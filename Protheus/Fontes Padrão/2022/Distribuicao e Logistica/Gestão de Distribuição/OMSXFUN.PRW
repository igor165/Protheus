#INCLUDE "PROTHEUS.CH" 
#INCLUDE "OMSXFUN.CH"

Static nTipoOper  := OsVlEntCom()
Static aNfsRatPes := {}

//--------------------------------------------------------------------
/*/{Protheus.doc} OsAvalDAI
Rotina de gravacao de itens do arquivo DAI

Esta rotina tem como objetivo gravar os dados do arquivo DAI e DAK,
 partindo do SC9 para inclusao ou do SD2 para exclusao de notas 

@param  cAlias    Alias da origem do SC9 
@param  nEvento   1 - Inclui no DAI
				  2 - Estorna DAI e atualiza DAK (SC9)
				  3 - Estorna DAI e atualiza DAK (SD2)
				  4 - Exclui cabecalho da carga
@param  aRotas    Array contendo os dados da roteirizacao
@param  lDelDAK   Flag para exclusão da tabela DAK
@param  aCargaAnt Array contendo dados da carga anterior
@param  cFilCar   Filial da Carga
@param  oMdl      Model relacionado a função MaEnvEAI

@return Null

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsAvalDAI(cAlias,nEvento,aRotas,lDelDAK,aCargaAnt,cFilCar,oMdl)
Static cFilCar  := xFilial("DAK")
Local aArea     := GetArea()
Local aAreaDAK  := DAK->(GetArea())
Local aAreaDAI  := DAI->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local nPeso     := 0
Local nPesoProd := 0
Local nCapVol   := 0
Local nCapArm   := 0
Local cCarga    := SC9->C9_CARGA
Local cSeqCar   := SC9->C9_SEQCAR
Local cPedido   := SC9->C9_PEDIDO
Local cItem     := SC9->C9_ITEM
Local cSequen   := SC9->C9_SEQUEN
Local cFilPV    := ""
Local cAliasDAI := "DAI"
Local cAliasDAK := "DAK"
Local lAlocVei  := SuperGetMv("MV_ALOCVEI",.F.,.T.)
Local nX        := 0
Local nRecSF2   := 0
Local aRecDAN   := {}
Local cSeekDAN  := ""
Local aRecSDB   := {}
Local cSeekSDB  := ""
Local cCliente  := ""
Local cLoja     := ""
Local cSeek     := ""
Local nValor    := 0
Local cIdent    := ""
Local lRet      := .T.
Local lOSAVDAI  := ExistBlock("OSAVDAI")
Local lOMSXEST  := ExistBlock("OMSXEST")
Local lDclNew   := SuperGetMv("MV_DCLNEW",.F.,.F.)
Local lPENExcDAK := .F.

Local cQuery   := ""
Local aStruDAI := DAI->(dbStruct())
Local lEstTPR := .F.
Local cRoteiri := ""

DEFAULT cAlias    := "DAI"
DEFAULT aRotas    := Array(15)
DEFAULT lDelDAK   := .T.
DEFAULT aCargaAnt := {}
DEFAULT cFilCar   := xFilial("DAK")
Default oMdl      := Nil

//-- Ponto de entrada antes da gravacao de itens do arquivo DAI
If lOSAVDAI
	lRet := ExecBlock("OSAVDAI",.F.,.F.,{nEvento})
	If  Valtype(lRet) != "L"
		lRet := .T.
	EndIf
EndIf

If lRet
	Do Case
		Case nEvento == 1

			cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SC9"))

			DbSelectArea("SB1")
			DbSetOrder(1)
			If	MsSeek(OsFilial("SB1",cFilPV)+SC9->C9_PRODUTO)
				//-- Calculo peso do item do pedido
				nPesoProd := OsPesoProd(SC9->C9_PRODUTO,cFilPv)
				nPeso     := (nPesoProd * SC9->C9_QTDLIB)
				//-- Calcula capacidade volumetrica
				nCapArm   := OsPrCapArm(SB1->B1_COD,cFilPv)
				nCapVol   := (nCapArm   * SC9->C9_QTDLIB)
				//-- Acumula valores do DAI correspondente ao SC9
				RecLock("DAI")
					DAI->DAI_PESO   += nPeso
					DAI->DAI_CAPVOL += nCapVol
				MsUnlock()
				//-- Inclui Novo valor no DAK
				OsAvalDAK("DAK",1,aRotas,cFilCar)
			EndIf
		Case nEvento == 2

			//-- Array com os dados da roteirizacao
			AAdd(aRotas, DAI->DAI_ROTEIR)	//   [01] Codigo da Rota
			AAdd(aRotas, DAI->DAI_PERCUR)	//   [02] Codigo da Zona
			AAdd(aRotas, DAI->DAI_ROTA)		//   [03] Codigo do Setor
			AAdd(aRotas, Nil)				//   [04] Motorista
			AAdd(aRotas, Nil)				//   [05] Caminhao
			AAdd(aRotas, Nil)				//   [06] Ajudante 1
			AAdd(aRotas, Nil)				//   [07] Ajudante 2
			AAdd(aRotas, Nil)				//   [08] Ajudante 3
			AAdd(aRotas, DAI->DAI_CHEGAD)	//   [09] Hora chegada
			AAdd(aRotas, DAI->DAI_TMSERV)	//   [10] Time Service
			AAdd(aRotas, DAI->DAI_DTCHEG)	//   [11] Data chegada
			AAdd(aRotas, DAI->DAI_DTSAID)	//   [12] Data saida
			AAdd(aRotas, Nil)				//   [13] Hora de inicio de entrega
			AAdd(aRotas, Nil)				//   [14] Valor do Frete (DAI_VALFRE)*
			AAdd(aRotas, Nil)				//   [15] Frete Autonomo (DAI_FREAUT)*

			cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SC9"))

			DbSelectArea("SB1")
			DbSetOrder(1)
			If	MsSeek(OsFilial("SB1",cFilPV)+SC9->C9_PRODUTO)
				//-- Calculo peso do item do pedido
				nPesoProd := OsPesoProd(SC9->C9_PRODUTO,cFilPv)
				nPeso     := (nPesoProd * SC9->C9_QTDLIB)
				//-- Calcula capacidade volumetrica
				nCapArm   := OsPrCapArm(SC9->C9_PRODUTO,cFilPv)
				nCapVol   := nCapArm * SC9->C9_QTDLIB
				//-- Retira valores do DAI correspondente ao SC9 excluido
				RecLock("DAI",.F.)
					DAI->DAI_CAPVOL -= nCapVol
					DAI->DAI_PESO   -= nPeso
				MsUnlock()
				//-- Estorna o acumulado do DAK
				OsAvalDAK("DAK",2,,cFilCar)

				/*PE que ignora a exclusão da DAK (montagem de carga) no estorno de liberação de crédito/estoque
				  Essa função é chamada também na liberação de crédito (é feito o estorno e nova inclusão) e
				  também no estorno da montagem de carga, a execução do PE só ocorrerá quando for oriundo do
				  estoques (MATA440/MATA450 etc)*/
				lPENExcDAK := .F.
				If IsInCallStack('a460Estorna')
					If ExistBlock('OMSNEDAK')
						lPENExcDAK := ExecBlock("OMSNEDAK",.F.,.F.,{DAI->DAI_FILIAL, DAI->DAI_COD, DAI->DAI_SEQCAR, DAI->DAI_SEQUEN, SC9->C9_QTDLIB})
					EndIf
				EndIf

				//-- Estorna o SC9 da carga atual				
				RecLock("SC9",.F.)
					SC9->C9_CARGA   := ""
					SC9->C9_SEQCAR  := ""
					SC9->C9_SEQENT  := ""
				MsUnLock()

				If !OsHasSc9(cCarga,cSeqCar,cFilPV,SC9->C9_PEDIDO,.T.)

					RecLock("DAI",.F.)
						dbDelete()
					Msunlock()

					//-- Exclui unitizacao pois a mesma nao corresponde mais a original
					OsDelUnt(cCarga,cSeqCar,cPedido,cItem,cSequen)

					DbSelectArea("DAK")
					DbSetOrder(1)
					If	MsSeek(cFilCar+cCarga+cSeqCar)
						RecLock("DAK")
							DAK->DAK_PTOENT := OsPtoEntr(cCarga,cSeqCar,cFilCar)
						MsUnlock()
					EndIf

					//-- PE apos o estorno do item da Carga (DAK)
					If lOMSXEST
						ExecBlock("OMSXEST",.F.,.F.,{"DAI",cCarga,cSeqCar})
					EndIf

					If !lPENExcDAK
						//-- Deleta DAK caso nao exista mais DAI e DAH
						DbSelectArea("DAI")
						DbSetOrder(1)
						If !MsSeek(cFilCar+cCarga+cSeqCar)

							DbSelectArea("DAH")
							DbSetOrder(1)
							If !MsSeek(cFilCar+cCarga+cSeqCar)

								//-- Retira a reserva do veiculo
								If	lAlocVei
									OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_CAMINH,2)
									If DAK->(FieldPos("DAK_VEIC2")) > 0
										OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_VEIC2,2)
										OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_VEIC3,2)
									EndIf
								EndIf

								If	lDelDAK
									DbSelectArea("DAK")
									DbSetOrder(1)
									If	MsSeek(cFilCar+cCarga+cSeqCar)
										DbSelectArea("SF2")
										DbSetOrder(5)
										cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SF2"))
										If	MsSeek(OsFilial("SF2",cFilPV)+cCarga+cSeqCar)
											While SF2->(!Eof()) .And. SF2->F2_FILIAL+SF2->F2_CARGA+SF2->F2_SEQCAR == ;
													OsFilial("SF2",cFilPV)+cCarga+cSeqCar
												DbSelectArea("SF2")
												dbSkip()
												nRecSF2 := SF2->(Recno())
												dbSkip(-1)

												RecLock("SF2")
												SF2->F2_CARGA  := ""
												SF2->F2_SEQCAR := ""
												MsUnLock()
												SF2->(FkCommit())

												DbSelectArea("SF2")
												dbGoTo(nRecSF2)
											EndDo
										EndIf

										If IsInCallStack('Ma461Estor') .and. FindFunction("MaEnvEAI")
											oMdl:= MaEnvEAI(,,5,"OMSA200",,,.F.,.T.)
										EndIf
										
										Reclock("DAK")
										dbDelete()
										MsUnlock()

										If IsInCallStack('Ma461Estor') .and. FindFunction("MaEnvEAI")
											MaEnvEAI(,,5,"OMSA200",,,.T.,.F.,oMdl)
										EndIf

										//-- PE apos o estorno da Carga (DAK)
										If lOMSXEST
											ExecBlock("OMSXEST",.F.,.F.,{"DAK",cCarga,cSeqCar})
										EndIf
									EndIf
								EndIf
							EndIf
						Else
							//-- se estornou DAI atualiza DAK_FEZNF
							OsAvalDAK("SC9",7,,cFilCar)
						EndIf
					EndIf
					//-- Fim PE para ignorar o processo de exclusão da DAK
				Else
					//-- se estornou item do pedido atualiza DAK_FEZNF
					OsAvalDAK("SC9",7,,cFilCar)
				EndIf
			EndIf

		Case nEvento == 3

			cFilPv  := IIf(nTipoOper<>1,SD2->D2_FILIAL,xFilial("SD2"))
			cFilCar := OsFilOpe(SF2->F2_CARGA,SF2->F2_SEQCAR,SF2->F2_SEQENT,SF2->F2_CLIENTE,SF2->F2_LOJA,SD2->D2_PEDIDO)

			nCapArm := OsPrCapArm(SD2->D2_COD,cFilPv)
			DbSelectArea("SB1")
			DbSetOrder(1)
			If	MsSeek(OsFilial("SB1",cFilPV)+SD2->D2_COD)
				//-- Verifica se existe algum item do pedido na carga, caso nao exista deleta o DAI
				cAliasDAI := "QRYDAI"
				cQuery := "SELECT DAI.DAI_FILIAL, DAI.DAI_ROTEIR, DAI.DAI_PERCUR, DAI.DAI_ROTA, DAI.DAI_CHEGAD, "
				cQuery += "DAI.DAI_TMSERV, DAI.DAI_DTCHEG, DAI.DAI_DTSAID, DAI.DAI_VALFRE, DAI.DAI_FREAUT, "
				cQuery += "DAI.DAI_CLIENT, DAI.DAI_LOJA, DAI.DAI_PEDIDO, DAI.DAI_COD, DAI.DAI_SEQCAR, "
				cQuery += "DAK.DAK_CAMINH, DAK.DAK_MOTORI, DAK.DAK_AJUDA1, DAK.DAK_AJUDA2, DAK.DAK_AJUDA3, " 
				cQuery += "DAK.DAK_HRSTAR, DAI.R_E_C_N_O_ RECDAI, DAK.R_E_C_N_O_ RECDAK "
				If DAI->( ColumnPos("DAI_FILPV" ) ) > 0
					cQuery += ", DAI.DAI_FILPV "
				EndIf

				cQuery += "FROM " + RetSqlName("DAI")+ " DAI "
				cQuery += "INNER JOIN " + RetSqlName("DAK")+ " DAK "
				cQuery += "ON DAK_FILIAL = '" + OsFilial("DAK",cFilCar) + "' "
				cQuery += "AND DAK_COD    = DAI.DAI_COD "
				cQuery += "AND DAK_SEQCAR = DAI_SEQCAR "
				cQuery += "AND DAK.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE DAI_FILIAL = '"+OsFilial("DAI",cFilCar)+"' "
				cQuery += "AND DAI_CLIENT = '"+SD2->D2_CLIENTE+"' "
				cQuery += "AND DAI_LOJA   = '"+SD2->D2_LOJA   +"' "
				cQuery += "AND DAI_PEDIDO = '"+SD2->D2_PEDIDO +"' "
				cQuery += "AND DAI_COD    = '"+SF2->F2_CARGA  +"' "
				cQuery += "AND DAI_SEQCAR = '"+SF2->F2_SEQCAR +"' "
				cQuery += "AND DAI.D_E_L_E_T_ = ' ' "				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAI,.T.,.T.)
				For nX := 1 To Len(aStruDAI)
					If aStruDAI[nX][2]!="C"
						TcSetField(cAliasDAI,aStruDAI[nX][1],aStruDAI[nX][2],aStruDAI[nX][3],aStruDAI[nX][4])
					EndIf
				Next nX

				AAdd(aRotas, (cAliasDAI)->DAI_ROTEIR)
				AAdd(aRotas, (cAliasDAI)->DAI_PERCUR)
				AAdd(aRotas, (cAliasDAI)->DAI_ROTA  )
				AAdd(aRotas, (cAliasDAK)->DAK_CAMINH)
				AAdd(aRotas, (cAliasDAK)->DAK_MOTORI)
				AAdd(aRotas, (cAliasDAK)->DAK_AJUDA1)
				AAdd(aRotas, (cAliasDAK)->DAK_AJUDA2)
				AAdd(aRotas, (cAliasDAK)->DAK_AJUDA3)
				AAdd(aRotas, (cAliasDAI)->DAI_CHEGAD)
				AAdd(aRotas, (cAliasDAI)->DAI_TMSERV)
				AAdd(aRotas, (cAliasDAI)->DAI_DTCHEG)
				AAdd(aRotas, (cAliasDAI)->DAI_DTSAID)
				AAdd(aRotas, (cAliasDAK)->DAK_HRSTAR)
				AAdd(aRotas, (cAliasDAI)->DAI_VALFRE)
				AAdd(aRotas, (cAliasDAI)->DAI_FREAUT)

				While (cAliasDAI)->(!Eof()) .And. OsFilial("DAI",cFilCar) == (cAliasDAI)->DAI_FILIAL .And.;
					SD2->D2_CLIENTE == (cAliasDAI)->DAI_CLIENT .And.;
					SD2->D2_LOJA    == (cAliasDAI)->DAI_LOJA   .And.;
					SD2->D2_PEDIDO  == (cAliasDAI)->DAI_PEDIDO .And.;
					SF2->F2_CARGA   == (cAliasDAI)->DAI_COD    .And.;
					SF2->F2_SEQCAR  == (cAliasDAI)->DAI_SEQCAR

					If	nTipoOper == 1 .Or. (cAliasDAI)->DAI_FILPV == cFilPv
						//-- Calculo peso do item do pedido
						nPesoProd := OsPesoProd(SB1->B1_COD,cFilPv)
						nPeso     := (nPesoProd * SD2->D2_QUANT)
						//-- Calcula capacidade volumetrica
						nCapVol := nCapArm * SD2->D2_QUANT
						DAI->(MsGoto((cAliasDAI)->RECDAI))
						DAK->(MsGoto((cAliasDAI)->RECDAK))
						//-- Retira valores do DAI correspondente ao SC9 excluido
						RecLock("DAI",.F.)
							DAI->DAI_CAPVOL -= nCapVol
							DAI->DAI_PESO   -= nPeso
						MsUnlock()
						//-- Exclui o acumulado do DAK
						OsAvalDAK("DAK",8,aRotas,cFilcar)
						If !OsHasSc9(SF2->F2_CARGA,SF2->F2_SEQCAR,cFilPv,SD2->D2_PEDIDO,.T.)
							RecLock("DAI",.F.)
							dbDelete()
							Msunlock()

							//-- Exclui unitizacao pois a mesma nao corresponde mais a original
							OsDelUnt(SF2->F2_CARGA,SF2->F2_SEQCAR,,,,cFilCar)

							RecLock("DAK")
								DAK->DAK_PTOENT := OsPtoEntr(cCarga,cSeqCar,cFilCar)
							MsUnlock()

							//-- Template DCL-EST - Estorno de Cargas com Compartimentos/Lacres associados.
							If lDclNew
								DCLOMSXES(cCarga,cSeqCar,SD2->D2_PEDIDO)
							ElseIf ExistTemplate("OMSXEST")
								ExecTemplate("OMSXEST",.F.,.F.,{"DAI",cCarga,cSeqCar,SD2->D2_PEDIDO,SD2->D2_COD})
							EndIf
							//-- PE apos o estorno do item da Carga (DAK) na exclusao da Fatura
							If lOMSXEST
								ExecBlock("OMSXEST",.F.,.F.,{"DAI",cCarga,cSeqCar})
							EndIf
						EndIf
					EndIf

					DbSelectArea(cAliasDAI)
					dbSkip()

				EndDo
				//-- Deleta DAK caso nao exista mais DAI
				If	lDelDAK
					DbSelectArea("DAI")
					DbSetOrder(1)
					If !MsSeek(OsFilial("DAI",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR)

						SF2->(FkCommit())

						//-- Estorna SDB com Carga referente a esta movimentacao
						aRecSDB := {}
						DbSelectArea('SDB')
						DbSetOrder(14) //-- DB_FILIAL+DB_CARGA+DB_SEQCAR+DB_SERVIC+DB_TAREFA+DB_ATIVID
						If	MsSeek(cSeekSDB:=xFilial('SDB')+SF2->F2_CARGA+SF2->F2_SEQCAR, .F.)
							Do While !Eof() .And. cSeekSDB == DB_FILIAL+DB_CARGA+DB_SEQCAR
								AAdd(aRecSDB, Recno())
								dbSkip()
							EndDo
						EndIf
						For nX := 1 to Len(aRecSDB)
							dbGoTo(aRecSDB[nX])
							RecLock('SDB', .F.)
							Replace DB_CARGA  With CriaVar('DB_CARGA' , .F.)
							Replace DB_SEQCAR With CriaVar('DB_SEQCAR', .F.)
							Replace DB_UNITIZ With CriaVar('DB_UNITIZ', .F.)
							MsUnlock()
						Next nX

						//-- Deleta DAN com Carga referente a esta movimentacao
						aRecDAN := {}
						DbSelectArea('DAN')
						DbSetOrder(2) //-- DAN_FILIAL+DAN_CODCAR+DAN_SEQCAR+DAN_CODVEI
						If	MsSeek(cSeekDAN:=OsFilial("DAN",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR, .F.)
							Do While !Eof() .And. cSeekDAN == DAN_FILIAL+DAN_CODCAR+DAN_SEQCAR
								AAdd(aRecDAN, Recno())
								dbSkip()
							EndDo
						EndIf
						For nX := 1 to Len(aRecDAN)
							dbGoTo(aRecDAN[nX])
							RecLock('DAN', .F.)
							dbDelete()
							MsUnlock()
						Next nX

						DbSelectArea("DAK")
						DbSetOrder(1)
						If	MsSeek(OsFilial("DAK",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR)
							Reclock("DAK")
							dbDelete()
							MsUnlock()

							If FindFunction("MaEnvEAI")
								oMdl:= MaEnvEAI(,,5,"OMSA200",,,.F.)
							EndIf
							//-- PE apos o estorno da Carga (DAK) na exclusao da Fatura
							If lOMSXEST
								ExecBlock("OMSXEST",.F.,.F.,{"DAK",cCarga,cSeqCar})
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

		Case nEvento == 4

			DbSelectArea("DAI")
			DbSetOrder(1)
			If !MsSeek(OsFilial("DAI",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR)

				SF2->(FkCommit())

				//-- Estorna SDB com Carga referente a esta movimentacao
				aRecSDB := {}
				DbSelectArea("SDB")
				DbSetOrder(14) //-- DB_FILIAL+DB_CARGA+DB_SEQCAR+DB_SERVIC+DB_TAREFA+DB_ATIVID
				If MsSeek(cSeekSDB:=xFilial("SDB")+SF2->F2_CARGA+SF2->F2_SEQCAR, .F.)
					Do While !Eof() .And. cSeekSDB == DB_FILIAL+DB_CARGA+DB_SEQCAR
						AAdd(aRecSDB, Recno())
						dbSkip()
					EndDo
				EndIf
				For nX := 1 to Len(aRecSDB)
					dbGoTo(aRecSDB[nX])
					RecLock('SDB', .F.)
						Replace DB_CARGA  With CriaVar('DB_CARGA' , .F.)
						Replace DB_SEQCAR With CriaVar('DB_SEQCAR', .F.)
						Replace DB_UNITIZ With CriaVar('DB_UNITIZ', .F.)
					MsUnlock()
				Next nX

				//-- Deleta DAN com Carga referente a esta movimentacao
				aRecDAN := {}
				DbSelectArea('DAN')
				DbSetOrder(2) //-- DAN_FILIAL+DAN_CODCAR+DAN_SEQCAR+DAN_CODVEI
				If MsSeek(cSeekDAN:=OsFilial("DAN",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR, .F.)
					Do While !Eof() .And. cSeekDAN == DAN_FILIAL+DAN_CODCAR+DAN_SEQCAR
						AAdd(aRecDAN, Recno())
						dbSkip()
					EndDo
				EndIf
				For nX := 1 to Len(aRecDAN)
					dbGoTo(aRecDAN[nX])
					RecLock('DAN', .F.)
					dbDelete()
					MsUnlock()
				Next nX

				DbSelectArea("DAK")
				DbSetOrder(1)
				If MsSeek(OsFilial("DAK",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR)

					//--Caso integração GFE x Protheus ativa
					//--Exclui o romaneio
					OMSA200IPG(5,,,.T.)

					Reclock("DAK")
					dbDelete()
					MsUnlock()

					If TableInDic("DK0", .F.)
						DK0->(DbSetOrder(2))
						If DK0->(DbSeek(OsFilial("DK0",cFilCar)+SF2->F2_CARGA))
							RecLock("DK0",.F.)
								DK0->DK0_CARGER = '2'
								DK0->DK0_CARGA = ''
							DK0->(MsUnlock())
						EndIF
					EndIf

					If ColumnPos("DAK_INTTPR") > 0 .And. X3USO(GetSX3Cache("DAK_INTTPR", "X3_USADO"))
						If SuperGetMV("MV_ROTAINT",.F.,.F.) .And. TableInDic("DMS", .F.) .And. FindFunction('OMSTPRDMSC')
							DMS->(DbSetOrder(3))
							If DMS->(DbSeek(FwXFilial("DMS")+"DAK"+OsFilial("DAK",cFilCar)+SF2->F2_CARGA))
								cRoteiri := OMSROTEIRI()
								If cRoteiri == '2'
									OMSTPRDMSC(OsFilial("DAK",cFilCar), SF2->F2_CARGA)
									lEstTPR := .T.  //Estornou TPR Neolog
								EndIf
							EndIf
						EndIf
					EndIf
				
					If lEstTPR
						MsgAlert(STR0047 + SF2->F2_CARGA + STR0048, "OMSXFUN02" ) //"Atenção: A carga " + SF2->F2_CARGA + " e a roteirização TPR relacionada foram excluídas. Verifique a situação dos pedidos vinculados ao documento excluído."
					Else
						MsgAlert(STR0046, "OMSXFUN01" ) //""Atenção: Montagem de Carga foi excluída. Verificar a situação dos pedidos vinculados ao documento excluído."
					EndIf

					If FindFunction("MaEnvEAI")
						oMdl:= MaEnvEAI(,,5,"OMSA200",,,.F.)
					EndIf

					//-- PE apos o estorno da Carga (DAK) na exclusao da Fatura
					If lOMSXEST
						ExecBlock("OMSXEST",.F.,.F.,{"DAK",SF2->F2_CARGA,SF2->F2_SEQCAR})
					EndIf
				EndIf
			EndIf

		Case nEvento == 5

			If Len(aCargaAnt) > 0

				//--Pesquisa o item anterior, e tira o vinculo com
				//--o pedido que nao estara mais naquela carga, uma nota
				//--pode estar em varios DAI's, por isso o Loop
				DAI->(DbSetOrder(1))
				DAI->(dbGoTo(aCargaAnt[7]))
				If DAI->(FieldPos("DAI_FILPV")) > 0
					cFilPv := DAI->DAI_FILPV
				EndIf
				cCliente := DAI->DAI_CLIENT
				cLoja    := DAI->DAI_LOJA
				cPedido  := DAI->DAI_PEDIDO
				nPeso    := DAI->DAI_PESO
				nCapVol  := DAI->DAI_CAPVOL
				RecLock("DAI",.F.)
				DAI->DAI_NFISCA := ""
				DAI->DAI_SERIE  := ""
				DAI->(MsUnlock())

				//--Calcula o Valor atraves da Nota Fiscal
				SD2->(DbSetOrder(3))
				If SD2->(DbSeek(cSeek := xFilial("SD2")+aCargaAnt[3]+aCargaAnt[4]))
					While SD2->(!Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == cSeek)
						nValor += (SD2->D2_PRCVEN * SD2->D2_QUANT)
						SD2->(dbSkip())
					EndDo
				EndIf

				//Criar o novo DAI, para a nova carga
				RecLock("DAI",.T.)
				DAI->DAI_FILIAL  := xFilial("DAI")
				DAI->DAI_COD     := aCargaAnt[5]
				DAI->DAI_SEQCAR  := aCargaAnt[6]
				DAI->DAI_SEQUEN  := OsSeqEnt(aCargaAnt[5],aCargaAnt[6],cPedido)
				DAI->DAI_PEDIDO  := cPedido
				If DAI->(FieldPos("DAI_FILPV")) > 0
					DAI->DAI_FILPV := cFilPv
				EndIf
				DAI->DAI_NFISCA  := aCargaAnt[3] //Nota Anterior no Novo DAI
				DAI->DAI_SERIE   := aCargaAnt[4] //Serie Anterior no Novo DAI
				DAI->DAI_CLIENT  := cCliente
				DAI->DAI_LOJA    := cLoja
				DAI->DAI_ROTEIR  := aRotas[1]
				DAI->DAI_PERCUR  := aRotas[2]
				DAI->DAI_ROTA    := aRotas[3]
				DAI->DAI_SEQROT  := Space(6)
				DAI->DAI_DATA    := dDataBase
				DAI->DAI_HORA    := Time()
				DAI->DAI_CARORI  := "CARGA"
				DAI->DAI_PESO    := nPeso
				DAI->DAI_CAPVOL  := nCapVol
				DAI->DAI_CHEGAD  := aRotas[9]
				DAI->DAI_TMSERV  := aRotas[10]
				DAI->DAI_DTCHEG  := aRotas[11]
				DAI->DAI_DTSAID  := aRotas[12]
				DAI->(Msunlock())

				//-- Acumula a carga no DAK com peso e volume
				DAK->(DbSetOrder(1))
				If DAK->(DbSeek(xFilial("DAK")+aCargaAnt[5]+aCargaAnt[6]))
					RecLock("DAK",.F.)
					cIdent          := DAK->DAK_IDENT
					DAK->DAK_PESO   += nPeso
					DAK->DAK_CAPVOL += nCapVol
					DAK->DAK_VALOR  += nValor
					DAK->DAK_PTOENT := OsPtoEntr(aCargaAnt[5],aCargaAnt[6])
					DAK->DAK_FEZNF  := "1" //-- Gravar como Faturado
					DAK->(MsUnlock())
				EndIf

				//-- Grava o codigo da nova carga na nota fiscal
				SF2->(DbSetOrder(1))
				If SF2->(DbSeek(xFilial("SF2")+aCargaAnt[3]+aCargaAnt[4]))
					RecLock("SF2",.F.)
					SF2->F2_CARGA  := aCargaAnt[5]
					SF2->F2_SEQCAR := aCargaAnt[6]
					SF2->(MsUnlock())
				EndIf
			EndIf
		Case nEvento == 6
			cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SC9"))
			If !(SC9->C9_PRODUTO == SB1->B1_COD)
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(MsSeek(OsFilial("SB1",cFilPV)+SC9->C9_PRODUTO))
			EndIf
			
			//-- Calculo peso do item do pedido
			nPesoProd := OsPesoProd(SC9->C9_PRODUTO,cFilPv)
			nPeso     := (nPesoProd * SC9->C9_QTDLIB)
			//-- Calcula capacidade volumetrica
			nCapArm   := OsPrCapArm(SB1->B1_COD,cFilPv)
			nCapVol   := (nCapArm   * SC9->C9_QTDLIB)
			//-- Acumula valores do DAI correspondente ao SC9
			RecLock("DAI",.F.)
				DAI->DAI_PESO   += nPeso
				DAI->DAI_CAPVOL += nCapVol
			DAI->(MsUnlock())
	EndCase
EndIf

DbSelectArea(cAliasDAI)
dbCloseArea()
DbSelectArea("DAI")

RestArea( aAreaDAK )
RestArea( aAreaDAI )
RestArea( aAreaSC9 )
RestArea( aArea    )

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} OsAvalDAK
Rotina de analise do DAK

Esta rotina tem como objetivo gravar os dados do arquivo DAI e DAK,
partindo do SC9 para inclusao ou do SD2 para exclusao de notas 

@param  cAlias    Alias da origem do SC9 
@param  nEvento   1 - Inclui no DAK
 				  2 - Exclui no DAK                                     
				  3 - Flag de Unitizacao                                
				  4 - Estorna Unitizacao                                
				  5 - Flag de Retorno de Carga                          
				  6 - Estorna Retorno de Carga                          
				  7 - Flag de Faturamento da Carga                      
				  8 - Exclusao da nota fiscal de saida                  
				  9 - Flag de Prestacao de Contas Conferido             
				 10 - Flag de Prestacao de Contas Conferido e finalizado
				 11 - Flag de Bloqueio de carga                         
				 12 - Flag de estorno do bloqueio de carga              
				 13 - Estorno da baixa do titulo no Financeiro          
				 14 - Baixa do titulo no Financeiro                     
@param  aRotas    Array contendo os dados da roteirizacao
@param  cFilCar   Filial da Carga
@param  lRemito   Flag relacionado a Remito para o país ARGENTINA

@return Null

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsAvalDAK(cAlias,nEvento,aRotas,cFilCar,lRemito)
Local aArea     := GetArea()
Local aAreaDAK  := DAK->(GetArea())
Local aAreaDAI  := DAI->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aAreaSF2  := SF2->(GetArea())
Local aRecDBN   := {}
Local aRecDAK   := {}
Local aRecDCF   := {}
Local cCodUni   := ""
Local cAliasSC9 := "SC9"
Local cAliasDBN := "DBN"
Local cAliasSE1 := "SE1"
Local cFilPv    := ""
Local cPrefixo  := ""
Local cFezNF    := ""
Local lTitAb    := .F.
Local lAlocVei  := SuperGetMv("MV_ALOCVEI",.F.,.T.)
Local lIntDL    := IntDL()
Local nCapArm   := 0
Local nPeso     := 0
Local nPesoProd := 0
Local nCapVol   := 0
Local nVlEntcom := 0
Local nX        := 0
Local cIdDCF    := ""
Local cDuPref   := SuperGetMv("MV_1DUPREF",.F.,"")

#IFDEF TOP
	Local cQuery    := ""
#ENDIF

DEFAULT cAlias  := "DAK"
DEFAULT aRotas  := Array(15)
DEFAULT cFilCar := xFilial("DAK")
DEFAULT lRemito	:= .F.

nVlEntcom := OsVlEntCom(cFilCar)
cFilPv    := IIf(nVlEntCom<>1,DAI->DAI_FILPV,xFilial("SC9"))
//-- Calculo peso do item do pedido
nPesoProd := OsPesoProd(SC9->C9_PRODUTO,cFilPv)
nPeso     := (nPesoProd * SC9->C9_QTDLIB)
//-- Calcula capacidade volumetrica
nCapArm   := OsPrCapArm(SB1->B1_COD,cFilPv)
nCapVol   := (nCapArm * SC9->C9_QTDLIB)

Do Case
	//-- Inclusao ou aucumulador do DAK
	Case nEvento == 1
		//-- Verifica se existe DAK para a carga a ser criada
		DbSelectArea("DAK")
		DbSetOrder(1)
		If !MsSeek(OsFilial("DAK",cFilCar)+SC9->C9_CARGA+SC9->C9_SEQCAR)
			//-- Gera o Arquivo DAK
			DbSelectArea("DAK")
			RecLock("DAK",.T.)
				DAK->DAK_COD    := SC9->C9_CARGA
				DAK->DAK_SEQCAR := SC9->C9_SEQCAR
				DAK->DAK_FILIAL := OsFilial("DAK",cFilCar)
				DAK->DAK_CAMINH := aRotas[4]
				DAK->DAK_MOTORI := aRotas[5]
				DAK->DAK_AJUDA1 := aRotas[6]
				DAK->DAK_AJUDA2 := aRotas[7]
				DAK->DAK_AJUDA3 := aRotas[8]
				DAK->DAK_DATA   := dDatabase
				DAK->DAK_HORA   := Time()
				DAK->DAK_PESO   := 0
				DAK->DAK_CAPVOL := 0
				DAK->DAK_PTOENT := 0
				DAK->DAK_VALOR  := 0
				DAK->DAK_JUNTOU := "MANUAL"
				DAK->DAK_FLGUNI := "2"
				DAK->DAK_HRSTAR := aRotas[13]
				DAK->DAK_FEZNF  := "2"
				DAK->DAK_ACECAR := "2"
				DAK->DAK_ACEFIN := "2"
				DAK->DAK_ACEVAS := "2"
			MsUnlock()

			If lAlocVei .And. !Empty(aRotas[4])
				OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_CAMINH,1)
			EndIf
		Else
			//Verifica se carga possuí itens faturados
			cFezNF := Iif(OmsCarFat(DAK->DAK_FILIAL,DAK->DAK_COD,DAK->DAK_SEQCAR,nVlEntcom),"1","2")
			RecLock("DAK",.F.)
			If ('TMSA360' $ AllTrim(FunName()))
				DAK->DAK_FEZNF  := "1" //Se vier do Registro de Ocorrencia grava faturado
			Else	
				DAK->DAK_FEZNF  := cFezNF
			EndIf
			DAK->DAK_ACECAR := "2"
			DAK->DAK_ACEFIN := "2"
			DAK->DAK_ACEVAS := "2"
			MsUnlock()
		EndIf

		//-- Acumula a carga no DAK com peso e volume
		RecLock("DAK",.F.)
		DAK->DAK_PESO   += nPeso
		DAK->DAK_CAPVOL += nCapVol
		DAK->DAK_VALOR  += A410Arred(( SC9->C9_QTDLIB * SC9->C9_PRCVEN ),"DAK_VALOR")
		DAK->DAK_PTOENT := OsPtoEntr(DAK->DAK_COD,DAK->DAK_SEQCAR)
		MsUnlock()

	//-- Exclusao de DAI ou estorno do DAK
	Case nEvento == 2
		//-- Verifica se ainda existe um DAI, caso nao exista deleta o DAK
		DbSelectArea("DAK")
		DbSetOrder(1)
		If MsSeek(OsFilial("DAK",cFilCar)+SC9->C9_CARGA+SC9->C9_SEQCAR)
			//-- Retira valores do DAK correspondente ao SC9 excluido
			RecLock("DAK")
				DAK->DAK_PESO   -= Iif(DAK->DAK_PESO > 0,nPeso, 0 )
				DAK->DAK_CAPVOL -= Iif(DAK->DAK_CAPVOL > 0,nCapVol,0 )
				DAK->DAK_VALOR  -= A410Arred(Iif(DAK->DAK_VALOR > 0,SC9->C9_QTDLIB * SC9->C9_PRCVEN, 0 ),"DAK_VALOR")
				DAK->DAK_PTOENT := OsPtoEntr(DAK->DAK_COD,DAK->DAK_SEQCAR,cFilCar)
			MsUnlock()
		EndIf

	//-- Flag de unitizacao no DAK
	Case nEvento == 3
		DbSelectArea("DAK")
		RecLock("DAK",.F.)
			DAK->DAK_FLGUNI := "1"
		MsUnlock()

	Case nEvento == 4
		aRecDBN   := {}
		aRecDAK   := {}

		cCodUni := DBN->DBN_CODUNI
		
		//-- Exclui movimentacao de unitizacao da carga

		DbSelectArea("DBN")
		DbSetOrder(1)

		cAliasDBN := "QRYDBN"

		cQuery    := "SELECT DBN.DBN_FILIAL, DBN.DBN_CODUNI, DBN.DBN_CARGA, DBN.DBN_SEQCAR, dBN.R_E_C_N_O_ RECDBN "		
		cQuery    += "FROM " + RetSqlName("DBN")+ " DBN "
		cQuery    += "WHERE DBN_FILIAL = '"+xFilial("DBN")+"' "
		cQuery    += "AND DBN_CODUNI = '"+cCodUni+"' "
		cQuery    += "AND DBN.D_E_L_E_T_ = ' ' "
		cQuery    += "ORDER BY "+SqlOrder(DBN->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDBN,.T.,.T.)

		While DBN->(!Eof()) .And. (cAliasDBN)->DBN_FILIAL+(cAliasDBN)->DBN_CODUNI == xFilial("DBN")+cCodUni

			cCarga := (cAliasDBN)->DBN_CARGA+(cAliasDBN)->DBN_SEQCAR
			
			//-- Excluo a paletizacao
			While (cAliasDBN)->(!Eof()) .And. (cAliasDBN)->DBN_FILIAL == xFilial("DBN") .And. ;
				(cAliasDBN)->DBN_CARGA+(cAliasDBN)->DBN_SEQCAR == cCarga

				DBN->(MsGoto((cAliasDBN)->RECDBN))
				If lIntDL
					AAdd(aRecDBN, DBN->(Recno()))
				Else
					RecLock("DBN",.F.)
					dbDelete()
					MsUnlock()
				EndIf

				(cAliasDBN)->(dbSkip())
			Enddo
			
			//-- Altero o flag do arquivo de cargas
			DAK->(DbSetOrder(1))
			If DAK->(MsSeek(xFilial("DAK")+cCarga))
				If lIntDL
					AAdd(aRecDAK, DAK->(Recno()))
				Else
					RecLock("DAK",.F.)
					Replace DAK_FLGUNI With "2"
					MsUnlock()
				EndIf
			EndIf
		Enddo

		//-- Se integrado ao WMS, So exclui a Unitizacao se os Servicos de WMS NAO tiverem sido executados
		If lIntDL .And. Len(aRecDBN) > 0
			//-- Exclui Unitizacao
			For nX := 1 to Len(aRecDBN)
				DBN->(dbGoTo(aRecDBN[nX]))
				If RecLock('DBN', .F.)
					dbDelete()
					MsUnlock()
				EndIf
			Next nX
			//-- Altero o flag do arquivo de cargas
			For nX := 1 to Len(aRecDAK)
				DAK->(dbGoTo(aRecDAK[nX]))
				If RecLock('DAK', .F.)
					Replace DAK_FLGUNI With '2'
					MsUnlock()
				EndIf
			Next nX
			//-- Exclui os Servicos do WMS
			For nX := 1 to Len(aRecDCF)
				DCF->(dbGoTo(aRecDCF[nX]))
				cIdDCF   := If(DCF->(FieldPos("DCF_ID"))>0,DCF->DCF_ID,"")
				cServEmb := DCF->DCF_SERVIC
				If RecLock('DCF', .F.)
					dbDelete()
					MsUnlock()
					//-	Verifica servico de Embalagem e Expedicao
					If	!Empty(cIdDCF) .And. WmsVldSrv('3',@cServEmb,,,DCF->DCF_CODPRO)
						#IFDEF TOP
							DbSelectArea('SC9')
							//-- Obtem SC9 referente ao mesmo ID do SDB.
							cAliasSC9 := GetNextAlias()
							cQuery := "SELECT R_E_C_N_O_ RECSC9"
							cQuery += " FROM"
							cQuery += " "+RetSqlName('SC9')+" SC9"
							cQuery += " WHERE"
							cQuery += " C9_FILIAL = '"+xFilial("SC9")+"'"
							cQuery += " AND C9_IDDCF = '"+cIdDCF+"'"
							cQuery += " AND SC9.D_E_L_E_T_ = ' ' "
							cQuery := ChangeQuery(cQuery)
							DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSC9,.F.,.T.)
							While (cAliasSC9)->(!Eof())
								SC9->(MsGoTo((cAliasSC9)->RECSC9))
								If	RecLock('SC9',.F.)
									SC9->C9_IDDCF:=''
									MsUnlock()
								EndIf
								(cAliasSC9)->(DbSkip())
							EndDo
							DbSelectArea(cAliasSC9)
							DbCloseArea()
						#ENDIF
					EndIf
				EndIf
			Next nX			
		EndIf

		DbSelectArea(cAliasDBN)
		dbCloseArea()
		DbSelectArea("DBN")

	//-- Flag de Acerto de Carga
	Case nEvento == 5
		//- Tira o empenho do veiculo pois ele ja esta disponivel
		If lAlocVei
			OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_CAMINH,2)
		EndIf
		DbSelectArea("DAK")
		RecLock("DAK",.F.)
			DAK->DAK_ACECAR := "1"
			DAK->DAK_ACEVAS := "1"
			DAK->DAK_DTACCA := dDataBase
		MsUnlock()

	//-- Estorno do Flag de Acerto de Carga
	Case nEvento == 6
		DbSelectArea("DAK")
		RecLock("DAK" ,.F.)
			DAK->DAK_ACECAR := "2"
			DAK->DAK_ACEVAS := "2"
			DAK->DAK_DTACCA := Ctod("")
		MsUnlock()

		//-- Tira o empenho do veiculo pois ele ja esta disponivel
		If lAlocVei
			OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_CAMINH,1)
		EndIf

	//-- Faturamento da Carga
	Case nEvento == 7
		cAliasSC9 := "TOPSC9"
		SC9->(dbCommit())
		cQuery := "SELECT COUNT(*) QTDEPED "
		cQuery += "FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("DAI")+" DAI "
		cQuery += "WHERE DAI.DAI_FILIAL='"+cFilCar  +"' AND "
		cQuery += "DAI.DAI_COD='"   +DAK->DAK_COD   +"' AND "
		cQuery += "DAI.DAI_SEQCAR='"+DAK->DAK_SEQCAR+"' AND "
		cQuery += "DAI.D_E_L_E_T_=' ' AND "
		If	nVlEntcom <> 1
			cQuery += "SC9.C9_FILIAL=DAI.DAI_FILPV AND "
		Else
			cQuery += "SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
		EndIf
		cQuery += "SC9.C9_PEDIDO=DAI.DAI_PEDIDO AND "
		cQuery += "SC9.C9_CARGA =DAI.DAI_COD    AND "
		cQuery += "SC9.C9_SEQCAR=DAI.DAI_SEQCAR AND "
		cQuery += "SC9.C9_SERIENF='"+Space(Len(SC9->C9_SERIENF))+"' AND "
		cQuery += "SC9.C9_NFISCAL='"+Space(Len(SC9->C9_NFISCAL))+"' AND "
		cQuery += "SC9.D_E_L_E_T_=' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
		If	(cAliasSC9)->QTDEPED == 0
			RecLock("DAK")
			DAK->DAK_FEZNF := "1"
			MsUnlock()
		EndIf
		DbSelectArea(cAliasSC9)
		dbCloseArea()

		If cPaisLoc == "ARG" .And. lRemito
			DbSelectArea("DAI")
			DAI->(DbSetOrder(4)) //DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
			If DAI->(MsSeek(cFilCar+SD2->D2_PEDIDO+DAK->(DAK_COD+DAK->DAK_SEQCAR)))
				If Empty(DAI->DAI_REMITO)
					RecLock("DAI",.F.)
					DAI->DAI_REMITO		:= SD2->D2_DOC
					DAI->DAI_SERREM		:= SD2->D2_SERIE
					MsUnlock()
				EndIf
			Endif
		EndIf

	Case nEvento == 8
		//-- Calcula peso, volume e valor baseado no SD2
		
		//-- Calculo peso do item do pedido
		nPesoProd := OsPesoProd(SD2->D2_COD,SD2->D2_FILIAL)
		nPeso     := (nPesoProd * SD2->D2_QUANT)
		//-- Calcula capacidade volumetrica
		nCapArm := OsPrCapArm(SD2->D2_COD,SD2->D2_FILIAL)
		nCapVol := ( nCapArm * SD2->D2_QUANT )

		DbSelectArea("DAK")
		DbSetOrder(1)
		If MsSeek(OsFilial("DAK",cFilCar)+SF2->F2_CARGA+SF2->F2_SEQCAR)

			//-- Retira valores do DAK correspondente ao SC9 excluido
			RecLock("DAK")
				DAK->DAK_PESO   -= Iif(DAK->DAK_PESO > 0,nPeso, 0 )
				DAK->DAK_CAPVOL -= Iif(DAK->DAK_CAPVOL > 0,nCapVol,0 )
				DAK->DAK_VALOR  -= A410Arred(Iif(DAK->DAK_VALOR > 0,SD2->D2_QUANT * SD2->D2_PRCVEN, 0 ),"DAK_VALOR")
				DAK->DAK_PTOENT := OsPtoEntr(DAK->DAK_COD,DAK->DAK_SEQCAR,cFilCar)
			MsUnlock()
		EndIf

	Case nEvento == 9
		RecLock("DAK",.F.)
			DAK->DAK_ACEFIN := "1"
		MsUnlock()

	Case nEvento == 10
		RecLock("DAK",.F.)
			DAK->DAK_ACEFIN := "3"
		MsUnlock()

	Case nEvento == 11
		If DAK->(FieldPos("DAK_BLQCAR")) > 0
			RecLock("DAK",.F.)
				DAK->DAK_BLQCAR := "1"
			MsUnlock()
		EndIf

	Case nEvento == 12
		If DAK->(FieldPos("DAK_BLQCAR")) > 0
			RecLock("DAK",.F.)
				DAK->DAK_BLQCAR := "2"
			MsUnlock()
		EndIf

	Case nEvento == 13
		//-- Cancelamento da baixa do titulo no SIGAFIN
		If	AllTrim(SE1->E1_ORIGEM) == 'MATA460' .AND. AllTrim(SE1->E1_TIPO) == 'NF'
			SF2->(DbSetOrder(2))
			If	SF2->(DbSeek(xFilial("SF2")+SE1->(E1_CLIENTE+E1_LOJA+E1_NUM+E1_SERIE)))
				DAK->(DbSetOrder(1))
				If	DAK->(DbSeek(xFilial("DAK")+SF2->(F2_CARGA+F2_SEQCAR)) .And. DAK_ACEFIN=="1")
					//-- Verifica se houve conferencia do retorno financ.
					DAP->(DbSetOrder(1))
					If	DAP->(MsSeek(xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR))
						//-- Flag de Prestacao de Contas Conferido
						RecLock("DAK",.F.)
							DAK->DAK_ACEFIN := "3" //-- Status "Conferido"
						MsUnlock()
					Else
						//-- Flag de Prestacao de Contas em aberto
						RecLock("DAK",.F.)
							DAK->DAK_ACEFIN := "2" //-- Status "Em aberto"
						MsUnlock()
					EndIf
					//-- Verifica se houve acerto financeiro.
					DAM->(DbSetOrder(2)) //DAM_FILIAL+DAM_PREFIX+DAM_NUMERO+DAM_PARCEL+DAM_TIPO+DAM_CLIENT+DAM_LOJA
					If DAM->(DbSeek(xFilial("DAM")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
						RecLock("DAM",.F.)
						DAM->(DbDelete())
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf

	Case nEvento == 14
		//-- Baixa do titulo no SIGAFIN
		If	AllTrim(SE1->E1_ORIGEM) == 'MATA460' .AND. AllTrim(SE1->E1_TIPO) == 'NF'
			SF2->(DbSetOrder(2))
			If	SF2->(DbSeek(xFilial("SF2")+SE1->(E1_CLIENTE+E1_LOJA+E1_NUM+E1_SERIE)))
				DAK->(DbSetOrder(1))
				If	DAK->(DbSeek(xFilial("DAK")+SF2->(F2_CARGA+F2_SEQCAR)) .And. DAK_ACEFIN$"23")
					//-- Verificar se possui titulos em aberto
					SF2->(DbSetOrder(5))
					If	SF2->(DbSeek(xFilial("SF2")+DAK->(DAK_COD+DAK_SEQCAR)))
						While SF2->(!EOF() .And. F2_CARGA+F2_SEQCAR == DAK->(DAK_COD+DAK_SEQCAR))
							If	SF2->F2_TIPO <> "D"
								cPrefixo := IIf(Empty(SF2->F2_PREFIXO),&cDuPref,SF2->F2_PREFIXO)
								//-- Pesquisa titulos em aberto
								SE1->(dbSetOrder(2))
								#IFDEF TOP
									cAliasSE1:= GetNextAlias()
									cQuery := "SELECT 1 "
									cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
									cQuery += "WHERE SE1.E1_FILIAL= '"+xFilial("SE1")+"'"
									cQuery += " AND SE1.E1_PREFIXO= '"+cPrefixo+"'"
									cQuery += " AND SE1.E1_NUM    = '"+SF2->F2_DUPL+"'"
									cQuery += " AND SE1.E1_CLIENTE= '"+SF2->F2_CLIENTE+"'"
									cQuery += " AND SE1.E1_LOJA   = '"+SF2->F2_LOJA+"'"
									cQuery += " AND SE1.E1_BAIXA  = ''"
									cQuery += " AND SE1.E1_VALOR  = SE1.E1_SALDO"
									cQuery += " AND SE1.D_E_L_E_T_= ' ' "
									cQuery := ChangeQuery(cQuery)
									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
									lTitAb := (cAliasSE1)->(!EOF())
									dbSelectArea(cAliasSE1)
									(cAliasSE1)->(dbCloseArea())
									//-- Encontrou titulos em aberto
									If	lTitAb
										Exit
									EndIf
								#ENDIF
							EndIf
							SF2->(dbSkip())
						EndDo
					EndIf
					//-- Flag de Prestacao de Contas
					RecLock("DAK",.F.)
						DAK->DAK_ACECAR := "1"
						If	lTitAb
							DAK->DAK_ACEFIN := "3" //-- Status "Conferido"
						Else
							DAK->DAK_ACEFIN := "1" //-- Status "Conferido e Efetuado"
						EndIf
					MsUnlock()
				EndIf
			EndIf
		EndIf
EndCase

RestArea( aAreaSF2 )
RestArea( aAreaSC9 )
RestArea( aAreaDAK )
RestArea( aAreaDAI )
RestArea( aArea    )

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} OsHasSc9 STATIC
Rotina de verificacao de pedidos de uma determinada carga no SC9

Esta rotina tem como objetivo validar se existe SC9 para uma determinada carga

@param  cCarga    Codigo da Carga 
@param  cSeqCar   Sequencia da Carga                  
@param  cFilPv    Filial do Pedido de Venda 
@param  cPedido   Numero do pedido
@param  lWithNF   Apenas C9 já faturados - com NF

@return lRet      Existe ou não existe SC9

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OsHasSc9(cCarga,cSeqCar,cFilPv,cPedido,lWithNF)
Local aArea     := GetArea()
Local aAreaSC9  := SC9->(GetArea())
Local lRet      := .F.
Local cAliasSC9 := "SC9"

Local cQuery    := .F.

Default lWithNF := .F.

DbSelectArea("SC9")
DbSetOrder(1)

cAliasSC9 := "Oms200Proc"
SC9->(dbCommit())
cQuery := "SELECT COUNT(*) QTDEPED "
cQuery += "FROM "+RetSqlName("SC9")+" SC9 "
cQuery += "WHERE SC9.C9_FILIAL='"+OsFilial("SC9",cFilPV)+"' AND "
cQuery += "SC9.C9_CARGA ='"+cCarga +"' AND "
cQuery += "SC9.C9_SEQCAR='"+cSeqCar+"' AND "
cQuery += "SC9.C9_PEDIDO='"+cPedido+"' AND "
If lWithNF
	cQuery += "SC9.C9_NFISCAL > ' ' AND "
EndIf
cQuery += "SC9.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
lRet := Iif((cAliasSC9)->QTDEPED == 0,.F.,.T.)

DbSelectArea(cAliasSC9)
dbCloseArea()
DbSelectArea("SC9")

RestArea( aAreaSC9 )
RestArea( aArea    )

Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsPtoEntr STATIC
Rotina de Calculo de pontos de entrega na carga

@param  cCarga    Codigo da Carga 
@param  cSeqCar   Sequencia da Carga                  
@param  cFilCar   Filial da Carga

@return nPtoEntr  Quantidade de pontos de entrega da carga

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OsPtoEntr(cCarga,cSeqCar,cFilCar)
Local aArea     := GetArea()
Local aAreaDAI  := DAI->(GetArea())
Local lLocalEnt := SC5->(FieldPos("C5_CLIENT")) > 0
Local cOper     := ""
Local cFilPv    := ""
Local cQuery    := ""
Local cAliasDAI := "DAI"
Local cCodCli   := "SC5.C5_CLIENTE"
Local cLojCli   := "SC5.C5_LOJACLI"
Local nTpVlEnt  := OsVlEntCom()
Local nPtoEntr  := 0

Default cFilCar := xFilial("DAI")

//-- Calcula pontos de entrega de uma carga
If lLocalEnt
	cCodCli := "SC5.C5_CLIENT"
	cLojCli := "SC5.C5_LOJAENT"
EndIf
cFilPv := IIf(nTpVlEnt<>1,"DAI.DAI_FILPV",("'"+xFilial("SC9")+"'"))
cOper  := IIf(Upper(TcGetDb())$'ORACLE.POSTGRES.DB2.INFORMIX','||','+')
DAI->(dbCommit())
cAliasDAI := "OSPTOENTR"
cQuery := "SELECT COUNT(DISTINCT "+cCodCli+cOper+cLojCli+") DAI_COUNT "
cQuery += "FROM "      +RetSqlName("DAI")+" DAI "
cQuery += "INNER JOIN "+RetSqlName("SC5")+" SC5 ON "
cQuery += "SC5.C5_FILIAL  = "+cFilPv+" AND "
cQuery += "SC5.C5_NUM     = DAI.DAI_PEDIDO AND "
cQuery += "SC5.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery += "DAI.DAI_FILIAL = '"+OsFilial("DAI",cFilCar)+"' AND "
cQuery += "DAI.DAI_COD    = '"+cCarga +"' AND "
cQuery += "DAI.DAI_SEQCAR = '"+cSeqCar+"' AND "
cQuery += "DAI.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAI,.T.,.T.)
If (cAliasDAI)->(!Eof())
	nPtoEntr := (cAliasDAI)->DAI_COUNT
EndIf
(cAliasDAI)->(dbCloseArea())
DbSelectArea("SC9")

//³Restaura DAI por seguranca
RestArea( aAreaDAI )
RestArea( aArea    )

Return( nPtoEntr )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsPrCapArm
Rotina de Calculo de Volume do produto

Esta rotina tem como objetivo calcular o volume do produto solicitado de acordo com o cadastro do SB5 da pasta logistica

@param  cProduto  Codigo do Produto
@param  cFilPv    Filial do Pedido de Venda

@return nCapac    Volume do produto

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsPrCapArm(cProduto,cFilPv)
Local nCapac    := 0
Local lExistSB5 := .T.

DEFAULT cProduto := SB1->B1_PRODUTO

If	ExistBlock("OMSCPARM")
	nCapac := ExecBlock("OMSCPARM",.F.,.F.,{cProduto,cFilPv})
Else
	If !(cProduto == SB5->B5_COD)
		SB5->(DbSetOrder(1))
		lExistSB5 := SB5->(MsSeek(OsFilial("SB5",cFilPv)+cProduto))
	EndIf
	If lExistSB5
		nCapac := (SB5->B5_ALTURLC * SB5->B5_LARGLC * SB5->B5_COMPRLC)
	EndIf
EndIf

Return( nCapac )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsPesoProd
Rotina de Calculo de Peso do produto

@param  cProduto  Codigo do Produto
@param  cFilSB1   Filial do Produto

@return nPesoProd Peso do produto

@author  Vicco
@since   16/04/2014
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsPesoProd(cProduto,cFilSB1)
Local cCpoPeso  := IIf(Getmv("MV_PESOCAR") == "L","B1_PESO","B1_PESBRU")
Local lOM200PES := ExistBlock("OM200PES")
Local nRetPE    := 0
Local nPesoProd := 0

	If !(cProduto == SB1->B1_COD)
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(OsFilial("SB1",cFilSB1)+cProduto))
	EndIf

	nPesoProd := SB1->(FieldGet(FieldPos(cCpoPeso)))

	//-- Permite informar peso variavel do produto do pedido de vendas usado no calculo do peso da carga.
	If lOM200PES
		nRetPE := ExecBlock("OM200PES",.F.,.F.,{cProduto})
		If ValType(nRetPE) == "N"
			nPesoProd := nRetPE
		EndIf
	EndIf

Return( nPesoProd )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsAglForma
Rotina de Calculo Aglutinado das formas de pagamento

Esta rotina tem como objetivo calcular as formas de pagamento de uma carga aglutinada de acordo com os parametros:
MV_OMSBXCR, MV_OMSBXLQ, MV_OMSBXCP

@param  cCarga    Codigo da Carga
@param  cSeqCar   Sequencia da Carga

@return aRetorno  Formas de pagamento para a Carga

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsAglForma(cCarga,cSeqCar)
Local aArea     := GetArea()
Local aRetorno  := {}
Local aFormas   := OsFormasPg(cCarga,cSeqCar,1)
Local cQuery    := ""
Local cAliasDAP := GetNextAlias()
Local cAliasDAM := GetNextAlias()
Local cFormaBx  := SuperGetMv("MV_OMSBXCR",.F.,"")
Local cFormaLq  := SuperGetMv("MV_OMSBXLQ",.F.,"")
Local cFormaCp  := SuperGetMv("MV_OMSBXCP",.F.,"")
Local cFormaAglt:= ""
Local cDescAglt := ""

Local nPosRet   := 0
Local nPosForma := 0
Local nTotDev   := 0

	//-- Verifica se houveram devolucoes nao previstas nas formas
	nPosForma := Ascan(aFormas,{|x| Alltrim(x[3]) == "" })
	If nPosForma > 0
		nTotDev := aFormas[nPosForma][6]
	EndIf

	//-- Inclui sempre a linha outros para informacoes que não estavam previstas
	AAdd(aRetorno,{"OT","OUTROS",0,nTotDev,0,0})

	//-- Acerto Financeiro
	DAP->(dbCommit())
	cQuery := "SELECT DAP_FILIAL,"
	cQuery +=       " DAP_CARGA,"
	cQuery +=       " DAP_SEQCAR,"
	cQuery +=       " DAP_CODGRU,"
	cQuery +=       " DAP_PREVIS,"
	cQuery +=       " DAP_REALIZ"
	cQuery += " FROM "+RetSqlName("DAP")+" DAP"
	cQuery += "WHERE "
	If nTipoOper == 1
		cQuery +=   " DAP.DAP_FILIAL = '"+xFilial("DAP")+"' AND"
	EndIf
	cQuery +=       " DAP.DAP_CARGA  = '"+cCarga +"'"
	cQuery +=   " AND DAP.DAP_SEQCAR = '"+cSeqCar+"'"
	cQuery +=   " AND DAP.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAP,.T.,.T.)
	TcSetField(cAliasDAP,"DAP_PREVIS","N",TamSX3("DAP_PREVIS")[1],TamSX3("DAP_PREVIS")[2])
	TcSetField(cAliasDAP,"DAP_REALIZ","N",TamSX3("DAP_REALIZ")[1],TamSX3("DAP_REALIZ")[2])
	While !(cAliasDAP)->(Eof())
		nTotDev := 0
		Do Case
			Case Alltrim((cAliasDAP)->DAP_CODGRU) $ cFormaBx
				cFormaAglt := "BX"
				cDescAglt  := "BAIXAS SIMPLES"
			Case Alltrim((cAliasDAP)->DAP_CODGRU) $ cFormaLq
				cFormaAglt := "LQ"
				cDescAglt  := "LIQUIDACOES"
			Case Alltrim((cAliasDAP)->DAP_CODGRU) $ cFormaCp
				cFormaAglt := "CP"
				cDescAglt  := "COMPENSACOES"
			OtherWise
				cFormaAglt := "OT"
				cDescAglt  := "OUTROS"
		EndCase

		//-- Busca o total de devolucao do item
		nPosForma := Ascan(aFormas,{|x| x[3] == (cAliasDAP)->DAP_CODGRU })
		If nPosForma > 0
			nTotDev := aFormas[nPosForma][6]
		EndIf

		//-- Acumula as formas por movimentacao
		nPosRet := Ascan(aRetorno,{|x| x[1] == cFormaAglt})
		If nPosRet == 0
			AAdd(aRetorno,{cFormaAglt,cDescAglt,(cAliasDAP)->DAP_PREVIS,nTotDev,(cAliasDAP)->DAP_REALIZ,0})
		Else
			aRetorno[nPosRet][3] += (cAliasDAP)->DAP_PREVIS
			aRetorno[nPosRet][4] += nTotDev
			aRetorno[nPosRet][5] += (cAliasDAP)->DAP_REALIZ
		EndIf
		(cAliasDAP)->(dbSkip())
	EndDo
	(cAliasDAP)->(dbCloseArea())

	//-- Movimentacao Acerto Financeiro
	DAM->(dbCommit())
	cQuery := "SELECT DAM_FILIAL,"
	cQuery +=       " DAM_CARGA,"
	cQuery +=       " DAM_SEQCAR,"
	cQuery +=       " DAM_TPBAIX,"
	cQuery +=       " DAM_VALOR"
	cQuery += " FROM "+RetSqlName("DAM")+" DAM"
	cQuery += "WHERE "
	If nTipoOper == 1
		cQuery +=   " DAM.DAM_FILIAL = '"+xFilial("DAM")+"' AND"
	EndIf
	cQuery +=       " DAM.DAM_CARGA  = '"+cCarga +"'"
	cQuery +=   " AND DAM.DAM_SEQCAR = '"+cSeqCar+"'"
	cQuery +=   " AND DAM.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAM,.T.,.T.)
	TcSetField(cAliasDAM,"DAM_VALOR","N",TamSX3("DAM_VALOR")[1],TamSX3("DAM_VALOR")[2])

	//-- Busca no DAM caso ja exista baixas realizadas
	While (cAliasDAM)->(!Eof())
		Do Case
			Case (cAliasDAM)->DAM_TPBAIX == "1"
				cFormaAglt := "BX"
				cDescAglt  := "BAIXAS SIMPLES"
			Case (cAliasDAM)->DAM_TPBAIX == "2"
				cFormaAglt := "LQ"
				cDescAglt  := "LIQUIDACOES"
			Case (cAliasDAM)->DAM_TPBAIX == "3"
				cFormaAglt := "CP"
				cDescAglt  := "COMPENSACOES"
			OtherWise
				cFormaAglt := "OT"
				cDescAglt  := "OUTROS"
		EndCase
		nPosRet := Ascan(aRetorno,{|x| x[1] == cFormaAglt})
		If nPosRet == 0
			AAdd(aRetorno,{cFormaAglt,cDescAglt,0,0,0,(cAliasDAM)->DAM_VALOR})
		Else
			aRetorno[nPosRet][6] += (cAliasDAM)->DAM_VALOR
		EndIf
		(cAliasDAM)->(dbSkip())
	EndDo
	(cAliasDAM)->(dbCloseArea())

RestArea(aArea)
Return aRetorno

//--------------------------------------------------------------------
/*/{Protheus.doc} OSPcCpCob
Rotina de implantacao do titulo de cobranca no contas a pagar para o fornecedor determinado na tabela DA4 ( Motorista )

Esta rotina tem como objetivo gravar os titulos de cobranca para o motorista responsavel pela carga.
O codigo do fornecedor eh obtido da tabela DA4 ( Motorista ).
Para valores positivos serao gerados titulos do tipo NDF. 

@param  cCarga    Codigo da Carga
@param  cSeqCar   Sequencia da Carga
@param  nValor    Valor da implantacao do titulo de cobranca

@return lGravou  Indica o sucesso da implantacao

@author  Henry Fila
@since   08/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OSPcCpCob(cCarga,cSeqCar,nValor)

Local aArea      := GetArea()
Local cMay       := ""
Local cPrefixo   := &(SuperGetMv("MV_PCPREFI" ,.F.,'"CRG"'))
Local cNatureza  := &(SuperGetMv("MV_PCNATU" ,.F.,Space(Len(SE2->E2_NATUREZ))))
Local cNumTit    := DAK->DAK_COD
Local cTipo      := Iif(nValor > 0, SuperGetMv("MV_PCCRED" ,.F.,"NCF"),MV_CPNEG)
Local cAliasDAP  := "DAP"
Local lGravou    := .F.
Local nPrzVencto := SuperGetMv("MV_PCVENCT",.F.,0)  //Qtde de dias para o vencimento do titulo do motorista

//-- Ponto de entrada gravacao do Titulo de Cobranca para Motoristra/Fornecedor.
If ExistBlock("OSCOBFOR")
	lGravou := ExecBlock("OSCOBFOR",.F.,.F.,{cCarga,cSeqCar,nValor})
Else
	//-- Verifica se esta preenchido o fornecedor amarrado com o motorista
	DA4->(DbSetOrder(1))
	DA4->(MsSeek(xFilial("DA4")+DAK->DAK_MOTORI))
	If !Empty(DA4->DA4_FORNEC)
		//-- Busca numero do titulo a gerar
		DbSelectArea("SE2")
		cMay := "SE2"+ Alltrim(xFilial("SE2"))
		DbSetOrder(1)
		While ( MsSeek(xFilial("SE2")+cPrefixo+cNumTit+"1"+cTipo) .or. ;
				!MayIUseCode(cMay+cPrefixo+cNumTit+"1"+cTipo) )
			cNumTit := Soma1(cNumTit,Len(SE2->E2_NUM))
		EndDo

		//-- Posiciona registros
		DbSelectArea("SE2")
		DbSetOrder(1)
		DbSeek(xFilial("SE2") + cPrefixo + cNumTit)
			If Found() // Avalia o retorno do último DbSeek realizado
				RecLock("SE2", .F.)
			Else
				RecLock("SE2", .T.)
			EndIf
				nValor := xMoeda(Abs(nValor),1,1,dDataBase)
				SE2->E2_FILIAL  := xFilial("SE2")
				SE2->E2_NUM     := cNumTit
				SE2->E2_PREFIXO := cPrefixo
				SE2->E2_PARCELA := ""
				SE2->E2_TIPO    := cTipo
				SE2->E2_FORNECE := DA4->DA4_FORNEC
				SE2->E2_LOJA    := DA4->DA4_LOJA
				SE2->E2_NOMFOR  := SA2->A2_NREDUZ
				SE2->E2_EMIS1   := dDataBase
				SE2->E2_EMISSAO := dDataBase
				SE2->E2_VENCTO  := dDataBase + nPrzVencto
				SE2->E2_VENCREA := DataValida(SE2->E2_VENCTO,.T.)
				SE2->E2_VENCORI := SE2->E2_VENCTO
				SE2->E2_MOEDA   := 1
				SE2->E2_VALOR   := nValor
				SE2->E2_SALDO   := nValor
				SE2->E2_NATUREZ := cNatureza
				SE2->E2_VLCRUZ  := nValor
				SE2->E2_ORIGEM  := ""
				SE2->E2_RATEIO  := "N"
				SE2->E2_HIST    := "DIFERENCA DE CARGA"
			MsUnLock()
		FaAvalSe2(1,"OMSA341")

		//-- Grava Titulo gerado no DAP para amarração no SE2
		(cAliasDAP)->(DbSetOrder(1))
		(cAliasDAP)->(MsSeek(xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR))

		While (cAliasDAP)->(!Eof()) .And. (cAliasDAP)->DAP_FILIAL+(cAliasDAP)->DAP_CARGA+(cAliasDAP)->DAP_SEQCAR == ;
			xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR

			RecLock("DAP",.F.)
				DAP->DAP_PREFIX := SE2->E2_PREFIXO
				DAP->DAP_NUM    := SE2->E2_NUM
				DAP->DAP_PARCEL := SE2->E2_PARCELA
				DAP->DAP_TIPO   := SE2->E2_TIPO
				DAP->DAP_FORNEC := SE2->E2_FORNECE
				DAP->DAP_LOJA   := SE2->E2_LOJA
				DAP->DAP_FILCP  := Iif(!Empty(FwFilial("SE2")),xFilial("SE2"),cFilAnt)
			MsUnlock()

			(cAliasDAP)->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea( aArea )

Return( lGravou )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsFormasPg
Traz as formas de pagamento de uma determinada carga com seu rateio especifico

Esta rotina tem como objetivo efetuar o refresh no objeto da getdados na troca dos folders

@param  cCarga    Codigo da Carga
@param  cSeqCar   Sequencia da Carga
@param  nMoeda    Moeda de retorno
@param  nTpAgl    Aglutina por: [1] Forma de pagamento
								[2] Forma de pagamento/Pedido
								[3] Forma de pagametno/Cliente
@param  aDevol	  Array com dados de documento pré-existentes							

@return aFormas   Array com as formas de pagamento encontradas
				  [1] Moeda
				  [2] Valor do parametro ExpN4
				  [3] Forma
				  [4] Descricao
				  [5] Valor faturado ja rateado
				  [6] Valor devolvido ja reteado 

@author  Henry Fila
@since   17/08/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsFormasPg(cCarga,cSeqcar,nMoeda,nTpAgl,aDevol)
Local aArea      := GetArea()
Local aFormas    := {}
Local aPedidos   := {}
Local aValDup    := {}
Local aStruSF2   := {}
Local aStruSD2   := {}
Local aStruSF4   := {}
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasSD1  := ""
Local cNota      := ""
Local cSerie     := ""
Local cCliente   := ""
Local cLoja      := ""
Local cAglutina  := ""
Local cFilNf     := ""
Local cCampos    := ""
Local nValMerc   := 0
Local nValor     := 0
Local nMoedaTit  := 0
Local nValFat    := 0
Local nRateio    := 0
Local nAcRateio  := 0
Local nValorDev  := 0
Local nImpos     := 0
Local nY         := 0
Local nX         := 0
Local nUlt       := 0
Local nDespesas  := 0
Local nFaturas   := 0
Local nPosForma  := 0
Local lSkip      := .F.
Local oStructSD2 := FWFormStruct(1,"SD2")
Local aCamposSD2 := oStructSD2:GetFields()
Local dAcertFin  := Posicione("DAP",1,xFilial("DAP")+cCarga+cSeqCar,"DAP_DTACER")
Local lValFre    := SuperGetMv("MV_OMSVFRE",.F.,.F.)

DEFAULT nTpAgl  := 1
DEFAULT aDevol  := {}

	// Se o acerto financeiro ainda não tiver sido realizado, considera a database
	If Empty(dAcertFin)
		dAcertFin := dDataBase
	EndIf

	SF2->(DbSetOrder(5)) //F2_FILIAL+F2_CARGA+F2_SEQCAR+F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA
	cCampos := "F2_FILIAL|F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_FRETE|F2_DESPESA|F2_SEGURO|F2_VALFAT|F2_TIPO"
	cCampos += "D2_FILIAL|D2_DOC|D2_SERIE|D2_CLIENTE|D2_LOJA|D2_TES|D2_TOTAL|D2_ITEM|D2_PEDIDO|D2_ITEMPV|D2_QUANT|D2_VALIPI|D2_ICMSRET|D2_IPI|D2_TIPODOC"

	If cPaisLoc <> "BRA"
		For nY := 1 To Len(aCamposSD2)
			If SubStr(aCamposSD2[nY,3],1,9) == "D2_VALIMP"
				cCampos += aCamposSD2[nY,3]+"|"
			EndIf
		Next nY
	EndIf

	cCampos += "F4_DUPLIC|F4_AGREG|F4_INCSOL"

	aStruSF2 := SF2->(dbStruct())
	aStruSD2 := SD2->(dbStruct())
	aStruSF4 := SF4->(dbStruct())

	For nX := 1 To Len(aStruSF2)
		If Alltrim(aStruSF2[nX][1]) $ cCampos
			cQuery += ",SF2."+aStruSF2[nX][1]
		EndIf
	Next nX

	For nX := 1 To Len(aStruSD2)
		If Alltrim(aStruSD2[nX][1]) $ cCampos
			cQuery += ",SD2."+aStruSD2[nX][1]
		EndIf
	Next nX

	For nX := 1 To Len(aStruSF4)
		If Alltrim(aStruSF4[nX][1]) $ cCampos
			cQuery += ",SF4."+aStruSF4[nX][1]
		EndIf
	Next nX

	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
	cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2"
	cQuery +=    " ON SD2.D2_FILIAL  = "+Iif(nTipoOper == 1, "'"+xFilial("SD2")+"'", OsFilQry("SD2","SF2.F2_FILIAL"))
	cQuery +=   " AND SD2.D2_DOC     = SF2.F2_DOC"
	cQuery +=   " AND SD2.D2_SERIE   = SF2.F2_SERIE"
	cQuery +=   " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"
	cQuery +=   " AND SD2.D2_LOJA    = SF2.F2_LOJA"
	cQuery +=   " AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4"
	cQuery +=    " ON SF4.F4_FILIAL  = "+Iif(nTipoOper == 1, "'"+xFilial("SF4")+"'", OsFilQry("SF4","SF2.F2_FILIAL"))
	cQuery +=   " AND SF4.F4_CODIGO  = SD2.D2_TES"
	cQuery +=   " AND SF4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE "
	If nTipoOper == 1
		cQuery += " SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND"
	EndIf
	cQuery +=     " SF2.F2_CARGA  = '"+cCarga+"'"
	cQuery += " AND SF2.F2_SEQCAR = '"+cSeqCar+"'"
	cQuery += " AND SF2.F2_TIPO NOT IN ('D','B')"
	cQuery += " AND SF2.D_E_L_E_T_= ' '"
	If cPaisLoc<>"BRA"
		cQuery+=" AND NOT ("+IsRemito(3,'D2_TIPODOC')+ ") "
	EndIf
	cQuery += "ORDER BY "+SqlOrder(SF2->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	For nX := 1 To Len(aStruSF2)
		If aStruSF2[nX][2]!="C" .And. FieldPos(aStruSF2[nX][1])>0
			TcSetField(cAliasQry,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
		EndIf
	Next nX

	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2]!="C" .And. FieldPos(aStruSD2[nX][1])>0
			TcSetField(cAliasQry,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf
	Next nX

	For nX := 1 To Len(aStruSF4)
		If aStruSF4[nX][2]!="C" .And. FieldPos(aStruSF4[nX][1])>0
			TcSetField(cAliasQry,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
		EndIf
	Next nX

	While (cAliasQry)->(!Eof())

		aPedidos := {}
		lSkip    := .F.

		nValMerc := 0
		aValDup  := {}

		cFilNf   := OsFilial("SF2",(cAliasQry)->F2_FILIAL)
		cNota    := (cAliasQry)->F2_DOC
		cSerie   := (cAliasQry)->F2_SERIE
		cCliente := (cAliasQry)->F2_CLIENTE
		cLoja    := (cAliasQry)->F2_LOJA
		nDespesas:= (cAliasQry)->F2_FRETE+(cAliasQry)->F2_DESPESA+(cAliasQry)->F2_SEGURO
		nFaturas := (cAliasQry)->F2_VALFAT
		While (cAliasQry)->(!Eof() .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == cFilNf+cNota+cSerie+cCliente+cLoja)

			nValMerc += (cAliasQry)->D2_TOTAL
			nImpos   := Iif((cAliasQry)->F4_INCSOL=="S".And.(cAliasQry)->F4_DUPLIC=="S",(cAliasQry)->D2_ICMSRET,0)
			AAdd(aValDup,{	(cAliasQry)->D2_FILIAL,;		//1
							(cAliasQry)->D2_DOC,;			//2
							(cAliasQry)->D2_SERIE,;			//3
							(cAliasQry)->D2_ITEM,;			//4
							(cAliasQry)->D2_PEDIDO,;		//5
							(cAliasQry)->D2_ITEMPV,;		//6
							(cAliasQry)->D2_QUANT,;			//7
							(cAliasQry)->D2_TOTAL+nImpos,;	//08
							(cAliasQry)->F4_DUPLIC,;		//09
							0,;								//10 - Despesas acessorias
							0,;								//11 - Total da duplicata para este item
							0,;								//12 - Total de devolução para este item
							(cAliasQry)->D2_TIPODOC})		//13

			DbSelectArea(cAliasQry)
			(cAliasQry)->(dbSkip())
			lSkip := .T.
		EndDo
		
		//-- Rateia as despesas acessorias
		nRateio   := nDespesas
		nAcRateio := 0
		nValFat   := 0
		For nX := 1 To Len(aValDup)
			If nX <> Len(aValDup)
				aValDup[nX][10] := NoRound(aValDup[nX][8]*nRateio/nValMerc,2)
			Else
				aValDup[nX][10] := nRateio - nAcRateio
			EndIf
			nAcRateio += aValDup[nX][10]
			If	aValDup[nX][09] == "S" .And. !IsRemito(1,"'"+aValDup[nX][13]+"'")
				nValFat += aValDup[nX][8]+aValDup[nX][10]
			EndIf
		Next nX

		//-- Rateia a diferenca do valor faturado
		nUlt      := 0
		nRateio   := nFaturas - nValFat
		nAcRateio := 0
		For nX := 1 To Len(aValDup)
			If aValDup[nX][09] == "S" .And. !IsRemito(1,"'"+aValDup[nX][13]+"'")
				If nX <> Len(aValDup)
					aValDup[nX][11] := NoRound((aValDup[nX][8]+aValdup[nX][10])*nRateio/nValFat,2)
					nUlt := nX
				Else
					aValDup[nX][11] := nRateio - nAcRateio
				EndIf
				nAcRateio += aValDup[nX][11]
			EndIf
		Next nX
		If	nRateio > nAcRateio .And. nUlt > 0
			aValDup[nUlt][11] += nRateio - nAcRateio
		EndIf
		// A Matriz aValDup contém todos os itens de nota fiscal de saída
		// Na posição 12 de cada linha da matriz - item faturado - deve ser atualizado o valor da devolução dos itens
		// O alias SD1 foi indexado de pela serie, nota e item de saída (D1_NFORI,D1_SEIRORI, D1_ITEMORI)
		// Deve-se totalizar as devoluções no SD1 para o item faturado e atualizar a posição 12 da linha atual da Matriz aValDup
		For nX := 1 To Len(aValDup)
			//-- Busca as devolução deste item no SD1
			cAliasSD1 := GetNextAlias()
			cQuery := "SELECT D1_DOC,"
			cQuery +=       " D1_SERIE,"
			cQuery +=       " D1_FORNECE,"
			cQuery +=       " D1_LOJA,"
			cQuery +=       " D1_NFORI,"
			cQuery +=       " D1_SERIORI,"
			cQuery +=       " D1_FORNECE,"
			cQuery +=       " D1_LOJA, "
			cQuery +=       " D1_COD,"
			cQuery +=       " D1_ITEMORI,"
			cQuery +=       " D1_TOTAL,"
			cQuery +=       " D1_TES,"
			cQuery +=       " D1_VALDESC,"
			cQuery +=       " D1_VALIPI,"
			cQuery +=       " D1_ICMSRET,"
			cQuery +=       " D1_TIPODOC,"
			cQuery +=       " D1_VALFRE,"
			cQuery +=       " F4_INCSOL"
			cQuery +=  " FROM "+RetSqlName("SD1")+" SD1"
			cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4"
			cQuery +=    " ON SF4.F4_FILIAL  = '"+OsFilial("SF4",xFilial("SF4"))+"'"
			cQuery +=   " AND SF4.F4_CODIGO  = SD1.D1_TES"
			cQuery +=   " AND SF4.F4_DUPLIC  = 'S'"
			cQuery +=   " AND SF4.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SD1.D1_FILIAL  = '"+OsFilial("SD1",aValDup[nX][1])+"'"
			cQuery +=   " AND SD1.D1_FORNECE = '"+cCliente+"'"
			cQuery +=   " AND SD1.D1_LOJA    = '"+cLoja+"'"
			cQuery +=   " AND SD1.D1_TIPO    = 'D'"
			cQuery +=   " AND SD1.D1_EMISSAO <= '"+DtoS(dAcertFin)+"'"
			cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
			While (cAliasSD1)->(!EOF())
				nImpos := 0
				//-- Condicoes retiradas da consulta SQL (QUERY)
				If	(cAliasSD1)->D1_NFORI       = aValDup[nX][2] .AND. ;
					(cAliasSD1)->D1_SERIORI     = aValDup[nX][3] .AND. ;
					(cAliasSD1)->D1_ITEMORI     = aValDup[nX][4]

					If	!Empty((cAliasSD1)->D1_TES) .And. !IsRemito(1,(cAliasSD1)+"->D1_TIPODOC")
						nImpos := Iif(F4_INCSOL=="S",(cAliasSD1)->D1_ICMSRET,0)
						//Indica se o valor do frete informado no documento de devolução será considerado na conferencia da carga.
						IF lValFre
							aValDup[nX][12] += (cAliasSD1)->(D1_TOTAL-D1_VALDESC+D1_VALIPI+D1_VALFRE)+nImpos
						Else							
							aValDup[nX][12] += (cAliasSD1)->(D1_TOTAL-D1_VALDESC+D1_VALIPI)+nImpos
						Endif
						If aScan(aDevol,{|x| x[1]==(cAliasSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA,D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+Alltrim(D1_ITEMORI))})==0
							AAdd(aDevol,{			(cAliasSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA,D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+Alltrim(D1_ITEMORI))})
						EndIf
					EndIf
				EndIf
				(cAliasSD1)->(dbSkip())
			EndDo
			(cAliasSD1)->(dbCloseArea())
		Next nX
		
		//-- Rateia por pedido
		For nX := 1 To Len(aValDup)
			aValDup[nX][11] += (aValDup[nX][8]+aValdup[nX][10])
			If aValDup[nX][09] == "S" .And. !IsRemito(1,"'"+aValDup[nX][13]+"'")
				nY := aScan(aPedidos,{|x| x[2]==aValDup[nX][5]})
				If nY == 0
					AAdd(aPedidos, { aValDup[nX][1], aValDup[nX][5], aValDup[nX][11],aValDup[nX][12],cCliente+cLoja })
				Else
					aPedidos[nY][3] += aValDup[nX][11]
					aPedidos[nY][4] += aValDup[nX][12]
				EndIf
			EndIf
		Next nX

		For nY := 1 to Len(aPedidos)
			Do Case
				Case nTpAgl == 1 //Forma de pagto/
					cAglutina := ""
				Case nTpAgl == 2 //Forma de pagto/Pedido
					cAglutina := aPedidos[nY][2]
				Case nTpAgl == 3 //Forma de pagto/Cliente
					cAglutina := aPedidos[nY][5]
			EndCase

			DbSelectArea("SCV")
			SCV->(DbSetOrder(1)) //CV_FILIAL+CV_PEDIDO+CV_FORMAPG
			If SCV->(MsSeek(OsFilial("SCV",aPedidos[nY][1])+aPedidos[nY][2]))
				While SCV->(!Eof() .And. CV_FILIAL+CV_PEDIDO == OsFilial("SCV",aPedidos[nY][1])+aPedidos[nY][2])

					nValor    := aPedidos[nY][3] * (SCV->CV_RATFOR / 100)
					nValor    := xMoeda(nValor,1,nMoeda)

					nValorDev := aPedidos[nY][4] * (SCV->CV_RATFOR / 100)
					nValorDev := Round(xMoeda(nValorDev,nMoedaTit,nMoeda),2)

					nPosForma :=Ascan(aFormas,{|x| x[3] == SCV->CV_FORMAPG .And. x[2]==cAglutina})
					If nPosForma == 0
						AAdd(aFormas, {nMoeda,cAglutina,SCV->CV_FORMAPG,Tabela("24",SCV->CV_FORMAPG,.F.),nValor,nValorDev } )
					Else
						aFormas[nPosForma][5] += nValor
						aFormas[nPosForma][6] += nValorDev
					EndIf
					SCV->(dbSkip())
				EndDo
			Else
				nValor    := aPedidos[nY][3]
				nValor    := xMoeda(nValor,nMoedaTit,nMoeda)

				nValorDev := aPedidos[nY][4]
				nValorDev := Round(xMoeda(nValorDev,nMoedaTit,nMoeda),2)

				nPosForma :=Ascan(aFormas,{|x| x[3] == Space(Len(SCV->CV_FORMAPG)) .And. x[2]==cAglutina })
				If nPosForma == 0
					AAdd(aFormas, {nMoeda,cAglutina,Space(Len(SCV->CV_FORMAPG)),Space(30),nValor,nValorDev})
				Else
					aFormas[nPosForma][5] += nValor
					aFormas[nPosForma][6] += nValorDev
				EndIf
			EndIf
		Next nY

		If !lSkip
			(cAliasQry)->(dbSkip())
		EndIf
	EndDo
	(cAliasQry)->(dbCloseArea())

	SF2->(DbSetOrder(1))

RestArea( aArea )
Return( aFormas )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsCargaNf
Funcao que retorna clientes e respecitvas notas da carga

@param  cCarga    Codigo da Carga
@param  cSeqCar   Sequencia da Carga

@return aClientes Array com Clientes e Notas Fiscais relacionadas a Carga
					[1]-Filial SA1
					[2]-Filial SF2
					[3]-Codigo do Cliente
					[4]-Loja
					[5]-Nome
					[6]-aNotas
						[1]-Numero do documento de saida
						[2]-Serie
						[3]-Duplicata
						[4]-Prefixo

@author  Henry Fila
@since   27/07/2000
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsCargaNf(cCarga,cSeqCar)
Local aArea     := GetArea()
Local aClientes := {}
Local cAliasQry := ""
Local cQuery    := ""
Local nPosCli   := 0

	cQuery := "SELECT F2_FILIAL,"
	cQuery +=       " F2_CARGA,"
	cQuery +=       " F2_SEQCAR,"
	cQuery +=       " F2_SEQENT,"
	cQuery +=       " F2_CLIENTE,"
	cQuery +=       " F2_LOJA,"
	cQuery +=       " F2_DOC,"
	cQuery +=       " F2_SERIE,"
	cQuery +=       " F2_DUPL,"
	cQuery +=       " F2_PREFIXO,"
	cQuery +=       " A1_NOME"
	cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1"
	cQuery +=    " ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"
	cQuery +=   " AND SA1.A1_COD     = SF2.F2_CLIENTE"
	cQuery +=   " AND SA1.A1_LOJA    = SF2.F2_LOJA"
	cQuery +=   " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE "
	If nTipoOper == 1
		cQuery += " SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND"
	EndIf
	cQuery +=       " SF2.F2_CARGA   = '"+cCarga +"'"
	cQuery +=   " AND SF2.F2_SEQCAR  = '"+cSeqCar+"'"
	cQuery +=   " AND SF2.F2_TIPO NOT IN ('D','B')"
	cQuery +=   " AND SF2.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY F2_FILIAL,F2_CARGA,F2_SEQCAR,F2_SERIE,F2_DOC,F2_CLIENTE,F2_LOJA"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	While (cAliasQry)->(!EOF())
		nPosCli := Ascan(aClientes,{|x| x[1]+x[2]+x[3] == OsFilial("SA1",(cAliasQry)->F2_FILIAL)+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA})
		If nPosCli == 0
			AAdd(aClientes,{OsFilial("SA1",(cAliasQry)->F2_FILIAL),(cAliasQry)->F2_CLIENTE,(cAliasQry)->F2_LOJA,(cAliasQry)->A1_NOME,{}})
			nPosCli := Len(aClientes)
		EndIf
		//-- Acrescenta numero + serie da nota e duplicata + prefixo
		AAdd(aClientes[nPosCli][5],{(cAliasQry)->F2_FILIAL,(cAliasQry)->F2_DOC,(cAliasQry)->F2_SERIE,(cAliasQry)->F2_DUPL,(cAliasQry)->F2_PREFIXO})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	//-- Indica se na prestacao de contas os titulos serao mostrados em ordem de entrega da carga. 1=Sim;2=Nao
	If SuperGetMv("MV_PRSTORD",.F.,"2") == "1"
		aClientes := aSort(aClientes,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )
	EndIf

RestArea(aArea)
Return(aClientes)

//--------------------------------------------------------------------
/*/{Protheus.doc} OsSeqEnt
Funcao que retorna a sequencia de entrega de um determinado pedido dentro de uma carga

@param  cCarga    Codigo da Carga
@param  cSeqCar   Sequencia da Carga
@param  cPedido   Código do Pedido

@return cSeqEnt   Sequencia da Entrega

@author  Henry Fila
@since   27/07/2000
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsSeqEnt(cCarga,cSeqCar,cPedido)
Local aArea    := GetArea()
Local aAreaDAI := DAI->(GetArea())
Local nSeqInc  := SuperGetMV("MV_OMSENTR",.F.,5)
Local cSeqEnt  := ""

//-- Busca no DAI o numero da sequencia de entrega caso o pedido ja exista na carga de destino
DbSelectArea("DAI")
DbSetOrder(4)
If MsSeek(xFilial("DAI")+cPedido+cCarga+cSeqCar)
	cSeqEnt := DAI->DAI_SEQUEN
Else
	//-- Procura a proxima sequencia disponivel na carga de destino
	DbSelectArea("DAI")
	DbSetOrder(1)
	MsSeek(xFilial("DAI")+cCarga+cSeqCar+'zzzzzz',.T.)
	dbSkip(-1)
	If Eof() .Or. cCarga+cSeqCar <> DAI->DAI_COD+DAI->DAI_SEQCAR
		cSeqEnt := "000005"
	Else
		nSeqInc := IIF(nSeqInc > 0,nSeqInc,5)
		cSeqEnt := StrZero(Val(DAI_SEQUEN)+nSeqInc,6)
	EndIf
EndIf

RestArea( aAreaDAI )
RestArea( aArea    )

Return( cSeqEnt )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsVlEntCom
Função que valida a Entrega Compartilhada no módulo OMS

@param   cFilCar   Filial da tabela DAK (caracter)

@return  nTipo     Forma de busca da filial da Carga

@author  Henry Fila
@since   10/12/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsVlEntCom(cFilCar)
Local nTipo := 1
Default cFilCar := cFilAnt

	// Tipo 1     - Busca filial através do método padrão
	// Tipo 2 e 3 - Busca filiais de/até do sistema em todas as rotinas
	If DAI->(ColumnPos("DAI_FILPV")) > 0
		If OsOLCheck(cFilCar)
			nTipo := 3
		Else
			If Empty(FwFilial("DAK"))
				nTipo := 2
			EndIf
		EndIf
	EndIf

Return nTipo

//--------------------------------------------------------------------
/*/{Protheus.doc} OsOLCheck STATIC
Efetua a checagem se o OMS está parametrizado para operador logístico e se a filial corrente é a mesma do operador

@param   cFilAtual   Filial da tabela DAK (caracter)

@return  lRet        Retorno lógico da validação.

@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OsOLCheck(cFilAtual)
Local lRet      := .F.
Local lOperador := (SuperGetMV('MV_APDLOPE', .F., .F.).And.IntDL())
Local cFilOpera := SuperGetMV('MV_APDLFOP', .F., '')
Default cFilAtual  := ''

If (lRet := lOperador .And. !Empty(cFilAtual))
	lRet := !Empty(cFilOpera) .And. (cFilAtual==cFilOpera)
EndIf

Return(lRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} OsFilial
Funcao que faz o tratamento de filiais

@param   cAlias      Alias solicitado 
@param   cCodFil     Filial de destino

@return  cRetFil     Filial selecionada

@author  Henry Fila 
@since   10/12/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsFilial(cAlias,cCodFil)
Local cRetFil := ""

DEFAULT cCodFil := cFilAnt

If FWModeAccess(cAlias,3) == 'E' .And. !Empty(cCodFil)
	cRetFil := cCodFil
Else
	cRetFil := xFilial(cAlias)
EndIf

Return( cRetFil )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsFilQry
Funcao que faz o tratamento de filiais para query's

@param   cAlias      Alias solicitado 
@param   cFilQry     Expressao para ser colocada quando o alias for exclusivo (campo de ligacao)

@return  cExpFil     Expressao com a Filial desejada

@author  Henry Fila 
@since   10/12/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsFilQry(cAlias,cFilQry)
Local cExpFil := ""

DEFAULT cFilQry := ""
If FWModeAccess(cAlias,3) == 'E' .And. !Empty(cFilQry)
	cExpFil := cFilQry
Else
	cExpFil := "'"+xFilial(cAlias)+"'"
EndIf

Return( cExpFil )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsFilOpe
Funcao que retorna filial se excl.docto de saida gerado atraves de carga na filial do admin. operador logistico

@param   cCarga      Código da Carga
@param   cSeqCar     Sequencia da Carga
@param   cSeqEnt     Sequencia da Entrega
@param   cCliente    Cliente do Pedido
@param   cLoja       Loja do Cliente do Pedido
@param   cPedido     Código do Pedido

@return  cFilRet     Expressao com filial do admin. operador logistico

@author  Vicco 
@since   04/11/2009
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsFilOpe(cCarga,cSeqCar,cSeqEnt,cCliente,cLoja,cPedido)
Local aArea     := GetArea()
Local lOperador := (SuperGetMV("MV_APDLOPE", .F., .F.).And.IntDL())
Local cFilOpera := SuperGetMV("MV_APDLFOP", .F., "")
Local lFilPv    := (DAI->(FieldPos("DAI_FILPV")) > 0)
Local cFilRet   := xFilial("DAK")
Local cAliasDAI := "DAI"

If	lOperador .And. lFilPv .And. !Empty(cFilRet) .And. cFilOpera <> cFilAnt
	DbSelectArea("DAI")
	DAI->(DbSetOrder(1)) //DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
	cAliasDAI := GetNextAlias()
	cQuery := "SELECT 1 FROM "
	cQuery += RetSqlName("DAI")+ " DAI, "
	cQuery += " WHERE "
	cQuery += "DAI_FILIAL = '"+cFilOpera+"' AND "
	cQuery += "DAI_COD    = '"+cCarga   +"' AND "
	cQuery += "DAI_SEQCAR = '"+cSeqCar  +"' AND "
	cQuery += "DAI_SEQUEN = '"+cSeqEnt +"' AND "
	cQuery += "DAI_PEDIDO = '"+cPedido  +"' AND "
	cQuery += "DAI_CLIENT = '"+cCliente +"' AND "
	cQuery += "DAI_LOJA   = '"+cLoja    +"' AND "
	cQuery += "DAI_FILPV  = '"+xFilial("SC9")+"' AND "
	cQuery += "DAI.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAI,.T.,.T.)
	DbSelectArea(cAliasDAI)
	If	(cAliasDAI)->(!Eof())
		cFilRet := cFilOpera
	EndIf
	dbCloseArea()
EndIf
RestArea( aArea )

Return( cFilRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsSeqCar
Traz a proxima sequencia de carga

@param   cCarga      Código da Carga

@return  cNextSeq    Numero da proxima sequencia da carga

@author  Henry Fila 
@since   19/12/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsSeqCar(cCarga)
Local aArea      := GetArea()
Local aAreaDAK   := DAK->(GetArea())
Local cAliasDAK  := "DAK"
Local cNextSeq   := "01"
Local nSequencia := 1
Local cQuery     := ""

	cAliasDAK := "QRYDAK"

	cQuery := "SELECT DAK_FILIAL, DAK_COD "
	cQuery += "FROM " + RetSqlName("DAK") + " DAK "
	cQuery += "WHERE DAK_FILIAL ='" + xFilial("DAK") + "' "
	cQuery += "AND DAK_COD ='" + cCarga + "' "
	cQuery += "AND DAK.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDAK,.F.,.T.)

	dbSelectArea(cAliasDAK)

	While (cAliasDAK)->(!Eof())
		nSequencia++
		cNextSeq := StrZero(nSequencia,2)
		
		(cAliasDAK)->(dbSkip())
	EndDo

	(cAliasDAK)->(dbCloseArea())

	RestArea(aAreaDAK)
	RestArea(aArea)

Return (cNextSeq)

//--------------------------------------------------------------------
/*/{Protheus.doc} OsBlqExec
Identifica se a carga tem bloqueio de execucao de servico

@param   cCarga      Código da Carga
@param   cSeqCar     Sequencia da Carga

@return  lBloqueio   Indica se tem ou não tem execucao em andamento

@author  Henry Fila 
@since   19/12/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsBlqExec(cCarga,cSeqCar)
Local aArea     := GetArea()
Local aAreaDCF  := DCF->(GetArea())
Local bWhile    := {|| }
Local cQuery    := ""
Local cAliasDCF := "DCF"
Local lBloqueio := .F.
Local lCpoSeq   := (DCF->(FieldPos("DCF_SEQCAR")) > 0)

cAliasDCF := "TRBDCF"

cQuery := "SELECT DCF.DCF_FILIAL, DCF.DCF_CARGA, DCF.DCF_STSERV "
If lCpoSeq
	cQuery += ", DCF.DCF_SEQCAR "
EndIf
cQuery += "FROM "+RetSqlName("DCF") + " DCF "
cQuery += "WHERE DCF_FILIAL = '"+xFilial("DCF")+"' "
cQuery += "AND DCF_CARGA = '"+cCarga+"' AND "
If lCpoSeq
	cQuery += "DCF_SEQCAR = '"+cSeqCar+"' AND "
EndIf
cQuery += "DCF.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)

If lCpoSeq
	bWhile := {||	(cAliasDCF)->(!Eof()) .And. (cAliasDCF)->DCF_FILIAL == xFilial("DCF") .And. ;
					(cAliasDCF)->DCF_CARGA == cCarga .And. ;
					(cAliasDCF)->DCF_SEQCAR == cSeqCar }
Else
	bWhile := {||	(cAliasDCF)->(!Eof()) .And. (cAliasDCF)->DCF_FILIAL == xFilial("DCF") .And. ;
					(cAliasDCF)->DCF_CARGA == cCarga  }
EndIf

//-- Verifica se a carga ja existe execucao de servico em andamento
While Eval(bWhile)
	If (cAliasDCF)->DCF_STSERV == "2"
		lBloqueio := .T.
		Exit
	EndIf

	(cAliasDCF)->(dbSkip())
EndDo

DbSelectArea(cAliasDCF)
dbCloseArea()

DbSelectArea("DAK")
DbSetOrder(1)

RestArea( aAreaDCF )
RestArea( aArea    )

Return( lBloqueio )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsDtEntr
Funcao que retorna o melhor dia de entrega de acordo com o calendario de entregas

@param   cCodCal     Código do Calendário
@param   dDataEntr   Data da entrega

@return  dDataReal   Melhor data de entrega

@author  Henry Fila 
@since   27/07/2000
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsDtEntr(cCodCal,dDataEntr)
Local aArea    := GetArea()
Local aAreaDAA := DAA->(GetArea())
Local aAreaDAB := DAB->(GetArea())
Local aSemana  := {}

Local cDia     := SubStr(DtoS(dDataEntr),7,2)
Local dDataCalc:= DdataBase
Local dDataReal:= dDataBase

Local nSemana  := 0
Local nNumDia  := DoW(dDataEntr)
Local nX       := 0

Local lFound   := .F.
Local lSemana  := .T.

DAA->(DbSetOrder(1))
If DAA->(MsSeek(xFilial("DAA")+cCodCal))

	//-- Armazena as sequencias e as frequencias de entrega do calendario
	DAB->(DbSetOrder(1))
	If DAB->(MsSeek(xFilial("DAB")+DAA->DAA_CODIGO))
		//-- Verifica se o calendario eh por semana ou por dia
		lSemana := Iif(!Empty(DAB->DAB_FREQUE),.T.,.F.)
		While DAB->(!Eof()) .And. DAB->DAB_FILIAL == xFilial("DAA") .And. DAB->DAB_CODIGO == cCodCal
			AAdd(aSemana,Alltrim(Iif(!Empty(DAB->DAB_FREQUE),DAB->DAB_FREQUE,DAB->DAB_DATDIA)))
			DAB->(dbSkip())
		EndDo
	EndIf

	//-- Se o calendario for por semana
	If lSemana
		//-- Se for menor busca o mes anterior
		If cDia < DAA->DAA_DIA
			dDataCalc := StoD(SubStr(DtoS(FirstDay(dDataEntr)-1),1,6)+DAA->DAA_DIA)
		Else
			dDataCalc := dDataEntr
		EndIf

		nSemana := 1
		//-- Procura qual semana cai a data de entrega
		While dDataCalc < dDataEntr
			If DoW(dDataCalc) == 7
				nSemana++
				nSemana := If(nSemana > Len(aSemana),1,nSemana )
			EndIf
			dDataCalc := dDataCalc + 1
		EndDo

		//-- Acha a melhor data
		While !lFound
			For nX := 1 to Len(aSemana[nSemana])
				If nNumDia <= Val(SubStr(aSemana[nSemana],nX,1))
					dDataEntr := dDataEntr + (Val(SubStr(aSemana[nSemana],nX,1))-nNumDia)
					lFound    := .T.
					Exit
				EndIf
			Next

			If !lFound
				nSemana++
				nSemana   := If(nSemana > Len(aSemana),1,nSemana )
				dDataEntr := dDataEntr + ( 8 - nNumDia )
				nNumDia   := Dow(dDataEntr)
			EndIf
		Enddo

		dDataReal := dDataEntr

	//-- Se o calendario for por dia
	Else
		For nX := 1 to Len(aSemana)
			dDataCalc :=Ctod(Alltrim(aSemana[nX])+"/"+StrZero(Month(dDataEntr),2)+"/"+StrZero(Year(dDataEntr),4))

			If !Empty(dDataCalc) .And. dDataCalc >= dDataEntr
				dDataReal := dDataCalc
				lFound    := .T.
				Exit
			EndIf
		Next

		If !lFound
			dDataReal := CtoD(Alltrim(aSemana[1])+"/"+SubStr(DtoC(LastDay(dDataEntr)+1),4))

			If Empty(dDataReal)
				While Empty(dDataReal)
					dDataReal := CtoD(Alltrim(aSemana[1])+"/"+SubStr(DtoC(LastDay(dDataEntr)+1),4))
				Enddo
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDAA )
RestArea( aAreaDAB )
RestArea( aArea    )

Return( dDataReal )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsSrvTime
Funcao que retorna o tempo de descarga de um produto para um determinado clientegas

@param   cGrpVen     Grupo de Venda
@param   cCliente    Codigo do Cliente
@param   cLoja       Loja do Cliente
@param   nPeso       Peso
@param   nVolume     Volume

@return  cHora       Tempo de descarregamento

@author  Henry Fila 
@since   18/06/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsSrvTime(cGrpVen,cCliente,cLoja,nPeso,nVolume)
Local aArea    := GetArea()
Local aAreaDAF := DAF->(GetArea())
Local aAreaDAG := DAG->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aGrupos  := {}
Local cHora    := "0000:00"
Local nX       := 0

DEFAULT cGrpVen := Space(Len(SA1->A1_GRPVEN))
DEFAULT cCliente:= Space(Len(SA1->A1_COD))
DEFAULT cLoja   := Space(Len(SA1->A1_LOJA))

DAF->(DbSetOrder(2)) //DAF_FILIAL+DAF_CODIGO
If DAF->(!MsSeek(xFilial("DAF")+SPace(Len(SA1->A1_GRPVEN))+cCliente+cLoja))

	//-- Traz grupos superiores ao original para busca
	If cGrpVen <> Space(Len(SA1->A1_GRPVEN))
		MaCliStrUp( cGrpVen, aGrupos )
	EndIf

	//-- Ordena por niveis de grupos
	aGrupos := aSort(aGrupos,,,{|x,y| x[2] < y[2] } )
	For nX := 1 to Len(aGrupos)
		If DAF->(MsSeek(xFilial("DAF")+aGrupos[nX][1]+Space(Len(SA1->A1_COD))+Space(Len(SA1->A1_LOJA))))
			Exit
		EndIf
	Next nX
EndIf

//-- Traz os tempos de time service para os grupos
If DAF->(Found())
	DbSelectArea("DAG")
	DAG->(DbSetOrder(1))
	DAG->(MsSeek(xFilial("DAG")+DAF->DAF_CODIGO))
	While DAG->(!Eof()) .And. DAG->DAG_FILIAL == xFilial("DAG") .And. DAG->DAG_CODIGO == DAF->DAF_CODIGO
		If nPeso <= DAG->DAG_PESO .Or. nVolume <= DAG->DAG_VOLUME
			cHora := DAG->DAG_TEMPO
			Exit
		EndIf
		DAG->(dbSkip())
	EndDo
EndIf

RestArea( aAreaDAF )
RestArea( aAreaDAG )
RestArea( aAreaSB1 )
RestArea( aArea    )

Return( cHora )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsHasDa7
Função que verifica se o Cliente ou o CEP estão vinculados a algum registro de Pontos por Zona e Setor

@param   cFilCli    Codigo da filial da busca (caracter)
@param   cCliente   Codigo do Cliente         (caracter)
@param   cLoja      Loja                      (caracter)
@param   cAliasCli  Alias da tabela de Clientes (SA1) ou Fornecedor (SA2) (caracter)
@param   cRedesp    Códido do Redespachante

@return  aRecno     Registros correspondentes ao Cliente ou CEP (array)

@author  Henry Fila
@since   18/06/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsHasDa7(cFilCli,cCliente,cLoja,cAliasCli,cRedesp)
Local aAreaAnt  := GetArea()
Local cTipoCep  := SuperGetMv("MV_ROTCEP", .F.,"1")
Local cAlocPer  := SuperGetMv("MV_ALOCPER",.F.,"N")
Local cRotAtv   := SuperGetMv("MV_ROTATV",.F.,"2")
Local cQuery    := ""
Local cAliasQry := ""
Local aRecno    := {}

Default cAliasCli := "SA1"

	If cAliasCli = "SA4" //Buscar Rota por Transportador (SA4) caso for Redespachante. cAliasCli será enviado igual a "SA4" somente se o campo DAI_REDESP já tiver sido validado no outro fonte.
		OMSConout('Inicio OmsHasDa7 Query 1')	
		cQuery := "SELECT DA7.R_E_C_N_O_ RECNODA7"
		If cRotAtv == "1"
			cQuery +=   ",DA6.DA6_CODCAL"
		EndIf
		cQuery +=  " FROM "+RetSqlName("DA7")+" DA7"
		cQuery += " INNER JOIN "+RetSqlName("SA4")+" SA4"
		cQuery +=    " ON SA4.A4_FILIAL  = '"+OsFilial("SA4",cFilCli)+"'"
		cQuery +=   " AND SA4.A4_COD     = '"+cRedesp+"'"
		cQuery +=   " AND (SA4.A4_CEP <> ' ' AND SA4.A4_CEP >= DA7.DA7_CEPDE AND SA4.A4_CEP <= DA7.DA7_CEPATE)"
		cQuery +=   " AND SA4.D_E_L_E_T_ = ''"
		If cRotAtv == "1"
			cQuery += " INNER JOIN "+RetSqlName("DA6")+" DA6"
			cQuery +=    " ON DA6.DA6_FILIAL = '"+xFilial("DA6")+"'"
			cQuery +=   " AND DA6.DA6_PERCUR = DA7.DA7_PERCUR"
			cQuery +=   " AND DA6.DA6_ROTA   = DA7.DA7_ROTA"
			cQuery +=   " AND DA6.D_E_L_E_T_ = ' '"
		EndIf
		cQuery += " WHERE DA7.DA7_FILIAL = '"+xFilial("DA7")+"'"
		cQuery +=   " AND DA7.D_E_L_E_T_ = ' '"
		If cAliasCli == "SA1" .And. cTipoCep == "2"
			cQuery += " ORDER BY ORD_CEPENT"
		EndIf
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		OMSConout('Fim OmsHasDa7 Query 1')	
		While !(cAliasQry)->(Eof())
			If cRotAtv == "2"
				AAdd(aRecno,(cAliasQry)->RECNODA7)
				Exit
			Else
				If Empty((cAliasQry)->DA6_CODCAL) .Or. (!Empty((cAliasQry)->DA6_CODCAL) .And. OmsDtEntr((cAliasQry)->DA6_CODCAL,dDataBase) == dDataBase)
					AAdd(aRecno,(cAliasQry)->RECNODA7)
					If cAlocPer == "N"
						Exit
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())	
	Else
		OMSConout('Inicio OmsHasDa7 Query 2')	
		cQuery := "SELECT DA7.R_E_C_N_O_ RECNODA7"
		If cRotAtv == "1"
			cQuery +=   ",DA6.DA6_CODCAL"
		EndIf
		cQuery +=  " FROM "+RetSqlName("DA7")+" DA7"
		cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1"
		cQuery +=    " ON SA1.A1_FILIAL  = '"+OsFilial("SA1",cFilCli)+"'"
		cQuery +=   " AND SA1.A1_COD     = DA7.DA7_CLIENT"
		cQuery +=   " AND SA1.A1_LOJA    = DA7_LOJA"
		cQuery +=   " AND SA1.D_E_L_E_T_ = ' '"
		If cRotAtv == "1"
			cQuery += " INNER JOIN "+RetSqlName("DA6")+" DA6"
			cQuery +=    " ON DA6.DA6_FILIAL = '"+xFilial("DA6")+"'"
			cQuery +=   " AND DA6.DA6_PERCUR = DA7.DA7_PERCUR"
			cQuery +=   " AND DA6.DA6_ROTA   = DA7.DA7_ROTA"
			cQuery +=   " AND DA6.D_E_L_E_T_ = ' '"
		EndIf
		cQuery += " WHERE DA7.DA7_FILIAL = '"+xFilial("DA7")+"'"
		cQuery +=   " AND DA7.DA7_CLIENT = '"+cCliente+"'"
		cQuery +=   " AND DA7.DA7_LOJA   = '"+cLoja+"'"
		cQuery +=   " AND DA7.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		OMSConout('Fim OmsHasDa7 Query 2')	
		If !(cAliasQry)->(Eof())
			While !(cAliasQry)->(Eof())
				OMSConout('While OmsHasDA7')	
				If cRotAtv == "2"
					AAdd(aRecno,(cAliasQry)->RECNODA7)
					OMSConout('Exit 1 OmsHasDa7')	
					Exit
				Else
					If Empty((cAliasQry)->DA6_CODCAL) .Or. (!Empty((cAliasQry)->DA6_CODCAL) .And. OmsDtEntr((cAliasQry)->DA6_CODCAL,dDataBase) == dDataBase)
						AAdd(aRecno,(cAliasQry)->RECNODA7)
						If cAlocPer == "N"
							OMSConout('Exit 2 OmsHasDA7')	
							Exit
						EndIf
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		Else
			OMSConout('Inicio OmsHasDa7 Query 3')	
			(cAliasQry)->(DbCloseArea())
			cQuery := "SELECT DA7.R_E_C_N_O_ RECNODA7"
			If cRotAtv == "1"
				cQuery +=   ",DA6.DA6_CODCAL"
			EndIf
			If cAliasCli == "SA1" .And. cTipoCep == "2"
				// Regra para priorizar o CEP de entrega
				cQuery +=  ", CASE WHEN (SA1.A1_CEPE <> ' '"
				cQuery +=              " AND SA1.A1_CEPE >= DA7.DA7_CEPDE"
				cQuery +=              " AND SA1.A1_CEPE <= DA7.DA7_CEPATE)"
				cQuery +=        " THEN 1 ELSE 9 END ORD_CEPENT"
			EndIf
			cQuery +=  " FROM "+RetSqlName("DA7")+" DA7"
			If cAliasCli == "SA1"
				cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1"
				cQuery +=    " ON SA1.A1_FILIAL  = '"+OsFilial("SA1",cFilCli)+"'"
				cQuery +=   " AND SA1.A1_COD     = '"+cCliente+"'"
				cQuery +=   " AND SA1.A1_LOJA    = '"+cLoja+"'"
				cQuery +=   " AND SA1.D_E_L_E_T_ = ' '"
				If cTipoCep == "2"
					// Prioriza CEP de Entrega
					cQuery += " AND ((SA1.A1_CEPE <> ' '"
					cQuery +=       " AND SA1.A1_CEPE >= DA7.DA7_CEPDE"
					cQuery +=       " AND SA1.A1_CEPE <= DA7.DA7_CEPATE)"
					cQuery +=   " OR (SA1.A1_CEP  <> ' '"
					cQuery +=       " AND SA1.A1_CEP  >= DA7.DA7_CEPDE"
					cQuery +=       " AND SA1.A1_CEP  <= DA7.DA7_CEPATE))"
				ElseIf cTipoCep == "3"
					// Somente CEP de Entrega
					cQuery += " AND (SA1.A1_CEPE <> ' '"
					cQuery +=      " AND SA1.A1_CEPE >= DA7.DA7_CEPDE"
					cQuery +=      " AND SA1.A1_CEPE <= DA7.DA7_CEPATE)"
				Else
					// Somente CEP do Cliente
					cQuery += " AND (SA1.A1_CEP  <> ' '"
					cQuery +=      " AND SA1.A1_CEP  >= DA7.DA7_CEPDE"
					cQuery +=      " AND SA1.A1_CEP  <= DA7.DA7_CEPATE)"
				EndIf
			Else
				cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2"
				cQuery +=    " ON SA2.A2_FILIAL  = '"+OsFilial("SA2",cFilCli)+"'"
				cQuery +=   " AND SA2.A2_COD     = '"+cCliente+"'"
				cQuery +=   " AND SA2.A2_LOJA    = '"+cLoja+"'"
				cQuery +=   " AND (SA2.A2_CEP <> ' ' AND SA2.A2_CEP >= DA7.DA7_CEPDE AND SA2.A2_CEP <= DA7.DA7_CEPATE)"
				cQuery +=   " AND SA2.D_E_L_E_T_ = ''"
			EndIf
			If cRotAtv == "1"
				cQuery += " INNER JOIN "+RetSqlName("DA6")+" DA6"
				cQuery +=    " ON DA6.DA6_FILIAL = '"+xFilial("DA6")+"'"
				cQuery +=   " AND DA6.DA6_PERCUR = DA7.DA7_PERCUR"
				cQuery +=   " AND DA6.DA6_ROTA   = DA7.DA7_ROTA"
				cQuery +=   " AND DA6.D_E_L_E_T_ = ' '"
			EndIf
			cQuery += " WHERE DA7.DA7_FILIAL = '"+xFilial("DA7")+"'"
			cQuery +=   " AND DA7.D_E_L_E_T_ = ' '"
			If cAliasCli == "SA1" .And. cTipoCep == "2"
				cQuery += " ORDER BY ORD_CEPENT"
			EndIf
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			OMSConout('Fim OmsHasDa7 Query 3')	
			While !(cAliasQry)->(Eof())
				If cRotAtv == "2"
					AAdd(aRecno,(cAliasQry)->RECNODA7)
					Exit
				Else
					If Empty((cAliasQry)->DA6_CODCAL) .Or. (!Empty((cAliasQry)->DA6_CODCAL) .And. OmsDtEntr((cAliasQry)->DA6_CODCAL,dDataBase) == dDataBase)
						AAdd(aRecno,(cAliasQry)->RECNODA7)
						If cAlocPer == "N"
							Exit
						EndIf
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	Endif

RestArea(aAreaAnt)
Return aRecno

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsVldCal
Funcao que verifica se os calendarios possuem integridade

@param   cCalSup     Código de Calendário 
@param   cCalComp    Código de Calendário 

@return  lRet        Indica se os calendários possuem ou não possuem integridade

@author  Henry Fila 
@since   18/06/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsVldCal(cCalSup,cCalComp)

Local aArea    := GetArea()
Local aAreaDAA := DAA->(GetArea())
Local aAreaDAB := DAB->(GetArea())
Local aCal1    := {}
Local aCal2    := {}

Local cDiaSup  := ""
Local cDiaComp := ""
Local cTipoSup := ""
Local cTipoComp:= ""

Local lRet  := .T.
Local nX	:= 0
Local nY    := 0

DAA->(DbSetOrder(1))
If DAA->(MsSeek(xFilial("DAA")+cCalSup))

	cDiaSup  := DAA->DAA_DIA
	cTipoSup := DAA->DAA_TIPO

	DAB->(DbSetOrder(1))
	If DAB->(MsSeek(xFilial("DAB")+DAA->DAA_CODIGO))
		While DAB->(!Eof()) .And. DAB->DAB_FILIAL == xFilial("DAB") .And. DAB->DAB_CODIGO == DAA->DAA_CODIGO
			AAdd(aCal1,{DAB->DAB_NUMSEM,Iif(cTipoSup == "1",DAB->DAB_FREQUE, DAB->DAB_DATDIA)})
			DAB->(dbSkip())
		Enddo
	EndIf

	DAA->(DbSetOrder(1))
	If DAA->(MsSeek(xFilial("DAA")+cCalComp))

		cDiaComp  := DAA->DAA_DIA
		cTipoComp := DAA->DAA_TIPO

		DAB->(DbSetOrder(1))
		If DAB->(MsSeek(xFilial("DAB")+DAA->DAA_CODIGO))
			While DAB->(!Eof()) .And. DAB->DAB_FILIAL == xFilial("DAB") .And. DAB->DAB_CODIGO == DAA->DAA_CODIGO
				AAdd(aCal2,{DAB->DAB_NUMSEM,Iif(cTipoComp == "1",DAB->DAB_FREQUE, DAB->DAB_DATDIA)	})
				DAB->(dbSkip())
			EndDo
		EndIf
	EndIf

	//-- Verifica se os calendarios sao da mesma integridade
	If ( (cDiaSup == cDiaComp) .Or. (Len(aCal1) == Len(aCal2)) ) .And. ( cTipoSup == cTipoComp  )
		//-- Verifica se o calendario eh semanal
		If cTipoSup == "1" .And. cTipoComp == "1"
			For nX := 1 to Len(aCal2)
				For nY := 1 to Len(Alltrim(aCal2[nX][2]))
					cDia := SubStr(Alltrim(aCal2[nX][2]),nY,1)

					If !(cDia $ aCal1[nX][2])
						nX := Len(aCal2)
						nY := Len(aCal2[nX][2])
						lRet := .F.
					EndIf
				Next nY
			Next nX
		Else
			//-- Verifica se o calendario eh mensal
			For nX := 1 to Len(aCal2)
				If Ascan(aCal1,{|x| Alltrim(x[2]) == Alltrim(aCal2[nX][2]) }) == 0
					lRet := .F.
				EndIf
			Next nX
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

RestArea( aAreaDAA )
RestArea( aAreaDAB )
RestArea( aArea    )

Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsHasCg
Funcao que verifica se existe carga montada para o pedido

@param   cPedido     Código do Pedido
@param   cItem       Código do Item

@return  lRet        Indica se existe ou se não existe Carga

@author  Henry Fila 
@since   18/06/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsHasCg(cPedido,cItem)

Local aArea    := GetArea()
Local aAreaSC9 := SC9->(GetArea())

Local cAliasSC9:= "SC9"

Local lRet     := .F.
Local lOmsPedCg:= ExistBlock("OMSPEDCG")
Local lRetPE   := .F.

Local cQuery   := ""
Local lIntTPR   := SuperGetMV("MV_ROTAINT",,.F.)  //Integração Rota Inteligente
Local cRoteiri := ""

Default cItem := ""

cAliasSC9 := "QRYSC9"

cQuery := "SELECT COUNT(*) RECSC9 FROM "
cQuery += RetSqlName("SC9") + " SC9 "
cQuery += " WHERE "
cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND "
cQuery += "C9_PEDIDO = '"+cPedido+"' AND "
If !Empty(cItem)
	cQuery += "C9_ITEM = '"+cItem+"' AND "
EndIf
cQuery += "C9_CARGA <> '"+Space(Len(SC9->C9_CARGA))+"' AND "
cQuery += "SC9.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

If (cAliasSC9)->RECSC9 > 0
	lRet := .T.
EndIf
DbSelectArea(cAliasSC9)
dbCloseArea()
DbSelectArea("SC9")

If lOmsPedCg
	lRetPE:= ExecBlock("OMSPEDCG",.F.,.F.,{cPedido,lRet})
	If ValType(lRetPE) == "L"
		lRet:= lRetPE
	EndIf
EndIf

If lRet .And. lIntTPR .And. FindFunction('OMSROTEIRI') .And. FindFunction('OMSTPRDFUN')
	cRoteiri := OMSROTEIRI()
	If cRoteiri = '2'
		lRet := OMSTPRDFUN(cPedido)
	EndIf
EndIf

RestArea( aAreaSC9 )
RestArea( aArea    )

Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsJanEntr
Valida janela de entregas do cliente

@param   cGrpVen     Codigo do grupo do cliente
@param   cCliente    Codigo do cliente
@param   cLoja       Loja do cliente
@param   cHora       Horario a ser pesquisado na janela
@param   cVeiculo    Veiculo a ser pesquisado na janela
@param   dData       Data da item a ser pesquisado
@param   cZona       Zona a ser pesquisada
@param   cSetor      Setor a ser pesquisado

@return  nRetorno    Valor relacionado a validação da janela de entregas

@author  Henry Fila 
@since   12/04/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsJanEntr(cGrpVen,cCliente,cLoja,cHora,cVeiculo,dData,cZona,cSetor)
Local aGrupos    := {}
Local aArea      := GetArea()
Local aAreaDAE   := DAE->(GetArea())
Local aAreaDA5   := DA5->(GetArea())
Local aAreaDA6   := DA6->(GetArea())
Local aAreaDA7   := DA7->(GetArea())
Local aAreaDA8   := DA8->(GetArea())
Local aAreaDA9   := DA6->(GetArea())
Local cGrpVei    := ""
Local cQuery     := ""
Local cAliasDAE  := "DAE"
Local nRetorno   := 1
Local nRetAnt    := 1
Local nX         := 0
Local lBlqCalend := .F.
Local lBlqHora   := .F.
Local lBlqVei    := .F.
Local cSemZona   := Replicate("9",Len(DA7->DA7_PERCUR))
Local cSemSetor  := Replicate("9",Len(DA7->DA7_ROTA))

DEFAULT cGrpVen := Space(Len(SA1->A1_GRPVEN))
DEFAULT cCliente:= Space(Len(SA1->A1_COD))
DEFAULT cLoja   := Space(Len(SA1->A1_LOJA))
DEFAULT cZona   := ""
DEFAULT cSetor  := ""

DA3->(DbSetOrder(1))
If DA3->(MsSeek(xFilial("DA3")+cVeiculo))
	cGrpVei := DA3->DA3_CODGRU
EndIf

//-- Verifica se existe janela de entrega para o cliente ou grupo
DAD->(DbSetOrder(2))
If	DAD->(!MsSeek(xFilial("DAD")+Space(Len(SA1->A1_GRPVEN))+cCliente+cLoja))
	//Traz grupos superiores ao original para busca
	If cGrpVen <> Space(Len(SA1->A1_GRPVEN))
		MaCliStrUp( cGrpVen, aGrupos )
	EndIf
	//Ordena por niveis de grupos
	aGrupos := aSort(aGrupos,,,{|x,y| x[2] < y[2] } )
	For nX := 1 to Len(aGrupos)
		If DAD->(MsSeek(xFilial("DAD")+aGrupos[nX][1]+Space(Len(SA1->A1_COD))+Space(Len(SA1->A1_LOJA))))
			Exit
		EndIf
	Next
EndIf

//Se encontrar regras de entrega verifica se a condicao esta entre alguma
If	DAD->(Found())
	nRetorno := 0
	cAliasDAE := "QRYDAE"
	cQuery := "SELECT DAE_FILIAL,DAE_CODIGO,DAE_HRINI,DAE_HRFIM,DAE_CODVEI,DAE_GRUVEI,DAE_REGRA,DAE_CODCAL"
	cQuery += " FROM "+ RetSqlName("DAE") + " DAE "
	cQuery += " WHERE "
	cQuery += "DAE_FILIAL = '"+xFilial("DAE")+"' AND "
	cQuery += "DAE_CODIGO = '"+DAD->DAD_CODIGO+"' AND "
	cQuery += "DAE.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+SqlOrder(DAE->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAE,.T.,.T.)
	While (cAliasDAE)->(!Eof() .And. DAE_FILIAL+DAE_CODIGO == xFilial("DAE")+DAD->DAD_CODIGO)
		lBlqCalend := .F.
		lBlqVei    := .F.
		lBlqHora   := .F.
		//Verifica restricao por calendário
		If !Empty((cAliasDAE)->DAE_CODCAL)
			If	dData <> OmsDtEntr((cAliasDAE)->DAE_CODCAL,dData)
				lBlqCalend := (cAliasDAE)->DAE_REGRA == "1"
			Else
				lBlqCalend := (cAliasDAE)->DAE_REGRA == "2"
			EndIf
		EndIf
		//Verifica restricao por veiculo
		Do Case
			Case !Empty((cAliasDAE)->DAE_CODVEI) .And. !Empty(cVeiculo)
				If	cVeiculo <> (cAliasDAE)->DAE_CODVEI
					lBlqVei := (cAliasDAE)->DAE_REGRA == "1"
				Else
					lBlqVei := (cAliasDAE)->DAE_REGRA == "2"
				EndIf
			Case !Empty((cAliasDAE)->DAE_GRUVEI) .And. !Empty(cGrpVei)
				If	cGrpVei <> (cAliasDAE)->DAE_GRUVEI
					lBlqVei := (cAliasDAE)->DAE_REGRA == "1"
				Else
					lBlqVei := (cAliasDAE)->DAE_REGRA == "2"
				EndIf
		EndCase
		//Verifica janela de horarios da regra
		If !Empty((cAliasDAE)->DAE_HRINI) .And. !Empty((cAliasDAE)->DAE_HRFIM)
			If	cHora >= (cAliasDAE)->DAE_HRINI .And. cHora <= (cAliasDAE)->DAE_HRFIM
				lBlqHora := (cAliasDAE)->DAE_REGRA == "2"
			Else
				lBlqHora := (cAliasDAE)->DAE_REGRA == "1"
			EndIf
		EndIf
		//Analisa o codigo de retorno
		Do Case
			Case lBlqCalend
				nRetorno := 4
			Case lBlqVei
				nRetorno := 2
			Case lBlqHora
				nRetorno := 3
			Otherwise
				nRetorno := 1
		EndCase
		If	nRetorno > nRetAnt
			nRetAnt  := nRetorno
		Else
			nRetorno := nRetAnt
		EndIf
		DbSelectArea(cAliasDAE)
		(cAliasDAE)->(dbSkip())
	EndDo
	DbSelectArea(cAliasDAE)
	dbCloseArea()
	DbSelectArea("DAE")
EndIf
If	nRetorno <= 1
	If !Empty(cZona) .And. !Empty(cSetor) .And. !(cZona == cSemZona .And. cSetor == cSemSetor)
		nRetorno := AvalRestSet(dData,cZona,cSetor) // Avalia restrições da rota x setor
	Else
		nRetorno := AvalRestCli(cCliente,cLoja,dData) // Avalia restrições do cliente
	EndIf
EndIf
RestArea( aArea    )
RestArea( aAreaDAE )
RestArea( aAreaDA5 )
RestArea( aAreaDA6 )
RestArea( aAreaDA7 )
RestArea( aAreaDA8 )
RestArea( aAreaDA9 )

Return( nRetorno )

//--------------------------------------------------------------------
/*/{Protheus.doc} AvalRestSet STATIC
Avalia restrições do setor através do código de calendário vinculado ao cadastro

@param   dData       Data da item a ser pesquisado
@param   cZona       Zona a ser pesquisada
@param   cSetor      Setor a ser pesquisado

@return  nRetorno    Valor relacionado a validação da janela de entregas

@author  Henry Fila 
@since   12/04/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AvalRestSet(dData,cZona,cSetor)
Local nRetorno := 1

	cZona := PadR(cZona,TamSx3("DA6_PERCUR")[1])
	cSetor := PadR(cSetor,TamSx3("DA6_ROTA")[1])

	DA6->(DbSetOrder(1)) //DA6_FILIAL+DA6_PERCUR+DA6_ROTA
	If	DA6->(MsSeek(xFilial("DA6")+cZona+cSetor))
		If !Empty(DA6->DA6_CODCAL)
			If	dData <> OmsDtEntr(DA6->DA6_CODCAL,dData)
				nRetorno := 4
			EndIf
		Else
			//Caso nao exista calendario para o setor verfica se existe para a zona
			DA5->(DbSetOrder(1)) //DA5_FILIAL+DA5_COD
			If	DA5->(MsSeek(xFilial("DA5")+DA6->DA6_PERCUR))
				If !Empty(DA5->DA5_CODCAL)
					If	dData <> OmsDtEntr(DA5->DA5_CODCAL,dData)
						nRetorno := 4
					EndIf
				Else
					//Caso nao exista calendario para a zona  verfica se existe para a rota
					DA9->(DbSetOrder(2)) //DA9_FILIAL+DA9_PERCUR+DA9_ROTA+DA9_ROTEIR
					If	DA9->(MsSeek(xFilial("DA9")+DA6->DA6_PERCUR+DA6->DA6_ROTA))
						DA8->(DbSetOrder(1)) //DA8_FILIAL+DA8_COD
						If	DA8->(MsSeek(xFilial("DA8")+DA9->DA9_ROTEIR))
							If !Empty(DA8->DA8_CODCAL)
								If	dData <> OmsDtEntr(DA8->DA8_CODCAL,dData)
									nRetorno := 4
								EndIf
							Else
								nRetorno := 1
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return nRetorno

//--------------------------------------------------------------------
/*/{Protheus.doc} AvalRestCli STATIC
Avalia restrições do cliente através do código de calendário vinculado ao cadastro do setor

@param   cCliente    Código do Cliente
@param   cLoja       Loja do Cliente
@param   dData       Data da item a ser pesquisado

@return  nRetorno    Valor relacionado a validação da janela de entregas

@author  Henry Fila 
@since   12/04/2002
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AvalRestCli(cCliente,cLoja,dData)
Local nRetorno := 1 
	//Caso nao exista regra para o cliente verifica se existe para o setor
	DA7->(DbSetOrder(2)) //DA7_FILIAL+DA5_CLIENT+DA7_LOJA+DA7_PERCUR+DA7_ROTA
	If	DA7->(MsSeek(xFilial("DA7")+cCliente+cLoja))
		AvalRestSet(dData,DA7->DA7_PERCUR,DA7->DA7_ROTA)
	EndIf
Return nRetorno

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsVeiDisp
Verifica se um veiculo esta disponivel

@param   cVeiculo    Código do Veículo
@param   dDtIni      Data de inicio para validação
@param   cHoraIni    Hora de inicio para validação
@param   dDtFim      Data final para validação
@param   cHoraFim    Hora final para validação
@param   cCarga      Código da carga
@param   cSeqCar     Sequencia da carga

@return  lRet        Indica se o veículo esta ou não disponivel

@author  Henry Fila 
@since   19/03/2003
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsVeiDisp(cVeiculo,dDtIni,cHoraIni,dDtFim,cHoraFim,cCarga,cSeqCar)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDAN := GetNextAlias()

Default cCarga  := ""
Default cSeqCar := ""

	cQuery := "SELECT 1"
	cQuery +=  " FROM "+RetSqlName("DAN")+" DANA"
	cQuery += " WHERE DANA.DAN_FILIAL  = '"+xFilial("DAN")+"'"
	cQuery +=   " AND DANA.DAN_CODVEI  = '"+cVeiculo+"'"
	cQuery +=   " AND ((  DANA.DAN_DATINI <= '"+DtoS(dDtIni)+"' AND DANA.DAN_HORINI <= '"+cHoraIni+"'"
	cQuery +=       " AND DANA.DAN_DATFIM >= '"+DtoS(dDtIni)+"' AND DANA.DAN_HORFIM >= '"+cHoraIni+"')"
	cQuery +=    " OR  (  DANA.DAN_DATINI <= '"+DtoS(dDtFim)+"' AND DANA.DAN_HORINI <= '"+cHoraFim+"'"
	cQuery +=       " AND DANA.DAN_DATFIM >= '"+DtoS(dDtFim)+"' AND DANA.DAN_HORFIM >= '"+cHoraFim+"'))"
	cQuery +=   " AND DANA.D_E_L_E_T_ = ' '"
	If !Empty(cCarga) // Não deve considerar a carga em questão
		cQuery += " AND NOT EXISTS (SELECT 1"
		cQuery +=                   " FROM "+RetSqlName("DAN")+" DANB"
		cQuery +=                  " WHERE DANB.DAN_FILIAL = DANA.DAN_FILIAL"
		cQuery +=                    " AND DANB.DAN_CODVEI = DANA.DAN_CODVEI"
		cQuery +=                    " AND DANB.DAN_CODCAR = '"+cCarga+"'"
		cQuery +=                    " AND DANB.DAN_SEQCAR = '"+cSeqCar+"'"
		cQuery +=                    " AND DANB.DAN_DATINI = DANA.DAN_DATINI"
		cQuery +=                    " AND DANB.DAN_HORINI = DANA.DAN_HORINI"
		cQuery +=                    " AND DANB.DAN_DATFIM = DANA.DAN_DATFIM"
		cQuery +=                    " AND DANB.DAN_HORFIM = DANA.DAN_HORFIM"
		cQuery +=                    " AND DANB.D_E_L_E_T_ = ' ')"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAN,.T.,.T.)
	If !(cAliasDAN)->(Eof())
		lRet := .F.
	EndIf
	(cAliasDAN)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsTimeCg
Esta rotina tem como objetivo retornar os dados das cargas com horarios de entrega

@param   cCarga      Código da carga
@param   cSeqCar     Sequencia da carga
@param   cVeiculo    Código do Veículo

@return  aCargas     Array com os dados da carga

@author  Henry Fila 
@since   19/03/2003
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsTimeCg(cCarga,cSeqCar,cVeiculo)
Local aArea     := GetArea()
Local aAreaDAK  := DAK->(GetArea())
Local aAreaDAI  := DAI->(GetArea())
Local aCargas   := {}
Local aItens    := {}
Local aStruDAK  := DAK->(dbStruct())
Local aStruDAI  := DAI->(dbStruct())

Local bWhile    := {||}

Local cAliasDAK := "DAK"
Local cAliasDAI := "DAI"
Local cAliasDA3 := "DA3"
Local cQuery    := ""
Local cCargaCtl := ""
Local cSeqCarCtl:= ""

Local nHrSaid   := 0

Local lSkip     := .F.

Local nX	:= 0

DEFAULT cCarga  := ""
DEFAULT cSeqCar := ""
DEFAULT cVeiculo:= ""

DAK->(dbCommit())

cAliasDAK := "QRYDAK"
cAliasDAI := "QRYDAK"
cAliasDA3 := "QRYDAK"

cQuery := "SELECT DAK_COD, DAK_SEQCAR, DAK_DATA, DAK_HRSTAR, DAK_CAMINH, DAK.R_E_C_N_O_ DAKREC, "
cQuery += "DAI_FILIAL, DAI_COD, DAI_SEQCAR, DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, DAI_SEQUEN, DAI_DTCHEG, "
cQuery += "DAI_CHEGAD, DAI_TMSERV, DAI_DTSAID, DAI_PESO, DAI_CAPVOL "
If !Empty(cVeiculo)
	cQuery += ",DA3_DESC "
EndIf
cQuery += " FROM "
cQuery += RetSqlName("DAK")+ " DAK, "
cQuery += RetSqlName("DAI")+ " DAI  "
If !Empty(cVeiculo)
	cQuery += ", "+ RetSqlName("DA3")+ " DA3  "
EndIf
cQuery += " WHERE "
cQuery += "DAK_FILIAL = '"+xFilial("DAK")+"' AND "
cQuery += "DAK_ACECAR = '2' AND "
cQuery += "DAK_ACEFIN = '2' AND "
cQuery += "DAK_ACEVAS = '2' AND "
cQuery += "DAK.D_E_L_E_T_ = ' ' AND "

If !Empty(cCarga) .And. !Empty(cSeqCar)
	cQuery += "DAK_COD    = '"+cCarga+"'AND "
	cQuery += "DAK_SEQCAR = '"+cSeqCar+"' AND "
EndIf

If !Empty(cVeiculo)
	cQuery += "DAK_CAMINH = '"+cVeiculo+"' AND "
	cQuery += "DA3_FILIAL = '"+xFilial("DA3")+"' AND "
	cQuery += "DA3_COD    = DAK_CAMINH AND "
	cQuery += "DA3.D_E_L_E_T_ = ' ' AND "
EndIf

cQuery += "DAI_FILIAL = '"+xFilial("DAI")+"' AND "
cQuery += "DAI_COD    = DAK_COD AND "
cQuery += "DAI_SEQCAR = DAK_SEQCAR AND "
cQuery += "DAI.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY DAK_COD,DAK_SEQCAR, DAI_SEQUEN"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAK,.T.,.T.)

For nX := 1 To Len(aStruDAK)
	If aStruDAK[nX][2]!="C" .And. FieldPos(aStruDAK[nX][1])>0
		TcSetField(cAliasDAK,aStruDAK[nX][1],aStruDAK[nX][2],aStruDAK[nX][3],aStruDAK[nX][4])
	EndIf
Next nX
For nX := 1 To Len(aStruDAI)
	If aStruDAI[nX][2]!="C" .And. FieldPos(aStruDAI[nX][1])>0
		TcSetField(cAliasDAI,aStruDAI[nX][1],aStruDAI[nX][2],aStruDAI[nX][3],aStruDAI[nX][4])
	EndIf
Next nX

bWhile := {|| (cAliasDAK)->(!Eof()) }

While Eval(bWhile)

	aItens     := {}
	cCargaCtl  := (cAliasDAI)->DAI_COD
	cSeqCarCtl := (cAliasDAI)->DAI_SEQCAR
	lSkip      := .F.

	//-- Estrutura do array de retorno
	//--             [1] - Codigo da carga
	//--             [2] - Sequencia da carga
	//--             [3] - Veiculo da carga
	//--             [4] - Descricao do veiculo
	//--             [5] - Recno
	//--             [6] - Data da Carga
	//--             [7] - Hora de inicio da entrega
	//--             [8] - Data de Saida final da carga
	//--             [9] - Hora de Saida final da carga
	//--             [10] - SubArray com os itens da carga
	//--                   [1] - Sequencia de entrega
	//--                   [2] - Pedido
	//--                   [3] - Cliente
	//--                   [4] - Loja
	//--                   [5] - Data de Chegada
	//--                   [6] - Hora de Chegada
	//--                   [7] - Time Service
	//--                   [8] - Data Saida
	//--                   [9] - Hora Saida
	//--                   [10] - Peso
	//--                   [11] - Capacidade volumetrica

	AAdd(aCargas,{	(cAliasDAK)->DAK_COD,;
					(cAliasDAK)->DAK_SEQCAR,;
					(cAliasDAK)->DAK_CAMINH,;
					Iif(Empty(cVeiculo),"",(cAliasDA3)->DA3_DESC),;
					(cAliasDAK)->DAKREC,;
					(cAliasDAK)->DAK_DATA,;
					(cAliasDAK)->DAK_HRSTAR,,,});

	While (cAliasDAI)->(!Eof()) .And.	(cAliasDAI)->DAI_FILIAL == xFilial("DAI") .And. ;
										(cAliasDAI)->DAI_COD    == cCargaCtl      .And. ;
										(cAliasDAI)->DAI_SEQCAR == cSeqCarCtl

		nHrSaid := HoratoInt((cAliasDAI)->DAI_CHEGAD,2)+HoratoInt((cAliasDAI)->DAI_TMSERV,4)

		Do Case
			Case nHrSaid > 24
				nHrSaid -= 24
			Case nHrSaid == 24
				nHrSaid := 0
		EndCase

		aCargas[Len(aCargas)][8] := (cAliasDAI)->DAI_DTSAID
		aCargas[Len(aCargas)][9] := IntToHora(nHrSaid)

		AAdd(aItens, {(cAliasDAI)->DAI_SEQUEN,;
						(cAliasDAI)->DAI_PEDIDO,;
						(cAliasDAI)->DAI_CLIENT,;
						(cAliasDAI)->DAI_LOJA,;
						(cAliasDAI)->DAI_DTCHEG,;
						(cAliasDAI)->DAI_CHEGAD,;
						(cAliasDAI)->DAI_TMSERV,;
						(cAliasDAI)->DAI_DTSAID,;
						IntToHora(nHrSaid),;
						(cAliasDAI)->DAI_PESO,;
						(cAliasDAI)->DAI_CAPVOL})
		(cAliasDAI)->(dbSkip())
	EndDo

	aCargas[Len(aCargas)][10] := aItens

	If !lSkip
		(cAliasDAK)->(dbSkip())
	EndIf
EndDo

DbSelectArea(cAliasDAK)
dbCloseArea()

RestArea( aAreaDAK )
RestArea( aAreaDAI )
RestArea( aArea    )

Return( aCargas )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsVAgenda
Esta rotina tem como objetivo alocar o veiculo

@param   cCarga      Código da carga
@param   cSeqCar     Sequencia da carga
@param   cVeiculo    Código do Veículo
@param   nEvento     Indica qual o evento sera efetuado sendo:
						1 - Aloca o veiculo com a carga
						2 - Desaloca o veiculo da carga

@return  Null

@author  Henry Fila 
@since   19/03/2003
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsVAgenda(cCarga,cSeqCar,cVeiculo,nEvento)
Local aArea    := GetArea()
Local aAreaDAN := DAN->(GetArea())
Local aAreaDA3 := DA3->(GetArea())
Local aCargas  := {}

	If Empty(cVeiculo)
		Return
	EndIf

	Do Case

		// Aloca o veículo
		Case nEvento == 1

			DA3->(DbSetOrder(1))
			If DA3->(DbSeek(xFilial("DA3")+cVeiculo))
				// Busca dados da carga com horários de entrada e saída
				aCargas := OmsTimeCg(cCarga,cSeqCar)
				// Verifica a disponibilidade do veículo
				If !Empty(aCargas) .And. OmsVeiDisp(cVeiculo,aCargas[1][6],aCargas[1][7],aCargas[1][8],aCargas[1][9])
					// Atualiza agenda de veículos
					RecLock("DAN",.T.)
					DAN->DAN_FILIAL := xFilial("DAN")
					DAN->DAN_CODVEI := cVeiculo
					DAN->DAN_CODCAR := cCarga
					DAN->DAN_SEQCAR := cSeqCar
					DAN->DAN_DATINI := aCargas[1][6]
					DAN->DAN_HORINI := aCargas[1][7]
					DAN->DAN_DATFIM := aCargas[1][8]
					DAN->DAN_HORFIM := aCargas[1][9]
					DAN->DAN_TPALOC := "1"
					DAN->(MsUnlock())
					// Atualiza status do veículo
					RecLock("DA3",.F.)
					DA3->DA3_STATUS := "3"
					DA3->(MsUnlock())
				EndIf
			EndIf

		// Desaloca o veículo
		Case nEvento == 2

			DA3->(DbSetOrder(1))
			If DA3->(DbSeek(xFilial("DA3")+cVeiculo))
				RecLock("DA3",.F.)
				DA3->DA3_STATUS := "2"
				DA3->(MsUnlock())
			EndIf

			DAN->(DbSetOrder(1))
			If DAN->(DbSeek(xFilial("DAN")+cVeiculo+cCarga+cSeqCar))
				RecLock("DAN",.F.)
				DAN->(dbDelete())
				DAN->(MsUnlock())
			EndIf
	EndCase

RestArea(aAreaDA3)
RestArea(aAreaDAN)
RestArea(aArea)
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsTimeVei
Esta rotina tem como objetivo retornar os horarios das alocacoes do veiculo

@param   cCarga      Código da carga
@param   cSeqCar     Sequencia da carga
@param   cVeiculo    Código do Veículo

@return  aCargas     Cargas em que o veículo está alocado

@author  Henry Fila 
@since   19/03/2003
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsTimeVei(cVeiculo)
Local aCargas   := {}
Local cQuery    := ""
Local aStruDAN  := {}
Local nY := 0

	DbSelectArea("DAN")

	aStruDAN  := DAN->(dbStruct())

	cAliasDAN := "QRYDAN"

	cQuery := "SELECT DAN.DAN_CODVEI, DAN.DAN_CODCAR, DAN.DAN_SEQCAR, DAN.DAN_DATINI, DAN.DAN_HORINI, "
	cQuery += "DAN.DAN_DATFIM, DAN.DAN_HORFIM, DAN.DAN_TPALOC, DA3.DA3_DESC "
	cQuery += "FROM " + RetSqlName("DAN") + " DAN "
	cQuery += "INNER JOIN " + RetSqlName("DA3") + " DA3 "
	cQuery += "ON DA3_FILIAL = '" + xFilial("DA3") + "' "
	cQuery += "AND DA3_COD = DAN_CODVEI "
	cQuery += "AND DA3.D_E_L_E_T_ = ' ' "	
	cQuery += "WHERE "
	cQuery += "DAN_FILIAL = '" + xFilial("DAN") + "' AND "
	cQuery += "DAN_CODVEI = '" + cVeiculo + "' AND "
	cQuery += "DAN_TPALOC = '1' AND "
	cQuery += "DAN.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY DAN_CODVEI,DAN_DATINI,DAN_CODCAR,DAN_SEQCAR"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAN,.T.,.T.)

	For nY := 1 To Len(aStruDAN)
		If aStruDAN[nY][2]<>"C"
			TcSetField(cAliasDAN,aStruDAN[nY][1],aStruDAN[nY][2],aStruDAN[nY][3],aStruDAN[nY][4])
		EndIf
	Next nY

	While (cAliasDAN)->(!Eof())
		AAdd(aCargas,{	(cAliasDAN)->DAN_CODVEI,;
						(cAliasDAN)->DA3_DESC  ,;
						(cAliasDAN)->DAN_CODCAR,;
						(cAliasDAN)->DAN_SEQCAR,;
						(cAliasDAN)->DAN_DATINI,;
						(cAliasDAN)->DAN_HORINI,;
						(cAliasDAN)->DAN_DATFIM,;
						(cAliasDAN)->DAN_HORFIM,;
						(cAliasDAN)->DAN_TPALOC})

		(cAliasDAN)->(dbSkip())
	EndDo

	aCargas := aSort(aCargas,,,{|x,y| +Dtos(x[5])+x[6] < +Dtos(y[7])+y[8] })

	(cAliasDAN)->(dbCloseArea())

Return (aCargas)

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsCVDisp
Mostra janela de veiculos disponiveis

@param   dDtIni      Data de inicio para verificação
@param   cHoraIni    Hora de inicio para verificação
@param   dDtFim      Data final para verificação
@param   cHoraFim    Hora final para verificação
@param   nPeso       Peso para verificação
@param   nVolume     Volume para verificação

@return  cVeiculo    Código do veículo disponivel selecionado

@author  Henry Fila 
@since   05/04/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsCVDisp(dDtIni,cHoraIni,dDtFim,cHoraFim,nPeso,nVolume)
Local aArrayVei := {}
Local aArea     := GetArea()
Local aAreaDA3  := DA3->(GetArea())
Local cBitmap   := "PROJETOAP"
Local cListVei  := ""
Local cVeiculo  := ""
Local lDisable  := .F.
Local cCpoCapac := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local nCapac    := 0
Local oEnable   := LoadBitmap(GetResources(), "ENABLE")
Local oDisable  := LoadBitmap(GetResources(), "DISABLE")
Local oListVei
Local oDlg
Local oBmp

//-- Busca modelos de carga e joga no array
//-- Parametro: MV_OSFILVE
//-- 
//-- 1-Mostra os veiculos indisponíveis.
//-- 2-Não mostra veiculos indisponíveis.

DA3->(DbSetOrder(1))
DA3->(MsSeek(xFilial("DA3")))
While DA3->(!Eof()) .And. DA3->DA3_FILIAL == xFilial("DA3")
	nCapac := DA3->(FieldGet(FieldPos(cCpoCapac)))
	lDisponivel := DA3->DA3_ATIVO == "1" .And. OmsVeiDisp(DA3->DA3_COD,dDtIni,cHoraIni,dDtFim,cHoraFim)
	If	GetNewPar("MV_OSFILVE",1)==1 .Or. (lDisponivel .And. nPeso <= nCapac .And. nVolume <= DA3->DA3_VOLMAX )
		AAdd(aArrayVei,{lDisponivel,DA3->DA3_COD,DA3->DA3_DESC,nCapac,DA3->DA3_VOLMAX})
	EndIf
	DA3->(dbSkip())
EndDo

If	Len(aArrayVei) == 0
	AAdd(aArrayVei,{.F.,CriaVar("DA3_COD",.F.),CriaVar("DA3_DESC",.F.),CriaVar("DA3_CAPACN",.F.),CriaVar("DA3_VOLMAX",.F.)})
	lDisable := .T.
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -11

cBitmap := "PROJETOAP"

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0001) FROM 280,320 TO 580,840 OF oMainWnd PIXEL //"Disponibilidade de Veiculos"
@ 0 , 0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

@ 06,50 SAY OemtoAnsi(STR0004)  Of oDlg Pixel
@ 15,50 SAY STR0005+Dtoc(dDtIni)+STR0006+cHoraIni+ STR0007+Dtoc(dDtFim)+STR0006+cHoraFim  Of oDlg Pixel

@ 23,50 LISTBOX oListVei Var cListVei FIELDS HEADER " ",;
	OemToAnsi(STR0002),;
	OemToAnsi(STR0003),;
	OemtoAnsi(STR0008),;
	OemToAnsi(STR0009) SIZE 210,100  OF oDlg PIXEL

	oListVei:nFreeze := 1
	oListVei:SetArray(aArrayVei)
	oListVei:bLine:={ ||{Iif(aArrayVei[oListVei:nAT,1],oEnable,oDisable),;
	aArrayVei[oListVei:nAT,2],;
	aArrayVei[oListVei:nAT,3],;
	aArrayVei[oListVei:nAT,4],;
	aArrayVei[oListVei:nAT,5]}}

DEFINE SBUTTON oBut2 FROM 130, 195 TYPE 1 ENABLE OF oDlg PIXEL ACTION (Iif(aArrayVei[oListVei:nAt][1],cVeiculo := aArrayVei[oListVei:nAt][2],Help(" ",1,"OMSVEIEMP")),Iif(!Empty(cVeiculo),oDlg:End(),))
DEFINE SBUTTON oBut2 FROM 130, 225 TYPE 2 ENABLE OF oDlg PIXEL ACTION (nOpca := 0, oDlg:End())

ACTIVATE MSDIALOG oDlg

Restarea( aAreaDA3 )
Restarea( aArea    )

Return( cVeiculo )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsVisCg
Rotina de interface da visualizacao da carga

@param   cAlias      Não utilizado
@param   nReg        Numero do RECNO
@param   nOpc        Não utilizado
@param   dDataIni    Data de inicio
@param   cHrStart    Hora de inicio

@return  .T. fixo

@author  Henry Fila 
@since   02/03/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsVisCg(cAlias,nReg,nOpc,dDataIni,cHrStart)
Local aSize      := MsAdvSize( .T. )
Local aPosObj1   := {}
Local aObjects   := {}
Local aArrayDAI  := {}
Local aPedCli    := {}
Local aButtons   := {	{ "RELATORIO" , { || OmsVisLeg()}, OemtoAnsi(STR0031), OemtoAnsi(STR0031) },; //"Hora Inicial"
						{ "PESQUISA", { || OmsPesqVis(aCampos,aCpoBrw,oPedMan)}, OemtoAnsi(STR0037), OemtoAnsi(STR0038) } } //"Pesquisa de pedidos"
Local aCampos    := {}
Local aCpoBrw    := {}
Local aCpoAdd    := {}

Local cCliente   := ""
Local cLoja      := ""
Local cFilPv     := ""
Local cCliEnt    := ""
Local cLojaEnt   := ""
Local cNomeCli   := ""
Local cLine      := ""
Local cRotCep    := SuperGetMv("MV_ROTCEP",.F.,"1")

Local nTipoOper  := OsVlEntCom()
Local nX         := 0

Local lRet       := .T.
Local lLocalEnt  := SC5->(FieldPos("C5_CLIENT"))  > 0
Local lOSVCGADD  := ExistBlock("OSVCGADD")
Local lOSVCGCLI  := ExistBlock("OSVCGCLI")
Local oDlgman    := Nil
Local oPedMan    := Nil
Local oLiberado  := LoadBitmap( GetResources(), "PMSTASK4" )
Local oCalend    := LoadBitmap( GetResources(), "PMSTASK1" )
Local oHorario   := LoadBitmap( GetResources(), "PMSTASK2" )
Local oVeiculo   := LoadBitmap( GetResources(), "PMSTASK3" )
Local oSayCli    := Nil
Local oSayRed    := Nil
Local oSayEnd    := Nil
Local oSayChP    := Nil
Local oSayTmSrv  := Nil
Local oSaySdP    := Nil
Local oSayBai    := Nil
Local oSayEst    := Nil
Local oSayMun    := Nil
Local oSayCep    := Nil
Local oSayRestr  := Nil
Local oBold      := Nil
Local oStructDAI := Nil
Local cCamposDAI := ""
Local aCamposDAI := {}

//Dados do Redespachante
Local cRedNom    := ""
Local cRedEnd    := ""
Local cRedBai    := ""
Local cRedMun    := ""
Local cRedEst    := ""
Local cRedCEP    := ""
Local lRedExs    := ""
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0
Local cStatus    := ""
Local lIntTPR    := SuperGetMV("MV_ROTAINT",,.F.)  //Integração Rota Inteligente

DEFAULT cHrStart := DAK->DAK_HRSTAR

//-- Tratamento efetuado devido o quarto parametro ser reservado pelo aRotina
If ValType(dDataIni) <> "D"
	dDataIni := DAK->DAK_DATA
EndIf

DEFINE FONT oBold    NAME "Arial" SIZE 0,-12 BOLD

AAdd(aCampos, {"DAI_SEQUEN", "C", TamSx3("DAI_SEQUEN")[1], 0})
AAdd(aCampos, {"DAI_ROTEIR", "C", TamSx3("DAI_ROTEIR")[1], 0})
AAdd(aCampos, {"DAI_PEDIDO", "C", TamSx3("DAI_PEDIDO")[1], 0})
AAdd(aCampos, {"DAI_DTCHEG", "D", TamSx3("DAI_DTCHEG")[1], 0})
AAdd(aCampos, {"DAI_CHEGAD", "C", TamSx3("DAI_CHEGAD")[1], 0})
AAdd(aCampos, {"DAI_TMSERV", "C", TamSx3("DAI_TMSERV")[1], 0})
AAdd(aCampos, {"DAI_DTSAID", "D", TamSx3("DAI_DTSAID")[1], 0})
AAdd(aCampos, {"DAI_CLIENT", "C", TamSx3("DAI_CLIENT")[1], 0})
AAdd(aCampos, {"DAI_LOJA"  , "C", TamSx3("DAI_LOJA")[1], 0})

AAdd(aCpoBrw, {""          ,, OemtoAnsi("")})
AAdd(aCpoBrw, {"DAI_SEQUEN",, OemtoAnsi(STR0010)}) //"Sequencia"
AAdd(aCpoBrw, {"DAI_ROTEIR",, OemtoAnsi(STR0011)}) //"Rota"
AAdd(aCpoBrw, {""          ,, OemtoAnsi("")})
AAdd(aCpoBrw, {""          ,, OemtoAnsi("")})
AAdd(aCpoBrw, {"DAI_PEDIDO",, OemtoAnsi(STR0012)}) //"Pedido"
AAdd(aCpoBrw, {"DAI_DTCHEG",, OemtoAnsi(STR0013)}) //"Data Chegada"
AAdd(aCpoBrw, {"DAI_CHEGAD",, OemtoAnsi(STR0014)}) //"Chegada Prevista"
AAdd(aCpoBrw, {"DAI_TMSERV",, OemtoAnsi(STR0015)}) //"Time Service"
AAdd(aCpoBrw, {"DAI_DTSAID",, OemtoAnsi(STR0016)}) //"Data Saida"
AAdd(aCpoBrw, {"DAI_CLIENT",, OemtoAnsi(STR0017)}) //"Cliente"
AAdd(aCpoBrw, {"DAI_LOJA"  ,, OemtoAnsi(STR0018)}) //"Loja"

//-- Verifica se ha campos a adicionar
If lOSVCGADD
	aCpoAdd := ExecBlock("OSVCGADD",.F.,.F.)
	If ValType(aCpoAdd) == "A" .And. Len(aCpoAdd) > 0
		// Atribui à variável cCamposDAI os IDs dos campos retornados pelo PE
		AEval(aCpoAdd,{|cCampo| cCamposDAI += Iif(Empty(cCamposDAI),cCampo[1],"|"+cCampo[1])})
		// Busca a estrutura dos campos retornados pelo PE
		oStructDAI := FWFormStruct(1,"DAI", { |x| AllTrim(x) $ cCamposDAI } )
		aCamposDAI := oStructDAI:GetFields()
		// Adiciona campos de pesquisa
		For nX := 1 To Len(aCamposDAI)
			AAdd(aCampos,{aCamposDAI[nX,3],aCamposDAI[nX,4],aCamposDAI[nX,5],aCamposDAI[nX,6]})
			AAdd(aCpoBrw,{aCamposDAI[nX,3],,aCamposDAI[nX,1]})
		Next nX
	EndIf
EndIf

//-- Carrega na memoria os dados do cabecalho da carga
RegToMemory( "DAK", .F., .F. )

//-- Carrega no array os dados do item da carga
DbSelectArea("DAI")
DbSetOrder(1)
MsSeek(xFilial()+DAK->DAK_COD+DAK_SEQCAR)

//-- Verifica a filial do cliente e esta usando modo operador logistico
cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SC5"))

While DAI->(!Eof() .And. DAI_FILIAL+DAI_COD+DAI_SEQCAR == xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR)
	//-- Pesquisa Pedido de Venda
	cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SC5"))
	DbSelectArea("SC5")
	DbSetOrder(1)
	MsSeek(OsFilial("SC5",cFilPV)+DAI->DAI_PEDIDO)
	//-- Cod.Cliente + Loja do item da carga - Endereco de entrega
	cCliEnt  := If(lLocalEnt.And.!Empty(SC5->C5_CLIENT), SC5->C5_CLIENT, SC5->C5_CLIENTE)
	cLojaEnt := If(lLocalEnt.And.!Empty(SC5->C5_LOJAENT),SC5->C5_LOJAENT,SC5->C5_LOJACLI)
	//-- Cod.Cliente + Loja do item da carga
	cCliente := DAI->DAI_CLIENT
	cLoja    := DAI->DAI_LOJA
	//-- Ponto de entrada para alterar cliente/loja na visualizacao de cargas.
	If	lOSVCGCLI
		aRetPE := ExecBlock("OSVCGCLI",.F.,.F.,{DAI->DAI_FILIAL, DAI->DAI_PEDIDO, DAI->DAI_CLIENT, DAI->DAI_LOJA})
		If	ValType(aRetPE)=="A"
			cCliEnt  := aRetPE[1]
			cLojaEnt := aRetPE[2]
			cCliente := aRetPE[1]
			cLoja    := aRetPE[2]
		EndIf
	EndIf

	//Caso exista Redespachante no Pedido, buscar seus dados.
	If lDaiRedesp .And. !Empty(DAI->DAI_REDESP)
		SA4->(DbSetOrder(1))
		SA4->(MsSeek(OsFilial("SA4",cFilPv)+DAI->DAI_REDESP))
		cRedNom := SA4->A4_NOME
		cRedEnd := SA4->A4_END
		cRedBai := SA4->A4_BAIRRO
		cRedMun := SA4->A4_MUN
		cRedEst := SA4->A4_EST
		cRedCEP := SA4->A4_CEP
	Else
		cRedNom := ""
		cRedEnd := ""
		cRedBai := ""
		cRedMun := ""
		cRedEst := ""
		cRedCEP := ""
	EndIf

	//-- Array aPedCli contendo cliente+loja usado para exibir rodape
	aAdd(aPedCli,{SC5->C5_TIPO,cCliEnt,cLojaEnt})
	If	SC5->C5_TIPO $ "DB"
		cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SA2"))
		SA2->(DbSetOrder(1))
		SA2->(MsSeek(OsFilial("SA2",cFilPv)+cCliente+cLoja))
		cNomeCli := SA2->A2_NOME

		SA2->(MsSeek(OsFilial("SA2",cFilPv)+cCliEnt+cLojaEnt))

		//-- Inclui no array para a montagem da tela
		AAdd(aArrayDAI,{1,;
						DAI->DAI_SEQUEN,;
						DAI->DAI_ROTEIR,;
						DAI->DAI_PERCUR,;
						DAI->DAI_ROTA,;
						DAI->DAI_PEDIDO,;
						DAI->DAI_DTCHEG,;
						DAI->DAI_CHEGAD,;
						DAI->DAI_TMSERV,;
						DAI->DAI_DTSAID,;
						cCliente,;
						cLoja,;
						DAI->DAI_PESO,;
						DAI->DAI_CAPVOL,;
						cNomeCli,;
						Iif(!Empty(cRedEnd),cRedEnd,SA2->A2_END),;
						Iif(!Empty(cRedBai),cRedBai,SA2->A2_BAIRRO),;
						Iif(!Empty(cRedMun),cRedMun,SA2->A2_MUN),;
						Iif(!Empty(cRedEst),cRedEst,SA2->A2_EST),;
						Iif(!Empty(cRedCEP),cRedCEP,SA2->A2_CEP),;
						If(DAI->(FieldPos("DAI_FILPV"))>0,DAI->DAI_FILPV,OsFilial("SA2",cFilPv)),;
						Iif(lDaiRedesp,DAI->DAI_REDESP,""),;
						cRedNom})
	Else
		cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SA1"))
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(OsFilial("SA1",cFilPv)+cCliente+cLoja))
		cNomeCli := SA1->A1_NOME

		SA1->(MsSeek(OsFilial("SA1",cFilPv)+cCliEnt+cLojaEnt))

		//-- Inclui no array para a montagem da tela
		lRedExs := lDaiRedesp .And. !Empty(DAI->DAI_REDESP)
		Do Case
			Case lRedExs == .T.
				AAdd(aArrayDAI,{1,;
							DAI->DAI_SEQUEN,;
							DAI->DAI_ROTEIR,;
							DAI->DAI_PERCUR,;
							DAI->DAI_ROTA,;
							DAI->DAI_PEDIDO,;
							DAI->DAI_DTCHEG,;
							DAI->DAI_CHEGAD,;
							DAI->DAI_TMSERV,;
							DAI->DAI_DTSAID,;
							cCliente,;
							cLoja,;
							DAI->DAI_PESO,;
							DAI->DAI_CAPVOL,;
							cNomeCli,;
							cRedEnd,;
							cRedBai,;
							cRedMun,;
							cRedEst,;
							cRedCEP,;
							IIf(DAI->(FieldPos("DAI_FILPV"))>0,DAI->DAI_FILPV,OsFilial("SA1",cFilPv)),;
							DAI->DAI_REDESP,;
							cRedNom})			
			Case cRotCep == "1"
				AAdd(aArrayDAI,{1,;
							DAI->DAI_SEQUEN,;
							DAI->DAI_ROTEIR,;
							DAI->DAI_PERCUR,;
							DAI->DAI_ROTA,;
							DAI->DAI_PEDIDO,;
							DAI->DAI_DTCHEG,;
							DAI->DAI_CHEGAD,;
							DAI->DAI_TMSERV,;
							DAI->DAI_DTSAID,;
							cCliente,;
							cLoja,;
							DAI->DAI_PESO,;
							DAI->DAI_CAPVOL,;
							cNomeCli,;
							SA1->A1_END,;
							SA1->A1_BAIRRO,;
							SA1->A1_MUN,;
							SA1->A1_EST,;
							SA1->A1_CEP,;
							IIf(DAI->(FieldPos("DAI_FILPV"))>0,DAI->DAI_FILPV,OsFilial("SA1",cFilPv)),;
							Iif(lDaiRedesp, DAI->DAI_REDESP, ""),;
							cRedNom})
			Case cRotCep == "2"
				AAdd(aArrayDAI,{1,;
							DAI->DAI_SEQUEN,;
							DAI->DAI_ROTEIR,;
							DAI->DAI_PERCUR,;
							DAI->DAI_ROTA,;
							DAI->DAI_PEDIDO,;
							DAI->DAI_DTCHEG,;
							DAI->DAI_CHEGAD,;
							DAI->DAI_TMSERV,;
							DAI->DAI_DTSAID,;
							cCliente,;
							cLoja,;
							DAI->DAI_PESO,;
							DAI->DAI_CAPVOL,;
							cNomeCli,;
							IIf(Empty(SA1->A1_ENDENT),SA1->A1_END,SA1->A1_ENDENT),;
							IIf(Empty(SA1->A1_BAIRROE),SA1->A1_BAIRRO,SA1->A1_BAIRROE),;
							IIf(Empty(SA1->A1_MUNE),SA1->A1_MUN,SA1->A1_MUNE),;
							IIf(Empty(SA1->A1_ESTE),SA1->A1_EST,SA1->A1_ESTE),;
							IIf(Empty(SA1->A1_CEPE),SA1->A1_CEP,SA1->A1_CEPE),;
							IIf(DAI->(FieldPos("DAI_FILPV"))>0,DAI->DAI_FILPV,OsFilial("SA1",cFilPv)),;
							Iif(lDaiRedesp,DAI->DAI_REDESP,""),;
							cRedNom})
			OtherWise
				AAdd(aArrayDAI,{1,;
							DAI->DAI_SEQUEN,;
							DAI->DAI_ROTEIR,;
							DAI->DAI_PERCUR,;
							DAI->DAI_ROTA,;
							DAI->DAI_PEDIDO,;
							DAI->DAI_DTCHEG,;
							DAI->DAI_CHEGAD,;
							DAI->DAI_TMSERV,;
							DAI->DAI_DTSAID,;
							cCliente,;
							cLoja,;
							DAI->DAI_PESO,;
							DAI->DAI_CAPVOL,;
							cNomeCli,;
							SA1->A1_ENDENT,;
							SA1->A1_BAIRROE,;
							SA1->A1_MUNE,;
							SA1->A1_ESTE,;
							SA1->A1_CEPE,;
							IIf(DAI->(FieldPos("DAI_FILPV"))>0,DAI->DAI_FILPV,OsFilial("SA1",cFilPv)),;
							Iif(lDaiRedesp,DAI->DAI_REDESP,""),;
							cRedNom})
		EndCase

		//-- Adiciona campos customizados
		For nX := 1 To Len(aCpoAdd)
			AAdd(Atail(aArrayDAI),DAI->(FieldGet(FieldPos(aCpoAdd[nX][1]))))
		Next nX
	EndIf
	DbSelectArea("DAI")
	DAI->(dbSkip())
EndDo

If !OMSOrigTPR() .And. Empty(DAK->DAK_VIAROT)  //Carga não roteirizada com TPR ou não rot. com TOL
	//-- Recalculo do horario / dia de chegada
	Oms200Time(cHrStart,dDataIni,aArrayDAI,DAK->DAK_CAMINH,21,11,12,3,4,5,13,14,8,9,1,7,10)
EndIf


//-- Montagem da Interface
aObjects := {}
AAdd(aObjects,{100,100,.T.,.T.		} )
AAdd(aObjects,{100, 50,.T.,.T.,.T.	} )
AAdd(aObjects,{100, 60,.T.,.F.		} )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj1 := MsObjSize( aInfo, aObjects)

DEFINE MSDIALOG oDlgMan FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL //"Sequencia da Carga "

DbSelectArea("DAK")
EnChoice( "DAK", nReg, 2   ,,,,,aPosObj1[1], , 3, , , , , ,.T.,,,,.T.)

//-- ListBox dos pedido
If lDaiRedesp
	@ aPosObj1[2,1],aPosObj1[2,2] LISTBOX oPedMan VAR cVar Fields HEADER OemtoAnsi(" "),;
	OemtoAnsi(STR0010),; //"Sequencia"
	OemtoAnsi(STR0011),; //"Rota"
	OemtoAnsi(STR0012),; //"Pedido"
	OemtoAnsi(STR0013),; //"Data Chegada"
	OemtoAnsi(STR0014),; //"Chegada Prevista"
	OemtoAnsi(STR0015),; //"Time Service"
	OemtoAnsi(STR0016),; //"Data Saida"
	OemtoAnsi(STR0017),; //"Cliente"
	OemtoAnsi(STR0018),; //"Loja"
	OemtoAnsi(STR0049),; //"Peso"
	OemtoAnsi(STR0050),; //"Cap. Volume"
	OemToAnsi(STR0019),; //"Nome"
	OemToAnsi(STR0044),; //"Redespachante"
	OemToAnsi(STR0045),; //"Nome Redespachante"
	RetTitle("A1_END"),; //"Endereco"
	OemToAnsi(STR0020),; //'Bairro'
	OemToAnsi(STR0021),; //'Cidade'
	OemToAnsi(STR0022),; //'UF'
	RetTitle("A1_CEP"),; //"CEP"
	If(nTipoOper<>1,RetTitle("DAI_FILIAL"),""),;  //"Filial"
	SIZE aPosObj1[2,3],aPosObj1[2,4] OF oDlgMan PIXEL
Else
	@ aPosObj1[2,1],aPosObj1[2,2] LISTBOX oPedMan VAR cVar Fields HEADER OemtoAnsi(" "),;
	OemtoAnsi(STR0010),; //"Sequencia"
	OemtoAnsi(STR0011),; //"Rota"
	OemtoAnsi(STR0012),; //"Pedido"
	OemtoAnsi(STR0013),; //"Data Chegada"
	OemtoAnsi(STR0014),; //"Chegada Prevista"
	OemtoAnsi(STR0015),; //"Time Service"
	OemtoAnsi(STR0016),; //"Data Saida"
	OemtoAnsi(STR0017),; //"Cliente"
	OemtoAnsi(STR0018),; //"Loja"
	OemtoAnsi(STR0049),; //"Peso"
	OemtoAnsi(STR0050),; //"Cap. Volume"
	OemToAnsi(STR0019),; //"Nome"
	RetTitle("A1_END"),; //"Endereco"
	OemToAnsi(STR0020),; //'Bairro'
	OemToAnsi(STR0021),; //'Cidade'
	OemToAnsi(STR0022),; //'UF'
	RetTitle("A1_CEP"),; //"CEP"
	If(nTipoOper<>1,RetTitle("DAI_FILIAL"),""),;  //"Filial"
	SIZE aPosObj1[2,3],aPosObj1[2,4] OF oDlgMan PIXEL
EndIf	
oPedMan:SetArray(aArrayDAI)

//-- Adiciona campos customizados
For nX := 1 To Len(aCpoAdd)
	AAdd(oPedMan:aHeaders,aCpoAdd[nX][2])
Next nX

cLine := '{ ||{Iif(aArrayDAI[oPedMan:nAT,1]==1,oLiberado,'
cLine += 'Iif(aArrayDAI[oPedMan:nAT,1]==2,oVeiculo,'
cLine += 'Iif(aArrayDAI[oPedMan:nAT,1]==3,oHorario,'
cLine += 'Iif(aArrayDAI[oPedMan:nAT,1]==4,oCalend,oLiberado)))),'
cLine += 'aArrayDAI[oPedMan:nAT,2],'  //"Sequencia"
cLine += 'aArrayDAI[oPedMan:nAT,3],'  //"Rota"
cLine += 'aArrayDAI[oPedMan:nAT,6],'  //"Pedido"
cLine += 'aArrayDAI[oPedMan:nAT,7],'  //"Data Chegada"
cLine += 'aArrayDAI[oPedMan:nAT,8],'  //"Chegada Prevista"
cLine += 'aArrayDAI[oPedMan:nAT,9],'  //"Time Service"
cLine += 'aArrayDAI[oPedMan:nAT,10],' //"Data Saida"
cLine += 'aArrayDAI[oPedMan:nAT,11],' //"Cliente"
cLine += 'aArrayDAI[oPedMan:nAT,12],' //"Loja"
cLine += 'aArrayDAI[oPedMan:nAT,13],' //"Peso"
cLine += 'aArrayDAI[oPedMan:nAT,14],' //"Volume"
cLine += 'aArrayDAI[oPedMan:nAT,15],' //"Nome"
If lDaiRedesp
	cLine += 'aArrayDAI[oPedMan:nAT,22],' //Redespachante
	cLine += 'aArrayDAI[oPedMan:nAT,23],' //Nome Redespachante
EndIf
cLine += 'aArrayDAI[oPedMan:nAT,16],' //"Endereco"
cLine += 'aArrayDAI[oPedMan:nAT,17],' //'Bairro'
cLine += 'aArrayDAI[oPedMan:nAT,18],' //'Cidade'
cLine += 'aArrayDAI[oPedMan:nAT,19],' //'UF'
cLine += 'aArrayDAI[oPedMan:nAT,20],' //"CEP"
cLine += 'If(nTipoOper<>1,aArrayDAI[oPedMan:nAT,21],),' //"Filial"

For nX := 1 To Len(aCpoAdd)
	cLine += ',aArrayDAI[oPedMan:nAT,'+StrZero(nX+23,2)+']'
Next nX
cLine += '}}'

oPedMan:bLine:=&cLine

//-- Rodape da janela
@ aPosObj1[3,1], aPosObj1[3,2] TO  aPosObj1[3,3], aPosObj1[3,4] LABEL  OemToAnsi(STR0023)   OF oDlgMan PIXEL   //"Dados da Entrega"

@ aPosObj1[3,1]+10,05 Say OemtoAnsi(STR0017)+":" SIZE 040,08 Of oDlgMan PIXEL //"Cliente: "
@ aPosObj1[3,1]+10,30 Say oSayCli Prompt "" SIZE 300,08 Of oDlgMan PIXEL

If lDaiRedesp
	@ aPosObj1[3,1]+10,170 Say OemtoAnsi(STR0044)+":" SIZE 040,08 Of oDlgMan PIXEL //"Redespachante: "
	@ aPosObj1[3,1]+10,210 Say oSayRed Prompt "" SIZE 300,08 Of oDlgMan PIXEL
EndIf

@ aPosObj1[3,1]+20,05 Say OemtoAnsi(STR0024)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Endereco:"
@ aPosObj1[3,1]+20,30 Say oSayEnd Prompt "" SIZE 300,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+20,170 Say OemtoAnsi(STR0020)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Bairro"
@ aPosObj1[3,1]+20,210 Say oSayBai Prompt "" SIZE 300,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+30,05 Say OemtoAnsi(STR0021)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Cidade"
@ aPosObj1[3,1]+30,30 Say oSayMun Prompt "" SIZE 300,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+30,90 Say OemtoAnsi(STR0022)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Estado"
@ aPosObj1[3,1]+30,120 Say oSayEst Prompt "" SIZE 040,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+30,170 Say OemtoAnsi(STR0025)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Cep"
@ aPosObj1[3,1]+30,210 Say oSayCep Prompt "" SIZE 040,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+40,05 Say OemtoAnsi(STR0014)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Chegada Prevista:"
@ aPosObj1[3,1]+40,50 Say oSayChP Prompt "" SIZE 040,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+40,90 Say OemtoAnsi(STR0015)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Time Service:"
@ aPosObj1[3,1]+40,125 Say oSayTmSrv Prompt "" SIZE 040,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+40,170 Say OemtoAnsi(STR0026)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Saida Prevista"
@ aPosObj1[3,1]+40,210 Say oSaySdP Prompt "" SIZE 040,08 Of oDlgMan PIXEL

@ aPosObj1[3,1]+50,04 Say oSayRestr Prompt "  " SIZE 0150,08 Of oDlgMan PIXEL  FONT oBold COLOR If(lRet,CLR_HBLUE,CLR_HRED)

oPedMan:bChange  := {|| OmsVisMsg(aArrayDAI,oPedMan,oSayCli,oSayEnd,oSayBai,oSayMun,oSayEst,oSayCep,oSayChP,oSayTmSrv,oSaySdP,oSayRestr,aPedCli,oSayRed)}
oPedMan:Refresh()

ACTIVATE MSDIALOG  oDlgMan ON INIT EnchoiceBar( oDlgMan, { || nOpca := 1,oDlgMan:End()}, {||oDlgMan:End()},,aButtons)

Return( .T. )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsVisMsg STATIC
Rotina de mensagem do rodape da sequencia de carga

@param   aArrayDAI   Array da Carga
@param   oPedMan     Objeto do ListBox
@param   oSayCli     Objeto do Cliente
@param   oSayEnd     Objeto do Endereco
@param   oSayBai     Objeto do Bairro
@param   oSayMun     Objeto do Municipio
@param   oSayEst     Objeto do Estado
@param   oSayCep     Objeto do CEP
@param   oSayChP     Objeto da Chegada Prevista
@param   oSayTmSrv   Objeto dO TIME SERVICE
@param   oSaySdP     Objeto da SAIDA PREVISTA
@param   oSayRestr   Objeto das Restrições
@param   aPedCli     Array de Pedidos do Cliente
@param   oSayRed     Objeto do Redespachante

@return  Null

@author  Henry Fila 
@since   02/03/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OmsVisMsg(aArrayDAI,oPedMan,oSayCli,oSayEnd,oSayBai,oSayMun,oSayEst,oSayCep,oSayChP,oSayTmSrv,oSaySdP,oSayRestr,aPedCli,oSayRed)
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local cCliEnt   := ""
Local cLojaEnt  := ""
Local cTipoPed  := ""
Local cFilPv    := ""
Local nTipoOper := OsVlEntCom()
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

//-- Array aPedCli contendo cliente+loja usado para exibir rodape
cTipoPed := aPedCli[oPedMan:nAt][1]
cCliEnt  := aPedCli[oPedMan:nAt][2]
cLojaEnt := aPedCli[oPedMan:nAt][3]

If cTipoPed $ "DB"
	cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SA2"))
	SA2->(DbSetOrder(1))
	SA2->(MsSeek(OsFilial("SA2",cFilPV)+cCliEnt+cLojaEnt))
	oSayCli:SetText(SA2->A2_COD+"-"+SA2->A2_LOJA+"   "+SA2->A2_NOME)
Else
	cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SA1"))
	SA1->(MsSeek(OsFilial("SA1",cFilPV)+cCliEnt+cLojaEnt))
	oSayCli:SetText(SA1->A1_COD+"-"+SA1->A1_LOJA+"   "+SA1->A1_NOME)
EndIf

oSayEnd:SetText(Alltrim(aArrayDAI[oPedMan:nAt][16]))
oSayBai:SetText(aArrayDAI[oPedMan:nAt][17])
oSayMun:SetText(aArrayDAI[oPedMan:nAt][18])
oSayEst:SetText(aArrayDAI[oPedMan:nAt][19])
oSayCep:SetText(aArrayDAI[oPedMan:nAt][20])
oSayChP:SetText(aArrayDAI[oPedMan:nAt][8])
oSayTmSrv:SetText(aArrayDAI[oPedMan:nAt][9])
oSaySdP:SetText(IntToHora(HoraToInt(aArrayDAI[oPedMan:nAt][8],2)+HoraToInt(aArrayDAI[oPedMan:nAt][9],4),2))
If ValType(oSayRestr)=="O"
	oSayRestr:SetText(If(aArrayDAI[oPedMan:nAt][1]==1,OemtoAnsi(STR0033),OemtoAnsi(STR0034))) //"Carga sem restricao de entrega"###"Carga possui restricao de entrega"
	oSayRestr:nClrText:=If(aArrayDAI[oPedMan:nAt][1]==1,CLR_HBLUE,CLR_HRED)
EndIf
If lDaiRedesp
	If !Empty(aArrayDAI[oPedMan:nAt][22])
		oSayRed:SetText(aArrayDAI[oPedMan:nAt][22]+" - "+aArrayDAI[oPedMan:nAt][23])
	Else
		oSayRed:SetText("")
	EndIf
EndIf
RestArea( aAreaSA1 )
RestArea( aArea    )

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsVisLeg STATIC
Exibe a legenda dos status do pedido

@param   Null

@return  Null

@author  Henry Fila 
@since   23/01/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OmsVisLeg()
Local aLegenda := {	{ "PMSTASK4", OemToAnsi(STR0027) },; //"Entrega permitida"
					{ "PMSTASK1", OemToAnsi(STR0028) },; //"Restricao por calendario"
					{ "PMSTASK2", OemToAnsi(STR0029) },; //"Restricao por horario"
					{ "PMSTASK3", OemToAnsi(STR0030) } } //"Restricao por veiculo"

BrwLegenda( cCadastro, OemToAnsi( STR0032 ), aLegenda  ) //"Status"

Return( Nil )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsVldHr
Validacao da hora inicial digitada

@param   cNewHr   Hora a ser validada

@return  lRet     Retorna se a hora é válida ou não.

@author  Henry Fila 
@since   02/03/2001
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsVldHr(cNewHr)

Local lRet := .T.

Do Case
	Case Val(SubStr(cNewHr,1,2)) > 23 
		Help(" ",1,"OMS200HORA") //Horario invalido
		lRet := .F.
	Case Val(SubStr(cNewHr,1,2)) < 00 
		Help(" ",1,"OMS200HORA") //Horario invalido
		lRet := .F.
	Case Val(SubStr(cNewHr,4,5)) > 59 
		Help(" ",1,"OMS200MIN") //Horario invalido
		lRet := .F.
EndCase

Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} OsDelUnt STATIC
Exclui a unitizacao caso haja alguma modificacao na carga apos gerada

@param   cCarga   Código da carga
@param   cSeqCar  Sequencia da carga
@param   cPedido  Código do Pedido
@param   cItem    Código do Item
@param   cSequen  Sequencia do Item
@param   cFilCar  Filial da Carga

@return  .T. Fixo

@author  Henry Fila 
@since   27/07/2000
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OsDelUnt(cCarga,cSeqCar,cPedido,cItem,cSequen,cFilCar)
Local aArea := GetArea()

Default cPedido := ""
Default cItem   := ""
Default cSequen := ""
Default cFilCar := xFilial("DBN")

If !Empty(cPedido) .And. !Empty(cItem) .And. !Empty(cSequen)
	DBN->(DbSetOrder(3))
	If DBN->(MsSeek(OsFilial("DBN",cFilCar)+cPedido+cItem+cSequen+cCarga))
		While DBN->(!Eof()) .And. DBN->DBN_FILIAL == xFilial("DBN") .And. ;
									DBN->DBN_PEDIDO == cPedido .And. ;
									DBN->DBN_ITEM == cItem .And. ;
									DBN->DBN_SEQUEN == cSequen .And. ;
									DBN->DBN_CARGA == cCarga
			RecLock("DBN",.F.)
			dbDelete()
			MsUnlock()
			DBN->(dbSkip())
		EndDo
	EndIf
Else
	DBN->(DbSetOrder(4))
	If DBN->(MsSeek(OsFilial("DBN",cFilCar)+cCarga))
		While DBN->(!Eof()) .And. DBN->DBN_FILIAL == xFilial("DBN") .And. ;
									DBN->DBN_CARGA == cCarga
			RecLock("DBN",.F.)
			dbDelete()
			MsUnlock()
			DBN->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea( aArea )

Return( .T. )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsPesqVis STATIC
Permite efetuar a pesquisa de pedidos

@param   aCampos  Array com a estrutura
@param   aCpoBrw  Array com os dados de exibicao
@param   oPedMan  Objeto com os Pedidos

@return  Null

@author  Kleber Dias Gomes 
@since   29/11/2005
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OmsPesqVis(aCampos,aCpoBrw,oPedMan)

Local aCpoLbl  := {}
Local aCpo     := {}

Local cCpoLbl  := ""
Local cCpo     := ""
Local xPesq := Space(6)

Local nX       := 0
Local nTipo    := 0
Local nOpca    := 0
Local nPArray  := 0
Local nPosBrw  := 0

Local oDlg

For nX := 1 to Len(aCpoBrw)
	If !Empty(aCpoBrw[nX][3])
		AAdd(aCpoLbl,aCpoBrw[nX][3])
		AAdd(aCpo,aCpoBrw[nX][1])
	EndIf
Next

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0037)  FROM 09,0 TO 20,50 OF oMainWnd

	@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST

	@ 014,035 SAY OemtoAnsi(STR0039) of oDlg PIXEL
	@ 014,075 MSCOMBOBOX oCpo VAR cCpoLbl ITEMS aCpoLbl SIZE 55, 65 OF oDlg PIXEL ON CHANGE (nTipo := oCpo:nAt,OmsPesPict(nTipo,aCampos,aCpo,@xPesq,oPesq,@cCpo))
	@ 028,035 SAY OemtoAnsi(STR0040) of oDlg PIXEL
	@ 028,075 MSGET oPesq VAR xPesq Picture "@!" SIZE 113, 10 Of oDlg PIXEL

	DEFINE SBUTTON oBut1 FROM 062, 130 TYPE 1 ACTION ( nOpca := 1, oDlg:End() ) ENABLE of oDlg
	DEFINE SBUTTON oBut1 FROM 062, 160 TYPE 2 ACTION ( nOpca := 0, oDlg:End() )  ENABLE of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	nPosBrw := Ascan(aCpoBrw,{|x| x[3] == Alltrim(cCpoLbl)})
	nPArray := Ascan(oPedMan:AARRAY,{|x| x[nPosBrw] == If(ValType(xPesq)<>"C",xPesq,AllTrim(xPesq))})
	If nPArray > 0
		oPedMan:nAT := nPArray
		oPedMan:Refresh()
		oPedMan:SetFocus()
	EndIf
EndIf

Return( Nil )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsPesPict STATIC
Tratamento da Picture para resultados da pesquisa de pedidos

@param   nTipo    Posicao do campo no Array
@param   aCampos  Array com a estrutura do arquivo
@param   aCpo     Array com os campos e labels do arquivo
@param   xPesq    Variavel de pesquisa
@param   oPesq    Objeto da variavel de pesquisa
@param   cCpo     Nome do campo por referencia para ser pesquisado

@return  Null

@author  Kleber Dias Gomes 
@since   29/11/2005
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OmsPesPict(nTipo,aCampos,aCpo,xPesq,oPesq,cCpo)

Local nPosCpo := 0
Local cPict   := ""

nPosCpo := Ascan(aCampos,{|x| x[1] == Alltrim(aCpo[nTipo])})

If nPosCpo > 0

	cCpo  := aCampos[nPosCpo][1]

	Do Case
		Case aCampos[nPosCpo][2] == "N"
			xPesq := 0
			cPict := "@E 99,999,999.99"
		Case aCampos[nPosCpo][2] == "D"
			xPesq := dDataBase
			cPict := "@D"
		Case aCampos[nPosCpo][2] == "C"
			xPesq := Space(aCampos[nPosCpo][3])
			cPict := Replicate("!",aCampos[nPosCpo][3])
	EndCase
EndIf

oPesq:oGet:Picture := cPict
oPesq:Refresh()

Return( Nil )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsDcEntra
Exibe browse dos documentos de entrada vinculados a carga

@param   Null

@return  Lógico nOpcSel == 1

@author  Richard Anderson 
@since   01/08/2007
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsDcEntra()

Local   cCadastro  := STR0041 // "Documentos de Entrada"
Local   aRotOld    := Iif(Type('aRotina') == 'A',AClone(aRotina),{})
Local   aCampos    := {}
Local   aIndexSF1  := {}
Local   cFiltraSF1 := ''
Local   bFiltraBrw := {}
Local   cFilSF1    := ''
Local   cFilDCT    := ''
Local   cCodFor    := ''
Local   cLojFor    := ''
Private nOpcSel    := 0

aRotina := {}
AAdd( aRotina, { STR0043 ,"OMSConfSel",0,2,,,.T.} ) // "&Confirmar"

If Type('aCols') == 'A' .And. GdFieldPos('DFR_FILDCT') > 0
	cFilDCT := GdFieldGet('DFR_FILDCT')
	If Empty(cFilDCT)
		cFilSF1 := xFilial('SF1')
	Else
		cFilSF1 := cFilDCT
	EndIf
Else
	cFilSF1 := xFilial('SF1')
EndIf

If Type('M->DFQ_CODFOR') == 'C'
	cCodFor := M->DFQ_CODFOR
EndIf

If Type('M->DFQ_LOJFOR') == 'C'
	cLojFor := M->DFQ_LOJFOR
EndIf

SF1->(DbSetOrder(1))
cFiltraSF1 := "F1_FILIAL == '"+cFilSF1+"' .And."
cFiltraSF1 += "AllTrim(F1_ESPECIE) $ 'CTR;NFST'"
If !Empty(cCodFor)
	cFilTraSF1 += ".And. F1_FORNECE == '"+cCodFor+"'"
EndIf
If !Empty(cLojFor)
	cFilTraSF1 += ".And. F1_LOJA == '"+cLojFor+"'"
EndIf
bFiltraBrw := {|| FilBrowse("SF1",@aIndexSF1,@cFiltraSF1) }
Eval(bFiltraBrw)

MaWndBrowse(0,0,300,600,cCadastro,"SF1",aCampos,aRotina,,,,.T.)

nRecnoSF1 := SF1->(Recno())
aRotina   := AClone(aRotOld)

//-- Finaliza o uso da funcao FilBrowse e retorna os indices padroes
EndFilBrw("SF1",aIndexSF1)

SF1->(dbGoTo(nRecnoSF1))

Return( nOpcSel == 1 )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsDcSaida
Exibe browse dos documentos de saida vinculados a carga

@param   Null

@return  Lógico nOpcSel == 1

@author  Kleber Dias Gomes 
@since   01/08/2007
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsDcSaida()

Local   cCadastro  := STR0042 // "Documentos de Saída"
Local   aRotOld    := Iif(Type('aRotina') == 'A',AClone(aRotina),{})
Local   aCampos    := {}
Local   aIndexSF2  := {}
Local   cFiltraSF2 := ''
Local   bFiltraBrw := {}
Local   nRecnoSF2  := 0
Local   cFilSF2    := ''
Local   cFilDCS    := ''
Private nOpcSel    := 0

aRotina := {}
AAdd( aRotina, { STR0043 ,"OMSConfSel",0,2,,,.T.} ) // "&Confirmar"

If Type('aCols') == 'A' .And. GdFieldPos('DFP_FILDCS') > 0
	cFilDCS := GdFieldGet('DFP_FILDCS')
	If Empty(cFilDCS)
		cFilSF2 := xFilial('SF2')
	Else
		cFilSF2 := cFilDCS
	EndIf
Else
	cFilSF2 := xFilial('SF2')
EndIf

SF2->(DbSetOrder(1))
cFiltraSF2 := "F2_FILIAL == '"+cFilSF2+"' .And. "
cFiltraSF2 += "F2_CARGA  <> ' '"
bFiltraBrw := {|| FilBrowse("SF2",@aIndexSF2,@cFiltraSF2) }
Eval(bFiltraBrw)

MaWndBrowse(0,0,300,600,cCadastro,"SF2",aCampos,aRotina,,,,.T.)

nRecnoSF2 := SF2->(Recno())
aRotina   := AClone(aRotOld)

//-- Finaliza o uso da funcao FilBrowse e retorna os indices padroes
EndFilBrw("SF2",aIndexSF2)

SF2->(dbGoTo(nRecnoSF2))

Return( nOpcSel == 1 )

//--------------------------------------------------------------------
/*/{Protheus.doc} OMSConfSel STATIC
Confirma selecao em browse especifico

@param   Null

@return  Null

@author  Richard Anderson 
@since   01/08/2007
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function OMSConfSel()

nOpcSel := 1

If Type("oWind") == "O"
	oWind:End()
Else
	oWnd:End()
EndIf

Return( Nil )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmRtPesoIt
Esta rotina tem como objetivo calcular o peso bruto do item da Nota de Saida,
quando ha a integração com o modulo SIGAGFE. (Campo virtual D2_PBRUTO)
Novo parametro MV_GFERPB - Rateio do Peso Bruto da NF

@param   cCodPro   Código do Produto
@param   nQuant    Quantidade do Produto
@param   cTipoNota Tipo da Nota - E = Entrada / S = Saída
@param   nValorIt  Valor do Produto

@return  nPesoBru  Peso Bruto calculado

@author  Katia
@since   12/04/2013
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmRtPesoIt(cCodPro, nQuant, cTipoNota, nValorIt)

Local  aArea      := GetArea()
Local  cQuery     := ""
Local  cAliasSD   := ""
Local  nPesoSD    := 0
Local  nPesoBru   := 0
Local  nPos       := 0
Local  cGFERPB    := SuperGetMv("MV_GFERPB",.F.,'0')  //Tipo de Rateio do Peso Bruto

Default nValorIt  := 0
Default cCodPro   := ""
Default nQuant    := 0
Default cTipoNota := "S"

If cGFERPB == '1'
	// Documento de Saída
	If cTipoNota == "S"
		If ( nPos := Ascan( aNfsRatPes, { | e | e[1] == SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE } ) ) > 0
			nPesoSD := aNfsRatPes[nPos,2]
		Else
			Aadd( aNfsRatPes, { SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE, 0 } )
			nPos := Len(aNfsRatPes)

			//---- Calcula o Total do Peso dos Itens da Nota
			cAliasSD := GetNextAlias()
			cQuery := "SELECT SUM(SD2.D2_QUANT * B1_PESBRU) PESO  "
			cQuery += "FROM "+RetSqlName("SD2")+ " SD2, "
			cQuery +=         RetSqlName("SB1")+ " SB1 "
			cQuery += "WHERE "
			cQuery += " SD2.D2_FILIAL  = '" + SF2->F2_FILIAL  + "' AND "
			cQuery += " SD2.D2_DOC     = '" + SF2->F2_DOC     + "' AND "
			cQuery += " SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' AND "
			cQuery += " SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
			cQuery += " SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' AND "
			cQuery += " SD2.D_E_L_E_T_ = ' ' "
			cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
			cQuery += " AND SB1.B1_COD = SD2.D2_COD "
			cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD,.T.,.T.)
			TCSetField(cAliasSD,"PESO"  ,"N",TamSx3("F2_PBRUTO")[1],TamSx3("F2_PBRUTO")[2])
			If (cAliasSD)->(!Eof())
				nPesoSD := (cAliasSD)->PESO
			EndIf
			(cAliasSD)->(DbCloseArea())

			aNfsRatPes[nPos,2] := nPesoSD

			RestArea(aArea)
		EndIf

		nPeso   := ((Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_PESBRU") * nQuant) / nPesoSD)
		nPesoBru:= (SF2->F2_PBRUTO * nPeso)
	EndIf

	// Documento de Entrada
	If cTipoNota == "E"
		IF SuperGetMV("MV_NFGFEPL",,.F.)
			If ( nPos := Ascan( aNfsRatPes, { | e | e[1] == SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE } ) ) > 0
				nPesoBru := (nValorIt/SF1->F1_VALBRUT)*aNfsRatPes[nPos,2]
			Else
				Aadd( aNfsRatPes, { SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE, 0 } )
				nPos := Len(aNfsRatPes)

				nPesoBru := (nValorIt/SF1->F1_VALBRUT)*SF1->F1_PBRUTO
				aNfsRatPes[nPos,2] := SF1->F1_PBRUTO
			Endif
		Else
			If ( nPos := Ascan( aNfsRatPes, { | e | e[1] == SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE } ) ) > 0
				nPesoSD := aNfsRatPes[nPos,2]
			Else
				Aadd( aNfsRatPes, { SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE, 0 } )
				nPos := Len(aNfsRatPes)

				//---- Calcula o Total do Peso dos Itens da Nota
				cAliasSD := GetNextAlias()
				cQuery := "SELECT SUM(SD1.D1_QUANT * B1_PESBRU) PESO  "
				cQuery += "FROM "+RetSqlName("SD1")+ " SD1, "
				cQuery +=         RetSqlName("SB1")+ " SB1 "
				cQuery += "WHERE "
				cQuery += " SD1.D1_FILIAL  = '" + SF1->F1_FILIAL  + "' AND "
				cQuery += " SD1.D1_DOC     = '" + SF1->F1_DOC     + "' AND "
				cQuery += " SD1.D1_SERIE   = '" + SF1->F1_SERIE   + "' AND "
				cQuery += " SD1.D1_FORNECE = '" + SF1->F1_FORNECE + "' AND "
				cQuery += " SD1.D1_LOJA    = '" + SF1->F1_LOJA    + "' AND "
				cQuery += " SD1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
				cQuery += " AND SB1.B1_COD = SD1.D1_COD "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD,.T.,.T.)
				TCSetField(cAliasSD,"PESO"  ,"N",TamSx3("F1_PBRUTO")[1],TamSx3("F1_PBRUTO")[2])
				If (cAliasSD)->(!Eof())
					nPesoSD := (cAliasSD)->PESO
				EndIf
				(cAliasSD)->(DbCloseArea())

				aNfsRatPes[nPos,2] := nPesoSD

				RestArea(aArea)
			EndIf

			nPeso   := ((Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_PESBRU") * nQuant) / nPesoSD)
			nPesoBru:= (SF1->F1_PBRUTO * nPeso)
		Endif
	EndIf
Else
	nPesoBru:= (Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_PESBRU")) * nQuant
EndIf

Return ( nPesoBru )

//--------------------------------------------------------------------
/*/{Protheus.doc} OmsX6Valid
Valida os parâmetros do SIGATMS

@param   cFil      Código da Filial
@param   cPar      Código do parametro
@param   cTipo     Não utilizado
@param   xContPor  Conteudo do parametro em Portugues
@param   xContSpa  Conteudo do parametro em Espanhol
@param   xContEng  Conteudo do parametro em Ingles

@return  lRet      Indica se o conteudo informado é valido ou não.

@author  Rafael Souza
@since   18/11/2013
@version 1.0
/*/
//--------------------------------------------------------------------
Function OmsX6Valid (cFil, cPar, cTipo, xContPor, xContSpa, xContEng)

Local lRet		  := .T.
Local aArea 	  := GetArea()
Local aConteudo	  := {}
Local nCont		  := 1
Local cLanguage	  := " "
Local lMostraErr  := .T. //-- Variavel usada para controlar validacoes que exibem mensagem de help.
Local xConteudo	  := Nil

Default cFil	  := " "
Default cPar	  := " "
Default cTipo	  := " "


Aadd( aConteudo , { xContPor , "PORTUGUES" } )
Aadd( aConteudo , { xContSpa , "ESPANHOL" } )
Aadd( aConteudo , { xContEng , "INGLES" }  )


While lRet .And. nCont <= Len(aConteudo)

	xConteudo 	:= aConteudo[nCont,1]
	cLanguage   := aConteudo[nCont,2]

	Do Case
		Case AllTrim(cPar) == 'MV_CDTPOP'
			lRet:= Empty(xConteudo) .Or. VldExistCp( "GV4", xConteudo , @lMostraErr )
		Case AllTrim(cPar) == 'MV_DESDEV'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT7", xConteudo , @lMostraErr )
		Case AllTrim(cPar) == 'MV_NATDCT'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SED", xConteudo, @lMostraErr  )
		Case AllTrim(cPar) == 'MV_OMSCAPA'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2'
		Case AllTrim(cPar) == 'MV_OSFILVE'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2'
		Case AllTrim(cPar) == 'MV_ROTCEP'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2|3'
	   	Case AllTrim(cPar) == 'MV_SEQENT'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2'
		Case AllTrim(cPar) == 'MV_OMSTPBA'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2'
		Case AllTrim(cPar) == 'MV_ASSCARG'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ 'S|N'
		Case AllTrim(cPar) == 'MV_ALOCPER'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ 'S|N'
		Case AllTrim(cPar) == 'MV_MANCARG'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ 'S|N'
		Case AllTrim(cPar) == 'MV_PESOCAR'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ 'L|B'
		Case AllTrim(cPar) == 'MV_ROTATV'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2|3'
		Case AllTrim(cPar) == 'MV_PRSTORD'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1|2'
		EndCase
		nCont++
EndDo

If !lRet .And. lMostraErr
	Help("",1,"OMSXFUN01")// Conteudo informado invalido! Informe um registro valido.
EndIf

RestArea(aArea)
Return(lRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} VldExistCp STATIC
Valida o ExistCpo

@param   cAliasTab  Código da Tabela
@param   xConteudo  Conteudo informado
@param   lMostraErr Indica se o erro deve ser exibido ou não.

@return  lRet       Indica se o conteúdo informado é valido ou não.

@author  Rafael Souza
@since   18/11/2013
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VldExistCp( cAliasTab , xConteudo , lMostraErr )

Local lRet := .T.

Default cAliasTab 	:= " "
Default xConteudo 	:= " "
Default lMostraErr	:= .T.

lRet := ExistCpo(cAliasTab,xConteudo)

If !lRet
	lMostraErr := .F.
EndIf

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc} OmsCarFat STATIC
Função responsável por verificar se a carga encontra-se com algum pedido faturado

@param   cFilCar   Filial da Carga
@param   cCarga    Código da Carga
@param   cSeqCar   Sequencia da Carga
@param   nVlEntcom Indicador de OMS em Operador Logístico

@return  lRet      Indica se a carga está ou não em algum pedido faturado

@author  amanda.vieira
@version P12
@since   21/12/2018
/*/
//------------------------------------------------------
Static Function OmsCarFat(cFilCar,cCarga,cSeqCar,nVlEntcom)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasSC9 := GetNextAlias()
	cQuery := " SELECT SC9.C9_PEDIDO"
	cQuery +=   " FROM "+RetSqlName("DAI")+" DAI "
	cQuery +=  " INNER JOIN "+RetSqlName("SC9")+" SC9"
	If	nVlEntcom <> 1
		cQuery += " ON SC9.C9_FILIAL = DAI.DAI_FILPV"
	Else
		cQuery += " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	EndIf
	cQuery +=    " AND SC9.C9_PEDIDO  = DAI.DAI_PEDIDO"
	cQuery +=    " AND SC9.C9_CARGA   = DAI.DAI_COD"
	cQuery +=    " AND SC9.C9_SEQCAR  = DAI.DAI_SEQCAR"
	cQuery +=    " AND SC9.C9_SERIENF <> ' '"
	cQuery +=    " AND SC9.C9_NFISCAL <> ' '"
	cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DAI.DAI_FILIAL = '"+cFilCar+"'"
	cQuery +=    " AND DAI.DAI_COD    = '"+cCarga+"'"
	cQuery +=    " AND DAI.DAI_SEQCAR = '"+cSeqCar+"'"
	cQuery +=    " AND DAI.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
	If (cAliasSC9)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasSC9)->(DbCloseArea())
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} OMSParcChq
Encontra uma parcela válida para o título na liquidação com cheques

@param   cPrefixo   Prefixo do título
@param   cNumero    Numero do título
@param   cParcela   Parcela do título
@param   cTipo      Tipo do título

@return  cParcela   Parcela do título

@author  Squad OMS
@since   19/12/2018
@version 1.0
@obs     Utilizado pelo FINXAPI
/*/
//--------------------------------------------------------------------
Function OMSParcChq(cPrefixo,cNumero,cParcela,cTipo)
Local aAreaSE1  := SE1->(GetArea())
Local nTamParc  := TamSX3("E1_PARCELA")[1]
Local nTamPref  := TamSX3("E1_PREFIXO")[1]
Local nTamNume  := TamSX3("E1_NUM"    )[1]
Local nTamTipo  := TamSX3("E1_TIPO"   )[1]
Local ParcZero  := Replicate("0",nTamParc)
Local aParcelas := {}

	// Trata o retorno inválido da parcela pelo FINXAPI
	If Len(cParcela) > nTamParc
		cParcela := ParcZero
	EndIf

	cPrefixo := Padr(cPrefixo,nTamPref)
	cNumero  := Padr(cNumero ,nTamNume)
	cParcela := Padr(cParcela,nTamParc)
	cTipo    := Padr(cTipo   ,nTamTipo)

	// Somente se a parcela já existe
	SE1->(dbSetOrder(1))
	If SE1->(DBSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo))
		// Busca todas as parcelas existentes para o mesmo prefixo/número e armazena num array
		SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumero))
		While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+cPrefixo+cNumero
			If SE1->E1_TIPO == cTipo
				AAdd(aParcelas,Upper(SE1->E1_PARCELA))
			EndIf
			SE1->(DbSkip())
		EndDo
		// Reinicia a variável para começar da parcela 00
		cParcela := ParcZero
		// Tenta encontrar uma parcela válida
		While .T.
			cParcela := Soma1(cParcela)
			If AScan(aParcelas,cParcela) <= 0 .Or. cParcela == "ZZ"
				If cParcela == "ZZ"
					Final("Não foi possível definir um número de parcela para o título: E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO - [VAR01]|[VAR02]|[VAR03]|[VAR04]|[VAR05]. Favor avaliar a necessidade de aumentar o tamanho do campo E1_PARCELA.")
				EndIf
				Exit
			EndIf
		EndDo
	EndIf

RestArea(aAreaSE1)
Return cParcela

//--------------------------------------------------------------------
/*/{Protheus.doc} OsGravaDAK
Realiza a gravação do peso, volume, valor e pontos de entrega da carga posicionada.
A DAK deve encontrar-se posicionada.

@param   Null

@return  lRet   Retorna se a gravação ocorreu (Em 07/12/2020 foi visto que esta variável não é condicionada em nenhum ponto da função.)

@author  amanda.vieira
@since   08/08/2019
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsGravaDAK()
Local lRet       := .T.
Local lAlocVei   := SuperGetMv("MV_ALOCVEI",.F.,.T.)
Local cFilCar    := DAK->DAK_FILIAL
Local cCarga     := DAK->DAK_COD
Local cSeqCar    := DAK->DAK_SEQCAR
Local cVeiculo   := DAK->DAK_CAMINH
Local cWhere     := ""
Local cInner     := ""
Local cAliasCarg := ""		
Local nVlEntcom  := OsVlEntCom(cFilCar)

	If !(nVlEntcom == 1) .And. DAI->(ColumnPos("DAI_FILPV")) > 0
		cInner := " SC9AUX.C9_FILIAL = DAI.DAI_FILPV AND "
	Else
		cWhere := " SC9.C9_FILIAL = '"+xFilial('SC9')+"' AND"
	EndIf
	cInner := "%"+cInner+"%"
	cWhere := "%"+cWhere+"%"
	
	cAliasCarg := GetNextAlias()
	BeginSql Alias cAliasCarg
		SELECT SUM(DAI.DAI_PESO) DAK_PESO,
				SUM(DAI.DAI_CAPVOL) DAK_CAPVOL,
				SUM(SC9AUX.C9_VALOR) DAK_VALOR,
				COUNT(DISTINCT DAI.DAI_CLIENT||DAI.DAI_LOJA) DAK_PTOENT
		FROM %Table:DAI% DAI
		INNER JOIN (SELECT SUM(SC9.C9_QTDLIB * SC9.C9_PRCVEN) C9_VALOR,
							SC9.C9_PEDIDO,
							SC9.C9_FILIAL
					FROM %Table:SC9% SC9
					WHERE %Exp:cWhere%
					SC9.C9_CARGA = %Exp:cCarga%
					AND SC9.C9_SEQCAR = %Exp:cSeqCar%
					AND SC9.%notdel%
					GROUP BY SC9.C9_PEDIDO,
								SC9.C9_FILIAL ) SC9AUX
					ON %Exp:cInner%
					SC9AUX.C9_PEDIDO = DAI.DAI_PEDIDO
		WHERE DAI.DAI_FILIAL = %Exp:cFilCar%
		AND DAI.DAI_COD = %Exp:cCarga%
		AND DAI.DAI_SEQCAR = %Exp:cSeqCar%
		AND DAI.%notdel%
	EndSql
	If (cAliasCarg)->(!EoF())
		DbSelectArea("DAK")
		RecLock("DAK",.F.)
		DAK->DAK_PESO   := (cAliasCarg)->DAK_PESO
		DAK->DAK_CAPVOL := (cAliasCarg)->DAK_CAPVOL
		DAK->DAK_PTOENT := (cAliasCarg)->DAK_PTOENT
		DAK->DAK_VALOR  := A410Arred(( (cAliasCarg)->DAK_VALOR ),"DAK_VALOR")
		DAK->(MsUnlock())
		//Realiza alocação do veículo
		If lAlocVei .And. !Empty(cVeiculo)
			OsVAgenda(cCarga,cSeqCar,cVeiculo,1)
		EndIf
	EndIf
	(cAliasCarg)->(DbCloseArea())
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} OMSNOW STATIC
Retorna uma string contendo a data e hora

@param  lShowDate Mostra data
@param  lShowMs   Mostra milissegundos
@param  cSepDtHr  Define o separador entre data e hora. Default '_'
@param  cSepHr    Define o separador entre hora, minuto e segundo. Default '' 
@param  cSepMS    Define o separador entre segundo e milissegundo. Default cSepDtHr
@param  lFileFmt  T: Formato de arquivo: sem pontuação e data reversa. Ex: 20160127_120101. F: Formato de apresentação em tela. Ex: 27/01/2016 - 12:01:01

@return cRet      String contendo a Data e Hora

@author Wander Horongoso
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OMSNOW(lShowDate, lShowMs, cSepDtHr, cSepHr, cSepMs, lFileFmt)
Local cRet := ""
Local nHH, nMM, nSS, nMS := Seconds()
Default lShowDate := .F.
Default lShowMs   := .T.
Default cSepDtHr  := '_'
Default cSepHr    := ':'
Default cSepMs    := '.'
Default lFileFmt  := .F.

    nHH := Int(nMS / 3600)
    nMS -= (nHH * 3600)
    nMM := Int(nMS / 60)
    nMS -= (nMM * 60)
    nSS := Int(nMS)
    nMS := (nMs - nSS) * 1000

    If lShowDate
		cRet := Iif(lFileFmt, Dtos(Date()),  DtoC(Date()))
		cRet += cSepDtHr
	EndIf
	
    cRet += StrZero(nHH,2) + cSepHr + StrZero(nMM,2) + cSepHr + StrZero(nSS,2)
    If lShowMs
		cRet += cSepMs + StrZero(nMS,3)
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} OMSConout
Grava no arquivo de console uma mensagem incluindo hora da geração, e podendo incluir data da geração.

O parâmetro MV_OMSCMSG não foi documentado propositadamente. Deve-se criar na mão para os casos de
necessidade de log de debug.

@param  cMsg      Mensagem a ser exibida no console
@param  lTamMsg   Se 0, exibe a mensagem. Se maior que 0, limita o tamanho da mensagem e faz com o conout fique formatado, facilitando a extração para planilhas.
@param  lShowDate Mostra data
@param  lShowMs   Mostra milissegundos
@param  cSepDtHr  Define o separador entre data e hora. Default '_'
@param  cSepHr    Define o separador entre hora, minuto e segundo. Default '' 
@param  cSepMS    Define o separador entre segundo e milissegundo. Default cSepDtHr
@param  lFileFmt  T: Formato de arquivo: sem pontuação e data reversa. Ex: 20160127_120101. F: Formato de apresentação em tela. Ex: 27/01/2016 - 12:01:01

@return Null

@author Wander Horongoso
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function OMSConout(cMsg,nTamMsg,cPrefixo,lShowDate, lShowMs, cSepDtHr, cSepHr, cSepMs, lFileFmt)
Default nTamMsg   := 60
Default cPrefixo  := '_OMS_ '
Default lShowDate := .F.
Default lShowMs   := .T.
Default cSepDtHr  := '_'
Default cSepHr    := ':'
Default cSepMs    := '.'
Default lFileFmt  := .F.

	If SuperGetMV('MV_OMSCMSG',.F.,.F.) 
		cMsg := cPrefixo + cMsg
		If nTamMsg > 0
			cMsg += Replicate(' ', nTamMsg)
			cMsg := Substr(cMsg,1,nTamMsg)
		EndIf

		LogMsg( "OMSConout",0, 0,1, cValToChar(TIME()), '', cMsg + OMSNow(lShowDate, lShowMs, cSepDtHr, cSepHr, cSepMs, lFileFmt))

	EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OMSINITFUN ºAutor  ³ TOTVS S/A        º Data ³  21/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa as funcoes de inicializacao do modulo SIGAOMS       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMSINITFUN()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//³              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("MA215CHECK")
    MA215CHECK()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  OMSLOAD    ºAutor  ³                    º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa a sincronizacao das tabelas entre Protheus e       º±±
±±º          ³TOP.     E ativa os gatilhos das tabelas de cadastro do     º±±
±±º          ³Protheus.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMSLOAD()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//³              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("MA215CHECK")
    MA215CHECK()
EndIf

Return


// ---------------------------------------------------------
/*/{Protheus.doc} OMSOrigTPR
Informa se a origem da carga é do TPR
@author Equipe OMS
@since 16/11/2021
@version 1.0
/*/
// ---------------------------------------------------------
Function OMSOrigTPR()
	Local lRet := .F.
	Local aArea := GetArea()
	
	DbSelectArea("DAK")
	lRet := ColumnPos("DAK_INTTPR") > 0 .And. X3USO(GetSX3Cache("DAK_INTTPR", "X3_USADO")) .And. DAK->DAK_INTTPR == "1"

	RestArea(aArea)

Return lRet

