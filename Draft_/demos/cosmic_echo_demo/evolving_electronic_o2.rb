# 演化电子音乐优化版2：主干固定（参考 Deep House 传统 EDM），花色（数学常数驱动额外变异）

# 数学常数定义（花色基因库）
PI_DIGITS = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
GOLDEN_DIGITS = "6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374"
E_DIGITS = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
PLANCK_DIGITS = "1616255000000000000000000000000000001616255000000000000000000000000000001616255"

# 花色：演化因子引擎（驱动变异）
@evolution_tick = 0
@digit_cache = {}
define :evolution_factor do |constant, base=1.0, growth=0.01|
  digits = @digit_cache[constant] ||= case constant
  when :golden then GOLDEN_DIGITS
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :planck then PLANCK_DIGITS
  else PI_DIGITS
  end
  factor = 0
  (0..@evolution_tick).each { |i| factor += digits[i % digits.length].to_i / 9.0 }
  # 动态growth，随tick增加
  dynamic_growth = growth + @evolution_tick * 0.001
  base + (factor * dynamic_growth)
end

# 辅助：数学随机生成器（花色驱动）
define :electronic_rand do |min, max, constant=:pi, tick_offset=0|
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :golden then GOLDEN_DIGITS
  else PI_DIGITS
  end
  index = (@evolution_tick + tick_offset) % digits.length
  digit = digits[index].to_i
  min + (digit / 9.0) * (max - min) * evolution_factor(constant, 1.0, 0.05)
end

# 设置全局（参考 DeepHouse.rb）
use_bpm 60
use_random_seed 113
use_debug false

# 主干：参考 Deep House 结构（固定，无变异，使用内置采样）
live_loop :met do
  sleep 0.5
end

live_loop :kick, sync: :met do
  28.times do
    sample :bd_tek, amp: 2
    sleep 0.5
  end
  sleep 2
end

live_loop :hats_sample, sync: :met do
  with_fx :reverb do
    sample :hat_zap, beat_stretch: 8, amp: 1.2  # 使用内置 hat 采样
    sleep 8
  end
end

live_loop :clap, sync: :met do
  sleep 0.5
  with_fx :reverb do
    sample :clap  # 使用内置 clap 采样
  end
  sleep 0.5
end

live_loop :synth_1, sync: :met do
  use_synth :saw
  use_synth_defaults release: 0.25, cutoff: 100, amp: 0.9
  sleep 0
  with_fx :echo, decay: 2, phase: 0.25, mix: 0.5 do
    play chord(:c4, :m7)
    sleep 0.375
    play chord(:c4, :m7)
    sleep 0.375
    play chord(:c4, :m7)
    sleep 0.375
    sleep 2 - 0.375*3
  end
end

live_loop :synth_2, sync: :met do
  use_synth :tb303
  sleep 1.25
  with_fx :wobble, phase: 0.9, invert_wave: 1 do
    play chord(:c4, :m7)
    sleep 0.75
  end
  sleep 0
end

live_loop :bass_loop, sync: :met do
  use_synth :dsaw
  use_synth_defaults release: 0.1, cutoff: 80, amp: 1.1, sustain: 0.1
  progression = [:c2, :f1]
  with_fx :reverb, mix: 0.5 do
    p = progression.tick
    play p
    sleep 0.125
    play p
    sleep 0.25
    play p
    sleep 0.25
    play p-2
    sleep 0.125
    play p-2
    sleep 0.125
    sleep 0.125
  end
end

# 花色：额外变异元素（数学驱动，渐进）
live_loop :electronic_variations, sync: :met do
  # 阈值随tick降低，开始时无激活
  threshold = 0.8 - @evolution_tick * 0.01
  if electronic_rand(0, 1, :golden, @evolution_tick) > threshold
    variation_note = :c4 + electronic_rand(-2, 2, :e, @evolution_tick)
    use_synth :beep
    play variation_note, amp: 0.2 * evolution_factor(:golden, 0.5, 0.1), release: 1,
      pan: electronic_rand(-1, 1, :pi, @evolution_tick)
  end
  sleep 4
  @evolution_tick += 1
end

live_loop :pan_flair, sync: :met do
  # 阈值随tick降低
  threshold = 0.4 - @evolution_tick * 0.005
  if evolution_factor(:golden, 0.0, 0.1) > threshold
    sample :ambi_choir, amp: 0.1 * evolution_factor(:pi, 0.5, 0.1), rate: 0.5,
      pan: (Math.sin(@evolution_tick * 0.1) * evolution_factor(:pi, 0.5, 0.1))
  end
  sleep 4
end

# 花色：变异bass（额外元素）
live_loop :varied_bass, sync: :met do
  threshold = 0.6 - @evolution_tick * 0.01
  if electronic_rand(0, 1, :planck, @evolution_tick) > threshold
    extra_bass = :c2 + electronic_rand(-1, 1, :e, @evolution_tick)
    use_synth :dsaw
    play extra_bass, amp: 0.3 * evolution_factor(:golden, 0.5, 0.1), release: 0.5,
      pan: electronic_rand(-0.5, 0.5, :pi, @evolution_tick)
  end
  sleep 2
end