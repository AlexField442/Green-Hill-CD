@echo off

set REGION=1
set OUTPUT=scdbuilt.iso

if not exist out mkdir out
if not exist out\files mkdir out\files
if not exist out\misc mkdir out\misc
if %REGION%==0 (copy original\japan\*.* out\files > nul)
if %REGION%==1 (copy original\usa\*.* out\files > nul)
if %REGION%==2 (copy original\europe\*.* out\files > nul)
del out\files\.gitkeep > nul

cd src

set ASM68K=..\bin\asm68k.exe /p /o ae-,l.,ow+ /e REGION=%REGION%
set AS=..\bin\asw.exe -q -xx -n -A -L -U -E -i .
set P2BIN=..\bin\p2bin.exe

if %REGION%==0 (set FMVWAV="FMV\Data\Opening (Japan, Europe).wav")
if %REGION%==1 (set FMVWAV="FMV\Data\Opening (USA).wav")
if %REGION%==2 (set FMVWAV="FMV\Data\Opening (Japan, Europe).wav")

%AS% "Sound Drivers\FM\_Driver.asm"
if exist "Sound Drivers\FM\_Driver.p" (
    %P2BIN% "Sound Drivers\FM\_Driver.p" "..\out\misc\fm_driver.bin"
    del "Sound Drivers\FM\_Driver.p" > nul
) else (
    echo **************************************************************************************
    echo *                                                                                    *
    echo * FM sound driver failed to build. See "Sound Drivers\FM\_Driver.log" for more info. *
    echo *                                                                                    *
    echo **************************************************************************************
)

%ASM68K% "DA Garden\Track Titles.asm", "..\out\files\PLANET_D.BIN", "DA Garden\Track Titles.sym"
..\bin\dumpasmsym.exe -m asm "DA Garden\Track Titles.sym" -o "DA Garden\Track Title Labels.inc"
if exist "DA Garden\Track Titles.sym" ( del "DA Garden\Track Titles.sym" > nul )
%ASM68K% "DA Garden\Main.asm", "..\out\files\PLANET_M.MMD", , "DA Garden\Main.lst"
%ASM68K% "DA Garden\Sub.asm", "..\out\files\PLANET_S.BIN", , "DA Garden\Sub.lst"

%ASM68K% "CD Initial Program\IP.asm", "..\out\misc\ip.bin", , "CD Initial Program\IP.lst"
%ASM68K% "CD Initial Program\IPX.asm", "..\out\files\IPX___.MMD",  , "CD Initial Program\IPX.lst"
%ASM68K% "CD System Program\SP.asm", "..\out\misc\sp.bin", , "CD System Program\SP.lst"
%ASM68K% "CD System Program\SPX.asm", "..\out\files\SPX___.BIN", , "CD System Program\SPX.lst"
%ASM68K% "Backup RAM\Initialization\Main.asm", "..\out\files\BRAMINIT.MMD", , "Backup RAM\Initialization\Main.lst"
%ASM68K% "Backup RAM\Sub.asm", "..\out\files\BRAMSUB.BIN", , "Backup RAM\Sub.lst"
%ASM68K% "Mega Drive Init\Main.asm", "..\out\files\MDINIT.MMD", , "Mega Drive Init\Main.lst"
%ASM68K% "Time Warp Cutscene\Main.asm", "..\out\files\WARP__.MMD", , "Time Warp Cutscene\Main.lst"
%ASM68K% "Sound Drivers\PCM\Palmtree Panic.asm", "..\out\files\SNCBNK1B.BIN", , "Sound Drivers\PCM\Palmtree Panic.lst"
%ASM68K% "Sound Drivers\PCM\Collision Chaos.asm", "..\out\files\SNCBNK3B.BIN", , "Sound Drivers\PCM\Collision Chaos.lst"
%ASM68K% "Sound Drivers\PCM\Tidal Tempest.asm", "..\out\files\SNCBNK4B.BIN", , "Sound Drivers\PCM\Tidal Tempest.lst"
%ASM68K% "Sound Drivers\PCM\Quartz Quadrant.asm", "..\out\files\SNCBNK5B.BIN", , "Sound Drivers\PCM\Quartz Quadrant.lst"
%ASM68K% "Sound Drivers\PCM\Wacky Workbench.asm", "..\out\files\SNCBNK6B.BIN", , "Sound Drivers\PCM\Wacky Workbench.lst"
%ASM68K% "Sound Drivers\PCM\Stardust Speedway.asm", "..\out\files\SNCBNK7B.BIN", , "Sound Drivers\PCM\Stardust Speedway.lst"
%ASM68K% "Sound Drivers\PCM\Metallic Madness.asm", "..\out\files\SNCBNK8B.BIN", , "Sound Drivers\PCM\Metallic Madness.lst"
%ASM68K% "Sound Drivers\PCM\Boss.asm", "..\out\files\SNCBNKB1.BIN", , "Sound Drivers\PCM\Boss.lst"
%ASM68K% "Sound Drivers\PCM\Final Boss.asm", "..\out\files\SNCBNKB2.BIN", , "Sound Drivers\PCM\Final Boss.lst"

%ASM68K% "Title Screen\Main.asm", "..\out\files\TITLEM.MMD", , "Title Screen\Main.lst"
%ASM68K% "Title Screen\Sub.asm", "..\out\files\TITLES.BIN", , "Title Screen\Sub.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Sound Test.asm", "..\out\files\SOSEL_.MMD", , "Title Screen\Secrets\Sound Test.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Stage Select.asm", "..\out\files\STSEL_.MMD", , "Title Screen\Secrets\Stage Select.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=1 "Title Screen\Secrets\Best Staff Times.asm", "..\out\files\DUMMY4.MMD", , "Title Screen\Secrets\Best Staff Times.lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Special Stage 8 Credits.asm", "..\out\files\SPEEND.MMD", , "Title Screen\Secrets\Special Stage 8 Credits.lst"

%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=0 "Title Screen\Secrets\Sound Test Image.asm", "..\out\files\NISI.MMD", , "Title Screen\Secrets\Sound Test Image (Fun Is Infinite).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=1 "Title Screen\Secrets\Sound Test Image.asm", "..\out\files\DUMMY0.MMD", , "Title Screen\Secrets\Sound Test Image (M.C. Sonic).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=2 "Title Screen\Secrets\Sound Test Image.asm", "..\out\files\DUMMY1.MMD", , "Title Screen\Secrets\Sound Test Image (Tails).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=3 "Title Screen\Secrets\Sound Test Image.asm", "..\out\files\DUMMY2.MMD", , "Title Screen\Secrets\Sound Test Image (Batman).lst"
%ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=4 "Title Screen\Secrets\Sound Test Image.asm", "..\out\files\DUMMY3.MMD", , "Title Screen\Secrets\Sound Test Image (Cute Sonic).lst"

%ASM68K% "FMV\Main (Opening).asm", "..\out\files\OPEN_M.MMD", , "FMV\Main (Opening).lst"
%ASM68K% "FMV\Sub (Opening).asm", "..\out\files\OPEN_S.BIN", , "FMV\Sub (Opening).lst"
%ASM68K% /e DATAFILE=0 "FMV\Sub (Ending).asm", "..\out\files\GOODEND.BIN", , "FMV\Sub (Good Ending).lst"
%ASM68K% /e DATAFILE=1 "FMV\Sub (Ending).asm", "..\out\files\BADEND.BIN", , "FMV\Sub (Bad Ending).lst"
%ASM68K% "FMV\Sub (Pencil Test).asm", "..\out\files\PTEST.BIN", , "FMV\Sub (Pencil Test).lst"
echo.
echo Making opening FMV STM...
..\bin\MakeSTM.exe "FMV\Data\Opening.gif" %FMVWAV% 0 0 "..\out\files\OPN.STM"

%ASM68K% "Visual Mode\Main.asm", "..\out\files\VM____.MMD", , "Visual Mode\Main.lst"

%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Present.asm", "..\out\files\R11A__.MMD", , "Level\Palmtree Panic\Act 1 Present.lst"
%ASM68K% /e DEMO=1 "Level\Palmtree Panic\Act 1 Present.asm", "..\out\files\DEMO11A.MMD", , "Level\Palmtree Panic\Act 1 Present (Demo).lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Present.asm", "..\out\files\R12A__.MMD", , "Level\Palmtree Panic\Act 2 Present.lst"

%ASM68K% "Special Stage\Stage Data.asm", "Special Stage\Stage Data.bin", "Special Stage\Stage Data.sym"
..\bin\dumpasmsym.exe -m asm "Special Stage\Stage Data.sym" -o "Special Stage\Stage Data Labels.inc"
if exist "Special Stage\Stage Data.sym" ( del "Special Stage\Stage Data.sym" > nul )
%ASM68K% "Special Stage\Main.asm", "..\out\files\SPMM__.MMD", , "Special Stage\Main.lst"
%ASM68K% "Special Stage\Sub.asm", "..\out\files\SPSS__.BIN", , "Special Stage\Sub.lst"

echo.
echo Compiling filesystem...
..\bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o ..\out\misc\files.bin ..\out\files

%ASM68K% main.asm, ..\out\%OUTPUT%
del ..\out\misc\files.bin > nul

pause