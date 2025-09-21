; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; System definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; File IDs
; -------------------------------------------------------------------------

	rsreset
FID_GHZ1	rs.b	1			; Green Hill Act 1
FID_GHZ2	rs.b	1			; Green Hill Act 2
FID_GHZ3	rs.b	1			; Green Hill Act 3

FID_MDINIT	rs.b	1			; Mega Drive initialization
FID_SNDTEST	rs.b	1			; Sound test
FID_STAGESEL	rs.b	1			; Stage select
FID_R12A	rs.b	1			; Palmtree Panic Act 2 Present
FID_TITLEMAIN	rs.b	1			; Title screen (Main CPU)
FID_TITLESUB	rs.b	1			; Title screen (Sub CPU)
FID_WARP	rs.b	1			; Warp sequence
FID_TIMEATKMAIN	rs.b	1			; Time attack menu (Main CPU)
FID_TIMEATKSUB	rs.b	1			; Time attack menu (Sub CPU)
FID_IPX		rs.b	1			; Main program
FID_PENCILSTM	rs.b	1			; Pencil test FMV data
FID_OPENSTM	rs.b	1			; Opening FMV data
FID_BADENDSTM	rs.b	1			; Bad ending FMV data
FID_GOODENDSTM	rs.b	1			; Good ending FMV data
FID_OPENMAIN	rs.b	1			; Opening FMV (Main CPU)
FID_OPENSUB	rs.b	1			; Opening FMV (Sub CPU)
FID_COMINSOON	rs.b	1			; "Comin' Soon" screen
FID_DAGARDMAIN	rs.b	1			; D.A. Garden (Main CPU)
FID_DAGARDSUB	rs.b	1			; D.A. Garden (Sub CPU)
FID_R31A	rs.b	1			; Collision Chaos Act 1 Present
FID_R31B	rs.b	1			; Collision Chaos Act 1 Past
FID_R31C	rs.b	1			; Collision Chaos Act 1 Good Future
FID_R31D	rs.b	1			; Collision Chaos Act 1 Bad Future
FID_R32A	rs.b	1			; Collision Chaos Act 2 Present 
FID_R32B	rs.b	1			; Collision Chaos Act 2 Past 
FID_R32C	rs.b	1			; Collision Chaos Act 2 Good Future 
FID_R32D	rs.b	1			; Collision Chaos Act 2 Bad Future 
FID_R33C	rs.b	1			; Collision Chaos Act 3 Good Future 
FID_R33D	rs.b	1			; Collision Chaos Act 3 Bad Future 
FID_R13C	rs.b	1			; Palmtree Panic Act 3 Good Future
FID_R41A	rs.b	1			; Tidal Tempest Act 1 Present
FID_R41B	rs.b	1			; Tidal Tempest Act 1 Past
FID_R41C	rs.b	1			; Tidal Tempest Act 1 Good Future
FID_R41D	rs.b	1			; Tidal Tempest Act 1 Bad Future
FID_R42A	rs.b	1			; Tidal Tempest Act 2 Present 
FID_R42B	rs.b	1			; Tidal Tempest Act 2 Past 
FID_R42C	rs.b	1			; Tidal Tempest Act 2 Good Future 
FID_R42D	rs.b	1			; Tidal Tempest Act 2 Bad Future 
FID_R43C	rs.b	1			; Tidal Tempest Act 3 Good Future 
FID_R43D	rs.b	1			; Tidal Tempest Act 3 Bad Future 
FID_R51A	rs.b	1			; Quartz Quadrant Act 1 Present
FID_R51B	rs.b	1			; Quartz Quadrant Act 1 Past
FID_R51C	rs.b	1			; Quartz Quadrant Act 1 Good Future
FID_R51D	rs.b	1			; Quartz Quadrant Act 1 Bad Future
FID_R52A	rs.b	1			; Quartz Quadrant Act 2 Present 
FID_R52B	rs.b	1			; Quartz Quadrant Act 2 Past 
FID_R52C	rs.b	1			; Quartz Quadrant Act 2 Good Future 
FID_R52D	rs.b	1			; Quartz Quadrant Act 2 Bad Future 
FID_R53C	rs.b	1			; Quartz Quadrant Act 3 Good Future 
FID_R53D	rs.b	1			; Quartz Quadrant Act 3 Bad Future 
FID_R61A	rs.b	1			; Wacky Workbench Act 1 Present
FID_R61B	rs.b	1			; Wacky Workbench Act 1 Past
FID_R61C	rs.b	1			; Wacky Workbench Act 1 Good Future
FID_R61D	rs.b	1			; Wacky Workbench Act 1 Bad Future
FID_R62A	rs.b	1			; Wacky Workbench Act 2 Present 
FID_R62B	rs.b	1			; Wacky Workbench Act 2 Past 
FID_R62C	rs.b	1			; Wacky Workbench Act 2 Good Future 
FID_R62D	rs.b	1			; Wacky Workbench Act 2 Bad Future 
FID_R63C	rs.b	1			; Wacky Workbench Act 3 Good Future 
FID_R63D	rs.b	1			; Wacky Workbench Act 3 Bad Future 
FID_R71A	rs.b	1			; Stardust Speedway Act 1 Present
FID_R71B	rs.b	1			; Stardust Speedway Act 1 Past
FID_R71C	rs.b	1			; Stardust Speedway Act 1 Good Future
FID_R71D	rs.b	1			; Stardust Speedway Act 1 Bad Future
FID_R72A	rs.b	1			; Stardust Speedway Act 2 Present 
FID_R72B	rs.b	1			; Stardust Speedway Act 2 Past 
FID_R72C	rs.b	1			; Stardust Speedway Act 2 Good Future 
FID_R72D	rs.b	1			; Stardust Speedway Act 2 Bad Future 
FID_R73C	rs.b	1			; Stardust Speedway Act 3 Good Future 
FID_R73D	rs.b	1			; Stardust Speedway Act 3 Bad Future 
FID_R81A	rs.b	1			; Metallic Madness Act 1 Present
FID_R81B	rs.b	1			; Metallic Madness Act 1 Past
FID_R81C	rs.b	1			; Metallic Madness Act 1 Good Future
FID_R81D	rs.b	1			; Metallic Madness Act 1 Bad Future
FID_R82A	rs.b	1			; Metallic Madness Act 2 Present 
FID_R82B	rs.b	1			; Metallic Madness Act 2 Past 
FID_R82C	rs.b	1			; Metallic Madness Act 2 Good Future 
FID_R82D	rs.b	1			; Metallic Madness Act 2 Bad Future 
FID_R83C	rs.b	1			; Metallic Madness Act 3 Good Future 
FID_R83D	rs.b	1			; Metallic Madness Act 3 Bad Future 
FID_SPECMAIN	rs.b	1			; Special Stage (Main CPU)
FID_SPECSUB	rs.b	1			; Special Stage (Sub CPU)
FID_R1PCM	rs.b	1			; PCM driver (Palmtree Panic)
FID_R3PCM	rs.b	1			; PCM driver (Collision Chaos)
FID_R4PCM	rs.b	1			; PCM driver (Tidal Tempest)
FID_R5PCM	rs.b	1			; PCM driver (Quartz Quadrant)
FID_R6PCM	rs.b	1			; PCM driver (Wacky Workbench)
FID_R7PCM	rs.b	1			; PCM driver (Stardust Speedway)
FID_R8PCM	rs.b	1			; PCM driver (Metallic Madness)
FID_BOSSPCM	rs.b	1			; PCM driver (Boss)
FID_FINALPCM	rs.b	1			; PCM driver (Final boss)
FID_DAGARDDATA	rs.b	1			; D.A. Garden data
FID_GHZ1DEMO	rs.b	1			; Palmtree Panic Act 1 Good Future demo
FID_VISMODE	rs.b	1			; Visual Mode
FID_BURAMINIT	rs.b	1			; Backup RAM initialization
FID_BURAMSUB	rs.b	1			; Backup RAM functions
FID_BURAMMAIN	rs.b	1			; Backup RAM manager

; -------------------------------------------------------------------------
; Sub CPU commands
; -------------------------------------------------------------------------

	rsset	1
SCMD_GHZ1	rs.b	1			; Load Green Hill Act 1
SCMD_GHZ2	rs.b	1			; Load Green Hill Act 2
SCMD_GHZ3	rs.b	1			; Load Green Hill Act 3

SCMD_LZ1	rs.b	1			; Load Green Hill Act 1
SCMD_LZ2	rs.b	1			; Load Green Hill Act 2
SCMD_LZ3	rs.b	1			; Load Green Hill Act 3

SCMD_MZ1	rs.b	1			; Load Green Hill Act 1
SCMD_MZ2	rs.b	1			; Load Green Hill Act 2
SCMD_MZ3	rs.b	1			; Load Green Hill Act 3

SCMD_MDINIT	rs.b	1			; Load Mega Drive initialization
SCMD_STAGESEL	rs.b	1			; Load stage select
SCMD_TITLE	rs.b	1			; Load title screen
SCMD_WARP	rs.b	1			; Load warp sequence
SCMD_TIMEATK	rs.b	1			; Load time attack menu

SCMD_FADECDA	rs.b	1			; Fade out CDDA music
SCMD_R1AMUS	rs.b	1			; Play Palmtree Panic Present music
SCMD_R1CMUS	rs.b	1			; Play Palmtree Panic Good Future music
SCMD_R1DMUS	rs.b	1			; Play Palmtree Panic Bad Future music
SCMD_R3AMUS	rs.b	1			; Play Collision Chaos Present music
SCMD_R3CMUS	rs.b	1			; Play Collision Chaos Good Future music
SCMD_R3DMUS	rs.b	1			; Play Collision Chaos Bad Future music
SCMD_R4AMUS	rs.b	1			; Play Tidal Tempest Present music
SCMD_R4CMUS	rs.b	1			; Play Tidal Tempest Good Future music
SCMD_R4DMUS	rs.b	1			; Play Tidal Tempest Bad Future music
SCMD_R5AMUS	rs.b	1			; Play Quartz Quadrant Present music
SCMD_R5CMUS	rs.b	1			; Play Quartz Quadrant Good Future music
SCMD_R5DMUS	rs.b	1			; Play Quartz Quadrant Bad Future music
SCMD_R6AMUS	rs.b	1			; Play Wacky Workbench Present music
SCMD_R6CMUS	rs.b	1			; Play Wacky Workbench Good Future music
SCMD_R6DMUS	rs.b	1			; Play Wacky Workbench Bad Future music
SCMD_R7AMUS	rs.b	1			; Play Stardust Speedway Present music
SCMD_R7CMUS	rs.b	1			; Play Stardust Speedway Good Future music
SCMD_R7DMUS	rs.b	1			; Play Stardust Speedway Bad Future music
SCMD_R8AMUS	rs.b	1			; Play Metallic Madness Present music
SCMD_R8CMUS	rs.b	1			; Play Metallic Madness Good Future music
SCMD_IPX	rs.b	1			; Load main program
SCMD_SNDTEST	rs.b	1			; Load sound test
		rs.b	1			; Invalid
SCMD_R8DMUS	rs.b	1			; Play Metallic Madness Bad Future music
SCMD_BOSSMUS	rs.b	1			; Play boss music
SCMD_FINALMUS	rs.b	1			; Play final boss music
SCMD_TITLEMUS	rs.b	1			; Play title screen music
SCMD_TMATKMUS	rs.b	1			; Play time attack menu music
SCMD_RESULTMUS	rs.b	1			; Play results music
SCMD_SHOESMUS	rs.b	1			; Play speed shoes music
SCMD_INVINCMUS	rs.b	1			; Play invincibility music
SCMD_GMOVERMUS	rs.b	1			; Play game over music
SCMD_SPECMUS	rs.b	1			; Play special stage music
SCMD_DAGRDNMUS	rs.b	1			; Play D.A. Garden music
SCMD_PROTOWARP	rs.b	1			; Play prototype warp sound
SCMD_INTROMUS	rs.b	1			; Play opening music
SCMD_ENDINGMUS	rs.b	1			; Play ending music
SCMD_STOPCDDA	rs.b	1			; Stop CDDA music
SCMD_SPECSTAGE	rs.b	1			; Load special stage
SCMD_FUTURESFX	rs.b	1			; Play "Future" voice clip
SCMD_PASTSFX	rs.b	1			; Play "Past" voice clip
SCMD_ALRIGHTSFX	rs.b	1			; Play "Alright" voice clip
SCMD_GIVEUPSFX	rs.b	1			; Play "I'm outta here" voice clip
SCMD_YESSFX	rs.b	1			; Play "Yes" voice clip
SCMD_YEAHSFX	rs.b	1			; Play "Yeah" voice clip
SCMD_GIGGLESFX	rs.b	1			; Play Amy giggle voice clip
SCMD_YELPSFX	rs.b	1			; Play Amy yelp voice clip
SCMD_STOMPSFX	rs.b	1			; Play mech stomp sound
SCMD_BUMPERSFX	rs.b	1			; Play bumper sound
SCMD_PASTMUS	rs.b	1			; Play Past music
SCMD_DAGARDEN	rs.b	1			; Load D.A. Garden
SCMD_FADEPCM	rs.b	1			; Fade out PCM
SCMD_STOPPCM	rs.b	1			; Stop PCM
SCMD_VISMODE	rs.b	1			; Load Visual Mode menu
SCMD_INITSS2	rs.b	1			; Reset special stage flags
SCMD_READSAVE	rs.b	1			; Read save data
SCMD_WRITESAVE	rs.b	1			; Write save data
SCMD_BURAMINIT	rs.b	1			; Load Backup RAM initialization
SCMD_INITSS	rs.b	1			; Reset special stage flags
SCMD_RDTEMPSAVE	rs.b	1			; Read temporary save data
SCMD_WRTEMPSAVE	rs.b	1			; Write temporary save data
SCMD_BURAMMGR	rs.b	1			; Load Backup RAM manager
SCMD_RESETVOL	rs.b	1			; Reset CDDA music volume
SCMD_PAUSEPCM	rs.b	1			; Pause PCM
SCMD_UNPAUSEPCM	rs.b	1			; Unpause PCM
SCMD_BREAKSFX	rs.b	1			; Play glass break sound
SCMD_PAUSECDA	rs.b	1			; Pause CDDA music
SCMD_UNPAUSECDA	rs.b	1			; Unpause CDDA music
SCMD_OPENING	rs.b	1			; Load opening FMV
SCMD_COMINSOON	rs.b	1			; Load "Comin' Soon" screen

; -------------------------------------------------------------------------

	if def(SUBCPU)

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; System program
SPVariables	EQU	$7000			; Variables
SaveDataTemp	EQU	$7400			; Temporary save data buffer
SPIRQ2		EQU	$7700			; IRQ2 handler
LoadFile	EQU	$7800			; Load file
GetFileName	EQU	$7840			; Get file name
FileFunc	EQU	$7880			; File engine function handler
FileVars	EQU	$8C00			; File engine variables

; System program extension
SPX		EQU	$B800			; SPX start location
SPXFileTable	EQU	SPX			; SPX file table
SPXStart	EQU	SPX+$800		; SPX code start
Stack		EQU	$10000			; Stack base

; FMV
FMVPCMBUF	EQU	PRGRAM+$40000		; PCM data buffer
FMVGFXBUF	EQU	WORDRAM1M		; Graphics data buffer

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; File engine functions
	rsreset
FFUNC_INIT	rs.b	1			; Initialize
FFUNC_OPER	rs.b	1			; Perform operation
FFUNC_STATUS	rs.b	1			; Get status
FFUNC_GETFILES	rs.b	1			; Get files
FFUNC_LOADFILE	rs.b	1			; Load file
FFUNC_FINDFILE	rs.b	1			; Find file
FFUNC_LOADFMV	rs.b	1			; Load FMV
FFUNC_RESET	rs.b	1			; Reset
FFUNC_LOADFMVM	rs.b	1			; Load FMV (mute)

; File engine operation modes
	rsreset
FMODE_NONE	rs.b	1			; No function
FMODE_GETFILES	rs.b	1			; Get files
FMODE_LOADFILE	rs.b	1			; Load file
FMODE_LOADFMV	rs.b	1			; Load FMV
FMODE_LOADFMVM	rs.b	1			; Load FMV (mute)

; File engine statuses
FSTAT_OK	EQU	100			; OK
FSTAT_GETFAIL	EQU	-1			; File get failed
FSTAT_NOTFOUND	EQU	-2			; File not found
FSTAT_LOADFAIL	EQU	-3			; File load failed
FSTAT_READFAIL	EQU	-100			; Failed
FSTAT_FMVFAIL	EQU	-111			; FMV load failed

; FMV data types
FMVT_PCM	EQU	0			; PCM data type
FMVT_GFX	EQU	1			; Graphics data type

; FMV flags
FMVF_INIT	EQU	3			; Initialized flag
FMVF_PBUF	EQU	4			; PCM buffer ID
FMVF_READY	EQU	5			; Ready flag
FMVF_SECT	EQU	7			; Reading data section 1 flag

; File data
FILENAMESZ	EQU	12			; File name length

; -------------------------------------------------------------------------
; SP variables
; -------------------------------------------------------------------------

	rsset	SPVariables
curPCMDriver	rs.l	1			; Current PCM driver
ssFlagsCopy	rs.b	1			; Special stage flags copy
pcmDrvFlags	rs.b	1			; PCM driver flags
		rs.b	$400-__rs
SPVARSSZ	rs.b	1			; Size of structure

; -------------------------------------------------------------------------
; File engine variables structure
; -------------------------------------------------------------------------

	rsreset
feOperMark	rs.l	1			; Operation bookmark
feSector	rs.l	1			; Sector to read from
feSectorCnt	rs.l	1			; Number of sectors to read
feReturnAddr	rs.l	1			; Return address for CD read functions
feReadBuffer	rs.l	1			; Read buffer address
feReadTime	rs.b	0			; Time of read sector
feReadMin	rs.b	1			; Read sector minute
feReadSec	rs.b	1			; Read sector second
feReadFrame	rs.b	1			; Read sector frame
		rs.b	1
feDirSectors	rs.b	0			; Directory size in sectors
feFileSize	rs.l	1			; File size buffer
feOperMode	rs.w	1			; Operation mode
feStatus	rs.w	1			; Status code
feFileCount	rs.w	1			; File count
feWaitTime	rs.w	1			; Wait timer
feRetries	rs.w	1			; Retry counter
feSectorsRead	rs.w	1			; Number of sectors read
feCDC		rs.b	1			; CDC mode
feSectorFrame	rs.b	1			; Sector frame
feFileName	rs.b	FILENAMESZ		; File name buffer
		rs.b	$100-__rs
feFileList	rs.b	$2000			; File list
feDirReadBuf	rs.b	$900			; Directory read buffer
feFMVSectFrame	rs.w	1			; FMV sector frame
feFMVDataType	rs.b	1			; FMV read data type
feFMV		rs.b	1			; FMV flags
feFMVFailCount	rs.b	1			; FMV fail counter
FILEVARSSZ	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; File entry structure
; -------------------------------------------------------------------------

	rsreset
fileName	rs.b	FILENAMESZ		; File name
		rs.b	$17-__rs
fileFlags	rs.b	1			; File flags
fileSector	rs.l	1			; File sector
fileLength	rs.l	1			; File size
FILEENTRYSZ	rs.b	0			; Size of structure
	endif

; -------------------------------------------------------------------------
