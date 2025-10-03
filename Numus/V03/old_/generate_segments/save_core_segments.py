"""
生成核心 EDM Segments
确保每个 Section 类型都有足够的素材支持
"""

import json
import os
from pathlib import Path
from datetime import datetime

def create_core_segments():
    """
    创建 15 个核心 Segment 定义
    """
    segments = []
    
    # ========== RHYTHM 类 ==========
    
    # 1. Four-on-Floor Kick (必备)
    segments.append({
        "id": "kick_four_on_floor_foundation_01",
        "name": "Four-on-Floor Kick Foundation",
        "category": "rhythm",
        "sub_type": "kick_pattern",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :kick_foundation do
  sample :bd_haus, amp: 1.5, cutoff: 90
  sleep 1
end""",
            "live_loop_name": "kick_foundation",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "pattern": [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
            "synth": ":bd_haus",
            "bpm": 128,
            "amp_range": [1.3, 1.7],
            "effects": {
                "compression": True,
                "sidechain": True
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["house", "techno", "progressive"],
            "mood_tags": ["driving", "foundation", "solid"],
            "element_tags": ["kick", "four_on_floor", "essential"],
            "suitable_sections": ["intro", "verse", "drop", "build_up"],
            "energy_level": 0.6,
            "complexity": 0.2,
            "car_audio_optimization": {
                "bass_boost": 1.3,
                "punch": 1.2
            }
        },
        "math_adaptable": False,
        "variations": None
    })
    
    # 2. Progressive Hi-Hat
    segments.append({
        "id": "hihat_progressive_open_closed_01",
        "name": "Progressive Hi-Hat Open/Closed",
        "category": "rhythm",
        "sub_type": "hihat_pattern",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :hihat_prog do
  4.times do
    sample :drum_cymbal_closed, amp: 0.5, cutoff: rrand(90, 110)
    sleep 0.5
    sample :drum_cymbal_open, amp: 0.3, cutoff: rrand(100, 120), release: 0.2
    sleep 0.5
  end
end""",
            "live_loop_name": "hihat_prog",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "pattern": [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1],
            "synth": ":drum_cymbal_closed",
            "bpm": 128,
            "subdivisions": 8,
            "effects": {
                "cutoff_automation": "slight_variation",
                "reverb": 0.2
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["progressive_house", "deep_house"],
            "mood_tags": ["rhythmic", "textural", "flowing"],
            "element_tags": ["hihat", "percussion", "groove"],
            "suitable_sections": ["verse", "drop", "build_up"],
            "energy_level": 0.5,
            "complexity": 0.4,
            "car_audio_optimization": {
                "high_boost": 1.1,
                "clarity": 1.2
            }
        },
        "math_adaptable": True,
        "variations": [
            {"name": "faster_subdivision", "subdivisions": 16},
            {"name": "slower_groove", "subdivisions": 4}
        ]
    })
    
    # 3. Clap/Snare Pattern
    segments.append({
        "id": "snare_clap_pattern_01",
        "name": "Clap and Snare Pattern",
        "category": "rhythm",
        "sub_type": "snare_pattern",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :snare_clap do
  sleep 1
  sample :drum_snare_hard, amp: 1.0
  sample :perc_snap, amp: 0.7
  sleep 1
end""",
            "live_loop_name": "snare_clap",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "pattern": [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
            "synth": ":drum_snare_hard",
            "bpm": 128,
            "amp_range": [0.9, 1.1]
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["house", "techno", "edm"],
            "mood_tags": ["punchy", "rhythmic", "classic"],
            "element_tags": ["snare", "clap", "backbeat"],
            "suitable_sections": ["drop", "verse", "chorus"],
            "energy_level": 0.7,
            "complexity": 0.3,
            "car_audio_optimization": {
                "mid_boost": 1.15,
                "punch": 1.3
            }
        },
        "math_adaptable": False
    })
    
    # ========== HARMONY 类 ==========
    
    # 4. Deep Sub Bass
    segments.append({
        "id": "sub_bass_deep_foundation_01",
        "name": "Deep Sub Bass Foundation",
        "category": "harmony",
        "sub_type": "sub_bass",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :sub_bass do
  use_synth :sine
  play :c2, amp: 1.5, release: 4, cutoff: 60
  sleep 4
end""",
            "live_loop_name": "sub_bass",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "notes": ["C2"],
            "synth": ":sine",
            "root_note": "C2",
            "bpm": 128,
            "effects": {
                "low_pass": 60,
                "sub_enhancement": True
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["deep_house", "techno", "minimal"],
            "mood_tags": ["deep", "foundation", "powerful"],
            "element_tags": ["sub_bass", "foundation", "low_end"],
            "suitable_sections": ["intro", "verse", "drop", "outro"],
            "energy_level": 0.4,
            "complexity": 0.1,
            "car_audio_optimization": {
                "bass_boost": 1.5,
                "low_cut": 30
            }
        },
        "math_adaptable": True
    })
    
    # 5. Bass Line Groove
    segments.append({
        "id": "bass_line_groove_minor_01",
        "name": "Bass Line Groove (Minor)",
        "category": "harmony",
        "sub_type": "bass_line",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :bass_groove do
  use_synth :bass_foundation
  notes = [:c2, :c2, :eb2, :g2]
  notes.each do |n|
    play n, amp: 1.2, release: 0.8, cutoff: 70
    sleep 1
  end
end""",
            "live_loop_name": "bass_groove",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "notes": ["C2", "C2", "Eb2", "G2"],
            "scale": "minor",
            "synth": ":bass_foundation",
            "bpm": 128,
            "effects": {
                "filter_type": "lpf",
                "cutoff": 70,
                "resonance": 0.3
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["deep_house", "progressive_house"],
            "mood_tags": ["groovy", "driving", "melodic"],
            "element_tags": ["bass", "melodic_bass", "groove"],
            "suitable_sections": ["verse", "drop", "chorus"],
            "energy_level": 0.6,
            "complexity": 0.4,
            "car_audio_optimization": {
                "bass_boost": 1.25,
                "mid_boost": 1.1
            }
        },
        "math_adaptable": True,
        "variations": [
            {"name": "major_variant", "notes": ["C2", "C2", "E2", "G2"]},
            {"name": "darker_variant", "notes": ["C2", "C2", "Ab1", "Bb1"]}
        ]
    })
    
    # 6. Chord Progression Pad
    segments.append({
        "id": "pad_chord_progression_01",
        "name": "Chord Progression Pad",
        "category": "harmony",
        "sub_type": "pad",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :chord_pad do
  use_synth :hollow
  chords = [chord(:c, :minor7), chord(:ab, :major7), chord(:eb, :major7), chord(:bb, :major7)]
  chords.each do |c|
    play c, amp: 0.6, release: 3.5, cutoff: 80, attack: 0.5
    sleep 4
  end
end""",
            "live_loop_name": "chord_pad",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 16,
            "chord_progressions": ["Cm7", "Abmaj7", "Ebmaj7", "Bbmaj7"],
            "synth": ":hollow",
            "bpm": 128,
            "effects": {
                "reverb": 0.7,
                "attack": 0.5,
                "release": 3.5
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["progressive_house", "trance", "ambient"],
            "mood_tags": ["atmospheric", "emotional", "warm"],
            "element_tags": ["pad", "chords", "harmonic"],
            "suitable_sections": ["intro", "breakdown", "bridge", "outro"],
            "energy_level": 0.4,
            "complexity": 0.5,
            "car_audio_optimization": {
                "mid_boost": 1.1,
                "width": 1.3
            }
        },
        "math_adaptable": True
    })
    
    # ========== MELODY 类 ==========
    
    # 7. Progressive Lead
    segments.append({
        "id": "lead_progressive_melody_01",
        "name": "Progressive House Lead Melody",
        "category": "melody",
        "sub_type": "lead_melody",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :prog_lead do
  use_synth :blade
  melody = [:c4, :d4, :eb4, :g4, :ab4, :g4, :eb4, :d4]
  melody.each do |n|
    play n, amp: 0.8, attack: 0.01, release: 0.4, cutoff: 100
    sleep 0.5
  end
end""",
            "live_loop_name": "prog_lead",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "notes": ["C4", "D4", "Eb4", "G4", "Ab4", "G4", "Eb4", "D4"],
            "scale": "minor",
            "synth": ":blade",
            "bpm": 128,
            "effects": {
                "cutoff": 100,
                "resonance": 0.4,
                "delay": 0.25
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["progressive_house", "melodic_techno"],
            "mood_tags": ["uplifting", "melodic", "emotional"],
            "element_tags": ["lead", "melody", "synth"],
            "suitable_sections": ["drop", "chorus", "climax"],
            "energy_level": 0.8,
            "complexity": 0.6,
            "car_audio_optimization": {
                "mid_boost": 1.2,
                "high_boost": 1.1,
                "clarity": 1.3
            }
        },
        "math_adaptable": True
    })
    
    # 8. Arpeggio Pattern
    segments.append({
        "id": "arpeggio_rising_pattern_01",
        "name": "Rising Arpeggio Pattern",
        "category": "melody",
        "sub_type": "arpeggio",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :arp_rising do
  use_synth :pluck
  notes = scale(:c3, :minor_pentatonic, num_octaves: 2)
  notes.each do |n|
    play n, amp: 0.6, release: 0.2, cutoff: 90
    sleep 0.125
  end
end""",
            "live_loop_name": "arp_rising",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "scale": "minor_pentatonic",
            "pattern": "ascending",
            "synth": ":pluck",
            "bpm": 128,
            "subdivisions": 16,
            "effects": {
                "cutoff": 90,
                "delay": 0.25
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["trance", "progressive_house", "psytrance"],
            "mood_tags": ["energetic", "hypnotic", "building"],
            "element_tags": ["arpeggio", "sequence", "rising"],
            "suitable_sections": ["build_up", "drop", "verse"],
            "energy_level": 0.7,
            "complexity": 0.6,
            "car_audio_optimization": {
                "mid_boost": 1.15,
                "clarity": 1.25
            }
        },
        "math_adaptable": True
    })
    
    # ========== FX 类 ==========
    
    # 9. White Noise Riser
    segments.append({
        "id": "riser_white_noise_8bar_01",
        "name": "White Noise Riser (8 bars)",
        "category": "fx",
        "sub_type": "riser",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :noise_riser, sync: :kick_foundation do
  with_fx :hpf, cutoff: 60, cutoff_slide: 8 do |fx|
    with_fx :lpf, cutoff: 130, cutoff_slide: 8 do |fx2|
      control fx, cutoff: 130
      control fx2, cutoff: 130
      sample :vinyl_hiss, amp: 0.3, rate: 1, sustain: 8
      sleep 8
    end
  end
end""",
            "live_loop_name": "noise_riser",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 8,
            "synth": ":noise",
            "bpm": 128,
            "effects": {
                "cutoff_start": 60,
                "cutoff_end": 130,
                "filter_type": "hpf + lpf sweep"
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["edm", "house", "trance", "universal"],
            "mood_tags": ["building", "tension", "anticipation"],
            "element_tags": ["riser", "fx", "build_up"],
            "suitable_sections": ["build_up"],
            "energy_level": 0.5,
            "complexity": 0.3,
            "car_audio_optimization": {
                "high_boost": 1.2,
                "width": 1.4
            }
        },
        "math_adaptable": False
    })
    
    # 10. Impact Drop Hit
    segments.append({
        "id": "impact_drop_hit_01",
        "name": "Impact Drop Hit",
        "category": "fx",
        "sub_type": "impact",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :drop_impact, sync: :kick_foundation do
  sample :bd_boom, amp: 2.0, cutoff: 110
  sample :drum_cymbal_open, amp: 1.5, rate: 0.5, cutoff: 120
  sleep 16
end""",
            "live_loop_name": "drop_impact",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 0.25,
            "synth": ":bd_boom",
            "bpm": 128,
            "amp_range": [1.8, 2.2]
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["edm", "big_room", "festival"],
            "mood_tags": ["powerful", "explosive", "peak"],
            "element_tags": ["impact", "drop", "hit"],
            "suitable_sections": ["drop", "transition"],
            "energy_level": 1.0,
            "complexity": 0.2,
            "car_audio_optimization": {
                "bass_boost": 1.4,
                "punch": 1.5,
                "limiter": True
            }
        },
        "math_adaptable": False
    })
    
    # 11. Filter Sweep Transition
    segments.append({
        "id": "transition_filter_sweep_01",
        "name": "Filter Sweep Transition",
        "category": "fx",
        "sub_type": "transition",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :filter_sweep do
  with_fx :lpf, cutoff: 130, cutoff_slide: 2 do |fx|
    control fx, cutoff: 40
    sample :ambi_swoosh, amp: 0.8, rate: 1
    sleep 2
  end
end""",
            "live_loop_name": "filter_sweep",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 2,
            "bpm": 128,
            "effects": {
                "cutoff_start": 130,
                "cutoff_end": 40,
                "sweep_duration": 2
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["house", "techno", "edm"],
            "mood_tags": ["transitional", "smooth", "connecting"],
            "element_tags": ["transition", "filter", "sweep"],
            "suitable_sections": ["transition", "breakdown", "build_up"],
            "energy_level": 0.4,
            "complexity": 0.3,
            "car_audio_optimization": {
                "width": 1.3
            }
        },
        "math_adaptable": False
    })
    
    # ========== ATMOSPHERE 类 ==========
    
    # 12. Ambient Dawn Texture
    segments.append({
        "id": "ambient_dawn_texture_01",
        "name": "Ambient Dawn Texture",
        "category": "atmosphere",
        "sub_type": "ambient_layer",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :dawn_ambient do
  use_synth :hollow
  with_fx :reverb, room: 0.9 do
    play chord(:c4, :major7), amp: 0.3, release: 8, cutoff: 70, attack: 2
    sleep 8
    play chord(:g3, :major7), amp: 0.3, release: 8, cutoff: 70, attack: 2
    sleep 8
  end
end""",
            "live_loop_name": "dawn_ambient",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 16,
            "chord_progressions": ["Cmaj7", "Gmaj7"],
            "synth": ":hollow",
            "bpm": 128,
            "effects": {
                "reverb": 0.9,
                "attack": 2,
                "release": 8
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["ambient", "chill", "atmospheric"],
            "mood_tags": ["peaceful", "awakening", "spacious", "serene"],
            "element_tags": ["ambient", "texture", "background"],
            "suitable_sections": ["intro", "outro", "breakdown"],
            "energy_level": 0.2,
            "complexity": 0.2,
            "car_audio_optimization": {
                "width": 1.5,
                "depth": 1.3
            }
        },
        "math_adaptable": True
    })
    
    # 13. Night Drive Atmosphere
    segments.append({
        "id": "atmosphere_night_drive_01",
        "name": "Night Drive Atmosphere",
        "category": "atmosphere",
        "sub_type": "ambient_layer",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :night_atmos do
  use_synth :dark_ambience
  with_fx :reverb, room: 0.8 do
    with_fx :echo, phase: 0.75, decay: 4 do
      play :c2, amp: 0.4, release: 12, cutoff: 60, attack: 3
      sleep 12
    end
  end
end""",
            "live_loop_name": "night_atmos",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 12,
            "notes": ["C2"],
            "synth": ":dark_ambience",
            "bpm": 128,
            "effects": {
                "reverb": 0.8,
                "echo": {"phase": 0.75, "decay": 4},
                "attack": 3,
                "release": 12
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["ambient", "dark", "atmospheric"],
            "mood_tags": ["mysterious", "urban", "nocturnal", "deep"],
            "element_tags": ["ambient", "dark", "spacious"],
            "suitable_sections": ["intro", "breakdown", "bridge"],
            "energy_level": 0.3,
            "complexity": 0.3,
            "car_audio_optimization": {
                "width": 1.4,
                "bass_boost": 1.1
            }
        },
        "math_adaptable": True
    })
    
    # ========== TEXTURE 类 ==========
    
    # 14. Evolving Synth Texture
    segments.append({
        "id": "texture_evolving_synth_01",
        "name": "Evolving Synth Texture",
        "category": "texture",
        "sub_type": "synth_texture",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :evolving_texture do
  use_synth :prophet
  with_fx :reverb, room: 0.7 do
    with_fx :lpf, cutoff: 80, cutoff_slide: 4 do |fx|
      play chord(:c3, :minor), amp: 0.5, release: 4, cutoff: 70
      control fx, cutoff: 100
      sleep 4
    end
  end
end""",
            "live_loop_name": "evolving_texture",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "chord_progressions": ["Cm"],
            "synth": ":prophet",
            "bpm": 128,
            "effects": {
                "reverb": 0.7,
                "lpf": {"start": 80, "end": 100},
                "release": 4
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["progressive", "techno", "ambient"],
            "mood_tags": ["evolving", "textural", "layered"],
            "element_tags": ["texture", "synth", "movement"],
            "suitable_sections": ["verse", "breakdown", "bridge"],
            "energy_level": 0.4,
            "complexity": 0.5,
            "car_audio_optimization": {
                "mid_boost": 1.1,
                "width": 1.3
            }
        },
        "math_adaptable": True
    })
    
    # 15. Percussion Layer (Shakers)
    segments.append({
        "id": "percussion_shaker_layer_01",
        "name": "Shaker Percussion Layer",
        "category": "rhythm",
        "sub_type": "percussion_layer",
        "version": "1.0",
        "sonic_pi_code": {
            "main_code": """live_loop :shaker_layer do
  16.times do
    sample :drum_cymbal_closed, amp: 0.3, rate: 2, release: 0.1, cutoff: 110
    sleep 0.25
  end
end""",
            "live_loop_name": "shaker_layer",
            "dependencies": [],
            "setup_code": "use_bpm 128"
        },
        "musical_params": {
            "duration_bars": 4,
            "pattern": [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            "synth": ":drum_cymbal_closed",
            "bpm": 128,
            "subdivisions": 16,
            "effects": {
                "rate": 2,
                "cutoff": 110
            }
        },
        "metadata": {
            "source_file": "generated_core_segments.py",
            "extraction_date": datetime.now().isoformat(),
            "author": "Numus Core Library",
            "genre_tags": ["house", "latin_house", "deep_house"],
            "mood_tags": ["groovy", "organic", "rhythmic"],
            "element_tags": ["shaker", "percussion", "groove"],
            "suitable_sections": ["verse", "drop", "breakdown"],
            "energy_level": 0.4,
            "complexity": 0.3,
            "car_audio_optimization": {
                "high_boost": 1.15,
                "clarity": 1.2
            }
        },
        "math_adaptable": False
    })
    
    return segments

def save_core_segments(segments: list, output_dir: str):
    """
    将生成的核心 Segments 保存到对应的分类文件夹
    """
    output_path = Path(output_dir)
    
    for segment in segments:
        category = segment['category']
        category_dir = output_path / category
        category_dir.mkdir(parents=True, exist_ok=True)
        
        filename = f"{segment['id']}.json"
        filepath = category_dir / filename
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(segment, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Created: {filepath}")

if __name__ == "__main__":
    print("🎵 Generating 15 Core EDM Segments...\n")
    
    segments = create_core_segments()
    
    output_dir = "/Users/tsb/Pop-Proj/vootaa-music/Numus/segments"
    save_core_segments(segments, output_dir)
    
    print(f"\n✨ Successfully generated {len(segments)} core segments!")
    print("\nSegment Summary:")
    print("- Rhythm: 4 segments")
    print("- Harmony: 3 segments")
    print("- Melody: 2 segments")
    print("- FX: 3 segments")
    print("- Atmosphere: 2 segments")
    print("- Texture: 1 segment")