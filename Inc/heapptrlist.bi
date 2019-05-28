/'
    
    heapptrlist.bi
    
    Copyright (c) 2018-2019 Kazusoft Co.
    
'/

#Pragma Once

''include windows header
#Include Once "windows.bi"

/'Type HEAP_LIST
    plpList As LPVOID Ptr
    cbItem As SIZE_T
    cItems As UINT
    Declare Property cbTotal () As SIZE_T
End Type'/

''declare functions
/'  HeapListAlloc:
    
    /'  Description:
        
            Allocates a specified number of values of a specified size in a
        heap. The values are zeroed out when allocating.
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hHeap As HANDLE
            
                The heap to allocate values into.
            
        '/
        
        /'  ByRef plpList As LPVOID Ptr
            
                Pointer to a list of values. When calling, this must be a
            NULL pointer. Upon returning this parameter will be a pointer to
            the start of the list of items.
            
        '/
        
        /'  ByVal cbItem As SIZE_T
            
                The size in BYTEs of each item to allocate in the list.
            
        '/
        
        /'  ByVal cItems As UINT
            
                The number of items to allocate in the list.
            
        '/
        
    '/
    
    /'  Return Value:
        
            <description>
        
    '/
    
'/
Declare Function HeapListAlloc (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT) As BOOL

/'  HeapListFree:
    
    /'  Description:
        
            <description>
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hHeap As HANDLE
            
                <description>
            
        '/
        
        /'  ByRef plpList As LPVOID Ptr
            
                <description>
            
        '/
        
        /'  ByVal cbItem As SIZE_T
            
                <description>
            
        '/
        
        /'  ByVal cItems As UINT
            
                <description>
            
        '/
        
    '/
    
    /'  Return Value:
        
            <description>
        
    '/
    
'/
Declare Function HeapListFree (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT) As BOOL

Declare Function HeapListFill (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As UINT, ByVal lpValue As LPBYTE) As BOOL

/'  LoadStringRange:
    
    /'  Description:
        
            <description>
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hInst As HINSTANCE
            
                <description>
            
        '/
        
        /'  ByVal plpszBuff As LPTSTR Ptr
            
                <description>
            
        '/
        
        /'  ByVal wIdFirst As WORD
            
                <description>
            
        '/
        
        /'  ByVal cchString As UINT32
            
                <description>
            
        '/
        
        /'  ByVal cStrings As UINT32
            
                <description>
            
        '/
        
    '/
    
    /'  Return Value:
        
            <description>
        
    '/
    
'/
Declare Function LoadStringRange (ByVal hInst As HINSTANCE, ByVal plpszBuff As LPTSTR Ptr, ByVal wIdFirst As WORD, ByVal cchString As UINT32, ByVal cStrings As UINT32) As BOOL

''EOF
