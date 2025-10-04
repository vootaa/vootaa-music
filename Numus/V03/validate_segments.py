"""
Segment 验证工具
检查 segments 中的合成器和样本名称是否有效
基于 Sonic Pi 3.4 官方文档
"""

from pathlib import Path
import json
from typing import Set, List, Dict

# Sonic Pi 3.4 实际可用的合成器列表（来自官方文档）
VALID_SYNTHS = {
    # 基础波形
    "beep", "sine", "saw", "square", "triangle", "pulse",
    
    # 低音合成器
    "bass_foundation", "bass_highend",  # 移除了 fm_bass
    "tb303", "prophet",
    
    # 主音合成器
    "blade", "pluck", "pretty_bell", "kalimba",
    
    # Pad/氛围
    "hollow", "dark_ambience", "growl", "hoover",
    
    # FM 合成器
    "fm",  # 只有 fm，没有 fm_bass
    
    # 调制合成器
    "mod_fm", "mod_saw", "mod_dsaw", "mod_sine", "mod_tri", "mod_pulse",
    
    # Chip 音乐
    "chiplead", "chipbass", "dsaw", "dpulse", "dtri",
    
    # 噪音
    "noise", "gnoise", "bnoise", "cnoise", "pnoise",
    
    # 特殊
    "piano", "dull_bell", "sound_in",
    
    # 鼓机合成器
    "dsaw", "fm", "mod_fm", "mod_saw", "mod_dsaw", "mod_sine",
    "mod_tri", "mod_pulse", "subpulse", "supersaw",
    
    # 其他
    "zawa", "tech_saws"
}

# 常用打击乐样本（这些用 sample 命令）
VALID_SAMPLES = {
    # Kick
    "bd_haus", "bd_klub", "bd_tek", "bd_boom", "bd_ada", "bd_fat", "bd_gas",
    "bd_mehackit", "bd_pure", "bd_sone", "bd_zum",
    
    # Snare
    "drum_snare_hard", "drum_snare_soft", "sn_dolf", "sn_generic",
    
    # Hi-hat
    "drum_cymbal_closed", "drum_cymbal_open", "drum_cymbal_pedal",
    "hat_bdu", "hat_cab", "hat_gnu", "hat_noiz", "hat_raw", "hat_star",
    
    # Tom
    "drum_tom_lo_hard", "drum_tom_lo_soft", "drum_tom_mid_hard", 
    "drum_tom_mid_soft", "drum_tom_hi_hard", "drum_tom_hi_soft",
    
    # 其他打击乐
    "perc_bell", "perc_snap", "perc_swash", "perc_till",
    "elec_blip", "elec_blip2", "elec_ping", "elec_bell", "elec_flip",
    
    # Bass 样本（注意：不是合成器）
    "bass_hit_c", "bass_voxy_c", "bass_voxy_hit_c",
    "bass_dnb_f", "bass_thick_c", "bass_trance_c"
}

# 根据 sub_type 判断应该使用 synth 还是 sample
SUBTYPE_TO_PLAYBACK = {
    # 节奏类 - 使用 sample
    "kick_pattern": "sample",
    "snare_pattern": "sample",
    "hihat_pattern": "sample",
    "percussion_layer": "sample",
    "full_drum_kit": "sample",
    "breakbeat": "sample",
    
    # 和声/旋律类 - 使用 synth
    "bass_line": "synth",
    "chord_progression": "synth",
    "pad": "synth",
    "sub_bass": "synth",
    "lead_melody": "synth",
    "arpeggio": "synth",
    "hook": "synth",
    "ornament": "synth",
    
    # 质感/特效 - 大多使用 synth
    "synth_texture": "synth",
    "noise_layer": "synth",
    "riser": "synth",
    "impact": "sample",  # impact 通常用 sample
    "transition": "synth",
    "ambient_layer": "synth"
}

# 推荐的替代合成器映射
SYNTH_ALTERNATIVES = {
    "fm_bass": "fm",  # FM bass -> 使用 FM 合成器
    "bass_voxy": "bass_voxy_c",  # 这是一个样本，不是合成器
    "deep_bass": "bass_foundation",
    "sub_bass": "bass_foundation",
}

def validate_synth_name(synth_name: str, segment_id: str, sub_type: str) -> bool:
    """验证合成器名称"""
    clean_name = synth_name.lstrip(":")
    
    # 判断应该是 synth 还是 sample
    expected_type = SUBTYPE_TO_PLAYBACK.get(sub_type, "synth")
    
    if expected_type == "sample":
        # 应该是样本
        if clean_name in VALID_SAMPLES:
            return True
        elif clean_name in VALID_SYNTHS:
            print(f"⚠️  {segment_id}: '{synth_name}' 是合成器，但 sub_type '{sub_type}' 应使用样本")
            return False
        else:
            # 检查是否有推荐替代
            if clean_name in SYNTH_ALTERNATIVES:
                alt = SYNTH_ALTERNATIVES[clean_name]
                print(f"❌ {segment_id}: 未知样本 '{synth_name}' -> 建议使用 ':{alt}'")
            else:
                print(f"❌ {segment_id}: 未知样本 '{synth_name}'")
            return False
    else:
        # 应该是合成器
        if clean_name in VALID_SYNTHS:
            return True
        elif clean_name in VALID_SAMPLES:
            print(f"⚠️  {segment_id}: '{synth_name}' 是样本，但 sub_type '{sub_type}' 应使用合成器")
            print(f"   提示：如果要使用样本，请用 sample :{clean_name} 而非 use_synth")
            return False
        else:
            # 检查是否有推荐替代
            if clean_name in SYNTH_ALTERNATIVES:
                alt = SYNTH_ALTERNATIVES[clean_name]
                print(f"❌ {segment_id}: 未知合成器 '{synth_name}' -> 建议使用 ':{alt}'")
            else:
                print(f"❌ {segment_id}: 未知合成器 '{synth_name}'")
                print(f"   可用的低音合成器: bass_foundation, bass_highend, tb303, prophet, fm")
            return False

def validate_segment_file(filepath: Path) -> Dict[str, List[str]]:
    """验证单个 segment 文件"""
    issues = {"synth_errors": [], "sample_warnings": [], "type_mismatches": []}
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for segment in data.get("segments", []):
            segment_id = segment.get("id", "unknown")
            sub_type = segment.get("sub_type", "unknown")
            params = segment.get("playback_params", {})
            
            # 检查 synth 参数
            if "synth" in params:
                synth = params["synth"]
                if not validate_synth_name(synth, segment_id, sub_type):
                    issues["synth_errors"].append(f"{segment_id}: {synth}")
            
            # 检查 open_synth（hi-hat 特有）
            if "open_synth" in params:
                open_synth = params["open_synth"]
                clean_name = open_synth.lstrip(":")
                if clean_name not in VALID_SAMPLES:
                    print(f"❌ {segment_id}: 未知 open_synth 样本 '{open_synth}'")
                    issues["sample_warnings"].append(f"{segment_id}: {open_synth}")
            
            # 检查 breakbeat 的多个 synth 字段
            for field in ["kick_synth", "snare_synth", "hihat_synth"]:
                if field in params:
                    sample_name = params[field]
                    clean_name = sample_name.lstrip(":")
                    if clean_name not in VALID_SAMPLES:
                        print(f"❌ {segment_id}: 未知 {field} 样本 '{sample_name}'")
                        issues["sample_warnings"].append(f"{segment_id}: {sample_name}")
        
    except Exception as e:
        print(f"❌ 读取文件失败 {filepath}: {e}")
    
    return issues

def validate_all_segments(segments_dir: str = "../segments"):
    """验证所有 segment 文件"""
    segments_path = Path(segments_dir)
    
    print("="*80)
    print("Segment 验证工具 v2.1 - 基于 Sonic Pi 3.4 官方文档")
    print("="*80)
    
    all_issues = {
        "synth_errors": [],
        "sample_warnings": [],
        "type_mismatches": []
    }
    
    json_files = list(segments_path.glob("*.json"))
    
    for json_file in json_files:
        print(f"\n检查: {json_file.name}")
        issues = validate_segment_file(json_file)
        all_issues["synth_errors"].extend(issues["synth_errors"])
        all_issues["sample_warnings"].extend(issues["sample_warnings"])
        all_issues["type_mismatches"].extend(issues.get("type_mismatches", []))
    
    # 汇总报告
    print("\n" + "="*80)
    print("验证报告")
    print("="*80)
    
    total_errors = (len(all_issues["synth_errors"]) + 
                   len(all_issues["sample_warnings"]) + 
                   len(all_issues["type_mismatches"]))
    
    if total_errors == 0:
        print("\n✅ 所有 Segments 验证通过！")
    else:
        if all_issues["synth_errors"]:
            print(f"\n🔴 发现 {len(all_issues['synth_errors'])} 个合成器错误:")
            for error in all_issues["synth_errors"]:
                print(f"  - {error}")
        
        if all_issues["sample_warnings"]:
            print(f"\n⚠️  发现 {len(all_issues['sample_warnings'])} 个样本警告:")
            for warning in all_issues["sample_warnings"]:
                print(f"  - {warning}")
        
        if all_issues["type_mismatches"]:
            print(f"\n⚠️  发现 {len(all_issues['type_mismatches'])} 个类型不匹配:")
            for mismatch in all_issues["type_mismatches"]:
                print(f"  - {mismatch}")
    
    print("\n" + "="*80)
    print("Sonic Pi 可用的低音合成器:")
    print("  - :bass_foundation  (深沉低音)")
    print("  - :bass_highend     (明亮低音)")
    print("  - :tb303            (经典酸性低音)")
    print("  - :prophet          (模拟合成器)")
    print("  - :fm               (FM 合成低音)")
    print("="*80)

if __name__ == "__main__":
    validate_all_segments()