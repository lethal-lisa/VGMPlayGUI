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
Dim Shared nHist As ULONG32

Public Function InitHistory () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    ''allocate desired number of paths
    If (HeapLock(hHist) = FALSE) Then Return(FALSE)
    If (HeapListAlloc(hHist, plpszHist, CB_PATH, nHist) = FALSE) Then Return(FALSE)
    If (HeapUnlock(hHist) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

Public Function FreeHistory () As BOOL
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
    #EndIf
    
    If (HeapLock(hHist) = FALSE) Then Return(FALSE)
    If (HeapListFree(hHist, plpszHist, CB_PATH, nHist) = FALSE) Then Return(FALSE)
    If (HeapUnlock(hHist) = FALSE) Then Return(FALSE)
    
    ''return
    SetLastError(ERROR_SUCCESS)
    Return(TRUE)
    
End Function

''EOF
