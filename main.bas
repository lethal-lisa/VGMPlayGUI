/'
    
    main.bas
    
    VGMPlayGUI v2 - Main module.
    
    Compile with:
        GoRC /r /nu "resource.rc"
        fbc -s gui "main.bas" "resource.res" "errorhandler.o" "config.o" -x "VGMPlayGUI.exe"
    
    Copyright (c) 2018 Kazusoft Co.
    Kazusoft is a TradeMark of Lisa Murray.
    
'/

''make sure this is main module
#Ifndef __FB_MAIN__
    #Error "This file must be the main module."
#EndIf

''include header file
#Include "header.bi"

''init
Dim Shared hWin As HWND ''handle to the application's main window
Dim Shared hInstance As HINSTANCE
hInstance = GetModuleHandle(NULL)
Dim lpszCmdLine As LPSTR = GetCommandLine()
#If __FB_DEBUG__
    ? !"hInstance\t= 0x"; Hex(hInstance)
    ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine)
    ? !"*lpszCmdLine\t= "; *lpszCmdLine
#EndIf
InitCommonControls()

''call WinMain
Dim uExitCode As UINT32 = WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL)

''exit
#If __FB_DEBUG__
    ? !"uExitCode\t= 0x"; Hex(uExitCode)
#EndIf
ExitProcess(uExitCode)
End(uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd)
    #EndIf
    
    hConfig = HeapCreate(NULL, NULL, NULL)
    If (hConfig = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    /'''setup and register classes
    Dim wcxMainClass As WNDCLASSEX
    ZeroMemory(@wcxMainClass, SizeOf(WNDCLASSEX))
    With wcxMainClass
        .cbSize         = SizeOf(WNDCLASSEX)
        .style          = (CS_HREDRAW Or CS_VREDRAW)
        .lpfnWndProc    = @MainProc
        .cbClsExtra     = 0
        .cbWndExtra     = DLGWINDOWEXTRA
        .hInstance      = hInst
        .hIcon          = LoadIcon(hInst, MAKEINTRESOURCE(IDI_VGMPLAYGUI))
        .hCursor        = LoadCursor(NULL, IDC_ARROW)
        .hbrBackground  = Cast(HBRUSH, (COLOR_BTNFACE + 1))
        .lpszMenuName   = MAKEINTRESOURCE(IDR_MENUMAIN)
        .lpszClassName  = @MainClass
        .hIconSm        = .hIcon
    End With
    RegisterClassEx(@wcxMainClass)'/
    
    If (InitClasses() = FALSE) Then Return(GetLastError())
    
    ''initialize memory
    If (InitConfig() = FALSE) Then Return(GetLastError())
    
    ''load config from registry
    If (LoadConfig() = FALSE) Then Return(GetLastError())
    
    ''create, show, and update the main window
    If (StartMainDialog(hWin, nShowCmd, NULL) = FALSE) Then Return(GetLastError())
    
    ''start message loop
    Dim msg As MSG
    While (GetMessage(@msg, hWin, 0, 0) = TRUE)
        If (IsDialogMessage(hWin, @msg) = FALSE) Then
            TranslateMessage(@msg)
            DispatchMessage(@msg)
        End If
    Wend
    
    ''free memory
    If (FreeConfig() = FALSE) Then Return(GetLastError())
    
    ''destroy the heap
    If (HeapDestroy(hConfig) = FALSE) Then Return(GetLastError())
    
    ''unregister the window classes
    If (UnregisterClass(@MainClass, hInst) = FALSE) Then Return(GetLastError())
    
    ''return exit code
    Return(msg.wParam)
    
End Function

Private Function InitClasses () As BOOL
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''setup main class
    Dim lpwcxMain As LPWNDCLASSEX = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(WNDCLASSEX))
    If (lpwcxMain = NULL) Then Return(FALSE)
    With *lpwcxMain
        .cbSize         = SizeOf(WNDCLASSEX)
        .style          = (CS_HREDRAW Or CS_VREDRAW)
        .lpfnWndProc    = @MainProc
        .cbClsExtra     = 0
        .cbWndExtra     = DLGWINDOWEXTRA
        .hInstance      = hInstance
        .hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_VGMPLAYGUI))
        .hCursor        = LoadCursor(NULL, IDC_ARROW)
        .hbrBackground  = Cast(HBRUSH, (COLOR_BTNFACE + 1))
        .lpszMenuName   = MAKEINTRESOURCE(IDR_MENUMAIN)
        .lpszClassName  = @MainClass
        .hIconSm        = .hIcon
    End With
    RegisterClassEx(lpwcxMain)
    
    ''return
    If (HeapFree(hHeap, NULL, lpwcxMain) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''used to start the main dialog. called by WinMain
Private Function StartMainDialog (ByVal hWnd As HWND, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd)
        ? !"lParam\t= 0x"; Hex(lParam)
    #EndIf
    
    ''create the window
    DialogBoxParam(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, @MainProc, lParam)
    
    ''find the window
    hWnd = FindWindow(@MainClass, NULL)
    If (hWnd = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''show the window
    If (ShowWindow(hWnd, nShowCmd) = FALSE) Then Return(FALSE)
    If (SetForegroundWindow(hWnd) = FALSE) Then Return(FALSE)
    SetActiveWindow(hWnd)
    If (UpdateWindow(hWnd) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''dialog procedures
Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''process messages
    Select Case uMsg                ''messages:
        Case WM_CREATE              ''creating window
            
            ''set the program's icon
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_VGMPLAYGUI))))
            
            ''create child windows
            If (CreateMainChildren(hWnd) = FALSE) Then SysErrMsgBox(NULL, GetLastError())
            
        Case WM_DESTROY             ''destroying window
            
            ''post quit message with success code
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG          ''initializing dialog
            
            ''initialize directory listings to default directory
            If (HeapLock(hConfig) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            If (PopulateLists(hWnd, plpszPath[PATH_DEFAULT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            If (HeapUnlock(hConfig) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''set the default keyboard focus to IDC_LST_MAIN
            If (SetFocus(GetDlgItem(hWnd, IDC_LST_MAIN)) = Cast(HWND, NULL)) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''make sure VGMPlay's path is valid
            If (PathFileExists(plpszPath[PATH_VGMPLAY]) = FALSE) Then
                If (ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_VGMPMISS, IDS_MSGCAP_VGMPMISS, MB_YESNO Or MB_ICONWARNING) = IDYES) Then
                    ''TODO: fix error checking here
                    DoOptionsPropSheet(hWnd)
                End If
            End If
            
        Case WM_CLOSE               ''window is being closed
            
            ''destroy main window
            If (DestroyWindow(hWnd) = FALSE) Then SysErrMsgBox(NULL, GetLastError())
            
        Case WM_COMMAND             ''command has been issued
            
            Select Case HiWord(wParam)                          ''event:
                Case BN_CLICKED                                 ''a button has been pressed
                    Select Case LoWord(wParam)                      ''button IDs:
                        Case IDM_ROOT                               ''change to drive root
                            
                            ''change directory to the current drive's root
                            If (PopulateLists(hWnd, "\") = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDM_EXIT                               ''exit program
                            
                            ''send a WM_CLOSE message to the main window
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_OPTIONS                            ''start the options property sheet
                            
                            DoOptionsPropSheet(hWnd)
                            
                        Case IDM_ABOUT                              ''display the about message
                            
                            ''setup messageboxparams
                            Dim mbp As MSGBOXPARAMS
                            ZeroMemory(@mbp, SizeOf(MSGBOXPARAMS))
                            With mbp
                                .cbSize             = SizeOf(MSGBOXPARAMS)
                                .hwndOwner          = hWnd
                                .hInstance          = hInstance
                                .lpszText           = MAKEINTRESOURCE(IDS_MSGTXT_ABOUT)
                                .lpszCaption        = MAKEINTRESOURCE(IDS_MSGCAP_ABOUT)
                                .dwStyle            = (MB_OK Or MB_DEFBUTTON1 Or MB_USERICON)
                                .lpszIcon           = MAKEINTRESOURCE(IDI_KAZUSOFT)
                                '.dwContextHelpId    = NULL
                                '.lpfnMsgBoxCallback = NULL
                                .dwLanguageId       = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
                            End With
                            
                            ''display message box
                            MessageBeep(MB_ICONINFORMATION)
                            MessageBoxIndirect(@mbp)
                            
                        Case IDC_BTN_PLAY, IDM_BTN_PLAY_CURRENT     ''start VGMPlay
                            
                            If (HeapLock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            GetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT], CCH_PATH)
                            If (StartVGMPlay(plpszPath[PATH_CURRENT]) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (HeapUnlock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_GO                             ''change to a specified directory
                            
                            If (HeapLock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            GetDlgItemText(hWnd, IDC_EDT_PATH, plpszPath[PATH_CURRENT], MAX_PATH)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (HeapUnlock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_UP, IDM_UP                     ''move up one directory
                            
                            If (PopulateLists(hWnd, "..") = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_REFRESH, IDM_REFRESH           ''refresh the current directory listing
                            
                            If (PopulateLists(hWnd, ".") = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                    End Select
                    
                Case LBN_DBLCLK                                 ''the user has double-clicked in a listbox
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get selected item, change directories, and refresh the listboxes
                            If (HeapLock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_MAIN)
                            If (PathIsDirectory(Cast(LPCTSTR, plpszPath[PATH_CURRENT])) = Cast(BOOL, FILE_ATTRIBUTE_DIRECTORY)) Then
                                
                                ''change to selected directory and refresh the listboxes
                                If (GetLastError() = ERROR_SUCCESS) Then
                                    If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                                Else
                                    Return(SysErrMsgBox(hWnd, GetLastError()))
                                End If
                                
                            End If
                            If (HeapUnlock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                    End Select
                    
                Case LBN_SELCHANGE                              ''a listbox selection has changed
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get the selected item and update the UI
                            If (HeapLock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_MAIN)
                            SetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT])
                            If (HeapUnlock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_LST_DRIVES     ''drives list
                            
                            ''get the selected item and change drives
                            If (HeapLock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_DRIVES)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (HeapUnlock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                    End Select
                    
                Case Cast(UINT32, LBN_ERRSPACE), EN_ERRSPACE    ''a listbox or edit control is out of memory
                    
                    ''display error message, and terminate program
                    'SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY)
                    'PostQuitMessage(ERROR_NOT_ENOUGH_MEMORY)
                    Return(FatalSysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY))
                    
            End Select
            
        Case WM_SIZE                ''window has been resized
            
            #If __FB_DEBUG__
                ? "WM_SIZE:"
                ? "Resize type:", "0x"; Hex(wParam)
                'If (wParam And SIZE_MAXHIDE) Then ? "SIZE_MAXHIDE"
                'If (wParam And SIZE_MAXIMIZED) Then ? "SIZE_MAXIMIZED"
                'If (wParam And SIZE_MAXSHOW) Then ? "SIZE_MAXSHOW"
                'If (wParam And SIZE_MINIMIZED) Then ? "SIZE_MINIMIZED"
                'If (wParam And SIZE_RESTORED) Then ? "SIZE_RESTORED"
                ? "(cx, cy)", "= ("; LoWord(lParam); ", "; HiWord(lParam); ")"
            #EndIf
            
            ''declare local variables
            Dim rcSbr As RECT       ''statusbar rect
            Dim rcParent As RECT    ''main dialog rect
            
            ''get rects for statusbar and main dialog, and subtract the statusbar's height from that of the main window
            With rcParent
                .right  = LoWord(lParam)
                .bottom = HiWord(lParam)
            End With
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR), @rcSbr) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            rcParent.bottom -= rcSbr.bottom
            
            ''resize the child windows
            If (EnumChildWindows(hWnd, @ResizeChildren, Cast(LPARAM, @rcParent)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
            Return(Cast(LRESULT, TRUE))
            
        Case WM_WINDOWPOSCHANGING   ''window position is changing
            
            ''get windowpos structure from lParam
            Dim pwp As WINDOWPOS Ptr = Cast(WINDOWPOS Ptr, lParam)
            
            ''prevent window from getting too small
            If (pwp->cx < MIN_SIZE_X) Then pwp->cx = MIN_SIZE_X
            If (pwp->cy < MIN_SIZE_Y) Then pwp->cy = MIN_SIZE_Y
            
        Case WM_CONTEXTMENU         ''display the context menu
            
            /' (x, y) = _
                LoWord(lParam) = x
                HiWord(lParam) = y
            '/
            
            If (DisplayContextMenu(hWnd, Cast(DWORD32, lParam)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
        Case Else                   ''otherwise
            
            ''use default window procedure
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return
    Return(0)
    
End Function

''creates child windows for the main dialog
Private Function CreateMainChildren (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''create child windows
    CreateWindowEx(NULL, STATUSCLASSNAME, NULL, WS_CHILD Or WS_VISIBLE Or SBARS_SIZEGRIP Or SBARS_TOOLTIPS, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_SBR), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTBOX, NULL, WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_TABSTOP Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_HASSTRINGS Or LBS_SORT, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_LST_MAIN), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTBOX, NULL, WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_TABSTOP Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_HASSTRINGS Or LBS_SORT, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_LST_DRIVES), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_EDIT, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or ES_LEFT Or ES_AUTOHSCROLL, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_EDT_FILE), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER Or BS_DEFPUSHBUTTON Or BS_ICON, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_PLAY), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_EDIT, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or ES_LEFT Or ES_AUTOHSCROLL, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_EDT_PATH), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, "Go", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_GO), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, "[..]", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_UP), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, "[.]", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_REFRESH), hInstance, NULL)
    
    ''set IDI_PLAY to IDC_BTN_PLAY
    SendMessage(GetDlgItem(hDlg, IDC_BTN_PLAY), BM_SETIMAGE, IMAGE_ICON, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_PLAY))))
    
    ''create tooltips
    If (CreateMainToolTips(hDlg) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''called by CreateMainChildren to create tooltips
Private Function CreateMainToolTips (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''create tooltips
    If (CreateToolTip(hInstance, hDlg, IDC_LST_DRIVES, IDS_TIP_DRIVELIST, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_BTN_PLAY, IDS_TIP_PLAYBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_BTN_GO, IDS_TIP_GOBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_BTN_UP, IDS_TIP_UPBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_BTN_REFRESH, IDS_TIP_REFRESHBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''resizes the main dialog's child windows
Private Function ResizeChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
    
    ''declare local variables
    Dim lprcParent As LPRECT    ''parent window's bounding rectangle
    Dim rcChild As RECT         ''child window's new bounding rectangle
    
    ''get lprcParent
    lprcParent = Cast(LPRECT, lParam)
    
    With rcChild
        
        ''calculate child window's new bounding rectangle
        Select Case GetWindowLong(hWnd, GWL_ID)
            Case IDC_SBR
                .left   = 0
                .top    = 0
                .right  = 0
                .bottom = 0
            Case IDC_LST_MAIN
                .left   = MARGIN_SIZE
                .top    = ((2 * MARGIN_SIZE) + WINDOW_SIZE)
                .right  = (lprcParent->Right - ((3 * MARGIN_SIZE) + (3 * WINDOW_SIZE)))
                .bottom = (lprcParent->bottom - ((4 * MARGIN_SIZE) + (2 * WINDOW_SIZE)))
            Case IDC_LST_DRIVES
                .left   = (lprcParent->Right - (MARGIN_SIZE + (3 * WINDOW_SIZE)))
                .top    = ((2 * MARGIN_SIZE) + WINDOW_SIZE)
                .right  = (3 * WINDOW_SIZE)
                .bottom = (lprcParent->bottom - ((4 * MARGIN_SIZE) + (2 * WINDOW_SIZE)))
            Case IDC_EDT_FILE
                .left   = MARGIN_SIZE
                .top    = (lprcParent->bottom - (MARGIN_SIZE + WINDOW_SIZE))
                .right  = (lprcParent->Right - ((3 * MARGIN_SIZE) + (2 * WINDOW_SIZE)))
                .bottom = WINDOW_SIZE
            Case IDC_BTN_PLAY
                .left   = (lprcParent->Right - (MARGIN_SIZE + (2 * WINDOW_SIZE)))
                .top    = (lprcParent->bottom - (MARGIN_SIZE + (1.25 * WINDOW_SIZE)))
                .right  = (2 * WINDOW_SIZE)
                .bottom = (1.5 * WINDOW_SIZE)
            Case IDC_EDT_PATH
                .left   = MARGIN_SIZE
                .top    = MARGIN_SIZE
                .right  = (lprcParent->Right - ((3 * WINDOW_SIZE) + (3 * MARGIN_SIZE)))
                .bottom = WINDOW_SIZE
            Case IDC_BTN_GO
                .left   = (lprcParent->Right - (MARGIN_SIZE + (3 * WINDOW_SIZE)))
                .top    = MARGIN_SIZE
                .right  = WINDOW_SIZE
                .bottom = WINDOW_SIZE
            Case IDC_BTN_UP
                .left   = (lprcParent->Right - (MARGIN_SIZE + (2 * WINDOW_SIZE)))
                .top    = MARGIN_SIZE
                .right  = WINDOW_SIZE
                .bottom = WINDOW_SIZE
            Case IDC_BTN_REFRESH
                .left   = (lprcParent->Right - (MARGIN_SIZE + WINDOW_SIZE))
                .top    = MARGIN_SIZE
                .right  = WINDOW_SIZE
                .bottom = WINDOW_SIZE
        End Select
        
        ''resize the child window
        If (MoveWindow(hWnd, .left, .top, .right, .bottom, TRUE) = FALSE) Then Return(FALSE)
        
    End With
    
    ''return
    Return(TRUE)
    
End Function

/' displays a context menu in the main dialog
    hDlg:HWND       -   Handle to the parent dialog
    dwMouse:DWORD32 -   Mouse position in screen co-ords. The low-order
                        WORD is the x co-ord, and the high-order WORD is
                        the y co-ord.
'/
Function DisplayContextMenu (ByVal hDlg As HWND, ByVal dwMouse As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwMouse\t= 0x"; Hex(dwMouse)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    '''create a local heap
    'Dim hDcm As HANDLE = HeapCreate(NULL, Cast(SIZE_T, SizeOf(Point)), Cast(SIZE_T, (SizeOf(Point) + (2 * SizeOf(HMENU)))))
    'If (hDcm = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get the mouse coords & convert them to client coords
    Dim lpptMouse As LPPOINT = Cast(LPPOINT, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(Point)))
    If (lpptMouse = NULL) Then Return(FALSE)
    lpptMouse->x = LoWord(dwMouse)
    lpptMouse->y = HiWord(dwMouse)
    If (ScreenToClient(hDlg, lpptMouse) = FALSE) Then Return(FALSE)
    
    ''get the child window from the mouse co-ords
    Dim hwndChild As HWND = ChildWindowFromPoint(hDlg, *lpptMouse)
    If (hwndChild = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''free memory allocated for lpptMouse
    If (HeapFree(hHeap, NULL, lpptMouse) = FALSE) Then Return(FALSE)
    
    ''allocate memory for menu handles
    Dim phMenu As HMENU Ptr = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (2 * SizeOf(HMENU)))
    If (phMenu = NULL) Then Return(FALSE)
    /'  phMenu[x] key:
        phMenu[0] = top level menu
        phMenu[1] = sub menu
    '/
    
    ''select the child window's appropriate context menu
    Select Case GetWindowLong(hwndChild, GWL_ID)
        Case IDC_LST_MAIN
            
            ''load top-level menu
			phMenu[0] = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUMAIN))
			If (phMenu[0] = INVALID_HANDLE_VALUE) Then Return(FALSE)
			
			''load sub menu
			phMenu[1] = GetSubMenu(phMenu[0], 1)
			If (phMenu[1] = INVALID_HANDLE_VALUE) Then Return(FALSE)
			
        Case IDC_LST_DRIVES
            
            ''load top-level menu
			phMenu[0] = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUCONTEXT))
			If (phMenu[0] = INVALID_HANDLE_VALUE) Then Return(FALSE)
			
			''load sub menu
            phMenu[1] = GetSubMenu(phMenu[0], MEN_DRIVES)
            If (phMenu[1] = INVALID_HANDLE_VALUE) Then Return(FALSE)
            
        Case IDC_BTN_PLAY
            
            ''load top-level menu
            phMenu[0] = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUCONTEXT))
            If (phMenu[0] = INVALID_HANDLE_VALUE) Then Return(FALSE)
            
            ''load sub menu
            phMenu[1] = GetSubMenu(phMenu[0], MEN_PLAYBTN)
            If (phMenu[1] = INVALID_HANDLE_VALUE) Then Return(FALSE)
            
        Case Else
            
            ''return
            If (HeapFree(hHeap, NULL, Cast(LPVOID, phMenu)) = FALSE) Then Return(FALSE)
            SetLastError(ERROR_SUCCESS)
            Return(TRUE)
            
    End Select
    
    ''display context menu
    If (TrackPopupMenu(phMenu[1], (TPM_LEFTALIGN Or TPM_TOPALIGN Or TPM_RIGHTBUTTON Or TPM_NOANIMATION), LoWord(dwMouse), HiWord(dwMouse), NULL, hDlg, NULL) = FALSE) Then Return(FALSE)
    
    ''destroy the menu objects
    For iMenu As INT32 = 1 To 0 Step -1
        If (DestroyMenu(phMenu[iMenu]) = FALSE) Then Return(FALSE)
    Next iMenu
    
    ''free memory allocated for menu handles
    If (HeapFree(hHeap, NULL, phMenu) = FALSE) Then Return(FALSE)
    
    ''restore the previous cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''changes directories and refreshes directory listings
Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg)
        ? !"lpszPath\t= 0x"; Hex(lpszPath)
        ? !"*lpszPath\t= "; *lpszPath
    #EndIf
    
    ''load and set a waiting cursor
    Dim hPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
	'''get a lock on the heap
    'If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
    ''make sure path exists and is a directory
    If (PathFileExists(lpszPath) = FALSE) Then Return(FALSE)
    If (PathIsDirectory(lpszPath) = FALSE) Then Return(FALSE)
    
    ''store previous path
    /' NYI:
            At this location, write the previous path (since we haven't
        changed it yet, this can be gotten with CurDir()) to a buffer.
    '/
    
    ''change directories
    If (ChDir(*lpszPath)) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''update UI
    If (SetDlgItemText(hDlg, IDC_EDT_PATH, CurDir()) = FALSE) Then Return(FALSE)
    If (SetDlgItemText(hDlg, IDC_EDT_FILE, NULL) = FALSE) Then Return(FALSE)
    
    ''allocate space for appname & load the string
    Dim lpszAppName As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, 128 * SizeOf(TCHAR))))
    If (lpszAppName = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_APPNAME, lpszAppName, 128) = 0) Then Return(FALSE)
    
    ''allocate space for new title bar string and format it
    Dim lpszTitle As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, ((MAX_PATH + 128) * SizeOf(TCHAR)))))
    If (lpszTitle = NULL) Then Return(FALSE)
    *lpszTitle = (*lpszAppName + " - [" + CurDir() + "]")
    
    ''free memory used for appname
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszAppName)) = FALSE) Then Return(FALSE)
    
    ''update the title bar
    If (SetWindowText(hDlg, Cast(LPCTSTR, lpszTitle)) = FALSE) Then Return(FALSE)
    
    ''free memory used for new title bar string
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszTitle)) = FALSE) Then Return(FALSE)
    
    ''refresh directory listings
    If (DlgDirList(hDlg, (CurDir() + "\*"), IDC_LST_MAIN, NULL, dwFileFilt) = 0) Then Return(FALSE)
    If (DlgDirList(hDlg, NULL, IDC_LST_DRIVES, NULL, (DDL_DRIVES Or DDL_EXCLUSIVE)) = 0) Then Return(FALSE)
    
    '''release the lock on the heap
    'If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''restore the previous cursor
    SetCursor(hPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''starts VGMPlay with the specified file
Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
	''set loading cursor
    Dim hPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
	
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate buffer for command line parameters
    Dim lpszParam As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (MAX_PATH * SizeOf(TCHAR)))))
    If (lpszParam = NULL) Then Return(FALSE)
    
    ''format command line parameters
    *lpszParam = (" " + Chr(34) + CurDir() + "\" + *lpszFile + Chr(34))
    If (PathFileExists(lpszFile) = FALSE) Then Return(FALSE)
    
    Static piProcInfo As PROCESS_INFORMATION
    Static siStartInfo As STARTUPINFO
    
    ''stop VGMPlay if it's already running
    If (piProcInfo.hProcess <> INVALID_HANDLE_VALUE) Then TerminateProcess(piProcInfo.hProcess, ERROR_SINGLE_INSTANCE_APP)
    
    ''start VGMPlay, and wait for an input idle code
    If (CreateProcess(plpszPath[PATH_VGMPLAY], lpszParam, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, @siStartInfo, @piProcInfo) = FALSE) Then Return(FALSE)
    WaitForInputIdle(piProcInfo.hProcess, INFINITE)
    
    ''free the buffer used for the command line parameters
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszParam)) = FALSE) Then Return(FALSE)
    
	''restore the cursor
    SetCursor(hPrev)
	
	''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
