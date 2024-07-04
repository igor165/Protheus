#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS Hashtable FROM LongNameClass
	DATA __Item AS ARRAY
	DATA __Count AS NUMERIC
	
	METHOD New() CONSTRUCTOR
	
	METHOD Add(key, value)
	METHOD Clear()
	METHOD Clone()
	METHOD ContainsKey(key)
	METHOD ContainsValue(value)
	METHOD CopyTo(array, arrayIndex)
	METHOD Remove(key)
	METHOD ToString()
	METHOD Equals(obj)

	METHOD GetItem(key)
	METHOD SetItem(key, value)
	METHOD GetKeys()
	METHOD GetKey(pos)
	METHOD GetValues()
	METHOD GetValue(pos)
	METHOD GetCount()
ENDCLASS


///<summary>
///	
///</summary>
///<returns></returns>
METHOD New() CLASS Hashtable
	SELF:Clear()
RETURN SELF


///<summary>
///	
///</summary>
///<param name="key" type="Object"></param>
///<param name="value" type="Object"></param>
///<returns></returns>
METHOD Add(xKey, xValue) CLASS Hashtable
	If (xKey == NIL)
		UserException("Chave não pode ser nula!")
	EndIf
	
	If SELF:ContainsKey(xKey)
		UserException("Chave já existente na Hashtable!")
	EndIf
             
	AAdd(SELF:__Item, DictionaryEntry():New(xKey, xValue))

	SELF:__Count:= Len(SELF:__Item)
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Clear() CLASS Hashtable
	SELF:__Item:= {}
	SELF:__Count:= 0
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Clone() CLASS Hashtable
	LOCAL oClone:= Hashtable():New()
	
	oClone:__Item	:= AClone(SELF:Item)
	oClone:__Count	:= SELF:__Count	
RETURN oClone


///<summary>
///	
///</summary>
///<param name="key" type="Object"></param>
///<returns></returns>
METHOD ContainsKey(xKey) CLASS Hashtable
	Local nPos:= AScan(SELF:__Item, { |oDicEntry| oDicEntry:GetKey() == xKey})	
RETURN (nPos > 0)


///<summary>
///	
///</summary>
///<param name="value" type="Object"></param>
///<returns></returns>
METHOD ContainsValue(xValue) CLASS Hashtable
	Local nPos:= AScan(SELF:__Item, { |oDicEntry| oDicEntry:GetValue() == xValue})		
RETURN (nPos > 0)


///<summary>
///	
///</summary>
///<param name="array" type="Array"></param>
///<param name="arrayIndex" type="Int32"></param>
///<returns></returns>
METHOD CopyTo(array, arrayIndex) CLASS Hashtable
	
RETURN


///<summary>
///	
///</summary>
///<param name="key" type="Object"></param>
///<returns></returns>
METHOD Remove(key) CLASS Hashtable
	Local nPos:= AScan(SELF:__Item, { |oDicEntry| oDicEntry:GetKey() == xKey})	
	
	If (nPos > 0)
		ADel(SELF:__Item, nPos)
		ASize(SELF:__Item, Len(SELF:Item)-1)
		
		SELF:__Count:= Len(SELF:Item)
	EndIf	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD ToString() CLASS Hashtable
	
RETURN


///<summary>
///	
///</summary>
///<param name="obj" type="Object"></param>
///<returns></returns>
METHOD Equals(obj) CLASS Hashtable
	
RETURN


///<summary>
///	
///</summary>
METHOD GetItem(xKey) CLASS Hashtable
	Local nPos:= AScan(SELF:__Item, { |oDicEntry| oDicEntry:GetKey() == xKey})

	If (nPos > 0)	         
		RETURN SELF:__Item[nPos]:GetValue()
	EndIF
RETURN


///<summary>
///	
///</summary>
METHOD SetItem(xKey, xValue) CLASS Hashtable
	Local nPos:= AScan(SELF:__Item, { |oDicEntry| oDicEntry:GetKey() == xKey})

	If (nPos > 0)
		SELF:__Item[nPos]:SetValue(xValue)
	Else
		SELF:Add(xKey, xValue)
	EndIF	
RETURN xValue


///<summary>
///	
///</summary>
METHOD GetKeys() CLASS Hashtable
	Local aKeys:= {}
	Local nCount
	
	For nCount:= 1 To SELF:__Count
		AAdd(aKeys, SELF:__Item[nCount]:GetKey())
	Next	
RETURN aKeys


///<summary>
///	
///</summary>
METHOD GetKey(pos) CLASS Hashtable
RETURN SELF:__Item[pos]:GetKey()


///<summary>
///	
///</summary>
METHOD GetValues() CLASS Hashtable
	Local aValues:= {}
	Local nCount
	
	For nCount:= 1 To SELF:__Count
		AAdd(aValues, SELF:__Item[nCount]:GetValue()	)
	Next	
RETURN aValues

///<summary>
///	
///</summary>
METHOD GetValue(pos) CLASS Hashtable
RETURN SELF:__Item[pos]:GetValue()


///<summary>
///	
///</summary>
METHOD GetCount() CLASS Hashtable
RETURN SELF:__Count