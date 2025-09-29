# Dawn Ignition 《晨启》V0.1
# 基于数学演变的Deep House

use_bpm 120

define :pi_seq do |index, offset = 0|
  "31415926535897932384626433832795"[(index + offset) % 30].to_i / 9.0
end

define :phi_wave do |time, freq = 1.0, amp = 1.0|
  (Math.sin(time * freq * 1.618) * 0.5 + 0.5) * amp
end

define :safe do |val, min, max|
  [[val, min].max, max].min
end

define :layers do |t|
  {micro: t % 4, meso: (t/16) % 8, macro: (t/128) % 16, ultra: t/2048.0}
end

define :evolve do |time, freq, rate = 0.1|
  l = layers(time)
  base = Math.sin(time * freq) * 0.5 + 0.5
  micro = phi_wave(l[:micro], 4.0, 0.3)
  meso = phi_wave(l[:meso], 1.0, 0.4) 
  macro = phi_wave(l[:macro], 0.25, 0.2)
  
  safe(base + (micro + meso + macro) * 0.3, 0.0, 1.0)
end

set :t, 0
set :phase, 0.0
set :energy, 0.15

live_loop :master do
  time = get(:t) + 1
  set :t, time
  set :phase, evolve(time, 0.01, 0.05)
  set :energy, evolve(time, 0.02, 0.08)
  
  puts "T:#{time} E:#{get(:energy).round(2)}" if time % 128 == 0
  sleep 0.125
end

live_loop :kick, sync: :master do
  t, energy = get(:t), get(:energy)
  l = layers(t)
  
  trigger = (t % 4 == 0) || (t % 16 == 6 && pi_seq(t/4, 23) > 0.7)
  
  if trigger
    sample :bd_haus,
      amp: safe(0.8 + energy * 0.4 + pi_seq(t, 31) * 0.2, 0.1, 2.0),
      rate: safe(0.98 + (pi_seq(t/8, 17) * 0.1 - 0.05), 0.5, 2.0),
      cutoff: safe(70 + energy * 40 + phi_wave(l[:micro], 2.0, 15), 30, 130)
  end
  sleep 0.25
end

live_loop :bass, sync: :master do
  t, energy, phase = get(:t), get(:energy), get(:phase)
  l = layers(t)
  
  use_synth :fm
  
  bass_chords = [[:c2,:eb2,:g2], [:f2,:ab2,:c3], [:g2,:bb2,:d3], [:c2,:eb2,:g2]]
  current_chord = bass_chords[(l[:meso]/2).to_i % 4]
  note = current_chord[(pi_seq(t/8, 47) * current_chord.length).to_i % current_chord.length]
  
  play_cond = (t % 8 == 0) || (t % 8 == 3 && pi_seq(t/4, 53) > 0.6)
  
  if play_cond
    with_fx :reverb, room: safe(0.3 + phase * 0.2, 0, 1), mix: 0.2 do
      play note,
        cutoff: safe(60 + energy * 35 + phi_wave(l[:micro], 1.0, 15), 30, 130),
        amp: safe(0.5 + energy * 0.3, 0.1, 1.0),
        divisor: safe(0.5 + phase * 0.3, 0.1, 2.0),
        attack: 0.1, release: 0.8
    end
  end
  sleep 0.5
end

live_loop :pads, sync: :master do
  t, energy, phase = get(:t), get(:energy), get(:phase)
  l = layers(t)
  
  use_synth :hollow
  
  pad_chords = [chord(:c4,:minor7), chord(:f4,:major7), chord(:g4,:dom7), chord(:c4,:minor7)]
  current_pad = pad_chords[(l[:macro]/4).to_i % 4]
  drift = safe((pi_seq(t/32, 59) - 0.5) * 1.5, -2.0, 2.0)
  warped = current_pad.map{|n| n + drift}
  
  if t % 16 == 0
    with_fx :reverb, room: safe(0.6 + phase * 0.3, 0, 1), mix: safe(0.4 + energy * 0.3, 0, 1) do
      with_fx :wobble, phase: safe(4 + phi_wave(l[:ultra], 0.1, 2), 0.5, 16), mix: safe(0.2 + phase * 0.3, 0, 1) do
        play warped,
          attack: safe(3 + phase * 3, 0.1, 10),
          release: safe(12 + energy * 8, 1, 30),
          amp: safe(0.25 + energy * 0.15, 0.05, 1),
          cutoff: safe(80 + energy * 30, 30, 130)
      end
    end
  end
  sleep 2
end

live_loop :melody, sync: :master do
  t, energy, phase = get(:t), get(:energy), get(:phase)
  l = layers(t)
  
  use_synth energy < 0.3 ? :sine : (energy < 0.6 ? :blade : :prophet)
  
  melody_notes = scale(:c5, :minor_pentatonic) + [:bb5, :d5, :f5]
  current_note = melody_notes[(pi_seq(t/4, 67) * melody_notes.length).to_i % melody_notes.length]
  
  if pi_seq(t/2, 71) < safe(0.3 + phase * 0.5, 0, 1) && energy > 0.25
    with_fx :echo, phase: safe(0.375 + phi_wave(l[:meso], 0.2, 0.125), 0.125, 2), decay: safe(3 + energy * 2, 1, 8), mix: safe(0.3 + phase * 0.2, 0, 1) do
      with_fx :reverb, room: safe(0.5 + energy * 0.3, 0, 1), mix: 0.4 do
        play current_note + safe(phi_wave(l[:micro], 8.0, 0.2) - 0.1, -1, 1),
          attack: safe(0.1 + phase * 0.4, 0.01, 2),
          release: safe(0.8 + energy * 1.5, 0.1, 4),
          amp: safe(0.3 + energy * 0.2, 0.05, 1),
          cutoff: safe(90 + energy * 30, 30, 130)
      end
    end
  end
  
  sleep energy > 0.7 ? [0.25, 0.5, 0.75].choose : [0.5, 1.0, 1.5].choose
end

live_loop :atmosphere, sync: :master do
  t, energy, phase = get(:t), get(:energy), get(:phase)
  l = layers(t)
  
  use_synth :dark_ambience
  
  if t % 64 == 0
    ambient_note = :c4 + safe(phi_wave(l[:ultra], 20.0, 12).round, -24, 24)
    
    with_fx :reverb, room: safe(0.7 + (Math.log(t+1)/Math.log(2.718)) * 0.02 % 1 * 0.3, 0, 1), mix: safe(0.8 + phase * 0.2, 0, 1) do
      with_fx :echo, phase: safe(phi_wave(l[:ultra], 30.0, 0.5) + 0.5, 0.125, 4) do
        play ambient_note,
          attack: safe(6 + phase * 4, 1, 15),
          release: safe(16 + energy * 12, 8, 40),
          amp: safe(0.1 + (1 - energy) * 0.1, 0.01, 0.3),
          cutoff: safe(60 + pi_seq(t/16, 79) * 30, 30, 130)
      end
    end
  end
  sleep 8
end

live_loop :perc, sync: :master do
  t, energy, phase = get(:t), get(:energy), get(:phase)
  l = layers(t)
  
  hihat_pattern = [0, 0.3, 0, 0.7, 0, 0.18, 0, 0.42] # 简化分形模式
  hihat_strength = hihat_pattern[(l[:micro] * 2).to_i % hihat_pattern.length]
  
  if hihat_strength > 0.2 && energy > 0.3
    sample :drum_cymbal_closed,
      amp: safe(hihat_strength * (0.4 + energy * 0.3), 0.05, 1),
      rate: safe(0.9 + pi_seq(t, 83) * 0.2, 0.5, 2),
      cutoff: safe(100 + energy * 25, 60, 130)
  end
  
  if t % 32 == 24 && pi_seq(t/8, 97) > 0.6
    sample [:perc_bell, :perc_snap].choose,
      amp: safe(0.3 + phase * 0.2, 0.1, 0.8),
      rate: safe(0.8 + pi_seq(t, 101) * 0.4, 0.5, 2)
  end
  
  sleep 0.25
end