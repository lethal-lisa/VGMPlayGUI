/'
    
    Heap Pointer List Management Library v1.1
    
    HeapPtrList.bas
    
    Copyright (c) 2018 Kazusoft Co.
    
    Compile with:
        fbc -lib "HeapPtrList.bas"
    
'/

''check compiler output type
#If __FB_OUT_LIB__ = 0
#Error "__FB_OUT_LIB__ = 0"
#EndIf

#Print Compiling "HeapPtrList.bas"

''show if 32- or 64-bit target
#Ifdef __FB_64BIT__
#Print "Compiling for 64-bit Windows."
#Else
#Print "Compiling for 32-bit Windows."
#EndIf

''show if debug mode is enabled
#If __FB_DEBUG__
#Print "Compiling in debug mode."
#Else
#Print "Compiling in release mode."
#EndIf

''include header
#Include Once "../inc/heapptrlist.bi"

Public Function HeapAllocPtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT
    
    #If __FB_DEBUG__
    ? "Calling:", __FUNCTION__
    #EndIf
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''allocate the list of pointers
    plpList = Cast(LPVOID Ptr, HeapAlloc(hHeap, HEAP_ZERO_MEMORY, Cast(SIZE_T, (cbItem * cItems))))
    If (plpList = NULL) Then Return(GetLastError())
    
    ''allocate each individual item
    For iItem As UINT32 = 0 To (cItems - 1)
        plpList[iItem] = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, cbItem)
        If (plpList[iItem] = NULL) Then Return(GetLastError())
    Next iItem
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    Return(ERROR_SUCCESS)
    
End Function

Public Function HeapFreePtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT
    
    #If __FB_DEBUG__
    ? "Calling:", __FUNCTION__
    #EndIf
    
    ''make sure a valid list is being passed
    If (plpList = NULL) Then Return(ERROR_INVALID_PARAMETER)
    
    ''get a lock on the heap
    If (HeapLock(hHeap) = FALSE) Then Return(GetLastError())
    
    ''free each individual item
    For iItem As UINT32 = 0 To (cItems - 1)
        If (HeapFree(hHeap, NULL, plpList[iItem]) = FALSE) Then Return(GetLastError())
    Next iItem
    
    ''free the list of pointers
    If (HeapFree(hHeap, NULL, Cast(LPVOID, plpList)) = FALSE) Then Return(GetLastError())
    
    ''release the lock on the heap
    If (HeapUnlock(hHeap) = FALSE) Then Return(GetLastError())
    
    Return(ERROR_SUCCESS)
    
End Function

''EOF
