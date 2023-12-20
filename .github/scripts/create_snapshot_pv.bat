:: 2023-08-06 09:00

rem test if PROG_VER already set
if .%PROG_VER%==. goto Set_PROG_VER
goto DoContinue

:Set_PROG_VER
rem Set sudo version
set PROG_VER=1.1.1

:DoContinue
rem The new package will be created from here
set BUILD_PACK_DIR=%TEMP%\sudo-release

rem The new package will be saved here
set PACK_DIR=%CD%\sudo-release

rem Prepare target dir
mkdir %PACK_DIR%

rem Get revision number
call .github/scripts/git2revisioninc.exe.cmd %CD%
echo %REVISION%> %PACK_DIR%\revision.txt

rem Read version number
for /f tokens^=2delims^=^" %%a in ('findstr "VERSION_MAJOR" Sudo/Build.pp') do (set PROG_MAJOR=%%a)
for /f tokens^=2delims^=^" %%a in ('findstr "VERSION_MINOR" Sudo/Build.pp') do (set PROG_MINOR=%%a)
for /f tokens^=2delims^=^" %%a in ('findstr "VERSION_REVISION" Sudo/Build.pp') do (set PROG_MICRO=%%a)
if [%PROG_MINOR%] == [] set PROG_MINOR=0
if [%PROG_MICRO%] == [] set PROG_MICRO=0
set PROG_VER=%PROG_MAJOR%.%PROG_MINOR%.%PROG_MICRO%

rem Change log
git log -n 10 --format="%%h %%al %%ai%%n%%s%%n" > %PACK_DIR%\changelog.txt

rem Set processor architecture
set CPU_TARGET=i386
set OS_TARGET=win32

rem call :DoBuild

rem Set processor architecture
set CPU_TARGET=x86_64
set OS_TARGET=win64

call :DoBuild

GOTO:EOF

:DoBuild
  rem Build all components of sudo
  call build.bat sudo

  rem Prepare install dir
  mkdir %BUILD_PACK_DIR%

  rem Prepare install files
  call .github/scripts/install.bat

  rem Create *.7z archive
  echo "%ProgramFiles%\7-Zip\7z.exe" a -mx9 %PACK_DIR%\sudo-%PROG_VER%.r%REVISION%.%CPU_TARGET%-%OS_TARGET%.7z %PROG_INSTALL_DIR%\*
  "%ProgramFiles%\7-Zip\7z.exe" a -mx9 %PACK_DIR%\sudo-%PROG_VER%.r%REVISION%.%CPU_TARGET%-%OS_TARGET%.7z %PROG_INSTALL_DIR%\*
  
  rem Clean
  del /Q *.dll
  del /Q *.exe
  call clean.bat
  rm -rf %BUILD_PACK_DIR%

  rem set env.REVISION
  ::echo %REVISION% >> $env:GITHUB_ENV
  set
  echo PROG_VER=%PROG_VER%>> %GITHUB_ENV%
  echo PROG_REVISION=%REVISION%>> %GITHUB_ENV%
  echo "Print GITHUB_ENV"
  echo %GITHUB_ENV%
   
GOTO:EOF
