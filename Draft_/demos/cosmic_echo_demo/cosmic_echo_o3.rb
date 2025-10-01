# 宇宙回响：远古星系的冥想之音（融合版本3）
# 主干：可听性太空氛围（和谐和弦、reverb、ambient sample）
# 扩展：数学常数驱动多样性（pan、rate、cutoff），模拟宇宙演化阶段，引入宇宙谐波音阶系统和动态数学音阶生成

# 常量和数据部分
PI_DIGITS = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
E_DIGITS = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
GOLDEN_DIGITS = "6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374"
SQRT2_DIGITS = "4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727"
SQRT3_DIGITS = "7320508075688772935274463415058723669428052538103806280558069794519330169088000370811461867572485756"

HUBBLE_DIGITS = "7000000067402385119138205128205128205128205128205128205128205128205128205128205"
PLANCK_DIGITS = "1616255000000000000000000000000000001616255000000000000000000000000000001616255"
FINE_STRUCTURE = "7297352566400000000000000000000000000729735256640000000000000000000000000072973"
EULER_GAMMA = "5772156649015328606065120900824024310421593359399235988057672348848677267776646709"
CATALAN = "9159655941772190150546035149323841107741493742816721342664981198704686804649256927"
CHAMPERNOWNE = "1234567891011121314151617181920212223242526272829303132333435363738394041424344"

COSMIC_CONFIG = {
  reverb_room: 0.65,
  echo_phase: 0.25,
  echo_decay: 3,
  base_amp: 0.2,
  max_chord_size: 3
}

@indices = Hash.new(0)
@digit_cache = {}

# 宇宙谐波音阶系统（基于天体物理学的频率比例）
COSMIC_HARMONIC_SCALES = {
  big_bang: [:c5, :d5, :f5, :g5],                    # 四度共振，初始爆发
  galaxy_formation: [:c4, :e4, :g4, :bb4, :d5],      # 大七和弦，复杂结构诞生
  stellar_stability: [:c4, :d4, :f4, :g4, :a4],      # 五声音阶，稳定和谐
  stellar_death: [:c4, :eb4, :gb4, :a4],             # 减七和弦，引力坍缩
  heat_death: [:c4, :f4, :bb4]                       # 三全音，宇宙的孤寂
}

# 数学常数映射到音程关系
MATHEMATICAL_INTERVALS = {
  pi: [0, 3, 7, 10],
  golden: [0, 2, 5, 8],
  e: [0, 4, 7, 11],
  sqrt2: [0, 2, 6, 9],
  hubble: [0, 5, 10],
  fine: [0, 7, 2, 9],
  euler: [0, 5, 7, 7]
}

define :cosmic_rand do |min, max, constant = :pi|
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :golden then GOLDEN_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :sqrt3 then SQRT3_DIGITS
  when :hubble then HUBBLE_DIGITS
  when :planck then PLANCK_DIGITS
  when :fine then FINE_STRUCTURE
  when :euler then EULER_GAMMA
  when :catalan then CATALAN
  when :champer then CHAMPERNOWNE
  else PI_DIGITS
  end
  
  @indices[constant] = (@indices[constant] + 1) % (digits.length * 2)
  digit = digits[@indices[constant] % digits.length].to_i
  
  min + (digit / 9.0) * (max - min)
end

define :get_cosmic_harmonic_scale do |stage|
  case stage
  when 0 then COSMIC_HARMONIC_SCALES[:big_bang]
  when 1 then COSMIC_HARMONIC_SCALES[:galaxy_formation]
  when 2 then COSMIC_HARMONIC_SCALES[:stellar_stability]
  when 3 then COSMIC_HARMONIC_SCALES[:stellar_death]
  when 4 then COSMIC_HARMONIC_SCALES[:heat_death]
  else COSMIC_HARMONIC_SCALES[:stellar_stability]
  end
end

define :generate_mathematical_scale do |base_note, constant = :golden|
  intervals = MATHEMATICAL_INTERVALS[constant] || MATHEMATICAL_INTERVALS[:golden]
  notes = intervals.map { |interval| note(base_note) + interval }
  
  case constant
  when :pi
    notes.rotate(3)
  when :golden
    phi_index = (notes.length * 0.618).to_i
    notes.take(phi_index) + notes.drop(phi_index).reverse
  when :e
    notes.shuffle(random: Random.new(271))
  when :fine
    notes.reverse
  when :euler
    notes.sort_by { |n| n % 12 }
  else
    notes
  end
end

define :golden_split do |value|
  phi = 1.618
  b = value / (1 + phi)
  a = value - b
  [a, b]
end

define :play_cosmic_chord do |scale, chord_type, amp = 0.2, attack = 1, release = 2|
  root = scale.choose
  chord_notes = chord(root, chord_type).take(COSMIC_CONFIG[:max_chord_size])
  
  quantized_notes = chord_notes.map do |note|
    closest_scale_note = scale.min_by { |scale_note| (note(note) - note(scale_note)).abs }
    closest_scale_note
  end
  
  quantized_notes.each_with_index do |note, i|
    at i * 0.1 do
      play note, amp: amp, attack: attack, release: release,
        pan: cosmic_rand(-0.8, 0.8, :golden)
    end
  end
end

use_bpm 70
use_random_seed 113
use_debug false

with_fx :reverb, room: COSMIC_CONFIG[:reverb_room], mix: 0.6 do
  with_fx :echo, phase: COSMIC_CONFIG[:echo_phase], decay: COSMIC_CONFIG[:echo_decay] do
    
    live_loop :cosmic_evolution do
      stage = tick % 5
      harmonic_scale = get_cosmic_harmonic_scale(stage)
      puts "宇宙演化阶段 #{stage}"
      
      case stage
      when 0
        use_synth :saw
        play harmonic_scale.choose, amp: 0.12, attack: 0.1, release: 0.5,
          pan: cosmic_rand(-0.8, 0.8, :hubble), cutoff: cosmic_rand(90, 120, :planck)
        sleep 2
      when 1
        use_synth :hollow
        play_cosmic_chord(harmonic_scale, :minor, 0.2, 1, 2)
        sleep 4
      when 2
        use_synth :fm
        play_cosmic_chord(harmonic_scale, :major7, 0.18, 0.5, 5.5)
        sleep 6
      when 3
        use_synth :bass_foundation
        play harmonic_scale.choose, amp: 0.15, release: 7,
          rate: cosmic_rand(0.6, 1.0, :catalan), pan: cosmic_rand(-0.6, 0.6, :champer)
        sleep 8
      when 4
        use_synth :sine
        play harmonic_scale.choose, amp: 0.08, attack: 2, release: 7,
          pan: cosmic_rand(-0.3, 0.3, :sqrt2)
        sleep 10
      end
    end
    
    live_loop :mathematical_melodies, sync: :cosmic_evolution do
      stage = look % 5
      constants = [:pi, :golden, :e, :sqrt2, :hubble, :fine, :euler]
      current_constant = constants[stage % constants.length]
      math_scale = generate_mathematical_scale(:c4, current_constant)
      
      use_synth :blade
      with_fx :lpf, cutoff: cosmic_rand(60, 100, current_constant) do
        (stage + 1).times do
          play math_scale[cosmic_rand(0, math_scale.length - 1, current_constant).to_i],
            amp: cosmic_rand(0.08, 0.15, current_constant),
            release: cosmic_rand(0.5, 1.5, current_constant),
            pan: cosmic_rand(-0.7, 0.7, current_constant)
          sleep 2
        end
      end
    end
    
    live_loop :ambient_layers, sync: :cosmic_evolution do
      stage = look % 5
      harmonic_scale = get_cosmic_harmonic_scale(stage)
      use_synth :hollow
      
      play_cosmic_chord(harmonic_scale, :minor, 0.25, stage * 0.5 + 0.5, stage * 2 + 1.5)
      if stage > 0
        at stage + 1 do
          sample :ambi_glass_hum, amp: 0.08, rate: cosmic_rand(0.4, 0.6, :golden),
            pan: cosmic_rand(-0.5, 0.5, :golden)
        end
      end
      sleep [2, 4, 6, 8, 10][stage]
    end
    
    live_loop :cosmic_pulse, sync: :cosmic_evolution do
      stage = look % 5
      bass_scale = get_cosmic_harmonic_scale(stage).map { |n| note(n) - 24 }
      use_synth :bass_foundation
      
      case stage
      when 0
        play bass_scale.choose, amp: 0.3, release: 0.4,
          rate: cosmic_rand(0.9, 1.1, :pi), pan: cosmic_rand(-0.6, 0.6, :hubble)
        sleep 2
      when 1
        2.times do
          play bass_scale.choose, amp: 0.3, release: 0.8,
            rate: cosmic_rand(0.9, 1.1, :pi), pan: cosmic_rand(-0.6, 0.6, :hubble)
          sleep 2
        end
      when 2
        2.times do
          play bass_scale.choose, amp: 0.3, release: 2.5,
            rate: cosmic_rand(0.9, 1.1, :pi), pan: cosmic_rand(-0.6, 0.6, :hubble)
          sleep 3
        end
      when 3
        2.times do
          play bass_scale.choose, amp: 0.3, release: 3.5,
            rate: cosmic_rand(0.9, 1.1, :pi), pan: cosmic_rand(-0.6, 0.6, :hubble)
          sleep 4
        end
      when 4
        2.times do
          play bass_scale.choose, amp: 0.3, release: 4.5,
            rate: cosmic_rand(0.9, 1.1, :pi), pan: cosmic_rand(-0.6, 0.6, :hubble)
          sleep 5
        end
      end
    end
    
    live_loop :cosmic_variations, sync: :cosmic_evolution do
      stage = look % 5
      math_constants = [:golden, :e, :sqrt2, :fine, :euler]
      current_math = math_constants[stage % math_constants.length]
      variation_scale = generate_mathematical_scale(:e4, current_math)
      amps = golden_split(0.12)
      use_synth :hollow
      
      (stage + 1).times do |i|
        play variation_scale[i % variation_scale.length] || :e4, 
          amp: amps[i % 2], release: 1.5,
          cutoff: cosmic_rand(70, 95, current_math), pan: cosmic_rand(-0.5, 0.5, current_math)
        sleep 2
      end
    end
  end
end

# 融合版本特色说明：
# 1. 宇宙谐波系统：每个演化阶段都有独特的音阶特征
# 2. 数学常数驱动：专门的旋律层展现数学美学
# 3. 智能音阶量化：确保和谐性的同时保持数学驱动的随机性
# 4. 黄金比例时间分割：连接数学与音乐时间结构
# 5. 多层次融合：宇宙物理学概念与抽象数学完美结合
# 6. 动态音阶生成：根据不同数学常数特性调整音乐结构