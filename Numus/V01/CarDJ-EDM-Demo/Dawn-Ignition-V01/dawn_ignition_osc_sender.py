import json
import time
from pathlib import Path
from pythonosc import udp_client

# Config: adjust port if needed (Sonic Pi often receives on 4559; if your test used 4560 keep it)
SONIC_PI_HOST = "127.0.0.1"
SONIC_PI_PORT = 4560  # try 4559 if no response

# Load DNA JSON relative to this script
BASE_DIR = Path(__file__).parent
dna_path = BASE_DIR / "dawn_ignition_dna.json"

try:
    with dna_path.open("r", encoding="utf-8") as f:
        dna = json.load(f)
    print(f"JSON加载成功: {dna_path.name}")
except Exception as e:
    print(f"JSON加载失败: {e}")
    raise SystemExit(1)

# Prepare OSC client
client = udp_client.SimpleUDPClient(SONIC_PI_HOST, SONIC_PI_PORT)
client.send_message("/debug", "sender_online")
print(f"OSC连接 -> {SONIC_PI_HOST}:{SONIC_PI_PORT}")

bpm = dna["bpm"]
chord_prog = dna["chord_progression"]

print(f"启动编排: track={dna.get('track_id')} BPM={bpm} 章节数={len(dna['chapters'])}")

# Features that need explicit reset each section
toggle_keys = ["kick_sparse", "fx_riser", "snare", "filter_sweep", "sub_fade"]

start_time = time.time()

def send_param(addr, val):
    client.send_message(addr, str(val))

for ch_key, ch_data in dna["chapters"].items():
    for sec_key, sec_data in ch_data["sections"].items():
        # Wait until section start (wall clock scheduling)
        elapsed = time.time() - start_time
        wait = sec_data["start_time"] - elapsed
        if wait > 0:
            print(f"等待 {ch_key}_{sec_key} -> {wait:.2f}s")
            time.sleep(wait)

        # Core parameters
        chord = chord_prog[sec_data["chord_index"]]
        parts = ",".join(sec_data["active_parts"])
        print(f"Section {ch_key}_{sec_key}: energy={sec_data['energy']} density={sec_data['density']} chord={chord} parts={parts}")

        send_param("/set_energy", sec_data["energy"])
        send_param("/set_density", sec_data["density"])
        send_param("/set_chord", chord)
        send_param("/active_parts", parts)

        # Reset all toggles to 0 first
        for k in toggle_keys:
            active = 1 if sec_data.get(k) else 0
            send_param(f"/{k}", active)
            if active:
                print(f"  Toggle {k}=1")

print("乐曲播放完成 (所有Section已发送)")