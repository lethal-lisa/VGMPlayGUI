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

REM Compile chip-settings.dll:
ECHO.
ECHO COMPILING: "chip-settings.dll"
ECHO.
CHDIR %PROJROOT%\Mod\Chip-Settings
IF EXIST ".\chip-settings.rc" (
	GoRC /r ".\chip-settings.rc"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)
IF NOT EXIST ".\chip-settings.res" (
	SET ERRORLEVEL=1
	GOTO ERR
)
IF EXIST ".\chip-settings.bas" (
	fbc %FBPARAM% ".\chip-settings.bas" ".\chip-settings.res"
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)
ECHO.
ECHO MOVING FILES
ECHO.
IF EXIST ".\chip-settings.dll" (
	MOVE ".\chip-settings.dll" %PROJROOT%
) ELSE (
	SET ERRORLEVEL=1
	GOTO END
)
IF EXIST ".\libchip-settings.dll.a" (
	MOVE ".\libchip-settings.dll.a" %PROJROOT%\Mod
) ELSE (
	SET ERRORLEVEL=1
	GOTO END
)
IF EXIST ".\chip-settings.res" (
	DEL ".\chip-settings.res"
) ELSE (
	SET ERRORLEVEL=1
	GOTO END
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