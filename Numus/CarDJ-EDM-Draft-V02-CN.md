# 汽车DJ-EDM系统技术草案 V0.2

## 项目概述

基于Numus算法机制，构建专为车载环境设计的长时EDM生成系统。系统通过Python算法生成、OSC协议控制、Sonic Pi实时合成和录制输出，实现《动感旅途》专辑的6首独立EDM乐曲。

---

## 1. 系统架构设计

### 1.1 Numus核心架构适配

遵循Numus三层架构，针对车载EDM进行专门化设计：

```
DNA层（逻辑性模块-频繁迭代）
├── 专辑DNA配置（JSON）
├── 乐曲DNA配置（JSON + Python）  
└── 章节DNA配置（JSON + Python）

算法生成层（功能性模块-稳定结构）
├── NumusEngine（Python核心）
├── OSC控制器（Python）
└── MIDI渲染器（Python + FluidSynth）

Sonic Pi合成层（功能性+逻辑性混合）
├── EDM骨干合成（Ruby-功能性）
├── 乐曲编排逻辑（Ruby-逻辑性）
└── 录制输出（Ruby-功能性）
```

### 1.2 工作流程架构

```python
# 单曲制作完整工作流
class TrackProductionWorkflow:
    def __init__(self, track_name):
        self.track_name = track_name
        self.osc_client = OSCClient("127.0.0.1", 4559)  # Sonic Pi OSC端口
        
    def produce_track(self):
        """单曲制作主流程"""
        # 第1步：加载DNA配置（逻辑性模块）
        track_dna = self.load_track_dna(self.track_name)
        
        # 第2步：生成MIDI装饰层（功能性模块）
        midi_decorations = self.generate_midi_decorations(track_dna)
        
        # 第3步：渲染MIDI为WAV采样（功能性模块）
        wav_samples = self.render_midi_to_wav(midi_decorations)
        
        # 第4步：通过OSC启动Sonic Pi播放（功能性模块）
        self.start_sonic_pi_session(track_dna, wav_samples)
        
        # 第5步：录制完整乐曲WAV（Sonic Pi内置录制）
        final_wav = self.record_track_from_sonic_pi()
        
        return final_wav
```

---

## 2. 层级DNA配置系统

### 2.1 逻辑性模块设计（频繁迭代）

```python
# 专辑级DNA配置 - albums/motion_groove.json
ALBUM_DNA = {
    "album_id": "motion_groove",
    "total_tracks": 6,
    "global_energy_curve": [0.3, 0.7, 0.9, 0.8, 0.3, 0.95],
    "key_progression": ["C", "Am", "F", "Dm", "G", "C"],
    "style_evolution": [
        "progressive_house", "electro_house", "trance", 
        "ambient_trance", "chillout", "uplifting_trance"
    ],
    "car_audio_profile": "premium_surround"  # 车载音响配置
}

# 乐曲级DNA配置 - tracks/dawn_ignition.json  
TRACK_DNA = {
    "track_id": "dawn_ignition",
    "duration_minutes": 25,
    "bpm": 120,
    "key": "C_major",
    "style": "progressive_house",
    "energy_target": 0.3,  # 来自专辑级
    
    # 章节规划
    "chapters": [
        {
            "name": "gentle_awakening",
            "duration_seconds": 180,
            "energy_local": 0.2,
            "midi_decoration_needs": {
                "melody_complexity": "simple",
                "harmonic_density": "sparse", 
                "ornamental_elements": ["birds", "morning_bells"]
            }
        },
        # ...更多章节
    ],
    
    # MIDI装饰层配置
    "midi_decoration_config": {
        "melody_instruments": ["acoustic_piano", "flute"],
        "harmony_instruments": ["strings", "choir_pad"],
        "ornamental_samples": ["nature_birds", "morning_chimes"],
        "render_quality": "44khz_16bit"
    }
}

# 章节级DNA配置 - chapters/gentle_awakening.json
CHAPTER_DNA = {
    "chapter_id": "gentle_awakening", 
    "structure": "intro_build_sustain_outro",
    "edm_backbone_spec": {
        "kick_pattern": "minimal_four_four",
        "bass_type": "warm_sub",
        "pad_progression": ["C", "Am", "F", "G"],
        "lead_synth": "soft_saw_lead",
        "effects_chain": ["reverb_hall", "filter_sweep_slow"]
    },
    "midi_decoration_spec": {
        "melody_notes_per_bar": 4,
        "melody_note_range": ["C4", "C6"], 
        "harmony_voicing": "open_triads",
        "ornament_density": 0.3  # 30%的小节包含装饰音符
    }
}
```

### 2.2 配置加载与验证（功能性模块）

```python
class DNAConfigManager:
    """稳定的DNA配置管理器"""
    
    def __init__(self, config_root="config/"):
        self.config_root = config_root
        
    def load_track_dna(self, track_name):
        """加载完整的乐曲DNA配置"""
        # 加载专辑级配置
        album_dna = self._load_json(f"albums/motion_groove.json")
        
        # 加载乐曲级配置
        track_dna = self._load_json(f"tracks/{track_name}.json")
        
        # 加载所有章节配置
        chapters_dna = []
        for chapter_spec in track_dna["chapters"]:
            chapter_dna = self._load_json(f"chapters/{chapter_spec['name']}.json")
            chapters_dna.append(chapter_dna)
        
        # 合并配置
        return {
            "album": album_dna,
            "track": track_dna, 
            "chapters": chapters_dna
        }
    
    def validate_dna_consistency(self, dna_config):
        """验证DNA配置的一致性"""
        # 检查能量曲线一致性
        # 检查调性关系合理性
        # 检查时长分配合理性
        pass
```

---

## 3. MIDI装饰层生成系统

### 3.1 装饰层需求分析

```python
class MIDIDecorationAnalyzer:
    """分析EDM骨干，提出MIDI装饰需求"""
    
    def analyze_decoration_needs(self, chapter_dna, edm_backbone_spec):
        """基于EDM骨干分析装饰需求"""
        needs = {
            "melody_requirements": self._analyze_melody_needs(edm_backbone_spec),
            "harmony_requirements": self._analyze_harmony_needs(edm_backbone_spec),
            "ornament_requirements": self._analyze_ornament_needs(chapter_dna)
        }
        return needs
    
    def _analyze_melody_needs(self, edm_spec):
        """分析旋律装饰需求"""
        # 根据EDM的pad_progression确定旋律调性
        # 根据kick_pattern确定旋律节奏密度
        # 根据lead_synth类型确定旋律音域避让
        
        return {
            "scale": self._derive_scale_from_progression(edm_spec["pad_progression"]),
            "rhythm_density": self._calculate_melody_density(edm_spec["kick_pattern"]),
            "frequency_range": self._calculate_melody_range(edm_spec["lead_synth"]),
            "articulation": "legato" if "pad" in edm_spec["lead_synth"] else "staccato"
        }
```

### 3.2 MIDI生成与渲染

```python
class MIDIDecorationGenerator:
    """MIDI装饰层生成器（功能性模块）"""
    
    def __init__(self):
        self.pi_sequence = self._generate_pi_sequence(10000)
        self.phi_ratio = 1.618033988749895
        
    def generate_chapter_decorations(self, chapter_dna, decoration_needs):
        """为单个章节生成MIDI装饰"""
        decorations = {}
        
        # 生成旋律层
        if decoration_needs["melody_requirements"]:
            melody_midi = self._generate_melody_midi(
                chapter_dna, 
                decoration_needs["melody_requirements"]
            )
            decorations["melody"] = melody_midi
            
        # 生成和声层  
        if decoration_needs["harmony_requirements"]:
            harmony_midi = self._generate_harmony_midi(
                chapter_dna,
                decoration_needs["harmony_requirements"] 
            )
            decorations["harmony"] = harmony_midi
            
        # 生成装饰层
        if decoration_needs["ornament_requirements"]:
            ornament_midi = self._generate_ornament_midi(
                chapter_dna,
                decoration_needs["ornament_requirements"]
            )
            decorations["ornaments"] = ornament_midi
            
        return decorations
    
    def render_decorations_to_wav(self, decorations, output_dir):
        """渲染MIDI装饰为WAV采样"""
        wav_paths = {}
        
        for layer_name, midi_data in decorations.items():
            # 保存MIDI文件
            midi_path = f"{output_dir}/{layer_name}.mid"
            self._save_midi(midi_data, midi_path)
            
            # 渲染为WAV
            wav_path = f"{output_dir}/{layer_name}.wav"
            self._render_with_fluidsynth(midi_path, wav_path)
            
            wav_paths[layer_name] = wav_path
            
        return wav_paths
    
    def _render_with_fluidsynth(self, midi_path, wav_path):
        """使用FluidSynth渲染MIDI为WAV"""
        import subprocess
        
        # 使用高质量SoundFont
        soundfont_path = "assets/soundfonts/FluidR3_GM.sf2"
        
        cmd = [
            "fluidsynth", 
            "-ni", soundfont_path,
            midi_path,
            "-F", wav_path,
            "-r", "44100"
        ]
        
        subprocess.run(cmd, check=True)
```

---

## 4. OSC控制与Sonic Pi集成

### 4.1 OSC控制系统

```python
class SonicPiController:
    """Sonic Pi OSC控制器（功能性模块）"""
    
    def __init__(self, host="127.0.0.1", port=4559):
        from pythonosc import udp_client
        self.client = udp_client.SimpleUDPClient(host, port)
        
    def start_track_session(self, track_dna, wav_samples):
        """启动乐曲播放会话"""
        # 发送初始化消息
        self.client.send_message("/numus/init", [track_dna["track"]["track_id"]])
        
        # 发送WAV采样路径
        for layer_name, wav_path in wav_samples.items():
            self.client.send_message(f"/numus/sample/{layer_name}", [wav_path])
        
        # 发送乐曲结构信息
        self._send_track_structure(track_dna)
        
        # 启动播放
        self.client.send_message("/numus/play", ["start"])
        
    def control_chapter_transition(self, from_chapter, to_chapter, transition_spec):
        """控制章节过渡"""
        self.client.send_message("/numus/transition", [
            from_chapter["chapter_id"],
            to_chapter["chapter_id"], 
            transition_spec["method"],
            transition_spec["duration_bars"]
        ])
        
    def start_recording(self, output_path):
        """启动Sonic Pi录制"""
        self.client.send_message("/numus/record/start", [output_path])
        
    def stop_recording(self):
        """停止录制"""
        self.client.send_message("/numus/record/stop", [])
```

### 4.2 Sonic Pi集成脚本

```ruby
# sonic-pi-code/numus_car_edm_engine.rb
# Numus车载EDM引擎（功能性+逻辑性模块混合）

# === 功能性模块部分（稳定） ===

# OSC消息接收器
live_loop :numus_osc_receiver do
  use_real_time
  
  # 接收初始化消息
  init_msg = sync "/osc*/numus/init"
  if init_msg
    set :current_track_id, init_msg[0]
    puts "Numus: 初始化乐曲 #{init_msg[0]}"
  end
  
  # 接收采样路径
  sample_msg = sync "/osc*/numus/sample/*"
  if sample_msg
    layer_name = get_event("/osc*/numus/sample/*").path.split("/").last
    sample_path = sample_msg[0]
    set "sample_#{layer_name}".to_sym, sample_path
    puts "Numus: 加载采样 #{layer_name} -> #{sample_path}"
  end
  
  # 接收播放控制
  play_msg = sync "/osc*/numus/play"
  if play_msg && play_msg[0] == "start"
    set :numus_playing, true
    puts "Numus: 开始播放"
  end
end

# 采样加载器
define :load_numus_samples do
  @numus_samples = {}
  
  # 加载MIDI装饰采样
  ["melody", "harmony", "ornaments"].each do |layer|
    sample_path = get("sample_#{layer}".to_sym)
    if sample_path
      @numus_samples[layer.to_sym] = sample_path
      puts "加载采样: #{layer} -> #{sample_path}"
    end
  end
end

# 车载音响路由
define :route_to_car_audio do |element_type, audio_block|
  case element_type
  when :kick, :bass
    # 低频 -> 前置 + 重低音
    with_fx :hpf, cutoff: 30 do
      with_fx :lpf, cutoff: 120 do  # 重低音频段
        audio_block.call
      end
    end
    
  when :melody, :lead
    # 旋律 -> 前置立体声
    with_fx :pan, pan: rrand(-0.3, 0.3) do
      audio_block.call
    end
    
  when :pad, :ambient
    # 氛围 -> 后置环绕
    with_fx :pan, pan: rrand(-0.8, 0.8) do
      with_fx :reverb, room: 0.6, mix: 0.4 do
        audio_block.call  
      end
    end
  end
end

# === 逻辑性模块部分（频繁迭代） ===

# 乐曲主控制器
live_loop :numus_track_master do
  sync :numus_playing
  
  track_id = get(:current_track_id)
  
  case track_id
  when "dawn_ignition"
    play_dawn_ignition_chapters
  when "urban_velocity"
    play_urban_velocity_chapters
  # ...其他乐曲
  end
end

# Dawn Ignition章节播放逻辑
define :play_dawn_ignition_chapters do
  # 章节1: Gentle Awakening
  in_thread do
    play_gentle_awakening_chapter
  end
  
  sleep 180  # 3分钟后
  
  # 程序化DJ过渡到章节2
  execute_chapter_transition("gentle_awakening", "morning_stir", "element_handoff")
  
  # 章节2: Morning Stir
  in_thread do
    play_morning_stir_chapter  
  end
  
  # ...继续其他章节
end

# 具体章节播放函数
define :play_gentle_awakening_chapter do
  puts "播放章节: Gentle Awakening"
  
  # EDM骨干层
  in_thread do
    live_loop :gentle_kick do
      route_to_car_audio :kick do
        sample :bd_mehackit, amp: 0.6
      end
      sleep 1
    end
  end
  
  in_thread do  
    live_loop :gentle_pad do
      route_to_car_audio :pad do
        use_synth :prophet
        play_chord chord(:c, :major), release: 4, amp: 0.3
      end
      sleep 4
    end
  end
  
  # MIDI装饰层
  in_thread do
    if @numus_samples[:melody]
      live_loop :gentle_melody_decoration do
        route_to_car_audio :melody do
          sample @numus_samples[:melody], 
                 rate: rrand(0.95, 1.05),
                 amp: 0.4
        end
        sleep choose([2, 4, 8])  # 随机间隔
      end
    end
  end
  
  # 章节结构控制
  sleep 32   # Intro段
  set :gentle_energy, 0.4  # Build段能量提升
  sleep 32
  set :gentle_energy, 0.8  # Drop段
  sleep 64  
  set :gentle_energy, 0.3  # Breakdown段
  sleep 32
  set :gentle_energy, 0.1  # Outro段
  sleep 20
  
  # 停止当前章节所有循环
  stop
end

# 程序化DJ过渡控制
define :execute_chapter_transition do |from_chapter, to_chapter, method|
  puts "执行过渡: #{from_chapter} -> #{to_chapter} (#{method})"
  
  case method
  when "element_handoff"
    # 元素交接过渡
    8.times do |i|
      fade_factor = 1.0 - (i / 8.0)
      intro_factor = i / 8.0
      
      # 逐渐淡出来源章节
      set "#{from_chapter}_amp".to_sym, fade_factor
      
      # 逐渐引入目标章节  
      set "#{to_chapter}_amp".to_sym, intro_factor
      
      sleep 2  # 每2拍一个步骤
    end
    
  when "filter_sweep"
    # 滤波器扫频过渡
    16.times do |i|
      cutoff_value = 8000 - (i * 400)
      set :global_filter_cutoff, cutoff_value
      sleep 0.5
    end
  end
end
```

---

## 5. 录制与输出系统

### 5.1 Sonic Pi录制控制

```ruby
# 录制控制模块（功能性模块）
define :numus_recording_controller do
  # 等待录制开始信号
  record_start = sync "/osc*/numus/record/start"
  if record_start
    output_path = record_start[0]
    puts "开始录制到: #{output_path}"
    
    # 启动Sonic Pi内置录制
    record_start
    
    # 等待录制停止信号
    sync "/osc*/numus/record/stop"
    puts "录制完成"
    
    # 停止录制
    record_stop
  end
end
```

### 5.2 Python录制管理

```python
class TrackRecordingManager:
    """乐曲录制管理器"""
    
    def __init__(self, sonic_pi_controller):
        self.controller = sonic_pi_controller
        
    def record_complete_track(self, track_dna, estimated_duration_minutes):
        """录制完整乐曲"""
        track_name = track_dna["track"]["track_id"]
        output_path = f"out/album/{track_name}.wav"
        
        print(f"开始录制乐曲: {track_name}")
        print(f"预计时长: {estimated_duration_minutes}分钟")
        
        # 启动录制
        self.controller.start_recording(output_path)
        
        # 等待乐曲播放完成
        estimated_seconds = estimated_duration_minutes * 60
        time.sleep(estimated_seconds + 30)  # 额外30秒缓冲
        
        # 停止录制
        self.controller.stop_recording()
        
        print(f"录制完成: {output_path}")
        return output_path
```

---

## 6. 完整制作工作流

### 6.1 单曲制作CLI命令

```bash
# 制作单首乐曲
python scripts/produce_track.py --track dawn_ignition --mode test
python scripts/produce_track.py --track dawn_ignition --mode record

# 参数说明:
# --track: 乐曲名称
# --mode test: 仅启动Sonic Pi播放，供测试和调试
# --mode record: 启动播放并录制为WAV文件
```

### 6.2 制作脚本实现

```python
# scripts/produce_track.py
import argparse
import time
from src.dna_config_manager import DNAConfigManager
from src.midi_decoration_generator import MIDIDecorationGenerator  
from src.sonic_pi_controller import SonicPiController
from src.track_recording_manager import TrackRecordingManager

def main():
    parser = argparse.ArgumentParser(description="Numus乐曲制作工具")
    parser.add_argument("--track", required=True, help="乐曲名称")
    parser.add_argument("--mode", choices=["test", "record"], default="test", 
                       help="制作模式：test=测试播放，record=录制WAV")
    args = parser.parse_args()
    
    print(f"=== Numus乐曲制作 ===")
    print(f"乐曲: {args.track}")
    print(f"模式: {args.mode}")
    
    # 第1步：加载DNA配置
    print("加载DNA配置...")
    config_manager = DNAConfigManager()
    track_dna = config_manager.load_track_dna(args.track)
    config_manager.validate_dna_consistency(track_dna)
    
    # 第2步：生成MIDI装饰层
    print("生成MIDI装饰层...")
    decoration_generator = MIDIDecorationGenerator()
    
    all_decorations = {}
    for chapter_dna in track_dna["chapters"]:
        chapter_decorations = decoration_generator.generate_chapter_decorations(
            chapter_dna, 
            chapter_dna["midi_decoration_spec"]
        )
        
        # 渲染为WAV
        output_dir = f"out/midi/{args.track}/{chapter_dna['chapter_id']}"
        wav_paths = decoration_generator.render_decorations_to_wav(
            chapter_decorations, output_dir
        )
        
        all_decorations[chapter_dna["chapter_id"]] = wav_paths
    
    # 第3步：启动Sonic Pi会话
    print("启动Sonic Pi会话...")
    controller = SonicPiController()
    controller.start_track_session(track_dna, all_decorations)
    
    # 第4步：根据模式执行
    if args.mode == "test":
        print("测试模式 - Sonic Pi播放中，按Ctrl+C停止")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("停止播放")
            
    elif args.mode == "record":
        print("录制模式 - 开始录制...")
        recording_manager = TrackRecordingManager(controller)
        duration_minutes = track_dna["track"]["duration_minutes"]
        
        output_wav = recording_manager.record_complete_track(
            track_dna, duration_minutes
        )
        
        print(f"录制完成: {output_wav}")

if __name__ == "__main__":
    main()
```

---

## 7. 模块稳定性设计

### 7.1 功能性模块（稳定，少变）

```python
# src/core/ - 核心功能模块，一旦稳定基本不变
├── numus_engine.py          # 数学序列生成引擎
├── midi_generator.py        # MIDI生成核心算法  
├── midi_renderer.py         # MIDI到WAV渲染
├── osc_controller.py        # OSC协议控制
├── sonic_pi_interface.py    # Sonic Pi接口封装
└── audio_utils.py           # 音频处理工具
```

```ruby
# sonic-pi-code/numus_core/ - Sonic Pi核心模块
├── osc_receiver.rb          # OSC消息接收
├── car_audio_router.rb      # 车载音响路由  
├── recording_controller.rb  # 录制控制
├── transition_engine.rb     # 过渡引擎
└── edm_synthesizers.rb      # EDM合成器库
```

### 7.2 逻辑性模块（频繁变化）

```python
# config/ - 配置文件，制作过程中频繁调整
├── albums/
│   └── motion_groove.json   # 专辑级配置
├── tracks/
│   ├── dawn_ignition.json   # 各乐曲配置
│   └── ...
└── chapters/
    ├── gentle_awakening.json # 各章节配置
    └── ...
```

```ruby
# sonic-pi-code/tracks/ - 乐曲逻辑，制作过程中频繁调整
├── dawn_ignition.rb         # Dawn Ignition播放逻辑
├── urban_velocity.rb        # Urban Velocity播放逻辑
└── ...
```

### 7.3 实验迭代策略

```python
# 实验迭代的典型工作流
class ExperimentalWorkflow:
    """支持快速实验迭代的工作流"""
    
    def iterate_chapter_dna(self, chapter_id, parameter_variations):
        """快速迭代章节DNA参数"""
        for variation in parameter_variations:
            print(f"测试变体: {variation}")
            
            # 修改DNA配置
            self.modify_chapter_dna(chapter_id, variation)
            
            # 重新生成MIDI装饰
            self.regenerate_midi_decorations(chapter_id)
            
            # 快速测试播放（仅播放该章节）
            self.test_play_chapter(chapter_id)
            
            # 用户反馈
            feedback = input("满意这个变体吗？(y/n/q): ")
            if feedback == 'y':
                self.save_chapter_dna(chapter_id)
                break
            elif feedback == 'q':
                break
    
    def a_b_test_transitions(self, chapter_a, chapter_b, transition_methods):
        """A/B测试不同的过渡方法"""
        for method in transition_methods:
            print(f"测试过渡方法: {method}")
            self.test_chapter_transition(chapter_a, chapter_b, method)
            
            rating = input(f"为{method}评分(1-10): ")
            self.record_transition_rating(chapter_a, chapter_b, method, rating)
```

---

## 8. 技术要点总结

### 8.1 核心架构特点

- **工作流澄清**：Python生成→OSC控制→Sonic Pi播放→内置录制→WAV输出
- **模块分离**：功能性模块稳定，逻辑性模块频繁迭代
- **装饰时机**：EDM骨干确定后，基于需求分析生成MIDI装饰
- **集成方式**：MIDI装饰渲染为WAV采样，Sonic Pi实时调用并合成

### 8.2 制作输出

- **单曲WAV**：通过Sonic Pi录制功能生成最终音频文件
- **中间产物**：MIDI文件（调试用）、WAV采样（Sonic Pi调用）
- **配置文件**：DNA配置的版本管理和实验记录

### 8.3 车载优化特色

- **实时合成优势**：Sonic Pi强大的实时效果处理和车载音响路由
- **分层渲染**：EDM骨干实时合成，MIDI装饰预渲染采样
- **灵活控制**：OSC协议支持实时参数调整和过渡控制

---

通过这套基于Numus架构的技术方案，《动感旅途》专辑将实现稳定的功能模块和灵活的创作迭代，既保证了系统的可靠性，又支持了快速的音乐实验和调整，为车载EDM的算法生成提供了完整的技术解决方案。
