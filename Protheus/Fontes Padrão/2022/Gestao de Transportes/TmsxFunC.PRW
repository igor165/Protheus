#include "PROTHEUS.ch"
#include "TMSXFUNC.CH"
#Include "AP5MAIL.CH"
#Include "XMLXFUN.CH"
#Include "FileIO.ch"

// Variaveis nao devem ser removidas, utilizadas para geracao do sequencial do identificador de carga.
Static __lNoErro
Static lxProxIdVc,lFProxIdVc
Static __lArquivo := .F.
Static lAWBRepete := DT8->(FieldPos("DT8_CODCIA")) > 0 .And. DT8->(FieldPos("DT8_LOJCIA")) > 0
Static lRestricao := .F. //-- Verifica se possui a funcionalidade de Restricoes
Static lRestRepom := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSMovViag³ Autor ³ Antonio C Ferreira    ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gerar a Movimentacao de Entrega.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMovViag()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial Origem                                      ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±³          ³ ExpC3 = Codigo da atividade                                ³±±
±±³          ³ ExpA1 = Array contendo os Documentos                       ³±±
±±³          ³ ExpN1 = Item                                               ³±±
±±³          ³ ExpN2 = Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSMovViag( cFilOri, cViagem, cCdAtiv, aDoc, nItem, nOpcx, lGeraDUD, cFilAtu, lDestAli )

Local cFilDca		:= ''
Local cFilDes		:= ''
Local cTipTra		:= ''
Local cSerTms		:= ''
Local cServic		:= ''
Local cSeek			:= ''
Local cStatus		:= ''
Local lErroNf		:= .F.
Local lAchouDUD		:= .F.
Local nA			:= 0
Local nTam			:= 0
Local lDocBlq		:= .F. 				//-- Obtem os Documentos Nao Bloqueados.
Local cAtivDca		:= GetMV('MV_ATIVDCA',,'')
Local cAtivSai		:= GetMV('MV_ATIVSAI',,'')
Local cAtivChg		:= GetMV('MV_ATIVCHG',,'')
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')
Local cAtivCar		:= SuperGetMv('MV_ATIVCAR',,'')
Local lTmsCdCa		:= GetMv('MV_TMSCDCA',,.T.) // Motorista generico.
local lRet        := .T.
Local lAlianca    := TmsAlianca() //-- Verifica se utiliza Alianca
Local nI          := 0
Local cArmazem    := ""
Local lTMALOCAL   := ExistBlock('TMALOCAL')
Local lRedesp     := GetMV("MV_REDESP",,.T.) //-- Controla Redespacho ? (Utilizacao Modulo de Transporte)
Local nPercur     := 0
Local cEndere     := ''
Local aAreaDTC    := {}
Local cSqEDes     := ''
Local aAreaDTW    := {}
Local cUltSeq     := ''
Local cStatusDTQ  := ''
Local cQuery		:= ''
Local cAliasDUD
Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Local cAtvSaiApo := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio

Local aArea := {}
Local aAreaDA8 := DA8->(GetArea())

DEFAULT cCdAtiv	:= ''
DEFAULT aDoc		:= {}
DEFAULT nItem		:= 1
DEFAULT nOpcx		:= 3
DEFAULT lGeraDUD	:= .F.
DEFAULT cFilAtu	:= cFilAnt
DEFAULT lDestAli	:= .F.

DTQ->(DbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))

	If cCdAtiv == cAtivSai .Or. cCdAtiv == cAtvSaiCli .Or. cCdAtiv == cAtvSaiApo
		If nOpcx == 3 // Inclusao de uma atividade de saida

			// Saida de Cliente - Verifica manifesto gerado
			If cCdAtiv == cAtvSaiCli .Or. cCdAtiv == cAtvSaiApo
				lRet := TMSExstMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)

				If lRet
					//-- Valida UF's validas do manifesto
					lRet	:= VldUFManif(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)

				EndIf

			EndIf

			If lRet

				RecLock("DTQ", .F.)
				DTQ->DTQ_STATUS := StrZero(2, Len(DTQ_STATUS))  // Em Transito
				MsUnlock()

				//-- Atualiza Gestão de Demandas
				If lMVITMSDMD .And. FindFunction("PlnDmdTran") .And. TableInDic("DL9")
					PlnDmdTran(TVgGetPlnD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM),  '7') //Saída Viagem -> Muda Planejamento da Demanda para "Em transito"
				EndIf						

				DT5->(dbSetOrder(4)) //DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
				DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
				DUD->(dbSetOrder(2)) //DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
				DUD->(MsSeek(cSeek := xFilial('DUD')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
				While DUD->(! Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeek)
					If DT5->(MsSeek(xFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
						If DT5->DT5_STATUS <> StrZero(4,Len(DT5->DT5_STATUS)) .And. ; //-- Encerrado
							DT5->DT5_STATUS <> StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado
							RecLock("DT5",.F.)
							DT5->DT5_STATUS := StrZero(3,Len(DT5->DT5_STATUS)) // Em Transito
								MsUnLock()
						EndIf
					ElseIf DUD->DUD_STATUS != StrZero(3,Len(DUD->DUD_STATUS)) // Carregado
						DUD->(DbSkip())
						Loop
					EndIf

					// Atualiza status de movimentos de viagens de transporte ou entrega
					If DUD->DUD_STATUS <> StrZero(4,Len(DUD->DUD_STATUS)) .AND. DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS))  // 4-Encerrado; 9-Cancelado
						RecLock("DUD",.F.)
						DUD->DUD_STATUS := StrZero(2,Len(DUD->DUD_STATUS)) // Em Transito
						MsUnLock()
					EndIf

					// Atualiza status dos documentos da viagem
					If DT6->(MsSeek(xFilial('DT6')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE))) .And. ;
						DT6->DT6_STATUS != StrZero(3,Len(DTQ->DTQ_STATUS)) // Em Transito
						RecLock('DT6',.F.)
						DT6->DT6_STATUS := StrZero(3,Len(DTQ->DTQ_STATUS)) // Em Transito         
						DT6->DT6_ULTEMB := dDataBase
						MsUnLock()
					EndIf
					DUD->(DbSkip())
				EndDo
			ElseIf cCdAtiv == cAtvSaiCli .Or. cCdAtiv == cAtvSaiApo .And. Posicione("DA8",1,xFilial("DA8") + DTQ->DTQ_ROTA,"DA8_ROTMUN") != StrZero(1, Len(DA8->DA8_ROTMUN))
				Help( "", 1, 'TMSXFUNC190', , STR0133, 1, 0, , , , , , { STR0134 } ) //STR0133"Verifique o Manifesto." STR0134 "Apontamento de Saída por cliente só é permitido após a geração do manifesto eletrônico."
			EndIf
		ElseIf nOpcx == 5 // Estorno de uma atividade de saida

			//-- Verifica se existe atividade anterior apontada
			aAreaDTW  := DTW->(GetArea())
			cUltSeq   := DTW->(DTW_SEQUEN)
			cStatusDTQ:= StrZero(5, Len(DTQ->DTQ_STATUS)) //Fechada

			DTW->(dbSetOrder(3))
			DTW->(dbSeek(xFilial("DTW")+DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + cUltSeq))
			DTW->(dbSkip(-1))
			If DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) == xFilial("DTW") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM .And. ;
				DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS))

				If DTW->DTW_ATIVID == cAtivChg .Or. DTW->DTW_ATIVID == cAtivDca .Or. DTW->DTW_ATIVID == cAtvSaiCli .Or.  DTW->DTW_ATIVID == cAtvSaiApo .Or. ((cFilAnt <> DTQ->DTQ_FILORI) .And. (DTW->DTW_ATIVID = cAtivCar)) 
					cStatusDTQ := StrZero(4, Len(DTQ->DTQ_STATUS)) //Chegada em Filial
				EndIf
			EndIf
			
			RestArea(aAreaDTW)
			//--
		
			RecLock("DTQ", .F.)
			DTQ->DTQ_STATUS := cStatusDTQ
			DTQ->DTQ_FILATU := cFilAtu
			MsUnlock()

			//-- Atualiza Gestão de Demandas
			If lMVITMSDMD .And. FindFunction("PlnDmdTran") .And. TableInDic("DL9")
				PlnDmdTran(TVgGetPlnD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM),  '3') //Estorno Saída Viagem -> Muda Planejamento da Demanda para "Em viagem"
			EndIf				

			DT5->(dbSetOrder(4)) //DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
			DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			DUD->(dbSetOrder(2)) //DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
			DUD->(MsSeek(cSeek := xFilial('DUD')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
			While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeek)
				If DT5->(MsSeek(xFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE))) // Atualiza status da Solicitacao de Coleta
					If DT5->DT5_STATUS <> StrZero(4,Len(DT5->DT5_STATUS)) .And. ; // Encerrada
						DT5->DT5_STATUS <> StrZero(5,Len(DT5->DT5_STATUS)) // Documento Informado
						RecLock("DT5",.F.)
						DT5->DT5_STATUS := StrZero(2,Len(DT5->DT5_STATUS)) // Indicada para Coleta
						MsUnLock()
					EndIf
					If DUD->DUD_STATUS <> StrZero(4,Len(DUD->DUD_STATUS)) // Encerrado
						RecLock("DUD",.F.)
						DUD->DUD_STATUS := StrZero(1,Len(DUD->DUD_STATUS)) // Em Aberto
						MsUnLock()
					EndIf
				ElseIf DUD->DUD_STATUS != StrZero(2,Len(DUD->DUD_STATUS)) .Or. ; // Em Transito
				   	(!Empty(DUD->DUD_FILFEC) .And. DUD->DUD_FILFEC <> cFilAtu)
					DUD->(DbSkip())
					Loop
				EndIf

				// Atualiza status de movimentos de viagens de transporte ou entrega
				If DUD->DUD_SERTMS <> StrZero(1,Len(DUD->DUD_SERTMS))
					RecLock("DUD",.F.)
					DUD->DUD_STATUS := StrZero(3,Len(DUD->DUD_STATUS)) // Carregado
					MsUnLock()
				EndIf

				If DT6->(MsSeek(xFilial('DT6')+DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )
					RecLock('DT6', .F.)
					If DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS)) // Viagem Coleta
						DT6->DT6_STATUS := StrZero(1,Len(DT6->DT6_STATUS)) // Em Aberto
					ElseIf DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) // Viagem Transporte
						DT6->DT6_STATUS := StrZero(2,Len(DT6->DT6_STATUS)) // Carregado
					ElseIf DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS)) // Viagem Entrega
						DT6->DT6_STATUS := StrZero( 6, Len(DT6->DT6_STATUS) ) // Indicado para Entrega						
					EndIf
					DT6->DT6_ULTEMB := CriaVar("DT6_ULTEMB",.F.)
					MsUnLock()
				EndIf
				DUD->(DbSkip())
			EndDo
		EndIf

	ElseIf cCdAtiv == cAtivChg

		If cFilOri <> cFilAtu .And. DTQ->DTQ_SERTMS == StrZero( 2, Len( DTQ->DTQ_SERTMS ) )
			If Empty( aDoc )
				TMSVerMov( cFilOri, cViagem,,,, lDocBlq , @aDoc, .F. , nOpcx==5 )
				nTam := Len( aDoc )
			Else
				nTam := nItem
			EndIf

			DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			DUD->(DbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM

			For nA := nItem To nTam

				//-- Ponto de Entrada utilizado para retornar o Armazem
				If lTMALOCAL
					cArmazem := ExecBlock( 'TMALOCAL', .F., .F., { aDoc[nA][1], aDoc[nA][2], aDoc[nA][3] } )
				EndIf

				//-- Caso nao exista o Doc na filial atual, sera criado.
				If nOpcx == 3
					lAchouDUD := .F. 
					cAliasDUD :=GetNextAlias()
					cQuery := " SELECT MAX(R_E_C_N_O_) RECNO_DUD FROM " + RetSqlName('DUD')
					cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD')	+ "' "
					cQuery += "   AND DUD_FILDOC = '" + aDoc[nA][1]		+ "' "
					cQuery += "   AND DUD_DOC    = '" + aDoc[nA][2]		+ "' "
					cQuery += "   AND DUD_SERIE  = '" + aDoc[nA][3]		+ "' "
					cQuery += "   AND DUD_FILATU = '" + cFilAtu			+ "' "
					cQuery += "   AND DUD_SERTMS <> '" + StrZero(2, Len(DUD->DUD_SERTMS)) + "'"
					cQuery += "   AND DUD_STATUS NOT IN ('" + StrZero(9, Len(DUD->DUD_STATUS)) + "','" +StrZero(4, Len(DUD->DUD_STATUS)) + "')"
					cQuery += "   AND D_E_L_E_T_ <> '*' "					
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasDUD, .T., .F. )
					
					If (cAliasDUD)->RECNO_DUD > 0
						lAchouDUD := .T.
						DUD->( DbGoTo( (cAliasDUD)->RECNO_DUD ) )						 
					EndIf				
					(cAliasDUD)->( DbCloseArea() )
				Else
					lAchouDUD := DUD->( MsSeek(xFilial("DUD") + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3] + cFilAtu ) )
				EndIf

				If lAchouDUD .And. nOpcx == 5 .And. !Empty(DUD->DUD_VIAGEM)
					Final(STR0001 + chr(13)+chr(10) + STR0002 + " " + DUD->(DUD_FILDOC+"-"+DUD_DOC+"/"+DUD_SERIE))  //-- 'Ja existe Viagem registrada para esse Documento! Operacao Abortada.'
				EndIf

				If	( !lAchouDUD .And. nOpcx == 3 ) .Or. ( lAchouDUD .And. nOpcx == 5 ) .Or. ;
					( !lAchouDUD .And. lGeraDUD   )


					If nOpcx == 5

						DUD->( RecLock('DUD',.F.) )
						DUD->( DbDelete() )
						DUD->( MsUnLock() )

						//-- Se nao for viagem de transporte aereo
						If DTQ->DTQ_TIPTRA != StrZero( 2, Len( DTQ->DTQ_TIPTRA ) )
							//-- Estornar nota fiscal de entrada.
							TMSGerNFEnt(nOpcx,.T.,aDoc[nA][1], aDoc[nA][2], aDoc[nA][3],,,,,cArmazem)
						EndIf

						// Retorna para carregado do documento da viagem de transporte
						DUD->( MsSeek(xFilial("DUD") + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3] + cFilOri + cViagem ) )
						RecLock('DUD',.F.)
						DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) ) //-- Em Transito
						MsUnLock()

						cTipTra := aDoc[ nA, 4 ]
						cFilDes := aDoc[ nA, 6 ]
						cFilDca := aDoc[ nA, 7 ]
						nPercur := 0

						If cFilDca == cFilAtu
							If cFilDes == cFilDca
								cSerTms := StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Entrega
							ElseIf lAlianca .And. DTA->(FieldPos("DTA_FILDPC")) > 0 .And. ; //-- Verifica se a eh Entrega Alianca
									TmsDocAli( DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, @nPercur ) .And. nPercur == 1 .And. ; //-- Documento Alianca
									AllTrim(cFilDca) <> AllTrim(Posicione("DTA",1,xFilial("DTA")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE+cFilOri+cViagem,"DTA_FILDPC"))
								cSerTms := StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Entrega
							Else
								cSerTms := StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) // Transporte
							EndIf
						EndIf

						// Atualiza  Status do CTRC
						DT6->( MsSeek(xFilial("DT6") + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3]) )
						RecLock('DT6',.F.)
						DT6->DT6_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) //-- Em Transito
						//-- Grava bloqueio de documento igual a 2 Nao
						If cTiptra <> StrZero( 2, Len( DUD->DUD_TIPTRA ) )  .And. ( cSerTms == Strzero( 2, Len(DUD->DUD_SERTMS) ) .Or. ;
							cSerTms == StrZero( 3, Len(DUD->DUD_SERTMS) ) )
							If DT6->DT6_QTDVOL > 0 .And. DT6->DT6_BLQDOC <> StrZero(1,Len(DT6->DT6_BLQDOC))
								DT6->DT6_BLQDOC := StrZero(2,Len(DT6->DT6_BLQDOC))
							EndIf
						EndIf
						MsUnLock()

					Else
						cFilDes := aDoc[ nA, 6 ]
						cFilDca := aDoc[ nA, 7 ]
						cServic := aDoc[ nA, 8 ]
						nPercur := 0

						If ( cFilDca == cFilAtu ) .Or. ( lDestAli )
							cServic := ''
							If ( cFilDes == cFilDca ) .Or. ( lDestAli )
								cSerTms := StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Entrega
								cStatus := StrZero( 5, Len( DT6->DT6_STATUS ) ) // Chegada Final
							ElseIf lAlianca .And. DTA->(FieldPos("DTA_FILDPC")) > 0 .And. ; //-- Verifica se a eh Entrega Alianca
									TmsDocAli( aDoc[nA][1], aDoc[nA][2], aDoc[nA][3], @nPercur ) .And. nPercur == 1 .And. ; //-- Documento Alianca
									AllTrim(cFilDca) <> AllTrim(Posicione("DTA",1,xFilial("DTA")+aDoc[nA][1]+aDoc[nA][2]+aDoc[nA][3]+cFilOri+cViagem,"DTA_FILDPC"))
								cSerTms := StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Entrega
								cStatus := StrZero( 5, Len( DT6->DT6_STATUS ) ) // Chegada Final
							Else
								cSerTms := StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) // Transporte
								cStatus := StrZero( 4, Len( DT6->DT6_STATUS ) ) // Chegada Parcial
							EndIf
						Else
							cSerTms := StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) // Transporte
							cStatus := StrZero( 4, Len( DT6->DT6_STATUS ) ) // Chegada Parcial
							Loop
						EndIf

						cTipTra := aDoc[ nA, 4 ]

						//-- Se for Chegada de Viagem Fluvial, gerar um DUD de Entrega 'RODOVIARIO'
						If DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_TIPTRA)) .And. DTQ->DTQ_TIPTRA == StrZero(3, Len(DTQ->DTQ_TIPTRA))
							If AliasInDic('DF7')
								cTipTra := StrZero(3, Len(DTQ->DTQ_TIPTRA))
							Else
								cTipTra := StrZero(1, Len(DTQ->DTQ_TIPTRA))
							EndIf
						EndIf

						//-- Se a filial de Descarga for diferente da filial Destino, atualiza o tipo
						//-- de transporte com o tipo de redespacho informado no cad. de rotas
						If cFilDca <> cFilDes
							cCdrDes := aDoc[ nA, 5 ]
							aRegiao := TMSNivSup( cCdrDes )
							DUN->(DbSetOrder(1)) //DUN_FILIAL+DUN_ROTEIR+DUN_CDRDES
							For nI := 1 To Len( aRegiao )
								If DUN->( MsSeek( xFilial('DUN') + DTQ->DTQ_ROTA + aRegiao[ nI ], .F. ) )
									//-- Se NAO controla Redespacho (MV_REDESP) e o 'Tp. de Redesp' da Rota for igual a '0'
									If !lRedesp .And. DUN->DUN_REDESP == StrZero(0, Len(DUN->DUN_REDESP))
										cSerTMS := StrZero(3,Len(DTQ->DTQ_SERTMS)) // Entrega
									ElseIf DUN->DUN_REDESP <> StrZero(0, Len(DUN->DUN_REDESP))
										cTipTra := DUN->DUN_REDESP
									EndIf
									Exit
								EndIf
							Next
						EndIf

						lErroNf := .F.

						//-- Se nao for uma viagem de transporte aereo
						If	DTQ->DTQ_TIPTRA != StrZero( 2, Len( DTQ->DTQ_TIPTRA ) )
							//-- Gera nota fiscal de entrada.
							lErroNf := !TMSGerNFEnt(nOpcx,.F.,aDoc[nA][1], aDoc[nA][2], aDoc[nA][3],,,,,cArmazem)

							If lErroNf .And. !__TTSInUse
								//-- Gera nota fiscal de entrada.
								TMSGerNFEnt(5, .T., aDoc[nA][1], aDoc[nA][2], aDoc[nA][3],,,,,cArmazem)
							EndIf
						EndIf

						If !lErroNf
							//-- Grava movimento de viagem
							RecLock('DUD', .T.)
							DUD->DUD_FILIAL := xFilial('DUD')
							DUD->DUD_FILORI := cFilAtu
							DUD->DUD_FILDOC := aDoc[nA][1]
							DUD->DUD_DOC    := aDoc[nA][2]
							DUD->DUD_SERIE  := aDoc[nA][3]
							DUD->DUD_SERTMS := cSerTms
							DUD->DUD_TIPTRA := cTipTra
							DUD->DUD_CDRDES := aDoc[nA][5]
							DUD->DUD_CDRCAL := aDoc[nA][9]
							DUD->DUD_SERVIC := cServic
							DUD->DUD_FILVGE := cFilOri
							DUD->DUD_NUMVGE := cViagem
							DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) //-- Status do documento igual a 1 - Em aberto
							DUD->DUD_GERROM := StrZero( 2, Len( DUD->DUD_GERROM ) ) //-- Nao
							//-- Verificar se o documento foi enderecado
							cEndere := '1'
							If TMSSldDist(aDoc[nA][1],aDoc[nA][2],aDoc[nA][3],.F.)
								If !TMSLocaliz('',aDoc[nA][1], aDoc[nA][2] ,aDoc[nA][3])
									cEndere := '0'
								EndIf
							EndIf
							DUD->DUD_ENDERE := cEndere
							DUD->DUD_DOCTRF := StrZero( 2, Len( DUD->DUD_DOCTRF ) ) //-- Nao
							//-- A filial atual do documento eh utilizada pela rotina de estorno de operacoes de transporte, para
							//-- nao permitir estornar a operacao de chegada de viagem, se ja foram incluidos documentos nessa viagem
							If	DUD->(FieldPos('DUD_FILATU'))>0
								DUD->DUD_FILATU := cFilAnt
							EndIf
							//-- Grava o CEP de entrega
							If	DUD->(FieldPos('DUD_CEPENT')) > 0
								aAreaDTC := DTC->(GetArea())

								cSqEDes:= ''
																
								If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(aDoc[nA][1], aDoc[nA][2], aDoc[nA][3])
									dbSelectArea("DTC")
									DTC->(dbSetOrder(3)) // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
									If DTC->(MsSeek(xFilial('DTC') + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3] ))
										If DTC->(FieldPos('DTC_SQEDES')) > 0
											cSqEDes:= DTC->DTC_SQEDES
										EndIf
									EndIf
								Else
									DbSelectArea("DY4")
									DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
									If DY4->(MsSeek(xFilial('DY4') + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3] ))
										If DY4->(FieldPos('DY4_SQEDES')) > 0
											cSqEDes:= DY4->DY4_SQEDES
										EndIf
									EndIf
								EndIf
								DUD->DUD_CEPENT := TmsCEPEnt(aDoc[nA][10],aDoc[nA][11],,,cSqEDes)

								RestArea(aAreaDTC)
							EndIf
							DUD->( MsUnLock() )

							// Encerra documento da viagem de transporte
							aArea := GetArea()
							cAliasDUD := GetNextAlias()
							cQuery := " SELECT MAX(R_E_C_N_O_) RECNO_DUD "
							cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
							cQuery += "  WHERE DUD_FILIAL = '" + xFilial("DUD")	+ "' "
							cQuery += "    AND DUD_FILDOC = '" + aDoc[nA][1] + "' "
							cQuery += "    AND DUD_DOC    = '" + aDoc[nA][2] + "' "
							cQuery += "    AND DUD_SERIE  = '" + aDoc[nA][3] + "' "
							cQuery += "    AND DUD_FILORI = '" + cFilOri + "' "
							cQuery += "    AND DUD_VIAGEM = '" + cViagem + "' "
							cQuery += "    AND DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "' "
							cQuery += "    AND DUD.D_E_L_E_T_ <> '*' "					
							cQuery := ChangeQuery(cQuery)
							DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD,.T.,.F.)
							If (cAliasDUD)->RECNO_DUD > 0
								DUD->(DbGoTo((cAliasDUD)->RECNO_DUD))
								RecLock("DUD",.F.)
								DUD->DUD_STATUS := StrZero(4,Len(DUD->DUD_STATUS))	//-- Encerrado
								DUD->(MsUnLock())
							EndIf
							(cAliasDUD)->(DbCloseArea())
							RestArea(aArea)

							// Atualiza  Status do CTRC
							If DT6->( MsSeek(xFilial("DT6") + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3]) )
								//-- Se documento com status entregue, devido ocorrencia encerra entrega, nao alterar para chegada final.
								If nOpcx == 3 .And. DT6->DT6_STATUS == StrZero( 7, Len( DTQ->DTQ_SERTMS ) ) .And. cStatus == StrZero( 5, Len( DTQ->DTQ_SERTMS ) )
									cStatus := StrZero( 7, Len( DTQ->DTQ_SERTMS ) ) // Entregue
								EndIf
								RecLock('DT6',.F.)
								DT6->DT6_STATUS := cStatus
								//-- Grava bloqueio de documento igual a 3 descarregando
								If	cCdAtiv == cAtivChg .And. cTiptra <> StrZero( 2, Len( DUD->DUD_TIPTRA ) )  .And. ( ;
									cSerTms == Strzero( 2, Len(DUD->DUD_SERTMS) ) .Or. ;
									cSerTms == StrZero( 3, Len(DUD->DUD_SERTMS) ) )
									If	DT6->DT6_QTDVOL > 0 .And. lTmsCdCa .And. DT6->DT6_BLQDOC <> StrZero(1,Len(DT6->DT6_BLQDOC))
										DT6->DT6_BLQDOC := StrZero(3,Len(DT6->DT6_BLQDOC))
									EndIf
								EndIf
								MsUnLock()
							EndIf

						EndIf

						lRet := !lErroNf

					EndIf

				EndIf
			Next
		EndIf

		If !lErroNf

			If nOpcx == 3 //-- Apontamento
				// Altera o Status da Viagem para Chegada em Filial
				RecLock("DTQ", .F.)
				If DTQ->DTQ_STATUS != '3'
					DTQ->DTQ_STATUS := StrZero( 4, Len( DTQ->DTQ_STATUS ) ) //-- Chegada em Filial
				EndIf

				DTQ->DTQ_FILATU := cFilAtu
				MsUnLock()
			ElseIf nOpcx == 5 //-- Estorno
				// Retorna o Status da Viagem para Em Transito
				RecLock("DTQ", .F.)
				DTQ->DTQ_STATUS := StrZero( 2, Len( DTQ->DTQ_STATUS ) ) //-- Em Transito
				DTW->(dbSkip(-1))
				DTQ->DTQ_FILATU := DTW->DTW_FILATI
				DTW->(dbSkip())
				MsUnLock()
			EndIf
		EndIf

	ElseIf cCdAtiv == cAtvChgCli .Or. cCdAtiv == cAtvChgApo
	
		If nOpcx == 3 //-- Apontamento
			// Altera o Status da Viagem para Chegada em Filial
			RecLock("DTQ", .F.)

			If DTQ->DTQ_STATUS != '3'
				DTQ->DTQ_STATUS := StrZero( 4, Len( DTQ->DTQ_STATUS ) ) //-- Chegada em Filial
			EndIf

			DTQ->DTQ_FILATU := cFilAtu
			MsUnLock()
		ElseIf nOpcx == 5 //-- Estorno
			// Retorna o Status da Viagem para Em Transito
			RecLock("DTQ", .F.)
			DTQ->DTQ_STATUS := StrZero( 2, Len( DTQ->DTQ_STATUS ) ) //-- Em Transito
			DTW->(dbSkip(-1))
			DTQ->DTQ_FILATU := DTW->DTW_FILATI
			DTW->(dbSkip())
			MsUnLock()
		EndIf
				
	//-- Apontamento da atividade de descarregamento
	ElseIf cCdAtiv == cAtivDca

		If Empty( aDoc )
			TMSVerMov( cFilOri, cViagem, , , , lDocBlq, @aDoc, .F., .T. )
			nTam := Len( aDoc )
		Else
			nTam := nItem
		EndIf

		For nA := nItem To nTam
			cFilDca := aDoc[ nA, 7 ]
			//-- Procura o documento da filial original da viagem e verifica se esta com status encerrado
			DUD->(DbSetOrder(1))
			If	cFilDca == cFilAtu .And. DUD->( MsSeek( xFilial('DUD') + aDoc[nA,1] + aDoc[nA,2] + aDoc[nA,3] + cFilOri + cViagem ) ) .And.;
				DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS))
				//-- Procura o documento gerado na filial atual da viagem e verifica se esta com status em aberto
				If	DUD->( MsSeek( xFilial('DUD') + aDoc[nA,1] + aDoc[nA,2] + aDoc[nA,3] + cFilAtu ) ) .And.;
					DUD->DUD_STATUS == StrZero(1,Len(DUD->DUD_STATUS)) .And. (DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .Or. DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS)))
					//-- Desbloqueia o documento
					DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					If	DT6->( MsSeek( xFilial('DT6') + aDoc[nA,1] + aDoc[nA,2] + aDoc[nA,3] ) )
						//caso nao haja saldo para entrega o documento esta bloqueado, nao desbloqueia pois podem existir pendencias em aberto
						//que iram desbloquear o documento
						If DT6->DT6_QTDVOL > 0 .And. DT6->DT6_BLQDOC <> StrZero(1,Len(DT6->DT6_BLQDOC))
							RecLock('DT6',.F.)
							DT6->DT6_BLQDOC := StrZero(2,Len(DT6->DT6_BLQDOC))
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea(aAreaDA8)

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGerNFEn³ Autor ³ Patricia Salomao/Alex ³ Data ³08.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Nota Fiscal de Entrada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSGerNFEnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1- Opcao Selecionada                                    ³±±
±±³          ³ExpL1- Valida se realiza ou nao o enderecamento dos produtos³±±
±±³          ³ExpC1- Filial do Documento                                  ³±±
±±³          ³ExpC2- No. do Documento                                     ³±±
±±³          ³ExpC3- Serie do Documento                                   ³±±
±±³          ³ExpC4- Numero da Nota Fiscal                                ³±±
±±³          ³ExpC5- Serie da Nota Fiscal                                 ³±±
±±³          ³ExpC6- Cliente Remetente                                    ³±±
±±³          ³ExpC7- Loja do Cliente Remetente                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSGerNFEnt(nOpcx,lEnderecar,cFilDoc,cDoc,cSerie,cNumNFC,cSerNFC,cCliRem,cLojRem,cArmazem)

Static lExecBlock	:= NIL

Local   aCab		:= {}
Local   aItSD1		:= {}
Local   aLinSD1		:= {}
Local   cTes		:= GetMV("MV_TESDR",,"")
Local   aAreaDTC	:= DTC->(GetArea())
Local   nSeekNF		:= 0
Local   aNFs		:= {}
Local   aDadosNF	:= {}
Local   lLimpaArm	:= .F.
Local   aAreaSBZ
Local	nItem	    := 0
Local   lUnitiz		:= FindFunction("TmsChkVer") .And. TmsChkVer('11','R7') .And. 	!IsInCallStack('TMSA050') .And. !IsInCallStack('TMSA360')
Local   lLocaliz	:= SuperGetMv('MV_LOCALIZ',.F.,'N') == 'S'
Local   lCtrlEst	:= .F.
Local	cTabela		:= "" 
Local	bWhile		:= {}

Default cArmazem	:= ""
Default cFilDoc	:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cNumNFC	:= ""
Default cSerNFC	:= ""
Default cCliRem	:= ""
Default cLojRem	:= ""
Default lEnderecar	:= .T.

Private lMsErroAuto	:= .F.

// Verifica a existencia do EXECBLOCK
If (lExecBlock== NIL)
	lExecBlock := ExistBlock("TMSGERNFE")
EndIf

SF4->( DbSetOrder( 1 ) )
If	SF4->( ! MsSeek( xFilial('SF4') + cTes, .F. ) )
	Help(' ',1,'TMSA20015',,STR0006 + cTes,5,11)	 //"Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4).###" TES : "
	Return(.F.)
EndIf
//-- Nao controla estoque
If SF4->F4_ESTOQUE == 'N' .And. !lLocaliz
	Return(.T.)
Else
	lCtrlEst := SF4->F4_ESTOQUE == 'S'
EndIf
//-- Verifica a configuracao do TES
If	! TmsChkTES('1')
	Return(.F.)
EndIf

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)	
		DTC->(dbSetOrder(7)) //DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SERNFC
		DTC->(MsSeek(cSeekDTC:=xFilial('DTC')+cDoc+cSerie+cFilDoc))
		bWhile   := {|| !DTC->(Eof()).And. DTC->(DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC) == cSeekDTC  }  
		cTabela := "DTC"
	Else
		DbSelectArea("DY4")
		DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
			If DY4->( MsSeek( cSeekDTC:=xFilial("DY4")+ cFilDoc + cDoc + cSerie ) )
				bWhile   := {|| !DY4->(Eof()).And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeekDTC  }
				cTabela := "DY4"
	   		Endif
		Endif				
	Endif	
Else
	DTC->(dbSetOrder(2)) //DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC
	DTC->(MsSeek(cSeekDTC:=xFilial('DTC')+cNumNFC+cSerNFC+cCliRem+cLojRem))
	bWhile   := {|| !DTC->(Eof()).And. DTC->(DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) == cSeekDTC }
	cTabela := "DTC"
EndIf

aLinSD1	:= {}
aItSD1	:= {}

While Eval(bWhile)
	If cTabela == "DY4" //verifica se o looping esta percorrendo os registros da tabela DY4
		DbSelectArea("DTC")
		DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
		//posiciona na DTC a partir da DY4				
		DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO))		
	Endif	
	
	If DTC->DTC_QTDVOL <= 0
 		If cTabela == "DY4"
 			DY4->(dbSkip())
			Loop
 		Else
 			DTC->(dbSkip())
			Loop
		EndIf
	EndIf

	//-- Zera o conteudo da variavel armazem. Utilizado qdo nao informado o armazem no parametro.
	If lLimpaArm
		cArmazem  := ""
		lLimpaArm := .F.
	EndIf

	nSeekNF := Ascan(aNFs, {|x| x[1]+x[2]+x[3]+x[4] == DTC->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) })
	If nSeekNF == 0
		AADD(aNFs, {DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM, DTC->DTC_LOJREM})
	EndIf

 	AADD(aDadosNF,  {DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO, ;
 						DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE, DTC->DTC_QTDVOL, DTC->DTC_VALOR } )

	//-- Cabecalho da nota fiscal de entrada.
	If nSeekNF == 0	.And. lCtrlEst

	   //-- Se o While estiver sendo feito por Fildoc+Doc+Serie, e esta nota for diferente
	   //-- da Nota contida no array aCab, Gravar a Nota Fiscal Contida no Array aCab.
	   //-- Isto devera' ser feito, para controlar a Gravacao de Notas Diferentes com Documentos iguais.
	   If !Empty(cFildoc) .And. !Empty(cDoc) .And. !Empty(cSerie) .And. !Empty(aCab)

	      // Gera Nota Fiscal de Entrada / Enderacamento
			If !TMSGrvNFEnt(nOpcx, aCab, aItSD1, aDadosNF, lEnderecar)
				Return ( .F. )
			Else
				// Executa Ponto de entrada pos geracao/exclusao de NF do cliente
				If lExecBlock
					ExecBlock("TMSGERNFE",.F.,.F.,{aDadosNf[Len(aDadosNf),1],aDadosNf[Len(aDadosNf),2],aDadosNf[Len(aDadosNf),3],aDadosNf[Len(aDadosNf),4],nOpcx})
				EndIf
			EndIf

	      aItSD1:={}

	   EndIf

		aCab 		:= {}
		Aadd( aCab, { 'F1_DOC'		, DTC->DTC_NUMNFC	, Nil } )	// Numero da NF				( Obrigatorio )
		Aadd( aCab, { 'F1_SERIE'	, DTC->DTC_SERNFC	, Nil } )	// Serie da NF					( Obrigatorio )
		Aadd( aCab, { 'F1_TIPO'		, 'B'				, Nil } )	// Tipo da NF					( Obrigatorio )
		Aadd( aCab, { 'F1_FORNECE'	, DTC->DTC_CLIREM	, Nil } )	// Codigo do Fornecedor		( Obrigatorio )
		Aadd( aCab, { 'F1_LOJA'		, DTC->DTC_LOJREM	, Nil } )	// Loja do Fornecedor		( Obrigatorio )
		Aadd( aCab, { 'F1_EMISSAO'	, dDataBase			, Nil } )	// Emissao da NF				( Obrigatorio )
		Aadd( aCab, { 'F1_FORMUL'	, 'S'				, Nil } )	// Formulario
		Aadd( aCab, { 'F1_ESPECIE'	, 'NFE'				, Nil } )	// Especie
		Aadd( aCab, { 'F1_COND'		, Space(Len(SF1->F1_COND))	, Nil } )	// Condicao de pagamento

	EndIf
   If lCtrlEst
		//-- Caso nao informado o armazem, busca o local padrao do produto
		If Empty(cArmazem)
			If RetArqProd(DTC->DTC_CODPRO)
				cArmazem  := Posicione("SB1",1,xFilial("SB1")+DTC->DTC_CODPRO,"B1_LOCPAD")
			Else
				aAreaSBZ:= GetArea()
				cArmazem  := Posicione("SBZ",1,xFilial("SBZ")+DTC->DTC_CODPRO,"BZ_LOCPAD")
				RestArea(aAreaSBZ)
			Endif
			lLimpaArm := .T.
		EndIf

		nItem++

		//-- Itens da nota fiscal de entrada.
		aLinSD1 := {}
		Aadd( aLinSD1, { 'D1_COD'		, DTC->DTC_CODPRO	, Nil } )	// Codigo do produto
		Aadd( aLinSD1, { 'D1_ITEM'		, StrZero( nItem, Len( SD1->D1_ITEM ) ), Nil } )	// Item da nota fiscal
		Aadd( aLinSD1, { 'D1_QUANT'	, DTC->DTC_QTDVOL	, Nil } )	// Quantidade do produto
		Aadd( aLinSD1, { 'D1_VUNIT'	, DTC->DTC_VALOR / DTC->DTC_QTDVOL, Nil } )	// Valor unitario
		Aadd( aLinSD1, { 'D1_TOTAL'	, DTC->DTC_VALOR	, Nil } )	// Valor total
		Aadd( aLinSD1, { 'D1_TES'		, SF4->F4_CODIGO	, Nil } )	// Tipo de entrada da nota
		Aadd( aLinSD1, { 'D1_LOCAL'	, cArmazem			, Nil } )	// Codigo do armazem

		Aadd( aItSD1, Aclone(aLinSD1) )
	EndIf
	//--Atualiza DUH Se o MV_LOCALIZ estiver ativo
	If lUnitiz .And. lLocaliz
		TmA595Grv(nOpcx,cArmazem,,DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE)
	EndIf
    
	If cTabela == "DY4" //verifica se o looping esta percorrendo os registros da tabela DY4
		DY4->(dbSkip())
	Else
		DTC->(dbSkip())	
	Endif	

EndDo

//-- Gera Nota Fiscal de Entrada / Enderecamento
If Len(aCab) > 0 .And. Len(aItSD1) > 0
	If !TMSGrvNFEnt(nOpcx, aCab, aItSD1, aDadosNF, lEnderecar)
		Return ( .F. )
	Else
		// Executa Ponto de entrada pos geracao/exclusao de NF do cliente
		If lExecBlock
			ExecBlock("TMSGERNFE",.F.,.F.,{aDadosNf[Len(aDadosNf),1],aDadosNf[Len(aDadosNf),2],aDadosNf[Len(aDadosNf),3],aDadosNf[Len(aDadosNf),4],nOpcx})
		EndIf
	EndIf
EndIf

dbSelectArea('DTC')

RestArea(aAreaDTC)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsGrvDT8³ Autor ³ Alex Egydio            ³ Data ³29.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a composicao do frete                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do programa q chamou esta funcao              ³±±
±±³          ³ ExpC2 = Filial de origem ou filial do documento            ³±±
±±³          ³ ExpC3 = Codigo do documento( cotacao, ctrc, awb, etc... )  ³±±
±±³          ³ ExpC4 = Serie do documento                                 ³±±
±±³          ³ ExpC5 = Indica se inclui taxa por CTRC ou apenas no ultimo ³±±
±±³          ³ ExpL1 = .T. indica q esta processando o ultimo CTRC        ³±±
±±³          ³ ExpL2 = Grava Componente com valor Zerado ? (Sim/Nao)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsGrvDT8( cPrograma, cFilOri, cDocto, cSerie, cTaxCtr, lUltimo, aCmpFrt, lCompValZer, nOrdem, cChave, cCodCia , cLojCia , cDigAwb )

Local aAreaAnt	:= GetArea()
Local aAreaDT8	:= DT8->(GetArea())
Local bCampo	:= {|x| FieldName(x) }
Local nCampos	:= 0
Local nCntFor	:= 0
Local n1Cnt		:= 0
Local n2Cnt		:= 0
Local nValPas	:= 0
Local nValImp	:= 0
Local nValTot	:= 0
Local lGrava	:= .T.
Local lTaxa		:= .F.
Local lTMSAI70	:= ("TMSAI70" $ AllTrim(FunName()))
Local lPERRAT	:= Iif ( DT8->(ColumnPos("DT8_PERRAT")) > 0, .T., .F. )
Local lFechado  := GetMv("MV_COTVFEC",,.F.)  //-- Permite a digitacao de Valor Fechado por componente
Local nDecValPas:= TamSx3("DT8_VALPAS")[2]


Default lCompValZer := .F.
Default nOrdem := 1
Default cChave := ''
Default cCodCia := ''
Default cLojCia := ''
Default cDigAwb := ''

If ValType(aCmpFrt)=='A'
	aFrete := AClone(aCmpFrt)
EndIf

//-- Cria variaveis de memoria
nCampos := DT8->( FCount() )
RegToMemory('DT8',.T.)
//-- Grava a composicao do frete
For nCntFor := 1 To Len( aFrete )

	For n2Cnt := 1 To Len( aFrete[ nCntFor, 2 ] )

		//--Se o Valor do componente for 0
		//--No Internacional preciso gravar o DT8 mesmo sem valor, pois existe a possibilidade de alterar valores de componentes
		If	!lCompValZer .And. (Round(aFrete[ nCntFor, 2, n2Cnt, 2 ], nDecValPas) == 0 .And. !lTMSAI70)
			Loop
		EndIf

		//-- Cotacao de Frete
		If	cPrograma == 'TMSA040'
			M->DT8_FILORI := cFilOri
			M->DT8_NUMCOT := cDocto
			//-- Verifica se foi encontrado a regiao origem, regiao destino e o valor para o componente.
			If	Empty(aFrete[ nCntFor, 2, n2Cnt, 07 ]) .And. ;
				Empty(aFrete[ nCntFor, 2, n2Cnt, 08 ]) .And. ;
				aFrete[ nCntFor, 2, n2Cnt, 2 ] == 0
				Loop
			EndIf
		//-- Geracao de Documentos
		ElseIf Alltrim(cPrograma) $ 'TMSA200|TMSA491|TMSA853'
			M->DT8_FILDOC	:= cFilOri
			M->DT8_DOC		:= cDocto
			M->DT8_SERIE	:= cSerie
			M->DT8_ITEMD2	:= aFrete[ nCntFor, 2, n2Cnt, 4 ]
			//-- Verifica se o componente eh taxa
			lTaxa := TMSAComTax( aFrete[ nCntFor, 2, n2Cnt, 3 ] )
			//-- Taxa por documento 1=Sim, todos os documentos serao taxados
			//-- Taxa por documento 2=Nao, somente o ultimo documento sera taxado
			lGrava := ( cTaxCtr == StrZero(1,Len(DUO->DUO_TAXCTR)) .Or. !lTaxa .Or. (cTaxCtr == StrZero(2,Len(DUO->DUO_TAXCTR)) .And. lUltimo) )
			//-- Caso na estrutura de frete possuir apenas um componente taxa, mesmo que o cliente
			//-- esteja configurado para não cobrar taxa por CTRC, o componente será gravado
			If !lGrava .And. Len(aFrete[ nCntFor, 2 ]) <= 2
				lGrava := .T.
			EndIf
		//-- Geracao da AWB
		ElseIf cPrograma == 'TMSA320'
			M->DT8_FILORI := cFilOri
			M->DT8_NUMAWB := cDocto
			If lAWBRepete
				M->DT8_CODCIA := cCodCia
				M->DT8_LOJCIA := cLojCia
				M->DT8_DIGAWB := cDigAwb
			EndIf
		ElseIf cPrograma == 'TMSA250'
			M->DT8_FILORI := cFilOri
			M->DT8_NUMCTC := cDocto
		EndIf
		If	lGrava
			M->DT8_CODPAS := aFrete[ nCntFor, 2, n2Cnt, 03 ]
			M->DT8_VALPAS := aFrete[ nCntFor, 2, n2Cnt, 02 ]
			M->DT8_VALIMP := aFrete[ nCntFor, 2, n2Cnt, 05 ]
			M->DT8_VALTOT := aFrete[ nCntFor, 2, n2Cnt, 06 ]
			M->DT8_CDRORI := aFrete[ nCntFor, 2, n2Cnt, 07 ]
			M->DT8_CDRDES := aFrete[ nCntFor, 2, n2Cnt, 08 ]
			M->DT8_TABFRE := aFrete[ nCntFor, 2, n2Cnt, 09 ]
			M->DT8_TIPTAB := aFrete[ nCntFor, 2, n2Cnt, 10 ]
			M->DT8_SEQTAB := aFrete[ nCntFor, 2, n2Cnt, 11 ]
			M->DT8_DESC   := aFrete[ nCntFor, 2, n2Cnt, 13 ]
			M->DT8_ACRESC := aFrete[ nCntFor, 2, n2Cnt, 14 ]
			M->DT8_CALMIN := aFrete[ nCntFor, 2, n2Cnt, 15 ]

			If lPERRAT .And. (Len(aFrete[ nCntFor, 2, n2Cnt ]) >= 21)
				M->DT8_PERRAT := aFrete[ nCntFor, 2, n2Cnt, 21 ]
			EndIf

			//-- Atualisa a linha totalizadora do frete
			If	aFrete[ nCntFor, 2, n2Cnt, 3 ] == 'TF' .And. Alltrim(cPrograma) <> 'TMSA491'
				M->DT8_VALPAS := nValPas
				M->DT8_VALIMP := nValImp
				M->DT8_VALTOT := nValTot

				If lPERRAT
					M->DT8_PERRAT := 0
				EndIf

				nValPas := 0
				nValImp := 0
				nValTot := 0
			Else
				nValPas += M->DT8_VALPAS
				nValImp += M->DT8_VALIMP
				nValTot += M->DT8_VALTOT
			EndIf
			//-- Efetua a gravacao
			DT8->(DbSetOrder(nOrdem))
			If !Empty(cChave) .And. DT8->(MsSeek(cChave+M->DT8_CODPAS))
				If lFechado
					RecLock('DT8',.F.)
					DT8->DT8_CODPAS += M->DT8_CODPAS
					DT8->DT8_VALPAS += M->DT8_VALPAS
					DT8->DT8_VALIMP += M->DT8_VALIMP
					DT8->DT8_VALTOT += M->DT8_VALTOT
					DT8->DT8_CDRORI += M->DT8_CDRORI
					DT8->DT8_CDRDES += M->DT8_CDRDES
					DT8->DT8_TABFRE += M->DT8_TABFRE
					DT8->DT8_TIPTAB += M->DT8_TIPTAB
					DT8->DT8_SEQTAB += M->DT8_SEQTAB				
					DT8->DT8_DESC   += M->DT8_DESC
					DT8->DT8_ACRESC += M->DT8_ACRESC
					DT8->DT8_CALMIN += M->DT8_CALMIN
				Else
					RecLock('DT8',.F.)
					DT8->DT8_VALPAS += M->DT8_VALPAS
					DT8->DT8_VALIMP += M->DT8_VALIMP
					DT8->DT8_VALTOT += M->DT8_VALTOT
				EndIf					
				MsUnLock()
			Else
				RecLock('DT8',.T.)
				For n1Cnt := 1 To nCampos
					FieldPut( n1Cnt, M->&( Eval( bCampo,n1Cnt ) ) )
				Next
				DT8->DT8_FILIAL := xFilial('DT8')
				DT8->DT8_CODPRO := aFrete[ nCntFor, 1 ]
				MsUnLock()
			EndIf
		EndIf
	Next
Next

RestArea(aAreaAnt)
RestArea(aAreaDT8)

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsViewFrt³ Autor ³ Alex Egydio           ³ Data ³11.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem a composicao de frete                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Determina como a funcao obtem a composicao de frete³±±
±±³          ³         1 = Visualiza a composicao de frete                ³±±
±±³          ³         2 = Obtem a composicao pela cotacao de frete       ³±±
±±³          ³         3 = Obtem a composicao pelo documento              ³±±
±±³          ³         4 = Geracao de documentos com cotacao vinculada    ³±±
±±³          ³         5 = Obtem a composicao pelo contrato               ³±±
±±³          ³         6 = Obtem a composicao pela AWB                    ³±±
±±³          ³         7 = Especifico p/manutencao de documentos          ³±±
±±³          ³         8 = Monta afrete em branco                         ³±±
±±³          ³         9 = Atualiza o listbox que apresenta a composicao  ³±±
±±³          ³ ExpC2 = Filial de origem ou filial do documento            ³±±
±±³          ³ ExpC3 = Codigo do documento( cotacao, ctrc, awb, etc... )  ³±±
±±³          ³ ExpC4 = Serie do documento                                 ³±±
±±³          ³ ExpC5 = Codigo do produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsViewFrt(cAcao,cFilOri,cDocto,cSerie,cCodPro,lCompFrete,nOpcx,aCmpFrt,nTValPas,nTValImp,nTValTot,cCodCia,cLojCia,cDigAwb)
Static lFechado	:= GetMv("MV_COTVFEC",,.F.) //-- Permite a digitacao de Valor Fechado por componente
//-- Controle de dimensoes de objetos
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aSize		:= {}
//-- MsDialog
Local oDlgEsp
//-- ListBox
Local cLbx		:= ''
Local oLbxComp
Local aCompos	:= {}
Local cDscComp	:= ''
Local cOrdem	:= '  '		//-- O cOrdem foi inicializado com 2 espacos para forcar o componente de Reentrega p/1a linha
Local cSeek		:= ''
Local lRet		:= .T.
Local nCntFor	:= 0
Local n1Cnt		:= 0
Local nSeek		:= 0
Local bWhile
Local lPERRAT    := DT8->(ColumnPos("DT8_PERRAT")) > 0
Local nValComp	:= 0
Local nImpComp	:= 0
Local nTotComp	:= 0
Local lShowTES  := (IsInCallStack("TMSA040VFRT") .And. IsInCallStack("TMSA040MNT")) .Or. IsInCallStack("TMSA200MNT") .Or. IsInCallStack("TMSA200REC") //-- Exibe informações da TES somente se estiver na cotação.
Local lConsig   := .F.
Local aCompTES  := {}
Local cCliGen   := SuperGetMv("MV_CLIGEN",,"")
Local cTipNFC	:= "0"

DEFAULT cAcao    := '1'
DEFAULT cCodPro  := ''
DEFAULT nTValPas := 0
DEFAULT nTValImp := 0
DEFAULT nTValTot := 0
DEFAULT cCodCia  := ''
DEFAULT cLojCia  := ''
DEFAULT cDigAwb  := ''

If ValType(aCmpFrt)=='A'
	aFrete := AClone(aCmpFrt)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aFrete                                               ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aFrete[01] = Descricao do componente                                  ³
//³ aFrete[02] = Valor do componente                                      ³
//³ aFrete[03] = Codigo do componente                                     ³
//³ aFrete[04] = Item SD2. Atualizado pelas funcoes que geram o SD2       ³
//³ aFrete[05] = Na cotacao eh gravado o valor do imposto do componente   ³
//³ aFrete[06] = Total do componente ( valor + imposto )                  ³
//³ aFrete[07] = Codigo da regiao origem                                  ³
//³ aFrete[08] = Codigo da regiao destino                                 ³
//³ aFrete[09] = Tabela de Frete                                          ³
//³ aFrete[10] = Tipo da Tabela                                           ³
//³ aFrete[11] = Sequencia                                                ³
//³ aFrete[12] = Linha Totalizadora                                       ³
//³ aFrete[13] = Desconto dado ao valor do componente                     ³
//³ aFrete[14] = Acrescimo dado ao valor do componente                    ³
//³ aFrete[15] = Indica se o componente esta com o valor minimo da tabela,|
//³              1=Sim,2=Nao                                              |
//³-----Rateio----------                                                  |
//³ aFrete[16] = Indica o criterio de calculo do componente- Peso, Volume,|
//³              Quantidade                                               |
//³ aFrete[17] = Produto                                                  |
//³ aFrete[18] = Codigo do Serviço                                        |
//³ aFrete[19] = Codigo do Cliente                                        |
//³ aFrete[20] = Loja do cliente                                          |
//³ aFrete[21] = % Calculado de Rateio para o Componente de Frete         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//-- Visualiza a composicao do frete. TmsA040
If	cAcao == '1'
	For nCntFor := 1 To Len(aFrete)
		nValComp	:= 0
		nImpComp	:= 0
		nTotComp	:= 0

		//--Busca informacoes da TES para previsualizacao junto com o calculo.		
		If lShowTES .And. cAcao == "1"
			If IsInCallStack("TMSA200MNT") .Or. IsInCallStack("TMSA200REC") .Or. IsInCallStack("TMSA200PRC")
				If Len( aFrete[nCntFor][3] ) >= 30 
					cTipNFC	:=  aFrete[nCntFor][3][30]
				EndIf 
				aCompTES := A500TESCmp(aFrete[nCntFor][3][27],aFrete[nCntFor][3][28],aFrete[nCntFor][3][1],aFrete[nCntFor][3][2],aFrete[nCntFor][3][22], aFrete[nCntFor][3][23],aFrete[nCntFor][1],aFrete[nCntFor][3][29],cTipNFC,aFrete[nCntFor][2],aFrete[nCntFor][3][19],aFrete[nCntFor][3][20] )
			Else
				If !Empty(M->(DT4_CLIREM+DT4_LOJREM)) .And. !Empty(M->(DT4_CLIDES+DT4_LOJDES))
					If M->(DT4_CLIDEV + DT4_LOJDEV) <> M->(DT4_CLIREM+DT4_LOJREM) .And.;
						M->(DT4_CLIDEV + DT4_LOJDEV) <> M->(DT4_CLIDES+DT4_LOJDES) .And.;
						M->(DT4_CLIDEV + DT4_LOJDEV) <> cCliGen
						lConsig := .T.
					EndIf
				EndIf
				aCompTES := A500TESCmp(M->DT4_DOCTMS,M->DT4_TIPFRE,M->DT4_CLIDEV,M->DT4_LOJDEV,M->DT4_CDRORI, M->DT4_CDRDES,aFrete[nCntFor][1],lConsig,M->DT4_TIPNFC,aFrete[1][2],M->DT4_CLIDES,M->DT4_LOJDES)
			EndIf
		EndIf

		For n1Cnt := 1 To Len(aFrete[nCntFor, 2])

			nValComp += aFrete[nCntFor, 2, n1Cnt, 2]
			nImpComp += aFrete[nCntFor, 2, n1Cnt, 5]
			nTotComp += aFrete[nCntFor, 2, n1Cnt, 6]

			If !lFechado
				AAdd(aCompos,{Iif(n1Cnt==1,Posicione('SB1',1,xFilial('SB1')+aFrete[nCntFor,1],'B1_DESC'),Space(Len(SB1->B1_DESC))),;
					aFrete[nCntFor,2,n1Cnt,1],;
					aFrete[nCntFor,2,n1Cnt,2],;
					aFrete[nCntFor,2,n1Cnt,5],;
					aFrete[nCntFor,2,n1Cnt,6],;
					aCompTES[n1Cnt,1] + " " + aCompTES[n1Cnt,2],; //-- TES e Descricao
					aCompTES[n1Cnt,3],;                             //-- CFOP
					aCompTES[n1Cnt,4] + " " + aCompTES[n1Cnt,5] })//-- CST - Situacao Tributaria
			Else
				AAdd(aCompos,{Iif(n1Cnt==1,Posicione('SB1',1,xFilial('SB1')+aFrete[nCntFor,1],'B1_DESC'),Space(Len(SB1->B1_DESC))),;
					aFrete[nCntFor,2,n1Cnt,1],;
					aFrete[nCntFor,2,n1Cnt,2],;
					aFrete[nCntFor,2,n1Cnt,5],;
					aFrete[nCntFor,2,n1Cnt,6],;
					aFrete[nCntFor,2,n1Cnt,13],;
					aFrete[nCntFor,2,n1Cnt,14],;
					aCompTES[n1Cnt,1] + " " + aCompTES[n1Cnt,2],; //-- TES e Descricao
					aCompTES[n1Cnt,3],;                           //-- CFOP
					aCompTES[n1Cnt,4] + " " + aCompTES[n1Cnt,5],; //-- CST - Situacao Tributaria
					aFrete[nCntFor,2,n1Cnt,15] })                 //-- Valor minimo da tabela? 1=SIM;2=NAO
			EndIf

		Next
		nSeek := aScan(aFrete[nCntFor, 2], {|x| x[3] == 'TF'})
		If nSeek == 0
			If !lFechado
				AAdd(aCompos, {Space(Len(SB1->B1_DESC)), STR0016, nValComp, nImpComp, nTotComp,"","",""}) // "Total do Frete"
			Else
				AAdd(aCompos, {Space(Len(SB1->B1_DESC)), STR0016, nValComp, nImpComp, nTotComp, 0, 0,"","","", 0}) // "Total do Frete"
			EndIf
		EndIf		
	Next
	//-- Calcula as dimensoes dos objetos
	aSize  := MsAdvSize( .T. )

	AAdd( aObjects, { 100, 60,.T.,.T. } )

	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	aPosObj:= MsObjSize( aInfo, aObjects,.T. )
	DEFINE MSDIALOG oDlgEsp TITLE STR0007 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //"Composicao do frete"
		If !lFechado
			@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxComp VAR cLbx FIELDS HEADER "INIT" SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL //"Produto"###"Composicao"###"Valor"###"Imposto"###"Valor + Imposto"
			oLbxComp:aHeaders := {STR0008,STR0009,STR0010,STR0011,STR0012,STR0006,STR0130,STR0131}
			oLbxComp:SetArray( aCompos )
			oLbxComp:bLine	:= { || {	aCompos[ oLbxComp:nAT, 1 ],;
										aCompos[ oLbxComp:nAT, 2 ],;
										TransForm( aCompos[ oLbxComp:nAT, 3 ], PesqPict('DT8','DT8_VALPAS') ),;
										TransForm( aCompos[ oLbxComp:nAT, 4 ], PesqPict('DT8','DT8_VALIMP') ),;
										TransForm( aCompos[ oLbxComp:nAT, 5 ], PesqPict('DT8','DT8_VALTOT') ),;
										 aCompos[ oLbxComp:nAT, 6 ],;
										 aCompos[ oLbxComp:nAT, 7 ],;
										 aCompos[ oLbxComp:nAT, 8 ] }}
		Else
			@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxComp VAR cLbx FIELDS HEADER "INIT" SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL //"Produto"###"Composicao"###"Valor"###"Imposto"###"Valor + Imposto"###"%Desconto"##"%Acrescimo"
			oLbxComp:aHeaders := {STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0006,STR0130,STR0131}
			oLbxComp:SetArray( aCompos )
			oLbxComp:bLine	:= { || {	aCompos[ oLbxComp:nAT, 1 ],;
										aCompos[ oLbxComp:nAT, 2 ],;
										TransForm( aCompos[ oLbxComp:nAT, 3 ], PesqPict('DT8','DT8_VALPAS') ),;
										TransForm( aCompos[ oLbxComp:nAT, 4 ], PesqPict('DT8','DT8_VALIMP') ),;
										TransForm( aCompos[ oLbxComp:nAT, 5 ], PesqPict('DT8','DT8_VALTOT') ),;
										TransForm( aCompos[ oLbxComp:nAT, 6 ], PesqPict('DT4','DT4_DESC'  ) ),;
										TransForm( aCompos[ oLbxComp:nAT, 7 ], PesqPict('DT4','DT4_ACRESC') ),;
										aCompos[ oLbxComp:nAT, 8 ],;
										 aCompos[ oLbxComp:nAT, 9 ],;
										 aCompos[ oLbxComp:nAT, 10 ] }}
		EndIf


	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()})

//-- Atualiza o listbox que apresenta a composicao. TmsA500
ElseIf cAcao == '9'
		
	oLbx:SetArray( aFrete )
	
	If Len(aFrete)
		oLbx:bLine	:= { || {	aFrete[ oLbx:nAT, 1 ],;
									TransForm( aFrete[ oLbx:nAT, 2 ], PesqPict('DT8','DT8_VALPAS') ),;
									TransForm( aFrete[ oLbx:nAT, 5 ], PesqPict('DT8','DT8_VALIMP') ),;
									TransForm( aFrete[ oLbx:nAT, 6 ], PesqPict('DT8','DT8_VALTOT') ),;
									Iif(lPERRAT .And. Len(aFrete[oLbx:nAT]) >= 21,;								
									TransForm( aFrete[ oLbx:nAT, 21], Iif(lPERRAT, PesqPict('DT8','DT8_PERRAT'), "") ), '') } }
	EndIf

//-- Preenche o vetor aFrete com a composicao da cotacao de frete
Else
	//-- Obtem a composicao de frete pelo nr. da cotacao. TmsA040
	If	cAcao == '2'
		DT8->(DbSetOrder(1)) //DT8_FILIAL+DT8_FILORI+DT8_NUMCOT+DT8_CODPRO+DT8_CODPAS
		DT8->(MsSeek(cSeek := xFilial('DT8') + cFilOri + cDocto))
		bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCOT == cSeek ) }

	//-- Obtem a composicao de frete pelo nr. do documento + produto. TmsA200Rc1 e TmsA200Rc2
	ElseIf cAcao == '3'
		DT8->(DbSetOrder(2)) //DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
		DT8->(MsSeek(cSeek := xFilial('DT8') + cFilOri + cDocto + cSerie + cCodPro))
		bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_FILDOC + DT8->DT8_DOC + DT8->DT8_SERIE + DT8->DT8_CODPRO == cSeek ) }

	//-- Obtem a composicao de frete pelo nr. da cotacao + produto. TmsA200Cot
	ElseIf cAcao == '4'
		DT8->(DbSetOrder(1)) //DT8_FILIAL+DT8_FILORI+DT8_NUMCOT+DT8_CODPRO+DT8_CODPAS
		DT8->(MsSeek(cSeek := xFilial('DT8') + cFilOri + cDocto + cCodPro))
		bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCOT + DT8->DT8_CODPRO == cSeek ) }
		aFrete := {}

	//-- Obtem a composicao de frete pelo nr. do contrato. TmsA250
	ElseIf cAcao == '5'
		DT8->(DbSetOrder(4)) //DT8_FILIAL+DT8_TABFRE+DT8_TIPTAB+DT8_CDRORI+DT8_CDRDES+DT8_SEQTAB+DT8_FILDOC+DT8_DOC+DT8_SERIE
		lCompFrete := DT8->(MsSeek(cSeek := xFilial('DT8') + cFilOri + cDocto))
		bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCTC == cSeek ) }

	//-- Obtem a composicao de frete pelo nr. da AWB. TmsA320
	ElseIf cAcao == '6'
		DT8->(DbSetOrder(3)) //DT8_FILIAL+DT8_NUMAWB+DT8_CODCIA+DT8_LOJCIA+DT8_CODPAS
		If lAWBRepete
			DT8->(MsSeek(cSeek := xFilial('DT8') + cDocto + cCodCia + cLojCia ))
			bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB + DT8->DT8_CODCIA + DT8->DT8_LOJCIA == cSeek ) }
			If DT8->(FieldPos("DT8_DIGAWB")) > 0
				DT8->(MsSeek(cSeek := xFilial('DT8') + cDocto + cDigAwb + cCodCia + cLojCia ))
				bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB + DT8->DT8_DIGAWB + DT8->DT8_CODCIA + DT8->DT8_LOJCIA == cSeek ) }
			EndIf
		Else
			DT8->(MsSeek(cSeek := xFilial('DT8') + cDocto))
			bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_NUMAWB == cSeek ) }
		EndIf

	//-- Obtem a composicao de frete pelo nr. do documento. Tratamento especifico p/ manutencao de documentos. TmsA500
	ElseIf cAcao == '7'
		If AliasIndic("DIK") .And. ("TMSAI70" $ FunName()) .And. M->DIK_STATUS == "9" //--Internacional
			//--Ativar os deletados do DT8
			dbSelectArea('DT8')
			SET DELETED OFF
		EndIf
		DT8->(DbSetOrder(2)) //DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
		DT8->(MsSeek(cSeek := xFilial('DT8') + cFilOri + cDocto + cSerie))
		bWhile := {|| DT8->( ! Eof() .And. DT8->DT8_FILIAL + DT8->DT8_FILDOC + DT8->DT8_DOC + DT8->DT8_SERIE == cSeek ) }
		//-- Reentrega
		If	nOpcx == 5
			AAdd(aFrete,{Posicione('DT3',1,xFilial('DT3') + GetMV('MV_COMPENT'),'DT3_DESCRI'),0,GetMV('MV_COMPENT'),'',0,0,'','','','','',cOrdem,0,0, StrZero(2,Len(DT8->DT8_CALMIN)),'','','','','', 0 })
		EndIf
		//-- Complemento de Imposto
		If	nOpcx == 10
			AAdd(aFrete,{Posicione('DT3',1,xFilial('DT3') + GetMV('MV_COMPIMP'),'DT3_DESCRI'),0,GetMV('MV_COMPIMP'),'',0,0,'','','','','',cOrdem,0,0, StrZero(2,Len(DT8->DT8_CALMIN)),'','','','','', 0 })
		EndIf
	EndIf

	If cAcao != '8'
		While Eval( bWhile )
			cOrdem := '00'

			If	cAcao == '7'
				//-- Devolucao
				If nOpcx == 4
					//-- Qd o componente for de uso exclusivo da regiao, o mesmo nao deve fazer parte da composicao do frete na devolucao
					DUR->(DbSetOrder(1))
					If DUR->( MsSeek(xFilial('DUR') + M->DT6_CDRORI + DT8->DT8_CODPAS)) .And.;
						DUR->(!MsSeek(xFilial('DUR') + M->DT6_CDRDES + DT8->DT8_CODPAS))
						DT8->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf

			If	DT8->DT8_CODPAS == 'TF'
				cDscComp := STR0016 //"Total do Frete"
				cOrdem	:= 'ZZ'
			Else
				cDscComp := Posicione('DT3', 1, xFilial('DT3') + DT8->DT8_CODPAS, 'DT3_DESCRI')
			EndIf

			If cAcao == '2' .Or. cAcao == '5'
				nSeek := AScan(aFrete,{|x| x[1]==DT8->DT8_CODPRO })
				If	Empty(nSeek)
					AAdd(aFrete,{DT8->DT8_CODPRO,{{cDscComp,;
						DT8->DT8_VALPAS,DT8->DT8_CODPAS,'',;
						DT8->DT8_VALIMP,DT8->DT8_VALTOT,	;
						DT8->DT8_CDRORI,DT8->DT8_CDRDES,	;
						DT8->DT8_TABFRE,;
						DT8->DT8_TIPTAB,;
						DT8->DT8_SEQTAB,;
						cOrdem,;
						DT8->DT8_DESC,;
						DT8->DT8_ACRESC,;
						DT8->DT8_CALMIN,;
						'',;
						'',;
						'',;
						'',;
						'',;
						Iif(lPERRAT, DT8->DT8_PERRAT, 0)}}})
				Else
					AAdd(aFrete[nSeek,2],{cDscComp,;
										DT8->DT8_VALPAS,;
										DT8->DT8_CODPAS,;
										'',;
										DT8->DT8_VALIMP,;
										DT8->DT8_VALTOT,;
										DT8->DT8_CDRORI,;
										DT8->DT8_CDRDES,;
										DT8->DT8_TABFRE,;
										DT8->DT8_TIPTAB,;
										DT8->DT8_SEQTAB,;
										cOrdem,;
										DT8->DT8_DESC,;
										DT8->DT8_ACRESC,;
										DT8->DT8_CALMIN,;
										'',;
										'',;
										'',;
										'',;
										'',;
										Iif(lPERRAT, DT8->DT8_PERRAT, 0)})
				EndIf
				If	DT8->DT8_CODPAS == 'TF'
					nTValPas	+= DT8->DT8_VALPAS
					nTValImp	+= DT8->DT8_VALIMP
					nTValTot	+= DT8->DT8_VALTOT
				EndIf
			ElseIf cAcao == '4'
				AAdd(aFrete,{cDscComp,;
						DT8->DT8_VALPAS,;
						DT8->DT8_CODPAS,;
						'',;
						DT8->DT8_VALIMP,;//0,; //--Incluído o Imposto e Frete + Imposto da Cotação, já que no Frete Informado esse campo é necessário.
						DT8->DT8_VALTOT,;//0,;
						DT8->DT8_CDRORI,;
						DT8->DT8_CDRDES,;
						DT8->DT8_TABFRE,;
						DT8->DT8_TIPTAB,;
						DT8->DT8_SEQTAB,;
						cOrdem,;
						DT8->DT8_DESC,;
						DT8->DT8_ACRESC,;
						DT8->DT8_CALMIN,;
						'',;
						'',;
						'',;
						'',;
						'',;
						Iif(lPERRAT, DT8->DT8_PERRAT, 0) } )

			ElseIf cAcao == '7'
				nSeek := AScan(aFrete,{|x|x[3]==DT8->DT8_CODPAS})
				If	Empty(nSeek)
					AAdd( aFrete,{cDscComp,;
								DT8->DT8_VALPAS,;
								DT8->DT8_CODPAS,;
								DT8->DT8_ITEMD2,;
								DT8->DT8_VALIMP,;
								DT8->DT8_VALTOT,;
								DT8->DT8_CDRORI,;
								DT8->DT8_CDRDES,;
								DT8->DT8_TABFRE,;
								DT8->DT8_TIPTAB,;
								DT8->DT8_SEQTAB,;
								cOrdem,;
								DT8->DT8_DESC,;
								DT8->DT8_ACRESC,;
								DT8->DT8_CALMIN,;
								'',;
								'',;
								'',;
								'',;
								'',;
								Iif(lPERRAT, DT8->DT8_PERRAT, 0) })
				Else
					aFrete[nSeek,2]+=DT8->DT8_VALPAS
					aFrete[nSeek,5]+=DT8->DT8_VALIMP
					aFrete[nSeek,6]+=DT8->DT8_VALTOT
				EndIf
			Else
				nSeek := Ascan( aFrete,{|x| x[3] == DT8->DT8_CODPAS })
				If	Empty(nSeek)
					AAdd( aFrete,{cDscComp,;
								DT8->DT8_VALPAS,;
								DT8->DT8_CODPAS,;
								DT8->DT8_ITEMD2,;
								DT8->DT8_VALIMP,;
								DT8->DT8_VALTOT,;
								DT8->DT8_CDRORI,;
								DT8->DT8_CDRDES,;
								DT8->DT8_TABFRE,;
								DT8->DT8_TIPTAB,;
								DT8->DT8_SEQTAB,;
								cOrdem,;
								DT8->DT8_DESC,;
								DT8->DT8_ACRESC,;
								DT8->DT8_CALMIN,;
								'',;
								'',;
								'',;
								'',;
								'',;
								Iif(lPERRAT, DT8->DT8_PERRAT, 0) } )
				EndIf
			EndIf

			DT8->(DbSkip())
		EndDo
	EndIf

	If	cAcao == '2' .Or. cAcao == '5'
		If	Empty( aFrete )
			AAdd(aFrete,{Space(Len(DT8->DT8_CODPRO)),{{Space(Len(DT3->DT3_DESCRI)),0,'','',0,0,'','','','','','00',0,0,StrZero(2,Len(DT8->DT8_CALMIN)),'','','','','', 0 }}})
		Else
			For nCntFor := 1 To Len(aFrete)
				ASort(aFrete[nCntFor,2],,,{|x,y| x[12] + x[3] < y[12] + y[3] })
			Next
		EndIf
	Else
		If	Empty( aFrete )
			AAdd(aFrete,{Space(Len(DT3->DT3_DESCRI)),0,'','',0,0,'','','','','','00',0,0, StrZero(2,Len(DT8->DT8_CALMIN)),'','','','','', 0 })
		EndIf
		ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })
	EndIf

EndIf

If cAcao == "7" .And. AliasIndic("DIK") .And. ("TMSAI70" $ FunName()) .And. M->DIK_STATUS == "9" //--Internacional
	//--Ativar os deletados do DT8
	dbSelectArea('DT8')
	SET DELETED ON
EndIf

If ValType(aCmpFrt)=='A'
	aCmpFrt := AClone(aFrete)
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsGrvA103³ Autor ³ Eduardo de Souza      ³ Data ³ 23/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Notas / Enderecamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsGrvA103(ExpN1,ExpL1,ExpA1,ExpA2,ExpN2,ExpA3)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no Browser                                   ³±±
±±³          ³ ExpA1 - Itens do SDB                                       ³±±
±±³          ³ ExpA2 - Itens do SD1                                       ³±±
±±³          ³ ExpA3 - Cabecalho                                          ³±±
±±³          ³ ExpC1 - Numero da Nota Fiscal                              ³±±
±±³          ³ ExpC2 - Serie da Nota Fiscal                               ³±±
±±³          ³ ExpC3 - Codigo Remetente                                   ³±±
±±³          ³ ExpC4 - Loja Remetente                                     ³±±
±±³          ³ ExpC5 - Codigo do Produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsGrvA103(nOpcx,aItSDB,aItSD1,aCab,cNumNFC,cSerNFC,cCliRem,cLojRem,cCodPro)

Local aCabSDA := {}
Local nCnt    := 0
Local nCnt2   := 0
Local nPos    := 0
Local aGrvSDB := {}

//-- Esta funcao funciona para inclusao ou estorno de notas fiscais e distribuicao de produtos.
//-- Na inclusao devo chamar mata103 e depois mata265.
//-- No estorno  devo chamar mata265 e depois mata103.
If	nOpcx == 3
	//-- Gera nota fiscal de entrada.
	MATA103( aCab, aItSD1, nOpcx )

	//-- Se houve problemas na entrada de notas fiscais, apresenta o motivo do erro e sai do laco no arquivo DTC.
	If lMsErroAuto
		MostraErro()
		Return ( .F. )
	EndIf
EndIf

//-- Executa a distribuicao de produtos.
If !Empty(aItSDB)
	For nCnt := 1 To Len(aItSD1)

		SD1->(DbSetOrder(1))
		If SD1->(MsSeek( xFilial('SD1') + cNumNFC + cSerNFC + cCliRem + cLojRem + cCodPro + aItSD1[nCnt,1,2] ))
			//-- Atualiza por Localizacao
			aGrvSDB := {}
			nPos    := Ascan( aItSDB, { |x| x[2,2] == SD1->D1_LOCAL } )
			For nCnt2 := nPos To Len(aItSDB)
				If aItSDB[nCnt2,2,2] == SD1->D1_LOCAL
					aAdd(aGrvSDB, aClone(aItSDB[nCnt2]))
				Else
					Exit
				EndIf
			Next nCnt2

			aCabSDA := {}
			Aadd( aCabSDA, { 'DA_PRODUTO'	, cCodPro			, Nil } )
			Aadd( aCabSDA, { 'DA_LOCAL'		, SD1->D1_LOCAL		, Nil } )
			Aadd( aCabSDA, { 'DA_NUMSEQ'	, SD1->D1_NUMSEQ	, Nil } )
			Aadd( aCabSDA, { 'DA_DOC'		, cNumNFC			, Nil } )
			Aadd( aCabSDA, { 'DA_SERIE'		, cSerNFC			, Nil } )
			Aadd( aCabSDA, { 'DA_CLIFOR'	, cCliRem			, Nil } )
			Aadd( aCabSDA, { 'DA_LOJA'		, cLojRem			, Nil } )

			//-- Executa a distribuicao de produtos.
			lMsErroAuto := .F.
			SDA->(dbSetOrder(1))
			If SDA->( MsSeek( xFilial('SDA') + SD1->(D1_COD+D1_LOCAL+D1_NUMSEQ+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) ))
				If nOpcx == 5 //-- Estornar
					Mata265( aCabSDA, aGrvSDB, 4 )
				Else
					Mata265( aCabSDA, aGrvSDB, nOpcx )
				EndIf
			EndIf
		EndIf
	Next nCnt
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGrvNFEn³ Autor ³ Patricia Salomao      ³ Data ³01.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Nota Fiscal de Entrada / Enderecamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSGrvNFEnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1-Opcao Selecionada                                     ³±±
±±³          ³ExpA1-Array contendo o Cabecalho da Nota Fiscal (SF1)       ³±±
±±³          ³ExpA2-Array contendo os Itens da Nota Fiscal (SD1)          ³±±
±±³          ³ExpA3-Array contendo os Dados da Nota Fiscal do Cliente(DTC)³±±
±±³          ³ExpL1-Valida se realiza ou nao o enderecamento dos produtos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao TMSGerNFEnt()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSGrvNFEnt(nOpcx, aCab, aItSD1, aDadosNF, lEnderecar)


//-- Na inclusao chamar mata103 e depois mata265.
//-- No estorno  chamar mata265 e depois mata103.
If	!lEnderecar
	If nOpcx == 3 //-- Gera nota fiscal de entrada.
		MATA103( aCab, aItSD1, nOpcx )
	EndIf
Else
	If !TMSEnderec( aCab, nOpcx, aDadosNF ) // Gera notas fiscal de entrada e Enderacamento.
		Return ( .F. )
	EndIf
EndIf

If nOpcx == 5 //-- Estorno
	SF1->( DbSetOrder( 1 ) )
	If SF1->( MsSeek( xFilial('SF1') + aCab[1][2] + aCab[2][2] + aCab[4][2]+ aCab[5][2] + 'B' ) )
		//-- Estorna nota fiscal de entrada.
		MATA103( aCab, aItSD1, 21 )//21 chamada especial do TMS para o mata103 para realizar a exclusao da nf
	EndIf

	//-- Se houve problemas na entrada de notas fiscais, apresenta o motivo do erro e sai do laco no arquivo DTC.
	If lMsErroAuto
		MostraErro()
		Return ( .F. )
	EndIf
EndIf

Return ( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSEnderec³ Autor ³ Patricia Salomao      ³ Data ³01.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Enderecamento da Nota Fiscal                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSEnderec(ExpN1,ExpA1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1- Opcao Selecionada                                    ³±±
±±³          ³ExpA1- Array contendo as Notas Fiscais (DTC)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao TMSGrvNFEnt()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSEnderec(aCab,nOpcx,aDadosNF)

Local nX         := 0
Local cItem      := ''
Local aItSDB     := {}
Local aLinSDB	 := {}
Local aLinSD1    := {}
Local aItSD1     := {}
Local cAnomalia  := CriaVar("DB_ANOMAL", .F.)
Local cServic    := CriaVar("DB_SERVIC", .F.)
Local cCliRem, cLojRem, cSerNFC, cNumNFC, cCodPro
Local nVItem     := 0
Local nEndereco  := 0
Local nItem      := 0
Local nQtdeProd  := 0
Local nVFinal    := 0
Local nTotItEnd  := 0
Local aAreaDUH   := {}
Local cTes		 := GetMV("MV_TESDR",,"")
Local lGrvA103   := .F.

SF4->(DbSetOrder(1))
If SF4->(!MsSeek(xFilial('SF4')+cTes,.F.))
	Help(' ',1,'TMSA20015',,STR0006 + cTes,5,11)	 //"Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4).###" TES : "
	Return(.F.)
EndIf

//-- Executa o enderecamento de produtos.
lMsErroAuto	:=	.F.

For nX := 1  to Len(aDadosNF)

	cNumNFC   := aDadosNF[nX][01]
	cSerNFC   := aDadosNF[nX][02]
	cCliRem   := aDadosNF[nX][03]
	cLojRem   := aDadosNF[nX][04]
	cCodPro   := aDadosNF[nX][05]
	nQtdeProd := aDadosNF[nX][09]
	nValor    := aDadosNF[nX][10]

	If Localiza(cCodPro)
		//-- Verifica o total de Enderacamentos
		DUH->( DbSetOrder( 1 ) )
		If	DUH->( MsSeek( cSeekDUH := xFilial('DUH') + cFilAnt + cNumNFC + cSerNFC + cCliRem + cLojRem + cCodPro, .F. ) )
			Do While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC + DUH->DUH_CLIREM + DUH->DUH_LOJREM + DUH->DUH_CODPRO == cSeekDUH )
				nEndereco++
				DUH->(DbSkip())
			EndDo
		EndIf

		nVItem  := nValor / nEndereco
		nVFinal := nValor - (nVItem * (nEndereco - 1))

		//-- Verifica se ha enderecamento de notas fiscais.
		DUH->( DbSetOrder( 1 ) )
		If	DUH->( MsSeek( cSeekDUH := xFilial('DUH') + cFilAnt + cNumNFC + cSerNFC + cCliRem + cLojRem + cCodPro, .F. ) )
			Do While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC + DUH->DUH_CLIREM + DUH->DUH_LOJREM + DUH->DUH_CODPRO == cSeekDUH )

				nItem ++
				cArmazem  := DUH->DUH_LOCAL
				nQtdeProd := 0
				nTotItEnd := 0
				cItem	  := StrZero( 0, Len( SDB->DB_ITEM ) )

				Do While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC + DUH->DUH_CLIREM + DUH->DUH_LOJREM + DUH->DUH_CODPRO + DUH->DUH_LOCAL == cSeekDUH + cArmazem )

					cItem   := Soma1( cItem, Len( SDB->DB_ITEM ) )
					aLinSDB := {}

					Aadd( aLinSDB,	{ 'DB_ITEM'		,	cItem			,   NIL } )
					Aadd( aLinSDB,	{ 'DB_LOCAL'	,	cArmazem		,	NIL } )
					Aadd( aLinSDB,	{ 'DB_LOCALIZ'	,	DUH->DUH_LOCALI	,	NIL } )
					Aadd( aLinSDB,	{ 'DB_QUANT'	,	DUH->DUH_QTDVOL	,	NIL } )
					Aadd( aLinSDB,	{ 'DB_PRODUTO'	,	DUH->DUH_CODPRO ,	NIL } )
					Aadd( aLinSDB,	{ 'DB_DATA'		,	dDataBase		,	NIL } )
					Aadd( aLinSDB,	{ 'DB_ANOMAL'	,	cAnomalia   	,	".T." } )
					Aadd( aLinSDB,	{ 'DB_SERVIC'   ,	cServic  		,	".T." } )

					If	nOpcx == 5
						Aadd( aLinSDB,	{ 'DB_ESTORNO',	'S', NIL } )
					EndIf

					Aadd( aItSDB, Aclone(aLinSDB) )

					nQtdeProd += DUH->DUH_QTDVOL
					nTotItEnd ++

					DUH->( DbSkip() )

				EndDo

	 			nVUnit := (nVItem * nTotItEnd)  / nQtdeProd

				aLinSD1 := {}
				Aadd( aLinSD1, { 'D1_ITEM'	, StrZero(nItem ,Len(SD1->D1_ITEM)), Nil } )	// Item da nota fiscal
				Aadd( aLinSD1, { 'D1_LOCAL'	, cArmazem             , Nil } )	// Codigo do armazem
				Aadd( aLinSD1, { 'D1_QUANT'	, nQtdeProd            , Nil } )	// Quantidade do produto
				Aadd( aLinSD1, { 'D1_COD'	, cCodPro              , Nil } )	// Codigo do produto
				Aadd( aLinSD1, { 'D1_VUNIT'	, nVUnit               , Nil } )	// Valor unitario
				Aadd( aLinSD1, { 'D1_TOTAL'	, nVItem * nTotItEnd   , Nil } )	// Valor total
				Aadd( aLinSD1, { 'D1_TES'	, SF4->F4_CODIGO       , Nil } )	// Tipo de entrada da nota

				Aadd( aItSD1, Aclone(aLinSD1) )

			EndDo

			//-- Grava Notas / Enderecamento
			aAreaDUH := DUH->(GetArea())
			TmsGrvA103(nOpcx,aItSDB,aItSD1,aCab,cNumNFC,cSerNFC,cCliRem,cLojRem,cCodPro)
			RestArea( aAreaDUH )

		EndIf
	Else

		nItem ++

		Aadd( aLinSD1, { 'D1_ITEM'  , StrZero( nItem , Len( SD1->D1_ITEM ) ), Nil } )	// Item da nota fiscal
		If RetArqProd(cCodPro)
			Aadd( aLinSD1, { 'D1_LOCAL' , Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_LOCPAD") , Nil } ) // Codigo do armazem
		Else
			aAreaSBZ:= GetArea()
			Aadd( aLinSD1, { 'D1_LOCAL' , Posicione("SBZ",1,xFilial("SBZ")+cCodPro,"BZ_LOCPAD") , Nil } ) // Codigo do armazem
			RestArea(aAreaSBZ)
		Endif
		Aadd( aLinSD1, { 'D1_QUANT' , nQtdeProd     	 	, Nil } )	// Quantidade do produto
		Aadd( aLinSD1, { 'D1_COD'   , cCodPro       	 	, Nil } )	// Codigo do produto
		Aadd( aLinSD1, { 'D1_VUNIT' , nValor / nQtdeProd	, Nil } )	// Valor unitario
		Aadd( aLinSD1, { 'D1_TOTAL' , nValor            	, Nil } )	// Valor total
		Aadd( aLinSD1, { 'D1_TES'   , SF4->F4_CODIGO	 	, Nil } )	// Tipo de entrada da nota

		Aadd( aItSD1, Aclone(aLinSD1) )

		lGrvA103 := .T.

	EndIf

Next

If lGrvA103
	//-- Grava Notas / Enderecamento
	aAreaDUH := DUH->(GetArea())
	TmsGrvA103(nOpcx,aItSDB,aItSD1,aCab,cNumNFC,cSerNFC,cCliRem,cLojRem,cCodPro)
	RestArea( aAreaDUH )
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsBlqViag³ Autor ³ Alex Egydio           ³ Data ³29.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bloqueio de viagem.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsBlqViag()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial da viagem                                   ³±±
±±³          ³ ExpC2 = Codigo da viagem                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsBlqViag( cFilOri, cViagem, aLimite, nCapacM, aValSeg, cSerTms, lHelp, aBlqAnoVei, aBlqCarPer,;
                     nCapCav, aBlqFrtPag, nValFrePag, nValFreRec, aBlqDoctos, aVeiculos, aMotorista , lTela, cRotaMod3 )

Static lTMBLQVGE  := ExistBlock('TMBLQVGE')
Static cMV_BLQPES := SuperGetMv("MV_BLQPES",.F.,'3') // 1=Peso Real;2=Peso Cubado;3=Maior Peso
Static cMV_TMSINCO:= SuperGetMv("MV_TMSINCO",.F.,"") // Verifica Se Produtos Constantes Na Viagem São Incompativeis Entre Si
Static cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Static aListRRE   := {}

//-- Salva As Areas
Local aAreaAnt    := GetArea()
Local aAreaDTQ    := DTQ->( GetArea() )
Local aAreaDT6    := DT6->( GetArea() )
Local aAreaDTC    := DTC->( GetArea() )
Local aAreaDTR    := DTR->( GetArea() )
Local aAreaDUC    := DUC->( GetArea() )
Local aAreaDUD    := DUD->( GetArea() )
Local aAreaSA7    := SA7->( GetArea() )
Local aAreaSB5    := SB5->( GetArea() )
Local aAreaDUE    := DUE->( GetArea() )
//-- Tipos de Bloqueio Padroes
Local cBlqVal     := StrZero(10, Len(DUC->DUC_CODBLQ)) // Bloqueio valor
Local cBlqPes     := StrZero(20, Len(DUC->DUC_CODBLQ)) // Bloqueio peso.
Local cBlqSeg     := StrZero(30, Len(DUC->DUC_CODBLQ)) // Bloqueio seguro.
Local cBlqCap     := StrZero(40, Len(DUC->DUC_CODBLQ)) // Bloqueio capacidade.
Local cBlqAnoVei  := StrZero(50, Len(DUC->DUC_CODBLQ)) // Ano de fabricacao do veiculo.
Local cBlqCarPer  := StrZero(60, Len(DUC->DUC_CODBLQ)) // Motorista habilitado para carga perigosa.
Local cBlqCapCav  := StrZero(70, Len(DUC->DUC_CODBLQ)) // Bloqueio de Capacidade do cavalo
Local cBlqFrtPag  := StrZero(80, Len(DUC->DUC_CODBLQ)) // Bloqueio de Frete a Pagar
Local cBlqRtbRot  := StrZero(90, Len(DUC->DUC_CODBLQ)) // Bloqueio de Rentabilidade de Rota
Local cBlqPerVei  := Padr('I1', Len(DUC->DUC_CODBLQ))  // Bloqueio de Permisso Vencido
Local cBlqSemPer  := Padr('I2', Len(DUC->DUC_CODBLQ))  // Bloqueio de Ausencia de Permisso
Local cBlqSPerRg  := Padr('I3', Len(DUC->DUC_CODBLQ))  // Bloqueio de Ausencia de Permisso Para a Regiao
Local cBlqDocProp := PadR('D1', Len(DUC->DUC_CODBLQ))  // Bloqueio Documentacao Pendente - Fornec. Prop. do Veiculo
Local cBlqDocAju  := PadR('D2', Len(DUC->DUC_CODBLQ))  // Bloqueio Documentacao Pendente - Fornec. Ajudante
Local cBlqDocMot  := PadR('D3', Len(DUC->DUC_CODBLQ))  // Bloqueio Documentacao Pendente - Motorista
Local cBlqPerFor  := PadR('D4', Len(DUC->DUC_CODBLQ))  // Bloqueio Periodo de Prest. Serv. Expirado
Local cBlqManut   := PadR('D5', Len(DUC->DUC_CODBLQ))  // Bloqueio Manutencao de Ativos
Local cBlqAcv     := PadR('D6', Len(DUC->DUC_CODBLQ))  // Motorista / Veiculo de filiais diferentes.
Local cBlqJust    := PadR('J1', Len(DUC->DUC_CODBLQ))  // Justificativa pendente.
Local cBlqRest    := PadR('R1', Len(DUC->DUC_CODBLQ))  // Bloqueio Restrioes da viagem. (TMSA024)
Local aBloqueio   := {}
Local aBloqDoc    := {}
Local cCliente    := ''
Local cLoja       := ''
Local cProduto    := ''
Local cSeek       := ''
Local nCntFor     := 0
Local nPesCli     := 0
Local nVlrCli     := 0
Local nPesPrd     := 0
Local nVlrPrd     := 0
Local nPeso       := 0
Local nValMer     := 0
Local nLimVlr     := 0
Local nLimPeso    := 0
Local nLimPeso3   := 0
Local nI          := 0
Local nX          := 0
Local nB          := 0
Local nSeek       := 0
Local nPerRtb     := 0
Local cCodVei     := ''
Local cChave      := ''
Local cCodFor     := ''
Local cLojFor     := ''
Local cVeiRas     := ''
Local cRota       := ''
Local aChaveCli   := {}
Local aChavePrd   := {}
Local cTmsTit     := STR0017 //"Limite"
Local lReturn     := .T.
Local nIdadeVei   := 0
Local nPos        := 0
Local cCliVaz     := Space( Len( DTC->DTC_CLIREM ) )
Local cLojVaz     := Space( Len( DTC->DTC_LOJREM ) )
Local cPrdVaz     := Space( Len( DTC->DTC_CODPRO ) )
Local cCatVei     := ''
Local lQtdEix     := DTR->(FieldPos("DTR_QTDEIX")) > 0
Local lQtdEixV    := DTR->(FieldPos("DTR_QTEIXV")) > 0
Local aBlqUsr     := {}
Local oTmsBrw     := NIL
Local aTitulos    := {}
Local oTmsBrwDoc  := NIL
Local aTitBlqDoc  := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aSize       := MsAdvSize()
Local oTmsDlg     := NIL
Local aButtons    := {}
Local cTMSOPdg    := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local aMsgErr     := {}
Local aVisErr     := {}
Local dDtaApr     := CtoD(Space(08))
Local lNewDUC     := .F.
Local aAvaliaBlq  := {}
Local oFolderBlq  := NIL
Local aTitleFld   := {}
Local lMntTms     := ( GetMV('MV_NGMNTMS',,'N') == 'S') //-- Ativa integracao TMS X MNT.
Local nTotDist    := 0
Local nCont       := 0
Local nDias       := 0
//-- Bloqueio de Permisso
Local aRegDCA     := {}
Local cCdpOri     := ''
Local cCdpDes     := ''
Local cAliasQry   := GetNextAlias()
Local lAptJor     := AliasInDic('DAY') .And. SuperGetMv("MV_CONTJOR",,.F.) //-- Apontamento da jornada de trabalho do motorista
Local cStrMot     := ''
// -- Autorizacao para conduzir veiculo
Local cAcv := GetMv("MV_TMSADCV",," ")
Local lGrava      := .F.
Local aAreaCar    := {}
Local lBlqMotVei  := .F. // Utilizado na Impressao da Carta de Autorizacao = T bloqueia viagem
Local cMot        := "" //utilizado para montar mensagem na rotina de bloqueio
Local lBAcv       := GetMV("MV_TMSBACV",,.F.) // Bloqueia Viagem qdo motorista e veiculo sao divergente na Filial Base
Local cMV_BLQ70   := SuperGetMv("MV_TMSBL70",,"1")  //1= Capacidade do Cavalo com Capacidade da Carreta, 2= Capacidade do Cavalo com peso carregado na carreta
Local lTMSBLVG    := SuperGetMV( 'MV_TMSBLVG',, .F.) .And. !IsInCallStack("TmsA190Mnt")  // Sistema Devera bloquear a Viagem, mesmo com a existencia de um desbloqueio anterior.
Local lTMBLOQUE   := ExistBlock('TMBLOQUE')
Local lTMBLOQDB	  := ExistBlock('TMBLOQDB')
Local oEnable     := LoadBitmap(GetResources(),"ENABLE")
Local oDisable    := LoadBitmap(GetResources(),"DISABLE")
Local cOldFName   := FunName() //-- Utilizado para restaurar o FunName original, pois na chamada das rotinas atraves do submenu sera alterado.
Local nControle	 := 3 
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0

// -- Processo de Restricoes de Viagem
Local aCliLoj		:= {}
Local aSerTms		:= {}
Local aCepCli		:= {}
Local aCepDeAte		:= {}
Local aRestricao	:= {}
Local cCateg		:= ""
Local aVeiRes		:= {}
Local cData			:= ""
Local nCount		:= 0
Local lTmsa029     := FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA140")
Local cTMSRLC      := SuperGetMV( "MV_TMSRLC",, "0") //Restricao de Localizacao e Cliente 0= Nao Utiliza;1=Utiliza
Local cDescRtr	   := ""
Local lBlqDDU      := .F.
Local cTipOpVg     := "" 
Local lIsLGPD	   := ExistFunc("FWPDCanUse") .And. FwPdCanUse(.T.) .And. ExistFunc("TMLGPDCpPr")
Local nTamCpos     := 0	
Local nB5CarPer    := 0
Local lVgeMod3     := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

DEFAULT aBlqAnoVei 	:= {}
DEFAULT aBlqCarPer 	:= {}
DEFAULT aLimite    	:= {}
DEFAULT nCapacM    	:= 0
DEFAULT aValSeg    	:= 0
DEFAULT lHelp      	:= Iif(!lVgeMod3,( Len( aLimite ) == 0 ),.T.)
DEFAULT cSerTms    	:= StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) //-- Transporte
DEFAULT nCapCav    	:= 0
DEFAULT aBlqFrtPag 	:= {}
DEFAULT nValFrePag 	:= 0
DEFAULT nValFreRec 	:= 0
DEFAULT aBlqDoctos 	:= {}
DEFAULT aVeiculos  	:= {}
DEFAULT aMotorista 	:= {}
DEFAULT lTela		:= .T. 
DEFAULT cRotaMod3   := ""

lRestricao := AliasIndic("DIR") .And. FindFunction('TMSA024') .And. cTMSRLC $ '1|2|3' //Restricao de Localizacao e Cliente 0= Nao Utiliza 

//-- Verifica a Existencia dos Campos necessarios
If DUC->(FieldPos('DUC_CODVEI')) == 0 .Or. DUC->(FieldPos('DUC_CODMOT')) == 0
	Help(" ",1,"TMSXFUNC01") //"Para utilizar esta opcao, favor alterar o primeiro indice do arquivo DUC para DUC_FILIAL+DUC_FILORI+DUC_VIAGEM+DUC_CODBLQ+DUC_CODPRO+DUC_CODVEI+DUC_CODMOT"
	Return .F.
EndIf

//-- Obtem a Rota
If Left(FunName(),7) == 'TMSA140' .Or. Left(FunName(),7) == 'TMSA141' .Or. Left(FunName(),7) == 'TMSA144' 
	cRota := M->DTQ_ROTA
ElseIf lVgeMod3
	cRota	:= cRotaMod3
Else
   	cRota := Posicione('DTQ',2,xFilial( 'DTQ' ) + cFilOri + cViagem,'DTQ_ROTA')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aLimite                                              ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ [01] = Codigo do cliente remetente                                    ³
//³ [02] = Loja                                                           ³
//³ [03] = Codigo do produto                                              ³
//³ [04] = Valor da Mercadoria                                            ³
//³ [05] = Peso Real                                                      ³
//³ [06] = Peso Cubado                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aLimite ) > 0
	For nI := 1 To Len( aLimite )
		cCliente  := aLimite[ nI, 1 ]
		cLoja     := aLimite[ nI, 2 ]
		cProduto  := aLimite[ nI, 3 ]
		nLimVlr   := aLimite[ nI, 4 ]
		nLimPeso  := aLimite[ nI, 5 ]
		nLimPeso3 := aLimite[ nI, 6 ]

		nSeek := AScan( aChaveCli,{|x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )
		If Empty(nSeek)
			AAdd( aChaveCli,{ cCliente, cLoja, cProduto, nLimVlr, nLimPeso, nLimPeso3 } )
		Else
			aChaveCli[ nSeek, 4 ] += nLimVlr
			aChaveCli[ nSeek, 5 ] += nLimPeso
			aChaveCli[ nSeek, 6 ] += nLimPeso3
		EndIf

		nSeek := AScan( aChavePrd,{|x| x[1] == cProduto } )
		If Empty(nSeek)
			AAdd( aChavePrd,{ cProduto, nLimVlr, nLimPeso, nLimPeso3 } )
		Else
			aChavePrd[ nSeek, 2 ] += nLimVlr
			aChavePrd[ nSeek, 3 ] += nLimPeso
			aChavePrd[ nSeek, 4 ] += nLimPeso3
		EndIf
		//-- Acumula o peso de acordo com a definicao do parametro.
		If cMV_BLQPES == '1' //-- Peso Real
			nPeso	  += nLimPeso
		ElseIf cMV_BLQPES == '2' //-- Peso Cubado
			nPeso	  += nLimPeso3
		Else //-- Maior Peso
			nPeso	  += Max(nLimPeso,nLimPeso3)
		EndIf
		nValMer += nLimVlr
	Next
ElseIf !Empty(cViagem)
	DTQ->( DbSetOrder( 2 ) )
	DTQ->( MsSeek( xFilial( 'DTQ' ) + cFilOri + cViagem ) )

	DUD->( DbSetOrder( 2 ) )
	DUC->( DbSetOrder( 1 ) )
	If DUD->( MsSeek( cSeek := xFilial('DUD') + cFilOri + cViagem, .F. ) )
		nValFreRec := 0
		While DUD->( ! Eof() .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == cSeek )

			If	DUD->DUD_STATUS == StrZero( 4, Len( DUD->DUD_STATUS ) ) .Or. ; // Encerrado
				DUD->DUD_STATUS == StrZero( 9, Len( DUD->DUD_STATUS ) )        // Cancelado
				DUD->( DbSkip() )
				Loop
			EndIf

			DT6->( DbSetOrder( 1 ) )
			If DT6->( ! MsSeek( xFilial('DT6') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE, .F. ) )
				DUD->( DbSkip() )
				Loop
			EndIf

			nValFreRec += DT6->DT6_VALFRE

			// -----------------------------------------------+
			// Processo - Regra de Restricoes                 |
			// Recupera Cliente e Loja  e Servico de Transp.  |
			// -----------------------------------------------+
			If lRestricao
				BusCliServ(@aCliLoj,@aSerTms,@aCepCli)
			EndIf

			If	DTQ->DTQ_SERTMS == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .Or. ; // Transporte
				DTQ->DTQ_SERTMS == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Entrega

				DTC->( DbSetOrder( 3 ) )
				If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE)
					If DTC->( ! MsSeek( xFilial('DTC') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE ) )
						DUD->( DbSkip() )
						Loop
					Else
						While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == ;
							xFilial('DTC') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE
							cCliente := DTC->DTC_CLIREM
							cLoja    := DTC->DTC_LOJREM
							cProduto := DTC->DTC_CODPRO
	
							nSeek := AScan( aChaveCli,{|x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )
							If Empty(nSeek)
								AAdd( aChaveCli,{ cCliente, cLoja, cProduto, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
							Else
								aChaveCli[ nSeek, 4 ] += DTC->DTC_VALOR
								aChaveCli[ nSeek, 5 ] += DTC->DTC_PESO
								aChaveCli[ nSeek, 6 ] += DTC->DTC_PESOM3
							EndIf
	
							nSeek := AScan( aChavePrd,{|x| x[1] == cProduto } )
							If Empty(nSeek)
								AAdd( aChavePrd,{ cProduto, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
							Else
								aChavePrd[ nSeek, 2 ] += DTC->DTC_VALOR
								aChavePrd[ nSeek, 3 ] += DTC->DTC_PESO
								aChavePrd[ nSeek, 4 ] += DTC->DTC_PESOM3
							EndIf
							DTC->(DbSkip())
						EndDo
					EndIf
				Else					
					DbSelectArea("DY4")
					DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto										
					If DY4->( ! MsSeek( xFilial('DY4') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE ) )
						DUD->( DbSkip() )
						Loop
					Else
						While DY4->(!Eof()) .And. DY4->DY4_FILIAL + DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == ;
							xFilial('DY4') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE
							cCliente := DY4->DY4_CLIREM
							cLoja    := DY4->DY4_LOJREM
							cProduto := DY4->DY4_CODPRO
							
							DbSelectArea("DTC")
							DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto				
							If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO))	
								nSeek := AScan( aChaveCli,{|x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )
								If Empty(nSeek)
									AAdd( aChaveCli,{ cCliente, cLoja, cProduto, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
								Else
									aChaveCli[ nSeek, 4 ] += DTC->DTC_VALOR
									aChaveCli[ nSeek, 5 ] += DTC->DTC_PESO
									aChaveCli[ nSeek, 6 ] += DTC->DTC_PESOM3
								EndIf
		
								nSeek := AScan( aChavePrd,{|x| x[1] == cProduto } )
								If Empty(nSeek)
									AAdd( aChavePrd,{ cProduto, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
								Else
									aChavePrd[ nSeek, 2 ] += DTC->DTC_VALOR
									aChavePrd[ nSeek, 3 ] += DTC->DTC_PESO
									aChavePrd[ nSeek, 4 ] += DTC->DTC_PESOM3
								EndIf								
							Endif	
							DY4->(DbSkip())
						EndDo
					EndIf		
				Endif
	      ElseIf DUD->DUD_SERTMS == StrZero( 1, Len( DUD->DUD_SERTMS ) ) // Coleta

				DT5->( DbSetOrder( 4 ) )
				If DT5->( ! MsSeek( xFilial('DT5') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE ) )
					DUD->( DbSkip() )
					Loop
				EndIf
				cCliente := Space( Len( DTC->DTC_CLIREM ) )
				cLoja    := Space( Len( DTC->DTC_LOJREM ) )

				DUM->(DbSetOrder(1))
				If DUM->(MsSeek(xFilial("DUM")+DT5->DT5_FILORI+DT5->DT5_NUMSOL))
					While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL
						cProduto := DUM->DUM_CODPRO
						nSeek := AScan( aChaveCli,{|x| x[1] + x[2] + x[3] == cCliente + cLoja + cProduto } )
						If Empty(nSeek)
							AAdd( aChaveCli,{ cCliente, cLoja, cProduto, DUM->DUM_VALMER, DUM->DUM_PESO, DUM->DUM_PESOM3 } )
						Else
							aChaveCli[ nSeek, 4 ] += DUM->DUM_VALMER
							aChaveCli[ nSeek, 5 ] += DUM->DUM_PESO
							aChaveCli[ nSeek, 6 ] += DUM->DUM_PESOM3
						EndIf

						nSeek := AScan( aChavePrd,{|x| x[1] == cProduto } )
						If Empty(nSeek)
							AAdd( aChavePrd,{ cProduto, DUM->DUM_VALMER, DUM->DUM_PESO, DUM->DUM_PESOM3 } )
						Else
							aChavePrd[ nSeek, 2 ] += DUM->DUM_VALMER
							aChavePrd[ nSeek, 3 ] += DUM->DUM_PESO
							aChavePrd[ nSeek, 4 ] += DUM->DUM_PESOM3
						EndIf
						DUM->(DbSkip())
					EndDo
				EndIf
			EndIf
			//-- Acumula o peso de acordo com a definicao do parametro.
			If cMV_BLQPES == '1' //-- Peso Real
				nPeso	  += DT6->DT6_PESO
			ElseIf cMV_BLQPES == '2' //-- Peso Cubado
				nPeso	  += DT6->DT6_PESOM3
			Else //-- Maior Peso
				nPeso   += Max(DT6->DT6_PESO,DT6->DT6_PESOM3)
			EndIf
			nValMer += DT6->DT6_VALMER
			DUD->( DbSkip() )
		EndDo
	EndIf


	If lRestricao //-- Verifica se possui a funcionalidade de Restricoes
		// ---------------------------------------------+
		// F12 PERGUNTE - EXIBE RESTRICOES INFORMATIVAS.|
		// POREM O LRET NAO E MODIFICADO.               |
		// ---------------------------------------------+
		Pergunte("TMB144",.F.)
		If MV_PAR03 == 1
			cTipRes := "T"
			//
		Else
			 cTipRes := "B"
		EndIf

		// -------------------------------------------------+
		// VERIFICA SE A VIAGEM POSSUI REGRA DE RESTRICOES  |
		// -------------------------------------------------+
		dbSelectArea("DTR")
		DTR->( DbSetOrder( 1 ) )

		// Restringe pelo Array aCompViag
		If Iif(Type("aCompViag") <> "U", !Empty(aCompViag),.F.)

			For nCount := 1 to Len(aCompViag[2])
				
				//-- Veiculo Ou Cavalo
				AADD(aVeiRes,aCompViag[2][nCount][2])
				
				//-- Reboque 1
				If !Empty(aCompViag[2][nCount][5])
					AADD(aVeiRes,aCompViag[2][nCount][5])
				EndIf

				//-- Reboque 2
				If !Empty(aCompViag[2][nCount][7])
					AADD(aVeiRes,aCompViag[2][nCount][7])
				EndIf				

				//-- Reboque 3
				If DTR->(FieldPos("DTR_CODRB3")) > 0
					If !Empty(aCompViag[2][nCount][26])
						AADD(aVeiRes,aCompViag[2][nCount][26])
					EndIf
				EndIf						
				
			Next nCount

			If DTOS(aCompViag[11][3]) < DTOS(Date())
				cData	:= DTOS(Date())            
           Else
				cData	:= DTOS(aCompViag[11][3]) 
			Endif

		// Restringe pelo Complemento da Viagem
		ElseIf DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))

            If DTOS(DTR->DTR_DATINI) < DTOS(Date())
				cData	:= DTOS(Date())            
            Else
				cData	:= DTOS(DTR->DTR_DATINI)
			 Endif

			While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM == xFilial("DTR") + cFilOri + cViagem

				//-- Veiculo Ou Cavalo
				AADD(aVeiRes, DTR->DTR_CODVEI)

				//-- Reboque 1
				If !Empty(DTR->DTR_CODRB1)
					AADD(aVeiRes, DTR->DTR_CODRB1 )
				EndIf

				//-- Reboque 2
				If !Empty(DTR->DTR_CODRB2)
					AADD(aVeiRes, DTR->DTR_CODRB2 )
				EndIf				

				//-- Reboque 3
				If DTR->(FieldPos("DTR_CODRB3")) > 0
					If !Empty(DTR->DTR_CODRB3)
						AADD(aVeiRes, DTR->DTR_CODRB3 )
					EndIf
				EndIf						

				DTR->(DbSkip())
			EndDo

		// Restringe por valores vazios
		Else
			aVeiRes		:= {}
			cData		:= DTOS(Date())
		EndIf

		//Ceps da Rota
		If cTMSRLC $ "2|3" // Por Faixa de Cep ou Ambos
			aCepDeAte	:= A023CepRot(cRota,.T.)
		EndIf
		
		// Verifica Data preenchida
		If Empty(cData)
			cData := DTOS(Date())
		EndIf

		// Busca as Restrições
		aRestricao :=  TMSRESTRI("T",aCepDeAte,cRota,aCliLoj,aVeiRes,cTipRes,cData,aSerTms,,aCepCli,cFilOri,cViagem)

	EndIf

EndIf

//-- Preenche o vetor aBloqueio com os codigos de bloqueios especificados na tabela MB
SA7->( DbSetOrder( 1 ) )
SB5->( DbSetOrder( 1 ) )
For nI := 1 To Len( aChaveCli )
	cCliente := aChaveCli[ nI, 1 ]
	cLoja    := aChaveCli[ nI, 2 ]
	cProduto := aChaveCli[ nI, 3 ]
	nVlrCli  := aChaveCli[ nI, 4 ]
	nPesCli  := aChaveCli[ nI, 5 ]
	If SA7->( MsSeek( xFilial('SA7') + cCliente + cLoja + cProduto, .F. ) )

		// Bloqueio valor
		If SA7->A7_LVLEMB > 0
			Aadd( aBloqueio, { cBlqVal, cCliente, cLoja, cProduto, SA7->A7_LVLEMB, nVlrCli, ( SA7->A7_LVLEMB - nVlrCli ), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
		EndIf

		// Bloqueio peso
		If SA7->A7_LPSEMB > 0
			Aadd( aBloqueio, { cBlqPes, cCliente, cLoja, cProduto, SA7->A7_LPSEMB, nPesCli, ( SA7->A7_LPSEMB - nPesCli ), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
		EndIf
		// Ano de fabricacao do veiculo.
		If SA7->A7_IDADEM > 0
			If Empty(aBlqAnoVei)
				If  !Empty(cViagem)
					DTR->( DbSetOrder( 1 ) )
					DA3->( DbSetOrder( 1 ) )
					If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
						While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM == xFilial("DTR") + cFilOri + cViagem
							If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI)) .And. DA3->DA3_ATIVO == StrZero(1,Len(DA3->DA3_ATIVO))
								nIdadeVei :=  Year(dDataBase) - Val(DA3->DA3_ANOFAB)
								Aadd( aBloqueio, { cBlqAnoVei, cCliVaz, cLojVaz, cProduto, SA7->A7_IDADEM, nIdadeVei, ( SA7->A7_IDADEM - nIdadeVei ), DTR->DTR_CODVEI, Space(Len(DUC->DUC_CODMOT)) } )
							EndIf
							DTR->(DbSkip())
						EndDo
					EndIf
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Formato do vetor aBlqAnoVei                                           ³
				//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				//³ [01] = Codigo do veiculo                                              ³
				//³ [02] = Ano de Fabricacao                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCntFor := 1 To Len(aBlqAnoVei)
					nIdadeVei :=  Year(dDataBase) - Val(aBlqAnoVei[nCntFor,2])
					Aadd( aBloqueio, { cBlqAnoVei, cCliVaz, cLojVaz, cProduto, SA7->A7_IDADEM, nIdadeVei, ( SA7->A7_IDADEM - nIdadeVei ), aBlqAnoVei[nCntFor,1], Space(Len(DUC->DUC_CODMOT)) } )
				Next nCntFor
			EndIf
		EndIf
    EndIf

	nSeek := Ascan( aChavePrd, { | e | e[1] == cProduto } )
	If Empty( nSeek )
		Loop
	EndIf
	nVlrPrd := aChavePrd[ nSeek, 2 ]
	nPesPrd := aChavePrd[ nSeek, 3 ]

	If	SB5->( MsSeek( xFilial('SB5') + cProduto, .F. ) )
		
		// Bloqueio valor
		If SB5->B5_LVLEMB > 0
			// Se ja existir bloqueio de valor para o produto, nao bloqueia novamente
			If Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqVal + cCliente + cLoja + cProduto } ) == 0 .And. ;
				Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqVal + cCliVaz + cLojVaz + cProduto } ) == 0
				Aadd( aBloqueio, { cBlqVal, cCliVaz, cLojVaz, cProduto, SB5->B5_LVLEMB, nVlrPrd, ( SB5->B5_LVLEMB - nVlrPrd ), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
			EndIf
		EndIf

		// Bloqueio peso
		If SB5->B5_LPSEMB > 0
			// Se ja existir bloqueio de peso para o produto, nao bloqueia novamente
			If Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqPes + cCliente + cLoja + cProduto } ) == 0 .And. ;
				Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqPes + cCliVaz + cLojVaz + cProduto } ) == 0
				Aadd( aBloqueio, { cBlqPes, cCliVaz, cLojVaz, cProduto, SB5->B5_LPSEMB, nPesPrd, ( SB5->B5_LPSEMB - nPesPrd ), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
			EndIf
		EndIf

		// Se ja existir bloqueio de ano de fabricacao para o produto, nao bloqueia novamente
		If SB5->B5_IDADEM > 0
			If Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqAnoVei + cCliente + cLoja + cProduto } ) == 0 .And. ;
				Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqAnoVei + cCliVaz + cLojVaz + cProduto } ) == 0
				If Empty(aBlqAnoVei)
					If  !Empty(cViagem)
						// Ano de fabricacao do veiculo.
						DTR->( DbSetOrder( 1 ) )
						DA3->( DbSetOrder( 1 ) )
						If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
							While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM == xFilial("DTR") + cFilOri + cViagem
								If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI)) .And. DA3->DA3_ATIVO == StrZero(1,Len(DA3->DA3_ATIVO))
									nIdadeVei :=  Year(dDataBase) - Val(DA3->DA3_ANOFAB)
									Aadd( aBloqueio, { cBlqAnoVei, cCliVaz, cLojVaz, cProduto, SB5->B5_IDADEM, nIdadeVei, ( SB5->B5_IDADEM - nIdadeVei ), DTR->DTR_CODVEI, Space(Len(DUC->DUC_CODMOT)) } )
								EndIf
								DTR->(DbSkip())
							EndDo
						EndIf
					EndIF
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Formato do vetor aBlqAnoVei                                           ³
					//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
					//³ [01] = Codigo do veiculo                                              ³
					//³ [02] = Ano de Fabricacao                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nCntFor := 1 To Len(aBlqAnoVei)
						nIdadeVei :=  Year(dDataBase) - Val(aBlqAnoVei[nCntFor,2])
						Aadd( aBloqueio, { cBlqAnoVei, cCliVaz, cLojVaz, cProduto, SB5->B5_IDADEM, nIdadeVei, ( SB5->B5_IDADEM - nIdadeVei ), aBlqAnoVei[nCntFor,1], Space(Len(DUC->DUC_CODMOT)) } )
					Next nCntFor
				EndIf
			EndIf
		EndIf

		If Ascan( aBloqueio, { | e | e[1] + e[2] + e[3] + e[4] == cBlqCarPer + cCliVaz + cLojVaz + cProduto } ) == 0
			nB5CarPer:=  Iif(Empty(SB5->B5_CARPER),2,Val(SB5->B5_CARPER)) //1-Sim;2-Não
		
			If Empty(aBlqCarPer)
				If  !Empty(cViagem)
					// Carga Perigosa e o Motorista nao habilitado para carga perigosa.
					DUP->(DbSetOrder(1))
					DA4->(DbSetOrder(1))
					If DUP->(MsSeek(xFilial("DUP")+cFilOri+cViagem))
						While DUP->(!Eof()) .And. DUP->DUP_FILIAL + DUP->DUP_FILORI + DUP->DUP_VIAGEM == xFilial("DUP") + cFilOri + cViagem
							If DA4->(MsSeek(xFilial("DA4")+DUP->DUP_CODMOT)) .And. DA4->DA4_BLQMOT == StrZero( 2, Len( DA4->DA4_BLQMOT ) )
								Aadd( aBloqueio, { cBlqCarPer, cCliVaz, cLojVaz, cProduto, nB5CarPer, Val(DA4->DA4_CARPER) , ( nB5CarPer - Val(DA4->DA4_CARPER) ), Space(Len(DUC->DUC_CODVEI)), DUP->DUP_CODMOT } )
							EndIf
							DUP->(DbSkip())
						EndDo
					EndIf
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Formato do vetor aBlqCarPer                                           ³
				//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ,ÄÄÄÄÄÄÄÄÄ´
				//³ [01] = Codigo do motorista                                            ³
				//³ [02] = Carga Perigosa (1=Sim/2=Nao)                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCntFor := 1 To Len(aBlqCarPer)
					Aadd( aBloqueio, { cBlqCarPer, cCliVaz, cLojVaz, cProduto, nB5CarPer, Val(aBlqCarPer[nCntFor,2]) , ( nB5CarPer - Val(aBlqCarPer[nCntFor,2]) ), Space(Len(DUC->DUC_CODVEI)), aBlqCarPer[nCntFor,1] } )
				Next nCntFor
			EndIf
		EndIf
	EndIf
Next

//-- Verifica se o motorista tem permissao para transportar o valor da mercadoria da viagem.
If Empty(aValSeg)
	If !Empty(cViagem)
		DUP->(DbSetOrder(1))
		DA4->(DbSetOrder(1))
		If DUP->(MsSeek(xFilial("DUP")+cFilOri+cViagem))
			While DUP->(!Eof()) .And. DUP->DUP_FILIAL + DUP->DUP_FILORI + DUP->DUP_VIAGEM == xFilial("DUP") + cFilOri + cViagem
				If DA4->(MsSeek(xFilial("DA4")+DUP->DUP_CODMOT)) .And. DA4->DA4_BLQMOT == StrZero( 2, Len( DA4->DA4_BLQMOT ) )
					//-- Bloqueio de Seguro
					If DA4->DA4_VALSEG > 0
						Aadd( aBloqueio, { cBlqSeg, cCliVaz, cLojVaz, cPrdVaz, DA4->DA4_VALSEG, nValMer, ( DA4->DA4_VALSEG - nValMer ), Space(Len(DUC->DUC_CODVEI)), DUP->DUP_CODMOT } )
					EndIf
				EndIf
				DUP->(DbSkip())
			EndDo
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Formato do vetor aValSeg                                              ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ [01] = Codigo do motorista                                            ³
	//³ [02] = Valor liberado pelo seguro                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To Len(aValSeg)
		If aValSeg[nCntFor,2] > 0
			Aadd( aBloqueio, { cBlqSeg, cCliVaz, cLojVaz, cPrdVaz, aValSeg[nCntFor,2], nValMer, ( aValSeg[nCntFor,2] - nValMer ), Space(Len(DUC->DUC_CODVEI)), aValSeg[nCntFor,1] } )
		EndIf
	Next nCntFor
EndIf

// -- Verifica se ira validar por Contador e por Tempo no modulos SIGAMNT
If lMntTms .And. !Empty(cViagem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Bloqueio Manutencao de Ativos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTR->( DbSetOrder( 1 ) )
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM == xFilial("DTR") + cFilOri + cViagem
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua Tratamento para o Veiculo Principal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			// -- Calcula a Distancia baseado na Rota
			nTotDist := TMSDistRot(cRota,.F.)
			nCont := 0
			dDatReal := CTOD(" ")
			If TmsBlqMnt(DTR->DTR_CODVEI,DTR->DTR_DATINI,DTR->DTR_DATFIM,@nTotDist,@nCont,@nDias)
				If nCont > 0
					Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, nCont, nTotDist, ( nCont - nTotDist ), DTR->DTR_CODVEI, Space(Len(DUC->DUC_CODMOT)) } )
				Else
					Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, 0, nDias, ( 0 - nDias ), DTR->DTR_CODVEI, Space(Len(DUC->DUC_CODMOT)) } )
		    	EndIf

		    	Exit
		    EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua tratamento para o Reboque 1        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(DTR->DTR_CODRB1)
				If TmsBlqMnt(DTR->DTR_CODRB1,DTR->DTR_DATINI,DTR->DTR_DATFIM,@nTotDist,@nCont,@nDias)
					If nCont > 0
						Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, nCont, nTotDist, ( nCont - nTotDist ), DTR->DTR_CODRB1, Space(Len(DUC->DUC_CODMOT)) } )
					ElseIf nDias > 0
						Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, 0, nDias, ( 0 - nDias ), DTR->DTR_CODRB1, Space(Len(DUC->DUC_CODMOT)) } )
			    	EndIf

			    	Exit
			    EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua tratamento para o Reboque 2        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(DTR->DTR_CODRB2)
				If TmsBlqMnt(DTR->DTR_CODRB2,DTR->DTR_DATINI,DTR->DTR_DATFIM,@nTotDist,@nCont,@nDias)
					If nCont > 0
						Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, nCont, nTotDist, ( nCont - nTotDist ), DTR->DTR_CODRB2, Space(Len(DUC->DUC_CODMOT)) } )
					ElseIf nDias > 0
						Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, 0, nDias, ( 0 - nDias ), DTR->DTR_CODRB2, Space(Len(DUC->DUC_CODMOT)) } )
			    	EndIf

			    	Exit
			    EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua tratamento para o Reboque 3        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTercRbq .And. !Empty(DTR->DTR_CODRB3)
				If TmsBlqMnt(DTR->DTR_CODRB3,DTR->DTR_DATINI,DTR->DTR_DATFIM,@nTotDist,@nCont,@nDias)
					If nCont > 0
						Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, nCont, nTotDist, ( nCont - nTotDist ), DTR->DTR_CODRB3, Space(Len(DUC->DUC_CODMOT)) } )
					ElseIf nDias > 0
						Aadd( aBloqueio, { cBlqManut, cCliVaz, cLojVaz, cProduto, 0, nDias, ( 0 - nDias ), DTR->DTR_CODRB3, Space(Len(DUC->DUC_CODMOT)) } )
			    	EndIf
			    	
			    	Exit
			    EndIf
			EndIf
			DTR->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaDTR)
EndIf

If (nCapacM == 0 .Or. nCapCav == 0 .Or. Empty(aBlqFrtPag)) .And. !Empty(cViagem)

	//-- Verifica a capacidade do veiculo.
	DTR->( DbSetOrder( 1 ) )
	DA3->( DbSetOrder( 1 ) )
	DTQ->( DbSetOrder( 2 ) )
	DTQ->( MsSeek( xFilial( 'DTQ' ) + cFilOri + cViagem ) )
	If DTR->( MsSeek( cSeek := xFilial('DTR') + cFilOri + cViagem, .F. ) )
		nValFrePag := 0
		nCapacM    := 0
		nCapCav	  := 0
		aBlqFrtPag := {}
	EndIf
	If DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
		cTipOpVg:= DTQ->DTQ_TPOPVG
	EndIf

	While DTR->( ! Eof() .And. DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM == cSeek )
		nValFrePag += DTR->DTR_VALFRE
		If lTercRbq
			nControle:= 4
		EndIf
					
		For nI := 1 To nControle                                                          
			cCodVei := ''
			If nI == 1 
				cCodVei := DTR->DTR_CODVEI  
			ElseIf nI == 2 
				If !Empty( DTR->DTR_CODRB1 )
					cCodVei := DTR->DTR_CODRB1
				Else
					cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
				EndIf		
			ElseIf nI == 3 
				If !Empty( DTR->DTR_CODRB2 )
					cCodVei := DTR->DTR_CODRB2		
				Else
					cChave+= StrZero(0, Len(DA3->DA3_FROVEI))		
				EndIf	
			ElseIf nI == 4
				If lTercRbq .And. !Empty( DTR->DTR_CODRB3 )
					cCodVei := DTR->DTR_CODRB3
				Else 
					cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
				EndIf
			EndIf	 
			If !Empty(cCodVei) 			
				//-- Se o veiculo for do Tipo Cavalo, nao considera-lo no bloqueio de capacidade de veiculo
				DA3->( MsSeek( xFilial('DA3') + cCodVei ) )
				cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI')

				If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI)) //-- Se o Tipo do Veiculo for 'Cavalo'
					nCapCav  += DA3->DA3_CAPACM
				Else
					nCapacM  += DA3->DA3_CAPACM
				EndIf

				//-- Nao considerar a capacidade do 'Cavalo' no Bloqueio de capacidade de Veiculo
				If nI == 1 .And.	DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) )
					cChave 	:= DA3->DA3_TIPVEI
					cCodFor	:= DA3->DA3_CODFOR
					cLojFor 	:= DA3->DA3_LOJFOR
					cVeiRas  := DA3->DA3_VEIRAS
					AAdd( aVeiculos, { cCodVei, 	Iif(lQtdEix	,DTR->DTR_QTDEIX	,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX")),;
					Iif(lQtdEixV,DTR->DTR_QTEIXV	,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX"))})
				ElseIf nI == 2
					If DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) ) .And. !Empty(cCodVei) .And. cCodVei == DTR->DTR_CODRB1
						AAdd( aVeiculos, { cCodVei, 	Iif(lQtdEix	,0,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX")),;
						Iif(lQtdEixV,0,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX"))})
						cChave+= DA3->DA3_FROVEI
					Else
						cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
					EndIf
				ElseIf nI == 3
					If DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) ) .And. !Empty(cCodVei) .And. cCodVei == DTR->DTR_CODRB2
						AAdd( aVeiculos, { cCodVei,	Iif(lQtdEix	,0,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX")),;
						Iif(lQtdEixV,0,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX"))})
						cChave+= DA3->DA3_FROVEI
					Else
						cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
					EndIf
				ElseIf nI == 4
					If DA3->DA3_ATIVO == StrZero( 1, Len( DA3->DA3_ATIVO ) ) .And. !Empty(cCodVei) .And. cCodVei == DTR->DTR_CODRB3
						AAdd( aVeiculos, { cCodVei,	Iif(lQtdEix	,0,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX")),;
						Iif(lQtdEixV,0,Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_QTDEIX"))})
						cChave+= DA3->DA3_FROVEI
					Else
						cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
					EndIf
				EndIf
			Endif
		Next			
		cChave+=cVeiRas

		If DTT->(FieldPos("DTT_TIPVIA")) > 0
			cChave += DTQ->DTQ_TIPVIA
		EndIf

		If  Empty(aBlqFrtPag)
			aFretCar := TMSFretCar(DTQ->DTQ_ROTA, cCodFor, cLojFor,;
                                aVeiculos, cChave, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA,,,IIF(cTMSOPdg <> '0', DTR->DTR_CODOPE,''), .F.,,cTipOpVg)

			//-- Bloqueia a Viagem se o Valor do Frete a Pagar for maior que o valor do frete calculado
			If !Empty(aFretCar) .And. !Empty(aFretCar[2]) .And. DTR->DTR_VALFRE > aFretCar[2]
				Aadd( aBlqFrtPag, { DTR->DTR_VALFRE, aFretCar[2] } )
			EndIf
		EndIf

		DTR->( DbSkip() )
	EndDo
EndIf

If nCapacM > 0
	//-- Bloqueio de capacidade de veiculo (Nao Considera Veiculos Tipo 'Cavalo')
	Aadd( aBloqueio, { cBlqCap, cCliVaz, cLojVaz, cPrdVaz, nCapacM, nPeso, ( nCapacM - nPeso ), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
EndIf

If nCapCav > 0
	//-- Bloqueio de capacidade de veiculo  (Considera Veiculos Tipo 'Cavalo')
	Aadd( aBloqueio, { cBlqCapCav, cCliVaz, cLojVaz, cPrdVaz, nCapCav, Iif( cMV_BLQ70 == '2', nPeso, nCapacM), Iif(cMV_BLQ70 == '2',( nCapCav-nPeso) ,( nCapCav-nCapacM )), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueio de Frete a Pagar:  Bloqueia a Viagem se o valor do     ³
//³ frete a Pagar for maior que o valor do frete calculado.         ³
//³ Estrutura do Array aBlqFrtPag :                                 ³
//³ aBlqFrtPag[n,1] - Valor INFORMADO de Frete a Pagar (DTR_VALFRE) ³
//³ aBlqFrtPag[n,2] - Valor CALCULADO de Frete a Pagar por Rota     ³                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aBlqFrtPag)
   For nI := 1 To Len(aBlqFrtPag)
		Aadd( aBloqueio, { cBlqFrtPag, cCliVaz, cLojVaz, cPrdVaz, aBlqFrtPag[nI][2], aBlqFrtPag[nI][1], ( aBlqFrtPag[nI][2] - aBlqFrtPag[nI][1] ), Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueio de Rentabilidade por Rota:  Bloqueia a Viagem se o     ³
//³ Percentual do Frete a Pagar/Receber for MAIOR que o Percentual  ³
//³ de Rentabilidade da Rota                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DA8->(dbSetOrder(1))
If DA8->(MsSeek(xFilial('DA8')+cRota)) .And. DA8->(FieldPos('DA8_PERRTB')) > 0 .And. !Empty(DA8->DA8_PERRTB) .And. nValFrePag > 0
	If nValFrePag <= nValFreRec
		nPerRtb := 100 - (Round((nValFrePag / nValFreRec) * 100,2))
	Else
		nPerRtb := (100 - (Round((nValFreRec / nValFrePag) * 100,2))) * -1
	EndIf
	If nPerRtb <= DA8->DA8_PERRTB
		Aadd( aBloqueio, { cBlqRtbRot, cCliVaz, cLojVaz, cPrdVaz,DA8->DA8_PERRTB,nPerRtb,(DA8->DA8_PERRTB-(iif(nPerRtb<0,(nPerRtb)*-1,nPerRtb))),Space(Len(DUC->DUC_CODVEI)), Space(Len(DUC->DUC_CODMOT)) } )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³* Bloqueio Documentacao Pendente - Fornecedor (Motorista/Ajudante)   ³
//³* Bloqueio Documentacao Pendente - Motorista                         ³
//³* Bloqueio Periodo de Atividade Expirado                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AliasInDic('DD1') .And. AliasInDic('DD2')
	If !Empty(aBlqDoctos) .And. (!Empty(aBlqDoctos[1]) .Or. !Empty(aBlqDoctos[2]) .Or. !Empty(aBlqDoctos[3]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Formato do vetor aBlqDoctos                                           ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ [01][X] = Veiculos da Viagem                                          ³
		//³ [02][X] = Motoristas da Viagem                                        ³
		//³ [03][X] = Ajudantes da Viagem                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Documentacao Pendente - Fornecedor / Prop. do Veiculo     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aBlqDoctos[1])
			DA3->(DbSetOrder(1))
			If DA3->(MsSeek(xFilial('DA3')+aBlqDoctos[1,nCntFor]))
				//--Checa os Documentos do Fornecedor amarrado ao Motorista
				DD3->(DbSetOrder(1)) //-- DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR+DD3_ITEM
				If DD3->(MsSeek(xFilial('DD3')+DA3->(DA3_CODFOR+DA3_LOJFOR)))
					While !DD3->(EoF()) .And. DD3->(DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR) == xFilial('DD3')+DA3->(DA3_CODFOR+DA3_LOJFOR)
						//-- Verifica a data limite de apresentacao do Documento,
						//-- considerando a data de Tolerancia
						dDtaApr  := IF(Empty(DD3->DD3_TOLERA), DD3->DD3_PRXAPR, DD3->DD3_TOLERA)
						AAdd(aBloqDoc,{	cBlqDocProp,;
										DD3->DD3_CODDOC,;
										dDtaApr,;
										Space(Len(DUC->DUC_CODAJU)),;
										Space(Len(DUC->DUC_CODMOT)),;
										aBlqDoctos[1,nCntFor],;
										DA3->DA3_CODFOR,;
										DA3->DA3_LOJFOR,;
										CtoD(Space(08)),;
										CtoD(Space(08)),;
										dDtaApr - dDataBase,;
										dDataBase })
						DD3->(DbSkip())
					EndDo
				EndIf
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Documentacao Pendente - Fornecedor / Ajudantes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aBlqDoctos[3])
			DAU->(DbSetOrder(1))
			If DAU->(MsSeek(xFilial('DAU') + aBlqDoctos[3,nCntFor]))
				//--Checa os Documentos do Fornecedor amarrado ao Ajudante
				DD3->(DbSetOrder(1)) //-- DWY_FILIAL+DWY_CODFOR+DWY_LOJFOR+DWY_ITEM
				If DD3->(MsSeek(xFilial('DD3') + DAU->(DAU_CODFOR+DAU->DAU_LOJFOR)))
					While !DD3->(EoF()) .And. DD3->(DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR) == xFilial('DD3')+DAU->(DAU_CODFOR+DAU_LOJFOR)
						//-- Verifica a data limite de apresentacao do Documento,
						//-- considerando a data de Tolerancia
						dDtaApr  := IF(Empty(DD3->DD3_TOLERA), DD3->DD3_PRXAPR, DD3->DD3_TOLERA)
						AAdd(aBloqDoc,{	cBlqDocAju,;
										DD3->DD3_CODDOC,;
										dDtaApr,;
										aBlqDoctos[3,nCntFor],;
										Space(Len(DUC->DUC_CODMOT)),;
										Space(Len(DUC->DUC_CODVEI)),;
										DAU->DAU_CODFOR,;
										DAU->DAU_LOJFOR,;
										CtoD(Space(08)),;
										CtoD(Space(08)),;
										dDtaApr - dDataBase,;
										dDataBase })
						DD3->(DbSkip())
					EndDo
				EndIf
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Documentacao Pendente - Motorista                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aBlqDoctos[2])
			DD4->(DbSetOrder(1))
			If DD4->(MsSeek(xFilial('DD4')+aBlqDoctos[2,nCntFor]))
				While !DD4->(EoF()) .And. DD4->(DD4_FILIAL+DD4_CODMOT) == xFilial('DD4')+aBlqDoctos[2,nCntFor]
					//-- Verifica a data limite de apresentacao do Documento,
					//-- considerando a data de Tolerancia
					dDtaApr  := IF(Empty(DD4->DD4_TOLERA), DD4->DD4_PRXAPR, DD4->DD4_TOLERA)
					AAdd(aBloqDoc,{	cBlqDocMot,;
									DD4->DD4_CODDOC,;
									dDtaApr,;
									Space(Len(DUC->DUC_CODAJU)),;
									aBlqDoctos[2,nCntFor],;
									Space(Len(DUC->DUC_CODVEI)),;
									Space(Len(DUC->DUC_CODFOR)),;
									Space(Len(DUC->DUC_LOJFOR)),;
									CtoD(Space(08)),;
									CtoD(Space(08)),;
									dDtaApr - dDataBase,;
									dDataBase })
					DD4->(DbSkip())
				EndDo
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Periodo de Prestacao de Servico Expirado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len(aBlqDoctos[3])
			DAU->(DbSetOrder(1))
			If DAU->(MsSeek(xFilial('DAU') + aBlqDoctos[3,nCntFor]))
				//--Verifica o Periodo da Prest. de Servico
				DD1->(DbSetOrder(1))
				If DD1->(MsSeek(xFilial('DD1')+DAU->(DAU_CODFOR+DAU_LOJFOR)))
					AAdd(aBloqDoc,{	cBlqPerFor,;
									PadR('-',Len(DD3->DD3_CODDOC)),;
									CtoD(Space(08)),;
									aBlqDoctos[3,nCntFor],;
									Space(Len(DUC->DUC_CODMOT)),;
									Space(Len(DUC->DUC_CODVEI)),;
									DAU->DAU_CODFOR,;
									DAU->DAU_LOJFOR,;
									DD1->DD1_DTAAFA,;
									DD1->DD1_DTARET,;
									0,;
									dDataBase })
				EndIf
			EndIf
		Next
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Documentacao Pendente - Fornecedor / Prop. do Veiculo     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTR->(DbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem))
			While !DTR->(EoF()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial('DTR')+cFilOri+cViagem
				DA3->(DbSetOrder(1))
				If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))
					//--Checa os Documentos do Fornecedor amarrado ao Motorista
 					DD3->(DbSetOrder(1)) //-- DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR+DD3_ITEM
					If DD3->(MsSeek(xFilial('DD3')+DA3->(DA3_CODFOR+DA3_LOJFOR)))
						While !DD3->(EoF()) .And. DD3->(DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR) == xFilial('DD3')+DA3->(DA3_CODFOR+DA3_LOJFOR)
							//-- Verifica a data limite de apresentacao do Documento,
							//-- considerando a data de Tolerancia
							dDtaApr  := IF(Empty(DD3->DD3_TOLERA), DD3->DD3_PRXAPR, DD3->DD3_TOLERA)
							AAdd(aBloqDoc,{	cBlqDocProp,;
											DD3->DD3_CODDOC,;
											dDtaApr,;
											Space(Len(DUC->DUC_CODAJU)),;
											Space(Len(DUC->DUC_CODMOT)),;
											DTR->DTR_CODVEI,;
											DA3->DA3_CODFOR,;
											DA3->DA3_LOJFOR,;
											CtoD(Space(08)),;
											CtoD(Space(08)),;
											dDtaApr - dDataBase,;
											dDataBase })
							DD3->(DbSkip())
						EndDo
					EndIf
				EndIf
				DTR->(DbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Documentacao Pendente - Fornecedor / Ajudantes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DUQ->(DbSetOrder(1)) //-- DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR+DUQ_CODAJU
		If DUQ->(MsSeek(xFilial('DUQ')+cFilOri+cViagem))
			While !DUQ->(EoF()) .And. DUQ->(DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM) == xFilial('DUQ')+cFilOri+cViagem
				DAU->(DbSetOrder(1))
				If DAU->(MsSeek(xFilial('DAU') + DUQ->DUQ_CODAJU))
					//--Checa os Documentos do Fornecedor amarrado ao Ajudante
					DD3->(DbSetOrder(1)) //-- DWY_FILIAL+DWY_CODFOR+DWY_LOJFOR+DWY_ITEM
					If DD3->(MsSeek(xFilial('DD3') + DAU->(DAU_CODFOR+DAU->DAU_LOJFOR)))
						While !DD3->(EoF()) .And. DD3->(DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR) == xFilial('DD3')+DAU->(DAU_CODFOR+DAU_LOJFOR)
							//-- Verifica a data limite de apresentacao do Documento,
							//-- considerando a data de Tolerancia
							dDtaApr  := IF(Empty(DD3->DD3_TOLERA), DD3->DD3_PRXAPR, DD3->DD3_TOLERA)
							AAdd(aBloqDoc,{	cBlqDocAju,;
											DD3->DD3_CODDOC,;
											dDtaApr,;
											DUQ->DUQ_CODAJU,;
											Space(Len(DUC->DUC_CODMOT)),;
											Space(Len(DUC->DUC_CODVEI)),;
											DAU->DAU_CODFOR,;
											DAU->DAU_LOJFOR,;
											CtoD(Space(08)),;
											CtoD(Space(08)),;
											dDtaApr - dDataBase,;
											dDataBase})
							DD3->(DbSkip())
						EndDo
					EndIf
				EndIf
				DUQ->(DbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Documentacao Pendente - Motorista                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DUP->(DbSetOrder(1))
		If DUP->(MsSeek(xFilial('DUP')+cFilOri+cViagem))
			While !DUP->(EoF()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM) == xFilial('DUP')+cFilOri+cViagem
			   lGrava := .F.
				//--Checa os Documentos do Fornecedor amarrado ao Motorista
				aAreaCar:=GetArea()
				DA4->(DbSetOrder(1))
				If DA4->(MsSeek(xFilial("DA4")+DUP->DUP_CODMOT)) .AND. DA4->DA4_TIPMOT == "1"

               DA3->(Dbsetorder(1))
               If DA3->(MsSeek(xFilial("DA3")+DUP->DUP_CODVEI)) .And. DA3->DA3_FROVEI == "1" // Filial base = veiculo e motorista e veiculo = proprio sim emite carta
               	If DA4->(FieldPos("DA4_FILBAS")) > 0 .And. DA4->DA4_FILBAS == DA3->DA3_FILBAS
			            lBlqMotVei := .F. // Motorista e Veiculo sao iguais nao gerar bloqueio
		  					DD4->(DbSetOrder(2))
			            If !Empty(cAcv) .And. DA4->(FieldPos("DA4_FILBAS")) > 0 .And. DA3->(FieldPos("DA3_FILBAS")) > 0 .And.;
								(Left(FunName(),7) == 'TMSA140' .Or. Left(FunName(),7) == 'TMSA141' .Or. Left(FunName(),7) == 'TMSA144')
			            	If !DD4->(MsSeek(xFilial("DD4")+DUP->DUP_CODMOT+cAcv))
									If !TMSRD40(DUP->DUP_CODMOT,DUP->DUP_CODVEI,DA4->DA4_FILBAS,cAcv,.T.)
										lGrava := .T.
			                  EndIf
			               Else
							   	If TMSRD40(DD4->DD4_CODMOT,DUP->DUP_CODVEI,DA4->DA4_FILBAS,cAcv,.F.) // -- Verifica se precisa imprimir
										If !TMSRD40(DD4->DD4_CODMOT,DUP->DUP_CODVEI,DA4->DA4_FILBAS,cAcv,.T.)
											lGrava   := .T.
										Endif
									EndIf
			               EndIf
			            Endif
			         Else
		               If lBAcv
				            lGrava     := .T.
			               lBlqMotVei := .T. // Motorista e Veiculo com filiais diferentes gera bloqueio
			            EndIf
		            EndIf
		         EndIf

					If lGrava
						dDtaApr  := IF(Empty(DD4->DD4_TOLERA), DD4->DD4_PRXAPR, DD4->DD4_TOLERA)
						AAdd(aBloqDoc,{IIF(lBlqMotVei,cBlqAcv,cBlqDocMot),;
											DD4->DD4_CODDOC,;
											dDtaApr,;
											Space(Len(DUC->DUC_CODAJU)),;
											DUP->DUP_CODMOT,;
											IIF(lBlqMotVei,DUP->DUP_CODVEI,Space(Len(DUC->DUC_CODVEI))),;
											Space(Len(DUC->DUC_CODFOR)),;
											Space(Len(DUC->DUC_LOJFOR)),;
											CtoD(Space(08)),;
											CtoD(Space(08)),;
											dDtaApr - dDataBase,;
											dDataBase })
					EndIf
				EndIf
				RestArea(aAreaCar)

				//--Checa os Documentos do Fornecedor amarrado ao Motorista
				DD4->(DbSetOrder(1))
				If DD4->(MsSeek(xFilial('DD4')+DUP->DUP_CODMOT))
					While !DD4->(EoF()) .And. DD4->(DD4_FILIAL+DD4_CODMOT) == xFilial('DD4')+DUP->DUP_CODMOT
						//-- Verifica a data limite de apresentacao do Documento,
						//-- considerando a data de Tolerancia
						dDtaApr  := IF(Empty(DD4->DD4_TOLERA), DD4->DD4_PRXAPR, DD4->DD4_TOLERA)
							AAdd(aBloqDoc,{cBlqDocMot,;
												DD4->DD4_CODDOC,;
												dDtaApr,;
												Space(Len(DUC->DUC_CODAJU)),;
												DUP->DUP_CODMOT,;
												Space(Len(DUC->DUC_CODVEI)),;
												Space(Len(DUC->DUC_CODFOR)),;
												Space(Len(DUC->DUC_LOJFOR)),;
												CtoD(Space(08)),;
												CtoD(Space(08)),;
												dDtaApr - dDataBase,;
												dDataBase })
						DD4->(DbSkip())
					EndDo
				EndIf
				DUP->(DbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio Periodo de Prestacao de Servico Expirado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DUQ->(DbSetOrder(1)) //-- DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR+DUQ_CODAJU
		If DUQ->(MsSeek(xFilial('DUQ')+cFilOri+cViagem))
			While !DUQ->(EoF()) .And. DUQ->(DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM) == xFilial('DUQ')+cFilOri+cViagem
				DAU->(DbSetOrder(1))
				If DAU->(MsSeek(xFilial('DAU') + DUQ->DUQ_CODAJU))
					//--Verifica o Periodo da Prest. de Servico
					DD1->(DbSetOrder(1))
					If DD1->(MsSeek(xFilial('DD1')+DAU->(DAU_CODFOR+DAU_LOJFOR)))
						AAdd(aBloqDoc,{	cBlqPerFor,;
										PadR('-',Len(DD3->DD3_CODDOC)),;
										CtoD(Space(08)),;
										DUQ->DUQ_CODAJU,;
										Space(Len(DUC->DUC_CODMOT)),;
										Space(Len(DUC->DUC_CODVEI)),;
										DAU->DAU_CODFOR,;
										DAU->DAU_LOJFOR,;
										DD1->DD1_DTAAFA,;
										DD1->DD1_DTARET,;
										0,;
										dDataBase })
					EndIf
				EndIf
				DUQ->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

//-- del129 --jornada de trabalho
If lAptJor
	If !Empty(cViagem)
		// posicionar viagem
		If DTQ->DTQ_TIPTRA == '4' .Or. DTQ->DTQ_TIPTRA == '1'
			DAY->(DbSetOrder(3)) //--Verificar se há Lançamentos Pendentes de Justificativas
			DUP->(DbSetOrder(1))
			DUP->(MsSeek(cSeekDUP := xFilial('DUP')+cFilOri+cViagem))
			While DUP->(!Eof()) .And. DUP->(xFilial('DUP')+DUP_FILORI+DUP_VIAGEM) == cSeekDUP
				If DAY->(DbSeek(xFilial('DAY')+DUP->DUP_CODMOT+StrZero(2, Len(DAY->DAY_STATUS))))
					Aadd( aBloqueio, { cBlqJust, '', '', Space(Len(DUC->DUC_CODPRO)), 0, 1, -1, DUP->DUP_CODVEI,DUP->DUP_CODMOT } )
				EndIf
				DUP->(dbSkip())
			EndDo
		EndIf
   ElseIf Len(aMotorista) > 0
   	DAY->(DbSetOrder(3)) //--Verificar se há Lançamentos Pendentes de Justificativas
   	For nI := 1 To Len(aMotorista)
			If DAY->(DbSeek(xFilial('DAY')+aMotorista[nI]+StrZero(2, Len(DAY->DAY_STATUS))))
				Aadd( aBloqueio, { cBlqJust, '', '', Space(Len(DUC->DUC_CODPRO)), 0, 1, -1, '',DUP->DUP_CODMOT } )
			EndIf
			If !Empty(cStrMot)
				cStrMot += ","
			EndIf
			cStrMot += "'"+aMotorista[nI]+"'"
		Next nI
	EndIf
EndIf
// --------------------------------+
// PROCESSO - REGRA DE RESTRICOES	|
// CARREGA BLOQUEIO DA VIAGEM		|
// --------------------------------+
If lRestricao .And. Len(aRestricao) > 0

	If aRestricao[1]

		aRestricao := aRestricao[3]
		
		//-- Modela Informação Para Tratamento No TMSA029
		cDescRtr := ""
		If lTmsa029 .And. Tmsa029Use("TMSA140")
			For nI := 1 To Len(aRestricao)
				If Len(aRestricao[nI]) >= 11 .And. !Empty(aRestricao[nI,11])
					cDescRtr += aRestricao[nI,11]
					
					If nI < Len(aRestricao)
						cDescRtr += "|"
					EndIf
					
				EndIf
			Next nI
		EndIf			   
		
		Aadd( aBloqueio, {cBlqRest, '','',Space(Len(DUC->DUC_CODPRO)), 0, 1, -1, '',DUP->DUP_CODMOT, cDescRtr } )
	EndIf
EndIf

If AliasInDic('DIE') .And. DTQ->DTQ_TIPTRA == '4' //-- Rodoviario Internacional
	DIE->(dbSetOrder(1))
	For nI := 1 To Len(aVeiculos)
		//--Verificar veiculos sem permisso cadastrado
		If DIE->(!MsSeek(xFilial('DIE')+aVeiculos[nI,1]))
			Aadd( aBloqueio, { cBlqSemPer, '', '', Space(Len(DUC->DUC_CODPRO)), 1, 2, -1, aVeiculos[nI,1], Space(Len(DUC->DUC_CODMOT)) } )
			Exit
		EndIf
		aRegDCA := TmsRegDCA( cRota )
		cCdpOri := aRegDCA[1,5]
		cCdpDes := ''
		If DTQ->DTQ_SERTMS ='2'
			For nB  := 2 To Len(aRegDCA)
				If !Empty(cCdpDes)
					cCdpDes += "', "
				EndIf
				cCdpDes += "'"+aRegDCA[nB,5]
			Next nB
			If !Empty(cCdpDes)
				cCdpDes += "'"
			EndIf
		Else
			DUD->( DbSetOrder( 2 ) )
			If DUD->( MsSeek( cSeek := xFilial('DUD') + cFilOri + cViagem, .F. ) )
				cCdpDes := "'" + Posicione('DUY',1,xFilial('DUY')+DUD->DUD_CDRCAL,'DUY_PAIS') + "'"
			EndIf
		EndIf

		//--Avaliar se existe permisso para as regioes
		cQuery := "SELECT COUNT(DIE_CODVEI) NQTDPER FROM "
		cQuery += RetSqlName("DIE")+" DIE, "
		cQuery += RetSqlName("DIF")+" DIF  "
		cQuery += " WHERE DIE.DIE_FILIAL  = '"+xFilial('DIE')+"'"
		cQuery += "   AND DIE.DIE_CODVEI  = '"+aVeiculos[nI,1]+"'"
		cQuery += "   AND DIE.D_E_L_E_T_  = ' '"
		cQuery += "   AND DIF.DIF_FILIAL  = '"+xFilial('DIF')+"'"
		cQuery += "   AND DIF.DIF_CODVEI  = DIE_CODVEI"
		cQuery += "   AND DIF.DIF_NUMPER  = DIE_NUMPER"
		cQuery += "   AND DIF.DIF_CDPORI  = '"+cCdpOri+"'"
		cQuery += "   AND DIF.DIF_CDPDES IN ("+cCdpDes+")"
		cQuery += "   AND DIF.D_E_L_E_T_  = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->NQTDPER)
			Aadd( aBloqueio, { cBlqSPerRg, '', '', Space(Len(DUC->DUC_CODPRO)), 1, 2, -1, aVeiculos[nI,1], Space(Len(DUC->DUC_CODMOT)) } )
		EndIf
		(cAliasQry)->(dbCloseArea())

		//--Avaliar se o permisso nao esta vencido
		cAliasQry := GetNextAlias()
		cQuery := "SELECT COUNT(DIE_CODVEI) NQTDPER FROM "
		cQuery += RetSqlName("DIE")+" DIE, "
		cQuery += " WHERE DIE.DIE_FILIAL  = '"+xFilial('DIE')+"'"
		cQuery += "   AND DIE.DIE_CODVEI  = '"+aVeiculos[nI,1]+"'"
		cQuery += "   AND DIE.DIE_INIVIG <= '"+Dtos(dDataBase)+"'"
		cQuery += "   AND DIE.DIE_FIMVIG >= '"+Dtos(dDataBase)+"'"
		cQuery += "   AND DIE.D_E_L_E_T_  = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->NQTDPER)
			Aadd( aBloqueio, { cBlqPerVei, '', '', Space(Len(DUC->DUC_CODPRO)), 1, 2, -1, aVeiculos[nI,1], Space(Len(DUC->DUC_CODMOT)) } )
		EndIf
		(cAliasQry)->(dbCloseArea())

	Next nI
EndIf

//-- Inicio - Tratamento Para Bloqueio De Viagens Por Incompatibilidades de Produtos (ONU) e RRE
TMSIncoRRE(@aBloqueio,@aBloqDoc,'',cFilOri,cViagem)


If lTMBLQVGE
	aBlqUsr := ExecBlock( 'TMBLQVGE', .F., .F., { cFilOri, cViagem, cRota, nValFreRec, cSerTms } )
	If ValType(aBlqUsr) == 'A'
		For nI := 1 To Len(aBlqUsr)
			//-- Somente bloqueios de Usuario
			If SubStr(aBlqUsr[nI,1],1,1) == "U"
				Aadd( aBloqueio, {	aBlqUsr[nI,1],aBlqUsr[nI,2],aBlqUsr[nI,3],aBlqUsr[nI,4],aBlqUsr[nI,5],;
				                   	aBlqUsr[nI,6],aBlqUsr[nI,7],aBlqUsr[nI,8],aBlqUsr[nI,9] } )
			EndIf
		Next nI
	EndIf
EndIf

//-- Permite manipulacao do array aBloqueio ou desativar o Bloqueio
If lTMBLOQUE
	aBlqUsr := ExecBlock("TMBLOQUE",.F.,.F.,{cFilOri, cViagem, aBloqueio})
	If ValType(aBlqUsr) == "A"
		aBloqueio := AClone(aBlqUsr)
	EndIf
EndIf

//-- Permite manipulacao do array aBloqDoc ou desativar o Bloqueio dos Docs
If lTMBLOQDB
	aBlqUsr := ExecBlock("TMBLOQDB",.F.,.F.,{cFilOri, cViagem, aBloqDoc})
	If ValType(aBlqUsr) == "A"
		aBloqDoc := AClone(aBlqUsr)
	EndIf
EndIf
//-- Ordena array Bloqueio + Produto + Veiculo + Motorista.
aSort( aBloqueio,,,{ |x,y| x[1]+x[4]+x[8]+x[9] < y[1]+y[4]+y[8]+y[9] } )

If Len( aLimite ) > 0
	If Len( aBloqueio ) == 0 .And. !lVgeMod3

		Help( '', 1, 'TMSXFUNA30' ) // Limites não encontrados

	ElseIf lTela
		//-- Controle de dimensoes de objetos
		AAdd( aObjects, { 100, 100,.T.,.T. } )
		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj:= MsObjSize( aInfo, aObjects,.T. )
		//-- Titulo do TWBrowse - Bloqueios 10 - 90
		AAdd( aTitleFld, STR0059 ) //-- "Bloqueios Operacionais"
		DbSelectArea("DUC") //Precisa posicionar pois binarios antigos a RetTitle nao tem alias
		aTitulos := {	"",;
						RetTitle('DUC_CODBLQ'),	RetTitle('DUC_DESBLQ'),;
						STR0020,				STR0021,; //"Cliente"###"Loja"
						RetTitle('DUC_CODPRO'), RetTitle('DUC_CODVEI'),;
						RetTitle('DUC_CODMOT'), RetTitle('DUC_VALLIM'),;
						RetTitle('DUC_VALCAR'), STR0026}

		If AliasInDic('DD1') .And. !Empty(aBloqDoc)
			//-- Titulo do TWBrowse - Bloqueios D1 - D4
			AAdd( aTitleFld, STR0060 ) //-- "Bloqueios Controle Docto."
			//-- Browse Referente aos Bloqueios - Controle de Documentos
			aTitBlqDoc := {	"",;
							RetTitle('DUC_CODBLQ'),	RetTitle('DUC_DESBLQ'),	RetTitle('DUC_CODDOC'),;
							RetTitle('DUC_DESDOC'),	STR0056,				RetTitle('DUC_DTAAPR'),;	//-- "Dt. Viagem"
							STR0057,				RetTitle('DUC_DTAAFA'),	RetTitle('DUC_DTARET'),;	//-- "Dias Atraso"
							RetTitle('DUC_CODVEI'),	RetTitle('DUC_CODMOT'),	RetTitle('DUC_CODAJU'),;
							RetTitle('DUC_CODFOR'),	RetTitle('DUC_LOJFOR'),	RetTitle('DUC_NOMFOR') }

			aButtons := {{'DESTINOS',{|| IF(oFolderBlq:nOption == 2, TMSADocExig(aBloqDoc, oTmsBrwDoc:nAT), HELP('',1,'TMSXFUNC12')) }, STR0054, STR0055 }}	//-- 'Mais Detalhes...' # 'Mais Det.' //-- 'Opcao nao disponivel nesta pasta'
		EndIf

		DEFINE MSDIALOG oTmsDlg TITLE cTmsTit FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
		oFolderBlq := TFolder():New(	aPosObj[1,1], aPosObj[1,2],;
										aTitleFld, {"",""}, oTmsDlg,,,,.T.,.F.,;
										aPosObj[1,4] - 5, aPosObj[1,3] - 5)

		oTmsBrw := TWBrowse():New(	3,;
									3,;
									(aPosObj[1,4]-aPosObj[1,2])-8,;
									(aPosObj[1,3]-aPosObj[1,1])-8,,;
									aTitulos,,oFolderBlq:aDialogs[1],,,,,,,,,,,,,,.T. )

		oTmsBrw:bLDblClick := { || oTmsDlg:End() }
		oTmsBrw:SetArray( aBloqueio )
		oTmsBrw:bLine := { || {	If(aBloqueio[ oTmsBrw:nAT, 7 ]>=0,oEnable,oDisable),;
								aBloqueio[ oTmsBrw:nAT, 1 ],;							//-- Cod.Bloqueio
								Tabela( 'MB', aBloqueio[ oTmsBrw:nAT, 1 ], .F. ),;		//-- Descricao
								aBloqueio[ oTmsBrw:nAT, 2 ],;							//-- Cliente
								aBloqueio[ oTmsBrw:nAT, 3 ],;							//-- Loja
								aBloqueio[ oTmsBrw:nAT, 4 ],;							//-- Produto
								aBloqueio[ oTmsBrw:nAT, 8 ],;							//-- Veiculo
								aBloqueio[ oTmsBrw:nAT, 9 ],;							//-- Motorista
								TransForm(aBloqueio[ oTmsBrw:nAT, 5 ],PesqPict('DT6','DT6_PESOM3')),;		//-- Limite.Maximo
								TransForm(aBloqueio[ oTmsBrw:nAT, 6 ],PesqPict('DT6','DT6_PESOM3')),;		//-- Carregado
								TransForm(aBloqueio[ oTmsBrw:nAT, 7 ],PesqPict('DT6','DT6_PESOM3')) } }	//-- Disponivel

		If AliasInDic('DD1') .And. !Empty(aBloqDoc)
			oTmsBrwDoc := TWBrowse():New(	3,;
					  						3,;
											(aPosObj[1,4]-aPosObj[1,2])-8,;
											(aPosObj[1,3]-aPosObj[1,1])-8,,;
											aTitBlqdoc,,oFolderBlq:aDialogs[2],,,,,,,,,,,,,,.T. )

			oTmsBrwDoc:bLDblClick := { || oTmsDlg:End() }
			If !Empty(aBloqDoc)
				//+-----------------------------------------------------------------------------------------------------------------
				//-- Tratamento dos campos sensíveis referente ao LGPD(Lei Proteção de Dados)
				//+-----------------------------------------------------------------------------------------------------------------
				If lIsLGPD
					aProteFlds := TMLGPDCpPr({"A2_NOME"},"SA2")
					nTamCpos:= Len(aProteFlds)
					If nTamCpos > 0
						If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aProteFlds )) < nTamCpos
							cSA2Nome := Replicate("*",Len(SA2->A2_NOME))
						Else
							cSA2Nome := Posicione('SA2',1,xFilial('SA2')+aBloqDoc[oTmsBrwDoc:nAT,7]+aBloqDoc[oTmsBrwDoc:nAT,8],'A2_NOME')
						EndIf
					EndIf
				Else
					cSA2Nome := Posicione('SA2',1,xFilial('SA2')+aBloqDoc[oTmsBrwDoc:nAT,7]+aBloqDoc[oTmsBrwDoc:nAT,8],'A2_NOME')
				EndIf
				//+-----------------------------------------------------------------------------------------------------------------

				oTmsBrwDoc:SetArray( aBloqDoc )
				oTmsBrwDoc:bLine := { || {	If(aBloqDoc[ oTmsBrwDoc:nAT, 11 ]>=0,oEnable,oDisable),;
											aBloqDoc[ oTmsBrwDoc:nAT, 01 ],;						//-- Cod.Bloqueio
						  					Tabela( 'MB', aBloqDoc[ oTmsBrwDoc:nAT, 1 ], .F. ),;	//-- Des.Bloqueio
											aBloqDoc[ oTmsBrwDoc:nAT, 02 ],;						//-- Cod.Docto.
											Posicione('DD0',1,xFilial('DD0')+aBloqDoc[ oTmsBrwDoc:nAT, 2 ],'DD0_DESDOC'),;	//-- Desc.Docto
											aBloqDoc[ oTmsBrwDoc:nAT, 12 ],;						//-- Dt.Viagem
											aBloqDoc[ oTmsBrwDoc:nAT, 03 ],;						//-- Dt.Apresen.
 											IF(aBloqDoc[ oTmsBrwDoc:nAT, 11] > 0, 0,aBloqDoc[ oTmsBrwDoc:nAT, 11]) ,;		//--Dias Atraso
											aBloqDoc[ oTmsBrwDoc:nAT, 09 ],;						//-- Dt.Afast.
											aBloqDoc[ oTmsBrwDoc:nAT, 10 ],;						//-- Dt.Retorno
											aBloqDoc[ oTmsBrwDoc:nAT, 06 ],;						//-- Cod.Veiculo
											aBloqDoc[ oTmsBrwDoc:nAT, 05 ],;						//-- Cd.Motorista
											aBloqDoc[ oTmsBrwDoc:nAT, 04 ],;						//-- Cd.Ajudante
											aBloqDoc[ oTmsBrwDoc:nAT, 07 ],;						//-- Fornecedor
											aBloqDoc[ oTmsBrwDoc:nAT, 08 ],;						//-- Loja
											cSA2Nome } }
			EndIf
		EndIf
		ACTIVATE MSDIALOG oTmsDlg ON INIT EnchoiceBar(oTmsDlg,{|| oTmsDlg:End() },{|| oTmsDlg:End() },, aButtons )
	EndIf
Else
	//-- Exclui os itens que nao estao mais bloqueados.
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DUC_FILIAL, DUC_FILORI, DUC_VIAGEM, DUC_CODPRO, DUC_CODBLQ, DUC_CODMOT, DUC_CODVEI, DUC_STATUS, "
	cQuery += "       DUC_CODDOC, DUC_CODAJU, DUC_CODFOR, DUC_LOJFOR, DUC_DTAAPR, DUC_DTAAFA, DUC_DTARET, DUC.R_E_C_N_O_ DUCRECNO "
	cQuery += " FROM " + RetSqlName("DUC") + " DUC "
	cQuery += " WHERE DUC_FILIAL = '"+xFilial("DUC")+"'"
	If !Empty( cFilOri + cViagem )
		cQuery += " AND DUC_FILORI = '"+cFilOri+"' "
		cQuery += " AND DUC_VIAGEM = '"+cViagem+"' "
	EndIf
	If !Empty(cStrMot)
		cQuery += " AND  DUC_CODMOT  IN ( " + cStrMot + ")"
	EndIf
	cQuery += " AND  DUC_STATUS  = '1' "
	cQuery += " AND  DUC.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	TcSetField(cAliasQry,"DUC_DTAAPR","D",TamSX3("DUC_DTAAPR")[1],TamSX3("DUC_DTAAPR")[2])
	TcSetField(cAliasQry,"DUC_DTAAFA","D",TamSX3("DUC_DTAAFA")[1],TamSX3("DUC_DTAAFA")[2])
	TcSetField(cAliasQry,"DUC_DTARET","D",TamSX3("DUC_DTARET")[1],TamSX3("DUC_DTARET")[2])

	While (cAliasQry)->(!Eof())
		// --------------------------------------------------------------------+
		// PROCESSO - REGRA DE RESTRICOES - EXCLUI ITENS DE BLOQUEIO DA VIAGEM |
		// -----------------------------------	---------------------------------+
		If	lRestricao .And. (cAliasQry)->DUC_CODBLQ == PadR('R1', Len(DUC->DUC_CODBLQ))
			DbSelectArea("DIY")
			DbSetOrder(1)
			// - Tabela Itens Bloqueio da Viag.
			If DIY->( DbSeek(xFilial("DIY") + cFilOri + cViagem + (cAliasQry)->DUC_CODBLQ ) )
				While DIY->(DIY_FILORI + DIY_VIAGEM + DIY_CODBLQ ) == (cFilOri + cViagem + (cAliasQry)->DUC_CODBLQ )
					RecLock("DIY",.F.)
					DbDelete()
					MsUnlock()
					DIY->(DbSkip())
				EndDo
			EndIf
			// - Tabela Bloqueio
			DUC->(dbGoTo((cAliasQry)->DUCRECNO))
			RecLock( 'DUC', .F. )
			DbDelete()
			MsUnLock()

			// -------------------------------------------------------------------
		ElseIf	(cAliasQry)->DUC_CODBLQ <> PadR('D1', Len(DUC->DUC_CODBLQ)) .And.;
			(cAliasQry)->DUC_CODBLQ <> PadR('D2', Len(DUC->DUC_CODBLQ)) .And.;
			(cAliasQry)->DUC_CODBLQ <> PadR('D3', Len(DUC->DUC_CODBLQ)) .And.;
			(cAliasQry)->DUC_CODBLQ <> PadR('D4', Len(DUC->DUC_CODBLQ))

			If ( nPos := Ascan( aBloqueio, { | e | e[1] + e[4] + e[8] + e[9] == (cAliasQry)->DUC_CODBLQ + (cAliasQry)->DUC_CODPRO + (cAliasQry)->DUC_CODVEI + (cAliasQry)->DUC_CODMOT } ) ) == 0 .Or. aBloqueio[ nPos, 7 ] >= 0
				DUC->(dbGoTo((cAliasQry)->DUCRECNO))
				RecLock('DUC', .F. )
				DbDelete()
				MsUnLock()
			EndIf
		ElseIf 	AliasInDic('DD1') .And. (;
				(cAliasQry)->DUC_CODBLQ == PadR('D1', Len(DUC->DUC_CODBLQ)) .Or.;
				(cAliasQry)->DUC_CODBLQ == PadR('D2', Len(DUC->DUC_CODBLQ)) .Or.;
				(cAliasQry)->DUC_CODBLQ == PadR('D3', Len(DUC->DUC_CODBLQ)) .Or.;
				(cAliasQry)->DUC_CODBLQ == PadR('D4', Len(DUC->DUC_CODBLQ)))

			If !Empty(aBloqDoc)
				//-- Verifica o registro de bloqueio (DUC) X Os Bloqueios obtidos no aBloqDoc
				If (nPos := Ascan(aBloqDoc, { |e| e[1]+e[2]+e[4]+e[5]+e[6]+e[7]+e[8] == (cAliasQry)->(DUC_CODBLQ+DUC_CODDOC+DUC_CODAJU+DUC_CODMOT+DUC_CODVEI+DUC_CODFOR+DUC_LOJFOR)})) == 0
					//-- Monta array para reavaliacao dos Status
					AAdd( aAvaliaBlq, {	(cAliasQry)->DUC_CODBLQ,;
										(cAliasQry)->DUC_CODFOR,;
										(cAliasQry)->DUC_LOJFOR,;
										(cAliasQry)->DUC_CODMOT,;
										(cAliasQry)->DUC_DTAAPR,;
										(cAliasQry)->DUC_DTAAFA,;
										(cAliasQry)->DUC_DTARET,;
										.F. } )
						DUC->(dbGoTo((cAliasQry)->DUCRECNO))
						RecLock( 'DUC', .F. )
						DbDelete()
						MsUnLock()

				Else
					//-- Registro foi encontrado na base de dados
					//-- Reavalia o bloqueio e caso o mesmo nao exista mais, exclui o bloqueio
					If aBloqDoc[nPos,1] <> PadR('D4',Len(DUC->DUC_CODBLQ))
						If dDataBase > aBloqDoc[nPos,3] .And. (cAliasQry)->DUC_STATUS <> StrZero(2,Len(DUC->DUC_STATUS))
							//-- Monta array para reavaliacao dos Status
							AAdd( aAvaliaBlq, {	(cAliasQry)->DUC_CODBLQ,;
												(cAliasQry)->DUC_CODFOR,;
												(cAliasQry)->DUC_LOJFOR,;
												(cAliasQry)->DUC_CODMOT,;
												(cAliasQry)->DUC_DTAAPR,;
												(cAliasQry)->DUC_DTAAFA,;
												(cAliasQry)->DUC_DTARET,;
												.F. } )
							DUC->(dbGoTo((cAliasQry)->DUCRECNO))
							RecLock( 'DUC', .F. )
							DbDelete()
							MsUnLock()
						EndIf
					ElseIf aBloqDoc[nPos,1] == PadR('D4',Len(DUC->DUC_CODBLQ))
						If  dDataBase > aBloqDoc[nPos,9] .And. dDataBase < aBloqDoc[nPos,10] .And.;
							(cAliasQry)->DUC_STATUS <> StrZero(2,Len(DUC->DUC_STATUS))
							//-- Monta array para reavaliacao dos Status
							AAdd( aAvaliaBlq, {	(cAliasQry)->DUC_CODBLQ,;
												(cAliasQry)->DUC_CODFOR,;
												(cAliasQry)->DUC_LOJFOR,;
												(cAliasQry)->DUC_CODMOT,;
												(cAliasQry)->DUC_DTAAPR,;
												(cAliasQry)->DUC_DTAAFA,;
												(cAliasQry)->DUC_DTARET,;
												.F. } )
							DUC->(dbGoTo((cAliasQry)->DUCRECNO))
							RecLock( 'DUC', .F. )
							DbDelete()
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Else
				DUC->(dbGoTo((cAliasQry)->DUCRECNO))
				RecLock('DUC', .F. )
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
EndIf

DbSelectArea("DUC")
For nCntFor := 1 To Len( aBloqueio )
	// -------------------------------------------------------------------+
	// PROCESSO - REGRA DE RESTRICOES GRAVA BLOQUEIO DA VIAGEM NA (DUC)	|
	// E OS ITENS DE BLQ  (DIY) APENAS P/ RESTRICOES 	             	  	|
	// -------------------------------------------------------------------+
	
	lBlqDDu := .F.
	If lRestricao .AND. aBloqueio[ nCntFor, 1 ] == "R1"
		If	DUC->( MsSeek( xFilial('DUC') + cFilOri + cViagem + aBloqueio[ nCntFor, 1 ] )) //+ aBloqueio[ nCntFor, 4 ] + aBloqueio[ nCntFor, 8 ] + aBloqueio[ nCntFor, 9 ] ) )
			//-- Se liberado e o valor carregado ainda for menor ou igual
			If !lTMSBLVG .And. ( DUC->DUC_STATUS == StrZero( 2, Len( DUC->DUC_STATUS ) ) .Or.  ; 
								 DUC->DUC_VALCAR <  aBloqueio[ nCntFor, 6 ] .Or. ; 
								 ( !lHelp .And. DUC->DUC_VALCAR == aBloqueio[ nCntFor, 6 ] .And. DUC->DUC_STATUS == StrZero( 2, Len( DUC->DUC_STATUS )  ) ) )
				Loop
			EndIf

			RecLock('DUC',.F.)
			DUC->DUC_STATUS := StrZero( 1, Len( DUC->DUC_STATUS ) )
		Else
			RecLock('DUC',.T.)
			DUC->DUC_FILIAL := xFilial('DUC')
			DUC->DUC_FILORI := cFilOri
			DUC->DUC_VIAGEM := cViagem
			DUC->DUC_CODBLQ := aBloqueio[ nCntFor, 1 ]
			DUC->DUC_CODPRO := aBloqueio[ nCntFor, 4 ]
			DUC->DUC_CODVEI := aBloqueio[ nCntFor, 8 ]
			DUC->DUC_CODMOT := aBloqueio[ nCntFor, 9 ]
			DUC->DUC_STATUS := StrZero( 1, Len( DUC->DUC_STATUS ) )
		EndIf

		DUC->DUC_VALLIM := aBloqueio[ nCntFor, 5 ]
		DUC->DUC_VALCAR := aBloqueio[ nCntFor, 6 ]
		MsUnLock()
		lBlqDDU := .T.

		//-- DIY - Restrições da Viagem
		DbSelectArea("DIY")
		DbSetOrder(1)

		For nX := 1 To Len(aRestricao)
			//-- X2_UNICO DIY_FILIAL+DIY_FILORI+DIY_VIAGEM+DIY_CODBLQ+DIY_CODREG+DIY_CATEGO+DIY_ITEM
			If !DIY->(dbSeek(xFilial("DIY") + cFilOri + cViagem + aBloqueio[ nCntFor, 1 ] + aRestricao[nx][6] + aRestricao[nx][7]+ aRestricao[nx][8]))
				
				RecLock("DIY",.T.)
				 DIY_FILIAL	:= FwxFilial("DIY")
				 DIY_FILORI	:= cFilOri
				 DIY_VIAGEM	:= cViagem
				 DIY_CODBLQ	:= aBloqueio[ nCntFor, 1 ] // R1
				 DIY_CODREG := aRestricao[nx][6]
				 DIY_CATEGO := aRestricao[nx][7]
				 DIY_ITEM	:= aRestricao[nx][8]
				 DIY_DESCRI := aRestricao[nx][9]
				 DIY_CODCLI	:= aRestricao[nx][1]
				 DIY_LOJCLI	:= aRestricao[nx][2]
				 DIY_NOMCLI	:= aRestricao[nx][3]
				 DIY_CODARE := aRestricao[nx][4]
				 DIY_DESARE := aRestricao[nx][5]
				MsUnlock()
			EndIf
						

		    //-- MSG (Interface) com as restricoes encontradas
			If(aRestricao[ nX, 7 ] == "1") ; cCateg := STR0115 ; EndIf //"Restrições"
			If(aRestricao[ nX, 7 ] == "2") ; cCateg := STR0116 ; EndIf //"Restrições de Usuário"


			cMsgBlq := ""
			cMsgBlq := AllTrim(AlltoChar(Tabela('MB',aBloqueio[ nCntFor, 1 ],.F.)) +" - "+ ; //-- Cod Blq
						" Tipo Restri.:"+ cCateg+ " "+ ; 			//-- Descricao do tipo de restricao
						" Cod. Regra:" +aRestricao[nX][6]+" "+ ; //-- Cod Regra Restricao
						" Descr. Regra:" +aRestricao[nX][9] )		//-- Descrição da Regra Restricao

			If Ascan( aMsgErr, { | x |  x[1] == cMsgBlq } ) == 0
				AAdd(aMsgErr, {cMsgBlq,'','TMSA400()'}) //-- Array com msg de bloqueio a ser exiba na tela
			EndIf
		Next nX

	//-- Nao tem limite disponivel
	ElseIf aBloqueio[ nCntFor, 7 ] < 0
		If	DUC->( MsSeek( xFilial('DUC') + cFilOri + cViagem + aBloqueio[ nCntFor, 1 ] + aBloqueio[ nCntFor, 4 ] + aBloqueio[ nCntFor, 8 ] + aBloqueio[ nCntFor, 9 ], .F. ) )
			//-- Se liberado e o valor carregado ainda for menor ou igual
			If !lTMSBLVG .And. ( DUC->DUC_STATUS == StrZero( 2, Len( DUC->DUC_STATUS ) ) .Or.  ; 
								 DUC->DUC_VALCAR <  aBloqueio[ nCntFor, 6 ] .Or. ; 
								 ( !lHelp .And. DUC->DUC_VALCAR == aBloqueio[ nCntFor, 6 ] .And. DUC->DUC_STATUS == StrZero( 1, Len( DUC->DUC_STATUS )  ) ) )
				Loop
			EndIf
			RecLock('DUC',.F.)
			cMsgBlq := Tabela('MB',aBloqueio[ nCntFor, 1 ],.F.)
		Else
			RecLock('DUC',.T.)
			DUC->DUC_FILIAL := xFilial('DUC')
			DUC->DUC_FILORI := cFilOri
			DUC->DUC_VIAGEM := cViagem
			DUC->DUC_CODBLQ := aBloqueio[ nCntFor, 1 ]
			DUC->DUC_CODPRO := aBloqueio[ nCntFor, 4 ]
			DUC->DUC_CODVEI := aBloqueio[ nCntFor, 8 ]
			DUC->DUC_CODMOT := aBloqueio[ nCntFor, 9 ]
			cMsgBlq := Tabela('MB',aBloqueio[ nCntFor, 1 ],.F.)
		EndIf
		DUC->DUC_VALLIM := aBloqueio[ nCntFor, 5 ]
		DUC->DUC_VALCAR := aBloqueio[ nCntFor, 6 ]
		DUC->DUC_STATUS := StrZero( 1, Len( DUC->DUC_STATUS ) )
		MsUnLock()
		lBlqDDU := .T.
		If Ascan( aMsgErr, { | x | x[1] == cMsgBlq } ) == 0
			AAdd(aMsgErr, {cMsgBlq,'','TMSA400()'})
		EndIf
	EndIf

	//-- 02Feb2015 -> Novo Tratamento Para Tabela DDU
	If lTmsa029 .And. Len(aMsgErr) > 0 .AND. lBlqDDU

		// Monta Mensagem Para Tabela DDU
		If Len(aBloqueio[nCntFor]) >= 10 .And. !Empty(aBloqueio[nCntFor,10])
			cMsgBlq := Alltrim(aBloqueio[nCntFor,10])
		Else

			cMsgBlq := Iif(!Empty(aBloqueio[ nCntFor, 4 ]),' ' + DUC->(RetTitle('DUC_CODPRO')) + ': #' + aBloqueio[ nCntFor, 4 ]+ "#" ,'') 
			cMsgBlq += Iif(!Empty(aBloqueio[ nCntFor, 8 ]),' ' + DUC->(RetTitle('DUC_CODVEI')) + ': #' + aBloqueio[ nCntFor, 8 ]+ "#",'') 
			cMsgBlq += Iif(!Empty(aBloqueio[ nCntFor, 9 ]),' ' + DUC->(RetTitle('DUC_CODMOT')) + ': #' + aBloqueio[ nCntFor, 9 ] + " " + Tabela('MB',aBloqueio[ nCntFor, 1 ],.F.)+ "#" ,'')
			cMsgBlq += Iif(!Empty(aBloqueio[ nCntFor, 5 ]),' ' + DUC->(RetTitle('DUC_VALLIM')) + ': #' + Transform( aBloqueio[ nCntFor, 5 ],PesqPict('DUC','DUC_VALLIM'))+ "#" ,'')
			cMsgBlq += Iif(!Empty(aBloqueio[ nCntFor, 6 ]),' ' + DUC->(RetTitle('DUC_VALCAR')) + ': #' + Transform( aBloqueio[ nCntFor, 6 ],PesqPict('DUC','DUC_VALLIM'))+ "|" ,'')

		EndIf

		cMsgBlq := iIf(Empty(cMsgBlq),Tabela('MB',aBloqueio[ nCntFor, 1 ],.F.),cMsgBlq)

		If Tmsa029Blq( 3  ,; 						// 01 - nOpc
						'TMSA140',;					// 02 - Rotina
						aBloqueio[ nCntFor, 1 ],;	// 03 - Tipo Bloq
						cFilOri,;						// 04 - Filial Origem
						'DUC',;						// 05 - Tabela Referencial
						'1',;							// 06 - Indice Da Tabela
						xFilial('DUC') + cFilOri + cViagem,; // 07 - Chave Indexação
						cViagem,;						// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
						cMsgBlq,; 						// 09 - Detalhes Adicionais a Respeito Do Bloqueio
						)								// 10 - Opcao Rotina
		EndIf
	EndIf

Next nCntFor

//-- Trata Bloqueios referente ao Controle de Documentos
If AliasInDic('DD1')
	If !Empty(aBloqDoc)
		For nCntFor := 1 To Len( aBloqDoc )
			If ((aBloqDoc[nCntFor,1] <> PadR('D4',Len(DUC->DUC_CODBLQ)) .And.  dDataBase >= aBloqDoc[nCntFor,3]) .Or.;
				(aBloqDoc[nCntFor,1] == PadR('D4',Len(DUC->DUC_CODBLQ)) .And. (dDataBase >= aBloqDoc[nCntFor,9] .And. dDataBase <= aBloqDoc[nCntFor,10]))) .Or.;
				(!Empty(cAcv) .And. lBlqMotVei) // Quando Motorista e Veiculos sao de filiais diferentes nao pode prosseguir viagem

				lNewDUC := .T.
				cMsgBlq := STR0127 + "#" +  Tabela('MB',aBloqDoc[nCntFor,1],.F.) + "#"

				If DUC->(MsSeek(xFilial('DUC')+cFilOri+cViagem+aBloqDoc[nCntFor,1]))
					While DUC->(DUC_FILIAL+DUC_FILORI+DUC_VIAGEM+DUC_CODBLQ) == xFilial('DUC')+cFilOri+cViagem+aBloqDoc[nCntFor,1]
						If DUC->(DUC_CODBLQ+DUC_CODDOC+DUC_CODAJU+DUC_CODMOT+DUC_CODVEI+DUC_CODFOR+DUC_LOJFOR) == aBloqDoc[nCntFor,1]+aBloqDoc[nCntFor,2]+aBloqDoc[nCntFor,4]+aBloqDoc[nCntFor,5]+aBloqDoc[nCntFor,6]+aBloqDoc[nCntFor,7]+aBloqDoc[nCntFor,8]
							lNewDUC := .F.
							Exit
						EndIf
						DUC->(DbSkip())
					EndDo
				EndIf

				RecLock('DUC',lNewDUC)
				If lNewDUC
					DUC->DUC_FILIAL := xFilial('DUC')
					DUC->DUC_FILORI := cFilOri
					DUC->DUC_VIAGEM := cViagem
					DUC->DUC_CODBLQ := aBloqDoc[nCntFor,1]
					DUC->DUC_CODDOC := aBloqDoc[nCntFor,2]
					DUC->DUC_CODAJU := aBloqDoc[nCntFor,4]
					DUC->DUC_CODMOT := aBloqDoc[nCntFor,5]
					DUC->DUC_CODVEI := aBloqDoc[nCntFor,6]
					DUC->DUC_CODFOR := aBloqDoc[nCntFor,7]
					DUC->DUC_LOJFOR := aBloqDoc[nCntFor,8]
					DUC->DUC_STATUS := StrZero(1,Len(DUC->DUC_STATUS))
				EndIf
				DUC->DUC_DTAAPR := aBloqDoc[nCntFor,3]
				DUC->DUC_DTAAFA := aBloqDoc[nCntFor,9]
				DUC->DUC_DTARET := aBloqDoc[nCntFor,10]
				MsUnLock()

				//-- Monta array para reavaliacao dos Status
				AAdd( aAvaliaBlq, {	DUC->DUC_CODBLQ,;
									DUC->DUC_CODFOR,;
									DUC->DUC_LOJFOR,;
									DUC->DUC_CODMOT,;
									DUC->DUC_DTAAPR,;
									DUC->DUC_DTAAFA,;
									DUC->DUC_DTARET,;
									.T. } )

				If aBloqDoc[ nCntFor, 1 ] == PadR('D1',Len(DUC->DUC_CODBLQ)) //-- Documento Pendente - Fornecedor Prop. do Veiculo
					cMsgBlq +=  RetTitle('DUC_CODVEI') + ': #' + aBloqDoc[ nCntFor, 6 ] + "#"
					cMsgBlq +=  RetTitle('DUC_CODFOR') + ': #' + aBloqDoc[ nCntFor, 7 ] + '/' + aBloqDoc[ nCntFor, 8 ] 
					MsUnLock()

				ElseIf aBloqDoc[ nCntFor, 1 ] == PadR('D2',Len(DUC->DUC_CODBLQ)) //-- Documento Pendente - Fornecedor Ajudante
					cMsgBlq +=  RetTitle('DUC_CODAJU') + ': #' + aBloqDoc[ nCntFor, 4 ] + "#"
					cMsgBlq +=  RetTitle('DUC_CODFOR') + ': #' + aBloqDoc[ nCntFor, 7 ] + '/' + aBloqDoc[ nCntFor, 8 ] 
					MsUnLock()

				ElseIf aBloqDoc[ nCntFor, 1 ] == PadR('D3',Len(DUC->DUC_CODBLQ)) //-- Documento Pendente - Motorista
					cMsgBlq +=  RetTitle('DUC_CODMOT') + ': #' + aBloqDoc[ nCntFor, 05 ]

				ElseIf aBloqDoc[ nCntFor, 1 ] == PadR('D4',Len(DUC->DUC_CODBLQ)) //-- Periodo de Prest. Serv. Expirado
					cMsgBlq += RetTitle('DUC_CODAJU') + ': #' + aBloqDoc[ nCntFor, 4 ] + "#"
					cMsgBlq += RetTitle('DUC_CODFOR') + ': #' + aBloqDoc[ nCntFor, 7 ] + '/' + aBloqDoc[ nCntFor, 8 ]

				ElseIf aBloqDoc[ nCntFor, 1 ] == PadR('D6',Len(DUC->DUC_CODBLQ)) //-- Motorista e Veiculo de filiais diferentes.

					//+-----------------------------------------------------------------------------------------------------------------
					//-- Tratamento dos campos sensíveis referente ao LGPD(Lei Proteção de Dados)
					//+-----------------------------------------------------------------------------------------------------------------
					If lIsLGPD
						aProteFlds := TMLGPDCpPr({"DA4_NOME"},"DA4")
						If nTamCpos:= Len(aProteFlds)
							If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aProteFlds )) < nTamCpos
								cMot := Replicate("*",Len(DA4->DA4_NOME))
							Else
								cMot := Posicione("DA4",1,XFILIAL("DA4")+aBloqDoc[ nCntFor, 5],"DA4_NOME")
							EndIf
						EndIf
					Else
						cMot := Posicione("DA4",1,XFILIAL("DA4")+aBloqDoc[ nCntFor, 5],"DA4_NOME")
					EndIf
					//+-----------------------------------------------------------------------------------------------------------------
					
					cMsgBlq += STR0082 +"#"+ Alltrim(cMot)+"#" // 'Motorista :'
					cMsgBlq += STR0083+"#" // ' esta com a Filial Base : '

					cMot := Posicione("DA4",1,XFILIAL("DA4")+aBloqDoc[ nCntFor, 5],"DA4_FILBASE")
					cMsgBlq += cMot+"#"

					cMsgBlq += STR0084+"" // ' Divergente do '

					cMot := Posicione("DA3",1,XFILIAL("DA3")+aBloqDoc[ nCntFor, 6],"DA3_FILBASE")
					cMsgBlq += STR0085 +"#"+ aBloqDoc[ nCntFor, 6 ]+" "+STR0083+" "+cMot    //Motorista

				EndIf
				
				
				If lNewDUC

					If Ascan( aMsgErr, { | x |  x[1] == cMsgBlq } ) == 0
						AAdd(aMsgErr, { STRTRAN(cMsgBlq,"#"," ")  ,'','TMSA400()'})
					EndIf
					cMsgBlq += "|"
					//-- 02Feb2015 -> Novo Tratamento Para Tabela DDU
					If lTmsa029 //--AliasInDic('DDU')

						If Tmsa029Blq( 3  ,; 						// 01 - nOpc
										'TMSA140',;					// 02 - Rotina
										aBloqDoc[nCntFor,1],;		// 03 - Tipo Bloq
										cFilOri,;						// 04 - Filial Origem
										'DUC',;						// 05 - Tabela Referencial
										'1',;							// 06 - Indice Da Tabela
										xFilial('DUC') + cFilOri + cViagem,; // 07 - Chave Indexação
										cViagem,;						// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
										cMsgBlq,; 						// 09 - Detalhes Adicionais a Respeito Do Bloqueio
										)								// 10 - Opcao Rotina
						EndIf
					EndIf
				EndIf

			EndIf
		Next
		//-- Reavalia os Status da amarracao - Fornecedor/Motorista X Documentos Exigidos
		TMSAvlBlqDoc( aAvaliaBlq )
	EndIf
EndIf

If lHelp .And. !Empty( aMsgErr ) .AND. (Type('lTelaBloq') == 'U' .OR. !lTelaBloq)
	AaddMsgErr( aMsgErr, @aVisErr )
	SetFunName("TMSA400")
	TmsMsgErr( aVisErr )
	SetFunName(cOldFName)
	If Type('lTelaBloq') != 'U'
		lTelaBloq := .T.
	EndIf
	lReturn := .F.
EndIf

RestArea( aAreaDUE )
RestArea( aAreaDT6 )
RestArea( aAreaDTC )
RestArea( aAreaDTR )
RestArea( aAreaDUC )
RestArea( aAreaDUD )
RestArea( aAreaSA7 )
RestArea( aAreaSB5 )
RestArea( aAreaAnt )
RestArea( aAreaDTQ )

Return( lReturn )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsShowPro³ Autor ³ Valdemar Roberto      ³ Data ³ 01/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Produto em CTRCs de Devolucao, Reentrega            ³±±
±±³          ³ e Complemento                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsShowPro(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao de Display (1-CodPro, 2-DesPro)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsShowPro(nOpcao)

Local cRet := ""

If nOpcao == 1
	If DT6->DT6_DOCTMS $ "6.7.8"
		cRet := Posicione("DTC",3,XFILIAL("DTC")+DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO),"DTC_CODPRO")
	Else
		cRet := Posicione("DTC",3,XFILIAL("DTC")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE),"DTC_CODPRO")
	EndIf
Else
	If DT6->DT6_DOCTMS $ "6.7.8"
		cRet := Posicione("SB1",1,xFilial("SB1")+Posicione("DTC",3,xFilial("DTC")+DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO),"DTC_CODPRO"),"B1_DESC")
	Else
		cRet := Posicione("SB1",1,xFilial("SB1")+Posicione("DTC",3,xFilial("DTC")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE),"DTC_CODPRO"),"B1_DESC")
	EndIf
EndIf

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVerOco ³ Autor ³ Valdemar Roberto      ³ Data ³11.04.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica as Ocorrencias                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVerOco(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - No. do Documento                                   ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±³          ³ ExpC4 - Servico de Transporte                              ³±±
±±³          ³ ExpC5 - Tipo da Ocorrencia                                 ³±±
±±³          ³ ExpC6 - Responsavel pela Ocorrencia                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com as Ocorrencias                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSVerOco(cFilDoc, cDoc, cSerie, cSerTMS, cTipOco, cResOco, cTipPnd)
Local aAreaAnt  := GetArea()
Local cAliasQry := ""
Local cQuery    := ""
Local aOcorrenc := {}
Local aTamSx3   := {}

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cSerTMS := ""
Default cTipOco := ""
Default cResOco := ""
Default cTipPnd := ""

#IFDEF TOP
	cAliasQry := GetNextAlias()

	Aadd( aTamSX3 , TamSx3("DUA_QTDOCO") )
	Aadd( aTamSX3 , TamSX3("DUA_DATOCO") )

	cQuery := "SELECT DUA_CODOCO CODOCO, COUNT(*) QTDOCO , DUA_DATOCO DATOCO , DUA_HOROCO HOROCO  "
	cQuery += "FROM " + RetSqlName("DUA") + " DUA "
	cQuery += "JOIN " + RetSqlName("DT2") + " DT2 "
	cQuery += "  ON  DT2_FILIAL     = '" + xFilial("DT2") + "' "
	cQuery += "  AND DT2_CODOCO     = DUA_CODOCO "
	cQuery += "  AND DT2_SERTMS     = '" + cSerTMS + "'"
	cQuery += "  AND DT2_TIPOCO     = '" + cTipOco + "' "
	If !Empty(cTipPnd)
		cQuery += "  AND DT2_TIPPND     = '" + cTipPnd + "' "
	EndIf
	If !Empty(cResOco)
		cQuery += "  AND DT2_RESOCO  = '" + cResOco + "' "
	EndIf
	cQuery += "WHERE DUA_FILIAL     = '" + xFilial("DUA") + "' "
	cQuery += "  AND DUA_FILDOC     = '" + cFilDoc + "' "
	cQuery += "  AND DUA_DOC        = '" + cDoc + "' "
	cQuery += "  AND DUA_SERIE      = '" + cSerie + "' "
	cQuery += "  AND DUA.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY DUA_CODOCO , DUA_DATOCO, DUA_HOROCO  "
	cQuery += "UNION ALL "
	cQuery += "SELECT DUA_CODOCO CODOCO, COUNT(*) QTDOCO  , DUA_DATOCO DATOCO , DUA_HOROCO HOROCO"
	cQuery += "FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "JOIN " + RetSqlName("DUA") + " DUA "
	cQuery += "  ON  DUA_FILIAL     = '" + xFilial("DUA") + "' "
	cQuery += "  AND DUA_FILORI     = DUD_FILORI "
	cQuery += "  AND DUA_VIAGEM     = DUD_VIAGEM "
	cQuery += "  AND DUA_FILDOC     = ' ' "
	cQuery += "  AND DUA_DOC        = ' ' "
	cQuery += "  AND DUA_SERIE      = ' ' "
	cQuery += "  AND DUA.D_E_L_E_T_ = ' ' "
	cQuery += "JOIN " + RetSqlName("DT2") + " DT2 "
	cQuery += "  ON  DT2_FILIAL     = '" + xFilial("DT2") + "' "
	cQuery += "  AND DT2_CODOCO     = DUA_CODOCO "
	cQuery += "  AND DT2_SERTMS     = '" + cSerTMS + "'"
	cQuery += "  AND DT2_TIPOCO     = '" + cTipOco + "' "
	If !Empty(cTipPnd)
		cQuery += "  AND DT2_TIPPND     = '" + cTipPnd + "' "
	EndIf
	If !Empty(cResOco)
		cQuery += "  AND DT2_RESOCO  = '" + cResOco + "' "
   EndIf
	cQuery += "WHERE DUD_FILIAL     = '" + xFilial("DUD") + "' "
	cQuery += "  AND DUD_FILDOC     = '" + cFilDoc + "' "
	cQuery += "  AND DUD_DOC        = '" + cDoc + "' "
	cQuery += "  AND DUD_SERIE      = '" + cSerie + "' "
	cQuery += "  AND DUD_STATUS    IN ('4','9') "
	cQuery += "  AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY DUA_CODOCO , DUA_DATOCO, DUA_HOROCO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	aOcorrenc := {}
	TCSetField(cAliasQry,"QTDOCO","N",aTamSx3[1,1],aTamSx3[1,2])
	TCSetField(cAliasQry,"DATOCO","D",aTamSx3[2,1],aTamSx3[2,2])
	While (cAliasQry)->(!Eof())
		aAdd(aOcorrenc,{(cAliasQry)->CODOCO,(cAliasQry)->QTDOCO ,  (cAliasQry)->DATOCO , (cAliasQry)->HOROCO })
		(cAliasQry)->(dbSkip())
	EndDo
#ENDIF

RestArea(aAreaAnt)
Return (aOcorrenc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSMail   ³ Autor ³ Vitor Raspa                    ³ Data ³ 25.Abr.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para envio de e-mail                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMail(ExpA1,ExpA2,ExpC3,ExpC4,ExpL5,ExpC6,@ExpC7)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array simples com os e-mails dos Destinatarios Externos     ³±±
±±³          ³ ExpA2 - Array simples com os e-mails dos Destinatarios Internos     ³±±
±±³          ³ ExpC3 - Campo 'Assunto' do e-mail                                   ³±±
±±³          ³ ExpC4 - Corpo do e-mail                                             ³±±
±±³          ³ ExpL5 - .T. para apresentar a tela de edicao do e-mail              ³±±
±±³          ³ ExpC6 - Tipo da Mensagem:                                           ³±±
±±³          ³         1-Dest. Externos                                            ³±±
±±³          ³         2-Dest. Internos                                            ³±±
±±³          ³         3-Ambos                                                     ³±±
±±³          ³                                                                     ³±±
±±³          ³ ExpC7 - Referencia p/armazenar mensagens de erro                    ³±±
±±³          ³ ExpL8 - .T. para definir que o corpo do e-mail esta no formato HTML ³±±
±±³          ³ ExpC9 - Caminho de anexo a ser enviado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se o e-mail foi enviado com sucesso                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSMAIL( aDestE, aDestI, cSubject, cBody, lEdit, cTpMsg, cMsgErr, lHTML, cAnexos, aAnexos )

Local oTmsDlgMail
Local oBMP
Local oDestE
Local oDestI
Local oFiles
Local aDest			:= {}
Local cNewDest		:= Space(50)
Local lSendMail		:= .F.
Local nList
Local nCntFor
Local oHTML
Local oScroll

//-Variaveis para conexao com o servidor de e-mail
Local cMailConta
Local cMailServer
Local cMailSenha
Local cMailCtaAut
Local lSmtpAuth		:= GetMv("MV_RELAUTH",,.F.)
Local cMask			:= ""
Local lOk			:= .F.
Local lAutOk		:= .F.
Local cDest			:= ''
Local lRet			:= .F.

Default aDestE		:= {}
Default aDestI		:= {}
Default cSubject	:= Space(150)
Default cBody		:= Space(10)
Default lEdit		:= .F.
Default cTpMsg		:= '3'
Default cAnexos   	:= ""
Default aAnexos		:= {}

If lEdit
	cMask  := "Arquivos Doc       (*.DOC)     | *.DOC | "
	cMask  += "Arquivos Texto     (*.TXT)     | *.TXT | "
	cMask  += "Planilhas          (*.XLS)     | *.XLS | "
	cMask  += "Todos os Arquivos  (*.*)       | *.* |   "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MONTA JANELA PARA EDICAO DO E-MAIL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oTMSDlgMail TITLE STR0029 FROM 178,181 TO 610,1160 PIXEL //"'Edicao do e-mail"
	@ 002,002 BITMAP oBMP RESNAME "email" Of oTMSDlgMail SIZE 100,085 NOBORDER WHEN .F. PIXEL

	If cTpMsg == '1'
		@ 002,106 TO 088,358 LABEL STR0030    PIXEL OF oTMSDlgMail // "Destinatarios Externos"
		@ 011,108 MsGet cNewDest Size 116,009 PIXEL OF oTMSDlgMail

		TButton():New( 011,237, STR0032 , oTmsDlgMail, {|| TMSAtuList(1,oDestE,aDestE,cNewDest,.T.) },053,012,,,,.T.,,,,,,) // "Adicionar a Lista"
		TButton():New( 011,301, STR0033 , oTmsDlgMail, {|| TMSAtuList(2,oDestE,aDestE,        ,.T.)},053,012,,,,.T.,,,,,,) // "Remover da Lista"

		oDestE := TListBox():New( 039, 109, {|u|if(Pcount()>0,nList:=u,nList)}, aDestE,  245,046, , oTmsDlgMail ,,,,.T. )
		oFiles := TListBox():New( 026, 365, {|u|if(Pcount()>0,nList:=u,nList)}, aAnexos, 116,059, , oTmsDlgMail ,,,,.T. )

	ElseIf cTpMsg == '2'
		@ 002,106 TO 088,358 LABEL STR0031 PIXEL OF oTMSDlgMail		// "Destinatarios Internos"

		TButton():New( 011,109, STR0032 , oTmsDlgMail, {|| TMSAtuList(3,oDestI,aDestI,        ,.T.)}, 053,012,,,,.T.,,,,,,) // "Adicionar a Lista"
		TButton():New( 011,173, STR0033 , oTmsDlgMail, {|| TMSAtuList(2,oDestI,aDestI,        ,.T.) },053,012,,,,.T.,,,,,,) // "Remover da Lista"

	  	oDestI := TListBox():New( 026, 109, {|u|if(Pcount()>0,nList:=u,nList)}, aDestI,  245,059, , oTmsDlgMail ,,,,.T. )
		oFiles := TListBox():New( 026, 365, {|u|if(Pcount()>0,nList:=u,nList)}, aAnexos, 116,059, , oTmsDlgMail ,,,,.T. )

	ElseIf cTpMsg == '3'
		@ 002,106 TO 088,230 LABEL STR0030 COLOR CLR_BLUE PIXEL OF oTMSDlgMail // "Destinatarios Externos"
		@ 002,234 TO 088,358 LABEL STR0031 COLOR CLR_BLUE PIXEL OF oTMSDlgMail // "Destinatarios Internos"
		@ 009,108 MsGet cNewDest Size 116,009 PIXEL OF oTMSDlgMail

		TButton():New( 011,237, STR0032, oTmsDlgMail, {|| TMSAtuList(3,oDestI,aDestI,        ,.T.)},053,012,,,,.T.,,,,,,) // "Adicionar a Lista"
		TButton():New( 024,172, STR0033, oTmsDlgMail, {|| TMSAtuList(2,oDestE,aDestE,        ,.T.)},053,012,,,,.T.,,,,,,) // "Remover da Lista"

		TButton():New( 024,108, STR0032, oTmsDlgMail, {|| TMSAtuList(1,oDestE,aDestE,cNewDest,.T.) },053,012,,,,.T.,,,,,,) // "Adicionar a Lista"
		TButton():New( 011,301, STR0033, oTmsDlgMail, {|| TMSAtuList(2,oDestI,aDestI,        ,.T.) },053,012,,,,.T.,,,,,,) // "Remover da Lista"

		oDestE := TListBox():New( 039, 109, {|u|if(Pcount()>0,nList:=u,nList)}, aDestE,  116,046, , oTmsDlgMail ,,,,.T. )
		oDestI := TListBox():New( 026, 238, {|u|if(Pcount()>0,nList:=u,nList)}, aDestI,  116,059, , oTmsDlgMail ,,,,.T. )
	EndIf

	//-- Selecione o Anexo
	@ 002,362 TO 088,486 LABEL STR0110 COLOR CLR_BLUE PIXEL OF oTMSDlgMail // "Selecione o Anexo"
	TButton():New( 011,366, STR0032, oTmsDlgMail, {|| TMSAtuList(1,oFiles,aAnexos,cFile:=cGetFile( cMask, STR0111, 4, "", .F., GETF_ONLYSERVER, .T.  ), .F.) },053,012,,,,.T.,,,,,,) // "Adicionar a Lista"
	TButton():New( 011,426, STR0033, oTmsDlgMail, {|| TMSAtuList(2,oFiles,aAnexos,        ,.F.) },053,012,,,,.T.,,,,,,) // "Remover da Lista"
	oFiles := TListBox():New( 026, 365, {|u|if(Pcount()>0,nList:=u,nList)}, aAnexos, 116,059, , oTmsDlgMail ,,,,.T. )

	@ 091,002 TO 214,486 LABEL STR0034 PIXEL OF oTMSDlgMail // "Dados do e-mail"
	@ 100,006 Say   STR0035  PIXEL OF oTMSDlgMail // "Assunto:"
	@ 108,006 MsGet cSubject Valid !Empty(cSubject) Size 144,009 PIXEL OF oTMSDlgMail

	If !lHTML
		@ 123,006 GET cBody MEMO Valid !Empty(cBody) Size 400/*259*/,084 PIXEL OF oTMSDlgMail
	Else
		oScroll := TScrollBox():New(oTMSDlgMail,123,006,084,259)
		oHTML := TSay():New( 001,001,{||cBody}, oScroll,,,,,,.T.,,,250,500,,,,.T.,,.T. )
	EndIf

	TButton():New( 141,426, STR0036 , oTmsDlgMail, {|| lSendMail := .T., oTmsDlgMail:End() },055,025,,,,.T.,,,,,,) // "Enviar e-mail"
	TButton():New( 175,426, STR0037 , oTmsDlgMail, {|| lSendMail := .F., oTmsDlgMail:End() },055,025,,,,.T.,,,,,,) // "Cancelar Envio"

	ACTIVATE MSDIALOG oTMSDlgMail CENTERED
Else
	lSendMail := .T.
EndIf

If lSendMail
	CursorWait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Obtem dados necessarios a conexao                                                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsgErr     := ''
	cMailConta  := If(cMailConta == NIL,GETMV("MV_EMCONTA"),cMailConta)
	cMailServer := If(cMailServer== NIL,GETMV("MV_RELSERV"),cMailServer)
	cMailSenha  := If(cMailSenha == NIL,GETMV("MV_EMSENHA"),cMailSenha)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o parametro nao estiver definido pega o parametro dos relatorios              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cMailConta )
		cMailConta := GETMV("MV_RELFROM",,"")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o parametro nao estiver definido pega o parametro dos relatorios              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cMailSenha )
		cMailSenha := GETMV("MV_RELPSW")
	EndIf

	cMailCtaAut := GETMV("MV_RELACNT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Caso nao exista conta definida, pega o proprio e-mail origem                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cMailCtaAut )
		cMailCtaAut := cMailConta
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia e-mail com os dados necessarios                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cMailServer) .And. ! Empty(cMailCtaAut) .And.;
		( (lSmtpAuth .And. ! Empty(cMailCtaAut) .And. ! Empty(cMailSenha)) .Or. ! lSmtpAuth)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Conecta uma vez com o servidor de e-mails                                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lOk
			CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cMailSenha RESULT lOk
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Se configurado, efetua a autenticacao                                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAutOk
			If ( lSmtpAuth )
				lAutOk := MailAuth(cMailCtaAut,cMailSenha)
			Else
				lAutOk := .T.
			EndIf
		EndIf

		If lOk .And. lAutOk

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Unindo Destinatarios Internos e Externos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Externos
			For nCntFor := 1 To Len(aDestE)
				AAdd(aDest, aDestE[nCntFor])
			Next
			//-- Internos
			For nCntFor := 1 To Len(aDestI)
				AAdd(aDest, UsrRetMail(Left(aDestI[nCntFor],6)))
			Next

			For nCntFor := 1 To Len(aDest)
				If !Empty(cDest)
					cDest += ';'
				EndIf
				cDest += aDest[nCntFor]
			Next

			If Empty(cDest)
				lOk     := .F.
				cMsgErr := "Nao foi informado Destinatario"
			EndIf

			If lOk
				//-- Monta um Vetor com o path e nome do arquivo em cada linha para passar via email
				For nCntFor := 1 to Len(aAnexos)
					cAnexos += aAnexos[nCntFor] + "; "
				Next nCntFor

				If Empty(cAnexos) //-- Verifica se há anexo
					SEND MAIL FROM cMailConta to cDest SUBJECT cSubject BODY cBody RESULT lSendOk
				Else
					SEND MAIL FROM cMailConta to cDest SUBJECT cSubject BODY cBody ATTACHMENT cAnexos RESULT lSendOk
				EndIf
				If !lSendOk
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Erro no Envio do e-mail                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					GET MAIL ERROR cMsgErr
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Erro na conexao com o SMTP Server ou na autenticacao da conta          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			GET MAIL ERROR cMsgErr
		EndIf
	Else
		cMsgErr := "Problemas nos parametros de configuracao de e-mail"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desconecta com o servidor de e-mails                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk
		DISCONNECT SMTP SERVER
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe mensagem de erro para tratar o retorno da funcao     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk .And. Empty(cMsgErr)
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	CursorArrow()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO    ³TMSAtuListºAutor ³VITOR RASPA          º Data ³ 24-Abr-2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ATUALIZA OS LISTBOXES CONFORME COMANDO DO USUARIO           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºArgumentos³ nExpr1: Numero da opcao:                                   º±±
±±º          ³      1-ADICIONA/2-REMOVE/3-Tratamento p/ Usuarios Internos º±±
±±º          ³ oExpr2: ListBox com a lista                                º±±
±±º          ³ aExpr3: Array com os elementos da lista                    º±±
±±º          ³ cExpr4: E-mail para Adicionar a Lista                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuList(nOperacao, oList, aList, cItem, lHelp)
Local nNewTam
Local nCntFor
Local aAllUsers
Local aUsers		:= {}
Local oDlgUsers
Local oListUsers
Local cListUsers
Local nListUsers
Local cPesqUsers	:= Space(30)
Local nOpc			:= 0
Local oBold
Local oBmp
Default cItem 		:= ''
Default lHelp 		:= .T.

If nOperacao == 1
	If Empty(cItem)
		If lHelp
			Help('',1,'TMSXFUNC02')	//"Nao foi informado e-mail para adicionar a Lista"
		EndIf
	Else
		If lHelp .And. !('@'$cItem)
			Help('',1,'TMSXFUNC03')	//"O e-mail informado nao parece ser um e-mail valido"
		Else
			If AScan(aList,Lower(AllTrim(cItem))) <> 0
				If lHelp
					Help('',1,'TMSXFUNC04') //"Este Destinatario ja esta na lista"
				EndIf
			Else
				AAdd( aList, Lower(cItem) )
				oList:SetItems( aList )
				oList:SetFocus()
			EndIf
		EndIf
	EndIf
ElseIf nOperacao == 2
	If oList:nAt <> 0
		If Len( oList:aITEMS ) > 0
			//Ajusta o tamanho da lista
			nNewTam := Len( aList ) - 1
			aList   := aSize( aDel( aList, oList:nAt ), nNewTam )
			oList:SetItems(aList)
			oList:SetFocus()
		EndIf
	Else
		If lHelp
			Help('',1,'TMSXFUNC05')	//"Nao existem Destinatarios a serem removidos"`
		EndIf
	EndIf
ElseIf nOperacao == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RECUPERANDO TODOS USUARIOS DO SISTEMA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAllUsers := AllUsers()
	For nCntFor := 1 To Len(aAllUsers)
		If aScan(aList, AllTrim(aAllUsers[nCntFor][1][1] + '-' + aAllUsers[nCntFor][1][4])) == 0
			AAdd( aUsers  , aAllUsers[nCntFor][1][1] + '-' + aAllUsers[nCntFor][1][4] )
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TELA PARA SELECIONAR O USUARIO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlgUsers FROM 114,180 TO 335,600 TITLE STR0031 Of oMainWnd PIXEL // 'Destinatarios Internos'

	@ 000,000 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgUsers SIZE 90,255 NOBORDER WHEN .F. PIXEL
	@ 012,060 TO  014,400 Of oDlgUsers PIXEL
	@ 004,066 SAY STR0038 Of oDlgUsers PIXEL SIZE 120,009 FONT oBold // 'Selecione o Usuario:'
	@ 077,070 SAY STR0039 Of oDlgUsers PIXEL SIZE 030,009 // 'Pesquisar'
	@ 018,070 LISTBOX oListUsers VAR cListUsers ITEMS aUsers PIXEL SIZE 127,56 OF oDlgUsers ON DBLCLICK (If(!Empty(cListUsers),(nOpc:=1,oDlgUsers:End()),))
	oListUsers:bChange := {||nListUsers := oListUsers:nAT}

	@ 75, 96 MSGET cPesqUsers VALID If(aScan(aUsers,{|x| x=Alltrim(cPesqUsers)})>0,;
								((oListUsers:nAT :=aScan(aUsers,{|x| x=Alltrim(cPesqUsers)})),(oListUsers:Refresh())),Nil)  of oDlgUsers PIXEL SIZE 100,9

	DEFINE SBUTTON FROM 092,155 TYPE 1 ENABLE OF oDlgUsers ACTION If(!Empty(cListUsers),(nOpc:=1,oDlgUsers:End()),)  OF oDlgUsers PIXEL
	DEFINE SBUTTON FROM 092,110 TYPE 2 ENABLE OF oDlgUsers ACTION (oDlgUsers:End())  OF oDlgUsers PIXEL

	ACTIVATE MSDIALOG oDlgUsers CENTERED

	If nOpc == 1
		If Empty(UsrRetMail(Left(aUsers[nListUsers],6)))
			Help('',1,'TMSXFUNC06')	//"O usuario selecionado nao possui e-mail informado em seu cadastro"
		Else
			AAdd( aList, aUsers[nListUsers] )
			oList:SetItems( aList )
			oList:SetFocus()
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSLocaliz³ Autor ³ Rodolfo K. Rosseto    ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa o produto e verifica se pode ser enderecado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSLocaliz(ExpC1,ExpC2,ExpC3,ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Produto                                  ³±±
±±³          ³ ExpC2 - Filial do Documento                                ³±±
±±³          ³ ExpC3 - Numero do Documento                                ³±±
±±³          ³ ExpC4 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSLocaliz(cCodPro,cFilDoc,cDoc,cSerie)

Local lRet      := .F.
Local aAreaSB1 := SB1->(GetArea())

Default cCodPro := ''
Default cFilDoc := ''
Default cDoc    := ''
Default cSerie  := ''

If Empty(cCodPro)
	If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
		DTC->(dbSetOrder(7))
		If DTC->(MsSeek(xFilial('DTC')+cDoc+cSerie+cFilDoc))
			cCodPro := AllTrim(DTC->DTC_CODPRO)
		EndIf
	Else
		DbSelectArea("DY4")
		DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		If DY4->(MsSeek(xFilial('DY4')+cFilDoc+cDoc+cSerie))
			cCodPro := AllTrim(DY4->DY4_CODPRO)
		EndIf			
	Endif	
EndIf
If !Empty(cCodPro)
   SB1->( DbSetOrder( 1 ) )
   If SB1->( MsSeek( xFilial('SB1') + Padr(cCodPro,TamSx3("B1_COD")[1]) ) )
      	If	TmsChkTES('1') .And. RetFldProd(SB1->B1_COD ,"B1_LOCALIZ") == "S"
			lRet:= .T.
		EndIf
	EndIf
EndIf

RestArea(aAreaSB1)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSVldFunc³ Autor ³ Eduardo de Souza      ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Funcionario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSVldFunc(ExpC1,ExpC2,ExpD1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Matricula                                          ³±±
±±³          ³ ExpC2 - Filial do Funcionario                              ³±±
±±³          ³ ExpD3 - Data                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSVldFunc( cCodMatr, cCodFilial, dData, dDataFim )
Local lRet      := .T.
Local cSituacao := ''
Local cAliasQry := ''
Local aTitle    := {}
Local aMatr     := {}
Local nSelec    := 0
Local aArea     := GetArea()
Local aAreaSRA  := SRA->( GetArea() )
Local aColOfusca:= {}
Local aCpoAccess:= {'RA_FILIAL','RA_MAT', 'RA_NOME', 'RA_CODFUNC', 'RA_DESCFUN'}
Local aCpoAccNew:= {}
Local nCountCpo	:= 0
Local lLGPD		:= FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.)

Default cCodFilial := ''
Default dData      := dDataBase
Default dDataFim   := dDataBase

//--Somente valida a amarracao entre o motorista
//--e o funcionario (TMS x GPE) se o codigo da matricula
//--do funcionario estiver informado no cadastro do motorista
If !Empty( cCodMatr )
	If !Empty( cCodFilial )
		//--Caso o Motorista possua a Filial Base informada em
		//--seu cadastro ou na chamada da funcao de forma recursiva
		//--(passando o codigo do filial a ser considerada), realiza
		//--as consistencias considerando o codigo da filial em questao:
		SRA->( DbSetOrder(1) ) //--RA_FILIAL+RA_MAT
		If SRA->( MsSeek( cCodFilial + cCodMatr ) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VERIFICA SE O FUNCIONARIO ESTA DEMITIDO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( SRA->RA_DEMISSA ) .And. SRA->RA_DEMISSA <= dData
				cSituacao := AllTrim(Tabela("31",PadR('D',Len(SRA->RA_SITFOLH)),.F.))
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³VERIFICA SE O FUNCIONARIO ESTA AFASTADO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cAliasQry := GetNextAlias()
				BeginSQL Alias cAliasQry
					Column 	R8_DATAINI As Date
					Column 	R8_DATAFIM As Date
					SELECT 	SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_DATAINI, SR8.R8_DATAFIM
					FROM 	%Table:SR8% SR8
					WHERE 	SR8.R8_FILIAL = %Exp:cCodFilial% AND
							SR8.R8_MAT = %Exp:cCodMatr% AND
							( (%Exp:DtoS( dData )% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM) OR
							  (%Exp:DtoS( dDataFim )% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM) OR
							  (SR8.R8_DATAINI >= %Exp:Dtos( dData )% AND  SR8.R8_DATAFIM <= %Exp:Dtos( dDataFim )% )  OR
							  (SR8.R8_DATAINI <= %Exp:Dtos( dDataFim )% AND SR8.R8_DATAFIM = %Exp:' '% )  OR
							  (SR8.R8_DATAINI <= %Exp:Dtos( dData )% AND SR8.R8_DATAFIM = %Exp:' '% ) ) AND
							SR8.%notDel%
				EndSQL

				If !(cAliasQry)->( Eof() )
					cSituacao := AllTrim(Tabela("31",PadR('A',Len(SRA->RA_SITFOLH)),.F.))
				EndIf

				//--Fecha a area
				(cAliasQry)->( DbCloseArea() )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³EXIBE HELP DE INCONSISTENCIA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( cSituacao )
				Help( '', 1, 'TMSXFUNC07',, SRA->RA_SITFOLH + ' - ' + cSituacao, 3, 0  )
				lRet := .F.
			EndIf
		Else
			Help( '', 1, 'REGNOIS',, AllTrim( RetTitle('RA_MAT') )+': '+ cCodMatr, 3, 0 )
			lRet := .F.
		EndIf
	Else
		//--Caso nao seja informada a filial base do motorista,
		//--faz uma busca considerando apenas a matricula do funcionario.
		//--Se encontrar mais de uma ocorrencia (Funcionarios em filiais distintas, porem
		//--com o mesmo numero de matricula), exibe uma tela para o usuario indicar qual
		//--funcionario esta relacionado aquele motorista
		SRA->( DbsetOrder(13) ) //--RA_MAT+RA_FILIAL
		If SRA->( MsSeek( cCodMatr ) )
			//--Obtem os funcionarios com o numero da
			//--matricula em questao
			While !SRA->( Eof() ) .And. SRA->RA_MAT == cCodMatr
				AAdd( aMatr, {	SRA->RA_FILIAL,;
								SRA->RA_MAT,;
								SRA->RA_NOME,;
								SRA->RA_CODFUNC,;
								Posicione( 'SRJ', 1, xFilial('SRJ') + SRA->RA_CODFUNC, 'RJ_DESC' ) } )

				SRA->( DbSkip() )
			End

			//--A partir dos campos protegidos verifica quais o usuÃ¡rio possui acesso
			If llGPD .And. FindFunction('TMLGPDCpPr')
				aCpoAccNew := TMLGPDCpPr(aCpoAccess,'SRA') //--Campos protegidos e que são apresentados na rotina.
				aUsrAcsPFl := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCpoAccNew ) //--Campos protegidos usados na rotina e que o usuário possue acesso

				//--Monta Array com as colunas que nÃ£o serÃ£o exibidas devido ao acesso do usuÃ¡rio
				If Len(aCpoAccNew) > 0
					For nCountCpo := 1 To Len(aCpoAccess)
						If Ascan( aCpoAccNew, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
							AADD(aColOfusca,.F.)
						Else
							If Ascan( aUsrAcsPFl, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
								AADD(aColOfusca,.T.)
							Else
								AADD(aColOfusca,.F.)
							EndIf
						EndIf	
					Next nCountCpo
				EndIf	
			EndIf	
			If Len( aMatr ) > 1
				AAdd( aTitle, RetTitle( 'RA_FILIAL' ) )
				AAdd( aTitle, RetTitle( 'RA_MAT' ) )
				AAdd( aTitle, RetTitle( 'RA_NOME' ) )
				AAdd( aTitle, RetTitle( 'RA_CODFUNC' ) )
				AAdd( aTitle, RetTitle( 'RA_DESCFUN' ) )
				nSelec := TmsF3Array( aTitle, aMatr, STR0087, .F.,,,aColOfusca )									  
				If nSelec == 0
					Help( '', 1, 'TMSXFUNC13' )
					lRet := .F.
				Else
					//--Chama a funcao de forma recursiva, porem neste momento
					//--possuimos a informacao sobre qual filial o motorista
					//--eh funcionario
					lRet := TMSVldFunc( aMatr[nSelec,2], aMatr[nSelec,1], dData, dDataFim )
				EndIf
			Else
				//--Existe somente um funcionario no SRA para
				//--a matricula amarrada ao motorista

				//--Chama a funcao de forma recursiva, porem neste momento
				//--possuimos a informacao sobre qual filial o motorista
				//--eh funcionario
				lRet := TMSVldFunc( aMatr[1,2], aMatr[1,1], dData, dDataFim )
			EndIf
        Else
			Help( '', 1, 'REGNOIS',, AllTrim( RetTitle('RA_MAT') )+': '+ cCodMatr, 3, 0 )
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea( aArea )
RestArea( aAreaSRA )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAtualOp³ Autor ³ Vitor Raspa                               ³ Data ³ 28.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza dados da Operadora (Motorista, Veiculo e Fornec.)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAtualOp(cExpC1,ExpC2,ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Operadora de Frotas/Vale-Pedagio                             ³±±
±±³          ³                                                                                ³±±
±±³          ³ ExpC2 - Tipo da Atualizacao:                                                   ³±±
±±³          ³         1-Fornecedores/2-Motoristas/3-Veiculos/4-Carretas/5-Todos              ³±±
±±³          ³                                                                                ³±±
±±³          ³ ExpA1 - Array Com os Codigos Correspondentes:                                  ³±±
±±³          ³         ExpA2[1] - Codigo/Loja do Fornecedor                                   ³±±
±±³          ³         ExpA2[2] - Codigo do Motorista                                         ³±±
±±³          ³         ExpA2[3] - Codigo do Veiculo                                           ³±±
±±³          ³         ExpA2[4] - Codigo da Carreta                                           ³±±
±±³          ³ ExpL1 - .T. para exibir a mensagem de OK quanto a atualizacao dos dados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAtualOp( cCodOpe, cTpAtualiz, aCodigos, lMsgOk, cCGCMot )

Local lRet       := .T.
Local aArea      := GetArea()
Local aMsgErr    := {}
Local cCodMot	 := ""
Local cCodVei	 := ""

Default lMsgOk   := .F.
Default cCGCMot	 := ""

If cCodOpe == '01' //-- REPOM TECNOLOGIA
	lRet := RepAtualOp( cCodOpe, cTpAtualiz, aCodigos, lMsgOk, aMsgErr )
ElseIf cCodOpe == '03' .AND. FindFunction("TMSIntgPB") //-- PAGBEM
	If FwIsInCallStack("OMSA040")
		cCodMot := aCodigos[1,2]
		lRet := TMSIntgPB( cCodMot, AllTrim(cCGCMot) )
	ElseIf FwIsInCallStack("OMSA060")
		
		If !Empty(aCodigos[ 1, 3 ])
			cCodVei := aCodigos[ 1, 3 ]
		Else
			cCodVei := aCodigos[ 1, 4 ]
		EndIf

		lRet := TMSIntgPB( , , cCodVei )
	ElseIf FwIsInCallStack("MATA020")
		
		If !Empty( aCodigos[ 1, 1 ])
			cCodForLoj := aCodigos[ 1, 1 ]
		EndIf

		lRet := TMSIntgPB( , , , cCodForLoj )
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSErrOper³ Autor ³ Vitor Raspa           ³ Data ³ 08.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata Mensagens de Erro Retornadas pelas Operadoras de     ³±±
±±³          ³ Frota/Vale-Pedagio                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSErrOper()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Operadora de Frotas/Vale-Pedagio         ³±±
±±³          ³ ExpC2 = XML com o Erro                                     ³±±
±±³          ³ ExpC3 = Tipo de Erro:                                      ³±±
±±³          ³         1- Retorno do WS Falso                             ³±±
±±³          ³         2- Falha na conexao com o WS                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com os Erros                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSErrOper(cCodOpe, cXMLErr, cTipoErro)

Local cError   := ''
Local cWarning := ''
Local aErros   := {}
Local oObjXML
Local nXMLStatus
Local nAux
Local cSvcError   := ''
Local cSoapFCode  := ''
Local cSoapFDescr := ''
Local lTMSXML     := GetMV( 'MV_TMSXML',, .F. )
Local lTMS250SCH  := TMS250SCHE()	//--> Verifica se a execução é via SCHEDULE da rotina TMSA250.
Local cTXTLG250   := ""

Default cXMLErr := ''

If cTipoErro == '1'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorno do WS igual a Falso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXMLErr := TMSNoAcento( cXMLErr ) //-- Remove os Acentos do XML de Erro

	//-- Gera XM em disco
	If lTMSXML
		TMSLogXML( cXMLErr, 'ErroIntegracao.XML' )
	EndIf

	oObjXML := XMLParser( cXMLErr, '_', @cError, @cWarning )
	nXMLStatus := XMLError()
	If nXMLStatus <> XERROR_SUCCESS
		If !lTMS250SCH
			AAdd( aErros, {STR0062,'',''} ) //"Nao foi possivel ler a mensagem enviada pela operadora, entre em contato com o adminstrador de sistema"
			AAdd( aErros, {IIF(!Empty(cError), cError, cWarning),'',''} ) //Mensagem da funcao XMLParser
		Else
			cTXTLG250 += STR0040 + " " + STR0062 + CHR(13) + CHR(10)
			cTXTLG250 += STR0040 + " " + IIF(!Empty(cError), cError, cWarning)
		EndIf
	Else
		If !lTMS250SCH
			AAdd( aErros, {STR0061 + ': ','',''} ) //"Ocorreram erros na validacao do processo pela Operadora de Frotas"
		Else
			cTXTLG250 += STR0040 + " "+STR0061 + CHR(13) + CHR(10)
		EndIf

		If !('<ERROS>' $ Upper( cXMLErr))
			If !lTMS250SCH
				AAdd( aErros, {STR0110,'',''} ) //"Nao foi possivel ler a mensagem de erro enviada pela Operadora de Frotas, pois o formato da mensagem e invalido. Favor entrar em contato com a Operadora de Frotas e relatar o problema. "
			Else
				cTXTLG250 += STR0040 + " " + STR0110
			EndIf
		Else
			If ValType(oObjXML:_ERROS:_ERRO) == 'A'
				For nAux := 1 To Len(oObjXML:_ERROS:_ERRO)
					AAdd( aErros, {oObjXML:_ERROS:_ERRO[nAux]:_ERRO_DESCRICAO:Text + ' - (' + oObjXML:_ERROS:_ERRO[nAux]:_ERRO_CODIGO:Text + ')','','' } )
				Next
			Else
				AAdd( aErros, {oObjXML:_ERROS:_ERRO:_ERRO_DESCRICAO:Text + ' - (' + oObjXML:_ERROS:_ERRO:_ERRO_CODIGO:Text + ')','','' } )
			EndIf
		EndIf
	EndIf
Elseif cTipoErro == "3" // Utiliza Erros de procedimento interno e nao de conexao ou procedimentos da Repom
	AAdd( aErros, {cXMLErr,'',''} ) //Msg definido pelo Usuario
Elseif cTipoErro == "4" // Erros Repom 2.2

	If ValType(cXMLErr) == 'A'
		For nAux := 1 To Len(cXMLErr)
			AAdd( aErros, {cXMLErr[nAux],'','' } )
		Next
	Else
		AAdd( aErros, {cXMLErr,'',''} ) 
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³NAO FOI POSSIVEL EXECUTAR O METODO!³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTMS250SCH
		AAdd( aErros, {STR0042,'',''} ) //"Nao foi possivel estabelecer comunicacao com a Operadora de Frotas, entre em contato com o Administrador de Sistema e informe o codigo a seguir"
	Else
		cTXTLG250 += STR0040 + " " + STR0042
	EndIf
	cSvcError   := GetWSCError()		// Resumo do erro
	cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	If !Empty(cSoapFCode)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a ocorrência de erro esteja com o fault_code preenchido,³
		//³ a mesma teve relação com a chamada do serviço .              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aErros, {cSoapFDescr + ' (' + cSoapFCode + ')','',''} )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso a ocorrência não tenha o soap_code preenchido    ³
		//³Ela está relacionada a uma outra falha ,              ³
		//³provavelmente local ou interna.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aErros, {cSvcError,'',''} )
	Endif
EndIf

If ! Empty(aErros)
	Help(' ', 1, 'TMSXFUNC18') // "Ocorreram erros ou validações do processo pela Operadora de Frotas e o processo não foi realizado com sucesso."
EndIf

//--> Caso seja execução via SCHEDULE da rotina TMSA250,  grava as mensagens em LOG de processamento.
If lTMS250SCH .And. ! Empty(cTXTLG250)
	AADMsgTMS250(cTXTLG250,'',"TMSA250")
EndIf

Return( aErros )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGerLog ³ Autor ³ Vitor Raspa           ³ Data ³ 14.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera LOG de transacoes das Operacoes realziadas com as     ³±±
±±³          ³ Operadoras de Frota/Vale-Pedagio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSGerLog()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Operadora de Frotas/Vale-Pedagio         ³±±
±±³          ³ ExpC2 = Tipo do Log:                                       ³±±
±±³          ³         MT - Cadastro de Motoristas                        ³±±
±±³          ³         VE - Cadastro de Veiculos                          ³±±
±±³          ³         FR - Cadastro de Fornecedores                      ³±±
±±³          ³         CC - Contrato de Carreteiro                        ³±±
±±³          ³         QT - Quitacao de Contrato                          ³±±
±±³          ³         CV - Abertura de Controle de Viagem                ³±±
±±³          ³         BX - Baixa de Contr. de Viagem                     ³±±
±±³          ³         AV - Aviso de Pagto. de Postos                     ³±±
±±³          ³         PP - Passagem em Postos                            ³±±
±±³          ³         MV - Movimentacao de Valores                       ³±±
±±³          ³         AC - Aviso de Pagto. de Carreteiro                 ³±±
±±³          ³                                                            ³±±
±±³          ³ ExpC3 = Log de 'E'nvio ou 'R'ecebimento                    ³±±
±±³          ³ ExpC4 = Chave do Registro (Identificador do Registro)      ³±±
±±³          ³ ExpC5 = Origem do Registro                                 ³±±
±±³          ³ ExpC6 = Tipo da Operacao                                   ³±±
±±³          ³         0-Inclusao                                         ³±±
±±³          ³         1-Exclusao                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSGerLog( cCodOpe, cTipLog, cRecEnv, cIdReg, cOrigem, cTpOper )
RecLock('DEO', .T.)
DEO->DEO_FILIAL := xFilial('DEO')
DEO->DEO_CODOPE := cCodOpe
DEO->DEO_TIPLOG := cTipLog
DEO->DEO_RECENV := cRecEnv
DEO->DEO_IDREG  := cIdReg
DEO->DEO_DTLOG  := dDataBase
DEO->DEO_HRLOG  := PadL(AllTrim(StrTran(Left(Time(),5), ':','')),4,'0')
DEO->DEO_ORIGEM := cOrigem
DEO->DEO_TPOPER := cTpOper
MsUnLock()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPassag ³ Autor ³ Vitor Raspa           ³ Data ³ 13.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza as Passagens em Postos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSPassag(cExpC1, cExpC2, cExpC3, aExpA1)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 = Codigo da Operadora de Frotas                     ³±±
±±³          ³ cExpC2 = Filial de Origem                                  ³±±
±±³          ³ cExpC3 = Numero da Viagem                                  ³±±
±±³          ³ aExpA1 = Array com os dados da Passagem:                   ³±±
±±³          ³          [01] - N.o do Processo de Transporte (Operadora)  ³±±
±±³          ³          [02] - Dt. de Previsao da Passagem                ³±±
±±³          ³          [03] - Hr. de Previsao da Passagem                ³±±
±±³          ³          [04] - Dados do Fornecedor (Posto)                ³±±
±±³          ³          [04][01] - CNPJ do Posto                          ³±±
±±³          ³          [04][02] - Razao Social do Posto                  ³±±
±±³          ³          [04][03] - Endereco                               ³±±
±±³          ³          [04][04] - Cidade                                 ³±±
±±³          ³          [04][05] - Estado                                 ³±±
±±³          ³          [04][06] - Telefone                               ³±±
±±³          ³          [05] - Valor do Diesel (R$)                       ³±±
±±³          ³          [06] - Dt. Real da Passagem                       ³±±
±±³          ³          [07] - Hr. Real da Passagem                       ³±±
±±³          ³          [08] - Valor do Consumo                           ³±±
±±³          ³          [09] - Valor do Saque                             ³±±
±±³          ³          [10] - Dt. Prev. Pagto. do valor do Consumo       ³±±
±±³          ³          [11] - Dt. Prev. Pagto. do valor de Saque         ³±±
±±³          ³          [12] - Numero do Documento da Passagem            ³±±
±±³          ³          [13] - Indice do Lancamento (Ordem da Passag.)    ³±±
±±³          ³          [14] - Operacao: 0=Baixa da Passagem              ³±±
±±³          ³                           1=Estorno da Baixa               ³±±
±±³          ³                           2=Nova Passagem em Aberto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSPassag( cCodOpe, cFilOri, cViagem, aPassagens)

Local aArea      := GetArea()
Local aAreaDTW   := DTW->(GetArea())
Local aAreaDEP   := DEP->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local lRet       := .F.
Local cAtivSai   := GetMv( 'MV_ATIVSAI',, '' )
Local cAtivChg   := GetMv( 'MV_ATIVCHG',, '' )
Local cAtivPsg   := GetMv( 'MV_ATIVPSG',, '' )
Local cQuery     := ''
Local cAliasQry  := ''
Local nAux       := 0
Local aDadosForn := {}
Local cOrdem     := ''
Local cSequen    := ''
Local cServic    := ''
Local cTarefa    := ''
Local cSerTMS    := ''
Local cTipTra    := ''
Local cPosto     := ''
Local lNewPassag := .T.
Local aDadDTW    := {}
Local lGravaDTW  := .F.
Local cCodVei    := ''
Local cCodFor    := ''
Local cLojFor    := ''
Local cSeek      := ''
Local lGravaDg   := .T.
Local lRepom     := SuperGetMV( 'MV_VSREPOM',, '1' ) $ '2|2.2'
Local cDesAbast  := SuperGetMV( 'MV_ABAST',, '' )
Local cDesSaq    := SuperGetMV( 'MV_DESSAQ',, '' )
Local cDesAdf    := SuperGetMV( 'MV_DESADF',, '' )

DTY->(DbSetOrder(2))	 //-- Se os docto foram entregues na filial, apenas finaliza a viagem e gera o titulo
If  DTY->(MsSeek(xFilial("DTY")+cFilOri+cViagem)) .And. lRepom
	cCodVei  := DTY->DTY_CODVEI
	cCodFor  := DTY->DTY_CODFOR
	cLojFor  := DTY->DTY_LOJFOR
EndIf

If cCodOpe == '01' .And. AllTrim(SuperGetMv('MV_ENREPOM',,'1')) $ '1;2' //-- REPOM Tecnologia
	DEG->(DbSetOrder(1))
	If DEG->(MsSeek(xFilial('DEG') + cCodOpe))

		For nAux := 1 To Len(aPassagens)
			lGravaDg   := .T. //-- Reseta a variavel que permite gravacao de SDG
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VERIFICA SE EXISTE O POSTO CADASTRADO COMO FORNECEDOR³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA2->(DbSetOrder(3)) //-- A2_FILIAL+A2_CGC
			If !SA2->(MsSeek(xFilial('SA2') + AllTrim(aPassagens[nAux,4,1])))
				aDadosForn := {	{'A2_NOME'	, aPassagens[nAux,4,2]},;
								{'A2_NREDUZ', Left(aPassagens[nAux,4,2],TamSX3("A2_NREDUZ")[1])},;
								{'A2_END'	, aPassagens[nAux,4,3]},;
								{'A2_MUN'	, aPassagens[nAux,4,4]},;
								{'A2_EST'	, aPassagens[nAux,4,5]},;
								{'A2_CGC'	, aPassagens[nAux,4,1]},;
								{'A2_TEL'	, aPassagens[nAux,4,6]},;
								{'A2_TIPO'	, IF(Len(AllTrim(aPassagens[nAux,4,1])) == 14, 'J', 'F') }}
				//-- Realiza a Inclusao do Fornecedor
				TMSA370Frn(,,,aDadosForn)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ATUALIZA OS DADOS DA PASSAGEM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aPassagens[nAux,14] == '0' //-- Baixa da Passagem
				If aPassagens[nAux,13] == '00' //-- Passagem nao Prevista, nao possui Indice de Lancto.
					lNewPassag := .T.
					cQuery := ""
					cQuery += "SELECT Max(DEP.DEP_ORDEM) NumPass "
					cQuery += "FROM " + RetSqlName("DEP") + " DEP "
					cQuery += "WHERE "
					cQuery += "DEP.DEP_FILIAL = '" + xFilial("DEP") + "' AND "
					cQuery += "DEP.DEP_FILORI = '" + cFilOri + "' AND "
					cQuery += "DEP.DEP_VIAGEM = '" + cViagem + "' AND "
					cQuery += "DEP.DEP_STATUS = '2' AND "
					cQuery += "DEP.D_E_L_E_T_ = ''"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
					If (cAliasQry)->(EoF()) //-- Nao Existe nenhuma passagem Efetivada!
						cOrdem := '001'
					Else
						cOrdem := StrZero(Val((cAliasQry)->NumPass) + 1, 3)
					EndIf
					(cAliasQry)->(DbCloseArea())
				Else
					cOrdem := StrZero(Val(aPassagens[nAux,13])*10,3)
					lNewPassag := .F.
				EndIf

				DEP->(DbSetOrder(1)) //-- DEP_FILIAL+DEP_FILORI+DEP_VIAGEM+DEP_ORDEM
				If DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem + cOrdem))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³GERA A OPERACAO DE TRANSPORTE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := ""
					cQuery += "SELECT DTW.DTW_FILORI, DTW.DTW_VIAGEM, DTW.DTW_SEQUEN, DTW.DTW_TIPOPE, "
					cQuery += "DTW.DTW_SERVIC, DTW.DTW_TAREFA, DTW.DTW_ATIVID, DTW.DTW_SERTMS, DTW.DTW_TIPTRA, "
					cQuery += "DTW.DTW_STATUS, DTW.DTW_CATOPE "
					cQuery += "FROM " + RetSqlName("DTW") + " DTW "
					cQuery += "WHERE "
					cQuery += "DTW.DTW_FILIAL = '" + xFilial("DTW") + "' AND "
					cQuery += "DTW.DTW_FILORI = '" + cFilOri + "' AND "
					cQuery += "DTW.DTW_VIAGEM = '" + cViagem + "' AND "
					cQuery += "(DTW.DTW_ATIVID = '" + cAtivSai + "' OR DTW.DTW_ATIVID = '" + cAtivChg + "') AND "
					cQuery += "DTW.D_E_L_E_T_ = ''"
					cQuery += "ORDER BY DTW.DTW_SEQUEN
					cAliasQry := GetNextAlias()
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
					While !(cAliasQry)->(EoF())
						lGravaDTW:=.T.
						cSequen := (cAliasQry)->DTW_SEQUEN
						If (cAliasQry)->DTW_ATIVID == cAtivSai
							(cAliasQry)->(DbSkip())
						Else
							If (cAliasQry)->DTW_STATUS == '1' //-- Em Aberto
								cSequen := StrZero((Val(cSequen) - 30), Len(DTW->DTW_SEQUEN))
								Exit
							Else
								(cAliasQry)->(DbSkip())
							EndIf
						EndIf
					EndDo
					(cAliasQry)->(DbCloseArea())

					If lGravaDTW
						DTW->(dbSetOrder(1))
						While DTW->(MsSeek(xFilial('DTW') + cFilOri + cViagem + cSequen ))
							cSequen := Soma1(cSequen)
							cServic := DTW->DTW_SERVIC
							cTarefa := DTW->DTW_TAREFA
							cSerTMS := DTW->DTW_SERTMS
							cTipTra := DTW->DTW_TIPTRA
							DTW->(dbSkip())
						EndDo
						cPosto := Posicione('SA2',3,xFilial('SA2') + AllTrim(aPassagens[nAux,4,1]),'A2_NOME')
						Aadd( aDadDTW, { 'DTW_FILORI'	, DEP->DEP_FILORI									, Nil } )
						Aadd( aDadDTW, { 'DTW_VIAGEM'	, DEP->DEP_VIAGEM									, Nil } )
						Aadd( aDadDTW, { 'DTW_SEQUEN'	, cSequen											, Nil } )
						Aadd( aDadDTW, { 'DTW_DATPRE'	, DEP->DEP_DTPREV									, Nil } )
						Aadd( aDadDTW, { 'DTW_HORPRE'	, DEP->DEP_HRPREV									, Nil } )
						Aadd( aDadDTW, { 'DTW_DATINI'	, CtoD(aPassagens[nAux][11])						, Nil } )
						Aadd( aDadDTW, { 'DTW_HORINI'	, PadL(StrTran(aPassagens[nAux][12],':',''),4,'0')	, Nil } )
						Aadd( aDadDTW, { 'DTW_DATREA'	, CtoD(aPassagens[nAux][12])						, Nil } )
						Aadd( aDadDTW, { 'DTW_HORREA'	, PadL(StrTran(aPassagens[nAux][12],':',''),4,'0')	, Nil } )
						Aadd( aDadDTW, { 'DTW_SERVIC'	, cServic 											, Nil } )
						Aadd( aDadDTW, { 'DTW_TAREFA'	, cTarefa											, Nil } )
						Aadd( aDadDTW, { 'DTW_ATIVID'	, cAtivPsg											, Nil } )
						Aadd( aDadDTW, { 'DTW_FILATI'	, cFilAnt											, Nil } )
						Aadd( aDadDTW, { 'DTW_FILATU'	, cFilAnt											, Nil } )
						Aadd( aDadDTW, { 'DTW_SERTMS'	, cSerTMS											, Nil } )
						Aadd( aDadDTW, { 'DTW_TIPTRA'	, cTipTra											, Nil } )
						Aadd( aDadDTW, { 'DTW_STATUS'	, StrZero(2,Len(DTW->DTW_STATUS))					, Nil } ) // Aberto
						Aadd( aDadDTW, { 'DTW_TIPOPE'	, StrZero(2,Len(DTW->DTW_STATUS))					, Nil } ) // Tipo de Operacao == "Transporte"
						Aadd( aDadDTW, { 'DTW_CATOPE'	, StrZero(2,Len(DTW->DTW_STATUS))					, Nil } ) // Categoria da operacao 2=Eventual
						Aadd( aDadDTW, { 'DTW_OBSERV'	, 'Posto: ' + cPosto								, Nil } )
						lRet := TMSCriaDTW( aDadDTW )
					EndIf
				Else
					If !lNewPassag
						lNewPassag  := .T.
					EndIF
				EndIf

			ElseIf aPassagens[nAux,14] == '1' //-- Estorno da Baixa
				lRet := .T.
				cOrdem := StrZero(Val(aPassagens[nAux,13])*10,3)
				DEP->(DbSetOrder(1)) //-- DEP_FILIAL+DEP_FILORI+DEP_VIAGEM+DEP_ORDEM
				If DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem + cOrdem))
					RecLock('DEP',.F.)
					DEP->DEP_DTREAL := CtoD(Space(08))
					DEP->DEP_HRREAL := ''
					DEP->DEP_VALCON := 0
					DEP->DEP_VALSAQ := 0
					DEP->DEP_PRVCON := CtoD(Space(08))
					DEP->DEP_PRVSAQ := CtoD(Space(08))
					DEP->DEP_DOCPAS := ''
					DEP->DEP_STATUS := '1' //- Em Aberto
					MsUnLock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³CANCELA A OPERACAO DE TRANSPORTE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DTW->(DbSetOrder(1))
					If DTW->(MsSeek(xFilial('DTW') + cFilOri + cViagem + DEP->DEP_SEQDTW ))
						RecLock('DTW',.F.)
						DTW->DTW_STATUS := '9'
						MsUnLock()
					EndIf
				EndIf
			EndIf

			If aPassagens[nAux,14] <> '1'
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³GRAVACAO DOS SGD DA PASSAGEM        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAreaDEP := DEP->(GetArea())
				DEP-> (DbSetOrder(1))
				DEP-> (MsSeek(cSeek := xFilial('DEP') + cFilOri + cViagem + cOrdem))
				While DEP->(!Eof()) .And. DEP->(DEP_FILIAL+DEP_FILORI+DEP_VIAGEM+DEP_ORDEM) == cSeek
					If AllTrim(DEP->DEP_DOCPAS) == AllTrim(aPassagens[nAux,12])  //DOCPAS = codigo chave unica no XML de passagem de postos
						lGravaDg := .F.                      					  //Caso ja exista, significa que XML esta duplicado
						EXIT                                  					 // Nao grava SDG nessa situacao
					EndIF
					DEP->(dbSkip())
				Enddo
				RestArea(aAreaDEP)

				If lGravaDg .And. lRepom
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³GRAVACAO DAS INFORMACOES DA PASSAGEM³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock('DEP', lNewPassag)
				DEP->DEP_FILIAL := 	xFilial('DEP')
				DEP->DEP_ORDEM  := If(!Empty(cOrdem), cOrdem, StrZero(Val(aPassagens[nAux,13])*10,3))
				DEP->DEP_FILORI := cFilOri
				DEP->DEP_VIAGEM := cViagem
				DEP->DEP_CODOPE := cCodOpe
				DEP->DEP_CODFOR := cCodFor
				DEP->DEP_LOJFOR := cLojFor
				If Val(aPassagens[nAux,5]) <> 0
					DEP->DEP_VALCOM := Val(aPassagens[nAux,5])
				EndIf
				If aPassagens[nAux,14] <> '0'
					DEP->DEP_DTPREV := CtoD(aPassagens[nAux][2])
					DEP->DEP_HRPREV := PadL(StrTran(aPassagens[nAux][3],':',''),4,'0')
					DEP->DEP_STATUS := '1' //-- Passagem em Aberto
				ElseIf aPassagens[nAux,14] == '0'
					DEP->DEP_DTREAL := CtoD(aPassagens[nAux,6])
					DEP->DEP_HRREAL := PadL(StrTran(aPassagens[nAux,7],':',''),4,'0')
					DEP->DEP_VALCON := Val(aPassagens[nAux,8])
					DEP->DEP_VALSAQ := Val(aPassagens[nAux,9])
					DEP->DEP_PRVCON := CtoD(aPassagens[nAux,10])
					DEP->DEP_PRVSAQ := CtoD(aPassagens[nAux,11])
					DEP->DEP_DOCPAS := aPassagens[nAux,12]
					DEP->DEP_STATUS := '2' //-- Passagem Realizada
					DEP->DEP_SEQDTW := cSequen
				EndIf
				MsUnLock()
					If !Empty(cDesAdf)
						cQuery :=  ""
						cQuery += "SELECT DG_FILIAL, DG_FILORI, DG_VIAGEM, DG_CODVEI, DG_CODDES, DG_IDENT, DG_NUMSEQ  "
						cQuery += " FROM " + RetSqlName("SDG")
						cQuery += " WHERE DG_FILIAL = '" + xFilial('SDG') + "'"
						cQuery += " AND DG_FILORI = '"   + cFilOri + "'"
						cQuery += " AND DG_VIAGEM = '"   + cViagem + "'"
						cQuery += " AND DG_CODVEI = '"   + cCodVei + "'"
						cQuery += " AND DG_CODDES = '"   + cDesAdf + "'"
						cQuery += " AND D_E_L_E_T_ = ' '  "
						cAliasQry := GetNextAlias()
						cQuery := ChangeQuery(cQuery)
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
						While !(cAliasQry)->(EoF())
							If !Empty(cDesAbast) .And. Val(aPassagens[nAux,8]) > 0
								TMSA070Bx("1",(cAliasQry)->DG_NUMSEQ,cFilOri,cViagem,cCodVei,,,Val(aPassagens[nAux,8]),,(cAliasQry)->DG_IDENT,cDesAbast)
							EndIf
							If !Empty(cDesSaq) .And. Val(aPassagens[nAux,9]) > 0
								TMSA070Bx("1",(cAliasQry)->DG_NUMSEQ,cFilOri,cViagem,cCodVei,,,Val(aPassagens[nAux,9]),,(cAliasQry)->DG_IDENT,cDesSaq)
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
						(cAliasQry)->(DbCloseArea())
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GERA LOG DA MOVIMENTACAO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TMSGerLog( 	'01',;	//-- Codigo da Operadora
			'PP',;	//-- Tipo do Log
			'R',;	//-- Log de 'E'nvio ou 'R'ecebimento
			xFilial('DEP')+cFilOri+cViagem+If(!Empty(cOrdem), cOrdem, StrZero(Val(aPassagens[nAux,13])*10,3)),;	//-- Chave do Registro (Identificador do Registro)
			'DEP',;	//-- Origem do Registro
			'0' )	//-- 0-Inclusao, 1-Exclusao
		Next
	EndIf
EndIf
RestArea(aArea)
RestArea(aAreaDTW)
RestArea(aAreaSA2)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSMovVal ³ Autor ³ Vitor Raspa           ³ Data ³ 15.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata a Movimentacao de Valores retornada pela Operadora   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSMovVal()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Operadora                                ³±±
±±³          ³ ExpC2 = Filial de Origem                                   ³±±
±±³          ³ ExpC3 = Numero da Viagem                                   ³±±
±±³          ³ ExpA4 = Array com os Movimentos                            ³±±
±±³          ³      [01] - Processo de Transporte                         ³±±
±±³          ³      [02] - Numero do Proc. Transp. (Operadora)            ³±±
±±³          ³      [03] - Codigo do Movimento                            ³±±
±±³          ³      [04] - Valor do Movimento                             ³±±
±±³          ³      [05] - Tipo do Movimento (Debito/Credito/Pedagio)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSMovVal( cCodOpe, cFilOri, cViagem, aMovtos, nOpcx, cCodVei )
Local lRet := .T.

If cCodOpe == "01"
	//-- Bloco de código movido para TMSRepom.prw
	lRet := RepMovVal( @cCodOpe, @cFilOri, @cViagem, @aMovtos, @nOpcx, @cCodVei )
EndIf
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSIncMov ³ Autor ³ Vitor Raspa           ³ Data ³ 18.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui novo movimento na Operacao da Viagem                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIncMov()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os Movimentos                            ³±±
±±³          ³         [01] - Id do Registro                              ³±±
±±³          ³         [02] - Codigo do Movimento                         ³±±
±±³          ³         [03] - Valor do Movimento                          ³±±
±±³          ³         [04] - Acao Executada para Historico               ³±±
±±³          ³         [05] - Tipo do Movto. (0-Inclusao / 1-Exclusao)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSIncMov( cCodOpe, cFilOri, cViagem, aMovtos)
Local aArea    := GetArea()
Local aAreaDTR := DTR->(GetArea())
Local aAreaDEG := DEG->(GetArea())
Local lRet     := .T.
Local aMsgErr  := {}
Local aVisErr  := {}
Local cXML     := ''
Local nAux     := 0
Local oObj     := NIL
Local lTMSXML  := GetMV( 'MV_TMSXML',, .F. )
Local oRepom   := Nil
Local cCodMov	:= ""
SetVarNameLen(255)
If cCodOpe == '01' //-- REPOM Tecnologia
	DEG->(DbSetOrder(1))
	If DEG->(MsSeek(xFilial('DEG')+cCodOpe))
		For nAux := 1 To Len(aMovtos)
			DTR->(DbSetOrder(1))
			If DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem)) 
				If lRestRepom
					cCodMov:= AllTrim(aMovtos[nAux,2])
					
					If aMovtos[nAux,5] == '1'    //Estorno, deve incluir o 'e' apos o Codigo ("Identifier": "10e")
						cCodMov:= cCodMov + "e"
					EndIf

					If !Empty(cCodMov)
						oRepom := TMSBCARepomFrete():New()
						If oRepom:Auth()
							lRet:= oRepom:ShippingMovAdd(DTR->DTR_FILORI,DTR->DTR_VIAGEM,DTR->DTR_CODVEI,cCodMov,AllTrim(Str(aMovtos[nAux,3],10,2)))
						EndIf
						oRepom:Destroy()
						FwFreeObj(oRepom)
					EndIf		
								
				Else
					cXML := '<movimento>'
					cXML += 	'<cliente_codigo>' + AllTrim(DEG->DEG_IDOPE) + '</cliente_codigo>'
					cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
					cXML += 	'<movimento_codigo>' + AllTrim(aMovtos[nAux,2]) + '</movimento_codigo>'
					cXML += 	'<movimento_cliente_codigo></movimento_cliente_codigo>'
					cXML +=		'<valor>' + AllTrim(Str(aMovtos[nAux,3],10,2)) + '</valor>'
					cXML +=		'<tipo_operacao>' + aMovtos[nAux,5] + '</tipo_operacao>'
					cXML += '</movimento>'

					//-- Remove acentos e caracteres especiais
					cXML := TMSNoAcento( cXML )

					//-- Gera XML em disco
					If lTMSXML
						TMSLogXML( cXML, 'IncluiMovimento.XML' )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ACIONA O WEBSERVICE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oObj := WSIntegracao():New()
					oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
					oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
					oObj:cStrXMLIn             := cXML
					oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

					If oObj:IncluiMovimento()
						If oObj:lIncluiMovimentoResult
							//-- Atualiza o Log de Transacoes
							TMSGerLog(cCodOpe, 'MV', 'E', xFilial('DEN')+cFilOri+cViagem+DtoS(dDataBase)+PadL(StrTran(Left(Time(),5),':',''),4,'0'), 'DEN', '0' )

							lRet := .T.
							//-- Atualiza Movimentação - DEN (parte1)
						Else
							aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
							lRet := .F.
						EndIf
					Else
						aMsgErr := TMSErrOper(cCodOpe,, '2')
						lRet := .F.
					EndIf
				EndIf

				If lRet .And. Len(aMovtos) > 0
					//-- Atualiza Movimentação - DEN (parte1)
					If aMovtos[nAux,5] == '0' .Or. aMovtos[nAux,5] == '1' //-- 0-Inclusao ou 1-Exclusão
						TMSAtuDEN(cFilOri,cViagem,aMovtos,cCodOpe,nAux,aMovtos[nAux,5])
					EndIf
				EndIf
			EndIf
        Next
	EndIF
EndIf
SetVarNameLen(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Trata mensagens de Erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aMsgErr)
	AaddMsgErr( aMsgErr, aVisErr )
	TmsMsgErr( aVisErr )
EndIf

RestArea(aArea)
RestArea(aAreaDTR)
RestArea(aAreaDEG)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAvlBlqDoc ³ Autor ³ Vitor Raspa        ³ Data ³ 06.Set.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o | Atualiza os Status das tabelas vinculadas ao Controle de   ³±±
±±³          | Documentos (DD1 / DD2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAvlBlqDoc( cExpC1, cExpC2 )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExpA1 - Array com os Dados para Avaliacao dos Bloqueios:  ³±±
±±³          ³     aExpA1[1] - Cod. do Bloqueio                           ³±±
±±³          ³     aExpA1[2] - Cod. Fornecedor                            ³±±
±±³          ³     aExpA1[3] - Loja do Fornecedor                         ³±±
±±³          ³     aExpA1[4] - Cod. Motorista                             ³±±
±±³          ³     aExpA1[5] - Dt. Apresentacao Docto.                    ³±±
±±³          ³     aExpA1[6] - Dt. de Afastaemento (Prest. Servico)       ³±±
±±³          ³     aExpA1[7] - Dt. de Retorno (Prest. Servico)            ³±±
±±³          ³     aExpA1[8] - .T. para Bloqueio e .F. para Desbloqueio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAvlBlqDoc( aAvaliaBlq )
Local aArea       := GetArea()
Local aAreaDUC    := DUC->(GetArea())
Local nAux        := 0
Local cNewStat    := ''
Local cQuery      := ''
Local cAliasQry   := GetNextAlias()
Local lBlqDocto   := .F.
Local lBlqPeriod  := .F.

For nAux := 1 To Len( aAvaliaBlq )
	If 	((aAvaliaBlq[nAux,1] <> PadR('D4',Len(DUC->DUC_CODBLQ)) .And. dDataBase >= aAvaliaBlq[nAux,5]) .Or.;
		(aAvaliaBlq[nAux,1] == PadR('D4',Len(DUC->DUC_CODBLQ)) .And. (dDataBase >= aAvaliaBlq[nAux,6] .And. dDataBase <= aAvaliaBlq[nAux,7]))) .And.;
		aAvaliaBlq[nAux,8]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³BLOQUEIO               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	aAvaliaBlq[nAux,1] == PadR('D1',Len(DUC->DUC_CODBLQ)) .Or.;
			aAvaliaBlq[nAux,1] == PadR('D2',Len(DUC->DUC_CODBLQ)) .Or.;
			aAvaliaBlq[nAux,1] == PadR('D4',Len(DUC->DUC_CODBLQ))

			DD1->(DbSetOrder(1))
			If DD1->(MsSeek(xFilial('DD1') + aAvaliaBlq[nAux,2] + aAvaliaBlq[nAux,3]))
				If 	aAvaliaBlq[nAux,1] == PadR('D1',Len(DUC->DUC_CODBLQ)) .Or.;
					aAvaliaBlq[nAux,1] == PadR('D2',Len(DUC->DUC_CODBLQ))
					If DD1->DD1_STATUS == StrZero(1, Len(DD1->DD1_STATUS)) .Or. DD1->DD1_STATUS == StrZero(2,Len(DD1->DD1_STATUS))
						cNewStat := StrZero(2, Len(DD1->DD1_STATUS))
					ElseIf DD1->DD1_STATUS == StrZero(3, Len(DD1->DD1_STATUS)) .Or. DD1->DD1_STATUS == StrZero(4, Len(DD1->DD1_STATUS))
						cNewStat := StrZero(4, Len(DD1->DD1_STATUS))
					EndIf
				Else
					If DD1->DD1_STATUS == StrZero(1, Len(DD1->DD1_STATUS)) .Or. DD1->DD1_STATUS == StrZero(3, Len(DD1->DD1_STATUS))
						cNewStat := StrZero(3, Len(DD1->DD1_STATUS))
					ElseIf DD1->DD1_STATUS == StrZero(2, Len(DD1->DD1_STATUS)) .Or. DD1->DD1_STATUS == StrZero(4, Len(DD1->DD1_STATUS))
						cNewStat := StrZero(4, Len(DD1->DD1_STATUS))
					EndIf
				EndIf

				RecLock('DD1',.F.)
				DD1->DD1_STATUS := cNewStat
				MsUnLock()
			EndIf
		ElseIf aAvaliaBlq[nAux,1] == PadR('D3',Len(DUC->DUC_CODBLQ))
			DD2->(DbSetOrder(1))
			If DD2->(MsSeek(xFilial('DD2') + aAvaliaBlq[nAux,4]))
				RecLock('DD2',.F.)
				DD2->DD2_STATUS := StrZero(2, Len(DD1->DD1_STATUS))
				MsUnLock()
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³DESBLOQUEIO            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT DUC.DUC_CODBLQ, DUC.DUC_STATUS, DUC.DUC_CODFOR, DUC.DUC_LOJFOR, DUC.DUC_CODMOT "
		cQuery += "FROM " + RetSQLName('DUC') + " DUC "
		cQuery += "WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND "

		If 	aAvaliaBlq[nAux,1] == PadR('D1',Len(DUC->DUC_CODBLQ)) .Or.;
			aAvaliaBlq[nAux,1] == PadR('D2',Len(DUC->DUC_CODBLQ)) .Or.;
			aAvaliaBlq[nAux,1] == PadR('D4',Len(DUC->DUC_CODBLQ))
			cQuery += "DUC.DUC_CODFOR = '" + aAvaliaBlq[nAux,2] + "' AND "
			cQuery += "DUC.DUC_LOJFOR = '" + aAvaliaBlq[nAux,3] + "' AND "
			cQuery += "(DUC.DUC_CODBLQ = 'D1' OR DUC.DUC_CODBLQ = 'D2' OR DUC.DUC_CODBLQ = 'D4') AND "
		Else
			cQuery += "DUC.DUC_CODMOT = '" + aAvaliaBlq[nAux,4] + "' AND "
			cQuery += "DUC.DUC_CODBLQ = 'D3' AND "
		EndIf
		cQuery += "DUC.DUC_STATUS = '1' AND "
		cQuery += "DUC.D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasQry,.F.,.T.)

		If (cAliasQry)->(EoF())
			cNewStat := '1'
		Else
			If 	(cAliasQry)->DUC_CODBLQ == PadR('D1',Len(DUC->DUC_CODBLQ)) .Or.;
				(cAliasQry)->DUC_CODBLQ == PadR('D2',Len(DUC->DUC_CODBLQ)) .Or.;
				(cAliasQry)->DUC_CODBLQ == PadR('D4',Len(DUC->DUC_CODBLQ))
				While !(cAliasQry)->(EoF())
					If	(cAliasQry)->DUC_CODBLQ == PadR('D1',Len(DUC->DUC_CODBLQ)) .Or.;
						(cAliasQry)->DUC_CODBLQ == PadR('D2',Len(DUC->DUC_CODBLQ))
						lBlqDocto := .T.
					ElseIf (cAliasQry)->DUC_CODBLQ == PadR('D4',Len(DUC->DUC_CODBLQ))
						lBlqPeriod := .T.
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
				If lBlqDocto .And. lBlqPeriod
					cNewStat := StrZero(4, Len(DD1->DD1_STATUS))
				ElseIf lBlqDocto .And. !lBlqPeriod
					cNewStat := StrZero(2, Len(DD1->DD1_STATUS))
				ElseIf !lBlqDocto .And. lBlqPeriod
					cNewStat := StrZero(3, Len(DD1->DD1_STATUS))
				ElseIf !lBlqDocto .And. !lBlqPeriod
					cNewStat := StrZero(1, Len(DD1->DD1_STATUS))
				EndIf
			Else
				cNewStat := StrZero(2, Len(DD1->DD1_STATUS))
			EndIf
        EndIf
		If 	aAvaliaBlq[nAux,1] == PadR('D1',Len(DUC->DUC_CODBLQ)) .Or.;
			aAvaliaBlq[nAux,1] == PadR('D2',Len(DUC->DUC_CODBLQ)) .Or.;
			aAvaliaBlq[nAux,1] == PadR('D4',Len(DUC->DUC_CODBLQ))
			DD1->(DbSetOrder(1))
			If DD1->(MsSeek(xFilial('DD1') + aAvaliaBlq[nAux,2]+aAvaliaBlq[nAux,3]))
				RecLock('DD1',.F.)
				DD1->DD1_STATUS := cNewStat
				MsUnLock()
			EndIf
		ElseIf aAvaliaBlq[nAux,1] == PadR('D3',Len(DUC->DUC_CODBLQ))
			DD2->(DbSetOrder(1))
			If DD2->(MsSeek(xFilial('DD2') + aAvaliaBlq[nAux,4]))
				RecLock('DD2',.F.)
				DD2->DD2_STATUS := cNewStat
				MsUnLock()
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
Next

RestArea(aArea)
RestArea(aAreaDUC)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSLoad      ³ Autor ³ Vitor Raspa        ³ Data ³ 06.Set.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada das funcoes necessarias para inicializacao do      ³±±
±±³          ³ modulo SIGATMS                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSLoad()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSLoad()

Local aArea     := GetArea()
Local aAreaDD1  := {}
Local dUltVer   := CtoD(Space(08))
Local cQuery    := ''
Local cAliasQry := ''
Local cLockBy   := 'Docto.Terc'
Local dDtaRet   := CtoD(Space(08))
Local lAgdEntr     := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.

// Realiza a atualização do Status do Agendamento de Entrega "Não Atendido"
If FindFunction("A018AtStNA") .AND. lAgdEntr
	A018AtStNA()
EndIf
//--A validacao abaixo estava na antiga TMSEnable(), que ficava no TMSXFUNB, que era chamada
//--no x2_rotina da tabela DT6, agora a inicializacao do modulo ocorre na TMSLoad()
If !IntTms()
	Final(STR0063) //"Habilitar parametro MV_INTTMS !"
EndIf

If (FWModeAccess ("DTO",3)=="C")
	Final(STR0064) //"O Arq. DTO deve ser exclusivo !"
EndIf

If (FWModeAccess ("DTU",3)=="C")
	Final(STR0065) //"O Arq. DTU deve ser exclusivo !"
EndIf

dUltVer   := SuperGetMv("MV_TMSUVER",.F.,dDataBase)
If Date() > dUltVer
	If LockByName(cLockBy,.F.,.T.)
		cAliasQry := CriaTrab(NIL,.F.)
		If AliasInDic('DD1')
			aAreaDD1  := DD1->(GetArea())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SELECIONA OS FORNECEDOES QUE POSSUEM A DATA ³
			//³DE RETORNO IGUAL A DATA BASE DO SISTEMA     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT DD1.DD1_DTAAFA, DD1.DD1_DTARET, DD1.R_E_C_N_O_ DD1RecNo "
			cQuery += "FROM " + RetSQLName('DD1') + " DD1 "
			cQuery += "WHERE DD1.DD1_FILIAL = '" + xFilial('DD1') + "' AND "
			cQuery += "DD1.DD1_DTARET <= '" + DtoS(dDataBase) + "' AND "
			cQuery += "DD1.D_E_L_E_T_ = ''"
			cQuery := ChangeQuery(cQuery)
			MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasQry,.F.,.T.)}, '', STR0058 ) //--"Verificando Periodos de Prestacao de Servico..."
			If !(cAliasQry)->(EoF())
				While !(cAliasQry)->(EoF())
					DD1->(MsGoTo( (cAliasQry)->DD1RecNo ))
					RecLock('DD1',.F.)
					dDtaRet := DD1->DD1_DTARET
					DD1->DD1_DTCALC := dDtaRet
					DD1->DD1_DTAAFA := dDtaRet + DD1->DD1_DIATRB
					DD1->DD1_DTARET := ((dDtaRet + DD1->DD1_DIATRB) + DD1->DD1_DIAAFA)
					MsUnLock()
					(cAliasQry)->(DbSkip())
				EndDo
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aAreaDD1)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica contratos de clientes com fim de vigencia e que ainda nao estao encerrados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT R_E_C_N_O_ NRECNO "
		cQuery += "   FROM "+RetSqlName("AAM") + " AAM "
		cQuery += "  WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
		cQuery += "    AND AAM.AAM_STATUS = '1' "
		cQuery += "    AND AAM.AAM_FIMVIG <> ' ' AND AAM.AAM_FIMVIG < '" + DtoS(Date())+ "'"
		cQuery += "    AND AAM.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		Do While (cAliasQry)->(!Eof())
			AAM->(MsGoto( (cAliasQry)->NRECNO ))
			Reclock('AAM',.F.)
			AAM->AAM_STATUS := StrZero(3, Len(AAM->AAM_STATUS))
			MsUnLock()
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		PUTMV("MV_TMSUVER",DtoC(Date()))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativação/Inativação de Contratos de Demanda
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AliasInDic('DL7')
			cQuery := " SELECT R_E_C_N_O_ NRECNO, DL7_STATUS, DL7_INIVIG, DL7_FIMVIG "
			cQuery += "   FROM "+RetSqlName("DL7") + " DL7 "
			cQuery += "  WHERE DL7.DL7_FILIAL = '" + xFilial("DL7") + "' "
			cQuery += "    AND DL7.DL7_STATUS IN ('1','4') "
			cQuery += "    AND DL7.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			Do While (cAliasQry)->(!Eof())
				DL7->(MsGoto( (cAliasQry)->NRECNO ))
				//Para Contrato Ativo, e a data corrente não se encaixar no prazo da vigência, INATIVAR.
				If (cAliasQry)->DL7_STATUS == StrZero(1, Len(DL7->DL7_STATUS)) .And.;
				   ((cAliasQry)->DL7_INIVIG > DtoS(Date()) .Or. (cAliasQry)->DL7_FIMVIG < DtoS(Date())) 
					Reclock('DL7',.F.)
					DL7->DL7_STATUS := StrZero(4, Len(DL7->DL7_STATUS))
					MsUnLock()
				EndIf
				//Para Contrato Inativo, e a data corrente se encaixar no prazo da vigência, ATIVAR.
				If (cAliasQry)->DL7_STATUS == StrZero(4, Len(DL7->DL7_STATUS)) .And.;
				   ((cAliasQry)->DL7_INIVIG <= DtoS(Date()) .And. (cAliasQry)->DL7_FIMVIG >= DtoS(Date())) 
					Reclock('DL7',.F.)
					DL7->DL7_STATUS := StrZero(1, Len(DL7->DL7_STATUS))
					MsUnLock()
				EndIf				
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf		
	EndIf
EndIf

RestArea(aArea)
UnLockByName(cLockBy)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSDocExig   ³ Autor ³ Vitor Raspa        ³ Data ³ 06.Set.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe os detalhes na tela sobre os Documentos Exigidos de  ³±±
±±³          ³ Fornecedores / Motoristas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSDocExig()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSADocExig( aBloqDoc, nLin )
Local aArea      := GetArea()
Local aAreaDD1   := DD1->(GetArea())
Local aAreaDD2   := DD2->(GetArea())
Local aAreaDD3   := DD3->(GetArea())
Local aAreaDD4   := DD4->(GetArea())
Local cCodMot    := aBloqDoc[nLin,5]
Local cCodFor    := aBloqDoc[nLin,7]
Local cLojFor    := aBloqDoc[nLin,8]
Local nRecNo     := 0
Local lOldInc    := INCLUI
Local oMainModel := NIL

INCLUI := .F.

If !Empty(cCodFor) .And. !Empty(cLojFor)
	DD1->(DbSetOrder(1))
	If DD1->(MsSeek(xFilial('DD1') + cCodFor + cLojFor))
		nRecNo := DD1->(RecNo())

		If ExistFunc("TMSAD20STC") //--- Rotina MVC
			TMSAD20STC(.F., .T. )

			oMainModel:= FWLoadModel("TMSAD20")
			oMainModel:SetOperation( MODEL_OPERATION_VIEW )
			oMainModel:Activate()

			FWExecView (, "TMSAD20" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , oMainModel ) 

			TMSAD20STC(.F., .F.)
		EndIf

	EndIf
ElseIf !Empty(cCodMot)
	DD2->(DbSetOrder(1))
	If DD2->(MsSeek(xFilial('DD2') + cCodMot))
		nRecNo := DD2->(RecNo())
		TMSAD30Mnt( 'DD2', nRecNo, 2 )
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDD1)
RestArea(aAreaDD2)
RestArea(aAreaDD3)
RestArea(aAreaDD4)
INCLUI := lOldInc
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsBlqMnt    ³ Autor ³ Rodrigo Gomes      ³ Data ³ 05.Jan.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o bem encontra com OS em aberto na Manutencao  ³±±
±±³          ³ de Ativos 									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSBlqMnt(cExpC1, cExpC2, cExpC3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: Codigo do Bem                                      ³±±
±±³          ³ cExpC2: Rota da Viagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsBlqMnt(cCodBem,dDataIni,dDataFim,nTotDist,nCont,nDias)

Local aArea    := GetArea()
Local aBem     := {}
Local aRet     := {}
Local cSeek    := ""
Local lBloq    := .F.
Local cTipACon := ""
Local i        := 0
Local aTamSx3  := TamSx3("TP_ACUMCON")

AAdd(aBem, cCodBem)

DbSelectArea("STC")
dbSetOrder(1)
DbSelectArea("STF")
dbSetOrder(1)
DbSelectArea("ST9")
dbSetOrder(1)

If STC->(MsSeek(xFilial('STC') + aBem[1]))
	aRet := NGESTRU(STC->TC_COMPONE)
	For i := 1 to Len(aRet)
		AAdd(aBem, aRet[i])
	Next
EndIf

For i := 1 to Len(aBem)

	If STF->(MsSeek(cSeek := xFilial('STF') + aBem[i]))

		While STF->(!Eof()) .And. AllTrim(STF->(TF_FILIAL+TF_CODBEM)) == AllTrim( cSeek )

			cTipACon := STF->TF_TIPACOM

			If ST9->(MsSeek(xFilial('ST9') + STF->TF_CODBEM))

				If cTipACon == "T" // Tempo
					dDatReal := NGPROXMAN(ST9->T9_DTULTAC,; // Data da Proxima manutenção
									   STF->TF_TIPACOM,;
									   STF->TF_TEENMAN,;
									   STF->TF_UNENMAN,;
									   STF->TF_CONMANU,;
									   STF->TF_INENMAN,;
									   ST9->T9_CONTACU,;
									   ST9->T9_VARDIA)

					// -- Data Real da Próxima manutenção
 					dDatReal := NGCHKDTMNT(dDatReal, STF->TF_CALENDA, STF->TF_NAOUTIL)

					lBloq := dDatReal >= dDataIni .And. dDatReal <= dDataFim
					nDias := dDataFim - dDatReal

				ElseIf cTipACon == "C" // Contador

					// -- Busca o Contador (Odometro) real do bem
					cQuery := ""
					cQuery += "SELECT MAX(TP_ACUMCON) CONTAT "
					cQuery += "FROM " + RetSqlName("STP") + " STP "
					cQuery += "WHERE "
					cQuery += "STP.TP_FILIAL = '" + xFilial("STP") + "' AND "
					cQuery += "STP.TP_CODBEM = '" + aBem[i] + "' AND "
					cQuery += "STP.D_E_L_E_T_ = ''"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

					TCSetField(cAliasQry,"CONTAT","N",aTamSx3[1],aTamSx3[2])

					If (cAliasQry)->(!EoF())
						nTotDist += (cAliasQry)->CONTAT
					EndIf

					(cAliasQry)->(DbCloseArea())

					// -- Calcula o contador maximo permitido
					nCont := (STF->TF_CONMANU + STF->TF_INENMAN)

					// -- Contador da Próxima manutenção
					lBloq := nTotDist >= nCont
				EndIf

				// -- Devera ser checado se o TMS deve ou nao bloquear por Tempo ou por Contador
				If lBloq
					Exit
				EndIf

			EndIf

			STF->(DbSkip())
		EndDo
	EndIf
Next
RestArea(aArea)
Return(lBloq)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAComTax ³ Autor ³Wellington A Santos   ³ Data ³ 16/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna array informando se um componente e taxa            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM200ComTax(ExpA1,ExpC1,ExpL1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do componente para verificar se e taxa      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - Indica se o componente e taxa ou nao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAComTax(cComponente)
Local aArea:= GetArea()
Local nPos := 0
Local lRet := .F.
Static __aTaxa := {}
If ( nPos := Ascan(__aTaxa , { |x| x[1] == cComponente } ) ) == 0
	Aadd( __aTaxa, { cComponente , Posicione('DT3',1,xFilial('DT3') + cComponente,'DT3_TAXA') } )
	nPos := Len(__aTaxa)
EndIf

lRet := __aTaxa[nPos,2] == StrZero(1,Len(DT3->DT3_TAXA))

RestArea( aArea )
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSInfSol ³ Autor ³Wellington A Santos    ³ Data ³08/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca informacoes do solicitante para um conhecimento caso  ³±±
±±³          |este possua solicitacao e use sequencia de endereco         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSInfSol()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do documento                                ³±±
±±³          ³ ExpC2 = Documento de transporte (Ctrc)                     ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Cliente                                            ³±±
±±³          ³ ExpC5 = Loja                                               ³±±
±±³          ³ ExpL6 = Logico (T- Cliente Remetente)                      ³±±
±±³          ³                (F- Cliente Devedor - Ex: GISSCON.INI)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSInfSol(cFilDoc,cDoc,cSerie,cCliente,cLoja,lCliRem)

Local aRet				:= {}
Local lSolicitante	:= .F.
Local cInscr			:= ''
Local cSeqIns			:= ''
Local cMunDief		:= ''
Local lAchouDTC		:= .F.
//--Formato do vetor aRet
//aRet[1] -- CPF/CNPJ
//aRet[2] -- Inscricao Municipal
//aRet[3] -- Inscricao Estadual
//aRet[4] -- Nome
//aRet[5] -- Endereco, numero, complemento
//aRet[6] -- Bairro
//aRet[7] -- Cidade
//aRet[8] -- UF
//aRet[9] -- CEP
//aRet[10]-- email
//aRet[11]-- Codigo municipio
//aRet[12]-- Codigo municipio DIEF

Default cCliente	:= ""
Default cLoja		:= ""
Default lCliRem		:= .F.

DT6->(dbSetOrder(1)) //DT6_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
	If FindFunction("TmsPsqDY4") .And. TmsPsqDY4(cFilDoc,cDoc,cSerie)		
		DY4->(dbSetOrder(1))
		If DY4->(MsSeek(xFilial("DY4")+cFilDoc+cDoc+cSerie))
			DbSelectArea("DTC")
			DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto				
			If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO))
				lAchouDTC := .T.	
			Endif
		Endif
		
		If lAchouDTC .And. !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3"
			lSolicitante := .T.
		EndIf				
	Else
		DTC->(dbSetOrder(3))
		If DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDoc+cSerie)) .And. !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3"
			lSolicitante := .T.
		EndIf
	EndIf

	If lSolicitante
		//-- Posiciona na Ordem de Coleta
		DT5->(dbSetOrder(1))
		If DT5->(MsSeek(xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
			If Empty (DT5->DT5_SEQEND)
				DUE->(dbSetOrder(1))
				If DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_CODSOL)))
					Aadd( aRet , DUE->DUE_CGC   )
					Aadd( aRet , If (DUE->(FieldPos("DUE_INSCRM"))>0, DUE->DUE_INSCRM, "") ) //(Cod. Municipio )
					Aadd( aRet , DUE->DUE_INSCR )
					Aadd( aRet , DUE->DUE_NOME )
					Aadd( aRet , DUE->DUE_END )
					Aadd( aRet , DUE->DUE_BAIRRO )
					Aadd( aRet , DUE->DUE_MUN )
					Aadd( aRet , DUE->DUE_EST )
					Aadd( aRet , DUE->DUE_CEP )
					Aadd( aRet , DUE->DUE_EMAIL )
					Aadd( aRet , IIF(IsInCallStack('MATA972'), IIf (DUE->(FieldPos("DUE_GIASP"))>0, DUE->DUE_GIASP, ""), IIf (DUE->(FieldPos("DUE_CODMUN"))>0, DUE->DUE_CODMUN, ""))) //(Cod. Municipio )
					Aadd( aRet , '' )
				EndIf
			Else
				DUL->(dbSetOrder(3))
				If DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
					DUE->(dbSetOrder(1))
					If DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_CODSOL)))
						Aadd( aRet , DUE->DUE_CGC   )
					Else
						Aadd( aRet , ''  )
					EndIf
					Aadd( aRet , If (DUL->(FieldPos("DUL_INSCRM"))>0, DUL->DUL_INSCRM, "") ) //(Cod. Municipio )
					If DUE->( Found() )
						Aadd( aRet , DUE->DUE_INSCR )
						Aadd( aRet , DUE->DUE_NOME )
					Else
						Aadd( aRet , '' )
						Aadd( aRet , '' )
					EndIf
					Aadd( aRet , DUL->DUL_END )
					Aadd( aRet , DUL->DUL_BAIRRO )
					Aadd( aRet , DUL->DUL_MUN )
					Aadd( aRet , DUL->DUL_EST )
					Aadd( aRet , DUL->DUL_CEP )
					If DUE->( Found() )
						Aadd( aRet , DUE->DUE_EMAIL )
					Else
						Aadd( aRet , '' )
					EndIf
					Aadd( aRet , IIF(IsInCallStack('MATA972'), IIf (DUL->(FieldPos("DUL_GIASP"))>0, DUL->DUL_GIASP, ""), IIf (DUL->(FieldPos("DUL_CODMUN"))>0, DUL->DUL_CODMUN, ""))) //(Cod. Municipio )
					Aadd( aRet , '' )
				EndIf
			EndIf
		EndIf
	Else
		cSeqIns := ""
		Do Case
			Case DTC->DTC_DEVFRE == "1" .And. !Empty(DTC->DTC_SQIREM)
				cSeqIns := DTC->DTC_SQIREM
			Case DTC->DTC_DEVFRE == "2" .And. !Empty(DTC->DTC_SQIDES)
				cSeqIns := DTC->DTC_SQIDES
			Case DTC->DTC_DEVFRE == "3" .And. DTC->(FieldPos("DTC_SQICON")) > 0 .And. !Empty(DTC->DTC_SQICON)
				cSeqIns := DTC->DTC_SQICON
			Case DTC->DTC_DEVFRE == "4" .And. DTC->(FieldPos("DTC_SQIDPC")) > 0 .And. !Empty(DTC->DTC_SQIDPC)
				cSeqIns := DTC->DTC_SQIDPC
		EndCase

		If !Empty(cSeqIns)
			cInscr := Posicione("DV3",1,xFilial("DV3")+DTC->DTC_CLIDEV+DTC->DTC_LOJDEV+cSeqIns,"DV3_INSCR")
		Endif

		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+ Iif(lCliRem, DT6->(DT6_CLIREM+DT6_LOJREM), DT6->(DT6_CLIDEV+DT6_LOJDEV)) ))
			Aadd( aRet , SA1->A1_CGC )
			Aadd( aRet , SA1->A1_INSCRM )
			If Empty(cSeqIns)
				Aadd( aRet , SA1->A1_INSCR )
			Else
				Aadd( aRet , cInscr )
			EndIf
			Aadd( aRet , SA1->A1_NOME )
			Aadd( aRet , SA1->A1_END )
			Aadd( aRet , SA1->A1_BAIRRO )
			Aadd( aRet , SA1->A1_MUN )
			Aadd( aRet , SA1->A1_EST )
			Aadd( aRet , SA1->A1_CEP )
			Aadd( aRet , SA1->A1_EMAIL )

			If (GetNewPar ("MV_CODMUN", "X")<>"X") .And. !(SA1->(Eof ())) .And. (SA1->(FieldPos(AllTrim (SuperGetMv ("MV_CODMUN"))))>0)
				Aadd( aRet ,SA1->(FieldGet (FieldPos (SuperGetMv ("MV_CODMUN")))))
			ElseIf (SA1->(FieldPos("A1_COD_MUN"))>0) .And. !(SA1->(Eof ()))
				Aadd( aRet , SA1->A1_COD_MUN)
			Else
				Aadd( aRet ,"")
			EndIf
			//-- Codigo Municipio DIEF/ES
			If (SA1->(FieldPos(AllTrim(SuperGetMv("MV_MCDFES",.F.,""))))>0)
				cMunDief := Alltrim(SA1->&(SuperGetMv("MV_MCDFES",.F.,"")))
				If Empty(cMunDief)
					If SuperGetMV('MV_CDRORI',.F.,"",DT6->DT6_FILDOC) == DT6->DT6_CDRORI
						cMunDief := Alltrim(SuperGetMv("MV_MUNDIEF",.F.,""))
					EndIf
				EndIf
			EndIf
			Aadd( aRet , cMunDief )
		EndIf
	EndIf
ElseIf !Empty(cCliente)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando nao encontra o DT6, significa que a NF foi emitida pelo faturamento. Ou seja, dados do SA1.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
		Aadd(aRet,SA1->A1_CGC)
		Aadd(aRet,SA1->A1_INSCRM)
		Aadd(aRet,SA1->A1_INSCR)
		Aadd(aRet,SA1->A1_NOME)
		Aadd(aRet,SA1->A1_END)
		Aadd(aRet,SA1->A1_BAIRRO)
		Aadd(aRet,SA1->A1_MUN)
		Aadd(aRet,SA1->A1_EST)
		Aadd(aRet,SA1->A1_CEP)
		Aadd(aRet,SA1->A1_EMAIL)
		Aadd(aRet,SA1->A1_CODMUN)
		If (SA1->(FieldPos(AllTrim(SuperGetMv("MV_MCDFES",.F.,""))))>0)
			Aadd( aRet ,  Alltrim(SA1->&(SuperGetMv("MV_MCDFES",.F.,""))) )
		Else
			Aadd( aRet ,"")
		EndIf
	EndIf
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSSinteg ³ Autor ³Wellington A Santos    ³ Data ³21/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca informacoes para a geracao do arquivo sintegra        ³±±
±±³          |                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSInfSol()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do documento                                ³±±
±±³          ³ ExpC2 = Documento de transporte (Ctrc)                     ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSSinteg(cFilDoc,cDoc,cSerie)

Local aRet			:= {}
Local cAliasQry		:= GetNextAlias()
Local cCampIns		:= " "
Local cCampCli		:= " "
Local cCampLoj		:= " "
Local cCampDev		:= " "
Local lSegPer		:= .F. // Segundo percurso
Local lTransf		:= .F.
Local cAliasNew		:= " "
Local cPrefix		:= " "
Local cNum			:= " "
Local cTipo			:= " "
Local cCliDev		:= " "
Local cLojDev		:= " "
Local cQuery		:= " "
Local aDocDTC		:= {}
Local nCnt			:= 0
Local aAreaDT6		:= {}
Local cCliente		:= " "
Local cLoja			:= " "
Local cRet			:= ""
Local cIE1			:= ""
Local cIE2			:= ""
Local cIEDev		:= ""
Local lSINTEGAPO	:= ExistBlock("SINTEGAPO")
Local lDY4			:= AliasInDic("DY4")
Local lNfEntr		:= DTC->(FieldPos("DTC_NFENTR")) > 0

//--Formato do vetor aRet
//aRet[1] -- CPF/CNPJ
//aRet[2] -- UF
//aRet[3] -- { Inscricao estadual devedor , Inscricao estadual figura 2, Data de emissao da NF, Serie da Nf, Numero da Nf, Valor da nf }

DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
If (DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie)))

	//Verifica o documento de Apoio
	If !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO))
		cPrefix  := DT6->DT6_PREFIX
		cNum     := DT6->DT6_NUM
		cTipo    := DT6->DT6_TIPO
		cCliDev  := DT6->DT6_CLIDEV
		cLojDev  := DT6->DT6_LOJDEV
		aAreaDT6 := DT6->(GetArea())

		cAliasNew:= GetNextAlias()
		cQuery := " SELECT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE "
		cQuery += "  FROM " +RetSqlName("DT6")+ " DT6 "
		cQuery += " WHERE "
		cQuery += "     DT6_FILIAL ='" + xFilial("DT6") + "' "
		cQuery += " AND DT6_CLIDEV ='" + cCliDev + "' "
		cQuery += " AND DT6_LOJDEV ='" + cLojDev + "' "
		cQuery += " AND DT6_PREFIX ='" + cPrefix + "' "
		cQuery += " AND DT6_NUM    ='" + cNum    + "' "
		cQuery += " AND DT6_TIPO   ='" + cTipo   + "' "
		cQuery += " AND DT6_DOCTMS IN ('B','C','H','I','N','O') "
		cQuery += " AND DT6.D_E_L_E_T_=' '"
		//-- Ponto de entrada para verificar se a query na DT6
		//-- retornará todos os documentos de apoio.
		If lSINTEGAPO
			cRet := ExecBlock("SINTEGAPO",.F.,.F.,cQuery)
			If ValType(cRet) == "C"
				cQuery := cRet
			EndIf
		EndIf
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
		Do While (cAliasNew)->(!Eof())
			Aadd( aDocDTC, {(cAliasNew)->DT6_FILDOC,(cAliasNew)->DT6_DOC,(cAliasNew)->DT6_SERIE })
			(cAliasNew)->( DbSkip() )
		EndDo
		(cAliasNew)->(DbCloseArea())
		RestArea(aAreaDT6)
	EndIf

	If DT6->DT6_PRIPER == '1' //-- Doc.1o.Percurso 1=Sim
		lSegPer := .T.
	EndIf
	//-- Se CTRC complemento verifica se Doc. origem 1o.Percurso 1=Sim
	If !Empty(DT6->DT6_DOCDCO)
		cFilDoc := DT6->DT6_FILDCO
		cDoc    := DT6->DT6_DOCDCO
		cSerie  := DT6->DT6_SERDCO
		aAreaDT6 := DT6->(GetArea())
		cAliasNew:= GetNextAlias()
		cQuery := " SELECT DT6_PRIPER "
		cQuery += "  FROM " +RetSqlName("DT6")+ " DT6 "
		cQuery += " WHERE "
		cQuery += "     DT6_FILIAL ='" + xFilial("DT6")  + "' "
		cQuery += " AND DT6_FILDOC ='" + DT6->DT6_FILDCO + "' "
		cQuery += " AND DT6_DOC    ='" + DT6->DT6_DOCDCO + "' "
		cQuery += " AND DT6_SERIE  ='" + DT6->DT6_SERDCO + "' "
		cQuery += " AND DT6.D_E_L_E_T_=' '"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
		If (cAliasNew)->(!Eof())
			If	(cAliasNew)->DT6_PRIPER == '1'
				lSegPer := .T.
			EndIf
		EndIf
		(cAliasNew)->(DbCloseArea())
		RestArea(aAreaDT6)
	EndIf


	If DT6->DT6_DEVFRE == '1' //-- Remetente
		//-- IE Destinatario quando o Tomador for o Remetente e o Remetente quando o tomador for o Destinatario.
		cCliente := DT6->DT6_CLIDES
		cLoja    := DT6->DT6_LOJDES
		cCampIns := "DTC_SQIDES"
		//-- IE Tomador do Frete
		cCampCli := "DTC_CLIREM"
		cCampLoj := "DTC_LOJREM"
		cCampDev := "DTC_SQIREM"
	ElseIf DT6->DT6_DEVFRE == '2' //-- Destinatário
		//-- IE Destinatario quando o Tomador for o Remetente e o Remetente quando o tomador for o Destinatario.
		cCliente := DT6->DT6_CLIREM
		cLoja    := DT6->DT6_LOJREM
		cCampIns := "DTC_SQIREM"
		//-- IE Tomador do Frete
		cCampCli := "DTC_CLIDES"
		cCampLoj := "DTC_LOJDES"
		cCampDev := "DTC_SQIDES"
	ElseIf DT6->DT6_DEVFRE == '3' //-- Consignatário
		cCliente := DT6->DT6_CLICON
		cLoja    := DT6->DT6_LOJCON
		cCampDev := "DTC_SQICON"
		cCampCli := "DTC_CLICON"
		cCampLoj := "DTC_LOJCON"
		cCampIns := "DTC_SQICON"
	ElseIf DT6->DT6_DEVFRE == '4' //-- Despachante
		cCliente := DT6->DT6_CLIDPC
		cLoja    := DT6->DT6_LOJDPC
		cCampDev := "DTC_SQIDPC"
		cCampCli := "DTC_CLIDPC"
		cCampLoj := "DTC_LOJDPC"
		cCampIns := "DTC_SQIDPC"
	Else
		cCliente := DT6->DT6_CLIREM
		cLoja    := DT6->DT6_LOJREM
		cCampIns := "DTC_SQIREM"
		cCampCli := "DTC_CLIDES"
		cCampLoj := "DTC_LOJDES"
		cCampDev := "DTC_SQIDES"
	EndIf
	//-- Remetente/Destinatario
	If DT6->DT6_DEVFRE $ '12'
		If DT6->DT6_TIPFRE == "1" // CIF
			cCliDev := DT6->DT6_CLIDES
			cLojDev := DT6->DT6_LOJDES
		ElseIf DT6->DT6_TIPFRE == "2" // FOB
			cCliDev := DT6->DT6_CLIREM
			cLojDev := DT6->DT6_LOJREM
		EndIf
		//-- Verifica se nao houve transferencia de debito.
		If DT6->(DT6_CLIDEV+DT6_LOJDEV) == cCliDEV+cLojDEV
			If DT6->(DT6_CLIDEV+DT6_LOJDEV) == DT6->(DT6_CLIREM+DT6_LOJREM)
				SA1->(DbSetOrder (1))
				If SA1->(MsSeek (xFilial("SA1")+cCliente+cLoja))
					lTransf  := .T.
					cIEDev   := SA1->A1_INSCR
					cCliente := DT6->DT6_CLIDES
					cLoja    := DT6->DT6_LOJDES
				EndIf
			ElseIf DT6->(DT6_CLIDEV+DT6_LOJDEV) == DT6->(DT6_CLIDES+DT6_LOJDES)
				SA1->(DbSetOrder (1))
				If SA1->(MsSeek (xFilial("SA1")+cCliente+cLoja))
					lTransf  := .T.
					cIEDev   := SA1->A1_INSCR
					cCliente := DT6->DT6_CLIREM
					cLoja    := DT6->DT6_LOJREM
				EndIf
			EndIf
		EndIf
		//-- Verifica se e documento de devolucação e se o documento original está preenchido para inverter a busca na nota fiscal
		If DT6->DT6_DOCTMS = '6' .and. !Empty(DT6->DT6_DOCDCO)
			//-- Se o devedor do frete for remetente na nota original buscar os dados do destinatário
			If DT6->DT6_DEVFRE = '1'
				cCampDev := "DTC_SQIDES"
				cCampCli := "DTC_CLIDES"
				cCampLoj := "DTC_LOJDES"
			ElseIf DT6->DT6_DEVFRE = '2'//-- Se o devedor do frete for o destinatário na nota original buscar os dados do remetente
				cCampDev := "DTC_SQIREM"
				cCampCli := "DTC_CLIREM"
				cCampLoj := "DTC_LOJREM"
			EndIf
		EndIf
	EndIf

	If Empty(aDocDTC)
		Aadd(aDocDTC, {cFilDoc, cDoc, cSerie})
	EndIf
	For nCnt := 1 To Len(aDocDTC)
		cFilDoc:= aDocDTC[nCnt,1]
		cDoc   := aDocDTC[nCnt,2]
		cSerie := aDocDTC[nCnt,3]

		SA1->(DbSetOrder (1))
		If SA1->(MsSeek (xFilial("SA1")+cCliente+cLoja))
			Aadd( aRet , SA1->A1_CGC )
			Aadd( aRet , SA1->A1_EST )
			cIE1 := SA1->A1_INSCR
			cIE2 := SA1->A1_INSCR

			cQuery := " SELECT "
			cQuery += " SA11.A1_INSCR A1_INSCR1, DV31.DV3_INSCR DV3_INSCR1, DTC_EMINFC, DTC_SERNFC, DTC_NUMNFC, DTC_VALOR, "
			cQuery += " SA12.A1_INSCR A1_INSCR2, DV32.DV3_INSCR DV3_INSCR2, DTC_CLIDEV, DTC_LOJDEV "
			cQuery += " FROM " + RetSqlName("DTC") + " DTC "
			//-- IE Tomador do Frete
			cQuery += " LEFT JOIN " + RetSqlName("DV3") + " DV31 "
			cQuery += " ON  DV31.DV3_FILIAL = '" + xFilial("DV3") + "' "
			cQuery += " AND DV31.DV3_CODCLI = "  + cCampCli
			cQuery += " AND DV31.DV3_LOJCLI = "  + cCampLoj
			cQuery += " AND DV31.DV3_SEQUEN = "  + cCampDev
			cQuery += " AND DV31.D_E_L_E_T_ = ' ' "
			cQuery += " JOIN " + RetSqlName("SA1") + " SA11 "
			cQuery += " ON  SA11.A1_FILIAL  = '" + xFilial("SA1") + "' "
			cQuery += " AND SA11.A1_COD     =  " + cCampCli
			cQuery += " AND SA11.A1_LOJA    =  " + cCampLoj
			cQuery += " AND SA11.D_E_L_E_T_ = ' ' "
			//-- IE Destinatario quando o Tomador for o Remetente e o Remetente quando o tomador for o Destinatario.
			cQuery += " LEFT JOIN " + RetSqlName("DV3") + " DV32 "
			cQuery += " ON  DV32.DV3_FILIAL = '" + xFilial("DV3") + "' "
			cQuery += " AND DV32.DV3_CODCLI = '" + cCliente + "' "
			cQuery += " AND DV32.DV3_LOJCLI = '" + cLoja    + "' "
			cQuery += " AND DV32.DV3_SEQUEN = "  + cCampIns
			cQuery += " AND DV32.D_E_L_E_T_ = ' ' "
			cQuery += " JOIN " + RetSqlName("SA1") + " SA12 "
			cQuery += " ON  SA12.A1_FILIAL  = '" + xFilial("SA1") + "' "
			cQuery += " AND SA12.A1_COD     = '" + cCliente + "' "
			cQuery += " AND SA12.A1_LOJA    = '" + cLoja    + "' "
			cQuery += " AND SA12.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += " AND DTC_FILDOC   = '" + cFilDoc + "' "

			If lSegPer .And. Empty(DT6->DT6_DOCDCO)
				cQuery += " AND DTC_DOCPER = '" + cDoc + "' "
			Else
				cQuery += " AND DTC_DOC    = '" + cDoc + "' "
			EndIf

			cQuery += " AND DTC_SERIE  = '" + cSerie  + "' "
			cQuery += " AND DTC.D_E_L_E_T_ = ' ' "
			//-- pesquisar as notas que foram vinculadas na tabela DY4 pelos documentos de reentrega / devolucao
			If lDY4 .And. lNfEntr
				DY4->(DbSetOrder(1))
				If DY4->(MsSeek(xFilial("DY4") + DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) ))
					cQuery += " AND EXISTS ( SELECT 1 "
					cQuery += " FROM " + RetSqlName("DY4") + " DY4 "
					cQuery += " WHERE DY4_FILIAL = '" + xFilial("DY4")  + "' "
					cQuery += " AND DY4_FILDOC   = '" + DT6->DT6_FILDOC + "' "
					cQuery += " AND DY4_DOC      = '" + DT6->DT6_DOC    + "' "
					cQuery += " AND DY4_SERIE    = '" + DT6->DT6_SERIE  + "' "
					cQuery += " AND DY4_NUMNFC   = DTC_NUMNFC "
					cQuery += " AND DY4_SERNFC   = DTC_SERNFC "
					cQuery += " AND DY4_CODPRO   = DTC_CODPRO "
					cQuery += " AND DY4.D_E_L_E_T_ = ' ') "
				EndIf
			EndIf
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			aAdd( aRet , {} )
			Do While (cAliasQry)->( !Eof() )
				CIE1 := Iif( Empty((cAliasQry)->DV3_INSCR1), (cAliasQry)->A1_INSCR1, (cAliasQry)->DV3_INSCR1 )
				cIE2 := Iif( Empty((cAliasQry)->DV3_INSCR2), (cAliasQry)->A1_INSCR2, (cAliasQry)->DV3_INSCR2 )
				If lTransf
					cIE1 := cIEDev // Restaura IE do Tomador do Frete
				EndIf
				aAdd( aRet[3], {	cIE1,; // IE Tomador do Frete
									cIE2,; // IE Destinatario quando o Tomador for o Remetente e o Remetente quando o tomador for o Destinatario.
									(cAliasQry)->DTC_EMINFC,;
									(cAliasQry)->DTC_SERNFC,;
									(cAliasQry)->DTC_NUMNFC,;
									(cAliasQry)->DTC_VALOR })
				(cAliasQry)->( DbSkip() )
			EndDo
			(cAliasQry)->( DbCloseArea() )
		Else
			Help(' ',1,STR0040,,STR0020+' '+cCliente+' '+STR0021+' '+cLoja+ ' '+STR0086,5,11)
			aRet := {}
			Exit
		EndIf
	Next

EndIf

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSOPdgPC    ³ Autor ³ Vitor Raspa        ³ Data ³ 24.Nov.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Pedidos de Compra referente a prestacao de servicos   ³±±
±±³          ³ realizada pela Operadora de Frotas/Vale-Pedagio            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSOPdgPC(cExpC1, cExpC2, cExpC3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: Codigo da Operadora                                ³±±
±±³          ³ cExpC2: Filial de Origem                                   ³±±
±±³          ³ cExpC3: Numero da Viagem                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSOPdgPC( cCodOpe, cFilOri, cViagem, nOpcx )
Local aArea    := GetArea()
Local aAreaDEH := DEH->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaDTR := DTR->(GetArea())
Local nValPC   := 0
Local cNumPC   := ''
Local cPrcTra  := ''
Local cTxtObs  := ''
Local aCbPC    := {}
Local aItPC    := {}

DEG->(DbSetOrder(1))
If cCodOpe == '01' .And. DEG->(MsSeek(xFilial('DEG') + cCodOpe))

	If nOpcx == 3
		//-- Verifica as configuracoes realizadas no cadastro da Operadora de Frotas
		DEH->(DbSetOrder(1))
		If DEH->(MsSeek(xFilial('DEH') + cCodOpe))
			While DEH->(DEH_FILIAL+DEH_CODOPE) == xFilial('DEH') + cCodOpe
				nValPC := &(DEH->DEH_FORMUL)
				If ValType( nValPC ) <> 'N'
					Help('',1,'TMSA20016',,DEH->DEH_CODPRO,5,11) //-- 'O conteudo da formula para geracao do Pedido de Compra e invalido! Produto: '
				Else

					DTR->(DbSetOrder(1))
					If DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem))
						cPrcTra := DTR->DTR_PRCTRA
					EndIf
					cTxtObs := 'Vge: ' + cViagem + ' - Prc.Tra: ' + cPrcTra

					cNumPC := Criavar("C7_NUM",.T.)
					aCbPC := {	{"C7_NUM"		,cNumPC	  			,NIL},;  // Numero do Pedido
								{"C7_EMISSAO"	,dDataBase			,NIL},;  // Data de Emissao
								{"C7_FORNECE"	,DEG->DEG_CODFOR	,NIL},;  // Fornecedor
								{"C7_LOJA"		,DEG->DEG_LOJFOR	,NIL},;  // Loja do Fornecedor
								{"C7_COND"		,Posicione('SA2',1,xFilial('SA2')+DEG->(DEG_CODFOR+DEG_LOJFOR),'A2_COND')	,NIL},;  // Condicao de Pagamento
								{"C7_CONTATO"	,Posicione('SA2',1,xFilial('SA2')+DEG->(DEG_CODFOR+DEG_LOJFOR),'A2_CONTATO')	,NIL},;  // Contato
								{"C7_TIPO"		,1					,NIL},;  // Pedido de Compra
								{"C7_FILENT"	,xFilial('SC7')		,NIL}}   // Filial de Entrega

					aItPc := {	{	{"C7_NUM"		, cNumPc								,NIL},;	// Numero
									{"C7_ITEM"		,StrZero(1,Len(SC7->C7_ITEM))			,NIL},;	// Item
									{"C7_PRODUTO"	,DEH->DEH_CODPRO						,NIL},;	// Produto
									{"C7_QUANT"		,1					 					,NIL},;	// Quantidade
									{"C7_UM"		,Posicione('SB1',1,xFilial('SB1')+DEH->DEH_CODPRO,'B1_UM')	,NIL},;	// Unidade de Medida Produto
									{"C7_PRECO"		,nValPC									,NIL},;	// Valor do Frete (Unitario)
									{"C7_TOTAL"		,nValPC									,NIL},;	// Valor do Frete (Total)
									{"C7_DATPRF"	,dDataBase								,NIL},;	// DataBase
									{"C7_LOCAL"		,RetFldProd(SB1->B1_COD,"B1_LOCPAD")	,NIL},;	// Almoxarifado
									{"C7_TPFRETE"	,"C"									,NIL},;	// Tipo do Frete
									{"C7_OBS"		,cTxtObs								,NIL},;	// Observacoes
									{"C7_ORIGEM"	,"SIGATMS"								,NIL}}}	// Origem

					lMsErroAuto := .F.
					MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCbPC,aItPC,3,.F.)

					//-- Mostra Erro na geracao de Rotinas automaticas
					If lMsErroAuto
						MostraErro()
					EndIf
				EndIf
				DEH->(DbSkip())
            EndDo
        EndIf
    Else
    	DTR->(DbSetOrder(1))
    	If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
			aCbPC := {	{"C7_NUM"		,DTR->DTR_OPERPC	,NIL}}   // Filial de Entrega

			lMsErroAuto := .F.
			MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCbPC,aItPc,5,.F.)

			//-- Mostra Erro na geracao de Rotinas automaticas
			If lMsErroAuto
				MostraErro()
			EndIf
		EndIf
    EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDEH)
RestArea(aAreaSA2)
RestArea(aAreaSB1)
RestArea(aAreaDTR)

Return(cNumPC)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSLogXML    ³ Autor ³ Vitor Raspa        ³ Data ³ 09.Abr.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera as trasacoes via XML realizadas com a Operadora de    ³±±
±±³          ³ frotas em disco                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSLogXML( cExpC1, cExpC2 )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: String XML que deve ser gravada em disco           ³±±
±±³          ³ cExpC2: Nome do Arquivo de Destino                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSLogXML( cXML, cArqDest )
Local oXML
Local cError    := ''
Local cWarning  := ''
Local cBarSrv   := If( IsSrvUnix(), "/", "\" ) //Checa se o Server e Linux
Local cPath     := ''

If IsSrvUnix()
	cPath := CurDir() + cBarSrv + 'TMSXML' + cBarSrv
Else
	cPath := CurDir() + 'TMSXML' + cBarSrv
EndIf

//-- Cria diretorio
If !ExistDir( cPath )
	If MakeDir( cPath ) <> 0
		Help('',1,'TMSCFUNC15')
	EndIf
EndIf

If ExistDir( cPath )
	//-- Transforma a string XML em Objeto
	oXML := XMLParser( cXML, '_', @cError, @cWarning )

	cArqDest :=  Str(year(dDatabase),4) + StrZero(Month(dDatabase),2) + StrZero(Day(dDatabase),2) + "_" + StrTran(Time(),":","") + "_" + AllTrim(Str(ThreadId()))+"_"+ cArqDest 
	//-- Salva o XML em disco
	XMLSaveFile( oXML, cPath + cArqDest, .T. )
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSNoAcento  ³ Autor ³ Vitor Raspa        ³ Data ³ 09.Abr.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Remove acentos e caracteres especiais que implicam em      ³±±
±±³          ³ problemas na geracao de arquivos no formato XML            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSLogXML( cExpC1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: String XML que deve ser tratada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLRet : XML sem os caracteres especiais                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSNoAcento( cXML )
Local cXMLRet := ''

cXMLRet := NoAcento( OemToAnsi( cXML ) )	//-- Remove os Acentos
cXMLRet := StrTran( cXMLRet, 'º', ' ')		//-- Remove o Caracter 1.'o'
cXMLRet := StrTran( cXMLRet, 'ª', ' ')		//-- Remove o Caracter 1.'a'
cXMLRet := StrTran( cXMLRet, '&', ' ')		//-- Remove o Caracter &
cXMLRet := StrTran( cXMLRet, '´', ' ')		//-- Remove o Caracter ´
cXMLRet := StrTran( cXMLRet, '°', ' ')		//-- Remove o Caracter ° 'o' Celsius

Return( cXMLRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ProxIdVc ³ Autor ³ Eduardo Vicente       ³ Data ³ 22/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolve o proximo sequencial de identicacao de viagem	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProxIdVc(lSave)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ lSave - Indica se grava SX6 ou nao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Uso       ³ TMS/OMS                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ProxIdVc(lSave)

Local lFalhou := .F.
Local cTexto  := STR0066 //"O parametro MV_IDENTVC nao foi conseguiu ser travado. O numero sequencial do movimento sera "
Local aArea   := GetArea()
Local nTam    := TamSx3("DAK_IDENT")[1]
Local cNumSeq := Replicate("0",nTam)
Local i       := 0
Local nTentativas := 0

IF ValType(lSave) != "L"
	lSave := .T.
Endif
lFalhou := lSave

If lSave .And. !__lArquivo //-- Se for gravar o IDENT os 2 arquivos DEVEM ESTAR ABERTOS!

	If Select('DTQ') <= 0
		dbSelectArea('DTQ')
	EndIf
	If Select('DAK') <= 0
		dbSelectArea('DAK')
	EndIf

	__lArquivo := (Select('DTQ')>0) .And. (Select('DAK')>0)
	RestArea(aArea)
Endif

IF lxProxIdVc == Nil
	lxProxIdVc := ExistBlock("XPROXIDVC")
Endif
IF lxProxIdVc
	cNumSeq := ExecBlock("xProxIdVc",.f.,.f.)
	If ValType(cNumSeq) == "C"
		Return cNumSeq
	EndIf
Endif

IF __lNoErro == Nil .and. lSave
	ChkSeqVc()
Endif

IF lSave .And. (!__lNoErro .Or. !__lArquivo)
	FINAL(STR0067) //" AJUSTAR PARAMETRO MV_IDENTVC"
Endif

IF lFProxIdVc == Nil
	lFProxIdVc := ExistBlock("FPROXIDVC")
Endif

If !(GetMV("MV_IDENTVC",.T.))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona SM0 para transferir numero sequencial.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SM0->M0_CODIGO+SM0->M0_CODFIL # cEmpAnt+cFilant
		SM0->(MsSeek(cEmpAnt+cFilant))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui parametro no SX6.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFalhou := .F.
	dbSelectArea("SX6")

	For i:=1 to FCount()
		If !(ALLTRIM(FIELDNAME(i)) $ "X6_FIL/X6_VAR/X6_TIPO/X6_DESCRIC/X6_DESC1/X6_DESC2/X6_CONTEUD/X6_CONTSPA/X6_CONTENG")
			FieldPut(i,"X")
		EndIf
	Next i
	PUTMV("MV_IDENTVC",StrZero(SM0->M0_DOCSEQ,nTam))
	IF lFProxIdVc
		ExecBlock("FPROXIDVC",.f.,.f.,StrZero(SM0->M0_DOCSEQ,nTam))
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tenta travar 10 vezes os registros                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nTentativas < 10 .And. lFalhou
		lFalhou:=!(Reclock("SX6",.F.))
		nTentativas++
	End
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se conseguiu travar os registros.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
If lFalhou .and. lSave
	#IFNDEF WINDOWS
		Alert(cTexto+cNumSeq)
	#ELSE
		If IsTelNet()
			VTAlert(cTexto+cNumSeq, STR0070) //"Problema MV_IDENTVC"
		Else
			MsgAlert(cTexto+cNumSeq)
		EndIf
	#ENDIF
ElseIF lSave
	cNumSeq := Soma1(Subs(GetMV("MV_IDENTVC"),1,nTam))
	PutMV("MV_IDENTVC",cNumSeq)
	IF lFProxIdVc
		ExecBlock("FPROXIDVC",.f.,.f.,cNumSeq)
	Endif
	MsUnlock()
Else
	cNumSeq := Soma1(Substr(GETMV("MV_IDENTVC"),1,nTam))
	MsUnlock()
Endif
RestArea(aArea)

Return cNumSeq

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ChkSeqVc  ³ Autor ³Eduardo Vicente        ³ Data ³ 25/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Testa se parametro dos numeros sequenciais nao esta com    ³±±
±±³          ³ algum valor incorreto.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkSeqVc() 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMS/OMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChkSeqVc()

Local cNext
Local cNum,cGreat := Space(Len(Criavar("DAK_IDENT")))
Local cText
Local cAlias := Alias()
//Local aAreaDTQ
Local aAreaDAK
Local lRet := .T.

If lxProxIdVc == Nil
	lxProxIdVc := ExistBlock("XPROXIDVC")
EndIf
If lxProxIdVc
	__lNoErro := .t.
	lRet := .F.
EndIf

If lRet

	__lArquivo := (Select('DTQ')>0) .And. (Select('DAK')>0)

	If __lArquivo

		dbSelectArea("DAK")
		aAreaDAK := GetArea()
		dbSetOrder(4)
		MsSeek(xFilial("DAK")+"zzzzzz",.T.)
		dbSkip(-1)
		If DAK_FILIAL == xFilial("DAK")
			cNum := DAK_IDENT
		Else
			cNum := Space(Len(DAK_IDENT))
		EndIf
		If cNum > cGreat
			cGreat := cNum
		EndIf
		RestArea(aAreaDAK)

		cNext := ProxIdVc(.f.)

		If cGreat >= cNext
			cText := STR0071+cGreat+"." //"Problema no conteudo do parametro MV_IDENTVC. O valor correto deveria ser: "
			cText += STR0072 //"O Sistema abandonara na primeira montagem de carga."
			If IsTelNet()
				VTAlert(cText,STR0070) //"Problema MV_IDENTVC"
			Else
				Aviso(STR0073,cText,{"Ok"}) //"Problema no parametro MV_IDENTVC"
			EndIf
			__lNoErro := .F.
		Else
			__lNoErro := .T.
		EndIf
	EndIf
EndIf

If !Empty(cAlias)
	dbSelectArea(cAlias)
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAtuVge  ³ Autor ³ Rodolfo K. Rosseto   ³ Data ³03.Jul.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao da tabela DFI, totalizador para o Contr.Carreteiro³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA140 / TMSA141 / TMSA340						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem da Viagem         				     ³±±
±±³          ³ ExpC2 = Numero da Viagem         						        ³±±
±±³          ³ ExpC3 = Identificador de Viagem/Carga                      ³±±
±±³          ³ ExpN4 = 1=Inclusao;2=Alteracao;3=Exclusao;4=Encerramento   ³±±
±±³          ³			  5=Estorno do Encerramento								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAtuVge(cFilOri,cViagem,cIdent,nAcao)

Local cAliasQry  := GetNextAlias()
Local cAliasNew  := GetNextAlias()
Local cQuery     := ""
Local cTpUso     := "1" //--Viagem
Local aAreaDFI   := GetArea()
Local nRecno     := 0
Local cRota      := ""
Local cCdrOri    := ""
Local cCdrDes    := ""
Local aRegDca    := {}
Local aRegInf    := {}
Local lUltDest   := SuperGetMv('MV_ULTDEST',,.F.) // Define se utiliza o ultimo destino da coleta/entrega.
Local dDatIni    := Ctod('')
Local dDatFim    := Ctod('')
Local dDatEnc    := Ctod('')
Local aDiaSem    := {}
Local aDiaFimSem := {}
Local lGerCont   := GetMV('MV_GERCONT',,.F.) // Gera Contrato de Carreteiro para Entregas e Coletas Nao Efetuadas ?
Local nQtdOri    := 0
Local nPesOco    := 0
Local nQtdOco    := 0
Local nSeek      := 0
Local aQtdEnt    := {}
Local nQtdEnt    := 0
Local lKmDist    := SuperGetMv('MV_KMDIST',,.F.)  // Define que o calculo do Km será sempre pelo cadastro de Distancia para os calculos do frete a pagar.
Local nCntQry    := 0
Local nOdoEnt    := 0
Local nOdoSai    := 0
Local nKmVge     := 0
Local nCnt       := 0

DbSelectArea("DFI")
DbSelectArea("DTQ")
DFI->(DbSetOrder(1))
DTQ->(DbSetOrder(1))

If nAcao == 1 .Or. nAcao == 2 //--Inclusao ou Alteracao
	//--Verifica a Regiao
	If DTQ->(MsSeek(xFilial("DTQ")+cViagem))
		cRota   := DTQ->DTQ_ROTA
		cCdrOri := Posicione("DA8",1,xFilial("DA8")+cRota,"DA8_CDRORI")
	EndIf
	If DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS))
		//-- Obter a ultima Regiao de Descarga
		aRegDCA  := TMSRegDca(DTQ->DTQ_ROTA)
		If !Empty(aRegDCA)
			//-- A Ultima Regiao da TMSNivInf() sera' a Regiao Destino.
			aRegInf := {}
			TMSNivInf( aRegDCA[Len(aRegDCA)][2],@aRegInf )
			If !Empty(aRegInf)
				cCdrDes := aRegInf[Len(aRegInf)][1]
			Else
				cCdrDes := aRegDCA[Len(aRegDCA)][2]
			EndIf
		EndIf
	Else
		If !lUltDest
			cCdrDes := cCdrOri
		Else
			cQuery := " SELECT DUD_CDRCAL, DT6_CDRCAL "
			cQuery += "   FROM "
			cQuery += RetSqlName("DUD") + " DUD, "
			cQuery += RetSqlName("DT6") + " DT6 "
			cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
			cQuery += "     AND DUD_FILORI = '" + cFilOri + "'"
			cQuery += "     AND DUD_VIAGEM = '" + cViagem + "'"
			cQuery += "     AND DUD_SEQUEN = ( "
			cQuery += "     	SELECT Max(DUD_SEQUEN) "
			cQuery += "   		  FROM " + RetSqlName("DUD")
			cQuery += "   		  WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
			cQuery += "     	    AND DUD_FILORI = '" + cFilOri + "'"
			cQuery += "           AND DUD_VIAGEM = '" + cViagem + "'"
			cQuery += "           AND D_E_L_E_T_ = ' ' ) "
			cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "     AND DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += "     AND DT6_FILDOC = DUD_FILDOC "
			cQuery += "     AND DT6_DOC    = DUD_DOC "
			cQuery += "     AND DT6_SERIE  = DUD_SERIE "
			cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
			//-- Armazena a regiao destino da ultima sequencia da viagem.
			If (cAliasQry)->( !Eof() )
				If !Empty((cAliasQry)->DUD_CDRCAL)
					cCdrDes := (cAliasQry)->DUD_CDRCAL
				ElseIf !Empty((cAliasQry)->DT6_CDRCAL)
					cCdrDes := (cAliasQry)->DT6_CDRCAL
				Else
					cCdrDes := cCdrOri
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(DUD_VIAGEM) QTDDOC, SUM(DT6_VOLORI) DT6_VOLORI, SUM(DT6_PESO) DT6_PESO, SUM(DT6_PESOM3) DT6_PESOM3, "
	cQuery += "SUM(DT6_VALMER) DT6_VALMER, SUM(DT6_VALFRE) DT6_VALFRE, SUM(DT6_VALTOT) DT6_VALTOT, SUM(DT6_QTDUNI) DT6_QTDUNI, "
	cQuery += "MAX(DUD_TIPTRA) DUD_TIPTRA, MAX(DUD_SERTMS) DUD_SERTMS FROM "
	cQuery += RetSqlName("DT6")+" DT6 "
	cQuery += "JOIN " + RetSqlName("DUD")+ " DUD "
	cQuery += "ON DUD_FILIAL = '" +xFilial("DUD")+ "' "
	cQuery += "  AND DUD_FILDOC = DT6_FILDOC "
	cQuery += "  AND DUD_DOC    = DT6_DOC "
	cQuery += "  AND DUD_SERIE  = DT6_SERIE "
	cQuery += "  AND DUD_FILORI = '" +cFilOri+ "'"
	cQuery += "  AND DUD_VIAGEM = '" +cViagem+ "'"
	cQuery += "  AND DUD.D_E_L_E_T_ = ' '"
	cQuery += "WHERE DT6_FILIAL = '" +xFilial("DT6")+ "' "
	cQuery += "  AND DT6.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY DUD_FILIAL,DUD_FILORI,DUD_VIAGEM "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->QTDDOC > 0
		If !DFI->(MsSeek(xFilial("DFI")+cTpUso+cIdent))
			RecLock("DFI",.T.)
			DFI->DFI_FILIAL  := xFilial("DFI")
			DFI->DFI_IDENT   := cIdent
			DFI->DFI_TIPUSO  := cTpUso //Tipo de Uso = Viagem
		Else
			RecLock("DFI",.F.)
		EndIf
		DFI->DFI_QTDVOL  := (cAliasQry)->DT6_VOLORI
		DFI->DFI_PESO    := (cAliasQry)->DT6_PESO
		DFI->DFI_PESOM3  := (cAliasQry)->DT6_PESOM3
		DFI->DFI_VALMER  := (cAliasQry)->DT6_VALMER
		DFI->DFI_VALFRE  := (cAliasQry)->DT6_VALFRE
		DFI->DFI_VALTOT  := (cAliasQry)->DT6_VALTOT
		DFI->DFI_QTDUNI  := (cAliasQry)->DT6_QTDUNI
		DFI->DFI_QTDDOC  := (cAliasQry)->QTDDOC
		DFI->DFI_CDRORI  := cCdrOri
		DFI->DFI_CDRDES  := cCdrDes
		DFI->DFI_TIPTRA  := (cAliasQry)->DUD_TIPTRA
		DFI->DFI_SERTMS  := (cAliasQry)->DUD_SERTMS
		DFI->DFI_STATUS  := "1" //--Em Aberto
		DFI->(MsUnlock())
	EndIf
	(cAliasQry)->(DbCloseArea())
ElseIf nAcao == 3 //--Exclusao
	cQuery := "SELECT COUNT(DFI_IDENT) QTDREG, MAX(R_E_C_N_O_) RECNODFI FROM "
	cQuery += RetSqlName("DFI")+" DFI "
	cQuery += "WHERE DFI_FILIAL = '" +xFilial("DFI")+ "' "
	cQuery += "  AND DFI_TIPUSO = '" +cTpUso+ "'"
	cQuery += "  AND DFI_IDENT  = '" +cIdent+ "'"
	cQuery += "  AND DFI.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY DFI_FILIAL, DFI_TIPUSO, DFI_IDENT "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->QTDREG > 0
		nRecno := (cAliasQry)->RECNODFI
		DFI->(MsGoto(nRecno))
		RecLock("DFI",.F.)
		DFI->(DbDelete())
		DFI->(MsUnlock())
	EndIf
	(cAliasQry)->(DbCloseArea())
ElseIf nAcao == 4 //--Encerramento de Viagem

	cQuery := "SELECT DTQ_SERTMS, DTQ_DATFEC, DTQ_DATENC, DTQ_STATUS, DT6_CLIDES, DT6_LOJDES, DT6_PESO, DT6_QTDVOL, DUA_QTDOCO, "
	cQuery += "DUA_PESOCO, DT2_TIPOCO, DT2_RESOCO FROM "
	cQuery += RetSqlName("DTQ")+" DTQ "
	cQuery += " JOIN " + RetSqlName("DUD")+ " DUD "
	cQuery += "   ON DUD_FILIAL = '" +xFilial("DUD")+ "' "
	cQuery += "  AND DUD_FILORI = '" +cFilOri+ "'"
	cQuery += "  AND DUD_VIAGEM = '" +cViagem+ "'"
	cQuery += "  AND DUD.D_E_L_E_T_ = ' '"
	cQuery += " JOIN " + RetSqlName("DT6")+ " DT6 "
	cQuery += "   ON DT6_FILIAL = '" +xFilial("DT6")+ "' "
	cQuery += "  AND DT6_FILDOC = DUD_FILDOC "
	cQuery += "  AND DT6_DOC    = DUD_DOC "
	cQuery += "  AND DT6_SERIE  = DUD_SERIE "
	cQuery += "  AND DT6.D_E_L_E_T_ = ' '"
	cQuery += " JOIN " + RetSqlName("DUA")+ " DUA "
	cQuery += "   ON DUA_FILIAL = '" +xFilial("DUA")+ "' "
	cQuery += "  AND DUA_FILDOC = DUD_FILDOC "
	cQuery += "  AND DUA_DOC    = DUD_DOC "
	cQuery += "  AND DUA_SERIE  = DUD_SERIE "
	cQuery += "  AND DUA.D_E_L_E_T_ = ' '"
	cQuery += " JOIN " + RetSqlName("DT2")+ " DT2 "
	cQuery += "   ON DT2_FILIAL = '" +xFilial("DT2")+ "' "
	cQuery += "  AND DT2_CODOCO = DUA_CODOCO "
	cQuery += "  AND DT2.D_E_L_E_T_ = ' '"
	cQuery += "WHERE DTQ_FILIAL = '" +xFilial("DTQ")+ "' "
	cQuery += "  AND DTQ_FILORI = '" +cFilOri+ "'"
	cQuery += "  AND DTQ_VIAGEM = '" +cViagem+ "'"
	cQuery += "  AND DTQ.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	TCSetField(cAliasQry,"DTQ_DATFEC","D",8,0)
	TCSetField(cAliasQry,"DTQ_DATENC","D",8,0)

	If (cAliasQry)->(!Eof()) .And. DFI->(MsSeek(xFilial("DFI")+cTpUso+cIdent))
		RecLock("DFI",.F.)
		dDatIni  := (cAliasQry)->DTQ_DATFEC //--Fechamento da Viagem
		dDatFim  := (cAliasQry)->DTQ_DATENC //--Encerramento da Viagem
		dDatEnc  := (cAliasQry)->DTQ_DATENC //--Alimento nova varivel pois ao gravar o DFI a query ja foi fechada
		While (cAliasQry)->(!Eof())
			nCntQry += 1

			If (cAliasQry)->DTQ_SERTMS == StrZero(1, Len((cAliasQry)->DTQ_SERTMS)) .Or.;
				((cAliasQry)->DTQ_SERTMS == StrZero(3, Len((cAliasQry)->DTQ_SERTMS)))

				//-- Sera considerado Coleta e Entrega Efetuada se :
				//-- 1) A Ocorrencia for de 'Encerra Processo'.
				//-- 2) A Ocorrencia for de 'Retorno de Docto.', NAO sendo culpa do Motorista e o parametro MV_GERCONT == .T.

				//-- NAO sera considerado Coleta e Entrega efetuada se :
				//-- 1) A Ocorrencia for de 'Retorno de Docto.' sendo culpa do Motorista
				//-- 1) A Ocorrencia for de 'Retorno de Docto.', NAO sendo culpa do Motorista e o parametro MV_GERCONT == .F.

				If (cAliasQry)->DT2_TIPOCO == StrZero(1,Len((cAliasQry)->DT2_TIPOCO)) .Or. ;
					((cAliasQry)->DT2_TIPOCO == StrZero(4,Len((cAliasQry)->DT2_TIPOCO)).And.;
					(cAliasQry)->DT2_RESOCO <> '3' .And. lGerCont)

					//-- Armazena a qtde. de volumes original para verificar com a qtde. de volumes da ocorrencia
					nQtdOri += (cAliasQry)->DT6_QTDVOL
					//-- Obtem peso e volume dependendo do apontamento da ocorrencia se for por viagem ou docto.
					nPesOco += Iif(Empty((cAliasQry)->DUA_PESOCO),(cAliasQry)->DT6_PESO  ,(cAliasQry)->DUA_PESOCO)
					nQtdOco += Iif(Empty((cAliasQry)->DUA_QTDOCO),(cAliasQry)->DT6_QTDVOL,(cAliasQry)->DUA_QTDOCO)

					If (cAliasQry)->DTQ_SERTMS == StrZero(3,Len((cAliasQry)->DTQ_SERTMS)) //-- Entrega
						//-- A Quantidade de Entregas da viagem sera controlada de acordo com o Destinatario.
						//-- Ex: Se na mesma viagem, tiver varias entregas para o mesmo destinatario,
						//--     sera considerada 1 Entrega e sera' pago ao carreteiro o valor relativo
						//--     a 1 Entrega.
						nSeek := Ascan(aQtdEnt, { |x| x[1]+x[2] == (cAliasQry)->DT6_CLIDES+(cAliasQry)->DT6_LOJDES})
						If nSeek == 0
							AAdd(aQtdEnt, {(cAliasQry)->DT6_CLIDES,(cAliasQry)->DT6_LOJDES} )
							nQtdEnt += 1
						EndIf
					EndIf
				EndIf
			EndIf

			If nCntQry == 1 //So calcula da primeira vez
				If (cAliasQry)->DTQ_STATUS == StrZero(3,Len((cAliasQry)->DTQ_STATUS)) .And. !lKmDist
					//--Calculo da Quilometragem da Viagem
					//-- Se a Viagem Encerrada e o parametro MV_KMDIST não habilitado
					cQuery := "SELECT DUV_ODOVEI, DUV_CODVEI, DUV_DATA, DUV_HORA, DUV_TIPMOV FROM "
					cQuery += RetSqlName("DUV")+" DUV "
					cQuery += " JOIN " + RetSqlName("DA3")+ " DA3 "
					cQuery += "   ON DA3_FILIAL = '" +xFilial("DA3")+ "' "
					cQuery += "  AND DA3_COD = DUV_CODVEI "
					cQuery += "  AND DA3_FROVEI = '1' " //So veiculos proprios
					cQuery += "  AND DA3.D_E_L_E_T_ = ' ' "
					cQuery += "WHERE DUV_IDENT = '" +cIdent+ "' "
					cQuery += "  AND DUV_TIPUSO = '1' "
					cQuery += "  AND DUV.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY DUV_TIPUSO, DUV_IDENT, DUV_DATA, DUV_HORA "

					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

					While (cAliasNew)->(!Eof())
						nCnt += 1
						//O primeiro registro contem a primeira saida do veiculo
						If nCnt == 1 .And. (cAliasNew)->DUV_TIPMOV == "2" //--Saida
							nOdoSai := (cAliasNew)->DUV_ODOVEI
						EndIf
						//O ultimo registro contem a ultima entrada do veiculo
						If (cAliasNew)->DUV_TIPMOV == "1" //--Entrada
							nOdoEnt := (cAliasNew)->DUV_ODOVEI
						EndIf
						(cAliasNew)->(DbSkip())
					EndDo
					(cAliasNew)->(DbCloseArea())
					If nCnt > 0 //So efetua o calculo se encontrou DUV
						If nOdoEnt >= nOdoSai
							nKmVge += nOdoEnt - nOdoSai
						Else
							//-- Virada de Odometro
							nKmVge += 999999 - nOdoSai
							nKmVge += nOdoEnt
						EndIf
					EndIf
				Else
					If (cAliasQry)->DTQ_SERTMS <> StrZero(2, Len((cAliasQry)->DTQ_SERTMS))
						nKmVge := TMSDistRot(,.F.,DFI->DFI_CDRORI,DFI->DFI_CDRDES)
					Else
						nKmVge := TMSDistRot((cAliasQry)->DTQ_ROTA,.F.)
					EndIf
				EndIf
			EndIf
			(cAliasQry)->( DbSkip() )
		EndDo
		(cAliasQry)->(DbCloseArea())

		//--Calculo dos Dias da Semana e Finais de Semana
		If nCntQry == 1 //Calcula a diaria na primeira vez, pois a viagem nao muda
			Do While dDatIni <= dDatFim
				//-- Se for Sabado ou Domingo
				If Dow(dDatIni) == 7 .Or. Dow(dDatIni) == 1
					If Ascan(aDiaFimSem,Dtos(dDatIni) ) == 0
						Aadd(aDiaFimSem,Dtos(dDatIni) )
					EndIf
				Else
					If Ascan(aDiaSem,Dtos(dDatIni) ) == 0
						Aadd(aDiaSem,Dtos(dDatIni) )
					EndIf
				EndIf
				dDatIni += 1
			EndDo
		EndIf

		DFI->DFI_QTDIAS := Len(aDiaSem) 		//--Diarias de Semana
		DFI->DFI_QTFIMS := Len(aDiaFimSem) //--Diarias Final de Semana
		DFI->DFI_QTDENT := nQtdEnt 			//--Quantidade de Entregas
		DFI->DFI_VOLOCO := nQtdOco 			//--Volumes da Ocorrencia
		DFI->DFI_PESOCO := nPesOco 			//--Peso da Ocorrencia
		DFI->DFI_QTDKM  := nKmVge 				//--Quilometragem
		DFI->DFI_DATENC := dDatEnc 			//--Data de Encerramento
		DFI->DFI_STATUS := "2" 					//--Liberado
		DFI->(MsUnlock())

	EndIf

ElseIf nAcao == 5 //--Estorno do Encerramento
	//--Ao estornar o encerramento, limpar
	//--estes campos que foram totalizados no encerramento
	If DFI->(MsSeek(xFilial("DFI")+cTpUso+cIdent))
		RecLock("DFI",.F.)
		DFI->DFI_QTDIAS := 0
		DFI->DFI_QTFIMS := 0
		DFI->DFI_QTDENT := 0
		DFI->DFI_QTDKM  := 0
		DFI->DFI_VOLOCO := 0
		DFI->DFI_PESOCO := 0
		DFI->DFI_DATENC := Ctod('')
		DFI->DFI_STATUS := "1" //--Em Aberto
		DFI->(MsUnlock())
	EndIf
EndIf

RestArea(aAreaDFI)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsConsVc ³ Autor ³Eduardo Vicente        ³ Data ³ 03/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta a viagem ou carga dependendo do campo DG_TIPUSO.  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsConsVc() 	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMS/OMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TmsConsVc()

Local aArea			:= GetArea()
Local aBrowse		:= {}
Local aTitulo		:= {}
Local aOrdem		:= {}
Local oDlg			:= Nil
Local oBrowse		:= Nil
Local cSeek			:= Space(18)
Local oSeek			:= Nil
Local lExport		:= .F.
Local nSvRecBrw		:= 0
Local i				:= 0
Local oCol			:= Nil
Local oOrdem		:= Nil
Local cOrd			:= ""
Local oBtn1			:= Nil
Local oBtn2			:= Nil
Local cCampo		:= ""
Local bFiltraBrw	:= {||.T.}
Local cFiltro		:= ""
Local aIndex		:= {}
Local cCampoPsq		:= ReadVar()
Local oMdl070		:= NIL
Local cTabela		:= "DG"

If FwIsInCallStack("TMSA070")
	oMdl070	:= FwModelActive()
	cCampo	:= oMdl070:GetValue("MdGridSDG","DG_TIPUSO")
Else
	If 'DFO' $ cCampoPsq
		cTabela := 'DFO'
	ElseIf 'DFU' $ cCampoPsq
		cTabela	:= 'DFU'
	ElseIf 'DUV' $ cCampoPsq
		cTabela	:= 'DUV'
	ElseIf 'DUA' $ cCampoPsq
		cTabela	:= 'DUA'
	EndIf
	cCampo := GdFieldGet( cTabela + "_TIPUSO", n )
EndIf

If cCampo == '1' //Viagem

	dbSelectArea("DTQ")
	dbSetOrder(1)

	aAdd(aBrowse,{"DTQ_FILORI"})
	aAdd(aBrowse,{"DTQ_VIAGEM"})

	aAdd(aTitulo,{STR0074}) // Filial de Origem
	aAdd(aTitulo,{STR0075}) // Codigo da Viagem

	SIX->(msSeek("DTQ"))
	While SIX->(!EOF()) .And. SIX->INDICE == "DTQ"
		aAdd(aOrdem,SIX->CHAVE)
		SIX->(dbSkip())
	EndDo

Else // Carga

	dbSelectArea("DAK")
	dbSetOrder(1)

	//So trago as cargas que nao foi dado retorno nesta pesquisa
	bFiltraBrw := {|| FilBrowse("DAK",@aIndex,@cFiltro) }
	cFiltro := "DAK_FILIAL == '" + xFilial("DAK") + "' .And. "
	cFiltro += "DAK_ACECAR == '2' "

	CursorWait()
	Eval(bFiltraBrw)
	CursorArrow()

	aAdd(aBrowse,{"DAK_COD"})
	aAdd(aBrowse,{"DAK_SEQCAR"})

	aAdd(aTitulo,{STR0076}) //"Codigo da Carga"
	aAdd(aTitulo,{STR0077}) //"Sequencia da Carga"

	SIX->(msSeek("DAK"))
	While SIX->(!EOF()) .And. SIX->INDICE == "DAK"
		aAdd(aOrdem,SIX->CHAVE)
		SIX->(dbSkip())
	EndDo
EndIF

DEFINE MSDIALOG oDlg FROM  62,15 TO 310,460 TITLE OemToAnsi(STR0074) PIXEL

	oBrowse := VCBrowse():New(10,12,166,75,,,,oDlg,,,,{|| (cSeek := Space(18),oSeek:Refresh())},{ || lExport := .T., nSvRecBrw := Recno(), oDlg:End() }, , , , , , , , ,.T.)
	oBrowse := oBrowse:GetBrowse()

	For i:=1 To Len(aBrowse)
		oCol := TCColumn():New( OemToAnsi(aTitulo[i,1]), &("{ || "+aBrowse[i,1]+"}"),,,, "LEFT",, .F., .F.,,,, .F., )
		oBrowse:AddColumn(oCol)
	Next i

	@ 091, 14 SAY OemToAnsi(STR0079) SIZE 42, 7 OF oDlg PIXEL
	@ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlg PIXEL
	@ 104, 14 SAY OemToAnsi(STR0080) SIZE 32, 7 OF oDlg PIXEL
	@ 104, 58 MSGET oSeek VAR cSeek PICTURE "@!" SIZE 120, 10 OF oDlg PIXEL

	oSeek:bLostFocus := { || If ( MsSeek(AllTrim(oSeek:cText)), oBrowse:Refresh(),)}

	DEFINE SBUTTON oBtn1 FROM 09, 187 TYPE 1 ENABLE OF oDlg ACTION (lExport := .T., nSvRecBrw := Recno(), oDlg:End())
	DEFINE SBUTTON oBtn2 FROM 23, 187 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

	cSeek := &(ReadVar())

	If !Empty(cSeek)
		If !MsSeek(cSeek)
			MsGoto(nSvRecBrw)
		EndIf
	EndIf

	cSeek := Space(18)

ACTIVATE MSDIALOG oDlg

If cCampo  == "1"
	VAR_IXB	:= DTQ->DTQ_IDENT
Else
	If cCampoPsq == "M->DUA_CODCAR"
		VAR_IXB			:= DAK->DAK_COD
		M->DUA_SEQCAR	:= DAK->DAK_SEQCAR
		M->DUA_IDENT	:= DAK->DAK_IDENT
	Else
		VAR_IXB			:= DAK->DAK_IDENT
		M->DUA_CODCAR	:= DAK->DAK_COD
		M->DUA_SEQCAR	:= DAK->DAK_SEQCAR
	EndIf
	EndFilBrw("DAK",aIndex)
EndIf

RestArea(aArea)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTpTit  ³ Autor ³Katia                  ³ Data ³ 30/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Tipo do Titulo (E1_TIPO) com base no parametro      ³±±
±±³          ³MV_TMSTIPT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsTpPar()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMS/OMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsTpTit(cTipoParc)
Static cMvTMSTip   := SuperGetMV("MV_TMSTIPT",.F.,"")
Local nPosIni     := 0
Local nTamIni     := 0

Default cTipoParc := ''

If !Empty(cMvTMSTip)
	If (nPosIni := At(AllTrim(SF2->F2_SERIE)+"=",cMvTmsTip)) <> 0
		nPosIni += Len(AllTrim(SF2->F2_SERIE)+"=")
		If (nTamIni := At(";",Substr(cMvTMSTip,nPosIni)) - 1) <= 0
			nTamIni := Len(Alltrim(Substr(cMvTMSTip,nPosIni))) + 1
		EndIf
		cTipoParc := PadR(Substr(cMvTMSTip,nPosIni,nTamIni),Len(SE1->E1_TIPO))
	EndIf
EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSPRVENT ³ Autor ³ Andre Sperandio       ³ Data ³01.Jun.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela previsao de entrega                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TMSPRVENT(cAlaias,nReg,nOpc,aStruct,cTipTra,cCliDev,cLojDev,cCodOri,cCodDes)

Local oDlg
Local oTipTra
Local oCliDev
Local oLojDev
Local oCodOri
Local oCodDes
Local oDataIni
Local oBtn1
Local oBtn2
Local oBtn3
Local dDataIni  := dDataBase
Local cHoraIni  := StrTran(Left(Time(),5),':','')
Local dDataEnt1 := CtoD('  /  /  ')
Local dDataEnt2 := CtoD('  /  /  ')
Local lContinua := .T.
Local lCalcula  := .F.
Local aRetorno  := {}
Local dDataCal  := dDataBase
Local cHoraCal  := StrTran(Left(Time(),5),':','')
Local lTmsBut	:= ExistBlock("TMSBUTON",.F.)

Local lOfusca := .F.
Local lLGPD   := ExistFunc("FWPDCanUse") .And. FWPDCanUse(.T.)
Local oNomCli

Default cTipTra := Space(Len(DT4->DT4_TIPTRA))
Default cCliDev := Space(Len(DT4->DT4_CLIDEV))
Default cLojDev := Space(Len(DT4->DT4_LOJDEV))
Default cCodOri := Space(Len(DUY->DUY_GRPVEN))
Default cCodDes := Space(Len(DUY->DUY_GRPVEN))

Private cTipTrans := cTipTra

If lLGPD 
	If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0		
		lOfusca := .F.
	Else				
		lOfusca := .T.
	EndIf	
Else	
	lOfusca := .F.
EndIf

While lContinua
	DEFINE MSDIALOG oDlg FROM 000,000 TO 260,445 TITLE STR0088 PIXEL

	@ 002,004 TO 110,220 OF oDlg PIXEL
	//----------------------------------------------------------------------------------------------------------------
	@ 005,010 SAY STR0089 SIZE 70,10 OF oDlg PIXEL
	@ 005,050 MsGet oTipTra Var cTipTrans F3 "DLC" Picture PesqPict("DTD","DTD_TIPTRA");
	Valid If(lcontinua, lCalcula := TMSValField("cTipTrans",.T.), .T. )	SIZE 030,008 OF oDlg Pixel

	@ 005,090 SAY STR0090 SIZE 70,10 OF oDlg PIXEL
	@ 005,135 MsGet TMSValField("cTipTrans",.F.) SIZE 080,008 When .F. OF oDlg Pixel
	//----------------------------------------------------------------------------------------------------------------
	@ 020,010 SAY STR0091 SIZE 70,10 OF oDlg PIXEL
	@ 020,050 MsGet oCliDev Var cCliDev F3 "SA1" Picture PesqPict("DT4","DT4_CLIDEV");
	Valid( IIF(!Empty(cCliDev),ExistCpo("SA1",cCliDev),.T.) ) SIZE 030,008 OF oDlg Pixel

	@ 020,090 SAY STR0092 SIZE 70,10 OF oDlg PIXEL
	@ 020,135 MsGet oLojDev Var cLojDev Picture "@!";
	Valid( IIF(!Empty(cCliDev).and. !Empty(cLojDev),ExistCpo("SA1",cCliDev+cLojDev),.T.) ) SIZE 020,008 OF oDlg Pixel

	@ 035,010 SAY STR0093 SIZE 70,10 OF oDlg PIXEL
	If lLGPD
		@ 035,050 MsGet oNomCli Var RetCampo("SA1",1,xFilial("SA1") + cCliDev + cLojDev,"A1_NOME") Picture "@!" SIZE 165,008 When .F. OF oDlg Pixel Ofuscated lOfusca
	Else	
		@ 035,050 MsGet oNomCli Var RetCampo("SA1",1,xFilial("SA1") + cCliDev + cLojDev,"A1_NOME") Picture "@!" SIZE 165,008 When .F. OF oDlg Pixel
	EndIf
	
	//----------------------------------------------------------------------------------------------------------------
	@ 050,010 SAY STR0094 SIZE 70,10 OF oDlg PIXEL
	@ 050,050 MsGet oCodOri Var cCodOri F3 "DUY" Picture PesqPict("DUY","DUY_GRPVEN");
	Valid NaoVazio(AllTrim(cCodOri)) .and. ExistCpo("DUY",cCodOri) SIZE 030,008 OF oDlg Pixel

	@ 050,090 SAY STR0095 SIZE 70,10 OF oDlg PIXEL
	@ 050,135 MsGet POSICIONE("DUY",1,xFilial("DUY")+cCodOri,"DUY->DUY_DESCRI");
	Picture PesqPict("DUY","DUY_DESCRI") SIZE 080,008 When .F. OF oDlg Pixel
	//----------------------------------------------------------------------------------------------------------------
	@ 065,010 SAY STR0096 SIZE 70,10 OF oDlg PIXEL
	@ 065,050 MsGet oCodDes Var cCodDes F3 "DUY" Picture PesqPict("DUY", "DUY_GRPVEN");
	Valid NaoVazio(AllTrim(cCodDes)) .and. ExistCpo("DUY",cCodDes) SIZE 030,008 OF oDlg Pixel

	@ 065,090 SAY STR0097 SIZE 70,10 OF oDlg PIXEL
	@ 065,135 MsGet POSICIONE("DUY",1,xFilial("DUY")+cCodDes,"DUY->DUY_DESCRI");
	Picture PesqPict("DUY","DUY_DESCRI") SIZE 080,008 When .F. OF oDlg Pixel
	//----------------------------------------------------------------------------------------------------------------
	@ 080,010 SAY STR0098 SIZE 70,10 OF oDlg PIXEL
	@ 080,050 MSGET oDataIni Var dDataIni PICTURE	"@D" 	 SIZE 043,008 OF oDlg PIXEL

	@ 080,095 SAY STR0099 SIZE 70,10 OF oDlg PIXEL
	@ 080,135 MSGET cHoraIni PICTURE	"@R 99:99" SIZE 043,008 OF oDlg PIXEL
	//----------------------------------------------------------------------------------------------------------------
	@ 095,010 SAY STR0100 SIZE 70,10 OF oDlg PIXEL
	@ 095,050 MSGET dDataEnt1 PICTURE "@D" When .F. SIZE 043,008 OF oDlg PIXEL

	@ 095,095 SAY STR0101 SIZE 70,10 OF oDlg PIXEL
	@ 095,135 MSGET dDataEnt2 PICTURE "@D" When .F. SIZE 043,008 OF oDlg PIXEL

	oBtn1 := TBtnBmp2():New( 230,320,52,25,'s4wb064n',,,,{|| lCalcula := .T.,  oDlg:End()},oDlg,,,.T. )
	oBtn2 := TBtnBmp2():New( 230,380,52,25,'s4wb019n',,,,{|| lContinua := .F., oDlg:End()},oDlg,,,.T. )
	IF lTmsBut
		oBtn3 := TBtnBmp2():New( 230,260,52,25,'s4wb022n',,,,{|| lCalcula := .T., ExecBlock("TMSBUTON",.F.,.F.,),oDlg:End()},oDlg,,,.T. )
	EndIF

	ACTIVATE MSDIALOG oDlg CENTERED

	If lContinua .and. !lCalcula
		Exit
	EndIf

	If lCalcula
		dDataCal:= dDataIni
		cHoraCal:= cHoraIni

		//-- Calcula a Data de Coleta
		TMSA460PrvCol(@dDataCal, @cHoraCal, .T.)

		MsgRun(STR0102,STR0028,{|| CursorWait(), aRetorno := TmsTmpEntr( cTipTrans, cCodOri, cCodDes, cCliDev, cLojDev, dDataCal, cHoraCal ) ,CursorArrow()})
		If !Empty( aRetorno )
			//-- Calcula a data de entrega
			dDataEnt1:= dDataEnt2 := dDataCal
			SumDH( @dDataEnt1, cHoraCal, TmsHrToInt( aRetorno[ 1 ] ) )
			SumDH( @dDataEnt2, cHoraCal, TmsHrToInt( aRetorno[ 2 ] ) )
		EndIf
		lCalcula := .F.
	EndIf
EndDo

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NoAcentoCteºAutor  ³Microsiga          º Data ³  08/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por retirar caracteres especiais das     º±±
±±º          ³String                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NoAcentoCte(cMens)

Local cByte,ni
Local s1:= "áéíóú" + "ÁÉÍÓÚ" + "âêîôû" + "ÂÊÎÔÛ" + "äëïöü" + "ÄËÏÖÜ" + "àèìòù" + "ÀÈÌÒÙ"  + "ãõÃÕ" + "çÇ" + "<>&'" + '"'
Local s2:= "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cC" + "    " + " "
Local nPos:=0, nByte
Local cRet:=''

For ni := 1 To Len(cMens)
	cByte := Substr(cmens,ni,1)
 	nByte := ASC(cByte)
  	nPos  := At(cByte,s1)
   	If nPos > 0
    	cByte := Substr(s2,nPos,1)
    EndIf
    If nByte < 32 .Or. nByte > 125
    	cByte := " "
    EndIf
    cRet += cByte
Next
Return(AllTrim(cRet))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSSpedNFe³ Autor ³N3-DL/SUST             ³ Data ³01.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED - utilizada em personalizacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSSpedNFe(cIdEnt,cModalidade,cVersaoCTe,cAmbiente,cModelo,lUsaColab)
Local aArea       := GetArea()
Local aXML        := {}
Local cVersao     := ""
Local cVersaoDpec := ""
Local cMonitorSEF := ""
Local cSugestao   := ""
Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local nX          := 0
Local lOk         := .T.
Local lRet        := .T.
Local oWs
Local cVerTSS     := ""
Local cVersaoMDFE := ""

Default cModelo   := "57"   //CTE
Default lUsaColab := .F.

If TMSIsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := TMSGetIdEnt(lUsaColab)

	If !Empty(cIdEnt)
		If cModelo <> "58"  //MDFe
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem a versao do TSS - Totvs Services SPED                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWS := WsSpedCfgNFe():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk := oWs:CfgTSSVersao()
			If lOk
				cVerTSS:=oWs:cCfgTSSVersaoResult
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem o ambiente de execucao do Totvs Services SPED                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWS := WsSpedCfgNFe():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:nAmbiente  := 0
			oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk            := oWS:CFGAMBIENTE()
			cAmbiente      := oWS:cCfgAmbienteResult
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem a modalidade de execucao do Totvs Services SPED                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:nModalidade:= 0
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				If cVerTSS >= "2.11"
					oWS:cModelo   := "57"
				EndIf
				lOk            := oWS:CFGModalidade()
				cModalidade    := oWS:cCfgModalidadeResult
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem a versao de trabalho da NFe do Totvs Services SPED                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:cVersao    := "0.00"
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk            := oWS:CFGVersao()
				cVersao        := oWS:cCfgVersaoResult
			EndIf
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:cVersao    := "0.00"
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk            := oWS:CFGVersaoCTe()
				cVersaoCTe     := oWS:cCfgVersaoCTeResult
			EndIf
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:cVersao    := "0.00"
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk            := oWS:CFGVersaoDpec()
				cVersaoDpec	   := oWS:cCfgVersaoDpecResult
			EndIf
		Else
			oWS :=  WsSpedCfgNFe():New()
			oWS:cUSERTOKEN 		:= "TOTVS"
			oWS:cID_ENT    		:= cIdEnt
			oWS:nAmbienteMDFE  	:= 0 //Val(SubStr(cAmbiente,1,1))
			oWS:cVersaoMDFE 	:= "0.00"
			oWS:nModalidadeMDFE := 0
			oWS:cVERMDFELAYOUT  := "0.00"
			oWS:cVERMDFELAYEVEN := "0.00"
			oWS:nSEQLOTEMDFE  	:= 0
			oWS:cHORAVERAOMDFE  := '0'
			oWS:cHORARIOMDFE    := '0'
	   		oWS:_URL       		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
			oWS:cModelo   		:= cModelo
			lOk:= oWS:CFGMDFE()

			cAmbiente  := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
			cModalidade:= oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE
			cVersaoMDFE:= oWS:OWSCFGMDFERESULT:CVERSAOMDFE
			
			If cModalidade <> NIL
				cModalidade    := SubStr(cModalidade,1,1)
			Else
				cModalidade    := ""
			EndIf  
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o status na SEFAZ                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lOk
			oWS:= WSNFeSBRA():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
			lOk := oWS:MONITORSEFAZMODELO()
			If lOk
				aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
				For nX := 1 To Len(aXML)
					Do Case
						Case aXML[nX]:cModelo == "55"
							If cModelo <> "58"
								cMonitorSEF += "- NFe"+CRLF
								cMonitorSEF += "Versao do layout: "+cVersao+CRLF	//
								If !Empty(aXML[nX]:cSugestao)
									cSugestao += "Sugestão"+"(NFe)"+": "+aXML[nX]:cSugestao+CRLF //
								EndIf
							EndIf

						Case aXML[nX]:cModelo == "57"
								If cModelo <> "58"
									cMonitorSEF += "- CTe"+CRLF
									cMonitorSEF += "Versao do layout: "+cVersaoCTe+CRLF	//
									If !Empty(aXML[nX]:cSugestao)
										cSugestao += "Sugestão"+"(CTe)"+": "+aXML[nX]:cSugestao+CRLF //
									EndIf
								EndIf
						Case aXML[nX]:cModelo == "58"
							cMonitorSEF += "- MDFe"+CRLF
							cMonitorSEF += "Versao do layout: "+cVersaoMDFE+CRLF	//
							If !Empty(aXML[nX]:cSugestao)
								cSugestao += "Sugestão"+"(MDFe)"+": "+aXML[nX]:cSugestao+CRLF //
							EndIf
					EndCase
					cMonitorSEF += Space(6)+"Versão da mensagem"+": "+aXML[nX]:cVersaoMensagem+CRLF //
					cMonitorSEF += Space(6)+"Código do Status"+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //
					cMonitorSEF += Space(6)+"UF Origem"+": "+aXML[nX]:cUFOrigem //
					If !Empty(aXML[nX]:cUFResposta)
						cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF
					Else
						cMonitorSEF += CRLF
					EndIf
					If aXML[nX]:nTempoMedioSEF <> Nil
						cMonitorSEF += Space(6)+"Tempo de espera"+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF //
					EndIf
					If !Empty(aXML[nX]:cMotivo)
						cMonitorSEF += Space(6)+"Motivo"+": "+aXML[nX]:cMotivo+CRLF //
					EndIf
					If !Empty(aXML[nX]:cObservacao)
						cMonitorSEF += Space(6)+"Observação"+": "+aXML[nX]:cObservacao+CRLF //
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSGetIdEnt³ Autor ³N3-DL/SUST            ³ Data ³01.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSGetIdEnt(lUsaColab)

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs

Default lUsaColab  := .F.

If lUsaColab
	If !( ColCheckUpd() )
		Aviso("SPED","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{STR0114},3)
	Else
		cIdEnt := "000000"
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"},3)
	EndIf
EndIf

RestArea(aArea)
Return(cIdEnt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSIsReady³ Autor ³N3-DL/SUST             ³ Data ³01.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a conexao com a Totvs Sped Services pode ser    ³±±
±±³          ³estabelecida                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: URL do Totvs Services SPED                        OPC³±±
±±³          ³ExpN2: nTipo - 1 = Conexao ; 2 = Certificado             OPC³±±
±±³          ³ExpL3: Exibe help                                        OPC³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSIsReady(cURL,nTipo,lHelp)
Local nX       := 0
Local cHelp    := ""
Local oWS
Local lRetorno := .F.
DEFAULT nTipo := 1
DEFAULT lHelp := .T.
If !Empty(cURL)
	PutMV("MV_SPEDURL",cURL)
EndIf
SuperGetMv() //Limpa o cache de parametros - nao retirar
DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o servidor da Totvs esta no ar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWs := WsSpedCfgNFe():New()
oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
If oWs:CFGCONNECT()
	lRetorno := .T.
Else
	If lHelp
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf
	lRetorno := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o certificado digital ja foi transferido                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo <> 1 .And. lRetorno
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := TMSGetIdEnt()
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWs:CFGReady()
		lRetorno := .T.
	Else
		If nTipo == 3
			cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			If lHelp .And. !"003" $ cHelp
				Aviso("SPED",cHelp,{"Ok"},3)
				lRetorno := .F.
			EndIf
		Else
			lRetorno := .F.
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o certificado digital ja foi transferido                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 2 .And. lRetorno
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := TMSGetIdEnt()
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWs:CFGStatusCertificate()
		If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
			For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
				If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date()
					Aviso("SPED","O certificado digital irá vencer em: "+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{"Ok"},3) //
				EndIf
			Next nX
		EndIf
	EndIf
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSGetXML ³ Autor ³N3-DL/SUST             ³ Data ³01.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED - utilizada em personalizacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSGetXML(cIdEnt,aIdNFe,cModalidade,cModelo)
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local oWS
Local cRetorno   := ""
Local cProtocolo := ""
Local cRetDPEC   := ""
Local cProtDPEC  := ""
Local nX         := 0
Local nY         := 0
Local aRetorno   := {}
Local aResposta  := {}
Local aFalta     := {}
Local aExecute   := {}
Local nLenNFe
Local cDHRecbto  := ""
Local cDtHrRec   := ""
Local cDtHrRec1	 := ""
Local nDtHrRec1  := 0
Local dDtRecib	 :=	CToD("")
Local cVerTSS    := ""
Local lOK        := .T.

Default cModelo   := "57"  //CTE

Private oDHRecbto

If Empty(cModalidade)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem a versao do TSS - Totvs Services SPED                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oWS := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		lOk := oWs:CfgTSSVersao()
		If lOk
			cVerTSS:=oWs:cCfgTSSVersaoResult
		EndIf

		oWS := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt
		oWS:nModalidade:= 0
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If cVerTSS >= "2.11"
			oWS:cModelo   := "57"
		EndIf
		If oWS:CFGModalidade()
			cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
		Else
			cModalidade    := ""
		EndIf
EndIf
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
nLenNFe := Len(aIdNFe)
For nX := 1 To nLenNFe
	aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","","",CToD("")})
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nX][4]+aIdNfe[nX][5]
Next nX
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno     := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo   := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
			cDHRecbto    := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC  := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto := XmlParser(cDHRecbto,"","","")
				If cModelo == "58"  //MDFe
					cDtHrRec  := IIf(Type("oDHRecbto:_ProtMDFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtMDFE:_INFPROT:_DHRECBTO:TEXT,"")
				Else
					cDtHrRec  := IIf(Type("oDHRecbto:_ProtCTE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtCTE:_INFPROT:_DHRECBTO:TEXT,"")
				EndIf
				nDtHrRec1 := RAT("T",cDtHrRec)

				If nDtHrRec1 <> 0
					cDtHrRec1 := SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib  := SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				If cModelo <> "58"
					dbSelectArea("SF2")
					dbSetOrder(1)
					If MsSeek(xFilial("SF2")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
						If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
							RecLock("SF2")
							SF2->F2_HORA := cDtHrRec1
							MsUnlock()
						EndIf
					EndIf
					dbSelectArea("SF1")
					dbSetOrder(1)
					If MsSeek(xFilial("SF1")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
						If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
							RecLock("SF1")
							SF1->F1_HORA := cDtHrRec1
							MsUnlock()
						EndIf
					EndIf
				EndIf
			EndIf
			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib

				aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
		For nX := 1 To Len(aIdNfe)
			If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
				aadd(aFalta,aIdNfe[nX])
			EndIf
		Next nX
		If Len(aFalta)>0
			aExecute := TMSGetXML(cIdEnt,aFalta,@cModalidade,cModelo)
		Else
			aExecute := {}
		EndIf
		For nX := 1 To Len(aExecute)
			nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
			If nY == 0
				aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
			Else
				aRetorno[nY][01] := aExecute[nX][01]
				aRetorno[nY][02] := aExecute[nX][02]
			EndIf
		Next nX
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf
Return(aRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TmsLeLinha³ Autor ³N3-DL/SUST             ³ Data ³15.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Usado para ler linhas do arquivo texto                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Handle do arquivo texto                              ³±±
±±³          ³ExpC1: Texto retornado                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TmsLeLinha( nHdl, cRet )
Local cBuff := " "
cRet  := ""

While FRead( nHdl, @cBuff, 1 ) > 0 .And. cBuff <> Chr(13)
	cRet += cBuff
EndDo

// O chr(13) ja foi ignorado. agora ignora o Chr(10)
FRead( nHdl, @cBuff, 1 )

Return Len(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSChkVer ºAutor  ³ Richard Anderson   º Data ³  02/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica versao do Protheus                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ TMSChkVer(cVersao,cRelease)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Versao que deseja verificar o uso                  ³±±
±±³          ³ ExpC2 = Release que deseja verificar o uso                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Lógico (Está ou não habilitado para a versão e release     ³±±
±±³          ³ informados)                                                ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSChkVer(cVersao,cRelease)

Local   lRet     := .T.
Local   cVerAtu  := GetVersao(.F.)
Default cVersao  := ''
Default cRelease := ''

If !Empty(cVersao)
	lRet := (cVerAtu >= cVersao)
	If lRet .And. !Empty(cRelease) .And. cVerAtu == cVersao
		lRet := (GetRpoRelease() >= cRelease)
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSViewPreºAutor  ³ Richard Anderson   º Data ³  02/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza Pre-Alertas de Embarque Aereo                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ TMSViewPre(cNumAWB,cDigAWB,cCodCia,cLojCia)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = No.AWB                                             ³±±
±±³          ³ ExpC2 = Digito da AWB                                      ³±±
±±³          ³ ExpC3 = Codigo da Companhia Aerea                          ³±±
±±³          ³ ExpC4 = Loja da Companhia Aerea                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSViewPre(cNumAWB,cDigAWB,cCodCia,cLojCia)

Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local cCadastro   := STR0106 //"Pré-alertas gerados"
Local aNewButton  := {}
Local lCancel     := .T.
Local aRetBox     := {}
Local aTitulo     := {}
Local lKeyOff     := .F.
Local lExistAWB   := (Type('M->DTV_NUMAWB') == 'C')

Private aItensPre := {}

Default cNumAWB   := Iif(lExistAWB,M->DTV_NUMAWB,'')
Default cDigAWB   := Iif(lExistAWB,M->DTV_DIGAWB,'')
Default cCodCia   := Iif(lExistAWB,M->DTV_CODCIA,'')
Default cLojCia   := Iif(lExistAWB,M->DTV_LOJCIA,'')

If Type('aSetKey') == 'A'
	//-- Zera Teclas de Atalhos
	TmsKeyOff(aSetKey)
	lKeyOff := .T.
EndIf

If !Empty(cNumAWB)
	cQuery := "SELECT *"
	cQuery += "  FROM "+RetSqlName("DY8") + " DY8 "
	cQuery += " WHERE DY8_FILIAL = '" + xFilial("DY8") + "'"
	cQuery += "   AND DY8_NUMAWB = '" + cNumAWB + "'"
	cQuery += "   AND DY8_DIGAWB = '" + cDigAWB + "'"
	cQuery += "   AND DY8_CODCIA = '" + cCodCia + "'"
	cQuery += "   AND DY8_LOJCIA = '" + cLojCia + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	aRetBox := RetSx3Box( Posicione('SX3', 2, 'DY8_STATUS', 'X3CBox()' ),,, Len(DY8->DY8_STATUS) )

	While (cAliasQry)->(!Eof())
		Aadd(aItensPre,{ (cAliasQry)->DY8_NUMPRE,;
							AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == (cAliasQry)->DY8_STATUS} ), 3 ]),;
							(cAliasQry)->DY8_NUMOCO,;
							DTOC(STOD((cAliasQry)->DY8_DATPRE)),;
							TRANSFORM((cAliasQry)->DY8_HORPRE,"@R 99:99"),;
							(cAliasQry)->DY8_CODCIA,;
							(cAliasQry)->DY8_LOJCIA,;
							Posicione("SA2",1,xFilial("SA2")+(cAliasQry)->DY8_CODCIA+(cAliasQry)->DY8_LOJCIA,'A2_NOME') } )
							(cAliasQry)->(dbSkip())
	EndDo

	If Len(aItensPre) > 0
		Aadd( aTitulo, RetTitle('DY8_NUMPRE') )
		Aadd( aTitulo, RetTitle('DY8_STATUS') )
		Aadd( aTitulo, RetTitle('DY8_NUMOCO') )
		Aadd( aTitulo, RetTitle('DY8_DATPRE') )
		Aadd( aTitulo, RetTitle('DY8_HORPRE') )
		Aadd( aTitulo, RetTitle('DY8_CODCIA') )
		Aadd( aTitulo, RetTitle('DY8_LOJCIA') )
		Aadd( aTitulo, RetTitle('DY8_NOMCIA') )
		aCabec := AClone(aTitulo)

		//-- Botão de visualização de observações
		AAdd(aNewButton, {14,{|nAt| TMSVObsPre(aItensPre[nAt,1]) } } )

		TmsF3Array( aTitulo, aItensPre, cCadastro, lCancel, aNewButton, aCabec )
	Else
		MsgAlert(STR0107+cNumAWB+'-'+cDigAWB)
	EndIf
EndIf

If lKeyOff
	//-- retorna Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSVObsPreºAutor  ³ Gustavo Almeida    º Data ³  03/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza Observações de Pre-Alertas de Embarque Aereo     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ TMSVObsPre(cNumPre)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = No.Pre Alerta                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSVObsPre(cNumPre)

Local cObserv   := ""
Local cTitulo   := STR0108+cNumPre //"Observações do Pre-Alerta: "
Local oDlgObs

Default cNumPre := ""

DY8->(dbSetOrder(1))
DY8->(MsSeek(xFilial('DY8')+cNumPre))

cObserv :=	E_MSMM(DY8->DY8_CODOBS,80)

DEFINE MSDIALOG oDlgObs TITLE cTitulo FROM 15,20 TO 25,62

	@ 0.5,0.7  GET oGet VAR cObserv OF oDlgObs MEMO size 150,40 WHEN .F.

	DEFINE SBUTTON FROM 52,128 TYPE 1 ACTION (oDlgObs:End()) ENABLE OF oDlgObs

ACTIVATE MSDIALOG oDlgObs CENTERED

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSQuitac ³ Autor ³                       ³ Data ³ 03.Nov.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a Quitacao do Contrato                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSQuitac(cExpC1, cExpC2, cExpC3, aExpA1)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 = Codigo da Operadora de Frotas                     ³±±
±±³          ³ cExpC2 = Filial de Origem                                  ³±±
±±³          ³ cExpC3 = Numero da Viagem                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSQuitac( cCodOpe, cFilOri, cViagem, aQuitacao)

Local aArea      := GetArea()
Local aAreaDTW   := {}
Local aArea1     := {}
Local aArea2	 := {}
Local lRet       := .F.
Local aCab       := {}
Local aItens     := {}
Local cQuery     := ''
Local cAliasNew  := ''
Local nSeq       := 0
Local cOcoEnt    := PadR(GetMV("MV_OCORENT",.F.,""),Len(DT2->DT2_CODOCO)) //Codigo de ocorrencia de Encerra Processo de Entrega
Local cOcor      := GetMV("MV_OCORCOL")   //Armazena a(s) ocorrencia(s) contida(s) no parametro MV_OCORCOL, para apontamento da coleta.
Local cOcoCol    := ''
Local nCnt       := 0
Local cVar       := ''
Local dDtQuit    := ''
Local cHrQuit    := ''
Local cCodVei	:= ''
Local aContr	:= {}
Local cseek		:= ''
Local cDesSald  := SuperGetMV( 'MV_DESSALD',, '')
Local cDesAdf   := SuperGetMV( 'MV_DESADF',, '' )
Local lCentury	:= __SetCentury()
Local cIdOpe    := ''
Local cCodACe   := ''
Local cUrl      := ''
Local cBanco	:= ''
Local cAgencia  := ''
Local cNumCon	:= ''
Local dDtPrv 	:= ''
Local lRepom	:= SuperGetMV( 'MV_VSREPOM',, '1' ) $ '2|2.2'
Local lEnc      := .F.
Local aAreaSDG  := {}
Local nSeek     := 0
Local dDtEnt    := ''
Local cHrEnt    := ''
Local lGravaOco := .T.

Private lMSErroAuto := .F.
Private lWserver	:= .T.

If cCodOpe == '01' //-- REPOM Tecnologia
	If lRestRepom
		//--- Chamada pelo WebService wstmse65.prw
		MsgAlert("Função TMSQuitac() inativa para a versao 2.2!")
		RestArea(aArea)
		Return .F.
	EndIf

	nModulo:= 43
	DEG->(DbSetOrder(1))
	If DEG->(MsSeek(xFilial('DEG') + cCodOpe))

		cIdOpe    := DEG->DEG_IDOPE
		cCodACe   := DEG->DEG_CODACE
		cUrl      := DEG->DEG_URLWS
		cBanco    := DEG->DEG_BANCO
		cAgencia  := DEG->DEG_AGENCI
		cNumCon   := DEG->DEG_NUMCON

		cHrQuit  := AllTrim(StrTran(Left(aQuitacao[1,3] ,5),":",""))
		If !lCentury .And. Len(aQuitacao[1,2]) >= 8
	   		SET CENTURY ON
	   		dDtQuit	:= CtoD(aQuitacao[1,2])
	   		dDtPrv	:= CtoD(aQuitacao[1,8])
	   		SET CENTURY OFF
		EndIf

		DTQ->(dbSetOrder(2))    //-- Verifica se a viagem existe
		If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem ))
			lEnc:= DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS))
			lRet:= .T.
		EndIf

		//-- Verifica se existe registro de quitacao (DES - Quitacao de Contrato) e nao esta quitada ainda (STATUS)
		If lRet .And. !lEnc
			aArea2 := GetArea()
			cAliasNew := GetNextAlias()
			cQuery := " SELECT DES_VIAGEM "
			cQuery += " FROM " + RetSqlName("DES")
			cQuery += " WHERE "
			cQuery += " DES_FILIAL = '" + xFilial("DES") + "'"
			cQuery += " AND DES_FILORI = '" + cFilOri + "'"
			cQuery += " AND DES_VIAGEM = '" + cViagem + "'"
			cQuery += " AND DES_STATUS <> '2' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
			If (cAliasNew)->( Eof() )
				lRet  := .F.
			EndIf

			(cAliasNew)->( DbCloseArea() )
			RestArea( aArea2 )
		EndIf

		TmsLogMsg(,str(threadid()) + 'Inicio TMSXFUNC')
		TmsLogMsg(,VarInfo("Viagem: ",cFilOri + '-' + cViagem,,.f.))

		DTY->(DbSetOrder(2)) //-- Se os docto foram entregues na filial, apenas finaliza a viagem e gera o titulo
		If  DTY->(MsSeek(xFilial("DTY")+cFilOri+cViagem)) .And. lRepom
	 		//-- vetor aContr eh enviado para o TMSA251PRC para localizar o contrato em questao
			AAdd(aContr, DTY->DTY_NUMCTC)
			AAdd(aContr, DTY->DTY_CODFOR)
			AAdd(aContr, DTY->DTY_LOJFOR)
			AAdd(aContr, cFilOri)
			AAdd(aContr, cViagem)
			cCodVei := DTY->DTY_CODVEI
	    EndIf

		If lRet
			TmsLogMsg(,str(threadid()) + 'Processando TMSXFUNC')
			//Preenche o vetor aOcorCol com as ocorrencias contidas no parametro MV_OCORCOL separadas por '/', cujo
			//tipo de servico seja igual a coleta e o tipo da ocorrencia seja "Encerra Processo"
			If DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))
				For nCnt:=1 To Len(cOcor)
					If !(Subs(cOcor,nCnt,1)=="/") .And. nCnt!= Len(cOcor)
						cVar+= Subs(cOcor,nCnt,1)
					Else
						If nCnt==Len(cOcor)
							cVar+=Subs(cOcor,nCnt,1)
						Endif
						DT2->(dbSetOrder(1))
						If DT2->(MsSeek(xFilial("DT2") + cVar))
							If DT2->DT2_SERTMS == StrZero(1, Len(DT2->DT2_SERTMS)) .And. DT2->DT2_TIPOCO == '01'
								cOcoCol:= DT2->DT2_CODOCO
								Exit
							EndIf
						EndIf
						cVar:=""
					Endif
				Next

				If Empty(cOcoCol)
					lRet:= .F.
				EndIf

			ElseIf DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS))
				lRet:= .F.

			ElseIf DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS))
				If Empty(cOcoEnt)
					lRet:= .F.
				EndIf
			EndIf

			If !lRet
				Return( lRet )
			EndIf


			If !lEnc
				TmsLogMsg(,str(threadid()) + 'Chamada TMSA310GRV')
				//----------- 1- FECHAMENTO DA VIAGEM

				TMSA310Grv (3 , .T. , .F. , dDtQuit , cHrQuit) //(nOpcx,lFecAuto,lHelpAuto,dDatFec,cHorFec)

				//----------- 2- APONTAMENTO DAS OPERACOES

				aAreaDTW := DTW->(GetArea())
				DTW->(dbSetOrder(1))
				If DTW->(MsSeek(cSeek:=xFilial("DTW") + cFilOri + cViagem ))
					Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) == cSeek
						If DTW->DTW_STATUS == StrZero(1,Len(DTW->DTW_STATUS))
							lGrvOk := TMSA350Grv(3, DTW->DTW_FILORI, DTW->DTW_VIAGEM, DTW->DTW_ATIVID, dDtQuit, cHrQuit, dDataBase, StrTran(Left(Time(),5),":",""))
						EndIf
						DTW->(dbSkip())
					EndDo
				EndIf
				RestArea( aAreaDTW )


				//------------ 3- APONTAMENTO DA OCORRENCIA ENCERRA PROCESSO

				//--Cabecalho da Ocorrencia
				Aadd(aCab,{"DUA_FILORI", cFilOri, NIL})
				Aadd(aCab,{"DUA_VIAGEM", cViagem, NIL})

				aArea1	   := GetArea()

				//--Itens da ocorrencia:
				cAliasNew := GetNextAlias()
				cQuery := " SELECT DUD_STATUS,DUD_FILDOC,DUD_DOC,DUD_SERIE,"
				cQuery += " DT6_QTDVOL,DT6_PESO, DT6_VOLORI "
				cQuery += " FROM " + RetSqlName("DUD") + " DUD JOIN " + RetSqlName("DT6") + " DT6 ON"
				cQuery += " DUD_FILDOC = DT6_FILDOC AND "
				cQuery += " DUD_DOC    = DT6_DOC    AND "
				cQuery += " DUD_SERIE  = DT6_SERIE AND"
				cQuery += " DT6.D_E_L_E_T_ = ' ' "
				cQuery += " WHERE "
				cQuery += " DUD_FILIAL = '" + xFilial("DUD") + "'"
				cQuery += " AND DUD_FILORI = '" + cFilOri + "'"
				cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
				cQuery += " AND DUD_STATUS <> '4' AND DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )

				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
				While (cAliasNew)->( !Eof() )
					dDtEnt   := ""
					cHrEnt   := ""
					lGravaOco:= .T.

					If DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS))
		              	DT2->(dbSetOrder(1))
						If DT2->(MsSeek(xFilial("DT2") + cOcoEnt)) .And. DT2->DT2_CATOCO == StrZero(1, Len(DT2->DT2_CATOCO))  //Por Docto
		    	            If Len(aQuitacao[1][12]) > 0
        			        	nSeek := Ascan(aQuitacao[1][12], {|x| x[1]+x[2]+x[3] == AllTrim((cAliasNew)->DUD_FILDOC) + AllTrim((cAliasNew)->DUD_DOC) + AllTrim((cAliasNew)->DUD_SERIE) })
								If nSeek > 0
									If !lCentury
										SET CENTURY ON
										dDtEnt := CtoD(aQuitacao[1][12][nSeek][4])
										SET CENTURY OFF
									Else
										dDtEnt := aQuitacao[1][12][nSeek][4]
									EndIf
									cHrEnt := AllTrim(StrTran(Left(aQuitacao[1][12][nSeek][5] ,5),":",""))

									If Empty(dDtEnt) .Or. Empty(cHrEnt)
										lGravaOco:= .F.
									EndIf
								Else
									lGravaOco:= .F.
								EndIf
							EndIf
						EndIf
					EndIf
					If lGravaOco
						nSeq+= 1
						aAdd( aItens, {	{"DUA_SEQOCO", StrZero(nSeq,Len(DUA->DUA_SEQOCO)), NIL},;
										{"DUA_DATOCO", Iif(!Empty(dDtEnt),dDtEnt,dDtQuit), NIL},;    //dDatabase
										{"DUA_HOROCO", Iif(!Empty(cHrEnt),cHrEnt,cHrQuit), NIL},;    //StrTran(SubStr(Time(),1,5),":","")
										{"DUA_CODOCO", Iif(DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)),cOcoCol,cOcoEnt), NIL},;
										{"DUA_FILDOC", (cAliasNew)->DUD_FILDOC,            NIL},;
										{"DUA_DOC"   , (cAliasNew)->DUD_DOC,               NIL},;
										{"DUA_SERIE" , (cAliasNew)->DUD_SERIE,             NIL},;
										{"DUA_QTDOCO", (cAliasNew)->DT6_QTDVOL,            NIL},;
										{"DUA_PESO"  , (cAliasNew)->DT6_PESO,              NIL},;
										{"DUA_PESOCO", (cAliasNew)->DT6_PESO,              NIL},;
										{"DUA_FILVTR", ""	,                              NIL},;
										{"DUA_NUMVTR", ""	,                              NIL}})
        	        EndIf

					(cAliasNew)->( DbSkip() )
				EndDo

				(cAliasNew)->( DbCloseArea() )
				RestArea( aArea1 )

				lMsErroAuto := .F.
				If !Empty(aCab) .And. !Empty(aItens)
					lRet := TMSA360(aCab,aItens,,3)	 //-- Apontando Ocorrencias
					// chamada da rotina de apontamentos sem execauto. Chamado por parametros

					If lMSErroAuto
						lRet:= .F.
						TmsLogMsg(,str(threadid()) + 'Retorno TMSA360 lMSErroAuto')
					Else
						lRet:= .T.
						//--------- 4- ENCERRAMENTO DA VIAGEM
						TMSA340Grv(.T.)
					EndIf
				EndIf
            EndIf

			//-- registra na tabela quitacao de contrato
			DES->(DbSetOrder(1))
			If DES->(MsSeek(xFilial('DES') + cFilOri + cViagem))
				RecLock('DES',.F.)
				DES->DES_FILORI := cFilOri
				DES->DES_VIAGEM := cViagem
		   		DES->DES_DATQTC := dDtQuit
		   		DES->DES_DATPRV := dDtPrv
				DES->DES_HORQTC := cHrQuit
				DES->DES_VALSAQ := Val(aQuitacao[1,4])
				DES->DES_VALCON := Val(aQuitacao[1,5])
				DES->DES_SALPAG := Val(aQuitacao[1,6])
				DES->DES_STATUS := '2' //-- Quitacao Realizada
				MsUnLock()
			EndIf

			If lRepom .And. !Empty(cDesAdf)
				//-- Gerar e baixar abastecimento e saque no SDG
				cQuery :=  ""
				cQuery += "SELECT DG_FILIAL, DG_FILORI, DG_VIAGEM, DG_CODVEI, DG_CODDES, DG_IDENT, DG_NUMSEQ, DG_SALDO  "
				cQuery += " FROM " + RetSqlName("SDG")
				cQuery += " WHERE DG_FILIAL = '" + xFilial('SDG') + "'"
				cQuery += " AND DG_FILORI = '"   + cFilOri + "'"
				cQuery += " AND DG_VIAGEM = '"   + cViagem + "'"
				cQuery += " AND DG_CODVEI = '"   + cCodVei + "'"
				cQuery += " AND DG_CODDES = '"   + cDesAdf + "'"
				cQuery += " AND D_E_L_E_T_ = ' '  "
				cAliasQry := GetNextAlias()
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				While !(cAliasQry)->(EoF()) .And. (cAliasQry)->DG_SALDO > 0
					TMSA070Bx("1",(cAliasQry)->DG_NUMSEQ,cFilOri,cViagem,cCodVei,,,(cAliasQry)->DG_SALDO,,(cAliasQry)->DG_IDENT)
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())

				//-- Gerar SDG de Saldo
				If !Empty(cDesSald) .And.  Val(aQuitacao[1,6]) > 0
					DbSelectArea('SDG') //-- NAO RETIRAR
					aAreaSDG := SDG->(GetArea())
					TMA250GrvSDG('SDG', cFilOri, cViagem, cDesSald,  Val(aQuitacao[1,6]),,cCodVei,,,,,,,,.T., cBanco, cAgencia, cNumCon,,,,"TMSXFUNC","2")
					RestArea(aAreaSDG)
				EndIF
			EndIf

			//verificar se eh pessoa fisica para calcular os impostos
			If TmsXPess(cFilOri, cViagem, cCodVei) == 'F'
				aMovtos := TmsMovRep( cIdOpe, cCodACe, cUrl, cFilOri, , cFilOri+cViagem ) //-- Consulta contrato (Repom) trazendo os impostos
				If !Empty(aMovtos)
					TmsxInImp(cFilOri, cViagem, aMovtos, .T.)	//-- Inclui impostos
				EndIf
			EndIf

			If !Empty(aContr)
		        TMSA251Prc('1',lWserver,aContr,.T.)
			EndIf

			TmsxBxCc(cFilOri,cViagem)
			lWserver := nil		   			   			// mata variavel private
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSOutImp ³ Autor ³Guilherme R. Gaiofatto ³ Data ³ 30/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apresenta tela para escolha de a Lista de Impostos da Oper  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSOutImp()

Local aArea   := GetArea()
Local lOk     := .T.
Local nCont	  :=  0
Local cCodMov := &(ReadVar())
Local aOutImp := {	{"1  ","IRRF"},;
{"2  ","SEST"},;
{"100","INSS"},;
{"112","ISS" },;
{"122","CSLL"},;
{"124","PIS" },;
{"126","COFINS"};
}
If M->DEM_CODOPE == '01'
	For nCont := 1 to len(aOutImp)
		If cCodMov == aOutImp[nCont][1]
			lOk := .F.
			Help(' ',1,'TMSXDEM')	//	'Entre em contato com a operadora para verificar a validade do código.')
		Endif
	Next
EndIf

RestArea(aArea)
Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    TMSXBXCC   ³ Autor ³Guilherme R. Gaiofatto ³ Data ³ 30/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Baixa dos titulos a pagar									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1:= Codigo da Filial de Origem                         ³±±
±±³          ³cExpC2:= Codigo da Viagem                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsxBxCc(cFilOri,cViagem,lJob)

Local aArea		:= GetArea()
Local aAreaE2	:= SE2->(GetArea())
Local aAreaDTY	:= DTY->(GetArea())
Local aBaixa	:= {}
Local cCodForn	:= ''
Local cLojForn	:= ''
Local cContr	:= ''
Local nSaldo    := 0
Local cPrefix	:= ''
Local cCodOpe	:= ''
Local cBanco	:= ''
Local cAgencia	:= ''
Local cConta	:= ''
Local cNumSeq	:= ''
Local cCodVei	:= ''
Local nValBx	:= 0
Local cParcela	:= ''
Local cDesCtc  := SuperGetMV( 'MV_DESCTC',, '')
Local cDesAdf  := SuperGetMV( 'MV_DESADF' ,,'')
Local cAdNumSeq  := ''
Local nAdValCob  := 0
Local cTipCTC    := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro

Default lJob		:= .F. 

Private lMSErroAuto := .F.
Private lWServer	:= .T.    //-- Utilizada para nao chamar a funcao GetMark()

cPrefix := TMA250GerPrf(cFilOri)
//-- Se o parametro MV_TPTCTC nao estiver preenchido
If Empty(cTipCTC)
	cTipCTC := Padr( "C"+cFilAnt, Len( SE2->E2_TIPO ) ) // Tipo Contrato de Carreteiro
EndIf

begin transaction

DTY->(DbSetorder(2))
If DTY->(MsSeek(xFilial("DTY")+cFilOri+cViagem))
	cCodForn := DTY->DTY_CODFOR
	cLojForn := DTY->DTY_LOJFOR
	cContr	 := DTY->DTY_NUMCTC
	cCodOpe  := DTY->DTY_CODOPE

	Reclock("DTY",.F.)
	DTY->DTY_STATUS := '5'
	MsUnlock()
EndIf

DEG->(DbSetOrder(1))
If DEG->(MsSeek(xFilial("DEG")+cCodOpe))
	cBanco  	:= DEG->DEG_BANCO
	cAgencia 	:= DEG->DEG_AGENCI
	cConta		:= DEG->DEG_NUMCON
EndIf

SDG->(DbSetOrder(5))             //-- numero da sequencia para baixa
SDG->( DbSeek( xFilial('SDG') + cFilOri + cViagem) )
While SDG->(!Eof()) .And. SDG->DG_FILIAL == xFilial('SDG') .And. SDG->DG_FILORI == cFilOri .And. SDG->DG_VIAGEM == cViagem
	If AllTrim(SDG->DG_CODDES) == AllTrim(cDesAdf)
		cAdNumSeq := SDG->DG_NUMSEQ
		nAdValCob := SDG->DG_VALCOB
		cCodVei	  := SDG->DG_CODVEI
	EndIF
	If AllTrim(SDG->DG_CODDES) == AllTrim(cDesCtc)
		cNumSeq  := SDG->DG_NUMSEQ
		cCodVei	 := SDG->DG_CODVEI
   		nValBx	 := SDG->DG_VALCOB
	EndIF
SDG->(dbSkip())
Enddo

cParcela := StrZero(1, Len(SE2->E2_PARCELA))

SE2->(DbSetOrder(1))   //-- saldo para baixa
If SE2->(MsSeek(xFilial('SE2')+cPrefix+cContr+cParcela+cTipCTC+cCodForn+cLojForn))
	nSaldo  := SE2->E2_SALDO
EndIf

//baixa o titulo do contrato
TMSA070Bx('1',cNumSeq,cFilOri,cViagem,cCodVei,dDatabase,'1',nValBx)

//baixa o titulo do adiantamento
TMSA070Bx('1',cAdNumSeq,cFilOri,cViagem,cCodVei,dDatabase,'1',nAdValCob)

DbSelectArea("SE2")
AADD(aBaixa , {"E2_FILIAL"  , cFilOri              	,Nil})
AADD(aBaixa , {"E2_PREFIXO" , cPrefix           	,Nil})
AADD(aBaixa , {"E2_NUM"     , cContr 				,Nil})
AADD(aBaixa , {"E2_PARCELA" , cParcela         		,Nil})
AADD(aBaixa , {"E2_TIPO"    , cTipCTC				,Nil})
AADD(aBaixa , {"E2_FORNECE" , cCodForn          	,Nil})
AADD(aBaixa , {"E2_LOJA"    , cLojForn           	,Nil})
AADD(aBaixa , {"AUTBANCO"	, cBanco             	,Nil})
AADD(aBaixa , {"AUTAGENCIA" , cAgencia           	,Nil})
AADD(aBaixa , {"AUTCONTA"	, cConta           		,Nil})
AADD(aBaixa , {"AUTMOTBX"	, "DEBITO CC"          	,Nil})
AADD(aBaixa , {"AUTDTBAIXA" , dDataBase            	,Nil})
AADD(aBaixa , {"AUTHIST"	, 'Baixa via WS' 		,Nil})
AADD(aBaixa , {"AUTDESCONT" , 0                   	,Nil})
AADD(aBaixa , {"AUTMULTA"   , 0                   	,Nil})
AADD(aBaixa , {"AUTJUROS"   , 0                   	,Nil})
AADD(aBaixa , {"AUTVLRPG"   , nSaldo          		,Nil})
AADD(aBaixa , {"AUTVLRME"   , 0                   	,Nil})

//-- Executa a Baixa do Titulo
If lJob
	MsExecAuto({|x,y| FINA080(x, y)},aBaixa,3)
Else 
	FINA080(aBaixa, 3)
EndIf 

If lMSErroAuto
	//MostraErro()
	DisarmTransaction()
Endif

End Transaction

lWServer	:= Nil

RestArea(aAreaDTY)
RestArea(aAreaE2)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSXPESS  ³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna se o Fornecedor e Pessoa Fisica ou Juridica        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSXPESS ( ExpC1, ExpC2, ExpC3 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Filial de Origem                         ³±±
±±³          ³ ExpC2 = Codigo da Viagem                                   ³±±
±±³          ³ ExpC3 = Codigo do Veiculo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTipPess                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsXPess(cFilOri, cViagem, cCodVei)
Local aArea := GetArea()
Local cTipPess := ''
Local cCodForn := ''
Local cLojForn := ''

DTY->(DbSetorder(2))
If DTY->(MsSeek(xFilial("DTY")+cFilOri+cViagem))
	cCodForn  :=  DTY->DTY_CODFOR
	cLojForn  :=  DTY->DTY_LOJFOR
EndIf

SA2->(DbSetOrder(1))
If SA2->(MsSeek(xFilial("SA2")+cCodForn+cLojForn))
	cTipPess := SA2->A2_TIPO
EndIf

RestArea(aArea)
Return cTipPess

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsxInImp ³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao de Impostos no Contrato de Carreteiro             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsxInImp( ExpC1, ExpC2, ExpA1 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Codigo da Viagem                                   ³±±
±±³          ³ ExpA1 = Array com os Impostos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsxInImp(cFilOri, cViagem, aMovAux, lPosto)

Local aArea 	 := GetArea()
Local nAux 		 := 0
Local aMovtos 	 := {}
Local nVlr_IRRF  := 0
Local nVlr_INSS  := 0
Local nVlr_SEST  := 0
Local nVlr_VLSEST:= 0
Local nVlr_VLSENA:= 0

Default aMovAux	:= {}
Default lPosto 	:= .F.

If lPosto .And. !Empty(aMovAux) 						//-- Impostos vindos do consultaContrato
	For nAux := 1 to Len (aMovAux)
   		AAdd(aMovtos,{ NoAcentoCte(aMovAux[nAux][1]), aMovAux[nAux][2] })
	Next
ElseIf !Empty(aMovAux) 
	If ValType(aMovAux) == "A"   //-- Impostos vindos do QuitaContratoResult
		For nAux := 1 to Len (aMovAux)
	   		AAdd(aMovtos,{ NoAcentoCte(aMovAux[nAux]:_Codigo_Movimento:Text), Val(aMovAux[nAux]:_Valor:Text) })
		Next
	ElseIf ValType(aMovAux) == "O" 
	   	AAdd(aMovtos,{ NoAcentoCte(aMovAux:_Codigo_Movimento:Text), Val(aMovAux:_Valor:Text) })
	EndIf
EndIf

If SuperGetMV( 'MV_VSREPOM',, '1' ) == '2' .And. !Empty(aMovtos)
	For nAux := 1 to len(aMovtos)  		 // recebe valores da operadora
		Do Case
		Case aMovtos[nAux][1]  == '103' .Or. aMovtos[nAux][1]  == '1'    //--  IRRF
			nVlr_IRRF	  := aMovtos[nAux][2]
		Case aMovtos[nAux][1]  == '116' .Or. aMovtos[nAux][1]  == '100'  //--  INSS
			nVlr_INSS     := aMovtos[nAux][2]
		Case aMovtos[nAux][1]  == '108' .Or. aMovtos[nAux][1]  == '2'    //--  SEST
			nVlr_SEST	  += aMovtos[nAux][2]
			If DTY->(ColumnPOs('DTY_VLSEST')) > 0  //ERP Datasul
				nVlr_VLSEST := aMovtos[nAux][2]						
			EndIf
		Case aMovtos[nAux][1]  == '109' .Or. aMovtos[nAux][1]  == '3'    //--  SENAT
			nVlr_SEST	  += aMovtos[nAux][2]
			If DTY->(ColumnPOs('DTY_VLSENA')) > 0  //ERP Datasul
				nVlr_VLSENA := aMovtos[nAux][2]						
			EndIf
		EndCase
	Next

	//--- Atualiza valores na DTY (Trecho movido para a nova função)
	TMSAtuDTY(cFilOri,cViagem,nVlr_IRRF,nVlr_INSS,nVlr_SEST,nVlr_VLSEST,nVlr_VLSENA)
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsMovRep ³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno dos Movimentos do consultaContrato Repom           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsMovRep( ExpC1, ExpC2, ExpC3, ExpC4, ExpC5, ExpC6 )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Id do Cliente para Operadora                       ³±±
±±³          ³ ExpC2 = Codigo de acesso da Operadora                      ³±±
±±³          ³ ExpC3 = URL de acesso                                      ³±±
±±³          ³ ExpC4 = Codigo do Processo do Cliente (Filial + Viagem)    ³±±
±±³          ³ ExpC5 = Codigo do Processo da Operadora                    ³±±
±±³          ³ ExpC6 = Filial do Cliente                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aMovtos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsMovRep( cIdOpe, cCodACe, cUrl, cCodCli, cCodProc, cFilCodCli )
Local oXml      := Nil
Local aRetorno  := Nil
Local nAux		:= 0
Local aMovtos   := {}

oXml := TmsConsRep( cIdOpe, cCodACe, cUrl, cCodCli, cCodProc, cFilCodCli )

If ValType( oXml ) == 'O' //.And. XMLNode2Arr( oXML:_processo_transporte:_movimentos, '_movimento' )

	If Valtype(oXML:_Processo_Transporte:_Movimentos:_Movimento) == "A"
		aRetorno := aClone(oXML:_Processo_Transporte:_Movimentos:_Movimento)

		For nAux := 1 to len(aRetorno)
			AAdd(aMovtos,{ aRetorno[nAux]:_Movimento_Codigo:Text, Val(aRetorno[nAux]:_Valor:Text) })
		Next
	ElseIf Valtype(oXML:_Processo_Transporte:_Movimentos:_Movimento) == "O"
		AAdd(aMovtos,{ oXML:_Processo_Transporte:_Movimentos:_Movimento:_Movimento_Codigo:Text, Val(oXML:_Processo_Transporte:_Movimentos:_Movimento:_Valor:Text) })
	EndIf

Else
	TmsLogMsg(,str(threadid()) + 'Erro no retorno do metodo de consulta contrato repom')
	TmsLogMsg(,VARINFO("Codigo: ",cCodCli,,.f.))
Endif

oXml := Nil

Return aMovtos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsConsRep³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno os Impostos pelo metodo ConsultaContratoResult     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsConsRep( ExpC1, ExpC2, ExpC3, ExpC4, ExpC5, ExpC6 )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Id do Cliente para Operadora                       ³±±
±±³          ³ ExpC2 = Codigo de acesso da Operadora                      ³±±
±±³          ³ ExpC3 = URL de acesso                                      ³±±
±±³          ³ ExpC4 = Codigo do Processo do Cliente (Filial + Viagem)    ³±±
±±³          ³ ExpC5 = Codigo do Processo da Operadora                    ³±±
±±³          ³ ExpC6 = Filial do Cliente                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aMovtos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConsRep( cIdOpe, cCodACe, cUrl, cCodCli, cCodProc, cFilCodCli )
Local cXML                      := ''
Local cError            := ''
Local cWarning          := ''
Local lValido           := .T.
Local lTMSXML           := GetMV( 'MV_TMSXML',, .F. )
Local oXML              := Nil
Local oObj              := Nil

Default cIdOpe          := '' 	// id da operadora
Default cCodACe         := '' 	// codigo do certificado
Default cUrl            := '' 	// url de acesso ao Ws
Default cCodProc        := '' 	// codigo do contrato na repom
Default cCodCli         := '' 	// codigo do cliente
Default cFilCodCli      := '' 	// codigo da filial do cliente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos parametros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lValido .And. (Valtype( 'cIdOpe' ) <> 'C' .OR. Empty(cIdOpe))
	lValido := .F.
Endif
If lValido .And. (Valtype( 'cCodACe' ) <> 'C' .OR. Empty(cCodACe))
	lValido := .F.
Endif
If lValido .And. (Valtype( 'cUrl' ) <> 'C' .OR. Empty(cUrl))
	lValido := .F.
Endif

IF lValido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³XML para Entrada processo transporte              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXML += '<processo_transporte>'
	cXML += 	'<cliente_codigo>' + AllTrim(cIdOpe) + '</cliente_codigo>'
	cXML += 	'<processo_cliente_codigo>' + cFilCodCli + '</processo_cliente_codigo>' // Código do processo cliente.
	cXML += 	'<processo_cliente_filial_codigo_cliente/>'
	if !Empty(cCodProc)
   		cXML += '<processo_transporte_codigo>' + AllTrim(cCodProc) + '</processo_transporte_codigo>' // código do contrato na Repom
	Else
		cXML += '<processo_transporte_codigo/>'
	EndIf
	cXML += '<filial_codigo_cliente>' +  cCodCli+ '</filial_codigo_cliente>' // Código filial Cliente.
	cXML += '</processo_transporte>'

	//-- Gera XML em Disco
	If lTMSXML
		TMSLogXML( cXML, 'ConsultaContrato.XML' )
	EndIf

	//-- Remove acentos e caracteres especiais
	cXML := TMSNoAcento( cXML )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ACIONA O WEBSERVICE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := WSIntegracao():New()
	oObj:cStrCliente           := AllTrim(cIdOpe)
	oObj:cStrAssinaturaDigital := AllTrim(cCodACe)
	oObj:cStrXMLIn             := cXML
	oObj:_URL                  := cUrl

	oObj:ConsultaContrato()
	IF oObj <> Nil
		lValido := oObj:lConsultaContratoResult

		If lValido
			//-- Remove os acentos do XML de Retorno
			oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

			//-- Gera XML em Disco
			If lTMSXML
				TMSLogXML( oObj:cStrXMLOut, 'ConsultaContratoResult.XML' )
			EndIf

			//-- Coverte em Objeto o XML de retorno enviado pela Operadora
			oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )
		Endif

		If !lValido
			TmsLogMsg(,VARINFO("Erro Retorno ConsultaContrato: ",cCodProc,,.f.))
		Endif
	Endif
Endif

Return oXML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³EnvDocOper³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia documentos para a Operadora                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EnvDocOper( ExpC1, ExpC2, ExpC3, ExpC4, ExpC5,             ³±±
±±³ 		 ³		      ExpC6, ExpL1, ExpC7, ExpA1 )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Id do Cliente para Operadora                       ³±±
±±³          ³ ExpC2 = Codigo de acesso da Operadora                      ³±±
±±³          ³ ExpC3 = URL de acesso                                      ³±±
±±³          ³ ExpC4 = Codigo do Processo do Cliente (Filial + Viagem)    ³±±
±±³          ³ ExpC5 = Codigo do Processo da Operadora                    ³±±
±±³          ³ ExpC6 = Filial do Cliente                                  ³±±
±±³          ³ ExpC7 = Tipo de Operacao                                   ³±±
±±³          ³ ExpL1 = Estorno?                                           ³±±
±±³          ³ ExpA1 = Array com Documentos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lValido                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EnvDocOper( cIdOpe, cCodACe, cUrl, cCodCli, cCodProc, cFilCodCli, lEstorno, cTipo, aDocs )
Local aArea				:= GetArea()
Local aAreaDTR			:= DTR->(GetArea())
Local cXML              := ''
Local lCentury      	:=__SetCentury()
Local nIx               := 0
Local lValido           := .T.
Local lTMSXML           := GetMV( 'MV_TMSXML',, .F. )
Local oObj				:= Nil
Local lMostra           := .T.

Default cIdOpe          := '' 	// id da operadora
Default cCodACe         := '' 	// codigo do certificado
Default cUrl            := '' 	// url de acesso ao Ws
Default cCodProc        := '' 	// codigo do contrato na repom
Default cCodCli         := '' 	// codigo do cliente
Default cFilCodCli      := '' 	// codigo da filial do cliente
Default lEstorno        := 'F' 	// codigo do cliente
Default cTipo           := '0' 	// tipo da informação encaminhada para a operadora repom
Default aDocs           := {}	// Documentos a  serem enviados para a operadora repom

// Array com 'n' dimensoes e 4 colunas
// aDocs[n][codigo]
// aDocs[n][serie]
// aDocs[n][filial]
// aDocs[n][tipo]

If IsInCallStack(AllTrim('WSEXECUTE'))
	lMostra:= .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação dos parametros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lValido .And. (Valtype( 'cIdOpe' ) <> 'C' .OR. Empty(cIdOpe))
	If lMostra
		Help('',1,'TMSXFUNC16')
	EndIf
	lValido := .F.
Endif
If lValido .And. (Valtype( 'cCodACe' ) <> 'C' .OR. Empty(cCodACe))
	If lMostra
		Help('',1,'TMSXFUNC16')
	EndIf
	lValido := .F.
Endif
If lValido .And. (Valtype( 'cUrl' ) <> 'C' .OR. Empty(cUrl))
	If lMostra
		Help('',1,'TMSXFUNC16')
	EndIf
	lValido := .F.
Endif

DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR')+cCodCli))
	If Empty(cCodProc)
		cCodProc := DTR->DTR_PRCTRA
	EndIf
EndIf

If lValido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³XML para Envio do documentos recebidos na filial  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXML += '<confirma_recebimento_documentacao>'
 	cXML += '<processo_transporte>'
	If !Empty(cCodProc)
		cXML += '<processo_transporte_codigo>' + AllTrim(cCodProc) + '</processo_transporte_codigo>'
	Else
		cXML += '<processo_transporte_codigo/>'
	EndIf
	cXML += '<processo_transporte_codigo_cliente>' + cCodCli + '</processo_transporte_codigo_cliente>'
	cXML += '<filial_codigo_cliente>' + cFilCodCli + '</filial_codigo_cliente>'
	cXML += '<usuario>' + AllTrim(substr( cUsuario , 7,15)) + '</usuario>'
	If !lCentury
		SET CENTURY ON   //-- Operadora Repom aceita apenas Ano com 4 caracteres
		cXML += '<data_hora>' + Dtoc( dDatabase )+ '</data_hora>'
		SET CENTURY OFF
	Else
		cXML += '<data_hora>' + Dtoc( dDatabase )+ '</data_hora>'
	EndIf
	cXML += '<estorno>' + iif( lEstorno , '1' , '0' ) + '</estorno>'
	cXML += '<tipo>0</tipo>'

	// monta xml dos documentos a serem enviados
	cXML += '<documentos>'

	For nIx := 1 TO Len( aDocs )
		cXML += '<documento>'
			cXML += '<codigo>' + AllTrim(aDocs[nIx][1]) + '</codigo>'
			cXML += '<serie>'  + AllTrim(aDocs[nIx][2]) + '</serie>'
			cXML += '<filial>' + AllTrim(aDocs[nIx][3]) + '</filial>'
			cXML += '<tipo>'   + AllTrim(aDocs[nIx][4]) + '</tipo>'
		cXML += '</documento>'
	Next

	cXML += '</documentos>'
	cXML += '</processo_transporte>'
	cXML += '</confirma_recebimento_documentacao>'


	//-- Gera XML em Disco
	If lTMSXML
		TMSLogXML( cXML, 'RecebimentoDocumentacao.XML' )
	EndIf

	//-- Remove acentos e caracteres especiais
	cXML := TMSNoAcento( cXML )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ACIONA O WEBSERVICE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := WSIntegracao():New()
	oObj:cStrCliente           := cIdOpe
	oObj:cStrAssinaturaDigital := cCodACe
	oObj:cStrXMLIn             := cXML
	oObj:_URL                  := cUrl

	oObj:DocumentosBaixaAntecipada()
	If oObj <> Nil
		lValido := oObj:lDocumentosBaixaAntecipadaResult

		If !lValido
			If lMostra
				Aviso(STR0040,oObj:cStrXMLErr,{STR0041})
				aMsgErr := TMSErrOper(cIdOpe, oObj:cStrXMLErr, '1')
			Else
				TmsLogMsg(,str(threadid()) + 'Erro no retorno do metodo DocumentosBaixaAntecipada')
				TmsLogMsg(,VARINFO("Codigo: ",cCodCli,,.f.))
			EndIf
		Endif
	Endif
Endif
RestArea(aAreaDTR)
RestArea(aArea)
Return lValido

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsGetOp  ³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a operacao setada no perfil do Cliente             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsGetOp( ExpC1, ExpC2, ExpC3 )                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Codigo da Viagem                                   ³±±
±±³          ³ ExpC3 = Codigo do Veiculo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cOper                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsGetOp(cFilOri, cViagem, cCodVei, cCodForn, cLojForn)
Local aArea     := GetArea()
Local cOper     := ''
Local cCodOper  := ''
Local cSeek     := ''
Local nCont     := 0
Local aVeic     := {}
Local aDocViag  := {}
Local aCliDev   := {}
Local aContrFor := {}
Local lTipOpVg  := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0

Default cFilOri := ''
Default cViagem := ''
Default cCodVei := ''

DbSelectArea("DTR")
DTR->(DbSetOrder(3)) //-- Posiciona no Descricao de veiculos para obter codigo da operadora
If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem+cCodVei))
	cCodOper := DTR->DTR_CODOPE
	Aadd(aVeic,{DTR->DTR_CODVEI,DTR->DTR_QTDEIX,DTR->DTR_QTEIXV})
EndIf

DUD->(DbSetOrder(5)) //-- Posiciona no Movimento de Viagem para obter codigo dos Documentos da viagem
If DUD->(MsSeek(cSeek:=xFilial("DUD")+cFilOri+cViagem))
	Do While DUD->(!EoF()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == cSeek
		Aadd(aDocViag,{DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_SERTMS}) // passando o servico apenas - tmp
		DUD->(dbSkip())
	EndDo
EndIf

DT6->(DbSetOrder(1)) //-- Posiciona no Doc. de Viagem para obter os Devedores
If !Empty(aDocViag)
	For nCont := 1 to Len(aDocViag)
		If DT6->(MsSeek(xFilial("DT6")+aDocViag[nCont][1]+aDocViag[nCont][2]+aDocViag[nCont][3]))
			Aadd(aCliDev,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,aDocViag[nCont][4]})
		EndIf
	next
EndIf

DTQ->(DbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
	//-- Verifica a Operação no Contrato do Fornecedor.
	If DVG->(ColumnPos("DVG_OPERAC")) > 0 
		//-- Verifica os Dados do Contrato do Fornecedor   
		aContrFor := TMSContrFor(cCodForn, cLojForn,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,Posicione('DA3',1,xFilial('DA3') + cCodVei,'DA3_TIPVEI'), Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))
		
		If Empty(aContrFor)
			//-- Pesquisa Contrato com o Tipo de Veiculo Vazio
			aContrFor := TMSContrFor(cCodForn, cLojForn,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,,Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))
		EndIf
		If Len(aContrFor) > 0 .And. Len(aContrFor[1]) >= 16
			cOper := aContrFor[1][16]
		EndIf
	EndIf

	If Empty(cOper ) .And. DTQ->DTQ_TIPVIA == StrZero( 2, Len( DTQ->DTQ_TIPVIA ) ) //Vazia
		cOper := SuperGetMv('MV_OPREPOM',,"")
	EndIf
EndIf
If Empty(cOper)
	DUO->(DbSetOrder(1)) //-- Posiciona no Perfil do Cliente
	If !Empty(aCliDev)
		For nCont := 1 to Len(aCliDev)
			If DUO->(MsSeek(xFilial("DUO")+aCliDev[nCont][1]+aCliDev[nCont][2]))
				If aCliDev[nCont][3] == '3'
					If !Empty(DUO->DUO_OPEENT)
						cOper := DUO->DUO_OPEENT
					EndIf
				ElseIf aCliDev[nCont][3] == '1'
					If !Empty(DUO->DUO_OPECOL)
						cOper := DUO->DUO_OPECOL
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea(aArea)
Return cOper

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsOperF3 ³ Autor ³ Guilherme R. Gaiofatto³ Data ³17.01.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta especifica SXB para Operacoes x Operadora         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsOperF3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsOperF3()
Local oDlg
Local oGetDEJ
Local nAux    := 0
Local lOk     := .F.
Local nOpcx   := 1
Local lOldInc := INCLUI

Private aHeaderDEJ	:= {}
Private aColsDEJ	:= {}
Private aOperac		:= {}

INCLUI := .F.

RegToMemory( "DEG", .F. )	//-- seta na memoria os registro da DEG

TMSAE60DEJ(1)				//-- Preencher aHeader e aCols da DEJ

If !Empty(M->DEG_CODOPE)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SaveInter()

	n       := 1
	aHeader := aClone(aHeaderDEJ)
	aCols   := {}

	If Len(aColsDEJ)  > 0
		aCols	:= aClone(aColsDEJ)
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCols,Array(Len(aHeader)+1))
		For nAux := 1 to Len(aHeader)
			aCols[1][nAux] := CriaVar(aHeader[nAux][2])
			aCols[1][Len(aHeader)+1] := .F.
		Next

		GDFieldPut('DEJ_ITEM',StrZero(1,Len(DEJ->DEJ_ITEM)),1)
	EndIf

	DEFINE MSDIALOG oDlg FROM 94 ,104 TO 310,650 TITLE STR0113 Of oMainWnd PIXEL //"Operacoes do Gerenciador de Frotas"
	oGetDEJ := MSGetDados():New(30,2,105,270,nOpcx,'TAE60OpLOk','AllwaysTrue()','+DEJ_ITEM',;
											IIf(nOpcx == 3 .Or. nOpcx == 4,.T.,Nil))

	@ 18,03 SAY STR0114 Of oDlg PIXEL SIZE 80 ,9 //"Gerenciador de Frotas (Operador):"
	@ 18,90 SAY M->DEG_CODOPE + '/' + M->DEG_NOMOPE Of oDlg PIXEL SIZE 100,9

	//-- Esta Funcao corrige uma falha da GetDados ao mostrar os itens deletados
	TMSA011AjuMin(aColsDEJ, aCols)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDEJ:TudoOk(), ( lOk := .T., oDlg:End()), (lOk := .F.))},;
													{|| oDlg:End()} ) CENTERED
	If lOk
		VAR_IXB := aCols[n][6]
		aColsDEJ := aClone(aCols)
	Else
		VAR_IXB := ""
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as Variaveis da GetDados Anterior                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestInter()
Else
	VAR_IXB := ""
	Help('',1,'TMSAE6006') //"Operadora de frota não cadastrada."
EndIf

INCLUI := lOldInc
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsTpCrg  ³ Autor ³Guilherme R. Gaiofatto ³ Data ³02.02.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Codigo da Natureza da Receita    		 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsTpCrg(ExpC1,ExpC2)  		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial de Origem da Viagem                          ³±±
±±³          ³ExpC2 - Codigo da Viagem       			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cNatCarga - Codigo da natureza                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsTpCrg(cFilOri, cViagem, cFilDoc, cDoc, cSerie, lTela)
Local aArea      := GetArea()
Local aAreaDUD   := DUD->(GetArea())
Local aAreaDTC   := DTC->(GetArea())
Local aAreaSB1   := SB1->(GetArea())
Local cNatTmp	 := ''
Local cNatCarga  := ''
Local lLotacao	 := .T.
Local aMsgErr    := {}
Local aVisErr    := {}

Default cFilOri  := ''
Default cViagem  := ''
Default cFilDoc  := ''
Default cDoc	 := ''
Default cSerie	 := ''
Default lTela    := .T.

If IsInCallStack('TMA250Oper') .Or. IsInCallStack('TMSA310Mnt')
	DbSelectArea("DUD")
	DUD->( DbSetOrder( 2 ) )
	If DUD->( MsSeek( xFilial('DUD') + cFilOri + cViagem) )
		DTC->( DbSetOrder( 3 ) )
		If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE) 
			If DTC->(MsSeek(xFilial('DTC')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
				While !DTC->(EoF()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == xFilial('DUD')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)
						SB1->( DbSetOrder( 1 ) )
						If SB1->( MsSeek( xFilial('SB1') + DTC->DTC_CODPRO ) )
							cNatTmp := SB1->B1_TNATREC
							If Empty(cNatTmp)
								AAdd(aMsgErr,{STR0112+ STR0002 + ' ' + cFilDoc + ' ' + cDoc + ' ' + cSerie + ' ' +;
									  STR0008 + ' ' + SB1->B1_COD + ' ' + SB1->B1_DESC})// Documento No. ### ### ### Produto ### ###Codigo de Natureza de Despesa Vazio
				   			EndIf
						EndIf
						If cNatTmp != cNatCarga .And. !Empty(cNatTmp) .And.  !Empty(cNatCarga)
							lLotacao  := .F.
							Exit
						Else
							cNatCarga := cNatTmp
						EndIf
						DTC->(dbSkip())
				Enddo
			EndIf
		Else		
			DbSelectArea("DY4")
			DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
			If DY4->(MsSeek(xFilial('DY4')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
				While !DY4->(EoF()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == xFilial('DUD')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)
						SB1->( DbSetOrder( 1 ) )
						If SB1->( MsSeek( xFilial('SB1') + DY4->DY4_CODPRO ) )
							cNatTmp := SB1->B1_TNATREC
							If Empty(cNatTmp)
								AAdd(aMsgErr,{STR0112+ STR0002 + ' ' + cFilDoc + ' ' + cDoc + ' ' + cSerie + ' ' +;
									  STR0008 + ' ' + SB1->B1_COD + ' ' + SB1->B1_DESC})// Documento No. ### ### ### Produto ### ###Codigo de Natureza de Despesa Vazio
				   			EndIf
						EndIf
						If cNatTmp != cNatCarga .And. !Empty(cNatTmp) .And.  !Empty(cNatCarga)
							lLotacao  := .F.
							Exit
						Else
							cNatCarga := cNatTmp
						EndIf
						DY4->(dbSkip())
				Enddo
			EndIf			
		Endif	
	EndIf
ElseIf  IsInCallStack('TMSA240Mnt')
	
	If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
		DbSelectArea("DTC")
		DTC->( DbSetOrder( 3 ) ) 
		If DTC->(MsSeek(xFilial('DTC')+cFilDoc+cDoc+cSerie))
			While !DTC->(EoF()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == xFilial('DTC')+cFilDoc+cDoc+cSerie
				SB1->( DbSetOrder( 1 ) )
				If SB1->( MsSeek( xFilial('SB1') + DTC->DTC_CODPRO ) )
					cNatTmp := SB1->B1_TNATREC
					If Empty(cNatTmp)
						AAdd(aMsgErr,{STR0112+ STR0002 + ' ' + cFilDoc + ' ' + cDoc + ' ' + cSerie + ' ' +;
									  STR0008 + ' ' + SB1->B1_COD + ' ' + SB1->B1_DESC})
									  // Documento No. ### ### ### Produto ### ###Codigo de Natureza de Despesa Vazio
					EndIf
				EndIf
				If cNatTmp != cNatCarga .And. !Empty(cNatTmp) .And. !Empty(cNatCarga)
					lLotacao  := .F.
					Exit
				Else
					cNatCarga := cNatTmp
				EndIf
				DTC->(dbSkip())
		    Enddo
		EndIf
	Else
		DbSelectArea("DY4")
		DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		If DY4->(MsSeek(xFilial('DY4')+cFilDoc+cDoc+cSerie))
			While !DY4->(EoF()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == xFilial('DY4')+cFilDoc+cDoc+cSerie
				SB1->( DbSetOrder( 1 ) )
				If SB1->( MsSeek( xFilial('SB1') + DY4->DY4_CODPRO ) )
					cNatTmp := SB1->B1_TNATREC
					If Empty(cNatTmp)
						AAdd(aMsgErr,{STR0112+ STR0002 + ' ' + cFilDoc + ' ' + cDoc + ' ' + cSerie + ' ' +;
									  STR0008 + ' ' + SB1->B1_COD + ' ' + SB1->B1_DESC})
									  // Documento No. ### ### ### Produto ### ###Codigo de Natureza de Despesa Vazio
					EndIf
				EndIf
				If cNatTmp != cNatCarga .And. !Empty(cNatTmp) .And. !Empty(cNatCarga)
					lLotacao  := .F.
					Exit
				Else
					cNatCarga := cNatTmp
				EndIf
				DY4->(dbSkip())
		    Enddo
		EndIf			
	Endif	
EndIf

// Lista os Produtos com campo de Natureza de Despesa Brancos
AaddMsgErr( aMsgErr, aVisErr )
If !Empty(aVisErr) .And. lTela
	TmsMsgErr( aVisErr )
EndIf

If !lLotacao .And. Empty(cNatCarga)
	cNatCarga := '0001'    //-- Definicao padrao para Carga Fracionada
EndIf

RestArea(aAreaDUD)
RestArea(aAreaDTC)
RestArea(aAreaSB1)
RestArea(aArea)

Return cNatCarga
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSX520VLD³ Autor ³ Katia Bianchi         ³ Data ³30.07.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o doc. existe no TMS e não permite a excluir   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSXPESS ( ExpC1, ExpC2, ExpC3 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTipPess                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSX520VLD()
Local aArea := GetArea()
Local lRet  := .T.

DT6->(DbSetorder(1))
If DT6->(MsSeek(xFilial("DT6")+SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
	lRet := .F.
	Help( '', 1, 'TMSXFUNC17' ) // Documento originado pelo módulo TMS não pode ser excluído pelas rotinas do módulo faturamento
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSColXML³ Autor ³ N3-DL                ³ Data ³15.09.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de retorno de informacoes CTe Totvs Colaboracao 2.0  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSColXML(aIdCTe,cModalidade,lUsaColab,cModelo)

Local cProtocolo	:= ""
Local cModTrans		:= ""
Local cCodRetNFE	:= ""
Local cRetDPEC		:= ""
Local cProtDPEC		:= ""
Local cRetorno		:= ""
Local cDtHrRec1		:= ""
Local dDtRecib		:= CToD("")

Local cErro			:= ""
Local cAviso		:= ""

Local nZ			:= 0
Local nCount		:= 0
Local aDados		:= {}
Local aRetorno		:= {}

Private oDoc

default lUsacolab	:= .F.
default cModalidade := ColGetPar( "MV_MODCTE", "1" )
default cModelo		:= "57"

If cModelo=="58"
	cModalidade := ColGetPar("MV_MODMDF","1")
Else
	cModalidade := ColGetPar("MV_MODCTE","1")
EndIf

For nZ := 1 To len(aIdCTe)
	oDoc 			:= ColaboracaoDocumentos():new()
	oDoc:cModelo	:= IIf(cModelo=="58","MDF","CTE")
	oDoc:cTipoMov	:= "1"
	oDoc:cIDERP		:= IIf(cModelo=="58","MDF","")+aIdCTe[nZ][4]+aIdCTe[nZ][5]+FwGrpCompany()+FwCodFil()

	nCount++

	aadd(aRetorno,{"","",aIdCTe[nZ][4]+aIdCTe[nZ][5],"","","",CToD(""),"",""})

	if odoc:consultar()
		aDados := ColDadosNf(1,cModelo,.T.)

		if !Empty(oDoc:cXMLRet)
			cRetorno := oDoc:cXMLRet
		else
			cRetorno := oDoc:cXml
		endif

		aDadosXml := ColDadosXMl(cRetorno, aDados, @cErro, @cAviso)

		cProtocolo	:= aDadosXml[3]
		cModTrans	:= IIF(Empty(aDadosXml[5]),aDadosXml[7],aDadosXml[5])
		cCodRetNFE	:= aDadosXml[1]
		//-- Dados do DEPEC
		If !Empty( aDadosXml[9] )
			cRetDPEC  := cRetorno
			cProtDPEC := aDadosXml[9]
		EndIf

		//-- Tratamento para gravar a hora da transmissao da CTe
		If !Empty(cProtocolo)
			cDtHrRec		:= aDadosXml[4]
			nDtHrRec1		:= RAT("T",cDtHrRec)
			If nDtHrRec1 <> 0
				cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
				dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
			EndIf
		EndIf

		//-- Alterado cRetorno para o XML padrão que foi enviado.
		cRetorno := oDoc:cXml

		aRetorno[nZ][1] := cProtocolo
		aRetorno[nZ][2] := cRetorno
		aRetorno[nZ][4] := cRetDPEC
		aRetorno[nZ][5] := cProtDPEC
		aRetorno[nZ][6] := cDtHrRec1
		aRetorno[nZ][7] := dDtRecib

		if ( nCount == 10 )
			delClassIntF()
			nCount := 0
		endif

	EndIf
Next nZ

Return(aRetorno)

//------------------------------------------------------------------------------
*/
//------------------------------------------------------------------------------
/*/{Protheus.doc} TMSX3Cpo
Função auxiliar que retorna dados de um campo no SX3.

@sample 	TMSX3Cpo( cCampo )

@param		cCampo	Nome do campo que deseja obter informações.

@return	aDados Dados do campo.
					[1] Título do campo.
					[2] Descrição do campo.
					[3] Tamanho do campo.
					[4] Decimais do campo.
					[5] Picture do campo.

@author Fabio Marchiori Sampaio
@since		01/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function TMSX3Cpo( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

If ExistCpo("SX3",cCampo,2)

	AAdd( aDados, GetSX3Cache(cCampo,"X3_TITULO") )			//-- Retorna título do campo no X3
	AAdd( aDados, GetSX3Cache(cCampo,'X3_DESCRIC') )		//-- Retorna descrição do campo no X3
	AAdd( aDados, TamSX3(cCampo)[1] )						//-- Retorna tamanho do campo
	AAdd( aDados, TamSX3(cCampo)[2] )						//-- Retorna quantidade de casas decimais do campo
	AAdd( aDados, Alltrim(X3Picture(cCampo)) )				//-- Retorna a picture do campo
	AAdd( aDados, GetSX3Cache(cCampo,'X3_TIPO') )			//-- Retorna o tipo do campo
	AAdd( aDados, GetSX3Cache(cCampo,'X3_CBOX') )			//-- Retorna o combo do campo

EndIf

RestArea( aArea )

Return aDados

//------------------------------------------------------------------------------
*/
//------------------------------------------------------------------------------
/*/{Protheus.doc} TMS250SCHE
Função auxiliar que verifica se a chamada é da rotina TMSA250, e se é executada via Schedule.

@sample 	TMS250SCHE()

@param

@return	lRet

@author Clovis Nunes do Nascimento
@since		22/10/2014
@version	P11
/*/
//------------------------------------------------------------------------------
Static Function TMS250SCHE()

Local lRet := .F.

If IsBlind()
	If FunName() == "TMSA250"
		lRet := .T.
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCalcRat³ Autor ³Adalberto S.M          ³ Data ³24.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel por efetuar Rateios de Frete a Receber  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSCalcRat( aRateio, cFILORI, cLOTNFC, aPerFixDDP, aValInf )

	Local aRet		:= {}
	Local aBaseRat	:= {}
	Local aMsgErr	:= {}
	Local aTipVei	:= {}
	Local aFretRat	:= {}
	Local aAlteRat	:= {}
	Local aCompRat	:= {}
	Local aAreas	:= { DTP->(GetArea()), GetArea() }
	Local aCRIRAT	:= {}
	Local aPRORAT	:= {}

	Local lRateio	:= TMSLRateio( cFILORI, cLOTNFC )
	Local lCliGen	:= .F.
	Local lAjuAut	:= .F.
	Local lPrcPdg	:= .T.
	Local lQtdDocT	:= .F.
	Local lTBARAT   := .F.

	Local nCount1	:= 0
	Local nCount2	:= 0
	Local nCount3	:= 0
	Local nPosRat	:= 0
	Local nQtdUni	:= 0 // DTC_QTDUNI - Unitizador
	Local nCRIRAT	:= 0
	Local nPRORAT	:= 0
	Local nTotBas	:= 0
	Local nBaseDOC	:= 0
	Local nValFret	:= 0
	Local cSeqTab	:= StrZero(0,Len( DVC->DVC_SEQTAB ))
	Local cCodPro	:= Space(Len(SB1->B1_COD))
	Local cCodCli	:= ""
	Local cLojCli	:= ""
	Local cCliDev	:= ""
	Local cLojDev	:= ""
	Local cCliDes	:= ""
	Local cLojDes	:= ""
	Local cServic	:= ""
	Local cSerTms	:= ""
	Local cTipTra	:= ""
	Local cNContr	:= ""
	Local cDocTms	:= ""
	Local cAliasQry	:= ""
	Local cQuery	:= ""
	Local nDifRat   := 0
	Local nTotVlrRat:= 0
	Local nValRat   := 0
	Local lDizima   := .F.
	Local nTotVlrDiz:= 0
	Local nCount4   := 0
	Local nCount5   := 0
	Local lCamposRat:= DTP->(ColumnPos("DTP_CRIRAT")) > 0
	Local lIdentDoc := DTC->(ColumnPos("DTC_DOCTMS")) > 0
	Local nPerFix   := 0         
	Local nPeso     := 0
	Local lPerFix   := .F.
	Local nPerDDP   := 0
	Local nDoc      := 0
	Local aNFVlCol  := {}
	Local nPosElm   := 0
	Local nCol1     := 0
	Local nCol2     := 0	
	Local nAdiDoc   := 0
	Local nValBas   := 0
	Local nBasDist  := 0
	Local nUltVal   := 0
	Local nValApl   := 0
	Local aCRDVDC   := {}
	Local nCRDVDC   := 0
	Local nPosx     := 0
	Local aCliDev   := {}
	Local nPercent  := 0
	Local nValFreFx := 0
	Local nTotVlrFix:= 0
	Local lQbrCliDev:= .F.

	Local nValCalc  := 0
	Local lCbrCol   := .T.
	Local lBlqCol   := .F.
    
	Local cORIRAT   := "" //Origem do Rateio
	Local cCALRAT   := "" //Destino do Rateio

	Local lInvOri   := .F.
	
	Default aRateio := {}
	Default cFILORI := ""
	Default cLOTNFC := ""                      
	Default aPerFixDDP := {}
	
	If !lCamposRat
		lRateio:= .F.
	EndIf

	If lRateio
		// O vetor aCRIRAT tem a seguinte estrutura:                          //
		// 01 - Codigo do Criterio de Calculo de Rateio (DTP_CRIRAT)          //
		// 02 - Posicao no vetor aRateio a qual o Criterio se Refere          //
		// Observacao:                                                        //
		//   *Sera utiliza somente aqueles que tem a posicao 2 maior que zero.//
		//   *Quando a posicao 2 for 99 o sistema entendera que devera obter o//
		//    componente de maior valor.                                      //
		Aadd( aCRIRAT, { StrZero(1, Len(DTP->DTP_CRIRAT)), 00 } ) // Nao Utiliza
		Aadd( aCRIRAT, { StrZero(2, Len(DTP->DTP_CRIRAT)), 00 } ) // Orig/Dest;
		Aadd( aCRIRAT, { StrZero(3, Len(DTP->DTP_CRIRAT)), 99 } ) // Maior Vlr.Comp;
		Aadd( aCRIRAT, { StrZero(4, Len(DTP->DTP_CRIRAT)), 03 } ) // Maior Peso Real
		Aadd( aCRIRAT, { StrZero(5, Len(DTP->DTP_CRIRAT)), 04 } ) // Maior Peso M3;
		Aadd( aCRIRAT, { StrZero(6, Len(DTP->DTP_CRIRAT)), 05 } ) // Maior Vlr.Merc
		Aadd( aCRIRAT, { StrZero(7, Len(DTP->DTP_CRIRAT)), 02 } ) // Maior Vol
		Aadd( aCRIRAT, { StrZero(8, Len(DTP->DTP_CRIRAT)), 07 } ) // Maior KM
		Aadd( aCRIRAT, { StrZero(9, Len(DTP->DTP_CRIRAT)), 06 } ) // Maior M3
		Aadd( aCRIRAT, { 'A', 00 } ) // Orig/Dest/Vge;
		Aadd( aCRIRAT, { 'B', 09 } ) // Maior Peso Previsto
		Aadd( aCRIRAT, { 'C', 10 } ) // Maior Peso Previsto x Realizado
	
		// O vetor aPRORAT tem a seguinte estrutura:                          //
		// 01 - Codigo do Criterio de Proporcao de Rateio (DTP_PRORAT)        //
		// 02 - Valor Total (100%) utilizado para Rateio/Proporcionar		  //
		// 03 - Determinacao por qual Criterio sera executado o Rateio		  //
		// 04 - Posicao em que refere-se nos vetores aRateio e aBaseRat		  //
		Aadd( aPRORAT, { StrZero(1, Len(DTP->DTP_PRORAT)), 0, .F., 00 } ) // Nao Utiliza
		Aadd( aPRORAT, { StrZero(2, Len(DTP->DTP_PRORAT)), 0, .F., 03 } ) // Peso Real
		Aadd( aPRORAT, { StrZero(3, Len(DTP->DTP_PRORAT)), 0, .F., 04 } ) // Peso Cubado
		Aadd( aPRORAT, { StrZero(4, Len(DTP->DTP_PRORAT)), 0, .F., 06 } ) // M3
		Aadd( aPRORAT, { StrZero(5, Len(DTP->DTP_PRORAT)), 0, .F., 02 } ) // Volumes
		Aadd( aPRORAT, { StrZero(6, Len(DTP->DTP_PRORAT)), 0, .F., 05 } ) // Vlr.Merc
		Aadd( aPRORAT, { StrZero(7, Len(DTP->DTP_PRORAT)), 0, .F., 07 } ) // KM
		Aadd( aPRORAT, { StrZero(8, Len(DTP->DTP_PRORAT)), 0, .F., 01 } ) // Qtd.Doc.Cliente
		Aadd( aPRORAT, { StrZero(9, Len(DTP->DTP_PRORAT)), 0, .F., 99 } ) // Qtd.Doc.Transp
		Aadd( aPRORAT, { 'A', 0, .F., 98 } ) // %Fixo
		Aadd( aPRORAT, { 'B', 0, .F., 09 } ) // Peso Previsto
		Aadd( aPRORAT, { 'C', 0, .F., 10 } ) // Peso Previsto x Realizado
		Aadd( aPRORAT, { 'D', 0, .F., 01 } ) // Qtd.Coletas
	

		If DTP->(ColumnPos("DTP_CRDVDC")) > 0
			// O vetor aCRDVDC tem a seguinte estrutura:                       //
			// 01 - Codigo do Criterio de Devedor Diversos (DTP_CRDVDC)        //
			// 02 - Valor Total (100%) utilizado para Rateio/Proporcionar		 //
			// 03 - Determinacao por qual Criterio sera executado o Rateio		 //
			// 04 - Posicao em que refere-se nos vetores (aRateio e aBaseRat)   //
			// ** A estrutura é a mesma do aPRORAT
					
			Aadd( aCRDVDC, { StrZero(0, Len(DTP->DTP_CRDVDC)), 0, .F., 00} ) // Nao Utiliza 
			Aadd( aCRDVDC, { StrZero(1, Len(DTP->DTP_CRDVDC)), 0, .F., 03 } ) // Peso Real
			Aadd( aCRDVDC, { StrZero(2, Len(DTP->DTP_CRDVDC)), 0, .F., 04 } ) // Peso Cubado
			Aadd( aCRDVDC, { StrZero(3, Len(DTP->DTP_CRDVDC)), 0, .F., 05 } ) // Vlr.Merc
			Aadd( aCRDVDC, { StrZero(4, Len(DTP->DTP_CRDVDC)), 0, .F., 02 } ) // Volumes
			Aadd( aCRDVDC, { StrZero(5, Len(DTP->DTP_CRDVDC)), 0, .F., 06 } ) // M3
			Aadd( aCRDVDC, { StrZero(6, Len(DTP->DTP_CRDVDC)), 0, .F., 01 } ) // Qtd Docto
		EndIf
		
		lRateio	:= Iif( lRateio .And. ValType(aRateio) == "A" .And. (Len(aRateio) > 0), .T., .F. )
	
		If lRateio
			nPRORAT := 0
			nCRDVDC := 0
	
			DTP->(dbSetOrder(2)) // DTP_FILIAL + DTP_FILORI + DTP_LOTNFC
			If DTP->(MsSeek(xFilial("DTP") + cFILORI + cLOTNFC))
				lRateio := Iif( lRateio .And. DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)), .T., .F.)
				lRateio := Iif( lRateio .And. DTP->DTP_BACRAT != StrZero(1, Len(DTP->DTP_BACRAT)), .T., .F.) // 1=Nao Utiliza
				lRateio := Iif( lRateio .And. DTP->DTP_CRIRAT != StrZero(1, Len(DTP->DTP_CRIRAT)), .T., .F.) // 1=Nao Utiliza
				lRateio := Iif( lRateio .And. DTP->DTP_PRORAT != StrZero(1, Len(DTP->DTP_PRORAT)), .T., .F.) // 1=Nao Utiliza
	
				nPRORAT := Ascan(aPRORAT, { |x| x[01] == DTP->DTP_PRORAT })
				nCRDVDC := Ascan(aCRDVDC, { |x| x[01] == DTP->DTP_CRDVDC })
	
				// Indicar por qual Regra de Proporcao Sera feito o Rateio //
				If nPRORAT > 0
					aPRORAT[nPRORAT][03] := .T.
				EndIf
				
		    Else
				lRateio := .F.
			EndIf
	
	    Else
			lRateio := .F.
		EndIf
	
		//---- Verifica a diferenca de Percentual do Cadastro com os que estao no lote
		If lRateio .And. DTP->DTP_PRORAT == 'A'  //%Fixo
			nPerDif   := TmsPerFix(aRateio,aPerFixDDP,DTP->DTP_CRDVFA,@nPerDDP)
		EndIf
		
		// A primeira posicao de cada Elemento existente no aRateio contem todos//
		// os dados base para calculo de Rateio, seguindo a seguinte estrutura: //
		// 		01 - Quantidade de Notas Fiscais                                //
		// 		02 - Quantidade Total de Volumes                                //
		// 		03 - Quantidade Total de Peso                                   //
		// 		04 - Quantidade Total de PesoM3                                 //
		// 		05 - Quantidade Total de Vlr.Mercadoria                         //
		// 		06 - Quantidade Total de M3                                     //
		// 		07 - Quantidade Total de KM                                     //
		// 		08 - Componentes de Frete ja Calculados                         //
		//  	09 - Quantidade Total Peso Previsto		      	 				 //
		//  	10 - Quantidade Total Peso Previsto x Realizado	 				 //		
		// 		11 - Codigo do Remetente                                        //
		// 		12 - Loja do Remetente                                          //
		//  	13 - Codigo do Destinatario                                     //
		//  	14 - Loja do Destinatario                                       //
		//  	15 - Codigo do Devedor                                          //
		//  	16 - Loja do Devedor                                            //
		//  	17 - Codigo do Cliente de Calculo                               //
		//  	18 - Loja do Cliente de Calculo                                 //
		//  	19 - Numero do Contrato                                         //
		//  	20 - Codigo do Servico                                          //
		//  	21 - Tipo de Transporte                                         //
		//  	22 - Tipo de veiculo					       				   		 //
       //     23 - Sequencia Endereco Destinatario								 //	
       //  	24 - Codigo Negociação                                          //
		//  	25 - Percentual Fixo (DDP)                                      //
		//  	26 - Valoriza Coleta Nao Realizada                              //
		//////////////////////////////////////////////////////////////////////////
	
		//////////////////////////////////////////////////////////////////////////
		// Obter todas as informacoes base para execucao do Rateio, onde essas	//
		// informacoes encontram-se na primeira posicao do vetor aRateio.		//
		//////////////////////////////////////////////////////////////////////////
		If lRateio
			nDoc   := Len(aRateio)
			
			For nCount1 := 1 To Len(aRateio)
	           //-- calcular o percentual fixo
	          If DTP->DTP_PRORAT == 'A' 
	          		nPerFix:= TmsCalPFix(DTP->DTP_CRDVFA,aRateio[nCount1][01][25],nPerDif,nDoc)
	          		lPerFix:= .T.
	          		
	          EndIf	
	          
	          //----------------------------------------------------------------------------------
	          //-- EAlberti - Inclui Documentos De Coleta Tratamento Da Valorização ('VALCOL')
	          //----------------------------------------------------------------------------------
	          aNFVlCol := {}
	          If IsInCallStack("TMSA340GRV") //-- Encerramento Da Viagem
					aAdd( aNFVlCol , aRateio[ nCount1 , 13 , 01 , 11] )
					aAdd( aNFVlCol , aRateio[ nCount1 , 13 , 01 , 12] )
			   EndIf	 	          		
						
				Aadd( aBaseRat, {	aRateio[nCount1][01][01],;			// 01 - Quantidade de Notas Fiscais
									aRateio[nCount1][01][02],;			// 02 - Quantidade Total de Volumes
									aRateio[nCount1][01][03],;			// 03 - Quantidade Total de Peso
									aRateio[nCount1][01][04],;			// 04 - Quantidade Total de PesoM3
									aRateio[nCount1][01][05],;			// 05 - Quantidade Total de Vlr.Mercadoria
									aRateio[nCount1][01][06],;			// 06 - Quantidade Total de M3
									aRateio[nCount1][01][07],;			// 07 - Quantidade Total de KM
									aClone(aRateio[nCount1][01][08]),;	// 08 - Componentes de Frete ja Calculados
									aRateio[nCount1][01][09],;			// 09 - Quantidade Total de Peso Previsto
									aRateio[nCount1][01][10],;			// 10 - Quantidade Total de Peso Previsto Realizado
									nPerFix ,;                         // 11 - Percentual Fixo do Cliente  
									aNFVlCol,;  							// 12 - NF Coleta
									Iif(lPerFix,aRateio[nCount1][01][15],'') ,;   // 13 - Cliente Devedor
									Iif(lPerFix,aRateio[nCount1][01][16],'') })   // 14 - Loja Devedor
				
				If nPRORAT > 0
					
					// Elemento 01 sera desconsiderado pois corresponde ao "NAO UTILIZA" //
					For nCount2 := 2 To (Len(aPRORAT))
						If nCount2 <> 9 .And. nCount2 <> 10  // Desconsiderar o elemento (09 e 10) do vetor aPRORAT
							If nCount2 == 7 .And. DTP->DTP_CRIRAT == 'A'   //7=Quantidade Total de KM e Criterio A=Orig/Dest Vge
								aPRORAT[nCount2][02] := DTP->DTP_KM
							Else  
								aPRORAT[nCount2][02] += aRateio[nCount1][01][ aPRORAT[nCount2][04] ]	
							EndIf							
						EndIf							
					Next	
					
					If DTP->DTP_PRORAT == 'A'  // Criterio %Fixo, devera ratear entre o mesmo Cliente devedor + Loja devedor
						nPosx := Ascan(aCliDev, { |x| x[01]+x[02] == aRateio[nCount1][01][15] + aRateio[nCount1][01][16] })
						If nPosx == 0
							aAdd(aCliDev,{aRateio[nCount1][01][15],aRateio[nCount1][01][16],aClone(aCRDVDC),0})
							nPosx:= Len(aCliDev)
						EndIf
						If nPosx > 0				
							// Elemento 01 sera desconsiderado pois corresponde ao "NAO UTILIZA" //
							For nCount2:=2 To Len(aCliDev[nPosx][3])
								aCliDev[nPosx][3][nCount2][02] += aRateio[nCount1][01][ aCRDVDC[nCount2][04] ]
							Next
							aCliDev[nPosx][4]+=1    //Utilizado no momento da prorporaçao do rateio para identificar o ultimo registro
						EndIf	
					EndIf	
				EndIf
			Next
			
			aPRORAT[09][02] := Len(aRateio) // 09 - Qtd.Doc.Transp
			
			//////////////////////////////////////////////////////////////////////////
			// Validar se foram informados mais de um conjunto de dados, onde caso	//
			// seja informado somente um unico conjunto, nao sera executado o Rateio//
			//////////////////////////////////////////////////////////////////////////
			lRateio	:= Iif ( lRateio .And. (Len(aRateio) > 1), .T., .F. )
		EndIf
	
		If lRateio
			aFretRat := {}
			
	
			// DTP_BACRAT : Base Calc.Ra - Quando:                                                   //
			// 		2=Ponto a Ponto - Nao sera necessario calcular pois os componentes da posicao 08 //
			// 		ja encontram-se calculados por origem e Destino de Cada Nota Fiscal do Cliente.  //
			// 		nesses casos sera obtido o Criterio de Calculo de Rateio DTP_CRIRAT:Crit.Calc.Ra //
			If DTP->DTP_BACRAT == StrZero(2, Len(DTP->DTP_BACRAT))
				nCRIRAT := Ascan(aCRIRAT, { |x| x[01] == DTP->DTP_CRIRAT })
	
				If nCRIRAT > 0
					nCRIRAT := aCRIRAT[nCRIRAT][02]
				EndIf
	
				// 3=Maior Vlr.Comp //
				If nCRIRAT == 99
					// Efetuar a Leitura do primeiro Elemento do vetor aBaseRat //
					// para com base nos Componentes de Frete desse elemento, comparar com os
					// componentes de Frete dos outros Elementos
					For nCount1 := 1 To Len(aBaseRat[01][08])
						nPosRat := 1
	
						// Efetuar a Leitura a partir do Segundo Elemento //
						For nCount2 := 2 To Len(aBaseRat)
							For nCount3 := 1 To Len(aBaseRat[nCount2][08])
								If aBaseRat[nCount2][08][nCount1][03] == aBaseRat[01][08][nCount1][03]
	
									If aBaseRat[nCount2][08][nCount1][02] > aBaseRat[nPosRat][08][nCount1][02]  //Compara com o ultimo valor (MAIOR) 
										nPosRat := nCount2
									EndIf
	
									Exit
								EndIf
							Next nCount3
						Next nCount2
	
						If nPosRat > 0
							Aadd( aFretRat, AClone( aBaseRat[nPosRat][08][nCount1] ) )
						EndIf
	
					Next nCount1
	
				// 4=Maior Peso Real;5=Maior Peso M3;6=Maior Vlr.Merc;7=Maior Vol;8=Maior KM;9=Maior M3 //
				ElseIf nCRIRAT > 0
					nTotBas := 0
					nPosRat	:= 0
	
					For nCount1 := 1 To Len(aBaseRat)
						If aBaseRat[nCount1][nCRIRAT] > nTotBas
							nPosRat := nCount1
							nTotBas := aBaseRat[nCount1][nCRIRAT]
						EndIf
					Next nCount1
	
					If nPosRat > 0
						aFretRat := aBaseRat[nPosRat][08]
					EndIf
				EndIf
	
	
			// DTP_BACRAT : Base Calc.Ra - Quando:                                                   //
			// 		3=Consolidado - Se faz necessario o calculo de Frete considerando o total da base//
			// 		(soma de todas as bases de calculo e considerando a Origem do Rateio (DTP_ORIRAT)//
			//		e tambem o Destino (DTP_CALRAT).                                                 //
			ElseIf DTP->DTP_BACRAT == StrZero(3, Len(DTP->DTP_BACRAT))
				nPosRat	:= 1 // Serao utilizados dados do primeiro elemento do vetor aRateio
	
				cCodCli	:= aRateio[nPosRat][01][17]
				cLojCli	:= aRateio[nPosRat][01][18]
				cServic	:= aRateio[nPosRat][01][20]
				cTipTra	:= aRateio[nPosRat][01][21]
				cNContr	:= aRateio[nPosRat][01][19]
				aTipVei := aRateio[nPosRat][01][22]
				cCliDev	:= aRateio[nPosRat][01][15]
				cLojDev	:= aRateio[nPosRat][01][16]
				cCliDes	:= aRateio[nPosRat][01][13]
				cLojDes	:= aRateio[nPosRat][01][14]
				cCodNeg	:= aRateio[nPosRat][01][24] 
				cORIRAT   := Iif(!Empty(DTP->DTP_ORIRAT),DTP->DTP_ORIRAT,aRateio[nPosRat][01][26])
				cCALRAT   := Iif(!Empty(DTP->DTP_CALRAT),DTP->DTP_CALRAT,aRateio[nPosRat][01][28])
				nPeso		:= aPRORAT[02][02]
				If DTP->DTP_PRORAT == 'B' //Maior Peso Previsto
					nPesoCal	:= aPRORAT[11][02]
				ElseIf DTP->DTP_PRORAT == 'C' //Maior Peso Previsto x Realizado
					nPesoCal	:= aPRORAT[12][02]
				EndIf	   
	
				cSerTms	:= Posicione('DC5', 1, xFilial('DC5') + cServic, 'DC5_SERTMS' )
				If lIdentDoc
					cDocTms	:= DTC->DTC_DOCTMS
				Else
					cDocTms	:= Posicione('DC5', 1, xFilial('DC5') + cServic, 'DC5_DOCTMS' )
				EndIf 	

				If cSerTMS == "1"
					If DDA->(ColumnPos("DDA_CBRCOL")) > 0 .And. DDC->(ColumnPos("DDC_CBRCOL")) > 0
						lCbrCol := (TmsSobServ('CBRCOL',.T.,.T.,cNContr,cCodNeg,cServic,"0",@nAdiDoc) $ " 1")
					EndIf
					If DDA->(ColumnPos("DDA_BLQCOL")) > 0 .And. DDC->(ColumnPos("DDC_BLQCOL")) > 0
						lBlqCol := (TmsSobServ('BLQCOL',.T.,.T.,cNContr,cCodNeg,cServic,"0",@nAdiDoc) $ " 1")
					EndIf
				EndIf

				lInvOri := (DTC->(ColumnPos("DTC_INVORI")) > 0 .And. DTC->DTC_INVORI == "1")
				
				aFretRat:= TMSCalFret(	DTP->DTP_TABRAT,	DTP->DTP_TIPRAT,	@cSeqTab,		cORIRAT,	cCALRAT,;
										cCodCli,			cLojCli,			cCodPro,		cServic,			cSerTms,;
										cTipTra,			cNContr,			aMsgErr,		/*aNfCTRC*/,		aPRORAT[06][02],;
										nPeso,	aPRORAT[03][02],  	/*nPesoCob*/,	aPRORAT[05][02],	/*nDesconto*/,;
										/*nSeguro*/,		/*nMetro3*/,		/*nQtdDco*/,	/*nDiaSem*/,		Iif(DTP->DTP_CRIRAT == 'A', DTP->DTP_KM, aPRORAT[07][02]),;
										/*nPerNoi*/,		/*lMinimo*/,		lCliGen,		lAjuAut,			/*nQtdEnt*/,;
										nQtdUni,			/*nValDpc*/,		/*nDocSImp*/,	/*nDocCImp*/,		aValInf,;
										aTipVei,			cDocTms,			/*nDiaFimSem*/,	/*nPesoVge*/,		/*nPesoM3Vge*/,;
										/*nMetro3Vge*/,		/*nValMerVge*/,		/*nQtdVolVge*/,	/*nDiaArm*/,		/*aFaixaTab*/,;
										cLOTNFC,			/*aPesCub*/,		lPrcPdg,		cCliDev,			cLojDev,;
										/*nMoeda*/,			/*cExcTDA*/,		/*cDEVTDA*/,	/*cRemTDA*/,		/*cDesTDA*/,;
										/*nQtdCol*/,		cCliDes, 			cLojDes,		/*cSeqDes*/,;
										/*nSeqDoc*/,		/*lRateio*/,		/*aBaseRat*/,	/*aCompCalc*/	, cCodNeg, /*aTaxDev*/,/*aFretCol*/,;
										lCbrCol, lBlqCol, lInvOri )
	
				If !Empty(DTP->DTP_TBARAT) .And. !Empty(DTP->DTP_TPARAT)
					nPosRat := Ascan( aFretRat,{|x| x[3] == 'TF' })
	
					//-- Guardar o total do frete da composicao obtida acima
					If nPosRat > 0
						nValFret := aFretRat[ nPosRat, 2 ]
					EndIf
	
					aAlteRat:= TMSCalFret(	DTP->DTP_TBARAT,	DTP->DTP_TPARAT,	@cSeqTab,		DTP->DTP_ORIRAT,	DTP->DTP_CALRAT,;
											cCodCli,			cLojCli,			cCodPro,		cServic,			cSerTms,;
											cTipTra,			cNContr,			aMsgErr,		/*aNfCTRC*/,		aPRORAT[06][02],;
											nPeso,	aPRORAT[03][02],  	/*nPesoCob*/,	aPRORAT[05][02],	/*nDesconto*/,;
											/*nSeguro*/,		/*nMetro3*/,		/*nQtdDco*/,	/*nDiaSem*/,		Iif(DTP->DTP_CRIRAT == 'A', DTP->DTP_KM, aPRORAT[07][02]),;
											/*nPerNoi*/,		/*lMinimo*/,		lCliGen,		lAjuAut,			/*nQtdEnt*/,;
											nQtdUni,			/*nValDpc*/,		/*nDocSImp*/,	/*nDocCImp*/,		aValInf,;
											aTipVei,			cDocTms,			/*nDiaFimSem*/,	/*nPesoVge*/,		/*nPesoM3Vge*/,;
											/*nMetro3Vge*/,		/*nValMerVge*/,		/*nQtdVolVge*/,	/*nDiaArm*/,		/*aFaixaTab*/,;
											cLOTNFC,			/*aPesCub*/,		lPrcPdg,		cCliDev,			cLojDev,;
											/*nMoeda*/,			/*cExcTDA*/,		/*cDEVTDA*/,	/*cRemTDA*/,		/*cDesTDA*/,;
											/*nQtdCol*/,		cCliDes, 			cLojDes,		 		/*cSeqDes*/,;
											/*nSeqDoc*/,		/*lRateio*/,		/*aBaseRat*/,	/*aCompCalc*/, cCodNeg, /*aTaxDev*/,/*aFretCol*/,;
											lCbrCol, lBlqCol, lInvOri )
	
					If Len(aAlteRat) > 0
						//-- Total do frete, obtido com a tabela alternativa
						nPosRat := Ascan( aAlteRat,{|x| x[3] == 'TF' })
	
						// Sendo o Valor de Frete da Alternativa, esse sera a Base de Rateio
						If (nPosRat > 0) .And. (aAlteRat[ nPosRat, 2 ] > nValFret)
							aFretRat := {}
							aFretRat := aClone( aAlteRat )
							lTBARAT  := .T.
						EndIf
					EndIf
	            EndIf
			EndIf
	
			lRateio	:= Iif ( lRateio .And. (Len(aFretRat) > 0), .T., .F. )
		EndIf
	
	
		// Obter os Componentes que encontram-se configurados como RATEIO //
		If lRateio
			cAliasQry	:= GetNextAlias ()
			cQuery := ""
			cQuery += " SELECT DVE.DVE_CODPAS, DVE.DVE_DIZIMA " + CRLF
			cQuery +=   " FROM " + RetSqlName ("DVE") + " DVE " + CRLF
			cQuery +=  " WHERE DVE.DVE_FILIAL = '" + xFilial("DVE") + "' "	+ CRLF
			cQuery +=    " AND DVE.DVE_TABFRE = '" + Iif(lTBARAT, DTP->DTP_TBARAT, DTP->DTP_TABRAT) + "' " + CRLF
			cQuery +=    " AND DVE.DVE_TIPTAB = '" + Iif(lTBARAT, DTP->DTP_TPARAT, DTP->DTP_TIPRAT) + "' " + CRLF
			cQuery +=    " AND DVE.DVE_RATEIO = '" + StrZero(1, Len(DVE->DVE_RATEIO)) + "' " + CRLF
			cQuery +=    " AND DVE.D_E_L_E_T_ = ' '" + CRLF
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasQry, .F., .T.)
	
			(cAliasQry)->(DbGoTop())
	
			While (cAliasQry)->( !Eof() )
				Aadd( aCompRat, {(cAliasQry)->DVE_CODPAS,(cAliasQry)->DVE_DIZIMA,})
	
				(cAliasQry)->( DbSkip() )
			EndDo
	
			(cAliasQry)->(DbCloseArea())
	
			lRateio	:= Iif ( lRateio .And. (Len(aCompRat) > 0), .T., .F. )
		EndIf
	
		If lRateio
			// Retirar do vetor aFretRat todos os Componentes que nao sejam de Rateio //
			nCount1 := 0
	
			While .T.
				nCount1 += 1
	
				nPosRat := Ascan( aCompRat,{|x| x[1] == aFretRat[nCount1][03] })
	
				If nPosRat == 0
					aDel(aFretRat, nCount1)
					aSize(aFretRat, Len(aFretRat) - 1 )
					nCount1 := 0
				Else
					aCompRat[nPosRat,3] := Aclone(aFretRat[nCount1])
				EndIf
	
				If nCount1 == Len(aFretRat)
					Exit
				EndIf
			EndDo
	
			// Obter a BASE TOTAL que sera utilizada para Proporcionar	//
			// o Rateio conforme o Criterio de Proporcao de Rateio		//
			nTotBas := aPRORAT[nPRORAT][02]

	        // Efetuar a leitura dos Componentes configurados como RA-	//
	        // teio e com base em cada um, efetuar a leitura dos compo-	//
	        // nentes calculados e executar o rateio.					//
			For nCount1 := 1 To Len(aCompRat)

				nValFret  := 0
				nDifRat   := 0
				nTotVlrRat:= 0
				nTotVlrDiz:= 0

				//----------------------------------------------------------------------------------
				//- EAlberti -> INICIO - Rateia Valor Das Coletas Não Realizadas Quando Configurado
				//----------------------------------------------------------------------------------
				
				nPosElm := aPRORAT[nPRORAT][04]
				For nCol1 := 1 To Len(aBaseRat)
	
					//-- Verifica Se Existe NF Coleta Informada
					If Len(aBaseRat[nCol1,12]) > 0
					
						nCol2 := 0
						For nCol2 := 1 To Len(aBaseRat[nCol1][08])

							//-- Verifica Se Este Componente De Frete Tem Rateio
							If aBaseRat[nCol1][08][nCol2][03] == aCompRat[nCount1][1] 
					
								//-- Posiciona Nas Coletas
								DbSelectArea("DT5")
								DbSetOrder( 4 ) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
								If MsSeek( FWxFilial('DT5') + cFilAnt + aBaseRat[nCol1,12,01] + aBaseRat[nCol1,12,02] , .F. )
								
									//-- Valorização De Coleta
									nAdiDoc := 0
									If TmsSobServ('VALCOL',.T.,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0",@nAdiDoc) == '2' //-- 1 = Val. Todas ; 2 = Somente Coletadas
		
										//-- Posiciona Nas Ocorrencias da Viagem
										DbSelectArea("DUA")
										DbSetOrder(4) //-- DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM
										If MsSeek( FWxFilial("DUA") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE , .F.)
		
											//-- Procura Por Ocorrencias De Cancelamento
											While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE == xFilial("DUA") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE
											
												//-- Posiciona No Cad. Ocorrencias
												DbSelectArea("DT2")
												DbSetOrder(1)
												MsSeek( FWxFilial("DT2") + DUA->DUA_CODOCO , .F. )
												
												If DT2->DT2_TIPOCO == StrZero(12,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(04,Len(DT2->DT2_TIPOCO))

													nValBas := aBaseRat[ nCol1 , nPosElm ]
													aBaseRat[ nCol1 , nPosElm ] := 0
													Exit

												EndIf	
		
												DUA->(DbSkip())
											EndDo
										EndIf
									EndIf						
								EndIf
							EndIf
						Next nCol2		
					EndIf
				Next nCol1		

				//-- Se Houver Valores Alterados Redistribui Pesos Proporcionalmente
				If nValBas > 0

					nBasDist := 0	//-- Determina Peso Base Para Redistribuição
					nUltVal  := 0 //-- Determina Ultima Posição Do Vetor Que Contém Valor Maior Que Zero (Para o Arredondamento) ( Campos Zerados Não Podem Receber Saldos De Arredondamento )

					For nCol1 := 1 To Len(aBaseRat)
						nBasDist += aBaseRat[ nCol1 , nPosElm ]
						nUltVal  := Iif( (aBaseRat[ nCol1 , nPosElm ]) > 0 , nCol1 , nUltVal ) 
					Next nCol1	
					
					//-- Proporcionaliza Novo Peso
					If nValApl == 0
						For nCol1 := 1 To Len(aBaseRat)
						
							//-- Se Estiver Zerado, Não Efetuou a Coleta
							If aBaseRat[ nCol1 , nPosElm ] > 0
							
								If nCol1 <> nUltVal
									nValCalc := ( nValBas / ( nBasDist / aBaseRat[ nCol1 , nPosElm ] ) )
									aBaseRat[ nCol1 , nPosElm ] += nValCalc
									nValApl += nValCalc
								Else
									aBaseRat[ nCol1 , nPosElm ] += ( nValBas - nValApl )
								EndIf							
							EndIf				
					
						Next nCol1
					EndIf
				EndIf
				//----------------------------------------------------------------------------------
				//- EAlberti -> FIM    - Rateia Valor Das Coletas Não Realizadas Quando Configurado
				//----------------------------------------------------------------------------------

				// Obter Valor de Frete Base para Rateio				//
				For nCount2 := 1 To Len(aFretRat)
					If aFretRat[nCount2][03] == aCompRat[nCount1][1]
						nValFret := aFretRat[nCount2][02] //--> Valor a Ser Rateado
						Exit
					EndIf
				Next

				//-- Antes de inciar o rateio do componente entre os documentos, o sistema verifica se a composição do documento atual
				//-- possui o componente a ser rateado. Isto porque se não possuir, o rateio do total do componente fica somente proporcionalizado
				//-- naquele documento que possui o componente calculado inicialmente. Isto ocorre no componente do tipo de valor informado,
				//-- quando lançado numa única nota. Para contornar esta situação o sistema cria uma linha com os dados do componente no vetor
				//-- de frete do documento, porém com o valor igual a zero.
				For nCount2 := 1 To Len(aBaseRat)
					If (nPosRat := Ascan(aBaseRat[nCount2][08],{|x| x[3] == aCompRat[nCount1][1]})) == 0 .And. nValFret > 0
						Aadd(aBaseRat[nCount2][08],Aclone(aCompRat[nCount1][03]))
						aBaseRat[nCount2][08][Len(aBaseRat[nCount2][08])][02] := 0
					EndIf
				Next nCount2
				For nCount2 := 1 To Len(aBaseRat)

					lQtdDocT := .F.
					nPerFix  := 0
					nValFreFx:= 0

					// Obter a Base de Rateio do Documento	//
					// 9=Qtd.Doc.Transp        				//
					If aPRORAT[nPRORAT][04] == 99
						nBaseDOC := Len(aBaseRat)
						lQtdDocT := .T.
			
					ElseIf aPRORAT[nPRORAT][04] == 98 //%Fixo	
						nPerFix:= aBaseRat[nCount2][11]
						//Valor de Frete Base para Rateio com o percentual fixo
						nValFreFx := (nPerFix * nValFret / 100)
						lQbrCliDev := .F.
						//--- Base para Rateio com base no vetor aCRDVDC
						nPosx := Ascan(aCliDev, { |x| x[01]+x[02] == aBaseRat[nCount2][13] + aBaseRat[nCount2][14] })
						If nPosx > 0
							nTotBas := aCliDev[nPosx][3][nCRDVDC][02]
							nBaseDOC:= aBaseRat[nCount2][aCRDVDC[nCRDVDC][04]]
							aCliDev[nPosx][4]-= 1	
			
							//--- Verifica se é o ultimo registro do abaseRat do determinado Cliente+Loja Devedor 
							//--- quando ocorre rateio por CRDVDC. Utilizado para aplicar a diferença de centavos  
							If aCliDev[nPosx][4] == 0
								lQbrCliDev:= .T.
							EndIf	
						EndIf
					// 2=Peso Real;3=Peso Cubado;4=M3;5=Volumes;6=Vlr.Merc;7=KM;8=Qtd.Doc.Cliente//
					ElseIf aPRORAT[nPRORAT][04] > 0
						nBaseDOC := aBaseRat[nCount2][aPRORAT[nPRORAT][04]] //--> Peso Da NF Posicionada
						
					EndIf
					
					// Formula do Rateio...: Peso Docto / Peso Total * Valor do Frete = Valor de Frete Rateado //
					// Variaveis do Rateio.: nBaseDOC / nTotBas * nValFret = Novo Valor (Rateado) do Componente// 
					// Percentual do Rateio: Peso Docto / Peso Total * 100	   								   //
					For nCount3 := 1 To Len(aBaseRat[nCount2][08])

						If aBaseRat[nCount2][08][nCount3][03] == aCompRat[nCount1][1] 
							
							nValRat:= Iif(lQtdDocT, (nValFret / nTotBas), Iif(lPerFix,(nBaseDOC / nTotBas * nValFreFx),(nBaseDOC / nTotBas * nValFret)) )   
							
							If aCompRat[nCount1][2] == '1'   //Calcula Dizima
								If nValRat > 0 .And. nValRat < 0.01
									nValRat:= 0.01
									nTotVlrDiz+= nValRat 
								EndIf
							EndIf	
							
							aBaseRat[nCount2][08][nCount3][02] := Round(nValRat, 2)
																				
							nTotVlrRat += aBaseRat[nCount2][08][nCount3][02]												
							nTotVlrFix += aBaseRat[nCount2][08][nCount3][02]
	
							If Len(aBaseRat[nCount2][08][nCount3]) >= 21
								nPercent:= 100
								If lPerFix
									nPercent:= nPerFix
								EndIf
								aBaseRat[nCount2][08][nCount3][21] := Iif(lQtdDocT, Round(((nValFret / nTotBas) / nValFret) * 100, 2),;
																						Round(nBaseDOC / nTotBas * nPercent, 2))// % Rateio														
							EndIf 
							
							//--- Diferenças de Centavos, soma diferença no ultimo componente ou na quebra do Cliente+Loja Devedor (crdvdc)
							If nBaseDOC <> 0   //---Quando a viagem de coleta todos os documentos receberem a ocorrencia de retorna documento e valoriza coleta realizada igual a Nao
							                     //---o valor do rateio fica zerado   
							
								If nTotVlrDiz == 0  
									If (nCount2  ==  Len(aBaseRat)) 
										nDifRat:= (nValFret - nTotVlrRat)
									ElseIf lQbrCliDev
										nDifRat:= (nValFreFx - nTotVlrFix) 
										nTotVlrFix:= 0									
									EndIf
									If nDifRat <> 0
										aBaseRat[nCount2][08][nCount3][02] += nDifRat
									EndIf
								Else
									If nCount2  ==  Len(aBaseRat) 
										//---- Calculo da Dizima, procura um documento para subtrair o valor da Dizima.
										lDizima   := .F.
		
										For nCount4:= 1 To Len(aBaseRat)
											For nCount5:= 1 To Len(aBaseRat[nCount4][08])
												If aBaseRat[nCount4][08][nCount5][03] == aCompRat[nCount1][1] 
													If (aBaseRat[nCount4][08][nCount5][02] - nTotVlrDiz) > 1   //Verifica se há saldo para subtrair a dizima
														aBaseRat[nCount4][08][nCount5][02]-= nTotVlrDiz
													
														//--- Verifica se ha diferenca de centavos
														nDifRat:= (nValFret - (nTotVlrRat - nTotVlrDiz)) 
														If nDifRat > 0
															aBaseRat[nCount4][08][nCount5][02] += nDifRat
														EndIf
														lDizima:= .T.
														Exit
													EndIf
												EndIf 
											Next
											If lDizima
												Exit
											EndIf
										Next	
							       EndIf
								EndIf							       
							EndIf
								
							Exit
						EndIf
					Next
				Next
			Next
		EndIf
	
		If lRateio
			For nCount1 := 1 To Len(aBaseRat)
				Aadd( aRet, aClone( aBaseRat[nCount1][08] ) )
			Next
		EndIf
	EndIf
	
	AEval( aAreas, { |x| RestArea(x) } )
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSLRateio³ Autor ³Adalberto S.M          ³ Data ³11.12.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel por Validar se o Lote trata-se ou nao de³±±
±±³          ³ Lote do tipo Rateio										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSLRateio( cFILORI, cLOTNFC )
	Local lRateio	:= .F.

	Default cFILORI := ""
	Default cLOTNFC := ""

	dbSelectArea("DTP")
	dbSetOrder(2)
	If DTP->(MsSeek(xFilial("DTP") + cFILORI + cLOTNFC))
		If DTP->DTP_RATEIO == StrZero(1, Len(DTP->DTP_RATEIO)) 
			If  !("TMSA500" $ FunName())  // Desconsiderar Rateio quando execucao Originar do TMSA500
				lRateio	:= 	.T.
			EndIf
		EndIf	
	EndIf
Return(lRateio)

//+--------------------------------------------------------------------------
/*{Protheus.doc}
TMSRESTRI
Description

@owner paulo.henrique
@author paulo.henrique
@since 15/08/2014
@param Params
	cTipReg = Tipo da Regra C = Cliente / A = Area / T = Todos
	aCepDeAte =  Array com  {Cep Inicial,Cep Final} existente na rota
	cRota   = Codigo da Rota
	aCliLoj = Array com Cod. Cliente/ Cod. Loja
	aCodVei = codigos dos Veiculos da viagem
	cTipRes = Tipo de Restricao B = Regr. Bloquead / I = Regr. Informativa / T = Todas
	cData 	= Data para verificar restrições.
	aSerTms =  Array com  {cSerTms,Cod. Cliente,Cod. Loja} de cada documento
	lExiTelInf = Exibe Tela das Restrições Informativas
	aCepCliDoc = Recebe 
@return aRet = { {[Logico - Houve restrições]},
			   { [Mensagem - contendo as Descrições das Restrições] },
			   { [aRestrições - contendo os dados das Restrições] } }
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function TMSRESTRI(cTipReg, aCepDeAte, cRota, aCliLoj, aCodVei, cTipRes, cData, aSerTms , lExiTelInf, aCepCliDoc, cFilVia , cNumVia )

Local aArea 		:= GetArea()			// Recebe a Area ativa
Local aAreaDA8	:= DA8->( GetArea() )	// Recebe a Area da DA8
Local aAreaSA1   	:= SA1->( GetArea() )	// Recebe a Area da SA1
Local aAreaDUT   	:= DUT->( GetArea() )	// Recebe a Area da DUT
Local cQuery		:= ""					// Recebe a Query
Local aRestricoes	:= {}					// Recebe as Restrições
Local cTipVei		:= "" 					// Recebe o tipo de Veiculo
Local cFinPlac		:= ""					// Recebe o final da placa do veiculo
Local aAreasRes		:= {}					// Recebe as areas de restrição
Local aInfs			:= {}					// Recebe as Restrições informaticas
Local aRegras		:= {}					// Recebe as regras
Local cINReg		:= ""					// Recebe a Clausula IN dos codigos de Regras
Local nCount		:= 0 					// Recebe o Contador
Local nLenReg		:= 0 					// Recebe o Tamanho do array
Local cPlaca		:= ""					// Recebe a Placa do Veiculo
Local cDiaSem		:= ""					// Recebe o Dia da Semana
Local aRet			:= {}					// Recebe o Retorno
Local cMsgRet		:= ""					// Recene as mensagens de retorno
Local cSerTms		:= ""					// Recebe a Linha do Serviço
Local nLenSerTms	:= 0 					// Recebe o Tamanho do Array de Servico TMS
Local cMVTMSRLC		:= ""					// Recebe o Parametro referente ao tipo da Rotina de Restrições

DEFAULT cTipReg		:= ""
DEFAULT aCepDeAte	:= {}
DEFAULT cRota		:= ""
DEFAULT aCliLoj		:= {}
DEFAULT aCodVei		:= {}
DEFAULT cTipRes		:= ""
DEFAULT cData		:= DTOS(Date())
DEFAULT aSerTms		:= {}
DEFAULT lExiTelInf	:= .T.
DEFAULT aCepCliDoc	:= {}
DEFAULT cFilVia		:= "XX"		//-- Se Não Informado Descarta Left Join
DEFAULT cNumVia		:= "XXXXXX"	//-- Se Não Informado Descarta Left Join

cMVTMSRLC := SuperGetMV( 'MV_TMSRLC' ,,'0')

If cMVTMSRLC != "0" // Não Utiliza Restições

	// Verifica qual o Tipo do Parametro
	If cMVTMSRLC == '1' // Por CEP's dos documentos
		aCepDeAte := {}
	ElseIf cMVTMSRLC == '2' // Por faixas de CEP da rota
		aCepCliDoc	:= {}
	EndIf
	
	// Busca os dados do Veiculo
	If !Empty(aCodVei)
		dbSelectArea("DA3")
		DA3->( dbSetOrder(1) )
	
		For nCount := 1 to Len(aCodVei)
		
			If DA3->(dbSeek(FwxFilial("DA3")+ aCodVei[nCount]))
	
				// Tipo do Veiculo
				cTipVei += "'"+ DA3->DA3_TIPVEI +"'"
	
				// Placa
				cPlaca	 := AllTrim(POSICIONE("DA3",1,xFilial("DA3") + aCodVei[nCount], "DA3_PLACA"))
				cFinPlac += " DIV.DIV_PLACA LIKE '%"+ SubStr(cPlaca, Len(cPlaca), Len(cPlaca) ) +"%' "
	
				If nCount <  Len(aCodVei)
					cTipVei  += ","
					cFinPlac += " OR"
				EndIf
			Else
				// Retira a ultima virgula da clausula IN
				If !Empty(cTipVei)
					cTipVei := SubStr(cTipVei, 1, Len(cTipVei)-1 )
				EndIf
	
				If !Empty(cFinPlac)
					cFinPlac := SubStr(cFinPlac, 1, Len(cFinPlac)-2 )
				EndIf
	
			EndIf
		Next nCount
	
		// Busca por placas vazias
		If !Empty(cFinPlac)
			cFinPlac := " ( ("	+ cFinPlac + " OR DIV.DIV_PLACA = '"+ Space(TamSX3("DIV_PLACA")[1]) +"' ) AND DIV.DIV_SERTMS = '')"
		EndIf
	
	EndIf
	
	//Busca Dia da Semana
	If !Empty(cData)
		cDiaSem	:= Alltrim(AllToChar(Dow( STOD(cData) ) ) )
	EndIf
	
	//-- TRATAMENTO
	cTipReg := AllTrim(Upper(cTipReg))
	cTipRes := AllTrim(Upper(cTipRes))
	
	// Busca as Areas de Restrição referente aos CEP's da Rota
	If !Empty(aCepDeAte) .OR. !Empty(cRota) .OR. !Empty(aCepCliDoc)
		aAreasRes := A024BusArs(aCepDeAte,cRota,aCepCliDoc)
	EndIf
	
	// Busca as Regras de Restrição
	If !Empty(aCliLoj) .OR. !Empty(aAreasRes)
		aRegras := A024BusReg(aCliLoj, aAreasRes,cTipReg,cData)
	EndIf
	
	//Verifica as Outras restrições informativas
	If cTipRes $ 'T|I' .AND. !Empty(aRegras)
		aInfs := A024BusInf(aRegras, lExiTelInf)
	EndIf
	
	// Cria a String com os códigos das Regras de Restição
	nLenReg := Len(aRegras)
	
	If nLenReg > 0

		cINReg := ""
		For nCount := 1 to nLenReg
			cINReg += Iif(Empty(cINReg),"",",") + aRegras[nCount]
		Next nCount
	
		// ------------------------------+
		//   BUSCA RESTRICOES DIA SEMANA |
		// ------------------------------+
		cQuery := ""
		cQuery +="SELECT 			DIU.DIU_CODREG, "
		cQuery +="					DIU.DIU_CODCLI, "
		cQuery +="					DIU.DIU_LOJCLI, "
		cQuery +="					DIU.DIU_NOMCLI, "
		cQuery +="					DIU.DIU_CODARE, "
		cQuery +="					DIU.DIU_DESARE, "
		cQuery +="		   			DIV.DIV_ITEM,   "
		cQuery +="		   			DIV.DIV_DESCRI, "
		cQuery +="		   			DIV.DIV_HORINI, "
		cQuery +="		   			DIV.DIV_HORFIM, "
		cQuery +="		   			DIV.DIV_TIPVEI, "
		cQuery +="		   			ISNULL(DUD.DUD_FILDOC,'') AS DUD_FILDOC, "
		cQuery +="		   			ISNULL(DUD.DUD_DOC   ,'') AS DUD_DOC, "
		cQuery +="		   			ISNULL(DUD.DUD_SERIE ,'') AS DUD_SERIE "		
		cQuery +=" FROM 			" + RetSqlName("DIU") + " DIU "

		cQuery +=" INNER JOIN 	" + RetSqlName("DIV") + " DIV "
		cQuery +=" ON				DIU.DIU_FILIAL	=  DIV.DIV_FILIAL "
		cQuery +=" AND			DIU.DIU_CODREG 	=  DIV.DIV_CODREG "

		//-- Filtra Cód. De Regra
		If !Empty(cInReg)
			cQuery +=" AND		DIU.DIU_CODREG IN " + FormatIn( cInReg , "," )
		EndIf	

		cQuery +=" AND			DIU.D_E_L_E_T_ 	=  ' ' "

		cQuery +=" LEFT JOIN   	" + RetSqlName("DIS") + " DIS "
		cQuery +=" ON          	DIS.DIS_FILIAL 	=  '" + xFilial("DIS") + "' "
		cQuery +=" AND         	DIS.DIS_CODARE 	=  DIU.DIU_CODARE "
		cQuery +=" AND         	DIS.D_E_L_E_T_ 	=  ' ' "

		cQuery +=" LEFT JOIN   	" + RetSqlName("DUD") + " DUD "
		cQuery +=" ON          	DUD.DUD_FILIAL 	=  '" + xFilial("DUD")  	+ "' "
		cQuery +=" AND         	DUD.DUD_FILORI 	=  '" + cFilVia  	    	+ "' "
		cQuery +=" AND         	DUD.DUD_VIAGEM 	=  '" + cNumVia 			+ "' "
		cQuery +=" AND         	DUD.DUD_CEPENT 	BETWEEN DIS.DIS_CEPINI AND DIS.DIS_CEPFIM "
		cQuery +=" AND         	DUD.D_E_L_E_T_ 	=  ' ' "

		cQuery +=" WHERE 			DIV.DIV_FILIAL 	=  '" + FwxFilial("DIV") + "' "
		cQuery +=" AND			DIV.D_E_L_E_T_ 	=  ' ' "
	
		// Dia da semana
		If !Empty(cDiaSem)
			cQuery +="	AND	DIV.DIV_DIASEM 			=  '" + cDiaSem + "' "
		EndIf
	
		// Monta a Query do serviço de TMS
		nLenSerTms :=  Len(aSerTms)
		If nLenSerTms > 0
			cSerTms	+= "	( "
			For nCount = 1 To nLenSerTms
	
				cSerTms	+=  " (DIV.DIV_SERTMS = '"+ aSerTms[nCount][1] + "' AND (  DIU_CODCLI = '" + aSerTms[nCount][2]  + "' AND DIU_LOJCLI = '" + aSerTms[nCount][3] + "')  )  "
	
				If nCount <  nLenSerTms
					cSerTms	+=  " OR "
				EndIf
			Next nCount
			cSerTms	+= " ) "
		EndIf
	
		// Placa ou Serviço de transporte
		If !Empty(cSerTms) .AND. Empty(cFinPlac)
			cQuery += " AND " + cSerTms
		ElseIf !Empty(cFinPlac) .AND. Empty(cSerTms)
			cQuery +="	AND	"+ cFinPlac
		ElseIf !Empty(cSerTms) .AND. !Empty(cFinPlac)
			cQuery +="	AND	(" + cSerTms + "OR "+ cFinPlac +" )"
		EndIf
	
		// Tipo do Veiculo
		If !Empty(cTipVei)
			cQuery +="		AND ( DIV.DIV_TIPVEI IN ("+cTipVei+") OR DIV.DIV_TIPVEI = '"+ Space(TamSX3("DIV_TIPVEI")[1]) +"' )"
		EndIf
	
		// Busca restricoes Dia Semana
		A024QyRest("DIV",cQuery,@aRestricoes)  
	
	
		// Verifica Restrições de Usuario
		If cTipRes $ 'T|B'
			// -----------------------------------+
			// BUSCA RESTRICOES OUTRAS RESTRICOES |
			// -----------------------------------+
			cQuery := ""
			cQuery +=" SELECT			DIU.DIU_CODREG,"
			CqUERY +="					DIU.DIU_CODCLI,"
			cQuery +="					DIU.DIU_LOJCLI,"
			cQuery +="					DIU.DIU_NOMCLI,"
			cQuery +="					DIU.DIU_CODARE,"
			cQuery +="					DIU.DIU_DESARE,"
			cQuery +="					DIX.DIX_TIPREG,"
			cQuery +="		   			DIX.DIX_ITEM, "
			cQuery +="		   			DIX.DIX_DESCRI, "
			cQuery +="		   			DIX.DIX_ACAO"
			cQuery +=" FROM 			" + RetSqlName("DIX") + " DIX"
			cQuery +=" INNER JOIN 	" + RetSqlName("DIU") + " DIU "
			cQuery +=" ON 			DIU.DIU_FILIAL 	=  DIX.DIX_FILIAL "
			cQuery +=" AND			DIU.DIU_CODREG 	=  DIX_CODREG "
	
			//-- Filtra Cód. De Regra
			If !Empty(cInReg)
				cQuery +=" AND		DIU.DIU_CODREG IN " + FormatIn( cInReg , "," )
			EndIf	

			cQuery +=" AND 			DIU.D_E_L_E_T_ 	= ' '"
			cQuery +=" WHERE 			DIX.DIX_FILIAL 	= '"+FwxFilial("DIX")+"' "
			cQuery +=" AND 			DIX.DIX_TIPREG 	= '1' " // Tipo de Regra =  Bloqueio
			cQuery +=" AND 			DIX.D_E_L_E_T_ 	= ' '"
	
			// Busca Outras Restricoes
			A024QyRest("DIX",cQuery,@aRestricoes)

		EndIf
	EndIf

	// Mensagens de Retorno Informativas
	For nCount := 1 To Len(aInfs)
		cMsgRet += aInfs[nCount][9] + Chr(13)+ Chr(10)
	Next nCount
	
	// Mensagens de Retorno das Restrições
	For nCount := 1 To Len(aRestricoes)
		cMsgRet += aRestricoes[nCount][9] + Chr(13)+ Chr(10)
	Next nCount
EndIf
	
If Len(aRestricoes) > 0
	AADD(aRet,.T.)
	AADD(aRet,cMsgRet)
	AADD(aRet,aRestricoes)
Else
	AADD(aRet,.F.)
	AADD(aRet,cMsgRet)
	AADD(aRet,{})
EndIf

RestArea( aAreaDA8 )
RestArea( aAreaSA1 )
RestArea( aAreaDUT )
RestArea(aArea)

Return(aRet)

//+--------------------------------------------------------------------------
/*{Protheus.doc}
BusCliServ
Description
Retorna os Clientes, Serviços de Transpote dos documentos e Ceps do Documento.
@owner paulo.henrique
@author paulo.henrique
@since 05/01/2015
@param Params
		aCliLoj =  { {CodCli, LojCli} }   		// Paramentro deve ser passado por referencia
		aSerTms =  { {SerTms,CodCli, LojCli}  } // Paramentro deve ser passado por referencia
		aCepCli =  { CepCli } // Paramentro deve ser passado por referencia
@return
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
	Deve estar posicionado na tabela DT6
@history History
/*/
//+--------------------------------------------------------------------------
Function BusCliServ(aCliLoj,aSerTms,aCepCli)
Local cSerTmsDoc := ""				// Recebe o Serviço de Transporte
Local cCliRest	 := ""				// Recebe o Codigo do Cliente
Local cLojRest	 := ""				// Recebe o Codigo da Loja do Cliente
Local aArea 	 := GetArea()		// Recebe a Area Ativa
Local nX		 := 0 				// Recebe o Contador
Local cSeqEnd	 := ""				// Recebe a Sequencia de endereço

DEFAULT aCliLoj := {}
DEFAULT aSerTms := {}
DEFAULT aCepCli := {}

cSerTmsDoc 	:= DT6->DT6_SERTMS

If cSerTmsDoc != StrZero( 2, Len( DT6->DT6_SERTMS ) )  // Diferente de Transferencia
	
	If DT6->DT6_SERTMS == StrZero( 3, Len( DT6->DT6_SERTMS ) )// Entrega
			cCliRest 	:=  DT6->DT6_CLIDES
			cLojRest 	:=  DT6->DT6_LOJDES
			
			dbSelectArea("DTC")
			DTC->( dbSetOrder(3) )
			
			If DTC->( dbSeek(FwxFilial("DTC")+ DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE ) )
				cSeqEnd := DTC->DTC_SQEDES
			EndIf
	
	ElseIf DT6->DT6_SERTMS == StrZero( 1, Len( DT6->DT6_SERTMS ) )//Coleta
		dbSelectArea("DT5")
		DT5->( dbSetOrder( 4 ) )
		If DT5->( dbSeek( FwxFilial('DT5') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE ) )
	
			DbSelectArea("DUE")
			DbSetOrder(1)
			DUE->( dbSeek(FwxFilial("DUE") +  DT5->DT5_CODSOL) )
	
			cCliRest 	:= DUE->DUE_CODCLI
			cLojRest 	:= DUE->DUE_LOJCLI
			cSeqEnd 	:= DT5->DT5_SEQEND
		EndIf
	EndIf

	// Preenche o array de aCepCli 
	If Empty(cSeqEnd)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->( dbSeek(FwxFilial("SA1")+cCliRest+cLojRest) )
			If AScan(aCepCli,{|x| x == SA1->A1_CEP }) <= 0
				aAdd(aCepCli,SA1->A1_CEP)
			EndIf
		EndIf
	Else
		dbSelectArea("DUL")
		DUL->(dbSetOrder(2))
		If DUL->( dbSeek(FwxFilial("DUL")+cCliRest+cLojRest+cSeqEnd) )
			If AScan(aCepCli,{|x| x == DUL->DUL_CEP }) <= 0
				aAdd(aCepCli,DUL->DUL_CEP)
			EndIf
		EndIf	
	EndIf
	
	// Cria Array de Cliente + Loja
	If Len(aCliLoj) == 0
		aAdd(aCliLoj,{ cCliRest, cLojRest })
	Else
		//-- Adiciona Cli + Loj Sem duplicidade
		For nX := 1 To Len(aCliLoj)
			If AScan(aCliLoj,{|x| x[1] == cCliRest .And. x[2] == cLojRest  }) <= 0
				aAdd(aCliLoj,{ cCliRest, cLojRest })
			EndIf
		Next
	EndIf

	// Cria Array de SerTms + Cliente + Loja
	If Len(aSerTms) == 0
		aAdd(aSerTms,{ cSerTmsDoc,cCliRest, cLojRest })
	Else
		//-- Adiciona Cli + Loja Sem duplicidade
		For nX := 1 To Len(aSerTms)
			If AScan(aSerTms,{|x| x[1] == cSerTmsDoc .And. x[2] == cCliRest .And. x[3] == cLojRest  }) <= 0
				aAdd(aSerTms,{ cSerTmsDoc ,cCliRest, cLojRest })
			EndIf
		Next
	EndIf
EndIf

RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSIncoRRE()
Tratamento Para Bloqueio De Viagens Por Incompatibilidades de Produtos (ONU) e RRE
@author Katia  / Eduardo Alberti
@since 09/04/2015
@version 1.0
@Parametros: lChkList - Verificara somente itens do Chek List RRE, utilizado na
                        rotina de Fechamento de Viagem
/*/
//-------------------------------------------------------------------
Function TMSIncoRRE(aBloqueio,aBloqDoc,cRotRRE,cFilOri,cViagem)

Static cMV_TMSINCO:= SuperGetMv("MV_TMSINCO",.F.,"") // Verifica Se Produtos Constantes Na Viagem São Incompativeis Entre Si
Static cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

Local aVeiViag    := {}
Local aMotViag    := {}                                                       
Local aVetDoc     := {}
Local aVetRRE     := {}
Local cChvVia     := ""
Local lDocRee	  := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local cChvDoc     := ""
Local nPos        := 0
Local aVetCli     := {}
Local cCodCli     := ""
Local cLojCli     := ""
Local lTMBLOQDV   := ExistBlock('TMBLOQDV')
Local aVetPrd     := {}
Local nI          := 0
Local cMotBlq     := ""     
Local cBlqClRs    := PadR('CR', Len(DUC->DUC_CODBLQ))  // Bloqueio Por Classe De Risco De Produtos (ONU)
Local cBlqRRE     := PadR('RR', Len(DUC->DUC_CODBLQ))  // Bloqueio RRE
Local aRetRRE     := {}
Local lBlqRRE     := .T.  
Local cCodDoc     := ""
Local lChkList    := .F.   
Local nX          := 0
Local nII         := 0
Local aTipos      := {}

Default aBloqueio := {}  
Default aBloqDoc  := {}
Default cRotRRE   := "TMSA140"  
Default cFilOri   := ""
Default cViagem   := ""  

If "TMSA310" $ Upper(cRotRRE)
	lChkList:= .T.    //Somente verifica os Chek List e desconsidera os demais bloqueios.
EndIf

Private aListChk  := {}                                         

If ("A" $ cMV_TMSINCO .Or. "C" $ cMV_TMSINCO) .Or. ("3" $ cMV_TMSRRE)  //3=Viagem 

    //-- Busca dados do Veiculo e Motorista da Viagem e suas caracteristicas
	If "3" $ cMV_TMSRRE  //3=Viagem
		TmsVeiViag(cFilOri,cViagem,@aVeiViag, @aMotViag, @aTipos)
	EndIf

	//-- Posiciona Nos Movimentos Da Viagem
	DbSelectArea("DUD")
	DUD->( DbSetOrder( 2 ) ) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
	If DUD->( MsSeek(xFilial('DUD') + cFilOri + cViagem, .F. ) )

		aVetDoc := {}
		aVetRRE := {}
		cChvVia := DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM)

		DbSelectArea("DUD")
		While DUD->(!Eof()) .And. ( cChvVia == DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM))

			//--  '1'->Coleta; '2'->Transporte; '3'->Entrega
			If DUD->DUD_SERTMS <> '1'

				DbSelectArea("DT6")
				DT6->(dbSetOrder(1))
				DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE,.F.))

				//-- Tratamento Para Reentrega Quando Parametro MV_DOCREE = .t.
				If lDocRee .And. DT6->DT6_DOCTMS == StrZero(7, Len(DT6->DT6_DOCTMS))

					//-- Posiciona Nos Documentos De Reentrega
					DbSelectArea("DY4")
					DY4->(DbSetOrder(1))
					If DY4->(MsSeek(xFilial("DY4") + DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE),.f.))

						cChvDoc := DY4->(DY4_FILIAL + DY4_FILDOC + DY4_DOC + DY4_SERIE)

						While DY4->(!Eof()) .And. ( cChvDoc == DY4->(DY4_FILIAL + DY4_FILDOC + DY4_DOC + DY4_SERIE))

							DTC->( DbSetOrder( 2 ) ) // DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC
							If DTC->(MsSeek(xFilial('DTC')+DY4->(DY4_NUMNFC+DY4_SERNFC+DY4_CLIREM+DY4_LOJREM+DY4_CODPRO+DY4_FILORI+DY4_LOTNFC)))

								Aadd(aVetDoc,{DY4->DY4_CODPRO, DY4->DY4_NUMNFC, DY4->DY4_SERNFC, DY4->DY4_DOC, DY4->DY4_SERIE, "DY4", DY4->(Recno()), DTC->DTC_CLIDEV, DTC->DTC_LOJDEV })

								If "3" $ cMV_TMSRRE  //3=Viagem
							    	nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == DTC->DTC_CLIDEV + DTC->DTC_LOJDEV + DTC->DTC_CODPRO })
							    	If nPos > 0
								    	aVetRRE[nPos][4]+= DTC->DTC_QTDVOL
							    		aVetRRE[nPos][5]+= DTC->DTC_PESO
								    	aVetRRE[nPos][6]+= DTC->DTC_PESOM3
								    	aVetRRE[nPos][7]+= DTC->DTC_VALOR
								    Else
									    Aadd(aVetRRE,{DTC->DTC_CLIDEV, DTC->DTC_LOJDEV, DTC->DTC_CODPRO, DTC->DTC_QTDVOL, DTC->DTC_PESO, DTC->DTC_PESOM3, DTC->DTC_VALOR,'',0 })
									EndIf

									//--- Totalizador do Valor da Mercadoria por Cliente
									nPos:= aScan(aVetCli, {|x| x[1] + x[2] == DTC->DTC_CLIDEV + DTC->DTC_LOJDEV })
									If nPos > 0
										aVetCli[nPos][3]+= DTC->DTC_VALOR
									Else
										Aadd(aVetCli,{DTC->DTC_CLIDEV,DTC->DTC_LOJDEV,DTC->DTC_VALOR})
									EndIf
								EndIf
							EndIf

							DY4->(DbSkip())
						EndDo
					EndIf
				Else

					//-- Posiciona Doc Cliente para Transporte
					DbSelectArea("DTC")
					DTC->( DbSetOrder( 3 ) ) // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
					If DTC->(MsSeek(xFilial('DTC') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE, .F. ) )

						cChvDoc := DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE)

						While DTC->(!Eof()) .And. ( cChvDoc == DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE))

							Aadd(aVetDoc,{DTC->DTC_CODPRO, DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_DOC, DTC->DTC_SERIE, "DTC", DTC->(Recno()), DTC->DTC_CLIDEV, DTC->DTC_LOJDEV })

							If "3" $ cMV_TMSRRE  //3=Viagem
							    nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == DTC->DTC_CLIDEV + DTC->DTC_LOJDEV + DTC->DTC_CODPRO })
							    If nPos > 0
							    	aVetRRE[nPos][4]+= DTC->DTC_QTDVOL
							    	aVetRRE[nPos][5]+= DTC->DTC_PESO
							    	aVetRRE[nPos][6]+= DTC->DTC_PESOM3
							    	aVetRRE[nPos][7]+= DTC->DTC_VALOR
							    Else
								    Aadd(aVetRRE,{DTC->DTC_CLIDEV, DTC->DTC_LOJDEV, DTC->DTC_CODPRO, DTC->DTC_QTDVOL, DTC->DTC_PESO, DTC->DTC_PESOM3, DTC->DTC_VALOR,'',0 })
								EndIf

								//--- Totalizador do Valor da Mercadoria por Cliente
								nPos:= aScan(aVetCli, {|x| x[1] + x[2] == DTC->DTC_CLIDEV + DTC->DTC_LOJDEV })
								If nPos > 0
									aVetCli[nPos][3]+= DTC->DTC_VALOR
								Else
									Aadd(aVetCli,{DTC->DTC_CLIDEV,DTC->DTC_LOJDEV,DTC->DTC_VALOR})
								EndIf

							EndIf

							DTC->(DbSkip())
						EndDo
					EndIf
				EndIf
			Else

				//-- Posiciona Na Solicitacao de Coleta
				DbSelectArea("DT5")
				DbSetOrder(4) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
				MsSeek(xFilial("DT5") + DUD->DUD_FILORI + DUD->DUD_DOC + DUD->DUD_SERIE ,.F.)

				//-- Posiciona Nos Itens Da Solicitação De Coleta
				DbSelectArea("DUM")
				DbSetOrder(1) //-- DUM_FILIAL+DUM_FILORI+DUM_NUMSOL+DUM_ITEM
				MsSeek(xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL ,.F.)

				While DUM->(!Eof()) .And.  (DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == (xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL))

					If "3" $ cMV_TMSRRE
						If !Empty(DT5->DT5_CLIDEV+DT5->DT5_LOJDEV)
							cCodCli:= DT5->DT5_CLIDEV
							cLojCli:= DT5->DT5_LOJDEV
						Else   //Cliente Generico
							DUE->(DbSetOrder(1))
							If DUE->(dbSeek(xFilial('DUE')+DT5->(DT5_CODSOL))) .And. !Empty(DUE->DUE_CODCLI)
								cCodCli:= DUE->DUE_CODCLI
								cLojCli:= DUE->DUE_LOJCLI
							EndIf
                    	EndIf

                    	If !Empty(cCodCli)
						   	nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == cCodCli + cLojCli + DUM->DUM_CODPRO })
						   	If nPos > 0
						    	aVetRRE[nPos][4]+= DUM->DUM_QTDVOL
						    	aVetRRE[nPos][5]+= DUM->DUM_PESO
						    	aVetRRE[nPos][6]+= DUM->DUM_PESOM3
						    	aVetRRE[nPos][7]+= DUM->DUM_VALMER
							Else
							    Aadd(aVetRRE,{cCodCli, cLojCli, DUM->DUM_CODPRO, DUM->DUM_QTDVOL, DUM->DUM_PESO, DUM->DUM_PESOM3, DUM->DUM_VALMER,'',0 })
							EndIf

							//--- Totalizador do Valor da Mercadoria por Cliente
							nPos:= aScan(aVetCli, {|x| x[1] + x[2] == cCodCli + cLojCli })
							If nPos > 0
								aVetCli[nPos][3]+= DUM->DUM_VALMER
							Else
								Aadd(aVetCli,{cCodCli,cLojCli,DUM->DUM_VALMER})
							EndIf
						EndIf

					EndIf

					Aadd(aVetDoc,{DUM->DUM_CODPRO, DT5->DT5_DOC, DT5->DT5_SERIE, "COLETA", "COL", "DUM", DUM->(Recno()),cCodCli,cLojCli})

					DbSelectArea("DUM")
					DUM->(DbSkip())
				EndDo
			EndIf

			DUD->(DbSkip())
		EndDo

		//-- PE Permite Tratamento Usuario No Conteudo Do Vetor aVetDoc
		If lTMBLOQDV
			ExecBlock("TMBLOQDV",.F.,.F.,{aVetDoc, aVetRRE})
		EndIf

		If ("A" $ cMV_TMSINCO .Or. "C" $ cMV_TMSINCO) .And. !lChkList 

			//-- Gera Vetor De Produtos Para Calcular Incompatibilidades
			aVetPrd := {}
			For nI := 1 To Len(aVetDoc)
				nPos 	 := aScan(aVetPrd,aVetDoc[nI,01])
				If nPos == 0
					aAdd(aVetPrd,aVetDoc[nI,1])
				EndIf
			Next nI

			//-- Calcula Divergencias
			aVetPrd  := TmsRtDvP(aVetPrd)

			//-- Grava Vetor de Bloqueios Caso Existam
			If Len(aVetPrd) > 1

				//-- Gravacao Da Tabela DDU -> Registro De Bloqueios TMS
				cMotBlq := ""

				For nI := 1 To Len(aVetPrd)

					For nX := 1 To Len(aVetDoc)

						If aVetDoc[nX,1] == aVetPrd[nI,1]

							DbSelectArea("SB5")
							DbSetOrder(1) //-- B5_FILIAL+B5_COD
							MsSeek(xFilial("SB5") + aVetPrd[nI,01] ,.F.)

							DbSelectArea("DY3")
							DbSetOrder(1) //-- DY3_FILIAL+DY3_ONU+DY3_ITEM
							MsSeek(xFilial("DY3") + SB5->B5_ONU + SB5->B5_ITEM ,.F.)

							//-- Gera String Com Dados Das Divergencias Dos Produtos (Histórico)
							cMotBlq +=	( 	STR0120 + "#" + Alltrim(DY3->DY3_NRISCO) + " " + Alltrim(DY3->DY3_GRPEMB)			+"#"+; //-- "Risco: "
											STR0008 + "#" + aVetPrd[nI,01]															+"#"+; //-- "Produto" 							
											STR0019 + "#" + Posicione("SB1",1,xFilial("SB1") + aVetPrd[nI,01],"B1_DESC")		+"#"+; //-- "Descrição:"
											STR0002 + "#" + aVetDoc[nX,02] + "-" + aVetDoc[nX,03]								+"#"+; //-- "Documento No."
											STR0121 + "#" + aVetPrd[nI,02]															+"|" ) //-- "Divergência:"

						EndIf
					Next nX
				Next nI

				Aadd( aBloqueio, { cBlqClRs,;		// 01 Cod. Bloqueio
				'',;									// 02 Cliente
				'',;									// 03 Loja
				Space(Len(DUC->DUC_CODPRO)),;		// 04 Cod. Produto
				0,;										// 05 Limite Max Peso
				1,;										// 06 Peso Carregado
				-1,;									// 07 Peso Disponivel
				"",;									// 08 Cod. Veiculo
				Space(Len(DUC->DUC_CODMOT)),;		// 09 Cod. Motorista
				cMotBlq })								// 10 Descrição Do Bloq. Por Divergencia Produtos

			EndIf
      	EndIf

		If "3" $ cMV_TMSRRE //3=Viagem
		
			cMotBlq:= ""

			//-- Verifica divergencias RRE
			If Len(aVetRRE) > 0
				For nI:= 1 To Len(aVetCli)
					aEval(aVetRRE, {|x| Iif( x[1]+x[2] == aVetCli[nI][1] + aVetCli[nI][2], x[9]+= aVetCli[nI][3], .T.) })  //Atualiza valor total por Cliente
				Next nI

				aRetRRE:= TmsRetRRE(aVetRRE,aVeiViag,aMotViag,cRotRRE,@aListChk,cFilOri,cViagem,aTipos)
			EndIf
            
			If !lChkList   //Gera Bloqueios
				//-- Verifica se os itens do Chek List foram conferidos pelo operador
				//If Len(aListChk) > 0 .And. !IsInCallStack('TMSA146')  .And. lHelp //Programacao Carregamento
				//	SaveInter()
				//	FWExecView('RRE', 'TMSA034', 4, , { || .T. } )
				//	RestInter()
				//EndIf

				//-- Gravacao Da Tabela DDU -> Registro De Bloqueios TMS
				If Len(aRetRRE) >= 1 //.Or. Len(aListChk) > 0
	
					For nI := 1 To Len(aRetRRE)
						lBlqRRE:= .T.
	
						//-- Verificar se a Caracteristica está vinculada a um Codigo de Docto Exigido x Motorista
						//-- Se existir, o bloqueio devera ser efetuado pela rotina Docto Exigido e nao pela Caracteristica da RRE
						If !Empty(aRetRRE[nI,7]) .And. Len(aBloqDoc) > 0
							cCodDoc:= Posicione("DJ0",1,xFilial("DJ0")+aRetRRE[nI,7],"DJ0_CODDOC")
							If !Empty(cCodDoc)
								If aRetRRE[nI,5] == 'CARV'  //Caracteristica Veiculo
									nPos:= Ascan(aBloqDoc, {|x| + x[1] == 'D1' })
								EndIf
								If aRetRRE[nI,5] == 'CARM'  //Caracteristica Motorista
									nPos:= Ascan(aBloqDoc, {|x| + x[1] == 'D3' })
								EndIf
								If nPos > 0
	
									For nII:= 1 To Len(aBloqDoc)
										If (aRetRRE[nI,5] == 'CARV' .And. aBloqDoc[nII][1] == 'D1') .Or. (aRetRRE[nI,5] == 'CARM' .And. aBloqDoc[nII][1] == 'D3')
											If aBloqDoc[nII][5] == aRetRRE[nI,8]  //-- Verifica se é o mesmo Motorista
												If cCodDoc == aBloqDoc[nII,2]     //-- Verifica se é o mesmo Codigo de Docto Exigido
													lBlqRRE:= .F.
												EndIf
											EndIf
										EndIf
									Next nII
								EndIf
							EndIf
						EndIf
	
						If lBlqRRE
						cMotBlq +=	( 	STR0122 +"#"+ aRetRRE[nI,1] 							+"#"+;	 	//-- "Restrição Embarque:"
										STR0020 +"#"+ aRetRRE[nI,2] + " " + aRetRRE[nI,3]	+"#"+; 	//-- "Cliente"
										STR0123 +"#"+ aRetRRE[nI,04] 							+"#"+;		//-- "Produto / Grupo"
										STR0124 +"#"+ aRetRRE[nI,06]							+"|" )		//-- "Detalhes"
						EndIf
	
						//--- Exclui o bloqueio da tabela SA7, caso existir a RRE para o cliente devedor
						//cBlqVal     := StrZero(10, Len(DUC->DUC_CODBLQ)) // Bloqueio valor
						//cBlqPes     := StrZero(20, Len(DUC->DUC_CODBLQ)) // Bloqueio peso.
						//cBlqAnoVei  := StrZero(50, Len(DUC->DUC_CODBLQ)) // Ano de fabricacao do veiculo.
	
						nII:= 1
						While nII <= Len(aBloqueio)
							If aBloqueio[nII][1] $ '10/20/50'
								If aBloqueio[nII][2]+aBloqueio[nII][3] == aRetRRE[nI][2]+aRetRRE[nI][3]   //Cliente+Loja
									aDel(aBloqueio,nII)
									aSize(aBloqueio,Len(aBloqueio)-1)
									nII -= 1
								EndIf	
							EndIf
						    nII++  
						EndDo
	
					Next nI
				EndIf
	
				//-- Verifica Data da Liberação do Seguro do Motorista
				For nI:= 1 To Len(aMotViag)
					If !aMotViag[nI][4]   //-- Data Nao Validado
	
						cMotBlq +=	( 	"LIB.SEG.MOTORISTA:#" + aMotViag[nI][1] +"#"+;
											"Data de Liberação do Seguro: #" + SubStr(DtoS(aMotViag[nI][2]),7,2) + '/' + SubStr(DtoS(aMotViag[nI][2]),5,2) + '/' + SubStr(DtoS(aMotViag[nI][2]),1,4) +;
											" a " + SubStr(DtoS(aMotViag[nI][3]),7,2) + '/' + SubStr(DtoS(aMotViag[nI][3]),5,2) + '/' + SubStr(DtoS(aMotViag[nI][3]),1,4) +"#"+;
											" Motorista:#" + aMotViag[nI][1] +"#"+;
											" Verifique a Data Inicio e Fim da Viagem. " + "|" )
	
					EndIf
					If !aMotViag[nI][5]   //-- Data Nao Validado
	
						cMotBlq +=	( 	"LIB.SEG.MOTORISTA:#" + aMotViag[nI][1] +"#"+;
											"Numero de Liberação do Seguro: #" + aMotViag[nI][6] +"#"+;
											"Motorista:#" + aMotViag[nI][1] +"#"+;
											" Verifique o Numero de Liberação do Seguro. " + "|" )
	
					EndIf
				Next nI
	
				//-- Verifica Data da Liberação do Seguro do Veiculo
				For nI:= 1 To Len(aVeiViag)
					If !aVeiViag[nI][7]   //-- Data Nao Validado
	
						cMotBlq +=	( 	"LIB.SEG.VEICULO:#" + aVeiViag[nI][1] +"#"+;
											"Data de Liberação do Seguro:#" + SubStr(DtoS(aVeiViag[nI][5]),7,2) + '/' + SubStr(DtoS(aVeiViag[nI][5]),5,2) + '/' + SubStr(DtoS(aVeiViag[nI][5]),1,4) +;
											" a " + SubStr(DtoS(aVeiViag[nI][6]),7,2) + '/' + SubStr(DtoS(aVeiViag[nI][6]),5,2) + '/' + SubStr(DtoS(aVeiViag[nI][6]),1,4) +"#"+;
											" Veiculo:#" + aVeiViag[nI][1] +"#"+;
											" Verifique a Data Inicio e Fim da Viagem. " + "|" )
	
					EndIf
					If !aVeiViag[nI][8]  //-- Nro Liberacao Veiculo de Terceiro
						cMotBlq +=	( 	"LIB.SEG.VEICULO:#" + aVeiViag[nI][1] +"#"+;
											"Numero de Liberação do Seguro:#" + aVeiViag[nI][9] +"#"+;
											"Veiculo: #" + aVeiViag[nI][1] +"#"+;
											"Verifique o Numero de Liberação do Seguro. " + "|" )
					EndIf  
				Next nI
	
				//--- Guarda bloqueios na vetor aBloqueio
				If !Empty(cMotBlq)
					Aadd( aBloqueio, { cBlqRRE,;		// 01 Cod. Bloqueio
							'',;									// 02 Cliente
							'',;									// 03 Loja
							Space(Len(DUC->DUC_CODPRO)),;		// 04 Cod. Produto
							0,;										// 05 Limite Max Peso
							1,;										// 06 Peso Carregado
							-1,;									// 07 Peso Disponivel
							"",;									// 08 Cod. Veiculo
							Space(Len(DUC->DUC_CODMOT)),;		// 09 Cod. Motorista
							cMotBlq })								// 10 Descrição Do Bloq. RRE
				EndIf
	        EndIf
		EndIf
	EndIf
EndIf
//-- Fim    - Tratamento Para Bloqueio De Viagens Por Incompatibilidades de Produtos (ONU) e RRE
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSTipDoc
Função que retorna o KM dos Documentos 
@author	Rafael Souza 
@version	1.0
@since		22/12/2015
@sample    Esta função tem por objetivo identificar o tipo de documento 
			a ser gerado, de acordo com as regiões de origem e calculo.
/*/
//-------------------------------------------------------------------

Function TMSTipDoc(cRegOri,cRegCalc)

Local cDocTMs  := ""
Local cMunOri  := ""
Local cMunCalc := ""

Default cRegOri  := ""
Default cRegCalc := ""

If !Empty(cRegOri) .And. !Empty(cRegCalc)
	DUY->(DbSetOrder(1))
	If DUY->(MsSeek(xFilial('DUY') + cRegOri))
		cMunOri := AllTrim(DUY->DUY_EST + DUY->DUY_CODMUN)
	EndIf
	If DUY->(MsSeek(xFilial('DUY') + cRegCalc))
		cMunCalc := AllTrim(DUY->DUY_EST + DUY->DUY_CODMUN)
	EndIf
	
	If cMunOri == cMunCalc
		cDocTms := "5"
	Else
		cDocTMs := "2"
	EndIf 
EndIf 

Return (cDocTMs)


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSPesoRat
Função que retorna o Peso para calculo do Rateio 
@author	Katia
@version	1.0
@since		13/04/2016
@sample    Esta função tem por objetivo identificar o Maior Peso
			para calculo do Rateio 
/*/
//-------------------------------------------------------------------
Function TMSPesoRat(cFilSol, cNumSol, cProduto)
Local cQuery    := ""
Local cAliasDUM := GetNextAlias()
Local aArea     := GetArea()
Local nPesoCol  := 0 

Default cFilSol  := ""
Default cNumSol  := ""
Default cProduto := ""

If !Empty(cNumSol)
	cQuery := " SELECT  SUM(DUM_PESO) PESO, SUM(DUM_PESOM3) PESOM3 "
	cQuery += " FROM " + RetSqlName("DUM") + " DUM "
	cQuery += " WHERE DUM_FILIAL = '" + xFilial("DUM") + "' "
	cQuery += "   AND DUM_FILORI = '" + cFilSol + "' "
	cQuery += "   AND DUM_NUMSOL = '" + cNumSol + "' "
	If !Empty(cProduto)
		cQuery += "   AND DUM_CODPRO = '" + cProduto + "' "
	EndIf	
	cQuery += "   AND DUM.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUM)
	If (cAliasDUM)->(!Eof())
		nPesoCol := Iif((cAliasDUM)->PESO > (cAliasDUM)->PESOM3, (cAliasDUM)->PESO , (cAliasDUM)->PESOM3)  
	EndIf
	(cAliasDUM)->( DbCloseArea() )
EndIf	

RestArea(aArea)
Return nPesoCol

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSPFxDDP
Função que retorna o Percentual Fixo do Cadastro do Cliente 
@author	Katia
@version	1.0
@since		15/04/2016
@sample    Esta função tem por objetivo retornar o percentual fixo
			cadastrado na tabela DDP para o determinado cliente
/*/
//-------------------------------------------------------------------

Function TMSPFxDDP(cNrCont,cServico,cCodNeg)
Local aRet     := {}            
Local cAliasDDP:= ''
Local cQuery   := '' 

Default cNrCont := ""
Default cServico:= ""
Default cCodNeg := ""
                     
If !Empty(cNrCont)
	cAliasDDP := GetNextAlias()
	cQuery := " SELECT DDP_CLIDEV, DDP_LOJDEV, DDP_PERRAT  FROM " + RetSqlName("DDP") + " DDP "
	cQuery += "  WHERE DDP.DDP_FILIAL = '" + xFilial('DTC')  + "' "
	cQuery += "    AND DDP.DDP_NCONTR = '" + cNrCont + "' "
	cQuery += "    AND DDP.DDP_SERVIC   = '" + cServico    + "' "
	cQuery += "    AND DDP.DDP_CODNEG = '" + cCodNeg  + "' "
	cQuery += "    AND DDP.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDDP)
	While (cAliasDDP)->(!Eof())
		aAdd(aRet, {(cAliasDDP)->DDP_CLIDEV,(cAliasDDP)->DDP_LOJDEV,(cAliasDDP)->DDP_PERRAT})
		(cAliasDDP)->(dbSkip())
	EndDo                       
	(cAliasDDP)->(DbCloseArea())
EndIf
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsPerFix
Função que retorna o Diferena do Percentual Fixo no Lote 
@author	Katia
@version	1.0
@since		15/04/2016
@sample    Esta função tem por objetivo retornar a Diferenca de Percentual Fixo
			x Percentual dos Documentos que estao no Lote
/*/
//-------------------------------------------------------------------
                                                        
Function TmsPerFix(aRateio,aPerFixDDP,cCrdvfa,nPerDDP)
Local nCount   := 0
Local nPerDoc  := 0       
Local nPerDif  := 0
Local aDadosRat:= {}

Default aRateio   := {}
Default aPerFixDDP:= {}
Default cCrdvfa   := ''
               
If Empty(aRateio) .Or. Empty(aPerFixDDP)
	Return nPerDif
EndIf              
 
//--- Posicao aRateio
// 	15 - Codigo do Devedor            
// 	16 - Loja do Devedor              
// 	25 - Percentual do Rateio

//--- Soma total de percentual fixo dos documentos que estao no lote                                          
For nCount:= 1 To Len(aRateio)
	If aScan(aDadosRat,{|x| x[1]+x[2] == aRateio[nCount][01][15] + aRateio[nCount][01][16] }) == 0
		aAdd(aDadosRat,{aRateio[nCount][01][15],aRateio[nCount][01][16]})
		nPerDoc+= aRateio[nCount][01][25]
	EndIf	
Next nCount

//--- Soma o total do percentual do cadastro - DDP
AEval( aPerFixDDP, {|x| nPerDDP += x[ 3 ] })		

//-- Verifica a diferenca do Percentual Fixo (DDP) com o total do percentual dos documentos no lote
nPerDif:= nPerDDP - nPerDoc

If cCrdvfa == '2' //Proporcao
	nPerDif:= nPerDoc
EndIf	

Return nPerDif

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsCalPFix
Função que calcula o Percentual do Criterio Faltante   
@author	Katia
@version	1.0
@since		15/04/2016
@sample    Esta função tem por objetivo calcular o percentual do
			Criterio Faltante (Aritmetica ou Proporção)
			** Faltante: Documentos que estão no cadastro DDP e que nao
			estão no lote.
/*/
//-------------------------------------------------------------------                                                       
Function TmsCalPFix(cCrdvfa,nPerCli,nPerDif,nDoc)

Local nRet:= 0

Default cCrdvfa := ""
Default nPerfix := ""

If nPerDif <> 0 	
	If cCrdvfa == '1'  //Aritmetica                                         
		nRet:= nPerCli + (nPerDif / nDoc)
	Else
		nRet:= ((nPerCli / nPerDif) * 100)
	EndIf
Else
	nRet:= nPerCli	
EndIf	
nRet:= (Round(nRet,2))

Return nRet
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAgAUT
Funcao desenvolvida para gerar Agendamento (DF0, DF1, DF2) de forma automatica, sendo possivel ser instanciada atraves de outras funcoes.
@author Adalberto S. M.
@version Versao P12
@since 16/Nov/2015
@return Nil
@obs Compatibilizado Para o Produto Por Eduardo Alberti
/*/
//--------------------------------------------------------------------------------------------------------
Function TMSAgAUT( cCodCli, cLojCli, cCodLay, aDadAgen, aPrwDF0, aPrwDF1, aPrwDF2, aRecDDD )

	Local aArea			:= GetArea()
	Local aAreaDDD		:= DDD->(GetArea())
	Local aAreaDDE		:= DDE->(GetArea())
	Local aAreaDDF		:= DDF->(GetArea())	
	Local lColAut		:= .f.
	Local nCount		:= 0
	Local nTotReg		:= 0
	Local nPosV			:= 0
	Local nTotAgen		:= 0
	Local cTemp			:= ""
	Local cQuery		:= ""
	Local cQryNV1		:= ""
	Local cQryNV2		:= ""
	Local cOrderBy		:= ""
	Local cLinAtu		:= ""
	Local cLinNext		:= ""
	Local cQBRNV1		:= ""
	Local cQBRNV2		:= ""
	Local cAlias		:= ""
	Local aRECNO		:= {}
	Local aOrdDDD		:= {}
	Local aOrdDDE		:= {}
	Local aCPODDD		:= {}
	Local aCPODDE		:= {}
	Local aAutDF0		:= {}
	Local aAutDF1		:= {}
	Local aAutDF2		:= {}
	Local aTemp			:= {}
	Local aDF1Ant		:= {}
	Local aDF2Ant		:= {}
	Local aDEPARA		:= {}
	Local aCPOIGN		:= {} // Define quais CAMPOS devem ser IGNORADOS na IMPORTACAO
	Local aBrokeBy		:= {} //-- Vetor Contendo o Campo e o Valor de Quebra (Numérico)
	Local nBrokePar		:= 0
	Local lPreview		:= Iif( Alltrim(SuperGetMV( 'MV_TMSAGDP' , .F. , '2' )) == '1' , .t. , .f. )	
	Local lTMPFLAGE		:= ExistBlock('TMPFLAGE')
	Local lRetUsr		:= .F.
	Local oFormStruct	:= Nil
	Local aFields		:= Nil
	Local nAux			:= 1
	Local cCampo		:= ""
	
	Static lTMDPAGEN:= ExistBlock('TMDPAGEN') // De/Para Do Agendamento Automático
	Static lTMCIAGEN:= ExistBlock('TMCIAGEN') // Campos a Serem Ignorados Na Geração Do Agendamento Automático.

	Private cAliasNV1 := "" // Essa variavel precisa ser mantida como PRIVATE para que a execucao da MACRO ( & ) execute.
	Private cAliasNV2 := "" // Essa variavel precisa ser mantida como PRIVATE para que a execucao da MACRO ( & ) execute.
	
	//------------------------------------------------------------------------------
	// Variaveis necessarias para instanciar rotina padrao de agendamento TMSAF05 
	//------------------------------------------------------------------------------
	Private cCadastro	:= ""
	Private Inclui		:= .T.
	Private aRotina		:= {	{STR0002,'AxPesqui' ,0, 1,0,.F.},; // 'Pesquisar'
								{STR0003,'TMSF05Mnt',0, 2,0,NIL},; // 'Visualizar'
								{STR0004,'TMSF05Mnt',0, 3,0,NIL},; // 'Incluir'
								{STR0005,'TMSF05Mnt',0, 4,0,NIL},; // 'Alterar'
								{STR0006,'TMSF05Mnt',0, 5,0,NIL},; // 'Cancelar'
								{STR0007,'TMSF05Mnt',0, 6,0,NIL},; // 'Confirmar'
								{STR0008,'TMSF05Mnt',0, 7,0,NIL},; // 'Copiar'
								{STR0009,'TMSF05Leg',0, 8,0,.F.}}  // 'Legenda'
						
	Default cCodCli 	:= ""
	Default cLojCli 	:= ""
	Default aDadAgen	:= {}
	Default aPrwDF0	:= {}
	Default aPrwDF1	:= {}
	Default aPrwDF2	:= {}
	Default aRecDDD	:= {}

	//------------------------------------------------------------------------------
	// Obter Perfil Do Cliente (Duo) Para Identificar Se O Perfil Encontra-Se
	// Configurado (Duo_Ageaut) Para Gerar Agendamento Automatico Ou Nao
	//------------------------------------------------------------------------------
	If (DUO->(ColumnPos('DUO_AGEAUT')) > 0) 

		aTemp := {}
		aTemp := TmsPerfil(cCodCli, cLojCli, .T. , , , , , )

		//------------------------------------------------------------------------------
		// DUO_AGEAUT - 1=Sim ; 2=Nao 
		//------------------------------------------------------------------------------
		If Len(aTemp) >= 55
			lRet 		:= Iif( aTemp[ 55 ] == StrZero(1, Len(DUO->DUO_AGEAUT)), .T., .F. )
			lColAut	:= Iif( Len(aTemp) >= 56, (Iif( aTemp[ 56 ] == StrZero(1, Len(DUO->DUO_AGECON)), .T., .F. )),.F.)
		Else
			lRet 	:= .F.
			lColAut:= .F.
		EndIf
	EndIf
	//--------------------------------------------------------------------------------------------------------------
	//Ponto De Entrada Para Manipular Se O Sistema Deve Entender Que O Client Utiliza Agendamento Automatico Ou Não
	//--------------------------------------------------------------------------------------------------------------
	If lTMPFLAGE
		lRetUsr := ExecBlock( 'TMPFLAGE', .F., .F., { aTemp, lRet } )
		If ValType(lRetUsr) == "L"
			lRet := lRetUsr
		EndIf
	EndIf

	//-- Se Vetor Informado Força Processamento Registros
	If Len(aDadAgen) > 0
		lRet := .t.
	EndIf		

	//----------------------------------------------------------------------------------------------------------------
	// Para Os Clientes Em Que O Perfil Encontado Encontra-Se Configurado Para Nao Gerar Agendamento Automatico,    
	// Sera Atualizado O Status Dos Registros Da Tabela Ddd Que Encontram-Se Com Status Igual A "1 = Edi Importado" 
	// Para "2 = Processado" Que Indica Que Os Registros Ja Foram Processados E Dessa Forma, Nao Serao Considerados
	// Em Uma Proxima Geracao De Agendamento Automatico, Caso Seu Perfil Seja Alterado. Isso Visa Evitar De Que Com
	// A Demanda De Importacao, Fiquem Muitos Registros Como "1 = Edi Importado" E Posteriormente O Respectivo     
	// Cliente Seja Configurado Para Gerar Agendamento E A Rotina Processe Todos Os Registros Antigos.              
	//----------------------------------------------------------------------------------------------------------------
	If !lRet
		cAliasNV1	:= GetNextAlias()
		cQryNV1	:= " "
		cQryNV1	+= " SELECT      DDD.R_E_C_N_O_ " 
		cQryNV1	+= " FROM        " + RetSqlName("DDD") + " DDD "
		cQryNV1	+= " INNER JOIN  " + RetSqlName("DUE") + " DUE "
		cQryNV1	+= " ON          DUE.DUE_FILIAL =  '" + xFilial("DUE") + "' "
		cQryNV1	+= " AND         DUE.DUE_CODCLI =  '" + cCodCli + "' "
		cQryNV1	+= " AND         DUE.DUE_LOJCLI =  '" + cLojCli + "' "
		cQryNV1	+= " AND         DUE.D_E_L_E_T_ =  ' ' "
		cQryNV1	+= " WHERE       DDD.DDD_FILIAL =  '" + xFilial("DDD") + "' "
		cQryNV1	+= " AND         DDD.DDD_CODSOL =  DUE.DUE_CODSOL "   
		cQryNV1	+= " AND         DDD.DDD_STATUS =  '" + StrZero(1, Len(DDD->DDD_STATUS)) + "' "	// 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
		cQryNV1	+= " AND         DDD.D_E_L_E_T_ =  ' ' "

		cQryNV1	:= ChangeQuery(cQryNV1)

		dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQryNV1), cAliasNV1, .F., .T.)
		
		If (cAliasNV1)->( !Eof() )	
			While (cAliasNV1)->( !Eof() )
				//------------------------------------------------------------------------------
				// Atualizar Status Do Registro Corrente Da Tabela Ddd Para "2 = Processado" 
				//------------------------------------------------------------------------------
				DDD->(MsGoTo( (cAliasNV1)->R_E_C_N_O_ ))
				RecLock('DDD',.F.)
				DDD->DDD_STATUS := StrZero(2, Len(DDD->DDD_STATUS)) // 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
				MsUnLock()
	
			   	(cAliasNV1)->( DbSkip() )
			EndDo                                          
		EndIf
		
		(cAliasNV1)->( DbCloseArea() )
			
	//------------------------------------------------------------------------------
	// Perfil Do Cliente Encontra-Se Configurado Para Gerar Agendamento Automatico.
	// Rotina Preparada Vetores Base Para O Restante Da Rotina.         		
	//------------------------------------------------------------------------------
	Else
		//------------------------------------------------------------------------------
		// Configurar De/Para Dos Campos Das Tabelas De Edi - Agendamento (Ddd / Dde) 
		// Com Os Campos Do Agendamento (Df0 / Df1 / Df2). Os Campos Que Encontram-Se 
		// Chumbados No Fonte, Sao Todos Aqueles Em Que Seu "Nome" Nao Eh Semelhante  
		// Dentre As Tabelas, Exemplo: 'Ddd_Datage' --> 'Df0_Datcad'                  
		//------------------------------------------------------------------------------
		Aadd(aDEPARA, { 'DF0', 'DDD_FILIAL',	'DF0_FILIAL' } )
		Aadd(aDEPARA, { 'DF0', 'DDD_DATAGE',	'DF0_DATCAD' } )
		Aadd(aDEPARA, { 'DF1', 'DDD_FILIAL', 	'DF1_FILIAL' } )
		Aadd(aDEPARA, { 'DF1', 'DDD_FILIAL', 	'DF1_FILORI' } )
		
		If lTMDPAGEN
			aTemp := {}
			aTemp := ExecBlock( 'TMDPAGEN', .F., .F., { cCodCli, cLojCli, aDEPARA } )
							
			If ValType(aTemp) == 'A'
				Aadd( aDEPARA, Aclone( aTemp ) )
			EndIf
		EndIf			

		//------------------------------------------------------------------------------------------
		// Configurar Campos Que Devem Ser Desprezados Na Importacao.				  			  
		// Caso Existam Campo Dentre Edi - Agendamento (Ddd / Dde) E Agendamento (Df0 / Df1 / Df2)
		// E Seja Necessario Desprezar Sua Importacao, Adicionar Ao Vetor Acpoign.                
		// Exemplo : Na Tabela Ddd O Campo Ddd_Status Estiver Igual A "3", Sera Gravado "3" No    
		// Df0_Status Devido A Ambos Os Campos Serem Similares (_Status). Com Isso O Conteudo Do  
		// Campo Ddd_Status Deve Ser Desprezado E Nao Gravado Na Tabela Df0                       
		//------------------------------------------------------------------------------------------
		Aadd(aCPOIGN, { 'DF0', 'DDD_STATUS',	'DF0_STATUS' } )
	
		If lTMCIAGEN
			aTemp := {}
			aTemp := ExecBlock( 'TMCIAGEN', .F., .F., { cCodCli, cLojCli, aCPOIGN } )
							
			If ValType(aTemp) == 'A'
				Aadd( aCPOIGN, Aclone( aTemp ) )
			EndIf
		EndIf

		//------------------------------------------------------------------------------------------
		// Incluir Campos No Vetor De/Para (Adepara) De Acordo Com O Dicionario De Dados Sx3 Das  
		// Tabelas Informadas Como Alias (Calias)                                                 
		//------------------------------------------------------------------------------------------
		cAlias	:= ""
		cTemp	:= ""

		For nCount := 1 To 3	
			If nCount == 1
				cAlias	:= "DDD"
				cTemp	:= "DF0"				
			ElseIf nCount == 2
				cAlias	:= "DDD"
				cTemp	:= "DF1"
			Else
				cAlias	:= "DDE"
				cTemp	:= "DF2"
			EndIf
			
			//-- Retorna a estrutura
			oFormStruct		:= FwFormStruct(1,cAlias)
			aFields			:= oFormStruct:aFields

			For nAux := 1 To Len(aFields)
				cCampo	:= aFields[nAux,1]
				If ( GetSX3Cache(cCampo,'X3_CONTEXT') <> 'V') .And. (Ascan( aDEPARA, { |x| x[1] + x[2] == AllTrim(cTemp) + AllTrim(cCampo) } ) == 0) .And. (Ascan( aCPOIGN, { |x| x[1] + x[2] == AllTrim(cTemp) + AllTrim(cCampo) } ) == 0)
					Aadd(aDEPARA, { cTemp, AllTrim(cCampo), StrTran( AllTrim(cCampo), cAlias, cTemp, 1, 1 ) } )
				EndIf
			Next nAux

		Next nCount

		//------------------------------------------------------------------------------
		// Obter Campos Configurados Como Quebra De Geracao Do Agendamento 
		//------------------------------------------------------------------------------
		
		cAliasNV1 := GetNextAlias()

		//-- Eduardo Alberti Em 29-Oct-2015 
		//-- Efetua Busca Inicialmente Pelo Cadastro Cliente X Layout Tabela DEC Campo DEC_CODQBR
		DbSelectArea("DEC")
		DbSetOrder(2) //-- DEC_FILIAL+DEC_CODCLI+DEC_LOJCLI+DEC_CODLAY
		MsSeek(xFilial("DEC") + cCodCli + cLojCli + cCodLay )
		
		//-- Utiliza Cod. De Quebra Da Conf. "Cliente X Layout"
		If !Empty(DEC->DEC_CODQBR) 
		
			cQuery	:= " "
			cQuery	+= " SELECT	DDF_FILIAL, "
			cQuery	+= " 			DDF_CODQBR, "
			cQuery	+= " 			DDF_DESQBR, "
			cQuery	+= " 			DDF_CPOSX3, "
			cQuery	+= " 			DDF_QBRNV1, "
			cQuery	+= " 			DDF_QBRNV2, "
			cQuery	+= " 			DDF_QBRGEN, "
			cQuery	+= " 			DDF_LIMITE, "
			cQuery	+= " 			DDF_TPQBR, "			
			cQuery	+= " 			DDF_ATIVO "
			cQuery += " FROM 		" + RetSqlName("DDF") + " DDF "
			cQuery += " WHERE 	DDF.DDF_FILIAL = '" + xFilial("DDF") + "' "
			cQuery += " AND 		DDF.DDF_CODQBR = '" + PadR(DEC->DEC_CODQBR,TamSX3("DDF_CODQBR")[1]) + "' "				
			cQuery += " AND 	( (	DDF.DDF_QBRNV1 = 'S') OR (DDF.DDF_QBRNV2 = 'S') )"
			cQuery += " AND 		DDF.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY DDF_QBRNV1,DDF_QBRNV2 "

			cQuery := ChangeQuery(cQuery)
		
			dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasNV1, .F., .T.)
			
			While (cAliasNV1)->( !Eof() )

				If GetSX3Cache((cAliasNV1)->DDF_CPOSX3,"X3_TIPO") <> 'N'	//-- Se Não é Numérico, Compõe Chave De Quebra 

					If AllTrim((cAliasNV1)->DDF_QBRNV1) == 'S'
						Aadd(aOrdDDD, AllTrim((cAliasNV1)->DDF_CPOSX3))
					EndIf
			
					If AllTrim((cAliasNV1)->DDF_QBRNV2) == 'S'
						Aadd(aOrdDDE, (cAliasNV1)->DDF_CPOSX3)
					EndIf

				ElseIf (cAliasNV1)->DDF_LIMITE > 0 //-- Se For Numérico Compõe Limites Para Quebra
				
					aAdd(aBrokeBy,{(cAliasNV1)->DDF_CPOSX3,(cAliasNV1)->DDF_LIMITE,(cAliasNV1)->DDF_TPQBR})
				
				EndIf	
		
			   	(cAliasNV1)->( DbSkip() )
			EndDo                                          
			
			(cAliasNV1)->( DbCloseArea() )
		EndIf
		
		//-- Testa Se Existe Quebra Válida Para Cliente X LayOut Senão Gera Quebra Padrão
		If (Len(aOrdDDE) == 0) .Or. (Len(aOrdDDD) == 0)
		
			//-- Reinicia Variaveis (Não Remover)
			aOrdDDE := {}
			aOrdDDD := {}
			aBrokeBy:= {} 		
		
			cQuery	:= " "
			cQuery	+= " SELECT	DDF_FILIAL, "
			cQuery	+= " 			DDF_CODQBR, "
			cQuery	+= " 			DDF_DESQBR, "
			cQuery	+= " 			DDF_CPOSX3, "
			cQuery	+= " 			DDF_QBRNV1, "
			cQuery	+= " 			DDF_QBRNV2, "
			cQuery	+= " 			DDF_QBRGEN, "
			cQuery	+= " 			DDF_LIMITE, "			
			cQuery	+= " 			DDF_TPQBR, "
			cQuery	+= " 			DDF_ATIVO "
			cQuery += " FROM 		" + RetSqlName("DDF") + " DDF "
			cQuery += " WHERE 	DDF.DDF_FILIAL = '" + xFilial("DDF") + "' "	
			cQuery += " AND 		DDF.DDF_QBRGEN = 'S'"
			cQuery += " AND 	( (	DDF.DDF_QBRNV1 = 'S') OR (DDF.DDF_QBRNV2 = 'S') )"
			cQuery += " AND 		DDF.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY DDF_QBRNV1,DDF_QBRNV2 "
	
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasNV1, .F., .T.)
			
			TcSetField(cAliasNV1,"DDF_LIMITE","N",TamSX3("DDF_LIMITE")[1],TamSX3("DDF_LIMITE")[2])
						
			While (cAliasNV1)->( !Eof() )

				If GetSX3Cache((cAliasNV1)->DDF_CPOSX3 , "X3_TIPO" ) <> 'N'	//-- Se Não é Numérico, Compõe Chave De Quebra 

					If AllTrim((cAliasNV1)->DDF_QBRNV1) == 'S'
						Aadd(aOrdDDD, AllTrim((cAliasNV1)->DDF_CPOSX3))
					EndIf
			
					If AllTrim((cAliasNV1)->DDF_QBRNV2) == 'S'
						Aadd(aOrdDDE, (cAliasNV1)->DDF_CPOSX3)
					EndIf

				ElseIf (cAliasNV1)->DDF_LIMITE > 0 //-- Se For Numérico Compõe Limites Para Quebra
				
					aAdd(aBrokeBy,{(cAliasNV1)->DDF_CPOSX3,(cAliasNV1)->DDF_LIMITE,(cAliasNV1)->DDF_TPQBR})
				
				EndIf	
		
			   	(cAliasNV1)->( DbSkip() )
			EndDo                                          
			
			(cAliasNV1)->( DbCloseArea() )
		EndIf	

		lRet := Iif( (Len(aOrdDDE) == 0) .Or. (Len(aOrdDDD) == 0), .F., .T. )
		
		If !lRet
			Help('',1,'TMSAgAUT',,"Não foram encontradas quebras de agendamento configuradas no sistema",4,1)
		EndIf							
	EndIf

	//----------------------------------------------------------------------------------
	// Efetuar Obtencao Dos Registros De Edi - Agendamento E Inclusao Dos Agendamento 
	//----------------------------------------------------------------------------------
	If lRet
		//-------------------------------------------------------------------------------------------------
		// Inserir Campos No Order By De Acordo Com A Configuracao Da Tabela Ddf (Quebra De Agendamento) 
		//-------------------------------------------------------------------------------------------------
		cOrderBy	:= ""
		cQBRNV1	:= ""
		cQBRNV2	:= ""
		cQryNV2	:= ""
		cQuery		:= ""
	    
		For nCount := 1 To Len( aOrdDDD )
			If nCount <> Len( aOrdDDD )
				If !(Alltrim(aOrdDDD[ nCount ]) $ cOrderBy)
					cOrderBy += Iif( !Empty(cOrderBy)," , ","") + aOrdDDD[ nCount ]
					cQBRNV1  += Iif( !Empty(cQBRNV1) ," + ","") + "(cAliasNV1)->" + aOrdDDD[ nCount ] 
		
					If Empty(cQuery)
						cQuery	+=   " SELECT DISTINCT " + AllTrim(aOrdDDD[ nCount ]) + ", "
					Else
						cQuery	+=   AllTrim(aOrdDDD[ nCount ]) + ", "
					EndIf
				EndIf
			Else
				If !(Alltrim(aOrdDDD[ nCount ]) $ cOrderBy)
					cOrderBy += Iif( !Empty(cOrderBy)," , ","") + aOrdDDD[ nCount ]
					cQBRNV1  += Iif( !Empty(cQBRNV1) ," + ","") + "(cAliasNV1)->" + aOrdDDD[ nCount ]
		
					If Empty(cQuery)
						cQuery	+=   " SELECT DISTINCT " + AllTrim(aOrdDDD[ nCount ])
					Else
						cQuery	+=   AllTrim(aOrdDDD[ nCount ])
					EndIf
				EndIf
			EndIf	
		Next nCount
		
		For nCount := 1 To Len( aOrdDDE )
			If nCount <> Len( aOrdDDE )
				If !(Alltrim(aOrdDDE[ nCount ]) $ cOrderBy)
					cOrderBy += Iif( !Empty(cOrderBy)," , ","") + aOrdDDE[ nCount ]
					cQBRNV2  += Iif(!Empty(cQBRNV2)  ," + ","") + "(cAliasNV2)->" + aOrdDDE[ nCount ] 
				EndIf	
			Else
				If !(Alltrim(aOrdDDE[ nCount ]) $ cOrderBy)
					cOrderBy += Iif(!Empty(cOrderBy)," , ","") + aOrdDDE[ nCount ]
					cQBRNV2  += Iif(!Empty(cQBRNV2) ," + ","") + "(cAliasNV2)->" + aOrdDDE[ nCount ]
				EndIf	
			EndIf
		Next nCount
		
		//-- Adiciona a Quebra De Campo Numerico caso Exista
		For nCount := 1 To Len( aBrokeBy )
			cOrderBy += Iif( (!Empty(cOrderBy) .And. (Right(Alltrim(cOrderBy),1) <> ',')), "," , "" ) + aBrokeBy[ nCount, 1 ]
		Next nCount

		//------------------------------------------------------------------------------
		// Montar Estrutura Da Query Do Primeiro Nivel 		 
		//------------------------------------------------------------------------------
		cQuery 	+= " FROM			" + RetSqlName("DDD") + " DDD "
		cQuery		+= " INNER JOIN 	" + RetSqlName("DDE") + " DDE "
		cQuery		+= " ON 			DDE.DDE_FILIAL = '" + xFilial("DDE") + "' "
		cQuery		+= " AND 			DDE.DDE_DATAGE = DDD.DDD_DATAGE "
		cQuery		+= " AND 			DDE.DDE_HORAGE = DDD.DDD_HORAGE "
		cQuery		+= " AND 			DDE.DDE_CLIDES = DDD.DDD_CLIDES "
		cQuery		+= " AND 			DDE.DDE_LOJDES = DDD.DDD_LOJDES "
		cQuery		+= " AND 			DDE.DDE_SQEDES = DDD.DDD_SQEDES "
		cQuery		+= " AND 			DDE.DDE_CLIREM = DDD.DDD_CLIREM "
		cQuery		+= " AND 			DDE.DDE_LOJREM = DDD.DDD_LOJREM "
		cQuery		+= " AND 			DDE.DDE_SQEREM = DDD.DDD_SQEREM "
		cQuery		+= " AND 			DDE.D_E_L_E_T_ = ' ' "
		cQuery		+= " INNER JOIN  " + RetSqlName("DUE") + " DUE "
		cQuery		+= " ON			DUE.DUE_FILIAL =  '" + xFilial("DUE") + "' "
		cQuery		+= " AND			DUE.DUE_CODCLI =  '" + cCodCli + "' "
		cQuery		+= " AND			DUE.DUE_LOJCLI =  '" + cLojCli + "' "
		cQuery		+= " AND			DUE.D_E_L_E_T_ =  ' '

		cQryNV1	:= ""
		cQryNV1	+= cQuery
		cQryNV1	+= " WHERE			DDD_FILIAL 		= '" + xFilial("DDD") + "' "
		cQryNV1	+= " AND 			DDD.DDD_CODSOL 	=  DUE.DUE_CODSOL
		
		If Len(aDadAgen) == 0
			cQryNV1	+= " AND 			DDD_STATUS 		= '" + StrZero(1, Len(DDD->DDD_STATUS)) + "' "	// 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
		Else
			cQryNV1	+= " AND 			DDD_STATUS 		= '" + StrZero(2, Len(DDD->DDD_STATUS)) + "' "	// 1=EDI Importado; 2=Processado; 3=Agendamento Gerado		
		EndIf
		
		cQryNV1	+= " AND 			DDD.D_E_L_E_T_ 	= ' '"

		//-- Inclui Dados Do Vetor Na Query Quando Informado
		For nCount := 1 To Len( aDadAgen )
			cQryNV1 += " AND			DDD." + Alltrim(aDadAgen[ nCount , 1 ]) + " = '" + aDadAgen[ nCount , 2 ] + "' "
		Next nCount
		
		cQryNV1	:= ChangeQuery(cQryNV1)

		dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQryNV1), cAliasNV1, .F., .T.)	//-- Primeiro Nível		

		If (cAliasNV1)->( !Eof() )
			//------------------------------------------------------------------------------
			// Montar Query Do Segundo Nível 
			//------------------------------------------------------------------------------
			cQuery	:= " SELECT DDD.R_E_C_N_O_, "
			aCPODDD	:= {}
			aCPODDE	:= {} 
			
			For nCount := 1 To 2
				If nCount == 1
					cAlias := "DDD"
				Else
					cAlias := "DDE"
				EndIf

				//-- Retorna a estrutura
				oFormStruct		:= FwFormStruct(1,cAlias)
				aFields			:= oFormStruct:aFields

				For nAux := 1 To Len(aFields)
					cCampo	:= aFields[nAux,1]
					If  GetSX3Cache(cCampo,"X3_CONTEXT") <> 'V' 					
						If Empty(cQuery)
							cQuery	+=   " SELECT " + AllTrim(cCampo) + ", "
						Else
							cQuery	+=   AllTrim(cCampo) + ", "
						EndIf
	
						If nCount == 1
							//------------------------------------------------------------------------------
							// Adiciona Ao Vetor Somente Se O Campo Estiver Sendo  
							// Previsto A Ser Utilizado, Atraves De Sua Existencia 
							// No Vetor Adepara                                    
							//------------------------------------------------------------------------------
							If Ascan( aDEPARA, { |x| x[2] == AllTrim(cCampo) } ) > 0
								Aadd( aCPODDD, AllTrim(cCampo))
							EndIf
						Else
							//------------------------------------------------------------------------------
							// Adiciona Ao Vetor Somente Se O Campo Estiver Sendo  
							// Previsto A Ser Utilizado, Atraves De Sua Existencia 
							// No Vetor Adepara                                    
							//------------------------------------------------------------------------------
							If Ascan( aDEPARA, { |x| x[2] == AllTrim(cCampo) } ) > 0
								Aadd( aCPODDE, AllTrim(cCampo))
							EndIf
						EndIf
					EndIf
				Next nAux

			
			Next nCount
			
			//------------------------------------------------------------------------------
			// Checar Se O Ultimo Caractere Eh Uma Virgula E Sendo, Retira-La 
			//------------------------------------------------------------------------------
			If SubSTR( AllTrim(cQuery), Len(AllTrim(cQuery)), 1) == ','
				cQuery := STUFF( AllTrim(cQuery), Len(AllTrim(cQuery)), 1, '')
			EndIf
		
			cQuery 	+= " FROM 			" + RetSqlName("DDD") + " DDD "
			cQuery		+= " INNER JOIN 	" + RetSqlName("DDE") + " DDE "
			cQuery		+= " ON		( 	DDE.DDE_FILIAL =  '" + xFilial("DDE") + "' "
			cQuery		+= " AND 			DDE.DDE_DATAGE =  DDD.DDD_DATAGE "
			cQuery		+= " AND 			DDE.DDE_HORAGE =  DDD.DDD_HORAGE "
			cQuery		+= " AND 			DDE.DDE_CLIDES =  DDD.DDD_CLIDES "
			cQuery		+= " AND 			DDE.DDE_LOJDES =  DDD.DDD_LOJDES "
			cQuery		+= " AND 			DDE.DDE_SQEDES =  DDD.DDD_SQEDES "
			cQuery		+= " AND 			DDE.DDE_CLIREM =  DDD.DDD_CLIREM "
			cQuery		+= " AND 			DDE.DDE_LOJREM =  DDD.DDD_LOJREM "
			cQuery		+= " AND 			DDE.DDE_SQEREM =  DDD.DDD_SQEREM "
			cQuery		+= " AND 			DDE.D_E_L_E_T_ =  ' ' ) "	
			nCount		:= 0
			nTotReg	:= 0
			nTotAgen	:= 0
			cLinAtu	:= ""
			cLinNext	:= ""
		
			While (cAliasNV1)->( !Eof() )
				
				nCount	:= 0
				nTotReg := 0
				cQryNV2 := ""
				aDF2Ant := {}
	
				//------------------------------------------------------------------------------
				// Montar O Filtro (Where) Da Query Do Segundo Nivel 
				// Com Informacoes Obtidas Da Query Do Primeiro Nivel
				//------------------------------------------------------------------------------
				cQryNV2 := " WHERE DDD_FILIAL = '" + xFilial("DDD") + "' "
				
				If Len(aDadAgen) == 0

					cQryNV2 += " AND DDD_CLIREM = '" + cCodCli + "' "
					cQryNV2 += " AND DDD_LOJREM = '" + cLojCli + "' "
					cQryNV2 += " AND DDD_STATUS = '" + StrZero(1, Len(DDD->DDD_STATUS)) + "' " // 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
					
					For nCount := 1 To Len( aOrdDDD )
						cTemp		:= ""
						cTemp		:= "(cAliasNV1)->" + aOrdDDD[ nCount ]
						cTemp		:= &cTemp
						cQryNV2	+= " AND " + aOrdDDD[ nCount ] + " = '" + cTemp + "' "	
					Next nCount
				Else

					//-- Inclui Dados Do Vetor Na Query Quando Informado
					For nCount := 1 To Len( aDadAgen )
						cQryNV2 += " AND DDD." + Alltrim(aDadAgen[ nCount , 1 ]) + " = '" + aDadAgen[ nCount , 2 ] + "' "
					Next nCount
					
					cQryNV2 += " AND DDD_STATUS	= '" + StrZero(2, Len(DDD->DDD_STATUS)) + "' "	// 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
					
				EndIf
				
				cQryNV2 += " AND DDD.D_E_L_E_T_ 	= ' '"
	
				//------------------------------------------------------------------------------
				// Executar Query Do Segundo Nivel
				//------------------------------------------------------------------------------
				cAliasNV2 := GetNextAlias()
				cQryNV2	:= cQuery + cQryNV2 + " ORDER BY " + cOrderBy
				cQryNV2	:= ChangeQuery(cQryNV2)
				dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQryNV2), cAliasNV2, .F., .T.)	//-- Segundo Nível	
	
				If (cAliasNV2)->( !Eof() )

					While (cAliasNV2)->( !Eof() )

						nTotReg	+= 1
						aTemp	:= {}
						aDF1Ant	:= {}
						
						If nTotReg == 1 .Or. Empty(aAutDF0)
							nTotAgen += 1
				            //------------------------------------------------------------------------------
				            // Obter Campos Da Tabela Ddd E Que Encontram-Se No Retorno Da Query. 
				            // Para Cada Campo Obtido, Pega Seu Conteudo E Adicionar No Vetor     
				            // Temporario Atemp E Na Sequencia Adicionar Ao Vetor De Agend.Aut.   
				            // Tabela Destino: Df0                                                
				            //------------------------------------------------------------------------------
				            aAutDF0 := {}
				            aAutDF0 := TMSgtAlias( "DF0", aCPODDD, aDEPARA, "(cAliasNV2)->" )
						EndIf
	
			            //------------------------------------------------------------------------------
			            // Obter Campos Da Tabela Ddd E Que Encontram-Se No Retorno Da Query. 
			            // Para Cada Campo Obtido, Pega Seu Conteudo E Adicionar No Vetor     
			            // Temporario Atemp E Na Sequencia Adicionar Ao Vetor De Agend.Aut.   
			            // Tabela Destino: Df1                                                
			            //------------------------------------------------------------------------------
						aDF1Ant	:= {}
			            aDF1Ant := TMSgtAlias( "DF1", aCPODDD, aDEPARA, "(cAliasNV2)->" )
	
			            //------------------------------------------------------------------------------
			            // Obter Campos Da Tabela Dde E Que Encontram-Se No Retorno Da Query. 
			            // Para Cada Campo Obtido, Pega Seu Conteudo E Adicionar No Vetor     
			            // Temporario Atemp E Na Sequencia Adicionar Ao Vetor De Agend.Aut.   
			            // Tabela Destino: Df2                                                
			            //------------------------------------------------------------------------------
						aTemp := {}
			            aTemp := TMSgtAlias( "DF2", aCPODDE, aDEPARA, "(cAliasNV2)->" )
					
						If Len(aTemp) > 0
							Aadd( aDF2Ant, Aclone(aTemp) )
						EndIf
	
						//------------------------------------------------------------------------------
						// Armazenar Recno Para Atualizacao Do Status Ao Termino Da Rotina	
						//------------------------------------------------------------------------------
						Aadd( aRECNO, {(cAliasNV2)->R_E_C_N_O_ , "" })
	
						//------------------------------------------------------------------------------
						// Checar A Quebra Da Tabela Dde, Onde Quando Quebrar   
						// Os Itens (Produtos) Serao Inseridos Ao Vetor Aautdf2 
						// E Sera Inserido Registros Ao Vetor Aautdf1			
						//------------------------------------------------------------------------------
						cTemp 		:= ""
						cTemp 		:= &cQBRNV2 
						nBrokePar	+= Iif( Len(aBrokeBy) > 0, &("(cAliasNV2)->" + aBrokeBy[1,1]), 0 )
	
					   	(cAliasNV2)->( DbSkip() )
						
						//------------------------------------------------------------------------------
						// Checar Se O Item Anterior (Antes Do Dbskip()) Eh Igual Ao Atual 
						//------------------------------------------------------------------------------
						
						//-- 1 -> Estouro De Limite (Peso , Etc...) Gera Novo Agendamento
						//-- aAdd(aBrokeBy,{(cAliasNV1)->DDF_CPOSX3,(cAliasNV1)->DDF_LIMITE,(cAliasNV1)->DDF_TPQBR})
						If Len(aBrokeBy) > 0 .And. aBrokeBy[1,3] == '1' .And.((nBrokePar + &("(cAliasNV2)->" + aBrokeBy[1,1]) ) > aBrokeBy[1,2])
						
							If Len(aDF1Ant) > 0
								Aadd( aAutDF1, Aclone(aDF1Ant) )
							EndIf
	
							If Len(aDF2Ant) > 0
								Aadd( aAutDF2, Aclone(aDF2Ant) )
							EndIf
							
							aDF2Ant	:= {}
							aDF1Ant	:= {}

							//-------------------------------------------------------------------------------------------------
							// Caso Parametrizado Para Quebra De Novo Agendamento
							//-------------------------------------------------------------------------------------------------						
							If (Len(aAutDF0) > 0) .And. (Len(aAutDF1) > 0)
				
								//-- Inclui Solicitação De Coleta Quando Parametrizado No Perfil Do Cliente
								If lColAut
									nPosV := aScan(aAutDF0, { |x| Alltrim(x[1]) == "DF0_STATUS" })
									If nPosV == 0
										aAdd(aAutDF0,{"DF0_STATUS","2",Nil})
									Else
										aAutDF0[nPosV,2] := "2"
									EndIf	
								EndIf
							
								//-- Verifica Se Gera Preview Ou Gera Diretamente o Agendamento
								If lPreview
								
									//-- Incrementa Vetores Do Preview
									aAdd ( aPrwDF0 , 	aAutDF0 )
									aAdd ( aPrwDF1 , 	aAutDF1 )
									aAdd ( aPrwDF2 , 	aAutDF2 )

									//-- Captura Recnos Para Atualização Após Processamento
									For nCount := 1 To Len( aRECNO )
										If Ascan( aRecDDD, {|x| x[1] == aRECNO[nCount,1]}) == 0
											aAdd( aRecDDD, aRECNO[nCount] )
										EndIf
									Next nCount
								Else
									Processa( {|| TMSF05Mnt('DF0', 0, 3, .F. , .F., aAutDF0, aAutDF1, aAutDF2 ) }, STR0125 , STR0125 + Space(1) + STR0126 + "... (" + StrZero(nTotAgen, (Len( AllTrim(Str(nTotAgen)) ) + 1) 	) + ")", .F. ) //-- "Agendamento Automático" "Aguarde"
								EndIf								
							EndIf
												
							aTemp		:= {}
							aAutDF0	:= {}
							aAutDF1	:= {}
							aAutDF2	:= {}
							nBrokePar	:= 0						

						//-- 2 -> Quebra Conf. Campos da Quebra Ou Quebra Por Itens Dos Valores Numericos
						ElseIf cTemp != &cQBRNV2 .Or. Iif( (Len(aBrokeBy) > 0 .And. aBrokeBy[1,3] == '2' ), (nBrokePar + &("(cAliasNV2)->" + aBrokeBy[1,1]) ) > aBrokeBy[1,2]  , .f. )

							If Len(aDF1Ant) > 0
								Aadd( aAutDF1, Aclone(aDF1Ant) )
							EndIf
	
							If Len(aDF2Ant) > 0
								Aadd( aAutDF2, Aclone(aDF2Ant) )
							EndIf
							
							aDF2Ant	:= {}
							aDF1Ant	:= {}
							nBrokePar	:= Iif( (Len(aBrokeBy) > 0 .And. aBrokeBy[1,3] == '2' ), 0 , nBrokePar )
						
						EndIf
					EndDo
				EndIf
	
				(cAliasNV2)->( DbCloseArea() )
	
				//------------------------------------------------------------------------------
				// Instanciar E Executar Rotina Padrao De Agendamento,
				// De Forma A Gerar Agendamento Automaticamente       
				//------------------------------------------------------------------------------
				If (Len(aAutDF0) > 0) .And. (Len(aAutDF1) > 0)
				
					//-- Inclui Solicitação De Coleta Quando Parametrizado No Perfil Do Cliente
					If lColAut
						nPosV := aScan(aAutDF0, { |x| Alltrim(x[1]) == "DF0_STATUS" })
						If nPosV == 0
							aAdd(aAutDF0,{"DF0_STATUS","2",Nil})
						Else
							aAutDF0[nPosV,2] := "2"
						EndIf	
					EndIf
				
					//-- Verifica Se Gera Preview Ou Gera Diretamente o Agendamento
					If lPreview
								
						//-- Incrementa Vetores Do Preview
						aAdd ( aPrwDF0 , 	aAutDF0 )
						aAdd ( aPrwDF1 , 	aAutDF1 )
						aAdd ( aPrwDF2 , 	aAutDF2 )

						//-- Captura Recnos Para Atualização Após Processamento
						For nCount := 1 To Len( aRECNO )
							If Ascan( aRecDDD, {|x| x[1] == aRECNO[nCount,1]}) == 0
								aAdd( aRecDDD, aRECNO[nCount] )
							EndIf
						Next nCount
					Else
						Processa( {|| TMSF05Mnt('DF0', 0, 3, .F. , .F., aAutDF0, aAutDF1, aAutDF2 ) }, STR0125 , STR0125 + Space(1) + STR0126 + "... (" + StrZero(nTotAgen, (Len( AllTrim(Str(nTotAgen)) ) + 1) 	) + ")", .F. ) //-- "Agendamento Automático" "Aguarde"
					EndIf
				EndIf
									
				aTemp	:= {}
				aAutDF0	:= {}
				aAutDF1	:= {}
				aAutDF2	:= {}
	
			   	(cAliasNV1)->( DbSkip() )
			EndDo
		EndIf
		
		(cAliasNV1)->( DbCloseArea() )
		
		//-------------------------------------------------------------------------------------
		// Atualizar Status Do Registro Corrente Da Tabela Ddd Para "3 = Agendamento Gerado" 
		//                                                                                   
		// A Atualizacao Do Status Foi Colocada Aqui Ao Termino Do Processamento Das Rotinas 
		// E Nao Durante O While Do Nivel2, Pois Se Houver Algum Erro, Exemplo Errorlog,     
		// Durante O Processamento, O Itens Nao Serao Atualizados E Poderao Serem Processados
		// Em Uma Proxima Execucao                                                           
		//-------------------------------------------------------------------------------------
		If Len(aRECNO) > 0 .And. !(lPreview)
			For nCount := 1 To Len( aRECNO )
				DDD->(MsGoTo( aRECNO[ nCount , 1 ] ) )
				RecLock('DDD',.F.)
				DDD->DDD_STATUS := StrZero(3, Len(DDD->DDD_STATUS)) // 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
				MsUnLock()
			Next nCount
		EndIf
	EndIf 

	RestArea( aArea )
	RestArea( aAreaDDD )
	RestArea( aAreaDDE )
	RestArea( aAreaDDF )

Return ( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSgtAlias³ Autor ³         A.S.M         ³ Data ³ 06.11.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao desenvolvida para obter (GET) Alias para geracao do 	³±±
±±³          ³ Agendamento automatico										³±±
±±³          ³                                                 				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSgtAlias( cAlias, aCPO, aDPara, cMacro )                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                 				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                 				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Funcao utilizada pela funcao TMSAgAUT()						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSgtAlias( cAlias, aCPO, aDPara, cMacro )
	Local aRet		:= {}
	Local nCount	:= 0
	Local nPosicao	:= 0
	Local cTemp		:= ""

	For nCount := 1 To Len( aCPO )
		cTemp	 := ""
		nPosicao := Ascan( aDPara, { |x| x[1] + x[2] == cAlias + AllTrim(aCPO[ nCount ]) })

		If ( nPosicao > 0 ) .And. ( !Empty(aCPO[ nCount ]) )
			cTemp	:= cMacro + aCPO[ nCount ]
			cTemp	:= &cTemp
		EndIf
		
		If ( nPosicao > 0 ) .And. ( !Empty(cTemp) )
			Aadd( aRet, { aDPara[ nPosicao ] [ 3 ], cTemp, Nil } )
		EndIf
	Next nCount
Return( aRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSExstMan
Verifica se existe documentos na viagem sem manifesto
@type function
@author Rafael Souza
@version 12
@since 25/05/2017
@return lRet
/*/
//-------------------------------------------------------------------------------------------------

Static Function TMSExstMan(cFilOri,cViagem)

	Local lRet 		:= .T.
	Local cQuery	:= ""
	Local cAlias	:= ""

	Default cFilOri := ""
	Default cViagem := ""

	cQuery := "SELECT DUD.DUD_MANIFE, DT6.DT6_DOCTMS, DTP.DTP_TIPLOT "
	cQuery += "FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += 	"ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += 	"AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
	cQuery += 	"AND DT6.DT6_DOC = DUD.DUD_DOC "
	cQuery += 	"AND DT6.DT6_SERIE = DUD.DUD_SERIE "
	cQuery += 	"AND DT6.DT6_DOCTMS IN ('2', '6','7','9','A','E' ) "
	cQuery += 	"AND DT6.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("DTP") + " DTP "
	cQuery += 	"ON DTP.DTP_FILIAL = '" + xFilial("DTP") + "' "
	cQuery += 	"AND DTP.DTP_FILORI = DT6.DT6_FILORI "
	cQuery += 	"AND DTP.DTP_LOTNFC = DT6.DT6_LOTNFC "
	cQuery += 	"AND DTP.DTP_TIPLOT IN ( '3' , '4' ) " 
	cQuery += 	"AND DTP.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += 	"AND DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += 	"AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery +=   "AND DUD.DUD_MANIFE = '' "
	cQuery += 	"AND DUD.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
	
	// Manifesto em branco e (Lote Eletrônico ou CTe Único) e Documento = CTE.
	If (cAlias)->(!Eof())
		lRet := .F.		
	EndIf
	
	(cAlias)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldUFManif
Verifica se existem UF's que não contem MDF-e
@type function
@author Caio Murakami
@version 12
@since 26/02/2019
@return lRet
/*/
//-------------------------------------------------------------------------------------------------
Static Function VldUFManif(cFilOri,cViagem)
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
LocaL lUFAtiv	:= DTW->(ColumnPos("DTW_UFATIV")) > 0
Local cAtvChgCli:= SuperGetMv('MV_ATVCHGC',,'')
Local cTipManif	:= ""
Local aUfAtiv	:= {} 

Default cFilOri		:= ""
Default cViagem		:= ""

If lUFAtiv

	//Se o campo do Tipo de Manifesto ainda nao constar na base, utilizar o Pergunte antigo.
	If DTX->(FieldPos("DTX_TIPMAN")) > 0
		Pergunte("TMA190A", .F.)
		cTipManif := cValToChar(mv_par01)
	Else
		cTipManif := "1"
	EndIf

	aUfAtiv		:= RetUFDTWDc( cFilOri , cViagem )

	If Len(aUfAtiv) > 0 

		//-- A querie verifica se existem UF em que não existam manifestos
		cQuery	+= " SELECT DTW_UFATIV UFATIV  "
		cQuery	+= " FROM " + RetSQLName("DTW") + " DTW "
		If TableInDic("DLT") .And.  DTW->(ColumnPos("DTW_IDDTW")) > 0		
			cQuery	+= " INNER JOIN " + RetSQLName("DLT") + " DLT "
			cQuery	+= " 	ON DLT_FILIAL 	= '" + xFilial("DLT") + "' "
			cQuery	+= "	AND DLT_FILORI 	= DTW_FILORI "
			cQuery	+= "	AND DLT_VIAGEM	= DTW_VIAGEM "
			cQuery	+= "	AND DLT_IDDTW		= DTW_IDDTW "
			cQuery	+= "	AND DLT.D_E_L_E_T_ = '' "
			cQuery	+= "	INNER JOIN " + RetSQLName("DUD") + " DUD "
			cQuery	+= "		ON DUD_FILIAL		= '" + xFilial("DUD") + "' "
			cQuery	+= "		AND DUD_FILORI	= DLT_FILORI "
			cQuery	+= "		AND DUD_VIAGEM 	= DLT_VIAGEM "
			cQuery	+= " 		AND DUD_STATUS	NOT IN ('4','9') "
			cQuery	+= "		AND DUD.D_E_L_E_T_  = '' "
			cQuery 	+= "	INNER JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery 	+= "		ON DT6_FILIAL 	= '" + xFilial("DT6") + "' "
			cQuery 	+= "		AND DT6_FILDOC 	= DUD_FILDOC "
			cQuery 	+= "		AND DT6_DOC 		= DUD_DOC "
			cQuery 	+= "		AND DT6_SERIE 	= DUD_SERIE "		
			If cTipManif == "2"
				cQuery 	+= "		AND DT6_DOCTMS IN ('2', '6','7','9','A','E' ) "
			Else
				cQuery 	+= "		AND DT6_DOCTMS IN ('1', '5','B','C','H','I','K','N','0' ) " 
			EndIf
			cQuery 	+= "		AND DT6.D_E_L_E_T_ = ' ' "
			cQuery 	+= "	INNER JOIN " + RetSqlName("DTP") + " DTP "
			cQuery 	+= "		ON DTP_FILIAL = '" + xFilial("DTP") + "' "
			cQuery 	+= "		AND DTP_FILORI = DT6_FILORI "
			cQuery 	+= "		AND DTP_LOTNFC = DT6_LOTNFC "
			If cTipManif == "2"
				cQuery 	+= "	AND DTP_TIPLOT IN ( '3' , '4' ) " 
			EndIf
			cQuery 	+= "	AND DTP.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery	+= " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery	+= " 	AND DTW_FILORI 	= '" + cFilOri + "' "
		cQuery  += " 	AND DTW_VIAGEM 	= '" + cViagem + "' "
		cQuery	+= " 	AND DTW_STATUS	= '1' " //-- 1=Em Aberto
		cQuery	+= " 	AND DTW_DATREA	= '' "
		cQuery	+= " 	AND DTW_HORREA	= '' "
		cQuery	+= " 	AND DTW_CODCLI	<> '' "
		cQuery	+= "	AND DTW_LOJCLI 	<> '' "
		cQuery	+= "	AND DTW_ATIVID 	= '" + cAtvChgCli + "' "
		cQuery	+= "	AND DTW_UFATIV 	<> '' "
		cQuery	+= " 	AND DTW.D_E_L_E_T_ = '' "
		
		cQuery	+= " UNION "

		cQuery	+= " SELECT DTW_UFATIV  UFATIV "
		cQuery	+= " FROM " + RetSQLName("DTW") + " DTW "
		If TableInDic("DLT") .And.  DTW->(ColumnPos("DTW_IDDTW")) > 0		
			cQuery	+= " INNER JOIN " + RetSQLName("DLT") + " DLT "
			cQuery	+= " 	ON DLT_FILIAL 	= '" + xFilial("DLT") + "' "
			cQuery	+= "	AND DLT_FILORI 	= DTW_FILORI "
			cQuery	+= "	AND DLT_VIAGEM	= DTW_VIAGEM "
			cQuery	+= "	AND DLT_IDDTW		= DTW_IDDTW "
			cQuery	+= "	AND DLT.D_E_L_E_T_ = '' "
			cQuery	+= "	INNER JOIN " + RetSQLName("DUD") + " DUD "
			cQuery	+= "		ON DUD_FILIAL		= '" + xFilial("DUD") + "' "
			cQuery	+= "		AND DUD_FILORI	= DLT_FILORI "
			cQuery	+= "		AND DUD_VIAGEM 	= DLT_VIAGEM "
			cQuery	+= " 		AND DUD_STATUS	NOT IN ('4','9') "
			cQuery	+= "		AND DUD.D_E_L_E_T_  = '' "
			cQuery 	+= "	INNER JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery 	+= "		ON DT6_FILIAL 	= '" + xFilial("DT6") + "' "
			cQuery 	+= "		AND DT6_FILDOC 	= DUD_FILDOC "
			cQuery 	+= "		AND DT6_DOC 		= DUD_DOC "
			cQuery 	+= "		AND DT6_SERIE 	= DUD_SERIE "		
			If cTipManif == "2"
				cQuery 	+= "		AND DT6_DOCTMS IN ('2', '6','7','9','A','E' ) "
			Else
				cQuery 	+= "		AND DT6_DOCTMS IN ('1', '5','B','C','H','I','K','N','0' ) " 
			EndIf
			cQuery 	+= "		AND DT6.D_E_L_E_T_ = ' ' "
			cQuery	+= "		INNER JOIN " + RetSQLName("DT5") + " DT5 "
			cQuery	+= "			ON DT5_FILIAL 		= '" + xFilial("DT5") + "' "
			cQuery	+= "				AND DT5_FILDOC	= DUD_FILDOC "
			cQuery	+= "				AND DT5_DOC			= DUD_DOC "
			cQuery	+= "				AND DT5_SERIE		= DUD_SERIE "
			cQuery	+= "				AND DT5.D_E_L_E_T_  = '' "
		EndIf
		cQuery	+= " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery	+= " 	AND DTW_FILORI 	= '" + cFilOri + "' "
		cQuery  += " 	AND DTW_VIAGEM 	= '" + cViagem + "' "
		cQuery	+= " 	AND DTW_STATUS	= '1' " //-- 1=Em Aberto
		cQuery	+= " 	AND DTW_DATREA	= '' "
		cQuery	+= " 	AND DTW_HORREA	= '' "
		cQuery	+= " 	AND DTW_CODCLI	<> '' "
		cQuery	+= "	AND DTW_LOJCLI 	<> '' "
		cQuery	+= "	AND DTW_ATIVID 	= '" + cAtvChgCli + "' "
		cQuery	+= "	AND DTW_UFATIV 	<> '' "
		cQuery	+= " 	AND DTW.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

		While (cAliasQry)->( !Eof() )

			If aScan(aUFAtiv,{ |x| x == (cAliasQry)->UFATIV }) == 0 
				lRet	:= .F. 
				Exit
			Else
				lRet	:= .T. 
			EndIf

			(cAliasQry)->( dbSkip() )
		EndDo
		
		(cAliasQry)->( dbCloseArea() )
	
	EndIf

EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetUFDTWDc
Retorna todas as UF's dos documentos da viagem

@type function
@author Caio Murakami
@version 12
@since 06/04/2019
@return lRet
/*/
//-------------------------------------------------------------------------------------------------
Static Function RetUFDTWDc( cFilOri , cViagem )
Local aRet				:= {}
Local cQuery			:= ""
Local cAliasQry		:= GetNextAlias()
Local aArea				:= GetArea()
Local cTipManif		:= ""

Default cFilOri		:= ""
Default cViagem		:= ""

If DTX->(FieldPos("DTX_TIPMAN")) > 0
	Pergunte("TMA190A", .F.)
	cTipManif := cValToChar(mv_par01)
Else
	cTipManif := "1"
EndIf

cQuery	+= " 	SELECT DTX_UFATIV UFATIV FROM "+ RetSQLName("DUD") + " DUD "
cQuery	+= "	INNER JOIN "  + RetSQLName("DTX") + " DTX "	
cQuery	+= "			ON DTX_FILIAL 	= '" + xFilial("DTX") + "' "
cQuery	+= " 			AND DTX_FILORI	= DUD_FILORI "
cQuery	+= " 			AND DTX_VIAGEM	= DUD_VIAGEM "
cQuery	+= " 			AND DTX_STATUS	= '2' " //-- 2=Enviado
cQuery	+= " 			AND DTX.D_E_L_E_T_ = '' "
cQuery 	+= "	INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery 	+= "		ON DT6_FILIAL 	= '" + xFilial("DT6") + "' "
cQuery 	+= "		AND DT6_FILDOC 	= DUD_FILDOC "
cQuery 	+= "		AND DT6_DOC 		= DUD_DOC "
cQuery 	+= "		AND DT6_SERIE 	= DUD_SERIE "

If cTipManif == "2"
	cQuery 	+= "	AND DT6_DOCTMS IN ('2', '6','7','9','A','E' ) "
Else
	cQuery 	+= "	AND DT6_DOCTMS IN ('1', '5','B','C','H','I','K','N','0' ) " 
EndIf

cQuery 	+= "	AND DT6.D_E_L_E_T_ = ' ' "
cQuery 	+= "	INNER JOIN " + RetSqlName("DTP") + " DTP "
cQuery 	+= "		ON DTP_FILIAL = '" + xFilial("DTP") + "' "
cQuery 	+= "		AND DTP_FILORI = DT6_FILORI "
cQuery 	+= "		AND DTP_LOTNFC = DT6_LOTNFC "

If cTipManif == "2"
	cQuery 	+= "	AND DTP_TIPLOT IN ( '3' , '4' ) " 
EndIf

cQuery 	+= "	AND DTP.D_E_L_E_T_ = ' ' "
cQuery	+= "	WHERE DUD_FILIAL	= '" + xFilial("DUD") + "' "
cQuery	+= "		AND DUD_FILORI	= '" + cFilOri	+ "' "
cQuery	+= "		AND DUD_VIAGEM 	= '" + cViagem 	+ "' "
cQuery	+= " 		AND DUD_STATUS	NOT IN ('4','9') "
cQuery	+= "		AND DUD.D_E_L_E_T_  = '' "
cQuery	+= "	UNION "
cQuery	+= "	SELECT A1_EST UFATIV FROM " + RetSQLName("DUD") + " DUD "
cQuery	+= "	INNER JOIN " + RetSQLName("DT5") + " DT5 "
cQuery	+= "		ON DT5_FILIAL 		= '" + xFilial("DT5") + "' "
cQuery	+= "			AND DT5_FILDOC	= DUD_FILDOC "
cQuery	+= "			AND DT5_DOC			= DUD_DOC "
cQuery	+= "			AND DT5_SERIE		= DUD_SERIE "
cQuery	+= "			AND DT5.D_E_L_E_T_  = '' "
cQuery	+= "	INNER JOIN " + RetSQLName("SA1") + " SA1 "
cQuery	+= "		ON A1_FILIAL 			= '" + xFilial("SA1") + "' "
cQuery	+= "			AND A1_COD			= DT5_CLIREM "
cQuery	+= "			AND A1_LOJA			= DT5_LOJREM "
cQuery	+= "			AND SA1.D_E_L_E_T_ 	= '' "
cQuery 	+= "	INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery 	+= "		ON DT6_FILIAL 	= '" + xFilial("DT6") + "' "
cQuery 	+= "		AND DT6_FILDOC 	= DUD_FILDOC "
cQuery 	+= "		AND DT6_DOC 		= DUD_DOC "
cQuery 	+= "		AND DT6_SERIE 	= DUD_SERIE "

If cTipManif == "2"
	cQuery 	+= "	AND DT6_DOCTMS IN ('2', '6','7','9','A','E' ) "
Else
	cQuery 	+= "	AND DT6_DOCTMS IN ('1', '5','B','C','H','I','K','N','0' ) " 
EndIf

cQuery 	+= "	AND DT6.D_E_L_E_T_ = ' ' "
cQuery	+= "		WHERE DUD_FILIAL		= '" + xFilial("DUD") + "' "
cQuery	+= "		AND DUD_FILORI		= '" + cFilOri	+ "' "
cQuery	+= "		AND DUD_VIAGEM 		= '" + cViagem 	+ "' "
cQuery	+= " 			AND DUD_STATUS		NOT IN ('4','9') "
cQuery	+= "			AND DUD.D_E_L_E_T_  = '' "
cQuery	+= "	UNION "	
cQuery	+= " 	SELECT DTX_UFATIV UFATIV FROM " + RetSQLName("DTX") + " DTX "
cQuery	+= "	INNER JOIN " + RetSQLName("DUD") + " DUD "
cQuery	+= "		ON DUD_FILIAL 	= '" + xFilial("DUD") + "' "
cQuery	+= "			AND DUD_FILORI		= '" + cFilOri	+ "' "
cQuery	+= "			AND DUD_VIAGEM 		= '" + cViagem 	+ "' "
cQuery	+= "			AND DUD_FILMAN		= DTX_FILMAN "
cQuery	+= "			AND DUD_MANIFE		= DTX_MANIFE "
cQuery	+= " 			AND DUD_STATUS		IN ('4') " //-- 4=Encerrado
cQuery	+= "			AND DUD.D_E_L_E_T_  = '' "
cQuery	+= "		WHERE DTX_FILIAL 		= '" + xFilial("DTX") + "' "
cQuery	+= " 			AND DTX_FILORI		= '" + cFilOri + "' "
cQuery	+= " 			AND DTX_VIAGEM		= '" + cViagem + "' "
cQuery	+= " 			AND DTX_STATUS		= '3' " //-- 3=Encerrado
cQuery	+= " 			AND DTX.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	Aadd( aRet , (cAliasQry)->UFATIV )
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCampo
Retorna campo de um registro

@type static function
@author Valdemar
@version 12
@since 03/02/2020
@return cRet
/*/
//-------------------------------------------------------------------------------------------------

Static Function RetCampo(cAlias,nIndice,cChave,cCampo)
Local aAreas   := {&(cAlias)->(GetArea()),GetArea()}
Local cRet     := ""

Default cAlias  := ""
Default nIndice := 0
Default cChave  := ""
Default cCampo  := ""

If !Empty(cAlias) .And. !Empty(nIndice) .And.!Empty(cChave) .And.!Empty(cCampo)
	cRet := Posicione(cAlias,nIndice,cChave,cCampo)
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAtuDTY
Inclusao de Impostos no Contrato de Carreteiro   (³TmsxInImp)
@type static function
@version 12
@since 17/01/2012
/*/
//-------------------------------------------------------------------------------------------------
Function TMSAtuDTY(cFilOri,cViagem,nVlr_IRRF,nVlr_INSS,nVlr_SEST,nVlr_VLSEST,nVlr_VLSENA , nTxAtivDeb)
Local aAreaDTY:= DTY->(GetArea())

Default cFilOri     := ""
Default cViagem     := ""
Default nVlr_IRRF   := 0
Default nVlr_INSS   := 0
Default nVlr_SEST   := 0
Default nVlr_VLSEST := 0
Default nVlr_VLSENA := 0
Default nTxAtivDeb	:= 0 

DTY->(DbSetOrder(2))					//-- Procuramos seu ctc correspondente   | viagem precisa estar liberada ou aguardando lib
If  DTY->(MsSeek(cSeek:=xFilial("DTY",cFilOri)+cFilOri+cViagem))
	RecLock('DTY',.F.)      				//-- Limpa valores gerados anteriormente
	DTY->DTY_IRRF	  := 0
	DTY->DTY_INSS     := 0
	DTY->DTY_SEST	  := 0
	DTY->DTY_IRRF	  := nVlr_IRRF
	DTY->DTY_INSS     := nVlr_INSS
	DTY->DTY_SEST	  := nVlr_SEST
	If DTY->(ColumnPOs('DTY_VLSEST')) > 0  //ERP Datasul
		DTY->DTY_VLSEST := nVlr_VLSEST
	EndIf
	If DTY->(ColumnPOs('DTY_VLSENA')) > 0  //ERP Datasul
		DTY->DTY_VLSENA := nVlr_VLSENA
	EndIf
	If nTxAtivDeb > 0 
		DTY->DTY_VLDECR	+= nTxAtivDeb
	EndIF 
	DTY->(MsUnlock())
EndIf

RestArea(aAreaDTY)
Return

//--------------------------------------------------------
/*/{Protheus.doc} TMSAtuDEN
Atualiza dados da Movimentação REPOM - Tabela DEN
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------
Static Function	TMSAtuDEN(cFilOri,cViagem,aMovtos,cCodOpe,nAux,cAcaoDEN)
Local lRet:= .T.

Default cFilOri:= ""
Default cViagem:= ""
Default aMovtos:= {}
Default cCodOpe:= ""
Default nAux   := 0
Default cAcaoDEN:= 0 //0-Inclusao, 1-Exclusão
		
If cAcaoDEN == "0"  
	TMSGrvDEN(cFilOri,cViagem,aMovtos,cCodOpe,nAux) 
ElseIf cAcaoDEN == "1"  
	TMSExcDEN(cFilOri,cViagem,aMovtos,cCodOpe,nAux)  
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} TMSGrvDEN
Grava o Movimento na Tabela de Movimentação de Valores
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------
Static Function TMSGrvDEN(cFilOri,cViagem,aMovtos,cCodOpe,nAux) 
Local lRet:= .T.

Default cFilOri:= ""
Default cViagem:= ""
Default aMovtos:= {}
Default cCodOpe:= ""
Default nAux   := 0

	RecLock('DEN',.T.)
	DEN->DEN_FILIAL := xFilial('DEN')
	DEN->DEN_IDREG  := aMovtos[nAux,1]
	DEN->DEN_CODOPE := cCodOpe
	DEN->DEN_FILORI := cFilOri
	DEN->DEN_VIAGEM := cViagem
	DEN->DEN_DTMOV  := dDataBase
	DEN->DEN_HRMOV  := PadL(StrTran(Left(Time(),5),':',''),4,'0')
	DEN->DEN_CODMOV := aMovtos[nAux,2]
	DEN->DEN_VALOR  := aMovtos[nAux,3]
	DEN->DEN_ACAO   := aMovtos[nAux,4]
	DEN->DEN_STATUS := '1'
	DEN->DEN_RECENV := 'E'
	MsUnLock()


Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSExcDEN
Exclui o Movimento na Tabela de Movimentação de Valores
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSExcDEN(cFilOri,cViagem,aMovtos,cCodOpe,nAux)  
Default cFilOri:= ""
Default cViagem:= ""
Default aMovtos:= {}
Default cCodOpe:= ""
Default nAux   := 0

DEN->(DbSetOrder(1))
If DEN->(MsSeek(xFilial('DEN')+cFilOri+cViagem))
	While DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM) == xFilial('DTR')+DTR->(DTR_FILORI+DTR_VIAGEM)
		If RTrim(DEN->DEN_IDREG) == RTrim(aMovtos[nAux,1]) .And. DEN->DEN_RECENV == 'E'
			If !lRestRepom
				//-- Atualiza o Log de Transacoes
				TMSGerLog(cCodOpe, 'MV', 'E', DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM+DtoS(DEN_DTMOV)+DEN_HRMOV), 'DEN', '1' )
			EndIf

			RecLock('DEN',.F.)
			DEN->(DbDelete())
			MsUnLock()
		EndIf
		DEN->(DbSkip())
	EndDo
EndIf

Return	

//--------------------------------------------------------
/*/{Protheus.doc} TmsIncImp
Retorno dos Movimentos do Contrato Repom Versao 2.2 
@type  Function
@author Katia
@version 12.1.31
@since 05/11/2020
@return aMovtos
/*/
//----------------------------------------------------------
Function TmsIncImp(cFilOri, cViagem)
Local aRetShip:= {}
Local aMovtos := {}

aRetShip:= TM15StaPrc(cFilOri,cViagem)
If Len(aRetShip) > 0
	aMovtos:= TM15MovPrc(aRetShip)

EndIf

Return aMovtos

//-------------------------------------------------------------------
/*{Protheus.doc} ExisteSDG
Verifica se a viagem possui SDG gerado por outra rotina
@type Function
@author Valdemar Roberto Mognon
@since 23/05/2021
@version 12.1.30
@param cCampo
@return lRet
*/
//------------------------------------------------------------------
Function ExisteSDG(cFilOri,cViagem,cCodVei,cRotina,cTipGer)
Local aAreas    := {GetArea()}
Local lRet      := .F.
Local cQuery    := ""
Local cAliasSDG := ""

Default cFilOri := ""
Default cViagem := ""
Default cRotina := ""

cAliasSDG := GetNextAlias()
cQuery := " SELECT COUNT(R_E_C_N_O_) QTDSDG "
cQuery += "   FROM " + RetSqlName("SDG") + " SDG "
cQuery += "  WHERE DG_FILIAL  = '" + xFilial("SDG")	+ "' "
If !Empty(cFilOri)
	cQuery += "    AND DG_FILORI  = '" + cFilOri + "' "
EndIf
cQuery += "    AND DG_VIAGEM  = '" + cViagem + "' "
If !Empty(cCodVei)
	cQuery += "    AND DG_CODVEI  = '" + cCodVei + "' "
EndIf
cQuery += "    AND DG_GERADOR <> '" + cRotina + "' "
If !Empty(cTipGer)
	cQuery += "    AND DG_TIPGER  = '" + cTipGer + "' "
EndIf
cQuery += "    AND D_E_L_E_T_ = ' ' "					
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDG,.T.,.F.)

If (cAliasSDG)->QTDSDG > 0
	lRet := .T.
EndIf				
(cAliasSDG)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetMunISS
Verifica se a viagem possui SDG gerado por outra rotina
@type Function
@author Valdemar Roberto Mognon
@since 23/05/2021
@version 12.1.30
@param cCampo
@return lRet
*/
//------------------------------------------------------------------
Function RetMunISS(cCodCli,cLojCli,cCodFor,cLojFor)
Local aAreas := {SA1->(GetArea()),DUY->(GetArea()),GetArea()}
Local cCdrCal := ""

Default cCodCli := ""
Default cLojCli := ""

If DUY->(ColumnPos("DUY_CODFOR")) > 0 .And. DUY->(ColumnPos("DUY_LOJFOR")) > 0

	//-- Verifica se foi selecionado Região de Cálculo do Documento
    If SF2->(!Eof()) .And. FwIsInCallStack("A040DupRec") 
		cCdrCal := TmsISSVar(SF2->(F2_FILIAL+F2_DOC+F2_SERIE) /*cChv*/, "ISS_CDRCAL" /*cVar*/)
	EndIf

	//-- Caso não tenha Região de Cálculo do Documento, busca a região do Devedor
	If Empty(cCdrCal)
		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
			cCdrCal := SA1->A1_CDRDES
		EndIf
	EndIf

	//-- Selecionada a Região, busca o Fornecedor para o imposto
	If !Empty(cCdrCal)
		DUY->(DbSetOrder(1))
		If DUY->(MsSeek(xFilial("DUY") + cCdrCal))
			If !Empty(DUY->DUY_CODFOR) .And. !Empty(DUY->DUY_LOJFOR)
				cCodFor := DUY->DUY_CODFOR
				cLojFor := DUY->DUY_LOJFOR
			EndIf
		EndIf			
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-------------------------------------------------------------------
/*{Protheus.doc} TmsISSVar
Armazena variáveis ("Set": uValue <> NIL) do cálculo do TMS - TMSA200
  para retorná-las ("Get": uValue == NIL) na função RetMunISS - TMSXFUNC

@type Function
@author Daniel Leme
@since 14/09/2021
@version 12.1.30
@param cChv
@param cVar
@param uValue
@return uRet
*/
//------------------------------------------------------------------
Function TmsISSVar(cChv,cVar,uValue)
Local uRet

//-- Não foi criado array estático para não sobrecarregar memória
Static ISS_CHV
Static ISS_CDRCAL

//-- Inicialização Estáticas
Default ISS_CHV    := ""
Default ISS_CDRCAL := "" 

//-- Inicialização Args
Default cChv    := ""
Default cVar    := ""

//-- Seta o Valor da variável e a chave à qual pertence (ex: Fildoc+Doc+Serie)
If uValue != Nil
	If cVar == "ISS_CDRCAL"
		ISS_CHV    := cChv
		ISS_CDRCAL := uValue
		uRet       := .T.
	EndIf
//-- Retorna o Valor da variável (se a chave for igual à armazenada)
ElseIf uValue == Nil .And. ISS_CHV == cChv
	If cVar == "ISS_CDRCAL"
		If !Empty(ISS_CDRCAL)
			uRet   := ISS_CDRCAL
		Else
			uRet   := ""
		EndIf
	EndIf
EndIf

Return uRet
