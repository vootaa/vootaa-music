use_bpm 120

# ========== 数学驱动模块 ==========
define :pi_random do |index, min_val = 0, max_val = 1|
  pi_str = "31415926535897932384626433832795"
  digit = pi_str[index % pi_str.length].to_i
  min_val + (digit / 9.0) * (max_val - min_val)
end

define :modal_evolution do |time, phase_duration = 512|
  # 计算当前处于哪个模态阶段
  progress = (time % phase_duration) / phase_duration.to_f
  # S曲线过渡
  1.0 / (1.0 + Math.exp(-8 * (progress - 0.5)))
end

# ========== 全局状态 ==========
set :dt, 0
set :current_modal, 0  # 当前模态：0=原始DI风格, 1=演进风格
set :modal_intensity, 0.0  # 模态混合强度

# ========== 主控制器 ==========
live_loop :mc do
  t = get(:dt) + 1
  set :dt, t
  
  # 每512拍(约17分钟@120BPM)进入下一个模态
  modal_phase = (t / 512).to_i % 2
  modal_blend = modal_evolution(t, 512)
  
  set :current_modal, modal_phase
  set :modal_intensity, modal_blend
  
  # 调试信息
  if t % 64 == 0
    puts "Time: #{t}, Modal: #{modal_phase}, Intensity: #{modal_blend.round(2)}"
  end
  
  sleep 0.125
end

# ========== 底鼓系统 ==========
live_loop :k, sync: :mc do
  t = get(:dt)
  modal_intensity = get(:modal_intensity)
  
  # 原始模态：简单4/4
  base_amp = 0.8
  
  # 演进模态：复杂节拍模式
  evolved_pattern = pi_random(t / 4, 0, 1) > 0.3
  evolved_amp = 0.6 + pi_random(t / 8, 0, 0.4)
  
  # 模态混合
  final_amp = base_amp * (1 - modal_intensity) + evolved_amp * modal_intensity
  should_trigger = modal_intensity < 0.5 || evolved_pattern
  
  if should_trigger
    sample :bd_haus, 
      amp: final_amp,
      rate: 1.0 + modal_intensity * pi_random(t, -0.1, 0.1)
  end
  
  sleep 1
end

# ========== 氛围系统 ==========
live_loop :a, sync: :mc do
  t = get(:dt)
  modal_intensity = get(:modal_intensity)
  
  use_synth :blade
  
  # 原始模态：简单大三和弦
  base_chord = chord(:c4, :major).choose + 12
  base_room = 0.9
  
  # 演进模态：复杂和声
  evolved_notes = scale(:c4, :major_pentatonic, num_octaves: 2)
  evolved_note = evolved_notes[(pi_random(t / 64, 0, 1) * evolved_notes.length).to_i]
  evolved_room = 0.5 + pi_random(t / 32, 0, 0.4)
  
  # 模态混合
  final_note = modal_intensity < 0.5 ? base_chord : evolved_note
  final_room = base_room * (1 - modal_intensity) + evolved_room * modal_intensity
  
  # 限制cutoff值在有效范围内
  cutoff_val = [100 + modal_intensity * 30, 130].min
  
  with_fx :reverb, room: final_room, mix: 0.8 do
    play final_note,
      attack: 2,
      release: 8,
      amp: 0.3 * (1 + modal_intensity * 0.5),
      cutoff: cutoff_val
  end
  
  sleep 8
end

# ========== 旋律系统 ==========
live_loop :melody, sync: :mc do
  t = get(:dt)
  modal_intensity = get(:modal_intensity)
  
  use_synth :saw
  
  # 原始模态：五声音阶
  base_notes = scale(:c4, :major_pentatonic, num_octaves: 2)
  base_note = base_notes.choose
  
  # 演进模态：色彩音阶
  evolved_notes = scale(:c4, :whole_tone)
  evolved_note = evolved_notes[(pi_random(t / 16, 0, 1) * evolved_notes.length).to_i]
  
  # 模态混合
  final_note = modal_intensity < 0.6 ? base_note : evolved_note
  
  # 动态效果器参数
  echo_phase = 0.375 * (1 + modal_intensity * pi_random(t / 8, 0, 0.5))
  
  with_fx :echo, phase: echo_phase, decay: 4, mix: 0.3 do
    with_fx :reverb, room: 0.5, mix: 0.2 + modal_intensity * 0.3 do
      play final_note,
        attack: 0.1,
        release: 2 * (1 + modal_intensity),
        cutoff: 100 - modal_intensity * 30,
        amp: 0.4,
        pan: rrand(-0.3, 0.3) * (1 + modal_intensity)
    end
  end
  
  sleep 4
end

# ========== 和弦垫系统 ==========
live_loop :chord_pad, sync: :mc do
  t = get(:dt)
  modal_intensity = get(:modal_intensity)
  
  use_synth :hollow
  
  # 原始和弦进行
  base_chords = [
    chord(:c4, :major7),
    chord(:f4, :major7), 
    chord(:g4, :dom7),
    chord(:a4, :minor7)
  ]
  
  # 演进和弦进行（使用Sonic Pi支持的和弦类型）
  evolved_chords = [
    chord(:c4, :major) + [note(:d5)],  # 模拟major9
    invert_chord(chord(:f4, :major7), 1),  # 转位
    chord(:g4, :sus4),  # 模拟dom7sus4
    chord(:a4, :minor7)  # 保持minor7
  ]
  
  current_chord_idx = (t/32) % 4
  base_chord = base_chords[current_chord_idx]
  evolved_chord = evolved_chords[current_chord_idx]
  
  # 模态混合：低强度用原始，高强度用演进
  final_chord = modal_intensity < 0.4 ? base_chord : evolved_chord
  
  with_fx :reverb, room: 0.6 + modal_intensity * 0.3, mix: 0.4 do
    play final_chord,
      attack: 1 + modal_intensity,
      release: 15,
      amp: 0.15,
      cutoff: 80 - modal_intensity * 20
  end
  
  sleep 16
end

# ========== 高帽系统 ==========
live_loop :hihat, sync: :mc do
  t = get(:dt)
  modal_intensity = get(:modal_intensity)
  
  # 原始模式：简单律动
  base_condition = t % 16 > 8
  
  # 演进模式：复杂模式
  evolved_condition = pi_random(t, 0, 1) > (0.7 - modal_intensity * 0.4)
  
  # 模态混合
  should_play = modal_intensity < 0.3 ? base_condition : evolved_condition
  
  if should_play
    sample :drum_cymbal_closed,
      amp: 0.15 * (1 + modal_intensity),
      rate: 1.2 + modal_intensity * pi_random(t, -0.3, 0.3),
      pan: rrand(-0.4, 0.4) * (1 + modal_intensity * 0.5)
  end
  
  sleep 0.5
end

# ========== 低音触碰 ==========
live_loop :bass_touch, sync: :mc do
  t = get(:dt)
  modal_intensity = get(:modal_intensity)
  
  # 原始：偶尔触发
  base_trigger = t % 32 == 24
  
  # 演进：更频繁，更复杂
  evolved_trigger = pi_random(t / 4, 0, 1) > (0.9 - modal_intensity * 0.3)
  
  should_trigger = base_trigger || (modal_intensity > 0.5 && evolved_trigger)
  
  if should_trigger
    use_synth modal_intensity < 0.5 ? :sine : :fm
    
    with_fx :reverb, room: 0.3, mix: 0.1 + modal_intensity * 0.2 do
      play :c2,
        attack: 1,
        release: 3,
        amp: 0.2 + modal_intensity * 0.3
    end
  end
  
  sleep 8
end