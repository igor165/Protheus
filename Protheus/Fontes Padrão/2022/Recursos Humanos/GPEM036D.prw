#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static cVersEnvio	:= "2.4"
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM036D
@Author   Alessandro Santos 
@Since    18/03/2019 
@Version  1.0 
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1300
/*/
Function GPEM036D()
Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fNew1300()     ³Autor³  Marcia Moura     ³ Data ³10/07/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Gera o registro de Contribuicao Patronal                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM034                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Nil															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nil															³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function fNew1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, aLogsErr)

	Private lRobo := IsBlind()

	If lRobo
		fFaz1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, .F., aLogsErr)
	Else
		Proc2BarGauge( {|lEnd| fFaz1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, .T., aLogsErr)}, "Evento S-1300", NIL , NIL , .T. , .T. , .F. , .F. )
	EndIf

Return .T.

/*/{Protheus.doc} fFaz1280
Gera o evento S-1280

@type 		Static Function
@author		Sivio C. Stecca
@since		27/03/2020
@version	12.1.XX
@param 		cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, lNewProgres, aLogsErr
/*/
Static Function fFaz1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, lNewProgres, aLogsErr)

Local aArea			:= GetArea()
Local cTpFolha		:= IIF(lIndic13, "2", "1") //Tipo de folha 1 = Mensal / 2 = 13 Salario
Local nI			:= 0
Local aFilInTaf 	:= {}
Local cAno 			:= substr(cCompete,3,4)
Local cMes 			:= substr(cCompete,1,2)
Local cXml 			:= ""
Local cFilEnv 		:= ""
Local cFilPrc 		:= ""
Local cCGC			:= ""
Local cStatus 		:= ""
Local cAliasRCT 	:= GetNextAlias()
Local nCont			:= 0
Local cMsgErro  	:= ""
Local nVldOpcoes	:= 0

Local aErros		:= {}
Local nRecEvt		:= 0
Local cChaveMid		:= ""
Local cTpInsc		:= ""
Local cNrInsc		:= ""
Local cIdXml		:= ""
Local cRecibo		:= ""
Local cRcbAnt		:= ""
Local cRetfRJE		:= ""
Local cRetfNew		:= ""
Local cStatNew		:= ""
Local cOperNew		:= ""
Local cOpcRJE		:= ""	
Local cVersMw		:= ""
Local lAdmPubl		:= .F.
Local lNovoRJE		:= .F.
Local aInfoC		:= {}
Local aDados		:= {}
Local cRecibXML		:= ""
Local cFilIn		:= ""
Local cRaiz			:= ""
Local nPosSM0		:= 0
Local nTotRec		:= 0
Local cTimeIni		:= Time()

Private aSM0     	:= FWLoadSM0(.T.)

Default aCheck		:= {.F., .F., .F., .F., .F., .F., .F., .F., .F., .F.}
Default lNewProgres := .F.

If !lMiddleware
	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	If Empty(aFilInTaf)
		MsgAlert( STR0065 + CRLF + STR0066 )//"Não foi encontrada a filial de referência do TAF para a importação das informações."##"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
		Return .F.
	EndIf
Else
	If Empty(aArrayFil)
		MsgAlert( STR0167 + CRLF + STR0066 )//"Não foi encontrada a filial de referência do Middleware para a importação das informações."##"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
		Return .F.
	EndIf
EndIf

//Inicia array de verificação abertura e fechamento
For nI := 1 To If(!lMiddleware, Len(aFilInTaf), Len(aArrayFil))
		If (!lMiddleware .And. !aFilInTaf[nI, 4]) .Or. (lMiddleware .And. !(fVldMatriz(aArrayFil[nI], cAno+cMes) == aArrayFil[nI])) 		//Não é matriz
			Loop
		EndIf
		cFilIn	:= ""
		cStatus	:= "-1"
		If !lMiddleware
			cFilPrc 	:= aFilInTaf[nI, 2]
			nPosSM0		:= aScan( aSM0, { |x| x[1] == cEmpAnt .And. x[2] == aFilInTaf[nI, 2] } )
		Else
			cFilPrc 	:= aArrayFil[nI]
			nRecEvt		:= 0
			cChaveMid	:= ""
			cTpInsc		:= ""
			cNrInsc		:= ""
			cIdXml		:= ""
			cRecibo		:= ""
			cRcbAnt		:= ""
			cRetfRJE	:= ""
			cOperNew 	:= ""
			cRetfNew	:= ""
			cStatNew	:= ""
			lNovoRJE	:= .F.
			lAdmPubl	:= .F.
			cRecibXML	:= ""
			aDados		:= {}
			aInfoC		:= {}
			nPosSM0		:= aScan( aSM0, { |x| x[1] == cEmpAnt .And. x[2] == aArrayFil[nI] } )
		EndIf
		If nPosSM0 > 0
			If !lMiddleware
				If cTpFolha == "2"
					cStatus := TAFGetStat( "S-1300", cTpFolha+";"+cAno, , , 2 )
				else
					cStatus := TAFGetStat( "S-1300", cTpFolha+";"+cAno+cMes, , , 2 )
				endif
			Else
				fPosFil( cEmpAnt, aArrayFil[nI] )
				aInfoC   := fXMLInfos()
				If Len(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
					cIdXml   := aInfoC[3]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				//Monta chave e Pesquisa o status do evento na tabela RJE pela chave RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI 
				cChaveMid := cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1300" + cFilPrc + If(cTpFolha == "1", cAno+cMes + cTpFolha, cAno + cTpFolha)
				GetInfRJE( 2, cChaveMid, @cStatus, @cOpcRJE, @cRetfRJE, @nRecEvt, @cRecibo, @cRcbAnt)
			EndIf

			If cStatus == "2" 
				aAdd(aLogsErr,OemToAnsi(STR0016) + ": " + cFilPrc +  OemToAnsi(STR0015))
			Else
				nVldOpcoes := fVldOpcoes(aCheck, cStatus)

				If nVldOpcoes == 1
					Aadd(aLogsErr, "Registro S-1300  " +cFilPrc+ " - "+cAno+cMes+ OemToAnsi(STR0026) ) // #STR0026=" não foi sobrescrito."
					Loop
				ElseIf nVldOpcoes == 2
					Aadd(aLogsErr, "Registro S-1300  " +cFilPrc+ " - "+cAno+cMes+ OemToAnsi(STR0027) ) // #STR0027=" não foi retificado."
					Loop
				ElseIf nVldOpcoes == 3
					Aadd(aLogsErr, "Registro S-1300  " +cFilPrc+ " - "+cAno+cMes+ OemToAnsi(STR0028) ) // #STR0028=" desprezado pois está aguardando retorno do governo."
					Loop
				Endif

				If lMiddleware
					fVersEsoc( "S1300", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
					If cStatus == "-1"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
						//Evento sem transmissão, irá sobrescrever o registro na fila
					ElseIf cStatus $ "1/3"
						cOperNew 	:= cOpcRJE
						cRetfNew	:= cRetfRJE
						cStatNew	:= "1"
						lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
					ElseIf cOpcRJE != "E" .And. cStatus == "4"
						cOperNew 	:= "A"
						cRetfNew	:= "2"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
					ElseIf cOpcRJE == "E" .And. cStatus == "4"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					Else
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					EndIf
					If cRetfNew == "2"
						If cStatus == "4"
							cRecibXML 	:= cRecibo
							cRcbAnt		:= cRecibo
							cRecibo		:= ""
						Else
							cRecibXML 	:= cRcbAnt
						EndIf
					EndIf
				EndIf

				cRaiz	:= SubStr(aSM0[nPosSM0, 18], 1, 8)
				aEval( aSM0, { |x| Iif( x[1] == cEmpAnt .And. SubStr(x[18], 1, 8) == cRaiz, cFilIn += x[2], Nil ) } )
				cFilIn	:= "%" + fSqlIn(cFilIn, FwGetTamFilial) + "%"
				//Query para buscar informacoes Trabalhadores
				BeginSql alias cAliasRCT
					SELECT
						RCT_FILIAL,RCT_SIND,RCT_TPCONT,RCT_MES,RCT_ANO,RCT_VALOR
					FROM
						%table:RCT% RCT
					WHERE
						RCT.%notDel% AND
						RCT.RCT_FILIAL IN (%exp:cFilIn%) AND
						RCT.RCT_ANO IN ( %exp:cAno% ) AND
						RCT.RCT_MES IN ( %exp:cMes% )
					ORDER BY
						RCT.RCT_FILIAL, RCT.RCT_SIND
				EndSql
				dbSelectArea(cAliasRCT)

				If (cAliasRCT)->(!EOF())

					While (cAliasRCT)->(!EOF())

						nTotRec ++

						if nCont == 0
							If !lMiddleware
								cXml := '<eSocial>'
								cXml += '	<evtContrSindPatr>'
								cXml += '	<ideEvento>'

								If cStatus == '4'
									cXml += "<indRetif>2</indRetif>"
									If lMiddleware		
										cXml += '<nrRecibo>' + alltrim(cRcbAnt) + '</nrRecibo>'
									EndIf
								Endif

								cXml +='  <indApuracao>'+cTpFolha+'</indApuracao>'
								if cTpFolha == "2"
									cXml += '  <perApur>'+cAno+'</perApur>'
								else
									cXml += '  <perApur>'+cAno+"-"+cMes+'</perApur>'
								Endif
								cXml += '	</ideEvento>'
							Else
								cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtContrSindPatr/v" + cVersMw + "'>"
								cXml += "	<evtContrSindPatr Id='" + cIdXml + "'>"
								fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), cTpFolha, If(cTpFolha == "1", cAno+"-"+cMes, cAno), "2", 1, "12" } )//<ideEvento>
								fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
							EndIf
						endif

						cCGC := fLeRCECNPJ((cAliasRCT)->RCT_FILIAL,(cAliasRCT)->RCT_SIND)

						cXml += '	<contribSind>'

						cXml += '  <cnpjSindic>'+cCGC+'</cnpjSindic>'
						if (cAliasRCT)->RCT_TPCONT ==  "1"
							cXml += '  <tpContribSind>2</tpContribSind>'
						elseif (cAliasRCT)->RCT_TPCONT == "2"
							cXml += '  <tpContribSind>1</tpContribSind>'
						else
							cXml += '  <tpContribSind>'+(cAliasRCT)->RCT_TPCONT+'</tpContribSind>'
						Endif
						If !lMiddleware
							cXml += '  <vlrContribSind>'+AllTrim( Transform((cAliasRCT)->RCT_VALOR,"@E 999999999.99") )+'</vlrContribSind>'
						Else
							cXml += '  <vlrContribSind>'+AllTrim( Str((cAliasRCT)->RCT_VALOR) )+'</vlrContribSind>'
						EndIf
						cXml += '	</contribSind>'
						nCont := 1
						dbSelectArea(cAliasRCT)
						dbSkip()
					EndDo

					cXml += '</evtContrSindPatr>'
					cXml += '</eSocial>'

					GrvTxtArq(cXml, "S1300")
					If !lMiddleware
						aErros := TafPrepInt( cEmpAnt, cFilPrc, cXml, , "1", "S1300")
					Else
						aAdd( aDados, { xFilial("RJE", cFilPrc), cFilPrc, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1300", If( cTpFolha == "1", cAno+cMes, cAno), cFilPrc + If(cTpFolha == "1", cAno+cMes + cTpFolha, cAno + cTpFolha), cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, cRecibo, cRcbAnt } )
						If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
							aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
						EndIf
					EndIf
					If Len( aErros ) > 0
						cMsgErro := ''
						If !lMiddleware
							FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
							FormText(@cMsgErro)
						Else
							For nCont := 1 To Len(aErros)
								cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
							Next nCont
						EndIf
						aErros[1] := cMsgErro

						aAdd(aLogsErr, aErros[1] )
					Else
						If !lMiddleware
							aAdd(aLogsOk, OemToAnsi(STR0020) + cFilPrc + OemToAnsi(STR0019) ) //##"Contribuicoes Patronais, da Filial: "##" Integrados com TAF."
						Else
							aAdd(aLogsOk, OemToAnsi(STR0020) + cFilPrc + OemToAnsi(STR0165) ) //##"Contribuicoes Patronais, da Filial: "##" Integrados com Middleware."
						EndIf
						aAdd(aLogsOk, "" )
					Endif
					nCont := 0

				Endif

				If !lRobo .And. lNewProgres
					BarGauge1Set(nTotRec)
					IncPrcG1Time("Recibo: " + Alltrim(cRcbAnt) + " Período Apuração: " + cAno + "-" + cMes, nTotRec, cTimeIni, .T., 1, 1, .T.)
				EndIf

				(cAliasRCT)->( dbCloseArea() )
			EndIf
		EndIf
Next nI

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fleRCECNPJ  ³ Autor ³ Mauricio MR               ³ Data ³ 03/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o CNPJ do Sindicato		                			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fBuscRCECGC(cFil)													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM530   												        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fLeRCECNPJ( cFil, cSindica )
Local cCNPJ		:= ""

cFil := xFilial( "RCE", cFil )

dbSelectArea( "RCE" )
RCE->(dbSetOrder(1))

If RCE->( Dbseek( cFil + cSindica ) )
    cCNPJ :=  RCE->RCE_CGC
Endif

Return ( cCNPJ )

/*/{Protheus.doc} fVldMatriz
Função que verifica se a filial que foi configurada como matriz no middleware
@author lidio.oliveira
@since 19/11/2019
@version 1.0
@return cMatriz - Código da Matriz
/*/
Static Function fVldMatriz( cFilEnv, cPeriodo )

	Local aAreaSM0		:= SM0->( GetArea() )
	Local cMatriz		:= ""
	Local nFilEmp		:= 0
	Local cStatus		:= "-1"

	Default cFilEnv		:= cFilAnt
	Default cPeriodo 	:= AnoMes(dDatabase)

	If lMiddleware
		fPosFil( cEmpAnt, cFilEnv )
		If fVld1000( cPeriodo, @cStatus)
			If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == AllTrim(RJ9->RJ9_NRINSC) }) ) > 0
				cMatriz := aSM0[nFilEmp, 2]
			EndIf
		Else
			Do Case 
				Case cStatus == "-1" // nao encontrado na base de dados
					aAdd( aLogsErr, OemToAnsi(STR0002) + cFilEnv + OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX não localizado na base de dados"
				Case cStatus == "1" // nao enviado para o governo
					aAdd( aLogsErr, OemToAnsi(STR0002) + cFilEnv + OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX não transmitido para o governo"
				Case cStatus == "2" // enviado e aguardando retorno do governo
					aAdd( aLogsErr, OemToAnsi(STR0002) + cFilEnv + OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
				Case cStatus == "3" // enviado e retornado com erro 
					aAdd( aLogsErr, OemToAnsi(STR0002) + cFilEnv + OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
			EndCase
		EndIf
	EndIf

	RestArea(aAreaSM0)

Return cMatriz