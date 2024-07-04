#Include 'Protheus.ch'

#Define	DF_SX3_CPO				1
#Define	DF_SX3_CONTEUDO			2

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_FAT()
Fun��es de compatibiliza��o e/ou convers�o de dados para as tabelas do sistema.
@sample		RUP_FAT("12", "2", "003", "005", "BRA")
@param		cVersion	- Vers�o do Protheus 
@param		cMode		- Modo de execu��o		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente est�)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualiza��o)
@param		cLocaliz	- Localiza��o (pa�s)	- Ex. "BRA"
@return		Nil
@author		Servi�os & CRM
@since		06/08/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_FAT( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

IF findfunction("RUP_ARG12114") .and.  cPaisLoc == "ARG"
	RUP_ARG12114(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Estabilizacion Argentina 12.1.14, creaci�n de campos de impuestos  A-Z
ENDIF

Return Nil
