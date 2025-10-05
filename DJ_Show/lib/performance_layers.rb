# Performance layer implementation
module PerformanceLayers
  # 播放鼓手模式
  def play_drum_pattern(drummer_id, pattern, energy, patterns, conductor)
    return unless pattern
    
    drummer_pan = conductor.config(:drummer_pans)[drummer_id]
    energy_scale = [[energy * 0.8, 0.3].max, 1.5].min
    
    pattern[:beats].each do |beat|
      in_thread do
        sleep beat[:time]
        calibrated_volume = get_sample_volume(beat[:sample])
        
        sample beat[:sample],
               amp: beat[:amp] * energy_scale * conductor.config(:drummer_volume) * calibrated_volume,
               rate: beat.fetch(:rate, 1.0),
               pan: drummer_pan
      end
    end
    
    sleep pattern[:duration] + pattern[:breathe]
  end
end