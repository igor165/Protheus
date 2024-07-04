#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA020.ch'

Class CTBA020EVRUS FROM FWModelEvent

	Method New()
	Method AfterTTS(oModel, cModelId)

End Class

Method New() Class CTBA020EVRUS

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações após a transação.

@author Flavio Lopes
@since 21/02/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel, cModelId) Class CTBA020EVRUS
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local aAreaCT1		:= CT1->(GetArea())
	Local aAreaCV0		:= CV0->(GetArea())
	Local nSaveSX8CV0	:= GetSX8Len()

	If SuperGetMv("MV_REDSTORN",.F.,.F.)

		//----------------------------------------------------
		// Record 5th entity for Russia localization (Russia)
		//----------------------------------------------------
		If nOperation <> MODEL_OPERATION_DELETE
			DbSelectArea("CV0")
			CV0->(DbSetOrder(1))

			If MsSeek(xFilial("CV0")+"05"+CT1->CT1_CONTA)
				RecLock("CV0",.F.)
			Else
				RecLock("CV0",.T.)
			EndIf

			CV0->CV0_FILIAL	:= xFilial("CV0")
			CV0->CV0_PLANO	:= "05"
			CV0->CV0_ITEM	:= GetSXEnum('CV0','CV0_ITEM')
			CV0->CV0_CODIGO	:= CT1->CT1_CONTA
			CV0->CV0_DESC	:= CT1->CT1_DESC01
			CV0->CV0_CLASSE	:= CT1->CT1_CLASSE
			CV0->CV0_NORMAL	:= CT1->CT1_NORMAL
			CV0->CV0_ENTSUP	:= CT1->CT1_CTASUP
			CV0->CV0_BLOQUE	:= CT1->CT1_BLOQ
			CV0->CV0_DTIBLQ	:= CT1->CT1_DTBLIN
			CV0->CV0_DTFBLQ	:= CT1->CT1_DTBLFI
			CV0->CV0_DTIEXI	:= CT1->CT1_DTEXIS
			CV0->CV0_DTFEXI	:= CT1->CT1_DTEXSF
			CV0->CV0_CFGLIV	:= CT1->CT1_BOOK
			CV0->CV0_LUCPER	:= CT1->CT1_CTALP
			CV0->CV0_PONTE	:= CT1->CT1_CTAPON
			CV0->CV0_ECVM	:= CT1->CT1_CTAVM

			CV0->(MsUnlock())

			If __lSX8
				While (GetSX8Len() > nSaveSX8CV0)
					ConfirmSX8()
				End
			Else
				RollBackSX8()
			Endif
		Else
			DbSelectArea("CV0")
			CV0->(DbSetOrder(1))
			If MsSeek(xFilial("CV0")+"05"+ CT1->CT1_CONTA)
				RecLock("CV0")
				CV0->(DbDelete())
				CV0->(MsUnlock())
			Endif
		Endif

	EndIf

	RestArea(aAreaCV0)
	RestArea(aAreaCT1)

Return lRet