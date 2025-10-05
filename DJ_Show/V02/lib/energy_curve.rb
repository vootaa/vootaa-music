# 能量曲线：分段函数驱动密度、力度、滤波等参数

module Energy
  @@current = 0.5  # 初始能量 [0, 1]
  
  # 初始化
  def self.init
    set :global_energy, 0.5
  end
  
  # 获取当前能量
  def self.current
    @@current
  end
  
  # 设置能量（立即切换）
  def self.set(value)
    @@current = value.clamp(0.0, 1.0)
    set :global_energy, @@current
  end
  
  # === 分段能量曲线（根据章节段落） ===
  def self.curve_for_section(section)
    case section
    when :intro
      0.2  # 低能量铺垫
    when :build
      0.5  # 中等能量推进
    when :drop_a
      0.85 # 首次峰值
    when :bridge
      0.4  # 降密度过渡
    when :drop_b
      0.95 # 二次峰值（最高）
    when :outro
      0.1  # 冷却收束
    else
      0.5
    end
  end
  
  # === 平滑过渡到目标能量 ===
  # target: 目标能量
  # duration: 过渡时长（小节数）
  # curve: 曲线类型 (:linear, :exponential, :logistic)
  def self.transition_to(target, duration: 8, curve: :linear)
    live_loop :energy_transition do
      sync :bar
      
      start_energy = @@current
      
      duration.times do |bar|
        progress = bar.to_f / duration
        
        # 根据曲线类型计算当前能量
        @@current = case curve
                    when :linear
                      start_energy + (target - start_energy) * progress
                    when :exponential
                      start_energy + (target - start_energy) * (progress ** 2)
                    when :logistic
                      # S 型曲线（平滑加速后减速）
                      k = 6.0  # 陡度系数
                      sigmoid = 1.0 / (1.0 + Math.exp(-k * (progress - 0.5)))
                      start_energy + (target - start_energy) * sigmoid
                    else
                      start_energy + (target - start_energy) * progress
                    end
        
        set :global_energy, @@current
        sleep 1  # 等待下一小节
      end
      
      # 过渡完成
      @@current = target
      stop
    end
  end
  
  # === 能量到参数映射 ===
  
  # 密度系数 [0.3, 1.0]
  def self.density
    IrrationalEngine.map(@@current, 0, 1, 0.3, 1.0)
  end
  
  # 力度缩放 [0.5, 1.0]
  def self.velocity_scale
    IrrationalEngine.map(@@current, 0, 1, 0.5, 1.0)
  end
  
  # 滤波截止频率 [600, 3200] Hz
  def self.cutoff
    IrrationalEngine.map(@@current, 0, 1, 600, 3200)
  end
  
  # 延迟反馈 [0.15, 0.45]
  def self.delay_feedback
    IrrationalEngine.map(@@current, 0, 1, 0.15, 0.45)
  end
  
  # 混响大小 [0.4, 0.75]
  def self.reverb_size
    IrrationalEngine.map(@@current, 0, 1, 0.4, 0.75)
  end
  
  # 开镲比例 [0.2, 0.6]
  def self.hat_open_ratio
    IrrationalEngine.map(@@current, 0, 1, 0.2, 0.6)
  end
  
  # Ghost 音符比例 [0.1, 0.35]
  def self.ghost_ratio
    IrrationalEngine.map(@@current, 0, 1, 0.1, 0.35)
  end
end