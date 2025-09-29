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

# 铃声般的旋律单音
live_loop :melody, sync: :mc do
  use_synth :saw
  
  # 五声音阶创造铃声感
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