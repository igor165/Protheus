#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#INCLUDE "VEIA110EVDEF.CH"

CLASS VEIA110EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD GridLinePreVld()
ENDCLASS

METHOD New() CLASS VEIA110EVDEF
	
RETURN


METHOD ModelPosVld(oModel, cModelId) CLASS VEIA110EVDEF

	Local nOperation := oModel:GetOperation()
	Local oModelVJJ
	Local nPosQuote
	Local lContinua := .t.
	Local oJDQuote

	If nOperation == MODEL_OPERATION_DELETE
		oModelVJJ := oModel:GetModel("MODEL_VJJ")
		oJDQuote := VEJDQuoteMaintainQuote():New()
		If ! VA110E0013_VerificaStatusPortal(oJDQuote, oModelVJJ)
			Return .f.
		EndIf

		lContinua := .f.
		For nPosQuote := 1 to Len(oJDQuote:aResponse)
			If oJDQuote:aResponse[nPosQuote]:quoteId <> oModelVJJ:GetValue("VJJ_ID")
				Loop
			EndIf
			If oJDQuote:aResponse[nPosQuote]:deleteIndicator
				lContinua := .t.
			Else
				FMX_HELP("VA060EVDEFERR02",STR0001,STR0002) // "Só é permitida a exclusão de cotações que foram excluídas do portal antes." // "Acesse o portal do JDQuote, exclua a cotação e tente excluir o registro novamente do Protheus."
				Return .f.
			EndIf
		Next 

		If lContinua
			// TO-DO Excluir registros de oportunidade e/ou atendimentos relcionados à Cotação.
		EndIf
		
	EndIf

Return lContinua

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA110EVDEF
	Local lRet    := .t.
	
	If cModelId == "MODEL_VJK"
		Do Case
		Case cAction == "CANSETVALUE" // Pode atribuir Valor no campo ?
			If cId $ "VJK_INTEGR/VJK_CODMAR/VJK_MODVEI/VJK_SEGMOD" .and. (! Empty(oSubModel:GetValue("VJK_CODOPO")) .or. ! Empty(oSubModel:GetValue("VJK_NUMTRA")))
				lRet := .f.
			EndIf
		Case cAction == "SETVALUE"
			Do Case
			Case cId == "VJK_CODMAR"
				If Empty(xValue)
					Return .t.
				EndIf

				// Posicionamento da tabela VE1 para funcionamento correto do consulta padrao de grupo de modelo
				VE1->(dbSetOrder(1))
				VE1->(dbSeek(xFilial("VE1") + xValue))
				//

				cFilCodMar := xValue

			EndCase
		EndCase
	EndIf
RETURN lRet


/*/{Protheus.doc} VA110E0013_VerificaStatusPortal

	Verifica se a Cotação está deletada no portal do JDQuote

	@type  Static Function
	@author Rubens
	@since 02/07/2019
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	/*/
Static Function VA110E0013_VerificaStatusPortal(oJDQuote, oModelVJJ)
	//Local dDataFinal := oModelVJJ:GetValue("VJJ_DTMOD") + 300

	If oModelVJJ:GetValue("VJJ_DELETE") == "1"
		Return .t.
	EndIf

Return VA1100483_CotacaoDeletada(oJDQuote, oModelVJJ:GetValue("VJJ_DTMOD"), oModelVJJ:GetValue("VJJ_ID"))