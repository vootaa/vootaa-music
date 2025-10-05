# 多鼓手引擎（逐击演奏）

class DrumEngine
  def initialize(config, patterns, energy_mapper, irr_engine)
    @config = config
    @patterns = patterns
    @energy = energy_mapper
    @irr = irr_engine
    @drummer_settings = config.drummer_settings
  end
  
  # 鼓手 A：Kick + Snare（中央）
  def play_drummer_a(pattern_name, bar_index)
    pattern = @patterns.get(pattern_name)
    settings = @drummer_settings[:a]
    energy = @energy.energy_at(bar_index)
    
    live_loop :drummer_a, sync: :bar_tick do
      bar_data = sync :bar_tick
      current_bar = bar_data[:bar]
      
      16.times do |i|
        # Kick
        if pattern[:kick][i] == 1
          sample :drum_heavy_kick,
            amp: settings[:amp] * pattern[:vel][i] * @energy.energy_to_velocity(energy),
            pan: settings[:pan],
            room: settings[:room]
        end
        
        # Snare
        if pattern[:snare] && pattern[:snare][i] == 1
          sample :drum_snare_hard,
            amp: settings[:amp] * pattern[:vel][i] * @energy.energy_to_velocity(energy) * 0.9,
            pan: settings[:pan] + rrand(-2, 2),  # 轻微摆动
            room: settings[:room]
        end
        
        sleep 0.25  # 16分音符（1拍 = 4个16分音符）
      end
    end
  end
  
  # 鼓手 B：Hi-hat（左侧）
  def play_drummer_b(pattern_name, bar_index)
    pattern = @patterns.get(pattern_name)
    settings = @drummer_settings[:b]
    energy = @energy.energy_at(bar_index)
    swing_amount = settings[:swing]
    
    live_loop :drummer_b, sync: :bar_tick do
      bar_data = sync :bar_tick
      current_bar = bar_data[:bar]
      
      16.times do |i|
        if pattern[:hat][i] == 1
          # 应用 swing（偶数位延迟）
          sleep_time = (i % 2 == 1) ? (0.25 * swing_amount) : (0.25 * (2 - swing_amount))
          
          sample :drum_cymbal_closed,
            amp: settings[:amp] * pattern[:vel][i] * @energy.energy_to_velocity(energy) * 0.7,
            pan: settings[:pan],
            room: settings[:room],
            cutoff: @energy.energy_to_cutoff(energy) * 0.5  # 帽子高频可调
          
          sleep sleep_time
        else
          sleep 0.25
        end
      end
    end
  end
  
  # 鼓手 C：Perc/Tom（右侧）
  def play_drummer_c(fill_pattern_name, bar_index, trigger_every = 8)
    pattern = @patterns.get(fill_pattern_name)
    settings = @drummer_settings[:c]
    energy = @energy.energy_at(bar_index)
    
    live_loop :drummer_c, sync: :bar_tick do
      bar_data = sync :bar_tick
      current_bar = bar_data[:bar]
      
      # 仅在特定小节触发（如每 8 小节）
      if current_bar % trigger_every == (trigger_every - 1)
        16.times do |i|
          if pattern[:tom] && pattern[:tom][i] == 1
            sample :drum_tom_mid_hard,
              amp: settings[:amp] * pattern[:vel][i] * @energy.energy_to_velocity(energy),
              pan: settings[:pan] + rrand(-5, 5),
              room: settings[:room]
          end
          
          if pattern[:crash] && pattern[:crash][i] == 1
            sample :drum_splash_hard,
              amp: settings[:amp] * pattern[:vel][i],
              pan: 0,
              room: 0.5
          end
          
          sleep 0.25
        end
      else
        sleep 4  # 静默一小节
      end
    end
  end
  
  # 停止所有鼓手
  def stop_all
    stop :drummer_a
    stop :drummer_b
    stop :drummer_c
  end
end