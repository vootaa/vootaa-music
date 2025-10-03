"""
DJ过渡管理器
实现专业的Chapter间DJ衔接技术
"""

import time
import threading
from typing import List, Callable, Dict
from enum import Enum
from CoreDataStructure import ChapterTransition, TransitionType
from SegmentPlayer import SegmentPlayer


class DJTransitionManager:
    """
    DJ级别的过渡效果管理器
    实现各种专业DJ技法
    """
    
    def __init__(self, segment_player: SegmentPlayer):
        """
        初始化DJ过渡管理器
        
        Args:
            segment_player: SegmentPlayer实例
        """
        self.segment_player = segment_player
        
        # 注册过渡处理函数
        self.transition_handlers: Dict[TransitionType, Callable] = {
            TransitionType.ENERGY_CROSSFADE: self.energy_crossfade,
            TransitionType.FILTER_SWEEP: self.filter_sweep,
            TransitionType.BREAKDOWN_BUILD: self.breakdown_build,
            TransitionType.IMPACT_DROP: self.impact_drop
        }
    
    def execute_transition(self,
                          transition: ChapterTransition,
                          from_chapter_tracks: List[str],
                          to_chapter_tracks: List[str],
                          bpm: int):
        """
        执行Chapter间的DJ过渡
        
        Args:
            transition: ChapterTransition配置
            from_chapter_tracks: 前一个Chapter的活跃track名称列表
            to_chapter_tracks: 后一个Chapter要启动的track名称列表
            bpm: 当前BPM
        """
        print(f"\n{'='*60}")
        print(f"执行DJ过渡: {transition.transition_type.value}")
        print(f"过渡时长: {transition.duration_bars} bars")
        print(f"From tracks: {len(from_chapter_tracks)}")
        print(f"To tracks: {len(to_chapter_tracks)}")
        print(f"{'='*60}\n")
        
        handler = self.transition_handlers.get(transition.transition_type)
        
        if handler:
            handler(transition, from_chapter_tracks, to_chapter_tracks, bpm)
        else:
            print(f"警告: 未找到过渡类型 {transition.transition_type}, 使用默认crossfade")
            self.energy_crossfade(transition, from_chapter_tracks, to_chapter_tracks, bpm)
    
    def energy_crossfade(self, 
                        transition: ChapterTransition,
                        from_tracks: List[str],
                        to_tracks: List[str],
                        bpm: int):
        """
        能量平滑过渡：音量淡入淡出
        经典DJ混音技法
        """
        bar_duration = (60.0 / bpm) * 4  # 一个小节的时长（秒）
        total_duration = transition.duration_bars * bar_duration
        steps = int(transition.duration_bars * 16)  # 1/16音符精度
        step_duration = total_duration / steps
        
        def crossfade_worker():
            for i in range(steps + 1):
                progress = i / steps
                
                # 淡出旧tracks（音量从1.0降到0.0）
                volume_out = 1.0 - progress
                for track in from_tracks:
                    self.segment_player.set_segment_param(track, "volume", volume_out)
                
                # 淡入新tracks（音量从0.0升到1.0）
                volume_in = progress
                for track in to_tracks:
                    self.segment_player.set_segment_param(track, "volume", volume_in)
                
                time.sleep(step_duration)
            
            # 过渡完成，停止旧tracks
            for track in from_tracks:
                self.segment_player.stop_segment(track)
            
            print("Energy Crossfade 完成")
        
        # 启动过渡线程
        threading.Thread(target=crossfade_worker, daemon=True).start()
    
    def filter_sweep(self,
                    transition: ChapterTransition,
                    from_tracks: List[str],
                    to_tracks: List[str],
                    bpm: int):
        """
        滤波器扫频过渡
        通过低通滤波器cutoff变化实现音色明暗变化
        """
        bar_duration = (60.0 / bpm) * 4
        total_duration = transition.duration_bars * bar_duration
        steps = int(transition.duration_bars * 16)
        step_duration = total_duration / steps
        
        def sweep_worker():
            for i in range(steps + 1):
                progress = i / steps
                
                # 旧tracks：cutoff从130降到40（变暗、变闷）
                cutoff_out = 130 - (90 * progress)
                for track in from_tracks:
                    self.segment_player.set_segment_param(track, "cutoff", cutoff_out)
                
                # 新tracks：cutoff从40升到130（变亮、变清晰）
                cutoff_in = 40 + (90 * progress)
                for track in to_tracks:
                    self.segment_player.set_segment_param(track, "cutoff", cutoff_in)
                
                time.sleep(step_duration)
            
            # 停止旧tracks
            for track in from_tracks:
                self.segment_player.stop_segment(track)
            
            print("Filter Sweep 完成")
        
        threading.Thread(target=sweep_worker, daemon=True).start()
    
    def breakdown_build(self,
                       transition: ChapterTransition,
                       from_tracks: List[str],
                       to_tracks: List[str],
                       bpm: int):
        """
        分解重建过渡
        先减少元素（breakdown），再逐步引入新元素（build）
        """
        bar_duration = (60.0 / bpm) * 4
        half_duration = (transition.duration_bars / 2) * bar_duration
        
        def breakdown_build_worker():
            # 阶段1：Breakdown - 快速减少旧元素
            breakdown_steps = int(transition.duration_bars * 8)
            for i in range(breakdown_steps):
                progress = i / breakdown_steps
                volume = 1.0 - progress
                
                for track in from_tracks:
                    self.segment_player.set_segment_param(track, "volume", volume)
                
                time.sleep(half_duration / breakdown_steps)
            
            # 停止所有旧tracks
            for track in from_tracks:
                self.segment_player.stop_segment(track)
            
            # 短暂静默（增强对比感）
            time.sleep(bar_duration * 0.5)
            
            # 阶段2：Build - 逐步引入新元素
            build_steps = int(transition.duration_bars * 8)
            for i in range(build_steps):
                progress = i / build_steps
                volume = progress
                
                for track in to_tracks:
                    self.segment_player.set_segment_param(track, "volume", volume)
                
                time.sleep(half_duration / build_steps)
            
            print("Breakdown-Build 完成")
        
        threading.Thread(target=breakdown_build_worker, daemon=True).start()
    
    def impact_drop(self,
                   transition: ChapterTransition,
                   from_tracks: List[str],
                   to_tracks: List[str],
                   bpm: int):
        """
        冲击降落过渡
        突然停止 + 短暂静默 + 强力启动
        常用于Drop前的紧张感营造
        """
        bar_duration = (60.0 / bpm) * 4
        
        def impact_drop_worker():
            # 立即停止所有旧tracks
            for track in from_tracks:
                self.segment_player.stop_segment(track)
            
            # 静默期（通常0.5-1个小节）
            silence_duration = min(transition.duration_bars * bar_duration, bar_duration)
            time.sleep(silence_duration)
            
            # 新tracks已经在外部启动，这里只确保音量为最大
            for track in to_tracks:
                self.segment_player.set_segment_param(track, "volume", 1.0)
            
            print("Impact Drop 完成")
        
        threading.Thread(target=impact_drop_worker, daemon=True).start()
    
    def get_transition_duration(self, transition: ChapterTransition, bpm: int) -> float:
        """
        计算过渡时长（秒）
        
        Args:
            transition: ChapterTransition配置
            bpm: 当前BPM
        
        Returns:
            过渡时长（秒）
        """
        bar_duration = (60.0 / bpm) * 4
        return transition.duration_bars * bar_duration