#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM036C
@Author   Alessandro Santos
@Since    18/03/2019
@Version  1.0
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1280
/*/
Function GPEM036C()
Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fNew1280()     ³Autor³  Marcia Moura     ³ Data ³26/06/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Gera o registro de desoneração                              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM034                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Nil															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nil															³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
Function fNew1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, aLogsErr, cVersEnvio)

	Default cVersEnvio	:= ""
	Default aLogsErr	:= {}

	Private lRobo := IsBlind()

	If lRobo
		fFaz1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, .F., aLogsErr, cVersEnvio)
	Else
		Proc2BarGauge( {|lEnd| fFaz1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, .T., aLogsErr, cVersEnvio)}, "Evento S-1280", NIL , NIL , .T. , .T. , .F. , .F. )
	EndIf

Return

/*/{Protheus.doc} fFaz1280
Gera o evento S-1280

@type 		Static Function
@author		Sivio C. Stecca
@since		27/03/2020
@version	12.1.XX
@param 		cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, lNewProgres, aLogsErr
/*/
Static Function fFaz1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, aCheck, lNewProgres, aLogsErr, cVersEnvio)

	Local cTpFolha		:= IIF(lIndic13, "2", "1") //Tipo de folha 1 = Mensal / 2 = 13 Salario
	Local nI			:= 0
	Local nVldOpcoes	:= 0
	Local aFilInTaf 	:= {}
	Local cAno 			:= substr(cCompete,3,4)
	Local cMes 			:= substr(cCompete,1,2)
	Local dDataRef 		:= cToD( "01/" + cMes + "/" + cAno )
	Local cStatus	 	:= ""
	Local cFilEnv 		:= ""
	Local cMsgErro 		:= ""
	Local lFirst		:= .T.
	Local aErros		:= {}

	Local aInssEmp 		:= {}
	Local aTabS033 		:= {}

	//Variáveis utilizadas no middleware
	Local nCont			:= 0
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
	Local cPerc			:= ""
	Local lAdmPubl		:= .F.
	Local lNovoRJE		:= .F.
	Local aInfoC		:= {}
	Local aDados		:= {}
	Local cRecibXML		:= ""
	Local nTotRec		:= 0
	Local cTimeIni		:= Time()
	Local cPerApur		:= Iif(cTpFolha == "2", cAno, cAno+"-"+cMes)
	Local cnrRecibo		:= Nil
	Local cPerc11096	:= ""

	Private aSM0     	:= FWLoadSM0(.T.)

	Default aCheck		:= {.F., .F., .F., .F., .F., .F., .F., .F., .F., .F.}
	Default lNewProgres	:= .F.
	Default cVersEnvio	:= ""
	Default aLogsErr	:= {}


	SetMnemonicos(xFilial("RCA"), NIL, .T., "P_RECDES")

	P_RECDES := If (Type("P_RECDES") == "U" .OR. EMPTY(P_RECDES), "A", P_RECDES)

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
	EndIf

	If !lMiddleware .And. Empty(aFilInTaf)
		MsgAlert( STR0065 + CRLF + STR0066 )//"Não foi encontrada a filial de referência do TAF para a importação das informações."##"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
		Return .F.
	ElseIf lMiddleware .And. Empty(aArrayFil)
		MsgAlert( STR0167 + CRLF + STR0066 )//"Não foi encontrada a filial de referência do Middleware para a importação das informações."##"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
		Return .F.
	EndIf

	If cTpFolha == "1"
		fCarrTab( @aTabS033, "S033", dDataRef, .T. )
	Else
		fCarrTab( @aTabS033, "S033", Nil, .T. , cAno + "13" )
	EndIf

	cAnoMes := cAno +cMes

	//Inicia array de verificação abertura e fechamento
	For nI := 1 To If (!lMiddleware, Len(aFilInTaf), Len(aArrayFil))
		nTotRec ++

		If !lMiddleware
			If !aFilInTaf[nI,4] 		//Não é matriz
				Loop
			Else
				cFilEnv := aFilInTaf[nI, 2]
				fInssEmp(cFilEnv, @aInssEmp, Nil, cAno+cMes)
			Endif
		Else
			//Reinicializa variáveis do Middleware
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

			If !(fVldMatriz(aArrayFil[nI],cAnoMes,@aLogsErr) == aArrayFil[nI])
				Loop
			Else
				cFilEnv := aArrayFil[nI]
				fInssEmp(cFilEnv, @aInssEmp, Nil, cAno+cMes)
			EndIf
		EndIf

		If lFirst
			lFirst		:= .F.
			nRecBruta	:= 0
			nPerc1 		:= 0
			nRecBruND 	:= 0 //Receita Bruta nao desonerada
			//Apura a receita bruta total da empresa
			aEval(aTabS033, {|aTabS033| nRecBruta += aTabS033[10] } )
			//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
			aEval(aTabS033, {|aTabS033| If( aTabS033[6] == "2", nRecBruND += aTabS033[10], ) } )
			If P_RECDES $ "A|C"
				//Deduz as exclusoes da receita bruta total da empresa
				aEval(aTabS033, {|aTabS033| nRecBruta -= aTabS033[11] } )
				//Deduz as exclusoes da receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
				aEval(aTabS033, {|aTabS033| If( aTabS033[6] == "2", nRecBruND -= aTabS033[11], ) } )
			EndIF
			If P_RECDES $ "B|C"
				//Deduz as exportacoes da receita bruta total da empresa
				aEval(aTabS033, {|aTabS033| nRecBruta -= aTabS033[12] } )
				//Deduz as exportacoes da receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
				aEval(aTabS033, {|aTabS033| If( aTabS033[6] == "2", nRecBruND -= aTabS033[12], ) } )
			Endif
			//Deduz os impostos da receita bruta total da empresa
			aEval(aTabS033, {|aTabS033| nRecBruta -= aTabS033[13] } )
			//Deduz os impostos da receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
			aEval(aTabS033, {|aTabS033| If( aTabS033[6] == "2", nRecBruND -= aTabS033[13], ) } )
		EndIf
		
		If nRecBruta >= 0 .And. nRecBruND >= 0
			cStatus := ""

			If !lMiddleware
				If cTpFolha == "2"
					cStatus := TAFGetStat( "S-1280", cTpFolha+";"+cAno, , , 4 )
				Else
					cStatus := TAFGetStat( "S-1280", cTpFolha+";"+cAno+cMes, , , 4 )
				EndIf
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
				cChaveMid := cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1280" + cFilEnv + If(cTpFolha == "1", cAnoMes + cTpFolha, cAno + cTpFolha)
				GetInfRJE( 2, cChaveMid, @cStatus, @cOpcRJE, @cRetfRJE, @nRecEvt, @cRecibo, @cRcbAnt)
			EndIf

			nVldOpcoes := fVldOpcoes(aCheck, cStatus)

			If nVldOpcoes == 1
				Aadd(aLogsErr, "Registro S-1280  " +cFilEnv+ " - "+cAno+cMes+ OemToAnsi(STR0026) ) // #STR0026=" não foi sobrescrito."
				Loop
			ElseIf nVldOpcoes == 2
				Aadd(aLogsErr, "Registro S-1280  " +cFilEnv+ " - "+cAno+cMes+ OemToAnsi(STR0027) ) // #STR0027=" não foi retificado."
				Loop
			ElseIf nVldOpcoes == 3
				Aadd(aLogsErr, "Registro S-1280  " +cFilEnv+ " - "+cAno+cMes+ OemToAnsi(STR0028) ) // #STR0028=" desprezado pois está aguardando retorno do governo."
				Loop
			Endif

			If lMiddleware
				fVersEsoc( "S1280", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
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

			If cStatus == "2"
				If !lMiddleware
					aAdd(aLogsErr,OemToAnsi(STR0014) + ": " + aFilInTaf[nI, 2] +  OemToAnsi(STR0015))
				Else
					//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					aAdd(aLogsErr,OemToAnsi(STR0014) + ": " + aArrayFil[nI] +  OemToAnsi(STR0158))
				EndIf
			Else

				If lMiddleware
					cnrRecibo := Iif(cRetfNew == "2", cRecibXML, Iif(cStatus == "4", alltrim(cRcbAnt), Nil))
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtInfoComplPer/v" + cVersMw + "'>"
					cXml += "	<evtInfoComplPer Id='"+ cIdXml +"'>"
					fXMLIdEve( @cXML, { cRetfNew, cnrRecibo, cTpFolha, cPerApur, 1, 1, "12" }, If(Len(aInfoC) == 5 .And. aInfoC[5] $ "21*22",cVersEnvio,) )
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Else
					cXml := '<eSocial>'
					cXml += '	<evtInfoComplPer>'
					cXml += '		<ideEvento>'
					If cStatus == '4'
						cXml += "			<indRetif>2</indRetif>"
					Endif
					cXml +='			<indApuracao>'+cTpFolha+'</indApuracao>'
					cXml += '			<perApur>'+cPerApur+'</perApur>'
					cXml += '		</ideEvento>'
				EndIf
				cXml += '	<infoSubstPatr>'

				nPerc1 := ( nRecBruND / nRecBruta ) * 100
				cPerc  := alltrim( str( NoRound( nPerc1, 2 ) ) )

				If aInssEmp[27,1] $ "S" .OR. ( aInssEmp[27,1] == "M" .AND. nPerc1 <= 5 )
					cXml += '		<indSubstPatr>1</indSubstPatr>'
					cXml += '		<percRedContrib>0</percRedContrib>'
				Else
					cXml += '		<indSubstPatr>2</indSubstPatr>'
					cXml += '		<percRedContrib>' + cPerc + '</percRedContrib>'
				Endif

				cXml += '	</infoSubstPatr>'

				If cVersEnvio >= "9.0" .And. fCons129(cFilEnv, cAnoMes, @cPerc11096)
					cXml += '	<infoPercTransf11096>'
					cXml += '		<percTransf>' + cPerc11096 + '</percTransf>'
					cXml += '	</infoPercTransf11096>'
				EndIf

				cXml += '	</evtInfoComplPer>'
				cXml += '</eSocial>'
				GrvTxtArq(cXml, "S1280")
				If !lMiddleware
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1280")
				ElseIf Empty(aErros)
					aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1280", If( cTpFolha == "1", cAnoMes, cAno), cFilEnv + If(cTpFolha == "1", cAnoMes + cTpFolha, cAno + cTpFolha), cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, cRecibo, cRcbAnt } )
					If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
						aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
					EndIf
				EndIf
			Endif		
			
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
					aAdd(aLogsOk, OemToAnsI(STR0018) + cFilEnv + OemToAnsi(STR0019) ) //##"Valores de Desoneracao do grupo "##" Integrados com TAF."
					aAdd(aLogsOk, "" )
				Else
					aAdd(aLogsOk, OemToAnsI(STR0018) + cFilEnv + OemToAnsi(STR0165) ) //##"Valores de Desoneracao do grupo "##" Integrados com Middleware."
					aAdd(aLogsOk, "" )
				EndIf
			EndIf
		Endif

		If !lRobo .And. lNewProgres
			BarGauge1Set(nTotRec)
			IncPrcG1Time("Recibo: " + Alltrim(cRcbAnt) + " Período Apuração: " + cAno + "-" + cMes, nTotRec, cTimeIni, .T., 1, 1, .T.)
		EndIf

	Next nI

Return .T.

/*/{Protheus.doc} fVldMatriz
Função que verifica se a filial que foi configurada como matriz no middleware
@author lidio.oliveira
@since 19/11/2019
@version 1.0
@return cMatriz - Código da Matriz
/*/
Static Function fVldMatriz( cFilEnv, cPeriodo , aLogsErr )

	Local aAreaSM0		:= SM0->( GetArea() )
	Local cMatriz		:= ""
	Local nFilEmp		:= 0
	Local cStatus		:= "-1"

	Default cFilEnv		:= cFilAnt
	Default cPeriodo 	:= AnoMes(dDatabase)
	Default aLogsErr	:= {}

	If lMiddleware
		fPosFil( cEmpAnt, cFilEnv )
		If fVld1000( cPeriodo, @cStatus)
			If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. AllTrim(X[18]) == AllTrim(RJ9->RJ9_NRINSC) }) ) > 0
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

/*/{Protheus.doc} fCons129
Consulta tabela S129 para verificar geração do grupo infoPercTransf11096
@type  Static Function
@author isabel.noguti
@since 31/03/2022
@version 1.0
@param cFilEnv, caractere, Filial de envio (matriz)
@param cPeriodo, caractere, competencia para busca formato AAAAMM
@param cPerc11096, caractere, cod % no campo CONTRSOCFL da S-129
@return lRet, logico, indica se gera ou não o grupo
/*/
Static Function fCons129(cFilEnv, cPeriodo, cPerc11096)
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local cAlias129	:= GetNextAlias()
	Local c129Cc	:= ""
	Local c129Trans	:= ""

	Default cFilEnv		:= cFilAnt
	Default cPeriodo	:= AnoMes(dDatabase) //mmaaaa

	cPerc11096 := ""

	BeginSql alias cAlias129
		SELECT RCC.RCC_CHAVE, RCC.RCC_CONTEU
		FROM %table:RCC% RCC
		WHERE RCC.RCC_CODIGO = 'S129'
			AND RCC.RCC_FIL = %exp:cFilEnv%
			AND RCC.RCC_FILIAL = %exp:xFilial("RCC",cFilEnv)%
			AND RCC.RCC_CHAVE <= %exp:cPeriodo%
			AND RCC.%NotDel%
		ORDER BY RCC.RCC_CHAVE DESC
	EndSql

	While (cAlias129)->(!EoF()) .And. Empty(cPerc11096) .And. !Empty((cAlias129)->RCC_CHAVE)
		c129Cc		:= Substr((cAlias129)->RCC_CONTEU,1,16)
		c129Trans	:= Substr((cAlias129)->RCC_CONTEU,33,1)
		If !Empty(c129Cc) .Or. Empty(c129Trans)
			(cAlias129)->(dbSkip())
			loop
		EndIf
		If c129Trans == 'N'
			Exit
		EndIf
		cPerc11096 := Substr((cAlias129)->RCC_CONTEU,34,1)
		(cAlias129)->(dbSkip())
	EndDo

	(cAlias129)->(dbCloseArea())
	RestArea(aArea)
	lRet := !Empty(cPerc11096)

Return lRet
