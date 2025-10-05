# 全局配置：BPM、调式、无理数比率、章节时长

module Config
  # === 全局参数 ===
  BPM = 126
  MASTER_VOLUME = 0.8
  PEAK_HEADROOM = -6  # dB
  
  # === 无理数常量 ===
  PHI = (1 + Math.sqrt(5)) / 2.0    # φ ≈ 1.618
  SQRT2 = Math.sqrt(2)               # √2 ≈ 1.414
  SQRT3 = Math.sqrt(3)               # √3 ≈ 1.732
  PI = Math::PI                       # π ≈ 3.14159
  
  # === 章节定义（6章） ===
  CHAPTERS = {
    ch1: {
      name: "Warm Club Intro",
      key: :a3,
      scale: :minor,
      mode: :aeolian,
      kit: :warm_club,
      bars: 96,              # 总小节数
      progression: [:i, :VI, :III, :VII]
    },
    ch2: {
      name: "Tight Tech Push",
      key: :d3,
      scale: :minor,
      mode: :dorian,
      kit: :tight_tech,
      bars: 96,
      progression: [:i, :VII, :IV, :i]
    },
    ch3: {
      name: "Gritty Breaks",
      key: :g3,
      scale: :minor,
      mode: :aeolian,
      kit: :gritty_breaks,
      bars: 96,
      progression: [:i, :iv, :VI, :VII]
    },
    ch4: {
      name: "Bright 303",
      key: :c4,
      scale: :major,
      mode: :ionian,
      kit: :warm_club,
      bars: 96,
      progression: [:I, :V, :vi, :IV]
    },
    ch5: {
      name: "Lydian Float",
      key: :f3,
      scale: :major,
      mode: :lydian,
      kit: :tight_tech,
      bars: 96,
      progression: [:I, :II, :V, :I]
    },
    ch6: {
      name: "Return Home",
      key: :a3,
      scale: :minor,
      mode: :aeolian,
      kit: :gritty_breaks,
      bars: 96,
      progression: [:i, :VI, :III, :VII]
    }
  }
  
  # === 段落时长分配（每章内部结构）===
  SECTION_LENGTHS = {
    intro: 16,
    build: 16,
    drop_a: 32,
    bridge: 16,
    drop_b: 32,
    outro: 16
  }
  
  # === 混音总线增益 ===
  BUS_LEVELS = {
    drums: 0.0,      # dB (参考基准)
    bass: -3.0,
    harmony: -6.0,
    lead: -4.0,
    fx: -8.0
  }
  
  # === Lissajous 8字参数 ===
  LISSAJOUS = {
    alpha: PHI,
    beta: SQRT2,
    delta: PI / 4,
    period: 64  # 小节周期
  }
end