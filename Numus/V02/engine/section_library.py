import json
from pathlib import Path
from typing import Dict, List, Any, Optional

class NumusSectionLibrary:
    """Numus Section 素材库管理器"""
    
    def __init__(self, config_path: str = "sections/sections_config.json"):
        self.config_path = Path(config_path)
        self.sections = {}
        self.transitions = {}
        self.car_profiles = {}
        self.load_library()
    
    def load_library(self) -> bool:
        """加载 Section 配置库"""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            self.sections = config.get("section_library", {})
            self.transitions = config.get("dj_transitions", {})
            self.car_profiles = config.get("car_audio_profiles", {})
            
            print(f"已加载 {len(self.sections)} 个 Section 模板")
            return True
            
        except Exception as e:
            print(f"加载 Section 库失败: {e}")
            return False
    
    def get_section_by_energy(self, energy_level: float, style_preference: str = None) -> Optional[Dict]:
        """根据能量等级获取合适的 Section"""
        suitable_sections = []
        
        for section_name, section_data in self.sections.items():
            energy_range = section_data.get("energy_range", [0, 1])
            
            if energy_range[0] <= energy_level <= energy_range[1]:
                # 如果有风格偏好，优先匹配
                if style_preference and section_data.get("style") == style_preference:
                    return {**section_data, "name": section_name}
                suitable_sections.append({**section_data, "name": section_name})
        
        # 返回最匹配的 Section
        if suitable_sections:
            # 简单选择：返回能量范围最接近的
            return min(suitable_sections, 
                      key=lambda s: abs((s["energy_range"][0] + s["energy_range"][1]) / 2 - energy_level))
        
        return None
    
    def get_transition(self, from_energy: float, to_energy: float, 
                      transition_type: str = "auto") -> Dict:
        """获取过渡配置"""
        if transition_type == "auto":
            energy_diff = abs(to_energy - from_energy)
            
            if energy_diff > 0.4:
                transition_type = "breakdown_build"
            elif energy_diff > 0.2:
                transition_type = "filter_sweep"
            else:
                transition_type = "energy_crossfade"
        
        return self.transitions.get(transition_type, self.transitions["energy_crossfade"])
    
    def apply_car_profile(self, section_data: Dict, profile_name: str = "sedan_standard") -> Dict:
        """应用车载音频配置"""
        car_profile = self.car_profiles.get(profile_name, self.car_profiles["sedan_standard"])
        
        # 深拷贝避免修改原始数据
        import copy
        modified_section = copy.deepcopy(section_data)
        
        # 应用车载优化到各元素
        for element_name, element_data in modified_section.get("elements", {}).items():
            # 应用全局车载参数
            if "amp" in element_data:
                if "car_boost" in element_data:
                    element_data["amp"] *= element_data["car_boost"]
                elif "car_emphasis" in element_data:
                    element_data["amp"] *= element_data["car_emphasis"]
            
            # 应用频率调整
            if "bass" in element_name.lower():
                if "amp" in element_data:
                    element_data["amp"] *= car_profile["bass_boost"]
            elif "lead" in element_name.lower() or "pad" in element_name.lower():
                if "amp" in element_data:
                    element_data["amp"] *= car_profile["midrange_clarity"]
        
        return modified_section
    
    def generate_section_ruby_code(self, section_data: Dict, chapter_id: str) -> str:
        """将 Section 配置转换为 Ruby 代码"""
        ruby_code = f"# Section: {section_data.get('name', 'unknown')}\n"
        ruby_code += f"# Style: {section_data.get('style', 'generic')}\n\n"
        
        elements = section_data.get("elements", {})
        
        for element_name, element_config in elements.items():
            loop_name = f"{chapter_id}_{element_name}"
            
            ruby_code += f"live_loop :{loop_name}, sync: :met do\n"
            ruby_code += f"  stop unless get(:chapter_{chapter_id}_active)\n\n"
            
            # 根据元素类型生成代码
            if "synth" in element_config:
                ruby_code += self._generate_synth_code(element_config)
            elif "sample" in element_config:
                ruby_code += self._generate_sample_code(element_config)
            
            ruby_code += f"  sleep {element_config.get('sleep', 1)}\n"
            ruby_code += "end\n\n"
        
        return ruby_code
    
    def _generate_synth_code(self, element_config: Dict) -> str:
        """生成合成器 Ruby 代码"""
        code = f"  use_synth :{element_config['synth']}\n"
        
        # 添加合成器参数
        synth_params = []
        for param in ["attack", "sustain", "release", "cutoff", "amp"]:
            if param in element_config:
                synth_params.append(f"{param}: {element_config[param]}")
        
        if synth_params:
            code += f"  use_synth_defaults {', '.join(synth_params)}\n"
        
        # 添加音符播放
        if "notes" in element_config:
            notes = element_config["notes"]
            if isinstance(notes, list):
                code += f"  notes = ring({', '.join(notes)})\n"
                code += "  play notes.tick\n"
            else:
                code += f"  play {notes}\n"
        
        return code
    
    def _generate_sample_code(self, element_config: Dict) -> str:
        """生成采样 Ruby 代码"""
        sample_name = element_config["sample"]
        
        code = f"  sample {sample_name}"
        
        # 添加采样参数
        sample_params = []
        for param in ["amp", "rate", "pan"]:
            if param in element_config:
                sample_params.append(f"{param}: {element_config[param]}")
        
        if sample_params:
            code += f", {', '.join(sample_params)}"
        
        code += "\n"
        return code