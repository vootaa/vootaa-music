# Preset Manager - 预设管理
# 管理不同章节的音色、效果器预设

class PresetManager
  PRESETS = {
    # 第一章：混沌初开
    chapter_01: {
      synth: :dark_ambience,
      bass: { amp: 0.6, cutoff: 70, res: 0.7 },
      drums: { style: :minimal, density: 0.3 },
      fx: { reverb: 0.8, delay: 0.4 }
    },
    
    # 第二章：数学觉醒
    chapter_02: {
      synth: :saw,
      bass: { amp: 0.8, cutoff: 85, res: 0.5 },
      drums: { style: :techno, density: 0.6 },
      fx: { reverb: 0.5, delay: 0.6 }
    },
    
    # 第三章：黄金分割
    chapter_03: {
      synth: :blade,
      bass: { amp: 0.9, cutoff: 95, res: 0.4 },
      drums: { style: :breakbeat, density: 0.8 },
      fx: { reverb: 0.4, delay: 0.5 }
    },
    
    # 第四章：调和共振
    chapter_04: {
      synth: :prophet,
      bass: { amp: 0.85, cutoff: 90, res: 0.5 },
      drums: { style: :house, density: 0.7 },
      fx: { reverb: 0.6, delay: 0.3 }
    },
    
    # 第五章：无理数狂舞
    chapter_05: {
      synth: :tb303,
      bass: { amp: 1.0, cutoff: 110, res: 0.3 },
      drums: { style: :hard_techno, density: 1.0 },
      fx: { reverb: 0.3, delay: 0.7 }
    },
    
    # 第六章：宇宙归一
    chapter_06: {
      synth: :fm,
      bass: { amp: 0.5, cutoff: 80, res: 0.6 },
      drums: { style: :ambient, density: 0.2 },
      fx: { reverb: 0.9, delay: 0.8 }
    }
  }
  
  def initialize
    @current_preset = nil
  end
  
  # 加载预设
  def load(preset_name)
    if PRESETS.key?(preset_name)
      @current_preset = PRESETS[preset_name]
      puts "🎚️  加载预设: #{preset_name}"
      @current_preset
    else
      puts "⚠️  预设不存在: #{preset_name}"
      nil
    end
  end
  
  # 获取当前预设
  def current
    @current_preset
  end
  
  # 获取特定参数
  def get(category)
    @current_preset ? @current_preset[category] : nil
  end
end