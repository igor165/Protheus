#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA200()
Rotina que recalcula o valor do Time Sheet, retornando a moeda e o valor 
dos honorários.

@Param  cCodTS    Código do Time Sheet
        cPartAlt  Código do Participante
        cClienAlt Código do Cliente
        cLojaAlt  Código do Loja
        cCasoAlt  Código do Caso
        cAMAlt    Ano mês do TS
        cTabH     Código da Tabela de Honorários
        cAtivi    Código do Tipo de Atividade

@Return aRet      Retorna array com: 
				  aRet[1] - moeda do TimeSheet;  
				  aRet[2] - Valor Hora do TimeSheet; 
				  aRet[3] - Categoria do participante;

@author Luciano Pereira dos Santos

@since 20/06/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA200(cCodTS, cPartAlt, cClienAlt, cLojaAlt, cCasoAlt, cAMAlt, cTabH, cAtivi)
Local aArea         := GetArea()
Local nValorH       := 0
Local cMoeda        := ""
Local cCliente      := ""
Local cloja         := ""
Local cCasos        := ""
Local cCat          := ""
Local cAnoMes       := ""
Local cPart2        := ""
Local nVlTemp       := 0
Local cRegra        := ""
Local cExcCat       := ""
Local nVlHnCaso     := 0
Local aRet          := {}
Local cQry1         := ""
Local cQryNUE       := GetNextAlias()
Local cQry2         := ""
Local cQryNUU       := ""
Local lOHOInDic     := .F.
Local lOHRInDic     := .F.
Local lExistOHR     := .F.
Local cTabCas       := ""

Default cPartAlt    := ""
Default cClienAlt   := ""
Default cLojaAlt    := ""
Default cCasoAlt    := ""
Default cAMAlt      := ""
Default cTabH       := ""
Default cAtivi      := ""

lOHOInDic := FWAliasInDic("OHO") .And. !Empty(cAtivi)
lOHRInDic := FWAliasInDic("OHR") .And. !Empty(cAtivi)

If !Empty(cPartAlt) .And. !Empty(cClienAlt) .And. !Empty(cLojaAlt) .And. !Empty(cCasoAlt) .And. !Empty(cAMAlt)

	// Seleciona o Time Sheet com as informações necessárias
	cQry1 := "SELECT '" + cPartAlt + "' NUE_CPART2, '" + cClienAlt + "' NUE_CCLIEN, '" + cLojaAlt + "' NUE_CLOJA, '" + cCasoAlt + "' NUE_CCASO, '" + cAMAlt + "' NUE_ANOMES, "
	If Empty(cTabH)
		cQry1 += "NUU.NUU_CTABH, NUU.NUU_TPHORA, NTU.NTU_VALORH, NTV.NTV_COD, NTV.NTV_CMOEDA, NUS.NUS_CCAT, "
	Else
		cQry1 += " '" + cTabH + "' NUU_CTABH, NUU.NUU_TPHORA, NTU.NTU_VALORH, NTV.NTV_COD, NTV.NTV_CMOEDA, NUS.NUS_CCAT, "
	EndIf
	cQry1 += "NUW.NUW_REGRA, NUW.NUW_VALOR2, NV0.NV0_REGRA, NV0.NV0_EXCCAT, NV0.NV0_VALOR2, NV0.NV0_CCAT "
	If lOHOInDic
		cQry1 += ", OHO.OHO_REGRA, OHO.OHO_VALOR "
	EndIf
	If lOHRInDic
		cQry1 += ", OHR.OHR_REGRA, OHR.OHR_VALOR "
	EndIf
	
	cQry1 += "FROM " + RetSqlName("NUS") + " NUS "   // histórico do participante
	
	cQry1 += "INNER JOIN " + RetSqlName("NTU") + " NTU "  // histórico de honorários por categoria
	cQry1 +=    "ON NTU.NTU_FILIAL = '" + xFilial("NTU") + "' "
	cQry1 +=   "AND NTU.NTU_CCAT = NUS.NUS_CCAT "
	If !Empty(cTabH)
		cQry1 +=   "AND NTU.NTU_CTAB = '" + cTabH + "' "
	EndIf
	cQry1 +=   "AND NTU.D_E_L_E_T_ = ' ' "
	
	cQry1 += "INNER JOIN " + RetSqlName("NTV") + " NTV "  // histórico da tabela de honorários
	cQry1 +=    "ON NTV.NTV_FILIAL = '" + xFilial("NTV") + "' "
	cQry1 +=   "AND NTV.NTV_COD = NTU.NTU_CHIST "
	If !Empty(cTabH)
		cQry1 +=   "AND NTV.NTV_CTAB = '" + cTabH + "' "
	EndIf
	cQry1 +=   "AND NTV.D_E_L_E_T_ = ' ' "
	
	cQry1 += "INNER JOIN " + RetSqlName("NUU") + " NUU " // histórico do caso 
	cQry1 +=    "ON NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
	cQry1 +=   "AND NUU.NUU_CCLIEN = '" + cClienAlt + "' "
	cQry1 +=   "AND NUU.NUU_CLOJA  = '" + cLojaAlt + "' "
	cQry1 +=   "AND NUU.NUU_CCASO  = '" + cCasoAlt + "' "
	If Empty(cTabH) 
		cQry1 +=   "AND NUU.NUU_CTABH = NTV.NTV_CTAB "
		cQry1 +=   "AND NUU.NUU_CTABH = NTU.NTU_CTAB "
	EndIf
	cQry1 +=   "AND NUU.D_E_L_E_T_ = ' ' "
	
	cQry1 += "LEFT JOIN " +  RetSqlName("NUW") + " NUW "  // histórico de exceção da tabela de honorários Categoria (não obrigatório)  
	cQry1 +=    "ON NUW.NUW_FILIAL = '" + xFilial("NUW") + "' "
	cQry1 +=   "AND NUW.NUW_CCLIEN = '" + cClienAlt + "' "
	cQry1 +=   "AND NUW.NUW_CLOJA  = '" + cLojaAlt + "' "
	cQry1 +=   "AND NUW.NUW_CCASO  = '" + cCasoAlt + "' "
	cQry1 +=   "AND NUW_CCAT = NUS_CCAT "
	cQry1 +=   "AND (( NUW.NUW_AMINI <= '" + cAMAlt + "' "
	cQry1 +=   "AND NUW.NUW_AMFIM = '" + Space(TamSx3('NUW_AMFIM')[1]) + "') OR "
	cQry1 +=     "( NUW.NUW_AMINI <= '" + cAMAlt + "' "
	cQry1 +=   "AND NUW.NUW_AMFIM >= '" + cAMAlt + "')) "
	cQry1 +=   "AND NUW.D_E_L_E_T_ = ' ' "
	
	cQry1  += "LEFT JOIN " +  RetSqlName("NV0") + " NV0 " // histórico de exceção da tabela de honorários Participante (não obrigatório)  
	cQry1  +=   "ON NV0.NV0_FILIAL = '" + xFilial("NV0") + "' "
	cQry1  +=  "AND NV0.NV0_CCLIEN = '" + cClienAlt + "' "
	cQry1  +=  "AND NV0.NV0_CLOJA  = '" + cLojaAlt + "' "
	cQry1  +=  "AND NV0.NV0_CCASO  = '" + cCasoAlt + "' "
	cQry1  +=  "AND NV0.NV0_CPART = '" + cPartAlt + "' "
	cQry1  +=  "AND (( NV0.NV0_AMINI <= '" + cAMAlt + "' "
	cQry1  +=  "AND NV0.NV0_AMFIM = '" + Space(TamSx3('NV0_AMFIM')[1]) + "') OR "
	cQry1  +=    "( NV0.NV0_AMINI <= '" + cAMAlt + "' "
	cQry1  +=  "AND NV0.NV0_AMFIM >= '" + cAMAlt + "' )) "
	cQry1  +=  "AND NV0.D_E_L_E_T_ = ' ' "

	If lOHOInDic
		cQry1 += "LEFT JOIN " +  RetSqlName("OHO") + " OHO " // Exceção de Valor por Tipo de Atividade no Cliente  
		cQry1  +=   "ON OHO.OHO_FILIAL = '" + xFilial("OHO") + "' "
		cQry1  +=  "AND OHO.OHO_CCLIEN = '" + cClienAlt + "' "
		cQry1  +=  "AND OHO.OHO_CLOJA  = '" + cLojaAlt + "' "
		cQry1  +=  "AND OHO.OHO_CATIVI  = '" + cAtivi + "' "
		cQry1  +=  "AND (( OHO.OHO_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHO.OHO_AMFIM = '" + Space(TamSx3('OHO_AMFIM')[1]) + "') OR "
		cQry1  +=    "( OHO.OHO_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHO.OHO_AMFIM >= '" + cAMAlt + "' )) "
		cQry1  +=  "AND OHO.D_E_L_E_T_ = ' ' "
	EndIf

	If lOHRInDic
		cQry1 += "LEFT JOIN " +  RetSqlName("OHR") + " OHR " // Exceção de Valor por Tipo de Atividade no Caso
		cQry1  +=   "ON OHR.OHR_FILIAL = '" + xFilial("OHR") + "' "
		cQry1  +=  "AND OHR.OHR_CCLIEN = '" + cClienAlt + "' "
		cQry1  +=  "AND OHR.OHR_CLOJA  = '" + cLojaAlt + "' "
		cQry1  +=  "AND OHR.OHR_CCASO  = '" + cCasoAlt + "' "
		cQry1  +=  "AND OHR.OHR_CATIVI = '" + cAtivi + "' "
		cQry1  +=  "AND (( OHR.OHR_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHR.OHR_AMFIM = '" + Space(TamSx3('OHR_AMFIM')[1]) + "') OR "
		cQry1  +=    "( OHR.OHR_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHR.OHR_AMFIM >= '" + cAMAlt + "' )) "
		cQry1  +=  "AND OHR.D_E_L_E_T_ = ' ' "
	EndIf
	
	cQry1 += "WHERE NUS.NUS_FILIAL = '" + xFilial("NUS") + "' "
	cQry1 +=   "AND (('" + cAMAlt + "' >= NUU.NUU_AMINI AND NUU.NUU_AMFIM = '" + Space(TamSx3('NUU_AMFIM')[1]) + "') OR "
	cQry1 +=        "('" + cAMAlt + "' BETWEEN NUU.NUU_AMINI AND NUU.NUU_AMFIM)) "
	cQry1 +=   "AND (('" + cAMAlt + "' >= NTV.NTV_AMINI AND NTV.NTV_AMFIM = '" + Space(TamSx3('NTV_AMFIM')[1]) + "') OR "
	cQry1 +=        "('" + cAMAlt + "' BETWEEN NTV.NTV_AMINI AND NTV.NTV_AMFIM)) "
	cQry1 +=   "AND (('" + cAMAlt + "' >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '" + Space(TamSx3('NUS_AMFIM')[1]) + "') OR "
	cQry1 +=        "('" + cAMAlt + "' BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
	cQry1 +=   "AND NUS.NUS_CPART = '" + cPartAlt + "' "
	cQry1 +=   "AND NUS.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry1 ), cQryNUE, .T., .F. )
	
	nValorH  := (cQryNUE)->NTU_VALORH
	cCliente := (cQryNUE)->NUE_CCLIEN
	cLoja    := (cQryNUE)->NUE_CLOJA
	cCasos   := (cQryNUE)->NUE_CCASO
	cCat     := (cQryNUE)->NUS_CCAT
	cAnoMes  := (cQryNUE)->NUE_ANOMES
	cPart2   := (cQryNUE)->NUE_CPART2
	If !Empty((cQryNUE)->NTV_CMOEDA)
		cMoeda  := (cQryNUE)->NTV_CMOEDA
	Else
		cTabCas := JurGetDados('NVE', 1, xFilial('NVE') + cClienAlt + cLojaAlt + cCasoAlt, 'NVE_CTABH')
		cMoeda  := JurGetDados('NRF', 1, xFilial('NRF') + cTabCas, 'NRF_MOEDA')
		aAdd(aRet, cMoeda)
		aAdd(aRet, nValorH)
		aAdd(aRet, cCat)
	EndIf

	While !(cQryNUE)->(EOF())
	
		nVlTemp := JurGetDados('NTT', 2, xFilial('NTT') + (cQryNUE)->NUU_CTABH + (cQryNUE)->NTV_COD + cPart2, 'NTT_VALORH')   // mudar indice 2 NTT_FILIAL+NTT_CTAB+NTT_CHIST+NTT_CPART
		
		If !Empty(nVlTemp) .And. nVlTemp != 0
			nValorH := nVlTemp
		EndIf
		
		If Empty(cTabH) 
		
			// Indica se existe exceção de valor por Tipo de Atividade no Caso
			lExistOHR := lOHRInDic .And. !Empty((cQryNUE)->OHR_REGRA)

			If !lExistOHR // Se não existir exceção de valor por Tipo de Atividade no Caso
				// Verifica a exceção de valor por Tipo de Atividade no Cliente
				If lOHOInDic .And. !Empty( (cQryNUE)->OHO_REGRA )
					cRegra  := (cQryNUE)->OHO_REGRA
					nVlTemp := (cQryNUE)->OHO_VALOR
					Do Case
						Case cRegra == "1" .And. nVlTemp != 0
							nValorH := nValorH + (nValorH * nVlTemp/100)
						Case cRegra == "2" .And. nVlTemp != 0
							nValorH := nValorH + nVlTemp
						Case cRegra == "3" .And. nVlTemp != 0
							nValorH := nVlTemp
					EndCase
				EndIf
			EndIf
		
			// verifica se existe exceção de honorários na tabela de Histórico do Caso
			If (cQryNUE)->NUU_TPHORA != " "
				
				cQry2  := "SELECT NUU.NUU_VLHORA "
				cQry2  +=       "FROM " + RetSqlName("NUU") + " NUU "
				cQry2  +=       "WHERE NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
				cQry2  +=         "AND NUU.NUU_CCASO  = '" + cCasos + "' "
				cQry2  +=         "AND NUU.NUU_CCLIEN = '" + cCliente + "' "
				cQry2  +=         "AND NUU.NUU_CLOJA  = '" + cloja + "' "
				cQry2  +=         "AND (( NUU.NUU_AMINI <= '"+ cAnoMes + "' "
				cQry2  +=                "AND NUU.NUU_AMFIM = '" + Space(TamSx3('NUU_AMFIM')[1])+"') OR "
				cQry2  +=                "( NUU.NUU_AMINI >='" + cAnoMes + "' "
				cQry2  +=                "AND NUU.NUU_AMFIM <='" + cAnoMes + "')) "
				cQry2  +=         "AND NUU.D_E_L_E_T_ = ' ' "
				
				cQryNUU := GetNextAlias()
				dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry2 ), cQryNUU, .T., .F. )
				
				If !(cQryNUU)->(EOF())
					nVlTemp := (cQryNUU)->NUU_VLHORA
				Else
					nVlTemp := 0
				EndIf
				
				If (cQryNUE)->NUU_TPHORA == "1"
					nValorH := nVlTemp
				ElseIf ((cQryNUE)->NUU_TPHORA == "2") .And. (nVlTemp > 0) .And. ((cQryNUE)->NTU_VALORH > nVlTemp)
					nValorH := nVlTemp
				EndIf
			
				(cQryNUU)->( dbcloseArea() )
				
			EndIf

			// verifica se existe exceção de honorários na tabela de Categoria
			If !Empty( (cQryNUE)->NUW_REGRA )
				cRegra  := (cQryNUE)->NUW_REGRA
				nVlTemp := (cQryNUE)->NUW_VALOR2
			Else
				cRegra  := " "
				nVlTemp := 0
			EndIf
			
			nVlHnCaso := nValorH // guarda o valor de honorários da tabela de Histórico do Caso
			
			Do Case
				Case cRegra == "1" .And. nVlTemp != 0
					nValorH := nValorH + (nValorH * nVlTemp/100)
				Case cRegra == "2" .And. nVlTemp != 0
					nValorH := nValorH + nVlTemp
				Case cRegra == "3" .And. nVlTemp != 0
					nValorH := nVlTemp
			EndCase
			
			// verifica se existe exceção de honorários na tabela de Participante
			If !Empty( (cQryNUE)->NV0_REGRA )
				cRegra   := (cQryNUE)->NV0_REGRA
				nVlTemp  := (cQryNUE)->NV0_VALOR2
				cExcCat  := (cQryNUE)->NV0_EXCCAT
				If !Empty((cQryNUE)->NV0_CCAT)
					cCat := (cQryNUE)->NV0_CCAT
				EndIf 
					
			Else
				cRegra  := " "
				nVlTemp := 0
				cExcCat := " "
			EndIf
			
			Do Case
				Case cRegra == "1" .And. nVlTemp != 0 .And. cExcCat == "1"
					nValorH := nValorH + (nValorH * nVlTemp/100)
				Case cRegra == "1" .And. nVlTemp != 0 .And. cExcCat == "2"
					nValorH := nVlHnCaso + (nVlHnCaso * nVlTemp/100)
				Case cRegra == "2" .And. nVlTemp != 0 .And. cExcCat == "1"
					nValorH := nValorH + nVlTemp
				Case cRegra == "2" .And. nVlTemp != 0 .And. cExcCat == "2"
					nValorH := nVlHnCaso + nVlTemp
				Case cRegra == "3" .And. nVlTemp != 0
					nValorH := nVlTemp
				Case cRegra == "4" .And. nVlTemp != 0
					nValorH := nVlTemp
			EndCase

			// Verifica a exceção de valor por Tipo de Atividade no Cliente
			If lExistOHR
				cRegra  := (cQryNUE)->OHR_REGRA
				nVlTemp := (cQryNUE)->OHR_VALOR
				Do Case
					Case cRegra == "1" .And. nVlTemp != 0
						nValorH := nValorH + (nValorH * nVlTemp/100)
					Case cRegra == "2" .And. nVlTemp != 0
						nValorH := nValorH + nVlTemp
					Case cRegra == "3" .And. nVlTemp != 0
						nValorH := nVlTemp
				EndCase
			EndIf

		EndIf
		
		aAdd(aRet, cMoeda)
		aAdd(aRet, nValorH)
		aAdd(aRet, cCat)
	
		(cQryNUE)->(dbSkip())
		
	EndDo

	(cQryNUE)->( dbcloseArea() )

EndIf
	
If Empty(aRet)
	aRet := {CriaVar("NUE_CMOEDA", .F.), 0, CriaVar("NUE_CCATEG", .F.)}
EndIf

RestArea(aArea)

Return aRet
