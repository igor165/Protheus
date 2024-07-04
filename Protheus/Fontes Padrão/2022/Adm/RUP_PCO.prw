#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_PCO()

Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
Atualiza inicializador padrão

@sample		RUP_PCO("12", "2", "004", "005", "BRA")

@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"

@return		Nil

@author	Igor Sousa do Nascimento
@since		18/06/2015
@version	12
/*/
//------------------------------------------------------------------------------

Function RUP_PCO(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Return Nil
