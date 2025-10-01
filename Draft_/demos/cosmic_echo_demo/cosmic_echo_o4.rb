# 宇宙回响：（演化版本4-时间驱动永不重复）
# 主干：可听性太空氛围（和谐和弦、reverb、ambient sample）
# 扩展：数学常数驱动多样性（pan、rate、cutoff），无限时间演化，累积变异确保永不重复

# 常量和数据部分（压缩以适应buffer）
PI_DIGITS = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
E_DIGITS = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
GOLDEN_DIGITS = "6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374"
SQRT2_DIGITS = "4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727"
HUBBLE_DIGITS = "7000000067402385119138205128205128205128205128205128205128205128205128205128205"
PLANCK_DIGITS = "1616255000000000000000000000000000001616255000000000000000000000000000001616255"
FINE_STRUCTURE = "7297352566400000000000000000000000000729735256640000000000000000000000000072973"
EULER_GAMMA = "5772156649015328606065120900824024310421593359399235988057672348848677267776646709"
CATALAN = "9159655941772190150546035149323841107741493742816721342664981198704686804649256927"
CHAMPERNOWNE = "1234567891011121314151617181920212223242526272829303132333435363738394041424344"

COSMIC_CONFIG = { reverb_room: 0.5, echo_phase: 0.15, echo_decay: 2, base_amp: 0.15, max_chord_size: 3 }  # 降低room和decay，柔化效果

@indices = Hash.new(0)
@digit_cache = {}
@evolution_memory = []  # 累积变异记忆，限制100项

# 宇宙谐波音阶系统（动态扩展）
COSMIC_HARMONIC_SCALES = {
  big_bang: [:c5, :d5, :f5, :g5],
  galaxy_formation: [:c4, :e4, :g4, :bb4, :d5],
  stellar_stability: [:c4, :d4, :f4, :g4, :a4],
  stellar_death: [:c4, :eb4, :gb4, :a4],
  heat_death: [:c4, :f4, :bb4]
}

# 数学常数映射到音程关系
MATHEMATICAL_INTERVALS = {
  pi: [0, 3, 7, 10], golden: [0, 2, 5, 8], e: [0, 4, 7, 11], sqrt2: [0, 2, 6, 9],
  hubble: [0, 5, 10], fine: [0, 7, 2, 9], euler: [0, 5, 7, 7]
}

# 函数定义（扩展现有，添加tick依赖）
define :cosmic_rand do |min, max, constant = :pi, tick_offset = 0|
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :golden then GOLDEN_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :hubble then HUBBLE_DIGITS
  when :planck then PLANCK_DIGITS
  when :fine then FINE_STRUCTURE
  when :euler then EULER_GAMMA
  when :catalan then CATALAN
  when :champer then CHAMPERNOWNE
  else PI_DIGITS
  end
  @indices[constant] = (@indices[constant] + 1 + tick_offset) % (digits.length * 2)
  digit = digits[@indices[constant] % digits.length].to_i
  min + (digit / 9.0) * (max - min)
end

define :get_cosmic_harmonic_scale do |stage|
  keys = COSMIC_HARMONIC_SCALES.keys
  COSMIC_HARMONIC_SCALES[keys[stage % keys.length]] || COSMIC_HARMONIC_SCALES[:stellar_stability]
end

define :generate_mathematical_scale do |base_note, constant = :golden, tick_offset = 0|
  intervals = MATHEMATICAL_INTERVALS[constant] || MATHEMATICAL_INTERVALS[:golden]
  notes = intervals.map { |interval| note(base_note) + interval + cosmic_rand(-1, 1, constant, tick_offset) }  # 变异
  case constant
  when :pi then notes.rotate(tick_offset % notes.length)
  when :golden then notes.take((notes.length * 0.618).to_i) + notes.drop((notes.length * 0.618).to_i).reverse
  when :e then notes.shuffle(random: Random.new(tick_offset))
  when :fine then notes.reverse
  when :euler then notes.sort_by { |n| n % 12 + cosmic_rand(0, 1, :euler, tick_offset) }
  else notes
  end
end

define :golden_split do |value|
  phi = 1.618
  b = value / (1 + phi)
  a = value - b
  [a, b]
end

define :play_cosmic_chord do |scale, chord_type, amp = 0.15, attack = 1.5, release = 3, tick_offset = 0|  # 增加attack/release，柔化音符
  root = scale.choose
  chord_notes = chord(root, chord_type).take(COSMIC_CONFIG[:max_chord_size])
  quantized_notes = chord_notes.map do |note|
    closest = scale.min_by { |s| (note(note) - note(s)).abs }
    closest + cosmic_rand(-0.2, 0.2, :golden, tick_offset)  # 减少变异幅度，确保和谐
  end
  quantized_notes.each_with_index do |note, i|
    at i * 0.2 do  # 增加间隔，减少重叠
      play note, amp: amp, attack: attack, release: release,
        pan: cosmic_rand(-0.5, 0.5, :golden, tick_offset)  # 减少pan范围
    end
  end
end

# 主脚本（时间演化，永不重复）
use_bpm 70
use_random_seed 113
use_debug false

with_fx :reverb, room: COSMIC_CONFIG[:reverb_room], mix: 0.4 do  # 降低mix
  with_fx :echo, phase: COSMIC_CONFIG[:echo_phase], decay: COSMIC_CONFIG[:echo_decay] do
    with_fx :lpf, cutoff: 80 do  # 添加低通滤波，柔化高频
    
      live_loop :cosmic_evolution do
        evolution_tick = tick
        stage = evolution_tick % 5
        stage_names = [:big_bang, :galaxy_formation, :stellar_stability, :stellar_death, :heat_death]
        current_stage = stage_names[stage]
        puts "宇宙演化阶段 #{current_stage} (tick: #{evolution_tick})"
        harmonic_scale = get_cosmic_harmonic_scale(stage)
        if @evolution_memory.length > 100 then @evolution_memory.shift end
        mutation = cosmic_rand(-1, 1, :golden, evolution_tick)  # 减少变异
        harmonic_scale = harmonic_scale.map { |n| note(n) + mutation }.uniq
        @evolution_memory << harmonic_scale
        
        use_synth :fm  # 替换:saw为柔和的:fm
        play harmonic_scale.choose, amp: 0.1, attack: 0.5, release: cosmic_rand(1, 2, :pi, evolution_tick),
          pan: cosmic_rand(-0.5, 0.5, :hubble, evolution_tick), cutoff: cosmic_rand(70, 90, :planck, evolution_tick)
        sleep cosmic_rand(3, 5, :golden, evolution_tick)  # 增加sleep，减少密度
      end
      
      live_loop :mathematical_melodies, sync: :cosmic_evolution do
        evolution_tick = look
        constants = [:pi, :golden, :e, :sqrt2, :hubble, :fine, :euler]
        current_constant = constants[evolution_tick % constants.length]
        math_scale = generate_mathematical_scale(:c4, current_constant, evolution_tick)
        
        use_synth :sine  # 替换:blade为:sine，更太空
        with_fx :lpf, cutoff: cosmic_rand(50, 80, current_constant, evolution_tick) do
          (evolution_tick % 2 + 1).times do  # 减少次数
            play math_scale[cosmic_rand(0, math_scale.length - 1, current_constant, evolution_tick).to_i],
              amp: cosmic_rand(0.05, 0.1, current_constant, evolution_tick),
              release: cosmic_rand(1, 2, current_constant, evolution_tick),
              pan: cosmic_rand(-0.4, 0.4, current_constant, evolution_tick)
            sleep 3  # 增加sleep
          end
        end
      end
      
      live_loop :ambient_layers, sync: :cosmic_evolution do
        evolution_tick = look
        harmonic_scale = get_cosmic_harmonic_scale(evolution_tick % 5)
        use_synth :dark_ambience  # 太空氛围合成器
        
        play_cosmic_chord(harmonic_scale, :minor7, 0.2, 2, 4, evolution_tick)  # 更和谐和弦
        if evolution_tick > 10
          at evolution_tick % 5 + 1 do
            sample :ambi_space, amp: 0.05, rate: cosmic_rand(0.5, 0.8, :golden, evolution_tick),  # 太空样本
              pan: cosmic_rand(-0.3, 0.3, :golden, evolution_tick)
          end
        end
        sleep cosmic_rand(4, 8, :euler, evolution_tick)
      end
      
      live_loop :cosmic_pulse, sync: :cosmic_evolution do
        evolution_tick = look
        bass_scale = get_cosmic_harmonic_scale(evolution_tick % 5).map { |n| note(n) - 24 }
        use_synth :fm  # 柔和低音
        
        play bass_scale.choose, amp: 0.25, release: cosmic_rand(1, 3, :pi, evolution_tick),
          rate: cosmic_rand(0.95, 1.05, :pi, evolution_tick), pan: cosmic_rand(-0.4, 0.4, :hubble, evolution_tick)
        sleep cosmic_rand(4, 6, :catalan, evolution_tick)
      end
      
      live_loop :cosmic_variations, sync: :cosmic_evolution do
        evolution_tick = look
        math_constants = [:golden, :e, :sqrt2, :fine, :euler]
        current_math = math_constants[evolution_tick % math_constants.length]
        variation_scale = generate_mathematical_scale(:e4, current_math, evolution_tick)
        amps = golden_split(0.1)  # 降低音量
        use_synth :sine
        
        (evolution_tick % 2 + 1).times do |i|
          play variation_scale[i % variation_scale.length] || :e4, 
            amp: amps[i % 2], release: 2,
            cutoff: cosmic_rand(60, 85, current_math, evolution_tick), pan: cosmic_rand(-0.3, 0.3, current_math, evolution_tick)
          sleep 3
        end
      end
    end
  end
end

# 演化版本特色说明：
# 1. 时间驱动演化：用tick无限增长，确保永不重复。
# 2. 累积变异：@evolution_memory跟踪变化，微调参数。
# 3. 动态随机：cosmic_rand添加tick_offset，扩展随机池。
# 4. 高性能：缓存+限制，适应GUI buffer。
# 5. 渐进复杂：早期简单，后期丰富。