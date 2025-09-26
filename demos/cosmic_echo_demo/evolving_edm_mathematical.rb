# 数学驱动演化EDM：从传统EDM到复杂变异的有机演化
# 主干：经典EDM结构 (kick, hihat, bass, chord progression)
# 花色：数学常数驱动的渐进变异系统

# 数学常数定义
PI_DIGITS = "3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067"
GOLDEN_DIGITS = "1618033988749894848204586834365638117720309179805762862135448622705260462818902449707207204189391137"
E_DIGITS = "2718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427"
SQRT2_DIGITS = "1414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641573"
EULER_DIGITS = "0577215664901532860606512090082402431042159335939923598805767234884867726777664670936947063291746749"
PLANCK_DIGITS = "6626070040000000000000000000000000000662607004000000000000000000000000000066260700400000000000"

# 全局演化状态
@evolution_tick = 0
@digit_cache = {}
@complexity_level = 0

# 演化阶段定义
EVOLUTION_STAGES = {
  pure_edm: (0..50),
  light_mutation: (51..150), 
  medium_complexity: (151..300),
  high_complexity: (301..Float::INFINITY)
}

# EDM基础配置
use_bpm 124
use_random_seed 113
use_debug false

# 数学随机生成器
define :math_rand do |min, max, constant = :pi, offset = 0|
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :golden then GOLDEN_DIGITS
  when :e then E_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :euler then EULER_DIGITS
  when :planck then PLANCK_DIGITS
  else PI_DIGITS
  end
  
  index = (@evolution_tick + offset) % digits.length
  digit = digits[index].to_i
  min + (digit / 9.0) * (max - min)
end

# 演化因子计算
define :evolution_factor do |constant = :pi, base = 1.0, intensity = 0.1|
  stage_multiplier = case @complexity_level
  when 0 then 0.0  # Pure EDM: 无变异
  when 1 then 0.3  # Light: 30%强度
  when 2 then 0.7  # Medium: 70%强度
  when 3 then 1.0  # High: 100%强度
  else 1.0
  end
  
  math_factor = math_rand(0.5, 1.5, constant, @evolution_tick)
  base + (math_factor - 1.0) * intensity * stage_multiplier
end

# 激活概率计算
define :activation_chance do |base_threshold = 0.8|
  threshold = base_threshold - (@evolution_tick * 0.003)  # 逐渐降低阈值
  math_rand(0, 1, :golden, @evolution_tick) > [threshold, 0.1].max
end

# 更新演化状态
define :update_evolution do
  @evolution_tick += 1
  
  @complexity_level = case @evolution_tick
  when EVOLUTION_STAGES[:pure_edm] then 0
  when EVOLUTION_STAGES[:light_mutation] then 1  
  when EVOLUTION_STAGES[:medium_complexity] then 2
  when EVOLUTION_STAGES[:high_complexity] then 3
  else 3
  end
  
  if @evolution_tick % 50 == 0
    puts "Evolution Stage: #{@complexity_level}, Tick: #{@evolution_tick}"
  end
end

# === EDM主干结构 (固定) ===

live_loop :master_clock do
  sleep 1
  update_evolution
end

live_loop :kick_drum, sync: :master_clock do
  sample :bd_haus, amp: 1.2
  sleep 1
end

live_loop :hihat, sync: :master_clock do
  sleep 0.5
  sample :drum_cymbal_closed, amp: 0.6 * evolution_factor(:pi, 1.0, 0.2)
  sleep 0.5
end

live_loop :snare, sync: :master_clock do
  sleep 1
  sample :drum_snare_hard, amp: 0.8 * evolution_factor(:e, 1.0, 0.15)
  sleep 1
end

live_loop :bass_line, sync: :master_clock do
  use_synth :tb303
  use_synth_defaults release: 0.3, cutoff: 70, res: 0.8, amp: 0.9
  
  # 经典house bass pattern
  progression = [:a1, :a1, :f1, :c2]
  note_to_play = progression.tick
  
  # 数学驱动的cutoff调制
  cutoff_mod = @complexity_level > 0 ? 
    70 + math_rand(-10, 20, :pi, @evolution_tick) : 70
    
  play note_to_play, cutoff: cutoff_mod
  sleep 0.5
end

live_loop :chord_progression, sync: :master_clock do
  use_synth :saw
  use_synth_defaults release: 3, cutoff: 90, amp: 0.4
  
  # 基础和弦进行 Am-F-C-G
  chords = [
    chord(:a3, :minor),
    chord(:f3, :major), 
    chord(:c4, :major),
    chord(:g3, :major)
  ]
  
  current_chord = chords.tick
  
  # 黄金比例驱动的和弦扩展
  if @complexity_level >= 2 && activation_chance(0.6)
    # 添加延伸音
    extension_notes = [:d4, :e4, :g4].sample(
      (math_rand(1, 3, :golden, @evolution_tick)).to_i
    )
    current_chord = current_chord + extension_notes
  end
  
  with_fx :reverb, room: 0.3 * evolution_factor(:e, 1.0, 0.3) do
    play current_chord
  end
  
  sleep 4
end

# === 数学驱动的变异层 ===

live_loop :pi_filter_sweep, sync: :master_clock do
  if @complexity_level >= 1
    use_synth :pulse
    use_synth_defaults amp: 0.3, release: 2
    
    # π驱动滤波器扫频
    cutoff_sweep = 60 + math_rand(0, 40, :pi, @evolution_tick)
    
    play :a4, cutoff: cutoff_sweep, 
      pan: math_rand(-0.5, 0.5, :pi, @evolution_tick + 10)
  end
  
  sleep 8
end

live_loop :golden_rhythm_variation, sync: :master_clock do
  if @complexity_level >= 2 && activation_chance(0.7)
    use_synth :beep
    use_synth_defaults amp: 0.25, release: 0.5
    
    # 黄金比例驱动的节拍细分
    subdivision = [0.25, 0.375, 0.5].sample
    golden_factor = math_rand(0.8, 1.2, :golden, @evolution_tick)
    
    play [:c5, :d5, :e5].sample, 
      pan: math_rand(-0.7, 0.7, :golden, @evolution_tick)
    
    sleep subdivision * golden_factor
  else
    sleep 2
  end
end

live_loop :e_reverb_modulation, sync: :master_clock do
  if @complexity_level >= 1 && activation_chance(0.8)
    # e常数控制混响参数
    reverb_room = 0.2 + math_rand(0, 0.6, :e, @evolution_tick) * 0.01 * @complexity_level
    reverb_mix = 0.3 + math_rand(0, 0.4, :e, @evolution_tick + 20) * 0.01 * @complexity_level
    
    with_fx :reverb, room: reverb_room, mix: reverb_mix do
      sample :ambi_soft_buzz, amp: 0.2, 
        rate: math_rand(0.7, 1.3, :e, @evolution_tick)
    end
  end
  
  sleep 6
end

live_loop :sqrt2_pitch_modulation, sync: :master_clock do
  if @complexity_level >= 2 && activation_chance(0.6)
    use_synth :fm
    use_synth_defaults amp: 0.2, release: 1.5
    
    # √2驱动的音高调制
    base_notes = [:a3, :c4, :e4, :g4]
    note_to_play = base_notes.sample
    pitch_bend = math_rand(-0.3, 0.3, :sqrt2, @evolution_tick)
    
    play note_to_play + pitch_bend,
      pan: math_rand(-0.8, 0.8, :sqrt2, @evolution_tick + 30)
  end
  
  sleep 4
end

live_loop :planck_micro_variations, sync: :master_clock do
  if @complexity_level >= 3 && activation_chance(0.5)
    use_synth :sine
    use_synth_defaults amp: 0.15, release: 2
    
    # 普朗克常数驱动微小变异
    micro_detune = math_rand(-0.05, 0.05, :planck, @evolution_tick)
    micro_pan = math_rand(-0.3, 0.3, :planck, @evolution_tick + 40)
    
    play :c5 + micro_detune, pan: micro_pan
  end
  
  sleep 3
end

live_loop :euler_stereo_effects, sync: :master_clock do
  if @complexity_level >= 2 && activation_chance(0.7)
    # 欧拉常数控制立体声效果
    stereo_width = math_rand(0.3, 1.0, :euler, @evolution_tick)
    pan_position = math_rand(-1.0, 1.0, :euler, @evolution_tick + 50)
    
    with_fx :echo, phase: 0.125 * stereo_width do
      sample :bd_zome, amp: 0.3, pan: pan_position,
        rate: math_rand(0.8, 1.2, :euler, @evolution_tick)
    end
  end
  
  sleep 5
end

live_loop :complexity_buildup, sync: :master_clock do
  if @complexity_level >= 3 && activation_chance(0.4)
    # 高复杂度：多常数混合变异
    use_synth :dark_ambience
    
    pi_factor = math_rand(0.5, 1.5, :pi, @evolution_tick)
    golden_factor = math_rand(0.7, 1.3, :golden, @evolution_tick + 10)
    e_factor = math_rand(0.8, 1.2, :e, @evolution_tick + 20)
    
    mixed_cutoff = 80 * pi_factor * golden_factor * e_factor / 3
    mixed_amp = 0.2 * (pi_factor + golden_factor + e_factor) / 3
    
    play [:a2, :c3, :e3].sample, 
      amp: mixed_amp, cutoff: mixed_cutoff,
      release: 3 * e_factor,
      pan: math_rand(-1, 1, :sqrt2, @evolution_tick)
  end
  
  sleep 7
end