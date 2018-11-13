/'
    
    chip-settings.bas
    
    compile with:
        fbc -dll ".\Mod\Chip-Settings\chip-settings.bas" ".\Res\Chip-Settings\chip-settings.rc"
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

''include header
#Include Once "chip-settings.bi"

Function SegaPsgProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    ''declare local variables
    Static hwndPrpsht As HWND   ''handle to the property sheet
    
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''initialize dialog
        Case WM_NOTIFY      ''notifications
    End Select
    
End Function

''EOF
