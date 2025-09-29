# Urban Velocity - Sonic Pi Code for CarDJ_EDM
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion_uv(t)
  if t < SEGMENTS_UV[:intro]
    clamp(VEL_BASE_UV + (t / SEGMENTS_UV[:intro]) * 0.4, 0, 0.7)
  elsif t < SEGMENTS_UV[:intro] + SEGMENTS_UV[:drive]
    clamp(0.7 + ((t - SEGMENTS_UV[:intro]) / SEGMENTS_UV[:drive]) * 0.3, 0.7, 1.0)
  elsif t < SEGMENTS_UV[:intro] + SEGMENTS_UV[:drive] + SEGMENTS_UV[:peak]
    1.0
  else
    clamp(1.0 - ((t - (SEGMENTS_UV[:intro] + SEGMENTS_UV[:drive] + SEGMENTS_UV[:peak])) / SEGMENTS_UV[:outro]), 0, 1.0)
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
event_seq = get_md_seq("sqrt2", EVENT_POOL_UV.length)

# Initialize sequences and variant logic
variant_index = 0
drift = 0
event_subsets = []
subset_size = (EVENT_POOL_UV.length / VARIANT_COUNT_UV).to_i
VARIANT_COUNT_UV.times do |i|
  start = i * subset_size
  event_subsets << EVENT_POOL_UV[start...(start + subset_size)]
end

# Live loops with variant evolution
live_loop :kick do
  t = current_beat * (60.0 / BPM_UV)
  fusion = get_fusion_uv(t) + drift
  amp = clamp(fusion * 1.0, 0.2, 1.0)  # Stronger kick for energy
  pan = S_PAN.call(LANE_PAN_UV.call(t) + VEL_PAN_OFF_UV * fusion)
  sample :bd_tek, amp: amp, pan: pan  # Tekno kick for Electro House
  sleep 1.0 / (BPM_UV / 60.0)
end

live_loop :bass do
  t = current_beat * (60.0 / BPM_UV)
  fusion = get_fusion_uv(t) + drift
  amp = clamp(fusion * 0.8, 0.1, 0.9)
  pan = 0
  note = scale(:c2, :minor)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i]
  synth :saw, note: note, amp: amp, pan: pan, release: 0.3  # Shorter release for punchy bass
  sleep 1.0 / (BPM_UV / 60.0)  # Faster bass for intensity
end

live_loop :melody do
  t = current_beat * (60.0 / BPM_UV)
  fusion = get_fusion_uv(t) + drift
  amp = clamp(fusion * 0.9, 0.2, 1.0)
  pan = S_PAN.call(HORIZON_PAN_UV + LANE_PAN_UV.call(t) * 0.3)
  notes = scale(:c5, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i]
  # Pad layering: multiple synths for harmony
  synth :pluck, note: notes, amp: amp, pan: pan, release: 0.2  # Pluck for staccato Electro feel
  if fusion > 0.6
    synth :saw, note: chord_degree(notes, :major, 4), amp: amp * 0.6, pan: pan - 0.1, release: 0.5  # Chord enhancement
  end
  sleep 2.0 / (BPM_UV / 60.0)
end

live_loop :percussion do
  t = current_beat * (60.0 / BPM_UV)
  fusion = get_fusion_uv(t) + drift
  amp = clamp(fusion * 0.7, 0.1, 0.8)
  pan = S_PAN.call(LANE_PAN_UV.call(t) * -1)
  sample :sn_dub, amp: amp, pan: pan if rand < 0.5 + fusion * 0.5  # More frequent snares
  sleep 0.5 / (BPM_UV / 60.0)
end

live_loop :fx do
  t = current_beat * (60.0 / BPM_UV)
  fusion = get_fusion_uv(t) + drift
  amp = clamp(fusion * 0.3, 0.05, 0.5)
  pan = S_PAN.call(HORIZON_PAN_UV + rand(-0.6..0.6) * fusion)
  # FX stacking: nested reverb and echo
  with_fx :reverb, room: 0.8, decay: 1.5 + fusion * 1.5 do
    with_fx :echo, phase: 0.2, decay: 0.4 do
      synth :noise, amp: amp, pan: pan, release: 1.5  # Added reverb for Big Room space
    end
  end
  sleep 4.0 / (BPM_UV / 60.0)
end

live_loop :events do
  t = current_beat * (60.0 / BPM_UV)
  fusion = get_fusion_uv(t) + drift
  threshold = BPM_UV > 130 ? 0.5 : 0.6
  if fusion > threshold && event_subsets[variant_index]
    event = event_subsets[variant_index].sample
    case event
    when :bd_tek
      sample :bd_tek, amp: clamp(0.7, 0.1, 1.0), pan: S_PAN.call(rand(-0.5..0.5))
    when :sn_dub
      sample :sn_dub, amp: clamp(0.5, 0.1, 1.0), pan: S_PAN.call(rand(-0.5..0.5))
    when :synth_pluck
      synth :pluck, note: :d5, amp: clamp(0.8, 0.1, 1.0), pan: S_PAN.call(HORIZON_PAN_UV)
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :f4, amp: clamp(0.4, 0.1, 1.0), release: 0.8
      end
    when :amen_fill
      sample AMEN_POOL.sample, amp: clamp(0.7, 0.1, 1.0), pan: S_PAN.call(rand(-0.4..0.4)), rate: 1.2  # Faster rate for energy
    # Add more cases as needed
    end
  end
  sleep 8.0 / (BPM_UV / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # Variant start prompt: unique Synth melody for Electro House with stereo surround and fade-in
  melody_notes = [:c5, :d5, :e5, :f5]  # Sharp ascending melody for Big Room energy
  melody_notes.each_with_index do |n, i|
    fade_amp = (i + 1) / melody_notes.length.to_f * 0.6  # Fade-in amp
    pan = S_PAN.call(Math.sin(i * PI / 2) * 0.8)
    synth :pluck, note: n, amp: fade_amp, release: 0.2, pan: pan  # Quick pluck with increasing amp
    sleep 0.15  # Shorter sleep for fast-paced feel
  end
  sleep 0.4  # Prompt end, total ~1 sec
  
  total_seg = SEGMENTS_UV.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 1.5-sec silence for fast rhythm
  sleep 1.5
  
  variant_index += 1
  drift += 0.02  # Cumulative drift
  stop if variant_index >= VARIANT_COUNT_UV
end