# Dawn Ignition 《晨启》
# 场景：清晨出发 / 通勤
# 风格：渐进式 House，节奏从轻快逐渐增强
# 时长：20-25 分钟

use_bpm 120
use_debug false

# ========== 核心数学模块 ==========

# 基于π的确定性随机数生成器
define :pi_random do |index, min_val = 0, max_val = 1|
  pi_str = "31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
  digit = pi_str[index % pi_str.length].to_i
  min_val + (digit / 9.0) * (max_val - min_val)
end

# 黄金比例演进函数
define :golden_evolution do |time, amplitude = 1.0|
  phi = 1.618033988749895
  Math.sin(time * phi * 0.01) * amplitude
end

# 斐波那契节奏序列
define :fibonacci_rhythm do |step|
  fib_sequence = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
  fib_sequence[step % fib_sequence.length]
end

# 音乐"距离场"函数
define :harmonic_distance do |note1, note2|
  Math.abs(note_to_midi(note1) - note_to_midi(note2))
end

# 时间波形叠加
define :time_wave do |global_time, micro_pos|
  macro = Math.sin(global_time * 0.02)
  meso = Math.cos(global_time * 0.1) 
  micro = Math.sin(micro_pos * 4.0)
  macro * 0.5 + meso * 0.3 + micro * 0.2
end

# ========== 音乐基本单元 ==========

# 全局时间计数器
set :dawn_time, 0

# 主时钟
live_loop :dawn_clock do
  set :dawn_time, get(:dawn_time) + 1
  sleep 0.125
end

# 基础鼓组单元 - 灵感来自参考代码的节拍模式
live_loop :dawn_kick, sync: :dawn_clock do
  t = get(:dawn_time)
  
  # 基于π序列的节拍模式演进
  kick_intensity = pi_random(t / 8, 0.6, 1.2)
  kick_pattern = pi_random(t / 16, 0, 1) > 0.3
  
  # 时间波形调制音色
  wave_mod = time_wave(t, t % 32)
  cutoff_val = 80 + wave_mod * 40
  
  if kick_pattern
    sample :bd_haus, 
           amp: kick_intensity, 
           cutoff: cutoff_val,
           rate: 1.0 + golden_evolution(t) * 0.1
  end
  
  sleep 0.5
end

# 渐进式帽子 - 密度随时间增加
live_loop :dawn_hats, sync: :dawn_clock do
  t = get(:dawn_time)
  
  # 斐波那契序列控制节奏密度
  density_factor = fibonacci_rhythm(t / 64) / 144.0
  
  # 基于时间的音色演进
  rate_mod = 1.5 + golden_evolution(t * 1.2) * 0.5
  amp_mod = 0.3 + density_factor * 0.4
  
  # π序列控制是否触发
  trigger_prob = 0.4 + density_factor * 0.4
  
  if pi_random(t, 0, 1) < trigger_prob
    sample :hat_yosh,
           rate: rate_mod,
           amp: amp_mod,
           pan: pi_random(t * 3, -0.6, 0.6)
  end
  
  sleep 0.125
end

# 晨光合成器主旋律 - 灵感来自AcidWalk的和弦序列
live_loop :dawn_lead, sync: :dawn_clock do
  t = get(:dawn_time)
  
  # 基础和弦进行：C Major -> Am -> F -> G
  chord_progression = [:c4, :a3, :f4, :g4]
  current_root = chord_progression[(t / 128) % 4]
  
  use_synth :prophet
  
  # 黄金比例控制滤波器扫描
  cutoff_sweep = 70 + golden_evolution(t * 0.8) * 50
  release_time = 0.3 + pi_random(t / 4, 0, 0.4)
  
  # 和弦音符的"距离场"选择
  chord_notes = chord(current_root, :major)
  selected_note = chord_notes.choose
  
  with_fx :reverb, mix: 0.3 + time_wave(t, 0) * 0.2 do
    with_fx :echo, phase: 0.25, decay: 4, mix: 0.2 do
      play selected_note,
           release: release_time,
           cutoff: cutoff_sweep,
           amp: 0.6,
           attack: 0.05
    end
  end
  
  sleep [0.25, 0.5].choose
end

# 低音线条 - 渐进式能量累积
live_loop :dawn_bass, sync: :dawn_clock do
  t = get(:dawn_time)
  
  use_synth :tb303
  
  # 基础低音序列
  bass_notes = [:c2, :c2, :g2, :f2]
  current_bass = bass_notes[(t / 64) % 4]
  
  # 时间演进的音色调制
  cutoff_val = 60 + time_wave(t, t % 16) * 30
  res_val = 0.7 + golden_evolution(t * 0.6) * 0.2
  
  # 斐波那契控制节奏复杂度
  rhythm_complexity = fibonacci_rhythm(t / 32) % 4
  sleep_time = [1, 0.5, 0.25, 0.125][rhythm_complexity]
  
  play current_bass,
       release: 0.8,
       cutoff: cutoff_val,
       res: res_val,
       amp: 0.8,
       attack: 0.1
       
  sleep sleep_time
end

# 氛围层 - 车载空间感营造
live_loop :dawn_ambient, sync: :dawn_clock do
  t = get(:dawn_time)
  
  # 每16拍触发一次氛围音效
  if t % 128 == 0
    use_synth :blade
    
    # π序列控制音高选择
    ambient_notes = scale(:c3, :major_pentatonic, num_octaves: 2)
    note_index = (pi_random(t / 128, 0, 1) * ambient_notes.length).to_i
    selected_note = ambient_notes[note_index]
    
    # 黄金比例控制空间参数
    room_size = 0.6 + golden_evolution(t * 0.3) * 0.3
    mix_level = 0.4 + time_wave(t, 0) * 0.2
    
    with_fx :reverb, room: room_size, mix: mix_level do
      with_fx :echo, phase: 1, decay: 8, mix: 0.3 do
        play selected_note,
             release: 8,
             attack: 2,
             amp: 0.4,
             cutoff: 90,
             pan: pi_random(t, -0.8, 0.8)
      end
    end
  end
  
  sleep 4
end

# 装饰音效 - 细节变化增强
live_loop :dawn_details, sync: :dawn_clock do
  t = get(:dawn_time)
  
  # 基于π序列的稀疏触发
  detail_prob = pi_random(t, 0, 1)
  
  if detail_prob > 0.85  # 15%概率触发
    # 选择装饰音效类型
    detail_type = (detail_prob * 4).to_i
    
    case detail_type
    when 0
      sample :elec_plip, 
             rate: pi_random(t * 2, 0.5, 2.0),
             amp: 0.3
    when 1
      sample :perc_bell,
             rate: golden_evolution(t) + 1.0,
             amp: 0.2
    when 2
      use_synth :sine
      play :c5 + pi_random(t * 3, -12, 12),
           release: 0.1,
           amp: 0.3
    when 3
      sample :ambi_soft_buzz,
             rate: 0.5,
             amp: 0.15,
             start: pi_random(t * 4, 0, 0.3)
    end
  end
  
  sleep 0.25
end

# 动态控制器 - 整体音乐弧线
live_loop :dawn_dynamics, sync: :dawn_clock do
  t = get(:dawn_time)
  
  # 20分钟 = 9600个0.125拍
  progress = (t % 9600) / 9600.0
  
  # S曲线能量发展
  energy_curve = 1.0 / (1.0 + Math.exp(-8 * (progress - 0.5)))
  
  # 全局音量调制
  set :global_amp, 0.4 + energy_curve * 0.6
  
  # 每8小节输出进度信息
  if t % 256 == 0
    puts "Dawn Ignition Progress: #{(progress * 100).round(1)}% - Energy: #{(energy_curve * 100).round(1)}%"
  end
  
  sleep 4
end