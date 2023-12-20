@echo off

rem Add Lazarus installation to path
if [%LAZARUS_HOME%] == [] set LAZARUS_HOME=D:\Alexx\Prog\FreePascal\Lazarus
set PATH=%LAZARUS_HOME%;%PATH%

rem You can execute this script with different parameters:
rem components - compiling components needed for sudo
rem sudo - compiling sudo only (release mode)
rem plugins - compiling all sudo plugins
rem debug - compiling components, plugins and sudo (debug mode)
rem release - compile in release mode (using by default)
if not "%OS_TARGET%" == "" (
  set DC_ARCH=%DC_ARCH% --os=%OS_TARGET%
)
if not "%CPU_TARGET%" == "" (
  set DC_ARCH=%DC_ARCH% --cpu=%CPU_TARGET%
)
if not "%LCL_PLATFORM%" == "" (
  set DC_ARCH=%DC_ARCH% --ws=%LCL_PLATFORM%
)

if "%1"=="components" ( call :components
) else (
if "%1"=="plugins" ( call :plugins
) else (
if "%1"=="beta" ( call :release
) else (
if "%1"=="sudo" ( call :sudo
) else (
if "%1"=="release" ( call :release
) else (
if "%1"=="darkwin" ( call :darkwin
) else (
if "%1"=="debug" ( call :debug
) else (
if "%1"=="" ( call :release
) else (
  echo ERROR: Mode not defined: %1
  echo Available modes: components, plugins, sudo, release, darkwin, debug
))))))))

GOTO:EOF

:components
  call components\build.bat
GOTO:EOF

:plugins
  call plugins\build.bat
GOTO:EOF

:release
  call :components
  call :plugins
  call :sudo
GOTO:EOF

:debug
  call :components
  call :plugins

  rem Build sudo
  call :replace_old
  lazbuild Sudo\su.pas --bm=debug %DC_ARCH%
GOTO:EOF

:sudo
  rem Build sudo
  call :replace_old
  lazbuild Sudo\su.pas --bm=release %DC_ARCH%

  call :extract
GOTO:EOF

:darkwin
  call :components
  call :plugins

  rem Build Double Commander
  call :replace_old
  lazbuild Sudo\su.pas --bm=darkwin %DC_ARCH%

  call :extract
GOTO:EOF

:extract
  rem Build Dwarf LineInfo Extractor
  lazbuild tools\extractdwrflnfo.lpi

  rem Extract debug line info
  tools\extractdwrflnfo sudo.dbg
GOTO:EOF

:replace_old
  del /Q sudo.exe.old
  ren sudo.exe sudo.exe.old
GOTO:EOF
