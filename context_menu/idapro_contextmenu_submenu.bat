@echo off

call :check_privileges

REM Change current dir to the script's one in case of elevated run
cd /d "%~dp0"

@for /f %%f in ('dir /b /a:-d-l') do (
    @if [%%~nxf] == [ida.exe] (
        echo ida.exe was found in the current script directory.
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
REM Adding submenu first
set IDX=035
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\^*\shell\%IDX%_OpenWithIDAPro
set FSP_LOC=%~1

echo REG_KEY is %REG_KEY%
echo FSP_LOC is %FSP_LOC%

REM reg delete "%REG_KEY%" /f
@echo on
reg delete "%REG_KEY%" /f /ve
reg add "%REG_KEY%" /f /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%" /f /v MUIVerb /d "IDA Pro"
reg add "%REG_KEY%" /f /v Subcommands

reg add "%REG_KEY%\shell" /f
@echo off


REM Now submenu
call :extract_ida_ver "%~f1" IDAVER
REM Taking only first 3 characters from IDAVER (like 7.7, 8.3, 9.0, 9.1)
set IDAVER=%IDAVER:~0,3%

REM I think IDA versions from 3.x to 8.x have separate executables for 32-bit and 64-bit executables (ida.exe and ida64.exe).
REM But I will check if ida64.exe exists just in case. This way the logic can be generalized.
REM Though I consider IDA Pro versions only cause VersionInfo resource does not contain exact information about edition.
for %%T in (ida64.exe) do set ida64_attribs=%%~aT

if [%ida64_attribs%] == [] (
    echo Dealing with IDAPro%IDAVER% which has no separate binaries for 32-bit and 64-bit applications.
    echo.
    set VARBIT=
    set REG_BITNESS_SUFFIX=
) else (
    echo Dealing with IDAPro%IDAVER% which has ida.exe 32-bit and ida64.exe 64-bit executables.
    echo The two will be added to registry now.
    echo.
    set VARBIT=1
    set "REG_BITNESS_SUFFIX=(32-bit)"
)

:again_if_varbit
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\^*\shell\%IDX%_OpenWithIDAPro\shell\IDAPro%IDAVER%%REG_BITNESS_SUFFIX%
REM Path to file in filesystem
set FSP_LOC=%~dpn1%FSP_BITTNES_SUFFIX%%~x1

echo REG_KEY is %REG_KEY%
echo FSP_LOC is %FSP_LOC%

@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /ve /d "IDA Pro %IDAVER% %REG_BITNESS_SUFFIX%"
reg add "%REG_KEY%" /v Icon /d "%FSP_LOC%"
reg add "%REG_KEY%\command" /ve /d "\"%FSP_LOC%\" \"%%1\""
@echo off
if [%VARBIT%] == [1] (
    set VARBIT=
    set "REG_BITNESS_SUFFIX=(64-bit)"
    set FSP_BITTNES_SUFFIX=64
    echo.
    goto :again_if_varbit
)
echo.
exit /b 0



:extract_ida_ver
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "(Get-Item '%~f1').VersionInfo.ProductVersion"`) do set "%~2=%%V"
if [%IDAVER%] == [] (
    echo Could not extract IDA version from executable file! Exitting...
    pause
    exit 1
)
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

