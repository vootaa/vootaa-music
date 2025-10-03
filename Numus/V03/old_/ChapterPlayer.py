"""
Chapter播放器
管理Chapter内Section序列播放和Section间过渡
"""

from typing import Optional, Dict, List
import time
import threading
from CoreDataStructure import Chapter, Section, PatternDNA
from SectionPlayer import SectionPlayer
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary


class ChapterPlayer:
    """Chapter级别的播放控制器"""
    
    def __init__(self, segment_player: SegmentPlayer, segment_library: SegmentLibrary):
        """
        初始化Chapter播放器
        
        Args:
            segment_player: Segment播放器实例
            segment_library: Segment素材库实例
        """
        self.section_player = SectionPlayer(segment_player, segment_library)
        self.segment_library = segment_library
        self.current_chapter: Optional[Chapter] = None
        self.is_playing = False
        self.playback_thread: Optional[threading.Thread] = None
    
    def play_chapter(self,
                     chapter: Chapter,
                     track_id: str,
                     core_bpm: int,
                     pattern_dna: PatternDNA,
                     override_params: Optional[Dict] = None):
        """
        播放一个Chapter
        
        Args:
            chapter: Chapter对象
            track_id: Track标识
            core_bpm: 核心BPM
            pattern_dna: 模式DNA
            override_params: 全局覆盖参数
        """
        self.current_chapter = chapter
        self.is_playing = True
        
        # 启动播放线程
        self.playback_thread = threading.Thread(
            target=self._playback_worker,
            args=(chapter, track_id, core_bpm, pattern_dna, override_params)
        )
        self.playback_thread.start()
    
    def _playback_worker(self,
                        chapter: Chapter,
                        track_id: str,
                        core_bpm: int,
                        pattern_dna: PatternDNA,
                        override_params: Optional[Dict]):
        """Chapter播放工作线程"""
        
        # 应用Chapter级别的Pattern DNA变体（如果有）
        chapter_params = override_params or {}
        if chapter.pattern_dna_variant:
            chapter_params.update(chapter.pattern_dna_variant)
        
        # 依次播放每个Section
        for section in chapter.sections:
            if not self.is_playing:
                break
            
            print(f"播放Section: {section.name} (类型: {section.section_type.value})")
            
            # 播放Section
            self.section_player.play_section(
                section=section,
                track_id=track_id,
                chapter_id=chapter.id,
                bpm=core_bpm,
                override_params=chapter_params
            )
            
            # 等待Section完成
            section_duration = self._calculate_section_duration(section, core_bpm)
            time.sleep(section_duration)
            
            # 停止当前Section
            self.section_player.stop_section()
    
    def _calculate_section_duration(self, section: Section, bpm: int) -> float:
        """计算Section时长（秒）"""
        bar_duration = (60.0 / bpm) * 4  # 4/4拍
        return section.duration_bars * bar_duration
    
    def stop_chapter(self):
        """停止Chapter播放"""
        self.is_playing = False
        self.section_player.stop_section()
        self.current_chapter = None
    
    def get_chapter_progress(self) -> Dict:
        """获取Chapter播放进度"""
        if not self.current_chapter:
            return {"progress": 0.0}
        
        section_progress = self.section_player.get_section_progress()
        
        return {
            "chapter_id": self.current_chapter.id,
            "chapter_name": self.current_chapter.name,
            "section_progress": section_progress
        }