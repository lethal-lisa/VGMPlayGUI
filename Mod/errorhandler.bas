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

Public Function MsgBoxBeep (ByVal dwStyle As DWORD32) As BOOL
    
    ''play a sound if one of the available tones is specified in the style mask
    /'  These two sounds are disabled because they would both trigger false
        positives when checking the bit-mask.
    If (dwStyle And &hFFFFFFFF) Then Return(MessageBeep(&hFFFFFFFF))
    If (dwStyle And MB_OK) Then Return(MessageBeep(MB_OK))'/
    If (dwStyle And MB_ICONINFORMATION) Then Return(MessageBeep(MB_ICONINFORMATION))
    If (dwStyle And MB_ICONWARNING) Then Return(MessageBeep(MB_ICONWARNING))
    If (dwStyle And MB_ICONERROR) Then Return(MessageBeep(MB_ICONERROR))
    If (dwStyle And MB_ICONQUESTION) Then Return(MessageBeep(MB_ICONQUESTION))
    
    ''if a sound is not specifed, return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

/'  The end string will be formatted like this:
    
        <lpszErrId><lpszErrDesc>
    
    Which will look something like this:
    
        "Win32 error code 0x1:
        Incorrect function."
    
'/

Public Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwErrorId\t= 0x"; Hex(dwErrorId)
    #EndIf
    
    ''make sure we have an error to display
    If (dwErrorId = ERROR_SUCCESS) Then Return(ERROR_SUCCESS)
    
    ''get a process heap
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(ERROR_INVALID_HANDLE)
    #If __FB_DEBUG__
        ? !"hHeap\t= 0x"; Hex(hHeap)
    #EndIf
    
    ''get error ID string
    Dim lpszErrId As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_ERRID)
    If (lpszErrId = NULL) Then Return(GetLastError())
    *lpszErrId = ("Win32 error code: 0x" + Hex(dwErrorId) + !":\n")
    #If __FB_DEBUG__
        ? !"lpszErrId\t= 0x"; Hex(lpszErrId)
        ? !"*lpszErrId\t= "; *lpszErrId
    #EndIf
    
    ''get error description string
    Dim lpszErrDesc As LPTSTR
    Dim cchErrDesc As UINT = FormatMessage((FORMAT_MESSAGE_ALLOCATE_BUFFER Or FORMAT_MESSAGE_FROM_SYSTEM), NULL, dwErrorId, LANG_USER_DEFAULT, Cast(LPTSTR, @lpszErrDesc), CCH_ERRDESC, NULL)
    If (cchErrDesc = 0) Then Return(GetLastError())
    #If __FB_DEBUG__
        ? !"lpszErrDesc\t= 0x"; Hex(lpszErrDesc)
        ? !"*lpszErrDesc\t= "; *lpszErrDesc
        ? !"cchErrDesc\t= "; cchErrDesc
    #EndIf
    
    ''combine the two strings
    Dim lpszFormattedMsg As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (CB_ERRID + (cchErrDesc * SizeOf(TCHAR))))
    If (lpszFormattedMsg = NULL) Then Return(GetLastError())
    *lpszFormattedMsg = (*lpszErrId + *lpszErrDesc)
    #If __FB_DEBUG__
        ? !"lpszFormattedMsg\t= 0x"; Hex(lpszFormattedMsg)
        ? !"*lpszFormattedMsg\t= "; *lpszFormattedMsg
    #EndIf
    
    ''setup message box params
    Dim lpmbp As LPMSGBOXPARAMS = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(MSGBOXPARAMS))
    If (lpmbp = NULL) Then Return(GetLastError())
    With *lpmbp
        .cbSize             = SizeOf(MSGBOXPARAMS)
        .hwndOwner          = hDlg
        .lpszText           = Cast(LPCTSTR, lpszFormattedMsg)
        .dwStyle            = (MB_OK Or MB_ICONERROR)
        .dwLanguageId       = LANG_USER_DEFAULT
    End With
    
    ''display message box
    MessageBeep(MB_ICONERROR)
    MessageBoxIndirect(lpmbp)
    
    ''return
    If (HeapFree(hHeap, NULL, lpszErrId) = FALSE) Then Return(GetLastError())
    If (LocalFree(Cast(HLOCAL, lpszErrDesc)) = FALSE) Then Return(GetLastError())
    If (HeapFree(hHeap, NULL, lpszFormattedMsg) = FALSE) Then Return(GetLastError())
    If (HeapFree(hHeap, NULL, lpmbp) = FALSE) Then Return(GetLastError())
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

Public Function EndDlgSysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"dwErrorId\t= 0x"; Hex(dwErrorId)
    #EndIf
    
    SysErrMsgBox(hDlg, dwErrorId)
    EndDialog(hDlg, -1)
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
    If (hInst = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(NULL)
    End If
    
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
    If (MsgBoxBeep(dwStyle) = FALSE) Then Return(NULL)
    Return(MessageBoxIndirect(@mbp))
    
End Function

''EOF
