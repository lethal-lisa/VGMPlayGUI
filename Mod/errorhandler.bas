/'
    
    errorhandler.bas
    
    Compile with:
        fbc -c "errorhandler.bas"
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#If __FB_OUT_OBJ__
    #Print "Compiling ""Mod\errorhandler.bas""."
#Else
    #Error "This file, ""Mod\errorhandler.bas"" must be compiled as a module."
#EndIf

#Ifdef __FB_64BIT__
    #Print "Compiling for 64-bit Windows."
#Else
    #Print "Compiling for 32-bit Windows."
#EndIf

#If __FB_DEBUG__
    #Print "Compiling in debug mode."
#Else
    #Print "Compiling in release mode."
#EndIf

''include headers
#Include "inc/errorhandler.bi"

Public Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwErrorId\t= 0x"; Hex(dwErrorId)
    #EndIf
    
    ''make sure we have an error to display
    If (dwErrorId = ERROR_SUCCESS) Then Return(ERROR_SUCCESS)
    
    ''get error message string
    Dim lpszErrMsg As LPTSTR ''error message buffer returned by FormatMessage
    Dim cchErrMsg As ULONG32 = FormatMessage((FORMAT_MESSAGE_ALLOCATE_BUFFER Or FORMAT_MESSAGE_FROM_SYSTEM), NULL, dwErrorId, LANG_USER_DEFAULT, Cast(LPTSTR, @lpszErrMsg), CCH_ERRMSG, NULL)
    'If (cchErrMsg = 0) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"lpszErrMsg\t= 0x"; Hex(lpszErrMsg)
        ? !"*lpszErrMsg\t= "; *lpszErrMsg
        ? !"cchErrMsg\t= "; cchErrMsg
    #EndIf
    
    ''get error ID string
    Dim lpszErrId As LPTSTR = Cast(LPTSTR, LocalAlloc(LPTR, CB_ERRID))
    If (lpszErrId = NULL) Then Return(GetLastError())
    *lpszErrId = ("Win32 Error Code: 0x" + Hex(dwErrorId) + ": ")
    
    ''format message box text
    Dim lpszFormatted As LPTSTR = Cast(LPTSTR, LocalAlloc(LPTR, ((cchErrMsg * SizeOf(TCHAR)) + CB_ERRID)))
    If (lpszFormatted = NULL) Then Return(GetLastError())
    *lpszFormatted = (*lpszErrId + *lpszErrMsg)
    
    ''init message box parameters
    Dim lpMbp As LPMSGBOXPARAMS = Cast(LPMSGBOXPARAMS, LocalAlloc(LPTR, SizeOf(MSGBOXPARAMS)))
    If (lpMbp = NULL) Then Return(GetLastError())
    With *lpMbp
        .cbSize             = SizeOf(MSGBOXPARAMS)
        .hwndOwner          = hDlg
        .lpszText           = Cast(LPCTSTR, lpszFormatted)
        .dwStyle            = MB_ICONERROR
        .dwLanguageId       = LANG_USER_DEFAULT
    End With
    
    ''show message box
    If (MessageBoxIndirect(lpMbp) = 0) Then Return(GetLastError())
    
    ''return
    If (LocalFree(Cast(HLOCAL, lpszErrMsg)) = NULL) Then Return(GetLastError())
    If (LocalFree(Cast(HLOCAL, lpszErrId)) = NULL) Then Return(GetLastError())
    If (LocalFree(Cast(HLOCAL, lpMbp)) = NULL) Then Return(GetLastError())
    If (LocalFree(Cast(HLOCAL, lpszFormatted)) = NULL) Then Return(GetLastError())
    Return(ERROR_SUCCESS)
    
End Function

Public Function FatalSysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwErrorId\t= 0x"; Hex(dwErrorId)
    #EndIf
    
    SysErrMsgBox(hDlg, dwErrorId)
    PostQuitMessage(dwErrorId)
    Return(dwErrorId)
    
End Function

Public Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"wTextId\t= 0x"; Hex(wTextId)
        ? !"wCaptionId\t= 0x"; Hex(wCaptionId)
        ? !"dwStyle\t= 0x"; Hex(dwStyle)
    #EndIf
    
    ''check instance handle
    If (hInst = INVALID_HANDLE_VALUE) Then Return(ERROR_INVALID_HANDLE)
    
    ''setup mbp
    Dim mbp As MSGBOXPARAMS
    ZeroMemory(@mbp, SizeOf(MSGBOXPARAMS))
    With mbp
        .cbSize             = SizeOf(MSGBOXPARAMS)
        .hwndOwner          = hDlg
        .hInstance          = hInst
        .lpszText           = MAKEINTRESOURCE(wTextId)
        .lpszCaption        = MAKEINTRESOURCE(wCaptionId)
        .dwStyle            = dwStyle
        .dwLanguageId       = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
    End With
    
    ''return
    Return(MessageBoxIndirect(@mbp))
    
End Function

''EOF
