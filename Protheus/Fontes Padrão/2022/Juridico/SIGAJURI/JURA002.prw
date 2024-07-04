#INCLUDE "JURA002.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
Static nAtuCorre := 0
Static nAtuJuros := 0
Static nAtuMulta := 0

Static lTemIndice := .T.
Static cIndFCor   := ""

//-----------------------------------------------------------------------
/*/{Protheus.doc} JURA002
Correção Monetária

@param aCodigos    Array de código dos processos a filtrar os registros
para correção
@param aTabelas    Array de tabelas para filtrar os valores atualizáveis
@param lMsg        Indica se mostrarão mensagens, utilizar como .T. quando
a rotina partir de um botão na browse; e como .F. quando
for executada internamente

@param cDataCorte  Data de corte
@param aCamposV    Array de campos para se verificar a correção. Utilizado na exportação personalizada, para corrigir apenas os campos
selecionados para tal

@param lFiltraExtr - Define se irá utilizar o filtro extra
@param cFiltroExtr - valor do campo extra pra filtrar, no caso, filtrar pelo campo NSY_CVERBA
@param cCampoFilt - Nome do campo para filtrar quando for diferente de "NSY_CVERBA".
					Passar o nome do campo sem o prefixo. Exemplo: Para o campo "NSY_COD" passar "_COD"
@param oMonitor   - Objeto JSON para monitoramento da evolução

@author Juliana Iwayama Velho
@since 26/01/10
@version 1.0

FN_EQUACAO           - JA002Equac
FN_FORMULA           - JA002Frmla
FN_QTDEMESES         - DateDiffMonth
FN_SE_TEXTO          - JA002Decod
FN_SE_VALOR          - JA002Decod
FN_SUBROTINA         - JA002SubRN
FN_VALORINDICE       - JA002VInd
FN_VALORJUROSMES     - JA002JMes
FN_VALORFORMULA      - JA002Valor
FN_VER_QTDEMESES     - JA002QtMes
FN_VER_SETEXTO       - JA002TxVlr
FN_VER_SEVALOR       - JA002TxVlr
FN_VER_SEVALORINDICE - JA002VVInd

/*/
//-------------------------------------------------------------------
Function JURA002(aCodigos, aTabelas, lMsg, cDataCorte, aCamposV, lPesq, lRecalculo, lFiltraExtr, cFiltroExtr, cCampoFilt, oMonitor)
Static cMulAtu   := ''
Static cCod      := ''
Static cTabela   := ''
Static cDataBase := ''

Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local aAtualizar := {}
Local aCampoCorr := {}
Local cQuery     := ""
Local cCodigo    := ""
Local cSQL       := ""
Local cFormaCor  := ""
Local cGrupoApr  := ""
Local cDtCorte2  := ""
Local lRet       := .T.
Local lRetI      := .T.
Local aRetI      := {}
Local lExecuta   := .T.
Local lErroInd   := .F.
Local cDataJuros := ''
Local nValor     := 0
Local nX, nY
Local lMulta     := .F.
Local lDtMulta   := .F.
Local cPerMulta  := '0'
Local cDtMulta   := ''
Local nCorrecao  := 0
Local nJuros     := 0
Local nVlProv    := 0
Local nEmpAtliz  := 0 // Quantidade de elementos vazios do campo NW8_CDATAU -> Data Últ Atualizacao
Local nLenCodigo := Len(aCodigos)
Local aRetJA02Co := {} //18/07/2012 - SM-JURI049 - Variável para tratamento do Ponto de Entrada JA002CORR
Local lAnoMes    := (SuperGetMV('MV_JVLHIST',, '2') == '1')
Local aAnoMes    := {}
Local nCt
Local cJVlProv   := ""  //Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos
Local lAtuProvis := .F. //Controla se teve alterações no Processo ou Objetos
Local cTipoAss   := ""
Local aMsgErr    := {}
Local cMemoErr   := ""
Local nLenMsgErr := 0
Local cDataEnc   := ""
Local lAtualiza  := .F.
Local lAtuGaran  := .F.
Local nSucesso   := 0
Local cCodPro    := ''
Local lIntVal    := SuperGetMV('MV_JINTVAL',, '2') == '1'
Local lPrintEvol := GetSrvProfString("Trace","") == '1' // Define se terá conout da evolução da correção



Default lMsg        := .T.
Default lPesq       := .F.
Default aCamposV    := {}
Default aTabelas    := {}
Default cDataCorte  := DTOS(DATE())
Default lRecalculo  := .F.
Default lFiltraExtr := .F.
Default cFiltroExtr := ""
Default cCampoFilt  := ""
Default oMonitor    := Nil

	aAtualizar := JA002NW8(aTabelas,aCamposV)
	cDtCorte2 := cDataCorte //Bkp da data de corte, pois ela é alterada para histórico, mas é preciso usar seu valor original para o mês indicado nela
	nEmpAtliz := JA2VzioCpo(aAtualizar)

	If lPrintEvol
		Conout( "Quantidade de indices não preenchidos no campo NW8_CDATAU - Data Últ Atualização: " + ALLTRIM( str(nEmpAtliz)) )
		Conout( time() + " JURA002 - Total de Processos: " + alltrim(str(nLenCodigo)) )
	EndIf

	If lPesq .And. lExecuta
		If !ApMsgYesNo(STR0005)
			lExecuta := .F.
		EndIf
	EndIf

	If lExecuta

		If !Empty ( aAtualizar )

			If !Empty ( aCodigos )

				ProcRegua(nLenCodigo)

				If valType(oMonitor) == "J"
					oMonitor['O17_MIN'] := 0
					oMonitor['O17_MAX'] := nLenCodigo
				EndIf

				For nX:= 1 to nLenCodigo

					lAtuProvis := .F.
					cTipoAss   := JurGetDados("NSZ", 1, aCodigos[nX][2] + aCodigos[nX][1], "NSZ_TIPOAS")	//NSZ_FILIAL + NSZ_COD
					cJVlProv   := JGetParTpa(cTipoAss, "MV_JVLPROV", "1")

					IncProc(I18N( STR0012, { alltrim(str(nX)), alltrim(str(nLenCodigo)) })) //"Atualizando #1 de #2"

					If valType(oMonitor) == "J"
						oMonitor['O17_MIN']  := oMonitor['O17_MIN']+1
						oMonitor['O17_PERC'] := Round(oMonitor['O17_MIN']*100/oMonitor['O17_MAX'],0)
						J288GestRel(oMonitor)

						//Quando Finalizar, reseta o progresso
						If oMonitor['O17_MIN'] = nLenCodigo
							oMonitor['O17_MIN'] := 0
							oMonitor['O17_MAX'] := 0
						EndIf
					EndIf

					If lPrintEvol
						Conout( "------------------------------------------")
						Conout( time() + " JURA002 - Atualizando: " + alltrim( str( nX  ) ) + " de: " + alltrim(str(nLenCodigo))    )
						Conout( time() + " JURA002 - Cód do processo: " + aCodigos[nX][1] )
						Conout( "------------------------------------------")
					EndIf

					For nY := 1 to Len (aAtualizar)

						//Se o valor da Provisao vier dos Objetos não atualiza os campos do Processo Valor Provisão\Valor Envolvido
						If cJVlProv == "2" .And. AllTrim(aAtualizar[nY][4]) $ "NSZ_VAPROV|NSZ_VAENVO"
							Loop
						EndIf

						//Limpa o vetor que guarda os ano mes que devem ser corrigidos.
						aAnoMes := {}

						//16/07/2012 - Tânia - SM-JURI049 - Ponto de entrada para tratamento das correções não processadas.
						If Existblock("JA002CORR")
							If ValType(aRetJA02Co := ExecBlock("JA002CORR",.F.,.F.,{aAtualizar[nY],aCodigos[nX][1]})) != "A"
								Conout( "Retorno do Ponto de Entrada JA002CORR não é um Array")
								aRetJA02Co := {}

							EndIf

							If	Len(aRetJA02Co) > 0
								Conout( "------------------------------------------")
								Conout( time() + " JURA002 - Execução: JA002CORR: " )
								Conout( time() + " JURA002 - aAtualizar - Antes:  " + aToc(aAtualizar[nY]) )
								Conout( time() + " JURA002 - aAtualizar - Depois: " + aToc(aRetJA02Co) )
								Conout( "------------------------------------------")
								aAtualizar[nY] := aRetJA02Co
							EndIf
						EndIf

						aCampoCorr := JURSX9(aAtualizar[nY][1], 'NW7')
						lMulta     := .F.
						lDtMulta   := .F.
						nAtuMulta  := 0
						cMulAtu    := ''

						If !Empty( aCampoCorr )

							cQuery := "SELECT "+PrefixoCpo(aAtualizar[nY][1])+"_COD CODIGO, "+AllTrim(aAtualizar[nY][9])+" CORRECAO, "+CRLF
							cQuery += aAtualizar[nY][2]+" CAMPOVLR, "+aAtualizar[nY][3]+" CAMPODT "

							If !Empty(aAtualizar[nY][8])
								cQuery += ", "+aAtualizar[nY][8]+" CAMPOMULTA	"
								lMulta := .T.
							EndIf

							If !Empty(aAtualizar[nY][10])
								cQuery += ", "+aAtualizar[nY][10]+" DATA_MULTA "
								lDtMulta := .T.
							EndIf

							If PrefixoCpo(aAtualizar[nY][1]) == 'NT2'
								cQuery += ", "+PrefixoCpo(aAtualizar[nY][1])+"_MOVFIN MOV "
								cQuery += ", "+PrefixoCpo(aAtualizar[nY][1])+"_CAJURI "
								cQuery += ", "+PrefixoCpo(aAtualizar[nY][1])+"_INTFIN INTFIN "
							EndIf

							If PrefixoCpo(aAtualizar[nY][1]) == 'NSZ'
								cQuery += ", "+PrefixoCpo(aAtualizar[nY][1])+"_FILIAL FILIAL "
								cQuery += ", "+PrefixoCpo(aAtualizar[nY][1])+"_DTENCE "
							EndIf

							If !Empty(aAtualizar[nY][12]) .AND. !Empty(aAtualizar[nY][13])
								cQuery += ", "+aAtualizar[nY][12]+" CORMONET "
								cQuery += ", "+aAtualizar[nY][13]+" VALJUROS "
							EndIf

							If aAtualizar[nY][5] == '4'
								cQuery += ", "+aAtualizar[nY][6]+" CAMPOJUROS"
							EndIf

							cQuery += "  FROM "+RetSqlName(aAtualizar[nY][1])+ " "+aAtualizar[nY][1] + CRLF

							If PrefixoCpo(aAtualizar[nY][1]) == 'NSZ'

								cQuery += " WHERE "+PrefixoCpo(aAtualizar[nY][1])+"_FILIAL = '"+aCodigos[nX][2]+"'" + CRLF
								cQuery += "   AND "+PrefixoCpo(aAtualizar[nY][1])+".D_E_L_E_T_ = ' ' AND "

							Else

								cQuery += " WHERE "+PrefixoCpo(aAtualizar[nY][1])+"_FILIAL = '"+xFilial(aAtualizar[nY][1])+"'" + CRLF
								cQuery += "   AND "+PrefixoCpo(aAtualizar[nY][1])+".D_E_L_E_T_ = ' ' AND "

							EndIf

							If PrefixoCpo(aAtualizar[nY][1]) == 'NT2'
								cQuery += PrefixoCpo(aAtualizar[nY][1])+"_MOVFIN = '1' AND "
							EndIf

							If PrefixoCpo(aAtualizar[nY][1]) == 'NSZ'
								cCodigo := " NSZ_COD = '"+aCodigos[nX][1]+"'"
							Else
								cCodigo := +PrefixoCpo(aAtualizar[nY][1])+"_CAJURI = '"+aCodigos[nX][1]+"'"
							EndIf

							//Proteção para efetuar a alteração apenas quando necessário
							cQuery += " ((" + aAtualizar[nY][2] + " > 0 ) OR "
							cQuery += " ( " + aAtualizar[nY][2] + " = 0 AND " + aAtualizar[nY][4] + " <> 0 ) ) AND "
							cQuery += cCodigo
							If lFiltraExtr .And. Empty(cCampoFilt)
								cQuery += " AND "+PrefixoCpo(aAtualizar[nY][1])+"_CVERBA = '" + cFiltroExtr + "' "
							ElseIf lFiltraExtr .And. !Empty(cCampoFilt)
								cQuery += " AND "+PrefixoCpo(aAtualizar[nY][1])+ cCampoFilt +" = '" + cFiltroExtr + "' "
							EndIf

							// ChangeQuery removido por problemas de performance e por tratar-se de query no padrão ANSI
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

							While !(cAlias)->( EOF() )

								cDtMulta   := ''
								cFilAlias  := ''
								nAtuCorre  := 0
								nAtuJuros  := 0
								nAtuMulta  := 0
								cDataCorte := DTOS(DATE())
								cCod       := (cAlias)->CODIGO
								//Se o codigo do processo for o mesmo, não pega a data de encerramento e o valor de provisao novamente
								If cCodPro <> aCodigos[nX][1]
									cCodPro  := aCodigos[nX][1]
									cDataEnc := DTOS(JurGetDados("NSZ", 1, xFilial("NSZ") + cCodPro, "NSZ_DTENCE"))
									nVlProv  := JurGetDados("NSZ", 1, XFILIAL("NSZ") + cCodPro, "NSZ_VLPROV")
								EndIf

								If PrefixoCpo(aAtualizar[nY][1]) == 'NSZ'
									cFilAlias := (cAlias)->FILIAL
								EndIf

								cTabela   := PrefixoCpo(aAtualizar[nY][1])
								nCorrecao := aAtualizar[nY][12]
								nJuros    := aAtualizar[nY][13]

								If PrefixoCpo(aAtualizar[nY][1]) == 'NT2'
									cDataCorte := JA002DtCorte((cAlias)->CODIGO, (cAlias)->NT2_CAJURI)
								ElseIf (PrefixoCpo(aAtualizar[nY][1]) == 'NSZ') .And. !Empty((cAlias)->NSZ_DTENCE)
									cDataCorte := (cAlias)->NSZ_DTENCE
								ElseIf PrefixoCpo(aAtualizar[nY][1]) == 'NSY' .And. !Empty(cDataEnc)
									cDataCorte := cDataEnc
								EndIf

								cDtCorte2 := cDataCorte

								Do Case
								Case aAtualizar[nY][5] == '1'
									cDataJuros := DTOS(Posicione('NUQ', 2 , xFilial('NUQ') + aCodigos[nX][1] + '1', 'NUQ_DTDIST'))
								Case aAtualizar[nY][5] == '2'
									cDataJuros := DTOS(Posicione('NSZ', 1 , xFilial('NSZ') + aCodigos[nX][1] , 'NSZ_DTENTR'))
								Case aAtualizar[nY][5] == '3'
									cDataJuros := (cAlias)->CAMPODT
								Case aAtualizar[nY][5] == '4'
									cDataJuros := (cAlias)->CAMPOJUROS
								EndCase

								If Empty(cDataJuros)
									cDataJuros := cDataCorte
								EndIf

								cFormaCor := (cAlias)->CORRECAO

								//Se o cadastro não tiver forma de correção, utilizar o do processo
								If Empty( cFormaCor ) .And. !PrefixoCpo(aAtualizar[nY][1]) == 'NSZ' .And.;
										!(aAtualizar[nY][9] $ 'NSY_CFCOR1|NSY_CFCOR2|NSY_CFCORT|NSY_CFMUL2|NSY_CFMULT')

									cFormaCor := Posicione('NSZ', 1 , xFilial('NSZ') + aCodigos[nX][1] , 'NSZ_CFCORR')
									If PrefixoCpo(aAtualizar[nY][1]) == 'NT2'
										cFormaCor := ''
									EndIf
								EndIf

								If !ValType(cDataCorte) == 'C'
									cDataCorte := DTOS(cDataCorte)
									cDtCorte2 := cDataCorte
								EndIf

								If !Empty( cFormaCor ) .And. !Empty( (cAlias)->CAMPOVLR ) .And. !Empty( (cAlias)->CAMPODT )

									If lMulta
										cPerMulta := StrTran(((cAlias)->CAMPOMULTA), ',', '.')
									Else
										cPermulta := '0'
										nAtuMulta :=  0
									EndIf

									If lDtMulta
										cDtMulta := (cAlias)->DATA_MULTA
									EndIf

									If !Empty(aAtualizar[nY][11])
										cMulAtu	:= aAtualizar[nY][11]
									EndIf

									cDataBase := (cAlias)->CAMPODT

									//Valida se o campo de valor histórico está preenchido.
									If lAnoMes .And. !Empty(aAtualizar[nY][16]) .And. !Empty(cFormaCor)
										//Recebe todos os ano-mes que existem para o campo especificado com valores.
										aAnoMes := JA2LstAnoMes(LEFT(aAtualizar[nY][16],3), aAtualizar[nY][16], Stod(cDataBase), Stod(cDataCorte),(cAlias)->CODIGO)
										lAtualiza := .F.
									Else
										aAnoMes := { {AnoMes(SToD(cDataCorte)),0,.T.,0,0,0} }
									EndIf

									//Para cada ano-mes
									For nCt := 1 to len(aAnoMes)
										//Posição 2 do Array - Valor
										If (aAnoMes[nCt][2] == Nil .Or. aAnoMes[nCt][2] == 0 .Or. lRecalculo)
											If lAnoMes
												cDataCorte := Dtos(LastDate(Stod(aAnoMes[nCt][1]+"01"))) //Altera a data de corte para cada mês/ ano do histórico
												If AnoMes(StoD(cDataCorte)) == AnoMes(StoD(cDtCorte2))
													cDataCorte := cDtCorte2 //Retorna a data de corte original para o cálculo correto de juros
												EndIf
											EndIf

											nValor := JA002Valor( cFormaCor, (cAlias)->CAMPOVLR, (cAlias)->CAMPODT, cDataCorte, cDataJuros, cPerMulta, cDtMulta, lAnoMes, aAnoMes[nCt][1], ,@aMsgErr)

											aAnoMes[nCt][2] := nValor
											aAnoMes[nCt][4] := nAtuCorre
											aAnoMes[nCt][5] := nAtuJuros
											aAnoMes[nCt][6] := nAtuMulta

											If !lTemIndice

												aAnoMes[nCt][3] := .F.

												Conout( "------------------------------------------")
												ConOut( time() + " JURA002 - Return F	")
												ConOut( "Processo: " +  aCodigos[nX][1] 	)
												ConOut( "Valor Atualizao:   " + alltrim(nValor) )
												ConOut( "Forma de Correção: " + alltrim(cFormaCor) 	)
												Conout( "------------------------------------------")

											Else
												//marca que o valor deve ser atualizado na tabela
												aAnoMes[nCt][3] := .T.
												lAtualiza       := .T.
											EndIf

											lTemIndice := .T.

										EndIf
									Next

								Else
									If Empty( cFormaCor ) .And. Empty( (cAlias)->CAMPOVLR ) .And. Empty( (cAlias)->CAMPODT )
										nValor := 0
									Else
										nValor := (cAlias)->CAMPOVLR
										lAtualiza := .T.
										lAnoMes := .F.
									EndIf
								EndIf

								//Se guarda histórico, mas não tem registros a serem atualizados pela opção "Correção Valores"
								If lAnoMes .And. !lAtualiza
									lRet := .F.
								Else
									If (Len(aAnoMes)>0 .Or. (!lAnoMes))

										If aAtualizar[nY][1] $ "NSZ|NSY"
											lAtuProvis := .T.
										EndIf

										cSQL := "UPDATE " + RetSqlName(aAtualizar[nY][1])+CRLF
										cSQL += " SET " + aAtualizar[nY][4]+" = "+AllTrim(Str(nValor))+CRLF

										//<- Alteração do produto padrão para atendimento a PNA  ->
										If !Empty(Alltrim(aAtualizar[nY][7]))
											cSQL += ", "+ aAtualizar[nY][7]+" = '"+DTOS(DATE())+"'"
										EndIf

										If !EMPTY(aAtualizar[nY][12]) .AND. !EMPTY(aAtualizar[nY][13])

											If (cAlias)->CAMPODT > cDataCorte .And. nAtuCorre < 0
												nAtuCorre := 0
											EndIf

											If nAtuJuros < 0
												nAtuJuros := 0
											EndIf

											cSQL += ", "+ aAtualizar[nY][12]+" = '"+Alltrim(str(nAtuCorre))+"'"+CRLF
											cSQL += ", "+ aAtualizar[nY][13]+" = '"+Alltrim(str(nAtuJuros))+"'"
										EndIf

										If !Empty(aAtualizar[nY][11])

											If nAtuMulta > 0

												cSQL +=	", "+ aAtualizar[nY][11]+" = '"+Alltrim(str(nAtuMulta))+"'"

											EndIf

										EndIf

										cSQL += " WHERE " + cCodigo

										If At('CAJURI',	cCodigo) > 0
											cSQL += " AND "+PrefixoCpo(aAtualizar[nY][1])+"_COD ='"+(cAlias)->CODIGO+"'"
										EndIf
										If PrefixoCpo(aAtualizar[nY][1]) == 'NSZ'
											//Filiais
											cSQL += " AND "+PrefixoCpo(aAtualizar[nY][1])+"_FILIAL ='"+cFilAlias +"'"
										Else
											//Filiais
											cSQL += " AND "+PrefixoCpo(aAtualizar[nY][1])+"_FILIAL ='"+xFilial(PrefixoCpo(aAtualizar[nY][1])) +"'"
										Endif

										If nEmpAtliz == 0 .AND. tcSQLExec(cSQL) == 0
											nValor := 0
										Else
											lRet := .F.

											If nEmpAtliz > 0

												// "Atenção: É necessário que o campo " + RetTitle("NW8_CDATAU")+ " esteja corretamente preenchido no 'Cadastro de Valores Atualizaveis' para execução desta rotina!"
												JurMsgErro(STR0010 + RetTitle("NW8_CDATAU")+ STR0011)

												Conout( "----------------------------------------------------")
												Conout( "Quantidade de elementos nao preenchidos no campo NW8_CDATAU - Data Ult Atualizacao: " + ALLTRIM( str(nEmpAtliz)))
												Conout( "------------------------------------------")
											Else
												JurMsgErro(STR0007)
												Conout( "------------------------------------------")
												Conout( time() + " JURA002 - cSQL Error: " )
												Conout( STR0007 )
												Conout( tcsqlerror() )
												Conout( "------------------------------------------")
											EndIf

											RestArea(aArea)
											Return lRet
										End

										If lErroInd
											lRet := .F.
											Conout( "------------------------------------------")
											Conout( time() + " JURA002 - ERROR INDICE")
											ConOut( "Processo: " + aCodigos[nX][1] 	)
											ConOut( "Valor Atualizao:   " + alltrim(nValor) )
											ConOut( "Forma de Correção: " + alltrim(cFormaCor) 	)
											Conout( "------------------------------------------")
											RestArea(aArea)
											Return lRet
										EndIf
									EndIf
									//valida se o parâmetro de histórico está habilitado.
									If lAnoMes
										JA2GravaHist(aAnoMes,LEFT(aAtualizar[nY][16],3),(cAlias)->CODIGO,aAtualizar[nY][16],cFormaCor,aAtualizar[nY][9],aAtualizar[nY][1],aAtualizar[nY][2])
									EndIf
								EndIf

								If lRet

									If lIntVal .AND. PrefixoCpo(aAtualizar[nY][1]) == 'NT2' .AND. (cAlias)->MOV == '1' .AND.;
											!EMPTY(ALLTRIM((cAlias)->CORRECAO)) .AND. (cAlias)->INTFIN <> '2' .AND.;
											( IsInCallStack("JURA098") .OR. IsInCallStack("JURA112") )

										If (cAlias)->CAMPOVLR <> 0

											aRetI     := JAGetGrpAp(aCodigos[nX][1], (cAlias)->CODIGO,, 2, lRetI)
											lRetI     := aRetI[1]
											cGrupoApr := aRetI[2]

											If lRetI
												lRetI := JurHisCont(aCodigos[nX][1], (cAlias)->CODIGO, SToD((cAlias)->CAMPODT), (cAlias)->CAMPOVLR	, '1', '2', 'NT2',3, cGrupoApr)
											EndIf

										EndIf
										If lRetI .And. nAtuCorre <> 0
											lRetI := JurHisCont(aCodigos[nX][1], (cAlias)->CODIGO, SToD((cAlias)->CAMPODT), nAtuCorre, '2', '2', 'NT2', 3)
										EndIf
										If lRetI .And. nAtuJuros <> 0
											lRetI := JurHisCont(aCodigos[nX][1], (cAlias)->CODIGO, SToD((cAlias)->CAMPODT), nAtuJuros, '3', '2', 'NT2', 3)
										EndIf
									ElseIf PrefixoCpo(aAtualizar[nY][1]) == 'NSZ' .AND. nVlProv > 0 .AND. (IsInCallStack("JURA162") .OR.;
											IsInCallStack("JURA112")) .AND. !EMPTY(aAtualizar[nY][12]) .AND. !EMPTY(aAtualizar[nY][13])

										If lRetI .And. nVlProv <> 0
											lRetI := JurHisCont(aCodigos[nX][1],, SToD((cAlias)->CAMPODT), nVlProv		, '1', '1', 'NSZ',3)
										EndIf
										If lRetI .And. nAtuCorre <> 0
											lRetI := JurHisCont(aCodigos[nX][1],, SToD((cAlias)->CAMPODT), nAtuCorre 	, '2', '1', 'NSZ',3)
										EndIf
										If lRetI .And. nAtuJuros <> 0
											lRetI := JurHisCont(aCodigos[nX][1],, SToD((cAlias)->CAMPODT), nAtuJuros	, '3', '1', 'NSZ',3)
										EndIf
									EndIf
								EndIf

								//18/07/2012 - Tania - SM-JURI049 - Inclusão de Ponto de Entrada para alterar valor corrigido
								If Existblock("JA002CSQL")
									ExecBlock("JA002CSQL",.F.,.F.,{aAtualizar[nY],aCodigos[nX][1]})
								EndIf

								(cAlias)->( dbSkip() )
							End
							(cAlias)->( dbcloseArea() )

						Else
							lRet := .F.
							JurMsgErro( I18n(STR0013, {aAtualizar[nY][1]} ) )	//"A tabela #1 não tem relacionamento com a tabela NW7 no SX9."
						EndIf

						If lRet .And. PrefixoCpo(aAtualizar[nY][1]) == 'NT2'
							lAtuGaran := .T.
						EndIf
					Next

					//Atualiza o valores de Provisão e Redutores
					If lRet .And. lAtuProvis
						AtuVlrNsz(aCodigos[nX][2], aCodigos[nX][1], cJVlProv )
						If FWAliasIndic("O0W") .And. !IsInCallStack("J270Commit")
							JAtuValO0W(aCodigos[nX][1])
						EndIf
					EndIf

					If lRet
						nSucesso ++
					EndIf
				Next
			Else
				lRet := .F.
				JurMsgErro(STR0001)
			EndIf

			If lRet
				JA094SAtuSAPE(aCodigos)
			EndIf

			If lAtuGaran//se em algum processo houve atualização de garantia, a função que atualiza o saldo é chamada
				J98AtSalJz(aCodigos,@aMsgErr, oMonitor)
			EndIf

		ElseIf lMsg
			lRet := .F.
			JurMsgErro(STR0003) //"Não há valores atualizáveis configurados, verificar"
		EndIf

		If lRet .And. lMsg .And. Empty(aMsgErr)
			If nSucesso > 0
				MsgAlert(cValToChar(nSucesso) + STR0017 ) //" registros tiveram os valores atualizados com sucesso. "
			Else
				MsgAlert(STR0002)//"Correção de valores realizada com sucesso"
			EndIf
		ElseIf lRet .And. lMsg

			For nLenMsgErr := 1 to Len (aMsgErr)
				cMemoErr := cMemoErr + CRLF + aMsgErr[nLenMsgErr]
			Next

			cMemoErr := STR0008 + CRLF + cMemoErr
			MsgAlert(cMemoErr)
		EndIf

	EndIf

	RestArea(aArea)
	lTemIndice := .T.

	aSize(aCampoCorr,0)
	aSize(aRetI,0)
	aSize(aRetJA02Co,0)
	aSize(aAnoMes,0)
	aSize(aCamposV,0)
	aSize(aTabelas,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002NW8
Monta o array com os campos de valores atualizáveis

@param aTabelas    Array de tabelas para filtrar os valores atualizáveis
@param aCamposV    Array de campos para filtrar os valores atualizáveis

@return aCampos    Array de campos de valores

@author Juliana Iwayama Velho
@since 26/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA002NW8(aTabelas,aCamposV)
	Local cQuery  := ""
	Local cAlias  := GetNextAlias()
	Local cFiltro := 'T'
	Local aArea   := GetArea()
	Local aCampos := {}
	Local nAte    := 0
	Local nI

	Default aCamposV := {}

	If !Empty(aTabelas)
		nAte    := Len(aTabelas)
	ElseIf !Empty(aCamposV)
		nAte    := Len(aCamposV)
		cFiltro := 'C'
	EndIf

	For nI:= 1 to nAte

		cQuery := "SELECT NW8_CTABEL TABELA ,NW8_CCAMPO CAMPO, NW8_CDATA CDATA, NW8_CCMPAT CAMPOAT, "+ CRLF
		cQuery += "  NW8_DJUROS TIPOJUROS, NW8_CDATAJ DTJUROS,NW8_CDATAU DTULTIMA, NW8_CMULTA PERMULTA, "+ CRLF
		cQuery += "  NW8_CFORMA FORMA, NW8_CDTMUL DATA_MULTA, NW8_MULATU MULTAATU, NW8_CCORRM CORMONET, NW8_CJUROS VALJUROS, "+ CRLF
		If NW8->(FieldPos('NW8_CAMPH')) > 0
			cQuery += "  NW8_CTOTOR TOTAL_ORI, NW8_CTOTAT TOTAL_ATU, NW8_CAMPH FROM "+RetSqlName("NW8")+" NW8 "+ CRLF
		Else
			cQuery += "  NW8_CTOTOR TOTAL_ORI, NW8_CTOTAT TOTAL_ATU FROM "+RetSqlName("NW8")+" NW8 "+ CRLF
		EndIf
		cQuery += " WHERE NW8_FILIAL = '"+xFilial("NW8")+"' AND NW8.D_E_L_E_T_ = ' ' "

		If cFiltro == 'T'
			cQuery += " AND NW8_CTABEL ='"+aTabelas[nI]+"'"
		ElseIf cFiltro == 'C'
			cQuery += " AND NW8_CCAMPO ='"+aCamposV[nI]+"'"
		EndIf

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		(cAlias)->( dbGoTop() )

		While !(cAlias)->( EOF() )
			aAdd( aCampos,{ (cAlias)->TABELA,;
				AllTrim( (cAlias)->CAMPO ),;
				AllTrim( (cAlias)->CDATA ),;
				(cAlias)->CAMPOAT,;
				(cAlias)->TIPOJUROS,;
				(cAlias)->DTJUROS,;
				(cAlias)->DTULTIMA,;
				(cAlias)->PERMULTA,;
				(cAlias)->FORMA,;
				(cAlias)->DATA_MULTA,;
				(cAlias)->MULTAATU,;
				(cAlias)->CORMONET,;
				(cAlias)->VALJUROS,;
				(cAlias)->TOTAL_ORI,;
				(cAlias)->TOTAL_ATU,;
				IIf((NW8->(FieldPos('NW8_CAMPH')) > 0), (cAlias)->NW8_CAMPH, "") })

			(cAlias)->( dbSkip() )

		End

		(cAlias)->( dbcloseArea() )

	Next

	RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VInd
Retorna o valor do ìndice a partir de período e código. Verifica até
2 meses anteriores no cadastro, caso contrário, alertar o usuário
para verificar cadastro

@param cIndice  	Código do Índice
@param cDt    		Data
@param cAnoMes    	Ano-Mes do cálculo
@param lAnoMes    	Variável que indica se a preferência de histórico está ativa ou não.
@param cDtIni    	Variável que indica se existe um intervalo de datas definido, assim é retornado um array com todos os valores ao invés de um único valor

@return nValorInd   Valor do Índice

@author Juliana Iwayama Velho
@since  03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VInd(cIndice,cDt, cAnoMes, lAnoMes, lMsg, cDtIni, aMsgErr)
	Local cQuery    := ""
	Local cAlias    := GetNextAlias()
	Local cDescInd  := ''
	Local aArea     := GetArea()
	Local aAreaNW5  := NW5->( GetArea() )
	Local aAreaNW6  := NW6->( GetArea() )
	Local nAno      := Year(STOD(cDt))
	Local nMes      := Month(STOD(cDt))
	Local cData     := StrZero(nAno,4) + StrZero(nMes,2) +'01'
	Local cNvData   := cData
	Local fValorInd := DEC_CREATE("0",64,18)
	Local lAchou    := .F.
	Local aRet      := {} //retorno múltiplo, quando o parâmetro cDtIni é informado
	Local lIgual    := .F. //Valida se a data é igual.

	Default cAnoMes := AnoMes(STOD(cDt))
	Default lAnoMes := (SuperGetMV('MV_JVLHIST',, '2') == '1')
	Default lMsg    := .T.
	Default cDtIni  := ""
	Default aMsgErr := {}

	//Verifica se o tipo do indice é diario
	If Posicione('NW5', 1 , xFilial('NW5') + cIndice , 'NW5_TIPO') == "1"
		cNvData := cDt
	EndIf

	lIgual := (LEFT(cDtIni,6) == LEFT(cNvData,6))

	If !lIgual

		//Consulta ja trazendo últimos 3 meses
		cQuery := "SELECT NW6_PVALOR VALOR, NW6_DTINDI AS DATA FROM "+RetSqlName("NW6")+" NW6 "
		cQuery += "WHERE NW6_FILIAL = '"+xFilial("NW6")+"' AND NW6.D_E_L_E_T_ = ' ' "
		If Empty(cDtIni)
			//alterada a query para trazer de uma vez os três meses de não atualização permitidos.
			cQuery += "AND NW6_CINDIC ='"+cIndice+"' AND NW6_DTINDI BETWEEN '"+dtos(MonthSub(stod(cNvData), 3)) +"' AND '"+cNvData+"'
		Else
			cDtIni := LEFT(cDtIni,6) + '01'
			cQuery += "AND NW6_CINDIC ='"+cIndice+"' AND NW6_DTINDI BETWEEN '"+cDtIni+"' AND '"+cNvData+"'
		EndIf
		//ordenado decrescente para dar preferência ao índice mais atual
		cQuery += " ORDER BY NW6_DTINDI DESC"

		// ChangeQuery removido devido a questões de performance e considerando que a query é padrão ANSI
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		//valida se a query retornou dados, se a data é atual ou pelo menos de até 3 meses atrás ou se existe um intervalo de datas e por isso deve alimentar o array
		While !(cAlias)->( EOF() ) .And. ((cNvData == (cAlias)->DATA .Or. dtos(MonthSub(stod(cNvData), 3)) <= (cAlias)->DATA) .Or. (lAchou .And. !Empty(cDtIni)))
			fValorInd := DEC_CREATE((StrTran(((cAlias)->VALOR), ',', '.')),64,18)
			lAchou    := .T.
			If !Empty(cDtIni)
				//se existe um intervalo de datas, ele vai incluindo no array para retornar mais de um resultado.
				aAdd(aRet,{JSToFormat((cAlias)->DATA,'YYYYMM'),fValorInd})
				(cAlias)->( dbSkip() )
			Else

				//se não for um intervalo de datas, sai da rotina e retorna só um valor.
				Exit
			EndIf
		End

		(cAlias)->( dbcloseArea() )

	EndIf

	If !lAchou
		fValorInd := DEC_CREATE("0",64,18)
		cDescInd  := Posicione('NW5', 1 , xFilial('NW5') + cIndice , 'NW5_DESC')

		If lMsg .And. !lIgual

			If ( aScan( aMsgErr , {  |x| (STR0006 + cDescInd ) $ x } ) == 0 )
				aAdd ( aMsgErr, STR0006 + cDescInd + " : " + cValToChar(stod(cDt)) )
			EndIf
		EndIf

		lTemIndice:= lAchou .And. !lIgual

		If !Empty(cDtIni)
			aAdd(aRet,{JSToFormat(cNvData,'YYYYMM'),fValorInd})
		EndIf

	EndIf

	RestArea(aAreaNW6)
	RestArea(aAreaNW5)
	RestArea(aArea)

Return Iif(!Empty(cDtIni),aRet,fValorInd)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VPInd
Retorna o valor do índice a partir de período e código. Verifica até
2 meses anteriores no cadastro, caso contrário, alertar o usuário
para verificar cadastro

@param cIndice      Código do índice
@param cDt          Data
@param cSubMes      Quantidade de meses a adicionar ou subtrair de determinada data
@param cAnoMes      Data de corte para busca de índice
@param lAnoMes      Define se o histórico deve ser gravado
@param lMsg         Define se deve ser exibida mensagem em tela
@return nValorInd   Valor do índice
@author Clóvis Eduardo Teixeira
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VPInd(cIndice,cDt,cSubMes, cAnoMes, lAnoMes, lMsg)
	Local aArea     := GetArea()
	Local cAlias    := ''
	Local cQuery    := ""
	Local cDescInd  := ''
	Local nI        := 1
	Local nJ        := 0
	Local nValorInd := 0
	Local fValorInd := DEC_CREATE("0",64,18)
	Local lAchou    := .F.
	Local nAno      := 0
	Local nMes      := 0
	Local cData     := ''
	Local cNvData   := ''

	Default cAnoMes := AnoMes(STOD(cDt))
	Default lAnoMes := (SuperGetMV('MV_JVLHIST',, '2') == '1')

	cDt     := JurDtAdd(cDt, 'M', Val(cSubMes))
	nAno    := Year(STOD(cDt))
	nMes    := Month(STOD(cDt))
	cData   := StrZero(nAno,4) + StrZero(nMes,2) +'01'
	cNvData := cData

	While nI <= 3

		cQuery := "SELECT NW6_PVALOR VALOR FROM "+RetSqlName("NW6")+" NW6 "
		cQuery += " WHERE NW6_FILIAL = '"+xFilial("NW6")+"' AND NW6.D_E_L_E_T_ = ' '"
		cQuery += "   AND NW6_CINDIC ='"+cIndice+"' AND NW6_DTINDI ='"+cNvData+"'"
		// ChangeQuery removido devido a questões de performance e considerando que a query é padrão ANSI

		cAlias := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		(cAlias)->( dbGoTop() )

		If (cAlias)->( EOF() )
			nJ := nJ+1
			If nI < 3
				cNvData  := JurCalcRef( AllTrim( StrZero(nAno,4) )+ AllTrim( StrZero(nMes,2) ), nJ, 2 ) +'01'
			EndIf
		Else
			nValorInd := Val((cAlias)->VALOR)

			If !(cIndice $ "06/10/18/19/23/27") //Para este indices nao deve ocorrer divisao de troca de moeda pois o indice da planilha ja tem divisao de valores

				nValorInd := ConvMoeda(cDt, nValorInd)

			Endif

			fValorInd := DEC_CREATE((StrTran(CVALTOCHAR((nValorInd)), ',', '.')),64,18)

			lAchou    := .T.
			(cAlias)->( dbcloseArea() )
			Exit
		EndIf

		(cAlias)->( dbcloseArea() )
		nI := nI+1
	End

	If !lAchou
		fValorInd := DEC_CREATE("0",64,18)
		cDescInd  := Posicione('NW5', 1 , xFilial('NW5') + cIndice , 'NW5_DESC')

		If lTemIndice .And. lMsg
			JurMsgErro(STR0006 + cDescInd + " : " + cValToChar(stod(cDt)) )
		EndIf


		lTemIndice:= lAchou
	EndIf

	RestArea(aArea)

Return fValorInd
//-------------------------------------------------------------------
/*/{Protheus.doc} JA002Valor
Calcula o valor atualizado

@param cFCorrecao  	Código da forma de correção
@param nValor    	Valor a ser corrigido
@param cDataIn    	Data inicial de atualização
@param cDataCorte   Data limite de atualização
@param cDataCorte   Data de juros da atualização
@param aValores     Array com valores de atualização
					[1] Correção Monetária
					[2] Juros
@param lClear       Limpa as variáveis nAtuJuros e nAtuCorre

@return nValorAt    Valor atualizado

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA002Valor(cFCorrecao,nValor,cDataIn,cDataCorte,cDataJuros,nVlrMulta, cDtMulta, lAnoMes, cAnoMes, lMsg,aMsgErr, aValores, lClear)
Local aArea     := GetArea()
Local cFormula  := ''
Local cFormPart := ''
Local cValorTemp:= ''
Local nValorAt  := nValor
Local nTam      := 0
Local nValorTemp:= 0
Local nPosLeit  := 1
Local nPosIni   := nPosLeit
Local nPosFim   := 0
Local nParent   := 0
Local aParam    := {}

Default nVlrMulta  := '0'
Default cDtMulta   := ''
Default aMsgErr    := {}
Default cDataCorte := DTOS(Date())
Default aValores   := {0,0}
Default lClear     := .F.

	If lClear
		nAtuJuros := 0
		nAtuCorre := 0
	EndIf

	If cDataCorte > cDataIn

		If Empty(cDataBase)
			cDataBase := cDataIn
		EndIf
		
		nAtuJuros := 0

		If nVlrMulta <> '0'
			nVlrMulta := AllTrim(nVlrMulta)
		EndIf

		cFormula := JA002SubRN( JA002NW7(cFCorrecao) )
		cFormula := StrTran(cFormula,' ','')
		cFormula := StrTran(cFormula,Chr(13)+ Chr(10),'')
		cFormula := StrTran(cFormula,'#VALOR'  ,AllTrim(Str(nValor)))
		cFormula := StrTran(cFormula,'#DTINI'  ,Chr(39)+cDataIn+ Chr(39))
		cFormula := StrTran(cFormula,'#DTFIM'  ,Chr(39)+cDataCorte+ Chr(39))
		cFormula := StrTran(cFormula,'#DTJUROS',Chr(39)+cDataJuros+ Chr(39))
		cFormula := StrTran(cFormula,'#DTATUAL',Chr(39)+DTOS(DATE())+ Chr(39))
		cFormula := StrTran(cFormula,Chr(39)+ Chr(39),Chr(39))
		cFormula := StrTran(cFormula,'#VLRMULTA',Chr(39)+nVlrMulta+ Chr(39))

		If !Empty(cDtMulta)
			cFormula := StrTran(cFormula,'#DTMULTA',Chr(39)+cDtMulta+ Chr(39))
		EndIf

		nTam   := Len(cFormula)

		While nPosLeit <= nTam

			If (SUBSTR(cFormula,nPosLeit,12)) = 'FN_QTDEMESES'
				nAtuJuros := 0

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit +13

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				nValorTemp := Val(JA002QtMes(cFormPart))
				cFormula   := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,11)) = 'FN_QTDEDIAS'
				nAtuJuros := 0

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit +12

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim   := nPosLeit - nPosIni + 1
				cFormPart := SUBSTR(cFormula,nPosIni,nPosFim)

				nValorTemp:= Val(JA002QtDia(cFormPart))

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,14)) = 'FN_VALORINDICE'
				nAtuCorre := 0

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit +15

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				nValorTemp:= Val(JA002VVInd(cFormPart,cAnoMes, lMsg,@aMsgErr,cDataCorte))

				If cIndFCor == "05"
					nAtuJuros := (nValorTemp * nValor)
				ElseIf cIndFCor == "28"
					nAtuJuros := (nValorTemp * nValor)
				Else
					nAtuCorre := (nValorTemp * nValor) - ConvMoeda(cDataBase, nValor)
				EndIf

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,13)) = 'FN_INDICEPLUS'

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit +14

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				nValorTemp:= Val(JA002VVPInd(cFormPart,cAnoMes, lMsg,@aMsgErr,cDataCorte))

				If cIndFCor == "06"
					If JSToFormat(cDataBase,'YYYYMM') <= '199406'
						nAtuCorre := (nValorTemp * nValor)
					Else
						nAtuCorre := (nValorTemp * nValor)	- nValor
					EndIf
					//Solicitacao da Juliana Rocha para a correcao da SELIC apareca no valor de Juros
				ElseIf cIndFCor $ '05|28'
					nAtuJuros := (nValorTemp * nValor)
				Else
					nAtuCorre := (nValorTemp * nValor) - ConvMoeda(cDataBase, nValor)
				EndIf

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,11)) = 'FN_SE_VALOR' .Or. (SUBSTR(cFormula,nPosLeit,15)) = 'FN_SE_TEXTO'
				nAtuCorre := 0
				nAtuJuros := 0

				cFuncao  := SUBSTR(cFormula,nPosLeit,11)
				nParent  := 0
				nPosIni  := nPosLeit
				nPosLeit := nPosLeit + 11
				cFormPart:= ''

				While (nPosLeit <= nTam)
					If ((SUBSTR(cFormula,nPosLeit,1)) = '(')
						nParent := nParent + 1
						cFormPart := cFormPart+'+'+Alltrim( Str(nParent) )
					ElseIf ((SUBSTR(cFormula,nPosLeit,1)) = ')')
						nParent := nParent - 1
						cFormPart := cFormPart+'-'+Alltrim( Str(nParent) )
					EndIf

					If nParent == 0
						nPosFim   := nPosLeit - nPosIni - 12
						cFormPart := (SUBSTR(cFormula,nPosIni+12,nPosFim))

						cValorTemp:= JA002Decod(cFormPart,cFuncao+'(',@aMsgErr)

						If Empty( cValorTemp)
							cValorTemp := 0
						EndIf

						If !ValType(cValorTemp) == 'C'
							cFormula  := StrTran(cFormula, ''+cFuncao+'('+cFormPart+')', AllTrim( Str( cValorTemp ) ) )
						Else
							cFormula  := StrTran(cFormula, ''+cFuncao+'('+cFormPart+')', cValorTemp )
						EndIf

						nTam     := Len(cFormula)
						cFormPart:= ''
						nPosLeit := -1
						nPosIni  := nPosLeit
						Exit
					EndIf
					nPosLeit := nPosLeit + 1
				End
			ElseIf (SUBSTR(cFormula,nPosLeit,10)) = 'FN_MESAMES'
				nAtuCorre := 0
				nAtuJuros := 0

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit + 11

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				nValorTemp:= Val(JA002VTmes(cFormPart,@aMsgErr))

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit
			ElseIf (SUBSTR(cFormula,nPosLeit,9)) = 'FN_PROV26' .Or. (SUBSTR(cFormula,nPosLeit,9)) = 'FN_JMISTO'
				nAtuCorre := 0
				nAtuJuros := 0

				cFuncao  := SUBSTR(cFormula,nPosLeit,9)
				nPosIni  := nPosLeit
				nPosLeit := nPosLeit + 10

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				If cFuncao = 'FN_PROV26'
					nValorTemp:= Val(JA002VPR26(cFormPart,cAnoMes, lMsg, @aMsgErr))
				ElseIf cFuncao = 'FN_JMISTO'
					nValorTemp:= Val(JA002VJMTO(cFormPart))
				EndIf

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,11)) = 'FN_COMPOSTO'
				nAtuCorre := 0
				nAtuJuros := 0

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit + 11

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)
				aParam := StrToKArr(cFormPart, ',')

				If NWS->( FieldPos("NWS_TIPJUR") ) > 0 .And. At("#ANTIGA", cFormPart) == 0
					If !(Len(aParam)>5)
						nValorTemp:= Val(JA002VPRCOM(cFormPart,cAnoMes,,@aMsgErr,cFCorrecao))
					Else
						If ( aScan( aMsgErr , {  |x|  x == (I18N(STR0016, {SUBSTR(cFormula,nPosIni,11),cFCorrecao})) } ) == 0 )
							aAdd ( aMsgErr, I18N(STR0016, {SUBSTR(cFormula,nPosIni,11),cFCorrecao}) )
						Endif
					EndIf
				Else//efetua a correção da forma antiga - Correção paliativa
					nValorTemp:= Val(JA02VCOMAnt(cFormPart,cAnoMes,,@aMsgErr))
				EndIF

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,11)) = 'FN_VALORPRO' .Or. (SUBSTR(cFormula,nPosLeit,11)) = 'FN_VALORIND';
					.Or. (SUBSTR(cFormula,nPosLeit,11)) = 'FN_VALORCGS' .Or. (SUBSTR(cFormula,nPosLeit,11)) = 'FN_VALORPTJ';
					.Or. (SUBSTR(cFormula,nPosLeit,11)) = 'FN_VALORASP'

				cFuncao  := SUBSTR(cFormula,nPosLeit,11)
				nPosIni  := nPosLeit
				nPosLeit := nPosLeit + 11

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				aParam := StrToKArr(cFormPart, ',')

				If cFuncao == 'FN_VALORPRO'

					If NWS->( FieldPos("NWS_TIPJUR") ) > 0 .And. At("#ANTIGA", cFormPart) == 0
						If !(Len(aParam)> 6)
							nValorTemp:= Val(JA002VLPRO(cFormPart, cAnoMes, lMsg,@aMsgErr,cFCorrecao))
						Else
							If ( aScan( aMsgErr , {  |x|  x == (I18N(STR0016, {cFuncao,cFCorrecao})) } ) == 0 )
								aAdd ( aMsgErr, I18N(STR0016, {cFuncao,cFCorrecao}) )
							Endif
						EndIf
					Else//efetua a correção da forma antiga - Correção paliativa
						nValorTemp:= Val(JA002VPROR(cFormPart, cAnoMes, lMsg,@aMsgErr))
					EndIF

				ElseIf cFuncao == 'FN_VALORIND'
					nValorTemp:= Val(JA002VIndT(cFormPart, cAnoMes, lMsg,@aMsgErr))
				ElseIf cFuncao == 'FN_VALORCGS'
					nValorTemp:= Val(JA002VCGSel(cFormPart, cAnoMes, lMsg,@aMsgErr))
				ElseIf cFuncao == 'FN_VALORPTJ'

					If NWS->( FieldPos("NWS_TIPJUR") ) > 0 .And. At("#ANTIGA", cFormPart) == 0
						If (Len(aParam)>=5)
							nValorTemp:= Val(JA002VTJPro(cFormPart, cAnoMes, lMsg,@aMsgErr,cFCorrecao))
						Else
							If ( aScan( aMsgErr , {  |x|  x == (I18N(STR0016, {cFuncao,cFCorrecao})) } ) == 0 )
								aAdd ( aMsgErr, I18N(STR0016, {cFuncao,cFCorrecao}) )
							Endif
						EndIf
					Else//efetua a correção da forma antiga - Correção paliativa
						nValorTemp := Val(J02AVTJAnt(cFormula, cAnoMes, lMsg,@aMsgErr))
					EndIf

				ElseIf cFuncao == 'FN_VALORASP'
					nValorTemp:= Val(JA002VAutSP(cFormPart, cAnoMes, lMsg,@aMsgErr))
				EndIf

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,10)) = 'FN_VALORAF'
				nAtuCorre := 0
				nAtuJuros := 0

				nPosIni  := nPosLeit
				nPosLeit := nPosLeit + 10

				While (nPosLeit <= nTam) .And. ((SUBSTR(cFormula,nPosLeit,1)) <> ')')
					nPosLeit := nPosLeit + 1
				End

				nPosFim  := nPosLeit - nPosIni + 1
				cFormPart:= SUBSTR(cFormula,nPosIni,nPosFim)

				nValorTemp:= Val(JA002VPRAF(cFormPart, cAnoMes, lMsg,@aMsgErr))

				cFormula  := StrTran(cFormula, cFormPart, AllTrim( Str(nValorTemp) ) )

				nTam     := Len(cFormula)
				cFormPart:= ''
				nPosLeit := -1
				nPosIni  := nPosLeit

			ElseIf (SUBSTR(cFormula,nPosLeit,1)) = '('
				nPosIni := nPosLeit
			ElseIf (SUBSTR(cFormula,nPosLeit,1)) = ')'
				nPosFim := nPosLeit
			EndIf

			nPosLeit := nPosLeit + 1

		End

		If nValorAt <> -1
			cFormula := StrTran(cFormula,chr(39),'')
			If cFormula <> '0'
				nValorAt := JA002Frmla(cFormula)
				//Corrige o nAtuCorre se for expressão matemática
				If At('*',cFormula) > 0 .Or. At('+',cFormula) > 0 .Or. At('-',cFormula) > 0 .Or. At('/',cFormula) > 0
					nAtuCorre := (nValorAt - nValor) - nAtuJuros
				EndIF
			EndIf
		ElseIf nValorAt == -1 //ch:5427
			nValorAt :=	0
		EndIf

	EndIf

	RestArea(aArea)
	aValores[1] := nAtuCorre
	aValores[2] := nAtuJuros
	
Return nValorAt

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002NW7
Retorna a fórmula da forma de correção

@param cCodigo  	Código da forma de correção
@return cFormula    Fórmula

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002NW7(cCodigo)
//Local cQuery   := ""
//Local cAlias   := GetNextAlias()
	Local aArea    := GetArea()
	Local aAreaNW7 := NW7->( GetArea() )
	Local cFormula := ''

	NW7->(DBSetOrder(1))
	If NW7->(DBSeek(xFILIAL('NW7') + cCodigo))
		cFormula := AllTrim( NW7->NW7_FORMUL )
	EndIf

RestArea(aAreaNW7)
RestArea(aArea)

Return cFormula

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002SubRN
Substitui as fórmulas de outras formas de correção na fórmula

@param cFormula    Fórmula
@return cCompleta  Fórmula completa

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002SubRN(cFormula)
	Local aArea     := GetArea()
	Local cCompleta := ''
	Local cParam1   := ''
	Local cParam2   := ''
	Local nPosIni   := 0
	Local nPosFim   := 0

	While At('{', cFormula) > 0
		nPosIni  := At('{', cFormula)
		nPosFim  := At('}', cFormula)
		cParam1  := SubStr(@cFormula,nPosIni+1,nPosFim-nPosIni-1)
		cParam2  := JA002NW7(cParam1)
		cFormula := StrTran(cFormula,'{'+cParam1+'}','('+LTrim(RTrim(cParam2))+')')
	End

	cCompleta := cFormula

	RestArea(aArea)

Return cCompleta

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002Oper
Verifica qual a operação da expressão para retornar a fórmula

@param cExpressao    Expressão
@param cOperad    	 Operação
@param cFuncao       Indica se ó a função de texto ou valor

@return cFormula     Fórmula

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002Oper(cExpressao,cOperad,cFuncao,aMsgErr)
	Local aArea   := GetArea()
	Local nPos1   := At(cOperad,cExpressao)
	Local nParent := 0
	Local nPos2   := 0
	Local nPos3   := 0
	Local nTam    := Len(cExpressao)
	Local nValor1 := 0
	Local nValor2 := 0
	Local cPart1  := ''
	Local cPart2  := ''
	Local cFormula:= ''
	Default aMsgErr:={}

	nPos2 := nPos1 + 1

	While (nPos2 <= nTam)
		If SUBSTR(cExpressao,nPos2,1) == '('
			nParent := nParent + 1
		ElseIf SUBSTR(cExpressao,nPos2,1) == ')'
			nParent := nParent -1
		ElseIf (SUBSTR(cExpressao,nPos2,1) == ',') .And. (nParent == 0)
			Exit
		EndIf
		nPos2 := nPos2 + 1
	End

	nParent := 0
	nPos3   := nPos2 + 1

	WHILE (nPos3 <= nTam)
		If SUBSTR(cExpressao,nPos3,1) == '('
			nParent := nParent + 1
		ElseIf SUBSTR(cExpressao,nPos3,1) == ')'
			nParent := nParent -1
		ElseIf (SUBSTR(cExpressao,nPos3,1) == ',') .And. (nParent == 0)
			Exit
		EndIf
		nPos3 := nPos3 + 1
	End

	If cFuncao == 'FN_SE_TEXTO('

		cPart1 := REPLACE(SUBSTR(cExpressao,2,nPos1-2),"'","")
		cPart2 := REPLACE(SUBSTR(cExpressao,nPos1+2,nPos2-nPos1-2),"'","")

		Do Case
		Case cOperad == '>='
			If (cPart1 >= cPart2)
				cFormula := SUBSTR(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := SUBSTR(cExpressao,nPos3+1,Len(cExpressao)-nPos3)//-1)
			EndIf
		Case cOperad == '<='
			If (cPart1 <= cPart2)
				cFormula := SUBSTR(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := SUBSTR(cExpressao,nPos3+1,Len(cExpressao)-nPos3)//-1)
			EndIf
		Case cOperad == '='
			If (cPart1 == cPart2)
				cFormula := SUBSTR(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := SUBSTR(cExpressao,nPos3+1,Len(cExpressao)-nPos3)//-1)
			EndIf
		Case cOperad == '>'
			If (cPart1 > cPart2)
				cFormula := SUBSTR(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := SUBSTR(cExpressao,nPos3+1,Len(cExpressao)-nPos3)//-1)
			EndIf
		Case cOperad == '<'
			If (cPart1 < cPart2)
				cFormula := SUBSTR(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := SUBSTR(cExpressao,nPos3+1,Len(cExpressao)-nPos3)//-1)
			EndIf
		EndCase

	ElseIf cFuncao == 'FN_SE_VALOR('

		cFormula := Substring(cExpressao,1,(nPos1-1))
		cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
		cFormula := JA002VTmes(cFormula,@aMsgErr)
		cFormula := JA002VJMTO(cFormula)
		cFormula := JA002QtDia(cFormula)
		cFormula := JA002QtMes(cFormula)
		cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
		cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
		nValor1  := JA002Frmla(cFormula)

		If cOperad == '>='

			cFormula := Substr(cExpressao,nPos1+2,nPos2-nPos1-2)
			cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
			cFormula := JA002VTmes(cFormula,@aMsgErr)
			cFormula := JA002VJMTO(cFormula)
			cFormula := JA002QtDia(cFormula)
			cFormula := JA002QtMes(cFormula)
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
			nValor2  := JA002Frmla(cFormula)

			If (nValor1 >= nValor2)
				cFormula := Substr(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := Substr(cExpressao,nPos3+1,Len(cExpressao))
			EndIf

		ElseIf cOperad == '<='

			cFormula := Substr(cExpressao,nPos1+2,nPos2-nPos1-2)
			cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
			cFormula := JA002VTmes(cFormula,@aMsgErr)
			cFormula := JA002VJMTO(cFormula)
			cFormula := JA002QtDia(cFormula)
			cFormula := JA002QtMes(cFormula)
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
			nValor2  := JA002Frmla(cFormula)

			If (nValor1 <= nValor2)
				cFormula := Substr(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := Substr(cExpressao,nPos3+1,Len(cExpressao))
			EndIf

		ElseIf cOperad == '='

			cFormula := Substr(cExpressao,nPos1+1,nPos2-nPos1-1)
			cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
			cFormula := JA002VTmes(cFormula,@aMsgErr)
			cFormula := JA002VJMTO(cFormula)
			cFormula := JA002QtDia(cFormula)
			cFormula := JA002QtMes(cFormula)
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
			nValor2  := JA002Frmla(cFormula)

			If (nValor1 = nValor2)
				cFormula := Substr(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := Substr(cExpressao,nPos3+1,Len(cExpressao))
			EndIf

		ElseIf cOperad == '>'

			cFormula := Substr(cExpressao,nPos1+1,nPos2-nPos1-1)
			cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
			cFormula := JA002VTmes(cFormula,@aMsgErr)
			cFormula := JA002VJMTO(cFormula)
			cFormula := JA002QtDia(cFormula)
			cFormula := JA002QtMes(cFormula)
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
			nValor2  := JA002Frmla(cFormula)

			If (nValor1 > nValor2)
				cFormula := Substr(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := Substr(cExpressao,nPos3+1,Len(cExpressao))
			EndIf

		ElseIf cOperad == '<'

			cFormula := Substr(cExpressao,nPos1+1,nPos2-nPos1-1)
			cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
			cFormula := JA002VTmes(cFormula,@aMsgErr)
			cFormula := JA002VJMTO(cFormula)
			cFormula := JA002QtDia(cFormula)
			cFormula := JA002QtMes(cFormula)
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
			cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
			nValor2  := JA002Frmla(cFormula)

			If (nValor1 < nValor2)
				cFormula := Substr(cExpressao,nPos2+1,nPos3-nPos2-1)
			Else
				cFormula := Substr(cExpressao,nPos3+1,Len(cExpressao))
			EndIf

		EndIf

		cFormula := JA002VVInd(cFormula,/*cAnoMes,*/, /*lMsg*/,@aMsgErr)
		cFormula := JA002VTmes(cFormula,@aMsgErr)
		cFormula := JA002VJMTO(cFormula)
		cFormula := JA002QtDia(cFormula)
		cFormula := JA002QtMes(cFormula)
		cFormula := JA002TxVlr(cFormula,@aMsgErr) // texto
		cFormula := JA002TxVlr(cFormula,@aMsgErr) // valor
		cFormula := JA002Frmla(cFormula)

	EndIf

	RestArea(aArea)

Return cFormula

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002Decod
Verifica o operador utilizado na expressão para montar fórmula

@param cExpressao    Expressão
@param cFuncao       Indica se é a função de texto ou valor

@return cFormula     Fórmula

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002Decod(cExpressao,cFuncao,aMsgErr)
	Local cFormula := ''
	Local cOperador:= ''
	Local aArea    := GetArea()
	Default aMsgErr := {}

	Do Case
	Case At('>=',cExpressao) > 0
		cOperador := '>='
	Case At('<=',cExpressao) > 0
		cOperador := '<='
	Case At('=',cExpressao) > 0
		cOperador := '='
	Case At('>',cExpressao) > 0
		cOperador := '>'
	Case At('<',cExpressao) > 0
		cOperador := '<'
	EndCase

	cFormula := JA002Oper(cExpressao,cOperador,cFuncao,@aMsgErr)

	RestArea(aArea)

Return cFormula

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002TxVlr
Substitui o resultado da expressão da função de texto ou valor

@param cFormula    Fórmula

@return cResult    Resultado

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002TxVlr(cFormula,aMsgErr)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosFin := 0
	Local cParam  := ''
	Local nValor  := 0
	Local cFuncao := ''
	Default aMsgErr := {}

	If At('FN_SE_TEXTO(', cResult) > 0
		cFuncao := 'FN_SE_TEXTO('
	ElseIf At('FN_SE_VALOR(', cResult) > 0
		cFuncao := 'FN_SE_VALOR('
	EndIf

	If !Empty (cFuncao)
		While At(cFuncao, cResult) > 0
			nPosIni := At(cFuncao, cResult) + 12
			nPosFin := Len(cResult)-nPosIni
			cParam  := SubStr(cResult,nPosIni+1,nPosFin-2)
			nValor  := JA002Decod(cParam,cFuncao,@aMsgErr)
			cResult := SubStr(cResult,1,nPosIni-13)+AllTrim( Str(nValor) )+SubStr(cResult,nPosIni+nPosFin+1,Len(cResult))
		End
	EndIf

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VVInd
Substitui o resultado da expressão da função de valor do índice

@param cFormula    Fórmula
@param cAnoMes     Ano-mês que está em uso na correção
@param lMsg        Indica se a variavel de mensagem será populada
@param aMsgErr     Array que guarda as mensagens de erro conforme o processamento, para se apresentado ao final
@param cDtCorte    Data do Corte, ou seja, o limite de correção

@return cResult    Resultado

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VVInd(cFormula, cAnoMes, lMsg, aMsgErr,cDtCorte)
	Local aArea      := GetArea()
	Local cResult    := cFormula
	Local nPosIni    := 0
	Local nPosFin    := 0
	Local nPosIni2   := 0
	Local nPosFin2   := 0
	Local nValor     := 0
	Local lAtuTab    := .F.
	Local cIndice    := ''
	Local cDtValor   := ''
	Default aMsgErr  := {}
	Default cDtCorte := dToS(Date())

	While At('FN_VALORINDICE(', cResult) > 0
		nPosIni := At('FN_VALORINDICE(', cResult) + 15
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))
		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(')', SubStr(cResult,nPosIni2,Len(cResult)))

		cIndice  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cIndFCor := cIndice
		cDtValor  := SubStr(cResult,nPosIni2+1,nPosFin2-1-2)

		lAtuTab   := JA002AtuTab(cIndice)
		//Processo encerrado - Calcula o indice de forma diferente para chegar no valor correto
		If AnoMes(sToD(cDtCorte)) < AnoMes(Date()) .And. lAtuTab
			nValor := Val(cValToChar(VIndProEnc(cIndice, cDtCorte, cAnoMes, cDtValor, lMsg, @aMsgErr)))
		Else
			nValor := Val(cValToChar(DEC_RESCALE(JA002VInd(cIndice,cDtValor, cAnoMes,, lMsg,,@aMsgErr), 8, 0 )))
		EndIf

		cResult  := SubStr(cResult,1,nPosIni-16)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni2+nPosFin2,Len(cResult))
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VVPInd
Substitui o resultado da expressão da função de valor do índice

@param cFormula    Fórmula
@param cAnoMes     Ano-mês que está em uso na correção
@param lMsg        Indica se a variavel de mensagem será populada
@param aMsgErr     Array que guarda as mensagens de erro conforme o processamento, para se apresentado ao final
@param cDtCorte    Data do Corte, ou seja, o limite de correção

@return cResult    Resultado
@author Clovis Eduardo Teixeira
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VVPInd(cFormula, cAnoMes, lMsg, aMsgErr, cDtCorte)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := 0
	Local nPosFin  := 0
	Local nPosIni2 := 0
	Local nPosFin2 := 0
	Local nPosIni3 := 0
	Local nPosFin3 := 0
	Local nValor   := 0
	Local lAtuTab  := .F.
	Local cIndice  := ''
	Local cDtValor := ''
	Local cSubMes  := ''


	Default aMsgErr := {}
	Default cDtCorte := dToS(Date())

	While At('FN_INDICEPLUS(', cResult) > 0
		nPosIni  := At('FN_INDICEPLUS(', cResult) + 15
		nPosFin  := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2 := nPosIni + nPosFin
		nPosFin2 := At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3 := nPosIni2 + nPosFin2
		nPosFin3 := At(')', SubStr(cResult,nPosIni3,Len(cResult)))

		cIndice  := SubStr(cResult,nPosIni,nPosFin-1-1)
		cIndFCor := cIndice
		cDtValor := SubStr(cResult,nPosIni2+1,nPosFin2-1-2)
		cSubMes  := SubStr(cResult,nPosIni3,nPosFin3-1)
		lAtuTab  := JA002AtuTab(cIndice)

		//Processo encerrado - Calcula o indice de forma diferente para chegar no valor correto
		If AnoMes(sToD(cDtCorte)) ==  AnoMes(sToD(cDtValor))
			nValor := 1
		ElseIf AnoMes(sToD(cDtCorte)) < AnoMes(Date()) .And. lAtuTab
			nValor := Val(cValToChar(VIndProEnc(cIndice, cDtCorte, cAnoMes, cDtValor, lMsg, @aMsgErr)))
		Else
			nValor := Val(cValToChar(DEC_RESCALE(JA002VPInd(cIndice,cDtValor,cSubMes, cAnoMes, ,lMsg), 8, 0 )))
		EndIf
		cResult := SubStr(cResult,1,nPosIni-16)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni2+nPosFin2+nPosIni3+nPosFin3,Len(cResult))
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002QtMes
Substitui o resultado da expressão da função de quantidade de meses
@param cFormula    Formula
@return cResult    Resultado
@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002QtMes(cFormula)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosFin := 0
	Local nPosIni2:= 0
	Local nPosFin2:= 0
	Local nValor  := 0
	Local cParam  := ''
	Local cParam2 := ''
	Local cData   := ''

	While At('FN_QTDEMESES(', cResult) > 0

		nPosIni := RAt('FN_QTDEMESES(', cResult) + 12
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))
		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(')', SubStr(cResult,nPosIni2,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+2,nPosFin-4)
		cParam2 := SubStr(cResult,nPosIni2+1,nPosFin2-3)

		If At(Chr(39), cParam2) > 0
			cParam2 := StrTran(cParam2,Chr(39),'')
		EndIf

		If At(Chr(39), cParam) > 0
			cParam := StrTran(cParam,chr(39),'')
		EndIf

		If STOD(cParam2) > STOD(cParam)
			nValor := 1
		Else
			nValor := DateDiffMonth(STOD(cParam), STOD(cParam2))
			If Day(STOD(cParam)) < Day(STOD(cParam2))
				nValor := nValor - 1
			EndIf
		EndIf

		If nValor == 0
			nValor := 1
		EndIf

		If !Empty(cData)
			cResult := SubStr(cResult,1,nPosIni-14)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni2+nPosFin2+1,Len(cResult))
		Else
			cResult := SubStr(cResult,1,nPosIni-13)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni2+nPosFin2,Len(cResult))
		EndIf
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002QtDia
Substitui o resultado da expressão da função de quantidade de dias

@param cFormula	   Fórmula
@return cResult    Resultado da expressão

@author Juliana Iwayama Velho
@since 03/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002QtDia(cFormula)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosFin := 0
	Local nPosIni2:= 0
	Local nPosFin2:= 0
	Local cParam  := ''
	Local cParam2 := ''
	Local nValor  := 0

	While At('FN_QTDEDIAS(', cResult) > 0
		nPosIni := At('FN_QTDEDIAS(', cResult) + 11
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))
		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(')', SubStr(cResult,nPosIni2,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+2,nPosFin-4)
		cParam2 := SubStr(cResult,nPosIni2+1,nPosFin2-3)

		If At(chr(39), cParam2) > 0
			cParam2 := SubStr(cResult,nPosIni2+2,nPosFin2-4)
		EndIf

		If STOD(cParam2) > STOD(cParam)
			nValor := 0
		Else
			nValor  := DateDiffDay(STOD(cParam), STOD(cParam2))
		EndIf

		cResult := SubStr(cResult,1,nPosIni-12)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni2+nPosFin2,Len(cResult))

	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002TdMes
Calcula o valor do índice mês a mês, conforme campo de flag

@param cDataInd    Data do índice
@param cDataBase   Data base
@param cIndice     Código do índice

@return fValor     Valor do índice decimal de ponto fixo

@author Juliana Iwayama Velho
@since 03/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002TdMes(cDataInd, cDataBase, cIndice, aMsgErr)
	Local aArea      := GetArea()
	Local aAreaNW5   := NW5->( GetArea() )
	Local fValor     := DEC_CREATE("0",64,18)
	Local nAnoBase   := Year(STOD(cDataBase))
	Local nAnoIndic  := Year(STOD(cDataInd))
	Local nAnoAtual  := Year(DATE())
	Local nMesBase   := Month(STOD(cDataBase))
	Local nMesIndic  := Month(STOD(cDataInd))
	Local nMesAtual  := Month(DATE())
	Local nMesAnter  := Month(DATE())- 1
	Local cNovaDtBas := ''
	Local cDescIndic := AllTrim(Upper(Posicione('NW5', 1 , xFilial('NW5') + cIndice , 'NW5_DESC')))
	Default aMsgErr  := {}

	If nMesAnter == 0
		nMesAnter := 12
	EndIf

	If (nAnoBase == nAnoAtual .And. nMesBase == nMesAtual) .Or. (nAnoBase == nAnoAtual .And. nMesBase == nMesAnter) .Or.;
			(nAnoBase == nAnoIndic .And. nMesBase == nMesIndic)
		cNovaDtBas := JurCalcRef( StrZero(nAnoBase,4) + StrZero(nMesBase,2),1,2) +'01'
	Else
		cNovaDtBas := StrZero(nAnoBase,4) + StrZero(nMesBase,2) +'01'
	EndIf

	fValor := JA002SQLId(cNovaDtBas,StrZero(nAnoIndic,4)+StrZero(nMesIndic,2)+'01',cIndice, @aMsgErr) //já atribuida variavel de ponto decimal

//If nValor == 0 //.And. cNovaDtBas == DTOS(DATE())
	If Val(cValToChar(fValor)) == 0 //.And. cNovaDtBas == DTOS(DATE())
		fValor := JA002SQLId(DTOS(JurPrxData(STOD(cNovaDtBas),1,'M',2)),;
			JurCalcRef( StrZero(nAnoIndic,4) + StrZero(nMesIndic,2),1,2)+'01', cIndice, @aMsgErr)
	EndIf

//If nValor < 1 .And. cDescIndic == 'SELIC'
	If Val(cValToChar(fValor)) < 1 .And. cDescIndic == 'SELIC'
		fValor := DEC_CREATE("0",64,18)
	EndIf
	RestArea(aAreaNW5)
	RestArea(aArea)



Return fValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002SQLId
Rotina SQL para realizar o cálculo do índice
substituta da SSJR.JUR_FN_TABIND

@param cDataInd    Data do índice
@param cDataBase   Data base
@param cIndice     Código do índice

@return fValor     Valor do índice decimal de ponto fixo

@author Juliana Iwayama Velho
@since 03/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002SQLId(cDataBase,cDataInd,cIndice,aMsgErr)
	Local cQuery    := ''
	Local aArea     := GetArea()
	Local cAlias    := GetNextAlias()
	Local fValor    := DEC_CREATE(0,64,18)
	Local fVlAux1   := DEC_CREATE(0,64,18)
	Local nI        := 1
	Local nJ        := 0
	Local cNvData   := cDataBase
	Local nAno      := Year(STOD(cNvData))
	Local nMes      := Month(STOD(cNvData))
	Local lAchou    := .F.
	Local cDescInd  := AllTrim(Upper(Posicione('NW5', 1 , xFilial('NW5') + cIndice , 'NW5_DESC')))
	Default aMsgErr := {}

	While nI <= 3

		//	cQuery := "SELECT (CASE WHEN NW5.NW5_ATUTAB = '2' THEN NW6_A.NW6_VALOR ELSE (NW6_A.NW6_VALOR - NW6_B.NW6_VALOR) + 1 END) VALOR FROM "+CRLF
		cQuery := "SELECT NW5.NW5_ATUTAB ATUTAB, NW6_A.NW6_PVALOR VALORA, NW6_B.NW6_PVALOR VALORB FROM "+CRLF
		cQuery +=   RetSqlName("NW6")+" NW6_A, "+RetSqlName("NW6")+" NW6_B, "+ RetSqlName("NW5")+" NW5 "
		cQuery += " WHERE NW6_A.NW6_FILIAL = '"+xFilial("NW6")+"' AND NW6_A.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += "   AND NW6_B.NW6_FILIAL = '"+xFilial("NW6")+"' AND NW6_B.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += "   AND NW5.NW5_FILIAL   = '"+xFilial("NW5")+"' AND NW5.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += "   AND NW6_A.NW6_CINDIC = NW6_B.NW6_CINDIC AND NW6_A.NW6_CINDIC = NW5.NW5_COD "+ CRLF
		cQuery += "   AND NW6_A.NW6_CINDIC ='"+cIndice+"' AND NW6_A.NW6_DTINDI ='"+cDataInd +"'"+ CRLF
		cQuery += "   AND NW6_B.NW6_DTINDI ='"+cNvData+"'"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		If (cAlias)->( EOF() )
			nJ := nJ+1
			If nI < 3
				cNvData  := JurCalcRef( AllTrim( StrZero(nAno,4) )+ AllTrim( StrZero(nMes,2) ), nJ, 2 ) +'01'
			EndIf
		Else
			//	nValor := (cAlias)->VALOR
			If(cAlias)->ATUTAB == '2'                              //substitui a tomada de decisão realizada na cQuery
				fValor  := DEC_CREATE((StrTran(((cAlias)->VALORA), ',', '.')),64,18)
			Else
				//substitui a operação matematica realizada na cQuery utilizando decimal de ponto fixo
				fVlAux1    := DEC_SUB(DEC_CREATE((StrTran(((cAlias)->VALORA), ',', '.')),64,18),DEC_CREATE((StrTran(((cAlias)->VALORB), ',', '.')),64,18))
				fValor     := DEC_ADD(fVlAux1,DEC_CREATE("1",64,18))
			EndIf

			lAchou := .T.
			Exit
		EndIf

		(cAlias)->( dbcloseArea() )

		nI := nI+1

	End

	If !lAchou
		fValor := DEC_CREATE("0",64,18)

		If lTemIndice
			If ( aScan( aMsgErr , {  |x| (STR0006 + cDescInd ) $ x } ) == 0 )
				aAdd ( aMsgErr, STR0006 + cDescInd + " : " + cValToChar(stod(cDataBase)) )
			EndIf
		EndIf

		lTemIndice := lAchou
	EndIf

	RestArea(aArea)

Return fValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VTmes
Substitui o resultado da expressão da função de mes a mes

@param cFormula	   Fórmula
@return cResult    Resultado da expressão

@author Juliana Iwayama Velho
@since 03/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VTmes(cFormula,aMsgErr)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosFin := 0
	Local nPosIni2:= 0
	Local nPosFin2:= 0
	Local nPosIni3:= 0
	Local nPosFin3:= 0
	Local cParam  := ''
	Local cParam2 := ''
	Local cParam3 := ''
	Local nValor  := 0
	Default aMsgErr := {}

	While At('FN_MESAMES(', cResult) > 0
		nPosIni := At('FN_MESAMES(', cResult) + 11
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))
		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))
		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(')', SubStr(cResult,nPosIni3,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2+1,nPosFin2-1-2)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)

		nValor  := Val(cValToChar(DEC_RESCALE(JA002TdMes(cParam,cParam2,cParam3,@aMsgErr), 8, 0 )))
		cResult := SubStr(cResult,1,nPosIni-12)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni3+nPosFin3,Len(cResult))
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VPR26
Substitui o resultado da expressão da função do tributário estadual
ou federal
@param cFormula	   Formula
@return cResult    Resultado da expressão
@author Juliana Iwayama Velho
@since 04/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VPR26(cFormula, cAnoMes, lMsg,aMsgErr)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosIni2:= 0
	Local nPosIni3:= 0
	Local nPosIni4:= 0
	Local nPosIni5:= 0
	Local nPosIni6:= 0
	Local nPosIni7:= 0
	Local nPosIni8:= 0
	Local nPosFin := 0
	Local nPosFin2:= 0
	Local nPosFin3:= 0
	Local nPosFin4:= 0
	Local nPosFin5:= 0
	Local nPosFin6:= 0
	Local nPosFin7:= 0
	Local nPosFin8:= 0
	Local cParam  := ''
	Local cParam2 := ''
	Local cParam3 := ''
	Local cParam4 := ''
	Local cParam5 := ''
	Local cParam6 := ''
	Local cParam7 := ''
	Local cParam8 := ''
	Local nValor  := 0
	Default aMsgErr := {}

	While At('FN_PROV26(', cResult) > 0

		nPosIni := At('FN_PROV26(', cResult) + 10
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(',', SubStr(cResult,nPosIni6,Len(cResult)))

		nPosIni7:= nPosIni6 + nPosFin6
		nPosFin7:= At(',', SubStr(cResult,nPosIni7,Len(cResult)))

		nPosIni8:= nPosIni7 + nPosFin7
		nPosFin8:= At(')', SubStr(cResult,nPosIni8,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2+1,nPosFin2-1-2)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4+1,nPosFin4-1-2)
		cParam5 := SubStr(cResult,nPosIni5+1,nPosFin5-1-2)
		cParam6 := SubStr(cResult,nPosIni6+1,nPosFin6-1-2)
		cParam7 := SubStr(cResult,nPosIni7+1,nPosFin7-1-2)
		cParam8 := SubStr(cResult,nPosIni8,nPosFin8-1)

		nValor  := JA002PRV26(cParam,cParam2,cParam3,cParam4,cParam5,cParam6,cParam7,Val(cParam8), cAnoMes, lMsg,@aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-11)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni8+nPosFin8,Len(cResult))
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002PRV26
Calcula o valor do índice do Tributário conforme esfera estadual ou
federal

@param cData       Data do valor
@param cDataBase   Primeira Data base para verificação em primeiro índice
@param cDataBase2  Segunda Data base para verificação em segundo índice
@param cDataCorte  Data de corte
@param cInd1  	   Código do primeiro índice
@param cInd2  	   Código do segundo índice
@param cInd3  	   Código do terceiro índice
@param nValorBase  Valor

@return nValor     Valor do índice

@author Juliana Iwayama Velho
@since 04/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002PRV26(cData, cDataBase, cDataBase2, cDataCorte, cInd1, cInd2, cInd3, nValorBase, cAnoMes, lMsg, aMsgErr)
	Local aArea   := GetArea()
	Local fIndInf := DEC_CREATE("0",64,18)
	Local fIndSup := DEC_CREATE("0",64,18)
	Local fValor  := DEC_CREATE(nValorBase,64,18)
	Local nValor  := 0
	Local cDtValor:= cData
	Local nMeses  := 0
	Local fIndAux1:= DEC_CREATE("0",64,18)
	Local fIndAux2:= DEC_CREATE("0",64,18)
	Default aMsgErr := {}

//Primeiro índice
	If STOD(cDtValor) < STOD(cDataBase)
		fIndInf := JA002VInd(cInd1,cDtValor, cAnoMes,, lMsg,,@aMsgErr)
		fIndSup := JA002VInd(cInd1,DTOS(JurPrxData(STOD(cDataBase),1,'M',2)),cAnoMes,, lMsg,,@aMsgErr)
		fValor  := DEC_MUL(DEC_DIV(fValor,fIndInf),fIndSup)
		cDtValor:= cDataBase
	EndIf

//Segundo índice
	If STOD(cDtValor) >= STOD(cDataBase) .And. STOD(cDtValor) <= STOD(cDataBase2)
		fIndInf := JA002VInd(cInd2,cDtValor)
		fIndSup := JA002VInd(cInd2,StrZero(Year(STOD(cDataBase2)),4)+StrZero(Month(STOD(cDataBase2)),2)+'01',cAnoMes,, lMsg,,@aMsgErr)
		fValor  := DEC_MUL(DEC_DIV(fValor,fIndInf),fIndSup)
		cDtValor:= DTOS(STOD(cDataBase2)+1)
	EndIf

//Terceiro índice
	If cDtValor == cData
		fIndAux1 := DEC_ADD(DEC_CREATE("1",64,18),DEC_DIV(JA002TdMes(cDtValor, cDataCorte, cInd3,@aMsgErr),DEC_CREATE("100",64,18)))
		fValor   := DEC_MUL(fIndAux1,fValor)

	Else
		If STOD(cData) > STOD(cDtValor)
			nMeses := 0
		Else
			nMeses  := DateDiffMonth(STOD(cDtValor), STOD(cData))
			If Day(STOD(cDtValor)) < Day(STOD(cData))
				nMeses := nMeses - 1
			EndIf
		EndIf

		fIndAux1 := DEC_MUL(DEC_CREATE(((nMeses - 1)*0.01),64,18),fValor)
		fIndAux2 := DEC_DIV(DEC_MUL(fValor,JA002TdMes(cDtValor, cDataCorte, cInd3,@aMsgErr)),DEC_CREATE("100",64,18))
		fIndAux3 := DEC_ADD(fIndAux2,fIndAux1)
		fValor   := DEC_ADD(fIndAux3,fValor)

	EndIf

	nValor :=  Val(cValToChar(DEC_RESCALE (fValor, 8, 0 )))
	nAtuCorre := nValor - nValorBase

	RestArea(aArea)

Return nValor
/*-----------------------------------------------------------------------------------------------------------*/

Static Function JA002VJMTO(cFormula)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosIni2:= 0
	Local nPosIni3:= 0
	Local nPosFin := 0
	Local nPosFin2:= 0
	Local nPosFin3:= 0
	Local cParam  := ''
	Local cParam2 := ''
	Local cParam3 := ''
	Local nValor  := 0

	While At('FN_JMISTO(', cResult) > 0

		nPosIni := At('FN_JMISTO(', cResult) + 10
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(')', SubStr(cResult,nPosIni3,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2+1,nPosFin2-1-2)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		nValor  := JA002Misto(cParam,cParam2,cParam3)
		cResult := SubStr(cResult,1,nPosIni-11)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni3+nPosFin3,Len(cResult))
	End

	RestArea(aArea)

Return cResult

Static Function JA002Misto(cDataJuros,cDataBase,cDataCorte)
	Local aArea     := GetArea()
	Local nValor    := 1
	Local dNvJuros  := JurPrxData(STOD(cDataJuros))
	Local nMeses    := 0
	Local nJuros    := 0
	Local cDataBase2:= ''

	If dNvJuros <= STOD(cDataBase)
		cDataBase2 := StrZero(Year(JurPrxData(STOD(cDataBase))),4) + StrZero(Month(JurPrxData(STOD(cDataBase))),2)+'31'
		nMeses     := DateDiffMonth(STOD(cDataBase2),dNvJuros)
		If Day(STOD(cDataBase2)) < Day(dNvJuros)
			nMeses := nMeses - 1
		EndIf
		nJuros := nJuros + nMeses * 0.5
		dNvJuros := JurPrxData(dNvJuros,nMeses)
	EndIf

	If dNvJuros >  STOD(cDataBase)
		nMeses  := DateDiffMonth(STOD(cDataCorte),dNvJuros)
		If Day(STOD(cDataCorte)) < Day(dNvJuros)
			nMeses := nMeses - 1
		EndIf
		If nMeses > 0
			nJuros := nJuros + nMeses * 1
			nValor := (1+nJuros/100)
		EndIf
	EndIf

	RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002Equac
Monta a equação da expressão e realiza a operação
@param cEquacao Equação a ser realizada
@return nValor Valor da equação
@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002Equac(cEquacao)
	Local aArea  := GetArea()
	Local nValor := 0
	Local nValor1:= 0
	Local nValor2:= 0
	Local nPos   := 0

	Do Case
	Case At('+',cEquacao) > 0
		nPos := At('+',cEquacao)
		nValor1:= Val(AllTrim(Substr(cEquacao,1,(nPos-1))))
		nValor2:= Val(AllTrim(Substr(cEquacao,nPos+1,Len(cEquacao))))
		nValor := nValor1 + nValor2
	Case At('-',cEquacao) > 1
		nPos := At('-',cEquacao)
		nValor1:= Val(AllTrim(Substr(cEquacao,1,(nPos-1))))
		nValor2:= Val(AllTrim(Substr(cEquacao,nPos+1,Len(cEquacao))))
		nValor := nValor1 - nValor2
	Case At('*',cEquacao) > 0
		nPos := At('*',cEquacao)
		nValor1:= Val(AllTrim(Substr(cEquacao,1,(nPos-1))))
		nValor2:= Val(AllTrim(Substr(cEquacao,nPos+1,Len(cEquacao))))
		nValor := nValor1 * nValor2
	Case At('/',cEquacao) > 0
		nPos := At('/',cEquacao)
		nValor1:= Val(AllTrim(Substr(cEquacao,1,(nPos-1))))
		nValor2:= Val(AllTrim(Substr(cEquacao,nPos+1,Len(cEquacao))))
		nValor := nValor1 / nValor2
	Otherwise
		nValor := Val(cEquacao)
	EndCase

	RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002Frmla
Desenvolve a fórmula de atualização

@param cFormula    Fórmula
@return nValor     Valor

@author Juliana Iwayama Velho
@since 03/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002Frmla(cFormula)
	Local aArea     := GetArea()
	Local nValor    := 0
	Local cFormula2 := cFormula
	Local cFormulaF := cFormula2
	Local nPos      := At('(',cFormula2)
	Local cEquacao  := ''

	While nPos <> 0
		nPos := At('(',cFormula2)
		If nPos > 0
			cFormula2:= Substr(cFormula2,nPos+1,Len(cFormula2))
		Else
			cEquacao := Substr(cFormula2,1,At(')',cFormula2)-1)
			nPos     := At('(',cFormula2)
			If nPos > 0
				cEquacao := JA002Frmla(cEquacao)
			EndIf
			cFormulaF := StrTran(cFormulaF,'('+cEquacao+')',AllTrim( Str(JA002Equac(cEquacao)) ) )
			cFormula2 := cFormulaF
		EndIf
		nPos := At('(',cFormula2)
		If nPos == 0
			nPos := At(')',cFormula2)
		EndIf
	END

	nValor := JA002Equac(cFormulaF)

	RestArea(aArea)

Return nValor



//-------------------------------------------------------------------
/*/{Protheus.doc} JA002Job
Rotina agendada para atualização dos valores (correção monetária)

@param lManual    Define se é manual ou automático
@param cEmpJob    Código da empresa
@param cFilJob    Código da filial
@param aParams    [1] - lManual
                  [2] - cEmpJob
                  [3] - cFilJob
                  [4] - lEncerr (Atualiza processos Encerrados? .T. ou .F.)
                  [5] - aTipoAs (Ex. {"001","005"} - Tipos de Assunto Contencioso e Consultivo)

@example JA002Job({.F.,"T1","D MG 01 ",.F.,{"001","005"}})
@author Juliana Iwayama Velho
@since 13/04/10
/*/
//-------------------------------------------------------------------
Function JA002Job( aParam )
	Local cAlias   := ''
	Local aArea    := {}
	Local aCodigos := {}
	Local aTabelas := {}
	Local nCod	   := 0
	Local lManual  := .F.
	Local cEmpJOB  := ""
	Local cFilJOB  := ""
	Local lEncerr  := .T.
	Local aTipoAs  := {}
	Local cTipoAs  := ""
	Local nI, nX   := 0

	Conout( "------------------------------------------")
	Conout( time() + " JA002Job -  aParams: " + aToC(aParam ,';'))
	Conout( "------------------------------------------")

	If ValType(aParam[4]) == 'A'//Validação da chamada antiga
		lManual  := IIf( aParam == NIL,.T., aParam[4][1] )
		cEmpJOB  := IIf( lManual, cEmpAnt,  aParam[4][2] )
		cFilJOB  := IIf( lManual, cFilAnt,  aParam[4][3] )
	Else
		If Len(aParam) > 0
			If ValType(aParam[1])== "A"
				For nX := 1 To Len(aParam[1])
					Do Case
					Case nX == 1
						lManual  := IIf( aParam[1][nX] == NIL,.F.    , aParam[1][nX] )
					Case nX == 2
						cEmpJOB  := IIf( aParam[1][nX] == NIL,aParam[2], aParam[1][nX] )
					Case nX == 3
						cFilJOB  := IIf( aParam[1][nX] == NIL,aParam[3], aParam[1][nX] )
					Case nX == 4
						lEncerr  := IIf( aParam[1][nX] == NIL,.T.    , aParam[1][nX] )
					Case nX == 5
						aTipoAs  := IIf( aParam[1][nX] == NIL,{}     , aParam[1][nX] )
					End Case
				Next

				//monta o IN da query
				If !Empty(aTipoAs)
					For nI := 1 To Len(aTipoAs)
						If nI > 1 .And. nI <= Len(aTipoAs)
							cTipoAs += ", "
						EndIf
						cTipoAs += "'"+aTipoAs[nI]+"'"
					Next
				EndIf
			Else
				lManual := .F.
				cEmpJOB := aParam[1]
				cFilJOB := aParam[2]
			EndIf
		EndIf
	EndIf

	If !lManual
		RpcSetType( 3 )
		RpcSetEnv( cEmpJob,	cFilJob,	,	,	, "JURA002" )
	EndIf

	aTabelas := JURRELASX9('NSZ', .F.)
	aArea    := GetArea()
	cAlias   := GetNextAlias()

	cQuery   := " SELECT DISTINCT NSZ_COD CODIGO, NSZ_FILIAL FILIAL "
	cQuery   +=   " FROM " + RetSqlName("NSZ") + " NSZ "
	cQuery   +=   " WHERE NSZ_FILIAL = '" + xFilial("NSZ") + "' AND NSZ.D_E_L_E_T_ = ' ' "
	If !Empty(cTipoAs)
		cQuery   +=   " AND NSZ.NSZ_TIPOAS IN ("+ cTipoAs +")"
	EndIf
	If !lEncerr
		cQuery   +=   " AND NSZ.NSZ_SITUAC = '1' "
	EndIf

	Conout( "------------------------------------------")
	Conout( time() + " JA002Job - cQuery: ")
	Conout( cQuery )
	Conout( "------------------------------------------")
	cQuery   := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )

		aAdd(aCodigos, {(cAlias)->CODIGO, (cAlias)->FILIAL	}	)

		nCod := nCod +1
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea( aArea )

	Conout( "------------------------------------------")
	Conout(	time() + " JA002Job - Início - JURA002 		")
	Conout( " Total de processos da rotina automática: ")
	Conout( "------------------------------------------")

	lRet := JURA002( aCodigos, aTabelas,,,,,.F.)


	Conout( "------------------------------------------")
	Conout( time() + " JA002Job - Qtd de Processos: " + str(nCod)			)
	Conout( time() + " JA002Job - Término - JURA002 "	)
	Conout( "------------------------------------------")
	If !lManual
		RpcClearEnv()
	EndIf

	aSize(aArea,0)
	aSize(aCodigos,0)
	aSize(aTabelas,0)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VPRCOM
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VPRCOM(cFormula, cAnoMes, lMsg,aMsgErr,cFCorrecao)
	Local aArea      := GetArea()
	Local cResult    := cFormula
	Local nPosIni    := At('FN_COMPOSTO(', cResult) + 12
	Local cDtValor   := ''
	Local nValorBase := ''
	Local cDtCorte   := ''
	Local cInd       := ''
	Local cDtJuros   := ''
	Local nValor     := 0
	Local aParam     := StrToKArr(cFormula, ',')

	Default aMsgErr := {}

	While At('FN_COMPOSTO(', cResult) > 0

		cDtValor   := StrTran(SubStr(aParam[1],nPosIni,Len(aParam[1])),"'")
		nValorBase := StrTran(aParam[2],"'")
		cDtCorte   := StrTran(aParam[3],"'")
		cInd       := StrTran(aParam[4],"'")
		cDtJuros   := StrTran(SubStr(aParam[5],1,Len(aParam[5])-1),"'")

		nValor := JA002PRVCOM(cDtValor, Val(nValorBase), cDtCorte, cInd, cDtJuros, cAnoMes, lMsg,aMsgErr,cFCorrecao)
		cResult := SubStr(cResult,1,nPosIni-13)+ AllTrim( Str(nValor) )
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002PRVCOM(cDtValor, nValorBase, cDtCorte, cIndice, cJuros)
Rotina de calculo de juros compostos

@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor seró corrigido)
@param cIndice    Indice monetário que seró utilizado para correção
@author Clóvis Eduardo Teixeira
@since 28/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002PRVCOM(cDtValor, nValorBase, cDtCorte, cIndice, cDtJuros, cAnoMes, lMsg,aMsgErr,cForCor)
Local aArea     := GetArea()
Local nVlrInd   := JA002PInd(cDtValor, cDtCorte, cIndice, .T., 0, cAnoMes, lMsg,@aMsgErr)
Local nVlrCorig := Iif( (nValorBase * nVlrInd) == 0, nValorBase, nValorBase * nVlrInd)
Local nVlrJur   := J002CalJur(cDtJuros,cDtCorte,cForCor,nVlrCorig)
Local nValorAtu := 0

Default aMsgErr := {}

	If nVlrInd == 0
			nVlrInd := 1
	EndIf
		
	nValorAtu := Round((nVlrCorig + nVlrJur),2)

	nAtuCorre := (nValorBase * nVlrInd) - ConvMoeda(cDtValor, nValorBase)
	nAtuJuros := (((nValorBase * nVlrInd) + nVlrJur) - (nValorBase * nVlrInd))

	RestArea(aArea)

Return nValorAtu

//---------------------------------------------------------------------
/*/{Protheus.doc} JA002PInd(cDtValor, cDtCorte, cIndice, lSoma, nIndAcum)
Rotina para calculo de Indice Acumulado entre dois periodos
@param cDtValor  Data Base do Valor
@param cDtCorte  Data de Corte (até que data o valor será corrigido)
@param cIndice   Indice monetário que será utilizado para correção
@param lSoma     Flag para determinar se deve ser somado o valor do mes anterior
@param nIndAcum  Valor do Indice Acumulado
@author Clóvis Eduardo Teixeira
@since 23/03/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function JA002PInd(cDtValor, cDtCorte, cIndice, lSoma, nIndAcum, cAnoMes, lMsg,aMsgErr)
	Local aArea   := GetArea()
	Local nVldInd := 0
	Local aVldInd := {}
	Local cData   := AnoMes(stod(cDtCorte)) +'01'
	Local nPosInd := 0

	Default aMsgErr := {}

	dMesAnt = stod(cData)

	If Empty(Posicione('NW6', 3 , xFilial('NW6') + cIndice + cData, 'NW6_COD'))
		dMesAnt := MonthSub(dMesAnt,1)
		cData   := AnoMes(dMesAnt) +'01'
		If Empty(Posicione('NW6', 3 , xFilial('NW6') + cIndice + cData, 'NW6_COD'))
			dMesAnt := MonthSub(dMesAnt,1)
		EndIf
	EndIf

	aVldInd := JA002VInd(cIndice, cDtCorte,cAnoMes,,lMsg,cDtValor,@aMsgErr)
	nVldInd := aVldInd[1][2] //pega o primeiro valor

	If AnoMes(cDtCorte) < AnoMes(Date())
		nVldInd := aVldInd[1][2] //pega o primeiro valor
	EndIf

	While (AnoMes(stod(cDtCorte)) == AnoMes(Date()) .And. AnoMes(dMesAnt) >= AnoMes(stod(cDtValor))) .Or. (AnoMes(stod(cDtCorte)) < AnoMes(Date()) .And. AnoMes(dMesAnt) > AnoMes(stod(cDtValor)))
		If lSoma
			If AnoMes(dMesAnt) == '199406'
				nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 2750
			ElseIf AnoMes(dMesAnt) == '199307'
				nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
			ElseIf AnoMes(dMesAnt) == '198901'
				nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
			ElseIf AnoMes(dMesAnt) == '198602'
				nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
			Else
				nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1)
			Endif
		Else
			If AnoMes(dMesAnt) == '199406'
				nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 2750
			ElseIf AnoMes(dMesAnt) == '199307'
				nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
			ElseIf AnoMes(dMesAnt) == '198901'
				nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
			ElseIf AnoMes(dMesAnt) == '198602'
				nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
			Else
				nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1)
			Endif
		Endif

		dMesAnt := MonthSub(dMesAnt,1)

		If AnoMes(dMesAnt) >= AnoMes(stod(cDtValor))
			If (len(aVldInd)==1) .Or. (nPosInd := aScan(aVldInd,{|x| x[1] == AnoMes(dMesAnt) })) == 0//se não existem valores
				Exit
			Else
				nVldInd := aVldInd[nPosInd][2]
			Endif
		EndIf

		lSoma   := .F.

	EndDo

	RestArea(aArea)

Return nIndAcum

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VPRAF
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VPRAF(cFormula, cAnoMes, lMsg,aMsgErr)
	Local aArea      := GetArea()
	Local cResult    := cFormula
	Local nPosIni    := 0
	Local cDtValor   := ''
	Local nValorBase := 0
	Local cIndice    := ''
	Local cDtCorte   := ''
	Local cMesInd    := ''
	Local nPerMul    := ''
	Local cPorcJur   := ''
	Local cTipo      := ''
	Local cDtJuros   := ''
	Local cDtMul     := ''
	Local cIndSel    := ''
	Local nValor     := 0
	Local cTmpFor    := ''
	Local aFrmla     := {}
	Default aMsgErr  := {}

	While At('FN_VALORAF(', cResult) > 0

		cTmpFor := SUBSTR(cFormula,RAT("(",cFormula),RAT(")",cFormula))	// Retira a expressão "FN_VALORAF"
		cTmpFor := SUBSTR(cTmpFor, RAT("(",cTmpFor)+1 , LEN(cTmpFor))	// Retira o primeiro parenteses
		cTmpFor := Left( cTmpFor, RAT(")", cTmpFor)-1 )	// Retira o último parenteses

		aFrmla  := StrToArray( cTmpFor , "," ) // transforma para array o conteudo do filtro

		nPosIni := At('FN_VALORAF(', cResult) + 11


		//<- Verifica se o valor do array não estiver nulo, insira na variveis>
		//<- Caso estiverem nulos, a variavel recebe ''							->
		nValor := 	LEN(aFrmla)

		cDtValor   := IIF( nValor >= 1,  IIF( aFrmla[1]  != Nil, aFrmla[1], '')  , '' )
		nValorBase := Val(IIF( nValor >= 2,  IIF( aFrmla[2]  != Nil, aFrmla[2], '')  , '' ))
		cIndice    := IIF( nValor >= 3,  IIF( aFrmla[3]  != Nil, aFrmla[3], '')  , '' )
		cDtCorte   := IIF( nValor >= 4,  IIF( aFrmla[4]  != Nil, aFrmla[4], '')  , '' )
		cMesInd    := IIF( nValor >= 5,  IIF( aFrmla[5]  != Nil, aFrmla[5], '')  , '' )
		nPerMul    := IIF( nValor >= 6,  IIF( aFrmla[6]  != Nil, aFrmla[6], '')  , '' )
		cPorcJur   := IIF( nValor >= 7,  IIF( aFrmla[7]  != Nil, aFrmla[7], '')  , '' )
		cTipo      := IIF( nValor >= 8,  IIF( aFrmla[8]  != Nil, aFrmla[8], '')  , '' )
		cDtJuros   := IIF( nValor >= 9,  IIF( aFrmla[9]  != Nil, aFrmla[9], '')  , '' )
		cDtMul     := IIF( nValor >= 10, IIF( aFrmla[10] != Nil, aFrmla[10], '')  , '')
		cIndSel    := IIF( nValor >= 11, IIF( aFrmla[11] != Nil, aFrmla[11], '')  , '')

		//<--  Tratamento para retirar "'" anteriores e posteriores das variaveis abaixo -->
		cDtValor := Iif( AT("'", cDtValor) > 0,SUBSTR(cDtValor, AT("'",cDtValor)+1), cDtValor )	// Retira o primeiro "'"
		cDtValor := Iif( RAT("'", cDtValor) > 0, LEFT(cDtValor, RAT("'",cDtValor)-1), cDtValor )	// Retira o segundo "'"

		cIndice:= Iif( AT("'", cIndice) > 0,SUBSTR(cIndice, AT("'",cIndice)+1), cIndice )
		cIndice:= Iif( RAT("'", cIndice) > 0, LEFT(cIndice, RAT("'",cIndice)-1), cIndice )

		cDtCorte:= Iif( AT("'", cDtCorte) > 0,SUBSTR(cDtCorte, AT("'",cDtCorte)+1), cDtCorte )
		cDtCorte:= Iif( RAT("'", cDtCorte) > 0, LEFT(cDtCorte, RAT("'",cDtCorte)-1), cDtCorte )

		nPerMul:= Iif( AT("'", nPerMul) > 0,SUBSTR(nPerMul, AT("'",nPerMul)+1), nPerMul )
		nPerMul:= Val(Iif( RAT("'", nPerMul) > 0, LEFT(nPerMul, RAT("'",nPerMul)-1), nPerMul ))

		cDtJuros:= Iif( AT("'", cDtJuros) > 0,SUBSTR(cDtJuros, AT("'",cDtJuros)+1), cDtJuros )
		cDtJuros:= Iif( RAT("'", cDtJuros) > 0, LEFT(cDtJuros, RAT("'",cDtJuros)-1), cDtJuros )

		cDtMul:= Iif( AT("'", cDtMul) > 0,SUBSTR(cDtMul, AT("'",cDtMul)+1), cDtMul )
		cDtMul:= Iif( RAT("'", cDtMul) > 0, LEFT(cDtMul, RAT("'",cDtMul)-1), cDtMul )

		cIndSel:= Iif( AT("'", cIndSel) > 0,SUBSTR(cIndSel, AT("'",cIndSel)+1), cIndSel )
		cIndSel:= Iif( RAT("'", cIndSel) > 0, LEFT(cIndSel, RAT("'",cIndSel)-1), cIndSel )

		//<- Fim Tratmento ->
		nValor  := 0

		nValor  := JA002AutFed(cDtValor,nValorBase,cIndice,cDtCorte,cMesInd,nPerMul,cPorcJur,cTipo,cDtJuros, cDtMul, cIndSel, cAnoMes, lMsg,@aMsgErr)

		cResult := SubStr(cResult, 1, nPosIni-12 )+AllTrim( Str(nValor) )
	EndDo

	RestArea(aArea)

	aSize(aFrmla,0)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002AutFed(cDtValor, nValorBase, cInd, cInd2)
Rotina de calculo de valores da Autuação Federal DF

@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor seró corrigido)
@param cInd       Código do Indice monetário que seró utilizado para correção
@param cInd2      Código do Indice monetário Correspondente ao SELIC
@author Clóvis Eduardo Teixeira
@since 28/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002AutFed(cDtValor, nValorBase, cInd, cDtCorte, cMesInd, nPerMul, cPorcJur, cTipo, cDtJuros, cDtMul, cIndSel, cAnoMes, lMsg,aMsgErr)
	Local aArea      := GetArea()
	Local nValorInd  := 0
	Local nValorMul  := 0
	Local nValorJur  := 0
	Local nValorAtu  := 0
	Local nQtdMeses  := 0
	Local nValSelic  := 0
	Local nJurSelic  := 0
	Local nMulSelic  := 0
	Local nJurosImp  := 0
	Local nJurosMul  := 0
	Local fValorInd  := DEC_CREATE("0",64,18)
	Local lAtuTab    := JA002AtuTab(cInd)

	Default	cIndSel  := '30'
	Default aMsgErr  := {}

	nAtuCorre := 0
	nAtuJuros := 0
	nAtuMulta := 0

	If DateDiffDay(STOD(cDtJuros), STOD(cDtCorte)) <= 30
		nQtdMeses := DateDiffMonth(STOD(cDtJuros), STOD(cDtCorte))

		If nQtdMeses == 0 .And. !Empty(nPerMul)
			nQtdMeses := 1
		Endif
	Else
		nQtdMeses  := DateDiffMonth(STOD(cDtJuros), STOD(cDtCorte)) + 1
	EndIf

	If AnoMes(sToD(cDtCorte)) < AnoMes(Date()) .And. lAtuTab //verifica se o ano-mes de corte é menor que da data atual
		nValorInd := Val(cValToChar(VIndProEnc(cInd, cDtCorte, cAnoMes, cDtValor, lMsg, @aMsgErr)))
		If cInd == '05' .Or. cInd == '28'
			nValorInd := nValorInd / 100
		EndIf
		nValorInd := DEC_CREATE((StrTran(CVALTOCHAR((nValorInd)), ',', '.')),64,18)
	Else
		If cTipo = 'DF' .Or. cTipo = 'SP' .Or. cTipo = 'AF' .Or. cTipo = 'GO' .Or.  cTipo = 'MG'
			if !cMesInd == '0'
				nValorInd := JA002VPInd(cInd , cDtValor, cMesInd, cAnoMes, , lMsg)
			Elseif cTipo = 'AF' .Or. cTipo = 'MG'
				nValorInd := JA002VInd(cInd,cDtJuros, cAnoMes,, lMsg,,@aMsgErr)
			Else
				nValorInd := JA002VInd(cInd,cDtValor, cAnoMes,, lMsg, ,@aMsgErr)
			Endif
		Elseif cTipo = 'RJ' .Or. cTipo ='PA'
			nValorInd := JA002VInd(cInd, cDtCorte , cAnoMes,, lMsg, ,@aMsgErr)
		ElseIf cTipo = 'PR' .Or. cTipo ='CMP' .Or. cTipo ='ES' .Or. cTipo ='PI' .Or. cTipo ='SE'
			nValorInd := JA002VInd(cInd,cDtValor, cAnoMes,, lMsg, ,@aMsgErr)
			fValorInd := JA002VInd(cInd,cDtCorte, cAnoMes,, lMsg, ,@aMsgErr)
		ElseIf cTipo = 'MT' .Or. cTipo = 'MS'
			nValorInd := JA002VInd(cInd, cDtValor, cAnoMes,, lMsg, ,@aMsgErr)
		Endif
	EndIf

	nVlrCor := Round(nValorBase * (Val(cValToChar(DEC_RESCALE (nValorInd,8,0)))),2)

	If cTipo = 'SP'

		nAtuCorre := nVlrCor - nValorBase

		nValorMul := (nVlrCor * (nPerMul / 100)) + nVlrCor
		nValorJur := nQtdMeses * Val(cPorcJur) * nValorMul
		nValorAtu := nValorMul + nValorJur

		nAtuJuros := nValorJur
		nValorMul := (nVlrCor * (nPerMul / 100))

	ElseIf cTipo = 'GO'

		nAtuCorre := nVlrCor - nValorBase

		nAtuJuros := nQtdMeses * Val(cPorcJur) * (nVlrCor)

		nValorMul := ((nVlrCor) * (nPerMul / 100))

		nValorAtu := nValorBase + nAtuCorre + nValorMul + nAtuJuros

	ElseIf cTipo == 'AF' .OR. cTipo == 'MG'

		If !(cDtMul == '#DTMULTA') .And. AnoMes(stod(cDtCorte)) >= AnoMes(stod(cDtMul))

			If AnoMes(sToD(cDtCorte)) < AnoMes(Date()) .And. lAtuTab //verifica se o ano-mes de corte é menor que da data atual
				nValSelic := Val(cValToChar(VIndProEnc(cInd, cDtCorte, cAnoMes, cDtMul, lMsg, @aMsgErr)))

				If cInd == '05' .Or. cInd == '28'
					nValSelic := nValSelic / 100
					nValSelic := DEC_CREATE(nValSelic,64,18)
				EndIf
			Else
				nValSelic := JA002VInd(cInd,cDtMul, cAnoMes,, lMsg,,@aMsgErr)
			EndIf

		Else
			nValSelic := fValorInd
		Endif

		//Valor Corrigido
		nAtuCorre := 0

		//Valor Multa Atualizado
		If cInd == '05' .Or. cInd == '28'
			nValorMul := (nValorBase * (nPerMul / 100))
			nValorMul += Round(nValorMul * (Val(cValToChar(DEC_RESCALE (nValSelic,8,0)))),2)
		Else
			nValorMul := (nVlrCor * (nPerMul / 100))
			nValorMul += Round(nValorMul * nVlrCor ,2)
		EndIf

		//Somatória de Juros
		nAtuJuros := nVlrCor

		//Totalizadores Finais
		nValorAtu := nValorBase + nAtuCorre + nValorMul + nAtuJuros

	ElseIf cTipo == 'RJ'

		If Empty(cIndSel)
			cIndSel := '30'
		Endif

		//Valor da Multa
		nValorMul := Round((nVlrCor * (nPerMul / 100)),2)

		If sTod(cDtJuros) <= cTod('31/12/2012')

			//Percentual de juros a ser aplicado
			nQtdMeses  := DateDiffMonth(STOD(cDtJuros), cTod('31/12/2012')) + 1

			//Juros sobre o imposto
			nJurosImp := Round((nQtdMeses * Val(cPorcJur) * nVlrCor),2)

			//Juros sobre a multa
			nJurosMul := Round((nQtdMeses * Val(cPorcJur) * nValorMul),2)

		Else
			nQtdMeses := 0
		Endif

		//Valor do Indice da Selic
		If sTod(cDtJuros) <= cTod('31/12/2012')
			nValSelic := JA002VInd(cIndSel,'20130101',cAnoMes,, lMsg,,@aMsgErr)
		Else
			nValSelic := JA002VInd(cIndSel,cDtJuros,cAnoMes,, lMsg,,@aMsgErr)
		Endif

		//Valor Juros Selic
		nJurSelic := Round(nVlrCor * (Val(cValToChar(DEC_RESCALE (nValSelic,8,0)))),2)
		//Valor Multa Selic
		nMulSelic := Round(nValorMul * (Val(cValToChar(DEC_RESCALE (nValSelic,8,0)))),2)

		//Somatória de Juros
		nValorJur := nJurosImp + nJurSelic + nMulSelic + nJurosMul


		//Totalizadores Finais
		nValorAtu := nVlrCor + nValorMul + nValorJur
		nAtuJuros := nValorJur
		nAtuMulta := nValorMul
		nAtuCorre := nVlrCor - nValorBase
	ElseIf cTipo == 'PR'
		nValorAtu := (nValorBase / Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))) * Val(cValToChar(DEC_RESCALE (fValorInd, 8, 0 )))
		nAtuCorre := nValorAtu - nValorBase
		//nAtuJuros := (nValorAtu) * (nQtdMeses*0.01)


	ElseIf cTipo == 'ES'
		nValorAtu :=  (nValorBase / Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))) * Val(cValToChar(DEC_RESCALE (fValorInd, 8, 0 )))
		nAtuCorre := nValorAtu - nValorBase
		nAtuJuros := (nValorAtu) * (nQtdMeses*(Val(cPorcJur)))
		nValorAtu := nValorAtu + nAtuJuros

	ElseIf cTipo == 'MT'
		nValorAtu :=  (nValorBase * Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 ))))
		nValorMul := (nValorBase * Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))) * (nPerMul / 100)
		nAtuCorre := nValorAtu - nValorBase4

		nAtuJuros := (nValorAtu) * (nQtdMeses * (Val(cPorcJur)))

		nValorAtu := nValorAtu + nAtuJuros + nValorMul

	ElseIf cTipo == 'CMP'

		nValorMul := (nValorBase * nPerMul / 100)
		nValorAtu :=  (nValorBase / Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))) * Val(cValToChar(DEC_RESCALE (fValorInd, 8, 0 )))
		nAtuCorre := nValorAtu - nValorBase
		nAtuJuros := (nValorAtu) * (nQtdMeses*(Val(cPorcJur)))
		nValorAtu := nValorAtu + nAtuJuros + nValorMul

	ElseIf cTipo == 'MS'
		nValorAtu := (nValorBase / Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 ))))
		nValorMul := nValorAtu  * (nPerMul / 100)
		nAtuCorre := nValorAtu - nValorBase
		nAtuJuros := (nValorAtu) * (nQtdMeses * (Val(cPorcJur)))
		nValorAtu := nValorAtu + nAtuJuros + nValorMul


	ElseIf cTipo == 'PI'

		nValorAtu :=  (nValorBase / Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))) * Val(cValToChar(DEC_RESCALE (fValorInd, 8, 0 )))
		nValorMul := (nValorAtu * nPerMul / 100)
		nAtuCorre := nValorAtu - nValorBase
		nAtuJuros := (nValorAtu) * (nQtdMeses*(Val(cPorcJur)))
		nValorAtu := nValorAtu + nAtuJuros + nValorMul

	ElseIf cTipo == 'PA'

		nValorAtu := (nValorBase * Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 ))))
		nAtuCorre := nValorAtu - nValorBase
		nAtuJuros := (nValorAtu) * (nQtdMeses*(Val(cPorcJur)))
		nValorAtu := nValorAtu + nAtuJuros

	ElseIf cTipo == 'SE'

		nValorAtu := (nValorBase / Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))) * Val(cValToChar(DEC_RESCALE (fValorInd, 8, 0 )))
		nValorMul := (nValorAtu * nPerMul / 100)
		nAtuCorre := nValorAtu - nValorBase
		nAtuJuros := (nValorAtu) * (nQtdMeses*(Val(cPorcJur)))
		nValorAtu := nValorAtu + nAtuJuros + nValorMul

	Else

		nValorMul := nVlrCor * (nPerMul / 100)
		nValorJur := nQtdMeses * Val(cPorcJur) * nVlrCor
		nValorAtu := nVlrCor + nValorMul + nValorJur
		nAtuCorre := nVlrCor - ConvMoeda(JurDtAdd(cDtValor, 'M', Val(cMesInd)), nValorBase)
		nAtuJuros := nValorJur

	Endif

	If Empty(nPerMul)
		nValorMul := 0
	Endif

	nAtuMulta := nValorMul

//JA002AtuMulta(nValorMul) //Function de atualizar a multa atul.

	nAtuJuros := Round(nAtuJuros,2)
	nAtuCorre := Round(nAtuCorre,2)

	RestArea(aArea)

Return nValorAtu
//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VLPRO
Substitui o resultado da expressão da função composta
@param  cFormula Fórmula
@return cResult  Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VLPRO(cFormula, cAnoMes, lMsg, aMsgErr, cForCor)
	Local aArea      := GetArea()
	Local cResult    := cFormula
	Local nPosIni    := At('FN_VALORPRO(', cResult) + 12
	Local nValor     := 0
	Local cDtValor   := ''
	Local nValorBase := ''
	Local cDtCorte   := ''
	Local cIndice    := ''
	Local cMesInd    := ''
	Local cDtJuros   := ''
	Local aParam     := StrToKArr(cFormula, ',')

	Default aMsgErr := {}

	While At('FN_VALORPRO(', cResult) > 0

		cDtValor   := StrTran(SubStr(aParam[1],nPosIni,Len(aParam[1])),"'")
		nValorBase := StrTran(aParam[2],"'")
		cDtCorte   := StrTran(aParam[3],"'")
		cIndice    := StrTran(aParam[4],"'")
		cMesInd    := StrTran(aParam[5],"'")
		cDtJuros   := StrTran(SubStr(aParam[6],1,Len(aParam[6])-1),"'")

		nValor  := JA002VLJUR(cDtValor, Val(nValorBase), cDtCorte, cIndice, cMesInd, cDtJuros, cAnoMes, lMsg,aMsgErr,cForCor)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VLJUR(cDtValor, nValorBase, cDtCorte, cIndice, cMesInd,cDtJuros, cAnoMes, lMsg,aMsgErr,cForCor)
Rotina de calculo de juros (FN_VALORPRO) 

@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor será corrigido)
@param cIndice    Código do Indice Monetário
@param cMesInd    Quantidade de meses a adicionar o subtrair para calculo do indice
@Param cDtJuros   Data do juros
@Param cAnoMês    Ano-Mes do cálculo
@Param lMsg       Indica se mostrarão mensagens, utilizar como .T. quando a rotina partir de um botão na browse; e como .F. 
quando for executada internamente
@Param aMsgErr array para armazenar as mensagens de erro ao longo do processo
@Param cForCor    Forma de correção que está sendo utilizada
@author Clóvis Eduardo Teixeira
@since 01/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VLJUR(cDtValor, nValorBase, cDtCorte, cIndice, cMesInd, cDtJuros, cAnoMes, lMsg,aMsgErr,cForCor)
	Local aArea      := GetArea()
	Local nValorInd  := 0
	Local nValorAtu  := 0
	Local nValorJur  := 0
	Local nValorTot  := 0
	Local lAtuTab    := JA002AtuTab(cIndice)
	Default aMsgErr  := {}

	nAtuJuros := 0

	If AnoMes(sToD(cDtCorte)) < AnoMes(Date()) .And. lAtuTab
		nValorInd := Val(cValToChar(VIndProEnc(cIndice, cDtCorte, cAnoMes, cDtValor, lMsg, @aMsgErr)))
		nValorInd := DEC_CREATE((StrTran(CVALTOCHAR((nValorInd)), ',', '.')),64,18)
	Else
		If !cMesInd == '0'
			nValorInd := JA002VInd(cIndice,JurDtAdd(cDtValor, 'M', Val(cMesInd)),cAnoMes,, lMsg,,@aMsgErr)
		Else
			nValorInd := JA002VInd(cIndice,cDtValor,cAnoMes,, lMsg,,@aMsgErr)
		Endif
	EndIf
	nValorAtu := (Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 ))) * nValorBase)

	If !(cIndice $ "06/09/11/13/15/16/18/19/23/27")  //Não deve ocorrer divisão para estes indices pois a divisão de anos é realizada na planilha

		nValorAtu := ConvMoeda(cDtValor, nValorAtu)

	Endif

	nValorJur := J002CalJur(cDtJuros,cDtCorte,cForCor,nValorAtu)

	nValorTot := nValorJur

	nAtuJuros := nValorJur

	nAtuCorre := nValorAtu - nValorBase

	RestArea(aArea)

Return nValorTot

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VIndT
Substitui o resultado da expressão da função composta
@param cFormula Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VIndT(cFormula,cAnoMes, lMsg,aMsgErr)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := 0
	Local nPosIni2 := 0
	Local nPosIni3 := 0
	Local nPosIni4 := 0
	Local nPosIni5 := 0
	Local nPosIni6 := 0
	Local nPosFin  := 0
	Local nPosFin2 := 0
	Local nPosFin3 := 0
	Local nPosFin4 := 0
	Local nPosFin5 := 0
	Local nPosFin6 := 0
	Local cParam   := ''
	Local cParam2  := ''
	Local cParam3  := ''
	Local cParam4  := ''
	Local cParam5  := ''
	Local cParam6  := ''
	Local nValor   := 0
	Default aMsgErr := {}

	While At('FN_VALORIND(', cResult) > 0

		nPosIni := At('FN_VALORIND(', cResult) + 12
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(')', SubStr(cResult,nPosIni6,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2,nPosFin2-1)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4,nPosFin4-1)
		cParam5 := SubStr(cReSult,nPosIni5+1,nPosFin5-3)
		cParam6 := SubStr(cReSult,nPosIni6+1,nPosFin6-3)

		nValor  := JA002IndTrib(cParam,Val(cParam2),cParam3,cParam4,cParam5,cParam6,cAnoMes, lMsg,@aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002IndTrib(cDtValor, nValorBase, cDtCorte, cPorcJur, cInd, cIndSel)
Rotina de calculo de valores do Indébito Tributário
@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor seró corrigido)
@param cPorcJur   Porcentagem de juros a ser aplicado
@param cInd       Código do Indice referente ao Indébito Tributário
@Param cIndSel    Código do Indice monetário Correspondente ao SELIC
@author Clóvis Eduardo Teixeira
@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002IndTrib(cDtValor, nValorBase, cDtCorte, cPorcJur, cInd, cIndSel, cAnoMes, lMsg,aMsgErr)
	Local aArea     := GetArea()
	Local nValorInd := JA002VInd(cInd,cDtValor,cAnoMes,, lMsg,,@aMsgErr)
	Local nValorSel := JA002VInd(cIndSel,cDtValor,cAnoMes,, lMsg,,@aMsgErr)
	Local nValorPar := nValorBase * Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))
	Local nValorAtu := (nValorPar * Val(cValToChar(DEC_RESCALE (nValorSel, 8, 0 )))) + nValorPar
	Local nValorJur := 0
	Local nValorTot := 0
	Default aMsgErr := {}

	nAtuCorre := 0
	nAtuJuros := 0

	nValorJur := nValorPar * Val(cValToChar(DEC_RESCALE (nValorSel, 8, 0 )))
	nValorTot := nValorAtu

	nAtuCorre := nValorTot - ConvMoeda(cDtValor, nValorBase)

	RestArea(aArea)

Return nValorTot

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VCGSel
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VCGSel(cFormula,cAnoMes, lMsg,aMsgErr)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := 0
	Local nPosIni2 := 0
	Local nPosIni3 := 0
	Local nPosIni4 := 0
	Local nPosIni5 := 0
	Local nPosIni6 := 0
	Local nPosFin  := 0
	Local nPosFin2 := 0
	Local nPosFin3 := 0
	Local nPosFin4 := 0
	Local nPosFin5 := 0
	Local nPosFin6 := 0
	Local cParam   := ''
	Local cParam2  := ''
	Local cParam3  := ''
	Local cParam4  := ''
	Local cParam5  := ''
	Local cParam6  := ''
	Local nValor   := 0
	Default aMsgErr := {}

	While At('FN_VALORCGS(', cResult) > 0

		nPosIni := At('FN_VALORCGS(', cResult) + 12
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(')', SubStr(cResult,nPosIni6,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2,nPosFin2-1)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4,nPosFin4-1)
		cParam5 := SubStr(cReSult,nPosIni5+1,nPosFin5-3)
		cParam6 := SubStr(cReSult,nPosIni6+1,nPosFin6-3)

		nValor  := JA002CGSelic(cParam,Val(cParam2),cParam3,cParam4,cParam5,cParam6,cAnoMes, lMsg,@aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002CGSelic(cDtValor, nValorBase, cDtCorte, cPorcJur, cInd, cIndSel)
Rotina de calculo de valores de Condenatória Geral com Selic
@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor seró corrigido)
@param cPorcJur   Porcentagem de juros a ser aplicado
@param cInd       Código do Indice referente ao Indébito Tributário
@Param cIndSel    Código do Indice monetário Correspondente ao SELIC
@author Clóvis Eduardo Teixeira
@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002CGSelic(cDtValor, nValorBase, cDtCorte, cPorcJur, cInd, cIndSel, cAnoMes, lMsg,aMsgErr)
	Local aArea     := GetArea()
	Local nValorInd := JA002VInd(cInd,cDtValor,cAnoMes,, lMsg,,@aMsgErr)
	Local nValorAtu := nValorBase * Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 )))
	Local nValorSel := JA002VInd(cIndSel,cDtValor,cAnoMes,, lMsg,,@aMsgErr)
	Local nValor1   := 0
	Local nValor2   := 0
	Local nValor3   := 0
	Local cDtJur1   := '31/12/2002'
	Local cDTSelic  := '30/06/2009'
	Local cDtJur2   := '01/07/2009'
	Default aMsgErr := {}
	nAtuCorre := 0
	nAtuJuros := 0

	If sTod(cDtValor) <= cTod(cDtJur1)
		nValor1 := ((DateDiffDay(cTod(cDtJur1), STOD(cDtValor))) * Val(cPorcJur) / 30) * nValorAtu
	Endif

	If sTod(cDtValor) <= cTod(cDTSelic)
		nValor2 := nValorAtu * Val(cValToChar(DEC_RESCALE (nValorSel, 8, 0 )))
	Endif

	If sTod(cDtValor) >= cTod(cDtJur2)
		nValor3 := ((DateDiffDay(sTod(cDtCorte), sTod(cDtValor))) * Val(cPorcJur) / 30) * nValorAtu
	Else
		nValor3 := ((DateDiffDay(sTod(cDtCorte), cTod(cDtJur2))) * Val(cPorcJur) / 30) * nValorAtu
	Endif

	nValorTot := nValor1 + nValor2 + nValor3 + nValorAtu

	If JSToFormat(cDtValor,'YYYYMM') <= '199406'
		nAtuCorre := nValorAtu
	Else
		nAtuCorre := 	nValorAtu - nValorBase
	Endif

	nAtuJuros := nValor1 + nValor2 + nValor3

	RestArea(aArea)

Return nValorTot
//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VTJPro
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VTJPro(cFormula, cAnoMes, lMsg,aMsgErr,cFCorrecao)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := At('FN_VALORPTJ(', cResult) + 12
	Local cDtValor   := ''
	Local nValorBase := ''
	Local cDtCorte   := ''
	Local cInd       := ''
	Local cDtJuros   := ''
	Local cTipo      := ''
	Local nValor     := 0
	Local aParam     := StrToKArr(cFormula, ',')
	Default aMsgErr := {}

	While At('FN_VALORPTJ(', cResult) > 0

		cDtValor   := StrTran(SubStr(aParam[1],nPosIni,Len(aParam[1])),"'")
		nValorBase := StrTran(aParam[2],"'")
		cDtCorte   := StrTran(aParam[3],"'")
		cInd       := StrTran(aParam[4],"'")
		cDtJuros   := StrTran(SubStr(aParam[5],1,Len(aParam[5])-1),"'")

		// Parâmetro opcional de UF
		If Len(aParam) >= 6
			cTipo := StrTran(aParam[6],"'")
		EndIf

		nValor  := JA002TJPro(cDtValor,Val(nValorBase),cDtCorte,cInd,cDtJuros,cAnoMes, lMsg,aMsgErr,cFCorrecao,cTipo)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

Return cResult
//-------------------------------------------------------------------
/*/{Protheus.doc} JA002TJPro(cDtValor, nValorBase, cDtCorte, cInd, cDtJuros)
Rotina de calculo de valores do TJ
@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor será corrigido)
@param cInd        Código do Indice 
@param cDtJuros   Data do Juros
@param cAnoMes
@param lMsg
@param aMsgErr
@param cFCorrecao
@param cUF        UF para o calculo do valor de correção
@author Clóvis Eduardo Teixeira
@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002TJPro(cDtValor, nValorBase, cDtCorte, cInd, cDtJuros, cAnoMes, lMsg,aMsgErr,cFCorrecao,cUF)
	Local aArea      := GetArea()
	Local fAux       := DEC_CREATE('0',64,18)
	Local fVlrIndAtu := fAux
	Local fVlrIndAnt := fAux
	Local nVlrCorig  := 0
	Local nVlrJuros  := 0
	Local nVlrAtu    := 0
	Local nErro      := LEN(aMsgErr)
	Default aMsgErr  := {}
	Default cUF      := "SP"

	// Se for data Futura Não Busca índices para atualizar
	If (cDtValor < cDtCorte)
		fVlrIndAtu := JA002VInd(cInd,cDtCorte, cAnoMes,, lMsg,,@aMsgErr)
		fVlrIndAnt := JA002VInd(cInd,cDtValor, cAnoMes,, lMsg,,@aMsgErr)
	EndIf

	// Se um dos índices for Zero não atualiza Pois significa que deu erro
	If (fVlrIndAtu = fAux .Or. fVlrIndAnt = fAux) .Or. (LEN(aMsgErr) > nErro)
		fAux := DEC_CREATE('1',64,18)
		fVlrIndAtu := fAux
		fVlrIndAnt := fAux
	EndIf


	cUF := StrTran(cUF,")")

	Do Case
	Case cUF == "RJ"
		nVlrCorig := nValorBase * Val(cValToChar(DEC_RESCALE (fVlrIndAnt, 8, 0 ))) / Val(cValToChar(DEC_RESCALE (fVlrIndAtu, 8, 0 )))
	Otherwise
		nVlrCorig := nValorBase / Val(cValToChar(DEC_RESCALE (fVlrIndAnt, 8, 0 ))) * Val(cValToChar(DEC_RESCALE (fVlrIndAtu, 8, 0 )))
	End Case

	If (cDtJuros < cDtCorte)
		nVlrJuros := J002CalJur(cDtJuros,cDtCorte,cFCorrecao,nVlrCorig)
	EndIf

	nVlrAtu   := nVlrCorig + nVlrJuros
	nAtuJuros := nVlrJuros

	If JSToFormat(cDataBase,'YYYYMM') <= '199406'
		nAtuCorre := nVlrCorig
	Else
		nAtuCorre := nVlrCorig - nValorBase
	Endif

	RestArea(aArea)

Return Round(nVlrAtu,2)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VAutSP
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 28/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VAutSP(cFormula, cAnoMes, lMsg,aMsgErr)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := 0
	Local nPosIni2 := 0
	Local nPosIni3 := 0
	Local nPosIni4 := 0
	Local nPosIni5 := 0
	Local nPosIni6 := 0
	Local nPosFin  := 0
	Local nPosFin2 := 0
	Local nPosFin3 := 0
	Local nPosFin4 := 0
	Local nPosFin5 := 0
	Local nPosFin6 := 0
	Local cParam   := ''
	Local cParam2  := ''
	Local cParam3  := ''
	Local cParam4  := ''
	Local cParam5  := ''
	Local cParam6  := ''
	Local nValor   := 0
	Default aMsgErr := {}

	While At('FN_VALORASP(', cResult) > 0

		nPosIni := At('FN_VALORASP(', cResult) + 12
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(')', SubStr(cResult,nPosIni6,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2,nPosFin2-1)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4+1,nPosFin4-3)
		cParam5 := SubStr(cReSult,nPosIni5+1,nPosFin5-1-2)
		cParam6 := SubStr(cReSult,nPosIni6+1,nPosFin6-1-2)

		nValor  := JA002AutSP(cParam,Val(cParam2),cParam3,cParam4,cParam5, cParam6, cAnoMes, lMsg,@aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

//StrTran(cSQL,"' '","''")

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002AutSP(cDtValor, nValorBase, cDtCorte, cInd, cDtJuros)
Rotina de calculo de valores da Autuação Estadual SP
@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor seró corrigido)
@param cInd       Codigo do Indice referente ao Indebito Tributário
@Param cDtJuros   Data de incidencia de Juros
@author Clóvis Eduardo Teixeira
@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002AutSP(cDtValor, nValorBase, cDtCorte, cInd, cDtJuros, nPerMul, cAnoMes, lMsg,aMsgErr)
	Local aArea      := GetArea()
	Local nVlrInd    := 0
	Local cAliasQry  := GetNextAlias()
	Local nVlrAtu    := 0
	Local nTotalJurP := 0
	Local cForCor    := '30'
	Local aIntDatas  := {}
	Local aTotal     := {}
	Local cDtJurM1   := '21/12/2009'
	Local cDtJurSel  := '01/11/2017'
	Local nVlrIndSel := 0
	Local nI
	Default aMsgErr  := {}

	nAtuCorre := 0
	nAtuJuros := 0
	nAtuMulta := 0

	//Aplicação da SELIC para valores anterior a 22/12/2009
	If sTod(cDtJuros) <= cTod(cDtJurM1)
		nVlrInd := JA002VInd(cInd,cDtJuros, cAnoMes,,lMsg,,@aMsgErr)
		nTotalJurP +=  Val(cValToChar(DEC_RESCALE (nVlrInd, 8, 0 )))
	Endif

	BeginSql Alias cAliasQry

		SELECT NWS_PERCEN PERCENTUAL, NWS_DTINI DTINI, NWS_DTFIM DTFIM
		  FROM %table:NWS% NWS
		 WHERE NWS.NWS_CFCORR = %Exp:cForCor%
		   AND NWS.NWS_FILIAL = %xFilial:NWS%
		   AND NWS.%notDel%
	EndSql

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbgoTop())

	While !(cAliasQry)->(EOF())
		aAdd(aIntDatas, {(cAliasQry)->PERCENTUAL, (cAliasQry)->DTINI, (cAliasQry)->DTFIM})
		(cAliasQry)->(dbSkip())
	EndDo

	If Len(aIntDatas) > 0
		For nI := 1 To Len(aIntDatas)

			//Leitura e aplicacao dos juros conforme a periodicidade de juros - CTS 17/07/12
			If sTod(cDtJuros) < sTod(aIntDatas[nI][3])
				If sTod(cDtJuros) >= sTod(aIntDatas[nI][2])	 .And. sTod(cDtJuros) <= sTod(aIntDatas[nI][3])
					If sTod(cDtCorte) < sTod(aIntDatas[nI][3])
						aAdd(aTotal,{(((aIntDatas[nI][1]/10000) * (DateDiffDay(sTod(cDtJuros), sTod(cDtCorte)))))})
					else
						aAdd(aTotal,{(((aIntDatas[nI][1]/10000) * (DateDiffDay(sTod(cDtJuros), sTod(aIntDatas[nI][3])))))})
					Endif
				Else
					If sTod(aIntDatas[nI][3]) > sTod(cDtCorte)
						aAdd(aTotal,{(((aIntDatas[nI][1]/10000) * (DateDiffDay(sTod(cDtCorte), sTod(aIntDatas[nI][2])))))})
					Else
						aAdd(aTotal,{(((aIntDatas[nI][1]/10000) * (DateDiffDay(sTod(aIntDatas[nI][3]), sTod(aIntDatas[nI][2])))))})
					Endif
				Endif
			Endif
		Next

		If Len(aTotal) > 0
			For nI := 1 To Len(aTotal)
				nTotalJurP += aTotal[nI][1]
			Next
		Endif
	Endif

	//Aplicação da SELIC após 01/11/2017
	If sTod(cDtJuros) <= cTod(cDtJurSel)
		nVlrIndSel := JA002VInd(cInd,dTos(cTod(cDtJurSel)), cAnoMes,,lMsg,,@aMsgErr)
	Else
		nVlrIndSel := JA002VInd(cInd,cDtJuros, cAnoMes,,lMsg,,@aMsgErr)
	EndIf

	nTotalJurP += Val(cValToChar(DEC_RESCALE (nVlrIndSel, 8, 0 )))

	nAtuJuros := nValorBase * nTotalJurP
	nAtuMulta := nValorBase * (Val(nPerMul) / 100)

	//Verificação do sistema para a data do valor, caso seja superior a 21/12/2009 não se aplica
	//os juros da SELIC, apenas os periodo de datas acima
	//CTS - 01/11/2012
	nVlrAtu := nValorBase + nAtuJuros + nAtuMulta

	(cAliasQry)->( dbCloseArea())

	RestArea(aArea)

	aSize(aIntDatas,0)
	aSize(aTotal,0)

Return nVlrAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002DtCorte
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 28/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002DtCorte(cCod, cCajuri)
	Local aArea      := GetArea()
	Local cAliasQry  := GetNextAlias()
	Local cDataCorte := ''
	Local cDataEnc   := ''
	Local cQuery     := ''

	cQuery += "SELECT NT2_DATA, NT2_CCOMON "
	cQuery += " FROM " + RetSqlName('NT2') + " NT2"
	cQuery += " WHERE NT2_CGARAN = '"+ cCod +"' "
	cQuery +=       " AND NT2_FILIAL = '" + xFilial("NT2")+"'"
	cQuery +=       " AND NT2_MOVFIN = '2'"
	cQuery +=       " AND NT2.D_E_L_E_T_ = ' '"
	cQuery +=       " AND NT2_CAJURI = '" + cCajuri + "' "
	cQuery += " ORDER BY NT2_DATA, NT2_COD  "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .T., .F. )

	//Se tiver levantamento a data de corte é a data do levantamento, caso contrário,
	//a data de corte é a data de encerramento se o processo estiver encerrado
	If (cAliasQry)->(EOF()) .Or. (cAliasQry)->NT2_CCOMON == '07'

		cDataEnc := JurGetDados("NSZ",1,xFilial("NSZ") + cCajuri,"NSZ_DTENCE")

		If Empty(cDataEnc)
			cDataCorte := DTOS(DATE())
		Else
			cDataCorte := cDataEnc
		Endif
	Else
		cDataCorte := (cAliasQry)->NT2_DATA
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return cDataCorte

//-------------------------------------------------------------------
/*/{Protheus.doc} JA2VzioCpo
 
Verifica a quantidade de elementos em branco do campo NW8_CDATAU
(Data Últ Atu --> Campo data últ atualização )

@param aDados array dos indices para verificação
@return lRet True ou falso

@author Rafael Rezende Costa
@since 08/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA2VzioCpo(aDados)
	Local nI		:= 0
	Local nFim		:= 0
	Local nQtd		:= 0

	Default aDados :={}

	nFim := LEN(aDados)

	If nFim > 0
		For nI:= 1 to nFim
			If EMPTY( aDados[nI][7] )	// Campo NW8_CDATAU
				nQtd := nQtd +1
			EndIF
		Next nI
	EndIf

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002AtuTab
Valida se o campo muda valores antigos a cada atualização
@param cIndice ìndice que será analisado.

@return lRet Retorna .T. ou .F. 
@author André Spirigoni Pinto
@since 29/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002AtuTab(cIndice)
	Local lRet := .F.
	Local aArea      := GetArea()
	Local cAliasQry  := GetNextAlias()
	Local cQuery

	cQuery := "SELECT NW5_COD,NW5_ATUTAB FROM " + RetSqlName("NW5") + " NW5 "
	cQuery += " WHERE NW5_FILIAL = '" + xFilial("NW5") + "' "
	cQuery += "   AND NW5_COD = '" + cIndice + "' "
	cQuery += "   AND D_E_L_E_T_ = ' '"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .T., .F. )

	If !(cAliasQry)->(EOF())
		If (cAliasQry)->NW5_ATUTAB=="1"
			lRet := .T.
		Endif
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA2LstAnoMes
Retorna os meses que não existe informação de histórico dos índices.
@param cIndice ìndice que será analisado.

@return lRet Retorna .T. ou .F. 
@author André Spirigoni Pinto
@since 29/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA2LstAnoMes(cTabela, cCampo, dDataIni, dDataFim, cChave)
	Local aArea     := GetArea()
	Local aAnoMes   := {} //Array com 3 posições. 1 - AnoMes, 2 - Valor, 3 - Atualiza ?, 4 - Correção, 5 - Juros, 6 - Multa
	Local dAnoTmp
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ''

//Monta o array com os ano-mes do intervalo escolhido.
	For dAnoTmp := FirstDate(dDataIni) to LastDate(dDataFim)
		aAdd(aAnoMes,{AnoMes(dAnoTmp),Nil,.T.,Nil,Nil,Nil})
		dAnoTmp := MonthSum(FirstDate(dAnoTmp),1)
	Next

	cQuery := "SELECT " + cTabela + "_ANOMES ANOMES, " + cCampo + " VALOR FROM " + RetSqlName(cTabela) + CRLF
	cQuery += "WHERE " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "'" + CRLF
	cQuery += "AND " + cTabela + "_ANOMES >= '" + Anomes(dDataIni) + "'" + CRLF
	cQuery += "AND " + cTabela + "_ANOMES <= '" + Anomes(dDataFim) + "'" + CRLF
	cQuery += "AND D_E_L_E_T_ = ' '" + CRLF

	If cTabela == "NYZ"
		cQuery += "AND " + cTabela + "_CAJURI = '" + cChave + "'"
	ElseIf cTabela == "NZ0"
		cQuery += "AND " + cTabela + "_CGARAN = '" + cChave + "'"
	ElseIf cTabela == "NZ1"
		cQuery += "AND " + cTabela + "_CVALOR = '" + cChave + "'"
	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .T., .F. )

	While !(cAliasQry)->(EOF())
		If aScan(aAnoMes,{|aX| aX[1] == (cAliasQry)->ANOMES}) > 0
			aAnoMes[aScan(aAnoMes,{|aX| aX[1] == (cAliasQry)->ANOMES})][2] := (cAliasQry)->VALOR
			aAnoMes[aScan(aAnoMes,{|aX| aX[1] == (cAliasQry)->ANOMES})][3] := .F.
		EndIf
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aAnoMes

//-------------------------------------------------------------------
/*/{Protheus.doc} JA2GravaHist
Grava os valores corrigidos na tabela de histórico




@param aAnoMes Array com todos os ano-mes e valores corrigidos
@param cTabela Tabela onde o histórico deve ser gravado
@param cChave Chave que deve se usada para gravar os valores na tabela de histórico
@param cCampo Campo da tabela de histórico que receberá o valor
@param cFormaCor Forma de correção que deverá ser gravada
@param cCampoCor Campo da tabela histórica que deverá receber o conteúdo da forma de correção



@return lRet Retorna .T. ou .F. 
@author André Spirigoni Pinto

@since 29/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA2GravaHist(aAnoMes,cTabela,cChave,cCampo, cFormaCor, cCampoCor, cCodNW8, cCampoNW8)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local aAreaNSY  := NSY->( GetArea() )
	Local cCampCod  := ""
	Local cTabAlias
	Local nCt
	Local nI
	Local aDados := {}

	If !Empty(AllTrim(cTabela)) .And. !Empty(AllTrim(cFormaCor))


		cTabAlias := &(cTabela)->(GetArea())

		//Define o campo de código usado em cada tabela.
		If cTabela == "NZ1"
			cCampCod := "_CVALOR"
		ElseIf (cTabela == "NZ0")
			cCampCod := "_CGARAN"
		Else
			cCampCod := "_CAJURI"
		Endif

		dbSelectArea(cTabela)
		&(cTabela)->( dbSetOrder( 1 ) )

		If (Len(aAnoMes) > 0)
			For nCt := 1 to len(aAnoMes)

				//Valida para não gravar o mês atual no histórico e valida se o valor deve ser gravado (Pos 3 array, .T. ou .F.
				If aAnoMes[nCt][1] < AnoMes(DATE()) .And. aAnoMes[nCt][3] == .T.

					//Caso ja exista linha para o registro, apenas fazer um update
					If (&(cTabela)->( dbSeek( xFilial(cTabela) + cChave + aAnoMes[nCt][1] ) ))
						Reclock(cTabela, .F.)
						&(cTabela)->(&(cCampo)) := aAnoMes[nCt][2]
						&(cTabela)->(&(cTabela+SubStr(cCampoCor,4))) := cFormaCor

						If cTabela == "NYZ"
							aDados := JA2HistNYZ(aAnoMes, cCodNW8, cCampoNW8, nCt, cCampo)

							If Len(aDados) > 0
								For nI := 1 to Len(aDados)
									&(cTabela)->(&(aDados[nI][1])) := aDados[nI][2]
								Next
							EndIf
						EndIf

						If cTabela == "NZ0"
							aDados := JA2HistNZ0(aAnoMes, cCodNW8, cCampoNW8, nCt)

							If Len(aDados) > 0
								For nI := 1 to Len(aDados)
									&(cTabela)->(&(aDados[nI][1])) := aDados[nI][2]
								Next
							EndIf
						EndIf

						If cTabela == "NZ1"
							aDados := JA2HistNZ1(aAnoMes, cCodNW8, cCampoNW8, nCt)

							If Len(aDados) > 0
								For nI := 1 to Len(aDados)
									&(cTabela)->(&(cTabela+SubStr(aDados[nI][1],4))) := aDados[nI][2]
								Next
							EndIf
						EndIf

						&(cTabela)->(MsUnlock())
						&(cTabela)->(DbCommit())
					Else
						Reclock(cTabela, .T.)
						&(cTabela)->(&(cTabela+"_FILIAL")) := xFilial(cTabela)
						&(cTabela)->(&(cTabela+cCampCod)) := cChave
						&(cTabela)->(&(cCampo)) := aAnoMes[nCt][2]
						&(cTabela)->(&(cTabela+"_ANOMES")) := aAnoMes[nCt][1]
						&(cTabela)->(&(cTabela+SubStr(cCampoCor,4))) := cFormaCor

						If cTabela == "NYZ"
							aDados := JA2HistNYZ(aAnoMes, cCodNW8, cCampoNW8, nCt, cCampo)

							If Len(aDados) > 0
								For nI := 1 to Len(aDados)
									&(cTabela)->(&(aDados[nI][1])) := aDados[nI][2]
								Next
							EndIf
						EndIf

						If cTabela == "NZ0"
							aDados := JA2HistNZ0(aAnoMes, cCodNW8, cCampoNW8, nCt)

							If Len(aDados) > 0
								For nI := 1 to Len(aDados)
									&(cTabela)->(&(aDados[nI][1])) := aDados[nI][2]
								Next
							EndIf
						EndIf

						If cTabela == "NZ1"
							aDados := JA2HistNZ1(aAnoMes, cCodNW8, cCampoNW8, nCt)

							If Len(aDados) > 0
								For nI := 1 to Len(aDados)
									&(cTabela)->(&(cTabela+SubStr(aDados[nI][1],4))) := aDados[nI][2]
								Next
							EndIf
						EndIf

						&(cTabela)->(MsUnlock())
						&(cTabela)->(DbCommit())
					Endif

					If __lSX8
						ConfirmSX8()
					EndIf

				Endif

			Next
		EndIf

		RestArea(cTabAlias)

	EndIf

	RestArea(aAreaNSY)
	RestArea(aArea)

	aSize(aDados,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA2HistNYZ
Retorna os valores a serem gravados na tabela de histórico referente
a correção, juros, multa, valor incidente

@param aAnoMes Array com todos os ano-mes e valores corrigidos
@param cTabela Tabela onde o histórico deve ser gravado
@param cChave Chave que deve se usada para gravar os valores na tabela de histórico
@param cCampo Campo da tabela de histórico que receberá o valor
@param cFormaCor Forma de correção que deverá ser gravada
@param cCampoCor Campo da tabela histórica que deverá receber o conteúdo da forma de correção

@return lRet Retorna .T. ou .F. 
@author Jorge Luis Branco Martins Junior
@since 23/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA2HistNYZ(aAnoMes, cCodNW8, cCampoNW8, nCt, cCampo)
	Local aArea     := GetArea()
	Local aAreaNW8  := NW8->( GetArea() )
	Local aDados    := {}

	dbSelectArea("NW8")
	NW8->( dbSetOrder( 1 ) )

	If NW8->(DBSeek(xFILIAL('NW8') + cCodNW8 + cCampoNW8))
		If cCampo == 'NYZ_VACAUS'
			aAdd(aDados, { 'NYZ_VCCAUS', aAnoMes[nCt][4] } )
			aAdd(aDados, { 'NYZ_VJCAUS', aAnoMes[nCt][5] } )
		ElseIf cCampo == 'NYZ_VAENVO'
			aAdd(aDados, { 'NYZ_VCENVO', aAnoMes[nCt][4] } )
			aAdd(aDados, { 'NYZ_VJENVO', aAnoMes[nCt][5] } )
		ElseIf cCampo == 'NYZ_VAPROV'
			aAdd(aDados, { 'NYZ_VCPROV', aAnoMes[nCt][4] } )
			aAdd(aDados, { 'NYZ_VJPROV', aAnoMes[nCt][5] } )
		ElseIf cCampo == 'NYZ_VAHIST'
			aAdd(aDados, { 'NYZ_VCHIST', aAnoMes[nCt][4] } )
			aAdd(aDados, { 'NYZ_VJHIST', aAnoMes[nCt][5] } )

		EndIf
	EndIf

	RestArea(aAreaNW8)
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JA2HistNZ0
Retorna os valores a serem gravados na tabela de histórico referente
a correção, juros, multa, valor incidente

@param aAnoMes Array com todos os ano-mes e valores corrigidos
@param cTabela Tabela onde o histórico deve ser gravado
@param cChave Chave que deve se usada para gravar os valores na tabela de histórico
@param cCampo Campo da tabela de histórico que receberá o valor
@param cFormaCor Forma de correção que deverá ser gravada
@param cCampoCor Campo da tabela histórica que deverá receber o conteúdo da forma de correção

@return lRet Retorna .T. ou .F. 
@author Jorge Luis Branco Martins Junior
@since 23/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA2HistNZ0(aAnoMes, cCodNW8, cCampoNW8, nCt)
	Local aArea     := GetArea()
	Local aAreaNW8  := NW8->( GetArea() )
	Local aDados    := {}

	dbSelectArea("NW8")
	NW8->( dbSetOrder( 1 ) )

	If NW8->(DBSeek(xFILIAL('NW8') + cCodNW8 + cCampoNW8))
		aAdd(aDados, { 'NZ0_VCGARA', aAnoMes[nCt][4] } )
		aAdd(aDados, { 'NZ0_VJGARA', aAnoMes[nCt][5] } )
		aAdd(aDados, { 'NZ0_MULATU', aAnoMes[nCt][6] } )
	EndIf

	RestArea(aAreaNW8)
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JA2HistNZ1
Retorna os valores a serem gravados na tabela de histórico referente
a correção, juros, multa, valor incidente

@param aAnoMes Array com todos os ano-mes e valores corrigidos
@param cCampo Campo da tabela de histórico que receberá o valor

@return lRet Retorna .T. ou .F. 
@author Jorge Luis Branco Martins Junior
@since 23/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA2HistNZ1(aAnoMes, cCodNW8, cCampoNW8, nCt)
	Local aArea     := GetArea()
	Local aAreaNW8  := NW8->( GetArea() )
	Local aDados    := {}

	dbSelectArea("NW8")
	NW8->( dbSetOrder( 1 ) )

	If NW8->(DBSeek(xFILIAL('NW8') + cCodNW8 + cCampoNW8))
		aAdd(aDados, { NW8->NW8_CCORRM, aAnoMes[nCt][4] } )
		aAdd(aDados, { NW8->NW8_CJUROS, aAnoMes[nCt][5] } )
		aAdd(aDados, { NW8->NW8_MULATU, aAnoMes[nCt][6] } )
	EndIf

	RestArea(aAreaNW8)
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} J002ClrAtu
Limpa os campos atualizados pela correção monetária
@param aAnoMes Array com todos os ano-mes e valores corrigidos
@param cCampo Campo da correção monetária refernciado no cadastro de
Valores Atualizaveis ( NW8_CFORMA )

@return lRet Retorna .T. ou .F. 
@author Marcelo Araujo Dente
@since 17/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J002ClrAtu()
	Local oMdl        := ''
	Local oMdlAtivo   := ''
	Local cCampo      := Substr(ReadVar(),4)
	Local aArea       := GetArea()
	Local aAreaNW8    := NW8->( GetArea() )
	Local lRet        := .T.
	Local cNomeModel  := ''


	If !Empty(cCampo) .And. !IsPesquisa()
		Do case
		Case SubStr(cCampo,1,3) == 'NSZ'
			cNomeModel := "NSZMASTER"
		Case SubStr(cCampo,1,3) == 'NT9'
			cNomeModel := "NT9DETAIL"
		Case SubStr(cCampo,1,3) == 'NUQ'
			cNomeModel := "NUQDETAIL"
		Case SubStr(cCampo,1,3) == 'NSY'
			If IsInCallStack("JCALLJ094")
				cNomeModel := "NSYDETAIL"
			Else
				cNomeModel := "NSYMASTER"
			EndIf
		Case SubStr(cCampo,1,3) == 'NT2'
			cNomeModel := "NT2MASTER"
		Case SubStr(cCampo,1,3) == 'NYP'
			cNomeModel := "NYPDETAIL"
		Case SubStr(cCampo,1,3) == 'NXY'
			cNomeModel := "NXYDETAIL"
		End Case

		oMdl := FWModelActive()
		oMdlAtivo := oMdl:GetModel(cNomeModel)
		dbSelectArea("NW8")
		NW8->( dbSetOrder( 1 ) )
		NW8->(DbGoTop())

		While !(NW8->( EOF() ))
			If Alltrim(NW8->NW8_CFORMA) == Alltrim(cCampo)
				If !Empty(NW8->NW8_CCMPAT) .And. (oMdlAtivo:HasField(NW8->NW8_CCMPAT))
					oMdlAtivo:clearField((NW8->NW8_CCMPAT))
				EndIf
				If !Empty(NW8->NW8_MULATU) .And. (oMdlAtivo:HasField(NW8->NW8_MULATU))
					oMdlAtivo:clearField((NW8->NW8_MULATU))
				EndIf
				If !Empty(NW8->NW8_CJUROS) .And. (oMdlAtivo:HasField(NW8->NW8_CJUROS))
					oMdlAtivo:clearField((NW8->NW8_CJUROS))
				EndIf
				If !Empty(NW8->NW8_CTOTAT) .And. (oMdlAtivo:HasField(NW8->NW8_CTOTAT))
					oMdlAtivo:clearField((NW8->NW8_CTOTAT))
				EndIf
				If !Empty(NW8->NW8_CCORRM) .And. (oMdlAtivo:HasField(NW8->NW8_CCORRM))
					oMdlAtivo:clearField((NW8->NW8_CCORRM))
				EndIf

			EndIf
			NW8->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaNW8)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuVlrNsz
Atualiza os valores atualizados do processo com valores dos objetos

@param cFilNsz   - Filial que esta tendo os valores atualizados
@param cProcesso - Processo que esta tendo os valores atualizados
@param cJVlProv  - Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos para calculo do redutor

@author  Rafael Tenorio da Costa
@since   08/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuVlrNsz(cFilNsz, cProcesso, cJVlProv)
Local aArea      := GetArea()
Local aAreaNSZ   := NSZ->( GetArea() )
Local aVlrProv   := {}
Local aVlrEnvo   := {}
Local nVlAtuProv := 0
Local nAtuCorre  := 0
Local nAtuJuros  := 0
Local nVlProv    := 0
local cFaseProc  := ""

Default cJVlProv := "2"

	DbSelectArea("NSZ")
	NSZ->( DbSetOrder(1) )		//NSZ->NSZ_FILIAL+NSZ_COD
	If NSZ->( DbSeek(cFilNsz + cProcesso) )

		RecLock("NSZ", .F.)
		If cJVlProv == '2'
			nVlProv  := JA094VlDis(cProcesso, "1", .F., cFilNsz, .F.) // Pega o valor original da provisao, para gravar o historico
			aVlrProv := JA094VlDis(cProcesso, "1", .T., cFilNsz, .T.)//Valores atualizados
			aVlrEnvo := JA094VlEnv(cProcesso, cFilNsz)

			//Valores atualizados Provisão
			nVlAtuProv := aVlrProv[1][1]
			nAtuCorre  := aVlrProv[1][2]
			nAtuJuros  := aVlrProv[1][3]
			NSZ->NSZ_VAPROV := nVlAtuProv
			NSZ->NSZ_VCPROV := nAtuCorre
			NSZ->NSZ_VJPROV := nAtuJuros

			//Valores atualizados Envolvido
			NSZ->NSZ_VAENVO := aVlrEnvo[1][2]
			NSZ->NSZ_VCENVO := aVlrEnvo[1][3]
			NSZ->NSZ_VJENVO := aVlrEnvo[1][4]

			If NSZ->( FieldPos("NSZ_VRDPRO") ) > 0
				cFaseProc  := JURA100Fase(cProcesso,cFilNsz,.T.)
				NSZ->NSZ_VRDPRO := JA94CALRED(cProcesso, , '1', , cFilNsz,cFaseProc)
				NSZ->NSZ_VRDPOS := JA94CALRED(cProcesso, , '2', , cFilNsz,cFaseProc)
				NSZ->NSZ_VRDREM := JA94CALRED(cProcesso, , '3', , cFilNsz,cFaseProc)
			EndIf

			//Verifica se há valores para incluir no historico
			If nVlProv <> 0
				JurHisCont(cProcesso,, NSZ->NSZ_DTPROV, nVlProv  , '1', '1', 'NSZ',3)
			EndIf

			If nAtuCorre <> 0
				JurHisCont(cProcesso,, NSZ->NSZ_DTPROV, nAtuCorre, '2', '1', 'NSZ',3)
			EndIf

			If nAtuJuros <> 0
				JurHisCont(cProcesso,, NSZ->NSZ_DTPROV, nAtuJuros, '3', '1', 'NSZ',3)
			EndIf

		Else
			If NSZ->( FieldPos("NSZ_VRDPRO") ) > 0
				NSZ->NSZ_VRDPRO := JA94CALRED(cProcesso, , , cJVlProv, cFilNsz )
			EndIF
		EndIF
		NSZ->( MsUnLock() )

		//Atualiza redutor do objeto
		JA94AtuRed(cProcesso)
	EndIf

	RestArea( aAreaNSZ )
	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J002CalJur
Função utilizada para fazer o calculo dos juros através da tabela NWS

@param cDtJuros Data de Juros
@param cDtCorte Data do Corte
@param cForCor Forma de correção
@param nVlrCorig Valor corrigido 

@return Valor de Juros calculado
@author Beatriz Gomes
@since 05/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J002CalJur(cDtJuros,cDtCorte,cForCor,nVlrCorig)
	Local nVlrJuros := 0
	Local cSql      := ""
	Local cAlias    := GetNextAlias()
	Local aJurDta   := {}
	Local aTotal    := {}
	Local nI        := 0
	Local cDtJurIni := cDtJuros
	Local cDtCorFim := cDtCorte
	Local lNext     := .T.
	Local nDiffDia  := 0
	Local nDiffMes  := 0
	Local lJurSeg   := (SuperGetMV('MV_JJURSEG',, '1') == '1')
	Local lDecMes   := .F.

	//Consulta do percentual, data inicio e data fim, tipo do juros (Simples/Composto) e Pro-rata(Sim/não) informados no Grid do cadastro de forma de correção
	cSql := " SELECT NWS.NWS_PERCEN PERC, NWS.NWS_DTINI DTINI, NWS.NWS_DTFIM DTFIM"

	DbSelectArea("NWS")
	If NWS->( FieldPos("NWS_TIPJUR") ) > 0
		cSql += ", NWS.NWS_TIPJUR TPJUROS, NWS.NWS_PRORAT PRORAT "
	Else
		cSql += ", '1' TPJUROS, '1' PRORAT "
	EndIf
	If NWS->( FieldPos("NWS_DECMES") ) > 0
		cSql += ", NWS.NWS_DECMES DECMES "
		lDecMes := .T.
	EndIf

	cSql += " FROM " + RetSqlName('NWS') + " NWS "
	cSql += " WHERE NWS.NWS_CFCORR = '" + cForCor+ "' "
	cSql += " AND NWS.NWS_FILIAL = '" + xFilial('NWS') + "'
	cSql += " AND NWS.D_E_L_E_T_ = ''"

	cSql := ChangeQuery(cSql)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAlias, .T., .T.)

	While !(cAlias)->(EOF())
		aAdd(aJurDta, {(cAlias)->PERC, (cAlias)->DTINI, (cAlias)->DTFIM,(cAlias)->TPJUROS, (cAlias)->PRORAT, Iif(lDecMes,(cAlias)->DECMES,0)})//adc no array o percentual de juros e as datas no grid
		(cAlias)->(dbSkip())
	EndDo

	For nI := 1 To Len(aJurDta)

		If Empty(sTod(aJurDta[Len(aJurDta)][3]))
			aJurDta[Len(aJurDta)][3] := cDtCorte
		EndIf

		If sTod(cDtJuros) < sTod(aJurDta[nI][3])
			//dtIni e DtFim estão dentro do periodo da dtJuros e dtCorte?
			If !Empty(sTod(aJurDta[nI][2])) .AND. sTod(aJurDta[nI][2]) >= sTod(cDtJuros) .AND. sTod(aJurDta[nI][2]) <= sTod(cDtCorte)
				cDtJurIni := aJurDta[nI][2]
			Else
				cDtJurIni := cDtJuros
			EndIf
			If !Empty(sTod(aJurDta[nI][3])) .AND. sTod(aJurDta[nI][3]) >= sTod(cDtJuros) .AND. sTod(aJurDta[nI][3]) <= sTod(cDtCorte)
				cDtCorFim := aJurDta[nI][3]
			Else
				cDtCorFim := cDtCorte
			EndIf
		Else
			lNext := .F.
		Endif

		If lNext

			nDiffMes := (DateDiffMonth(sTod(cDtJurIni), sTod(cDtCorFim)) - aJurDta[nI][6])
			If nDiffMes < 0
				nDiffMes := 0
			EndIf
			nDiffDia := DateDiffDay(sTod(cDtJurIni), sTod(cDtCorFim))

			If aJurDta[nI][4] == '1' //Tp Juros Simples
				If aJurDta[nI][5] =='1' //Pro-rata Sim (Diferença em dias)
					aAdd(aTotal,{((((aJurDta[nI][1]/100)/30) * (nDiffDia)) * nVlrCorig)})
				Else//diferença em meses
					If lJurSeg//Se houver a margem de segurança, é consiferado o mês fechado
						aAdd(aTotal,{((((aJurDta[nI][1]/100)) * (nDiffMes)) * nVlrCorig)})
					Else
						If Day(StoD(cDtCorFim)) < Day(sToD(cDtJurIni))
							aAdd(aTotal,{((((aJurDta[nI][1]/100)) * (IIF(nDiffMes > 0, nDiffMes -1,0))) * nVlrCorig)})
						Else
							aAdd(aTotal,{((((aJurDta[nI][1]/100)) * nDiffMes ) * nVlrCorig)})
						EndIF
					EndIF
				EndIf
			Else//Tp Juros Composto
				If aJurDta[nI][5] =='1' //Pro-rata Sim (Diferença em dias)
					aAdd(aTotal,{(((( 1 + aJurDta[nI][1]/100) ^ ((nDiffDia)/30)) * nVlrCorig)-nVlrCorig)})
				Else//diferença em meses
					If lJurSeg //Se houver a margem de segurança, é consiferado o mês fechado
						aAdd(aTotal,{((( 1 + aJurDta[nI][1]/100) ^ (nDiffMes)-1) * nVlrCorig)})
					Else
						If Day(StoD(cDtCorFim)) < Day(sToD(cDtJurIni))
							aAdd(aTotal,{((( 1 + aJurDta[nI][1]/100) ^ (IIF(nDiffMes > 0, nDiffMes -1,0))-1) * nVlrCorig)})
						Else
							aAdd(aTotal,{((( 1 + aJurDta[nI][1]/100) ^ (nDiffMes)-1) * nVlrCorig)})
						EndIF

					EndIf
				EndIf
			EndIf
		EndIF

		lNext:= .T.
	Next

	If Len(aTotal) > 0
		For nI := 1 To Len(aTotal)
			nVlrJuros += aTotal[nI][1]
		Next
	Endif
	(cAlias)->( dbcloseArea() )
	aSize(aTotal,0)

Return nVlrJuros
//-------------------------------------------------------------------
/*/{Protheus.doc} VIndProEnc
Função utilizada para calcular o indice para processos encerrados

@Param cIndice  Codigo do indice a ser utilizado
@param cDtCorte Data do Corte, ou seja, o limite de correção
@param cAnoMes  Ano-Mes do cálculo
@param lAnoMes  Variável que indica se a preferência de histórico está ativa ou não.
@param cDtIni   Data de inicio da correção
@param lSoma    Indica se haverá soma do valor do indice, pegando o primeiro valor para ser somado com o restante
@param lMsg     Indica se a variavel de mensagem será populada
@param aMsgErr  Array que guarda as mensagens de erro conforme o processamento, para se apresentado ao final

@return nIndAcum Valor do indice acumulado considerando o periodo entre a data Inicio e a Data de Corte

@author Breno Gomes
@since 29/03/2019
/*/
//-------------------------------------------------------------------
Static Function VIndProEnc(cIndice,cDtCorte, cAnoMes, cDtValor, lMsg, aMsgErr)
	Local cQuery    := ""
	Local cAlias    := GetNextAlias()
	Local cDescInd  := ''
	Local aArea     := GetArea()
	Local aAreaNW5  := NW5->( GetArea() )
	Local aAreaNW6  := NW6->( GetArea() )
	Local cData     := AnoMes(stod(cDtCorte)) +'01'
	Local cNvData   := cData
	Local fValorInd := DEC_CREATE("0",64,18)
	Local lAchou    := .F.
	Local aVldInd   := {} //retorno múltiplo, quando o parâmetro cDtIni é informado
	Local lIgual    := .F.//Valida se a data é igual.
	Local nIndAcum  := 0
	Local nVldInd   := 0
	Local nPosInd   := 0
	Local dDtCorte  := StoD(cDtCorte)
	Local dProxMes  := StoD(cDtValor)
	Local lSoma     := .T.
	Local lAnoMes   := (SuperGetMV('MV_JVLHIST',, '2') == '1')

	Default cAnoMes  := AnoMes(STOD(cDtCorte))
	Default lMsg     := .T.
	Default cDtValor := ""
	Default aMsgErr  := {}

	//Caso não haja índice para o mês corrente, atribui-se o índice do mês anterior
	If Empty(Posicione('NW6', 3 , xFilial('NW6') + cIndice + cData, 'NW6_COD'))
		dDtCorte := MonthSub(dDtCorte,1)
		cData    := AnoMes(dDtCorte) +'01'
		If Empty(Posicione('NW6', 3 , xFilial('NW6') + cIndice + cData, 'NW6_COD'))
			dDtCorte := MonthSub(dDtCorte,1)
		EndIf
	EndIf

	//Verifica se o tipo do indice é diario
	If JurGetDados("NW5", 1, xFilial("NW5") + cIndice, "NW5_TIPO") == "1"
		cNvData := cDtCorte
	EndIf

	//Lista os Valores dos índices que estão entre a data inicial e a data de corte da correção
	cQuery := "SELECT NW6_VALOR VALOR, NW6_DTINDI AS DATA FROM "+RetSqlName("NW6")+" NW6 "
	cQuery += "WHERE NW6_FILIAL = '"+xFilial("NW6")+"' AND NW6.D_E_L_E_T_ = ' ' "
	If Empty(cDtValor)
		//alterada a query para trazer de uma vez os três meses de não atualização permitidos.
		cQuery += "AND NW6_CINDIC ='"+cIndice+"' AND NW6_DTINDI BETWEEN '"+dtos(MonthSub(stod(cNvData), 3)) +"' AND '"+cNvData+"'
	Else
		cDtValor := LEFT(cDtValor,6) + '01'
		cQuery += "AND NW6_CINDIC ='"+cIndice+"' AND NW6_DTINDI BETWEEN '"+cDtValor+"' AND '"+cNvData+"'
	EndIf

	//ordenado decrescente para dar preferência ao índice mais atual
	cQuery += " ORDER BY NW6_DTINDI"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	//valida se a query retornou dados, se a data é atual ou pelo menos de até 3 meses atrás ou se existe um intervalo de datas e por isso deve alimentar o array
	While !(cAlias)->( EOF() )
		fValorInd := DEC_CREATE((StrTran(Alltrim(str((cAlias)->VALOR)), ',', '.')),64,18)
		lAchou    := .T.
		If !Empty(cDtValor)
			//se existe um intervalo de datas, ele vai incluindo no array para retornar mais de um resultado.
			aAdd(aVldInd,{JSToFormat((cAlias)->DATA,'YYYYMM'),fValorInd})
			(cAlias)->( dbSkip() )
		Else
			//se não for um intervalo de datas, sai da rotina e retorna só um valor.
			Exit
		EndIf
	EndDo

	(cAlias)->( dbcloseArea() )


	If !lAchou
		fValorInd := DEC_CREATE("0",64,18)
		cDescInd  := JurGetDados('NW5', 1 , xFilial('NW5') + cIndice , 'NW5_DESC')

		If lTemIndice .And. lMsg .And. !lIgual
			If ( aScan( aMsgErr , {  |x| (STR0006 + cDescInd ) $ x } ) == 0 )
				aAdd ( aMsgErr, STR0006 + cDescInd + " : " + cValToChar(stod(cDtCorte)) )
			EndIf
		EndIf

		lTemIndice := lAchou .And. !lIgual

		If !Empty(cDtValor)
			aAdd(aVldInd,{JSToFormat(cNvData,'YYYYMM'),fValorInd})
		EndIf

	EndIf

	If cIndice == '05' .Or. cIndice == '28'//Se for selic o calculo não é juros sobre juros
		nVldInd := DEC_CREATE("1",64,18)
	Else
		nVldInd := aVldInd[1][2] //pega o primeiro valor
	EndIf

	While (AnoMes(dProxMes) <= AnoMes(dDtCorte)) .OR. (lAnoMes .And. AnoMes(dProxMes) <= AnoMes(dDtCorte))
		If cIndice == '05' .Or. cIndice == '28'//Se for selic o calculo não é juros sobre juros
			nIndAcum := (Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 ))) + nIndAcum)
		Else
			If lSoma //Se for o primeiro índice da fila


				If AnoMes(dProxMes) == '199406'
					nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 2750
				ElseIf AnoMes(dProxMes) == '199307'
					nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
				ElseIf AnoMes(dProxMes) == '198901'
					nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
				ElseIf AnoMes(dProxMes) == '198602'
					nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
				Else
					nIndAcum := ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1)
				Endif
			Else
				If AnoMes(dProxMes) == '199406'
					nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 2750
				ElseIf AnoMes(dProxMes) == '199307'
					nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
				ElseIf AnoMes(dProxMes) == '198901'
					nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
				ElseIf AnoMes(dProxMes) == '198602'
					nIndAcum := nIndAcum * ((Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))/100) + 1) / 1000
				Else
					nIndAcum := (nIndAcum * Val(cValToChar(DEC_RESCALE (nVldInd, 8, 0 )))) / 100 + nIndAcum
				Endif
			Endif
		EndIf
		dProxMes := MonthSum(dProxMes,1)
		If ( AnoMes(dProxMes) == AnoMes(dDtCorte) .and. Day(dDtCorte) <= Day(dProxMes)) .Or. (len(aVldInd)==1) .Or. ; //se é o mês de corte ou tem somente um mês
			(nPosInd := aScan(aVldInd,{|x| x[1] == AnoMes(dProxMes) })) == 0//se não existem valores
			Exit
		Else
			nVldInd := aVldInd[nPosInd][2]
		EndIf
		lSoma   := .F.

	EndDo
	RestArea(aAreaNW6)
	RestArea(aAreaNW5)
	RestArea(aArea)

Return nIndAcum

//----------------------------------------------------------------------------------------
// AJUSTE PALIATIVO, COLOCANDO A FORMA ANTIGA DE CALCULO ATÉ QUE SEJA FEITA A VIRADA DA VERSÃO
//----------------------------------------------------------------------------------------
/*/{Protheus.doc} J02AVTJAnt
Rotina de calculo de valores do TJ da forma antiga
@param cFormula	FÓrmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/11
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function J02AVTJAnt(cFormula, cAnoMes, lMsg,aMsgErr)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := 0
	Local nPosIni2 := 0
	Local nPosIni3 := 0
	Local nPosIni4 := 0
	Local nPosIni5 := 0
	Local nPosIni6 := 0
	Local nPosIni7 := 0
	Local nPosFin  := 0
	Local nPosFin2 := 0
	Local nPosFin3 := 0
	Local nPosFin4 := 0
	Local nPosFin5 := 0
	Local nPosFin6 := 0
	Local nPosFin7 := 0
	Local cParam   := ''
	Local cParam2  := ''
	Local cParam3  := ''
	Local cParam4  := ''
	Local cParam5  := ''
	Local cParam6  := ''
	Local cParam7  := ''
	Local nValor   := 0

	Default aMsgErr  := {}

	While At('FN_VALORPTJ(', cResult) > 0

		nPosIni := At('FN_VALORPTJ(', cResult) + 12
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(',', SubStr(cResult,nPosIni6,Len(cResult)))

		nPosIni7:= nPosIni6 + nPosFin6
		nPosFin7:= At(')', SubStr(cResult,nPosIni7,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2,nPosFin2-1)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4+1,nPosFin4-3)
		cParam5 := SubStr(cReSult,nPosIni5,nPosFin5-1)
		cParam6 := SubStr(cReSult,nPosIni6+1,nPosFin6-3)
		cParam7 := SubStr(cResult,nPosIni7+1,nPosFin7-1-2)

		nValor  := JA002TJAnt(cParam,Val(cParam2),cParam3,cParam4,cParam5,cParam6, cParam7, cAnoMes, lMsg,aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

Return cResult
//-------------------------------------------------------------------
/*/{Protheus.doc} JA002TJAnt(cDtValor, nValorBase, cDtCorte, cInd, cDtJuros)
Rotina de calculo de valores do TJ FORMA ANTIGA
@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor será corrigido)
@param cInd        Código do Indice 
@param cDtJuros   Data do Juros
@author Clóvis Eduardo Teixeira

@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function JA002TJAnt(cDtValor, nValorBase, cDtCorte, cInd, cPorcJur, cTipo, cDtJuros, cAnoMes, lMsg,aMsgErr)
	Local aArea      := GetArea()
	Local nVlrIndAtu := JA002VInd(cInd,cDtCorte, cAnoMes, lMsg)
	Local nVlrIndAnt := JA002VInd(cInd,cDtValor, cAnoMes, lMsg)
	Local nVlrCorig  := nValorBase/Val(cValToChar(DEC_RESCALE (nVlrIndAnt, 8, 0 ))) * Val(cValToChar(DEC_RESCALE (nVlrIndAtu, 8, 0 )))
	Local nVlrJuros  := 0
	Local nVlrAtu    := 0
	Local nVlrMisto1 := 0
	Local nVlrMisto2 := 0
	Local nQtdDias   := 0
	Local nQtdJuros  := 0
	Local cDtJurM1   := '10/01/2003'
	Local cDtJurM2   := '11/01/2003'

	Default aMsgErr  := {}

	nAtuCorre := 0
	nAtuJuros := 0

	If cTipo == 'S'


		nVlrJuros := (DateDiffDay(sTod(cDtCorte), sTod(cDtJuros))) * (Val(cPorcJur) / 30) * nVlrCorig
		nVlrAtu   := nVlrCorig + nVlrJuros

		nAtuJuros := nVlrJuros

	ElseIf cTipo == 'M'

		If sTod(cDtJuros) <= cTod(cDtJurM1)

			nVlrMisto1 := ((DateDiffDay(cTod(cDtJurM1), STOD(cDtJuros))) * Val('0.005') / 30) * nVlrCorig

		Endif

		If sTod(cDtJuros) >= cTod(cDtJurM2)
			//nVlrMisto2 := ((DateDiffDay(sTod(cDtJuros), Date())) * Val(cPorcJur) / 30) * nVlrCorig
			nVlrMisto2 := ((DateDiffDay(sTod(cDtJuros), STOD(cDtCorte))) * Val(cPorcJur) / 30) * nVlrCorig
		Else
			//nVlrMisto2 := ((DateDiffDay(cTod(cDtJurM2), Date())) * Val(cPorcJur) / 30) * nVlrCorig
			nVlrMisto2 := ((DateDiffDay(cTod(cDtJurM2), STOD(cDtCorte))) * Val(cPorcJur) / 30) * nVlrCorig
		Endif

		nVlrAtu := nVlrMisto1 + nVlrMisto2 + nVlrCorig

		nAtuJuros := nVlrMisto1 + nVlrMisto2

	ElseIf cTipo == 'C'

		nQtdDias  := (DateDiffDay(sTod(cDtCorte), sTod(cDtJuros)))
		nQtdJuros := (( 1 + Val(cPorcJur)) ^ (nQtdDias/30)-1)
		nVlrJuros := nVlrCorig * nQtdJuros
		nVlrAtu   := nVlrCorig + nVlrJuros

		nAtuJuros := nVlrJuros

	Endif

	If JSToFormat(cDataBase,'YYYYMM') <= '199406'
		nAtuCorre := nVlrCorig
	Else
		nAtuCorre := nVlrCorig - nValorBase
	Endif

	RestArea(aArea)

Return nVlrAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VPRCOM
Substitui o resultado da expressão da função composta FORMA ANTIGA
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA02VCOMAnt(cFormula, cAnoMes, lMsg,aMsgErr)
	Local aArea   := GetArea()
	Local cResult := cFormula
	Local nPosIni := 0
	Local nPosIni2:= 0
	Local nPosIni3:= 0
	Local nPosIni4:= 0
	Local nPosIni5:= 0
	Local nPosIni6:= 0
	Local nPosFin := 0
	Local nPosFin2:= 0
	Local nPosFin3:= 0
	Local nPosFin4:= 0
	Local nPosFin5:= 0
	Local nPosFin6:= 0
	Local cParam  := ''
	Local cParam2 := ''
	Local cParam3 := ''
	Local cParam4 := ''
	Local cParam5 := ''
	Local cParam6 := ''
	Local nValor  := 0
	Default aMsgErr := {}

	While At('FN_COMPOSTO(', cResult) > 0

		nPosIni := At('FN_COMPOSTO(', cResult) + 11
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(')', SubStr(cResult,nPosIni6,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+2,nPosFin-1-3)
		cParam2 := SubStr(cResult,nPosIni2,nPosFin2-1)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4+1,nPosFin4-1-2)
		cParam5 := SubStr(cResult,nPosIni5,nPosFin5-1)
		cParam6 := SubStr(cResult,nPosIni6+1,nPosFin6-1-2)

		nValor  := JA02PCOMAnt(cParam,Val(cParam2),cParam3,cParam4,Val(cParam5), cParam6,cAnoMes, lMsg,@aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-12)+AllTrim( Str(nValor) )+ SubStr(cResult,nPosIni6+nPosFin6,Len(cResult))
	End

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA02PCOMAnt(cDtValor, nValorBase, cDtCorte, cIndice, cJuros)
Rotina de calculo de juros compostos FORMA ANTIGA

@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor seró corrigido)
@param cIndice    Indice monetário que seró utilizado para correção
@author Clóvis Eduardo Teixeira
@since 28/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA02PCOMAnt(cDtValor, nValorBase, cDtCorte, cIndice, cJuros, cDtJuros, cAnoMes, lMsg,aMsgErr)
	Local aArea     := GetArea()
	Local nVlrInd   := JA002PInd(cDtValor, cDtCorte, cIndice, .T., 0, cAnoMes, lMsg,@aMsgErr)
	Local nVlrJur   := JA002PJur(cDtJuros, cDtCorte, cIndice, .T., 0, cJuros)
	Local nValInd   := nVlrInd * nVlrJur
	Local nValorAtu := 0
	Default aMsgErr := {}

	If nVlrJur == 0
		nValInd := 1+(nVlrInd/100)
		nVlrJur := 1
	Endif

	nValorAtu := (round((nValorBase * nVlrInd),2) - nValorBase) + (round((round((nValorBase * nVlrInd),2) * nVlrJur),2) - round((nValorBase * nVlrInd),2)) + nValorBase

	nAtuCorre := (nValorBase * nVlrInd) - ConvMoeda(cDtValor, nValorBase)
	nAtuJuros	:= (((nValorBase * nVlrInd) * nVlrJur) - (nValorBase * nVlrInd))

	RestArea(aArea)

Return nValorAtu

//---------------------------------------------------------------------
/*/{Protheus.doc} JA002PJur(cDtValor, cDtCorte, cIndice, lSoma, nIndAcum)
Rotina para calculo de juros compostos entre dois periodos
@param cDtValor  Data Base do Valor
@param cDtCorte  Data de Corte (até que data o valor será corrigido)
@param cIndice   Indice monetário que será utilizado para correção
@param lSoma     Flag para determinar se deve ser somado o valor do mes anterior
@param nIndAcum  Valor do Indice Acumulado
@author Clóvis Eduardo Teixeira
@since 23/03/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function JA002PJur(cDtValor, cDtCorte, cIndice, lSoma, nJurAcum, nJuros)
	Local aArea      := GetArea()
	Local dMesAnt    := stod(cDtCorte)
	Local cData      := AnoMes(stod(cDtCorte)) +'01'
	Local cAmesValor := ""
	Local nDIf       := 0
	Local nCt        := 0
	Local lJurSeg    := (SuperGetMV('MV_JJURSEG',, '1') == '1') // Indica se será aplicada uma margem de segurança na aplicação dos juros.

	If (!Empty(cDtValor) .And. nJuros > 0) //valida se existe juros que deve ser calculado


		If Empty(Posicione('NW6', 3 , xFilial('NW6') + cIndice + cData, 'NW6_COD'))
			dMesAnt := MonthSub(dMesAnt,1)
			cData   := AnoMes(dMesAnt) +'01'
			If Empty(Posicione('NW6', 3 , xFilial('NW6') + cIndice + cData, 'NW6_COD'))
				dMesAnt := MonthSub(dMesAnt,1)
			EndIf
		EndIf

		If lJurSeg

		/*
		
			Parâmetro habilitado (Valor = 1) 
	
			O juros será aplicado levando em consideração o mês completo 	da data do valor e o mês completo 
			da data de correção. 
			Por exemplo: Data do valor é 27/12/14 e data atual é 04/07/15, ao corrigir o valor será aplicado
			juros considerando também o mês de dezembro de 2014 todo e o mês de julho de 2015 todo. 
			Com isso o juros é aplicado para os meses 12/2014, 01/2015, 02/2015, 03/2015, 04/2015, 05/2015,
			06/2015 e 07/2015.
	
		*/

			cAmesValor := AnoMes(stod(cDtValor))

			While AnoMes(dMesAnt) >= cAmesValor

				If lSoma
					nJurAcum := (nJuros/100) + 1
				Else
					nJurAcum := nJurAcum * ((nJuros/100) + 1)
				Endif

				dMesAnt := MonthSub(dMesAnt,1)
				lSoma   := .F.

			EndDo

		Else

		/*
		
			Parâmetro desabilitado (Valor = 2)
			
			O juros será aplicado levando em consideração a data de "aniversário" do valor. 
			Por exemplo: Data do valor é 27/12/14 e data atual é 04/07/15, ao corrigir o valor será aplicado
			juros considerando a data de "aniversário" do valor.
			Com isso o juros é aplicado para os meses 01/2015, 02/2015, 03/2015, 04/2015, 05/2015 e
			06/2015. Só considerará o mês 07/2015 caso a correção seja a partir do dia de "aniversário" do 
			valor que é dia 27 de cada mês.
	
		*/

			nDIf := DateDiffDay(stod(cDtValor), dMesAnt) / 30.4375 //divisão pela quantidade de dias para avaliar a diferença de meses de forma correta

			For nCt:=0 to nDif
				If (nCt == 0)
					nJurAcum := (nJuros/100) + 1
				Else
					nJurAcum := nJurAcum * ((nJuros/100) + 1)
				Endif
			Next

		EndIf

	Endif

	RestArea(aArea)

Return nJurAcum
//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VPROR
Substitui o resultado da expressão da função composta
@param cFormula	Fórmula
@return cResult Resultado da expressão
@author Clóvis Eduardo Teixeira
@since 04/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002VPROR(cFormula, cAnoMes, lMsg, aMsgErr)
	Local aArea    := GetArea()
	Local cResult  := cFormula
	Local nPosIni  := 0
	Local nPosIni2 := 0
	Local nPosIni3 := 0
	Local nPosIni4 := 0
	Local nPosIni5 := 0
	Local nPosIni6 := 0
	Local nPosIni7 := 0
	Local nPosFin  := 0
	Local nPosFin2 := 0
	Local nPosFin3 := 0
	Local nPosFin4 := 0
	Local nPosFin5 := 0
	Local nPosFin6 := 0
	Local nPosFin7 := 0
	Local cParam   := ''
	Local cParam2  := ''
	Local cParam3  := ''
	Local cParam4  := ''
	Local cParam5  := ''
	Local cParam6  := ''
	Local cParam7  := ''
	Local nValor   := 0
	Default aMsgErr := {}

	While At('FN_VALORPRO(', cResult) > 0

		nPosIni := At('FN_VALORPRO(', cResult) + 12
		nPosFin := At(',', SubStr(cResult,nPosIni,Len(cResult)))

		nPosIni2:= nPosIni + nPosFin
		nPosFin2:= At(',', SubStr(cResult,nPosIni2,Len(cResult)))

		nPosIni3:= nPosIni2 + nPosFin2
		nPosFin3:= At(',', SubStr(cResult,nPosIni3,Len(cResult)))

		nPosIni4:= nPosIni3 + nPosFin3
		nPosFin4:= At(',', SubStr(cResult,nPosIni4,Len(cResult)))

		nPosIni5:= nPosIni4 + nPosFin4
		nPosFin5:= At(',', SubStr(cResult,nPosIni5,Len(cResult)))

		nPosIni6:= nPosIni5 + nPosFin5
		nPosFin6:= At(',', SubStr(cResult,nPosIni6,Len(cResult)))

		nPosIni7:= nPosIni6 + nPosFin6
		nPosFin7:= At(')', SubStr(cResult,nPosIni7,Len(cResult)))

		cParam  := SubStr(cResult,nPosIni+1,nPosFin-1-2)
		cParam2 := SubStr(cResult,nPosIni2,nPosFin2-1)
		cParam3 := SubStr(cResult,nPosIni3+1,nPosFin3-1-2)
		cParam4 := SubStr(cResult,nPosIni4,nPosFin4-1)
		cParam5 := SubStr(cReSult,nPosIni5+1,nPosFin5-3)
		cParam6 := SubStr(cReSult,nPosIni6,nPosFin6-1)
		cParam7 := SubStr(cResult,nPosIni7+1,nPosFin7-3)

		nValor  := JA02ProRat(cParam,Val(cParam2),cParam3,cParam4,cParam5,cParam6, cParam7,cAnoMes, lMsg,@aMsgErr)
		cResult := SubStr(cResult,1,nPosIni-13)+AllTrim(Str(nValor))
	EndDo

	RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA02ProRat(cDtValor, nValorBase, cDtCorte, cPorcJur, cIndice, cMesInd, cJuros)
Rotina de calculo de juros Pró-Rata-Die

@param cDtValor   Data Base do Valor
@param nValorBase Valor Base a ser corrigido
@param cDtCorte   Data de Corte (até que data o valor será corrigido)
@param cPorcJur   Porcentagem de juros a ser aplicado sobre o valor
@param cIndice    Código do Indice Monetário
@param cMesInd    Quantidade de meses a adicionar o subtrair para calculo do indice
@author Clóvis Eduardo Teixeira
@since 01/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA02ProRat(cDtValor, nValorBase, cDtCorte, cPorcJur, cIndice, cMesInd, cDtJuros, cAnoMes, lMsg,aMsgErr)
	Local aArea      := GetArea()
	Local nValorInd  := 0
	Local nValorAtu  := 0
	Local nValorJur  := 0
	Local nValorTot  := 0
	Default aMsgErr  := {}

	nAtuJuros := 0

	If !cMesInd == '0'
		nValorInd := JA002VInd(cIndice,JurDtAdd(cDtValor, 'M', Val(cMesInd)),cAnoMes,, lMsg,,@aMsgErr)
	Else
		nValorInd := JA002VInd(cIndice,cDtValor,cAnoMes,, lMsg,,@aMsgErr)
	Endif

	nValorAtu := (Val(cValToChar(DEC_RESCALE (nValorInd, 8, 0 ))) * nValorBase)


	If !(cIndice $ "06/09/11/13/15/16/18/19/23/27")  //Não deve ocorrer divisão para estes indices pois a divisão de anos é realizada na planilha

		nValorAtu := ConvMoeda(cDtValor, nValorAtu)

	Endif
	If cIndice $ ('11|15|16')
		nValorJur := (DateDiffDay(STOD(cDtJuros), STOD(cDtCorte))) / 30 * Val(cPorcJur)
	Else
		nValorJur := (DateDiffDay(STOD(cDtJuros), STOD(cDtCorte))) / 30.4375 * Val(cPorcJur)
	EndIf

	nValorTot := nValorAtu * nValorJur

	nAtuJuros := nValorTot

	RestArea(aArea)

Return nValorTot

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvMoeda(cDtValor, nValor)
Converte moedas brasileiras para Real

@param cDtValor  Data Base do Valor
@param nValor    Valor Base a ser corrigido

@since 24/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConvMoeda(cDtValor, nValor)

	cDtValor := JSToFormat(cDtValor,'YYYYMM') 

	If cDtValor <= '198602'
		nValor := ((((nValor /2750) /1000) /1000) / 1000)
	ElseIf cDtValor <= '198901'
		nValor := (((nValor /2750) /1000) / 1000)
	ElseIf cDtValor <= '199307'
		nValor := ((nValor /2750) /1000)
	ElseIf cDtValor <= '199406'
		nValor := (nValor /2750)
	EndIf

Return nValor
