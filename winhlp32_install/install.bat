@echo off

:: ---------------------------------------------------------------------------
:: Settings

set MuiFileName=winhlp32.exe.mui
set ExeFileName=winhlp32.exe
set MuiFileNameBak=winhlp32.exe.mui_bak
set ExeFileNameBak=winhlp32.exe_bak
set WindowsVersion=7
:: To perform hash checks the line was transfered after hashes computation
::goto :BypassVersionError

:: ---------------------------------------------------------------------------
:: Displaying installer information

echo ----------------------------------------------------------
echo  Windows Help program (WinHlp32) installer for Windows 10
echo ----------------------------------------------------------
echo.

:: ---------------------------------------------------------------------------
:: Check hashes of existing mui and exe files to avoid redundant actions

pushd "%~dp0"
echo Computing SHA256 hashes of existing system files to compare with installable ones
echo.

for /f "tokens=*" %%A in ('certutil -hashfile "%SystemRoot%\en-US\%MuiFileName%" SHA256 ^| find /i /v "SHA256" ^| find /i /v "certutil"') do set "muiSysHash=%%A"
echo Computed SHA256 hash of %SystemRoot%\en-US\%MuiFileName% is %muiSysHash%
echo.

for /f "tokens=*" %%A in ('certutil -hashfile "%CD%\%MuiFileName%" SHA256 ^| find /i /v "SHA256" ^| find /i /v "certutil"') do set "muiNewHash=%%A"
echo Computed SHA256 hash of %CD%\%MuiFileName% is %muiNewHash%
echo.

for /f "tokens=*" %%A in ('certutil -hashfile "%SystemRoot%\%ExeFileName%" SHA256 ^| find /i /v "SHA256" ^| find /i /v "certutil"') do set "exeSysHash=%%A"
echo Computed SHA256 hash of %SystemRoot%\%ExeFileName% is %exeSysHash%
echo.

for /f "tokens=*" %%A in ('certutil -hashfile "%CD%\%ExeFileName%" SHA256 ^| find /i /v "SHA256" ^| find /i /v "certutil"') do set "exeNewHash=%%A"
echo Computed SHA256 hash of %CD%\%ExeFileName% is %exeNewHash%
popd

goto :BypassVersionError

:: ---------------------------------------------------------------------------
:: Windows version detection

echo Setup is detecting Windows version...
ver | findstr /il "6\.1\." > nul
if %errorlevel% equ 0 (
  echo Microsoft Windows 7 [Version 6.1] detected.
  set WindowsVersion=7
  goto :BypassVersionError
)

ver | findstr /il "6\.0\." > nul
if %errorlevel% equ 0 (
  echo Microsoft Windows Vista / Server 2008 [Version 6.0] detected.
  set WindowsVersion=6
  goto :BypassVersionError
)

ver | findstr /il "5\.2\." > nul
if %errorlevel% equ 0 (
  echo Microsoft Windows Server 2003 [Version 5.2] detected.
  set WindowsVersion=5
  goto :BypassVersionError
)

ver | findstr /il "5\.1\." > nul
if %errorlevel% equ 0 (
  echo Microsoft Windows XP [Version 5.1] detected.
  set WindowsVersion=5
  goto :BypassVersionError
)

ver | findstr /il "5\.0" > nul
if %errorlevel% equ 0 (
  echo Microsoft Windows 2000 [Version 5.0] detected.
  set WindowsVersion=5
  goto :BypassVersionError
)

echo Inappropriate Windows version. Setup must be run under one of the following
echo operating systems:
echo.
echo * Microsoft Windows 7
echo * Microsoft Windows Server 2008
echo * Microsoft Windows Vista
echo * Microsoft Windows Server 2003
echo * Microsoft Windows XP
echo * Microsoft Windows Server 2000
echo.
pause
goto :eof

:: Mandatory for older Windows versions incapable of understanding EOF,
:: eventhough they don't take CMD files as BAT.
exit

:: ---------------------------------------------------------------------------
:: Initialization

:BypassVersionError
if not [%WindowsVersion%] == [7] (
  echo Inappropriate Windows version. Setup must be run under one of the following
  echo operating systems:
  echo.
  echo * Microsoft Windows 7
  echo.
  pause
  goto :eof
)

:: Preserve current directory for further referrings.
set InitialDirectory=%CD%
:: Change drive and path to where the batch file was started from. This is
:: required when your batch file is run-as-administrator, because it sets
:: System32 the working (current) directory.
::cd /d "%0\.."
cd /d "%~dp0"

:: ---------------------------------------------------------------------------
:: Windows 7 installation
:InstallFor7
echo.
echo Terminating all possible running instances of WinHlp32...
taskkill /f /im %ExeFileName% /t
:: No error checking is required, because if it's not opened so far, an error will occur.
echo.

if not [%muiSysHash%] == [%muiNewHash%] (
	echo Taking the ownership of system's existing %MuiFileName%...
	takeown /f "%SystemRoot%\en-US\%MuiFileName%"
	echo.
	echo Granting %UserName% full-access permission to system's existing %MuiFileName%...
	icacls "%SystemRoot%\en-US\%MuiFileName%" /grant "%UserName%":F
	echo.

	echo Backuping system's existing %MuiFileName% by renaming it to %MuiFileNameBak%...
	ren "%SystemRoot%\en-US\%MuiFileName%" %MuiFileNameBak%
	echo.

	echo CHECK IF BACKUP WAS SUCCESSFULL
	if errorlevel 1 goto :Error
	pause
	echo.

	echo Denying %UserName% full-access permission of system's backuped %MuiFileNameBak% to avoid overwriting...
	icacls "%SystemRoot%\en-US\%MuiFileNameBak%" /deny "%UserName%":F
	echo.

	echo Copying %MuiFileName% to system...
	xcopy /r /y /h /q %MuiFileName% "%SystemRoot%\en-US"
	echo.

	if errorlevel 1 goto :Error
	pause
) else (
	echo %SystemRoot%\en-US\%MuiFileName% was already installed.
)

if not [%exeSysHash%] == [%exeNewHash%] (
	echo Taking the ownership of system's existing %ExeFileName%...
	takeown /f "%SystemRoot%\%ExeFileName%"
	echo.

	echo Granting %UserName% full-access permission to system's existing %ExeFileName%...
	icacls "%SystemRoot%\%ExeFileName%" /grant "%UserName%":F
	echo.

	echo Backuping system's existing %ExeFileName% by renaming it to %ExeFileNameBak%...
	ren "%SystemRoot%\%ExeFileName%" %ExeFileNameBak%
	echo.

	echo CHECK IF BACKUP WAS SUCCESSFULL
	if errorlevel 1 goto :Error
	pause
	echo.

	echo Denying %UserName% full-access permission of system's backuped %ExeFileNameBak% to avoid overwriting...
	icacls "%SystemRoot%\%ExeFileNameBak%" /deny "%UserName%":F
	echo.

	echo Copying %ExeFileName% to system...
	xcopy /r /y /h /q %ExeFileName% "%SystemRoot%"
	echo.

	if errorlevel 1 goto :Error
	pause
) else (
	echo %SystemRoot%\%ExeFileName% was already installed.
)

echo.
echo Updating Registry entries...
@echo on
reg add "HKLM\SOFTWARE\Microsoft\WinHelp" /v "AllowProgrammaticMacros" /t REG_DWORD /d "0x00000001" /f
reg add "HKLM\SOFTWARE\Microsoft\WinHelp" /v "AllowIntranetAccess" /t REG_DWORD /d "0x00000001" /f
if %PROCESSOR_ARCHITECTURE%==AMD64 (
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\WinHelp" /v "AllowProgrammaticMacros" /t REG_DWORD /d "0x00000001" /f
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\WinHelp" /v "AllowIntranetAccess" /t REG_DWORD /d "0x00000001" /f
)
@echo off
echo.

if errorlevel 1 goto :Error
pause
goto :eof

:: ---------------------------------------------------------------------------
:: Error management
:Error
echo Error installing WinHlp32
echo.
echo Setup will now exit.
echo.
pause
goto :eof
