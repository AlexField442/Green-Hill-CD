; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Sonic object
; -------------------------------------------------------------------------

ObjSonic:
	tst.b	debugMode		; Are we in debug mode?
	beq.s	.NormalMode		; If not, branch
	jmp	UpdateDebugMode		; Handle debug mode

.NormalMode:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jmp	.Index(pc,d1.w)
; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSonic_Init-.Index		; Initialization
	dc.w	ObjSonic_Main-.Index		; Main
	dc.w	ObjSonic_Hurt-.Index		; Hurt
	dc.w	ObjSonic_Dead-.Index		; Death
	dc.w	ObjSonic_Restart-.Index		; Death delay and level restart

; -------------------------------------------------------------------------
; Sonic's initialization routine
; -------------------------------------------------------------------------

ObjSonic_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	move.b	#$13,oYRadius(a0)		; Default hitbox size
	move.b	#9,oXRadius(a0)
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$780,oTile(a0)			; Set base tile
	move.b	#2,oPriority(a0)		; Set priority
	move.b	#$18,oWidth(a0)			; Set width
	move.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.w	#$600,sonicTopSpeed.w		; Set physics values
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w

; -------------------------------------------------------------------------
; Sonic's main routine
; -------------------------------------------------------------------------

ObjSonic_Main:
	bsr.w	ObjSonic_ExtCamera		; Handle extended camera
	tst.w	debugCheat			; Is debug mode enabled?
	beq.s	.NoDebug			; If not, branch
	btst	#4,p1CtrlTap.w			; Was the B button pressed?
	beq.s	.NoDebug			; If not, branch
	move.b	#1,debugMode			; Enter debug mode
	rts

.NoDebug:
	tst.b	ctrlLocked.w			; Are controls locked?
	bne.s	.CtrlLock			; If so, branch
	move.w	p1CtrlData.w,playerCtrl.w	; Copy controller data

.CtrlLock:
	btst	#0,oPlayerCtrl(a0)		; Are we being controlled by another object?
	bne.s	.SkipControl			; If not, branch
	moveq	#0,d0				; Run player mode routine
	move.b	oFlags(a0),d0
	andi.w	#6,d0
	move.w	ObjSonic_ModeIndex(pc,d0.w),d1
	jsr	ObjSonic_ModeIndex(pc,d1.w)

.SkipControl:
	bsr.w	ObjSonic_Display		; Draw sprite and handle timers
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Water			; Handle water

						; Update our angle buffers
	move.b	primaryAngle.w,oPlayerPriAngle(a0)
	move.b	secondaryAngle.w,oPlayerSecAngle(a0)

	tst.b	windTunnelFlag.w		; Are we in a wind tunnel?
	beq.s	.NoWindTunnel			; If not, branch
	tst.b	oAnim(a0)			; Are we in the walking animation?
	bne.s	.NoWindTunnel			; If not, branch
	move.b	oPrevAnim(a0),oAnim(a0)		; Set animation to the previously saved animation ID

.NoWindTunnel:
	bsr.w	ObjSonic_Animate		; Animate sprite
	tst.b	oPlayerCtrl(a0)			; Has object collision been disabled?
	bmi.s	.NoObjCol			; If so, branch
	jsr	Player_ObjCollide		; Handle object collision

.NoObjCol:
	bsr.w	ObjSonic_SpecialChunks		; Handle special chunks
	rts

; -------------------------------------------------------------------------

ObjSonic_ModeIndex:
	dc.w	ObjSonic_MdGround-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdAir-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdRoll-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdJump-ObjSonic_ModeIndex

; -------------------------------------------------------------------------
; Handle the extended camera
; -------------------------------------------------------------------------

ObjSonic_ExtCamera:
	move.w	camXCenter.w,d1			; Get camera X center position

	move.w	oPlayerGVel(a0),d0		; Get how fast we are moving
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	cmpi.w	#$600,d0			; Are we going at max regular speed?
	bcs.s	.ResetPan			; If not, branch

	tst.w	oPlayerGVel(a0)			; Are we moving right?
	bpl.s	.MovingRight			; If so, branch

.MovingLeft:
	addq.w	#2,d1				; Pan the camera to the right
	cmpi.w	#(320/2)+64,d1			; Has it panned far enough?
	bcs.s	.SetPanVal			; If not, branch
	move.w	#(320/2)+64,d1			; Cap the camera's position
	bra.s	.SetPanVal

.MovingRight:
	subq.w	#2,d1				; Pan the camera to the left
	cmpi.w	#(320/2)-64,d1			; Has it panned far enough
	bcc.s	.SetPanVal			; If not, branch
	move.w	#(320/2)-64,d1			; Cap the camera's position
	bra.s	.SetPanVal

.ResetPan:
	cmpi.w	#320/2,d1			; Has the camera panned back to the middle?
	beq.s	.SetPanVal			; If so, branch
	bcc.s	.ResetLeft			; If it's panning back left

.ResetRight:
	addq.w	#2,d1				; Pan back to the right
	bra.s	.SetPanVal

.ResetLeft:
	subq.w	#2,d1				; Pan back to the left

.SetPanVal:
	move.w	d1,camXCenter.w			; Update camera X center position
	rts

; -------------------------------------------------------------------------
; Display Sonic's sprite and update timers
; -------------------------------------------------------------------------

ObjSonic_Display:
	move.w	oPlayerHurt(a0),d0		; Get current hurt time
	beq.s	.NotFlashing			; If we are not hurting, branch
	subq.w	#1,oPlayerHurt(a0)		; Decrement hurt time
	lsr.w	#3,d0				; Should we flash our sprite?
	bcc.s	.SkipDisplay			; If so, branch

.NotFlashing:
	jsr	DrawObject			; Draw sprite

.SkipDisplay:
	tst.b	invincible			; Are we invincible?
	beq.s	.NotInvincible			; If not, branch
	tst.w	oPlayerInvinc(a0)		; Is the invincibility timer active?
	beq.s	.NotInvincible			; If not, branch

	subq.w	#1,oPlayerInvinc(a0)		; Decrement invincibility time
	bne.s	.NotInvincible			; If it hasn't run out, branch

	tst.b	speedShoes			; Is the speed shoes music playing?
	bne.s	.StopInvinc			; If so, branch
	tst.b	bossMusic			; Is the boss music playing?
	bne.s	.StopInvinc			; If so, branch
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#SCMD_FADECDA,d0		; Fade out music
	jsr	SubCPUCmd

.NotPast:
	jsr	PlayLevelMusic			; Play level music

.StopInvinc:
	move.b	#0,invincible			; Stop invincibility

.NotInvincible:
	tst.b	speedShoes			; Do we have speed shoes?
	beq.s	.End				; If not, branch
	tst.w	oPlayerShoes(a0)		; Is the speed shoes timer active?
	beq.s	.End				; If not, branch

	subq.w	#1,oPlayerShoes(a0)		; Decrement speed shoes time
	bne.s	.End				; If it hasn't run out, branch

	move.w	#$600,sonicTopSpeed.w		; Return physics back to normal
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w

	tst.b	invincible			; Is the invincibility music playing?
	bne.s	.StopSpeedShoes			; If so, branch
	tst.b	bossMusic			; Is the boss music playing?
	bne.s	.StopSpeedShoes			; If so, branch
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast2			; If not, branch
	move.w	#SCMD_FADECDA,d0		; Fade out music
	jsr	SubCPUCmd

.NotPast2:
	jsr	PlayLevelMusic			; Play level music

.StopSpeedShoes:
	move.b	#0,speedShoes			; Stop speed shoes

.End:
	rts

; -------------------------------------------------------------------------
; Save Sonic's current position into the position buffer
; -------------------------------------------------------------------------

ObjSonic_RecordPos:
	move.w	sonicRecordIndex.w,d0		; Get pointer to current position buffer index
	lea	sonicRecordBuf.w,a1
	lea	(a1,d0.w),a1

	move.w	oX(a0),(a1)+			; Save our position
	move.w	oY(a0),(a1)+

	addq.b	#4,sonicRecordIndex+1.w		; Advance position buffer index
	rts

; -------------------------------------------------------------------------
; Handle Sonic underwater
; -------------------------------------------------------------------------

ObjSonic_Water:
	cmpi.b	#2,zone				; Are we in Tidal Tempest?
	beq.s	.HasWater			; If so, branch

.End:
	rts

.HasWater:
	move.w	waterHeight.w,d0		; Are we in the water?
	cmp.w	oY(a0),d0
	bge.s	.OutWater			; If not, branch

	bset	#6,oFlags(a0)			; Mark as underwater
	bne.s	.End				; If we were already marked as such, branch

	move.b	#$21,objBubblesSlot.w		; Create bubbles that come out of our mouth
	move.b	#$81,objBubblesSlot+oSubtype.w

	move.w	#$300,sonicTopSpeed.w		; Set to water physics
	move.w	#6,sonicAcceleration.w
	move.w	#$40,sonicDeceleration.w

	asr	oXVel(a0)			; Slow ourselves down in the water
	asr	oYVel(a0)
	asr	oYVel(a0)
	beq.s	.End				; If we entered the water slowly, branch
	move.b	#$B,oID(a0)
	rts

; -------------------------------------------------------------------------

.OutWater:
	bclr	#6,oFlags(a0)			; Mark as not underwater
	beq.s	.End				; If we were already marked as such, branch

	move.w	#$600,sonicTopSpeed.w		; Return physics back to normal
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w

	asl	oYVel(a0)			; Accelerate ourselves out of the water
	beq.w	.End				; If we are still moving up too slowly, branch
	move.b	#$B,oID(a0)
	cmpi.w	#-$1000,oYVel(a0)		; Are we moving up too fast?
	bgt.s	.End				; If not, branch
	move.w	#-$1000,oYVel(a0)		; Cap our speed
	rts

; -------------------------------------------------------------------------
; Sonic's ground mode routine
; -------------------------------------------------------------------------

ObjSonic_MdGround:
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_SlopeResist		; Handle slope resistance
	bsr.w	ObjSonic_MoveGround		; Handle movement
	bsr.w	ObjSonic_CheckRoll		; Check for rolling
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMove				; Apply velocity
	bsr.w	Player_GroundCol		; Handle level collision
	bsr.w	ObjSonic_CheckFallOff		; Check for falling off a steep slope or ceiling
	rts

; -------------------------------------------------------------------------
; Sonic's air mode routine
; -------------------------------------------------------------------------

ObjSonic_MdAir:
	bsr.w	ObjSonic_JumpHeight		; Handle jump height
	bsr.w	ObjSonic_MoveAir		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMoveGrv			; Apply velocity
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$28,oYVel(a0)			; Apply water gravity resistance

.NoWater:
	bsr.w	ObjSonic_JumpAngle		; Reset angle
	bsr.w	Player_LevelColInAir		; Handle level collision
	rts

; -------------------------------------------------------------------------
; Sonic's roll mode routine
; -------------------------------------------------------------------------

ObjSonic_MdRoll:
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_SlopeResistRoll	; Handle slope resistance
	bsr.w	ObjSonic_MoveRoll		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMove				; Apply velocity
	bsr.w	Player_GroundCol		; Handle level collision
	bsr.w	ObjSonic_CheckFallOff		; Check for falling off a steep slope or ceiling
	rts

; -------------------------------------------------------------------------
; Sonic's jump mode routine
; -------------------------------------------------------------------------

ObjSonic_MdJump:
	bsr.w	ObjSonic_JumpHeight		; Handle jump height
	bsr.w	ObjSonic_MoveAir		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMoveGrv			; Apply velocity
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$28,oYVel(a0)			; Apply water gravity resistance

.NoWater:
	bsr.w	ObjSonic_JumpAngle		; Reset angle
	bsr.w	Player_LevelColInAir		; Handle level collision
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGround:
	move.w	sonicTopSpeed.w,d6		; Get top speed
	move.w	sonicAcceleration.w,d5		; Get acceleration
	move.w	sonicDeceleration.w,d4		; Get deceleration

	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.w	.CalcXYVels			; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement locked temporarily?
	bne.w	.ResetScreen			; If so, branch

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.NotLeft			; If not, branch
	bsr.w	ObjSonic_MoveGndLeft		; Move left

.NotLeft:
	btst	#3,playerCtrlHold.w		; Are we holding right
	beq.s	.NotRight			; If not, branch
	bsr.w	ObjSonic_MoveGndRight		; Move right

.NotRight:
	move.b	oAngle(a0),d0			; Are we on firm on the ground?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.w	.ResetScreen			; If not, branch
	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	bne.w	.ResetScreen			; If not, branch

	bclr	#5,oFlags(a0)			; Stop pushing
	move.b	#5,oAnim(a0)			; Set animation to idle animation
	btst	#3,oFlags(a0)			; Are we standing on an object?
	beq.s	.BalanceGround			; If not, branch

	moveq	#0,d0				; Get the object we are standing on
	move.b	oPlayerStandObj(a0),d0
	lsl.w	#6,d0
	lea	objects.w,a1
	lea	(a1,d0.w),a1
	tst.b	oFlags(a1)			; Is it a special hazardous object?
	bmi.w	.LookUp				; If so, branch
	moveq	#0,d1				; Get distance from an edge of the object
	move.b	oWidth(a1),d1
	move.w	d1,d2
	add.w	d2,d2
	subq.w	#4,d2
	add.w	oX(a0),d1
	sub.w	oX(a1),d1
	cmpi.w	#4,d1				; Are we at least 4 pixels away from the left edge?
	blt.s	.BalanceLeft			; If so, branch
	cmp.w	d2,d1				; Are we at least 4 pixels away from the right edge?
	bge.s	.BalanceRight			; If so, branch
	bra.s	.LookUp				; Check for peelout/spindash charge

.BalanceGround:
	jsr	ObjGetFloorDist			; Are we leaning near a ledge on either side?
	cmpi.w	#$C,d1
	blt.s	.LookUp				; If not, branch
	cmpi.b	#3,oPlayerPriAngle(a0)		; Are we leaning near a ledge on the right?
	bne.s	.CheckLeft			; If not, branch

.BalanceRight:
	btst	#0,oFlags(a0)			; Are we facing left?
	bne.s	.BalanceAniBackwards		; If so, use the backwards animation
	bra.s	.BalanceAniForwards		; Use the forwards animation

.CheckLeft:
	cmpi.b	#3,oPlayerSecAngle(a0)		; Are we leaning near a ledge on the left?
	bne.s	.LookUp				; If not, branch

.BalanceLeft:
	btst	#0,oFlags(a0)			; Are we facing left?
	bne.s	.BalanceAniForwards		; If so, use the forwards animation

.BalanceAniBackwards:
	move.b	#$32,oAnim(a0)			; Set animation to balancing backwards animation
	bra.w	.ResetScreen			; Reset screen position

.BalanceAniForwards:
	move.b	#6,oAnim(a0)			; Set animation to balancing forwards animation
	bra.w	.ResetScreen			; Reset screen position
; -------------------------------------------------------------------------

.LookUp:
	btst	#0,playerCtrlHold.w		; Are we holding up?
	beq.s	.Duck				; If not, branch

	move.b	#7,oAnim(a0)			; Set animation to looking up animation
	cmpi.w	#$C8,camYCenter.w		; Has the screen scrolled up all the way?
	beq.w	.Settle				; If so, branch
	addq.w	#2,camYCenter.w			; Move the screen up
	bra.w	.Settle				; Settle movement
; -------------------------------------------------------------------------

.Duck:
	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.ResetScreen			; If not, branch

	move.b	#8,oAnim(a0)			; Set animation to ducking animation
	cmpi.w	#8,camYCenter.w			; Has the screen scrolled dowm all the way?
	beq.s	.Settle				; If so, branch
	subq.w	#2,camYCenter.w			; Move the screen down
	bra.s	.Settle				; Settle movement
; -------------------------------------------------------------------------

.ResetScreen:
	cmpi.w	#$60,camYCenter.w		; Is the screen centered?
	bne.s	.CheckIncShift			; If not, branch

	move.b	lookMode.w,d0			; Get look double tap timer
	andi.b	#$F,d0
	bne.s	.Settle				; If it's active, branch
	move.b	#0,lookMode.w			; Reset double tap timer and charge lock flags
	bra.s	.Settle				; Settle movement

.CheckIncShift:
	bcc.s	.DecShift			; If the screen needs to move back down, branch
	addq.w	#4,camYCenter.w			; Move the screen back up

.DecShift:
	subq.w	#2,camYCenter.w			; Move the screen back down

; -------------------------------------------------------------------------

.Settle:
	move.b	playerCtrlHold.w,d0		; Are we holding left or right?
	andi.b	#$C,d0
	bne.s	.CalcXYVels			; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.CalcXYVels			; If we aren't moving at all, branch
	bmi.s	.SettleLeft			; If we are moving left, branch

	sub.w	d5,d0				; Settle right
	bcc.s	.SetGVel			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	bra.s	.CalcXYVels			; Calculate X and Y velocities

.SettleLeft:
	add.w	d5,d0				; Settle left
	bcc.s	.SetGVel2			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

.CalcXYVels:
	move.b	oAngle(a0),d0			; Get sine and cosine of our current angle
	jsr	CalcSine
	muls.w	oPlayerGVel(a0),d1		; Get X velocity (ground velocity * cos(angle))
	asr.l	#8,d1
	move.w	d1,oXVel(a0)
	muls.w	oPlayerGVel(a0),d0		; Get Y velocity (ground velocity * sin(angle))
	asr.l	#8,d0
	move.w	d0,oYVel(a0)

; -------------------------------------------------------------------------
; Handle wall collision for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckWallCol:
	move.b	oAngle(a0),d0			; Are we moving on a ceiling?
	addi.b	#$40,d0
	bmi.s	.End				; If so, branch

	move.b	#$40,d1				; Get angle to point the sensor towards (angle +/- 90 degrees)
	tst.w	oPlayerGVel(a0)
	beq.s	.End
	bmi.s	.RotAngle
	neg.w	d1

.RotAngle:
	move.b	oAngle(a0),d0
	add.b	d1,d0

	move.w	d0,-(sp)			; Get distance from wall
	bsr.w	Player_CalcRoomInFront
	move.w	(sp)+,d0
	tst.w	d1
	bpl.s	.End				; If we aren't colliding with a wall, branch
	asl.w	#8,d1				; Get zip distance

	addi.b	#$20,d0				; Get the angle of the wall
	andi.b	#$C0,d0
	beq.s	.ZipUp				; If we are facing a wall downwards, branch
	cmpi.b	#$40,d0				; Are we facing a wall on the left?
	beq.s	.ZipRight			; If so, branch
	cmpi.b	#$80,d0				; Are we facing a wall upwards?
	beq.s	.ZipDown			; If so, branch
	add.w	d1,oXVel(a0)			; Zip to the left
	bset	#5,oFlags(a0)			; Mark as pushing
	move.w	#0,oPlayerGVel(a0)		; Stop moving
	rts

.ZipDown:
	sub.w	d1,oYVel(a0)			; Zip downwards
	rts

.ZipRight:
	sub.w	d1,oXVel(a0)			; Zip to the right
	bset	#5,oFlags(a0)			; Mark as pushing
	move.w	#0,oPlayerGVel(a0)		; Stop moving
	rts

.ZipUp:
	add.w	d1,oYVel(a0)			; Zip upwards

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic left on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGndLeft:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.Normal				; If we aren't moving at all, branch
	bpl.s	.Skid				; If we are moving right, branch

.Normal:
	bset	#0,oFlags(a0)			; Face left
	bne.s	.Accelerate			; If we were already facing left, branch
	bclr	#5,oFlags(a0)			; Stop pushing
	move.b	#1,oPrevAnim(a0)		; Reset animation

.Accelerate:
	sub.w	d5,d0				; Apply acceleration
	move.w	d6,d1				; Get top speed
	neg.w	d1
	cmp.w	d1,d0				; Have we already reached it?
	bgt.s	.SetGVel			; If not, branch
	move.w	d1,d0				; Cap our velocity

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	rts

.Skid:
	sub.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel2			; If we are still moving right, branch
	move.w	#-$80,d0			; If we are now moving left, set velocity to -0.5

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

	move.b	oAngle(a0),d0			; Are we on a floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch
	cmpi.w	#$400,d0			; Is our ground velocity at least 4?
	blt.s	.End				; If not, branch

	move.b	#$D,oAnim(a0)			; Set animation to skidding animation
	bclr	#0,oFlags(a0)			; Face right
	move.w	#FM_SKID,d0			; Play skidding sound
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic right on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGndRight:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	bmi.s	.Skid
	bclr	#0,oFlags(a0)			; Face right
	beq.s	.Accelerate			; If we were already facing right, branch
	bclr	#5,oFlags(a0)			; Stop pushing
	move.b	#1,oPrevAnim(a0)		; Reset animation

.Accelerate:
	add.w	d5,d0				; Apply acceleration
	cmp.w	d6,d0				; Have we already reached top speed?
	blt.s	.SetGVel			; If not, branch
	move.w	d6,d0				; Cap our velocity

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	rts

.Skid:
	add.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel2			; If we are still moving left, branch
	move.w	#$80,d0				; If we are now moving right, set velocity to 0.5

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

	move.b	oAngle(a0),d0			; Are we on a floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch
	cmpi.w	#-$400,d0			; Is our ground velocity at least -4?
	bgt.s	.End				; If not, branch

	move.b	#$D,oAnim(a0)			; Set animation to skidding animation
	bset	#0,oFlags(a0)			; Face left
	move.w	#FM_SKID,d0			; Play skidding sound
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement while rolling on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveRoll:
	move.w	sonicTopSpeed.w,d6		; Get top speed (multiplied by 2)
	asl.w	#1,d6
	move.w	sonicAcceleration.w,d5		; Get acceleration (divided by 2)
	asr.w	#1,d5
	move.w	sonicDeceleration.w,d4		; Get deceleration (divided by 4)
	asr.w	#2,d4

	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.w	.CalcXYVels			; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement locked temporarily?
	bne.s	.NotRight			; If so, branch

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.NotLeft			; If not, branch
	bsr.w	ObjSonic_MoveRollLeft		; Move left

.NotLeft:
	btst	#3,playerCtrlHold.w		; Are we holding right
	beq.s	.NotRight			; If not, branch
	bsr.w	ObjSonic_MoveRollRight		; Move right

.NotRight:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.CheckStopRoll			; If we aren't moving at all, branch
	bmi.s	.SettleLeft			; If we are moving left, branch

	sub.w	d5,d0				; Settle right
	bcc.s	.SetGVel			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	bra.s	.CheckStopRoll			; Calculate X and Y velocities

.SettleLeft:
	add.w	d5,d0				; Settle left
	bcc.s	.SetGVel2			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

.CheckStopRoll:
	tst.w	oPlayerGVel(a0)			; Are we still moving?
	bne.s	.CalcXYVels			; If so, branch
	bclr	#2,oFlags(a0)			; Stop rolling
	move.b	#$13,oYRadius(a0)		; Restore hitbox size
	move.b	#9,oXRadius(a0)
	subq.w	#5,oY(a0)

.CalcXYVels:
	move.b	oAngle(a0),d0			; Get sine and cosine of our current angle
	jsr	CalcSine
	muls.w	oPlayerGVel(a0),d0		; Get Y velocity (ground velocity * sin(angle))
	asr.l	#8,d0
	move.w	d0,oYVel(a0)
	muls.w	oPlayerGVel(a0),d1		; Get X velocity (ground velocity * cos(angle))
	asr.l	#8,d1
	cmpi.w	#$1000,d1			; Is the X velocity greater than 16?
	ble.s	.CheckCapLeft			; If not, branch
	move.w	#$1000,d1			; Cap the X velocity at 16

.CheckCapLeft:
	cmpi.w	#-$1000,d1			; Is the X velocity less than -16?
	bge.s	.SetXVel			; If not, branch
	move.w	#-$1000,d1			; Cap the X velocity at -16

.SetXVel:
	move.w	d1,oXVel(a0)			; Set X velocity
	bra.w	ObjSonic_CheckWallCol		; Handle wall collision

; -------------------------------------------------------------------------
; Move Sonic left on the ground while rolling
; -------------------------------------------------------------------------

ObjSonic_MoveRollLeft:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.StartRoll			; If we aren't moving at all, branch
	bpl.s	.DecelRoll			; If we are moving right, branch

.StartRoll:
	bset	#0,oFlags(a0)			; Face left
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	rts

.DecelRoll:
	sub.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel			; If we are still moving right, branch
	move.w	#-$80,d0			; If we are now moving left, set velocity to -0.5

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	rts

; -------------------------------------------------------------------------
; Move Sonic right on the ground while rolling
; -------------------------------------------------------------------------

ObjSonic_MoveRollRight:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	bmi.s	.DecelRoll			; If we are moving left, branch
	bclr	#0,oFlags(a0)			; Face right
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	rts

.DecelRoll:
	add.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel			; If we are still moving left, branch
	move.w	#$80,d0				; If we are now moving left, set velocity to 0.5

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement in the air
; -------------------------------------------------------------------------

ObjSonic_MoveAir:
	move.w	sonicTopSpeed.w,d6		; Get top speed
	move.w	sonicAcceleration.w,d5		; Get acceleration (multiplied by 2)
	asl.w	#1,d5
	btst	#4,oFlags(a0)
	bne.s	.ResetScreen
	move.w	oXVel(a0),d0			; Get current X velocity

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.CheckRight			; If not, branch
	bset	#0,oFlags(a0)			; Face left
	sub.w	d5,d0				; Apply acceleration
	move.w	d6,d1				; Get top speed
	neg.w	d1
	cmp.w	d1,d0				; Have we reached top speed?
	bgt.s	.CheckRight			; If not, branch
	move.w	d1,d0				; Cap at top speed

.CheckRight:
	btst	#3,playerCtrlHold.w		; Are we holding right?
	beq.s	.SetXVel			; If not, branch
	bclr	#0,oFlags(a0)			; Face right
	add.w	d5,d0				; Apply acceleration
	cmp.w	d6,d0				; Have we reached top speed?
	blt.s	.SetXVel			; If not, branch
	move.w	d6,d0				; Cap at top speed

.SetXVel:
	move.w	d0,oXVel(a0)			; Update X velocity

; -------------------------------------------------------------------------

.ResetScreen:
	cmpi.w	#$60,camYCenter.w		; Is the screen centered?
	beq.s	.CheckDrag			; If not, branch
	bcc.s	.DecShift			; If the screen needs to move back down, branch
	addq.w	#4,camYCenter.w			; Move the screen back up

.DecShift:
	subq.w	#2,camYCenter.w			; Move the screen back down

; -------------------------------------------------------------------------

.CheckDrag:
	cmpi.w	#-$400,oYVel(a0)		; Are we moving upwards at a velocity greater than -4?
	bcs.s	.End				; If not, branch

	move.w	oXVel(a0),d0			; Get air drag value (X velocity / $20)
	move.w	d0,d1
	asr.w	#5,d1
	beq.s	.End				; If there is no air drag to apply, branch
	bmi.s	.DecLXVel			; If we are moving left, branch

.DecRXVel:
	sub.w	d1,d0				; Apply air drag
	bcc.s	.SetRAirDrag			; If we haven't stopped horizontally, branch
	move.w	#0,d0				; Stop our horizontal movement

.SetRAirDrag:
	move.w	d0,oXVel(a0)			; Update X velocity
	rts

.DecLXVel:
	sub.w	d1,d0				; Apply air drag
	bcs.s	.SetLAirDrag			; If we haven't stopped horizontally, branch
	move.w	#0,d0				; Stop our horizontal movement

.SetLAirDrag:
	move.w	d0,oXVel(a0)			; Update X velocity

.End:
	rts

; -------------------------------------------------------------------------
; Handle level boundaries for Sonic
; -------------------------------------------------------------------------

ObjSonic_LevelBound:
	move.l	oX(a0),d1			; Get X position for horizontal boundary checking (X position + X velocity)
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	swap	d1

	move.w	leftBound.w,d0			; Have we crossed the left boundary?
	addi.w	#16,d0
	cmp.w	d1,d0
	bhi.s	.Sides				; If so, branch

	move.w	rightBound.w,d0			; Get right boundary
	addi.w	#320-16,d0
	tst.b	bossFight.w			; Are we in a boss fight?
	bne.s	.ScreenLocked			; If so, branch
	addi.w	#56,d0				; If not, extend the boundary beyond the screen

.ScreenLocked:
	cmp.w	d1,d0				; Have we crossed the right boundary?
	bls.s	.Sides				; If so, branch

.CheckBottom:
	move.w	bottomBound.w,d0		; Have we crossed the bottom boundary?
	addi.w	#224,d0
	cmp.w	oY(a0),d0
	blt.s	.Bottom				; If so, branch
	rts

.Bottom:
	bra.w	KillPlayer

.Sides:
	move.w	d0,oX(a0)			; Stop at the boundary
	move.w	#0,oXSub(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oPlayerGVel(a0)
	bra.s	.CheckBottom			; Continue checking for bottom boundary collision

; -------------------------------------------------------------------------
; Check for rolling for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckRoll:
	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get absolute value of our ground velocity
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	cmpi.w	#$80,d0				; Is it at least 0.5?
	bcs.s	.End				; If not, branch
	move.b	playerCtrlHold.w,d0		; Are we holding left or right?
	andi.b	#$C,d0
	bne.s	.End				; If not, branch
	btst	#1,playerCtrlHold.w		; Are we holding down?
	bne.s	ObjSonic_StartRoll		; If so, branch

.End:
	rts

; -------------------------------------------------------------------------
; Make Sonic start rolling
; -------------------------------------------------------------------------

ObjSonic_StartRoll:
	btst	#2,oFlags(a0)			; Are we already rolling?
	beq.s	.DoRoll				; If not, branch
	rts

.DoRoll:
	bset	#2,oFlags(a0)			; Mark as rolling
	move.b	#$E,oYRadius(a0)		; Set rolling hitbox size
	move.b	#7,oXRadius(a0)
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	addq.w	#5,oY(a0)
	move.w	#FM_9B,d0			; Play jump sound
	jsr	PlayFMSound
	tst.w	oPlayerGVel(a0)			; Are we moving left?
	bne.s	.End				; If not, branch
	move.w	#$200,oPlayerGVel(a0)		; If so, cap our ground velocity at 2

.End:
	rts

; -------------------------------------------------------------------------
; Check for jumping for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckJump:
	move.b	playerCtrlTap.w,d0		; Have we pressed A, B, or C?
	andi.b	#$70,d0
	beq.w	.End				; If not, branch

	moveq	#0,d0				; Get the amount of space over our head
	move.b	oAngle(a0),d0
	addi.b	#$80,d0
	bsr.w	Player_CalcRoomOverHead
	cmpi.w	#6,d1				; Is there at least 6 pixels of space?
	blt.w	.End				; If not, branch

	move.w	#$680,d2			; Get jump speed (6.5)
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	move.w	#$380,d2			; Get underwater jump speed (3.5)

.NoWater:
	moveq	#0,d0				; Get our angle on the ground
	move.b	oAngle(a0),d0
	subi.b	#$40,d0
	jsr	CalcSine			; Get the sine and cosine of our angle
	muls.w	d2,d1				; Get X velocity to jump at (jump speed * cos(angle))
	asr.l	#8,d1
	add.w	d1,oXVel(a0)
	muls.w	d2,d0				; Get Y velocity to jump at (jump speed * sin(angle))
	asr.l	#8,d0
	add.w	d0,oYVel(a0)

	bset	#1,oFlags(a0)			; Mark as in air
	bclr	#5,oFlags(a0)			; Stop pushing
	addq.l	#4,sp				; Stop handling ground specific routines after this
	move.b	#1,oPlayerJump(a0)		; Mark as jumping
	clr.b	oPlayerStick(a0)		; Mark as not sticking to terrain

	move.w	#FM_JUMP,d0			; Play jump sound
	jsr	PlayFMSound

	btst	#2,oFlags(a0)			; Were we rolling?
	bne.s	.RollJump			; If so, branch
	move.b	#$E,oYRadius(a0)		; Set jumping hitbox size
	move.b	#7,oXRadius(a0)
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	bset	#2,oFlags(a0)			; Mark as rolling
	addq.w	#5,oY(a0)

.End:
	rts

.RollJump:
	bset	#4,oFlags(a0)			; Mark as roll-jumping
	rts

; -------------------------------------------------------------------------
; Handle Sonic's jump height
; -------------------------------------------------------------------------

ObjSonic_JumpHeight:
	tst.b	oPlayerJump(a0)			; Are we jumping?
	beq.s	.NotJump			; If not, branch

	move.w	#-$400,d1			; Get minimum jump velocity
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.GotCapVel			; If not, branch
	move.w	#-$200,d1			; Get minimum underwater jump velocity

.GotCapVel:
	cmp.w	oYVel(a0),d1			; Are we going up faster than the minimum jump velocity?
	ble.s	.End				; If so, branch
	move.b	playerCtrlHold.w,d0		; Are we holding A, B, or C?
	andi.b	#$70,d0
	bne.s	.End				; If so, branch
	move.w	d1,oYVel(a0)			; Cap our Y velocity at the minimum jump velocity

.End:
	rts

.NotJump:
	cmpi.w	#-$FC0,oYVel(a0)		; Is our Y velocity less than -15.75?
	bge.s	.End2				; If not, branch
	move.w	#-$FC0,oYVel(a0)		; Cap our Y velocity at -15.75

.End2:
	rts

; -------------------------------------------------------------------------
; Handle slope resistance for Sonic
; -------------------------------------------------------------------------

ObjSonic_SlopeResist:
	move.b	oAngle(a0),d0			; Are we on a ceiling?
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bcc.s	.End2				; If so, branch

	move.b	oAngle(a0),d0			; Get slope resistance value (sin(angle) / 8)
	jsr	CalcSine
	muls.w	#$20,d0
	asr.l	#8,d0

	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.s	.End2				; If not, branch
	bmi.s	.MovingLeft			; If we are moving left, branch
	tst.w	d0				; Is the slope resistance value 0?
	beq.s	.End				; If so, branch
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End:
	rts

.MovingLeft:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End2:
	rts

; -------------------------------------------------------------------------
; Handle slope resistance for Sonic while rolling
; -------------------------------------------------------------------------

ObjSonic_SlopeResistRoll:
	move.b	oAngle(a0),d0			; Are we on a ceiling?
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bcc.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Get slope resistance value (sin(angle) / 3.2)
	jsr	CalcSine
	muls.w	#$50,d0
	asr.l	#8,d0

	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	bmi.s	.MovingLeft			; If we are moving left, branch
	tst.w	d0				; Is the slope resistance value positive?
	bpl.s	.ApplyResist			; If so, branch
	asr.l	#2,d0				; If it's negative, divide it by 4

.ApplyResist:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance
	rts

.MovingLeft:
	tst.w	d0				; Is the slope resistance value negatie?
	bmi.s	.ApplyResist2			; If so, branch
	asr.l	#2,d0				; If it's positive, divide it by 4

.ApplyResist2:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End:
	rts

; -------------------------------------------------------------------------
; Check if Sonic should fall off a steep slope or ceiling
; -------------------------------------------------------------------------

ObjSonic_CheckFallOff:
	nop
	tst.b	oPlayerStick(a0)		; Are we stuck to the terrain?
	bne.s	.End				; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement currently temporarily locked?
	bne.s	.RunMoveLock			; If so, branch

	move.b	oAngle(a0),d0			; Are we on a steep enough slope or ceiling?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	.End				; If not, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground speed
	bpl.s	.CheckSpeed
	neg.w	d0

.CheckSpeed:
	cmpi.w	#$280,d0			; Is our ground speed less than 2.5?
	bcc.s	.End				; If not, branch

	clr.w	oPlayerGVel(a0)			; Set ground velocity to 0
	bset	#1,oFlags(a0)			; Mark as in air
	move.w	#30,oPlayerMoveLock(a0)		; Set movement lock timer

.End:
	rts

.RunMoveLock:
	subq.w	#1,oPlayerMoveLock(a0)		; Decrement movement lock timer
	rts

; -------------------------------------------------------------------------
; Reset Sonic's angle in the air
; -------------------------------------------------------------------------

ObjSonic_JumpAngle:
	move.b	oAngle(a0),d0			; Get current angle
	beq.s	.End				; If it's 0, branch
	bpl.s	.DecPosAngle			; If it's positive, branch

	addq.b	#2,d0				; Slowly set angle back to 0
	bcc.s	.DontCap
	moveq	#0,d0

.DontCap:
	bra.s	.SetNewAngle			; Update the angle value

.DecPosAngle:
	subq.b	#2,d0				; Slowly set angle back to 0
	bcc.s	.SetNewAngle
	moveq	#0,d0

.SetNewAngle:
	move.b	d0,oAngle(a0)			; Update angle

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LevelColInAir:
	move.w	oXVel(a0),d1			; Get the angle that we are moving at
	move.w	oYVel(a0),d2
	jsr	CalcAngle

	move.b	d0,debugAngle			; Update debug angle buffers
	subi.b	#$20,d0
	move.b	d0,debugAngleShift
	andi.b	#$C0,d0
	move.b	d0,debugQuadrant

	cmpi.b	#$40,d0				; Are we moving left?
	beq.w	Player_LvlColAir_Left		; If so, branch
	cmpi.b	#$80,d0				; Are we moving up?
	beq.w	Player_LvlColAir_Up		; If so, branch
	cmpi.b	#$C0,d0				; Are we moving right?
	beq.w	Player_LvlColAir_Right		; If so, branch

; -------------------------------------------------------------------------
; Handle level collision while moving downwards in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Down:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotLeftWall:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotRightWall:
	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	move.b	d1,debugFloorDist
	tst.w	d1
	bpl.s	.End				; If not, branch

	move.b	oYVel(a0),d2			; Are we moving too fast downwards?
	addq.b	#8,d2
	neg.b	d2
	cmp.b	d2,d1
	bge.s	.NotFallThrough			; If not, branch
	cmp.b	d2,d0
	blt.s	.End				; If so, branch

.NotFallThrough:
	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation

	move.b	d3,d0				; Did we land on a steep slope?
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	.LandSteepSlope			; If so, branch

	move.b	d3,d0				; Did we land on a more flat surface?
	addi.b	#$10,d0
	andi.b	#$20,d0
	beq.s	.LandFloor			; If so, branch

.LandSlope:
	asr	oYVel(a0)			; Halve the landing speed
	bra.s	.KeepYVel

.LandFloor:
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.LandSteepSlope:
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	cmpi.w	#$FC0,oYVel(a0)			; Is our landing speed greater than 15.75?
	ble.s	.KeepYVel			; If not, branch
	move.w	#$FC0,oYVel(a0)			; Cap it at 15.75

.KeepYVel:
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	tst.b	d3				; Is our angle 0-$7F?
	bpl.s	.End				; If so, branch
	neg.w	oPlayerGVel(a0)			; If not, negate our landing speed

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving left in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Left:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.NotLeftWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.NotCeiling			; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling
	tst.w	oYVel(a0)			; Were we moving upwards?
	bpl.s	.End				; If not, branch
	move.w	#0,oYVel(a0)			; If so, stop moving vertically

.End:
	rts

.NotCeiling:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	tst.w	d1
	bpl.s	.End2				; If not, branch

	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed

.End2:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving upwards in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Up:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotLeftWall:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotRightWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.End				; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling

	move.b	d3,d0				; Did we land on a steep slope?
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	.LandSteepSlope			; If so, branch

.LandCeiling:
	move.w	#0,oYVel(a0)			; Stop moving vertically
	rts

.LandSteepSlope:
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed

	tst.b	d3				; Is our angle 0-$7F?
	bpl.s	.End				; If so, branch
	neg.w	oPlayerGVel(a0)			; If not, negate our landing speed

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving right in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Right:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.NotRightWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.NotCeiling			; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling
	tst.w	oYVel(a0)			; Were we moving upwards?
	bpl.s	.End				; If not, branch
	move.w	#0,oYVel(a0)			; If so, stop moving vertically

.End:
	rts

.NotCeiling:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	tst.w	d1
	bpl.s	.End2				; If not, branch

	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed

.End2:
	rts

; -------------------------------------------------------------------------
; Reset flags for when the player lands on the floor
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_ResetOnFloor:
	btst	#4,oFlags(a0)			; Did we jump after rolling?
	beq.s	.NoRollJump			; If not, branch
	nop

.NoRollJump:
	bclr	#5,oFlags(a0)			; Stop puishing
 	bclr	#1,oFlags(a0)			; Mark as on the ground
	bclr	#4,oFlags(a0)			; Clear roll jump flag

	btst	#2,oFlags(a0)			; Did we land from a jump?
	beq.s	.NotJumping			; If not, branch
	bclr	#2,oFlags(a0)			; Mark as not jumping

	move.b	#$13,oYRadius(a0)		; Restore hitbox size
	move.b	#9,oXRadius(a0)
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	subq.w	#5,oY(a0)

.NotJumping:
	move.b	#0,oPlayerJump(a0)		; Clear jumping flag
	move.w	#0,scoreChain.w			; Clear chain bonus counter
	rts

; -------------------------------------------------------------------------
; Sonic's hurt routine
; -------------------------------------------------------------------------

ObjSonic_Hurt:
	jsr	ObjMove				; Apply velocity
	addi.w	#$30,oYVel(a0)			; Make gravity stronger
	btst	#6,oFlags(a0)			; Is Sonic underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$20,oYVel(a0)			; Make the gravity less strong underwater

.NoWater:
	bsr.w	ObjSonic_HurtChkLand		; Check for landing on the ground
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Animate		; Animate sprite
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Check for Sonic landing on the ground while hurting
; -------------------------------------------------------------------------

ObjSonic_HurtChkLand:
	move.w	bottomBound.w,d0		; Have we gone past the bottom level boundary?
	addi.w	#224,d0
	cmp.w	oY(a0),d0
	bcs.w	KillPlayer			; If so, branch

	bsr.w	Player_LevelColInAir		; Handle level collision
	btst	#1,oFlags(a0)			; Are we still in the air?
	bne.s	.End				; If so, branch

	moveq	#0,d0				; Stop movement
	move.w	d0,oYVel(a0)
	move.w	d0,oXVel(a0)
	move.w	d0,oPlayerGVel(a0)
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	subq.b	#2,oRoutine(a0)			; Go back to the main routine
	move.w	#120,oPlayerHurt(a0)		; Set hurt time

.End:
	rts

; -------------------------------------------------------------------------
; Sonic's death routine
; -------------------------------------------------------------------------

ObjSonic_Dead:
	bsr.w	ObjSonic_DeadChkGone		; Check if we have gone offscreen
	jsr	ObjMoveGrv			; Apply velocity
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Animate		; Animate sprite
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Check for Sonic going offscreen when he's dead
; -------------------------------------------------------------------------

ObjSonic_DeadChkGone:
	move.w	bottomBound.w,d0		; Have we gone past the bottom level boundary?
	addi.w	#256,d0
	cmp.w	oY(a0),d0
	bcc.w	.End				; If not, branch

	move.w	#-$38,oYVel(a0)			; Make us go upwards a little
	addq.b	#2,oRoutine(a0)			; Set routine to gone

	clr.b	updateHUDTime			; Stop the level timer
	addq.b	#1,updateHUDLives		; Decrement life counter
	subq.b	#1,lives
	bpl.s	.CapLives			; If we still have lives left, branch
	clr.b	lives				; Cap lives at 0

.CapLives:
	cmpi.b	#$2B,oAnim(a0)			; Were we giving up from boredom?
	beq.s	.LoadGameOver			; If so, branch

	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.LoadGameOver			; If not, branch

	move.b	#0,lives			; Set lives to 0
	bra.s	.ResetDelay			; Continue setting the delay timer

.LoadGameOver:
	jsr	FindObjSlot			; Load the game over text object
	move.b	#$3B,oID(a1)

	move.w	#8*60,oPlayerReset(a0)		; Set game over delay timer to 8 seconds
	tst.b	lives				; Do we still have lives left?
	beq.s	.End				; If not, branch

.ResetDelay:
	move.w	#60,oPlayerReset(a0)		; Set delay timer to 1 second

.End:
	rts

; -------------------------------------------------------------------------
; Handle Sonic's death delay timer and handle level reseting
; -------------------------------------------------------------------------

ObjSonic_Restart:
	tst.w	oPlayerReset(a0)		; Is the delay timer active?
	beq.w	.End				; If not, branch
	subq.w	#1,oPlayerReset(a0)		; Decrement the delay timer
	bne.w	.End				; If it hasn't run out, branch

	move.w	#1,levelRestart			; Set to restart the level

	jsr	StopZ80				; Allow conditional jumps to jump in FM sound effects
	move.b	#1,Z80RAM+$1C3E
	jsr	StartZ80

	bsr.w	ResetSavedObjFlags		; Reset saved object flags
	clr.l	flowerCount			; Reset flower count

	tst.b	checkpoint			; Have we hit a checkpoint?
	bne.s	.Skip				; If so, branch
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.Skip				; If not, branch
	bclr	#1,plcLoadFlags			; Set to reload the title card upon restarting

.Skip:
	move.w	#SCMD_FADECDA,d0		; Set to fade out music

	tst.b	lives				; Are we out of lives?
	beq.s	.SendCmd			; If so, branch
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.SpawnAtStart			; If not, branch
	tst.b	checkpoint			; Have we hit a checkpoint?
	beq.s	.SendCmd			; If not, branch

	move.b	#1,spawnMode			; Spawn at checkpoint
	bra.s	.SendCmd			; Continue setting the fade out command

.SpawnAtStart:
	clr.b	spawnMode			; Spawn at beginning

.SendCmd:
	bra.w	SubCPUCmd			; Set the fade out command

.End:
	rts

; -------------------------------------------------------------------------
; Handle special chunks for Sonic
; -------------------------------------------------------------------------

ObjSonic_SpecialChunks:
	cmpi.b	#3,zone				; Are we in Star Light?
	beq.s	.HasSpecChunks			; If so, branch
	tst.b	zone				; Are we in Green Hill?
	bne.w	.End				; If not, branch

.HasSpecChunks:
	move.w	oY(a0),d0			; Get current chunk that we are in
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.b	oX(a0),d1
	andi.w	#$7F,d1
	add.w	d1,d0
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1

	cmp.b	specialChunks+2.w,d1		; Are we in a regular roll tunnel?
	beq.w	ObjSonic_StartRoll		; If so, branch
	cmp.b	specialChunks+3.w,d1		; Are we in a regular roll tunnel?
	beq.w	ObjSonic_StartRoll		; If so, branch

	cmp.b	specialChunks.w,d1		; Are we on a loop?
	beq.s	.CheckIfLeft			; If so, branch
	cmp.b	specialChunks+1.w,d1		; Are we on a special loop?
	beq.s	.CheckIfInAir			; If so, branch
	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts
; -------------------------------------------------------------------------

.CheckIfInAir:
	btst	#1,oFlags(a0)			; Are we in the air?
	beq.s	.CheckIfLeft			; If not, branch

	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts
; -------------------------------------------------------------------------

.CheckIfLeft:
	move.w	oX(a0),d2			; Are we left of the loop check section?
	cmpi.b	#$2C,d2
	bcc.s	.CheckIfRight			; If not, branch

	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts
; -------------------------------------------------------------------------

.CheckIfRight:
	cmpi.b	#$E0,d2				; Are we right of the loop check section?
	bcs.s	.CheckAngle			; If not, branch

	bset	#6,oSprFlags(a0)		; Set to higher path layer
	rts
; -------------------------------------------------------------------------

.CheckAngle:
	btst	#6,oSprFlags(a0)		; Are we on the higher path layer?
	bne.s	.HighPath			; If so, branch

	move.b	oAngle(a0),d1			; Get angle
	beq.s	.End				; If we are flat on the floor, branch
	cmpi.b	#$80,d1				; Are right of the path swap position?
	bhi.s	.End				; If so, branch
	bset	#6,oSprFlags(a0)		; Set to higher path layer
	rts
; -------------------------------------------------------------------------

.HighPath:
	move.b	oAngle(a0),d1			; Are left of the path swap position?
	cmpi.b	#$80,d1
	bls.s	.End				; If so, branch
	bclr	#6,oSprFlags(a0)		; Set to lower path layer

.End:
	rts
; End of function ObjSonic_SpecialChunks

; -------------------------------------------------------------------------
; Animate Sonic's sprite
; -------------------------------------------------------------------------

ObjSonic_Animate:
	lea	Ani_Sonic,a1			; Get animation script

	moveq	#0,d0				; Get current animation
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0		; Are we changing animations?
	beq.s	.Do				; If not, branch

	move.b	d0,oPrevAnim(a0)		; Reset animation flags
	move.b	#0,oAnimFrame(a0)
	move.b	#0,oAnimTime(a0)

.Do:
	add.w	d0,d0				; Get pointer to animation data
	adda.w	(a1,d0.w),a1
	move.b	(a1),d0				; Get animation speed/special flag
	bmi.s	.SpecialAnim			; If it's a special flag, branch

	move.b	oFlags(a0),d1			; Apply horizontal flip flag
	andi.b	#%00000001,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)

	subq.b	#1,oAnimTime(a0)		; Decrement frame duration time
	bpl.s	.AniDelay			; If it hasn't run out, branch
	move.b	d0,oAnimTime(a0)		; Reset frame duration time

; -------------------------------------------------------------------------

.RunAnimScript:
	moveq	#0,d1				; Get animation frame
	move.b	oAnimFrame(a0),d1
	move.b	1(a1,d1.w),d0
	beq.s	.AniNext			; If it's a frame ID, branch
	bpl.s	.AniNext
	cmpi.b	#$FD,d0				; Is it a flag?
	bge.s	.AniFF				; If so, branch

.AniNext:
	move.b	d0,oMapFrame(a0)		; Update animation frame
	addq.b	#1,oAnimFrame(a0)

.AniDelay:
	rts

.AniFF:
	addq.b	#1,d0				; Is the flag $FF (loop)?
	bne.s	.AniFE				; If not, branch

	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	move.b	1(a1),d0			; Get animation frame at that point
	bra.s	.AniNext

.AniFE:
	addq.b	#1,d0				; Is the flag $FE (loop back to frame)?
	bne.s	.AniFD

	move.b	2(a1,d1.w),d0			; Get animation script frame to go back to
	sub.b	d0,oAnimFrame(a0)
	sub.b	d0,d1				; Get animation frame at that point
	move.b	1(a1,d1.w),d0
	bra.s	.AniNext

.AniFD:
	addq.b	#1,d0				; Is the flag $FD (new animation)?
	bne.s	.End
	move.b	2(a1,d1.w),oAnim(a0)		; Set new animation ID

.End:
	rts

; -------------------------------------------------------------------------

.SpecialAnim:
	subq.b	#1,oAnimTime(a0)		; Decrement frame duration time
	bpl.s	.AniDelay			; If it hasn't run out, branch

	addq.b	#1,d0				; Is this special animation $FF (walking/running)?
	bne.w	.RollAnim			; If not, branch

	moveq	#0,d1				; Initialize flip flags
	move.b	oAngle(a0),d0			; Get angle
	move.b	oFlags(a0),d2			; Are we flipped horizontally?
	andi.b	#%00000001,d2
	bne.s	.Flipped			; If so, branch
	not.b	d0				; If not, flip the angle

.Flipped:
	addi.b	#$10,d0				; Center the angle
	bpl.s	.NoInvert			; If we aren't on an angle where we should flip the sprite, branch
	moveq	#%00000011,d1			; If we are, set the flip flags accordingly

.NoInvert:
	andi.b	#%11111100,oSprFlags(a0)	; Apply flip flags
	eor.b	d1,d2
	or.b	d2,oSprFlags(a0)

	btst	#5,oFlags(a0)			; Are we pushing on something?
	bne.w	.CheckPush			; If so, branch

	lsr.b	#4,d0				; Get offset of the angled sprites we need for running and peelout
	andi.b	#6,d0				; ((((angle + 16) / 16) & 6) * 2)
						; (angle is NOT'd if we are facing right)
	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed
	neg.w	d2

.CheckSpeed:
	lea	SonAni_Peelout,a1		; Get peelout sprites
	cmpi.w	#$A00,d2			; Are we running at peelout speed?
	bcc.s	.GotRunAnim			; If so, branch
	lea	SonAni_Run,a1			; Get running sprites
	cmpi.w	#$600,d2			; Are we running at running speed?
	bcc.s	.GotRunAnim			; If so, branch
	lea	SonAni_Walk,a1			; Get walking sprites

	move.b	d0,d1				; Get offset of the angled sprites we need for walking
	lsr.b	#1,d1				; ((((angle + 16) / 16) & 6) * 3)
	add.b	d1,d0				; (angle is NOT'd if we are facing right)

.GotRunAnim:
	add.b	d0,d0

	move.b	d0,d3				; Get animation duration
	neg.w	d2				; max(-ground speed + 8, 0)
	addi.w	#$800,d2
	bpl.s	.BelowMax
	moveq	#0,d2

.BelowMax:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	bsr.w	.RunAnimScript			; Run animation script
	add.b	d3,oMapFrame(a0)		; Add angle offset
	rts

; -------------------------------------------------------------------------

.RollAnim:
	addq.b	#1,d0				; Is this special animation $FE (rolling)?
	bne.s	.CheckPush			; If not, branch

	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed2
	neg.w	d2

.CheckSpeed2:
	lea	SonAni_RollFast,a1		; Get fast rolling sprites
	cmpi.w	#$600,d2			; Are we rolling fast?
	bcc.s	.GotRollAnim			; If so, branch
	lea	SonAni_Roll,a1			; If not, use the regular rolling sprites

.GotRollAnim:
	neg.w	d2				; Get animation duration
	addi.w	#$400,d2			; max(-ground speed + 4, 0)
	bpl.s	.BelowMax2
	moveq	#0,d2

.BelowMax2:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	move.b	oFlags(a0),d1			; Apply horizontal flip flag
	andi.b	#%00000001,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------

.CheckPush:
	move.w	oPlayerGVel(a0),d2		; Get ground speed (negated)
	bmi.s	.CheckSpeed3
	neg.w	d2

.CheckSpeed3:
	addi.w	#$800,d2			; Get animation duration
	bpl.s	.BelowMax3			; max(-ground speed + 8, 0) * 4
	moveq	#0,d2

.BelowMax3:
	lsr.w	#6,d2
	move.b	d2,oAnimTime(a0)
	lea	SonAni_Push,a1			; Get normal pushing sprites
	move.b	oFlags(a0),d1			; Apply horizontal flip flag
	andi.b	#%00000001,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)
	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------
; Sonic's animation script
; -------------------------------------------------------------------------

Ani_Sonic:
	include	"Level/_objects/Sonic/Data/Animations.asm"
	even

; -------------------------------------------------------------------------
; Load the tiles for Sonic's current sprite frame
; -------------------------------------------------------------------------

LoadSonicDynPLC:
	moveq	#0,d0
	move.b	oMapFrame(a0),d0		; Get current sprite frame ID
	cmp.b	sonicLastFrame.w,d0		; Has our sprite frame changed?
	beq.s	.End				; If not, branch

	move.b	d0,sonicLastFrame.w		; Update last sprite frame ID

	lea	DPLC_Sonic,a2			; Get DPLC data for our current sprite frame
	add.w	d0,d0
	adda.w	(a2,d0.w),a2

	moveq	#0,d1				; Get number of DPLC entries
	move.b	(a2)+,d1
	subq.b	#1,d1
	bmi.s	.End				; If there are none, branch

	lea	sonicArtBuf.w,a3		; Get sprite frame tile buffer
	move.b	#1,updateSonicArt.w		; Mark buffer as updated

.PieceLoop:
	moveq	#0,d2				; Get number of tiles to load
	move.b	(a2)+,d2
	move.w	d2,d0
	lsr.b	#4,d0
	lsl.w	#8,d2				; Get starting tile to load
	move.b	(a2)+,d2
	andi.w	#$FFF,d2
	lsl.l	#5,d2
	lea	Art_Sonic,a1
	adda.l	d2,a1

.CopyPieceLoop:
	movem.l	(a1)+,d2-d6/a4-a6		; Load tile data for this entry
	movem.l	d2-d6/a4-a6,(a3)
	lea	$20(a3),a3
	dbf	d0,.CopyPieceLoop		; Loop until all tiles in this entry are loaded

	dbf	d1,.PieceLoop			; Loop until all entries are processed

.End:
	rts

; -------------------------------------------------------------------------
; Check if Sonic is on a pinball flipper, and if so, get the angle to launch
; Sonic at when jumping off of it
; -------------------------------------------------------------------------
; RETURNS:
;	d0.b - Angle to launch at
;	d2.w - Speed to launch at
;	eq/ne - Was on flipper/Was not on flipper
; -------------------------------------------------------------------------

ObjSonic_ChkFlipper:
	moveq	#0,d0				; Get object we are standing on
	move.b	oPlayerStandObj(a0),d0
	lsl.w	#6,d0
	addi.l	#objPlayerSlot&$FFFFFF,d0
	movea.l	d0,a1

	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.End				; If not, branch

	move.w	#FM_SPRING,d0			; Play spring sound
	jsr	PlayFMSound
	move.b	#1,oAnim(a1)			; Set flipper animation to move

	move.w	oX(a1),d1			; Get angle in which to launch at
	move.w	oY(a1),d2			; arctan((object Y + 24 - player Y) / (object X - player X))
	addi.w	#24,d2
	sub.w	oX(a0),d1
	sub.w	oY(a0),d2
	jsr	CalcAngle

	moveq	#0,d2				; Get the amount of force used to get the speed to launch us at, depending on
	move.b	oWidth(a1),d2			; the distance we are from the flipper's rotation pivot
	move.w	oX(a0),d3			; (object width + (player X - object X))
	sub.w	oX(a1),d3
	add.w	d2,d3

	btst	#0,oFlags(a1)			; Is the flipper object flipped horizontally?
	bne.s	.XFlip				; If so, branch

	move.w	#64,d1				; Invert the force to account for the horizontal flip
	sub.w	d3,d1				; (64 - (object width + (player X - object X)))
	move.w	d1,d3

.XFlip:
	move.w	#-$A00,d2			; Get the speed to launch us at
	move.w	d2,d1				; (-10 + ((-10 * force) / 64))
	ext.l	d1
	muls.w	d3,d1
	divs.w	#64,d1
	add.w	d1,d2

	moveq	#0,d1				; Mark as having been on the flipper

.End:
	rts

; -------------------------------------------------------------------------
