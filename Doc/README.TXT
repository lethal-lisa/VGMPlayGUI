VGMPlayGUI - General Documentation:

Summary:
    
    This program is a Windows GUI for Valley Bell's VGMPlay program,
    as such it is not stand-alone and requires VGMPlay to be installed.
    It's designed to make using VGMPlay easier by providing a GUI based interface
    for the otherwise console-mode only application. It's distributed under the 
    GNU GPL3 license, and built using FreeBASIC v1.05.0.
    
Minimum Requirements:
    
    CPU: Depends on VGM file complexity.
    RAM: Depends on VGM file size.
    OS: 32- or 64-Bit Microsoft Windows Vista or higher (64-Bit Windows 7 or higher recommended).
    Software: Valley Bell's VGMPlay for Windows.

:Compilation Requirements:
    
    -32- or 64-Bit Microsoft Windows Vista or Higher.
    -FreeBASIC compiler v1.05.0 or newer for Windows.
  
Compilation Instructions:
    
    1. Install the latest version of FreeBASIC for Windows.
    2. compile .\Mod\*.bas with the -lib command-line switch.
    3. compile .\main.bas with these parameters:
    fbc.exe -s gui ".\main.bas" ".\resource.rc" -x "VGMPlayGUI.exe"

Contact:
    Community Discord Server: https://discord.gg/mdN3sqp
  
