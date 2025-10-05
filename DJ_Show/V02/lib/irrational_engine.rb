# 确定性伪随机：基于无理数序列的参数生成

module IrrationalEngine
  # === 无理步进器 ===
  # counter: 计数器（通常是小节/节拍索引）
  # base: 无理数基数（φ、√2、√3、π）
  # scale: 缩放范围
  # quantize: 离散化步数（nil = 连续值）
  def self.step(counter, base: Config::PHI, scale: 1.0, quantize: nil)
    raw_value = (counter * base) % scale
    
    if quantize
      # 离散化到 N 个档位
      (raw_value * quantize / scale).floor
    else
      # 返回 [0, scale) 范围内的连续值
      raw_value
    end
  end
  
  # === Lissajous 8字联动 ===
  # t: 时间参数（通常是小节数）
  # 返回 [x, y]，范围 [-1, 1]
  def self.lissajous_8(t, alpha: Config::PHI, beta: Config::SQRT2, delta: 0.0)
    angle = 2 * Math::PI * t / Config::LISSAJOUS[:period]
    x = Math.sin(alpha * angle)
    y = Math.sin(beta * angle + delta)
    [x, y]
  end
  
  # === 映射到目标范围 ===
  def self.map(value, from_min, from_max, to_min, to_max)
    ratio = (value - from_min).to_f / (from_max - from_min)
    (to_min + ratio * (to_max - to_min)).clamp(to_min, to_max)
  end
  
  # === 欧几里得节奏生成器 ===
  # n: 总步数, k: 触发次数, rot: 旋转偏移
  def self.euclidean(n, k, rot: 0)
    pattern = bjorklund(n, k)
    pattern.rotate(rot)
  end
  
  private
  
  # Bjorklund 算法实现
  def self.bjorklund(n, k)
    return [0] * n if k == 0 || k > n
    return [1] * n if k == n
    
    pattern = [1] * k + [0] * (n - k)
    counts = [k, n - k]
    remainders = [k]
    
    level = 0
    loop do
      break if counts[level + 1] <= 1
      
      counts << counts[level] - counts[level + 1]
      remainders << remainders[level] % counts[level + 1]
      level += 1
    end
    
    build_pattern(counts, remainders, level)
  end
  
  def self.build_pattern(counts, remainders, level)
    pattern = []
    
    if level == -1
      pattern = [0]
    elsif level == 0
      pattern = [1] * counts[0] + [0] * counts[1]
    else
      base = build_pattern(counts, remainders, level - 1)
      
      remainders[level].times do
        pattern += base
      end
      
      if counts[level + 1] > 0
        pattern += build_pattern(counts, remainders, level - 1)[0...-1]
        pattern += [0] * (counts[level + 1] - 1)
      end
    end
    
    pattern
  end
end