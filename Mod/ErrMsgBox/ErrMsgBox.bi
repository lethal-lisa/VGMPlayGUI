/'
    
    ErrMsgBox.bi
    
    Error Message Box Library Header
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

#Pragma Once

''compiler output
#Ifdef __FB_WIN32__
    #If __FB_OUT_EXE__
        #Print "Including ""ErrMsgBox""."
        #Inclib "errmsgbox"
    #ElseIf __FB_OUT_LIB__
        #Print "Compiling ""ErrMsgBox""."
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
    #Else
        #Error "This file must be compiled as a static library."
    #EndIf
#Else
    #Error "This file must be compiled for Windows."
#EndIf

#Define CCH_ERRMSG 512

''include windows header
#Include Once "windows.bi"

Declare Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32) As LRESULT
'Declare Function SysErrMsgBoxEx (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32, ByVal lpszCaption As LPCTSTR, ByVal lidLang As LANGID, ByVal dwStyle As DWORD32) As LRESULT
Declare Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As LRESULT
Declare Function PlayMsgSound (ByVal dwStyle As DWORD32) As BOOL

''EOF
