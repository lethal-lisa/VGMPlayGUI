/'
    
    Heap Pointer List Management Library v1.1
    
    HeapPtrList.bi
    
    Copyright (c) 2018 Kazusoft Co.
    
'/

#Pragma Once

''compiler output
#Ifdef __FB_WIN32__
    #If __FB_OUT_EXE__
        #Print "Including ""HeapPtrList""."
        #Inclib "heapptrlist"
    #ElseIf __FB_OUT_LIB__
        #Print "Compiling ""HeapPtrList""."
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
    #Else
        #Error "This file must be compiled as a static library."
    #EndIf
#Else
    #Error "This file must be compiled for Windows."
#EndIf

''include windows header
#Include Once "windows.bi"

''declare functions
Declare Function HeapAllocPtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT
Declare Function HeapFreePtrList (ByVal hHeap As HANDLE, ByRef plpList As LPVOID Ptr, ByVal cbItem As SIZE_T, ByVal cItems As ULONG32) As LRESULT

''EOF
