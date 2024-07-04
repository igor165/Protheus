#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_LOJA 
Fun��o de compatibiliza��o do release incremental chamada na execu��o do UpdDistr.
Esta fun��o � relativa ao m�dulo Controle de Lojas (SIGALOJA). 

@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA  

@Author Varejo
@since 10/01/2018
@version P12

@obs Veja a documenta��o de exemplo em: https://tdn.totvs.com/pages/viewpage.action?pageId=286729822

/*/
//-------------------------------------------------------------------
Function RBE_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Return