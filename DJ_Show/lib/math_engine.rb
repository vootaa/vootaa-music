# ============================================================
# MATHEMATICAL CONSTANTS ENGINE
# Provides deterministic "randomness" from π, e, φ, √2
# ============================================================

class MathEngine
  
  # Mathematical constant sequences (first 32 digits)
  PI_DIGITS = [3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5]
  E_DIGITS = [2,7,1,8,2,8,1,8,2,8,4,5,9,0,4,5,2,3,5,3,6,0,2,8,7,4,7,1,3,5,2,6]
  GOLDEN_DIGITS = [1,6,1,8,0,3,3,9,8,8,7,4,9,8,9,4,8,4,8,2,0,4,5,8,6,8,3,4,3,6,5,6]
  SQRT2_DIGITS = [1,4,1,4,2,1,3,5,6,2,3,7,3,0,9,5,0,4,8,8,0,1,6,8,8,7,2,4,2,0,9,6]
  
  def initialize(seed)
    @seed = seed
    @pi_index = 0
    @e_index = 0
    @golden_index = 0
    @sqrt2_index = 0
  end
  
  # Get next digit from specified constant
  def get_next(constant_name)
    case constant_name
    when :pi
      digit = PI_DIGITS[@pi_index % 32]
      @pi_index += 1
      digit
    when :e
      digit = E_DIGITS[@e_index % 32]
      @e_index += 1
      digit
    when :golden
      digit = GOLDEN_DIGITS[@golden_index % 32]
      @golden_index += 1
      digit
    when :sqrt2
      digit = SQRT2_DIGITS[@sqrt2_index % 32]
      @sqrt2_index += 1
      digit
    else
      0
    end
  end
  
  # Map digit (0-9) to arbitrary range
  def map_to_range(digit, min_val, max_val)
    normalized = digit / 9.0
    min_val + (normalized * (max_val - min_val))
  end
  
  # Get next value mapped to range
  def get_mapped(constant_name, min_val, max_val)
    digit = get_next(constant_name)
    map_to_range(digit, min_val, max_val)
  end
  
  # Apply cycle offset (shift indices based on cycle number)
  def apply_cycle_offset(cycle_number)
    offset = (cycle_number * GOLDEN_RATIO * 10).to_i % 32
    @pi_index = (@pi_index + offset) % 32
    @e_index = (@e_index + offset) % 32
    @golden_index = (@golden_index + offset) % 32
    @sqrt2_index = (@sqrt2_index + offset) % 32
  end
  
  # Get current indices (for debugging)
  def get_indices
    {
      pi: @pi_index,
      e: @e_index,
      golden: @golden_index,
      sqrt2: @sqrt2_index
    }
  end
end