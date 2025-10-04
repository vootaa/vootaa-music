"""
Segment 完整功能展示
自动播放所有类型的 Segments，并使用 DJ 过渡技术连接
"""

import time
from typing import List, Dict
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary
from DJTransitionManager import DJTransitionManager
from CoreDataStructure import ChapterTransition, TransitionType
from StandardSegment import SegmentSubType, SegmentCategory


class SegmentShowcase:
    """Segment 展示系统"""
    
    def __init__(self):
        self.player = SegmentPlayer()
        self.library = SegmentLibrary("../segments")
        self.dj = DJTransitionManager(self.player)
        self.bpm = 128
        
        print("="*80)
        print("Numus V03 - Segment Showcase")
        print("="*80)
        print(f"\n加载了 {len(self.library.segments)} 个 Segments")
    
    def create_mini_chapter(self, 
                           name: str,
                           segments_config: List[Dict],
                           duration: float = 16.0) -> List[str]:
        """
        创建一个迷你章节（一组协调的 Segments）
        
        Args:
            name: 章节名称
            segments_config: Segment 配置列表 [{"subtype": ..., "override_params": ...}]
            duration: 播放时长（秒）
        
        Returns:
            活跃的 track 名称列表
        """
        print(f"\n{'='*60}")
        print(f"🎵 {name}")
        print(f"{'='*60}")
        
        active_tracks = []
        
        for i, config in enumerate(segments_config):
            subtype = config.get("subtype")
            override_params = config.get("override_params", {})
            delay = config.get("delay", 0)
            
            # 从库中获取该类型的第一个 Segment
            candidates = self.library.search_by_subtype(subtype)
            if not candidates:
                print(f"⚠️  未找到类型 {subtype.value} 的 Segment")
                continue
            
            segment = candidates[0]
            
            # 延迟启动
            if delay > 0:
                time.sleep(delay)
            
            # 播放 Segment
            track_name = self.player.play_segment(
                segment=segment,
                track_id="showcase",
                chapter_id=name.replace(" ", "_"),
                section_id=f"seg{i}",
                override_params={
                    "bpm": self.bpm,
                    **override_params
                }
            )
            
            active_tracks.append(track_name)
            print(f"  ✓ {segment.name}")
        
        # 播放指定时长
        print(f"\n播放 {duration:.1f} 秒...")
        time.sleep(duration)
        
        return active_tracks
    
    def transition_between_chapters(self,
                                   from_tracks: List[str],
                                   to_tracks: List[str],
                                   transition_type: TransitionType,
                                   duration_bars: int = 4):
        """在两个章节之间执行 DJ 过渡"""
        
        transition = ChapterTransition(
            from_chapter_id="prev",
            to_chapter_id="next",
            transition_type=transition_type,
            duration_bars=duration_bars
        )
        
        print(f"\n🔀 执行过渡: {transition_type.value} ({duration_bars} bars)")
        
        self.dj.execute_transition(
            transition=transition,
            from_chapter_tracks=from_tracks,
            to_chapter_tracks=to_tracks,
            bpm=self.bpm
        )
        
        # 等待过渡完成
        transition_duration = self.dj.get_transition_duration(transition, self.bpm)
        time.sleep(transition_duration + 0.5)
    
    def showcase_rhythm_foundation(self):
        """展示1: 节奏基础层"""
        return self.create_mini_chapter(
            name="Chapter 1: Rhythm Foundation",
            segments_config=[
                {
                    "subtype": SegmentSubType.KICK_PATTERN,
                    "override_params": {"amp": 1.2}
                },
                {
                    "subtype": SegmentSubType.SNARE_PATTERN,
                    "delay": 4,
                    "override_params": {"amp": 0.9}
                },
                {
                    "subtype": SegmentSubType.HIHAT_PATTERN,
                    "delay": 4,
                    "override_params": {"amp": 0.6}
                }
            ],
            duration=16.0
        )
    
    def showcase_bass_groove(self):
        """展示2: 低音律动"""
        return self.create_mini_chapter(
            name="Chapter 2: Bass Groove",
            segments_config=[
                {
                    "subtype": SegmentSubType.KICK_PATTERN,
                    "override_params": {"amp": 1.0}
                },
                {
                    "subtype": SegmentSubType.SUB_BASS,
                    "delay": 0,
                    "override_params": {"amp": 1.0}
                },
                {
                    "subtype": SegmentSubType.BASS_LINE,
                    "delay": 8,
                    "override_params": {"amp": 0.8}
                },
                {
                    "subtype": SegmentSubType.HIHAT_PATTERN,
                    "delay": 0,
                    "override_params": {"amp": 0.5}
                }
            ],
            duration=16.0
        )
    
    def showcase_harmonic_layers(self):
        """展示3: 和声层次"""
        return self.create_mini_chapter(
            name="Chapter 3: Harmonic Layers",
            segments_config=[
                {
                    "subtype": SegmentSubType.KICK_PATTERN,
                    "override_params": {"amp": 0.9}
                },
                {
                    "subtype": SegmentSubType.BASS_LINE,
                    "override_params": {"amp": 0.7}
                },
                {
                    "subtype": SegmentSubType.PAD,
                    "delay": 4,
                    "override_params": {"amp": 0.6}
                },
                {
                    "subtype": SegmentSubType.CHORD_PROGRESSION,
                    "delay": 4,
                    "override_params": {"amp": 0.5}
                }
            ],
            duration=16.0
        )
    
    def showcase_melodic_peak(self):
        """展示4: 旋律高潮"""
        return self.create_mini_chapter(
            name="Chapter 4: Melodic Peak",
            segments_config=[
                {
                    "subtype": SegmentSubType.KICK_PATTERN,
                    "override_params": {"amp": 1.1}
                },
                {
                    "subtype": SegmentSubType.SNARE_PATTERN,
                    "override_params": {"amp": 0.9}
                },
                {
                    "subtype": SegmentSubType.BASS_LINE,
                    "override_params": {"amp": 0.8}
                },
                {
                    "subtype": SegmentSubType.PAD,
                    "override_params": {"amp": 0.5}
                },
                {
                    "subtype": SegmentSubType.LEAD_MELODY,
                    "delay": 4,
                    "override_params": {"amp": 0.7}
                },
                {
                    "subtype": SegmentSubType.ARPEGGIO,
                    "delay": 4,
                    "override_params": {"amp": 0.6}
                }
            ],
            duration=20.0
        )
    
    def showcase_atmospheric_breakdown(self):
        """展示5: 氛围分解"""
        return self.create_mini_chapter(
            name="Chapter 5: Atmospheric Breakdown",
            segments_config=[
                {
                    "subtype": SegmentSubType.AMBIENT_LAYER,
                    "override_params": {"amp": 0.8}
                },
                {
                    "subtype": SegmentSubType.PAD,
                    "delay": 4,
                    "override_params": {"amp": 0.5}
                },
                {
                    "subtype": SegmentSubType.SYNTH_TEXTURE,
                    "delay": 4,
                    "override_params": {"amp": 0.6}
                }
            ],
            duration=16.0
        )
    
    def showcase_fx_buildup(self):
        """展示6: 特效积累"""
        return self.create_mini_chapter(
            name="Chapter 6: FX Build-up",
            segments_config=[
                {
                    "subtype": SegmentSubType.KICK_PATTERN,
                    "override_params": {"amp": 0.8}
                },
                {
                    "subtype": SegmentSubType.SNARE_PATTERN,
                    "override_params": {"amp": 0.7}
                },
                {
                    "subtype": SegmentSubType.RISER,
                    "delay": 0,
                    "override_params": {"amp": 0.7}
                },
                {
                    "subtype": SegmentSubType.HIHAT_PATTERN,
                    "delay": 4,
                    "override_params": {"amp": 0.6}
                }
            ],
            duration=16.0
        )
    
    def showcase_full_drop(self):
        """展示7: 完整爆发"""
        return self.create_mini_chapter(
            name="Chapter 7: Full Drop",
            segments_config=[
                {
                    "subtype": SegmentSubType.KICK_PATTERN,
                    "override_params": {"amp": 1.3}
                },
                {
                    "subtype": SegmentSubType.SNARE_PATTERN,
                    "override_params": {"amp": 1.0}
                },
                {
                    "subtype": SegmentSubType.HIHAT_PATTERN,
                    "override_params": {"amp": 0.7}
                },
                {
                    "subtype": SegmentSubType.BASS_LINE,
                    "override_params": {"amp": 1.0}
                },
                {
                    "subtype": SegmentSubType.LEAD_MELODY,
                    "override_params": {"amp": 0.8}
                },
                {
                    "subtype": SegmentSubType.PAD,
                    "override_params": {"amp": 0.6}
                },
                {
                    "subtype": SegmentSubType.ARPEGGIO,
                    "delay": 8,
                    "override_params": {"amp": 0.7}
                }
            ],
            duration=20.0
        )
    
    def run_complete_showcase(self):
        """运行完整的 Segment 展示"""
        print("\n" + "="*80)
        print("开始 Segment 完整展示")
        print("总共 7 个章节，使用不同的 DJ 过渡技术连接")
        print("="*80)
        
        input("\n按回车键开始...")
        
        # Chapter 1: Rhythm Foundation
        tracks_1 = self.showcase_rhythm_foundation()
        
        # Chapter 2: Bass Groove (使用 Energy Crossfade)
        tracks_2 = self.showcase_bass_groove()
        self.transition_between_chapters(
            from_tracks=tracks_1,
            to_tracks=tracks_2,
            transition_type=TransitionType.ENERGY_CROSSFADE,
            duration_bars=4
        )
        
        # Chapter 3: Harmonic Layers (使用 Filter Sweep)
        tracks_3 = self.showcase_harmonic_layers()
        self.transition_between_chapters(
            from_tracks=tracks_2,
            to_tracks=tracks_3,
            transition_type=TransitionType.FILTER_SWEEP,
            duration_bars=4
        )
        
        # Chapter 4: Melodic Peak (使用 Energy Crossfade)
        tracks_4 = self.showcase_melodic_peak()
        self.transition_between_chapters(
            from_tracks=tracks_3,
            to_tracks=tracks_4,
            transition_type=TransitionType.ENERGY_CROSSFADE,
            duration_bars=4
        )
        
        # Chapter 5: Atmospheric Breakdown (使用 Breakdown Build)
        tracks_5 = self.showcase_atmospheric_breakdown()
        self.transition_between_chapters(
            from_tracks=tracks_4,
            to_tracks=tracks_5,
            transition_type=TransitionType.BREAKDOWN_BUILD,
            duration_bars=8
        )
        
        # Chapter 6: FX Build-up (使用 Filter Sweep)
        tracks_6 = self.showcase_fx_buildup()
        self.transition_between_chapters(
            from_tracks=tracks_5,
            to_tracks=tracks_6,
            transition_type=TransitionType.FILTER_SWEEP,
            duration_bars=4
        )
        
        # Chapter 7: Full Drop (使用 Impact Drop)
        tracks_7 = self.showcase_full_drop()
        self.transition_between_chapters(
            from_tracks=tracks_6,
            to_tracks=tracks_7,
            transition_type=TransitionType.IMPACT_DROP,
            duration_bars=2
        )
        
        # 结束
        print("\n" + "="*80)
        print("展示即将结束...")
        print("="*80)
        time.sleep(5)
        
        # 渐进停止
        for track in tracks_7:
            self.player.stop_segment(track)
        
        print("\n✨ Segment Showcase 完成！")
        print("\n展示内容总结:")
        print("  1. Rhythm Foundation - 节奏基础")
        print("  2. Bass Groove - 低音律动")
        print("  3. Harmonic Layers - 和声层次")
        print("  4. Melodic Peak - 旋律高潮")
        print("  5. Atmospheric Breakdown - 氛围分解")
        print("  6. FX Build-up - 特效积累")
        print("  7. Full Drop - 完整爆发")
        print("\n使用的 DJ 过渡技术:")
        print("  • Energy Crossfade (音量淡入淡出)")
        print("  • Filter Sweep (滤波器扫频)")
        print("  • Breakdown Build (分解重建)")
        print("  • Impact Drop (冲击降落)")


class SegmentTypeShowcase:
    """按 Segment 类型分类展示"""
    
    def __init__(self):
        self.player = SegmentPlayer()
        self.library = SegmentLibrary("../segments")
        self.bpm = 128
    
    def showcase_by_category(self, category: SegmentCategory, duration: float = 8.0):
        """按类别展示所有 Segment"""
        print(f"\n{'='*80}")
        print(f"类别: {category.value}")
        print(f"{'='*80}")
        
        segments = self.library.search_by_category(category)
        print(f"共 {len(segments)} 个 Segments\n")
        
        for i, segment in enumerate(segments, 1):
            print(f"\n[{i}/{len(segments)}] {segment.name}")
            print(f"  类型: {segment.sub_type.value}")
            print(f"  能量: {segment.metadata.energy_level:.2f}")
            print(f"  时长: {segment.playback_params.duration_bars} bars")
            
            # 播放
            track = self.player.play_segment(
                segment=segment,
                track_id="showcase",
                chapter_id=category.value,
                section_id=f"seg{i}",
                override_params={"bpm": self.bpm}
            )
            
            time.sleep(duration)
            self.player.stop_segment(track)
            time.sleep(1)  # 短暂间隔
    
    def run_type_showcase(self):
        """运行类型展示"""
        print("\n" + "="*80)
        print("Segment 类型完整展示")
        print("按类别逐个播放所有 Segments")
        print("="*80)
        
        input("\n按回车键开始...")
        
        categories = [
            SegmentCategory.RHYTHM,
            SegmentCategory.BASS,
            SegmentCategory.HARMONY,
            SegmentCategory.MELODY,
            SegmentCategory.TEXTURE,
            SegmentCategory.FX,
            SegmentCategory.ATMOSPHERE
        ]
        
        for category in categories:
            self.showcase_by_category(category, duration=6.0)
            
            if category != categories[-1]:
                input(f"\n按回车键继续下一类别...")
        
        print("\n✨ 类型展示完成！")


def main():
    """主程序"""
    print("\n" + "="*80)
    print("Numus V03 - Segment 完整展示程序")
    print("="*80)
    print("\n选择展示模式:")
    print("  1. 完整音乐展示 (推荐) - 7个章节 + DJ过渡")
    print("  2. 类型分类展示 - 逐个播放所有Segment")
    print("  3. 两种模式都运行")
    
    choice = input("\n请选择 (1/2/3): ").strip()
    
    if choice == "1":
        showcase = SegmentShowcase()
        showcase.run_complete_showcase()
    
    elif choice == "2":
        showcase = SegmentTypeShowcase()
        showcase.run_type_showcase()
    
    elif choice == "3":
        print("\n运行模式1: 完整音乐展示")
        showcase1 = SegmentShowcase()
        showcase1.run_complete_showcase()
        
        input("\n\n按回车键继续运行模式2...")
        
        print("\n运行模式2: 类型分类展示")
        showcase2 = SegmentTypeShowcase()
        showcase2.run_type_showcase()
    
    else:
        print("无效选择")


if __name__ == "__main__":
    print("\n请确保:")
    print("  1. Sonic Pi 已启动")
    print("  2. sonic_universal_player.rb 已加载")
    print("  3. segments 文件夹包含所有 JSON 文件")
    
    input("\n按回车键继续...")
    
    main()