/'
    
    playlist-editor.bi
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#Pragma Once
#Print "Including ""playlist-editor.bi""."

#Include Once "windows.bi"
#Include Once "win/shlwapi.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "dir.bi"
#Include "inc/heapptrlist.bi"
#Include "inc/errorhandler.bi"
#Include "defines.bi"

#Define CCH_FILT    &h00000200 ''512
#Define CB_FILT     Cast(SIZE_T, (CCH_FILT * SizeOf(TCHAR)))

Type IMPORTDIRPARAMS
    lpszDir As LPTSTR
    lpszFilt As LPTSTR
    bClear As BOOL
End Type

Declare Function PlaylistProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

''EOF
