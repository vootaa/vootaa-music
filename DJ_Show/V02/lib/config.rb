# V02 全局配置：BPM、调式、章节时长、无理数比率、混音参数

class V02Config
  attr_accessor :bpm, :chapters, :irrational_ratios, :mix_settings, :drummer_settings
  
  def initialize
    @bpm = 126
    
    # 章节配置：调式、时长（小节）、能量目标（0-100）
    @chapters = [
      { name: :ch1, mode: :aeolian, root: :a2, bars: 80, energy_target: 65 },
      { name: :ch2, mode: :dorian,  root: :d2, bars: 80, energy_target: 75 },
      { name: :ch3, mode: :aeolian, root: :g2, bars: 80, energy_target: 80 },
      { name: :ch4, mode: :ionian,  root: :c2, bars: 80, energy_target: 70 },
      { name: :ch5, mode: :lydian,  root: :f2, bars: 80, energy_target: 65 },
      { name: :ch6, mode: :aeolian, root: :a2, bars: 96, energy_target: 60 }
    ]
    
    # 无理数配置（用于确定性微变）
    @irrational_ratios = {
      phi: 1.618033988749895,      # 黄金比
      sqrt2: 1.4142135623730951,   # √2
      pi: 3.141592653589793,       # π
      e: 2.718281828459045         # 自然常数
    }
    
    # 鼓手配置：pan、swing、room
    @drummer_settings = {
      a: { pan: 0,   swing: 0.52, room: 0.25, amp: 1.0 },  # Kick+Snare 中央
      b: { pan: -20, swing: 0.54, room: 0.20, amp: 0.9 },  # Hi-hat 左
      c: { pan: 20,  swing: 0.50, room: 0.30, amp: 0.95 }  # Perc/Tom 右
    }
    
    # 混音设置
    @mix_settings = {
      master_headroom: -6,         # 主总线余量（dB）
      drum_bus_level: -3,
      pad_bus_level: -6,
      bass_bus_level: -4,
      sidechain_amount: -2.5,
      transition_bars: 16          # 默认过渡时长（小节）
    }
  end
  
  # 获取章节总时长（小节）
  def total_bars
    @chapters.sum { |ch| ch[:bars] }
  end
  
  # 根据小节索引获取当前章节
  def current_chapter(bar_index)
    accumulated = 0
    @chapters.each do |ch|
      return ch if bar_index < accumulated + ch[:bars]
      accumulated += ch[:bars]
    end
    @chapters.last
  end
end