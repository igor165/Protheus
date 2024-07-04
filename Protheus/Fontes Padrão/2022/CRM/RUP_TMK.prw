#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TMK()
Fun��es de compatibiliza��o e/ou convers�o de dados para as tabelas do sistema.
@sample	RUP_TMK("12", "2", "003", "005", "BRA")
@param		cVersion	- Vers�o do Protheus 
@param		cMode		- Modo de execu��o	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente est�)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualiza��o)
@param		cLocaliz	- Localiza��o (pa�s)	- Ex. "BRA"
@return	Nil
@author	Alexandre da Costa
@since		09/12/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_TMK(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

//Este RUP n�o possui mais nenhum ajuste e o mesmo ser� exclu�do do TFS e do RPO.

Return Nil