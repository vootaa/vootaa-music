# Chapter 5：F Lydian（320-400 小节）

class Chapter05
  def self.run
    in_thread { intro }
    in_thread { build }
    in_thread { drop_a }
    in_thread { drums }
    in_thread { bass }
    in_thread { harmony }
  end
  
  def self.intro
    sync :bar_tick
    live_loop :ch5_intro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 320 && bar < 336
        if bar == 320
          $fx_bus.with_bus_a do
            in_thread { $piw.ambient_experiment(:f3, :major, 16) }
          end
        end
      elsif bar >= 336
        stop
      end
    end
  end
  
  def self.build
    sync :bar_tick
    live_loop :ch5_build, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 336 && bar < 352
        if bar == 336
          $fx_bus.with_bus_a do
            in_thread { $piw.reich_phase(:f4, 16) }
          end
        end
        
        if bar == 344
          $fx_bus.with_bus_a do
            in_thread { $piw.acid(:f2, 8, 75, 110) }
          end
        end
      elsif bar >= 352
        stop
      end
    end
  end
  
  def self.drop_a
    sync :bar_tick
    live_loop :ch5_drop_a, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 352 && bar < 400
        if bar == 352
          $fx_bus.with_bus_a do
            in_thread { $piw.blip_rhythm(:f3, :major, 48) }
          end
        end
      elsif bar >= 400
        stop
      end
    end
  end
  
  def self.drums
    sync :bar_tick
    live_loop :ch5_drums, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 352 && bar < 400
        if bar == 352
          in_thread { $drum_engine.play_drummer_a(:trap_half_time, bar) }
          in_thread { $drum_engine.play_drummer_b(:trap_half_time, bar) }
          in_thread { $drum_engine.play_drummer_c(:fill_crash_hit, bar, 8) }
        end
      elsif bar >= 400
        $drum_engine.stop_all
        stop
      end
    end
  end
  
  def self.bass
    sync :bar_tick
    live_loop :ch5_bass, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 352 && bar < 400
        if bar == 352
          in_thread do
            $fx_bus.with_bus_a do
              $bass_engine.play_bass(:trap_808, :f1, :major, 352, 400)
            end
          end
        end
      elsif bar >= 400
        $bass_engine.stop_bass
        stop
      end
    end
  end
  
  def self.harmony
    sync :bar_tick
    live_loop :ch5_harmony, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 336 && bar < 400
        if bar == 336
          progression = [
            [:f3, :major],
            [:g3, :major],
            [:c3, :major],
            [:f3, :major]
          ]
          
          in_thread do
            $fx_bus.with_bus_a do
              $harmony_engine.play_pad(:f3, :major, 336, 400, progression)
            end
          end
        end
      elsif bar >= 400
        $harmony_engine.stop_harmony
        stop
      end
    end
  end
end