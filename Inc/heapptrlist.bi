/'
    
    heapptrlist.bi
    
    Copyright (c) 2018-2019 Kazusoft Co.
    
'/

#Pragma Once

''include windows header
#Include Once "windows.bi"

''declare functions
Declare Function HeapListAlloc (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT32) As BOOL
Declare Function HeapListFree (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT32) As BOOL
Declare Function LoadStringRange (ByVal hInst As HINSTANCE, ByVal plpszBuff As LPTSTR Ptr, ByVal wIdFirst As WORD, ByVal cchString As UINT32, ByVal cStrings As UINT32) As BOOL

''EOF
