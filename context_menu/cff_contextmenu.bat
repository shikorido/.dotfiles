@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
cd /d "%~dp0"

@for /f %%f in ('dir /b /a:-d-l') do (
    @if [%%~nxf] == [CFFExplorer.exe] (
        echo CFF Explorer.exe was found in the current script directory.
        echo.
        echo Adding it to the context menu for dll, exe, sys and other specific files.
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
REM Path to file in filesystem
set FSP_LOC=%~1

REM CFFExplorer.Script is a specific to CFF ProgID key and it defines shell\open
REM so it must be handled separately
set REG_KEY=HKLM\SOFTWARE\Classes\CFFExplorer.Script\shell\open

echo FSP_LOC is %FSP_LOC%
echo REG_KEY is %REG_KEY%

@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%\command" /ve /d "\"%FSP_LOC%\" %%1"
@echo off

@for %%x in (cplfile dllfile exefile ocxfile sysfile) do (
    REM Path to registry key
    REM set REG_KEY=HKLM\SOFTWARE\Classes\%%x\shell\025_OpenWithCFFExplorer
    REM Avoiding EnableDelayedExpansion by passing REG_KEY directly
    REM
    REM UPD. cplfile should not have highest priority for CFFExplorer
    REM Instead cplopen (Open with Control Panel) should be first
    REM So we will add index for everything except cplfile
    
    if not [%%x] == [cplfile] (
        call :loop_call "HKLM\SOFTWARE\Classes\%%x\shell\025_OpenWithCFFExplorer" "%%x"
    ) else (
        call :loop_call "HKLM\SOFTWARE\Classes\%%x\shell\OpenWithCFFExplorer" "%%x"
    )
)

echo.
exit /b 0



REM To make each command executed in loop echoed back the label workaround is used
:loop_call
set REG_KEY_STOCK=HKLM\SOFTWARE\Classes\%~2\shell\Open with CFF Explorer
echo.
echo REG_KEY is %~1
@echo on
reg delete "%REG_KEY_STOCK%" /f
reg delete "%~1" /f
reg add "%~1" /ve /d "CFF Explorer"
reg add "%~1" /v Icon /d "%FSP_LOC%"
reg add "%~1\command" /ve /d "\"%FSP_LOC%\" %%1"
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

