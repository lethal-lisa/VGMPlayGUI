/'
    
    chip-settings.bi
    
'/

''preprocesser statements
#Pragma Once

''check target OS
#Ifndef __FB_WIN32__
    #Error "This library is for Windows only."
#EndIf

#If __FB_OUT_DLL__
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
#ElseIf __FB_OUT_EXE__
    #Print "Including Chip Settings Library"
    #Inclib "chip-settings"
#Else
    #Error "This file must be compiled as a DLL."
#EndIf

#Include Once "windows.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/prsht.bi"
#Include Once "cs_defines.bas"

''declare functions
Declare Function DoChipSettingsPropSheet (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As DWORD32
Declare Function SegaPsgProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function NesApuProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function OplProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function Opl2Proc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function Opl3Proc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function OpmProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function OpnProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function Opn2Proc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function OpnaProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''EOF
