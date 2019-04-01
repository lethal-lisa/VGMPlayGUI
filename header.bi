/'
    
    header.bi
    
    VGMPlayGUI v2 - Header file.
    
    Copyright (c) 2018-2019 Kazusoft Co.
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
#Include "inc/config.bi"
#Include "inc/createtooltip.bi"
#Include "inc/errorhandler.bi"
#Include "inc/heapptrlist.bi"
#Include "defines.bi"

''define constants
Const MainClass = "MAINCLASS"

''declare shared variables

Extern hInstance As HINSTANCE

''declare functions
''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32

Declare Function InitClasses () As BOOL

/'  Used to start the main dialog. called by WinMain only, do not call this
    function.
    
    hWnd:HWND       -   Returns the handle to the main window.
    nShowCmd:INT32  -   Show command to use (passed from WinMain/nShowCmd).
    lParam:LPARAM   -   Optional parameter to pass to DialogBoxParam.
'/
Declare Function StartMainDialog (ByVal hWnd As HWND, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL

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
Declare Function CreateMainToolTips (ByVal hDlg As HWND) As BOOL

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

Declare Function UpdateMainTitleBar (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL

Declare Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL

''EOF
