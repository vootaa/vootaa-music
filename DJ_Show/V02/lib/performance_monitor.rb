# Performance Monitor - 性能监控
# 监控CPU、内存使用，输出状态信息

class PerformanceMonitor
  def initialize
    @start_time = Time.now
    @section_times = {}
  end
  
  # 记录章节开始
  def section_start(name)
    @section_times[name] = Time.now
    log_status("🎬 开始: #{name}")
  end
  
  # 记录章节结束
  def section_end(name)
    if @section_times[name]
      duration = Time.now - @section_times[name]
      log_status("✅ 完成: #{name} (耗时: #{duration.round(2)}秒)")
    end
  end
  
  # 输出状态信息
  def log_status(message)
    elapsed = Time.now - @start_time
    puts "[#{format_time(elapsed)}] #{message}"
  end
  
  # 输出完整报告
  def report
    total_time = Time.now - @start_time
    puts "\n" + "="*60
    puts "🎭 演出报告"
    puts "="*60
    puts "总时长: #{format_time(total_time)}"
    puts "章节详情:"
    @section_times.each do |name, start_time|
      puts "  - #{name}: #{format_time(Time.now - start_time)}"
    end
    puts "="*60
  end
  
  private
  
  def format_time(seconds)
    mins = (seconds / 60).to_i
    secs = (seconds % 60).round(2)
    "#{mins}:#{secs.to_s.rjust(5, '0')}"
  end
end