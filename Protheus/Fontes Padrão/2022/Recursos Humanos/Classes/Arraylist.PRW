#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/// <summary>
/// 	
/// </summary>
CLASS ArrayList FROM LongNameClass
	DATA __Item AS ARRAY
	DATA __Count AS NUMERIC
	
	METHOD New() CONSTRUCTOR

	METHOD Add() 
	METHOD AddRange() 
	METHOD Clear() 	
	METHOD Clone()
	METHOD Contains()
	METHOD IndexOf()
	METHOD LastIndexOf()
	METHOD Insert()
	METHOD InsertRange()	
	METHOD Remove()
	METHOD RemoveAt()
	METHOD RemoveRange()
	METHOD Reverse()
	METHOD Sort()
	METHOD ToArray()
	METHOD ToString() 
	METHOD TrimToSize()
	                  
	METHOD Equals(oArrayList)
	
	METHOD GetItem(nPos)
	METHOD SetItem(nPos, xValue)
	METHOD GetCount()
ENDCLASS



/// <summary>
/// 	Initializes a new instance of the ArrayList class.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
/*METHOD New(aInit) CLASS ArrayList
	PARAMTYPE 0 VAR aInit AS ARRAY
	           
	SELF:__Item:=	AClone(aInit)	
RETURN SELF	*/



/// <summary>
/// 	Initializes a new instance of the ArrayList class.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
/*METHOD New(nInit) CLASS ArrayList
	PARAMTYPE 0 VAR nInit AS NUMERIC

	SELF:__Item:=	Array(nInit)	
RETURN SELF	*/

METHOD New(xInit) CLASS ArrayList
	If ValType(xInit) == "N"
		SELF:__Item:= Array(xInit)	
	ElseIf ValType(xInit) == "A"
		SELF:__Item:= AClone(xInit)
	Else
		SELF:__Item:=	{}
	EndIf
	
	SELF:__Count:= Len(SELF:__Item)
RETURN SELF

/// <summary>
/// 	Adds an object to the end of the ArrayList.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD Add(xItem) CLASS ArrayList
	AAdd(SELF:__Item, xItem)
	SELF:__Count+= 1
RETURN Len(SELF:__Item)



/// <summary>
/// 	Adds the elements of an array to the end of the ArrayList.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD AddRange(aItems) CLASS ArrayList
	LOCAL nCount
	PARAMTYPE 0 VAR aItems AS ARRAY OPTIONAL
	
	For nCount:= 1 To Len(aItems)
		If ValType(aItems[nCount]) == "A"
			AAdd(SELF:__Item, AClone(aItems[nCount]))
		Else
			AAdd(SELF:__Item, aItems[nCount])
		EndIf

		SELF:__Count+= 1
	Next
RETURN 



/// <summary>
/// 	Removes all elements from the ArrayList.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD Clear() CLASS ArrayList
	SELF:__Item:= {}
	SELF:__Count:= 0
RETURN 



/// <summary>
/// 	Creates a shallow copy of the ArrayList.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD Clone() CLASS ArrayList
	LOCAL oArrayList

	oArrayList:= ArrayList():New()
	oArrayList:__Item:= AClone(SELF:__Item)
	oArrayList:__Count:= SELF:__Count
RETURN oArrayList



/// <summary>
/// 	Determines whether an element is in the ArrayList. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD Contains(xItem) CLASS ArrayList
	LOCAL lReturn
	
	lReturn:= (AScan(SELF:__Item, { |oSearch| oSearch == xItem}) > 0)	
RETURN lReturn



/// <summary>
/// 	Returns the one-based index of the first occurrence of a value in the 
/// ArrayList or in a portion of it. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD IndexOf(xItem, nStart, nLength) CLASS ArrayList
	LOCAL nPos
	//PARAMTYPE 0 VAR xItem AS OBJECT
	PARAMTYPE 1 VAR nStart AS NUMERIC OPTIONAL DEFAULT 1
	PARAMTYPE 2 VAR nLength AS NUMERIC OPTIONAL DEFAULT Len(SELF:__Item)-nStart+1
		
	nPos:= AScan(SELF:__Item, { |oSearch| oSearch == xItem}, nStart, nLength)
RETURN nPos



/// <summary>
/// 	Returns the one-based index of the last occurrence of a value 
///	in the ArrayList or in a portion of it. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD LastIndexOf(xItem, nStart, nLength) CLASS ArrayList
	LOCAL nCount
	LOCAL nPos:= 0
	
	//PARAMTYPE 0 VAR xItem AS OBJECT
	PARAMTYPE 1 VAR nStart AS NUMERIC OPTIONAL DEFAULT 1
	PARAMTYPE 2 VAR nLength AS NUMERIC OPTIONAL DEFAULT Len(SELF:__Item)-nStart+1

	For nCount:= nLength To nStart Step -1
		If SELF:__Item == xItem
			nPos:= nCount
			Exit
		EndIf	
	Next
RETURN nPos



/// <summary>
/// 	Inserts an element into the ArrayList at the specified index.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns>
METHOD Insert(nIndex, xItem) CLASS ArrayList
	PARAMTYPE 0 VAR nIndex AS NUMERIC
	//PARAMTYPE 1 VAR xItem AS OBJECT
	
	ASize(SELF:__Item, Len(SELF:__Item)+1)
	AIns(SELF:__Item, nIndex)

	If ValType(xItem) == "A"
		SELF:__Item[nIndex]:= AClone(xItem)
	Else
		SELF:__Item[nIndex]:= xItem
	EndIf
	
	SELF:__Count+= 1	
RETURN



/// <summary>
/// 	Inserts the elements of an Array into the ArrayList at the specified index.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD InsertRange(nIndex, aItems) CLASS ArrayList
	LOCAL nCount
	PARAMTYPE 0 VAR nIndex AS NUMERIC
	PARAMTYPE 1 VAR aItems AS ARRAY
	
	ASize(SELF:__Item, Len(SELF:__Item)+ Len(aItems))

	For nCount:= 1 To Len(aItems)
		AIns(SELF:__Item, nIndex+nCount-1)

		If ValType(aItems[nCount]) == "A"
			SELF:__Item[nIndex+nCount-1]:= AClone(aItems[nCount])
		Else
			SELF:__Item[nIndex+nCount-1]:= aItems[nCount]
		EndIf

		SELF:__Count+= 1
	Next
RETURN



/// <summary>
/// 	Removes the first occurrence of a specific object from the ArrayList.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD Remove(xItem) CLASS ArrayList
	LOCAL nCount
	LOCAL nPos:= AScan(SELF:__Item, {|xTemp| xTemp == xItem})
	//PARAMTYPE 0 VAR xItem AS OBJECT
	
	If nPos > 0
		SELF:__Count-= 1
		
		ADel(SELF:__Item, nPos)
		ASize(SELF:__Item, SELF:__Count)
	EndIf
RETURN



/// <summary>
/// 	Removes the element at the specified index of the ArrayList. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD RemoveAt(nItem) CLASS ArrayList
	PARAMTYPE 0 VAR nItem AS NUMERIC
	
	SELF:__Count-= 1
	
	ADel(SELF:__Item, nItem)
	ASize(SELF:__Item, SELF:__Count)
RETURN



/// <summary>
/// 	Removes a range of elements from the ArrayList. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD RemoveRange(nStart, nLength) CLASS ArrayList
	LOCAL nCount
	PARAMTYPE 0 VAR nStart AS NUMERIC
	PARAMTYPE 1 VAR nLength AS NUMERIC
	
	For nCount:= nStart To nStart+Length
		SELF:__Count-= 1
		
		ADel(SELF:__Item, nCount)
		ASize(SELF:__Item, SELF:__Count)
	Next
RETURN


 
/// <summary>
/// 	Reverses the order of the elements in the ArrayList or a portion of it.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD Reverse() CLASS ArrayList
RETURN



/// <summary>
/// 	Sorts the elements in the ArrayList or a portion of it. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD Sort() CLASS ArrayList	
RETURN



/// <summary>
/// 	Copies the elements of the ArrayList to a new array. 
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD ToArray() CLASS ArrayList
RETURN SELF:__Item



/// <summary>
/// 	Returns a String that represents the current Object.
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD ToString() CLASS ArrayList
	Local cReturn:= ""
	Local cCount
	Local xItem
		
	For cCount:= 1 To SELF:__Count
		xItem:= SELF:GetItem(cCount)
		cReturn+= IIf(Empty(cReturn), "{", ", ")

		If ValType(xItem) == "C"
			cReturn+= xItem
		ElseIf ValType(xItem) == "N"
			cReturn+= AllTrim(Str(xItem	))
		ElseIf ValType(xItem) == "L"
			cReturn+= IIF(xItem, ".T.", ".F.")
		ElseIf ValType(xItem) == "D"
			cReturn+= DTOC(xItem)
		ElseIf ValType(xItem) == "A"
			xItem:= ArrayList():New(xItem)
			cReturn+= xItem:ToString()
		EndIf
	Next	
	cReturn+= "}"
RETURN cReturn



/// <summary>
/// 	Sets the capacity to the actual number of elements in the ArrayList.  
/// </summary>
/// <param name="Parametro"></param>
/// <returns></returns> 
METHOD TrimToSize() CLASS ArrayList
RETURN

METHOD Equals(oArrayList) CLASS ArrayList
RETURN ArrayCompare(SELF:__Item, oArrayList:ToArray())                              

METHOD GetItem(nPos) CLASS ArrayList
RETURN SELF:__Item[nPos]

METHOD SetItem(nPos, xValue) CLASS ArrayList
	SELF:__Item[nPos]:= xValue
RETURN SELF:__Item[nPos]

METHOD GetCount() CLASS ArrayList
RETURN SELF:__Count


/*
// Overloaded. Copies the ArrayList or a portion of it to a one-dimensional array. 
METHOD CopyTo()
// Overloaded. Returns a list wrapper with a fixed size, where elements are allowed to be modified, but not added or removed. 
METHOD FixedSize()
// Overloaded. Returns an enumerator that iterates through the ArrayList. 
METHOD GetEnumerator()
// Serves as a hash function for a particular type. (Inherited from Object.)
METHOD GetHashCode()
// Returns an ArrayList which represents a subset of the elements in the source ArrayList. 
METHOD GetRange()
// Gets the Type of the current instance. (Inherited from Object.) 
METHOD GetType()
//Overloaded. Returns a list wrapper that is read-only. 
METHOD ReadOnly()
// Returns an ArrayList whose elements are copies of the specified value.
METHOD Repeat()
// Copies the elements of a collection over a range of elements in the ArrayList.
METHOD SetRange()
// Overloaded. Returns a list wrapper that is synchronized (thread safe). 
METHOD Synchronized()
*/