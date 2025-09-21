; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main program
; -------------------------------------------------------------------------

	include	"_Include/Common.inc"
	include	"_Include/Main CPU.inc"
	include	"_Include/Main CPU Variables.inc"
	include	"_Include/System.inc"
	include	"_Include/Backup RAM.inc"
	include	"_Include/Sound.inc"
	include	"_Include/MMD.inc"
	include	"Special Stage/_Global Variables.inc"

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAM, $1000, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM Access
	
	lea	MAINVARS,a0			; Clear variables
	move.w	#MAINVARSSZ/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	moveq	#SCMD_MDINIT,d0			; Run Mega Drive initialization
	bsr.w	RunMMD
	move.w	#SCMD_BURAMINIT,d0		; Run Backup RAM initialization
	bsr.w	RunMMD
	tst.b	d0				; Was it a succes?
	beq.s	.GetSaveData			; If so, branch
	bset	#0,saveDisabled			; If not, disable saving to Backup RAM

.GetSaveData:
	bsr.w	ReadSaveData			; Read save data

.GameLoop:
	move.w	#SCMD_INITSS2,d0		; Initialize special stage flags
	bsr.w	SubCPUCmd

;	moveq	#0,d0
;	move.l	d0,score			; Reset score
;	move.b	d0,timeAttackMode		; Reset time attack mode flag
;	move.b	d0,specialStage			; Reset special stage flag
;	move.b	d0,checkpoint			; Reset checkpoint
;	move.w	d0,rings			; Reset ring count
;	move.l	d0,time				; Reset time
;	move.b	d0,goodFuture			; Reset good future flag
;	move.b	d0,projDestroyed		; Reset projector destroyed flag
;	move.b	#TIME_PRESENT,timeZone		; Set time zone to present

	moveq	#SCMD_TITLE,d0			; Run title screen
	bsr.w	RunMMD

	ext.w	d1				; Run next scene
	add.w	d1,d1
	move.w	.Scenes(pc,d1.w),d1
	jsr	.Scenes(pc,d1.w)

	bra.s	.GameLoop			; Loop

; -------------------------------------------------------------------------

.Scenes:
	dc.w	Demo-.Scenes			; Demo mode
	dc.w	NewGame-.Scenes			; New game
	dc.w	LoadGame-.Scenes		; Load game
	dc.w	TimeAttack-.Scenes		; Time attack
	dc.w	BuRAMManager-.Scenes		; Backup RAM manager
	dc.w	DAGarden-.Scenes		; D.A. Garden
	dc.w	VisualMode-.Scenes		; Visual mode
	dc.w	SoundTest-.Scenes		; Sound test

; -------------------------------------------------------------------------
; Backup RAM manager
; -------------------------------------------------------------------------

BuRAMManager:
	move.w	#SCMD_BURAMMGR,d0		; Run Backup RAM manager
	bsr.w	RunMMD
	bsr.w	ReadSaveData			; Read save data
	rts

; -------------------------------------------------------------------------
; Run Special Stage 1 demo
; -------------------------------------------------------------------------

SpecStage1Demo:
	move.b	#1-1,specStageIDCmd		; Stage 1
	move.b	#0,timeStonesCmd		; Reset time stones retrieved for this stage
	bset	#0,specStageFlags		; Temporary mode
	
	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD
	rts

; -------------------------------------------------------------------------
; Run Special Stage 6 demo
; -------------------------------------------------------------------------

SpecStage6Demo:
	move.b	#6-1,specStageIDCmd		; Stage 6
	move.b	#0,timeStonesCmd		; Reset time stones retrieved for this stage
	bset	#0,specStageFlags		; Temporary mode
	
	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD
	rts

; -------------------------------------------------------------------------
; Load game
; -------------------------------------------------------------------------

LoadGame:
	bsr.w	ReadSaveData			; Read save data
	move.w	savedLevel,zoneAct		; Get level from save data
	move.b	#3,lives			; Reset life count to 3
	move.b	#0,plcLoadFlags			; Reset PLC load flags

	cmpi.b	#0,zone				; Are we in Green Hill?
	beq.w	RunR1				; If so, branch
	cmpi.b	#1,zone				; Are we in Labyrinth?
	bls.w	RunR3				; If so, branch

; -------------------------------------------------------------------------
; New game
; -------------------------------------------------------------------------

NewGame:
RunR1:
	moveq	#0,d0
	move.b	d0,plcLoadFlags			; Reset PLC load flags
	move.w	d0,zone				; Set level to Palmtree Panic Act 1
	move.w	d0,savedLevel
	move.b	d0,curSpecStage			; Reset special stage ID

	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR11				; Run act 1
	bsr.w	RunR12				; Run act 2
	bsr.w	RunR13				; Run act 3

	moveq	#3*1,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	bset	#6,titleFlags
	bset	#5,titleFlags
	move.b	#0,checkpoint			; Reset checkpoint

; -------------------------------------------------------------------------

RunR3:
	bsr.w	WriteSaveData			; Write save data

	bsr.w	RunR31				; Run act 1
	bsr.w	RunR32				; Run act 2
	bsr.w	RunR33				; Run act 3

	moveq	#3*2,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,checkpoint			; Reset checkpoint

; -------------------------------------------------------------------------

GameDone:
	move.b	goodFutures,gameGoodFutures	; Save good futures achieved
	move.b	timeStones,gameTimeStones	; Save time stones retrieved

	bra.w	WriteSaveData			; Write save data

; -------------------------------------------------------------------------
; Game over
; -------------------------------------------------------------------------

GameOver:
	move.b	#0,act				; Reset act
	move.w	zoneAct,savedLevel		; Save zone and act ID
	move.b	#0,checkpoint			; Reset checkpoint
	rts

; -------------------------------------------------------------------------
; Final game results data
; -------------------------------------------------------------------------

gameGoodFutures:	
	dc.b	0				; Good futures achieved
gameTimeStones:
	dc.b	0				; Time stones retrieved

; -------------------------------------------------------------------------
; Run Palmtree Panic Act 1
; -------------------------------------------------------------------------

RunR11:
	lea	R11SubCmds(pc),a0
	move.w	#$000,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Palmtree Panic Act 2
; -------------------------------------------------------------------------

RunR12:
	lea	R12SubCmds(pc),a0
	move.w	#$001,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Palmtree Panic Act 3
; -------------------------------------------------------------------------

RunR13:
	lea	R13SubCmds(pc),a0
	move.w	#$002,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Collision Chaos Act 1
; -------------------------------------------------------------------------

RunR31:
	lea	R31SubCmds(pc),a0
	move.w	#$100,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Collision Chaos Act 2
; -------------------------------------------------------------------------

RunR32:
	lea	R32SubCmds(pc),a0
	move.w	#$101,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Collision Chaos Act 3
; -------------------------------------------------------------------------

RunR33:
	lea	R33SubCmds(pc),a0
	move.w	#$102,zoneAct
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Tidal Tempest Act 1
; -------------------------------------------------------------------------

RunR41:
	lea	R41SubCmds(pc),a0
	move.w	#$200,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Tidal Tempest Act 2
; -------------------------------------------------------------------------

RunR42:
	lea	R42SubCmds(pc),a0
	move.w	#$201,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Tidal Tempest Act 3
; -------------------------------------------------------------------------

RunR43:
	lea	R43SubCmds(pc),a0
	move.w	#$202,zoneAct
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Quartz Quadrant Act 1
; -------------------------------------------------------------------------

RunR51:
	lea	R51SubCmds(pc),a0
	move.w	#$300,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Quartz Quadrant Act 2
; -------------------------------------------------------------------------

RunR52:
	lea	R52SubCmds(pc),a0
	move.w	#$301,zoneAct
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Quartz Quadrant Act 3
; -------------------------------------------------------------------------

RunR53:
	lea	R53SubCmds(pc),a0
	move.w	#$302,zoneAct
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Wacky Workbench Act 1
; -------------------------------------------------------------------------

RunR61:
	lea	R61SubCmds(pc),a0
	move.w	#$400,zoneAct
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Wacky Workbench Act 2
; -------------------------------------------------------------------------

RunR62:
	lea	R62SubCmds(pc),a0
	move.w	#$401,zoneAct
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Wacky Workbench Act 3
; -------------------------------------------------------------------------

RunR63:
	lea	R63SubCmds(pc),a0
	move.w	#$402,zoneAct
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Stardust Speedway Act 1
; -------------------------------------------------------------------------

RunR71:
	lea	R71SubCmds(pc),a0
	move.w	#$500,zoneAct
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Stardust Speedway Act 2
; -------------------------------------------------------------------------

RunR72:
	lea	R72SubCmds(pc),a0
	move.w	#$501,zoneAct
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Stardust Speedway Act 3
; -------------------------------------------------------------------------

RunR73:
	lea	R73SubCmds(pc),a0
	move.w	#$502,zoneAct
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Metallic Madness Act 1
; -------------------------------------------------------------------------

RunR81:
	lea	R81SubCmds(pc),a0
	move.w	#$600,zoneAct
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Metallic Madness Act 2
; -------------------------------------------------------------------------

RunR82:
	lea	R82SubCmds(pc),a0
	move.w	#$601,zoneAct
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Metallic Madness Act 3
; -------------------------------------------------------------------------

RunR83:
	lea	R83SubCmds(pc),a0
	move.w	#$602,zoneAct
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run level
; -------------------------------------------------------------------------

RunLevel:
	moveq	#0,d0				; Get present file load command
	move.b	0(a0),d0

.LevelLoop:
	bsr.w	RunMMD				; Run level file

	tst.b	lives				; Do we still have lives left?
	bne.s	.CheckSpecStage			; If so, branch
	move.l	(sp)+,d0			; If not, exit
	bra.w	GameOver

.CheckSpecStage:
	tst.b	specialStage			; Are we going into a special stage?
	bne.s	.SpecialStage			; If so, branch
	rts

.SpecialStage:
	move.b	curSpecStage,specStageIDCmd	; Set stage ID
	move.b	timeStones,timeStonesCmd	; Copy time stones retrieved flags
	bclr	#0,specStageFlags		; Normal mode

	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD

	move.b	#1,palClearFlags		; Fade from white in next level
	cmpi.b	#%01111111,timeStones		; Do we have all of the time stones now?
	bne.s	.End				; If not, branch
	move.b	#1,goodFuture			; If so, set good future flag

.End:
	rts

; -------------------------------------------------------------------------
; Run boss level
; -------------------------------------------------------------------------

RunBossLevel:
	moveq	#0,d0				; Get good future file load command
	move.b	0(a0),d0
	tst.b	goodFuture			; Are we in the good future?
	bne.s	.RunLevel			; If so, branch
	move.b	1(a0),d0			; Get bad future file load command
	
.RunLevel:
	bsr.w	RunMMD				; Run level file

	tst.b	lives				; Do we still have lives left?
	bne.s	.NextLevel			; If so, branch
	move.l	(sp)+,d0			; If not, exit
	bra.w	GameOver

.NextLevel:
	addq.b	#1,savedLevel			; Next level
	cmpi.b	#7,savedLevel			; Are we at the end of the game?
	bcs.s	.End				; If not, branch
	subq.b	#1,savedLevel			; Cap level ID

.End:
	move.b	#0,checkpoint			; Reset checkpoint
	rts

; -------------------------------------------------------------------------
; Unlock time attack zone
; -------------------------------------------------------------------------
; PARAMETERS
;	d0.b - Level ID
; -------------------------------------------------------------------------

UnlockTimeAttackLevel:
	cmp.b	timeAttackUnlock,d0		; Is this level already unlocked?
	bls.s	.End				; If so, branch
	move.b	d0,timeAttackUnlock		; If not, unlock it

.End:
	rts

; -------------------------------------------------------------------------
; Level loading Sub CPU commands
; -------------------------------------------------------------------------

; Palmtree Panic
R11SubCmds:
	dc.b	SCMD_GHZ1
R12SubCmds:
	dc.b	SCMD_GHZ2
R13SubCmds:
	dc.b	SCMD_GHZ3

; Collision Chaos
R31SubCmds:
	dc.b	SCMD_GHZ1
R32SubCmds:
	dc.b	SCMD_GHZ2
R33SubCmds:
	dc.b	SCMD_GHZ3

; Tidal Tempest
R41SubCmds:
	dc.b	SCMD_GHZ1
R42SubCmds:
	dc.b	SCMD_GHZ2
R43SubCmds:
	dc.b	SCMD_GHZ3

; Quartz Quadrant
R51SubCmds:
	dc.b	SCMD_GHZ1
R52SubCmds:
	dc.b	SCMD_GHZ2
R53SubCmds:
	dc.b	SCMD_GHZ3

; Wacky Workbench
R61SubCmds:
	dc.b	SCMD_GHZ1
R62SubCmds:
	dc.b	SCMD_GHZ2
R63SubCmds:
	dc.b	SCMD_GHZ3

; Stardust Speedway
R71SubCmds:
	dc.b	SCMD_GHZ1
R72SubCmds:
	dc.b	SCMD_GHZ2
R73SubCmds:
	dc.b	SCMD_GHZ3

; Metallic Madness
R81SubCmds:
	dc.b	SCMD_GHZ1
R82SubCmds:
	dc.b	SCMD_GHZ2
R83SubCmds:
	dc.b	SCMD_GHZ3
	even

; -------------------------------------------------------------------------
; Demo mode
; -------------------------------------------------------------------------

Demo:
	moveq	#(.DemosEnd-.Demos)/2-1,d1	; Maximum demo ID
	
	lea	demoID,a6			; Get current demo ID
	moveq	#0,d0
	move.b	(a6),d0

	addq.b	#1,(a6)				; Advance demo ID
	cmp.b	(a6),d1				; Are we past the max ID?
	bcc.s	.RunDemo			; If not, branch
	move.b	#0,(a6)				; Wrap demo ID

.RunDemo:
	add.w	d0,d0				; Run demo
	move.w	.Demos(pc,d0.w),d0
	jmp	.Demos(pc,d0.w)

; -------------------------------------------------------------------------

.Demos:
	dc.w	Demo_OpenFMV-.Demos		; Opening FMV
.DemosEnd:

; -------------------------------------------------------------------------
; Opening FMV
; -------------------------------------------------------------------------

Demo_OpenFMV:
	move.w	#SCMD_OPENING,d0		; Run opening FMV file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	Demo_OpenFMV			; If so, loop
	rts

; -------------------------------------------------------------------------
; Sound test
; -------------------------------------------------------------------------

SoundTest:
	moveq	#SCMD_SNDTEST,d0		; Run sound test file
	bsr.w	RunMMD

	add.w	d0,d0				; Exit sound test
	move.w	.Exits(pc,d0.w),d0
	jmp	.Exits(pc,d0.w)

; -------------------------------------------------------------------------

.Exits:
	dc.w	SoundTest_Exit-.Exits		; Exit sound test

; -------------------------------------------------------------------------
; Exit sound test
; -------------------------------------------------------------------------

SoundTest_Exit:
	rts

; -------------------------------------------------------------------------
; Visual Mode
; -------------------------------------------------------------------------

VisualMode:
	move.w	#SCMD_VISMODE,d0		; Run Visual Mode file
	bsr.w	RunMMD

	add.w	d0,d0				; Play FMV
	move.w	.FMVs(pc,d0.w),d0
	jmp	.FMVs(pc,d0.w)

; -------------------------------------------------------------------------

.FMVs:
	dc.w	VisualMode_Exit-.FMVs		; Exit Visual Mode
	dc.w	VisualMode_OpenFMV-.FMVs	; Opening FMV
	dc.w	VisualMode_Exit-.FMVs		; Good ending FMV
	dc.w	VisualMode_Exit-.FMVs		; Bad ending FMV
	dc.w	VisualMode_Exit-.FMVs		; Pencil test FMV

; -------------------------------------------------------------------------
; Play opening FMV
; -------------------------------------------------------------------------

VisualMode_OpenFMV:
	move.w	#SCMD_OPENING,d0		; Run opening FMV file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	VisualMode_OpenFMV		; If so, loop

	bra.s	VisualMode			; Go back to menu

; -------------------------------------------------------------------------
; Exit Visual Mode
; -------------------------------------------------------------------------

VisualMode_Exit:
	rts

; -------------------------------------------------------------------------
; D.A. Garden
; -------------------------------------------------------------------------

DAGarden:
	move.w	#SCMD_DAGARDEN,d0		; Run D.A. Garden file
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Time Attack
; -------------------------------------------------------------------------

TimeAttack:
	rts

; -------------------------------------------------------------------------
; Run MMD file
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File load Sub CPU command ID
; -------------------------------------------------------------------------

RunMMD:
	move.l	a0,-(sp)			; Save a0
	move.w	d0,GACOMCMD0			; Set Sub CPU command ID

	lea	WORKRAMFILE,a1			; Clear work RAM file buffer
	moveq	#0,d0
	move.w	#WORKRAMFILESZ/16-1,d7

.ClearFileBuffer:
	rept	16/4
		move.l	d0,(a1)+
	endr
	dbf	d7,.ClearFileBuffer

	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	move.l	WORDRAM2M+mmdEntry,d0		; Get entry address
	beq.w	.End				; If it's not set, exit
	movea.l	d0,a0

	move.l	WORDRAM2M+mmdOrigin,d0		; Get origin address
	beq.s	.GetHInt			; If it's not set, branch
	
	movea.l	d0,a2				; Copy file to origin address
	lea	WORDRAM2M+mmdFile,a1
	move.w	WORDRAM2M+mmdSize,d7

.CopyFile:
	move.l	(a1)+,(a2)+
	dbf	d7,.CopyFile

.GetHInt:
	move	sr,-(sp)			; Save status register

	move.l	WORDRAM2M+mmdHInt,d0		; Get H-INT address
	beq.s	.GetVInt			; If it's not set, branch
	move.l	d0,_LEVEL4+2.w			; Set H-INT address

.GetVInt:
	move.l	WORDRAM2M+mmdVInt,d0		; Get V-INT address
	beq.s	.CheckFlags			; If it's not set, branch
	move.l	d0,_LEVEL6+2.w			; Set V-INT address

.CheckFlags:
	btst	#MMDSUB,WORDRAM2M+mmdFlags	; Should the Sub CPU have Word RAM access?
	beq.s	.NoSubWordRAM			; If not, branch
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access

.NoSubWordRAM:
	move	(sp)+,sr			; Restore status register

.WaitSubCPU:
	move.w	GACOMSTAT0,d0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait
	cmp.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	move.w	GACOMSTAT0,d0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	move.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPUDone			; If not, wait

	jsr	(a0)				; Run file
	move.b	d0,mmdReturnCode		; Set return code

	bsr.w	StopZ80				; Stop the Z80
	move.b	#FMC_STOP,FMDrvQueue2		; Stop FM sound
	bsr.w	StartZ80			; Start the Z80

	move.b	#0,ipxVSync			; Clear VSync flag
	move.l	#BlankInt,_LEVEL4+2.w		; Reset H-INT address
	move.l	#VInterrupt,_LEVEL6+2.w		; Reset V-INT address
	move.w	#$8134,ipxVDPReg1		; Reset VDP register 1 cache
	
	bset	#0,screenDisable		; Set screen disable flag
	bsr.w	VSync				; VSync
	
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access

.End:
	movea.l	(sp)+,a0			; Restore a0
	rts

; -------------------------------------------------------------------------

screenDisable:
	dc.b	0				; Screen disable flag
mmdReturnCode:
	dc.b	0				; MMD return code

; -------------------------------------------------------------------------
; V-BLANK interrupt handler
; -------------------------------------------------------------------------

VInterrupt:
	bset	#0,GAIRQ2			; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipxVSync			; Clear VSync flag
	bclr	#0,screenDisable		; Clear screen disable flag
	beq.s	BlankInt			; If it wasn't set branch
	
	move.w	#$8134,VDPCTRL			; If it was set, disable the screen

BlankInt:
	rte

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

ReadSaveData:
	bsr.w	GetBuRAMData			; Get Backup RAM data

	move.w	WORDRAM2M+svZone,savedLevel	; Read save data
	move.b	WORDRAM2M+svGoodFutures,goodFutures
	move.b	WORDRAM2M+svTitleFlags,titleFlags
	move.b	WORDRAM2M+svTmAtkUnlock,timeAttackUnlock
	move.b	WORDRAM2M+svUnknown,unkBuRAMVar
	move.b	WORDRAM2M+svSpecStage,curSpecStage
	move.b	WORDRAM2M+svTimeStones,timeStones

	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	rts

; -------------------------------------------------------------------------
; Get Backup RAM data
; -------------------------------------------------------------------------

GetBuRAMData:
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	
	move.w	#SCMD_RDTEMPSAVE,d0		; Read temporary save data
	btst	#0,saveDisabled			; Is saving to Backup RAM disabled?
	bne.s	.Read				; If so, branch
	move.w	#SCMD_READSAVE,d0		; Read Backup RAM save data
	
.Read:
	bsr.w	SubCPUCmd			; Run command
	bra.w	WaitWordRAMAccess		; Wait for Word RAM access

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

WriteSaveData:
	bsr.s	GetBuRAMData			; Get Backup RAM data

	move.w	savedLevel,WORDRAM2M+svZone	; Write save data
	move.b	goodFutures,WORDRAM2M+svGoodFutures
	move.b	titleFlags,WORDRAM2M+svTitleFlags
	move.b	timeAttackUnlock,WORDRAM2M+svTmAtkUnlock
	move.b	unkBuRAMVar,WORDRAM2M+svUnknown
	move.b	curSpecStage,WORDRAM2M+svSpecStage
	move.b	timeStones,WORDRAM2M+svTimeStones

	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access

	move.w	#SCMD_WRTEMPSAVE,d0		; Write temporary save data
	btst	#0,saveDisabled			; Is saving to Backup RAM disabled?
	bne.s	.Read				; If so, branch
	move.w	#SCMD_WRITESAVE,d0		; Write Backup RAM save data
	
.Read:
	bsr.w	SubCPUCmd			; Run command
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bra.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	
; -------------------------------------------------------------------------
; Send the Sub CPU a command
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmd:
	move.w	d0,GACOMCMD0			; Set command ID

.WaitSubCPU:
	move.w	GACOMSTAT0,d0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait
	cmp.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	move.w	GACOMSTAT0,d0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	move.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPUDone			; If not, wait
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#0,GAMEMMODE			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	bset	#1,GAMEMMODE			; Give Sub CPU Word RAM access
	btst	#1,GAMEMMODE			; Has it been given?
	beq.s	GiveWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR			; Save status register
	move	#$2700,sr			; Disable interrupts
	Z80STOP					; Stop the Z80
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

StartZ80:
	Z80START				; Start the Z80
	move	savedSR,sr			; Restore status register
	rts

; -------------------------------------------------------------------------
; VSync
; -------------------------------------------------------------------------

VSync:
	bset	#0,ipxVSync			; Set VSync flag
	move	#$2500,sr			; Enable V-INT

.Wait:
	btst	#0,ipxVSync			; Has the V-INT handler run?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Send the Sub CPU a command (copy)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmdCopy:
	move.w	d0,GACOMCMD0			; Send the command

.WaitSubCPU:
	move.w	GACOMSTAT0,d0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait
	cmp.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	move.w	GACOMSTAT0,d0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	move.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPUDone			; If not, wait
	rts

; -------------------------------------------------------------------------
; Saved status register
; -------------------------------------------------------------------------

savedSR:
	dc.w	0

; -------------------------------------------------------------------------

	jmp	0.w				; Unreferenced
	ALIGN	MAINVARS

; -------------------------------------------------------------------------
