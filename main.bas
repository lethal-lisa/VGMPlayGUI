/'
    
    main.bas
    
    VGMPlayGUI v2 - Main module.
    
    Compile with:
        fbc -s gui "main.bas" "resource.rc" -x "VGMPlayGUI.exe"
    
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
lpszCmdLine = GetCommandLine()
#If __FB_DEBUG__
    ? "hInstance", "= 0x"; Hex(hInstance, 8)
    ? "lpszCmdLine", "= 0x"; Hex(lpszCmdLine, 8)
    ? "Command line:", Chr(34); *lpszCmdLine; Chr(34)
#EndIf
InitCommonControls()

''call WinMain
Dim uExitCode As UINT32 = WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL)

''exit
#If __FB_DEBUG__
    ? "Exit code", "= 0x" + Hex(uExitCode, 8)
#EndIf
ExitProcess(uExitCode)
End(uExitCode)

''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''declare local variables
    Dim msg As MSG                  ''message
    Dim wcxMainClass As WNDCLASSEX  ''class information for MainClass
    
    ''setup and register classes
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
    
    ''create the application heap
    hHeap = HeapCreate(NULL, NULL, NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then PostQuitMessage(SysErrMsgBox(NULL, GetLastError(), NULL))
    
    ''initialize memory
    If (InitMem() = FALSE) Then PostQuitMessage(SysErrMsgBox(NULL, GetLastError(), NULL))
    
    ''load strings
    If (LoadStringResources(hInst) = FALSE) Then PostQuitMessage(SysErrMsgBox(NULL, GetLastError(), NULL))
    
    ''load config from registry
    If (LoadConfig() = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
    
    ''create, show, and update the main window
    StartMainDialog(hInst, nShowCmd, NULL)
    
    ''start message loop
    While (GetMessage(@msg, hWin, 0, 0) = TRUE)
        If (IsDialogMessage(hWin, @msg) = FALSE) Then
            TranslateMessage(@msg)
            DispatchMessage(@msg)
        End If
    Wend
    
    ''unregister window classes
    UnregisterClass(@MainClass, hInst)
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''subroutine used to start the main dialog. called by WinMain
Sub StartMainDialog (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM)
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''create, show, and update the main dialog
    DialogBoxParam(hInst, MAKEINTRESOURCE(IDD_MAIN), NULL, @MainProc, lParam)
    hWin = FindWindow(@MainClass, NULL)
    ShowWindow(hWin, nShowCmd)
    SetForegroundWindow(hWin)
    SetActiveWindow(hWin)
    UpdateWindow(hWin)
    
End Sub

''dialog procedures
Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''process messages
    Select Case uMsg                ''messages:
        Case WM_CREATE              ''creating window
            
            ''set the program's icon and set a loading cursor
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_VGMPLAYGUI))))
            SetCursor(LoadCursor(NULL, IDC_APPSTARTING))
            
            ''create child windows
            If (CreateMainChildren(hWnd) = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
            
        Case WM_DESTROY             ''destroying window
            
            ''close handles, free allocated memory, and destroy the heap
            If (FreeMem() = FALSE) Then PostQuitMessage(Cast(INT32, GetLastError()))
            If (HeapDestroy(hHeap) = FALSE) Then PostQuitMessage(Cast(INT32, GetLastError()))
            
            ''post quit message with success code
            PostQuitMessage(ERROR_SUCCESS)
            
        Case WM_INITDIALOG          ''initializing dialog
            
            ''initialize directory listings to default directory
            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (PopulateLists(hWnd, plpszPath[PATH_DEFAULT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
            ''set the default keyboard focus to IDC_LST_MAIN
            If (SetFocus(GetDlgItem(hWnd, IDC_LST_MAIN)) = Cast(HWND, NULL)) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
            ''set the arrow cursor
            SetCursor(LoadCursor(NULL, IDC_ARROW))
            
            ''make sure VGMPlay's path is valid
            If (PathFileExists(plpszPath[PATH_VGMPLAY]) = FALSE) Then
                If (ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_VGMPMISS, IDS_MSGCAP_VGMPMISS, MB_YESNO Or MB_ICONWARNING) = IDYES) Then
                    ''TODO: fix error checking here
                    DoOptionsPropSheet(hInstance, hWnd)
                End If
            End If
            
        Case WM_CLOSE               ''window is being closed
            
            ''destroy main window
            If (DestroyWindow(hWnd) = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
            
        Case WM_COMMAND             ''command has been issued
            
            Select Case HiWord(wParam)                          ''event:
                Case BN_CLICKED                                 ''a button has been pressed
                    Select Case LoWord(wParam)              ''button IDs:
                        Case IDM_ROOT                       ''change to drive root
                            
                            ''change directory to the current drive's root
                            If (PopulateLists(hWnd, "\") = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDM_EXIT                       ''exit program
                            
                            ''send a WM_CLOSE message to the main window
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_OPTIONS                    ''start the options property sheet
                            
                            DoOptionsPropSheet(hInstance, hWnd)
                            
                        Case IDM_ABOUT                      ''display the about message
                            
                            ''setup messageboxparams
                            Dim mbp As MSGBOXPARAMS
                            ZeroMemory(@mbp, SizeOf(mbp))
                            With mbp
                                .cbSize             = SizeOf(mbp)
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
                            
                        Case IDC_BTN_PLAY                   ''start VGMPlay
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            GetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT], CCH_PATH)
                            If (StartVGMPlay(plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_GO                     ''change to a specified directory
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            GetDlgItemText(hWnd, IDC_EDT_PATH, plpszPath[PATH_CURRENT], MAX_PATH)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_UP, IDM_UP             ''move up one directory
                            
                            If (PopulateLists(hWnd, "..") = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_REFRESH, IDM_REFRESH   ''refresh the current directory listing
                            
                            If (PopulateLists(hWnd, ".") = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                    End Select
                    
                Case LBN_DBLCLK                                 ''the user has double-clicked in a listbox
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get selected item, change directories, and refresh the listboxes
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_MAIN)
                            If (PathIsDirectory(Cast(LPCTSTR, plpszPath[PATH_CURRENT])) = Cast(BOOL, FILE_ATTRIBUTE_DIRECTORY)) Then
                                
                                ''change to selected directory and refresh the listboxes
                                If (GetLastError() = ERROR_SUCCESS) Then
                                    If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                                Else
                                    SysErrMsgBox(hWnd, GetLastError(), NULL)
                                End If
                                
                            End If
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                    End Select
                    
                Case LBN_SELCHANGE                              ''a listbox selection has changed
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get the selected item and update the UI
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_MAIN)
                            SetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT])
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_LST_DRIVES     ''drives list
                            
                            ''get the selected item and change drives
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            DlgDirSelectEx(hWnd, plpszPath[PATH_CURRENT], MAX_PATH, IDC_LST_DRIVES)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                    End Select
                    
                Case Cast(UINT32, LBN_ERRSPACE), EN_ERRSPACE    ''a listbox or edit control is out of memory
                    
                    ''display error message, and terminate program
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY, NULL)
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
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR), @rcSbr) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            rcParent.bottom -= rcSbr.bottom
            
            ''resize the child windows
            If (EnumChildWindows(hWnd, @ResizeChildren, Cast(LPARAM, @rcParent)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
            Return(Cast(LRESULT, TRUE))
            
        Case WM_WINDOWPOSCHANGING   ''window position is changing
            
            ''get windowpos structure from lParam
            Dim pwp As WINDOWPOS Ptr = Cast(WINDOWPOS Ptr, lParam)
            
            #If __FB_DEBUG__
                ? "Window Pos Changing:"
                ? "(x, y)", "= ("; Str(pwp->x); ", "; Str(pwp->y); ")"
                ? "(cx, cy)", "= ("; Str(pwp->cx); ", "; Str(pwp->cy); ")"
            #EndIf
            
            ''prevent window from getting too small
            If (pwp->cx < MIN_SIZE_X) Then pwp->cx = MIN_SIZE_X
            If (pwp->cy < MIN_SIZE_Y) Then pwp->cy = MIN_SIZE_Y
            
        Case WM_CONTEXTMENU         ''display the context menu
            
            If (DisplayContextMenu(hWnd, LoWord(lParam), HiWord(lParam)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
        Case Else                   ''otherwise
            
            ''use default window procedure
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return
    Return(0)
    
End Function

''creates child windows for the main dialog
Function CreateMainChildren (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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

Function CreateMainToolTips (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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
Function ResizeChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
    
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

''displays a context menu in the main dialog
Function DisplayContextMenu (ByVal hDlg As HWND, ByVal x As WORD, ByVal y As WORD) As BOOL
    
    #If __FB_DEBUG__
    ? "Calling:", __FUNCTION__
    #EndIf
    
    ''declare local variables
    Dim hMenu As HMENU      ''top level menu
    Dim hMenuSub As HMENU   ''sub menu to return
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
	''get a handle for the child window that was clicked in
    Dim ptMouse As Point
    With ptMouse
        .x = x
        .y = y
    End With
    If (ScreenToClient(hDlg, @ptMouse) = FALSE) Then Return(FALSE)
    Dim hwndChild As HWND = ChildWindowFromPoint(hDlg, ptMouse)
    If (hwndChild = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''select the child window's appropriate context menu
    Select Case GetWindowLong(hwndChild, GWL_ID)
        Case IDC_LST_MAIN
			hMenu = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUMAIN))
			If (hMenu = INVALID_HANDLE_VALUE) Then Return(FALSE)
			hMenuSub = GetSubMenu(hMenu, 1)
        Case IDC_LST_DRIVES
			hMenu = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUCONTEXT))
			If (hMenu = INVALID_HANDLE_VALUE) Then Return(FALSE)
            hMenuSub = GetSubMenu(hMenu, 0)
    End Select
    
    ''display context menu
    If (TrackPopupMenu(hMenuSub, TPM_LEFTALIGN Or TPM_TOPALIGN Or TPM_RIGHTBUTTON Or TPM_NOANIMATION, x, y, 0, hDlg, NULL) = FALSE) Then
		DestroyMenu(hMenuSub)	''destroy the sub-menu
        DestroyMenu(hMenu)  	''destroy the top-level menu
        Return(FALSE)       	''return FALSE
    End If
    
    ''destroy the created menu objects
	If (DestroyMenu(hMenuSub) = FALSE) Then Return(FALSE)
    If (DestroyMenu(hMenu) = FALSE) Then Return(FALSE)
    
    ''restore the previous cursor
    SetCursor(hCurPrev)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''changes directories and refreshes directory listings
Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''load and set a waiting cursor
    Dim hPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''make sure path exists and is a directory
    If (PathFileExists(lpszPath) = FALSE) Then Return(FALSE)
    If (PathIsDirectory(lpszPath) = FALSE) Then Return(FALSE)
    
    ''store previous path
    '*plpszPath[PATH_PREVIOUS] = CurDir()
    
    ''change directories
    If (ChDir(*lpszPath)) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''update UI
    SetDlgItemText(hDlg, IDC_EDT_PATH, CurDir())
    SetDlgItemText(hDlg, IDC_EDT_FILE, NULL)
    
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

''starts the options property sheet
Function DoOptionsPropSheet (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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
            'CreateToolTip(hInstance, hWnd, IDC_EDT_VGMPLAYPATH, IDS_TIP_VGMPLAYPATH, TTS_ALWAYSTIP, NULL)
            'CreateToolTip(hInstance, hWnd, IDC_EDT_DEFAULTPATH, IDS_TIP_DEFAULTPATH, TTS_ALWAYSTIP, NULL)
            If (CreatePathsToolTips(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
            ''set text in path options
            SetPathsProc(hWnd, plpszPath)
            
        Case WM_COMMAND     ''commands
            
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    
                    Select Case LoWord(wParam)      ''button IDs:
                        Case IDC_BTN_VGMPLAYPATH    ''browse for vgmplay
							
                            If (BrowseVGMPlay(hInstance, hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_DEFAULTPATH    ''set default path to current one
							
							Dim szCurDir As ZString*MAX_PATH = CurDir()
							If (SetDlgItemText(hWnd, IDC_EDT_DEFAULTPATH, @szCurDir) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
							
                    End Select
                    
                Case EN_CHANGE          ''edit control changing
                    
                    SendMessage(hwndPrsht, PSM_CHANGED, Cast(WPARAM, hWnd), 0)
                    
                Case EN_ERRSPACE        ''edit control is out of space
                    
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY, NULL)
                    
            End Select
            
        Case WM_NOTIFY      ''notifications
            
            Select Case (Cast(LPNMHDR, lParam)->code)   ''notification codes
                Case PSN_SETACTIVE                      ''page becoming active
                    
                    ''get page handle
                    hwndPrsht = Cast(HWND, Cast(LPNMHDR, lParam)->hwndFrom)
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    ''let page become inactive
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    ''get settings from dialog
                    If (GetPathsProc(hWnd, plpszPath) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
                    ''save settings to the registry
                    If (SaveConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
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
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''create tooltips
    If (CreateToolTip(hInstance, hDlg, IDC_EDT_VGMPLAYPATH, IDS_TIP_VGMPLAYPATH, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_EDT_DEFAULTPATH, IDS_TIP_DEFAULTPATH, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''called by PathsProc to start the browse for VGMPlay dialog
Private Function BrowseVGMPlay (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''store current path to return to upon function exit
    Dim lpszReturnTo As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (MAX_PATH * SizeOf(TCHAR)))))
    If (lpszReturnTo = NULL) Then Return(FALSE)
    *lpszReturnTo = CurDir()
    
    ''load file filter
    Dim lpszFilter As LPTSTR = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (MAX_PATH * SizeOf(TCHAR)))))
    If (lpszFilter = NULL) Then Return(FALSE)
    If (LoadString(hInst, IDS_FILT_VGMPLAY, lpszFilter, 512) = 0) Then Return(FALSE)
    
    ''setup ofn
    Dim ofn As OPENFILENAME
    ZeroMemory(@ofn, SizeOf(OPENFILENAME))
    With ofn
        .lStructSize        = SizeOf(OPENFILENAME)
        .hwndOwner          = hDlg
        .hInstance          = hInst
        .lpstrFilter        = Cast(LPCTSTR, lpszFilter)
        .lpstrCustomFilter  = NULL
        .nMaxCustFilter     = NULL
        .nFilterIndex       = 1
        .lpstrFile          = plpszPath[PATH_VGMPLAY]
        .nMaxFile           = MAX_PATH
        .lpstrFileTitle     = NULL
        .nMaxFileTitle      = NULL
        .lpstrInitialDir    = NULL
        .lpstrTitle         = NULL
        .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_NONETWORKBUTTON Or OFN_PATHMUSTEXIST Or OFN_READONLY)
        .nFileOffset        = NULL
        .nFileExtension     = NULL
        .lpstrDefExt        = NULL
    End With
    
    ''browse for VGMPlay.exe
    GetOpenFileName(@ofn)
    If (SetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszPath[PATH_VGMPLAY]) = FALSE) Then Return(FALSE)
    
    ''free memory allocated for lpszFilter
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszFilter)) = FALSE) Then Return(FALSE)
    
    ''return to current directory
    If (ChDir(*lpszReturnTo)) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''free memory allocated for lpszReturnTo
    If (HeapFree(hHeap, NULL, Cast(LPVOID, lpszReturnTo)) = FALSE) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''called by PathsProc to update its UI to the current values
Private Function SetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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
        ? "Calling:", __FUNCTION__
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

Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND	''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''dialog init
            
            ''create tooltips
            For i As UINT32 = 0 To 4
                If (CreateToolTip(hInstance, hWnd, (IDC_CHK_ARCHIVE + i), (IDS_TIP_ARCHIVE + i), TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then
                    SysErrMsgBox(hWnd, GetLastError(), NULL)
                    Exit For
                End If
            Next i
            
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
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    ''get values from sheet
                    If (GetFileFiltProc(hWnd, dwFileFilt) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
                    ''save to registry
                    'If (SaveConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
                Case PSN_HELP                           ''user has pressed the help button
                    
                    ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_FILTHELP, IDS_MSGCAP_FILTHELP, MB_ICONINFORMATION)
                    
                Case PSN_QUERYCANCEL                    ''user has pressed the cancel button
                    
                    Dim dwCurrent As DWORD32
                    If (GetFileFiltProc(hWnd, dwCurrent) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    If (dwCurrent <> dwFileFilt) Then PrpshCancelPrompt(hWnd)
                    
            End Select
            
        Case Else           ''otherwise
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

Function SetFileFiltProc (ByVal hDlg As HWND, ByVal dwValue As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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

Function GetFileFiltProc (ByVal hDlg As HWND, ByRef dwValue As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
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

Function PrpshCancelPrompt (ByVal hDlg As HWND) As DWORD32
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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

''starts VGMPlay
Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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
        ? "Calling:", __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate memory
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszPath), CB_PATH, NUM_PATH)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszStrRes), CB_STRRES, NUM_STRRES)))
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
        ? "Calling:", __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''free memory
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszPath), CB_PATH, NUM_PATH)))
    If (GetLastError() <> ERROR_SUCCESS) Then Return(FALSE)
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszStrRes), CB_STRRES, NUM_STRRES)))
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
        ? "Calling:", __FUNCTION__
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

''config functions:
''loads the config from the registry
Function LoadConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
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
        SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, NUM_KEY)))
        If (GetLastError()) Then Return(FALSE)
        
        ''load the key names
        For iKey As UINT32 = 0 To (NUM_KEY - 1)
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
        SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, NUM_KEY)))
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
        ? "Calling:", __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''open the program's registry key
    Dim hkProgKey As HKEY   ''handle to the program's registry key
    SetLastError(Cast(DWORD32, OpenProgHKey(@hkProgKey, "VGMPlayGUI"/'plpszStrRes[STR_APPNAME]'/, NULL, KEY_WRITE, NULL)))
    If (GetLastError()) Then Return(FALSE)
    
    ''allocate a buffer for a list of strings to hold the key names
    Dim plpszKeyName As LPTSTR Ptr
    SetLastError(Cast(DWORD32, HeapAllocPtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, NUM_KEY)))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the key names
    For iKey As UINT32 = 0 To (NUM_KEY - 1)
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
    SetLastError(Cast(DWORD32, HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, NUM_KEY)))
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
        ? "Calling:", __FUNCTION__
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
    
End Function

''EOF
