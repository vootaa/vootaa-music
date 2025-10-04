# Sonic Pi Universal Player for Numus V03
# 通用播放框架，接收OSC命令执行播放

set :tk, {}
set :bpm, 128
set :mv, 1.0

puts "Numus V03 Ready"

live_loop :osc do
  use_real_time
  c = sync "/osc*/numus/cmd"
  case c[0]
  when "play_segment"; play_seg(c)
  when "stop_segment"; stop_seg(c[1])
  when "set_param"; set_p(c[1], c[2], c[3])
  when "stop_all"; get(:tk).clear
  end
end

define :play_seg do |c|
  tn = c[1]
  st = c[2]
  pm = JSON.parse(c[3], symbolize_names: true)
  
  get(:tk)[tn] = {t: st, p: pm, v: pm[:volume] || 1.0, c: pm[:cutoff] || 130}
  
  live_loop tn.to_sym do
    stop if get(:tk)[tn].nil?
    s = get(:tk)[tn]
    case s[:t]
    when "kick_pattern"; pk(s[:p], s)
    when "snare_pattern"; ps(s[:p], s)
    when "hihat_pattern"; ph(s[:p], s)
    when "bass_line"; pb(s[:p], s)
    when "chord_progression"; pch(s[:p], s)
    when "lead_melody"; pl(s[:p], s)
    when "arpeggio"; par(s[:p], s)
    when "pad"; ppad(s[:p], s)
    when "riser"; pr(s[:p], s)
    when "ambient_layer"; pam(s[:p], s)
    end
    sleep s[:p][:duration_bars] || 4
  end
end

define :pk do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  pt = p[:pattern] || [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]
  sy = (p[:synth] || ":bd_haus").to_sym
  pt.each do |h|
    sample sy, amp: (p[:amp] || 1.0) * s[:v] * get(:mv), cutoff: s[:c] if h == 1
    sleep 0.25
  end
end

define :ps do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  pt = p[:pattern] || [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0]
  sy = (p[:synth] || ":drum_snare_hard").to_sym
  pt.each do |h|
    sample sy, amp: (p[:amp] || 0.8) * s[:v] * get(:mv), cutoff: s[:c] if h == 1
    sleep 0.25
  end
end

define :ph do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  pt = p[:pattern] || [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0]
  sy = (p[:synth] || ":drum_cymbal_closed").to_sym
  pt.each do |h|
    sample sy, amp: (p[:amp] || 0.5) * s[:v] * get(:mv), cutoff: s[:c] if h == 1
    sleep 0.25
  end
end

define :pb do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":bass_foundation").to_sym
  ns = p[:notes] || [:c2, :c2, :as1, :as1]
  ns.each do |n|
    play n.to_sym, amp: (p[:amp] || 0.8) * s[:v] * get(:mv), cutoff: s[:c], 
         res: p[:res] || 0.3, release: p[:release] || 0.5
    sleep 1
  end
end

define :pch do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":blade").to_sym
  chs = p[:chords] || [[:c4, :e4, :g4], [:a3, :c4, :e4]]
  chs.each do |ch|
    play ch.map(&:to_sym), amp: (p[:amp] || 0.6) * s[:v] * get(:mv), cutoff: s[:c],
         attack: p[:attack] || 0.1, release: p[:release] || 1.0
    sleep 2
  end
end

define :pl do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":blade").to_sym
  ns = p[:notes] || [:c4, :e4, :g4, :a4]
  ns.each do |n|
    play n.to_sym, amp: (p[:amp] || 0.6) * s[:v] * get(:mv), cutoff: s[:c],
         attack: p[:attack] || 0.01, release: p[:release] || 0.3
    sleep p[:note_duration] || 0.5
  end
end

define :par do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":pluck").to_sym
  ns = p[:notes] || [:c4, :e4, :g4, :c5]
  sp = p[:speed] || 0.25
  ns.each do |n|
    play n.to_sym, amp: (p[:amp] || 0.5) * s[:v] * get(:mv), cutoff: s[:c],
         release: p[:release] || 0.2
    sleep sp
  end
end

define :ppad do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":hollow").to_sym
  ns = p[:notes] || [:c3, :e3, :g3]
  with_fx :reverb, room: p[:reverb] || 0.7 do
    play ns.map(&:to_sym), amp: (p[:amp] || 0.4) * s[:v] * get(:mv), cutoff: s[:c],
         attack: p[:attack] || 1.0, sustain: p[:sustain] || 2.0, release: p[:release] || 2.0
    sleep p[:duration_bars] || 4
  end
end

define :pr do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth :noise
  db = p[:duration_bars] || 8
  st = db * 16
  st.times do |i|
    pg = i.to_f / st
    ct = 60 + (70 * pg)
    play 60, amp: (p[:amp] || 0.5) * pg * s[:v] * get(:mv), cutoff: ct
    sleep db.to_f / st
  end
end

define :pam do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":dark_ambience").to_sym
  with_fx :reverb, room: p[:reverb] || 0.9 do
    play (p[:root_note] || :c2).to_sym, amp: (p[:amp] || 0.3) * s[:v] * get(:mv),
         cutoff: s[:c], attack: 2, sustain: p[:duration_bars] || 4, release: 2
    sleep p[:duration_bars] || 4
  end
end

define :ptex do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth (p[:synth] || ":blade").to_sym
  
  with_fx :reverb, room: p[:reverb] || 0.7 do
    with_fx :lpf, cutoff: s[:c] do
      play p[:notes].map(&:to_sym), 
        amp: (p[:amp] || 0.4) * s[:v],
        attack: p[:attack] || 0.5,
        sustain: p[:sustain] || 3.0,
        release: p[:release] || 1.0
      sleep p[:duration_bars] || 8
    end
  end
end

define :stop_seg do |tn|
  get(:tk).delete(tn)
end

define :set_p do |tn, pn, pv|
  get(:tk)[tn][pn.to_sym] = pv if get(:tk)[tn]
end


# 极简变量名：
# tk = tracks
# bpm = BPM
# mv = master_volume
# tn = track_name
# st = segment_type
# pm = params
# s = state
# p = params

# 函数命名压缩：
# pk = play_kick
# ps = play_snare
# ph = play_hihat
# pb = play_bass
# pch = play_chord
# pl = play_lead
# par = play_arpeggio
# ppad = play_pad
# pr = play_riser
# pam = play_ambient
# ptex = play_texture