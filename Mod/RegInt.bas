
''check compiler output type
#If __FB_OUT_LIB__ = 0
#Error "__FB_OUT_LIB__ = 0"
#EndIf

#Print Compiling "RegInt.bas"

''show if 32- or 64-bit target
#Ifdef __FB_64BIT__
#Print "Compiling for 64-bit Windows."
#Else
#Print "Compiling for 32-bit Windows."
#EndIf

''include header
#Include "../inc/regint.bi"

Public Function OpenProgHKey (ByRef phkProgKey As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As BOOL
    
    ''declare local variables
    Dim hkSoftware As HKEY  ''hkey to HKEY_CURRENT_USER\Software
    Dim lResult As LONG32   ''result value
    
    ''open HKEY_CURRENT_USER\Software
    lResult = RegOpenKeyEx(HKEY_CURRENT_USER, "Software", 0, samDesired, @hkSoftware)
    If (lResult <> ERROR_SUCCESS) Then
        SetLastError(Cast(DWORD32, lResult))
        Return(FALSE)
    End If
    
    ''open/create HKEY_CURRENT_USER\Software\<appName>
    lResult = RegCreateKeyEx(hkSoftware, lpszAppName, 0, NULL, 0, samDesired, NULL, phkProgKey, pdwDisp)
    If (lResult <> ERROR_SUCCESS) Then
        SetLastError(Cast(DWORD32, lResult))
        Return(FALSE)
    End If
    
    ''return
    lResult = RegCloseKey(hkSoftware)
    If (lResult <> ERROR_SUCCESS) Then
        SetLastError(Cast(DWORD32, lResult))
        Return(FALSE)
    Else
        SetLastError(ERROR_SUCCESS)
        Return(TRUE)
    End If
    
End Function
