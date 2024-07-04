#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

CLASS ProtheusDictionary FROM LongNameClass
	DATA Table
	
	METHOD New() CONSTRUCTOR	
ENDCLASS

/// <summary>
/// 	Initializes a new instance of the class.
/// </summary>
/// <returns></returns>
METHOD New() CLASS ProtheusDictionary
	SELF:Table:= ProtheusDictionaryTable():New()
RETURN SELF
