/'
    
    heapptrlist.bi
    
    Copyright (c) 2018-2019 Kazusoft Co.
    
'/

#Pragma Once

''include windows header
#Include Once "windows.bi"

''declare functions
Declare Function HeapListAlloc (ByVal hHeap As HANDLE, ByVal plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT) As BOOL
Declare Function HeapListFree (ByVal hHeap As HANDLE, ByVal plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT) As BOOL
Declare Function HeapListClear (ByVal hHeap As HANDLE, ByVal plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT) As BOOL
Declare Function LoadStringRange (ByVal hInst As HINSTANCE, ByVal plpszBuff As LPTSTR Ptr, ByVal wIdFirst As WORD, ByVal cchString As UINT, ByVal cStrings As UINT) As BOOL

''EOF
