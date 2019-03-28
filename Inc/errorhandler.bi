/'
    
    errorhandler.bi
    
    Error Message Box Module Header
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

#Pragma Once
#Include Once "windows.bi"

#Define CCH_ERRMSG  &h00000200 /'512'/
#Define CB_ERRMSG   Cast(SIZE_T, (CCH_ERRMSG * SizeOf(TCHAR)))

#Define CCH_ERRID   &h00000080 /'128'/
#Define CB_ERRID    Cast(SIZE_T, (CCH_ERRID * SizeOf(TCHAR)))

/'  SysErrMsgBox:
    /'  Description:
        Formats a system error message in the user's default language, and
        displays an MB_OK message box with the MB_ICONERROR style and the
        caption "Error".
    '/
    /'  Parameters:
        /'  ByVal hDlg As HWND
            Handle to the dialog to use as a parent for the message box.
            This can be left as NULL. 
        '/
        /'  ByVal dwErrorId As DWORD32
            System error code to display. If this is left as zero or
            ERROR_SUCCESS, the message box is not displayed.
        '/
    '/
    /'  Return Value:
        Returns ERROR_SUCCESS on success, and a system error code on failure.
    '/
'/
Declare Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT

/'  FatalSysErrMsgBox:
    /'  Description:
        Same as SysErrMsgBox except posts a quit message before exiting.
    '/
    /'  Parameters:
        See SysErrMsgBox's parameters.
    '/
    /'  Return Value:
        Returns dwErrorId.
    '/
'/
Declare Function FatalSysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT

Declare Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As LRESULT

''EOF
