from pythonosc.udp_client import SimpleUDPClient

# 本机地址 + Sonic Pi 默认接收端口
ip = "127.0.0.1"
port = 4560

client = SimpleUDPClient(ip, port)

# 向 Sonic Pi 发送 OSC 指令
client.send_message("/play_this", [60])  # 60 = MIDI音符 C4
print("已发送OSC消息: C4")
