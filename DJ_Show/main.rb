# DRUM CIRCLE DJ SHOW - MAIN PERFORMANCE
# Perpetual mathematically-driven percussion showcase

# Load external libraries
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/config.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/math_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/energy_curve.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/drummer_patterns.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/lib/scale_modes.rb"

# Initialize global systems
use_random_seed INITIAL_SEED
use_bpm BASE_BPM
set_volume! SET_VOLUME

# Create system instances
@math = MathEngine.new(INITIAL_SEED)
@energy_system = EnergyCurve.new(CYCLE_LENGTH, GOLDEN_RATIO)
@patterns = DrummerPatterns.new
@scales = ScaleModes.new

# Global state
@cycle_start_time = Time.now
@cycle_number = 0
@last_energy = 0.0

# HELPER FUNCTIONS

define :current_energy do
  elapsed = Time.now - @cycle_start_time
  
  if elapsed >= CYCLE_LENGTH
    @cycle_number += 1
    @cycle_start_time = Time.now
    @math.apply_cycle_offset(@cycle_number)
    elapsed = 0
    puts "=== CYCLE #{@cycle_number} STARTED ===" if DEBUG_MODE
  end
  
  energy = @energy_system.calculate(elapsed)
  @last_energy = energy
  energy
end

define :should_play_drummer do |drummer_id, energy|
  threshold = case drummer_id
              when "A" then 0.2
              when "B" then 0.3
              when "C" then 0.5
              when "D" then 0.7
              else 0.5
              end
  
  active = energy > threshold && @math.get_next(:e) % 4 == (drummer_id.ord % 4)
  active
end

define :should_trigger_fill do |energy|
  inflection = @energy_system.detect_inflection(energy, FILL_THRESHOLD)
  random_trigger = @math.get_next(:golden) > 7
  
  (inflection || random_trigger) && energy > 0.4
end

# 修改此函数 - 应用音量校准和固定立体声位置
define :play_drum_pattern do |drummer_id, pattern, energy_scale|
  return unless pattern
  
  # 获取鼓手的固定 pan 位置
  drummer_pan = get_drummer_pan(drummer_id)
  
  pattern[:beats].each do |beat|
    in_thread do
      sleep beat[:time]
      
      # 获取样本的校准音量
      calibrated_volume = get_sample_volume(beat[:sample])
      
      sample beat[:sample],
             amp: beat[:amp] * energy_scale * DRUMMER_VOLUME * calibrated_volume,
             rate: beat.fetch(:rate, 1.0),
             pan: drummer_pan  # 使用鼓手固定位置，忽略 pattern 中的 pan: 0
    end
  end
  
  sleep pattern[:duration] + pattern[:breathe]
end

define :get_loop_start_pattern do |pattern_type|
  case pattern_type
  when 0
    [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]
  when 1
    [0.0, 0.25, 0.5, 0.75]
  when 2
    [0.0, 0.333, 0.666]
  else
    [0.0, 0.1, 0.3, 0.4, 0.6, 0.8]
  end
end

# LAYER 1: PULSE FOUNDATION (保持中央)

live_loop :pulse do
  sample [:bd_fat, :bd_haus].ring.tick, 
         amp: PULSE_VOLUME * get_sample_volume(:bd_fat),
         pan: 0  # 脉冲保持中央
  sleep 1
end

# LAYER 2: DRUMMER CONVERSATIONS (使用固定位置)

live_loop :drummer_a, sync: :pulse do
  energy = current_energy
  
  if should_play_drummer("A", energy)
    pattern_idx = @math.get_next(:pi) % @patterns.pattern_count("A")
    pattern = @patterns.get_pattern("A", pattern_idx)
    play_drum_pattern("A", pattern, energy)
  else
    sleep 2
  end
end

live_loop :drummer_b, sync: :pulse do
  energy = current_energy
  
  if should_play_drummer("B", energy)
    pattern_idx = @math.get_next(:pi) % @patterns.pattern_count("B")
    pattern = @patterns.get_pattern("B", pattern_idx)
    play_drum_pattern("B", pattern, energy)
  else
    sleep 2
  end
end

live_loop :drummer_c, sync: :pulse do
  energy = current_energy
  
  if should_play_drummer("C", energy)
    pattern_idx = @math.get_next(:pi) % @patterns.pattern_count("C")
    pattern = @patterns.get_pattern("C", pattern_idx)
    play_drum_pattern("C", pattern, energy)
  else
    sleep 2
  end
end

live_loop :drummer_d, sync: :pulse do
  energy = current_energy
  
  if should_play_drummer("D", energy)
    pattern_idx = @math.get_next(:pi) % @patterns.pattern_count("D")
    pattern = @patterns.get_pattern("D", pattern_idx)
    play_drum_pattern("D", pattern, energy)
  else
    sleep 2
  end
end

# LAYER 3: LOOP TEXTURE (应用音量校准，居中或轻微偏移)

live_loop :loop_texture, sync: :pulse do
  energy = current_energy
  
  if energy > 0.2
    loop_samples = [:loop_amen, :loop_compus, :loop_tabla, :loop_safari].ring
    current_sample = loop_samples.tick
    
    pattern_type = @math.get_next(:golden) % 4
    start_pattern = get_loop_start_pattern(pattern_type).ring
    
    sample current_sample,
           beat_stretch: 4,
           start: start_pattern.look,
           rate: [0.5, 1.0, 2.0].ring.look,
           amp: energy * LOOP_VOLUME * get_sample_volume(current_sample),
           pan: @math.map_to_range(@math.get_next(:sqrt2), -0.2, 0.2)  # 轻微偏移
    
    sleep 1
  else
    sleep 4
  end
end

# LAYER 4: MELODIC ORNAMENTS (随机立体声位置)

live_loop :melody, sync: :pulse do
  energy = current_energy
  
  if energy.between?(0.2, 0.8) && one_in(3)
    mode_idx = @math.get_next(:pi) % 12
    current_scale = @scales.get_scale_notes(:c4, mode_idx)
    
    phrase_length = rrand_i(3, 7)
    note_indices = phrase_length.times.map { @math.get_next(:e) }
    rhythm = [0.5, 1.0, 1.5].ring
    
    phrase = @scales.generate_phrase(current_scale, phrase_length, note_indices, rhythm)
    
    use_synth @scales.get_instrument_for_energy(energy)
    
    with_fx :reverb, room: energy * 0.5 do
      with_fx :echo, phase: 0.75, decay: 2 do
        phrase.each do |note_data|
          # 每个音符随机立体声位置
          random_pan = @math.map_to_range(@math.get_next(:sqrt2), -0.8, 0.8)
          
          play note_data[:note],
               amp: MELODY_VOLUME * energy * 1.5,  # 轻微提升旋律音量
               release: note_data[:duration] * 0.8,
               pan: random_pan
          
          sleep note_data[:duration]
        end
      end
    end
    
    sleep rrand(1, 2)
  else
    sleep 2
  end
end

# LAYER 5: AMBIENCE (应用音量校准，立体声宽度)

live_loop :ambience, sync: :pulse do
  energy = current_energy
  
  if energy < 0.4
    amb_samples = [:ambi_choir, :ambi_drone, :ambi_lunar_land].ring
    current_amb = amb_samples.tick
    
    # 氛围音左右声道交替
    amb_pan = [-0.5, 0.5].ring.look
    
    with_fx :reverb, room: 0.8 do
      sample current_amb,
             amp: AMBIENT_VOLUME * get_sample_volume(current_amb),
             rate: 0.9,
             pan: amb_pan
    end
    
    sleep 8
  else
    sleep 4
  end
end

# LAYER 5: FILLS & TRANSITIONS (随机立体声，应用音量校准)

live_loop :fills, sync: :pulse do
  energy = current_energy
  
  if should_trigger_fill(energy)
    fill_type = @math.get_next(:sqrt2) % 4
    
    case fill_type
    when 0  # Tom roll (跨立体声扫描)
      4.times do |i|
        tom_sample = [:drum_tom_hi_hard, :drum_tom_mid_hard, :drum_tom_lo_hard].choose
        # 从左到右扫描
        pan_position = @math.map_to_range(i * 2, -0.8, 0.8)
        
        sample tom_sample,
               amp: FILL_VOLUME * get_sample_volume(tom_sample),
               rate: rrand(0.9, 1.1),
               pan: pan_position
        sleep 0.25
      end
      
    when 1  # Cymbal crash (宽立体声)
      sample :drum_cymbal_open,
             amp: FILL_VOLUME * get_sample_volume(:drum_cymbal_open),
             rate: 0.9,
             pan: @math.map_to_range(@math.get_next(:golden), -0.6, 0.6)
      sleep 2
      
    when 2  # Glitch burst (快速立体声跳跃)
      glitch_sample = [:elec_blip2, :elec_twang, :elec_pop].choose
      with_fx :bitcrusher, bits: 4 do
        sample glitch_sample,
               amp: FILL_VOLUME * get_sample_volume(glitch_sample),
               rate: rrand(0.8, 1.5),
               pan: @math.map_to_range(@math.get_next(:sqrt2), -1.0, 1.0)
      end
      sleep 0.5
      
    else  # Rest
      sleep 1
    end
  end
  
  sleep 1
end

# PERFORMANCE MONITOR

live_loop :monitor, sync: :pulse do
  if DEBUG_MODE
    energy = current_energy
    category = @energy_system.get_category(energy)
    
    puts "Energy: #{(energy * 100).to_i}% | Category: #{category} | Cycle: #{@cycle_number}"
  end
  
  sleep 4
end

# INITIALIZATION MESSAGE

puts "DRUM CIRCLE DJ SHOW - ACTIVE"
puts "Cycle Length: #{CYCLE_LENGTH}s"
puts "Base BPM: #{BASE_BPM}"
puts "Master Volume: #{SET_VOLUME}"
puts "Seed: #{INITIAL_SEED}"
puts "Stereo Layout:"
puts "  Drummer A (West African): Left (-0.6)"
puts "  Drummer C (Latin): Center-Left (-0.3)"
puts "  Drummer D (Electronic): Center-Right"
puts "  Drummer B (Indian): Right (+0.6)"
puts "  Melody/Fills: Random positions"
puts "Press [Stop] to end performance"
