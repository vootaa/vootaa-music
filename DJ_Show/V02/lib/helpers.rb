# 通用工具：渐变、限幅、对数转换等

module Helpers
  # === 线性渐变 ===
  # 从 start 到 end，持续 steps 步
  def self.ramp(start_val, end_val, steps)
    return [end_val] if steps <= 1
    
    step_size = (end_val - start_val).to_f / (steps - 1)
    Array.new(steps) { |i| start_val + step_size * i }
  end
  
  # === 对数缩放（用于频率/增益） ===
  def self.log_scale(value, min, max)
    return min if value <= 0
    min * ((max / min) ** value)
  end
  
  # === 分贝转线性 ===
  def self.db_to_linear(db)
    10 ** (db / 20.0)
  end
  
  # === 线性转分贝 ===
  def self.linear_to_db(linear)
    20 * Math.log10(linear)
  end
  
  # === 等功率交叉淡入（用于过渡） ===
  # progress: [0, 1] 进度
  # 返回 [fade_out, fade_in] 两个曲线值
  def self.equal_power_fade(progress)
    angle = progress * Math::PI / 2
    fade_out = Math.cos(angle)
    fade_in = Math.sin(angle)
    [fade_out, fade_in]
  end
  
  # === 限幅器 ===
  def self.clip(value, min, max)
    value.clamp(min, max)
  end
  
  # === 概率触发（基于无理数） ===
  def self.trigger?(counter, threshold = 0.5, base: Config::PHI)
    IrrationalEngine.step(counter, base: base, scale: 1.0) < threshold
  end
end