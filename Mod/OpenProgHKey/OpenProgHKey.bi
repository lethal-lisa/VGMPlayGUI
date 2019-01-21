/'
    
    OpenProgHKey.bi
    
'/

#Pragma Once

''include windows headers
#Include Once "windows.bi"

''compiler output
#Ifdef __FB_WIN32__
    #If __FB_OUT_EXE__
        #Print "Including ""OpenProgHKey.bi""."
        #Inclib "openproghkey"
    #ElseIf __FB_OUT_LIB__
        #Print "Compiling ""OpenProgHKey.bas""."
        #Ifdef __FB_64BIT__
            #Print "Compiling for 64-bit Windows."
        #Else
            #Print "Compiling for 32-bit Windows."
        #EndIf
    #Else
        #Error "This file must be compiled as a static library."
    #EndIf
#Else
    #Error "This file must be compiled for Windows."
#EndIf

Declare Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal lpszClass As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As LRESULT

''EOF
