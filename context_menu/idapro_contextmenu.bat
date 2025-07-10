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

call :extract_ida_ver "%~f1" IDAVER
REM Taking only first 3 characters from IDAVER (like 8.3, 9.0, 9.1)
set IDAVER=%IDAVER:~0,3%

if [%IDAVER:~0,1%] == [8] (
    echo Dealing with IDAPro8.X which has ida.exe 32-bit and ida64.exe 64-bit executables.
    echo The two will be added to registry now.
    echo.
    set VARBIT=1
    set IDX=033
    set "REG_BITNESS_SUFFIX=(32-bit)"
) else if [%IDAVER%] == [9.0] (
    echo Dealing with IDAPro9.0 which has no separate binaries for 32-bit and 64-bit applications.
    echo.
    set IDX=034
) else if [%IDAVER%] == [9.1] (
    echo Dealing with IDAPro9.1 which has no separate binaries for 32-bit and 64-bit applications.
    echo.
    set IDX=035
)

:again_if_varbit
REM Path to registry key
set REG_KEY=HKLM\SOFTWARE\Classes\^*\shell\%IDX%_OpenWithIDAPro%IDAVER%%REG_BITNESS_SUFFIX%
REM Path to file in filesystem
set FSP_LOC=%~dpn1%FSP_BITTNES_SUFFIX%%~x1

echo REG_KEY is %REG_KEY%
echo FSP_LOC is %FSP_LOC%

@echo on
reg delete "%REG_KEY%" /f
reg add "%REG_KEY%" /ve /d "IDA Pro %IDAVER%%REG_BITNESS_SUFFIX:(= (%"
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

