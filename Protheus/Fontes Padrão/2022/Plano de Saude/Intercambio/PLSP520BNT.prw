#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSP520BNT.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Guilherme Carvalho
@version   1.xxx
@since     07/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruBNT := FWFormStruct( 1, 'BNT', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( STR0001 ) //"Importação Lote Guias"
	oModel:AddFields( 'MODEL_BNT',,oStruBNT )	
	oModel:SetDescription( STR0002 + " - " + STR0001 ) //"Equipe" # "Importação Lote Guias"
	oModel:GetModel( 'MODEL_BNT' ):SetDescription( ".:: " + STR0001 + " ::." ) //"Importação Lote Guias"
	oModel:SetPrimaryKey( { "BNT_FILIAL","BNT_SEQLOT","BNT_SEQGUI","BNT_SEQUEN","BNT_SEQEQU" } )
return oModel
