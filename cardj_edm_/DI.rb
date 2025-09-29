# Dawn Ignition 《晨启》
# 清晨出发/通勤 | 渐进House | 20-25min | 车载优化

use_bpm 120
use_debug false

# 数学函数
define :pi_r do |i,mn=0,mx=1|
  s="31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
  d=s[i.abs%s.length].to_i
  mn+(d/9.0)*(mx-mn)
end

define :gold do |t,a=1|
  Math.sin(t*1.618*0.01)*a
end

define :warp do |t,s=1|
  x,y=t*0.1,t*0.05
  [x+Math.sin(x*3)*s,y+Math.cos(y*2)*s]
end

define :wave do |t,m|
  Math.sin(t*0.02)*0.5+Math.cos(t*0.1)*0.3+Math.sin(m*4)*0.2
end

define :layers do |t|
  {mi:t%8,me:(t/8)%32,ma:(t/256)%128,ul:(t/512)%64}
end

define :energy do |p|
  b = 0.4 + (1.0/(1.0+Math.exp(-6*(p-0.2)))) * 0.6
  d = Math.sin(p*Math::PI*8)*0.05
  [[b+d,0.2].max,1.0].min
end

define :harm do |t|
  p=[chord(:c4,:major),chord(:a3,:minor),chord(:f4,:major),chord(:g4,:major)]
  p[((t*0.001618)%1.0*4).floor]
end

define :dens do |e,l|
  d = e*(0.8+Math.sin(l[:mi]*0.5)*0.2)
  {
    k: d > 0.12,
    b: d > 0.10,  
    h: d > 0.15,  
    p: d > 0.20,
    l: d > 0.25,
    f: d > 0.35   
  }
end

# 状态
set :dt,0
set :ce,0.3
set :ch,chord(:c4,:major)
set :mm,[]

# 主控
live_loop :mc do
  t=get(:dt)+1
  set :dt,t
  pr=(t%9600)/9600.0
  e=energy(pr)
  set :ce,e
  l=layers(t)
  set :tl,l
  d=dens(e,l)
  set :ld,d
  if t%32==0
    set :ch,harm(t)
  end
  sleep 0.125
end

# 底鼓
live_loop :k,sync: :mc do
  t,d,e,l = get(:dt),get(:ld),get(:ce),get(:tl)
  main_trigger = d[:k] && (l[:mi]%2==0 || t%4==0)
  backup_trigger = t%8==0 && pi_r(t) > 0.7
  if main_trigger || backup_trigger
    w = warp(t)
    ki = e*(0.8+pi_r(t)*0.4)
    with_fx :compressor,threshold:0.6,slope_above:0.5 do
      with_fx :hpf,cutoff:40 do
        sample :bd_haus,amp:[[ki*1.4,0.05].max,3.0].min,
               rate:1.0+Math.sin(t*0.01618)*0.02,cutoff:75,pan:0
      end
    end
  end
  sleep 0.5
end

# 高帽
live_loop :h,sync: :mc do
  t,d,e,l=get(:dt),get(:ld),get(:ce),get(:tl)
  if d[:h]
    tc = l[:mi]%2==1 || (l[:mi]%4==0 && pi_r(t) > 0.6) 
    to = t%16==0&&pi_r(t)>0.8
    if tc
      w=warp(t,0.5)
      sample :drum_cymbal_closed,rate:1.1+w[0]*0.2, 
             amp:[[0.4+w[1]*0.2,0.05].max,1.5].min,
             pan:[[-0.7+pi_r(t*3)*1.4,-0.95].max,0.95].min,hpf:95
    end
    if to
      sample :drum_cymbal_open,rate:0.9,amp:[[0.2*e,0.05].max,1.5].min,
             pan:[[-0.9+pi_r(t*7)*1.8,-0.95].max,0.95].min,release:2.0
    end
  end
  sleep 0.5
end

# 低音
live_loop :b,sync: :mc do
  t,d,l=get(:dt),get(:ld),get(:tl)
  if d[:b]&&l[:mi]%4==0
    use_synth :tb303
    h=get(:ch)
    n=h[l[:me]%h.size]-24
    e=get(:ce)
    w=warp(t)
    c=[[55+e*35,20].max,125].min
    with_fx :reverb,room:0.4,mix:0.2 do
      with_fx :compressor,threshold:0.4 do
        play n,release:1.5,cutoff:c,res:0.4,
             amp:[[1.2*e,0.01].max,3.0].min,pan:0
      end
    end
  end
  sleep 1
end

# 和弦垫
live_loop :p,sync: :mc do
  t,d,l=get(:dt),get(:ld),get(:tl)
  if d[:p]&&l[:me]%16==0
    use_synth :prophet
    h,e=get(:ch),get(:ce)
    w=wave(t,0)
    with_fx :reverb,room:0.7,mix:0.4+w*0.1 do
      with_fx :slicer,phase:8,smooth:0.8,mix:0.2 do
        play h,attack:1+e*2,release:6+e*3,
             cutoff:[[65+e*25,30].max,125].min,
             amp:[[0.7*e,0.01].max,3.0].min,
             pan:Math.sin(t*0.01)*0.3
      end
    end
  end
  sleep 8
end

# 主旋律
live_loop :l,sync: :mc do
  t,d,l=get(:dt),get(:ld),get(:tl)
  if (d[:l] && l[:me]%8==0) || (d[:p] && l[:me]%4==0 && pi_r(t) > 0.7)
    use_synth :saw
    h,m,e=get(:ch),get(:mm),get(:ce)
    s=scale(h[0],:major_pentatonic,num_octaves:2)
    if m.size>0&&pi_r(t)>0.6
      n=m.choose[:note]+[0,7,-7].choose
    else
      ni = (pi_r(t*3) * s.size).floor % s.size  # 简化warp计算
      n=s[ni]
    end
    if l[:me]%16==0
      nm=m+[{note:n,time:t}]
      nm.shift if nm.size>4
      set :mm,nm
    end
    with_fx :echo,phase:0.375,decay:4,mix:0.2 do
      with_fx :reverb,room:0.5,mix:0.15 do
        play n,attack:0.1,release:1.5+e,
             cutoff:[[85+e*20,40].max,125].min,
             amp:[[0.6*e,0.01].max,2.0].min,
             pan:[[-0.4+pi_r(t*5)*0.8,-0.95].max,0.95].min
      end
    end
  end
  sleep 2
end

# 氛围
live_loop :a,sync: :mc do
  t,d,l=get(:dt),get(:ld),get(:tl)
  if d[:p]&&l[:ul]%4==0
    use_synth :blade
    e=get(:ce)
    s=[scale(:c4,:major_pentatonic),scale(:d4,:dorian),scale(:e4,:mixolydian)]
    cs=s[(l[:ul]/8)%3]
    n=cs.choose
    with_fx :reverb,room:0.85,mix:0.7 do
      play n+[0,12].choose,attack:3,release:10,
           amp:[[0.15*e,0.01].max,2.0].min,
           pan:[[-0.6+pi_r(t*7)*1.2,-0.95].max,0.95].min
    end
  end
  sleep 8  # 保持原有节拍
end

# 打击乐
live_loop :pr,sync: :mc do
  t,d,l=get(:dt),get(:ld),get(:tl)
  if d[:f]&&l[:mi]%8==0&&pi_r(t)>0.8
    sample :perc_bell,rate:0.8+pi_r(t*5)*0.4,
           amp:[[0.08*get(:ce),0.01].max,3.0].min,
           pan:[[-0.8+pi_r(t*11)*1.6,-0.95].max,0.95].min
  end
  sleep 0.5
end

# FX
live_loop :fx,sync: :mc do
  t,d,l=get(:dt),get(:ld),get(:tl)
  if d[:f]&&l[:ul]%16==0
    f=[:ambi_soft_buzz,:ambi_swoosh,:ambi_glass_hum].choose
    e=get(:ce)
    with_fx :reverb,room:0.9,mix:0.6 do
      sample f,rate:0.7+e*0.6,amp:[[0.06*e,0.01].max,3.0].min,
             pan:[[-1.0+pi_r(t*13)*2.0,-0.95].max,0.95].min
    end
  end
  sleep 8
end

# 监控
live_loop :m,sync: :mc do
  t,l=get(:dt),get(:tl)
  if l[:ul]%32==0
    pr=((t%9600)/9600.0*100).round(1)
    e=(get(:ce)*100).round(1)
    puts "🌅#{pr}%|⚡#{e}%|🎵#{l[:ul]}/128|🕐#{(t*0.125/60).round(1)}m"
  end
  sleep 16
end