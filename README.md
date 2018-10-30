# VGMPlayGUI
GUI for Valley Bell's VGMPlay:

  This program is a Windows GUI for Valley Bell's VGMPlay program,
as such it is not stand-alone and requires VGMPlay to be installed.
  It's designed to make using VGMPlay easier.
It's built using FreeBASIC.

Requirements:
  - 32- or 64-Bit Microsoft Windows Vista or higher.
  - Valley Bell's VGMPlay for Windows.

To compile:
  1. Install the latest version of FreeBASIC for Windows.
  2. compile the *.bas files in the .\Mod directory with the -lib command-line switch.
  3. compile .\main.bas with these parameters:
    fbc.exe -s gui ".\main.bas" ".\Res\resource.rc" -x "VGMPlayGUI.exe"