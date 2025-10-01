# Endless Lane - Sonic Pi Code for CarDJ_EDM
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

use_debug false

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion_el(t)
  if t < S_EL[:intro]
    clamp(VB_EL + (t / S_EL[:intro]) * 0.3, 0, 0.6)
  elsif t < S_EL[:intro] + S_EL[:drive]
    clamp(0.6 + ((t - S_EL[:intro]) / S_EL[:drive]) * 0.4, 0.6, 1.0)
  elsif t < S_EL[:intro] + S_EL[:drive] + S_EL[:peak]
    1.0
  else
    clamp(1.0 - ((t - (S_EL[:intro] + S_EL[:drive] + S_EL[:peak])) / S_EL[:outro]), 0, 1.0)
  end
end

def get_md_seq(const, len)
  seq = MD[const.to_sym].chars.map(&:to_i).take(len)
  seq.map { |d| d / 10.0 }
end

# Cached sequences for optimization
kick_seq = get_md_seq("golden", 100)
bass_seq = get_md_seq("pi", 100)
melody_seq = get_md_seq("e", 200)
event_seq = get_md_seq("sqrt2", EP_EL.length)

# Initialize sequences and variant logic
variant_index = 0
drift = 0
event_subsets = []
subset_size = [3, (EP_EL.length.to_f / VC_EL).ceil].max  # Ensure at least 3
VC_EL.times do |i|
  start = i * (subset_size - 1)  # Overlap step for衔接
  subset = []
  subset_size.times do |j|
    idx = (start + j) % EP_EL.length  # Loop to cover all events
    subset << EP_EL[idx]
  end
  event_subsets << subset
end

# Global for variant start beat
$variant_start_beat = 0

# Live loops with variant evolution
live_loop :kick do
  if variant_index >= VC_EL
    stop
  end
  t = (current_beat - $variant_start_beat) * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.8, 0.1, 1.0)
  pan = S_PAN.call(LP_EL.call(t) + VP_EL * fusion)
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM_EL / 60.0)
end

live_loop :bass do
  if variant_index >= VC_EL
    stop
  end
  t = (current_beat - $variant_start_beat) * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.6, 0.05, 0.8)
  pan = 0  # Low freq centered
  note = scale(:c2, :minor)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i % 7]  # Fixed: modulo 7 to prevent index out of range (minor scale has 7 notes)
  synth :saw, note: note, amp: amp, pan: pan, release: 0.5
  sleep 2.0 / (BPM_EL / 60.0)
end

live_loop :melody do
  if variant_index >= VC_EL
    stop
  end
  t = (current_beat - $variant_start_beat) * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.7, 0.1, 0.9)
  pan = S_PAN.call(HP_EL + LP_EL.call(t) * 0.2)
  notes = scale(:c4, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i % 7]  # Fixed: modulo 7 to prevent index out of range (major scale has 7 notes)
  # Pad layering: multiple synths for harmony
  synth :piano, note: notes, amp: amp, pan: pan, release: 1.0
  if fusion > 0.5
    synth :saw, note: chord(notes, :major), amp: amp * 0.5, pan: pan + 0.1, release: 1.5  # Fixed: use chord instead of chord_degree to avoid scale error
    if fusion > 0.8  # Add more chords for richness
      synth :piano, note: chord(:c4, :major7), amp: amp * 0.3, pan: pan - 0.1, release: 2.0  # Full chord layering
    end
  end
  sleep 4.0 / (BPM_EL / 60.0)
end

live_loop :percussion do
  if variant_index >= VC_EL
    stop
  end
  t = (current_beat - $variant_start_beat) * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.5, 0.05, 0.7)
  pan = S_PAN.call(LP_EL.call(t) * -1)
  sample :sn_dub, amp: amp, pan: pan if event_seq[(t.to_i % event_seq.length)] < 0.4 + fusion * 0.3  # Deterministic replacement for rand
  sleep 0.5 / (BPM_EL / 60.0)
end

live_loop :fx do
  if variant_index >= VC_EL
    stop
  end
  t = (current_beat - $variant_start_beat) * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.4, 0.02, 0.6)
  pan_offset = event_seq[(t.to_i % event_seq.length)] * 0.8 - 0.4  # Deterministic replacement for rand(-0.4..0.4)
  pan = S_PAN.call(HP_EL + pan_offset * fusion)
  # FX stacking: nested reverb and echo
  with_fx :reverb, room: 0.9, decay: 2.5 + fusion * 2.5 do
    with_fx :echo, phase: 0.3, decay: 0.6 do
      synth :noise, amp: amp, pan: pan, release: 2.0
    end
  end
  sleep 8.0 / (BPM_EL / 60.0)
end

live_loop :events do
  if variant_index >= VC_EL
    stop
  end
  t = (current_beat - $variant_start_beat) * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  threshold = BPM_EL > 130 ? 0.6 : 0.7  # Velocity-based threshold
  if DEBUG
    puts "DEBUG: Variant #{variant_index}, t #{t.round(2)}, Fusion #{fusion.round(2)}, Threshold #{threshold}, Event_subsets exist: #{!event_subsets[variant_index].nil?}"
  end
  if fusion > threshold && event_subsets[variant_index]
    event_index = (t.to_i / 16) % event_subsets[variant_index].length  # Deterministic selection
    event = event_subsets[variant_index][event_index]
    if DEBUG
      puts "DEBUG: Event triggered: #{event}"
    end
    case event
    when :bd_haus
      pan_offset = event_seq[(t.to_i % event_seq.length)] * 1.0 - 0.5  # Deterministic
      sample :bd_haus, amp: clamp(0.6, 0.1, 1.0), pan: S_PAN.call(pan_offset)
    when :sn_dub
      pan_offset = event_seq[(t.to_i % event_seq.length)] * 1.0 - 0.5
      sample :sn_dub, amp: clamp(0.5, 0.1, 1.0), pan: S_PAN.call(pan_offset)
    when :synth_saw
      synth :saw, note: :e4, amp: clamp(0.7, 0.1, 1.0), pan: S_PAN.call(HP_EL)
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :g4, amp: clamp(0.4, 0.1, 1.0), release: 1.5
      end
    when :amen_fill
      amen_index = (variant_index + t.to_i) % AP.length  # Deterministic Amen selection
      sample AP[amen_index], amp: clamp(0.7, 0.1, 1.0), pan: S_PAN.call(event_seq[(t.to_i % event_seq.length)] * 0.8 - 0.4), rate: 1.0
    # Add more cases as needed
    end
  end
  sleep 16.0 / (BPM_EL / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # DEBUG: Print progress if in DEBUG mode
  if DEBUG
    puts "DEBUG: Starting variant #{variant_index + 1} of #{VC_EL}"
  end
  
  # Record start beat for this variant
  $variant_start_beat = current_beat
  
  # Variant start prompt: unique Synth melody for House with stereo surround and fade-in
  melody_notes = [:c4, :e4, :g4, :c5]
  melody_notes.each_with_index do |n, i|
    fade_amp = (i + 1) / melody_notes.length.to_f * 0.4  # Fade-in amp
    pan = S_PAN.call(Math.sin(i * PI / 3) * 0.6)
    synth :piano, note: n, amp: fade_amp, release: 0.4, pan: pan
    sleep 0.25
  end
  sleep 0.5  # Prompt end, total ~1.5 sec
  
  total_seg = S_EL.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 2-sec silence for rhythm
  sleep 2.0
  
  variant_index += 1
  drift += 0.01  # Cumulative drift
  stop if variant_index >= VC_EL
end