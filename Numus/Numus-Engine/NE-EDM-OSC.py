#!/usr/bin/env python3
"""
EDM_OSC.py
通用 DNA 编排 → OSC 播放控制器

功能:
- 读取 DNA JSON（格式类似 dawn_ignition_dna.json）
- 按 Section 时间轴发送参数与特性
- 自动识别数值字段与布尔字段（布尔发 /engine/toggle/<name>，数值发 /engine/param/<name>）
- 标准核心字段：bpm, energy, density, chord_index, active_parts
- 和弦序列只需在第一 Section 开始前发一次 (/engine/chord_prog)
- 支持: --time-scale (加速缩短测试) --start-chapter / --start-section 断点
- 若 DNA 中无 start_time，将按累积 duration 顺序调度

用法:
python EDM_OSC.py --dna path/to/track_dna.json --port 4560
"""
import json
import time
import argparse
from pathlib import Path
from typing import Any, Dict, List, Tuple
from pythonosc import udp_client

CORE_FIELDS = {
    "energy": "/engine/energy",
    "density": "/engine/density",
    "chord_index": "/engine/chord_index",
    "active_parts": "/engine/parts"

}

RESERVED_FIELDS = set([
    "start_time","duration","energy","density","active_parts","chord_index",
    "track_id","bpm","key","scale","chord_progression","chapters"
])

def is_bool_like(v: Any) -> bool:
    if isinstance(v, bool):
        return True
    if isinstance(v, (int, float)):
        return v in (0,1)
    if isinstance(v, str):
        return v.lower() in ("0","1","true","false","on","off")
    return False

def bool_value(v: Any) -> int:
    if isinstance(v, bool): return 1 if v else 0
    s = str(v).lower()
    return 1 if s in ("1","true","on") else 0

class DNATimeline:
    def __init__(self, dna: Dict[str,Any]):
        self.dna = dna
        self.sections: List[Tuple[str,str,Dict[str,Any]]] = []
        for ch_key, ch_data in dna.get("chapters", {}).items():
            secs = ch_data.get("sections", {})
            for sec_key, sec_data in secs.items():
                self.sections.append((ch_key, sec_key, sec_data))
        # 按 start_time 排序（若缺失则稍后填充）
        if any("start_time" not in s[2] for s in self.sections):
            # 回退：按顺序累计
            t = 0.0
            for ch, sk, data in self.sections:
                data.setdefault("duration", 60)
                data["start_time"] = t
                t += data["duration"]
        self.sections.sort(key=lambda x: x[2]["start_time"])

    def filtered(self, start_ch: str=None, start_sec: str=None):
        started = (start_ch is None and start_sec is None)
        for ch, sk, data in self.sections:
            if not started:
                if start_ch and ch == start_ch:
                    if (start_sec is None) or (sk == start_sec):
                        started = True
            if started:
                yield ch, sk, data

def send(client, addr, value):
    client.send_message(addr, value)

def send_debug(client, text: str):
    try:
        client.send_message("/engine/debug", text)
    except Exception as e:
        print(f"[WARN] debug send failed: {e}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dna", required=True, help="DNA JSON path")
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=4560)
    ap.add_argument("--time-scale", type=float, default=1.0, help="时间缩放 (<1 加速)")
    ap.add_argument("--start-chapter", help="从指定 chapter 开始")
    ap.add_argument("--start-section", help="与 --start-chapter 配合，用该 section 开始")
    ap.add_argument("--no-section-debug", action="store_true", help="不在每个 Section 发送 debug OSC")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    path = Path(args.dna)
    if not path.exists():
        print(f"[ERR] DNA 文件不存在: {path}")
        return

    with path.open("r", encoding="utf-8") as f:
        dna = json.load(f)

    timeline = DNATimeline(dna)
    sections = list(timeline.filtered(args.start_chapter, args.start_section))
    if not sections:
        print("[ERR] 没有匹配的 Section")
        return

    host = args.host
    port = args.port
    client = udp_client.SimpleUDPClient(host, port)
    print(f"[INFO] OSC -> {host}:{port}")

    bpm = dna.get("bpm", 120)
    chord_prog = dna.get("chord_progression", [])
    track_id = dna.get("track_id","unknown_track")

    if chord_prog:
        print(f"[SEND] chord_prog={chord_prog}")
        if not args.dry_run:
            send(client, "/engine/chord_prog", ",".join(chord_prog))

    if not args.dry_run:
        send(client, "/engine/bpm", bpm)
        # 启动调试信息
        total_secs = 0
        if sections:
            last = sections[-1][2]
            total_secs = last.get("start_time",0)+last.get("duration",0)
        send_debug(client, f"INIT track={track_id} bpm={bpm} sections={len(sections)} total_time={total_secs:.1f}s")

    # 收集所有潜在布尔 & 数值字段（用于重置）
    bool_keys = set()
    num_keys = set()
    for _ch, _sk, data in sections:
        for k, v in data.items():
            if k in RESERVED_FIELDS: continue
            if is_bool_like(v):
                bool_keys.add(k)
            elif isinstance(v, (int,float)):
                num_keys.add(k)

    start_wall = time.time()
    print(f"[INFO] 开始调度，共 {len(sections)} sections, time_scale={args.time_scale}")
    for ch, sk, data in sections:
        st = data["start_time"] / args.time_scale
        now = time.time() - start_wall
        wait = st - now
        if wait > 0:
            print(f"[WAIT] {ch}/{sk} 等待 {wait:.2f}s (scaled)")
            time.sleep(wait)

        print(f"[SECTION] {ch}/{sk} t={st:.2f}s")
        # 核心字段
        chord_index = data.get("chord_index", 0)
        energy = data.get("energy", 0.0)
        density = data.get("density", 0.0)
        parts = data.get("active_parts", [])

        if not args.dry_run:
            send(client, CORE_FIELDS["chord_index"], chord_index)
            send(client, CORE_FIELDS["energy"], energy)
            send(client, CORE_FIELDS["density"], density)
            send(client, CORE_FIELDS["active_parts"], ",".join(parts))

        # 字段分类发送
        # 先构建该 section 实际使用的 bool/num
        sec_bool = {}
        sec_num = {}
        for k, v in data.items():
            if k in RESERVED_FIELDS: continue
            if is_bool_like(v):
                sec_bool[k] = bool_value(v)
            elif isinstance(v, (int,float)):
                sec_num[k] = v

        # 重置未出现的布尔为 0
        for bk in bool_keys:
            val = sec_bool.get(bk, 0)
            if not args.dry_run:
                send(client, f"/engine/toggle/{bk}", val)

        #发送数值参数
        for nk in num_keys:
            if nk in sec_num:
                if not args.dry_run:
                    send(client, f"/engine/param/{nk}", sec_num[nk])
            else:
                # 可选择不重置缺省，以避免突兀；如需清零可启用：
                # send(client, f"/engine/param/{nk}", 0)
                pass

        # 单独列出激活 toggles
        active_toggles = [k for k,v in sec_bool.items() if v == 1]
        if active_toggles:
            print(f"  toggles_on={active_toggles}")
        
        if not args.no_section_debug and not args.dry_run:
            dbg_parts = "/".join(parts) if parts else "-"
            send_debug(client, f"SECTION {ch}.{sk} ci={chord_index} E={energy} D={density} parts={dbg_parts}")

    if not args.dry_run:
        send_debug(client, "DONE all_sections_sent")
    print("[DONE] 全部 Section 已发送。")

if __name__ == "__main__":
    main()