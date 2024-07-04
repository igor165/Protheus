#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TMK()
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
@sample	RUP_TMK("12", "2", "003", "005", "BRA")
@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"
@return	Nil
@author	Alexandre da Costa
@since		09/12/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_TMK(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

//Este RUP não possui mais nenhum ajuste e o mesmo será exclu´do do TFS e do RPO.

Return Nil