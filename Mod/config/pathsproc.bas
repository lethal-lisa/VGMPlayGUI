/'
    
    pathsproc.bas
    
'/

#Include "inc/config.bi"

Declare Function CreatePathsToolTips (ByVal hDlg As HWND) As BOOL
Declare Function SetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL
Declare Function GetPathsProc (ByVal hWnd As HWND, ByVal plpszValue As LPTSTR Ptr) As BOOL

Declare Function BrowseVGMPlay (ByVal hDlg As HWND) As BOOL

Public Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
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
        ? "Calling:", __FILE__; "/"; __FUNCTION__
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
        ? "Calling:", __FILE__; "/"; __FUNCTION__
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
        ? "Calling:", __FILE__; "/"; __FUNCTION__
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
        ? "Calling:", __FILE__; "/"; __FUNCTION__
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


''EOF
