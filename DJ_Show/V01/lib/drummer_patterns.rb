# ============================================================
# DRUMMER PATTERNS LIBRARY
# 48 percussion patterns across 4 cultural styles
# NOTE: pan: 0 is placeholder, actual pan set at playback
# ============================================================

class DrummerPatterns
  
  # Pattern data structure:
  # {
  #   beats: [{time: 0.0, sample: :bd_haus, amp: 3.0, rate: 1.0, pan: 0, pan: 0}, ...],
  #   duration: 2.0,
  #   breathe: 0.5
  # }
  
  PATTERNS = {
    
    # ========== DRUMMER A: WEST AFRICAN (Djembe) ==========
    "A" => [
      # Basic patterns
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 3.0, pan: 0, pan: 0},
          {time: 0.5, sample: :drum_tom_mid_hard, amp: 2.0, pan: 0, pan: 0},
          {time: 1.0, sample: :bd_haus, amp: 3.5, pan: 0, pan: 0},
          {time: 1.5, sample: :drum_tom_hi_soft, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_fat, amp: 3.0, pan: 0, pan: 0},
          {time: 0.75, sample: :drum_tom_lo_hard, amp: 2.5, pan: 0, pan: 0},
          {time: 1.5, sample: :perc_bell, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 3.0, pan: 0, pan: 0},
          {time: 0.5, sample: :drum_tom_mid_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 1.0, sample: :drum_tom_lo_hard, amp: 2.5, pan: 0, pan: 0},
          {time: 1.5, sample: :bd_fat, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 3.5, pan: 0, pan: 0},
          {time: 1.0, sample: :bd_haus, amp: 3.0, pan: 0, pan: 0},
          {time: 1.5, sample: :drum_tom_hi_hard, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Syncopated patterns
      {
        beats: [
          {time: 0.0, sample: :bd_fat, amp: 3.0, pan: 0, pan: 0},
          {time: 0.375, sample: :drum_tom_mid_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 0.75, sample: :drum_tom_hi_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 1.25, sample: :bd_haus, amp: 2.5, pan: 0, pan: 0},
          {time: 1.75, sample: :perc_bell, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 3.0, pan: 0, pan: 0},
          {time: 0.5, sample: :drum_tom_lo_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 1.0, sample: :perc_bell, amp: 2.5, pan: 0, pan: 0},
          {time: 1.5, sample: :drum_tom_mid_hard, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :bd_fat, amp: 3.5, pan: 0, pan: 0},
          {time: 0.625, sample: :drum_tom_hi_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 1.125, sample: :drum_tom_lo_hard, amp: 2.5, pan: 0, pan: 0},
          {time: 1.75, sample: :bd_haus, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 3.0, pan: 0, pan: 0},
          {time: 0.25, sample: :drum_tom_mid_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 0.75, sample: :drum_tom_hi_soft, amp: 1.5, pan: 0, pan: 0},
          {time: 1.5, sample: :bd_fat, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Intensive patterns
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 3.5, pan: 0},
          {time: 0.25, sample: :drum_tom_lo_hard, amp: 2.0, pan: 0},
          {time: 0.5, sample: :drum_tom_mid_hard, amp: 2.0, pan: 0},
          {time: 0.75, sample: :drum_tom_hi_hard, amp: 2.0, pan: 0},
          {time: 1.0, sample: :bd_fat, amp: 3.0, pan: 0},
          {time: 1.5, sample: :perc_bell, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :bd_fat, amp: 3.5, pan: 0},
          {time: 0.333, sample: :drum_tom_mid_hard, amp: 2.5, pan: 0},
          {time: 0.666, sample: :drum_tom_hi_hard, amp: 2.5, pan: 0},
          {time: 1.0, sample: :bd_haus, amp: 3.0, pan: 0},
          {time: 1.333, sample: :drum_tom_lo_hard, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_haus, amp: 4.0, pan: 0},
          {time: 0.5, sample: :bd_fat, amp: 3.5, pan: 0},
          {time: 1.0, sample: :bd_haus, amp: 3.5, pan: 0},
          {time: 1.25, sample: :drum_tom_hi_hard, amp: 2.5, pan: 0},
          {time: 1.5, sample: :drum_tom_mid_hard, amp: 2.5, pan: 0},
          {time: 1.75, sample: :drum_tom_lo_hard, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :bd_fat, amp: 3.5, pan: 0},
          {time: 0.25, sample: :perc_bell, amp: 2.0, pan: 0},
          {time: 0.5, sample: :drum_tom_mid_hard, amp: 2.5, pan: 0},
          {time: 0.75, sample: :perc_bell, amp: 2.0, pan: 0},
          {time: 1.0, sample: :bd_haus, amp: 3.5, pan: 0},
          {time: 1.5, sample: :drum_tom_lo_hard, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      }
    ],
    
    # ========== DRUMMER B: INDIAN (Tabla) ==========
    "B" => [
      # Basic patterns
      {
        beats: [
          {time: 0.0, sample: :drum_snare_soft, amp: 2.5, pan: 0},
          {time: 0.5, sample: :perc_snap, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.5, sample: :perc_snap2, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 0.25, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.5, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 0.75, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.5, sample: :drum_snare_soft, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.0, sample: :perc_snap2, amp: 2.0, pan: 0},
          {time: 1.5, sample: :drum_snare_soft, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 0.5, sample: :perc_snap, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.25, sample: :perc_snap2, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Syncopated patterns (3+3+2 rhythm)
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 0.375, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.75, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 1.125, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 1.5, sample: :drum_snare_hard, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 0.333, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.666, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.5, sample: :perc_snap2, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 0.5, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 0.875, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.25, sample: :drum_snare_soft, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 0.625, sample: :perc_snap, amp: 2.0, pan: 0},
          {time: 1.25, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.75, sample: :perc_snap2, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Intensive patterns (fast 16ths)
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 0.25, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.5, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 0.75, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.0, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 1.25, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 1.5, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.75, sample: :drum_snare_hard, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 3.0, pan: 0},
          {time: 0.125, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.25, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 0.375, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.5, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.5, sample: :perc_snap2, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_soft, amp: 2.5, pan: 0},
          {time: 0.333, sample: :perc_snap, amp: 2.0, pan: 0},
          {time: 0.666, sample: :perc_snap2, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_snare_hard, amp: 3.0, pan: 0},
          {time: 1.333, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.666, sample: :perc_snap2, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :drum_snare_hard, amp: 3.0, pan: 0},
          {time: 0.25, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 0.5, sample: :drum_snare_soft, amp: 2.0, pan: 0},
          {time: 0.75, sample: :perc_snap2, amp: 1.5, pan: 0},
          {time: 1.0, sample: :drum_snare_hard, amp: 2.5, pan: 0},
          {time: 1.25, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.75, sample: :drum_snare_soft, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      }
    ],
    
    # ========== DRUMMER C: LATIN (Conga/Clave) ==========
    "C" => [
      # Basic patterns
      {
        beats: [
          {time: 0.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 0.5, sample: :elec_bong, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.5, sample: :perc_snap, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 0.75, sample: :drum_cowbell, amp: 2.0, pan: 0},
          {time: 1.5, sample: :perc_snap, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 0.5, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 1.5, sample: :drum_cowbell, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 1.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.5, sample: :perc_snap, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Syncopated patterns (Son Clave 3-2)
      {
        beats: [
          {time: 0.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 0.5, sample: :drum_cowbell, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.25, sample: :elec_bong, amp: 2.0, pan: 0},
          {time: 1.75, sample: :perc_snap, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 0.375, sample: :drum_cowbell, amp: 1.5, pan: 0},
          {time: 0.75, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.25, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.75, sample: :elec_bong, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 0.625, sample: :elec_bong, amp: 2.0, pan: 0},
          {time: 1.125, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.75, sample: :drum_cowbell, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 0.5, sample: :drum_cowbell, amp: 2.0, pan: 0},
          {time: 0.875, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.5, sample: :drum_cowbell, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Intensive patterns
      {
        beats: [
          {time: 0.0, sample: :drum_cowbell, amp: 3.0, pan: 0},
          {time: 0.25, sample: :elec_bong, amp: 2.0, pan: 0},
          {time: 0.5, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 0.75, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 1.5, sample: :drum_cowbell, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :elec_bong, amp: 3.0, pan: 0},
          {time: 0.333, sample: :drum_cowbell, amp: 2.0, pan: 0},
          {time: 0.666, sample: :perc_snap, amp: 1.5, pan: 0},
          {time: 1.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.333, sample: :elec_bong, amp: 2.0, pan: 0},
          {time: 1.666, sample: :drum_cowbell, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :drum_cowbell, amp: 3.0, pan: 0},
          {time: 0.5, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.0, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 1.25, sample: :perc_snap, amp: 2.0, pan: 0},
          {time: 1.5, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.75, sample: :elec_bong, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :elec_bong, amp: 3.0, pan: 0},
          {time: 0.25, sample: :drum_cowbell, amp: 2.0, pan: 0},
          {time: 0.75, sample: :perc_snap, amp: 2.0, pan: 0},
          {time: 1.0, sample: :drum_cowbell, amp: 2.5, pan: 0},
          {time: 1.5, sample: :elec_bong, amp: 2.5, pan: 0},
          {time: 1.75, sample: :drum_cowbell, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      }
    ],
    
    # ========== DRUMMER D: ELECTRONIC ==========
    "D" => [
      # Basic patterns
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 0.5, sample: :elec_mid_snare, amp: 2.0, pan: 0},
          {time: 1.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 1.5, sample: :elec_blip, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 0.75, sample: :elec_hi_snare, amp: 2.5, pan: 0},
          {time: 1.5, sample: :elec_ping, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.5, pan: 0},
          {time: 0.5, sample: :elec_blip2, amp: 1.5, pan: 0},
          {time: 1.0, sample: :elec_mid_snare, amp: 2.5, pan: 0},
          {time: 1.5, sample: :bd_808, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 1.0, sample: :elec_hi_snare, amp: 2.5, pan: 0},
          {time: 1.5, sample: :elec_tick, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Syncopated patterns
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 0.375, sample: :elec_blip, amp: 1.5, pan: 0},
          {time: 0.75, sample: :elec_ping, amp: 1.5, pan: 0},
          {time: 1.25, sample: :elec_mid_snare, amp: 2.5, pan: 0},
          {time: 1.75, sample: :elec_tick, amp: 1.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.5, pan: 0},
          {time: 0.5, sample: :elec_blip2, amp: 1.5, pan: 0},
          {time: 1.0, sample: :elec_hi_snare, amp: 2.5, pan: 0},
          {time: 1.5, sample: :elec_ping, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.75
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 0.625, sample: :elec_mid_snare, amp: 2.0, pan: 0},
          {time: 1.125, sample: :elec_blip, amp: 1.5, pan: 0},
          {time: 1.75, sample: :elec_tick, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 0.25, sample: :elec_ping, amp: 1.5, pan: 0},
          {time: 0.75, sample: :elec_blip2, amp: 1.5, pan: 0},
          {time: 1.5, sample: :elec_hi_snare, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      
      # Intensive patterns
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.5, pan: 0},
          {time: 0.25, sample: :elec_blip, amp: 2.0, pan: 0},
          {time: 0.5, sample: :elec_mid_snare, amp: 2.5, pan: 0},
          {time: 0.75, sample: :elec_ping, amp: 2.0, pan: 0},
          {time: 1.0, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 1.5, sample: :elec_hi_snare, amp: 2.5, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 4.0, pan: 0},
          {time: 0.333, sample: :elec_blip2, amp: 1.5, pan: 0},
          {time: 0.666, sample: :elec_tick, amp: 1.5, pan: 0},
          {time: 1.0, sample: :elec_mid_snare, amp: 3.0, pan: 0},
          {time: 1.333, sample: :elec_ping, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 3.5, pan: 0},
          {time: 0.5, sample: :bd_808, amp: 3.0, pan: 0},
          {time: 1.0, sample: :elec_hi_snare, amp: 2.5, pan: 0},
          {time: 1.25, sample: :elec_blip, amp: 2.0, pan: 0},
          {time: 1.5, sample: :elec_mid_snare, amp: 2.5, pan: 0},
          {time: 1.75, sample: :elec_ping, amp: 2.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.25
      },
      {
        beats: [
          {time: 0.0, sample: :bd_808, amp: 4.0, pan: 0},
          {time: 0.25, sample: :elec_tick, amp: 1.5, pan: 0},
          {time: 0.5, sample: :elec_blip2, amp: 2.0, pan: 0},
          {time: 0.75, sample: :elec_ping, amp: 1.5, pan: 0},
          {time: 1.0, sample: :bd_808, amp: 3.5, pan: 0},
          {time: 1.5, sample: :elec_hi_snare, amp: 3.0, pan: 0}
        ],
        duration: 2.0, breathe: 0.5
      }
    ]
  }
  
  # Get pattern for specific drummer
  def get_pattern(drummer, index)
    patterns = PATTERNS[drummer]
    return nil unless patterns
    patterns[index % patterns.length]
  end
  
  # Get total pattern count for drummer
  def pattern_count(drummer)
    PATTERNS[drummer]&.length || 0
  end
end