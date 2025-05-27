:: DOTFILES management
:: master
:: win_utils.bat

@echo off


REM Skip unknown utils via explicit filtering.
if "%~1"=="find_program" shift & goto :find_program
if "%~1"=="is_valid_dir" shift & goto :is_valid_dir
if "%~1"=="mkdir_strict" shift & goto :mkdir_strict
if "%~1"=="stow" shift & goto :stow
exit /b 1


:find_program
if "%~1" == "" (
    exit /b 1
)

where "%~1" >NUL 2>&1
if ERRORLEVEL 1 (
    echo "%~1" was not found in PATH!
    exit /b 1
)
exit /b 0


:is_valid_dir
SetLocal
set "cur_dir=%__CD__%"
cd /d "%~1" >NUL 2>&1
if not ERRORLEVEL 1 cd /d "%cur_dir%" >NUL 2>&1 &EndLocal &exit /b 0
echo "%~1 is not a valid dir!"
EndLocal &exit /b 1


:mkdir_strict
SetLocal
set "arg=%~1"
for %%F in ("%arg%") do set tmp_attrs=%%~aF
if not "%tmp_attrs%"=="" (
    if "%tmp_attrs:~0,1%"=="-" (
        echo "%arg% is a file but directory was expected."
        EndLocal &exit /b 1
    ) else if "%tmp_attrs:~8,1%"=="l" (
        echo "%arg% is a directory symlink but directory was expected."
        EndLocal &exit /b 1
    )
) else mkdir "%arg%"
EndLocal &exit /b 0


:stow
REM Percent signs and carets in path lead to creation of inaccessible symlink.
REM Also there is one important behaviour that breaks symlink validation
REM which leads to constant symlink updating and, therefore, unstow cannot be performed.
REM Again, because of special characters.
REM
REM Using EnableDelayedExpansion leads to issues with ! in paths.
SetLocal EnableExtensions DisableDelayedExpansion
set stow_unstow=
set stow_root=
set stow_target=
set packages=
set sub_package_processing=
REM Arguments parsing.
:next_arg
REM Check if arg starts with -
set "arg=%~1"
if "%arg%"=="" goto :done_parse
if "%arg:~0,1%"=="-" (
    if "%arg:~0,1%"=="" goto :flag_err
    if not "%arg:~2,1%"=="" goto :flag_err
    goto :flag_ok
)
goto :add_package

:flag_err
echo "Flag must have length of 2. Given flag: %arg%"
shift
goto :stow_err

:flag_ok
set "key=%arg:~1,1%"
if "%key%"=="D" (
    REM Equivalent of -D
    set stow_unstow=1
    shift
    goto :next_arg
)
shift
if "%~1"=="" (
    echo "Missing parameter for flag %arg%"
    goto :stow_err
) else if "%key%"=="d" (
    REM Equivalent of -d
    set "stow_root=%~1"
) else if "%key%"=="t" (
    REM Equivalent of -t
    set "stow_target=%~1"
)
goto :post_flag

:add_package
REM Comma-separated list of packages to stow.
if not defined packages (
    set "packages=%~1"
) else (
    set "packages=%packages%,%~1"
)

:post_flag
shift
goto :next_arg

:done_parse
REM Check if no packages were provided.
if "%packages%"=="" (
    echo Provide at least one package to stow.
    goto :stow_err
)

REM Fill necessary variables not provided in arguments.
if not defined stow_root (
    REM Set stow root to the current working directory.
    REM Remove leading backslash.
    set "stow_root=%__CD__:~0,-1%"
)
if not defined stow_target (
    REM Set stow target to the parent of current working directory.
    for /f "tokens=*" %%D in ("..") do (
        set "stow_target=%%~fD"
    )
)
REM echo Parsed stow arguments are:
REM echo "stow_root: %stow_root%"
REM echo "stow_target: %stow_target%"
REM echo "packages: %packages%"

:next_package
if not defined packages goto :stow_done

for /f "delims=," %%P in ("%packages%") do set "package=%%~P"

REM In case of directory stows when target is a directory
REM we will reuse this piece of code via CALL.
REM Must be called via SetLocal to make use of modified package variable
REM but only one to avoid SetLocal exhaustion.
:next_sub_package

if not defined stow_unstow (
    echo "Stowing %package%..."
) else (
    echo "Unstowing %package%..."
)
set "package_fp=%stow_root%\%package%"

REM Using separate logic for directory and file stows.
for /f "delims=" %%F in ('dir /b /a:-l "%package_fp%"') do (
    call :process_package "%%~nxF"
)

if defined sub_package_processing (
    exit /b %ERRORLEVEL%
)

:shift_package
if defined sub_package_processing (
    set sub_package_processing=
    EndLocal
)
REM Remove stowed package from packages list.
if "%packages%"=="%package%" (
    set packages=
    goto :stow_done
) else (
    REM Two-side boundaries for safety.
    set "packages=,%packages%"
    REM For call trick we do not need delayed expansion.
    REM What will happen with parentheses?
    REM Unexpected thing will happen more likely in some cases...
    call set "packages=%%packages:,%package%,=%%"
    goto :next_package
)

:stow_done
EndLocal &exit /b 0
:stow_err
EndLocal &exit /b 1

:process_package
REM echo "package is %package%"
set "source_fp=%package_fp%\%~1"
set "target_fp=%stow_target%\%~1"
for %%T in ("%source_fp%") do set "source_attribs=%%~aT"
for %%T in ("%target_fp%") do set "target_attribs=%%~aT"

if "%source_attribs:~0,1%"=="-" (
    REM Is a file?
    call :stow_file
) else (
    REM Is a directory?
    call :stow_directory
)
exit /b %ERRORLEVEL%

:stow_file
if "%target_attribs%"=="" (
    REM Does not exist?
    if not defined stow_unstow (
        mklink "%target_fp%" "%source_fp%"
    )
) else (
    REM Credits to https://ss64.com/nt/syntax-args.html
    REM Attribute                    Expansion
    REM FILE_ATTRIBUTE_DIRECTORY     d--------
    REM FILE_ATTRIBUTE_READONLY      -r-------
    REM FILE_ATTRIBUTE_ARCHIVE       --a------
    REM FILE_ATTRIBUTE_HIDDEN        ---h-----
    REM FILE_ATTRIBUTE_SYSTEM        ----s----
    REM FILE_ATTRIBUTE_COMPRESSED    -----c---
    REM FILE_ATTRIBUTE_OFFLINE       ------o--
    REM FILE_ATTRIBUTE_TEMPORARY     -------t-
    REM FILE_ATTRIBUTE_REPARSE_POINT --------l
    REM FILE_ATTRIBUTE_NORMAL        ---------
    REM Other NTFS attributes not recognised by ~a can be read using FSUTIL usn command:
    REM FILE_ATTRIBUTE_ENCRYPTED
    REM FILE_ATTRIBUTE_NOT_CONTENT_INDEXED
    REM FILE_ATTRIBUTE_SPARSE_FILE

    if "%target_attribs:~8,1%"=="-" (
        if "%target_attribs:~0,1%"=="-" (
            REM File and not symlink?
            if not defined stow_unstow (
                echo "Could not stow file %source_fp% cause %target_fp% is a file."
            ) else (
                echo "Could not unstow file %source_fp% cause %target_fp% is a file."
            )
            exit /b 1
        ) else (
            REM Directory and not symlink?
            if not defined stow_unstow (
                echo "Could not stow file %source_fp% cause %target_fp% is a directory."
            ) else (
                echo "Could not unstow file %source_fp% cause %target_fp% is a directory."
            )
            exit /b 1
        )
    ) else if "%target_attribs:~0,1%"=="d" (
        REM Directory symlink?
        if not defined stow_unstow (
            echo "Could not stow file %source_fp% cause %target_fp% is a directory symlink."
        ) else (
            echo "Could not unstow file %source_fp% cause %target_fp% is a directory symlink."
        )
        exit /b 1
    ) else (
        REM Now we know that the target is symlink and not a directory.
        REM Validating symlink...
        for /f "tokens=2 delims=[]" %%S in ('dir /a:l "%target_fp%" ^| findstr /c:"<SYMLINK>"') do (
            REM for /f "tokens=2,4 delims=<>[]" %%R in ('dir /a:l "%target_fp%" ^| findstr /c:"<SYMLINK>"') do (
            REM echo "%target_fp% has type of %%~R and points to %%~S"

            REM For simplicity we will use ABSOLUTE symlink paths for easier matches against stow sources.
            if "%%~S"=="%source_fp%" (
                if not defined stow_unstow (
                    echo "Skipping redundant stow for %source_fp%"
                ) else (
                    del /a:-dl "%target_fp%"
                )
            ) else (
                if not defined stow_unstow (
                    echo "Updating file symlink %target_fp% to point at %source_fp%"
                    del /a:-dl "%target_fp%"
                    mklink "%target_fp%" "%source_fp%"
                )
            )
        )
    )
)
exit /b 0

:traverse_directories
REM Recursive traversion into subdirectories if current target is a directory.

REM We can touch the essential variables cause we should be under SetLocal here.
set "package_fp=%source_fp%"
set "stow_target=%target_fp%"

REM echo "package_fp is %package_fp%"
REM echo "stow_target is %stow_target%"

REM Using separate logic for directory and file stows.
for /f "delims=" %%F in ('dir /b /a:-l "%package_fp%"') do (
    REM This one is mainly for directory symlink validation due to DIR quirks.
    set "package=%%~nxF"
    call :process_package "%%~nxF"
)
exit /b %ERRORLEVEL%

:stow_directory
if "%target_attribs%"=="" (
    REM Does not exist?
    if not defined stow_unstow (
        mklink /d "%target_fp%" "%source_fp%"
    )
) else (
    if "%target_attribs:~0,1%"=="-" (
        if "%target_attribs:~8,1%"=="l" (
            REM File symlink?
            if not defined stow_unstow (
                echo "Could not stow directory %source_fp% cause %target_fp% is a file symlink."
            ) else (
                echo "Could not unstow directory %source_fp% cause %target_fp% is a file symlink."
            )
            exit /b 1
        ) else (
            REM File?
            if not defined stow_unstow (
                echo "Could not stow directory %source_fp% cause %target_fp% is a file."
            ) else (
                echo "Could not unstow directory %source_fp% cause %target_fp% is a file."
            )
            exit /b 1
        )
    ) else if "%target_attribs:~8,1%"=="-" (
        REM Directory?
        REM Requires recursive processing.
        if not defined stow_unstow (
            echo "Recursively stowing %source_fp%"
        ) else (
            echo "Recursively unstowing %source_fp%"
        )
        if not defined sub_package_processing (
            REM Using EnableDelayedExpansion leads to issues with ! in paths.
            SetLocal EnableExtensions DisableDelayedExpansion
            set sub_package_processing=1
        )
        call :traverse_directories
        REM Undefining sub_package_processing here will be a mistake
        REM cause the same code path can be executed in traversion process.
        REM It must be done in shift_package.
        exit /b %ERRORLEVEL%
    ) else (
        REM Now we know that the target is a directory symlink.
        REM Validating symlink...
        for /f "tokens=2 delims=[]" %%S in ('dir /a:dl "%stow_target%" ^| findstr /c:"%package%"') do (
            REM for /f "tokens=2,4 delims=<>[]" %%R in ('dir /a:dl "%stow_target%" ^| findstr /c:"%package%"') do (
            REM echo "%target_fp% has type of %%~R and points to %%~S"

            REM For simplicity we will use ABSOLUTE symlink paths for easier matches against stow sources.
            if "%%~S"=="%source_fp%" (
                if not defined stow_unstow (
                    echo "Skipping redundant stow for %source_fp%"
                ) else (
                    rmdir "%target_fp%"
                )
            ) else (
                if not defined stow_unstow (
                    echo "Updating directory symlink %target_fp% to point at %source_fp%"
                    rmdir "%target_fp%"
                    mklink /d "%target_fp%" "%source_fp%"
                )
            )
        )
    )
)
exit /b 0

