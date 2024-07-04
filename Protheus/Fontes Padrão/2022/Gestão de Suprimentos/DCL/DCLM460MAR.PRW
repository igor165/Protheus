#INCLUDE "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLM460MARK
Valida geracao de nota apos confirmacao de estoque do produto  

@author Totvs
@since 07/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLM460MAR(cMarca,lInverte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva Integridade dos Dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea := GetArea()
Local _aAreaSG1     := SG1->(GetArea())
Local _aAreaSC6     := SC6->(GetArea())
Local _aAreaSB1     := SB1->(GetArea())
Local _aAreaSF4     := SF4->(GetArea())
Local _aAreaSB2     := SB2->(GetArea())
Local aAreaDH5		:= DH5->(GetArea())
Local cAliasSC9     := ""
Local cQrySC9       := ""
Local nEmpenho      := 0
Local nNotas        := 0
Local nPos          := 0
Local aEstoque      := {}
Local lRet          :=.T.
Local lMarcado      :=.T.
Local dFim          := CTOD("")
Local lFatPrev      := SuperGetMV("MV_FATFTPR",.F.,.T.) //Indica se permite faturar itens previstos (C9_TPOP = P)
Local cCmpUsr       := SuperGetMV("MV_CMPUSR",,"C5_MENNOTA")
Local cRotFat       := FunName()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

SaveInter() // Salva variaveis publicas 

//-- Validar conteudo parametro MV_CMPUSR
If Empty(cCmpUsr)
	cCmpUsr := "C5_MENNOTA"
EndIf
If cRotFat == "MATA460A"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01     // Filtra j  emitidas     - Sim/Nao             ³
	//³ mv_par02     // Estorno da Liberacao   - Posic./Marcados     ³
	//³ mv_par03     // Cons. Param. Abaixo    - Sim/Nao             ³
	//³ mv_par04     // Trazer Ped. Marc       - Sim/Nao             ³
	//³ mv_par05     // De  Pedido                                   ³
	//³ mv_par06     // Ate Pedido                                   ³
	//³ mv_par07     // De  Cliente                                  ³
	//³ mv_par08     // Ate Cliente                                  ³
	//³ mv_par09     // De  Loja                                     ³
	//³ mv_par10     // Ate Loja                                     ³
	//³ mv_par11     // De  Liberacao                                ³
	//³ mv_par12     // Ate Liberacao                                ³
	//³ mv_par13     // Mostra Itens Previstos - Sim/Não             ³
	//³ mv_par14     // De  Entrega                                  ³
	//³ mv_par15     // Ate Entrega                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MT461A",.F.)
	cQrySC9 := "SELECT SC9.R_E_C_N_O_ C9RECNO, SC9.C9_OK "
	cQrySC9 += "  FROM " + RetSqlName("SC9")+" SC9 "
	cQrySC9 += "WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"'"
	
	If ( MV_PAR01 == 1 )
		cQrySC9 += " And SC9.C9_BLEST<>'10'"
		cQrySC9 += " And SC9.C9_BLEST<>'ZZ'"
	EndIf
	
	If ( !lFatPrev )	//Indica se permite faturar itens Previstos (Campo C6_TPOP)
		//Filtra apenas itens com Tipo de Ordem de Produção Firmes (C6_TPOP = 'F' | C9_TPOP = '1')
		cQrySC9 += " And SC9.C9_TPOP != '2' "
	EndIf
	
	If ( MV_PAR03 == 1 )
		cQrySC9 += " And SC9.C9_PEDIDO  >='"+MV_PAR05+"'"
		cQrySC9 += " And SC9.C9_PEDIDO  <='"+MV_PAR06+"'"
		cQrySC9 += " And SC9.C9_CLIENTE >='"+MV_PAR07+"'"
		cQrySC9 += " And SC9.C9_CLIENTE <='"+MV_PAR08+"'"
		cQrySC9 += " And SC9.C9_LOJA    >='"+MV_PAR09+"'"
		cQrySC9 += " And SC9.C9_LOJA    <='"+MV_PAR10+"'"
		cQrySC9 += " And SC9.C9_DATALIB >='"+Dtos(MV_PAR11)+"'"
		cQrySC9 += " And SC9.C9_DATALIB <='"+Dtos(MV_PAR12)+"'"
		
		//Mostra itens previstos?
		If ( !Empty( MV_PAR13 ) ) .And. ( ValType(MV_PAR13) == 'N' )
			If ( MV_PAR13 == 2 ) .And. ( lFatPrev )
				cQrySC9 += " And SC9.C9_TPOP <> '2'"
			EndIf
		EndIf
		
		//Filtra por data de entrega
		If ( !Empty( MV_PAR14 ) ) .And. ( ValType(MV_PAR14) == 'D' )
			cQrySC9 += " And SC9.C9_DATENT >= '" + DToS(MV_PAR14) + "'"
		EndIf
		If ( !Empty( MV_PAR15 ) ) .And. ( ValType(MV_PAR15) == 'D' )
			cQrySC9 += " And SC9.C9_DATENT <= '" + DToS(MV_PAR15) + "'"
		EndIf
		
	EndIf
	If lInverte
		cQrySC9 += " AND SC9.C9_OK<>'"+cMarca+"'"
	Else
		cQrySC9 += " AND SC9.C9_OK='"+cMarca+"'"
	End
	cQrySC9 += " AND SC9.C9_NFISCAL = ''"
	cQrySC9 += " And SC9.D_E_L_E_T_ = ''"
ElseIf cRotFat == "MATA460B"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01     // Filtra j  emitidas     - Sim/Nao             ³
	//³ mv_par02     // Trazer Carga Marcada   - Sim/Nao             ³
	//³ mv_par03     // Carga Inicial                                ³
	//³ mv_par04     // Carga Final                                  ³
	//³ mv_par05     // Caminhao Inicial                             ³
	//³ mv_par06     // Caminhao Final                               ³
	//³ mv_par07     // Dt de Liberacao Inicial                      ³
	//³ mv_par08     // Dt de Liberacao Final                        ³
	//³ mv_par09     // Fatura Pedidos c/Bloqueio WMS? Sim/Nao       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MT461B",.F.)
	cQrySC9 := "SELECT SC9.R_E_C_N_O_ C9RECNO, DAK.R_E_C_N_O_ DAKRECNO, DAK.DAK_OK"
	cQrySC9 += " FROM "       + RetSqlName("SC9")+" SC9 "
	cQrySC9 += " INNER JOIN " + RetSqlName("DAK")+" DAK "
	cQrySC9 += "  ON DAK.DAK_FILIAL = '"+xFilial("DAK")+"'"
	cQrySC9 += " AND DAK.DAK_COD   >= '"+MV_PAR03+"'"
	cQrySC9 += " AND DAK.DAK_COD   <= '"+MV_PAR04+"'"
	cQrySC9 += " AND DAK.DAK_CAMINH>= '"+MV_PAR05+"'"
	cQrySC9 += " AND DAK.DAK_CAMINH<= '"+MV_PAR06+"'"
	cQrySC9 += " AND DAK.DAK_COD    = SC9.C9_CARGA"
	cQrySC9 += " AND DAK.DAK_SEQCAR = SC9.C9_SEQCAR"
	cQrySC9 += " AND DAK_FEZNF <> '1' "
	cQrySC9 += " AND DAK.D_E_L_E_T_ = ''"
	If lInverte
		cQrySC9 += " AND DAK.DAK_OK<>'"+cMarca+"'"
	Else
		cQrySC9 += " AND DAK.DAK_OK='"+cMarca+"'"
	EndIf
	cQrySC9 += "WHERE SC9.C9_FILIAL  = '"+xFilial("SC9")+"'"
	cQrySC9 += " AND SC9.C9_DATALIB >= '"+Dtos(MV_PAR07)+"'"
	cQrySC9 += " AND SC9.C9_DATALIB <= '"+Dtos(MV_PAR08)+"'"
	cQrySC9 += " AND SC9.C9_NFISCAL  = ''"
	cQrySC9 += " AND SC9.D_E_L_E_T_  = ''"
    EndIf
cAliasSC9 := GetNextAlias()
cQrySC9   := ChangeQuery(cQrySC9)
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQrySC9 ), cAliasSC9, .F., .T. )
While !(cAliasSC9)->(EOF())
	If cRotFat == "MATA460A"
		If !(((cAliasSC9)->C9_OK <> cMarca .And. lInverte) .Or. ((cAliasSC9)->C9_OK == cMarca .And. !lInverte))
			lMarcado := .F.
		EndIf
	ElseIf cRotFat == "MATA460B"
		DAK->(dbGoTo((cAliasSC9)->DAKRECNO))
		If !((DAK->DAK_OK <> cMarca .And. lInverte) .Or. (DAK->DAK_OK == cMarca .And. !lInverte))
			lMarcado := .F.
		EndIf
	EndIf
	If lMarcado
		SC9->(dbGoTo((cAliasSC9)->C9RECNO))
		SC5->(dbSeek(xFilial()+SC9->C9_PEDIDO))
		SC6->(dbSeek(xFilial()+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		SF4->(dbSeek(xFilial()+SC6->C6_TES))
		SB1->(dbSeek(xFilial()+SC9->C9_PRODUTO))
		SB2->(dbSeek(xFilial()+SC9->C9_PRODUTO+SC6->C6_LOCAL))
		//-- Verificar gravacao dos Lacres e Envelopes Seguranca Amostra-Testemunha
		If cRotFat == "MATA460B"
			If !Empty(DAK->DAK_CAMINH)
				//-- Se existe Compartimentos para este veiculo?
				DHF->(dbSetOrder(1)) //DHF_FILIAL+DHF_CODVEI+DHF_NROCOM
				If DHF->(dbSeek(xFilial("DHF")+DAK->DAK_CAMINH))
					//-- Se existe Compartimento, Lacres e Envelopes Seguranca Amostra-Testemunha informados
					If Empty(SC5->(&(cCmpUsr)))
						dbSelectArea("DAK")
						DAK->(dbGoTo((cAliasSC9)->DAKRECNO))
						RecLock("DAK",.F.)
						If lInverte
							DAK->DAK_OK := cMarca
						Else
							DAK->DAK_OK := ""
						EndIf
						MsUnLock()
						MsgAlert("Verificar se existem Compartimentos alocados e Lacres informados.", "ATENCAO")
						dbSelectarea("SC9")
						(cAliasSC9)->(dbSkip())
						Loop
					EndIf
				EndIf
			EndIf
		EndIf
		If SF4->F4_ESTOQUE == "S"
			SG1->(dbSeek(xFilial()+SC9->C9_PRODUTO))
			DH5->(DbSetOrder(1))
			If DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD)) .And. DH5->DH5_PREQUI =="S"
				nEmpenho := 0//SB2->B2_QATU
				dbSelectarea("SG1")
				SG1->(DbSetOrder(5))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
				SG1->(DbSeek(xFilial()+SC9->C9_PRODUTO+DTOS(SC9->C9_DATALIB),.T.))
				dFim := SG1->G1_FIM
				While !SG1->(EOF()) .And. SC9->C9_PRODUTO == SG1->G1_COD .And. dFim == SG1->G1_FIM
					SB2->(dbSeek(xFilial()+SG1->G1_COMP+SC6->C6_LOCAL))
					nNotas := 0
					nPos   := aScan(AESTOQUE,{ |X| X[1] == SG1->G1_COMP+SC6->C6_LOCAL})
					If nPos <> 0
						nNotas := AESTOQUE[nPos,2]
					EndIf
					If DCLVldBloq(SG1->G1_COMP,SC6->C6_LOCAL) .Or. !ValEstDcl(SG1->G1_COMP,SC6->C6_LOCAL,((SC9->C9_QTDLIB - nEmpenho) * SG1->G1_QUANT) + nNotas,dDataBase,2)
						lRet := .F.
						If cRotFat == "MATA460A"
							dbSelectArea("SC9")
							RecLock("SC9",.F.)
							If lInverte
								SC9->C9_OK := cMarca
							Else
								SC9->C9_OK := ""
							EndIf
							MsUnLock()
						EndIf
					Else
						nPos := aScan(aEstoque,{ |X| X[1] == SG1->G1_COMP+SC6->C6_LOCAL})
						If nPos == 0
							Aadd(aEstoque,{SG1->G1_COMP+SC6->C6_LOCAL,(SC9->C9_QTDLIB * SG1->G1_QUANT)})
						Else
							aEstoque[nPos,2] := aEstoque[nPos,2] + ( SC9->C9_QTDLIB * SG1->G1_QUANT )
						EndIf
					EndIf
					dbSelectarea("SG1")
					dbSkip()
				EndDo
				If cRotFat == "MATA460B"
					If !lRet
						dbSelectArea("DAK")
						DAK->(dbGoTo((cAliasSC9)->DAKRECNO))
						RecLock("DAK",.F.)
						If lInverte
							DAK->DAK_OK := cMarca
						Else
							DAK->DAK_OK := ""
						EndIf
						MsUnLock()
					EndIf
				EndIf
			Else
				nNotas := 0
				nPos   := aScan(aEstoque,{ |X| X[1] == SC6->C6_PRODUTO+SC6->C6_LOCAL})
				If nPos <> 0
					nNotas := aEstoque[nPos,2]
				EndIf
				If DCLVldBloq(SC9->C9_PRODUTO,SC9->C9_LOCAL) .Or. !ValEstDcl(SC9->C9_PRODUTO,SC9->C9_LOCAL,(SC9->C9_QTDLIB+nNotas),dDataBase,2)
					lRet := .F.
					If cRotFat == "MATA460A"
						dbSelectArea("SC9")
						RecLock("SC9",.F.)
						If lInverte
							SC9->C9_OK := cMarca
						Else
							SC9->C9_OK := ""
						EndIf
						MsUnLock()
					ElseIf cRotFat == "MATA460B"
						dbSelectArea("DAK")
						DAK->(dbGoTo((cAliasSC9)->DAKRECNO))
						RecLock("DAK",.F.)
						If lInverte
							DAK->DAK_OK := cMarca
						Else
							DAK->DAK_OK := ""
						EndIf
						MsUnLock()
					EndIf
				Else
					nPos := aScan(aEstoque,{ |X| X[1] == SC6->C6_PRODUTO+SC6->C6_LOCAL})
					If nPos == 0
						Aadd(aEstoque,{SC6->C6_PRODUTO+SC6->C6_LOCAL,SC9->C9_QTDLIB})
					Else
						aEstoque[nPos,2] := aEstoque[nPos,2] + SC9->C9_QTDLIB
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectarea("SC9")
	(cAliasSC9)->(dbSkip())
EndDo
(cAliasSC9)->(dbCloseArea())

RestInter()//Recupera as variáveis públicas

SC6->(RestArea(_aAreaSC6))
SB1->(RestArea(_aAreaSB1))
SF4->(RestArea(_aAreaSF4))
SB2->(RestArea(_aAreaSB2))
SG1->(RestArea(_aAreaSG1))
DH5->(RestArea(aAreaDH5))
RestArea(_aArea)

Return lRet