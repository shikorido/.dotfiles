:: DOTFILES management
:: master
:: setup_gitconfig.bat

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

call "%master_root%\win_utils.bat" find_program git.exe
if ERRORLEVEL 1 goto :end

REM Main config
set main_config=%USERPROFILE%\.gitconfig
REM Symlinked config
set local_config=%USERPROFILE%\.gitconfig.local

echo System's git config will be untouched, instead the global i.e. user config will shadow the system one.
git config --global user.name >NUL 2>&1
if not ERRORLEVEL 1 goto :name_defined
:ask_name
set /p "GIT_USERNAME=Enter your Git user.name: "
if "%GIT_USERNAME%" == "" (
    echo Please enter a non-empty name.
    goto :ask_name
)
git config --global user.name "%GIT_USERNAME%"

:name_defined
git config --global user.email >NUL 2>&1
if not ERRORLEVEL 1 goto :email_defined
:ask_email
set /p "GIT_EMAIL=Enter your Git user.email: "
if "%GIT_EMAIL%" == "" (
    echo Please enter a non-empty email.
    goto :ask_email
)
git config --global user.email "%GIT_EMAIL%"

:email_defined
type "%main_config%" | findstr /c:"path = \"%local_config:\=/%\"" >NUL 2>&1
if not ERRORLEVEL 1 goto :local_included
(
    echo.
    echo [include]
    echo 	path = "%local_config:\=/%"
    echo.
) >>"%main_config%"
echo Added include for %local_config% to %main_config%

:local_included

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

