# Numus-Engine.rb
# 通用 OSC 驱动 EDM 引擎（Sonic Pi）
# 设计原则：
# 1. 绝不内置乐曲特定参数：所有状态由 OSC 设置 (/engine/*)。
# 2. 可扩展：新增参数无需改核心，只需发送 /engine/param/<name> 或 /engine/toggle/<name>
# 3. 确定性：不使用 rand / choose。旋律序列需外部提供。
# 4. 声部解耦：每个 live_loop 查询全局状态并自适应。
# 5. 模式/节奏可通过 /engine/pattern/<part> <pattern_id> 切换。

use_debug false
use_osc_logging false

###############
# STATE STORE #
###############
# 基础控制变量初始化（外部会覆盖）
set :engine_ready, true
set :bpm, 120
set :energy, 0.3
set :density, 0.2
set :chord_prog, ["C"]
set :chord_index, 0
set :active_parts, []         # ["kick","pad","bass","lead",...]
set :lead_degrees, []         # 例: ["0","2","4","5"] 外部通过 /engine/lead_seq
set :lead_step, 0
set :decor_samples, []        # 通过 /engine/decor/add & /engine/decor/clear
set :toggles, {}              # bool map
set :params_num, {}           # numeric map
set :patterns, {}             # pattern id per part
set :tick_counter, 0
set :bar_counter, 0
set :beats_per_bar, 4

###############
# UTILITIES   #
###############
define :boolify do |v|
  return false if v.nil?
  s = v.to_s.downcase
  return true if ["1","true","on","yes"].include?(s)
  return false
end

define :update_toggle do |name, val|
  t = get(:toggles).dup
  t[name.to_sym] = boolify(val)
  set :toggles, t
end

define :toggle? do |name|
  h = get(:toggles)
  h[name.to_sym] || false
end

define :update_param_num do |name, val|
  h = get(:params_num).dup
  h[name.to_sym] = val.to_f
  set :params_num, h
end

define :param_num do |name, default=0.0|
  h = get(:params_num)
  h.fetch(name.to_sym, default)
end

define :current_chord_root do
  prog = get(:chord_prog)
  idx = get(:chord_index) % [prog.length,1].max
  prog[idx]
end

define :safe_chord_notes do |root|
  begin
    # 尝试从符号解析，如 "Am", "G", "Cmaj7" 的简单处理
    # 若包含 'm' 视为小三和弦，否则大三
    if root.to_s.include?("m") && !root.to_s.include?("maj")
      chord(root.to_sym, :minor)
    else
      chord(root.to_sym, :major)
    end
  rescue
    [note(root)]
  end
end

###############
# PATTERN LIB #
###############
# 仅内置少量模式，可扩展；由 /engine/pattern/<part> 选择
# 标准接口：pattern_fn.(local_beat_in_bar, bar_index, global_tick) => bool
$pattern_library = {
  "kick_four_on_floor" => lambda { |b, _bar, _g| b == 0 || b == 1 || b == 2 || b == 3 },
  "kick_half"          => lambda { |b, _bar, _g| b == 0 || b == 2 },
  "kick_sparse_intro"  => lambda { |b, bar, _g| (bar < 2) ? (b == 0) : (b == 0 || b == 2) },
  "snare_backbeat"     => lambda { |b, _bar, _g| b == 1 || b == 3 },
  "snare_half"         => lambda { |b, _bar, _g| b == 3 },
  "hat_offbeat"        => lambda { |b, _bar, _g| b == 0.5 || b == 1.5 || b == 2.5 || b == 3.5 },
  "lead_every_2beats"  => lambda { |b, _bar, _g| (b % 2).abs < 0.001 },
  "lead_syncopated"    => lambda { |b, _bar, _g| [0,1.5,2,3.25].include?(b) },
  "bass_on_beats"      => lambda { |b, _bar, _g| b.to_i == b },
  "bass_drive"         => lambda { |b, _bar, _g| b == 0 || b == 1 || b == 2.5 || b == 3 }
}

define :pattern_hit? do |part, local_beat, bar_idx, global_tick|
  patterns = get(:patterns)
  pid = patterns.fetch(part.to_sym, nil)
  return false if pid.nil?
  fn = $pattern_library[pid]
  return false unless fn
  fn.call(local_beat, bar_idx, global_tick)
end

###############
# OSC RECEIVE #
###############
# 约定地址:
# /engine/bpm              <num>
# /engine/energy           <num>
# /engine/density          <num>
# /engine/chord_prog       "C,G,Am,F"
# /engine/chord_index      <int>
# /engine/parts            "kick,bass,pad"
# /engine/lead_seq         "0,2,4,5"
# /engine/pattern/<part>   <pattern_id>
# /engine/toggle/<name>    0|1|true|false
# /engine/param/<name>     <float>
# /engine/decor/add        "/abs/path/sample.wav"
# /engine/decor/clear      (any payload)
# /engine/next_chord       (advance chord index +1)
# /engine/debug            free string (prints)

live_loop :osc_router do
  use_real_time
  addr, *vals = sync "/osc*/engine/*"
  # addr like "/osc:127.0.0.1:4560/engine/bpm"
  core = addr.split("/engine/")[1]
  if core
    # 分发
    if core == "bpm"
      set :bpm, vals[0].to_f
      use_bpm get(:bpm)
      puts ">> BPM=#{get(:bpm)}"
    elsif core == "energy"
      set :energy, vals[0].to_f
    elsif core == "density"
      set :density, vals[0].to_f
    elsif core == "chord_prog"
      cp = vals[0].to_s.split(",").map(&:strip)
      set :chord_prog, cp if cp.length > 0
    elsif core == "chord_index"
      set :chord_index, vals[0].to_i
    elsif core == "parts"
      set :active_parts, vals[0].to_s.split(",").map(&:strip)
    elsif core == "lead_seq"
      set :lead_degrees, vals[0].to_s.split(",").map(&:strip)
      set :lead_step, 0
    elsif core.start_with?("pattern/")
      part = core.split("pattern/")[1]
      h = get(:patterns).dup
      h[part.to_sym] = vals[0].to_s
      set :patterns, h
    elsif core.start_with?("toggle/")
      name = core.split("toggle/")[1]
      update_toggle(name, vals[0])
    elsif core.start_with?("param/")
      name = core.split("param/")[1]
      update_param_num(name, vals[0])
    elsif core == "decor/add"
      arr = get(:decor_samples).dup
      path = vals[0].to_s
      unless arr.include?(path)
        arr << path
        set :decor_samples, arr
      end
    elsif core == "decor/clear"
      set :decor_samples, []
    elsif core == "next_chord"
      set :chord_index, get(:chord_index) + 1
    elsif core == "debug"
      puts "DEBUG: #{vals.inspect}"
    end
  end
end

###############
# CLOCK / MET #
###############
live_loop :master_clock do
  use_bpm get(:bpm)
  beat = get(:tick_counter)
  bar = get(:bar_counter)
  cue :beat_tick, beat: beat, bar: bar
  # 维护计数
  next_beat = beat + 1
  if (next_beat % get(:beats_per_bar) == 0)
    set :bar_counter, bar + 1
  end
  set :tick_counter, next_beat
  sleep 1  # one beat at current BPM
end

################
# PART: KICK   #
################
live_loop :kick do
  sync :beat_tick
  parts = get(:active_parts)
  stop unless parts.include?("kick")
  bpb = get(:beats_per_bar)
  beat = get(:tick_counter) - 1
  local_beat = (beat % bpb)
  bar = get(:bar_counter)
  # pattern check
  hit = pattern_hit?("kick", local_beat, bar, beat)
  # fallback: if no pattern set and density moderate以上 → four on floor
  if get(:patterns)[:kick].nil?
    hit ||= true
  end
  if hit
    amp_scale = [[0.2, get(:energy)].max, 1.5].min
    sample :bd_tek, amp: amp_scale
  end
end

################
# PART: SNARE  #
################
live_loop :snare do
  sync :beat_tick
  parts = get(:active_parts)
  stop unless parts.include?("snare") || toggle?("snare")
  bpb = get(:beats_per_bar)
  beat = get(:tick_counter) - 1
  local_beat = (beat % bpb)
  bar = get(:bar_counter)
  hit = pattern_hit?("snare", local_beat, bar, beat)
  # fallback backbeat
  if get(:patterns)[:snare].nil?
    hit ||= ([1,3].include?(local_beat))
  end
  if hit
    sample :sn_dolf, amp: get(:energy) * 0.8
  end
end

################
# PART: BASS   #
################
live_loop :bass do
  sync :beat_tick
  parts = get(:active_parts)
  stop unless parts.include?("bass")
  beat = get(:tick_counter) - 1
  bpb = get(:beats_per_bar)
  local_beat = (beat % bpb)
  bar = get(:bar_counter)
  hit = pattern_hit?("bass", local_beat, bar, beat)
  if get(:patterns)[:bass].nil?
    hit ||= (local_beat.to_i == local_beat) # default on each beat
  end
  if hit
    root = current_chord_root
    n = note(root) - 12
    cutoff = 60 + (get(:energy) * 40)
    synth :tb303,
      note: n,
      sustain: 0.6,
      release: 0.2,
      cutoff: cutoff,
      amp: get(:energy) * 0.9 * (toggle?("sub_fade") ? param_num(:sub_fade_level, 1.0) : 1.0)
  end
end

################
# PART: PAD    #
################
live_loop :pad do
  # 每小节开头进来
  sync :beat_tick
  parts = get(:active_parts)
  stop unless parts.include?("pad")
  beat = get(:tick_counter) - 1
  bpb = get(:beats_per_bar)
  local_beat = (beat % bpb)
  next unless local_beat == 0
  root = current_chord_root
  notes = safe_chord_notes(root)
  with_fx :reverb, mix: 0.35, room: 0.7 do
    with_fx :lpf, cutoff: (toggle?("filter_sweep") ? param_num(:pad_cutoff, 90) : 120) do
      synth :prophet, notes: notes,
        sustain: bpb * 0.9,
        release: 1,
        amp: get(:energy) * 0.6
    end
  end
end

################
# PART: LEAD   #
################
live_loop :lead do
  sync :beat_tick
  parts = get(:active_parts)
  stop unless parts.include?("lead")
  # 通过 pattern 或 fallback
  beat = get(:tick_counter) - 1
  bpb = get(:beats_per_bar)
  local_beat = (beat % bpb).to_f
  bar = get(:bar_counter)
  hit = pattern_hit?("lead", local_beat, bar, beat)
  if get(:patterns)[:lead].nil?
    # fallback: 每 2 拍
    hit ||= (local_beat % 2 == 0)
  end
  if hit
    seq = get(:lead_degrees)
    if seq.length > 0
      idx = get(:lead_step) % seq.length
      deg = seq[idx].to_i
      set :lead_step, get(:lead_step) + 1
      root = note(current_chord_root)
      scale_notes = scale(root, :major, num_octaves: 2) # 可外部未来换 scale
      nt = scale_notes[deg % scale_notes.length]
      cutoff = 90 + get(:energy) * 40
      with_fx :echo, phase: 0.25, mix: 0.2 do
        synth :blade, note: nt,
          sustain: 0.3,
          release: 0.2,
          cutoff: cutoff,
          amp: 0.5 + get(:energy) * 0.5
      end
    end
  end
end

################
# PART: FX RISER
################
live_loop :fx_riser do
  sync :beat_tick
  stop unless toggle?("fx_riser")
  beat = get(:tick_counter) - 1
  # 每小节首触发长噪声渐变
  bpb = get(:beats_per_bar)
  local_beat = beat % bpb
  if local_beat == 0
    with_fx :slicer, phase: 0.25, mix: 0.3 do
      synth :noise,
        sustain: bpb * 0.9,
        release: 0.5,
        amp: get(:energy) * 0.4,
        cutoff: 100 + get(:energy)*20
    end
  end
end

################
# PART: FILTER SWEEP CONTROLLER
################
live_loop :filter_sweep_ctrl do
  sync :beat_tick
  stop unless toggle?("filter_sweep")
  # 外部可不发 pad_cutoff；如需自动渐变，可使用 param: sweep_progress (0..1)
  prog = param_num(:sweep_progress, 0.0) # 外部定时更新
  cutoff_val = 70 + (prog.clamp(0,1) * 60)
  update_param_num(:pad_cutoff, cutoff_val)
end

################
# PART: DECOR SAMPLES
################
live_loop :decor_play do
  sync :beat_tick
  arr = get(:decor_samples)
  stop if arr.empty?
  # 播放速率受 density 控制；简单稀疏策略
  # density<0.4 -> 每 8 拍一次; <0.6 -> 每 4 拍; else 每 2 拍
  beat = get(:tick_counter) - 1
  interval = if get(:density) < 0.4
               8
             elsif get(:density) < 0.6
               4
             else
               2
             end
  if beat % interval == 0
    # 轮询方式（不随机）
    idx = (beat / interval) % arr.length
    path = arr[idx]
    if File.exists?(path)
      with_fx :reverb, mix: 0.35 do
        sample path, amp: 0.6 + get(:energy)*0.4
      end
    else
      puts "WARN decor sample missing: #{path}"
    end
  end
end

################
# PART: DELAY / DIST / REVERB GLOBAL MOD (OPTIONAL)
################
# 外部通过 /engine/param/delay_mix, /engine/param/dist_mix, /engine/param/reverb_mix
# 可以被其他 loop 包裹使用（本示例未对所有部件重复包裹，仅提供参数参考）
# 用户可扩展在具体 part 中引用 param_num(:dist_mix,0.0) 等进行动态效果调制

puts "Numus-Engine loaded. Awaiting OSC control (/engine/*)."