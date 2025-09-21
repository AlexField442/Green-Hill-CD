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
	dc.b	1
	dc.b	1

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
	dc.w	0
	dc.l	Art_LevelTiles
	dc.w	0

PLC_Std:
	dc.w	0
	dc.l	Art_LevelTiles
	dc.w	0

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
	dc.w	-1

PLC_Signpost:
	dc.w	-1

	align $10000

; -------------------------------------------------------------------------

LevelChunks:
	incbin	"Title Screen/Palmtree Panic/Data/Chunks (Act 1 Present).bin"
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
	incbin	"Title Screen/Palmtree Panic/Data/Foreground (Act 1 Present).bin"
	even
.BG:
	incbin	"Title Screen/Palmtree Panic/Data/Background (Act 1 Present).bin"
	even
.Null:

; -------------------------------------------------------------------------

LevelBlocks:
	incbin	"Title Screen/Palmtree Panic/Data/Blocks (Act 1 Present).eni"
	even
Art_LevelTiles:
	incbin	"Title Screen/Palmtree Panic/Data/Tiles (Act 1 Present).nem"
	even
Art_TitleSonic:
	incbin	"Title Screen/_Objects/Sonic/Data/Art.nem"
	even