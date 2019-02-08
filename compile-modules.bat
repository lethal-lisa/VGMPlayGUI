@ECHO OFF

IF EXIST ".\compile-module.bat" (
	CALL ".\compile-module.bat" ".\Mod\CreateToolTip\CreateToolTip.bas" ".\libCreateToolTip.a"
	CALL ".\compile-module.bat" ".\Mod\ErrMsgBox\ErrMsgBox.bas" ".\libErrMsgBox.a"
	CALL ".\compile-module.bat" ".\Mod\HeapPtrList\HeapPtrList.bas" ".\libHeapPtrList.a"
	CALL ".\compile-module.bat" ".\Mod\OpenProgHKey\OpenProgHKey.bas" ".\libOpenProgHKey.a"
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Error handler
:ERR
GOTO ERR%ERRORLEVEL%
:ERR0
ECHO ERROR (%ERRORLEVEL%): No errors.
GOTO END
:ERR1
ECHO ERROR (%ERRORLEVEL%): Compile script not found.
GOTO END

:END
