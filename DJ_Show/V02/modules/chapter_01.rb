# Chapter 1：Am Aeolian（0-80 小节）- 完整集成版

class Chapter01
  def self.run
    in_thread { intro }
    in_thread { build }
    in_thread { drop_a }
    in_thread { bridge }
    in_thread { drums }
    in_thread { bass }
    in_thread { harmony }
  end
  
  # Intro（0-16 小节）：PI ambient + ocean
  def self.intro
    sync :bar_tick
    bar_start = 0
    bar_end = 16
    
    live_loop :ch1_intro, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        if bar == bar_start
          $fx_bus.with_bus_a do
            in_thread { $pi.ambient(:a2, :minor, 16, 8) }
            in_thread { $pi.ocean(16, 8) }
          end
        end
      elsif bar >= bar_end
        stop
      end
    end
  end
  
  # Build（16-32 小节）：PI reich_phase + acid
  def self.build
    sync :bar_tick
    bar_start = 16
    bar_end = 32
    
    live_loop :ch1_build, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        if bar == bar_start
          $fx_bus.with_bus_a do
            in_thread { $pi.reich_phase(:a4, 16) }
          end
        end
        
        if bar == bar_start + 4
          $fx_bus.with_bus_a do
            in_thread { $pi.acid(:a2, 12, 60, 100) }
          end
        end
      elsif bar >= bar_end
        stop
      end
    end
  end
  
  # Drop A（32-64 小节）：PI blip_rhythm
  def self.drop_a
    sync :bar_tick
    bar_start = 32
    bar_end = 64
    
    live_loop :ch1_drop_a, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        if bar == bar_start
          $fx_bus.with_bus_a do
            in_thread { $pi.blip_rhythm(:a3, :minor_pentatonic, 32) }
          end
        end
      elsif bar >= bar_end
        stop
      end
    end
  end
  
  # Bridge（64-80 小节）：和弦转位
  def self.bridge
    sync :bar_tick
    bar_start = 64
    bar_end = 80
    
    live_loop :ch1_bridge, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        # Am - F - Dm - E 进行
        chords = [
          [:a2, :minor],
          [:f3, :major],
          [:d3, :minor],
          [:e3, :major]
        ]
        
        $fx_bus.with_bus_a do
          use_synth :piano
          with_fx :reverb, room: 0.6, mix: 0.5 do
            chords.each do |ch|
              play chord(ch[0], ch[1]), release: 3.8, amp: 0.4
              sleep 4
            end
          end
        end
      elsif bar >= bar_end
        stop
      end
    end
  end
  
  # 鼓层（32-80 小节）
  def self.drums
    sync :bar_tick
    bar_start = 32
    bar_end = 80
    
    live_loop :ch1_drums, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        if bar == bar_start
          in_thread { $drum_engine.play_drummer_a(:house_4f_k1, bar) }
          in_thread { $drum_engine.play_drummer_b(:house_4f_k1, bar) }
        end
        
        if bar == bar_start + 8
          in_thread { $drum_engine.play_drummer_c(:fill_tom_run, bar, 8) }
        end
      elsif bar >= bar_end
        $drum_engine.stop_all
        stop
      end
    end
  end
  
  # Bass 层（32-80 小节）
  def self.bass
    sync :bar_tick
    bar_start = 32
    bar_end = 80
    
    live_loop :ch1_bass, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        if bar == bar_start
          in_thread do
            $fx_bus.with_bus_a do
              $bass_engine.play_bass(:house_pump, :a1, :minor, bar_start, bar_end)
            end
          end
        end
      elsif bar >= bar_end
        $bass_engine.stop_bass
        stop
      end
    end
  end
  
  # Harmony 层（16-64 小节）
  def self.harmony
    sync :bar_tick
    bar_start = 16
    bar_end = 64
    
    live_loop :ch1_harmony, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar >= bar_start && bar < bar_end
        if bar == bar_start
          # Am - F - Dm - E 进行
          progression = [
            [:a2, :minor],
            [:f3, :major],
            [:d3, :minor],
            [:e3, :major]
          ]
          
          in_thread do
            $fx_bus.with_bus_a do
              $harmony_engine.play_pad(:a2, :minor, bar_start, bar_end, progression)
            end
          end
        end
      elsif bar >= bar_end
        $harmony_engine.stop_harmony
        stop
      end
    end
  end
end