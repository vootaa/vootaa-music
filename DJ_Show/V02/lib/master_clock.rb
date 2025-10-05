# Master Clock - 全局时钟管理
# 管理BPM变化、小节计数、时间同步

class MasterClock
  attr_accessor :bpm, :bar_count, :beat_in_bar
  
  def initialize(initial_bpm = 120)
    @bpm = initial_bpm
    @bar_count = 0
    @beat_in_bar = 0
    @beat_duration = 60.0 / @bpm
  end
  
  # 更新BPM
  def update_bpm(new_bpm, transition_time = 4)
    old_bpm = @bpm
    @bpm = new_bpm
    @beat_duration = 60.0 / @bpm
    puts "🎵 BPM: #{old_bpm} → #{new_bpm} (#{transition_time}拍过渡)"
  end
  
  # 前进一拍
  def tick
    @beat_in_bar += 1
    if @beat_in_bar >= 4
      @beat_in_bar = 0
      @bar_count += 1
    end
  end
  
  # 等待一拍
  def wait_beat
    sleep @beat_duration
    tick
  end
  
  # 等待指定小节数
  def wait_bars(num_bars)
    (num_bars * 4).times { wait_beat }
  end
  
  # 获取当前位置信息
  def position_info
    "Bar: #{@bar_count + 1}, Beat: #{@beat_in_bar + 1}"
  end
  
  # 重置时钟
  def reset
    @bar_count = 0
    @beat_in_bar = 0
  end
end