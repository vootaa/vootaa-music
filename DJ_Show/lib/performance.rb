module Performance
  class Conductor
    attr_reader :math, :energy_system, :patterns, :scales, :volume_ctrl, :cycle_number
    
    def initialize(config)
      @config = config
      @math = MathEngine.new(config)
      @energy_system = EnergyCurve.new(config[:cycle_length], config[:golden_ratio])
      @patterns = DrummerPatterns.new
      @scales = ScaleModes.new
      @volume_ctrl = VolumeController.new(@energy_system, @math, config[:cycle_length])
      @performance_start = Time.now
      @previous_energy = 0.0
      @cycle_number = 0
      
      # 用于减少日志输出的计数器
      @pattern_select_count = 0
      @melody_select_count = 0
    end
    
    def config(key)
      @config[key]
    end
    
    def current_energy
      elapsed = Time.now - @performance_start
      @energy_system.calculate(elapsed)
    end
    
    # ============================================================
    # LOOP METHODS
    # ============================================================
    
    # 获取 Loop Start 模式（从配置中选择）
    def get_loop_start_pattern
      patterns = @config[:loop_start_patterns]
      pattern_keys = patterns.keys
      
      # 使用黄金比例序列选择模式
      pattern_idx = @math.get_next(:golden) % pattern_keys.length
      selected_key = pattern_keys[pattern_idx]
      
      if @config[:debug_mode]
        @pattern_select_count += 1
        if @pattern_select_count % 10 == 0
          puts "🔀 Loop Pattern: #{selected_key}"
        end
      end
      
      patterns[selected_key]
    end
    
    # 获取 Loop 速率
    def get_loop_rate
      rates = @config[:loop_rates]
      rate_idx = @math.get_next(:sqrt2) % rates.length
      rates[rate_idx]
    end
    
    # 获取 Loop 样本
    def get_loop_sample
      samples = @config[:loop_samples]
      sample_idx = @math.get_next(:pi) % samples.length
      samples[sample_idx]
    end
    
    # 获取 Loop Beat Stretch
    def get_loop_beat_stretch
      stretches = @config[:loop_beat_stretches]
      stretch_idx = @math.get_next(:e) % stretches.length
      stretches[stretch_idx]
    end
    
    # ============================================================
    # MELODY METHODS
    # ============================================================
    
    # 获取旋律音阶
    def get_scale_for_melody
      mode_name = @scales.get_mode(@energy_curve.current_energy)
      @scales.get_scale(mode_name)
    end
    
    # 生成旋律短语
    def generate_melody_phrase(scale_notes, phrase_len)
      phrase = []
      rhythm_pattern = get_melody_rhythm
      
      phrase_len.times do |i|
        note_idx = @math.get_next(:e) % scale_notes.length
        duration = rhythm_pattern[i % rhythm_pattern.length]
        
        phrase << {
          note: scale_notes[note_idx],
          duration: duration
        }
      end
      
      phrase
    end
    
    # 根据能量选择乐器
    def get_instrument_for_energy(energy)
      case energy
      when 0.0...0.3 then :kalimba
      when 0.3...0.5 then [:kalimba, :piano].choose
      when 0.5...0.7 then :piano
      when 0.7...0.9 then [:piano, :pretty_bell].choose
      else :pretty_bell
      end
    end
    
    # 获取旋律音符范围
    def get_note_range_for_instrument(instrument)
      @config[:melody_note_ranges][instrument] || (60..72)
    end
    
    # 获取旋律节奏模式
    def get_melody_rhythm
      patterns = @config[:melody_rhythm_patterns]
      idx = @math.get_next(:e) % patterns.length
      patterns[idx]
    end
    
    # 获取旋律短语长度
    def get_melody_phrase_length
      lengths = @config[:melody_phrase_lengths]
      idx = @math.get_next(:golden) % lengths.length
      lengths[idx]
    end
    
    # ============================================================
    # DRUMMER METHODS
    # ============================================================
    
    # 获取鼓手模式
    def get_drum_pattern(drummer_id)
      pattern_index = @math.get_next(:phi).abs % @patterns.pattern_count(drummer_id)
      @patterns.get_pattern(drummer_id, pattern_index)
    end
    
    # 判断鼓手是否应该演奏
    def should_play_drummer?(drummer_id, energy)
      # 获取当前能量等级允许的最大鼓手数
      max_drummers = get_max_drummers_for_energy(energy)
      
      # 能量太低时只保留脉冲
      return false if max_drummers == 0
      
      # 使用 E 序列决定哪些鼓手活跃
      e_val = @math.get_next(:e)
      drummer_index = {'A'=>0, 'B'=>1, 'C'=>2, 'D'=>3}[drummer_id]
      
      # 能量 > 0.9 允许 3 位鼓手
      if energy > 0.9
        return drummer_index < 3
      # 能量 0.6-0.9 允许 2 位鼓手重叠
      elsif energy > 0.6
        return (e_val % 3 == drummer_index % 3) && (drummer_index < 2)
      # 低能量：单鼓手或 2 鼓手交替
      else
        return (e_val % 4 == drummer_index) && (drummer_index < max_drummers)
      end
    end
    
    # ============================================================
    # FILL METHODS
    # ============================================================
    
    # 判断是否应该触发 Fill
    def should_trigger_fill?(energy)
      delta = (energy - @previous_energy).abs
      @previous_energy = energy
      
      # 只在能量剧变时触发
      delta > @config[:fill_threshold] && energy > 0.5
    end
    
    # 获取 Fill 类型
    def get_fill_type
      fill_types = @config[:fill_types].keys
      type_idx = @math.get_next(:sqrt2) % fill_types.length
      fill_types[type_idx]
    end
    
    # 获取 Fill 配置
    def get_fill_config(fill_type)
      @config[:fill_types][fill_type]
    end
    
    # ============================================================
    # AMBIENT METHODS
    # ============================================================
    
    # 获取环境音样本
    def get_ambient_sample
      samples = @config[:ambient_samples]
      idx = @math.get_next(:golden) % samples.length
      samples[idx]
    end
    
    # 获取环境音速率
    def get_ambient_rate
      range = @config[:ambient_rate_range]
      range.min + (@math.get_next(:sqrt2) % 100) / 100.0 * (range.max - range.min)
    end
    
    # ============================================================
    # ENERGY METHODS
    # ============================================================
    
    # 根据能量获取允许的最大鼓手数
    def get_max_drummers_for_energy(energy)
      category = @config[:energy_categories].find { |c| c[:range].include?(energy) }
      category ? category[:max_drummers] : 1
    end
    
    # 获取能量分类名称
    def get_energy_category_name(energy)
      category = @config[:energy_categories].find { |c| c[:range].include?(energy) }
      category ? category[:name] : "Unknown"
    end
    
    # ============================================================
    # PAN METHODS
    # ============================================================
    
    # 获取声像位置
    def get_pan_value(constant_type)
      value = @math.get_next(constant_type)
      @math.map_to_range(value, -0.8, 0.8)
    end
  end
end