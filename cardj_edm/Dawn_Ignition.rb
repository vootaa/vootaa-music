# Dawn Ignition - Sonic Pi Code for CarDJ_EDM
# Load shared constants from cdec.rb
load "/Users/tsb/Pop-Proj/vootaa-music/cardj_edm/cdec.rb"

# Dawn Ignition specific constants
BPM = 128
TOTAL_TIME = 1500  # 25 minutes in seconds
SEGMENTS = { intro: 300, drive: 600, peak: 400, outro: 200 }  # Segment durations in seconds

# Energy engine parameters
VELOCITY_BASE = 0.5
INTENSITY_BASE = 0.3
FUSION_MAX = 1.0

# Stereo mapping
LANE_PAN = lambda { |t| Math.sin(t * PI / 10) * 0.3 }  # Oscillating pan for lane feel
HORIZON_PAN = 0.5  # Wide spread for horizon
VELOCITY_PAN_OFFSET = 0.1

# Utility functions
def clamp(val, min, max)
  [min, [val, max].min].max
end

def get_fusion(t)
  # Fusion based on time: gradual increase with segments
  if t < SEGMENTS[:intro]
    clamp(VELOCITY_BASE + (t / SEGMENTS[:intro]) * 0.3, 0, 0.6)
  elsif t < SEGMENTS[:intro] + SEGMENTS[:drive]
    clamp(0.6 + ((t - SEGMENTS[:intro]) / SEGMENTS[:drive]) * 0.4, 0.6, 1.0)
  elsif t < SEGMENTS[:intro] + SEGMENTS[:drive] + SEGMENTS[:peak]
    1.0
  else
    clamp(1.0 - ((t - (SEGMENTS[:intro] + SEGMENTS[:drive] + SEGMENTS[:peak])) / SEGMENTS[:outro]), 0, 1.0)
  end
end

def get_md_sequence(constant, length)
  # Extract sequence from MD hash for pseudo-randomness
  seq = MD[constant.to_sym].chars.map(&:to_i).take(length)
  seq.map { |d| d / 10.0 }  # Normalize to 0-1
end

# Initialize sequences
kick_seq = get_md_sequence("golden", 100)
bass_seq = get_md_sequence("pi", 100)
melody_seq = get_md_sequence("e", 200)

# Live loops
live_loop :kick do
  t = current_beat * (60.0 / BPM)
  fusion = get_fusion(t)
  amp = clamp(fusion * 0.8, 0.1, 1.0)
  pan = LANE_PAN.call(t) + VELOCITY_PAN_OFFSET * fusion
  sample :bd_haus, amp: amp, pan: pan
  sleep 1.0 / (BPM / 60.0)  # Basic kick at BPM
end

live_loop :bass do
  t = current_beat * (60.0 / BPM)
  fusion = get_fusion(t)
  amp = clamp(fusion * 0.6, 0.05, 0.8)
  pan = 0  # Center for low freq
  note = scale(:c2, :minor_pentatonic)[(melody_seq[(t.to_i % melody_seq.length)] * 7).to_i]
  synth :saw, note: note, amp: amp, pan: pan, release: 0.5
  sleep 2.0 / (BPM / 60.0)
end

live_loop :melody do
  t = current_beat * (60.0 / BPM)
  fusion = get_fusion(t)
  amp = clamp(fusion * 0.7, 0.1, 0.9)
  pan = HORIZON_PAN + LANE_PAN.call(t) * 0.2
  notes = scale(:c4, :major)[(kick_seq[(t.to_i % kick_seq.length)] * 7).to_i]
  synth :piano, note: notes, amp: amp, pan: pan, release: 1.0
  sleep 4.0 / (BPM / 60.0)
end

live_loop :percussion do
  t = current_beat * (60.0 / BPM)
  fusion = get_fusion(t)
  amp = clamp(fusion * 0.5, 0.05, 0.7)
  pan = LANE_PAN.call(t) * -1  # Opposite for stereo
  sample :sn_dub, amp: amp, pan: pan if rand < 0.3 + fusion * 0.4
  sleep 0.5 / (BPM / 60.0)
end

live_loop :fx do
  t = current_beat * (60.0 / BPM)
  fusion = get_fusion(t)
  amp = clamp(fusion * 0.4, 0.02, 0.6)
  pan = HORIZON_PAN + rand(-0.5..0.5) * fusion
  synth :noise, amp: amp, pan: pan, release: 2.0
  sleep 8.0 / (BPM / 60.0)
end

# Stop after total time
sleep TOTAL_TIME
stop