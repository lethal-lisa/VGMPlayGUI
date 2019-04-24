/'
    
    playlist-editor.bas
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#If __FB_OUT_OBJ__
    #Print "Compiling ""Mod\playlist-editor.bas""."
#Else
    #Error "This file, ""Mod\playlist-editor.bas"" must be compiled as a module."
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

#Include "inc/playlist-editor.bi"

Extern hInstance As HINSTANCE

Declare Function OpenPlayList (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR) As BOOL
Declare Function BrowseOpenPlayList (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR) As BOOL
Declare Function LoadPlayListFromFile (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL

Public Function PlaylistProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    Static hHeap As HANDLE
    Static lpszFile As LPTSTR
    Static bSaved As BOOL
    
    Select Case uMsg
        Case WM_INITDIALOG
            
            hHeap = GetProcessHeap()
            If (hHeap = INVALID_HANDLE_VALUE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            lpszFile = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
            If (lpszFile = NULL) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
        Case WM_CLOSE
            
            If (HeapFree(hHeap, NULL, lpszFile) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            'If (DestroyWindow(hWnd) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            EndDialog(hWnd, ERROR_SUCCESS)
            
        Case WM_COMMAND
            Select Case HiWord(wParam)
                Case BN_CLICKED
                    Select Case LoWord(wParam)
                        Case IDM_PL_NEW     ''new list
                            
                            SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_RESETCONTENT, NULL, NULL)
                            
                        Case IDM_PL_OPEN    ''open a list file
                            
                            If (OpenPlayList(hWnd, lpszFile) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_SAVE    ''save the list
                            
                        Case IDM_PL_SAVEAS  ''save the list with a new name
                            
                        Case IDM_PL_EXIT    ''exit the playlist editor
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                    End Select
                    
                Case Cast(UINT32, LBN_ERRSPACE)
                    
                    ''display error message, and terminate program
                    Return(FatalSysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY))
                    
            End Select
            
        Case Else
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

Private Function OpenPlayList (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR) As BOOL
    
    ''browse for a file
    If (BrowseOpenPlayList(hDlg, lpszFile) = FALSE) Then Return(FALSE)
    
    ''read the file
    If (LoadPlayListFromFile(GetDlgItem(hDlg, IDC_LST_PLAYLIST), Cast(LPCTSTR, lpszFile)) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function BrowseOpenPlayList (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    Dim hHeap As HANDLE = HeapCreate(NULL, (CB_FILT + SizeOf(OPENFILENAME)), NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load file filter
    Dim lpszFilt As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_FILT)
    If (lpszFilt = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_FILT_M3U, lpszFilt, CCH_FILT) = 0) Then Return(FALSE)
    
    ''browse for a new file
    Dim lpOfn As LPOPENFILENAME = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(OPENFILENAME))
    If (lpOfn = NULL) Then Return(FALSE)
    With *lpOfn
        .lStructSize    = SizeOf(OPENFILENAME)
        .hwndOwner      = hDlg
        .hInstance      = hInstance
        .lpstrFilter    = Cast(LPCTSTR, lpszFilt)
        .nFilterIndex   = 1
        .lpstrFile      = lpszFile
        .nMaxFile       = MAX_PATH
        .Flags          = (OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST)
    End With
    
    GetOpenFileName(lpOfn)
    
    ''return
    If (HeapFree(hHeap, NULL, lpOfn) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszFilt) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function LoadPlayListFromFile (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL
    
    ''make sure the file exists
    If (PathFileExists(lpszFile) = FALSE) Then Return(FALSE)
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszItem = NULL) Then Return(FALSE)
    
    ''get a file I/O id
    Dim uf As UByte = FreeFile()
    
    If (Open(*lpszFile For Input As #uf) = 0) Then
        
        While (Not(Eof(uf)))
            
            ''load an item
            Line Input #uf, *lpszItem
            
            ''add the item
            If (Len(*lpszItem) > 0) Then SendMessage(hWnd, LB_ADDSTRING, NULL, Cast(LPARAM, lpszItem))
            
        Wend
        
        Close #uf
        
    Else
        Return(FALSE)
    End If
    
    ''return
    If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
