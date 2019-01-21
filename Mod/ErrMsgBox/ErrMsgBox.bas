/'
    
    ErrMsgBox.bas
    
    Error Message Box Library
    
    Copyright (c) 2018 Kazusoft Co.
    
    Compile with:
        fbc -lib ErrMsgBox.bas
        
'/

''check compiler output type
#If __FB_OUT_LIB__ = 0
#Error "__FB_OUT_LIB__ = 0"
#EndIf

#Print Compiling "ErrMsgBox.bas"

''show if 32- or 64-bit target
#Ifdef __FB_64BIT__
#Print "Compiling for 64-bit Windows."
#Else
#Print "Compiling for 32-bit Windows."
#EndIf

''show if debug mode is enabled
#If __FB_DEBUG__
#Print "Compiling in debug mode."
#Else
#Print "Compiling in release mode."
#EndIf

''include header
#Include "errmsgbox.bi"

Public Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32, ByVal pdwArgs As PDWORD32) As DWORD32
    
    #If __FB_DEBUG__
    ? "Calling:", __FUNCTION__
    #EndIf
    
    ''make sure we have an error to display
    If (dwErrorId = ERROR_SUCCESS) Then Return(ERROR_SUCCESS)
    
    ''declare local variables
    Dim mbp As MSGBOXPARAMS ''message box parameters
    Dim lpszError As LPTSTR ''error message buffer
    
    ''format message
    If (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER Or FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_ARGUMENT_ARRAY, NULL, dwErrorId, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), lpszError, 512, Cast(LPVOID, pdwArgs)) = 0) Then Return(GetLastError())
    
    ''setup mbp
    ZeroMemory(@mbp, SizeOf(mbp))
    With mbp
        .cbSize = SizeOf(mbp)
        .hwndOwner = hDlg
        .hInstance = NULL
        .lpszText = lpszError
        .lpszCaption = NULL
        .dwStyle = (MB_OK Or MB_ICONERROR)
        .lpszIcon = NULL
        .dwContextHelpId = NULL
        .lpfnMsgBoxCallback = NULL
        .dwLanguageId = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
    End With
    
    ''show messagebox
    MessageBeep(MB_ICONERROR)   ''play sound
    MessageBoxIndirect(@mbp)    ''show messagebox
    
    ''free memory
    LocalFree(Cast(HLOCAL, lpszError))
    
    ''return
    Return(dwErrorId)
    
End Function

Public Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As DWORD32
    
    #If __FB_DEBUG__
    ? "Calling:", __FUNCTION__
    #EndIf
    
    ''check instance handle
    If (hInst = INVALID_HANDLE_VALUE) Then Return(ERROR_INVALID_HANDLE)
    
    ''declare local variables
    Dim mbp As MSGBOXPARAMSA
    
    ''setup mbp
    ZeroMemory(@mbp, SizeOf(MSGBOXPARAMSA))
    With mbp
        .cbSize             = SizeOf(MSGBOXPARAMSA)
        .hwndOwner          = hDlg
        .hInstance          = hInst
        .lpszText           = MAKEINTRESOURCE(wTextId)
        .lpszCaption        = MAKEINTRESOURCE(wCaptionId)
        .dwStyle            = dwStyle
        .lpszIcon           = NULL
        .dwContextHelpId    = NULL
        .lpfnMsgBoxCallback = NULL
        .dwLanguageId       = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL)
    End With
    
    ''play sound and show message box
    If (dwStyle Or MB_ICONINFORMATION) Then MessageBeep(MB_ICONINFORMATION)
    If (dwStyle Or MB_ICONQUESTION) Then MessageBeep(MB_ICONQUESTION)
    If (dwStyle Or MB_ICONWARNING) Then MessageBeep(MB_ICONWARNING)
    If (dwStyle Or MB_ICONERROR) Then MessageBeep(MB_ICONERROR)
    Return(MessageBoxIndirect(@mbp))
    
End Function

''EOF
