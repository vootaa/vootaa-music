"""
批量提取2022文件夹中的高质量Segment素材
重点：Deep House、Samba节奏、宇宙主题、高能量元素
"""

from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


def extract_deep_house_vocal_layer():
    """提取Deep House人声层 - 来自2022-11-20_vox_deephouse.rb"""
    
    code = """use_bpm 124
use_synth :tb303

live_loop :vocal_layer do
  with_fx :reverb, room: 0.8, mix: 0.7 do
    with_fx :echo, phase: 0.75, decay: 6 do
      with_fx :pitch_shift, pitch: 12 do
        sample :ambi_choir, amp: 0.3, rate: 0.5, cutoff: 90
        sleep 16
      end
    end
  end
end"""

    return StandardSegment(
        id="deep_house_vocal_layer_01",
        name="Deep House Vocal Layer",
        category=SegmentCategory.ATMOSPHERE,
        sub_type=SegmentSubType.AMBIENT_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="vocal_layer",
            setup_code="use_bpm 124"
        ),
        musical_params=MusicalParameters(
            sample=":ambi_choir",
            amp_range=(0.2, 0.4),
            effects={
                "reverb": {"room": 0.8, "mix": 0.7},
                "echo": {"phase": 0.75, "decay": 6},
                "pitch_shift": {"pitch": 12},
                "cutoff": 90
            },
            duration_bars=16,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2022-11-20_vox_deephouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "vocal_house", "soulful"],
            mood_tags=["ethereal", "emotional", "atmospheric"],
            element_tags=["vocal", "choir", "atmospheric", "background"],
            suitable_sections=["breakdown", "intro", "ambient_section"],
            energy_level=0.4,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.2,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"pitch_shift_range": (7, 19)},
            {"rate_range": (0.4, 0.7)}
        ]
    )


def extract_samba_percussion():
    """提取Samba打击乐 - 优化自2022-09-18_samba.rb"""
    
    code = """use_bpm 132

live_loop :samba_perc do
  sample :drum_tom_mid_soft, amp: 0.6
  sleep 0.5
  sample :drum_tom_lo_soft, amp: 0.5
  sleep 0.25
  sample :drum_tom_hi_soft, amp: 0.4
  sleep 0.25
  sample :drum_tom_mid_soft, amp: 0.5
  sleep 0.5
  sample :perc_bell, amp: 0.3, rate: 1.5
  sleep 0.5
end"""

    return StandardSegment(
        id="samba_percussion_pattern_01",
        name="Samba Percussion Pattern",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.PERCUSSION_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="samba_perc",
            setup_code="use_bpm 132"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 1, 1, 0, 1, 0],
            subdivisions=8,
            sample=":drum_tom_mid_soft, :drum_tom_lo_soft, :drum_tom_hi_soft, :perc_bell",
            amp_range=(0.3, 0.6),
            duration_bars=2,
            bpm=132
        ),
        metadata=SegmentMetadata(
            source_file="2022-09-18_samba.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["samba", "latin", "brazilian", "world"],
            mood_tags=["energetic", "festive", "rhythmic", "joyful"],
            element_tags=["percussion", "latin", "polyrhythm"],
            suitable_sections=["verse", "drop", "peak"],
            energy_level=0.8,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.3,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"tempo_range": (120, 140)},
            {"accent_variations": True}
        ]
    )


def extract_jazz_house_piano():
    """提取Jazz House钢琴 - 来自2022-04-29_jazz_house.rb"""
    
    code = """use_bpm 122
use_synth :piano

live_loop :jazz_piano do
  with_fx :reverb, room: 0.6, mix: 0.5 do
    play_pattern_timed [:c4, :e4, :g4, :b4, :d5, :c5], [0.5, 0.25, 0.25, 0.5, 0.25, 0.25],
                       amp: 0.5, release: 0.3
    sleep 0.5
  end
end"""

    return StandardSegment(
        id="jazz_house_piano_01",
        name="Jazz House Piano",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ORNAMENT,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="jazz_piano",
            setup_code="use_bpm 122\nuse_synth :piano"
        ),
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "B4", "D5", "C5"],
            scale="C_major",
            root_note="C4",
            synth=":piano",
            amp_range=(0.4, 0.6),
            effects={"reverb": {"room": 0.6, "mix": 0.5}},
            duration_bars=2,
            bpm=122
        ),
        metadata=SegmentMetadata(
            source_file="2022-04-29_jazz_house.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["jazz_house", "house", "jazz", "fusion"],
            mood_tags=["sophisticated", "smooth", "groovy"],
            element_tags=["piano", "melodic", "jazzy", "ornament"],
            suitable_sections=["verse", "breakdown", "interlude"],
            energy_level=0.6,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.3,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"swing": 0.1},
            {"chord_voicing": "jazz"}
        ]
    )


def extract_skydiving_riser():
    """提取跳伞上升音效 - 来自2022-09-29_SKYDIVING_1.rb"""
    
    code = """use_bpm 140

live_loop :skydive_riser do
  with_fx :reverb, room: 0.9 do
    with_fx :hpf, cutoff_slide: 8 do |fx|
      sample :ambi_drone, amp: 0.5, rate: 2
      control fx, cutoff: 20, cutoff_slide: 8
      control fx, cutoff: 130
      sleep 8
    end
  end
end"""

    return StandardSegment(
        id="skydiving_riser_01",
        name="Skydiving Riser FX",
        category=SegmentCategory.FX,
        sub_type=SegmentSubType.RISER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="skydive_riser",
            setup_code="use_bpm 140"
        ),
        musical_params=MusicalParameters(
            sample=":ambi_drone",
            amp_range=(0.4, 0.6),
            effects={
                "reverb": {"room": 0.9},
                "hpf": {"cutoff_start": 20, "cutoff_end": 130, "slide": 8}
            },
            duration_bars=8,
            bpm=140
        ),
        metadata=SegmentMetadata(
            source_file="2022-09-29_SKYDIVING_1.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["edm", "progressive", "big_room"],
            mood_tags=["intense", "rising", "dramatic", "tension"],
            element_tags=["riser", "fx", "build", "tension"],
            suitable_sections=["build_up"],
            energy_level=0.9,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.1,
                "high": 1.4
            }
        ),
        math_adaptable=True,
        variations=[
            {"rate_range": (1.5, 3.0)},
            {"slide_duration_range": (4, 16)}
        ]
    )


def extract_cosmic_pad():
    """提取宇宙Pad - 来自2022-11-24_Cosmic Music.rb"""
    
    code = """use_bpm 128
use_synth :hollow

live_loop :cosmic_pad do
  with_fx :reverb, room: 1.0, mix: 0.8 do
    with_fx :echo, phase: 1.5, decay: 8 do
      play_chord [:c3, :e3, :g3, :b3], amp: 0.4, attack: 4, sustain: 8, release: 4
      sleep 16
      play_chord [:f3, :a3, :c4, :e4], amp: 0.35, attack: 4, sustain: 8, release: 4
      sleep 16
    end
  end
end"""

    return StandardSegment(
        id="cosmic_music_pad_01",
        name="Cosmic Music Pad",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.PAD,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cosmic_pad",
            setup_code="use_bpm 128\nuse_synth :hollow"
        ),
        musical_params=MusicalParameters(
            notes=["C3", "E3", "G3", "B3", "F3", "A3", "C4", "E4"],
            scale="C_major",
            root_note="C3",
            synth=":hollow",
            amp_range=(0.35, 0.4),
            effects={
                "reverb": {"room": 1.0, "mix": 0.8},
                "echo": {"phase": 1.5, "decay": 8}
            },
            duration_bars=32,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="2022-11-24_Cosmic Music.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "space", "cosmic", "atmospheric"],
            mood_tags=["spacious", "ethereal", "contemplative"],
            element_tags=["pad", "harmonic", "sustained", "spacey"],
            suitable_sections=["intro", "breakdown", "ambient_section"],
            energy_level=0.3,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.1,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"echo_phase_range": (1.0, 2.0)},
            {"reverb_room_range": (0.8, 1.0)}
        ]
    )


def extract_fashion_show_bass():
    """提取时尚秀Bass - 来自2022-06-07_fashion_show.rb"""
    
    code = """use_bpm 128
use_synth :fm

live_loop :fashion_bass do
  play :c2, amp: 1.0, release: 0.8, divisor: 2, depth: 3
  sleep 1
  play :c2, amp: 0.7, release: 0.4, divisor: 2, depth: 3
  sleep 0.5
  play :f1, amp: 0.8, release: 0.4, divisor: 2, depth: 3
  sleep 0.5
end"""

    return StandardSegment(
        id="fashion_show_bass_01",
        name="Fashion Show FM Bass",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.BASS_LINE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="fashion_bass",
            setup_code="use_bpm 128\nuse_synth :fm"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "F1"],
            root_note="C2",
            pattern=[1, 0, 1, 1],
            synth=":fm",
            amp_range=(0.7, 1.0),
            effects={"divisor": 2, "depth": 3},
            duration_bars=2,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="2022-06-07_fashion_show.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["fashion", "tech_house", "minimal"],
            mood_tags=["stylish", "modern", "sophisticated"],
            element_tags=["bass", "fm", "groovy", "foundation"],
            suitable_sections=["verse", "drop", "groove"],
            energy_level=0.7,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 1.3,
                "mid": 1.0,
                "high": 0.9
            }
        ),
        math_adaptable=True,
        variations=[
            {"divisor_range": (1, 4)},
            {"depth_range": (2, 5)}
        ]
    )


def extract_bossa_nova_rhythm():
    """提取Bossa Nova节奏 - 来自2022-09-11_bossa_nova.rb"""
    
    code = """use_bpm 120

live_loop :bossa_rhythm do
  sample :drum_snare_soft, amp: 0.4
  sleep 0.5
  sample :drum_cymbal_closed, amp: 0.2
  sleep 0.25
  sample :drum_cymbal_closed, amp: 0.15
  sleep 0.25
  sample :drum_snare_soft, amp: 0.3
  sleep 0.5
  sample :drum_cymbal_closed, amp: 0.2
  sleep 0.5
end"""

    return StandardSegment(
        id="bossa_nova_rhythm_01",
        name="Bossa Nova Rhythm",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.PERCUSSION_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="bossa_rhythm",
            setup_code="use_bpm 120"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 1, 1, 0, 1, 0],
            subdivisions=8,
            sample=":drum_snare_soft, :drum_cymbal_closed",
            amp_range=(0.15, 0.4),
            duration_bars=2,
            bpm=120
        ),
        metadata=SegmentMetadata(
            source_file="2022-09-11_bossa_nova.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["bossa_nova", "jazz", "latin", "brazilian"],
            mood_tags=["relaxed", "smooth", "elegant", "warm"],
            element_tags=["rhythm", "jazz", "gentle", "sophisticated"],
            suitable_sections=["verse", "breakdown", "chill_section"],
            energy_level=0.4,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.1,
                "high": 1.2
            }
        ),
        math_adaptable=True
    )


def extract_edm_synth_lead():
    """提取EDM合成器主音 - 来自2022-05-07_edm.rb"""
    
    code = """use_bpm 128
use_synth :blade

live_loop :edm_lead do
  with_fx :slicer, phase: 0.125, wave: 1 do
    with_fx :reverb, room: 0.5 do
      play_pattern_timed [:c5, :e5, :g5, :a5, :g5, :e5], [0.25]*6,
                         amp: 0.6, release: 0.2, cutoff: 110
    end
  end
end"""

    return StandardSegment(
        id="edm_synth_lead_blade_01",
        name="EDM Blade Lead",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.LEAD_MELODY,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="edm_lead",
            setup_code="use_bpm 128\nuse_synth :blade"
        ),
        musical_params=MusicalParameters(
            notes=["C5", "E5", "G5", "A5"],
            scale="C_major",
            root_note="C5",
            synth=":blade",
            amp_range=(0.5, 0.7),
            effects={
                "slicer": {"phase": 0.125, "wave": 1},
                "reverb": {"room": 0.5},
                "cutoff": 110
            },
            duration_bars=2,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="2022-05-07_edm.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["edm", "electro", "progressive"],
            mood_tags=["energetic", "bright", "powerful"],
            element_tags=["lead", "synth", "sliced", "melodic"],
            suitable_sections=["drop", "chorus", "peak"],
            energy_level=0.85,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.3,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"slicer_phase_range": (0.0625, 0.25)},
            {"cutoff_range": (90, 130)}
        ]
    )


def extract_modern_night_house_kick():
    """提取现代夜间House Kick - 来自2022-06-17_house_modern_night.rb"""
    
    code = """use_bpm 124

live_loop :night_kick do
  sample :bd_tek, amp: 1.3, cutoff: 85
  sleep 1
end"""

    return StandardSegment(
        id="modern_night_house_kick_01",
        name="Modern Night House Kick",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.KICK_PATTERN,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="night_kick",
            setup_code="use_bpm 124"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
            subdivisions=16,
            sample=":bd_tek",
            amp_range=(1.2, 1.4),
            effects={"cutoff": 85},
            duration_bars=4,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2022-06-17_house_modern_night.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["house", "tech_house", "modern"],
            mood_tags=["driving", "tight", "powerful"],
            element_tags=["kick", "four_on_floor", "foundation"],
            suitable_sections=["verse", "drop", "peak"],
            energy_level=0.75,
            complexity=0.2,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 0.9,
                "high": 0.8
            }
        ),
        math_adaptable=True
    )


def extract_chaos_glitch():
    """提取混沌故障音效 - 来自2022-03-29_chaos.rb"""
    
    code = """use_bpm 160

live_loop :chaos_glitch do
  with_fx :bitcrusher, bits: rrand_i(4, 8), mix: 0.6 do
    sample :glitch_perc, amp: 0.5, rate: rrand(0.5, 2.0)
    sleep [0.125, 0.25, 0.5].choose
  end
end"""

    return StandardSegment(
        id="chaos_glitch_fx_01",
        name="Chaos Glitch FX",
        category=SegmentCategory.FX,
        sub_type=SegmentSubType.TRANSITION,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="chaos_glitch",
            setup_code="use_bpm 160"
        ),
        musical_params=MusicalParameters(
            sample=":glitch_perc",
            amp_range=(0.4, 0.6),
            effects={
                "bitcrusher": {"bits_range": (4, 8), "mix": 0.6},
                "rate_range": (0.5, 2.0)
            },
            duration_bars=2,
            bpm=160
        ),
        metadata=SegmentMetadata(
            source_file="2022-03-29_chaos.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["glitch", "experimental", "idm"],
            mood_tags=["chaotic", "intense", "unpredictable"],
            element_tags=["glitch", "fx", "texture", "lo-fi"],
            suitable_sections=["transition", "breakdown", "drop"],
            energy_level=0.7,
            complexity=0.8,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"bits_fixed": [4, 6, 8]},
            {"timing_pattern": "mathematical"}
        ]
    )


# 主函数：批量生成并保存
def generate_all_segments_2022():
    """生成2022文件夹的所有Segment并保存"""
    
    segments = [
        extract_deep_house_vocal_layer(),
        extract_samba_percussion(),
        extract_jazz_house_piano(),
        extract_skydiving_riser(),
        extract_cosmic_pad(),
        extract_fashion_show_bass(),
        extract_bossa_nova_rhythm(),
        extract_edm_synth_lead(),
        extract_modern_night_house_kick(),
        extract_chaos_glitch()
    ]
    
    # 保存到对应分类文件夹
    base_path = "../segments"
    
    # 检查ID唯一性
    ids = [s.id for s in segments]
    if len(ids) != len(set(ids)):
        print("⚠️  警告：存在重复的Segment ID！")
        duplicates = [id for id in ids if ids.count(id) > 1]
        print(f"重复ID: {set(duplicates)}")
        return []
    
    saved_count = 0
    for segment in segments:
        category_path = f"{base_path}/{segment.category.value}"
        os.makedirs(category_path, exist_ok=True)
        
        filepath = f"{category_path}/{segment.id}.json"
        
        # 检查文件是否存在
        if os.path.exists(filepath):
            print(f"⚠️  文件已存在: {filepath}")
            continue
        
        segment.save_to_file(filepath)
        print(f"✓ 已生成: {segment.name} -> {filepath}")
        saved_count += 1
    
    print(f"\n总计生成 {saved_count}/{len(segments)} 个高质量Segment素材")
    
    # 生成统计报告
    category_count = {}
    for segment in segments:
        cat = segment.category.value
        category_count[cat] = category_count.get(cat, 0) + 1
    
    print("\n分类统计:")
    for cat, count in sorted(category_count.items()):
        print(f"  {cat}: {count} 个")
    
    # 显示能量等级分布
    energy_levels = [s.metadata.energy_level for s in segments]
    print(f"\n能量等级范围: {min(energy_levels):.1f} - {max(energy_levels):.1f}")
    print(f"平均能量等级: {sum(energy_levels)/len(energy_levels):.2f}")
    
    return segments


if __name__ == "__main__":
    segments = generate_all_segments_2022()