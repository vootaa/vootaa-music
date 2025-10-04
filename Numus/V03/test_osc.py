from pythonosc import udp_client
import json
import time

client = udp_client.SimpleUDPClient("127.0.0.1", 4560)

# 测试 Kick Pattern - 不要在 JSON 中加冒号前缀
params = {
    "pt": [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
    "syn": "bd_haus",  # 移除冒号
    "amp": 1.0,
    "db": 4
}

print("发送 play kick 命令...")
client.send_message("/numus/cmd", ["play", "test_kick", "kick", json.dumps(params)])

time.sleep(5)

# 测试 Bass Line
bass_params = {
    "ns": ["c2", "c2", "as1", "as1"],  # 移除冒号
    "syn": "bass_foundation",  # 移除冒号
    "amp": 0.8,
    "db": 4
}

print("发送 play bass 命令...")
client.send_message("/numus/cmd", ["play", "test_bass", "bass", json.dumps(bass_params)])

time.sleep(5)

# 调整参数
print("调整 kick 音量...")
client.send_message("/numus/cmd", ["set", "test_kick", "vol", 0.5])

time.sleep(5)

# 停止单个
print("停止 kick...")
client.send_message("/numus/cmd", ["stop", "test_kick"])

time.sleep(2)

# 停止所有
print("停止所有...")
client.send_message("/numus/cmd", ["stop_all"])