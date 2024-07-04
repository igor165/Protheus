#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS DBParameter FROM LongNameClass
	DATA __Name AS UNDEFINED
	DATA __Value AS UNDEFINED
	               
	METHOD New(xName, xValue) CONSTRUCTOR
	
	METHOD GetName()
	METHOD SetName(value)
	METHOD GetValue()
	METHOD SetValue(value)
ENDCLASS


///<summary>
///	
///</summary>
METHOD New(xName, xValue) CLASS DBParameter
	SELF:__Name:= xName
	SELF:__Value:= xValue
RETURN SELF


///<summary>
///	
///</summary>
METHOD GetName() CLASS DBParameter	
RETURN SELF:__Name


///<summary>
///	
///</summary>
METHOD SetName(xName) CLASS DBParameter
	SELF:__Name := xName
RETURN xName


///<summary>
///	
///</summary>
METHOD GetValue() CLASS DBParameter	
RETURN SELF:__Value


///<summary>
///	
///</summary>
METHOD SetValue(xValue) CLASS DBParameter
	SELF:__Value := xValue
RETURN xValue
