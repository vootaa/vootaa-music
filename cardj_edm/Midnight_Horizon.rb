# Midnight Horizon - Sonic Pi Code for CarDJ_EDM
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

use_debug false

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion_mh(t)
  if t < SEGMENTS_MH[:intro]
    clamp(VEL_BASE_MH + (t / SEGMENTS_MH[:intro]) * 0.4, 0, 0.6)
  elsif t < SEGMENTS_MH[:intro] + SEGMENTS_MH[:drive]
    clamp(0.6 + ((t - SEGMENTS_MH[:intro]) / SEGMENTS_MH[:drive]) * 0.3, 0.6, 0.9)
  elsif t < SEGMENTS_MH[:intro] + SEGMENTS_MH[:drive] + SEGMENTS_MH[:peak]
    0.9
  else
    clamp(0.9 - ((t - (SEGMENTS_MH[:intro] + SEGMENTS_MH[:drive] + SEGMENTS_MH[:peak])) / SEGMENTS_MH[:outro]), 0, 0.9)
  end
end

def get_md_seq(const, len)
  seq = MD[const.to_sym].chars.map(&:to_i).take(len)
  seq.map { |d| d / 10.0 }
end

# Cached sequences for optimization
kick_seq = get_md_seq("pi", 100)
bass_seq = get_md_seq("golden", 100)
melody_seq = get_md_seq("e", 200)
event_seq = get_md_seq("sqrt2", EVENT_POOL_MH.length)

# Initialize sequences and variant logic
variant_index = 0
drift = 0
event_subsets = []
subset_size = (EVENT_POOL_MH.length / VARIANT_COUNT_MH).to_i
VARIANT_COUNT_MH.times do |i|
  start = i * subset_size
  event_subsets << EVENT_POOL_MH[start...(start + subset_size)]
end

# Live loops with variant evolution
live_loop :kick do
  if variant_index >= VARIANT_COUNT_MH
    stop
  end
  t = current_beat * (60.0 / BPM_MH)
  fusion = get_fusion_mh(t) + drift
  amp = clamp(fusion * 0.7, 0.1, 0.9)
  pan = S_PAN.call(LANE_PAN_MH.call(t) + VEL_PAN_OFF_MH * fusion)
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM_MH / 60.0)
end

live_loop :bass do
  if variant_index >= VARIANT_COUNT_MH
    stop
  end
  t = current_beat * (60.0 / BPM_MH)
  fusion = get_fusion_mh(t) + drift
  amp = clamp(fusion * 0.5, 0.05, 0.7)
  pan = 0
  note = scale(:c2, :minor)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i % 7]  # Fixed: modulo 7 to prevent index out of range (minor scale has 7 notes)
  synth :saw, note: note, amp: amp, pan: pan, release: 0.8
  sleep 2.0 / (BPM_MH / 60.0)
end

live_loop :melody do
  if variant_index >= VARIANT_COUNT_UV
    stop
  end
  t = current_beat * (60.0 / BPM_MH)
  fusion = get_fusion_mh(t) + drift
  amp = clamp(fusion * 0.9, 0.1, 1.0)
  pan = S_PAN.call(HORIZON_PAN_MH + LANE_PAN_MH.call(t) * 0.3)
  notes = scale(:c5, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i % 7]  # Fixed: modulo 7 to prevent index out of range (major scale has 7 notes)
  # Pad layering: multiple synths for harmony
  synth :saw, note: notes, amp: amp, pan: pan, release: 2.0  # Pad for ambient layering
  if fusion > 0.8
    synth :pluck, note: chord_degree(notes, :major, 6), amp: amp * 0.7, pan: pan - 0.2, release: 3.0  # Chord enhancement
    if fusion > 0.8  # Add more chords for richness
      synth :piano, note: chord(:c4, :major7), amp: amp * 0.3, pan: pan - 0.1, release: 2.0  # Full chord layering
    end
  end
  sleep 4.0 / (BPM_MH / 60.0)
end

live_loop :percussion do
  if variant_index >= VARIANT_COUNT_MH
    stop
  end
  t = current_beat * (60.0 / BPM_MH)
  fusion = get_fusion_mh(t) + drift
  amp = clamp(fusion * 0.4, 0.05, 0.6)
  pan = S_PAN.call(LANE_PAN_MH.call(t) * -1)
  sample :sn_dub, amp: amp, pan: pan if rand < 0.3 + fusion * 0.4
  sleep 0.5 / (BPM_MH / 60.0)
end

live_loop :fx do
  if variant_index >= VARIANT_COUNT_MH
    stop
  end
  t = current_beat * (60.0 / BPM_MH)
  fusion = get_fusion_mh(t) + drift
  amp = clamp(fusion * 0.6, 0.02, 0.8)
  pan = S_PAN.call(HORIZON_PAN_MH + rand(-0.6..0.6) * fusion)
  # FX stacking: nested reverb and echo
  with_fx :reverb, room: 0.95, decay: 3.0 + fusion * 3.0 do
    with_fx :echo, phase: 0.4, decay: 0.8 do
      synth :noise, amp: amp, pan: pan, release: 3.0  # Deep reverb for night atmosphere
    end
  end
  sleep 8.0 / (BPM_MH / 60.0)
end

live_loop :events do
  if variant_index >= VARIANT_COUNT_MH
    stop
  end
  t = current_beat * (60.0 / BPM_MH)
  fusion = get_fusion_mh(t) + drift
  threshold = BPM_MH > 130 ? 0.6 : 0.7
  if fusion > threshold && event_subsets[variant_index]
    event = event_subsets[variant_index].sample
    case event
    when :bd_haus
      sample :bd_haus, amp: clamp(0.5, 0.1, 1.0), pan: S_PAN.call(rand(-0.5..0.5))
    when :sn_dub
      sample :sn_dub, amp: clamp(0.4, 0.1, 1.0), pan: S_PAN.call(rand(-0.5..0.5))
    when :synth_pad
      synth :saw, note: :a4, amp: clamp(0.8, 0.1, 1.0), pan: S_PAN.call(HORIZON_PAN_MH)
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :c4, amp: clamp(0.5, 0.1, 1.0), release: 2.0
      end
    when :amen_fill
      sample AMEN_POOL.sample, amp: clamp(0.6, 0.1, 1.0), pan: S_PAN.call(rand(-0.4..0.4)), rate: 0.9  # Slower rate for ambient
    # Add more cases as needed
    end
  end
  sleep 16.0 / (BPM_MH / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # DEBUG: Print progress if in DEBUG mode
  if DEBUG
    puts "DEBUG: Starting variant #{variant_index + 1} of #{VARIANT_COUNT_DI}"
  end
  
  # Variant start prompt: unique Synth melody for Uplifting Trance with stereo surround and fade-in
  melody_notes = [:c4, :e4, :g4, :b4, :c5]  # Uplifting arpeggio for night horizon
  melody_notes.each_with_index do |n, i|
    fade_amp = (i + 1) / melody_notes.length.to_f * 0.4  # Fade-in amp
    pan = S_PAN.call(Math.sin(i * PI / 3) * 0.8)
    synth :saw, note: n, amp: fade_amp, release: 0.6, pan: pan  # Pad with fade-in amp
    sleep 0.25  # Moderate sleep for uplifting feel
  end
  sleep 0.5  # Prompt end, total ~1.75 sec
  
  total_seg = SEGMENTS_MH.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 1.5-sec silence for ambient rhythm
  sleep 1.5
  
  variant_index += 1
  drift += 0.015  # Cumulative drift
  stop if variant_index >= VARIANT_COUNT_MH
end