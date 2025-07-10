:: DOTFILES management
:: windows
:: uninstall.bat

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


echo Unstowing config files...
for /f "delims=" %%P in ('dir /b /a:d "%script_dir%\stow_userprofile"') do (
    REM Due to some unique cases when file name has special characters
    REM one package at time will be stowed.
    REM Otherwise we must use DelayedExpansion for collecting packages
    REM in a space-separated (or whatever else separated) list but it will break ! paths.
    call "%master_root%\win_utils.bat" stow -D -d "%script_dir%\stow_userprofile" -t "%USERPROFILE%" "%%~P"
)

for /f "delims=" %%P in ('dir /b /a:d "%script_dir%\stow_d"') do (
    REM Using D:\ will cause D:\\ in path after concatenation.
    REM But specifying D:\ is a standard and more reliable.
    REM TODO Fix the <DRIVE>:\ concatenation issues.
    call "%master_root%\win_utils.bat" stow -D -d "%script_dir%\stow_d" -t "D:" "%%~P"
)



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

