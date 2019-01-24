/'
    
    OpenProgHKey.bi
    
'/

#Pragma Once

''compiler output
#Ifdef __FB_WIN32__
    #If __FB_OUT_EXE__
        #Print "Including ""OpenProgHKey""."
        #Inclib "openproghkey"
    #ElseIf __FB_OUT_LIB__
        #Print "Compiling ""OpenProgHKey""."
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

Declare Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal lpszClass As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As LRESULT

''EOF
