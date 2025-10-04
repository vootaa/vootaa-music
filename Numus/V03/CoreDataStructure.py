"""
Numus V03 核心数据结构
定义 Album、Track、Chapter、Section 的完整数据结构
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any
from enum import Enum
import json
from pathlib import Path


# ==================== 枚举类型定义 ====================

class TransitionType(Enum):
    """Chapter间过渡类型"""
    ENERGY_CROSSFADE = "energy_crossfade"  # 能量平滑过渡
    FILTER_SWEEP = "filter_sweep"  # 滤波器扫频
    BREAKDOWN_BUILD = "breakdown_build"  # 分解重建
    IMPACT_DROP = "impact_drop"  # 冲击降落


class SectionType(Enum):
    """Section功能类型"""
    INTRO = "intro"
    BUILD_UP = "build_up"
    DROP = "drop"
    BREAKDOWN = "breakdown"
    VERSE = "verse"
    BRIDGE = "bridge"
    OUTRO = "outro"
    TRANSITION = "transition"


class CarAudioProfile(Enum):
    """车载音频优化配置"""
    STANDARD = "standard"  # 标准配置
    BASS_BOOST = "bass_boost"  # 低音增强
    CLEAR_VOCAL = "clear_vocal"  # 人声清晰
    WIDE_STEREO = "wide_stereo"  # 立体声宽度


# ==================== DNA 三层体系 ====================

@dataclass
class CoreDNA:
    """
    核心DNA - 定义音乐的基础属性
    在Album级别定义，Track级别可以有变体
    """
    tempo: int  # BPM
    time_signature: str = "4/4"  # 拍号
    key: str = "C"  # 调性（C, D, E, F, G, A, B）
    mode: str = "minor"  # 调式（major, minor）
    scale: str = "minor_pentatonic"  # 音阶类型
    
    # 车载音频优化
    car_audio_profile: CarAudioProfile = CarAudioProfile.STANDARD
    car_audio_boost: Dict[str, float] = field(default_factory=lambda: {
        "sub_bass": 1.2,  # 30-60Hz
        "bass": 1.1,  # 60-250Hz
        "mid": 1.0,  # 250-2000Hz
        "high": 1.05  # 2000Hz+
    })
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "tempo": self.tempo,
            "time_signature": self.time_signature,
            "key": self.key,
            "mode": self.mode,
            "scale": self.scale,
            "car_audio_profile": self.car_audio_profile.value,
            "car_audio_boost": self.car_audio_boost
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'CoreDNA':
        """从字典创建"""
        car_audio_profile = CarAudioProfile(data.get("car_audio_profile", "standard"))
        return cls(
            tempo=data["tempo"],
            time_signature=data.get("time_signature", "4/4"),
            key=data.get("key", "C"),
            mode=data.get("mode", "minor"),
            scale=data.get("scale", "minor_pentatonic"),
            car_audio_profile=car_audio_profile,
            car_audio_boost=data.get("car_audio_boost", {
                "sub_bass": 1.2,
                "bass": 1.1,
                "mid": 1.0,
                "high": 1.05
            })
        )


@dataclass
class PatternDNA:
    """
    模式DNA - 定义旋律、和声、节奏的种子
    在Track级别定义，Chapter级别可以有细粒度变体
    """
    # 旋律种子
    melody_seeds: List[str] = field(default_factory=lambda: ["C4", "D4", "E4", "G4"])
    
    # 和弦进行
    chord_progressions: List[List[str]] = field(default_factory=lambda: [
        ["Cm", "Gm", "Ab", "Bb"],
        ["Cm", "Fm", "Ab", "Bb"]
    ])
    
    # 节奏模式（16步）
    kick_pattern: List[int] = field(default_factory=lambda: [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0])
    snare_pattern: List[int] = field(default_factory=lambda: [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0])
    hihat_pattern: List[int] = field(default_factory=lambda: [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0])
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "melody_seeds": self.melody_seeds,
            "chord_progressions": self.chord_progressions,
            "kick_pattern": self.kick_pattern,
            "snare_pattern": self.snare_pattern,
            "hihat_pattern": self.hihat_pattern
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'PatternDNA':
        """从字典创建"""
        return cls(
            melody_seeds=data.get("melody_seeds", ["C4", "D4", "E4", "G4"]),
            chord_progressions=data.get("chord_progressions", [
                ["Cm", "Gm", "Ab", "Bb"]
            ]),
            kick_pattern=data.get("kick_pattern", [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]),
            snare_pattern=data.get("snare_pattern", [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0]),
            hihat_pattern=data.get("hihat_pattern", [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0])
        )


@dataclass
class EvolutionParameters:
    """
    演化参数 - 定义数学序列如何驱动音乐变化
    仅在Chapter和Section层面应用
    """
    # 数学序列类型
    sequence_type: str = "fibonacci"  # fibonacci, golden_ratio, prime, harmonic
    
    # 演化速度（每多少小节应用一次变化）
    evolution_rate: int = 4
    
    # 演化强度（0.0-1.0）
    evolution_intensity: float = 0.5
    
    # 应用的音乐参数
    affected_params: List[str] = field(default_factory=lambda: [
        "cutoff", "resonance", "amp"
    ])
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "sequence_type": self.sequence_type,
            "evolution_rate": self.evolution_rate,
            "evolution_intensity": self.evolution_intensity,
            "affected_params": self.affected_params
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'EvolutionParameters':
        """从字典创建"""
        return cls(
            sequence_type=data.get("sequence_type", "fibonacci"),
            evolution_rate=data.get("evolution_rate", 4),
            evolution_intensity=data.get("evolution_intensity", 0.5),
            affected_params=data.get("affected_params", ["cutoff", "resonance", "amp"])
        )


# ==================== 四层架构数据结构 ====================

@dataclass
class Segment:
    """
    Segment - 最小音乐单元（引用SegmentLibrary中的素材）
    """
    segment_id: str  # 引用SegmentLibrary中的ID
    start_bar: int = 0  # 在Section中的起始小节
    duration_bars: Optional[int] = None  # 覆盖默认时长
    params: Dict[str, Any] = field(default_factory=dict)  # 参数覆盖
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "segment_id": self.segment_id,
            "start_bar": self.start_bar,
            "duration_bars": self.duration_bars,
            "params": self.params
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Segment':
        """从字典创建"""
        return cls(
            segment_id=data["segment_id"],
            start_bar=data.get("start_bar", 0),
            duration_bars=data.get("duration_bars"),
            params=data.get("params", {})
        )


@dataclass
class Section:
    """
    Section - EDM音乐段落
    包含多个Segment的协调播放序列
    """
    id: str
    name: str
    section_type: SectionType
    duration_bars: int  # Section总时长（小节数）
    
    # Segment序列（可以是预定义的或动态生成的）
    segment_sequence: List[Dict] = field(default_factory=list)  # [{"segment_id": ..., "start_bar": ..., "params": ...}]
    
    # 演化参数（可选）
    evolution_params: Optional[EvolutionParameters] = None
    
    # 能量等级（0.0-1.0）
    energy_level: float = 0.5
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "id": self.id,
            "name": self.name,
            "section_type": self.section_type.value,
            "duration_bars": self.duration_bars,
            "segment_sequence": self.segment_sequence,
            "evolution_params": self.evolution_params.to_dict() if self.evolution_params else None,
            "energy_level": self.energy_level
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Section':
        """从字典创建"""
        section_type = SectionType(data["section_type"])
        evolution_params = None
        if data.get("evolution_params"):
            evolution_params = EvolutionParameters.from_dict(data["evolution_params"])
        
        return cls(
            id=data["id"],
            name=data["name"],
            section_type=section_type,
            duration_bars=data["duration_bars"],
            segment_sequence=data.get("segment_sequence", []),
            evolution_params=evolution_params,
            energy_level=data.get("energy_level", 0.5)
        )


@dataclass
class ChapterTransition:
    """Chapter间的过渡配置"""
    from_chapter_id: str
    to_chapter_id: str
    transition_type: TransitionType
    duration_bars: int  # 过渡时长（从前一个Chapter结尾开始计算）
    
    # 过渡参数
    params: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "from_chapter_id": self.from_chapter_id,
            "to_chapter_id": self.to_chapter_id,
            "transition_type": self.transition_type.value,
            "duration_bars": self.duration_bars,
            "params": self.params
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'ChapterTransition':
        """从字典创建"""
        transition_type = TransitionType(data["transition_type"])
        return cls(
            from_chapter_id=data["from_chapter_id"],
            to_chapter_id=data["to_chapter_id"],
            transition_type=transition_type,
            duration_bars=data["duration_bars"],
            params=data.get("params", {})
        )


@dataclass
class Chapter:
    """
    Chapter - EDM短曲
    具有完整EDM结构的独立作品
    """
    id: str
    name: str
    style: str  # 风格标签（如 "deep_house", "progressive", "ambient"）
    duration_bars: int  # Chapter总时长
    
    # Section序列
    sections: List[Section] = field(default_factory=list)
    
    # Pattern DNA变体（可选，覆盖Track级别的PatternDNA）
    pattern_dna_variant: Optional[Dict[str, Any]] = None
    
    # 演化参数（Chapter级别）
    evolution_params: Optional[EvolutionParameters] = None
    
    # 能量曲线（描述Chapter内的能量变化）
    energy_curve: List[float] = field(default_factory=list)  # 每个Section对应一个能量值
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "id": self.id,
            "name": self.name,
            "style": self.style,
            "duration_bars": self.duration_bars,
            "sections": [s.to_dict() for s in self.sections],
            "pattern_dna_variant": self.pattern_dna_variant,
            "evolution_params": self.evolution_params.to_dict() if self.evolution_params else None,
            "energy_curve": self.energy_curve
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Chapter':
        """从字典创建"""
        sections = [Section.from_dict(s) for s in data.get("sections", [])]
        evolution_params = None
        if data.get("evolution_params"):
            evolution_params = EvolutionParameters.from_dict(data["evolution_params"])
        
        return cls(
            id=data["id"],
            name=data["name"],
            style=data["style"],
            duration_bars=data["duration_bars"],
            sections=sections,
            pattern_dna_variant=data.get("pattern_dna_variant"),
            evolution_params=evolution_params,
            energy_curve=data.get("energy_curve", [])
        )


@dataclass
class Track:
    """
    Track - 单场EDM现场秀
    包含完整的DNA配置和Chapter序列
    """
    id: str
    name: str
    theme_scene: str  # 主题场景（如 "dawn_ignition", "urban_pulse"）
    duration_minutes: float  # 预计时长（分钟）
    
    # DNA三层体系
    core_dna: CoreDNA
    pattern_dna: PatternDNA
    
    # Chapter序列
    chapters: List[Chapter] = field(default_factory=list)
    
    # Chapter间过渡
    chapter_transitions: List[ChapterTransition] = field(default_factory=list)
    
    # 情绪标签
    mood_tags: List[str] = field(default_factory=list)
    
    # 元数据
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "id": self.id,
            "name": self.name,
            "theme_scene": self.theme_scene,
            "duration_minutes": self.duration_minutes,
            "core_dna": self.core_dna.to_dict(),
            "pattern_dna": self.pattern_dna.to_dict(),
            "chapters": [c.to_dict() for c in self.chapters],
            "chapter_transitions": [t.to_dict() for t in self.chapter_transitions],
            "mood_tags": self.mood_tags,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Track':
        """从字典创建"""
        core_dna = CoreDNA.from_dict(data["core_dna"])
        pattern_dna = PatternDNA.from_dict(data["pattern_dna"])
        chapters = [Chapter.from_dict(c) for c in data.get("chapters", [])]
        transitions = [ChapterTransition.from_dict(t) for t in data.get("chapter_transitions", [])]
        
        return cls(
            id=data["id"],
            name=data["name"],
            theme_scene=data["theme_scene"],
            duration_minutes=data["duration_minutes"],
            core_dna=core_dna,
            pattern_dna=pattern_dna,
            chapters=chapters,
            chapter_transitions=transitions,
            mood_tags=data.get("mood_tags", []),
            metadata=data.get("metadata", {})
        )
    
    def save_to_file(self, filepath: str):
        """保存到JSON文件"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
    
    @classmethod
    def load_from_file(cls, filepath: str) -> 'Track':
        """从JSON文件加载"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return cls.from_dict(data)


@dataclass
class Album:
    """
    Album - 完整专辑
    包含多个Track的现场秀集合
    """
    id: str
    name: str
    theme: str  # 专辑主题
    total_duration_hours: float  # 总时长（小时）
    
    # Track列表（文件引用）
    tracks: List[Dict[str, str]] = field(default_factory=list)  # [{"id": ..., "name": ..., "file": ...}]
    
    # 专辑级别的默认DNA（Track可以覆盖）
    default_core_dna: Optional[CoreDNA] = None
    
    # 元数据
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """转换为字典"""
        return {
            "id": self.id,
            "name": self.name,
            "theme": self.theme,
            "total_duration_hours": self.total_duration_hours,
            "tracks": self.tracks,
            "default_core_dna": self.default_core_dna.to_dict() if self.default_core_dna else None,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Album':
        """从字典创建"""
        default_core_dna = None
        if data.get("default_core_dna"):
            default_core_dna = CoreDNA.from_dict(data["default_core_dna"])
        
        return cls(
            id=data["id"],
            name=data["name"],
            theme=data["theme"],
            total_duration_hours=data["total_duration_hours"],
            tracks=data.get("tracks", []),
            default_core_dna=default_core_dna,
            metadata=data.get("metadata", {})
        )
    
    def save_to_file(self, filepath: str):
        """保存到JSON文件"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
    
    @classmethod
    def load_from_file(cls, filepath: str) -> 'Album':
        """从JSON文件加载"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return cls.from_dict(data)


# ==================== 工具函数 ====================

def create_example_track() -> Track:
    """创建一个示例Track"""
    core_dna = CoreDNA(
        tempo=128,
        key="C",
        mode="minor",
        scale="minor_pentatonic"
    )
    
    pattern_dna = PatternDNA(
        melody_seeds=["C4", "D4", "Eb4", "G4", "Bb4"],
        chord_progressions=[
            ["Cm", "Gm", "Ab", "Bb"],
            ["Cm", "Fm", "Bb", "Gm"]
        ]
    )
    
    # 创建一个简单的Chapter
    intro_section = Section(
        id="intro_01",
        name="Atmospheric Intro",
        section_type=SectionType.INTRO,
        duration_bars=16,
        segment_sequence=[
            {"segment_id": "ambient_dawn_texture_01", "start_bar": 0, "params": {}},
            {"segment_id": "pad_soft_atmosphere_01", "start_bar": 8, "params": {}}
        ],
        energy_level=0.2
    )
    
    chapter_01 = Chapter(
        id="ch01",
        name="Awakening",
        style="ambient_intro",
        duration_bars=32,
        sections=[intro_section],
        energy_curve=[0.2, 0.3]
    )
    
    return Track(
        id="dawn_ignition_v03",
        name="Dawn Ignition",
        theme_scene="dawn_ignition",
        duration_minutes=22.0,
        core_dna=core_dna,
        pattern_dna=pattern_dna,
        chapters=[chapter_01],
        mood_tags=["awakening", "motivation", "fresh_start"]
    )


if __name__ == "__main__":
    # 测试：创建并保存示例Track
    example_track = create_example_track()
    example_track.save_to_file("example_track.json")
    print("示例Track已保存到 example_track.json")
    
    # 测试：加载Track
    loaded_track = Track.load_from_file("example_track.json")
    print(f"加载的Track: {loaded_track.name}")
    print(f"BPM: {loaded_track.core_dna.tempo}")
    print(f"Chapters: {len(loaded_track.chapters)}")