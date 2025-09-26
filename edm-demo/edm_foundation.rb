# EDM基础轨道 - 核心节拍和bass line
# 这个文件包含必要的函数定义和基础音轨

# 加载共享数据
load "/Users/tsb/Pop-Proj/edm/shared_constants.rb"

# === 基础设置 ===
set_volume! 0.8  # 录音优化设置-避免削峰
use_bpm 124
use_random_seed 113
use_debug false

puts "🎵 EDM基础轨道启动 [#{Time.now.strftime('%H:%M:%S')}]"

# === 核心函数 ===

define :simple_math_rand do |min, max, constant = :pi|
  $evolution_tick ||= 0
  $digit_cache ||= {}
  
  digits = $digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :golden then GOLDEN_DIGITS
  when :e then E_DIGITS
  when :euler then EULER_DIGITS
  else PI_DIGITS
  end
  
  index = $evolution_tick % digits.length
  digit = digits[index].to_i
  min + (digit / 9.0) * (max - min)
end

define :update_global_state do
  $evolution_tick ||= 0
  $evolution_tick += 1
  
  $complexity_level = case $evolution_tick
  when EVOLUTION_STAGES[:pure_edm] then 0
  when EVOLUTION_STAGES[:light_math] then 1
  when EVOLUTION_STAGES[:cosmic_intro] then 2
  when EVOLUTION_STAGES[:full_complex] then 3
  else 3
  end
  
  $cosmic_stage = $evolution_tick % 5
  
  # 减少输出频率 - 每50拍显示一次
  if $evolution_tick % 50 == 0
    stage_names = ["Pure EDM", "Light Math", "Cosmic Intro", "Full Complex"]
    puts "🎼 T#{$evolution_tick}: #{stage_names[$complexity_level]} | 宇宙#{$cosmic_stage}"
  end
end

define :balanced_amp do |base_amp, boost = 1.0|
  $complexity_level ||= 0
  
  complexity_factor = case $complexity_level
  when 0..1 then 1.0
  when 2..3 then 0.8
  else 0.7
  end
  
  base_amp * boost * complexity_factor
end

# === EDM基础轨道 ===

live_loop :master_clock do
  $total_amplitude = 0.0
  sleep 0.5
  update_global_state
  sleep 0.5
end

live_loop :kick, sync: :master_clock do
  puts "🥁 基础层同步成功！[#{Time.now.strftime('%H:%M:%S')}]" if ($evolution_tick || 0) == 1
  
  amp = balanced_amp(1.2)
  $total_amplitude ||= 0.0
  $total_amplitude += amp
  
  sample :bd_haus, amp: amp
  sleep 1
end

live_loop :hihat, sync: :master_clock do
  $complexity_level ||= 0
  
  base_amp = 0.6
  variation = $complexity_level >= 1 ? simple_math_rand(0.9, 1.1, :pi) : 1.0
  amp = balanced_amp(base_amp * variation)
  
  $total_amplitude ||= 0.0
  $total_amplitude += amp
  
  sleep 0.5
  sample :drum_cymbal_closed, amp: amp
  sleep 0.5
end

live_loop :snare, sync: :master_clock do
  $complexity_level ||= 0
  
  base_amp = 0.8
  variation = $complexity_level >= 1 ? simple_math_rand(0.95, 1.05, :e) : 1.0
  amp = balanced_amp(base_amp * variation)
  
  $total_amplitude ||= 0.0
  $total_amplitude += amp
  
  sleep 1
  sample :drum_snare_hard, amp: amp
  sleep 1
end

live_loop :bass_foundation, sync: :master_clock do
  use_synth :tb303
  $complexity_level ||= 0
  
  bass_notes = case $complexity_level
  when 0 then [:a1, :a1, :f1, :c2]
  when 1..2 then COSMIC_SCALES[:edm_minor].map { |n| note(n) - 24 }
  else COSMIC_SCALES[:stellar].map { |n| note(n) - 24 }
  end
  
  note_to_play = bass_notes.tick
  cutoff_val = $complexity_level >= 2 ? 
    70 + simple_math_rand(-10, 15, :golden) : 70
  
  amp = balanced_amp(0.9)
  $total_amplitude ||= 0.0
  $total_amplitude += amp
  
  use_synth_defaults release: 0.3, cutoff: cutoff_val, res: 0.8, amp: amp
  play note_to_play
  sleep 0.5
end

live_loop :chord_foundation, sync: :master_clock do
  use_synth :saw
  $complexity_level ||= 0
  
  base_chords = case $complexity_level
  when 0..1
    [chord(:a3, :minor), chord(:f3, :major), chord(:c4, :major), chord(:g3, :major)]
  else
    cosmic_notes = COSMIC_SCALES[:stellar]
    cosmic_notes.map { |root| chord(root, [:minor, :major, :sus2].sample) }
  end
  
  current_chord = base_chords.tick
  amp = balanced_amp(0.4)
  $total_amplitude ||= 0.0
  $total_amplitude += amp
  
  fx_intensity = $complexity_level >= 2 ? 0.4 : 0.2
  
  with_fx :reverb, room: 0.3 * fx_intensity, mix: 0.3 * fx_intensity do
    use_synth_defaults release: 3, cutoff: 90, amp: amp
    play current_chord
  end
  
  sleep 4
end

# 录音提示
live_loop :recording_guide, sync: :master_clock do
  tick = $evolution_tick || 0
  
  case tick
  when 50
    puts "🎙️  录音建议：现在是录音的好时机！"
  when 100  
    puts "🎵  数学层已激活，音乐变得有趣"
  when 200
    puts "🌌  宇宙层即将激活，准备体验完整演化"
  when 400
    puts "✨  已达到最高复杂度，这是最精彩的部分！"
  end
  
  sleep 20
end

# 精简状态监控
live_loop :foundation_monitor, sync: :master_clock do
  sleep 30
  
  tick = $evolution_tick || 0
  complexity = $complexity_level || 0
  total_amp = $total_amplitude || 0.0
  
  if tick > 0 && (tick % 100 == 0)  # 每100拍显示一次
    puts "🏗️ 基础层: T#{tick} | Lv#{complexity} | Vol#{total_amp.round(1)}"
  end
end

puts "🎼 EDM基础轨道运行中..."