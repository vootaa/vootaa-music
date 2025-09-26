# 宇宙回响：远古星系的冥想之音（简化氛围版本）
# 主干：可听性太空氛围（和谐和弦、reverb、ambient sample）
# 扩展：数学常数驱动多样性（pan、rate、cutoff）

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

# 全局索引跟踪（确保常数顺序读取）
@indices = {pi: 0, e: 0, golden: 0}

# 宇宙音阶（用于相似性和谐）
COSMIC_SCALES = [:c4, :d4, :e4, :f4, :g4, :a4, :b4]

# 数学驱动随机函数（从常数小数位生成值）
define :cosmic_rand do |min, max, constant = :pi|
  digits = case constant
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :golden then GOLDEN_DIGITS
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

# 主效果链：太空回响氛围
with_fx :reverb, room: 0.7 do
  # 主干氛围层：和谐和弦垫
  live_loop :ambient_pad do
    use_synth :hollow
    chord_note = COSMIC_SCALES.choose  # 相似性：固定音阶选择
    play chord(chord_note, :minor), amp: 0.3, attack: 2, release: 4
    sleep 8
  end

  # 主干扩展层：太空回响sample
  live_loop :cosmic_echo, sync: :ambient_pad do
    sample :ambi_glass_hum, amp: 0.2, rate: 0.5, pan: cosmic_rand(-1, 1, :golden)  # 扩展：数学驱动pan（模拟星系螺旋）
    sleep 16
  end

  # 节奏主干层：数学间隔驱动beat
  live_loop :math_driven_beat, sync: :ambient_pad do
    intervals = [1, 1, 2, 3, 5].map { |x| x * 0.25 }  # 简化斐波那契间隔
    intervals.each do |int|
      use_synth :bass_foundation
      play :c2, amp: 0.4, release: 0.5, rate: cosmic_rand(0.8, 1.2, :pi)  # 扩展：数学rate变奏（模拟宇宙扩张）
      sleep int
    end
  end

  # 扩展变奏层：调制丰富性
  live_loop :variation_layer, sync: :ambient_pad do
    sleep 4
    amps = golden_split(0.2)  # 数学辅助比例分割
    play :e4, amp: amps[0], release: 2, cutoff: cosmic_rand(60, 100, :e)  # 扩展：常数驱动cutoff（量子调制）
    sleep 2
    play :g4, amp: amps[1], release: 2
    sleep 2
  end
end