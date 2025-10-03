import subprocess
import pretty_midi
from pathlib import Path
from typing import List, Optional, Dict

class NumusMIDIRenderer:
    """Numus MIDI 渲染器"""
    
    def __init__(self, soundfont_path: str = "SF/FluidR3_GM.sf2"):
        self.soundfont_path = Path(soundfont_path)
        self.output_dir = Path("output/wav")
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def create_ornament_midi(self, ornament_data: Dict, key: str = "Am") -> pretty_midi.PrettyMIDI:
        """基于装饰数据创建 MIDI"""
        midi = pretty_midi.PrettyMIDI()
        
        # 根据类型选择音色和音域
        if ornament_data["type"] == "bell":
            program = 14  # Tubular Bells
            base_note = 72  # C5
            note_range = 12
        elif ornament_data["type"] == "lead":
            program = 81  # Square Lead
            base_note = 60  # C4
            note_range = 24
        else:  # pad
            program = 88  # New Age Pad
            base_note = 48  # C3
            note_range = 12
        
        instrument = pretty_midi.Instrument(program=program)
        
        # 简单旋律生成
        intensity = ornament_data["intensity"]
        note_count = int(3 + intensity * 5)  # 3-8个音符
        
        current_time = 0.0
        for i in range(note_count):
            pitch = base_note + int((intensity * note_range) % note_range)
            velocity = int(40 + intensity * 40)  # 40-80
            duration = 0.25 + intensity * 0.5   # 0.25-0.75秒
            
            note = pretty_midi.Note(
                velocity=velocity,
                pitch=pitch,
                start=current_time,
                end=current_time + duration
            )
            instrument.notes.append(note)
            current_time += duration * 0.8  # 轻微重叠
        
        midi.instruments.append(instrument)
        return midi
    
    def render_ornament(self, track_name: str, chapter_name: str, 
                       ornament_data: Dict) -> Optional[str]:
        """渲染单个装饰音为 WAV"""
        # 创建 MIDI
        midi = self.create_ornament_midi(ornament_data)
        
        # 文件路径
        filename_base = f"{track_name}_{chapter_name}_{ornament_data['type']}_{ornament_data['bar']}"
        midi_path = self.output_dir / f"{filename_base}.mid"
        wav_path = self.output_dir / f"{filename_base}.wav"
        
        # 保存 MIDI
        midi.write(str(midi_path))
        
        # 渲染为 WAV
        if self._render_with_fluidsynth(midi_path, wav_path):
            midi_path.unlink()  # 删除临时 MIDI
            return str(wav_path.relative_to(Path.cwd()))
        
        return None
    
    def _render_with_fluidsynth(self, midi_path: Path, wav_path: Path) -> bool:
        """使用 FluidSynth 渲染"""
        cmd = [
            "fluidsynth", "-ni", str(self.soundfont_path),
            str(midi_path), "-F", str(wav_path), "-r", "44100"
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0 and wav_path.exists()
        except FileNotFoundError:
            print("错误: 未找到 fluidsynth 命令")
            return Falses