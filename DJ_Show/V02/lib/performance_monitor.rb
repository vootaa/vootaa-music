# 性能监控：CPU、线程、能量、章节状态

class PerformanceMonitor
  def initialize(config, clock, energy_mapper)
    @config = config
    @clock = clock
    @energy = energy_mapper
    @start_time = Time.now
  end
  
  # 启动监控循环
  def start
    live_loop :performance_monitor do
      elapsed = (Time.now - @start_time).to_i
      current_bar = @clock.bar_count
      total_bars = @config.total_bars
      progress = (current_bar.to_f / total_bars * 100).round(1)
      energy = @energy.energy_at(current_bar).round(1)
      chapter = @config.current_chapter(current_bar)
      
      # 打印状态
      puts "=" * 60
      puts "V02 DJ Show Performance Monitor"
      puts "=" * 60
      puts "Time Elapsed: #{elapsed}s | Chapter: #{chapter[:name]}"
      puts "Progress: Bar #{current_bar}/#{total_bars} (#{progress}%)"
      puts "Energy Level: #{energy}/100"
      puts "Active Threads: #{Thread.list.count}"
      puts "BPM: #{@config.bpm} | Mode: #{chapter[:mode]}"
      puts "=" * 60
      
      sleep 8  # 每 8 秒更新一次
    end
  end
  
  # 停止监控
  def stop_monitor
    stop :performance_monitor
  end
end