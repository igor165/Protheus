#INCLUDE "PROTHEUS.CH"

Function OMSAvalSF2(aCarga,nRecnoDAK)
Local aAreaDAI   := DAI->(GetArea())
Local lGrvVeic   := .F.
Local cOmsCplInt := SuperGetMv("MV_CPLINT",.F.,"2") // Integração OMS x CPL
Local cFilSav    := cFilAnt
Local cQuery     := ""
Local cAliasQry  := ""

	// Tratamento para Filial Operador Logistico
	If	Type("cFilOpl") <> "U" .And. cFilOpl <> cFilAnt
		cFilAnt := cFilOpl
	EndIf

	If nRecnoDAK <> 0
		lGrvVeic := .T.
		If AScan(aCarga,nRecnoDAK) == 0
			AAdd(aCarga,nRecnoDAK)
		EndIf
	Else
		DAK->(DbSetOrder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR
		If DAK->(DbSeek(xFilial("DAK")+SC9->C9_CARGA+SC9->C9_SEQCAR))
			lGrvVeic := .T.
			If AScan(aCarga,DAK->(Recno())) == 0
				AAdd(aCarga,DAK->(Recno()))
			EndIf
		EndIf
	EndIf

	If lGrvVeic
		SF2->F2_VEICUL1 := DAK->DAK_CAMINH
		If DAK->(ColumnPos("DAK_VEIC2")) > 0
			SF2->F2_VEICUL2 := DAK->DAK_VEIC2
			SF2->F2_VEICUL3 := DAK->DAK_VEIC3
		EndIf
	EndIf

	DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
	If DAI->(DbSeek(xFilial("DAI")+SC9->C9_CARGA+SC9->C9_SEQCAR+SC9->C9_SEQENT+SC9->C9_PEDIDO))
		RecLock("DAI",.F.)
		DAI->DAI_NFISCA := SF2->F2_DOC
		SerieNfId("DAI",1,"DAI_SERIE",,,, SF2->F2_SERIE )
		DAI->(MsUnlock())
		// Se possui integração OMS x CPL
		If cOmsCplInt == "1"
			cQuery := "SELECT DK1.R_E_C_N_O_ RECNODK1"
			cQuery +=  " FROM "+RetSqlName("DK0")+" DK0,"
			cQuery +=           RetSqlName("DK1")+" DK1"
			cQuery += " WHERE DK0.DK0_FILIAL = '"+xFilial("DK0")+"'"
			cQuery +=   " AND DK0.DK0_CARGA  = '"+SC9->C9_CARGA+"'"
			cQuery +=   " AND DK0.D_E_L_E_T_ = ' '"
			cQuery +=   " AND DK1.DK1_FILIAL = '"+xFilial("DK1")+"'"
			cQuery +=   " AND DK1.DK1_REGID  = DK0.DK0_REGID"
			cQuery +=   " AND DK1.DK1_VIAGID = DK0.DK0_VIAGID"
			cQuery +=   " AND DK1.DK1_FILPED = '"+SC9->C9_FILIAL+"'"
			cQuery +=   " AND DK1.DK1_PEDIDO = '"+SC9->C9_PEDIDO+"'"
			cQuery +=   " AND DK1.DK1_ITEMPE = '"+SC9->C9_ITEM+"'"
			cQuery +=   " AND DK1.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
			While !(cAliasQry)->(Eof())
				DK1->(DbGoTo((cAliasQry)->RECNODK1))
				RecLock('DK1',.F.)
				DK1->DK1_NFISCA := SF2->F2_DOC
				DK1->DK1_SERIE  := SF2->F2_SERIE
				DK1->(MsUnLock())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

	// Tratamento para Filial Operador Logistico
	If cFilAnt <> cFilSav
		cFilAnt := cFilSav
	EndIf

RestArea(aAreaDAI)
Return
//-----------------------------------------------------------------
/*/{Protheus.doc} OmsxFunVQE
Valida se a carga do pedido possui a transportadora informada

@param aQuebra	, Array, Array de quebra
@param cCarga	, Caracter, Carga do pedido

@Return lRet	, Boleano, Indica que a transportadora está informada
@author Squad WMS/OMS Protheus
@since 04/09/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Function OMSValQbrE(aQuebra,cCarga)
Local lRet      := .F.
Local aAreaAnt  := {}
Local cAliasQry := Nil
Local nPos      := 0
	// Verifica se houveram diferença além da transportadora
	// Caso existam diferenças além da transpordora considera como quebra
	If (aScan(aQuebra,{|x| If(x[1] <> 'C5_TRANSP',&(x[1])<>x[2],.F.) }) == 0)
		// Verifica se a transportadora é diferente para avaliar se a carga possui transportadora
		If (nPos := aScan(aQuebra,{|x| x[1] == 'C5_TRANSP'})) > 0 .And. &(aQuebra[nPos][1]) <> aQuebra[nPos][2]
			aAreaAnt  := GetArea()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:DAK% DAK
				WHERE DAK.DAK_FILIAL = %xFilial:DAK%
				AND DAK.DAK_COD = %Exp:cCarga%
				AND DAK.DAK_TRANSP <> '  '
				AND DAK.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				lRet := .T.
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aAreaAnt)
		EndIf
	EndIf
Return lRet