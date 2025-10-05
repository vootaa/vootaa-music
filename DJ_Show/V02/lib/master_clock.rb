# 母时钟与同步系统

class MasterClock
  attr_reader :bar_count, :beat_count
  
  def initialize(bpm, total_bars)
    @bpm = bpm
    @total_bars = total_bars
    @bar_count = 0
    @beat_count = 0
  end
  
  # 启动时钟（主循环）
  def start
    live_loop :master_clock do
      cue :bar_tick, bar: @bar_count
      
      4.times do |beat|
        cue :beat_tick, bar: @bar_count, beat: beat
        sleep 1  # 一拍
        @beat_count += 1
      end
      
      @bar_count += 1
      stop if @bar_count >= @total_bars
    end
  end
  
  # 同步到小节边界
  def sync_to_bar
    sync :bar_tick
  end
  
  # 同步到拍
  def sync_to_beat
    sync :beat_tick
  end
end