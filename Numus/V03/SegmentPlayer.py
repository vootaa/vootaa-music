"""
Segment播放器（V03修正版）
将StandardSegment的参数解析为OSC命令发送到Sonic Pi
"""

from pythonosc import udp_client
from typing import Optional, Dict, Any
import json
import time
from StandardSegment import StandardSegment, SegmentSubType


class SegmentPlayer:
    """
    Segment级别的OSC控制器
    职责：将Segment参数转换为OSC消息
    """
    
    # Segment类型到Sonic Pi播放函数的映射
    TYPE_MAPPING = {
        SegmentSubType.KICK_PATTERN: "kick",
        SegmentSubType.SNARE_PATTERN: "snare",
        SegmentSubType.HIHAT_PATTERN: "hat",
        SegmentSubType.PERCUSSION_LAYER: "hat",
        SegmentSubType.FULL_DRUM_KIT: "kick",
        SegmentSubType.BASS_LINE: "bass",
        SegmentSubType.SUB_BASS: "bass",
        SegmentSubType.CHORD_PROGRESSION: "chord",
        SegmentSubType.PAD: "pad",
        SegmentSubType.LEAD_MELODY: "lead",
        SegmentSubType.ARPEGGIO: "arp",
        SegmentSubType.HOOK: "lead",
        SegmentSubType.RISER: "rise",
        SegmentSubType.IMPACT: "rise",
        SegmentSubType.AMBIENT_LAYER: "amb",
        SegmentSubType.SYNTH_TEXTURE: "tex"
    }
    
    def __init__(self, osc_ip: str = "127.0.0.1", osc_port: int = 4560):
        """
        初始化Segment播放器
        
        Args:
            osc_ip: Sonic Pi OSC服务器地址
            osc_port: Sonic Pi OSC端口（默认4560）
        """
        self.client = udp_client.SimpleUDPClient(osc_ip, osc_port)
        self.active_segments: Dict[str, Dict] = {}
        self.track_counter = 0
        
        print(f"SegmentPlayer初始化: {osc_ip}:{osc_port}")
    
    def play_segment(self, 
                     segment: StandardSegment,
                     track_id: str,
                     chapter_id: str,
                     section_id: str,
                     override_params: Optional[Dict[str, Any]] = None) -> str:
        """
        播放一个Segment
        
        Args:
            segment: StandardSegment对象
            track_id: Track标识
            chapter_id: Chapter标识
            section_id: Section标识
            override_params: 覆盖参数（如BPM、调性）
        
        Returns:
            生成的唯一track_name
        """
        # 生成唯一的track名称
        track_name = self._generate_track_name(track_id, chapter_id, section_id, segment.id)
        
        # 合并参数并压缩
        final_params = self._merge_and_compress_parameters(segment, override_params)
        
        # 获取Sonic Pi播放类型
        play_type = self.TYPE_MAPPING.get(segment.sub_type, "tex")
        
        # 构造OSC消息（匹配test_osc.py的格式）
        osc_message = [
            "play",
            track_name,
            play_type,
            json.dumps(final_params, ensure_ascii=False)
        ]
        
        # 发送到Sonic Pi
        self._send_osc_message(osc_message)
        
        # 记录活跃segment
        self.active_segments[track_name] = {
            "segment_id": segment.id,
            "segment_type": segment.sub_type.value,
            "start_time": time.time(),
            "params": final_params
        }
        
        print(f"播放Segment: {segment.name} -> {track_name}")
        return track_name
    
    def stop_segment(self, track_name: str):
        """停止指定的Segment"""
        self.client.send_message("/numus/cmd", ["stop", track_name])
        
        if track_name in self.active_segments:
            print(f"停止Segment: {track_name}")
            del self.active_segments[track_name]
    
    def stop_all_segments(self):
        """停止所有Segment"""
        self.client.send_message("/numus/cmd", ["stop_all"])
        self.active_segments.clear()
        print("停止所有Segment")
    
    def set_segment_param(self, track_name: str, param_name: str, value: Any):
        """
        动态调整Segment参数
        
        Args:
            track_name: Track名称
            param_name: 参数名（vol, cut, amp等，使用压缩名称）
            value: 新值
        """
        # 压缩参数名
        compressed_name = self._compress_param_name(param_name)
        
        self.client.send_message("/numus/cmd", [
            "set",
            track_name,
            compressed_name,
            float(value) if isinstance(value, (int, float)) else str(value)
        ])
        
        # 更新本地记录
        if track_name in self.active_segments:
            self.active_segments[track_name]["params"][compressed_name] = value
    
    def crossfade_segments(self, from_track: str, to_track: str, duration_bars: int):
        """
        执行两个Segment间的crossfade（通过音量自动化实现）
        
        Args:
            from_track: 源track名称
            to_track: 目标track名称
            duration_bars: 过渡时长（小节数）
        """
        # Sonic Pi端需要逐步降低from_track的音量，升高to_track的音量
        # 这里发送目标状态，实际淡入淡出在Sonic Pi端通过线程实现
        self.client.send_message("/numus/cmd", [
            "crossfade",
            from_track,
            to_track,
            duration_bars
        ])
        print(f"Crossfade: {from_track} -> {to_track} ({duration_bars} bars)")
    
    def _generate_track_name(self, track_id: str, chapter_id: str, 
                            section_id: str, segment_id: str) -> str:
        """
        生成唯一的track名称
        格式: t{track}_c{chapter}_s{section}_{segment}_{counter}
        """
        self.track_counter += 1
        
        # 清理ID，只保留字母数字
        clean = lambda s: ''.join(c for c in s if c.isalnum())[:8]
        
        return (f"t{clean(track_id)}_c{clean(chapter_id)}_"
                f"s{clean(section_id)}_{clean(segment_id)}_{self.track_counter}")
    
    def _merge_and_compress_parameters(self, segment: StandardSegment, 
                                       override_params: Optional[Dict]) -> Dict:
        """
        合并参数并压缩为Sonic Pi期望的简短格式
        
        参数名映射：
        duration_bars -> db
        pattern -> pt
        synth -> syn
        notes -> ns
        amp -> amp (保持)
        release -> rel
        cutoff -> cut (Sonic Pi端会映射到cutoff)
        ...
        """
        base_params = segment.playback_params.to_dict()
        
        if override_params:
            base_params.update(override_params)
        
        # 压缩参数名
        compressed = {}
        for key, value in base_params.items():
            compressed_key = self._compress_param_name(key)
            compressed_value = self._compress_value(value)
            compressed[compressed_key] = compressed_value
        
        return compressed
    
    def _compress_param_name(self, name: str) -> str:
        """压缩参数名"""
        mapping = {
            "duration_bars": "db",
            "pattern": "pt",
            "synth": "syn",
            "notes": "ns",
            "chords": "chs",
            "attack": "atk",
            "release": "rel",
            "sustain": "sus",
            "reverb": "rev",
            "root_note": "rn",
            "note_duration": "nd",
            "speed": "spd",
            "cutoff": "cut",
            "volume": "vol",
            "res": "res",
            "bpm": "bpm",
            "amp": "amp"
        }
        return mapping.get(name, name)
    
    def _compress_value(self, value: Any) -> Any:
        """
        压缩值（移除Sonic Pi符号的冒号前缀）
        
        例如: ":bd_haus" -> "bd_haus"
        """
        if isinstance(value, str) and value.startswith(":"):
            return value[1:]  # 移除冒号
        elif isinstance(value, list):
            # 递归处理列表
            return [self._compress_value(v) for v in value]
        return value
    
    def _send_osc_message(self, message: list):
        """发送OSC消息到Sonic Pi"""
        try:
            self.client.send_message("/numus/cmd", message)
        except Exception as e:
            print(f"OSC发送错误: {e}")
    
    def get_active_segments_info(self) -> Dict:
        """获取当前活跃segment信息"""
        return {
            name: {
                "segment_id": info["segment_id"],
                "type": info["segment_type"],
                "duration": time.time() - info["start_time"]
            }
            for name, info in self.active_segments.items()
        }