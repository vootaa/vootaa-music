"""基础播放测试"""

from SegmentPlayer import SegmentPlayer
from StandardSegment import create_example_kick_pattern, create_example_bass_line
import time

# 初始化播放器
player = SegmentPlayer()

# 测试1：播放Kick
print("测试Kick Pattern...")
kick = create_example_kick_pattern()
track1 = player.play_segment(kick, "test", "ch1", "sec1")
time.sleep(8)  # 播放2个循环
player.stop_segment(track1)

# 测试2：播放Bass
print("测试Bass Line...")
bass = create_example_bass_line()
track2 = player.play_segment(bass, "test", "ch1", "sec1")
time.sleep(8)
player.stop_segment(track2)

# 测试3：同时播放Kick + Bass
print("测试组合...")
track1 = player.play_segment(kick, "test", "ch1", "sec1")
track2 = player.play_segment(bass, "test", "ch1", "sec1")
time.sleep(16)

player.stop_all_segments()
print("测试完成")