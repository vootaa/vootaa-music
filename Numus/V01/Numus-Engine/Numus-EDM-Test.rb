use_bpm 120   # Can be overridden later via /set_bpm if added

# Runtime state (defaults)
set :energy, 0.3
set :density, 0.2
set :chord, "C"
set :active_parts, []
set :kick_sparse, false
set :fx_riser_active, false
set :snare_active, false
set :filter_sweep_active, false
set :sub_fade_active, false

puts "Numus-EDM: Ready. Waiting for OSC control data on (likely) port 4560 (try 4559 if no response)."

# ---------------------------
# OSC RECEIVE LOOPS
# Each loop listens for one address and updates global state.
# ---------------------------
live_loop :osc_energy do
  use_real_time
  v = sync "/osc*/set_energy"
  set :energy, v[0].to_f
  puts "OSC set_energy -> #{get(:energy)}"
end

live_loop :osc_density do
  use_real_time
  v = sync "/osc*/set_density"
  set :density, v[0].to_f
  puts "OSC set_density -> #{get(:density)}"
end

live_loop :osc_chord do
  use_real_time
  v = sync "/osc*/set_chord"
  # Expect single string (e.g. "C", "Am")
  set :chord, v[0].to_s
  puts "OSC set_chord -> #{get(:chord)}"
end

live_loop :osc_active_parts do
  use_real_time
  v = sync "/osc*/active_parts"
  # Received as single comma-separated string
  parts = v[0].to_s.split(',').map(&:strip)
  set :active_parts, parts
  puts "OSC active_parts -> #{parts}"
end

# Boolean toggles (sender now sends "1" or "0")
def bool_from(v)
  vv = v[0]
  (vv.to_s == "1") || (vv == 1) || (vv.to_s.downcase == "true")
end

live_loop :osc_kick_sparse do
  use_real_time
  v = sync "/osc*/kick_sparse"
  set :kick_sparse, bool_from(v)
  puts "OSC kick_sparse -> #{get(:kick_sparse)}"
end

live_loop :osc_fx_riser do
  use_real_time
  v = sync "/osc*/fx_riser"
  set :fx_riser_active, bool_from(v)
  puts "OSC fx_riser -> #{get(:fx_riser_active)}"
end

live_loop :osc_snare do
  use_real_time
  v = sync "/osc*/snare"
  set :snare_active, bool_from(v)
  puts "OSC snare -> #{get(:snare_active)}"
end

live_loop :osc_filter_sweep do
  use_real_time
  v = sync "/osc*/filter_sweep"
  set :filter_sweep_active, bool_from(v)
  puts "OSC filter_sweep -> #{get(:filter_sweep_active)}"
end

live_loop :osc_sub_fade do
  use_real_time
  v = sync "/osc*/sub_fade"
  set :sub_fade_active, bool_from(v)
  puts "OSC sub_fade -> #{get(:sub_fade_active)}"
end

# Optional debug channel
live_loop :osc_debug do
  use_real_time
  v = sync "/osc*/debug"
  puts "OSC DEBUG -> #{v.inspect}"
end

# ---------------------------
# Master clock (metronome cue)
# ---------------------------
live_loop :met do
  sleep 1
end

# ---------------------------
# Musical Parts
# ---------------------------

# Kick: true four-on-the-floor; sparse = only beats 0 & 2 (example)
live_loop :kick, sync: :met do
  if get(:active_parts).include?("kick")
    sparse = get(:kick_sparse)
    energy = get(:energy)
    beat_idx = (tick % 4)
    play_it = if sparse
                (beat_idx == 0 || beat_idx == 2)
              else
                true
              end
    sample :bd_tek, amp: energy * (sparse ? 0.9 : 1.2) if play_it
  end
  sleep 1
end

# Bass (sub)
live_loop :bass, sync: :met do
  if get(:active_parts).include?("bass")
    root_note = note(get(:chord))
    synth :sine, note: root_note - 12, amp: get(:energy) * 0.8,
         sustain: 0.8, release: 0.2
  end
  sleep 1
end

# Pad (sustained)
live_loop :pad, sync: :met do
  if get(:active_parts).include?("pad")
    n = get(:chord)
    begin
      notes = chord(n, :major)
    rescue
      notes = [note(n)]
    end
    with_fx :reverb, mix: 0.3, room: 0.7 do
      synth :saw, notes: notes, amp: get(:energy) * 0.6,
            sustain: 4, release: 2
    end
  end
  sleep 4
end

# Lead
live_loop :lead, sync: :met do
  if get(:active_parts).include?("lead")
    base = note(get(:chord))
    use_random_seed 1234  # deterministic variability
    steps = (scale base+12, :major, num_octaves: 1).shuffle.take(1)
    steps.each do |nt|
      synth :prophet, note: nt, amp: get(:energy) * 0.7,
            sustain: 0.5, release: 0.3, cutoff: 90 + (get(:energy)*40)
    end
  end
  sleep 2
end

# Snare (on beats 2 & 4 pattern)
live_loop :snare, sync: :met do
  if get(:snare_active)
    b = (tick % 4)
    sample :sn_dolf, amp: get(:energy) * 0.6 if [1,3].include?(b)
  end
  sleep 1
end

# FX Riser (trigger while active)
live_loop :fx_riser, sync: :met do
  if get(:fx_riser_active)
    with_fx :slicer, phase: 0.25, mix: 0.3 do
      synth :noise, amp: get(:energy) * 0.4,
           attack: 0, sustain: 3.5, release: 0.5,
           cutoff: (line 70, 130, steps: 16).tick
    end
  end
  sleep 4
end

# Filter Sweep value (can be used by other synths if expanded)
live_loop :filter_sweep, sync: :met do
  if get(:filter_sweep_active)
    set :cutoff_val, (line 70, 130, steps: 32).tick
  end
  sleep 0.5
end

# Sub Fade automation (amp envelope stored)
live_loop :sub_fade, sync: :met do
  if get(:sub_fade_active)
    set :sub_amp, (line 0.8, 0, steps: 64).tick
  end
  sleep 1
end