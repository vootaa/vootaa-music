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

# Initialize sequences and variant logic
kick_seq = get_md_seq("golden", 100)
bass_seq = get_md_seq("pi", 100)
melody_seq = get_md_seq("e", 200)
event_seq = get_md_seq("pi", EVENT_POOL_DI.length)
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
  pan = LANE_PAN_DI.call(t) + VEL_PAN_OFF_DI * fusion
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM_DI / 60.0)
end

live_loop :bass do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.6, 0.05, 0.8)
  pan = 0
  note = scale(:c2, :minor_pentatonic)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i]
  synth :saw, note: note, amp: amp, pan: pan, release: 0.5
  sleep 2.0 / (BPM_DI / 60.0)
end

live_loop :melody do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.7, 0.1, 0.9)
  pan = HORIZON_PAN_DI + LANE_PAN_DI.call(t) * 0.2
  notes = scale(:c4, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i]
  synth :piano, note: notes, amp: amp, pan: pan, release: 1.0
  sleep 4.0 / (BPM_DI / 60.0)
end

live_loop :percussion do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.5, 0.05, 0.7)
  pan = LANE_PAN_DI.call(t) * -1
  sample :sn_dub, amp: amp, pan: pan if rand < 0.3 + fusion * 0.4
  sleep 0.5 / (BPM_DI / 60.0)
end

live_loop :fx do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  amp = clamp(fusion * 0.4, 0.02, 0.6)
  pan = HORIZON_PAN_DI + rand(-0.5..0.5) * fusion
  synth :noise, amp: amp, pan: pan, release: 2.0
  sleep 8.0 / (BPM_DI / 60.0)
end

live_loop :events do
  t = current_beat * (60.0 / BPM_DI)
  fusion = get_fusion(t) + drift
  if fusion > 0.7 && event_subsets[variant_index]
    event = event_subsets[variant_index].sample
    case event
    when :bd_haus
      sample :bd_haus, amp: 0.5, pan: rand(-0.5..0.5)
    when :sn_dub
      sample :sn_dub, amp: 0.4, pan: rand(-0.5..0.5)
    when :synth_piano
      synth :piano, note: :c5, amp: 0.6, pan: HORIZON_PAN_DI
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :e4, amp: 0.3, release: 1.0
      end
    when :amen_fill
      sample AMEN_POOL.sample, amp: 0.6, pan: rand(-0.3..0.3), rate: 1.0  # External WAV for rhythmic fill
    # Add more cases as needed
    end
  end
  sleep 16.0 / (BPM_DI / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # Variant start prompt: unique Synth melody for House with stereo surround
  melody_notes = [:c4, :e4, :g4, :c5]  # Gentle ascending melody for House style
  melody_notes.each_with_index do |n, i|
    pan = Math.sin(i * PI / 3) * 0.6  # Stereo surround: smooth left-right sweep
    synth :piano, note: n, amp: 0.4 + i * 0.1, release: 0.4, pan: pan  # Piano with fade-in amp
    sleep 0.25  # Moderate sleep for gradual feel
  end
  sleep 0.5  # Prompt end, total ~1.5 sec
  
  total_seg = SEGMENTS_DI.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 2-sec silence for rhythm
  sleep 2.0
  
  variant_index += 1
  drift = Math.sin(variant_index * PI / VARIANT_COUNT_DI) * 0.1
  stop if variant_index >= VARIANT_COUNT_DI
end