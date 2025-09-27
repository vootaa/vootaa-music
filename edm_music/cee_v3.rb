# Cosmic EDM Evolution v3.0

P=1.618034
E=2.718281828
PI=Math::PI

MD={
  pi:"314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196",
  golden:"161803398874989484820458683436563811772030917980576286213544862270526046281890244970720720418939113748475408807538689175212663428754440643745123718192179998391015919561814675142691239748940901224953430",
  e:"271828182845904523536028747135266249775724709369999595749669676277240766303535475945713821785251664272427466391932003059921817413596629043572900334295260595630738132328627943490763233829880753195251019",
  sqrt2:"141421356237309504880168872420969807856967187537694807317667973799073247846210703885038753432764157273501384623091229702492483605598507372126441214970999358314132226659275055927557999505011527820605714"
}.freeze

CS={
  big_bang:[:c5,:d5,:f5,:g5],
  galaxy:[:c4,:e4,:g4,:bb4,:d5],
  stellar:[:c4,:d4,:f4,:g4,:a4],
  death:[:c4,:eb4,:gb4,:a4],
  quantum:[:c4,:db4,:e4,:fs4,:ab4]
}.freeze

SC_PROF={
  tb303:{amp:0.9,res:0.85,cut:0.9,atk:0.9,rel:0.8},
  supersaw:{amp:0.85,cut:1.15,atk:1.1,rel:1.1},
  blade:{amp:0.95,cut:1.1,mod:1.1},
  zawa:{amp:0.9,cut:1.05},
  prophet:{amp:1.0,atk:1.15,rel:1.2,cut:0.95},
  hollow:{amp:1.05,atk:1.2,rel:1.25},
  pretty_bell:{amp:1.1,atk:0.4,rel:0.5,cut:1.2},
  sine:{amp:1.2,cut:0.8}
}.freeze

EP=[:big_bang,:galaxy,:stellar,:death,:quantum].ring

S_FX=[:perc_bell,:perc_snap,:elec_tick,:elec_blip2,:elec_ping,:elec_pop,:drum_cowbell,:vinyl_hiss]
S_FX_HI=[:perc_bell,:elec_ping]
S_FX2=[:ambi_choir,:ambi_glass_rub,:ambi_glass_hum,:ambi_drone,:ambi_dark_woosh,:ambi_swoosh,:ambi_lunar_land,:guit_e_slide,:guit_em9,:vinyl_backspin,:drum_roll]
S_FXT=[:drum_splash_soft,:drum_splash_hard,:vinyl_scratch,:vinyl_backspin,:ambi_swoosh]

S_SYN=[:mod_saw,:mod_pulse,:mod_sine,:mod_tri,:pluck,:fm]
S_SYN2=[:prophet,:blade,:supersaw,:zawa,:pulse]
S_SYN3=[:pretty_bell,:beep,:chiplead,:chipbass,:pluck,:mod_beep]
S_SYN4=[:tb303,:subpulse,:fm,:sine,:growl,:dsaw]
S_SYN5=[:hollow,:prophet,:saw,:dark_ambience,:supersaw,:blade]

S_CHD=[:minor7,:major7,:sus4,:add9,:dim7,:minor,:major,:dom7]
S_AMB=[:hollow,:prophet,:saw]
S_PAN=[:spiral,:orbit,:galaxy,:figure8,:random]
S_PAN2=[:spiral,:figure8,:wave]

PH_LEAD={
  big_bang:[:prophet,:pulse,:blade],
  galaxy: [:prophet,:blade,:zawa],
  stellar:[:blade,:supersaw,:pulse],
  death:  [:prophet,:zawa],
  quantum:[:blade,:supersaw,:zawa,:pulse]
}

PH_FILTER={
  death:  ->(pool){pool - [:supersaw]},
  quantum: ->(pool){(pool + [:blade,:zawa]).uniq}
}.freeze

# 主题动机（与相位集合作为索引位移）
MOTIF=[0,2,4,7].freeze

# === 系统功能说明 ===
# Cosmic EDM Evolution v3 - 无理数序列驱动版 功能概览
#
# 时间单位说明：
# • cg loop:1 tick=0.25 拍 (sleep 0.25) —— 主节奏/旋律/FX/和弦触发骨干
# • ct loop:1 tick=2 拍    (sleep 2)    —— 质感 / 粒子 / Pad / 环境层
# • cm loop:1 tick=4 拍    (sleep 4)    —— 氛围长尾 / 阈值日志 / 相位提示
# “拍”指真实 musical beats，除特别说明外。
#
# === 核心结构 ===
# 1. 量子态三层能量引擎 (qs)
#   - micro (m)：快速正弦/复合余弦扰动 → 细粒度瞬时动态与选音/调制轻微摇摆。
#   - macro (ma)：慢周期包络 → 全局能量呼吸；驱动力度放大量 (da) 的三段式阈值判断。
#   - fusion (f)：micro*0.6 + macro*0.4 后限幅到 [0.1,0.9]；作为多数事件触发/幅度主参考。
#   三尺度耦合：避免纯随机的“纹理疲劳”与单频调制的“规律厌倦”。
#
# 2. 宇宙相位与谐波音阶 (phs + CS)
#   - 相位 EP 循环：big_bang → galaxy → stellar → death → quantum。
#   - 每相位指派一组有限音列 (CS)：旋律 / 和弦 / 低音 共用集合但索引与八度策略不同。
#   - quantum 提供更多半音位差 → 周期性色彩刷新。
#
# 3. 智能音色选择 (es)
#   - 根据当前音高自动归类角色(:bass/:arp/:lead/:accent/:pad)选不同合成器池 (S_SYNx)。
#   - 相位过滤/附加 (PH_LEAD / PH_FILTER) 限制或扩展音色范围。
#   - SC_PROF 注入针对合成器的包络/幅度/滤波比例 (存入 :f_amp/:f_atk/:f_rel/:f_cut)。
#
# 4. 立体声轨道/空间映射 (cp)
#   -spiral：φ(黄金比例) 调制+双正弦交叉 → 平滑旋转感。
#   -orbit：单频正弦 → 规则椭圆式左右摆动。
#   -pendulum：双频乘积 → 次慢调制上叠快速摆动。
#   -galaxy：半径随慢速正弦波动，旋转幅度动态呼吸。
#   -figure8：正交频率组合生成“∞”式运动。
#   -wave：幅值叠加波包 → 类潮汐起伏。
#   -random：无理数数字序列驱动的伪随机定位（粒子/瞬态用），兼顾稀疏扩散与可复现性。
#    空间策略：长期声像轨迹=结构；短期随机=纹理空气度。
#    pj：对 pan 做无理数序列驱动微扰并硬限幅 [-1,1]。
#    不同层（低频、旋律、FX、粒子）使用差异轨道宽度，形成深度错位。
#
# 5. 多层触发框架
#   - cg：高速节拍层（0.25 拍粒度）→ 鼓 / 主旋律 / FX 点采样 / 和弦线程调度。
#   - ct：中速结构层（2 拍）→ Pad 根簇、粒子判定、环境扩展。
#   - cm：慢速背景层（4 拍）→ 长尾氛围、相位/演化度日志、远程提示。
#
# 6. 随机性与确定性平衡
#   -核心能量曲线 (qs) 完全确定性（纯函数）。
#   -事件/音色/和弦类型/音高偏移使用无理数数字串索引 (mr/mp) → 可复现伪随机。
#   -局部空间与装饰通过 pj + spread + motif 偏移增加“似随机”变化。
#
# 7. 线程化和声层
#   - 每 32 cg tick (=8 拍) 启动一个 in_thread：顺序输出 3 组和弦，每组持续 8 拍（总 24 拍跨期漂移）。
#   - plr 对同一和弦拆分：root 下八度 / 主体 / 高音点缀(+12 可选) 各有独立包络与 cutoff。
#
# 8. 参数保护与适配
#   - lr：所有 cutoff / rate / mod_range / mod_rate / pan 抖动结果执行前限幅。
#   - 合成器配置通过 SC_PROF 归一化后再叠加能量调制，防止极值噪声。
#
# 9. 能量感知事件与逻辑扩展
#   - 动态放大量 da：ma>0.65 → 2；ma<0.35 → 0.85；其余 1。替代 V2 固定“64拍前4拍”规则。
#   - 静音窗口 sw?：512 cg tick 周期中 [256,272) 抑制 lead（:mute_lead），粒子阈值放宽并提升 pad 叠加力度。
#   - fusion 与 macro 阈值联合作为 Bass / FX / 粒子 / Pad 触发条件，减少无效堆叠。
#
# === 风格切换 ===
# • :edm → 128 BPM；高速 closed hi-hat（每 cg tick），受侧链函数 sf 影响产生呼吸感。
# • :deep_house → 120 BPM；关闭快速 hat；加入 compus shaker（ct t%4==0 → 每 8 拍）与更宽混响。
#
# === 音乐层次 ===
# 节拍层 (cg):
#   - 底鼓：t%4==0 每 1 拍；记录时间戳供 sf 计算瞬态压缩。
#   - 军鼓：16 tick 循环中 positions 6 & 14（=1.5 / 3.5 拍）。
#   - FX 触发：f>=0.4 启动普通池；f>0.7 改用高能池且触发 pattern 更稀疏 (spread(3,16) vs spread(5,16))。
#   - Hi-hat (仅 EDM)：固定速率 + sf 侧链衰减。
#   - 旋律：t%2==0 且 m>0.5 进入；前 8 tick (t%64<8) 叠加 MOTIF 偏移强化相位开头纹理。
#
# 装饰 (pl):
#   - harmonic：每偶数 tick 再判 t%3==0 且 f>0.4；附带 mod_range / mod_rate 能量映射。
#   - tremolo：spread(7,32) 稀疏分布；phase 与 mix 由能量比例归一。
#   - particle：在 ct 层（见下）调用；阈值窗口随是否静音领奏变化。
#
# Bass:
#   - 条件：t%8==0 且 f>0.6。
#   - 跳跃：每 4 次 (bc%4==0) 先上行 +12 八度后 glide 回主根。
#   - passing tone：中段 (bc%8==4) 插值 +7 半音后短延迟回落。
#
# 和声层 (plr):
#   - Root 下沉 12 半音构建低频基座；主体保持原位；顶层可能 +12 点缀。
#   - 三层包络/滤波差异 + pan 抖动 (pj) 控制立体透明度。
#
# 质感层 (ct):
#   - 粒子事件：每 ct tick 判断；能量 i 进入窗口：
#       正常：i∈(0.72,0.90)；静音窗口：i∈(0.68,0.92)。
#   - 根音 Pad：每 32 ct tick (≈64 拍) 评估；fusion 子采样 si>0.6 时生成；room 参数随风格变化。
#   - 环境 FX：f>0.5 且 t%16==0（ct 语境下即每 32 拍）触发随机氛围采样。
#
# 背景层 (cm):
#   - 长尾和声簇：t%8==0 (32 拍) 根据 fusion/macro 低频填底。
#   - 回声提示：t%20==0 (=80 拍) 触发相位音列回声扫描。
#   - 演化度日志：t%16==0 (=64 拍) 输出当前相位与 macro 演化百分比（V2 注释曾误写 16 拍）。
#
# === 技术亮点 ===
# • 多尺度确定性（qs）+ 无理数序列伪随机（mr/mp）混合。
# • 侧链函数 sf 基于真实事件时间差而非固定 LFO。
# • 静音窗口 sw? 引导层间让位，提升长时聆听波形起伏。
# • 分层和弦 voicing + 独立包络防止频谱掩蔽。
# • 全局限幅 lr 与 pan 抖动安全夹紧，减少运行时错误。
#
# === 使用建议 ===
# • s=:edm / :deep_house 切换风格后重跑主文件。
# • 观察长周期（≥5 分钟）体验静音窗口、80/64 拍级事件与相位轮换。
# • 调试：暂时 use_debug true 或打印 f/m 值分析能量映射。
# • 可通过调整 sw? 窗口长度/阈值 (ma 分段) 获得更激进或平缓的宏观起伏。
# • 立体声输出设备可最大化轨道运动感。
#
# === 创作理念 ===
# 通过“节奏=时间分形”，“空间=轨道映射”，“能量=多尺度分层”，将抽象数学参数转译为可感知音乐演化。
# 设计重点：
# • 可持续聆听：缓慢宏观周期+快速微观扰动避免疲劳。
# • 结构透明：核心函数 cp/qs/lr/es 清晰分层，便于学术或二次开发。
# • 渐进演化：避免突兀转场，采用阈值+限幅平滑过渡。
#
# === 适用场景 ===
# • 算法音乐展示：解析生成策略或课堂演示。
# • Ambient/Game 背景：长时运行无固定终止。
# • 创作灵感底床：循环输出上叠人工旋律或鼓轨。
# • 即兴演出：实时修改 s、替换 CS、调整频率常数快速得到变体。
# • 研究实验：可插入日志/可视化 tick→能量映射做多尺度分析。