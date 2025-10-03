"""
Numus V03 核心数据结构
定义四层架构的基础类：Album, Track, Chapter, Section, Segment
以及DNA三层体系：Core DNA, Pattern DNA, Evolution Parameters
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from enum import Enum
import json


# ==================== DNA 三层体系 ====================

@dataclass
class CoreDNA:
    """核心基因：不可变的音乐本质"""
    scale: str  # 调性，如 "C_major", "A_minor"
    tempo: int  # BPM速度
    key_signature: str  # 调号
    time_signature: Tuple[int, int]  # 拍号，如 (4, 4)
    style_template: str  # 风格模板，如 "deep_house", "trance"
    
    def to_dict(self) -> dict:
        return {
            "scale": self.scale,
            "tempo": self.tempo,
            "key_signature": self.key_signature,
            "time_signature": list(self.time_signature),
            "style_template": self.style_template
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["time_signature"] = tuple(data["time_signature"])
        return cls(**data)


@dataclass
class PatternDNA:
    """模式基因：可演化的音乐模式"""
    melody_seeds: List[List[str]]  # 旋律种子，音符列表
    chord_progressions: List[List[str]]  # 和弦进行
    rhythm_templates: Dict[str, List[int]]  # 节奏模板
    harmonic_functions: List[str]  # 和声功能序列
    arrangement_patterns: Dict[str, List[str]]  # 编曲模式
    
    def to_dict(self) -> dict:
        return {
            "melody_seeds": self.melody_seeds,
            "chord_progressions": self.chord_progressions,
            "rhythm_templates": self.rhythm_templates,
            "harmonic_functions": self.harmonic_functions,
            "arrangement_patterns": self.arrangement_patterns
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        return cls(**data)


@dataclass
class EvolutionParameters:
    """演化参数：数学驱动的变化因子"""
    math_sequence: str  # 使用的数学序列 "pi", "e", "phi"
    sequence_start: int  # 序列起始位置
    sequence_length: int  # 使用的序列长度
    transformation_functions: List[str]  # 变换函数列表
    variation_ranges: Dict[str, Tuple[float, float]]  # 各参数的变化范围
    progression_curve: str  # 发展曲线类型 "linear", "exponential", "sinusoidal"
    
    def to_dict(self) -> dict:
        return {
            "math_sequence": self.math_sequence,
            "sequence_start": self.sequence_start,
            "sequence_length": self.sequence_length,
            "transformation_functions": self.transformation_functions,
            "variation_ranges": {k: list(v) for k, v in self.variation_ranges.items()},
            "progression_curve": self.progression_curve
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["variation_ranges"] = {k: tuple(v) for k, v in data["variation_ranges"].items()}
        return cls(**data)


# ==================== 四层架构 ====================

class SegmentType(Enum):
    """Segment类型枚举"""
    # 节奏类
    KICK_PATTERN = "kick_pattern"
    HIHAT_SEQUENCE = "hihat_sequence"
    PERCUSSION_LAYER = "percussion_layer"
    
    # 和声类
    BASS_LINE = "bass_line"
    CHORD_PROGRESSION = "chord_progression"
    HARMONIC_PAD = "harmonic_pad"
    
    # 旋律类
    LEAD_MELODY = "lead_melody"
    ARPEGGIO_PATTERN = "arpeggio_pattern"
    ORNAMENTAL_PHRASE = "ornamental_phrase"
    
    # 音色类
    SYNTH_PATCH = "synth_patch"
    FILTER_AUTOMATION = "filter_automation"
    EFFECT_PROCESSING = "effect_processing"


@dataclass
class Segment:
    """最小可执行音乐单元（4-16小节）"""
    id: str
    name: str
    segment_type: SegmentType
    duration_bars: int  # 时长（小节数）
    
    # 音乐内容
    musical_content: Dict  # 具体的音乐参数和数据
    
    # 元数据
    energy_level: float  # 能量等级 0.0-1.0
    complexity: float  # 复杂度 0.0-1.0
    tags: List[str]  # 标签，如 ["foundation", "driving", "atmospheric"]
    
    # 车载优化
    car_audio_boost: Dict[str, float]  # 频段增益 {"bass": 1.2, "mid": 1.0, "high": 1.1}
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "segment_type": self.segment_type.value,
            "duration_bars": self.duration_bars,
            "musical_content": self.musical_content,
            "energy_level": self.energy_level,
            "complexity": self.complexity,
            "tags": self.tags,
            "car_audio_boost": self.car_audio_boost
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["segment_type"] = SegmentType(data["segment_type"])
        return cls(**data)


class SectionType(Enum):
    """Section类型枚举（EDM标准结构）"""
    INTRO = "intro"
    BUILD_UP = "build_up"
    DROP = "drop"
    BREAKDOWN = "breakdown"
    OUTRO = "outro"


@dataclass
class Section:
    """音乐段落（8-32小节，30秒-2分钟）"""
    id: str
    name: str
    section_type: SectionType
    duration_bars: int
    
    # Segment组合
    segments: List[str]  # Segment ID列表
    segment_sequence: List[Dict]  # Segment播放序列和参数
    
    # 音乐特征
    energy_start: float
    energy_end: float
    musical_function: str  # 音乐功能描述
    
    # 元素配置
    active_elements: List[str]  # 活跃的音乐元素 ["kick", "bass", "pad", "lead"]
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "section_type": self.section_type.value,
            "duration_bars": self.duration_bars,
            "segments": self.segments,
            "segment_sequence": self.segment_sequence,
            "energy_start": self.energy_start,
            "energy_end": self.energy_end,
            "musical_function": self.musical_function,
            "active_elements": self.active_elements
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["section_type"] = SectionType(data["section_type"])
        return cls(**data)


@dataclass
class Chapter:
    """EDM短曲（2-7分钟，完整的EDM作品）"""
    id: str
    name: str
    duration_bars: int
    
    # Section结构
    sections: List[Section]
    
    # 音乐特征
    style: str  # EDM风格 "deep_house", "trance", "progressive"
    energy_profile: Dict[str, float]  # 能量曲线 {"start": 0.3, "peak": 0.8, "end": 0.5}
    
    # 个性特征
    character_tags: List[str]  # 个性标签 ["atmospheric", "driving", "emotional"]
    dominant_elements: List[str]  # 主导元素
    
    # DNA应用
    pattern_dna_variant: Optional[Dict] = None  # 局部Pattern DNA变体
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "duration_bars": self.duration_bars,
            "sections": [s.to_dict() for s in self.sections],
            "style": self.style,
            "energy_profile": self.energy_profile,
            "character_tags": self.character_tags,
            "dominant_elements": self.dominant_elements,
            "pattern_dna_variant": self.pattern_dna_variant
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["sections"] = [Section.from_dict(s) for s in data["sections"]]
        return cls(**data)


class TransitionType(Enum):
    """Chapter间过渡类型"""
    ENERGY_CROSSFADE = "energy_crossfade"
    FILTER_SWEEP = "filter_sweep"
    BREAKDOWN_BUILD = "breakdown_build"
    IMPACT_DROP = "impact_drop"


@dataclass
class ChapterTransition:
    """Chapter间的DJ过渡"""
    from_chapter_id: str
    to_chapter_id: str
    transition_type: TransitionType
    duration_bars: int  # 过渡时长
    parameters: Dict  # 过渡参数
    
    def to_dict(self) -> dict:
        return {
            "from_chapter_id": self.from_chapter_id,
            "to_chapter_id": self.to_chapter_id,
            "transition_type": self.transition_type.value,
            "duration_bars": self.duration_bars,
            "parameters": self.parameters
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["transition_type"] = TransitionType(data["transition_type"])
        return cls(**data)


@dataclass
class Track:
    """乐曲/现场秀（20-30分钟，一场完整的EDM Live Show）"""
    id: str
    name: str
    album_name: str
    
    # 场景信息
    theme_scene: str  # 主题场景 "morning_departure", "urban_driving"
    emotion_tags: List[str]  # 情绪标签
    duration_target_minutes: float  # 目标时长（分钟）
    
    # DNA配置
    core_dna: CoreDNA
    pattern_dna: PatternDNA
    evolution_params: EvolutionParameters
    
    # Chapter序列
    chapters: List[Chapter]
    chapter_transitions: List[ChapterTransition]
    
    # 车载配置
    car_audio_profile: str  # 车载音频配置 "sedan_standard", "suv_premium", "sports_car"
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "album_name": self.album_name,
            "theme_scene": self.theme_scene,
            "emotion_tags": self.emotion_tags,
            "duration_target_minutes": self.duration_target_minutes,
            "core_dna": self.core_dna.to_dict(),
            "pattern_dna": self.pattern_dna.to_dict(),
            "evolution_params": self.evolution_params.to_dict(),
            "chapters": [c.to_dict() for c in self.chapters],
            "chapter_transitions": [t.to_dict() for t in self.chapter_transitions],
            "car_audio_profile": self.car_audio_profile
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["core_dna"] = CoreDNA.from_dict(data["core_dna"])
        data["pattern_dna"] = PatternDNA.from_dict(data["pattern_dna"])
        data["evolution_params"] = EvolutionParameters.from_dict(data["evolution_params"])
        data["chapters"] = [Chapter.from_dict(c) for c in data["chapters"]]
        data["chapter_transitions"] = [ChapterTransition.from_dict(t) for t in data["chapter_transitions"]]
        return cls(**data)
    
    def save_to_file(self, filepath: str):
        """保存Track配置到JSON文件"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
    
    @classmethod
    def load_from_file(cls, filepath: str):
        """从JSON文件加载Track配置"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return cls.from_dict(data)


@dataclass
class Album:
    """专辑（2.5-3小时，完整的车载音乐体验）"""
    name: str
    total_duration_hours: Tuple[float, float]  # 总时长范围
    car_profiles: List[str]  # 支持的车载配置
    
    # Track列表
    tracks: List[Dict[str, str]]  # [{"id": "dawn_ignition", "file": "tracks/dawn_ignition.json"}]
    
    # 专辑级元数据
    theme: str  # 专辑主题
    description: str
    
    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "total_duration_hours": list(self.total_duration_hours),
            "car_profiles": self.car_profiles,
            "tracks": self.tracks,
            "theme": self.theme,
            "description": self.description
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["total_duration_hours"] = tuple(data["total_duration_hours"])
        return cls(**data)
    
    def save_to_file(self, filepath: str):
        """保存Album配置到JSON文件"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump({"album": self.to_dict()}, f, indent=2, ensure_ascii=False)
    
    @classmethod
    def load_from_file(cls, filepath: str):
        """从JSON文件加载Album配置"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return cls.from_dict(data["album"])


# ==================== 辅助函数 ====================

def create_default_core_dna() -> CoreDNA:
    """创建默认的Core DNA"""
    return CoreDNA(
        scale="C_major",
        tempo=128,
        key_signature="C",
        time_signature=(4, 4),
        style_template="progressive_house"
    )


def create_default_pattern_dna() -> PatternDNA:
    """创建默认的Pattern DNA"""
    return PatternDNA(
        melody_seeds=[
            ["C4", "E4", "G4", "A4"],
            ["D4", "F4", "A4", "C5"]
        ],
        chord_progressions=[
            ["C", "G", "Am", "F"],
            ["Dm", "G", "C", "Am"]
        ],
        rhythm_templates={
            "four_on_floor": [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
            "offbeat_hat": [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0]
        },
        harmonic_functions=["I", "V", "vi", "IV"],
        arrangement_patterns={
            "intro": ["kick", "hat"],
            "verse": ["kick", "bass", "hat"],
            "chorus": ["kick", "bass", "hat", "lead", "pad"]
        }
    )


def create_default_evolution_params() -> EvolutionParameters:
    """创建默认的Evolution Parameters"""
    return EvolutionParameters(
        math_sequence="pi",
        sequence_start=0,
        sequence_length=1000,
        transformation_functions=["scale", "modulo", "interpolate"],
        variation_ranges={
            "pitch": (0.8, 1.2),
            "velocity": (0.7, 1.0),
            "timing": (0.95, 1.05)
        },
        progression_curve="sinusoidal"
    )