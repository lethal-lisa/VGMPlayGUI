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
#Define CCH_HIST        MAX_PATH
#Define CB_HIST         Cast(SIZE_T, (CCH_HIST * SizeOf(TCHAR)))
#Define C_HIST          &h00000010 ''16

#Define SIZE_HIST_MIN   Cast(SIZE_T, SizeOf(UINT))
#Define SIZE_HIST_MAX   Cast(SIZE_T, (SizeOf(UINT) + (CB_HIST * C_HIST)))

Extern hHist As HANDLE
Extern plpszHist As LPTSTR Ptr

Declare Function InitHistory () As BOOL
Declare Function FreeHistory () As BOOL
Declare Function ClearHistory () As BOOL
Declare Function AddPathToHistory (ByVal lpszPath As LPCTSTR) As BOOL

''EOF
