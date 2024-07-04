#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSU520B6S.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB6S := FWFormStruct( 1, 'B6S', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Exportação Lote Aviso"
	oModel:AddFields( 'MODEL_B6S',,oStruB6S )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Itens" # "Exportação Lote Aviso"
	oModel:GetModel( 'MODEL_B6S' ):SetDescription( ".:: " + STR0001 + " ::." ) 
	oModel:SetPrimaryKey( { "B6S_FILIAL","B6S_NUMLOT","B6S_CODOPE","B6S_CODLDP","B6S_CODPEG","B6S_NUMERO","B6S_ORIMOV","B6S_SEQUEN","B6S_CODPAD","B6S_CODPRO" } )
return oModel
