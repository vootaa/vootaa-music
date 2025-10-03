"""
Segment素材标准结构定义（V03修正版）
定义纯参数化的Segment结构，不包含Sonic Pi代码
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any
from enum import Enum
import json


class SegmentCategory(Enum):
    """Segment大类"""
    RHYTHM = "rhythm"
    HARMONY = "harmony"
    MELODY = "melody"
    TEXTURE = "texture"
    FX = "fx"
    ATMOSPHERE = "atmosphere"


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
class PlaybackParameters:
    """
    播放参数 - 纯数据结构
    这些参数会被OSC控制端解析并转换为OSC消息
    """
    # 基础参数
    duration_bars: int = 4
    bpm: Optional[int] = None  # None表示继承全局BPM
    
    # 音符/音高参数
    notes: Optional[List[str]] = None  # ["C4", "E4", "G4"] 或 ["c2", "g2"]
    scale: Optional[str] = None  # ":minor", ":major", ":minor_pentatonic"
    root_note: Optional[str] = None  # "C", "D", "E"
    
    # 节奏参数
    pattern: Optional[List[int]] = None  # [1,0,0,0,1,0,0,0] 二进制节奏模式
    subdivisions: Optional[int] = None  # 16 表示1/16精度
    swing: Optional[float] = None  # 0.0-1.0
    
    # 音色参数
    synth: Optional[str] = None  # ":blade", ":bass_foundation", ":bd_haus"
    sample: Optional[str] = None  # 仅用于内置样本，如":bd_haus", ":drum_cymbal_closed"
    
    # 动态参数
    amp: Optional[float] = 1.0
    amp_range: Optional[tuple] = None  # (min, max) 用于动态变化
    velocity_curve: Optional[str] = None  # "linear", "exponential", "random"
    
    # 包络参数
    attack: Optional[float] = None
    decay: Optional[float] = None
    sustain: Optional[float] = None
    release: Optional[float] = None
    
    # 滤波器参数
    cutoff: Optional[int] = None  # 40-130
    cutoff_min: Optional[int] = None  # 用于滤波器扫频
    cutoff_max: Optional[int] = None
    res: Optional[float] = None  # Resonance 0.0-1.0
    
    # 效果器参数
    reverb: Optional[float] = None  # 0.0-1.0
    echo: Optional[float] = None
    distortion: Optional[float] = None
    pan: Optional[float] = None  # -1.0 (左) 到 1.0 (右)
    
    # 特殊效果
    detune: Optional[float] = None  # 用于chorus效果
    wobble_rate: Optional[float] = None  # 用于bass wobble
    
    # 自动化参数
    filter_automation: Optional[str] = None  # "linear_rise", "sine_wobble"
    volume_automation: Optional[str] = None
    
    def to_dict(self) -> dict:
        """转换为字典，过滤None值"""
        return {k: v for k, v in self.__dict__.items() if v is not None}
    
    @classmethod
    def from_dict(cls, data: dict) -> 'PlaybackParameters':
        """从字典创建"""
        return cls(**{k: v for k, v in data.items() if hasattr(cls, k)})


@dataclass
class SegmentMetadata:
    """Segment元数据"""
    source_file: str
    author: Optional[str] = None
    creation_date: Optional[str] = None
    version: str = "1.0"
    description: Optional[str] = None
    
    # 适用场景
    suitable_sections: List[str] = field(default_factory=list)  # ["drop", "build_up"]
    suitable_moods: List[str] = field(default_factory=list)  # ["energetic", "dark"]
    
    # 音乐特征
    energy_level: float = 0.5  # 0.0-1.0
    complexity: float = 0.5  # 0.0-1.0
    density: float = 0.5  # 音符密度
    
    # 兼容性标签
    element_tags: List[str] = field(default_factory=list)  # ["bass", "kick", "lead"]
    style_tags: List[str] = field(default_factory=list)  # ["house", "techno", "trance"]
    mood_tags: List[str] = field(default_factory=list)  # ["uplifting", "dark", "chill"]
    
    def to_dict(self) -> dict:
        return {
            "source_file": self.source_file,
            "author": self.author,
            "creation_date": self.creation_date,
            "version": self.version,
            "description": self.description,
            "suitable_sections": self.suitable_sections,
            "suitable_moods": self.suitable_moods,
            "energy_level": self.energy_level,
            "complexity": self.complexity,
            "density": self.density,
            "element_tags": self.element_tags,
            "style_tags": self.style_tags,
            "mood_tags": self.mood_tags
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'SegmentMetadata':
        return cls(**data)


@dataclass
class StandardSegment:
    """
    标准Segment结构（V03修正版）
    只包含参数化数据，不包含Sonic Pi代码
    """
    id: str
    name: str
    category: SegmentCategory
    sub_type: SegmentSubType
    
    # 核心播放参数
    playback_params: PlaybackParameters
    
    # 元数据
    metadata: SegmentMetadata
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "category": self.category.value,
            "sub_type": self.sub_type.value,
            "playback_params": self.playback_params.to_dict(),
            "metadata": self.metadata.to_dict()
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'StandardSegment':
        return cls(
            id=data["id"],
            name=data["name"],
            category=SegmentCategory(data["category"]),
            sub_type=SegmentSubType(data["sub_type"]),
            playback_params=PlaybackParameters.from_dict(data["playback_params"]),
            metadata=SegmentMetadata.from_dict(data["metadata"])
        )
    
    def save_to_file(self, filepath: str):
        """保存为JSON文件"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
    
    @classmethod
    def load_from_file(cls, filepath: str) -> 'StandardSegment':
        """从JSON文件加载"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return cls.from_dict(data)


# ==================== Segment示例 ====================

def create_example_kick_pattern() -> StandardSegment:
    """示例：Four-on-Floor Kick Pattern"""
    return StandardSegment(
        id="kick_four_on_floor_01",
        name="Four-on-Floor Kick Pattern",
        category=SegmentCategory.RHYTHM,
        sub_type=SegmentSubType.KICK_PATTERN,
        playback_params=PlaybackParameters(
            duration_bars=4,
            pattern=[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
            synth=":bd_haus",
            amp=1.2,
            release=0.3,
            cutoff=110
        ),
        metadata=SegmentMetadata(
            source_file="kick_four_on_floor_01.json",
            author="Numus V03",
            description="经典Four-on-Floor底鼓模式",
            suitable_sections=["drop", "verse", "build_up"],
            energy_level=0.7,
            complexity=0.2,
            element_tags=["kick", "foundation", "four_on_floor"],
            style_tags=["house", "techno", "edm"]
        )
    )


def create_example_bass_line() -> StandardSegment:
    """示例：Deep House Bass Line"""
    return StandardSegment(
        id="bass_deep_house_01",
        name="Deep House Bass Line",
        category=SegmentCategory.HARMONY,
        sub_type=SegmentSubType.BASS_LINE,
        playback_params=PlaybackParameters(
            duration_bars=4,
            notes=["c2", "c2", "as1", "as1"],
            synth=":bass_foundation",
            amp=0.8,
            release=0.5,
            cutoff=80,
            res=0.3
        ),
        metadata=SegmentMetadata(
            source_file="bass_deep_house_01.json",
            description="Deep House风格低音线条",
            suitable_sections=["drop", "verse"],
            energy_level=0.6,
            complexity=0.3,
            element_tags=["bass", "groove"],
            style_tags=["deep_house", "house"]
        )
    )


if __name__ == "__main__":
    # 测试：创建并保存示例segment
    kick = create_example_kick_pattern()
    kick.save_to_file("./segments/rhythm/kick_four_on_floor_01.json")
    
    bass = create_example_bass_line()
    bass.save_to_file("./segments/harmony/bass_deep_house_01.json")
    
    print("示例Segment已生成")