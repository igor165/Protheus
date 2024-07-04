#Include "TMSME05.CH"   
#Include "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------------------------
/* EDI - Exportacao de Documentos
@author  	Jefferson Tomaz de Lima
@version 	P12 12.1.23
@since 		27/02/2019
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSME05A()
Return TMSME05(1)

//-----------------------------------------------------------------------------------------------------------
/* EDI - Exportacao  - Scheduler
@author  	Jefferson Tomaz de Lima
@version 	P12 12.1.23
@since 		27/02/2019
@return 	*/
//-----------------------------------------------------------------------------------------------------------

Static Function SchedDef()

Local aParam
Local cCadastro := ""
Local cPerg 	:= ""

cPerg := TMSME05PER(1, @cCadastro)

aParam := { 	"P"			,;  	//Tipo R para relatorio P para processo
				cPerg	,;			// Pergunte do relatorio, caso nao use passar ParamDef
				"DE0"		,;  	// Alias
							,;   	//Array de ordens
				cCadastro} 			//--> "EDI - Envio de Documentos"	

Return aParam