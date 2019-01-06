/'
    
    Heap Pointer List Management Library v1.1
    
    HeapPtrList.bi
    
    Copyright (c) 2018 Kazusoft Co.
    
'/
#Pragma Once

#If __FB_OUT_EXE__
#Print "Including HeapPtrList"
#Inclib "heapptrlist"
#EndIf

''check target OS
#Ifndef __FB_WIN32__
#Error "Target OS must be Windows."
#EndIf

''include windows header
#Include Once "windows.bi"

''declare functions
Declare Function HeapAllocPtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT
Declare Function HeapFreePtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT

''EOF
