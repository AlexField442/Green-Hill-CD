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

%ASM68K% "CD Initial Program\IP.asm", "..\out\misc\ip.bin", , "CD Initial Program\IP.lst"
%ASM68K% "CD Initial Program\IPX.asm", "..\out\files\IPX___.MMD",  , "CD Initial Program\IPX.lst"
%ASM68K% "CD System Program\SP.asm", "..\out\misc\sp.bin", , "CD System Program\SP.lst"
%ASM68K% /e loadOld=1 "CD System Program\SPX.asm", "..\out\files\SPX___.BIN", , "CD System Program\SPX.lst"
%ASM68K% "Backup RAM\Initialization\Main.asm", "..\out\files\BRAMINIT.MMD", , "Backup RAM\Initialization\Main.lst"
%ASM68K% "Backup RAM\Sub.asm", "..\out\files\BRAMSUB.BIN", , "Backup RAM\Sub.lst"
%ASM68K% "Mega Drive Init\Main.asm", "..\out\files\MDINIT.MMD", , "Mega Drive Init\Main.lst"
%ASM68K% "Sound Drivers\PCM\Palmtree Panic.asm", "..\out\files\SNCBNK1B.BIN", , "Sound Drivers\PCM\Palmtree Panic.lst"


%ASM68K% "Title Screen OLD\Main.asm", "..\out\files\TITLEM.MMD", , "Title Screen OLD\Main.lst"
%ASM68K% "Title Screen OLD\Sub.asm", "..\out\files\TITLES.BIN", , "Title Screen OLD\Sub.lst"

%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Present.asm", "..\out\files\GHZ1__.MMD", , "Level\Palmtree Panic\Act 1 Present.lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 2 Present.asm", "..\out\files\GHZ2__.MMD", , "Level\Palmtree Panic\Act 2 Present.lst"
%ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 3 Present.asm", "..\out\files\GHZ3__.MMD", , "Level\Palmtree Panic\Act 3 Present.lst"

echo.
echo Compiling filesystem...
..\bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o ..\out\misc\files.bin ..\out\files

%ASM68K% main.asm, ..\out\%OUTPUT%
del ..\out\misc\files.bin > nul

pause