"""
批量提取2025年及特殊文件夹的高质量Segment素材
包含：2025主文件夹、SonicPI-Examples算法音乐、WIP实验作品
重点：最新Deep House、算法生成音乐、数学模式
"""

from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


# ============= 2025年Deep House系列 =============

def extract_2025_deep_house_evolved():
    """提取2025进化版Deep House - 来自2025-08-09-DeepHouse.rb"""
    
    code = """use_bpm 124
use_synth :fm

live_loop :evolved_bass do
  with_fx :lpf, cutoff: 88 do
    with_fx :compressor, threshold: 0.3 do
      play :c2, amp: 1.0, release: 0.9, divisor: 1.8, depth: 2.8
      sleep 1
      play :c2, amp: 0.7, release: 0.4, divisor: 1.8, depth: 2.8
      sleep 0.5
      play :g1, amp: 0.8, release: 0.5, divisor: 1.8, depth: 2.8
      sleep 0.5
      play :a1, amp: 0.75, release: 0.4, divisor: 1.8, depth: 2.8
      sleep 0.5
      play :f1, amp: 0.7, release: 0.3, divisor: 1.8, depth: 2.8
      sleep 0.5
    end
  end
end"""

    return StandardSegment(
        id="deep_house_evolved_2025_01",
        name="Deep House Evolved 2025",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.BASS_LINE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="evolved_bass",
            setup_code="use_bpm 124\nuse_synth :fm"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "G1", "A1", "F1"],
            root_note="C2",
            pattern=[1, 0, 1, 1, 1, 0, 1, 0],
            synth=":fm",
            amp_range=(0.7, 1.0),
            effects={
                "lpf": {"cutoff": 88},
                "compressor": {"threshold": 0.3},
                "divisor": 1.8,
                "depth": 2.8
            },
            duration_bars=4,
            bpm=124
        ),
        metadata=SegmentMetadata(
            source_file="2025-08-09-DeepHouse.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["deep_house", "house", "2025", "evolved"],
            mood_tags=["sophisticated", "mature", "groovy", "refined"],
            element_tags=["bass", "fm", "melodic", "compressed"],
            suitable_sections=["verse", "drop", "peak"],
            energy_level=0.75,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 1.35,
                "mid": 1.0,
                "high": 0.9
            }
        ),
        math_adaptable=True,
        variations=[
            {"divisor_range": (1.5, 2.5)},
            {"depth_range": (2.5, 3.5)},
            {"progression_variations": True}
        ]
    )


def extract_dnb_coastal_fragrance():
    """提取DnB Coastal Fragrance - 来自2025-01-13_dnb-Coastal-Fragrance.rb"""
    
    code = """use_bpm 174

live_loop :coastal_break do
  sample :loop_amen, amp: 0.75, beat_stretch: 2, rate: 1.02
  sleep 2
end

live_loop :coastal_bass do
  sync :coastal_break
  use_synth :tb303
  with_fx :lpf, cutoff: 75 do
    play :c2, amp: 0.75, release: 0.3, cutoff: rrand(60, 90), res: 0.85
    sleep 0.25
    play :c2, amp: 0.55, release: 0.15, cutoff: rrand(60, 90), res: 0.85
    sleep 0.25
    play :d2, amp: 0.65, release: 0.2, cutoff: rrand(60, 90), res: 0.85
    sleep 0.25
    play :c2, amp: 0.6, release: 0.15, cutoff: rrand(60, 90), res: 0.85
    sleep 0.25
  end
end"""

    return StandardSegment(
        id="dnb_coastal_fragrance_01",
        name="DnB Coastal Fragrance",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.BREAKBEAT,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="coastal_break",
            dependencies=["coastal_bass"],
            setup_code="use_bpm 174"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "D2"],
            root_note="C2",
            sample=":loop_amen",
            synth=":tb303",
            amp_range=(0.55, 0.75),
            effects={
                "beat_stretch": 2,
                "rate": 1.02,
                "lpf": {"cutoff": 75},
                "cutoff_range": (60, 90),
                "res": 0.85
            },
            duration_bars=2,
            bpm=174
        ),
        metadata=SegmentMetadata(
            source_file="2025-01-13_dnb-Coastal-Fragrance.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["dnb", "drum_and_bass", "liquid", "atmospheric"],
            mood_tags=["flowing", "atmospheric", "coastal", "fresh"],
            element_tags=["breakbeat", "amen", "bass", "liquid_dnb"],
            suitable_sections=["drop", "peak", "groove"],
            energy_level=0.85,
            complexity=0.85,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 1.1,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"rate_modulation": "subtle"},
            {"cutoff_lfo": True}
        ]
    )


# ============= 算法音乐系列 =============

def extract_math_ocean_waves():
    """提取数学海浪 - 来自SonicPI-Examples-1/Math_Ocean_Waves.rb"""
    
    code = """use_bpm 100

live_loop :math_waves do
  use_synth :sine
  with_fx :reverb, room: 0.9, mix: 0.7 do
    with_fx :echo, phase: 1.5, decay: 8 do
      # 使用数学函数生成波浪般的音高
      wave_height = Math.sin(tick * 0.1) * 12
      note = :c3 + wave_height.round
      
      play note, amp: 0.3 + (Math.cos(tick * 0.05) * 0.15), 
           release: 2, attack: 0.5
      
      sleep_time = 0.5 + (Math.sin(tick * 0.15) * 0.3)
      sleep sleep_time
    end
  end
end"""

    return StandardSegment(
        id="math_ocean_waves_01",
        name="Mathematical Ocean Waves",
        category=SegmentCategory.TEXTURE,
        sub_type=SegmentSubType.SYNTH_TEXTURE,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="math_waves",
            setup_code="use_bpm 100"
        ),
        musical_params=MusicalParameters(
            scale="C_chromatic",
            root_note="C3",
            synth=":sine",
            amp_range=(0.15, 0.45),
            effects={
                "reverb": {"room": 0.9, "mix": 0.7},
                "echo": {"phase": 1.5, "decay": 8},
                "math_function": "sine_wave_modulation"
            },
            duration_bars=8,
            bpm=100
        ),
        metadata=SegmentMetadata(
            source_file="SonicPI-Examples-1/Math_Ocean_Waves.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["algorithmic", "generative", "ambient", "mathematical"],
            mood_tags=["flowing", "natural", "evolving", "hypnotic"],
            element_tags=["algorithm", "sine_wave", "generative", "ocean"],
            suitable_sections=["ambient_section", "intro", "experimental"],
            energy_level=0.3,
            complexity=0.9,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.0,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"wave_function": "cosine"},
            {"wave_frequency": "adjustable"},
            {"amplitude_modulation": "dynamic"}
        ]
    )


def extract_math_symphony():
    """提取数学交响乐 - 来自SonicPI-Examples-1/math_symphony.rb"""
    
    code = """use_bpm 120

# 使用斐波那契数列生成音符
define :fibonacci do |n|
  return n if n <= 1
  fibonacci(n-1) + fibonacci(n-2)
end

live_loop :fib_melody do
  use_synth :prophet
  with_fx :reverb, room: 0.7 do
    8.times do |i|
      fib_num = fibonacci(i % 8)
      note = :c4 + (fib_num % 12)
      
      play note, amp: 0.4, release: 0.5, cutoff: 90 + (fib_num % 40)
      sleep 0.5
    end
  end
end"""

    return StandardSegment(
        id="math_symphony_fibonacci_01",
        name="Mathematical Symphony (Fibonacci)",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ARPEGGIO,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="fib_melody",
            setup_code="use_bpm 120"
        ),
        musical_params=MusicalParameters(
            scale="C_chromatic",
            root_note="C4",
            pattern=[1]*8,
            subdivisions=8,
            synth=":prophet",
            amp_range=(0.35, 0.45),
            effects={
                "reverb": {"room": 0.7},
                "cutoff_range": (90, 130),
                "algorithm": "fibonacci"
            },
            duration_bars=4,
            bpm=120
        ),
        metadata=SegmentMetadata(
            source_file="SonicPI-Examples-1/math_symphony.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["algorithmic", "mathematical", "generative", "experimental"],
            mood_tags=["intellectual", "evolving", "mathematical", "complex"],
            element_tags=["fibonacci", "algorithm", "melodic", "pattern"],
            suitable_sections=["experimental", "interlude", "build_up"],
            energy_level=0.5,
            complexity=0.95,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.2,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"sequence_type": "lucas_numbers"},
            {"sequence_type": "prime_numbers"},
            {"modulo_range": (8, 16)}
        ]
    )


def extract_idm_breakbeat():
    """提取IDM Breakbeat - 来自SonicPI-Examples-1/IDM_Breakbeat.rb"""
    
    code = """use_bpm 160

live_loop :idm_break do
  with_fx :bitcrusher, bits: rrand_i(6, 12), mix: 0.4 do
    with_fx :reverb, room: 0.6 do
      # 不规则的Breakbeat模式
      pattern = [1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1]
      
      16.times do |i|
        if pattern[i] == 1
          sample [:drum_snare_soft, :drum_snare_hard, :elec_snare].choose,
                 amp: rrand(0.4, 0.7),
                 rate: rrand(0.9, 1.1)
        end
        sleep 0.125
      end
    end
  end
end"""

    return StandardSegment(
        id="idm_breakbeat_01",
        name="IDM Breakbeat",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.BREAKBEAT,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="idm_break",
            setup_code="use_bpm 160"
        ),
        musical_params=MusicalParameters(
            pattern=[1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1],
            subdivisions=16,
            sample=":drum_snare_soft, :drum_snare_hard, :elec_snare",
            amp_range=(0.4, 0.7),
            effects={
                "bitcrusher": {"bits_range": (6, 12), "mix": 0.4},
                "reverb": {"room": 0.6},
                "rate_range": (0.9, 1.1)
            },
            duration_bars=2,
            bpm=160
        ),
        metadata=SegmentMetadata(
            source_file="SonicPI-Examples-1/IDM_Breakbeat.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["idm", "breakbeat", "glitch", "electronic"],
            mood_tags=["complex", "unpredictable", "experimental", "glitchy"],
            element_tags=["breakbeat", "glitch", "irregular", "lo-fi"],
            suitable_sections=["experimental", "breakdown", "transition"],
            energy_level=0.7,
            complexity=0.9,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"pattern_generation": "euclidean"},
            {"randomization": "controlled"}
        ]
    )


def extract_cloud_beat():
    """提取云端节奏 - 来自SonicPI-Examples-2/Cloud_beat.rb"""
    
    code = """use_bpm 128

live_loop :cloud_texture do
  use_synth :hollow
  with_fx :reverb, room: 0.95, mix: 0.8 do
    with_fx :echo, phase: 0.75, decay: 8 do
      with_fx :lpf, cutoff: rrand(70, 100) do
        play_chord (chord :c3, :minor7), 
                   amp: rrand(0.2, 0.4),
                   attack: 2,
                   sustain: 4,
                   release: 2
        sleep 8
      end
    end
  end
end

live_loop :cloud_kick do
  sample :bd_fat, amp: 0.8, cutoff: 80
  sleep 1
end"""

    return StandardSegment(
        id="cloud_beat_texture_01",
        name="Cloud Beat Texture",
        category=SegmentCategory.ATMOSPHERE,
        sub_type=SegmentSubType.AMBIENT_LAYER,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cloud_texture",
            dependencies=["cloud_kick"],
            setup_code="use_bpm 128"
        ),
        musical_params=MusicalParameters(
            notes=["C3", "E♭3", "G3", "B♭3"],
            scale="C_minor",
            root_note="C3",
            synth=":hollow",
            amp_range=(0.2, 0.4),
            effects={
                "reverb": {"room": 0.95, "mix": 0.8},
                "echo": {"phase": 0.75, "decay": 8},
                "lpf": {"cutoff_range": (70, 100)}
            },
            duration_bars=8,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="SonicPI-Examples-2/Cloud_beat.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "cloud", "atmospheric", "house"],
            mood_tags=["ethereal", "floating", "dreamy", "spacious"],
            element_tags=["texture", "atmospheric", "chord", "reverb"],
            suitable_sections=["intro", "breakdown", "ambient_section"],
            energy_level=0.4,
            complexity=0.5,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.0,
                "high": 1.1
            }
        ),
        math_adaptable=True,
        variations=[
            {"chord_type": "sus4"},
            {"reverb_room_range": (0.8, 1.0)}
        ]
    )


def extract_time_machine():
    """提取时光机器 - 来自SonicPI-Examples-2/Time_machine.rb"""
    
    code = """use_bpm 140

live_loop :time_warp do
  use_synth :tb303
  with_fx :reverb, room: 0.8 do
    with_fx :pitch_shift, pitch_slide: 4 do |fx|
      with_fx :slicer, phase: 0.125, wave: 3 do
        play :c3, amp: 0.6, release: 2, cutoff: 100, res: 0.8
        control fx, pitch: 12
        sleep 4
        control fx, pitch: -12
        sleep 4
      end
    end
  end
end"""

    return StandardSegment(
        id="time_machine_warp_01",
        name="Time Machine Warp",
        category=SegmentCategory.FX,
        sub_type=SegmentSubType.TRANSITION,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="time_warp",
            setup_code="use_bpm 140"
        ),
        musical_params=MusicalParameters(
            notes=["C3"],
            root_note="C3",
            synth=":tb303",
            amp_range=(0.5, 0.7),
            effects={
                "reverb": {"room": 0.8},
                "pitch_shift": {"slide": 4, "range": (-12, 12)},
                "slicer": {"phase": 0.125, "wave": 3},
                "cutoff": 100,
                "res": 0.8
            },
            duration_bars=8,
            bpm=140
        ),
        metadata=SegmentMetadata(
            source_file="SonicPI-Examples-2/Time_machine.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["experimental", "sci-fi", "transition", "fx"],
            mood_tags=["temporal", "sci-fi", "warping", "dramatic"],
            element_tags=["pitch_shift", "transition", "fx", "time_warp"],
            suitable_sections=["transition", "build_up", "fx_section"],
            energy_level=0.6,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 1.1,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"pitch_range": "extended"},
            {"slide_duration": "variable"}
        ]
    )


# ============= WIP实验作品 =============

def extract_perfume_plasma():
    """提取Perfume Plasma风格 - 来自WIP/2025-01-18_perfume_plasma.rb"""
    
    code = """use_bpm 135
use_synth :blade

live_loop :plasma_lead do
  with_fx :slicer, phase: 0.0625, wave: 3 do
    with_fx :reverb, room: 0.6, mix: 0.5 do
      with_fx :bitcrusher, bits: 11, mix: 0.25 do
        play_pattern_timed [:e5, :g5, :b5, :d6, :b5, :g5, :e5, :d5],
                           [0.125]*8,
                           amp: 0.65, release: 0.15, cutoff: 115
      end
    end
  end
end"""

    return StandardSegment(
        id="perfume_plasma_lead_01",
        name="Perfume Plasma Lead",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.LEAD_MELODY,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="plasma_lead",
            setup_code="use_bpm 135\nuse_synth :blade"
        ),
        musical_params=MusicalParameters(
            notes=["E5", "G5", "B5", "D6"],
            scale="E_minor",
            root_note="E5",
            pattern=[1]*8,
            subdivisions=8,
            synth=":blade",
            amp_range=(0.6, 0.7),
            effects={
                "slicer": {"phase": 0.0625, "wave": 3},
                "reverb": {"room": 0.6, "mix": 0.5},
                "bitcrusher": {"bits": 11, "mix": 0.25},
                "cutoff": 115
            },
            duration_bars=1,
            bpm=135
        ),
        metadata=SegmentMetadata(
            source_file="WIP/2025-01-18_perfume_plasma.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["jpop", "electro_pop", "perfume_style", "modern"],
            mood_tags=["futuristic", "bright", "energetic", "digital"],
            element_tags=["lead", "sliced", "high_energy", "jpop"],
            suitable_sections=["chorus", "drop", "hook"],
            energy_level=0.85,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.3,
                "high": 1.4
            }
        ),
        math_adaptable=True,
        variations=[
            {"slicer_phase": "variable"},
            {"bit_depth_modulation": True}
        ]
    )


def extract_flying_city_plan():
    """提取空飛ぶ都市計画 - 来自WIP/空飛ぶ都市計画.rb"""
    
    code = """use_bpm 128
use_synth :prophet

live_loop :flying_city do
  with_fx :reverb, room: 0.85, mix: 0.7 do
    with_fx :echo, phase: 0.5, decay: 6 do
      # 飞行城市主题：上升的音阶
      scale_notes = (scale :c4, :major_pentatonic, num_octaves: 3)
      
      8.times do |i|
        play scale_notes[i * 2], 
             amp: 0.5, 
             release: 0.5,
             cutoff: 80 + (i * 5)
        sleep 0.25
      end
    end
  end
end"""

    return StandardSegment(
        id="flying_city_plan_01",
        name="Flying City Plan (空飛ぶ都市計画)",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ARPEGGIO,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="flying_city",
            setup_code="use_bpm 128\nuse_synth :prophet"
        ),
        musical_params=MusicalParameters(
            scale="C_major_pentatonic",
            root_note="C4",
            pattern=[1]*8,
            subdivisions=8,
            synth=":prophet",
            amp_range=(0.45, 0.55),
            effects={
                "reverb": {"room": 0.85, "mix": 0.7},
                "echo": {"phase": 0.5, "decay": 6},
                "cutoff_progression": (80, 120)
            },
            duration_bars=2,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="WIP/空飛ぶ都市計画.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["cinematic", "jpop", "atmospheric", "sci-fi"],
            mood_tags=["soaring", "futuristic", "hopeful", "expansive"],
            element_tags=["arpeggio", "ascending", "cinematic", "japanese"],
            suitable_sections=["build_up", "chorus", "cinematic"],
            energy_level=0.7,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"scale_direction": "ascending/descending"},
            {"interval_pattern": "adjustable"}
        ]
    )


# 主函数：批量生成并保存
def generate_all_segments_2025_complete():
    """生成2025年及特殊文件夹的所有Segment并保存"""
    
    segments = [
        # 2025年主作品
        extract_2025_deep_house_evolved(),
        extract_dnb_coastal_fragrance(),
        
        # 算法音乐系列
        extract_math_ocean_waves(),
        extract_math_symphony(),
        extract_idm_breakbeat(),
        extract_cloud_beat(),
        extract_time_machine(),
        
        # WIP实验作品
        extract_perfume_plasma(),
        extract_flying_city_plan()
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
    
    # 详细统计
    print("\n" + "="*60)
    print("📊 2025年完整素材库统计报告")
    print("="*60)
    
    # 分类统计
    category_count = {}
    for segment in segments:
        cat = segment.category.value
        category_count[cat] = category_count.get(cat, 0) + 1
    
    print("\n【分类分布】")
    for cat, count in sorted(category_count.items()):
        print(f"  {cat}: {count} 个")
    
    # 来源统计
    source_count = {
        "2025主作品": 2,
        "算法音乐": 5,
        "WIP实验": 2
    }
    
    print("\n【来源分布】")
    for source, count in source_count.items():
        print(f"  {source}: {count} 个")
    
    # 风格标签统计
    genre_count = {}
    for segment in segments:
        for genre in segment.metadata.genre_tags:
            genre_count[genre] = genre_count.get(genre, 0) + 1
    
    print("\n【风格特色（Top 8）】")
    for genre, count in sorted(genre_count.items(), key=lambda x: x[1], reverse=True)[:8]:
        print(f"  {genre}: {count} 次")
    
    # 能量等级分析
    energy_levels = [s.metadata.energy_level for s in segments]
    print(f"\n【能量等级】")
    print(f"  范围: {min(energy_levels):.2f} - {max(energy_levels):.2f}")
    print(f"  平均: {sum(energy_levels)/len(energy_levels):.2f}")
    
    # 复杂度分析
    complexities = [s.metadata.complexity for s in segments]
    print(f"\n【复杂度】")
    print(f"  范围: {min(complexities):.2f} - {max(complexities):.2f}")
    print(f"  平均: {sum(complexities)/len(complexities):.2f}")
    
    # BPM统计
    bpms = [s.musical_params.bpm for s in segments if s.musical_params.bpm]
    if bpms:
        print(f"\n【BPM范围】")
        print(f"  最低: {min(bpms)} BPM")
        print(f"  最高: {max(bpms)} BPM")
        print(f"  平均: {sum(bpms)/len(bpms):.0f} BPM")
    
    # 数学适应性统计
    math_count = sum(1 for s in segments if s.math_adaptable)
    print(f"\n【数学适应性】")
    print(f"  支持数学变换: {math_count}/{len(segments)} 个 ({math_count/len(segments)*100:.0f}%)")
    
    print("\n" + "="*60)
    
    return segments


if __name__ == "__main__":
    segments = generate_all_segments_2025_complete()