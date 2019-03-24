/'
    
    config.bas
    
'/

#Include "inc/config.bi"

''private function declarations
Declare Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal lpszClass As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As LRESULT
Declare Function SetDefConfig () As BOOL

Public Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim hHeap As HANDLE = HeapCreate(NULL, ((3 * SizeOf(PROPSHEETPAGE)) + SizeOf(PROPSHEETHEADER)), ((3 * SizeOf(PROPSHEETPAGE)) + SizeOf(PROPSHEETHEADER)))
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate space for pages
    Dim lpPsp As LPPROPSHEETPAGE = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (3 * SizeOf(PROPSHEETPAGE)))
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
        .hInstance      = hInstance
        .pszTemplate    = MAKEINTRESOURCE(IDD_VGMPLAYSETTINGS)
        .pszIcon        = MAKEINTRESOURCE(IDI_WRENCH)
        .pszTitle       = NULL
        .pfnDlgProc     = @VGMPlaySettingsProc
        .lParam         = NULL
        .pfnCallback    = NULL
    End With
    
    ''setup property sheet header
    Dim lpPsh As LPPROPSHEETHEADER = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(PROPSHEETHEADER))
    If (lpPsh = NULL) Then Return(FALSE)
    With *lpPsh
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
    PropertySheet(lpPsh)
    
    ''return
    If (HeapFree(hHeap, NULL, lpPsp) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpPsh) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function VGMPlaySettingsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
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

''saves the paths to the registry
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

''sets the default config values
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
        ? "Calling:", __FUNCTION__
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
