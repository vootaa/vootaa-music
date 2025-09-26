# 宇宙回响：远古星系的冥想之音（优化版本1）
# 主干：可听性太空氛围（和谐和弦、reverb、ambient sample）
# 扩展：数学常数驱动多样性（pan、rate、cutoff），模拟宇宙演化阶段

PI_DIGITS = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
E_DIGITS = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
GOLDEN_DIGITS = "6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374"
SQRT2_DIGITS = "4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727"
SQRT3_DIGITS = "7320508075688772935274463415058723669428052538103806280558069794519330169088000370811461867572485756"

# 物理常数（基于实际物理数值的小数部分）
HUBBLE_DIGITS = "7000000000000000000000000067402385119138205128205128205128205128205128205128205128205128205128205"  # 哈勃常数
PLANCK_DIGITS = "1616255000000000000000000000000000001616255000000000000000000000000000001616255000000000000000"   # 普朗克长度
FINE_STRUCTURE = "7297352566400000000000000000000000000729735256640000000000000000000000000072973525664000000000"  # 精细结构常数

EULER_GAMMA = "5772156649015328606065120900824024310421593359399235988057672348848677267776646709369470632917467495"  # 欧拉-马歇罗尼常数
CATALAN = "9159655941772190150546035149323841107741493742816721342664981198704686804649256927631966835244537071"     # 卡塔兰常数  
CHAMPERNOWNE = "1234567891011121314151617181920212223242526272829303132333435363738394041424344454647484950515253"   # 钱珀瑙恩常数

# 全局索引跟踪（扩展到所有常数）
@indices = {pi: 0, e: 0, golden: 0, sqrt2: 0, sqrt3: 0, hubble: 0, planck: 0, fine: 0, euler: 0, catalan: 0, champer: 0}

# 宇宙音阶（用于相似性和谐）
COSMIC_SCALES = [:c4, :d4, :e4, :f4, :g4, :a4, :b4]

# 数学驱动随机函数（扩展支持所有常数）
define :cosmic_rand do |min, max, constant = :pi|
  digits = case constant
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
  digit = digits[@indices[constant] % digits.length].to_i
  @indices[constant] += 1
  min + (digit / 9.0) * (max - min)
end

# 黄金比例分割函数（用于比例辅助）
define :golden_split do |value|
  phi = (1 + Math.sqrt(5)) / 2
  [value / phi, value * (phi - 1)]
end

# 全局设置
use_bpm 70
use_random_seed 42
use_debug false

# 主效果链：太空回响氛围（增强空间化）
with_fx :reverb, room: 0.7 do
  with_fx :echo, phase: 0.25, decay: 4 do
    # 主时间线：宇宙演化阶段（模拟星系生命周期）
    live_loop :cosmic_evolution do
      # 阶段计数器（循环通过阶段）
      stage = tick % 5  # 0: 大爆炸初期, 1: 星系形成, 2: 恒星稳定, 3: 恒星死亡, 4: 热寂趋近
      
      case stage
      when 0  # 大爆炸初期：高能、简洁动机
        use_synth :saw
        play :c5, amp: 0.15, attack: 0.1, release: 0.5, pan: cosmic_rand(-1, 1, :hubble) 
        sleep 2
      when 1  # 星系形成期：复杂度上升，声像扩展
        use_synth :hollow
        chord_notes = chord(COSMIC_SCALES.choose, :minor).take(2)  # 逐步增加和弦
        chord_notes.each do |note|
          play note, amp: 0.3, attack: 1, release: 2, pan: cosmic_rand(-0.5, 0.5, :planck)  # 扩展声像
        end
        sleep 4
      when 2  # 恒星稳定期：最高复杂度与和声密度
        use_synth :fm
        full_chord = chord(COSMIC_SCALES.choose, :major7)
        full_chord.each do |note|
          play note, amp: 0.25, attack: 0.5, release: 3, cutoff: cosmic_rand(70, 110, :fine), pan: cosmic_rand(-1, 1, :euler)  # 密集和声，自动化 pan
        end
        sleep 6
      when 3  # 恒星死亡期：能量衰减，纹理稀疏
        use_synth :bass_foundation
        play :c2, amp: 0.2, release: 4, rate: cosmic_rand(0.5, 1.0, :catalan), pan: cosmic_rand(-0.8, 0.8, :champer)  # 衰减能量，稀疏纹理
        sleep 8
      when 4  # 热寂趋近：回归静谧与尾音消散
        use_synth :sine
        play :a3, amp: 0.1, attack: 2, release: 8, pan: cosmic_rand(-0.2, 0.2, :sqrt2)  # 静谧尾音
        sleep 10
      end
    end

    # 主干氛围层：和谐和弦垫（同步到演化）
    live_loop :ambient_pad, sync: :cosmic_evolution do
      use_synth :hollow
      chord_note = COSMIC_SCALES.choose
      play chord(chord_note, :minor), amp: 0.3, attack: 2, release: 4, pan: cosmic_rand(-0.5, 0.5, :golden)  # 螺旋声像
      sleep 8
    end

    # 主干扩展层：太空回响sample（降低音量，增强 panning）
    live_loop :cosmic_echo, sync: :cosmic_evolution do
      with_fx :pan, pan: cosmic_rand(-1, 1, :sqrt3), pan_slide: cosmic_rand(2, 5, :pi) do |p|  # 自动化 panning 模拟粒子流，从左到右移动
        sample :ambi_glass_hum, amp: 0.1, rate: 0.5, pan: cosmic_rand(-1, 1, :golden)  # 降低 amp
        control p, pan: cosmic_rand(-1, 1, :e)  # 旋转声像
      end
      sleep 16
    end

    # 节奏主干层：数学间隔驱动beat（脉冲星模拟）
    live_loop :math_driven_beat, sync: :cosmic_evolution do
      intervals = [1, 1, 2, 3, 5].map { |x| x * 0.25 }
      intervals.each do |int|
        use_synth :bass_foundation
        play :c2, amp: 0.4, release: 0.5, rate: cosmic_rand(0.8, 1.2, :pi), pan: cosmic_rand(-1, 1, :hubble)  # 短促脉冲
        sleep int
      end
    end

    # 扩展变奏层：调制丰富性（螺旋星系，降低音量，增强移动）
    live_loop :variation_layer, sync: :cosmic_evolution do
      sleep 4
      amps = golden_split(0.15)  # 降低总 amp，使用黄金比例分割，并动态调整。
      with_fx :pan, pan: cosmic_rand(-1, 1, :sqrt2), pan_slide: cosmic_rand(3, 6, :e) do |p|  # 缓慢旋转，从左到右
        play :e4, amp: amps[0], release: 2, cutoff: cosmic_rand(60, 100, :e)
        sleep 2
        play :g4, amp: amps[1], release: 2
        sleep 2
        control p, pan: cosmic_rand(-1, 1, :golden)  # 连续移动
      end
    end
  end
end