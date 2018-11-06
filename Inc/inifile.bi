' Ini File Object
' Richard D. Clark
' Public Domain
' This program is free software; you can redistribute it and/or modify it
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
' ================================================================
'Set the ini object namespace.
Namespace inifobj
'Using the string list.
#Include Once "stringlist.bi"

'Define true and false values.
#Ifndef FALSE
#Define FALSE 0
#EndIf
#Ifndef TRUE
#Define TRUE (Not FALSE)
#EndIf

Const iniVersion = "0.1"

'Create the ini file object definition.
Type iniobj
	Private:
	_stlist As stringlist
	_initok As Integer
	_fname As String
	_fexists As Integer
	_version As String        'The current version.
	Declare Function _GetKeyValue (keyvalue As String) As String 'Returns key value from string. 
	Declare Function _GetKey (keyvalue As String) As String 'Returns key from string. 
	Public:
	Declare Constructor (inifile As String)  'Constructor.
	Declare Property Version () As String 'Returns the current version.
	Declare Property InitStatus () As Integer 'Return the initok status.
	Declare Property IniFileName () As String  'Return the current file name.
	Declare Property IniFileExists () As Integer 'Does disk file exist.
	Declare Property Count() As Integer 'The number of strings in the ini file.         
	Declare Function Strings(Index As Integer) As String 'Return a string based on the index.
	Declare Function SectionExists (section As String, ByRef Index As Integer) As Integer 'Return True if section exists.
	Declare Function KeyExists (section As String, skey As String, ByRef Index As Integer) As Integer 'Return True if key in section exists.
	Declare Function ReadString (section As String, skey As String, default As String) As String 'Returns a string value from section/key.
	Declare function UpdateFile() As Integer 'Writes the file to disk. Returns TRUE if successful, False if Not.
	Declare function DeleteSection(section As String) As Integer 'Deletes section and returns true if successful, false if not.
	Declare function DeleteKey(section As String, skey As String) As Integer 'Deletes key and returns true if successful, false if not.
	Declare Sub WriteString (section As String, skey As String, value As String)'Writes a string value to section/key.
	Declare Sub GetSections (ByRef slist As stringlist) 'Returns all sections in passed stringlist.
	Declare Sub GetSectionKeys (section As String, ByRef slist As stringlist) 'Returns all keys in a section in passed stringlist.
	Declare Sub GetSectionKeyValues (section As String, ByRef slist As stringlist) 'Returns all key/values in a section in passed stringlist.
End Type

'Returns key value from string.
Function iniobj._GetKeyValue (keyvalue As String) As String
	Dim As Integer chk
	Dim As String ret = ""
	
	ret = ""
	keyvalue = LTrim(keyvalue)
	'Skip comments.
	If Mid(keyvalue, 1, 1) <> ";" Then
		'Look for =.
		chk = InStr(keyvalue, "=")
		'Found  =.
		If chk < Len(keyvalue) Then
			ret = Mid(keyvalue, chk + 1)
		EndIf
	End If
	
	Return ret
End Function

'Returns key value from string.
Function iniobj._GetKey (keyvalue As String) As String
	Dim As Integer chk
	Dim As String ret = ""
	
	ret = ""
	keyvalue = LTrim(keyvalue)
	'Skip comments.
	If Mid(keyvalue, 1, 1) <> ";" Then
		'Look for =.
		chk = InStr(keyvalue, "=")
		'Found  =.
		If chk > 1 Then
			ret = Mid(keyvalue, 1, chk - 1)
		EndIf
	End If
	
	Return ret
End Function

'Constructor code.
Constructor iniobj (inifile As String)
	
	'Set the default value.
	_initok = TRUE
	'Set the file name.
	_fname = inifile
	'Set default exists flag.
	_fexists = TRUE
	'Set the version.
	_version = strlVersion
	'Make sure we Get a file name.
	If Len(_fname) > 0 Then
		'Load the file if present.
		If Len(Dir(_fname)) > 0 Then
			_initok = _stlist.LoadFromFile(_fname)
		Else
			_fexists = FALSE
		EndIf
	Else
		_initok = FALSE
		_fexists = FALSE
	EndIf
	
End Constructor

'Returns the current version.
Property iniobj.Version () As String
	Return _version
End Property

'Returns the init status of the object. True, ok, False error.
Property iniobj.InitStatus () As Integer
	Return _initok
End Property

'Returns the current ini file name.
Property iniobj.IniFileName () As String
	Return _fname
End Property

'Returns true if file exists, False if it doesn't.
Property iniobj.IniFileExists () As Integer
	Return _fexists
End Property

'Returns the number of strings.
Property iniobj.Count () As Integer
	Return _stlist.Count
End Property

'Returns string at index.
Function iniobj.Strings(Index As Integer) As String
	Dim ret As String = ""
	
	'Make sure we have a valid ini.
	If (_initok = TRUE) And (_stlist.Count > 0) Then
		'Validate the index range.
		If (Index >= 0) And (Index <= _stList.Count) Then
			'Return string.
			ret = _stlist.Strings(Index)
		EndIf
	End If
	
	Return ret
End Function

'Returns True if section name exists.
Function iniobj.SectionExists (section As String, ByRef Index As Integer) As Integer
	Dim As Integer ret
	Dim As String skey = "[" & Trim(section) & "]"
	'Make sure the object was initialized.
	If (_initok = TRUE) And (_stlist.Count > 0) Then
		'Look for section name.
		ret = _stlist.Find(skey, Index) 
	EndIf
	Return ret
End Function

'Returns True if key in section exists.
Function iniobj.KeyExists (section As String, skey As String, ByRef Index As Integer) As Integer
	Dim As Integer iret, chk, idx, ret = FALSE
	Dim As String stmp, sskey = "[" & Trim(section) & "]", tkey = skey
	
	'Set default.
	Index = -1
	'Make sure the object was initialized.
	If (_initok = TRUE) And (_stlist.Count > 0) Then
		'Look for section name.
		iret = _stlist.Find(sskey, idx)
		'Did we find section?
		If iret = TRUE Then
			'Look at each entry in section for key.
			For i As Integer = idx + 1 To _stlist.Count - 1
				'Get the current line from list.
				stmp = Trim(_stlist.Strings(i))
				'Skip comments.
				If Mid(stmp, 1, 1) <> ";" Then
					'Look for =.
					chk = InStr(stmp, "=")
					'Found  =.
					If chk > 1 Then
						'Get key from ini.
						stmp = Left(stmp, chk - 1)
						'Compare to passed key.
						If UCase(stmp) = UCase(tkey) Then
							ret = TRUE
							Index = i
							Exit For
						EndIf
					EndIf
				EndIf
				'See if we have reached a new section.
				If Mid(stmp, 1, 1) = "[" Then Exit For
			Next
		EndIf 
	EndIf
	Return ret
End Function

'Returns a string value from section/key.
Function iniobj.ReadString (section As String, skey As String, default As String) As String
	Dim As Integer idx
	Dim As String istring, svalue
	Dim As String ret = default
	
	'See if section/key exists.
	If KeyExists(section, skey, idx) = TRUE Then
		istring = Strings(idx)
		svalue = _GetKeyValue (istring)
		If Len(svalue) > 0 Then
			ret = svalue
		EndIf
	EndIf
	
	Return ret
End Function 

'Updates file to disk. Returns true if successful, False if not.
Function iniobj.UpdateFile () As Integer
	Dim As Integer ret = FALSE
	
	If _initok = TRUE Then
		ret = _stlist.SaveToFile(_fname)
	EndIf
	Return ret
End Function

'Deletes key from section. Returns true if successful, false if not.
Function iniobj.DeleteSection(section As String) As Integer
	Dim As Integer ret = FALSE, idx
	Dim As string lines
	
	'Check for section.	
	If SectionExists(section, idx) = TRUE Then
		ret = _stlist.DeleteItem(idx)
		lines = Trim(_stlist.Strings(idx))
		Do While (Mid(lines, 1, 1) <> "[") And (idx <= _stlist.Count - 1)
			ret = _stlist.DeleteItem(idx)
			lines = Trim(_stlist.Strings(idx))
		Loop
	End If
	
	Return ret
End Function

'Deletes key from section. Returns true if successful, false if not.
Function iniobj.DeleteKey(section As String, skey As String) As Integer
	Dim As Integer ret = FALSE, idx
	
	'Check for section.	
	If SectionExists(section, idx) = TRUE Then
		If KeyExists(section, skey, idx) = TRUE Then
			ret = _stlist.DeleteItem(idx)
		End If
	End If
	
	Return ret
End Function

'Writes a string value to section/key. Will create it if not found.
Sub iniobj.WriteString (section As String, skey As String, value As String) 
	Dim As Integer sidx, kidx
	
	'If section doesn't exist then add it.
	If SectionExists(section, sidx) = FALSE Then
		sidx = _stlist.Add("[" & UCase(Trim(section)) & "]")
	End If
	If KeyExists(section, skey, kidx) = TRUE Then
		_stlist.Strings(kidx) = Trim(UCase(skey)) & "=" & value
	Else
		If sidx = _stlist.Count - 1 Then
			kidx = _stlist.Add(Trim(UCase(skey)) & "=" & value)
		Else
			kidx = _stlist.InsertItem(sidx + 1, Trim(UCase(skey)) & "=" & value)
		EndIf
	EndIf
	
End Sub 

'Returns all sections in passed stringlist.
Sub iniobj.GetSections (ByRef slist As stringlist)
	Dim As Integer idx, ret
	Dim As string lines

	'Clear the stringlist.
	slist.ClearList
	'Get all sections in ini file.
	For idx = 0 To _stlist.Count - 1
		lines = Trim(_stlist.Strings(idx))
		If (Mid(lines, 1, 1) = "[") Then
			ret = slist.Add(lines)
		EndIf
	Next
	
End Sub

'Returns all strings in a section in passed stringlist.
Sub iniobj.GetSectionKeys (section As String, ByRef slist As stringlist)
	Dim As Integer idx, ret
	Dim As string lines, ky

	If SectionExists(section, idx) = TRUE Then
		'Clear the stringlist.
		slist.ClearList
		idx += 1
		lines = Trim(_stlist.Strings(idx))
		Do While (Mid(lines, 1, 1) <> "[") And (idx <= _stlist.Count - 1)
			ky = _GetKey(lines)
			ret = slist.Add(ky)
			idx += 1
			lines = Trim(_stlist.Strings(idx))
		Loop
	End If
	
End Sub

'Returns all strings in a section in passed stringlist.
Sub iniobj.GetSectionKeyValues (section As String, ByRef slist As stringlist)
	Dim As Integer idx, ret
	Dim As string lines

	If SectionExists(section, idx) = TRUE Then
		'Clear the stringlist.
		slist.ClearList
		idx += 1
		lines = Trim(_stlist.Strings(idx))
		Do While (Mid(lines, 1, 1) <> "[") And (idx <= _stlist.Count - 1)
			ret = slist.Add(lines)
			idx += 1
			lines = Trim(_stlist.Strings(idx))
		Loop
	End If
	
End Sub

End Namespace
