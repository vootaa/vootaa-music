"""
批量提取2024文件夹中的高质量Segment素材
重点：成熟Deep House、Cyberpunk、K-pop风格、实验性Tempo
"""

from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


def extract_cyberpunk_synth_lead():
    """提取赛博朋克合成器主音 - 来自2024-03-08_CyberPunk.rb"""
    
    code = """use_bpm 140
use_synth :blade

live_loop :cyber_lead do
  with_fx :bitcrusher, bits: 10, mix: 0.3 do
    with_fx :reverb, room: 0.6, mix: 0.5 do
      with_fx :slicer, phase: 0.125, wave: 3 do
        play_pattern_timed [:e5, :g5, :a5, :b5, :a5, :g5, :e5, :d5], 
                           [0.25]*8,
                           amp: 0.7, release: 0.2, cutoff: 120
      end
    end
  end
end"""

    return StandardSegment(
        id="cyberpunk_synth_lead_01",
        name="Cyberpunk Blade Lead",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.LEAD_MELODY,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cyber_lead",
            setup_code="use_bpm 140\nuse_synth :blade"
        ),
        musical_params=MusicalParameters(
            notes=["E5", "G5", "A5", "B5", "D5"],
            scale="E_minor",
            root_note="E5",
            synth=":blade",
            amp_range=(0.6, 0.8),
            effects={
                "bitcrusher": {"bits": 10, "mix": 0.3},
                "reverb": {"room": 0.6, "mix": 0.5},
                "slicer": {"phase": 0.125, "wave": 3},
                "cutoff": 120
            },
            duration_bars=2,
            bpm=140
        ),
        metadata=SegmentMetadata(
            source_file="2024-03-08_CyberPunk.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["cyberpunk", "synthwave", "futuristic", "electronic"],
            mood_tags=["dystopian", "energetic", "neon", "intense"],
            element_tags=["lead", "synth", "sliced", "digital"],
            suitable_sections=["drop", "chorus", "peak"],
            energy_level=0.85,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.3,
                "high": 1.4
            }
        ),
        math_adaptable=True,
        variations=[
            {"bits_range": (8, 12)},
            {"slicer_wave_range": (0, 3)},
            {"cutoff_range": (100, 130)}
        ]
    )


def extract_slow_tempo_ambient():
    """提取慢速氛围 - 来自2024-01-19_bpm50_slow_tempo.rb"""
    
    code = """use_bpm 50
use_synth :dark_ambience

live_loop :slow_ambient do
  with_fx :reverb, room: 1.0, mix: 0.9 do
    with_fx :echo, phase: 2, decay: 12 do
      play :c2, amp: 0.4, attack: 8, sustain: 16, release: 8
      sleep 32
      play :f2, amp: 0.35, attack: 8, sustain: 16, release: 8
      sleep 32
    end
  end
end"""

    return StandardSegment(
        id="slow_tempo_ambient_drone_01",
        name="Slow Tempo Ambient Drone",
        category=SegmentCategory.ATMOSPHERE,
        sub_type=SegmentSubType.AMBIENT_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="slow_ambient",
            setup_code="use_bpm 50\nuse_synth :dark_ambience"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "F2"],
            root_note="C2",
            synth=":dark_ambience",
            amp_range=(0.35, 0.4),
            effects={
                "reverb": {"room": 1.0, "mix": 0.9},
                "echo": {"phase": 2, "decay": 12}
            },
            duration_bars=64,
            bpm=50
        ),
        metadata=SegmentMetadata(
            source_file="2024-01-19_bpm50_slow_tempo.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "drone", "experimental", "atmospheric"],
            mood_tags=["meditative", "deep", "slow", "immersive"],
            element_tags=["drone", "atmospheric", "sustained", "minimal"],
            suitable_sections=["intro", "ambient_section", "meditation"],
            energy_level=0.15,
            complexity=0.2,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 0.9,
                "high": 0.8
            }
        ),
        math_adaptable=True,
        variations=[
            {"bpm_range": (40, 60)},
            {"attack_range": (6, 10)}
        ]
    )


def extract_newjeans_pop_bass():
    """提取NewJeans风格流行Bass - 来自2024-09-22_Supernatural-NewJeans.rb"""
    
    code = """use_bpm 128
use_synth :fm

live_loop :pop_bass do
  with_fx :compressor, threshold: 0.4 do
    play :c2, amp: 1.0, release: 0.8, divisor: 2, depth: 3
    sleep 0.5
    play :c2, amp: 0.7, release: 0.3, divisor: 2, depth: 3
    sleep 0.25
    play :d2, amp: 0.8, release: 0.3, divisor: 2, depth: 3
    sleep 0.25
    play :e2, amp: 0.75, release: 0.5, divisor: 2, depth: 3
    sleep 0.5
    play :c2, amp: 0.85, release: 0.4, divisor: 2, depth: 3
    sleep 0.5
  end
end"""

    return StandardSegment(
        id="newjeans_pop_bass_01",
        name="NewJeans Pop Bass",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.BASS_LINE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="pop_bass",
            setup_code="use_bpm 128\nuse_synth :fm"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "D2", "E2"],
            root_note="C2",
            pattern=[1, 0, 1, 1, 1, 0, 1, 0],
            synth=":fm",
            amp_range=(0.7, 1.0),
            effects={
                "compressor": {"threshold": 0.4},
                "divisor": 2,
                "depth": 3
            },
            duration_bars=2,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="2024-09-22_Supernatural-NewJeans.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["kpop", "pop", "dance_pop", "modern"],
            mood_tags=["catchy", "bright", "youthful", "energetic"],
            element_tags=["bass", "fm", "groovy", "pop"],
            suitable_sections=["verse", "chorus", "drop"],
            energy_level=0.75,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 1.3,
                "mid": 1.1,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"divisor_range": (1.5, 3.0)},
            {"depth_range": (2, 4)}
        ]
    )


def extract_modern_deep_house_kick():
    """提取现代Deep House Kick - 来自2024-09-20_DeepHouse.rb"""
    
    code = """use_bpm 124

live_loop :modern_kick do
  sample :bd_haus, amp: 1.4, cutoff: 90
  sleep 1
  sample :bd_haus, amp: 1.2, cutoff: 85, rate: 0.98
  sleep 1
end"""

    return StandardSegment(
        id="modern_deep_house_kick_02",
        name="Modern Deep House Kick v2",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.KICK_PATTERN,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="modern_kick",
            setup_code="use_bpm 124"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 0, 0, 1, 0, 0, 0],
            subdivisions=8,
            sample=":bd_haus",
            amp_range=(1.2, 1.4),
            effects={
                "cutoff_range": (85, 90),
                "rate_variation": 0.98
            },
            duration_bars=2,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2024-09-20_DeepHouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "house", "modern"],
            mood_tags=["driving", "powerful", "tight", "punchy"],
            element_tags=["kick", "four_on_floor", "foundation", "modern"],
            suitable_sections=["verse", "drop", "peak"],
            energy_level=0.75,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 1.5,
                "mid": 0.9,
                "high": 0.8
            }
        ),
        math_adaptable=True,
        variations=[
            {"rate_range": (0.95, 1.05)},
            {"cutoff_range": (80, 95)}
        ]
    )


def extract_dnb_reese_bass():
    """提取DnB Reese Bass - 来自2024-06-06_dnb.rb"""
    
    code = """use_bpm 174
use_synth :tb303

live_loop :reese_bass do
  with_fx :lpf, cutoff: 70 do
    with_fx :distortion, distort: 0.3 do
      play :c2, amp: 0.8, release: 0.5, cutoff: rrand(50, 80), res: 0.9
      sleep 0.5
      play :c2, amp: 0.6, release: 0.3, cutoff: rrand(50, 80), res: 0.9
      sleep 0.25
      play :f1, amp: 0.7, release: 0.3, cutoff: rrand(50, 80), res: 0.9
      sleep 0.25
    end
  end
end"""

    return StandardSegment(
        id="dnb_reese_bass_01",
        name="DnB Reese Bass",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.BASS_LINE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="reese_bass",
            setup_code="use_bpm 174\nuse_synth :tb303"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "F1"],
            root_note="C2",
            synth=":tb303",
            amp_range=(0.6, 0.8),
            effects={
                "lpf": {"cutoff": 70},
                "distortion": {"distort": 0.3},
                "cutoff_range": (50, 80),
                "res": 0.9
            },
            duration_bars=1,
            bpm=174
        ),
        metadata=SegmentMetadata(
            source_file="2024-06-06_dnb.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["dnb", "drum_and_bass", "neurofunk", "jungle"],
            mood_tags=["aggressive", "intense", "dark", "powerful"],
            element_tags=["reese_bass", "bass", "distorted", "modulated"],
            suitable_sections=["drop", "peak", "high_energy"],
            energy_level=0.9,
            complexity=0.8,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 1.0,
                "high": 0.9
            }
        ),
        math_adaptable=True,
        variations=[
            {"cutoff_modulation": "lfo"},
            {"distortion_range": (0.2, 0.5)}
        ]
    )


def extract_cyberpunk_arpeggio():
    """提取赛博朋克琶音 - 来自2024-01-20_cyberpunk.rb"""
    
    code = """use_bpm 138
use_synth :pulse

live_loop :cyber_arp do
  with_fx :echo, phase: 0.375, decay: 6 do
    with_fx :reverb, room: 0.7 do
      with_fx :bitcrusher, bits: 12, mix: 0.2 do
        notes = (scale :c4, :minor, num_octaves: 2)
        16.times do |i|
          play notes[i % notes.length], 
               amp: 0.5, 
               release: 0.15, 
               pulse_width: rrand(0.3, 0.7),
               cutoff: rrand(80, 120)
          sleep 0.125
        end
      end
    end
  end
end"""

    return StandardSegment(
        id="cyberpunk_arpeggio_pulse_01",
        name="Cyberpunk Pulse Arpeggio",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ARPEGGIO,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cyber_arp",
            setup_code="use_bpm 138\nuse_synth :pulse"
        ),
        musical_params=MusicalParameters(
            scale="C_minor",
            root_note="C4",
            pattern=[1]*16,
            subdivisions=16,
            synth=":pulse",
            amp_range=(0.4, 0.6),
            effects={
                "echo": {"phase": 0.375, "decay": 6},
                "reverb": {"room": 0.7},
                "bitcrusher": {"bits": 12, "mix": 0.2},
                "pulse_width_range": (0.3, 0.7),
                "cutoff_range": (80, 120)
            },
            duration_bars=2,
            bpm=138
        ),
        metadata=SegmentMetadata(
            source_file="2024-01-20_cyberpunk.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["cyberpunk", "synthwave", "techno", "futuristic"],
            mood_tags=["dark", "mechanical", "dystopian", "driving"],
            element_tags=["arpeggio", "pulse", "modulated", "digital"],
            suitable_sections=["build_up", "verse", "peak"],
            energy_level=0.8,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"pattern_algorithm": "fibonacci"},
            {"pulse_width_modulation": "lfo"}
        ]
    )


def extract_deep_house_piano_stabs():
    """提取Deep House钢琴Stab - 来自2024-04-18_deephouse.rb"""
    
    code = """use_bpm 124
use_synth :piano

live_loop :piano_stabs do
  with_fx :reverb, room: 0.7, mix: 0.6 do
    with_fx :hpf, cutoff: 60 do
      play_chord [:c4, :e4, :g4], amp: 0.6, release: 0.8
      sleep 2
      play_chord [:f3, :a3, :c4], amp: 0.55, release: 0.8
      sleep 2
      play_chord [:g3, :b3, :d4], amp: 0.58, release: 0.8
      sleep 2
      play_chord [:a3, :c4, :e4], amp: 0.57, release: 0.8
      sleep 2
    end
  end
end"""

    return StandardSegment(
        id="deep_house_piano_stabs_01",
        name="Deep House Piano Stabs",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.CHORD_PROGRESSION,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="piano_stabs",
            setup_code="use_bpm 124\nuse_synth :piano"
        ),
        musical_params=MusicalParameters(
            notes=["C4", "E4", "G4", "F3", "A3", "C4", "G3", "B3", "D4", "A3", "C4", "E4"],
            scale="C_major",
            root_note="C4",
            synth=":piano",
            amp_range=(0.55, 0.6),
            effects={
                "reverb": {"room": 0.7, "mix": 0.6},
                "hpf": {"cutoff": 60}
            },
            duration_bars=8,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2024-04-18_deephouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "house", "piano_house"],
            mood_tags=["soulful", "warm", "emotional", "groovy"],
            element_tags=["piano", "chords", "stabs", "harmonic"],
            suitable_sections=["verse", "breakdown", "build_up"],
            energy_level=0.65,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 1.3,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"progression_type": "I-IV-V-vi"},
            {"voicing": "jazz"}
        ]
    )


def extract_kpop_synth_hook():
    """提取K-pop合成器Hook - 来自2024-10-07_OMG-NewJeans.rb"""
    
    code = """use_bpm 130
use_synth :prophet

live_loop :kpop_hook do
  with_fx :slicer, phase: 0.25, wave: 1 do
    with_fx :reverb, room: 0.5, mix: 0.4 do
      play_pattern_timed [:e5, :g5, :e5, :d5, :c5, :d5, :e5, :g5],
                         [0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5],
                         amp: 0.65, release: 0.3, cutoff: 110
    end
  end
end"""

    return StandardSegment(
        id="kpop_synth_hook_01",
        name="K-pop Synth Hook",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.HOOK,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="kpop_hook",
            setup_code="use_bpm 130\nuse_synth :prophet"
        ),
        musical_params=MusicalParameters(
            notes=["E5", "G5", "D5", "C5"],
            scale="C_major",
            root_note="E5",
            synth=":prophet",
            amp_range=(0.6, 0.7),
            effects={
                "slicer": {"phase": 0.25, "wave": 1},
                "reverb": {"room": 0.5, "mix": 0.4},
                "cutoff": 110
            },
            duration_bars=2,
            bpm=130
        ),
        metadata=SegmentMetadata(
            source_file="2024-10-07_OMG-NewJeans.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["kpop", "pop", "dance", "modern"],
            mood_tags=["catchy", "bright", "youthful", "fun"],
            element_tags=["hook", "lead", "synth", "melodic"],
            suitable_sections=["chorus", "hook", "drop"],
            energy_level=0.8,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.3,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"slicer_phase_range": (0.125, 0.5)},
            {"melody_variations": "call_response"}
        ]
    )


def extract_deep_house_sub_bass():
    """提取Deep House Sub Bass - 来自2024-02-22_DeepHouse.rb"""
    
    code = """use_bpm 122
use_synth :sine

live_loop :sub_bass do
  with_fx :compressor, threshold: 0.4 do
    play :c1, amp: 1.6, release: 1.5, attack: 0.01
    sleep 2
    play :c1, amp: 1.3, release: 0.8, attack: 0.01
    sleep 1
    play :f1, amp: 1.4, release: 0.8, attack: 0.01
    sleep 1
  end
end"""

    return StandardSegment(
        id="deep_house_sub_bass_02",
        name="Deep House Sub Bass v2",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.SUB_BASS,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="sub_bass",
            setup_code="use_bpm 122\nuse_synth :sine"
        ),
        musical_params=MusicalParameters(
            notes=["C1", "F1"],
            root_note="C1",
            pattern=[1, 0, 0, 0, 1, 0, 1, 0],
            synth=":sine",
            amp_range=(1.3, 1.6),
            effects={"compressor": {"threshold": 0.4}},
            duration_bars=4,
            bpm=122
        ),
        metadata=SegmentMetadata(
            source_file="2024-02-22_DeepHouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "house", "minimal"],
            mood_tags=["deep", "powerful", "foundation", "solid"],
            element_tags=["sub_bass", "foundation", "low_end", "compressed"],
            suitable_sections=["drop", "peak", "verse"],
            energy_level=0.7,
            complexity=0.3,
            car_audio_optimization={
                "bass_boost": 1.6,
                "mid": 0.8,
                "high": 0.7
            }
        ),
        math_adaptable=True,
        variations=[
            {"amp_envelope": "dynamic"},
            {"pattern_variations": True}
        ]
    )


def extract_cyberpunk_impact():
    """提取赛博朋克冲击音效 - 来自2024-03-08_CyberPunk.rb"""
    
    code = """use_bpm 140

live_loop :cyber_impact do
  with_fx :reverb, room: 0.8 do
    with_fx :distortion, distort: 0.5 do
      sample :bd_boom, amp: 1.5, rate: 0.7
      sample :elec_blip2, amp: 0.8, rate: 0.5
      sleep 8
    end
  end
end"""

    return StandardSegment(
        id="cyberpunk_impact_fx_01",
        name="Cyberpunk Impact FX",
        category=SegmentCategory.FX,
        sub_type=SegmentSubType.IMPACT,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cyber_impact",
            setup_code="use_bpm 140"
        ),
        musical_params=MusicalParameters(
            sample=":bd_boom, :elec_blip2",
            amp_range=(0.8, 1.5),
            effects={
                "reverb": {"room": 0.8},
                "distortion": {"distort": 0.5},
                "rate_range": (0.5, 0.7)
            },
            duration_bars=8,
            bpm=140
        ),
        metadata=SegmentMetadata(
            source_file="2024-03-08_CyberPunk.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["cyberpunk", "industrial", "electronic"],
            mood_tags=["powerful", "dramatic", "cinematic", "intense"],
            element_tags=["impact", "fx", "transition", "boom"],
            suitable_sections=["transition", "drop", "impact_point"],
            energy_level=0.9,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 1.5,
                "mid": 1.1,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"layering": "multiple_samples"},
            {"timing_variations": True}
        ]
    )


# 主函数：批量生成并保存
def generate_all_segments_2024():
    """生成2024文件夹的所有Segment并保存"""
    
    segments = [
        extract_cyberpunk_synth_lead(),
        extract_slow_tempo_ambient(),
        extract_newjeans_pop_bass(),
        extract_modern_deep_house_kick(),
        extract_dnb_reese_bass(),
        extract_cyberpunk_arpeggio(),
        extract_deep_house_piano_stabs(),
        extract_kpop_synth_hook(),
        extract_deep_house_sub_bass(),
        extract_cyberpunk_impact()
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
    
    # 生成详细统计
    category_count = {}
    for segment in segments:
        cat = segment.category.value
        category_count[cat] = category_count.get(cat, 0) + 1
    
    print("\n分类统计:")
    for cat, count in sorted(category_count.items()):
        print(f"  {cat}: {count} 个")
    
    # 风格标签统计
    genre_count = {}
    for segment in segments:
        for genre in segment.metadata.genre_tags:
            genre_count[genre] = genre_count.get(genre, 0) + 1
    
    print("\n2024年风格特色（Top 5）:")
    for genre, count in sorted(genre_count.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {genre}: {count} 次")
    
    # 能量等级分析
    energy_levels = [s.metadata.energy_level for s in segments]
    print(f"\n能量等级范围: {min(energy_levels):.2f} - {max(energy_levels):.2f}")
    print(f"平均能量等级: {sum(energy_levels)/len(energy_levels):.2f}")
    
    # BPM范围统计
    bpms = [s.musical_params.bpm for s in segments if s.musical_params.bpm]
    if bpms:
        print(f"\nBPM范围: {min(bpms)} - {max(bpms)}")
        print(f"平均BPM: {sum(bpms)/len(bpms):.0f}")
    
    return segments


if __name__ == "__main__":
    segments = generate_all_segments_2024()