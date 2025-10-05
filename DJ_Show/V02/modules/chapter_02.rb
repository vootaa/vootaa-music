# Chapter 2：D Dorian（80-160 小节）

class Chapter02
  def self.run
    in_thread { intro }
    in_thread { build }
    in_thread { drop_a }
    in_thread { drop_b }
    in_thread { drums }
    in_thread { bass }
    in_thread { harmony }
  end
  
  # Intro（80-96 小节）
  def self.intro
    sync :bar_tick
    live_loop :ch2_intro, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 80 && bar < 96
        if bar == 80
          $fx_bus.with_bus_b do
            in_thread { $piw.driving_pulse(:d2, 16) }
          end
        end
      elsif bar >= 96
        stop
      end
    end
  end
  
  # Build（96-112 小节）
  def self.build
    sync :bar_tick
    live_loop :ch2_build, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 96 && bar < 112
        if bar == 96
          $fx_bus.with_bus_b do
            in_thread { $piw.acid(:d2, 16, 70, 110) }
          end
        end
      elsif bar >= 112
        stop
      end
    end
  end
  
  # Drop A（112-144 小节）
  def self.drop_a
    sync :bar_tick
    live_loop :ch2_drop_a, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 112 && bar < 144
        if bar == 112
          $fx_bus.with_bus_b do
            in_thread { $piw.blip_rhythm(:d3, :dorian, 32) }
          end
        end
      elsif bar >= 144
        stop
      end
    end
  end
  
  # Drop B（144-160 小节）
  def self.drop_b
    sync :bar_tick
    live_loop :ch2_drop_b, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 144 && bar < 160
        if bar == 144
          $fx_bus.with_bus_b do
            in_thread { $piw.wob_rhyth(:d1, 16) }
          end
        end
      elsif bar >= 160
        stop
      end
    end
  end
  
  # 鼓层（112-160 小节）
  def self.drums
    sync :bar_tick
    live_loop :ch2_drums, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 112 && bar < 160
        if bar == 112
          in_thread { $drum_engine.play_drummer_a(:house_shuffle, bar) }
          in_thread { $drum_engine.play_drummer_b(:house_shuffle, bar) }
          in_thread { $drum_engine.play_drummer_c(:fill_snare_roll, bar, 8) }
        end
      elsif bar >= 160
        $drum_engine.stop_all
        stop
      end
    end
  end
  
  # Bass 层（112-160 小节）
  def self.bass
    sync :bar_tick
    live_loop :ch2_bass, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 112 && bar < 160
        if bar == 112
          in_thread do
            $fx_bus.with_bus_b do
              $bass_engine.play_bass(:breaks_wobble, :d1, :dorian, 112, 160)
            end
          end
        end
      elsif bar >= 160
        $bass_engine.stop_bass
        stop
      end
    end
  end
  
  # Harmony 层（96-144 小节）
  def self.harmony
    sync :bar_tick
    live_loop :ch2_harmony, sync: :bar_tick do
      bar = sync(:bar_tick)[:bar]
      if bar >= 96 && bar < 144
        if bar == 96
          # Dm - C - Gm - Am 进行
          progression = [
            [:d2, :minor],
            [:c3, :major],
            [:g2, :minor],
            [:a2, :minor]
          ]
          
          in_thread do
            $fx_bus.with_bus_b do
              $harmony_engine.play_pad(:d2, :minor, 96, 144, progression)
            end
          end
        end
      elsif bar >= 144
        $harmony_engine.stop_harmony
        stop
      end
    end
  end
end