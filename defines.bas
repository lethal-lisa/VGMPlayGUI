
#Pragma Once

''defines from resource.rc
#Define IDD_MAIN                &h03E8 /'1000'/

''paths property sheet:
#Define IDD_PATHS               &h044C /'1100'/
#Define IDC_STC_VGMPLAYPATH     &h044D /'1101'/
#Define IDC_EDT_VGMPLAYPATH     &h044E /'1102'/
#Define IDC_BTN_VGMPLAYPATH     &h044F /'1103'/
#Define IDC_STC_DEFAULTPATH     &h0450 /'1104'/
#Define IDC_EDT_DEFAULTPATH     &h0451 /'1105'/
#Define IDC_BTN_DEFAULTPATH     &h0452 /'1106'/
#Define IDC_STC_WAVOUTPATH      &h0423 /'1107'/
#Define IDC_EDT_WAVOUTPATH      &h0424 /'1108'/
#Define IDC_BTN_WAVOUTPATH      &h0425 /'1109'/

''file filter property sheet:
#Define IDD_FILEFILT            &h04B0 /'1200'/
#Define IDC_GRP_ATTRIB          &h04B1 /'1201'/
#Define IDC_CHK_ARCHIVE         &h04B2 /'1202'/
#Define IDC_CHK_HIDDEN          &h04B3 /'1203'/
#Define IDC_CHK_SYSTEM          &h04B4 /'1204'/
#Define IDC_CHK_READONLY        &h04B5 /'1205'/
#Define IDC_CHK_EXCLUSIVE       &h04B6 /'1206'/

''core select property sheet:
#Define IDD_VGMPLAYSETTINGS     &h0514 /'1300'/
#Define IDC_GRP_CORESEL         &h0515 /'1301'/
#Define IDC_CBX_CHIP            &h0516 /'1302'/
#Define IDC_CBX_CORE            &h0517 /'1303'/
#Define IDC_GRP_WAVOUTPUT       &h0518 /'1304'/
#Define IDC_CHK_SPEAKERS        &h0519 /'1305'/
#Define IDC_CHK_WAVFILE         &h051A /'1306'/


''defines from icons.rc:
#Define IDI_VGMPLAYGUI          &h0064 /'100'/
#Define IDI_KAZUSOFT            &h0065 /'101'/
#Define IDI_WRENCH              &h0066 /'102'/
#Define IDI_PLAY                &h0067 /'103'/


''defines from strings.rc:
#Define IDS_APPNAME             &h0001 /'1'/
#Define IDS_OPTIONS             &h0002 /'2'/

''message captions and text
#Define IDS_MSGTXT_ABOUT        &h0011 /'17'/
#Define IDS_MSGCAP_ABOUT        &h0012 /'18'/
#Define IDS_MSGTXT_NYI          &h0013 /'19'/
#Define IDS_MSGCAP_NYI          &h0014 /'20'/
#Define IDS_MSGTXT_VGMPMISS     &h0015 /'21'/
#Define IDS_MSGCAP_VGMPMISS     &h0016 /'22'/
#Define IDS_MSGTXT_CHANGES      &h0017 /'23'/
#Define IDS_MSGCAP_CHANGES      &h0018 /'24'/
#Define IDS_MSGTXT_FILTHELP     &h0019 /'25'/
#Define IDS_MSGCAP_FILTHELP     &h001A /'26'/
#Define IDS_MSGTXT_DELFILE      &h001B /'27'/
#Define IDS_MSGCAP_DELFILE      &h001C /'28'/

''registry key names
#Define IDS_REG_VGMPLAYPATH     &h0021 /'33'/
#Define IDS_REG_DEFAULTPATH     &h0022 /'34'/
#Define IDS_REG_WAVOUTPATH      &h0023 /'35'/
#Define IDS_REG_FILEFILTER      &h0024 /'36'/

''file filters
#Define IDS_FILT_VGMPLAY        &h0031 /'49'/
#Define IDS_FILT_VGMFILE        &h0032 /'50'/

''tooltips
#Define IDS_TIP_DRIVELIST       &h0041 /'65'/
#Define IDS_TIP_BACKBTN         &h0042 /'66'/
#Define IDS_TIP_GOBTN           &h0043 /'67'/
#Define IDS_TIP_REFRESHBTN      &h0044 /'68'/
#Define IDS_TIP_PLAYBTN         &h0045 /'69'/
#Define IDS_TIP_VGMPLAYPATH     &h0046 /'70'/
#Define IDS_TIP_DEFAULTPATH     &h0047 /'71'/
#Define IDS_TIP_WAVOUTPATH      &h0048 /'72'/
#Define IDS_TIP_ARCHIVE         &h0049 /'73'/
#Define IDS_TIP_HIDDEN          &h004A /'74'/
#Define IDS_TIP_SYSTEM          &h004B /'75'/
#Define IDS_TIP_READONLY        &h004C /'76'/
#Define IDS_TIP_EXCLUSIVE       &h004D /'77'/
#Define IDS_TIP_CHIP            &h004E /'78'/
#Define IDS_TIP_CORE            &h004F /'79'/

''defines from menus.rc
#Define IDR_MENU1               &h2710 /'10000'/
#Define IDM_FILE                &h2711 /'10001'/
#Define IDM_ROOT                &h2712 /'10002'/
#Define IDM_EXIT                &h2713 /'10003'/
#Define IDM_OPTIONS             &h2714 /'10004'/
#Define IDM_ABOUT               &h2715 /'10005'/

#Define IDR_MENUCONTEXT         &h4E20 /'20000'/
#Define IDM_LST_MAIN            &h4E21 /'20001'/
#Define IDM_LST_MAIN_REFRESH    &h4E22 /'20002'/
#Define IDM_LST_MAIN_BACK       &h4E23 /'20003'/
#Define IDM_LST_DRIVES          &h4E24 /'20004'/
#Define IDM_LST_DRIVES_REFRESH  &h4E25 /'20005'/


''heap object info:
''ID's for plpszPaths
#Define CCH_PATH            MAX_PATH
#Define CB_PATH             (SizeOf(TCHAR) * CCH_PATH)
#Define NUM_PATH            4
#Define SIZE_PATH           Cast(SIZE_T, (NUM_PATH * CB_PATH))
#Define PATH_VGMPLAY        0
#Define PATH_DEFAULT        1
#Define PATH_CURRENT        2
#Define PATH_WAVOUT         3

''ID's for plpszKeyName
#Define CCH_KEY             32
#Define CB_KEY              (SizeOf(TCHAR) * CCH_KEY)
#Define NUM_KEY             4
#Define SIZE_KEY            Cast(SIZE_T, (NUM_KEY * CB_KEY))
#Define KEY_VGMPLAYPATH     0
#Define KEY_DEFAULTPATH     1
#Define KEY_WAVOUTPATH      2
#Define KEY_FILEFILTER      3

''ID's for plpszStrRes
#Define CCH_STRRES          512
#Define CB_STRRES           (SizeOf(TCHAR) * CCH_STRRES)
#Define NUM_STRRES          4
#Define SIZE_STRRES         Cast(SIZE_T, (NUM_STRRES * CB_STRRES))
#Define STR_APPNAME         0
#Define STR_FILT_VGMPLAY    1
#Define STR_FILT_VGMFILE    2
#Define STR_OPTIONS         3

''child window ID's
#Define IDC_SBR             &h03E9 /'1001'/
#Define IDC_LST_MAIN        &h03EA /'1002'/
#Define IDC_LST_DRIVES      &h03EB /'1003'/
#Define IDC_EDT_FILE        &h03EC /'1004'/
#Define IDC_BTN_PLAY        &h03ED /'1005'/
#Define IDC_EDT_PATH        &h03EE /'1006'/
#Define IDC_BTN_GO          &h03EF /'1007'/
#Define IDC_BTN_BACK        &h03F0 /'1008'/
#Define IDC_BTN_REFRESH     &h03F1 /'1009'/

''EOF
