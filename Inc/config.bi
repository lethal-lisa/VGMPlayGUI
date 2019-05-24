/'
    
    config.bi
    
    Copyright (c) 2019 Kazusoft Co.
    
'/

/'  Config structure
    [HKEY_CURRENT_USER\Software\VGMPlayGUI]
    Name:               Type:       Default Value:
    (default)           REG_SZ      (N/A)
    "Default Path"      REG_SZ      (N/A)
    "Default Playlist"  REG_SZ      (N/A)
    "File Filter"       REG_DWORD   0x10 (16)
    "VGMPlay Path"      REG_SZ      (N/A)
'/

#Pragma Once
#Print "Including ""config.bi""."

#Include Once "windows.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/prsht.bi"
#Include "inc/createtooltip.bi"
#Include "inc/heapptrlist.bi"
#Include "inc/errorhandler.bi"
#Include "defines.bi"

#Define CCH_BVGMP           MAX_PATH
#Define CB_BVGMP            Cast(SIZE_T, (CCH_BVGMP * SizeOf(TCHAR)))
#Define C_BVGMP             4
#Define BVGMP_RETURN        0
#Define BVGMP_FILT          1
#Define BVGMP_FILE          2
#Define BVGMP_FILETITLE     3

''page count and IDs
#Define C_PAGES             3
#Define PG_PATHS            0
#Define PG_FILEFILT         1
#Define PG_GENERALOPTS      2

''IDs for plpszKeyName
#Define CCH_KEY             &h00000020 ''32
#Define CB_KEY              Cast(SIZE_T, (CCH_KEY * SizeOf(TCHAR)))
#Define C_KEY               &h00000003 ''3
#Define KEY_VGMPLAYPATH     &h00000000 ''0
#Define KEY_DEFAULTPATH     &h00000001 ''1
#Define KEY_FILEFILTER      &h00000002 ''2

Extern hConfig As HANDLE
Extern plpszPath As LPTSTR Ptr
Extern dwFileFilt As DWORD32

/'  DoOptionsPropSheet:
    
    /'  Description:
        
            Starts the options property sheet dialog.
        
    '/
    
    /'  Parameters:
        
        /'  ByVal hDlg As HWND
            
                Handle to the dialog to use as a parent window.
            
        '/
        
        /'  ByVal nStartPage As UINT = PG_PATHS
            
                Page ID of the property sheet page to start on. This
            defaults to the Paths page if this value is not included.
            
        '/
        
    '/
    
    /'  Return Value:
        
            Returns TRUE on success and FALSE on failure. To get more
        detailed error information, call GetLastError().
        
    '/
    
'/
Declare Function DoOptionsPropSheet (ByVal hDlg As HWND, ByVal nStartPage As UINT = PG_PATHS) As BOOL

/'  InitConfig:
    
    /'  Description:
        
            Initializes the config module. This must be called before using
        any other config functions.
        
    '/
    
    /'  Return Value:
        
            Returns TRUE on success and FALSE on failure. To get more
        detailed error information, call GetLastError().
        
    '/
    
'/
Declare Function InitConfig () As BOOL

/'  FreeConfig:
    
    /'  Description:
        
            Frees the memory allocated by the config module. This must be
        called before exiting the program.
        
    '/
    
    /'  Return Value:
        
            Returns TRUE on success and FALSE on failure. To get more
        detailed error information, call GetLastError().
        
    '/
    
'/
Declare Function FreeConfig () As BOOL

/'  LoadConfig:
    
    /'  Description:
        
            Loads the config information into memory from the registry.
        
    '/
    
    /'  Return Value:
        
            Returns TRUE on success and FALSE on failure. To get more
        detailed error information, call GetLastError().
        
    '/
    
'/
Declare Function LoadConfig () As BOOL

/'  SaveConfig:
    
    /'  Description:
        
            Writes the config information from memory to the registry.
        
    '/
    
    /'  Return Value:
        
            Returns TRUE on success and FALSE on failure. To get more
        detailed error information, call GetLastError().
        
    '/
    
'/
Declare Function SaveConfig () As BOOL

''EOF
