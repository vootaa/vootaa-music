# ============================================================
# CONFIGURATION MODULE
# Global settings for Drum Circle DJ Show
# ============================================================

# Performance Parameters
CYCLE_LENGTH = 60          # Seconds per major energy cycle
BASE_BPM = 90             # Beats per minute
SET_VOLUME = 5            # Master volume (1-10)

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

# Debug Mode
DEBUG_MODE = false        # Set true to see energy/state logs

# ============================================================
# SAMPLE VOLUME CALIBRATION
# Normalize volumes so all samples sound balanced
# ============================================================

SAMPLE_VOLUME_MAP = {
  # Bass drums (naturally loud, reduce)
  bd_haus: 0.7,
  bd_fat: 0.7,
  bd_808: 0.8,
  bd_boom: 0.6,
  
  # Toms (medium, slight boost)
  drum_tom_hi_hard: 1.1,
  drum_tom_hi_soft: 1.3,
  drum_tom_mid_hard: 1.0,
  drum_tom_mid_soft: 1.2,
  drum_tom_lo_hard: 0.9,
  drum_tom_lo_soft: 1.1,
  
  # Snares (can be piercing, moderate)
  drum_snare_hard: 0.9,
  drum_snare_soft: 1.1,
  
  # Cymbals (very loud, reduce significantly)
  drum_cymbal_open: 0.5,
  drum_cymbal_closed: 0.8,
  drum_cymbal_pedal: 0.7,
  drum_cymbal_hard: 0.6,
  drum_cymbal_soft: 0.8,
  drum_splash_hard: 0.6,
  drum_splash_soft: 0.9,
  
  # Percussion (boost quiet ones)
  perc_bell: 1.2,
  perc_bell2: 1.3,
  perc_snap: 1.4,
  perc_snap2: 1.3,
  drum_cowbell: 1.0,
  
  # Electronic (variable, normalize)
  elec_bong: 1.1,
  elec_blip: 1.3,
  elec_blip2: 1.2,
  elec_ping: 1.1,
  elec_tick: 1.4,
  elec_mid_snare: 1.0,
  elec_hi_snare: 0.9,
  elec_lo_snare: 1.1,
  elec_pop: 1.2,
  elec_twang: 1.0,
  
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
  ambi_glass_hum: 1.6,
  
  # Synths (adjust in use_synth, not here)
  # kalimba, piano, beep, dsaw handled separately
}

# Get calibrated volume for sample
def get_sample_volume(sample_name)
  SAMPLE_VOLUME_MAP.fetch(sample_name, 1.0)
end

# ============================================================
# STEREO POSITIONING
# Fixed pan positions for each drummer
# ============================================================

DRUMMER_PAN_POSITIONS = {
  "A" => -0.6,   # West African - Left
  "B" => 0.6,    # Indian - Right
  "C" => -0.3,   # Latin - Center-Left
  "D" => 0.3     # Electronic - Center-Right
}

# Get drummer's pan position
def get_drummer_pan(drummer_id)
  DRUMMER_PAN_POSITIONS.fetch(drummer_id, 0.0)
end

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
    
    # Panning and volumes
    drummer_pans: DRUMMER_PANS,
    sample_volumes: SAMPLE_VOLUMES,
    
    # Thresholds
    fill_threshold: FILL_THRESHOLD
  }
end