# Sonic Pi Universal Player for Numus V03
# 通用播放框架，接收OSC命令执行播放

set :tk, []
set :bpm, 128
set :mv, 1.0
set :lc, 0

puts "Numus V03 Ready"

live_loop :osc do
  use_real_time
  c = sync "/osc*/numus/cmd"
  case c[0]
  when "play"; psg(c)
  when "stop"; stg(c[1])
  when "set"; stp(c[1], c[2], c[3])
  when "stop_all"; set :tk, []
  end
end

define :psg do |c|
  tn = c[1]
  st = c[2]
  pm = JSON.parse(c[3], symbolize_names: true)
  
  stg(tn)
  sleep 0.05
  
  tks = get(:tk)
  tks = tks.reject { |t| t[:n] == tn }
  tks << {n: tn, t: st, p: pm, v: pm[:vol] || 1.0, c: pm[:cut] || 130, a: true}
  set :tk, tks
  
  set :lc, get(:lc) + 1
  ln = "l#{get(:lc)}".to_sym
  
  in_thread name: ln do
    loop do
      tks = get(:tk)
      trk = tks.find { |t| t[:n] == tn && t[:a] }
      break unless trk
      
      case trk[:t]
      when "kick"; pk(trk[:p], trk)
      when "snare"; ps(trk[:p], trk)
      when "hat"; ph(trk[:p], trk)
      when "bass"; pb(trk[:p], trk)
      when "chord"; pch(trk[:p], trk)
      when "lead"; pl(trk[:p], trk)
      when "arp"; par(trk[:p], trk)
      when "pad"; ppad(trk[:p], trk)
      when "rise"; pr(trk[:p], trk)
      when "amb"; pam(trk[:p], trk)
      when "tex"; ptx(trk[:p], trk)
      end
      
      sleep trk[:p][:db] || 4
    end
  end
end

define :s2sym do |v|
  return v unless v.is_a?(String)
  v.start_with?(":") ? v[1..-1].to_sym : v.to_sym
end

define :pk do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  pt = p[:pt] || [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]
  sy = s2sym(p[:syn] || :bd_haus)
  pt.each do |h|
    sample sy, amp: (p[:amp] || 1.0) * s[:v] * get(:mv), cutoff: s[:c], release: p[:rel] || 0.3 if h == 1
    sleep 0.25
  end
end

define :ps do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  pt = p[:pt] || [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0]
  sy = s2sym(p[:syn] || :drum_snare_hard)
  pt.each do |h|
    sample sy, amp: (p[:amp] || 0.8) * s[:v] * get(:mv), cutoff: s[:c] if h == 1
    sleep 0.25
  end
end

define :ph do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  pt = p[:pt] || [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0]
  sy = s2sym(p[:syn] || :drum_cymbal_closed)
  pt.each do |h|
    sample sy, amp: (p[:amp] || 0.5) * s[:v] * get(:mv), cutoff: s[:c] if h == 1
    sleep 0.25
  end
end

define :pb do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth s2sym(p[:syn] || :bass_foundation)
  ns = (p[:ns] || [:c2, :c2, :as1, :as1]).map { |n| s2sym(n) }
  ns.each do |n|
    play n, amp: (p[:amp] || 0.8) * s[:v] * get(:mv), cutoff: s[:c], 
         res: p[:res] || 0.3, release: p[:rel] || 0.5
    sleep 1
  end
end

define :pch do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth s2sym(p[:syn] || :blade)
  chs = p[:chs] || [[:c4, :e4, :g4], [:a3, :c4, :e4]]
  chs = chs.map { |ch| ch.map { |n| s2sym(n) } }
  chs.each do |ch|
    play ch, amp: (p[:amp] || 0.6) * s[:v] * get(:mv), cutoff: s[:c],
         attack: p[:atk] || 0.1, release: p[:rel] || 1.0
    sleep 2
  end
end

define :pl do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth s2sym(p[:syn] || :blade)
  ns = (p[:ns] || [:c4, :e4, :g4, :a4]).map { |n| s2sym(n) }
  ns.each do |n|
    play n, amp: (p[:amp] || 0.6) * s[:v] * get(:mv), cutoff: s[:c],
         attack: p[:atk] || 0.01, release: p[:rel] || 0.3
    sleep p[:nd] || 0.5
  end
end

define :par do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth s2sym(p[:syn] || :pluck)
  ns = (p[:ns] || [:c4, :e4, :g4, :c5]).map { |n| s2sym(n) }
  sp = p[:spd] || 0.25
  ns.each do |n|
    play n, amp: (p[:amp] || 0.5) * s[:v] * get(:mv), cutoff: s[:c], release: p[:rel] || 0.2
    sleep sp
  end
end

define :ppad do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth s2sym(p[:syn] || :hollow)
  ns = (p[:ns] || [:c3, :e3, :g3]).map { |n| s2sym(n) }
  with_fx :reverb, room: p[:rev] || 0.7 do
    play ns, amp: (p[:amp] || 0.4) * s[:v] * get(:mv), cutoff: s[:c],
         attack: p[:atk] || 1.0, sustain: p[:sus] || 2.0, release: p[:rel] || 2.0
    sleep p[:db] || 4
  end
end

define :pr do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth :noise
  db = p[:db] || 8
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
  use_synth s2sym(p[:syn] || :dark_ambience)
  rn = s2sym(p[:rn] || :c2)
  with_fx :reverb, room: p[:rev] || 0.9 do
    play rn, amp: (p[:amp] || 0.3) * s[:v] * get(:mv),
         cutoff: s[:c], attack: 2, sustain: p[:db] || 4, release: 2
    sleep p[:db] || 4
  end
end

define :ptx do |p, s|
  use_bpm p[:bpm] || get(:bpm)
  use_synth s2sym(p[:syn] || :blade)
  ns = p[:ns] ? (p[:ns].is_a?(Array) ? p[:ns].map { |n| s2sym(n) } : s2sym(p[:ns])) : :c3
  with_fx :reverb, room: p[:rev] || 0.7 do
    with_fx :lpf, cutoff: s[:c] do
      play ns, amp: (p[:amp] || 0.4) * s[:v] * get(:mv),
           attack: p[:atk] || 0.5, sustain: p[:sus] || 3.0, release: p[:rel] || 1.0
      sleep p[:db] || 8
    end
  end
end

define :stg do |tn|
  tks = get(:tk)
  new_tks = []
  tks.each do |t|
    if t[:n] == tn
      new_tks << {n: t[:n], t: t[:t], p: t[:p], v: t[:v], c: t[:c], a: false}
    else
      new_tks << t
    end
  end
  set :tk, new_tks
end

define :stp do |tn, pn, pv|
  tks = get(:tk)
  new_tks = []
  tks.each do |t|
    if t[:n] == tn
      new_v = t[:v]
      new_c = t[:c]
      new_p = t[:p]
      
      case pn
      when "vol"; new_v = pv.to_f
      when "cut"; new_c = pv.to_f
      else
        new_p = t[:p].dup
        new_p[pn.to_sym] = pv
      end
      
      new_tks << {n: t[:n], t: t[:t], p: new_p, v: new_v, c: new_c, a: t[:a]}
    else
      new_tks << t
    end
  end
  set :tk, new_tks
end

# 变量名压缩
# tk = tracks
# bpm = BPM
# mv = master_volume
# tn = track_name
# st = segment_type
# pm = params
# s = state
# p = params

# 参数名压缩
# :volume -> :vol
# :cutoff -> :cut
# :duration_bars -> :db
# :pattern -> :pt
# :synth -> :syn
# :notes -> :ns
# :chords -> :chs
# :attack -> :atk
# :release -> :rel
# :sustain -> :sus
# :reverb -> :rev
# :root_note -> :rn
# :note_duration -> :nd
# :speed -> :spd

# 函数名压缩
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

# 类型名压缩
# "kick_pattern" -> "kick"
# "snare_pattern" -> "snare"
# "hihat_pattern" -> "hat"
# "bass_line" -> "bass"
# "chord_progression" -> "chord"
# "lead_melody" -> "lead"
# "arpeggio" -> "arp"
# "pad" -> "pad"
# "riser" -> "rise"
# "ambient_layer" -> "amb"
# "texture" -> "tex"