; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Object spawner
; -------------------------------------------------------------------------

ResetSavedObjFlags:
	rts

; -------------------------------------------------------------------------
; Spawn objects
; -------------------------------------------------------------------------

SpawnObjects:
	moveq	#0,d0				; Run routine
	move.b	objSpawnRoutine.w,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	SpawnObjects_Init-.Index
	dc.w	SpawnObjects_Main-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

SpawnObjects_Init:
	addq.b	#2,objSpawnRoutine.w		; Next routine

	lea	ObjectLayouts,a0		; Get object layout
	movea.l	a0,a1
	adda.w	(a0),a0
	move.l	a0,objChunkRight.w
	move.l	a0,objChunkLeft.w
	adda.w	2(a1),a1			; Get null object layout
	move.l	a1,objChunkNullR.w
	move.l	a1,objChunkNullL.w

	lea	savedObjFlags,a2		; Reset current saved object flag entry IDs
	move.w	#$101,(a2)
	move.w	#OBJFLAGSCNT/4-1,d0		; Clear flags

.Clear:
	clr.l	(a2)+
	dbf	d0,.Clear

	lea	savedObjFlags,a2
	moveq	#0,d2				; Get initial right chunk position
	move.w	cameraX.w,d6			; (max(0, camera X - $80) & $FF80)
	subi.w	#$80,d6
	bcc.s	.GotLeftBound			; If it's not offscreen, branch
	moveq	#0,d6				; If it is, cap at leftmost side of the level

.GotLeftBound:
	andi.w	#$FF80,d6
	movea.l	objChunkRight.w,a0		; Find right chunk

.FindRightChunk:
	cmp.w	(a0),d6				; Is this object located past the chunk position?
	bls.s	.FoundRightChunk		; If so, branch
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.NextObjRight			; If not, branch
	move.b	(a2),d2				; Get saved flags entry ID
	addq.b	#1,(a2)				; Set next saved flags entry ID for right chunk

.NextObjRight:
	addq.w	#oeSize,a0			; Next object
	bra.s	.FindRightChunk			; Loop until the right chunk is found

.FoundRightChunk:
	move.l	a0,objChunkRight.w		; Set right chunk address

	movea.l	objChunkLeft.w,a0		; Find left chunk
	subi.w	#$80,d6				; Initial left chunk position = (camera X - $100)
	bcs.s	.FoundLeftChunk			; If it's offscreen, branch

.FindLeftChunk:
	cmp.w	(a0),d6				; Is this object located past the chunk position?
	bls.s	.FoundLeftChunk			; If so, branch
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.NextObjLeft			; If not, branch
	addq.b	#1,1(a2)			; Set next saved flags entry ID for left chunk

.NextObjLeft:
	addq.w	#oeSize,a0			; Next object
	bra.s	.FindLeftChunk			; Loop until the left chunk is found

.FoundLeftChunk:
	move.l	a0,objChunkLeft.w		; Set left chunk address

	move.w	#-1,objPrevChunk.w		; Force object spawns

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

SpawnObjects_Main:
	lea	savedObjFlags,a2		; Get saved object flags

	moveq	#0,d2				; Get current chunk position
	move.w	cameraX.w,d6
	andi.w	#$FF80,d6
	cmp.w	objPrevChunk.w,d6		; Has it changed?
	beq.w	SpawnObjects_End		; If not, branch
	bge.s	SpawnObjects_Forward		; If the camera has moved forwards, branch
	move.w	d6,objPrevChunk.w		; Update chunk position

; -------------------------------------------------------------------------

SpawnObjects_Backward:
	movea.l	objChunkLeft.w,a0		; Get new left chunk position
	subi.w	#$80,d6				; ((camera X & $FF80) - $80)
	blo.s	.SpawnDone			; If it's offscreen, branch

.SpawnLoop:
	cmp.w	oeX-oeSize(a0),d6		; Is this object past the chunk position?
	bge.s	.SpawnDone			; If so, branch
	subq.w	#oeSize,a0
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.SpawnObj			; If not, branch
	subq.b	#1,1(a2)			; Set next saved flags entry ID
	move.b	1(a2),d2			; Get saved flags entry ID

.SpawnObj:
	bsr.w	SpawnObject			; Spawn object
	bne.s	.SpawnFailed			; If it failed to spawn, branch
	subq.w	#oeSize,a0			; Otherwise, check next object
	bra.s	.SpawnLoop

.SpawnFailed:
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.Rewind				; If not, branch
	addq.b	#1,1(a2)			; Rewind saved flags entry ID
	;bclr	#7,2(a2,d3.w)			; Mark object as unloaded

.Rewind:
	addq.w	#oeSize,a0			; Rewind object entry

.SpawnDone:
	move.l	a0,objChunkLeft.w		; Set left chunk address

	movea.l	objChunkRight.w,a0		; Get new right chunk position
	addi.w	#$280+$80,d6			; ((camera X & $FF80) + $280)

.FindRightChunk:
	cmp.w	oeX-oeSize(a0),d6		; Is this object located past the chunk position?
	bgt.s	.FoundRightChunk		; If so, branch
	tst.b	oeID-oeSize(a0)			; Does this object have a saved flags entry?
	bpl.s	.NextObjRight			; If not, branch
	subq.b	#1,(a2)				; Set next saved flags entry ID

.NextObjRight:
	subq.w	#oeSize,a0			; Next object
	bra.s	.FindRightChunk			; Loop until the right chunk is found

.FoundRightChunk:
	move.l	a0,objChunkRight.w		; Set right chunk address
	rts

; -------------------------------------------------------------------------

SpawnObjects_Forward:
	move.w	d6,objPrevChunk.w		; Update chunk position

	movea.l	objChunkRight.w,a0		; Get new right chunk position
	addi.w	#$280,d6			; ((camera X & $FF80) + $280)

.SpawnLoop:
	cmp.w	(a0),d6				; Is this object past the chunk position?
	bls.s	.SpawnDone			; If so, branch
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.SpawnObj			; If not, branch
	move.b	(a2),d2				; Get saved flags entry ID
	addq.b	#1,(a2)				; Set next saved flags entry ID

.SpawnObj:
	bsr.w	SpawnObject			; Spawn object
	beq.s	.SpawnLoop			; If it successfully spawned, branch
;	tst.b	oeID(a0)			; was this object a remember state?
;	bpl.s	.SpawnLoop			; if not, branch
;	subq.b	#1,(a2)				; move right counter back

.SpawnDone
	move.l	a0,objChunkRight.w		; Set right chunk address

	movea.l	objChunkLeft.w,a0		; Get left chunk position
	subi.w	#$80+$280,d6			; ((camera X & $FF80) - $80)
	bcs.s	.FoundLeftChunk			; If it's offscreen, branch

.FindLeftChunk:
	cmp.w	(a0),d6				; Is this object located past the chunk position?
	bls.s	.FoundLeftChunk			; If so, branch
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.NextObjLeft			; If not, branch
	addq.b	#1,1(a2)			; Set next saved flags entry ID

.NextObjLeft:
	addq.w	#oeSize,a0			; Next object
	bra.s	.FindLeftChunk			; Loop until the left chunk is found

.FoundLeftChunk:
	move.l	a0,objChunkLeft.w		; Set left chunk address

; -------------------------------------------------------------------------

SpawnObjects_End:
	rts

; -------------------------------------------------------------------------
; Spawn an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l  - Pointer to object entry
;	d2.w  - Saved object flags entry ID
; RETURNS:
;	eq/ne - Success/Failure
;	d3.w  - Saved object flags entry offset
; -------------------------------------------------------------------------

SpawnObject:
	tst.b	oeID(a0)			; Does this object have a saved flags entry?
	bpl.s	.Spawn				; If not, branch
	btst	#7,2(a2,d2.w)			; Mark as spawned
	beq.s	.Spawn				; If it wasn't spawned already, branch

.NoSpawn:
	addq.w	#oeSize,a0			; Skip over object
	moveq	#0,d0				; Mark as successful
	rts

.Spawn:
	bsr.w	FindObjSlot			; Spawn object
	bne.s	.End
	
	move.w	(a0)+,oX(a1)			; Set X position
	
	move.w	(a0)+,d0			; Get Y position and flags
	move.w	d0,d1				; Copy flags
	andi.w	#$FFF,d0			; Set Y position
	move.w	d0,oY(a1)
	
	rol.w	#2,d1				; Set flags
	andi.b	#3,d1
	move.b	d1,oSprFlags(a1)
	move.b	d1,oFlags(a1)

	move.b	(a0)+,d0			; Get object ID
	bpl.s	.NoSavedFlags			; If tihs object doesn't have a saved flags entry, branch
	andi.b	#$7F,d0				; Clear flag from ID
	move.b	d2,oSavedFlagsID(a1)		; Set saved flags entry ID

.NoSavedFlags:
	move.b	d0,oID(a1)			; Set object ID
	move.b	(a0)+,oSubtype(a1)		; Set subtype
	moveq	#0,d0				; Mark as successful

.End:
	rts

; -------------------------------------------------------------------------
; Find object slot
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Success/Failure
;	a1.l  - Pointer to found object slot
; -------------------------------------------------------------------------

FindObjSlot:
	lea	dynObjects.w,a1			; Object pool
	move.w	#DYNOBJCOUNT-1,d0		; Number of slots to check

.Find:
	tst.b	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, branch
	lea	oSize(a1),a1			; Next object
	dbf	d0,.Find			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Find object slot after current one
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l  - Current object slot
; RETURNS:
;	eq/ne - Success/Failure
;	a1.l  - Pointer to found object slot
; -------------------------------------------------------------------------

FindNextObjSlot:
	movea.l	a0,a1				; Start with slot after the current one

	move.w	#objectsEnd,d0			; Get number of slots to check
	sub.w	a0,d0
	if oSize=$40
		lsr.w	#6,d0
	else
		divu.w	#oSize,d0
	endif
	subq.w	#1,d0				; Decrement for DBF
	bcs.s	.End				; If there are no objects to check, branch

.Find:
	tst.b	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, branch
	lea	oSize(a1),a1			; Next object
	dbf	d0,.Find			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Check if an object should despawn offscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w  - X position (for CheckObjDespawn2)
;	a0.l  - Object slot
; RETURNS:
;	eq/ne - Not despawned/Despawned
; -------------------------------------------------------------------------

CheckObjDespawn:
	move.w	oX(a0),d0			; Get the object's chunk position

CheckObjDespawn2:
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1

	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	.NoDraw				; If so, branch
	bra.w	DrawObject			; If not, draw the object's sprite

.NoDraw:
	lea	savedObjFlags,a2		; Saved object flags table
	moveq	#0,d0				; Get table entry ID
	move.b	oSavedFlagsID(a0),d0
	beq.s	.NoClear			; If the object doesn't have one, branch
	bclr	#7,2(a2,d0.w)			; Mark as unloaded

.NoClear:
	bra.w	DeleteObject			; Delete the object

; -------------------------------------------------------------------------
