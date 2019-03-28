/'
    
    heapptrlist.bas
    
    Copyright (c) 2018-2019 Kazusoft Co.
    
    Compile with:
        fbc -c "heapptrlist.bas"
    
'/

''include header
#Include "inc/heapptrlist.bi"

Public Function HeapAllocPtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"plpList\t= 0x"; Hex(plpList)
        ? !"cbItem\t= 0x"; Hex(cbItem)
        ? !"cItems\t= 0x"; Hex(cItems)
        ? !"Total size\t= "; (cbItem * cItems); "Bytes"
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''allocate the list of pointers
    plpList = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (cbItem * cItems))
    If (plpList = NULL) Then Return(GetLastError())
    
    ''allocate each individual item
    For iItem As UINT32 = 0 To (cItems - 1)
        plpList[iItem] = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, cbItem)
        If (plpList[iItem] = NULL) Then Return(GetLastError())
        #If __FB_DEBUG__
            ? "Allocated Item #"; iItem
            ? !"Item Address\t= 0x"; Hex(plpList[iItem])
        #EndIf
    Next iItem
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    Return(ERROR_SUCCESS)
    
End Function

Public Function HeapFreePtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hHeap\t= 0x"; Hex(hHeap)
        ? !"plpList\t= 0x"; Hex(plpList)
        ? !"cbItem\t= 0x"; Hex(cbItem)
        ? !"cItems\t= 0x"; Hex(cItems)
        ? !"Total size\t= "; (cbItem * cItems); "Bytes"
    #EndIf
    
    ''make sure a valid list is being passed
    If (plpList = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''free each individual item
    For iItem As UINT32 = 0 To (cItems - 1)
        If (HeapFree(hHeap, NULL, plpList[iItem]) = FALSE) Then Return(GetLastError())
        #If __FB_DEBUG__
            ? "Freed Item #"; iItem
        #EndIf
    Next iItem
    
    ''free the list of pointers
    If (HeapFree(hHeap, NULL, plpList) = FALSE) Then Return(GetLastError())
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    Return(ERROR_SUCCESS)
    
End Function

Public Function LoadStringRange (ByVal hInst As HINSTANCE, ByVal plpszBuff As LPTSTR Ptr, ByVal wIdFirst As WORD, ByVal cchString As ULONG32, ByVal cStrings As ULONG32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FILE__; "\"; __FUNCTION__
        ? !"hInst\t= 0x"; Hex(hInst)
        ? !"plpszBuff\t= 0x"; Hex(plpszBuff)
        ? !"wIdFirst\t= 0x"; Hex(wIdFirst)
        ? !"cchString\t= "; cchString
        ? !"cStrings\t= "; cStrings
    #EndIf
    
    ''load strings
    For iStr As UINT32 = 0 To (cStrings - 1)
        If (LoadString(hInst, Cast(UINT32, (wIdFirst + iStr)), plpszBuff[iStr], cchString) = 0) Then Return(GetLastError())
        #If __FB_DEBUG__
            ? "Loaded string #"; iStr
            ? !"String ID\t= 0x"; Hex((wIdFirst + iStr))
            ? !"String Address\t= 0x"; Hex(plpszBuff[iStr])
            ? !"String Content\t= "; *plpszBuff[iStr]
        #EndIf
    Next iStr
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

''EOF
