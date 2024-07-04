#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSA350EVOMS.CH"

#DEFINE OMS350EV01 "OMS350EV01"
#DEFINE OMS350EV02 "OMS350EV02"
#DEFINE OMS350EV03 "OMS350EV03"
#DEFINE OMS350EV04 "OMS350EV04"

//-------------------------------------------------------------------
CLASS OMSA350EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD VldActivate(oModel, cModelId)
	METHOD GridLinePosVld(oSubModel, cModelID, nLine)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New() CLASS OMSA350EVOMS
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de validação do Model
//-------------------------------------------------------------------
METHOD VldActivate(oModel, cModelId) CLASS OMSA350EVOMS
Local aAreaDA5  := DA5->(GetArea())
Local aAreaDA6  := DA6->(GetArea())
Local aAreaDA8  := DA8->(GetArea())
Local aAreaDAE  := DAE->(GetArea())
Local cCalendar := DAA->DAA_CODIGO
Local cString   := ""
Local lRet      := .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE

		DA5->(DbSetOrder(3))
		If DA5->(DbSeek(xFilial("DA5")+cCalendar))
			cString := STR0013 // "uma Zona"
		EndIf

		If lRet
			DA6->(DbSetOrder(2))
			If DA6->(DbSeek(xFilial("DA6")+cCalendar))
				cString := STR0014 // "um Setor por Zona"
			EndIf
		EndIf

		If lRet
			DA8->(DbSetOrder(3))
			If DA8->(DbSeek(xFilial("DA8")+cCalendar))
				cString := STR0015 // "uma Rota"
			EndIf
		EndIf

		If lRet
			DAE->(DbSetOrder(2))
			If DAE->(DbSeek(xFilial("DAE")+cCalendar))
				cString := STR0016 // "uma Regra de Entrega"
			EndIf
		EndIf

		If !Empty(cString)
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV01,OmsFmtMsg(STR0011,{{"[VAR01]",cString}}),STR0012) // "Não é possível excluir o calendário, pois o mesmo encontra-se relacionado a [VAR01]." // "Elimine o registro relacionado ao calendário."
			lRet := .F.
		EndIf

	EndIf

RestArea(aAreaDAE)
RestArea(aAreaDA8)
RestArea(aAreaDA6)
RestArea(aAreaDA5)
Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
//-------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS OMSA350EVOMS
Local oModel  := FWModelActive()
Local cTipCal := ""
Local cFrqSem := ""
Local cDiaMes := ""

	If cModelID == "MdGridIDAB"
	
		cTipCal := oModel:GetValue("MdFieldCDAA","DAA_TIPO")
		cFrqSem := oSubModel:GetValue("DAB_FREQUE")
		cDiaMes := oSubModel:GetValue("DAB_DATDIA")
		
		If cTipCal == "1"
			If Empty(cFrqSem)
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV01,OmsFmtMsg(STR0001,{{"[VAR01]",FWX3Titulo("DAB_FREQUE")}}),STR0002) // "Quando o Calendário é do Tipo 1 - Semanal, o preenchimento do campo [VAR01] torna-se obrigatório." // "Preencha o campo em questão."
				Return .F.
			EndIf
			If !Empty(cDiaMes)
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV02,OmsFmtMsg(STR0003,{{"[VAR01]",FWX3Titulo("DAB_DATDIA")}}),STR0004) // "Quando o calendário é do tipo 1 - Semanal, o preenchimento do campo [VAR01] não é necessário." // "Remova a informação do campo ou altere o Tipo do Calendário."
				Return .F.
			EndIf
		Else
			If Empty(cDiaMes)
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV03,OmsFmtMsg(STR0005,{{"[VAR01]",FWX3Titulo("DAB_DATDIA")}}),STR0002) // "Quando o Calendário é do Tipo 2 - Mensal, o preenchimento do campo [VAR01] torna-se obrigatório." // "Preencha o campo em questão."
				Return .F.
			EndIf
			If !Empty(cFrqSem)
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV04,OmsFmtMsg(STR0006,{{"[VAR01]",FWX3Titulo("DAB_FREQUE")}}),STR0004) // "Quando o calendário é do tipo 2 - Mensal, o preenchimento do campo [VAR01] não é necessário." // "Remova a informação do campo ou altere o Tipo do Calendário."
				Return .F.
			EndIf
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS OMSA350EVOMS
Local cTipCal   := ""
Local cDiaMes   := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		cTipCal := oModel:GetValue("MdFieldCDAA","DAA_TIPO"  )
		cDiaMes := oModel:GetValue("MdGridIDAB" ,"DAB_FREQUE")

		If cTipCal == "1" .And. Empty(cDiaMes)
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV04,STR0007,STR0008) // "Quando o Calendário for do tipo 1 - Semanal o Dia Inicial deve ser preenchido." // "Preencha o campo Dia Inicial ou altere o Tipo do Calendário."
			Return .F.
		ElseIf cTipCal == "2" .And. !Empty(cDiaMes)
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS350EV04,STR0009,STR0010) // "O Dia Inicial somente deve ser preenchido quando o Calendário for do tipo 1 - Semanal." // "Remova a informação do campo ou altere o Tipo do Calendário."
			Return .F.
		EndIf

	EndIf

Return .T.
