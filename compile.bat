@ECHO OFF

REM ERRORLEVEL values:
REM 0 = no error
REM 1 = output file not found
REM 2 = project root not defined
REM 3 = source file not found
REM 4 = fb parameters not defined

REM compile chip-settings.dll
SET FBPARAM=-dll
compile-chip-settings.bat

REM compile modules
SET FBPARAM=-lib
compile-modules.bat


SET FBPARAM=

:END
