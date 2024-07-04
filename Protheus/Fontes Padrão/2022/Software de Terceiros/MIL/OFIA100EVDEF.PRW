#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA100.CH"

CLASS OFIA100EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD Activate()
	METHOD After()

ENDCLASS


METHOD New() CLASS OFIA100EVDEF
RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA100EVDEF
Local lRet    := .t.
Local cMotCan := ""
Local nRecTab := 0
Local xValAnt
If cModelId == "VDQFILHO"
	Do Case
		Case cAction == "CANSETVALUE" // Pode atribuir Valor no campo ?
			If cId == "VDQ_MOTCAN"
				lRet := .f.
			ElseIf cId == "VDQ_CODVEN"
				If !Empty(oSubModel:GetValue("VDQ_NUMORC"))
					lRet := .f.
				EndIf
			ElseIf cId == "VDQ_DESITE"
				If !Empty(oSubModel:GetValue("VDQ_NUMORC")) .or. !Empty(oSubModel:GetValue("VDQ_MOTCAN"))
					lRet := .f.
				EndIf
			EndIf
		Case cAction == "SETVALUE" // Valid do campo
			xValAnt := xCurrentValue
			If cId == "VDQ_CODFAS" // Para o COD.FASE, pegar conteudo gravado no Banco de Dados
				xValAnt := ""
				nRecTab := oSubModel:GetDataId(nLine) // RecNo VDQ
				If nRecTab > 0
					VDQ->(DbGoTo(nRecTab))
					xValAnt := VDQ->VDQ_CODFAS
				EndIf
			EndIf
			lRet := OA1000081_ValidVDQ(oSubModel,cId,xValue,xValAnt)
		Case cAction == "DELETE" // Deixa deletar
			If !Empty(oSubModel:GetValue("VDQ_DESITE"))
				If Empty(oSubModel:GetValue("VDQ_MOTCAN"))
					// Seleciona Motivo do Cancelamento
					cMotCan := OA1000021_MotivoCancelamento( nLine , .t. )
					If !Empty(cMotCan)
						oSubModel:SetValue("VDQ_MOTCAN",cMotCan)
						Help(NIL, NIL, STR0043, NIL, oSubModel:GetValue("VDQ_DESITE") , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044}) // Cancelamento do Interesse / Interesse cancelado com sucesso.
					Else
						Help(NIL, NIL, STR0043, NIL, STR0046, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0045}) // Cancelamento do Interesse / Motivo não selecionado / Informar o motivo do cancelamento.
					EndIf
				Else
					Help(NIL, NIL, STR0047, NIL, oSubModel:GetValue("VDQ_DESITE") , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0048}) // Interesse Cancelado / Interesse já foi cancelado com Motivo.
				EndIf
				lRet := .f. // NUNCA deleta a linha do Interesse
			EndIf
	EndCase
EndIf
RETURN lRet


METHOD After(oSubModel, cModelId, cAlias, lNewRecord) CLASS OFIA100EVDEF
If cModelId == "VDLMASTER"
	DbSelectArea("VDL")
	ConfirmSX8() // Controle de Numeração
ElseIf cModelId == "VDQFILHO"
	If lNewRecord
		OA1000061_BatizaNumeracaoVDQ()
	EndIf
	If !Empty(VDQ->VDQ_MOTCAN)
		OA1000071_GravaMotivoCancelamento(oSubModel:nline)
	EndIf
	// Gravar a tabela de Historico do Interesse
	OA1000031_GravaHistorico() // Chama a cada linha da grid se o registro foi alterado ou inserido
EndIf
RETURN


METHOD Activate(oModel, lCopy) CLASS OFIA100EVDEF
	Local oModelVDL := oModel:GetModel("VDLMASTER")
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		If type("cAutCli") <> "U" .and. !Empty(cAutCli+cAutLjC)
			oModelVDL:SetValue( "VDL_CODCLI" , cAutCli )
			oModelVDL:SetValue( "VDL_LOJCLI" , cAutLjC )
		ElseIf type("cAutPro") <> "U" .and. !Empty(cAutPro+cAutLjP)
			oModelVDL:SetValue( "VDL_CDPROS" , cAutPro )
			oModelVDL:SetValue( "VDL_LJPROS" , cAutLjP )
		EndIf
	EndIf
RETURN .T.