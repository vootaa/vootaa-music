use_debug false
use_osc_logging false

set :bpm,120
set :engine_run,true
set :tick_counter,0
set :bar_counter,0
set :beats_per_bar,4
set :chord_prog,["C"]
set :chord_index,0
set :active_parts,[]
set :lead_degrees,[]
set :lead_step,0
set :decor_samples,[]

def g(k,d=nil); v=get(k); v.nil? ? d : v end
def t?(n); !!g("tg_"+n) end
def set_t(n,v); set "tg_"+n, %w(1 true on yes).include?(v.to_s.downcase) end
def set_p(n,v); set "pn_"+n, v.to_f end
def p(n,d=0); g("pn_"+n,d) end
def set_pat(part,id); set "pt_"+part,id.to_s end
def pat(part); g("pt_"+part) end

def cur_chord_token
  pr=g(:chord_prog); i=g(:chord_index).to_i % [pr.length,1].max; pr[i]
end
def root_sym(tok)
  m=tok.to_s.strip.match(/\A([A-Ga-g])([#b]?)/); (m ? (m[1]+(m[2]||"")) : "c").downcase.to_sym
end
def chord_from_token(tok)
  s=tok.to_s.downcase; minor=(s.include?("m") && !s.include?("maj"))
  chord(root_sym(tok), minor ? :minor : :major)
rescue; [note(:c)]; end
def inv_chord(tok,inv)
  ns=chord_from_token(tok); inv.to_i.times { ns<< (ns.shift+12) } ; ns
end
def root_note_val; note(root_sym(cur_chord_token)) end

$pt={
 "kick_four_on_floor"=>->(b,_bar,_gt){[0,1,2,3].include?(b)},
 "kick_half"=>->(b,_bar,_gt){[0,2].include?(b)},
 "kick_sparse_intro"=>->(b,bar,_g){bar<2 ? b==0 : [0,2].include?(b)},
 "snare_backbeat"=>->(b,_bar,_g){[1,3].include?(b)},
 "hat_offbeat"=>->(b,_bar,_g){[0.5,1.5,2.5,3.5].include?(b)},
 "lead_every_2beats"=>->(b,_bar,_g){(b % 2).abs<0.001},
 "lead_syncopated"=>->(b,_bar,_g){[0,1.5,2,3.25].include?(b)},
 "bass_on_beats"=>->(b,_bar,_g){b.to_i==b},
 "bass_drive"=>->(b,_bar,_g){[0,1,2.5,3].include?(b)}
}
def phit?(part,lb,bar,gt)
  pid=pat(part); return false unless pid
  fn=$pt[pid]; return false unless fn
  fn.call(lb,bar,gt)
end

def sc_amp(a)
  d=p(:sidechain_depth,0.0); return a if d<=0
  ph=(g(:tick_counter) % g(:beats_per_bar)).to_f
  curve = case ph; when 0 then 1-d*0.85; when 1 then 1-d*0.55; when 2 then 1-d*0.75; when 3 then 1-d*0.40; else 1-d*0.5 end
  a*curve
end
def hat_hit?(lb)
  d=p(:hat_density,0).to_i
  case d
  when 0 then false
  when 1 then [0.5,1.5,2.5,3.5].include?(lb+0.5)
  when 2 then ((lb*2)%1==0.5) || (lb%1==0)
  else ((lb*4)%1).abs<0.001
  end
end

live_loop :osc_stop do
  use_real_time; sync "/osc*/engine/stop"; set :engine_run,false
  in_thread do 12.times do set_p :master_amp, p(:master_amp,1.0)*0.7; sleep 0.2 end; set_p :master_amp,0 end
end

live_loop :osc_chord_prog do
  use_real_time; v=sync "/osc*/engine/chord_prog"; set :chord_prog, v[0].to_s.split(",").map(&:strip)
end
live_loop :osc_parts do
  use_real_time; v=sync "/osc*/engine/parts"; set :active_parts, v[0].to_s.split(",").map(&:strip)
end
live_loop :osc_lead_seq do
  use_real_time; v=sync "/osc*/engine/lead_seq"; set :lead_degrees, v[0].to_s.split(","); set :lead_step,0
end

%w(bpm energy density chord_index pad_cutoff sweep_progress sub_fade_level master_amp
   hat_density sidechain_depth bass_drive lead_detune reverb_bus delay_mix stereo_spread chord_inversion).each do |n|
  live_loop ("osc_p_"+n).to_sym do
    use_real_time
    v=sync "/osc*/engine/param/#{n}"
    if n=="bpm"; set :bpm,v[0].to_f
    elsif n=="chord_index"; set :chord_index,v[0].to_i
    else set_p n,v[0]
    end
  end
end

%w(fx_riser filter_sweep sub_fade texture_air texture_grain callback_theme anti_drop drop_gap snare_roll snare_fill).each do |n|
  live_loop ("osc_t_"+n).to_sym do
    use_real_time; v=sync "/osc*/engine/toggle/#{n}"; set_t n,v[0]
  end
end

%w(kick snare bass pad hat lead).each do |pname|
  live_loop ("osc_pat_"+pname).to_sym do
    use_real_time; v=sync "/osc*/engine/pattern/#{pname}"; set_pat pname, v[0]
  end
end

live_loop :osc_decor_add do
  use_real_time; v=sync "/osc*/engine/decor/add"; a=g(:decor_samples).dup; path=v[0].to_s; a<<path unless a.include?(path); set :decor_samples,a
end
live_loop :osc_decor_clear do
  use_real_time; sync "/osc*/engine/decor/clear"; set :decor_samples,[]
end

live_loop :osc_debug_any do
  use_real_time; v=sync "/osc*/engine/debug"; puts "[DBG] #{v.inspect}"
end

live_loop :clock do
  stop unless g(:engine_run)
  use_bpm g(:bpm,120)
  bt=g(:tick_counter); bar=g(:bar_counter)
  cue :beat_tick, beat:bt, bar:bar
  nb=bt+1
  set :bar_counter, bar+1 if nb % g(:beats_per_bar) == 0
  set :tick_counter, nb
  sleep 1
end

live_loop :kick do
  sync :beat_tick; break unless g(:engine_run); next unless g(:active_parts).include?("kick")
  bpb=g(:beats_per_bar); beat=g(:tick_counter)-1; lb=beat % bpb; bar=g(:bar_counter)
  if phit?("kick",lb,bar,beat) || !pat("kick")
    base=[[0.35,g(:energy)+0.15].max,1.0].min
    sample :bd_tek, amp: base*p(:master_amp,1)
  end
end

live_loop :snare do
  sync :beat_tick; break unless g(:engine_run); ap=g(:active_parts); play_it=ap.include?("snare") || t?("snare_fill") || t?("snare_roll")
  next unless play_it
  bpb=g(:beats_per_bar); beat=g(:tick_counter)-1; lb=beat % bpb; bar=g(:bar_counter)
  if t?("snare_roll") && lb>=3
    4.times { sample :sn_dolf, amp:g(:energy)*0.35*p(:master_amp,1); sleep 0.125 }; next
  end
  hit=phit?("snare",lb,bar,beat) || (!pat("snare") && [1,3].include?(lb))
  sample :sn_dolf, amp:g(:energy)*0.8*p(:master_amp,1) if hit
end

live_loop :hat do
  sync :beat_tick; break unless g(:engine_run); next unless g(:active_parts).include?("hat")
  bpb=g(:beats_per_bar); beat=g(:tick_counter)-1; lb=beat % bpb
  if hat_hit?(lb)
    sample :hat_zap, amp: sc_amp(0.12+g(:energy)*0.25)*p(:master_amp,1), pan: rrand(-0.35,0.35)
  end
end

live_loop :bass do
  sync :beat_tick; break unless g(:engine_run); next unless g(:active_parts).include?("bass")
  bpb=g(:beats_per_bar); beat=g(:tick_counter)-1; lb=beat % bpb; bar=g(:bar_counter)
  next if t?("drop_gap") && lb<2
  hit=phit?("bass",lb,bar,beat) || (!pat("bass") && lb.to_i==lb)
  if hit
    n=root_note_val-12
    mul = t?("sub_fade") ? p(:sub_fade_level,1) : 1
    drv = p(:bass_drive,0)
    synth :tb303, note:n, sustain:0.55, release:0.2,
      cutoff: (60+g(:energy)*40 + drv*25),
      res: 0.7+drv*0.15,
      amp: sc_amp(g(:energy)*0.85*mul*p(:master_amp,1))
  end
end

live_loop :pad do
  sync :beat_tick; break unless g(:engine_run); next unless g(:active_parts).include?("pad")
  beat=g(:tick_counter)-1; bpb=g(:beats_per_bar); next unless beat % bpb == 0
  notes = inv_chord(cur_chord_token, p(:chord_inversion,0))
  cutoff = t?("filter_sweep") ? p(:pad_cutoff,90) : 120
  with_fx :reverb, mix:p(:reverb_bus,0.2), room:0.8 do
    with_fx :echo, mix:p(:delay_mix,0.1), phase:0.375 do
      with_fx :lpf, cutoff:cutoff do
        synth :prophet, note:notes, sustain:bpb*0.9, release:1,
          amp: sc_amp((0.28+g(:energy)*0.7)*p(:master_amp,1))
      end
    end
  end
end

live_loop :lead do
  sync :beat_tick; break unless g(:engine_run); next unless g(:active_parts).include?("lead")
  bpb=g(:beats_per_bar); beat=g(:tick_counter)-1; lb=(beat % bpb).to_f; bar=g(:bar_counter)
  next if t?("drop_gap") && lb<2
  hit=phit?("lead",lb,bar,beat) || (!pat("lead") && (lb % 2 == 0))
  seq=g(:lead_degrees); next if seq.empty?
  if hit
    idx=g(:lead_step)%seq.length; set :lead_step,g(:lead_step)+1
    sca=scale(root_note_val,:major,num_octaves:2)
    nt=sca[seq[idx].to_i % sca.length]
    det=p(:lead_detune,0)
    with_fx :reverb, mix:p(:reverb_bus,0.2) do
      with_fx :echo, mix:p(:delay_mix,0.12), phase:0.25 do
        with_fx :chorus, depth:det*3, mix:det*0.6 do
          synth :blade, note:nt, sustain:0.3, release:0.18,
            cutoff:90+g(:energy)*40, amp: sc_amp((0.38+g(:energy)*0.6)*p(:master_amp,1))
        end
      end
    end
  end
end

live_loop :fx_riser do
  sync :beat_tick; break unless g(:engine_run); next unless t?("fx_riser")
  bpb=g(:beats_per_bar); beat=g(:tick_counter)-1
  if beat % bpb == 0
    with_fx :slicer, phase:0.25, mix:0.25 do
      synth :noise, sustain:bpb*0.9, release:0.4,
        cutoff: 100+g(:energy)*25,
        amp: sc_amp(g(:energy)*0.35*p(:master_amp,1))
    end
  end
end

live_loop :textures do
  sync :beat_tick; break unless g(:engine_run)
  play_tex = t?("texture_air") || t?("texture_grain")
  next unless play_tex
  beat=g(:tick_counter)-1
  interval = t?("texture_grain") ? 8 : 12
  if beat % interval == 0
    n = root_note_val + (t?("texture_grain") ? 24 : 36)
    synth :hollow, note:n, release:4,
      amp: sc_amp(0.15+g(:energy)*0.18)*p(:master_amp,1)
  end
end

live_loop :decor do
  sync :beat_tick; break unless g(:engine_run)
  arr=g(:decor_samples); next if arr.empty?
  beat=g(:tick_counter)-1
  interval = g(:density) < 0.4 ? 8 : (g(:density) < 0.6 ? 4 : 2)
  if beat % interval == 0
    path=arr[(beat/interval) % arr.length]
    if File.exists?(path)
      with_fx :reverb, mix:0.35 do
        sample path, amp: sc_amp((0.55+g(:energy)*0.45)*p(:master_amp,1))
      end
    end
  end
end

live_loop :filter_sweep_ctrl do
  sync :beat_tick; break unless g(:engine_run)
  next unless t?("filter_sweep")
  prog=[[p(:sweep_progress,0),0].max,1].min
  set_p :pad_cutoff, 70 + prog*60
end

puts "Numus Engine Ready."