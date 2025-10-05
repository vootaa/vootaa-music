# DRUM CIRCLE DJ SHOW - MAIN PERFORMANCE
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/config.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/math_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/energy_curve.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/drummer_patterns.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/scale_modes.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/volume_controller.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/helpers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/performance_layers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/performance.rb"

extend PerformanceLayers

# Get configuration
config = get_performance_config

# Apply global settings
use_random_seed config[:initial_seed]
use_bpm config[:base_bpm]
set_volume! config[:set_volume]

# Initialize conductor
@conductor = Performance::Conductor.new(config)

# Calculate fade parameters (ONCE)
fade_params = @conductor.volume_ctrl.calculate_fade_params(
  config[:fade_in_dur], config[:fade_out_dur], config[:perf_cycles]
)
performance_start = Time.now

if config[:debug_mode]
  puts "Fade Mode: IN=#{fade_params[:mode_in]} | OUT=#{fade_params[:mode_out]}"
end

# MASTER VOLUME with Smart Fade
with_fx :level, amp: 0 do |master_vol|
  # Volume control thread
  in_thread do
    loop do
      elapsed = Time.now - performance_start
      target_amp = @conductor.volume_ctrl.get_dynamic_volume(elapsed, fade_params)
      control master_vol, amp: target_amp
      
      if config[:debug_mode] && (elapsed.to_i % 5 == 0)
        puts "Volume: #{(target_amp * 100).to_i}% | Elapsed: #{elapsed.to_i}s"
      end
      
      sleep 0.1
      break if elapsed >= fade_params[:total]
    end
  end
  
  # CYCLE MANAGER (独立管理周期切换)
  live_loop :cycle_manager do
    elapsed = Time.now - performance_start
    current_cycle = (elapsed / config[:cycle_length]).to_i
    
    # 检测到新周期时更新种子
    if current_cycle != @conductor.cycle_num
      @conductor.math.apply_cycle_offset(current_cycle)
      @conductor.instance_variable_set(:@cycle_number, current_cycle)
      puts "🔄 Entering Cycle #{current_cycle}" if config[:debug_mode]
    end
    
    sleep config[:cycle_length] / 4.0  # 每 1/4 周期检查一次
  end
  
  # PULSE
  live_loop :pulse do
    sample [:bd_fat, :bd_haus].ring.tick, 
           amp: config[:pulse_volume] * get_sample_volume(:bd_fat), 
           pan: 0
    sleep 1
  end
  
  # DRUMMERS
  [:drummer_a, :drummer_b, :drummer_c, :drummer_d].each do |drummer|
    live_loop drummer, sync: :pulse do
      energy = @conductor.current_energy
      drummer_id = drummer.to_s[-1].upcase
      
      if @conductor.should_play_drummer?(drummer_id, energy)
        pattern = @conductor.get_drum_pattern(drummer_id)
        play_drum_pattern(drummer_id, pattern, energy, @conductor.patterns, @conductor)
      else
        sleep 2
      end
    end
  end
  
  # LOOP TEXTURE
  live_loop :loop_texture, sync: :pulse do
    energy = @conductor.current_energy
    
    if energy > 0.2
      loop_samples = [:loop_amen, :loop_compus, :loop_tabla, :loop_safari].ring
      current_sample = loop_samples.tick
      start_pattern = @conductor.get_loop_start_pattern.ring
      
      sample current_sample, 
             beat_stretch: 4, 
             start: start_pattern.look,
             rate: [0.5, 1.0, 2.0].ring.look,
             amp: energy * config[:loop_volume] * get_sample_volume(current_sample),
             pan: @conductor.get_pan_value(:sqrt2)
      sleep 1
    else
      sleep 4
    end
  end
  
  # MELODY
  live_loop :melody, sync: :pulse do
    energy = @conductor.current_energy
    
    if energy.between?(0.2, 0.8) && one_in(3)
      scale_notes = @conductor.get_scale_for_melody
      phrase_len = rrand_i(3, 7)
      phrase = @conductor.generate_melody_phrase(scale_notes, phrase_len)
      
      use_synth @conductor.get_instrument_for_energy(energy)
      
      with_fx :reverb, room: energy * 0.5 do
        with_fx :echo, phase: 0.75, decay: 2 do
          phrase.each do |note_data|
            play note_data[:note], 
                 amp: config[:melody_volume] * energy * 1.5,
                 release: note_data[:duration] * 0.8,
                 pan: @conductor.get_pan_value(:sqrt2)
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
    energy = @conductor.current_energy
    
    if energy < 0.4
      amb = [:ambi_choir, :ambi_drone, :ambi_lunar_land].ring.tick
      with_fx :reverb, room: 0.8 do
        sample amb, 
               amp: config[:ambient_volume] * get_sample_volume(amb),
               rate: 0.9, 
               pan: [-0.5, 0.5].ring.look
      end
      sleep 8
    else
      sleep 4
    end
  end
  
  # FILLS
  live_loop :fills, sync: :pulse do
    energy = @conductor.current_energy
    
    if @conductor.should_trigger_fill?(energy)
      case @conductor.math.get_next(:sqrt2) % 4
      when 0  # Tom roll
        4.times do |i|
          tom = [:drum_tom_hi_hard, :drum_tom_mid_hard, :drum_tom_lo_hard].choose
          sample tom, 
                 amp: config[:fill_volume] * get_sample_volume(tom),
                 rate: rrand(0.9, 1.1), 
                 pan: @conductor.math.map_to_range(i * 2, -0.8, 0.8)
          sleep 0.25
        end
      when 1  # Cymbal
        sample :drum_cymbal_open, 
               amp: config[:fill_volume] * get_sample_volume(:drum_cymbal_open),
               rate: 0.9, 
               pan: @conductor.get_pan_value(:golden)
        sleep 2
      when 2  # Glitch
        glitch = [:elec_blip2, :elec_twang, :elec_pop].choose
        with_fx :bitcrusher, bits: 4 do
          sample glitch, 
                 amp: config[:fill_volume] * get_sample_volume(glitch),
                 rate: rrand(0.8, 1.5), 
                 pan: @conductor.get_pan_value(:sqrt2)
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
    if config[:debug_mode]
      energy = @conductor.current_energy
      puts "⚡️ Energy: #{(energy * 100).to_i}% | #{@conductor.energy_system.get_category(energy)} | Cycle: #{@conductor.cycle_num}"
    end
    sleep 4
  end
end

puts "=" * 60
puts "🥁 DRUM CIRCLE DJ SHOW 🥁"
puts "Cycles: #{config[:perf_cycles]} | BPM: #{config[:base_bpm]} | Seed: #{config[:initial_seed]}"
puts "Duration: #{fade_params[:total].to_i}s (Fade In: #{config[:fade_in_dur]}s, Out: #{config[:fade_out_dur]}s)"
puts "=" * 60