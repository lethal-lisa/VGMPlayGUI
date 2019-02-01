/'
    
    ErrMsgBox.bas
    
    Error Message Box Library
    
    Copyright (c) 2018 Kazusoft Co.
    
    Compile with:
        fbc -lib ErrMsgBox.bas
        
'/

''include header
#Include "errmsgbox.bi"

Public Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg, 8)
        ? !"dwErrorId\t= 0x"; Hex(dwErrorId, 8)
    #EndIf
    
    ''make sure we have an error to display
    If (dwErrorId = ERROR_SUCCESS) Then Return(ERROR_SUCCESS)
    
    ''format error message from error code
    Dim lpszError As LPTSTR ''error message buffer
    If (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER Or FORMAT_MESSAGE_FROM_SYSTEM, NULL, dwErrorId, LANG_USER_DEFAULT, Cast(LPTSTR, @lpszError), CCH_ERRMSG, NULL) = 0) Then Return(GetLastError())
    
    ''allocate space for message box parameters
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, LocalAlloc(LPTR, Cast(SIZE_T, SizeOf(MSGBOXPARAMS))))
    If (lpMbp = NULL) Then Return(GetLastError())
    
    ''set up the message box parameters
    With *lpMbp
        .cbSize             = SizeOf(MSGBOXPARAMS)
        .hwndOwner          = hDlg
        .lpszText           = lpszError
        .dwStyle            = MB_ICONERROR
        .dwLanguageId       = LANG_USER_DEFAULT
    End With
    
    ''play sound
    If (MessageBeep(MB_ICONERROR) = FALSE) Then Return(GetLastError())
    
    ''show message box
    If (MessageBoxIndirect(lpMbp) = 0) Then Return(GetLastError())
    
    ''free memory allocated for message box parameters and 
    If (LocalFree(Cast(HLOCAL, lpMbp)) = NULL) Then Return(GetLastError())
    If (LocalFree(Cast(HLOCAL, lpszError)) = NULL) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

Public Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
        ? "hInst", "= 0x"; Hex(hInst, 8)
        ? "hDlg", "= 0x"; Hex(hDlg, 8)
        ? "wTextId", "= 0x"; Hex(wTextId, 4)
        ? "wCaptionId", "= 0x"; Hex(wCaptionId, 4)
        ? "dwStyle", "= 0x"; Hex(dwStyle, 8)
    #EndIf
    
    ''check instance handle
    If (hInst = INVALID_HANDLE_VALUE) Then Return(ERROR_INVALID_HANDLE)
    
    ''declare local variables
    'Dim mbp As MSGBOXPARAMSA
    
    ''setup mbp
    'ZeroMemory(@mbp, SizeOf(MSGBOXPARAMSA))
    'With mbp
    '    .cbSize             = SizeOf(MSGBOXPARAMSA)
    '    .hwndOwner          = hDlg
    '    .hInstance          = hInst
    '    .lpszText           = MAKEINTRESOURCE(wTextId)
    '    .lpszCaption        = MAKEINTRESOURCE(wCaptionId)
    '    .dwStyle            = dwStyle
    '    .lpszIcon           = NULL
    '    .dwContextHelpId    = NULL
    '    .lpfnMsgBoxCallback = NULL
    '    .dwLanguageId       = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
    'End With
    
    ''allocate space for message box parameters
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, LocalAlloc(LPTR, Cast(SIZE_T, SizeOf(MSGBOXPARAMS))))
    If (lpMbp = NULL) Then Return(GetLastError())
    
    ''set up message box parameters
    With *lpMbp
        .cbSize         = SizeOf(MSGBOXPARAMS)
        .hwndOwner      = hDlg
        .hInstance      = hInst
        .lpszText       = MAKEINTRESOURCE(wTextId)
        .lpszCaption    = MAKEINTRESOURCE(wCaptionId)
        .dwStyle        = dwStyle
        .dwLanguageId   = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
    End With
    
    ''play sound
    'If (dwStyle Or MB_ICONINFORMATION) Then MessageBeep(MB_ICONINFORMATION)
    'If (dwStyle Or MB_ICONQUESTION) Then MessageBeep(MB_ICONQUESTION)
    'If (dwStyle Or MB_ICONWARNING) Then MessageBeep(MB_ICONWARNING)
    'If (dwStyle Or MB_ICONERROR) Then MessageBeep(MB_ICONERROR)
    'Return(MessageBoxIndirect(@mbp))
    If (PlayMsgSound(dwStyle) = FALSE) Then Return(GetLastError())
    
    ''show message box
    Dim dwRetVal As DWORD32 = MessageBoxIndirect(lpMbp)
    If (dwRetVal = 0) Then Return(GetLastError())
    
    ''free memory allocated for message box parameters
    If (LocalFree(Cast(HLOCAL, lpMbp)) = NULL) Then Return(GetLastError())
    
    ''return code returned by MessageBoxIndirect
    Return(dwRetVal)
    
End Function

Private Function PlayMsgSound (ByVal dwStyle As DWORD32) As BOOL
    
    If (dwStyle = MB_ICONINFORMATION) Then
        If (MessageBeep(MB_ICONINFORMATION) = FALSE) Then Return(FALSE)
    End If
    
    If (dwStyle = MB_ICONQUESTION) Then
        If (MessageBeep(MB_ICONQUESTION) = FALSE) Then Return(FALSE)
    End If
    
    If (dwStyle = MB_ICONWARNING) Then
        If (MessageBeep(MB_ICONWARNING) = FALSE) Then Return(FALSE)
    End If
    
    If (dwStyle = MB_ICONWARNING) Then
        If (MessageBeep(MB_ICONWARNING) = FALSE) Then Return(FALSE)
    End If
    
    Return(TRUE)
    
End Function

''EOF
