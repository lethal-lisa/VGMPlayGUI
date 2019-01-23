/'
    
    ErrMsgBox.bi
    
    Error Message Box Library Header
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

#Pragma Once

''compiler output
#Ifdef __FB_WIN32__
    #If __FB_OUT_EXE__
        #Print "Including ""ErrMsgBox.bi""."
        #Inclib "errmsgbox"
    #ElseIf __FB_OUT_LIB__
        #Print "Compiling ""ErrMsgBox.bas""."
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

''include windows header
#Include Once "windows.bi"

Declare Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorId As DWORD32, ByVal pdwArgs As PDWORD32) As DWORD32
Declare Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextId As WORD, ByVal wCaptionId As WORD, ByVal dwStyle As DWORD32) As DWORD32

''EOF
