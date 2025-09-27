# Cosmic EDM Evolution v2.0

s=:edm
bpm=s==:edm ? 128 :120
use_bpm bpm
set_volume! 0.8
use_debug false
P=1.618034
E=2.718281828
PI=Math::PI
MD={
  pi:"3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067",
  golden:"1618033988749894848204586834365638117720309179805762862135448622705260462818902449707207204189391137",
  e:"2718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427",
  sqrt2:"1414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641573"
}.freeze
@dc=Hash.new(0)
define :mr do |a=0.0,b=1.0,c=:pi,adv=1|
  d=MD[c] || MD[:pi]
  l=[d.length-1,1].max
  i=@dc[c]%l
  s=d[i,2] || d[i]
  v=s.to_i
  sc=(10**s.length)-1
  @dc[c]=(@dc[c]+adv)%l
  a+(v/sc.to_f)*(b-a)
end
define :mp do |list,c=:pi,adv=1|
  arr=list.respond_to?(:to_a) ? list.to_a : Array(list)
  return arr.first if arr.empty?
  arr[mr(0,arr.length,c,adv).to_i%arr.length]
end
CS={
  big_bang:[:c5,:d5,:f5,:g5],
  galaxy:[:c4,:e4,:g4,:bb4,:d5],
  stellar:[:c4,:d4,:f4,:g4,:a4],
  death:[:c4,:eb4,:gb4,:a4],
  quantum:[:c4,:db4,:e4,:fs4,:ab4]
}.freeze
EP=[:big_bang,:galaxy,:stellar,:death,:quantum].ring
S_FX=[:perc_bell,:perc_snap,:elec_tick,:elec_blip2,:elec_ping,:elec_pop,:drum_cowbell,:vinyl_hiss]
S_FX2=[:ambi_choir,:ambi_glass_rub,:ambi_glass_hum,:ambi_drone,:ambi_dark_woosh,:ambi_swoosh,:ambi_lunar_land,:guit_e_slide,:guit_em9,:vinyl_backspin,:drum_roll]
S_FX_TRANS=[:drum_splash_soft,:drum_splash_hard,:vinyl_scratch,:vinyl_backspin,:ambi_swoosh]
S_SYN=[:mod_saw,:mod_pulse,:mod_sine,:mod_tri,:pluck,:fm]
S_SYN2=[:prophet,:blade,:supersaw,:zawa,:pulse]
S_SYN3=[:pretty_bell,:beep,:chiplead,:chipbass,:pluck,:mod_beep]
S_SYN4=[:tb303,:subpulse,:fm,:sine,:growl,:dsaw]
S_SYN5=[:hollow,:prophet,:saw,:dark_ambience,:supersaw,:blade]
S_CHD=[:minor7,:major7,:sus4,:add9,:dim7,:minor,:major,:dom7]
S_AMB=[:hollow,:prophet,:saw]
S_PAN=[:spiral,:orbit,:galaxy,:figure8,:random]
S_PAN2=[:spiral,:figure8,:wave]
PH_LEAD={big_bang:[:prophet,:pulse,:blade],galaxy:[:prophet,:blade,:zawa],stellar:[:blade,:supersaw,:pulse],death:[:prophet,:zawa],quantum:[:blade,:supersaw,:zawa,:pulse]}
define :cp do |t,type=:spiral|
  case type
  when :spiral
    Math.sin(t*P*0.08)*Math.cos(t*0.05)*0.8
  when :orbit
    Math.sin(t*0.12)*0.7
  when :pendulum
    Math.sin(t*0.15)*Math.cos(t*0.03)*0.6
  when :galaxy
    r=0.6+Math.sin(t*0.02)*0.2
    Math.sin(t*0.1)*r
  when :figure8
    Math.sin(t*0.08)*Math.cos(t*0.16)*0.9
  when :wave
    Math.sin(t*0.06)*(0.5+Math.sin(t*0.02)*0.3)
  when :random
    mr(-0.8,0.8,:sqrt2)
  end
end
define :qs do |t,l|
  case l
  when :micro
    b=t*P*0.1
    q=(Math.sin(b)*Math.log(E)+Math.cos(b*2))*0.3
    c=(Math.sin(b*3.14159)+Math.cos(b*1.414))*0.2
    (q+c).abs*0.5+0.3
  when :macro
    ct=t*0.0618
    d=Math.sin(ct*0.73)*0.4
    m=Math.cos(ct*0.27+PI/3)*0.3
    (d+m)*0.5+0.5
  when :fusion
    mi=qs(t,:micro)*0.6
    ma=qs(t,:macro)*0.4
    [[mi+ma,0.9].min,0.1].max
  end
end
define :lr do |v,min,max|
  [[v,max].min,min].max
end
define :es do |i,nm,role=:auto,e=nil|
  e||=i; p=note(nm)
  role=(p<48 ? :bass : p<60 ? :arp : p<72 ? :lead : :accent) if role==:auto
  pools={bass:S_SYN4,lead:S_SYN2,arp:S_SYN,accent:S_SYN3,pad:S_SYN5}
  pool=pools[role]||S_SYN2
  if role==:lead && defined?($ph)
    ap=PH_LEAD[$ph]||[]
    fp=pool & ap
    pool=fp unless fp.empty?
  end
  idx=((i*pool.length)+( (e||i)*0.37*pool.length)).to_i%pool.length
  sc=pool[idx]; use_synth sc; sc
end
define :phase do |t|
  EP[((t*0.01)%EP.length).to_i]
end
define :cs do |p|
  CS[p] || CS[:stellar]
end
define :pl do |kind,t,i,pn|
  case kind
  when :harmonic
    return unless t%3==0 && i>0.4
    n=pn[t%pn.length]+12
    ln=get(:lead_note); n+=5 if ln && note(ln)==note(n)
    es(i,n,:accent,i)
    play n,amp:i*0.3,mod_range:lr(i*12,0,24),mod_rate:lr(i*8,0.1,16),
         attack:0.1,release:1.5,pan:cp(t,:figure8)
  when :tremolo
    return unless spread(7,32)[t%32]
    n=mp(pn,:e)+mp([0,7],:golden)
    es(i,n,:arp,i)
    with_fx :tremolo,phase:lr(i*2,0.1,4),mix:lr(i*0.8,0,1) do
      play n,amp:i*0.4,cutoff:lr(60+i*40,20,130),release:0.8,pan:cp(t,:wave)
    end
  when :particle
    return unless i>0.72 && i<0.9
    n=mp(pn,:golden)+mp([12,24,36],:e)
    es(i,n,:accent,i)
    with_fx :reverb,room:0.4,mix:0.3 do
      play n,amp:i*0.2,attack:0.05,release:0.3,
           cutoff:lr(80+i*30,50,130),pan:cp(t+mr(0,16,:pi),mp(S_PAN2,:golden))+mr(-0.1,0.1,:e)
    end
  end
end

live_loop :cg do
  t=tick
  m=qs(t*0.25,:micro); ma=qs(t*0.125,:macro); f=qs(t*0.0625,:fusion)
  ph=phase(t); $ph=ph
  pn=cs(ph)
  prev_m=get(:m_old)||m; set :m_old,m
  sample :bd_haus,amp:m,rate:lr(1+(m-0.5)*0.1,0.5,2.0),
         lpf:lr(80+ma*40,20,130),pan:cp(t,:pendulum)*0.3 if t%4==0
  set :bd_last,t if t%4==0
  if [6,14].include?(t%16)
    sample :sn_dub,amp:ma*0.8,pan:cp(t,:orbit),hpf:lr(20+m*80,0,118)
  end
  if f>0.4 && spread(5,16)[t%16]
    fx_pool = f>0.7 ? [:perc_bell,:elec_tick,:elec_ping] :S_FX
    sample mp(fx_pool,:pi),amp:f*0.4,rate:lr(0.8+m*0.4,0.25,4.0),
           pan:cp(t+mr(0,8,:golden),:spiral)
  end
  if s==:edm
    sample :drum_cymbal_closed,amp:0.2,pan:cp(t,:random)
    da=t%64 < 4 ? 2 :1
  else
    da=1
  end
  if t%2==0 && m>0.5
    ni=((t*f*5)+(m*8)).to_i%pn.length
    tn=pn[ni]; rising=(m>0.55 && prev_m<m)
    es(m,tn,:lead,f); set :lead_note,tn; set :lead_last,t
    with_fx :distortion,distort:0.1 do
      with_fx :pitch_shift,pitch:(rising ? 0.3 :0) do
        play tn,amp:m*0.7*da,cutoff:lr(40+ma*80,0,130),
             res:lr(f*0.8,0,1),attack:lr((1-m)*0.3,0,4),
             release:lr(0.2+f*0.5,0.1,8),pan:cp(t,:galaxy)
      end
    end
  end
  pl(:harmonic,t,f,pn) if t%2==0
  pl(:tremolo,t,ma,pn) if t%4==0
  if t%32==0
    in_thread do
      3.times do |i|
        es(f,pn[i%pn.length],:pad,f)
        lead_recent=( (get(:lead_last)||-99) > t-2 )
        bd_recent=( (get(:bd_last)||-99) > t-2 )
        pad_amp=f*0.2*da*(lead_recent ? 0.7 :1)
        cut_base=f<0.5 ? lr(50+m*20,20,110) :lr(80+m*30,40,130)
        with_fx(:compressor,threshold:0.3,clamp_time:0.01,relax_time:0.15) do
          play_chord chord(pn[i%pn.length],mp(S_CHD,:golden)),
               amp:pad_amp*(bd_recent ? 0.85 :1),
               attack:lr(1.5+i*0.5,0,4),
               release:lr(6+ma*3,1,12),
               cutoff:cut_base,
               pan:cp(t+i*16,mp(S_PAN,:pi))
        end
        sleep 8
      end
    end
  end
  if t%8==0 && f>0.6
    bc=(get(:bass_cnt)||0)+1; set :bass_cnt,bc
    base=note(pn[0])-24
    jump=(bc%4==0); n=base+(jump ? 12 :0)
    sc=es(ma,n,:bass,f)
    bn=synth sc,
      note:n,
      amp:ma*0.6*da,
      attack:0.1,
      sustain:(jump ? 1.0 :1.6),
      release:0,
      note_slide:0.25,
      cutoff:lr(60+m*20,20,130),
      pan:cp(t,:pendulum)*0.4
    control bn, note:base if jump
  end
  if t%64==60
    sample mp(S_FX_TRANS,:golden),amp:f*0.35,rate:lr(0.8+f*0.4,0.5,1.5),pan:cp(t,:wave)
  end
  if t%128==124
    sample mp(S_FX_TRANS,:pi),amp:f*0.45,rate:lr(0.6+f*0.5,0.4,1.4),pan:cp(t*0.5,:galaxy)
  end
  if t%256==200
    sample :ambi_swoosh,amp:f*0.4,rate:lr(0.7+f*0.3,0.5,1.3),pan:cp(t,:orbit)
  end
  if t%256==252
    sample :vinyl_backspin,amp:f*0.5,rate:lr(0.8+f*0.2,0.6,1.4),pan:cp(t,:figure8)
  end
  sleep 0.25
end

live_loop :ct,sync::cg do
  t=tick
  f=qs(t*0.0625,:fusion)
  ph=phase(t*2)
  pn=cs(ph)
  pl(:particle,t*2,qs(t*0.125,:micro),pn) if t%2==0
  if t%32==0
    si=qs(t*0.015625,:fusion)
    if si>0.6
      use_synth mp(S_AMB,:golden)
      sc=pn.take(3).map { |n| n-12 }
      with_fx :reverb,room:s==:deep_house ? 0.8 :0.6,mix:0.5 do
        with_fx :lpf,cutoff:lr(70+si*30,40,120) do
          play sc,amp:si*0.25,attack:2,release:6,pan:cp(t*8,:wave)*0.7
        end
      end
    end
  end
  sample :loop_compus,amp:0.3,beat_stretch:4 if s==:deep_house && t%4==0
  if t%16==0 && f>0.5
    sample mp(S_FX2,:e),amp:f*0.3,
           rate:lr(0.5+f*0.5,0.25,2.0),
           pan:cp(t*4,:random)
  end
  sleep 2
end

live_loop :cm,sync::cg do
  t=tick
  ph=phase(t*4)
  pn=cs(ph)
  if t%8==0
    use_synth :dark_ambience
    ai=qs(t*0.125,:fusion)
    play pn.map { |n| note(n)-36 }.take(3),
         amp:ai*0.15,attack:8,release:16,
         cutoff:lr(40+ai*20,20,130),
         pan:cp(t*4,:galaxy)*0.6
  end
  if t%20==0 && t>0
    use_synth :prophet
    with_fx :reverb,room:0.8,mix:0.6 do
      with_fx :echo,phase:0.375,decay:2 do
        pn.each_with_index do |nv,i|
          at i*0.2 do
            play nv+12,amp:0.3,attack:0.5,release:2,cutoff:90,
                 pan:cp(t*4+i*4,:spiral)
          end
        end
      end
    end
    puts "相位提示:#{ph.to_s.upcase}"
  end
  if t%16==0 && t>0
    ge=qs(t*0.0625,:macro)
    puts "#{ph.to_s.upcase} | 演化度:#{(ge*100).to_i}%"
  end
  sleep 4
end

puts "=== Cosmic EDM Evolution v2.0 启动 ==="
puts "7种立体声轨道 | 25音色 | 宇宙谐波音阶"
puts "COSMIC演化引擎运行中 | 风格:#{s.to_s.upcase}"

# === 系统功能说明 ===
# Cosmic EDM Evolution v2-无理数序列驱动版 功能概览
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
# • 可调试：临时开启 use_debug true 观察事件节奏。
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