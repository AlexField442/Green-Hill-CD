; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present
; -------------------------------------------------------------------------

SonicMappingsVer = 1
	include	"_Include/SpritePiece_ASM68K.asm"
	include	"Title Screen/_Definitions.inc"

; --------------------------------------------------------------------------

	include	"Title Screen/Initialization.asm"
	include	"Title Screen/Palmtree Panic/Palette Cycle (Present).asm"
	include	"Title Screen/Palette Fade.asm"
	include	"Title Screen/Palette Load (Fade).asm"
	include	"Title Screen/Palette Load.asm"
	include	"Title Screen/Palmtree Panic/Palette Data (Act 1 Present).asm"
	include	"Title Screen/Functions (Misc).asm"
	include	"Title Screen/Main.asm"
	include	"Title Screen/Functions (General).asm"
	include	"Title Screen/Palmtree Panic/Scroll (Act 1 Present).asm"
	include	"Title Screen/Palmtree Panic/Load Level Data.asm"
	include	"Title Screen/Object Functions.asm"
	include	"Title Screen/Palmtree Panic/Object Index (Act 1 Present).asm"
	include	"Title Screen/Sub CPU.asm"
	include "Title Screen/_Objects/Sonic/Main.asm"
	include	"Title Screen/Object Animate.asm"
	include	"Title Screen/Load Saved Data.asm"
	include	"Title Screen/Palmtree Panic/Data (Act 1 Present).asm"
	;align $40000

; -------------------------------------------------------------------------
