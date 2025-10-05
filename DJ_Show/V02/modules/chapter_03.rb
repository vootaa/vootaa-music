# Chapter 3：Gm Aeolian（160-240 小节）

class Chapter03
  def self.run
    in_thread { intro }
    in_thread { build }
    in_thread { drop_a }
    in_thread { bridge }
    in_thread { drop_b }
    in_thread { outro }
    in_thread { drums }
    in_thread { bass }
    in_thread { harmony }
  end
  
  # Intro（160-176 小节）
  def self.intro
    sync :bar_tick
    live_loop :ch3_intro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 160 && bar < 176
        if bar == 160
          $fx_bus.with_bus_a do
            in_thread { $pi.ocean(16, 8) }
            in_thread do
              sleep 4
              $pi.ambient_experiment(:g3, :aeolian, 12)
            end
          end
        end
      elsif bar >= 176
        stop
      end
    end
  end
  
  # Build（176-192 小节）
  def self.build
    sync :bar_tick
    live_loop :ch3_build, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 176 && bar < 192
        if bar == 176
          $fx_bus.with_bus_a do
            in_thread { $pi.reich_phase(:g4, 16) }
          end
        end
        
        if bar == 184
          $fx_bus.with_bus_a do
            in_thread { $pi.acid(:g2, 8, 65, 105) }
          end
        end
      elsif bar >= 192
        stop
      end
    end
  end
  
  # Drop A（192-208 小节）
  def self.drop_a
    sync :bar_tick
    live_loop :ch3_drop_a, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 192 && bar < 208
        if bar == 192
          $fx_bus.with_bus_a do
            in_thread { $pi.blip_rhythm(:g3, :minor_pentatonic, 16) }
          end
        end
        
        if bar == 200
          $fx_bus.with_bus_a do
            in_thread { $pi.wob_rhyth(:g1, 4) }
          end
        end
      elsif bar >= 208
        stop
      end
    end
  end
  
  # Bridge（208-224 小节）
  def self.bridge
    sync :bar_tick
    live_loop :ch3_bridge, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 208 && bar < 224
        # Gm - Eb - Bb - F 进行
        chords = [
          [:g2, :minor],
          [:eb3, :major],
          [:bb2, :major],
          [:f3, :major]
        ]
        
        $fx_bus.with_bus_a do
          use_synth :hollow
          with_fx :reverb, room: 0.7, mix: 0.6 do
            with_fx :echo, phase: 0.75, mix: 0.3 do
              chords.each do |ch|
                play chord(ch[0], ch[1]), release: 3.5, amp: 0.35
                sleep 4
              end
            end
          end
        end
      elsif bar >= 224
        stop
      end
    end
  end
  
  # Drop B（224-232 小节）
  def self.drop_b
    sync :bar_tick
    live_loop :ch3_drop_b, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 224 && bar < 232
        if bar == 224
          $fx_bus.with_bus_a do
            in_thread { $pi.driving_pulse(:g2, 8) }
          end
        end
      elsif bar >= 232
        stop
      end
    end
  end
  
  # Outro（232-240 小节）
  def self.outro
    sync :bar_tick
    live_loop :ch3_outro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 232 && bar < 240
        fade_vol = 1.0 - ((bar - 232).to_f / 8)
        
        $fx_bus.with_bus_a do
          use_synth :pad
          with_fx :reverb, room: 0.8, mix: 0.7 do
            play chord(:g2, :minor), release: 8, amp: 0.3 * fade_vol
            sleep 8
          end
        end
      elsif bar >= 240
        stop
      end
    end
  end
  
  # 鼓层（192-240 小节）
  def self.drums
    sync :bar_tick
    live_loop :ch3_drums, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 192 && bar < 240
        if bar == 192
          in_thread { $drum_engine.play_drummer_a(:breaks_amen, bar) }
          in_thread { $drum_engine.play_drummer_b(:breaks_amen, bar) }
          in_thread { $drum_engine.play_drummer_c(:fill_snare_roll, bar, 8) }
        end
      elsif bar >= 240
        $drum_engine.stop_all
        stop
      end
    end
  end
  
  # Bass 层（192-240 小节）
  def self.bass
    sync :bar_tick
    live_loop :ch3_bass, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 192 && bar < 240
        if bar == 192
          in_thread do
            $fx_bus.with_bus_a do
              $bass_engine.play_bass(:breaks_sub, :g1, :aeolian, 192, 240)
            end
          end
        end
      elsif bar >= 240
        $bass_engine.stop_bass
        stop
      end
    end
  end
  
  # Harmony 层（176-224 小节）
  def self.harmony
    sync :bar_tick
    live_loop :ch3_harmony, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 176 && bar < 224
        if bar == 176
          progression = [
            [:g2, :minor],
            [:eb3, :major],
            [:bb2, :major],
            [:f3, :major]
          ]
          
          in_thread do
            $fx_bus.with_bus_a do
              $harmony_engine.play_arp(:g2, :minor, 176, 224, :updown)
            end
          end
        end
      elsif bar >= 224
        $harmony_engine.stop_harmony
        stop
      end
    end
  end
end