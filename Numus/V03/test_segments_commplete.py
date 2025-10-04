"""
完整 Segment 展示程序
确保所有 Segments 都被播放并测试
"""

import time
from typing import List, Dict
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary
from StandardSegment import SegmentCategory, SegmentSubType


class CompleteSegmentShowcase:
    """完整 Segment 展示系统"""
    
    def __init__(self):
        self.player = SegmentPlayer()
        self.library = SegmentLibrary("../segments")
        self.bpm = 128
        self.tested_segments = set()  # 记录已测试的 Segment
        
        print("="*80)
        print("Numus V03 - 完整 Segment 展示")
        print("="*80)
        print(f"\n库中共有 {len(self.library.segments)} 个 Segments")
        
        # 显示统计信息
        stats = self.library.get_statistics()
        print(f"\n按类别分布:")
        for cat, count in stats['by_category'].items():
            print(f"  {cat}: {count}")
    
    def showcase_category_complete(self, 
                                   category: SegmentCategory,
                                   play_duration: float = 6.0,
                                   pause_between: float = 1.0):
        """
        完整展示某个类别的所有 Segments
        
        Args:
            category: Segment 类别
            play_duration: 每个 Segment 播放时长（秒）
            pause_between: Segment 间的间隔（秒）
        """
        segments = self.library.search_by_category(category)
        
        print(f"\n{'='*80}")
        print(f"类别: {category.value.upper()}")
        print(f"{'='*80}")
        print(f"共 {len(segments)} 个 Segments\n")
        
        for i, segment in enumerate(segments, 1):
            print(f"[{i}/{len(segments)}] {segment.name}")
            print(f"  ID: {segment.id}")
            print(f"  类型: {segment.sub_type.value}")
            print(f"  能量: {segment.metadata.energy_level:.2f}")
            
            # 显示适用 Section（最多3个）
            sections = segment.metadata.suitable_sections[:3]
            if sections:
                print(f"  适用: {', '.join(sections)}")
            
            # 显示标签（最多5个）
            tags = segment.metadata.element_tags[:5]
            if tags:
                print(f"  标签: {', '.join(tags)}")
            
            # 播放
            try:
                track_name = self.player.play_segment(
                    segment=segment,
                    track_id="complete_test",
                    chapter_id=category.value,
                    section_id=f"seg{i}",
                    override_params={"bpm": self.bpm}
                )
                
                # 记录已测试
                self.tested_segments.add(segment.id)
                
                # 播放指定时长
                time.sleep(play_duration)
                
                # 停止
                self.player.stop_segment(track_name)
                
                print(f"  ✅ 播放成功\n")
                
            except Exception as e:
                print(f"  ❌ 播放失败: {e}\n")
            
            # 间隔
            if i < len(segments):
                time.sleep(pause_between)
    
    def showcase_by_subtype_complete(self,
                                    subtype: SegmentSubType,
                                    play_duration: float = 8.0):
        """
        按子类型完整展示所有变体
        
        Args:
            subtype: Segment 子类型
            play_duration: 播放时长（秒）
        """
        segments = self.library.search_by_subtype(subtype)
        
        if not segments:
            print(f"⚠️  未找到类型 {subtype.value} 的 Segments")
            return
        
        print(f"\n{'='*60}")
        print(f"子类型: {subtype.value}")
        print(f"{'='*60}")
        print(f"共 {len(segments)} 个变体\n")
        
        for i, segment in enumerate(segments, 1):
            print(f"  [{i}] {segment.name}")
            
            try:
                track_name = self.player.play_segment(
                    segment=segment,
                    track_id="subtype_test",
                    chapter_id=subtype.value,
                    section_id=f"var{i}",
                    override_params={"bpm": self.bpm}
                )
                
                self.tested_segments.add(segment.id)
                
                time.sleep(play_duration)
                self.player.stop_segment(track_name)
                print(f"    ✅ 完成\n")
                
            except Exception as e:
                print(f"    ❌ 失败: {e}\n")
            
            time.sleep(0.5)
    
    def showcase_multi_layer(self,
                            segment_ids: List[str],
                            duration: float = 12.0,
                            title: str = "Multi-Layer Test"):
        """
        多层叠加测试
        
        Args:
            segment_ids: Segment ID 列表
            duration: 播放时长（秒）
            title: 测试标题
        """
        print(f"\n{'='*60}")
        print(f"🎵 {title}")
        print(f"{'='*60}")
        
        active_tracks = []
        
        for segment_id in segment_ids:
            segment = self.library.get_segment(segment_id)
            if not segment:
                print(f"⚠️  未找到 Segment: {segment_id}")
                continue
            
            try:
                track_name = self.player.play_segment(
                    segment=segment,
                    track_id="multi_layer",
                    chapter_id="test",
                    section_id=segment_id,
                    override_params={"bpm": self.bpm}
                )
                
                active_tracks.append(track_name)
                self.tested_segments.add(segment_id)
                print(f"  ✓ {segment.name}")
                time.sleep(0.5)  # 逐层加入
                
            except Exception as e:
                print(f"  ✗ {segment.name}: {e}")
        
        print(f"\n播放 {duration} 秒...")
        time.sleep(duration)
        
        # 停止所有
        for track in active_tracks:
            self.player.stop_segment(track)
    
    def run_complete_showcase(self):
        """运行完整展示流程"""
        print("\n" + "="*80)
        print("开始完整 Segment 展示")
        print("将按类别播放所有 Segments")
        print("="*80)
        
        input("\n按回车键开始...\n")
        
        # 按类别完整展示
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
            self.showcase_category_complete(category, play_duration=6.0)
            
            if category != categories[-1]:
                print("\n" + "-"*80)
                input("按回车键继续下一类别...")
        
        # 生成测试报告
        self.generate_test_report()
    
    def generate_test_report(self):
        """生成详细的测试报告"""
        print("\n" + "="*80)
        print("测试报告")
        print("="*80)
        
        all_segment_ids = set(self.library.segments.keys())
        tested_count = len(self.tested_segments)
        total_count = len(all_segment_ids)
        
        print(f"\n✅ 已测试: {tested_count}/{total_count} 个 Segments")
        print(f"   覆盖率: {tested_count/total_count*100:.1f}%")
        
        # 检查未测试的
        untested = all_segment_ids - self.tested_segments
        if untested:
            print(f"\n⚠️  未测试的 Segments ({len(untested)} 个):")
            for seg_id in sorted(untested):
                segment = self.library.get_segment(seg_id)
                if segment:
                    print(f"  - {seg_id}: {segment.name}")
        else:
            print("\n🎉 所有 Segments 已完整测试！")
        
        # 按类别统计
        print(f"\n按类别测试统计:")
        for category in SegmentCategory:
            cat_segments = self.library.search_by_category(category)
            cat_ids = {s.id for s in cat_segments}
            tested_in_cat = cat_ids & self.tested_segments
            print(f"  {category.value}: {len(tested_in_cat)}/{len(cat_ids)}")
        
        # 验证库完整性
        print(f"\n库完整性验证:")
        issues = self.library.validate_library()
        total_issues = sum(len(v) for v in issues.values())
        
        if total_issues == 0:
            print("  ✅ 未发现问题")
        else:
            print(f"  ⚠️  发现 {total_issues} 个问题:")
            for issue_type, seg_ids in issues.items():
                if seg_ids:
                    print(f"    - {issue_type}: {len(seg_ids)} 个")


class MixedLayerShowcase:
    """混合层叠展示 - 按能量等级和标签组合"""
    
    def __init__(self):
        self.player = SegmentPlayer()
        self.library = SegmentLibrary("./segments")
        self.bpm = 128
    
    def create_mix_from_energy(self, energy_level: str, duration: float = 16.0):
        """
        根据能量等级创建混音
        
        Args:
            energy_level: "low", "medium", "high"
            duration: 播放时长
        """
        segments = self.library.search_by_energy(energy_level)
        
        print(f"\n{'='*60}")
        print(f"🎚️  能量等级: {energy_level.upper()}")
        print(f"{'='*60}")
        print(f"从 {len(segments)} 个 Segments 中选择混音\n")
        
        # 按类别分组
        by_category = {}
        for seg in segments:
            cat = seg.category.value
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(seg)
        
        # 每个类别选一个
        active_tracks = []
        for cat, segs in by_category.items():
            if segs:
                seg = segs[0]  # 选第一个
                print(f"  [{cat}] {seg.name}")
                
                try:
                    track_name = self.player.play_segment(
                        segment=seg,
                        track_id="energy_mix",
                        chapter_id=energy_level,
                        section_id=cat,
                        override_params={"bpm": self.bpm}
                    )
                    active_tracks.append(track_name)
                    time.sleep(0.5)
                except Exception as e:
                    print(f"    ✗ 播放失败: {e}")
        
        print(f"\n🎵 播放 {duration} 秒...")
        time.sleep(duration)
        
        for track in active_tracks:
            self.player.stop_segment(track)
    
    def create_mix_from_section(self, section_type: str, duration: float = 16.0):
        """
        根据 Section 类型创建混音
        
        Args:
            section_type: "intro", "build_up", "drop", "breakdown", "outro"
            duration: 播放时长
        """
        segments = self.library.search_by_section(section_type)
        
        print(f"\n{'='*60}")
        print(f"🎬 Section 类型: {section_type.upper()}")
        print(f"{'='*60}")
        print(f"从 {len(segments)} 个适合的 Segments 中选择\n")
        
        # 按类别选择多样性
        selected = {}
        for seg in segments:
            cat = seg.category.value
            if cat not in selected:
                selected[cat] = seg
        
        active_tracks = []
        for cat, seg in selected.items():
            print(f"  [{cat}] {seg.name}")
            
            try:
                track_name = self.player.play_segment(
                    segment=seg,
                    track_id="section_mix",
                    chapter_id=section_type,
                    section_id=cat,
                    override_params={"bpm": self.bpm}
                )
                active_tracks.append(track_name)
                time.sleep(0.5)
            except Exception as e:
                print(f"    ✗ 播放失败: {e}")
        
        print(f"\n🎵 播放 {duration} 秒...")
        time.sleep(duration)
        
        for track in active_tracks:
            self.player.stop_segment(track)
    
    def showcase_energy_progression(self):
        """展示能量递进 - Low -> Medium -> High"""
        print("\n" + "="*80)
        print("🎢 能量递进展示")
        print("="*80)
        
        input("\n按回车键开始...\n")
        
        # Low -> Medium -> High
        self.create_mix_from_energy("low", duration=12.0)
        time.sleep(2)
        
        self.create_mix_from_energy("medium", duration=12.0)
        time.sleep(2)
        
        self.create_mix_from_energy("high", duration=16.0)
        
        print("\n✨ 能量递进展示完成！")
    
    def showcase_section_journey(self):
        """展示完整的 Section 旅程"""
        print("\n" + "="*80)
        print("🎭 完整 Section 旅程展示")
        print("="*80)
        
        input("\n按回车键开始...\n")
        
        sections = ["intro", "build_up", "drop", "breakdown", "outro"]
        
        for section in sections:
            self.create_mix_from_section(section, duration=12.0)
            time.sleep(2)
        
        print("\n✨ Section 旅程展示完成！")


class QuickDemo:
    """快速演示 - 展示每个类别的典型 Segment"""
    
    def __init__(self):
        self.player = SegmentPlayer()
        self.library = SegmentLibrary("./segments")
        self.bpm = 128
    
    def run_quick_demo(self):
        """运行快速演示"""
        print("\n" + "="*80)
        print("⚡ 快速演示 - 每个类别1个代表")
        print("="*80)
        
        input("\n按回车键开始...\n")
        
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
            segments = self.library.search_by_category(category)
            if not segments:
                continue
            
            # 选择第一个作为代表
            segment = segments[0]
            
            print(f"\n{'='*60}")
            print(f"类别: {category.value}")
            print(f"代表: {segment.name}")
            print(f"{'='*60}")
            
            try:
                track_name = self.player.play_segment(
                    segment=segment,
                    track_id="quick_demo",
                    chapter_id=category.value,
                    section_id="demo",
                    override_params={"bpm": self.bpm}
                )
                
                time.sleep(6.0)
                self.player.stop_segment(track_name)
                print("✅ 完成")
                time.sleep(1.0)
                
            except Exception as e:
                print(f"❌ 失败: {e}")
        
        print("\n✨ 快速演示完成！")


def main():
    """主程序"""
    print("\n" + "="*80)
    print("Numus V03 - Segment 完整测试程序")
    print("="*80)
    print("\n选择测试模式:")
    print("  1. ⚡ 快速演示 (每类1个, ~1分钟)")
    print("  2. 🎢 能量递进展示 (~1分钟)")
    print("  3. 🎭 Section 旅程展示 (~1.5分钟)")
    print("  4. 📋 完整展示 (所有Segments, ~10-15分钟)")
    print("  5. 🎨 组合展示 (模式1+2+3)")
    
    choice = input("\n请选择 (1/2/3/4/5): ").strip()
    
    if choice == "1":
        demo = QuickDemo()
        demo.run_quick_demo()
    
    elif choice == "2":
        showcase = MixedLayerShowcase()
        showcase.showcase_energy_progression()
    
    elif choice == "3":
        showcase = MixedLayerShowcase()
        showcase.showcase_section_journey()
    
    elif choice == "4":
        showcase = CompleteSegmentShowcase()
        showcase.run_complete_showcase()
    
    elif choice == "5":
        print("\n=== 阶段 1: 快速演示 ===")
        demo = QuickDemo()
        demo.run_quick_demo()
        
        input("\n\n按回车键继续阶段 2...")
        
        print("\n=== 阶段 2: 能量递进展示 ===")
        showcase1 = MixedLayerShowcase()
        showcase1.showcase_energy_progression()
        
        input("\n\n按回车键继续阶段 3...")
        
        print("\n=== 阶段 3: Section 旅程展示 ===")
        showcase2 = MixedLayerShowcase()
        showcase2.showcase_section_journey()
        
        print("\n\n🎉 组合展示完成！")
    
    else:
        print("❌ 无效选择")


if __name__ == "__main__":
    print("\n✅ 请确保:")
    print("  1. Sonic Pi 已启动")
    print("  2. sonic_universal_player.rb 已加载到 Sonic Pi")
    print("  3. segments 文件夹包含 7 个 JSON 文件")
    
    input("\n按回车键继续...")
    
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏸️  用户中断")
    except Exception as e:
        print(f"\n\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()