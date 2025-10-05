# DRUM CIRCLE DJ SHOW - MAIN PERFORMANCE
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/config.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/math_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/energy_curve.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/drummer_patterns.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/scale_modes.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/volume_controller.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/helpers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/performance_layers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V01/lib/performance.rb"

extend PerformanceLayers

config = get_performance_config

use_random_seed config[:initial_seed]
use_bpm config[:base_bpm]
set_volume! config[:set_volume]

set :beat_idx, 0
set :bar_idx, 0
set :bar_in_phrase, 0

set :loop_cycle_sample, nil
set :loop_cycle_start_ring, nil
set :loop_cycle_rate, 1.0
set :loop_cycle_beat_stretch, 4

@energy_hist = []

DRUMMER_PAN = { "A" => -0.5, "B" => 0.5, "C" => -0.2, "D" => 0.2 }

fade_params = @conductor.volume_ctrl.calculate_fade_params(
  config[:fade_in_dur],
  config[:fade_out_dur],
  config[:perf_cycles]
)
performance_start = Time.now

if config[:debug_mode]
  puts "Fade Mode: IN=#{fade_params[:mode_in]} | OUT=#{fade_params[:mode_out]}"
end

with_fx :level, amp: 0 do |master_vol|
  # Volume control thread
  in_thread do
    loop do
      elapsed = Time.now - performance_start
      target_amp = @conductor.volume_ctrl.get_dynamic_volume(elapsed, fade_params)
      control master_vol, amp: target_amp
      sleep 0.2  # fewer updates, less pump
      break if elapsed >= fade_params[:total]
    end
  end
  
  live_loop :bar_clock do
    beat = get(:beat_idx) + 1
    set :beat_idx, beat
    
    if (beat % config[:beats_per_bar]).zero?
      bar = get(:bar_idx) + 1
      set :bar_idx, bar
      set :bar_in_phrase, (bar - 1) % config[:bars_per_phrase]
      cue :bar
    end
    sleep 1
  end
  
  live_loop :cycle_manager do
    elapsed = Time.now - performance_start
    current_cycle = (elapsed / config[:cycle_length]).to_i
    
    if current_cycle != @conductor.cycle_number
      @conductor.math.apply_cycle_offset(current_cycle)
      @conductor.instance_variable_set(:@cycle_number, current_cycle)
      
      if config[:loop_slice_mode] == :cycle_locked
        set :loop_cycle_sample, @conductor.get_loop_sample
        set :loop_cycle_start_ring, @conductor.get_loop_start_pattern.ring
        set :loop_cycle_rate, @conductor.get_loop_rate
        set :loop_cycle_beat_stretch, @conductor.get_loop_beat_stretch
      end
    end
    
    sleep config[:cycle_length] / 4.0
  end
  
  live_loop :pulse do
    pulse_samples = config[:pulse_samples].ring
    sample pulse_samples.tick,
      amp: config[:pulse_volume] * get_sample_volume(pulse_samples.look),
      pan: 0
    sleep 1
  end
  
  define :smooth_energy do
    e = @conductor.current_energy
    @energy_hist << e
    @energy_hist = @energy_hist.last(8)
    @energy_hist.sum / @energy_hist.size
  end
  
  [:drummer_a, :drummer_b, :drummer_c, :drummer_d].each do |drummer|
    live_loop drummer, sync: :bar do
      energy = smooth_energy
      drummer_id = drummer.to_s[-1].upcase
      
      allowed = @conductor.get_active_drummer_ids(energy).take(config[:max_active_drummers]) rescue []
      play_now = allowed.include?(drummer_id) && @conductor.should_play_drummer?(drummer_id, energy)
      
      if play_now
        pattern = @conductor.get_drum_pattern(drummer_id)
        with_fx :pan, pan: DRUMMER_PAN[drummer_id] do
          play_drum_pattern(drummer_id, pattern, energy, @conductor.patterns, @conductor)
        end
        sleep pattern[:breathe] if pattern[:breathe]
      else
        sleep config[:drummer_rest_sleep]
      end
    end
  end
  
  # LOOP TEXTURE
  live_loop :loop_texture, sync: :bar do
    energy = smooth_energy
    if energy > 0.2
      current_sample = (get(:loop_cycle_sample) || @conductor.get_loop_sample)
      start_ring     = (get(:loop_cycle_start_ring) || @conductor.get_loop_start_pattern.ring)
      rate           = (get(:loop_cycle_rate) || @conductor.get_loop_rate)
      beat_stretch   = (get(:loop_cycle_beat_stretch) || @conductor.get_loop_beat_stretch)
      
      with_fx :hpf, cutoff: config[:loop_hpf_cutoff] do
        s = start_ring.tick
        sample current_sample,
          beat_stretch: beat_stretch,
          start: s,
          rate: rate,
          amp: energy * config[:loop_volume] * get_sample_volume(current_sample),
          pan: 0  # keep centered for glue
      end
      sleep 1
    else
      sleep 4
    end
  end
  
  # MELODY
  live_loop :melody, sync: :bar do
    energy = smooth_energy
    bar_in_phrase = get(:bar_in_phrase)
    # play only on even bars, reduce density
    if energy.between?(0.25, 0.7) && (bar_in_phrase.even?) && one_in((1.0 / config[:melody_bar_density]).to_i)
      scale_notes = @conductor.get_scale_for_melody
      phrase_len = @conductor.get_melody_phrase_length
      phrase = @conductor.generate_melody_phrase(scale_notes, phrase_len)
      
      use_synth @conductor.get_instrument_for_energy(energy)
      with_fx :reverb, room: 0.4 + energy * 0.3 do
        with_fx :echo, phase: 0.75, decay: 1.5 do
          phrase.each do |note_data|
            play note_data[:note],
              amp: [config[:melody_volume] * energy, config[:melody_volume] * config[:melody_max_amp]].min,
              release: note_data[:duration] * 0.8,
              pan: 0.1  # small, stable
            sleep note_data[:duration]
          end
        end
      end
      sleep 1
    else
      sleep 2
    end
  end
  
  # AMBIENCE（与 melody 错峰）
  live_loop :ambience, sync: :bar do
    energy = smooth_energy
    if energy < config[:ambient_energy_threshold]
      amb = @conductor.get_ambient_sample
      amb_rate = @conductor.get_ambient_rate
      with_fx :reverb, room: 0.8 do
        sample amb,
          amp: config[:ambient_volume] * get_sample_volume(amb),
          rate: amb_rate,
          pan: -0.1
      end
      sleep config[:ambient_sleep_duration]
    else
      sleep 4
    end
  end
  
  # FILLS
  live_loop :fills, sync: :bar do
    energy = smooth_energy
    bar_in_phrase = get(:bar_in_phrase)
    
    if config[:fill_only_at_phrase_end] && (bar_in_phrase == config[:bars_per_phrase] - 1)
      if @conductor.should_trigger_fill?(energy) && energy > 0.4
        fill_type = @conductor.get_fill_type
        fill_config = @conductor.get_fill_config(fill_type)
        
        (config[:beats_per_bar] - 1).times { sleep 1 }
        if fill_config[:notes] > 0
          fill_config[:notes].times do |i|
            sample_choice = fill_config[:samples].choose
            rate_val = rrand(fill_config[:rate_range].min, fill_config[:rate_range].max)
            if fill_config[:fx] == :bitcrusher
              with_fx :bitcrusher, bits: 4 do
                sample sample_choice,
                  amp: config[:fill_volume] * get_sample_volume(sample_choice),
                  rate: rate_val,
                  pan: 0.0
              end
            else
              sample sample_choice,
                amp: config[:fill_volume] * get_sample_volume(sample_choice),
                rate: rate_val,
                pan: 0.0
            end
            sleep fill_config[:sleep_time]
          end
        else
          sleep fill_config[:duration]
        end
      else
        sleep config[:beats_per_bar]
      end
    else
      sleep config[:beats_per_bar]
    end
  end
  
  # MONITOR
  live_loop :monitor, sync: :bar do
    if config[:debug_mode]
      energy = smooth_energy
      category = @conductor.get_energy_category_name(energy)
      puts "⚡️ Energy: #{(energy * 100).to_i}% | #{category} | Cycle: #{@conductor.cycle_number} | Bar: #{get(:bar_idx)}"
    end
    sleep 4
  end
end

puts "=" * 60
puts "🥁 DRUM CIRCLE DJ SHOW 🥁"
puts "Cycles: #{config[:perf_cycles]} | BPM: #{config[:base_bpm]} | Seed: #{config[:initial_seed]}"
puts "Duration: #{fade_params[:total].to_i}s (Fade In: #{config[:fade_in_dur]}s, Out: #{config[:fade_out_dur]}s)"
puts "=" * 60