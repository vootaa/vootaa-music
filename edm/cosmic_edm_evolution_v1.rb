# Cosmic EDM Evolution v1.0

s = :edm
bpm = s == :edm ? 128 : 120
use_bpm bpm
set_volume! 0.8
use_debug false
P = 1.618034
E = 2.718281828
PI = Math::PI
CS = { big_bang: [:c5, :d5, :f5, :g5], galaxy: [:c4, :e4, :g4, :bb4, :d5], stellar: [:c4, :d4, :f4, :g4, :a4], death: [:c4, :eb4, :gb4, :a4], quantum: [:c4, :db4, :e4, :fs4, :ab4] }.freeze
EP = [:big_bang, :galaxy, :stellar, :death, :quantum].ring
define :cp do |t, type = :spiral|
  case type
  when :spiral
    Math.sin(t * P * 0.08) * Math.cos(t * 0.05) * 0.8
  when :orbit
    Math.sin(t * 0.12) * 0.7
  when :pendulum
    Math.sin(t * 0.15) * Math.cos(t * 0.03) * 0.6
  when :galaxy
    r = 0.6 + Math.sin(t * 0.02) * 0.2
    Math.sin(t * 0.1) * r
  when :figure8
    Math.sin(t * 0.08) * Math.cos(t * 0.16) * 0.9
  when :wave
    Math.sin(t * 0.06) * (0.5 + Math.sin(t * 0.02) * 0.3)
  when :random
    rand(-0.8..0.8)
  end
end
define :qs do |t, l|
  case l
  when :micro
    b = t * P * 0.1
    q = (Math.sin(b) * Math.log(E) + Math.cos(b * 2)) * 0.3
    c = (Math.sin(b * 3.14159) + Math.cos(b * 1.414)) * 0.2
    (q + c).abs * 0.5 + 0.3
  when :macro
    ct = t * 0.0618
    d = Math.sin(ct * 0.73) * 0.4
    m = Math.cos(ct * 0.27 + PI / 3) * 0.3
    (d + m) * 0.5 + 0.5
  when :fusion
    mi = qs(t, :micro) * 0.6
    ma = qs(t, :macro) * 0.4
    [[mi + ma, 0.9].min, 0.1].max
  end
end
define :lr do |v, min, max|
  [[v, max].min, min].max
end
define :es do |i, nm|
  fc = nm > 72 ? :high : (nm > 60 ? :mid : :low)
  sp = { low: [:fm, :sine, :tb303, :subpulse, :dsaw, :dtri, :dpulse, :tri, :growl], mid: [:saw, :prophet, :zawa, :blade, :pulse, :supersaw, :mod_saw, :noise], high: [:hollow, :pretty_bell, :chiplead, :chipbass, :beep, :mod_beep, :pluck, :pnoise] }
  sc = sp[fc][(i * 9).to_i % 9]
  use_synth sc
  sc
end
define :ccp do |t|
  EP[((t * 0.01) % EP.length).to_i]
end
define :csn do |p|
  CS[p] || CS[:stellar]
end
define :pcl do |lt, t, i, pn|
  case lt
  when :harmonic
    return unless t % 3 == 0 && i > 0.4
    use_synth [:mod_sine, :mod_saw, :mod_pulse, :mod_tri].choose
    play pn[(t % pn.length)] + 12, amp: i * 0.3, mod_range: lr(i * 12, 0, 24), mod_rate: lr(i * 8, 0.1, 16), attack: 0.1, release: 1.5, pan: cp(t, :figure8)
  when :tremolo
    return unless spread(7, 32)[t % 32]
    use_synth [:prophet, :zawa, :hollow, :pluck].choose
    with_fx :tremolo, phase: lr(i * 2, 0.1, 4), mix: lr(i * 0.8, 0, 1) do
      play pn.sample + (rand(2) == 0 ? 0 : 7), amp: i * 0.4, cutoff: lr(60 + i * 40, 20, 130), release: 0.8, pan: cp(t, :wave)
    end
  when :particle
    return unless i > 0.7
    use_synth [:pretty_bell, :chiplead, :beep, :chipbass].choose
    with_fx :reverb, room: 0.4, mix: 0.3 do
      play pn.sample + [12, 24, 36].sample, amp: i * 0.2, attack: 0.05, release: 0.3, cutoff: lr(80 + i * 30, 50, 130), pan: cp(t + rand(16), [:spiral, :figure8, :wave].sample)
    end
  end
end
live_loop :cg do
  t = tick
  m = qs(t * 0.25, :micro)
  M = qs(t * 0.125, :macro)
  f = qs(t * 0.0625, :fusion)
  cp = ccp(t)
  pn = csn(cp)
  if t % 4 == 0
    sample :bd_haus, amp: m, rate: lr(1 + (m - 0.5) * 0.1, 0.5, 2.0), lpf: lr(80 + M * 40, 20, 130), pan: cp(t, :pendulum) * 0.3
  end
  if [6, 14].include?(t % 16)
    sample :sn_dub, amp: M * 0.8, pan: cp(t, :orbit), hpf: lr(20 + m * 80, 0, 118)
  end
  if spread(5, 16)[t % 16]
    sample [:perc_bell, :elec_tick, :elec_blip2, :elec_chime, :perc_snap, :elec_pop, :ambi_glass_rub, :ambi_piano, :ambi_soft_buzz, :ambi_swoosh].choose, amp: f * 0.4, rate: lr(0.8 + m * 0.4, 0.25, 4.0), pan: cp(t + rand(8), :spiral)
  end
  if s == :edm
    if t % 1 == 0
      sample :drum_cymbal_closed, amp: 0.2, pan: cp(t, :random)
    end
    da = (t % 64 < 4 ? 2 : 1)
  else
    da = 1
  end
  if t % 2 == 0 && m > 0.5
    ni = ((t * f * 5) + (m * 8)).to_i % pn.length
    tn = pn[ni]
    es(m, note(tn))
    with_fx :distortion, distort: 0.1 do
      play tn, amp: m * 0.7 * da, cutoff: lr(40 + M * 80, 0, 130), res: lr(f * 0.8, 0, 1), attack: lr((1 - m) * 0.3, 0, 4), release: lr(0.2 + f * 0.5, 0.1, 8), pan: cp(t, :galaxy)
    end
  end
  pcl(:harmonic, t, f, pn) if t % 2 == 0
  pcl(:tremolo, t, M, pn) if t % 4 == 0
  if t % 32 == 0
    in_thread do
      3.times do |i|
        ct = [:minor7, :major7, :sus4, :add9, :dim7, :minor, :major, :dom7].sample
        use_synth [:hollow, :prophet, :saw, :blade].sample
        play chord(pn[i % pn.length], ct), amp: f * 0.2 * da, attack: lr(1.5 + i * 0.5, 0, 4), release: lr(6 + M * 3, 1, 12), cutoff: lr(60 + m * 25, 20, 130), pan: cp(t + i * 16, [:spiral, :orbit, :galaxy, :figure8, :random].sample)
        sleep 8
      end
    end
  end
  if t % 8 == 0 && f > 0.6
    use_synth [:sine, :subpulse, :fm, :tb303].sample
    play note(pn[0]) - 24, amp: M * 0.6 * da, attack: 0.1, release: 2, cutoff: lr(60 + m * 20, 20, 130), pan: cp(t, :pendulum) * 0.4
  end
  sleep 0.25
end
live_loop :ct, sync: :cg do
  t = tick
  f = qs(t * 0.0625, :fusion)
  cp = ccp(t * 2)
  pn = csn(cp)
  if t % 2 == 0
    pi = qs(t * 0.125, :micro)
    pcl(:particle, t * 2, pi, pn)
  end
  if t % 32 == 0
    si = qs(t * 0.015625, :fusion)
    if si > 0.6
      use_synth [:hollow, :prophet, :saw].choose
      sc = pn.take(3).map { |n| n - 12 }
      with_fx :reverb, room: s == :deep_house ? 0.8 : 0.6, mix: 0.5 do
        with_fx :lpf, cutoff: lr(70 + si * 30, 40, 120) do
          play sc, amp: si * 0.25, attack: 2, release: 6, pan: cp(t * 8, :wave) * 0.7
        end
      end
    end
  end
  if s == :deep_house && t % 4 == 0
    sample :loop_compus, amp: 0.3, beat_stretch: 4
  end
  if t % 16 == 0 && f > 0.5
    sample [:guit_harmonics, :guit_e_fifths, :guit_e_slide, :guit_em9, :drum_roll, :perc_bell, :elec_tick, :elec_blip2, :elec_chime, :perc_snap, :elec_ping, :elec_pop, :ambi_choir, :ambi_glass_rub, :ambi_piano, :ambi_soft_buzz, :ambi_swoosh].choose, amp: f * 0.3, rate: lr(0.5 + f * 0.5, 0.25, 2.0), pan: cp(t * 4, :random)
  end
  sleep 2
end
live_loop :cm, sync: :cg do
  t = tick
  cp = ccp(t * 4)
  pn = csn(cp)
  if t % 8 == 0
    use_synth :dark_ambience
    ai = qs(t * 0.125, :fusion)
    an = pn.map { |n| note(n) - 36 }.take(3)
    play an, amp: ai * 0.15, attack: 8, release: 16, cutoff: lr(40 + ai * 20, 20, 130), pan: cp(t * 4, :galaxy) * 0.6
  end
  if t % 20 == 0 && t > 0
    use_synth :prophet
    with_fx :reverb, room: 0.8, mix: 0.6 do
      with_fx :echo, phase: 0.375, decay: 2 do
        pn.each_with_index do |nv, i|
          at i * 0.2 do
            play nv + 12, amp: 0.3, attack: 0.5, release: 2, cutoff: 90, pan: cp(t * 4 + i * 4, :spiral)
          end
        end
      end
    end
    puts "🌌 相位提示: #{cp.to_s.upcase}"
  end
  if t % 16 == 0 && t > 0
    ge = qs(t * 0.0625, :macro)
    pe = { big_bang: "💥", galaxy: "🌌", stellar: "⭐", death: "🌑", quantum: "⚛️" }
    puts "#{pe[cp]} #{cp.to_s.upcase} | 演化度: #{(ge * 100).to_i}%"
  end
  sleep 4
end
puts "=== Cosmic EDM Evolution v1.0 启动 ==="
puts "🎭 7种立体声轨道 | 🎵 25种音色 | 🌌 宇宙谐波音阶"
puts "⚛️ 量子态演化引擎运行中... | 风格: #{s.to_s.upcase}"

# === 系统功能说明 ===
# 🌌 Cosmic EDM Evolution v1.0 - 功能概览
#
# 时间单位说明：
# • cg loop: 1 tick = 0.25 拍 (sleep 0.25)
# • ct loop: 1 tick = 2 拍    (sleep 2)
# • cm loop: 1 tick = 4 拍    (sleep 4)
# 下面若未特别说明，“拍”指真实 musical beats，括号中给出代码触发条件。
#
# === 核心结构 ===
# 1. 量子态演化层 (qs):
#    - micro：微观快速扰动
#    - macro：缓慢能量曲线
#    - fusion：两者加权融合并限幅
# 2. 宇宙谐波相位循环 (ccp + CS)：big_bang → galaxy → stellar → death → quantum 自动轮换。
# 3. 立体声轨道函数 (cp)：spiral / orbit / pendulum / galaxy / figure8 / wave / random 提供动态声像。
#
# === 风格切换 ===
# • :edm → 128 BPM，恒定 closed hi-hat，64 拍周期前 4 拍能量提升 (t % 64 < 4)。
# • :deep_house → 120 BPM，加入 compus shaker（ct 中 t%4==0 即每 8 拍）与较大混响。
#
# === 音乐层次 ===
# 🥁 节拍层 (cg):
#    - 底鼓：每 1 拍 (t % 4 == 0)；声像 pendulum。
#    - 军鼓：16 tick 序列中的第 6 与 14 tick → 6,14 ⇒ 1.5 拍与 3.5 拍位置。
#    - 打击细节：spread(5,16) → 16 tick（=4 拍）循环的 5 分布事件。
#    - Hi-hat：EDM 模式每 tick (0.25 拍)。
#    - 能量提升：64 拍周期前 4 拍振幅加倍 (da=2)。
#
# 🌀 纹理/装饰 (pcl):
#    - harmonic：每 3 tick 触发 (≈0.75 拍) 且 fusion 强度 > 0.4。
#    - tremolo：32 tick pattern (spread 7,32) = 8 拍循环稀疏触发。
#    - particle：ct 中每 4 拍评估一次（ct t%2==0 → 2*2 拍），高能量 (micro>0.7) 时触发。
#
# 🎵 旋律层：
#    - 相位驱动选音：按当前相位音列索引推进。
#    - 动态合成器选择：根据音高区块自适应 (es)。
#    - 轻度失真与滤波参数随 micro/macro/fusion 波动。
#
# 🎹 和声层：
#    - 和弦线程：每 32 tick (=8 拍) 启动独立线程，分 3 组和弦（每组 8 拍 sustain）。
#    - 低音：每 8 tick (=2 拍) 若 fusion > 0.6 补强根音下两组八度。
#
# 🌌 质感层 (ct):
#    - Pad/和声簇：每 32 ct tick (=64 拍) 条件性进入 (si>0.6)。
#    - 环境采样点缀：每 16 ct tick (=32 拍) 且 fusion > 0.5。
#    - Deep House shaker：ct t%4==0 → 每 8 拍。
#
# 🌟 背景层 (cm):
#    - 长尾氛围：每 8 cm tick (=32 拍) 生成低频和声堆叠。
#    - 相位提示：每 20 cm tick (=80 拍) 回声提示与日志输出。
#    - 状态日志：每 4 cm tick (=16 拍) 打印相位与演化度。
#
# === 技术亮点 ===
# • 数学调制 (正弦 / 黄金比例) + 随机采样混合，兼顾结构与生成性。
# • 自适应合成器：基础池 26 个音色 + 额外调制合成调用（>26）。
# • 参数限幅 (lr) 防止 cutoff / rate / mod 超界。
# • 多线程和弦：独立 in_thread 提升空间层次。
# • 声像轨道统一由 cp 抽象，便于扩展新轨道函数。
#
# === 使用建议 ===
# • 修改变量 s=:edm / :deep_house 切换风格。
# • 运行 ≥5 分钟体验一个以上完整长周期（含 64/80 拍事件）。
# • 立体声输出设备可最大化轨道运动感。
# • 可调试：临时开启 use_debug true 观察事件节奏。