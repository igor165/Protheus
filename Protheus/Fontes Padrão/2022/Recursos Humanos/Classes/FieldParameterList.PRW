#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS DBParameterList FROM LongNameClass
	DATA __Item AS ARRAY
	DATA __Count AS NUMERIC
	
	METHOD New() CONSTRUCTOR
	
	METHOD Add(Name, value)
	METHOD Clear()
	METHOD Clone()
	METHOD Contains(Name)
	METHOD CopyTo(array, arrayIndex)
	METHOD Remove(Name)
	METHOD ToString()
	METHOD Equals(obj)

	METHOD GetItem(index)
	METHOD SetItem(index, value)
	METHOD GetParameter(Name)
	METHOD SetParameter(Name, value)
	
	METHOD GetNames()
	METHOD GetValues()
	METHOD GetCount()
ENDCLASS


///<summary>
///	
///</summary>
///<returns></returns>
METHOD New() CLASS DBParameterList
	SELF:Clear()
RETURN SELF


///<summary>
///	
///</summary>
///<param name="Name" type="Object"></param>
///<param name="value" type="Object"></param>
///<returns></returns>
METHOD Add(xName, xValue) CLASS DBParameterList
	If (xName == NIL)
		UserException("Chave não pode ser nula!")
	EndIf
	
	If SELF:Contains(xName)
		UserException("Chave já existente na DBParameterList!")
	EndIf
             
	AAdd(SELF:__Item, DBParameter():New(xName, xValue))

	SELF:__Count:= Len(SELF:__Item)
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Clear() CLASS DBParameterList
	SELF:__Item:= {}
	SELF:__Count:= 0
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Clone() CLASS DBParameterList
	LOCAL oClone:= DBParameterList():New()
	
	oClone:__Item	:= AClone(SELF:Item)
	oClone:__Count	:= SELF:__Count	
RETURN oClone


///<summary>
///	
///</summary>
///<param name="Name" type="Object"></param>
///<returns></returns>
METHOD Contains(xName) CLASS DBParameterList
	Local nPos:= AScan(SELF:__Item, { |oFieldParam| oFieldParam:GetName() == xName})	
RETURN (nPos > 0)



///<summary>
///	
///</summary>
///<param name="array" type="Array"></param>
///<param name="arrayIndex" type="Int32"></param>
///<returns></returns>
METHOD CopyTo(array, arrayIndex) CLASS DBParameterList
	
RETURN


///<summary>
///	
///</summary>
///<param name="Name" type="Object"></param>
///<returns></returns>
METHOD Remove(Name) CLASS DBParameterList
	Local nPos:= AScan(SELF:__Item, { |oFieldParam| oFieldParam:GetName() == xName})	
	
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
METHOD ToString() CLASS DBParameterList
	
RETURN


///<summary>
///	
///</summary>
///<param name="obj" type="Object"></param>
///<returns></returns>
METHOD Equals(obj) CLASS DBParameterList
	
RETURN


///<summary>
///	
///</summary>
METHOD GetItem(xName) CLASS DBParameterList
	Local nPos

	If ValType(xName) == "C"
		nPos:= AScan(SELF:__Item, { |oFieldParam| oFieldParam:GetName() == xName})
	
		If (nPos > 0)	         
			RETURN SELF:__Item[nPos]
		EndIF
	ElseIf ValType(xName) == "N"
		RETURN SELF:__Item[xName]
	EndIf
RETURN


///<summary>
///	
///</summary>
METHOD SetItem(xName, xValue) CLASS DBParameterList
	Local nPos:= AScan(SELF:__Item, { |oFieldParam| oFieldParam:GetName() == xName})

	If (nPos > 0)
		SELF:__Item[nPos]:SetValue(xValue)
	Else
		SELF:Add(xName, xValue)
	EndIF	
RETURN xValue


///<summary>
///	
///</summary>
METHOD GetNames() CLASS DBParameterList
	Local aNames:= {}
	Local nCount
	
	For nCount:= 1 To SELF:__Count
		AAdd(aNames, SELF:__Item[nCount]:GetName())
	Next	
RETURN aNames


///<summary>
///	
///</summary>
METHOD GetValues() CLASS DBParameterList
	Local aValues:= {}
	Local nCount
	
	For nCount:= 1 To SELF:__Count
		AAdd(aValues, SELF:__Item[nCount]:GetValue()	)
	Next	
RETURN aValues


///<summary>
///	
///</summary>
METHOD GetCount() CLASS DBParameterList
RETURN SELF:__Count