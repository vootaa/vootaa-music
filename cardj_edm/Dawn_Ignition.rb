# Dawn Ignition - Sonic Pi Code for CarDJ_EDM
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion(t)
  if t < SEGMENTS_DI[:intro]
    clamp(VEL_BASE_DI + (t / SEGMENTS_DI[:intro]) * 0.3, 0, 0.6)
  elsif t < SEGMENTS_DI[:intro] + SEGMENTS_DI[:drive]
    clamp(0.6 + ((t - SEGMENTS_DI[:intro]) / SEGMENTS_DI[:drive]) * 0.4, 0.6, 1.0)
  elsif t < SEGMENTS_DI[:intro] + SEGMENTS_DI[:drive] + SEGMENTS_DI[:peak]
    1.0
  else
    clamp(1.0 - ((t - (SEGMENTS_DI[:intro] + SEGMENTS_DI[:drive] + SEGMENTS_DI[:peak])) / SEGMENTS_DI[:outro]), 0, 1.0)
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
event_seq = get_md_seq("pi", EVENT_POOL_DI.length)

# Initialize sequences and variant logic
variant_index = 0
drift = 0
event_subsets = []
subset_size = (EVENT_POOL_DI.length / VARIANT_COUNT_DI).to_i
VARIANT_COUNT_DI.times do |i|
  start = i * subset_size
  event_subsets << EVENT_POOL_DI[start...(start + subset_size)]
end

# Live loops with variant evolution
live_loop :kick do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.8, 0.1, 1.0)
  pan = S_PAN.call(LANE_PAN_DI.call(t) + VEL_PAN_OFF_DI * fusion)
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM_DI / 60.0)
end

live_loop :bass do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.6, 0.05, 0.8)
  pan = 0  # Low freq centered
  note = scale(:c2, :minor_pentatonic)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i]
  synth :saw, note: note, amp: amp, pan: pan, release: 0.5
  sleep 2.0 / (BPM_DI / 60.0)
end

live_loop :melody do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.7, 0.1, 0.9)
  pan = S_PAN.call(HORIZON_PAN_DI + LANE_PAN_DI.call(t) * 0.2)
  notes = scale(:c4, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i]
  # Pad layering: multiple synths for harmony
  synth :piano, note: notes, amp: amp, pan: pan, release: 1.0
  if fusion > 0.5
    synth :saw, note: chord_degree(notes, :major, 3), amp: amp * 0.5, pan: pan + 0.1, release: 1.5  # Chord enhancement
  end
  sleep 4.0 / (BPM_DI / 60.0)
end

live_loop :percussion do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.5, 0.05, 0.7)
  pan = S_PAN.call(LANE_PAN_DI.call(t) * -1)
  sample :sn_dub, amp: amp, pan: pan if rand < 0.3 + fusion * 0.4  # Decorative rand for variation
  sleep 0.5 / (BPM_DI / 60.0)
end

live_loop :fx do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.4, 0.02, 0.6)
  pan = S_PAN.call(HORIZON_PAN_DI + rand(-0.5..0.5) * fusion)  # Decorative rand
  # FX stacking: nested reverb and echo
  with_fx :reverb, room: 0.8, decay: 2.0 + fusion * 2.0 do
    with_fx :echo, phase: 0.25, decay: 0.5 do
      synth :noise, amp: amp, pan: pan, release: 2.0
    end
  end
  sleep 8.0 / (BPM_DI / 60.0)
end

live_loop :events do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  threshold = BPM_DI > 130 ? 0.6 : 0.7  # Velocity-based threshold
  if fusion > threshold && event_subsets[variant_index]
    event = event_subsets[variant_index].sample
    case event
    when :bd_haus
      sample :bd_haus, amp: clamp(0.5, 0.1, 1.0), pan: S_PAN.call(rand(-0.5..0.5))
    when :sn_dub
      sample :sn_dub, amp: clamp(0.4, 0.1, 1.0), pan: S_PAN.call(rand(-0.5..0.5))
    when :synth_piano
      synth :piano, note: :c5, amp: clamp(0.6, 0.1, 1.0), pan: S_PAN.call(HORIZON_PAN_DI)
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :e4, amp: clamp(0.3, 0.1, 1.0), release: 1.0
      end
    when :amen_fill
      sample AMEN_POOL.sample, amp: clamp(0.6, 0.1, 1.0), pan: S_PAN.call(rand(-0.3..0.3)), rate: 1.0
    # Add more cases as needed
    end
  end
  sleep 16.0 / (BPM_DI / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # Variant start prompt: unique Synth melody for House with stereo surround and fade-in
  melody_notes = [:c4, :e4, :g4, :c5]
  melody_notes.each_with_index do |n, i|
    fade_amp = (i + 1) / melody_notes.length.to_f * 0.4  # Fade-in amp
    pan = S_PAN.call(Math.sin(i * PI / 3) * 0.6)
    synth :piano, note: n, amp: fade_amp, release: 0.4, pan: pan
    sleep 0.25
  end
  sleep 0.5  # Prompt end, total ~1.5 sec
  
  total_seg = SEGMENTS_DI.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 2-sec silence for rhythm
  sleep 2.0
  
  variant_index += 1
  drift += 0.01  # Cumulative drift
  stop if variant_index >= VARIANT_COUNT_DI
end