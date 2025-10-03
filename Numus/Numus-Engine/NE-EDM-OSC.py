#!/usr/bin/env python3
"""
NE-EDM-OSC.py – DNA 时间线 → Sonic Pi OSC 指挥
"""
import json, time, argparse, math, shutil, sys
from pathlib import Path
from typing import Any, Dict, List, Tuple
from pythonosc import udp_client

CORE_PARAM_ADDR={"bpm":"/engine/bpm","energy":"/engine/param/energy","density":"/engine/param/density","chord_index":"/engine/param/chord_index","active_parts":"/engine/parts"}
PATTERN_KEY="pattern_overrides"
RESERVED={"start_time","duration","energy","density","active_parts","chord_index","track_id","bpm","key","scale","chord_progression","chapters","sweep_phase_start","sweep_phase_end","micro_energy"}
NUMERIC_WHITELIST={"pad_cutoff","sub_fade_level","hat_density","sidechain_depth","bass_drive","lead_detune","reverb_bus","delay_mix","chord_inversion"}
TOGGLE_WHITELIST={"sub_fade","texture_air","texture_grain","drop_gap","snare_roll","snare_fill"}
BASE_PAD_CUTOFF_MIN=70
BASE_PAD_CUTOFF_MAX=132
PAD_CUTOFF_MIN_HARD=40
PAD_CUTOFF_MAX_HARD=130

class Timeline:
    def __init__(self,dna:Dict[str,Any]):
        self.dna=dna
        self.sections:List[Tuple[str,str,Dict[str,Any]]]=[]
        for ch_k,ch_v in dna.get("chapters",{}).items():
            for sec_k,sec_v in ch_v.get("sections",{}).items():
                self.sections.append((ch_k,sec_k,sec_v))
        # fill missing start_time
        if any("start_time" not in s[2] for s in self.sections):
            t=0.0
            for _,_,d in self.sections:
                d.setdefault("duration",60)
                d["start_time"]=t
                t+=d["duration"]
        self.sections.sort(key=lambda x:x[2]["start_time"])
        # backfill duration if absent (until next start / last=60)
        for i,(c,s,d) in enumerate(self.sections):
            if "duration" not in d:
                if i<len(self.sections)-1:
                    d["duration"]=self.sections[i+1][2]["start_time"]-d["start_time"]
                else:
                    d["duration"]=60.0
    def filtered(self,ch=None,sec=None):
        start=(ch is None and sec is None)
        for C,S,D in self.sections:
            if not start:
                if C==ch and (sec is None or S==sec):
                    start=True
            if start:
                yield C,S,D

def is_bool_like(v): return isinstance(v,bool) or (isinstance(v,(int,float)) and v in (0,1)) or (isinstance(v,str) and v.lower() in ("0","1","true","false","on","off"))
def to_bool_int(v): return 1 if (isinstance(v,bool) and v) or (str(v).lower() in ("1","true","on")) else 0
def send(client,addr,val): client.send_message(addr,val)
def dbg(client,msg):
    try: client.send_message("/engine/debug",msg)
    except: pass

def derive_pad_cutoff(sec,energy):
    if "sweep_phase_start" in sec and "sweep_phase_end" in sec:
        r=max(0.0,min(1.0,sec["sweep_phase_start"]))
        return int(BASE_PAD_CUTOFF_MIN+(BASE_PAD_CUTOFF_MAX-BASE_PAD_CUTOFF_MIN)*r)
    return int(90+(energy*40))

def interpolate_sweep(sec,elapsed,total):
    sp0=max(0.0,min(1.0,sec.get("sweep_phase_start",0.0)))
    sp1=max(0.0,min(1.0,sec.get("sweep_phase_end",sp0)))
    if total<=0: return int(BASE_PAD_CUTOFF_MIN+(BASE_PAD_CUTOFF_MAX-BASE_PAD_CUTOFF_MIN)*sp1)
    t=max(0.0,min(1.0,elapsed/total))
    cur=sp0+(sp1-sp0)*t
    return int(BASE_PAD_CUTOFF_MIN+(BASE_PAD_CUTOFF_MAX-BASE_PAD_CUTOFF_MIN)*cur)

def anti_drop_adjust(sec,params,toggles):
    params["sidechain_depth"]=min(params.get("sidechain_depth",0.2),0.25)
    params["bass_drive"]=min(params.get("bass_drive",0.2),0.25)
    toggles["drop_gap"]=1; toggles["sub_fade"]=1
    params["sub_fade_level"]=min(params.get("sub_fade_level",0.4),0.4)

def callback_theme_adjust(sec,params,toggles):
    params["reverb_bus"]=min(0.45,params.get("reverb_bus",0.30)+0.08)
    params["pad_cutoff"]=max(params.get("pad_cutoff",100),105)
    toggles["texture_air"]=1

def micro_energy_mod(sec,params):
    me=sec.get("micro_energy")
    if me is None: return
    params["sidechain_depth"]=round(min(0.65,params.get("sidechain_depth",0.2)+me*0.04),4)
    params["pad_cutoff"]=min(132,params.get("pad_cutoff",110)+me*2)

def pattern_override(client,po):
    for part,pid in po.items():
        send(client,f"/engine/pattern/{part}",pid)

def build_param_and_toggle_sets(sec):
    params={}; toggles={}
    for k,v in sec.items():
        if k in RESERVED: continue
        if k in NUMERIC_WHITELIST and isinstance(v,(int,float)): params[k]=float(v)
        elif k in TOGGLE_WHITELIST and is_bool_like(v): toggles[k]=to_bool_int(v)
    return params,toggles

def colorize(s,c,no_color):
    if no_color: return s
    codes={"g":32,"y":33,"c":36,"m":35,"r":31}
    return f"\033[{codes.get(c,37)}m{s}\033[0m"

def fmt_table(rows,pad=1):
    if not rows: return ""
    cols=list(zip(*rows))
    widths=[max(len(str(c)) for c in col) for col in cols]
    out=[]
    for r in rows:
        out.append(" ".join(str(c).ljust(w+pad) for c,w in zip(r,widths)))
    return "\n".join(out)

def clamp_pad(v):
    if v is None: return 100
    if v>PAD_CUTOFF_MAX_HARD: return PAD_CUTOFF_MAX_HARD
    if v<PAD_CUTOFF_MIN_HARD: return PAD_CUTOFF_MIN_HARD
    return v

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--dna",required=True)
    ap.add_argument("--host",default="127.0.0.1")
    ap.add_argument("--port",type=int,default=4560)
    ap.add_argument("--time-scale",type=float,default=1.0)
    ap.add_argument("--start-chapter")
    ap.add_argument("--start-section")
    ap.add_argument("--pad-sweep-interval",type=float,default=1.0)
    ap.add_argument("--show-sections",action="store_true")
    ap.add_argument("--countdown",type=int,default=3,help="启动前倒计时秒")
    ap.add_argument("--progress",action="store_true",help="打印已播进度")
    ap.add_argument("--no-debug",action="store_true")
    ap.add_argument("--no-color",action="store_true")
    ap.add_argument("--dry-run",action="store_true")
    args=ap.parse_args()

    dna_path=Path(args.dna)
    if not dna_path.exists():
        print("DNA file missing")
        return
    dna=json.loads(dna_path.read_text(encoding="utf-8"))
    tl=Timeline(dna)
    sections=list(tl.filtered(args.start_chapter,args.start_section))
    if not sections:
        print("No sections after filter")
        return

    if args.show_sections:
        rows=[("Idx","Chapter.Section","Start","Dur","E","D","µE","Flags")]
        for i,(ch,sk,sec) in enumerate(sections):
            flags=[]
            for f in ("callback_theme","anti_drop","sub_fade","drop_gap"):
                if sec.get(f): flags.append(f.replace("_",""))
            rows.append((i,f"{ch}.{sk}",round(sec["start_time"],1),round(sec.get("duration",0),1),
                         sec.get("energy","-"),sec.get("density","-"),
                         sec.get("micro_energy","-"),",".join(flags)))
        print(fmt_table(rows))
        if args.dry_run: return

    client=udp_client.SimpleUDPClient(args.host,args.port)
    w=shutil.get_terminal_size((100,20)).columns
    banner=f"[NE-EDM-OSC] Track={dna.get('track_id')} BPM={dna.get('bpm',120)} Sections={len(sections)} Host={args.host}:{args.port} scale={args.time_scale}"
    print(colorize(banner,"c",args.no_color))

    if args.countdown>0:
        for r in range(args.countdown,0,-1):
            print(colorize(f"Starting in {r}...","y",args.no_color)); time.sleep(1)

    bpm=dna.get("bpm",120)
    chord_prog=dna.get("chord_progression",[])
    if not args.dry_run:
        send(client,"/engine/bpm",bpm)
        if chord_prog: send(client,"/engine/chord_prog",",".join(chord_prog))
        if not args.no_debug: dbg(client,f"INIT track={dna.get('track_id')} sections={len(sections)}")

    start_wall=time.time()
    last_sent:Dict[str,float]={}
    bool_state:Dict[str,int]={}

    def send_param(name,val):
        if name=="pad_cutoff": val=clamp_pad(val)
        addr=f"/engine/param/{name}"
        if last_sent.get(name)!=val and not args.dry_run:
            send(client,addr,val); last_sent[name]=val

    def send_toggle(name,val):
        addr=f"/engine/toggle/{name}"
        if bool_state.get(name)!=val and not args.dry_run:
            send(client,addr,val); bool_state[name]=val

    total_duration=sections[-1][2]["start_time"]+sections[-1][2].get("duration",0)
    scaled_total_duration = total_duration / args.time_scale
    for idx,(ch,sk,sec) in enumerate(sections):
        st=sec["start_time"]/args.time_scale
        now=time.time()-start_wall
        wait=st-now
        if wait>0: time.sleep(wait)
        energy=sec.get("energy",0.0); density=sec.get("density",0.0)
        chord_index=sec.get("chord_index",0); parts=sec.get("active_parts",[])
        if not args.dry_run:
            send(client,"/engine/param/chord_index",chord_index)
            send(client,"/engine/param/energy",energy)
            send(client,"/engine/param/density",density)
            send(client,"/engine/parts",",".join(parts))
        po=sec.get(PATTERN_KEY)
        if po and not args.dry_run: pattern_override(client,po)

        params,toggles=build_param_and_toggle_sets(sec)
        if "pad_cutoff" not in params: params["pad_cutoff"]=derive_pad_cutoff(sec,energy)
        micro_energy_mod(sec,params)
        if sec.get("callback_theme"): callback_theme_adjust(sec,params,toggles)
        if sec.get("anti_drop"): anti_drop_adjust(sec,params,toggles)
        if sec.get("sub_fade") and "sub_fade_level" not in params: params["sub_fade_level"]=0.5

        for tk,val in toggles.items(): send_toggle(tk,val)
        for tk in TOGGLE_WHITELIST:
            if tk not in toggles: send_toggle(tk,0)
        for nk,val in params.items(): send_param(nk,float(val))

        if not args.no_debug and not args.dry_run:
            dbg(client,f"SEC {idx} {ch}.{sk} E={energy} D={density} parts={len(parts)}")
        if args.progress:
            elapsed=time.time()-start_wall
            pct=elapsed/scaled_total_duration if scaled_total_duration>0 else 0
            bar_len=min(40,max(10,int(w*0.25)))
            fill=int(bar_len*pct)
            bar="["+"#"*fill+"-"*(bar_len-fill)+"]"
            print(colorize(f"{idx:02d} {ch}.{sk} {bar} {pct*100:5.1f}% t={int(elapsed)}/{int(total_duration)}s","g",args.no_color))

        dur=sec.get("duration",0)/args.time_scale
        if "sweep_phase_start" in sec and "sweep_phase_end" in sec and dur>0:
            steps=max(1,int(dur/args.pad_sweep_interval))
            base=time.time()
            for sidx in range(1,steps+1):
                frac=sidx/steps
                target=interpolate_sweep(sec,frac*dur,dur)
                send_param("pad_cutoff",target)
                remain=base+frac*dur-time.time()
                if remain>0: time.sleep(remain)

    if not args.dry_run:
        dbg(client,"DONE timeline"); send(client,"/engine/stop",1)
    print(colorize("Playback complete.","m",args.no_color))

if __name__=="__main__":
    try: main()
    except KeyboardInterrupt:
        print("\nInterrupted.")