; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)
; =============================================================================================

; ---------------------------------------------------------------------------------------------
; Note Equates
	rsset	$80
nRst		rs.b	1			; Rest note
nC0		rs.b	1			; C0
nCs0		rs.b	0			; C#0/Db0
nDb0		rs.b	1
nD0		rs.b	1			; D0
nDs0		rs.b	0			; D#0/Eb0
nEb0		rs.b	1
nE0		rs.b	0			; E0
nFb0		rs.b	1
nF0		rs.b	0			; F0
nEs0		rs.b	1
nFs0		rs.b	0			; F#0/Gb0
nGb0		rs.b	1
nG0		rs.b	1			; G0
nGs0		rs.b	0			; G#0/Ab0
nAb0		rs.b	1
nA0		rs.b	1			; A0
nAs0		rs.b	0			; A#0/Bb0
nBb0		rs.b	1
nB0		rs.b	0			; B0/Cb1
nCb1		rs.b	1
nC1		rs.b	0			; C1/B#0
nBs0		rs.b	1
nCs1		rs.b	0			; C#1/Db1
nDb1		rs.b	1
nD1		rs.b	1			; D1
nDs1		rs.b	0			; D#1/Eb1
nEb1		rs.b	1
nE1		rs.b	0			; E1
nFb1		rs.b	1
nF1		rs.b	0			; F1
nEs1		rs.b	1
nFs1		rs.b	0			; F#1/Gb1
nGb1		rs.b	1
nG1		rs.b	1			; G1
nGs1		rs.b	0			; G#1/Ab1
nAb1		rs.b	1
nA1		rs.b	1			; A1
nAs1		rs.b	0			; A#1/Bb1
nBb1		rs.b	1
nB1		rs.b	0			; B1/Cb2
nCb2		rs.b	1
nC2		rs.b	0			; C2/B#1
nBs1		rs.b	1
nCs2		rs.b	0			; C#2/Db2
nDb2		rs.b	1
nD2		rs.b	1			; D2
nDs2		rs.b	0			; D#2/Eb2
nEb2		rs.b	1
nE2		rs.b	0			; E2
nFb2		rs.b	1
nF2		rs.b	0			; F2
nEs2		rs.b	1
nFs2		rs.b	0			; F#2/Gb2
nGb2		rs.b	1
nG2		rs.b	1			; G2
nGs2		rs.b	0			; G#2/Ab2
nAb2		rs.b	1
nA2		rs.b	1			; A2
nAs2		rs.b	0			; A#2/Bb2
nBb2		rs.b	1
nB2		rs.b	0			; B2/Cb3
nCb3		rs.b	1
nC3		rs.b	0			; C3/B#2
nBs2		rs.b	1
nCs3		rs.b	0			; C#3/Db3
nDb3		rs.b	1
nD3		rs.b	1			; D3
nDs3		rs.b	0			; D#3/Eb3
nEb3		rs.b	1
nE3		rs.b	0			; E3
nFb3		rs.b	1
nF3		rs.b	0			; F3
nEs3		rs.b	1
nFs3		rs.b	0			; F#3/Gb3
nGb3		rs.b	1
nG3		rs.b	1			; G3
nGs3		rs.b	0			; G#3/Ab3
nAb3		rs.b	1
nA3		rs.b	1			; A3
nAs3		rs.b	0			; A#3/Bb3
nBb3		rs.b	1
nB3		rs.b	0			; B3/Cb4
nCb4		rs.b	1
nC4		rs.b	0			; C4/B#3
nBs3		rs.b	1
nCs4		rs.b	0			; C#4/Db4
nDb4		rs.b	1
nD4		rs.b	1			; D4
nDs4		rs.b	0			; D#4/Eb4
nEb4		rs.b	1
nE4		rs.b	0			; E4
nFb4		rs.b	1
nF4		rs.b	0			; F4
nEs4		rs.b	1
nFs4		rs.b	0			; F#4/Gb4
nGb4		rs.b	1
nG4		rs.b	1			; G4
nGs4		rs.b	0			; G#4/Ab4
nAb4		rs.b	1
nA4		rs.b	1			; A4
nAs4		rs.b	0			; A#4/Bb4
nBb4		rs.b	1
nB4		rs.b	0			; B4/Cb5
nCb5		rs.b	1
nC5		rs.b	0			; C5/B#4
nBs4		rs.b	1
nCs5		rs.b	0			; C#5/Db5
nDb5		rs.b	1
nD5		rs.b	1			; D5
nDs5		rs.b	0			; D#5/Eb5
nEb5		rs.b	1
nE5		rs.b	0			; E5
nFb5		rs.b	1
nF5		rs.b	0			; F5
nEs5		rs.b	1
nFs5		rs.b	0			; F#5/Gb5
nGb5		rs.b	1
nG5		rs.b	1			; G5
nGs5		rs.b	0			; G#5/Ab5
nAb5		rs.b	1
nA5		rs.b	1			; A5
nAs5		rs.b	0			; A#5/Bb5
nBb5		rs.b	1
nB5		rs.b	0			; B5/Cb6
nCb6		rs.b	1
nC6		rs.b	0			; C6/B#5
nBs5		rs.b	1
nCs6		rs.b	0			; C#6/Db6
nDb6		rs.b	1
nD6		rs.b	1			; D6
nDs6		rs.b	0			; D#6/Eb6
nEb6		rs.b	1
nE6		rs.b	0			; E6
nFb6		rs.b	1
nF6		rs.b	0			; F6
nEs6		rs.b	1
nFs6		rs.b	0			; F#6/Gb6
nGb6		rs.b	1
nG6		rs.b	1			; G6
nGs6		rs.b	0			; G#6/Ab6
nAb6		rs.b	1
nA6		rs.b	1			; A6
nAs6		rs.b	0			; A#6/Bb6
nBb6		rs.b	1
nB6		rs.b	0			; B6/Cb7
nCb7		rs.b	1
nC7		rs.b	0			; C7/B#6
nBs6		rs.b	1
nCs7		rs.b	0			; C#7/Db7
nDb7		rs.b	1
nD7		rs.b	1			; D7
nDs7		rs.b	0			; D#7/Eb7
nEb7		rs.b	1
nE7		rs.b	0			; E7
nFb7		rs.b	1
nF7		rs.b	0			; F7
nEs7		rs.b	1
nFs7		rs.b	0			; F#7/Gb7
nGb7		rs.b	1
nG7		rs.b	1			; G7
nGs7		rs.b	0			; G#7/Ab7
nAb7		rs.b	1
nA7		rs.b	1			; A7
nAs7		rs.b	0			; A#7/Bb7
nBb7		rs.b	1
nB7		rs.b	0			; B7/Cb8
nCb8		rs.b	1

; ---------------------------------------------------------------------------------------------
; Channel IDs
cPCM1				EQU $00
cPCM2				EQU $01
cPCM3				EQU $02
cPCM4				EQU $03
cPCM5				EQU $04
cPCM6				EQU $05
cPCM7				EQU $06
cPCM8				EQU $07

; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong macro ver
SourceDriver set ver
songStart set *
	dc.w	$0000
	endm

smpsHeaderStartSongConvert macro ver
SourceDriver set ver
songStart set *
	dc.w	$0000
	endm

; Header macros for music (not for SFX)
; Header - Set up Channel Usage
smpsHeaderChan macro pcm
	dc.b	pcm,0
	endm

; Header - Set up Tempo
smpsHeaderTempo macro div,mod
	dc.b	div,mod
	endm

; Header - Set up PCM Channel
smpsHeaderPCM macro loc,pitch,vol
	dc.w	loc-songStart
	dc.b	pitch,vol
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
	dc.w	loc-songStart
	dc.b	pitc, vol
	endm

; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and Equates
; E0xx - Panning
smpsPan macro pan
	dc.b	$E0,pan
	endm

; E1xx - Set channel detune to val
smpsAlterNote macro val
	dc.b	$E1,val
	endm

; E2xx - Useless
smpsNop macro val
	dc.b	$E2,val
	endm

; E3xx - Start CDDA loop
smpsCDDALoop macro val
	dc.b	$E3
	endm

; E6xx - Alter Volume
smpsAlterVol macro val
	dc.b	$E6,val
	endm

; E7 - Prevent attack of next note
smpsNoAttack	EQU $E7

; E8xx - Set note fill to xx
smpsNoteFill macro val
	dc.b	$E8,val
	endm

; EAxx - Set music tempo modifier to xx
smpsSetTempoMod macro mod
	dc.b	$EA,mod
	endm

; EBxx - Play sound xx
smpsPlaySound macro index
	dc.b	$EB,index
	endm

; EFxx - Set Voice of channel to xx
smpsSetvoice macro voice
	dc.b	$EF,voice
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$F6
	dc.w	loc-*-1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$F7,index,loops
	dc.w	loc-*-1
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$F8
	dc.w	loc-*-1
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

; FCxx - Set music tempo divider to xx
smpsSetTempoDiv macro val
	dc.b	$FC,val
	endm

; FExxyy - Unknown
smpsUnkFE macro val1, val2
	dc.b	$FE,val1,val2
	endm
