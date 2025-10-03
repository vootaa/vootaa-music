import math
from typing import List, Dict, Any

class NumusMathGenerator:
    """Numus 数学序列生成器 - 确定性音乐参数生成"""
    
    def __init__(self):
        # 预计算常用数学常数的小数位
        self.pi_digits = self._extract_digits(math.pi, 2000)
        self.e_digits = self._extract_digits(math.e, 2000)
        self.phi_digits = self._extract_digits((1 + math.sqrt(5)) / 2, 2000)
    
    def _extract_digits(self, number: float, length: int) -> List[int]:
        """提取数字小数位为整数列表"""
        decimal_str = f"{number:.{length}f}".split('.')[1]
        return [int(d) for d in decimal_str[:length]]
    
    def get_sequence(self, source: str, start: int, length: int) -> List[float]:
        """获取归一化序列 [0,1]"""
        if source == "pi":
            digits = self.pi_digits[start:start+length]
        elif source == "e":
            digits = self.e_digits[start:start+length]
        elif source == "phi":
            digits = self.phi_digits[start:start+length]
        else:
            raise ValueError(f"未知序列源: {source}")
        
        return [d / 9.0 for d in digits]
    
    def generate_energy_curve(self, chapters: List[Dict], source: str = "pi") -> List[float]:
        """为章节列表生成能量曲线"""
        total_bars = sum(ch["duration_bars"] for ch in chapters)
        sequence = self.get_sequence(source, 0, total_bars)
        
        # 应用章节能量约束
        energy_curve = []
        bar_idx = 0
        
        for chapter in chapters:
            chapter_length = chapter["duration_bars"]
            start_energy = chapter["energy_start"]
            end_energy = chapter["energy_end"]
            
            for i in range(chapter_length):
                progress = i / chapter_length
                base_energy = start_energy + (end_energy - start_energy) * progress
                
                # 用数学序列调制 ±20%
                modulation = (sequence[bar_idx] - 0.5) * 0.4
                final_energy = max(0.0, min(1.0, base_energy + modulation))
                
                energy_curve.append(final_energy)
                bar_idx += 1
        
        return energy_curve
    
    def generate_ornament_triggers(self, chapter_idx: int, bars: int) -> List[Dict]:
        """生成装饰音触发点"""
        # 每个章节使用不同的序列偏移
        offset = chapter_idx * 100
        pi_seq = self.get_sequence("pi", offset, bars * 4)  # 每小节4个检查点
        
        triggers = []
        for bar in range(bars):
            for beat in range(4):
                idx = bar * 4 + beat
                if idx < len(pi_seq) and pi_seq[idx] > 0.85:  # 15% 概率触发
                    triggers.append({
                        "bar": bar,
                        "beat": beat,
                        "intensity": pi_seq[idx],
                        "type": self._select_ornament_type(pi_seq[idx])
                    })
        
        return triggers
    
    def _select_ornament_type(self, value: float) -> str:
        """根据数值选择装饰类型"""
        if value > 0.95:
            return "bell"
        elif value > 0.9:
            return "lead"
        else:
            return "pad"s