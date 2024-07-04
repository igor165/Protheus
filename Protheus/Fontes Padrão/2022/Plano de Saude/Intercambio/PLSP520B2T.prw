#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSP520B2T.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB2T := FWFormStruct( 1, 'B2T', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Importação Lote Guias"
	oModel:AddFields( 'MODEL_B2T',,oStruB2T )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Cabeçalho" # "Importação Lote Guias"
	oModel:GetModel( 'MODEL_B2T' ):SetDescription( ".:: "+STR0001+" ::." ) //"Importação Lote Guias" 
	oModel:SetPrimaryKey( { "B2T_FILIAL","B2T_SEQLOT" } )
return oModel
