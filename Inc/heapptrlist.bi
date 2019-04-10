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
Declare Function LoadStringRange (ByVal hInst As HINSTANCE, ByVal plpszBuff As LPTSTR Ptr, ByVal wIdFirst As WORD, ByVal cchString As ULONG32, ByVal cStrings As ULONG32) As LRESULT
Declare Function HeapListRealloc (ByVal hHeap As HANDLE, ByVal plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItemsOld As UINT, ByVal cItemsNew As UINT) As BOOL

''EOF
