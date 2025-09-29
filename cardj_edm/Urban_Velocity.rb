load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"
use_debug false

def clamp(v,min,max); [min,[v,max].min].max; end
def gf(t)
  if t < S_UV[:intro]
    b = VB_UV+(t/S_UV[:intro])*0.5
    br = Math.sin(t*PI*E/6)*0.08
    clamp(b+br, 0, 0.8)
  elsif t < S_UV[:intro]+S_UV[:drive]
    dt = t-S_UV[:intro]; dp = dt/S_UV[:drive]
    b = 0.8+(E**(dp*2.2)-1)/(E**2.2-1)*0.2
    clamp(b, 0.8, 1.0)
  elsif t < S_UV[:intro]+S_UV[:drive]+S_UV[:peak]
    pt = t-S_UV[:intro]-S_UV[:drive]
    mv = Math.sin(pt*PI*2.0)*0.06
    clamp(1.0+mv, 0.94, 1.0)
  else
    ot = t-(S_UV[:intro]+S_UV[:drive]+S_UV[:peak])
    df = 1.0-(ot/S_UV[:outro])**2.0
    clamp(df, 0, 1.0)
  end
end
def gms(c,l); MD[c.to_sym].chars.map(&:to_i).take(l).map{|d| d/10.0}; end
def gcm(s1,s2,l); (0...l).map{|i| v1=s1[i%s1.length]; v2=s2[i%s2.length]; (v1*E+v2)/(E+1)}; end
def gcp(t,vi)
  ci = ($ks[(t.to_i/3)%$ks.length]*5).to_i % BC_DI.length
  bn,bt = BC_DI[ci]
  if vi>=2 && $hs[t.to_i%$hs.length]>0.65
    ei = ($ms[t.to_i%$ms.length]*5).to_i % CE_DI.length
    return [bn, CE_DI[ei]]
  end
  [bn,bt]
end
def al(t,f,vi); ls=[:kick]; ls<<:bass if f>0.4; ls<<:melody if f>0.5&&(t.to_i%10)<7; ls<<:fx if f>0.65&&(t.to_i%14)<9; ls; end

$ks=gms("golden",100); $bs=gms("pi",100); $ms=gms("e",200); $es=gms("sqrt2",150)
$hs=gcm($ks,$ms,100); $rs=gcm($bs,$es,100); $ss=gcm($ms,$bs,50)

vi=0; dr=0; mm=[]; em=0.6
esubs=[]; ssz=[3,(EP_UV.length.to_f/VC_UV).ceil].max
VC_UV.times{|i| st=i*(ssz-1); sb=[]; ssz.times{|j| idx=(st+j)%EP_UV.length; sb<<EP_UV[idx]}; esubs<<sb}
$vsb=0

live_loop :kick do
  stop if vi>=VC_UV
  t=(current_beat-$vsb)*(60.0/BPM_UV); f=gf(t)+dr+em*0.12
  to=($bs[t.to_i%$bs.length]-0.5)*0.015
  a=clamp(f*0.85,0.08,1.0); bp=LP_UV.call(t)+VP_UV*f; sm=($ss[(t.to_i/2)%$ss.length]-0.5)*0.18
  p=S_PAN.call(bp+sm)
  sample :bd_tek,amp:a,pan:p
  if f>0.65&&(t.to_i%4)==2; sample :bd_fat,amp:a*0.4,pan:p*0.3; end
  sleep (1.0/(BPM_UV/60.0))+to
end

live_loop :bass do
  stop if vi>=VC_UV
  t=(current_beat-$vsb)*(60.0/BPM_UV); f=gf(t)+dr
  if al(t,f,vi).include?(:bass)
    a=clamp(f*0.6,0.04,0.8); p=($ss[t.to_i%$ss.length]-0.5)*0.15
    ni=($bs[t.to_i%$bs.length]*8).to_i%8; rn=scale(:c2,:minor)[ni%6]
    synth :saw,note:rn,amp:a,pan:p,release:0.3,cutoff:45+f*45,attack:0.02
    synth :square,note:rn-12,amp:a*0.25,pan:0,release:0.6 if f>0.5
    if f>0.75&&vi>=2; synth :tb303,note:rn+12,amp:a*0.15,pan:p*-0.5,release:0.25,cutoff:65+f*25; end
  end
  sleep 2.8/(BPM_UV/60.0)
end

live_loop :melody do
  stop if vi>=VC_UV
  t=(current_beat-$vsb)*(60.0/BPM_UV); f=gf(t)+dr
  if al(t,f,vi).include?(:melody)
    a=clamp(f*0.65,0.08,0.85); bp=S_PAN.call(HP_UV+LP_UV.call(t)*0.2)
    cn,ct=gcp(t,vi); mi=($ms[t.to_i%$ms.length]*8).to_i%8; nt=scale(:c4,:minor)[mi]
    mm<<nt if mm.length<6
    synth :pluck,note:nt,amp:a,pan:bp,release:0.6,attack:0.01
    if f>0.6&&(t.to_i%6)<4
      ha=a*0.5; hp=S_PAN.call(bp+0.08)
      synth :saw,note:chord(cn,ct),amp:ha,pan:hp,release:0.8,attack:0.05,cutoff:70+f*20
      if mm.length>3&&$hs[t.to_i%$hs.length]>0.75&&vi>=2
        mn=mm[(vi*t.to_i)%mm.length]; synth :blade,note:mn+7,amp:ha*0.4,pan:-bp,release:1.0
      end
    end
    if vi>=3&&f>0.8; synth :prophet,note:nt+12,amp:a*0.3,pan:bp*-0.7,release:1.4; end
  end
  sleep 4.5/(BPM_UV/60.0)
end

live_loop :fx do
  stop if vi>=VC_UV
  t=(current_beat-$vsb)*(60.0/BPM_UV); f=gf(t)+dr
  if al(t,f,vi).include?(:fx)
    a=clamp(f*0.35,0.02,0.6); pm=Math.sin(t*0.08*PI)*0.8; p=S_PAN.call(HP_UV+pm*f)
    rs=0.6+vi*0.04; dt=1.0+f*2.0+dr*8
    with_fx :reverb,room:rs,decay:dt do
      with_fx :echo,phase:0.15+($ss[t.to_i%$ss.length]*0.08),decay:0.5 do
        st=[:tech_saws,:beep,:pulse][vi%3]; ra=[1.2,0.8,1.5][vi%3]
        synth st,amp:a,pan:p,release:ra,cutoff:80+f*40
      end
    end
  end
  sleep 8.5/(BPM_UV/60.0)
end

live_loop :events do
  stop if vi>=VC_UV
  t=(current_beat-$vsb)*(60.0/BPM_UV); f=gf(t)+dr
  th=0.65-vi*0.04
  if f>=th && esubs[vi]
    ei=(t.to_i/12)%esubs[vi].length; ev=esubs[vi][ei]; ea=0.5+vi*0.08+f*0.35
    case ev
    when :bd_tek; sample :bd_tek,amp:clamp(ea*0.6,0.08,1.0),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.9)
    when :sn_dub; sample :sn_dub,amp:clamp(ea*0.5,0.08,1.0),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.9)
    when :bd_fat; sample :bd_fat,amp:clamp(ea*0.7,0.08,1.0),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.7)
    when :synth_pluck; cn,_=gcp(t,vi); synth :pluck,note:cn,amp:clamp(ea*0.7,0.08,1.0),pan:S_PAN.call(HP_UV*0.9)
    when :synth_saw; cn,ct=gcp(t,vi); synth :saw,note:chord(cn,ct),amp:clamp(ea*0.4,0.05,0.8),pan:S_PAN.call(HP_UV*0.5),release:1.5
    when :sample_perc; sample :perc_bell,amp:clamp(ea*0.4,0.05,0.8),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.8)
    when :fx_reverb; with_fx :reverb,room:0.9+vi*0.02 do synth :tech_saws,note:note(:g4)+vi,amp:clamp(ea*0.4,0.08,1.0),release:1.0+vi*0.15 end
    when :fx_echo; with_fx :echo,phase:0.25+($ss[t.to_i%$ss.length]*0.12),decay:0.6 do synth :beep,note:scale(:c5,:minor_pentatonic)[($ms[t.to_i%$ms.length]*5).to_i%5],amp:clamp(ea*0.5,0.05,0.8),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.8),release:0.8 end
    when :synth_pad; cn,ct=gcp(t,vi); synth :prophet,note:chord(cn,ct),amp:clamp(ea*0.3,0.04,0.7),pan:S_PAN.call(HP_UV*0.6),release:2.5+vi*0.3
    when :amen_fill; ai=(vi+t.to_i)%AP.length; rm=1.05+(vi*0.04)+($rs[t.to_i%$rs.length]-0.5)*0.08; sample AP[ai],amp:clamp(ea*0.55,0.08,1.0),pan:S_PAN.call(($es[t.to_i%$es.length]-0.5)*0.7),rate:rm
    end
  end
  sleep 12.0/(BPM_UV/60.0)
end

live_loop :vctrl do
  puts "Urban variant #{vi+1}/#{VC_UV}" if DEBUG; $vsb=current_beat
  pns=case vi; when 0; [:g3,:b3,:d4,:g4]; when 1; [:g3,:b3,:d4,:f4,:g4]; when 2; [:g3,:a3,:c4,:d4,:f4,:g4]; else; mm.length>0 ? mm.take(5) : [:g3,:b3,:d4,:f4,:g4]; end
  pns.each_with_index{|n,i| fa=(i+1)/pns.length.to_f*0.4; pa=(i*PI/3)+(vi*PI/5); p=S_PAN.call(Math.sin(pa)*0.8); synth :blade,note:n,amp:fa,release:0.25,pan:p; synth :tech_saws,note:n+12,amp:fa*0.3,release:0.4,pan:-p if vi>=2; sleep 0.15}
  sleep 2.8; sleep S_UV.values.sum; em=clamp(em+0.12-vi*0.02,0.3,1.0); sleep 3.5
  vi+=1; dr+=0.015*(vi+1); stop if vi>=VC_UV
end