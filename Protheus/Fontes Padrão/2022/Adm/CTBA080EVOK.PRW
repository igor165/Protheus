#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Class CTBA080EVOK FROM FWModelEvent
	Method New()
	Method ModelPreVld(oModel, cModelId)
	Method ModelPosVld(oModel, cModelId)
	Method InTTS(oModel, cModelId)
End Class

Method New() Class CTBA080EVOK
Return


Method ModelPreVld(oModel, cModelId) Class CTBA080EVOK
	Local lRet := .T.

	// Quando estou excluindo um lançamento padrão verifico se foi usado no RH
	If cModelId == "CT5MASTER" .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		If ChkFile("SRV")
			If ! GpChkPadrao()
				Return .F.
			EndIf
		EndIf
	EndIf
Return lRet


Method ModelPosVld(oModel, cModelId) Class CTBA080EVOK
	Local lRet       := .T.
	Local nOperation := oModel:GetOperation()
	Local oModelCT5  := Nil
	Local cDebito	 := ""
	Local cCredit	 := ""

	// apenas para insert e update
	If cModelId == "CTBA080" .And. ( nOperation == MODEL_OPERATION_INSERT ;
			.Or. nOperation == MODEL_OPERATION_UPDATE ;
			.Or. nOperation == MODEL_OPERATION_ONLYUPDATE )

		oModelCT5 := oModel:GetModel("CT5MASTER")
		
		cDebito := oModelCT5:GetValue("CT5_DEBITO")
		cDebito += oModelCT5:GetValue("CT5_CCD")
		cDebito += oModelCT5:GetValue("CT5_ITEMD")
		cDebito += oModelCT5:GetValue("CT5_CLVLDB")
		
		cCredit := oModelCT5:GetValue("CT5_CREDIT")
		cCredit += oModelCT5:GetValue("CT5_CCC")
		cCredit += oModelCT5:GetValue("CT5_ITEMC")
		cCredit += oModelCT5:GetValue("CT5_CLVLCR")
		
		If cDebito == cCredit
			Help(" ",1,"I5_IGUAIS")
			lRet := .F.	
		EndIf
		
	EndIf

Return lRet


Method InTTS(oModel, cModelId) Class CTBA080EVOK
	Local lRet        := .T.
	Local nOperation  := oModel:GetOperation()
	Local nLine       := 0
	Local cValor      := ""
	Local cCodFor     := ""
	Local oModelCT5   := Nil
 	Local aCampos     := { "CT5_DEBITO" ,"CT5_CREDIT" ,"CT5_CCD"    ,"CT5_CCC"    ,;
	                       "CT5_ITEMD"  ,"CT5_ITEMC"  ,"CT5_CLVLDB" ,"CT5_CLVLCR" ,;
	                       "CT5_VLR01"  ,"CT5_VLR02"  ,"CT5_VLR03"  ,"CT5_VLR04"  ,;
	                       "CT5_VLR05"}

	//--------------------------
	// Salva os dados do modelo
	//--------------------------
	If lRet .And. cModelId == "CTBA080" ;
			.And. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) 
		
		oModelCT5 := oModel:GetModel("CT5MASTER")

		//--------------------------------------------------------------
		// Eliminara todos los registros de la tabla CWM que contengan
		// el asiento y la secuencia del registro posicionado.
		//--------------------------------------------------------------
		DbSelectArea("CWM") 
		CWM ->(DBSETORDER(1))
		If CWM->(DBSeek(XFILIAL("CWM")+oModelCT5:GetValue("CT5_LANPAD")+oModelCT5:GetValue("CT5_SEQUEN")))
			While CWM->(!EoF()) .And. (CWM->(CWM_FILIAL+CWM_LANPAD+CWM_SEQUEN))==XFILIAL("CWM")+oModelCT5:GetValue("CT5_LANPAD")+oModelCT5:GetValue("CT5_SEQUEN")
					Reclock("CWM",.F.)
					CWM->(DBDelete())
					CWM->(MsUnlock())
				CWM->(DBSkip())
			EndDo
		EndIf

		//----------------------------------------------------------------
		// Si el asiento estándar, secuencia y la Formula no existe en la
		// tabla CWM se agrega el nuevo registro, dejando solo un código
		// de formula relacionado a cada Asiento y secuencia.
		//----------------------------------------------------------------
		For nLine := 1 To Len(aCampos)
			cValor:= AllTrim(oModelCT5:GetValue(aCampos[nLine]))

			If !Empty(cValor)
				If "EJEFOR" $ cValor
					cCodFor := SubStr(cValor,9,15)
					CWM->(DBSetOrder(1)) 
					If !CWM->(DBSeek(XFilial("CWM")+oModelCT5:GetValue("CT5_LANPAD")+oModelCT5:GetValue("CT5_SEQUEN")+cCodFor))
						Reclock("CWM",.T.)
						CWM->CWM_FILIAL	:= XFilial("CWM")
						CWM->CWM_LANPAD	:= oModelCT5:GetValue("CT5_LANPAD")
						CWM->CWM_SEQUEN	:= oModelCT5:GetValue("CT5_SEQUEN")
						CWM->CWM_CODFOR	:= cCodFor
						CWM->(MsUnlock())
					EndIf
				EndIf
			EndIf
		Next nLine
	EndIf
Return lRet