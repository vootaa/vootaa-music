"""
Numus V03 主引擎
提供统一的播放控制接口
"""

import json
from pathlib import Path
from typing import Optional
from CoreDataStructure import Track, Album
from SegmentLibraryManager import SegmentLibrary
from SegmentPlayer import SegmentPlayer
from TrackConductor import TrackConductor


class NumusEngine:
    """Numus主引擎"""
    
    def __init__(self, 
                 segments_path: str = "./segments",
                 osc_ip: str = "127.0.0.1",
                 osc_port: int = 4560):
        """
        初始化Numus引擎
        
        Args:
            segments_path: Segment素材库路径
            osc_ip: Sonic Pi OSC地址
            osc_port: Sonic Pi OSC端口
        """
        self.segment_library = SegmentLibrary(segments_path)
        self.segment_player = SegmentPlayer(osc_ip, osc_port)
        self.track_conductor = TrackConductor(self.segment_player, self.segment_library)
        
        print(f"Numus Engine 初始化完成")
        print(f"Segment库统计: {self.segment_library.get_statistics()}")
    
    def play_track_from_file(self, track_file: str):
        """
        从JSON文件加载并播放Track
        
        Args:
            track_file: Track配置文件路径
        """
        track = Track.load_from_file(track_file)
        self.track_conductor.play_track(track)
    
    def play_album_from_file(self, album_file: str):
        """
        从JSON文件加载并播放Album
        
        Args:
            album_file: Album配置文件路径
        """
        album = Album.load_from_file(album_file)
        
        print(f"开始播放专辑: {album.name}")
        print(f"主题: {album.theme}")
        print(f"包含 {len(album.tracks)} 场现场秀")
        
        for track_info in album.tracks:
            track_path = track_info.get("file")
            if track_path:
                self.play_track_from_file(track_path)
    
    def stop(self):
        """停止所有播放"""
        self.track_conductor.stop_track()
        self.segment_player.stop_all_segments()
    
    def get_library_stats(self) -> dict:
        """获取Segment库统计信息"""
        return self.segment_library.get_statistics()


# 命令行使用示例
if __name__ == "__main__":
    import sys
    
    engine = NumusEngine()
    
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        if file_path.endswith("_album.json"):
            engine.play_album_from_file(file_path)
        else:
            engine.play_track_from_file(file_path)
    else:
        print("用法: python NumusEngine.py <track_file.json 或 album_file.json>")