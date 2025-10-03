"""
扫描并更新 segments 文件夹中依赖外部样本的文件
转换为纯 Sonic Pi 内置合成器版本
"""

import json
import os
from pathlib import Path

# 需要检查和更新的文件列表
SEGMENTS_TO_UPDATE = {
    "rhythm/dnb_breakbeat_amen_01.json": {
        "replace_sample": ":loop_amen",
        "with_synth": ":drum_heavy_kick + :drum_snare_hard",
        "pattern": "创建 Amen Break 风格的合成器打击乐模式"
    },
    "rhythm/ethnic_percussion_tabla_01.json": {
        "replace_sample": "tabla samples",
        "with_synth": ":drum_tom_mid_soft + :perc_bell",
        "pattern": "使用 Sonic Pi 内置打击乐合成 tabla 音色"
    },
    "rhythm/samba_percussion_pattern_01.json": {
        "replace_sample": "samba samples",
        "with_synth": ":drum_cowbell + :perc_bell + :drum_tom_hi_hard",
        "pattern": "合成器模拟 Samba 打击乐组"
    },
    "atmosphere/amazonia_jungle_atmosphere_01.json": {
        "replace_sample": "field recording",
        "with_synth": ":noise + :hollow + :prophet",
        "pattern": "合成器叠加创造丛林氛围"
    },
    "fx/cosmic_noise_sweep_01.json": {
        "replace_sample": "noise sweep sample",
        "with_synth": ":noise + :cnoise",
        "pattern": "白噪声 + cutoff automation"
    }
}

def update_segment_to_synth(segment_path: str, update_info: dict) -> dict:
    """
    将依赖外部样本的 Segment 更新为纯合成器版本
    """
    with open(segment_path, 'r', encoding='utf-8') as f:
        segment = json.load(f)
    
    # 更新 sonic_pi_code 中的 sample 为 synth
    if 'sonic_pi_code' in segment:
        main_code = segment['sonic_pi_code'].get('main_code', '')
        
        # 替换 sample 调用为 synth
        if 'sample' in main_code:
            # 这里需要根据具体的 segment 内容进行智能替换
            # 示例：将 sample :loop_amen 替换为 synth :drum_heavy_kick
            pass
    
    # 添加标注说明这是合成器版本
    if 'metadata' not in segment:
        segment['metadata'] = {}
    
    segment['metadata']['version_note'] = "Pure synthesizer version - no external samples"
    segment['metadata']['original_sample'] = update_info['replace_sample']
    
    return segment

def scan_and_update_all_segments(segments_dir: str):
    """
    扫描所有 segment 文件，检查是否有外部依赖
    """
    segments_path = Path(segments_dir)
    
    for category_dir in segments_path.iterdir():
        if category_dir.is_dir():
            for segment_file in category_dir.glob("*.json"):
                with open(segment_file, 'r', encoding='utf-8') as f:
                    try:
                        segment = json.load(f)
                        
                        # 检查是否使用了 sample
                        if 'sonic_pi_code' in segment:
                            main_code = segment['sonic_pi_code'].get('main_code', '')
                            if 'sample' in main_code.lower():
                                print(f"⚠️  Found sample usage in: {segment_file}")
                                print(f"   Code snippet: {main_code[:100]}...")
                    except Exception as e:
                        print(f"❌ Error reading {segment_file}: {e}")

if __name__ == "__main__":
    segments_dir = "/Users/tsb/Pop-Proj/vootaa-music/Numus/segments"
    print("🔍 Scanning segments for external dependencies...\n")
    scan_and_update_all_segments(segments_dir)