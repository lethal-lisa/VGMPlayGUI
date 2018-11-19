/'
    
    header.bi
    
    VGMPlayGUI v2 - Header file.
    
    Copyright (c) 2018 Kazusoft Co.
    Kazusoft is a TradeMark of Lisa Murray.
    
'/

''preprocesser
#Pragma Once

''make sure target is Windows
#Ifndef __FB_WIN32__
#Error "This file is for Windows only." 
#EndIf

#Ifdef __FB_64BIT__
#Print "Compiling for 64-bit Windows."
#Else
#Print "Compiling for 32-bit Windows."
#EndIf

#If __FB_DEBUG__
#Print "Compiling in debug mode."
#Else
#Print "Compiling in release mode."
#EndIf

#LibPath "mod"

''include header files
#Include Once "windows.bi"
#Include Once "win/shlwapi.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/prsht.bi"
#Include "mod/chip-settings/chip-settings.bi"
#Include "inc/errmsgbox.bi"
#Include "inc/winapicheck.bi"

#Include Once "defines.bas"


''define constants
Const MainClass = "MAINCLASS"

''declare shared variables
Dim Shared hInstance As HMODULE                     ''global application instance handle
Dim Shared lpszCmdLine As LPSTR                     ''command line parameters pointer
Dim Shared hWin As HWND                             ''main window handle
Dim Shared hHeap As HANDLE                          ''application heap handle

Dim Shared plpszPath As LPTSTR Ptr                  ''paths
Dim Shared plpszKeyName As LPTSTR Ptr               ''registry key names
Dim Shared plpszStrRes As LPTSTR Ptr                ''misc. string resources
Dim Shared phkProgKey As PHKEY                      ''application hkey
Dim Shared ppiProcInfo As PROCESS_INFORMATION Ptr   ''process info for CreateProcess
Dim Shared psiStartInfo As STARTUPINFO Ptr          ''startup info for CreateProcess
Dim Shared dwFileFilt As DWORD32                    ''file attribute filter


''declare functions
''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32

''subroutine used to start the main dialog. called by WinMain
Declare Sub StartMainDialog (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM)

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''creates child windows for the main dialog
Declare Function CreateMainChildren (ByVal hDlg As HWND) As BOOL

''creates a tooltip and associates it with a control
Declare Function CreateToolTip (ByVal hDlg As HWND, ByVal dwToolID As DWORD32, ByVal wTextID As WORD, ByVal dwStyle As DWORD32, ByVal uFlags As UINT32) As HWND

''resizes the main dialog's child windows
Declare Function ResizeChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

''displays a context menu in the main dialog
Declare Function DisplayContextMenu (ByVal hDlg As HWND, ByVal x As WORD, ByVal y As WORD) As BOOL

''changes directories and refreshes directory listings
Declare Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPTSTR) As BOOL

''options property sheet functions
Declare Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL
Declare Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function SetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function GetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function SetFileFiltProc (ByVal hWnd As HWND, ByVal dwValue As DWORD32) As BOOL
Declare Function GetFileFiltProc (ByVal hWnd As HWND, ByRef dwValue As DWORD32) As BOOL
Declare Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function PrpshCancelPrompt (ByVal hDlg As HWND) As DWORD32

''starts VGMPlay
Declare Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL

''memory macro functions
Declare Function InitMem () As BOOL
Declare Function FreeMem () As BOOL

''loads string resources
Declare Function LoadStringResources (ByVal hInst As HINSTANCE) As BOOL

''config functions
Declare Function LoadConfig () As BOOL
Declare Function SaveConfig () As BOOL
Declare Function SetDefConfig () As BOOL
Declare Function OpenProgHKey (ByRef phkProgKey As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As BOOL

''EOF
