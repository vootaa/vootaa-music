"""
批量提取2023文件夹中的高质量Segment素材
重点：成熟Deep House、Lo-fi House、Drum'n'Bass、热带风格
"""

from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


def extract_elegant_deep_house_bass():
    """提取优雅Deep House Bass - 来自2023-10-17_elegant-deep-house.rb"""
    
    code = """use_bpm 122
use_synth :fm

live_loop :elegant_bass do
  with_fx :lpf, cutoff: 85 do
    play :c2, amp: 0.9, release: 0.9, divisor: 1.5, depth: 2.5
    sleep 1
    play :c2, amp: 0.6, release: 0.4, divisor: 1.5, depth: 2.5
    sleep 0.5
    play :g1, amp: 0.7, release: 0.4, divisor: 1.5, depth: 2.5
    sleep 0.5
    play :a1, amp: 0.65, release: 0.3, divisor: 1.5, depth: 2.5
    sleep 0.5
    play :g1, amp: 0.7, release: 0.4, divisor: 1.5, depth: 2.5
    sleep 0.5
  end
end"""

    return StandardSegment(
        id="elegant_deep_house_bass_01",
        name="Elegant Deep House Bass",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.BASS_LINE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="elegant_bass",
            setup_code="use_bpm 122\nuse_synth :fm"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "G1", "A1"],
            root_note="C2",
            pattern=[1, 0, 1, 1, 1, 0, 1, 0],
            synth=":fm",
            amp_range=(0.6, 0.9),
            effects={
                "lpf": {"cutoff": 85},
                "divisor": 1.5,
                "depth": 2.5
            },
            duration_bars=4,
            bpm=122
        ),
        metadata=SegmentMetadata(
            source_file="2023-10-17_elegant-deep-house.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "elegant", "sophisticated"],
            mood_tags=["smooth", "refined", "groovy", "classy"],
            element_tags=["bass", "fm", "melodic", "foundation"],
            suitable_sections=["verse", "drop", "groove"],
            energy_level=0.7,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 1.3,
                "mid": 1.0,
                "high": 0.9
            }
        ),
        math_adaptable=True,
        variations=[
            {"divisor_range": (1.0, 2.5)},
            {"depth_range": (2.0, 4.0)}
        ]
    )


def extract_lofi_house_texture():
    """提取Lo-fi House纹理 - 优化自2023-06-14_lofi_house.rb"""
    
    code = """use_bpm 118
use_synth :piano

live_loop :lofi_texture do
  with_fx :bitcrusher, bits: 8, mix: 0.4 do
    with_fx :lpf, cutoff: 75 do
      with_fx :reverb, room: 0.7, mix: 0.6 do
        play_chord [:c4, :e4, :g4], amp: 0.35, release: 2
        sleep 4
        play_chord [:a3, :c4, :e4], amp: 0.3, release: 2
        sleep 4
      end
    end
  end
end"""

    return StandardSegment(
        id="lofi_house_texture_01",
        name="Lo-fi House Texture",
        category=SegmentCategory.TEXTURE,
        sub_type=SegmentSubType.SYNTH_TEXTURE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="lofi_texture",
            setup_code="use_bpm 118\nuse_synth :piano"
        ),
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "A3", "C4", "E4"],
            scale="C_major",
            root_note="C4",
            synth=":piano",
            amp_range=(0.3, 0.35),
            effects={
                "bitcrusher": {"bits": 8, "mix": 0.4},
                "lpf": {"cutoff": 75},
                "reverb": {"room": 0.7, "mix": 0.6}
            },
            duration_bars=8,
            bpm=118
        ),
        metadata=SegmentMetadata(
            source_file="2023-06-14_lofi_house.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["lofi_house", "house", "lofi", "chill"],
            mood_tags=["nostalgic", "warm", "relaxed", "dreamy"],
            element_tags=["texture", "chords", "lo-fi", "vintage"],
            suitable_sections=["verse", "breakdown", "ambient_section"],
            energy_level=0.4,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.2,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"bits_range": (6, 10)},
            {"cutoff_range": (60, 90)}
        ]
    )


def extract_dnb_breakbeat():
    """提取Drum'n'Bass Breakbeat - 来自2023-05-12_drum'n'bass_heart.rb"""
    
    code = """use_bpm 174

live_loop :dnb_break do
  sample :loop_amen, amp: 0.8, beat_stretch: 2, rate: 1
  sleep 2
end

live_loop :dnb_bass do
  sync :dnb_break
  use_synth :tb303
  play :c2, amp: 0.7, release: 0.2, cutoff: rrand(60, 100), res: 0.8
  sleep 0.25
  play :c2, amp: 0.5, release: 0.1, cutoff: rrand(60, 100), res: 0.8
  sleep 0.25
end"""

    return StandardSegment(
        id="dnb_breakbeat_amen_01",
        name="Drum'n'Bass Amen Breakbeat",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.BREAKBEAT,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="dnb_break",
            dependencies=["dnb_bass"],
            setup_code="use_bpm 174"
        ),
        musical_params=MusicalParameters(
            notes=["C2"],
            root_note="C2",
            sample=":loop_amen",
            synth=":tb303",
            amp_range=(0.5, 0.8),
            effects={
                "beat_stretch": 2,
                "cutoff_range": (60, 100),
                "res": 0.8
            },
            duration_bars=2,
            bpm=174
        ),
        metadata=SegmentMetadata(
            source_file="2023-05-12_drum'n'bass_heart.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["dnb", "drum_and_bass", "breakbeat", "jungle"],
            mood_tags=["intense", "energetic", "fast", "aggressive"],
            element_tags=["breakbeat", "amen", "bass", "synced"],
            suitable_sections=["drop", "peak", "high_energy"],
            energy_level=0.95,
            complexity=0.9,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 1.1,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"rate_range": (0.9, 1.1)},
            {"beat_stretch_range": (1.5, 2.5)}
        ]
    )


def extract_amazonia_jungle_atmosphere():
    """提取亚马逊雨林氛围 - 来自2023-09-19_amazonia_house.rb"""
    
    code = """use_bpm 120

live_loop :jungle_atmos do
  with_fx :reverb, room: 1.0, mix: 0.8 do
    with_fx :echo, phase: 1.5, decay: 8 do
      sample :ambi_haunted_hum, amp: 0.3, rate: 0.7
      sleep 16
      sample :ambi_dark_woosh, amp: 0.25, rate: 0.5
      sleep 16
    end
  end
end"""

    return StandardSegment(
        id="amazonia_jungle_atmosphere_01",
        name="Amazonia Jungle Atmosphere",
        category=SegmentCategory.ATMOSPHERE,
        sub_type=SegmentSubType.FIELD_RECORDING,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="jungle_atmos",
            setup_code="use_bpm 120"
        ),
        musical_params=MusicalParameters(
            sample=":ambi_haunted_hum, :ambi_dark_woosh",
            amp_range=(0.25, 0.3),
            effects={
                "reverb": {"room": 1.0, "mix": 0.8},
                "echo": {"phase": 1.5, "decay": 8},
                "rate_range": (0.5, 0.7)
            },
            duration_bars=32,
            bpm=120
        ),
        metadata=SegmentMetadata(
            source_file="2023-09-19_amazonia_house.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "world", "tribal", "organic"],
            mood_tags=["mysterious", "natural", "immersive", "exotic"],
            element_tags=["atmosphere", "field_recording", "jungle", "organic"],
            suitable_sections=["intro", "breakdown", "ambient_section"],
            energy_level=0.2,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.0,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"rate_variations": True},
            {"layering": "multiple_samples"}
        ]
    )


def extract_chill_deep_house_pad():
    """提取Chill Deep House Pad - 来自2023-08-05_chill_deep_house.rb"""
    
    code = """use_bpm 120
use_synth :blade

live_loop :chill_pad do
  with_fx :reverb, room: 0.8, mix: 0.7 do
    with_fx :lpf, cutoff: 80 do
      play_chord [:c3, :e3, :g3, :b3], amp: 0.3, attack: 3, sustain: 6, release: 3
      sleep 12
      play_chord [:f3, :a3, :c4, :e4], amp: 0.28, attack: 3, sustain: 6, release: 3
      sleep 12
    end
  end
end"""

    return StandardSegment(
        id="chill_deep_house_pad_01",
        name="Chill Deep House Pad",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.PAD,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="chill_pad",
            setup_code="use_bpm 120\nuse_synth :blade"
        ),
        musical_params=MusicalParameters(
            notes=["C3", "E3", "G3", "B3", "F3", "A3", "C4", "E4"],
            scale="C_major",
            root_note="C3",
            synth=":blade",
            amp_range=(0.28, 0.3),
            effects={
                "reverb": {"room": 0.8, "mix": 0.7},
                "lpf": {"cutoff": 80}
            },
            duration_bars=24,
            bpm=120
        ),
        metadata=SegmentMetadata(
            source_file="2023-08-05_chill_deep_house.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "chill", "ambient_house"],
            mood_tags=["relaxed", "soothing", "mellow", "peaceful"],
            element_tags=["pad", "chords", "sustained", "smooth"],
            suitable_sections=["intro", "breakdown", "verse"],
            energy_level=0.35,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.1,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"attack_range": (2, 4)},
            {"cutoff_range": (70, 90)}
        ]
    )


def extract_minimal_deep_house_hihat():
    """提取Minimal Deep House Hi-hat - 来自2023-02-02_minimal_deephouse.rb"""
    
    code = """use_bpm 124

live_loop :minimal_hats do
  8.times do |i|
    sample :drum_cymbal_closed, amp: (i % 2 == 0) ? 0.4 : 0.25, rate: 1.1
    sleep 0.25
  end
end"""

    return StandardSegment(
        id="minimal_deep_house_hihat_01",
        name="Minimal Deep House Hi-hat",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.HIHAT_PATTERN,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="minimal_hats",
            setup_code="use_bpm 124"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 0, 1, 0, 1, 0],
            subdivisions=8,
            sample=":drum_cymbal_closed",
            amp_range=(0.25, 0.4),
            duration_bars=2,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2023-02-02_minimal_deephouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["minimal", "deep_house", "house"],
            mood_tags=["clean", "precise", "subtle", "groovy"],
            element_tags=["hihat", "minimal", "groove", "tight"],
            suitable_sections=["verse", "drop", "minimal_section"],
            energy_level=0.5,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 0.7,
                "mid": 1.0,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"accent_pattern": "alternating"},
            {"rate_range": (1.0, 1.2)}
        ]
    )


def extract_tech_house_synth():
    """提取Tech House合成器 - 来自2023-04-16_tech_house.rb"""
    
    code = """use_bpm 128
use_synth :prophet

live_loop :tech_synth do
  with_fx :slicer, phase: 0.25 do
    with_fx :reverb, room: 0.5 do
      play :c4, amp: 0.5, release: 0.5, cutoff: 100
      sleep 0.5
      play :e4, amp: 0.45, release: 0.5, cutoff: 100
      sleep 0.5
    end
  end
end"""

    return StandardSegment(
        id="tech_house_synth_prophet_01",
        name="Tech House Prophet Synth",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.HOOK,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="tech_synth",
            setup_code="use_bpm 128\nuse_synth :prophet"
        ),
        musical_params=MusicalParameters(
            notes=["C4", "E4"],
            scale="C_major",
            root_note="C4",
            synth=":prophet",
            amp_range=(0.45, 0.5),
            effects={
                "slicer": {"phase": 0.25},
                "reverb": {"room": 0.5},
                "cutoff": 100
            },
            duration_bars=1,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="2023-04-16_tech_house.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["tech_house", "house", "techno"],
            mood_tags=["driving", "hypnotic", "modern"],
            element_tags=["synth", "melodic", "sliced", "hook"],
            suitable_sections=["verse", "drop", "groove"],
            energy_level=0.7,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.3,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"slicer_phase_range": (0.125, 0.5)},
            {"melody_variations": True}
        ]
    )


def extract_ethnic_percussion():
    """提取民族打击乐 - 来自2023-07-28_民族.rb"""
    
    code = """use_bpm 110

live_loop :ethnic_perc do
  sample :tabla_tas1, amp: 0.6
  sleep 0.5
  sample :tabla_te1, amp: 0.4
  sleep 0.25
  sample :tabla_ghe1, amp: 0.5
  sleep 0.25
  sample :tabla_tas2, amp: 0.55
  sleep 0.5
  sample :tabla_te2, amp: 0.45
  sleep 0.5
end"""

    return StandardSegment(
        id="ethnic_percussion_tabla_01",
        name="Ethnic Tabla Percussion",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.PERCUSSION_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="ethnic_perc",
            setup_code="use_bpm 110"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 1, 1, 0, 1, 0],
            subdivisions=8,
            sample=":tabla_tas1, :tabla_te1, :tabla_ghe1",
            amp_range=(0.4, 0.6),
            duration_bars=2,
            bpm=110
        ),
        metadata=SegmentMetadata(
            source_file="2023-07-28_民族.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["world", "ethnic", "indian", "tribal"],
            mood_tags=["exotic", "rhythmic", "traditional", "organic"],
            element_tags=["percussion", "tabla", "ethnic", "world"],
            suitable_sections=["verse", "breakdown", "world_fusion"],
            energy_level=0.6,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"pattern_variations": "indian_classical"},
            {"tempo_range": (100, 120)}
        ]
    )


def extract_triple_helix_pattern():
    """提取三螺旋模式 - 来自2023-01-04_triple_helix.rb"""
    
    code = """use_bpm 130

live_loop :helix_1 do
  use_synth :sine
  play (scale :c4, :minor_pentatonic).choose, amp: 0.3, release: 0.2
  sleep 0.333
end

live_loop :helix_2 do
  use_synth :sine
  play (scale :c4, :minor_pentatonic, num_octaves: 2).choose, amp: 0.25, release: 0.2
  sleep 0.5
end

live_loop :helix_3 do
  use_synth :sine
  play (scale :c4, :minor_pentatonic, num_octaves: 3).choose, amp: 0.2, release: 0.2
  sleep 0.25
end"""

    return StandardSegment(
        id="triple_helix_pattern_01",
        name="Triple Helix Pattern",
        category=SegmentCategory.TEXTURE,
        sub_type=SegmentSubType.SYNTH_TEXTURE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="helix_1",
            dependencies=["helix_2", "helix_3"],
            setup_code="use_bpm 130"
        ),
        musical_params=MusicalParameters(
            scale="C_minor_pentatonic",
            root_note="C4",
            synth=":sine",
            amp_range=(0.2, 0.3),
            duration_bars=4,
            bpm=130
        ),
        metadata=SegmentMetadata(
            source_file="2023-01-04_triple_helix.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["experimental", "algorithmic", "generative"],
            mood_tags=["complex", "hypnotic", "mathematical", "evolving"],
            element_tags=["texture", "polyrhythm", "generative", "layered"],
            suitable_sections=["ambient_section", "experimental"],
            energy_level=0.5,
            complexity=0.9,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.1,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"timing_ratios": [(0.333, 0.5, 0.25), (0.25, 0.333, 0.5)]},
            {"octave_spreading": True}
        ]
    )


def extract_weekend_deep_house_chord():
    """提取Weekend Deep House和弦 - 来自2023-01-19_weekend_deephouse.rb"""
    
    code = """use_bpm 122
use_synth :saw

live_loop :weekend_chords do
  with_fx :reverb, room: 0.7, mix: 0.6 do
    with_fx :lpf, cutoff: 90 do
      play_chord [:c4, :e4, :g4, :b4], amp: 0.4, release: 3, cutoff: 80
      sleep 4
      play_chord [:a3, :c4, :e4, :g4], amp: 0.38, release: 3, cutoff: 80
      sleep 4
      play_chord [:f3, :a3, :c4, :e4], amp: 0.39, release: 3, cutoff: 80
      sleep 4
      play_chord [:g3, :b3, :d4, :f4], amp: 0.37, release: 3, cutoff: 80
      sleep 4
    end
  end
end"""

    return StandardSegment(
        id="weekend_deep_house_chord_01",
        name="Weekend Deep House Chords",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.CHORD_PROGRESSION,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="weekend_chords",
            setup_code="use_bpm 122\nuse_synth :saw"
        ),
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "B4", "A3", "C4", "E4", "G4", "F3", "A3", "C4", "E4", "G3", "B3", "D4", "F4"],
            scale="C_major",
            root_note="C4",
            synth=":saw",
            amp_range=(0.37, 0.4),
            effects={
                "reverb": {"room": 0.7, "mix": 0.6},
                "lpf": {"cutoff": 90},
                "synth_cutoff": 80
            },
            duration_bars=16,
            bpm=122
        ),
        metadata=SegmentMetadata(
            source_file="2023-01-19_weekend_deephouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "weekend", "progressive"],
            mood_tags=["uplifting", "emotional", "warm", "euphoric"],
            element_tags=["chords", "progression", "harmonic", "sustained"],
            suitable_sections=["chorus", "breakdown", "build_up"],
            energy_level=0.65,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 1.2,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"progression": "I-vi-IV-V"},
            {"voicing": "open"}
        ]
    )


# 主函数：批量生成并保存
def generate_all_segments_2023():
    """生成2023文件夹的所有Segment并保存"""
    
    segments = [
        extract_elegant_deep_house_bass(),
        extract_lofi_house_texture(),
        extract_dnb_breakbeat(),
        extract_amazonia_jungle_atmosphere(),
        extract_chill_deep_house_pad(),
        extract_minimal_deep_house_hihat(),
        extract_tech_house_synth(),
        extract_ethnic_percussion(),
        extract_triple_helix_pattern(),
        extract_weekend_deep_house_chord()
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
    
    # 显示风格分布
    genre_count = {}
    for segment in segments:
        for genre in segment.metadata.genre_tags:
            genre_count[genre] = genre_count.get(genre, 0) + 1
    
    print("\n风格分布（Top 5）:")
    for genre, count in sorted(genre_count.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {genre}: {count} 次")
    
    # 能量等级分析
    energy_levels = [s.metadata.energy_level for s in segments]
    print(f"\n能量等级范围: {min(energy_levels):.2f} - {max(energy_levels):.2f}")
    print(f"平均能量等级: {sum(energy_levels)/len(energy_levels):.2f}")
    
    return segments


if __name__ == "__main__":
    segments = generate_all_segments_2023()