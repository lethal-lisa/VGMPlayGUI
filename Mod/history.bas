/'
    
    history.bas
    
    History functions for VGMPlayGUI
    
    Compile with:
        fbc -c "history.bas"
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

#Include "inc/history.bi"

Dim Shared hHist As HANDLE
Dim Shared plpszHist As LPTSTR Ptr

Public Function InitHistory () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    If (HeapListAlloc(hHist, plpszHist, CB_PATH, C_HIST) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function FreeHistory () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    If (HeapListFree(hHist, plpszHist, CB_PATH, C_HIST) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function ClearHistory () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    If (HeapListClear(hHist, plpszHist, CB_PATH, C_HIST) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function AddPathToHistory (ByVal lpszPath As LPCTSTR) As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"lpszPath\t= 0x"; Hex(lpszPath)
        ? !"*lpszPath\t= "; *lpszPath
    #EndIf
    
    If (HeapLock(hHist) = FALSE) Then Return(FALSE)
    
    ''make room for the new item by moving all the other items up in the array
    Dim nLast As UINT
    For iHist As UINT = 0 To (C_HIST - 1)
        If (*plpszHist[iHist] = "") Then
            nLast = iHist
            Exit For
        End If
        *plpszHist[iHist] = *plpszHist[iHist + 1]
    Next iHist
    
    ''add the new item as the last item in the array
    *plpszHist[nLast] = *lpszPath
    
    ''return
    If (HeapUnlock(hHist) = FALSE) Then Return(FALSE)
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
