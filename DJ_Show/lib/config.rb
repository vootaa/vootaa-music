# ============================================================
# CONFIGURATION MODULE
# Global settings for Drum Circle DJ Show
# ============================================================

# Performance Parameters
CYCLE_LENGTH = 60          # Seconds per major energy cycle
BASE_BPM = 90             # Beats per minute
SET_VOLUME = 5            # Master volume (1-10)

# Groove/Structure 
BEATS_PER_BAR = 4
BARS_PER_PHRASE = 8             # 8 or 16
MAX_ACTIVE_DRUMMERS = 3         # hard cap at peak
LOOP_SLICE_MODE = :cycle_locked # lock loop params per cycle
LOOP_HPF_CUTOFF = 90            # Hz, free the kick
MELODY_MAX_AMP = 0.6            # never dominate
MELODY_BAR_DENSITY = 0.5        # only ~1/2 bars attempt melody
FILL_ONLY_AT_PHRASE_END = true

# Mathematical Constants
INITIAL_SEED = 65535      # Starting random seed
GOLDEN_RATIO = 1.618033988749

# Mix Parameters
MAX_ACTIVE_DRUMMERS = 3   # Maximum simultaneous drummers
MELODY_DENSITY = 0.4      # 0.0 = rare, 1.0 = constant
FILL_THRESHOLD = 0.15     # Energy delta to trigger fills

# Volume Balance
PULSE_VOLUME = 2.0
DRUMMER_VOLUME = 2.5
LOOP_VOLUME = 1.5
MELODY_VOLUME = 0.6
AMBIENT_VOLUME = 0.3
FILL_VOLUME = 2.5

# Performance Duration
FADE_IN_DUR = 10          # Fade in duration in seconds
FADE_OUT_DUR = 15         # Fade out duration in seconds
PERF_CYCLES = 10          # Total number of cycles to perform

# Debug Mode
DEBUG_MODE = true         # Set to false for production

# ============================================================
# LOOP CONFIGURATION
# ============================================================

# Loop Slicing Patterns (inspired by drums.rb)
LOOP_START_PATTERNS = {
  pattern_a: [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875],  # 16th notes (original)
  pattern_b: [0.0, 0.25, 0.5, 0.75],                               # Quarter notes
  pattern_c: [0.0, 0.333, 0.666],                                  # Triplets
  pattern_d: [0.0, 0.1, 0.3, 0.4, 0.6, 0.8]                       # Irregular (polyrhythmic)
}

# Loop Rate Variations
LOOP_RATES = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

# Loop Sample Pool
LOOP_SAMPLES = [:loop_amen, :loop_compus, :loop_tabla, :loop_safari]

# Loop Beat Stretch Options
LOOP_BEAT_STRETCHES = [4, 8, 16]

# ============================================================
# MELODY CONFIGURATION
# ============================================================

# Melody Note Ranges (MIDI note numbers)
MELODY_NOTE_RANGES = {
  kalimba: (60..72),      # C4 to C5
  piano: (48..72),        # C3 to C5
  beep: (60..84),         # C4 to C6
  pretty_bell: (72..84),  # C5 to C6
  dsaw: (36..60)          # C2 to C4
}

# Melody Rhythm Patterns (beat durations)
MELODY_RHYTHM_PATTERNS = [
  [0.5, 0.5, 1.0],           # Quick-quick-slow
  [1.0, 0.5, 0.5],           # Slow-quick-quick
  [0.75, 0.75, 0.5],         # Dotted rhythm
  [0.333, 0.333, 0.333],     # Triplets
  [1.0, 1.0, 1.0],           # Even quarters
  [0.25, 0.25, 0.5, 1.0]     # Accelerating
]

# Melody Phrase Lengths (number of notes)
MELODY_PHRASE_LENGTHS = [3, 4, 5, 7]

# Melody Activation Chance (probability)
MELODY_ACTIVATION_CHANCE = 3  # one_in(3) = 33% chance

# ============================================================
# FILL CONFIGURATION
# ============================================================

# Fill Type Definitions
FILL_TYPES = {
  tom_roll: {
    samples: [:drum_tom_hi_hard, :drum_tom_mid_hard, :drum_tom_lo_hard],
    duration: 1.0,
    notes: 4,
    sleep_time: 0.25,
    rate_range: (0.9..1.1),
    fx: nil
  },
  cymbal_crash: {
    samples: [:drum_cymbal_open, :drum_splash_hard],
    duration: 2.0,
    notes: 1,
    sleep_time: 2.0,
    rate_range: (0.85..0.95),
    fx: nil
  },
  glitch_burst: {
    samples: [:elec_blip2, :elec_twang, :elec_pop],
    duration: 0.5,
    notes: 3,
    sleep_time: 0.166,
    rate_range: (0.8..1.5),
    fx: :bitcrusher
  },
  snare_roll: {
    samples: [:drum_snare_hard, :elec_mid_snare, :sn_dolf],
    duration: 1.0,
    notes: 6,
    sleep_time: 0.166,
    rate_range: (0.95..1.05),
    fx: nil
  },
  rest: {
    samples: [],
    duration: 1.0,
    notes: 0,
    sleep_time: 1.0,
    rate_range: (1.0..1.0),
    fx: nil
  }
}

# ============================================================
# AMBIENT CONFIGURATION
# ============================================================

# Ambient Sample Pool
AMBIENT_SAMPLES = [:ambi_choir, :ambi_drone, :ambi_lunar_land, :ambi_soft_buzz, :ambi_glass_hum]

# Ambient Energy Threshold
AMBIENT_ENERGY_THRESHOLD = 0.4

# Ambient Sleep Duration
AMBIENT_SLEEP_DURATION = 8

# Ambient Rate Range
AMBIENT_RATE_RANGE = (0.85..1.0)

# ============================================================
# ENERGY CONFIGURATION
# ============================================================

# Energy Category Thresholds
ENERGY_CATEGORIES = [
  { name: "Silence",     range: (0.0...0.1), max_drummers: 0, description: "Pure pulse only" },
  { name: "Intro",       range: (0.1...0.3), max_drummers: 1, description: "Single drummer, sparse" },
  { name: "Development", range: (0.3...0.6), max_drummers: 2, description: "Two drummers, alternating" },
  { name: "Peak",        range: (0.6...0.9), max_drummers: 2, description: "Two drummers, overlapping" },
  { name: "Climax",      range: (0.9..1.0),  max_drummers: 3, description: "Three drummers + fills" }
]

# ============================================================
# PULSE CONFIGURATION
# ============================================================

# Pulse Samples
PULSE_SAMPLES = [:bd_fat, :bd_haus]

# Pulse Sleep Time
PULSE_SLEEP_TIME = 1

# ============================================================
# DRUMMER CONFIGURATION
# ============================================================

# Drummer Panning
DRUMMER_PANS = {
  'A' => -0.6,  # West African - Left
  'B' => -0.2,  # Indian - Center-Left
  'C' => 0.2,   # Latin - Center-Right
  'D' => 0.6    # Electronic - Right
}

# Drummer Default Sleep (when not playing)
DRUMMER_REST_SLEEP = 2

# ============================================================
# SAMPLE VOLUME CALIBRATION
# ============================================================

# Sample Volume Calibration
# (Normalized based on actual sample loudness)
SAMPLE_VOLUMES = {
  # Kick drums (generally loud, reduce slightly)
  bd_fat: 0.9,
  bd_haus: 1.0,
  bd_808: 1.1,
  
  # Toms (balanced)
  drum_tom_hi_hard: 1.0,
  drum_tom_mid_hard: 1.0,
  drum_tom_lo_hard: 1.0,
  
  # Snares (can be sharp, moderate)
  drum_snare_hard: 0.95,
  drum_snare_soft: 1.0,
  sn_dolf: 0.9,
  
  # Cymbals (often too loud, reduce)
  drum_cymbal_open: 0.7,
  drum_splash_hard: 0.75,
  drum_cymbal_closed: 0.8,
  
  # Tabla (quiet, boost significantly)
  tabla_tas1: 1.5,
  tabla_tas2: 1.5,
  tabla_tas3: 1.5,
  tabla_ke1: 1.4,
  tabla_ke2: 1.4,
  tabla_ke3: 1.4,
  tabla_na: 1.6,
  tabla_te1: 1.5,
  tabla_te2: 1.5,
  tabla_te_ne: 1.5,
  tabla_tun1: 1.4,
  tabla_tun2: 1.4,
  tabla_tun3: 1.4,
  tabla_re: 1.5,
  tabla_ghe1: 1.4,
  tabla_ghe2: 1.4,
  tabla_ghe3: 1.4,
  tabla_ghe4: 1.4,
  tabla_ghe5: 1.4,
  tabla_ghe6: 1.4,
  tabla_ghe7: 1.4,
  tabla_ghe8: 1.4,
  tabla_dhec: 1.5,
  
  # Percussion (vary widely)
  perc_bell: 1.2,
  perc_snap: 1.3,
  drum_cowbell: 0.8,
  elec_bong: 1.1,
  
  # Electronic (generally well-balanced)
  elec_triangle: 1.0,
  elec_blip: 1.1,
  elec_blip2: 1.0,
  elec_twang: 1.0,
  elec_pop: 1.2,
  elec_mid_snare: 1.0,
  elec_hi_snare: 0.9,
  elec_lo_snare: 1.1,
  
  # Loops (background, keep moderate)
  loop_amen: 0.8,
  loop_compus: 0.9,
  loop_tabla: 1.0,
  loop_safari: 0.85,
  
  # Ambient (very quiet, boost significantly)
  ambi_choir: 1.8,
  ambi_drone: 1.6,
  ambi_lunar_land: 1.7,
  ambi_soft_buzz: 1.5,
  ambi_glass_hum: 1.6
}

# ============================================================
# HELPER FUNCTIONS
# ============================================================

# Get calibrated volume for sample
def get_sample_volume(sample_name)
  SAMPLE_VOLUMES[sample_name.to_sym] || 1.0
end

# ============================================================
# EXPORT CONFIGURATION
# ============================================================

# Export all config as a hash for easy passing
def get_performance_config
  {
    # Core settings
    initial_seed: INITIAL_SEED,
    base_bpm: BASE_BPM,
    set_volume: SET_VOLUME,
    cycle_length: CYCLE_LENGTH,
    golden_ratio: GOLDEN_RATIO,
    debug_mode: DEBUG_MODE,
    
    # Performance
    fade_in_dur: FADE_IN_DUR,
    fade_out_dur: FADE_OUT_DUR,
    perf_cycles: PERF_CYCLES,
    
    # Volume levels
    pulse_volume: PULSE_VOLUME,
    drummer_volume: DRUMMER_VOLUME,
    loop_volume: LOOP_VOLUME,
    melody_volume: MELODY_VOLUME,
    ambient_volume: AMBIENT_VOLUME,
    fill_volume: FILL_VOLUME,
    
    # Loop configuration
    loop_start_patterns: LOOP_START_PATTERNS,
    loop_rates: LOOP_RATES,
    loop_samples: LOOP_SAMPLES,
    loop_beat_stretches: LOOP_BEAT_STRETCHES,
    
    # Melody configuration
    melody_note_ranges: MELODY_NOTE_RANGES,
    melody_rhythm_patterns: MELODY_RHYTHM_PATTERNS,
    melody_phrase_lengths: MELODY_PHRASE_LENGTHS,
    melody_activation_chance: MELODY_ACTIVATION_CHANCE,
    
    # Fill configuration
    fill_types: FILL_TYPES,
    fill_threshold: FILL_THRESHOLD,
    
    # Ambient configuration
    ambient_samples: AMBIENT_SAMPLES,
    ambient_energy_threshold: AMBIENT_ENERGY_THRESHOLD,
    ambient_sleep_duration: AMBIENT_SLEEP_DURATION,
    ambient_rate_range: AMBIENT_RATE_RANGE,
    
    # Energy categories
    energy_categories: ENERGY_CATEGORIES,
    
    # Pulse configuration
    pulse_samples: PULSE_SAMPLES,
    pulse_sleep_time: PULSE_SLEEP_TIME,
    
    # Drummer configuration
    drummer_pans: DRUMMER_PANS,
    drummer_rest_sleep: DRUMMER_REST_SLEEP,
    
    # Sample volumes
    sample_volumes: SAMPLE_VOLUMES,
    
    # Mix parameters
    max_active_drummers: MAX_ACTIVE_DRUMMERS
  }
end