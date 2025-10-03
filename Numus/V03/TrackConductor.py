"""
Track指挥器（修正版）
完整实现Chapter间DJ过渡
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
        self.chapter_player = ChapterPlayer(segment_player, segment_library)
        self.dj_transition = DJTransitionManager(segment_player)
        self.segment_player = segment_player
        
        self.current_track: Optional[Track] = None
        self.is_playing = False
        self.playback_thread: Optional[threading.Thread] = None
    
    def play_track(self, track: Track):
        """播放一个Track"""
        self.current_track = track
        self.is_playing = True
        
        print(f"\n{'#'*80}")
        print(f"# 开始播放Track: {track.name}")
        print(f"# 场景: {track.theme_scene} | BPM: {track.core_dna.tempo}")
        print(f"# 时长: {track.duration_minutes:.1f}分钟 | Chapters: {len(track.chapters)}")
        print(f"{'#'*80}\n")
        
        self.playback_thread = threading.Thread(
            target=self._playback_worker,
            args=(track,),
            daemon=True
        )
        self.playback_thread.start()
    
    def _playback_worker(self, track: Track):
        """Track播放工作线程"""
        prev_tracks = []
        
        for i, chapter in enumerate(track.chapters):
            if not self.is_playing:
                break
            
            print(f"\n{'='*80}")
            print(f"Chapter {i+1}/{len(track.chapters)}: {chapter.name}")
            print(f"{'='*80}")
            
            # Chapter间过渡处理
            if i > 0:
                transition = self._find_transition(track, track.chapters[i-1].id, chapter.id)
                
                if transition:
                    # 启动新Chapter的前几个Section（用于overlap）
                    new_tracks = self._start_chapter_overlap(
                        chapter, track, initial_volume=0.0
                    )
                    
                    # 执行DJ过渡
                    self.dj_transition.execute_transition(
                        transition=transition,
                        from_chapter_tracks=prev_tracks,
                        to_chapter_tracks=new_tracks,
                        bpm=track.core_dna.tempo
                    )
                    
                    # 等待过渡完成
                    trans_duration = self.dj_transition.get_transition_duration(
                        transition, track.core_dna.tempo
                    )
                    time.sleep(trans_duration)
                    
                    # 继续播放新Chapter剩余部分
                    remaining_tracks = self._play_chapter_remaining(chapter, track)
                    prev_tracks = new_tracks + remaining_tracks
                else:
                    # 无过渡配置，直接播放
                    prev_tracks = self._play_chapter_full(chapter, track)
            else:
                # 第一个Chapter，直接播放
                prev_tracks = self._play_chapter_full(chapter, track)
        
        print(f"\n{'#'*80}")
        print(f"# Track播放完成: {track.name}")
        print(f"{'#'*80}\n")
        
        self.is_playing = False
    
    def _play_chapter_full(self, chapter, track) -> List[str]:
        """完整播放Chapter"""
        return self.chapter_player.play_chapter(
            chapter=chapter,
            track_id=track.id,
            core_bpm=track.core_dna.tempo,
            pattern_dna=track.pattern_dna
        )
    
    def _start_chapter_overlap(self, chapter, track, initial_volume=0.0) -> List[str]:
        """启动Chapter的前几个Section（用于DJ过渡overlap）"""
        # 简化：启动第一个Section，音量设为0等待淡入
        first_section = chapter.sections[0] if chapter.sections else None
        if not first_section:
            return []
        
        tracks = self.chapter_player.section_player.play_section(
            section=first_section,
            track_id=track.id,
            chapter_id=chapter.id,
            bpm=track.core_dna.tempo,
            override_params={"volume": initial_volume}
        )
        return tracks
    
    def _play_chapter_remaining(self, chapter, track) -> List[str]:
        """播放Chapter的剩余Section"""
        remaining = []
        for section in chapter.sections[1:]:  # 跳过第一个已播放的Section
            tracks = self.chapter_player.section_player.play_section(
                section=section,
                track_id=track.id,
                chapter_id=chapter.id,
                bpm=track.core_dna.tempo
            )
            remaining.extend(tracks)
            
            # 等待Section完成
            duration = self.chapter_player._calculate_section_duration(
                section, track.core_dna.tempo
            )
            time.sleep(duration)
            self.chapter_player.section_player.stop_section()
        
        return remaining
    
    def _find_transition(self, track, from_id, to_id) -> Optional[ChapterTransition]:
        """查找Chapter间的过渡配置"""
        for trans in track.chapter_transitions:
            if trans.from_chapter_id == from_id and trans.to_chapter_id == to_id:
                return trans
        return None
    
    def stop_track(self):
        """停止Track播放"""
        self.is_playing = False
        self.chapter_player.stop_chapter()
        self.segment_player.stop_all_segments()
        self.current_track = None
    
    def get_track_progress(self) -> Dict:
        """获取播放进度"""
        if not self.current_track:
            return {"progress": 0.0}
        
        return {
            "track_id": self.current_track.id,
            "track_name": self.current_track.name,
            "chapter_progress": self.chapter_player.get_chapter_progress()
        }