"""
Segment播放器
负责将StandardSegment转换为OSC消息并发送到Sonic Pi
"""

from pythonosc import udp_client, osc_message_builder
from typing import Optional, Dict, Any
import time
from StandardSegment import StandardSegment, SonicPiCode


class SegmentPlayer:
    """Segment级别的播放控制器"""
    
    def __init__(self, osc_ip: str = "127.0.0.1", osc_port: int = 4560):
        """
        初始化Segment播放器
        
        Args:
            osc_ip: Sonic Pi OSC服务器地址
            osc_port: Sonic Pi OSC端口
        """
        self.client = udp_client.SimpleUDPClient(osc_ip, osc_port)
        self.active_segments: Dict[str, Dict] = {}  # 当前播放的segment
        self.loop_counter = 0  # 全局循环计数器，用于生成唯一loop名称
    
    def play_segment(self, 
                     segment: StandardSegment, 
                     track_id: str,
                     chapter_id: str,
                     section_id: str,
                     override_params: Optional[Dict[str, Any]] = None) -> str:
        """
        播放一个Segment
        
        Args:
            segment: 要播放的Segment对象
            track_id: Track标识
            chapter_id: Chapter标识
            section_id: Section标识
            override_params: 覆盖的参数（如BPM、调性等）
        
        Returns:
            生成的唯一loop_name
        """
        # 生成唯一的loop名称，避免冲突
        unique_loop_name = self._generate_unique_loop_name(
            track_id, chapter_id, section_id, segment.id
        )
        
        # 准备Sonic Pi代码
        sonic_code = self._prepare_sonic_code(
            segment.sonic_pi_code,
            unique_loop_name,
            segment.musical_params.to_dict(),
            override_params or {}
        )
        
        # 发送代码到Sonic Pi
        self._send_to_sonic_pi(sonic_code)
        
        # 记录活跃的segment
        self.active_segments[unique_loop_name] = {
            "segment_id": segment.id,
            "start_time": time.time(),
            "duration_bars": segment.musical_params.duration_bars,
            "track_id": track_id,
            "chapter_id": chapter_id,
            "section_id": section_id
        }
        
        return unique_loop_name
    
    def stop_segment(self, loop_name: str):
        """停止指定的Segment播放"""
        stop_code = f"live_loop :{loop_name} do\n  stop\nend"
        self._send_to_sonic_pi(stop_code)
        
        if loop_name in self.active_segments:
            del self.active_segments[loop_name]
    
    def stop_all_segments(self):
        """停止所有Segment播放"""
        self._send_to_sonic_pi("stop")
        self.active_segments.clear()
    
    def _generate_unique_loop_name(self, track_id: str, chapter_id: str, 
                                   section_id: str, segment_id: str) -> str:
        """
        生成唯一的loop名称
        格式：t{track}_c{chapter}_s{section}_{segment}_{counter}
        """
        self.loop_counter += 1
        # 清理ID中的特殊字符，只保留字母数字下划线
        clean_track = ''.join(c for c in track_id if c.isalnum() or c == '_')[:8]
        clean_chapter = ''.join(c for c in chapter_id if c.isalnum() or c == '_')[:8]
        clean_section = ''.join(c for c in section_id if c.isalnum() or c == '_')[:8]
        clean_segment = ''.join(c for c in segment_id if c.isalnum() or c == '_')[:12]
        
        return f"t{clean_track}_c{clean_chapter}_s{clean_section}_{clean_segment}_{self.loop_counter}"
    
    def _prepare_sonic_code(self, 
                           sonic_pi_code: SonicPiCode,
                           unique_loop_name: str,
                           musical_params: Dict,
                           override_params: Dict) -> str:
        """
        准备要发送的Sonic Pi代码
        将参数注入到代码中
        """
        code_parts = []
        
        # 添加setup代码（如果有）
        if sonic_pi_code.setup_code:
            code_parts.append(sonic_pi_code.setup_code)
        
        # 应用参数覆盖
        final_params = {**musical_params, **override_params}
        
        # 添加参数设置
        if 'bpm' in final_params and final_params['bpm']:
            code_parts.append(f"use_bpm {final_params['bpm']}")
        
        if 'synth' in final_params and final_params['synth']:
            code_parts.append(f"use_synth {final_params['synth']}")
        
        # 替换原始loop名称为唯一名称
        main_code = sonic_pi_code.main_code.replace(
            sonic_pi_code.live_loop_name,
            unique_loop_name
        )
        
        code_parts.append(main_code)
        
        return "\n".join(code_parts)
    
    def _send_to_sonic_pi(self, code: str):
        """发送代码到Sonic Pi"""
        self.client.send_message("/run-code", code)
    
    def get_active_segments_info(self) -> Dict:
        """获取当前活跃segment信息"""
        return self.active_segments.copy()
    
    def sync_with_timeline(self, current_bar: int):
        """
        与时间线同步，检查是否需要停止已完成的segment
        
        Args:
            current_bar: 当前小节数
        """
        # 这个方法留给SectionPlayer调用
        pass