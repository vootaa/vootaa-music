# Numus Sonic Pi 增强播放器 V2.0
# 长篇车载 EDM 专用播放器

use_osc "localhost", 4560

# 全局状态管理

# 播放器状态
set :numus_active, false
set :current_chapter, -1
set :current_bpm, 125
set :energy_level, 0.1
set :car_profile, "sedan_standard"

# 章节元素状态
set :chapter_kick_active, false
set :chapter_bass_active, false
set :chapter_pad_active, false
set :chapter_lead_active, false
set :chapter_perc_active, false

# 过渡效果状态
set :transition_active, false
set :filter_active, false
set :filter_type, "none"
set :filter_cutoff, 130
set :filter_resonance, 0.3

# 车载音频参数
set :car_bass_boost, 1.2
set :car_mid_clarity, 1.0
set :car_treble_enhance, 1.1

puts "🎵 Numus 增强播放器 V2.0 启动"
puts "🚗 支持车载音频优化"

#  OSC 消息处理 

live_loop :numus_osc_handler do
  msg = sync "/osc/numus/*"
  
  case msg[0]
  when "/numus/init"
    set :numus_active, true
    set :current_bpm, msg[1] || 125
    set :car_profile, msg[2] || "sedan_standard"
    use_bpm get(:current_bpm)
    
    # 应用车载音频配置
    apply_car_audio_profile(get(:car_profile))
    
    puts "🎮 Numus 播放器激活"
    puts "♪ BPM: #{get(:current_bpm)}"
    puts "🚗 车载配置: #{get(:car_profile)}"
    
  when "/numus/chapter_start"
    chapter_idx = msg[1]
    energy_start = msg[2]
    energy_end = msg[3]
    duration_bars = msg[4]
    
    set :current_chapter, chapter_idx
    set :energy_level, energy_start
    
    puts "🎪 章节 #{chapter_idx + 1} 开始"
    puts "⚡ 能量: #{energy_start} → #{energy_end}"
    
  when "/numus/chapter_stop"
    chapter_idx = msg[1]
    
    # 停用所有章节元素
    set :chapter_kick_active, false
    set :chapter_bass_active, false
    set :chapter_pad_active, false
    set :chapter_lead_active, false
    set :chapter_perc_active, false
    
    puts "⏹️  章节 #{chapter_idx + 1} 结束"
    
  when "/numus/section_element"
    chapter_id = msg[1]
    element_name = msg[2]
    element_config_json = msg[3]
    
    # 解析并应用 Section 元素配置
    apply_section_element(chapter_id, element_name, element_config_json)
    
  when "/numus/energy"
    energy = [msg[1], 1.0].min
    set :energy_level, energy
    
  when "/numus/ornament"
    sample_path = msg[1]
    amplitude = msg[2] || 0.5
    
    # 播放装饰采样
    sample sample_path, amp: amplitude * get(:car_mid_clarity)
    
  when "/numus/filter"
    if msg[1] == "off"
      set :filter_active, false
    else
      set :filter_active, true
      set :filter_type, msg[1]      # "hpf", "lpf", "bpf"
      set :filter_cutoff, msg[2]    # 20-20000
      set :filter_resonance, msg[3] # 0-1
    end
    
  when "/numus/emergency_stop"
    set :numus_active, false
    puts "🛑 紧急停止"
    
  when "/numus/finalize"
    set :numus_active, false
    puts "🎉 播放完成"
  end
end

#  车载音频配置 

define :apply_car_audio_profile do |profile|
  case profile
  when "sedan_standard"
    set :car_bass_boost, 1.2
    set :car_mid_clarity, 1.0
    set :car_treble_enhance, 1.1
  when "suv_premium"
    set :car_bass_boost, 1.1
    set :car_mid_clarity, 1.1
    set :car_treble_enhance, 1.0
  when "sports_car"
    set :car_bass_boost, 1.3
    set :car_mid_clarity, 0.9
    set :car_treble_enhance, 1.2
  else
    set :car_bass_boost, 1.2
    set :car_mid_clarity, 1.0
    set :car_treble_enhance, 1.1
  end
end

#  Section 元素应用 

define :apply_section_element do |chapter_id, element_name, config_json|
  # 这里可以解析 JSON 配置并动态调整元素参数
  # 简化版本：根据元素名激活对应的播放循环
  
  case element_name
  when "kick"
    set :chapter_kick_active, true
  when "bass"
    set :chapter_bass_active, true
  when "pad"
    set :chapter_pad_active, true
  when "lead"
    set :chapter_lead_active, true
  when "percussion", "hihat", "perc"
    set :chapter_perc_active, true
  end
  
  puts "🔧 激活元素: #{element_name}"
end

#  核心播放循环 

# Kick 循环 - 车载低频优化
live_loop :numus_kick, sync: :met do
  stop unless get(:numus_active)
  
  if get(:chapter_kick_active)
    energy = get(:energy_level)
    bass_boost = get(:car_bass_boost)
    
    # 根据能量选择 kick 样式和模式
    if energy > 0.8
      # 高能量：密集模式
      sample :bd_boom, amp: energy * 0.9 * bass_boost
      sleep 0.5
      sample :bd_boom, amp: energy * 0.6 * bass_boost
      sleep 0.5
    elsif energy > 0.5
      # 中等能量：标准四拍
      sample :bd_haus, amp: energy * 0.8 * bass_boost
      sleep 1
    else
      # 低能量：稀疏模式
      sample :bd_haus, amp: energy * 0.7 * bass_boost
      sleep 2
    end
  else
    sleep 1
  end
end

# Bass 循环 - 车载低频强化
live_loop :numus_bass, sync: :met do
  stop unless get(:numus_active)
  
  if get(:chapter_bass_active)
    energy = get(:energy_level)
    bass_boost = get(:car_bass_boost)
    
    use_synth :bass_foundation
    use_synth_defaults release: 0.8, 
                      cutoff: 40 + (energy * 60),
                      amp: energy * 0.7 * bass_boost
    
    # 车载优化的低音线条
    bass_notes = ring(:a1, :a1, :e1, :a1)
    
    with_fx :compressor, threshold: 0.7 do
      play bass_notes.tick
    end
    
    sleep 2
  else
    sleep 2
  end
end

# Pad 循环 - 车载中频清晰度
live_loop :numus_pad, sync: :met do
  stop unless get(:numus_active)
  
  if get(:chapter_pad_active)
    energy = get(:energy_level)
    mid_clarity = get(:car_mid_clarity)
    
    use_synth :pad
    use_synth_defaults attack: 1.5, 
                      sustain: 4, 
                      release: 1.5,
                      cutoff: 60 + (energy * 40),
                      amp: energy * 0.4 * mid_clarity
    
    # 车载优化的和弦进行
    chord_progressions = [
      [chord(:a2, :minor), chord(:f2, :major), chord(:c3, :major), chord(:g2, :major)],
      [chord(:a2, :minor7), chord(:f2, :maj7), chord(:c3, :add9), chord(:g2, :sus4)]
    ]
    
    chapter = get(:current_chapter)
    progression = chord_progressions[chapter % chord_progressions.length]
    
    with_fx :reverb, room: 0.6 do
      play progression.ring.tick
    end
    
    sleep 4
  else
    sleep 4
  end
end

# Lead 循环 - 车载高频增强
live_loop :numus_lead, sync: :met do
  stop unless get(:numus_active)
  
  if get(:chapter_lead_active)
    energy = get(:energy_level)
    treble_enhance = get(:car_treble_enhance)
    
    use_synth :lead
    use_synth_defaults release: 0.4, 
                      cutoff: 80 + (energy * 50),
                      amp: energy * 0.6 * treble_enhance
    
    # 根据章节和能量动态旋律
    scales = [
      scale(:a3, :minor),
      scale(:a4, :minor_pentatonic),
      scale(:a3, :dorian)
    ]
    
    chapter = get(:current_chapter)
    current_scale = scales[chapter % scales.length]
    
    if energy > 0.8
      # 高能量：快速旋律
      4.times do
        play current_scale.choose, amp: energy * 0.7 * treble_enhance
        sleep 0.25
      end
    elsif energy > 0.5
      # 中等能量：标准旋律
      play current_scale.choose, amp: energy * 0.6 * treble_enhance
      sleep [0.5, 1].choose
    else
      # 低能量：长音
      play current_scale.choose, amp: energy * 0.5 * treble_enhance
      sleep 2
    end
  else
    sleep 1
  end
end

# 打击乐循环 - 车载空间感
live_loop :numus_percussion, sync: :met do
  stop unless get(:numus_active)
  
  if get(:chapter_perc_active)
    energy = get(:energy_level)
    
    # 高帽
    if energy > 0.4 && spread(3, 8).tick
      sample :drum_cymbal_closed, 
             amp: energy * 0.3,
             pan: rrand(-0.3, 0.3)  # 车载立体声优化
    end
    
    # 拍掌
    if energy > 0.6 && spread(1, 4).look
      sample :perc_snap, 
             amp: energy * 0.4,
             pan: rrand(-0.2, 0.2)
    end
    
    # 装饰打击乐
    if energy > 0.8 && one_in(16)
      sample :elec_cymbal, 
             amp: energy * 0.2,
             rate: rrand(0.8, 1.2)
    end
  end
  
  sleep 0.5
end

#  动态效果处理 

# 滤波器效果循环
live_loop :numus_filter_fx, sync: :met do
  stop unless get(:numus_active)
  
  if get(:filter_active)
    # 应用全局滤波器效果
    # 这里可以实现动态滤波器处理
    # 简化版本：输出状态信息
    puts "🎛️  滤波器: #{get(:filter_type)} @ #{get(:filter_cutoff)}Hz"
  end
  
  sleep 4
end

# 车载环境音效
live_loop :numus_car_ambience, sync: :met do
  stop unless get(:numus_active)
  
  energy = get(:energy_level)
  
  # 轻微的环境噪声，增强车载沉浸感
  if energy > 0.1 && one_in(32)
    with_fx :hpf, cutoff: 200 do
      with_fx :reverb, room: 0.3 do
        sample :vinyl_hiss, 
               amp: 0.05,
               rate: rrand(0.8, 1.2)
      end
    end
  end
  
  sleep 8
end

puts "🎵 Numus 播放循环已启动"
puts "🚗 车载 EDM 播放器准备就绪"