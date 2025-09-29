# CarDJ Edm Constant

P=1.618034
E=2.718281828
PI=Math::PI

# DEBUG switch: shorten time to 1/5 for quick testing
DEBUG = true

MD={
  pi:"314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196",
  golden:"161803398874989484820458683436563811772030917980576286213544862270526046281890244970720720418939113748475408807538689175212663428754440643745123718192179998391015919561814675142691239748940901224953430",
  e:"271828182845904523536028747135266249775724709369999595749669676277240766303535475945713821785251664272427466391932003059921817413596629043572900334295260595630738132328627943490763233829880753195251019",
  sqrt2:"141421356237309504880168872420969807856967187537694807317667973799073247846210703885038753432764157273501384623091229702492483605598507372126441214970999358314132226659275055927557999505011527820605714"
}.freeze

AP = [
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen01_175.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen04_170.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen07_172.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen13_173.wav",
  "/Users/tsb/Pop-Proj/rhythm-lab.com_amen_vol.1/WAV/cw_amen18_178.wav"
]

S_PAN = lambda { |pan_val| [-1.0, [pan_val, 1.0].min].max }

# Dawn Ignition
BPM_DI = 125
VC_DI = 5
S_DI = { intro: DEBUG ? 60/5 : 60, drive: DEBUG ? 120/5 : 120, peak: DEBUG ? 80/5 : 80, outro: DEBUG ? 40/5 : 40 }
VB_DI = 0.3
IB_DI = 0.2
FM_DI = 1.0
LP_DI = lambda { |t| Math.sin(t * PI / 12) * 0.25 }
HP_DI = 0.4
VP_DI = 0.08
EP_DI = [:bd_haus, :sn_dub, :synth_piano, :fx_reverb, :synth_pad, :perc_bell, :fx_echo, :amen_fill]
BC_DI = [[:c4, :major], [:f4, :major], [:g4, :major], [:a4, :minor]]
CE_DI = [:major7, :sus2, :sus4, :minor7]

# Urban Velocity
BPM_UV = 135
VC_UV = 4
S_UV = { intro: DEBUG ? 45/5 : 45, drive: DEBUG ? 90/5 : 90, peak: DEBUG ? 60/5 : 60, outro: DEBUG ? 30/5 : 30 }
VB_UV = 0.6
IB_UV = 0.4
FM_UV = 1.0
LP_UV = lambda { |t| Math.sin(t * PI / 8) * 0.4 }
HP_UV = 0.3
VP_UV = 0.15
EP_UV = [:bd_tek, :sn_dub, :bd_fat, :synth_pluck, :synth_saw, :sample_perc, :fx_reverb, :fx_echo, :synth_pad, :amen_fill]

# Endless Lane
BPM_EL = 132
VC_EL = 6
S_EL = { intro: DEBUG ? 50/5 : 50, drive: DEBUG ? 150/5 : 150, peak: DEBUG ? 100/5 : 100, outro: DEBUG ? 50/5 : 50 }
VB_EL = 0.4
IB_EL = 0.2
FM_EL = 1.0
LP_EL = lambda { |t| Math.sin(t * PI / 12) * 0.2 }
HP_EL = 0.4
VP_EL = 0.05
EP_EL = [:bd_haus, :sn_dub, :bd_fat, :synth_saw, :synth_pad, :sample_perc, :fx_reverb, :fx_echo, :synth_pluck, :amen_fill]

# Midnight Horizon
BPM_MH = 138
VC_MH = 5
S_MH = { intro: DEBUG ? 40/5 : 40, drive: DEBUG ? 100/5 : 100, peak: DEBUG ? 80/5 : 80, outro: DEBUG ? 40/5 : 40 }
VB_MH = 0.3
IB_MH = 0.5
FM_MH = 1.0
LP_MH = lambda { |t| Math.sin(t * PI / 10) * 0.5 }
HP_MH = 0.6
VP_MH = 0.2
EP_MH = [:bd_haus, :sn_dub, :bd_fat, :synth_pad, :synth_saw, :sample_perc, :fx_reverb, :fx_echo, :synth_pluck, :amen_fill]

# Station Dreams
BPM_SD = 100
VC_SD = 4
S_SD = { intro: DEBUG ? 30/5 : 30, drive: DEBUG ? 60/5 : 60, peak: DEBUG ? 40/5 : 40, outro: DEBUG ? 20/5 : 20 }
VB_SD = 0.2
IB_SD = 0.1
FM_SD = 0.8
LP_SD = lambda { |t| Math.sin(t * PI / 15) * 0.1 }
HP_SD = 0.7
VP_SD = 0.05
EP_SD = [:bd_haus, :sn_dub, :bd_fat, :synth_pad, :synth_saw, :sample_perc, :fx_reverb, :fx_echo, :synth_pluck, :amen_fill]