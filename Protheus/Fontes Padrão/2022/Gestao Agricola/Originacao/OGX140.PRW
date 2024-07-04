#include "protheus.ch"
#include "fwmvcdef.ch"
#include "ogx140.ch" 

/** {Protheus.doc} OGX140
Rotina chamada através do Ponto de Entrada no final da gravação do Documento de Entrada ( MATA103 )
Chamado após os PEs: MT100AGR (MATA100) e MT100AGR (MATA103)

@param:     lExec   - .T. força a rotina a ser executada independente de onde estiver sendo chamada.
@return:    Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       SIGAAGR
@type function
*/
// Função Original:ARMXPE05 

Function OGX140( lExec )
	Local aAreaAtu  	:= GetArea()
	Local aAreaSF1  	:= SF1->(GetArea())
	Local aAreaSF4  	:= SF4->(GetArea())
	Local aAreaSD1  	:= SD1->(GetArea())
	Local aAreaSE2  	:= SE2->(GetArea())
	Local lAtzValFin    := .F.

	Local aLinVncAux2	:= {}
	Local cHist			:= {}
	Local cOrigem		:= ''
	Local aVncCPag 		:= {}

	Local lSISDEV       := SuperGetMV("MV_SISDEV", .F., .F.)

	Default lExec       := .F.

	Private lMsErroAuto := .F.

	If lExec .Or. ( INCLUI .Or. ALTERA ) 

		IF ! SF1->F1_TIPO == 'C'        // Se NÃO for nota de complemento

			dbSelectArea( "SD1" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) )

				While .Not. SD1->( Eof() ) ;
				.And. SD1->( D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )

					If .Not. Empty( SD1->( D1_CTROG ) )
						lAtzValFin := .F.

						dbSelectArea( "NJM" )
						dbSetOrder( 1 )
						If dbSeek( xFilial( "NJM" ) + SD1->( D1_CODROM ) + SD1->( D1_ITEROM ) )

							// Atualiza o item do romaneio (NJM)
							RecLock( "NJM", .f. )
							NJM->( NJM_DOCSER ) := SF1->( F1_SERIE )
							NJM->( NJM_DOCNUM ) := SF1->( F1_DOC )
							NJM->( NJM_DOCEMI ) := SF1->( F1_EMISSAO )
							NJM->( NJM_DOCESP ) := SF1->( F1_ESPECIE )
							NJM->( NJM_CHVNFE ) := SF1->( F1_CHVNFE )
							NJM->( NJM_STAFIS ) := "2"
							NJM->( NJM_DTRANS ) := dDatabase
							NJM->(MsUnLock())

							If NJM->( NJM_TIPO ) $ "4|5|8|9"
								lAtzValFin := .T.
							EndIf
						EndIf

						/* Movido bloco para este ponto para tratar também os casos em que 
						APENAS o contrato é informado via MATA103*/
						SF4->( dbSetOrder( 1 ) )
						SF4->( dbSeek( xFilial( "SF4" ) + SD1->( D1_TES ) ) )
						If SF4->( F4_DUPLIC ) = "S"

							If lAtzValFin
								// Atualiza valores financeiros provisorios do contrato
								OGA250ATUF(NJM->( NJM_CODCTR ), NJM->( NJM_QTDFIS ), IIF(NJM->( NJM_TIPO ) $ "4|5","2","1"))
							EndIf
							
							aVncCPag := {}

							dbSelectArea( "SE2" )
							dbSetOrder( 6 ) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
							If dbSeek( xFilial( "SE2" ) + SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC ) )
								While .Not. SE2->( Eof() ) .And. SE2->( E2_FILIAL ) == xFilial( "SE2" ) ;
								.And. SE2->( E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC )
									///;       .And. Empty( SE2->( E2_CTROG ) )

									If GetRpoRelease() >= "12.1.023" //a partir do rpo 12.1.023 usa tabelas de extensão
										cHist := Alltrim(Posicione("SX5",1,xFilial("SX5")+'K5' + NJM-> NJM_TIPO,"X5_DESCRI"))
										cOrigem := ''
										IF IsInCallStack('OGA250')
											cOrigem := 'OGA250'
										ElseIF IsInCallStack('OGA251')
											cOrigem := 'OGA251'
										EndIF
										
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
							EndIf

							//realiza o ajuste na previsão financeira quando for devolução.
							If GetRpoRelease() >= "12.1.023"

								If SF1->F1_TIPO == 'D' //faz somente para notas de devolução
									//vamos verificar se o lance deu liga
									fEstornaCtr(SD1->D1_FILIAL, SD1->D1_FILORI, SD1->D1_CTROG, SD1->D1_SERIORI, SD1->D1_NFORI, SD1->D1_QUANT, SD1->D1_TOTAL)

								EndIf

							EndIf

						EndIf

					EndIf

					//Coletar dados de compra de sementes/mudas a serem transmitidas ao SISDEV
					IF AliasIndic("ND3") .AND. lSISDEV
						DbSelectArea('ND3')
						IF ND3->(ColumnPos('ND3_CODPRO')) > 0 .AND. ND3->(ColumnPos('ND3_FORNEC')) > 0 .AND. ND3->(ColumnPos('ND3_LOJA')) > 0
							IF Posicione("SB5", 1, xFilial("SB5") + SD1->D1_COD, "B5_SEMENTE") == "1"
								GravarSISDEV(SD1->D1_COD, SD1->D1_LOTECTL, SD1->D1_QUANT, SD1->D1_DOC, SD1->D1_SERIE,;
								SD1->D1_EMISSAO, SD1->D1_DTDIGIT, SD1->D1_FORNECE, SD1->D1_LOJA)
							ENDIF
						ENDIF
					ENDIF

					SD1->( dbSkip() )
				EndDo

				IF  Len( aVncCPag ) > 0
					fAgrVncPag (aVncCPag, 3 )  	//Incluir
				EndIF

				// Atualiza o registro de NJJ com o primeiro de NJM
				OGX140AtNJJ( xFilial( "NJJ" ), SF1->( F1_CODROM ) )

			EndIf

		ElseIF SF1->F1_TIPO == 'C'   //--Inc. Emerson 11/02/2015 Tratar Tits. das nfs. de Compl. de preço do originação --//

			dbSelectArea( "SD1" )
			SD1->( dbSetOrder( 1 ) )
			If SD1->( dbSeek( xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )

				While SD1->(! Eof() ) .And. SD1->D1_FILIAL = xFilial( "SD1" ) ;
				.And. SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )

					If !FWIsInCallStack("OGA430B") .AND. !FWIsInCallStack("OGA450C")
						dbSelectArea( "NJM" )
						dbSetOrder( 1 )
						If dbSeek( xFilial( "NJM" ) + SD1->( D1_CODROM ) + SD1->( D1_ITEROM ) )
							// Atualiza o item do romaneio (NJM)
							RecLock( "NJM", .f. )
							NJM->( NJM_DOCSER ) := SF1->( F1_SERIE )
							NJM->( NJM_DOCNUM ) := SF1->( F1_DOC )
							NJM->( NJM_DOCEMI ) := SF1->( F1_EMISSAO )
							NJM->( NJM_DOCESP ) := SF1->( F1_ESPECIE )
							NJM->( NJM_CHVNFE ) := SF1->( F1_CHVNFE )
							NJM->( NJM_STAFIS ) := "2"
							NJM->( NJM_DTRANS ) := dDatabase
							NJM->(MsUnLock())						
						EndIf
					EndIf

					If .Not. Empty( SD1->( D1_CTROG ) )
						SF4->( dbSetOrder( 1 ) )
						SF4->( dbSeek( xFilial( "SF4" ) + SD1->( D1_TES ) ) )
						If SF4->( F4_DUPLIC ) == "S"

							dbSelectArea( "SE2" )
							SE2->( dbSetOrder( 6 ) ) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
							If SE2->( dbSeek( xFilial( "SE2" ) + SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC ) ) )
								While SE2->( !Eof() )  .And. SE2->E2_FILIAL == xFilial( "SE2" );
								.And. SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC )

									If GetRpoRelease() >= "12.1.023" //a partir do rpo 12.1.023 usa tabelas de extensão

										cOrigem		:= IIF(IsInCallStack('OGA430B'), 'OGA430B',IIF(IsInCallStack('OGA450C'), 'OGA450C',''))
										cHist		:= FWI18NLang("OGX140","STR0001",001)		 
										aVncCPag 	:= {}

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
											aadd( aLinVncAux2, { "N8M_CODSAF"	    , NJM->NJM_CODSAF				} )
											aadd( aLinVncAux2, { "N8M_CODROM"    	, NJM->NJM_CODROM				} )
											aadd( aLinVncAux2, { "N8M_ITEROM"   	, NJM->NJM_ITEROM				} )
											aadd( aLinVncAux2, { "N8M_ITEMFX"   	, NNC->NNC_ITEMFX				} )
											aadd( aLinVncAux2, { "N8M_ORDTRA"    	, ''							} )
											aadd( aLinVncAux2, { "N8M_ORPGRC"    	, ''							} )
											aadd( aLinVncAux2, { "N8M_ITPGRC"    	, ''							} )
											aadd( aLinVncAux2, { "N8M_CODNGC"   	, ''							} )
											aadd( aLinVncAux2, { "N8M_VERNGC"   	, ''							} )
											aadd( aLinVncAux2, { "N8M_ORIGEM"    	, cOrigem		 				} )
											aAdd( aLinVncAux2, { "N8M_HISTOR"    	, ChIST							} )

											aAdd(aVncCPag,aLinVncAux2)

										EndIF

										RecLock( "SE2", .f. )
										SE2->E2_CCD     := SD1->D1_CC

										SE2->( MsUnLock() )

										SE2->( dbSkip() )

									else
										//rpo 12.1.017 e anteriores
										RecLock( "SE2", .f. )
										SE2->E2_CODSAF  := SD1->D1_CODSAF
										SE2->E2_CTROG   := SD1->D1_CTROG
										SE2->E2_CCD     := SD1->D1_CC
										SE2->( MsUnLock() )

										SE2->( dbSkip() )
									endIf
								EndDo
							EndIf
						EndIf
					EndIf

					SD1->( dbSkip() )
				EndDo

				If !FWIsInCallStack("OGA430B") .AND. !FWIsInCallStack("OGA450C")
					// Atualiza o registro de NJJ com o primeiro de NJM
					OGX140AtNJJ( xFilial( "NJJ" ), SF1->( F1_CODROM ) )
				EndIf

				IF  Len( aVncCPag ) > 0
					fAgrVncPag (aVncCPag, 3 )  	//Incluir
				EndIF
			EndIf

		EndIf

	EndIF

	RestArea( aAreaSE2 )
	RestArea( aAreaSD1 )
	RestArea( aAreaSF4 )
	RestArea( aAreaSF1 )
	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} OGX140AtNJJ
Atualiza os dados da NJJ e Status com os dados do primeiro registro da NJM que tem fiscal. 

@param:     cCodRom - Código do romaneio
@return:    Nil
@author:    Marlon Richard Trettin
@since:     20/04/2015
@Uso:       SIGAAGR 
*/
Function OGX140AtNJJ( pcFilial, pcCodRom )
	Local aAreaNJM  := GetArea( "NJM" )
	Local aAreaNJJ  := GetArea( "NJJ" )
	Local lExport	:= .F.

	lExport := OGA250EXP(pcFilial, pcCodRom)

	// Posiciona no primeiro registro de comercialização do romaneio (NJM)
	dbSelectArea( "NJM" )
	dbSetOrder( 1 )
	If dbSeek( pcFilial + pcCodRom )
		While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial( "NJM" ) + pcCodRom

			// Posiciona no primeiro NJM com Fiscal para atualizar o NJJ
			If NJM->( NJM_STAFIS ) == "2" // 2=Com Fiscal

				// Posiciona no registro do romaneio (NJJ)
				dbSelectArea( "NJJ" )
				dbSetOrder( 1 )
				If dbSeek( pcFilial + pcCodRom )
					If RecLock( "NJJ", .f. )
						NJJ->( NJJ_DOCSER ) := NJM->( NJM_DOCSER )
						NJJ->( NJJ_DOCNUM ) := NJM->( NJM_DOCNUM )
						NJJ->( NJJ_DOCEMI ) := NJM->( NJM_DOCEMI )
						NJJ->( NJJ_DOCESP ) := NJM->( NJM_DOCESP )
						NJJ->( NJJ_CHVNFE ) := NJM->( NJM_CHVNFE )
						NJJ->( NJJ_DTRANS ) := NJM->( NJM_DTRANS )
						NJJ->( NJJ_STAFIS ) := "2" //1=Sem Fiscal;2=Com Fiscal;3=Gerencial
						NJJ->( NJJ_STATUS ) := "3" //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
						NJJ->( NJJ_STACTR ) := "2" //1=Sem CTR;2=Com CTR
						If (NJJ->( NJJ_TPFORM ) == "1";      // Se Formulário Próprio = 1 ( SIM )
						.Or. NJJ->( NJJ_TIPO ) $ "2|4|6|8") .AND. !lExport // ou Tipo do Romaneio = SAIDA
							NJJ->( NJJ_QTDFIS ) := NJM->( NJM_QTDFIS )
							NJJ->( NJJ_VLRUNI ) := NJM->( NJM_VLRUNI )
							NJJ->( NJJ_VLRTOT ) := NJM->( NJM_VLRTOT )
						EndIf
						NJJ->( msUnLock() )
					EndIf
				EndIf

				Exit // após achar o primeiro registro de NJM com fiscal, sai do loop

			EndIf

			NJM->( DbSkip() )

		EndDo
	EndIf

	RestArea( aAreaNJJ )
	RestArea( aAreaNJM )
	Return( Nil )


	#Include 'Protheus.ch'
/** {Protheus.doc} MT100GE2
__  Rotina para Ajustar, a Data de Vencto dos tits. de Nf. de Entrada Gerados Pelo originação;
__  Solução Provisoria , Ate que a função A103AtuSE2, do fonte padrão seja atualizada, com a integração do AGRO;  
@param:
PARAMIXB[1] Array of Record         ACols dos títulos financeiro a pagar                                        
PARAMIXB[2] Numérico                    1=inclusão de títulos   2=exclusão de títulos                                       
PARAMIXB[3] Array of Record         AHeader dos titulos financeiros a pagar
Atenção: Esta atualização deve ocorrer, aqui, pq se ocorrer depois da nf. gerada
como o cliente utiliza o envio automatico de tranmissao de nfe, o sistema em alguns
casos gerava o xml sem o ERP TER, Atualizado as datas dos titulos.
@author:    Equipe Agroindustria
@since:     23/06/2015
@Uso:       SIGAAGR - Originação de Grãos
@OBS : Inclusao titulo funcao no mata103 - 21/10/15 - Vanilda Moggio
*/
Function OGX140AtuE2
	Local lVencAprop  := .t.	

	If .Not. Empty( SD1->( D1_CTROG ) ) 
		//- Se TIPO for diferente de complemento
		IF .not. SD1->(D1_TIPO) = "C"
			SF4->( dbSetOrder( 1 ) )
			SF4->( dbSeek( xFilial( "SF4" ) + SD1->( D1_TES ) ) )
			If SF4->( F4_DUPLIC ) == "S"
				NN7->( dbSetOrder( 1 ) )
				NN7->( dbSeek( xFilial( "NN7" ) + SD1->( D1_CTROG ) ) )
				While ! NN7->( Eof() ) .And. NN7->( NN7_FILIAL + NN7_CODCTR ) == xFilial( "NN7" ) + SD1->D1_CTROG
					If NN7->( NN7_DTVENC ) >= dDatabase .and. lVencAprop /*Se já coloco uma data de vencimento - não sobrescrever*/
						If SE2->( E2_VENCTO ) < NN7->( NN7_DTVENC ) .and. OGX140PRDS() /*verifica se ainda tem saldo*/
							SE2->( E2_VENCREA )  := DataValida(NN7->( NN7_DTVENC ),.T.)
							SE2->( E2_VENCTO  )  := NN7->( NN7_DTVENC )
							SE2->( E2_VENCORI )  := NN7->( NN7_DTVENC )
							lVencAprop  := .f.
						EndIf
					EndIf

					//Independente de data de vencimento sempre será atualizado 
					SE2->( E2_NATUREZ )  := NN7->( NN7_NATURE )
					SE2->( E2_CCD     )  := NN7->( NN7_CCD    )

					NN7->( DbSkip() )
				EndDo
			EndIf
			//-- Tratamento para notas de complemento para utilizar outra data de vencimento
		ElseIf SD1->(D1_TIPO) = "C"
			//- verifica se a variavel não existe para criar com data atual
			If type("_dOgVctCpl") == "U" .or. !ValType(_dOgVctCpl) == "D"
				_dOgVctCpl := dDatabase
			EndIf

			SF4->( dbSetOrder( 1 ) )
			SF4->( dbSeek( xFilial( "SF4" ) + SD1->( D1_TES ) ) )
			If SF4->( F4_DUPLIC ) == "S"
				If SE2->( E2_VENCTO ) < _dOgVctCpl
					SE2->( E2_VENCREA )  := DataValida( _dOgVctCpl ,.T.)
					SE2->( E2_VENCTO  )  := _dOgVctCpl
					SE2->( E2_VENCORI )  := _dOgVctCpl
				EndIf

				NN7->( dbSetOrder( 1 ) )
				NN7->( dbSeek( xFilial( "NN7" ) + SD1->( D1_CTROG ) ) )
				While ! NN7->( Eof() ) .And. NN7->( NN7_FILIAL + NN7_CODCTR ) == xFilial( "NN7" ) + SD1->D1_CTROG	                               
					//Independente de data de vencimento sempre será atualizado 
					SE2->( E2_NATUREZ )  := NN7->( NN7_NATURE )
					SE2->( E2_CCD     )  := NN7->( NN7_CCD    )

					NN7->( DbSkip() )
				EndDo			    
			EndIf
		EndIf 
	EndIF 
Return ( Nil )

/** {Protheus.doc} OGX140PRDS
Rotina para verificar se a previsão ainda está disponível.

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Static Function OGX140PRDS()
	Local aAreaSE2  := GetArea( "SE2" )
	Local lExistPR  := .f.	 

	BeginSql Alias "QrySE2"
		Select
		SE2.E2_NUM
		From
		%table:SE2% SE2
		Where
		SE2.E2_FILIAL = %xFilial:SE2% And
		SE2.E2_PREFIXO = 'CTR' And
		SE2.E2_NUM = %Exp:NN7->( NN7_CODCTR )% And
		SE2.E2_TIPO = 'PR' And
		SE2.E2_PARCELA = %Exp:NN7->( NN7_PARCEL )% And
		SE2.E2_FORNECE = %Exp:SD1->D1_FORNECE% And
		SE2.E2_LOJA = %Exp:SD1->D1_LOJA% And
		SE2.%NotDel%        
	EndSql

	if .Not. QrySE2->( Eof() )
		lExistPR := .t.           
	EndIf
	QrySE2->( dbCloseArea( ) )

	RestArea( aAreaSE2 )	
Return (lExistPR)  


Static Function fEstornaCtr(cFilTit, cFilOri, cCtr, cSerieOr, cNfOrig, nQuant, nValor)
	Local cQuery    := ""
	Local cAliasN8K := GetNextAlias()

	//busca o romaneio de venda
	cQuery := " SELECT N8K.*, NJM.*" 
	cQuery += " FROM " + RetSqlname("N8K") + " N8K "
	cQuery += " INNER JOIN " + RetSqlname("NJM") + " NJM ON (N8K.N8K_FILIAL = NJM.NJM_FILIAL AND "  //filial neste caso deve ser igual por se tratar de romaneio
	cQuery +=                           " N8K.N8K_CODROM = NJM.NJM_CODROM AND "
	cQuery +=                           " N8K.N8K_ITEROM = NJM.NJM_ITEROM AND "
	cQuery +=                           " N8K.D_E_L_E_T_ = NJM.D_E_L_E_T_) "
	cQuery += " WHERE N8K.D_E_L_E_T_ = '' "
	cQuery += " AND N8K.N8K_FILIAL = '" + cFilTit + "' "
	cQuery += " AND N8K.N8K_CODCTR = '" + cCtr + "' "
	cQuery += " AND N8K.N8K_SERIE  = '" + cSerieOr + "' "
	cQuery += " AND N8K.N8K_DOC    = '" + cNfOrig + "' "

	cQuery := ChangeQuery( cQuery )

	If Select(cAliasN8K) <> 0
		(cAliasN8K)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN8K,.T.,.T.)

	If (cAliasN8K)->(!EOF())       

		if AGRTPALGOD((cAliasN8K)->(NJM_CODPRO))

		else
			OGX060CANC("D", (cAliasN8K)->NJM_FILORG, (cAliasN8K)->NJM_CODROM, (cAliasN8K)->NJM_ITEROM, (cAliasN8K)->NJM_CODCTR, (cAliasN8K)->NJM_ITEM, (cAliasN8K)->NJM_SEQPRI, nQuant, .t., (cAliasN8K)->NJM_FILIAL, nValor, {cFilOri,SF1->F1_PREFIXO, SF1->F1_DUPL})     
		endif
	EndIf

	//reajusta o valor das previsões
	OGX018ATPR(FWxfilial("NJR"), cCtr, "OGX140")

	(cAliasN8K)->(dbCloseArea())

Return nil

/*/{Protheus.doc} GravarSISDEV
//Função para persistência de dados da recepção de sementes/mudas a serem transmitidas ao SISDEV (UBSA010)
@author luiz.dias
@since 24/10/2019
@version 1.0
@type function
/*/
Static Function GravarSISDEV(cProduto, cLote, cQuant, cDoc, cSerie, cDTEmissao, cDTEntrada, cFornece, cLoja)
	Local aAreaAtu  	:= GetArea()
	Local cRenasem		:= ""
	Local cCpfCnpj		:= ""
	Local cNomeForn		:= ""
	Local cCtvar		:= ""	
	Local cCtSemente	:= ""
	Local cCodMun		:= ""
	Local cDarFase		:= ""
	Local cDarIndea		:= ""

	DbSelectArea('NP9')
	NP9->(DbSetOrder( 5 ))
	NP9->(DbSeek( FWxFilial('NP9') + cDoc + cSerie + cFornece + cLoja + cProduto )) //NP9_FILIAL+NP9_DOC+NP9_SERIE+NP9_FORNEC+NP9_LOJA+NP9_PROD
	While NP9->(!Eof()) .AND. NP9->(NP9_FILIAL+NP9_DOC+NP9_SERIE+NP9_FORNEC+NP9_LOJA+NP9_PROD) == FWxFilial('NP9') + cDoc + cSerie + cFornece + cLoja + cProduto
		If NP9->NP9_LOTE == cLote
			cRenasem	:= NP9->(NP9_RENASE)
			If NP9->(ColumnPos( 'NP9_DFASE' )) > 0   
				cDarFase	:= NP9->(NP9_DFASE)
			EndIf
			If NP9->(ColumnPos( 'NP9_DINDEA' )) > 0
				cDarIndea	:= NP9->(NP9_DINDEA)
			EndIF
		EndIF
		NP9->(DbSkip())
	EndDo
	NP9->(DbCloseArea())

	SA2->(DbSetOrder( 1 ))
	If SA2->(DbSeek( FWxFilial('SA2') + cFornece + cLoja ))
		/*------------------------------------------//
		// Captura nome e CPF ou CNPJ do Fornecedor //
		//------------------------------------------*/
		cCpfCnpj	:= SA2->(A2_CGC)
		cNomeForn	:= SA2->(A2_NOME)		
		/*-------------------------------------------------------------------//
		// Valida o estado e gera o código do município de acordo com o IBGE //
		//-------------------------------------------------------------------*/
		//12	AC
		If SA2->( A2_EST ) = 'AC'
			cCodMun	:= '12'+ SA2->( A2_COD_MUN )
			//27	AL
		ElseIf SA2->( A2_EST ) = 'AL'
			cCodMun	:= '12'+ SA2->( A2_COD_MUN )
			//16	AP
		ElseIf SA2->( A2_EST ) = 'AP'
			cCodMun	:= '16'+ SA2->( A2_COD_MUN )
			//13	AM
		ElseIf SA2->( A2_EST ) = 'AM'
			cCodMun	:= '13'+ SA2->( A2_COD_MUN )
			//29	BA
		ElseIf SA2->( A2_EST ) = 'BA'
			cCodMun	:= '29'+ SA2->( A2_COD_MUN )
			//23	CE
		ElseIf SA2->( A2_EST ) = 'CE'
			cCodMun	:= '23'+ SA2->( A2_COD_MUN )
			//53	DF
		ElseIf SA2->( A2_EST ) = 'DF'
			cCodMun	:= '53'+ SA2->( A2_COD_MUN )
			//32	ES
		ElseIf SA2->( A2_EST ) = 'ES'
			cCodMun	:= '32'+ SA2->( A2_COD_MUN )
			//52	GO
		ElseIf SA2->( A2_EST ) = 'GO'
			cCodMun	:= '52'+ SA2->( A2_COD_MUN )
			//21	MA
		ElseIf SA2->( A2_EST ) = 'MA'
			cCodMun	:= '21'+ SA2->( A2_COD_MUN )
			//51	MT
		ElseIf SA2->( A2_EST ) = 'MT'
			cCodMun	:= '51'+ SA2->( A2_COD_MUN )
			//50	MS
		ElseIf SA2->( A2_EST ) = 'MS'
			cCodMun	:= '50'+ SA2->( A2_COD_MUN )
			//31	MG
		ElseIf SA2->( A2_EST ) = 'MG'
			cCodMun	:= '31'+ SA2->( A2_COD_MUN )
			//15	PA
		ElseIf SA2->( A2_EST ) = 'PA'
			cCodMun	:= '15'+ SA2->( A2_COD_MUN )
			//25	PB
		ElseIf SA2->( A2_EST ) = 'PB'
			cCodMun	:= '25'+ SA2->( A2_COD_MUN )
			//41	PR
		ElseIf SA2->( A2_EST ) = 'PR'
			cCodMun	:= '41'+ SA2->( A2_COD_MUN )
			//26	PE
		ElseIf SA2->( A2_EST ) = 'PE'
			cCodMun	:= '26'+ SA2->( A2_COD_MUN )
			//22	PI
		ElseIf SA2->( A2_EST ) = 'PI'
			cCodMun	:= '22'+ SA2->( A2_COD_MUN )
			//33	RJ
		ElseIf SA2->( A2_EST ) = 'RJ'
			cCodMun	:= '33'+ SA2->( A2_COD_MUN )
			//24	RN
		ElseIf SA2->( A2_EST ) = 'RN'
			cCodMun	:= '24'+ SA2->( A2_COD_MUN )
			//43	RS
		ElseIf SA2->( A2_EST ) = 'RS'
			cCodMun	:= '43'+ SA2->( A2_COD_MUN )
			//11	RO
		ElseIf SA2->( A2_EST ) = 'RO'
			cCodMun	:= '11'+ SA2->( A2_COD_MUN )
			//14	RR
		ElseIf SA2->( A2_EST ) = 'RR'
			cCodMun	:= '14'+ SA2->( A2_COD_MUN )
			//42	SC
		ElseIf SA2->( A2_EST ) = 'SC'
			cCodMun	:= '42'+ SA2->( A2_COD_MUN )
			//35	SP
		ElseIf SA2->( A2_EST ) = 'SP'
			cCodMun	:= '35'+ SA2->( A2_COD_MUN )
			//28	SE
		ElseIf SA2->( A2_EST ) = 'SE'
			cCodMun	:= '28'+ SA2->( A2_COD_MUN )
			//17	TO
		ElseIf SA2->( A2_EST ) = 'TO'
			cCodMun	:= '17'+ SA2->( A2_COD_MUN )
		Endif
	EndIf	

	SB5->(DbSetOrder( 1 ))
	If SB5->(DbSeek(FWxFilial('SB5') + cProduto))		
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
		/*------------------------------------------------------------------------------------------------------//
		//  Valida o Cultivar do Produto e converte para o ID Cultivar do INDEA-MT contido no campo NP4_IDCTVR //
		//------------------------------------------------------------------------------------------------------*/
		NP4->(DbSetOrder( 1 ))
		If NP4->(DbSeek( FWxFilial('NP4') + SB5->( B5_CTVAR )))
			If NP4->(FieldPos("NP4_IDCTVR")) > 0
				cCtvar	:= NP4->( NP4_IDCTVR )
			Else 
				cCtvar  := ''
			Endif
		EndIf		
	EndIf

	cNum :=GETSXENUM("ND3", "ND3_CODIGO")
	ConfirmSX8() 

	If RecLock('ND3', .T.)
		ND3->ND3_FILIAL		:= FWxFilial('ND3')
		ND3->ND3_CODIGO     := cNum
		ND3->ND3_TIPOOP		:= '1'
		ND3->ND3_CODPRO		:= cProduto
		ND3->ND3_LOTE		:= cLote							//Obrigatório
		ND3->ND3_QUANT		:= cQuant							//Obrigatório
		ND3->ND3_DOC		:= cDoc								//Obrigatório
		ND3->ND3_SERIE		:= cSerie							//Obrigatório
		ND3->ND3_DTDOC		:= cDTEmissao						//Obrigatório
		ND3->ND3_DTENTR		:= cDTEntrada						//Obrigatório
		ND3->ND3_FORNEC		:= cFornece
		ND3->ND3_LOJA		:= cLoja
		ND3->ND3_CTVAR		:= cCtvar							//Obrigatório
		ND3->ND3_CTGSMT		:= cCtSemente						//Obrigatório
		ND3->ND3_CGC		:= cCpfCnpj							//Obrigatório
		ND3->ND3_FORCLI		:= cNomeForn						//Obrigatório
		ND3->ND3_CODMUN		:= cCodMun							//Obrigatório
		ND3->ND3_RENASE		:= cRenasem							//Obrigatório
		ND3->ND3_DFASE		:= cDarFase							//Obrigatório
		ND3->ND3_DINDEA		:= cDarIndea						//Obrigatório
		ND3->(MsUnlock())
	EndIf
	RestArea( aAreaAtu )
Return nil 
