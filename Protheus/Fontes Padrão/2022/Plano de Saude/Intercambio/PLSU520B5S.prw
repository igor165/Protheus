#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSU520B5S.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB5S := FWFormStruct( 1, 'B5S', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Exportação Lote Aviso"
	oModel:AddFields( 'MODEL_B5S',,oStruB5S )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Guia" # "Exportação Lote Aviso"
	oModel:GetModel( 'MODEL_B5S' ):SetDescription( ".:: " + STR0001 + " ::." ) 
	oModel:SetPrimaryKey( { "B5S_FILIAL","B5S_NUMLOT","B5S_CODOPE","B5S_CODLDP","B5S_CODPEG","B5S_NUMERO" } )
return oModel
