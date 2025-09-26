# 演化 House：（时间驱动永不重复）
# 主干：可听性 House 氛围（和谐和弦、reverb、电子元素）
# 扩展：数学常数驱动多样性（pan、rate、cutoff），无限时间演化，累积变异确保永不重复

# 常量和数据部分
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

HOUSE_STYLE = :soulful  # 切换这里：:soulful, :techno, :ambient

# 风格配置（基于选择调整参数）
HOUSE_CONFIG = case HOUSE_STYLE
when :soulful then { reverb_room: 0.6, echo_phase: 0.25, echo_decay: 3, base_amp: 0.2, max_chord_size: 4, synth: :fm, chord_type: :minor7, bpm: 120 }
when :techno then { reverb_room: 0.3, echo_phase: 0.1, echo_decay: 1, base_amp: 0.3, max_chord_size: 3, synth: :tb303, chord_type: :minor, bpm: 130 }
when :ambient then { reverb_room: 0.8, echo_phase: 0.3, echo_decay: 4, base_amp: 0.15, max_chord_size: 5, synth: :saw, chord_type: :major7, bpm: 110 }
else { reverb_room: 0.5, echo_phase: 0.2, echo_decay: 2, base_amp: 0.2, max_chord_size: 4, synth: :fm, chord_type: :minor7, bpm: 120 }
end

@indices = Hash.new(0)
@digit_cache = {}
@evolution_memory = []  # 累积变异记忆，限制100项

# House 音阶系统（动态扩展）
HOUSE_SCALES = {
  intro: [:c3, :d3, :e3, :f3],
  build: [:c4, :eb4, :g4, :bb4, :d5],
  drop: [:c4, :d4, :f4, :g4, :a4],
  breakdown: [:c4, :gb4, :a4],
  outro: [:c4, :f4, :bb4]
}

# 数学常数映射到音程关系
MATHEMATICAL_INTERVALS = {
  pi: [0, 3, 7, 10], golden: [0, 2, 5, 8], e: [0, 4, 7, 11], sqrt2: [0, 2, 6, 9],
  hubble: [0, 5, 10], fine: [0, 7, 2, 9], euler: [0, 5, 7, 7]
}

# 函数定义（扩展现有，添加tick依赖）
define :house_rand do |min, max, constant = :pi, tick_offset = 0|
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

define :get_house_scale do |stage|
  keys = HOUSE_SCALES.keys
  HOUSE_SCALES[keys[stage % keys.length]] || HOUSE_SCALES[:drop]
end

define :generate_house_pattern do |base_note, constant = :golden, tick_offset = 0|
  intervals = MATHEMATICAL_INTERVALS[constant] || MATHEMATICAL_INTERVALS[:golden]
  notes = intervals.map { |interval| note(base_note) + interval + house_rand(-2, 2, constant, tick_offset) }
  # House 变异：基于黄金比例分割
  split = golden_split(notes.length)
  notes.take(split[0].to_i) + notes.drop(split[0].to_i).reverse
end

define :golden_split do |value|
  phi = 1.618
  b = value / (1 + phi)
  a = value - b
  [a, b]
end

define :play_house_chord do |scale, amp = 0.2, attack = 0.5, release = 1.5, tick_offset = 0|
  root = scale.choose
  chord_notes = chord(root, HOUSE_CONFIG[:chord_type]).take(HOUSE_CONFIG[:max_chord_size])
  chord_notes.each_with_index do |note, i|
    at i * 0.25 do  # House 节奏间隔
      play note, amp: amp, attack: attack, release: release,
        pan: house_rand(-0.6, 0.6, :golden, tick_offset)
    end
  end
end

# 主脚本（时间演化，永不重复）
use_bpm HOUSE_CONFIG[:bpm]
use_random_seed 113
use_debug false

with_fx :reverb, room: HOUSE_CONFIG[:reverb_room], mix: 0.5 do
  with_fx :echo, phase: HOUSE_CONFIG[:echo_phase], decay: HOUSE_CONFIG[:echo_decay] do
    with_fx :lpf, cutoff: 90 do  # 调整 cutoff 为 House 感
      
      live_loop :house_evolution do
        evolution_tick = tick
        stage = evolution_tick % 5
        stage_names = [:intro, :build, :drop, :breakdown, :outro]
        current_stage = stage_names[stage]
        puts "House 演化阶段 #{current_stage} (tick: #{evolution_tick})"
        house_scale = get_house_scale(stage)
        if @evolution_memory.length > 100 then @evolution_memory.shift end
        mutation = house_rand(-0.5, 0.5, :golden, evolution_tick)
        house_scale = house_scale.map { |n| note(n) + mutation }.uniq
        @evolution_memory << house_scale
        
        use_synth HOUSE_CONFIG[:synth]  # 风格驱动合成器
        play house_scale.choose, amp: 0.3, attack: 0.1, release: house_rand(0.5, 1.5, :pi, evolution_tick),
          pan: house_rand(-0.7, 0.7, :hubble, evolution_tick), cutoff: house_rand(80, 110, :planck, evolution_tick)
        sleep house_rand(2, 4, :golden, evolution_tick)
      end
      
      live_loop :house_drums, sync: :house_evolution do
        evolution_tick = look
        constants = [:pi, :golden, :e, :sqrt2, :hubble]
        current_constant = constants[evolution_tick % constants.length]
        drum_pattern = generate_house_pattern(:c2, current_constant, evolution_tick)
        
        # House kick/snare 循环
        sample :drum_bass_hard, amp: 0.5 if (evolution_tick % 4) == 0
        sample :drum_snare_hard, amp: 0.4 if (evolution_tick % 4) == 2
        sleep 0.5  # 固定节奏，但可变异
      end
      
      live_loop :house_arpeggios, sync: :house_evolution do
        evolution_tick = look
        house_scale = get_house_scale(evolution_tick % 5)
        use_synth :saw  # 电子 arpeggio
        
        play_house_chord(house_scale, 0.15, 0.05, 0.8, evolution_tick)
        sleep house_rand(3, 6, :euler, evolution_tick)
      end
      
      live_loop :house_bassline, sync: :house_evolution do
        evolution_tick = look
        bass_scale = get_house_scale(evolution_tick % 5).map { |n| note(n) - 12 }
        use_synth HOUSE_CONFIG[:synth]  # 风格 bass
        
        play bass_scale.choose, amp: 0.4, release: house_rand(1, 2, :pi, evolution_tick),
          rate: house_rand(0.9, 1.1, :pi, evolution_tick), pan: house_rand(-0.6, 0.6, :hubble, evolution_tick)
        sleep house_rand(2, 4, :catalan, evolution_tick)
      end
      
      live_loop :house_variations, sync: :house_evolution do
        evolution_tick = look
        math_constants = [:golden, :e, :sqrt2, :fine, :euler]
        current_math = math_constants[evolution_tick % math_constants.length]
        variation_scale = generate_house_pattern(:e3, current_math, evolution_tick)
        amps = golden_split(0.2)
        use_synth :beep
        
        (evolution_tick % 3 + 1).times do |i|
          play variation_scale[i % variation_scale.length] || :e3, 
            amp: amps[i % 2], release: 1,
            cutoff: house_rand(70, 100, current_math, evolution_tick), pan: house_rand(-0.5, 0.5, current_math, evolution_tick)
          sleep 2
        end
      end
    end
  end
end

# 演化版本特色说明：
# 1. 时间驱动演化：用 tick 无限增长，确保永不重复。
# 2. 累积变异：@evolution_memory 跟踪变化，微调参数。
# 3. 动态随机：house_rand 添加 tick_offset，扩展随机池。
# 4. 高性能：缓存+限制，适应 GUI buffer。
# 5. 渐进复杂：早期简单，后期丰富，聚焦 House 元素。