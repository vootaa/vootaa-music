import time
from typing import Dict, List, Callable
from pythonosc import udp_client

class NumusDJTransitions:
    """Numus DJ 过渡机制管理器"""
    
    def __init__(self, osc_client: udp_client.SimpleUDPClient):
        self.osc_client = osc_client
        self.transition_functions = {
            "energy_crossfade": self._energy_crossfade,
            "filter_sweep": self._filter_sweep,
            "breakdown_build": self._breakdown_build,
            "impact_drop": self._impact_drop
        }
    
    def execute_transition(self, transition_config: Dict, from_chapter: Dict, 
                         to_chapter: Dict) -> None:
        """执行章节过渡"""
        transition_type = transition_config.get("type", "energy_crossfade")
        duration_bars = transition_config.get("duration_bars", 8)
        
        print(f"执行过渡: {transition_type} ({duration_bars} 小节)")
        
        # 计算过渡时长（秒）
        bpm = 125  # 从全局配置获取
        bar_duration = (60.0 / bpm) * 4
        transition_duration = duration_bars * bar_duration
        
        # 执行对应的过渡函数
        transition_func = self.transition_functions.get(transition_type, self._energy_crossfade)
        transition_func(transition_duration, from_chapter, to_chapter, transition_config)
    
    def _energy_crossfade(self, duration: float, from_chapter: Dict, 
                         to_chapter: Dict, config: Dict) -> None:
        """能量交叉淡化过渡"""
        steps = int(duration / 0.5)  # 每0.5秒更新一次
        
        from_energy = from_chapter.get("energy_end", 0.5)
        to_energy = to_chapter.get("energy_start", 0.5)
        
        for step in range(steps):
            progress = step / steps
            current_energy = from_energy + (to_energy - from_energy) * progress
            
            # 发送能量变化
            self.osc_client.send_message("/numus/energy", [current_energy])
            
            # 车载优化：平滑过渡
            car_smoothness = config.get("car_smoothness", 1.0)
            time.sleep(0.5 / car_smoothness)
    
    def _filter_sweep(self, duration: float, from_chapter: Dict, 
                     to_chapter: Dict, config: Dict) -> None:
        """滤波器扫频过渡"""
        steps = int(duration / 0.25)
        cutoff_range = config.get("cutoff_range", [20, 20000])
        resonance = config.get("resonance", 0.3)
        
        # 第一阶段：高通滤波器扫频（移除低频）
        for step in range(steps // 2):
            progress = step / (steps // 2)
            cutoff = cutoff_range[0] + (cutoff_range[1] - cutoff_range[0]) * progress
            
            self.osc_client.send_message("/numus/filter", ["hpf", cutoff, resonance])
            time.sleep(0.25)
        
        # 切换章节元素
        self.osc_client.send_message("/numus/chapter_switch", [to_chapter["id"]])
        
        # 第二阶段：恢复全频谱
        for step in range(steps // 2):
            progress = step / (steps // 2)
            cutoff = cutoff_range[1] - (cutoff_range[1] - cutoff_range[0]) * progress
            
            self.osc_client.send_message("/numus/filter", ["hpf", cutoff, resonance])
            time.sleep(0.25)
        
        # 移除滤波器
        self.osc_client.send_message("/numus/filter", ["off"])
    
    def _breakdown_build(self, duration: float, from_chapter: Dict, 
                        to_chapter: Dict, config: Dict) -> None:
        """分解重建过渡"""
        fade_order = config.get("elements_fade_order", ["kick", "bass", "lead", "pad"])
        riser_intro = config.get("riser_introduction", 8)
        
        # 第一阶段：逐步移除元素
        fade_duration = duration * 0.6
        element_fade_time = fade_duration / len(fade_order)
        
        for element in fade_order:
            self.osc_client.send_message("/numus/element_fade", [element, 0, element_fade_time])
            time.sleep(element_fade_time)
        
        # 第二阶段：引入 Riser
        if riser_intro > 0:
            self.osc_client.send_message("/numus/riser", [1, riser_intro])
            time.sleep(riser_intro * (60.0 / 125))  # 转换为秒
        
        # 第三阶段：新章节爆发
        self.osc_client.send_message("/numus/chapter_drop", [to_chapter["id"]])
        
        # 车载优化：增强期待感
        car_anticipation = config.get("car_anticipation", 1.0)
        if car_anticipation > 1.0:
            self.osc_client.send_message("/numus/car_excitement", [car_anticipation])
    
    def _impact_drop(self, duration: float, from_chapter: Dict, 
                    to_chapter: Dict, config: Dict) -> None:
        """冲击降落过渡"""
        silence_beats = config.get("silence_beats", 1)
        impact_sample = config.get("impact_sample", ":bd_boom")
        
        # 突然静音
        self.osc_client.send_message("/numus/emergency_stop", [])
        
        # 短暂静音
        silence_duration = silence_beats * (60.0 / 125)
        time.sleep(silence_duration)
        
        # 冲击音效
        car_punch = config.get("car_punch", 1.0)
        self.osc_client.send_message("/numus/impact", [impact_sample, car_punch])
        
        # 立即启动新章节
        self.osc_client.send_message("/numus/chapter_start", [to_chapter["id"]])