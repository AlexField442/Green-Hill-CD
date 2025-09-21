; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Level events
; -------------------------------------------------------------------------

RunLevelEvents:
	moveq	#0,d0				; Run level events
	move.b	zone,d0
	add.w	d0,d0
	move.w	.Events(pc,d0.w),d0
	jsr	.Events(pc,d0.w)

	moveq	#2,d1				; Bottom boundary shift speed
	move.w	destBottomBound.w,d0		; Is the bottom boundary shifting?
	sub.w	bottomBound.w,d0
	beq.s	.End				; If not, branch
	bcc.s	.MoveDown			; If it's scrolling down, branch

	neg.w	d1				; Set the speed to go up
	move.w	cameraY.w,d0			; Is the camera past the target bottom boundary?
	cmp.w	destBottomBound.w,d0
	bls.s	.ShiftUp			; If not, branch
	move.w	d0,bottomBound.w		; Set the bottom boundary to be where the camera id
	andi.w	#$FFFE,bottomBound.w

.ShiftUp:
	add.w	d1,bottomBound.w		; Shift the boundary up
	move.b	#1,btmBoundShift.w		; Mark as shifting

.End:
	rts

.MoveDown:
	move.w	cameraY.w,d0			; Is the camera near the bottom boundary?
	addq.w	#8,d0
	cmp.w	bottomBound.w,d0
	bcs.s	.ShiftDown			; If not, branch
	btst	#1,objPlayerSlot+oFlags.w	; Is the player in the air?
	beq.s	.ShiftDown			; If not, branch
	add.w	d1,d1				; If so, quadruple the shift speed
	add.w	d1,d1

.ShiftDown:
	add.w	d1,bottomBound.w		; Shift the boundary down
	move.b	#1,btmBoundShift.w		; Mark as shifting
	rts

; -------------------------------------------------------------------------

.Events:
	dc.w	LevEvents_GHZ-.Events

; -------------------------------------------------------------------------
; Green Hill level events
; -------------------------------------------------------------------------

LevEvents_GHZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_GHZ_Index(pc,d0.w),d0
	jmp	LevEvents_GHZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_GHZ_Index:
	dc.w	LevEvents_GHZ1-LevEvents_GHZ_Index
	dc.w	LevEvents_GHZ2-LevEvents_GHZ_Index
	dc.w	LevEvents_GHZ3-LevEvents_GHZ_Index

; -------------------------------------------------------------------------

LevEvents_GHZ1:
	move.w	#$300,destBottomBound.w
	cmpi.w	#$1780,cameraX.w	; has the camera reached $1780 on the x-axis?
	blo.s	.End			; if not, branch
	move.w	#$400,destBottomBound.w

.End:
	rts

; -------------------------------------------------------------------------

LevEvents_GHZ2:
	move.w	#$300,destBottomBound.w
	cmpi.w	#$ED0,cameraX.w		; has the camera reached $ED0 on the x-axis?
	blo.s	.End			; if not, branch
	move.w	#$200,destBottomBound.w
	cmpi.w	#$1600,cameraX.w	; has the camera reached $1600 on the x-axis?
	blo.s	.End			; if not, branch
	move.w	#$400,destBottomBound.w
	cmpi.w	#$1D60,cameraX.w	; has the camera reached $1600 on the x-axis?
	blo.s	.End			; if not, branch
	move.w	#$300,destBottomBound.w

.End:
	rts

; -------------------------------------------------------------------------

LevEvents_GHZ3:
	move.w	#$300,destBottomBound.w
	cmpi.w	#$380,cameraX.w		; has the camera reached $380 on the x-axis?
	blo.s	.End			; if not, branch
	move.w	#$310,destBottomBound.w
	cmpi.w	#$960,cameraX.w		; has the camera reached $960 on the x-axis?
	blo.s	.End			; if not, branch
	cmpi.w	#$280,cameraY.w		; has the camera reached $280 on the y-axis?
	blo.s	.LockForBoss		; if not, branch
	move.w	#$400,destBottomBound.w
	cmpi.w	#$1380,cameraX.w	; has the camera reached $1380 on the x-axis?
	bhs.s	.SecondCheck		; if not, branch
	move.w	#$4C0,destBottomBound.w
	move.w	#$4C0,bottomBound.w

.SecondCheck:
	cmpi.w	#$1700,cameraX.w	; has the camera reached $1700 on the x-axis?
	bhs.s	.LockForBoss		; if not, branch

.End:
	rts

.LockForBoss:
	move.w	#$300,destBottomBound.w
	rts