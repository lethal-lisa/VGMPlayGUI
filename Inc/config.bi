/'
    
    config.bi
    
'/

#Pragma Once
#Include Once "windows.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/prsht.bi"
'#Include "mod/createtooltip/createtooltip.bi"
'#Include "mod/heapptrlist/heapptrlist.bi"
#Include "inc/createtooltip.bi"
#Include "inc/heapptrlist.bi"
#Include "inc/errorhandler.bi"
#Include "defines.bi"

#Define CCH_BVGMP           MAX_PATH
#Define CB_BVGMP            Cast(SIZE_T, (SizeOf(TCHAR) * CCH_BVGMP))
#Define C_BVGMP             4
#Define BVGMP_RETURN        0
#Define BVGMP_FILT          1
#Define BVGMP_FILE          2
#Define BVGMP_FILETITLE     3

#Define C_PAGES             3
#Define PG_PATHS            0
#Define PG_FILEFILT         1
#Define PG_VGMPLAY          2

Extern hConfig As HANDLE
Extern plpszPath As LPTSTR Ptr
Extern dwFileFilt As DWORD32

Declare Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL
Declare Function InitConfig () As BOOL
Declare Function FreeConfig () As BOOL
Declare Function PrpshCancelPrompt (ByVal hDlg As HWND) As DWORD32
Declare Function LoadConfig () As BOOL
Declare Function SaveConfig () As BOOL

''EOF
