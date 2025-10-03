"""
Track指挥器
管理单场EDM Live Show的完整播放流程
"""

from typing import Optional, Dict
import time
import threading
from CoreDataStructure import Track, ChapterTransition
from ChapterPlayer import ChapterPlayer
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary


class TrackConductor:
    """Track级别的总指挥"""
    
    def __init__(self, segment_player: SegmentPlayer, segment_library: SegmentLibrary):
        """
        初始化Track指挥器
        
        Args:
            segment_player: Segment播放器实例
            segment_library: Segment素材库实例
        """
        self.chapter_player = ChapterPlayer(segment_player, segment_library)
        self.current_track: Optional[Track] = None
        self.is_playing = False
        self.playback_thread: Optional[threading.Thread] = None
    
    def play_track(self, track: Track):
        """
        播放一个Track
        
        Args:
            track: Track对象（包含完整的DNA配置）
        """
        self.current_track = track
        self.is_playing = True
        
        print(f"开始播放Track: {track.name}")
        print(f"场景: {track.theme_scene}")
        print(f"BPM: {track.core_dna.tempo}")
        print(f"调性: {track.core_dna.scale}")
        
        # 启动播放线程
        self.playback_thread = threading.Thread(
            target=self._playback_worker,
            args=(track,)
        )
        self.playback_thread.start()
    
    def _playback_worker(self, track: Track):
        """Track播放工作线程"""
        
        for i, chapter in enumerate(track.chapters):
            if not self.is_playing:
                break
            
            print(f"\n{'='*60}")
            print(f"Chapter {i+1}/{len(track.chapters)}: {chapter.name}")
            print(f"风格: {chapter.style}")
            print(f"{'='*60}\n")
            
            # 播放Chapter
            self.chapter_player.play_chapter(
                chapter=chapter,
                track_id=track.id,
                core_bpm=track.core_dna.tempo,
                pattern_dna=track.pattern_dna
            )
            
            # 等待Chapter完成
            chapter_duration = self._calculate_chapter_duration(
                chapter, track.core_dna.tempo
            )
            time.sleep(chapter_duration)
            
            # 停止当前Chapter
            self.chapter_player.stop_chapter()
            
            # 执行Chapter间过渡（如果不是最后一个）
            if i < len(track.chapters) - 1:
                transition = self._find_transition(track, chapter.id, track.chapters[i+1].id)
                if transition:
                    self._execute_transition(transition, track.core_dna.tempo)
        
        print(f"\nTrack播放完成: {track.name}")
        self.is_playing = False
    
    def _calculate_chapter_duration(self, chapter, bpm: int) -> float:
        """计算Chapter时长（秒）"""
        bar_duration = (60.0 / bpm) * 4
        return chapter.duration_bars * bar_duration
    
    def _find_transition(self, track: Track, from_id: str, to_id: str) -> Optional[ChapterTransition]:
        """查找Chapter间的过渡配置"""
        for transition in track.chapter_transitions:
            if transition.from_chapter_id == from_id and transition.to_chapter_id == to_id:
                return transition
        return None
    
    def _execute_transition(self, transition: ChapterTransition, bpm: int):
        """
        执行Chapter间的过渡
        
        Args:
            transition: 过渡配置
            bpm: 当前BPM
        """
        print(f"\n执行过渡: {transition.transition_type.value}")
        print(f"过渡时长: {transition.duration_bars} bars")
        
        bar_duration = (60.0 / bpm) * 4
        transition_duration = transition.duration_bars * bar_duration
        
        # TODO: 根据transition_type实现不同的过渡效果
        # 这里暂时简单等待
        time.sleep(transition_duration)
    
    def stop_track(self):
        """停止Track播放"""
        self.is_playing = False
        self.chapter_player.stop_chapter()
        self.current_track = None
    
    def get_track_progress(self) -> Dict:
        """获取Track播放进度"""
        if not self.current_track:
            return {"progress": 0.0}
        
        chapter_progress = self.chapter_player.get_chapter_progress()
        
        return {
            "track_id": self.current_track.id,
            "track_name": self.current_track.name,
            "chapter_progress": chapter_progress
        }