@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
cd /d "%~dp0"

@for /f %%f in ('dir /b /a:-d-l') do (
    @if [%%~nxf] == [die.exe] (
        echo die.exe was found in the current script directory.
        echo.
        echo Adding it to the context menu for dll, exe and sys files.
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

echo FSP_LOC is %FSP_LOC%

@for %%x in (dllfile exefile sysfile) do (
    REM Path to registry key
    REM set REG_KEY=HKLM\SOFTWARE\Classes\%%x\shell\045_OpenWithDiE
    REM Avoiding EnableDelayedExpansion by passing REG_KEY directly
    call :loop_call "HKLM\SOFTWARE\Classes\%%x\shell\045_OpenWithDiE"
)

echo.
exit /b 0



REM To make each command executed in loop echoed back the label workaround is used
:loop_call
echo.
echo REG_KEY is %~1
@echo on
reg delete "%~1" /f
reg add "%~1" /ve /d "Detect It Easy"
reg add "%~1" /v Icon /d "%FSP_LOC%"
reg add "%~1\command" /ve /d "\"%FSP_LOC%\" \"%%1\""
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

