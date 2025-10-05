# DRUM CIRCLE DJ SHOW - MAIN PERFORMANCE
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/config.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/math_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/energy_curve.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/drummer_patterns.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/scale_modes.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/volume_controller.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/helpers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/performance_layers.rb"

# Include methods directly (Sonic Pi style)
extend PerformanceLayers

use_random_seed INITIAL_SEED
use_bpm BASE_BPM
set_volume! SET_VOLUME

# Initialize systems
@math = MathEngine.new(INITIAL_SEED)
@energy_system = EnergyCurve.new(CYCLE_LENGTH, GOLDEN_RATIO)
@patterns = DrummerPatterns.new
@scale_modes = ScaleModes.new  # Renamed from @scales
@volume_ctrl = VolumeController.new(@energy_system, @math, CYCLE_LENGTH)

@cycle_start = Time.now
@cycle_num = 0

# Performance config
FADE_IN_DUR = 10
FADE_OUT_DUR = 10
PERF_CYCLES = 2

# Helper wrapper
define :current_energy do
  result = DrumHelpers.current_energy(@cycle_start, @cycle_num, CYCLE_LENGTH, 
                                       @energy_system, @math, DEBUG_MODE)
  @cycle_start = result[1]
  @cycle_num = result[2]
  result[0]
end

# Calculate fade parameters
fade_params = @volume_ctrl.calculate_fade_params(FADE_IN_DUR, FADE_OUT_DUR, PERF_CYCLES)
performance_start = Time.now

if DEBUG_MODE
  puts "Fade Mode: IN=#{fade_params[:mode_in]} | OUT=#{fade_params[:mode_out]}"
end

# MASTER VOLUME with Smart Fade
with_fx :level, amp: 0 do |master_vol|
  # Volume control thread
  in_thread do
    loop do
      elapsed = Time.now - performance_start
      target_amp = @volume_ctrl.get_dynamic_volume(elapsed, fade_params)
      control master_vol, amp: target_amp
      
      if DEBUG_MODE && (elapsed.to_i % 5 == 0)
        puts "Volume: #{(target_amp * 100).to_i}% | Elapsed: #{elapsed.to_i}s"
      end
      
      sleep 0.1
      
      # Stop after performance duration
      break if elapsed >= fade_params[:total]
    end
  end
  
  # PULSE
  live_loop :pulse do
    sample [:bd_fat, :bd_haus].ring.tick, 
           amp: PULSE_VOLUME * get_sample_volume(:bd_fat), pan: 0
    sleep 1
  end
  
  # DRUMMERS
  [:drummer_a, :drummer_b, :drummer_c, :drummer_d].each do |drummer|
    live_loop drummer, sync: :pulse do
      energy = current_energy
      id = drummer.to_s[-1].upcase
      
      if DrumHelpers.should_play_drummer(id, energy, @math)
        idx = @math.get_next(:pi) % @patterns.pattern_count(id)
        pattern = @patterns.get_pattern(id, idx)
        play_drum_pattern(id, pattern, energy, @patterns, 
                         {drummer_pans: DRUMMER_PANS, sample_volumes: SAMPLE_VOLUMES, 
                          drummer_volume: DRUMMER_VOLUME})
      else
        sleep 2
      end
    end
  end
  
  # LOOP TEXTURE
  live_loop :loop_texture, sync: :pulse do
    energy = current_energy
    
    if energy > 0.2
      loop_samples = [:loop_amen, :loop_compus, :loop_tabla, :loop_safari].ring
      current_sample = loop_samples.tick
      pattern_type = @math.get_next(:golden) % 4
      start_pattern = DrumHelpers.get_loop_start_pattern(pattern_type).ring
      
      sample current_sample, beat_stretch: 4, start: start_pattern.look,
             rate: [0.5, 1.0, 2.0].ring.look,
             amp: energy * LOOP_VOLUME * get_sample_volume(current_sample),
             pan: @math.map_to_range(@math.get_next(:sqrt2), -0.2, 0.2)
      sleep 1
    else
      sleep 4
    end
  end
  
  # MELODY
  live_loop :melody, sync: :pulse do
    energy = current_energy
    
    if energy.between?(0.2, 0.8) && one_in(3)
      mode_idx = @math.get_next(:pi) % 12
      scale_notes = @scale_modes.get_scale_notes(:c4, mode_idx)  # Changed from @scales
      phrase_len = rrand_i(3, 7)
      note_idx = phrase_len.times.map { @math.get_next(:e) }
      phrase = @scale_modes.generate_phrase(scale_notes, phrase_len, note_idx, [0.5, 1.0, 1.5].ring)  # Changed
      
      use_synth @scale_modes.get_instrument_for_energy(energy)  # Changed
      
      with_fx :reverb, room: energy * 0.5 do
        with_fx :echo, phase: 0.75, decay: 2 do
          phrase.each do |note_data|
            play note_data[:note], amp: MELODY_VOLUME * energy * 1.5,
                 release: note_data[:duration] * 0.8,
                 pan: @math.map_to_range(@math.get_next(:sqrt2), -0.8, 0.8)
            sleep note_data[:duration]
          end
        end
      end
      sleep rrand(1, 2)
    else
      sleep 2
    end
  end
  
  # AMBIENCE
  live_loop :ambience, sync: :pulse do
    energy = current_energy
    
    if energy < 0.4
      amb = [:ambi_choir, :ambi_drone, :ambi_lunar_land].ring.tick
      with_fx :reverb, room: 0.8 do
        sample amb, amp: AMBIENT_VOLUME * get_sample_volume(amb),
               rate: 0.9, pan: [-0.5, 0.5].ring.look
      end
      sleep 8
    else
      sleep 4
    end
  end
  
  # FILLS
  live_loop :fills, sync: :pulse do
    energy = current_energy
    
    if DrumHelpers.should_trigger_fill(energy, @energy_system, @math, FILL_THRESHOLD)
      case @math.get_next(:sqrt2) % 4
      when 0  # Tom roll
        4.times do |i|
          tom = [:drum_tom_hi_hard, :drum_tom_mid_hard, :drum_tom_lo_hard].choose
          sample tom, amp: FILL_VOLUME * get_sample_volume(tom),
                 rate: rrand(0.9, 1.1), pan: @math.map_to_range(i * 2, -0.8, 0.8)
          sleep 0.25
        end
      when 1  # Cymbal
        sample :drum_cymbal_open, amp: FILL_VOLUME * get_sample_volume(:drum_cymbal_open),
               rate: 0.9, pan: @math.map_to_range(@math.get_next(:golden), -0.6, 0.6)
        sleep 2
      when 2  # Glitch
        glitch = [:elec_blip2, :elec_twang, :elec_pop].choose
        with_fx :bitcrusher, bits: 4 do
          sample glitch, amp: FILL_VOLUME * get_sample_volume(glitch),
                 rate: rrand(0.8, 1.5), pan: @math.map_to_range(@math.get_next(:sqrt2), -1.0, 1.0)
        end
        sleep 0.5
      else
        sleep 1
      end
    end
    sleep 1
  end
  
  # MONITOR
  live_loop :monitor, sync: :pulse do
    if DEBUG_MODE
      energy = current_energy
      puts "Energy: #{(energy * 100).to_i}% | #{@energy_system.get_category(energy)} | Cycle: #{@cycle_num}"
    end
    sleep 4
  end
end

puts "=" * 60
puts "DRUM CIRCLE DJ SHOW"
puts "Cycles: #{PERF_CYCLES} | BPM: #{BASE_BPM} | Seed: #{INITIAL_SEED}"
puts "Duration: #{fade_params[:total].to_i}s (Fade In: #{FADE_IN_DUR}s, Out: #{FADE_OUT_DUR}s)"
puts "=" * 60