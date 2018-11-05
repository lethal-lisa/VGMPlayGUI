/'
    
    WinAPICheck.bi
    
    Simple checking functions for Windows API.
    
    Copyright (c) 2018 Lisa Murray
    
'/

#Pragma Once

''check the compiler output type
#If __FB_OUT_EXE__ <> 0
#Print "Including WinAPICheck"
#Inclib "winapicheck"
#EndIf

''check target OS
#Ifndef __FB_WIN32__
#Error "Target OS must be Windows"
#EndIf

''include windows header
#Include Once "windows.bi"

/'  CheckLongErrCode
    /'  Description
        
            Converts a 32-bit error code into a boolean value and sets the
        last-error-code.
        
    '/
    /'  Parameters
        /'  lCode
            Addressing: ByVal
            Data Type:  LONG32
            Optional:   No
            Description:
                Code to evaluate.
        '/
    '/
    /'  Return Value
        Data Type:      BOOL
        Description:
            Returns TRUE on ERROR_SUCCESS, and FALSE on an error code.
    '/
'/
Declare Function CheckLongErrCode (ByVal lCode As LONG32) As BOOL

''EOF
