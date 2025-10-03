import subprocess
import pretty_midi
import numpy as np
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class NumusMIDIRenderer:
    """Numus MIDI 渲染器 - 装饰采样生成"""
    
    def __init__(self, soundfont_path: str = "../SF/FluidR3_GM.sf2"):
        self.soundfont_path = Path(soundfont_path)
        self.output_dir = Path("output/wav")
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # 确认 SoundFont 文件存在
        if not self.soundfont_path.exists():
            print(f"警告: SoundFont 文件不存在 {self.soundfont_path}")
        
        print("MIDI 渲染器初始化完成")
    
    def render_ornament(self, track_name: str, chapter_name: str, 
                       ornament_data: Dict) -> Optional[str]:
        """渲染装饰音为 WAV 文件"""
        try:
            # 创建 MIDI 数据
            midi_data = self._create_ornament_midi(ornament_data)
            
            # 生成文件名
            filename_base = f"{track_name}_{chapter_name}_{ornament_data['type']}_{ornament_data['bar']}"
            midi_path = self.output_dir / f"{filename_base}.mid"
            wav_path = self.output_dir / f"{filename_base}.wav"
            
            # 保存 MIDI 文件
            midi_data.write(str(midi_path))
            
            # 渲染为 WAV
            if self._render_with_fluidsynth(midi_path, wav_path):
                # 删除临时 MIDI 文件
                midi_path.unlink()
                return str(wav_path.relative_to(Path.cwd()))
            else:
                print(f"渲染失败: {filename_base}")
                return None
                
        except Exception as e:
            print(f"渲染装饰音失败: {e}")
            return None
    
    def _create_ornament_midi(self, ornament_data: Dict) -> pretty_midi.PrettyMIDI:
        """基于装饰数据创建 MIDI"""
        midi = pretty_midi.PrettyMIDI()
        
        ornament_type = ornament_data["type"]
        intensity = ornament_data["intensity"]
        
        # 根据类型选择音色和参数
        if ornament_type == "bell":
            program = 14  # Tubular Bells
            base_note = 72  # C5
            note_range = 12
            note_count = int(2 + intensity * 4)  # 2-6个音符
            max_duration = 2.0
            
        elif ornament_type == "lead":
            program = 81  # Square Lead  
            base_note = 60  # C4
            note_range = 24
            note_count = int(4 + intensity * 8)  # 4-12个音符
            max_duration = 3.0
            
        elif ornament_type == "pad":
            program = 88  # New Age Pad
            base_note = 48  # C3
            note_range = 16
            note_count = int(1 + intensity * 3)  # 1-4个音符（和弦）
            max_duration = 4.0
            
        else:  # texture
            program = 95  # FX 5 (brightness)
            base_note = 36  # C2
            note_range = 24
            note_count = int(3 + intensity * 6)  # 3-9个音符
            max_duration = 2.5
        
        instrument = pretty_midi.Instrument(program=program)
        
        # 生成音符序列
        current_time = 0.0
        
        if ornament_type == "pad":
            # 和弦类型：同时发音
            chord_notes = self._generate_chord_notes(base_note, note_range, note_count)
            duration = max_duration * intensity
            
            for note_pitch in chord_notes:
                velocity = int(30 + intensity * 50)  # 30-80
                note = pretty_midi.Note(
                    velocity=velocity,
                    pitch=note_pitch,
                    start=current_time,
                    end=current_time + duration
                )
                instrument.notes.append(note)
        
        else:
            # 旋律类型：顺序发音
            melody_notes = self._generate_melody_notes(base_note, note_range, note_count, intensity)
            
            for i, note_pitch in enumerate(melody_notes):
                velocity = int(40 + intensity * 60)  # 40-100
                note_duration = (max_duration / note_count) * (0.7 + intensity * 0.6)
                
                note = pretty_midi.Note(
                    velocity=velocity,
                    pitch=note_pitch,
                    start=current_time,
                    end=current_time + note_duration
                )
                instrument.notes.append(note)
                
                # 计算下一个音符的开始时间
                overlap_factor = 0.1 + intensity * 0.3  # 重叠程度
                current_time += note_duration * (1 - overlap_factor)
        
        midi.instruments.append(instrument)
        return midi
    
    def _generate_chord_notes(self, base_note: int, note_range: int, note_count: int) -> List[int]:
        """生成和弦音符"""
        # 简单的三和弦 + 扩展
        intervals = [0, 4, 7, 11, 14, 17]  # 大三和弦 + 扩展音程
        
        chord_notes = []
        for i in range(min(note_count, len(intervals))):
            note = base_note + intervals[i]
            if note <= 127:  # MIDI 音符范围限制
                chord_notes.append(note)
        
        return chord_notes
    
    def _generate_melody_notes(self, base_note: int, note_range: int, 
                             note_count: int, intensity: float) -> List[int]:
        """生成旋律音符"""
        # 使用小调音阶（A minor）
        scale_intervals = [0, 2, 3, 5, 7, 8, 10]  # A minor scale intervals
        
        melody_notes = []
        
        for i in range(note_count):
            # 根据强度和位置选择音符
            scale_degree = int((i / note_count + intensity) * len(scale_intervals)) % len(scale_intervals)
            octave_offset = int((intensity + i / note_count) * (note_range / 12)) * 12
            
            note = base_note + scale_intervals[scale_degree] + octave_offset
            
            # 确保在 MIDI 范围内
            note = max(0, min(127, note))
            melody_notes.append(note)
        
        return melody_notes
    
    def _render_with_fluidsynth(self, midi_path: Path, wav_path: Path) -> bool:
        """使用 FluidSynth 渲染 MIDI 为 WAV"""
        if not self.soundfont_path.exists():
            print(f"SoundFont 文件不存在: {self.soundfont_path}")
            return False
        
        cmd = [
            "fluidsynth",
            "-ni",  # 非交互模式
            str(self.soundfont_path),
            str(midi_path),
            "-F", str(wav_path),
            "-r", "44100",  # 采样率
            "-g", "0.5"     # 增益
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0 and wav_path.exists():
                return True
            else:
                print(f"FluidSynth 错误: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print("FluidSynth 渲染超时")
            return False
        except FileNotFoundError:
            print("错误: 未找到 fluidsynth 命令，请确保已安装 FluidSynth")
            return False
    
    def batch_render_ornaments(self, ornaments_list: List[Dict], 
                             track_name: str) -> Dict[str, str]:
        """批量渲染装饰音"""
        results = {}
        
        print(f"批量渲染 {len(ornaments_list)} 个装饰音...")
        
        for i, ornament in enumerate(ornaments_list):
            chapter_name = ornament.get("chapter", f"ch_{i}")
            
            wav_path = self.render_ornament(track_name, chapter_name, ornament)
            
            if wav_path:
                ornament_key = f"{chapter_name}_{ornament['type']}_{ornament['bar']}"
                results[ornament_key] = wav_path
                print(f"  ✓ {ornament_key}")
            else:
                print(f"  ✗ 渲染失败: {ornament}")
        
        print(f"批量渲染完成，成功 {len(results)} 个")
        return results