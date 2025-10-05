# Chapter 4：C Ionian（240-320 小节）

class Chapter04
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
    live_loop :ch4_intro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 240 && bar < 256
        if bar == 240
          $fx_bus.with_bus_b do
            in_thread { $pi.ambient(:c3, :major, 16, 8) }
          end
        end
      elsif bar >= 256
        stop
      end
    end
  end
  
  def self.build
    sync :bar_tick
    live_loop :ch4_build, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 256 && bar < 272
        if bar == 256
          $fx_bus.with_bus_b do
            in_thread { $pi.acid(:c2, 16, 70, 115) }
            in_thread do
              sleep 8
              $pi.ambient_experiment(:c3, :major, 8)
            end
          end
        end
      elsif bar >= 272
        stop
      end
    end
  end
  
  def self.drop_a
    sync :bar_tick
    live_loop :ch4_drop_a, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 272 && bar < 320
        if bar == 272
          $fx_bus.with_bus_b do
            in_thread { $pi.blip_rhythm(:c4, :major, 48) }
          end
        end
      elsif bar >= 320
        stop
      end
    end
  end
  
  def self.drums
    sync :bar_tick
    live_loop :ch4_drums, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 272 && bar < 320
        if bar == 272
          in_thread { $drum_engine.play_drummer_a(:house_4f_k1, bar) }
          in_thread { $drum_engine.play_drummer_b(:house_shuffle, bar) }
          in_thread { $drum_engine.play_drummer_c(:fill_tom_run, bar, 8) }
        end
      elsif bar >= 320
        $drum_engine.stop_all
        stop
      end
    end
  end
  
  def self.bass
    sync :bar_tick
    live_loop :ch4_bass, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 272 && bar < 320
        if bar == 272
          in_thread do
            $fx_bus.with_bus_b do
              $bass_engine.play_bass(:house_root, :c1, :major, 272, 320)
            end
          end
        end
      elsif bar >= 320
        $bass_engine.stop_bass
        stop
      end
    end
  end
  
  def self.harmony
    sync :bar_tick
    live_loop :ch4_harmony, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 256 && bar < 320
        if bar == 256
          progression = [
            [:c3, :major],
            [:g3, :major],
            [:a3, :minor],
            [:f3, :major]
          ]
          
          in_thread do
            $fx_bus.with_bus_b do
              $harmony_engine.play_pad(:c3, :major, 256, 320, progression)
            end
          end
        end
      elsif bar >= 320
        $harmony_engine.stop_harmony
        stop
      end
    end
  end
end