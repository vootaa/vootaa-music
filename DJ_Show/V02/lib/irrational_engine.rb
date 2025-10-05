# 无理数驱动的确定性"伪随机"引擎

class IrrationalEngine
  def initialize(config)
    @ratios = config.irrational_ratios
    @phase = 0.0  # 全局相位计数器
  end
  
  # 步进相位（每次调用递增）
  def step(ratio_key = :phi, step_size = 1.0)
    @phase += @ratios[ratio_key] * step_size
    @phase % 1.0  # 返回小数部分 [0, 1)
  end
  
  # 将相位映射到离散索引（模式库选择）
  def to_index(ratio_key, max_index)
    (step(ratio_key) * max_index).floor
  end
  
  # 将相位映射到连续值范围（力度、滤波等）
  def to_range(ratio_key, min_val, max_val)
    phase = step(ratio_key)
    min_val + phase * (max_val - min_val)
  end
  
  # Lissajous 8字型联动（x=sin(α·t), y=sin(β·t+δ)）
  def lissajous_pair(alpha_key, beta_key, delta = 0.0)
    alpha = @ratios[alpha_key]
    beta = @ratios[beta_key]
    t = @phase
    
    x = Math.sin(alpha * t)
    y = Math.sin(beta * t + delta)
    
    @phase += 0.01  # 缓慢递增
    [x, y]  # 返回 [-1, 1] 范围的 x, y
  end
  
  # 重置相位（章节切换时可用）
  def reset_phase
    @phase = 0.0
  end
end