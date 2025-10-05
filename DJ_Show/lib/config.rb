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

# Performance Duration
FADE_IN_DUR = 10          # Fade in duration in seconds
FADE_OUT_DUR = 15         # Fade out duration in seconds
PERF_CYCLES = 10          # Total number of cycles to perform

# Debug Mode
DEBUG_MODE = true         # Set to false for production

# Drummer Panning
DRUMMER_PANS = {
  'A' => -0.6,  # West African - Left
  'B' => -0.2,  # Indian - Center-Left
  'C' => 0.2,   # Latin - Center-Right
  'D' => 0.6    # Electronic - Right
}

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
  SAMPLE_VOLUMES[sample_name] || 1.0
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
    
    # Panning and volumes
    drummer_pans: DRUMMER_PANS,
    sample_volumes: SAMPLE_VOLUMES,
    
    # Thresholds
    fill_threshold: FILL_THRESHOLD
  }
end