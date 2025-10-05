# V02 主程序：完整版

load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/config.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/irrational_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/energy_mapper.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/master_clock.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/drum_patterns.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/drum_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/transition_system.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/bass_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/harmony_engine.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/fx_bus.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/performance_monitor.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/helpers.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/lib/preset_manager.rb"

load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/pi_wrapper.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_01.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_02.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_03.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_04.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_05.rb"
load "/Users/tsb/Pop-Proj/vootaa-music/DJ_Show/V02/modules/chapter_06.rb"

$config = V02Config.new
$irr_engine = IrrationalEngine.new($config)
$energy = EnergyMapper.new
$patterns = DrumPatterns.new
$drum_engine = DrumEngine.new($config, $patterns, $energy, $irr_engine)
$transition = TransitionSystem.new($config)
$bass_engine = BassEngine.new($config, $energy, $irr_engine)
$harmony_engine = HarmonyEngine.new($config, $energy, $irr_engine)
$piw = PIWrapper.new
$preset_manager = PresetManager.new($config)

use_bpm $config.bpm

$energy.add_segment(0, 16, 30, 40, :linear)
$energy.add_segment(16, 32, 40, 60, :exponential)
$energy.add_segment(32, 64, 60, 65, :linear)
$energy.add_segment(64, 80, 65, 50, :linear)
$energy.add_segment(80, 96, 50, 65, :linear)
$energy.add_segment(96, 112, 65, 75, :exponential)
$energy.add_segment(112, 144, 75, 75, :linear)
$energy.add_segment(144, 160, 75, 60, :linear)
$energy.add_segment(160, 240, 60, 80, :exponential)
$energy.add_segment(240, 320, 70, 70, :linear)
$energy.add_segment(320, 400, 65, 65, :linear)
$energy.add_segment(400, 496, 60, 40, :logistic)

$clock = MasterClock.new($config.bpm, $config.total_bars)
$fx_bus = FXBus.new($config, $transition)
$monitor = PerformanceMonitor.new($config, $clock, $energy)

$fx_bus.start
in_thread { $clock.start }
in_thread { $monitor.start }

in_thread { Chapter01.run }
in_thread { Chapter02.run }
in_thread { Chapter03.run }
in_thread { Chapter04.run }
in_thread { Chapter05.run }
in_thread { Chapter06.run }

in_thread { $transition.execute_transition(:ch1, :ch2, 76) }
in_thread { $transition.execute_transition(:ch2, :ch3, 156) }
in_thread { $transition.execute_transition(:ch3, :ch4, 236) }
in_thread { $transition.execute_transition(:ch4, :ch5, 316) }
in_thread { $transition.execute_transition(:ch5, :ch6, 396) }

live_loop :main_guardian do
  sleep 16
  if $clock.bar_count >= $config.total_bars
    puts "=== V02 DJ Show Completed ==="
    $drum_engine.stop_all
    $bass_engine.stop_bass
    $harmony_engine.stop_harmony
    $piw.stop_all
    $fx_bus.stop_all
    $monitor.stop_monitor
    stop
  end
end