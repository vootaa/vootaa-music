# V02 主程序 - Sonic Pi DJ Show
# 架构：使用 load 加载外部模块（遵循V01成功经验）

# ================================
# 核心库加载（使用 load）
# ================================
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/config.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/helpers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/energy_mapper.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/drum_patterns.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/drum_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/bass_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/harmony_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/irrational_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/transition_system.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/fx_bus.rb"

# ================================
# 章节模块加载
# ================================
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/pi_wrapper.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_01.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_02.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_03.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_04.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_05.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_06.rb"

# ================================
# 全局初始化
# ================================
$config = V02Config.new
use_bpm $config.bpm
use_debug false

# 创建核心对象
$energy = EnergyMapper.new
$patterns = DrumPatterns.new
$irr = IrrationalEngine.new($config)
$transition = TransitionSystem.new($config)
$fx_bus = FXBus.new($config, $transition)

# 初始化引擎
$drum_engine = DrumEngine.new($config, $patterns, $energy, $irr)
$bass_engine = BassEngine.new($config, $energy, $irr)
$harmony_engine = HarmonyEngine.new($config, $energy, $irr)

# 初始化 PIWrapper
$piw = PIWrapper.new

# 配置能量曲线（6章节）
$energy.add_segment(0, 40, 20, 65, :exponential)      # Ch1
$energy.add_segment(40, 80, 65, 50, :linear)          # Ch1: 淡出
$energy.add_segment(80, 120, 50, 75, :exponential)    # Ch2
$energy.add_segment(120, 160, 75, 60, :linear)        # Ch2: 淡出
$energy.add_segment(160, 200, 60, 80, :exponential)   # Ch3
$energy.add_segment(200, 240, 80, 50, :logistic)      # Ch3: 淡出
$energy.add_segment(240, 280, 50, 70, :exponential)   # Ch4
$energy.add_segment(280, 320, 70, 55, :linear)        # Ch4: 淡出
$energy.add_segment(320, 360, 55, 85, :exponential)   # Ch5
$energy.add_segment(360, 400, 85, 40, :logistic)      # Ch5: 淡出
$energy.add_segment(400, 464, 40, 60, :linear)        # Ch6
$energy.add_segment(464, 496, 60, 10, :logistic)      # Ch6: 终极淡出

puts "🎭 V02 系统初始化完成"
puts "="*60

# ================================
# 主时钟（核心驱动）
# ================================
live_loop :master_clock do
  cue :bar_tick, bar: tick
  sleep 4  # 一小节 = 4拍
end

# ================================
# FX总线监听器（启动）
# ================================
$fx_bus.start

# ================================
# 章节自动触发系统
# ================================
in_thread do
  sleep 0.1
  Chapter01.run  # 0-80 小节
  Chapter02.run  # 80-160 小节
  Chapter03.run  # 160-240 小节
  Chapter04.run  # 240-320 小节
  Chapter05.run  # 320-400 小节
  Chapter06.run  # 400-496 小节
end

# ================================
# 章节过渡控制器
# ================================
in_thread do
  sleep 0.2
  
  # Ch1 → Ch2 (76-80小节)
  $transition.execute_transition(:ch1, :ch2, 76)
  
  # Ch2 → Ch3 (156-160小节)
  sleep 80 * 4
  $transition.execute_transition(:ch2, :ch3, 156)
  
  # Ch3 → Ch4 (236-240小节)
  sleep 80 * 4
  $transition.execute_transition(:ch3, :ch4, 236)
  
  # Ch4 → Ch5 (316-320小节)
  sleep 80 * 4
  $transition.execute_transition(:ch4, :ch5, 316)
  
  # Ch5 → Ch6 (396-400小节)
  sleep 80 * 4
  $transition.execute_transition(:ch5, :ch6, 396)
end

puts "🎬 演出开始 - 总时长: #{$config.total_bars} 小节"