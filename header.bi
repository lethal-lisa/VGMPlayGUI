/'
    
    header.bi
    
    VGMPlayGUI v2 - Header file.
    
    Copyright (c) 2018 Kazusoft Co.
    Kazusoft is a TradeMark of Lisa Murray.
    
'/

''preprocesser
#Pragma Once

''make sure target is Windows
#Ifndef __FB_WIN32__
#Error "This file is for Windows only." 
#EndIf

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

#LibPath "mod"

''include header files
#Include Once "windows.bi"
#Include Once "win/shlwapi.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/prsht.bi"
#Include "inc/errmsgbox.bi"
#Include "inc/regint.bi"
#Include "inc/winapicheck.bi"

''defines
#Define MARGIN_SIZE 10
#Define WINDOW_SIZE 30
#Define MIN_SIZE_X  503
#Define MIN_SIZE_Y  443

''for some reason, this isn't defined in FB's 64-bit headers
#Ifndef DWL_MSGRESULT
#Define DWL_MSGRESULT 0
#EndIf

''defines from resource.rc
#Define IDD_MAIN                &h03E8

#Define IDD_PATHS               &h044C
#Define IDC_STC_VGMPLAYPATH     &h044D
#Define IDC_EDT_VGMPLAYPATH     &h044E
#define IDC_BTN_VGMPLAYPATH     &h044F
#define IDC_STC_DEFAULTPATH     &h0450
#define IDC_EDT_DEFAULTPATH     &h0451
#Define IDC_BTN_DEFAULTPATH     &h0452

#define IDD_FILEFILT            &h04B0
#Define IDC_GRP_ATTRIB          &h04B1
#define IDC_CHK_ARCHIVE         &h04B2
#define IDC_CHK_HIDDEN          &h04B3
#define IDC_CHK_SYSTEM          &h04B4
#define IDC_CHK_READONLY        &h04B5
#define IDC_CHK_EXCLUSIVE       &h04B6

#Define IDD_CORESELECT          &h0514
#Define IDC_CBX_CHIP            &h0515
#Define IDC_CBX_CORE            &h0516

''defines from icons.rc
#Define IDI_VGMPLAYGUI          &h0064
#Define IDI_KAZUSOFT            &h0065
#Define IDI_WRENCH              &h0066
#Define IDI_PLAY                &h0067

''defines from strings.rc
#Define IDS_APPNAME             &h0001
#Define IDS_MSGTXT_ABOUT        &h0011
#Define IDS_MSGCAP_ABOUT        &h0012
#Define IDS_MSGTXT_NYI          &h0013
#Define IDS_MSGCAP_NYI          &h0014
#Define IDS_MSGTXT_VGMPMISS     &h0015
#Define IDS_MSGCAP_VGMPMISS     &h0016
#Define IDS_MSGTXT_CHANGES      &h0017
#Define IDS_MSGCAP_CHANGES      &h0018
#Define IDS_MSGTXT_FILTHELP     &h0019
#Define IDS_MSGCAP_FILTHELP     &h001A
#Define IDS_MSGTXT_DELFILE      &h001B
#Define IDS_MSGCAP_DELFILE      &h001C
#Define IDS_REG_VGMPLAYPATH     &h0021
#Define IDS_REG_DEFAULTPATH     &h0022
#Define IDS_REG_FILEFILTER      &h0023
#Define IDS_FILT_VGMPLAY        &h0031
#Define IDS_FILT_VGMFILE        &h0032
#Define IDS_TIP_DRIVELIST       &h0041
#Define IDS_TIP_BACKBTN         &h0042
#Define IDS_TIP_GOBTN           &h0043
#Define IDS_TIP_REFRESHBTN      &h0044
#Define IDS_TIP_PLAYBTN         &h0045
#Define IDS_OPTIONS             &h0051

''defines from menus.rc
#Define IDR_MENU1               &h2710
#Define IDM_FILE                &h2711
#Define IDM_ROOT                &h2712
#Define IDM_EXIT                &h2713
#Define IDM_OPTIONS             &h2714
#Define IDM_ABOUT               &h2715

#Define IDR_MENUCONTEXT         &h4E20
#Define IDM_LST_MAIN            &h4E21
#Define IDM_LST_MAIN_REFRESH    &h4E22
#Define IDM_LST_MAIN_BACK       &h4E23
#Define IDM_LST_DRIVES          &h4E24
#Define IDM_LST_DRIVES_REFRESH  &h4E25

''IDs for plpszPaths
#Define CCH_PATH            MAX_PATH
#Define CB_PATH             (SizeOf(TCHAR) * CCH_PATH)
#Define NUM_PATH            3
#Define SIZE_PATH           Cast(SIZE_T, (NUM_PATH * CB_PATH))
#Define PATH_VGMPLAY        0
#Define PATH_DEFAULT        1
#Define PATH_CURRENT        2

''IDs for plpszKeyName
#Define CCH_KEY             32
#Define CB_KEY              (SizeOf(TCHAR) * CCH_KEY)
#Define NUM_KEY             3
#Define SIZE_KEY            Cast(SIZE_T, (NUM_KEY * CB_KEY))
#Define KEY_VGMPLAYPATH     0
#Define KEY_DEFAULTPATH     1
#Define KEY_FILEFILTER      2

''IDs for plpszStrRes
#Define CCH_STRRES          512
#Define CB_STRRES           (SizeOf(TCHAR) * CCH_STRRES)
#Define NUM_STRRES          4
#Define SIZE_STRRES         Cast(SIZE_T, (NUM_STRRES * CB_STRRES))
#Define STR_APPNAME         0
#Define STR_FILT_VGMPLAY    1
#Define STR_FILT_VGMFILE    2
#Define STR_OPTIONS         3

''IDs for puOptions
#Define CB_OPT              SizeOf(UINT32)
#Define NUM_OPT             2
#Define SIZE_OPT            Cast(SIZE_T, (NUM_OPT * CB_OPT))
#Define OPT_FILEFILT        0
#Define OPT_MULTIINST       1

''mask values for OPT_MULTIINST
#Define MIM_MULTIINST       &h1 /'bit #1, TRUE=multiple instances, FALSE=single instance'/
#Define MIM_CLOSEPREV       &h2 /'bit #2, TRUE=close previous, FALSE=open multiple copies'/

''child window IDs
#Define IDC_SBR             &h03E9 /'1001'/
#Define IDC_LST_MAIN        &h03EA /'1002'/
#Define IDC_LST_DRIVES      &h03EB /'1003'/
#Define IDC_EDT_FILE        &h03EC /'1004'/
#Define IDC_BTN_PLAY        &h03ED /'1005'/
#Define IDC_EDT_PATH        &h03EE /'1006'/
#Define IDC_BTN_GO          &h03EF /'1007'/
#Define IDC_BTN_BACK        &h03F0 /'1008'/
#Define IDC_BTN_REFRESH     &h03F1 /'1009'/


''define constants
Const MainClass = "MAINCLASS"


''declare shared variables
Dim Shared hInstance As HMODULE ''instance handle
Dim Shared lpszCmdLine As LPSTR ''command line
Dim Shared hWin As HWND         ''main window handle
Dim Shared hHeap As HANDLE      ''heap handle

Dim Shared plpszPath As LPTSTR Ptr                  ''paths
Dim Shared plpszKeyName As LPTSTR Ptr               ''registry key names
Dim Shared plpszStrRes As LPTSTR Ptr                ''misc. string resources
Dim Shared phkProgKey As PHKEY                      ''program hkey
Dim Shared ppiProcInfo As PROCESS_INFORMATION Ptr   ''process info for CreateProcess
Dim Shared psiStartInfo As STARTUPINFO Ptr          ''startup info for CreateProcess
Dim Shared puOption As PUINT32                      ''various options


''declare functions
''main function
Declare Function WinMain (ByVal hInst As HINSTANCE, ByVal hInstPrev As HINSTANCE, ByVal lpszCmdLine As LPSTR, ByVal nShowCmd As INT32) As INT32

''subroutine used to start the main dialog. called by WinMain
Declare Sub StartMainDialog (ByVal hInst As HINSTANCE, ByVal nShowCmd As INT32, ByVal lParam As LPARAM)


''main dialog procedure
Declare Function MainProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''creates child windows for the main dialog
Declare Function CreateMainChildren (ByVal hDlg As HWND) As BOOL

''creates a tooltip and associates it with a control
Declare Function CreateToolTip (ByVal hDlg As HWND, ByVal dwToolID As DWORD32, ByVal wTextID As WORD, ByVal dwStyle As DWORD32, ByVal uFlags As UINT32) As HWND

''resizes the main dialog's child windows
Declare Function ResizeChildren (ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL

''displays an about message
Declare Sub AboutMsgBox (ByVal hDlg As HWND)

''displays a context menu in the main dialog
Declare Function DisplayContextMenu (ByVal hDlg As HWND, ByVal x As WORD, ByVal y As WORD) As BOOL

''changes directories and refreshes directory listings
Declare Function PopulateLists (ByVal hDlg As HWND, ByVal lpszPath As LPTSTR) As BOOL


''starts the options property sheet
Declare Function DoOptionsPropSheet (ByVal hDlg As HWND) As BOOL

''options property sheet page procedures
Declare Function PathsProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function FileFiltProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function CoreSelectProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''shows the cancel prompt
Declare Sub PrpshCancelPrompt (ByVal hDlg As HWND)

''starts VGMPlay
Declare Function StartVGMPlay (ByVal lpszFile As LPCTSTR) As BOOL

''opens a VGM file
Declare Function OpenVGMFile (ByVal hDlg As HWND) As BOOL


''memory macro functions
Declare Function InitMem () As BOOL
Declare Function FreeMem () As BOOL

''loads string resources
Declare Function LoadStringResources (ByVal hInst As HINSTANCE) As BOOL

''config functions
Declare Function LoadConfig () As BOOL
Declare Function SaveConfig () As BOOL
Declare Function SetDefConfig () As BOOL

''EOF
