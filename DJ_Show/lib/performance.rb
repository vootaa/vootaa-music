# Performance orchestration module
module Performance
  class Conductor
    attr_reader :math, :energy_system, :patterns, :scale_modes, :volume_ctrl
    attr_accessor :cycle_start, :cycle_num
    
    def initialize(config)
      @config = config
      @math = MathEngine.new(config[:initial_seed])
      @energy_system = EnergyCurve.new(config[:cycle_length], config[:golden_ratio])
      @patterns = DrummerPatterns.new
      @scale_modes = ScaleModes.new
      @volume_ctrl = VolumeController.new(@energy_system, @math, config[:cycle_length])
      
      @cycle_start = Time.now
      @cycle_num = 0
    end
    
    def current_energy
      result = DrumHelpers.current_energy(@cycle_start, @cycle_num, @config[:cycle_length], 
                                           @energy_system, @math, @config[:debug_mode])
      @cycle_start = result[1]
      @cycle_num = result[2]
      result[0]
    end
    
    def should_play_drummer?(drummer_id, energy)
      DrumHelpers.should_play_drummer(drummer_id, energy, @math)
    end
    
    def get_drum_pattern(drummer_id)
      idx = @math.get_next(:pi) % @patterns.pattern_count(drummer_id)
      @patterns.get_pattern(drummer_id, idx)
    end
    
    def get_loop_start_pattern
      pattern_type = @math.get_next(:golden) % 4
      DrumHelpers.get_loop_start_pattern(pattern_type)
    end
    
    def get_scale_for_melody
      mode_idx = @math.get_next(:pi) % 12
      @scale_modes.get_scale_notes(:c4, mode_idx)
    end
    
    def generate_melody_phrase(scale_notes, phrase_len)
      note_idx = phrase_len.times.map { @math.get_next(:e) }
      @scale_modes.generate_phrase(scale_notes, phrase_len, note_idx, [0.5, 1.0, 1.5].ring)
    end
    
    def get_instrument_for_energy(energy)
      @scale_modes.get_instrument_for_energy(energy)
    end
    
    def should_trigger_fill?(energy)
      DrumHelpers.should_trigger_fill(energy, @energy_system, @math, @config[:fill_threshold])
    end
    
    def get_pan_value(seed = :sqrt2)
      @math.map_to_range(@math.get_next(seed), -0.8, 0.8)
    end
    
    def config(key)
      @config[key]
    end
  end
end