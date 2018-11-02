#Pragma Once

#If __FB_OUT_EXE__
#Print "Including ErrMsgBox"
#Inclib "errmsgbox"
#EndIf

''check target OS
#Ifndef __FB_WIN32__
#Error "Target OS must be Windows"
#EndIf

''include windows header
#Include Once "windows.bi"

Declare Function SysErrMsgBox (ByVal hDlg As HWND, ByVal dwErrorID As DWORD32, ByVal pdwArgs As PDWORD32) As DWORD32
Declare Function ProgMsgBox (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal wTextID As WORD, ByVal wCaptionID As WORD, ByVal dwStyle As DWORD32) As DWORD32