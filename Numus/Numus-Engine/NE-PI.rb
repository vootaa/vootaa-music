use_debug false
use_osc_logging false

set :bpm,120
set :energy,0.3
set :density,0.2
set :chord_prog,["C"]
set :chord_index,0
set :active_parts,[]
set :lead_degrees,[]
set :lead_step,0
set :decor_samples,[]
set :tick_counter,0
set :bar_counter,0
set :beats_per_bar,4

define :boolify do |v|
  ["1","true","on","yes"].include?(v.to_s.downcase)
end
define :set_toggle do |name,val|
  set ("tg_"+name.to_s).to_sym, boolify(val)
end
define :toggle? do |name|
  !!get(("tg_"+name.to_s).to_sym)
end
define :set_param_num do |name,val|
  set ("pn_"+name.to_s).to_sym, val.to_f
end
define :param_num do |name,default=0.0|
  v=get(("pn_"+name.to_s).to_sym); v.nil? ? default : v
end
define :set_pattern do |part,pid|
  set ("pt_"+part.to_s).to_sym, pid.to_s
end
define :pattern_of do |part|
  get(("pt_"+part.to_s).to_sym)
end
define :current_chord_root do
  prog=get(:chord_prog); i=get(:chord_index) % [prog.length,1].max; prog[i]
end
define :safe_chord_notes do |root|
  begin
    if root.to_s.include?("m") && !root.to_s.include?("maj")
      chord(root.to_sym,:minor)
    else
      chord(root.to_sym,:major)
    end
  rescue
    [note(root)]
  end
end

set_param_num :master_amp, 1.0

$pattern_library={
 "kick_four_on_floor"=>->(b,_bar,_g){[0,1,2,3].include?(b)},
 "kick_half"=>->(b,_bar,_g){[0,2].include?(b)},
 "kick_sparse_intro"=>->(b,bar,_g){bar<2 ? b==0 : [0,2].include?(b)},
 "snare_backbeat"=>->(b,_bar,_g){[1,3].include?(b)},
 "snare_half"=>->(b,_bar,_g){b==3},
 "hat_offbeat"=>->(b,_bar,_g){[0.5,1.5,2.5,3.5].include?(b)},
 "lead_every_2beats"=>->(b,_bar,_g){(b % 2).abs<0.001},
 "lead_syncopated"=>->(b,_bar,_g){[0,1.5,2,3.25].include?(b)},
 "bass_on_beats"=>->(b,_bar,_g){b.to_i==b},
 "bass_drive"=>->(b,_bar,_g){[0,1,2.5,3].include?(b)}
}
define :pattern_hit? do |part,lb,bar,gt|
  pid=pattern_of(part); return false unless pid
  fn=$pattern_library[pid]; return false unless fn
  fn.call(lb,bar,gt)
end

live_loop :osc_bpm do
  use_real_time
  v=sync "/osc*/engine/bpm"
  set :bpm,v[0].to_f
  use_bpm get(:bpm)
end
live_loop :osc_energy do
  use_real_time
  v=sync "/osc*/engine/energy"
  set :energy,v[0].to_f
  puts "[OSC] energy=#{get(:energy)}"
end
live_loop :osc_density do
  use_real_time
  v=sync "/osc*/engine/density"
  set :density,v[0].to_f
end
live_loop :osc_chord_prog do
  use_real_time
  v=sync "/osc*/engine/chord_prog"
  set :chord_prog,v[0].to_s.split(",").map(&:strip)
end
live_loop :osc_chord_index do
  use_real_time
  v=sync "/osc*/engine/chord_index"
  set :chord_index,v[0].to_i
end
live_loop :osc_parts do
  use_real_time
  v=sync "/osc*/engine/parts"
  set :active_parts,v[0].to_s.split(",").map(&:strip)
  puts "[OSC] parts=#{get(:active_parts)}"
end
live_loop :osc_lead_seq do
  use_real_time
  v=sync "/osc*/engine/lead_seq"
  set :lead_degrees,v[0].to_s.split(",").map(&:strip)
  set :lead_step,0
end

[:kick,:snare,:bass,:lead,:pad,:hat].each do |p|
  live_loop ("osc_pattern_"+p.to_s).to_sym do
    use_real_time
    v=sync "/osc*/engine/pattern/#{p}"
    set_pattern p, v[0]
  end
end

[:fx_riser,:filter_sweep,:snare,:sub_fade].each do |tg|
  live_loop ("osc_toggle_"+tg.to_s).to_sym do
    use_real_time
    v=sync "/osc*/engine/toggle/#{tg}"
    set_toggle tg, v[0]
  end
end

[:sweep_progress,:sub_fade_level,:pad_cutoff,:master_amp].each do |pn|
  live_loop ("osc_param_"+pn.to_s).to_sym do
    use_real_time
    v=sync "/osc*/engine/param/#{pn}"
    set_param_num pn, v[0]
    puts "[OSC] param #{pn}=#{param_num(pn)}" if pn==:master_amp
  end
end

live_loop :osc_decor_add do
  use_real_time
  v=sync "/osc*/engine/decor/add"
  arr=get(:decor_samples).dup
  path=v[0].to_s
  arr<<path unless arr.include?(path)
  set :decor_samples,arr
end
live_loop :osc_decor_clear do
  use_real_time
  sync "/osc*/engine/decor/clear"
  set :decor_samples,[]
end
live_loop :osc_next_chord do
  use_real_time
  sync "/osc*/engine/next_chord"
  set :chord_index,get(:chord_index)+1
end

live_loop :master_clock do
  use_bpm get(:bpm)
  beat=get(:tick_counter)
  bar=get(:bar_counter)
  cue :beat_tick, beat:beat, bar:bar
  nb=beat+1
  if nb % get(:beats_per_bar)==0
    set :bar_counter,bar+1
  end
  set :tick_counter,nb
  sleep 1
end

live_loop :kick do
  sync :beat_tick
  stop unless get(:active_parts).include?("kick")
  bpb=get(:beats_per_bar)
  beat=get(:tick_counter)-1
  lb=beat % bpb
  bar=get(:bar_counter)
  hit=pattern_hit?("kick",lb,bar,beat)
  hit||=true unless pattern_of("kick")
  if hit
    base = [[0.35,get(:energy)+0.15].max,1.0].min
    sample :bd_tek, amp: base * param_num(:master_amp,1.0)
  end
end

live_loop :snare do
  sync :beat_tick
  parts=get(:active_parts)
  stop unless parts.include?("snare") || toggle?("snare")
  bpb=get(:beats_per_bar)
  beat=get(:tick_counter)-1
  lb=beat % bpb
  bar=get(:bar_counter)
  hit=pattern_hit?("snare",lb,bar,beat)
  hit||=[1,3].include?(lb) unless pattern_of("snare")
  sample :sn_dolf, amp:get(:energy)*0.8 * param_num(:master_amp,1.0) if hit
end

live_loop :bass do
  sync :beat_tick
  stop unless get(:active_parts).include?("bass")
  bpb=get(:beats_per_bar)
  beat=get(:tick_counter)-1
  lb=beat % bpb
  bar=get(:bar_counter)
  hit=pattern_hit?("bass",lb,bar,beat)
  hit||=(lb.to_i==lb) unless pattern_of("bass")
  if hit
    n=note(current_chord_root)-12
    amp_mul=toggle?("sub_fade") ? param_num(:sub_fade_level,1.0) : 1.0
    synth :tb303, note:n, sustain:0.6, release:0.2,
      cutoff:60+get(:energy)*40,
      amp:get(:energy)*0.9*amp_mul * param_num(:master_amp,1.0)
  end
end

live_loop :pad do
  sync :beat_tick
  stop unless get(:active_parts).include?("pad")
  beat=get(:tick_counter)-1
  bpb=get(:beats_per_bar)
  next unless (beat % bpb)==0
  notes=safe_chord_notes(current_chord_root)
  with_fx :reverb, mix:0.35, room:0.7 do
    with_fx :lpf, cutoff:(toggle?("filter_sweep") ? param_num(:pad_cutoff,90) : 120) do
      synth :prophet, notes:notes, sustain:bpb*0.9, release:1,
        amp:(0.3 + get(:energy)*0.7) * param_num(:master_amp,1.0) 
    end
  end
end

live_loop :lead do
  sync :beat_tick
  stop unless get(:active_parts).include?("lead")
  bpb=get(:beats_per_bar)
  beat=get(:tick_counter)-1
  lb=(beat % bpb).to_f
  bar=get(:bar_counter)
  hit=pattern_hit?("lead",lb,bar,beat)
  hit||=(lb % 2 == 0) unless pattern_of("lead")
  if hit && get(:lead_degrees).length>0
    idx=get(:lead_step) % get(:lead_degrees).length
    deg=get(:lead_degrees)[idx].to_i
    set :lead_step,get(:lead_step)+1
    sc=scale(note(current_chord_root),:major,num_octaves:2)
    nt=sc[deg % sc.length]
    with_fx :echo, phase:0.25, mix:0.2 do
      synth :blade, note:nt, sustain:0.3, release:0.2,
        cutoff:90+get(:energy)*40,
        amp:(0.4+get(:energy)*0.6) * param_num(:master_amp,1.0)
    end
  end
end

live_loop :fx_riser do
  sync :beat_tick
  stop unless toggle?("fx_riser")
  bpb=get(:beats_per_bar)
  beat=get(:tick_counter)-1
  if (beat % bpb)==0
    with_fx :slicer, phase:0.25, mix:0.3 do
      synth :noise, sustain:bpb*0.9, release:0.5,
        amp:get(:energy)*0.4 * param_num(:master_amp,1.0),
        cutoff:100+get(:energy)*20
    end
  end
end

live_loop :filter_sweep_ctrl do
  sync :beat_tick
  stop unless toggle?("filter_sweep")
  prog=param_num(:sweep_progress,0.0)
  prog=[[prog,0].max,1].min
  set_param_num :pad_cutoff, 70 + prog*60
end

live_loop :decor_play do
  sync :beat_tick
  arr=get(:decor_samples)
  stop if arr.empty?
  beat=get(:tick_counter)-1
  interval = if get(:density) < 0.4
               8
             elsif get(:density) < 0.6
               4
             else
               2
             end
  if beat % interval == 0
    idx=(beat/interval) % arr.length
    path=arr[idx]
    if File.exists?(path)
      with_fx :reverb, mix:0.35 do
        sample path, amp:(0.6+get(:energy)*0.4) * param_num(:master_amp,1.0)
      end
    else
      puts "WARN missing sample: #{path}"
    end
  end
end

live_loop :osc_debug_any do
  use_real_time
  v = sync "/osc*/engine/debug"
  puts "[DEBUG] #{v.inspect}"
end

puts "Numus-Engine engine ready."