import json
import time
from pathlib import Path
from pythonosc import udp_client
from typing import Dict, List, Any

from math_generator import NumusGenerator
from midi_renderer import NumusMIDIRenderer

class NumusEngine:
    """Numus 核心引擎 - 驱动音乐作品生成和播放"""
    
    def __init__(self, sonic_pi_host: str = "127.0.0.1", sonic_pi_port: int = 4560):
        self.generator = NumusGenerator()
        self.renderer = NumusMIDIRenderer()
        self.osc_client = udp_client.SimpleUDPClient(sonic_pi_host, sonic_pi_port)
        
        self.current_track = None
        self.current_chapter_idx = 0
        self.global_start_time = None
        self.ornament_cache = {}
    
    def load_track(self, track_path: str) -> bool:
        """加载作品配置"""
        try:
            with open(track_path, 'r', encoding='utf-8') as f:
                self.current_track = json.load(f)
            print(f"已加载作品: {self.current_track['name']}")
            return True
        except Exception as e:
            print(f"加载作品失败: {e}")
            return False
    
    def prepare_track(self) -> bool:
        """预处理作品 - 生成能量曲线和装饰音"""
        if not self.current_track:
            return False
        
        print("预处理作品...")
        
        # 生成全局能量曲线
        chapters = self.current_track["chapters"]
        self.energy_curve = self.generator.generate_energy_curve(chapters)
        
        # 预渲染装饰音
        track_name = self.current_track["name"]
        
        for i, chapter in enumerate(chapters):
            chapter_name = chapter["id"]
            triggers = self.generator.generate_ornament_triggers(i, chapter["duration_bars"])
            
            rendered_ornaments = []
            for trigger in triggers[:3]:  # 限制每章节最多3个装饰
                ornament_path = self.renderer.render_ornament(track_name, chapter_name, trigger)
                if ornament_path:
                    rendered_ornaments.append({
                        "path": ornament_path,
                        "trigger": trigger
                    })
            
            self.ornament_cache[chapter_name] = rendered_ornaments
            print(f"  章节 {i+1}: 生成 {len(rendered_ornaments)} 个装饰音")
        
        return True
    
    def send_osc(self, address: str, *args) -> None:
        """发送 OSC 消息到 Sonic Pi"""
        self.osc_client.send_message(f"/numus/{address}", list(args))
    
    def play_track(self) -> None:
        """播放完整作品"""
        if not self.current_track:
            print("错误: 未加载作品")
            return
        
        print(f"\n开始播放: {self.current_track['name']}")
        print("=" * 50)
        
        # 初始化 Sonic Pi
        self.send_osc("init", self.current_track["global_bpm"])
        time.sleep(1)
        
        self.global_start_time = time.time()
        
        # 播放各章节
        for i, chapter in enumerate(self.current_track["chapters"]):
            self.play_chapter(i, chapter)
        
        # 结束
        total_time = time.time() - self.global_start_time
        print(f"\n播放完成，总时长: {total_time/60:.1f} 分钟")
        self.send_osc("stop")
    
    def play_chapter(self, chapter_idx: int, chapter: Dict) -> None:
        """播放单个章节"""
        self.current_chapter_idx = chapter_idx
        
        # 计算章节时长
        bpm = self.current_track["global_bpm"]
        beats_per_bar = 4
        bar_duration = (60.0 / bpm) * beats_per_bar
        chapter_duration = chapter["duration_bars"] * bar_duration
        
        print(f"\n章节 {chapter_idx + 1}: {chapter['name']}")
        print(f"  时长: {chapter['duration_bars']} 小节 ({chapter_duration:.1f}秒)")
        
        # 发送章节信息
        self.send_osc("chapter", chapter_idx, chapter["energy_start"], chapter["energy_end"])
        
        # 激活元素
        for element in chapter["elements"]:
            self.send_osc("element", element, 1)
        
        # 章节主循环
        start_time = time.time()
        last_ornament_time = 0
        
        while time.time() - start_time < chapter_duration:
            elapsed = time.time() - start_time
            progress = elapsed / chapter_duration
            
            # 计算当前能量
            energy = chapter["energy_start"] + (chapter["energy_end"] - chapter["energy_start"]) * progress
            self.send_osc("energy", energy)
            
            # 触发装饰音
            if elapsed - last_ornament_time > 8:  # 最少间隔8秒
                self._trigger_ornament(chapter["id"], progress)
                last_ornament_time = elapsed
            
            time.sleep(0.5)  # 500ms 更新间隔
        
        # 关闭元素
        for element in chapter["elements"]:
            self.send_osc("element", element, 0)
    
    def _trigger_ornament(self, chapter_id: str, progress: float) -> None:
        """触发章节装饰音"""
        if chapter_id not in self.ornament_cache:
            return
        
        ornaments = self.ornament_cache[chapter_id]
        if not ornaments:
            return
        
        # 选择装饰音（基于进度）
        ornament_idx = int(progress * len(ornaments))
        if ornament_idx < len(ornaments):
            ornament = ornaments[ornament_idx]
            self.send_osc("sample", ornament["path"], 0.6)
            print(f"    装饰音: {ornament['trigger']['type']}")

# 主函数
def main():
    """主程序入口"""
    engine = NumusEngine()
    
    # 加载 Dawn Ignition
    if not engine.load_track("tracks/dawn_ignition.json"):
        return
    
    # 预处理
    if not engine.prepare_track():
        print("预处理失败")
        return
    
    try:
        # 播放
        engine.play_track()
    except KeyboardInterrupt:
        print("\n用户中断")
        engine.send_osc("stop")
    except Exception as e:
        print(f"\n播放错误: {e}")
        engine.send_osc("stop")

if __name__ == "__main__":
    main()