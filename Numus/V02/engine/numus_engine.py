import json
import time
from pathlib import Path
from pythonosc import udp_client
from typing import Dict, List, Any

from section_library import NumusSectionLibrary
from dj_transitions import NumusDJTransitions
from math_generator import NumusGenerator
from midi_renderer import NumusMIDIRenderer

class NumusEngine:
    """Numus 核心引擎 V2.0 - 长篇车载 EDM 专用"""
    
    def __init__(self, sonic_pi_host: str = "127.0.0.1", sonic_pi_port: int = 4560):
        # 初始化模块
        self.osc_client = udp_client.SimpleUDPClient(sonic_pi_host, sonic_pi_port)
        self.section_library = NumusSectionLibrary()
        self.dj_transitions = NumusDJTransitions(self.osc_client)
        self.math_generator = NumusGenerator()
        self.midi_renderer = NumusMIDIRenderer()
        
        # 状态变量
        self.current_track = None
        self.current_chapter_idx = 0
        self.car_audio_profile = "sedan_standard"
        self.generated_sections = {}
        self.ornament_cache = {}
        
        print("Numus Engine V2.0 初始化完成")
    
    def load_track(self, track_path: str) -> bool:
        """加载音乐作品配置"""
        try:
            with open(track_path, 'r', encoding='utf-8') as f:
                self.current_track = json.load(f)
            
            print(f"已加载作品: {self.current_track['name']}")
            print(f"专辑: {self.current_track.get('album', 'Unknown')}")
            print(f"章节数: {len(self.current_track['chapters'])}")
            
            return True
        except Exception as e:
            print(f"加载作品失败: {e}")
            return False
    
    def set_car_audio_profile(self, profile_name: str) -> None:
        """设置车载音频配置"""
        available_profiles = list(self.section_library.car_profiles.keys())
        
        if profile_name in available_profiles:
            self.car_audio_profile = profile_name
            print(f"车载音频配置: {profile_name}")
        else:
            print(f"未知配置 {profile_name}，使用默认配置")
            self.car_audio_profile = "sedan_standard"
    
    def prepare_track(self) -> bool:
        """预处理音乐作品"""
        if not self.current_track:
            print("错误: 未加载作品")
            return False
        
        print("\n开始预处理...")
        
        # 1. 为每个章节分配 Section 模板
        self._assign_sections_to_chapters()
        
        # 2. 预渲染装饰采样
        self._prerender_ornaments()
        
        # 3. 生成 DJ 过渡计划
        self._plan_dj_transitions()
        
        print("预处理完成\n")
        return True
    
    def _assign_sections_to_chapters(self) -> None:
        """为章节分配 Section 模板"""
        print("分配 Section 模板...")
        
        for i, chapter in enumerate(self.current_track["chapters"]):
            energy_mid = (chapter["energy_start"] + chapter["energy_end"]) / 2
            style_hint = chapter.get("style_hint", None)
            
            # 获取合适的 Section
            section_template = self.section_library.get_section_by_energy(energy_mid, style_hint)
            
            if section_template:
                # 应用车载优化
                optimized_section = self.section_library.apply_car_profile(
                    section_template, self.car_audio_profile
                )
                
                self.generated_sections[chapter["id"]] = optimized_section
                print(f"  章节 {i+1}: {section_template['name']} ({section_template['style']})")
            else:
                print(f"  章节 {i+1}: 未找到合适的 Section 模板")
    
    def _prerender_ornaments(self) -> None:
        """预渲染装饰采样"""
        print("预渲染装饰采样...")
        
        track_name = self.current_track["name"].replace(" ", "_").lower()
        
        for i, chapter in enumerate(self.current_track["chapters"]):
            chapter_ornaments = []
            
            # 基于数学序列生成装饰触发点
            triggers = self.math_generator.generate_ornament_triggers(
                i, chapter["duration_bars"]
            )
            
            # 限制每章节装饰数量，避免过密
            max_ornaments = min(3, len(triggers))
            selected_triggers = triggers[:max_ornaments]
            
            for trigger in selected_triggers:
                ornament_path = self.midi_renderer.render_ornament(
                    track_name, chapter["id"], trigger
                )
                
                if ornament_path:
                    chapter_ornaments.append({
                        "path": ornament_path,
                        "trigger": trigger
                    })
            
            self.ornament_cache[chapter["id"]] = chapter_ornaments
            print(f"  章节 {i+1}: {len(chapter_ornaments)} 个装饰采样")
    
    def _plan_dj_transitions(self) -> None:
        """规划 DJ 过渡方案"""
        print("规划 DJ 过渡...")
        
        chapters = self.current_track["chapters"]
        
        for i in range(len(chapters) - 1):
            from_chapter = chapters[i]
            to_chapter = chapters[i + 1]
            
            # 获取过渡配置
            transition_config = self.section_library.get_transition(
                from_chapter["energy_end"],
                to_chapter["energy_start"]
            )
            
            # 保存过渡计划
            transition_key = f"{from_chapter['id']}_to_{to_chapter['id']}"
            self.current_track[f"transition_{i}"] = {
                **transition_config,
                "from_chapter": from_chapter["id"],
                "to_chapter": to_chapter["id"]
            }
            
            print(f"  {i+1}→{i+2}: {transition_config.get('type', 'energy_crossfade')}")
    
    def play_track(self) -> None:
        """播放完整作品"""
        if not self.current_track:
            print("错误: 未加载或预处理作品")
            return
        
        print("=" * 60)
        print(f"🎵 开始播放: {self.current_track['name']}")
        print(f"🚗 车载配置: {self.car_audio_profile}")
        print(f"⏱️  预计时长: {self._calculate_total_duration():.1f} 分钟")
        print("=" * 60)
        
        # 初始化 Sonic Pi
        self._initialize_sonic_pi()
        
        # 播放各章节
        start_time = time.time()
        
        for i, chapter in enumerate(self.current_track["chapters"]):
            self._play_chapter(i, chapter)
            
            # 执行章节间过渡（除了最后一个章节）
            if i < len(self.current_track["chapters"]) - 1:
                transition_key = f"transition_{i}"
                if transition_key in self.current_track:
                    next_chapter = self.current_track["chapters"][i + 1]
                    self.dj_transitions.execute_transition(
                        self.current_track[transition_key],
                        chapter,
                        next_chapter
                    )
        
        # 结束处理
        total_duration = time.time() - start_time
        print(f"\n🎉 播放完成！实际时长: {total_duration/60:.1f} 分钟")
        self._finalize_sonic_pi()
    
    def _calculate_total_duration(self) -> float:
        """计算总时长（分钟）"""
        bpm = self.current_track.get("global_bpm", 125)
        total_bars = sum(ch["duration_bars"] for ch in self.current_track["chapters"])
        
        # 加上过渡时间
        transition_bars = (len(self.current_track["chapters"]) - 1) * 8  # 平均每个过渡8小节
        
        total_bars += transition_bars
        total_minutes = (total_bars * 4 * 60) / (bpm * 60)  # 4拍每小节
        
        return total_minutes
    
    def _initialize_sonic_pi(self) -> None:
        """初始化 Sonic Pi 播放器"""
        self.osc_client.send_message("/numus/init", [
            self.current_track["global_bpm"],
            self.car_audio_profile
        ])
        time.sleep(2)  # 等待初始化完成
    
    def _play_chapter(self, chapter_idx: int, chapter: Dict) -> None:
        """播放单个章节"""
        self.current_chapter_idx = chapter_idx
        
        print(f"\n🎪 章节 {chapter_idx + 1}: {chapter['name']}")
        
        # 发送章节配置到 Sonic Pi
        if chapter["id"] in self.generated_sections:
            section_data = self.generated_sections[chapter["id"]]
            self._send_section_to_sonic_pi(chapter["id"], section_data)
        
        # 激活章节
        self.osc_client.send_message("/numus/chapter_start", [
            chapter_idx,
            chapter["energy_start"],
            chapter["energy_end"],
            chapter["duration_bars"]
        ])
        
        # 章节播放循环
        self._execute_chapter_playback(chapter)
        
        # 停用章节
        self.osc_client.send_message("/numus/chapter_stop", [chapter_idx])
    
    def _send_section_to_sonic_pi(self, chapter_id: str, section_data: Dict) -> None:
        """发送 Section 数据到 Sonic Pi"""
        # 发送 Section 的各元素配置
        for element_name, element_config in section_data.get("elements", {}).items():
            self.osc_client.send_message("/numus/section_element", [
                chapter_id,
                element_name,
                json.dumps(element_config)
            ])
    
    def _execute_chapter_playback(self, chapter: Dict) -> None:
        """执行章节播放"""
        bpm = self.current_track["global_bpm"]
        bar_duration = (60.0 / bpm) * 4
        chapter_duration = chapter["duration_bars"] * bar_duration
        
        start_time = time.time()
        last_ornament_time = 0
        
        print(f"   ⏳ 播放时长: {chapter_duration:.1f} 秒")
        
        while time.time() - start_time < chapter_duration:
            elapsed = time.time() - start_time
            progress = elapsed / chapter_duration
            
            # 更新能量等级
            current_energy = chapter["energy_start"] + \
                           (chapter["energy_end"] - chapter["energy_start"]) * progress
            
            self.osc_client.send_message("/numus/energy", [current_energy])
            
            # 触发装饰采样（稀疏）
            if elapsed - last_ornament_time > 10 and chapter["id"] in self.ornament_cache:
                self._maybe_trigger_ornament(chapter["id"], progress)
                last_ornament_time = elapsed
            
            # 每秒更新一次
            time.sleep(1.0)
    
    def _maybe_trigger_ornament(self, chapter_id: str, progress: float) -> None:
        """可能触发装饰采样"""
        ornaments = self.ornament_cache.get(chapter_id, [])
        
        if not ornaments:
            return
        
        # 基于进度选择装饰
        ornament_idx = int(progress * len(ornaments))
        
        if ornament_idx < len(ornaments):
            ornament = ornaments[ornament_idx]
            
            # 使用数学序列决定是否真的触发
            pi_value = self.math_generator.get_sequence("pi", int(progress * 100), 1)[0]
            
            if pi_value > 0.8:  # 20% 概率触发
                self.osc_client.send_message("/numus/ornament", [
                    ornament["path"],
                    ornament["trigger"]["intensity"] * 0.6
                ])
                print(f"   🎨 装饰: {ornament['trigger']['type']}")
    
    def _finalize_sonic_pi(self) -> None:
        """结束 Sonic Pi 播放"""
        self.osc_client.send_message("/numus/finalize", [])

# 主程序入口
def main():
    """主程序"""
    engine = NumusEngine()
    
    # 设置车载配置（可选）
    car_profile = input("选择车载配置 (sedan_standard/suv_premium/sports_car) [回车默认]: ").strip()
    if car_profile:
        engine.set_car_audio_profile(car_profile)
    
    # 加载作品
    if not engine.load_track("tracks/dawn_ignition.json"):
        return
    
    # 预处理
    if not engine.prepare_track():
        return
    
    try:
        # 播放
        input("按回车开始播放 Dawn Ignition...")
        engine.play_track()
        
    except KeyboardInterrupt:
        print("\n⏹️  用户中断播放")
        engine.osc_client.send_message("/numus/emergency_stop", [])
    except Exception as e:
        print(f"\n❌ 播放错误: {e}")
        engine.osc_client.send_message("/numus/emergency_stop", [])

if __name__ == "__main__":
    main()