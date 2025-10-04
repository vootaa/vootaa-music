"""
Segment Library 完整测试
测试所有74个segments的加载和检索
"""

from SegmentLibraryManager import SegmentLibrary
from StandardSegment import SegmentCategory, SegmentSubType


def test_library_loading():
    """测试库加载"""
    print("\n" + "="*80)
    print("测试1: Segment库加载")
    print("="*80)
    
    library = SegmentLibrary("../segments")
    
    stats = library.get_statistics()
    print(f"\n总Segments数量: {stats['total_segments']}")
    print(f"\n按类别分布:")
    for cat, count in stats['by_category'].items():
        print(f"  {cat}: {count}")
    
    print(f"\n按子类型分布:")
    for subtype, count in sorted(stats['by_subtype'].items()):
        print(f"  {subtype}: {count}")
    
    print(f"\n按Section类型分布:")
    for section, count in sorted(stats['by_section'].items()):
        print(f"  {section}: {count}")
    
    print(f"\n按能量等级分布:")
    for level, count in stats['by_energy'].items():
        print(f"  {level}: {count}")
    
    return library


def test_search_by_category(library: SegmentLibrary):
    """测试按类别搜索"""
    print("\n" + "="*80)
    print("测试2: 按类别搜索")
    print("="*80)
    
    for category in SegmentCategory:
        results = library.search_by_category(category)
        print(f"\n{category.value}: {len(results)} 个")
        for seg in results[:3]:  # 显示前3个
            print(f"  - {seg.name} (ID: {seg.id})")


def test_search_by_section(library: SegmentLibrary):
    """测试按Section类型搜索"""
    print("\n" + "="*80)
    print("测试3: 按Section类型搜索")
    print("="*80)
    
    sections = ["intro", "build_up", "drop", "breakdown", "outro"]
    
    for section in sections:
        results = library.search_by_section(section)
        print(f"\n适用于 {section} 的Segments: {len(results)} 个")
        for seg in results[:5]:
            print(f"  - {seg.name} (能量: {seg.metadata.energy_level:.2f})")


def test_search_by_energy(library: SegmentLibrary):
    """测试按能量等级搜索"""
    print("\n" + "="*80)
    print("测试4: 按能量等级搜索")
    print("="*80)
    
    for energy_range in ["low", "medium", "high"]:
        results = library.search_by_energy(energy_range)
        print(f"\n{energy_range} 能量: {len(results)} 个")
        for seg in results[:3]:
            print(f"  - {seg.name} (能量: {seg.metadata.energy_level:.2f})")


def test_search_by_tags(library: SegmentLibrary):
    """测试按标签搜索"""
    print("\n" + "="*80)
    print("测试5: 按标签搜索")
    print("="*80)
    
    test_tags = [
        ["house", "deep_house"],
        ["kick", "foundation"],
        ["atmospheric", "spacey"],
        ["energetic", "powerful"]
    ]
    
    for tags in test_tags:
        results = library.search_by_tags(tags, match_all=False)
        print(f"\n标签 {tags}: {len(results)} 个")
        for seg in results[:3]:
            print(f"  - {seg.name}")


def test_advanced_search(library: SegmentLibrary):
    """测试高级搜索"""
    print("\n" + "="*80)
    print("测试6: 高级组合搜索")
    print("="*80)
    
    # 场景1: 为Drop Section找高能量的Kick
    print("\n场景1: Drop Section 的高能量 Kick")
    results = library.search_advanced(
        subtype=SegmentSubType.KICK_PATTERN,
        section_type="drop",
        min_energy=0.6
    )
    print(f"找到 {len(results)} 个")
    for seg in results:
        print(f"  - {seg.name} (能量: {seg.metadata.energy_level:.2f})")
    
    # 场景2: 为Intro找低能量的氛围层
    print("\n场景2: Intro Section 的低能量氛围层")
    results = library.search_advanced(
        category=SegmentCategory.ATMOSPHERE,
        section_type="intro",
        max_energy=0.4
    )
    print(f"找到 {len(results)} 个")
    for seg in results:
        print(f"  - {seg.name} (能量: {seg.metadata.energy_level:.2f})")
    
    # 场景3: 为Build-up找渐进式元素
    print("\n场景3: Build-up Section 的上升元素")
    results = library.search_advanced(
        section_type="build_up",
        tags=["rising", "building", "tension"],
        min_energy=0.4
    )
    print(f"找到 {len(results)} 个")
    for seg in results:
        print(f"  - {seg.name}")


def test_segment_details(library: SegmentLibrary):
    """测试Segment详细信息"""
    print("\n" + "="*80)
    print("测试7: Segment详细信息")
    print("="*80)
    
    # 随机选择几个segment查看详情
    sample_ids = [
        "RHY_kick_4floor__a3f8b2c1",
        "BASS_deep_sub__7d9e4a12",
        "MELO_lead_prog__5c2f8e90",
        "FX_riser_white__9a3f7c2e",
        "ATM_dawn_texture__5a8d3f2c"
    ]
    
    for seg_id in sample_ids:
        seg = library.get_segment(seg_id)
        if seg:
            print(f"\n{seg.name}")
            print(f"  ID: {seg.id}")
            print(f"  类别: {seg.category.value} / {seg.sub_type.value}")
            print(f"  时长: {seg.playback_params.duration_bars} bars")
            print(f"  能量: {seg.metadata.energy_level:.2f}")
            print(f"  适用Section: {', '.join(seg.metadata.suitable_sections)}")
            print(f"  标签: {', '.join(seg.metadata.mood_tags[:5])}")


def test_library_validation(library: SegmentLibrary):
    """测试库验证"""
    print("\n" + "="*80)
    print("测试8: 库完整性验证")
    print("="*80)
    
    issues = library.validate_library()
    
    print(f"\n缺少参数的Segments: {len(issues['missing_params'])}")
    if issues['missing_params']:
        for seg_id in issues['missing_params'][:5]:
            print(f"  - {seg_id}")
    
    print(f"\n能量值异常的Segments: {len(issues['invalid_energy'])}")
    if issues['invalid_energy']:
        for seg_id in issues['invalid_energy']:
            print(f"  - {seg_id}")
    
    print(f"\n缺少元数据的Segments: {len(issues['missing_metadata'])}")
    if issues['missing_metadata']:
        for seg_id in issues['missing_metadata'][:5]:
            print(f"  - {seg_id}")
    
    if not any(issues.values()):
        print("\n✅ 库验证通过！所有Segments格式正确。")


def test_all_tags(library: SegmentLibrary):
    """测试所有标签列表"""
    print("\n" + "="*80)
    print("测试9: 所有可用标签")
    print("="*80)
    
    all_tags = library.list_all_tags()
    print(f"\n总共 {len(all_tags)} 个标签:")
    
    # 分列显示
    for i in range(0, len(all_tags), 5):
        print("  " + ", ".join(all_tags[i:i+5]))


if __name__ == "__main__":
    # 运行所有测试
    library = test_library_loading()
    
    test_search_by_category(library)
    test_search_by_section(library)
    test_search_by_energy(library)
    test_search_by_tags(library)
    test_advanced_search(library)
    test_segment_details(library)
    test_library_validation(library)
    test_all_tags(library)
    
    print("\n" + "="*80)
    print("所有测试完成！")
    print("="*80)