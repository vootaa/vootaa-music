#!/usr/bin/env python3
"""
NE-EDM-OSC.py
Advanced DNA timeline → OSC conductor.

Design goals:
- Ruby engine stays minimal (no internal transitions logic).
- This script performs: section scheduling, param interpolation (filter sweeps), adaptive micro_energy modulation,
  callback + anti_drop behaviors, pattern & toggle management, reduced redundant OSC.
- Deterministic: all transformations derived from DNA numeric fields (no random).
"""

import json, time, argparse, math
from pathlib import Path
from typing import Any, Dict, List, Tuple
from pythonosc import udp_client

CORE_PARAM_ADDR = {
    "bpm": "/engine/bpm",
    "energy": "/engine/param/energy",
    "density": "/engine/param/density",
    "chord_index": "/engine/param/chord_index",
    "active_parts": "/engine/parts"
}

PATTERN_KEY = "pattern_overrides"
RESERVED = {
    "start_time","duration","energy","density","active_parts","chord_index",
    "track_id","bpm","key","scale","chord_progression","chapters",
    "sweep_phase_start","sweep_phase_end","micro_energy"
}

NUMERIC_WHITELIST = {
    "pad_cutoff","sub_fade_level","hat_density","sidechain_depth","bass_drive",
    "lead_detune","reverb_bus","delay_mix","chord_inversion"
}

TOGGLE_WHITELIST = {
    "sub_fade","texture_air","texture_grain","drop_gap",
    "snare_roll","snare_fill"
}

BASE_PAD_CUTOFF_MIN = 70
BASE_PAD_CUTOFF_MAX = 132

class Timeline:
    def __init__(self, dna: Dict[str,Any]):
        self.dna = dna
        self.sections: List[Tuple[str,str,Dict[str,Any]]] = []
        for ch_k, ch_v in dna.get("chapters",{}).items():
            for sec_k, sec_v in ch_v.get("sections",{}).items():
                self.sections.append((ch_k,sec_k,sec_v))
        # ensure start times
        if any("start_time" not in s[2] for s in self.sections):
            t=0.0
            for _,_,d in self.sections:
                d.setdefault("duration",60)
                d["start_time"]=t
                t+=d["duration"]
        self.sections.sort(key=lambda x: x[2]["start_time"])

    def filtered(self, ch=None, sec=None):
        start_flag = (ch is None and sec is None)
        for c,s,d in self.sections:
            if not start_flag:
                if c==ch and (sec is None or s==sec):
                    start_flag=True
            if start_flag:
                yield c,s,d

def is_bool_like(v: Any)->bool:
    if isinstance(v,bool): return True
    if isinstance(v,(int,float)) and v in (0,1): return True
    if isinstance(v,str) and v.lower() in ("0","1","true","false","on","off"): return True
    return False

def to_bool_int(v: Any)->int:
    if isinstance(v,bool): return 1 if v else 0
    return 1 if str(v).lower() in ("1","true","on") else 0

def send(client, addr, val): client.send_message(addr,val)
def dbg(client,msg): 
    try: client.send_message("/engine/debug",msg)
    except: pass

def derive_pad_cutoff(sec: Dict[str,Any], base_energy: float)->int:
    # If sweep phases exist: linear map
    if "sweep_phase_start" in sec and "sweep_phase_end" in sec:
        # initial cutoff at section enter will be start; we'll linearly morph to end over its duration
        # return start immediate; interpolation handled externally
        start_ratio = max(0.0,min(1.0, sec["sweep_phase_start"]))
        return int(BASE_PAD_CUTOFF_MIN + (BASE_PAD_CUTOFF_MAX-BASE_PAD_CUTOFF_MIN)*start_ratio)
    # fallback energy shaping
    return int(90 + (base_energy*40))

def interpolate_sweep(sec: Dict[str,Any], elapsed: float, total: float)->int:
    sp0 = max(0.0,min(1.0,sec.get("sweep_phase_start",0.0)))
    sp1 = max(0.0,min(1.0,sec.get("sweep_phase_end",sp0)))
    if total<=0: return int(BASE_PAD_CUTOFF_MIN + (BASE_PAD_CUTOFF_MAX-BASE_PAD_CUTOFF_MIN)*sp1)
    t = max(0.0,min(1.0, elapsed/total))
    cur = sp0 + (sp1-sp0)*t
    return int(BASE_PAD_CUTOFF_MIN + (BASE_PAD_CUTOFF_MAX-BASE_PAD_CUTOFF_MIN)*cur)

def anti_drop_adjust(sec: Dict[str,Any], params: Dict[str,float], toggles: Dict[str,int]):
    # reduce sidechain, reduce density-driven hats if present
    params["sidechain_depth"] = min(params.get("sidechain_depth",0.2),0.25)
    params["bass_drive"] = min(params.get("bass_drive",0.2),0.25)
    toggles["drop_gap"] = 1
    toggles["sub_fade"] = 1
    params["sub_fade_level"] = min(params.get("sub_fade_level",0.4),0.4)

def callback_theme_adjust(sec: Dict[str,Any], params: Dict[str,float], toggles: Dict[str,int]):
    # widen reverb + slight cutoff raise
    params["reverb_bus"] = min(0.45, params.get("reverb_bus",0.30)+0.08)
    params["pad_cutoff"] = max(params.get("pad_cutoff",100),105)
    toggles["texture_air"] = 1

def micro_energy_mod(sec: Dict[str,Any], params: Dict[str,float]):
    me = sec.get("micro_energy")
    if me is None: return
    # map 0..3 to sidechain micro boost + subtle cutoff nudge
    sx = params.get("sidechain_depth",0.2)
    params["sidechain_depth"] = round(min(0.65, sx + me*0.04),4)
    pc = params.get("pad_cutoff",110)
    params["pad_cutoff"] = min(132, pc + me*2)

def pattern_override(client, po: Dict[str,str]):
    for part,pid in po.items():
        send(client,f"/engine/pattern/{part}",pid)

def apply_section(client, sec: Dict[str,Any], dna: Dict[str,Any], first=False):
    # base parameters
    energy = sec.get("energy",0.0)
    density = sec.get("density",0.0)
    chord_index = sec.get("chord_index",0)
    parts = sec.get("active_parts",[])
    send(client, CORE_PARAM_ADDR["energy"], energy)
    send(client, CORE_PARAM_ADDR["density"], density)
    send(client, CORE_PARAM_ADDR["chord_index"], chord_index)
    send(client, CORE_PARAM_ADDR["active_parts"], ",".join(parts))

def build_param_and_toggle_sets(sec: Dict[str,Any]) -> Tuple[Dict[str,float], Dict[str,int]]:
    params={}
    toggles={}
    for k,v in sec.items():
        if k in RESERVED: continue
        if k in NUMERIC_WHITELIST and isinstance(v,(int,float)):
            params[k]=float(v)
        elif k in TOGGLE_WHITELIST and is_bool_like(v):
            toggles[k]=to_bool_int(v)
    return params,toggles

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--dna",required=True)
    ap.add_argument("--host",default="127.0.0.1")
    ap.add_argument("--port",type=int,default=4560)
    ap.add_argument("--time-scale",type=float,default=1.0)
    ap.add_argument("--start-chapter")
    ap.add_argument("--start-section")
    ap.add_argument("--dry-run",action="store_true")
    ap.add_argument("--pad-sweep-interval",type=float,default=1.0,help="seconds between sweep cutoff updates")
    ap.add_argument("--no-debug",action="store_true")
    args=ap.parse_args()

    dna_path=Path(args.dna)
    if not dna_path.exists():
        print("DNA file missing");return
    dna=json.loads(dna_path.read_text(encoding="utf-8"))
    tl=Timeline(dna)
    sections=list(tl.filtered(args.start_chapter,args.start_section))
    if not sections:
        print("No sections after filter");return

    client=udp_client.SimpleUDPClient(args.host,args.port)

    bpm=dna.get("bpm",120)
    chord_prog=dna.get("chord_progression",[])
    if not args.dry_run:
        send(client,"/engine/bpm",bpm)
        if chord_prog:
            send(client,"/engine/chord_prog",",".join(chord_prog))
        if not args.no_debug:
            dbg(client,f"INIT track={dna.get('track_id')} bpm={bpm} sections={len(sections)}")

    # Pre-calc global sets
    # We'll drive pad_cutoff dynamically even if not specified
    start_wall=time.time()
    last_sent: Dict[str,float]={}
    bool_state: Dict[str,int]={}

    def send_param(name,val):
        addr=f"/engine/param/{name}"
        if last_sent.get(name)!=val and not args.dry_run:
            send(client,addr,val)
            last_sent[name]=val

    def send_toggle(name,val):
        addr=f"/engine/toggle/{name}"
        if bool_state.get(name)!=val and not args.dry_run:
            send(client,addr,val)
            bool_state[name]=val

    for idx,(ch,sk,sec) in enumerate(sections):
        st = sec["start_time"]/args.time_scale
        now = time.time()-start_wall
        wait = st - now
        if wait>0:
            time.sleep(wait)

        energy=sec.get("energy",0.0)
        density=sec.get("density",0.0)
        chord_index=sec.get("chord_index",0)
        parts=sec.get("active_parts",[])
        if not args.dry_run:
            send(client,"/engine/param/chord_index",chord_index)
            send(client,"/engine/param/energy",energy)
            send(client,"/engine/param/density",density)
            send(client,"/engine/parts",",".join(parts))

        po=sec.get(PATTERN_KEY)
        if po and not args.dry_run:
            pattern_override(client,po)

        params,toggles=build_param_and_toggle_sets(sec)
        # Derive pad_cutoff baseline and sweeps
        if "pad_cutoff" not in params:
            params["pad_cutoff"]=derive_pad_cutoff(sec,energy)

        # micro_energy modulation influences sidechain/pad_cutoff
        micro_energy_mod(sec,params)

        # callback theme
        if sec.get("callback_theme"):
            callback_theme_adjust(sec,params,toggles)

        # anti-drop composite
        if sec.get("anti_drop"):
            anti_drop_adjust(sec,params,toggles)

        # ensure toggles sinks for implied logic
        if sec.get("sub_fade") and "sub_fade_level" not in params:
            params["sub_fade_level"]=0.5

        # Dispatch toggles first
        for tk,val in toggles.items():
            send_toggle(tk,val)
        # Reset missing toggles to 0 (only those we manage)
        for tk in TOGGLE_WHITELIST:
            if tk not in toggles:
                send_toggle(tk,0)

        # Send numeric params
        for nk,val in params.items():
            send_param(nk, float(val))

        # Live sweep interpolation
        dur = sec.get("duration",0)
        if "sweep_phase_start" in sec and "sweep_phase_end" in sec:
            sweep_total = dur/args.time_scale
            steps = max(1,int(sweep_total/args.pad_sweep_interval))
            base_start=time.time()
            for sidx in range(1,steps+1):
                frac = sidx/steps
                target = interpolate_sweep(sec, frac*sweep_total, sweep_total)
                send_param("pad_cutoff",target)
                remain = base_start + frac*sweep_total - time.time()
                if remain>0: time.sleep(remain)

        if not args.no_debug and not args.dry_run:
            dbg(client,f"SEC {ch}.{sk} E={energy:.2f} D={density:.2f} parts={len(parts)}")

    if not args.dry_run:
        dbg(client,"DONE timeline")
        send(client,"/engine/stop",1)

if __name__=="__main__":
    main()