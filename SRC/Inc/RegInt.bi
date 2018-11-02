/'
    
    RegInt.bi
    
    Registry Interface Library for Windows
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

#Pragma Once

#If __FB_OUT_EXE__
#Print "Including RegInt"
#Inclib "regint"
#EndIf

''check target OS
#Ifndef __FB_WIN32__
#Error "Target OS must be Windows"
#EndIf

''include windows header
#Include Once "windows.bi"

Declare Function OpenProgHKey (ByRef phkProgKey As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As BOOL
