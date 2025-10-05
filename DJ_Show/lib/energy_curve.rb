class EnergyCurve
  def initialize(cycle_length, golden_ratio)
    @cycle_length = cycle_length
    @golden_ratio = golden_ratio
    @previous_energy = 0.0
  end
  
  def calculate(elapsed_time)
    t = elapsed_time.to_f / @cycle_length
    
    base_wave = Math.sin(2 * Math::PI * t)
    golden_wave = Math.sin(2 * Math::PI * t * @golden_ratio)
    fibonacci_wave = Math.sin(3 * Math::PI * t) * 0.5
    
    combined = (base_wave + golden_wave + fibonacci_wave) / 2.5
    normalized = (combined + 1.0) / 2.0
    
    @previous_energy = normalized
    normalized
  end
  
  # 音量淡入曲线（多种模式）
  def fade_in_curve(elapsed_time, duration, mode = :smooth)
    t = (elapsed_time.to_f / duration).clip(0.0, 1.0)
    
    case mode
    when :linear
      t
      
    when :smooth  # S-curve (sigmoid-like)
      t * t * (3.0 - 2.0 * t)
      
    when :exponential
      (Math.exp(t * 3) - 1) / (Math::E ** 3 - 1)
      
    when :wave  # 波浪式上升
      base = t * t * (3.0 - 2.0 * t)
      ripple = Math.sin(t * Math::PI * 4) * 0.1 * (1 - t)
      (base + ripple).clip(0.0, 1.0)
      
    when :breathing  # 呼吸式（golden ratio）
      base = t * t * (3.0 - 2.0 * t)
      breath = Math.sin(t * Math::PI * @golden_ratio * 2) * 0.15
      (base + breath).clip(0.0, 1.0)
      
    when :surge  # 脉冲式上升
      if t < 0.3
        (t / 0.3) ** 2
      elsif t < 0.7
        surge = 1.0 + Math.sin((t - 0.3) / 0.4 * Math::PI * 3) * 0.2
        surge.clip(0.0, 1.2)
      else
        ease_in = (t - 0.7) / 0.3
        1.0 + ease_in * 0.1
      end
      
    else
      t
    end
  end
  
  # 音量淡出曲线
  def fade_out_curve(elapsed_time, duration, mode = :smooth)
    t = (elapsed_time.to_f / duration).clip(0.0, 1.0)
    
    case mode
    when :linear
      1.0 - t
      
    when :smooth  # 平滑下降
      1.0 - (t * t * (3.0 - 2.0 * t))
      
    when :exponential  # 指数衰减
      Math.exp(-t * 4)
      
    when :wave  # 波浪式下降
      base = 1.0 - (t * t * (3.0 - 2.0 * t))
      ripple = Math.sin(t * Math::PI * 5) * 0.08 * t
      (base + ripple).clip(0.0, 1.0)
      
    when :breathing  # 呼吸式退出
      base = 1.0 - (t * t * (3.0 - 2.0 * t))
      breath = Math.sin(t * Math::PI * @golden_ratio * 3) * 0.12 * (1 - t)
      (base + breath).clip(0.0, 1.0)
      
    when :echo  # 回声式（多次衰减波）
      base = 1.0 - (t * t)
      echo1 = Math.sin(t * Math::PI * 8) * 0.15 * (1 - t)
      echo2 = Math.sin(t * Math::PI * 13) * 0.08 * (1 - t)
      (base + echo1 + echo2).clip(0.0, 1.0)
      
    else
      1.0 - t
    end
  end
  
  def detect_inflection(current_energy, threshold)
    change_rate = (current_energy - @previous_energy).abs
    change_rate > threshold
  end
  
  def get_category(energy)
    case energy
    when 0.0..0.2 then "Rest"
    when 0.2..0.4 then "Low"
    when 0.4..0.6 then "Medium"
    when 0.6..0.8 then "High"
    else "Peak"
    end
  end
end

# Helper for Float
class Float
  def clip(min, max)
    [[self, min].max, max].min
  end
end