; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present data
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Level data
; -------------------------------------------------------------------------

LevelDataIndex:
	dc.l	$3000000|Art_LevelTiles
	dc.l	$2000000|LevelBlocks
	dc.l	LevelChunks
	dc.b	0
	dc.b	$81

LevelPaletteID:
	dc.b	5
	dc.b	5

; -------------------------------------------------------------------------
; PLC lists
; -------------------------------------------------------------------------

PLCLists:
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Std-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Cam2_Full-PLCLists
	dc.w	PLC_Cam3_Full-PLCLists
	dc.w	PLC_Cam4_Full-PLCLists
	dc.w	PLC_Cam5_Full-PLCLists
	dc.w	PLC_Cam1_Incr-PLCLists
	dc.w	PLC_Cam2_Incr-PLCLists
	dc.w	PLC_Cam3_Incr-PLCLists
	dc.w	PLC_Cam4_Incr-PLCLists
	dc.w	PLC_Cam5_Incr-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Results-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Signpost-PLCLists

PLC_Level:
	dc.w	1
	dc.l	Art_LevelTiles
	dc.w	0
	dc.l	Art_Checkpoint
	dc.w	$D960

PLC_Std:
	dc.w	7
	dc.l	Art_Spikes
	dc.w	$6400
	dc.l	Art_DiagonalSpring
	dc.w	$9200
	dc.l	Art_Springs
	dc.w	$A400
	dc.l	Art_HUD
	dc.w	$AD00
	dc.l	Art_MonitorTimePosts
	dc.w	$B500
	dc.l	Art_Explosions
	dc.w	$D000
	dc.l	Art_Points
	dc.w	$D8C0
	dc.l	Art_Rings
	dc.w	$F5C0

PLC_Cam1_Full:
	dc.w	-1

PLC_Cam2_Full:
	dc.w	-1

PLC_Cam3_Full:
	dc.w	-1
PLC_Cam4_Full:
	dc.w	-1

PLC_Cam5_Full:
	dc.w	-1

PLC_Cam1_Incr:
	dc.w	-1

PLC_Cam2_Incr:
	dc.w	-1

PLC_Cam3_Incr:
	dc.w	-1

PLC_Cam4_Incr:
	dc.w	-1

PLC_Cam5_Incr:
	dc.w	-1

PLC_Results:
	dc.w	0
	dc.l	Art_Results
	dc.w	$7880

PLC_Signpost:
	dc.w	2
	dc.l	Art_Signpost
	dc.w	$8780
	dc.l	Art_BigRing
	dc.w	$9100
	dc.l	Art_BigRingFlash
	dc.w	$7DE0

	align $10000

; -------------------------------------------------------------------------

LevelChunks:
	incbin	"Level/Palmtree Panic/Data/Chunks (Act 1 Present).bin"
	even
MapSpr_Sonic:
	include	"Level/_Objects/Sonic/Data/Mappings.asm"
	even
Art_Sonic:
	incbin	"Level/_Objects/Sonic/Data/Art.bin"
	even
DPLC_Sonic:
	include	"Level/_Objects/Sonic/Data/DPLCs.asm"
	even
Art_Points:
	incbin	"Level/_Objects/HUD and Points/Data/Art (Points).nem"
	even
Art_BigRing:
	incbin	"Level/_Objects/Level End/Data/Art (Big Ring).nem"
	even
Art_Signpost:
	incbin	"Level/_Objects/Level End/Data/Art (Signpost).nem"
	even
Art_Results:
	incbin	"Level/_Objects/Results/Data/Art.nem"
	even
Art_TimeOver:
	incbin	"Level/_Objects/Game Over/Data/Art (Time Over).nem"
	even
Art_GameOver:
	incbin	"Level/_Objects/Game Over/Data/Art (Game Over).nem"
	even
Art_TitleCard:
	incbin	"Level/_Objects/Title Card/Data/Art.nem"
	even
Art_Shield:
	incbin	"Level/_Objects/Powerup/Data/Art (Shield).bin"
	even
Art_InvStars:
	incbin	"Level/_Objects/Powerup/Data/Art (Invincibility Stars).bin"
	even
Art_TimeStars:
	incbin	"Level/_Objects/Powerup/Data/Art (Time Warp Stars).bin"
	even
Art_DiagonalSpring:
	incbin	"Level/_Objects/Spring/Data/Art (Diagonal).nem"
	even
Art_Springs:
	incbin	"Level/_Objects/Spring/Data/Art (Normal).nem"
	even
Art_MonitorTimePosts:
	incbin	"Level/_Objects/Monitor and Time Post/Data/Art.nem"
	even
Art_Explosions:
	incbin	"Level/_Objects/Explosion/Data/Art.nem"
	even
Art_Rings:
	incbin	"Level/_Objects/Ring/Data/Art.nem"
	even
Art_LifeIcon:
	incbin	"Level/_Objects/HUD and Points/Data/Art (Life Icon).bin"
	even
Art_HUDNumbers:
	incbin	"Level/_Objects/HUD and Points/Data/Art (Numbers).bin"
	even
Art_HUD:
	incbin	"Level/_Objects/HUD and Points/Data/Art (HUD).nem"
	even
Art_Checkpoint:
	incbin	"Level/_Objects/Checkpoint/Data/Art.Nem"
	even
Art_TitleCardText:
	incbin	"Level/Palmtree Panic/Objects/Title Card/Art.nem"
	even
Art_Spikes:
	incbin	"Level/_Objects/Spikes/Data/Art.nem"
	even
Art_Animals:
	incbin	"Level/Palmtree Panic/Objects/Animal/Data/Art.nem"
	even

; -------------------------------------------------------------------------
; Collision data
; -------------------------------------------------------------------------

ColAngleMap:
	incbin	"Level/_Data/Collision Angles.bin"
	even
ColHeightMap:
	incbin	"Level/_Data/Collision Height Map.bin"
	even
ColWidthMap:
	incbin	"Level/_Data/Collision Width Map.bin"
	even
LevelCollision:
	incbin	"Level/Palmtree Panic/Data/Collision (Act 1 Present).bin"
	even

; -------------------------------------------------------------------------
; Level layout
; -------------------------------------------------------------------------

LevelLayouts:
	dc.w .FG-LevelLayouts,   .BG-LevelLayouts,   .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .FG-LevelLayouts,   .BG-LevelLayouts,   .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .FG-LevelLayouts,   .BG-LevelLayouts,   .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts
	dc.w .Null-LevelLayouts, .Null-LevelLayouts, .Null-LevelLayouts

.FG:
	incbin	"Level/Palmtree Panic/Data/Foreground (Act 2 Present).bin"
	even
.BG:
	incbin	"Level/Palmtree Panic/Data/Background (Act 1 Present).bin"
	even
.Null:

; -------------------------------------------------------------------------

LevelBlocks:
	incbin	"Level/Palmtree Panic/Data/Blocks (Act 1 Present).eni"
	even
Art_LevelTiles:
	incbin	"Level/Palmtree Panic/Data/Tiles (Act 1 Present).nem"
	even
Ani_Powerup:
	include	"Level/_Objects/Powerup/Data/Animations.asm"
	even
MapSpr_Powerup:
	include	"Level/_Objects/Powerup/Data/Mappings.asm"
	even
Ani_Explosion:
	include	"Level/_Objects/Explosion/Data/Animations.asm"
	even
MapSpr_Explosion:
	include	"Level/_Objects/Explosion/Data/Mappings.asm"
	even
Ani_Checkpoint:
	include	"Level/_Objects/Checkpoint/Data/Animations.asm"
	even
MapSpr_Checkpoint:
	include	"Level/_Objects/Checkpoint/Data/Mappings.asm"
	even
Ani_BigRing:
	include	"Level/_Objects/Level End/Data/Animations (Big Ring).asm"
	even
MapSpr_BigRing:
	include	"Level/_Objects/Level End/Data/Mappings (Big Ring).asm"
	even
Ani_Signpost:
	include	"Level/_Objects/Level End/Data/Animations (Signpost).asm"
	even
MapSpr_GoalSignpost:
	include	"Level/_Objects/Level End/Data/Mappings (Post).asm"
	even

; -------------------------------------------------------------------------
; Animated artwork

Art_GhzWater:
	incbin	"Level/Palmtree Panic/Data/Waterfall.bin"
	even

Art_GhzFlower1:
	incbin	"Level/Palmtree Panic/Data/Flower 1.bin"
	even

Art_GhzFlower2:
	incbin	"Level/Palmtree Panic/Data/Flower 2.bin"
	even