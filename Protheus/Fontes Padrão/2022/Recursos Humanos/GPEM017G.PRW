#Include "Protheus.ch"
#INCLUDE "GPEM017G.CH"

Static nMaxReg    := 99
Static cVersEnvio := ""

/*/{Protheus.doc} GPEM017G
Retorna lista de treinamentos realizados pelo funcionário
@type function
@version 12.1.27
@author brdwc0032
@since 11/02/2021
/*/

Function GPEM017G(cFilMat as Character, cMat as Character)
Local aRet as Array
Local aArea as Array
Local cQuery as Character
Local cTab as Character
Local nI as Numeric
Local nCont as Numeric

Default cFilMat := ""
Default cMat := ""

aRet := {}
aArea := GetArea()
cQuery := ""
cTab := ""
nI := 0

cQuery := "SELECT T0.RA2_CURSO" + CRLF
cQuery += " ,T0.RA2_TURMA" + CRLF
cQuery += "	,T0.RA2_DESC" + CRLF
cQuery += "	,T0.RA2_ESOC" + CRLF
cQuery += "FROM " + RetSQLName("RA2") + " T0(NOLOCK)" + CRLF
cQuery += "INNER JOIN " + RetSQLName("RA4") + " T1(NOLOCK) ON (" + CRLF
cQuery += "		(T1.RA4_FILIAL = '" + xFilial("RA4", cFilMat) + "')" + CRLF
cQuery += "		AND (T1.RA4_CURSO = T0.RA2_CURSO)" + CRLF
cQuery += "     AND (T1.RA4_TURMA = T0.RA2_TURMA)" + CRLF 
cQuery += "		AND (T1.RA4_MAT = '" + cMat + "')" + CRLF
cQuery += "		AND (T1.D_E_L_E_T_ = ' ')" + CRLF
cQuery += "		)" + CRLF
cQuery += "WHERE T0.RA2_FILIAL = '" + xFilial("RA2", cFilMat) + "'" + CRLF
cQuery += "	AND T0.RA2_REALIZ = 'S'" + CRLF
cQuery += "	AND T0.RA2_ESOC <> '" + Space(TamSX3("RA2_ESOC")[1]) + "'" + CRLF
cQuery += "	AND T0.D_E_L_E_T_ = ' '" + CRLF
cQuery += "ORDER BY T0.RA2_DATAFI DESC" + CRLF
cQuery += "	,T0.RA2_CURSO DESC" + CRLF

cQuery := ChangeQuery(cQuery)

cTab := MPSysOpenQuery(cQuery)

DbSelectArea((cTab))
(cTab)->(DbGoTop())

While (((cTab)->(!Eof())) .And. (nI <= nMaxReg))

	If (nCont := aScan( aRet, { |x| x[3] == (cTab)->RA2_ESOC } )) == 0
	    aAdd(aRet, {(cTab)->RA2_CURSO, (cTab)->RA2_DESC, (cTab)->RA2_ESOC})
    	nI++
	Endif
    (cTab)->(DbSkip())
Enddo

(cTab)->(DbCloseArea())

RestArea(aArea)
Return(aRet)

/*/{Protheus.doc} vldClasEst
Retorna lista de treinamentos realizados pelo funcionário
@type function
@version 12.1.27
@author brdwc0032
@since 11/02/2021
/*/

Function vldClasEst(cClasEst as Character)
Local lRet as Logical

Default cClasEst := ""

lRet := .T.

Iif(cPaisLoc == "BRA" .And. FindFunction("fVersEsoc"), fVersEsoc("S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio), .T.)

If (cVersEnvio >= "9.0")
	lRet := cClasEst $ " 1 2 3 4 5 6 7 "
Else
    lRet := cClasEst $ "010203040506070809101112"
Endif
Return(lRet)

/*/{Protheus.doc} fIntBxTrm
	Efetua integração S-2200/S-2206 dos funcionários atualizados na Baixa de Treinamento TRMA070
	@type  Function
	@author isabel.noguti
	@since 19/11/2021
	@version 12.1.33
	@param aFuncAtu, array, funcionários a serem avaliados
	/*/
Function fIntBxTrm(aFuncAtu)
	Local aArea		:= GetArea()
	Local cBkpFil	:= cFilAnt
	Local cMsgErro	:= ""
	Local aErros	:= {}
	Local aLog		:= {}
	Local cChave	:= ""
	Local cStat2200	:= ""
	Local cTCV		:= fCatTrabEFD("TCV")
	Local lIntTAF	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 ) //Integracao com TAF
	Local lIntegra	:= Iif(cPaisLoc == "BRA" .And. FindFunction("fVersEsoc"), fVersEsoc("S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio), .F.)
	Local lRet		:= .T.
	Local nI		:= 0
	Local nCont		:= 0
	Local nContErr	:= 0
	Local nContTSV	:= 0
	Local lJorSInt	:= .F. // Jornada Sem Intervalo Definido

	If lIntTaf .And. lIntegra .And. cVersEnvio >= "9.0"
		DbSelectArea("SRA")

		For nI := 1 to Len(aFuncAtu)
			If SRA->(DbSeek(aFuncAtu[nI][1]+aFuncAtu[nI][2]))

				If !(SRA->RA_CATEFD $ cTCV)
					nContTSV ++
					loop
				EndIf
				cFilAnt		:= aFuncAtu[nI][1]
				cChave		:= AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_CODUNIC)
				cStat2200	:= TAFGetStat("S-2200", cChave, cEmpAnt, cFilAnt)
				lJorSInt	:= .F.

				If cStat2200 == "-1"
					cMsgErro := STR0003							//"Não foi encontrado o evento S-2200 deste funcionário."
					lRet := .F.
				ElseIf cStat2200 <> "4"
					RegToMemory("SRA",,,.F.)
					lRet:= fIntAdmiss("SRA", /*lAltCad*/, 4, "S2200", Nil, Nil, Nil, Nil, Nil, @aErros, cVersEnvio, /*oMdlRFZ*/, /*aFilial*/, /*oMdlRS9*/, /*cFilTrf*/, /*dDtAdm*/, /*aVinc*/, /*cFilDe*/, .F., /*cCCAte*/, /*cArqSR6*/, /*cSR6Fil*/, /*cEmpP*/, /*cArqSRJ*/, , /*cArqSQ3*/, /*cSQ3Fil*/, , /*cSVAObs*/, /*lTrfCNPJ*/, /*lNovoCPF*/, /*cNovoCodUnic*/, /*lAjustaDep*/, @lJorSInt)
					If lRet
						If lJorSInt // Jornada Sem Intervalo 
							// " - Evento S-2200 enviado com sucesso." + "Observ.: Possui Sequência de Turno sem Intervalo Definido, verificar Tabela de Horário Padrão do Turno."       
							aAdd(aLog, aFuncAtu[nI][1]+aFuncAtu[nI][2] + STR0004 + CRLF + STR0011 )
						Else
							aAdd(aLog, aFuncAtu[nI][1]+aFuncAtu[nI][2] + STR0004)	//" - Evento S-2200 enviado com sucesso."	
						EndIf					
						nCont ++
					EndIf
				Else
					RegToMemory("SRA",,,.F.)
					lRet := fInt2206("SRA", /*lAltCad*/, 4,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/, cVersEnvio, /*oMdlRS9*/, /*dDtAlt*/, /*lTransf*/, /*cCTT2206*/, @aErros, .F., /*lDataAlt*/, /*cSalario*/, /*cSVAObs*/, /*lGp010Auto*/, /*aRotAuto*/, /*cTafKey*/, /*cDtRGE*/,@lJorSInt)
					If lRet						
						If lJorSInt // Jornada Sem Intervalo 
							// " - Evento S-2206 enviado com sucesso." + "Observ.: Possui Sequência de Turno sem Intervalo Definido, verificar Tabela de Horário Padrão do Turno."       
							aAdd(aLog, aFuncAtu[nI][1]+aFuncAtu[nI][2] + STR0005 + CRLF + STR0011 )
						Else
							aAdd(aLog, aFuncAtu[nI][1]+aFuncAtu[nI][2] + STR0005)	//" - Evento S-2206 enviado com sucesso."	
						EndIf						
						nCont ++
					EndIf
				EndIf

				If !lRet
					nContErr ++
					aAdd(aLog, aFuncAtu[nI][1]+aFuncAtu[nI][2] + STR0006)		//" - Não enviado ao TAF"
					If Len(aErros) > 0
						FeSoc2Err(aErros[1], @cMsgErro, Iif(aErros[1]!= '000026', 1, 2))
						aErros := {}
					EndIf
					aAdd(aLog, cMsgErro)
					aAdd(aLog, "")
				EndIf
			EndIf
		Next nI

		aAdd(aLog, "")
		aAdd(aLog, "")
		aAdd(aLog, STR0007)					//"Total de registros - Envio de eventos TAF"
		aAdd(aLog, "")
		aAdd(aLog, STR0008 + AllTrim(STR(nCont)))		//"Registros enviados: "
		aAdd(aLog, STR0009 + AllTrim(STR(nContErr)))	//"Registros não enviados: "
		aAdd(aLog, STR0010 + AllTrim(STR(nContTSV)))	//"Registros TSV não processados: "
		aAdd(aLog, "")

		cFilAnt := cBkpFil
		fMakeLog( { aLog } , {STR0002} , NIL , NIL , NIL , STR0001, "M", "P",, .F. )	//"Monitoramento Envio de Eventos ##Integração eSocial na Baixa de Treinamentos"
	EndIf

	RestArea(aArea)
Return lRet
