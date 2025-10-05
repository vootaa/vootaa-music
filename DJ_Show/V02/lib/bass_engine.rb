# Bass 演奏引擎：根音导向的节型，小范围位移与装饰音

class BassEngine
  def initialize(config, energy_mapper, irr_engine)
    @config = config
    @energy = energy_mapper
    @irr = irr_engine
    @patterns = {
      # House/Techno 风格 Bass
      house_root: {
        notes: ring(0, 0, 0, 0, 0, 0, 0, 0),  # 根音持续
        durations: ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5),
        octaves: ring(0, 0, 0, 0, 0, 0, 0, 0)
      },
      
      house_pump: {
        notes: ring(0, -1, 0, -1, 0, -1, 0, -1),  # 根音与邻接音
        durations: ring(0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.5),
        octaves: ring(0, 0, 0, 0, 0, 0, 0, 0)
      },
      
      # Breaks/DnB 风格
      breaks_wobble: {
        notes: ring(0, 0, 5, 0, 0, 7, 0, 5),  # 根音 + 五度 + 七度
        durations: ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5),
        octaves: ring(0, -1, 0, 0, -1, 0, 0, 0)  # 八度跳跃
      },
      
      breaks_sub: {
        notes: ring(0, 0, 0, 0, 0, 0, 0, 0),
        durations: ring(1.0, 1.0, 1.0, 1.0),
        octaves: ring(-1, -1, -1, -1)  # Sub-bass
      },
      
      # Hip-hop/Trap
      trap_808: {
        notes: ring(0, 0, -2, 0, 0, -2, 0, -3),  # 根音 + 小二度 + 小三度
        durations: ring(0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25, 0.5),
        octaves: ring(0, 0, 0, -1, 0, 0, -1, 0)
      },
      
      # Minimal
      minimal_stab: {
        notes: ring(0, -5, 0, -5),  # 根音 + 下四度
        durations: ring(0.25, 0.25, 0.25, 0.25),
        octaves: ring(0, 0, 0, 0)
      }
    }
  end
  
  # 播放 Bass 线
  def play_bass(pattern_name, root_note, scale_type, bar_start, bar_end)
    pattern = @patterns[pattern_name] || @patterns[:house_root]
    
    live_loop :bass_layer, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        scale_notes = scale(root_note, scale_type)
        energy = @energy.energy_at(bar)
        
        # 根据能量调整滤波与力度
        cutoff = @energy.energy_to_cutoff(energy) * 0.6  # Bass 低频为主
        velocity = @energy.energy_to_velocity(energy)
        
        use_synth :tb303
        with_fx :lpf, cutoff: cutoff do
          with_fx :compressor, threshold: 0.6, slope_above: 0.5 do
            pattern[:notes].length.times do |i|
              # 计算音高（根音 + 偏移 + 八度）
              degree = pattern[:notes][i]
              octave = pattern[:octaves][i] * 12
              note = scale_notes[degree % scale_notes.length] + octave
              
              # 播放
              play note,
                release: pattern[:durations][i] * 0.9,
                cutoff: cutoff + rrand(-5, 5),
                res: 0.7,
                amp: 0.6 * velocity,
                pan: rrand(-0.1, 0.1)  # 轻微空间感
              
              sleep pattern[:durations][i]
            end
          end
        end
      elsif bar >= bar_end
        stop
      else
        sleep 4
      end
    end
  end
  
  # 停止 Bass
  def stop_bass
    stop :bass_layer
  end
end