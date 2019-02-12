@ECHO OFF

CHDIR ".\Mod\Chip-Settings\"

REM Compile resource file
IF EXIST ".\chip-settings.rc" (
	GoRC /r /nu ".\chip-settings.rc"
	IF NOT EXIST ".\chip-settings.res" (
		SET ERRORLEVEL=3
		GOTO ERR
	)
) ELSE (
	SET ERRORLEVEL=2
	GOTO ERR
)

REM Compile libchip-settings.dll
IF EXIST ".\chip-settings.bas" (
	fbc -dll ".\chip-settings.bas" ".\chip-settings.res"
) ELSE (
	SET ERRORLEVEL=2
	GOTO ERR
)

IF EXIST ".\chip-settings.dll" (
	MOVE ".\chip-settings.dll" "..\.."
	MOVE ".\libchip-settings.dll.a" "..\.."
	DEL ".\chip-settings.res"
	CHDIR "..\.."
) ELSE (
	SET ERRORLEVEL=3
	GOTO ERR
)




GOTO END

REM Error handler
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
