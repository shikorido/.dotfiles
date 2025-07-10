:: DOTFILES management
:: windows
:: choco_install.bat

@echo off
call :check_privileges

SetLocal EnableExtensions

set ret=0

:: Should be ran from the worktree root but just in case
set script_dir=%~dp0
set PWD=%__CD__%
:: Discard trailing backslashes
set script_dir=%script_dir:~0,-1%
set PWD=%PWD:~0,-1%

if not [%script_dir%] == [%PWD%] (
    set __PWD_OLD=%PWD%
    pushd "%script_dir%"
)

if not exist .master_root (
    echo Could not locate .master_root file in the windows worktree.
    set ret=1
    goto :end
)
for /f "delims=" %%m in ('type .master_root') do set master_root=%%m

call "%master_root%\win_utils.bat" find_program choco.exe
if not ERRORLEVEL 1 (
    echo Found installed chocolatey. No installation will be performed.
    goto :end
)

REM Original command
REM Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

REM With preloaded ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex (Get-Content 'choco\install.ps1' -Raw)"

:end
if defined __PWD_OLD (
    popd
    set __PWD_OLD=
)

if not [%ret%] == [0] (
    pause
)
exit /b %ret% & EndLocal



:check_privileges
REM echo -------------------------------------------------------------
REM echo  Administrative privileges required. Detecting privileges...
REM echo.

fsutil dirty query %SYSTEMDRIVE% >NUL

if errorlevel 1 (
    echo  Failure: Current privileges inadequate. Restarting with elevation...
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit 1
) else (
    REM echo  Success: Administrative privileges confirmed.
    REM echo -------------------------------------------------------------
    REM echo.
    exit /b 0
)

REM not working with turned off server service
REM net session >nul 2>&1

