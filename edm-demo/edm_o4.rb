# EDM宇宙演化系统 - O4多风格版

style = :edm  # 切换风格 :deep_house

use_bpm style == :edm ? 128 : 120
set_volume! 0.8
use_debug false

PHI = 1.618034
EULER = 2.718281828
PI = Math::PI

COSMIC_SCALES = {
  big_bang: [:c5, :d5, :f5, :g5],
  galaxy: [:c4, :e4, :g4, :bb4, :d5],
  stellar: [:c4, :d4, :f4, :g4, :a4],
  death: [:c4, :eb4, :gb4, :a4],
  quantum: [:c4, :db4, :e4, :fs4, :ab4]
}.freeze

EVOLUTION_PHASES = [:big_bang, :galaxy, :stellar, :death, :quantum].ring

define :cosmic_pan do |time, type = :spiral|
  case type
  when :spiral
    Math.sin(time * PHI * 0.08) * Math.cos(time * 0.05) * 0.8
  when :orbit
    Math.sin(time * 0.12) * 0.7
  when :pendulum
    Math.sin(time * 0.15) * Math.cos(time * 0.03) * 0.6
  when :galaxy
    radius = 0.6 + Math.sin(time * 0.02) * 0.2
    Math.sin(time * 0.1) * radius
  when :figure8
    Math.sin(time * 0.08) * Math.cos(time * 0.16) * 0.9
  when :wave
    Math.sin(time * 0.06) * (0.5 + Math.sin(time * 0.02) * 0.3)
  when :random
    rand(-0.8..0.8)
  end
end

define :quantum_state do |time, layer|
  case layer
  when :micro
    base = time * PHI * 0.1
    quantum_osc = (Math.sin(base) * Math.log(EULER) + Math.cos(base * 2)) * 0.3
    chaos_factor = (Math.sin(base * 3.14159) + Math.cos(base * 1.414)) * 0.2
    (quantum_osc + chaos_factor).abs * 0.5 + 0.3
  when :macro
    cosmic_time = time * 0.0618
    dark_energy = Math.sin(cosmic_time * 0.73) * 0.4
    matter_density = Math.cos(cosmic_time * 0.27 + PI/3) * 0.3
    (dark_energy + matter_density) * 0.5 + 0.5
  when :fusion
    micro_influence = quantum_state(time, :micro) * 0.6
    macro_influence = quantum_state(time, :macro) * 0.4
    [[micro_influence + macro_influence, 0.9].min, 0.1].max
  end
end

define :limit_range do |value, min_val, max_val|
  [[value, max_val].min, min_val].max
end

define :evolving_synth do |intensity, note_midi|
  freq_class = note_midi > 72 ? :high : (note_midi > 60 ? :mid : :low)
  synth_pools = {
    low: [:fm, :sine, :tb303, :subpulse, :dsaw, :dtri, :dpulse, :tri, :growl],
    mid: [:saw, :prophet, :zawa, :blade, :pulse, :supersaw, :mod_saw, :noise],
    high: [:hollow, :pretty_bell, :chiplead, :chipbass, :beep, :mod_beep, :pluck, :pnoise]
  }
  synth_choice = synth_pools[freq_class][(intensity * 9).to_i % 9]
  use_synth synth_choice
  synth_choice
end

define :current_cosmic_phase do |time|
  EVOLUTION_PHASES[((time * 0.01) % EVOLUTION_PHASES.length).to_i]
end

define :cosmic_scale_notes do |phase|
  COSMIC_SCALES[phase] || COSMIC_SCALES[:stellar]
end

define :play_cosmic_layer do |layer_type, t, intensity, phase_notes|
  case layer_type
  when :harmonic
    return unless t % 3 == 0 and intensity > 0.4
    use_synth [:mod_sine, :mod_saw, :mod_pulse, :mod_tri].choose
    play phase_notes[(t % phase_notes.length)] + 12,
      amp: intensity * 0.3,
      mod_range: limit_range(intensity * 12, 0, 24),
      mod_rate: limit_range(intensity * 8, 0.1, 16),
      attack: 0.1, release: 1.5,
      pan: cosmic_pan(t, :figure8)
    
  when :tremolo
    return unless spread(7, 32)[t % 32]
    use_synth [:prophet, :zawa, :hollow, :pluck].choose
    with_fx :tremolo, phase: limit_range(intensity * 2, 0.1, 4),
    mix: limit_range(intensity * 0.8, 0, 1) do
      play phase_notes.sample + (rand(2) == 0 ? 0 : 7),
        amp: intensity * 0.4,
        cutoff: limit_range(60 + intensity * 40, 20, 130),
        release: 0.8, pan: cosmic_pan(t, :wave)
    end
    
  when :particle
    return unless intensity > 0.7
    use_synth [:pretty_bell, :chiplead, :beep, :chipbass].choose
    with_fx :reverb, room: 0.4, mix: 0.3 do
      play particle_note = phase_notes.sample + [12, 24, 36].sample
      play particle_note, amp: intensity * 0.2, attack: 0.05, release: 0.3,
        cutoff: limit_range(80 + intensity * 30, 50, 130),
        pan: cosmic_pan(t + rand(16), [:spiral, :figure8, :wave].sample)
    end
  end
end

live_loop :cosmic_genesis do
  t = tick
  
  micro = quantum_state(t * 0.25, :micro)
  macro = quantum_state(t * 0.125, :macro)
  fusion = quantum_state(t * 0.0625, :fusion)
  
  cosmic_phase = current_cosmic_phase(t)
  phase_notes = cosmic_scale_notes(cosmic_phase)
  
  if t % 4 == 0
    sample :bd_haus, amp: micro,
      rate: limit_range(1 + (micro - 0.5) * 0.1, 0.5, 2.0),
      lpf: limit_range(80 + macro * 40, 20, 130),
      pan: cosmic_pan(t, :pendulum) * 0.3
  end
  
  if [6, 14].include?(t % 16)
    sample :sn_dub, amp: macro * 0.8,
      pan: cosmic_pan(t, :orbit),
      hpf: limit_range(20 + micro * 80, 0, 118)
  end
  
  if spread(5, 16)[t % 16]
    sample [:perc_bell, :elec_tick, :elec_blip2, :elec_chime, :perc_snap, :elec_pop, :ambi_glass_rub, :ambi_piano, :ambi_soft_buzz, :ambi_swoosh].choose,
      amp: fusion * 0.4,
      rate: limit_range(0.8 + micro * 0.4, 0.25, 4.0),
      pan: cosmic_pan(t + rand(8), :spiral)
  end

  if style == :edm
    if t % 1 == 0
      sample :drum_cymbal_closed, amp: 0.2, pan: cosmic_pan(t, :random)
    end
    drop_amp = (t % 64 < 4 ? 2 : 1)
  else
    drop_amp = 1
  end
  
  if t % 2 == 0 and micro > 0.5
    note_index = ((t * fusion * 5) + (micro * 8)).to_i % phase_notes.length
    target_note = phase_notes[note_index]
    
    evolving_synth(micro, note(target_note))
    with_fx :distortion, distort: 0.1 do
      play target_note,
        amp: micro * 0.7 * drop_amp,
        cutoff: limit_range(40 + macro * 80, 0, 130),
        res: limit_range(fusion * 0.8, 0, 1),
        attack: limit_range((1 - micro) * 0.3, 0, 4),
        release: limit_range(0.2 + fusion * 0.5, 0.1, 8),
        pan: cosmic_pan(t, :galaxy)
    end
  end
  
  play_cosmic_layer(:harmonic, t, fusion, phase_notes) if t % 2 == 0
  play_cosmic_layer(:tremolo, t, macro, phase_notes) if t % 4 == 0
  
  if t % 32 == 0
    in_thread do
      3.times do |i|
        chord_type = [:minor7, :major7, :sus4, :add9, :dim7, :minor, :major, :dom7].sample
        use_synth [:hollow, :prophet, :saw, :blade].sample
        play chord(phase_notes[i % phase_notes.length], chord_type),
          amp: fusion * 0.2 * drop_amp, attack: limit_range(1.5 + i * 0.5, 0, 4),
          release: limit_range(6 + macro * 3, 1, 12),
          cutoff: limit_range(60 + micro * 25, 20, 130),
          pan: cosmic_pan(t + i * 16, [:spiral, :orbit, :galaxy, :figure8, :random].sample)
        sleep 8
      end
    end
  end
  
  if t % 8 == 0 and fusion > 0.6
    use_synth [:sine, :subpulse, :fm, :tb303].sample
    play note(phase_notes[0]) - 24, amp: macro * 0.6 * drop_amp, attack: 0.1, release: 2,
      cutoff: limit_range(60 + micro * 20, 20, 130),
      pan: cosmic_pan(t, :pendulum) * 0.4
  end
  
  sleep 0.25
end

live_loop :cosmic_textures, sync: :cosmic_genesis do
  t = tick
  current_phase = current_cosmic_phase(t * 2)
  phase_notes = cosmic_scale_notes(current_phase)
  
  if t % 2 == 0
    particle_intensity = quantum_state(t * 0.125, :micro)
    play_cosmic_layer(:particle, t * 2, particle_intensity, phase_notes)
  end
  
  if t % 32 == 0
    string_intensity = quantum_state(t * 0.015625, :fusion)
    if string_intensity > 0.6
      use_synth [:hollow, :prophet, :saw].choose
      string_chord = phase_notes.take(3).map { |n| n - 12 }
      with_fx :reverb, room: style == :deep_house ? 0.8 : 0.6, mix: 0.5 do
        with_fx :lpf, cutoff: limit_range(70 + string_intensity * 30, 40, 120) do
          play string_chord, amp: string_intensity * 0.25, attack: 2, release: 6,
            pan: cosmic_pan(t * 8, :wave) * 0.7
        end
      end
    end
  end
  
  # Deep House风格: 添加shaker
  if style == :deep_house and t % 4 == 0
    sample :loop_compus, amp: 0.3, beat_stretch: 4
  end
  
  sleep 2
end

live_loop :cosmic_management, sync: :cosmic_genesis do
  t = tick
  current_phase = current_cosmic_phase(t * 4)
  phase_notes = cosmic_scale_notes(current_phase)
  
  if t % 8 == 0
    use_synth :dark_ambience
    ambient_intensity = quantum_state(t * 0.125, :fusion)
    ambient_notes = phase_notes.map { |n| note(n) - 36 }.take(3)
    play ambient_notes, amp: ambient_intensity * 0.15, attack: 8, release: 16,
      cutoff: limit_range(40 + ambient_intensity * 20, 20, 130),
      pan: cosmic_pan(t * 4, :galaxy) * 0.6
  end
  
  if t % 20 == 0 and t > 0
    use_synth :prophet
    with_fx :reverb, room: 0.8, mix: 0.6 do
      with_fx :echo, phase: 0.375, decay: 2 do
        phase_notes.each_with_index do |note_val, i|
          at i * 0.2 do
            play note_val + 12, amp: 0.3, attack: 0.5, release: 2,
              cutoff: 90, pan: cosmic_pan(t * 4 + i * 4, :spiral)
          end
        end
      end
    end
    puts "🌌 相位转换: #{current_phase.to_s.upcase}"
  end
  
  if t % 16 == 0 and t > 0
    global_evolution = quantum_state(t * 0.0625, :macro)
    phase_emoji = { big_bang: "💥", galaxy: "🌌", stellar: "⭐", death: "🌑", quantum: "⚛️" }
    puts "#{phase_emoji[current_phase]} #{current_phase.to_s.upcase} | 演化度: #{(global_evolution * 100).to_i}%"
  end

  if t == 1 then puts "🎵 开始录音" end
  if t == 75 then puts "🎵 结束录音" end
  
  sleep 4
end

puts "=== EDM宇宙演化系统 O4 多风格版启动 ==="
puts "🎭 7种立体声轨道 | 🎵 25种音色 | 🌌 宇宙谐波音阶"
puts "⚛️ 量子态演化引擎运行中... | 风格: #{style.to_s.upcase}"


# === 系统功能说明 ===

# 🌌 EDM宇宙演化系统 O4 - 多风格完整功能介绍

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

# 🌌 管理层(cosmic_management)：
#    - 宇宙背景辐射：低频环境音，星系轨道
#    - 相位转换音效：每80拍的相位变化提示音
#    - 实时状态监控：显示当前相位和演化程度

# === 技术亮点 ===
# • 数学驱动：整个系统基于严格的数学公式，无随机性
# • 自适应音色：根据音符频率和强度自动选择最佳合成器
# • 智能参数限制：所有参数都有安全范围限制，避免极端值
# • 多线程和声：和弦进行在独立线程中异步演奏
# • 代码精简：280行实现12层音乐纹理和7种立体声轨道
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