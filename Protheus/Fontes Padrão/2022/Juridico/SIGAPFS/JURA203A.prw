#Include "Protheus.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203ARat
Função para controlar a tela de Rateio do Desconto / Acréscimo da Fatura

@Param  cEscrit   Código do Escritório da Fatura
@Param  cNumFat   Número da Fatura
@Param  cTipo     Tipo do Rateio: 1 - Desconto / 2 - Acréscimo
		
@Return -

@author David G. Fernandes
@since 01/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203ARat(cEscrit, cNumFat, cTipo, cPreFt, lExibe, lInsSld)  
	Local lRet := .F.
	Local aRet := {.F., "JA203ARat"} 
	
	Private oRateio

	oRateio := TJRATCASO():New(cEscrit, cNumFat, cTipo, cPreFt)
	If lExibe
		oRateio:DrawScreen()
	EndIf

	If lInsSld
		lRet := oRateio:InsereSaldo(lExibe)
	EndIf
	
	If lExibe
		lRet := oRateio:ActiveScreen()
	EndIf
	
	//Se rateio de Acrescimo ou do pagador, executa a confirmacao dos valores (nao existe tela)
	If cTipo $ "2|3"
		lRet := oRateio:Confirma()
	EndIf
	
	If lRet 
		aRet := {.T., "JA203ARat"} 
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203QRYRAT
Retorna as querys utilizadas na consulta dos contratos / casos / participantes
na inclusão par ao rateio e para a rotina de inclusão do saldo.

@author David Gonçalves Fernandes
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203QRYRAT(cEscrit, cNumFat, cAlias, cTipo, cPreFt)
Local cQuery := ""

Do Case
	Case cAlias == 'NXB'
		If cTipo == '1' //Count
			cQuery := " SELECT COUNT(NXB.NXB_CESCR) COUNTNXB " + CRLF
		ElseIf cTipo == '2' //F3
			cQuery := " SELECT NXB.NXB_CESCR, NXB.NXB_CFATUR, NXB.NXB_CCONTR, NT0.NT0_NOME, NXB.NXB_VLFATH, " + CRLF
			cQuery += "        NXB.R_E_C_N_O_ NXBRECNO  " + CRLF
		ElseIf cTipo == '3'//Saldos
			cQuery := " SELECT NXB.NXB_CCONTR, NT0.NT0_NOME, NXB.NXB_VLFATH,  " + CRLF
			cQuery += "        NXB.R_E_C_N_O_ NXBRECNO  " + CRLF
		EndIf
		cQuery += "   FROM " + RetSQLName("NXB") + " NXB, " + RetSQLName("NT0") + " NT0 " + CRLF
		cQuery += "  WHERE NXB.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NT0.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NXB.NXB_FILIAL = '" + xFilial('NXB') + "' " + CRLF
		cQuery += "    AND NT0.NT0_FILIAL = '" + xFilial('NT0') + "' " + CRLF
		cQuery += "    AND NXB.NXB_CCONTR = NT0.NT0_COD " + CRLF
		cQuery += "    AND NXB.NXB_VLFATH > 0 " + CRLF
		cQuery += "    AND NXB.NXB_CESCR  = '" + cEscrit + "' " + CRLF
		cQuery += "    AND NXB.NXB_CFATUR = '" + cNumFat + "' " + CRLF
		
	Case cAlias == 'NXC'
		If cTipo == '1' //Count
			cQuery := " SELECT COUNT(NXC.NXC_CESCR) COUNTNXC " + CRLF
		ElseIf cTipo == '2' //F3
			cQuery := " SELECT NXC.NXC_CCONTR, NXC.NXC_CCLIEN, NXC.NXC_CLOJA, NXC.NXC_CCASO, " + CRLF
			cQuery += " 	      NVE.NVE_TITULO,  NXC.NXC_VLTS, NXC.NXC_VLTAB, " + CRLF
			cQuery += "        NXC.R_E_C_N_O_ NXCRECNO " + CRLF
		ElseIf cTipo == '3'//Saldos
			cQuery := " SELECT NXC.NXC_CCONTR, NXC.NXC_CCLIEN, NXC.NXC_CLOJA, NXC.NXC_CCASO, " + CRLF
			cQuery += "        NVE.NVE_TITULO, NXC.NXC_VLTS, NXC.NXC_VLTAB, NXC.NXC_VLHFAT, NXC.NXC_DRATL," + CRLF
			cQuery += "        NXC.NXC_DRATL, NXC_DRATE, " + CRLF
			cQuery += "        NXC.R_E_C_N_O_ NXCRECNO  " + CRLF
		EndIf
		cQuery += "   FROM " + RetSQLName("NXC") + " NXC, " + RetSQLName("NVE") + " NVE " + CRLF
		cQuery += "  WHERE NXC.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NVE.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NXC.NXC_FILIAL = '" + xFilial('NXC') + "' " + CRLF
		cQuery += "    AND NVE.NVE_FILIAL = '" + xFilial('NVE') + "' " + CRLF
		cQuery += "    AND NXC.NXC_CCLIEN = NVE.NVE_CCLIEN " + CRLF
		cQuery += "    AND NXC.NXC_CLOJA  = NVE.NVE_LCLIEN " + CRLF
		cQuery += "    AND NXC.NXC_CCASO  = NVE.NVE_NUMCAS " + CRLF
		cQuery += "    AND NXC.NXC_CESCR  = '" + cEscrit + "' " + CRLF
		cQuery += "    AND NXC.NXC_CFATUR = '" + cNumFat + "' " + CRLF
		
	Case cAlias == 'NXD'
		If cTipo == '1' //Count
			cQuery := " SELECT COUNT(NXD.NXD_CESCR) COUNTNXD  " + CRLF
		ElseIf cTipo == '2' //F3
			cQuery := " SELECT NXD.NXD_CCLIEN, NXD.NXD_CLOJA, NXD.NXD_CCASO, NXD.NXD_CPART, NXD.NXD_CSEQ,  " + CRLF
			cQuery += "        RD0.RD0_NOME,  NXD.NXD_VLADVG, " + CRLF
			cQuery += "        NXD.R_E_C_N_O_ NXDRECNO  " + CRLF
		ElseIf cTipo == '3'//Saldos
			cQuery := " SELECT NXD.NXD_CCLIEN, NXD.NXD_CLOJA, NXD.NXD_CCASO, NXD.NXD_CPART, NXD.NXD_CSEQ,   " + CRLF
			cQuery += "        RD0.RD0_NOME, NXD.NXD_VLADVG,  " + CRLF
			cQuery += "        NXD.R_E_C_N_O_ NXDRECNO  " + CRLF
		EndIf
		cQuery += "   FROM " + RetSQLName("NXD") + " NXD, " + RetSQLName("RD0") + " RD0                " + CRLF
		cQuery += "  WHERE NXD.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND RD0.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NXD.NXD_FILIAL = '" + xFilial('NXD') + "' " + CRLF
		cQuery += "    AND RD0.RD0_FILIAL = '" + xFilial('RD0') + "' " + CRLF
		cQuery += "    AND NXD.NXD_CPART  = RD0_CODIGO " + CRLF
		cQuery += "    AND NXD.NXD_VLADVG     > 0 " + CRLF
		cQuery += "    AND NXD.NXD_CESCR  = '" + cEscrit + "' " + CRLF
		cQuery += "    AND NXD.NXD_CFATUR = '" + cNumFat + "' " + CRLF

	Case cAlias == 'NX1'
		If cTipo == '1' //Count
			cQuery := " SELECT COUNT(NX1.NX1_CPREFT) COUNTNX1 " + CRLF
		ElseIf cTipo == '2' //F3
			cQuery := " SELECT NX1.NX1_CCONTR, NX1.NX1_CCLIEN, NX1.NX1_CLOJA, NX1.NX1_CCASO, " + CRLF
			cQuery +=         " NVE.NVE_TITULO,  NX1.NX1_VTS, NX1.NX1_VTAB," + CRLF
			cQuery +=         " NX1.R_E_C_N_O_ NX1RECNO  " + CRLF
		ElseIf cTipo == '3'//Saldos
			cQuery := " SELECT NX1.NX1_CCONTR, NX1.NX1_CCLIEN, NX1.NX1_CLOJA, NX1.NX1_CCASO, " + CRLF
			cQuery +=        " NVE.NVE_TITULO,  NX1.NX1_VTS, NX1.NX1_VTAB, NX0.NX0_VLFATH, NX1.NX1_VDESCO," + CRLF
			cQuery +=        " NX1.R_E_C_N_O_ NX1RECNO  " + CRLF
		EndIf
		cQuery += "   FROM " + RetSQLName("NX1") + " NX1, " + RetSQLName("NVE") + " NVE, " + RetSQLName("NX0") + " NX0 " + CRLF
		cQuery += "  WHERE NX1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NVE.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NX0.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "    AND NX1.NX1_FILIAL = '" + xFilial('NX1') + "' " + CRLF
		cQuery += "    AND NVE.NVE_FILIAL = '" + xFilial('NVE') + "' " + CRLF
		cQuery += "    AND NX0.NX0_FILIAL = '" + xFilial('NX0') + "' " + CRLF
		cQuery += "    AND NX1.NX1_CCLIEN = NVE.NVE_CCLIEN " + CRLF
		cQuery += "    AND NX1.NX1_CLOJA  = NVE.NVE_LCLIEN " + CRLF
		cQuery += "    AND NX1.NX1_CCASO  = NVE.NVE_NUMCAS " + CRLF
		cQuery += "    AND NX1.NX1_CPREFT = '" + cPreFt + "' " + CRLF
		cQuery += "    AND NX0.NX0_COD    = NX1.NX1_CPREFT " + CRLF
		
	OtherWise
		cQuery := " "
EndCase

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JaRemPos
Remove itens do array (cria um novo array sem o item excluído)
Pois a Função ADEL() exclui o item mas mantém a posição vazia.

@Params aArray, nPos

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JaRemPos(aArray, nPos)
Local nI   := 0
Local aRet := {}

	If !Empty(aArray)
		For nI := 1 To Len(aArray)
			If !Empty(aArray[ni]) .AND. nI <> nPos
				aAdd(aRet, aArray[nI] )
			EndIf
		Next
	EndIf
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203aSA1F3
Filtro Cliente/Loja para pesquisa da tela de desconto especial na pré-fatura

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@author Abner Fogaça
@since 05/12/18
/*/
//-------------------------------------------------------------------
Function J203aSA1F3()
	Local cSQL       := ""
	Local cTab       := "SA1"
	Local aCampos    := {{"SA1", "A1_COD"}, {"SA1", "A1_LOJA"}}
	Local lVisualiza := .F.
	Local lInclui    := .F.
	Local nResult    := 0
	Local lResult    := .F.

	cSQL := " SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.R_E_C_N_O_ RECNO "
	cSQL +=   " FROM " + RetSqlName("SA1") + " SA1 "
	cSQL +=  " WHERE EXISTS  (SELECT NX1.NX1_CCLIEN, NX1.NX1_CLOJA "
	cSQL +=                   " FROM " + RetSqlName("NX1") + " NX1 "
	cSQL +=                  " WHERE NX1.D_E_L_E_T_ = ' ' "
	cSQL +=                    " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "'"
	cSQL +=                    " AND NX1.NX1_CPREFT = '" + NX0->NX0_COD + "'
	If !Empty(cGetCtrF3)
		cSQL +=                " AND NX1.NX1_CCONTR = '" + cGetCtrF3 + "'
	EndIf
	cSQL +=                    " AND SA1.A1_COD = NX1.NX1_CCLIEN "
	cSQL +=                    " AND SA1.A1_LOJA = NX1.NX1_CLOJA) "
	cSQL +=    " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	CSQL +=    " AND SA1.D_E_L_E_T_ = ' ' "

	nResult := JurF3SXB(cTab, aCampos, "", .F., .F., "", cSQL)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf

	oRateio:SetF3Caso(Criavar("NVE_NUMCAS", .F.))
	oRateio:SetF3Contr(CriaVar('NT0_COD', .F.))

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J203aNVEF3
Filtro Cliente/Loja/Caso para pesquisa da tela de desconto especial na pré-fatura

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@author Abner Fogaça
@since 05/12/18
/*/
//-------------------------------------------------------------------
Function J203aNVEF3()
	Local cSQL       := ""
	Local cTab       := "NVE"
	Local aCampos    := {{"NVE", "NVE_CCLIEN"}, {"NVE", "NVE_LCLIEN"}, {"NVE", "NVE_NUMCAS"}}
	Local lVisualiza := .F.
	Local lInclui    := .F.
	Local nResult    := 0
	Local lResult    := .F.

	cSQL := " SELECT NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS, NVE.R_E_C_N_O_ RECNO "
	cSQL +=   " FROM " + RetSqlName("NVE") + " NVE "
	cSQL +=  " WHERE EXISTS  (SELECT NX1.NX1_CCLIEN, NX1.NX1_CLOJA "
	cSQL +=                   " FROM " + RetSqlName("NX1") + " NX1 "
	cSQL +=                  " WHERE NX1.D_E_L_E_T_ = ' ' "
	cSQL +=                    " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "'"
	cSQL +=                    " AND NX1.NX1_CPREFT = '" + NX0->NX0_COD + "' "
	cSQL +=                    " AND NVE.NVE_CCLIEN = NX1.NX1_CCLIEN "
	cSQL +=                    " AND NVE.NVE_LCLIEN = NX1.NX1_CLOJA "
	cSQL +=                    " AND NVE.NVE_NUMCAS = NX1.NX1_CCASO) "
	cSQL +=    " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	CSQL +=    " AND NVE.D_E_L_E_T_ = ' ' "
	If !Empty(cGetCliF3) .And. !Empty(cGetLjF3)
		CSQL +=    " AND NVE.NVE_CCLIEN = '" + cGetCliF3 + "' "
		CSQL +=    " AND NVE.NVE_LCLIEN = '" + cGetLjF3 + "' "
	EndIf

	nResult := JurF3SXB(cTab, aCampos, "", .F., .F., "", cSQL)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J203aNT0F3
Filtro Cliente/Loja/Caso para pesquisa da tela de desconto especial na pré-fatura

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@author Abner Fogaça
@since 05/12/18
/*/
//-------------------------------------------------------------------
Function J203aNT0F3()
	Local cSQL       := ""
	Local cTab       := "NT0"
	Local aCampos    := {{"NT0", "NT0_COD"}}
	Local lVisualiza := .F.
	Local lInclui    := .F.
	Local nResult    := 0
	Local lResult    := .F.

	cSQL := " SELECT NT0.NT0_COD, NT0.R_E_C_N_O_ RECNO "
	cSQL +=   " FROM " + RetSqlName("NT0") + " NT0 "
	cSQL +=  " WHERE EXISTS  (SELECT NX1.NX1_CCLIEN, NX1.NX1_CLOJA "
	cSQL +=                   " FROM " + RetSqlName("NX1") + " NX1 "
	cSQL +=                  " INNER JOIN " + RetSqlName("NUT") + " NUT "
	cSQL +=                          " ON NUT.NUT_CCONTR = NX1.NX1_CCONTR "
	cSQL +=                         " AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "'"
	cSQL +=                         " AND NUT.D_E_L_E_T_ = ' ' "
	cSQL +=                  " WHERE NX1.D_E_L_E_T_ = ' ' "
	cSQL +=                    " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "'"
	cSQL +=                    " AND NX1.NX1_CPREFT = '" + NX0->NX0_COD + "' "
	If !Empty(cGetCliF3) .And. !Empty(cGetLjF3)
		cSQL +=                    " AND NUT.NUT_CCLIEN = '" + cGetCliF3 + "' "
		cSQL +=                    " AND NUT.NUT_CLOJA = '" + cGetLjF3 + "' "
	EndIf
	cSQL +=                    " AND NT0.NT0_CCLIEN = NX1.NX1_CCLIEN "
	cSQL +=                    " AND NT0.NT0_CLOJA = NX1.NX1_CLOJA "
	cSQL +=                    " AND NT0.NT0_COD = NX1.NX1_CCONTR) "
	cSQL +=    " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
	CSQL +=    " AND NT0.D_E_L_E_T_ = ' ' "

	nResult := JurF3SXB(cTab, aCampos, "", .F., .F., "", cSQL)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf

Return lResult
