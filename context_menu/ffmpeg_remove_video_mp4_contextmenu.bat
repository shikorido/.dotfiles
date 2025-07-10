@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
cd /d "%~dp0"

for /f "delims=" %%F in ('where ffmpeg_remove_video.bat') do (
    set "FSP_LOC=%%~F"
    goto :bat_found
)
:bat_found

if not defined FSP_LOC (
    echo Could not find ffmpeg_remove_video.bat in PATH.
    pause
    exit /b 1
)

call :add_to_registry

echo Done!
echo.
echo Close the window or press any key to exit.
pause >NUL
exit /b 0



:add_to_registry
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\SystemFileAssociations\.mp4\shell\055_RemoveVideo

echo "REG_KEY is %REG_KEY%"
echo "FSP_LOC is %FSP_LOC%"

@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /ve /d "Remove Video" 
reg add "%REG_KEY%" /v Icon /d "imageres.dll,-68"

reg add "%REG_KEY%\command" /ve /d "\"%FSP_LOC%\" \"%%1\""
@echo off
exit /b 0



:check_privileges
echo -------------------------------------------------------------
echo  Administrative privileges required. Detecting privileges...
echo.

fsutil dirty query %SYSTEMDRIVE% >NUL

if errorlevel 1 (
    echo  Failure: Current privileges inadequate. Restarting with elevation...
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit 1
) else (
    echo  Success: Administrative privileges confirmed.
    echo -------------------------------------------------------------
    echo.
    exit /b 0
)

REM not working with turned off server service
REM net session >nul 2>&1
