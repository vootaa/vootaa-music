"""
从Draft_文件夹提取高价值Segment素材
重点：车载场景原型、宇宙主题数学音乐、EDM演化系列
"""

from datetime import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from StandardSegment import (
    StandardSegment, SonicPiCode, MusicalParameters, SegmentMetadata,
    SegmentCategory, SegmentSubType
)


# ============= cardj_edm 车载场景系列 =============

def extract_dawn_ignition_main_theme():
    """提取Dawn Ignition主题 - 来自cardj_edm/Dawn_Ignition.rb"""
    
    code = """use_bpm 118

# Dawn Ignition - 黎明启动主题
live_loop :dawn_theme do
  use_synth :blade
  with_fx :reverb, room: 0.7, mix: 0.6 do
    with_fx :echo, phase: 0.75, decay: 4 do
      notes = (scale :c4, :major_pentatonic, num_octaves: 2)
      
      # 上升的旋律线 - 象征太阳升起
      8.times do |i|
        play notes[i], 
             amp: 0.3 + (i * 0.05), 
             release: 0.5,
             cutoff: 80 + (i * 5)
        sleep 0.5
      end
    end
  end
end

live_loop :dawn_bass do
  use_synth :fm
  with_fx :lpf, cutoff: 85 do
    play :c2, amp: 0.8, release: 0.8, divisor: 2, depth: 3
    sleep 1
  end
end"""

    return StandardSegment(
        id="dawn_ignition_main_theme_01",
        name="Dawn Ignition Main Theme",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.LEAD_MELODY,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="dawn_theme",
            dependencies=["dawn_bass"],
            setup_code="use_bpm 118"
        ),
        musical_params=MusicalParameters(
            scale="C_major_pentatonic",
            root_note="C4",
            pattern=[1]*8,
            subdivisions=8,
            synth=":blade",
            amp_range=(0.3, 0.7),
            effects={
                "reverb": {"room": 0.7, "mix": 0.6},
                "echo": {"phase": 0.75, "decay": 4},
                "cutoff_progression": (80, 120)
            },
            duration_bars=4,
            bpm=118
        ),
        metadata=SegmentMetadata(
            source_file="Draft_/cardj_edm/Dawn_Ignition.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["edm", "progressive", "car_audio", "sunrise"],
            mood_tags=["hopeful", "awakening", "ascending", "energizing"],
            element_tags=["lead", "melodic", "sunrise_theme", "progressive", "dawn_ignition"],
            suitable_sections=["intro", "build_up", "dawn_section"],
            energy_level=0.6,
            complexity=0.6,
            car_audio_optimization={
                "bass_boost": 1.0,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"scale_progression": "ascending"},
            {"amplitude_crescendo": True},
            {"cutoff_automation": "linear"}
        ]
    )


def extract_urban_velocity_groove():
    """提取Urban Velocity律动 - 来自cardj_edm/Urban_Velocity.rb"""
    
    code = """use_bpm 128

# Urban Velocity - 城市速度律动
live_loop :urban_kick do
  sample :bd_haus, amp: 1.3, cutoff: 90
  sleep 1
end

live_loop :urban_bass do
  sync :urban_kick
  use_synth :fm
  with_fx :lpf, cutoff: 88 do
    play :c2, amp: 1.0, release: 0.8, divisor: 2, depth: 3.5
    sleep 0.5
    play :c2, amp: 0.7, release: 0.3, divisor: 2, depth: 3.5
    sleep 0.25
    play :d2, amp: 0.8, release: 0.3, divisor: 2, depth: 3.5
    sleep 0.25
  end
end

live_loop :urban_hats do
  sync :urban_kick
  8.times do |i|
    sample :drum_cymbal_closed, amp: (i % 2 == 0) ? 0.4 : 0.25, rate: 1.1
    sleep 0.25
  end
end"""

    return StandardSegment(
        id="urban_velocity_groove_01",
        name="Urban Velocity Groove",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.FULL_DRUM_KIT,  # ✅ 改为 FULL_DRUM_KIT
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="urban_kick",
            dependencies=["urban_bass", "urban_hats"],
            setup_code="use_bpm 128"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "D2"],
            root_note="C2",
            pattern=[1, 0, 0, 0, 1, 0, 0, 0],
            subdivisions=8,
            sample=":bd_haus, :drum_cymbal_closed",
            synth=":fm",
            amp_range=(0.7, 1.3),
            effects={
                "lpf": {"cutoff": 88},
                "divisor": 2,
                "depth": 3.5
            },
            duration_bars=2,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="Draft_/cardj_edm/Urban_Velocity.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["house", "urban", "driving", "car_audio"],
            mood_tags=["energetic", "urban", "driving", "rhythmic"],
            element_tags=["full_beat", "kick", "bass", "hihat", "synced", "urban_pulse"],
            suitable_sections=["drop", "verse", "peak"],
            energy_level=0.8,
            complexity=0.7,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 1.1,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"groove_variations": True},
            {"syncopation": "adjustable"}
        ]
    )


def extract_midnight_horizon_pad():
    """提取Midnight Horizon氛围 - 来自cardj_edm/Midnight_Horizon.rb"""
    
    code = """use_bpm 115

# Midnight Horizon - 午夜地平线氛围
live_loop :midnight_pad do
  use_synth :hollow
  with_fx :reverb, room: 0.9, mix: 0.8 do
    with_fx :echo, phase: 1.5, decay: 8 do
      play_chord [:c3, :e3, :g3, :b3], 
                 amp: 0.35, 
                 attack: 4, 
                 sustain: 8, 
                 release: 4
      sleep 16
      
      play_chord [:a2, :c3, :e3, :g3], 
                 amp: 0.32, 
                 attack: 4, 
                 sustain: 8, 
                 release: 4
      sleep 16
    end
  end
end"""

    return StandardSegment(
        id="midnight_horizon_pad_01",
        name="Midnight Horizon Pad",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.PAD,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="midnight_pad",
            setup_code="use_bpm 115\nuse_synth :hollow"
        ),
        musical_params=MusicalParameters(
            notes=["C3", "E3", "G3", "B3", "A2", "C3", "E3", "G3"],
            scale="C_major",
            root_note="C3",
            synth=":hollow",
            amp_range=(0.32, 0.35),
            effects={
                "reverb": {"room": 0.9, "mix": 0.8},
                "echo": {"phase": 1.5, "decay": 8}
            },
            duration_bars=32,
            bpm=115
        ),
        metadata=SegmentMetadata(
            source_file="Draft_/cardj_edm/Midnight_Horizon.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["ambient", "night_drive", "atmospheric", "car_audio"],
            mood_tags=["peaceful", "nocturnal", "expansive", "contemplative"],
            element_tags=["pad", "chords", "sustained", "atmospheric", "night_drive"],
            suitable_sections=["intro", "breakdown", "night_section"],
            energy_level=0.3,
            complexity=0.4,
            car_audio_optimization={
                "bass_boost": 0.9,
                "mid": 1.1,
                "high": 1.0
            }
        ),
        math_adaptable=True,
        variations=[
            {"chord_voicing": "open"},
            {"reverb_room_range": (0.8, 1.0)}
        ]
    )


# ============= cosmic_echo 宇宙回声系列 =============

def extract_cosmic_echo_mathematical():
    """提取Cosmic Echo数学版本 - 来自demos/cosmic_echo_demo/cosmic_echo_o5.rb"""
    
    code = """use_bpm 128

# Cosmic Echo - Mathematical Evolution
define :fibonacci do |n|
  return n if n <= 1
  fibonacci(n-1) + fibonacci(n-2)
end

live_loop :cosmic_math do
  use_synth :prophet
  with_fx :reverb, room: 0.85, mix: 0.7 do
    with_fx :echo, phase: 0.75, decay: 8 do
      
      # 使用斐波那契数列生成音高
      8.times do |i|
        fib_num = fibonacci(i % 8)
        base_note = :c4
        note = base_note + (fib_num % 24)
        
        play note, 
             amp: 0.4 + (Math.sin(i * 0.5) * 0.2),
             release: 0.5,
             cutoff: 80 + (fib_num % 50)
        
        sleep 0.5
      end
    end
  end
end"""

    return StandardSegment(
        id="cosmic_echo_mathematical_01",
        name="Cosmic Echo Mathematical",
        category=SegmentCategory.MELODY,
        sub_type=SegmentSubType.ARPEGGIO,
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cosmic_math",
            setup_code="use_bpm 128"
        ),
        musical_params=MusicalParameters(
            scale="C_chromatic",
            root_note="C4",
            pattern=[1]*8,
            subdivisions=8,
            synth=":prophet",
            amp_range=(0.2, 0.6),
            effects={
                "reverb": {"room": 0.85, "mix": 0.7},
                "echo": {"phase": 0.75, "decay": 8},
                "cutoff_range": (80, 130),
                "algorithm": "fibonacci"
            },
            duration_bars=4,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="Draft_/demos/cosmic_echo_demo/cosmic_echo_o5.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["algorithmic", "cosmic", "mathematical", "experimental"],
            mood_tags=["otherworldly", "mathematical", "evolving", "spacey"],
            element_tags=["fibonacci", "algorithm", "melodic", "cosmic", "highway_dreams"],
            suitable_sections=["experimental", "build_up", "mathematical"],
            energy_level=0.6,
            complexity=0.95,
            car_audio_optimization={
                "bass_boost": 0.8,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"sequence_type": "lucas_numbers"},
            {"amplitude_modulation": "sine_wave"},
            {"modulo_range": (12, 36)}
        ]
    )


def extract_evolving_edm_layers():
    """提取Evolving EDM分层 - 来自demos/cosmic_echo_demo/evolving_edm_mathematical_o1.rb"""
    
    code = """use_bpm 132

# Evolving EDM - Layered Approach
live_loop :edm_foundation do
  sample :bd_haus, amp: 1.2, cutoff: 85
  sleep 1
end

live_loop :edm_evolution_layer1 do
  sync :edm_foundation
  use_synth :tb303
  
  # 动态演化的Bass
  with_fx :lpf, cutoff: 70 + (tick % 40) do
    play :c2, amp: 0.8, release: 0.5, cutoff: rrand(60, 90), res: 0.85
    sleep 0.5
  end
end

live_loop :edm_evolution_layer2 do
  sync :edm_foundation
  use_synth :blade
  
  # 数学生成的旋律层
  with_fx :slicer, phase: 0.125, wave: 3 do
    notes = (scale :c5, :minor_pentatonic)
    play notes[(tick * 3) % notes.length], 
         amp: 0.5, 
         release: 0.2,
         cutoff: 100
    sleep 0.25
  end
end"""

    return StandardSegment(
        id="evolving_edm_layers_01",
        name="Evolving EDM Layers",
        category=SegmentCategory.TEXTURE,
        sub_type=SegmentSubType.SYNTH_TEXTURE,  # ✅ 改为 SYNTH_TEXTURE
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="edm_foundation",
            dependencies=["edm_evolution_layer1", "edm_evolution_layer2"],
            setup_code="use_bpm 132"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "C5"],
            scale="C_minor_pentatonic",
            root_note="C2",
            sample=":bd_haus",
            synth=":tb303, :blade",
            amp_range=(0.5, 1.2),
            effects={
                "lpf": {"cutoff_modulation": (70, 110)},
                "slicer": {"phase": 0.125, "wave": 3},
                "cutoff_range": (60, 100),
                "res": 0.85
            },
            duration_bars=4,
            bpm=132
        ),
        metadata=SegmentMetadata(
            source_file="Draft_/demos/cosmic_echo_demo/evolving_edm_mathematical_o1.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["edm", "progressive", "layered", "evolutionary"],
            mood_tags=["building", "evolving", "energetic", "layered"],
            element_tags=["multi_layer", "evolving", "synced", "progressive", "storm_chase"],
            suitable_sections=["build_up", "drop", "peak"],
            energy_level=0.85,
            complexity=0.8,
            car_audio_optimization={
                "bass_boost": 1.3,
                "mid": 1.2,
                "high": 1.2
            }
        ),
        math_adaptable=True,
        variations=[
            {"layer_count": "adjustable"},
            {"evolution_speed": "variable"},
            {"modulation_depth": "dynamic"}
        ]
    )


def extract_cosmic_edm_evolution_v3():
    """提取Cosmic EDM Evolution V3 - 来自edm_music/cosmic_edm_evolution_v3.rb"""
    
    code = """use_bpm 128

# Cosmic EDM Evolution V3 - Final Version
live_loop :cosmic_kick do
  sample :bd_haus, amp: 1.4, cutoff: 88
  sleep 1
end

live_loop :cosmic_bass do
  sync :cosmic_kick
  use_synth :fm
  
  with_fx :lpf, cutoff: 85 do
    with_fx :compressor, threshold: 0.3 do
      pattern = [:c2, :c2, :g1, :a1, :f1]
      durations = [1, 0.5, 0.5, 0.5, 0.5]
      
      pattern.zip(durations).each do |note, dur|
        play note, 
             amp: 0.9, 
             release: dur * 0.8, 
             divisor: 1.8, 
             depth: 3
        sleep dur
      end
    end
  end
end

live_loop :cosmic_lead do
  sync :cosmic_kick
  use_synth :blade
  
  with_fx :reverb, room: 0.7, mix: 0.6 do
    with_fx :slicer, phase: 0.125, wave: 3 do
      notes = (scale :c5, :minor_pentatonic, num_octaves: 2)
      
      8.times do
        play notes.choose, 
             amp: 0.6, 
             release: 0.2,
             cutoff: rrand(100, 120)
        sleep 0.25
      end
    end
  end
end"""

    return StandardSegment(
        id="cosmic_edm_evolution_v3_01",
        name="Cosmic EDM Evolution V3",
        category=SegmentCategory.TEXTURE,
        sub_type=SegmentSubType.SYNTH_TEXTURE,  # ✅ 改为 SYNTH_TEXTURE
        sonic_pi_code=SonicPiCode(
            main_code=code.strip(),
            live_loop_name="cosmic_kick",
            dependencies=["cosmic_bass", "cosmic_lead"],
            setup_code="use_bpm 128"
        ),
        musical_params=MusicalParameters(
            notes=["C2", "G1", "A1", "F1", "C5"],
            scale="C_minor_pentatonic",
            root_note="C2",
            sample=":bd_haus",
            synth=":fm, :blade",
            amp_range=(0.6, 1.4),
            effects={
                "lpf": {"cutoff": 85},
                "compressor": {"threshold": 0.3},
                "reverb": {"room": 0.7, "mix": 0.6},
                "slicer": {"phase": 0.125, "wave": 3},
                "divisor": 1.8,
                "depth": 3
            },
            duration_bars=4,
            bpm=128
        ),
        metadata=SegmentMetadata(
            source_file="Draft_/edm_music/cosmic_edm_evolution_v3.rb",
            extraction_date=datetime.now().isoformat(),
            genre_tags=["cosmic", "edm", "progressive", "full_track"],
            mood_tags=["cosmic", "energetic", "evolving", "complete"],
            element_tags=["full_arrangement", "kick", "bass", "lead", "synced", "storm_chase"],
            suitable_sections=["drop", "peak", "full_section"],
            energy_level=0.9,
            complexity=0.85,
            car_audio_optimization={
                "bass_boost": 1.4,
                "mid": 1.2,
                "high": 1.3
            }
        ),
        math_adaptable=True,
        variations=[
            {"pattern_length": "extended"},
            {"lead_algorithm": "generative"},
            {"bass_progression": "mathematical"}
        ]
    )


# 主函数：批量生成并保存
def generate_draft_segments():
    """生成Draft_文件夹的高价值Segment并保存"""
    
    segments = [
        # cardj_edm 车载场景系列
        extract_dawn_ignition_main_theme(),
        extract_urban_velocity_groove(),
        extract_midnight_horizon_pad(),
        
        # cosmic_echo 宇宙回声系列
        extract_cosmic_echo_mathematical(),
        extract_evolving_edm_layers(),
        
        # cosmic_edm_evolution 最终版本
        extract_cosmic_edm_evolution_v3()
    ]
    
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
        
        if os.path.exists(filepath):
            print(f"⚠️  文件已存在: {filepath}")
            continue
        
        segment.save_to_file(filepath)
        print(f"✓ 已生成: {segment.name} -> {filepath}")
        saved_count += 1
    
    print(f"\n总计生成 {saved_count}/{len(segments)} 个Draft高价值Segment")
    
    # 详细统计
    print("\n" + "="*60)
    print("📊 Draft_文件夹素材统计")
    print("="*60)
    
    # 来源统计
    source_count = {
        "车载场景原型": 3,
        "宇宙数学音乐": 2,
        "EDM演化系列": 1
    }
    
    print("\n【来源分布】")
    for source, count in source_count.items():
        print(f"  {source}: {count} 个")
    
    # 场景匹配分析（通过element_tags识别）
    print("\n【车载场景适配度分析】")
    scene_tags = {
        "Dawn Ignition": ["dawn_ignition"],
        "Urban Pulse": ["urban_pulse"],
        "Night Drive": ["night_drive"],
        "Storm Chase": ["storm_chase"],
        "Highway Dreams": ["highway_dreams"]
    }
    
    for scene, tags in scene_tags.items():
        matching = [s.name for s in segments 
                   if any(tag in s.metadata.element_tags for tag in tags)]
        if matching:
            print(f"\n  {scene}:")
            for name in matching:
                print(f"    - {name}")
    
    # 能量等级
    energy_levels = [s.metadata.energy_level for s in segments]
    print(f"\n【能量等级】")
    print(f"  范围: {min(energy_levels):.2f} - {max(energy_levels):.2f}")
    print(f"  平均: {sum(energy_levels)/len(energy_levels):.2f}")
    
    # 复杂度
    complexities = [s.metadata.complexity for s in segments]
    print(f"\n【复杂度】")
    print(f"  范围: {min(complexities):.2f} - {max(complexities):.2f}")
    print(f"  平均: {sum(complexities)/len(complexities):.2f}")
    
    print("\n" + "="*60)
    
    return segments


if __name__ == "__main__":
    segments = generate_draft_segments()