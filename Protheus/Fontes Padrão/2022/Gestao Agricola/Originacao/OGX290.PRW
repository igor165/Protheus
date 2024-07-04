#INCLUDE "Protheus.ch"
#INCLUDE "fwMvcDef.ch"
#INCLUDE "ogx290.ch"



/*{Protheus.doc} OGX290WHEN
//Trata o when de campo da tabela N9A.
@author roney.maia
@since 28/03/2018
@version 1.0
@return ${return}, ${.T. - Desbloqueado, .F. - Bloqueado}
@type function
*/
Function OGX290WHEN()

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oModelN9A	:= Nil
	Local lRfResum	:= FwIsInCallStack("OGX290")
	Local lUnlock	:= (FwIsInCallStack("OGX290MACT") .OR. FwIsInCallStack("OGX290OK")) // Rotinas DE-PARA entre models
	Local cCampo	:= ReadVar()

	If Select("NJR") > 0 .AND. !AGRTPALGOD(NJR->NJR_CODPRO) // Verifica se o alias esta aberto, e se o produto é algodão
		RestArea(aArea)
		Return .F.
	EndIf

	// Se o modelo está ativo e a rotina ogx290 esta empilhada então verifica o take-up
	If oModel != Nil .AND. oModel:IsActive() .AND. oModel:GetId() == "OGA290" .AND. lRfResum .AND. !lUnlock
		oModelN9A := oModel:GetModel("N9AUNICO")

		Do Case
			// Caso for disparado o when de campo para o campo de take-up e a linha posicionada está com take-up, então bloqueia o mesmo
			Case 'N9A_TAKEUP' $ cCampo .AND. !Empty(_aTakeUps) .AND. ;
			aScan(_aTakeUps, {|x| !oModelN9A:IsDeleted() .AND. x[1] == oModelN9A:GetValue("N9A_ITEM") .AND. x[2] == oModelN9A:GetValue("N9A_SEQPRI")}) > 0
				lRet := .F.

		EndCase
	EndIf

	RestArea(aArea)

Return lRet

/*{Protheus.doc} OGX290FIL
//Filtro para consulta padrão, no qual é filtrado somente os take-ups,
da previsão de entrega posicionada no contrato, filtrando tambem pela filial
de origem.
@author roney.maia
@since 28/03/2018
@version 1.0
@return ${return}, ${Query de filtro para a consulta padrão}
@type function
*/
Function OGX290FIL()

	Local aArea		:= GetArea()
	Local oView		:= FwViewActive()
	Local oModel	:= Nil
	Local oModelNJR	:= Nil
	Local oModelNNY	:= Nil
	Local cQuery	:= ""

	If oView != Nil
		oModel := oView:GetModel()
		oModelNJR := oModel:GetModel("NJRUNICO")
		oModelNNY := oModel:GetModel("NNYUNICO")

		cQuery += "@ D_E_L_E_T_ = '' "
		cQuery += " AND DXP_FILIAL ='" + oModelNJR:GetValue("NJR_FILIAL") + "'"
		cQuery += " AND DXP_CODCTP ='" + oModelNJR:GetValue("NJR_CODCTR") + "'"
		cQuery += " AND DXP_ITECAD ='" + oModelNNY:GetValue("NNY_ITEM") + "'"
		cQuery += " AND DXP_STATUS = '2'"  
		cQuery += " AND EXISTS(SELECT * FROM "+ RetSqlName('DXQ') + " DXQ"
		cQuery += " WHERE DXQ.DXQ_FILIAL = DXP_FILIAL"
		cQuery += " AND DXQ.D_E_L_E_T_ = '' "
		cQuery += " AND DXQ.DXQ_CODRES = DXP_CODIGO"
		cQuery += " AND DXQ.DXQ_FILORG = '" + oModelNNY:GetValue('NNY_FILORG') + "'"
		cQuery += " AND DXQ.DXQ_QUANT > 0 )"
		
	EndIf

	RestArea(aArea)

Return cQuery

/*{Protheus.doc} OGX290VLD
//Valida os campos da tabela N9A.
@author roney.maia
@since 28/03/2018
@version 1.0
@return ${return}, ${.T. - Válido, .F. - Inválido}
@type function
*/
Function OGX290VLD()

	Local aArea		:= GetArea()
	Local oView		:= FwViewActive()
	Local oModel	:= Nil
	Local oModelNJR	:= Nil
	Local oModelNNY	:= Nil
	Local oModelN9A	:= Nil
	Local cCampo	:= ReadVar()
	Local lRet		:= .T.
	Local cQuery	:= ""

	If oView != Nil
		oModel := oView:GetModel()
		oModelNJR := oModel:GetModel("NJRUNICO")
		oModelNNY := oModel:GetModel("NNYUNICO")
		oModelN9A := oModel:GetModel("N9AUNICO")

		If oModelN9A:GetValue("N9A_FILORG") == oModelNNY:GetValue('NNY_FILORG')  // Executa a validação somente para a mesma filial de origem
			Do Case
				Case "N9A_TAKEUP" $ cCampo // Valida o campo de take-up

					cQuery += "SELECT DXP_CODIGO FROM " + RetSqlName("DXP") + " DXP"
					cQuery += "	WHERE D_E_L_E_T_ = '' "
					cQuery += " AND DXP_FILIAL ='" + oModelNJR:GetValue("NJR_FILIAL") + "'"
					cQuery += " AND DXP_CODCTP ='" + oModelNJR:GetValue("NJR_CODCTR") + "'"
					cQuery += " AND DXP_ITECAD ='" + oModelNNY:GetValue("NNY_ITEM") + "'" 
					cQuery += " AND DXP_CODIGO ='" + oModelN9A:GetValue("N9A_TAKEUP") + "'"
					cQuery += " AND EXISTS(SELECT * FROM "+ RetSqlName('DXQ') + " DXQ"
					cQuery += " WHERE DXQ.DXQ_FILIAL = DXP_FILIAL"
					cQuery += " AND DXQ.D_E_L_E_T_ = '' "
					cQuery += " AND DXQ.DXQ_CODRES = DXP_CODIGO"
					cQuery += " AND DXQ.DXQ_FILORG = '" + oModelNNY:GetValue('NNY_FILORG')  + "'"
					cQuery += " AND DXQ.DXQ_QUANT > 0 )"

					cAliasQry := GetSQLAll(cQuery) // Executa a query e retorna um alias com a estrutura

					(cAliasQry)->(dbGoTop())
					If !(cAliasQry)->(EOF()) // Verifica se encontrou 1 registro e define como válido
						lRet := .T.
					ElseIf Empty(&(cCampo))
						lRet := .T.
					Else // Se não encontrou então se torna inválido
						Help("", 1, "REGNOIS")
						lRet := .F.
					EndIf

					(cAliasQry)->(dbCloseArea())
			EndCase
		EndIf	
	EndIf

	RestArea(aArea)

Return lRet
