; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Palmtree Panic Present palette cycle
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle palette cycling
; -------------------------------------------------------------------------

PaletteCycle:
	lea	PaletteCycleData,a0		; Prepare first palette data set

	subq.w	#1,palCycleTimers.w		; Decrement timer
	bpl.s	.SkipCycle			; If this cycle's timer isn't done, branch
	move.w	#5,palCycleTimers.w		; Reset the timer

	move.w	palCycleSteps.w,d0
	addq.w	#1,palCycleSteps.w		; Increment the palette cycle frame
	andi.w	#3,d0				; Wrap it back to 0 if we reach frame 4
	lsl.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lea	palette+$50.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.SkipCycle:
	rts

; -------------------------------------------------------------------------
; Palette cycle data
; -------------------------------------------------------------------------

PaletteCycleData:
	incbin	"Level/Palmtree Panic/Data/Palette Cycle (Present).bin"
	even