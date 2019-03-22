/'
    
    main.bas
    
    VGMPlayGUI v2 - Main module.
    
    Compile with:
        GoRC /r /nu "resource.rc"
        fbc -s gui "main.bas" "resource.res" -x "VGMPlayGUI.exe"
    
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
hInstance = GetModuleHandle(NULL)
Dim lpszCmdLine As LPSTR = GetCommandLine()
#If __FB_DEBUG__
    ? !"hInstance\t= 0x"; Hex(hInstance, 8)
    ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine, 8)
    ? !"*lpszCmdLine\t= "; *lpszCmdLine
#EndIf
InitCommonControls()

''call WinMain
Dim uExitCode As UINT32 = WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL)

''exit
#If __FB_DEBUG__
    ? !"uExitCode\t= 0x"; Hex(uExitCode, 8)
#EndIf
ExitProcess(uExitCode)
End(uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t\t= 0x"; Hex(hInst, 8)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev, 8)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine, 8)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd, 8)
    #EndIf
    
    ''create the application heap
    hHeap = HeapCreate(NULL, NULL, NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    
    ''setup and register classes
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
    RegisterClassEx(@wcxMainClass)
    
    ''initialize memory
    If Not(InitMem()) Then Return(GetLastError())
    
    ''load strings
    If Not(LoadStringResources(hInst)) Then Return(GetLastError())
    
    ''load config from registry
    If Not(LoadConfig()) Then Return(GetLastError())
    
    ''create, show, and update the main window
    If Not(StartMainDialog(hInst, hWin, nShowCmd, NULL)) Then Return(GetLastError())
    
    ''start message loop
    Dim msg As MSG
    While (GetMessage(@msg, hWin, 0, 0) = TRUE)
        If (IsDialogMessage(hWin, @msg) = FALSE) Then
            TranslateMessage(@msg)
            DispatchMessage(@msg)
        End If
    Wend
    
    ''free memory
    If (FreeMem() = FALSE) Then Return(GetLastError())
    
    ''destroy the heap
    If (HeapDestroy(hHeap) = FALSE) Then Return(GetLastError())
    
    ''unregister the window classes
    If (UnregisterClass(@MainClass, hInst) = FALSE) Then Return(GetLastError())
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''used to start the main dialog. called by WinMain
Private Function StartMainDialog (ByVal hInst As HINSTANCE, ByVal hWnd As HWND, ByVal nShowCmd As INT32, ByVal lParam As LPARAM) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t\t= 0x"; Hex(hInst, 8)
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd, 8)
        ? !"lParam\t\t= 0x"; Hex(lParam, 8)
    #EndIf
    
    ''create the window
    DialogBoxParam(hInst, MAKEINTRESOURCE(IDD_MAIN), NULL, @MainProc, lParam)
    
    ''find the window
    hWnd = FindWindow(@MainClass, NULL)
    If (hWnd = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''show the window
    If Not(ShowWindow(hWnd, nShowCmd)) Then Return(FALSE)
    If Not(SetForegroundWindow(hWnd)) Then Return(FALSE)
    SetActiveWindow(hWnd)
    If Not(UpdateWindow(hWnd)) Then Return(FALSE)
    
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
            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            If (PopulateLists(hWnd, plpszPath[PATH_DEFAULT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''set the default keyboard focus to IDC_LST_MAIN
            If (SetFocus(GetDlgItem(hWnd, IDC_LST_MAIN)) = Cast(HWND, NULL)) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''make sure VGMPlay's path is valid
            If (PathFileExists(plpszPath[PATH_VGMPLAY]) = FALSE) Then
                If (ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_VGMPMISS, IDS_MSGCAP_VGMPMISS, MB_YESNO Or MB_ICONWARNING) = IDYES) Then
                    ''TODO: fix error checking here
                    DoOptionsPropSheet(hInstance, hWnd)
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
                            
                            DoOptionsPropSheet(hInstance, hWnd)
                            
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
                                .dwContextHelpId    = NULL
                                .lpfnMsgBoxCallback = NULL
                                .dwLanguageId       = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
                            End With
                            
                            ''display message box
                            MessageBeep(MB_ICONINFORMATION)
                            MessageBoxIndirect(@mbp)
                            
                        Case IDC_BTN_PLAY, IDM_BTN_PLAY_CURRENT     ''start VGMPlay
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            GetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT], CCH_PATH)
                            If (StartVGMPlay(plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDC_BTN_GO                             ''change to a specified directory
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            GetDlgItemText(hWnd, IDC_EDT_PATH, plpszPath[PATH_CURRENT], MAX_PATH)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDC_BTN_UP, IDM_UP                     ''move up one directory
                            
                            If (PopulateLists(hWnd, "..") = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDC_BTN_REFRESH, IDM_REFRESH           ''refresh the current directory listing
                            
                            If (PopulateLists(hWnd, ".") = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                    End Select
                    
                Case LBN_DBLCLK                                 ''the user has double-clicked in a listbox
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get selected item, change directories, and refresh the listboxes
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_MAIN)
                            If (PathIsDirectory(Cast(LPCTSTR, plpszPath[PATH_CURRENT])) = Cast(BOOL, FILE_ATTRIBUTE_DIRECTORY)) Then
                                
                                ''change to selected directory and refresh the listboxes
                                If (GetLastError() = ERROR_SUCCESS) Then
                                    If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                                Else
                                    SysErrMsgBox(hWnd, GetLastError())
                                End If
                                
                            End If
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                    End Select
                    
                Case LBN_SELCHANGE                              ''a listbox selection has changed
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get the selected item and update the UI
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_MAIN)
                            SetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT])
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDC_LST_DRIVES     ''drives list
                            
                            ''get the selected item and change drives
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_DRIVES)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                    End Select
                    
                Case Cast(UINT32, LBN_ERRSPACE), EN_ERRSPACE    ''a listbox or edit control is out of memory
                    
                    ''display error message, and terminate program
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY)
                    PostQuitMessage(ERROR_NOT_ENOUGH_MEMORY)
                    
            End Select
            
        Case WM_SIZE                ''window has been resized
            
            #If __FB_DEBUG__
                ? "WM_SIZE:"
                ? "Resize type:", "0x"; Hex(wParam, 8)
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
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR), @rcSbr) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            rcParent.bottom -= rcSbr.bottom
            
            ''resize the child windows
            If (EnumChildWindows(hWnd, @ResizeChildren, Cast(LPARAM, @rcParent)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
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
            
            If (DisplayContextMenu(hWnd, Cast(DWORD32, lParam)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
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
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
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
    If (CreateMainToolTips(hInstance, hDlg) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''called by CreateMainChildren to create tooltips
Private Function CreateMainToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    ''create tooltips
    If (CreateToolTip(hInst, hDlg, IDC_LST_DRIVES, IDS_TIP_DRIVELIST, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInst, hDlg, IDC_BTN_PLAY, IDS_TIP_PLAYBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInst, hDlg, IDC_BTN_GO, IDS_TIP_GOBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInst, hDlg, IDC_BTN_UP, IDS_TIP_UPBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInst, hDlg, IDC_BTN_REFRESH, IDS_TIP_REFRESHBTN, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
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
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg, 8)
        ? !"dwMouse\t\t= 0x"; Hex(dwMouse, 8)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''create a local heap
    Dim hDcm As HANDLE = HeapCreate(NULL, Cast(SIZE_T, SizeOf(Point)), Cast(SIZE_T, (SizeOf(Point) + (2 * SizeOf(HMENU)))))
    If (hDcm = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hDcm\t\t= 0x"; Hex(hDcm, 8)
    #EndIf
    
    ''lock the local heap
    If (HeapLock(hDcm) = FALSE) Then Return(FALSE)
    
    ''allocate space for a POINT structure to hold the mouse coords
    Dim lpptMouse As LPPOINT = Cast(LPPOINT, HeapAlloc(hDcm, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(Point))))
    If (lpptMouse = NULL) Then Return(FALSE)
    
    ''get the mouse coords & convert them to client coords
    lpptMouse->x = LoWord(dwMouse)
    lpptMouse->y = HiWord(dwMouse)
    If (ScreenToClient(hDlg, lpptMouse) = FALSE) Then Return(FALSE)
    
    ''get the child window from the mouse co-ords
    Dim hwndChild As HWND = ChildWindowFromPoint(hDlg, *lpptMouse)
    If (hwndChild = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''free memory allocated for lpptMouse
    If (HeapFree(hDcm, NULL, Cast(LPVOID, lpptMouse)) = FALSE) Then Return(FALSE)
    
    ''allocate memory for menu handles
    Dim phMenu As HMENU Ptr = Cast(HMENU Ptr, HeapAlloc(hDcm, HEAP_ZERO_MEMORY, Cast(SIZE_T, (2 * SizeOf(HMENU)))))
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
            
            ''free memory allocated for menu handles
            If (HeapFree(hDcm, NULL, Cast(LPVOID, phMenu)) = FALSE) Then Return(FALSE)
            
            ''unlock & destroy the local heap
            If (HeapUnlock(hDcm) = FALSE) Then Return(FALSE)
            If (HeapDestroy(hDcm) = FALSE) Then Return(FALSE)
            
            ''return
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
    If (HeapFree(hDcm, NULL, Cast(LPVOID, phMenu)) = FALSE) Then Return(FALSE)
    
    ''unlock & destroy the local heap
    If (HeapUnlock(hDcm) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hDcm) = FALSE) Then Return(FALSE)
    
    ''restore the previous cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''changes directories and refreshes directory listings
Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg, 8)
        ? !"lpszPath\t= 0x"; Hex(lpszPath, 8)
        ? !"*lpszPath\t= "; *lpszPath
    #EndIf
    
    ''load and set a waiting cursor
    Dim hPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
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
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''restore the previous cursor
    SetCursor(hPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function
/'
''starts the options property sheet
Function DoOptionsPropSheet (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''declare local variables
    Dim lpPsp As LPPROPSHEETPAGE    ''property sheet pages
    Dim psh As PROPSHEETHEADER      ''property sheet header
    
    ''allocate space for pages
    lpPsp = Cast(LPPROPSHEETPAGE, LocalAlloc(LPTR, Cast(SIZE_T, (3 * SizeOf(PROPSHEETPAGE)))))
    If (lpPsp = NULL) Then Return(FALSE)
    
    ''setup "paths" page
    With lpPsp[0]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = PSP_USEICONID
        .hInstance      = hInst
        .pszTemplate    = MAKEINTRESOURCE(IDD_PATHS)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszTitle       = NULL
        .pfnDlgProc     = @PathsProc
        .lParam         = NULL
        .pfnCallback    = NULL
    End With
    
    ''setup "file filter" page
    With lpPsp[1]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = (PSP_USEICONID Or PSP_HASHELP)
        .hInstance      = hInst
        .pszTemplate    = MAKEINTRESOURCE(IDD_FILEFILTER)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszTitle       = NULL
        .pfnDlgProc     = @FileFiltProc
        .lParam         = NULL
        .pfnCallback    = NULL
    End With
    
    ''setup "vgmplay settings" page
    With lpPsp[2]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = (PSP_USEICONID Or PSP_HASHELP)
        .hInstance      = hInst
        .pszTemplate    = MAKEINTRESOURCE(IDD_VGMPLAYSETTINGS)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszTitle       = NULL
        .pfnDlgProc     = @VGMPlaySettingsProc
        .lParam         = NULL
        .pfnCallback    = NULL
    End With
    
    ''setup property sheet header
    ZeroMemory(@psh, SizeOf(PROPSHEETHEADER))
    With psh
        .dwSize         = SizeOf(PROPSHEETHEADER)
        .dwFlags        = (PSH_USEICONID Or PSH_PROPSHEETPAGE Or PSH_NOCONTEXTHELP Or PSH_HASHELP)
        .hwndParent     = hDlg
        .hInstance      = hInst
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszCaption     = plpszStrRes[STR_OPTIONS]
        .nPages         = 3
        .nStartPage     = 0
        .ppsp           = Cast(LPCPROPSHEETPAGE, lpPsp)
        .pfnCallback    = NULL
    End With
    
    ''start property sheet
    PropertySheet(@psh)
    
    ''return
    LocalFree(Cast(HLOCAL, lpPsp))
    If (GetLastError()) Then Return(FALSE)
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''options property sheet page procedures
Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND    ''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''dialog init
            
            ''create tooltips
            If (CreatePathsToolTips(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''set text in path options
            SetPathsProc(hWnd, plpszPath)
            
        Case WM_COMMAND     ''commands
            
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    
                    Select Case LoWord(wParam)      ''button IDs:
                        Case IDC_BTN_VGMPLAYPATH    ''browse for vgmplay
							
                            If (BrowseVGMPlay(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDC_BTN_DEFAULTPATH    ''set default path to current one
							
							Dim szCurDir As ZString*MAX_PATH = CurDir()
							If (SetDlgItemText(hWnd, IDC_EDT_DEFAULTPATH, @szCurDir) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
							
                    End Select
                    
                Case EN_CHANGE          ''edit control changing
                    
                    SendMessage(hwndPrsht, PSM_CHANGED, Cast(WPARAM, hWnd), 0)
                    
                Case EN_ERRSPACE        ''edit control is out of space
                    
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY)
                    
            End Select
            
        Case WM_NOTIFY      ''notifications
            
            Select Case (Cast(LPNMHDR, lParam)->code)   ''notification codes
                Case PSN_SETACTIVE                      ''page becoming active
                    
                    ''get page handle
                    hwndPrsht = Cast(HWND, Cast(LPNMHDR, lParam)->hwndFrom)
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    ''let page become inactive
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    ''get settings from dialog
                    If (GetPathsProc(hWnd, plpszPath) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                    ''save settings to the registry
                    If (SaveConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                Case PSN_QUERYCANCEL                    ''user has pressed the cancel button
                    
                    PrpshCancelPrompt(hWnd)
                    
            End Select
            
        Case Else           ''otherwise
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

''called by PathsProc to create tooltips in response to WM_INITDIALOG
Private Function CreatePathsToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    ''create tooltips
    If (CreateToolTip(hInstance, hDlg, IDC_EDT_VGMPLAYPATH, IDS_TIP_VGMPLAYPATH, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_EDT_DEFAULTPATH, IDS_TIP_DEFAULTPATH, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function
'/
''called by PathsProc to start the browse for VGMPlay dialog
/'Private Function BrowseVGMPlay (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    ''create local heap
    Dim hOfn As HANDLE = HeapCreate(NULL, Cast(SIZE_T, (SizeOf(OPENFILENAME) + (CB_BVGMP * C_BVGMP))), NULL)
    If (hOfn = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hOfn\t= 0x"; Hex(hOfn, 8)
    #EndIf
    
    ''get a lock on the newly created heap
    If (HeapLock(hOfn) = FALSE) Then Return(FALSE)
    
    ''allocate strings
    Dim plpszString As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hOfn, Cast(LPVOID Ptr, plpszString), CB_BVGMP, C_BVGMP)))
    If (GetLastError()) Then Return(FALSE)
    /' plpszString index definitions:
        plpszString[0] = path to return to
        plpszString[1] = file filter
        plpszString[2] = ofn.lpstrFile
        plpszString[3] = ofn.lpstrFileTitle
    '/
    *plpszString[BVGMP_RETURN] = CurDir()
    If (LoadString(hInst, IDS_FILT_VGMPLAY, plpszString[BVGMP_FILT], MAX_PATH) = 0) Then Return(FALSE)
    
    ''setup ofn
    Dim lpOfn As LPOPENFILENAME = Cast(LPOPENFILENAME, HeapAlloc(hOfn, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(OPENFILENAME))))
    If (lpOfn = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpOfn\t= 0x"; Hex(lpOfn, 8)
    #EndIf
    With *lpOfn
        .lStructSize        = SizeOf(OPENFILENAME)
        .hwndOwner          = hDlg
        .hInstance          = NULL
        .lpstrFilter        = Cast(LPCTSTR, plpszString[BVGMP_FILT])
        .lpstrCustomFilter  = NULL
        .nMaxCustFilter     = NULL
        .nFilterIndex       = 1
        .lpstrFile          = plpszString[BVGMP_FILE]
        .nMaxFile           = MAX_PATH
        .lpstrFileTitle     = plpszString[BVGMP_FILETITLE]
        .nMaxFileTitle      = MAX_PATH
        .lpstrInitialDir    = NULL
        .lpstrTitle         = NULL
        .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST)
        .nFileOffset        = NULL
        .nFileExtension     = NULL
        .lpstrDefExt        = NULL
    End With
    
    ''browse for VGMPlay.exe
    If (GetOpenFileName(lpOfn)) Then
        
        ''update UI
        If (SetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszString[BVGMP_FILE]) = FALSE) Then Return(FALSE)
        
    Else
        
        #If __FB_DEBUG__
            ? !"CommDlgExError\t= 0x"; Hex(CommDlgExtendedError(), 8)
        #EndIf
        
    End If
    
    ''return to current directory because GetOpenFileName has changed it
    ''FB's ChDir function returns non-zero on error.
    If (ChDir(*plpszString[BVGMP_RETURN])) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''free memory used for ofn
    If (HeapFree(hOfn, NULL, Cast(LPVOID, lpOfn)) = FALSE) Then Return(FALSE)
    
    ''free string list
    SetLastError(Cast(DWORD32, HeapFreePtrList(hOfn, Cast(LPVOID Ptr, plpszString), CB_BVGMP, C_BVGMP)))
    If (GetLastError()) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''destroy the heap
    If (HeapDestroy(hOfn) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function'/
/'
''called by PathsProc to update its UI to the current values
Private Function SetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg, 8)
        ? !"plpszValue\t= 0x"; Hex(plpszValue, 8)
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''set the values
    If (SetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszValue[PATH_VGMPLAY]) = FALSE) Then Return(FALSE)
    If (SetDlgItemText(hDlg, IDC_EDT_DEFAULTPATH, plpszValue[PATH_DEFAULT]) = FALSE) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
	''return
	SetLastError(ERROR_SUCCESS)
	Return(TRUE)
    
End Function

''called by PathsProc to save its UI values to the current config
Private Function GetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg, 8)
        ? !"plpszValue\t= 0x"; Hex(plpszValue, 8)
    #EndIf
    
    ''get values
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    GetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszValue[PATH_VGMPLAY], MAX_PATH)
    GetDlgItemText(hDlg, IDC_EDT_DEFAULTPATH, plpszValue[PATH_DEFAULT], MAX_PATH)
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
	''return
	SetLastError(ERROR_SUCCESS)
	Return(TRUE)
    
End Function
'/

/'Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND	''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''dialog init
            
            ''create tooltips
            If (CreateFileFiltToolTips(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''update display to current settings
            SetFileFiltProc(hWnd, dwFileFilt)
            
        Case WM_COMMAND     ''commands
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    
					''we don't need to poll individual buttons since GetFileFiltProc just checks each button's state
                    SendMessage(hwndPrsht, PSM_CHANGED, Cast(WPARAM, hWnd), 0)
                    
            End Select
            
        Case WM_NOTIFY      ''notifications
            
            Select Case (Cast(LPNMHDR, lParam)->code)   ''notification codes
                Case PSN_SETACTIVE                      ''page becoming active
                    
                    ''get page handle
                    hwndPrsht = Cast(HWND, Cast(LPNMHDR, lParam)->hwndFrom)
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    ''get values from sheet
                    If (GetFileFiltProc(hWnd, dwFileFilt) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                    ''save to registry
                    If (SaveConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                Case PSN_HELP                           ''user has pressed the help button
                    
                    ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_FILTHELP, IDS_MSGCAP_FILTHELP, MB_ICONINFORMATION)
                    
                Case PSN_QUERYCANCEL                    ''user has pressed the cancel button
                    
                    Dim dwCurrent As DWORD32
                    If (GetFileFiltProc(hWnd, dwCurrent) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                    If (dwCurrent <> dwFileFilt) Then PrpshCancelPrompt(hWnd)
                    
            End Select
            
        Case Else           ''otherwise
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

''called by FileFiltProc to create tooltips in response to WM_INITDIALOG
Private Function CreateFileFiltToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    ''create tooltips
    For i As UINT32 = 0 To 4
        If (CreateToolTip(hInstance, hDlg, (IDC_CHK_ARCHIVE + i), (IDS_TIP_ARCHIVE + i), TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    Next i
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''called by FileFiltProc to update its UI to the current values
Private Function SetFileFiltProc (ByVal hDlg As HWND, ByVal dwValue As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg, 8)
        ? !"dwValue\t= 0x"; Hex(dwValue, 8)
    #EndIf
    
    If (dwValue And DDL_ARCHIVE) Then 
        CheckDlgButton(hDlg, IDC_CHK_ARCHIVE, BST_CHECKED)
    Else
        CheckDlgButton(hDlg, IDC_CHK_ARCHIVE, BST_UNCHECKED)
    End If
    If (dwValue And DDL_HIDDEN) Then
        CheckDlgButton(hDlg, IDC_CHK_HIDDEN, BST_CHECKED)
    Else
        CheckDlgButton(hDlg, IDC_CHK_HIDDEN, BST_UNCHECKED)
    End If
    If (dwValue And DDL_SYSTEM) Then
        CheckDlgButton(hDlg, IDC_CHK_SYSTEM, BST_CHECKED)
    Else
        CheckDlgButton(hDlg, IDC_CHK_SYSTEM, BST_UNCHECKED)
    End If
    If (dwValue And DDL_READONLY) Then
        CheckDlgButton(hDlg, IDC_CHK_READONLY, BST_CHECKED)
    Else
        CheckDlgButton(hDlg, IDC_CHK_READONLY, BST_UNCHECKED)
    End If
    If (dwValue And DDL_EXCLUSIVE) Then
        CheckDlgButton(hDlg, IDC_CHK_EXCLUSIVE, BST_CHECKED)
    Else
        CheckDlgButton(hDlg, IDC_CHK_EXCLUSIVE, BST_UNCHECKED)
    End If
    
	''return
	SetLastError(ERROR_SUCCESS)
	Return(TRUE)
    
End Function

''called by FileFiltProc to save its UI values to the current config
Private Function GetFileFiltProc (ByVal hDlg As HWND, ByRef dwValue As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg, 8)
        ? !"dwValue\t= 0x"; Hex(dwValue, 8)
    #EndIf
    
    dwValue = DDL_DIRECTORY
    
    If (IsDlgButtonChecked(hDlg, IDC_CHK_ARCHIVE) = BST_CHECKED) Then dwValue = (dwValue Or DDL_ARCHIVE)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_HIDDEN) = BST_CHECKED) Then dwValue = (dwValue Or DDL_HIDDEN)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_SYSTEM) = BST_CHECKED) Then dwValue = (dwValue Or DDL_SYSTEM)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_READONLY) = BST_CHECKED) Then dwValue = (dwValue Or DDL_READONLY)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_EXCLUSIVE) = BST_CHECKED) Then dwValue = (dwValue Or DDL_EXCLUSIVE)
	
	''return
	SetLastError(ERROR_SUCCESS)
	Return(TRUE)
    
End Function


Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND    ''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''initialize dialog
            
            CreateToolTip(hInstance, hWnd, IDC_CHK_PREFERJAPTAG, IDS_TIP_PREFERJAPTAG, TTS_ALWAYSTIP, NULL)
			
			''disable windows until chip-settings.dll is done
			EnableWindow(GetDlgItem(hWnd, IDC_CHK_LOGSOUND), FALSE)
			EnableWindow(GetDlgItem(hWnd, IDC_CHK_PREFERJAPTAG), FALSE)
			EnableWindow(GetDlgItem(hWnd, IDC_BTN_CHIPSETTINGS), FALSE)
			
        Case WM_COMMAND     ''commands
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    Select Case LoWord(wParam)
                        Case IDC_BTN_CHIPSETTINGS
                            
                            ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_NYI, IDS_MSGCAP_NYI, MB_ICONWARNING)
                            
                    End Select
                    
                    SendMessage(hwndPrsht, PSM_CHANGED, Cast(WPARAM, hWnd), NULL)
                    
            End Select
            
        Case WM_NOTIFY      ''notifications
            
            Select Case (Cast(LPNMHDR, lParam)->code)   ''notification codes
                Case PSN_SETACTIVE                      ''page becoming active
                    
                    ''get page handle
                    hwndPrsht = Cast(HWND, Cast(LPNMHDR, lParam)->hwndFrom)
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError())
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    'ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_NYI, IDS_MSGCAP_NYI, MB_ICONWARNING)
                    
                Case PSN_HELP                           ''user has pressed the help button
                    
                    ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_NYI, IDS_MSGCAP_NYI, MB_ICONWARNING)
                    
                Case PSN_QUERYCANCEL                    ''user has pressed the cancel button
                    
                    PrpshCancelPrompt(hWnd)
                    
            End Select
            
        Case Else           ''otherwise
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

''displays a cancel prompt for the options property sheet
Function PrpshCancelPrompt (ByVal hDlg As HWND) As DWORD32
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
    #EndIf
    
    Dim dwReturn As DWORD32 = ProgMsgBox(hInstance, hDlg, IDS_MSGTXT_CHANGES, IDS_MSGCAP_CHANGES, MB_ICONWARNING Or MB_YESNOCANCEL)
    Select Case dwReturn    ''button pressed
        Case IDYES          ''"Yes" button, save settings and close
            
            ''send a PSN_APPLY notification to the property sheet and let it close
            Dim nmh As NMHDR
            nmh.code = PSN_APPLY
            SendMessage(hDlg, WM_NOTIFY, NULL, Cast(LPARAM, @nmh))
            SetWindowLong(hDlg, DWL_MSGRESULT, Cast(LONG32, FALSE))
            
        Case IDNO           ''"No" button, close
            
            ''allow the property sheet to close
            SetWindowLong(hDlg, DWL_MSGRESULT, Cast(LONG32, FALSE))
            
        Case IDCANCEL       ''"Cancel" button, do not close
            
            ''stop the property sheet from closing
            SetWindowLong(hDlg, DWL_MSGRESULT, Cast(LONG32, TRUE))
            
    End Select
    
    Return(dwReturn)
    
End Function
'/
''starts VGMPlay with the specified file
Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? "lpszFile", "= 0x"; Hex(lpszFile, 8)
        ? "*lpszFile", "= "; *lpszFile
    #EndIf
    
	''set loading cursor
    Dim hPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
	
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
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
    
	''release the heap lock
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
	''restore the cursor
    SetCursor(hPrev)
	
	''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''memory macro functions:
''initializes memory
Function InitMem () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate memory
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszPath), CB_PATH, C_PATH)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszStrRes), CB_STRRES, C_STRRES)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    
    ''check allocation
    If ((plpszPath = NULL) Or (plpszStrRes = NULL)) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
	''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''frees memory
Function FreeMem () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''free memory
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszPath), CB_PATH, C_PATH)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszStrRes), CB_STRRES, C_STRRES)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
	''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''loads the needed string resources
Function LoadStringResources (ByVal hInst As HINSTANCE) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst, 8)
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''load misc strings
    For iMisc As UINT32 = 0 To 1
        If (LoadString(hInst, (IDS_APPNAME + iMisc), plpszStrRes[STR_APPNAME + iMisc], CCH_STRRES) = 0) Then Return(FALSE)
    Next iMisc
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

/'''config functions:
''loads the config from the registry
Function LoadConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''open the program's registry key
    Dim dwKeyDisp As DWORD32    ''disposition value for OpenProgHKey
    Dim hkProgKey As HKEY       ''handle to the program's registry key 
    SetLastError(Cast(DWORD32, OpenProgHKey(@hkProgKey, "VGMPlayGUI"/'plpszStrRes[STR_APPNAME]'/, NULL, KEY_ALL_ACCESS, @dwKeyDisp)))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the config
    Dim cbValue As DWORD32          ''size of items to write to the registry
    Dim plpszKeyName As LPTSTR Ptr  ''pointer to a buffer for the key names
    
    If (dwKeyDisp = REG_OPENED_EXISTING_KEY) Then
        
        ''allocate a buffer for a list of strings to hold the key names
        SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, C_KEY)))
        If (GetLastError()) Then Return(FALSE)
        
        ''load the key names
        For iKey As UINT32 = 0 To (C_KEY - 1)
            If (LoadString(hInstance, Cast(UINT32, (IDS_REG_VGMPLAYPATH + iKey)), plpszKeyName[iKey], CCH_KEY) = 0) Then Return(FALSE)
        Next iKey
        
        ''load the config
        cbValue = CB_PATH
        SetLastError(Cast(DWORD32, RegQueryValueEx(hkProgKey, plpszKeyName[KEY_VGMPLAYPATH], NULL, NULL, Cast(LPBYTE, plpszPath[PATH_VGMPLAY]), @cbValue)))
        If (GetLastError()) Then Return(FALSE)
        
        cbValue = CB_PATH
        SetLastError(Cast(DWORD32, RegQueryValueEx(hkProgKey, plpszKeyName[KEY_DEFAULTPATH], NULL, NULL, Cast(LPBYTE, plpszPath[PATH_DEFAULT]), @cbValue)))
        If (GetLastError()) Then Return(FALSE)
        
        cbValue = SizeOf(DWORD32)
        SetLastError(Cast(DWORD32, RegQueryValueEx(hkProgKey, plpszKeyName[KEY_FILEFILTER], NULL, NULL, Cast(LPBYTE, @dwFileFilt), @cbValue)))
        If (GetLastError()) Then Return(FALSE)
        
        ''free the allocated buffer for the key names
        SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, C_KEY)))
        If (GetLastError()) Then Return(FALSE)
        
    Else
        
        If (SetDefConfig() = FALSE) Then Return(FALSE)
        
    End If
    
    ''close the key
    SetLastError(Cast(DWORD32, RegCloseKey(hkProgKey)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    
	''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''saves the paths to the registry
Function SaveConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''open the program's registry key
    Dim hkProgKey As HKEY   ''handle to the program's registry key
    SetLastError(Cast(DWORD32, OpenProgHKey(@hkProgKey, "VGMPlayGUI"/'plpszStrRes[STR_APPNAME]'/, NULL, KEY_WRITE, NULL)))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate a buffer for a list of strings to hold the key names
    Dim plpszKeyName As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, C_KEY)))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the key names
    For iKey As UINT32 = 0 To (C_KEY - 1)
        If (LoadString(hInstance, Cast(UINT32, (IDS_REG_VGMPLAYPATH + iKey)), plpszKeyName[iKey], CCH_KEY) = 0) Then Return(FALSE)
    Next iKey
    
    ''save the configuration to the registry
    SetLastError(Cast(DWORD32, RegSetValueEx(hkProgKey, plpszKeyName[KEY_VGMPLAYPATH], NULL, REG_SZ, Cast(LPBYTE, plpszPath[PATH_VGMPLAY]), CB_PATH)))
    If (GetLastError()) Then Return(FALSE)
    
    SetLastError(Cast(DWORD32, RegSetValueEx(hkProgKey, plpszKeyName[KEY_DEFAULTPATH], NULL, REG_SZ, Cast(LPBYTE, plpszPath[PATH_DEFAULT]), CB_PATH)))
    If (GetLastError()) Then Return(FALSE)
    
    SetLastError(Cast(DWORD32, RegSetValueEx(hkProgKey, plpszKeyName[KEY_FILEFILTER], NULL, REG_DWORD, Cast(LPBYTE, @dwFileFilt), SizeOf(DWORD32))))
    If (GetLastError()) Then Return(FALSE)
    
    ''free the allocated buffer for the key names
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, C_KEY)))
    If (GetLastError()) Then Return(FALSE)
    
    ''close the key
    SetLastError(Cast(DWORD32, RegCloseKey(hkProgKey)))
    If (GetLastError()) Then Return(FALSE)
    
	''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
	
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''sets the default config values
Function SetDefConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "/"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''set defaults
    *plpszPath[PATH_VGMPLAY]    = ""
    *plpszPath[PATH_DEFAULT]    = ""
    dwFileFilt                  = DDL_DIRECTORY
    
	''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''save the default configuration
    If (SaveConfig() = FALSE) Then Return(FALSE)
	
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function'/

''EOF

