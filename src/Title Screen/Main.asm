; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Main function
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Title screen game mode
; -------------------------------------------------------------------------

TitleScreen:
	bsr.w	ClearPLCs			; Clear PLCs
	move	#$2700,sr			; Disable interrupts

	lea	VDPCTRL,a6
	move.w	#$8004,(a6)			; HScroll by line, VScroll by screen
	move.w	#$8230,(a6)			; Plane A at $C000
	move.w	#$8407,(a6)			; Plane B at $E000
	move.w	#$9001,(a6)			; Plane size 64x32
	move.w	#$9200,(a6)			; Window vertical position
	move.w	#$8B03,(a6)			; HScroll by line, VScroll by screen
	move.w	#$8720,(a6)			; Background color at line 2, color 0
	bsr.w	ClearScreen			; Clear the screen

	lea	objects.w,a1			; Clear object RAM
	moveq	#0,d0
	move.w	#$2000/4-1,d1

.ClearObjects:
	move.l	d0,(a1)+
	dbf	d1,.ClearObjects

	;move.l	#$40000001,VDPCTRL
	;lea	(Art_TitleFg).l,a0 ; load title	screen patterns
	;bsr.w	NemDec
	move.l	#$60000001,VDPCTRL
	lea	(Art_TitleSonic).l,a0 ;	load Sonic title screen	patterns
	bsr.w	NemDec
	;move.l	#$62000002,VDPCTRL
	;lea	(Art_TitleTM).l,a0 ; load "TM" patterns
	;bsr.w	NemDec

	moveq	#3,d0
	bsr.w	LoadFadePal

	move.b	#0,spawnMode
	move.w	#0,demoMode
	move.w	#0,zone

	bsr.w	LevelSizeLoad			; Get level size and start position
	bsr.w	LevelScroll			; Initialize level scrolling

;	lea	VDPCTRL,a5
;	lea	VDPDATA,a6
;	lea	cameraBgX,a3
;	lea	levelLayout+$40,a4
;	move.w	#$6000,d2
;	bsr.w	InitLevelDrawFG

	move.l	#$40000000,VDPCTRL
	lea	(Art_LevelTiles).l,a0 ; load GHZ patterns
	bsr.w	NemDec
	moveq	#1,d0
	bsr.w	LoadFadePal

	bset	#2,scrollFlags.w		; Force draw a block column on the left side of the screen
	bsr.w	LoadLevelData			; Load level data

	bsr.w	InitLevelDraw			; Begin level drawing (TO REMOVE)

	move.b	#$E,objTitleSonicSlot.w
	jsr	RunObjects			; Run objects
	bsr.w	LevelScroll			; Handle level scrolling
	jsr	DrawObjects			; Draw objects

	move.w	vdpReg01.w,d0
	ori.b	#$40,d0
	move.w	d0,VDPCTRL
	move.w	#$003F,palFadeInfo.w		; Set to fade palette lines 1-3
	bsr.w	FadeFromBlack			; Fade from black

; -------------------------------------------------------------------------

Level_MainLoop:
	move.b	#4,vintRoutine.w		; VSync
	bsr.w	VSync

	jsr	RunObjects			; Run objects
	bsr.w	LevelScroll			; Handle level scrolling
	jsr	DrawObjects			; Draw objects
	bsr.w	PaletteCycle			; Handle palette cycling
	bsr.w	ProcessPLCs			; Process PLCs

;	bra.w	Level_MainLoop			; Loop

	andi.b	#$80,p1CtrlTap.w
	beq.w	Level_MainLoop

	move.b	#$C,gameMode.w
	move.b	#3,lives
	moveq	#0,d0
	move.w	d0,rings			; Reset ring count
	move.l	d0,time				; Reset time
	move.l	d0,score			; Reset score
	move.b	d0,specialStage			; Reset special stage flag
	rts

LevelStart:
	bset	#0,GAMAINFLAG			; Tell Sub CPU we are finished

.WaitSubCPU:
	btst	#0,GASUBFLAG			; Has the Sub CPU received our tip?
	beq.s	.WaitSubCPU			; If not, branch
	bclr	#0,GAMAINFLAG			; Respond to the Sub CPU
	rts

; -------------------------------------------------------------------------
; Vertical interrupt routine
; -------------------------------------------------------------------------

VInterrupt:
	bset	#0,GAIRQ2			; Send Sub CPU IRQ2 request
	movem.l	d0-a6,-(sp)			; Save registers

	tst.b	vintRoutine.w			; Are we lagging?
	beq.s	VInt_Lag			; If so, branch

	move.w	VDPCTRL,d0	
	move.l	#$40000010,VDPCTRL		; Update VScroll
	move.l	vscrollScreen.w,VDPDATA

	btst	#6,versionCache			; Is this a PAL console?
	beq.s	.NotPAL				; If not, branch
	move.w	#$700,d0			; Delay for a bit
	dbf	d0,*

.NotPAL:
	move.b	vintRoutine.w,d0		; Get V-INT routine ID
	move.b	#0,vintRoutine.w		; Mark V-INT as run
	andi.w	#$3E,d0
	move.w	VInt_Index(pc,d0.w),d0		; Run the current V-INT routine
	jsr	VInt_Index(pc,d0.w)

VInt_Finish:
	jsr	UpdateFMQueues			; Update FM driver queues

VInt_Done:
	addq.l	#1,levelVIntCounter		; Increment frame counter

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------

VInt_Index:
	dc.w	VInt_Lag-VInt_Index		; Lag
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen

; -------------------------------------------------------------------------
; V-INT lag routine
; -------------------------------------------------------------------------

VInt_Lag:
	tst.b	levelStarted			; Has the level started?
	beq.w	VInt_Finish			; If not, branch
	cmpi.b	#2,zone				; Are we in Tidal Tempest?
	bne.w	VInt_Finish			; If not, branch

	move.w	VDPCTRL,d0
	btst	#6,versionCache			; Is this a PAL console?
	beq.s	.NotPAL				; If not, branch
	move.w	#$700,d0			; Delay for a bit
	dbf	d0,*

.NotPAL:
	move.w	#1,hintFlag.w			; Set H-INT flag
	jsr	StopZ80				; Stop the Z80

	tst.b	waterFullscreen.w		; Is water filling the screen?
	bne.s	.WaterPal			; If so, branch
	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	bra.s	.Done

.WaterPal:
	LVLDMA	waterPalette,$0000,$80,CRAM	; DMA water palette

.Done:
	move.w	vdpReg0A.w,(a5)			; Update H-INT counter
	jsr	StartZ80			; Start the Z80

	bra.w	VInt_Finish			; Finish V-INT

; -------------------------------------------------------------------------
; V-INT title screen routine
; -------------------------------------------------------------------------

VInt_S1Title:
	bsr.w	DoVIntUpdates			; Do V-INT updates
	bsr.w	DrawLevelBG			; Draw level BG
	bsr.w	DecompPLCFast			; Process PLC art decompression

	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Do common V-INT updates
; -------------------------------------------------------------------------

DoVIntUpdates:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadControllers			; Read controllers

	tst.b	waterFullscreen.w		; Is water filling the screen?
	bne.s	.WaterPal			; If so, branch
	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	bra.s	.LoadedPal

.WaterPal:
	LVLDMA	waterPalette,$0000,$80,CRAM	; DMA water palette

.LoadedPal:
	LVLDMA	sprites,$F800,$280,VRAM		; DMA sprites
	LVLDMA	hscroll,$FC00,$380,VRAM		; DMA horizontal scroll data

	jmp	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Horizontal interrupt
; -------------------------------------------------------------------------

HInterrupt:
	rte

; -------------------------------------------------------------------------
