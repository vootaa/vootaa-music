# FX 总线系统：A/B 通道等功率跨推 + 频域交接

class FXBus
  def initialize(config, transition_system)
    @config = config
    @transition = transition_system
    @bus_a_vol = 1.0
    @bus_b_vol = 0.0
    @hpf_a = 120
    @lpf_b = 20000
  end
  
  # 启动 FX 总线监听
  def start
    # Bus A（章节 A 的总线）
    in_thread do
      loop do
        begin
          params = sync :xfade_params
          @bus_a_vol = params[:vol_a] || 1.0
          @hpf_a = params[:hpf_a] || 120
        rescue
          sleep 0.05
        end
      end
    end
    
    # Bus B（章节 B 的总线）
    in_thread do
      loop do
        begin
          params = sync :xfade_params
          @bus_b_vol = params[:vol_b] || 0.0
          @lpf_b = params[:lpf_b] || 20000
        rescue
          sleep 0.05
        end
      end
    end
  end
  
  # 应用 Bus A 效果（章节调用）
  def with_bus_a(&block)
    with_fx :hpf, cutoff: @hpf_a do
      with_fx :compressor, threshold: 0.6, slope_above: 0.5 do
        with_fx :level, amp: @bus_a_vol do
          block.call
        end
      end
    end
  end
  
  # 应用 Bus B 效果
  def with_bus_b(&block)
    with_fx :lpf, cutoff: @lpf_b do
      with_fx :compressor, threshold: 0.6, slope_above: 0.5 do
        with_fx :level, amp: @bus_b_vol do
          block.call
        end
      end
    end
  end
end