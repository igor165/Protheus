#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_LOJA 
Função de compatibilização do release incremental chamada na execução do UpdDistr.
Esta função é relativa ao módulo Controle de Lojas (SIGALOJA). 

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA  

@Author Varejo
@since 10/01/2018
@version P12

@obs Veja a documentação de exemplo em: https://tdn.totvs.com/pages/viewpage.action?pageId=286729822

/*/
//-------------------------------------------------------------------
Function RBE_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Return