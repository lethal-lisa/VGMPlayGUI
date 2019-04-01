/'
    
    defines.bi
    
    Defines for VGMPlayGUI
    
'/

#Pragma Once
#Include "inc/stringids.bi"

''defines
#Define MARGIN_SIZE                 &h0000000A ''(10) distance between adjacent controls
#Define WINDOW_SIZE                 &h0000001E ''(30) minimum window length/width
#Define MIN_SIZE_X                  &h000001F8 ''504
#Define MIN_SIZE_Y                  &h000001BC ''444

''for some reason, DWL_MSGRESULT isn't defined in FB v1.05.0's 64-bit Windows
''headers, as this may be fixed in future versions, only define this if it isn't already
#Ifndef DWL_MSGRESULT
    #Define DWL_MSGRESULT           &h00000000 ''0
#EndIf

''defines from resource files:

''version information
#Define IDR_VERSIONINFO				&h0001 ''1

''main dialog
#Define IDD_MAIN                    &h03E8 ''1000
#Define IDC_SBR_MAIN                &h03E9 ''1001
#Define IDC_LST_MAIN                &h03EA ''1002
#Define IDC_LST_DRIVES              &h03EB ''1003
#Define IDC_EDT_FILE                &h03EC ''1004
#Define IDC_BTN_PLAY                &h03ED ''1005
#Define IDC_EDT_PATH                &h03EE ''1006
#Define IDC_BTN_GO                  &h03EF ''1007
#Define IDC_BTN_UP                  &h03F0 ''1008
#Define IDC_BTN_REFRESH             &h03F1 ''1009

''paths property sheet
#Define IDD_PATHS                   &h044C ''1100
#Define IDC_STC_VGMPLAYPATH         &h044D ''1101
#Define IDC_EDT_VGMPLAYPATH         &h044E ''1102
#Define IDC_BTN_VGMPLAYPATH         &h044F ''1103
#Define IDC_STC_DEFAULTPATH         &h0450 ''1104
#Define IDC_EDT_DEFAULTPATH         &h0451 ''1105
#Define IDC_BTN_DEFAULTPATH         &h0452 ''1106

''file filter property sheet
#Define IDD_FILEFILTER              &h04B0 ''1200
#Define IDC_GRP_ATTRIB              &h04B1 ''1201
#Define IDC_CHK_ARCHIVE             &h04B2 ''1202
#Define IDC_CHK_HIDDEN              &h04B3 ''1203
#Define IDC_CHK_SYSTEM              &h04B4 ''1204
#Define IDC_CHK_READONLY            &h04B5 ''1205
#Define IDC_CHK_EXCLUSIVE           &h04B6 ''1206

''menus:
''main dialog's menu
#Define IDR_MENUMAIN                &h2710 ''10000
#Define IDM_FILE                    &h2711 ''10001
#Define IDM_EXIT                    &h2712 ''10002
#Define IDM_LIST					&h2713 ''10003
#Define IDM_UP						&h2714 ''10004
#Define IDM_ROOT					&h2715 ''10005
#Define IDM_BACK                    &h2716 ''10006
#Define IDM_REFRESH					&h2717 ''10007
#Define IDM_OPTIONS                 &h2718 ''10008
#Define IDM_ABOUT                   &h2719 ''10009

''context menu
#Define IDR_MENUCONTEXT             &h4E20 ''20000
#Define IDM_LST_DRIVES              &h4E21 ''20001
#Define IDM_LST_DRIVES_REFRESH      &h4E22 ''20002
#Define IDM_LST_MAIN                &h4E23 ''20003
#Define IDM_PROPERTIES              &h4E24 ''20004
#Define IDM_ADDTOLIST               &h4E25 ''20005
#Define IDM_DELETE                  &h4E26 ''20006

''icons:
#Define IDI_VGMPLAYGUI              &h0064 ''100
#Define IDI_KAZUSOFT                &h0065 ''101
#Define IDI_WRENCH                  &h0066 ''102
#Define IDI_PLAY                    &h0067 ''103

''heap object info:
''IDs for plpszPaths
#Define CCH_PATH                    MAX_PATH
#Define CB_PATH                     Cast(SIZE_T, (CCH_PATH * SizeOf(TCHAR)))
#Define C_PATH                      &h00000002 ''2
#Define PATH_VGMPLAY                &h00000000 ''0
#Define PATH_DEFAULT                &h00000001 ''1

''IDs for plpszHistory
/'
        In the final version of this history feature, the value determined
    currently by NUM_HIST will instead be loaded from the registry based on
    the user's preference.
'/
#Define CCH_HIST                    MAX_PATH
#Define CB_HIST                     Cast(SIZE_T, (CCH_HIST * SizeOf(TCHAR)))
#Define C_HIST                      &h00000003 ''3

#Define CCH_APPNAME                 &h00000040 ''64
#Define CB_APPNAME                  Cast(SIZE_T, (CCH_APPNAME * SizeOf(TCHAR)))

''IDs for context menus
#Define MEN_DRIVES                  &h00000000
#Define MEN_MAINLIST                &h00000001

''EOF
