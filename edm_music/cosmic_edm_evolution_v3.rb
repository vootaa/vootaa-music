# Cosmic EDM Evolution v3.0

load("/Users/tsb/Pop-Proj/vootaa-music/edm_music/cee_v3.rb")

s=:edm
bpm=s==:edm ? 128 :120
use_bpm bpm
set_volume! 0.8
use_debug false
@dc=Hash.new(0)
define :mr do |a=0.0,b=1.0,c=:pi,adv=1|
  d=MD[c] || MD[:pi]
  l=[d.length-1,1].max
  i=@dc[c]%l
  s=d[i,2] || d[i]
  v=s.to_i
  sc=(10**s.length)-1
  @dc[c]=(@dc[c]+adv)%l
  a+(v/sc.to_f)*(b-a)
end
define :mp do |list,c=:pi,adv=1|
  arr=list.respond_to?(:to_a) ? list.to_a : Array(list)
  return arr.first if arr.empty?
  arr[mr(0,arr.length,c,adv).to_i%arr.length]
end
define :cp do |t,type=:spiral|
  case type
  when :spiral
    Math.sin(t*P*0.08)*Math.cos(t*0.05)*0.8
  when :orbit
    Math.sin(t*0.12)*0.7
  when :pendulum
    Math.sin(t*0.15)*Math.cos(t*0.03)*0.6
  when :galaxy
    r=0.6+Math.sin(t*0.02)*0.2
    Math.sin(t*0.1)*r
  when :figure8
    Math.sin(t*0.08)*Math.cos(t*0.16)*0.9
  when :wave
    Math.sin(t*0.06)*(0.5+Math.sin(t*0.02)*0.3)
  when :random
    mr(-0.8,0.8,:sqrt2)
  end
end
define :qs do |t,l|
  case l
  when :micro
    b=t*P*0.1
    q=(Math.sin(b)*Math.log(E)+Math.cos(b*2))*0.3
    c=(Math.sin(b*3.14159)+Math.cos(b*1.414))*0.2
    (q+c).abs*0.5+0.3
  when :macro
    ct=t*0.0618
    d=Math.sin(ct*0.73)*0.4
    m=Math.cos(ct*0.27+PI/3)*0.3
    (d+m)*0.5+0.5
  when :fusion
    mi=qs(t,:micro)*0.6
    ma=qs(t,:macro)*0.4
    [[mi+ma,0.9].min,0.1].max
  end
end
define :lr do |v,min,max|
  [[v,max].min,min].max
end
define :phase do |t|
  EP[((t*0.01)%EP.length).to_i]
end
define :cs do |p|
  CS[p] || CS[:stellar]
end
define(:ka){|v|v*(get(:f_amp)||1)};define(:kt){|v|v*(get(:f_atk)||1)};define(:kr){|v|v*(get(:f_rel)||1)};define(:kc){|v|v*(get(:f_cut)||1)}
define :pl do |kind,t,i,pn|
  case kind
  when :harmonic
    return unless t%3==0 && i>0.4
    n=pn[t%pn.length]+12
    ln=get(:lead_note); n+=5 if ln && note(ln)==note(n)
    es(i,n,:accent,i)
    play n,amp:ka(i*0.3),mod_range:lr(i*12,0,24),mod_rate:lr(i*8,0.1,16),
         attack:kt(0.1),release:kr(1.5),pan:cp(t,:figure8)+mr(-0.1,0.1,:e)
  when :tremolo
    return unless spread(7,32)[t%32]
    n=mp(pn,:e)+mp([0,7],:golden)
    es(i,n,:arp,i)
    with_fx :tremolo,phase:lr(i*2,0.1,4),mix:lr(i*0.8,0,1) do
      play n,amp:ka(i*0.4),cutoff:lr(kc(60+i*40),20,130),release:kr(0.8),
           pan:cp(t,:wave)+mr(-0.1,0.1,:e)
    end
  when :particle
    ml=get(:mute_lead)
    return unless i>(ml ? 0.68 :0.72) && i<(ml ? 0.92 :0.9)
    n=mp(pn,:golden)+mp([12,24,36],:e)
    es(i,n,:accent,i)
    with_fx :reverb,room:0.4,mix:0.3 do
      play n,amp:ka(i*0.2),attack:kt(0.05),release:kr(0.3),
           cutoff:lr(kc(80+i*30),50,130),
           pan:cp(t+mr(0,16,:pi),mp(S_PAN2,:golden))+mr(-0.1,0.1,:e)
    end
  end
end
define :es do |i,nm,role=:auto,e=nil|
  e||=i; p=note(nm)
  role=(p<48 ? :bass : p<60 ? :arp : p<72 ? :lead : :accent) if role==:auto
  pools={bass:S_SYN4,lead:S_SYN2,arp:S_SYN,accent:S_SYN3,pad:S_SYN5}
  pool=pools[role]||S_SYN2
  if role==:lead && defined?($ph)
    ap=PH_LEAD[$ph]||[]
    fp=pool & ap
    pool=fp unless fp.empty?
  end
  idx=((i*pool.length)+((e||i)*0.37*pool.length)).to_i%pool.length
  sc=pool[idx]; use_synth sc; set :sc,sc; $last_sc=sc
  pr=SC_PROF[sc]||{}
  set :f_amp,pr[:amp]||1; set :f_atk,pr[:atk]||1; set :f_rel,pr[:rel]||1; set :f_cut,pr[:cut]||1
  sc
end
define :pad_layers do |ch,amp,cut,pan,ma,ml|
  arr=ch.to_a.map{|x|note(x)}.sort
  return if arr.empty?
  root=arr.first
  rest=arr.drop(1)
  ext=rest.length>2 ? [rest.pop] : []
  mid=rest
  rb=6+ma*3
  adj_root=ka(amp*0.55); adj_mid=ka(amp); adj_ext=ka(amp*0.35)
  atk_root=kt(1.5*(ml ? 0.7 : 1)); atk_mid=kt(1.5); atk_ext=kt(0.2)
  rel_root=kr(rb*1.1); rel_mid=kr(rb); rel_ext=kr(rb*0.4)
  cut_root=lr(kc(cut-10),20,130); cut_mid=lr(kc(cut),20,130); cut_ext=lr(kc(cut+15),20,130)
  nr=root-12
  play nr,amp:adj_root,attack:atk_root,release:rel_root,cutoff:cut_root,pan:pan*0.6
  mid.each{|n|play n,amp:adj_mid,attack:atk_mid,release:rel_mid,cutoff:cut_mid,pan:pan}
  ext.each{|n|play n+12,amp:adj_ext,attack:atk_ext,release:rel_ext,cutoff:cut_ext,pan:pan+mr(-0.15,0.15,:e)}
end

live_loop :cg do
  t=tick
  m=qs(t*0.25,:micro); ma=qs(t*0.125,:macro); f=qs(t*0.0625,:fusion)
  ml=(t%256>=120 && t%256<128); set :mute_lead,ml; set :gt,t
  ph=phase(t); $ph=ph
  pn=cs(ph)
  prev_m=get(:m_old)||m; set :m_old,m
  sample :bd_haus,amp:m,rate:lr(1+(m-0.5)*0.1,0.5,2.0),
         lpf:lr(80+ma*40,20,130),pan:cp(t,:pendulum)*0.3 if t%4==0
  set :bd_last,t if t%4==0
  if [6,14].include?(t%16)
    sample :sn_dub,amp:ma*0.8,pan:cp(t,:orbit),hpf:lr(20+m*80,0,118)
  end
  if ma>=0.35 && f>0.4 && spread(5,16)[t%16]
    with_fx(:reverb,room:0.25,mix:0.25){sample mp(f>0.7 ? [:perc_bell,:elec_tick,:elec_ping] : S_FX,:pi),
      amp:f*0.4,rate:lr(0.8+m*0.4,0.25,4.0),pan:cp(t+mr(0,8,:golden),:spiral)}
    sample :elec_tick,amp:0.25*ma,pan:cp(t*1.3,:random) if ma>=0.65 && (t*7)%5==0
  end
  if s==:edm
    sample :drum_cymbal_closed,amp:0.2,pan:cp(t,:random)
    da=t%64 < 4 ? 2 :1
  else
    da=1
  end
  if t%2==0 && m>0.5 && !ml
    ni=((t*f*5)+(m*8)).to_i%pn.length
    tn=pn[ni]; rising=(m>0.55 && prev_m<m)
    es(m,tn,:lead,f); set :lead_note,tn; set :lead_last,t
    with_fx :distortion,distort:0.1 do
      with_fx :pitch_shift,pitch:(rising ? 0.3 :0) do
        play tn,amp:ka((m*0.7*da)*(ma>=0.75 ? 0.9 :1)),cutoff:lr(kc(40+ma*80),0,130),
             res:lr(f*0.8,0,1),attack:kt(lr((1-m)*0.3,0,4)),
             release:kr(lr(0.2+f*0.5,0.1,8)),pan:cp(t,:galaxy)
      end
    end
  end
  pl(:harmonic,t,f,pn) if t%2==0
  pl(:tremolo,t,ma,pn) if t%4==0
  if t%32==0
    in_thread do
      3.times do |i|
        es(f,pn[i%pn.length],:pad,f)
        lead_recent=((get(:lead_last)||-99)>t-2)
        bd_recent=((get(:bd_last)||-99)>t-2)
        pad_amp=f*0.2*da*(lead_recent ? 0.7 :1)
        pad_amp*=1.15 if ml
        cut_base=f<0.5 ? lr(50+m*20,20,110) : lr(80+m*30,40,130)
        with_fx(:compressor,threshold:0.3,clamp_time:0.01,relax_time:0.15) do
          ch=chord(pn[i%pn.length],mp(S_CHD,:golden))
          pad_amp=f*0.2*da*(lead_recent ? 0.7 :1); pad_amp*=1.15 if ml
          pad_layers ch,pad_amp,cut_base,cp(t+i*16,mp(S_PAN,:pi)),ma,ml
        end
        sleep 8
      end
    end
  end
  if t%8==0 && f>0.6
    bc=(get(:bass_cnt)||0)+1; set :bass_cnt,bc
    base=note(pn[0])-24
    jump=(bc%4==0 && ma>=0.4); n=base+(jump ? 12 :0)
    sc=es(ma,n,:bass,f)
    bn=synth sc,
      note:n,amp:ka(ma*0.6*da),attack:kt(0.1),
      sustain:(jump ? 1.0 :1.6),release:0,
      note_slide:0.25,cutoff:lr(kc(60+m*20),20,130),
      pan:cp(t,:pendulum)*0.4
    control bn,note:base if jump
  end
  if t%64==60
    sample mp(S_FX_TRANS,:golden),amp:f*0.35,rate:lr(0.8+f*0.4,0.5,1.5),pan:cp(t,:wave)
  end
  if t%128==124
    sample mp(S_FX_TRANS,:pi),amp:f*0.45,rate:lr(0.6+f*0.5,0.4,1.4),pan:cp(t*0.5,:galaxy)
  end
  if t%256==200
    sample :ambi_swoosh,amp:f*0.4,rate:lr(0.7+f*0.3,0.5,1.3),pan:cp(t,:orbit)
  end
  if t%256==252
    sample :vinyl_backspin,amp:f*0.5,rate:lr(0.8+f*0.2,0.6,1.4),pan:cp(t,:figure8)
  end
  sleep 0.25
end

live_loop :ct,sync::cg do
  t=tick
  f=qs(t*0.0625,:fusion)
  ph=phase(t*2); pn=cs(ph)
  pl(:particle,t*2,qs(t*0.125,:micro),pn) if t%2==0
  if t%32==0
    si=qs(t*0.015625,:fusion)
    if si>0.6
      use_synth mp(S_AMB,:golden)
      sc=pn.take(3).map { |n| n-12 }
      with_fx :reverb,room:s==:deep_house ? 0.8 :0.6,mix:0.5 do
        with_fx :lpf,cutoff:lr(70+si*30,40,120) do
          play sc,amp:si*0.25,attack:2,release:6,pan:cp(t*8,:wave)*0.7
        end
      end
    end
  end
  sample :loop_compus,amp:0.3,beat_stretch:4 if s==:deep_house && t%4==0
  if t%16==0 && f>0.5 && ((get(:gt)||0)%256>16)
    with_fx(:reverb,room:0.8,mix:0.5){sample mp(S_FX2,:e),
      amp:f*0.3,rate:lr(0.5+f*0.5,0.25,2.0),pan:cp(t*4,:random)}
  end
  sleep 2
end

live_loop :cm,sync::cg do
  t=tick
  ph=phase(t*4)
  pn=cs(ph)
  if t%8==0
    use_synth :dark_ambience
    ai=qs(t*0.125,:fusion)
    play pn.map { |n| note(n)-36 }.take(3),
         amp:ai*0.15,attack:8,release:16,
         cutoff:lr(40+ai*20,20,130),
         pan:cp(t*4,:galaxy)*0.6
  end
  if t%20==0 && t>0
    use_synth :prophet
    with_fx :reverb,room:0.8,mix:0.6 do
      with_fx :echo,phase:0.375,decay:2 do
        pn.each_with_index do |nv,i|
          at i*0.2 do
            play nv+12,amp:0.3,attack:0.5,release:2,cutoff:90,
                 pan:cp(t*4+i*4,:spiral)
          end
        end
      end
    end
    puts "相位提示:#{ph.to_s.upcase}"
  end
  if t%16==0 && t>0
    ge=qs(t*0.0625,:macro)
    puts "#{ph.to_s.upcase} | 演化度:#{(ge*100).to_i}%"
  end
  sleep 4
end

puts "=== Cosmic EDM Evolution v3.0 启动 ==="
puts "7种立体声轨道 | 25音色 | 宇宙谐波音阶"
puts "COSMIC演化引擎运行中 | 风格:#{s.to_s.upcase}"