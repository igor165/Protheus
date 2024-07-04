#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201.CH"

//TIPO EXEC = 1 (EMISSÃO DE PRÉ)
//-------------------------------------------------------------------
/*/{Protheus.doc} JA201BVinc(oParams)
Rotina para Vincular os lançamentos à pré-fatura sendo emitida. 

@author David G. Fernandes
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201BVinc(oParams, cCodFixo, cCodPre, cCodFatAd, cCodJunc, cCodContr, cCodClien, cLoja, cCodCaso, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA)
	Local aRet       := {.T., "JA201BVinc"}
	Local aArea      := GetArea()
	Local cQryRes    := GetNextAlias()
	Local cCmd       := ""
	Local cQueryTS   := ""
	Local cQueryLT   := ""
	Local cFatura    := ""
	Local cEscr      := ""
	Local dMaiorDt   := sTod("  /  /    ")
	Local dMenorDt   := sTod("  /  /    ")
	Local nI         := 0
	Local aSqlRet    := {}
	Local cFilDtTs   := ""
	Local lVincTS    := .F.
	Local cTpHon     := JurGetDados("NT0", 1, xFilial("NT0") + cCodContr, "NT0_CTPHON")
	Local cCobH      := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")
	Local cCobF      := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF")
	Local lMinimo    := ( cCobH == "1" .And. cCobF == "1" .And. JurGetDados("NT0", 1, xFilial("NT0") + cCodContr, "NT0_FIXEXC") == "1" ) //Indica se o tipo de honorários é Mínimo
	Local lAtivNaoC  := SuperGetMV( 'MV_JURTS4',, .F. ) //Zera o tempo revisado de atividades nao cobraveis
	Local lRevisLD   := (SuperGetMV("MV_JREVILD", .F., '2') == '1') //Controla a integracao da revisão de pré-fatura com o Legal Desk
	Local lVincDspFx := .F.
	Local dDtIniDsp  := sTod("  /  /    ")
	Local dDtFimDsp  := sTod("  /  /    ")
	Local aRetCasMae := {}
	Local aCMaeFaTs  := {}
	Local aCMaeFaDp  := {}
	Local aCMaeFaLt  := {}
	Local aVigencia  := {}
	Local cTpHonMae  := ""
	Local cClienteMae:= ""
	Local cLojaMae   := ""
	Local cCasoMae   := ""
	Local lCobHMae   := .F.
	Local lFSinc     := SuperGetMV("MV_JFSINC", .F., '2') == '1'
	Local lFatAtiva  := .F.
	Local lDataVinc  := NW0->(ColumnPos('NW0_DTVINC')) > 0
	Local cSpaceDT   := Space(8)
	Local lAltHr     := NUE->(ColumnPos('NUE_ALTHR')) > 0
	Local lCasoMae   := .F.
	Local cCasMaeCli := ""
	Local cCasMaeLoj := ""
	Local cCasMaeCas := ""
	Local cCodPart   := ""
	Local lCpoFxNc   := NX0->(ColumnPos('NX0_FXNC')) > 0 // Proteção para campo de contratos fixos ou não cobráveis
	Local lTSNCobra  := SuperGetMV( 'MV_JTSNCOB',, .F. ) // Indica se vincula TimeSheet não cobrável na emissão
	
	If NX5->(FieldPos('NX5_DSPFIX')) > 0
		lVincDspFx := Iif(cTEMFX == "1", JurGetDados("NX5", 1, xFilial("NX5") + oParams:cCodFilaImp, "NX5_DSPFIX") == "1", .F.)
		If lVincDspFx
			dDtIniDsp  := JurGetDados("NX5", 1, xFilial("NX5") + oParams:cCodFilaImp, "NX5_DREFID")
			dDtFimDsp  := JurGetDados("NX5", 1, xFilial("NX5") + oParams:cCodFilaImp, "NX5_DREFFD")
		EndIf
	EndIf

	If oParams:GetTpExec() $ "3|4|5|7|MS"    //Emissão de Minuta de Pré-Fatura / Minuta de Fatura / Emissão de Fatura / Minuta Sócio
		cFatura := oParams:GetMarkFat()
		cEscr   := oParams:GetMarkEsc()
	EndIf

	//Informações de Caso Mãe
	If oParams:GetTpExec() == "5" .And. Empty(cCodFatAd) // Emissão de Fatura
		If Empty(cCodPre)
			If lFSinc .And. NX8->(ColumnPos( "NX8_CLOJCM" )) > 0 // Emissão de Fatura
				aRetCasMae  := JurGetDados("NT0", 1, xFilial("NT0") + cCodContr, {"NT0_CCLICM", "NT0_CLOJCM", "NT0_CCASCM", "NT0_CTPHON"})
			EndIf
		Else
			If lFSinc .And. NX8->(ColumnPos( "NX8_CLOJCM" )) > 0 // Emissão de Fatura
				If NX8->(ColumnPos( "NX8_CTPHON" )) > 0 //Proteção
					aRetCasMae  := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre + cCodContr, {"NX8_CCLICM", "NX8_CLOJCM", "NX8_CCASCM", "NX8_CTPHON"})
				Else
					aRetCasMae  := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre + cCodContr, {"NX8_CCLICM", "NX8_CLOJCM", "NX8_CCASCM"})
					aAdd(aRetCasMae, JurGetDados("NT0", 1, xFilial("NT0") + cCodContr, "NT0_CTPHON") )
				EndIf
			EndIf
		EndIf

		If Len(aRetCasMae) == 4
			cClienteMae := aRetCasMae[1]
			cLojaMae    := aRetCasMae[2]
			cCasoMae    := aRetCasMae[3]

			cTpHonMae   := aRetCasMae[4]
			lCobHMae    := JurGetDados("NRA", 1, xFilial("NRA") + cTpHonMae, "NRA_COBRAH") == "1"
		EndIf
	EndIf
	
	//Chamada de função para verificar a existência de faturas 
	If oParams:GetTpExec() $ "3|4|5|7|MS" .And. Empty(cCodFatAd) //Emissão de Minuta de Pré-Fatura / Minuta de Fatura / Emissão de Fatura / Minuta Sócio
		If Empty(cCodPre)
			lFatAtiva := JA201TemFt(,,, cCodFixo)
		Else
			lFatAtiva := JA201TemFt(cCodPre)
		EndIf
	EndIf

	/****************************
	// VINCULA FIXO
	// vincular Fixo antes do TS,
	// pois para vincular os TSs em pré-fatura de Fixo, utiliza as parcelas vinculadas
	****************************/
	If aRet[1] .And. ( cTEMFX == "1" .Or. (cTEMTS == "1" .And. lMinimo) )

		oParams:PtInternal(STR0133) // "Vinc Lanctos do Caso - Fixo"
		If oParams:GetTpExec() == "1"

			cQueryFX :=         " SELECT NT1.NT1_SEQUEN "
			If oParams:GetSituac() == "1"
				cQueryFX +=        " , NT1.NT1_VALORB "
				cQueryFX +=        " , NT1.NT1_VALORA "
				cQueryFX +=        " , NT1.NT1_DATAIN "
				cQueryFX +=        " , NT1.NT1_DATAFI "
			EndIf
			cQueryFX += " FROM " + RetSqlName("NT1") + " NT1, " + RetSqlName('NT0') + " NT0  "
			cQueryFX +=     " INNER JOIN " + RetSqlName("NRA") + " NRA ON (NRA.NRA_FILIAL = '" + xFilial("NRA") + "' AND "
			cQueryFX +=                                                   " NRA.NRA_COD = NT0.NT0_CTPHON AND "
			cQueryFX +=                                                   " NRA.D_E_L_E_T_ = ' ') "
			cQueryFX +=     " INNER JOIN " + RetSqlName("NTH") + " NTH ON (NTH.NTH_FILIAL = '" + xFilial("NTH") +"' AND "
			cQueryFX +=                                                   " NTH.NTH_CTPHON = NRA.NRA_COD AND "
			cQueryFX +=                                                   " NTH.NTH_CAMPO = 'NT0_FXABM' AND "
			cQueryFX +=                                                   " NTH.D_E_L_E_T_ = ' ') "
			cQueryFX += " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cQueryFX +=   " AND NT1.NT1_SITUAC = '1' "
			cQueryFX +=   " AND NT1.NT1_CCONTR = '" + cCodContr +"' "
			cQueryFX +=   " AND NT0.NT0_FILIAL = '"+ xFilial("NT0") +"' "
			cQueryFX +=   " AND NT0.D_E_L_E_T_ = ' ' "
			cQueryFX +=   " AND NT0.NT0_COD = NT1.NT1_CCONTR "
			cQueryFX +=   " AND NT0.NT0_SIT = '2' " 
			cQueryFX +=   " AND NOT EXISTS ( SELECT NXA.NXA_COD "
			cQueryFX +=                       " FROM " + RetSqlName("NXA") + " NXA "
			cQueryFX +=                       " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") +"' "
			cQueryFX +=                         " AND NXA.NXA_CFIXO  = NT1.NT1_SEQUEN "
			cQueryFX +=                         " AND NXA.NXA_SITUAC = '1' "
			cQueryFX +=                         " AND NXA.NXA_TIPO = 'FT' "
			cQueryFX +=                         " AND NXA.D_E_L_E_T_ = ' '  "
			cQueryFX +=                     " ) "
			/*Bloco criado para exibir na fila apenas as parcelas cujo contrato possui casos válidos.*/
			cQueryFX +=   " AND EXISTS ( SELECT NVE.R_E_C_N_O_ " 
			cQueryFX +=                  " FROM " + RetSqlName("NVE") + " NVE, "
			cQueryFX +=                       " " + RetSqlName("NUT") + " NUT "
			cQueryFX +=                 " WHERE NVE.NVE_FILIAL = '"+ xFilial("NVE") +"' "
			cQueryFX +=                   " AND NUT.NUT_FILIAL = '"+ xFilial("NUT") +"' "
			cQueryFX +=                   " AND NUT.NUT_CCONTR = NT0.NT0_COD "
			cQueryFX +=                   " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
			cQueryFX +=                   " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
			cQueryFX +=                   " AND NVE.NVE_ENCHON = '2' "
			cQueryFX +=                   " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
			If oParams:GetSituac() <> "1" // Conferência
				cQueryFX +=               " AND NVE.NVE_COBRAV = '1' "
			EndIf
			cQueryFX +=                   " AND NVE.D_E_L_E_T_ = ' ' "
			//Se não for Faixa Qtdade de Casos
			cQueryFX +=                   " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
			cQueryFX +=                           " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
			cQueryFX +=                              " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryFX +=                           " END) "
			cQueryFX +=                        " ELSE "
			//Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
			cQueryFX +=                           " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
			cQueryFX +=                               " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
			cQueryFX +=                                   " (CASE WHEN NT0.NT0_FXABM = '1' THEN  "
			cQueryFX +=                                       " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryFX +=                                    " ELSE "
			cQueryFX +=                                        " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryFX +=                                    " END) " 
			cQueryFX +=                                " ELSE "  
			cQueryFX +=                                   " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQueryFX +=                                       " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQueryFX +=                                           " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryFX +=                                        " ELSE "
			cQueryFX +=                                           " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryFX +=                                        " END ) "
			cQueryFX +=                                    " ELSE "
			cQueryFX +=                                       " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQueryFX +=                                           " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryFX +=                                        " ELSE  "
			cQueryFX +=                                           " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) " 
			cQueryFX +=                                        " END) "
			cQueryFX +=                                    " END) "
			cQueryFX +=                                " END) "
			cQueryFX +=                            " END) "
			cQueryFX +=                         " END) <> '2' "
			cQueryFX +=               " ) "

			//Verifica a menor data para filtrar as parcelas:
			If !Empty(oParams:GetDIniH())
				If Empty(dMenorDt) .Or. (dMenorDt < oParams:GetDIniH())
					dMenorDt := oParams:GetDIniH()
				EndIf
			EndIf

			//Verifica a maior data para filtrar as parcelas:
			If !Empty(oParams:GetDFinH())
				If Empty(dMaiorDt) .Or. (dMaiorDt < oParams:GetDFinH())
					dMaiorDt := oParams:GetDFinH()
				EndIf
			EndIf

			If !Empty(dMenorDt) .And. !Empty(dMaiorDt)
				cQueryFX += " AND NT1.NT1_DATAFI >= '" + DtoS( dMenorDt ) +"' "
				cQueryFX += " AND NT1.NT1_DATAFI <= '" + DtoS( dMaiorDt ) +"' "
			EndIf
			If oParams:GetSituac() == "1"
				cQueryFX += " AND NT1.NT1_CPREFT = NT1.NT1_CPREFT "
			 Else
				cQueryFX += " AND NT1.NT1_CPREFT = '"+ Space(TamSx3('NT1_CPREFT')[1]) + "' "
			EndIf
			cQueryFX +=     " AND NT1.D_E_L_E_T_ = ' '"
		EndIf

		If oParams:GetTpExec() == "6" // Reemitir a pré de Fatura Cancelada
			cQueryFX := "SELECT NWE.NWE_CFIXO NT1_SEQUEN"
			cQueryFX += " FROM " + RetSqlName("NWE") + " NWE "
			cQueryFX += " WHERE	NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
			cQueryFX +=   " AND NWE.NWE_CFATUR = '" + oParams:GetCodFatur() +"' "
			cQueryFX +=   " AND NWE.NWE_CESCR  = '" + oParams:GetCodEscr() +"' "
			cQueryFX +=   " AND NWE.D_E_L_E_T_ = ' ' "

		EndIf

		If oParams:GetTpExec() == "1" .And. oParams:GetSituac() == "1" //Conferência

			cQueryFX := ChangeQuery(cQueryFX, .F.)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryFX ), cQryRes, .T., .F. )

			TcSetField(cQryRes, 'NT1_VALORB', 'N', TamSX3('NT1_VALORB')[1], TamSX3('NT1_VALORB')[2])
			TcSetField(cQryRes, 'NT1_VALORA', 'N', TamSX3('NT1_VALORA')[1], TamSX3('NT1_VALORA')[2])
			TcSetField(cQryRes, 'NT1_DATAIN', 'D', TamSX3('NT1_DATAIN')[1], TamSX3('NT1_DATAIN')[2])
			TcSetField(cQryRes, 'NT1_DATAFI', 'D', TamSX3('NT1_DATAFI')[1], TamSX3('NT1_DATAFI')[2])

			While !(cQryRes)->(EOF())

				NWE->(DbSetOrder(1)) //  NWE_FILIAL+NWE_CFIXO+NWE_SITUAC+NWE_PRECNF+NWE_CFATUR+NWE_CESCR+NWE_CWO
				If (NWE->(MsSeek( xFilial("NWE") + (cQryRes)->NT1_SEQUEN + "1" + cCodPre  ) ))
					RecLock("NWE", .F., .F., .F., .T.)
					NWE->NWE_CANC := "2"
					NWE->(MsUnlock())
					NWE->(DbCommit())
				Else
					RecLock("NWE", .T.)
					NWE->NWE_FILIAL  := xFilial("NWE")
					NWE->NWE_CFIXO   := (cQryRes)->NT1_SEQUEN
					NWE->NWE_SITUAC  := "1"
					NWE->NWE_PRECNF  := cCodPre
					NWE->NWE_CANC    := "2"
					NWE->NWE_CODUSR  := oParams:GetCodUser()
					NWE->NWE_VALORB  := (cQryRes)->NT1_VALORB
					NWE->NWE_VALORA  := (cQryRes)->NT1_VALORA
					NWE->NWE_DATAIN  := (cQryRes)->NT1_DATAIN
					NWE->NWE_DATAFI  := (cQryRes)->NT1_DATAFI

					NWE->(MsUnlock())
					NWE->(DbCommit())
				EndIf
				//Grava na fila de sincronização
				J170GRAVA("NT0", xFilial("NT0") + cCodContr, "4")

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
		EndIf

		If ( oParams:GetTpExec() $ "1|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré-Fatura

			// Se for emissão de pré, atualiza o Lançamento com o num da Pré
			cCmd := " SELECT R_E_C_N_O_ RECNO "
			cCmd +=   " FROM " + RetSqlName("NT1") + " NT1"
			cCmd +=  " INNER JOIN  (" + cQueryFX + ") NT12 "
			cCmd +=     " ON NT1.NT1_SEQUEN = NT12.NT1_SEQUEN "
			cCmd +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cCmd +=    " AND NT1.NT1_CPREFT = '"+ Space(TamSx3('NT1_CPREFT')[1]) + "' "
			cCmd +=    " AND NT1.D_E_L_E_T_ = ' ' "

			aSqlRet := JurSQL(cCmd, {"RECNO"})

			For nI := 1  To Len(aSqlRet)
				NT1->(DbGoto(aSqlRet[nI][1]))
				If RecLock("NT1", .F., .F., .F., .T.)
					NT1->NT1_CPREFT := cCodPre
					If NT1->(ColumnPos("NT1_ACAOLD")) > 0
						NT1->NT1_ACAOLD := ""
						NT1->NT1_INSREV := " "
						NT1->NT1_REVISA := "2"
					EndIf
					NT1->(MsUnlock())
					NT1->(DbCommit())
					//Grava na fila de sincronização
					J170GRAVA("NT0", xFilial("NT0") + cCodContr, "4")
				Else
					aRet := {.F., "JA201BVinc - NT1 - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
					Exit
				EndIf
			Next nI

			If (oParams:GetTpExec() == "6") .And. aRet[1]
				cCmd := " SELECT NWE_PF.R_E_C_N_O_ RECNO "
				cCmd += " FROM " + RetSqlName("NWE") + " NWE_PF, " + RetSqlName("NWE") + " NWE_FT "
				cCmd += " WHERE NWE_PF.NWE_FILIAL = '" + xFilial("NWE") +"' "
				cCmd += " AND NWE_FT.NWE_FILIAL = '" + xFilial("NWE") +"' "
				cCmd += " AND NWE_PF.NWE_PRECNF = '" + cCodPre +"' "
				cCmd += " AND NWE_PF.NWE_CANC = '1' "
				cCmd += " AND NWE_FT.NWE_CFATUR = '" + oParams:GetCodFatur() +"' "
				cCmd += " AND NWE_FT.NWE_CESCR  = '" + oParams:GetCodEscr() +"' "
				cCmd += " AND NWE_PF.NWE_CFIXO = NWE_FT.NWE_CFIXO "
				cCmd += " AND NWE_PF.D_E_L_E_T_ = ' ' "
				cCmd += " AND NWE_FT.D_E_L_E_T_ = ' ' "

			  aSqlRet := JurSQL(cCmd, {"RECNO"})

				For nI := 1 To Len(aSqlRet)
					NWE->(DbGoto(aSqlRet[nI][1]))
					If RecLock("NWE", .F., .F., .F., .T.)
						NWE->NWE_SITUAC  := '1'
						NWE->NWE_CANC    := '2'
						NWE->(MsUnlock())
						NWE->(DbCommit())
						//Grava na fila de sincronização
						J170GRAVA("NT0", xFilial("NT0") + cCodContr, "4")
					Else
						aRet := {.F., "JA201BVinc - NWE - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
						Exit
					EndIf
				Next nI
			EndIf

		EndIf

		If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de pré fatura / Minuta de Fatura / Fatura / Minuta Sócio
			cQueryFX := " SELECT NT1.NT1_SEQUEN "
			cQueryFX += " , NT1.NT1_VALORB "
			cQueryFX += " , NT1.NT1_VALORA "
			cQueryFX += " , NT1.NT1_DATAIN "
			cQueryFX += " , NT1.NT1_DATAFI "
			cQueryFX += " FROM " + RetSqlName("NT1") + " NT1  "
			cQueryFX += " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
			If !Empty(cCodPre)
				cQueryFX += " AND NT1.NT1_CPREFT = '" + cCodPre +"' "
				If lFatAtiva // verifica se tem faturas emitidas para essa pré-fatura
					cQueryFX += " AND NT1.NT1_SITUAC = '2' "
				Else
					cQueryFX += " AND NT1.NT1_SITUAC = '1' "
				EndIf
			Else
				cQueryFX +=     " AND ( NT1.NT1_SITUAC = '1' OR EXISTS ( SELECT SUM(NXA.NXA_PERFAT) NXA_PERFAT "
				cQueryFX +=                                              " FROM " + RetSqlName("NXA") + " NXA " 
				cQueryFX +=                                              " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF "
				cQueryFX +=                                                         " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
				cQueryFX +=                                                              " AND NXA.NXA_COD = NUF.NUF_CFATU "
				cQueryFX +=                                                              " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
				cQueryFX +=                                                              " AND NUF.D_E_L_E_T_ = ' ') "
				cQueryFX +=                                             " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") +"' "
				cQueryFX +=                                               " AND NXA.NXA_CFIXO = NT1.NT1_SEQUEN "
				cQueryFX +=                                               " AND (NXA.NXA_SITUAC = '1' "
				cQueryFX +=                                                     " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1' ) ) "  //Fatura de Wo Ativo
				cQueryFX +=                                               " AND NXA.D_E_L_E_T_ = ' ' "
				cQueryFX +=                                            " HAVING SUM(NXA.NXA_PERFAT) < 100 " 
				cQueryFX +=                                          " ) "
				cQueryFX +=         " ) "
			EndIf
			If !Empty(cCodFixo)
				cQueryFX += " AND NT1.NT1_SEQUEN = '" + cCodFixo +"' "
			EndIf

			cQueryFX += " AND NOT EXISTS (SELECT NWE.R_E_C_N_O_ "
			cQueryFX +=                    " FROM " + RetSqlName("NWE") + " NWE " 
			cQueryFX +=                     " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
			cQueryFX +=                        "AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
			cQueryFX +=                        "AND NWE.NWE_PRECNF = NT1.NT1_CPREFT "
			cQueryFX +=                        "AND NWE.NWE_CFATUR = '" + cFatura +"' "
			cQueryFX +=                        "AND NWE.NWE_CESCR = '" + cEscr +"' "
			cQueryFX +=                        "AND NWE.NWE_CODUSR = '" + oParams:GetCodUser() +"' "
			cQueryFX +=                        "AND NWE.NWE_CANC = '2' "
			cQueryFX +=                        "AND NWE.D_E_L_E_T_ = ' ')"

			cQueryFX +=     " AND NT1.D_E_L_E_T_ = ' ' "

			cQueryFX := ChangeQuery(cQueryFX, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryFX ), cQryRes, .T., .F. )

			TcSetField(cQryRes, 'NT1_VALORB', 'N', TamSX3('NT1_VALORB')[1], TamSX3('NT1_VALORB')[2])
			TcSetField(cQryRes, 'NT1_VALORA', 'N', TamSX3('NT1_VALORA')[1], TamSX3('NT1_VALORA')[2])
			TcSetField(cQryRes, 'NT1_DATAIN', 'D', TamSX3('NT1_DATAIN')[1], TamSX3('NT1_DATAIN')[2])
			TcSetField(cQryRes, 'NT1_DATAFI', 'D', TamSX3('NT1_DATAFI')[1], TamSX3('NT1_DATAFI')[2])

			While !(cQryRes)->(EOF())
				// NWE_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
				RecLock("NWE", .T.)
				NWE->NWE_FILIAL  := xFilial("NWE")
				NWE->NWE_CFIXO   := (cQryRes)->NT1_SEQUEN
				NWE->NWE_SITUAC  := "4"
				NWE->NWE_PRECNF  := cCodPre
				NWE->NWE_CFATUR  := cFatura
				NWE->NWE_CESCR   := cEscr
				NWE->NWE_CANC    := "2"
				NWE->NWE_CODUSR  := oParams:GetCodUser()
				NWE->NWE_VALORB  := (cQryRes)->NT1_VALORB
				NWE->NWE_VALORA  := (cQryRes)->NT1_VALORA
				NWE->NWE_DATAIN  := (cQryRes)->NT1_DATAIN
				NWE->NWE_DATAFI  := (cQryRes)->NT1_DATAFI

				NWE->(MsUnlock())
				NWE->(DbCommit())
				// Grava na fila de sincronização
				If !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NT0 na fila
					J170GRAVA("NT0", xFilial("NT0") + cCodContr, "4")
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())

		EndIf
	EndIf

	/****************************
	// VINCULA TIME-SHEET
	****************************/
	lVincTS := IIF(lCpoFxNc, oParams:GetFltrFxNc(), .T.) .Or.;
	           ( (cCobH = "2" .And. cCobF = "1" .And. SuperGetMv('MV_JVINCTS ',, .T.)) .Or. (cTEMFX == "1" .And. lMinimo) ) //Quando se tratar de Mínimo, os TSs sempre deverão ser vinculados.

	If aRet[1] .And. (cTEMTS == "1" .Or. (lVincTS .And. cTEMFX == "1" ))

		oParams:PtInternal(STR0134) // "Vinc Lanctos do Caso - Time Sheet"
		If (oParams:GetTpExec() == "1")  // Emissão de pré

			cQueryTS := " SELECT NUE.NUE_COD "
			cQueryTS +=    "FROM " + RetSqlName("NUE") + " NUE  "
			If cCobF == "1" .And. cTEMFX == "2"
				cQueryTS +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON (NUT.NUT_FILIAL = '" + xFilial("NUT") + "' AND "
				cQueryTS +=                                                       " NUT.NUT_CCONTR = '" + cCodContr +"' AND "
				cQueryTS +=                                                       " NUT.NUT_CCLIEN = NUE.NUE_CCLIEN AND "
				cQueryTS +=                                                       " NUT.NUT_CLOJA = NUE.NUE_CLOJA AND "
				cQueryTS +=                                                       " NUT.NUT_CCASO = NUE.NUE_CCASO AND "
				cQueryTS +=                                                       " NUT.D_E_L_E_T_ = ' ') "
				cQueryTS +=          " INNER JOIN " + RetSqlName("NT0") + " NT0 ON (NT0.NT0_FILIAL = '" + xFilial("NT0") + "' AND "
				cQueryTS +=                                                       " NT0.NT0_COD = NUT.NUT_CCONTR AND "
				cQueryTS +=                                                       " NT0.D_E_L_E_T_ = ' ') "
				cQueryTS +=          " INNER JOIN " + RetSqlName("NRA") + " NRA ON (NRA.NRA_FILIAL = '" + xFilial("NRA") + "' AND "
				cQueryTS +=                                                       " NRA.NRA_COD = NT0.NT0_CTPHON AND "
				cQueryTS +=                                                       " NRA.D_E_L_E_T_ = ' ') "
				cQueryTS +=          " INNER JOIN " + RetSqlName("NTH") + " NTH ON (NTH.NTH_FILIAL = '" + xFilial("NTH") +"' AND "
				cQueryTS +=                                                            " NTH.NTH_CTPHON = NRA.NRA_COD AND "
				cQueryTS +=                                                            " NTH.NTH_CAMPO = 'NT0_TPCEXC' AND "
				cQueryTS +=                                                            " NTH.D_E_L_E_T_ = ' ') "
				cQueryTS +=          " LEFT OUTER JOIN " + RetSqlName("NT1") + " NT1 ON (NT1.NT1_FILIAL = '" + xFilial("NT1") +"' AND "
				cQueryTS +=                                                             " NT1.NT1_CCONTR = NUT.NUT_CCONTR AND "
				If !Empty(oParams:GetDIniH()) .And. !Empty(oParams:GetDFinH())
					cQueryTS += " NT1.NT1_DATAFI >= '" + DtoS(oParams:GetDIniH()) +"' AND "
					cQueryTS += " NT1.NT1_DATAFI <= '" + DtoS(oParams:GetDFinH()) +"' AND "
				EndIf
				cQueryTS +=                                                       " NT1.D_E_L_E_T_ = ' ') "
				cQueryTS +=          " INNER JOIN " + RetSqlName("NVE") + " NVE ON (NVE.NVE_FILIAL = '" + xFilial("NVE") + "' AND "
				cQueryTS +=                                                       " NVE.NVE_CCLIEN = NUT.NUT_CCLIEN AND "
				cQueryTS +=                                                       " NVE.NVE_LCLIEN = NUT.NUT_CLOJA AND "
				cQueryTS +=                                                       " NVE.NVE_ENCHON = '2' AND "
				If oParams:GetSituac() <> "1" // Conferência
					cQueryTS +=                                                   " NVE.NVE_COBRAV = '1' AND "
				EndIf
				cQueryTS +=                                                       " NVE.NVE_NUMCAS = NUT.NUT_CCASO AND "
				cQueryTS +=                                                       " NVE.D_E_L_E_T_ = ' ' AND "
				/*Bloco criado para verificar a existência de casos válidos quando houver a cobrança de excedente
	 			(Misto e Mínimo), de forma que se não houver casos válidos, o excedente também não seja emitido.*/
				cQueryTS +=                                                       " ( CASE WHEN NTH.NTH_VISIV = '1' THEN "
				cQueryTS +=                                                             "(CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
				cQueryTS +=                                                       " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
				cQueryTS +=                                                          " END) "
				cQueryTS +=                " ELSE '1' END ) <> '2' "
				cQueryTS +=           " ) "
			EndIf

			If !lAtivNaoC .And. (oParams:GetSituac() <> "1" .And. !lTSNCobra) // Só considera TimeSheets cobrável
				cQueryTS +=      " INNER JOIN " + RetSqlName("NRC") + " NRC ON (NRC.NRC_FILIAL = '" + xFilial("NRC") + "' AND "
				cQueryTS +=                                                     " NRC.NRC_COD = NUE.NUE_CATIVI AND "
				cQueryTS +=                                                     " NRC.NRC_TEMPOZ  = '1' AND "
				cQueryTS +=                                                     " NRC.D_E_L_E_T_  = ' ') "
			EndIf

			cQueryTS += " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
			cQueryTS +=     " AND NUE.NUE_SITUAC  = '1' "
			If oParams:GetSituac() <> "1" .And. !lTSNCobra // Conferência e só considera TimeSheets cobrável
				cQueryTS += " AND NUE.NUE_COBRAR  = '1' "
			EndIf

			If oParams:GetTsZero() // clausula where  do filtro ts de participantes com tabela de honorarios zerada
				cQueryTS += oParams:GetTsZero(1)
			EndIf

			cQueryTS +=      " AND (NUE.NUE_CLTAB = '"+ Space(TamSx3('NUE_CLTAB')[1]) + "' "
			cQueryTS +=           " OR EXISTS (SELECT NV4.R_E_C_N_O_ "
			cQueryTS +=                              " FROM " + RetSqlName("NV4") + " NV4 "
			cQueryTS +=                              " WHERE NV4.NV4_FILIAL = '" +xFilial("NV4") +"' "
			cQueryTS +=                              " AND NV4.NV4_COD = NUE.NUE_CLTAB "
			cQueryTS +=                              " AND NV4.NV4_SITUAC = '1' "
			If oParams:GetSituac() <> "1" // Não é conferência
				cQueryTS +=                          " AND NV4.NV4_COBRAR = '1' "
			EndIf
			cQueryTS +=                              " AND NV4.NV4_CONC = '1' "
			cQueryTS +=                              " AND " + cTEMLT + " = '1' "
			cQueryTS +=                              " AND NV4.D_E_L_E_T_ = ' ')) "

			If oParams:GetSituac() <> "1" .And. !lTSNCobra // Não é conferência e só considera TimeSheets cobrável
				cQueryTS +=   " AND NOT EXISTS (SELECT NTJ.R_E_C_N_O_ "
				cQueryTS +=                     " FROM " + RetSqlName("NTJ") + " NTJ "
				cQueryTS +=                    " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
				cQueryTS +=                       "AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
				cQueryTS +=                       "AND NTJ.NTJ_CCONTR = '" + cCodContr + "' "
				cQueryTS +=                       "AND NTJ.D_E_L_E_T_ = ' ') "
			EndIf

			cQueryTS += " AND NUE.D_E_L_E_T_ = ' ' "

			If cTEMTS == "2" .And. lVincTS
				//Vincula os TSs dos casos vinculados ao contrato Fixo.
				cQueryTS +=   " AND EXISTS (SELECT NUT.R_E_C_N_O_  "
				cQueryTS +=                     " FROM " + RetSqlName("NUT") + " NUT "
				cQueryTS +=                     " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
				cQueryTS +=                       " AND NUT.NUT_CCONTR = '" + cCodContr +"' "
				cQueryTS +=                       " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
				cQueryTS +=                       " AND NUT.NUT_CLOJA = NUE.NUE_CLOJA "
				cQueryTS +=                       " AND NUT.NUT_CCASO = NUE.NUE_CCASO "
				cQueryTS +=                       " AND NUT.D_E_L_E_T_ = ' ' "
				cQueryTS +=             " ) "
				//Vincula somente os TSs de casos que não estão em outros contratos 'por hora'
				If !lMinimo
					cQueryTS +=   " AND NOT EXISTS ( SELECT NUT.R_E_C_N_O_ "
					cQueryTS +=                       " FROM " + RetSqlName("NUT") + " NUT "
					cQueryTS +=                            " INNER JOIN " + RetSqlName("NT0") + " NT0 
					cQueryTS +=                                    " ON (NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
					cQueryTS +=                                   " AND NT0.NT0_COD     = NUT.NUT_CCONTR "
					If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
						aVigencia := JurGetDados("NT0", 1, xFilial("NT0") + cCodContr, {"NT0_DTVIGI", "NT0_DTVIGF"})
						If !Empty(aVigencia[1])
													cQueryTS +=   " AND NT0.NT0_DTVIGI >= '" + DtoS(aVigencia[1]) + "'"
													cQueryTS +=   " AND NT0.NT0_DTVIGF <= '" + DtoS(aVigencia[2]) + "'"
						EndIf
					EndIf
					cQueryTS +=                                   " AND NT0.D_E_L_E_T_  = ' ') "
					cQueryTS +=                                 " INNER JOIN " + RetSqlName("NRA") + " NRA 
					cQueryTS +=                                    " ON (NRA.NRA_FILIAL = '" + xFilial("NRA") + "'"
					cQueryTS +=                                   " AND NRA.NRA_COD    = NT0.NT0_CTPHON "
					cQueryTS +=                                   " AND NRA.NRA_COBRAH = '1' "
					cQueryTS +=                                   " AND NRA.D_E_L_E_T_ = ' ') "
					cQueryTS +=                                 " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
					cQueryTS +=                                   " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
	 				cQueryTS +=                                   " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
					cQueryTS +=                                   " AND NUT.NUT_CCASO  = NUE.NUE_CCASO "
					cQueryTS +=                                   " AND NUT.D_E_L_E_T_ = ' ') "
				EndIf
			Else
				cQueryTS +=   " AND NUE.NUE_CCLIEN = '" + cCodClien +"' "
				cQueryTS +=   " AND NUE.NUE_CLOJA  = '" + cLoja +"' "
				cQueryTS +=   " AND NUE.NUE_CCASO  = '" + cCodCaso +"' "
				If oParams:GetSituac() <> "1" .And. !lTSNCobra // Não é conferência e só considera TimeSheets cobrável
					cQueryTS +=   " AND NUE.NUE_COBRAR = '1' "
				EndIf
			EndIf

			If cTEMTS == "1" .And. !lMinimo // Para Mínimo o vínculo de TSs deve obedecer o período das parcelas
				If !Empty(oParams:GetDIniH()) .And. !Empty(oParams:GetDFinH())
					cQueryTS += J201BVigCtr(DtoS(oParams:GetDIniH()), DtoS(oParams:GetDFinH()), "NUE.NUE_DATATS", cCodContr)
				EndIf
				If lCpoFxNc .And. !Empty(oParams:GetDInIFxNc()) .And. !Empty(oParams:GetDFinFxNc())
					cQueryTS += J201BVigCtr(DtoS(oParams:GetDInIFxNc()), DtoS(oParams:GetDFinFxNc()), "NUE.NUE_DATATS", cCodContr)
				EndIf
			Else
				cQueryTS += JA201BDtTS(cCodPre, , cCodContr, oParams)
			EndIf

			If oParams:GetSituac() == "1"
				cQueryTS += " GROUP BY NUE.NUE_COD " //Para mais de uma paracela de FX, esta duplicando os TS, e não é possivel o Exists para NT1 por conta de ser Outer Join
			Else
				cQueryTS += " AND NUE.NUE_CPREFT = '"+ Space(TamSx3('NUE_CPREFT')[1]) + "' "
			EndIf

		EndIf

		If oParams:GetTpExec() == "6" // Reemitir a pré de Fatura Cancelada
			cQueryTS := "SELECT NW0.NW0_CTS NUE_COD "
			cQueryTS +=    " FROM " + RetSqlName("NW0") + " NW0  "
			cQueryTS +=    " WHERE NW0.NW0_FILIAL = '" + xFilial("NW0") +"' "
			cQueryTS +=      " AND NW0.NW0_CFATUR = '" + oParams:GetCodFatur() +"' "
			cQueryTS +=      " AND NW0.NW0_CESCR  = '" + oParams:GetCodEscr() +"' "
			If NW0->(ColumnPos('NW0_DTVINC')) > 0 //Proteção
				cQueryTS +=  " AND NW0.NW0_DTVINC = '" + cSpaceDT + "' "
			EndIf
			cQueryTS +=      " AND NW0.D_E_L_E_T_ = ' ' "
		EndIf

		If oParams:GetTpExec() == "1" .And. oParams:GetSituac() == "1" //Emissão de Pré - Conferência
			// Se for conferência, insere na temporária

			cQueryTS := ChangeQuery(cQueryTS, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryTS ), cQryRes, .T., .F. )

			While !(cQryRes)->(EOF())

				// NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
				If Empty(JurGetDados("NW0", 1, xFilial("NW0") + (cQryRes)->NUE_COD + "1" + cCodPre, "NW0_CTS"))
					// NW0_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
					RecLock("NW0", .T.)
					NW0->NW0_FILIAL  := xFilial("NW0")
					NW0->NW0_CTS     := (cQryRes)->NUE_COD
					NW0->NW0_SITUAC  := "1"
					NW0->NW0_PRECNF  := cCodPre
					NW0->NW0_CANC    := "2"
					NW0->NW0_CODUSR  := oParams:GetCodUser()

					NW0->(MsUnlock())
					NW0->(DbCommit())

					//Grava na fila de sincronização a alteração
					If !lRevisLD
						J170GRAVA("NUE", xFilial("NUE") + (cQryRes)->NUE_COD, "4")
					EndIf
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
		EndIf

		If (oParams:GetTpExec() $ "1|6" .And. oParams:GetSituac() <> "1") .And. ( cTEMTS = "1" .Or. lVincTS )   // Emissão de Pré-Fatura
			// Se for emissão de pré, atualiza o Lançamento com o num da Pré

			cCmd := " SELECT R_E_C_N_O_ RECNO "
			cCmd +=   " FROM " + RetSqlName("NUE") + " NUE "
			cCmd +=  " INNER JOIN (" + cQueryTS + ") NUE2"
			cCmd +=     " ON  NUE.NUE_COD = NUE2.NUE_COD "
			cCmd +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
			cCmd +=    " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
			cCmd +=    " AND NUE.D_E_L_E_T_ = ' ' "

			If oParams:GetFltrFA() // Se for fatura adicional, valida se a mesma tem vinculo de TS ativado
				cCmd +=  " AND EXISTS (SELECT 1 FROM " + RetSqlName("NVV") + " NVV "
				cCmd +=                      " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
				cCmd +=                        " AND NVV.NVV_COD = '" + cCodFatAd + "'"
				cCmd +=                        " AND NVV.NVV_TRATS = '1'"
				cCmd +=                        " AND NVV.D_E_L_E_T_ = ' ' "
			EndIf

			aSqlRet := JurSQL(cCmd, {"RECNO"})

			cCodPart := JurUsuario(__CUSERID)

			For nI := 1 To Len(aSqlRet)
				NUE->(DbGoto(aSqlRet[nI][1]))
				If RecLock("NUE", .F., .F., .F., .T.)
					NUE->NUE_CPREFT := cCodPre
					NUE->NUE_CUSERA := cCodPart
					NUE->NUE_ALTDT  := Date()
					If lAltHr
						NUE->NUE_ALTHR := Time()
					EndIf
					NUE->(MsUnlock())
					NUE->(DbCommit())

					//Grava na fila de sincronização a alteração
					If !lRevisLD
						J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
					EndIf
				Else
					aRet := {.F., "JA201BVinc - NUE - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
					Exit
				EndIf
			Next nI

			If (oParams:GetTpExec() $ "6") .And. aRet[1]
				cCmd := " SELECT NW0_PF.R_E_C_N_O_ RECNO "
				cCmd += " FROM " + RetSqlName("NW0") + " NW0_PF, " + RetSqlName("NW0") + " NW0_FT "
				cCmd += " WHERE NW0_PF.NW0_FILIAL = '" + xFilial("NW0") +"' "
				cCmd += " AND NW0_FT.NW0_FILIAL = '" + xFilial("NW0") +"' "
				cCmd += " AND NW0_PF.NW0_PRECNF = '" + cCodPre +"' "
				cCmd += " AND NW0_PF.NW0_CANC = '1' "
				cCmd += " AND NW0_FT.NW0_CFATUR = '" + oParams:GetCodFatur() +"' "
				cCmd += " AND NW0_FT.NW0_CESCR  = '" + oParams:GetCodEscr() +"' "
				cCmd += " AND NW0_PF.NW0_CTS = NW0_FT.NW0_CTS "
				cCmd += " AND NW0_PF.D_E_L_E_T_ = ' ' "
				cCmd += " AND NW0_FT.D_E_L_E_T_ = ' ' "

				aSqlRet := JurSQL(cCmd, {"RECNO"})

				For nI := 1 To Len(aSqlRet)
					NW0->(DbGoto(aSqlRet[nI][1]))
					If RecLock("NW0", .F., .F., .F., .T.)
						NW0->NW0_SITUAC  := '1'
						NW0->NW0_CANC    := '2'
						NW0->(MsUnlock())
						NW0->(DbCommit())
						//Grava na fila de sincronização
						If !lRevisLD
							J170GRAVA("NUE", xFilial("NUE") + NW0->NW0_CTS, "4")
						EndIf
					Else
						aRet := {.F., "JA201BVinc - NW0 - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
						Exit
					EndIf
				Next nI
			EndIf

		EndIf

		If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de pré fatura / Minuta de Fatura / Fatura

			If !Empty(cCodFatAd) .Or. cTEMFA == "1" .Or. ( cTEMFX == "1" .And. Empty(cCodPre) )

				If cTEMFX == "1"
					cFilDtTs := JA201BDtTS(cCodPre, cCodFixo, cCodContr, oParams)
				EndIf

				cQueryTS := " SELECT NUE.NUE_COD, '" + cSpaceDT + "' NW0_DTVINC, NUE_CCLIEN, NUE_CLOJA, NUE_CCASO "
				cQueryTS +=   " FROM " + RetSqlName("NUE") + " NUE "
				If !lAtivNaoC .And. (oParams:GetSituac() <> "1" .And. !lTSNCobra) // Só considera TimeSheets cobrável
					cQueryTS +=      " INNER JOIN " + RetSqlName("NRC") + " NRC ON (NRC.NRC_FILIAL = '" + xFilial("NRC") + "' AND "
					cQueryTS +=                                                     " NRC.NRC_COD = NUE.NUE_CATIVI AND "
					cQueryTS +=                                                     " NRC.NRC_TEMPOZ  = '1' AND "
					cQueryTS +=                                                     " NRC.D_E_L_E_T_  = ' ') "
				EndIf
				cQueryTS +=  " WHERE NUE.NUE_FILIAL  = '" + xFilial("NUE") +"' "
				cQueryTS +=    " AND NUE.NUE_CCLIEN  = '" + cCodClien +"' "
				cQueryTS +=    " AND NUE.NUE_CLOJA   = '" + cLoja +"' "
				cQueryTS +=    " AND NUE.NUE_CCLIEN  = '" + cCodClien +"' "
				cQueryTS +=    " AND NUE.NUE_CLOJA   = '" + cLoja +"' "
				cQueryTS +=    " AND NUE.NUE_CCASO   = '" + cCodCaso +"' "
				If oParams:GetSituac() <> "1" .And. !lTSNCobra // Não é conferência e só considera TimeSheets cobrável
					cQueryTS +=    " AND NUE.NUE_COBRAR = '1' "
				EndIf
				cQueryTS +=    " AND NUE.NUE_CPREFT = '" + cCodPre +"' "

				If oParams:GetSituac() <> "1" .And. !lTSNCobra // Só considera TimeSheets cobrável
					cQueryTS +=    " AND NOT EXISTS (SELECT NTJ.R_E_C_N_O_ "
					cQueryTS +=                      " FROM " + RetSqlName("NTJ") + " NTJ "
					cQueryTS +=                     " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
					cQueryTS +=                       " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
					cQueryTS +=                       " AND NTJ.NTJ_CCONTR = '" + cCodContr + "' "
					cQueryTS +=                       " AND NTJ.D_E_L_E_T_ = ' ') "
				EndIf

				If cTEMTS == "2" .And. cTEMFX == "1"
					//Vincula os TSs dos casos vinculados ao contrato Fixo.
					//Vincula somente os TSs de casos que não estão em outros contratos 'por hora'
					cQueryTS += " AND NOT EXISTS ( SELECT NUT.R_E_C_N_O_ "
					cQueryTS +=                    " FROM " + RetSqlName("NUT") + " NUT "
					cQueryTS +=                         " INNER JOIN " + RetSqlName("NT0") + " NT0 ON (NT0.NT0_FILIAL = '" + xFilial("NT0") +"' AND "
					cQueryTS +=                                                                      " NT0.NT0_COD    = NUT.NUT_CCONTR AND "
					cQueryTS +=                                                                      " NT0.D_E_L_E_T_ = ' ') "
					cQueryTS +=                         " INNER JOIN " + RetSqlName("NRA") + " NRA ON (NRA.NRA_FILIAL = '" + xFilial("NRA") +"' AND "
					cQueryTS +=                                                                      " NRA.NRA_COD    = NT0.NT0_CTPHON AND "
					cQueryTS +=                                                                      " NRA.NRA_COBRAH = '1' AND "
					cQueryTS +=                                                                      " NRA.D_E_L_E_T_ = ' ') "
					cQueryTS +=                     " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
					cQueryTS +=                       " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
 					cQueryTS +=                       " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
					cQueryTS +=                       " AND NUT.NUT_CCASO  = NUE.NUE_CCASO "
					cQueryTS +=                       " AND NUT.D_E_L_E_T_ = ' ') "
				EndIf
				If lFatAtiva
					cQueryTS += " AND NUE.NUE_SITUAC = '2' "
				Else
					cQueryTS += " AND NUE.NUE_SITUAC = '1' "
				EndIf
				If !Empty(oParams:GetDIniH()) .And. !Empty(oParams:GetDFinH())
					cQueryTS += J201BVigCtr(DtoS(oParams:GetDIniH()), DtoS(oParams:GetDFinH()), "NUE.NUE_DATATS", cCodContr)
				Else
					If !Empty(cFilDtTs)
						cQueryTS += cFilDtTs
					EndIf
				EndIf
				cQueryTS += " AND NUE.D_E_L_E_T_ = ' ' "
			Else
				cQueryTS := "SELECT NUE.NUE_COD, '" + cSpaceDT + "' NW0_DTVINC, NUE_CCLIEN, NUE_CLOJA, NUE_CCASO "
				cQueryTS += " FROM " + RetSqlName("NUE") + " NUE  "
				cQueryTS += " INNER JOIN " + RetSqlName("NX1") + " NX1 "
				cQueryTS +=         " ON NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
				cQueryTS +=        " AND NX1.NX1_CPREFT = '" + cCodPre + "' "
				cQueryTS +=        " AND NX1.NX1_CCONTR = '" + cCodContr + "' "
				cQueryTS +=        " AND NX1.NX1_CJCONT = '" + cCodJunc + "' "
				cQueryTS +=        " AND NX1.NX1_CCLIEN = '" + cCodClien + "' "
				cQueryTS +=        " AND NX1.NX1_CLOJA = '" + cLoja + "' "
				cQueryTS +=        " AND NX1.NX1_CCASO = '" + cCodCaso + "' "
				cQueryTS +=        " AND NX1.NX1_TS = '1' "
				cQueryTS +=        " AND NX1.D_E_L_E_T_ = ' ' "
				cQueryTS += " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
				If lFatAtiva // verifica se tem faturas emitidas para essa pré-fatura
					cQueryTS += " AND NUE.NUE_SITUAC = '2' "
				Else
					cQueryTS += " AND NUE.NUE_SITUAC = '1' "
				EndIf
				If !Empty(cCodClien)
					cQueryTS += " AND NUE.NUE_CCLIEN = '" + cCodClien +"' "
				EndIf
				If !Empty(cLoja)
					cQueryTS += " AND NUE.NUE_CLOJA = '" + cLoja +"' "
				EndIf
				If !Empty(cCodCaso)
					cQueryTS += " AND NUE.NUE_CCASO	= '" + cCodCaso +"' "
				EndIf
				cQueryTS += " AND NUE.NUE_CPREFT = '" + cCodPre +"' "
				cQueryTS += " AND NUE.D_E_L_E_T_ = ' ' "
			EndIf

			//Revincula os Timesheets de faturas multipayers que foram vinculados pela operação de fataura.
			If lFatAtiva .And. lDataVinc  //Regra + Proteção  
				cQueryTS += " UNION " 
				cQueryTS += " SELECT DISTINCT NW0.NW0_CTS NUE_COD " 
				cQueryTS += Iif(lDataVinc, ", NW0.NW0_DTVINC ", ", '" + cSpaceDT + "' NW0_DTVINC " )
				cQueryTS += " , NW0.NW0_CCLIEN, NW0.NW0_CLOJA, NW0.NW0_CCASO "
				cQueryTS +=   " FROM " + RetSqlname('NW0') + " NW0 " 
				cQueryTS +=         " INNER JOIN " + RetSqlname('NXA')+" NXA " 
				cQueryTS +=                 " ON NXA.NXA_FILIAL = '" +xFilial("NXA")+"' " 
				cQueryTS +=                      " AND NXA.NXA_COD = NW0.NW0_CFATUR " 
				cQueryTS +=                      " AND NXA.NXA_CESCR = NW0.NW0_CESCR " 
				If !Empty(cCodPre)
					cQueryTS +=                      " AND NXA.NXA_CPREFT = '" + cCodPre + "' "
				Else
					cQueryTS +=                      " AND NXA.NXA_CFIXO = '" + cCodFixo + "' "
				EndIf
				cQueryTS +=                      " AND NXA.NXA_SITUAC = '1' " 
				cQueryTS +=                      " AND NXA.NXA_TIPO = 'FT' "
				cQueryTS +=                      " AND NXA.D_E_L_E_T_ = ' ' "
				cQueryTS +=   " WHERE NW0.NW0_FILIAL = '" +xFilial("NW0")+"' " 
				cQueryTS +=     " AND NW0.NW0_DTVINC > '" + cSpaceDT + "' " 
				cQueryTS +=     " AND NW0.D_E_L_E_T_ = ' ' " 
				If !Empty(cCodClien)
					cQueryTS += " AND NW0.NW0_CCLIEN = '" + cCodClien +"' "
				EndIf
				If !Empty(cLoja)
					cQueryTS += " AND NW0.NW0_CLOJA = '" + cLoja +"' "
				EndIf
				If !Empty(cCodCaso)
					cQueryTS += " AND NW0.NW0_CCASO = '" + cCodCaso +"' "
				EndIf
			EndIf

			cQueryTS := ChangeQuery(cQueryTS, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryTS ), cQryRes, .T., .F. )

			lCasoMae := .F.

			If !(cQryRes)->(EOF()) .And. lFSinc .And. oParams:GetTpExec() == "5" .And. NW0->(ColumnPos("NW0_CCLICM")) > 0  // Fatura
				If !Empty(cCodFatAd)
					aCMaeFaTs := JACasMae(1, cCodClien, cLoja, cCodCaso)
					If !Empty(aCMaeFaTs) .And. Len(aCMaeFaTs[1]) == 3
						cCasMaeCli := aCMaeFaTs[1][1]
						cCasMaeLoj := aCMaeFaTs[1][2]
						cCasMaeCas := aCMaeFaTs[1][3]
						lCasoMae   := .T.
					EndIf
				ElseIf lCobHMae
					cCasMaeCli := cClienteMae
					cCasMaeLoj := cLojaMae
					cCasMaeCas := cCasoMae
					lCasoMae   := .T.
				EndIf
			EndIf

			While !(cQryRes)->(EOF())
				// NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
				If Empty(JurGetDados("NW0", 1, xFilial("NW0") + (cQryRes)->NUE_COD + "4" + cCodPre + cFatura + cEscr, "NW0_CTS"))
					// NW0_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
					RecLock("NW0", .T.)
					NW0->NW0_FILIAL       := xFilial("NW0")
					NW0->NW0_CTS          := (cQryRes)->NUE_COD
					NW0->NW0_SITUAC       := "4"
					NW0->NW0_PRECNF       := cCodPre
					NW0->NW0_CFATUR       := cFatura
					NW0->NW0_CESCR        := cEscr
					NW0->NW0_CANC         := "2"
					NW0->NW0_CODUSR       := oParams:GetCodUser()
					NW0->NW0_CCLIEN       := (cQryRes)->NUE_CCLIEN
					NW0->NW0_CLOJA        := (cQryRes)->NUE_CLOJA
					NW0->NW0_CCASO        := (cQryRes)->NUE_CCASO
					If lCasoMae
						NW0->NW0_CCLICM   := cCasMaeCli
						NW0->NW0_CLOJCM   := cCasMaeLoj
						NW0->NW0_CCASCM   := cCasMaeCas
					EndIf

					If lDataVinc
						NW0->NW0_DTVINC   := StoD((cQryRes)->NW0_DTVINC)
					EndIf

					NW0->(MsUnlock())
					NW0->(DbCommit())

					// Grava na fila de sincronização a alteração
					If !lRevisLD .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NUE na fila
						J170GRAVA("NUE", xFilial("NUE") + (cQryRes)->NUE_COD, "4")
					EndIf
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())

		EndIf

	EndIf

	/****************************
	// VINCULA TABELADO
	****************************/
	If aRet[1] .And. cTEMLT == "1"

		oParams:PtInternal(STR0135) // "Vinc Lanctos do Caso - Tabelado"
		If oParams:GetTpExec() = "1" // Emissão de pré

			cQueryLT :=      "SELECT NV4.NV4_COD "
			cQueryLT +=       " FROM " + RetSqlName("NV4") + " NV4 "
			If oParams:GetSituac() <> "1" //Conferencia
				cQueryLT +=  " INNER JOIN " + RetSqlName('NVE') + " NVE "
			    cQueryLT +=     " ON ( NVE.NVE_FILIAL = '"+ xFilial("NVE") + "' "
				cQueryLT +=    " AND NVE.NVE_COBRAV = '1' "
				cQueryLT +=    " AND NVE.D_E_L_E_T_ = ' ' "
				cQueryLT +=    " AND NVE.NVE_NUMCAS = NV4.NV4_CCASO"
				cQueryLT +=    " AND NVE.NVE_CCLIEN = NV4.NV4_CCLIEN "
				cQueryLT +=    " AND NVE.NVE_LCLIEN = NV4.NV4_CLOJA) "
			EndIf
			cQueryLT +=      " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
			cQueryLT +=        " AND NV4.NV4_CCLIEN = '" + cCodClien + "' "
			cQueryLT +=        " AND NV4.NV4_CLOJA = '" + cLoja + "' "
			cQueryLT +=        " AND NV4.NV4_CCASO = '" + cCodCaso + "' "
			cQueryLT +=        " AND NV4.NV4_SITUAC = '1' "
			If oParams:GetSituac() <> "1" // Conferência
				cQueryLT +=    " AND NV4.NV4_COBRAR = '1' "
			EndIf
			cQueryLT +=        " AND NV4.NV4_CONC = '1' "

			If !Empty(oParams:GetDIniT()) .And. !Empty(oParams:GetDFinT())
				cQueryLT += J201BVigCtr(DtoS(oParams:GetDIniT()), DtoS(oParams:GetDFinT()), "NV4.NV4_DTCONC", cCodContr)
			EndIf
			If oParams:GetSituac() = "1"
				cQueryLT += " AND NV4.NV4_CPREFT = NV4.NV4_CPREFT "
			 Else
				cQueryLT += " AND NV4.NV4_CPREFT =  '"+ Space(TamSx3('NV4_CPREFT')[1]) + "' "
			EndIf
			cQueryLT +=     " AND NV4.D_E_L_E_T_ = ' ' "
		EndIf

		If oParams:GetTpExec() == "6" // Reemitir a pré de Fatura Cancelada
			cQueryLT := "SELECT NW4.NW4_CLTAB NV4_COD "
			cQueryLT +=    " FROM " + RetSqlName("NW4") + " NW4  "
			cQueryLT +=    " WHERE NW4.NW4_FILIAL = '" + xFilial("NW4") +"' "
			cQueryLT +=      " AND NW4.NW4_CFATUR = '" + oParams:GetCodFatur() +"' "
			cQueryLT +=      " AND NW4.NW4_CESCR  = '" + oParams:GetCodEscr() +"' "
			cQueryLT +=      " AND NW4.D_E_L_E_T_ = ' ' "
		EndIf

		If oParams:GetTpExec() = "1" .And. oParams:GetSituac() = "1" //Emissão de Pré - Conferência
			// Se for conferência, insere na temporária

			cQueryLT := ChangeQuery(cQueryLT, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryLT ), cQryRes, .T., .F. )

			While !(cQryRes)->(EOF())

				// NW0_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
				RecLock("NW4",.T.)
				NW4->NW4_FILIAL := xFilial("NW4")
				NW4->NW4_CLTAB  := (cQryRes)->NV4_COD
				NW4->NW4_SITUAC := "1"
				NW4->NW4_PRECNF := cCodPre
				NW4->NW4_CANC   := "2"
				NW4->NW4_CODUSR := oParams:GetCodUser()

				NW4->(MsUnlock())
				NW4->(DbCommit())

				//Grava na fila de sincronização a alteração
				If !lRevisLD
					J170GRAVA("NV4", xFilial("NV4") + (cQryRes)->NV4_COD, "4")
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
		EndIf

		If ( oParams:GetTpExec() $ "1|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré-Fatura
			// Se for emissão de pré, atualiza o Lançamento com o num da Pré

			cCmd :=  "SELECT R_E_C_N_O_ RECNO "
			cCmd +=   " FROM " + RetSqlName("NV4") + " NV4 "
			cCmd +=  " INNER JOIN (" + cQueryLT  + ") NV42 "
			cCmd +=     " ON NV4.NV4_COD = NV42.NV4_COD "
			cCmd +=  " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
			cCmd +=    " AND NV4.NV4_CPREFT = '" + Space(TamSx3('NV4_CPREFT')[1]) + "' "
			cCmd +=    " AND NV4.D_E_L_E_T_ = ' ' "

			If oParams:GetFltrFA() // Se for fatura adicional, valida se a mesma tem vinculo de LT ativado
				cCmd +=  " AND EXISTS (SELECT 1 FROM " + RetSqlName("NVV") + " NVV "
				cCmd +=                      " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
				cCmd +=                        " AND NVV.NVV_COD = '" + cCodFatAd + "'"
				cCmd +=                        " AND NVV.NVV_TRALT = '1'"
				cCmd +=                        " AND NVV.D_E_L_E_T_ = ' ' "
			EndIf

			aSqlRet := JurSQL(cCmd, {"RECNO"})

			For nI := 1 To Len(aSqlRet)
				NV4->(DbGoto(aSqlRet[nI][1]))
				If RecLock("NV4", .F., .F., .F., .T.)
					NV4->NV4_CPREFT := cCodPre
					NV4->(MsUnlock())
					NV4->(DbCommit())

					//Grava na fila de sincronização a alteração
					If !lRevisLD
						J170GRAVA("NV4", xFilial("NV4") + NV4->NV4_COD, "4")
					EndIf

				Else
					aRet := {.F., "JA201BVinc - NV4 - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
					Exit
				EndIf
			Next nI

			If (oParams:GetTpExec() $ "6") .And. aRet[1]
				cCmd := " SELECT NW4_PF.R_E_C_N_O_ RECNO "
				cCmd += " FROM " + RetSqlName("NW4") + " NW4_PF, " + RetSqlName("NW4") + " NW4_FT "
				cCmd += " WHERE NW4_PF.NW4_FILIAL = '" + xFilial("NW4") +"' "
				cCmd += " AND NW4_FT.NW4_FILIAL = '" + xFilial("NW4") +"' "
				cCmd += " AND NW4_PF.NW4_PRECNF = '" + cCodPre +"' "
				cCmd += " AND NW4_PF.NW4_CANC = '1' "
				cCmd += " AND NW4_FT.NW4_CFATUR = '" + oParams:GetCodFatur() +"' "
				cCmd += " AND NW4_FT.NW4_CESCR  = '" + oParams:GetCodEscr() +"' "
				cCmd += " AND NW4_PF.NW4_CLTAB = NW4_FT.NW4_CLTAB "
				cCmd += " AND NW4_PF.D_E_L_E_T_ = ' ' "
				cCmd += " AND NW4_FT.D_E_L_E_T_ = ' ' "

				aSqlRet := JurSQL(cCmd, {"RECNO"})

				For nI := 1 To Len(aSqlRet)
					NW4->(DbGoto(aSqlRet[nI][1]))
					If RecLock("NW4", .F., .F., .F., .T.)
						NW4->NW4_SITUAC  := '1'
						NW4->NW4_CANC    := '2'
						NW4->(MsUnlock())
						NW4->(DbCommit())
						//Grava na fila de sincronização a alteração
						If !lRevisLD
							J170GRAVA("NV4", xFilial("NV4") + NW4->NW4_CLTAB, "4")
						EndIf
					Else
						aRet := {.F., "JA201BVinc - NW4 - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
						Exit
					EndIf
				Next nI
			EndIf

		EndIf

		If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de pré fatura / Minuta de Fatura / Fatura

			If !Empty(cCodFatAd) .Or. cTEMFA == "1"

				cQueryLT :=     "SELECT NV4.NV4_COD, NV4_CCLIEN, NV4_CLOJA, NV4_CCASO "
				cQueryLT +=      " FROM " + RetSqlName("NV4") + " NV4  "
				If oParams:GetSituac() <> "1" // Conferencia
					cQueryLT += " INNER JOIN " + RetSqlName("NVE") + " NVE "
					cQueryLT +=    " ON ( NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
					cQueryLT +=   " AND NVE.NVE_COBRAV = '1' "
					cQueryLT +=   " AND NVE.D_E_L_E_T_ = ' ' "
					cQueryLT +=   " AND NVE.NVE_NUMCAS = NV4.NV4_CCASO "
					cQueryLT +=   " AND NVE.NVE_CCLIEN = NV4.NV4_CCLIEN "
					cQueryLT +=   " AND NVE.NVE_LCLIEN = NV4.NV4_CLOJA) "
				EndIf
				cQueryLT +=     " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
				cQueryLT +=       " AND NV4.NV4_CCLIEN ='" + cCodClien + "' "
				cQueryLT +=       " AND NV4.NV4_CLOJA = '" + cLoja + "' "
				cQueryLT +=       " AND NV4.NV4_CCASO = '" + cCodCaso + "' "
				cQueryLT +=       " AND NV4.NV4_SITUAC = '1' "
				cQueryLT +=       " AND NV4.NV4_COBRAR = '1' "
				cQueryLT +=       " AND NV4.NV4_CONC = '1' "

				If !Empty(oParams:GetDIniT()) .And. !Empty(oParams:GetDFinT())
					cQueryLT += J201BVigCtr(DtoS(oParams:GetDIniT()), DtoS(oParams:GetDFinT()), "NV4.NV4_DTCONC", cCodContr)
				EndIf
				If !Empty(cCodPre)
					cQueryLT +=   " AND NV4.NV4_CPREFT = '" + cCodPre +"' "
				 Else
					cQueryLT +=   " AND NV4.NV4_CPREFT = '"+ Space(TamSx3('NV4_CPREFT')[1]) + "' "
				EndIf
				cQueryLT +=       " AND NV4.D_E_L_E_T_ = ' ' "

			Else

				cQueryLT := " SELECT NV4.NV4_COD, NV4_CCLIEN, NV4_CLOJA, NV4_CCASO "
				cQueryLT += " FROM " + RetSqlName("NV4") + " NV4  "
				cQueryLT += " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") +"' "
				If lFatAtiva // verifica se tem faturas emitidas para essa pré-fatura
					cQueryLT += " AND NV4.NV4_SITUAC = '2' "
				Else
					cQueryLT += " AND NV4.NV4_SITUAC = '1' "
				EndIf
				cQueryLT +=     " AND NV4.NV4_CPREFT = '" + cCodPre +"' "
				If !Empty(cCodClien)
					cQueryLT += " AND NV4.NV4_CCLIEN = '" + cCodClien +"' "
				EndIf
				If !Empty(cLoja)
					cQueryLT += " AND NV4.NV4_CLOJA = '" + cLoja +"' "
				EndIf
				If !Empty(cCodCaso)
					cQueryLT += " AND NV4.NV4_CCASO = '" + cCodCaso +"' "
				EndIf

				cQueryLT +=     " AND NV4.D_E_L_E_T_ = ' ' "

			EndIf

			cQueryLT := ChangeQuery(cQueryLT, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryLT ), cQryRes, .T., .F. )

			lCasoMae := .F.

			If !(cQryRes)->(EOF()) .And. lFSinc .And. oParams:GetTpExec() == "5" .And. NW4->(ColumnPos( "NW4_CCLICM" )) > 0 //Fatura
					If !Empty(cCodFatAd)
						aCMaeFaLt := JACasMae(3, cCodClien, cLoja, cCodCaso)

						If !Empty(aCMaeFaLt) .And. Len(aCMaeFaLt[1]) == 3
							cCasMaeCli := aCMaeFaLt[1][1]
							cCasMaeLoj := aCMaeFaLt[1][2]
							cCasMaeCas := aCMaeFaLt[1][3]
							lCasoMae   := .T.
						EndIf
					Else
						cCasMaeCli := cClienteMae
						cCasMaeLoj := cLojaMae
						cCasMaeCas := cCasoMae
						lCasoMae   := .T.
					EndIf
				EndIf

			While !(cQryRes)->(EOF())
				// NW4_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
				If Empty(JurGetDados("NW4", 1, xFilial("NW4") + (cQryRes)->NV4_COD + Space(TamSX3("NW4_CWO")[1]) + cFatura + cEscr + cCodPre + "4", "NW4_CLTAB")) // NW4_FILIAL+NW4_CLTAB+NW4_CWO+NW4_CFATUR+NW4_CESCR+NW4_PRECNF+NW4_SITUAC
					RecLock("NW4", .T.)
					NW4->NW4_FILIAL := xFilial("NW4")
					NW4->NW4_CLTAB  := (cQryRes)->NV4_COD
					NW4->NW4_SITUAC := "4"
					NW4->NW4_PRECNF := cCodPre
					NW4->NW4_CFATUR := cFatura
					NW4->NW4_CESCR  := cEscr
					NW4->NW4_CANC   := "2"
					NW4->NW4_CODUSR := oParams:GetCodUser()
					NW4->NW4_CCLIEN := (cQryRes)->NV4_CCLIEN
					NW4->NW4_CLOJA  := (cQryRes)->NV4_CLOJA
					NW4->NW4_CCASO  := (cQryRes)->NV4_CCASO

					If lCasoMae
						NW4->NW4_CCLICM := cCasMaeCli
						NW4->NW4_CLOJCM := cCasMaeLoj
						NW4->NW4_CCASCM := cCasMaeCas
					EndIf

					NW4->(MsUnlock())
					NW4->(DbCommit())

					// Grava na fila de sincronização a alteração
					If !lRevisLD .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NV4 na fila
						J170GRAVA("NV4", xFilial("NV4") + (cQryRes)->NV4_COD, "4")
					EndIf
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())

		EndIf

	EndIf

	/****************************
	// VINCULA DESPESA
	****************************/
	If aRet[1] .And. (cTEMDP == "1" .Or. lVincDspFx)

		oParams:PtInternal(STR0136) // "Vinc Lanctos do Caso - Despesa"
		If oParams:GetTpExec() == "1"   // Emissão de pré

			cQueryDP :=     "SELECT NVY.NVY_COD, NVY.R_E_C_N_O_ RECNO_NVY "
			cQueryDP +=       "FROM " + RetSqlName("NVY") + " NVY "
			If oParams:GetSituac() <> "1" // Conferencia
				cQueryDP += " INNER JOIN " + RetSqlName('NVE') + " NVE "
			    cQueryDP +=    " ON ( NVE.NVE_FILIAL = '"+ xFilial("NVE") +"' "
				cQueryDP +=   " AND NVE.NVE_COBRAV = '1' "
				cQueryDP +=   " AND NVE.D_E_L_E_T_ = ' ' "
				cQueryDP +=   " AND NVE.NVE_NUMCAS = NVY.NVY_CCASO"
				cQueryDP +=   " AND NVE.NVE_CCLIEN = NVY.NVY_CCLIEN "
				cQueryDP +=   " AND NVE.NVE_LCLIEN = NVY.NVY_CLOJA) "
			EndIf
			cQueryDP +=      "INNER JOIN " + RetSqlName("NRH") + " NRH ON (NRH.NRH_FILIAL = '" + xFilial("NRH") + "' AND "
			cQueryDP +=                                                   "NRH.NRH_COD = NVY.NVY_CTPDSP AND "
			If oParams:GetSituac() <> "1" // Conferência
				cQueryDP +=                                               "NRH.NRH_COBRAR = '1' AND "
			EndIf
			cQueryDP +=                                                   "NRH.D_E_L_E_T_ = ' ' ) "
			cQueryDP +=     " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "'"
			cQueryDP +=       " AND NVY.NVY_CCLIEN = '" + cCodClien + "'"
			cQueryDP +=       " AND NVY.NVY_CLOJA  = '" + cLoja + "'"
			cQueryDP +=       " AND NVY.NVY_CCASO  = '" + cCodCaso + "'"
			If oParams:GetSituac() <> "1" // Conferência
				cQueryDP +=   " AND NVY.NVY_COBRAR = '1'"
			EndIf
			cQueryDP +=       " AND NVY.NVY_SITUAC = '1'"

			If oParams:GetSituac() <> "1" // Conferência
				cQueryDP +=   " AND NOT EXISTS (SELECT NTK.R_E_C_N_O_ "
				cQueryDP +=                     " FROM " + RetSqlName("NTK") + " NTK " 
				cQueryDP +=                    " WHERE NTK.NTK_FILIAL = '" + xFilial("NTK") + "' "
				cQueryDP +=                      " AND NTK.NTK_CCONTR = '" + cCodContr + "' "
				cQueryDP +=                      " AND NTK.NTK_CTPDSP = NVY.NVY_CTPDSP "
				cQueryDP +=                      " AND NTK.D_E_L_E_T_ = ' ') "
			EndIf

			If !Empty(oParams:GetDIniD()) .And. !Empty(oParams:GetDFinD())
				cQueryDP += J201BVigCtr(DtoS(oParams:GetDIniD()), DtoS(oParams:GetDFinD()), "NVY.NVY_DATA", cCodContr)
			EndIf
			If !Empty(oParams:GetTipoDP())
				cQueryDP +=   " AND NVY.NVY_CTPDSP IN (" + oParams:GetTipoDP() +") "
			EndIf

			If oParams:GetSituac() = "1"
				cQueryDP +=   " AND NVY.NVY_CPREFT = NVY.NVY_CPREFT "
			 Else
				cQueryDP +=   " AND NVY.NVY_CPREFT = '" + Space(TamSx3('NVY_CPREFT')[1]) + "' "
			EndIf

			If ExistBlock('J201BDPF')
				cQueryDP += " AND " + ExecBlock('J201BDPF', .F., .F.)
			EndIf

			cQueryDP +=       " AND NVY.D_E_L_E_T_ = ' ' "
			
			If oParams:GetFltrFA() // Se for fatura adicional, valida se a mesma tem vinculo de DP ativado
				cQueryDP +=  " AND EXISTS (SELECT 1 FROM " + RetSqlName("NVV") + " NVV "
				cQueryDP +=                      " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
				cQueryDP +=                        " AND NVV.NVV_COD = '" + cCodFatAd + "'"
				cQueryDP +=                        " AND NVV.NVV_TRADSP = '1'"
				cQueryDP +=                        " AND NVV.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf

		If oParams:GetTpExec() == "6" // Reemitir a pré de Fatura Cancelada
			cQueryDP :=   "SELECT NVZ.NVZ_CDESP NVY_COD, NVY.R_E_C_N_O_ RECNO_NVY "
			cQueryDP +=     "FROM " + RetSqlName("NVZ") + " NVZ "
			cQueryDP +=    "INNER JOIN " + RetSqlName("NVY") + " NVY ON (NVY.NVY_FILIAL = '" + xFilial("NVZ") + "' AND "
			cQueryDP +=                                                " NVY.NVY_COD = NVZ.NVZ_CDESP AND "
			cQueryDP +=                                                " NVY.D_E_L_E_T_ = ' ') "
			cQueryDP +=    "WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") + "' "
			cQueryDP +=     " AND NVZ.NVZ_CFATUR = '" + oParams:GetCodFatur() + "'"
			cQueryDP +=     " AND NVZ.NVZ_CESCR = '" + oParams:GetCodEscr() + "'"
			cQueryDP +=     " AND NVZ.D_E_L_E_T_ = ' ' "
		EndIf

		If oParams:GetTpExec() == "1" .And. oParams:GetSituac() == "1" //Conferência
			// Se for conferência, insere na temporária

			cQueryDP := ChangeQuery(cQueryDP, .F.)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryDP ), cQryRes, .T., .F. )

			While !(cQryRes)->(EOF())

				// NW0_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
				RecLock("NVZ", .T.)
				NVZ->NVZ_FILIAL  := xFilial("NVZ")
				NVZ->NVZ_CDESP   := (cQryRes)->NVY_COD
				NVZ->NVZ_SITUAC  := "1"
				NVZ->NVZ_PRECNF  := cCodPre
				NVZ->NVZ_CANC    := "2"
				NVZ->NVZ_CODUSR  := oParams:GetCodUser()

				NVZ->(MsUnlock())
				NVZ->(DbCommit())

				//Grava na fila de sincronização a alteração
				If !lRevisLD
					J170GRAVA("NVY", xFilial("NVY") + (cQryRes)->NVY_COD, "4")
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
		EndIf

		If ( oParams:GetTpExec() $ "1|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré-Fatura
			// Se for emissão de pré, atualiza o Lançamento com o num da Pré

			cCmd := cQueryDP
			aSqlRet := JurSQL(cCmd, {"RECNO_NVY"})

			For nI := 1 To Len(aSqlRet)
				NVY->(DbGoto(aSqlRet[nI][1]))
				If RecLock("NVY", .F., .F., .F., .T.)
					NVY->NVY_CPREFT := cCodPre
					NVY->(MsUnlock())
					NVY->(DbCommit())

					//Grava na fila de sincronização a alteração
					If !lRevisLD
						J170GRAVA("NVY", xFilial("NVY") + NVY->NVY_COD, "4")
					EndIf
				Else
					aRet := {.F., "JA201BVinc - NVY - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
					Exit
				EndIf
			Next nI

			If (oParams:GetTpExec() $ "6") .And. aRet[1]
				cCmd := " SELECT NVZ_PF.R_E_C_N_O_ RECNO "
				cCmd += " FROM " + RetSqlName("NVZ") + " NVZ_PF, " + RetSqlName("NVZ") + " NVZ_FT "
				cCmd += " WHERE NVZ_PF.NVZ_FILIAL = '" + xFilial("NVZ") +"' "
				cCmd += " AND NVZ_FT.NVZ_FILIAL = '" + xFilial("NVZ") +"' "
				cCmd += " AND NVZ_PF.NVZ_PRECNF = '" + cCodPre + "' "
				cCmd += " AND NVZ_PF.NVZ_CANC = '1' "
				cCmd += " AND NVZ_FT.NVZ_CFATUR = '" + oParams:GetCodFatur() +"' "
				cCmd += " AND NVZ_FT.NVZ_CESCR  = '" + oParams:GetCodEscr() +"' "
				cCmd += " AND NVZ_PF.NVZ_CDESP = NVZ_FT.NVZ_CDESP "
				cCmd += " AND NVZ_PF.D_E_L_E_T_ = ' ' "
				cCmd += " AND NVZ_FT.D_E_L_E_T_ = ' ' "

				aSqlRet := JurSQL(cCmd, {"RECNO"})

				For nI := 1 To Len(aSqlRet)
					NVZ->(DbGoto(aSqlRet[nI][1]))
					If RecLock("NVZ", .F., .F., .F., .T.)
						NVZ->NVZ_SITUAC  := '1'
						NVZ->NVZ_CANC    := '2'
						NVZ->(MsUnlock())
						NVZ->(DbCommit())
						//Grava na fila de sincronização a alteração
						If !lRevisLD
							J170GRAVA("NVY", xFilial("NVY") + NVZ->NVZ_CDESP, "4")
						EndIf
					Else
						aRet := {.F., "JA201BVinc - NVZ - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
						Exit
					EndIf
				Next nI
			EndIf

		EndIf

		If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de pré fatura / Minuta de Fatura / Fatura

			If ( !Empty(cCodFatAd) .Or. cTEMFA == "1" ) .Or. lVincDspFx
				cQueryDP := " SELECT NVY.NVY_COD, NVY_CCLIEN, NVY_CLOJA, NVY_CCASO "
				cQueryDP += J201BQDsp(cCodClien, cLoja, cCodCaso, cCodContr, lVincDspFx, dDtIniDsp, ;
				                      dDtFimDsp, cCodPre, oParams:GetDIniD(), oParams:GetDFinD(), ;
				                      oParams:GetSituac())
			Else
				cQueryDP :=     "SELECT NVY.NVY_COD, NVY_CCLIEN, NVY_CLOJA, NVY_CCASO "
				cQueryDP +=      " FROM " + RetSqlName("NVY") + " NVY  "
				If oParams:GetSituac() <> "1" // Conferencia
					cQueryDP += " INNER JOIN " + RetSqlName('NVE') + " NVE "
					cQueryDP +=    " ON ( NVE.NVE_FILIAL = '"+ xFilial("NVE") + "' "
					cQueryDP +=   " AND NVE.NVE_COBRAV = '1' "
					cQueryDP +=   " AND NVE.D_E_L_E_T_ = ' ' "
					cQueryDP +=   " AND NVE.NVE_NUMCAS = NVY.NVY_CCASO "
					cQueryDP +=   " AND NVE.NVE_CCLIEN = NVY.NVY_CCLIEN "
					cQueryDP +=   " AND NVE.NVE_LCLIEN = NVY.NVY_CLOJA) "
				EndIf
				cQueryDP +=     " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") +"' "
				If lFatAtiva // verifica se tem faturas emitidas para essa pré-fatura
					cQueryDP +=   " AND NVY.NVY_SITUAC = '2' "
				Else
					cQueryDP +=   " AND NVY.NVY_SITUAC = '1' "
				EndIf
				cQueryDP +=       " AND NVY.NVY_CPREFT = '" + cCodPre + "' "
				If !Empty(cCodClien)
					cQueryDP +=   " AND NVY.NVY_CCLIEN = '" + cCodClien + "' "
				EndIf
				If !Empty(cLoja)
					cQueryDP +=   " AND NVY.NVY_CLOJA = '" + cLoja + "' "
				EndIf
				If !Empty(cCodCaso)
					cQueryDP +=   " AND NVY.NVY_CCASO = '" + cCodCaso + "' "
				EndIf
				cQueryDP +=       " AND NVY.D_E_L_E_T_ = ' ' "
			EndIf

			cQueryDP := ChangeQuery(cQueryDP, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryDP ), cQryRes, .T., .F. )

			lCasoMae   := .F.

			If !(cQryRes)->(EOF()) .And. lFSinc .And. cTEMDP == "1" .And. oParams:GetTpExec() == "5" .And. NVZ->(ColumnPos( "NVZ_CCLICM" )) > 0 //Fatura
					If !Empty(cCodFatAd)
						aCMaeFaDp := JACasMae(2, cCodClien, cLoja, cCodCaso)

						If !Empty(aCMaeFaDp) .And. Len(aCMaeFaDp[1]) == 3
							cCasMaeCli := aCMaeFaDp[1][1]
							cCasMaeLoj := aCMaeFaDp[1][2]
							cCasMaeCas := aCMaeFaDp[1][3]
							lCasoMae   := .T.
						EndIf
					Else
						cCasMaeCli := cClienteMae
						cCasMaeLoj := cLojaMae
						cCasMaeCas := cCasoMae
						lCasoMae   := .T.
					EndIf
				EndIf

			While !(cQryRes)->(EOF())
				// NVZ_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
				If Empty(JurGetDados("NVZ", 1, xFilial("NVZ") + (cQryRes)->NVY_COD + "4" + cCodPre + cFatura + cEscr, "NVZ_CDESP")) //NVZ_FILIAL+NVZ_CDESP+NVZ_SITUAC+NVZ_PRECNF+NVZ_CFATUR+NVZ_CESCR+NVZ_CWO
					RecLock("NVZ", .T.)
					NVZ->NVZ_FILIAL  := xFilial("NVZ")
					NVZ->NVZ_CDESP   := (cQryRes)->NVY_COD
					NVZ->NVZ_SITUAC  := "4"
					NVZ->NVZ_PRECNF  := cCodPre
					NVZ->NVZ_CFATUR  := cFatura
					NVZ->NVZ_CESCR   := cEscr
					NVZ->NVZ_CANC    := "2"
					NVZ->NVZ_CODUSR  := oParams:GetCodUser()
					NVZ->NVZ_CCLIEN  := (cQryRes)->NVY_CCLIEN
					NVZ->NVZ_CLOJA   := (cQryRes)->NVY_CLOJA
					NVZ->NVZ_CCASO   := (cQryRes)->NVY_CCASO

					If lCasoMae
						NVZ->NVZ_CCLICM := cCasMaeCli
						NVZ->NVZ_CLOJCM := cCasMaeLoj
						NVZ->NVZ_CCASCM := cCasMaeCas
					EndIf

					NVZ->(MsUnlock())
					NVZ->(DbCommit())

					// Grava na fila de sincronização a alteração
					If !lRevisLD .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NVY na fila
						J170GRAVA("NVY", xFilial("NVY") + (cQryRes)->NVY_COD, "4")
					EndIf

					If lVincDspFx
						NX5->(dbSeek(xFilial('NX5') + oParams:cCodFilaImp))
						RecLock("NX5",.F.)
						NX5->NX5_DES := "1"
						NX5->(MsUnlock())
						NX5->(DbCommit())
						cTEMDP := "1"
					EndIf
				EndIf

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())

		EndIf

	EndIf

	/****************************
	// VINCULA FATURA ADICIONAL
	****************************/
	If aRet[1] .And. cTEMFA == "1"

		oParams:PtInternal(STR0137) // "Vinc Lanctos do Caso - Fatura Adicional"
		If oParams:GetTpExec() == "1"

			cQueryFA := "SELECT NVV.NVV_COD "
			cQueryFA += " FROM " + RetSqlName("NVV") + " NVV  "
			cQueryFA += " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
			cQueryFA +=   " AND NVV.NVV_SITUAC = '1' "
			cQueryFA +=   " AND NVV.NVV_COD = '" + cCodFatAd +"' "

			If !Empty(oParams:GetDIniFA()) .And. !Empty(oParams:GetDFinFA())
				cQueryFA += " AND NVV.NVV_DTBASE BETWEEN '" + DtoS(oParams:GetDIniFA()) +"' AND '" + DtoS(oParams:GetDFinFA()) +"' " 
			EndIf

			If oParams:GetSituac() == "1"
				cQueryFA += " AND NVV.NVV_CPREFT = NVV.NVV_CPREFT "
			 Else
				cQueryFA += " AND ( NVV_CPREFT = '"+ Space(TamSx3('NVV_CPREFT')[1]) + "' "
				cQueryFA += "  OR NVV_CPREFT = '" + cCodPre +"' )"
			EndIf

			cQueryFA +=     " AND NVV.D_E_L_E_T_ = ' ' "
		EndIf

		If oParams:GetTpExec() == "6" // Reemitir a pré de Fatura Cancelada
			cQueryFA := "SELECT NWD.NWD_CFTADC NVV_COD "
			cQueryFA += " FROM " + RetSqlName("NWD") + " NWD "
			cQueryFA += " WHERE	NWD.NWD_FILIAL = '" + xFilial("NWD") +"' "
			cQueryFA +=   " AND NWD.NWD_CFATUR = '" + oParams:GetCodFatur() +"' "
			cQueryFA +=   " AND NWD.NWD_CESCR	= '" + oParams:GetCodEscr() +"' "
			cQueryFA +=   " AND NWD.D_E_L_E_T_ = ' ' "
		EndIf

		If oParams:GetTpExec() == "1" .And. oParams:GetSituac() == "1" //Conferência
			// Se for conferência, insere na temporária
			cQueryFA := ChangeQuery(cQueryFA, .F.)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryFA ), cQryRes, .T., .F. )

			While !(cQryRes)->(EOF())

				RecLock("NWD", .T.)
				NWD->NWD_FILIAL := xFilial("NWD")
				NWD->NWD_CFTADC := (cQryRes)->NVV_COD
				NWD->NWD_SITUAC := "1"
				NWD->NWD_PRECNF := cCodPre
				NWD->NWD_CANC   := "2"
				NWD->NWD_CODUSR := oParams:GetCodUser()
				NWD->(MsUnlock())
				NWD->(DbCommit())

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
		EndIf

		If ( oParams:GetTpExec() $ "1|6" .And. oParams:GetSituac() <> "1" )   // Emissão de Pré-Fatura
			// Se for emissão de pré, atualiza o Lançamento com o num da Pré
			cCmd := "SELECT R_E_C_N_O_ RECNO "
			cCmd +=  " FROM " + RetSqlName("NVV") + " NVV "
			cCmd += " INNER JOIN (" + cQueryFA + ") NVV2 "
			cCmd +=    " ON NVV.NVV_COD = NVV2.NVV_COD"
			cCmd += " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
			cCmd +=   " AND NVV.D_E_L_E_T_ = ' ' "

			aSqlRet := JurSQL(cCmd, {"RECNO"})

			For nI := 1 To Len(aSqlRet)
				NVV->(DbGoto(aSqlRet[nI][1]))
				If RecLock("NVV",.F., .F., .F., .T.)
					NVV->NVV_CPREFT := cCodPre
					NVV->(MsUnlock())
					NVV->(DbCommit())
				Else
					aRet := {.F., "JA201BVinc - NVV - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
					Exit
				EndIf
			Next nI

			If (oParams:GetTpExec() $ "6") .And. aRet[1]
				cCmd := " SELECT NWD_PF.R_E_C_N_O_ RECNO "
				cCmd += " FROM " + RetSqlName("NWD") + " NWD_PF, " + RetSqlName("NWD") + " NWD_FT "
				cCmd += " WHERE NWD_PF.NWD_FILIAL = '" + xFilial("NWD") +"' "
				cCmd += " AND NWD_FT.NWD_FILIAL = '" + xFilial("NWD") +"' "
				cCmd += " AND NWD_PF.NWD_PRECNF = '" + cCodPre +"' "
				cCmd += " AND NWD_PF.NWD_CANC = '1' "
				cCmd += " AND NWD_FT.NWD_CFATUR = '" + oParams:GetCodFatur() +"' "
				cCmd += " AND NWD_FT.NWD_CESCR  = '" + oParams:GetCodEscr() +"' "
				cCmd += " AND NWD_PF.NWD_CFTADC = NWD_FT.NWD_CFTADC "
				cCmd += " AND NWD_PF.D_E_L_E_T_ = ' ' "
				cCmd += " AND NWD_FT.D_E_L_E_T_ = ' ' "

				aSqlRet := JurSQL(cCmd, {"RECNO"})

			    For nI := 1 To Len(aSqlRet)
					NWD->(DbGoto(aSqlRet[nI][1]))
					If RecLock("NWD", .F., .F., .F., .T.)
						NWD->NWD_SITUAC  := '1'
						NWD->NWD_CANC    := '2'
						NWD->(MsUnlock())
						NWD->(DbCommit())
					Else
						aRet := {.F., "JA201BVinc - NWD - Registro travado (recno: " + AllTrim(Str(aSQLRet[nI][1])) + ")"}
						Exit
					EndIf
				Next nI
			EndIf

		EndIf

		If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de pré fatura / Minuta de Fatura / Fatura

			cQueryFA := " SELECT NVV.NVV_COD "
			cQueryFA +=   " FROM " + RetSqlName("NVV") + " NVV  "
			cQueryFA +=  " WHERE NVV.NVV_FILIAL = '"+ xFilial("NVV") +"' "

			If !Empty(cCodPre)
				cQueryFA += " AND NVV.NVV_CPREFT = '" + cCodPre +"' "
				If lFatAtiva // verifica se tem faturas emitidas para essa pré-fatura
					cQueryFA += " AND NVV.NVV_SITUAC = '2' "
				Else
					cQueryFA += " AND NVV.NVV_SITUAC = '1' "
				EndIf
			Else
				cQueryFA += " AND (NVV.NVV_SITUAC = '1' OR "
				cQueryFA +=      " EXISTS ( SELECT NXG.R_E_C_N_O_ "
				cQueryFA +=                 " FROM " + RetSqlName( 'NXG' ) + " NXG "
				cQueryFA +=                " WHERE NXG.D_E_L_E_T_ = ' ' "
				cQueryFA +=                " AND NXG.NXG_FILIAL = '"+ xFilial("NXG") +"' " 
				cQueryFA +=                " AND NXG.NXG_CFATAD = NVV.NVV_COD "
				cQueryFA +=                " AND NXG.NXG_CFATUR = '"+ Space(TamSx3('NXG_CFATUR')[1]) + "' "
				cQueryFA +=                " AND NXG.NXG_CESCR  = '"+ Space(TamSx3('NXG_CESCR')[1]) + "' "
				cQueryFA +=                "  ) "
				cQueryFA +=     "  ) "
			EndIf

			cQueryFA +=     " AND NOT EXISTS (SELECT NWD.R_E_C_N_O_ "
			cQueryFA +=                       " FROM " + RetSqlName("NWD") + " NWD "
			cQueryFA +=                         " WHERE NWD.NWD_FILIAL = '" + xFilial("NWD") +"' "
			cQueryFA +=                            "AND NWD.NWD_CFTADC = NVV.NVV_COD "
			cQueryFA +=                            "AND NWD.NWD_PRECNF = NVV.NVV_CPREFT "
			cQueryFA +=                            "AND NWD.NWD_CFATUR = '" + cFatura +"' "
			cQueryFA +=                            "AND NWD.NWD_CESCR  = '" + cEscr +"' "
			cQueryFA +=                            "AND NWD.NWD_CODUSR = '" + oParams:GetCodUser() +"' "
			cQueryFA +=                            "AND NWD.NWD_CANC   = '2' "
			cQueryFA +=                            "AND NWD.D_E_L_E_T_ = ' ') "

			If !Empty(cCodFatAd)
				cQueryFA += " AND NVV.NVV_COD = '" + cCodFatAd +"' "
			EndIf
			cQueryFA +=     " AND NVV.D_E_L_E_T_ = ' ' "

			cQueryFA := ChangeQuery(cQueryFA, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryFA ), cQryRes, .T., .F. )

			While !(cQryRes)->(EOF())
				// NWD_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
				RecLock("NWD", .T.)
				NWD->NWD_FILIAL := xFilial("NWD")
				NWD->NWD_CFTADC := (cQryRes)->NVV_COD
				NWD->NWD_SITUAC := "4"
				NWD->NWD_PRECNF := cCodPre
				NWD->NWD_CFATUR := cFatura
				NWD->NWD_CESCR  := cEscr
				NWD->NWD_CANC   := "2"
				NWD->NWD_CODUSR := oParams:GetCodUser()
				NWD->(MsUnlock())
				NWD->(DbCommit())

				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())

		EndIf

	EndIf

 	RestArea(aArea)

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201TemFt()
Rotina que verifica se existem faturas geradas para a pré-fatura.

@Param  cCodPre  Fatura de Pré-fatura a ser analisada
@Param  cTipo    FT - Fatura , MF - Minuta de fatura, MP - Minuta de Pré-fatura
@Param  lWO      Fatura em situação se WO
@Param  cFixo    Fatura de Fixo à ser analisada
@Param  cFatAd   Fatura de fatura adicional à ser analisada

@return  lRet    .T. se existir faturas; .F. se não existir faturas

@author Luciano Pereira dos Santos
@since 26/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201TemFt(cCodPre, cTipo, lWO, cFixo, cFatAd)
Local lRet      := .F.
Local aArea     := GetArea()
Local aFatVald  := {}

Default cTipo   := 'FT'
Default lWO     := .T.
Default cFixo   := ''
Default cFatAd  := ''

If !Empty(cCodPre) .Or. !Empty(cFixo) .Or. !Empty(cFatAd)
	cQuery := " SELECT COUNT(NXA.R_E_C_N_O_) NXA_QTDE "
	cQuery +=  " FROM " + RetSqlname('NXA') + " NXA "
	cQuery +=       " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF "
	cQuery +=       " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
	cQuery +=            " AND NXA.NXA_COD = NUF.NUF_CFATU "
	cQuery +=            " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
	cQuery +=            " AND NUF.D_E_L_E_T_ = ' ') "
	cQuery +=       " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "

	Do Case
		Case !Empty(cCodPre)
			cQuery +=  " AND NXA.NXA_CPREFT = '" + cCodPre + "' "
		Case !Empty(cFixo)
			cQuery +=  " AND NXA.NXA_CFIXO = '" + cFixo + "' "
		Case !Empty(cFatAd)
			cQuery +=  " AND NXA.NXA_CFTADC = '" + cFatAd + "' "
	EndCase

	If lWO
		cQuery +=     " AND (NXA.NXA_SITUAC = '1' "
		cQuery +=      " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1' ) ) "  //Fatura de Wo Ativo
	Else
		cQuery +=     " AND (NXA.NXA_SITUAC = '1' ) "
	EndIf
	cQuery +=        " AND NXA.NXA_TIPO = '" + cTipo + "' "
	cQuery +=        " AND NXA.D_E_L_E_T_ = ' ' "

	aFatVald := JurSQL(cQuery, {'NXA_QTDE'})

	If aFatVald[1][1] > 0
		lRet = .T.
	EndIf
EndIf

RestArea( aArea )

Return (lRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} JA201BDtTS()
Rotina que verifica as datas para filtro do vinculo de TSs em
contratos de parcelas fixas

@Param	cCodPre   - pré-fatura a ser analisada
@Param	cCodFixo  - sequencia da parcela de fixo a ser analisada
@Param	cCodContr - Código do contrato da parcela de fixo

@return cRet      - expressao de filtro da query no campo NUE.NUE_DATATS

@author Luciano pereira dos Santos
@since 31/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Function JA201BDtTS(cCodPre, cCodFixo, cCodContr, oParams)
Local cQryNT1Dt := ""
Local cDIniH    := ""
Local cDFimH    := ""

Default cCodContr := ""
Default cCodFixo  := ""

If !Empty(oParams:GetDIniH()) .And. !Empty(oParams:GetDFinH())
	cDIniH := DTOS(oParams:GetDIniH())
	cDFimH := DTOS(oParams:GetDFinH())
EndIf

cQryNT1Dt := " AND EXISTS (SELECT NT1.R_E_C_N_O_ "
cQryNT1Dt +=               " FROM " + RetSqlName("NT1") + " NT1, "
cQryNT1Dt +=                    " " + RetSqlName("NUT") + " NUT "
cQryNT1Dt +=              " INNER JOIN " + RetSqlName("NT0") + " NT0 "
cQryNT1Dt +=                 " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
cQryNT1Dt +=                " AND NT0.NT0_COD = NUT.NUT_CCONTR "
cQryNT1Dt +=                " AND NT0.D_E_L_E_T_ = ' ' "
cQryNT1Dt +=              " INNER JOIN " + RetSqlName("NTH") + " NTH "
cQryNT1Dt +=                 " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
cQryNT1Dt +=                " AND NTH.NTH_CTPHON = NT0.NT0_CTPHON "
cQryNT1Dt +=                " AND NTH.NTH_CAMPO = 'NT0_FXABM' "
cQryNT1Dt +=                " AND NTH.D_E_L_E_T_ = ' ' "
cQryNT1Dt +=              " INNER JOIN " + RetSqlName("NVE") + " NVE "
cQryNT1Dt +=                 " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
cQryNT1Dt +=                " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
cQryNT1Dt +=                " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
cQryNT1Dt +=                " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
cQryNT1Dt +=                " AND NVE.NVE_ENCHON = '2' "
If oParams:GetSituac() <> "1" // Conferência
	cQryNT1Dt +=            " AND NVE.NVE_COBRAV = '1' "
EndIf
cQryNT1Dt +=                " AND NVE.D_E_L_E_T_ = ' ' "
cQryNT1Dt +=              " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
cQryNT1Dt +=                " AND NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
cQryNT1Dt +=                " AND NUT.NUT_CCONTR = NT1.NT1_CCONTR "
cQryNT1Dt +=                " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
cQryNT1Dt +=                " AND NUT.NUT_CLOJA = NUE.NUE_CLOJA "
cQryNT1Dt +=                " AND NUT.NUT_CCASO = NUE.NUE_CCASO "
If !Empty(cCodFixo)
	cQryNT1Dt +=            " AND NT1.NT1_SEQUEN = '" + cCodFixo + "' "
ElseIf oParams:GetSituac() == "1" // Conferência
	cQryNT1Dt +=            " AND (CASE WHEN NT1.NT1_CPREFT = '" + Space(TamSx3('NT1_CPREFT')[1]) + "' THEN '" +  cCodPre + "' ELSE NT1.NT1_CPREFT END) = '" + cCodPre + "' "
Else
	cQryNT1Dt +=            " AND NT1.NT1_CPREFT = '" + cCodPre + "' "
EndIf
If !Empty(cCodContr)
	cQryNT1Dt +=            " AND NT1.NT1_CCONTR = '" + cCodContr + "' "
EndIf
cQryNT1Dt +=                " AND NUE.NUE_DATATS >= (CASE WHEN NT1.NT1_DATAIN < '" + cDIniH + "' THEN '" + cDIniH + "' ELSE NT1.NT1_DATAIN END)"
cQryNT1Dt +=                " AND NUE.NUE_DATATS <= (CASE WHEN NT1.NT1_DATAFI > '" + cDFimH + "' THEN '" + cDFimH + "' ELSE NT1.NT1_DATAFI END)"
cQryNT1Dt +=                " AND NUT.D_E_L_E_T_ = ' ' "
cQryNT1Dt +=                " AND NT1.D_E_L_E_T_ = ' ' "
// Se não for Faixa Qtdade de Casos
cQryNT1Dt +=                " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
cQryNT1Dt +=                        " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
cQryNT1Dt +=                           " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
cQryNT1Dt +=                        " END) "
cQryNT1Dt +=                     " ELSE "
// Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
cQryNT1Dt +=                        " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
cQryNT1Dt +=                            " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
cQryNT1Dt +=                                " (CASE WHEN NT0.NT0_FXABM = '1' THEN  "
cQryNT1Dt +=                                    " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
cQryNT1Dt +=                                 " ELSE "
cQryNT1Dt +=                                     " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
cQryNT1Dt +=                                 " END) " 
cQryNT1Dt +=                             " ELSE "  
cQryNT1Dt +=                                " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
cQryNT1Dt +=                                    " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
cQryNT1Dt +=                                        " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
cQryNT1Dt +=                                     " ELSE "
cQryNT1Dt +=                                        " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
cQryNT1Dt +=                                     " END ) "
cQryNT1Dt +=                                 " ELSE "
cQryNT1Dt +=                                    " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
cQryNT1Dt +=                                        " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
cQryNT1Dt +=                                     " ELSE  "
cQryNT1Dt +=                                        " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) " 
cQryNT1Dt +=                                     " END) "
cQryNT1Dt +=                                 " END) "
cQryNT1Dt +=                             " END) "
cQryNT1Dt +=                         " END) "
cQryNT1Dt +=                      " END) <> '2' )"

Return cQryNT1Dt

//--------------------------------------------------------------------
/*/{Protheus.doc} J201BVigCtr
Função para montar filtro de data do lançamento considerando a 
vigência do contrato

@param   cDataIni , caracatere, Data inicial digitada na tela de emissão
@param   cDataFim , caracatere, Data final digitada na tela de emissão
@param   cCampo   , caracatere, Campo para filtro de data
@param   cCodContr, caracatere, Código do contrato
@Param   cTpEmiss , Tipo de Emissão
@Param   cCodPre  , Código da Pré-Fatura

@return  cQryVigCtr, caractere , Query de filtro com as datas

@author  Jonatas Martins
@since   07/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Function J201BVigCtr(cDataIni, cDataFim, cCampo, cCodContr, cTpEmiss, cCodPre)
Local cQryVigCtr  := ""
Local cDtVigi     := "'        '"
Local cDtVigf     := "'        '"
Local aContr      := {}
Local cSpaceDT    := Space(8)

Default cDataIni  := "'" + cSpaceDT + "'"
Default cDataFim  := "'" + cSpaceDT + "'"
Default cCampo    := ""
Default cCodContr := ""
Default cTpEmiss  := ""
Default cCodPre   := ""

	If cTpEmiss $ "2|5|6" .And. !Empty(cCodPre) // Refazer de Pré-Fatura, Emissão da Fatura de Pré ou Reemissão de Pré-fatura após cancelamento da fatura
		aContr := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre + cCodContr, {"NX8_DTVIGI", "NX8_DTVIGF"})
	Else
		aContr := JurGetDados("NT0", 1, xFilial("NT0") + cCodContr, {"NT0_DTVIGI", "NT0_DTVIGF"})
	EndIf

	If Len(aContr) == 2
		cDtVigi := DtoS(aContr[1])
		cDtVigf := DtoS(aContr[2])
	
		cQryVigCtr += "AND " + cCampo + " >= (CASE WHEN '" + cDtVigi + "' > '" + cSpaceDT + "' AND '" + cDtVigi + "' > '" + cDataIni + "' " 
		cQryVigCtr +=                            " THEN '" + cDtVigi + "' ELSE '" + cDataIni + "' END) "
		cQryVigCtr += "AND " + cCampo + " <= (CASE WHEN '" + cDtVigf + "' > '" + cSpaceDT + "' AND '" + cDtVigf + "' < '" + cDataFim + "' "
		cQryVigCtr +=                            " THEN '" + cDtVigf + "' ELSE '" + cDataFim + "' END) "
	EndIf

Return (cQryVigCtr)

//--------------------------------------------------------------------
/*/{Protheus.doc} J201BQDsp
Monta filtro de seleção de Despesas para vincular à Fatura

@param   cCodClien , Código do Cliente
@param   cLoja     , Loja do Cliente
@param   cCodCaso  , Código do Caso
@param   cCodContr , Código do contrato
@param   lVincDspFx, Vincula Despesa no Contrato Fixo?
@param   dDtIniDsp , Data Inicial do Filtro de Despesas no Filtro
@param   dDtFimDsp , Data Final do Filtro de Despesas no Filtro
@param   cCodPre   , Código da Pré-Fatura
@param   lVincDspFx, Vincula Despesas no Contrato Fixo
@param   dIniD     , Data Inicial do filtro de Despesa do Contrato
@param   dFimD     , Data Final do filtro de Despesa do Contrato
@param   cSituac   , Situação de Emissão

@return  cQryVigCtr, caractere , Query de filtro das despesas

@author  fabiana.silva
@since   13/12/2021
/*/
//--------------------------------------------------------------------
Function J201BQDsp(cCodClien, cLoja, cCodCaso, cCodContr, lVincDspFx, dDtIniDsp, dDtFimDsp, cCodPre, dIniD, dFimD, cSituac)
Local cQueryDP := ""

Default cCodClien  := ""
Default cLoja      := ""
Default cCodCaso   := ""
Default cCodContr  := ""
Default lVincDspFx := .F.
Default dDtIniDsp  := CtoD("")
Default dDtFimDsp  := CtoD("")
Default cCodPre    := ""
Default dIniD      := CtoD("")
Default dFimD      := CtoD("")
Default cSituac    := ""

	cQueryDP :=        " FROM " + RetSqlName("NVY") + " NVY "
	If lVincDspFx // Verifica se o contrato de fixo cobra despesa
		cQueryDP +=   " INNER JOIN " + RetSqlName("NT0") + " NT0 "
		cQueryDP +=      " ON (NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
		cQueryDP +=     " AND NT0.NT0_COD = '" + cCodContr + "' "
		cQueryDP +=     " AND NT0.NT0_DESPES = '1' "
		cQueryDP +=     " AND NT0.D_E_L_E_T_ = ' ') "
	EndIf
	cQueryDP +=       " INNER JOIN " + RetSqlName("NRH") + " NRH "
	cQueryDP +=          " ON (NRH.NRH_FILIAL = '" + xFilial("NRH") +"' "
	cQueryDP +=         " AND NRH.NRH_COD    = NVY.NVY_CTPDSP "
	cQueryDP +=         " AND NRH.NRH_COBRAR = '1' "
	cQueryDP +=         " AND NRH.D_E_L_E_T_ = ' ') "
	If cSituac <> "" .And. cSituac <> "1" // Conferencia
		cQueryDP +=   " INNER JOIN " + RetSqlName('NVE') + " NVE "
		cQueryDP +=      " ON (NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
		cQueryDP +=     " AND NVE.NVE_COBRAV = '1' "
		cQueryDP +=     " AND NVE.D_E_L_E_T_ = ' ' "
		cQueryDP +=     " AND NVE.NVE_NUMCAS = NVY.NVY_CCASO "
		cQueryDP +=     " AND NVE.NVE_CCLIEN = NVY.NVY_CCLIEN "
		cQueryDP +=     " AND NVE.NVE_LCLIEN = NVY.NVY_CLOJA) "
	EndIf
	cQueryDP +=       " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQueryDP +=         " AND NVY.NVY_CCLIEN = '" + cCodClien + "' "
	cQueryDP +=         " AND NVY.NVY_CLOJA  = '" + cLoja + "' "
	cQueryDP +=         " AND NVY.NVY_CCASO  = '" + cCodCaso + "' "
	cQueryDP +=         " AND NVY.NVY_COBRAR = '1' " 
	cQueryDP +=         " AND NVY.NVY_SITUAC = '1' " 
	cQueryDP +=         " AND NOT EXISTS (SELECT NTK.R_E_C_N_O_ "
	cQueryDP +=                           " FROM " + RetSqlName("NTK") + " NTK " 
	cQueryDP +=                          " WHERE NTK.NTK_FILIAL = '" + xFilial("NTK") + "' "
	cQueryDP +=                            " AND NTK.NTK_CCONTR = '" + cCodContr + "' "
	cQueryDP +=                            " AND NTK.NTK_CTPDSP = NVY.NVY_CTPDSP "
	cQueryDP +=                            " AND NTK.D_E_L_E_T_ = ' ') "

	If lVincDspFx
		cQueryDP +=     " AND NVY.NVY_DATA >= '" + DtoS(dDtIniDsp) + "' "
		cQueryDP +=     " AND NVY.NVY_DATA <= '" + DtoS(dDtFimDsp) + "' "
	Else
		//dIniD, dFimD
		If !Empty(dIniD) .And. !Empty(dFimD)
			cQueryDP += J201BVigCtr(DtoS(dIniD), DtoS(dFimD), "NVY.NVY_DATA", cCodContr)
		EndIf
	EndIf

	If cSituac == "1"
		cQueryDP +=     " AND NVY.NVY_CPREFT = NVY.NVY_CPREFT "
	Else
		If !Empty(cCodPre)
			cQueryDP += " AND NVY.NVY_CPREFT = '" + cCodPre + "' "
		Else
			cQueryDP += " AND NVY.NVY_CPREFT = '" + Space(TamSx3('NVY_CPREFT')[1]) + "' "
		EndIf
	EndIf
	cQueryDP +=         " AND NVY.D_E_L_E_T_ = ' ' "

Return cQueryDP