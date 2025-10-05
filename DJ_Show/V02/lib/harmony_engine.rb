# Pad/Harmony 引擎：长音/分解和弦交替，稀疏留白

class HarmonyEngine
  def initialize(config, energy_mapper, irr_engine)
    @config = config
    @energy = energy_mapper
    @irr = irr_engine
  end
  
  # 播放 Pad 和弦（长音持续）
  def play_pad(root_note, chord_type, bar_start, bar_end, progression = nil)
    live_loop :pad_layer, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        energy = @energy.energy_at(bar)
        cutoff = @energy.energy_to_cutoff(energy)
        reverb_size = @energy.energy_to_reverb_size(energy)
        
        # 默认和声进行：I - vi - IV - V
        prog = progression || [
          [root_note, chord_type],
          [root_note + 9, :minor],
          [root_note + 5, :major],
          [root_note + 7, :major]
        ]
        
        use_synth :hollow
        with_fx :reverb, room: reverb_size, mix: 0.6 do
          with_fx :lpf, cutoff: cutoff * 1.2 do
            prog.each do |ch|
              play chord(ch[0], ch[1]),
                release: 3.8,
                amp: 0.3 * @energy.energy_to_velocity(energy),
                pan: rrand(-0.2, 0.2)
              sleep 4
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
  
  # 播放分解和弦（Arpeggio）
  def play_arp(root_note, chord_type, bar_start, bar_end, pattern = :up)
    live_loop :arp_layer, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        energy = @energy.energy_at(bar)
        cutoff = @energy.energy_to_cutoff(energy)
        
        notes = chord(root_note, chord_type)
        
        # 分解模式
        arp_pattern = case pattern
                      when :up
                        notes
                      when :down
                        notes.reverse
                      when :updown
                        notes + notes.reverse
                      else
                        notes
                      end
        
        use_synth :sine
        with_fx :echo, phase: 0.375, mix: 0.3 do
          with_fx :lpf, cutoff: cutoff do
            arp_pattern.each do |note|
              play note,
                release: 0.3,
                amp: 0.35 * @energy.energy_to_velocity(energy),
                pan: rrand(-0.3, 0.3)
              sleep 0.25
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
  
  # 停止 Harmony
  def stop_harmony
    stop :pad_layer
    stop :arp_layer
  end
end