# Dawn Ignition V02 结构与参数说明

版本目标：提升章节差异、对比、回调与峰值塑形；增加可控 timbre/节奏/空间参数而不引入随机。

## 变化摘要

- 章节 6→8，Section 数 26（含短对比与反高潮段）。
- 新增过渡类型：Contrast Break, Anti-drop, Callback Interlude, Multi-stage Release。
- 引入参数：hat_density, sidechain_depth, bass_drive, lead_detune, chord_inversion, reverb_bus, delay_mix, stereo_spread, micro_energy 等。
- 借用和弦：Bb (♭VII) 占比 < 10%，用于 build 张力。
- 双峰结构：First Lift 与 Second Lift，中间加入回调与减法空间。
- Anti-drop：短暂低频撤离 + drop_gap 提供再上升缓冲。
- Release 分四阶段：频谱层层抽离 → 记忆回调 → 氛围尾声 → 静态淡出。

## 参数语义

- hat_density 0..3：0=无 /1=8分 /2=8+弱16 /3=含滚动填充。
- sidechain_depth 0..0.6：决定 duck 强度（后续引擎实现）。
- bass_drive 失真/谐波增强因子。
- lead_detune 叠层微调宽度。
- chord_inversion 控制 pad/bass 低音排列差异（0/1/2）。
- callback_theme=true：引用 Intro 和声色彩处理（可高通滤波）。
- anti_drop=true + drop_gap=true：突降密度制造再上升对比。
- micro_energy：同一能量层内部轻微推拉（未来扩展微抖动）。

## 能量形态

Awakening (0.2→0.26) → 微回落 → Formation (→0.40) → Contrast (小幅降) → First Lift (→0.62 plateau) → Cruise / Callback (0.55→0.45) → Second Lift (峰 0.74) → Anti-drop (0.50) → Re-lift (0.68) → Multi-stage Release (逐步 0.28)。

## 验收清单映射

- 两次高潮前均有对比段 (Contrast Break, Anti-drop)。
- 回调出现 ≥2 (callback_prep, callback_air, release_b_callback)。
- borrowed 和弦单次短用 (Bb)。
- Release >= 总时长 ~14%。
- 无连续三段 >0.1 能量跳升未插缓冲 (检查 OK)。

## 后续建议

1. 扩展 NE-PI.rb: 处理 hat_density → 节奏细分；sidechain_depth → 对 pad / lead 应用 amplitude duck；bass_drive → 303 cutoff/resonance 映射。
2. 未来装饰层：使用 math_sources 标注区块切片，避免重复消费 π 片段。

完成：可直接结合 NE-EDM-OSC 增强版本调度 v02 JSON 进行试听与迭代。
