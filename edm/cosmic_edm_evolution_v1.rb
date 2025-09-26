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
# === 核心结构 ===
# 1. 量子态演化层：micro/macro/fusion 三层算法混合黄金比例与正弦调制，驱动节奏与动态。
# 2. 宇宙谐波音阶：big_bang → galaxy → stellar → death → quantum 依次循环，决定音阶与和声。
# 3. 立体声轨道：spiral/orbit/pendulum/galaxy/figure8/wave/random 为音符提供动态声像。
#
# === 风格切换 ===
# • :edm → BPM 128，常亮 closed hi-hat 与 64 拍加倍动态。
# • :deep_house → BPM 120，加入 compus shaker 与更浓混响。
#
# === 音乐层次 ===
# 🥁 节拍层 (cg loop)
#    - 底鼓：受 micro/macro 强度影响，带摆动声像。
#    - 军鼓：椭圆轨道定位，16 拍循环。
#    - 打击细节：5/16 分布，多样采样随机选取。
#    - Hi-hat：EDM 模式每拍触发。
# 🌀 纹理层 (pcl 调度)
#    - harmonic：3 拍周期合成器层次。
#    - tremolo：32 拍散列触发，波浪声像。
#    - particle：高能量粒子音色，带随机声像。
# 🎵 旋律层
#    - 相位驱动的音符选择，含动态合成器挑选与轻度失真。
# 🎹 和声层
#    - 每 32 拍线程化和弦生成；低音每 8 拍补强。
# 🌌 质感层 (ct loop)
#    - 32 拍 pad 渐入，16 拍环境采样点缀。
#    - Deep House 模式提供 shaker groove。
# 🌟 背景层 (cm loop)
#    - 长尾氛围 pad，20 拍回响提示音与相位日志输出。
#
# === 技术亮点 ===
# • 数学调制结合随机化采样，既有结构亦保留灵活变化。
# • 智能音色选择依据音高区间自动切换。
# • 参数限制函数确保滤波、调制与音量安全范围。
# • 多线程和弦实现异步演奏，增强空间感。
# • 全局状态打印记录当前相位与演化度。
#
# === 使用建议 ===
# • 切换变量 s 为 :edm 或 :deep_house 体验不同音色。
# • 使用立体声耳机/音箱以感受声像轨道。
# • 建议运行 5 分钟以上体验完整演化循环。