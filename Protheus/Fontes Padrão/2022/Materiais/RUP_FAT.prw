#Include 'Protheus.ch'

#Define	DF_SX3_CPO				1
#Define	DF_SX3_CONTEUDO			2

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_FAT()
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
@sample		RUP_FAT("12", "2", "003", "005", "BRA")
@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"
@return		Nil
@author		Serviços & CRM
@since		06/08/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_FAT( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

IF findfunction("RUP_ARG12114") .and.  cPaisLoc == "ARG"
	RUP_ARG12114(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Estabilizacion Argentina 12.1.14, creación de campos de impuestos  A-Z
ENDIF

Return Nil
