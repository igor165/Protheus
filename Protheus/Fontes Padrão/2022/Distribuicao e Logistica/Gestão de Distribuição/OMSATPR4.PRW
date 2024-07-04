#INCLUDE "PROTHEUS.CH"
#include 'OMSATPR4.ch'


/*/-----------------------------------------------------------
{Protheus.doc} OmsTPRInfo()
Informa o status para o OMSA200
@author Equipe OMS
@since 30/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Function OmsTPRInfo(cCarga)
	Local cStatus := ""
	Local aArea   := GetArea()

	DMS->(DbSetOrder(3))
	If DMS->(DbSeek(FwXFilial("DMS")+"DAK"+FwXFilial("DAK")+cCarga))
		cStatus := STR0001//"INTEGRADO COM TPR"
		//DLU_FILIAL+DLU_FILENT+DLU_ENTIDA+DLU_CHVENT+DLU_CODIGO   
		DLU->(DbSetOrder(2))
		If DLU->(DbSeek(FwXFilial("DLU")+FwXFilial("DMR")+"DMR"+DMS->DMS_FILROT+DMS->DMS_IDROT))
			If !Empty(DLU->DLU_RETORN)
				If DMS->DMS_STATUS = "3"
					cStatus := STR0002//"INTEGRADO COM TPR (MAPA DISPONÍVEL)"
				ElseIf DMS->DMS_STATUS = "2"
					cStatus := STR0022 //"INTEGRADO COM TPR (REJEITADO)"
				ElseIf DMS->DMS_STATUS = "4"
					cStatus := STR0023 //"INTEGRADO COM TPR (COM FALHA)"
				EndIf
			ElseIf DMS->DMS_STATUS = "1"
				cStatus := STR0024//"EM PLANEJAMENTO COM TPR"
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return cStatus



/*/{Protheus.doc} OMSTPRDMSC
** Deleta todos os registros da DMS que tenham a carga do paramentro
Ao estornar a carga é preciso liberar todos os registros para integrar novamente
@author Equipe OMS
@since 14/09/2021
/*/
Function OMSTPRDMSC(cFilCar, cCarga)
	Local aDoctosDMS := {}
	Local oModel   := Nil
	Local oMdFldDMR:= Nil
	Local oMdGrdDMS:= Nil
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local nX := 0
	Local aErrors := {}
	Local cAliasQry
	Local cQuery
	Local cCHVEXT := cFilCar+cCarga
	Local cFilDMS := ""
	Local cFilROT := ""
	Local cIdRot := ""
	Local cCHVENT := ""

	cQuery := "SELECT DMS_FILIAL,DMS_FILROT,DMS_IDROT,DMS_CHVENT"
	cQuery += 		" FROM " + RetSqlName("DMS") + " DMS "
	cQuery += 			" WHERE DMS_FILIAL = '"+FwxFilial("DMS") +"'"
	cQuery += 				" AND DMS_CHVEXT = '"+cCHVEXT+"'"
	cQuery += 				" AND DMS_STATUS = '3'"
	cQuery += 				" AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	While !(cAliasQry)->( Eof() )
		Aadd(aDoctosDMS, (cAliasQry)->DMS_CHVENT)
		If Empty(cIdRot)
			cFilDMS := (cAliasQry)->DMS_FILIAL
			cFilROT := (cAliasQry)->DMS_FILROT
			cIdRot  := (cAliasQry)->DMS_IDROT
		EndIf
		(cAliasQry)->( dbSkip() )
	EndDo
	If !Empty(cIdRot)
		DMR->(DbSetOrder(1))
		If DMR->(DbSeek(cFilDMS+cFilROT+cIdRot))

			oModel := FWLoadModel( 'TMSAC19' )
			oModel:SetOperation( 4 )
			oModel:Activate()

			oMdFldDMR:= oModel:GetModel("MdFieldDMR")
			oMdGrdDMS:= oModel:GetModel("MdGridDMS")

			//Excluir apenas as linhas utilizadas para a carga
			For nX := 1 To Len(aDoctosDMS)
				cCHVENT := aDoctosDMS[nX]
				oMdGrdDMS:SeekLine({{"DMS_IDROT",cIdRot},{"DMS_ENTIDA",'SC9'},{"DMS_CHVENT",cCHVENT},{"DMS_STATUS",'3'}})
				oMdGrdDMS:DeleteLine()
			Next nX
			lRet := oModel:VldData()
			If lRet 
				oModel:CommitData()
			Else
				Aadd(aErrors,  oModel:GetErrorMessage()[6] )
			EndIf
			oModel:Destroy()
			oModel:= Nil	

			//Se excluir todas as linhas da DMS, excluir também o planejamento.
			DMS->(DbSetOrder(1))
			If !DMS->(DbSeek(cFilDMS+cFilROT+cIdRot))
				DMR->(DbSetOrder(1))
				If DMR->(DbSeek(cFilDMS+cFilROT+cIdRot))
					oModel := FWLoadModel( 'TMSAC19' )
					oModel:SetOperation( 5 )
					oModel:Activate()
					lRet := oModel:VldData()
					If lRet 
						oModel:CommitData()
					Else
						Aadd(aErrors,  oModel:GetErrorMessage()[6] )
					EndIf
					oModel:Destroy()
					oModel:= Nil	
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return

/*/{Protheus.doc} OMSTPRCan
** Deleta a roteirizacao TPR relacionada com a carga
@author Equipe OMS
@since 14/09/2021
/*/
Function OMSTPRCan(cCHVDMR, lPergunta, cFilDMR, cFilRot, cIdRot)
	Local oModelDMR
	Local lRet 		:= .T.
	Local lSemCarga := .F.
	Local aCarOK    := {}
	Local aCarNOK   := {}
	Local nX        := 1
	Local cMsgAlert := ""
	Local nCount    := 0
	Default lPergunta := .T.
	Default cFilDMR := DMR->DMR_FILIAL
	Default cFilRot := DMR->DMR_FILROT
	Default cIdRot  := DMR->DMR_IDROT

	If lPergunta
		lSemCarga := OMSTPRVLDD(cFilDMR, cFilRot, cIdRot)
	EndIf

	If !lSemCarga .And. lPergunta
		lRet := OMSTPRCarOK(cFilDMR, cFilRot, cIdRot, @aCarOK, @aCarNOK)
		If !Empty(aCarNOK)
			cMsgAlert := STR0026 + cFilRot + cIdRot + STR0027 //"Não foi possível cancelar a roteirização ". O status da(s) carga(s) "
			For nX := 1 to Len(aCarNOK)
				If nCount > 0
					cMsgAlert += " ,"
				EndIf
				cMsgAlert += aCarNOK[nX]
				nCount++
			Next nX
		EndIf
		cMsgAlert += STR0028 //" não permite estorno."
		If !lRet
			MsgAlert(cMsgAlert, STR0029)//Atenção
		EndIf
	EndIf

	If lRet .And. !lSemCarga .And. lPergunta
		lRet := MsgYesNo(STR0025) //"A roteirização possui carga gerada. Confirma o estorno da roteirização? A carga será mantida!"
	EndIf

	If lRet
		If lSemCarga .And. lPergunta
			lRet := MsgYesNo(STR0003)//"Tem certeza que deseja cancelar a integração enviada para o TPR?"
		EndIf
		If lRet
			DMR->(DbSetOrder(1))
			If DMR->(DbSeek(cCHVDMR))
				oModelDMR := FWLoadModel( 'TMSAC19' )
				oModelDMR:SetOperation( 5 )
				oModelDMR:Activate()
				lRet := oModelDMR:VldData()
				If lRet 
					oModelDMR:CommitData()
				Else
					Help(,,'HELP',,oModelDMR:GetErrorMessage()[6],1,0,)
				EndIf
				oModelDMR:Destroy()
				oModelDMR:= Nil	
			EndIf
		EndIf
	EndIf
Return lRet

// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPR410P
Valida ações da manipulação do pedido/com base no cockpit OMSCPLVlPd
@author carlos.augusto
@since 08/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSTPR410P(nAcao,aHeader,aCols,cPedido,cItem,cSequen,cProduto)
	Local lRet      := .T.
	Local aAreaSC6  := SC6->(GetArea())
	Local cStatus 	:= ""
	Local cCarga 	:= ""
	Local aItensDMS := {}
	Local aChvCargas := {}
	Local lCarga 	:= .F.
	Local lDisp 	:= .F.
	Local lResp 	:= .T.
	Local cCampo 	:= ""
	Local llogTPR	:= SuperGetMV("MV_TPRCLOG",.F.,.T.)
	Default nAcao := 1

	DbSelectArea("DAK")

	If ColumnPos("DAK_INTTPR") > 0 .And. X3USO(GetSX3Cache("DAK_INTTPR", "X3_USADO")) .And. FindFunction("OMSROTEIRI")
		cRoteiri := OMSROTEIRI()
		If cRoteiri = '2'
			If nAcao == 2
				/* MATA410 > Alterar. Esta acao e executada antes de abrir a tela para alterar o pedido.
				OMSTRPVld1 - Valida se tem carga e roteirizacao. Se lCarga = .T. possui carga
				Caso nao tenha carga, procurar viagem com status de rejeicao ou falha, 
				o usuario deve escolher se quer perder a roteirizacao. Ela sera excluir ao confirmar a alteracao do pedido*/
				lCarga := OMSTRPVld1(@cCarga,aChvCargas,cPedido)
				If lCarga
					lRet := MsgYesNo(STR0006 + cCarga+ STR0007)//"O pedido possui a(s) carga(s)  cCarga
					//" e roteirização com o TPR. A alteração do pedido excluirá a roteirização realizada da(s) carga(s). Deseja iniciar o processo de alteração do pedido?"  
				EndIf

				If !lCarga
					lDisp := OMSTRPVld2(@aItensDMS, @cStatus, cPedido )
					If !lDisp
						lRet := MsgYesNo(STR0008 + cStatus + ". " + STR0009)//"O pedido possui integração com o TPR no(s) status "
						//"A alteração do pedido excluirá tentativa de roteirização do pedido. Deseja iniciar o processo de alteração do pedido?"
					EndIf
				EndIf
			ElseIf nAcao == 4 
				/* MATA410 > Alterar > Confirmar 
				Ao confirmar a alteracao do pedido o usuario ja aceitou excluir os registros da DMS anterior e ja passou pela validacoes
				da acao 2. Mesmo assim, antes de salvar, sera questionado ao usuario o descarte da ultima integracao */
				cPedido := M->C5_NUM

				lCarga := OMSTRPVld1(@cCarga,aChvCargas,cPedido)
								
				If lCarga .And. !Empty(aChvCargas) 
					aItens := aChvCargas
					cCampo := "DMS_CHVEXT"
					OMSTPR410D(llogTPR, aItens, cCampo, "MATA410 > Alterar > Confirmar")
				EndIf
				
				If lResp
					lDisp := OMSTRPVld2(@aItensDMS, @cStatus, cPedido)
					If !lDisp .And. !Empty(aItensDMS)
						aItens := aItensDMS
						cCampo := "DMS_CHVENT"
						OMSTPR410D(llogTPR, aItens, cCampo, "MATA410 > Alterar > Confirmar")
					Endif
				EndIf
				// lRet := lResp
				lRet := .T.

			ElseIf nAcao == 6 
					/* MATA460A > Preparacao Documentos de Saida > Estorn. Docs 
					Antes de falar do processo, e importante destacar que o MV_PAR02 da rotina define se sera estornado
					os registros marcados ou posicionado. Se forem os marcados, a nAcao sera executada pela quantidade de vezes marcadas.
					OMSTRPVld1 - Valida se tem carga e roteirizacao. Se lCarga = .T. possui carga
					Caso nao tenha carga, procurar viagem com status de rejeicao ou falha, 
					o usuario deve escolher se quer perder a roteirizacao. Ela sera excluir ao confirmar a alteracao do pedido*/
				lCarga := OMSTRPVld1(@cCarga,aChvCargas, cPedido,cItem,cSequen,cProduto)
				If lCarga
					lResp := .F.
					MsgInfo(STR0010 + cPedido + STR0011 + cItem + STR0012 + cSequen + STR0013 + RTrim(cProduto) + STR0014 + cCarga + STR0015 )
					//"Ao estornar o pedido "+cPedido+", item "+cItem+", sequência "+cSequen+" e produto "+RTrim(cProduto)+", a roteirização com o TPR da carga "+cCarga+" foi excluída." 
				EndIf
				
				If lCarga .And. !Empty(aChvCargas) 
					aItens := aChvCargas
					cCampo := "DMS_CHVEXT"
					OMSTPR410D(llogTPR, aItens, cCampo, "MATA460A > Preparacao Documentos de Saida > Estorn. Docs")
				EndIf
				If !lCarga
					lDisp := OMSTRPVld2(@aItensDMS, @cStatus, cPedido,cItem,cSequen,cProduto)
					If !lDisp 
						If lResp
							MsgInfo(STR0010 + cPedido + STR0011 + cItem + STR0012 + cSequen + STR0013 + RTrim(cProduto) + STR0016 + cStatus + STR0015 )
							//MsgInfo("Ao estornar o pedido "+cPedido+", item "+cItem+", sequência "+cSequen+" e produto "+RTrim(cProduto)+" a tentativa de roteirização com o TPR no status "+cStatus+" foi excluída." )
						EndIf
					EndIf
				EndIf
				If !lDisp .And. !Empty(aItensDMS)
					aItens := aItensDMS
					cCampo := "DMS_CHVENT"
					OMSTPR410D(llogTPR, aItens, cCampo, "MATA460A > Preparacao Documentos de Saida > Estorn. Docs ")
				Endif
				lRet := .T.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC6)
Return lRet


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTRPVld1
Valida se existe carga para o pedido. Se tem deve retornar
@author equipe OMS
@since 08/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Static Function OMSTRPVld1(cCarga,aChvCargas, cPedido,cItem,cSequen,cProduto)
	Local lRet 		:= .F.
	Local cQuery 	:= ""
	Local cAliasQry := ""
	Local nTamSubs 	:= TamSX3('C9_FILIAL')[1]+TamSX3('C9_PEDIDO')[1]+1
	Local cSubstr 	:= FwxFilial("SC9")+cPedido
	Local nCount 	:= 0

	If !Empty(cItem)
		nTamSubs += TamSX3('C9_ITEM')[1]
		cSubstr  += cItem
	EndIf
	If !Empty(cSequen)
		nTamSubs += TamSX3('C9_SEQUEN')[1]
		cSubstr  += cSequen
	EndIf
	If !Empty(cProduto)
		nTamSubs += TamSX3('C9_PRODUTO')[1]
		cSubstr  += cProduto
	EndIf

	cQuery := " SELECT C9_CARGA, DMS_CHVEXT, DMS.DMS_FILIAL,DMS.DMS_FILROT,DMS.DMS_IDROT,DMS.DMS_STATUS "
	cQuery +=   " FROM "+RetSqlName('SC9')+" SC9"
	cQuery += 		" INNER JOIN " + RetSqlName("DMS") + " DMS ON(DMS.DMS_FILIAL  = '"+FwXFilial("DMS")+"'"

	cQuery += 		" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamSubs - 1)+") = '"+cSubstr+"'"
	
	cQuery += 		" AND DMS.DMS_FILROT = '"+cFilAnt+"'"
	cQuery += 		" AND DMS.DMS_ENTIDA = 'SC9')"
	cQuery +=		" WHERE SC9.C9_FILIAL = '"+FwxFilial("SC9")+"'"
	cQuery +=			" AND SC9.C9_PEDIDO = '"+cPedido+"'"
	If !Empty(cItem)
		cQuery +=		" AND SC9.C9_ITEM = '"+cItem+"'"
	EndIf
	If !Empty(cSequen)
		cQuery +=		" AND SC9.C9_SEQUEN = '"+cSequen+"'"
	EndIf
	If !Empty(cProduto)
		cQuery +=		" AND SC9.C9_PRODUTO = '"+cProduto+"'"
	EndIf
	cQuery +=			" AND SC9.C9_CARGA <> ' '"
	cQuery +=			" AND SC9.C9_SEQCAR <> ' '"
	cQuery +=			" AND SC9.D_E_L_E_T_ = ' '"
	cQuery += 			" AND DMS.D_E_L_E_T_ = ' '"
	cQuery += 			" AND DMS.DMS_STATUS = '3'"
	cQuery += 			" AND DMS.DMS_CHVEXT <> ' '"
	cQuery += 			" GROUP BY C9_CARGA,DMS.DMS_CHVEXT, DMS.DMS_FILIAL,DMS.DMS_FILROT,DMS.DMS_IDROT,DMS_STATUS "

	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->(!EoF())
		Aadd(aChvCargas, { (cAliasQry)->DMS_FILIAL+(cAliasQry)->DMS_FILROT+(cAliasQry)->DMS_IDROT,(cAliasQry)->DMS_CHVEXT,(cAliasQry)->DMS_STATUS} )
		lRet := .T.
		If nCount > 0 .And. !(cAliasQry)->C9_CARGA $ cCarga
			cCarga += ", " +  (cAliasQry)->C9_CARGA 
		ElseIf !(cAliasQry)->C9_CARGA  $ cCarga
			nCount++
			cCarga +=  (cAliasQry)->C9_CARGA 
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return lRet


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTRPVld2
Retorna os status das viagens do pedido e as roteirizacoes
@author equipe OMS
@since 08/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Static Function OMSTRPVld2(aItensDMS, cStatus,cPedido,cItem,cSequen,cProduto)
	Local lRet 		:= .T.
	Local cQuery 	:= ""
	Local cAliasQry := ""
	Local nCount 	:= 0
	Local nTamSubs 	:= TamSX3('C9_FILIAL')[1]+TamSX3('C9_PEDIDO')[1]+1
	Local cSubstr 	:= FwxFilial("SC9")+cPedido

	If !Empty(cItem)
		nTamSubs += TamSX3('C9_ITEM')[1]
		cSubstr  += cItem
	EndIf
	If !Empty(cSequen)
		nTamSubs += TamSX3('C9_SEQUEN')[1]
		cSubstr  += cSequen
	EndIf
	If !Empty(cProduto)
		nTamSubs += TamSX3('C9_PRODUTO')[1]
		cSubstr  += cProduto
	EndIf

	cQuery := " SELECT DMS_STATUS,DMS_CHVENT,"
	cQuery +=   " DMS.DMS_FILIAL,DMS.DMS_FILROT,DMS.DMS_IDROT "
	cQuery +=   " FROM "+RetSqlName('SC9')+" SC9"
	cQuery += 		" INNER JOIN " + RetSqlName("DMS") + " DMS ON(DMS.DMS_FILIAL  = '"+FwXFilial("DMS")+"'"
	cQuery += 		" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamSubs - 1)+") = '"+cSubstr+"'"
	
	cQuery += 		" AND DMS.DMS_FILROT = '"+cFilAnt+"'"
	cQuery += 		" AND DMS.DMS_ENTIDA = 'SC9')"
	cQuery +=		" WHERE SC9.C9_FILIAL = '"+FwxFilial("SC9")+"'"
	cQuery +=			" AND SC9.C9_PEDIDO = '"+cPedido+"'"
	If !Empty(cItem)
		cQuery +=		" AND SC9.C9_ITEM = '"+cItem+"'"
	EndIf
	If !Empty(cSequen)
		cQuery +=		" AND SC9.C9_SEQUEN = '"+cSequen+"'"
	EndIf
	If !Empty(cProduto)
		cQuery +=		" AND SC9.C9_PRODUTO = '"+cProduto+"'"
	EndIf
	cQuery +=			" AND SC9.D_E_L_E_T_ = ' '"
	cQuery += 			" AND DMS.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->(!EoF())
		lRet := .F.
		If cStatus = NIL
			Exit
		EndIf
		Aadd(aItensDMS, {(cAliasQry)->DMS_FILIAL + (cAliasQry)->DMS_FILROT + (cAliasQry)->DMS_IDROT,(cAliasQry)->DMS_CHVENT,(cAliasQry)->DMS_STATUS}) 
		If nCount > 0 .And. !X3CboxDesc( "DMS_STATUS", (cAliasQry)->DMS_STATUS ) $ cStatus 
			cStatus += ", " + X3CboxDesc( "DMS_STATUS", (cAliasQry)->DMS_STATUS )
		ElseIf !X3CboxDesc( "DMS_STATUS", (cAliasQry)->DMS_STATUS ) $ cStatus
			nCount++
			cStatus += X3CboxDesc( "DMS_STATUS", (cAliasQry)->DMS_STATUS )
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return lRet


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPRVLDD
Valida se a roteirizacao possui carga
@author equipe OMS
@since 08/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Static Function OMSTPRVLDD(cFilDMR, cFilRot, cIdRot)
	Local lRet     := .T.
	Local cAliasQry
	Local cQuery
	Local aArea 	:= GetArea()

	cQuery := "SELECT DMS_FILIAL,DMS_FILROT,DMS_IDROT,DMS_CHVENT"
	cQuery += 		" FROM " + RetSqlName("DMS") + " DMS "
	cQuery += 			" WHERE DMS_FILIAL = '"+cFilDMR+"'"
	cQuery += 				" AND DMS_FILROT = '"+cFilRot+"'"
	cQuery += 				" AND DMS_IDROT = '"+cIdRot+"'"
	cQuery += 			" AND DMS.DMS_CHVEXT <> ' '"
	cQuery += 				" AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	If !(cAliasQry)->( Eof() )
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPR410D
Exclui lista de roteirizacoes
@author equipe OMS
@since 09/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Static Function OMSTPR410D(llogTPR, aItens, cCampoDMS, cFuncSel)
	Local lRet 	:= .F.
	Local nX := 1
	Local nY := 1
	Local cCHVEXT := ""
	Local cChvDMR := ""
	Local oModel := Nil
	Local oMdFldDMR := Nil
	Local oMdGrdDMS := Nil
	Local cStatus := ""
	Local cChvDMRDel := ""

	If !Empty(aItens)
		For nX := 1 To Len(aItens)

			cStatus 	:= aItens[nX][3]
			cChvDMRDel	:= aItens[nX][1]

			//Se for rejeitado ou falha deleta por item.
			If cStatus != "1" 
			//If (cStatus == "2" .Or. cStatus == "4" ) .And. cCampoDMS != "DMS_CHVEXT"
				If cChvDMR != aItens[nX][1]
					cChvDMR := aItens[nX][1]
					cCHVEXT := aItens[nX][2]
					DMR->(DbSetOrder(1))
					DMR->(DbSeek(cChvDMR))
					oModel := FWLoadModel( 'TMSAC19' )
					oModel:SetOperation( 4 )
					oModel:Activate()
					oMdFldDMR:= oModel:GetModel("MdFieldDMR")
					oMdGrdDMS:= oModel:GetModel("MdGridDMS")
					lRet := .T.
				EndIf
				For nY := 1 To oMdGrdDMS:Length()	
					oMdGrdDMS:Goline(nY)
					If oMdGrdDMS:GetValue(cCampoDMS) = cCHVEXT
						oMdGrdDMS:DeleteLine()
					EndIf
				Next nY
				lRet := oModel:VldData()
				If lRet 
					oModel:CommitData()
					OMSTPRCLOG(llogTPR, "OMSATPR4", STR0017+cFuncSel+STR0019+cChvDMR)
					//"TOTVS Planejamento de Rotas(TPR) - Sucesso na exclusao de integracao via "" com o ID: "
				Else
					OMSTPRCLOG(llogTPR, "OMSATPR4", STR0018+FuncSel+STR0019+cChvDMR + " - "+ oModel:GetErrorMessage()[6])
					//"TOTVS Planejamento de Rotas(TPR) - Falha na exclusao de integracao via "" com o ID: "
				EndIf

				//Se excluir todas as linhas da DMS, excluir também o planejamento.
				DMS->(DbSetOrder(1))
				If !DMS->(DbSeek(cCHVDMR))
					OMSTPRDDMR(llogTPR, cFuncSel,cCHVDMR)
				EndIf
			Else
				OMSTPRDDMR(llogTPR, cFuncSel,cChvDMRDel)
			EndIf

		Next nX
		If lRet
			oModel:Destroy()
			oModel:= Nil
		EndIf
	EndIf
Return


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPRDFUN
Informa se existe integracao para o pedido
@author equipe OMS
@since 09/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSTPRDFUN(cPedido)
	Local aArea 	:= GetArea()
	Local lDisp 	:= .T.
	Local aItensDMS := {}
	Local cStatus 	:= ""
	lDisp := OMSTRPVld2(aItensDMS, cStatus,cPedido)
	RestArea(aArea)
Return lDisp


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPRDDMR
Exclui DMR enviando para o log em qual programa foi realizado
@author equipe OMS
@since 09/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSTPRDDMR(llogTPR,cFuncSel,cCHVDMR)
	Local lRet 	:= .T.
	Local oModel := Nil

	DMR->(DbSetOrder(1))
	If DMR->(DbSeek(cCHVDMR))
		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 5 )
		oModel:Activate()
		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
			OMSTPRCLOG(llogTPR, "OMSATPR4", STR0020+cFuncSel+STR0019+cChvDMR)
			//"TOTVS Planejamento de Rotas(TPR) - Sucesso na exclusao da DMR de integracao via "" com o ID: "
		Else
			OMSTPRCLOG(llogTPR, "OMSATPR4", STR0021+FuncSel+STR0019+cChvDMR+" - "+ oModel:GetErrorMessage()[6])
			//"TOTVS Planejamento de Rotas(TPR) - Falha na exclusao da DMR de integracao via "" com o ID: "
		EndIf
		oModel:Destroy()
		oModel:= Nil
	EndIf

Return


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPRCLOG
Funcao crua para gravar mensagens no log
@author equipe OMS
@since 13/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSTPRCLOG(llogTPR, cPrograma, cMsgLog)
	Default llogTPR := SuperGetMV("MV_TPRCLOG",.F.,.T.)
	If llogTPR
		LogMsg( cPrograma,0, 0,1, cValToChar(TIME()), '',cMsgLog)
	EndIf
Return


// ---------------------------------------------------------
/*/{Protheus.doc} OMSVeiDiff
Verifica se o novo veiculo selecionado para a carga e diferente do roteirizado
@author equipe OMS
@since 23/03/2022
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSVeiDiff(cFilCar, cCarga, cVeiculo)
	Local cJsonRet 	 := ""
	Local aArea 	 := GetArea()
	Local oObj 		 := JsonObject():New()
	Local oObjRot 	 := JsonObject():New()
	Local nCount 	 := 1
	Local cFilCodVei := ""
	Local lRet 		 := .F.
	Local cCapaCN    := 0
	Local cVolMax    := 0
	Local cQtdEixIda := 0
	Local cQtdEixVol := 0

	//Busco veiculo da roteirizacao da carga
	DMS->(DbSetOrder(3))
	If DMS->(DbSeek(FwXFilial("DMS")+"DAK"+cFilCar+cCarga))
		//DLU_FILIAL+DLU_FILENT+DLU_ENTIDA+DLU_CHVENT+DLU_CODIGO   
		DLU->(DbSetOrder(2))
		If DLU->(DbSeek(FwXFilial("DLU")+FwXFilial("DMR")+"DMR"+DMS->DMS_FILROT+DMS->DMS_IDROT))
			If !Empty(DLU->DLU_RETORN)
				cJsonRet := DLU->DLU_RETORN

				If !Empty(cJsonRet) .And. oObj:FromJson( cJsonRet ) <> "C"
					For nCount := 1 To Len( oObj["tripsResults"] )
						oObjRot := oObj["tripsResults"][nCount]
						If oObjRot["sequential"] =  DMS->DMS_SEQROT
							cFilCodVei := oObjRot["vehicle"]["identifier"]
							Exit
						EndIf
					Next nCount
				EndIf
			EndIf
		EndIf
	EndIf

	//Somente se o veiculo selecionado for diferente do roteirizado vou realizar as validacoes de caracteristicas
	If cVeiculo <> cFilCodVei
		DA3->(DbSetOrder(1))
		If DA3->(DbSeek(cVeiculo)) //caracteristicas do veiculo selecionado
			cCapaCN    := DA3->DA3_CAPACN
			cVolMax    := DA3->DA3_VOLMAX
			cQtdEixIda := DA3->DA3_QTDEIX
			cQtdEixVol := DA3->DA3_QTEIXV
			DA3->(dbGoTop())
			If DA3->(DbSeek(cFilCodVei)) //caracteristicas do veiculo da roteirizacao
				If cCapaCN <> DA3->DA3_CAPACN .Or. cVolMax <> DA3->DA3_VOLMAX .Or.;
					cQtdEixIda <> DA3->DA3_QTDEIX .Or. cQtdEixVol <> DA3->DA3_QTEIXV
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return lRet


// ---------------------------------------------------------
/*/{Protheus.doc} OMSTPRCarOK
Valida se e possivel estornar a roteirizacao com base no status da carga
@author carlos.augusto
@since 08/10/2021
@version 1.0
/*/
// ---------------------------------------------------------
Static Function OMSTPRCarOK(cFilDMR, cFilRot, cIdRot, aCarOK, aCarNOK)
	Local lRet     := .T.
	Local cAliasQry
	Local cQuery
	Local aArea 	:= GetArea()
	Default aCarNOK := {}
	Default aCarOK  := {}

	cQuery := "SELECT DMS_FILIAL,DMS_FILROT,DMS_IDROT,DMS_CHVENT,DMS_CHVEXT"
	cQuery += 		" FROM " + RetSqlName("DMS") + " DMS "
	cQuery += 			" WHERE DMS_FILIAL = '"+cFilDMR+"'"
	cQuery += 				" AND DMS_FILROT = '"+cFilRot+"'"
	cQuery += 				" AND DMS_IDROT = '"+cIdRot+"'"
	cQuery += 			" AND DMS.DMS_CHVEXT <> ' '"
	cQuery += 				" AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	While !(cAliasQry)->( Eof() )

		DAK->(DbSetOrder(1))
		If DAK->(DbSeek( RTrim((cAliasQry)->DMS_CHVEXT )))
			If !( DAK->DAK_FEZNF == '2' .And. DAK->DAK_ACECAR == '2'.And. ;
				(DAK->DAK_BLQCAR == '2' .Or. DAK-> DAK_BLQCAR == ' ') .And. ;
				(DAK->DAK_JUNTOU =='MANUAL' .Or. DAK->DAK_JUNTOU == 'ASSOCI' .Or. DAK->DAK_JUNTOU == 'JUNTOU') )
				Aadd(aCarNOK, DAK->DAK_COD )
				lRet := .F.
			Else
				Aadd(aCarOK,  DAK->DAK_COD)
			EndIf
		EndIf
		(cAliasQry)->( DbSkip() )
	EndDo

	RestArea(aArea)
Return lRet
