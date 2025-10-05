class VolumeController
  def initialize(energy_system, math_engine, cycle_length)
    @energy_system = energy_system
    @math = math_engine
    @cycle_length = cycle_length
  end
  
  def calculate_fade_params(fade_in_dur, fade_out_dur, perf_cycles)
    total_duration = @cycle_length * perf_cycles
    
    # Smart fade selection based on golden ratio
    fade_modes = [
      { in: :linear, out: :linear },
      { in: :sine, out: :sine },
      { in: :cubic, out: :exponential },
      { in: :exponential, out: :cubic }
    ]
    
    selected = fade_modes[@math.get_next(:golden) % fade_modes.length]
    
    {
      fade_in: fade_in_dur,
      fade_out: fade_out_dur,
      total: total_duration,
      mode_in: selected[:in],
      mode_out: selected[:out]
    }
  end
  
  def get_dynamic_volume(elapsed, params)
    fade_in = params[:fade_in]
    fade_out = params[:fade_out]
    total = params[:total]
    
    if elapsed < fade_in
      # Fade in
      progress = elapsed.to_f / fade_in
      apply_curve(progress, params[:mode_in])
    elsif elapsed > (total - fade_out)
      # Fade out
      progress = (total - elapsed).to_f / fade_out
      apply_curve(progress, params[:mode_out])
    else
      # Full volume
      1.0
    end
  end
  
  private
  
  def apply_curve(progress, mode)
    case mode
    when :linear
      progress
    when :sine
      Math.sin(progress * Math::PI / 2)
    when :cubic
      progress ** 3
    when :exponential
      (Math.exp(progress * 2) - 1) / (Math.exp(2) - 1)
    else
      progress
    end
  end
end