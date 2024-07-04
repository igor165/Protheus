#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSA120EVOMS.CH"

//-------------------------------------------------------------------
CLASS OMSA120EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld(oSubModel, cModelID, nLine)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New() CLASS OMSA120EVOMS		
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
//-------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS OMSA120EVOMS
Local oModel   := FWModelActive()
Local cGrpVeic := ""
Local cCodVeic := ""
Local cCodCale := ""
Local cHoraIni := ""
Local cHoraFim := ""

	If cModelID == "MdGridIDAE"

		cGrpVeic := oSubModel:GetValue("DAE_GRUVEI")
		cCodVeic := oSubModel:GetValue("DAE_CODVEI")
		cCodCale := oSubModel:GetValue("DAE_CODCAL")
		cHoraIni := oSubModel:GetValue("DAE_HRINI" )
		cHoraFim := oSubModel:GetValue("DAE_HRFIM" )

		If Empty(cGrpVeic) .And. Empty(cCodVeic) .And. Empty(cCodCale) .And. cHoraIni == "00:00" .And. cHoraFim == "23:59"
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,"OMSME12001",STR0001,OmsFmtMsg(STR0002,{{"[VAR01]",FWX3Titulo("DAE_GRUVEI")},{"[VAR02]",FWX3Titulo("DAE_CODVEI")},{"[VAR03]",FWX3Titulo("DAE_CODCAL")},{"[VAR04]",FWX3Titulo("DAE_HRINI")},{"[VAR05]",FWX3Titulo("DAE_HRFIM")}})) // "Um ou mais campos obrigatórios não foram preenchidos." // "Verifique os valores dos campos [VAR01], [VAR02], [VAR03], [VAR04] e [VAR05]. Ao menos um deles deve estar preenchido para que a linha seja considerada válida."
			Return .F.
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS OMSA120EVOMS
Local oModelFld := Nil
Local cGrpCli   := ""
Local cCodCli   := ""
Local cCodLoj   := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		oModelFld := oModel:GetModel("MdFieldCDAD")
		cGrpCli   := oModelFld:GetValue("DAD_GRPVEN")
		cCodCli   := oModelFld:GetValue("DAD_CODCLI")
		cCodLoj   := oModelFld:GetValue("DAD_LOJA"  )

		If Empty(cGrpCli) .And. (Empty(cCodCli) .Or. Empty(cCodLoj))
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,"OMSME12002",STR0001)
			Return .F.
		EndIf

	EndIf

Return .T.
