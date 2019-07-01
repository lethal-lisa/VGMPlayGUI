/'
    
    errorhandler.bi
    
    Error Message Box Module Header
    
    Copyright (c) 2018-2019 Kazusoft Co.
    
'/

#Pragma Once
#Include Once "windows.bi"

#Define CCH_ERRDESC     &h00000200 ''512
#Define CB_ERRDESC      (CCH_ERRDESC * SizeOf(TCHAR))

#Define CCH_ERRID       &h0000001F ''31
#Define CB_ERRID        (CCH_ERRID * SizeOf(TCHAR))

/'  MsgBoxBeep:
    
    /'  Description:
        
            Plays a system-defined sound based on a type specifed in a
        message box's style bit-mask.
        
    '/
    
    /'  Parameters:
        
        /'  ByVal dwStyle As DWORD32
            
                The style bit-mask to check for a sound.
            
                Accepted values are:
            
            Value:                                  Sound:
            MB_ICONINFORMATION/MB_ICONASTERISK      Windows Asterisk sound.
            MB_ICONWARNING/MB_ICONEXCLAMATION       Windows Exclamation
                                                    sound.
            MB_ICONERROR/MB_ICONHAND/MB_ICONSTOP    Windows Critical Stop
                                                    sound.
            MB_ICONQUESTION                         Windows Question sound.
            
                If no valid sound is detected, then the function returns true.
            
        '/
        
    '/
    
    /'  Return Value:
        
            Returns TRUE on success and FALSE on failure. To get more
        detailed error information, call GetLastError().
        
    '/
    
'/
Declare Function MsgBoxBeep (ByVal dwStyle As DWORD32) As BOOL

/'  SysErrMsgBox:
    
    /'  Description:
        
            Formats a system error message in the user's default language,
        and displays an MB_OK message box with the MB_ICONERROR style and
        the caption "Error".
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hDlg As HWND
            
                Handle to the dialog to use as a parent for the message box.
            This can be left as NULL.
             
        '/
        
        /'  ByVal dwErrorId As DWORD32
            
                System error code to display. If this is left as zero or
            ERROR_SUCCESS, the message box is not displayed and the function
            returns ERROR_SUCCESS.
            
        '/
        
    '/
    
    /'  Return Value:
        
        Returns ERROR_SUCCESS on success, and a system error code on failure.
        
    '/
    
'/
Declare Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT

/'  FatalSysErrMsgBox:
    
    /'  Description:
        
            Formats a system error message in the user's default language,
        and displays an MB_OK message box with the MB_ICONERROR style and
        the caption "Error".
        
            This function behaves identically to SysErrMsgBox, except in that
        WM_QUIT message is posted with the value in dwErrorId when the
        function exits.
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hDlg As HWND
            
                Handle to the dialog to use as a parent for the message box.
            This can be left as NULL.
             
        '/
        
        /'  ByVal dwErrorId As DWORD32
            
                System error code to display. If this is left as zero or
            ERROR_SUCCESS, the message box is not displayed and the function
            returns ERROR_SUCCESS.
            
        '/
        
    '/
    
    /'  Return Value:
        
            Returns the value from the dwErrorId parameter.
        
    '/
    
'/
Declare Function FatalSysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT

Declare Function EndDlgSysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT

/'  ProgMsgBox:
    
    /'  Description:
        
            Displays a message box with text loaded from an application's string
        resources.
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hInst As HINSTANCE
            
                A handle to the application instance to load the string
            resources from. If this parameter is left as NULL then the
            function will fail and set the last error code to
            ERROR_INVALID_HANDLE.
            
        '/
        
        /'  ByVal hDlg As HWND
            
                A handle to the dialog to use as a parent window for the
            message box. This parameter can be left as NULL.
            
        '/
        
        /'  ByVal wTextId As WORD
            
                The 16-bit resource ID number of a string in the module
            referenced by hInst to use as the message box's contents.
            
        '/
        
        /'  ByVal wCaptionId As WORD
            
                The 16-bit resource ID number of a string in the module
            referenced by hInst to use as the message box's caption.
            
        '/
        
        /'  ByVal dwStyle As DWORD32
            
                A style mask to pass to the message box. Acceptable values
            are those accepted by the MessageBoxIndirect function.
            
        '/
        
    '/
    
    /'  Return Value:
        
            Returns the button pressed by the user as one of the following
        values:
        
        ID  Alias       Meaning
        3   IDABORT     User chose "Abort".
        2   IDCANCEL    User chose "Cancel" or pressed the Escape key.
        11  IDCONTINUE  User chose "Continue".
        5   IDIGNORE    User chose "Ignore".
        7   IDNO        User chose "No".
        1   IDOK        User chose "OK".
        4   IDRETRY     User chose "Retry".
        10  IDTRYAGAIN  User chose "Try Again".
        6   IDYES       User chose "Yes".
        
            If some error occured the return value is 0. Additional
        information about the error can be obtained by calling
        GetLastError().
        
    '/
    
'/
Declare Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As LRESULT

''EOF
