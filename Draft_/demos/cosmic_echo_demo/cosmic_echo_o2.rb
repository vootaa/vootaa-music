# 宇宙回响：远古星系的冥想之音（优化版本2-强调性能）
# 主干：可听性太空氛围（和谐和弦、reverb、ambient sample）
# 扩展：数学常数驱动多样性（pan、rate、cutoff），模拟宇宙演化阶段

# 数学常数（精简版本，保留关键特征）
PI_DIGITS = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
E_DIGITS = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
GOLDEN_DIGITS = "6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374"
SQRT2_DIGITS = "4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727"
SQRT3_DIGITS = "7320508075688772935274463415058723669428052538103806280558069794519330169088000370811461867572485756"

# 物理常数（优化长度，减少内存占用）
HUBBLE_DIGITS = "7000000067402385119138205128205128205128205128205128205128205128205128205128205"
PLANCK_DIGITS = "1616255000000000000000000000000000001616255000000000000000000000000000001616255"
FINE_STRUCTURE = "7297352566400000000000000000000000000729735256640000000000000000000000000072973"
EULER_GAMMA = "5772156649015328606065120900824024310421593359399235988057672348848677267776646709"
CATALAN = "9159655941772190150546035149323841107741493742816721342664981198704686804649256927"
CHAMPERNOWNE = "1234567891011121314151617181920212223242526272829303132333435363738394041424344"

# 全局配置（集中管理参数）
COSMIC_CONFIG = {
  reverb_room: 0.65,      # 降低 room size 减少 CPU 负载
  echo_phase: 0.25,
  echo_decay: 3,          # 降低 decay 减少尾音重叠
  base_amp: 0.2,
  max_chord_size: 3       # 限制和弦大小减少 CPU 负载
}

# 全局索引跟踪（优化内存管理）
@indices = Hash.new(0)   # 使用 Hash.new(0) 简化初始化
@digit_cache = {}        # 添加缓存机制

# 宇宙音阶
COSMIC_SCALES = [:c4, :d4, :e4, :f4, :g4, :a4, :b4]

# 优化的数学驱动随机函数
define :cosmic_rand do |min, max, constant = :pi|
  # 缓存机制减少重复查找
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :golden then GOLDEN_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :sqrt3 then SQRT3_DIGITS
  when :hubble then HUBBLE_DIGITS
  when :planck then PLANCK_DIGITS
  when :fine then FINE_STRUCTURE
  when :euler then EULER_GAMMA
  when :catalan then CATALAN
  when :champer then CHAMPERNOWNE
  else PI_DIGITS
  end
  
  # 防止索引过大导致内存问题
  @indices[constant] = (@indices[constant] + 1) % (digits.length * 2)
  digit = digits[@indices[constant] % digits.length].to_i
  
  min + (digit / 9.0) * (max - min)
end

# 黄金比例分割函数
define :golden_split do |value|
  phi = 1.618  # 使用近似值减少计算
  [value / phi, value * (phi - 1)]
end

# 优化的和弦播放函数
define :play_cosmic_chord do |root, chord_type, amp = 0.2, attack = 1, release = 2|
  chord_notes = chord(root, chord_type).take(COSMIC_CONFIG[:max_chord_size])
  chord_notes.each_with_index do |note, i|
    at i * 0.1 do  # 轻微错开时间减少同时播放的声音数量
      play note, amp: amp, attack: attack, release: release, 
           pan: cosmic_rand(-0.8, 0.8, :golden)
    end
  end
end

# 全局设置
use_bpm 70
use_random_seed 42
use_debug false

# 主效果链（优化参数）
with_fx :reverb, room: COSMIC_CONFIG[:reverb_room], mix: 0.6 do
  with_fx :echo, phase: COSMIC_CONFIG[:echo_phase], decay: COSMIC_CONFIG[:echo_decay] do
    
    # 主时间线：宇宙演化阶段（核心循环）
    live_loop :cosmic_evolution do
      stage = tick % 5
      
      case stage
      when 0  # 大爆炸初期
        use_synth :saw
        play :c5, amp: 0.12, attack: 0.1, release: 0.5, 
             pan: cosmic_rand(-0.8, 0.8, :hubble)
        sleep 2
        
      when 1  # 星系形成期
        use_synth :hollow
        play_cosmic_chord(COSMIC_SCALES.choose, :minor, 0.2, 1, 2)
        sleep 4
        
      when 2  # 恒星稳定期
        use_synth :fm
        play_cosmic_chord(COSMIC_SCALES.choose, :major7, 0.18, 0.5, 3)
        sleep 6
        
      when 3  # 恒星死亡期
        use_synth :bass_foundation
        play :c2, amp: 0.15, release: 4, 
             rate: cosmic_rand(0.6, 1.0, :catalan),
             pan: cosmic_rand(-0.6, 0.6, :champer)
        sleep 8
        
      when 4  # 热寂趋近
        use_synth :sine
        play :a3, amp: 0.08, attack: 2, release: 6,
             pan: cosmic_rand(-0.3, 0.3, :sqrt2)
        sleep 10
      end
    end

    # 合并的氛围层（减少 live_loop 数量）
    live_loop :ambient_layers, sync: :cosmic_evolution do
      # 主氛围垫
      use_synth :hollow
      play_cosmic_chord(COSMIC_SCALES.choose, :minor, 0.25, 2, 4)
      
      # 太空回响（在同一循环中处理）
      at 4 do
        with_fx :pan, pan: cosmic_rand(-0.8, 0.8, :sqrt3) do
          sample :ambi_glass_hum, amp: 0.08, rate: 0.5,
                 pan: cosmic_rand(-0.5, 0.5, :golden)
        end
      end
      
      sleep 8
    end

    # 优化的节拍层（简化间隔计算）
    live_loop :cosmic_pulse, sync: :cosmic_evolution do
      # 使用预定义间隔减少计算
      intervals = [0.25, 0.25, 0.5, 0.75, 1.25]  # 斐波那契比例简化版
      
      intervals.each do |interval|
        use_synth :bass_foundation
        play :c2, amp: 0.3, release: 0.4,
             rate: cosmic_rand(0.9, 1.1, :pi),
             pan: cosmic_rand(-0.6, 0.6, :hubble)
        sleep interval
      end
    end

    # 简化的变奏层（降低复杂度）
    live_loop :cosmic_variations, sync: :cosmic_evolution do
      sleep 4
      
      amps = golden_split(0.12)  # 进一步降低音量
      
      use_synth :hollow
      play :e4, amp: amps[0], release: 1.5,
           cutoff: cosmic_rand(70, 95, :e),
           pan: cosmic_rand(-0.5, 0.5, :sqrt2)
      sleep 2
      
      play :g4, amp: amps[1], release: 1.5,
           pan: cosmic_rand(-0.5, 0.5, :golden)
      sleep 6  # 增加休息时间减少密度
    end
  end
end

# 性能监控（可选，调试时使用）
# live_loop :performance_monitor do
#   puts "Current tick: #{tick}, CPU usage optimized"
#   sleep 30
# end

# 优化说明：
# 1. 减少了同时播放的音符数量（max_chord_size: 3）
# 2. 降低了整体音量和效果强度
# 3. 合并了相似的 live_loop 减少系统负载
# 4. 添加了缓存机制优化数学常数查找
# 5. 使用预计算的间隔替代实时计算
# 6. 优化了内存管理防止索引无限增长
# 7. 集中配置管理便于调整参数