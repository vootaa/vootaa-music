# Numus Sonic Pi 通用播放器
# 接收 OSC 控制，播放任何 Numus 作品

use_osc "localhost", 4560

# 全局状态
set :numus_active, false
set :current_bpm, 125
set :current_chapter, 0
set :energy_level, 0.1

# 元素状态
set :kick_active, false
set :bass_active, false
set :pad_active, false
set :lead_active, false
set :perc_active, false

puts "Numus Sonic Player 启动"

# OSC 消息处理
live_loop :numus_osc do
  msg = sync "/osc/numus/*"
  
  case msg[0]
  when "/numus/init"
    set :numus_active, true
    set :current_bpm, msg[1] || 125
    use_bpm get(:current_bpm)
    puts "Numus 播放器激活 - BPM: #{get(:current_bpm)}"
    
  when "/numus/stop"
    set :numus_active, false
    puts "Numus 播放器停止"
    
  when "/numus/chapter"
    set :current_chapter, msg[1]
    puts "章节 #{msg[1] + 1} - 能量: #{msg[2]} → #{msg[3]}"
    
  when "/numus/energy"
    set :energy_level, [msg[1], 1.0].min
    
  when "/numus/element"
    element_name = msg[1]
    active = msg[2] > 0
    
    case element_name
    when "kick"
      set :kick_active, active
    when "bass"  
      set :bass_active, active
    when "pad"
      set :pad_active, active
    when "lead"
      set :lead_active, active
    when "percussion"
      set :perc_active, active
    end
    
    puts "元素 #{element_name}: #{active ? '激活' : '关闭'}"
    
  when "/numus/sample"
    if msg[2] > 0
      sample msg[1], amp: msg[2]
      puts "装饰音: #{File.basename(msg[1])}"
    end
  end
end

# 主要元素循环
live_loop :numus_kick, sync: :met do
  stop unless get(:numus_active)
  
  if get(:kick_active)
    energy = get(:energy_level)
    
    # 根据能量选择 kick 样式
    if energy > 0.7
      sample :bd_haus, amp: energy * 0.9
      sleep 0.5
      sample :bd_haus, amp: energy * 0.5
      sleep 0.5
    else
      sample :bd_haus, amp: energy * 0.8
      sleep 1
    end
  else
    sleep 1
  end
end

live_loop :numus_bass, sync: :met do
  stop unless get(:numus_active)
  
  if get(:bass_active)
    energy = get(:energy_level)
    
    use_synth :bass_foundation
    use_synth_defaults release: 0.8, cutoff: 40 + (energy * 50)
    
    bass_notes = ring(:a1, :a1, :e1, :a1)
    play bass_notes.tick, amp: energy * 0.8
    
    sleep 2
  else
    sleep 2
  end
end

live_loop :numus_pad, sync: :met do
  stop unless get(:numus_active)
  
  if get(:pad_active)
    energy = get(:energy_level)
    chapter = get(:current_chapter)
    
    use_synth :pad
    use_synth_defaults attack: 1, sustain: 3, release: 1,
                      cutoff: 60 + (energy * 40), amp: energy * 0.3
    
    # 根据章节变化和弦
    chord_progressions = [
      [chord(:a2, :minor), chord(:f2, :major), chord(:c3, :major), chord(:g2, :major)],
      [chord(:a2, :minor), chord(:e2, :minor), chord(:f2, :major), chord(:g2, :major)],
      [chord(:f2, :major), chord(:g2, :major), chord(:a2, :minor), chord(:a2, :minor)]
    ]
    
    progression = chord_progressions[chapter % chord_progressions.length]
    play progression.ring.tick
    
    sleep 4
  else
    sleep 4
  end
end

live_loop :numus_lead, sync: :met do
  stop unless get(:numus_active)
  
  if get(:lead_active)
    energy = get(:energy_level)
    chapter = get(:current_chapter)
    
    use_synth :lead
    use_synth_defaults release: 0.4, cutoff: 70 + (energy * 30)
    
    # 根据章节和能量选择音阶
    scales = [
      scale(:a3, :minor),
      scale(:a4, :minor_pentatonic), 
      scale(:a3, :dorian),
      scale(:a4, :mixolydian)
    ]
    
    current_scale = scales[chapter % scales.length]
    
    if energy > 0.8
      # 高能量时密集旋律
      4.times do
        play current_scale.choose, amp: energy * 0.7
        sleep 0.25
      end
    elsif energy > 0.5
      # 中等能量
      play current_scale.choose, amp: energy * 0.6
      sleep [0.5, 1].choose
    else
      # 低能量时稀疏
      play current_scale.choose, amp: energy * 0.5
      sleep [1, 2].choose
    end
  else
    sleep 1
  end
end

live_loop :numus_percussion, sync: :met do
  stop unless get(:numus_active)
  
  if get(:perc_active)
    energy = get(:energy_level)
    
    # 简单的打击乐补充
    if energy > 0.6 && one_in(4)
      sample :perc_snap, amp: energy * 0.4
    end
    
    if energy > 0.8 && one_in(8)
      sample :elec_cymbal, amp: energy * 0.2
    end
  end
  
  sleep 0.5
end

puts "Numus 播放循环已启动"