# CarDJ EDM — 实施草案（中文）

目的

- 将 CarDJ_EDM 概念转为可执行的 Numus 实施计划：以确定性算法生成短篇“章节/段落”（2–3 分钟完整单元），并用程序式 DJ 将这些段落有机衔接，针对车载多喇叭系统优化播放体验。

## 1. 高层架构

- 生成器（Python）
  - 输入：每段的 DNA（JSON/YAML）
  - 输出：./out/midi/<segment>.mid 与 ./out/midi/<segment>.meta.json
- 渲染器
  - 使用 FluidSynth / SoundFont 将 MIDI 渲染为 ./out/wav/<segment>.wav
- 段落仓库
  - 段落音频与元数据构成可排列的素材集合
- 程序 DJ 引擎（Python）
  - 播放列表组建、过渡评分、交叉淡化、喇叭映射与 EQ 自动化，输出拼接后的 master WAV 与分声道干声
- Sonic Pi（可选）
  - 载入生成的 WAV 做进一步实时 FX、摆位与 OSC 控制

## 2. 章节 / 段落概念

- 每段长度：2–3 分钟（具备完整乐曲性，便于组合）
- 每段拥有独特 DNA：id、style、tonic、bpm、energy（0–1）、timbre_profile、stereo_map、dna_seed、duration_sec
- 专辑由多个段落按能量弧线与风格关联编排，形成 20–40 分钟的长曲或更长的连续专辑

## 3. DNA 模式（示例 JSON）

- 简洁、可复现、可人工编辑
{
  "id": "dawn_001",
  "title": "Dawn Ignition - motif A",
  "style": "progressive_house",
  "tonic": "C4",
  "bpm": 118,
  "energy": 0.35,
  "timbre": "warm_pad+sub",
  "stereo_map": {"lead": 0.0, "pad": -0.2, "fx": 0.4},
  "dna_seed": {"type":"pi_digits","offset":1024},
  "duration_sec": 150
}

## 4. 确定性伪随机策略

- 优先使用无理数小数位（π、e、φ）或哈希的组合导出参数，确保可重现
- 在 metadata 中保存 dna_seed 与生成器版本
- 将数字序列映射到音高、力度、微移与效果参数的缩放函数

## 5. 段落生成流水线（实施要点）

- 建议依赖：mido、pretty_midi、numpy、pyfluidsynth（或系统 fluidsynth）
- generator.py：
  - 读取 DNA → 用确定性序列生成和弦进程与动机 → 输出 MIDI 与 meta.json → 调用 FluidSynth 渲染 WAV → 写入路径到 metadata
- metadata 字段建议：文件路径、dna、bpm、tonic、energy、peak_db、loudness_estimate、speaker_map

## 6. 程序 DJ：播放顺序与过渡设计

- 输入：段落列表及其 energy、style、key、speaker_map 等
- 目标：构建符合总体能量弧线且音乐上连贯的播放序列
- 过渡评分策略（示例启发式）：
  - 调性兼容性加分（同调/关系调）
  - 能量差异惩罚（限制 Δenergy）
  - 风格亲和度加分
  - BPM 兼容（允许 ±4% tempo warp）
- 过渡操作：
  - 小节对齐的交叉淡入淡出（4–16 小节）
  - 低频在淡入/淡出时自动衰减以避免低频叠加
  - 滤波/混响自动化用于“胶合”段落

## 7. 拼接与渲染细节

- 每次过渡计算淡化长度（以小节为单位）并转换为秒数
- 使用窗函数（余弦或线性）避免点击
- 在过渡期间应用每段的 EQ 与多喇叭增益变换
- 输出为主 WAV 以及可选的喇叭分组干声（便于后期微调）

## 8. 车载多喇叭考量

- 常见通道：Front L / Front R / Rear L / Rear R / Sub
- 映射策略：
  - kick/sub → Sub；lead/pad → Front；ambience → Rear
  - 使用 stereo_map 来控制 panning 与分布的自动化
  - 对车内动态范围进行适度压缩与多段控制，确保路噪下的可听度
- 实际 DSP 建议：
  - Sub 通道 20–80Hz 低架提升并做限幅管理
  - 前置保留 200Hz–2kHz 的清晰度
  - 前置 4–16kHz 适度提升以补偿车内高频损失

## 9. Sonic Pi 集成（实践要点）

- 在 Sonic Pi 脚本顶部定义样本路径，例如：
  synth_seg = "./out/wav/dawn_001.wav"
- 使用 sample 时控制 amp、pan，实现近似多喇叭的 stereo 效果（立体声模拟/重复分层）
- 可选：通过 OSC 将程序 DJ 的参数（节拍对齐、过渡触发）传入 Sonic Pi 做实时渲染与录音

## 10. 测试与可复现性

- 每次生成写入 meta.json，含 dna_seed、generator 版本、时间戳
- 添加 smoke-tests：确保 .mid、.wav、.meta.json 存在且时长在容差范围内
- 建议在 tests/ 下放小脚本验证基础流程

## 11. 最小文件布局（建议）

- vootaa-music/
  - Numus/
    - generators/
      - generator_template.py
    - utils/
      - render_wav.py
    - README.md
  - out/
    - midi/
    - wav/
  - sonic-pi/
    - cardj_playback.rb
  - tests/
    - smoke_generation.py

## 12. 实用建议（简要）

- 段落短小（2–3 分钟）便于重组与避免循环感
- 交叉淡化必须节拍对齐：bar_sec = 60 / bpm * beats_per_bar
- 输出最终合成时目标响度可采用 EBU R128 或目标 LUFS
- 小的 meta 文件便于 A/B 测试与人工策划播放列表

附录 — 过渡约束（简洁）

- 最大 Δenergy：0.4（软上限）
- 交叉淡化：8–16 小节（能量保持），2–4 小节（快速切换）
- 调性兼容：同调 +1.0；关系调 +0.6；远离调罚分
- 允许 tempo warp ±4% 以实现顺滑混合

结束语

- 该中文草案将 CarDJ 概念与 Numus 的确定性生成流水线结合，强调短段落的可组合性、车载多喇叭优化与程序化 DJ 的实现要点，便于下一步编码实现与参数调优。
