# Sonic Pi Universal Player for Numus V03
# 通用播放框架，接收OSC命令执行播放

# ==================== 全局状态管理 ====================
set :active_tracks, {}
set :global_bpm, 128
set :master_volume, 1.0

puts "Numus Universal Player V03 启动"
puts "等待OSC命令..."

# ==================== OSC命令监听器 ====================
live_loop :numus_osc_listener do
  use_real_time
  
  command = sync "/osc*/numus/cmd"
  cmd_type = command[0]
  
  puts "收到命令: #{cmd_type}"
  
  case cmd_type
  when "play_segment"
    handle_play_segment(command)
  when "stop_segment"
    handle_stop_segment(command)
  when "crossfade"
    handle_crossfade(command)
  when "set_param"
    handle_set_param(command)
  when "stop_all"
    handle_stop_all()
  else
    puts "未知命令: #{cmd_type}"
  end
end

# ==================== Segment播放处理 ====================
define :handle_play_segment do |cmd|
  track_name = cmd[1]
  segment_type = cmd[2]
  params_json = cmd[3]
  
  # 解析JSON参数
  params = JSON.parse(params_json, symbolize_names: true)
  
  # 创建track状态
  get(:active_tracks)[track_name] = {
    type: segment_type,
    params: params,
    volume: params[:volume] || 1.0,
    cutoff: params[:cutoff] || 130,
    pan: params[:pan] || 0
  }
  
  puts "启动Segment: #{track_name} (类型: #{segment_type})"
  
  # 启动对应的live_loop
  live_loop track_name.to_sym do
    stop if get(:active_tracks)[track_name].nil?
    
    track_state = get(:active_tracks)[track_name]
    
    # 根据segment类型调用对应的播放函数
    case track_state[:type]
    when "kick_pattern"
      play_kick_pattern(track_state[:params], track_state)
    when "snare_pattern"
      play_snare_pattern(track_state[:params], track_state)
    when "hihat_pattern"
      play_hihat_pattern(track_state[:params], track_state)
    when "bass_line"
      play_bass_line(track_state[:params], track_state)
    when "chord_progression"
      play_chord_progression(track_state[:params], track_state)
    when "lead_melody"
      play_lead_melody(track_state[:params], track_state)
    when "arpeggio"
      play_arpeggio(track_state[:params], track_state)
    when "pad"
      play_pad(track_state[:params], track_state)
    when "riser"
      play_riser(track_state[:params], track_state)
    when "ambient_layer"
      play_ambient_layer(track_state[:params], track_state)
    else
      puts "未知Segment类型: #{track_state[:type]}"
      sleep 1
    end
    
    sleep track_state[:params][:duration_bars] || 4
  end
end

# ==================== 节奏类播放函数 ====================
define :play_kick_pattern do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  
  pattern = params[:pattern] || [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]
  synth_name = (params[:synth] || ":bd_haus").to_sym
  
  pattern.each do |hit|
    if hit == 1
      sample synth_name,
        amp: (params[:amp] || 1.0) * state[:volume] * get(:master_volume),
        cutoff: state[:cutoff],
        pan: state[:pan],
        release: params[:release] || 0.3
    end
    sleep 0.25
  end
end

define :play_snare_pattern do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  
  pattern = params[:pattern] || [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0]
  synth_name = (params[:synth] || ":drum_snare_hard").to_sym
  
  pattern.each do |hit|
    if hit == 1
      sample synth_name,
        amp: (params[:amp] || 0.8) * state[:volume] * get(:master_volume),
        cutoff: state[:cutoff],
        pan: state[:pan]
    end
    sleep 0.25
  end
end

define :play_hihat_pattern do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  
  pattern = params[:pattern] || [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0]
  synth_name = (params[:synth] || ":drum_cymbal_closed").to_sym
  
  pattern.each do |hit|
    if hit == 1
      sample synth_name,
        amp: (params[:amp] || 0.5) * state[:volume] * get(:master_volume),
        cutoff: state[:cutoff],
        pan: state[:pan]
    end
    sleep 0.25
  end
end

# ==================== 和声类播放函数 ====================
define :play_bass_line do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth (params[:synth] || ":bass_foundation").to_sym
  
  notes = params[:notes] || [:c2, :c2, :as1, :as1]
  
  notes.each do |note|
    play note.to_sym,
      amp: (params[:amp] || 0.8) * state[:volume] * get(:master_volume),
      cutoff: state[:cutoff],
      res: params[:res] || 0.3,
      release: params[:release] || 0.5,
      pan: state[:pan]
    sleep 1
  end
end

define :play_chord_progression do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth (params[:synth] || ":blade").to_sym
  
  chords = params[:chords] || [[:c4, :e4, :g4], [:a3, :c4, :e4]]
  
  chords.each do |chord|
    play chord.map(&:to_sym),
      amp: (params[:amp] || 0.6) * state[:volume] * get(:master_volume),
      cutoff: state[:cutoff],
      attack: params[:attack] || 0.1,
      release: params[:release] || 1.0,
      pan: state[:pan]
    sleep 2
  end
end

define :play_pad do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth (params[:synth] || ":hollow").to_sym
  
  notes = params[:notes] || [:c3, :e3, :g3]
  
  play notes.map(&:to_sym),
    amp: (params[:amp] || 0.4) * state[:volume] * get(:master_volume),
    cutoff: state[:cutoff],
    attack: params[:attack] || 1.0,
    sustain: params[:sustain] || 2.0,
    release: params[:release] || 2.0,
    pan: state[:pan]
  
  with_fx :reverb, room: params[:reverb] || 0.7 do
    sleep params[:duration_bars] || 4
  end
end

# ==================== 旋律类播放函数 ====================
define :play_lead_melody do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth (params[:synth] || ":blade").to_sym
  
  melody = params[:notes] || [:c4, :e4, :g4, :a4]
  
  melody.each do |note|
    play note.to_sym,
      amp: (params[:amp] || 0.6) * state[:volume] * get(:master_volume),
      cutoff: state[:cutoff],
      attack: params[:attack] || 0.01,
      release: params[:release] || 0.3,
      pan: state[:pan]
    sleep params[:note_duration] || 0.5
  end
end

define :play_arpeggio do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth (params[:synth] || ":pluck").to_sym
  
  notes = params[:notes] || [:c4, :e4, :g4, :c5]
  speed = params[:speed] || 0.25
  
  notes.each do |note|
    play note.to_sym,
      amp: (params[:amp] || 0.5) * state[:volume] * get(:master_volume),
      cutoff: state[:cutoff],
      release: params[:release] || 0.2,
      pan: state[:pan]
    sleep speed
  end
end

# ==================== 氛围类播放函数 ====================
define :play_ambient_layer do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth (params[:synth] || ":dark_ambience").to_sym
  
  with_fx :reverb, room: params[:reverb] || 0.9 do
    play params[:root_note] || :c2,
      amp: (params[:amp] || 0.3) * state[:volume] * get(:master_volume),
      cutoff: state[:cutoff],
      attack: 2,
      sustain: params[:duration_bars] || 4,
      release: 2,
      pan: state[:pan]
  end
  
  sleep params[:duration_bars] || 4
end

# ==================== 特效类播放函数 ====================
define :play_riser do |params, state|
  use_bpm params[:bpm] || get(:global_bpm)
  use_synth :noise
  
  duration = params[:duration_bars] || 8
  steps = duration * 16
  
  steps.times do |i|
    progress = i.to_f / steps
    cutoff = 60 + (70 * progress)
    
    play 60,
      amp: (params[:amp] || 0.5) * progress * state[:volume] * get(:master_volume),
      cutoff: cutoff,
      pan: state[:pan]
    sleep duration.to_f / steps
  end
end

# ==================== Crossfade处理 ====================
define :handle_crossfade do |cmd|
  from_track = cmd[1]
  to_track = cmd[2]
  duration_bars = cmd[3]
  
  puts "执行Crossfade: #{from_track} -> #{to_track} (#{duration_bars} bars)"
  
  # 注意：实际的crossfade由Python端通过set_param控制
  # 这里只是记录
end

# ==================== 参数动态调整 ====================
define :handle_set_param do |cmd|
  track_name = cmd[1]
  param_name = cmd[2]
  param_value = cmd[3]
  
  if get(:active_tracks)[track_name]
    get(:active_tracks)[track_name][param_name.to_sym] = param_value
