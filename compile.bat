@ECHO OFF

REM ERRORLEVEL values:
REM 0 = no error
REM 1 = compile script not found
REM 2 = input file not found
REM 3 = output file not found

REM Compile modules
IF EXIST ".\compile-modules.bat" (
	CALL ".\compile-modules.bat"
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Compile chip-settings.dll
IF EXIST ".\compile-chip-settings.bat" (
	CALL ".\compile-chip-settings.bat"
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Compile resource script
IF EXIST ".\resource.rc" (
	GoRC /r /nu ".\resource.rc"
	IF NOT EXIST ".\resource.res" (
		SET ERRORLEVEL=3
		GOTO ERR
	)
) ELSE (
	SET ERRORLEVEL=2
	GOTO ERR
)

REM Compile main
IF EXIST ".\main.bas" (
	IF DEFINED FBDEBUG (
		fbc -g ".\main.bas" ".\resource.res" -x "VGMPlayGUI.exe"
	) ELSE (
		fbc -s gui ".\main.bas" ".\resource.res" -x "VGMPlayGUI.exe"
	)
	IF EXIST ".\VGMPlayGUI.exe" (
		DEL ".\*.a"
		DEL ".\*.res"
	) ELSE (
		SET ERRORLEVEL=3
		GOTO ERR
	)
) ELSE (
	SET ERRORLEVEL=2
	GOTO ERR
)

GOTO END

:ERR
GOTO ERR%ERRORLEVEL%
:ERR0
ECHO ERROR (%ERRORLEVEL%): No error.
GOTO END
:ERR1
ECHO ERROR (%ERRORLEVEL%): Compile script not found.
GOTO END
:ERR2
ECHO ERROR (%ERRORLEVEL%): Input file not found.
GOTO END
:ERR3
ECHO ERROR (%ERRORLEVEL%): Output file not found.
GOTO END

:END
