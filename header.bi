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
#Include "inc/errmsgbox.bi"
#Include "inc/regint.bi"
#Include "inc/winapicheck.bi"

''defines
#Define MARGIN_SIZE 10
#Define WINDOW_SIZE 30
#Define MIN_SIZE_X  503
#Define MIN_SIZE_Y  443

''for some reason, this isn't defined in FB's 64-bit headers
#Ifndef DWL_MSGRESULT
#Define DWL_MSGRESULT 0
#EndIf

#Include Once "defines.bas"


''define constants
Const MainClass = "MAINCLASS"


''declare shared variables
Dim Shared hInstance As HMODULE ''instance handle
Dim Shared lpszCmdLine As LPSTR ''command line
Dim Shared hWin As HWND         ''main window handle
Dim Shared hHeap As HANDLE      ''heap handle

Dim Shared plpszPath As LPTSTR Ptr                  ''paths
Dim Shared plpszKeyName As LPTSTR Ptr               ''registry key names
Dim Shared plpszStrRes As LPTSTR Ptr                ''misc. string resources
Dim Shared phkProgKey As PHKEY                      ''program hkey
Dim Shared ppiProcInfo As PROCESS_INFORMATION Ptr   ''process info for CreateProcess
Dim Shared psiStartInfo As STARTUPINFO Ptr          ''startup info for CreateProcess
Dim Shared dwFileFilt As DWORD32                    ''file filter


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

''displays an about message
Declare Sub AboutMsgBox (ByVal hDlg As HWND)

''displays a context menu in the main dialog
Declare Function DisplayContextMenu (ByVal hDlg As HWND, ByVal x As WORD, ByVal y As WORD) As BOOL

''changes directories and refreshes directory listings
Declare Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPTSTR) As BOOL

''starts the options property sheet
Declare Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL

''options property sheet page procedures
Declare Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function SetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function GetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Sub SetFileFiltProc (ByVal hWnd As HWND, ByVal dwValue As DWORD32)
Declare Function GetFileFiltProc (ByVal hWnd As HWND) As DWORD32
Declare Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function SetVGMPlaySettingsProc (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL

''shows the cancel prompt
Declare Sub PrpshCancelPrompt (ByVal hDlg As HWND)

''starts VGMPlay
Declare Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL

''opens a VGM file
Declare Function OpenVGMFile (ByVal hDlg As HWND) As BOOL

''memory macro functions
Declare Function InitMem () As BOOL
Declare Function FreeMem () As BOOL

''loads string resources
Declare Function LoadStringResources (ByVal hInst As HINSTANCE) As BOOL

''config functions
Declare Function LoadConfig () As BOOL
Declare Function SaveConfig () As BOOL
Declare Function SetDefConfig () As BOOL

''EOF
