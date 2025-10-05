# ============================================================
# SCALE MODES & MELODY GENERATOR
# 12 musical modes with phrase generation
# ============================================================

class ScaleModes
  
  # Available scale modes
  MODES = [
    :major, :minor,
    :major_pentatonic, :minor_pentatonic,
    :dorian, :phrygian, :lydian, :mixolydian,
    :harmonic_minor, :melodic_minor,
    :whole_tone, :blues_major
  ]
  
  # Melodic instruments pool
  INSTRUMENTS = [:kalimba, :piano, :beep, :dsaw]
  
  # Pre-computed scale intervals (semitones from root)
  SCALE_INTERVALS = {
    major: [0, 2, 4, 5, 7, 9, 11],
    minor: [0, 2, 3, 5, 7, 8, 10],
    major_pentatonic: [0, 2, 4, 7, 9],
    minor_pentatonic: [0, 3, 5, 7, 10],
    dorian: [0, 2, 3, 5, 7, 9, 10],
    phrygian: [0, 1, 3, 5, 7, 8, 10],
    lydian: [0, 2, 4, 6, 7, 9, 11],
    mixolydian: [0, 2, 4, 5, 7, 9, 10],
    harmonic_minor: [0, 2, 3, 5, 7, 8, 11],
    melodic_minor: [0, 2, 3, 5, 7, 9, 11],
    whole_tone: [0, 2, 4, 6, 8, 10],
    blues_major: [0, 2, 3, 4, 7, 9]
  }
  
  def initialize
    @current_mode_index = 0
    @current_root = :c4
  end
  
  # Get scale mode by index
  def get_mode(index)
    MODES[index % MODES.length]
  end
  
  # Get scale notes for root and mode
  # Returns array of MIDI note numbers
  def get_scale_notes(root_note, mode_index)
    mode = get_mode(mode_index)
    intervals = SCALE_INTERVALS[mode]
    
    # Convert root note to MIDI number
    root_midi = note_to_midi(root_note)
    
    # Generate scale across 2 octaves
    scale_notes = []
    2.times do |octave|
      intervals.each do |interval|
        scale_notes << root_midi + interval + (octave * 12)
      end
    end
    
    scale_notes
  end
  
  # Convert note symbol to MIDI number
  def note_to_midi(note_symbol)
    # Base MIDI numbers for each note name
    note_map = {
      c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11
    }
    
    note_str = note_symbol.to_s.downcase
    
    # Extract note name and octave
    note_name = note_str[0].to_sym
    octave = note_str[1..-1].to_i
    octave = 4 if octave == 0 && note_str.length == 1  # Default octave
    
    # Calculate MIDI number: (octave + 1) * 12 + note_offset
    base_midi = (octave + 1) * 12
    base_midi + note_map[note_name]
  end
  
  # Generate melodic phrase
  # Returns array of {note, duration, amp}
  def generate_phrase(scale_notes, length, note_indices, rhythm_pattern)
    phrase = []
    
    length.times do |i|
      note_idx = note_indices[i % note_indices.length] % scale_notes.length
      rhythm_idx = i % rhythm_pattern.length
      
      phrase << {
        note: scale_notes[note_idx],
        duration: rhythm_pattern[rhythm_idx],
        amp: 1.0
      }
    end
    
    phrase
  end
  
  # Check common tones between two scales (for smooth transitions)
  def common_tones_count(scale1, scale2)
    (scale1 & scale2).length
  end
  
  # Get random instrument
  def get_instrument(index)
    INSTRUMENTS[index % INSTRUMENTS.length]
  end
  
  # Get energy-appropriate instrument
  def get_instrument_for_energy(energy)
    case energy
    when 0.0..0.4
      :kalimba
    when 0.4..0.7
      :piano
    when 0.7..0.9
      :beep
    else
      :dsaw
    end
  end
end