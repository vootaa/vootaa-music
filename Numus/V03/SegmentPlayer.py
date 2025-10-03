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
        
        # 合并参数
        final_params = self._merge_parameters(segment, override_params)
        
        # 构造OSC消息
        osc_message = self._build_osc_message(
            segment.sub_type,
            track_name,
            final_params
        )
        
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
        self.client.send_message("/numus/cmd", ["stop_segment", track_name])
        
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
            param_name: 参数名（volume, cutoff, amp等）
            value: 新值
        """
        self.client.send_message("/numus/cmd", [
            "set_param",
            track_name,
            param_name,
            float(value) if isinstance(value, (int, float)) else str(value)
        ])
        
        # 更新本地记录
        if track_name in self.active_segments:
            self.active_segments[track_name]["params"][param_name] = value
    
    def crossfade_segments(self, from_track: str, to_track: str, duration_bars: int):
        """
        执行两个Segment间的crossfade
        
        Args:
            from_track: 源track名称
            to_track: 目标track名称
            duration_bars: 过渡时长（小节数）
        """
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
    
    def _merge_parameters(self, segment: StandardSegment, 
                         override_params: Optional[Dict]) -> Dict:
        """合并Segment参数和覆盖参数"""
        base_params = segment.playback_params.to_dict()
        
        if override_params:
            base_params.update(override_params)
        
        return base_params
    
    def _build_osc_message(self, segment_type: SegmentSubType, 
                          track_name: str, params: Dict) -> list:
        """
        构造OSC消息
        
        格式: ["play_segment", track_name, segment_type, params_json]
        """
        return [
            "play_segment",
            track_name,
            segment_type.value,
            json.dumps(params, ensure_ascii=False)
        ]
    
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