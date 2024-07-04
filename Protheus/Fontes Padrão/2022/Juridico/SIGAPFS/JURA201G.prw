#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA201G
Rotina para calcular o saldo disponivel para os limites por fatura
e geral

@Param    cTipoSld    - Tipo de saldo a calcular: 1 - Limite por Fatura, 2 - Limite Geral
@Param    cMoeLmCntr  - Moeda do limite do contrato
@Param    cCodFilaImp - Cod da Fila de emissao de fatura
@Param    cCodContr   - Cod do Contrato
@Param    cTpExec     - Tipo de execução de emissão
@Param    dDtCotac    - data da cotação
@Param    cCodPre     - codigo da pre-fatura
@Param    lApagaPre   - .T. que as pre-faturas serão apagadas e o seu saldo não deve ser considerado
@Param    lApagaMin   - .T. que as minutas serão apagadas e o seu saldo não deve ser considerado
@Param    cTipo       - Tipo de retonro: Se '1' retorna o valor Utilizado, '2' retorna o valor Diponível (somente para Limite Geral)
@Param    nSldAcuPre  - Saldo acumulado de pré-faturas e faturas anteriores (Valor excedido de TS)

@Return   nRet		  - Valor do saldo

@author Daniel Magalhaes
@since 28/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA201G( cTipoSld, cMoeLmCntr, cCodFilaImp, cCodContr, cTpExec, dDtCotac, cCodPre, lApagaPre, lApagaMin, cTipo, nSldAcuPre)
Local cQuery        := ""
Local nValFat       := 0
Local nValPre       := 0
Local nI            := 0
Local lNX8VLRLIF    := NX8->(ColumnPos("NX8_VLRLIF")) > 0 // Proteção
Local lNX8VTSNC     := NX8->(ColumnPos("NX8_VTSNC")) > 0  // @12.1.2210

Default cCodPre     := ""
Default lApagaPre   := .F.
Default lApagaMin   := .F.
Default cTipo       := "1"
Default nSldAcuPre  := 0

If cTipoSld == "1" // Limite por fatura

	cQuery := " SELECT (NXB.NXB_SLDPRO - NXB.NXB_SLDANT) as SALDODISP, NXA.NXA_CMOEDA "
	cQuery += " FROM " + RetSqlName("NXB") + " NXB "
	cQuery +=      " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=         " ON ( NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQuery +=         " AND NXA.NXA_CESCR = NXB.NXB_CESCR"
	cQuery +=         " AND NXA.NXA_COD = NXB.NXB_CFATUR"
	cQuery +=         " AND NXA.NXA_SITUAC = '1'"
	cQuery +=         " AND NXA.NXA_TIPO = 'FT'"
	If !Empty(cCodPre)
		cQuery +=     " AND NXA.NXA_CPREFT <> '" + cCodPre + "' "
	EndIf
	cQuery +=         " AND NXA.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NXB.NXB_FILIAL = '" + xFilial("NXB") + "'"
	cQuery +=   " AND NXB.NXB_CCONTR = '" + cCodContr + "'"
	cQuery +=   " AND NXB.D_E_L_E_T_ = ' '"
	
	aResult := JurSQL(cQuery, {"SALDODISP", "NXA_CMOEDA"})
	
	For nI := 1 To Len(aResult)
		nValFat += JA201FConv( cMoeLmCntr, aResult[nI][2], aResult[nI][1], cTpExec, dDtCotac, cCodFilaImp, cCodPre )[1]
	Next nI

	If !(cTpExec $ '3|4|5') // Se não for emissão de fatura ou minuta (de pré e fatura), considera o limite de pré-faturas emitidas
		cQuery := " SELECT " + IIF(lNX8VLRLIF, "NX8.NX8_VLRLIF", "NT0.NT0_VLRLIF") + " SALDODISP, NX0.NX0_CMOEDA, NX8.NX8_VTSVIN, NT0.NT0_CMOELI, " + IIF(lNX8VTSNC, "NX8.NX8_VTSNC", "0") + " VTSNCOB "
		cQuery += " FROM " + RetSqlName("NX8") + " NX8 "
		cQuery +=      " INNER JOIN " + RetSqlName("NX0") + " NX0 "
		cQuery +=         " ON ( NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
		cQuery +=             " AND NX0.NX0_COD = NX8.NX8_CPREFT"
		cQuery +=             " AND NX0.NX0_DINITS > '" + Space(TamSX3('NX0_DINITS')[1]) + "' " // Desconsidera Pré-Faturas que não foram marcados TS na emissão
		cQuery +=             " AND NX0.NX0_DFIMTS > '" + Space(TamSX3('NX0_DFIMTS')[1]) + "' " // Desconsidera Pré-Faturas que não foram marcados TS na emissão
		If lApagaPre
			If lApagaMin
				cQuery +=  " AND NX0.NX0_SITUAC NOT IN ('1','2','3','5','6','7','8','9','A','B','G') "
			Else
				cQuery +=  " AND NX0.NX0_SITUAC NOT IN ('1','2','3','8','G') "
			EndIf 
		Else
			cQuery +=  " AND NX0.NX0_SITUAC NOT IN ('1','8','G') "
		EndIf
		cQuery +=             " AND NX0.D_E_L_E_T_ = ' ')"
		cQuery +=      " INNER JOIN " + RetSqlName("NT0") + " NT0 "
		cQuery +=         " ON ( NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
		cQuery +=             " AND NT0.NT0_COD = NX8.NX8_CCONTR"
		cQuery +=             " AND NT0.D_E_L_E_T_ = ' ')"
		cQuery += " WHERE"
		cQuery +=     " NX8.NX8_FILIAL = '" + xFilial("NX8") + "'"
		cQuery +=     " AND NX8.NX8_CCONTR = '" + cCodContr + "'"
		cQuery +=     " AND NX8.NX8_CPREFT <> '" + cCodPre + "'"
		cQuery +=     " AND NX8.NX8_CTPHON = NT0.NT0_CTPHON "
		If lNX8VTSNC
			cQuery += " AND ((NX8.NX8_VTSVIN - NX8.NX8_VTSNC) > " + IIF(lNX8VLRLIF, "NX8.NX8_VLRLIF", "NT0.NT0_VLRLIF") + " OR (NX8.NX8_VTS > 0 AND NX8.NX8_VTSVIN = 0))"
		Else
			cQuery += " AND (NX8.NX8_VTSVIN > " + IIF(lNX8VLRLIF, "NX8.NX8_VLRLIF", "NT0.NT0_VLRLIF") + " OR (NX8.NX8_VTS > 0 AND NX8.NX8_VTSVIN = 0))"
		EndIf
		
		cQuery +=     " AND NX8.D_E_L_E_T_ = ' '"

		aResult := JurSQL(cQuery, {"SALDODISP", "NX0_CMOEDA", "NX8_VTSVIN", "NT0_CMOELI", "VTSNCOB"})

		For nI := 1 To Len(aResult)
			nValPre += JA201FConv( cMoeLmCntr, aResult[nI][2], aResult[nI][3] - aResult[nI][5], cTpExec, dDtCotac, cCodFilaImp, cCodPre )[1] - JA201FConv( cMoeLmCntr, aResult[nI][4], aResult[nI][1], cTpExec, dDtCotac, cCodFilaImp, cCodPre )[1]
		Next nI

	EndIf

	nSldAcuPre := nValFat + nValPre

ElseIf cTipoSld == "2" //Limite geral
	nValFat := J201GSldLm(cCodContr, cTipo, , , cCodPre)
EndIf

Return nValFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J201GSldLm
Rotina retornar o saldo do limite geral do contrato para as rotinas JURA201G
e JA096SDLIM

@Param   cContr     - Código do contrato
@Param   cTipo      - Se '1' retorna o valor Utilizado, '2' retorna o valor Diponível
@Param   aDados     - Força o uso dos dados diferente da NT0
                      aDados[1] = NT0_CTPHON - Tipo de Honorário
                      aDados[2] = NT0_VLRLI  - Valor limite do contrato
                      aDados[3] = NT0_SALDOI - Saldo Inicial (Valor Limite usado)
                      aDados[4] = NT0_CMOELI - Moeda do Limite
                      aDados[5] = NT0_CFACVL - Fat Adi Lim?
                      aDados[6] = NT0_CTBCVL - Serv Tb Lim?
                      aDados[7] = NT0_CFXCVL - Fixo Lim?
@Param   lModel     - Se é para buscar os dados no model ativo.
@Param   cCodPre    - Pré-fatura para desconsiderar no saldo (utilizado no cancelamento de fatura multipayer)

@return  nSaldo - Saldo disponivel

@author Luciano Pereira dos Santos
@since 31/07/2015
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function J201GSldLm(cContr, cTipo, aDados, lModel, cCodPre)
Local aArea     := GetArea()
Local nSaldo    := 0
Local nVlHonLm  := 0
Local nValorLm  := 0
Local nSaldIni  := 0
Local nValFat   := 0
Local cTpHon    := ''
Local cMoedaLm  := ''
Local cQuery    := ''
Local lLimGeral := .F.
Local aResult   := {}
Local nI        := 0
Local oModel    := Nil
Local cFacVl    := ""
Local cTbcVl    := ""
Local cFxcVl    := ""

Default cTipo   := '1'
Default aDados  := {}
Default lModel  := .F.
Default cCodPre := ""

If lModel
	oModel := FwModelActive()
	If oModel:GetId() == 'JURA096'
		cTpHon   := oModel:GetValue('NT0MASTER', 'NT0_CTPHON' ) // Tipo de Honorário
		nValorLm := oModel:GetValue('NT0MASTER', 'NT0_VLRLI' ) // Valor limite do contrato
		nSaldIni := oModel:GetValue('NT0MASTER', 'NT0_SALDOI') // Saldo Inicial (Valor Limite usado)
		cMoedaLm := oModel:GetValue('NT0MASTER', 'NT0_CMOELI') // Moeda do Limite
		cFacVl   := oModel:GetValue('NT0MASTER', 'NT0_CFACVL') // Fat Adi Lim?
		cTbcVl   := oModel:GetValue('NT0MASTER', 'NT0_CTBCVL') // Serv Tb Lim?
		cFxcVl   := oModel:GetValue('NT0MASTER', 'NT0_CFXCVL') // Fixo Lim?
	EndIf

Else
	If Empty(aDados)
		aDados := JurGetDados("NT0", 1, xFilial("NT0") + cContr, {"NT0_CTPHON", "NT0_VLRLI", "NT0_SALDOI",;
		                                                         "NT0_CMOELI", "NT0_CFACVL", "NT0_CTBCVL", "NT0_CFXCVL"})
	EndIf

	If Len(aDados) == 7
		cTpHon   := aDados[1] // Tipo de Honorário
		nValorLm := aDados[2] // Valor limite do contrato
		nSaldIni := aDados[3] // Saldo Inicial (Valor Limite usado)
		cMoedaLm := aDados[4] // Moeda do Limite
		cFacVl   := aDados[5] // Fat Adi Lim?
		cTbcVl   := aDados[6] // Serv Tb Lim?
		cFxcVl   := aDados[7] // Fixo Lim?
	EndIf
EndIf

If !Empty(cTpHon)
	lLimGeral := JurGetDados("NTH", 1, xFilial("NTH") + cTpHon + "NT0_DISPON", "NTH_VISIV") = "1"
EndIf

If lLimGeral
	If !Empty(cMoedaLm) .And. nValorLm > 0
		cQuery := " SELECT NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_CMOEDA, NXA.NXA_DTEMI, "
		cQuery +=        " SUM(CASE WHEN (NXA.NXA_FATADC = '2' OR (NXA.NXA_FATADC = '1' AND '" + cFacVl + "' = '1')) THEN (NXB.NXB_VTS) ELSE 0 END) VLTS, "
		cQuery +=        " SUM(CASE WHEN (('" + cTbcVl + "' = '1' AND NXA.NXA_TAB = '1' AND NXA.NXA_FATADC = '2')
		cQuery +=                        " OR (NXA.NXA_FATADC = '1' AND NXA.NXA_TAB = '1' AND '" + cFacVl + "' = '1' AND '" + cTbcVl + "' = '1')) THEN (NXB.NXB_VTAB) ELSE 0 END) VLTAB, "
		cQuery +=        " SUM(CASE WHEN ('" + cFxcVl + "' = '1' AND NXA.NXA_FIXO = '1') THEN (NXB.NXB_VFIXO) ELSE 0 END) VLFIX, "
		cQuery +=        " SUM(CASE WHEN (NXB.NXB_SLDANT > 0) THEN (NXB.NXB_VLFATH - NXB.NXB_VTS - NXB.NXB_VTAB - NXB.NXB_VFIXO) ELSE 0 END) VLEXCEDUTI, "
		cQuery +=        " SUM(NXB.NXB_DRATF) VLDESC "
		cQuery += " FROM  " + RetSqlName('NXA') + " NXA, "
		cQuery +=       " " + RetSqlName('NXB') + " NXB "
		cQuery += " WHERE NXA.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND NXB.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND NXA.NXA_FILIAL = '" + xFilial('NXA') + "' "
		cQuery +=   " AND NXB.NXB_FILIAL = '" + xFilial('NXB') + "' "
		cQuery +=   " AND NXA.NXA_COD    = NXB.NXB_CFATUR "
		cQuery +=   " AND NXA.NXA_CESCR  = NXB.NXB_CESCR "
		If !Empty(cCodPre)
			cQuery += " AND NXA.NXA_CPREFT <> '" + cCodPre + "' "
		EndIf
		cQuery +=   " AND NXA.NXA_TIPO   = 'FT' "
		cQuery +=   " AND NXA.NXA_CALDIS = '1' "
		cQuery +=   " AND NXA.NXA_SITUAC = '1' "
		cQuery +=   " AND NXB.NXB_CCONTR = '" + cContr + "' "
		cQuery +=   " AND NXB.NXB_CTPHON = '" + cTpHon + "' "
		cQuery += " GROUP BY NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_CMOEDA, NXA.NXA_DTEMI "

		aResult := JurSQL(cQuery, {"NXA_CESCR", "NXA_COD", "NXA_CMOEDA",;
		                                        "NXA_DTEMI", "VLTS", "VLTAB", "VLFIX", "VLDESC", "VLEXCEDUTI" })

		For nI := 1 To Len(aResult)
			            // TS            // TB            // FX            // Desconto      // Valor Excedido Utilizado
			nVlHonLm := aResult[nI][5] + aResult[nI][6] + aResult[nI][7] - aResult[nI][8] + aResult[nI][9]

			nValFat += JA201FConv(cMoedaLm, aResult[nI][3], nVlHonLm, "8", StoD(aResult[nI][4]), /*Fila*/, /*Pre*/, /*Filial*/, aResult[nI][1], aResult[nI][2])[1]
		Next nI
	EndIf

	If cTipo == '1' // Utilizado
		nSaldo := nValFat + nSaldIni
	ElseIf cTipo == '2' // Disponivel
		nSaldo := nValorLm - nSaldIni - nValFat
		If nSaldo < 0 // O campo "Disponível" (NT0_DISPON) não deve apresentar valores negativos.
			nSaldo := 0
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return (nSaldo)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201GSldCs()
Rotina para retornar o saldo do limite geral do caso para as rotinas JURA201G, 
JA070SDLIM e JURA201D.

@Param   cCliente  Código do cliente do caso
@Param   cLoja     Código da loja do cliente do caso
@Param   cCaso     Código do caso
@Param   cTipo     Se '1' retorna o valor Utilizado, '2' retorna o valor Disponível
@Param   lModel    Se .T. para extrair as informações do caso atráves modelo. Padrão: .F.
@Param   aCasoPre  Array com as informações de Limite no Caso da Pré-fatura

@return  nSaldo    Valor/Saldo disponivel conforme o parametro cTipo.

@author Anderson Carvalho / Queizy Nascimento
@since 11/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201GSldCs(cCliente, cLoja, cCaso, cTipo, lModel, aCasoPre)
Local aArea      := GetArea()
Local nSaldo     := 0
Local nVlHonLm   := 0
Local nValorLm   := 0
Local nSaldIni   := 0
Local nValFat    := 0
Local cMoedaLm   := ''
Local cQuery     := ''
Local lLimGeral  := .F.
Local aResult    := {}
Local aNVE       := {}
Local nI         := 0
Local oModel     := Nil
Local cFaCLim    := '' 
Local cTbCLim    := ''

Default cTipo    := '1'
Default lModel   := .F.
Default aCasoPre := {} 

If lModel
	oModel := FwModelActive()
	If oModel:GetId() == 'JURA070'
		nValorLm  := oModel:GetValue('NVEMASTER', 'NVE_VLRLI' ) //Valor limite do contrato
		nSaldIni  := oModel:GetValue('NVEMASTER', 'NVE_SALDOI') //Saldo Inicial (Valor Limite usado)
		cMoedaLm  := oModel:GetValue('NVEMASTER', 'NVE_CMOELI') //Moeda do Limite
		cFaCLim   := oModel:GetValue('NVEMASTER', 'NVE_CFACVL') //Considera Fatura Adicional 
		cTbCLim   := oModel:GetValue('NVEMASTER', 'NVE_CTBCVL') //Considera Tabelado
		lLimGeral := !Empty(cMoedaLm) .And. (oModel:GetOperation() == 1 .Or. oModel:GetOperation() == 4) 
	EndIf
Else
	If Len(aCasoPre) > 0
		nValorLm  := aCasoPre[11]
		nSaldIni  := aCasoPre[12]
		cMoedaLm  := aCasoPre[10]
		cFaCLim   := aCasoPre[13]
		cTbCLim   := aCasoPre[14]
		lLimGeral := !Empty(cMoedaLm)
	Else
		If NVE->(ColumnPos('NVE_VLRLI')) > 0
			aNVE := JurGetDados("NVE", 1, xFilial("NVE") + cCliente + cLoja + cCaso + '1', {"NVE_VLRLI", "NVE_SALDOI", "NVE_CMOELI", "NVE_CFACVL", "NVE_CTBCVL" })
		EndIf
	 	If Len(aNVE) == 5
			nValorLm  := aNVE[1] // Valor limite do contrato
			nSaldIni  := aNVE[2] // Saldo Inicial (Valor Limite usado)
			cMoedaLm  := aNVE[3] // Moeda do Limite
			cFaCLim   := aNVE[4] // Considera Fatura Adicional 
			cTbCLim   := aNVE[5] // Considera Tabelado
			lLimGeral := !Empty(cMoedaLm)
		EndIf
	EndIf
EndIf

If lLimGeral
	cQuery := " SELECT NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_CMOEDA, NXA.NXA_DTEMI, "
	cQuery +=        " SUM(CASE WHEN (NXA.NXA_FATADC = '2' OR (NXA.NXA_FATADC = '1' AND '" + cFaCLim + "' = '1')) THEN (NXC.NXC_VLTS) ELSE 0 END) VLTS, "
	cQuery +=        " SUM(CASE WHEN (('" + cTbCLim + "' = '1' AND NXA.NXA_TAB = '1' AND NXA.NXA_FATADC = '2')
	cQuery +=                        " OR (NXA.NXA_FATADC = '1' AND NXA.NXA_TAB = '1' AND '" + cFaCLim + "' = '1' AND '" + cTbCLim + "' = '1')) THEN (NXC.NXC_VLTAB) ELSE 0 END) VLTAB, "
	cQuery +=        " NXC.NXC_ARATF VLACRE, NXC.NXC_DRATF VLDESC "
	cQuery += " FROM  " + RetSqlName('NXA') + " NXA, "
	cQuery +=       " " + RetSqlName('NXC') + " NXC, "
	cQuery +=       " " + RetSqlName('NVE') + " NVE "
	cQuery += " WHERE NXA.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NXC.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NXA.NXA_FILIAL = '" + xFilial('NXA') + "' "
	cQuery +=   " AND NXC.NXC_FILIAL = '" + xFilial('NXC') + "' "
	cQuery +=   " AND NVE.NVE_FILIAL = '" + xFilial('NVE') + "' "
	cQuery +=   " AND NXA.NXA_COD    = NXC.NXC_CFATUR "
	cQuery +=   " AND NXA.NXA_CESCR  = NXC.NXC_CESCR "
	cQuery +=   " AND NXC.NXC_CCLIEN = NVE.NVE_CCLIEN "
	cQuery +=   " AND NXC.NXC_CLOJA  = NVE.NVE_LCLIEN "
	cQuery +=   " AND NXC.NXC_CCASO  = NVE.NVE_NUMCAS "
	cQuery +=   " AND NXA.NXA_TIPO   = 'FT' "
	cQuery +=   " AND NXA.NXA_CALDIS = '1' "
	cQuery +=   " AND NXA.NXA_SITUAC = '1' "
	cQuery +=   " AND NXC.NXC_CCLIEN = '" + cCliente + "' "
	cQuery +=   " AND NXC.NXC_CLOJA  = '" + cLoja + "' "
	cQuery +=   " AND NXC.NXC_CCASO  = '" + cCaso + "' "
	cQuery += " GROUP BY NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_CMOEDA, NXA.NXA_DTEMI, NXC.NXC_ARATF, "
	cQuery +=   " NXC.NXC_DRATF"

	aResult := JurSQL(cQuery, {"NXA_CESCR", "NXA_COD", "NXA_CMOEDA",; //3
	                          "NXA_DTEMI", "VLTS", "VLTAB", "VLACRE", "VLDESC" })  //8
	
	For nI := 1 To Len(aResult)
		            //TS             //TB             // Acres         //Desc
		nVlHonLm := aResult[nI][5] + aResult[nI][6] + aResult[nI][7] - aResult[nI][8]
	
		nValFat += JA201FConv(cMoedaLm, aResult[nI][3], nVlHonLm, "8", StoD(aResult[nI][4]), /*Fila*/, /*Pre*/, /*Filial*/, aResult[nI][1], aResult[nI][2])[1]
	Next nI

EndIf

If cTipo == '1' //Utilizado
	nSaldo := nValFat + nSaldIni
ElseIf cTipo == '2' //Disponível
	nSaldo := nValorLm - nSaldIni - nValFat
EndIf

RestArea( aArea )

Return (nSaldo)
