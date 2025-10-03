"""
批量提取2021文件夹中的高质量Segment素材
重点：Deep House、氛围音乐、宇宙主题
"""

from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


def extract_deep_house_kick_bass():
    """提取Deep House经典Kick+Bass组合 - 来自2021-10-31_deephouse_1.rb"""
    
    code = """use_bpm 124

live_loop :deep_kick do
  sample :bd_haus, amp: 1.5, cutoff: 90
  sleep 1
end

live_loop :deep_bass do
  sync :deep_kick
  use_synth :fm
  play :c2, amp: 0.8, release: 0.8, divisor: 1, depth: 2
  sleep 1
  play :c2, amp: 0.6, release: 0.4, divisor: 1, depth: 2
  sleep 0.5
  play :g1, amp: 0.7, release: 0.4, divisor: 1, depth: 2
  sleep 0.5
end"""

    return StandardSegment(
        id="deep_house_kick_bass_combo_01",
        name="Deep House Kick+Bass Combo",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.FULL_DRUM_KIT,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="deep_kick",
            dependencies=["deep_bass"],
            setup_code="use_bpm 124"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "G1"],
            root_note="C2",
            pattern=[1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
            subdivisions=16,
            synth=":fm",
            sample=":bd_haus",
            amp_range=(0.6, 1.5),
            effects={"cutoff": 90, "divisor": 1, "depth": 2},
            duration_bars=2,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2021-10-31_deephouse_1.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "house", "minimal"],
            mood_tags=["groovy", "deep", "foundation"],
            element_tags=["kick", "bass", "foundation", "synced"],
            suitable_sections=["verse", "drop", "peak"],
            energy_level=0.7,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 1.0,
                "high": 0.8
            }
        ),
        math_adaptable=True,
        variations=[
            {"bass_divisor_range": (0.5, 2.0)},
            {"bass_depth_range": (1, 4)}
        ]
    )


def extract_darkness_ambient_pad():
    """提取黑暗氛围Pad - 来自2021-10-27_darkness_bed.rb"""
    
    code = """use_bpm 90
use_synth :dark_ambience

live_loop :darkness_pad do
  with_fx :reverb, room: 0.9, mix: 0.8 do
    with_fx :hpf, cutoff: 50 do
      with_fx :bitcrusher, bits: 6, mix: 0.3 do
        play :c2, amp: 0.5, attack: 6, sustain: 12, release: 6
        sleep 24
      end
    end
  end
end"""

    return StandardSegment(
        id="darkness_ambient_pad_01",
        name="Darkness Ambient Pad",
        category=SegmentCategory.ATMOSPHERE,
        sub_type=SegmentSubType.AMBIENT_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="darkness_pad",
            setup_code="use_bpm 90\nuse_synth :dark_ambience"
        ),
        musical_params=MusicalParameters(
            notes=["C2"],
            root_note="C2",
            synth=":dark_ambience",
            amp_range=(0.4, 0.6),
            effects={
                "reverb": {"room": 0.9, "mix": 0.8},
                "hpf": {"cutoff": 50},
                "bitcrusher": {"bits": 6, "mix": 0.3}
            },
            duration_bars=24,
            bpm=90
        ),
        metadata=SegmentMetadata(
            source_file="2021-10-27_darkness_bed.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["dark_ambient", "atmospheric", "experimental"],
            mood_tags=["dark", "mysterious", "cinematic", "deep"],
            element_tags=["pad", "texture", "atmospheric", "lo-fi"],
            suitable_sections=["intro", "breakdown", "ambient_section"],
            energy_level=0.2,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 1.1,
                "mid": 0.9,
                "high": 0.8
            }
        ),
        math_adaptable=True,
        variations=[
            {"bitcrusher_bits_range": (4, 8)},
            {"reverb_room_range": (0.7, 1.0)}
        ]
    )


def extract_cosmic_arpeggio():
    """提取宇宙琶音 - 来自2021-08-15_CosmicExplorer.rb"""
    
    code = """use_bpm 132
use_synth :blade

live_loop :cosmic_arp do
  with_fx :echo, phase: 0.5, decay: 8 do
    with_fx :reverb, room: 0.8 do
      notes = (scale :c4, :minor_pentatonic, num_octaves: 3)
      8.times do
        play notes.choose, amp: 0.4, release: 0.2, cutoff: rrand(70, 120)
        sleep 0.125
      end
    end
  end
end"""

    return StandardSegment(
        id="cosmic_arpeggio_blade_01",
        name="Cosmic Explorer Arpeggio",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ARPEGGIO,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cosmic_arp",
            setup_code="use_bpm 132\nuse_synth :blade"
        ),
        musical_params=MusicalParameters(
            scale="C_minor_pentatonic",
            root_note="C4",
            pattern=[1]*8,
            subdivisions=8,
            synth=":blade",
            amp_range=(0.3, 0.5),
            effects={
                "echo": {"phase": 0.5, "decay": 8},
                "reverb": {"room": 0.8},
                "cutoff_range": (70, 120)
            },
            duration_bars=1,
            bpm=132
        ),
        metadata=SegmentMetadata(
            source_file="2021-08-15_CosmicExplorer.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["space", "cosmic", "trance", "progressive"],
            mood_tags=["spacey", "futuristic", "exploratory", "ethereal"],
            element_tags=["arpeggio", "melodic", "textural"],
            suitable_sections=["build_up", "peak", "transition"],
            energy_level=0.6,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"scale": "major_pentatonic"},
            {"scale": "blues"},
            {"octave_range": (2, 4)}
        ]
    )


def extract_synced_hihat_pattern():
    """提取同步Hi-hat模式 - 优化自2021-12-18系列"""
    
    code = """use_bpm 128

live_loop :synced_hats do
  16.times do |i|
    sample :drum_cymbal_closed, amp: (i % 4 == 2) ? 0.6 : 0.3, rate: 1.2
    sleep 0.125
  end
end"""

    return StandardSegment(
        id="synced_hihat_pattern_01",
        name="Synced Hi-hat Pattern",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.HIHAT_PATTERN,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="synced_hats",
            setup_code="use_bpm 128"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0],
            subdivisions=16,
            sample=":drum_cymbal_closed",
            amp_range=(0.3, 0.6),
            duration_bars=2,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="2021-12-18_2.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["house", "techno", "minimal"],
            mood_tags=["driving", "steady", "rhythmic"],
            element_tags=["hihat", "percussion", "groove"],
            suitable_sections=["verse", "drop", "groove_section"],
            energy_level=0.5,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 0.7,
                "mid": 1.0,
                "high": 1.4
            }
        ),
        math_adaptable=True,
        variations=[
            {"accent_positions": [2, 6, 10, 14]},
            {"rate_range": (1.0, 1.5)}
        ]
    )


def extract_futuristic_lead():
    """提取未来感主音 - 来自ゆめ未来 Sonic.rb"""
    
    code = """use_bpm 140
use_synth :prophet

live_loop :future_lead do
  with_fx :slicer, phase: 0.25, wave: 1 do
    with_fx :reverb, room: 0.5 do
      play_pattern_timed [:e5, :g5, :b5, :d6, :b5, :g5], [0.25, 0.25, 0.25, 0.5, 0.25, 0.25], 
                         amp: 0.6, release: 0.3, cutoff: 110
    end
  end
end"""

    return StandardSegment(
        id="futuristic_lead_slicer_01",
        name="Futuristic Sliced Lead",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.LEAD_MELODY,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="future_lead",
            setup_code="use_bpm 140\nuse_synth :prophet"
        ),
        musical_params=MusicalParameters(
            notes=["E5", "G5", "B5", "D6"],
            scale="E_minor",
            root_note="E5",
            synth=":prophet",
            amp_range=(0.5, 0.7),
            effects={
                "slicer": {"phase": 0.25, "wave": 1},
                "reverb": {"room": 0.5},
                "cutoff": 110
            },
            duration_bars=2,
            bpm=140
        ),
        metadata=SegmentMetadata(
            source_file="ゆめ未来 Sonic.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["future_bass", "electronic", "j-pop"],
            mood_tags=["futuristic", "bright", "energetic", "dreamy"],
            element_tags=["lead", "melodic", "sliced", "hook"],
            suitable_sections=["chorus", "drop", "hook"],
            energy_level=0.8,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.3,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"slicer_phase_range": (0.125, 0.5)},
            {"wave_type": [0, 1, 2, 3]}
        ]
    )


def extract_deep_house_chord_stabs():
    """提取Deep House和弦Stab - 来自2021-10-31_deephouse_2.rb"""
    
    code = """use_bpm 124
use_synth :piano

live_loop :chord_stabs do
  with_fx :reverb, room: 0.6, mix: 0.5 do
    with_fx :lpf, cutoff: 95 do
      play_chord [:c4, :e4, :g4], amp: 0.7, release: 0.5
      sleep 2
      play_chord [:a3, :c4, :e4], amp: 0.6, release: 0.5
      sleep 2
    end
  end
end"""

    return StandardSegment(
        id="deep_house_chord_stabs_01",
        name="Deep House Chord Stabs",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.CHORD_PROGRESSION,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="chord_stabs",
            setup_code="use_bpm 124\nuse_synth :piano"
        ),
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "A3", "C4", "E4"],
            scale="C_major",
            root_note="C4",
            synth=":piano",
            amp_range=(0.6, 0.7),
            effects={
                "reverb": {"room": 0.6, "mix": 0.5},
                "lpf": {"cutoff": 95}
            },
            duration_bars=4,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2021-10-31_deephouse_2.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "house", "soulful"],
            mood_tags=["warm", "groovy", "emotional"],
            element_tags=["chords", "stabs", "harmonic"],
            suitable_sections=["verse", "breakdown", "build_up"],
            energy_level=0.6,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 1.2,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"voicing": "open"},
            {"synth": ":prophet"}
        ]
    )


def extract_minimal_snare():
    """提取Minimal Snare模式 - 优化自2021-12-21系列"""
    
    code = """use_bpm 126

live_loop :minimal_snare do
  sleep 1
  sample :drum_snare_hard, amp: 0.8, rate: 0.9
  sleep 1
end"""

    return StandardSegment(
        id="minimal_snare_pattern_01",
        name="Minimal Snare Pattern",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.SNARE_PATTERN,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="minimal_snare",
            setup_code="use_bpm 126"
        ),
        musical_params=MusicalParameters(
            pattern=[0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
            subdivisions=16,
            sample=":drum_snare_hard",
            amp_range=(0.7, 0.9),
            duration_bars=2,
            bpm=126
        ),
        metadata=SegmentMetadata(
            source_file="2021-12-21_2.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["minimal", "techno", "house"],
            mood_tags=["clean", "precise", "driving"],
            element_tags=["snare", "backbeat", "minimal"],
            suitable_sections=["verse", "drop", "groove"],
            energy_level=0.6,
            complexity=0.2,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.3,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"rate_range": (0.8, 1.1)},
            {"reverb_add": {"room": 0.3}}
        ]
    )


def extract_cosmic_noise_sweep():
    """提取宇宙噪音扫频 - 来自2021-08-15_CosmicExplorer.rb"""
    
    code = """use_bpm 132

live_loop :cosmic_sweep do
  with_fx :hpf, cutoff_slide: 8 do |fx|
    sample :ambi_lunar_land, amp: 0.4, rate: 0.5
    control fx, cutoff: 130
    sleep 8
  end
end"""

    return StandardSegment(
        id="cosmic_noise_sweep_01",
        name="Cosmic Noise Sweep",
        category=SegmentCategory.FX,
        sub_type=SegmentSubType.RISER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cosmic_sweep",
            setup_code="use_bpm 132"
        ),
        musical_params=MusicalParameters(
            sample=":ambi_lunar_land",
            amp_range=(0.3, 0.5),
            effects={
                "hpf": {"cutoff_slide": 8, "cutoff_target": 130}
            },
            duration_bars=8,
            bpm=132
        ),
        metadata=SegmentMetadata(
            source_file="2021-08-15_CosmicExplorer.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["space", "ambient", "cinematic"],
            mood_tags=["atmospheric", "rising", "tension"],
            element_tags=["riser", "fx", "transition", "sweep"],
            suitable_sections=["build_up", "transition"],
            energy_level=0.5,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 0.7,
                "mid": 1.0,
                "high": 1.4
            }
        ),
        math_adaptable=True,
        variations=[
            {"cutoff_end_range": (100, 150)},
            {"slide_duration_range": (4, 16)}
        ]
    )


# 主函数：批量生成并保存
def generate_all_segments_2021():
    """生成2021文件夹的所有Segment并保存"""
    
    segments = [
        extract_deep_house_kick_bass(),
        extract_darkness_ambient_pad(),
        extract_cosmic_arpeggio(),
        extract_synced_hihat_pattern(),
        extract_futuristic_lead(),
        extract_deep_house_chord_stabs(),
        extract_minimal_snare(),
        extract_cosmic_noise_sweep()
    ]
    
    # 保存到对应分类文件夹
    base_path = "../segments"
    
    for segment in segments:
        category_path = f"{base_path}/{segment.category.value}"
        os.makedirs(category_path, exist_ok=True)
        
        filepath = f"{category_path}/{segment.id}.json"
        segment.save_to_file(filepath)
        print(f"✓ 已生成: {segment.name} -> {filepath}")
    
    print(f"\n总计生成 {len(segments)} 个高质量Segment素材")
    
    # 生成统计报告
    category_count = {}
    for segment in segments:
        cat = segment.category.value
        category_count[cat] = category_count.get(cat, 0) + 1
    
    print("\n分类统计:")
    for cat, count in sorted(category_count.items()):
        print(f"  {cat}: {count} 个")
    
    return segments


if __name__ == "__main__":
    segments = generate_all_segments_2021()