# 章节过渡系统：等功率交叉淡入 + 频域交接

class TransitionSystem
  def initialize(config)
    @config = config
    @transition_bars = config.mix_settings[:transition_bars]
  end
  
  # A/B 总线等功率交叉淡入（Equal-power crossfade）
  # progress: 0.0 (全A) → 1.0 (全B)
  def crossfade_volumes(progress)
    # Equal-power 曲线：A = cos(π/2 * p), B = sin(π/2 * p)
    vol_a = Math.cos(Math::PI / 2 * progress)
    vol_b = Math.sin(Math::PI / 2 * progress)
    [vol_a, vol_b]
  end
  
  # 频域交接：A 章尾 HPF 上行，B 章头 LPF 下行
  def frequency_handoff(progress, direction = :a_to_b)
    if direction == :a_to_b
      # A: HPF 从 120 Hz 升至 800 Hz（高通，只留高频）
      hpf_a = 120 + 680 * progress
      # B: LPF 从 2500 Hz 降至全频（低通打开）
      lpf_b = 2500 + (20000 - 2500) * progress
      { hpf_a: hpf_a, lpf_b: lpf_b }
    else
      { hpf_a: 120, lpf_b: 20000 }  # 默认无过滤
    end
  end
  
  # 执行章节过渡（在 main.rb 中调用）
  def execute_transition(from_chapter, to_chapter, start_bar)
    bars = @transition_bars
    
    live_loop :transition_controller, sync: :bar_tick do
      bar_data = sync :bar_tick
      current_bar = bar_data[:bar]
      
      if current_bar >= start_bar && current_bar < start_bar + bars
        # 计算进度 [0, 1]
        progress = (current_bar - start_bar).to_f / bars
        
        # 获取音量与滤波参数
        vol_a, vol_b = crossfade_volumes(progress)
        freqs = frequency_handoff(progress, :a_to_b)
        
        # 通过 cue 广播参数（主程序中的 FX 总线监听）
        cue :xfade_params, vol_a: vol_a, vol_b: vol_b, hpf_a: freqs[:hpf_a], lpf_b: freqs[:lpf_b]
        
        sleep 4  # 一小节
      elsif current_bar >= start_bar + bars
        stop  # 过渡结束
      else
        sleep 4
      end
    end
  end
  
  # 淡入包络（片段引入）
  def fade_in_envelope(bars = 4)
    # 返回一个 [0, 1] 的音量曲线（线性淡入）
    bars.times.map { |i| i.to_f / bars }
  end
end