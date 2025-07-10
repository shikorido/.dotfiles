@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
cd /d "%~dp0"

@for /f %%f in ('dir /b /a:-d-l') do (
    @if [%%~nxf] == [notepad++.exe] (
        echo notepad++.exe was found in the current script directory.
        echo.
        echo Adding it to the context menu for any file.
        echo.
        call :add_to_registry "%%~ff"
    )
)

echo Done!
echo.
echo Close the window or press any key to exit.
pause >NUL
exit /b 0



:add_to_registry
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\^*\shell\015_EditWithNotepad++
REM Path to file in filesystem
set FSP_LOC=%~1
echo REG_KEY is %REG_KEY%
echo FSP_LOC is %FSP_LOC%
@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /ve /d "Notepad++"
reg add "%REG_KEY%" /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%\command" /ve /d "\"%FSP_LOC%\" \"%%1\""
@echo off
echo.
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

