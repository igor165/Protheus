#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSP520B5T.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB5T := FWFormStruct( 1, 'B5T', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Importação Lote Guias"
	oModel:AddFields( 'MODEL_B5T',,oStruB5T )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Guia" # "Importação Lote Guias"
	oModel:GetModel( 'MODEL_B5T' ):SetDescription( ".:: "+STR0001+" ::." ) //"Importação Lote Guias" 
	oModel:SetPrimaryKey( { "B5T_FILIAL","B5T_SEQLOT","B5T_SEQGUI" } )
return oModel
