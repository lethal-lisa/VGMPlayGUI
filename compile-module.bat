@ECHO OFF

REM ERRORLEVEL ouput values:
REM 0 = No Error
REM 1 = Source file not found
REM 2 = Output file not found

REM Syntax:
REM compile-module[.bat] <source file> <output file> <output folder>
REM <source file> - The file to compile
REM <output file> - The output (*.a) file

ECHO.
ECHO %~0
ECHO FreeBASIC Static Library Compiler Tool
ECHO v1.3
ECHO.

REM compile library source file if it exists
IF EXIST %~f1 (
	IF DEFINED FBDEBUG (
		fbc -g -lib %~f1 -x %~f2
	) ELSE (
		fbc -lib %~f1 -x %~f2
	)
	SET ERRORLEVEL=0
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Check for output file
IF EXIST %~f2 (
	SET ERRORLEVEL=0
) ELSE (
	SET ERRORLEVEL=1
	GOTO ERR
)

REM Error handler
:ERR
IF NOT ERRORLEVEL 0 (
	GOTO ERR%ERRORLEVEL%
) ELSE (
	GOTO EOF
)

:ERR1
ECHO %~0 ERROR: Source file %~f1 not found.
GOTO EOF

:ERR2
ECHO.
ECHO %~0 ERROR: Output file %~f2 not found.
ECHO.

:EOF
