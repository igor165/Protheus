#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGA250.ch"

Static __aTab1221   := {"N83"} //tabelas SLC - previsão liberação 1220
Static __lLib1221   := .F. //Proteção de fonte para liberação 12.20 SLC

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/** {Protheus.doc} OGA250R
**
Rotina para Reabrir / Cancelar Romaneio
**
**/

/** {Protheus.doc} OGA250REA
Rotina para estorno do fechamento do romaneio

@param: 	cAlias - Tabela do Romaneio
@param: 	nReg - Registro para atualizacao
@param: 	nAcao - Tipo de atualizacao
@param: 	lAuto - Se automatica para nao exibir mensagens
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	24/10/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250REA( cAlias, nReg, nOpcao, aValores )
	Local aAreaAtu  	:= GetArea()
	Local cFill         := NJJ->NJJ_FILIAL
	Local cRoman        := NJJ->NJJ_CODROM
	Local aParam := {cFill, cRoman}
	
	Private _cIniStaNJJ	:= NJJ->NJJ_STATUS //Armazena o status inicial da NJJ antes de reabrir

	Default aValores := {}

	__lLib1221 := AGRTABDIC(__aTab1221)

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)

	If NJJ->( NJJ_TIPO ) $ "A|B" //A=(E) ENTRADA POR TRANSFERENCIA; B=(S) SAIDA POR TRANSFERENCIA
		AgrHelp(STR0021, STR0549, STR0371) //'HELP##"Não é possível reabrir o romaneio."##Romaneios com o Tipo de Controle A=(E) ENTRADA POR TRANSFERENCIA ou B=(S) SAIDA POR TRANSFERENCIA não podem ser reabertos!
		Return( Nil )
	EndIf

	If NJJ->( NJJ_STATUS ) $ "0|1" //0=Pendente; 1=Completo
		AgrHelp(STR0021, STR0549, STR0051) //'HELP##"Não é possível reabrir o romaneio."##"Somente romaneios com status de -Atualizado- e Status Fiscal diferente de Com Fiscal podem ser -Reabertos-."
		Return( Nil )
	EndIf

	If NJJ->NJJ_TIPO != "1" .AND. fNJMStaFis("GRID") == "2" 
		AgrHelp(STR0021, STR0549, STR0051) //'HELP##"Não é possível reabrir o romaneio."##"Somente romaneios com status de -Atualizado- e Status Fiscal diferente de Com Fiscal podem ser -Reabertos-."
		Return( Nil )
	EndIf	

	If AGRGRAVAHIS(STR0052,"NJJ",NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM,"B",aValores) = 1		//"Tem certeza que deseja reabrir este romaneio?"
		// Reabre o romaneio
		If ReabreNJJ()
			//se for Rom de Transferencia, atualizo o status. 
			If NJJ->(FieldPos("NJJ_CODTRF") > 0)
				If !Empty(NJJ->NJJ_CODTRF) 
					//limpar o rom.
					If Empty(NJJ->NJJ_SEQTRF) //se for de origem
						DbSelectArea('NBU')
						NBU->(DbSetOrder(1))
						If NBU->(DbSeek(xFilial('NBU')+NJJ->( NJJ_CODTRF )))	
							While NBU->(!Eof())
								If RecLock("NBU", .F.)														
									NBU->( NBU_DOCDEV) := ""
								NBU->(MsUnlock())
								EndIf	
							NBU->(DbSkip())
							Enddo				
						EndIf
					Else
						DbSelectArea('NBU')
						NBU->(DbSetOrder(1))
						If NBU->(DbSeek(xFilial('NBU')+NJJ->( NJJ_CODTRF )+ALLTRIM(NJJ->( NJJ_SEQTRF ))))					
							If RecLock("NBU", .F.)														
								NBU->( NBU_DOCTRF) := ""
							NBU->(MsUnlock())
							EndIf					
						EndIf
					EndIf

				OGA455STS(NJJ->NJJ_CODTRF)

				EndIf
			EndIf
			If Empty(aValores)
				MsgInfo(STR0160, STR0161)
			EndIf
			If ExistBlock('OG250RDEL')
				ExecBlock('OG250RDEL',.F.,.F.,aParam)
			EndIf 	
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} OGA250CAN
Rotina para Cancelamento do Romaneio

@param: 	cAlias - Tabela do Romaneio
@param: 	nReg - Registro para atualizacao
@param: 	nAcao - Tipo de atualizacao
@param: 	lAuto - Se automatica para nao exibir mensagens
@param: 	cCodRom - Código do romaneio  
@param: 	cFilNJJ - Filial do romaneio
@param: 	cStatusNJJ - Status do romaneio
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	24/10/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250CAN( cAlias, nReg, nOpcao, aValores, cCodRom, cFilNJJ, cStatusNJJ)
	Local lRetorno	:= .t.
	Local aAreaAtu  	:= GetArea()
	
	Private _cIniStaNJJ	:= NJJ->NJJ_STATUS //Armazena o status inicial da NJJ antes de cancelar
	
	Default aValores := {}

	__lLib1221 := AGRTABDIC(__aTab1221)

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)
	
		//se parâmetro código do romaneio estiver vazio atribui posicionado tela
		If Empty(cCodRom)
			cCodRom := NJJ->NJJ_CODROM
		EndIf

		//se parâmetro filial do romaneio estiver vazio atribui posicionado tela
		If Empty(cFilNJJ)
			cFilNJJ := NJJ->NJJ_FILIAL
		EndIf

		//se parâmetro status do romaneio estiver vazio atribui posicionado tela
		If Empty(cStatusNJJ)
			cStatusNJJ := NJJ->NJJ_STATUS 	
		EndIf
	
	If cStatusNJJ == "4" // Se romaneio já cancelado (NJJ_STATUS = "4"), não permite cancelar novamente
		AgrHelp(STR0021, STR0550, STR0101) //'HELP'###""Não é possível cancelar o romaneio."###"Somente romaneios com status de -Pendente, Completo ou Atualizado (sem fiscal)- podem ser -Cancelados-."
		Return( Nil )
	EndIf

	If .Not. (cStatusNJJ $ "0|1" )
		If NJJ->NJJ_TIPO != "1"  .and. NJJ->NJJ_STATUS != "1" .and. fNJMStaFis("GRID") == "2" // Se possui Doc Fiscal, não permite cancelar
			AgrHelp(STR0021, STR0550, STR0101) //'HELP'###""Não é possível cancelar o romaneio."###"Somente romaneios com status de -Pendente, Completo ou Atualizado (sem fiscal)- podem ser -Cancelados-."
			Return( Nil )
		EndIf
	EndIf

	If AGRGRAVAHIS(STR0085,"NJJ",cFilNJJ+cCodRom,"C", aValores) = 1	//"Tem certeza que deseja cancelar este romaneio?"	

		If  .Not. (cStatusNJJ $ "0|1" )
			// Reabre o romaneio
			lRetorno := ReabreNJJ()
		EndIf

		If lRetorno
			// Cancela o romaneio
			dbSelectArea( "NJJ" )
			NJJ->(dbSetOrder(1))
			If NJJ->(MsSeek(cFilNJJ+cCodRom)) //filial + código romaneio
				If RecLock( "NJJ", .f. )
					NJJ->( NJJ_STATUS ) := "4" //4=Cancelado
					If NJJ->(ColumnPos('NJJ_DTULAL')) > 0 .and. __lnewNeg
						NJJ->NJJ_DTULAL := dDatabase
						NJJ->NJJ_HRULAL := Time()
					EndIf
					msUnLock()
				EndIf
				If TableInDic('N9D').and. __lnewNeg
					//Ao cancelar um romaneio, excluir tabela N9D com transação 07 para o romaneio. 
					DBSelectArea("N9D")
					N9D->(DbSetOrder(6))
					N9D->(DbSeek(NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM))
					While N9D->(!Eof()) .AND. NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM == N9D->N9D_FILORG + N9D->N9D_CODROM
						If N9D->N9D_TIPMOV == "07"
							RecLock("N9D",.F.)
							N9D->(DbDelete())
							N9D->(MsUnlock())
						EndIf
						N9D->(DbSkip())
					EndDo
				EndIf 
			EndIf	
			If __lnewNeg
				If Empty(aValores)
					MsgInfo( STR0162, STR0163)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} ReabreNJJ
Rotina para reabertura do romaneio: atualizações na base de dados

@author 	Marlon Richard Trettin
@since 	08/12/2014
@Uso: 		OGA250 - Romaneio
@type function
*/
Static Function ReabreNJJ()

	Local lRetorno     	:= .T.
	Local aDelNJM      	:= {}
	Local nX 		 	:= 0
	Local cNumPV 	  	:= ""
	Local cStatus     	:= ""
	Local lGerencial  	:= ( NJJ->NJJ_TIPENT == "1" ) // 1=Gerencial
	Local aFrdDXI     	:= {}
	Local cCampoRom   	:= ""  //Verifica se o campo para gravar o Romaneio é DXI_ROMSAI ou DXI_ROMFO
	Local lExport     	:= .F.
	Local aCtrs 	 	:= {}
	Local nPos		 	:= 0		
	Private _cCLTTEMP  	:= NIL //Cria a Temp Table de Consulta de Ordem de Colheita

	If NJJ->( NJJ_TIPO ) == "1" 
		
		//Romaneio por Produção		
		BEGIN TRANSACTION
		
		If  .not. empty(NJJ->(NJJ_APONOP)) //romaneio de produção e com documento.

			Processa({||lRetorno := A500ESTOP()}, STR0372, STR0347 ) //"Estornando Ordem de Produção..."###"Aguarde"

		ElseIF .not. empty(NJJ->(NJJ_DOCEST)) //romaneio de produção e com documento.

			lRetorno := OGX013(.t.) //estorna os valores

		Else
		
			If RecLock( "NJJ", .f. )										
				NJJ->( NJJ_STATUS ) := "1"					
				msUnLock()
			EndIf
		
		EndIf

		If lRetorno 
			If !Empty(NJJ->NJJ_ORDCLT) .And. NJJ->NJJ_PSLIQU > 0 .AND. _cIniStaNJJ == "3" 
				//no reabrir/cancelar faz integração pims se tiver ordem de colheita e status confirmado no romaneio de produção
				If _cCLTTEMP == Nil .And. FWHasEAI( "AGRA530", .T., .F., .T. )
					_cCLTTEMP := AGRA530TTO(@_cCLTTEMP) //cria as variaveis
				EndIf
				lRetorno := AGRA500Int() //integração com o pims
			EndIf
		EndIf
		
		If !lRetorno
			DisarmTransaction()
		EndIf
		
		END TRANSACTION
	
	Else 
		//demais romaneios	
		BEGIN TRANSACTION
		/* Quando utiliza o novo processo pelo registro de negócio */
		If __lnewNeg		
			/* Retira as quantidades informadas na NJM (Comercialização) das regras fiscais das IEs e do contrato */
			Processa({||lRetorno := OG250DGQTD(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, .F.)}, STR0373, STR0347 ) //"Estornando Comercialização..."###"Aguarde"

			/* Atualiza a quantidade do retorno formação de lote */
			If NJJ->NJJ_TIPO == "7" .AND. lRetorno
				If !OG250HRN9I(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, .F.)
					DisarmTransaction()
					lRet := .F.
				EndIf
			EndIf			
		EndIf	

		dbSelectArea( "NJM" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) )
		While .Not. NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) .AND. lRetorno
			If (NJM->( NJM_STAFIS ) != '1')
				RecLock('NJM',.F.)
					NJM->( DbDelete() )
				msUnLock('NJM')
				NJM->( dbSkip() )
				Loop
			EndIf 
			If __lnewNeg
				lExport := OGA250EXP(xFilial("NJJ"), NJJ->( NJJ_CODROM ))
			EndIf
			IF !lExport
				cNumPV := NJM->( NJM_PEDIDO )

				// Se romaneio tem pedido de venda, exclui o pedido
				If !Empty( cNumPV )

					// Exclui o pedido de venda
					If AgrExcluPV( cNumPV )

						// Verifica se a exclusão do pedido foi bem sucedida
						SC5->( dbSetOrder( 1 ) ) // C5_FILIAL+C5_NUM
						If SC5->( dbSeek( xFilial( "SC5" ) + cNumPV ) )
							AgrHelp(STR0021, STR0130, STR0551 + Chr(10) + Chr(13) + "[ " + cNumPV + " ]") //'HELP'###"Romaneio não pode ser reaberto, pois ocorreu um problema ao excluir o Pedido de Venda. "###"Exclua o pedido de venda para poder reabrir o romaneio."
							lRetorno := .F.
							Exit
						Else 
							RecLock('NJM',.F.) // limpando o campo do pedido
								NJM->( NJM_PEDIDO ) := ''
							msUnLock('NJM')
														
						EndIf	

					Else
						AgrHelp(STR0021, STR0130, STR0551 + Chr(10) + Chr(13) + "[ " + cNumPV + " ]") //'HELP'###"Romaneio não pode ser reaberto, pois ocorreu um problema ao excluir o Pedido de Venda. "###"Exclua o pedido de venda para poder reabrir o romaneio."
						lRetorno := .F.
						Exit
					EndIf

				EndIf
			EndIf

			// Remessa por Ordem Terceiros - Não atualiza dados do contrato, elimina o registro
			If  NJM->(ColumnPos('NJM_SUBTIP')) > 0 .AND. NJM->NJM_SUBTIP == '46' .AND. lRetorno
				aAdd( aDelNJM, NJM->( Recno() ) )	
			ElseIf lRetorno			
				/***********************************************************/
				//Validar a existência de cálculo de serviço
				dbSelectArea('NKG')
				dbSetOrder(2)
				dbSeek( xFilial('NKG') + NJM->NJM_CODROM + NJM->NJM_ITEROM )
				While ! NKG->( Eof() ) .And. NKG->( NKG_FILIAL + NKG_CODROM + NKG_ITEROM ) == xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM )

					If ! Empty( NKG->NKG_FECSER ) .Or. NKG->NKG_FECSER == '0'
						//Se o serviço já estiver vinculado a um fechamento, o romaneio não pode ser reaberto
						AgrHelp(STR0021, STR0549, STR0100) //'HELP'###"Não é possível reabrir o romaneio."###"Há fechamento de cálculo de serviço relacionado ao romaneio. Verifique os serviços gerados."
						lRetorno := .F.
						Exit
					Else
						//Se não houver serviço relacionado, o registro do calculo é excluído e a operação prossegue
						If RecLock( 'NKG', .f. )	
							NKG->( dbDelete() )
							NKG->( MsUnlock() )
						Endif
					Endif

					NKG->( dbSkip() )
				EndDo
				/***********************************************************/

				If NJJ->( NJJ_STATUS ) <> '4' //4=Cancelado
					dbSelectArea('NJR')
					NJR->( dbSetOrder( 1 ) )
					If NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) ) .AND. ((NJM->(ColumnPos('NJM_SUBTIP')) > 0 .and. __lnewNeg .AND. !NJM->NJM_SUBTIP $ "43|46|51") .OR. !__lnewNeg)// (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM

						If RecLock( "NJR", .f. )
							If NJJ->( NJJ_TIPO ) $ "1|3|5|7|9"
								NJR->( NJR_QTEFCO ) -= NJM->( NJM_QTDFCO )
								NJR->( NJR_QTEFIS ) -= NJM->( NJM_QTDFIS ) 
								NJR->( NJR_VLEFIS ) -= NJM->( NJM_VLRTOT ) 
							Else
								NJR->( NJR_QTSFCO ) -= NJM->( NJM_QTDFCO )
								NJR->( NJR_QTSFIS ) -= NJM->( NJM_QTDFIS ) 
								NJR->( NJR_VLSFIS ) -= NJM->( NJM_VLRTOT )
							EndIf
							NJR->( msUnLock() )
						EndIf

						// Atualiza qtdes do contrato
						OGX010QTDS("A")	

						If RecLock( "NJR", .f. )
							/**********************************/
							/** Excluir reservas automáticas **/
							dbSelectArea('NJB')
							dbSetOrder(3)
							dbSeek( xFilial('NJB') + NJM->( NJM_CODROM ) + NJM->(NJM_ITEROM) )
							While ! NJB->( Eof() ) .And. NJB->( NJB_FILIAL + NJB_CODROM + NJB_ITEROM ) == xFilial('NJB') + NJM->( NJM_CODROM + NJM_ITEROM	)

								If NJB->NJB_CODCTR == NJR->NJR_CODCTR 

									If NJB->NJB_STATUS == '1'  // RESERVADO
										NJR->NJR_QTDRES := NJR->NJR_QTDRES - NJB->NJB_QTDPRO
									EndIf

									RecLock('NJB',.f.)
									NJB->( dbDelete() )
									NJB->( MsUnlock('NJB') )

								Endif	

								NJB->( dbSkip() )	
							EndDo
							/*********************************/      	
							NJR->( msUnLock() )
						EndIf

					EndIf

					// Voltar o saldo da Autorizacao
					If !Empty( NJM->NJM_CODAUT ) .AND. ( !__lnewNeg .or. (NJM->(ColumnPos('NJM_SUBTIP')) > 0 .AND. !NJM->NJM_SUBTIP $ "43|46|51")) // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM
						dbSelectArea( "NJP" ) // Autorizacao
						dbSetOrder( 1 )
						If dbSeek( xFilial( "NJP" ) + NJM->( NJM_CODCTR ) + NJM->( NJM_CODAUT ) )

							If RecLock( "NJP", .f. )

								NJP->( NJP_QTDFCO ) -= NJM->( NJM_QTDFCO )
								NJP->( NJP_QTDFIS ) -= NJM->( NJM_QTDFIS )

								If NJP->( NJP_QTDFCO ) == 0 .AND. NJP->( NJP_QTDFIS ) == 0 
									NJP->NJP_STATUS := "A" // Aberto
								Else 
									NJP->NJP_STATUS := "I" // iniciado
								EndIf
							EndIf
							NJP->( msUnLock() )
						EndIf
					EndIf

					//limpa campo rateio de saida do fardinho
					If __lnewNeg .and. NJJ->( NJJ_TIPO ) $ "4|2" .and. AGRTPALGOD(NJJ->( NJJ_CODPRO ))

						cCampoRom     := OGA250BRMSAI( NJJ->(NJJ_CODROM) )

						dbSelectArea( "DXI" ) 
						If cCampoRom == 'DXI_ROMSAI'
							DXI->(dbSetOrder(6)) //FILIAL+DXI_ROMSAI+DXI_ITEROM
						Else
							DXI->(dbSetOrder(9)) //FILIAL+DXI_ROMFLO+DXI_ITEROM
						EndIf
						If DXI->(dbSeek( xFilial( "DXI" ) + NJJ->( NJJ_CODROM ) ))
							While DXI->(!Eof()) .and. DXI->( DXI_FILIAL ) = NJJ->( NJJ_FILIAL ) .AND. &("Alltrim(DXI->("+ cCampoRom + "))") == AllTrim(NJJ->( NJJ_CODROM )) 

								Aadd( aFrdDXI, { ;
								DXI->DXI_CODINE,;
								DXI->DXI_FILIAL,;
								DXI->DXI_BLOCO ,; 
								DXI->DXI_SAFRA ,;
								DXI->DXI_CODIGO,;
								DXI->DXI_PSBRUT,;
								DXI->DXI_PSLIQU,;
								0,;
								DXI->DXI_PESSAI,; //peso rateio
								DXI->DXI_ETIQ  }) //gera array com os fardinhos para subtrair peso remetido N7Q_QTDREM

								If RecLock( "DXI", .F. )
									DXI->( DXI_PESSAI ) := 0
									DXI->( msUnLock() )
								EndIf

								DXI->( dbSkip() )
							EndDo		
						EndIf	
					EndIF
				EndIf		


				IF NJM->( NJM_CODPRO ) != NJJ->( NJJ_CODPRO ) .OR. NJM->( NJM_TIPMOV ) = "2" 

					aAdd( aDelNJM, NJM->( Recno() ) )

				EndIF

				If lGerencial
					If RecLock( "NJM", .f. )
						NJM->( NJM_DTRANS ) := CtoD("//")
						NJM->( msUnLock() )
					EndIf
				EndIf

			ENDIF

			nPos := aScan( aCtrs, alltrim(NJM->( NJM_CODCTR )))
			If nPos == 0
				aAdd( aCtrs, alltrim(NJM->( NJM_CODCTR )) )					
			EndIf

			If !__lnewNeg .AND. NJM->(ColumnPos('NJM_SUBTIP')) > 0
				If RecLock( "NJM", .f. )
					NJM->( NJM_SUBTIP ) := ""
					NJM->( NJM_IDMOV ) := ""
					NJM->( msUnLock() )
				EndIf
			EndIf 

			NJM->( dbSkip() )
		EndDo

		If lRetorno .and. __lnewNeg
			/* Atualiza a quantidade instuida da IE (N7Q/N7S) considerando o ganho de peso */
			/* Apenas para algodão */
			OG250EAQIE("07", NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, .T.)

			// Atualiza o movimento dos fardos (07 - Romaneio)
			OG250EATMF(.F., "07", NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
		EndIf

		If lRetorno

			DbSelectArea( "NJM" )
			For nX := 1 to Len( aDelNJM )

				DbGoTo( aDelNJM[ nX ] )
				If !(NJM->(Eof()))
					If RecLock( "NJM", .f. )
						NJM-> (dbdelete())
						NJM->( msUnLock() )
					EndIf
				EndIf
			Next nX

			If NJJ->( NJJ_TIPENT ) == "0" // Se romaneio for Fisico
				If NJJ->( NJJ_STSPES ) == "2" // Se status pesagem = '2-Segunda pesagem'
					cStatus := "1" // Então status romaneio = '1-Completo'
				Else 
					cStatus := "0" // Senão, status romaneio = '0-Pendente'
				EndIf
			Else // Senão, se romaneio não for Físico
				cStatus := "1" // Então status romaneio = '1-Completo'
			EndIf


			dbSelectArea( "NJJ" )
			If RecLock( "NJJ", .f. )
				//			NJJ->( NJJ_OBS    ) := cObs
				NJJ->( NJJ_STATUS ) := cStatus
				//			NJJ->( NJJ_LIBQLD ) := cStsQld
				If lGerencial
					NJJ->( NJJ_DTRANS ) := CtoD("//")
				EndIf
				
				If __lnewNeg
					NJJ->NJJ_DTULAL := dDatabase
					NJJ->NJJ_HRULAL := Time()

					msUnLock()
				EndIf
			EndIf
			If AGRColPos('NJR_TPEXC')  //12.1.17 projeto SJC - dicionario diferencial de outubro aplicado
				For nX := 1 to Len( aCtrs )
					ChecarNNW(aCtrs[nX],NJJ->( NJJ_CODROM ))
				Next nX
			EndIf
		Else
			lRetorno := .F.
		EndIf
		If !lRetorno
			DisarmTransaction()
		EndIf
		END TRANSACTION
	EndIf

Return( lRetorno ) 
