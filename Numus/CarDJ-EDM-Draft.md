# CarDJ EDM — Implementation Draft

Purpose

- Convert the CarDJ_EDM concept into an actionable Numus implementation plan: deterministic generators, short 2–3 minute “chapters” (segments) with unique DNA, and a programmatic DJ engine to stitch segments into long-form car-ready playlists targeted for multi‑speaker systems.

## 1. High-level architecture

- Generator (Python)
  - Input: DNA JSON/YAML per segment
  - Output: ./out/midi/<segment>.mid and ./out/midi/<segment>.meta.json
- Renderer
  - Render MIDI → WAV using FluidSynth / SoundFont to ./out/wav/<segment>.wav
- Segment store
  - Segments + metadata form the building blocks
- DJ Engine (Python)
  - Playlist assembly, transition scoring, crossfades, EQ maps for speaker layout
  - Output: stitched master WAV(s) and per-segment staging WAVs
- Sonic Pi (optional live)
  - Loads WAV samples; performs additional FX, multi‑speaker panning and live OSC control

## 2. Chapter / Segment concept

- Segment length: 2–3 minutes (complete mini‑song)
- Each segment has its own DNA:
  - id, style (house/trance/ambient), tonic, bpm, energy (0–1), timbre_profile, stereo_map, dna_seed (digits of π/φ or other constant)
- Album is a curated sequence of segments forming larger arcs (20–40 minute tracks built from segments)

## 3. DNA schema (example JSON)

- Keep concise, deterministic, and human-editable.

Example:
{
  "id": "dawn_001",
  "title": "Dawn Ignition - motif A",
  "style": "progressive_house",
  "tonic": "C4",
  "bpm": 118,
  "energy": 0.35,
  "timbre": "warm_pad+sub",
  "stereo_map": {"lead": 0.0, "pad": -0.2, "fx": 0.4},
  "dna_seed": {"type":"pi_digits","offset":1024},
  "duration_sec": 150
}

## 4. Deterministic pseudo-randomness

- Use fixed irrational sources: digits of π, e, φ or hashed combinations.
- Expose seed in metadata: dna_seed.
- Example generator routine:
  - Derive sequence values: digit = pi_digits[(index + offset) % len]
  - Map digit → parameter via scaling functions (note selection, velocity, timing micro‑shift)

## 5. Segment generation pipeline (implementation steps)

- requirements.txt: mido, pretty_midi, numpy, pyfluidsynth (or rely on system fluidsynth)
- generator.py responsibilities:
  - read DNA
  - generate chord progression and motif using deterministic sequences
  - write MIDI and meta JSON
  - call FluidSynth to render WAV
  - save sample path to metadata
- metadata fields: file paths, dna, bpm, tonic, energy, peak_db, loudness_estimate

## 6. DJ engine: playlist & transition design

- Inputs: list of segments with energy, style, key, and speaker mapping
- Goal: assemble segments to follow an energy arc and ensure musical coherence
- Transition scoring (simple heuristics):
  - Key compatibility bonus if same or related key
  - Energy delta penalty if too abrupt (limit Δenergy per transition)
  - Style affinity bonus (same / compatible styles)
  - Tempo compatibility (allow ±4% or tempo warp)
- Transition actions:
  - Beat‑aligned crossfade (4–16 bars)
  - EQ automation: reduce low end on fade‑in/out to avoid bass buildup
  - Filter sweeps, reverb send crossfades to glue segments
- Pseudocode (transition decision):
  - score = w_key*key_score + w_energy*(1-abs(e1-e2)) + w_style*style_match + w_bpm*bpm_score
  - choose next segment by highest score respecting global arc constraints

## 7. Stitching & rendering

- For each transition:
  - Compute crossfade length in seconds (aligned to bars)
  - Apply windowed crossfade (cosine or linear) to avoid clicks
  - Apply per‑segment EQ map and multi‑speaker gains during transition
- Output: master WAV and optional stems per speaker group

## 8. Multi‑speaker considerations (car systems)

- Typical channels: Front L / Front R / Rear L / Rear R / Sub
- Speaker mapping strategy:
  - Map instruments to speaker groups: kick/sub → Sub; lead/pad → Front; ambience → Rear
  - Use per-segment stereo_map to set panning automation
  - Per‑channel dynamic range control: mild multiband compression for in-car loudness consistency
- Practical DSP:
  - Low-shelf boost for sub channel (20–80Hz) with bass management to avoid overdrive
  - Mid clarity band (200Hz–2kHz) preservation on front speakers
  - High‑freq lift (4–16kHz) on front to compensate vehicle loss
- Example: store speaker_map in metadata:
  "speaker_map": {"sub":0.9,"front_l":0.9,"front_r":0.9,"rear_l":0.5,"rear_r":0.5}

## 9. Sonic Pi integration

- Sonic Pi scripts reference generated WAVs at top:
  synth_seg = "./out/wav/dawn_001.wav"
- Use samples with controlled amplitude and panning:
  sample synth_seg, amp: master_amp * seg_amp, pan: seg_pan
- For multi‑speaker testing with a stereo car system, simulate by panning and duplicated layers with EQ.

## 10. Testing & reproducibility

- For each generation run:
  - Write meta JSON: includes dna_seed, exact generator version, timestamp
  - Add a smoke-test that confirms: MIDI exists, WAV exists, meta JSON valid, duration within tolerance
- Keep a small test script under tests/ to assert artifact existence

## 11. Minimal file layout

- vootaa-music/
  - Numus/
    - generators/
      - generator_template.py
    - utils/
      - render_wav.py
    - README.md
  - out/
    - midi/
    - wav/
  - sonic-pi/
    - cardj_playback.rb
  - tests/
    - smoke_generation.py

## 12. Practical tips

- Keep segments short (2–3min) to allow many permutations and avoid repetitive loops.
- Ensure crossfades align to beats; compute bar length = 60 / bpm * beats_per_bar.
- Use small metadata files to make A/B testing and curated playlists easy.
- When rendering final long files, normalize loudness per EBU R128 or target LUFS for car playback.

Appendix — Example transition constraints (concise)

- Max Δenergy per transition: 0.4 (soft cap)
- Crossfade length: 8–16 bars for energy‑preserving transitions; 2–4 bars for quick cuts
- Key compatibility: same tonic = +1.0; relative minor/major = +0.6; distant keys penalized
- Tempo warp allowed up to ±4% for smooth mixing

End of draft.
