# ============================================================
# ENERGY CURVE SYSTEM
# Lissajous-based perpetual energy cycle
# ============================================================

class EnergyCurve
  
  def initialize(cycle_length, golden_ratio)
    @cycle_length = cycle_length.to_f
    @golden_ratio = golden_ratio
    @previous_energy = 0.0
  end
  
  # Calculate current energy level (0.0 to 1.0)
  def calculate(elapsed_time)
    t = elapsed_time.to_f
    period = @cycle_length
    
    # Lissajous curve formula
    # energy(t) = 0.5 + 0.5 × sin(2π × t/T) × cos(2π × t/(T×φ))
    phase1 = Math.sin(2 * Math::PI * t / period)
    phase2 = Math.cos(2 * Math::PI * t / (period * @golden_ratio))
    
    energy = 0.5 + 0.5 * phase1 * phase2
    
    # Ensure bounds
    energy = [[energy, 0.0].max, 1.0].min
    
    @previous_energy = energy
    energy
  end
  
  # Detect significant energy change (inflection point)
  def detect_inflection(current_energy, threshold = 0.15)
    delta = (current_energy - @previous_energy).abs
    delta > threshold
  end
  
  # Get energy category
  def get_category(energy)
    case energy
    when 0.0..0.1
      :silence
    when 0.1..0.3
      :intro
    when 0.3..0.6
      :development
    when 0.6..0.9
      :peak
    else
      :climax
    end
  end
  
  # Update previous energy for next comparison
  def update_previous(energy)
    @previous_energy = energy
  end
end