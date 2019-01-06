@ECHO OFF
REM Compile libchip-settings.dll
ECHO.
ECHO COMPILING LIBCHIP-SETTINGS.DLL.
ECHO.
CHDIR ".\Res\Chip-Settings"
GoRC /r ".\chip-settings.rc"
CHDIR "..\.."
fbc -dll ".\Mod\Chip-Settings\chip-settings.bas" ".\Res\Chip-Settings\chip-settings.res"
MOVE ".\Mod\Chip-Settings\*.dll" "."
MOVE ".\Mod\Chip-Settings\*.dll.a" "."

REM Compile modules
ECHO.
ECHO COMPILING MODULES.
ECHO.
CHDIR ".\Mod"
fbc -lib ".\ErrMsgBox.bas"
fbc -lib ".\HeapPtrList.bas"
fbc -lib ".\WinAPICheck.bas"
CHDIR ".."

REM Compile main module
ECHO.
ECHO COMPILING MAIN MODULE.
ECHO.
GoRC /r ".\resource.rc"
fbc -s gui -mt ".\main.bas" ".\resource.res" -x "VGMPlayGUI.exe"

REM Clean up directory
ECHO.
ECHO CLEANING UP DIRECTORY.
ECHO.
DEL ".\Res\Chip-Settings\*.res"
DEL ".\*.dll.a"
DEL ".\*.res"
DEL ".\Mod\*.a"
