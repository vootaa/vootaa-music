module DrumHelpers
  def self.current_energy(cycle_start_time, cycle_number, cycle_length, energy_system, math_engine, debug_mode)
    elapsed = Time.now - cycle_start_time
    
    if elapsed >= cycle_length
      cycle_number += 1
      cycle_start_time = Time.now
      math_engine.apply_cycle_offset(cycle_number)
      elapsed = 0
      puts "=== CYCLE #{cycle_number} ===" if debug_mode
    end
    
    energy = energy_system.calculate(elapsed)
    [energy, cycle_start_time, cycle_number]
  end
  
  def self.should_play_drummer(drummer_id, energy, math_engine)
    threshold = {"A" => 0.2, "B" => 0.3, "C" => 0.5, "D" => 0.7}[drummer_id] || 0.5
    energy > threshold && math_engine.get_next(:e) % 4 == (drummer_id.ord % 4)
  end
  
  def self.should_trigger_fill(energy, energy_system, math_engine, fill_threshold)
    inflection = energy_system.detect_inflection(energy, fill_threshold)
    random_trigger = math_engine.get_next(:golden) > 7
    (inflection || random_trigger) && energy > 0.4
  end
  
  def self.get_loop_start_pattern(pattern_type)
    case pattern_type
    when 0 then [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]
    when 1 then [0.0, 0.25, 0.5, 0.75]
    when 2 then [0.0, 0.333, 0.666]
    else [0.0, 0.1, 0.3, 0.4, 0.6, 0.8]
    end
  end

  # Get calibrated sample volume
  def self.get_sample_volume(sample_name)
    config = get_performance_config
    config[:sample_volumes][sample_name] || 1.0
  end

  # Random integer in range (inclusive)
  def self.rrand_i(min, max)
    (rrand(min, max + 0.999)).to_i
  end
end