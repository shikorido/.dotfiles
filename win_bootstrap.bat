:: DOTFILES management
:: master
:: win_bootstrap.bat

@echo off

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

REM Windows has no rich variations.
REM Windows is a windows. Just get git and you are good.

call win_utils.bat find_program git.exe
if ERRORLEVEL 1 goto :end

for /f "delims=" %%w in ('git worktree list ^| findstr /c:[windows]') do (
    echo windows worktree has been found in worktrees list!
    goto :end
)

git worktree add windows windows
echo %script_dir% >windows\.master_root

:end
if defined __PWD_OLD (
    popd
    set __PWD_OLD=
)

if not [%ret%] == [0] (
    pause
)
exit /b %ret% & EndLocal

