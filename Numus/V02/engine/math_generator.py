import math
from typing import List, Dict, Any

class NumusGenerator:
    """Numus 数学序列生成器 - 确定性音乐参数生成"""
    
    def __init__(self):
        # 预计算数学常数的小数位
        self.pi_digits = self._extract_digits(math.pi, 3000)
        self.e_digits = self._extract_digits(math.e, 3000)
        self.phi_digits = self._extract_digits((1 + math.sqrt(5)) / 2, 3000)
        
        print("数学序列生成器初始化完成")
    
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
        
        # 确保有足够的数字
        if len(digits) < length:
            # 如果不够，循环使用
            cycles_needed = (length // len(digits)) + 1
            extended_digits = (digits * cycles_needed)[:length]
            return [d / 9.0 for d in extended_digits]
        
        return [d / 9.0 for d in digits]
    
    def generate_energy_curve(self, chapters: List[Dict], source: str = "pi") -> List[float]:
        """为章节列表生成能量曲线"""
        total_bars = sum(ch["duration_bars"] for ch in chapters)
        sequence = self.get_sequence(source, 0, total_bars)
        
        energy_curve = []
        bar_idx = 0
        
        for chapter in chapters:
            chapter_length = chapter["duration_bars"]
            start_energy = chapter["energy_start"]
            end_energy = chapter["energy_end"]
            
            for i in range(chapter_length):
                progress = i / chapter_length
                base_energy = start_energy + (end_energy - start_energy) * progress
                
                # 使用数学序列进行微调（±15%）
                if bar_idx < len(sequence):
                    modulation = (sequence[bar_idx] - 0.5) * 0.3
                    final_energy = max(0.0, min(1.0, base_energy + modulation))
                else:
                    final_energy = base_energy
                
                energy_curve.append(final_energy)
                bar_idx += 1
        
        return energy_curve
    
    def generate_ornament_triggers(self, chapter_idx: int, bars: int) -> List[Dict]:
        """生成装饰音触发点"""
        offset = chapter_idx * 150  # 每个章节使用不同的序列偏移
        pi_seq = self.get_sequence("pi", offset, bars * 8)  # 每小节8个检查点
        e_seq = self.get_sequence("e", offset + 50, bars * 8)
        
        triggers = []
        
        for bar in range(bars):
            for eighth in range(8):  # 8个八分音符位置
                idx = bar * 8 + eighth
                
                if idx < len(pi_seq):
                    pi_val = pi_seq[idx]
                    e_val = e_seq[idx] if idx < len(e_seq) else 0.5
                    
                    # 使用组合条件决定触发
                    if pi_val > 0.85 and e_val > 0.6:  # 严格条件
                        ornament_type = self._select_ornament_type(pi_val, e_val)
                        
                        triggers.append({
                            "bar": bar,
                            "eighth": eighth,
                            "position": bar + eighth / 8.0,
                            "intensity": (pi_val + e_val) / 2,
                            "type": ornament_type,
                            "pi_value": pi_val,
                            "e_value": e_val
                        })
        
        return triggers
    
    def _select_ornament_type(self, pi_val: float, e_val: float) -> str:
        """根据数值组合选择装饰类型"""
        combined = (pi_val + e_val) / 2
        
        if combined > 0.95:
            return "bell"
        elif combined > 0.9:
            return "lead" 
        elif pi_val > e_val:
            return "pad"
        else:
            return "texture"
    
    def generate_rhythm_variations(self, base_pattern: List[int], 
                                 chapter_idx: int, variation_count: int = 4) -> List[List[int]]:
        """基于数学序列生成节奏变化"""
        offset = chapter_idx * 200
        phi_seq = self.get_sequence("phi", offset, len(base_pattern) * variation_count)
        
        variations = []
        
        for v in range(variation_count):
            variation = base_pattern.copy()
            
            for i in range(len(variation)):
                seq_idx = v * len(base_pattern) + i
                if seq_idx < len(phi_seq):
                    phi_val = phi_seq[seq_idx]
                    
                    # 根据黄金比例序列调整节奏
                    if phi_val > 0.8 and variation[i] == 0:
                        variation[i] = 1  # 添加重音
                    elif phi_val < 0.2 and variation[i] == 1:
                        variation[i] = 0  # 移除重音
            
            variations.append(variation)
        
        return variations
    
    def generate_harmonic_progression(self, chapter_idx: int, bars: int, 
                                    root_key: str = "Am") -> List[str]:
        """生成和声进行"""
        # 基础和弦池
        if root_key == "Am":
            chord_pool = ["Am", "F", "C", "G", "Dm", "Em", "Bb", "Ab"]
        else:
            chord_pool = ["C", "Am", "F", "G", "Dm", "Em", "Bb", "Ab"]  # 简化处理
        
        offset = chapter_idx * 300
        e_seq = self.get_sequence("e", offset, bars)
        
        progression = []
        
        for bar in range(bars):
            if bar < len(e_seq):
                e_val = e_seq[bar]
                chord_idx = int(e_val * len(chord_pool))
                chord_idx = min(chord_idx, len(chord_pool) - 1)
                progression.append(chord_pool[chord_idx])
            else:
                progression.append(chord_pool[0])  # 默认回到主和弦
        
        return progression
    
    def generate_filter_automation(self, chapter_idx: int, duration_bars: int) -> List[Dict]:
        """生成滤波器自动化"""
        offset = chapter_idx * 400
        pi_seq = self.get_sequence("pi", offset, duration_bars * 4)  # 每小节4个点
        
        automation_points = []
        
        for bar in range(duration_bars):
            for beat in range(4):
                idx = bar * 4 + beat
                
                if idx < len(pi_seq):
                    pi_val = pi_seq[idx]
                    
                    # 将 pi 值映射到滤波器参数
                    cutoff = 30 + (pi_val * 100)  # 30-130 Hz
                    resonance = pi_val * 0.8      # 0-0.8
                    
                    automation_points.append({
                        "bar": bar,
                        "beat": beat,
                        "cutoff": cutoff,
                        "resonance": resonance,
                        "position": bar + beat / 4.0
                    })
        
        return automation_points