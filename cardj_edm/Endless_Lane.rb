# Endless Lane - Sonic Pi Code for CarDJ_EDM
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

use_debug false

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion_el(t)
  if t < SEGMENTS_EL[:intro]
    clamp(VEL_BASE_EL + (t / SEGMENTS_EL[:intro]) * 0.2, 0, 0.5)
  elsif t < SEGMENTS_EL[:intro] + SEGMENTS_EL[:drive]
    clamp(0.5 + ((t - SEGMENTS_EL[:intro]) / SEGMENTS_EL[:drive]) * 0.4, 0.5, 0.9)
  elsif t < SEGMENTS_EL[:intro] + SEGMENTS_EL[:drive] + SEGMENTS_EL[:peak]
    0.9
  else
    clamp(0.9 - ((t - (SEGMENTS_EL[:intro] + SEGMENTS_EL[:drive] + SEGMENTS_EL[:peak])) / SEGMENTS_EL[:outro]), 0, 0.9)
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
event_seq = get_md_seq("sqrt2", EVENT_POOL_EL.length)

# Initialize sequences and variant logic
variant_index = 0
drift = 0
event_subsets = []
subset_size = [3, (EVENT_POOL_EL.length.to_f / VARIANT_COUNT_EL).ceil].max  # Ensure at least 3
VARIANT_COUNT_EL.times do |i|
  start = i * (subset_size - 1)
  subset = []
  subset_size.times do |j|
    idx = (start + j) % EVENT_POOL_EL.length
    subset << EVENT_POOL_EL[idx]
  end
  event_subsets << subset
end

# Live loops with variant evolution
live_loop :kick do
  if variant_index >= VARIANT_COUNT_EL
    stop
  end
  t = current_beat * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.9, 0.1, 1.0)
  pan = S_PAN.call(LANE_PAN_EL.call(t) + VEL_PAN_OFF_EL * fusion)
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM_EL / 60.0)
end

live_loop :bass do
  if variant_index >= VARIANT_COUNT_EL
    stop
  end
  t = current_beat * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.7, 0.05, 0.9)
  pan = 0
  note = scale(:c2, :minor)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i % 7]  # Fixed: modulo 7 to prevent index out of range (minor scale has 7 notes)
  synth :saw, note: note, amp: amp, pan: pan, release: 0.6
  sleep 2.0 / (BPM_EL / 60.0)
end

live_loop :melody do
  if variant_index >= VARIANT_COUNT_EL
    stop
  end
  t = current_beat * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.8, 0.1, 1.0)
  pan = S_PAN.call(HORIZON_PAN_EL + LANE_PAN_EL.call(t) * 0.2)
  notes = scale(:c4, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i % 7]  # Fixed: modulo 7 to prevent index out of range (major scale has 7 notes)
  # Pad layering: multiple synths for harmony
  synth :saw, note: notes, amp: amp, pan: pan, release: 1.2  # Extended release for progressive feel
  if fusion > 0.7
    synth :piano, note: chord_degree(notes, :major, 5), amp: amp * 0.4, pan: pan + 0.2, release: 2.0  # Chord enhancement
    if fusion > 0.8  # Add more chords for richness
      synth :piano, note: chord(:c4, :major7), amp: amp * 0.3, pan: pan - 0.1, release: 2.0  # Full chord layering
    end
  end
  sleep 4.0 / (BPM_EL / 60.0)
end

live_loop :percussion do
  if variant_index >= VARIANT_COUNT_EL
    stop
  end
  t = current_beat * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.6, 0.05, 0.8)
  pan = S_PAN.call(LANE_PAN_EL.call(t) * -1)
  sample :sn_dub, amp: amp, pan: pan if event_seq[(t.to_i % event_seq.length)] < 0.4 + fusion * 0.3
  sleep 0.5 / (BPM_EL / 60.0)
end

live_loop :fx do
  if variant_index >= VARIANT_COUNT_EL
    stop
  end
  t = current_beat * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  amp = clamp(fusion * 0.5, 0.02, 0.7)
  pan_offset = event_seq[(t.to_i % event_seq.length)] * 0.8 - 0.4
  pan = S_PAN.call(HORIZON_PAN_EL + pan_offset * fusion)
  # FX stacking: nested reverb and echo
  with_fx :reverb, room: 0.9, decay: 2.5 + fusion * 2.5 do
    with_fx :echo, phase: 0.3, decay: 0.6 do
      synth :noise, amp: amp, pan: pan, release: 2.5
    end
  end
  sleep 8.0 / (BPM_EL / 60.0)
end

live_loop :events do
  if variant_index >= VARIANT_COUNT_EL
    stop
  end
  t = current_beat * (60.0 / BPM_EL)
  fusion = get_fusion_el(t) + drift
  threshold = BPM_EL > 130 ? 0.7 : 0.8
  if fusion > threshold && event_subsets[variant_index]
    event_index = (t.to_i / 16) % event_subsets[variant_index].length
    event = event_subsets[variant_index][event_index]
    case event
    when :bd_haus
      pan_offset = event_seq[(t.to_i % event_seq.length)] * 1.0 - 0.5
      sample :bd_haus, amp: clamp(0.6, 0.1, 1.0), pan: S_PAN.call(pan_offset)
    when :sn_dub
      pan_offset = event_seq[(t.to_i % event_seq.length)] * 1.0 - 0.5
      sample :sn_dub, amp: clamp(0.5, 0.1, 1.0), pan: S_PAN.call(pan_offset)
    when :synth_saw
      synth :saw, note: :e4, amp: clamp(0.7, 0.1, 1.0), pan: S_PAN.call(HORIZON_PAN_EL)
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :g4, amp: clamp(0.4, 0.1, 1.0), release: 1.5
      end
    when :amen_fill
      amen_index = (variant_index + t.to_i) % AMEN_POOL.length
      sample AMEN_POOL[amen_index], amp: clamp(0.7, 0.1, 1.0), pan: S_PAN.call(event_seq[(t.to_i % event_seq.length)] * 0.8 - 0.4), rate: 1.0
    # Add more cases as needed
    end
  end
  sleep 16.0 / (BPM_EL / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # DEBUG: Print progress if in DEBUG mode
  if DEBUG
    puts "DEBUG: Starting variant #{variant_index + 1} of #{VARIANT_COUNT_EL}"
  end
  
  # Variant start prompt: unique Synth melody for Progressive Trance with stereo surround and fade-in
  melody_notes = [:c4, :d4, :e4, :f4, :g4]  # Slow ascending melody for highway progression
  melody_notes.each_with_index do |n, i|
    fade_amp = (i + 1) / melody_notes.length.to_f * 0.5  # Fade-in amp
    pan = S_PAN.call(Math.sin(i * PI / 4) * 0.7)
    synth :saw, note: n, amp: fade_amp, release: 0.5, pan: pan  # Saw with gradual amp increase
    sleep 0.3  # Moderate sleep for extended feel
  end
  sleep 0.6  # Prompt end, total ~2 sec
  
  total_seg = SEGMENTS_EL.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 2-sec silence for steady rhythm
  sleep 2.0
  
  variant_index += 1
  drift += 0.01  # Cumulative drift
  stop if variant_index >= VARIANT_COUNT_EL
end