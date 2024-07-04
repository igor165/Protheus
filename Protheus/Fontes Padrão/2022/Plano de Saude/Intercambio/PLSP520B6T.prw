#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSP520B6T.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB6T := FWFormStruct( 1, 'B6T', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Importação Lote Guias"
	oModel:AddFields( 'MODEL_B6T',,oStruB6T )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Itens" # "Importação Lote Guias"
	oModel:GetModel( 'MODEL_B6T' ):SetDescription( ".:: " + STR0001 + " ::." ) //"Importação Lote Guias" 
	oModel:SetPrimaryKey( { "B6T_FILIAL","B6T_SEQLOT","B6T_SEQGUI","B6T_SEQUEN" } )
return oModel
