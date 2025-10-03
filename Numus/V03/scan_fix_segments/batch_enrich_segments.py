"""
为现有 segments 补充缺失的元数据
- suitable_sections
- energy_level
- complexity
"""

import json
import os
from pathlib import Path
from typing import List, Dict

# EDM Section 类型定义
SECTION_TYPES = [
    "intro", "build_up", "drop", "breakdown", 
    "verse", "chorus", "bridge", "outro", "transition"
]

# 基于 Segment 类型的默认适用 Section 映射
DEFAULT_SUITABLE_SECTIONS = {
    # Rhythm
    "kick_pattern": ["intro", "verse", "drop", "build_up"],
    "snare_pattern": ["drop", "verse", "transition"],
    "hihat_pattern": ["verse", "drop", "build_up"],
    "percussion_layer": ["verse", "breakdown", "bridge"],
    "full_drum_kit": ["drop", "chorus"],
    "breakbeat": ["drop", "breakdown", "bridge"],
    
    # Harmony
    "bass_line": ["intro", "verse", "drop", "chorus"],
    "chord_progression": ["verse", "chorus", "bridge"],
    "pad": ["intro", "breakdown", "bridge", "outro"],
    "sub_bass": ["intro", "verse", "drop", "outro"],
    
    # Melody
    "lead_melody": ["drop", "chorus", "bridge"],
    "arpeggio": ["build_up", "drop", "verse"],
    "hook": ["chorus", "drop"],
    "ornament": ["verse", "bridge", "breakdown"],
    
    # Texture
    "synth_texture": ["intro", "breakdown", "bridge", "outro"],
    "noise_layer": ["build_up", "transition"],
    
    # FX
    "riser": ["build_up"],
    "impact": ["drop", "transition"],
    "transition": ["transition", "build_up", "breakdown"],
    
    # Atmosphere
    "ambient_layer": ["intro", "breakdown", "outro"],
    "field_recording": ["intro", "breakdown", "outro"]
}

# 基于音乐特征的能量等级评估规则
def estimate_energy_level(segment: dict) -> float:
    """
    基于 Segment 特征估算能量等级
    """
    sub_type = segment.get('sub_type', '')
    element_tags = segment.get('metadata', {}).get('element_tags', [])
    
    # 高能量类型
    if sub_type in ['kick_pattern', 'breakbeat', 'lead_melody', 'impact']:
        base_energy = 0.7
    # 中能量类型
    elif sub_type in ['bass_line', 'arpeggio', 'snare_pattern']:
        base_energy = 0.5
    # 低能量类型
    elif sub_type in ['pad', 'ambient_layer', 'synth_texture']:
        base_energy = 0.3
    else:
        base_energy = 0.5
    
    # 根据标签微调
    if 'intense' in element_tags or 'driving' in element_tags:
        base_energy += 0.1
    if 'soft' in element_tags or 'ambient' in element_tags:
        base_energy -= 0.1
    
    return max(0.0, min(1.0, base_energy))

def estimate_complexity(segment: dict) -> float:
    """
    基于 Segment 特征估算复杂度
    """
    musical_params = segment.get('musical_params', {})
    sub_type = segment.get('sub_type', '')
    
    # 基础复杂度
    base_complexity = 0.5
    
    # 根据音符数量
    notes = musical_params.get('notes', [])
    if notes and len(notes) > 8:
        base_complexity += 0.2
    elif notes and len(notes) < 4:
        base_complexity -= 0.1
    
    # 根据类型
    if sub_type in ['breakbeat', 'arpeggio', 'ornament']:
        base_complexity += 0.1
    elif sub_type in ['pad', 'sub_bass', 'ambient_layer']:
        base_complexity -= 0.1
    
    # 根据节奏复杂度
    pattern = musical_params.get('pattern', [])
    if pattern:
        # 计算节奏密度
        density = sum(1 for x in pattern if x > 0) / len(pattern)
        if density > 0.5:
            base_complexity += 0.1
    
    return max(0.0, min(1.0, base_complexity))

def enrich_segment_metadata(segment_path: str) -> dict:
    """
    为单个 Segment 补充元数据
    """
    with open(segment_path, 'r', encoding='utf-8') as f:
        segment = json.load(f)
    
    metadata = segment.get('metadata', {})
    sub_type = segment.get('sub_type', '')
    
    # 1. 补充 suitable_sections
    if not metadata.get('suitable_sections'):
        metadata['suitable_sections'] = DEFAULT_SUITABLE_SECTIONS.get(sub_type, ["verse", "drop"])
    
    # 2. 补充 energy_level
    if 'energy_level' not in metadata:
        metadata['energy_level'] = estimate_energy_level(segment)
    
    # 3. 补充 complexity
    if 'complexity' not in metadata:
        metadata['complexity'] = estimate_complexity(segment)
    
    segment['metadata'] = metadata
    
    return segment

def batch_enrich_segments(segments_dir: str, dry_run: bool = True):
    """
    批量处理所有 segments
    """
    segments_path = Path(segments_dir)
    updated_count = 0
    
    for category_dir in segments_path.iterdir():
        if category_dir.is_dir():
            print(f"\n📁 Processing category: {category_dir.name}")
            
            for segment_file in category_dir.glob("*.json"):
                try:
                    enriched_segment = enrich_segment_metadata(str(segment_file))
                    
                    if not dry_run:
                        with open(segment_file, 'w', encoding='utf-8') as f:
                            json.dump(enriched_segment, f, indent=2, ensure_ascii=False)
                    
                    print(f"  ✅ {segment_file.name}")
                    print(f"     Energy: {enriched_segment['metadata']['energy_level']:.2f}")
                    print(f"     Complexity: {enriched_segment['metadata']['complexity']:.2f}")
                    print(f"     Suitable: {', '.join(enriched_segment['metadata']['suitable_sections'][:3])}...")
                    
                    updated_count += 1
                    
                except Exception as e:
                    print(f"  ❌ Error processing {segment_file.name}: {e}")
    
    print(f"\n✨ Total segments processed: {updated_count}")
    if dry_run:
        print("⚠️  DRY RUN mode - no files were modified")
        print("   Run with dry_run=False to apply changes")

if __name__ == "__main__":
    segments_dir = "/Users/tsb/Pop-Proj/vootaa-music/Numus/segments"
    
    # 先运行 dry run 查看结果
    print("🔍 Running metadata enrichment preview...\n")
    batch_enrich_segments(segments_dir, dry_run=True)
    
    # 确认后执行实际更新
    #batch_enrich_segments(segments_dir, dry_run=False)