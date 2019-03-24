/'
    
    filefiltproc.bas
    
'/

#Include "inc/config.bi"

Declare Function CreateFileFiltToolTips (ByVal hDlg As HWND) As BOOL
Declare Function SetFileFiltProc (ByVal hDlg As HWND, ByVal dwValue As DWORD32) As BOOL
Declare Function GetFileFiltProc (ByVal hDlg As HWND, ByRef dwValue As DWORD32) As BOOL

Public Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
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

''EOF
