@ECHO OFF

REM ERRORLEVEL values:
REM 0 = no error
REM 1 = output file not found
REM 2 = project root not defined
REM 3 = source file not found
REM 4 = fb parameters not defined

REM make sure project root folder is defined
IF NOT DEFINED PROJROOT (
	SET ERRORLEVEL=2
	GOTO ERR
)

REM make sure fb parameters are defined
IF NOT DEFINED FBPARAM (
	SET ERRORLEVEL=4
	GOTO ERR
)

CHDIR %PROJROOT%\Mod

REM Compile libErrMsgBox.a
ECHO.
ECHO COMPILING: "libErrMsgBox.a"
ECHO.
CHDIR ".\ErrMsgBox"
IF EXIST ".\ErrMsgBox.bas" (
	fbc %FBPARAM% ".\ErrMsgBox.bas"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)
IF EXIST ".\libErrMsgBox.a" (
	MOVE ".\libErrMsgBox.a" %PROJROOT%\Mod
	CHDIR %PROJROOT%\Mod
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Compile libHeapPtrList.a
ECHO.
ECHO COMPILING: "libHeapPtrList.a"
ECHO.
CHDIR ".\HeapPtrList"
IF EXIST ".\HeapPtrList.bas" (
	fbc %FBPARAM% ".\HeapPtrList.bas"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)
IF EXIST ".\libHeapPtrList.a" (
	MOVE ".\libHeapPtrList.a" %PROJROOT%\Mod
	CHDIR %PROJROOT%\Mod
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Compile libOpenProgHKey.a
ECHO.
ECHO COMPILING: "libOpenProgHKey.a"
ECHO.
CHDIR ".\OpenProgHKey"
IF EXIST ".\OpenProgHKey.bas" (
	fbc %FBPARAM% ".\OpenProgHKey.bas"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)
IF EXIST ".\libOpenProgHKey.a" (
	MOVE ".\libOpenProgHKey.a" %PROJROOT%\Mod
	CHDIR %PROJROOT%\Mod
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Compile libCreateToolTip.a
ECHO.
ECHO COMPILING: "libCreateToolTip.a"
ECHO.
CHDIR ".\CreateToolTip"
IF EXIST ".\CreateToolTip.bas" (
	fbc %FBPARAM% ".\CreateToolTip.bas"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)
If EXIST ".\libCreateToolTip.a" (
	MOVE ".\libCreateToolTip.a" %PROJROOT%\Mod
	CHDIR %PROJROOT%\Mod
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

SET ERRORLEVEL=0
CHDIR %PROJROOT%
GOTO END

REM Error handler
:ERR
GOTO ERR%ERRORLEVEL%
:ERR0
ECHO ERROR (%ERRORLEVEL%): No errors.
GOTO END
:ERR1
ECHO ERROR (%ERRORLEVEL%): Output file not found.
GOTO END
:ERR2
ECHO ERROR (%ERRORLEVEL%): Project root folder environment variable (PROJROOT) not defined.
GOTO END
:ERR3
ECHO ERROR (%ERRORLEVEL%): Source file not found.
GOTO END
:ERR4
ECHO ERROR (%ERRORLEVEL%): FB parameters environment variable (FBPARAM) not defined.
GOTO END

:END
