; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)
; =============================================================================================

little_endian function x,((x)<<8)&$FF00|((x)>>8)&$FF

; ---------------------------------------------------------------------------------------------
; Note Equates
	enum		nRst=$80
	nextenum	nC0,nCs0,nDb0=nCs0,nD0,nDs0,nEb0=nDs0,nE0,nFb0=nE0,nEs0,nF0=nEs0
	nextenum	nFs0,nGb0=nFs0,nG0,nGs0,nAb0=nGs0,nA0,nAs0,nBb0=nAs0,nB0,nCb1=nB0,nBs0
	nextenum	nC1=nBs0,nCs1,nDb1=nCs1,nD1,nDs1,nEb1=nDs1,nE1,nFb1=nE1,nEs1,nF1=nEs1
	nextenum	nFs1,nGb1=nFs1,nG1,nGs1,nAb1=nGs1,nA1,nAs1,nBb1=nAs1,nB1,nCb2=nB1,nBs1
	nextenum	nC2=nBs1,nCs2,nDb2=nCs2,nD2,nDs2,nEb2=nDs2,nE2,nFb2=nE2,nEs2,nF2=nEs2
	nextenum	nFs2,nGb2=nFs2,nG2,nGs2,nAb2=nGs2,nA2,nAs2,nBb2=nAs2,nB2,nCb3=nB2,nBs2
	nextenum	nC3=nBs2,nCs3,nDb3=nCs3,nD3,nDs3,nEb3=nDs3,nE3,nFb3=nE3,nEs3,nF3=nEs3
	nextenum	nFs3,nGb3=nFs3,nG3,nGs3,nAb3=nGs3,nA3,nAs3,nBb3=nAs3,nB3,nCb4=nB3,nBs3
	nextenum	nC4=nBs3,nCs4,nDb4=nCs4,nD4,nDs4,nEb4=nDs4,nE4,nFb4=nE4,nEs4,nF4=nEs4
	nextenum	nFs4,nGb4=nFs4,nG4,nGs4,nAb4=nGs4,nA4,nAs4,nBb4=nAs4,nB4,nCb5=nB4,nBs4
	nextenum	nC5=nBs4,nCs5,nDb5=nCs5,nD5,nDs5,nEb5=nDs5,nE5,nFb5=nE5,nEs5,nF5=nEs5
	nextenum	nFs5,nGb5=nFs5,nG5,nGs5,nAb5=nGs5,nA5,nAs5,nBb5=nAs5,nB5,nCb6=nB5,nBs5
	nextenum	nC6=nBs5,nCs6,nDb6=nCs6,nD6,nDs6,nEb6=nDs6,nE6,nFb6=nE6,nEs6,nF6=nEs6
	nextenum	nFs6,nGb6=nFs6,nG6,nGs6,nAb6=nGs6,nA6,nAs6,nBb6=nAs6,nB6,nCb7=nB6,nBs6
	nextenum	nC7=nBs6,nCs7,nDb7=nCs7,nD7,nDs7,nEb7=nDs7,nE7,nFb7=nE7,nEs7,nF7=nEs7
	nextenum	nFs7,nGb7=nFs7,nG7,nGs7,nAb7=nGs7,nA7,nAs7,nBb7=nAs7

; ---------------------------------------------------------------------------------------------
; Channel IDs for SFX
cFM1				EQU $00
cFM2				EQU $01
cFM3				EQU $02
cFM4				EQU $04
cFM5				EQU $05
cFM6				EQU $06

; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong macro ver
SourceDriver set ver
songStart set *
	endm

smpsHeaderStartSongConvert macro ver
SourceDriver set ver
songStart set *
	endm

smpsHeaderVoiceNull macro
	if songStart<>*
		fatal "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endif
	dc.w	$0000
	endm

; Header - Set up Voice Location
; Common to music and SFX
smpsHeaderVoice macro loc
	if songStart<>*
		fatal "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endif
	dc.w	little_endian(loc)
	endm

; Header macros for SFX
; Header - Set up Tempo
smpsHeaderTempoSFX macro div
	dc.b	div
	endm

; Header - Set up Channel Usage
smpsHeaderChanSFX macro chan
	dc.b	chan
	endm

; Header - Set up FM Channel
smpsHeaderSFXChannel macro chanid,loc,pitc,vol
	dc.b	$80,chanid
	dc.w	little_endian(loc)
	dc.b	pitc, vol
	endm

; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and Equates
; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
panNone set $00
panRight set $40
panLeft set $80
panCentre set $C0
panCenter set $C0 ; silly Americans :U
	dc.b	$E0,direction+amsfms
	endm

; E1xx - Set pitch slide speed to xx
smpsSlideSpeed macro val
	dc.b	$E1,val
	endm

; E2xx - Useless
smpsNop macro val
	dc.b	$E2,val
	endm

; E3xx - Silence track
smpsSilence macro
	dc.b	$E3h
	endm

; E5xxyyyy - Loop end
smpsLoopEnd macro index,loc
	dc.b	$E5,index
	dc.w	little_endian(loc)
	endm

; E6xx - Alter Volume
smpsFMAlterVol macro val
	dc.b	$E6,val
	endm

; E7 - Prevent attack of next note
smpsNoAttack	EQU $E7

; E8xx - Set note fill to xx
smpsNoteFill macro val
	dc.b	$E8,val
	endm

; E9xxyy - Set LFO
smpsSetLFO macro enable,amsfms
	dc.b	$E9,enable,amsfms
	endm

; EBxxxx - Jump if condition is true	
smpsConditionalJumpCD macro loc
	dc.b	$EB
	dc.w	little_endian(loc)
	endm

; EC - Reset ring channel
smpsResetRing macro
	dc.b	$EC
	endm

; EDxxyy - FM command (track)
smpsFMCommand macro reg,val
	dc.b	$ED,reg,val
	endm

; EExxyy - FM command (part 1)
smpsFMICommand macro reg,val
	dc.b	$EE,reg,val
	endm

; EFxx - Set Voice of FM channel to xx
smpsSetvoice macro voice
	dc.b	$EF,voice
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
smpsModSet macro wait,speed,change,step
	dc.b	$F0,wait,speed,change,step
	endm

; F1 - Turn off Modulation
smpsModOff macro
	dc.b	$F1
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm

; F3 - Swap ring channels
smpsRingSwap macro
	dc.b	$F3
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$F6
	dc.w	little_endian(loc)
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$F7,index,loops
	dc.w	little_endian(loc)
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$F8
	dc.w	little_endian(loc)
	endm

; F9 - Return
smpsReturn macro val
	dc.b	$F9
	endm

; FAxx - Set channel tempo divider to xx
smpsChanTempoDiv macro val
	dc.b	$FA,val
	endm

; FBxx - Add xx to channel pitch
smpsAlterPitch macro val
	dc.b	$FB,val
	endm

; FCxx - Enable pitch slide
smpsPitchSlide macro enable
	dc.b	$FC,enable
	endm

; FDxx - Enable alternate frequency mode
smpsAlternateSMPS macro flag
	dc.b	$FD,flag
	endm

; FEwwxxyyzz - Enable FM3 special mode
smpsFM3SpecialMode macro ind1,ind2,ind3,ind4
	dc.b	$FE,ind1,ind2,ind3,ind4
	endm

; FF01xx - Set music tempo modifier to xx
smpsSetTempoMod macro mod
	dc.b	$FF,$01,mod
	endm

; FF02xx - Play sound xx
smpsPlaySound macro index
	dc.b	$FF,$02,index
	endm

; FF04xxxxyy - Copy data
smpsCopyData macro data,len
	fatal "Coord. Flag to copy data should not be used."
	dc.b	$FF,$04
	dc.w	little_endian(data)
	dc.b	len
	endm

; FF06wwxxyyzz - Enable SSG-EG
smpsSSGEG macro op1,op2,op3,op4
	dc.b	$FF,$06,op1,op3,op2,op4
	endm

; ---------------------------------------------------------------------------------------------
; Macros for FM instruments
; Voices - Feedback
smpsVcFeedback macro val
vcFeedback set val
	endm

; Voices - Algorithm
smpsVcAlgorithm macro val
vcAlgorithm set val
	endm

smpsVcUnusedBits macro val
vcUnusedBits set val
	endm

; Voices - Detune
smpsVcDetune macro op1,op2,op3,op4
vcDT1 set op1
vcDT2 set op2
vcDT3 set op3
vcDT4 set op4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro op1,op2,op3,op4
vcCF1 set op1
vcCF2 set op2
vcCF3 set op3
vcCF4 set op4
	endm

; Voices - Rate Scale
smpsVcRateScale macro op1,op2,op3,op4
vcRS1 set op1
vcRS2 set op2
vcRS3 set op3
vcRS4 set op4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro op1,op2,op3,op4
vcAR1 set op1
vcAR2 set op2
vcAR3 set op3
vcAR4 set op4
	endm

; Voices - Amplitude Modulation
smpsVcAmpMod macro op1,op2,op3,op4
vcAM1 set op1
vcAM2 set op2
vcAM3 set op3
vcAM4 set op4
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro op1,op2,op3,op4
vcD1R1 set op1
vcD1R2 set op2
vcD1R3 set op3
vcD1R4 set op4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro op1,op2,op3,op4
vcD2R1 set op1
vcD2R2 set op2
vcD2R3 set op3
vcD2R4 set op4
	endm

; Voices - Decay Level
smpsVcDecayLevel macro op1,op2,op3,op4
vcDL1 set op1
vcDL2 set op2
vcDL3 set op3
vcDL4 set op4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro op1,op2,op3,op4
vcRR1 set op1
vcRR2 set op2
vcRR3 set op3
vcRR4 set op4
	endm

; Voices - Total Level
smpsVcTotalLevel macro op1,op2,op3,op4
vcTL1 set op1
vcTL2 set op2
vcTL3 set op3
vcTL4 set op4
	dc.b	(vcUnusedBits<<6)+(vcFeedback<<3)+vcAlgorithm
;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111
	dc.b	(vcDT4<<4)+vcCF4 ,(vcDT3<<4)+vcCF3 ,(vcDT2<<4)+vcCF2 ,(vcDT1<<4)+vcCF1
	dc.b	(vcRS4<<6)+vcAR4 ,(vcRS3<<6)+vcAR3 ,(vcRS2<<6)+vcAR2 ,(vcRS1<<6)+vcAR1
	dc.b	(vcAM4<<7)+vcD1R4,(vcAM3<<7)+vcD1R3,(vcAM2<<7)+vcD1R2,(vcAM1<<7)+vcD1R1
	dc.b	vcD2R4           ,vcD2R3           ,vcD2R2           ,vcD2R1
	dc.b	(vcDL4<<4)+vcRR4 ,(vcDL3<<4)+vcRR3 ,(vcDL2<<4)+vcRR2 ,(vcDL1<<4)+vcRR1
	dc.b	vcTL4            ,vcTL3            ,vcTL2            ,vcTL1
	endm

