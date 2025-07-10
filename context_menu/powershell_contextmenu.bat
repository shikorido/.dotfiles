@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
REM cd /d "%~dp0"

REM For adding windows' stock powershell change current dir to System32
REM cd /d "%SYSTEMROOT%\System32\windowspowershell\v1.0"

REM @for /f %%f in ('dir /b /a:-d-l') do (
REM     @if [%%~nxf] == [powershell.exe] (
REM         echo powershell.exe was found in the current script directory.
REM         echo.
REM         echo Adding it to the context menu for any file.
REM         echo.
REM         call :add_to_registry "%%~ff"
REM     )
REM )

for /f "delims=" %%F in ('where powershell.exe') do (
    set ps_loc=%%F
    goto :got_ps
)

:got_ps
if not [%ps_loc%] == [] (
    call :add_to_registry "%ps_loc%"
)

echo Done!
echo.
echo Close the window or press any key to exit.
pause >NUL
exit /b 0



:add_to_registry
REM DIRECTORY BACKGROUND
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\Directory\background\shell\026_OpenInPowershell
REM Path to file in filesystem
set FSP_LOC=%~1
echo REG_KEY is %REG_KEY%
echo FSP_LOC is %FSP_LOC%
@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%" /v MUIVerb /d "PowerShell"
reg add "%REG_KEY%" /v Subcommands

reg add "%REG_KEY%\shell"
@echo off

SetLocal EnableDelayedExpansion
set count=01
@for %%x in (User Admin) do (
    call :loop_call_bg "%%x"
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

REM DIRECTORY CONTEXT
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\Directory\shell\026_OpenInPowershell
REM Path to file in filesystem
set FSP_LOC=%~1
echo REG_KEY is %REG_KEY%
echo FSP_LOC is %FSP_LOC%
@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%" /v MUIVerb /d "PowerShell"
reg add "%REG_KEY%" /v Subcommands

reg add "%REG_KEY%\shell"
@echo off

SetLocal EnableDelayedExpansion
set count=01
@for %%x in (User Admin) do (
    call :loop_call_ctx "%%x"
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
:loop_call_bg
@echo on
reg add "%REG_KEY%\shell\%count%%~1" /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%\shell\%count%%~1" /v MUIVerb /d "%~1"
reg add "%REG_KEY%\shell\%count%%~1" /v Extended
reg add "%REG_KEY%\shell\%count%%~1" /v NoWorkingDirectory

if [%~1] == [User] (
    reg add "%REG_KEY%\shell\%count%%~1\command" /ve /d "\"%FSP_LOC%\" -noexit -command Set-Location -literalPath \"\\\"%%V\\\"\""
) else (
    reg add "%REG_KEY%\shell\%count%%~1\command" /ve /d "powershell -Command Start-Process \"\\\"%FSP_LOC%\\\"\" -ArgumentList '-noexit','-command','Set-Location','-literalPath',\"\\\"\`\\\"%%V\`\\\"\\\"\" -Verb RunAs"
)
@echo off
exit /b 0

REM To make each command executed in loop echoed back the label workaround is used
:loop_call_ctx
@echo on
reg add "%REG_KEY%\shell\%count%%~1" /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%\shell\%count%%~1" /v MUIVerb /d "%~1"
reg add "%REG_KEY%\shell\%count%%~1" /v Extended
reg add "%REG_KEY%\shell\%count%%~1" /v NoWorkingDirectory

if [%~1] == [User] (
    reg add "%REG_KEY%\shell\%count%%~1\command" /ve /d "\"%FSP_LOC%\" -noexit -command Set-Location -literalPath \"\\\"%%1\\\"\""
) else (
    reg add "%REG_KEY%\shell\%count%%~1\command" /ve /d "powershell -Command Start-Process \"\\\"%FSP_LOC%\\\"\" -ArgumentList '-noexit','-command','Set-Location','-literalPath',\"\\\"\`\\\"%%1\`\\\"\\\"\" -Verb RunAs"
)
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



