module PerformanceLayers
  def play_drum_pattern(drummer_id, pattern, energy, patterns_obj, conductor)
    return unless pattern
    
    drummer_pan = conductor.config(:drummer_pans)[drummer_id]
    energy_scale = [[energy * 0.8, 0.3].max, 1.5].min
    base_volume = conductor.config(:drummer_volume)
    
    # Play each beat in the pattern
    pattern[:beats].each do |beat|
      in_thread do
        sleep beat[:time]
        
        calibrated_vol = get_sample_volume(beat[:sample])
        final_amp = beat[:amp] * energy_scale * base_volume * calibrated_vol
        
        sample beat[:sample],
               amp: final_amp,
               rate: beat.fetch(:rate, 1.0),
               pan: drummer_pan
      end
    end
    
    # Wait for pattern duration + breathe pause
    sleep pattern[:duration] + pattern[:breathe]
  end
end