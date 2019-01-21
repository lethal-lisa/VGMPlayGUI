/'
    
    OpenProgHKey.bas
    
    Compile with:
        fbc -lib "OpenProgHKey.bas"
    
'/

''include header
#Include "openproghkey.bi"

Public Function OpenProgHKey (ByVal phkOut As PHKEY, ByVal lpszAppName As LPCTSTR, ByVal lpszClass As LPCTSTR, ByVal samDesired As REGSAM, ByVal pdwDisp As PDWORD32) As LRESULT
    
    #If __FB_DEBUG__
        ? "Calling:", __FUNCTION__
    #EndIf
    
    ''declare local variables
    Dim hkSoftware As HKEY  ''hkey to HKEY_CURRENT_USER\"Software"
    
    ''open HKEY_CURRENT_USER\Software
    SetLastError(Cast(DWORD32, RegOpenKeyEx(HKEY_CURRENT_USER, "Software", NULL, samDesired, @hkSoftware)))
    If (GetLastError()) Then Return(GetLastError())
    
    ''open/create HKEY_CURRENT_USER\"Software"\*lpszAppName
    SetLastError(Cast(DWORD32, RegCreateKeyEx(hkSoftware, lpszAppName, NULL, NULL, NULL, samDesired, NULL, phkOut, pdwDisp)))
    If (GetLastError()) Then Return(GetLastError())
    
    ''close hkSoftware
    SetLastError(Cast(DWORD32, RegCloseKey(hkSoftware)))
    If (GetLastError()) Then Return(GetLastError())
    
    ''return
    Return(ERROR_SUCCESS)
    
End Function

''EOF
