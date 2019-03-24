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

#If __FB_OUT_EXE__
    #Print "Compiling VGMPlayGUI."
#Else
    #Error "__FB_OUT_EXE__ = 0"
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

''include header files
#Include Once "windows.bi"
#Include Once "win/shlwapi.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
'#Include Once "win/prsht.bi"
#Include "mod/chip-settings/chip-settings.bi"
#Include "inc/errorhandler.bi"
#Include "inc/config.bi"
#Include "mod/heapptrlist/heapptrlist.bi"
#Include "mod/createtooltip/createtooltip.bi"

#Include Once "defines.bas"

''define structures

''define constants
Const MainClass = "MAINCLASS"

''declare shared variables
Dim Shared hInstance As HINSTANCE       ''handle to the application's instance
Dim Shared hWin As HWND                 ''handle to the application's main window
Dim Shared hHeap As HANDLE              ''handle to the application's heap

Extern hInstance As HINSTANCE

Extern hConfig As HANDLE
Extern plpszPath As LPTSTR Ptr
Extern plpszStrRes As LPTSTR Ptr
Extern dwFileFilt As DWORD32

''declare functions
''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32

/'  Used to start the main dialog. called by WinMain only, do not call this
    function.
    
    hInst:HINSTANCE -   Handle to the app's instance (passed from
                        WinMain/hInst).
    hWnd:HWND       -   Returns the handle to the main window.
    nShowCmd:INT32  -   Show command to use (passed from WinMain/nShowCmd).
    lParam:LPARAM   -   Optional parameter to pass to DialogBoxParam.
'/
Declare Function StartMainDialog (ByVal hInst As HINSTANCE, ByVal hWnd As HWND, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL

''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

/'  Creates child windows for the main dialog. This is called exclusivly by
    MainProc, do not call this function otherwise.
'/
Declare Function CreateMainChildren (ByVal hDlg As HWND) As BOOL

/'  Called by CreateMainChildren to create tooltips for the main dialog. This
    is called exclusively by CreateMainChildren, do not call this
    function otherwise.
'/
Declare Function CreateMainToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL

''EnumChildWindows procedure for resizing the main dialog's child windows
Declare Function ResizeChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

/'  Displays a context menu in the main dialog. dwMouse holds the screen
    coords of the mouse click in the following form:
    Low order WORD = x
    High order WORD = y
'/
Declare Function DisplayContextMenu (ByVal hDlg As HWND, ByVal dwMouse As DWORD32) As BOOL

/'  Changes directories, updates the UI, and redraws the list boxes for the
    main dialog. This function should only be called by MainProc, do not call
    it otherwise.
'/
Declare Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL

/'
''options property sheet functions
''starts the options property sheet
Declare Function DoOptionsPropSheet (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL

''WindowProc for the paths page
Declare Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''functions for PathsProc
Declare Function CreatePathsToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
Declare Function BrowseVGMPlay (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL

/'  Gets or sets the UI for the Paths Property Sheet. plpszValue is a
    pointer to two strings of MAX_PATH TCHARs in length.
'/
Declare Function SetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function GetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL

''WindowProc for the file filter page
Declare Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''functions for FileFiltProc
Declare Function CreateFileFiltToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
Declare Function SetFileFiltProc (ByVal hWnd As HWND, ByVal dwValue As DWORD32) As BOOL
Declare Function GetFileFiltProc (ByVal hWnd As HWND, ByRef dwValue As DWORD32) As BOOL

''WindowProc for the VGMPlay settings page
Declare Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''cancel prompt for the property sheet
Declare Function PrpshCancelPrompt (ByVal hDlg As HWND) As DWORD32

''function to start up VGMPlay with a file
Declare Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL

''memory macro functions
Declare Function InitMem () As BOOL
Declare Function FreeMem () As BOOL

''loads string resources
Declare Function LoadStringResources (ByVal hInst As HINSTANCE) As BOOL

''config functions
''loads/saves the configuration to the registry
Declare Function LoadConfig () As BOOL
Declare Function SaveConfig () As BOOL

''sets the default configuration values
Declare Function SetDefConfig () As BOOL
'/

''EOF
