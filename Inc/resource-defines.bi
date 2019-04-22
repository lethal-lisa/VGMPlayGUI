/'
    
    resource-defines.bi
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#Pragma Once
#Print "Including ""resource-defines.bi""."
#Include "inc/menu-defines.bi"
#Include "inc/propsheet-defines.bi"
#Include "inc/string-defines.bi"
#Include "inc/playlist-editor-defines.bi"

''version info
#Define IDR_VERSIONINFO				&h0001 ''1

''main dialog
#Define IDD_MAIN                    &h03E8 ''1000
#Define IDC_SBR_MAIN                &h03E9 ''1001
#Define IDC_LST_MAIN                &h03EA ''1002
#Define IDC_LST_DRIVES              &h03EB ''1003
#Define IDC_EDT_FILE                &h03EC ''1004
#Define IDC_EDT_PATH                &h03ED ''1005
#Define IDC_BTN_PLAY                &h03EE ''1006
#Define IDC_BTN_GO                  &h03EF ''1007
#Define IDC_BTN_UP                  &h03F0 ''1008
#Define IDC_BTN_REFRESH             &h03F1 ''1009

''icons:
#Define IDI_VGMPLAYGUI              &h0064 ''100
#Define IDI_KAZUSOFT                &h0065 ''101
#Define IDI_WRENCH                  &h0066 ''102
#Define IDI_PLAY                    &h0067 ''103

''EOF
