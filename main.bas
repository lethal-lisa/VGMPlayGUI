/'
    
    main.bas
    
    VGMPlayGUI v2 - Main module.
    
    Compile with:
        fbc -c "Mod\*.bas"
        fbc -s gui "main.bas" "resource.rc" "Mod\*.o" -x "VGMPlayGUI.exe"
    
    Copyright (c) 2018-2019 Kazusoft Co.
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
Dim uExitCode As UINT32 
uExitCode = WinMain(hInstance, NULL, lpszCmdLine, SW_SHOWNORMAL)

''exit
#If __FB_DEBUG__
    ? !"uExitCode\t= 0x"; Hex(uExitCode)
#EndIf
ExitProcess(uExitCode)
End(uExitCode)

''main function
Public Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hInstPrev\t= 0x"; Hex(hInstPrev)
        ? !"lpszCmdLine\t= 0x"; Hex(lpszCmdLine)
        ? !"*lpszCmdLine\t= "; *lpszCmdLine
        ? !"nShowCmd\t= 0x"; Hex(nShowCmd)
    #EndIf
    
    ''init window classes
    If (InitClasses() = FALSE) Then Return(GetLastError())
    
    ''initialize config
    hConfig = HeapCreate(NULL, NULL, NULL)
    If (hConfig = INVALID_HANDLE_VALUE) Then Return(GetLastError())
    If (InitConfig() = FALSE) Then Return(GetLastError())
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
    
    ''destroy config
    If (FreeConfig() = FALSE) Then Return(GetLastError())
    If (HeapDestroy(hConfig) = FALSE) Then Return(GetLastError())
    
    ''unregister the window classes
    If (UnregisterClass(@MainClass, hInst) = FALSE) Then Return(GetLastError())
    
    ''return exit code
    Return(msg.wParam)
    
End Function

''initalizes classes
Private Function InitClasses () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
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

''main dialog procedure
Private Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    Static hHeap As HANDLE
    Static lpszCurPath As LPTSTR
    
    ''process messages
    Select Case uMsg                ''messages:
        Case WM_CREATE              ''creating window
            
            hHeap = GetProcessHeap()
            If (hHeap = INVALID_HANDLE_VALUE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            lpszCurPath = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
            If (lpszCurPath = NULL) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            ''set the program's icon
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_VGMPLAYGUI))))
            
            ''create child windows
            If (CreateMainChildren(hWnd) = FALSE) Then Return(FatalSysErrMsgBox(NULL, GetLastError()))
            
        Case WM_DESTROY             ''destroying window
            
            If (HeapFree(hHeap, NULL, lpszCurPath) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
            ''post quit message with last error-code
            PostQuitMessage(GetLastError())
            
        Case WM_INITDIALOG          ''initializing dialog
            
            ''initialize directory listings to default directory
            If (HeapLock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
            ''make sure VGMPlay's path is valid
            If (PathFileExists(plpszPath[PATH_VGMPLAY]) = FALSE) Then
                If (ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_VGMPMISS, IDS_MSGCAP_VGMPMISS, (MB_YESNO Or MB_ICONWARNING)) = IDYES) Then
                    If (DoOptionsPropSheet(hWnd) = FALSE) Then Return(FALSE)
                End If
            End If
            
            ''display the default path if it exists, otherwise display the current path
            If (PathIsDirectory(plpszPath[PATH_DEFAULT])) Then
                If (PopulateLists(hWnd, plpszPath[PATH_DEFAULT]) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            Else
                If (PopulateLists(hWnd, ".") = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            End If
            
            If (HeapUnlock(hConfig) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
            ''set the default keyboard focus to IDC_LST_MAIN
            If (SetFocus(GetDlgItem(hWnd, IDC_LST_MAIN)) = Cast(HWND, NULL)) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
        Case WM_CLOSE               ''window is being closed
            
            ''destroy main window
            If (DestroyWindow(hWnd) = FALSE) Then Return(SysErrMsgBox(NULL, GetLastError()))
            
        Case WM_COMMAND             ''command has been issued
            
            Select Case HiWord(wParam)                          ''event:
                Case BN_CLICKED                                 ''a button has been pressed
                    Select Case LoWord(wParam)                  ''button IDs:
                        Case IDM_ROOT                           ''change to drive root
                            
                            ''change directory to the current drive's root
                            If (PopulateLists(hWnd, "\") = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
                            
                        Case IDM_EXIT                           ''exit program
                            
                            ''send a WM_CLOSE message to the main window
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_OPTIONS                        ''start the options property sheet
                            
                            If (DoOptionsPropSheet(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_ABOUT                          ''display the about message
                            
                            If (AboutMsgBox(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PROPERTIES                     ''item properties
                            
                            ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_NYI, IDS_MSGCAP_NYI, MB_ICONWARNING)
                            
                        Case IDM_ADDTOLIST                      ''add item to a playlist
                            
                            ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_NYI, IDS_MSGCAP_NYI, MB_ICONWARNING)
                            
                        Case IDM_PLEDIT                         ''launch playlist editor
                            
                            ''store current path
                            *lpszCurPath = CurDir()
                            
                            DialogBox(hInstance, MAKEINTRESOURCE(IDD_PLAYLIST), hWnd, @PlaylistProc)
                            
                            ''refresh lists with current path in case the editor changed the current path
                            If (PopulateLists(hWnd, lpszCurPath) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_DELETE                         ''delete file
                            
                            If (ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_DELCONFIRM, IDS_MSGCAP_DELCONFIRM, (MB_ICONWARNING Or MB_YESNO)) = IDYES) Then
                                If (GetDlgItemText(hWnd, IDC_EDT_FILE, lpszCurPath, CCH_PATH) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                                If (DeleteFile(Cast(LPCTSTR, lpszCurPath)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                                If (PopulateLists(hWnd, ".") = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            End If
                            
                        Case IDC_BTN_PLAY                       ''start VGMPlay
                            
                            If (GetDlgItemText(hWnd, IDC_EDT_FILE, lpszCurPath, CCH_PATH) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (StartVGMPlay(Cast(LPCTSTR, lpszCurPath)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_GO                         ''change to a specified directory
                            
                            If (GetDlgItemText(hWnd, IDC_EDT_PATH, lpszCurPath, MAX_PATH) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (PopulateLists(hWnd, lpszCurPath) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_UP, IDM_UP                 ''move up one directory
                            
                            If (PopulateLists(hWnd, "..") = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_REFRESH, IDM_REFRESH       ''refresh the current directory listing
                            
                            If (PopulateLists(hWnd, ".") = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                    End Select
                    
                Case LBN_DBLCLK                                 ''the user has double-clicked in a listbox
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get selected item, change directories, and refresh the listboxes
                            If (GetDlgItemText(hWnd, IDC_EDT_FILE, lpszCurPath, MAX_PATH) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (PathIsDirectory(Cast(LPCTSTR, lpszCurPath)) = Cast(BOOL, FILE_ATTRIBUTE_DIRECTORY)) Then
                                
                                ''change to selected directory and refresh the listboxes
                                If (GetLastError()) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                                If (PopulateLists(hWnd, Cast(LPCTSTR, lpszCurPath)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                                
                            Else
                                
                                If (StartVGMPlay(Cast(LPCTSTR, lpszCurPath)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                                
                            End If
                            
                    End Select
                    
                Case LBN_SELCHANGE                              ''a listbox selection has changed
                    Select Case LoWord(wParam)  ''listbox IDs:
                        Case IDC_LST_MAIN       ''file list
                            
                            ''get the selected item and update the UI
                            DlgDirSelectEx(hWnd, lpszCurPath, MAX_PATH, IDC_LST_MAIN)
                            If (SetDlgItemText(hWnd, IDC_EDT_FILE, lpszCurPath) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_LST_DRIVES     ''drives list
                            
                            ''get the selected item and change drives
                            DlgDirSelectEx(hWnd, lpszCurPath, MAX_PATH, IDC_LST_DRIVES)
                            If (PopulateLists(hWnd, lpszCurPath) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                    End Select
                    
                Case Cast(UINT32, LBN_ERRSPACE), EN_ERRSPACE    ''a listbox or edit control is out of memory
                    
                    ''display error message, and terminate program
                    Return(FatalSysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY))
                    
            End Select
            
        Case WM_SIZE                ''window has been resized
            
            #If __FB_DEBUG__
                ? "WM_SIZE:"
                ? "Resize type:", "0x"; Hex(wParam)
                ? "(cx, cy)", "= ("; LoWord(lParam); ", "; HiWord(lParam); ")"
            #EndIf
            
            ''get the current directory
            Dim lpszCurDir As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
            If (lpszCurDir = NULL) Then
                SysErrMsgBox(hWnd, GetLastError())
                Return(FALSE)
            End If
            *lpszCurDir = CurDir()
            
            ''update the title bar
            If (UpdateMainTitleBar(hWnd, Cast(LPCTSTR, lpszCurDir)) = FALSE) Then
                SysErrMsgBox(hWnd, GetLastError())
                Return(FALSE)
            End If
            
            ''free the current directory
            If (HeapFree(hHeap, NULL, lpszCurDir) = FALSE) Then
                SysErrMsgBox(hWnd, GetLastError())
                Return(FALSE)
            End If
            
            Dim lprc As LPRECT = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (2 * SizeOf(RECT)))
            If (lprc = NULL) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
            ''get rects for statusbar and main dialog, and subtract the statusbar's height from that of the main window
            With lprc[0] ''rcParent
                .right  = LoWord(lParam)
                .bottom = HiWord(lParam)
            End With
            If (GetClientRect(GetDlgItem(hWnd, IDC_SBR_MAIN), @lprc[1]) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            lprc[0].bottom -= lprc[1].bottom
            
            ''resize the child windows
            If (EnumChildWindows(hWnd, @ResizeMainChildren, Cast(LPARAM, @lprc[0])) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
            If (HeapFree(hHeap, NULL, lprc) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
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
            
            If (DisplayMainContextMenu(hWnd, Cast(DWORD32, lParam)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
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
    
    ''create status bar control
    If (CreateWindowEx(NULL, STATUSCLASSNAME, NULL, WS_CHILD Or WS_VISIBLE Or SBARS_SIZEGRIP Or SBARS_TOOLTIPS, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_SBR_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''create list box controls
    If (CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTBOX, NULL, WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_TABSTOP Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_HASSTRINGS Or LBS_SORT, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_LST_MAIN), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTBOX, NULL, WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_TABSTOP Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_HASSTRINGS Or LBS_SORT, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_LST_DRIVES), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''create edit controls
    If (CreateWindowEx(WS_EX_CLIENTEDGE, WC_EDIT, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or ES_LEFT Or ES_AUTOHSCROLL, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_EDT_FILE), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateWindowEx(WS_EX_CLIENTEDGE, WC_EDIT, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or ES_LEFT Or ES_AUTOHSCROLL, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_EDT_PATH), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''create button controls
    If (CreateWindowEx(NULL, WC_BUTTON, NULL, WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER Or BS_DEFPUSHBUTTON Or BS_ICON, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_PLAY), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateWindowEx(NULL, WC_BUTTON, "Go", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_GO), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateWindowEx(NULL, WC_BUTTON, "[..]", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_UP), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateWindowEx(NULL, WC_BUTTON, "[.]", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or BS_CENTER Or BS_VCENTER, 0, 0, 0, 0, hDlg, Cast(HMENU, IDC_BTN_REFRESH), hInstance, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
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
Private Function ResizeMainChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
    
    ''declare local variables
    Dim lprcParent As LPRECT    ''parent window's bounding rectangle
    Dim rcChild As RECT         ''child window's new bounding rectangle
    
    ''get lprcParent
    lprcParent = Cast(LPRECT, lParam)
    
    With rcChild
        
        ''calculate child window's new bounding rectangle
        Select Case GetWindowLong(hWnd, GWL_ID)
            Case IDC_SBR_MAIN
                /'.left   = 0
                .top    = 0
                .right  = 0
                .bottom = 0'/
                ZeroMemory(@rcChild, SizeOf(RECT))
            Case IDC_LST_MAIN
                .left   = MARGIN_SIZE                                                       ''10=10
                .top    = ((2 * MARGIN_SIZE) + WINDOW_SIZE)                                 ''2*10+30=20+30=50
                .right  = (lprcParent->Right - ((3 * MARGIN_SIZE) + (3 * WINDOW_SIZE)))     ''3*10+3*30=30+90=120
                .bottom = (lprcParent->bottom - ((4 * MARGIN_SIZE) + (2 * WINDOW_SIZE)))    ''4*10+2*30=40+60=100
            Case IDC_LST_DRIVES
                .left   = (lprcParent->Right - (MARGIN_SIZE + (3 * WINDOW_SIZE)))           ''10+3*30=10+90=100
                .top    = ((2 * MARGIN_SIZE) + WINDOW_SIZE)                                 ''2*10+30=20+30=50
                .right  = (3 * WINDOW_SIZE)                                                 ''3*30=90
                .bottom = (lprcParent->bottom - ((4 * MARGIN_SIZE) + (2 * WINDOW_SIZE)))    ''4*10+2*30=40+60=100
            Case IDC_EDT_FILE
                .left   = MARGIN_SIZE                                                       ''10=10
                .top    = (lprcParent->bottom - (MARGIN_SIZE + WINDOW_SIZE))                ''10+30=40
                .right  = (lprcParent->Right - ((3 * MARGIN_SIZE) + (2 * WINDOW_SIZE)))     ''3*10+2*30=30+60=90
                .bottom = WINDOW_SIZE                                                       ''30=30
            Case IDC_BTN_PLAY
                .left   = (lprcParent->Right - (MARGIN_SIZE + (2 * WINDOW_SIZE)))           ''10+2*30=10+60=70
                .top    = (lprcParent->bottom - (MARGIN_SIZE + (1.25 * WINDOW_SIZE)))       ''10+1.25*30=10+37.5=47.5
                .right  = (2 * WINDOW_SIZE)                                                 ''2*30=60
                .bottom = (1.5 * WINDOW_SIZE)                                               ''1.5*30=45
            Case IDC_EDT_PATH
                .left   = MARGIN_SIZE                                                       ''10=10
                .top    = MARGIN_SIZE                                                       ''10=10
                .right  = (lprcParent->Right - ((3 * MARGIN_SIZE) + (3 * WINDOW_SIZE)))     ''3*10+3*30=30+90=120
                .bottom = WINDOW_SIZE                                                       ''30=30
            Case IDC_BTN_GO
                .left   = (lprcParent->Right - (MARGIN_SIZE + (3 * WINDOW_SIZE)))           ''10+3*30=10+90=100
                .top    = MARGIN_SIZE                                                       ''10=10
                .right  = WINDOW_SIZE                                                       ''30=30
                .bottom = WINDOW_SIZE                                                       ''30=30
            Case IDC_BTN_UP
                .left   = (lprcParent->Right - (MARGIN_SIZE + (2 * WINDOW_SIZE)))           ''10+2*30=10+60=70
                .top    = MARGIN_SIZE                                                       ''10=10
                .right  = WINDOW_SIZE                                                       ''30=30
                .bottom = WINDOW_SIZE                                                       ''30=30
            Case IDC_BTN_REFRESH
                .left   = (lprcParent->Right - (MARGIN_SIZE + WINDOW_SIZE))                 ''10+30=40
                .top    = MARGIN_SIZE                                                       ''10=10
                .right  = WINDOW_SIZE                                                       ''30=30
                .bottom = WINDOW_SIZE                                                       ''30=30
        End Select
        
        ''resize the child window
        If (MoveWindow(hWnd, .left, .top, .right, .bottom, TRUE) = FALSE) Then Return(FALSE)
        
    End With
    
    ''return
    Return(TRUE)
    
End Function

''displays context menus for the main dialog
Private Function DisplayMainContextMenu (ByVal hDlg As HWND, ByVal dwMouse As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwMouse\t= 0x"; Hex(dwMouse)
    #EndIf
    
    ''set waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''get the mouse coords & convert them to client coords
    Dim lpptMouse As LPPOINT = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(Point))
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
			phMenu[0] = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUCONTEXT))
			If (phMenu[0] = INVALID_HANDLE_VALUE) Then Return(FALSE)
			
			''load sub menu
			phMenu[1] = GetSubMenu(phMenu[0], MEN_MAINLIST)
			If (phMenu[1] = INVALID_HANDLE_VALUE) Then Return(FALSE)
			
        Case IDC_LST_DRIVES
            
            ''load top-level menu
			phMenu[0] = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENUCONTEXT))
			If (phMenu[0] = INVALID_HANDLE_VALUE) Then Return(FALSE)
			
			''load sub menu
            phMenu[1] = GetSubMenu(phMenu[0], MEN_DRIVES)
            If (phMenu[1] = INVALID_HANDLE_VALUE) Then Return(FALSE)
            
        Case Else
            
            ''return
            If (HeapFree(hHeap, NULL, Cast(LPVOID, phMenu)) = FALSE) Then Return(FALSE)
            SetLastError(ERROR_SUCCESS)
            Return(TRUE)
            
    End Select
    
    ''display context menu
    If (TrackPopupMenu(phMenu[1], (TPM_LEFTALIGN Or TPM_TOPALIGN Or TPM_RIGHTBUTTON Or TPM_NOANIMATION), LoWord(dwMouse), HiWord(dwMouse), NULL, hDlg, NULL) = FALSE) Then Return(FALSE)
    
    ''return
    For iMenu As INT32 = 1 To 0 Step -1
        If (DestroyMenu(phMenu[iMenu]) = FALSE) Then Return(FALSE)
    Next iMenu
    If (HeapFree(hHeap, NULL, phMenu) = FALSE) Then Return(FALSE)
    SetCursor(hCurPrev)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''changes directories and refreshes directory listings
Private Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszPath\t= 0x"; Hex(lpszPath)
        ? !"*lpszPath\t= "; *lpszPath
    #EndIf
    
    ''set a waiting cursor
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''make sure path exists and is a directory
    If (PathFileExists(lpszPath) = FALSE) Then Return(FALSE)
    If (PathIsDirectory(lpszPath) = FALSE) Then Return(FALSE)
    
    ''store previous path
    /'  NYI:
            At this location, write the previous path (since we haven't
        changed it yet, this can be obtained with CurDir()) to a buffer.
        
            This is for a "back" button.
    '/
    
    ''change directories
    If (ChDir(*lpszPath)) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''get current directory
    Dim lpszCurDir As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszCurDir = NULL) Then Return(FALSE)
    *lpszCurDir = CurDir()
    
    ''update UI
    If (SetDlgItemText(hDlg, IDC_EDT_PATH, Cast(LPCTSTR, lpszCurDir)) = FALSE) Then Return(FALSE)
    If (SetDlgItemText(hDlg, IDC_EDT_FILE, NULL) = FALSE) Then Return(FALSE)
    If (UpdateMainTitleBar(hDlg, Cast(LPCTSTR, lpszCurDir)) = FALSE) Then Return(FALSE)
    If (DlgDirList(hDlg, (CurDir() + "\*"), IDC_LST_MAIN, NULL, dwFileFilt) = 0) Then Return(FALSE)
    If (DlgDirList(hDlg, NULL, IDC_LST_DRIVES, NULL, (DDL_DRIVES Or DDL_EXCLUSIVE)) = 0) Then Return(FALSE)
    
    ''return
    SetCursor(hCurPrev)
    If (HeapFree(hHeap, NULL, lpszCurDir) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''updates the main dialog's title bar
Private Function UpdateMainTitleBar (ByVal hDlg As HWND, ByVal lpszPath As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszPath\t= 0x"; Hex(lpszPath)
        ? !"*lpszPath\t= "; *lpszPath
    #EndIf
    
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load the app name
    Dim lpszAppName As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_APPNAME)
    If (lpszAppName = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_APPNAME, lpszAppName, CCH_APPNAME) = 0) Then Return(FALSE)
    
    ''if path is null, only set the app title
    If (lpszPath = NULL) Then
        If (SetWindowText(hDlg, Cast(LPCTSTR, lpszAppName)) = FALSE) Then Return(FALSE)
        If (HeapFree(hHeap, NULL, lpszAppName) = FALSE) Then Return(FALSE)
        SetLastError(ERROR_SUCCESS)
        Return(TRUE)
    End If
    
    ''format the path name
    Dim lpszTempPath As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (lpszTempPath = NULL) Then Return(FALSE)
    *lpszTempPath = *lpszPath
    
    ''get the title bar's size
    Dim pti As PTITLEBARINFO = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(TITLEBARINFO))
    If (pti = NULL) Then Return(FALSE)
    pti->cbSize = SizeOf(TITLEBARINFO)
    If (GetTitleBarInfo(hDlg, pti) = FALSE) Then Return(FALSE)
    
    ''resize the path
    Dim dx As ULONG32 = ((pti->rcTitleBar.right - pti->rcTitleBar.left) \ 2)
    If (PathCompactPath(NULL, lpszTempPath, dx) = FALSE) Then Return(FALSE)
    
    ''format the new window title
    Dim lpszTitle As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, ((MAX_PATH + CCH_APPNAME + 5) * SizeOf(TCHAR)))
    If (lpszTitle = NULL) Then Return(FALSE)
    *lpszTitle = (*lpszAppName + " - [" + *lpszTempPath + "]")
    If (SetWindowText(hDlg, Cast(LPCTSTR, lpszTitle)) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapFree(hHeap, NULL, lpszTitle) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, pti) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszTempPath) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszAppName) = FALSE) Then Return(FALSE)
    SetCursor(hCurPrev)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''starts VGMPlay with the specified file
Private Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
	
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate buffer for command line parameters
    Dim lpszParam As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszParam = NULL) Then Return(FALSE)
    
    ''format command line parameters
    If (PathFileExists(lpszFile) = FALSE) Then Return(FALSE)
    *lpszParam = (" " + Chr(34) + CurDir() + "\" + *lpszFile + Chr(34))
    
    Static piProcInfo As PROCESS_INFORMATION
    Static siStartInfo As STARTUPINFO
    
    ''stop VGMPlay if it's already running
    If (piProcInfo.hProcess <> INVALID_HANDLE_VALUE) Then TerminateProcess(piProcInfo.hProcess, ERROR_SINGLE_INSTANCE_APP)
    
    ''start VGMPlay, and wait for an input idle code
    If (CreateProcess(plpszPath[PATH_VGMPLAY], lpszParam, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, @siStartInfo, @piProcInfo) = FALSE) Then Return(FALSE)
    WaitForInputIdle(piProcInfo.hProcess, INFINITE)
    
	''return
	If (HeapFree(hHeap, NULL, lpszParam) = FALSE) Then Return(FALSE)
	SetCursor(hCurPrev)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''displays the about message box
Private Function AboutMsgBox (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim hCurPrev As HCURSOR = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load unformatted strings
    Dim plpszAbout As LPTSTR Ptr
    If (HeapListAlloc(hHeap, plpszAbout, CB_ABT, C_ABT) = FALSE) Then Return(FALSE)
    If (LoadStringRange(hInstance, plpszAbout, IDS_ABT_DESCRIPTION, CCH_ABT, C_ABT) = FALSE) Then Return(FALSE)
    
    ''format the strings
    Dim lpszMessage As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (C_ABT * CB_ABT))
    If (lpszMessage = NULL) Then Return(FALSE)
    *lpszMessage = (*plpszAbout[ABT_DESCRIPTION] + *plpszAbout[ABT_LEGAL])
    
    ''setup message box params
    Dim lpMbp As LPMSGBOXPARAMS = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(MSGBOXPARAMS))
    If (lpMbp = NULL) Then Return(FALSE)
    With *lpMbp
        .hInstance      = hInstance
        .cbSize         = SizeOf(MSGBOXPARAMS)
        .hwndOwner      = hDlg
        .lpszText       = lpszMessage
        .lpszCaption    = MAKEINTRESOURCE(IDS_MSGCAP_ABOUT)
        .dwStyle        = MB_USERICON
        .lpszIcon       = MAKEINTRESOURCE(IDI_KAZUSOFT)
        .dwLanguageId   = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
    End With
    
    ''show message box
    SetCursor(hCurPrev)
    MessageBoxIndirect(lpMbp)
    hCurPrev = SetCursor(LoadCursor(NULL, IDC_WAIT))
    
    ''return
    If (HeapListFree(hHeap, plpszAbout, CB_ABT, C_ABT) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszMessage) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpMbp) = FALSE) Then Return(FALSE)
    SetCursor(hCurPrev)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
