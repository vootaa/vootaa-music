# 宇宙演化轨道2 - 高复杂度宇宙变异层
# 建议在数学层运行60秒后启动

# 加载共享数据
begin
  COSMIC_SCALES
rescue NameError
  load "/Users/tsb/Pop-Proj/edm/shared_constants.rb"
end

# 变量初始化
$evolution_tick ||= 0
$complexity_level ||= 0
$cosmic_stage ||= 0
$total_amplitude ||= 0.0
$digit_cache ||= {}

# 宇宙层专用标记
$cosmic_layer_synced ||= false

use_debug false

puts "🌌 宇宙演化层2启动 [#{Time.now.strftime('%H:%M:%S')}] - 等待同步..."

# === 核心函数 ===

define :get_cosmic_scale do
  stage = $cosmic_stage || 0
  scales_list = [COSMIC_SCALES[:big_bang], COSMIC_SCALES[:galaxy], 
                 COSMIC_SCALES[:stellar], COSMIC_SCALES[:death], COSMIC_SCALES[:heat]]
  scales_list[stage] || COSMIC_SCALES[:stellar]
end

define :cosmic_trigger do |threshold|
  complexity = $complexity_level || 0
  cosmic_stage = $cosmic_stage || 0
  factor = 1.0 + (complexity + cosmic_stage) * 0.15
  rand > (threshold / [factor, 5.0].min)
end

define :cosmic_amp do |base|
  total = $total_amplitude || 0.0
  cosmic = $cosmic_stage || 0
  global_factor = total > 3.0 ? 0.4 : 0.8
  (base * global_factor * (0.6 + cosmic * 0.1))
end

define :safe_cosmic_rand do |min, max, constant = :pi|
  tick = $evolution_tick || 0
  $digit_cache ||= {}
  
  digits = $digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :golden then GOLDEN_DIGITS
  when :e then E_DIGITS
  when :hubble then HUBBLE_DIGITS
  when :fine then FINE_DIGITS
  when :catalan then CATALAN_DIGITS
  else PI_DIGITS
  end
  
  index = tick % digits.length
  digit = digits[index].to_i
  min + (digit / 9.0) * (max - min)
end

define :safe_cutoff do |base_cutoff, variation = 0|
  cutoff_value = base_cutoff + variation
  [[cutoff_value, 20].max, 130].min
end

# 检查并显示同步状态
define :check_cosmic_sync do
  if !$cosmic_layer_synced
    tick = $evolution_tick || 0
    complexity = $complexity_level || 0
    puts "💥 宇宙层同步成功！[#{Time.now.strftime('%H:%M:%S')}] T#{tick} Lv#{complexity}"
    $cosmic_layer_synced = true
  end
end

# === 宇宙轨道 ===

live_loop :big_bang, sync: :master_clock do
  check_cosmic_sync  # 检查同步状态
  
  complexity = $complexity_level || 0
  cosmic = $cosmic_stage || 0
  
  if complexity >= 2 && cosmic == 0 && cosmic_trigger(0.8)
    use_synth :hollow
    cosmic_notes = get_cosmic_scale
    amp = cosmic_amp(0.3)
    
    with_fx :reverb, room: 0.9, mix: 0.7 do
      cosmic_notes.each_with_index do |note_val, i|
        at i * 0.05 do
          cutoff_val = safe_cutoff(80, i * 8)
          play note_val, amp: amp, attack: 0.1, release: 2 + i, 
               cutoff: cutoff_val, pan: safe_cosmic_rand(-1, 1, :pi)
        end
      end
    end
    puts "💥 宇宙大爆炸！"
  end
  sleep 8
end

live_loop :galaxy_spiral, sync: :master_clock do
  complexity = $complexity_level || 0
  cosmic = $cosmic_stage || 0
  
  if complexity >= 2 && [1,2].include?(cosmic) && cosmic_trigger(0.6)
    use_synth :blade
    cosmic_notes = get_cosmic_scale
    amp = cosmic_amp(0.25)
    
    with_fx :echo, phase: 0.375, decay: 3 do
      [3,5,8].sample.times do |i|
        note_to_play = cosmic_notes[i % cosmic_notes.length]
        cutoff_val = safe_cutoff(70, i * 6)
        
        play note_to_play, amp: amp, release: 1.5, cutoff: cutoff_val,
             pan: Math.sin(i * 0.5) * 0.8
        sleep safe_cosmic_rand(0.3, 0.8, :golden)
      end
    end
    puts "🌌 星系螺旋形成"
  end
  sleep 4
end

live_loop :stellar_death, sync: :master_clock do
  complexity = $complexity_level || 0
  cosmic = $cosmic_stage || 0
  
  if complexity >= 3 && cosmic == 3 && cosmic_trigger(0.5)
    use_synth :dark_ambience
    death_notes = COSMIC_SCALES[:death]
    amp = cosmic_amp(0.35)
    
    with_fx :reverb, room: 0.8, mix: 0.8 do
      death_notes.reverse.each_with_index do |note_val, i|
        cutoff_val = safe_cutoff(80, -i * 8)
        
        play note_val - (i * 3), amp: amp * (1.0 - i * 0.2),
             attack: 1, release: 4, cutoff: cutoff_val,
             pan: safe_cosmic_rand(-0.9, 0.9, :euler)
        sleep 1.5
      end
    end
    puts "🌑 恒星引力坍缩"
  end
  sleep 10
end

live_loop :transcendence, sync: :master_clock do
  complexity = $complexity_level || 0
  
  if complexity >= 4 && cosmic_trigger(0.3)
    use_synth :hollow
    cosmic_notes = get_cosmic_scale
    amp = cosmic_amp(0.2)
    
    factors = [safe_cosmic_rand(0.8, 1.2, :pi), 
               safe_cosmic_rand(0.9, 1.1, :golden), 
               safe_cosmic_rand(0.85, 1.15, :e)]
    
    with_fx :reverb, room: 0.9, mix: 0.9 do
      3.times do |i|
        at i * 0.5 do
          cutoff_val = safe_cutoff(60, i * 12)
          
          play cosmic_notes[i % cosmic_notes.length] + (i * 12),
               amp: amp * factors[i], attack: 1.5, release: 6,
               cutoff: cutoff_val, pan: [-0.7, 0, 0.7][i]
        end
      end
    end
    puts "✨ 数学超越和声"
  end
  sleep 12
end

live_loop :cosmic_ambient, sync: :master_clock do
  complexity = $complexity_level || 0
  
  if complexity >= 2 && cosmic_trigger(0.7)
    cosmic_notes = get_cosmic_scale
    amp = cosmic_amp(0.12)
    tick = $evolution_tick || 0
    
    with_fx :reverb, room: 0.7, mix: 0.5 do
      sample [:ambi_soft_buzz, :ambi_choir, :ambi_glass_hum].sample,
             amp: amp, rate: safe_cosmic_rand(0.5, 1.8, :hubble), 
             pan: Math.sin(tick * 0.05) * 0.6
    end
    
    if safe_cosmic_rand(0, 1, :fine) > 0.6
      at safe_cosmic_rand(1, 4, :catalan) do
        use_synth :sine
        cutoff_val = safe_cutoff(70, safe_cosmic_rand(-10, 20, :euler))
        
        play cosmic_notes.sample, amp: amp * 0.7, attack: 2, release: 5,
             cutoff: cutoff_val, pan: safe_cosmic_rand(-0.8, 0.8, :euler)
      end
    end
  end
  sleep 6
end

# 状态监控
live_loop :cosmic_monitor, sync: :master_clock do
  sleep 30
  
  tick = $evolution_tick || 0
  if tick > 0 && (tick % 120 == 0)
    stage_names = ["Big Bang", "Galaxy", "Stellar", "Death", "Heat Death"]
    cosmic = $cosmic_stage || 0
    complexity = $complexity_level || 0
    puts "🌌 宇宙状态: #{stage_names[cosmic]} | Lv#{complexity} | T#{tick}"
  end
end

puts "🎼 宇宙演化层2运行中..."