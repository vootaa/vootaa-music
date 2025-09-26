# 数学驱动演化EDM：宇宙融合版
# 结合EDM结构 + 宇宙谐波系统 + 智能演化控制 + 动态平衡
# 主干：经典EDM + 宇宙谐波音阶
# 花色：多层次数学常数驱动 + 智能音量平衡 + 风格演化

# === 扩展数学常数库 ===
PI_DIGITS = "3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067"
GOLDEN_DIGITS = "1618033988749894848204586834365638117720309179805762862135448622705260462818902449707207204189391137"
E_DIGITS = "2718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427"
SQRT2_DIGITS = "1414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641573"
SQRT3_DIGITS = "7320508075688772935274463415058723669428052538103806280558069794519330169088000370811461867572485756"
EULER_DIGITS = "0577215664901532860606512090082402431042159335939923598805767234884867726777664670936947063291746749"
PLANCK_DIGITS = "6626070040000000000000000000000000000662607004000000000000000000000000000066260700400000000000"
HUBBLE_DIGITS = "7000000067402385119138205128205128205128205128205128205128205128205128205128205"
FINE_STRUCTURE = "7297352566400000000000000000000000000729735256640000000000000000000000000072973"
CATALAN = "9159655941772190150546035149323841107741493742816721342664981198704686804649256927"
CHAMPERNOWNE = "1234567891011121314151617181920212223242526272829303132333435363738394041424344"

# === 全局演化状态 ===
@evolution_tick = 0
@complexity_level = 0
@current_cosmic_stage = 0
@digit_cache = {}
@performance_cache = {}
@active_layers_count = 0
@total_amplitude = 0.0
@style_evolution_phase = 0

# === 宇宙谐波音阶系统（扩展版）===
COSMIC_HARMONIC_SCALES = {
  big_bang: [:c5, :d5, :f5, :g5],                    # 能量爆发
  galaxy_formation: [:c4, :e4, :g4, :bb4, :d5],      # 复杂结构
  stellar_stability: [:c4, :d4, :f4, :g4, :a4],      # 和谐稳定
  stellar_death: [:c4, :eb4, :gb4, :a4],             # 引力坍缩
  heat_death: [:c4, :f4, :bb4],                      # 宇宙孤寂
  # EDM适配的宇宙音阶
  edm_cosmic_minor: [:a3, :c4, :d4, :e4, :g4],       # EDM + 宇宙小调
  edm_cosmic_major: [:c4, :d4, :e4, :g4, :a4],       # EDM + 宇宙大调
  edm_cosmic_progressive: [:a3, :c4, :eb4, :f4, :g4] # Progressive House风格
}

# === 数学常数音程映射（扩展）===
MATHEMATICAL_INTERVALS = {
  pi: [0, 3, 7, 10, 14],          # 增加更多音程
  golden: [0, 2, 5, 8, 11],       
  e: [0, 4, 7, 11, 15],
  sqrt2: [0, 2, 6, 9, 12],
  sqrt3: [0, 3, 6, 10, 13],
  hubble: [0, 5, 10, 15],
  fine: [0, 7, 2, 9, 14],
  euler: [0, 5, 7, 12, 16],
  planck: [0, 1, 4, 8, 11],
  catalan: [0, 4, 8, 11, 15]
}

# === EDM风格演化系统 ===
EDM_STYLES = {
  classic_house: { bpm: 124, synths: [:tb303, :saw], fx_intensity: 0.3 },
  progressive: { bpm: 126, synths: [:fm, :pulse], fx_intensity: 0.5 },
  cosmic_trance: { bpm: 128, synths: [:hollow, :blade], fx_intensity: 0.7 },
  mathematical_ambient: { bpm: 70, synths: [:sine, :dark_ambience], fx_intensity: 0.9 }
}

# === 演化阶段定义（扩展）===
EVOLUTION_STAGES = {
  pure_edm: (0..40),
  cosmic_introduction: (41..80),
  mathematical_emergence: (81..160), 
  style_morphing: (161..240),
  full_complexity: (241..320),
  transcendence: (321..Float::INFINITY)
}

# === 配置 ===
use_bpm 124
use_random_seed 113
use_debug false

# === 核心函数库 ===

# 优化的数学随机生成器（带缓存）
define :math_rand do |min, max, constant = :pi, offset = 0|
  cache_key = "#{constant}_#{(@evolution_tick + offset) / 5}"  # 每5tick更新缓存
  
  if @performance_cache[cache_key]
    return @performance_cache[cache_key]
  end
  
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :golden then GOLDEN_DIGITS
  when :e then E_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :sqrt3 then SQRT3_DIGITS
  when :euler then EULER_DIGITS
  when :planck then PLANCK_DIGITS
  when :hubble then HUBBLE_DIGITS
  when :fine then FINE_STRUCTURE
  when :catalan then CATALAN
  when :champer then CHAMPERNOWNE
  else PI_DIGITS
  end
  
  index = (@evolution_tick + offset) % digits.length
  digit = digits[index].to_i
  result = min + (digit / 9.0) * (max - min)
  
  @performance_cache[cache_key] = result
  
  # 清理缓存
  if @performance_cache.size > 50
    @performance_cache.shift(25)
  end
  
  result
end

# 智能演化控制
define :update_evolution do
  @evolution_tick += 1
  
  @complexity_level = case @evolution_tick
  when EVOLUTION_STAGES[:pure_edm] then 0
  when EVOLUTION_STAGES[:cosmic_introduction] then 1
  when EVOLUTION_STAGES[:mathematical_emergence] then 2
  when EVOLUTION_STAGES[:style_morphing] then 3
  when EVOLUTION_STAGES[:full_complexity] then 4
  when EVOLUTION_STAGES[:transcendence] then 5
  else 5
  end
  
  @current_cosmic_stage = @evolution_tick % 5
  @style_evolution_phase = (@evolution_tick / 80) % 4
  
  # 智能复杂度控制 - 防止过载
  if @total_amplitude > 3.0
    puts "🎛️  音量过载保护启动 - 降低复杂度"
    @complexity_level = [@complexity_level - 1, 0].max
  end
  
  # 用户体验 - 详细进度信息
  if @evolution_tick % 20 == 0
    stage_names = ["Pure EDM", "Cosmic Intro", "Math Emergence", "Style Morphing", "Full Complex", "Transcendence"]
    cosmic_names = ["Big Bang", "Galaxy Form", "Stellar Stable", "Stellar Death", "Heat Death"]
    style_names = ["Classic House", "Progressive", "Cosmic Trance", "Math Ambient"]
    
    puts "🎵 Evolution: #{@evolution_tick} | Stage: #{stage_names[@complexity_level]} | Cosmic: #{cosmic_names[@current_cosmic_stage]} | Style: #{style_names[@style_evolution_phase]}"
    puts "📊 Active Layers: #{@active_layers_count} | Total Amplitude: #{@total_amplitude.round(2)}"
  end
end

# 动态音量平衡系统
define :dynamic_amp_balance do |base_amp, layer_type = :normal|
  layer_weights = {
    kick: 3.0,      # 主要节拍
    bass: 2.5,      # 低频基础
    chord: 2.0,     # 和弦层
    lead: 1.5,      # 主旋律
    variation: 1.0, # 变异层
    ambient: 0.5    # 环境层
  }
  
  weight = layer_weights[layer_type] || 1.0
  active_weight_sum = @active_layers_count > 0 ? Math.sqrt(@active_layers_count) : 1
  
  balanced_amp = (base_amp * weight) / active_weight_sum
  
  # 根据复杂度调整
  complexity_factor = case @complexity_level
  when 0..1 then 1.2    # 早期提高音量
  when 2..3 then 1.0    # 中期保持
  when 4..5 then 0.8    # 后期降低防止过载
  else 0.7
  end
  
  final_amp = balanced_amp * complexity_factor
  @total_amplitude += final_amp
  final_amp
end

# 宇宙谐波音阶获取（智能选择）
define :get_cosmic_scale do |force_stage = nil|
  stage = force_stage || @current_cosmic_stage
  
  if @complexity_level <= 1
    # 早期使用EDM友好的宇宙音阶
    case stage % 3
    when 0 then COSMIC_HARMONIC_SCALES[:edm_cosmic_minor]
    when 1 then COSMIC_HARMONIC_SCALES[:edm_cosmic_major]  
    when 2 then COSMIC_HARMONIC_SCALES[:stellar_stability]
    end
  else
    # 后期使用完整宇宙音阶
    case stage
    when 0 then COSMIC_HARMONIC_SCALES[:big_bang]
    when 1 then COSMIC_HARMONIC_SCALES[:galaxy_formation]
    when 2 then COSMIC_HARMONIC_SCALES[:stellar_stability]
    when 3 then COSMIC_HARMONIC_SCALES[:stellar_death]
    when 4 then COSMIC_HARMONIC_SCALES[:heat_death]
    end
  end
end

# 数学音阶生成（增强版）
define :generate_math_scale do |base_note, constant = :golden|
  intervals = MATHEMATICAL_INTERVALS[constant] || MATHEMATICAL_INTERVALS[:golden]
  base_notes = intervals.map { |interval| note(base_note) + interval }
  
  # 根据常数特性变换音阶
  case constant
  when :pi
    # π: 圆周率，循环性
    base_notes.rotate((@evolution_tick * 3) % base_notes.length)
  when :golden
    # 黄金比例: 美学分割
    phi_point = (base_notes.length * 0.618).to_i
    base_notes.take(phi_point) + base_notes.drop(phi_point).reverse
  when :e
    # 自然对数: 增长性
    base_notes.sort_by.with_index { |note, i| note + i * 0.1 }
  when :sqrt2
    # 根号2: 对称性
    base_notes.reverse
  when :planck
    # 普朗克常数: 量子化
    base_notes.map { |note| (note / 12).round * 12 }
  else
    base_notes
  end
end

# 智能激活概率
define :smart_activation do |base_threshold, complexity_boost = true|
  # 基础阈值随时间降低
  time_factor = 1.0 - (@evolution_tick * 0.002)
  
  # 复杂度加成
  complexity_factor = complexity_boost ? (1.0 + @complexity_level * 0.1) : 1.0
  
  # 音量平衡因子
  volume_factor = @total_amplitude > 2.0 ? 0.7 : 1.0
  
  threshold = base_threshold * time_factor * volume_factor
  activation_value = math_rand(0, 1, :golden, @evolution_tick)
  
  activation_value > [threshold, 0.05].max
end

# 风格演化系统
define :apply_style_evolution do
  current_style = EDM_STYLES.values[@style_evolution_phase]
  
  # 动态BPM调整
  if @evolution_tick % 80 == 0 && @complexity_level >= 3
    target_bpm = current_style[:bpm]
    puts "🎼 风格演化: BPM → #{target_bpm}"
    # use_bpm target_bpm  # 注释掉避免突然变化
  end
  
  current_style
end

# === EDM主干结构（带智能平衡）===

live_loop :master_clock do
  @active_layers_count = 0
  @total_amplitude = 0.0
  sleep 0.25
  update_evolution
  apply_style_evolution
  sleep 0.75
end

live_loop :kick_drum, sync: :master_clock do
  @active_layers_count += 1
  amp = dynamic_amp_balance(1.2, :kick)
  sample :bd_haus, amp: amp
  sleep 1
end

live_loop :hihat, sync: :master_clock do
  if @complexity_level >= 0  # 总是激活
    @active_layers_count += 1
    base_amp = 0.6
    variation_amp = @complexity_level >= 1 ? math_rand(0.8, 1.2, :pi, @evolution_tick) : 1.0
    final_amp = dynamic_amp_balance(base_amp * variation_amp, :normal)
    
    sleep 0.5
    sample :drum_cymbal_closed, amp: final_amp
    sleep 0.5
  else
    sleep 1
  end
end

live_loop :snare, sync: :master_clock do
  @active_layers_count += 1
  base_amp = 0.8
  variation_amp = @complexity_level >= 1 ? math_rand(0.9, 1.1, :e, @evolution_tick) : 1.0
  final_amp = dynamic_amp_balance(base_amp * variation_amp, :normal)
  
  sleep 1
  sample :drum_snare_hard, amp: final_amp
  sleep 1
end

live_loop :bass_line, sync: :master_clock do
  @active_layers_count += 1
  
  current_style = apply_style_evolution
  use_synth current_style[:synths][0]
  
  # 宇宙音阶驱动的bass line
  cosmic_scale = get_cosmic_scale
  bass_scale = cosmic_scale.map { |n| note(n) - 24 }  # 降两个八度
  
  bass_progression = case @complexity_level
  when 0..1 then [:a1, :a1, :f1, :c2]  # 经典house
  when 2..3 then bass_scale.take(4)     # 宇宙音阶  
  else bass_scale.shuffle.take(4)       # 数学随机
  end
  
  note_to_play = bass_progression.tick
  
  # 数学驱动的参数调制
  cutoff_mod = @complexity_level > 0 ? 
    70 + math_rand(-15, 25, :pi, @evolution_tick) : 70
  
  amp = dynamic_amp_balance(0.9, :bass)
  
  use_synth_defaults release: 0.3, cutoff: cutoff_mod, res: 0.8, amp: amp
  play note_to_play
  sleep 0.5
end

live_loop :cosmic_chord_progression, sync: :master_clock do
  @active_layers_count += 1
  
  current_style = apply_style_evolution
  use_synth current_style[:synths][1]
  
  cosmic_scale = get_cosmic_scale
  
  # 智能和弦构建
  chord_types = [:minor, :major, :minor7, :major7, :sus2, :sus4]
  base_chords = case @complexity_level
  when 0..1
    # 经典进行
    [chord(:a3, :minor), chord(:f3, :major), chord(:c4, :major), chord(:g3, :major)]
  when 2..3
    # 宇宙和弦
    cosmic_scale.map { |root| chord(root, chord_types.sample) }
  else
    # 数学生成和弦
    math_scale = generate_math_scale(:c4, [:pi, :golden, :e].sample)
    math_scale.map { |root| chord(root, chord_types.sample) }
  end
  
  current_chord = base_chords.tick
  
  # 黄金比例扩展
  if @complexity_level >= 3 && smart_activation(0.6)
    extension_notes = cosmic_scale.sample(
      (math_rand(1, 3, :golden, @evolution_tick)).to_i
    )
    current_chord = (current_chord + extension_notes).uniq
  end
  
  amp = dynamic_amp_balance(0.4, :chord)
  fx_intensity = current_style[:fx_intensity] * (@complexity_level + 1) / 6.0
  
  with_fx :reverb, room: 0.3 * fx_intensity, mix: 0.4 * fx_intensity do
    use_synth_defaults release: 3, cutoff: 90, amp: amp
    play current_chord
  end
  
  sleep 4
end

# === 数学驱动的演化层 ===

live_loop :cosmic_mathematical_leads, sync: :master_clock do
  if @complexity_level >= 2 && smart_activation(0.7)
    @active_layers_count += 1
    
    # 选择数学常数和宇宙阶段
    constants = [:pi, :golden, :e, :sqrt2, :euler, :planck]
    current_constant = constants[@evolution_tick % constants.length]
    
    # 生成数学音阶
    math_scale = generate_math_scale(:c5, current_constant)
    cosmic_scale = get_cosmic_scale
    
    # 融合数学和宇宙音阶
    fusion_scale = (math_scale + cosmic_scale).uniq.sort
    
    use_synth [:blade, :fm, :pulse, :sine].sample
    
    amp = dynamic_amp_balance(0.25, :lead)
    
    with_fx :lpf, cutoff: math_rand(70, 110, current_constant, @evolution_tick) do
      with_fx :echo, phase: 0.25, decay: 2, mix: 0.3 do
        (1..(@complexity_level + 1)).each do |i|
          note_to_play = fusion_scale[math_rand(0, fusion_scale.length - 1, current_constant, i).to_i]
          
          play note_to_play,
            amp: amp,
            release: math_rand(0.5, 2, current_constant, @evolution_tick + i),
            pan: math_rand(-0.7, 0.7, current_constant, @evolution_tick + i * 10),
            cutoff: math_rand(80, 120, current_constant, @evolution_tick + i * 5)
          
          sleep math_rand(0.5, 1.5, current_constant, i)
        end
      end
    end
  end
  
  sleep 4
end

live_loop :fibonacci_rhythms, sync: :master_clock do
  if @complexity_level >= 3 && smart_activation(0.6)
    @active_layers_count += 1
    
    # 斐波那契节拍
    fib_sequence = [1, 1, 2, 3, 5, 8]
    rhythm_pattern = fib_sequence.take(@complexity_level + 1)
    
    use_synth :beep
    amp = dynamic_amp_balance(0.2, :variation)
    
    rhythm_pattern.each do |beat_length|
      if smart_activation(0.8, false)
        cosmic_scale = get_cosmic_scale
        play cosmic_scale.sample,
          amp: amp,
          release: beat_length * 0.2,
          pan: math_rand(-0.5, 0.5, :golden, @evolution_tick)
      end
      sleep beat_length * 0.125
    end
  else
    sleep 2
  end
end

live_loop :ambient_cosmic_layer, sync: :master_clock do
  if @complexity_level >= 1 && smart_activation(0.8)
    @active_layers_count += 1
    
    cosmic_scale = get_cosmic_scale
    amp = dynamic_amp_balance(0.15, :ambient)
    
    use_synth :dark_ambience
    
    # 宇宙环境音效
    with_fx :reverb, room: 0.8, mix: 0.6 do
      with_fx :echo, phase: 0.5, decay: 4 do
        play cosmic_scale.sample,
          amp: amp,
          attack: 2,
          release: 6,
          cutoff: math_rand(60, 90, :hubble, @evolution_tick),
          pan: Math.sin(@evolution_tick * 0.1) * 0.7
      end
    end
    
    # 随机宇宙采样
    if smart_activation(0.5, false)
      at math_rand(2, 6, :catalan, @evolution_tick) do
        sample :ambi_soft_buzz, 
          amp: amp * 0.7,
          rate: math_rand(0.5, 1.5, :planck, @evolution_tick),
          pan: math_rand(-0.8, 0.8, :fine, @evolution_tick)
      end
    end
  end
  
  sleep 8
end

live_loop :transcendence_layer, sync: :master_clock do
  if @complexity_level >= 5 && smart_activation(0.4)
    @active_layers_count += 1
    
    puts "🌌 进入超越层..."
    
    # 多常数融合
    pi_factor = math_rand(0.7, 1.3, :pi, @evolution_tick)
    golden_factor = math_rand(0.8, 1.2, :golden, @evolution_tick + 10)
    e_factor = math_rand(0.9, 1.1, :e, @evolution_tick + 20)
    
    # 终极音阶融合
    cosmic_scale = get_cosmic_scale
    pi_scale = generate_math_scale(:c4, :pi)
    golden_scale = generate_math_scale(:e4, :golden)
    
    transcendence_scale = (cosmic_scale + pi_scale + golden_scale).uniq
    
    amp = dynamic_amp_balance(0.3, :lead)
    
    use_synth :hollow
    with_fx :reverb, room: 0.9, mix: 0.8 do
      with_fx :echo, phase: 0.375, decay: 6 do
        transcendence_scale.take(3).each_with_index do |note, i|
          play note + (i * 12),  # 八度叠加
            amp: amp * [pi_factor, golden_factor, e_factor][i],
            attack: 1 + i,
            release: 4 + i * 2,
            cutoff: 60 + i * 20,
            pan: [-0.8, 0, 0.8][i]
          
          sleep 2
        end
      end
    end
  end
  
  sleep 12
end

# 最终状态显示
live_loop :evolution_monitor, sync: :master_clock do
  sleep 10
  
  if @evolution_tick % 100 == 0
    puts "=" * 50
    puts "🎵 演化EDM状态报告"
    puts "进化代数: #{@evolution_tick}"
    puts "复杂度等级: #{@complexity_level}/5"
    puts "宇宙阶段: #{@current_cosmic_stage}"  
    puts "风格相位: #{@style_evolution_phase}"
    puts "活跃层数: #{@active_layers_count}"
    puts "总音量: #{@total_amplitude.round(2)}"
    puts "缓存大小: #{@performance_cache.size}"
    puts "=" * 50
  end
end