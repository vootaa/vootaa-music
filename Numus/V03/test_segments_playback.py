"""
Segments播放测试
逐个测试所有segment类型的播放
"""

import time
from SegmentPlayer import SegmentPlayer
from SegmentLibraryManager import SegmentLibrary
from StandardSegment import SegmentSubType


def test_rhythm_segments(player: SegmentPlayer, library: SegmentLibrary):
    """测试节奏类Segments"""
    print("\n" + "="*80)
    print("测试节奏类Segments")
    print("="*80)
    
    # 测试Kick
    print("\n1. 测试Kick Patterns")
    kicks = library.search_by_subtype(SegmentSubType.KICK_PATTERN)
    if kicks:
        seg = kicks[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "rhythm", "kick")
        time.sleep(8)
        player.stop_segment(track)
    
    # 测试Snare
    print("\n2. 测试Snare Patterns")
    snares = library.search_by_subtype(SegmentSubType.SNARE_PATTERN)
    if snares:
        seg = snares[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "rhythm", "snare")
        time.sleep(8)
        player.stop_segment(track)
    
    # 测试Hi-Hat
    print("\n3. 测试Hi-Hat Patterns")
    hihats = library.search_by_subtype(SegmentSubType.HIHAT_PATTERN)
    if hihats:
        seg = hihats[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "rhythm", "hihat")
        time.sleep(8)
        player.stop_segment(track)
    
    # 测试完整鼓组
    print("\n4. 测试完整鼓组 (Kick + Snare + HiHat)")
    tracks = []
    if kicks:
        tracks.append(player.play_segment(kicks[0], "test", "rhythm", "full1"))
    if snares:
        tracks.append(player.play_segment(snares[0], "test", "rhythm", "full2"))
    if hihats:
        tracks.append(player.play_segment(hihats[0], "test", "rhythm", "full3"))
    
    time.sleep(16)
    for track in tracks:
        player.stop_segment(track)


def test_bass_segments(player: SegmentPlayer, library: SegmentLibrary):
    """测试低音类Segments"""
    print("\n" + "="*80)
    print("测试低音类Segments")
    print("="*80)
    
    # 测试Sub Bass
    print("\n1. 测试Sub Bass")
    subs = library.search_by_subtype(SegmentSubType.SUB_BASS)
    if subs:
        seg = subs[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "bass", "sub")
        time.sleep(8)
        player.stop_segment(track)
    
    # 测试Bass Line
    print("\n2. 测试Bass Line")
    basslines = library.search_by_subtype(SegmentSubType.BASS_LINE)
    if basslines:
        seg = basslines[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "bass", "line")
        time.sleep(8)
        player.stop_segment(track)


def test_melody_segments(player: SegmentPlayer, library: SegmentLibrary):
    """测试旋律类Segments"""
    print("\n" + "="*80)
    print("测试旋律类Segments")
    print("="*80)
    
    # 测试Lead Melody
    print("\n1. 测试Lead Melody")
    leads = library.search_by_subtype(SegmentSubType.LEAD_MELODY)
    if leads:
        seg = leads[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "melody", "lead")
        time.sleep(8)
        player.stop_segment(track)
    
    # 测试Arpeggio
    print("\n2. 测试Arpeggio")
    arps = library.search_by_subtype(SegmentSubType.ARPEGGIO)
    if arps:
        seg = arps[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "melody", "arp")
        time.sleep(8)
        player.stop_segment(track)


def test_harmony_segments(player: SegmentPlayer, library: SegmentLibrary):
    """测试和声类Segments"""
    print("\n" + "="*80)
    print("测试和声类Segments")
    print("="*80)
    
    # 测试Pad
    print("\n1. 测试Pad")
    pads = library.search_by_subtype(SegmentSubType.PAD)
    if pads:
        seg = pads[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "harmony", "pad")
        time.sleep(12)
        player.stop_segment(track)
    
    # 测试Chord Progression
    print("\n2. 测试Chord Progression")
    chords = library.search_by_subtype(SegmentSubType.CHORD_PROGRESSION)
    if chords:
        seg = chords[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "harmony", "chord")
        time.sleep(8)
        player.stop_segment(track)


def test_fx_segments(player: SegmentPlayer, library: SegmentLibrary):
    """测试特效类Segments"""
    print("\n" + "="*80)
    print("测试特效类Segments")
    print("="*80)
    
    # 测试Riser
    print("\n1. 测试Riser")
    risers = library.search_by_subtype(SegmentSubType.RISER)
    if risers:
        seg = risers[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "fx", "riser")
        time.sleep(10)
        player.stop_segment(track)
    
    # 测试Impact
    print("\n2. 测试Impact")
    impacts = library.search_by_subtype(SegmentSubType.IMPACT)
    if impacts:
        seg = impacts[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "fx", "impact")
        time.sleep(2)
        player.stop_segment(track)


def test_atmosphere_segments(player: SegmentPlayer, library: SegmentLibrary):
    """测试氛围类Segments"""
    print("\n" + "="*80)
    print("测试氛围类Segments")
    print("="*80)
    
    ambients = library.search_by_subtype(SegmentSubType.AMBIENT_LAYER)
    if ambients:
        seg = ambients[0]
        print(f"播放: {seg.name}")
        track = player.play_segment(seg, "test", "atm", "ambient")
        time.sleep(12)
        player.stop_segment(track)


def test_full_mix(player: SegmentPlayer, library: SegmentLibrary):
    """测试完整混音"""
    print("\n" + "="*80)
    print("测试完整混音 (多层Segments同时播放)")
    print("="*80)
    
    tracks = []
    
    # Kick
    kicks = library.search_by_subtype(SegmentSubType.KICK_PATTERN)
    if kicks:
        print("添加 Kick")
        tracks.append(player.play_segment(kicks[0], "test", "mix", "kick"))
    
    time.sleep(4)
    
    # Bass
    basslines = library.search_by_subtype(SegmentSubType.BASS_LINE)
    if basslines:
        print("添加 Bass")
        tracks.append(player.play_segment(basslines[0], "test", "mix", "bass"))
    
    time.sleep(4)
    
    # Hi-Hat
    hihats = library.search_by_subtype(SegmentSubType.HIHAT_PATTERN)
    if hihats:
        print("添加 Hi-Hat")
        tracks.append(player.play_segment(hihats[0], "test", "mix", "hihat"))
    
    time.sleep(4)
    
    # Pad
    pads = library.search_by_subtype(SegmentSubType.PAD)
    if pads:
        print("添加 Pad")
        tracks.append(player.play_segment(pads[0], "test", "mix", "pad"))
    
    time.sleep(4)
    
    # Lead
    leads = library.search_by_subtype(SegmentSubType.LEAD_MELODY)
    if leads:
        print("添加 Lead")
        tracks.append(player.play_segment(leads[0], "test", "mix", "lead"))
    
    print("\n完整混音播放中...")
    time.sleep(16)
    
    # 停止所有
    for track in tracks:
        player.stop_segment(track)
    
    print("混音结束")


if __name__ == "__main__":
    print("="*80)
    print("Numus V03 Segments 播放测试")
    print("请确保 Sonic Pi 已启动并加载 sonic_universal_player.rb")
    print("="*80)
    
    input("\n按回车键开始测试...")
    
    # 初始化
    player = SegmentPlayer()
    library = SegmentLibrary("./segments")
    
    # 依次测试各类型
    test_rhythm_segments(player, library)
    test_bass_segments(player, library)
    test_melody_segments(player, library)
    test_harmony_segments(player, library)
    test_fx_segments(player, library)
    test_atmosphere_segments(player, library)
    
    # 最后测试完整混音
    input("\n按回车键测试完整混音...")
    test_full_mix(player, library)
    
    print("\n" + "="*80)
    print("所有播放测试完成！")
    print("="*80)