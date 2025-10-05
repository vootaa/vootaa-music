# V02 主文件：时间线编排与章节调度

# === 加载模块 ===
require_relative '/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/config'
require_relative '/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/clock'
require_relative '/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/irrational_engine'
require_relative '/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/energy_curve'
require_relative '/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/helpers'

# === 全局设置 ===
use_bpm Config::BPM
set_volume! Config::MASTER_VOLUME

# === 初始化 ===
Clock.init
Energy.init

puts "="*60
puts "V02 DJ Show - Initialization Complete"
puts "BPM: #{Config::BPM}"
puts "Chapters: #{Config::CHAPTERS.keys.join(', ')}"
puts "="*60

# === 启动母时钟 ===
Clock.start

# === 测试：简单能量曲线演示 ===
live_loop :energy_demo do
  sync :section  # 每 8 小节
  
  bar = Clock.bar_count
  
  # 模拟段落切换
  section = case (bar / 8) % 6
            when 0 then :intro
            when 1 then :build
            when 2 then :drop_a
            when 3 then :bridge
            when 4 then :drop_b
            when 5 then :outro
            end
  
  target = Energy.curve_for_section(section)
  Energy.transition_to(target, duration: 8, curve: :logistic)
  
  puts "[Bar #{bar}] Section: #{section}, Target Energy: #{target}"
end

# === 测试：无理数序列演示 ===
live_loop :irrational_demo do
  sync :phrase  # 每 4 小节
  
  bar = Clock.bar_count
  
  # φ 步进（0-7 档位）
  phi_step = IrrationalEngine.step(bar, base: Config::PHI, scale: 8, quantize: 8)
  
  # √2 连续值
  sqrt2_val = IrrationalEngine.step(bar, base: Config::SQRT2, scale: 1.0)
  
  # Lissajous 8字
  x, y = IrrationalEngine.lissajous_8(bar)
  
  puts "  φ_step: #{phi_step}, √2: #{'%.3f' % sqrt2_val}, 8字: (#{('%.2f' % x)}, #{('%.2f' % y)})"
end

# 注意：鼓手系统、过渡系统等将在后续阶段添加