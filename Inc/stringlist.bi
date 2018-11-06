' Basic String List Object
' Richard D. Clark
' Use at your own risk.
' Public Domain
' This program is free software; you can redistribute it and/or modify it
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
' ================================================================

#Include Once "crt.bi"

Const strlVersion = "0.1"

'Create a NULL value.
#Ifndef NULL
#Define NULL 0
#EndIf

'Define true and false values.
#Ifndef FALSE
#Define FALSE 0
#EndIf
#Ifndef TRUE
#Define TRUE (Not FALSE)
#EndIf



'Needed by the compare function.
Dim Shared casesense As Integer
Dim Shared sortype As Integer

'This is our little stringlist object.
Type stringlist
	Private:
	_listcount As Integer 'The number of items in list.
	_list As ZString Ptr Ptr 'List of pointers to zstrings.
	_issorted As Integer       'Is list sorted.
	_casesense As Integer      'True if case sensitive, False if not.
	_sortype As Integer        'The last sorting mode.
	_version As String        'The current version.
	Declare Sub _DestroyList () 'Used to clear the pointer list.
	Declare Function _AddItemToList(item As String) As Integer 'Adds a new item to the list.
	Declare Static Function _QCompare Cdecl (e1 As Any Ptr, e2 As Any Ptr) As Integer
	Public:
	Declare Constructor () 'Object constructor.
	Declare Destructor () 'Used to clean up list, calls _DestroyList. Used when object goes out of scope.
	Declare Property Version () As String 'Returns the current version.
	Declare Property Count () As Integer 'Returns the number of items in list.
	Declare Property Sorted () As Integer 'Returns true if list is sorted.
	Declare Property Strings (index As Integer, item As String) 'Sets item based on index.
	Declare Property Strings (index As Integer) As String 'Returns item based on index.
	Declare Property Text (delimiter As String, txt As String) 'Sets stringlist based on text.
	Declare Property Text (delimiter As String) As String 'Returns string as text delimited by delimiter.
	Declare Property CaseSensitive (scase As Integer) 'Sets the case sensitive value.
	Declare Property CaseSensitive () As Integer 'Returns the case sensitive value.
	Declare Property SortAscending (sortdir As Integer) 'Sets the case sensitive value.
	Declare Property SortAscending () As Integer 'Returns the case sensitive value.
	Declare Function LoadFromFile (fname As String) As Integer 'Loads data from file, loads into list.
	Declare Function SaveToFile (fname As String) As Integer 'Save data to a line-based text file.
	Declare Function Add (item As String) As Integer 'Adds an item to the list, returns index value or -1.
	Declare Function InsertItem (index As Integer, item As String) As Integer 'Inserts item at index.
	Declare Function DeleteItem (index As Integer) As Integer 'Deletes item with index.
	Declare Function Move (fromindex As Integer, toindex As Integer) As Integer 'Moves item from index to index.
	Declare Function Find (fkey As String, ByRef index As Integer) As Integer 'Returns True if found, False if not. Index contains position.
	Declare Function IsEqual(sl As stringlist) As Integer 'Compares two stringlists and returns True if equal, False if not. 
	Declare Sub ClearList () 'Resets list. Calls _DestroyList.
	Declare Sub SwapItems (index1 As Integer, index2 As Integer) 'Swaps two index items.
	Declare Sub Sort () 'Sorts list.
	Declare Sub Copy (ByRef sl As stringlist) 'Creates a new copy of stringlist. 
End Type

'Object constructor, called when created.
Constructor stringlist ()
	'Set the default values.
	_issorted = FALSE
	_list = NULL
	_listcount = 0
	_casesense = FALSE
	casesense = FALSE
	_sortype = TRUE
	sortype = TRUE
	_version = strlVersion
End Constructor

'This will be called when object goes out of scope. Needed to clean up.
Destructor stringlist ()
	_DestroyList
End Destructor

'Returns the current version.
Property stringlist.Version () As String
	Return _version
End Property

'Returns the current number of items in list.
Property stringlist.Count () As Integer
	Return _listcount
End Property

'Returns true if list is sorted.
Property stringlist.Sorted () As Integer 
	Return _issorted
End Property

'Sets the comparison value.
Property stringlist.CaseSensitive (scase As Integer)
	'Validate the value.
	If scase = TRUE Then 
		_casesense = TRUE
	Else
		_casesense = FALSE
	End If
	casesense = _casesense
End Property

'Returns the comparison value.
Property stringlist.CaseSensitive () As Integer 
	Return _casesense
End Property

'Sets the sorting order.
Property stringlist.SortAscending (sortdir As Integer)
	'Validate the value.
	If sortdir = TRUE Then 
		_sortype = TRUE
	Else
		_sortype = FALSE
	End If
	sortype = _sortype
End Property

'Returns the comparison value.
Property stringlist.SortAscending () As Integer 
	Return _sortype
End Property

'Gets an item from the list.
Property stringlist.Strings (index As Integer) As String
	Dim ret As String = ""
	
	'Make sure we have a valid list.
	If _list Then
		'Make sure index is within bounds.
		If (index >= 0) And (index <= _listcount - 1) Then
			'Make sure we have a valid pointer.
			If _list[index] Then
				ret = *_list[index]
			Else
				ret = ""
			End If
		EndIf
	End If
	
	Return ret
End Property

'Replaces a string item in the list.
Property stringlist.Strings(index As Integer, item As String)
	Dim As Integer itemlen
	
	'Make sure we have a valid list.
	If _list Then
		'Make sure index is within bounds.
		If (index >= 0) And (index <= _listcount - 1) Then
			itemlen = Len(item)
			'Make sure we have a string.
			If itemlen > 0 Then
				'Adjust the size of the zstring.
				_list[index] = ReAllocate (_list[index], itemlen + 1)
				'Make sure we have a valid pointer.
				If _list[index] Then
					'Set the list item text.
					*_list[index] = item
				Else
					'Some error so clear the item.
					DeAllocate _list[index]
					_list[index] = NULL
				End If
			Else
				'If emptyy string deallocate and set to null.
				DeAllocate _list[index]
				_list[index] = NULL
			End If
		EndIf
	'Reset the sorted flag.
	_issorted = FALSE
	End If
	
End Property

'Sets stringlist based on item text. Parsed using delimiter.
Property stringlist.Text (delimiter As String, txt As String)
	Dim As String tx, tmpt
	Dim As Integer idx, ld
	
	'Get length of delimiter.
	ld = Len(delimiter)
	'Get copy of text.
	tx = txt
	'Make sure we have a a delimiter.
	If (ld > 0) And (Len(tx) > 0) Then
		'Clear current list.
		_DestroyList
		Do 
			'Extract each record in the text and add to the list.
			idx = InStr(tx, delimiter)
			tmpt = Left(tx, idx - 1)
			Add(tmpt)
			tx = Mid(tx, idx + ld)
		Loop While Len(tx) > 0
	EndIf 
	
End Property 

'Returns string as text delimited by delimiter.
Property stringlist.Text (delimiter As String) As String
	Dim ret As String = ""
	
	'Make sure have a valid list.
	If _list Then
		'Make sure we have a delimiter.
		If Len(delimiter) > 0 Then
			For i As Integer = 0 To _listcount - 1
				ret += Strings(i) & delimiter 
			Next
		EndIf
	End If
	
	Return ret
End Property 

'This adds an item to the string list.
Function stringlist._AddItemToList(item As String) As Integer
	Dim As Integer itemlen
	Dim ret As Integer = TRUE
	
	'We'll need this for the zstring.
	itemlen = Len(item)
	_listcount += 1
	'Add a new item to the list.
	_list = ReAllocate (_list, _listcount * SizeOf (ZString Ptr))
	'Make sure we have a valid pointer.
	If _list Then
		'Reset the sorted flag.
		_issorted = FALSE
		'Check to see if we have an empty string.
		If itemlen = 0 Then
			_list[_listcount - 1] = NULL
		Else
			'Create a new zstring.
			_list[_listcount - 1] = Allocate(itemlen + 1) 'Add a space for the null terminator.
			If _list[_listcount - 1] Then
				'Set the list item text.
				*_list[_listcount - 1] = item
			Else
				'Set it to null.
				_list[_listcount - 1] = NULL
			EndIf
		End If
	Else
		ret = FALSE
	EndIf
	
	Return ret
End Function

'Adds an item to the list. Will create list if not created. Returns index of item if successful, or
'-1 if not successful.
Function stringlist.Add (item As String) As Integer
	If _AddItemToList(item) = TRUE Then
		Return _listcount - 1
	Else
		Return -1
	EndIf
	
End Function
	 
'Loads a list of items from a file. Clears current list, if any.
Function stringlist.LoadFromFile (fname As String) As Integer
	Dim ret As Integer = TRUE
	Dim instring As String
	
	'Reset the current state of the object.
	_DestroyList
	'Make sure we get a file name.
	If Len(fname) > 0 Then
		'Get a file handle.
		Dim fh As Integer = FreeFile
		'make sure we can open the file.
		If Open (fname For Input As #fh) = 0 Then
			Do While Not Eof(fh)
				'Load up each item in the file.
				Line Input #fh, instring
				If Len(instring) > 0 Then
					'Add the item to the list.
					If _AddItemToList(instring) = FALSE Then
						'Set the return value.
						ret = FALSE
						'Can't go on since we have some memory problem.
						Exit Do
					EndIf 
				EndIf
			Loop
			'Close file.
			Close #fh
		Else
			ret = FALSE
		EndIf
	Else
		ret = FALSE
	EndIf
	'If ret = false, clean up any partial list that may have been created.
	If ret = FALSE Then
		_DestroyList
	EndIf
	'Return the result. True = list created, False = some error.
	Return ret
End Function

'Save the contexts of the stringlist to a line-based file.
Function stringlist.SaveToFile (fname As String) As Integer
	Dim ret As Integer = TRUE
	Dim As Integer fh = FreeFile
	Dim outstr As String
	
	'Make sure we have a valid list.
	If _list Then
		'Make sure we have a file name.
		If Len(fname) > 0 Then
			'Open file for output.
			If Open (fname For Output As #fh) = 0 Then
				'Get each string and save to file.
				For i As Integer = 0 To _listcount - 1
					outstr = Strings(i)
					Print #fh, outstr
				Next
				'Close the file.
				Close #fh
			Else
				ret = FALSE
			EndIf
		Else
			ret = FALSE
		EndIf
	Else
		ret = FALSE
	End If
	Return ret
		
End Function

'Deletes item with index. Returns True if successful, False if not.
Function stringlist.DeleteItem (index As Integer) As Integer
	Dim ret As Integer = TRUE
	
	'Make sure we have a valid list.
	If _list Then
		'Make sure index is within bounds.
		If (index >= 0) And (index <= _listcount - 1) Then
			'Deallocate the string from the list.
			DeAllocate _list[index]
			'Move all the string items down by one.
			For i As Integer = index To _listcount - 2
				_list[i] = _list[i + 1]
			Next
			'Set last item to NUll so we don't delete string that has moved.
			_list[_listcount - 1] = NULL
			'Delete the last item from the list.
			DeAllocate _list[_listcount - 1] 
			'Set the new list count.
			_listcount -= 1
			'Make sure we still have some items in list.
			If _listcount > 0 Then
				'Resize the list.
				_list = ReAllocate (_list, _listcount * SizeOf (ZString Ptr))
			Else
				'Clear the list.
				DeAllocate _list
				_list = NULL
				'Reset the sorted flag.
				_issorted = FALSE
			End If
		Else
			ret = FALSE
		EndIf
	Else
		ret = FALSE
	End If
	
	Return ret
	
End Function

'Inserts item at index. If successful, returns True, else False.
Function stringlist.InsertItem(index As Integer, item As String) As Integer
	Dim ret As Integer = TRUE
	Dim itemlen As Integer = Len(item)
	
	'Make sure we have a valid list.
	If _list Then
		'Make sure index is within bounds.
		If (index >= 0) And (index <= _listcount) Then
			'If index is at end of list just add the item.
			If index = _listcount Then
				ret = _AddItemToList(item)
			Else
				'Increase the list count.
				_listcount += 1
				'Enlarge the list.
				_list = ReAllocate (_list, _listcount * SizeOf (ZString Ptr))
				'Move each item up by 1.
				For i As Integer = _listcount - 2 To index Step -1
					_list[i + 1] = _list[i]
				Next
				'Insert new item at index.
				If itemlen > 0 Then
					_list[index] = Allocate(itemlen + 1) 'Add a space for the null terminator.
					If _list[index] Then
						'Set the list item text.
						*_list[index] = item
						'Set the sort flag.
						_issorted = FALSE
					Else
						'Set it to null.
						_list[index] = NULL
						'Set the sort flag.
						_issorted = FALSE
					EndIf
				Else
					_list[index] = NULL
				EndIf
			End If
		Else
			ret = FALSE
		End If
	Else
		ret = FALSE
	EndIf
	
	Return ret
End Function

'Moves item from index to index, adjusting items to make room.
Function stringlist.Move (fromindex As Integer, toindex As Integer) As Integer
	Dim ret As Integer = TRUE
	Dim As String item
	
	'Validate the indexes.
	If fromIndex <> toIndex Then
		If (fromindex >= 0) And (fromindex <= _listcount - 1) Then
			If (toindex >= 0) And (toindex <= _listcount) Then
				'Get the string.
				item = Strings(fromindex)
				'Do an insert followed by a delete.
				ret = InsertItem(toindex, item)
				If ret = TRUE Then
					ret = DeleteItem(fromindex)
					'Set the sort flag.
					_issorted = FALSE
				EndIf
			Else
				ret = FALSE
			End If
		Else
			ret = FALSE
		EndIf 
	Else
		ret = FALSE
	End If
	Return ret
End Function

'Finds element in list.
Function stringlist.Find (fkey As String, ByRef index As Integer) As Integer
	Dim ret As Integer = FALSE
	Dim As String item, ffkey = fkey
	
	'Set the default.
	index = -1
	'Make sure we have a valud list.
	If _list Then
		'What comparison value is active.
		If _casesense = FALSE Then
			ffkey = UCase(ffkey)
		End If
		'If the list is not sorted do a linaear search.
		If (_issorted = FALSE) Or (_sortype = FALSE) Then
			'Iterate through each element.
			For i As Integer = 0 To _listcount - 1
				'If not an empty string get item.
				If _list[i] Then
					item = *_list[i]
				Else
					item = ""
				EndIf
				If _casesense = FALSE Then
					item = UCase(item)
				End If
				'If found item, set the index and return.
				If ffkey = item Then
					index = i
					ret = TRUE
					Exit For
				EndIf 
			Next
		Else
			'Do a binary search on the list.
			Dim As Integer imid
			Dim As Integer first = 0
			Dim As Integer last = _listcount - 1
			Do While  first <= last 
				imid = (first + last) / 2
				'If not an empty string get item.
				If _list[imid] Then
					item = *_list[imid]
				Else
					item = ""
				EndIf
				'Set case type.
				If _casesense = FALSE Then
					item = UCase(item)
				End If
				'Compare the values.
				If item = ffkey Then
					index = imid
					ret = TRUE
					Exit Do
				ElseIf item > ffkey Then
					last = imid - 1
				Else
					first = imid + 1
				End If
			Loop
		End If
	End If
	Return ret	
End Function 

'Compares two stringlists and returns True if equal, False if not.
Function stringlist.IsEqual(sl As stringlist) As Integer
	Dim ret As integer = TRUE
	Dim As String t1, t2
	
	If sl.Count = _listcount Then
		'Make sure we have some strings in the list.
		If (sl.Count > 0) And (_listcount) > 0 Then
			'Iterate through each list and compare strings.
			For i As Integer = 0 To _listcount - 1
				'Get the two strings.
				t1 = sl.Strings(i)
				t2 = Strings(i)
				'If not case sensitive.
				If _casesense = FALSE Then
					t1 = UCase(t1)
					t2 = UCase(t2)
				EndIf
				'Compare the strings.
				If t1 <> t2 Then
					ret = FALSE
					Exit For
				EndIf
			Next
		EndIf
	Else
		ret = FALSE
	EndIf
	
	Return ret
End Function 


'Destroys the list, if any.
Sub stringlist._DestroyList ()
	'Make sure we have some items in the list.
	If _list Then
		For i As Integer = _listcount - 1 To 0 Step -1
			'Delete each item in list.
			DeAllocate _list[i]
		Next
		'Delete the list.
		DeAllocate _list
		'Set the list ptr to null.
		_list = NULL
		'Reset the list count.
		_listcount = 0
		'Reset the sorted flag.
		_issorted = FALSE
	EndIf
End Sub


'Clear current list.
Sub stringlist.ClearList()
	_DestroyList
End Sub

'Swaps two items in the list.
Sub stringlist.SwapItems (index1 As Integer, index2 As Integer)
	
	'Make sure we have a valid list.
	If _list Then
		If index1 <> index2 Then
			'Make sure indexes is within bounds.
			If (index1 >= 0) And (index1 <= _listcount - 1) Then
				If (index2 >= 0) And (index2 <= _listcount - 1) Then
					'Don't need to swap if index is same.
					Swap _list[index1], _list[index2]
				End If
			End If
		End If
	'Reset the sorted flag.
	_issorted = FALSE
	EndIf
		
End Sub

'Qsort comparison function.
Function stringlist._QCompare Cdecl (e1 As Any Ptr, e2 As Any Ptr) As Integer
      Dim As String el1, el2
      Dim ret As Integer
        
		'Get the values, must cast to string ptr
		el1 = *(CPtr(String Ptr, e1))
		el2 = *(CPtr(String Ptr, e2))
		If casesense = FALSE Then
			el1 = UCase(el1)
			el2 = UCase(el2)
		EndIf			
		'Compare the values
		If sortype = TRUE Then
			If el1 < el2 Then
		   	ret = -1
			ElseIf el1 > el2 Then
		   	ret = 1
			Else
		   	ret = 0
			End If
      Else
			If el1 > el2 Then
				ret = -1
			ElseIf el1 < el2 Then
	   		ret = 1
			Else
   		ret = 0
			End If
		End If
		
		Return ret
End Function

'Uses CRT qsort function.
Sub stringlist.Sort ()
	'Make sure we have a valid list.
	If _list Then
		'Build a working array.
		Dim slist(0 To _listcount - 1) As String
		'Copy the elements to the array.
		For i As Integer = 0 To _listcount - 1
			'Check for empty string.
			If _list[i] Then
				slist(i) = *_list[i]
			Else
				slist(i) = ""
			EndIf
		Next
		qsort(@slist(0), _listcount, SizeOf(String), @_QCompare)
		'Copy back to string list.
		For i As Integer = 0 To _listcount - 1
			Strings(i) = slist(i)
		Next
		_issorted = TRUE
	End If
End Sub

'Creates a new copy of stringlist.
Sub stringlist.Copy (ByRef sl As stringlist) 
	
	'Copy the properties.
	sl.CaseSensitive = _casesense
	sl.SortAscending = _sortype
	'If we have a list copy it.
	If _list Then
		For i As Integer = 0 To _listcount - 1
			sl.Add(Strings(i))
		Next
	EndIf
	
End Sub
