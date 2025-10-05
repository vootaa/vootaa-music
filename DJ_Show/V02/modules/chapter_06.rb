# Chapter 6：Am Aeolian 回归（400-496 小节）

class Chapter06
  def self.run
    in_thread { intro }
    in_thread { build }
    in_thread { drop_a }
    in_thread { bridge }
    in_thread { final_outro }
    in_thread { drums }
    in_thread { bass }
  end
  
  def self.intro
    sync :bar_tick
    live_loop :ch6_intro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 400 && bar < 416
        if bar == 400
          $fx_bus.with_bus_b do
            in_thread { $pi.ocean(16, 8) }
            in_thread do
              sleep 4
              $pi.ambient(:a2, :minor, 12, 6)
            end
          end
        end
      elsif bar >= 416
        stop
      end
    end
  end
  
  def self.build
    sync :bar_tick
    live_loop :ch6_build, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 416 && bar < 432
        if bar == 416
          $fx_bus.with_bus_b do
            in_thread { $pi.reich_phase(:a4, 16) }
          end
        end
        
        if bar == 424
          $fx_bus.with_bus_b do
            in_thread { $pi.acid(:a2, 8, 60, 100) }
          end
        end
      elsif bar >= 432
        stop
      end
    end
  end
  
  def self.drop_a
    sync :bar_tick
    live_loop :ch6_drop_a, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 432 && bar < 464
        if bar == 432
          $fx_bus.with_bus_b do
            in_thread { $pi.blip_rhythm(:a3, :minor_pentatonic, 32) }
          end
        end
      elsif bar >= 464
        stop
      end
    end
  end
  
  def self.bridge
    sync :bar_tick
    live_loop :ch6_bridge, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 464 && bar < 480
        chords = [
          [:a2, :minor],
          [:f3, :major],
          [:c3, :major],
          [:g3, :major]
        ]
        
        $fx_bus.with_bus_b do
          use_synth :piano
          with_fx :reverb, room: 0.7, mix: 0.6 do
            chords.each do |ch|
              play chord(ch[0], ch[1]), release: 3.8, amp: 0.4
              sleep 4
            end
          end
        end
      elsif bar >= 480
        stop
      end
    end
  end
  
  def self.final_outro
    sync :bar_tick
    live_loop :ch6_final_outro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 480 && bar < 496
        if bar >= 480 && bar < 488
          if bar == 480
            $fx_bus.with_bus_b do
              in_thread { $pi.blimp_zones(:a2, :minor, 8) }
            end
          end
        end
        
        if bar >= 488 && bar < 496
          if bar == 488
            $fx_bus.with_bus_b do
              in_thread { $pi.bach(:a2, :minor, 8) }
            end
          end
        end
      elsif bar >= 496
        stop
      end
    end
  end
  
  def self.drums
    sync :bar_tick
    live_loop :ch6_drums, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 432 && bar < 488
        if bar >= 432 && bar < 464
          if bar == 432
            in_thread { $drum_engine.play_drummer_a(:house_4f_k1, bar) }
            in_thread { $drum_engine.play_drummer_b(:house_4f_k1, bar) }
          end
        end
        
        if bar >= 464 && bar < 488
          if bar == 464
            $drum_engine.stop_all
            sleep 0.5
            in_thread { $drum_engine.play_drummer_a(:breaks_two_step, bar) }
            in_thread { $drum_engine.play_drummer_b(:breaks_two_step, bar) }
          end
        end
      elsif bar >= 488
        $drum_engine.stop_all
        stop
      end
    end
  end
  
  def self.bass
    sync :bar_tick
    live_loop :ch6_bass, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 432 && bar < 488
        if bar == 432
          in_thread do
            $fx_bus.with_bus_b do
              $bass_engine.play_bass(:house_pump, :a1, :minor, 432, 488)
            end
          end
        end
      elsif bar >= 488
        $bass_engine.stop_bass
        stop
      end
    end
  end
end