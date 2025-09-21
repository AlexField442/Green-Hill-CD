; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Palmtree Panic animated tiles update
; -------------------------------------------------------------------------

UpdateAnimTiles:
	rts
.size		= 8	; number of tiles per frame

	subq.b	#1,(ani0_time).w ; decrement timer
	bpl.s	AniArt_GHZ_Bigflower ; branch if not 0

	move.b	#6-1,(ani0_time).w ; time to display each frame
	lea	(Art_GhzWater).l,a1 ; load waterfall patterns
	move.b	(ani0_frame).w,d0
	addq.b	#1,(ani0_frame).w ; increment frame counter
	andi.w	#1,d0		; there are only 2 frames
	beq.s	.isframe0	; branch if frame 0
	lea	.size*8*8/2(a1),a1 ; use graphics for frame 1

.isframe0:
	move.l	#$6F000001,(VDPCTRL).l	; VRAM address
	move.w	#.size-1,d1	; number of 8x8 tiles
	bra.w	LoadTiles
; ===========================================================================

AniArt_GHZ_Bigflower:

.size		= 16	; number of tiles per frame

	subq.b	#1,(ani1_time).w
	bpl.s	AniArt_GHZ_Smallflower

	move.b	#$10-1,(ani1_time).w
	lea	(Art_GhzFlower1).l,a1 ; load big flower patterns
	move.b	(ani1_frame).w,d0
	addq.b	#1,(ani1_frame).w
	andi.w	#1,d0
	beq.s	.isframe0
	lea	.size*8*8/2(a1),a1

.isframe0:
	move.l	#$6B800001,(VDPCTRL).l	; VRAM address
	move.w	#.size-1,d1
	bra.w	LoadTiles
; ===========================================================================

AniArt_GHZ_Smallflower:

.size		= 12	; number of tiles per frame

	subq.b	#1,(ani2_time).w
	bpl.s	.end

	move.b	#8-1,(ani2_time).w
	move.b	(ani2_frame).w,d0
	addq.b	#1,(ani2_frame).w ; increment frame counter
	andi.w	#3,d0		; there are 4 frames
	move.b	.sequence(pc,d0.w),d0
	btst	#0,d0		; is frame 0 or 2? (actual frame, not frame counter)
	bne.s	.isframe1	; if not, branch
	move.b	#$7F,(ani2_time).w ; set longer duration for frames 0 and 2

.isframe1:
	lsl.w	#7,d0		; multiply frame num by $80
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0		; multiply that by 3 (i.e. frame num times 12 * $20)
	move.l	#$6D800001,(VDPCTRL).l	; VRAM address
	lea	(Art_GhzFlower2).l,a1 ; load small flower patterns
	lea	(a1,d0.w),a1	; jump to appropriate tile
	move.w	#.size-1,d1
	bsr.w	LoadTiles

.end:
	rts

.sequence:	dc.b 0,	1, 2, 1

; ---------------------------------------------------------------------------
; Subroutine to transfer graphics to VRAM

; input:
; a1 = source address
; a6 = vdp_data_port ($C00000)
; d1 = number of tiles to load (minus one)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadTiles:
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	dbf	d1,LoadTiles
	rts
; End of function LoadTiles