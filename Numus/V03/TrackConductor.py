"""
Track指挥器
管理单场EDM Live Show的完整播放流程，包括Chapter间DJ过渡
"""

from typing import Optional, Dict, List
import time
import threading
from CoreDataStructure import Track, ChapterTransition
from ChapterPlayer import ChapterPlayer
from DJTransitionManager import DJTransitionManager
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary


class TrackConductor:
    """Track级别的总指挥"""
    
    def __init__(self, segment_player: SegmentPlayer, segment_library: SegmentLibrary):
        """
        初始化Track指挥器
        
        Args:
            segment_player: SegmentPlayer实例
            segment_library: Segment素材库实例
        """
        self.chapter_player = ChapterPlayer(segment_player, segment_library)
        self.dj_transition_manager = DJTransitionManager(segment_player)
        self.segment_player = segment_player
        
        self.current_track: Optional[Track] = None
        self.is_playing = False
        self.playback_thread: Optional[threading.Thread] = None
    
    def play_track(self, track: Track):
        """
        播放一个Track
        
        Args:
            track: Track对象（包含完整的DNA配置和Chapters）
        """
        self.current_track = track
        self.is_playing = True
        
        print(f"\n{'#'*80}")
        print(f"#{'开始播放Track'.center(76)}#")
        print(f"#{'':76}#")
        print(f"#  名称: {track.name:<68}#")
        print(f"#  场景: {track.theme_scene:<68}#")
        print(f"#  BPM: {track.core_dna.tempo:<69}#")
        print(f"#  调性: {track.core_dna.scale:<68}#")
        print(f"#  时长: {track.duration_minutes:.1f} 分钟{' '*56}#")
        print(f"#  Chapters: {len(track.chapters):<64}#")
        print(f"#{'':76}#")
        print(f"{'#'*80}\n")
        
        # 启动播放线程
        self.playback_thread = threading.Thread(
            target=self._playback_worker,
            args=(track,),
            daemon=True
        )
        self.playback_thread.start()
    
    def _playback_worker(self, track: Track):
        """Track播放工作线程"""
        
        previous_chapter_tracks = []
        
        for i, chapter in enumerate(track.chapters):
            if not self.is_playing:
                break
            
            print(f"\n{'='*80}")
            print(f"Chapter {i+1}/{len(track.chapters)}: {chapter.name}")
            print(f"风格: {chapter.style} | 能量: {chapter.energy_level}")
            print(f"{'='*80}")
            
            # 如果不是第一个Chapter，执行DJ过渡
            if i > 0:
                transition = self._find_transition(
                    track,
                    track.chapters[i-1].id,
                    chapter.id
                )
                
                if transition:
                    # 提前启动新Chapter的第一个Section
                    # 这样可以在过渡期间同时播放两个Chapter
                    new_chapter_tracks = self._start_chapter_first_section(
                        chapter, track, initial_volume=0.0
                    )
                    
                    # 执行DJ过渡
                    self.dj_transition_manager.execute_transition(
                        transition=transition,
                        from_chapter_tracks=previous_chapter_tracks,
                        to_chapter_tracks=new_chapter_tracks,
                        bpm=track.core_dna.tempo
                    )
                    
                    # 等待过渡完成
                    transition_duration = self.dj_transition_manager.get_transition_duration(
                        transition, track.core_dna.tempo
                    )
                    time.sleep(transition_duration)
                    
                    # 继续播放新Chapter的剩余部分
                    remaining_tracks = self._continue_chapter(chapter, track)
                    previous_chapter_tracks = new_chapter_tracks + remaining_tracks
                else:
                    # 没有配置过渡，直接播放
                    chapter_tracks = self.chapter_player.play_chapter(
                        chapter=chapter,
                        track_id=track.id,
                        core_bpm=track.core_dna.tempo,
                        pattern_dna=track.pattern_dna
                    )
                    previous_chapter_tracks = chapter_tracks
            else:
                # 第一个Chapter，直接播放
                chapter_tracks = self.chapter_player.play_chapter(
                    chapter=chapter,
                    track_id=track.id,
                    core_bpm=track.core_dna.tempo,
                    pattern_dna=track.pattern_dna
                )
                previous_chapter_tracks = chapter_tracks
        
        print(f"\n{'#'*80}")
        print(f"#{'Track播放完成'.center(76)}#")
        print(f"#  {track.name:<73}#")
        print(f"{'#'*80}\n")
        
        self.is_playing = False
    
    def _find_transition(self, track: Track, from_id: str, to_id: str) -> Optional[ChapterTransition]:
        """查找Chapter间的过渡配置"""
        for transition in track.chapter_transitions:
            if (transition.from_chapter_id == from_id and 
                transition.to_chapter_id == to_id):
                return transition
        return None
    
    def _start_chapter_first_section(self, chapter, track, initial_volume=0.0):
        """
        启动Chapter的第一个Section（用于DJ过渡）
        
        Args:
            chapter: Chapter对象
            track: Track对象
            initial_volume: 初始音量（用于淡入）
        
        Returns:
            启动的track名称列表
        """
        # 这里简化实现，实际需要更复杂的逻辑
        # TODO: 实现更精细的Section部分启动
        return []
    
    def _continue_chapter(self, chapter, track):
        """继续播放Chapter的剩余部分"""
        # TODO: 实现Chapter剩余部分的播放
        return []
    
    def stop_track(self):
        """停止Track播放"""
        self.is_playing = False
        self.chapter_player.stop_chapter()
        self.segment_player.stop_all_segments()
        self.current_track = None
        print("Track播放已停止")
    
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