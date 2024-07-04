#INCLUDE "OGX155.ch"
#include "protheus.ch"

/** {Protheus.doc} OGX155
Rotina chamada através do Ponto de Entrada no final da gravação do Documento de Saída ( MATA460 )
Chamado dos antes dos PEs: M460FIM (MATA460) e M460FIM (MATA461)

@param: 	Nil
@return:	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
//Programa Original: ARMXPE02
Function OGX155()
	Local aAreaAtu 		:= GetArea()
	Local aAreaSC5 		:= SC5->( GetArea() )
	Local aAreaSC6 		:= SC6->( GetArea() )
	Local aAreaSD2 		:= SD2->( GetArea() )
	Local aAreaNJJ 		:= NJJ->( GetArea() )
	Local aAreaNJR 		:= NJR->( GetArea() )
	Local aAreaADA 		:= ADA->( GetArea() )
	Local aAreaSE1 		:= SE1->( GetArea() )
	Local aVincCabNF 	:=	{}
	Local aVincIteNF 	:= 	{}
	Local aLinha		:=	{}
	Local cOrigem		:= 	{}
	Local aVncCRec		:=  {}
	Local cHist			:= ''
	Local cGenMod   	:= ''
	Local cCodCtr		:= ""
	Local cCodRom		:= ""
	Local aVlrTot       := {}
	Local nPos          := 0
	Local nVlrNJM       := 0
	local nx			:= 0
	Local aVncCPag      := {}
	Local aLinVncAux2   :={}

	Local lSISDEV       := SuperGetMV("MV_SISDEV", .F., .F.)

	Private _lLWR12123 	:= GetRpoRelease() < "12.1.023"

	If _lLWR12123

		dbselectArea( "SD2" ) // Item da NF de Saída
		dbSetOrder( 3 )
		If dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
			While .Not. SD2->( Eof() ) ;
			.And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )

				dbSelectArea( "SC5" ) // Cabecalho do PV
				dbSetOrder( 1 )
				If dbSeek( xFilial( "SC5" ) + SD2->( D2_PEDIDO ) )

					dbSelectArea( "SC6" ) // Item do PV
					dbSetOrder( 1 )
					If dbSeek( xFilial( "SC6" ) + SD2->( D2_PEDIDO ) + SD2->( D2_ITEMPV ) )

						dbSelectArea( "NJJ" ) // Romaneio
						NJJ->( dbSetOrder(1) )
						If dbSeek( xFilial( "NJJ" ) + SC6->( C6_CODROM ) )

							If .Not. Empty( SC6->( C6_CTROG ) )

								// Vincula a NF ao Romaneio
								RecLock( "SF2", .f. )
								SF2->( F2_CODROM ) 	:= NJJ->( NJJ_CODROM )
								SF2->( msUnLock() )

								// Vincula o Item da NF ao Romaneio
								RecLock( "SD2", .f. )
								SD2->( D2_CTROG ) 	:= SC6->( C6_CTROG )
								SD2->( D2_CODSAF ) 	:= SC6->( C6_CODSAF )
								SD2->( D2_CODROM ) 	:= SC6->( C6_CODROM )
								SD2->( D2_ITEROM )	:= SC6->( C6_ITEROM )
								cCodRom				:= SC6->( C6_CODROM )
								msUnLock("SD2")

								dbSelectArea( "NJM" ) // Item do romaneio
								dbSetOrder( 1 )
								If dbSeek( xFilial( "NJM" ) + SC6->( C6_CODROM ) + SC6->( C6_ITEROM ) )

									// Atualiza o item do romaneio (NJM)
									RecLock( "NJM", .f. )
									NJM->( NJM_DOCSER ) := SF2->( F2_SERIE   )
									NJM->( NJM_DOCNUM ) := SF2->( F2_DOC     )
									NJM->( NJM_DOCEMI ) := SF2->( F2_EMISSAO )
									NJM->( NJM_DOCESP ) := SF2->( F2_ESPECIE )
									NJM->( NJM_CHVNFE ) := SF2->( F2_CHVNFE )
									NJM->( NJM_STAFIS ) := "2"
									NJM->( NJM_DTRANS ) := dDatabase
									msUnLock("NJM")

									If NJJ->( NJJ_TIPO ) $ "6|8"
										//criar os totais
										nPos  := aScan(aVlrTot,{|x| x[1] == NJM->( Recno() )  })
										If nPos > 0
											aVlrTot[nPos][2] += SD2->( D2_TOTAL )
										else
											aadd (aVlrTot, {NJM->( Recno() ),  SD2->( D2_TOTAL )} )
										endif
									endif

									// Atualiza o registro de NJJ com o primeiro de NJM
									OGX140AtNJJ( xFilial( "NJJ" ), NJJ->( NJJ_CODROM ) )

									If NJM->( NJM_TIPO ) $ "4|5|8|9"
										If Empty(cCodCtr) .and. NJM->( NJM_TIPO ) = "4"
											cCodCtr := SC6->( C6_CTROG )
										EndiF

										SF4->( dbSetOrder( 1 ) )
										SF4->( dbSeek( xFilial( "SF4" ) + SD2->( D2_TES ) ) )
										If SF4->( F4_DUPLIC ) = "S"

											// Atualiza valores financeiros provisorios do contrato
											OGA250ATUF(NJM->( NJM_CODCTR ), NJM->( NJM_QTDFIS ), IIF(NJM->( NJM_TIPO ) $ "4|5","2","1" ))

											dbSelectArea( "SE1" ) // Titulo a Receber
											dbSetOrder( 2 )  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
											dbSeek( xFilial( "SE1" ) + SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) )
											While .Not. SE1->( Eof() ) .And. SE1->( E1_FILIAL ) == xFilial( "SE1" );
											.And. SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ==  SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) ;
											.And. Empty( SE1->( E1_CTROG ) )

												If	RecLock( "SE1", .f. )
													SE1->( E1_MOVIMEN ) 	:= dDatabase
													SE1->( E1_CTROG )		:= cCodCtr
													SE1->( E1_CODSAF )	:= NJM->( NJM_CODSAF )

													/*NN7->( dbSetOrder( 1 ) )
													NN7->( dbSeek( xFilial( "NN7" ) + cCodCtr ) )

													While !NN7->( Eof() ) .And. xFilial( "NN7" ) = NN7->( NN7_FILIAL ) .And. cCodCtr = NN7->( NN7_CODCTR ) .And. NN7->( NN7_DTVENC ) >= dDatabase
													SE1->( E1_VENCREA ) 	:= DataValida(NN7->( NN7_DTVENC ),.T.)
													SE1->( E1_VENCTO ) 	:= NN7->( NN7_DTVENC )
													SE1->( E1_NATUREZ ) 	:= NN7->( NN7_NATURE )
													SE1->( E1_CCD ) 		:= NN7->( NN7_CCD )
													Exit
													EndDo
													*/

													msUnLock("SE1")
												EndIf

												SE1->( DbSkip() )
											EndDo
										EndIf
									EndIf

									If NJM->( NJM_TIPO ) = "6" .and. NJM->NJM_TRSERV $ '1|2'   // retorno depósito terceiros e transfere serviços

										dbSelectArea( "SD1" )  // ITENS DA NOTA DE ENTRADA ORIGINAL
										dbSetOrder( 1 )
										dbSeek( xFilial( "SD1" ) + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_ITEMORI)
										While ! SD1->( Eof() ) ;
										.And. SD1->D1_FILIAL  = xFilial('SD1') ;
										.And. SD1->D1_DOC     = SD2->D2_NFORI  ;
										.And. SD1->D1_SERIE   = SD2->D2_SERIORI;
										.And. SD1->D1_FORNECE = SD2->D2_CLIENTE;
										.And. SD1->D1_LOJA    = SD2->D2_LOJA   ;
										.And. SD1->D1_COD     = SD2->D2_COD    ;
										.And. SD1->D1_ITEM    = SD2->D2_ITEMORI

											dbSelectArea('NKG')
											dbSetOrder(2)
											dbSeek( xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM ) )
											While ! NKG->( Eof() );
											.And. NKG->( NKG_FILIAL + NKG_CODROM + NKG_ITEROM ) == xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM )

												If Empty(NKG->NKG_FECSER) .Or. NKG->NKG_FECSER = ''

													AGRDELEREG('NKG',(cAliasQuery)->NKG_CODCTR+(cAliasQuery)->NKG_ITEMOV,1,.f.)

												Endif

												NKG->( DbSkip() )
											EndDo

											SD1->( DbSkip() )
										EndDo
									Endif
								EndIf
							Endif
						EndIf
					Endif
				EndIf

				//Coletar dados de expedição de sementes/mudas a serem transmitidas ao SISDEV
				IF AliasIndic("ND3") .AND. lSISDEV
					DbSelectArea('ND3')
					IF ND3->(ColumnPos('ND3_CODPRO')) > 0 .AND. ND3->(ColumnPos('ND3_CLIENT')) > 0 .AND. ND3->(ColumnPos('ND3_LOJA')) > 0 .AND. ND3->(ColumnPos('ND3_DTSAI')) > 0
						IF Posicione("SB5", 1, xFilial("SB5") + SD2->D2_COD, "B5_SEMENTE") == "1"
						GravarSISDEV(SD2->D2_COD, SD2->D2_LOTECTL, SD2->D2_QUANT, SD2->D2_DOC, SD2->D2_SERIE,;
						SD2->D2_EMISSAO, SD2->D2_DTDIGIT, SD2->D2_CLIENTE, SD2->D2_LOJA)
						ENDIF
					ENDIF
					ND3->(DbCloseArea())
				ENDIF

				dbSelectArea( "SD2" )
				SD2->( dbSkip() )
			EndDo

			for nx := 1 to len(aVlrTot) //atualização de valores totais

				dbSelectArea( "NJM" )
				NJM->( DbGoTo( aVlrTot[nx][1] ) )	//posiciona conforme recno

				If RecLock( "NJM", .F. )
					nVlrNJM := NJM->( NJM_VLRTOT )		//atualiza a NJR primeiro, revertendo a soma, corrigindo o valor informado ao atualizar o contrato

					//atualiza a NJM com o valor total e unitário
					NJM->( NJM_VLRUNI ) := aVlrTot[nx][2] / NJM->( NJM_QTDFIS )
					NJM->( NJM_VLRTOT ) := aVlrTot[nx][2]
					msUnLock("NJM")

					//atualiza os dados da NJJ
					OGX140AtNJJ( xFilial( "NJJ" ), NJM->( NJM_CODROM ) )

					dbSelectArea( "NJR" )
					NJR->( dbSetOrder( 1 ) )

					if NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) ) //atualiza a NJR com o novo valor da NJM
						RecLock( "NJR", .F. )
						NJR->( NJR_VLSFIS ) = (NJR->( NJR_VLSFIS ) - nVlrNJM) + NJM->( NJM_VLRTOT )
						If NJR->( NJR_TIPO ) = "3"
							NJR->( NJR_SLDTOT ) := NJR->( NJR_VLEFIS ) - NJR->( NJR_VLSFIS )
						endif
						msUnLock("NJR")
					endif

				endif

			end

			If !Empty(cCodCtr) .And. .Not. Empty( NJJ->NJJ_CHVNFE )

				RecLock( "SF2", .f. )
				SF2->( F2_CHVNFE ) := NJJ->( NJJ_CHVNFE )
				SF2->( msUnLock() )
			EndIf
		EndIf
		
	Else
		dbselectArea( "SD2" ) // Item da NF de Saída
		dbSetOrder( 3 )
		If dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
			While .Not. SD2->( Eof() ) ;
			.And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )

				dbSelectArea( "SC5" ) // Cabecalho do PV
				dbSetOrder( 1 )
				If dbSeek( xFilial( "SC5" ) + SD2->( D2_PEDIDO ) )

					dbSelectArea( "N8I" ) // Tab. de vinculo de itens do pv
					N8I-> ( dbSetOrder( 1 ))  //N8I_FILIAL+N8I_NUMPV+N8I_ITEMPV
					If dbSeek( xFilial( "N8I" ) + SD2->( D2_PEDIDO ) + SD2->( D2_ITEMPV ) )

						// Alterado para controlar pelo campo do contrato devido ao legado
						//carregado neste ponto para garantir que encontre vinculo com contrato - proteção para chamadas externas ao romaneio
						_lnewNeg    := !Empty(Posicione("NJR",1,xFilial("NJR")+N8I->N8I_CODCTR ,"NJR_CODNGC"))

						dbSelectArea( "NJJ" ) // Romaneio
						NJJ->( dbSetOrder(1) )
						If dbSeek( xFilial( "NJJ" ) + N8I->N8I_CODROM  )

							If SC5->C5_TIPO $ "N;B;D" //alterado para tratar pelo pedido se é ou não complemento.
								//If .Not. Empty( N8I->N8I_CODROM ) .and. Empty(N8I->N8I_CODFIX) // Indica que é uma nf. de romaneio ( Não é uma nf. de complemento )

								cCodRom				:= N8I->N8I_CODROM
								
								dbSelectArea( "NJM" ) // Item do romaneio
								dbSetOrder( 1 )
								If dbSeek( xFilial( "NJM" ) + N8I->N8I_CODROM + N8I->N8I_ITEROM )

									//guarda a informação do campo de GMO
									cGenMod := NJM->( NJM_GENMOD )
									// Atualiza o item do romaneio (NJM)
									RecLock( "NJM", .f. )
									NJM->( NJM_DOCSER ) := SF2->( F2_SERIE   )
									NJM->( NJM_DOCNUM ) := SF2->( F2_DOC     )
									NJM->( NJM_DOCEMI ) := SF2->( F2_EMISSAO )
									NJM->( NJM_DOCESP ) := SF2->( F2_ESPECIE )
									NJM->( NJM_CHVNFE ) := SF2->( F2_CHVNFE )
									NJM->( NJM_STAFIS ) := "2"
									NJM->( NJM_DTRANS ) := dDatabase
									msUnLock("NJM")

									If SD2->(FieldPos('D2_CTROG')) > 0
										// Vincula o Item da NF ao Romaneio
										RecLock( "SD2", .f. )
										SD2->( D2_CTROG ) 	:= N8I->N8I_CODCTR
										SD2->( D2_CODSAF ) 	:= N8I->N8I_SAFRA 
										SD2->( D2_CODROM ) 	:= N8I->N8I_CODROM
										SD2->( D2_ITEROM )	:= N8I->N8I_ITEROM
										msUnLock("SD2")
									Endif

									If NJJ->( NJJ_TIPO ) $ "6|8"
										//criar os totais
										nPos  := aScan(aVlrTot,{|x| x[1] == NJM->( Recno() )  })
										If nPos > 0
											aVlrTot[nPos][2] += SD2->( D2_TOTAL )
										else
											aadd (aVlrTot, {NJM->( Recno() ),  SD2->( D2_TOTAL )} )
										endif
									endif

									// Atualiza o registro de NJJ com o primeiro de NJM
									OGX140AtNJJ( xFilial( "NJJ" ), NJJ->( NJJ_CODROM ) )

									If NJM->( NJM_TIPO ) $ "4|5|8|9"
										If Empty(cCodCtr) .and. NJM->( NJM_TIPO ) = "4"
											cCodCtr := N8I->N8I_CODCTR
										EndiF

										SF4->( dbSetOrder( 1 ) )
										SF4->( dbSeek( xFilial( "SF4" ) + SD2->( D2_TES ) ) )
										If SF4->( F4_DUPLIC ) = "S"

											// Atualiza valores financeiros provisorios do contrato
											If _lnewNeg // Verifica se utiliza  modelo de contrato por negócio
												//Realiza baixa dos títulos de previsão e vínculo do contrato
												BaixaPrev(NJM->NJM_CODCTR, NJM->NJM_CODROM, NJM->NJM_ITEROM,;
												NJM->NJM_ITEM  , NJM->NJM_SEQPRI)

												//Realiza a baixo dos títulos gerados e amarrados ao contrato.
												BaixNFXRA(NJM->NJM_CODCTR, NJM->NJM_CODROM, NJM->NJM_ITEROM,;
												NJM->NJM_ITEM  , NJM->NJM_SEQPRI)
											Else
												OGA250ATUF(NJM->( NJM_CODCTR ), NJM->( NJM_QTDFIS ), IIF(NJM->( NJM_TIPO ) $ "4|5","2","1" ))
											EndIf

											cHist := Alltrim(Posicione("SX5",1,xFilial("SX5")+'K5' + NJM-> NJM_TIPO,"X5_DESCRI"))
											cOrigem := ''
											IF IsInCallStack('OGA250')
												cOrigem := 'OGA250'
											ElseIF IsInCallStack('OGA251')
												cOrigem := 'OGA251'
											EndIF
											aVncCRec := {}

											dbSelectArea( "SE1" ) // Titulo a Receber
											dbSetOrder( 2 )  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
											dbSeek( xFilial( "SE1" ) + SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) )
											While	.Not. SE1->( Eof() ) .And. SE1->( E1_FILIAL ) == xFilial( "SE1" );
											.And. SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ==  SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL )

												DbselectArea( 'N8L' )
												N8L->( dbSetOrder( 1 ) ) // N8L_FILIAL + N8L_PREFIX + N8L_PARCEL + N8L_NUM + N8L_TIPO
												IF .NOT. N8L->(DbSeek( FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))) .AND.;
												!('-' $ SE1->E1_TIPO) //Desconsiderar impostos na geração da N8L

													//Removento o vinculo da SE1
													aLinVncAux := {}
													aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('N8L') 				} )
													aadd( aLinVncAux, { "N8L_FILORI"    	, SE1->E1_FILORIG 				} )
													aadd( aLinVncAux, { "N8L_PREFIX"    	, SE1->E1_PREFIXO				} )
													aadd( aLinVncAux, { "N8L_NUM"    		, SE1->E1_NUM					} )
													aadd( aLinVncAux, { "N8L_PARCEL"    	, SE1->E1_PARCELA				} )
													aadd( aLinVncAux, { "N8L_TIPO"    		, SE1->E1_TIPO					} )
													aadd( aLinVncAux, { "N8L_CODCTR"    	, NJM->NJM_CODCTR				} )
													aadd( aLinVncAux, { "N8L_SAFRA"    		, NJM->NJM_CODSAF				} )
													aadd( aLinVncAux, { "N8L_CODROM"    	, NJM->NJM_CODROM				} )
													aadd( aLinVncAux, { "N8L_ITEROM"   		, NJM->NJM_ITEROM				} )
													aadd( aLinVncAux, { "N8L_CODFIX"   		,''								} )
													aadd( aLinVncAux, { "N8L_CODOTR"    	, ''							} )
													aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''							} )
													aadd( aLinVncAux, { "N8L_ORIGEM"    	, cOrigem						} )
													aAdd( aLinVncAux, { "N8L_HISTOR"    	, cHist							} )  //Previsão financeira, Contrato de vendas

													aAdd(aVncCRec, aLinvncAux)

													If	RecLock( "SE1", .f. )
														SE1->( E1_MOVIMEN ) 	:= dDatabase
														SE1->( MsUnlock() )
													EndIf
												EndIF

												SE1->( DbSkip() )
											EndDo
											IF  Len( aVncCRec ) > 0
												fAgrVncRec (aVncCRec, 3 )  	//Incluir
											EndIF

											If NJM->( NJM_TIPO ) $ "8" //qdo devolução de compra é gerada 
												SF1->( dbSetOrder(1) )
												SD1->( dbSetOrder(1) )    
												SE2->(dbSetOrder( 6 ))                                                                              
												If SF1->( dbSeek( xFilial("SF1") + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA  ) )                                                                                      
													If SD1->( dbSeek( xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
														If SE2->(dbSeek( xFilial( "SE2" ) + SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC ) ))
															While .Not. SE2->( Eof() ) .And. SE2->( E2_FILIAL ) == xFilial( "SE2" ) ;
															.And. SE2->( E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC )
																

																If GetRpoRelease() >= "12.1.023" //a partir do rpo 12.1.023 usa tabelas de extensão
																	cHist := Alltrim(Posicione("SX5",1,xFilial("SX5")+'K5' + NJM-> NJM_TIPO,"X5_DESCRI"))
																	cOrigem := ''
																	IF IsInCallStack('OGA250')
																		cOrigem := 'OGA250'
																	ElseIF IsInCallStack('OGA251')
																		cOrigem := 'OGA251'
																	EndIF
																	aVncCPag := {}

																	DbselectArea( 'N8M' )
																	N8M->( dbSetOrder( 1 ) )  //N8M_FILIAL+N8M_PREFIX+N8M_NUM+N8M_PARCEL+N8M_TIPO+N8M_FORNEC+N8M_LOJA 
																	IF .NOT. N8M->(DbSeek( FwXfilial('N8M') + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))  
																		aLinVncAux2 := {}

																		aadd( aLinVncAux2, { "N8M_FILIAL"    	, SE2->E2_FILIAL				} )
																		aadd( aLinVncAux2, { "N8M_FILORI"    	, SE2->E2_FILORIG				} )
																		aadd( aLinVncAux2, { "N8M_PREFIX"    	, SE2->E2_PREFIXO				} )
																		aadd( aLinVncAux2, { "N8M_NUM"    		, SE2->E2_NUM 					} )
																		aadd( aLinVncAux2, { "N8M_PARCEL"    	, SE2->E2_PARCELA				} )
																		aadd( aLinVncAux2, { "N8M_TIPO"    		, SE2->E2_TIPO					} )
																		aadd( aLinVncAux2, { "N8M_FORNEC"    	, SE2->E2_FORNECE				} )
																		aadd( aLinVncAux2, { "N8M_LOJA"    		, SE2->E2_LOJA					} )
																		aadd( aLinVncAux2, { "N8M_CODCTR"    	, SD1->D1_CTROG					} )
																		aadd( aLinVncAux2, { "N8M_CODSAF"	    , SD1->D1_CODSAF				} )
																		aadd( aLinVncAux2, { "N8M_CODROM"    	, SD1->D1_CODROM				} )
																		aadd( aLinVncAux2, { "N8M_ITEROM"   	, SD1->D1_ITEROM				} )
																		aadd( aLinVncAux2, { "N8M_ITEMFX"   	, ''							} )
																		aadd( aLinVncAux2, { "N8M_ORDTRA"    	, ''							} )
																		aadd( aLinVncAux2, { "N8M_ORPGRC"    	, ''							} )
																		aadd( aLinVncAux2, { "N8M_ITPGRC"    	, ''							} )
																		aadd( aLinVncAux2, { "N8M_CODNGC"   	, ''							} )
																		aadd( aLinVncAux2, { "N8M_VERNGC"   	, ''							} )
																		aadd( aLinVncAux2, { "N8M_ORIGEM"    	, cOrigem		 				} )
																		aAdd( aLinVncAux2, { "N8M_HISTOR"    	, cHist							} )

																		aAdd(aVncCPag,aLinVncAux2)

																	EndIF

																	RecLock( "SE2", .f. )
																	SE2->( E2_MOVIMEN )     := dDatabase

																	If SE2->(ColumnPos('E2_CTROG'))
																		SE2->( E2_CTROG )   := SD1->( D1_CTROG )
																	EndIf 

																	If SE2->(ColumnPos('E2_CODSAF'))
																		SE2->( E2_CODSAF )  := SD1->( D1_CODSAF )
																	EndIf 

																	SE2->( MsUnLock() )
																	SE2->( dbSkip() )

																else    
																	//rpo 12.1.0.17 e anteriores                             
																	RecLock( "SE2", .f. )
																	SE2->( E2_CODSAF )  := SD1->( D1_CODSAF )
																	SE2->( E2_CTROG )   := SD1->( D1_CTROG )
																	SE2->( E2_MOVIMEN ) := dDatabase
																	SE2->( MsUnLock() )

																	SE2->( dbSkip() )
																endIf
															EndDo

															IF  Len( aVncCPag ) > 0
																fAgrVncPag (aVncCPag, 3 )  	//Incluir
															EndIF
														EndIf
													EndIf
												Endif
											EndIf
										EndIf
									EndIf

									If NJM->( NJM_TIPO ) = "6" .and. NJM->NJM_TRSERV $ '1|2'   // retorno depósito terceiros e transfere serviços

										dbSelectArea( "SD1" )  // ITENS DA NOTA DE ENTRADA ORIGINAL
										dbSetOrder( 1 )
										dbSeek( xFilial( "SD1" ) + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_ITEMORI)
										While ! SD1->( Eof() ) ;
										.And. SD1->D1_FILIAL  = xFilial('SD1') ;
										.And. SD1->D1_DOC     = SD2->D2_NFORI  ;
										.And. SD1->D1_SERIE   = SD2->D2_SERIORI;
										.And. SD1->D1_FORNECE = SD2->D2_CLIENTE;
										.And. SD1->D1_LOJA    = SD2->D2_LOJA   ;
										.And. SD1->D1_COD     = SD2->D2_COD    ;
										.And. SD1->D1_ITEM    = SD2->D2_ITEMORI

											dbSelectArea('NKG')
											dbSetOrder(2)
											dbSeek( xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM ) )
											While ! NKG->( Eof() );
											.And. NKG->( NKG_FILIAL + NKG_CODROM + NKG_ITEROM ) == xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM )

												If Empty(NKG->NKG_FECSER) .Or. NKG->NKG_FECSER = ''

													AGRDELEREG('NKG',(cAliasQuery)->NKG_CODCTR+(cAliasQuery)->NKG_ITEMOV,1,.f.)

												Endif

												NKG->( DbSkip() )
											EndDo

											SD1->( DbSkip() )
										EndDo
									Endif
								EndIf

							Else //pedido de complemento
								//ElseIf .Not. Empty( N8I->N8I_CODROM ) .and. .not. Empty(N8I->N8I_CODFIX) // Indica que veio da geração de complemento...
								//Está tratando impactos no legado e o novo negócio.

								cHist       := N8I->N8I_HISTOR //busca da N8I o texto
								cOrigem     := N8I->N8I_ORIGEM //busca da N8I a origem
								aVncCRec :={}

								dbSelectArea( "SE1" ) // Titulo a Receber
								dbSetOrder( 2 )  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
								dbSeek( xFilial( "SE1" ) + SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) )
								While	.Not. SE1->( Eof() ) .And. SE1->( E1_FILIAL ) == xFilial( "SE1" );
								.And. SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ==  SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL )

									DbselectArea( 'N8L' )
									N8L->( dbSetOrder( 1 ) ) // N8L_FILIAL + N8L_PREFIX + N8L_PARCEL + N8L_NUM + N8L_TIPO
									IF .NOT. N8L->(DbSeek( FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))) .AND.;
									!('-' $ SE1->E1_TIPO) //Desconsiderar impostos na geração da N8L

										//vinculando o contas a receber.
										aLinVncAux := {}
										aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('N8L') 				} )
										aadd( aLinVncAux, { "N8L_FILORI"    	, SE1->E1_FILORIG				} )
										aadd( aLinVncAux, { "N8L_PREFIX"    	, SE1->E1_PREFIXO				} )
										aadd( aLinVncAux, { "N8L_NUM"    		, SE1->E1_NUM					} )
										aadd( aLinVncAux, { "N8L_PARCEL"    	, SE1->E1_PARCELA				} )
										aadd( aLinVncAux, { "N8L_TIPO"    		, SE1->E1_TIPO					} )
										aadd( aLinVncAux, { "N8L_CODCTR"    	, N8I->N8I_CODCTR				} )
										aadd( aLinVncAux, { "N8L_SAFRA"    		, N8I->N8I_SAFRA				} )
										aadd( aLinVncAux, { "N8L_CODROM"    	, N8I->N8I_CODROM				} )
										aadd( aLinVncAux, { "N8L_ITEROM"   		, N8I->N8I_ITEROM				} )
										aadd( aLinVncAux, { "N8L_CODFIX"   		, N8I->N8I_CODFIX				} )
										aadd( aLinVncAux, { "N8L_CODOTR"    	, ''							} )
										aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''							} )
										aadd( aLinVncAux, { "N8L_ORIGEM"    	, cOrigem						} )
										aAdd( aLinVncAux, { "N8L_HISTOR"    	, cHist							} )  //Previsão financeira, Contrato de vendas

										aAdd(aVncCRec, aLinvncAux)
									EndIF

									SE1->( DbSkip() )
								EndDo
								IF  Len( aVncCRec ) > 0
									fAgrVncRec (aVncCRec, 3 )  	//Incluir
								EndIF

								NJM->(dbSetOrder( 1 ))
								If NJM->(dbSeek( xFilial( "NJM" ) + N8I->( N8I_CODROM ) + N8I->( N8I_ITEROM ) ))
									// Atualiza o item do romaneio (NJM)
									RecLock( "NJM", .f. )									
									NJM->( NJM_STAFIS ) := "2"
									NJM->( NJM_DTRANS ) := dDatabase
									NJM->(MsUnLock("NJM"))
								EndIf
							Endif
						EndIf

						//Array de vinculo do Agro com os Itens do doc. Saida
						IF Len(aVincCabNF) > 0
							nPosCpo:= ASCAN(aVincCabNF, {|aVincCabNF| aVincCabNF[1] ==  'N8J_DOC' })

							IF ! Alltrim ( aVincCabNF[nPosCpo][2] ) ==  Alltrim(SD2->D2_DOC)
								lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  		//Incluir
								aVincCabNF := {}
								aVincIteNF := {}
							EndIF

						EndIF

						aLinha := {}
						aadd( aLinha, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
						aadd( aLinha, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
						aadd( aLinha, { "N8K_SERIE"    	, SD2->D2_SERIE		} )
						aadd( aLinha, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} )
						aadd( aLinha, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
						aadd( aLinha, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
						aadd( aLinha, { "N8K_PRODUT"    , SD2->D2_COD 		} )
						aadd( aLinha, { "N8K_TPPROD"    , N8I->N8I_TPPROD	} )
						aadd( aLinha, { "N8K_CODCTR"    , N8I->N8I_CODCTR	} )
						aadd( aLinha, { "N8K_SAFRA"    	, N8I->N8I_SAFRA 	} )
						aadd( aLinha, { "N8K_CODROM"   	, N8I->N8I_CODROM   } )
						aadd( aLinha, { "N8K_ITEROM"   	, N8I->N8I_ITEROM	} )
						aadd( aLinha, { "N8K_CODFIX"    , N8I->N8I_CODFIX 	} )
						aadd( aLinha, { "N8K_CODOTR"    , N8I->N8I_CODOTR	} )
						aadd( aLinha, { "N8K_ITEOTR"    , N8I->N8I_ITEOTR 	} )
						aadd( aLinha, { "N8K_ORPGRC"    , N8I->N8I_ORPGRC 	} )
						aadd( aLinha, { "N8K_FECSER"    , N8I->N8I_FECSER	} )
						aadd( aLinha, { "N8K_ORIGEM"    , N8I->N8I_ORIGEM	} )
						aadd( aLinha, { "N8K_HISTOR"    , N8I->N8I_HISTOR	} )

						//Dados do Aviso PEPRO
						aadd( aLinha, { "N8K_NUMAVI"    , N8I->N8I_NUMAVI	} )
						aadd( aLinha, { "N8K_NUMDCO"    , N8I->N8I_NUMDCO	} )
						aadd( aLinha, { "N8K_SEQDCO"    , N8I->N8I_SEQDCO	} )
						aadd( aLinha, { "N8K_TPAVIS"    , N8I->N8I_TPAVIS	} )
						aadd( aLinha, { "N8K_OBSERV"    , N8I->N8I_OBSERV	} )

						//Informação GMO
						If !Empty(cGenMod)
							aadd( aLinha, { "N8K_GENMOD", cGenMod		} )
						EndIf

						aAdd( aVincIteNF, aLinha )

						//Array de vinculo do Agro com o doc. Sada

						IF Len (aVincCabNF) == 0
							aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8J')	} )
							aadd( aVincCabNF, { "N8J_DOC"		, SF2->F2_DOC		} )
							aadd( aVincCabNF, { "N8J_SERIE"		, SF2->F2_SERIE		} )
							aadd( aVincCabNF, { "N8J_CLIFOR"    , SF2->F2_CLIENTE	} )
							aadd( aVincCabNF, { "N8J_LOJA"    	, SF2->F2_LOJA		} )
							aadd( aVincCabNF, { "N8J_TPDOC"    	, SF2->F2_TIPO   	} )
							aadd( aVincCabNF, { "N8J_CODCTR"    , N8I->N8I_CODCTR	} )
							aadd( aVincCabNF, { "N8J_CODROM"    , N8I->N8I_CODROM	} )
							aadd( aVincCabNF, { "N8J_CODFIX"    , N8I->N8I_CODFIX	} )
							aadd( aVincCabNF, { "N8J_CODROM"   	, N8I->N8I_CODROM   } )
							aadd( aVincCabNF, { "N8J_CODOTR"   	, N8I->N8I_ITEROM	} )
							aadd( aVincCabNF, { "N8J_CODFIX"	, N8I->N8I_CODFIX 	} )
							aadd( aVincCabNF, { "N8J_CODOTR"	, N8I->N8I_CODOTR	} )
							aadd( aVincCabNF, { "N8J_ORPGRC"	, N8I->N8I_ORPGRC 	} )
							aadd( aVincCabNF, { "N8J_FECSER"	, N8I->N8I_FECSER	} )
							aadd( aVincCabNF, { "N8J_ORIGEM"	, N8I->N8I_ORIGEM	} )
							aadd( aVincCabNF, { "N8J_HISTOR"	, N8I->N8I_HISTOR	} )
						EndIf
					Endif
				EndIf

				//Coletar dados de expedição de sementes/mudas a serem transmitidas ao SISDEV
				IF AliasIndic("ND3") .AND. lSISDEV
					DbSelectArea('ND3')
					IF ND3->(ColumnPos('ND3_CODPRO')) > 0 .AND. ND3->(ColumnPos('ND3_CLIENT')) > 0 .AND. ND3->(ColumnPos('ND3_LOJA')) > 0 .AND. ND3->(ColumnPos('ND3_DTSAI')) > 0
						IF Posicione("SB5", 1, xFilial("SB5") + SD2->D2_COD, "B5_SEMENTE") == "1"
							cSaf = Posicione ("SC5", 1, xFilial("SC5") + SD2->D2_PEDIDO, "C5_CODSAF")
							GravarSISDEV(SD2->D2_COD, SD2->D2_LOTECTL, SD2->D2_QUANT, SD2->D2_DOC, SD2->D2_SERIE,;
							SD2->D2_EMISSAO, SD2->D2_DTDIGIT, SD2->D2_CLIENTE, SD2->D2_LOJA, cSaf)
						ENDIF
					ENDIF
					ND3->(DbCloseArea())
				ENDIF

				dbSelectArea( "SD2" )
				SD2->( dbSkip() )

				IF SD2->( Eof() ) .Or. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) <> xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
					IF Len (aVincCabNF) > 0
						lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  	//Incluir
					EndIF

				EndIF



			EndDo

			for nx := 1 to len(aVlrTot) //atualização de valores totais

				dbSelectArea( "NJM" )
				NJM->( DbGoTo( aVlrTot[nx][1] ) )	//posiciona conforme recno

				If RecLock( "NJM", .F. )
					nVlrNJM := NJM->( NJM_VLRTOT )		//atualiza a NJR primeiro, revertendo a soma, corrigindo o valor informado ao atualizar o contrato

					//atualiza a NJM com o valor total e unitário
					NJM->( NJM_VLRUNI ) := aVlrTot[nx][2] / NJM->( NJM_QTDFIS )
					NJM->( NJM_VLRTOT ) := aVlrTot[nx][2]
					msUnLock("NJM")

					//atualiza os dados da NJJ
					OGX140AtNJJ( xFilial( "NJJ" ), NJM->( NJM_CODROM ) )

					dbSelectArea( "NJR" )
					NJR->( dbSetOrder( 1 ) )

					if NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) ) //atualiza a NJR com o novo valor da NJM
						RecLock( "NJR", .F. )
						NJR->( NJR_VLSFIS ) = (NJR->( NJR_VLSFIS ) - nVlrNJM) + NJM->( NJM_VLRTOT )
						If NJR->( NJR_TIPO ) = "3"
							NJR->( NJR_SLDTOT ) := NJR->( NJR_VLEFIS ) - NJR->( NJR_VLSFIS )
						endif
						msUnLock("NJR")
					endif

				endif

			end

			If !Empty(cCodCtr) .And. .Not. Empty( NJJ->NJJ_CHVNFE )

				RecLock( "SF2", .f. )
				SF2->( F2_CHVNFE ) := NJJ->( NJJ_CHVNFE )
				SF2->( msUnLock() )
			EndIf
		EndIf

	EndIf
	
	ftroca()

	RestArea( aAreaSE1 )
	RestArea( aAreaADA )
	RestArea( aAreaNJR )
	RestArea( aAreaNJJ )
	RestArea( aAreaSC5 )
	RestArea( aAreaSC6 )
	RestArea( aAreaSD2 )
	RestArea( aAreaAtu )

Return( Nil )


//--<< Grava o contrato de Compra na Se1 >>--

/** {Protheus.doc} fTroca
Definido por Vanilda
Rotina ref. ao processo de troca , verifica se a Nf Refere-se a UM PV , de contrato de parceria, e se o contrato
de parceria possui um relacionamento de troca.

@param: 	Nil
@return:	Nil
@author: 	Emerson Coelho
@since: 	08/06/2010
@Uso: 		SIGAAGR - Agro Industria
*/

Static Function FTroca()

	Local aAreaAtu 	:= GetArea()
	Local aAreaSC6 	:= SC6->( GetArea() )
	Local aAreaSD2 	:= SD2->( GetArea() )
	Local aAreaADA 	:= ADA->( GetArea() )
	Local aAreaSE1 	:= SE1->( GetArea() )

	//É imprescIndivel que em acordos de troca n. se tenha dois contratos, na mesma nf, isso ja foi tratado no AGRA900

	dbSelectArea( "SD2" )
	SD2->( dbSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	IF SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))

		dbSelectArea( "SC6" )
		SC6->( dbSetOrder( 1 ) ) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If dbSeek( xFilial( "SC6" ) + SD2->( D2_PEDIDO+ D2_ITEMPV ) )

			dbSelectArea( "ADA" )
			ADA->( dbSetOrder( 1 ) ) //ADA_FILIAL+ADA_NUMCTR

			If dbSeek( xFilial( "ADA" ) + SC6->C6_CONTRAT )
				nTxaMoeda := 0
				cNktTrcNum := ''
				IF ADA->(FieldPos('ADA_TRCNUM')) >0
					cNktTrcNum:= Posicione("ADA", 1, xFilial("ADA")+SC6->C6_CONTRAT, "ADA_TRCNUM")

					dbSelectArea( "NKT" ) //--Tab. Acordo de Trocas --//
					NKT->( dbSetOrder( 1 ) )
					IF NKT->( dbSeek( xFilial( "NKT" ) + cNktTrcNum ) )
						nTxaMoeda	:= NKT->NKT_VRPAUT
					EndIF

				EndIF

				SE1->(dbSetOrder(2)) 	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL)))

				While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") ;
				.And. SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL)
					IF nTxaMoeda > 0
						RecLock("SE1",.F.)
						SE1->E1_TXMOEDA := nTxaMoeda
						SE1->(MsUnLock())
					EndIF
					SE1->(dbSkip())
				EndDo
			EndIF
		EndIF
	EndIf

	RestArea( aAreaSE1 )
	RestArea( aAreaADA )
	RestArea( aAreaSD2 )
	RestArea( aAreaSC6 )
	RestArea( aAreaAtu )

Return( Nil )

/*{Protheus.doc} BaixaPrev
//Relaciona a NF à previsão e faz a baixa do valor dela na SE1
@author Marcos Wagner / Marcelo Ferrari
@since 11/05/2018
@version 1
@param cCodCtr, characters, Observação do contato
@param cCodRom, characters, Codigo do Romaneio
@param cItemRom,characters, Item do Romaneio
@param cItemPe, characters, Item da Previsão de Entrega
@param cSeqPri, characters, Sequencia Regra Fiscal
@type function
*/
Static Function BaixaPrev(cCodCtr, cCodRom, cItemRom, cItemPe, cSeqPri)
	Local aAreaN9K   := N9K->(GetArea())
	Local aAreaSE1   := SE1->(GetArea())
	Local aAreaN8L   := N8L->(GetArea())
	Local aPrvVincul := {}
	Local nQtdTotal  := 0
	Local nCountVinc := 0
	Local nValorUnit := 0
	Local nValorTotal:= 0
	Local nCountReg  := 1
	Local nPos       := 0
	Local nDifComp   := 0
	Local aCpoAtu    := {}
	Local cTipoEvto  := ""

	dbSelectArea("SE1") // Titulo a Receber
	dbSetOrder(2)
	dbGoTop() //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL))

		While SE1->(!EOF())

			//faz um dbskip devido nao ter a chave completa e qprecisar apenas do titulo NF
			If SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL) == SE1->(E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM)
				//controla o loop para caso ter mais de uma parcela

				If AllTrim(SE1->E1_TIPO) == "NF"

					//reseta variaveis de count
					aPrvVincul := {}
					nQtdTotal    := 0
					nCountVinc   := 0
					nValorUnit   := 0
					nValorTotal  := SE1->E1_SALDO - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)  // salvamos o valor total do título para irmos montando a sequencia de uso do mesmo
					nCountReg    := 1
					nPos         := 0

					// buscamos todos os itens da N9K com a data do título
					dbSelectArea("N9K")
					dbSetOrder(2) //N9K_FILIAL+N9K_CODROM+N9K_ITEROM+N9K_DTVENC
					dbGoTop()

					If dbSeek(FwxFilial("N9K")+cCodRom+cItemRom+DTOS(SE1->E1_VENCTO))
						//busca todos os registros com aquele vencimento na tabela
						While N9K->(!EOF()) .and. N9K->(N9K_FILIAL+N9K_CODROM+N9K_ITEROM+DTOS(N9K_DTVENC)) == FwxFilial("N9K")+cCodRom+cItemRom+DTOS(SE1->E1_VENCTO)
							//verifica a quantidade de itens para montar o valor proporcional
							nQtdTotal  += N9K->N9K_QTDVNC
							nCountVinc += 1
							N9K->(dbSkip())
						enddo
					EndIf

					//valor para tratar quebra de valor
					nValorUnit := round(nValorTotal / nQtdTotal, TAMSX3("E1_VALOR")[2])

					dbSetOrder(2) //N9K_FILIAL+N9K_CODROM+N9K_ITEROM+N9K_DTVENC
					dbGoTop()

					If dbSeek(FwxFilial("N9K")+cCodRom+cItemRom+DTOS(SE1->E1_VENCTO))
						While N9K->(!EOF()) .and. N9K->(N9K_FILIAL+N9K_CODROM+N9K_ITEROM+DTOS(N9K_DTVENC)) == FwxFilial("N9K")+cCodRom+cItemRom+DTOS(SE1->E1_VENCTO)

							cParcelaNN7 := Posicione('NN7',1,N9K->N9K_FILORI+N9K->N9K_CODCTR+N9K->N9K_SEQPF,"NN7_PARCEL")
							cTipoEvto	:= Posicione('NN7',1,N9K->N9K_FILORI+N9K->N9K_CODCTR+N9K->N9K_SEQPF,"NN7_TIPEVE")

							// guardamos o valor do título e a numeracao do mesmo
							RecLock("N9K",.f.)
							N9K->N9K_FILTIT := SE1->E1_FILORIG
							N9K->N9K_PREFIX := SE1->E1_PREFIXO
							N9K->N9K_NUM    := SE1->E1_NUM
							N9K->N9K_PARCEL := SE1->E1_PARCELA
							N9K->N9K_TIPO   := SE1->E1_TIPO

							If nCountVinc == nCountReg
								N9K->N9K_VALOR := nValorTotal
							Else
								N9K->N9K_VALOR  := nValorUnit * N9K->N9K_QTDVNC
								nValorTotal     -= N9K->N9K_VALOR //proporcional
							EndIf

							If cTipoEvto == "1"
								aCpoAtu := { {"NN7_VLTNCO", N9K->N9K_VALOR, "SOMA"}, {"NN7_VLTEMI", N9K->N9K_VALOR, "SOMA"} }
							Else
								aCpoAtu := { {"NN7_VLTNCO", N9K->N9K_VALOR, "SOMA"}, {"NN7_VLTEMI", N9K->N9K_VALOR, "SOMA"} }
							EndIf

							OGX018ASLD(N9K->N9K_FILORI, N9K->N9K_CODCTR, N9K->N9K_SEQPF, cParcelaNN7, aCpoAtu)

							//agrupa por previsão financeira
							if len(aPrvVincul) > 0 .and. (nPos := aScan(aPrvVincul, { |x| Alltrim(x[1]) == alltrim(SE1->E1_FILORIG + 'CTR' + PADR(N9K->N9K_CODCTR, TAMSX3("E1_NUM")[1], " " ) + cParcelaNN7 + "PR") }))
								aPrvVincul[nPos][2] += N9K->N9K_VALOR
							else
								aAdd(aPrvVincul,{SE1->E1_FILIAL + 'CTR' + PADR(N9K->N9K_CODCTR, TAMSX3("E1_NUM")[1], " " ) + cParcelaNN7 + "PR", N9K->N9K_VALOR , N9K->N9K_SEQPF })
							endif

							N9K->(MsUnlock())

							nCountReg += 1

							N9K->(dbSkip())
						enddo
					EndIf

					//lista as previsões para baixar
					for nCountReg = 1 to len(aPrvVincul)
						if aPrvVincul[nCountReg][2] > 0 //tem que baixar algum valor

							dbSelectArea("NN7")
							dbSetOrder(1)
							If dbSeek(xFilial("NN7")+cCodCtr+aPrvVincul[nCountReg][3]) //utiliza a sequencia da previsão
								If NN7->NN7_TIPEVE != '1'
									If RecLock("NN7", .F.)
										//tratando a baixa realizada na vinculação da PRXRA
										If NN7->NN7_VLCOMP > 0
											//Se tem valor compensado na vinculação apenas desconta o valor, não atualiza a PR pois nao muda nada
											//se o valor compensado é maior que o valor da NF desconta o total, caso contrário faz parcial
											If NN7->NN7_VLCOMP >= aPrvVincul[nCountReg][2]
												NN7->NN7_VLCOMP -= aPrvVincul[nCountReg][2]
											Else
												nDifComp := aPrvVincul[nCountReg][2] - NN7->NN7_VLCOMP
												NN7->NN7_VLCOMP  := 0 //zera o saldo de compensação
												NN7->NN7_VLSALDO -= nDifComp // desconta a diferença no saldo e muda a flag para ajustar a SE1
												NN7->NN7_STSTIT  := "2"
											EndIf
										Else
											NN7->NN7_VLSALDO -= aPrvVincul[nCountReg][2] //tira o saldo
											NN7->NN7_STSTIT  := "2" //atualiza para realizar a correção
										EndIf

										NN7->(MsUnlock())
									EndIf
								EndIf
							EndIf

						EndIf

					next nCountReg

				EndIf

				SE1->(dbSkip())
			Else
				Exit //sai fora do loop
			EndIf
		EndDo

		//chama a função que varre a NN7 toda e reajusta os titulos provisórios
		OGX018ATPR(FWxfilial("NJR"), cCodCtr, "OGX155")

	EndIf

	RestArea( aAreaN9K )
	RestArea( aAreaSE1 )
	RestArea( aAreaN8L )

Return .t.

/*{Protheus.doc} BaixNFXRA
//Relaciona a NF à previsão e faz a baixa do valor dela na SE1
@author filipe.olegini
@since 18/05/2018
@version 1
@param cCodCtr, characters, Código do contato
@param cCodRom, characters, Codigo do Romaneio
@param cItemRom,characters, Item do Romaneio
@param cItemPe, characters, Item da Previsão de Entrega
@param cSeqPri, characters, Sequencia Regra Fiscal
@type function
*/
Static Function BaixNFXRA(cCodCtr, cCodRom, cItemRom, cItemPe, cSeqPri)
	Local aAreaN9G  := N9G->(GetArea())
	Local aAreaSE1  := SE1->(GetArea())
	Local cAliasRA  := GetNextAlias()
	Local aBaixaNF  := {}
	Local aBaisaRA  := {}
	Local nValorBx  := 0
	Local nAbatim   := 0
	Local cQuery    := ""
	Local lRet      := .F.
	Local cFunName	:= FunName()
	Local cDbType   := TCGetDB()
	Local aSldNN7   := {}
	Local nValNF    := 0
	Local nSaldoRA  := 0
	Local nVlrComp  := 0

	dbSelectArea("SE1") // posiciona no titulo emitido pelo romaneio
	dbSetOrder(2)
	dbGoTop() //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL))

		While SE1->(!EOF())
			//faz um dbskip devido nao ter a chave completa e qprecisar apenas do titulo NF
			If SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL) == SE1->(E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM)
				//controla o loop para caso da NF possuir mais de uma parcela
				If AllTrim(SE1->E1_TIPO) == "NF"
					lRet     := .F.
					aBaixaNF := {SE1->(Recno())}
					nAbatim  := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
					nValorBx := SE1->E1_SALDO - nAbatim      //Valor a ser baixado, sempre utilizar o saldo devido baixas parciais e os abatimentos
					nValNF   := SE1->E1_VALOR

					//busca a RA vinculada a NF emitida através da N9G
					cQuery := " SELECT DISTINCT SE1.E1_FILORIG, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.R_E_C_N_O_ AS RECNO, SE1.E1_SALDO, "
					cQuery += " N9K.N9K_SEQPF "
					cQuery += "  FROM " + RetSqlname("SE1") + " SE1 "
					cQuery += "  INNER JOIN " + RetSqlname("N9G") + " N9G ON (N9G.N9G_FILIAL = '" + FwxFilial("N9G") + "' AND "
					cQuery +=                           "  N9G.N9G_FILTIT = SE1.E1_FILORIG  AND "
					cQuery +=                           "  N9G.N9G_PREFIX = SE1.E1_PREFIXO AND "
					cQuery +=                           "  N9G.N9G_NUM    = SE1.E1_NUM     AND "
					cQuery +=                           "  N9G.N9G_PARTT  = SE1.E1_PARCELA AND "
					cQuery +=                           "  N9G.N9G_TIPO   = SE1.E1_TIPO    AND "
					cQuery +=                           "  N9G.D_E_L_E_T_ = SE1.D_E_L_E_T_ ) "
					cQuery += "  INNER JOIN " + RetSqlname("N9K") + " N9K ON (N9K.N9K_FILIAL = '" + FwxFilial("N9K") + "' AND "
					cQuery +=                           "  N9K.N9K_CODCTR = N9G.N9G_CODCTR AND "
					cQuery +=                           "  N9K.N9K_SEQPF  = N9G_ITEMPV     AND "
					cQuery +=                           "  N9K.D_E_L_E_T_ = N9G.D_E_L_E_T_) "
					cQuery += "INNER JOIN " + RetSqlName("SA1") + " A1NF ON "
					cQuery += 		   		" A1NF.A1_COD    = SE1.E1_CLIENTE AND  "
					cQuery +=              	"A1NF.A1_LOJA   = SE1.E1_LOJA AND "
					cQuery +=              	"A1NF.D_E_L_E_T_ = SE1.D_E_L_E_T_  "
					cQuery += "INNER JOIN " + RetSqlName("SA1") + " A1RA ON "
					cQuery += 		   		" A1RA.A1_FILIAL = A1NF.A1_FILIAL AND  "
					If cDbType $ "MSSQL|MSSQL7|POSTGRES"
						cQuery +=              	"SUBSTRING(A1RA.A1_CGC,1,8) = SUBSTRING(A1NF.A1_CGC,1,8)  AND "
					ElseIf cDbType $ "ORACLE|DB2|INFORMIX"
						cQuery +=              	"SUBSTRING(A1RA.A1_CGC,1,8) = SUBSTRING(A1NF.A1_CGC,1,8)  AND "
					Endif
					cQuery +=              	" A1RA.D_E_L_E_T_ = SE1.D_E_L_E_T_ "
					cQuery += "  WHERE SE1.D_E_L_E_T_ = '' "
					cQuery +=   "  AND SE1.E1_FILIAL  = '" + FwxFilial("SE1") + "'"
					cQuery +=   "  AND SE1.E1_CLIENTE = '" + SE1->E1_CLIENTE + "'"
					cQuery +=   "  AND N9K.N9K_CODCTR = '" + cCodCtr + "'"
					cQuery +=   "  AND N9K.N9K_CODROM = '" + cCodRom + "'"
					cQuery +=   "  AND N9K.N9K_ITEROM = '" + cItemRom + "'"
					cQuery +=   "  AND N9K.N9K_FILORI = '" + FwxFilial("NJR") + "'" //filial do contrato
					cQuery +=   "  AND N9K.N9K_FILTIT = '" + SE1->E1_FILORIG + "'"
					cQuery +=   "  AND N9K.N9K_PREFIX = '" + SE1->E1_PREFIXO + "'"
					cQuery +=   "  AND N9K.N9K_NUM    = '" + SE1->E1_NUM + "'"
					cQuery +=   "  AND N9K.N9K_PARCEL = '" + SE1->E1_PARCELA + "'"
					cQuery +=   "  AND N9K.N9K_TIPO   = '" + SE1->E1_TIPO + "'"
					cQuery +=   "  AND E1_SALDO > 0 "

					cQuery := ChangeQuery( cQuery )

					If Select(cAliasRA) <> 0
						(cAliasRA)->(dbCloseArea())
					EndIf

					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasRA,.T.,.T.)

					//somente se existir vinculo ele baixa, neste ponto ele nao permite vinculo parcial.
					While (cAliasRA)->(!EOF()) .and. nValorBx > 0
						aSldNN7  := {}

						nSomaRA := OGX120RACP((cAliasRA)->E1_FILORIG, cCodCtr,  (cAliasRA)->E1_NUM, (cAliasRA)->E1_PARCELA, (cAliasRA)->E1_PREFIXO, (cAliasRA)->E1_TIPO)
						nVincRA := OGX120RAVC((cAliasRA)->E1_FILORIG, cCodCtr,  (cAliasRA)->E1_NUM, (cAliasRA)->E1_PARCELA, (cAliasRA)->E1_PREFIXO, (cAliasRA)->E1_TIPO, (cAliasRA)->N9K_SEQPF)

						nSaldoRA := nVincRA - nSomaRA
						If nSaldoRA > 0
							If nSaldoRA > nValorBx
								nVlrComp := nValorBx
							Else
								nVlrComp := nSaldoRA
								nValorBx -= nVlrComp
							EndIf

							//ajuste para execução da baixa das NFS X RA
							OGX155PERG()

							aBaisaRA := {(cAliasRA)->RECNO}

							SetFunName("MATA410") //força o nome de outra função para baixar os titulos de abatimentos
							lRet := MaIntBxCR(3, aBaixaNF, ,aBaisaRA, ,{.F.,.F.,.F.,.F.,.F.,.F.}, , , , , nVlrComp, , , , , ,.T.)
							SetFunName(cFunName)

							If lRet
								//se retornou OK na baixa realiza o vinculo na tabela N9M
								RecLock("N9M",.T.)
								N9M->N9M_FILIAL := FwxFilial("N9M")
								N9M->N9M_CODCTR := cCodCtr
								N9M->N9M_CODROM := cCodRom
								N9M->N9M_ITEROM := cItemRom
								N9M->N9M_FILTIT := SE1->E1_FILORIG
								N9M->N9M_PREFIX := SE1->E1_PREFIXO
								N9M->N9M_NUM    := SE1->E1_NUM
								N9M->N9M_PARCEL := SE1->E1_PARCELA
								N9M->N9M_TIPO   := SE1->E1_TIPO
								N9M->N9M_FILTIC := (cAliasRA)->E1_FILORIG
								N9M->N9M_PREFIC := (cAliasRA)->E1_PREFIXO
								N9M->N9M_NUMC   := (cAliasRA)->E1_NUM
								N9M->N9M_PARCEC := (cAliasRA)->E1_PARCELA
								N9M->N9M_TIPOC  := (cAliasRA)->E1_TIPO
								N9M->N9M_VALCOM := nVlrComp
								N9M->(MsUnlock())

								aAdd(aSldNN7,  {"NN7_VLTNCO", nVlrComp, "SUBT"} )

								/* ATUALIZA NN7 TOTAL TÍTULOS NÃO COMPENSADOS e NN7_SLDRA SALDO RA */
								OGX018ASLD(FwxFilial("NN7"), cCodCtr, (cAliasRA)->N9K_SEQPF, "", aSldNN7)
							Else
								Help('',1, "OGX155BBXCP") //Problema ao realizar a compensação do titulo. ### Realize a compensação pelo Painel Financeiro.
							EndIf
						EndIf
						(cAliasRA)->(dbSkip())
					EndDo
				Endif
				SE1->(dbSkip())
			Else
				Exit //sai fora do loop
			EndIf
		EndDo

		(cAliasRA)->(dbCloseArea())
	EndIf

	RestArea( aAreaN9G )
	RestArea( aAreaSE1 )

Return .T.

/*{Protheus.doc} OGX155PERG
//Apenas realiza a chamada do Pergunte, devido a inconsistências no Sonar
//Foi colocado em função para não avaliar todo o fonte do MATA
@author marcos.wagner
@since 05/12/2018
@version 1
@type function
*/
Static Function OGX155PERG()

	PERGUNTE("FIN330",.F.)

Return .t.

/*/{Protheus.doc} GravarSISDEV
//Função para coletar dados de expedição de sementes/mudas a serem transmitidas ao SISDEV (UBSA010)
@author luiz.dias
@since 29/10/2019
@version 1.0
@type function
/*/
Static Function GravarSISDEV(cProduto, cLote, cQuant, cDoc, cSerie, cDTEmissao, cDTSaida, cCliente, cLoja, cSafra)
	Local aAreaAtu  	:= GetArea()
	Local cRenasem		:= ""	
	Local cCtvar		:= ""
	Local cCpfCnpj		:= ""
	Local cNomeCli		:= ""	
	Local cCodMun		:= ""
	Local lProd			:= .F.
	Local cCtSemente	:= ""
	Local cDarFase		:= ""
	Local cDarIndea		:= ""
	Local cCodSafra 	:= ""
	
	NP9->(DbSetOrder( 5 ))
	If NP9->(DbSeek( FWxFilial('NP9') + cDoc + cSerie + cCliente + cLoja + cProduto ))
		If NP9->NP9_LOTE == cLote
		cRenasem := NP9->(NP9_RENASE)
		EndIF	
	Else 	
		NP9->(DbSetOrder( 1 ))
		If NP9->(DbSeek( FWxFilial('NP9') + cSafra + cProduto + cLote ))
			If NP9->NP9_LOTE == cLote
				lProd := NP9->NP9_TIPLOT = "1"
				cRenasem := NP9->(NP9_RENASE)
				If lProd
					If NP9->(ColumnPos( 'NP9_DFASE' )) > 0   
						cDarFase	:= NP9->(NP9_DFASE)
					EndIf
					If NP9->(ColumnPos( 'NP9_DINDEA' )) > 0
						cDarIndea	:= NP9->(NP9_DINDEA)
					EndIF
				EndIF
			EndIF
		EndIF
	EndIF	 
	
	SA1->(DbSetOrder( 1 ))
	If SA1->(DbSeek( FWxFilial('SA1') + cCliente + cLoja ))	
		/*---------------------------------------//
		// Captura nome e CPF ou CNPJ do Cliente //
		//---------------------------------------*/
		cCpfCnpj	:= SA1->(A1_CGC)
		cNomeCli	:= SA1->(A1_NOME)	
		/*-------------------------------------------------------------------//
		// Valida o estado e gera o código do município de acordo com o IBGE //
		//-------------------------------------------------------------------*/
		//12	AC
		If SA1->( A1_EST ) = 'AC'
			cCodMun	:= '12'+ SA1->( A1_COD_MUN )
		//27	AL
		ElseIf SA1->( A1_EST ) = 'AL'
			cCodMun	:= '27'+ SA1->( A1_COD_MUN )
		//16	AP
		ElseIf SA1->( A1_EST ) = 'AP'
			cCodMun	:= '16'+ SA1->( A1_COD_MUN )
		//13	AM
		ElseIf SA1->( A1_EST ) = 'AM'
			cCodMun	:= '13'+ SA1->( A1_COD_MUN )
		//29	BA
		ElseIf SA1->( A1_EST ) = 'BA'
			cCodMun	:= '29'+ SA1->( A1_COD_MUN )
		//23	CE
		ElseIf SA1->( A1_EST ) = 'CE'
			cCodMun	:= '23'+ SA1->( A1_COD_MUN )
		//53	DF
		ElseIf SA1->( A1_EST ) = 'DF'
			cCodMun	:= '53'+ SA1->( A1_COD_MUN )
		//32	ES
		ElseIf SA1->( A1_EST ) = 'ES'
			cCodMun	:= '32'+ SA1->( A1_COD_MUN )
		//52	GO
		ElseIf SA1->( A1_EST ) = 'GO'
			cCodMun	:= '52'+ SA1->( A1_COD_MUN )
		//21	MA
		ElseIf SA1->( A1_EST ) = 'MA'
			cCodMun	:= '21'+ SA1->( A1_COD_MUN )
		//51	MT
		ElseIf SA1->( A1_EST ) = 'MT'
			cCodMun	:= '51'+ SA1->( A1_COD_MUN )
		//50	MS
		ElseIf SA1->( A1_EST ) = 'MS'
			cCodMun	:= '50'+ SA1->( A1_COD_MUN )
		//31	MG
		ElseIf SA1->( A1_EST ) = 'MG'
			cCodMun	:= '31'+ SA1->( A1_COD_MUN )
		//15	PA
		ElseIf SA1->( A1_EST ) = 'PA'
			cCodMun	:= '15'+ SA1->( A1_COD_MUN )
		//25	PB
		ElseIf SA1->( A1_EST ) = 'PB'
			cCodMun	:= '25'+ SA1->( A1_COD_MUN )
		//41	PR
		ElseIf SA1->( A1_EST ) = 'PR'
			cCodMun	:= '41'+ SA1->( A1_COD_MUN )
		//26	PE
		ElseIf SA1->( A1_EST ) = 'PE'
			cCodMun	:= '26'+ SA1->( A1_COD_MUN )
		//22	PI
		ElseIf SA1->( A1_EST ) = 'PI'
			cCodMun	:= '22'+ SA1->( A1_COD_MUN )
		//33	RJ
		ElseIf SA1->( A1_EST ) = 'RJ'
			cCodMun	:= '33'+ SA1->( A1_COD_MUN )
		//24	RN
		ElseIf SA1->( A1_EST ) = 'RN'
			cCodMun	:= '24'+ SA1->( A1_COD_MUN )
		//43	RS
		ElseIf SA1->( A1_EST ) = 'RS'
			cCodMun	:= '43'+ SA1->( A1_COD_MUN )
		//11	RO
		ElseIf SA1->( A1_EST ) = 'RO'
			cCodMun	:= '11'+ SA1->( A1_COD_MUN )
		//14	RR
		ElseIf SA1->( A1_EST ) = 'RR'
			cCodMun	:= '14'+ SA1->( A1_COD_MUN )
		//42	SC
		ElseIf SA1->( A1_EST ) = 'SC'
			cCodMun	:= '42'+ SA1->( A1_COD_MUN )
		//35	SP
		ElseIf SA1->( A1_EST ) = 'SP'
			cCodMun	:= '35'+ SA1->( A1_COD_MUN )
		//28	SE
		ElseIf SA1->( A1_EST ) = 'SE'
			cCodMun	:= '28'+ SA1->( A1_COD_MUN )
		//17	TO
		ElseIf SA1->( A1_EST ) = 'TO'
			cCodMun	:= '17'+ SA1->( A1_COD_MUN )
		Endif
	EndIf
	
	SB5->(DbSetOrder( 1 ))
	If SB5->( DbSeek(FWxFilial('SB5') + cProduto ))		
		/*--------------------------------------------------------------------------------------------------------//
		//  Valida o Cultivar do Produto e converte para o ID Cultivar do INDEA-MT contido no campo (NP4_IDCTVR) //
		//--------------------------------------------------------------------------------------------------------*/
		NP4->(DbSetOrder( 1 ))
		If NP4->( DbSeek( FWxFilial('NP4') + SB5->( B5_CTVAR )))
			If NP4->(FieldPos("NP4_IDCTVR")) > 0
				cCtvar	:= NP4->( NP4_IDCTVR )
			Else 
				cCtvar := ''
			Endif	
		EndIf	
		If lProd
			/*-----------------------------------------------------------------//
			// Valida a Categoria da Semente e converte para o modelo INDEA-MT //
			//-----------------------------------------------------------------*/
			If SB5->( B5_CATEG ) = 'S1'
				cCtSemente := '1'
			ElseIf SB5->( B5_CATEG ) = 'S2'
				cCtSemente := '2'
			ElseIf SB5->( B5_CATEG ) = 'C1'
				cCtSemente := '3'
			ElseIf SB5->( B5_CATEG ) = 'C2'
				cCtSemente := '4'
			ElseIf SB5->( B5_CATEG ) = 'BS'
				cCtSemente := '5'
			Endif
		EndIf
	EndIf

	If lProd
	/*-----------------------------------------------------------------//
	 // Valida a Safra e converte para o ID Safra do INDEA-MT contido no campo (NJU_IDSAFR) //
	 //-----------------------------------------------------------------*/
		NJU->(DbSetOrder( 1 ))
		If NJU->( DbSeek( FWxFilial('NJU') + NP9->( NP9_CODSAF ))) 
			If NJU->(FieldPos("NJU_IDSAFR")) > 0
				cCodSafra   := NJU->( NJU_IDSAFR )
			Else 
				cCodSafra   := ''	
			Endif	
		EndIf	
	EndIf

	cNum :=GETSXENUM("ND3", "ND3_CODIGO")
	ConfirmSX8() 

	If RecLock("ND3", .T.)
		ND3->ND3_FILIAL		:= FWxFilial("ND3")
		ND3->ND3_CODIGO     := cNum
		ND3->ND3_TIPOOP		:= '2'                                                                                               
		ND3->ND3_CODPRO		:= cProduto
		ND3->ND3_LOTE		:= cLote
		ND3->ND3_QUANT		:= cQuant
		ND3->ND3_DOC		:= cDoc
		ND3->ND3_SERIE		:= cSerie
		ND3->ND3_DTDOC		:= cDTEmissao
		ND3->ND3_DTSAI		:= cDTSaida
		ND3->ND3_CLIENT		:= cCliente
		ND3->ND3_LOJA		:= cLoja
		ND3->ND3_CTVAR		:= cCtvar
		ND3->ND3_CGC		:= cCpfCnpj
		ND3->ND3_FORCLI		:= cNomeCli
		ND3->ND3_CODMUN		:= cCodMun
		ND3->ND3_RENASE		:= cRenasem							
		If lProd 
		/*-----------------------------------------------------------------//
		 // Campos específicos da venda de sementes/mudas - Produtor //
	 	//-----------------------------------------------------------------*/
			ND3->ND3_TIPOOP		:= '4'
			ND3->ND3_CTGSMT     := cCtSemente
			ND3->ND3_DFASE      := cDarFase 
			ND3->ND3_DINDEA     := cDarIndea   
			If ND3->(FieldPos("ND3_CODSAF")) > 0
				ND3->ND3_CODSAF := cCodSafra
			Endif	                     	
		EndIf
		ND3->(MsUnlock())
		RestArea( aAreaAtu )
	EndIf
Return nil  
