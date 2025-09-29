# Dawn Ignition 《晨启》- Enhanced Version
# 场景：清晨出发 / 通勤 | 风格：渐进式 House
# 时长：20-25 分钟 | 车载优化版本

use_bpm 120
use_debug false

# 核心数学模块
define :pi_random do |index, min_val = 0, max_val = 1|
  pi_str = "31415926535897932384626433832795028841971693993751"
  digit = pi_str[index % pi_str.length].to_i
  min_val + (digit / 9.0) * (max_val - min_val)
end

define :golden_evolution do |time, amplitude = 1.0|
  phi = 1.618033988749895
  Math.sin(time * phi * 0.01) * amplitude
end

define :fractal_rhythm do |time, depth = 2|
  return [1] if depth == 0
  base = [1, 0, 1, 0]
  sub = fractal_rhythm(time, depth - 1)
  base.flat_map { |b| b == 1 ? sub : [0] * sub.length }
end

define :domain_warp do |time, strength = 0.5|
  x = time * 0.1
  y = time * 0.05
  warp_x = Math.sin(x * 3.0) * strength
  warp_y = Math.cos(y * 2.0) * strength
  [x + warp_x, y + warp_y]
end

define :texture_sample do |time, texture, speed = 0.1|
  u = (time * speed) % 1.0
  texture[(u * texture.length).floor % texture.length]
end

# 智能参数限制
define :smart_cutoff do |value|
  clamped = [[value, 20].max, 125].min
  clamped
end

define :smart_amp do |value|
  [[value, 0.01].max, 3.0].min
end

define :smart_pan do |value|
  [[value, -0.95].max, 0.95].min
end

# 车载优化混音系统
define :car_mix_profile do |element_type|
  case element_type
  when :kick then { amp: 1.4, lpf: 85, hpf: 35 }
  when :bass then { amp: 1.2, lpf: 110, hpf: 45 }
  when :lead then { amp: 1.0, hpf: 85 }
  when :ambient then { amp: 0.8, spread: 0.9 }
  else { amp: 0.8 }
  end
end

# 全局控制
set :dawn_time, 0
set :energy_level, 0.2
set :musical_memory, []

live_loop :dawn_master_clock do
  set :dawn_time, get(:dawn_time) + 1
  # 20分钟能量弧线 (9600 * 0.125s = 20min)
  progress = (get(:dawn_time) % 9600) / 9600.0
  energy = 1.0 / (1.0 + Math.exp(-6 * (progress - 0.5))) # S曲线
  set :energy_level, 0.2 + energy * 0.8  # 更大的能量范围
  sleep 0.125
end

# 分形驱动鼓组
live_loop :fractal_kick, sync: :dawn_master_clock do
  t = get(:dawn_time)
  mix = car_mix_profile(:kick)
  
  pattern = fractal_rhythm(t / 64, 2)
  kick_prob = pi_random(t / 8, 0.3, 0.95)
  
  if pattern[t % pattern.length] == 1 && pi_random(t, 0, 1) < kick_prob
    kick_amp = mix[:amp] * get(:energy_level) * (0.8 + pi_random(t, 0, 0.4))
    
    with_fx :hpf, cutoff: mix[:hpf] do
      with_fx :lpf, cutoff: mix[:lpf] do
        sample :bd_haus, 
               amp: smart_amp(kick_amp),
               rate: 1.0 + golden_evolution(t) * 0.08,
               cutoff: smart_cutoff(60 + golden_evolution(t * 2) * 15)
      end
    end
  end
  sleep 0.5
end

live_loop :textured_hats, sync: :dawn_master_clock do
  t = get(:dawn_time)
  
  # 纹理驱动的帽子节奏
  hat_texture = [1, 0, 1, 0, 1, 0, 0, 1]
  hat_hit = texture_sample(t, hat_texture, 0.25)
  
  if hat_hit == 1
    warped = domain_warp(t, 0.4)
    hat_energy = get(:energy_level) * (0.6 + pi_random(t * 5, 0, 0.4))
    
    sample :hat_yosh,
           rate: 1.2 + warped[0] * 0.6 + get(:energy_level) * 0.3,
           amp: smart_amp(hat_energy * (0.3 + warped[1].abs * 0.4)),
           pan: smart_pan(pi_random(t * 3, -0.8, 0.8)),
           cutoff: smart_cutoff(80 + warped[0].abs * 25)
  end
  sleep 0.125
end

# 体积混响低音
live_loop :volumetric_bass, sync: :dawn_master_clock do
  t = get(:dawn_time)
  mix = car_mix_profile(:bass)
  
  use_synth :tb303
  
  bass_progression = [:c2, :g2, :f2, :a2]
  current_bass = bass_progression[(t / 128) % 4]
  
  # 多层混响深度
  if t % 2 == 0
    base_cutoff = 65 + get(:energy_level) * 25
    base_amp = mix[:amp] * get(:energy_level)
    
    3.times do |depth|
      distance = depth / 3.0
      reverb_mix = Math.exp(-distance * 1.2) * 0.4
      layer_cutoff = base_cutoff + golden_evolution(t + depth * 100) * 20
      
      with_fx :reverb, room: 0.7 + distance * 0.25, mix: reverb_mix do
        with_fx :lpf, cutoff: mix[:lpf] do
          with_fx :hpf, cutoff: mix[:hpf] do
            play current_bass,
                 release: 0.9 - distance * 0.15,
                 cutoff: smart_cutoff(layer_cutoff),
                 res: 0.6 + distance * 0.2,
                 amp: smart_amp(base_amp * (1.0 - distance * 0.3))
          end
        end
      end
    end
  end
  sleep 1
end

# 记忆系统主旋律 
live_loop :memory_lead, sync: :dawn_master_clock do
  t = get(:dawn_time)
  mix = car_mix_profile(:lead)
  memory = get(:musical_memory).dup
  
  use_synth :prophet
  
  # 主和弦进行
  chord_prog = [chord(:c4, :major), chord(:a3, :minor), 
                chord(:f4, :major), chord(:g4, :major)]
  current_chord = chord_prog[(t / 256) % 4]
  
  # 域扭曲音符选择
  warped = domain_warp(t, 0.5)
  note_index = ((warped[0].abs * 10) % current_chord.length).floor
  selected_note = current_chord[note_index]
  
  # 记忆系统：每64拍可能回调
  if t % 64 == 0 && memory.length > 0 && pi_random(t, 0, 1) > 0.65
    recalled = memory.choose
    selected_note = recalled[:note] + [-2, -1, 0, 1, 2].choose
  end
  
  # 存储当前音符到记忆
  if t % 32 == 0
    memory << { note: selected_note, time: t, energy: get(:energy_level) }
    memory.shift if memory.length > 12
    set :musical_memory, memory
  end
  
  # 动态参数计算
  lead_release = 0.3 + warped[1].abs * 0.5 + get(:energy_level) * 0.3
  lead_cutoff = 75 + warped[0].abs * 35 + get(:energy_level) * 15
  lead_amp = mix[:amp] * get(:energy_level) * (0.7 + pi_random(t, 0, 0.3))
  
  with_fx :reverb, mix: 0.25 + get(:energy_level) * 0.15 do
    with_fx :echo, phase: 0.25, decay: 2 + get(:energy_level) * 2, mix: 0.15 do
      with_fx :hpf, cutoff: mix[:hpf] do
        play selected_note,
             release: lead_release,
             cutoff: smart_cutoff(lead_cutoff),
             amp: smart_amp(lead_amp),
             attack: 0.05 + pi_random(t, 0, 0.1)
      end
    end
  end
  sleep [0.5, 0.25, 0.75, 1.0].ring.tick
end

# 进化氛围层
live_loop :evolving_ambient, sync: :dawn_master_clock do
  t = get(:dawn_time)
  mix = car_mix_profile(:ambient)
  
  if t % 256 == 0  # 每64小节
    use_synth :blade
    
    # 音乐纹理采样
    ambient_scales = [scale(:c4, :major_pentatonic),
                     scale(:a4, :minor_pentatonic),
                     scale(:f4, :dorian)]
    current_scale = ambient_scales[(t / 512) % 3]
    
    sampled_note = texture_sample(t, current_scale, 0.03)
    energy_factor = get(:energy_level)
    
    # 多层体积混响
    5.times do |layer|
      depth = layer / 5.0
      layer_amp = mix[:amp] * energy_factor * (0.4 - depth * 0.06)
      
      in_thread do
        sleep depth * 0.6
        
        with_fx :reverb, room: 0.85 + depth * 0.1, 
                         mix: 0.5 * Math.exp(-depth * 1.8) do
          play sampled_note + [0, 7, 12].choose,
               attack: 1.5 + depth * 1.2,
               release: 5 + depth * 3,
               amp: smart_amp(layer_amp),
               pan: smart_pan(pi_random(t + layer, -mix[:spread], mix[:spread])),
               cutoff: smart_cutoff(90 + depth * 10)
        end
      end
    end
  end
  
  sleep 8
end

# 动态细节装饰
live_loop :fractal_details, sync: :dawn_master_clock do
  t = get(:dawn_time)
  
  # 能量驱动的触发概率
  detail_prob = pi_random(t, 0, 1)
  trigger_threshold = 0.9 - get(:energy_level) * 0.15  # 能量越高，细节越多
  
  if detail_prob > trigger_threshold
    effect_type = [:perc_bell, :elec_plip, :ambi_glass_rub, :elec_blip].choose
    warped = domain_warp(t, 0.7)
    
    detail_rate = 0.7 + warped[0].abs * 0.8 + get(:energy_level) * 0.3
    detail_amp = 0.12 + warped[1].abs * 0.25 + get(:energy_level) * 0.15
    
    sample effect_type,
           rate: detail_rate,
           amp: smart_amp(detail_amp),
           pan: smart_pan(pi_random(t * 7, -0.9, 0.9)),
           cutoff: smart_cutoff(70 + pi_random(t * 11, 0, 40))
  end
  sleep 0.25
end

# 智能动态控制
live_loop :intelligent_dynamics, sync: :dawn_master_clock do
  t = get(:dawn_time)
  
  # 多时间尺度音量控制
  macro = Math.sin(t * 0.003) * 0.25 + 0.75
  meso = Math.cos(t * 0.04) * 0.15 + 0.85
  
  # 黄金比例相位关系
  phi_phase = t * 1.618033988749895 * 0.008
  micro = Math.sin(phi_phase) * 0.08 + 0.92
  
  global_volume = macro * meso * micro * get(:energy_level)
  set :master_volume, global_volume

  if t % 512 == 0
    progress_pct = ((t % 9600) / 9600.0 * 100).round(1)
    energy_pct = (get(:energy_level) * 100).round(1)
    puts "晨启进度: #{progress_pct}% | 能量: #{energy_pct}% | 音量: #{(global_volume * 100).round(1)}%"
  end
  sleep 4
end