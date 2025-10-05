# 辅助函数：欧几里得节奏、平滑插值、音阶映射等

class Helpers
  # 欧几里得节奏生成 E(n, k, rotation)
  def self.euclidean(steps, pulses, rotation = 0)
    pattern = Array.new(steps, 0)
    slope = pulses.to_f / steps
    
    pulses.times do |i|
      pattern[(i / slope).floor] = 1
    end
    
    # 旋转
    pattern.rotate(rotation)
  end
  
  # 平滑插值（线性/指数/S型）
  def self.interpolate(start_val, end_val, progress, curve_type = :linear)
    case curve_type
    when :linear
      start_val + (end_val - start_val) * progress
    when :exponential
      start_val + (end_val - start_val) * (progress ** 2)
    when :sigmoid
      k = 10.0
      s = 1.0 / (1.0 + Math.exp(-k * (progress - 0.5)))
      start_val + (end_val - start_val) * s
    else
      start_val + (end_val - start_val) * progress
    end
  end
  
  # 将能量映射到离散档位（如：低/中/高）
  def self.energy_to_tier(energy)
    case energy
    when 0..40
      :low
    when 41..70
      :medium
    else
      :high
    end
  end
  
  # MIDI 音符号转 Sonic Pi 音符
  def self.midi_to_note(midi_number)
    note_names = [:c, :cs, :d, :ds, :e, :f, :fs, :g, :gs, :a, :as, :b]
    octave = (midi_number / 12) - 1
    note_index = midi_number % 12
    "#{note_names[note_index]}#{octave}".to_sym
  end
  
  # 量化到最近的 1/16 音符（防止时值漂移）
  def self.quantize_to_sixteenth(value)
    (value * 4).round / 4.0
  end
  
  # 无理数步进取模（确定性伪随机）
  def self.irrational_mod(counter, ratio, max_value)
    ((counter * ratio) % 1.0 * max_value).floor
  end
end