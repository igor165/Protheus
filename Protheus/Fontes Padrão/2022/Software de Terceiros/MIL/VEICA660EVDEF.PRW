#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEICA660EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD FieldPreVld()
	METHOD After()
	METHOD AfterTTS()
	METHOD Activate()

ENDCLASS


METHOD New() CLASS VEICA660EVDEF
RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEICA660EVDEF
Local lRet    := .t.
If cModelId == "VQXFILHO"
	Do Case
		Case cAction == "CANSETVALUE" // Pode atribuir Valor no campo ?
			If cId == "VQX_MODVEI"
				MV_PAR01      := oSubModel:GetValue("VQX_CODMAR") // Compatibilidade de SXB - VX3
			ElseIf cId == "VQX_SEGMOD"
				M->VV1_CODMAR := oSubModel:GetValue("VQX_CODMAR") // Compatibilizacao da consulta VX0 (segmento do modelo do veiculo)
			EndIf
		Case cAction == "SETVALUE" // Valid do campo
			lRet := VCA660011_ValidacaoCampos("VQX",oSubModel,cId,xValue)
		Case cAction == "DELETE" // Verifica se Deixa deletar
			lRet := VCA660101_PodeExcluir("VQX",oSubModel)
	EndCase
EndIf
RETURN lRet


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEICA660EVDEF
Local lRet := .t.
If cModelId == "VQ8MASTER"
	Do Case
		Case cAction == "SETVALUE" // Valid do campo
			lRet := VCA660011_ValidacaoCampos("VQ8",oSubModel,cId,xValue)
	EndCase
EndIf
RETURN lRet


METHOD After(oSubModel, cModelId, cAlias, lNewRecord) CLASS VEICA660EVDEF
If cModelId == "VQXFILHO" .or. cModelId == "VQNFILHO"
	If lNewRecord
		VCA660031_Numeracao( left(cModelId,3) ) // Batiza a Numeracao do VQX/VQN
	EndIf
EndIf
RETURN


METHOD AfterTTS(oModel, cModelId) CLASS VEICA660EVDEF
	VCA660071_GravacaoAposPadrao(oModel) // Gravacoes apos Gravacoes Padrao
RETURN .T.


METHOD Activate(oModel, lCopy) CLASS VEICA660EVDEF
	VCA660081_AntesAberturaTela(oModel) // Antes da Abertura da Tela
RETURN .T.