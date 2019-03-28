/'
    
    createtooltip.bi
    
'/

#Pragma Once

''include windows header
#Include Once "windows.bi"
#Include Once "win/commctrl.bi"

Declare Function CreateToolTip (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal dwToolID As DWORD32, ByVal wTextID As WORD, ByVal dwStyle As DWORD32, ByVal uFlags As UINT32) As HWND

''EOF
