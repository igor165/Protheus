#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

CLASS ProtheusDictionaryTable FROM LongNameClass
	METHOD New() CONSTRUCTOR
		
	METHOD IsShared(cArquivo) 
	METHOD IsExclusive(cArquivo)	
ENDCLASS


/// <summary>
/// 	Initializes a new instance of the class.
/// </summary>
/// <returns></returns>
METHOD New() CLASS ProtheusDictionaryTable
RETURN SELF


/// <summary>
/// 	
/// </summary>
/// <returns></returns>
METHOD IsShared(cTableName) CLASS ProtheusDictionaryTable
	Local aArea := GetArea()
	Local lCompart

	PARAMTYPE 0 VAR cTableName AS CHARACTER
	
	If !ChkFile(cTableName)
		UserException("Tabela nao encontrada no dicionario: " + cTableName)
	EndIf

	lCompart := FWModeAccess(cTableName, 3) == "C"
	
	RestArea(aArea)
Return lCompart


/// <summary>
/// 	
/// </summary>
/// <returns></returns>
METHOD IsExclusive(cTableName) CLASS ProtheusDictionaryTable
	PARAMTYPE 0 VAR cTableName AS CHARACTER
RETURN .NOT. SELF:IsShared(cArquivo)
