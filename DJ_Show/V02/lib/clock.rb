# 母时钟：全局节拍同步、小节计数、章节切换信号

module Clock
  @@bar_count = 0
  @@current_chapter = :ch1
  @@running = false
  
  # 初始化时钟
  def self.init
    set :global_bar, 0
    set :current_chapter, :ch1
    set :clock_running, true
    @@running = true
  end
  
  # 启动母时钟
  def self.start
    live_loop :master_clock do
      # 每小节发送同步信号
      cue :bar
      
      # 更新计数器
      @@bar_count += 1
      set :global_bar, @@bar_count
      
      # 每 4 小节发送强拍信号
      cue :phrase if @@bar_count % 4 == 0
      
      # 每 8 小节发送段落信号
      cue :section if @@bar_count % 8 == 0
      
      # 每 16 小节发送过门信号
      cue :fill if @@bar_count % 16 == 0
      
      sleep 4  # 4 拍 = 1 小节
    end
  end
  
  # 获取当前小节数
  def self.bar_count
    @@bar_count
  end
  
  # 章节内小节数（相对于章节起点）
  def self.bar_in_chapter
    @@bar_count % Config::CHAPTERS[@@current_chapter][:bars]
  end
  
  # 切换章节
  def self.switch_chapter(chapter_id)
    @@current_chapter = chapter_id
    set :current_chapter, chapter_id
    puts ">>> Switched to #{Config::CHAPTERS[chapter_id][:name]}"
  end
  
  # 当前章节配置
  def self.current_config
    Config::CHAPTERS[@@current_chapter]
  end
  
  # 停止时钟
  def self.stop
    @@running = false
    set :clock_running, false
  end
end