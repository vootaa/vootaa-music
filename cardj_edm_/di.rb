# Dawn Ignition 《晨启》
# 数学驱动的渐进式House，借鉴经验技法

use_bpm 118
use_debug false

use_bpm 118

define :pi_sequence do |index, offset = 0|
  pi_str = "31415926535897932384626433832795028841971693993751"
  digit = pi_str[(index + offset) % pi_str.length].to_i
  digit / 9.0
end

define :phi_evolution do |time, frequency = 1.0|
  phi = 1.618033988749895
  (Math.sin(time * frequency * phi) * 0.5 + 0.5)
end

define :time_coordinates do |global_time|
  {
    micro: global_time % 4,
    meso: (global_time / 16) % 8,
    macro: (global_time / 128) % 16, 
    ultra: global_time / 9600.0
  }
end

define :deephouse_techniques do |energy_level|
  {
    gentle_kick: {
      pattern: [1, 0, 0.3, 0],
      amp_base: 0.6,
      condition: energy_level < 0.3
    },
    
    chord_progression: [chord(:c4, :M7),chord(:f4, :M7),chord(:g4, :dom7),chord(:c4, :M7)],
    
    wobble_params: {
      phase: 2.0 + energy_level * 2.0,
      mix: energy_level * 0.4,
      wave: 0
    },
    
    piano_texture: {
      arpeggio: [0, 2, 1, 3, 1, 2],
      humanize: true,
      reverb_mix: 0.6
    }
  }
end

define :dawn_fusion_controller do |ultra_time|
  stage_raw = (ultra_time * 5).to_i
  stage = stage_raw < 0 ? 0 : (stage_raw > 4 ? 4 : stage_raw)
  stage_progress = ((ultra_time * 5) % 1.0)
  
  transition = 1.0 / (1.0 + Math.exp(-8 * (stage_progress - 0.5)))
  
  base_configs = [
    {
      energy: 0.15,
      kick_style: :gentle_morning,
      synth_primary: :blade,
      scale: :major_pentatonic,
      reverb_space: 0.9,
      borrowed_technique: :gentle_kick
    },
    
    {
      energy: 0.35,
      kick_style: :light_bounce,
      synth_primary: :dpulse,
      scale: :major,
      reverb_space: 0.7,
      borrowed_technique: :chord_progression
    },
    
    {
      energy: 0.55,
      kick_style: :steady_four,
      synth_primary: :dsaw,
      scale: :dorian,
      reverb_space: 0.5,
      borrowed_technique: :wobble_params
    },
    
    {
      energy: 0.75,
      kick_style: :house_classic,
      synth_primary: :piano,
      scale: :minor,
      reverb_space: 0.4,
      borrowed_technique: :piano_texture
    },
    
    {
      energy: 0.95,
      kick_style: :full_drive,
      synth_primary: :prophet,
      scale: :mixolydian,
      reverb_space: 0.3,
      borrowed_technique: :all_techniques
    }
  ]
  
  current_config = base_configs[stage]
  
  current_config[:energy] += phi_evolution(ultra_time * 20) * 0.1
  current_config[:micro_variations] = pi_sequence((ultra_time * 1000).to_i)
  
  [stage, current_config, transition]
end

set :dawn_time, 0
set :dawn_stage, 0
set :dawn_config, {
  energy: 0.15,
  kick_style: :gentle_morning,
  synth_primary: :blade,
  scale: :major_pentatonic,
  reverb_space: 0.9,
  techniques: deephouse_techniques(0.15)
}
set :dawn_transition, 0.0

live_loop :dawn_master_controller do
  t = get(:dawn_time) + 1
  set :dawn_time, t
  
  coords = time_coordinates(t)
  fusion_data = dawn_fusion_controller(coords[:ultra])
  techniques = deephouse_techniques(fusion_data[1][:energy])
  
  set :dawn_stage, fusion_data[0]
  set :dawn_config, fusion_data[1].merge(techniques: techniques)
  set :dawn_transition, fusion_data[2]
  
  if t % 128 == 0
    puts "Stage #{fusion_data[0]}: Energy #{fusion_data[1][:energy].round(2)}"
  end
  
  sleep 0.125
end

live_loop :dawn_kick_fusion, sync: :dawn_master_controller do
  t = get(:dawn_time)
  config = get(:dawn_config)
  
  next if config.nil? || config[:techniques].nil?
  
  coords = time_coordinates(t)
  mathematical_intensity = phi_evolution(coords[:micro] * 4)
  borrowed_pattern = config[:techniques][:gentle_kick][:pattern]
  
  should_kick = case config[:kick_style]
  when :gentle_morning
    base_trigger = borrowed_pattern[t % 4] > 0.5
    math_mod = mathematical_intensity > 0.6
    base_trigger || (math_mod && pi_sequence(t/4) > 0.8)
    
  when :light_bounce
    (t % 4 == 0) || (t % 4 == 2 && pi_sequence(t/8) > 0.7)
    
  when :steady_four, :house_classic, :full_drive
    complexity = config[:energy]
    base_hits = [0, 2].include?(t % 4)
    extra_hits = complexity > 0.5 && [1, 3].include?(t % 4) && pi_sequence(t) > (1 - complexity)
    base_hits || extra_hits
  end
  
  if should_kick
    amp_base = config[:techniques][:gentle_kick][:amp_base]
    amp_variation = pi_sequence(t, 3) * 0.3
    
    sample :bd_haus,
      amp: amp_base + amp_variation + config[:energy] * 0.4,
      rate: 0.98 + coords[:micro] * 0.02,
      cutoff: [60 + config[:energy] * 50, 130].min
  end
  
  sleep 0.25
end

live_loop :dawn_chord_fusion, sync: :dawn_master_controller do
  t = get(:dawn_time)
  config = get(:dawn_config)
  
  next if config.nil? || config[:techniques].nil?
  
  coords = time_coordinates(t)
  
  use_synth config[:synth_primary]
  
  base_progression = config[:techniques][:chord_progression]
  chord_index = (coords[:macro] / 4).to_i % base_progression.length
  current_chord = base_progression[chord_index]
  
  pitch_warp = (pi_sequence(t/32, 7) - 0.5) * 3
  warped_chord = current_chord.map { |note| note + pitch_warp }
  
  wobble_config = config[:techniques][:wobble_params]
  wobble_phase = wobble_config[:phase] + phi_evolution(coords[:ultra] * 10) * 0.5
  
  with_fx :reverb, room: 0.7, mix: config[:reverb_space] do
    with_fx :wobble,
      phase: wobble_phase,
      mix: wobble_config[:mix] + coords[:micro] * 0.1,
      wave: wobble_config[:wave] do
      
      play warped_chord,
        attack: 1 + config[:energy] * 2,
        release: 8 - config[:energy] * 3,
        amp: 0.3 + config[:energy] * 0.2,
        cutoff: 70 + config[:energy] * 40
    end
  end
  
  sleep 16
end

live_loop :dawn_melody_fusion, sync: :dawn_master_controller do
  t = get(:dawn_time)
  config = get(:dawn_config)
  
  next if config.nil? || config[:techniques].nil?
  
  coords = time_coordinates(t)
  
  if config[:energy] > 0.4
    use_synth :piano
    
    arpeggio_pattern = config[:techniques][:piano_texture][:arpeggio]
    current_chord = config[:techniques][:chord_progression][(coords[:macro]/4).to_i % 4]
    
    pattern_index = (coords[:micro] * 2).to_i % arpeggio_pattern.length
    chord_note_index = arpeggio_pattern[pattern_index]
    base_note = current_chord[chord_note_index % current_chord.length]
    
    fractal_offset = (pi_sequence(t, 11) - 0.5) * 7
    final_note = base_note + fractal_offset
    
    timing_humanize = (pi_sequence(t, 13) - 0.5) * 0.1
    
    with_fx :reverb, room: 0.5, mix: 0.6 do
      with_fx :echo, phase: 0.375, decay: 3, mix: 0.3 do
        play final_note,
          amp: 0.2 + config[:energy] * 0.3,
          release: 1.2,
          cutoff: 80 + config[:energy] * 30
      end
    end
    
    sleep [0.25, 0.5, 0.75][(pi_sequence(t, 17) * 3).to_i] + timing_humanize
  else
    sleep 2
  end
end

live_loop :dawn_ambient_fusion, sync: :dawn_master_controller do
  t = get(:dawn_time)
  config = get(:dawn_config)
  
  next if config.nil?
  
  coords = time_coordinates(t)
  
  use_synth :hollow
  
  phi_note_offset = (phi_evolution(coords[:ultra] * 50) * 24).round
  ambient_note = :c5 + phi_note_offset
  
  reverb_room = 0.8 + pi_sequence(t/64) * 0.2
  reverb_mix = config[:reverb_space] + (pi_sequence(t/32, 5) - 0.5) * 0.2
  
  with_fx :reverb, room: reverb_room, mix: reverb_mix do
    with_fx :echo, phase: phi_evolution(coords[:ultra] * 30) * 0.5 + 0.25 do
      play ambient_note,
        attack: 3 + config[:energy] * 2,
        release: 12 - config[:energy] * 4,
        amp: 0.1 + (1 - config[:energy]) * 0.2,
        cutoff: 60 + pi_sequence(t/16) * 30,
        pan: (pi_sequence(t/8, 9) - 0.5) * 0.8
    end
  end
  
  sleep 8 + pi_sequence(t/4) * 4
end

live_loop :dawn_bass_fusion, sync: :dawn_master_controller do
  t = get(:dawn_time)
  config = get(:dawn_config)
  
  next if config.nil? || config[:techniques].nil?
  
  coords = time_coordinates(t)
  
  if config[:energy] > 0.35
    use_synth :dsaw
    use_synth_defaults release: 0.1, amp: 1.0 + config[:energy] * 0.5
    
    current_chord = config[:techniques][:chord_progression][(coords[:macro]/4).to_i % 4]
    root_note = current_chord[0] - 24
    
    bass_pattern = [
      root_note, 0, root_note + 7, 0,
      root_note, root_note, 0, root_note + 5
    ]
    
    note_to_play = bass_pattern[t % bass_pattern.length]
    
    if note_to_play != 0
      if pi_sequence(t, 19) < (config[:energy] * 0.8 + 0.2)
        play note_to_play,
          cutoff: 80 + config[:energy] * 20,
          sustain: 0.08
      end
    end
  end
  
  sleep 0.125
end