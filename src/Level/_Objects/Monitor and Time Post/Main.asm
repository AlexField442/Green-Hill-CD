; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Monitor object
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle monitor solidity
; -------------------------------------------------------------------------

ObjMonitor_Solid:
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.DoSolid			; If not, branch
	tst.b	layer				; Is the player on layer 1?
	beq.s	.Layer1				; If so, branch
	tst.b	oLayer(a0)			; Are we on layer 2?
	bne.s	.DoSolid			; If so, branch
	rts

.Layer1:
	tst.b	oLayer(a0)			; Are we on layer 1?
	beq.s	.DoSolid			; If so, branch
	rts

.DoSolid:
	move.w	oX(a0),d3			; Handle solidity
	move.w	oY(a0),d4
	jmp	SolidObject

; -------------------------------------------------------------------------
; Monitor object
; -------------------------------------------------------------------------

oMonitorFall	EQU	oRoutine2		; Fall flag

ObjMonitor:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jmp	.Index(pc,d1.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjMonitor_Init-.Index
	dc.w	ObjMonitor_Main-.Index
	dc.w	ObjMonitor_Break-.Index
	dc.w	ObjMonitor_Animate-.Index
	dc.w	ObjMonitor_Draw-.Index
	
; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjMonitor_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	move.b	#$E,oYRadius(a0)		; Set height
	move.b	#$E,oXRadius(a0)		; Set width
	move.l	#MapSpr_MonitorTime,oMap(a0)	; Set mappings
	move.w	#$5A8,oTile(a0)			; Set base tile ID
	move.b	#3,oPriority(a0)		; Set priority
	move.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#$F,oWidth(a0)			; Set width

	lea	savedObjFlags,a2		; Saved object flags
	moveq	#0,d0				; Get base entry offset
	move.b	oSavedFlagsID(a0),d0
	bclr	#7,2(a2,d0.w)
	btst	#0,2(a2,d0.w)			; Is this monitor already broken?
	beq.s	.NotBroken			; If not, branch
	move.b	#8,oRoutine(a0)			; If so, set as broken
	move.b	#$11,oMapFrame(a0)
	rts

.NotBroken:
	move.b	#$40|6,oColType(a0)		; Enable collision
	move.b	oSubtype(a0),oAnim(a0)		; Set animation

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjMonitor_Main:
	tst.b	oSprFlags(a0)			; Are we on screen?
	bpl.w	ObjMonitor_Draw			; If not, branch
	
	move.b	oMonitorFall(a0),d0		; Are we set to fall?
	beq.s	.CheckSolid			; If not, branch
	
	bsr.w	ObjMoveGrv			; Fall
	jsr	ObjGetFloorDist			; Check floor collision
	tst.w	d1
	bpl.w	ObjMonitor_Animate		; If we have not hit the floor, branch
	add.w	d1,oY(a0)			; Align with floor
	clr.w	oYVel(a0)			; Stop falling
	clr.b	oMonitorFall(a0)
	bra.w	ObjMonitor_Animate

.CheckSolid:
	tst.b	oSprFlags(a0)			; Are we on screen?
	bpl.s	ObjMonitor_Animate		; If not, branch
	
	lea	objPlayerSlot.w,a1		; Handle solidity
	bsr.w	ObjMonitor_Solid

; -------------------------------------------------------------------------
; Animate sprite
; -------------------------------------------------------------------------

ObjMonitor_Animate:
	tst.w	timeStopTimer			; Is time stopped?
	bne.s	ObjMonitor_Draw			; If so, branch
	lea	Ani_Monitor,a1			; Animate sprite
	bsr.w	AnimateObject

; -------------------------------------------------------------------------
; Draw sprite
; -------------------------------------------------------------------------

ObjMonitor_Draw:
	bsr.w	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check despawn

; -------------------------------------------------------------------------
; Break
; -------------------------------------------------------------------------

ObjMonitor_Break:
	move.w	#FM_DESTROY,d0			; Play explosion sound
	jsr	PlayFMSound
	addq.b	#4,oRoutine(a0)			; Destroyed
	move.b	#0,oColType(a0)
	
	bsr.w	FindObjSlot			; Spawn item
	bne.s	.NoItem
	move.b	#$2E,oID(a1)
	move.w	oX(a0),oX(a1)			; Set position
	move.w	oY(a0),oY(a1)
	move.b	oAnim(a0),oAnim(a1)		; Set animation
	move.b	oLayer(a0),oLayer(a1)		; Set layer

.NoItem:
	bsr.w	FindObjSlot			; Spawn explosion
	bne.s	.NoExplosion
	move.b	#$18,oID(a1)
	move.w	oX(a0),oX(a1)			; Set position
	move.w	oY(a0),oY(a1)
	move.b	#1,oExplodeBadnik(a1)		; Not from badnik
	move.b	#1,oSubtype(a1)
	move.b	oLayer(a0),oLayer(a1)		; Set layer

.NoExplosion:
	lea	savedObjFlags,a2		; Saved object flags
	moveq	#0,d0				; Get base entry offset
	move.b	oSavedFlagsID(a0),d0
	bset	#0,2(a2,d0.w)
	move.b	#$11,oMapFrame(a0)		; Set broken sprite frame
	bra.w	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Monitor item object
; -------------------------------------------------------------------------

oMonItemDel	EQU	oAnimTime		; Deletion timer

; -------------------------------------------------------------------------

ObjMonitorItem:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jsr	.Index(pc,d1.w)
	
	bra.w	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjMonitorItem_Init-.Index
	dc.w	ObjMonitorItem_Main-.Index
	dc.w	ObjMonitorItem_Delete-.Index
	
; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjMonitorItem_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	move.w	#$85A8,oTile(a0)		; Set base tile ID
	tst.b	oLayer(a0)			; Are we on layer 2?
	beq.s	.NotPriority			; If so, branch
	andi.b	#$7F,oTile(a0)			; Set low priority

.NotPriority:
	move.b	#%00100100,oSprFlags(a0)	; Set sprite flags
	move.b	#3,oPriority(a0)		; Set priority
	move.b	#8,oWidth(a0)			; Set width
	move.w	#-$300,oYVel(a0)		; Move up
	
	moveq	#0,d0				; Set sprite frame
	move.b	oAnim(a0),d0
	move.b	d0,oMapFrame(a0)
	
	movea.l	#MapSpr_MonitorTime,a1		; Set mappings
	add.b	d0,d0
	adda.w	(a1,d0.w),a1
	addq.w	#1,a1
	move.l	a1,oMap(a0)

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjMonitorItem_Main:
	tst.w	oYVel(a0)			; Are we moving up still?
	bpl.w	.GiveItem			; If not, branch
	bsr.w	ObjMove				; Move
	addi.w	#$18,oYVel(a0)			; Slow down
	rts

.GiveItem:
	addq.b	#2,oRoutine(a0)			; Disappear
	move.w	#30-1,oMonItemDel(a0)		; Set deletion timer

; -------------------------------------------------------------------------

.Check1UP:
	move.b	oAnim(a0),d0			; Get item type
	bne.s	.CheckRing			; Branch if this is not a 1UP

.Give1UP:
	addq.b	#1,lives			; Increment lives
	addq.b	#1,updateHUDLives
	move.w	#SCMD_YESSFX,d0			; Play 1UP sound
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.CheckRing:
	cmpi.b	#1,d0				; Is this a rings item?
	bne.s	.CheckShield			; If not, branch

.GiveRings:
	addi.w	#10,rings			; Add 10 rings
	ori.b	#1,updateHUDRings
	
	cmpi.w	#100,rings			; Have 100 rings been accumulated?
	bcs.s	.RingSound			; If not, branch
	bset	#1,livesFlags			; Set 100 rings flag
	beq.w	.Give1UP			; If it wasn't already set, branch
	cmpi.w	#200,rings			; Have 200 rings been accumulated?
	bcs.s	.RingSound			; If not, branch
	bset	#2,livesFlags			; Set 200 rings flag
	beq.w	.Give1UP			; If it wasn't already set, branch

.RingSound:
	move.w	#FM_RING,d0			; Play ring sound
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.CheckShield:
	cmpi.b	#2,d0				; Is this a shield item?
	bne.s	.CheckInvinc			; If not, branch

.GiveShield:
	move.b	#1,shield			; Set shield flag
	move.b	#3,objShieldSlot.w		; Spawn shield
	move.w	#FM_SHIELD,d0			; Play shield sound
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.CheckInvinc:
	cmpi.b	#3,d0				; Is this an invincibility item?
	bne.s	.CheckSpeedShoes		; If not, branch

.GiveInvinc:
	move.b	#1,invincible			; Set invincible flag
	if REGION=USA				; Set invincibility timer
		move.w	#1320,objPlayerSlot+oPlayerInvinc.w
	else
		move.w	#1200,objPlayerSlot+oPlayerInvinc.w
	endif
	
	move.b	#3,objInvStar1Slot.w		; Spawn invincibility stars
	move.b	#1,objInvStar1Slot+oAnim.w
	move.b	#3,objInvStar2Slot.w
	move.b	#2,objInvStar2Slot+oAnim.w
	move.b	#3,objInvStar3Slot.w
	move.b	#3,objInvStar3Slot+oAnim.w
	move.b	#3,objInvStar4Slot.w
	move.b	#4,objInvStar4Slot+oAnim.w
	
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#SCMD_FADEPCM,d0		; If so, fade out PCM
	jsr	SubCPUCmd

.NotPast:
	move.w	#SCMD_INVINCMUS,d0		; Play invincibility music
	jmp	SubCPUCmd
	rts

; -------------------------------------------------------------------------

.CheckSpeedShoes:
	cmpi.b	#4,d0				; Is this a speed shoes item?
	bne.s	.CheckTimeStop			; If not, branch

.GiveSpeedShoes:
	move.b	#1,speedShoes			; Set speed shoes flag
	if REGION=USA				; Set speed shoes timer
		move.w	#1320,objPlayerSlot+oPlayerShoes.w
	else
		move.w	#1200,objPlayerSlot+oPlayerShoes.w
	endif
	
	move.w	#$C00,sonicTopSpeed.w		; Speed the player up
	move.w	#$18,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w
	
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast2			; If not, branch
	move.w	#SCMD_FADEPCM,d0		; If so, fade out PCM
	jsr	SubCPUCmd

.NotPast2:
	move.w	#SCMD_SHOESMUS,d0		; Play speed shoes music
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.CheckTimeStop:
	cmpi.b	#5,d0				; Is this a time stop item?
	bne.s	.CheckCombine			; If not, branch
	
.GiveTimeStop:
	move.w	#300,timeStopTimer		; Set time stop timer
	rts

; -------------------------------------------------------------------------

.CheckCombine:
	cmpi.b	#6,d0				; Is this a combine ring item?
	bne.s	.CheckS				; If not, branch
	
.GiveCombineRing:
	move.w	#FM_SIGNPOST,d0			; Play sound
	jsr	PlayFMSound
	move.b	#1,combineRing			; Set combine ring flag
	rts

; -------------------------------------------------------------------------

.CheckS:
	bsr.w	.GiveShield			; Give shield
	bsr.w	.GiveInvinc			; Give invincibility
	bra.s	.GiveSpeedShoes			; Give speed shoes
	
; -------------------------------------------------------------------------
; Delete
; -------------------------------------------------------------------------

ObjMonitorItem_Delete:
	subq.w	#1,oMonItemDel(a0)		; Decrement timer
	bmi.w	DeleteObject			; If it has run out, delete ourselves
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Ani_Monitor:
	include	"Level/_Objects/Monitor and Time Post/Data/Animations.asm"
	even
	
MapSpr_MonitorTime:
	include	"Level/_Objects/Monitor and Time Post/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
