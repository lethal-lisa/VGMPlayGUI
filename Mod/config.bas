/'
    
    config.bas
    
    Compile with:
        fbc -c "config.bas"
    
'/

#Include "inc/config.bi"

Extern hInstance As HINSTANCE

Dim Shared hConfig As HANDLE            ''handle to the config heap
Dim Shared plpszPath As LPTSTR Ptr      ''paths
Dim Shared dwFileFilt As DWORD32        ''file attribute filter variable loaded from the registry

''private function declarations
Declare Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function CreatePathsToolTips (ByVal hDlg As HWND) As BOOL
Declare Function SetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function GetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function BrowseVGMPlay (ByVal hDlg As HWND) As BOOL

Declare Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function CreateFileFiltToolTips (ByVal hDlg As HWND) As BOOL
Declare Function SetFileFiltProc (ByVal hDlg As HWND, ByVal dwValue As DWORD32) As BOOL 
Declare Function GetFileFiltProc (ByVal hDlg As HWND, ByRef dwValue As DWORD32) As BOOL

Declare Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal lpszClass As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As LRESULT
Declare Function SetDefConfig () As BOOL

Public Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim hHeap As HANDLE = HeapCreate(NULL, ((C_PAGES * SizeOf(PROPSHEETPAGE)) + SizeOf(PROPSHEETHEADER) + (64 * SizeOf(TCHAR))), ((3 * SizeOf(PROPSHEETPAGE)) + SizeOf(PROPSHEETHEADER) + (64 * SizeOf(TCHAR))))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate space for pages
    Dim lpPsp As LPPROPSHEETPAGE = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (C_PAGES * SizeOf(PROPSHEETPAGE)))
    If (lpPsp = NULL) Then Return(FALSE)
    
    ''setup "paths" page
    With lpPsp[PG_PATHS]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = PSP_USEICONID
        .hInstance      = hInstance
        .pszTemplate    = MAKEINTRESOURCE(IDD_PATHS)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pfnDlgProc     = @PathsProc
    End With
    
    ''setup "file filter" page
    With lpPsp[PG_FILEFILT]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = (PSP_USEICONID Or PSP_HASHELP)
        .hInstance      = hInstance
        .pszTemplate    = MAKEINTRESOURCE(IDD_FILEFILTER)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pfnDlgProc     = @FileFiltProc
    End With
    
    ''setup property sheet header
    Dim lpPsh As LPPROPSHEETHEADER = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(PROPSHEETHEADER))
    If (lpPsh = NULL) Then Return(FALSE)
    Dim lpszOptions As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (64 * SizeOf(TCHAR)))
    If (lpszOptions = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_OPTIONS, lpszOptions, 64) = 0) Then Return(FALSE)
    With *lpPsh
        .dwSize         = SizeOf(PROPSHEETHEADER)
        .dwFlags        = (PSH_USEICONID Or PSH_PROPSHEETPAGE Or PSH_NOCONTEXTHELP Or PSH_HASHELP)
        .hwndParent     = hDlg
        .hInstance      = hInstance
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszCaption     = Cast(LPCTSTR, lpszOptions)
        .nPages         = C_PAGES
        .nStartPage     = 0
        .ppsp           = Cast(LPCPROPSHEETPAGE, lpPsp)
    End With
    
    ''start property sheet
    PropertySheet(lpPsh)
    
    ''return
    If (HeapFree(hHeap, NULL, lpPsp) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpPsh) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszOptions) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function


Public Function InitConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
    ''allocate memory
    SetLastError(HeapAllocPtrList(hConfig, plpszPath, CB_PATH, C_PATH))
    If (GetLastError()) Then Return(FALSE)
    If (plpszPath = NULL) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
	
	''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function FreeConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
    ''free memory
    SetLastError(HeapFreePtrList(hConfig, plpszPath, CB_PATH, C_PATH))
    If (GetLastError()) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
	
	''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function



Private Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND    ''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''dialog init
            
            ''create tooltips
            If (CreatePathsToolTips(hWnd) = FALSE) Then SysErrMsgBox(hWnd, GetLastError())
            
            ''set text in path options
            SetPathsProc(hWnd, plpszPath)
            
        Case WM_COMMAND     ''commands
            
            Select Case HiWord(wParam)  ''event code
                Case BN_CLICKED         ''button clicked
                    
                    Select Case LoWord(wParam)      ''button IDs:
                        Case IDC_BTN_VGMPLAYPATH    ''browse for vgmplay
							
                            If (BrowseVGMPlay(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDC_BTN_DEFAULTPATH    ''set default path to current one
							
							Dim szCurDir As ZString*MAX_PATH = CurDir()
							If (SetDlgItemText(hWnd, IDC_EDT_DEFAULTPATH, @szCurDir) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
							
                    End Select
                    
                Case EN_CHANGE          ''edit control changing
                    
                    SendMessage(hwndPrsht, PSM_CHANGED, Cast(WPARAM, hWnd), NULL)
                    
                Case EN_ERRSPACE        ''edit control is out of space
                    
                    Return(FatalSysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY))
                    
            End Select
            
        Case WM_NOTIFY      ''notifications
            
            Select Case (Cast(LPNMHDR, lParam)->code)   ''notification codes
                Case PSN_SETACTIVE                      ''page becoming active
                    
                    ''get page handle
                    hwndPrsht = Cast(HWND, Cast(LPNMHDR, lParam)->hwndFrom)
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    ''let page become inactive
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    ''get settings from dialog
                    If (GetPathsProc(hWnd, plpszPath) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                    ''save settings to the registry
                    If (SaveConfig() = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                Case PSN_QUERYCANCEL                    ''user has pressed the cancel button
                    
                    PrpshCancelPrompt(hWnd)
                    
            End Select
            
        Case Else           ''otherwise
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

Private Function CreatePathsToolTips (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''create tooltips
    If (CreateToolTip(hInstance, hDlg, IDC_EDT_VGMPLAYPATH, IDS_TIP_VGMPLAYPATH, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    If (CreateToolTip(hInstance, hDlg, IDC_EDT_DEFAULTPATH, IDS_TIP_DEFAULTPATH, TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function SetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg)
        ? !"plpszValue\t= 0x"; Hex(plpszValue)
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
    ''set the values
    If (SetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszValue[PATH_VGMPLAY]) = FALSE) Then Return(FALSE)
    If (SetDlgItemText(hDlg, IDC_EDT_DEFAULTPATH, plpszValue[PATH_DEFAULT]) = FALSE) Then Return(FALSE)
    
    ''release the lock on the heap
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
	
	''return
	SetLastError(ERROR_SUCCESS)
	Return(TRUE)
    
End Function

Private Function GetPathsProc (ByVal hDlg As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg)
        ? !"plpszValue\t= 0x"; Hex(plpszValue)
    #EndIf
    
    ''get values
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    GetDlgItemText(hDlg, IDC_EDT_VGMPLAYPATH, plpszValue[PATH_VGMPLAY], MAX_PATH)
    GetDlgItemText(hDlg, IDC_EDT_DEFAULTPATH, plpszValue[PATH_DEFAULT], MAX_PATH)
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
	
	''return
	SetLastError(ERROR_SUCCESS)
	Return(TRUE)
    
End Function

Private Function BrowseVGMPlay (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''create local heap
    Dim hOfn As HANDLE = HeapCreate(NULL, Cast(SIZE_T, (SizeOf(OPENFILENAME) + (CB_BVGMP * C_BVGMP))), NULL)
    If (hOfn = INVALID_HANDLE_VALUE) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"hOfn\t= 0x"; Hex(hOfn, 8)
    #EndIf
    
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
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
    If (LoadString(hInstance, IDS_FILT_VGMPLAY, plpszString[BVGMP_FILT], MAX_PATH) = 0) Then Return(FALSE)
    
    ''setup ofn
    Dim lpOfn As LPOPENFILENAME = Cast(LPOPENFILENAME, HeapAlloc(hOfn, HEAP_ZERO_MEMORY, Cast(SIZE_T, SizeOf(OPENFILENAME))))
    If (lpOfn = NULL) Then Return(FALSE)
    #If __FB_DEBUG__
        ? !"lpOfn\t= 0x"; Hex(lpOfn)
    #EndIf
    With *lpOfn
        .lStructSize        = SizeOf(OPENFILENAME)
        .hwndOwner          = hDlg
        '.hInstance          = NULL
        .lpstrFilter        = Cast(LPCTSTR, plpszString[BVGMP_FILT])
        '.lpstrCustomFilter  = NULL
        '.nMaxCustFilter     = NULL
        .nFilterIndex       = 1
        .lpstrFile          = plpszString[BVGMP_FILE]
        .nMaxFile           = MAX_PATH
        .lpstrFileTitle     = plpszString[BVGMP_FILETITLE]
        .nMaxFileTitle      = MAX_PATH
        '.lpstrInitialDir    = NULL
        '.lpstrTitle         = NULL
        .Flags              = (OFN_DONTADDTORECENT Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST)
        '.nFileOffset        = NULL
        '.nFileExtension     = NULL
        '.lpstrDefExt        = NULL
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
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
    
    ''destroy the heap
    If (HeapDestroy(hOfn) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function



Private Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrsht As HWND	''handle to property sheet.
    
    ''process messages
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''dialog init
            
            ''create tooltips
            If (CreateFileFiltToolTips(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
            
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
                    If (hwndPrsht = INVALID_HANDLE_VALUE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                Case PSN_KILLACTIVE                     ''page becoming inactive
                    
                    SetWindowLong(hWnd, DWL_MSGRESULT, Cast(LONG32, FALSE))
                    Return(FALSE)
                    
                Case PSN_APPLY                          ''user has pressed the apply button
                    
                    ''get values from sheet
                    If (GetFileFiltProc(hWnd, dwFileFilt) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                    ''save to registry
                    If (SaveConfig() = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    
                Case PSN_HELP                           ''user has pressed the help button
                    
                    ProgMsgBox(hInstance, hWnd, IDS_MSGTXT_FILTHELP, IDS_MSGCAP_FILTHELP, MB_ICONINFORMATION)
                    
                Case PSN_QUERYCANCEL                    ''user has pressed the cancel button
                    
                    Dim dwCurrent As DWORD32
                    If (GetFileFiltProc(hWnd, dwCurrent) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                    If (dwCurrent <> dwFileFilt) Then PrpshCancelPrompt(hWnd)
                    
            End Select
            
        Case Else           ''otherwise
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

Private Function CreateFileFiltToolTips (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''create tooltips
    For i As UINT32 = 0 To 4
        If (CreateToolTip(hInstance, hDlg, (IDC_CHK_ARCHIVE + i), (IDS_TIP_ARCHIVE + i), TTS_ALWAYSTIP, NULL) = INVALID_HANDLE_VALUE) Then Return(FALSE)
    Next i
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function SetFileFiltProc (ByVal hDlg As HWND, ByVal dwValue As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwValue\t= 0x"; Hex(dwValue)
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

Private Function GetFileFiltProc (ByVal hDlg As HWND, ByRef dwValue As DWORD32) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t\t= 0x"; Hex(hDlg)
        ? !"dwValue\t= 0x"; Hex(dwValue)
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



Public Function PrpshCancelPrompt (ByVal hDlg As HWND) As DWORD32
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
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

Public Function LoadConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    Dim hHeap As HANDLE = HeapCreate(NULL, (CB_KEY * C_KEY), (CB_KEY * C_KEY))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''open the program's registry key
    Dim dwKeyDisp As DWORD32    ''disposition value for OpenProgHKey
    Dim hkProgKey As HKEY       ''handle to the program's registry key 
    SetLastError(OpenProgHKey(@hkProgKey, "VGMPlayGUI", NULL, KEY_ALL_ACCESS, @dwKeyDisp))
    If (GetLastError()) Then Return(FALSE)
    
    ''load the config
    Dim cbValue As DWORD32          ''size of items to write to the registry
    Dim plpszKeyName As LPTSTR Ptr  ''pointer to a buffer for the key names
    
    If (dwKeyDisp = REG_OPENED_EXISTING_KEY) Then
        
        ''setup key names
        SetLastError(HeapAllocPtrList(hHeap, plpszKeyName, CB_KEY, C_KEY))
        If (GetLastError()) Then Return(FALSE)
        SetLastError(LoadStringRange(hInstance, plpszKeyName, IDS_REG_VGMPLAYPATH, CCH_KEY, C_KEY))
        If (GetLastError()) Then Return(FALSE)
        
        ''load the config
        If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
        
        cbValue = CB_PATH
        SetLastError(RegQueryValueEx(hkProgKey, plpszKeyName[KEY_VGMPLAYPATH], NULL, NULL, Cast(LPBYTE, plpszPath[PATH_VGMPLAY]), @cbValue))
        If (GetLastError()) Then Return(FALSE)
        
        cbValue = CB_PATH
        SetLastError(RegQueryValueEx(hkProgKey, plpszKeyName[KEY_DEFAULTPATH], NULL, NULL, Cast(LPBYTE, plpszPath[PATH_DEFAULT]), @cbValue))
        If (GetLastError()) Then Return(FALSE)
        
        cbValue = SizeOf(DWORD32)
        SetLastError(RegQueryValueEx(hkProgKey, plpszKeyName[KEY_FILEFILTER], NULL, NULL, Cast(LPBYTE, @dwFileFilt), @cbValue))
        If (GetLastError()) Then Return(FALSE)
        
        If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
        
        ''free the allocated buffer for the key names
        SetLastError(HeapFreePtrList(hHeap, plpszKeyName, CB_KEY, C_KEY))
        If (GetLastError()) Then Return(FALSE)
        
    Else
        
        If (SetDefConfig() = FALSE) Then Return(FALSE)
        
    End If
    
    ''return
    SetLastError(RegCloseKey(hkProgKey))
    If (GetLastError()) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function SaveConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    Dim hHeap As HANDLE = HeapCreate(NULL, (CB_KEY * C_KEY), (CB_KEY * C_KEY))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''open the program's registry key
    Dim hkProgKey As HKEY   ''handle to the program's registry key
    SetLastError(OpenProgHKey(@hkProgKey, "VGMPlayGUI", NULL, KEY_WRITE, NULL))
    If (GetLastError()) Then Return(FALSE)
    
    ''setup key names
    Dim plpszKeyName As LPTSTR Ptr
    SetLastError(HeapAllocPtrList(hHeap, plpszKeyName, CB_KEY, C_KEY))
    If (GetLastError()) Then Return(FALSE)
    SetLastError(LoadStringRange(hInstance, plpszKeyName, IDS_REG_VGMPLAYPATH, CCH_KEY, C_KEY))
    If (GetLastError()) Then Return(FALSE)
    
    ''save the configuration to the registry
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
    SetLastError(RegSetValueEx(hkProgKey, plpszKeyName[KEY_VGMPLAYPATH], NULL, REG_SZ, Cast(LPBYTE, plpszPath[PATH_VGMPLAY]), CB_PATH))
    If (GetLastError()) Then Return(FALSE)
    
    SetLastError(RegSetValueEx(hkProgKey, plpszKeyName[KEY_DEFAULTPATH], NULL, REG_SZ, Cast(LPBYTE, plpszPath[PATH_DEFAULT]), CB_PATH))
    If (GetLastError()) Then Return(FALSE)
    
    SetLastError(RegSetValueEx(hkProgKey, plpszKeyName[KEY_FILEFILTER], NULL, REG_DWORD, Cast(LPBYTE, @dwFileFilt), SizeOf(DWORD32)))
    If (GetLastError()) Then Return(FALSE)
    
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(HeapFreePtrList(hHeap, Cast(LPVOID Ptr, plpszKeyName), CB_KEY, C_KEY))
    If (GetLastError()) Then Return(FALSE)
    SetLastError(RegCloseKey(hkProgKey))
    If (GetLastError()) Then Return(FALSE)
	If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function SetDefConfig () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
	''get a lock on the heap
    If (HeapLock(hConfig) = FALSE) Then Return(FALSE)
    
    ''set defaults
    *plpszPath[PATH_VGMPLAY]    = ""
    *plpszPath[PATH_DEFAULT]    = ""
    dwFileFilt                  = DDL_DIRECTORY
    
	''release the lock on the heap
    If (HeapUnlock(hConfig) = FALSE) Then Return(FALSE)
    
    ''save the default configuration
    If (SaveConfig() = FALSE) Then Return(FALSE)
	
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal lpszClass As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    ''declare local variables
    Dim hkSoftware As HKEY  ''hkey to HKEY_CURRENT_USER\"Software"
    
    ''open HKEY_CURRENT_USER\Software
    SetLastError(Cast(DWORD32, RegOpenKeyEx(HKEY_CURRENT_USER, "Software", NULL, samDesired, @hkSoftware)))
    If (GetLastError()) Then Return(GetLastError())
    
    ''open/create HKEY_CURRENT_USER\"Software"\*lpszAppName
    SetLastError(Cast(DWORD32, RegCreateKeyEx(hkSoftware, lpszAppName, NULL, NULL, NULL, samDesired, NULL, phkOut, pdwDisp)))
    If (GetLastError()) Then Return(GetLastError())
    
    ''close hkSoftware
    SetLastError(Cast(DWORD32, RegCloseKey(hkSoftware)))
    If (GetLastError()) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

''EOF
