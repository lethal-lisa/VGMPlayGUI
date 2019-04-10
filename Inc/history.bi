/'
    
    history.bi
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#Pragma Once
#Include Once "windows.bi"
#Include "inc/heapptrlist.bi"
#Include "defines.bi"

''IDs for plpszHist
/'
        In the final version of this history feature, the value determined
    currently by NUM_HIST will instead be loaded from the registry based on
    the user's preference.
'/
#Define CCH_HIST                    MAX_PATH
#Define CB_HIST                     Cast(SIZE_T, (CCH_HIST * SizeOf(TCHAR)))
#Define C_HIST                      &h00000003 ''3

Extern hHist As HANDLE
Extern plpszHist As LPTSTR Ptr
Extern nHist As ULONG32

''EOF
