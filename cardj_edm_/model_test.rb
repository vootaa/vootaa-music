use_bpm 120

# ========== 数学驱动模块 ==========
define :pi_random do |index, min_val = 0, max_val = 1|
  pi_str = "31415926535897932384626433832795"
  digit = pi_str[index % pi_str.length].to_i
  min_val + (digit / 9.0) * (max_val - min_val)
end

define :modal_evolution do |time, phase_duration = 256|
  # 计算当前处于哪个模态阶段 (0-4)
  current_modal = (time / phase_duration).to_i % 5
  progress = (time % phase_duration) / phase_duration.to_f
  # S曲线过渡强度
  transition_intensity = 1.0 / (1.0 + Math.exp(-8 * (progress - 0.5)))
  
  [current_modal, transition_intensity]
end

# 定义5个模态的特征
define :get_modal_config do |modal_id, intensity|
  case modal_id
  when 0  # 模态0: 原始温暖氛围 (DI原版)
    {
      name: "Warm Ambient",
      kick_amp: 0.8,
      kick_pattern: :simple,
      synth_type: :blade,
      scale_type: :major_pentatonic,
      chord_complexity: :basic,
      hihat_density: 0.2,
      bass_freq: 0.1,
      reverb_mix: 0.8,
      tempo_mod: 1.0
    }
  when 1  # 模态1: 深度电子
    {
      name: "Deep Electronic", 
      kick_amp: 0.9 + intensity * 0.3,
      kick_pattern: :syncopated,
      synth_type: :tb303,
      scale_type: :minor,
      chord_complexity: :extended,
      hihat_density: 0.4 + intensity * 0.3,
      bass_freq: 0.3,
      reverb_mix: 0.5,
      tempo_mod: 1.0 + intensity * 0.1
    }
  when 2  # 模态2: 迷幻空间
    {
      name: "Psychedelic Space",
      kick_amp: 0.6,
      kick_pattern: :triplet,
      synth_type: :prophet,
      scale_type: :whole_tone,
      chord_complexity: :suspended,
      hihat_density: 0.6 + intensity * 0.4,
      bass_freq: 0.2,
      reverb_mix: 0.9 + intensity * 0.1,
      tempo_mod: 0.9 + intensity * 0.2
    }
  when 3  # 模态3: 工业节拍
    {
      name: "Industrial Beats",
      kick_amp: 1.2,
      kick_pattern: :industrial,
      synth_type: :saw,
      scale_type: :minor_pentatonic,
      chord_complexity: :power,
      hihat_density: 0.8 + intensity * 0.2,
      bass_freq: 0.5,
      reverb_mix: 0.3,
      tempo_mod: 1.1 + intensity * 0.1
    }
  when 4  # 模态4: 宇宙回响
    {
      name: "Cosmic Echo",
      kick_amp: 0.4 + intensity * 0.4,
      kick_pattern: :cosmic,
      synth_type: :hollow,
      scale_type: :chromatic,
      chord_complexity: :cluster,
      hihat_density: 0.3 + intensity * 0.7,
      bass_freq: 0.15,
      reverb_mix: 1.0,
      tempo_mod: 0.8 + intensity * 0.4
    }
  end
end

# ========== 全局状态 ==========
set :dt, 0
set :current_modal, 0
set :modal_intensity, 0.0
set :modal_config, {}

# ========== 主控制器 ==========
live_loop :mc do
  t = get(:dt) + 1
  set :dt, t
  
  # 每256拍切换模态
  modal_data = modal_evolution(t, 256)
  current_modal = modal_data[0]
  transition_intensity = modal_data[1]
  
  # 获取当前模态配置
  config = get_modal_config(current_modal, transition_intensity)
  
  set :current_modal, current_modal
  set :modal_intensity, transition_intensity
  set :modal_config, config
  
  # 调试信息
  if t % 64 == 0
    puts "#{config[:name]} - Modal: #{current_modal}, Intensity: #{transition_intensity.round(2)}"
  end
  
  sleep 0.125
end

# ========== 智能底鼓系统 ==========
live_loop :k, sync: :mc do
  t = get(:dt)
  config = get(:modal_config)
  intensity = get(:modal_intensity)
  
  case config[:kick_pattern]
  when :simple
    should_trigger = t % 4 == 0
  when :syncopated
    should_trigger = [0, 1.5, 3, 3.75].include?(t % 4)
  when :triplet
    should_trigger = t % 3 == 0
  when :industrial
    should_trigger = pi_random(t / 2, 0, 1) > 0.4
  when :cosmic
    should_trigger = (t % 8 == 0) || (pi_random(t, 0, 1) > 0.8)
  end
  
  if should_trigger
    sample :bd_haus,
      amp: config[:kick_amp] * (0.8 + intensity * 0.4),
      rate: config[:tempo_mod] + pi_random(t, -0.05, 0.05),
      cutoff: [60 + intensity * 40, 130].min
  end
  
  sleep 0.25
end

# ========== 动态氛围系统 ==========
live_loop :a, sync: :mc do
  t = get(:dt)
  config = get(:modal_config)
  intensity = get(:modal_intensity)
  
  use_synth config[:synth_type]
  
  # 根据模态选择音阶和音符
  notes = scale(:c4, config[:scale_type], num_octaves: 2)
  selected_note = case config[:scale_type]
  when :major_pentatonic
    notes.choose + 12
  when :minor, :minor_pentatonic
    notes[(pi_random(t / 32, 0, 1) * notes.length).to_i]
  when :whole_tone
    notes[(t / 16) % notes.length] + (pi_random(t, 0, 1) * 12).to_i
  when :chromatic
    :c4 + (pi_random(t / 8, 0, 1) * 24).to_i
  else
    notes.choose
  end
  
  # 动态混响参数
  reverb_room = [0.3 + config[:reverb_mix] * 0.7, 1.0].min
  
  with_fx :reverb, room: reverb_room, mix: config[:reverb_mix] do
    with_fx :echo, phase: 0.5 + intensity * 0.5, decay: 6, mix: 0.2 + intensity * 0.3 do
      play selected_note,
        attack: 1 + intensity * 2,
        release: 6 + intensity * 4,
        amp: 0.2 + intensity * 0.3,
        cutoff: [80 + intensity * 50, 130].min,
        pan: rrand(-0.5, 0.5) * intensity
    end
  end
  
  sleep 8
end

# ========== 智能和弦系统 ==========
live_loop :chord_pad, sync: :mc do
  t = get(:dt)
  config = get(:modal_config)
  intensity = get(:modal_intensity)
  
  use_synth :hollow
  
  # 根据模态复杂度选择和弦
  chord_root = [:c4, :f4, :g4, :a4][(t / 64) % 4]
  
  selected_chord = case config[:chord_complexity]
  when :basic
    chord(chord_root, :major)
  when :extended
    chord(chord_root, :minor7)
  when :suspended
    chord(chord_root, :sus4)
  when :power
    [chord_root, chord_root + 7]  # 五度和弦
  when :cluster
    [chord_root, chord_root + 1, chord_root + 7, chord_root + 11]
  end
  
  with_fx :reverb, room: 0.6, mix: 0.4 + intensity * 0.3 do
    play selected_chord,
      attack: 2 + intensity,
      release: 12 + intensity * 8,
      amp: 0.1 + intensity * 0.1,
      cutoff: [70 + intensity * 30, 130].min
  end
  
  sleep 16
end

# ========== 动态旋律系统 ==========
live_loop :melody, sync: :mc do
  t = get(:dt)
  config = get(:modal_config)
  intensity = get(:modal_intensity)
  
  # 根据模态选择合成器
  use_synth case config[:synth_type]
  when :tb303
    :tb303
  when :prophet
    :prophet  
  when :saw
    :saw
  else
    :sine
  end
  
  # 音阶选择
  notes = scale(:c4, config[:scale_type])
  melody_note = notes[(pi_random(t / 8, 0, 1) * notes.length).to_i]
  
  # 动态效果器链
  with_fx :echo, 
    phase: 0.25 + intensity * 0.5,
    decay: 3 + intensity * 3,
    mix: 0.2 + intensity * 0.4 do
    
    with_fx :reverb, room: 0.4, mix: 0.3 + intensity * 0.4 do
      play melody_note,
        attack: 0.1 + intensity * 0.3,
        release: 1 + intensity * 3,
        cutoff: [90 + intensity * 40, 130].min,
        amp: 0.3 + intensity * 0.2,
        pan: rrand(-0.4, 0.4) * (1 + intensity)
    end
  end
  
  sleep [2, 3, 4].choose * config[:tempo_mod]
end

# ========== 智能高帽系统 ==========
live_loop :hihat, sync: :mc do
  t = get(:dt)
  config = get(:modal_config)
  intensity = get(:modal_intensity)
  
  should_play = pi_random(t, 0, 1) < config[:hihat_density]
  
  if should_play
    sample :drum_cymbal_closed,
      amp: 0.1 + intensity * 0.2,
      rate: 1.0 + pi_random(t, -0.2, 0.2) * intensity,
      pan: rrand(-0.6, 0.6) * (1 + intensity * 0.5),
      cutoff: [80 + intensity * 30, 130].min
  end
  
  sleep 0.25
end

# ========== 动态低音系统 ==========
live_loop :bass_touch, sync: :mc do
  t = get(:dt)
  config = get(:modal_config)
  intensity = get(:modal_intensity)
  
  should_trigger = pi_random(t / 8, 0, 1) < config[:bass_freq]
  
  if should_trigger
    use_synth case get(:current_modal)
    when 0, 4
      :sine
    when 1, 2  
      :fm
    when 3
      :subpulse
    end
    
    bass_notes = [:c2, :f2, :g2, :a2]
    bass_note = bass_notes[(pi_random(t / 16, 0, 1) * 4).to_i]
    
    with_fx :reverb, room: 0.2 + intensity * 0.3, mix: 0.1 + intensity * 0.2 do
      play bass_note,
        attack: 0.5 + intensity,
        release: 2 + intensity * 2,
        amp: 0.3 + intensity * 0.3,
        cutoff: [50 + intensity * 30, 90].min
    end
  end
  
  sleep 4
end