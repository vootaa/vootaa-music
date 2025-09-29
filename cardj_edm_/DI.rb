use_bpm 120

# 状态
set :dt, 0

# 主控
live_loop :mc do
  t = get(:dt) + 1
  set :dt, t
  sleep 0.125
end

# 底鼓 - 确保有节拍
live_loop :k, sync: :mc do
  sample :bd_haus, amp: 0.8
  sleep 1
end

# 早晨氛围泛音
live_loop :a, sync: :mc do
  use_synth :blade
  
  with_fx :reverb, room: 0.9, mix: 0.8 do
    play chord(:c4, :major).choose + 12,
      attack: 2,
      release: 8,
      amp: 0.3
  end
  
  sleep 8
end

# 铃声般的单音旋律
live_loop :melody, sync: :mc do
  use_synth :saw
  
  # 五声音阶单音
  notes = scale(:c4, :major_pentatonic, num_octaves: 2)
  n = notes.choose
  
  with_fx :echo, phase: 0.375, decay: 4, mix: 0.3 do
    with_fx :reverb, room: 0.5, mix: 0.2 do
      play n,
        attack: 0.1,
        release: 2,
        cutoff: 100,
        amp: 0.4,
        pan: rrand(-0.3, 0.3)
    end
  end
  
  sleep 4
end

# 和弦垫 - 支撑单音
live_loop :chord_pad, sync: :mc do
  use_synth :hollow  # 使用hollow合成器代替pad
  
  # 简单的和弦进行
  chords = [
    chord(:c4, :major7),
    chord(:f4, :major7),
    chord(:g4, :dom7),
    chord(:a4, :minor7)
  ]
  
  t = get(:dt)
  current_chord = chords[(t/32) % chords.length]
  
  with_fx :reverb, room: 0.6, mix: 0.4 do
    play current_chord,
      attack: 1,
      release: 15,
      amp: 0.15,
      cutoff: 80
  end
  
  sleep 16
end

# 微妙的高帽增加律动感
live_loop :hihat, sync: :mc do
  t = get(:dt)
  if t % 16 > 8  # 只在后半段加入
    sample :drum_cymbal_closed,
      amp: 0.15,
      rate: 1.2,
      pan: rrand(-0.4, 0.4)
    sleep 0.5
  else
    sleep 0.5
  end
end

# 偶尔的低音补充（很轻微）
live_loop :bass_touch, sync: :mc do
  t = get(:dt)
  if t % 32 == 24  # 很偶尔触发
    use_synth :sine
    with_fx :reverb, room: 0.3, mix: 0.1 do
      play :c2,
        attack: 1,
        release: 3,
        amp: 0.2
    end
  end
  sleep 8
end