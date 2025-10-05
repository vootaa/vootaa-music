module PerformanceLayers
  # 播放鼓手模式
  def play_drum_pattern(drummer_id, pattern, energy, patterns, conductor)
    return unless pattern
    
    drummer_pan = config[:drummer_pans][drummer_id]
    
    pattern[:beats].each do |beat|
      in_thread do
        sleep beat[:time]
        calibrated_volume = config[:sample_volumes][beat[:sample]] || 1.0
        
        sample beat[:sample],
               amp: beat[:amp] * energy_scale * config[:drummer_volume] * calibrated_volume,
               rate: beat.fetch(:rate, 1.0),
               pan: drummer_pan
      end
    end
    
    sleep pattern[:duration] + pattern[:breathe]

    hits.each_with_index do |hit, beat|
      if hit == "x"
        sample sample_name,
               amp: amplitude * conductor.config(:drummer_volume) * get_sample_volume(sample_name),
               pan: conductor.config(:drummer_pans)[drummer_id.to_sym] || 0,
               rate: rate
      end
      sleep 0.5
    end
  end
end