/'
    
    defines.bas
    
    Defines for VGMPlayGUI
    
'/

#Pragma Once

''defines
#Define MARGIN_SIZE                 &h0000000A /'(10) distance between adjacent controls'/
#Define WINDOW_SIZE                 &h0000001E /'(30) minimum window length/width'/
#Define MIN_SIZE_X                  &h000001F8 /'504'/
#Define MIN_SIZE_Y                  &h000001BC /'444'/

''for some reason, DWL_MSGRESULT isn't defined in FB v1.05.0's 64-bit Windows
''headers, as this may be fixed in future versions, only define this if it isn't already
#Ifndef DWL_MSGRESULT
    #Define DWL_MSGRESULT           &h00000000 /'0'/
#EndIf

''defines from resource files:

''version information
#Define IDR_VERSIONINFO				&h0001 /'1'/

''main dialog
#Define IDD_MAIN                    &h03E8 /'1000'/
#Define IDC_SBR                     &h03E9 /'1001'/
#Define IDC_LST_MAIN                &h03EA /'1002'/
#Define IDC_LST_DRIVES              &h03EB /'1003'/
#Define IDC_EDT_FILE                &h03EC /'1004'/
#Define IDC_BTN_PLAY                &h03ED /'1005'/
#Define IDC_EDT_PATH                &h03EE /'1006'/
#Define IDC_BTN_GO                  &h03EF /'1007'/
#Define IDC_BTN_UP                  &h03F0 /'1008'/
#Define IDC_BTN_REFRESH             &h03F1 /'1009'/

''paths property sheet
#Define IDD_PATHS                   &h044C /'1100'/
#Define IDC_STC_VGMPLAYPATH         &h044D /'1101'/
#Define IDC_EDT_VGMPLAYPATH         &h044E /'1102'/
#Define IDC_BTN_VGMPLAYPATH         &h044F /'1103'/
#Define IDC_STC_DEFAULTPATH         &h0450 /'1104'/
#Define IDC_EDT_DEFAULTPATH         &h0451 /'1105'/
#Define IDC_BTN_DEFAULTPATH         &h0452 /'1106'/

''file filter property sheet
#Define IDD_FILEFILTER              &h04B0 /'1200'/
#Define IDC_GRP_ATTRIB              &h04B1 /'1201'/
#Define IDC_CHK_ARCHIVE             &h04B2 /'1202'/
#Define IDC_CHK_HIDDEN              &h04B3 /'1203'/
#Define IDC_CHK_SYSTEM              &h04B4 /'1204'/
#Define IDC_CHK_READONLY            &h04B5 /'1205'/
#Define IDC_CHK_EXCLUSIVE           &h04B6 /'1206'/

''vgmplay settings property sheet
#Define IDD_VGMPLAYSETTINGS         &h0514 /'1300'/
#Define IDC_CHK_LOGSOUND            &h0515 /'1301'/
#Define IDC_CHK_PREFERJAPTAG        &h0516 /'1302'/
#Define IDC_BTN_CHIPSETTINGS        &h0517 /'1303'/

''menus:
''main dialog's menu
#Define IDR_MENUMAIN                &h2710 /'10000'/
#Define IDM_FILE                    &h2711 /'10001'/
#Define IDM_EXIT                    &h2712 /'10002'/
#Define IDM_LIST					&h2713 /'10003'/
#Define IDM_UP						&h2714 /'10004'/
#Define IDM_ROOT					&h2715 /'10005'/
#Define IDM_BACK                    &h2716 /'10006'/
#Define IDM_REFRESH					&h2717 /'10007'/
#Define IDM_OPTIONS                 &h2718 /'10008'/
#Define IDM_ABOUT                   &h2719 /'10009'/

''context menu
#Define IDR_MENUCONTEXT             &h4E20 /'20000'/
#Define IDM_LST_DRIVES              &h4E21 /'20001'/
#Define IDM_LST_DRIVES_REFRESH      &h4E22 /'20002'/
#Define IDM_BTN_PLAY                &h4E23 /'20003'/
#Define IDM_BTN_PLAY_PLAY           &h4E24 /'20004'/
#Define IDM_BTN_PLAY_RENDER         &h4E25 /'20005'/
#Define IDM_BTN_PLAY_BOTH           &h4E26 /'20006'/
#Define IDM_BTN_PLAY_CURRENT        &h4E27 /'20007'/

''icons:
#Define IDI_VGMPLAYGUI              &h0064 /'100'/
#Define IDI_KAZUSOFT                &h0065 /'101'/
#Define IDI_WRENCH                  &h0066 /'102'/
#Define IDI_PLAY                    &h0067 /'103'/

''strings:
#Define IDS_APPNAME                 &h0001 /'1'/
#Define IDS_OPTIONS                 &h0002 /'2'/
#Define IDS_FILT_VGMPLAY            &h0003 /'3'/

''message captions and text
#Define IDS_MSGTXT_ABOUT            &h0011 /'17'/
#Define IDS_MSGCAP_ABOUT            &h0012 /'18'/
#Define IDS_MSGTXT_NYI              &h0013 /'19'/
#Define IDS_MSGCAP_NYI              &h0014 /'20'/
#Define IDS_MSGTXT_VGMPMISS         &h0015 /'21'/
#Define IDS_MSGCAP_VGMPMISS         &h0016 /'22'/
#Define IDS_MSGTXT_CHANGES          &h0017 /'23'/
#Define IDS_MSGCAP_CHANGES          &h0018 /'24'/
#Define IDS_MSGTXT_FILTHELP         &h0019 /'25'/
#Define IDS_MSGCAP_FILTHELP         &h001A /'26'/
#Define IDS_MSGTXT_DELFILE          &h001B /'27'/
#Define IDS_MSGCAP_DELFILE          &h001C /'28'/

''registry key names
#Define IDS_REG_VGMPLAYPATH         &h0021 /'33'/
#Define IDS_REG_DEFAULTPATH         &h0022 /'34'/
#Define IDS_REG_FILEFILTER          &h0023 /'35'/

''tooltips
#Define IDS_TIP_DRIVELIST           &h0041 /'65'/
#Define IDS_TIP_UPBTN               &h0042 /'66'/
#Define IDS_TIP_GOBTN               &h0043 /'67'/
#Define IDS_TIP_REFRESHBTN          &h0044 /'68'/
#Define IDS_TIP_PLAYBTN             &h0045 /'69'/
#Define IDS_TIP_VGMPLAYPATH         &h0046 /'70'/
#Define IDS_TIP_DEFAULTPATH         &h0047 /'71'/
#Define IDS_TIP_ARCHIVE             &h0048 /'72'/
#Define IDS_TIP_HIDDEN              &h0049 /'73'/
#Define IDS_TIP_SYSTEM              &h004A /'74'/
#Define IDS_TIP_READONLY            &h004B /'75'/
#Define IDS_TIP_EXCLUSIVE           &h004C /'76'/
#Define IDS_TIP_PREFERJAPTAG        &h004D /'77'/

''heap object info:
''IDs for plpszPaths
#Define CCH_PATH                    MAX_PATH
#Define CB_PATH                     Cast(SIZE_T, (SizeOf(TCHAR) * CCH_PATH))
#Define C_PATH                      &h00000003 /'3'/
#Define SIZE_PATH                   Cast(SIZE_T, (NUM_PATH * CB_PATH))
#Define PATH_VGMPLAY                &h00000000 /'0'/
#Define PATH_DEFAULT                &h00000001 /'1'/
#Define PATH_CURRENT                &h00000002 /'2'/

''IDs for plpszKeyName
#Define CCH_KEY                     &h00000020 /'32'/
#Define CB_KEY                      Cast(SIZE_T, (SizeOf(TCHAR) * CCH_KEY))
#Define C_KEY                       &h00000003 /'3'/
#Define SIZE_KEY                    Cast(SIZE_T, (NUM_KEY * CB_KEY))
#Define KEY_VGMPLAYPATH             &h00000000 /'0'/
#Define KEY_DEFAULTPATH             &h00000001 /'1'/
#Define KEY_FILEFILTER              &h00000002 /'2'/

''IDs for plpszStrRes
#Define CCH_STRRES                  &h00000200 /'512'/
#Define CB_STRRES                   Cast(SIZE_T, (SizeOf(TCHAR) * CCH_STRRES))
#Define C_STRRES                    &h00000002 /'2'/
#Define SIZE_STRRES                 Cast(SIZE_T, (NUM_STRRES * CB_STRRES))
#Define STR_APPNAME                 &h00000000 /'0'/
#Define STR_OPTIONS                 &h00000001 /'1'/

''IDs for plpszHistory
/'
        In the final version of this history feature, the value determined
    currently by NUM_HIST will instead be loaded from the registry based on
    the user's preference.
'/
#Define CCH_HIST                    MAX_PATH
#Define CB_HIST                     Cast(SIZE_T, (SizeOf(TCHAR) * CCH_HIST))
#Define C_HIST                      &h00000003 /'3'/

''IDs for context menus
#Define MEN_DRIVES                  &h00000000
#Define MEN_PLAYBTN                 &h00000001

#Define CCH_BVGMP                   MAX_PATH
#Define CB_BVGMP                    Cast(SIZE_T, (SizeOf(TCHAR) * CCH_BVGMP))
#Define C_BVGMP                     4
#Define BVGMP_RETURN                0
#Define BVGMP_FILT                  1
#Define BVGMP_FILE                  2
#Define BVGMP_FILETITLE             3

''EOF
