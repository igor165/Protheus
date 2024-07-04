#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSU520B2S.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB2S := FWFormStruct( 1, 'B2S', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Exportação Lote Aviso"
	oModel:AddFields( 'MODEL_B2S',,oStruB2S )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Cabeçalho" # "Exportação Lote Aviso"
	oModel:GetModel( 'MODEL_B2S' ):SetDescription( ".:: " + STR0001 + " ::." ) //"Exportação Lote Aviso"
	oModel:SetPrimaryKey( { "B2S_FILIAL","B2S_NUMLOT","B2S_TIPGUI" } )
return oModel
