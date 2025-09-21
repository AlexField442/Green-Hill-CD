@echo off
set REGION=1

if %REGION%==0 (set REGPATH=Japan)
if %REGION%==1 (set REGPATH=USA)
if %REGION%==2 (set REGPATH=Europe)

if %REGION%==0 fc /b original\ip_japan.bin out\misc\ip.bin
if %REGION%==1 fc /b original\ip_usa.bin out\misc\ip.bin
if %REGION%==2 fc /b original\ip_europe.bin out\misc\ip.bin
fc /b original\sp.bin out\misc\sp.bin
fc /b original\%REGPATH%\IPX___.MMD out\files\IPX___.MMD
fc /b original\%REGPATH%\SPX___.BIN out\files\SPX___.BIN
fc /b original\%REGPATH%\BRAMINIT.MMD out\files\BRAMINIT.MMD
fc /b original\%REGPATH%\BRAMSUB.BIN out\files\BRAMSUB.BIN
fc /b original\%REGPATH%\MDINIT.MMD out\files\MDINIT.MMD
fc /b original\%REGPATH%\WARP__.MMD out\files\WARP__.MMD
fc /b original\%REGPATH%\SNCBNK1B.BIN out\files\SNCBNK1B.BIN
fc /b original\%REGPATH%\SNCBNK3B.BIN out\files\SNCBNK3B.BIN
fc /b original\%REGPATH%\SNCBNK4B.BIN out\files\SNCBNK4B.BIN
fc /b original\%REGPATH%\SNCBNK5B.BIN out\files\SNCBNK5B.BIN
fc /b original\%REGPATH%\SNCBNK6B.BIN out\files\SNCBNK6B.BIN
fc /b original\%REGPATH%\SNCBNK7B.BIN out\files\SNCBNK7B.BIN
fc /b original\%REGPATH%\SNCBNK8B.BIN out\files\SNCBNK8B.BIN
fc /b original\%REGPATH%\SNCBNKB1.BIN out\files\SNCBNKB1.BIN
fc /b original\%REGPATH%\SNCBNKB2.BIN out\files\SNCBNKB2.BIN
fc /b original\%REGPATH%\TITLEM.MMD out\files\TITLEM.MMD
fc /b original\%REGPATH%\TITLES.BIN out\files\TITLES.BIN
fc /b original\%REGPATH%\STSEL_.MMD out\files\STSEL_.MMD
fc /b original\%REGPATH%\SOSEL_.MMD out\files\SOSEL_.MMD
fc /b original\%REGPATH%\NISI.MMD out\files\NISI.MMD
fc /b original\%REGPATH%\DUMMY0.MMD out\files\DUMMY0.MMD
fc /b original\%REGPATH%\DUMMY1.MMD out\files\DUMMY1.MMD
fc /b original\%REGPATH%\DUMMY2.MMD out\files\DUMMY2.MMD
fc /b original\%REGPATH%\DUMMY3.MMD out\files\DUMMY3.MMD
fc /b original\%REGPATH%\DUMMY4.MMD out\files\DUMMY4.MMD
fc /b original\%REGPATH%\DUMMY5.MMD out\files\DUMMY5.MMD
fc /b original\%REGPATH%\DUMMY6.MMD out\files\DUMMY6.MMD
fc /b original\%REGPATH%\DUMMY7.MMD out\files\DUMMY7.MMD
fc /b original\%REGPATH%\DUMMY8.MMD out\files\DUMMY8.MMD
fc /b original\%REGPATH%\DUMMY9.MMD out\files\DUMMY9.MMD
fc /b original\%REGPATH%\SPEEND.MMD out\files\SPEEND.MMD
fc /b original\%REGPATH%\OPEN_M.MMD out\files\OPEN_M.MMD
fc /b original\%REGPATH%\OPEN_S.BIN out\files\OPEN_S.BIN
fc /b original\%REGPATH%\OPN.STM out\files\OPN.STM
fc /b original\%REGPATH%\GOODEND.BIN out\files\GOODEND.BIN
fc /b original\%REGPATH%\BADEND.BIN out\files\BADEND.BIN
fc /b original\%REGPATH%\PTEST.BIN out\files\PTEST.BIN
fc /b original\%REGPATH%\PLANET_M.MMD out\files\PLANET_M.MMD
fc /b original\%REGPATH%\PLANET_S.BIN out\files\PLANET_S.BIN
fc /b original\%REGPATH%\PLANET_D.BIN out\files\PLANET_D.BIN
fc /b original\%REGPATH%\VM____.MMD out\files\VM____.MMD
fc /b original\%REGPATH%\R11A__.MMD out\files\R11A__.MMD
fc /b original\%REGPATH%\DEMO11A.MMD out\files\DEMO11A.MMD
fc /b original\%REGPATH%\R11B__.MMD out\files\R11B__.MMD
fc /b original\%REGPATH%\R11C__.MMD out\files\R11C__.MMD
fc /b original\%REGPATH%\R11D__.MMD out\files\R11D__.MMD
fc /b original\%REGPATH%\R61A__.MMD out\files\R61A__.MMD
fc /b original\%REGPATH%\SPMM__.MMD out\files\SPMM__.MMD
fc /b original\%REGPATH%\SPSS__.BIN out\files\SPSS__.BIN

pause