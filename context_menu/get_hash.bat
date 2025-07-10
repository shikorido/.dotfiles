@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
cd /d "%~dp0"

call :add_to_registry

echo Done!
echo.
echo Close the window or press any key to exit.
pause >NUL
exit /b 0



:add_to_registry
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\^*\shell\105_GetHash

echo REG_KEY is %REG_KEY%

@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /v Icon /d "shell32.dll,1"
reg add "%REG_KEY%" /v MUIVerb /d "Get Hash"
reg add "%REG_KEY%" /v Subcommands

reg add "%REG_KEY%\shell"
@echo off

SetLocal EnableDelayedExpansion
set count=01
@for %%x in (MD5 SHA1 SHA256 SHA384 SHA512 ALL) do (
    call :loop_call "%%x"
    set /a count+=1
    if !count! lss 10 (
        set count=0!count!
    ) else if !count! lss 100 (
        set count=!count!
    ) else (
        echo Count variable is greater or equal to 100: !count!. Why?
    )
)
EndLocal

echo.
exit /b 0



REM To make each command executed in loop echoed back the label workaround is used
:loop_call
@echo on
reg add "%REG_KEY%\shell\%count%%~1" /v Icon /d "shell32.dll,1"
reg add "%REG_KEY%\shell\%count%%~1" /v MUIVerb /d "Copy %~1"

REM reg add "%REG_KEY%\shell\%count%%~1\command" /ve /d "powershell -windowstyle hidden -command \"^(get-filehash -algorithm %~1 -literalpath '%%1'^).hash.tolower().tostring()^|set-clipboard\""

REM Using separate script to get more control like selecting multiple files
reg add "%REG_KEY%\shell\%count%%~1\command" /ve /d "powershell -windowstyle hidden -noprofile -executionpolicy bypass -file \"D:\.local\bin\Get-Hashes.ps1\" -RunType Registry -Algorithms %~1 \"%%1\""
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
