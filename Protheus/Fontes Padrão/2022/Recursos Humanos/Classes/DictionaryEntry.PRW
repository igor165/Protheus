#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS DictionaryEntry FROM LongNameClass
	DATA __Key AS UNDEFINED
	DATA __Value AS UNDEFINED
	               
	METHOD New(xKey, xValue) CONSTRUCTOR
	
	METHOD GetKey()
	METHOD SetKey(value)
	METHOD GetValue()
	METHOD SetValue(value)
ENDCLASS


///<summary>
///	
///</summary>
METHOD New(xKey, xValue) CLASS DictionaryEntry
	SELF:__Key:= xKey
	SELF:__Value:= xValue
RETURN SELF


///<summary>
///	
///</summary>
#XTRANSLATE <oSender>:Key => <oSender>:GetKey()
METHOD GetKey() CLASS DictionaryEntry	
RETURN SELF:__Key


///<summary>
///	
///</summary>
#XTRANSLATE <oSender>:Key := <uVal> => <oSender>:SetKey( <uVal> )
METHOD SetKey(xKey) CLASS DictionaryEntry
	SELF:__Key := xKey
RETURN xKey


///<summary>
///	
///</summary>
#XTRANSLATE <oSender>:Value => <oSender>:GetValue()
METHOD GetValue() CLASS DictionaryEntry	
RETURN SELF:__Value


///<summary>
///	
///</summary>
#XTRANSLATE <oSender>:Value := <uVal> => <oSender>:SetValue( <uVal> )
METHOD SetValue(xValue) CLASS DictionaryEntry
	SELF:__Value := xValue
RETURN xValue
