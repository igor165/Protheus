#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "CTBA020.CH"

/**
Fonte contendo o processo de integração com o SIGAGFE
*/

Class CTBA020EVGFE FROM FWModelEvent
    Data cIntGFE2
    Data lIntGFE

	Method New()
    Method InTTS(oModel, cModelId)
	Method AfterTTS(oModel, cModelId)
End Class


Method New() Class CTBA020EVGFE
    Self:lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
    Self:cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
Return


Method InTTS(oModel, cModelId) Class CTBA020EVGFE
    Local lRet       := .T.

	If AllTrim(cModelId) == "CTBA020"
		If Self:lIntGFE == .T. .And. Self:cIntGFE2 $ "1"
			If !InterGUE(oModel:GetModel("CT1MASTER"))
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet


Method AfterTTS(oModel, cModelId) Class CTBA020EVGFE
	Local nOperation := oModel:GetOperation()

	If AllTrim(cModelId) == "CTBA020"
		If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
			MaEnvEAI(/*EMPRESA*/,/*FILIAL*/,nOperation,"CTBA020",{{ "CT1", "CT1MASTER", NIL, NIL, NIL, NIL }})
		EndIf
	EndIf
Return .T.


//-----------------------------------------------------
/*/	Integra a tabela CT1(Protheus) com GUE(SIGAGFE) a cada registro novo
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function InterGUE(oModelCT1)
	Local aAreaGUE   := GUE->(GetArea())
	Local lRet       := .T.
	Local cMsg       := ""
	Local nTpOpSetad := 0
	Local nOperation := oModelCT1:GetOperation()
	Local oModelGUE  := FWLoadModel("GFEA090")

	DbSelectArea("GUE")
	GUE->(DbSetOrder(1))
	GUE->(DbSeek(xFilial("GUE")+oModelCT1:GetValue("CT1_CONTA")))

	If !GUE->(Eof()) .And. GUE->GUE_FILIAL == xFilial("GUE");
			.And. AllTrim(GUE->GUE_CTACTB) == AllTrim(oModelCT1:GetValue("CT1_CONTA"))
		oModelGUE:SetOperation(MODEL_OPERATION_UPDATE)
		nTpOpSetad := MODEL_OPERATION_UPDATE
	Else
		oModelGUE:SetOperation(MODEL_OPERATION_INSERT)
		nTpOpSetad := MODEL_OPERATION_INSERT
	EndIf

	oModelGUE:Activate()

	If nOperation <> MODEL_OPERATION_DELETE
		oModelGUE:SetValue("GFEA090_GUE", "GUE_TITULO", oModelCT1:GetValue("CT1_DESC01"))
		If nTpOpSetad == MODEL_OPERATION_UPDATE
			If nOperation == MODEL_OPERATION_INSERT
				oModelGUE:LoadValue("GFEA090_GUE", "GUE_SIT", "1")
			Endif
		Else
			oModelGUE:SetValue("GFEA090_GUE", "GUE_FILIAL", xFilial("CT1"))
			oModelGUE:SetValue("GFEA090_GUE", "GUE_CTACTB", oModelCT1:GetValue("CT1_CONTA"))
		EndIf
	Else
		If nTpOpSetad <> MODEL_OPERATION_INSERT
			oModelGUE:LoadValue("GFEA090_GUE", "GUE_SIT", "2")
		EndIf
	Endif

	If nOperation != MODEL_OPERATION_DELETE .Or. nTpOpSetad != MODEL_OPERATION_INSERT
		If ! oModelGUE:VldData()
			lRet := .F.
			cMsg := STR0066+CRLF+CRLF+oModelGUE:GetErrorMessage()[6]
		Else
			oModelGUE:CommitData()
		EndIf
	EndIf

	oModelGUE:Deactivate()

	FWModelActive(oModelCT1)

	If ! lRet
		Help( ,, STR0057,,cMsg, 1, 0 ) //"Atenção"
	EndIf

	RestArea( aAreaGUE )
Return lRet
