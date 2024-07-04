#Include "TMSME05.CH"   
#Include "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------------------------
/* EDI - Exportacao de Ocorrencias
@author  	Jefferson Tomaz de Lima
@version 	P12 12.1.23
@since 		27/02/2019
@return 	*/
//-----------------------------------------------------------------------------------------------------------

Function TMSME05C()
Return TMSME05(3)

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

cPerg := TMSME05PER(3, @cCadastro)

aParam := { 	"P"			,;  	//Tipo R para relatorio P para processo
				cPerg	,;			// Pergunte do relatorio, caso nao use passar ParamDef
				"DE0"		,;  	// Alias
							,;   	//Array de ordens
				cCadastro} 			//--> "EDI - Envio de Ocorrencias"	

Return aParam