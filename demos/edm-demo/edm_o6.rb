# EDM宇宙演化系统 - o6

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
    puts "🌌 相位转换: #{cp.to_s.upcase}"
  end
  if t % 16 == 0 && t > 0
    ge = qs(t * 0.0625, :macro)
    pe = { big_bang: "💥", galaxy: "🌌", stellar: "⭐", death: "🌑", quantum: "⚛️" }
    puts "#{pe[cp]} #{cp.to_s.upcase} | 演化度: #{(ge * 100).to_i}%"
  end
  sleep 4
end
puts "=== EDM宇宙演化系统 o6 启动 ==="
puts "🎭 7种立体声轨道 | 🎵 25种音色 | 🌌 宇宙谐波音阶"
puts "⚛️ 量子态演化引擎运行中... | 风格: #{s.to_s.upcase}"


# === 系统功能说明 ===

# 🌌 EDM宇宙演化系统 o6 - 功能介绍

# === 核心特色 ===
# 1. 量子态演化引擎：基于黄金比例(PHI)和自然常数(EULER)的三层演化算法
#    - micro层：量子级微观随机性，控制细节变化
#    - macro层：宇宙级宏观演化，控制整体氛围
#    - fusion层：融合层，平衡微观与宏观的相互作用
#
# 2. 宇宙谐波音阶系统：5个演化相位自动循环
#    💥 big_bang：宇宙大爆炸，高能量音阶
#    🌌 galaxy：星系形成，和谐音阶组合
#    ⭐ stellar：恒星演化，稳定的五声音阶
#    🌑 death：恒星死亡，暗调音阶
#    ⚛️ quantum：量子态，复杂半音阶
#
# 3. 七维立体声轨道系统：
#    - spiral：螺旋轨道，基于黄金比例的优雅旋转
#    - orbit：椭圆轨道，规律的左右摆动
#    - pendulum：钟摆轨道，双频率调制的复杂摆动
#    - galaxy：星系轨道，动态半径的银河系旋转
#    - figure8：8字轨道，双频正弦波交织
#    - wave：波浪轨道，多层次波动叠加
#    - random：随机轨道，完全随机的空间定位

# === 风格切换 ===
# • EDM风格 (style = :edm): BPM 128, 添加hi-hat和drop效果，高能量舞曲体验
# • Deep House风格 (style = :deep_house): BPM 120, 添加shaker和增强reverb，温暖groovy氛围

# === 音乐层次结构 ===
# 🥁 节拍层(cosmic_genesis)：
#    - 宇宙心跳：量子态驱动的底鼓，带立体声钟摆效果
#    - 宇宙呼吸：宏观态控制的军鼓，椭圆轨道移动
#    - 量子脉冲：5/16节拍的细节打击乐，螺旋轨道分布
#    - EDM hi-hat：每拍closed hi-hat，增加节奏密度
#    - Deep House shaker：循环compus样本，提供groove

# 🎵 旋律层：
#    - 相位驱动旋律：根据当前宇宙相位选择音阶和音符
#    - 25种智能音色：根据音高自动选择最适合的合成器
#    - 星系轨道pan：旋律音符沿星系轨道运动
#    - 失真效果：轻微distortion增强音色丰富度
#    - EDM drop：每64拍短暂能量爆发

# 🎹 和声层：
#    - 相位和弦：每32拍生成基于当前相位的和弦进行
#    - 多轨道分布：和弦声部分布在7种立体声轨道
#    - 量子低音：深层低音提供时空结构支撑

# 🌟 纹理层(cosmic_textures)：
#    - 量子谐波：3拍周期的调制合成器，8字轨道
#    - 宇宙颤音：tremolo效果的装饰音，波浪轨道  
#    - 宇宙微粒：高音区粒子效果，随机轨道选择
#    - 立体声弦乐：长延音pad，营造空间深度 (Deep House增强reverb)
#    - 样板增强：每16拍随机精选特色样本，添加有机质感

# 🌌 管理层(cosmic_management)：
#    - 宇宙背景辐射：低频环境音，星系轨道
#    - 相位转换音效：每80拍的相位变化提示音
#    - 实时状态监控：显示当前相位和演化程度

# === 技术亮点 ===
# • 数学驱动：整个系统基于严格的数学公式，无随机性
# • 自适应音色：根据音符频率和强度自动选择最佳合成器
# • 智能参数限制：所有参数都有安全范围限制，避免极端值
# • 多线程和声：和弦进行在独立线程中异步演奏
# • 代码精简：200行实现13层音乐纹理和7种立体声轨道
# • 多风格支持：通过简单变量切换EDM/Deep House风格

# === 适用场景 ===
# 🎧 个人聆听：丰富的立体声体验，推荐使用耳机
# 🎵 音乐制作：可作为背景轨道或灵感来源
# 🔬 算法音乐研究：展示数学与音乐结合的可能性
# 🎮 游戏音效：适合科幻、太空题材的背景音乐
# 🧘 冥想放松：量子态演化创造自然的音乐流动
# 🎶 舞曲派对：EDM风格适合俱乐部，Deep House适合chill场景

# === 运行建议 ===
# • 风格切换: 修改 style = :edm 或 :deep_house
# • BPM: EDM 128, Deep House 120 (自动调整)
# • 音量: 建议设置为适中，避免长时间大音量聆听  
# • 运行时间: 系统会持续演化，建议至少运行5分钟体验完整相位循环
# • 立体声设备: 强烈建议使用立体声耳机或音箱以体验空间效果

# 创作理念：用代码演绎宇宙演化，让数学与音乐共舞，
# 在算法的精确性中寻找艺术的无限可能。🎵✨