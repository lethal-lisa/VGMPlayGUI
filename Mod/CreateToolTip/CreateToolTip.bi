/'
    
    CreateToolTip.bi
    
'/

#Pragma Once

''compiler output
#Ifdef __FB_WIN32__
    #If __FB_OUT_EXE__
        #Print "Including ""CreateToolTip""."
        #Inclib "createtooltip"
    #ElseIf __FB_OUT_LIB__
        #Print "Compiling ""CreateToolTip""."
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
    #EndIf
#Else
    #Error "This file must be compiled for Windows."
#EndIf

''include windows header
#Include Once "windows.bi"
#Include Once "win/commctrl.bi"

Declare Function CreateToolTip (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal dwToolID As DWORD32, ByVal wTextID As WORD, ByVal dwStyle As DWORD32, ByVal uFlags As UINT32) As HWND

''EOF
