# 片段封装：将 SONIC PI examples 中的代码提取为可调用函数

class PIWrapper
  # ambient.rb：双和弦 Drone（主和弦 → 近亲和弦）
  def ambient(root = :a2, chord_type = :minor, bars = 8, fade_bars = 4)
    in_thread do
      bar_start = sync(:bar_tick)[:bar]
      
      bars.times do |bar_offset|
        bar_data = sync :bar_tick
        current_bar = bar_data[:bar]
        
        if bar_offset < fade_bars
          fade_vol = bar_offset.to_f / fade_bars
          with_fx :lpf, cutoff: 600 + 2400 * fade_vol do
            with_fx :reverb, room: 0.7, mix: 0.5 * fade_vol do
              use_synth :hollow
              play chord(root, chord_type), release: 8, amp: 0.3 * fade_vol
            end
          end
        else
          with_fx :reverb, room: 0.7, mix: 0.5 do
            use_synth :hollow
            play chord(root, chord_type), release: 8, amp: 0.3
          end
        end
      end
    end
  end
  
  # ocean.rb：低频噪声海面 + 轻滤波摆动
  def ocean(bars = 8, fade_bars = 4)
    in_thread do
      bars.times do |bar_offset|
        sync :bar_tick
        
        fade_vol = bar_offset < fade_bars ? (bar_offset.to_f / fade_bars) : 1.0
        
        with_fx :lpf, cutoff: 80 + 40 * Math.sin(bar_offset * 0.5) do
          with_fx :reverb, room: 0.9, mix: 0.6 * fade_vol do
            sample :ambi_drone, rate: 0.5, amp: 0.2 * fade_vol
          end
        end
      end
    end
  end
  
  # ambient_experiment.rb：稀疏琶音（1-3-5-9）
  def ambient_experiment(root = :a3, scale_type = :minor, bars = 4)
    in_thread do
      notes = scale(root, scale_type)
      pattern = [0, 2, 4, 8]
      
      bars.times do
        sync :bar_tick
        
        with_fx :echo, phase: 0.375, mix: 0.4 do
          with_fx :reverb, room: 0.6 do
            use_synth :sine
            pattern.each do |step|
              play notes[step % notes.length], release: 0.5, amp: 0.3
              sleep 0.5
            end
          end
        end
      end
    end
  end

  # reich_phase.rb：双单音相位缓移
  def reich_phase(root = :a4, bars = 8)
    in_thread do
      bars.times do |bar_offset|
        sync :bar_tick
        
        2.times do |voice|
          in_thread do
            16.times do |i|
              use_synth :beep
              play root, release: 0.1, amp: 0.4, pan: voice == 0 ? -0.3 : 0.3
              sleep 0.25 + voice * 0.01 * bar_offset
            end
          end
        end
      end
    end
  end
  
  # acid.rb：303 风格（16 步滑音/重音）
  def acid(root = :a2, bars = 8, cutoff_start = 60, cutoff_end = 110)
    in_thread do
      bars.times do |bar_offset|
        sync :bar_tick
        
        cutoff = cutoff_start + (cutoff_end - cutoff_start) * (bar_offset.to_f / bars)
        
        use_synth :tb303
        with_fx :reverb, room: 0.4 do
          16.times do |i|
            play root, release: 0.2, cutoff: cutoff, res: 0.8, amp: 0.5
            sleep 0.25
          end
        end
      end
    end
  end
  
  # blip_rhythm.rb：1-3-5-8 极简钩子
  def blip_rhythm(root = :a3, scale_type = :minor_pentatonic, bars = 4)
    in_thread do
      notes = scale(root, scale_type).take(8)
      pattern = [0, 2, 4, 7]
      
      bars.times do
        sync :bar_tick
        
        with_fx :echo, phase: 0.25, mix: 0.3 do
          use_synth :square
          pattern.each do |step|
            play notes[step % notes.length], release: 0.1, amp: 0.5
            sleep 0.25
          end
        end
      end
    end
  end
  
  # chord_inversions.rb：和弦转位（I-vi-IV-V）
  def chord_inversions(root = :c3, bars = 8)
    live_loop :pi_chords, sync: :bar_tick do
      bar_data = sync :bar_tick
      bar = bar_data[:bar]
      
      if bar < bars
        # I - vi - IV - V 进行
        chords = [
          chord(root, :major),
          chord(root + 9, :minor),      # vi
          chord(root + 5, :major),      # IV
          chord(root + 7, :major)       # V
        ]
        
        use_synth :piano
        with_fx :reverb, room: 0.6, mix: 0.5 do
          chords.each do |ch|
            play ch, release: 3.8, amp: 0.4
            sleep 4
          end
        end
      else
        stop
      end
    end
  end
  
  # driving_pulse.rb：主音-五度踏垫
  def driving_pulse(root = :d2, bars = 8)
    in_thread do
      bars.times do
        sync :bar_tick
        
        use_synth :pulse
        with_fx :reverb, room: 0.3 do
          4.times do
            play root, release: 0.8, amp: 0.6
            sleep 0.5
            play root + 7, release: 0.8, amp: 0.5
            sleep 0.5
          end
        end
      end
    end
  end
  
  # wob_rhyth.rb：wob 低音插花
  def wob_rhyth(root = :a1, bars = 4)
    in_thread do
      bars.times do
        sync :bar_tick
        
        use_synth :tb303
        with_fx :wobble, phase: 0.5 do
          play root, release: 1.5, cutoff: 70, res: 0.9, amp: 0.7
          sleep 1.5
          play root - 5, release: 1.5, cutoff: 50, res: 0.9, amp: 0.7
          sleep 2.5
        end
      end
    end
  end
  
  # blimp_zones.rb：5-4-3-2-1 低频暖垫缓降
  def blimp_zones(root = :a2, scale_type = :minor, bars = 8)
    in_thread do
      degrees = [5, 4, 3, 2, 1]
      scale_notes = scale(root, scale_type)
      
      bars.times do
        sync :bar_tick
        
        use_synth :hollow
        with_fx :reverb, room: 0.9, mix: 0.8 do
          degrees.each do |deg|
            play scale_notes[deg - 1], release: 1.5, amp: 0.3
            sleep 1.6
          end
        end
      end
    end
  end
  
  # bach.rb：3-2-1 终止式（弱拍邻接音）
  def bach(root = :a2, scale_type = :minor, bars = 4)
    in_thread do
      degrees = [3, 2, 1]
      scale_notes = scale(root, scale_type)
      
      bars.times do
        sync :bar_tick
        
        use_synth :piano
        with_fx :reverb, room: 0.8, mix: 0.7 do
          degrees.each do |deg|
            play scale_notes[deg], release: 1.5, amp: 0.35
            sleep 1.0
            play scale_notes[deg - 1], release: 0.5, amp: 0.2
            sleep 0.5
            play scale_notes[deg], release: 1.5, amp: 0.35
            sleep 2.5
          end
        end
      end
    end
  end
end