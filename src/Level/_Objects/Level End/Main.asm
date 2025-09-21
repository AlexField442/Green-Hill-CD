; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Level end objects
; -------------------------------------------------------------------------

oLvlEndTimer	EQU	oVar2A			; Timer

; -------------------------------------------------------------------------
; Big ring flash object
; -------------------------------------------------------------------------

ObjBigRingFlash:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjBigRingFlash_Init-.Index
	dc.w	ObjBigRingFlash_Animate-.Index
	dc.w	ObjBigRingFlash_Delete-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjBigRingFlash_Init:
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	addq.b	#2,oRoutine(a0)			; Next routine
	move.w	#$3EF,oTile(a0)			; Set base tile ID
	move.l	#MapSpr_BigRingFlash,oMap(a0)	; Set mappings

; -------------------------------------------------------------------------
; Animate
; -------------------------------------------------------------------------

ObjBigRingFlash_Animate:
	lea	Ani_BigRingFlash,a1		; Animate sprite
	jmp	AnimateObject

; -------------------------------------------------------------------------
; Delete
; -------------------------------------------------------------------------

ObjBigRingFlash_Delete:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------
; Big ring object
; -------------------------------------------------------------------------

ObjBigRing:
	tst.b	oSubtype(a0)			; Is this a flash?
	bne.s	ObjBigRingFlash			; If so, branch
	cmpi.w	#50,rings			; Have 50 rings been collected?
	bcc.s	.Proceed			; If so, branch

	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		jmp	CheckObjDespawn		; Check despawn
	else
		jmp	DeleteObject		; Delete ourselves
	endif

.Proceed:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	cmpi.b	#4,oRoutine(a0)			; Has the big ring been touched?
	beq.s	.End				; If so, branch
	jmp	DrawObject			; If not, draw sprite

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjBigRing_Init-.Index
	dc.w	ObjBigRing_Main-.Index
	dc.w	ObjBigRing_Animate-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjBigRing_Init:
	cmpi.b	#%1111111,timeStones		; Have all the time stones been collected?
	bne.s	.TimeStonesLeft			; If not, branch
	jmp	DeleteObject			; If so, delete object

.TimeStonesLeft:
	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.Init				; If not, branch
	jmp	DeleteObject			; If so, delete object

.Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.w	#$2488,oTile(a0)		; Set base tile ID
	move.l	#MapSpr_BigRing,oMap(a0)	; Set mappings
	move.b	#$20,oXRadius(a0)		; Set width
	move.b	#$20,oWidth(a0)
	move.b	#$20,oYRadius(a0)		; Set height

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjBigRing_Main:
	lea	objPlayerSlot.w,a1		; Check if the player has touched us?
	bsr.w	ObjBigRing_CheckTouch
	beq.s	ObjBigRing_Animate		; If not, branch

	move.b	#1,specialStage			; Set special stage flag
	addq.b	#2,oRoutine(a0)			; Touched

	move.w	cameraX.w,d0			; Force player off screen
	addi.w	#336,d0
	move.w	d0,oX(a1)
	
	bset	#0,ctrlLocked.w			; Force right to be held
	move.w	#$808,playerCtrlHold.w
	move.w	#0,oXVel(a1)			; Stop player's movement
	move.w	#0,oPlayerGVel(a1)
	move.b	#1,scrollLock.w			; Lock camera

	move.w	#FM_BIGRING,d0			; Play sound
	jsr	PlayFMSound

	jsr	FindObjSlot			; Spawn flash
	bne.s	ObjBigRing_Main
	move.b	#$14,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#1,oSubtype(a1)

; -------------------------------------------------------------------------
; Animate
; -------------------------------------------------------------------------

ObjBigRing_Animate:
	lea	Ani_BigRing,a1			; Animate sprite
	jmp	AnimateObject

; -------------------------------------------------------------------------
; Check if the player has touched the big ring
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l  - Player object slot
; RETURNS:
;	eq/ne - No collision/Collision
; -------------------------------------------------------------------------

ObjBigRing_CheckTouch:
	move.b	oXRadius(a1),d1			; Check horizontal collision
	ext.w	d1
	addi.w	#16,d1
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollision			; If there was no collision, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision			; If there was no collision, branch

	move.b	oYRadius(a1),d1			; Check vertical collision
	ext.w	d1
	addi.w	#32,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollision			; If there was no collision, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision			; If there was no collision, branch

.Collided:
	moveq	#1,d0				; Collided
	rts

.NoCollision:
	moveq	#0,d0				; No collision
	rts

; -------------------------------------------------------------------------
; Signpost object
; -------------------------------------------------------------------------

ObjSignpost:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSignpost_Init-.Index
	dc.w	ObjSignpost_Main-.Index
	dc.w	ObjSignpost_Spin-.Index
	dc.w	StartResults-.Index
	dc.w	ResultsActive-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjSignpost_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#$18,oXRadius(a0)		; Set width
	move.b	#$18,oWidth(a0)
	move.b	#$20,oYRadius(a0)		; Set height
	move.b	#4,oPriority(a0)		; Set priority
	move.w	#$43C,oTile(a0)			; Set base tile ID
	cmpi.b	#3,zone				; Are we in Quartz Quadrant?
	beq.s	.NotHighPriority		; If so, branch
	ori.b	#$80,oTile(a0)			; If not, set high priority on sprite

.NotHighPriority:
	move.l	#MapSpr_GoalSignpost,oMap(a0)	; Set mappings

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjSignpost_Main:
	lea	objPlayerSlot.w,a6
	move.w	oY(a6),d0			; Check if the player is in range vertically
	sub.w	oY(a0),d0
	addi.w	#128,d0
	bmi.s	.End				; If not, branch
	cmpi.w	#256,d0
	bcc.s	.End				; If not, branch

	move.w	oX(a0),d0			; Has the player gone past us?
	cmp.w	oX(a6),d0
	bcc.s	.End				; If not, branch

	move.w	cameraX.w,leftBound.w		; Lock camera
	move.w	cameraX.w,destLeftBound.w

	clr.b	updateHUDTime			; Stop timer
	move.b	#120,oLvlEndTimer(a0)		; Set spin timer
	move.b	#0,oMapFrame(a0)		; Set to the Robotnik side
	addq.b	#2,oRoutine(a0)			; Next routine

	clr.b	speedShoes			; Disable speed shoes
	clr.b	invincible			; Disable invincibility

	move.w	#FM_SIGNPOST,d0			; Play signpost sound
	jmp	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Spin
; -------------------------------------------------------------------------

ObjSignpost_Spin:
	lea	Ani_Signpost,a1			; Animate sprite
	jsr	AnimateObject

	subq.b	#1,oLvlEndTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#2,oRoutine(a0)			; Spun
	move.b	#3,oMapFrame(a0)		; Set to the player side
	move.b	#60,oLvlEndTimer(a0)		; Set results delay timer

.End:
	rts

; -------------------------------------------------------------------------
; Start results
; -------------------------------------------------------------------------

StartResults:
	subq.b	#1,oLvlEndTimer(a0)		; Decrement timer
	bne.w	.End				; If it hasn't run out, branch

	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#SCMD_FADEPCM,d0		; If so, fade out PCM
	jsr	SubCPUCmd

.NotPast:
	move.w	#SCMD_RESULTMUS,d0		; Play results music
	jsr	SubCPUCmd

	bset	#0,ctrlLocked.w			; Force the player to move right
	move.w	#$808,playerCtrlHold.w
	cmpi.w	#$502,zoneAct			; Are we in Stardust Speedway act 3?
	bne.s	.NotSSZ3			; If not, branch
	move.w	#0,playerCtrlHold.w		; If so, force the player to stay still

.NotSSZ3:
	move.b	#180,oLvlEndTimer(a0)		; Set (unused) timer
	addq.b	#2,oRoutine(a0)			; Next routine

	jsr	FindObjSlot			; Spawn results
	move.b	#$3A,oID(a1)
	move.b	#16,oResultsTimer(a1)		; Set results spawn delay
	move.b	#1,updateHUDBonus.w		; Update bonus count

	moveq	#0,d0				; Get time bonus index
	move.b	timeMinutes,d0
	mulu.w	#60,d0
	moveq	#0,d1
	move.b	timeSeconds,d1
	add.w	d1,d0
	divu.w	#15,d0
	moveq	#(.TimeBonusesEnd-.TimeBonuses)/2-1,d1
	cmp.w	d1,d0
	bcs.s	.GetBonus
	move.w	d1,d0

.GetBonus:
	add.w	d0,d0				; Set time bonus
	move.w	.TimeBonuses(pc,d0.w),timeBonus.w

	move.w	rings,d0			; Set ring bonus
	mulu.w	#100,d0
	move.w	d0,ringBonus.w

.End:
	rts

; -------------------------------------------------------------------------

.TimeBonuses:
	dc.w	50000
	dc.w	50000
	dc.w	10000
	dc.w	5000
	dc.w	4000
	dc.w	4000
	dc.w	3000
	dc.w	3000
	dc.w	2000
	dc.w	2000
	dc.w	2000
	dc.w	2000
	dc.w	1000
	dc.w	1000
	dc.w	1000
	dc.w	1000
	dc.w	500
	dc.w	500
	dc.w	500
	dc.w	500
	dc.w	0
.TimeBonusesEnd:

; -------------------------------------------------------------------------
; Results active
; -------------------------------------------------------------------------

ResultsActive:
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Ani_BigRingFlash:
	include	"Level/_Objects/Level End/Data/Animations (Big Ring Flash).asm"
	even
MapSpr_BigRingFlash:
	include	"Level/_Objects/Level End/Data/Mappings (Big Ring Flash).asm"
	even
Art_BigRingFlash:
	incbin	"Level/_Objects/Level End/Data/Art (Big Ring Flash).nem"
	even

; -------------------------------------------------------------------------
