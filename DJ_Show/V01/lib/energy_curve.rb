class EnergyCurve
  def initialize(cycle_length, golden_ratio)
    @cycle_length = cycle_length
    @golden_ratio = golden_ratio
    @previous_energy = 0.0
  end
  
  def calculate(elapsed_time)
    t = elapsed_time.to_f / @cycle_length
    
    # Lissajous curve with golden ratio
    base_wave = Math.sin(2 * Math::PI * t)
    golden_wave = Math.sin(2 * Math::PI * t * @golden_ratio)
    fibonacci_wave = Math.sin(3 * Math::PI * t) * 0.5
    
    # Combine waves
    combined = (base_wave + golden_wave + fibonacci_wave) / 2.5
    
    # Normalize to 0.0-1.0
    normalized = (combined + 1.0) / 2.0
    
    @previous_energy = normalized
    normalized
  end
  
  def detect_inflection(current, previous)
    (current - previous).abs > 0.15
  end
  
  # 获取能量等级分类
  def get_category(energy)
    case energy
    when 0.0...0.1 then "Silence"
    when 0.1...0.3 then "Intro"
    when 0.3...0.6 then "Development"
    when 0.6...0.9 then "Peak"
    else "Climax"
    end
  end
end