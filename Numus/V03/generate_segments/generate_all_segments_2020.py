"""
批量提取2020文件夹中的高质量Segment素材
优化和标准化为可复用的音乐单元
"""

from datetime import datetime
import sys
sys.path.append('..')
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


def extract_summer_ambient_pad():
    """提取夏日氛围Pad - 来自ElectronicSummer.rb"""
    
    code = """use_bpm 120
use_synth :hollow

live_loop :summer_pad do
  with_fx :reverb, room: 0.8, mix: 0.6 do
    with_fx :lpf, cutoff: 90 do
      play_chord [:c4, :e4, :g4, :b4], amp: 0.4, attack: 2, sustain: 4, release: 3
      sleep 8
      play_chord [:d4, :f4, :a4, :c5], amp: 0.35, attack: 2, sustain: 4, release: 3
      sleep 8
    end
  end
end"""

    return StandardSegment(
        id="summer_ambient_pad_01",
        name="Summer Ambient Pad",
        category=SegmentCategory.ATMOSPHERE,
        sub_type=SegmentSubType.PAD,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="summer_pad",
            setup_code="use_bpm 120\nuse_synth :hollow"
        ),
        
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "B4", "D4", "F4", "A4", "C5"],
            scale="C_major",
            root_note="C4",
            synth=":hollow",
            amp_range=(0.35, 0.4),
            effects={
                "reverb": {"room": 0.8, "mix": 0.6},
                "lpf": {"cutoff": 90}
            },
            duration_bars=16,
            bpm=120
        ),
        
        metadata=SegmentMetadata(
            source_file="ElectronicSummer.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "chillout", "atmospheric"],
            mood_tags=["peaceful", "bright", "warm"],
            element_tags=["pad", "harmonic", "sustained"],
            suitable_sections=["intro", "breakdown", "outro"],
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
            {"cutoff_range": (70, 110), "room_range": (0.6, 1.0)},
            {"attack_range": (1.5, 3.0), "sustain_range": (3, 6)}
        ]
    )


def extract_rising_arpeggio():
    """提取上升琶音 - 优化自昇っていく系.rb"""
    
    code = """use_bpm 128
use_synth :pluck

live_loop :rising_arp do
  with_fx :echo, phase: 0.75, decay: 4 do
    notes = (scale :c4, :major_pentatonic, num_octaves: 2)
    notes.each do |n|
      play n, amp: 0.6, release: 0.3, cutoff: rrand(80, 110)
      sleep 0.125
    end
  end
end"""

    return StandardSegment(
        id="rising_arpeggio_pentatonic_01",
        name="Rising Pentatonic Arpeggio",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ARPEGGIO,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="rising_arp",
            setup_code="use_bpm 128\nuse_synth :pluck"
        ),
        
        musical_params=MusicalParameters(
            scale="C_major_pentatonic",
            root_note="C4",
            pattern=[1]*16,  # 连续16分音符
            subdivisions=16,
            synth=":pluck",
            amp_range=(0.5, 0.7),
            effects={
                "echo": {"phase": 0.75, "decay": 4},
                "cutoff_range": (80, 110)
            },
            duration_bars=4,
            bpm=128
        ),
        
        metadata=SegmentMetadata(
            source_file="昇っていく系.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["melodic", "progressive", "uplifting"],
            mood_tags=["ascending", "hopeful", "energetic"],
            element_tags=["arpeggio", "melodic", "driving"],
            suitable_sections=["build_up", "drop"],
            energy_level=0.7,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.2,
                "high": 1.1
            }
        ),
        
        math_adaptable=True,
        variations=[
            {"scale": "minor_pentatonic"},
            {"scale": "major"},
            {"subdivisions": 8, "note_length": 0.25}
        ]
    )


def extract_retro_8bit_lead():
    """提取8-bit复古主音 - 来自TetrisSonic.rb"""
    
    code = """use_bpm 140
use_synth :square

live_loop :retro_lead do
  melody = [:e5, :b4, :c5, :d5, :c5, :b4, :a4, :a4, :c5, :e5, :d5, :c5, :b4]
  melody.each do |note|
    play note, amp: 0.5, release: 0.2, cutoff: 80
    sleep 0.25
  end
  sleep 0.25
end"""

    return StandardSegment(
        id="retro_8bit_lead_01",
        name="8-bit Retro Lead Melody",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.LEAD_MELODY,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="retro_lead",
            setup_code="use_bpm 140\nuse_synth :square"
        ),
        
        musical_params=MusicalParameters(
            notes=["E5", "B4", "C5", "D5", "C5", "B4", "A4", "A4", "C5", "E5", "D5", "C5", "B4"],
            scale="E_minor",
            root_note="E5",
            synth=":square",
            amp_range=(0.4, 0.6),
            effects={"cutoff": 80},
            duration_bars=4,
            bpm=140
        ),
        
        metadata=SegmentMetadata(
            source_file="TetrisSonic.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["chiptune", "8bit", "retro"],
            mood_tags=["nostalgic", "playful", "energetic"],
            element_tags=["lead", "melodic", "hook"],
            suitable_sections=["drop", "hook"],
            energy_level=0.8,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 0.7,
                "mid": 1.3,
                "high": 1.2
            }
        ),
        
        math_adaptable=True,
        variations=[
            {"synth": ":pulse", "pulse_width": 0.3},
            {"synth": ":saw"}
        ]
    )


def extract_deep_sub_bass():
    """提取深沉Sub Bass - 优化综合素材"""
    
    code = """use_bpm 128
use_synth :sine

live_loop :deep_sub do
  with_fx :compressor, threshold: 0.5 do
    play :c2, amp: 1.5, release: 1, attack: 0.01
    sleep 1
    play :c2, amp: 1.2, release: 0.5, attack: 0.01
    sleep 0.5
    play :g1, amp: 1.3, release: 0.5, attack: 0.01
    sleep 0.5
  end
end"""

    return StandardSegment(
        id="deep_sub_bass_foundation_01",
        name="Deep Sub Bass Foundation",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.SUB_BASS,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="deep_sub",
            setup_code="use_bpm 128\nuse_synth :sine"
        ),
        
        musical_params=MusicalParameters(
            notes=["C2", "G1"],
            root_note="C2",
            pattern=[1, 0, 1, 1, 0, 0, 1, 0],
            synth=":sine",
            amp_range=(1.2, 1.5),
            effects={"compressor": {"threshold": 0.5}},
            duration_bars=2,
            bpm=128
        ),
        
        metadata=SegmentMetadata(
            source_file="MySonic.rb (optimized)",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "techno", "minimal"],
            mood_tags=["deep", "powerful", "foundation"],
            element_tags=["sub_bass", "foundation", "low_end"],
            suitable_sections=["drop", "peak", "build_up"],
            energy_level=0.7,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 1.5,
                "mid": 0.8,
                "high": 0.6
            }
        ),
        
        math_adaptable=True
    )


def extract_atmospheric_texture():
    """提取氛围纹理层 - 综合优化"""
    
    code = """use_bpm 120
use_synth :dark_ambience

live_loop :atmosphere do
  with_fx :reverb, room: 1.0, mix: 0.7 do
    with_fx :hpf, cutoff: 60 do
      play :c3, amp: 0.3, attack: 4, sustain: 8, release: 4
      sleep 16
    end
  end
end"""

    return StandardSegment(
        id="atmospheric_texture_layer_01",
        name="Atmospheric Texture Layer",
        category=SegmentCategory.TEXTURE,
        sub_type=SegmentSubType.SYNTH_TEXTURE,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="atmosphere",
            setup_code="use_bpm 120\nuse_synth :dark_ambience"
        ),
        
        musical_params=MusicalParameters(
            notes=["C3"],
            root_note="C3",
            synth=":dark_ambience",
            amp_range=(0.2, 0.4),
            effects={
                "reverb": {"room": 1.0, "mix": 0.7},
                "hpf": {"cutoff": 60}
            },
            duration_bars=16,
            bpm=120
        ),
        
        metadata=SegmentMetadata(
            source_file="ElectronicSummer.rb (enhanced)",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "atmospheric", "cinematic"],
            mood_tags=["spacious", "mysterious", "calm"],
            element_tags=["texture", "background", "atmospheric"],
            suitable_sections=["intro", "breakdown", "transition"],
            energy_level=0.2,
            complexity=0.2,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.0,
                "high": 1.1
            }
        ),
        
        math_adaptable=True
    )


def extract_rhythmic_percussion():
    """提取节奏打击乐层 - 优化自StanBicSonic.rb"""
    
    code = """use_bpm 128

live_loop :perc_layer do
  sample :perc_bell, amp: 0.4, rate: 1.2
  sleep 0.5
  sample :perc_snap, amp: 0.3
  sleep 0.25
  sample :perc_bell, amp: 0.35, rate: 0.8
  sleep 0.25
end"""

    return StandardSegment(
        id="rhythmic_percussion_layer_01",
        name="Rhythmic Percussion Layer",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.PERCUSSION_LAYER,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="perc_layer",
            setup_code="use_bpm 128"
        ),
        
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 1],  # 简化的节奏型
            subdivisions=4,
            sample=":perc_bell, :perc_snap",
            amp_range=(0.3, 0.4),
            duration_bars=1,
            bpm=128
        ),
        
        metadata=SegmentMetadata(
            source_file="StanBicSonic.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["house", "techno", "minimal"],
            mood_tags=["rhythmic", "driving", "textural"],
            element_tags=["percussion", "texture", "rhythm"],
            suitable_sections=["build_up", "drop", "verse"],
            energy_level=0.5,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        
        math_adaptable=True
    )


def extract_melodic_chord_progression():
    """提取旋律性和弦进行 - 综合优化"""
    
    code = """use_bpm 124
use_synth :prophet

live_loop :chord_prog do
  with_fx :reverb, room: 0.6 do
    play_chord [:c4, :e4, :g4], amp: 0.5, release: 4
    sleep 4
    play_chord [:a3, :c4, :e4], amp: 0.5, release: 4
    sleep 4
    play_chord [:f3, :a3, :c4], amp: 0.5, release: 4
    sleep 4
    play_chord [:g3, :b3, :d4], amp: 0.5, release: 4
    sleep 4
  end
end"""

    return StandardSegment(
        id="melodic_chord_progression_01",
        name="Melodic Chord Progression",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.CHORD_PROGRESSION,
        version="1.0",
        
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="chord_prog",
            setup_code="use_bpm 124\nuse_synth :prophet"
        ),
        
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "A3", "C4", "E4", "F3", "A3", "C4", "G3", "B3", "D4"],
            scale="C_major",
            root_note="C4",
            synth=":prophet",
            amp_range=(0.4, 0.6),
            effects={"reverb": {"room": 0.6}},
            duration_bars=16,
            bpm=124
        ),
        
        metadata=SegmentMetadata(
            source_file="MySonic.rb (enhanced)",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["progressive", "melodic", "house"],
            mood_tags=["emotional", "uplifting", "harmonic"],
            element_tags=["chords", "harmonic", "progression"],
            suitable_sections=["verse", "chorus", "breakdown"],
            energy_level=0.6,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 1.2,
                "high": 1.0
            }
        ),
        
        math_adaptable=True,
        variations=[
            {"chord_voicing": "open"},
            {"chord_voicing": "close"},
            {"progression": "I-vi-IV-V"}
        ]
    )


# 主函数：批量生成并保存
def generate_all_segments_2020():
    """生成2020文件夹的所有Segment并保存"""
    
    segments = [
        extract_summer_ambient_pad(),
        extract_rising_arpeggio(),
        extract_retro_8bit_lead(),
        extract_deep_sub_bass(),
        extract_atmospheric_texture(),
        extract_rhythmic_percussion(),
        extract_melodic_chord_progression()
    ]
    
    # 保存到对应分类文件夹
    base_path = "../segments"
    
    for segment in segments:
        category_path = f"{base_path}/{segment.category.value}"
        import os
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
    for cat, count in category_count.items():
        print(f"  {cat}: {count} 个")
    
    return segments


if __name__ == "__main__":
    segments = generate_all_segments_2020()