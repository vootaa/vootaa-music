load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"
use_debug false

def clamp(v,min,max); [min,[v,max].min].max; end
def gf(t)
  if t < S_DI[:intro]
    b = VB_DI+(t/S_DI[:intro])*0.4
    br = Math.sin(t*PI*P/8)*0.06
    clamp(b+br, 0, 0.65)
  elsif t < S_DI[:intro]+S_DI[:drive]
    dt = t-S_DI[:intro]; dp = dt/S_DI[:drive]
    b = 0.65+(E**(dp*1.8)-1)/(E**1.8-1)*0.35
    clamp(b, 0.65, 1.0)
  elsif t < S_DI[:intro]+S_DI[:drive]+S_DI[:peak]
    pt = t-S_DI[:intro]-S_DI[:drive]
    mv = Math.sin(pt*PI*1.5)*0.04
    clamp(1.0+mv, 0.96, 1.0)
  else
    ot = t-(S_DI[:intro]+S_DI[:drive]+S_DI[:peak])
    df = 1.0-(ot/S_DI[:outro])**1.8
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
def al(t,f,vi); ls=[:kick]; ls<<:bass if f>0.3; ls<<:melody if f>0.45&&(t.to_i%12)<8; ls<<:perc if f>0.4&&vi>=1; ls<<:fx if f>0.6&&(t.to_i%16)<10; ls; end

$ks=gms("golden",100); $bs=gms("pi",100); $ms=gms("e",200); $es=gms("sqrt2",150)
$hs=gcm($ks,$ms,100); $rs=gcm($bs,$es,100); $ss=gcm($ms,$bs,50)

vi=0; dr=0; mm=[]; em=0.5
esubs=[]; ssz=[3,(EP_DI.length.to_f/VC_DI).ceil].max
VC_DI.times{|i| st=i*(ssz-1); sb=[]; ssz.times{|j| idx=(st+j)%EP_DI.length; sb<<EP_DI[idx]}; esubs<<sb}
$vsb=0

live_loop :kick do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr+em*0.1
  to=($bs[t.to_i%$bs.length]-0.5)*0.012
  a=clamp(f*0.7,0.06,0.9); bp=LP_DI.call(t)+VP_DI*f; sm=($ss[(t.to_i/2)%$ss.length]-0.5)*0.15
  p=S_PAN.call(bp+sm); sample :bd_haus,amp:a,pan:p
  sleep (1.2/(BPM_DI/60.0))+to
end

live_loop :bass do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  if al(t,f,vi).include?(:bass)
    a=clamp(f*0.5,0.03,0.65); p=($ss[t.to_i%$ss.length]-0.5)*0.12
    ni=($bs[t.to_i%$bs.length]*7).to_i%7; rn=scale(:c2,:minor_pentatonic)[ni%5]
    synth :saw,note:rn,amp:a,pan:p,release:0.4,cutoff:52+f*35
    synth :sine,note:rn-12,amp:a*0.2,pan:0,release:0.8 if f>0.4
  end
  sleep 3.5/(BPM_DI/60.0)
end

live_loop :melody do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  if al(t,f,vi).include?(:melody)
    a=clamp(f*0.55,0.06,0.75); bp=S_PAN.call(HP_DI+LP_DI.call(t)*0.15)
    cn,ct=gcp(t,vi); mi=($ms[t.to_i%$ms.length]*7).to_i%7; nt=scale(:c4,:major)[mi]
    mm<<nt if mm.length<8; synth :piano,note:nt,amp:a,pan:bp,release:0.8
    if f>0.5&&(t.to_i%8)<6
      ha=a*0.4; hp=S_PAN.call(bp+0.06)
      synth :saw,note:chord(cn,ct),amp:ha,pan:hp,release:1.2
      if mm.length>2&&$hs[t.to_i%$hs.length]>0.7&&vi>=2
        mn=mm[(vi*t.to_i)%mm.length]; synth :piano,note:mn+12,amp:ha*0.5,pan:-bp,release:1.6
      end
    end
  end
  sleep 6.5/(BPM_DI/60.0)
end

live_loop :perc do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  if al(t,f,vi).include?(:perc)
    a=clamp(f*0.4,0.03,0.6); bp=LP_DI.call(t)*0.55; p=S_PAN.call(bp)
    pi=(vi+(t.to_i/8))%PD_DI.length; pos=(t*1.8).to_i%8; bi=PD_DI[pi][pos]
    if bi>0&&f>0.28
      rv=$ks[t.to_i%$ks.length]; at=0.62+vi*0.04; ia=rv>at
      aa=ia ? a*bi*1.4 : a*bi*0.65
      sample :sn_dub,amp:clamp(aa,0,0.85),pan:p
      if ia&&vi>=1
        sample :bd_tek,amp:clamp(aa*0.28,0,0.42),pan:p*0.45
      end
    end
    gc=$bs[(t*P).to_i%$bs.length]
    if gc>0.73&&vi>=1&&f>0.35
      ga=a*0.18; gp=S_PAN.call(bp*-0.6)
      sample :perc_snap,amp:ga,pan:gp
    end
    if vi>=2&&f>0.52
      bpi=vi%BD_DI.length; bint=BD_DI[bpi][pos]
      if bint>0.12
        br=($bs[(t*1.314).to_i%$bs.length]-0.5)*0.25
        fbi=clamp(bint+br,0,0.75)
        if fbi>0.16
          bpan=clamp(bp+0.28,-0.75,0.75)
          sample :perc_bell,amp:a*fbi*0.48,pan:S_PAN.call(bpan)
        end
      end
    end
  end
  sleep 0.75/(BPM_DI/60.0)
end

live_loop :fx do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  if al(t,f,vi).include?(:fx)
    a=clamp(f*0.25,0.01,0.45); pm=Math.sin(t*0.06*PI)*0.6; p=S_PAN.call(HP_DI+pm*f)
    rs=0.7+vi*0.03; dt=1.5+f*1.5+dr*6
    with_fx :reverb,room:rs,decay:dt do
      with_fx :echo,phase:0.2+($ss[t.to_i%$ss.length]*0.06),decay:0.4 do
        st=[:noise,:bnoise,:gnoise][vi%3]; ra=[1.6,1.2,2.0][vi%3]
        synth st,amp:a,pan:p,release:ra
      end
    end
  end
  sleep 12.0/(BPM_DI/60.0)
end

live_loop :events do
  stop if vi>=VC_DI
  t=(current_beat-$vsb)*(60.0/BPM_DI); f=gf(t)+dr
  th=0.6-vi*0.03
  if f>=th && esubs[vi]
    ei=(t.to_i/18)%esubs[vi].length; ev=esubs[vi][ei]; ea=0.4+vi*0.06+f*0.3
    case ev
    when :bd_haus; sample :bd_haus,amp:clamp(ea*0.5,0.06,0.9),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.8)
    when :sn_dub; sample :sn_dub,amp:clamp(ea*0.4,0.06,0.9),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.8)
    when :synth_piano; cn,_=gcp(t,vi); synth :piano,note:cn,amp:clamp(ea*0.6,0.06,0.9),pan:S_PAN.call(HP_DI*0.8)
    when :fx_reverb; with_fx :reverb,room:0.8+vi*0.01 do synth :saw,note:note(:e4)+vi,amp:clamp(ea*0.3,0.06,0.9),release:0.8+vi*0.12 end
    when :synth_pad; cn,ct=gcp(t,vi); synth :prophet,note:chord(cn,ct),amp:clamp(ea*0.35,0.04,0.6),pan:S_PAN.call(HP_DI*0.4),release:2.2+vi*0.25
    when :perc_bell; sample :perc_bell,amp:clamp(ea*0.35,0.04,0.7),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.6)
    when :fx_echo; with_fx :echo,phase:0.35+($ss[t.to_i%$ss.length]*0.1),decay:0.55 do synth :pluck,note:scale(:c5,:major_pentatonic)[($ms[t.to_i%$ms.length]*5).to_i%5],amp:clamp(ea*0.4,0.04,0.7),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.7),release:1.1 end
    when :amen_fill; ai=(vi+t.to_i)%AP.length; rm=1.0+(vi*0.03)+($rs[t.to_i%$rs.length]-0.5)*0.06; sample AP[ai],amp:clamp(ea*0.45,0.06,0.9),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.6),rate:rm
    end
  end
  sleep 18.0/(BPM_DI/60.0)
end

live_loop :vctrl do
  puts "Dawn variant #{vi+1}/#{VC_DI}" if DEBUG; $vsb=current_beat
  pns=case vi; when 0; [:c4,:e4,:g4,:c5]; when 1; [:c4,:e4,:g4,:b4,:c5]; when 2; [:c4,:d4,:f4,:g4,:a4,:c5]; else; mm.length>0 ? mm.take(4) : [:c4,:e4,:g4,:c5]; end
  pns.each_with_index{|n,i| fa=(i+1)/pns.length.to_f*0.3; pa=(i*PI/2)+(vi*PI/4); p=S_PAN.call(Math.sin(pa)*0.6); synth :piano,note:n,amp:fa,release:0.3,pan:p; synth :saw,note:n+7,amp:fa*0.2,release:0.5,pan:-p if vi>=2; sleep 0.2}
  sleep 3.5; sleep S_DI.values.sum; em=clamp(em+0.1-vi*0.01,0.2,0.9); sleep 4.2
  vi+=1; dr+=0.012*(vi+1); stop if vi>=VC_DI
end