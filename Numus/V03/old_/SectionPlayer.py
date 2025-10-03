"""
Section播放器
管理Section内多个Segment的协调播放
"""

from typing import List, Dict, Optional
import time
import threading
from CoreDataStructure import Section, Segment
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary


class SectionPlayer:
    """Section级别的播放控制器"""
    
    def __init__(self, segment_player: SegmentPlayer, segment_library: SegmentLibrary):
        """
        初始化Section播放器
        
        Args:
            segment_player: Segment播放器实例
            segment_library: Segment素材库实例
        """
        self.segment_player = segment_player
        self.segment_library = segment_library
        self.current_section: Optional[Section] = None
        self.section_start_time: Optional[float] = None
        self.active_loop_names: List[str] = []
        self.is_playing = False
        self.playback_thread: Optional[threading.Thread] = None
    
    def play_section(self, 
                     section: Section,
                     track_id: str,
                     chapter_id: str,
                     bpm: int,
                     override_params: Optional[Dict] = None):
        """
        播放一个Section
        
        Args:
            section: Section对象
            track_id: Track标识
            chapter_id: Chapter标识
            bpm: 当前BPM
            override_params: 全局覆盖参数
        """
        self.current_section = section
        self.section_start_time = time.time()
        self.is_playing = True
        self.active_loop_names.clear()
        
        # 计算小节时长（秒）
        bar_duration = (60.0 / bpm) * 4  # 假设4/4拍
        
        # 启动播放线程
        self.playback_thread = threading.Thread(
            target=self._playback_worker,
            args=(section, track_id, chapter_id, bpm, bar_duration, override_params)
        )
        self.playback_thread.start()
    
    def _playback_worker(self, 
                        section: Section,
                        track_id: str,
                        chapter_id: str,
                        bpm: int,
                        bar_duration: float,
                        override_params: Optional[Dict]):
        """播放工作线程"""
        current_bar = 0
        
        # 解析segment_sequence
        for seq_item in section.segment_sequence:
            if not self.is_playing:
                break
            
            segment_id = seq_item.get("segment_id")
            start_bar = seq_item.get("start_bar", current_bar)
            duration_bars = seq_item.get("duration_bars")
            segment_params = seq_item.get("params", {})
            
            # 从库中加载Segment
            segment = self.segment_library.get_segment(segment_id)
            if not segment:
                print(f"警告: Segment {segment_id} 未找到")
                continue
            
            # 等待到start_bar
            wait_time = (start_bar - current_bar) * bar_duration
            if wait_time > 0:
                time.sleep(wait_time)
                current_bar = start_bar
            
            # 合并参数
            merged_params = {
                "bpm": bpm,
                **(override_params or {}),
                **segment_params
            }
            
            # 播放Segment
            loop_name = self.segment_player.play_segment(
                segment=segment,
                track_id=track_id,
                chapter_id=chapter_id,
                section_id=section.id,
                override_params=merged_params
            )
            self.active_loop_names.append(loop_name)
            
            # 如果指定了duration，在结束时停止
            if duration_bars:
                threading.Timer(
                    duration_bars * bar_duration,
                    lambda: self.segment_player.stop_segment(loop_name)
                ).start()
            
            current_bar += (duration_bars or segment.musical_params.duration_bars)
    
    def stop_section(self):
        """停止当前Section播放"""
        self.is_playing = False
        
        # 停止所有活跃的segment
        for loop_name in self.active_loop_names:
            self.segment_player.stop_segment(loop_name)
        
        self.active_loop_names.clear()
        self.current_section = None
    
    def get_section_progress(self) -> Dict:
        """获取Section播放进度"""
        if not self.current_section or not self.section_start_time:
            return {"progress": 0.0, "elapsed_bars": 0}
        
        elapsed = time.time() - self.section_start_time
        # 简化计算，假设120 BPM
        elapsed_bars = elapsed / 2.0
        progress = min(elapsed_bars / self.current_section.duration_bars, 1.0)
        
        return {
            "section_id": self.current_section.id,
            "progress": progress,
            "elapsed_bars": elapsed_bars,
            "total_bars": self.current_section.duration_bars
        }