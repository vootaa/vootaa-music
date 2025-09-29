load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"
use_debug false

def clamp(v, min, max); [min, [v, max].min].max; end
def gf(t)
  intro_end = S_DI[:intro]
  drive_end = intro_end + S_DI[:drive]
  peak_end = drive_end + S_DI[:peak]
  if t < intro_end
    clamp(VB_DI + (t / intro_end) * 0.4 + Math.sin(t * PI * P / 8) * 0.06, 0, 0.65)
  elsif t < drive_end
    dt = t - intro_end; dp = dt / S_DI[:drive]
    clamp(0.65 + (E**(dp * 1.8) - 1) / (E**1.8 - 1) * 0.35, 0.65, 1.0)
  elsif t < peak_end
    pt = t - drive_end
    clamp(1.0 + Math.sin(pt * PI * 1.5) * 0.04, 0.96, 1.0)
  else
    ot = t - peak_end
    clamp(1.0 - (ot / S_DI[:outro])**1.8, 0, 1.0)
  end
end
def gcp(t, vi)
  ci = ($ks[(t.to_i / 4) % $ks.length] * 4).to_i % BC_DI.length
  bn, bt = BC_DI[ci]
  if vi >= 2 && $hs[t.to_i % $hs.length] > 0.6
    ei = ($ms[t.to_i % $ms.length] * 4).to_i % CE_DI.length
    return [bn, CE_DI[ei]]
  end
  [bn, bt]
end
def al(f, vi); [:kick] + (f > 0.4 ? [:bass, :melody] : []) + (f > 0.6 && vi >= 1 ? [:perc] : []) + (f > 0.8 ? [:fx] : []); end

# Precompute short sequences for simplicity
$ks = MD[:golden].chars.map(&:to_i).take(50).map { |d| d / 10.0 }
$bs = MD[:pi].chars.map(&:to_i).take(50).map { |d| d / 10.0 }
$ms = MD[:e].chars.map(&:to_i).take(100).map { |d| d / 10.0 }
$hs = (0...50).map { |i| ($ks[i % $ks.length] * P + $ms[i % $ms.length]) / (P + 1) }
$ss = (0...25).map { |i| ($ms[i % $ms.length] * P + $bs[i % $bs.length]) / (P + 1) }

vi = 0; dr = 0; mm = []
$vsb = 0

live_loop :kick do
  stop if vi >= VC_DI
  t = (current_beat - $vsb) * (60.0 / BPM_DI); f = gf(t) + dr
  a = clamp(f * 0.7, 0.06, 0.9); bp = LP_DI.call(t) + VP_DI * f; sm = ($ss[(t.to_i / 2) % $ss.length] - 0.5) * 0.15
  p = S_PAN.call(bp + sm); sample :bd_haus, amp: a, pan: p
  sleep (1.2 / (BPM_DI / 60.0)) + ($bs[t.to_i % $bs.length] - 0.5) * 0.012
end

live_loop :bass do
  stop if vi >= VC_DI
  t = (current_beat - $vsb) * (60.0 / BPM_DI); f = gf(t) + dr
  if al(f, vi).include?(:bass)
    a = clamp(f * 0.5, 0.03, 0.65); p = ($ss[t.to_i % $ss.length] - 0.5) * 0.12
    ni = ($bs[t.to_i % $bs.length] * 7).to_i % 7; rn = scale(:c2, :minor_pentatonic)[ni % 5]
    synth :saw, note: rn, amp: a, pan: p, release: 0.4, cutoff: 52 + f * 35
    synth :sine, note: rn - 12, amp: a * 0.2, pan: 0, release: 0.8 if f > 0.4
  end
  sleep 3.5 / (BPM_DI / 60.0)
end

live_loop :melody do
  stop if vi >= VC_DI
  t = (current_beat - $vsb) * (60.0 / BPM_DI); f = gf(t) + dr
  if al(f, vi).include?(:melody)
    a = clamp(f * 0.55, 0.06, 0.75); bp = S_PAN.call(HP_DI + LP_DI.call(t) * 0.15)
    cn, ct = gcp(t, vi); mi = ($ms[t.to_i % $ms.length] * 7).to_i % 7; nt = scale(:c4, :major)[mi]
    mm << nt if mm.length < 8; synth :piano, note: nt, amp: a, pan: bp, release: 0.8
    if f > 0.5
      ha = a * 0.4; hp = S_PAN.call(bp + 0.06)
      synth :saw, note: chord(cn, ct), amp: ha, pan: hp, release: 1.2
      if mm.length > 2 && vi >= 2
        mn = mm[(vi * t.to_i) % mm.length]; synth :piano, note: mn + 12, amp: ha * 0.5, pan: -bp, release: 1.6
      end
    end
  end
  sleep 6.5 / (BPM_DI / 60.0)
end

live_loop :perc do
  stop if vi >= VC_DI
  t = (current_beat - $vsb) * (60.0 / BPM_DI); f = gf(t) + dr
  if al(f, vi).include?(:perc)
    a = clamp(f * 0.4, 0.03, 0.6); bp = LP_DI.call(t) * 0.55; p = S_PAN.call(bp)
    pos = (t * 1.8).to_i % 8; bi = PD_DI[vi % PD_DI.length][pos]
    if bi > 0 && f > 0.28
      rv = $ks[t.to_i % $ks.length]; at = 0.62 + vi * 0.04; ia = rv > at
      aa = ia ? a * bi * 1.4 : a * bi * 0.65
      sample :sn_dub, amp: clamp(aa, 0, 0.85), pan: p
      sample :bd_tek, amp: clamp(aa * 0.28, 0, 0.42), pan: p * 0.45 if ia && vi >= 1
    end
    if vi >= 1 && f > 0.35
      ga = a * 0.18; gp = S_PAN.call(bp * -0.6)
      sample :perc_snap, amp: ga, pan: gp
    end
    if vi >= 2 && f > 0.52
      bint = BD_DI[vi % BD_DI.length][pos]
      if bint > 0.12
        fbi = clamp(bint + ($bs[(t * 1.314).to_i % $bs.length] - 0.5) * 0.25, 0, 0.75)
        if fbi > 0.16
          bpan = clamp(bp + 0.28, -0.75, 0.75)
          sample :perc_bell, amp: a * fbi * 0.48, pan: S_PAN.call(bpan)
        end
      end
    end
  end
  sleep 0.75 / (BPM_DI / 60.0)
end

live_loop :fx do
  stop if vi >= VC_DI
  t = (current_beat - $vsb) * (60.0 / BPM_DI); f = gf(t) + dr
  if al(f, vi).include?(:fx)
    a = clamp(f * 0.25, 0.01, 0.45); p = S_PAN.call(HP_DI + Math.sin(t * 0.06 * PI) * 0.6 * f)
    with_fx :reverb, room: 0.7 + vi * 0.03, decay: 1.5 + f * 1.5 + dr * 6 do
      st = [:noise, :bnoise, :gnoise][vi % 3]; ra = [1.6, 1.2, 2.0][vi % 3]
      synth st, amp: a, pan: p, release: ra
    end
  end
  sleep 12.0 / (BPM_DI / 60.0)
end

live_loop :vctrl do
  puts "Dawn variant #{vi + 1}/#{VC_DI}" if DEBUG; $vsb = current_beat
  pns = case vi
        when 0; [:c4, :e4, :g4, :c5]
        when 1; [:c4, :e4, :g4, :b4, :c5]
        when 2; [:c4, :d4, :f4, :g4, :a4, :c5]
        else; mm.length > 0 ? mm.take(4) : [:c4, :e4, :g4, :c5]
        end
  pns.each_with_index { |n, i| fa = (i + 1) / pns.length.to_f * 0.3; pa = (i * PI / 2) + (vi * PI / 4); p = S_PAN.call(Math.sin(pa) * 0.6); synth :piano, note: n, amp: fa, release: 0.3, pan: p; synth :saw, note: n + 7, amp: fa * 0.2, release: 0.5, pan: -p if vi >= 2; sleep 0.2 }
  sleep 3.5; sleep S_DI.values.sum; sleep 4.2
  vi += 1; dr += 0.012 * (vi + 1); stop if vi >= VC_DI
end