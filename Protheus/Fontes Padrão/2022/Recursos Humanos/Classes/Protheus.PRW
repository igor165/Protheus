#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

CLASS Protheus FROM LongNameClass
	DATA Dictionary

	METHOD New() CONSTRUCTOR
ENDCLASS



/// <summary>
/// 	Initializes a new instance of the class.
/// </summary>
/// <returns></returns>
METHOD New() CLASS Protheus
	SELF:Dictionary:= ProtheusDictionary():New()
RETURN SELF
