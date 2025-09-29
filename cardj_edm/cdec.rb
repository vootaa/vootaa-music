# CarDJ Edm Constant

P=1.618034
E=2.718281828
PI=Math::PI

MD={
  pi:"314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196",
  golden:"161803398874989484820458683436563811772030917980576286213544862270526046281890244970720720418939113748475408807538689175212663428754440643745123718192179998391015919561814675142691239748940901224953430",
  e:"271828182845904523536028747135266249775724709369999595749669676277240766303535475945713821785251664272427466391932003059921817413596629043572900334295260595630738132328627943490763233829880753195251019",
  sqrt2:"141421356237309504880168872420969807856967187537694807317667973799073247846210703885038753432764157273501384623091229702492483605598507372126441214970999358314132226659275055927557999505011527820605714"
}.freeze

# Amen sample pool for all 6 tracks (filtered for car EDM: clear breaks, varying BPM)
AMEN_POOL = [
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen01_175.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen04_170.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen07_172.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen13_173.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen18_178.wav"
]  # Select 5 for variety; use in events for rhythmic fills

# Dawn Ignition constants
BPM_DI = 128
VARIANT_COUNT_DI = 5  # Number of variants; total duration = VARIANT_COUNT_DI * single variant length (~25 min total)
SEGMENTS_DI = { intro: 60, drive: 120, peak: 80, outro: 40 }  # Single variant ~5 min (300 sec); adjust for total ~25 min
VEL_BASE_DI = 0.5
INT_BASE_DI = 0.3
FUSION_MAX_DI = 1.0
LANE_PAN_DI = lambda { |t| Math.sin(t * PI / 10) * 0.3 }
HORIZON_PAN_DI = 0.5
VEL_PAN_OFF_DI = 0.1
EVENT_POOL_DI = [:bd_haus, :sn_dub, :bd_fat, :synth_piano, :synth_saw, :sample_perc, :fx_reverb, :fx_echo, :synth_pad, :amen_fill]

# Urban Velocity constants
BPM_UV = 135  # Higher BPM for fast-paced city driving
VARIANT_COUNT_UV = 4  # Number of variants; total duration ~20 min
SEGMENTS_UV = { intro: 45, drive: 90, peak: 60, outro: 30 }  # Single variant ~3.75 min; total ~15 min, adjust for 20 min
VEL_BASE_UV = 0.6
INT_BASE_UV = 0.4
FUSION_MAX_UV = 1.0
LANE_PAN_UV = lambda { |t| Math.sin(t * PI / 8) * 0.4 }  # Faster lane switching for city feel
HORIZON_PAN_UV = 0.3
VEL_PAN_OFF_UV = 0.15
EVENT_POOL_UV = [:bd_tek, :sn_dub, :bd_fat, :synth_pluck, :synth_saw, :sample_perc, :fx_reverb, :fx_echo, :synth_pad, :amen_fill]