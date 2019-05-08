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

Declare Function ContextMenu (ByVal hDlg As HWND, ByVal dwMouse As DWORD32) As BOOL

''browse & load files
Declare Function BrowseOpen (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR, ByVal bReadOnly As BOOL) As BOOL
Declare Function BrowseSave (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR) As BOOL
Declare Function LoadFromFile (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL
Declare Function SaveToFile (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL

''item functions
Declare Function BrowseItem (ByVal hDlg As HWND, ByVal lpszItem As LPTSTR) As BOOL
Declare Function AddItem (ByVal hDlg As HWND) As BOOL
Declare Function InsertItem (ByVal hDlg As HWND) As BOOL
Declare Function RemoveItem (ByVal hWnd As HWND) As BOOL

Public Function PlaylistProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    Static hHeap As HANDLE
    Static lpszFile As LPTSTR
    Static bSaved As BOOL
    Static bReadOnly As BOOL
    
    Select Case uMsg
        Case WM_INITDIALOG
            
            hHeap = GetProcessHeap()
            If (hHeap = INVALID_HANDLE_VALUE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            lpszFile = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
            If (lpszFile = NULL) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_MAKEM3U))))
            
        Case WM_CLOSE
            
            If (HeapFree(hHeap, NULL, lpszFile) = FALSE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            EndDialog(hWnd, ERROR_SUCCESS)
            
        Case WM_COMMAND
            Select Case HiWord(wParam)
                Case BN_CLICKED
                    Select Case LoWord(wParam)
                        Case IDM_PL_NEW     ''new list
                            
                            ZeroMemory(lpszFile, (MAX_PATH * SizeOf(TCHAR)))
                            SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_RESETCONTENT, NULL, NULL)
                            
                        Case IDM_PL_OPEN    ''open a list file
                            
                            If (BrowseOpen(hWnd, lpszFile, bReadOnly) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (LoadFromFile(GetDlgItem(hWnd, IDC_LST_PLAYLIST), Cast(LPCTSTR, lpszFile)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_SAVE    ''save the list
                            
                            If (*lpszFile = "") Then Return(TRUE)
                            If (SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_GETCOUNT, NULL, NULL) = 0) Then Return(TRUE)
                            If (SaveToFile(GetDlgItem(hWnd, IDC_LST_PLAYLIST), Cast(LPCTSTR, lpszFile)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_SAVEAS  ''save the list with a new name
                            
                            If (BrowseSave(hWnd, lpszFile) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (SaveToFile(GetDlgItem(hWnd, IDC_LST_PLAYLIST), Cast(LPCTSTR, lpszFile)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_EXIT    ''exit the playlist editor
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                        Case IDM_PL_ADD     ''add an item to the list
                            
                            If (AddItem(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_INSERT  ''insert an item into the list
                            
                            If (InsertItem(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_REMOVE  ''remove an item from the list
                            
                            If (RemoveItem(GetDlgItem(hWnd, IDC_LST_PLAYLIST)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_PRUNENONEXIST
                            
                            ''get the count of items in the list
                            Dim cItems As INT32 = SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_GETCOUNT, NULL, NULL)
                            If (cItems < 1) Then
                                ''if the list is empty, then return with the message processed code
                                SetWindowLong(hWnd, DWL_MSGRESULT, TRUE)
                                Return(TRUE)
                            End If
                            
                            ''allocate space for a path buffer
                            Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
                            If (lpszItem = NULL) Then
                                SetWindowLong(hWnd, DWL_MSGRESULT, FALSE)
                                Return(SysErrMsgBox(hWnd, GetLastError()))
                            End If
                            
                            ''test each file for existance & remove it if it doesn't
                            For iItem As UINT32 = 0 To (cItems - 1)
                                SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_GETTEXT, iItem, Cast(LPARAM, lpszItem))
                                If (PathFileExists(lpszItem) = FALSE) Then SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_DELETESTRING, iItem, NULL)
                            Next iItem
                            
                            ''free the memory
                            If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then
                                SetWindowLong(hWnd, DWL_MSGRESULT, TRUE)
                                Return(SysErrMsgBox(hWnd, GetLastError()))
                            End If
                            
                    End Select
                    
                Case Cast(UINT32, LBN_ERRSPACE)
                    
                    ''display error message, and terminate program
                    EndDialog(hWnd, ERROR_NOT_ENOUGH_MEMORY)
                    
            End Select
            
        Case Else
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

Private Function BrowseOpen (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR, ByVal bReadOnly As BOOL) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
        ? !"bReadOnly\t= 0x"; Hex(bReadOnly)
    #EndIf
    
    If (hInstance = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
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
        .lpstrFilter    = Cast(LPCTSTR, lpszFilt)
        .nFilterIndex   = 1
        .lpstrFile      = lpszFile
        .nMaxFile       = MAX_PATH
        .Flags          = (OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST)
    End With
    
    If (GetOpenFileName(lpOfn) = TRUE) Then
        If (lpOfn->Flags And OFN_READONLY) Then
            bReadOnly = TRUE
        Else
            bReadOnly = FALSE
        End If
    End If
    
    ''return
    If (HeapFree(hHeap, NULL, lpOfn) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszFilt) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function BrowseSave (ByVal hDlg As HWND, ByVal lpszFile As LPTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    If (hInstance = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
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
        .lpstrFilter    = Cast(LPCTSTR, lpszFilt)
        .nFilterIndex   = 1
        .lpstrFile      = lpszFile
        .nMaxFile       = MAX_PATH
        .Flags          = (OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST)
    End With
    
    If (GetSaveFileName(lpOfn) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapFree(hHeap, NULL, lpOfn) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszFilt) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function LoadFromFile (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    ''make sure the file exists
    If (PathFileExists(lpszFile) = FALSE) Then Return(FALSE)
    
    ''make sure file name is valid
    If (lpszFile = NULL) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszItem = NULL) Then Return(FALSE)
    
    ''get a file I/O id
    Dim uf As UByte = FreeFile()
    
    If (Open(*lpszFile For Input As #uf) = 0) Then
        
        SendMessage(hWnd, LB_RESETCONTENT, NULL, NULL)
        
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

Private Function SaveToFile (ByVal hWnd As HWND, ByVal lpszFile As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"lpszFile\t= 0x"; Hex(lpszFile)
        ? !"*lpszFile\t= "; *lpszFile
    #EndIf
    
    ''make sure file name is valid
    If (lpszFile = NULL) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszItem = NULL) Then Return(FALSE)
    
    ''get file handle
    Dim uf As UByte = FreeFile()
    
    ''get list item count
    Dim cItems As UINT = SendMessage(hWnd, LB_GETCOUNT, NULL, NULL)
    
    ''save items
    If (Open(*lpszFile For Output As #uf) = 0) Then
        
        For iItem As UINT = 0 To (cItems - 1)
            
            ''get an item from the list
            SendMessage(hWnd, LB_GETTEXT, iItem, Cast(LPARAM, lpszItem))
            
            ''write the item to the file
            Print #uf, *lpszItem
            
        Next iItem
        
        ''close the file
        Close #uf
        
    Else
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''return
    If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function BrowseItem (ByVal hDlg As HWND, ByVal lpszItem As LPTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
        ? !"lpszItem\t= 0x"; Hex(lpszItem)
        ? !"*lpszItem\t= "; *lpszItem
    #EndIf
    
    If (hInstance = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
    Dim hHeap As HANDLE = HeapCreate(NULL, SizeOf(OPENFILENAME), NULL)
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''load file filter
    Dim lpszFilt As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_FILT)
    If (lpszFilt = NULL) Then Return(FALSE)
    If (LoadString(hInstance, IDS_FILT_ADDTOLIST, lpszFilt, CCH_FILT) = 0) Then Return(FALSE)
    
    ''browse for the file to add
    Dim lpOfn As LPOPENFILENAME = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, SizeOf(OPENFILENAME))
    If (lpOfn = NULL) Then Return(FALSE)
    With *lpOfn
        .lStructSize    = SizeOf(OPENFILENAME)
        .hwndOwner      = hDlg
        .lpstrFilter    = Cast(LPCTSTR, lpszFilt)
        .nFilterIndex   = 1
        .lpstrFile      = lpszItem
        .nMaxFile       = MAX_PATH
        .Flags          = (OFN_DONTADDTORECENT Or OFN_HIDEREADONLY) ''hide read-only since we aren't actually opening the files and disable recent file lists since files don't need to exist
    End With
    
    If (GetOpenFileName(lpOfn) = FALSE) Then Return(FALSE)
    
    ''return
    If (HeapFree(hHeap, NULL, lpszFilt) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpOfn) = FALSE) Then Return(FALSE)
    If (HeapDestroy(hHeap) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function AddItem (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszItem = NULL) Then Return(FALSE)
    
    If (BrowseItem(hDlg, lpszItem) = FALSE) Then
        HeapFree(hHeap, NULL, lpszItem)
        Return(FALSE)
    End If
    
    PathStripPath(lpszItem)
    
    ''add the item
    SendMessage(GetDlgItem(hDlg, IDC_LST_PLAYLIST), LB_ADDSTRING, NULL, Cast(LPARAM, lpszItem))
    
    ''return
    If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function InsertItem (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszItem = NULL) Then Return(FALSE)
    
    If (BrowseItem(hDlg, lpszItem) = FALSE) Then
        HeapFree(hHeap, NULL, lpszItem)
        Return(FALSE)
    End If
    
    ''add the item
    Dim hWndList As HWND = GetDlgItem(hDlg, IDC_LST_PLAYLIST)
    If (hWndList = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    Dim uIndex As UINT = SendMessage(hWndList, LB_GETCURSEL, NULL, NULL)
    SendMessage(hWndList, LB_INSERTSTRING, uIndex, Cast(LPARAM, lpszItem))
    
    ''return
    If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function RemoveItem (ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    Dim nCurSel As UINT = SendMessage(hWnd, LB_GETCURSEL, NULL, NULL)
    SendMessage(hWnd, LB_DELETESTRING, nCurSel, NULL)
    
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF