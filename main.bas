/'
    
    main.bas
    
    VGMPlayGUI v2 - Main module.
    
    Compile with:
        fbc -s -gui -mt "main.bas" "resource.rc" -x "VGMPlayGUI.exe"
    
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
InitCommonControls()

''call WinMain
Dim uExitCode As UINT32 = WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL)

''exit
ExitProcess(uExitCode)
End(uExitCode)


''main function
Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    ''declare local variables
    Dim msg As MSG                  ''message
    Dim wcxMainClass As WNDCLASSEX  ''class information for MainClass
    
    ''setup and register classes
    ZeroMemory(@wcxMainClass, SizeOf(wcxMainClass))
    With wcxMainClass
        .cbSize         = SizeOf(wcxMainClass)
        .style          = (CS_HREDRAW Or CS_VREDRAW)
        .lpfnWndProc    = @MainProc
        .cbClsExtra     = 0
        .cbWndExtra     = DLGWINDOWEXTRA
        .hInstance      = hInst
        .hIcon          = LoadIcon(hInst, MAKEINTRESOURCE(IDI_VGMPLAYGUI))
        .hCursor        = LoadCursor(NULL, IDC_ARROW)
        .hbrBackground  = Cast(HBRUSH, (COLOR_BTNFACE + 1))
        .lpszMenuName   = MAKEINTRESOURCE(IDR_MENU1)
        .lpszClassName  = @MainClass
        .hIconSm        = .hIcon
    End With
    RegisterClassEx(@wcxMainClass)
    
    ''create, show, and update the main window
    StartMainDialog(hInst, nShowCmd, NULL)
    
    ''start message loop
    While (GetMessage(@msg, hWin, 0, 0) = TRUE)
        If (IsDialogMessage(hWin, @msg) = 0) Then
            TranslateMessage(@msg)
            DispatchMessage(@msg)
        End If
    Wend
    
    ''return
    UnregisterClass(@MainClass, hInst)
    Return(msg.wParam)
    
End Function

''subroutine used to start the main dialog. called by WinMain
Sub StartMainDialog (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM)
    
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
            
            ''create the heap, init memory, and load resources
            hHeap = HeapCreate(0, 0, 0)
            If (InitMem() = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (LoadStringResources(hInstance) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
            ''open program hkey and load settings
            Dim dwKeyDisp As DWORD32    ''key disposition for OpenProgHKey
            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (OpenProgHKey(phkProgKey, plpszStrRes[STR_APPNAME], KEY_ALL_ACCESS, @dwKeyDisp) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (dwKeyDisp = REG_OPENED_EXISTING_KEY) Then
                If (LoadConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            Else
                If (SetDefConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            End If
            
            ''create child windows
            If (CreateMainChildren(hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
        Case WM_DESTROY             ''destroying window
            
            ''close handles, free allocated memory, and destroy the heap
            If (CheckLongErrCode(RegCloseKey(*phkProgKey)) = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
            If (FreeMem() = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
            If (HeapDestroy(hHeap) = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
            
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
                    DoOptionsPropSheet(hWnd)
                End If
            End If
            
        Case WM_CLOSE               ''window is being closed
            
            ''destroy main window
            If (DestroyWindow(hWnd) = FALSE) Then SysErrMsgBox(NULL, GetLastError(), NULL)
            
        Case WM_COMMAND             ''command has been issued
            Select Case HiWord(wParam)          ''event:
                Case BN_CLICKED                 ''a button has been pressed
                    Select Case LoWord(wParam)  ''button ID's:
                        Case IDM_ROOT           ''change to drive root
                            
                            ''change directory to the current drive's root
                            If (PopulateLists(hWnd, "\") = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDM_EXIT           ''exit program
                            
                            ''send a WM_CLOSE message to the main window
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_OPTIONS        ''start the options property sheet
                            
                            DoOptionsPropSheet(hWnd)
                            
                        Case IDM_ABOUT          ''display the about message
                            
                            ''declare and setup mbp
                            Dim mbp As MSGBOXPARAMS
                            ZeroMemory(@mbp, SizeOf(mbp))
                            With mbp
                                .cbSize             = SizeOf(mbp)
                                .hwndOwner          = hWnd
                                .hInstance          = hInstance
                                .lpszText           = MAKEINTRESOURCE(IDS_MSGTXT_ABOUT)
                                .lpszCaption        = MAKEINTRESOURCE(IDS_MSGCAP_ABOUT)
                                .dwStyle            = (MB_OK Or MB_DEFBUTTON1 Or MB_APPLMODAL Or MB_SETFOREGROUND Or MB_USERICON)
                                .lpszIcon           = MAKEINTRESOURCE(IDI_KAZUSOFT)
                                .dwContextHelpId    = NULL
                                .lpfnMsgBoxCallback = NULL
                                .dwLanguageId       = LANG_NEUTRAL
                            End With
                            
                            ''display message box
                            MessageBeep(MB_ICONASTERISK)
                            MessageBoxIndirect(@mbp)
                            
                        Case IDC_BTN_PLAY       ''start VGMPlay
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            GetDlgItemText(hWnd, IDC_EDT_FILE, plpszPath[PATH_CURRENT], CCH_PATH)
                            If (StartVGMPlay(plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_GO         ''change to a specified directory
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            GetDlgItemText(hWnd, IDC_EDT_PATH, plpszPath[PATH_CURRENT], MAX_PATH)
                            If (PopulateLists(hWnd, plpszPath[PATH_CURRENT]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_BACK       ''move up one directory
                            
                            If (PopulateLists(hWnd, "..") = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_REFRESH    ''refresh the current directory listing
                            
                            If (PopulateLists(hWnd, ".") = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                    End Select
                    
                Case LBN_DBLCLK                 ''the user has double-clicked in a listbox
                    Select Case LoWord(wParam)  ''listbox ID's:
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
                    
                Case LBN_SELCHANGE              ''a listbox selection has changed
                    Select Case LoWord(wParam)  ''listbox ID's:
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
                    
                Case Cast(UINT32, LBN_ERRSPACE) ''a listbox is out of memory
                    
                    ''display error message, and terminate program
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY, NULL)
                    If (DestroyWindow(hWnd) = FALSE) Then SysErrMsgBox(NULL, NULL, NULL)
                    
                Case EN_ERRSPACE                ''an editbox is out of memory
                    
                    ''display error message, and terminate program
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY, NULL)
                    If (DestroyWindow(hWnd) = FALSE) Then SysErrMsgBox(NULL, NULL, NULL)
                    
            End Select
            
        Case WM_SIZE                ''window has been resized
            
            ''declare local variables
            Dim rcSbr As RECT       ''statusbar rect
            Dim rcParent As RECT    ''main dialog rect
            
            ''get rects for statusbar and main dialog, and subtract the statusbar's height from that of the main window
            If (GetClientRect(hWnd, @rcParent) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR), @rcSbr) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            rcParent.bottom -= rcSbr.bottom
            
            ''resize the child windows
            If (EnumChildWindows(hWnd, @ResizeChildren, Cast(LPARAM, @rcParent)) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
            
        Case WM_WINDOWPOSCHANGING   ''window position is changing
            
            ''get windowpos structure from lParam
            Dim pwp As WINDOWPOS Ptr = Cast(WINDOWPOS Ptr, lParam)
            
            ''prevent window from getting too small
            If (pwp->cx < MIN_SIZE_X) Then pwp->cx = MIN_SIZE_X
            If (pwp->cy < MIN_SIZE_Y) Then pwp->cy = MIN_SIZE_Y
            
        Case WM_CONTEXTMENU         ''display the context menu
            
            DisplayContextMenu(hWnd, LoWord(lParam), HiWord(lParam))
            
        Case Else                   ''otherwise
            
            ''use default window procedure
            Return(DefWindowProc(hWnd, uMsg, wParam, lParam))
            
    End Select
    
    ''return
    Return(0)
    
End Function

''creates child windows for the main dialog
Function CreateMainChildren (ByVal hDlg As HWND) As BOOL
    
    ''create child windows
    CreateWindowEx(NULL, STATUSCLASSNAME, NULL, WS_CHILD Or WS_VISIBLE Or SBARS_SIZEGRIP Or SBARS_TOOLTIPS, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_SBR), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTBOX, NULL, WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_TABSTOP Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_HASSTRINGS Or LBS_SORT, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_LST_MAIN), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTBOX, NULL, WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_TABSTOP Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_HASSTRINGS Or LBS_SORT, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_LST_DRIVES), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_EDIT, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or ES_LEFT Or ES_AUTOHSCROLL, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_EDT_FILE), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER Or BS_DEFPUSHBUTTON Or BS_ICON, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_PLAY), hInstance, NULL)
    CreateWindowEx(WS_EX_CLIENTEDGE, WC_EDIT, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or ES_LEFT Or ES_AUTOHSCROLL, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_EDT_PATH), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, "Go", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_GO), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, "[..]", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_BACK), hInstance, NULL)
    CreateWindowEx(NULL, WC_BUTTON, "[.]", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_REFRESH), hInstance, NULL)
    
    ''set IDI_PLAY to IDC_BTN_PLAY
    SendMessage(GetDlgItem(hDlg, IDC_BTN_PLAY), BM_SETIMAGE, IMAGE_ICON, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_PLAY))))
    
    ''create tooltips
    CreateToolTip(hDlg, IDC_LST_DRIVES, IDS_TIP_DRIVELIST, TTS_ALWAYSTIP, NULL)
    CreateToolTip(hDlg, IDC_BTN_PLAY, IDS_TIP_PLAYBTN, TTS_ALWAYSTIP, NULL)
    CreateToolTip(hDlg, IDC_BTN_GO, IDS_TIP_GOBTN, TTS_ALWAYSTIP, NULL)
    CreateToolTip(hDlg, IDC_BTN_BACK, IDS_TIP_BACKBTN, TTS_ALWAYSTIP, NULL)
    CreateToolTip(hDlg, IDC_BTN_REFRESH, IDS_TIP_REFRESHBTN, TTS_ALWAYSTIP, NULL)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''creates a tooltip and associates it with a control
Function CreateToolTip (ByVal hDlg As HWND, ByVal dwToolID As DWORD32, ByVal wTextID As WORD, ByVal dwStyle As DWORD32, ByVal uFlags As UINT32) As HWND
    
    ''get tool window
    Dim hwndTool As HWND = GetDlgItem(hDlg, dwToolID)
    If (hwndTool = INVALID_HANDLE_VALUE) Then Return(Cast(HWND, NULL))
    
    ''create tip window
    Dim hwndTip As HWND = CreateWindowEx(NULL, TOOLTIPS_CLASS, NULL, dwStyle, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, hDlg, NULL, hInstance, NULL)
    
    ''setup toolinfo
    Dim ti As TOOLINFO
    ZeroMemory(@ti, SizeOf(ti))
    With ti
        .cbSize     = SizeOf(ti)
        .uFlags     = (uFlags Or TTF_IDISHWND Or TTF_SUBCLASS)
        .hwnd       = hDlg
        .uId        = cast(UINT_PTR, hwndTool)
        .hInst      = hInstance
        .lpszText   = MAKEINTRESOURCE(wTextID)
    End With
    
    ''associate the tip with the tool
    If (SendMessage(hwndTip, TTM_ADDTOOL, NULL, Cast(LPARAM, @ti)) = FALSE) Then Return(Cast(HWND, NULL))
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(hwndTip)
    
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
            Case IDC_BTN_BACK
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
    
    ''declare local variables
    Dim hMenu As HMENU      ''top level menu
    Dim hMenuSub As HMENU   ''sub menu to return
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''load the top level menu
    hMenu = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUCONTEXT))
    If (hMenu = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
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
            hMenuSub = GetSubMenu(hMenu, 0)
        Case IDC_LST_DRIVES
            hMenuSub = GetSubMenu(hMenu, 1)
        Case Else
            If (DestroyMenu(hMenu) = FALSE) Then Return(FALSE)  ''destroy the top-level menu
            SetLastError(ERROR_SUCCESS)                         ''set the success code
            Return(FALSE)                                       ''return FALSE
    End Select
    
    ''display context menu
    If (TrackPopupMenu(hMenuSub, TPM_LEFTALIGN Or TPM_TOPALIGN Or TPM_RIGHTBUTTON Or TPM_NOANIMATION, x, y, 0, hDlg, NULL) = FALSE) Then
        DestroyMenu(hMenu)  ''destroy the top-level menu
        Return(FALSE)       ''return FALSE
    End If
    
    ''return
    SetCursor(hCurPrev)
    If (DestroyMenu(hMenu) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''changes directories and refreshes directory listings
Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPTSTR) As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''make sure path exists and is a directory
    If ((PathFileExists(lpszPath) = FALSE) Or (PathIsDirectory(lpszPath) = FALSE)) Then
        HeapUnlock(hHeap)
        Return(FALSE)
    End If
    
    ''change directories
    If (ChDir(*lpszPath) <> 0) Then
        HeapUnlock(hHeap)
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''update UI
    SetDlgItemText(hDlg, IDC_EDT_PATH, CurDir())
    SetDlgItemText(hDlg, IDC_EDT_FILE, NULL)
    
    ''refresh directory listings
    If ((DlgDirList(hDlg, (CurDir() + "\*"), IDC_LST_MAIN, NULL, dwFileFilt) = 0) Or (DlgDirList(hDlg, NULL, IDC_LST_DRIVES, NULL, (DDL_DRIVES Or DDL_EXCLUSIVE)) = 0)) Then
        HeapUnlock(hHeap)
        Return(FALSE)
    End If
    
    ''return
    SetCursor(hCurPrev)
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''starts the options property sheet
Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL
    
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
        .hInstance      = hInstance
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
        .hInstance      = hInstance
        .pszTemplate    = MAKEINTRESOURCE(IDD_FILEFILT)
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
        .hInstance      = hInstance
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
        .hInstance      = hInstance
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
            CreateToolTip(hWnd, IDC_EDT_VGMPLAYPATH, IDS_TIP_VGMPLAYPATH, TTS_ALWAYSTIP, NULL)
            CreateToolTip(hWnd, IDC_EDT_DEFAULTPATH, IDS_TIP_DEFAULTPATH, TTS_ALWAYSTIP, NULL)
            
            ''set text in path options
            SetPathsProc(hWnd, plpszPath)
            
        Case WM_COMMAND     ''commands
            
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    
                    Select Case LoWord(wParam)          ''button ID's:
                        Case IDC_BTN_VGMPLAYPATH        ''browse for vgmplay
                            
                            If (HeapLock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                            ''declare local variables
                            Dim ofn As OPENFILENAME             ''ofn struct
                            Dim szReturnTo As ZString*MAX_PATH  ''temp buffer for current path
                            
                            ''store current directory
                            szReturnTo = CurDir()
                            
                            ''setup ofn
                            ZeroMemory(@ofn, SizeOf(OPENFILENAME))
                            With ofn
                                .lStructSize        = SizeOf(OPENFILENAME)
                                .hwndOwner          = hWnd
                                .hInstance          = hInstance
                                .lpstrFilter        = plpszStrRes[STR_FILT_VGMPLAY]
                                .lpstrCustomFilter  = NULL
                                .nMaxCustFilter     = 0
                                .nFilterIndex       = 1
                                .lpstrFile          = plpszPath[PATH_VGMPLAY]
                                .nMaxFile           = MAX_PATH
                                .lpstrFileTitle     = NULL
                                .nMaxFileTitle      = 0
                                .lpstrInitialDir    = NULL
                                .lpstrTitle         = NULL
                                .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_NONETWORKBUTTON Or OFN_PATHMUSTEXIST)
                                .nFileOffset        = 0
                                .nFileExtension     = 0
                                .lpstrDefExt        = NULL
                            End With
                            
                            ''browse for VGMPlay.exe
                            GetOpenFileName(@ofn)
                            If (SetDlgItemText(hWnd, IDC_EDT_VGMPLAYPATH, plpszPath[PATH_VGMPLAY]) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                            ''return to current directory
                            ChDir(szReturnTo)
                            
                            If (HeapUnlock(hHeap) = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                            
                        Case IDC_BTN_DEFAULTPATH        ''set default path to current one
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

Function SetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    ''set values
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    SetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszValue[PATH_VGMPLAY])
    SetDlgItemText(hDlg, IDC_EDT_DEFAULTPATH, plpszValue[PATH_DEFAULT])
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    If (GetLastError() <> ERROR_SUCCESS) Then
        Return(FALSE)
    Else
        Return(TRUE)
    End If
    
End Function

Function GetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    ''get values
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    GetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszValue[PATH_VGMPLAY], MAX_PATH)
    GetDlgItemText(hDlg, IDC_EDT_DEFAULTPATH, plpszValue[PATH_DEFAULT], MAX_PATH)
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    If (GetLastError() <> ERROR_SUCCESS) Then
        Return(FALSE)
    Else
        Return(TRUE)
    End If
    
End Function

Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND    ''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''dialog init
            
            ''create tooltips
            For i As UINT32 = 0 To 4
                If (CreateToolTip(hWnd, (IDC_CHK_ARCHIVE + i), (IDS_TIP_ARCHIVE + i), TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then
                    SysErrMsgBox(hWnd, GetLastError(), NULL)
                    Exit For
                End If
            Next i
            
            ''display current
            SetFileFiltProc(hWnd, dwFileFilt)
            
        Case WM_COMMAND     ''commands
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    
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
                    If (SaveConfig() = FALSE) Then SysErrMsgBox(hWnd, GetLastError(), NULL)
                    
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
    
    If (dwValue And DDL_ARCHIVE) Then CheckDlgButton(hDlg, IDC_CHK_ARCHIVE, BST_CHECKED)
    If (dwValue And DDL_HIDDEN) Then CheckDlgButton(hDlg, IDC_CHK_HIDDEN, BST_CHECKED)
    If (dwValue And DDL_SYSTEM) Then CheckDlgButton(hDlg, IDC_CHK_SYSTEM, BST_CHECKED)
    If (dwValue And DDL_READONLY) Then CheckDlgButton(hDlg, IDC_CHK_READONLY, BST_CHECKED)
    If (dwValue And DDL_EXCLUSIVE) Then CheckDlgButton(hDlg, IDC_CHK_EXCLUSIVE, BST_CHECKED)
    
    If (GetLastError() <> ERROR_SUCCESS) Then
        Return(FALSE)
    Else
        Return(TRUE)
    End If
    
End Function

Function GetFileFiltProc (ByVal hDlg As HWND, ByRef dwValue As DWORD32) As BOOL
    
    dwValue = DDL_DIRECTORY
    
    If (IsDlgButtonChecked(hDlg, IDC_CHK_ARCHIVE) = BST_CHECKED) Then dwValue = (dwValue Or DDL_ARCHIVE)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_HIDDEN) = BST_CHECKED) Then dwValue = (dwValue Or DDL_HIDDEN)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_SYSTEM) = BST_CHECKED) Then dwValue = (dwValue Or DDL_SYSTEM)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_READONLY) = BST_CHECKED) Then dwValue = (dwValue Or DDL_READONLY)
    If (IsDlgButtonChecked(hDlg, IDC_CHK_EXCLUSIVE) = BST_CHECKED) Then dwValue = (dwValue Or DDL_EXCLUSIVE)
    
    If (GetLastError() <> ERROR_SUCCESS) Then
        Return(FALSE)
    Else
        Return(TRUE)
    End If
    
End Function

Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND    ''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''initialize dialog
            
            ''create tooltips
            For iTip As UINT32 = 0 To 1
                If (CreateToolTip(hWnd, (IDC_CHK_WAVOUT + iTip), (IDS_TIP_WAVOUT + iTip), TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then
                    SysErrMsgBox(hWnd, GetLastError(), NULL)
                    Exit For
                End If
            Next iTip
            
        Case WM_COMMAND     ''commands
            Select Case HiWord(wParam) ''event code
                Case BN_CLICKED        ''button clicked
                    
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
                    
                    ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_NYI, IDS_MSGCAP_NYI, MB_ICONWARNING)
                    
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
    
    Dim dwReturn As DWORD32 = ProgMsgBox(hInstance, hDlg, IDS_MSGTXT_CHANGES, IDS_MSGCAP_CHANGES, MB_ICONWARNING Or MB_YESNOCANCEL)
    Select Case dwReturn
        Case IDYES      ''"Yes" button, save settings and close
            
            ''send a PSN_APPLY notification to the property sheet and let it close
            Dim nmh As NMHDR
            nmh.code = PSN_APPLY
            SendMessage(hDlg, WM_NOTIFY, NULL, Cast(LPARAM, @nmh))
            SetWindowLong(hDlg, DWL_MSGRESULT, Cast(LONG32, FALSE))
            
        Case IDNO       ''"No" button, close
            
            ''allow the property sheet to close
            SetWindowLong(hDlg, DWL_MSGRESULT, Cast(LONG32, FALSE))
            
        Case IDCANCEL   ''"Cancel" button, do not close
            
            ''stop the property sheet from closing
            SetWindowLong(hDlg, DWL_MSGRESULT, Cast(LONG32, TRUE))
            
    End Select
    
    Return(dwReturn)
    
End Function

''starts VGMPlay
Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''check & format lpszFile
    ''confirm path's existence, and add quotes if nessecary
    If (PathFileExists(lpszFile) = FALSE) Then Return(FALSE)
    PathQuoteSpaces(Cast(LPTSTR, lpszFile))
    
    ''get previous cursor
    Dim hPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''stop VGMPlay if it's already running
    If (ppiProcInfo->hProcess <> INVALID_HANDLE_VALUE) Then
        TerminateProcess(ppiProcInfo->hProcess, ERROR_SINGLE_INSTANCE_APP)
    End If
    
    Dim szFile As ZString*MAX_PATH = (" " + *lpszFile)
    
    ''start VGMPlay, and wait for an input idle code
    If (CreateProcess(plpszPath[PATH_VGMPLAY], @szFile, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, psiStartInfo, ppiProcInfo) = FALSE) Then Return(FALSE)
    WaitForInputIdle(ppiProcInfo->hProcess, INFINITE)
    
    ''restore cursor
    SetCursor(hPrev)
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''memory macro functions:
''initializes memory
Function InitMem () As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''allocate memory
    plpszPath       = Cast(LPTSTR Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SIZE_PATH))
    plpszKeyName    = Cast(LPTSTR Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SIZE_KEY))
    plpszStrRes     = Cast(LPTSTR Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SIZE_STRRES))
    phkProgKey      = Cast(PHKEY, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(HKEY))))
    ppiProcInfo     = Cast(PROCESS_INFORMATION Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(PROCESS_INFORMATION))))
    psiStartInfo    = Cast(STARTUPINFO Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(STARTUPINFO))))
    
    ''check allocation
    If ((plpszPath = NULL) Or (plpszKeyName = NULL) Or (plpszStrRes = NULL) Or (phkProgKey = NULL) Or (ppiProcInfo = FALSE) Or (psiStartInfo = FALSE)) Then
        HeapUnlock(hHeap)
        Return(FALSE)
    End If
    
    ''allocate paths
    For iPath As UINT32 = 0 To (NUM_PATH - 1)
        plpszPath[iPath] = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, CB_PATH)))
        If (plpszPath[iPath] = NULL) Then
            HeapUnlock(hHeap)
            Return(FALSE)
        End If
    Next iPath
    
    ''allocate registry key names
    For iKey As UINT32 = 0 To (NUM_KEY - 1)
        plpszKeyName[iKey] = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, CB_KEY)))
        If (plpszKeyName[iKey] = NULL) Then
            HeapUnlock(hHeap)
            Return(FALSE)
        End If
    Next iKey
    
    ''allocate string resources
    For iRes As UINT32 = 0 To (NUM_STRRES - 1)
        plpszStrRes[iRes] = Cast(LPTSTR, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, CB_STRRES)))
        If (plpszStrRes[iRes] = NULL) Then
            HeapUnlock(hHeap)
            Return(FALSE)
        End If
    Next iRes
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''frees memory
Function FreeMem () As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''free paths
    For iPath As UINT32 = 0 To (NUM_PATH - 1)
        If (HeapFree(hHeap, 0, Cast(LPVOID, plpszPath[iPath])) = FALSE) Then Return(FALSE)
    Next iPath
    
    ''free registry key names
    For iKey As UINT32 = 0 To (NUM_KEY - 1)
        If (HeapFree(hHeap, 0, Cast(LPVOID, plpszKeyName[iKey])) = FALSE) Then Return(FALSE)
    Next iKey
    
    ''free string resources
    For iRes As UINT32 = 0 To (NUM_STRRES - 1)
        If (HeapFree(hHeap, 0, Cast(LPVOID, plpszStrRes[iRes])) = FALSE) Then Return(FALSE)
    Next iRes
    
    ''free memory
    If (HeapFree(hHeap, 0, Cast(LPVOID, plpszPath)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, 0, Cast(LPVOID, plpszKeyName)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, 0, Cast(LPVOID, plpszStrRes)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, 0, Cast(LPVOID, phkProgKey)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, 0, Cast(LPVOID, ppiProcInfo)) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, 0, Cast(LPVOID, psiStartInfo)) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''loads the needed string resources
Function LoadStringResources (ByVal hInst As HINSTANCE) As BOOL
    
    If (hInst = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''load the strings
    If (LoadString(hInst, IDS_REG_VGMPLAYPATH, plpszKeyName[KEY_VGMPLAYPATH], CCH_KEY) = 0) Then Return(FALSE)
    If (LoadString(hInst, IDS_REG_DEFAULTPATH, plpszKeyName[KEY_DEFAULTPATH], CCH_KEY) = 0) Then Return(FALSE)
    If (LoadString(hInst, IDS_REG_FILEFILTER, plpszKeyName[KEY_FILEFILTER], CCH_KEY) = 0) Then Return(FALSE)
    
    If (LoadString(hInst, IDS_APPNAME, plpszStrRes[STR_APPNAME], CCH_STRRES) = 0) Then Return(FALSE)
    If (LoadString(hInst, IDS_FILT_VGMPLAY, plpszStrRes[STR_FILT_VGMPLAY], CCH_STRRES) = 0) Then Return(FALSE)
    If (LoadString(hInst, IDS_OPTIONS, plpszStrRes[STR_OPTIONS], CCH_STRRES) = 0) Then Return(FALSE)
    
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''config functions:
''loads the config from the registry
Function LoadConfig () As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''declare local variables
    Dim cbValue As DWORD32   ''size of value in bytes
    
    ''load config
    cbValue = CB_PATH
    If (CheckLongErrCode(RegQueryValueEx(*phkProgKey, plpszKeyName[KEY_VGMPLAYPATH], 0, NULL, Cast(LPBYTE, plpszPath[PATH_VGMPLAY]), @cbValue)) = FALSE) Then Return(FALSE)
    cbValue = CB_PATH
    If (CheckLongErrCode(RegQueryValueEx(*phkProgKey, plpszKeyName[KEY_DEFAULTPATH], 0, NULL, Cast(LPBYTE, plpszPath[PATH_DEFAULT]), @cbValue)) = FALSE) Then Return(FALSE)
    cbValue = CB_PATH
    If (CheckLongErrCode(RegQueryValueEx(*phkProgKey, plpszKeyName[KEY_WAVOUTPATH], 0, NULL, Cast(LPBYTE, plpszPath[PATH_WAVOUT]), @cbValue)) = FALSE) Then Return(FALSE)
    cbValue = SizeOf(DWORD32)
    If (CheckLongErrCode(RegQueryValueEx(*phkProgKey, plpszKeyName[KEY_FILEFILTER], 0, NULL, Cast(LPBYTE, @dwFileFilt), @cbValue)) = FALSE) Then Return(FALSE)
    
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''saves the paths to the registry
Function SaveConfig () As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''save configuration
    If (CheckLongErrCode(RegSetValueEx(*phkProgKey, plpszKeyName[KEY_VGMPLAYPATH], 0, REG_SZ, Cast(LPBYTE, plpszPath[PATH_VGMPLAY]), CB_PATH)) = FALSE) Then Return(FALSE)
    If (CheckLongErrCode(RegSetValueEx(*phkProgKey, plpszKeyName[KEY_DEFAULTPATH], 0, REG_SZ, Cast(LPBYTE, plpszPath[PATH_DEFAULT]), CB_PATH)) = FALSE) Then Return(FALSE)
    If (CheckLongErrCode(RegSetValueEx(*phkProgKey, plpszKeyName[KEY_WAVOUTPATH], 0, REG_SZ, Cast(LPBYTE, plpszPath[PATH_WAVOUT]), CB_PATH)) = FALSE) Then Return(FALSE)
    If (CheckLongErrCode(RegSetValueEx(*phkProgKey, plpszKeyName[KEY_FILEFILTER], 0, REG_DWORD, Cast(LPBYTE, @dwFileFilt), SizeOf(DWORD32))) = FALSE) Then Return(FALSE)
    
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''sets the default configuration
Function SetDefConfig () As BOOL
    
    If (HeapLock(hHeap) = FALSE) Then Return(FALSE)
    
    ''set defaults
    *plpszPath[PATH_VGMPLAY]    = ""
    *plpszPath[PATH_DEFAULT]    = ""
    *plpszPath[PATH_WAVOUT]     = ""
    dwFileFilt                  = DDL_DIRECTORY
    
    If (HeapUnlock(hHeap) = FALSE) Then Return(FALSE)
    
    ''call SaveConfig
    If (SaveConfig() = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
