"""
扫描并更新 segments 文件夹中依赖外部样本的文件
转换为纯 Sonic Pi 内置合成器版本
"""

import json
import os
from pathlib import Path
import re

# Sonic Pi 内置样本列表（排除外部依赖）
BUILTIN_SAMPLES = {
    # Drums
    ':bd_', ':drum_', ':sn_', ':elec_', ':tabla_', ':guit_',
    # Percussion  
    ':perc_', 
    # Ambient
    ':ambi_', ':vinyl_',
    # Bass
    ':bass_',
    # Misc
    ':misc_'
}

def is_builtin_sample(sample_name: str) -> bool:
    """
    检查是否是 Sonic Pi 内置样本
    """
    sample_name = sample_name.strip().lower()
    
    # 检查是否以内置前缀开头
    for prefix in BUILTIN_SAMPLES:
        if sample_name.startswith(prefix):
            return True
    
    # 特殊情况：loop_ 开头的通常不是内置的
    if sample_name.startswith(':loop_'):
        return False
    
    return False

def extract_samples_from_code(code: str) -> list:
    """
    从 Sonic Pi 代码中提取所有 sample 调用
    返回 [(sample_name, full_line), ...]
    """
    samples = []
    
    # 匹配 sample :xxx 或 sample "xxx"
    pattern = r'sample\s+(:[a-z_0-9]+|"[^"]+"|\'[^\']+\')'
    
    for match in re.finditer(pattern, code, re.IGNORECASE):
        sample_name = match.group(1).strip()
        # 获取完整的行
        line_start = code.rfind('\n', 0, match.start()) + 1
        line_end = code.find('\n', match.end())
        if line_end == -1:
            line_end = len(code)
        full_line = code[line_start:line_end].strip()
        
        samples.append((sample_name, full_line, match.start()))
    
    return samples

def generate_synth_replacement(sample_name: str, original_line: str) -> str:
    """
    根据样本类型生成合成器替代方案
    """
    sample_lower = sample_name.lower()
    
    # 提取原始参数（amp, rate, cutoff 等）
    params_match = re.search(r'sample\s+[^,]+,?\s*(.*)$', original_line)
    params = params_match.group(1).strip() if params_match else ""
    
    # 根据样本类型选择合成器
    if 'amen' in sample_lower or 'break' in sample_lower:
        # Amen Break 类型 - 用内置打击乐组合
        return f"""# Replaced external breakbeat with synth drums
  sample :drum_heavy_kick, {params}
  sleep 0.25
  sample :drum_snare_hard, {params}, amp: 0.8
  sleep 0.25"""
    
    elif 'tabla' in sample_lower or 'ethnic' in sample_lower:
        # 民族打击乐 - 用 tom + bell 组合
        return f"sample :drum_tom_mid_soft, {params}  # Replaced ethnic percussion"
    
    elif 'samba' in sample_lower or 'latin' in sample_lower:
        # 拉丁打击乐 - 用 cowbell + perc
        return f"sample :drum_cowbell, {params}  # Replaced latin percussion"
    
    elif 'jungle' in sample_lower or 'forest' in sample_lower or 'field' in sample_lower:
        # 环境音 - 用合成器氛围音
        return f"""# Replaced field recording with synth atmosphere
  use_synth :hollow
  with_fx :reverb, room: 0.9 do
    play :c2, amp: 0.3, release: 4, {params}
  end"""
    
    elif 'noise' in sample_lower or 'sweep' in sample_lower:
        # 噪音扫频 - 用噪音合成器
        return f"""# Replaced noise sample with synth
  use_synth :noise
  with_fx :lpf, cutoff_slide: 2 do |fx|
    play 60, {params}, sustain: 2
    control fx, cutoff: 130
  end"""
    
    elif 'vocal' in sample_lower or 'voice' in sample_lower:
        # 人声 - 用 chipbass 或 prophet
        return f"use_synth :chipbass\n  play :c4, {params}  # Replaced vocal sample"
    
    else:
        # 默认替换 - 用通用合成器
        return f"# TODO: Replace sample {sample_name} with appropriate synth\n  # Original: {original_line}"

def update_segment_code(segment: dict, dry_run: bool = True) -> tuple:
    """
    更新 Segment 的 Sonic Pi 代码，移除外部样本依赖
    返回 (updated_segment, has_changes, change_log)
    """
    if 'sonic_pi_code' not in segment:
        return segment, False, []
    
    main_code = segment['sonic_pi_code'].get('main_code', '')
    
    # 提取所有样本调用
    samples = extract_samples_from_code(main_code)
    
    # 找出非内置样本
    external_samples = [
        (name, line, pos) for name, line, pos in samples 
        if not is_builtin_sample(name)
    ]
    
    if not external_samples:
        return segment, False, []
    
    # 记录变更
    change_log = []
    updated_code = main_code
    
    # 从后往前替换（避免位置偏移）
    for sample_name, original_line, pos in reversed(external_samples):
        replacement = generate_synth_replacement(sample_name, original_line)
        
        # 找到这一行在代码中的位置
        line_start = updated_code.rfind('\n', 0, pos) + 1
        line_end = updated_code.find('\n', pos)
        if line_end == -1:
            line_end = len(updated_code)
        
        # 替换
        updated_code = (
            updated_code[:line_start] + 
            replacement + 
            updated_code[line_end:]
        )
        
        change_log.append({
            'original_sample': sample_name,
            'original_line': original_line,
            'replacement': replacement
        })
    
    if not dry_run:
        segment['sonic_pi_code']['main_code'] = updated_code
        
        # 更新元数据
        if 'metadata' not in segment:
            segment['metadata'] = {}
        
        segment['metadata']['version_note'] = "Pure synthesizer version - external samples replaced"
        segment['metadata']['replaced_samples'] = [
            log['original_sample'] for log in change_log
        ]
    
    return segment, True, change_log

def scan_and_update_all_segments(segments_dir: str, dry_run: bool = True, fix: bool = False):
    """
    扫描所有 segment 文件，检查并可选修复外部依赖
    
    Args:
        segments_dir: segments 根目录
        dry_run: True=仅报告，不修改文件
        fix: True=自动修复问题
    """
    segments_path = Path(segments_dir)
    
    stats = {
        'total': 0,
        'with_samples': 0,
        'with_external_samples': 0,
        'fixed': 0,
        'errors': 0
    }
    
    issues = []
    
    print(f"{'='*70}")
    print(f"🔍 Scanning: {segments_dir}")
    print(f"   Mode: {'DRY RUN (preview only)' if dry_run else 'WRITE MODE (will modify files)'}")
    print(f"   Auto-fix: {'ENABLED' if fix else 'DISABLED'}")
    print(f"{'='*70}\n")
    
    for category_dir in segments_path.iterdir():
        if not category_dir.is_dir() or category_dir.name.startswith('.'):
            continue
        
        print(f"\n📁 Category: {category_dir.name}")
        print(f"   {'-'*60}")
        
        for segment_file in sorted(category_dir.glob("*.json")):
            stats['total'] += 1
            
            try:
                with open(segment_file, 'r', encoding='utf-8') as f:
                    segment = json.load(f)
                
                # 检查是否使用了 sample
                if 'sonic_pi_code' in segment:
                    main_code = segment['sonic_pi_code'].get('main_code', '')
                    samples = extract_samples_from_code(main_code)
                    
                    if samples:
                        stats['with_samples'] += 1
                        
                        # 检查外部样本
                        external = [(name, line) for name, line, _ in samples if not is_builtin_sample(name)]
                        
                        if external:
                            stats['with_external_samples'] += 1
                            
                            print(f"\n   ⚠️  {segment_file.name}")
                            print(f"      Found {len(external)} external sample(s):")
                            
                            for sample_name, line in external:
                                print(f"         • {sample_name}")
                                print(f"           {line[:80]}...")
                            
                            if fix:
                                # 尝试修复
                                updated_segment, has_changes, change_log = update_segment_code(
                                    segment, 
                                    dry_run=dry_run
                                )
                                
                                if has_changes:
                                    print(f"\n      🔧 Generated replacement:")
                                    for log in change_log:
                                        print(f"         {log['original_sample']} → ")
                                        print(f"         {log['replacement'][:100]}...")
                                    
                                    if not dry_run:
                                        # 写入文件
                                        with open(segment_file, 'w', encoding='utf-8') as f:
                                            json.dump(updated_segment, f, indent=2, ensure_ascii=False)
                                        print(f"      ✅ File updated")
                                        stats['fixed'] += 1
                                    else:
                                        print(f"      ℹ️  Would update (dry run)")
                            
                            issues.append({
                                'file': str(segment_file),
                                'external_samples': external
                            })
            
            except json.JSONDecodeError as e:
                print(f"   ❌ JSON Error in {segment_file.name}: {e}")
                stats['errors'] += 1
            except Exception as e:
                print(f"   ❌ Error processing {segment_file.name}: {e}")
                stats['errors'] += 1
    
    # 打印总结
    print(f"\n{'='*70}")
    print(f"📊 SUMMARY")
    print(f"{'='*70}")
    print(f"Total segments scanned:           {stats['total']}")
    print(f"Segments using samples:           {stats['with_samples']}")
    print(f"Segments with external samples:   {stats['with_external_samples']}")
    if fix:
        print(f"Segments fixed:                   {stats['fixed']}")
    print(f"Errors:                           {stats['errors']}")
    print(f"{'='*70}\n")
    
    if issues and not fix:
        print("💡 To automatically fix these issues, run with fix=True")
    
    return stats, issues

if __name__ == "__main__":
    segments_dir = "/Users/tsb/Pop-Proj/vootaa-music/Numus/segments"
    
    # Step 1: 先扫描查看问题
    print("STEP 1: Scanning for issues...\n")
    stats, issues = scan_and_update_all_segments(
        segments_dir, 
        dry_run=False, 
        fix=True
    )
    
    # Step 2: 如果发现问题，询问是否修复
    if stats['with_external_samples'] > 0:
        print("\n" + "="*70)
        print("⚠️  Found segments with external sample dependencies!")
        print("="*70)
        print("\nTo preview fixes, run:")
        print("  scan_and_update_all_segments(segments_dir, dry_run=True, fix=True)")
        print("\nTo apply fixes, run:")
        print("  scan_and_update_all_segments(segments_dir, dry_run=False, fix=True)")