# Cosmic EDM Evolution v3.0

P=1.618034
E=2.718281828
PI=Math::PI

MD={
  pi:"3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067",
  golden:"1618033988749894848204586834365638117720309179805762862135448622705260462818902449707207204189391137",
  e:"2718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427",
  sqrt2:"1414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641573"
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
# • cg loop:1 tick=0.25 拍 (sleep 0.25)
# • ct loop:1 tick=2 拍    (sleep 2)
# • cm loop:1 tick=4 拍    (sleep 4)
# 下面若未特别说明，“拍”指真实 musical beats，括号中给出代码触发条件。
#
# === 核心结构 ===
# 1. 量子态三层能量引擎 (qs)
#   -micro：高频扰动（快速正弦/复合余弦），驱动细粒度动态与瞬时力度起伏。
#   -macro：低频缓变包络（慢速正弦相位偏移），塑造全局能量曲线与氛围呼吸。
#   -fusion：对 micro/macro 加权混合并限幅，作为多数组件触发条件与幅度控制中心值。
#    设计要点：三个尺度耦合可在长时间聆听中避免“平铺”与“突跳”两类疲劳问题。
#
# 2. 宇宙相位与谐波音阶 (ccp+CS)
#   -相位序列：big_bang → galaxy → stellar → death → quantum 循环。
#   -每个相位映射一组有限音列（非传统功能和声）→ 旋律、和弦、低音共享同一集合不同偏移。
#   -通过 tick 时间映射 (ccp) 缓慢推进，避免每拍强制转调造成割裂。
#   -quantum 相位提供更多半音间距 → 拉高局部复杂度，作为“色彩刷新”节点。
#
# 3. 智能音色选择 (es)
#   -按音高区间 (低/中/高) 选择不同合成器池，保持频段分工与层次解析度。
#   -避免低频使用高谐波亮度音色，减少频谱拥挤；高频使用瞬态/亮色合成器提升空气感。
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
#
# 5. 多层触发框架
#   -主节奏 (cg)：最快层（0.25 拍粒度），承载打击/旋律/附加纹理调度。
#   -结构填充 (ct)：中速层（2 拍粒度），控制 pad/环境铺陈。
#   -背景/管理 (cm)：慢速层（4 拍粒度），负责长尾氛围与状态输出。
#    分离速率降低竞争，避免在同一循环内堆叠过多判定逻辑。
#
# 6. 随机性与确定性平衡
#   -核心能量曲线 (qs) 完全确定性（纯函数）。
#   -事件/采样/和弦类型与局部音高偏移改用 mr/mp（无理数序列驱动）生成，必要时辅以 rand 保持变化。
#
# 7. 线程化和声层
#   -每 32 tick (=8 拍) 启动和弦线程：顺序 3 组（每组 sustain 8 拍），与主旋律并行不阻塞节拍。
#   -通过 sleep 分段+长 release 形成“漂浮”叠加，不同相位音列在跨周期时形成模糊交叉。
#
# 8. 参数保护与适配
#   -lr 限幅：所有 cutoff/rate/mod_range/mod_rate 进入执行前归一化以防极值失控。
#   -动态滤波：依据 micro/macro/fusion 平滑映射，避免“硬跳频”。
#
# 9. 能量感知事件
#   -fusion/macro 阈值驱动：低音、粒子、pad、加倍动态等事件只在能量窗口内触发。
#   -相位提示：80 拍周期（cm 层）输出状态 → 给长时运行用户自然参照点。
#
# === 风格切换 ===
# • :edm → 128 BPM，恒定 closed hi-hat，64 拍周期前 4 拍能量提升 (t%64 < 4)。
# • :deep_house → 120 BPM，加入 compus shaker（ct 中 t%4==0 即每 8 拍）与较大混响。
#
# === 音乐层次 ===
# 节拍层 (cg):
#   -底鼓：每 1 拍 (t%4==0)；声像 pendulum。
#   -军鼓：16 tick 序列中的第 6 与 14 tick → 6,14 ⇒ 1.5 拍与 3.5 拍位置。
#   -打击细节：spread(5,16) → 16 tick（=4 拍）循环的 5 分布事件。
#   -Hi-hat：EDM 模式每 tick (0.25 拍)。
#   -能量提升：64 拍周期前 4 拍振幅加倍 (da=2)。
#
# 纹理/装饰 (pcl):
#   -harmonic：每 3 tick 触发 (≈0.75 拍) 且 fusion 强度>0.4。
#   -tremolo：32 tick pattern (spread 7,32)=8 拍循环稀疏触发。
#   -particle：ct 中每 4 拍评估一次（ct t%2==0 → 2*2 拍），高能量 (micro>0.7) 时触发。
#
# 旋律层：
#   -相位驱动选音：按当前相位音列索引推进。
#   -动态合成器选择：根据音高区块自适应 (es)。
#   -轻度失真与滤波参数随 micro/macro/fusion 波动。
#
# 和声层：
#   -和弦线程：每 32 tick (=8 拍) 启动独立线程，分 3 组和弦（每组 8 拍 sustain）。
#   -低音：每 8 tick (=2 拍) 若 fusion>0.6 补强根音下两组八度。
#
# 质感层 (ct):
#   -Pad/和声簇：每 32 ct tick (=64 拍) 条件性进入 (si>0.6)。
#   -环境采样点缀：每 16 ct tick (=32 拍) 且 fusion>0.5。
#   -Deep House shaker：ct t%4==0 → 每 8 拍。
#
# 背景层 (cm):
#   -长尾氛围：每 8 cm tick (=32 拍) 生成低频和声堆叠。
#   -相位提示：每 20 cm tick (=80 拍) 回声提示与日志输出。
#   -状态日志：每 4 cm tick (=16 拍) 打印相位与演化度。
#
# === 技术亮点 ===
# • 数学调制 (正弦/黄金比例)+随机采样混合，兼顾结构与生成性。
# • 自适应合成器：基础池 26 个音色+额外调制合成调用（>26）。
# • 参数限幅 (lr) 防止 cutoff/rate/mod 超界。
# • 多线程和弦：独立 in_thread 提升空间层次。
# • 声像轨道统一由 cp 抽象，便于扩展新轨道函数。
#
# === 使用建议 ===
# • 修改变量 s=:edm/:deep_house 切换风格。
# • 运行 ≥5 分钟体验一个以上完整长周期（含 64/80 拍事件）。
# • 立体声输出设备可最大化轨道运动感。
# • 可调试：临时开启 use_debug true 观察事件节奏。∂
#
# === 创作理念 ===
# 通过“节奏=时间分形”，“声像=轨道映射”，“能量=多尺度调制”，将抽象数学参数转译为可感知音乐演化。
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