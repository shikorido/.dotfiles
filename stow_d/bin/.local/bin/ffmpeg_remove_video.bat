@echo off
SetLocal EnableDelayedExpansion

where ffmpeg.exe >NUL 2>&1
if ERRORLEVEL 1 (
    echo Could not find ffmpeg.exe in PATH.
    pause
    EndLocal &exit /b 1
)

set workDir=%~dp1
set inputNameExt=%~nx1
set prefix=2
set pad=000
set novid=NOVIDEO_
if not exist "%workDir%%novid%%inputNameExt%" (
    echo Not exists: "%workDir%%novid%%inputNameExt%"
    set prefix=
    goto :done
)
echo Exists: "%workDir%%novid%%inputNameExt%"
:exists
if exist "%workDir%%pad%%prefix%_%novid%%inputNameExt%" (
    echo Exists: "%workDir%%pad%%prefix%_%novid%%inputNameExt%"
    set /a prefix+=1
    if !prefix! lss 10 (
        set pad=000
    ) else if !prefix! lss 100 (
        set pad=00
    ) else if !prefix! lss 1000 (
        set pad=0
    ) else (
        set pad=
    )
    goto :exists
)
if %prefix% geq 10000 (
    echo *** Why the prefix %prefix% is absurdly large? ***
)
set prefix=%pad%%prefix%_
:done
REM echo Prefix: %prefix%
REM echo Output file: "%~dp1%prefix%%novid%%inputNameExt%"
REM pause

REM https://ffmpeg.org/ffmpeg.html#toc-Stream-specifiers-1
REM ffmpeg -i "%~1" -map 0:a -map 0:v:1? -map 0:s? -map 0:t? -map_metadata 0 -c copy "%~dp1%prefix%%novid%%inputNameExt%" -n
ffmpeg -i "%~1" -map 0 -map -0:v? -map 0:disp:attached_pic? -c copy "%~dp1%prefix%%novid%%inputNameExt%" -n
if ERRORLEVEL 1 (
    echo An error occured. Make your investigation.
    pause
    EndLocal &exit /b 1
)
EndLocal &exit /b 0

