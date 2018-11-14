/'
    
    chip-settings.bas
    
    compile with:
        fbc -dll ".\Mod\Chip-Settings\chip-settings.bas" ".\Res\Chip-Settings\chip-settings.rc"
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

''include header
#Include Once "chip-settings.bi"

Function DoChipSettingsPropSheet (ByVal hInst As HINSTANCE, ByVal hDlg As HWND) As DWORD32 Export
    
    ''declare local variables
    Dim lpPsp As LPPROPSHEETPAGE    ''property sheet pages
    Dim psh As PROPSHEETHEADER      ''property sheet header
    
    ''allocate space for pages
    lpPsp = Cast(LPPROPSHEETPAGE, LocalAlloc(LPTR, Cast(SIZE_T, (2 * SizeOf(PROPSHEETPAGE)))))
    If (lpPsp = NULL) Then Return(FALSE)
    
    ''setup "Sega PSG" page
    With lpPsp[0]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = (PSP_USEICONID Or PSP_HASHELP)
        .hInstance      = hInst
        .pszTemplate    = MAKEINTRESOURCE(IDD_SEGAPSG)
        .pszIcon        = MAKEINTRESOURCE(IDI_CHIP)
        .pszTitle       = NULL
        .pfnDlgProc     = @SegaPsgProc
        .lParam         = NULL
        .pfnCallback    = NULL
    End With
    
    ''setup "NES APU" page
    With lpPsp[1]
        .dwSize         = SizeOf(PROPSHEETPAGE)
        .dwFlags        = (PSP_USEICONID Or PSP_HASHELP)
        .hInstance      = hInst
        .pszTemplate    = MAKEINTRESOURCE(IDD_NESAPU)
        .pszIcon        = MAKEINTRESOURCE(IDI_CHIP)
        .pszTitle       = NULL
        .pfnDlgProc     = @NesApuProc
        .lParam         = NULL
        .pfnCallback    = NULL
    End With
    
    ''setup property sheet header
    ZeroMemory(@psh, SizeOf(PROPSHEETHEADER))
    With psh
        .dwSize         = SizeOf(PROPSHEETHEADER)
        .dwFlags        = (PSH_USEICONID Or PSH_PROPSHEETPAGE Or PSH_NOCONTEXTHELP Or PSH_HASHELP)
        .hwndParent     = hDlg
        .hInstance      = hInst
        .pszIcon        = MAKEINTRESOURCE(IDI_CHIP)
        .pszCaption     = NULL
        .nPages         = 2
        .nStartPage     = 0
        .ppsp           = Cast(LPCPROPSHEETPAGE, lpPsp)
        .pfnCallback    = NULL
    End With
    
    ''start property sheet
    PropertySheet(@psh)
    
    ''return
    LocalFree(Cast(HLOCAL, lpPsp))
    Return(ERROR_SUCCESS)
    
End Function

Function SegaPsgProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT Export
    
    ''declare local variables
    Static hwndPrpsht As HWND   ''handle to the property sheet
    
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''initialize dialog
        Case WM_NOTIFY      ''notifications
        Case Else
            Return(FALSE)
    End Select
    
    Return(TRUE)
    
End Function

Function NesApuProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT Export
    
    ''declare local variables
    Static hwndPrpsht As HWND   ''handle to the property sheet
    
    Select Case uMsg        ''messages
        Case WM_INITDIALOG  ''initialize dialog
        Case WM_NOTIFY      ''notifications
        Case Else
            Return(FALSE)
    End Select
    
    Return(TRUE)
    
End Function

''EOF
