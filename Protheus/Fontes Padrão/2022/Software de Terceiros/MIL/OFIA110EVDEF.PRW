#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA110.CH"

CLASS OFIA110EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD Activate()	
	METHOD After()

ENDCLASS


METHOD New() CLASS OFIA110EVDEF
RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA110EVDEF
Local lRet    := .t.
Local cTab    := left(cModelId,3)
Local cDescr  := ""
Local cMotCan := ""
Local nRecTab := 0
Local xValAnt
If cModelId == cTab+"FILHO"
	Do Case
		Case cAction == "CANSETVALUE" // Pode atribuir Valor no campo ?
			If cId == cTab+"_MOTCAN"
				lRet := .f.
			ElseIf cId == cTab+"_CODVEN"
				If !Empty(oSubModel:GetValue(cTab+"_NUMORC"))
					lRet := .f.
				EndIf
			ElseIf cId == "VDI_DESITE" .or. cId == "VDJ_DESSER"
				If !Empty(oSubModel:GetValue(cTab+"_NUMORC")) .or. !Empty(oSubModel:GetValue(cTab+"_MOTCAN"))
					lRet := .f.
				EndIf
			EndIf
		Case cAction == "SETVALUE" // Valid do campo
			xValAnt := xCurrentValue
			If cId == cTab+"_CODFAS" // Para o COD.FASE, pegar conteudo gravado no Banco de Dados
				xValAnt := ""
				nRecTab := oSubModel:GetDataId(nLine) // RecNo VDI/VDJ
				If nRecTab > 0
					If cTab == "VDI" // PECAS
						VDI->(DbGoTo(nRecTab))
						xValAnt := VDI->VDI_CODFAS
					Else // "VDJ" // SERVICOS
						VDJ->(DbGoTo(nRecTab))
						xValAnt := VDJ->VDJ_CODFAS
					EndIf
				EndIf
			EndIf
			lRet := OA1100081_ValidFilho(oSubModel,cId,xValue,xValAnt,cTab)
		Case cAction == "DELETE" // Deixa deletar
			If cTab == "VDI" // PECAS
				cDescr := oSubModel:GetValue("VDI_DESITE")
			Else // "VDJ" // SERVICOS
				cDescr := oSubModel:GetValue("VDJ_DESSER")
			EndIf
			If !Empty(cDescr)
				If Empty(oSubModel:GetValue(cTab+"_MOTCAN"))
					// Seleciona Motivo do Cancelamento
					cMotCan := OA1100021_MotivoCancelamento( nLine , .t. , cTab )
					If !Empty(cMotCan)
						oSubModel:SetValue(cTab+"_MOTCAN",cMotCan)
						Help(NIL, NIL, STR0045, NIL, cDescr , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0047}) // Cancelamento do Interesse / Interesse cancelado com sucesso.
					Else
						Help(NIL, NIL, STR0045, NIL, STR0046, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0048}) // Cancelamento do Interesse / Motivo não selecionado / Informar o motivo do cancelamento.
					EndIf
				Else
					Help(NIL, NIL, STR0049, NIL, cDescr , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0050}) // Interesse Cancelado // Interesse já foi cancelado com Motivo.
				EndIf
				lRet := .f. // NUNCA deleta a linha do Interesse
			EndIf
	EndCase
EndIf
RETURN lRet


METHOD After(oSubModel, cModelId, cAlias, lNewRecord) CLASS OFIA110EVDEF
Local cTab := left(cModelId,3)
If cModelId == "VDLMASTER"
	DbSelectArea("VDL")
	ConfirmSX8() // Controle de Numeração
ElseIf cModelId == cTab+"FILHO"
	If lNewRecord
		OA1100061_BatizaNumeracao(cTab)
	EndIf
	If !Empty(&(cTab+"->"+cTab+"_MOTCAN"))
		OA1100071_GravaMotivoCancelamento(oSubModel:nline,cTab)
	EndIf
	// Gravar a tabela de Historico do Interesse
	OA1100031_GravaHistorico(cTab) // Chama a cada linha da grid se o registro foi alterado ou inserido
EndIf
RETURN


METHOD Activate(oModel, lCopy) CLASS OFIA110EVDEF
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