# Cosmic EDM Evolution v3.0
load("/Users/tsb/Pop-Proj/vootaa-music/edm_music/cee_v3.rb")

s=:edm
use_bpm(s==:edm ? 128 : 120)
set_volume! 0.8
use_debug false
@dc=Hash.new(0)
define :mr do |a=0.0,b=1.0,c=:pi,adv=1|
  d=MD[c]||MD[:pi]; l=[d.length-1,1].max
  i=@dc[c]%l; g=d[i,2]||d[i]; v=g.to_i; sc=(10**g.length)-1
  @dc[c]=(@dc[c]+adv)%l
  a+(v/sc.to_f)*(b-a)
end
define :mp do |list,c=:pi,adv=1|
  arr=list.respond_to?(:to_a) ? list.to_a : Array(list)
  return arr.first if arr.empty?
  arr[mr(0,arr.length,c,adv).to_i%arr.length]
end
define(:lr){|v,min,max| [[v,max].min,min].max}
define :cp do |t,type=:spiral|
  case type
  when :spiral then Math.sin(t*P*0.08)*Math.cos(t*0.05)*0.8
  when :orbit then Math.sin(t*0.12)*0.7
  when :pendulum then Math.sin(t*0.15)*Math.cos(t*0.03)*0.6
  when :galaxy then r=0.6+Math.sin(t*0.02)*0.2; Math.sin(t*0.1)*r
  when :figure8 then Math.sin(t*0.08)*Math.cos(t*0.16)*0.9
  when :wave then Math.sin(t*0.06)*(0.5+Math.sin(t*0.02)*0.3)
  when :random then mr(-0.8,0.8,:sqrt2)
  end
end
define(:pj){|base=0.0,amt=0.1,src=:e|
  lr(base+mr(-amt,amt,src),-1,1)
  }
define :qs do |t,l|
  case l
  when :micro
    b=t*P*0.1
    q=(Math.sin(b)*Math.log(E)+Math.cos(b*2))*0.3
    c=(Math.sin(b*3.14159)+Math.cos(b*1.414))*0.2
    (q+c).abs*0.5+0.3
  when :macro
    ct=t*0.0618
    d=Math.sin(ct*0.73)*0.4; m=Math.cos(ct*0.27+PI/3)*0.3
    (d+m)*0.5+0.5
  when :fusion
    mi=qs(t,:micro)*0.6; ma=qs(t,:macro)*0.4
    [[mi+ma,0.9].min,0.1].max
  end
end
define :eng do |t|
  m=qs(t*0.25,:micro); ma=qs(t*0.125,:macro); f=qs(t*0.0625,:fusion)
  rg=(m>0.55 && (get(:m_old)||0)<m); set :m_old,m
  {m:m,ma:ma,f:f,rg:rg}
end
define(:phs){|t|EP[((t*0.01)%EP.length).to_i]}
define(:cs){|p|CS[p]||CS[:stellar]}
define(:ka){|v|v*(get(:f_amp)||1)}
define(:kt){|v|v*(get(:f_atk)||1)}
define(:kr){|v|v*(get(:f_rel)||1)}
define(:kc){|v|v*(get(:f_cut)||1)}
define :sw? do |t=nil|
  t ||= get(:gt)||0
  r=t%512
  r>=256 && r<272
end
define :sf do
  bd_vt=get(:bd_vt)||-10
  age=vt-bd_vt
  return 1.0 if age>0.15
  0.4+(age/0.15)*0.6
end
define(:fxp){|f| f<0.4 ? [] : (f>0.7 ? S_FX_HI : S_FX)}
T_E=[
  {mod:64,pos:60, fx:->(f,t){sample mp(S_FXT,:golden),amp:f*0.35,rate:lr(0.8+f*0.4,0.5,1.5),pan:cp(t,:wave)}},
  {mod:128,pos:124,fx:->(f,t){sample mp(S_FXT,:pi),amp:f*0.45,rate:lr(0.6+f*0.5,0.4,1.4),pan:cp(t*0.5,:galaxy)}},
  {mod:256,pos:200,fx:->(f,t){sample :ambi_swoosh,amp:f*0.4,rate:lr(0.7+f*0.3,0.5,1.3),pan:cp(t,:orbit)}},
  {mod:256,pos:252,fx:->(f,t){sample :vinyl_backspin,amp:f*0.5,rate:lr(0.8+f*0.2,0.6,1.4),pan:cp(t,:figure8)}}
].freeze
define :tfx do |t,f|
  T_E.each{|ev| ev[:fx].call(f,t) if t%ev[:mod]==ev[:pos]}
end
define :es do |i,nm,role=:auto,e=nil|
  p=note(nm)
  role=(p<48 ? :bass : p<60 ? :arp : p<72 ? :lead : :accent) if role==:auto
  pools={bass:S_SYN4,lead:S_SYN2,arp:S_SYN,accent:S_SYN3,pad:S_SYN5}
  pool=(pools[role]||S_SYN2)
  if role==:lead && defined?($ph)
    ap=PH_LEAD[$ph]||[]
    pool=(pool & ap) unless (pool & ap).empty?
  end
  pool=PH_FILTER[$ph].call(pool) if defined?($ph) && PH_FILTER[$ph]
  idx=(((e||i)+i)*pool.length*0.37).to_i%pool.length
  sc=pool[idx]; use_synth sc
  prof=SC_PROF[sc]||{}
  set :f_amp,prof[:amp]||1
  set :f_atk,prof[:atk]||1
  set :f_rel,prof[:rel]||1
  set :f_cut,prof[:cut]||1
  sc
end
define :plr do |ch,amp,cut,pan,ma,ml|
  a=ch.to_a.map{|x|note(x)}.sort; return if a.empty?
  r=a.first; rs=a.drop(1); x=rs.length>2 ? [rs.pop] : []; md=rs
  b=6+ma*3; as=sf
  ar=ka(amp*0.55); am=ka(amp); ax=ka(amp*0.35)
  tr=kt(1.5*(ml ? 0.7 : 1)*as); tm=kt(1.5*sf); tx=kt(0.25*as)
  rr=kr(b*1.1); rm=kr(b); rx=kr(b*0.4)
  cr=lr(kc(cut-12),20,130); cm=lr(kc(cut),20,130); cx=lr(kc(cut+18),20,130)
  play r-12,amp:ar,attack:tr,release:rr,cutoff:cr,pan:pan*0.6
  md.each{|n| play n,amp:am,attack:tm,release:rm,cutoff:cm,pan:pan}
  x.each{|n| play n+12,amp:ax,attack:tx,release:rx,cutoff:cx,pan:pj(pan+0.15,0.15)}
end
define :pl do |k,t,i,pn|
  case k
  when :harmonic
    return unless t%3==0 && i>0.4
    n=pn[t%pn.length]+12
    ln=get(:lead_note); n+=5 if ln && note(ln)==note(n)
    es(i,n,:accent,i)
    play n,amp:ka(i*0.3),mod_range:lr(i*12,0,24),mod_rate:lr(i*8,0.1,16),
      attack:kt(0.1),release:kr(1.5),pan:pj(cp(t,:figure8))
  when :tremolo
    return unless spread(7,32)[t%32]
    n=mp(pn,:e)+mp([0,7],:golden)
    es(i,n,:arp,i)
    with_fx :tremolo,phase:lr(i*2,0.1,4),mix:lr(i*0.8,0,1) do
      play n,amp:ka(i*0.4),cutoff:lr(kc(60+i*40),20,130),release:kr(0.8),
        pan:pj(cp(t,:wave))
    end
  when :particle
    ml=get(:mute_lead)
    tl=ml ? 0.68 : 0.72; th=ml ? 0.92 : 0.90
    return unless i>tl && i<th
    n=mp(pn,:golden)+mp([12,24,36],:e)
    es(i,n,:accent,i)
    with_fx :reverb,room:0.4,mix:0.3 do
      play n,amp:ka(i*0.2),attack:kt(0.05),release:kr(0.3),
        cutoff:lr(kc(80+i*30),50,130),
        pan:pj(cp(t+mr(0,16,:pi),mp(S_PAN2,:golden)))
    end
  end
end
live_loop :cg do
  t=tick; set :gt,t
  e=eng(t); m=e[:m]; ma=e[:ma]; f=e[:f]; rg=e[:rg]
  ml=sw?(t); set :mute_lead,ml
  ph=phs(t); $ph=ph; pn=cs(ph)
  da= ma>0.65 ? 2 : ma<0.35 ? 0.85 : 1
  if t%4==0
    sample :bd_haus,amp:m,lpf:lr(80+ma*40,20,130),pan:cp(t,:pendulum)*0.3
    set :bd_vt,vt
  end
  sample :sn_dub,amp:ma*0.8,pan:cp(t,:orbit),hpf:lr(20+m*80,0,118) if [6,14].include?(t%16)
  if f>=0.4 && !ml
    pool=fxp(f)
    trig=(f>0.7 ? spread(3,16) : spread(5,16))[t%16]
    if trig&&!pool.empty?
      with_fx(:reverb,room:0.22,mix:0.22) do
        sample mp(pool,:pi),
          amp:f*0.38*sf,
          rate:lr(0.8+m*0.4,0.25,4.0),
          pan:cp(t+mr(0,8,:golden),:spiral)
      end
    end
  end
  sample :drum_cymbal_closed,amp:0.18*sf,pan:cp(t,:random) if s==:edm
  if t%2==0 && m>0.5 && !ml
    bi=((t*f*5)+(m*8)).to_i%pn.length
    if t%64<8
      off=MOTIF[(t/2)%MOTIF.length]; bi=(bi+off)%pn.length
    end
    tn=pn[bi]
    es(m,tn,:lead,f); set :lead_note,tn; set :lead_last,t
    l=play tn,amp:ka(m*0.7*da*sf*(ma>=0.75 ? 0.9 : 1)),
      cutoff:lr(kc(40+ma*80),0,130),
      attack:kt(lr((1-m)*0.25,0,2)),
      release:kr(lr(0.25+f*0.5,0.2,6)),
      note_slide:0.05,
      pan:cp(t,:galaxy)
    if rg
      control l,note:note(tn)+2
      at(vt+0.05){control l,note:note(tn)}
    end
  end
  pl(:harmonic,t,f,pn) if t%2==0
  pl(:tremolo,t,ma,pn) if t%4==0
  if t%32==0
    in_thread do
      3.times do |i|
        rn=pn[i%pn.length]
        es(f,rn,:pad,f)
        lc=((get(:lead_last)||-99)>t-2)
        pamp=f*0.2*da*(lc ? 0.7 : 1); pamp*=1.15 if ml
        cb = f<0.5 ? lr(50+m*20,20,110) : lr(80+m*30,40,130)
        with_fx(:compressor,threshold:0.35,clamp_time:0.01,relax_time:0.15) do
          ch=chord(rn,mp(S_CHD,:golden))
          plr ch,pamp,cb,cp(t+i*16,mp(S_PAN,:pi)),ma,ml
        end
        sleep 8
      end
    end
  end
  if t%8==0 && f>0.6
    bc=(get(:bass_cnt)||0)+1; set :bass_cnt,bc
    base=note(pn[0])-24
    jump=(bc%4==0 && ma>=0.4)
    passing=(!jump && bc%8==4) ? base+7 : nil
    n=passing || (jump ? base+12 : base)
    es(ma,n,:bass,f)
    b=synth get(:sc),
      note:n,
      amp:ka(ma*0.58*da*sf),
      attack:kt(0.09*sf),
      sustain:(jump ? 1.0 : 1.4),
      release:0,
      note_slide:0.25,
      cutoff:lr(kc(60+m*20),20,130),
      pan:cp(t,:pendulum)*0.4
    control b,note:base if jump
    at(vt+0.18){control b,note:base} if passing
  end
  tfx(t,f)
  sleep 0.25
end
live_loop :ct, sync: :cg do
  t=tick
  f=qs(t*0.0625,:fusion)
  ph=phs(t*2); pn=cs(ph)
  pl(:particle,t*2,qs(t*0.125,:micro),pn) if t%2==0
  if t%32==0
    si=qs(t*0.015625,:fusion)
    if si>0.6
      use_synth mp(S_AMB,:golden)
      roots=pn.take(3).map{|n|n-12}
      with_fx :reverb,room:(s==:deep_house ? 0.85 : 0.65),mix:0.5 do
        with_fx :lpf,cutoff:lr(70+si*30,40,120) do
          play roots,amp:si*0.25*sf,attack:2,release:6,pan:cp(t*8,:wave)*0.7
        end
      end
    end
  end
  sample :loop_compus,amp:0.3,beat_stretch:4 if s==:deep_house && t%4==0
  if t%16==0 && f>0.5 && !sw?
    with_fx(:reverb,room:0.85,mix:0.5){
      sample mp(S_FX2,:e),
        amp:f*0.3,
        rate:lr(0.5+f*0.5,0.25,2.0),
        pan:cp(t*4,:random)
    }
  end
  sleep 2
end
live_loop :cm, sync: :cg do
  t=tick
  ph=phs(t*4); pn=cs(ph)
  if t%8==0
    use_synth :dark_ambience
    ai=qs(t*0.125,:fusion)
    with_fx(:lpf,cutoff:(sw? ? 70 : lr(40+ai*20,20,130))) do
      play pn.map{|n|note(n)-36}.take(3),
        amp:ai*0.15,attack:8,release:16,
        pan:cp(t*4,:galaxy)*0.6
    end
  end
  if t%20==0 && t>0
    use_synth :prophet
    with_fx :reverb,room:0.8,mix:0.6 do
      with_fx :echo,phase:0.375,decay:2 do
        pn.each_with_index do |nv,i|
          at i*0.2 do
            play nv+12,amp:0.3,attack:0.5,release:2,cutoff:90,pan:cp(t*4+i*4,:spiral)
          end
        end
      end
    end
  end
  if t%16==0 && t>0
    ge=qs(t*0.0625,:macro)
    puts "#{ph.to_s.upcase} | 演化度: #{(ge*100).to_i}%"
  end
  sleep 4
end

puts "=== Cosmic EDM Evolution v3.0 启动 ==="
puts "7种立体声轨道 | 25音色 | 宇宙谐波音阶"
puts "COSMIC演化引擎运行中 | 风格:#{s.to_s.upcase}"