# 宇宙回响：（空灵版本5-增强太空冥想）
# 主干：可听性太空氛围（和谐和弦、reverb、ambient sample）
# 扩展：数学常数驱动多样性（pan、rate、cutoff），无限时间演化，累积变异确保永不重复，增强空灵效果

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

COSMIC_CONFIG = { reverb_room: 0.7, echo_phase: 0.2, echo_decay: 4, base_amp: 0.1, max_chord_size: 3 }
@indices = Hash.new(0)
@digit_cache = {}
@evolution_memory = []

COSMIC_HARMONIC_SCALES = {
  big_bang: [:c5, :d5, :f5, :g5],
  galaxy_formation: [:c4, :e4, :g4, :bb4, :d5],
  stellar_stability: [:c4, :d4, :f4, :g4, :a4],
  stellar_death: [:c4, :eb4, :gb4, :a4],
  heat_death: [:c4, :f4, :bb4]
}

MATHEMATICAL_INTERVALS = {
  pi: [0, 3, 7, 10], golden: [0, 2, 5, 8], e: [0, 4, 7, 11], sqrt2: [0, 2, 6, 9],
  hubble: [0, 5, 10], fine: [0, 7, 2, 9], euler: [0, 5, 7, 7]
}

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
  notes = intervals.map { |interval| note(base_note) + interval + cosmic_rand(-0.5, 0.5, constant, tick_offset) }
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

define :play_cosmic_chord do |scale, chord_type, amp = 0.1, attack = 2, release = 4, tick_offset = 0|
  root = scale.choose
  chord_notes = chord(root, chord_type).take(COSMIC_CONFIG[:max_chord_size])
  quantized_notes = chord_notes.map do |note|
    closest = scale.min_by { |s| (note(note) - note(s)).abs }
    closest + cosmic_rand(-0.3, 0.3, :golden, tick_offset)
  end
  quantized_notes.each_with_index do |note, i|
    at i * 0.3 do
      play note, amp: amp, attack: attack, release: release,
        pan: cosmic_rand(-0.7, 0.7, :golden, tick_offset)
    end
  end
end

use_bpm 60
use_random_seed 113
use_debug false

with_fx :reverb, room: COSMIC_CONFIG[:reverb_room], mix: 0.7 do
  with_fx :echo, phase: COSMIC_CONFIG[:echo_phase], decay: COSMIC_CONFIG[:echo_decay] do
    with_fx :lpf, cutoff: 70 do
      
      live_loop :cosmic_evolution do
        evolution_tick = tick
        stage = evolution_tick % 5
        stage_names = [:big_bang, :galaxy_formation, :stellar_stability, :stellar_death, :heat_death]
        current_stage = stage_names[stage]
        puts "宇宙演化阶段 #{current_stage} (tick: #{evolution_tick})"
        harmonic_scale = get_cosmic_harmonic_scale(stage)
        if @evolution_memory.length > 100 then @evolution_memory.shift end
        mutation = cosmic_rand(-0.5, 0.5, :golden, evolution_tick)
        harmonic_scale = harmonic_scale.map { |n| note(n) + mutation }.uniq
        @evolution_memory << harmonic_scale
        
        use_synth :fm
        play harmonic_scale.choose, amp: 0.06, attack: 1, release: cosmic_rand(2, 4, :pi, evolution_tick),
          pan: cosmic_rand(-0.6, 0.6, :hubble, evolution_tick), cutoff: cosmic_rand(60, 90, :planck, evolution_tick)
        sleep cosmic_rand(4, 6, :golden, evolution_tick)
      end
      
      live_loop :mathematical_melodies, sync: :cosmic_evolution do
        evolution_tick = look
        constants = [:pi, :golden, :e, :sqrt2, :hubble, :fine, :euler]
        current_constant = constants[evolution_tick % constants.length]
        math_scale = generate_mathematical_scale(:c4, current_constant, evolution_tick)
        
        use_synth :fm
        with_fx :lpf, cutoff: cosmic_rand(40, 70, current_constant, evolution_tick) do
          (evolution_tick % 2 + 1).times do
            play math_scale[cosmic_rand(0, math_scale.length - 1, current_constant, evolution_tick).to_i],
              amp: cosmic_rand(0.04, 0.08, current_constant, evolution_tick),
              release: cosmic_rand(2, 4, current_constant, evolution_tick),
              pan: cosmic_rand(-0.6, 0.6, current_constant, evolution_tick)
            sleep 4
          end
        end
      end
      
      live_loop :ambient_layers, sync: :cosmic_evolution do
        evolution_tick = look
        harmonic_scale = get_cosmic_harmonic_scale(evolution_tick % 5)
        use_synth :sine
        
        play_cosmic_chord(harmonic_scale, :minor7, 0.15, 3, 6, evolution_tick)
        if evolution_tick > 5
          at evolution_tick % 5 + 1 do
            sample :ambi_space, amp: 0.04, rate: cosmic_rand(0.4, 0.7, :golden, evolution_tick),
              pan: cosmic_rand(-0.5, 0.5, :golden, evolution_tick)
            sample :perc_bell, amp: 0.03, rate: cosmic_rand(0.6, 1.0, :euler, evolution_tick),
              pan: cosmic_rand(-0.4, 0.4, :euler, evolution_tick)
          end
        end
        sleep cosmic_rand(6, 10, :euler, evolution_tick)
      end
      
      live_loop :cosmic_pulse, sync: :cosmic_evolution do
        evolution_tick = look
        bass_scale = get_cosmic_harmonic_scale(evolution_tick % 5).map { |n| note(n) - 12 }
        use_synth :fm
        
        play bass_scale.choose, amp: 0.15, release: cosmic_rand(2, 5, :pi, evolution_tick),
          rate: cosmic_rand(0.95, 1.05, :pi, evolution_tick), pan: cosmic_rand(-0.5, 0.5, :hubble, evolution_tick)
        sleep cosmic_rand(5, 8, :catalan, evolution_tick)
      end
      
      live_loop :cosmic_variations, sync: :cosmic_evolution do
        evolution_tick = look
        math_constants = [:golden, :e, :sqrt2, :fine, :euler]
        current_math = math_constants[evolution_tick % math_constants.length]
        variation_scale = generate_mathematical_scale(:e4, current_math, evolution_tick)
        amps = golden_split(0.08)
        use_synth :fm
        
        (evolution_tick % 2 + 1).times do |i|
          play variation_scale[i % variation_scale.length] || :e4, 
            amp: amps[i % 2], release: 3,
            cutoff: cosmic_rand(50, 80, current_math, evolution_tick), pan: cosmic_rand(-0.6, 0.6, current_math, evolution_tick)
          sleep 4
        end
      end
    end
  end
end

# 空灵版本特色说明：
# 1. 增强reverb/echo：更高room/decay，营造太空空间感。
# 2. 空灵合成器：fm, sine为主。
# 3. 更长音符：attack/release增加，amp降低，增强冥想。
# 4. 氛围样本：ambi_space和perc_bell增强空灵。
# 5. 动态pan：更宽范围，模拟太空漂浮。