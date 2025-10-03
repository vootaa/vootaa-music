"""
Segment Library 管理器
负责Segment素材的加载、检索、分类管理
"""

import os
import json
from typing import List, Dict, Optional, Set
from pathlib import Path
from segment_standards import (
    StandardSegment, SegmentCategory, SegmentSubType,
    MusicalParameters, SegmentMetadata
)


class SegmentLibrary:
    """Segment素材库管理器"""
    
    def __init__(self, library_path: str):
        """
        初始化Segment库
        
        Args:
            library_path: Segment库根目录路径
        """
        self.library_path = Path(library_path)
        self.segments: Dict[str, StandardSegment] = {}
        self.category_index: Dict[SegmentCategory, List[str]] = {}
        self.subtype_index: Dict[SegmentSubType, List[str]] = {}
        self.tag_index: Dict[str, Set[str]] = {}  # 标签到segment_id的映射
        
        # 初始化索引结构
        for category in SegmentCategory:
            self.category_index[category] = []
        for subtype in SegmentSubType:
            self.subtype_index[subtype] = []
        
        # 加载现有素材
        self._load_all_segments()
    
    def _load_all_segments(self):
        """加载库中所有Segment"""
        if not self.library_path.exists():
            self.library_path.mkdir(parents=True, exist_ok=True)
            return
        
        for category_dir in self.library_path.iterdir():
            if category_dir.is_dir():
                for segment_file in category_dir.glob("*.json"):
                    try:
                        segment = StandardSegment.load_from_file(str(segment_file))
                        self.add_segment(segment)
                    except Exception as e:
                        print(f"加载Segment失败 {segment_file}: {e}")
    
    def add_segment(self, segment: StandardSegment):
        """添加Segment到库中"""
        self.segments[segment.id] = segment
        
        # 更新分类索引
        if segment.id not in self.category_index[segment.category]:
            self.category_index[segment.category].append(segment.id)
        
        if segment.id not in self.subtype_index[segment.sub_type]:
            self.subtype_index[segment.sub_type].append(segment.id)
        
        # 更新标签索引
        all_tags = (
            segment.metadata.genre_tags +
            segment.metadata.mood_tags +
            segment.metadata.element_tags
        )
        for tag in all_tags:
            if tag not in self.tag_index:
                self.tag_index[tag] = set()
            self.tag_index[tag].add(segment.id)
    
    def get_segment(self, segment_id: str) -> Optional[StandardSegment]:
        """根据ID获取Segment"""
        return self.segments.get(segment_id)
    
    def find_by_category(self, category: SegmentCategory) -> List[StandardSegment]:
        """根据大类查找Segment"""
        segment_ids = self.category_index.get(category, [])
        return [self.segments[sid] for sid in segment_ids]
    
    def find_by_subtype(self, sub_type: SegmentSubType) -> List[StandardSegment]:
        """根据细分类型查找Segment"""
        segment_ids = self.subtype_index.get(sub_type, [])
        return [self.segments[sid] for sid in segment_ids]
    
    def find_by_tags(self, tags: List[str], match_all: bool = False) -> List[StandardSegment]:
        """
        根据标签查找Segment
        
        Args:
            tags: 标签列表
            match_all: True=必须匹配所有标签, False=匹配任一标签
        """
        if not tags:
            return []
        
        if match_all:
            # 交集：必须包含所有标签
            result_ids = None
            for tag in tags:
                tag_ids = self.tag_index.get(tag, set())
                if result_ids is None:
                    result_ids = tag_ids.copy()
                else:
                    result_ids &= tag_ids
            return [self.segments[sid] for sid in (result_ids or [])]
        else:
            # 并集：包含任一标签
            result_ids = set()
            for tag in tags:
                result_ids |= self.tag_index.get(tag, set())
            return [self.segments[sid] for sid in result_ids]
    
    def find_by_energy_range(self, min_energy: float, max_energy: float) -> List[StandardSegment]:
        """根据能量等级范围查找Segment"""
        return [
            segment for segment in self.segments.values()
            if min_energy <= segment.metadata.energy_level <= max_energy
        ]
    
    def find_suitable_for_section(self, section_type: str) -> List[StandardSegment]:
        """查找适合特定Section类型的Segment"""
        return [
            segment for segment in self.segments.values()
            if section_type in segment.metadata.suitable_sections
        ]
    
    def search(self, 
               category: Optional[SegmentCategory] = None,
               sub_type: Optional[SegmentSubType] = None,
               tags: Optional[List[str]] = None,
               energy_range: Optional[tuple] = None,
               section_type: Optional[str] = None) -> List[StandardSegment]:
        """
        综合搜索Segment
        
        Args:
            category: 大类筛选
            sub_type: 细分类型筛选
            tags: 标签筛选
            energy_range: 能量范围 (min, max)
            section_type: 适用的Section类型
        """
        results = list(self.segments.values())
        
        if category:
            results = [s for s in results if s.category == category]
        
        if sub_type:
            results = [s for s in results if s.sub_type == sub_type]
        
        if tags:
            tag_ids = set()
            for tag in tags:
                tag_ids |= self.tag_index.get(tag, set())
            results = [s for s in results if s.id in tag_ids]
        
        if energy_range:
            min_e, max_e = energy_range
            results = [s for s in results if min_e <= s.metadata.energy_level <= max_e]
        
        if section_type:
            results = [s for s in results if section_type in s.metadata.suitable_sections]
        
        return results
    
    def save_segment(self, segment: StandardSegment):
        """保存Segment到文件"""
        category_dir = self.library_path / segment.category.value
        category_dir.mkdir(exist_ok=True)
        
        filepath = category_dir / f"{segment.id}.json"
        segment.save_to_file(str(filepath))
        
        # 更新内存索引
        self.add_segment(segment)
    
    def list_all_tags(self) -> Dict[str, int]:
        """列出所有标签及其使用次数"""
        return {tag: len(ids) for tag, ids in self.tag_index.items()}
    
    def get_statistics(self) -> Dict:
        """获取库统计信息"""
        return {
            "total_segments": len(self.segments),
            "by_category": {cat.value: len(ids) for cat, ids in self.category_index.items()},
            "by_subtype": {st.value: len(ids) for st, ids in self.subtype_index.items()},
            "total_tags": len(self.tag_index),
            "average_energy": sum(s.metadata.energy_level for s in self.segments.values()) / len(self.segments) if self.segments else 0
        }