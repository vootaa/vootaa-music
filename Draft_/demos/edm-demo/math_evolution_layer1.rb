# 数学演化轨道1 - 中等复杂度数学变异层
# 建议在基础轨道运行30秒后启动

# 加载共享数据
begin
  PI_DIGITS
rescue NameError
  load "/Users/tsb/Pop-Proj/edm/shared_constants.rb"
end

# 变量初始化
$evolution_tick ||= 0
$complexity_level ||= 0
$cosmic_stage ||= 0
$total_amplitude ||= 0.0
$digit_cache ||= {}

# 数学层专用标记
$math_layer_synced ||= false

use_debug false

puts "🔢 数学演化层1启动 [#{Time.now.strftime('%H:%M:%S')}] - 等待同步..."

# === 数学演化函数 ===

define :math_scale_generator do |base_note, constant|
  intervals = MATH_INTERVALS[constant] || MATH_INTERVALS[:pi]
  base_notes = intervals.map { |interval| note(base_note) + interval }
  
  tick = $evolution_tick || 0
  
  case constant
  when :pi
    base_notes.rotate((tick * 2) % base_notes.length)
  when :golden
    phi_point = (base_notes.length * 0.618).to_i
    base_notes.take(phi_point) + base_notes.drop(phi_point).reverse
  when :e
    base_notes.sort_by.with_index { |note_val, i| note_val + i * 0.1 }
  else
    base_notes
  end
end

define :smart_trigger do |base_threshold|
  tick = $evolution_tick || 0
  time_factor = [1.0 - (tick * 0.001), 0.3].max
  threshold = base_threshold * time_factor
  rand > [threshold, 0.1].max
end

define :layer_amp do |base_amp|
  total_amp = $total_amplitude || 0.0
  complexity = $complexity_level || 0
  
  global_factor = total_amp > 2.0 ? 0.6 : 1.0
  complexity_factor = 0.8 + complexity * 0.1
  base_amp * global_factor * complexity_factor
end

define :safe_math_rand do |min, max, constant = :pi|
  $evolution_tick ||= 0
  $digit_cache ||= {}
  
  digits = $digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :golden then GOLDEN_DIGITS
  when :e then E_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :euler then EULER_DIGITS
  else PI_DIGITS
  end
  
  index = $evolution_tick % digits.length
  digit = digits[index].to_i
  min + (digit / 9.0) * (max - min)
end

define :safe_cutoff do |base_cutoff, variation = 0|
  cutoff_value = base_cutoff + variation
  [[cutoff_value, 20].max, 130].min
end

# 检查并显示同步状态
define :check_sync_status do
  if !$math_layer_synced
    tick = $evolution_tick || 0
    puts "🔵 数学层同步成功！[#{Time.now.strftime('%H:%M:%S')}] Tick=#{tick}"
    $math_layer_synced = true
  end
end

# === 数学演化轨道 ===

live_loop :pi_sweeps, sync: :master_clock do
  check_sync_status  # 每次循环都检查同步状态
  
  complexity = $complexity_level || 0
  
  if complexity >= 1 && smart_trigger(0.7)
    use_synth :pulse
    cutoff_sweep = safe_cutoff(60, safe_math_rand(0, 40, :pi))
    amp = layer_amp(0.25)
    
    play :a4, amp: amp, cutoff: cutoff_sweep, release: 2,
         pan: safe_math_rand(-0.6, 0.6, :pi)
    
    puts "🔵 π扫频: #{cutoff_sweep.round}"
  end
  sleep 6
end

live_loop :golden_melodies, sync: :master_clock do
  complexity = $complexity_level || 0
  
  if complexity >= 1 && smart_trigger(0.6)
    use_synth :fm
    golden_notes = math_scale_generator(:c5, :golden)
    amp = layer_amp(0.2)
    note_count = (golden_notes.length * 0.618).to_i
    
    with_fx :echo, phase: 0.25, decay: 1.5, mix: 0.3 do
      note_count.times do |i|
        note_to_play = golden_notes[i % golden_notes.length]
        play note_to_play, amp: amp, release: 0.8,
             pan: safe_math_rand(-0.5, 0.5, :golden)
        sleep 0.5
      end
    end
    puts "🟡 黄金旋律: #{note_count}音符"
  else
    sleep 3
  end
end

live_loop :e_reverb, sync: :master_clock do
  complexity = $complexity_level || 0
  
  if complexity >= 2 && smart_trigger(0.8)
    reverb_room = 0.3 + safe_math_rand(0, 0.4, :e)
    reverb_mix = 0.2 + safe_math_rand(0, 0.3, :e)
    amp = layer_amp(0.15)
    
    with_fx :reverb, room: reverb_room, mix: reverb_mix do
      sample :ambi_soft_buzz, amp: amp,
             rate: safe_math_rand(0.8, 1.2, :e),
             pan: safe_math_rand(-0.7, 0.7, :e)
    end
    puts "🟢 e混响: #{reverb_room.round(2)}"
  end
  sleep 5
end

live_loop :sqrt2_harmonics, sync: :master_clock do
  complexity = $complexity_level || 0
  
  if complexity >= 2 && smart_trigger(0.5)
    use_synth :sine
    sqrt2_notes = math_scale_generator(:c4, :sqrt2)
    amp = layer_amp(0.18)
    harmony_notes = sqrt2_notes.take(3)
    
    cutoff_base = safe_cutoff(80, safe_math_rand(-20, 20, :sqrt2))
    
    with_fx :lpf, cutoff: cutoff_base do
      harmony_notes.each_with_index do |note_val, i|
        at i * 0.1 do
          play note_val, amp: amp, attack: 0.5, release: 3,
               pan: [-0.5, 0, 0.5][i]
        end
      end
    end
    puts "🟠 √2和声: #{harmony_notes.length}音符"
  end
  sleep 4
end

live_loop :fibonacci_rhythms, sync: :master_clock do
  complexity = $complexity_level || 0
  
  if complexity >= 3 && smart_trigger(0.4)
    use_synth :beep
    fib_sequence = [1, 1, 2, 3, 5, 8].take([complexity + 1, 6].min)
    cosmic_notes = COSMIC_SCALES[:stellar]
    amp = layer_amp(0.15)
    
    fib_sequence.each do |beat_length|
      if safe_math_rand(0, 1, :golden) > 0.6
        play cosmic_notes.sample, amp: amp,
             release: beat_length * 0.2,
             pan: safe_math_rand(-0.4, 0.4, :golden)
      end
      sleep beat_length * 0.125
    end
    puts "🔶 斐波那契: #{fib_sequence}"
  else
    sleep 2
  end
end

# 状态监控
live_loop :math_monitor, sync: :master_clock do
  sleep 25
  
  tick = $evolution_tick || 0
  complexity = $complexity_level || 0
  
  if tick > 0 && (tick % 80 == 0)
    puts "🔢 数学层状态: Lv#{complexity} | T#{tick} | 活跃中"
  end
end

puts "🎼 数学演化层1运行中..."