/'
    
    createtooltip.bas
    
    Compile with:
        fbc -c "createtooltip.bas"
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#If __FB_OUT_OBJ__
    #Print "Compiling ""Mod\createtooltip.bas""."
#Else
    #Error "This file, ""Mod\createtooltip.bas"" must be compiled as a module."
#EndIf

#Ifdef __FB_64BIT__
    #Print "Compiling for 64-bit Windows."
#Else
    #Print "Compiling for 32-bit Windows."
#EndIf

#If __FB_DEBUG__
    #Print "Compiling in debug mode."
#Else
    #Print "Compiling in release mode."
#EndIf

''include header
#Include "inc/createtooltip.bi"

''creates a tooltip and associates it with a control
Public Function CreateToolTip (ByVal hInst As HINSTANCE, ByVal hDlg As HWND, ByVal dwToolID As DWORD32, ByVal wTextID As WORD, ByVal dwStyle As DWORD32, ByVal uFlags As UINT32) As HWND
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''get tool window
    Dim hwndTool As HWND = GetDlgItem(hDlg, dwToolID)
    If (hwndTool = INVALID_HANDLE_VALUE) Then Return(Cast(HWND, NULL))
    
    ''create tip window
    Dim hwndTip As HWND = CreateWindowEx(NULL, TOOLTIPS_CLASS, NULL, dwStyle, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, hDlg, NULL, hInst, NULL)
    
    ''setup toolinfo
    Dim ti As TOOLINFO
    ZeroMemory(@ti, SizeOf(ti))
    With ti
        .cbSize     = SizeOf(ti)
        .uFlags     = (uFlags Or TTF_IDISHWND Or TTF_SUBCLASS)
        .hwnd       = hDlg
        .uId        = cast(UINT_PTR, hwndTool)
        .hInst      = hInst
        .lpszText   = MAKEINTRESOURCE(wTextID)
    End With
    
    ''associate the tip with the tool
    If (SendMessage(hwndTip, TTM_ADDTOOL, NULL, Cast(LPARAM, @ti)) = FALSE) Then Return(Cast(HWND, NULL))
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(hwndTip)
    
End Function

''EOF
