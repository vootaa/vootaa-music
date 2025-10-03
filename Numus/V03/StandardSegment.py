"""
Segment素材标准结构定义
定义从Sonic Pi代码提取的Segment的标准化格式
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any
from enum import Enum
import json


class SegmentCategory(Enum):
    """Segment大类"""
    RHYTHM = "rhythm"          # 节奏类
    HARMONY = "harmony"        # 和声类
    MELODY = "melody"          # 旋律类
    TEXTURE = "texture"        # 音色质感类
    FX = "fx"                  # 特效类
    ATMOSPHERE = "atmosphere"  # 氛围类


class SegmentSubType(Enum):
    """Segment细分类型"""
    # 节奏类
    KICK_PATTERN = "kick_pattern"
    SNARE_PATTERN = "snare_pattern"
    HIHAT_PATTERN = "hihat_pattern"
    PERCUSSION_LAYER = "percussion_layer"
    FULL_DRUM_KIT = "full_drum_kit"
    BREAKBEAT = "breakbeat"
    
    # 和声类
    BASS_LINE = "bass_line"
    CHORD_PROGRESSION = "chord_progression"
    PAD = "pad"
    SUB_BASS = "sub_bass"
    
    # 旋律类
    LEAD_MELODY = "lead_melody"
    ARPEGGIO = "arpeggio"
    HOOK = "hook"
    ORNAMENT = "ornament"
    
    # 音色质感类
    SYNTH_TEXTURE = "synth_texture"
    NOISE_LAYER = "noise_layer"
    
    # 特效类
    RISER = "riser"
    IMPACT = "impact"
    TRANSITION = "transition"
    
    # 氛围类
    AMBIENT_LAYER = "ambient_layer"
    FIELD_RECORDING = "field_recording"


@dataclass
class SonicPiCode:
    """Sonic Pi代码封装"""
    main_code: str  # 主要演奏代码
    live_loop_name: str  # live_loop名称
    dependencies: List[str] = field(default_factory=list)  # 依赖的其他函数或定义
    setup_code: Optional[str] = None  # 初始化代码（如use_bpm, use_synth等）
    
    def to_dict(self) -> dict:
        return {
            "main_code": self.main_code,
            "live_loop_name": self.live_loop_name,
            "dependencies": self.dependencies,
            "setup_code": self.setup_code
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        return cls(**data)


@dataclass
class MusicalParameters:
    """音乐参数"""
    duration_bars: int = 4  # 默认4小节，放在前面作为必需字段
    
    # 音高相关（全部可选）
    notes: Optional[List[str]] = None
    scale: Optional[str] = None
    root_note: Optional[str] = None
    
    # 节奏相关
    pattern: Optional[List[int]] = None
    subdivisions: Optional[int] = None
    swing: Optional[float] = None
    
    # 音色相关
    synth: Optional[str] = None
    sample: Optional[str] = None
    
    # 动态相关
    amp_range: Optional[tuple] = None
    velocity_curve: Optional[str] = None
    
    # 效果器
    effects: Optional[Dict[str, Any]] = None
    
    # 时间相关
    bpm: Optional[int] = None
    
    def to_dict(self) -> dict:
        data = {
            "notes": self.notes,
            "scale": self.scale,
            "root_note": self.root_note,
            "pattern": self.pattern,
            "subdivisions": self.subdivisions,
            "swing": self.swing,
            "synth": self.synth,
            "sample": self.sample,
            "amp_range": list(self.amp_range) if self.amp_range else None,
            "velocity_curve": self.velocity_curve,
            "effects": self.effects,
            "duration_bars": self.duration_bars,
            "bpm": self.bpm
        }
        return {k: v for k, v in data.items() if v is not None}
    
    @classmethod
    def from_dict(cls, data: dict):
        if data.get("amp_range"):
            data["amp_range"] = tuple(data["amp_range"])
        return cls(**data)


@dataclass
class SegmentMetadata:
    """Segment元数据"""
    source_file: str  # 原始文件名（必需）
    extraction_date: str  # 提取日期（必需）
    energy_level: float = 0.5  # 能量等级 0.0-1.0
    complexity: float = 0.5  # 复杂度 0.0-1.0
    
    # 可选字段
    author: Optional[str] = None
    genre_tags: List[str] = field(default_factory=list)
    mood_tags: List[str] = field(default_factory=list)
    element_tags: List[str] = field(default_factory=list)
    suitable_sections: List[str] = field(default_factory=list)
    car_audio_optimization: Dict[str, float] = field(default_factory=dict)
    
    def to_dict(self) -> dict:
        return {
            "source_file": self.source_file,
            "extraction_date": self.extraction_date,
            "author": self.author,
            "genre_tags": self.genre_tags,
            "mood_tags": self.mood_tags,
            "element_tags": self.element_tags,
            "suitable_sections": self.suitable_sections,
            "energy_level": self.energy_level,
            "complexity": self.complexity,
            "car_audio_optimization": self.car_audio_optimization
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        return cls(**data)


@dataclass
class StandardSegment:
    """标准化的Segment素材"""
    # 必需字段（无默认值）
    id: str
    name: str
    category: SegmentCategory
    sub_type: SegmentSubType
    sonic_pi_code: SonicPiCode
    musical_params: MusicalParameters
    metadata: SegmentMetadata
    
    # 可选字段（有默认值）
    version: str = "1.0"
    math_adaptable: bool = False
    variations: Optional[List[Dict]] = None
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "category": self.category.value,
            "sub_type": self.sub_type.value,
            "version": self.version,
            "sonic_pi_code": self.sonic_pi_code.to_dict(),
            "musical_params": self.musical_params.to_dict(),
            "metadata": self.metadata.to_dict(),
            "variations": self.variations,
            "math_adaptable": self.math_adaptable
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        data["category"] = SegmentCategory(data["category"])
        data["sub_type"] = SegmentSubType(data["sub_type"])
        data["sonic_pi_code"] = SonicPiCode.from_dict(data["sonic_pi_code"])
        data["musical_params"] = MusicalParameters.from_dict(data["musical_params"])
        data["metadata"] = SegmentMetadata.from_dict(data["metadata"])
        return cls(**data)
    
    def save_to_file(self, filepath: str):
        """保存到JSON文件"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
    
    @classmethod
    def load_from_file(cls, filepath: str):
        """从JSON文件加载"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return cls.from_dict(data)