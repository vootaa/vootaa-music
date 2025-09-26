# EDM宇宙演化系统 - O2优化版
# 增强立体声效果 + 宇宙谐波音阶系统

use_bpm 128
use_debug false

# === 核心宇宙常数 ===
PHI = 1.618034  # 黄金比例
EULER = 2.718281828  # 自然常数
PI = Math::PI

# === 宇宙谐波音阶系统 ===
COSMIC_SCALES = {
  big_bang: [:c5, :d5, :f5, :g5],
  galaxy: [:c4, :e4, :g4, :bb4, :d5],
  stellar: [:c4, :d4, :f4, :g4, :a4],
  death: [:c4, :eb4, :gb4, :a4],
  quantum: [:c4, :db4, :e4, :fs4, :ab4]
}.freeze

EVOLUTION_PHASES = [:big_bang, :galaxy, :stellar, :death, :quantum].ring

# === 立体声轨道系统 ===
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
  end
end

# === 演化算法核心 ===
define :quantum_state do |time, layer|
  case layer
  when :micro    # 量子层
    base = time * PHI * 0.1
    quantum_osc = (Math.sin(base) * Math.log(EULER) + Math.cos(base * 2)) * 0.3
    chaos_factor = (Math.sin(base * 3.14159) + Math.cos(base * 1.414)) * 0.2
    (quantum_osc + chaos_factor).abs * 0.5 + 0.3
    
  when :macro    # 宇宙层
    cosmic_time = time * 0.0618
    dark_energy = Math.sin(cosmic_time * 0.73) * 0.4
    matter_density = Math.cos(cosmic_time * 0.27 + PI/3) * 0.3
    (dark_energy + matter_density) * 0.5 + 0.5
    
  when :fusion   # 融合层
    micro_influence = quantum_state(time, :micro) * 0.6
    macro_influence = quantum_state(time, :macro) * 0.4
    result = micro_influence + macro_influence
    [[result, 0.9].min, 0.1].max
  end
end

define :limit_range do |value, min_val, max_val|
  [[value, max_val].min, min_val].max
end

define :evolving_synth do |intensity, note_midi|
  freq_class = note_midi > 72 ? :high : (note_midi > 60 ? :mid : :low)
  synth_map = {
    low: [:fm, :sine, :tb303],
    mid: [:saw, :prophet, :zawa], 
    high: [:hollow, :pretty_bell, :chiplead]
  }
  synth_choice = synth_map[freq_class][(intensity * 3).to_i % 3]
  use_synth synth_choice
  synth_choice
end

# === 宇宙相位选择器 ===
define :current_cosmic_phase do |time|
  phase_index = ((time * 0.01) % EVOLUTION_PHASES.length).to_i
  EVOLUTION_PHASES[phase_index]
end

define :cosmic_scale_notes do |phase|
  COSMIC_SCALES[phase] || COSMIC_SCALES[:stellar]
end

# === 主演化引擎 ===
live_loop :cosmic_genesis do
  t = tick
  
  # 三层演化状态计算
  micro = quantum_state(t * 0.25, :micro)
  macro = quantum_state(t * 0.125, :macro)  
  fusion = quantum_state(t * 0.0625, :fusion)
  
  # 当前宇宙相位
  cosmic_phase = current_cosmic_phase(t)
  phase_notes = cosmic_scale_notes(cosmic_phase)
  
  # === 节拍层：宇宙心跳 ===
  if t % 4 == 0
    sample :bd_haus, amp: micro, 
           rate: limit_range(1 + (micro - 0.5) * 0.1, 0.5, 2.0),
           lpf: limit_range(80 + macro * 40, 20, 130),
           pan: cosmic_pan(t, :pendulum) * 0.3
  end
  
  # 宇宙呼吸 - snare变化
  if [6, 14].include?(t % 16)
    sample :sn_dub, amp: macro * 0.8, 
           pan: cosmic_pan(t, :orbit),
           hpf: limit_range(20 + micro * 80, 0, 118)
  end
  
  # 量子脉冲 - 细节打击乐（增强立体声）
  if spread(5, 16)[t % 16]
    sample [:perc_bell, :elec_tick, :elec_blip2].choose, 
           amp: fusion * 0.4, 
           rate: limit_range(0.8 + micro * 0.4, 0.25, 4.0),
           pan: cosmic_pan(t + rand(8), :spiral)
  end
  
  # === 宇宙旋律层：相位驱动 ===
  if t % 2 == 0
    note_probability = micro * 6
    if note_probability > (t % 6)
      note_index = ((t * fusion * 5) + (micro * 8)).to_i % phase_notes.length
      target_note = phase_notes[note_index]
      target_note_midi = note(target_note)
      
      evolving_synth(micro, target_note_midi)
      
      play target_note, 
           amp: micro * 0.7,
           cutoff: limit_range(40 + macro * 80, 0, 130),
           res: limit_range(fusion * 0.8, 0, 1),
           attack: limit_range((1 - micro) * 0.3, 0, 4),
           release: limit_range(0.2 + fusion * 0.5, 0.1, 8),
           pan: cosmic_pan(t, :galaxy)
    end
  end
  
  # === 宇宙和声层：相位和弦 ===
  if t % 32 == 0
    in_thread do
      3.times do |i|
        base_note = phase_notes[i % phase_notes.length]
        chord_type = [:minor7, :major7, :sus4, :add9].sample
        
        use_synth :hollow
        play chord(base_note, chord_type), 
             amp: fusion * 0.2,
             attack: limit_range(1.5 + i * 0.5, 0, 4),
             release: limit_range(6 + macro * 3, 1, 12),
             cutoff: limit_range(60 + micro * 25, 20, 130),
             pan: cosmic_pan(t + i * 16, [:spiral, :orbit, :galaxy].sample)
        sleep 8
      end
    end
  end
  
  # === 低频基础：时空结构 ===
  if t % 8 == 0 and fusion > 0.6
    use_synth :sine
    bass_note = phase_notes[0]
    bass_octave = note(bass_note) - 24
    
    play bass_octave,
         amp: macro * 0.6,
         attack: 0.1,
         release: 2,
         cutoff: limit_range(60 + micro * 20, 20, 130),
         pan: cosmic_pan(t, :pendulum) * 0.4
  end
  
  sleep 0.25
end

# === 宇宙背景音效层（增强立体声）===
live_loop :cosmic_ambience, sync: :cosmic_genesis do
  use_synth :dark_ambience
  t = tick
  
  ambient_intensity = quantum_state(t * 0.03125, :fusion)
  current_phase = current_cosmic_phase(t)
  phase_notes = cosmic_scale_notes(current_phase)
  
  # 选择相位对应的低音
  ambient_notes = phase_notes.map { |n| note(n) - 36 }.take(3)
  
  play ambient_notes, 
       amp: ambient_intensity * 0.15,
       attack: 8, 
       release: 16,
       cutoff: limit_range(40 + ambient_intensity * 20, 20, 130),
       pan: cosmic_pan(t, :galaxy) * 0.6
       
  sleep 32
end

# === 相位转换音效 ===
live_loop :phase_transitions, sync: :cosmic_genesis do
  t = tick
  
  # 每个相位转换时播放特殊音效
  if t % 80 == 0 and t > 0
    current_phase = current_cosmic_phase(t)
    phase_notes = cosmic_scale_notes(current_phase)
    
    use_synth :prophet
    with_fx :reverb, room: 0.8, mix: 0.6 do
      with_fx :echo, phase: 0.375, decay: 2 do
        phase_notes.each_with_index do |note_val, i|
          at i * 0.2 do
            play note_val + 12, 
                 amp: 0.3,
                 attack: 0.5,
                 release: 2,
                 cutoff: 90,
                 pan: cosmic_pan(t + i * 4, :spiral)
          end
        end
      end
    end
    
    puts "🌌 相位转换: #{current_phase.to_s.upcase}"
  end
  
  sleep 16
end

# === 演化状态监控 ===
live_loop :evolution_monitor, sync: :cosmic_genesis do
  t = tick * 4  # 匹配主循环时间
  current_phase = current_cosmic_phase(t)
  global_evolution = quantum_state(t * 0.015625, :macro)
  
  if t % 64 == 0 and t > 0
    phase_emoji = {
      big_bang: "💥", galaxy: "🌌", stellar: "⭐", 
      death: "🌑", quantum: "⚛️"
    }
    puts "#{phase_emoji[current_phase]} #{current_phase.to_s.upcase} | 演化度: #{(global_evolution * 100).to_i}%"
  end
  
  sleep 16
end

puts "=== EDM宇宙演化系统 O2 启动 ==="
puts "🎭 立体声轨道系统激活"
puts "🌌 宇宙谐波音阶载入"
puts "⚛️ 量子态演化引擎运行中..."