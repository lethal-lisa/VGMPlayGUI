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

''defines
#Define IDI_CHIP                    100
#define IDD_SEGAPSG                 1000
#define IDC_CHK_SEGAPSG_ENABLE      1001
#define IDC_GRP_SEGAPSG_CHANNELS    1002
#define IDC_CHK_SEGAPSG_CH1         1003
#define IDC_CHK_SEGAPSG_CH2         1004
#define IDC_CHK_SEGAPSG_CH3         1005
#define IDC_CHK_SEGAPSG_CH4         1006
#define IDC_CBX_SEGAPSG_CORE        1007
#define IDD_NESAPU                  1100
#define IDC_CHK_NES_ENABLE          1101
#define IDC_GRP_NES_CHANNELS        1102
#define IDC_CHK_NES_PULSE1          1103
#define IDC_CHK_NES_PULSE2          1104
#define IDC_CHK_NES_TRIANGLE        1105
#define IDC_CHK_NES_NOISE           1106
#define IDC_CHK_NES_DPCM            1107
#define IDC_CBX_NES_CORE            1108

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
