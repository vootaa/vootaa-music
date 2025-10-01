# Numus Section DNA 配置规范（Draft v0.1）

目的：统一“人工/历史 Sonic Pi 片段”与“确定性生成素材”的描述方式，形成可索引、可复原“核心感觉”的 Section 级素材参考单元，用于：

1) 构建素材参考池（检索 / 复用 / 迁移风格）。
2) 生成阶段：Numus 读取上下文 → 过滤候选 → 派生修饰或变体。
3) 追溯：任意采用的 WAV/MIDI 可还原：来源区间 + 映射 + 变换链。

---

## 1. 顶层结构 (JSON)

字段 (必需除非标注可选)：
{
  "spec_version": "0.1",
  "identity": {
    "track_id": "...",
    "chapter_id": "...",
    "section_id": "...",
    "source_type": "manual_demo | generated | hybrid",
    "origin_file": "relative/original_script.rb"       // 可选
  },
  "timeline": {
    "tempo_bpm": 60,
    "time_signature": "4/4",
    "bars_length": 8,
    "grid_min_note": "1/16"
  },
  "musical_context": {
    "key_root": "A",
    "scale": "minor",                // 或 "aeolian" 等
    "key_confidence": 0.82,
    "chord_palette": [ "Am7", "Fmaj7", "G", "Em7" ],   // 顺序=出现顺序（可重复）
    "root_motion": ["A","F","G","E"],                  // 主和声根序列（去重后保留顺序）
    "register_occupied": ["sub_low","low","mid","high"]
  },
  "energy_profile": {
    "energy_level": "low | mid | high",
    "density_level": "low | mid | mid_high | high",
    "focus_path": ["low_freq_pulse","pad_bed","mid_motif"], // 注意力主导序列
    "allowed_decor_slots": 1
  },
  "constraints": {
    "max_layers_simultaneous": 7,
    "forbid_registers": [],
    "target_role_gaps": ["sparkle_high","noise_riser"]       // 候选可补位
  },
  "layers": [ LayerObject, ... ],
  "dna": {
    "pitch_source_plan": {
      "type": "pi | phi | e | fib | manual",
      "slice": "pi:0-120",                 // 若 manual 则写 "manual"
      "mapping": "digits->scale_degree(mod 7)->octave(4-5)"
    },
    "rhythm_source_plan": {
      "base_pattern_id": "r4_straight_16",
      "transform_chain": ["thin(p=0.35)","shift(+1 step)"]
    },
    "energy_curve_plan": {
      "method": "linear_interp",
      "points": [[0,0.3],[0.5,0.55],[1.0,0.6]]
    }
  },
  "analytics": {
    "interval_vector": [4,3,2,1,0,0],        // 可选：六维 / SET-class 简化
    "onset_density_per_bar": [12,12,10,11], // 事件计数
    "spectral_bias": {"low":0.45,"mid":0.35,"high":0.20},
    "motif_signature": "hash:ab349f"         // pitch 与节奏组合散列
  },
  "adoption": {
    "status": "draft | approved | deprecated",
    "last_audition_note": "pad sustain slightly muddy",
    "version": 1
  },
  "trace": {
    "derivation_hash": "sha1:....",          // 由关键字段排序串联哈希
    "created_at": "2025-10-01T09:00:00Z",
    "updated_at": "2025-10-01T09:00:00Z"
  }
}

---

## 2. LayerObject 规范

{
  "name": "bass_loop",
  "role": "kick | bass | pad | chord_bed | rhythmic_lead | motif | percussion | fx_noise | texture | placeholder",
  "active": true,
  "pattern_len_bars": 8,
  "rhythm": {
    "grid_unit": "1/16",
    "events": 64,                         // 总事件数（含休止占位可写 total_steps）
    "density_per_bar": 8,
    "pattern_id": "r16_pulse_variantA",   // 绑定内部枚举，便于再生
    "mutations": ["thin(0.2)","accent([beat2_and])"]
  },
  "pitch": {
    "mode": "discrete_notes | chord_block | noise | percussive",
    "pitch_classes": ["A","C","E","G"],
    "octave_span": [1,3],
    "register": "low",
    "contour": "up_minor_3_then_stepwise", // 简述，可选
    "source_ref": "pi:40-80"               // 若适用
  },
  "fx_chain": ["reverb(mix=0.3)","wobble(phase=2)"],
  "articulation": "short | sustained | gated | sliced",
  "gain_norm": -12,                        // LUFS 相对参考（可选）
  "exposure": "foreground | support | background"
}

说明：

- rhythm.pattern_id 对应内部固定模板（建立 registry），变换链写入 mutations。
- pitch.source_ref 若手写则可省略；若来自数学序列必须写 slice。
- exposure 用于能量聚焦决策（同一 Section 不允许 >2 个 foreground）。

---

## 3. 生成 / 解析流程建议

解析（从 Sonic Pi 脚本 → JSON）：

1. 扫描 live_loop 名称 → 初步 role 映射（基于命名词典）。
2. 聚合 play / sample 事件 → 最小 sleep 推导 grid_min_note。
3. 统计事件计数 → density / events。
4. 收集 chord() / 单音 → pitch_class 频次 → key 猜测 & 置信度。
5. 注册启用层（未 stop）→ energy_level 粗分：score = (bass? + kick? + hats? + pad? + lead?)*权重。
6. 计算 interval_vector（按相邻音高差绝对值分类）。
7. 衍生 derivation_hash：对 identity+timeline+musical_context+layers[].(role+pattern_id+pitch_classes) 连接后哈希。

选取（创作阶段）：

- 依据曲目 target.key / energy_range / needed_role 列表过滤。
- density_level 不得使目标 Section 超过预期上限；检查 register_occupied 避免频段冲突。
- motif_signature 匹配：用于回调/主题再现（可选）。

复原（Numus 再生成）最少所需字段：

- tempo_bpm
- key_root + scale 或 pitch_classes
- grid_min_note
- chord_palette / root_motion
- 每个被复用 layer 的 rhythm.pattern_id + mutations
- pitch.source_ref + mapping（若非 manual）

---

## 4. 最小必填子集 (Lite Profile)

若只做“可选素材索引”：
identity + timeline + musical_context(key_root,scale,chord_palette) + energy_profile(energy_level,density_level) + layers[ role, active, pattern_len_bars, rhythm.pattern_id, pitch.pitch_classes, register ] + dna.pitch_source_plan(slice/mapping) + adoption.status

---

## 5. 枚举与约束

energy_level: low / mid / high  
density_level: low / mid / mid_high / high  
register: sub_low / low / low_mid / mid / mid_high / high / air  
role（核心）: kick, bass, pad, chord_bed, rhythmic_lead, motif, percussion, fx_noise, texture  
pattern_id 命名：r{division}_{descriptor}_{variant?} 例：r16_straight_v1, r16_offbeat_sync_v2  
pitch_source_plan.type: pi | phi | e | fib | manual  
transform_chain 元素：thin(p=..), shift(+/-n), cluster(size=k), accent([...]), invert, reverse, slice(i:j)

---

## 6. 目录与命名建议

存放：Numus/sections/<track_id>/<chapter_id>/<section_id>.json  
示例：Numus/sections/dawn_ignition/first_lift/first_lift_A_demo01.json

---

## 7. 版本与演化策略

- spec_version 升级仅追加字段，不移除必填；解析器需忽略未知字段。
- adoption.status=approved 后仅允许：trace.updated_at、adoption.last_audition_note、version++。
- 变体派生：section_id 加后缀 _var1 / _piA / _thin35。

---

## 8. 参考最小示例

{
  "spec_version": "0.1",
  "identity": {
    "track_id": "dawn_ignition",
    "chapter_id": "first_lift",
    "section_id": "first_lift_A_demo01",
    "source_type": "manual_demo"
  },
  "timeline": { "tempo_bpm": 60, "time_signature": "4/4", "bars_length": 16, "grid_min_note": "1/16" },
  "musical_context": {
    "key_root": "A",
    "scale": "minor",
    "key_confidence": 0.78,
    "chord_palette": ["Am7","Fmaj7","G","Am7"],
    "root_motion": ["A","F","G"],
    "register_occupied": ["sub_low","low","mid","mid_high","high"]
  },
  "energy_profile": {
    "energy_level": "mid",
    "density_level": "mid_high",
    "focus_path": ["low_freq_pulse","pad_bed","rhythmic_lead"],
    "allowed_decor_slots": 1
  },
  "constraints": {
    "max_layers_simultaneous": 7,
    "forbid_registers": [],
    "target_role_gaps": ["sparkle_high"]
  },
  "layers": [
    {
      "name": "kick",
      "role": "kick",
      "active": true,
      "pattern_len_bars": 16,
      "rhythm": { "grid_unit": "1/8", "events": 32, "density_per_bar": 4, "pattern_id": "r8_four_on_floor", "mutations": [] },
      "pitch": { "mode": "percussive", "pitch_classes": [], "octave_span": [], "register": "sub_low" },
      "fx_chain": [],
      "articulation": "short",
      "exposure": "foreground"
    }
  ],
  "dna": {
    "pitch_source_plan": { "type": "pi", "slice": "pi:0-120", "mapping": "digit%7->aeolian_degree->oct(4,5)" },
    "rhythm_source_plan": { "base_pattern_id": "r16_straight_v1", "transform_chain": ["thin(p=0.35)","shift(+1)"] },
    "energy_curve_plan": { "method": "linear_interp", "points": [[0,0.45],[0.5,0.55],[1,0.6]] }
  },
  "analytics": {},
  "adoption": { "status": "draft", "last_audition_note": "", "version": 1 },
  "trace": { "derivation_hash": "sha1:...", "created_at": "2025-10-01T09:00:00Z", "updated_at": "2025-10-01T09:00:00Z" }
}

---

## 9. 实施最小步骤

1. 写解析脚本：输入 .rb → 输出上述 JSON（Lite Profile）。
2. 建立 pattern 与 transform registry（常量 Python dict）。
3. 生成修饰素材流程：
   - 加载 Section JSON → 读取 energy_profile / constraints
   - 选择 pitch_source_plan.slice 未“过度消耗”的区间
   - 应用 transform_chain（严格有序）
   - 写出 out/midi / out/wav 与 meta（含 section_id + slice + chain）
4. 审听后更新 adoption.status。

---

## 10. 后续可能扩展（保持向后兼容）

- dynamic_macro_ref: 指向跨 Section 能量节点表
- similarity_links: 与其他 Section 的 motif_signature 相似度
- psychoacoustic_tags: "warm_pad","glassy_high"

结束：该规范足以驱动首轮“参考池→筛选→确定性再生”实现。
