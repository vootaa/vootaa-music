# Numus Engine V2.0 - 长篇车载 EDM 生成系统

> 数学驱动、音乐性优先、个人化实验的自动作曲引擎  
> 专为长篇车载 EDM 作品设计

## 🎵 系统概述

Numus Engine V2.0 是一个专门用于生成长篇车载 EDM 作品的音乐系统。它采用确定性的数学序列（π、e、φ）驱动音乐生成，结合专业的 DJ 过渡技术，为车载环境优化音频表现。

### 核心特性

- **🔢 确定性生成**: 基于 π、e、φ 等数学常数，拒绝随机性
- **🚗 车载优化**: 针对不同车型的音响系统优化
- **🎪 章节化架构**: 8个独立章节，专业 DJ 过渡衔接
- **🎛️ Section 库**: 丰富的 EDM 素材片段库
- **🎨 MIDI 装饰**: 动态生成装饰采样，丰富音乐层次
- **⚡ 实时控制**: Python OSC 主控 + Sonic Pi 播放器

## 📁 文件结构

```
Numus/V02/
├── engine/
│   ├── numus_engine.py      # 核心引擎
│   ├── section_library.py   # Section 素材库
│   ├── dj_transitions.py    # DJ 过渡机制
│   ├── math_generator.py    # 数学序列生成
│   ├── midi_renderer.py     # MIDI 渲染
│   └── numus_player.rb      # Sonic Pi 播放器
├── sections/
│   └── sections_config.json # Section 配置库
├── tracks/
│   └── dawn_ignition.json   # Dawn Ignition 配置
├── output/
│   ├── wav/                 # 渲染输出
│   └── logs/                # 执行日志
└── README.md               # 操作说明
```

## 🚀 快速开始

### 1. 环境准备

#### 系统要求

- macOS 或 Linux
- Python 3.8+
- Sonic Pi 4.0+
- FluidSynth

#### 安装依赖

```bash
# Python 依赖
pip install pythonosc pretty_midi numpy

# macOS 安装 FluidSynth
brew install fluidsynth

# Linux 安装 FluidSynth  
sudo apt-get install fluidsynth
```

#### 检查 SoundFont

确保 `Numus/SF/FluidR3_GM.sf2` 文件存在。

### 2. 启动播放

#### 第一步：启动 Sonic Pi

1. 打开 Sonic Pi 应用
2. 加载文件：`Numus/V02/engine/numus_player.rb`
3. 点击运行，等待显示"Numus 播放循环已启动"

#### 第二步：运行引擎

```bash
cd Numus/V02
python engine/numus_engine.py
```

#### 第三步：选择配置

```
选择车载配置 (sedan_standard/suv_premium/sports_car) [回车默认]: sports_car
已加载作品: Dawn Ignition
专辑: Motion Groove
章节数: 8

开始预处理...
分配 Section 模板...
  章节 1: ambient_intro (ambient)
  章节 2: house_foundation (deep_house)
  ...
预渲染装饰采样...
  章节 1: 2 个装饰采样
  ...
预处理完成

按回车开始播放 Dawn Ignition...
```

### 3. 播放体验

播放开始后，你将体验到：

```
============================================================
🎵 开始播放: Dawn Ignition
🚗 车载配置: sports_car
⏱️  预计时长: 22.3 分钟
============================================================

🎪 章节 1: Gentle Awakening
   ⏳ 播放时长: 102.4 秒

🎪 章节 2: Pulse Forming
执行过渡: energy_crossfade (8 小节)
   ⏳ 播放时长: 102.4 秒
   🎨 装饰: pad

...

🎉 播放完成！实际时长: 22.1 分钟
```

## 🎛️ 车载音频配置

### 可用配置文件

#### sedan_standard (默认)

- **适用**: 普通轿车标准音响
- **低音增强**: 1.2x
- **中频清晰度**: 1.0x  
- **高频增强**: 1.1x

#### suv_premium

- **适用**: SUV 高级音响系统
- **低音增强**: 1.1x
- **中频清晰度**: 1.1x
- **高频增强**: 1.0x

#### sports_car

- **适用**: 跑车音响系统
- **低音增强**: 1.3x
- **中频清晰度**: 0.9x
- **高频增强**: 1.2x

### 手动设置配置

在代码中修改：

```python
engine.set_car_audio_profile("sports_car")
```

## 🎪 作品结构解析

### Dawn Ignition 章节设计

| 章节 | 名称 | 时长 | 能量 | 风格 | 车载特点 |
|------|------|------|------|------|----------|
| 1 | Gentle Awakening | 2.7min | 0.1→0.3 | Ambient | 中频清晰，适合清晨 |
| 2 | Pulse Forming | 2.7min | 0.3→0.5 | Deep House | 引入低频测试 |
| 3 | Energy Rise | 4.1min | 0.5→0.7 | Trance | 增加立体声层次 |
| 4 | Peak Drive | 5.5min | 0.7→0.9 | Progressive | 全频段体验 |
| 5 | Sustained Cruise | 6.8min | 0.8→0.8 | Progressive | 高速巡航稳定输出 |
| 6 | Emotional Breakdown | 4.1min | 0.8→0.4 | Breakdown | 中高频情感表达 |
| 7 | Final Ascent | 5.5min | 0.4→0.95 | Festival | 最强能量输出 |
| 8 | Dawn Complete | 2.7min | 0.9→0.2 | Ambient | 温和结束 |

### DJ 过渡技术

- **Energy Crossfade**: 能量平滑过渡
- **Filter Sweep**: 滤波器扫频过渡
- **Breakdown Build**: 分解重建过渡
- **Impact Drop**: 冲击降落过渡

## 🔧 自定义配置

### 创建新作品

1. 复制 `tracks/dawn_ignition.json`
2. 修改章节配置：

   ```json
   {
     "name": "Your Track Name",
     "chapters": [
       {
         "id": "your_chapter",
         "name": "Your Chapter Name", 
         "duration_bars": 32,
         "energy_start": 0.2,
         "energy_end": 0.6,
         "style_hint": "deep_house",
         "elements": ["kick", "bass", "pad"]
       }
     ]
   }
   ```

3. 加载新作品：

   ```python
   engine.load_track("tracks/your_track.json")
   ```

### 添加新 Section

编辑 `sections/sections_config.json`：

```json
{
  "section_library": {
    "your_section": {
      "style": "your_style",
      "energy_range": [0.4, 0.8],
      "elements": {
        "kick": {
          "sample": ":bd_your_kick",
          "pattern": [1, 0, 0, 0, 1, 0, 0, 0],
          "car_boost": 1.2
        }
      }
    }
  }
}
```

## 🎨 数学序列说明

### 确定性生成原理

Numus 使用数学常数的小数位驱动音乐生成：

- **π (圆周率)**: 主要用于能量曲线和装饰触发
- **e (自然常数)**: 用于和声进行和节奏变化  
- **φ (黄金比例)**: 用于旋律生成和时间结构

### 序列使用示例

```python
# 获取 π 序列片段
pi_sequence = generator.get_sequence("pi", start=100, length=50)

# 生成装饰触发点
triggers = generator.generate_ornament_triggers(chapter_idx=2, bars=32)

# 生成能量曲线
energy_curve = generator.generate_energy_curve(chapters)
```

## 🚗 车载驾驶建议

### 最佳聆听环境

- **时段**: 清晨出发，长途驾驶
- **音量**: 中等音量，确保安全驾驶
- **环境**: 高速公路或开阔道路

### 章节特色体验

1. **Gentle Awakening**: 温和启动，适合出发前热车
2. **Pulse Forming**: 开始上路，建立节奏感
3. **Energy Rise**: 进入状态，逐步加速
4. **Peak Drive**: 高速驾驶，享受音乐与速度
5. **Sustained Cruise**: 稳定巡航，放松身心
6. **Emotional Breakdown**: 情感释放，体验音乐深度
7. **Final Ascent**: 最后冲刺，到达目的地前的兴奋
8. **Dawn Complete**: 平静结束，安全到达

## 🔍 故障排除

### 常见问题

#### 1. FluidSynth 未找到

```bash
错误: 未找到 fluidsynth 命令
```

**解决**: 安装 FluidSynth

```bash
# macOS
brew install fluidsynth

# Ubuntu/Debian  
sudo apt-get install fluidsynth
```

#### 2. SoundFont 文件缺失

```bash
警告: SoundFont 文件不存在
```

**解决**: 确保 `Numus/SF/FluidR3_GM.sf2` 存在

#### 3. Sonic Pi 连接失败

```bash
OSC 连接错误
```

**解决**:

1. 确保 Sonic Pi 正在运行
2. 检查 OSC 端口设置（默认 4560）
3. 重启 Sonic Pi

#### 4. 装饰采样渲染失败

```bash
渲染装饰音失败
```

**解决**:

1. 检查 output/wav 目录权限
2. 确认 FluidSynth 正常工作
3. 检查磁盘空间

### 调试模式

启用详细日志：

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

**Numus Engine V2.0** - 让数学与音乐在车载空间中完美融合 🎵🚗
