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
Declare Function PruneList (ByVal hWnd As HWND) As BOOL
Declare Function GetListItemType (ByVal hWnd As HWND, ByVal iItem As UINT, ByVal ubType As UByte) As BOOL
Declare Function ImportDirectory (ByVal hDlg As HWND) As BOOL

''other functions
Declare Function ImportDirProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

Public Function PlaylistProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT Export
    
    Static hHeap As HANDLE
    Static lpszFile As LPTSTR
    Static bSaved As BOOL
    Static bReadOnly As BOOL
    
    Select Case uMsg
        Case WM_INITDIALOG
            
            hHeap = GetProcessHeap()
            If (hHeap = INVALID_HANDLE_VALUE) Then Return(FatalSysErrMsgBox(hWnd, GetLastError()))
            
            lpszFile = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
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
                            
                            ZeroMemory(lpszFile, CB_PATH)
                            SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_RESETCONTENT, NULL, NULL)
                            
                        Case IDM_PL_OPEN    ''open a list file
                            
                            If (BrowseOpen(hWnd, lpszFile, bReadOnly) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            If (LoadFromFile(GetDlgItem(hWnd, IDC_LST_PLAYLIST), Cast(LPCTSTR, lpszFile)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_SAVE    ''save the list
                            
                            If (*lpszFile = "") Then Return(TRUE)
                            If (SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_GETCOUNT, NULL, NULL) = 0) Then Return(TRUE)
                            If (SaveToFile(GetDlgItem(hWnd, IDC_LST_PLAYLIST), Cast(LPCTSTR, lpszFile)) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                        Case IDM_PL_SAVEAS  ''save the list with a new name
                            
                            If (SendMessage(GetDlgItem(hWnd, IDC_LST_PLAYLIST), LB_GETCOUNT, NULL, NULL) = 0) Then Return(TRUE)
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
                            
                        Case IDM_PL_IMPORT
                            
                            If (ImportDirectory(hWnd) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
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
    
    ''make sure window handle is valid
    If (hWnd = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
    ''make sure file name is valid
    If ((lpszFile = NULL) Or (*lpszFile = "")) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''make sure the file exists
    If (PathFileExists(lpszFile) = FALSE) Then Return(FALSE)
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (MAX_PATH * SizeOf(TCHAR)))
    If (lpszItem = NULL) Then Return(FALSE)
    
    /'SendMessage(hWnd, LB_RESETCONTENT, NULL, NULL)
    
    Dim hFile As HANDLE = CreateFile(lpszFile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_ARCHIVE, NULL)
    If (hFile = INVALID_HANDLE_VALUE) Then Return(FALSE)'/
    
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
    
    /'SendMessage(hWnd, LB_RESETCONTENT, NULL, NULL)
    
    Dim chChar As TCHAR
    Dim cbRead As SIZE_T
    While (Not(chChar = !"\n"))
        If (ReadFile(hFile, @chChar, SizeOf(TCHAR), Cast(PDWORD, @cbRead), NULL) = FALSE) Then Return(FALSE)
        If (Not(chChar = !"\n")) Then
            If (StringCchCat(lpszItem, STRSAFE_MAX_CCH, Cast(LPCTSTR, @chChar)) = STRSAFE_E_INVALID_PARAMETER) Then
                SetLastError(ERROR_INVALID_PARAMETER)
                Return(FALSE)
            End If
        End If
    Wend'/
    
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
    
    ''make sure window handle is valid
    If (hWnd = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
    ''make sure file name is valid
    If ((lpszFile = NULL) Or (*lpszFile = "")) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''get app heap handle
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate item buffer
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (lpszItem = NULL) Then Return(FALSE)
    
    ''get list item count
    Dim cItems As INT32 = SendMessage(hWnd, LB_GETCOUNT, NULL, NULL)
    If (cItems <= 0) Then Return(FALSE)
    
    'Dim hFile As HANDLE = CreateFile(lpszFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, NULL)
    'If (hFile = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    Dim uFile As UByte = FreeFile()
    Open *lpszFile For Output As #uFile
    
    ''save items
    For iItem As UINT = 0 To (cItems - 1)
        
        ''get an item from the list
        Dim nChars As INT32 = SendMessage(hWnd, LB_GETTEXT, iItem, Cast(LPARAM, lpszItem))
        If (nChars <= 0) Then Return(FALSE)
        
        ''add a new-line char to the end of the item string
        '*lpszItem = (*lpszItem + !"\n")
        /'If (StringCchCat(lpszItem, STRSAFE_MAX_CCH, !"\n") = STRSAFE_E_INVALID_PARAMETER) Then
            SetLastError(ERROR_INVALID_PARAMETER)
            Return(FALSE)
        End If
        
        ''write to the file
        Dim cbBytesWritten As DWORD
        If (WriteFile(hFile, Cast(LPCTSTR, lpszItem), (lstrlen(Cast(LPCTSTR, lpszItem)) * SizeOf(TCHAR)), Cast(PDWORD, @cbBytesWritten), NULL) = FALSE) Then Return(FALSE)'/
        
        Print #uFile, *lpszItem
        
    Next iItem
    
    ''close the file
    'If (CloseHandle(hFile) = FALSE) Then Return(FALSE)
    Close #uFile
    
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
        '.lpstrFileTitle = lpszItem
        '.nMaxFileTitle  = MAX_PATH
        .Flags          = (OFN_DONTADDTORECENT Or OFN_HIDEREADONLY) ''hide read-only since we aren't actually opening the files and disable recent file lists since files don't need to exist
    End With
    
    If (GetOpenFileName(lpOfn) = FALSE) Then Return(FALSE)
    PathStripPath(lpszItem)
    
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
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (lpszItem = NULL) Then Return(FALSE)
    
    If (BrowseItem(hDlg, lpszItem) = FALSE) Then
        HeapFree(hHeap, NULL, lpszItem)
        Return(FALSE)
    End If
    
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
    
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (lpszItem = NULL) Then Return(FALSE)
    
    If (BrowseItem(hDlg, lpszItem) = FALSE) Then
        HeapFree(hHeap, NULL, lpszItem)
        Return(FALSE)
    End If
    
    ''insert the item
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

Private Function PruneList (ByVal hWnd As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
    #EndIf
    
    ''get number of items
    Dim cItems As UINT = SendMessage(hWnd, LB_GETCOUNT, NULL, NULL)
    If (cItems < 1) Then
        SetLastError(ERROR_INVALID_DATA)
        Return(FALSE)
    End If
    
    ''remove invalid list entries
    Dim ubType As UByte
    For iItem As UINT = (cItems - 1) To 0 Step -1
        If (GetListItemType(hWnd, iItem, ubType) = FALSE) Then Return(FALSE)
        If (ubType = FTYPE_INVALID) Then
            If (SendMessage(hWnd, LB_DELETESTRING, iItem, NULL) < 1) Then Exit For
        End If
    Next iItem
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function GetListItemType (ByVal hWnd As HWND, ByVal iItem As UINT, ByVal ubType As UByte) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hWnd\t= 0x"; Hex(hWnd)
        ? !"iItem\t= 0x"; Hex(iItem)
        ? !"ubType\t= 0x"; Hex(ubType)
    #EndIf
    
    ''get process heap
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''allocate an item buffer
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (lpszItem = NULL) Then Return(FALSE)
    
    ''read the item into the buffer
    If (SendMessage(hWnd, LB_GETTEXT, iItem, Cast(LPARAM, lpszItem)) = 0) Then
        If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
        SetLastError(ERROR_SUCCESS)
        Return(FALSE)
    End If
    
    ''convert to lowercase
    CharLower(lpszItem)
    
    ''check for each valid file type
    ubType = FTYPE_INVALID
    If (PathMatchSpec(Cast(LPCTSTR, lpszItem), "*.m3u")) Then ubType = FTYPE_INVALID ''M3U files usually can't link to each other.
    If (PathMatchSpec(Cast(LPCTSTR, lpszItem), "*.vgm")) Then ubType = FTYPE_VGM
    If (PathMatchSpec(Cast(LPCTSTR, lpszItem), "*.vgz")) Then ubType = FTYPE_VGZ
    If (PathMatchSpec(Cast(LPCTSTR, lpszItem), "*.cmf")) Then ubType = FTYPE_CMF
    If (PathMatchSpec(Cast(LPCTSTR, lpszItem), "*.dro")) Then ubType = FTYPE_DRO
    
    ''return
    If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function ImportDirectory (ByVal hDlg As HWND) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hDlg\t= 0x"; Hex(hDlg)
    #EndIf
    
    ''get the playlist editor window's handle
    Dim hWndList As HWND = GetDlgItem(hDlg, IDC_LST_PLAYLIST)
    If (hWndList = INVALID_HANDLE_VALUE) Then
        SetLastError(ERROR_INVALID_HANDLE)
        Return(FALSE)
    End If
    
    Dim hHeap As HANDLE = GetProcessHeap()
    If (hHeap = INVALID_HANDLE_VALUE) Then Return(FALSE)
    
    ''init params for dialog box
    Dim idp As IMPORTDIRPARAMS
    ZeroMemory(@idp, SizeOf(idp))
    idp.lpszPath = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (idp.lpszPath = NULL) Then Return(FALSE)
    idp.dwAttrib = FILE_ATTRIBUTE_NORMAL
    
    ''start the dialog box
    If (DialogBoxParam(hInstance, MAKEINTRESOURCE(IDD_IMPORTDIR), hDlg, @ImportDirProc, Cast(LPARAM, @idp)) <> IDOK) Then Return(FALSE)
    
    ''make sure path is a valid directory
    If (PathIsDirectory(idp.lpszPath) = FALSE) Then
        SetLastError(ERROR_PATH_NOT_FOUND)
        Return(FALSE)
    End If
    
    ''clear list if requested
    If (idp.bClear = TRUE) Then SendMessage(hWndList, LB_RESETCONTENT, NULL, NULL)
    
    ''add all the items in the directory
    Dim lpszItem As LPTSTR = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, CB_PATH)
    If (lpszItem = NULL) Then Return(FALSE)
    *idp.lpszPath = (*idp.lpszPath + "\*")
    Dim ffd As WIN32_FIND_DATA
    Dim hFind As HANDLE = FindFirstFile(Cast(LPCTSTR, idp.lpszPath), @ffd)
    If (hFind = INVALID_HANDLE_VALUE) Then Return(FALSE)
    While (FindNextFile(hFind, @ffd) <> 0)
        If (ffd.dwFileAttributes And idp.dwAttrib)Then
            *lpszItem = ffd.cFileName
            SendMessage(hWndList, LB_ADDSTRING, NULL, Cast(LPARAM, lpszItem))
        End If
    Wend
    If (FindClose(hFind) = FALSE) Then Return(FALSE)
    
    ''free allocated memory, return to initial directory, and return
    If (HeapFree(hHeap, NULL, idp.lpszPath) = FALSE) Then Return(FALSE)
    If (HeapFree(hHeap, NULL, lpszItem) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Private Function ImportDirProc (ByVal hWnd As HWND, ByVal uMsg As UINT32, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
    
    Static pidp As IMPORTDIRPARAMS Ptr
    
    Select Case uMsg
        Case WM_INITDIALOG
            
            ''set the icon
            SendMessage(hWnd, WM_SETICON, NULL, Cast(LPARAM, LoadIcon(hInstance, MAKEINTRESOURCE(IDI_MAKEM3U))))
            
            ''get params
            pidp = Cast(IMPORTDIRPARAMS Ptr, lParam)
            
            ''init controls from params
            
            ''init path
            Dim cchPath As SIZE_T
            If (FAILED(StringCchLength(Cast(LPCTSTR, pidp->lpszPath), MAX_PATH, @cchPath))) Then
                SetLastError(ERROR_INVALID_PARAMETER)
                SysErrMsgBox(hWnd, GetLastError())
                EndDialog(hWnd, -1)
            End If
            If (cchPath > 0) Then
                If (SetDlgItemText(hWnd, IDC_EDT_IMP_PATH, Cast(LPCTSTR, pidp->lpszPath)) = FALSE) Then Return(EndDlgSysErrMsgBox(hWnd, GetLastError()))
            End If
            
            ''init clear
            If (pidp->bClear) Then
                If (CheckDlgButton(hWnd, IDC_CHK_IMP_CLEAR, BST_CHECKED) = FALSE) Then Return(EndDlgSysErrMsgBox(hWnd, GetLastError()))
            Else
                If (CheckDlgButton(hWnd, IDC_CHK_IMP_CLEAR, BST_UNCHECKED) = FALSE) Then Return(EndDlgSysErrMsgBox(hWnd, GetLastError()))
            End If
            
            ''init valid only
            If (pidp->bValidOnly) Then
                If (CheckDlgButton(hWnd, IDC_CHK_IMP_VALIDONLY, BST_CHECKED) = FALSE) Then Return(EndDlgSysErrMsgBox(hWnd, GetLastError()))
            Else
                If (CheckDlgButton(hWnd, IDC_CHK_IMP_VALIDONLY, BST_UNCHECKED) = FALSE) Then Return(EndDlgSysErrMsgBox(hWnd, GetLastError()))
            End If
            
            
        Case WM_CLOSE
            
            EndDialog(hWnd, IDCANCEL)
            
        Case WM_COMMAND
            Select Case HiWord(wParam)
                Case BN_CLICKED
                    Select Case LoWord(wParam)
                        Case IDC_BTN_IMP_OK
                            
                            ''read input
                            
                            /'GetDlgItemText(hWnd, IDC_EDT_IMP_PATH, .lpszDir, MAX_PATH)
                            GetDlgItemText(hWnd, IDC_EDT_IMP_FILT, .lpszFilt, MAX_PATH)'/
                            
                            ''get lpszPath
                            If (GetDlgItemText(hWnd, IDC_EDT_IMP_PATH, pidp->lpszPath, MAX_PATH) = FALSE) Then Return(SysErrMsgBox(hWnd, GetLastError()))
                            
                            ''get bClear
                            If (IsDlgButtonChecked(hWnd, IDC_CHK_IMP_CLEAR) = BST_CHECKED) Then
                                pidp->bClear = TRUE
                            Else
                                pidp->bClear = FALSE
                            End If
                            
                            ''get bValidOnly
                            If (IsDlgButtonChecked(hWnd, IDC_CHK_IMP_VALIDONLY) = BST_CHECKED) Then
                                pidp->bValidOnly = TRUE
                            Else
                                pidp->bValidOnly = FALSE
                            End If
                            
                            pidp->dwAttrib = FILE_ATTRIBUTE_NORMAL
                            If (IsDlgButtonChecked(hWnd, IDC_CHK_IMP_ARCHIVE) = BST_CHECKED) Then pidp->dwAttrib = (pidp->dwAttrib Or FILE_ATTRIBUTE_ARCHIVE)
                            If (IsDlgButtonChecked(hWnd, IDC_CHK_IMP_READONLY) = BST_CHECKED) Then pidp->dwAttrib = (pidp->dwAttrib Or FILE_ATTRIBUTE_READONLY)
                            If (IsDlgButtonChecked(hWnd, IDC_CHK_IMP_HIDDEN) = BST_CHECKED) Then pidp->dwAttrib = (pidp->dwAttrib Or FILE_ATTRIBUTE_HIDDEN)
                            
                            ''close the dialog
                            EndDialog(hWnd, IDOK)
                            
                        Case IDC_BTN_IMP_CANCEL
                            
                            SendMessage(hWnd, WM_CLOSE, NULL, NULL)
                            
                    End Select
                    
                Case EN_ERRSPACE
                    
                    SysErrMsgBox(hWnd, ERROR_NOT_ENOUGH_MEMORY)
                    EndDialog(hWnd, -1)
                    
            End Select
            
        Case Else
            
            Return(FALSE)
            
    End Select
    
    Return(TRUE)
    
End Function

''EOF
