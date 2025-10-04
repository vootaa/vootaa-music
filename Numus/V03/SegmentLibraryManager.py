"""
Segment素材库管理器
负责加载、索引和检索Segment素材
"""

import json
from pathlib import Path
from typing import Dict, List, Optional, Set
from collections import defaultdict
from StandardSegment import StandardSegment, SegmentCategory, SegmentSubType


class SegmentLibrary:
    """Segment素材库管理器"""
    
    def __init__(self, segments_dir: str = "../segments"):
        """
        初始化Segment库
        
        Args:
            segments_dir: segments目录路径
        """
        self.segments_dir = Path(segments_dir)
        self.segments: Dict[str, StandardSegment] = {}
        
        # 索引结构 - 修复：by_energy 使用 defaultdict(set) 而非 list
        self.by_category: Dict[SegmentCategory, List[str]] = defaultdict(list)
        self.by_subtype: Dict[SegmentSubType, List[str]] = defaultdict(list)
        self.by_section: Dict[str, List[str]] = defaultdict(list)
        self.by_energy: Dict[str, Set[str]] = defaultdict(set)
        self.by_tags: Dict[str, Set[str]] = defaultdict(set)
        
        # 加载所有segments
        self._load_all_segments()
        
        print(f"SegmentLibrary 初始化完成")
        print(f"加载 {len(self.segments)} 个Segments")
    
    def _load_all_segments(self):
        """从JSON文件加载所有segments"""
        json_files = [
            "rhythm.json",
            "melody.json", 
            "harmony.json",
            "bass.json",
            "fx.json",
            "atmosphere.json",
            "texture.json"
        ]
        
        for filename in json_files:
            filepath = self.segments_dir / filename
            if filepath.exists():
                self._load_segment_file(filepath)
            else:
                print(f"警告: 未找到文件 {filepath}")
    
    def _load_segment_file(self, filepath: Path):
        """加载单个JSON文件"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            library_info = data.get("library_info", {})
            segments_data = data.get("segments", [])
            
            print(f"加载 {library_info.get('name', filepath.name)}: {len(segments_data)} 个segments")
            
            for seg_data in segments_data:
                self._load_segment_from_dict(seg_data)
                
        except Exception as e:
            print(f"加载文件失败 {filepath}: {e}")
    
    def _load_segment_from_dict(self, data: dict):
        """从字典创建并索引Segment"""
        try:
            # 转换为StandardSegment格式
            segment_dict = {
                "id": data["id"],
                "name": data["name"],
                "category": data["category"],
                "sub_type": data["sub_type"],
                "playback_params": data.get("playback_params", {}),
                "metadata": {
                    "source_file": f"{data['category']}.json",
                    "energy_level": data.get("metadata", {}).get("energy_level", 0.5),
                    "complexity": data.get("metadata", {}).get("complexity", 0.5),
                    "density": data.get("metadata", {}).get("density", 0.5),
                    "suitable_sections": data.get("metadata", {}).get("suitable_sections", []),
                    "suitable_moods": data.get("metadata", {}).get("suitable_moods", []),
                    "element_tags": data.get("metadata", {}).get("element_tags", []),
                    "style_tags": data.get("metadata", {}).get("style_tags", []),
                    "mood_tags": data.get("metadata", {}).get("mood_tags", []),
                    "description": data.get("metadata", {}).get("description", ""),
                }
            }
            
            segment = StandardSegment.from_dict(segment_dict)
            
            # 存储segment
            self.segments[segment.id] = segment
            
            # 建立索引
            self._index_segment(segment)
            
        except Exception as e:
            print(f"加载Segment失败 {data.get('id', 'unknown')}: {e}")
    
    def _index_segment(self, segment: StandardSegment):
        """为Segment建立多维度索引"""
        seg_id = segment.id
        
        # 按类别索引
        self.by_category[segment.category].append(seg_id)
        
        # 按子类型索引
        self.by_subtype[segment.sub_type].append(seg_id)
        
        # 按适用Section索引
        for section in segment.metadata.suitable_sections:
            self.by_section[section].append(seg_id)
        
        # 按能量等级索引 - 修复：使用 set 的 add() 方法
        energy = segment.metadata.energy_level
        if energy < 0.3:
            self.by_energy["low"].add(seg_id)
        elif energy < 0.7:
            self.by_energy["medium"].add(seg_id)
        else:
            self.by_energy["high"].add(seg_id)
        
        # 按标签索引
        all_tags = (segment.metadata.element_tags + 
                   segment.metadata.style_tags + 
                   segment.metadata.mood_tags)
        for tag in all_tags:
            self.by_tags[tag].add(seg_id)
    
    def get_segment(self, segment_id: str) -> Optional[StandardSegment]:
        """根据ID获取Segment"""
        return self.segments.get(segment_id)
    
    def search_by_category(self, category: SegmentCategory) -> List[StandardSegment]:
        """按类别搜索"""
        ids = self.by_category.get(category, [])
        return [self.segments[sid] for sid in ids]
    
    def search_by_subtype(self, subtype: SegmentSubType) -> List[StandardSegment]:
        """按子类型搜索"""
        ids = self.by_subtype.get(subtype, [])
        return [self.segments[sid] for sid in ids]
    
    def search_by_section(self, section_type: str) -> List[StandardSegment]:
        """
        按适用Section搜索
        
        Args:
            section_type: "intro", "build_up", "drop", "breakdown", "outro"
        """
        ids = self.by_section.get(section_type, [])
        return [self.segments[sid] for sid in ids]
    
    def search_by_energy(self, energy_range: str) -> List[StandardSegment]:
        """
        按能量等级搜索
        
        Args:
            energy_range: "low", "medium", "high"
        """
        ids = self.by_energy.get(energy_range, set())
        return [self.segments[sid] for sid in ids]
    
    def search_by_tags(self, tags: List[str], match_all: bool = False) -> List[StandardSegment]:
        """
        按标签搜索
        
        Args:
            tags: 标签列表
            match_all: True=匹配所有标签, False=匹配任一标签
        """
        if not tags:
            return []
        
        result_ids = None
        
        for tag in tags:
            tag_ids = self.by_tags.get(tag, set())
            
            if result_ids is None:
                result_ids = tag_ids.copy()
            else:
                if match_all:
                    result_ids &= tag_ids  # 交集
                else:
                    result_ids |= tag_ids  # 并集
        
        return [self.segments[sid] for sid in (result_ids or [])]
    
    def search_advanced(self,
                       category: Optional[SegmentCategory] = None,
                       subtype: Optional[SegmentSubType] = None,
                       section_type: Optional[str] = None,
                       energy_range: Optional[str] = None,
                       tags: Optional[List[str]] = None,
                       min_energy: Optional[float] = None,
                       max_energy: Optional[float] = None) -> List[StandardSegment]:
        """
        高级搜索 - 多条件组合
        """
        candidates = list(self.segments.values())
        
        # 按类别过滤
        if category:
            candidates = [s for s in candidates if s.category == category]
        
        # 按子类型过滤
        if subtype:
            candidates = [s for s in candidates if s.sub_type == subtype]
        
        # 按Section过滤
        if section_type:
            candidates = [s for s in candidates 
                         if section_type in s.metadata.suitable_sections]
        
        # 按能量等级过滤
        if min_energy is not None:
            candidates = [s for s in candidates 
                         if s.metadata.energy_level >= min_energy]
        
        if max_energy is not None:
            candidates = [s for s in candidates 
                         if s.metadata.energy_level <= max_energy]
        
        # 按标签过滤
        if tags:
            candidates = [s for s in candidates 
                         if any(tag in (s.metadata.element_tags + 
                                       s.metadata.style_tags + 
                                       s.metadata.mood_tags) 
                               for tag in tags)]
        
        return candidates
    
    def get_statistics(self) -> dict:
        """获取统计信息"""
        return {
            "total_segments": len(self.segments),
            "by_category": {cat.value: len(ids) 
                          for cat, ids in self.by_category.items()},
            "by_subtype": {st.value: len(ids) 
                         for st, ids in self.by_subtype.items()},
            "by_section": {sec: len(ids) 
                         for sec, ids in self.by_section.items()},
            "by_energy": {level: len(ids) 
                        for level, ids in self.by_energy.items()},
            "total_tags": len(self.by_tags)
        }
    
    def list_all_tags(self) -> List[str]:
        """列出所有标签"""
        return sorted(self.by_tags.keys())
    
    def validate_library(self) -> Dict[str, List[str]]:
        """验证库的完整性"""
        issues = {
            "missing_params": [],
            "invalid_energy": [],
            "missing_metadata": []
        }
        
        for seg_id, segment in self.segments.items():
            # 检查必要参数
            if not segment.playback_params.duration_bars:
                issues["missing_params"].append(seg_id)
            
            # 检查能量等级
            energy = segment.metadata.energy_level
            if not (0.0 <= energy <= 1.0):
                issues["invalid_energy"].append(seg_id)
            
            # 检查元数据
            if not segment.metadata.suitable_sections:
                issues["missing_metadata"].append(seg_id)
        
        return issues