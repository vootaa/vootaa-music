# 能量曲线与参数自动化映射

class EnergyMapper
  def initialize
    # 能量曲线分段函数（小节 → 能量 0-100）
    @curve_segments = []
  end
  
  # 添加曲线段（起始小节、结束小节、起始能量、结束能量、曲线类型）
  def add_segment(start_bar, end_bar, start_energy, end_energy, curve_type = :linear)
    @curve_segments << {
      start: start_bar,
      end: end_bar,
      e_start: start_energy,
      e_end: end_energy,
      type: curve_type
    }
  end
  
  # 获取指定小节的能量值
  def energy_at(bar_index)
    segment = @curve_segments.find { |s| bar_index >= s[:start] && bar_index < s[:end] }
    return 50 unless segment  # 默认中等能量
    
    progress = (bar_index - segment[:start]).to_f / (segment[:end] - segment[:start])
    interpolate(segment[:e_start], segment[:e_end], progress, segment[:type])
  end
  
  # 能量到密度（0-100 → 0.3-1.0）
  def energy_to_density(energy)
    0.3 + 0.7 * (energy / 100.0)
  end
  
  # 能量到力度（0-100 → 0.5-1.0）
  def energy_to_velocity(energy)
    0.5 + 0.5 * (energy / 100.0)
  end
  
  # 能量到滤波截止（0-100 → 600-3200 Hz）
  def energy_to_cutoff(energy)
    600 + 2600 * (energy / 100.0)
  end
  
  # 能量到延迟反馈（0-100 → 0.15-0.45）
  def energy_to_delay_fb(energy)
    0.15 + 0.3 * (energy / 100.0)
  end
  
  # 能量到混响大小（0-100 → 0.4-0.75）
  def energy_to_reverb_size(energy)
    0.4 + 0.35 * (energy / 100.0)
  end
  
  private
  
  # 插值函数（支持线性/指数/Logistic）
  def interpolate(start_val, end_val, progress, curve_type)
    case curve_type
    when :linear
      start_val + (end_val - start_val) * progress
    when :exponential
      start_val + (end_val - start_val) * (progress ** 2)
    when :logistic
      k = 10.0
      sigmoid = 1.0 / (1.0 + Math.exp(-k * (progress - 0.5)))
      start_val + (end_val - start_val) * sigmoid
    else
      start_val + (end_val - start_val) * progress
    end
  end
end