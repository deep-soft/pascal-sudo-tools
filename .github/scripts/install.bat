rem This script run from create_packages.bat
rem If you run it direct, set up %BUILD_PACK_DIR% first

rem Prepare all installation files

set PROG_INSTALL_DIR=%BUILD_PACK_DIR%\sudo
mkdir  %PROG_INSTALL_DIR%

copy *.exe                          %PROG_INSTALL_DIR%\
copy *.dll                          %PROG_INSTALL_DIR%\
