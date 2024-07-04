#INCLUDE "JURA201J.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JApag(oParams)
Pré-Faturamento - Apagar / Substituir pré-faturas existentes.
- Movimentar pré-faturas pendentes (situação 2,3,4) para substituir a
 pré-fatura (situação 8)

- Movimentar pré-faturas com minuta (situação 5, 6) para a
situação 7 - minuta cancelada

- Desvincular os lançamentos da pré-fatura em todos os casos

@param 		cNVVCOD   			Código da Fatura Adicional
			cNW2COD				Código da Junção de Contratos
			cNT0COD				Código do Contrato
			cNVECCLIEN			Código do Cliente
			cNVELCLIEN			Código da Loja
			cNVENUMCAS			Código do Caso

@Return 	aRet	 	  		Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Luciano Pereira dos Santos
@since 12/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201JApag(oParams, cNVVCOD, cNW2COD, cNT0COD, cNVECCLIEN, cNVELCLIEN, cNVENUMCAS, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA, cTEMLM, cCodPre, cMsg)
Local aArea       := GetArea()
Local aRet        := {.T., "JA201JApag"}
Local cQuery      := ""
Local cQrySub     := GetNextAlias()
Local cQuery2     := ""
Local cQryApg     := GetNextAlias()
Local cPreFat     := ""
Local cQryLanc    := JA201Lanc(cTEMTS, cTEMDP, cTEMLT, cTEMFX, cTEMLM)
Local cPart       := JurUsuario(__CUSERID)
Local cSituac     := ""
Local lCpoFxNc    := NX0->(ColumnPos('NX0_FXNC')) > 0 // Proteção para campo de contratos fixos ou não cobráveis 

Local lJ170GRAVA  := FindFunction("J170GRAVA") .And. (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Proteção em caso de atualização deste fonte sem os demais da integração com Legal Desk
Local lIntNX0     := lJ170GRAVA .And. SuperGetMV("MV_JREVILD", .F., '2') == '1' //Controla a integracao da revisão de pré-fatura com o Legal Desk
Local lAltDelPF   := .F. // Variavel de controle para enviar ou não a pre-fatura para a fila de sync

Default cMsg      := "JA201JApag ->"

// Seleciona as pré-faturas que serão alteradas para a situação 8 (substituicao) e situação 7 (minuta cancelada)
cQuery := " SELECT NX0.NX0_COD, NX0.R_E_C_N_O_ NRECNO, NX0.NX0_SITUAC "
cQuery +=    "FROM " + RetSqlName("NX0") +" NX0 "
cQuery +=         "INNER JOIN " + RetSqlName("NX8") + " NX8 ON (NX8.NX8_FILIAL = '" + xFilial("NX8") + "' AND "
cQuery +=                                                    "NX8.NX8_CPREFT = NX0.NX0_COD AND "
cQuery +=                                                    "NX8.D_E_L_E_T_ = ' ') "
cQuery +=         "INNER JOIN " + RetSqlName("NX1") + " NX1 ON (NX1.NX1_FILIAL = '" + xFilial("NX1") + "' AND "
cQuery +=                                                    "NX1.NX1_CPREFT = NX8.NX8_CPREFT AND "
If Empty(cNVVCOD)
	cQuery +=                                                 "NX1.NX1_CCLIEN = '" + cNVECCLIEN + "' AND "
	cQuery +=                                                 "NX1.NX1_CLOJA  = '" + cNVELCLIEN + "' AND "
	If !Empty(cNVENUMCAS)
		cQuery +=                                             "NX1.NX1_CCASO = '" + cNVENUMCAS + "' AND "
	Else
		cQuery +=                                             "NX1.NX1_CCONTR = '" + cNT0COD + "' AND "
	EndIf
EndIf
cQuery +=                                                    "NX1.D_E_L_E_T_ = ' ') "
cQuery +=   " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
cQuery +=     " AND NX0.NX0_SITUAC IN ('2','3','5')"
cQuery +=     " AND NX1.R_E_C_N_O_ IS NULL "

If !Empty(cNVVCOD)
	cQuery += " AND NX8.NX8_CFTADC = '" + cNVVCOD + "' "
Else
	cQuery += cQryLanc
EndIf

cQuery +=     " AND NX0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQrySub, .T., .F. )

BEGIN TRANSACTION

	While !(cQrySub)->(EOF())

		cPreFat := (cQrySub)->NX0_COD
		cSituac := (cQrySub)->NX0_SITUAC

		oParams:PtInternal("Erasing - 1° Sit - Pré: " + cPreFat + " Alterando para 8")

		// Altera a situação da pré-fatura
		If cSituac == "5"
			aRet := JA201JAlt("NX0", (cQrySub)->NRECNO, "NX0_SITUAC", "7", cPreFat)
		Else
			aRet := JA201JAlt("NX0", (cQrySub)->NRECNO, "NX0_SITUAC", "8", cPreFat)
			J202HIST('99', cPreFat, cPart, cMsg) //Insere o Histórico na pré-fatura
		EndIf

		//Desvincular lançamentos
		If (aRet[1])
			oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Desvinculando")
			aRet := JA201JDesv(cPreFat)
			oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NWE")
			IIF(aRet[1], aRet := JA201JCanc("NWE", cPreFat), )
			oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NW0")
			IIF(aRet[1], aRet := JA201JCanc("NW0", cPreFat), )
			oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NVZ")
			IIF(aRet[1], aRet := JA201JCanc("NVZ", cPreFat), )
			oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NW4")
			IIF(aRet[1], aRet := JA201JCanc("NW4", cPreFat), )
			oParams:PtInternal("Erasing - 1° Sit - Pré: "+cPreFat+ " Cancelando NWD")
			IIF(aRet[1], aRet := JA201JCanc("NWD", cPreFat), )
		EndIf

		If !aRet[1]
			DisarmTransaction()
			Exit
		Else

			If lJ170GRAVA .And. !lIntNX0
				//Grava na fila de sincronização a alteração de pré-fatura
				J170GRAVA("NX0", xFilial("NX0") + cPreFat, "4")
			EndIf

		EndIf

		(cQrySub)->( DbSkip() )

	EndDo

END TRANSACTION

(cQrySub)->( DbCloseArea() )

// 2a. Situacao - Seleciona as pré-faturas que serão excluídas
cQuery2 :=	" SELECT NX0.NX0_COD  "
cQuery2 +=	  "FROM "+ RetSqlName("NX0") +" NX0  "
cQuery2 +=	        "LEFT OUTER JOIN "+ RetSqlName("NXG") +" NXG ON (NXG.NXG_FILIAL = '" + xFilial("NXG") +"' AND "
cQuery2 +=	                                                        "NXG.NXG_CPREFT = NX0.NX0_COD AND "
cQuery2 +=	                                                        "NXG.NXG_CFATUR > '"+ Space(TamSx3('NXG_CFATUR')[1]) +"' AND "
cQuery2 +=	                                                        "NXG.NXG_CESCR  > '"+ Space(TamSx3('NXG_CESCR')[1]) +"' AND "
cQuery2 +=	                                                        "NXG.D_E_L_E_T_ = ' ') "
cQuery2 +=	             "INNER JOIN "+ RetSqlName("NX8") +" NX8 ON (NX8.NX8_FILIAL = '" + xFilial("NX8") +"' AND "
cQuery2 +=	                                                        "NX8.NX8_CPREFT = NX0.NX0_COD AND "
cQuery2 +=	                                                        "NX8.D_E_L_E_T_ = ' ')"
cQuery2 +=               "INNER JOIN "+ RetSqlName("NX1") +" NX1 ON (NX1.NX1_FILIAL = '" + xFilial("NX1") +"' AND "
cQuery2 +=	                                                          "NX1.NX1_CPREFT = NX8.NX8_CPREFT AND "
If Empty(cNVVCOD)
	If cTEMFX == "2"
		cQuery2 +=                                                    "NX1.NX1_CCLIEN = '" + cNVECCLIEN +"' AND "
		cQuery2 +=                                                    "NX1.NX1_CLOJA  = '" + cNVELCLIEN +"' AND "
		If !Empty(cNVENUMCAS)
			cQuery2 +=                                                 "NX1.NX1_CCASO = '" + cNVENUMCAS +"' AND "
		EndIf
	EndIf
	If !Empty(cNT0COD)
		cQuery2 +=                                                    "NX1.NX1_CCONTR =  NX8.NX8_CCONTR AND "
		cQuery2 +=                                                    "NX1.NX1_CCONTR = '" + cNT0COD +"' AND "
	EndIf
EndIf
cQuery2 +=                                                           "NX1.D_E_L_E_T_ = ' ') "
cQuery2 += " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
If oParams:GetChkApaga() .And. oParams:GetSituac() != '1'
	If oParams:GetChkApaMP()
		cQuery2 +=  " AND NX0.NX0_SITUAC IN ('1', '2', '3', '5', '6', '7', '9', 'A', 'B') "
	Else
		cQuery2 +=  " AND NX0.NX0_SITUAC IN ('1', '2', '3') "
	EndIf
Else
	cQuery2 +=  " AND NX0.NX0_SITUAC = '1' "
EndIf

cQuery2 +=     " AND NXG.R_E_C_N_O_ IS NULL "

If !Empty(cNVVCOD)
	cQuery2 += " AND NX8.NX8_CFTADC = '" + cNVVCOD +"' "
Else
	cQuery2 += cQryLanc
EndIf

If (cTEMTS == "1" .Or. cTEMDP == "1" .Or. cTEMLT == "1" .Or. cTEMFX  == "1")
	cQuery2 +=    " " + J201JFilDt(oParams, "ALL") + " " // Não apagar pré-faturas com períodos de emissão distintos
EndIf

cQuery2 +=    " AND NX0.D_E_L_E_T_ = ' ' "

If lCpoFxNc
	If oParams:GetFltrFxNc() // Indica se é uma emissão de pré de TSs de contratos fixos ou não cobráveis
		cQuery2 += " AND NX0.NX0_FXNC = '1' "
	Else // NÃO é uma emissão de TS de contrato fixo ou não cobrável
		cQuery2 += " AND NX0.NX0_FXNC = '2' "
	EndIf
EndIf

cQuery2 += " UNION"

cQuery2 += " SELECT NUE.NUE_CPREFT   "
cQuery2 +=    "FROM "+ RetSqlName("NUE") +" NUE "
cQuery2 +=        "LEFT OUTER JOIN "+ RetSqlName("NX0") +" NX0 ON (NX0.NX0_FILIAL = '" + xFilial("NX0") +"' AND "
cQuery2 +=                                                        "NX0.NX0_COD    = NUE.NUE_CPREFT AND "
cQuery2 +=                                                        "NX0.NX0_SITUAC IN ('2', '3', '4', '5', '6', '7','9','A','B','C','D','E','F') AND "
cQuery2 +=                                                        "NX0.D_E_L_E_T_ = ' ') "
cQuery2 += " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
cQuery2 +=    "AND NUE.NUE_CPREFT > '"+ Space(TamSx3('NUE_CPREFT')[1]) +"' "
cQuery2 +=    "AND NUE.NUE_CPREFT <> '" + cCodPre +"' "
cQuery2 +=    "AND NUE.NUE_CCLIEN = '" + cNVECCLIEN +"' "
cQuery2 +=    "AND NUE.NUE_CLOJA  = '" + cNVELCLIEN +"' "
cQuery2 +=    "AND NUE.NUE_CCASO  = '" + cNVENUMCAS +"' "
cQuery2 +=    " " + J201JFilDt(oParams, "TS") + " " // Não apagar pré-faturas com períodos de emissão distintos
cQuery2 +=    "AND NX0.R_E_C_N_O_ IS NULL "
cQuery2 +=    "AND NUE.D_E_L_E_T_ = ' ' "

cQuery2 += " UNION"

cQuery2 += " SELECT NVY.NVY_CPREFT   "
cQuery2 += " FROM "+ RetSqlName("NVY") +" NVY "
cQuery2 +=      "LEFT OUTER JOIN "+ RetSqlName("NX0") +" NX0 ON (NX0.NX0_FILIAL = '" + xFilial("NX0") +"' AND "
cQuery2 +=                                                    "NX0.NX0_COD = NVY.NVY_CPREFT AND "
cQuery2 +=                                                    "NX0.NX0_SITUAC IN ('2', '3', '4', '5', '6', '7','9','A','B','C','D','E','F') AND "
cQuery2 +=                                                    "NX0.D_E_L_E_T_ = ' ') "
cQuery2 += " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") +"'  "
cQuery2 +=   " AND NVY.NVY_CPREFT > '"+ Space(TamSx3('NVY_CPREFT')[1]) +"' "
cQuery2 +=   " AND NVY.NVY_CPREFT <> '" + cCodPre +"' "
cQuery2 +=   " AND NVY.NVY_CCLIEN = '" + cNVECCLIEN +"' "
cQuery2 +=   " AND NVY.NVY_CLOJA = '" + cNVELCLIEN +"' "
cQuery2 +=   " AND NVY.NVY_CCASO = '" + cNVENUMCAS +"' "
cQuery2 +=   " "+J201JFilDt(oParams, "DP")+" " // Não apagar pré-faturas com períodos de emissão distintos
cQuery2 +=   " AND NX0.R_E_C_N_O_ IS NULL "
cQuery2 +=   " AND NVY.D_E_L_E_T_	= ' ' "

cQuery2 += " UNION "

cQuery2 += " SELECT NV4.NV4_CPREFT "
cQuery2 +=    "FROM "+ RetSqlName("NV4") +" NV4 "
cQuery2 +=         "LEFT OUTER JOIN "+ RetSqlName("NX0") +" NX0 ON (NX0.NX0_FILIAL = '" + xFilial("NX0") +"' AND "
cQuery2 +=                                                         "NX0.NX0_COD = NV4.NV4_CPREFT AND "
cQuery2 +=                                                         "NX0.NX0_SITUAC IN ('2', '3', '4', '5', '6', '7','9','A','B','C','D','E','F') AND "
cQuery2 +=                                                         "NX0.D_E_L_E_T_ = ' ') "
cQuery2 += " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") +"' "
cQuery2 +=    "AND NV4.NV4_CPREFT > '"+ Space(TamSx3('NV4_CPREFT')[1]) +"' "
cQuery2 +=    "AND NV4.NV4_CPREFT <> '" + cCodPre +"' "
cQuery2 +=    "AND NV4.NV4_CCLIEN = '" + cNVECCLIEN +"' "
cQuery2 +=    "AND NV4.NV4_CLOJA = '" + cNVELCLIEN +"' "
cQuery2 +=    "AND NV4.NV4_CCASO = '" + cNVENUMCAS +"' "
cQuery2 +=    " " + J201JFilDt(oParams, "TB") + " " // Não trazer pré-faturas com períodos de emissão distintos
cQuery2 +=    "AND NX0.R_E_C_N_O_ IS NULL "
cQuery2 +=    "AND NV4.D_E_L_E_T_ = ' ' "

cQuery2 += " UNION "

cQuery2 += " SELECT NT1.NT1_CPREFT "
cQuery2 +=    "FROM "+ RetSqlName("NT1") +" NT1  "
cQuery2 +=         "LEFT OUTER JOIN "+ RetSqlName("NX0") +" NX0 ON (NX0.NX0_FILIAL = '" + xFilial("NX0") +"' AND "
cQuery2 +=                                                         "NX0.NX0_COD = NT1.NT1_CPREFT AND "
cQuery2 +=                                                         "NX0.NX0_SITUAC IN ('2', '3', '4', '5', '6', '7','9','A','B','C','D','E','F') AND "
cQuery2 +=                                                          "NX0.D_E_L_E_T_ = ' ') "
cQuery2 += " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
cQuery2 +=    "AND NT1.NT1_CPREFT > '"+ Space(TamSx3('NT1_CPREFT')[1]) +"' "
cQuery2 +=    "AND NT1.NT1_CPREFT <> '" + cCodPre +"' "
cQuery2 +=    "AND NT1.NT1_CCONTR = '" + cNT0COD +"' "
cQuery2 +=    " " + J201JFilDt(oParams, "FX") + " " // Não apagar pré-faturas com períodos de emissão distintos
cQuery2 +=    "AND NX0.R_E_C_N_O_ IS NULL "
cQuery2 +=    "AND NT1.D_E_L_E_T_ = ' ' "

cQuery2 +=	" UNION "

cQuery2 += " SELECT NVV.NVV_CPREFT   "
cQuery2 += "   FROM "+ RetSqlName("NVV") +" NVV "
cQuery2 +=         "LEFT OUTER JOIN "+ RetSqlName("NX0") +" NX0 ON (NX0.NX0_FILIAL = '" + xFilial("NX0") +"' AND "
cQuery2 +=                                                         "NX0.NX0_COD = NVV.NVV_CPREFT AND "
cQuery2 +=                                                         "NX0.NX0_SITUAC IN ('2', '3', '4', '5', '6', '7','9','A','B','C','D','E','F') AND "
cQuery2 +=                                                         "NX0.D_E_L_E_T_ = ' ') "
cQuery2 += " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
cQuery2 +=    "AND NVV.NVV_CPREFT > '"+ Space(TamSx3('NT1_CPREFT')[1]) +"' "
cQuery2 +=    "AND NVV.NVV_CPREFT <> '" + cCodPre +"' "
cQuery2 +=    "AND NVV.NVV_COD = '" + cNVVCOD +"' "
cQuery2 +=    " " + J201JFilDt(oParams, "FA") + " " // Não apagar pré-faturas com períodos de emissão distintos
cQuery2 +=    "AND NX0.R_E_C_N_O_ IS NULL "
cQuery2 +=    "AND NVV.D_E_L_E_T_ = ' ' "

cQuery2 := ChangeQuery(cQuery2, .F.)
DbCommitAll()
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery2 ), cQryApg, .T., .F. )

BEGIN TRANSACTION

	While !(cQryApg)->(EOF())

		cPreFat := (cQryApg)->NX0_COD
		oParams:PtInternal("Erasing - 2° Sit - Pré: " + cPreFat)

		//Verifica se não é PF em conferência, para enviar para a fila de sync
		lAltDelPF := !(Posicione('NX0', 1, xFilial('NX0') + cPrefat, 'NX0_SITUAC') == '1')

		//Desvincular lançamentos
		If (aRet[1])
			oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Desvinculando")
			aRet := JA201JDesv(cPreFat)
			oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NWE")
			IIF(aRet[1], aRet := JA201JCanc("NWE", cPreFat), )
			oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NW0")
			IIF(aRet[1], aRet := JA201JCanc("NW0", cPreFat), )
			oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NVZ")
			IIF(aRet[1], aRet := JA201JCanc("NVZ", cPreFat), )
			oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NW4")
			IIF(aRet[1], aRet := JA201JCanc("NW4", cPreFat), )
			oParams:PtInternal("Erasing - 2° Sit - Pré: "+cPreFat+ " Cancelando NWD")
			IIF(aRet[1], aRet := JA201JCanc("NWD", cPreFat), )
		EndIf

		//Apaga itens da tabela de pagadores da pré-faturas
		If (aRet[1])
			aRet := JA201JSubC("NXG", cPreFat)
		EndIf

		//Cancela/Substitui itens da tabela de pré-faturas
		If (aRet[1])
			aRet := JA201JSubC("NX0", cPreFat)
		EndIf

		If (aRet[1]) .And. oParams:GetChkApaga() .And. oParams:GetChkApaMP()
			If J202CanMin( cPreFat, STR0005 ) //"Cancelamento de minuta"
				aRet := {.T., "J202CanMin"}
			Else
				aRet := {.F., "J202CanMin"}
			EndIf
		EndIf

		If !aRet[1]
			DisarmTransaction()
			Exit
		Else
			If lJ170GRAVA .And. lAltDelPF
				//Grava na fila de sincronização a exclusão de pré-fatura
				J170GRAVA("NX0", xFilial("NX0") + cPreFat, "5")
				J170GRAVA("JURA202E", xFilial("NX0") + cPreFat, "5")
			EndIf

		EndIf

		(cQryApg)->( DbSkip() )
	EndDo

END TRANSACTION

(cQryApg)->( DbCloseArea() )

RestArea( aArea )

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JDesv(cPreFat)
Desvincula lançamentos da Pré-Fatura

@param   cPreFat código da pré-fatura

@Return  aRet    Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Luciano Pereira dos Santos
@since 08/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201JDesv(cPreFat)
Local aRet      := {.T., "JA201JDesv"}
Local cQuery    := ""
Local aArea     := GetArea()
Local cQryRes   := GetNextAlias()

// Desvincular Time Sheet
If (aRet[1])
	cQuery := " SELECT NUE.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NUE") + " NUE "
	cQuery +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=    " AND NUE.NUE_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NUE.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NUE", (cQryRes)->NRECNO, "NUE_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Despesas
If (aRet[1])
	cQuery := " SELECT NVY.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NVY") + " NVY "
	cQuery +=  " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=    " AND NVY.NVY_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NVY.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NVY", (cQryRes)->NRECNO, "NVY_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Lançamento Tabelado
If (aRet[1])
	cQuery := " SELECT NV4.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NV4") + " NV4 "
	cQuery +=  " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery +=    " AND NV4.NV4_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NV4.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
 	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->(Eof() ) )
		aRet := JA201JAlt("NV4", (cQryRes)->NRECNO, "NV4_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Parcelas de Fixo
If (aRet[1])
	cQuery := " SELECT NT1.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NT1") + " NT1 "
	cQuery +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
	cQuery +=    " AND NT1.NT1_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NT1.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
 	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NT1", (cQryRes)->NRECNO, "NT1_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

// Desvincular Fatura Adicional
If (aRet[1])
	cQuery := " SELECT NVV.R_E_C_N_O_ NRECNO "
	cQuery +=   " FROM " + RetSqlName("NVV") + " NVV "
	cQuery +=  " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
	cQuery +=    " AND NVV.NVV_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NVV.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While aRet[1] .AND. !( (cQryRes)->( Eof() ) )
		aRet := JA201JAlt("NVV", (cQryRes)->NRECNO, "NVV_CPREFT", "", cPreFat)
		(cQryRes)->(dbskip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

RestArea( aArea )

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JAlt(cAlias,nRecno,cCampo,uValor)
Função genérica para alterar em lote o valor de um campo
Utilizado para alterar a situação da pré-fatura (substituir)

@Params		cAlias		Alias da Tabela.
	   		nRecno		Recno da Tabela as ser alterada.
			cCampo     	Campo para ser alterado
			uValor		Informação para ser gravada no campo

@Return 	aRet    	Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Luciano Pereira dos Santos
@since 08/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201JAlt(cAliasTb, nRecno, cCampo, uValor, cCodPre)
Local aArea     := GetArea()
Local aAreaA    := (cAliasTb)->(GetArea())
Local aRet      := {.T., "JA201JAlt"}
Local cErro     := ""

DbSelectArea(cAliasTb)
(cAliasTb)->(DbGoTo(nRecno))
If RecLock( cAliasTb , .F., .F., .F., .T.)
	(cAliasTb)->&(cCampo) := uValor
	(cAliasTb)->( DbCommit())
	(cAliasTb)->( MsUnlock())
	(cAliasTb)->( DbSkip() )
Else
	cErro := STR0001 + cCodPre + "! " //"Erro ao apagar a pré-fatura "
	cErro += STR0002 + alltrim(Str(nRecno)) + STR0003 + cAliasTb + " ("+ JurX2Nome(cAliasTb) +")"+ STR0004  //"O registro "## " da tabela " ### esta sendo usado por outro usuário!
	aRet := {.F., cErro }
EndIf

RestArea( aAreaA )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201Lanc(cTEMTS, cTEMDP, cTEMLT, cTEMFX, cTEMLM)
Função para concatenar as flags de lançamento e devolver um filtro para
as querys da função JA201JApag.

@Params		cTEMTS		Desvincula Time Sheet?    : 1 - Sim; 2 - Não.
	   		cTEMDP		Desvincula Despesa?       : 1 - Sim; 2 - Não.
			cTEMLT     	Desvincula Lanc. Tab.     : 1 - Sim; 2 - Não.
			cTEMFX		Desvincula Fixo 	      : 1 - Sim; 2 - Não.
			cTEMLM		Desvincula Saldo de Limte : 1 - Sim; 2 - Não.

@Return 	cRet    	filtro sql para condição de existência das querys de
						desvinculo da lançamentos.

@author Luciano Pereira dos Santos
@since 08/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201Lanc(cTEMTS, cTEMDP, cTEMLT, cTEMFX, cTEMLM)
Local cRet := " AND ( "

If cTEMTS == "1"
	cRet += " NX1.NX1_TS = '1' OR "
EndIf

If cTEMDP == "1"
	cRet += " NX1.NX1_DESP = '1' OR "
EndIf

If cTEMLT == "1"
	cRet += " NX1.NX1_LANTAB = '1' OR "
EndIf

If cTEMFX == "1"
	cRet += " NX8.NX8_FIXO = '1' OR "
EndIf

If cTEMLM == "1"
	cRet +=  " (NX1.NX1_VTSVIN = 0 AND NX1.NX1_VTS > 0) OR "  
EndIf

If cRet == " AND ( "
	cRet := " "
Else
	cRet := SubStr( cRet, 1, Len( cRet ) - 3 ) + " ) "
EndIf

Return cRet

Static Function JA201JCanc(cTabela, cCodPre)
Local aRet      := {.T., "JA201JCanc"}
Local aArea     := GetArea()
Local aAreaA    := (cTabela)->(GetArea())
Local cQry      := ""
Local aQry      := {}
Local nI        := 0
Local cErro     := ""

	cQry += " SELECT R_E_C_N_O_"
	cQry +=   " FROM " + RetSqlName(cTabela) + "  "
	cQry +=  " WHERE D_E_L_E_T_ = ' ' "
	cQry +=    " AND " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' "
	cQry +=    " AND " + cTabela + "_PRECNF = '" + cCodPre + "'"
	cQry +=    " AND " + cTabela + "_CANC = '2' "

	aQry := JurSQL(cQry, "R_E_C_N_O_")

	If !Empty(aQry)
		For nI := 1 To Len(aQry)

			(cTabela)->( DBGoTo(aQry[nI][1]) )

			If RecLock(cTabela,.F., .F., .F., .T.)
				(cTabela)->&(cTabela+"_CANC") := "1"
				(cTabela)->(MsUnLock())
				(cTabela)->(DbCommit())
			Else
				cErro := STR0001 + cCodPre + "! " //"Erro ao apagar a pré-fatura "
				cErro += STR0002 + alltrim(Str(aQry[nI][1])) + STR0003 + cTabela + " (" + JurX2Nome(cTabela) + ")" + STR0004 //"O registro "## " da tabela " ### esta sendo usado por outro usuário!
				aRet := {.F., cErro }
				Exit
			EndIf

		Next nI
	EndIf

RestArea( aAreaA )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201JFilDt
Função para retornar um String sql para tabela NX0 contendo o filtro para impedir
a exclusão de pré-faturas do mesmo contrato ou cliente, loja e caso emitidas
usando intervalo de periodos distintos.

@Param   oParams  - Objeto contendo os metodos para recuperar os periodos
                    dos lançamentos da tela de emissão de pré-fatura
@Param   cLanc    - Tipo de lançamento: TS, TB, DP, FX ou ALL (todos)

@Return  cFilRet    String sql para tabela NX0 contendo o filtro.

@author Luciano Pereira dos Santos
@since  08/09/12
/*/
//-------------------------------------------------------------------
Static Function J201JFilDt(oParams, cLanc)
Local cDtIniHO   := DtoS(oParams:GetDIniH())
Local cDtFinHO   := DtoS(oParams:GetDFinH())
Local cDtIniDP   := DtoS(oParams:GetDIniD())
Local cDtFinDP   := DtoS(oParams:GetDFinD())
Local cDtIniTB   := DtoS(oParams:GetDIniT())
Local cDtFinTB   := DtoS(oParams:GetDFinT())
Local cDtIniFA   := DtoS(oParams:GetDIniFA())
Local cDtFinFA   := DtoS(oParams:GetDFinFA())
Local dDtIniFXNC := oParams:GetDIniFxNc()
Local dDtFinFXNC := oParams:GetDFinFxNc()
Local cDtIniFXNC := IIF(Type('dDtIniFXNC') == "U", "", DtoS(dDtIniFXNC)) // Protege por conta da automação. CTs antigos não fazem o SetDIniFxNc
Local cDtFinFXNC := IIF(Type('dDtFinFXNC') == "U", "", DtoS(dDtFinFXNC)) // Protege por conta da automação. CTs antigos não fazem o SetDFinFxNc
Local cQuery     := " "

Default cLanc   := "ALL"

If oParams:GetSituac() != '1'

	If !Empty(cDtFinHO) .And. !Empty(cDtFinHO)
		If cLanc == "ALL"  // Query da tabela NX0 - pré-faturas que estão no periodo
			cQuery += " AND ( ('" + cDtIniHO + "' <= NX0.NX0_DINITS AND NX0.NX0_DINITS <= '" + cDtFinHO + "') OR "
			cQuery +=       " ('" + cDtIniHO + "' <= NX0.NX0_DFIMTS AND NX0.NX0_DFIMTS <= '" + cDtFinHO + "') OR "
			cQuery +=       " ('" + cDtIniHO + "' >= NX0.NX0_DINITS AND NX0.NX0_DFIMTS >= '" + cDtIniHO + "') OR "
			cQuery +=       " ('" + cDtFinHO + "' >= NX0.NX0_DINITS AND NX0.NX0_DFIMTS >= '" + cDtFinHO + "') OR "
			cQuery +=       " (NX0.NX0_DINITS = '" + Space(TamSx3('NX0_DINITS')[1]) + "' AND NX0.NX0_DFIMTS = '" + Space(TamSx3('NX0_DFIMTS')[1]) + "') ) "
		ElseIf cLanc == "TS" // Query do left outer join da tabela NX0 e Time Sheet que estão no periodo
			cQuery += " AND NUE.NUE_DATATS >= '" + cDtIniHO + "' AND NUE.NUE_DATATS <= '" + cDtFinHO + "' "
		EndIf
	EndIf

	If !Empty(cDtIniDP) .And. !Empty(cDtFinDP)
		If cLanc == "ALL"  // Query da tabela NX0 - pré-faturas que estão no periodo
			cQuery += " AND ( ('" + cDtIniDP + "' <= NX0.NX0_DINIDP AND NX0.NX0_DINIDP <= '" + cDtFinDP + "') OR "
			cQuery +=       " ('" + cDtIniDP + "' <= NX0.NX0_DFIMDP AND NX0.NX0_DFIMDP <= '" + cDtFinDP + "') OR "
			cQuery +=       " ('" + cDtIniDP + "' >= NX0.NX0_DINIDP AND NX0.NX0_DFIMDP >= '" + cDtIniDP + "') OR "
			cQuery +=       " ('" + cDtFinDP + "' >= NX0.NX0_DINIDP AND NX0.NX0_DFIMDP >= '" + cDtFinDP + "') OR "
			cQuery +=       " (NX0.NX0_DINIDP = '" + Space(TamSx3('NX0_DINIDP')[1]) + "' AND NX0.NX0_DFIMDP = '" + Space(TamSx3('NX0_DFIMDP')[1]) + "') ) "
		ElseIf cLanc == "DP" // Query do left outer join da tabela NVY e Despesas que estão no periodo
			cQuery += " AND NVY.NVY_DATA >= '" + cDtIniDP + "' AND NVY.NVY_DATA <= '" + cDtFinDP + "' "
		EndIf
	EndIf

	If !Empty(cDtIniTB) .And. !Empty(cDtFinTB)
		If cLanc == "ALL" // Query da tabela NX0 - pré-faturas que estão no periodo
			cQuery += " AND ( ('" + cDtIniTB + "' <= NX0.NX0_DINITB AND NX0.NX0_DINITB <= '" + cDtFinTB + "') OR "
			cQuery +=       " ('" + cDtIniTB + "' <= NX0.NX0_DFIMTB AND NX0.NX0_DFIMTB <= '" + cDtFinTB + "') OR "
			cQuery +=       " ('" + cDtIniTB + "' >= NX0.NX0_DINITB AND NX0.NX0_DFIMTB >= '" + cDtIniTB + "') OR "
			cQuery +=       " ('" + cDtFinTB + "' >= NX0.NX0_DINITB AND NX0.NX0_DFIMTB >= '" + cDtFinTB + "') OR "
			cQuery +=       " (NX0.NX0_DINITB = '" + Space(TamSx3('NX0_DINITB')[1]) + "' AND NX0.NX0_DFIMTB = '" + Space(TamSx3('NX0_DFIMTB')[1]) + "') ) "
		ElseIf cLanc == "TB" // Query do left outer join da tabela NV4 e Tabeldos que estão no periodo
			cQuery += " AND NV4.NV4_DTCONC >= '" + cDtIniTB + "' AND NV4.NV4_DTCONC <= '" + cDtFinTB + "' "
		EndIf
	EndIf

	If !Empty(cDtFinHO) .And. !Empty(cDtFinHO) .And. oParams:GetFltrHO()
		If cLanc == "ALL" // Query da tabela NX0 - pré-faturas que estão no periodo
			cQuery += " AND ( ('" + cDtIniHO + "' <= NX0.NX0_DINIFX AND NX0.NX0_DINIFX <= '" + cDtFinHO + "') OR "
			cQuery +=       " ('" + cDtIniHO + "' <= NX0.NX0_DFIMFX AND NX0.NX0_DFIMFX <= '" + cDtFinHO + "') OR "
			cQuery +=       " ('" + cDtIniHO + "' >= NX0.NX0_DINIFX AND NX0.NX0_DFIMFX >= '" + cDtIniHO + "') OR "
			cQuery +=       " ('" + cDtFinHO + "' >= NX0.NX0_DINIFX AND NX0.NX0_DFIMFX >= '" + cDtFinHO + "') OR "
			cQuery +=       " (NX0.NX0_DINIFX = '" + Space(TamSx3('NX0_DINIFX')[1]) + "' AND NX0.NX0_DFIMFX = '" + Space(TamSx3('NX0_DFIMFX')[1]) + "') ) "
		ElseIf cLanc == "FX" // Query do left outer join da NT1 Fixos que estão no periodo
			cQuery += " AND NT1.NT1_DATAFI >= '" + cDtIniHO + "' AND NT1.NT1_DATAFI <= '" + cDtFinHO + "' "
		EndIf
	EndIf

	If !Empty(cDtIniFA) .And. !Empty(cDtFinFA) .And. cLanc == "FA" // Query do outer join da NVV Faturas adicionais que estão no periodo
		cQuery += " AND NVV.NVV_DTBASE >= '" + cDtIniFA + "' AND NVV.NVV_DTBASE <= '" + cDtFinFA + "' "
	EndIf

	If !Empty(cDtIniFXNC) .And. !Empty(cDtFinFXNC)
		If cLanc == "ALL"  // Query da tabela NX0 - pré-faturas que estão no periodo
			cQuery += " AND ( ('" + cDtIniFXNC + "' <= NX0.NX0_DIFXNC AND NX0.NX0_DIFXNC <= '" + cDtFinFXNC + "') OR "
			cQuery +=       " ('" + cDtIniFXNC + "' <= NX0.NX0_DFFXNC AND NX0.NX0_DFFXNC <= '" + cDtFinFXNC + "') OR "
			cQuery +=       " ('" + cDtIniFXNC + "' >= NX0.NX0_DIFXNC AND NX0.NX0_DFFXNC >= '" + cDtIniFXNC + "') OR "
			cQuery +=       " ('" + cDtFinFXNC + "' >= NX0.NX0_DIFXNC AND NX0.NX0_DFFXNC >= '" + cDtFinFXNC + "') OR "
			cQuery +=       " (NX0.NX0_DIFXNC = '" + Space(TamSx3('NX0_DIFXNC')[1]) + "' AND NX0.NX0_DFFXNC = '" + Space(TamSx3('NX0_DFFXNC')[1]) + "') ) "
		ElseIf cLanc == "TS" // Query do left outer join da tabela NX0 e Time Sheet que estão no periodo
			cQuery += " AND NUE.NUE_DATATS >= '" + cDtIniFXNC + "' AND NUE.NUE_DATATS <= '" + cDtFinFXNC + "' "
		EndIf
	EndIf

EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201JSubC()
Função para alterar a situação 8-'Substituir/Cancelar' das pré-faturas existentes
e também desvincular o pagador da pré-fatura quando for uma pré-fatura de Fatura
Adicional.

@Params cAlias  Alias da Tabela.
@Params cPreFat Código da Pré-Fatura.

@Return aRet    Execução realizada com sucesso?  [1] - .T. / .F.  [2] - Mensagem de erro

@author Anderson Carvalho\ Queizy Nascimento
@since 30/11/2018
/*/
//-------------------------------------------------------------------
Static Function JA201JSubC(cAliasTb, cPreFat)
	Local aArea     := GetArea()
	Local aAreaA    := (cAliasTb)->(GetArea())
	Local aRet      := {.T., "JA201JSubC"}
	Local aQry      := ""
	Local cQry      := ""
	Local cErro     := ""
	Local nI        := 0

	cQry += " SELECT R_E_C_N_O_"
	cQry +=   " FROM " + RetSqlName(cAliasTb)
	cQry +=  " WHERE D_E_L_E_T_ = ' ' "
	cQry +=    " AND " + cAliasTb + "_FILIAL = '" + xFilial(cAliasTb) + "' "
	If (cAliasTb == "NXG")
		cQry += " AND NXG_CPREFT = '" + cPreFat + "'"
	Else
		cQry += " AND NX0_COD = '" + cPreFat + "'"
	EndIf
	aQry := JurSQL(cQry, "R_E_C_N_O_")

	If !Empty(aQry)
		For nI := 1 To Len(aQry)

			(cAliasTb)->(DBGoTo(aQry[nI][1]))
			If RecLock((cAliasTb),.F., .F., .F., .T.)
				If cAliasTb == "NXG" .And. !Empty((cAliasTb)->NXG_CFATAD)
					NXG->NXG_CPREFT := ""
				ElseIf cAliasTb == "NX0"
					NX0->NX0_SITUAC := "8"
				EndIf
				(cAliasTb)->(DbCommit())
				(cAliasTb)->(MsUnlock())
			Else
				cErro += STR0002 + Alltrim(Str((cAliasTb)->(Recno()))) + STR0003 + cAliasTb + " (" + JurX2Nome(cAliasTb) + ")" + STR0004  //"O registro "## " da tabela " ### esta sendo usado por outro usuário!
				aRet := {.F., cErro}
				Exit
			EndIf
		Next nI
	EndIf

	(cAliasTb)->(DbCloseArea())

	RestArea(aArea)
	RestArea(aAreaA)

	JurFreeArr(@aQry)

Return (aRet)
