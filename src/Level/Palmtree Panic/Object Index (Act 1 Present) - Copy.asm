; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present object index
; -------------------------------------------------------------------------

ObjectIndex:
	dc.l	ObjSonic			; 01 - Sonic
	dc.l	ObjNull				; 02 - Blank
	dc.l	ObjPowerup			; 03 - Power up
	dc.l	ObjNull				; 04 - Blank
	dc.l	ObjNull				; 05 - Blank
	dc.l	ObjNull				; 06 - Blank
	dc.l	ObjNull				; 07 - Blank
	dc.l	ObjNull				; 08 - Blank
	dc.l	ObjNull				; 09 - Blank
	dc.l	ObjSpring			; 0A - Spring
	dc.l	ObjNull				; 0B - Blank
	dc.l	ObjNull				; 0C - Blank
	dc.l	ObjNull				; 0D - Blank
	dc.l	ObjNull				; 0E - Blank
	dc.l	ObjNull				; 0F - Blank
	dc.l	ObjRing				; 10 - Ring
	dc.l	ObjLostRing			; 11 - Lost ring
	dc.l	ObjNull				; 12 - Floating block
	dc.l	ObjCheckpoint			; 13 - Checkpoint
	dc.l	ObjBigRing			; 14 - Big ring
	dc.l	ObjNull				; 15 - Blank
	dc.l	ObjNull				; 16 - Blank
	dc.l	ObjSignpost			; 17 - Signpost
	dc.l	ObjExplosion			; 18 - Explosion
	dc.l	ObjMonitorTimePost		; 19 - Monitor/Time post
	dc.l	ObjMonitorItem			; 1A - Monitor item
	dc.l	ObjNull				; 1B - Blank
	dc.l	ObjHUDPoints			; 1C - HUD/Points
	dc.l	ObjNull				; 1D - Blank
	dc.l	ObjNull				; 1E - Blank
	dc.l	ObjNull				; 1F - Blank
	dc.l	ObjNull				; 20 - Blank
	dc.l	ObjNull				; 21 - Blank
	dc.l	ObjNull				; 22 - Blank
	dc.l	ObjNull				; 23 - Blank
	dc.l	ObjAnimal			; 24 - Animal
	dc.l	ObjNull				; 25 - Blank
	dc.l	ObjSpikes			; 26 - Spikes
	dc.l	ObjNull				; 27 - Blank
	dc.l	ObjNull				; 28 - Blank
	dc.l	ObjNull				; 29 - Blank
	dc.l	ObjNull				; 2A - Blank
	dc.l	ObjNull				; 2B - Blank
	dc.l	ObjNull				; 2C - Blank
	dc.l	ObjNull				; 2D - Blank
	dc.l	ObjNull				; 2E - Blank
	dc.l	ObjNull				; 2F - Blank
	dc.l	ObjNull				; 30 - Blank
	dc.l	ObjNull				; 31 - Blank
	dc.l	ObjNull				; 32 - Blank
	dc.l	ObjNull				; 33 - Blank
	dc.l	ObjNull				; 34 - Blank
	dc.l	ObjNull				; 35 - Blank
	dc.l	ObjNull				; 36 - Blank
	dc.l	ObjNull				; 37 - Blank
	dc.l	ObjNull				; 38 - Blank
	dc.l	ObjNull				; 39 - Blank
	dc.l	ObjResults			; 3A - End of level results
	dc.l	ObjGameOver			; 3B - Game over text
	dc.l	ObjTitleCard			; 3C - Title card
	dc.l	ObjNull				; 3D - Blank
	dc.l	ObjNull				; 3E - Blank
	dc.l	ObjNull				; 3F - Blank
	dc.l	ObjNull				; 40 - Blank

; -------------------------------------------------------------------------
; Null object
; -------------------------------------------------------------------------

ObjNull:
	bra.w	DeleteObject

; -------------------------------------------------------------------------
