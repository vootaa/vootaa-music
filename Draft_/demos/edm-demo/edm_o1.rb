# EDM宇宙演化系统 - 优化版
# 保持原有数学模型和音乐效果，大幅压缩代码长度

use_bpm 128
use_debug false

# === 核心宇宙常数 ===
PHI = 1.618034  # 黄金比例
EULER = 2.718281828  # 自然常数
PI = Math::PI

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

# === 参数限制函数 ===
define :limit_range do |value, min_val, max_val|
  [[value, max_val].min, min_val].max
end

# === 智能音色映射系统 ===
define :evolving_synth do |intensity, note_midi|
  if note_midi > 72
    freq_class = :high
  elsif note_midi > 60
    freq_class = :mid
  else
    freq_class = :low
  end
  
  synth_map = {
    low: [:fm, :sine, :tb303],
    mid: [:saw, :prophet, :zawa], 
    high: [:hollow, :pretty_bell, :chiplead]
  }
  
  synth_choice = synth_map[freq_class][(intensity * 3).to_i % 3]
  use_synth synth_choice
  synth_choice
end

# === 自适应调性系统 ===
SCALE_EVOLUTION = [
  scale(:c4, :minor_pentatonic),
  scale(:g3, :major),
  scale(:f3, :dorian),
  scale(:d4, :mixolydian),
  scale(:a3, :harmonic_minor)
].ring

CHORD_PROGRESSIONS = [
  [chord(:c4, :minor7), chord(:g3, :major7), chord(:f3, :add9)],
  [chord(:d4, :minor7), chord(:a3, :dom7), chord(:bb3, :major7)],
  [chord(:f3, :sus4), chord(:c4, :minor), chord(:g3, :major)]
].ring

# === 主演化引擎 ===
live_loop :cosmic_genesis do
  t = tick
  
  # 三层演化状态计算
  micro = quantum_state(t * 0.25, :micro)
  macro = quantum_state(t * 0.125, :macro)  
  fusion = quantum_state(t * 0.0625, :fusion)
  
  # === 节拍层：宇宙心跳 ===
  if t % 4 == 0
    sample :bd_haus, amp: micro, 
           rate: limit_range(1 + (micro - 0.5) * 0.1, 0.5, 2.0),
           lpf: limit_range(80 + macro * 40, 20, 130)
  end
  
  # 宇宙呼吸 - snare变化（修复hpf范围限制）
  if [6, 14].include?(t % 16)
    sample :sn_dub, amp: macro * 0.8, 
           pan: limit_range((fusion - 0.5) * 0.6, -1, 1),
           hpf: limit_range(20 + micro * 80, 0, 118)  # 限制在118以下
  end
  
  # 量子脉冲 - 细节打击乐
  if spread(5, 16)[t % 16]
    sample [:perc_bell, :elec_tick, :elec_blip2].choose, 
           amp: fusion * 0.4, 
           rate: limit_range(0.8 + micro * 0.4, 0.25, 4.0)
  end
  
  # === 旋律层：意识流动 ===
  if t % 2 == 0
    scale_index = (macro * 5).to_i
    current_scale = SCALE_EVOLUTION[scale_index]
    
    note_probability = micro * 7
    if note_probability > (t % 7)
      note_index = ((t * micro * 7) + (fusion * 12)).to_i % current_scale.length
      target_note = current_scale[note_index]
      target_note_midi = note(target_note)
      
      current_synth = evolving_synth(micro, target_note_midi)
      
      play target_note, 
           amp: micro * 0.7,
           cutoff: limit_range(40 + macro * 80, 0, 130),
           res: limit_range(fusion * 0.8, 0, 1),
           attack: limit_range((1 - micro) * 0.3, 0, 4),
           release: limit_range(0.2 + fusion * 0.5, 0.1, 8),
           pan: limit_range((micro - 0.5) * 0.4, -1, 1)
    end
  end
  
  # === 和声层：宇宙背景辐射 ===
  if t % 32 == 0
    chord_prog_index = (fusion * 3).to_i
    chord_progression = CHORD_PROGRESSIONS[chord_prog_index]
    
    in_thread do
      chord_progression.each_with_index do |chord_notes, i|
        use_synth :hollow
        play chord_notes, 
             amp: fusion * 0.25,
             attack: limit_range(2 + i * 0.5, 0, 4),
             release: limit_range(6 + macro * 4, 1, 16),
             cutoff: limit_range(60 + micro * 30, 20, 130),
             pan: limit_range((i - 1) * 0.3, -1, 1)
        sleep 8
      end
    end
  end
  
  # === 低频基础：时空结构 ===
  if t % 8 == 0 and fusion > 0.6
    use_synth :sine
    bass_note = [:c2, :g1, :f2, :d2].ring[t / 8 % 4]
    play bass_note,
         amp: macro * 0.6,
         attack: 0.1,
         release: 2,
         cutoff: limit_range(60 + micro * 20, 20, 130)
  end
  
  sleep 0.25
end

# === 宇宙背景音效层 ===
live_loop :cosmic_ambience, sync: :cosmic_genesis do
  use_synth :dark_ambience
  
  ambient_intensity = quantum_state(tick * 0.03125, :fusion)
  
  play [:c1, :g1, :c2], 
       amp: ambient_intensity * 0.15,
       attack: 8, 
       release: 16,
       cutoff: limit_range(40 + ambient_intensity * 20, 20, 130)
       
  sleep 32
end

# === 演化反馈调制层 ===
live_loop :evolution_modulation, sync: :cosmic_genesis do
  current_time = tick * 0.015625
  global_evolution = quantum_state(current_time, :macro)
  
  if tick % 16 == 0
    puts "宇宙演化状态: #{(global_evolution * 100).to_i}%"
  end
  
  sleep 64
end

puts "=== EDM宇宙演化系统启动 ==="
puts "量子态初始化完成..."
puts "宇宙演化引擎运行中..."