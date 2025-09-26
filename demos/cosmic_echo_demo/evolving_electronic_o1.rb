# 演化电子音乐优化版：主干固定（音乐性优先），辅助数学装饰（特性花色）
# 优化：平衡音量（整体提升鼓点和贝斯，微调和弦和变异），添加wobble/slicer效果，提升和谐性，使用:dsaw/:tech_saws合成器，添加invert和弦倒置。

# 数学常数定义（辅助元素，用于生成变异）
PI_DIGITS = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
E_DIGITS = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
GOLDEN_DIGITS = "6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374"
SQRT2_DIGITS = "4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727"
HUBBLE_DIGITS = "7000000067402385119138205128205128205128205128205128205128205128205128205128205"
PLANCK_DIGITS = "1616255000000000000000000000000000001616255000000000000000000000000000001616255"
FINE_STRUCTURE = "7297352566400000000000000000000000000729735256640000000000000000000000000072973"
EULER_GAMMA = "5772156649015328606065120900824024310421593359399235988057672348848677267776646709"
CATALAN = "9159655941772190150546035149323841107741493742816721342664981198704686804649256927"
CHAMPERNOWNE = "1234567891011121314151617181920212223242526272829303132333435363738394041424344"

# 风格配置（主干基础）
ELECTRONIC_STYLE = :algorithmic_techno  # 可切换: :algorithmic_techno, :quantum_wave, :fractal_rhythm, :soulful, :techno, :ambient

ELECTRONIC_CONFIG = case ELECTRONIC_STYLE
when :algorithmic_techno then {room: 0.4, phase: 0.2, decay: 4, amp: 0.25, max: 3, synth: :dsaw, chord: :minor, bpm: 128, fx: :distortion}  # 改为:dsaw，提升DeepHouse感
when :quantum_wave then {room: 0.3, phase: 0.1, decay: 2, amp: 0.2, max: 4, synth: :fm, chord: :major, bpm: 110, fx: :reverb}
when :fractal_rhythm then {room: 0.5, phase: 0.3, decay: 3, amp: 0.15, max: 5, synth: :saw, chord: :minor7, bpm: 120, fx: :echo}
when :soulful then {room: 0.6, phase: 0.25, decay: 3, amp: 0.2, max: 4, synth: :fm, chord: :minor7, bpm: 120, fx: :reverb}
when :techno then {room: 0.3, phase: 0.1, decay: 1, amp: 0.3, max: 3, synth: :tb303, chord: :minor, bpm: 130, fx: :lpf}
when :ambient then {room: 0.8, phase: 0.3, decay: 4, amp: 0.15, max: 5, synth: :saw, chord: :major7, bpm: 110, fx: :echo}
else {room: 0.5, phase: 0.2, decay: 2, amp: 0.2, max: 4, synth: :fm, chord: :minor7, bpm: 120, fx: :reverb}
end

# 主干：预定义结构（固定节奏、和弦进行）
ELECTRONIC_CHORD_PROGRESSION = {intro: [:c4, :f4, :g4], build: [:c4, :eb4, :g4, :bb4], drop: [:c4, :d4, :f4, :g4], breakdown: [:c4, :gb4, :a4], outro: [:c4, :f4, :bb4]}
DRUM_PATTERNS = {basic: [1, 0, 0, 0, 0, 0, 1, 0], fill: [1, 0, 1, 0, 0, 1, 1, 0]}  # 4/4固定模式
STAGE_NAMES = [:intro, :build, :drop, :breakdown, :outro]  # 全局常量，供所有live_loop使用

# 辅助：数学随机生成器
@indices = Hash.new(0)
@digit_cache = {}

define :electronic_rand do |min, max, constant=:pi, tick_offset=0|
  digits = @digit_cache[constant] ||= case constant
  when :pi then PI_DIGITS
  when :e then E_DIGITS
  when :golden then GOLDEN_DIGITS
  when :sqrt2 then SQRT2_DIGITS
  when :hubble then HUBBLE_DIGITS
  when :planck then PLANCK_DIGITS
  when :fine then FINE_STRUCTURE
  when :euler then EULER_GAMMA
  when :catalan then CATALAN
  when :champer then CHAMPERNOWNE
  else PI_DIGITS
  end
  @indices[constant] = (@indices[constant] + 1 + tick_offset) % (digits.length * 2)
  digit = digits[@indices[constant] % digits.length].to_i
  min + (digit / 9.0) * (max - min)
end

# 辅助：和弦播放函数（固定结构 + 数学微调 + DeepHouse技巧：invert和弦倒置，wobble效果）
define :play_electronic_chord do |chord_scale, amp=0.2, attack=0.5, release=1.5, tick_offset=0|
  root = chord_scale.choose
  chord_notes = chord(root, ELECTRONIC_CONFIG[:chord], invert: electronic_rand(0, 2, :golden, tick_offset).to_i).take(ELECTRONIC_CONFIG[:max])  # 添加invert倒置，提升和谐
  chord_notes.each_with_index do |note, i|
    at i * 0.25 do
      with_fx :wobble, phase: 2, mix: 0.2, wave: 0 do  # 添加wobble效果，参考DeepHouse
        play note + electronic_rand(-0.5, 0.5, :golden, tick_offset), amp: amp, attack: attack, release: release, pan: electronic_rand(-0.3, 0.3, :hubble, tick_offset)
      end
    end
  end
end

# 设置全局（主干）
use_bpm ELECTRONIC_CONFIG[:bpm]
use_random_seed 113
use_debug false

# 效果链（主干固定，辅助微调参数 + 添加slicer效果）
with_fx :reverb, room: ELECTRONIC_CONFIG[:room], mix: 0.5 do
  with_fx :echo, phase: ELECTRONIC_CONFIG[:phase], decay: ELECTRONIC_CONFIG[:decay] do
    with_fx ELECTRONIC_CONFIG[:fx], mix: 0.3 do
      with_fx :slicer, phase: 0.25, mix: 0.2 do  # 添加slicer效果，提升节奏感
      
        # 主干：旋律/和弦循环（固定4拍循环，数学微调音符 + 音量调整：amp从0.3调到0.4）
        live_loop :electronic_evolution do
          evolution_tick = tick
          stage = evolution_tick % 5
          current_stage = STAGE_NAMES[stage]  # 使用全局常量
          puts "电子演化阶段 #{current_stage} (tick: #{evolution_tick})"
          
          # 主干：固定和弦进行
          chord_root = ELECTRONIC_CHORD_PROGRESSION[current_stage][evolution_tick % ELECTRONIC_CHORD_PROGRESSION[current_stage].length]
          chord_notes = chord(chord_root, ELECTRONIC_CONFIG[:chord]).take(ELECTRONIC_CONFIG[:max])
          
          # 辅助：数学微调（±0.5半音）
          mutation = electronic_rand(-0.5, 0.5, :golden, evolution_tick)
          chord_notes = chord_notes.map { |n| n + mutation }
          
          use_synth ELECTRONIC_CONFIG[:synth]
          play chord_notes.choose, amp: 0.4, attack: 0.1, release: 1.0,  # 音量调高
            pan: electronic_rand(-0.3, 0.3, :hubble, evolution_tick),
            cutoff: 90 + electronic_rand(-10, 10, :planck, evolution_tick)
          
          sleep 4  # 主干：固定4拍（4/4节奏）
        end
        
        # 主干：鼓点（固定4/4模式，辅助偶尔变异 + 音量调整：kick从0.5调到0.7，snare从0.4调到0.6）
        live_loop :electronic_drums, sync: :electronic_evolution do
          evolution_tick = look
          pattern = DRUM_PATTERNS[:basic]  # 固定模式
          
          8.times do |i|
            sample :drum_bass_hard, amp: 0.7 if pattern[i] == 1  # 音量调高
            sample :drum_snare_hard, amp: 0.6 if (i % 4) == 2  # 音量调高
            
            # 辅助：数学偶尔添加变异（e.g., 每10 tick添加填充）
            if evolution_tick % 10 == 0 && electronic_rand(0, 1, :pi, evolution_tick) > 0.7
              sample :drum_cymbal_closed, amp: 0.3  # 音量调高
            end
            sleep 0.5  # 主干：固定半拍
          end
        end
        
        # 主干：arpeggio（固定节奏，辅助微调 + 音量调整：amp从0.15调到0.25）
        live_loop :electronic_arpeggios, sync: :electronic_evolution do
          evolution_tick = look
          chord_scale = ELECTRONIC_CHORD_PROGRESSION[STAGE_NAMES[evolution_tick % 5]]  # 使用全局常量
          use_synth :tech_saws  # 改为:tech_saws，提升DeepHouse感
          play_electronic_chord(chord_scale, 0.25, 0.05, 0.8, evolution_tick)  # 音量调高
          sleep 4  # 主干：固定4拍
        end
        
        # 主干：贝斯线（固定模式，辅助微调 + 音量调整：amp从0.4调到0.6）
        live_loop :electronic_bassline, sync: :electronic_evolution do
          evolution_tick = look
          bass_note = ELECTRONIC_CHORD_PROGRESSION[STAGE_NAMES[evolution_tick % 5]][evolution_tick % 3] - 12  # 使用全局常量
          use_synth ELECTRONIC_CONFIG[:synth]
          play bass_note, amp: 0.6, release: 1.5,  # 音量调高
            rate: 1.0 + electronic_rand(-0.1, 0.1, :pi, evolution_tick),  # 辅助：小幅rate变异
            pan: electronic_rand(-0.3, 0.3, :hubble, evolution_tick)
          sleep 2  # 主干：固定2拍
        end
        
        # 辅助：装饰变异（仅偶尔触发，作为“花色” + 音量调整：amp从0.1调到0.2）
        live_loop :electronic_variations, sync: :electronic_evolution do
          evolution_tick = look
          if electronic_rand(0, 1, :golden, evolution_tick) > 0.8  # 仅偶尔
            variation_note = :e3 + electronic_rand(-2, 2, :e, evolution_tick)
            use_synth :beep
            play variation_note, amp: 0.2, release: 1, cutoff: 80 + electronic_rand(-10, 10, :fine, evolution_tick)  # 音量调高
          end
          sleep 4  # 匹配主干
        end
      end
    end
  end
end