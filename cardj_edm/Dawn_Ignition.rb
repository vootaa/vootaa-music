load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"
use_debug false

def clamp(v,min,max); [min,[v,max].min].max; end
def gf(t)
  if t < S_DI[:intro]
    b = VB_DI + (t / S_DI[:intro]) * 0.4
    br = Math.sin(t * PI * P / 8) * 0.06
    clamp(b + br, 0, 0.65)
  elsif t < S_DI[:intro] + S_DI[:drive]
    dt = t - S_DI[:intro]; dp = dt / S_DI[:drive]
    b = 0.65 + (E**(dp*1.8)-1)/(E**1.8-1) * 0.35
    clamp(b, 0.65, 1.0)
  elsif t < S_DI[:intro] + S_DI[:drive] + S_DI[:peak]
    pt = t - S_DI[:intro] - S_DI[:drive]
    mv = Math.sin(pt * PI * 1.5) * 0.04
    clamp(1.0 + mv, 0.96, 1.0)
  else
    ot = t - (S_DI[:intro] + S_DI[:drive] + S_DI[:peak])
    df = 1.0 - (ot / S_DI[:outro])**1.8
    clamp(df, 0, 1.0)
  end
end
def gms(c,l); MD[c.to_sym].chars.map(&:to_i).take(l).map{|d| d/10.0}; end
def gcm(s1,s2,l); (0...l).map{|i| v1=s1[i%s1.length]; v2=s2[i%s2.length]; (v1*P+v2)/(P+1)}; end
def gcp(t,vi)
  ci = ($ks[(t.to_i/4)%$ks.length]*4).to_i % BC_DI.length
  bn,bt = BC_DI[ci]
  if vi>=2 && $hs[t.to_i%$hs.length]>0.6
    ei = ($ms[t.to_i%$ms.length]*4).to_i % CE_DI.length
    return [bn, CE_DI[ei]]
  end
  [bn,bt]
end

$ks=gms("golden",100); $bs=gms("pi",100); $ms=gms("e",200); $es=gms("sqrt2",150)
$hs=gcm($ks,$ms,100); $rs=gcm($bs,$es,100); $ss=gcm($ms,$bs,50)

vi=0; dr=0; mm=[]; em=0.5
esubs=[]; ssz=[3,(EP_DI.length.to_f/VC_DI).ceil].max
VC_DI.times{|i| st=i*(ssz-1); sb=[]; ssz.times{|j| idx=(st+j)%EP_DI.length; sb<<EP_DI[idx]}; esubs<<sb}
$vsb=0

live_loop :kick do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr+em*0.1
  to=($bs[t.to_i%$bs.length]-0.5)*0.015
  a=clamp(f*0.75,0.08,1.0)
  bp=LP_DI.call(t)+VP_DI*f; sm=($ss[(t.to_i/2)%$ss.length]-0.5)*0.18
  p=S_PAN.call(bp+sm)
  sample :bd_haus,amp:a,pan:p
  sleep (1.0/(BPM_DI/60.0))+to
end

live_loop :bass do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  a=clamp(f*0.55,0.04,0.75); p=($ss[t.to_i%$ss.length]-0.5)*0.15
  ni=($bs[t.to_i%$bs.length]*7).to_i%7; rn=scale(:c2,:minor_pentatonic)[ni%5]
  synth :saw,note:rn,amp:a,pan:p,release:0.45,cutoff:55+f*38
  if f>0.35
    synth :sine,note:rn-12,amp:a*0.25,pan:0,release:0.9
  end
  sleep 2.0/(BPM_DI/60.0)
end

live_loop :melody do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  a=clamp(f*0.65,0.08,0.85); bp=S_PAN.call(HP_DI+LP_DI.call(t)*0.18)
  cn,ct=gcp(t,vi); mi=($ms[t.to_i%$ms.length]*7).to_i%7; nt=scale(:c4,:major)[mi]
  mm<<nt if mm.length<8
  synth :piano,note:nt,amp:a,pan:bp,release:0.9
  if f>0.45
    ha=a*0.45; hp=S_PAN.call(bp+0.08)
    if vi<2
      synth :saw,note:chord(cn,ct),amp:ha,pan:hp,release:1.3
    else
      synth :saw,note:chord(cn,ct),amp:ha,pan:hp,release:1.3
      if mm.length>2 && $hs[t.to_i%$hs.length]>0.68
        mn=mm[(vi*t.to_i)%mm.length]
        synth :piano,note:mn+12,amp:ha*0.55,pan:-bp,release:1.8
      end
    end
    if f>0.75 && vi>=3
      synth :piano,note:chord(cn,:major7),amp:a*0.25,pan:S_PAN.call(bp-0.08),release:1.8
    end
  end
  sleep 4.0/(BPM_DI/60.0)
end

live_loop :perc do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  a=clamp(f*0.45,0.04,0.65)
  base_pan = LP_DI.call(t)*0.6
  p = S_PAN.call(base_pan)
  pattern_idx = (vi + (t.to_i/8)) % PD_DI.length
  beat_pos = (t*2).to_i % 8
  base_intensity = PD_DI[pattern_idx][beat_pos]
  if base_intensity > 0 && f > 0.25
    rand_val = $ks[t.to_i % $ks.length]
    accent_threshold = 0.6 + vi * 0.05
    is_accent = rand_val > accent_threshold
    if is_accent
      accent_amp = a * base_intensity * 1.5
      sample :sn_dub, amp: clamp(accent_amp, 0, 1.0), pan: p
      if vi >= 1
        sample :bd_tek, amp: clamp(accent_amp * 0.3, 0, 0.5), pan: p * 0.5
      end
    else
      weak_amp = a * base_intensity * 0.7
      sample :sn_dub, amp: weak_amp, pan: p
    end
    ghost_chance = $bs[(t*1.618).to_i % $bs.length]
    if ghost_chance > 0.75 && vi >= 2
      ghost_amp = a * 0.15
      sample :perc_snap, amp: ghost_amp, pan: p * -0.5
    end
  end
  if vi >= 2 && f > 0.55
    bell_pattern_idx = vi % BD_DI.length
    bell_intensity = BD_DI[bell_pattern_idx][beat_pos]    
    if bell_intensity > 0.1
      bell_rand = ($bs[(t*1.314).to_i % $bs.length] - 0.5) * 0.3
      final_bell_intensity = clamp(bell_intensity + bell_rand, 0, 0.8)
      
      if final_bell_intensity > 0.15
        bell_pan = clamp(base_pan + 0.3, -0.8, 0.8)
        sample :perc_bell, amp: a * final_bell_intensity * 0.5, pan: S_PAN.call(bell_pan)
      end
    end
  end
  sleep 0.5/(BPM_DI/60.0)
end

live_loop :fx do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  a=clamp(f*0.35,0.015,0.55)
  st=t*0.08; pm=Math.sin(st*PI)*Math.cos(st*P)*0.7
  p=S_PAN.call(HP_DI+pm*f)
  rs=0.75+vi*0.04; dt=1.8+f*1.8+dr*8
  with_fx :reverb,room:rs,decay:dt do
    with_fx :echo,phase:0.22+($ss[t.to_i%$ss.length]*0.08),decay:0.45 do
      case vi%3
      when 0; synth :noise,amp:a,pan:p,release:1.8
      when 1; synth :bnoise,amp:a*0.75,pan:p,release:1.3
      when 2; synth :gnoise,amp:a*1.1,pan:p,release:2.2
      end
    end
  end
  sleep 7.0/(BPM_DI/60.0)
end

live_loop :events do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  bt=BPM_DI>130 ? 0.55 : 0.65; vm=vi*0.04; th=bt-vm
  if f>th && esubs[vi]
    ei_idx=(t.to_i/14)%esubs[vi].length; ev=esubs[vi][ei_idx]; ei_val=0.45+vi*0.08+f*0.35
    case ev
    when :bd_haus; po=($es[t.to_i%$es.length]-0.5)*0.9; sample :bd_haus,amp:clamp(ei_val*0.55,0.08,1.0),pan:S_PAN.call(po)
    when :sn_dub; po=($es[t.to_i%$es.length]-0.5)*0.9; sample :sn_dub,amp:clamp(ei_val*0.45,0.08,1.0),pan:S_PAN.call(po)
    when :synth_piano; cn,ct=gcp(t,vi); synth :piano,note:cn,amp:clamp(ei_val*0.65,0.08,1.0),pan:S_PAN.call(HP_DI)
    when :fx_reverb; with_fx :reverb,room:0.85+vi*0.015 do synth :saw,note:note(:e4)+vi,amp:clamp(ei_val*0.35,0.08,1.0),release:0.9+vi*0.15 end
    when :synth_pad; cn,ct=gcp(t,vi); synth :prophet,note:chord(cn,ct),amp:clamp(ei_val*0.4,0.05,0.7),pan:S_PAN.call(HP_DI*0.5),release:2.5+vi*0.3
    when :perc_bell; po=S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.7); sample :perc_bell,amp:clamp(ei_val*0.4,0.05,0.8),pan:po
    when :fx_echo; with_fx :echo,phase:0.375+($ss[t.to_i%$ss.length]*0.125),decay:0.6 do synth :pluck,note:scale(:c5,:major_pentatonic)[($ms[t.to_i%$ms.length]*5).to_i%5],amp:clamp(ei_val*0.45,0.05,0.75),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.8),release:1.2 end
    when :amen_fill; ai=(vi+t.to_i)%AP.length; rm=1.0+(vi*0.04)+($rs[t.to_i%$rs.length]-0.5)*0.08; pp=S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.7); sample AP[ai],amp:clamp(ei_val*0.5,0.08,1.0),pan:pp,rate:rm
    end
  end
  sleep 14.0/(BPM_DI/60.0)
end

live_loop :vctrl do
  puts "Dawn variant #{vi+1}/#{VC_DI}" if DEBUG
  $vsb=current_beat
  pns=case vi
  when 0; [:c4,:e4,:g4,:c5]
  when 1; [:c4,:e4,:g4,:b4,:c5]
  when 2; [:c4,:d4,:f4,:g4,:a4,:c5]
  else; mm.length>0 ? mm.take(4) : [:c4,:e4,:g4,:c5]
  end
  pns.each_with_index{|n,i| fa=(i+1)/pns.length.to_f*0.35; pa=(i*PI/2)+(vi*PI/4); p=S_PAN.call(Math.sin(pa)*0.65); synth :piano,note:n,amp:fa,release:0.35,pan:p; synth :saw,note:n+7,amp:fa*0.25,release:0.55,pan:-p if vi>=2; sleep 0.22}
  sleep 0.45; sleep S_DI.values.sum
  em=clamp(em+0.12-vi*0.015,0.25,1.0); sleep 1.8
  vi+=1; dr+=0.015*(vi+1); stop if vi>=VC_DI
end