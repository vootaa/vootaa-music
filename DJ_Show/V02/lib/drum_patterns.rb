# 鼓型预置模式库（逐击控制，不使用 loop）

class DrumPatterns
  attr_reader :patterns
  
  def initialize
    @patterns = {
      # House/Techno 系列
      house_4f_k1: {
        style: :house,
        kick:  ring(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0),  # 四拍
        snare: ring(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0),  # 2、4 拍
        hat:   ring(1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0),  # 8分音符
        vel:   ring(0.9, 0.6, 0.8, 0.5, 0.9, 0.6, 0.8, 0.5, 0.9, 0.6, 0.8, 0.5, 0.9, 0.6, 0.8, 0.5)
      },
      
      house_shuffle: {
        style: :house,
        kick:  ring(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0),
        snare: ring(0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1),  # 轻微反拍
        hat:   ring(1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1),  # 三连感
        vel:   ring(0.9, 0.5, 0.7, 0.6, 0.9, 0.5, 0.7, 0.6, 0.9, 0.5, 0.7, 0.6, 0.9, 0.5, 0.7, 0.6)
      },
      
      # Breaks/DnB 系列
      breaks_amen: {
        style: :breaks,
        kick:  ring(1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0),
        snare: ring(0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1),  # Amen 轮廓
        hat:   ring(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),  # 高密度
        vel:   ring(0.8, 0.5, 0.6, 0.5, 0.9, 0.6, 0.7, 0.8, 0.8, 0.5, 0.7, 0.5, 0.9, 0.6, 0.7, 0.8)
      },
      
      breaks_two_step: {
        style: :breaks,
        kick:  ring(1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
        snare: ring(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0),  # 稀疏反拍
        hat:   ring(1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0),
        vel:   ring(0.9, 0.6, 0.8, 0.7, 0.9, 0.6, 0.8, 0.7, 0.9, 0.6, 0.8, 0.7, 0.9, 0.6, 0.8, 0.7)
      },
      
      # Hip-hop/Trap 系列
      hiphop_boom_bap: {
        style: :hiphop,
        kick:  ring(1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
        snare: ring(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0),
        hat:   ring(1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0),
        vel:   ring(1.0, 0.6, 0.8, 0.6, 0.95, 0.6, 0.8, 0.6, 1.0, 0.6, 0.8, 0.6, 0.95, 0.6, 0.8, 0.6)
      },
      
      trap_half_time: {
        style: :trap,
        kick:  ring(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0),  # 半速
        snare: ring(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
        hat:   ring(1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1),  # 三连
        vel:   ring(0.9, 0.5, 0.6, 0.7, 0.9, 0.5, 0.6, 0.7, 0.95, 0.5, 0.6, 0.7, 0.9, 0.5, 0.6, 0.7)
      },
      
      # Fill 库（过门）
      fill_tom_run: {
        style: :fill,
        tom:   ring(0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1),  # Tom 上行
        vel:   ring(0.5, 0.5, 0.5, 0.5, 0.6, 0.5, 0.7, 0.5, 0.8, 0.85, 0.9, 0.92, 0.94, 0.96, 0.98, 1.0)
      },
      
      fill_snare_roll: {
        style: :fill,
        snare: ring(0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1),  # 后半小节滚奏
        vel:   ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 1.0)
      },
      
      fill_crash_hit: {
        style: :fill,
        crash: ring(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),  # 峰值点
        vel:   ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0)
      }
    }
  end
  
  # 根据能量选择合适的模式（策略函数）
  def select_pattern(style, energy)
    candidates = @patterns.select { |k, v| v[:style] == style }
    return @patterns.keys.first if candidates.empty?
    
    # 简单策略：能量高用复杂模式，低用简单模式
    if energy > 70
      candidates.keys.last  # 返回最后一个（通常更复杂）
    else
      candidates.keys.first
    end
  end
  
  # 获取模式
  def get(pattern_name)
    @patterns[pattern_name] || @patterns[:house_4f_k1]
  end
end