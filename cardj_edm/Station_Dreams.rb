# Station Dreams - Sonic Pi Code for CarDJ_EDM
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion_sd(t)
  if t < SEGMENTS_SD[:intro]
    clamp(VEL_BASE_SD + (t / SEGMENTS_SD[:intro]) * 0.1, 0, 0.3)
  elsif t < SEGMENTS_SD[:intro] + SEGMENTS_SD[:drive]
    clamp(0.3 + ((t - SEGMENTS_SD[:intro]) / SEGMENTS_SD[:drive]) * 0.4, 0.3, 0.7)
  elsif t < SEGMENTS_SD[:intro] + SEGMENTS_SD[:drive] + SEGMENTS_SD[:peak]
    0.7
  else
    clamp(0.7 - ((t - (SEGMENTS_SD[:intro] + SEGMENTS_SD[:drive] + SEGMENTS_SD[:peak])) / SEGMENTS_SD[:outro]), 0, 0.7)
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
event_seq = get_md_seq("sqrt2", EVENT_POOL_SD.length)
variant_index = 0
drift = 0
event_subsets = []
subset_size = (EVENT_POOL_SD.length / VARIANT_COUNT_SD).to_i
VARIANT_COUNT_SD.times do |i|
  start = i * subset_size
  event_subsets << EVENT_POOL_SD[start...(start + subset_size)]
end

# Live loops with variant evolution
live_loop :kick do
  t = current_beat * (60.0 / BPM_SD)
  fusion = get_fusion_sd(t) + drift
  amp = clamp(fusion * 0.5, 0.05, 0.7)
  pan = LANE_PAN_SD.call(t) + VEL_PAN_OFF_SD * fusion
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM_SD / 60.0)
end

live_loop :bass do
  t = current_beat * (60.0 / BPM_SD)
  fusion = get_fusion_sd(t) + drift
  amp = clamp(fusion * 0.4, 0.02, 0.6)
  pan = 0
  note = scale(:c2, :minor)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i]
  synth :saw, note: note, amp: amp, pan: pan, release: 0.7
  sleep 2.0 / (BPM_SD / 60.0)
end

live_loop :melody do
  t = current_beat * (60.0 / BPM_SD)
  fusion = get_fusion_sd(t) + drift
  amp = clamp(fusion * 0.8, 0.1, 0.9)
  pan = HORIZON_PAN_SD + LANE_PAN_SD.call(t) * 0.1
  notes = scale(:c4, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i]
  synth :saw, note: notes, amp: amp, pan: pan, release: 1.5  # Pad for chillout space
  sleep 4.0 / (BPM_SD / 60.0)
end

live_loop :percussion do
  t = current_beat * (60.0 / BPM_SD)
  fusion = get_fusion_sd(t) + drift
  amp = clamp(fusion * 0.3, 0.02, 0.5)
  pan = LANE_PAN_SD.call(t) * -1
  sample :sn_dub, amp: amp, pan: pan if rand < 0.2 + fusion * 0.3
  sleep 0.5 / (BPM_SD / 60.0)
end

live_loop :fx do
  t = current_beat * (60.0 / BPM_SD)
  fusion = get_fusion_sd(t) + drift
  amp = clamp(fusion * 0.7, 0.02, 0.9)
  pan = HORIZON_PAN_SD + rand(-0.5..0.5) * fusion
  with_fx :reverb, room: 0.98 do
    synth :noise, amp: amp, pan: pan, release: 4.0  # Heavy reverb for restful ambiance
  end
  sleep 8.0 / (BPM_SD / 60.0)
end

live_loop :events do
  t = current_beat * (60.0 / BPM_SD)
  fusion = get_fusion_sd(t) + drift
  if fusion > 0.5 && event_subsets[variant_index]
    event = event_subsets[variant_index].sample
    case event
    when :bd_haus
      sample :bd_haus, amp: 0.4, pan: rand(-0.5..0.5)
    when :sn_dub
      sample :sn_dub, amp: 0.3, pan: rand(-0.5..0.5)
    when :synth_pad
      synth :saw, note: :d4, amp: 0.7, pan: HORIZON_PAN_SD
    when :fx_reverb
      with_fx :reverb do
        synth :saw, note: :f4, amp: 0.4, release: 1.8
      end
    when :amen_fill
      sample AMEN_POOL.sample, amp: 0.5, pan: rand(-0.2..0.2), rate: 0.8  # Slower rate for chill
    # Add more cases as needed
    end
  end
  sleep 16.0 / (BPM_SD / 60.0)
end

# Variant control with prompt and breathing gap
live_loop :variant_ctrl do
  # Variant start prompt: unique Synth melody for Chillout with stereo surround
  melody_notes = [:c4, :g4, :e4, :a4]  # Gentle arpeggio for restful dreams
  melody_notes.each_with_index do |n, i|
    pan = Math.sin(i * PI / 2) * 0.6  # Stereo surround: soft left-right sweep
    synth :saw, note: n, amp: 0.3 + i * 0.05, release: 0.8, pan: pan  # Pad with subtle amp increase
    sleep 0.4  # Slower sleep for relaxed feel
  end
  sleep 0.8  # Prompt end, total ~2.2 sec
  
  total_seg = SEGMENTS_SD.values.sum
  sleep total_seg  # Play variant
  
  # Breathing gap: 2.5-sec silence for chill rhythm
  sleep 2.5
  
  variant_index += 1
  drift = Math.sin(variant_index * PI / VARIANT_COUNT_SD) * 0.05
  stop if variant_index >= VARIANT_COUNT_SD
end