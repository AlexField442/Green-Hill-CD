; -------------------------------------------------------------------------
; Sonic 1 for Sega CD
; -------------------------------------------------------------------------
; Sonic object
; -------------------------------------------------------------------------

ObjTitleSonic:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	TitleSonic_Index(pc,d0.w),d1
	jmp	TitleSonic_Index(pc,d1.w)
; ===========================================================================
TitleSonic_Index:
	dc.w TitleSonic_Main-TitleSonic_Index
	dc.w TitleSonic_Delay-TitleSonic_Index
	dc.w TitleSonic_Move-TitleSonic_Index
	dc.w TitleSonic_Animate-TitleSonic_Index
; ===========================================================================

TitleSonic_Main:	; Routine 0
	addq.b	#2,oRoutine(a0)
	move.w	#$F0,oX(a0)
	move.w	#$DE,oYScr(a0)		; position is fixed to screen
	move.l	#Map_TitleSonic,oMap(a0)
	move.w	#$2300,oTile(a0)
	move.b	#1,oPriority(a0)
	move.b	#29,oAnimTime+1(a0)	; set time delay to 0.5 seconds
	lea	(Ani_TitleSonic).l,a1
	bsr.w	AnimateObject

TitleSonic_Delay:	; Routine 2
	subq.b	#1,oAnimTime+1(a0)	; subtract 1 from time delay
	bpl.s	.wait			; if time remains, branch
	addq.b	#2,oRoutine(a0)	; go to next routine
	bra.w	DrawObject

.wait:
	rts
; ===========================================================================

TitleSonic_Move:	; Routine 4
	subq.w	#8,oYScr(a0)		; move Sonic up
	cmpi.w	#$96,oYScr(a0)		; has Sonic reached final position?
	bne.s	.display		; if not, branch
	addq.b	#2,oRoutine(a0)

.display:
	bra.w	DrawObject
; ===========================================================================

TitleSonic_Animate:	; Routine 6
	lea	(Ani_TitleSonic).l,a1
	bsr.w	AnimateObject
	bra.w	DrawObject

; ===========================================================================
; ---------------------------------------------------------------------------
; Animation Script
; ---------------------------------------------------------------------------

Ani_TitleSonic:	dc.w byte_A706-Ani_TitleSonic
byte_A706:	dc.b 7,	0, 1, 2, 3, 4, 5, 6, 7,	$FE, 2

; ---------------------------------------------------------------------------
; Mappings
; ---------------------------------------------------------------------------

Map_TitleSonic:
		include	"Title Screen/_Objects/Sonic/Data/Mappings.asm"
		even