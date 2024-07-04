#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   

//-------------------------------------------------------------------
/*/ { Protheus.doc } CRM610EventDEFJUR
Classe responsável pelo evento das regras de negócio do segmento.

@author Cristina Cintra Santos
@since 25/08/2020
/*/
//-------------------------------------------------------------------
Class CRM610EventDEFJUR FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

Method New() Class CRM610EventDEFJUR
Return

Method InTTS(oSubModel, cModelId) Class CRM610EventDEFJUR
	If SuperGetMV("MV_JFSINC", .F., '2') == '1'
		JFILASINC(oSubModel:GetModel(), "AOV", "AOVMASTER", "AOV_CODSEG")
	EndIf
Return