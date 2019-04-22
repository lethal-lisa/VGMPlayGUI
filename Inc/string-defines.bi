/'
    
    string-defines.bi
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#Pragma Once
#Print "Including ""string-defines.bi""."

/'  String Ranges
    0001-00FF - Misc strings
    0100-01FF - Message box captions
    0200-02FF - Message box texts
    0300-03FF - Registry key names
    0400-04FF - Text for tooltips
    0500-05FF - File filters
'/

#Define IDS_APPNAME                 &h0001 ''1
#Define IDS_OPTIONS                 &h0002 ''2
#Define IDS_ABT_DESCRIPTION         &h0003 ''3
#Define IDS_ABT_LEGAL               &h0004 ''4

#Define IDS_MSGCAP_ABOUT            &h0100 ''256
#Define IDS_MSGCAP_NYI              &h0101 ''257
#Define IDS_MSGCAP_VGMPMISS         &h0102 ''258
#Define IDS_MSGCAP_CHANGES          &h0103 ''259
#Define IDS_MSGCAP_FILTHELP         &h0104 ''260
#Define IDS_MSGCAP_DELCONFIRM       &h0105 ''270
#Define IDS_MSGCAP_VGMPLAYKEYS      &h0106 ''271

#Define IDS_MSGTXT_NYI              &h0200 ''512
#Define IDS_MSGTXT_VGMPMISS         &h0201 ''513
#Define IDS_MSGTXT_CHANGES          &h0202 ''514
#Define IDS_MSGTXT_FILTHELP         &h0203 ''515
#Define IDS_MSGTXT_DELCONFIRM       &h0204 ''516
#Define IDS_MSGTXT_VGMPLAYKEYS      &h0205 ''517

#Define IDS_REG_VGMPLAYPATH         &h0300 ''768
#Define IDS_REG_DEFAULTPATH         &h0301 ''769
#Define IDS_REG_DEFAULTLIST         &h0302 ''770
#Define IDS_REG_FILEFILTER          &h0303 ''771

#Define IDS_TIP_DRIVELIST           &h0400 ''1024
#Define IDS_TIP_UPBTN               &h0401 ''1025
#Define IDS_TIP_GOBTN               &h0402 ''1026
#Define IDS_TIP_REFRESHBTN          &h0403 ''1027
#Define IDS_TIP_PLAYBTN             &h0404 ''1028
#Define IDS_TIP_VGMPLAYPATH         &h0405 ''1029
#Define IDS_TIP_DEFAULTPATH         &h0406 ''1030
#Define IDS_TIP_DEFAULTLIST         &h0407 ''1031
#Define IDS_TIP_ARCHIVE             &h0408 ''1032
#Define IDS_TIP_HIDDEN              &h0409 ''1033
#Define IDS_TIP_SYSTEM              &h040A ''1034
#Define IDS_TIP_READONLY            &h040B ''1035
#Define IDS_TIP_EXCLUSIVE           &h040C ''1036
#Define IDS_TIP_DELMOD_RECYCLE      &h040D ''1037
#Define IDS_TIP_DELMOD_REMOVE       &h040E ''1038

#Define IDS_FILT_VGMPLAY            &h0500 ''1280
#Define IDS_FILT_M3U                &h0501 ''1281
#Define IDS_FILT_ADDTOLIST          &h0502 ''1282

''EOF