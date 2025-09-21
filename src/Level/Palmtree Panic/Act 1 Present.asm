; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present
; -------------------------------------------------------------------------

SonicMappingsVer = 1
	include	"_Include/SpritePiece_ASM68K.asm"
	include	"Level/_Definitions.inc"

; --------------------------------------------------------------------------

	include	"Level/Initialization.asm"
	include	"Level/Palmtree Panic/Palette Cycle (Present).asm"
	include	"Level/Palette Fade.asm"
	include	"Level/Palette Load (Fade).asm"
	include	"Level/Palette Load.asm"
	include	"Level/Palmtree Panic/Palette Data (Act 1 Present).asm"
	include	"Level/Functions (Misc).asm"
	include	"Level/Collision Floor.asm"
	include	"Level/Main.asm"
	include	"Level/Functions (General).asm"
	include	"Level/Palmtree Panic/Scroll (Act 1 Present).asm"
	include	"Level/Palmtree Panic/Load Level Data.asm"
	include	"Level/_Events.asm"
	include	"Level/Object Functions.asm"
	include	"Level/Palmtree Panic/Object Index (Act 1 Present).asm"
	include	"Level/_Objects/Sonic/Main.asm"
	include	"Level/Sub CPU.asm"
	include	"Level/Object Animate.asm"
	include	"Level/_Objects/Checkpoint/Main.asm"
	include	"Level/_Objects/Explosion/Main.asm"
	include	"Level/_Objects/Powerup/Main.asm"
	include	"Level/Load Saved Data.asm"
	include	"Level/Collision Check.asm"
	include	"Level/Palmtree Panic/Player Object Collision.asm"
	include	"Level/Debug Mode.asm"
	include	"Level/Palmtree Panic/Debug Objects (Act 1 Present).asm"
	include	"Level/Object Spawner.asm"
	include	"Level/Palmtree Panic/Object Layout (Act 1).asm"
	include	"Level/Object Solid.asm"
	include	"Level/_Objects/Spring/Main.asm"
	include	"Level/_Objects/Ring/Main.asm"
	include	"Level/_Objects/Monitor and Time Post/Main.asm"
	include	"Level/_Objects/HUD and Points/Main.asm"
	include	"Level/_Objects/Spikes/Main.asm"
	include	"Level/Palmtree Panic/Objects/Animal/Main.asm"
	include	"Level/_Objects/Level End/Main.asm"
	include	"Level/Object Time Check.asm"
	include	"Level/_Objects/Game Over/Main.asm"
	include	"Level/_Objects/Title Card/Main.asm"
	include	"Level/_Objects/Results/Main.asm"
	include	"Level/Palmtree Panic/Title Card Data.asm"
	include	"Level/Palmtree Panic/Animated Tiles Update.asm"
	include	"Level/Palmtree Panic/Data (Act 1 Present).asm"
	;align $40000

; -------------------------------------------------------------------------
