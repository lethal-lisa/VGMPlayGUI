/'
    
    propsheet-defines.bi
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#Pragma Once
#Print "Including ""propsheet-defines.bi""."

''paths property sheet
#Define IDD_PATHS                   &h044C ''1100
#Define IDC_STC_VGMPLAYPATH         &h044D ''1101
#Define IDC_EDT_VGMPLAYPATH         &h044E ''1102
#Define IDC_BTN_VGMPLAYPATH         &h044F ''1103
#Define IDC_STC_DEFAULTPATH         &h0450 ''1104
#Define IDC_EDT_DEFAULTPATH         &h0451 ''1105
#Define IDC_BTN_DEFAULTPATH         &h0452 ''1106
#Define IDC_STC_DEFAULTLIST         &h0453 ''1107
#Define IDC_EDT_DEFAULTLIST         &h0454 ''1108
#Define IDC_BTN_DEFAULTLIST         &h0455 ''1109

''file filter property sheet
#Define IDD_FILEFILTER              &h04B0 ''1200
#Define IDC_GRP_ATTRIB              &h04B1 ''1201
#Define IDC_CHK_ARCHIVE             &h04B2 ''1202
#Define IDC_CHK_HIDDEN              &h04B3 ''1203
#Define IDC_CHK_SYSTEM              &h04B4 ''1204
#Define IDC_CHK_READONLY            &h04B5 ''1205
#Define IDC_CHK_EXCLUSIVE           &h04B6 ''1206

''general options property sheet
#Define IDD_GENERALOPTS             &h0514 ''1300
#Define IDC_GRP_DELMOD              &h0515 ''1301
#Define IDC_CHK_DELMOD_RECYCLE      &h0516 ''1302
#Define IDC_CHK_DELMOD_REMOVE       &h0517 ''1303

''EOF
