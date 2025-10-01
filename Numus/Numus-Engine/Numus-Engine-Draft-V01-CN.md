# Numus引擎设计草案 V0.1

## 引擎概述

Numus引擎是基于数学序列驱动的音乐生成系统，专注于EDM（电子舞曲）创作。引擎采用确定性算法，通过无理数序列（π、φ、e）和数学函数生成音乐元素，确保输出的可重现性和无限变化性。

---

## 核心设计原则

### 1. 确定性优先
- 使用数学常数和序列替代随机数
- 保证相同输入产生相同输出
- 支持音乐实验的重现性

### 2. 音乐性约束
- 遵循调性和和声规则
- 保持节奏的稳定性和变化的合理性
- 考虑人类听觉的音乐期待

### 3. 分层生成
- DNA层：音乐基因和模板
- 算法层：数学驱动的生成
- 输出层：MIDI和音频渲染

---

## 引擎架构

### DNA配置系统

```python
# 基础DNA结构
class MusicDNA:
    def __init__(self):
        self.scale = "major"              # 调式
        self.key = "C"                    # 调性
        self.bpm = 120                    # 速度
        self.time_signature = (4, 4)     # 拍号
        self.energy_curve = []            # 能量曲线
        self.style_tags = []              # 风格标签
        
    def get_chord_progression(self):
        """获取和弦进行"""
        return ["I", "V", "vi", "IV"]  # 经典进行
        
    def get_rhythm_pattern(self):
        """获取节奏模式"""
        return [1, 0, 0.5, 0, 1, 0, 0.5, 0]  # 4/4节拍模式
```

### 数学序列生成器

```python
class MathSequenceGenerator:
    def __init__(self):
        self.pi_digits = "31415926535897932384626433832795..."
        self.phi = 1.618033988749895
        self.e = 2.718281828459045
        
    def pi_sequence(self, length, offset=0):
        """基于π的确定性序列"""
        return [int(self.pi_digits[i + offset]) / 9.0 
                for i in range(length) 
                if i + offset < len(self.pi_digits)]
    
    def phi_evolution(self, time, frequency=1.0):
        """基于黄金比例的演进函数"""
        return math.sin(time * frequency * self.phi)
    
    def fibonacci_rhythm(self, length):
        """斐波那契节奏序列"""
        fib = [1, 1]
        while len(fib) < length:
            fib.append(fib[-1] + fib[-2])
        
        # 归一化到0-1
        max_val = max(fib)
        return [f / max_val for f in fib]
```

### 音乐元素生成器

```python
class MusicElementGenerator:
    def __init__(self, math_generator):
        self.math_gen = math_generator
        
    def generate_melody(self, dna, duration_bars=16):
        """生成旋律线"""
        scale_notes = self._get_scale_notes(dna.key, dna.scale)
        pi_seq = self.math_gen.pi_sequence(duration_bars * 4)  # 每小节4个音符
        
        melody = []
        for i, pi_val in enumerate(pi_seq):
            # 将π值映射到音阶音符
            note_index = int(pi_val * len(scale_notes))
            note = scale_notes[note_index % len(scale_notes)]
            
            # 添加时间信息
            beat_position = i % 4
            bar_number = i // 4
            
            melody.append({
                'note': note,
                'bar': bar_number,
                'beat': beat_position,
                'velocity': int(64 + pi_val * 63)  # 64-127
            })
            
        return melody
    
    def generate_harmony(self, dna, melody, duration_bars=16):
        """基于旋律生成和声"""
        chord_progression = dna.get_chord_progression()
        phi_seq = [self.math_gen.phi_evolution(i * 0.1) 
                   for i in range(duration_bars)]
        
        harmony = []
        for bar in range(duration_bars):
            # 根据φ序列选择和弦
            chord_index = int(abs(phi_seq[bar]) * len(chord_progression))
            chord_symbol = chord_progression[chord_index % len(chord_progression)]
            
            # 转换为具体音符
            chord_notes = self._chord_to_notes(chord_symbol, dna.key)
            
            harmony.append({
                'bar': bar,
                'chord': chord_symbol,
                'notes': chord_notes,
                'voicing': self._get_voicing_from_phi(phi_seq[bar])
            })
            
        return harmony
    
    def generate_rhythm(self, dna, duration_bars=16):
        """生成节奏模式"""
        base_pattern = dna.get_rhythm_pattern()
        fib_seq = self.math_gen.fibonacci_rhythm(duration_bars)
        
        rhythm = []
        for bar in range(duration_bars):
            # 基础模式 + 斐波那契变化
            pattern_variation = []
            fib_intensity = fib_seq[bar % len(fib_seq)]
            
            for beat_val in base_pattern:
                # 应用斐波那契强度变化
                varied_intensity = beat_val * (0.5 + fib_intensity * 0.5)
                pattern_variation.append(varied_intensity)
            
            rhythm.append({
                'bar': bar,
                'pattern': pattern_variation,
                'swing': self._calculate_swing(fib_intensity)
            })
            
        return rhythm
```

### MIDI输出系统

```python
class MIDIGenerator:
    def __init__(self):
        import mido
        self.mido = mido
        
    def create_midi_file(self, melody, harmony, rhythm, bpm=120):
        """创建MIDI文件"""
        mid = self.mido.MidiFile()
        
        # 创建音轨
        melody_track = self.mido.MidiTrack()
        harmony_track = self.mido.MidiTrack()
        rhythm_track = self.mido.MidiTrack()
        
        mid.tracks.extend([melody_track, harmony_track, rhythm_track])
        
        # 设置速度
        tempo = self.mido.bpm2tempo(bpm)
        melody_track.append(self.mido.MetaMessage('set_tempo', tempo=tempo))
        
        # 添加旋律
        self._add_melody_to_track(melody_track, melody, bpm)
        
        # 添加和声
        self._add_harmony_to_track(harmony_track, harmony, bpm)
        
        # 添加节奏
        self._add_rhythm_to_track(rhythm_track, rhythm, bpm)
        
        return mid
    
    def save_midi(self, midi_file, filepath):
        """保存MIDI文件"""
        midi_file.save(filepath)
        print(f"MIDI文件已保存: {filepath}")
    
    def render_to_wav(self, midi_filepath, wav_filepath, soundfont_path=None):
        """渲染MIDI为WAV"""
        import subprocess
        
        if not soundfont_path:
            soundfont_path = "assets/soundfonts/FluidR3_GM.sf2"
        
        cmd = [
            'fluidsynth',
            '-ni', soundfont_path,
            midi_filepath,
            '-F', wav_filepath,
            '-r', '44100'
        ]
        
        try:
            subprocess.run(cmd, check=True)
            print(f"WAV文件已生成: {wav_filepath}")
        except subprocess.CalledProcessError as e:
            print(f"渲染失败: {e}")
```

### OSC集成系统

```python
class OSCInterface:
    def __init__(self, host='127.0.0.1', port=4559):
        from pythonosc import udp_client
        self.client = udp_client.SimpleUDPClient(host, port)
        
    def send_track_data(self, track_name, elements):
        """发送音轨数据到Sonic Pi"""
        # 发送初始化消息
        self.client.send_message('/numus/init', [track_name])
        
        # 发送旋律数据
        if 'melody' in elements:
            for note_data in elements['melody']:
                self.client.send_message('/numus/melody', [
                    note_data['note'],
                    note_data['bar'],
                    note_data['beat'],
                    note_data['velocity']
                ])
        
        # 发送和声数据
        if 'harmony' in elements:
            for chord_data in elements['harmony']:
                self.client.send_message('/numus/harmony', [
                    chord_data['bar'],
                    *chord_data['notes']
                ])
        
        # 发送节奏数据
        if 'rhythm' in elements:
            for rhythm_data in elements['rhythm']:
                self.client.send_message('/numus/rhythm', [
                    rhythm_data['bar'],
                    *rhythm_data['pattern']
                ])
    
    def trigger_playback(self):
        """触发Sonic Pi播放"""
        self.client.send_message('/numus/play', ['start'])
    
    def stop_playback(self):
        """停止播放"""
        self.client.send_message('/numus/play', ['stop'])
```

---

## 完整生成流程

```python
class NumusEngine:
    def __init__(self):
        self.math_gen = MathSequenceGenerator()
        self.element_gen = MusicElementGenerator(self.math_gen)
        self.midi_gen = MIDIGenerator()
        self.osc_interface = OSCInterface()
        
    def generate_track(self, dna_config, duration_bars=64):
        """生成完整音轨"""
        print(f"开始生成音轨，时长: {duration_bars}小节")
        
        # 创建DNA对象
        dna = MusicDNA()
        dna.__dict__.update(dna_config)
        
        # 生成音乐元素
        melody = self.element_gen.generate_melody(dna, duration_bars)
        harmony = self.element_gen.generate_harmony(dna, melody, duration_bars)
        rhythm = self.element_gen.generate_rhythm(dna, duration_bars)
        
        # 创建MIDI文件
        midi_file = self.midi_gen.create_midi_file(
            melody, harmony, rhythm, dna.bpm
        )
        
        return {
            'dna': dna,
            'melody': melody,
            'harmony': harmony,
            'rhythm': rhythm,
            'midi': midi_file
        }
    
    def export_track(self, track_data, track_name):
        """导出音轨"""
        # 保存MIDI
        midi_path = f"out/midi/{track_name}.mid"
        self.midi_gen.save_midi(track_data['midi'], midi_path)
        
        # 渲染WAV
        wav_path = f"out/wav/{track_name}.wav"
        self.midi_gen.render_to_wav(midi_path, wav_path)
        
        # 发送到Sonic Pi（可选）
        elements = {
            'melody': track_data['melody'],
            'harmony': track_data['harmony'],
            'rhythm': track_data['rhythm']
        }
        self.osc_interface.send_track_data(track_name, elements)
        
        return {
            'midi_path': midi_path,
            'wav_path': wav_path
        }
```

---

## 使用示例

```python
# 创建引擎实例
engine = NumusEngine()

# 定义DNA配置
dawn_ignition_dna = {
    'scale': 'major',
    'key': 'C',
    'bpm': 120,
    'energy_curve': [0.2, 0.4, 0.6, 0.8, 0.9, 0.7, 0.8, 0.6],
    'style_tags': ['progressive_house', 'morning', 'uplifting']
}

# 生成音轨
track_data = engine.generate_track(dawn_ignition_dna, duration_bars=64)

# 导出文件
paths = engine.export_track(track_data, "dawn_ignition_chapter1")

print(f"生成完成:")
print(f"MIDI: {paths['midi_path']}")
print(f"WAV: {paths['wav_path']}")

# 触发Sonic Pi播放
engine.osc_interface.trigger_playback()
```

---

## 扩展性设计

### 自定义生成器

```python
class CustomMelodyGenerator:
    def __init__(self, math_generator):
        self.math_gen = math_generator
        
    def generate_pentatonic_melody(self, dna, duration_bars):
        """生成五声音阶旋律"""
        pentatonic_scale = [0, 2, 4, 7, 9]  # C大调五声音阶
        # 自定义生成逻辑
        pass
    
    def generate_modal_melody(self, dna, mode, duration_bars):
        """生成调式旋律"""
        modal_scales = {
            'dorian': [0, 2, 3, 5, 7, 9, 10],
            'mixolydian': [0, 2, 4, 5, 7, 9, 10]
        }
        # 自定义生成逻辑
        pass
```

### 效果处理链

```python
class EffectChain:
    def __init__(self):
        self.effects = []
    
    def add_humanize(self, timing_variance=0.02, velocity_variance=5):
        """添加人性化效果"""
        def humanize_effect(notes):
            for note in notes:
                # 轻微的时间偏移
                note['timing'] += random.uniform(-timing_variance, timing_variance)
                # 力度变化
                note['velocity'] += random.randint(-velocity_variance, velocity_variance)
            return notes
        
        self.effects.append(humanize_effect)
    
    def apply_to_track(self, track_data):
        """应用效果链到音轨"""
        for effect in self.effects:
            track_data = effect(track_data)
        return track_data
```

---

通过这套Numus引擎设计，可以实现基于数学原理的确定性音乐生成，同时保持足够的灵活性支持各种音乐风格和创意实验。引擎专注于算法生成的核心功能，与Sonic Pi的实时合成能力形成完美的互补。