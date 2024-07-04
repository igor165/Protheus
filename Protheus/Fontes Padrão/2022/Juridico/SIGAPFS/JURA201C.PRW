#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201.CH"

//TIPO EXEC = 1 (EMISSÃO DE PRÉ)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201CEmi()
Rotina para Totalizar os Valores e Gravar a Pre

@param oParams   , Objeto com os parâmetros para emissão da pré-fatura
@param cCodPre   , Código da pré-fatura
@param cNVVCOD   , Código da Fatura Adicional
@param cNW2COD   , Código da Junção de Contratos
@param cNT0COD   , Código do Contrato
@param lAutomato , Indica se a chamada foi feita via automação

@return aRet     , Retorno da Emissão
                   aRet[1] - .T. - Executado com sucesso - .F. - Houve erro
                   aRet[2] - Nome da função

@author David G. Fernandes
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201CEmi(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD, lAutomato)
	Local aRet      := {.T., "JA201CRcTS" }
	Local cCMOEDFT  := ""
	Local cFatCanc  := oParams:GetCodEscr() + oParams:GetCodFatur()
	Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
	Local nVTAXA2   := 0
	Local aArea     := GetArea()
	Local aNW2      := {}

	//Adicionado para não afetar a performance da tela quando o parâmetro de fila de integração está desativado
	Local lIntegracao := (SuperGetMV("MV_JFSINC", .F., '2') == '1')

	Default lAutomato := .F.

	//Verificar Escritório e Filial de emissão (se houver junção é da junção)
	If !Empty(cNW2COD)
		// O escritório só é utilizado para obter a filial
		aNW2 := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, {"NW2_CMOE", "NW2_CRELAT"})
		If !Empty(aNW2)
			cCMOEDFT := aNW2[1]
			cCRELAT  := aNW2[2]
		EndIf
	Else
		cCRELAT := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CRELAT")
		If !Empty(cNVVCOD)
			cCMOEDFT := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CMOE3")
		Else
			cCMOEDFT := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CMOE")
		EndIf
	EndIf

	//Insere a cotação da moeda da pré:
	If cCMOEDFT <> cMoedaNac
		// Verifica cotação dos Honorários da Fatura Acicional
		aConvLanc := JA201FConv(cCMOEDFT, cMoedaNac, 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
		nVTAXA2   := aConvLanc[3]  // Moeda da Pré

		If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
			J201DCotac(cCodPre, cCMOEDFT, nVTAXA2)
		EndIf
	EndIf

	// A filial só era usada para obter a taxa de conversão pelo DB
	//Totaliza Caso
	oParams:PtInternal(STR0128) // "Emitindo - Totaliza Caso"
	aRet := JA201DCaso(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD)

	//Totaliza Contrato
	If aRet[1]
		oParams:PtInternal(STR0129) // "Emitindo - Totaliza Contrato"
		aRet := JA201ECont(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD, lAutomato)
	EndIf

	//Totaliza Pré
	If aRet[1]
		oParams:PtInternal(STR0130) // "Emitindo - Totaliza Pré"
		aRet := JA201HPreF(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD, cCRELAT)
	EndIf

	//Vincula os Pagadores à pré
	If aRet[1]
		oParams:PtInternal(STR0131) // "Emitindo - Vincula os Pagadores à pré"
		aRet := JA201CPag(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD, cFatCanc)
	EndIf

	//Vincula os Encaminhamentos de Fatura à pré
	If aRet[1]
		oParams:PtInternal(STR0132) // "Emitindo - Vincula os Encaminhamentos de Fatura à pré"
		aRet := JA201CEnc(cCodPre, cNVVCOD, cNW2COD, cNT0COD)
	EndIf

	//Processa as customizações na emissão da pré:
	If aRet[1] .And. ExistBlock('J201CPF')
		aRet := ExecBlock('J201CPF', .F., .F., {cCodPre})
	EndIf

	If aRet[1] .And. lIntegracao .And. !(oParams:GetSituac() == '1')
		//Grava na fila de sincronização a alteração de pré-fatura
		If oParams:GetSituac() == "6"
			J170GRAVA("NX0", xFilial("NX0") + cCodPre, "3")
		Else
			J170GRAVA("JURA202E", xFilial("NX0") + cCodPre, "3")
		EndIf
	EndIf

	RestArea(aArea)

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201CPag()
Rotina para Vincular os pagadores da junção ou do contrato à pré-fatura

@author David G. Fernandes
@since 17/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201CPag(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD, cFatCanc)
Local aRet       := {.F., "JA201CPag (cCodPre, cNVVCOD, cNW2COD, cNT0COD): " + cCodPre +"-"+ cNVVCOD +"-"+ cNW2COD +"-"+ cNT0COD }
Local cQuery     := ''
Local aArea      := GetArea()
Local cQryRes    := ''
Local aConvLanc  := {}
Local nVTAXA1    := 0
Local nVTAXA2    := 0
Local cTipoRF    := ""
Local cEscrit    := ""
Local cFilEscr   := ""
Local aPimposto  := {}
Local aValorImp  := {}
Local nValorImp  := 0
Local lProtVlTrb := NX0->(ColumnPos('NX0_VLTRIB')) > 0 // Proteção
Local lProtJuros := NXP->(ColumnPos("NXP_TXPERM")) > 0 .And. NXG->(ColumnPos("NXG_TXPERM")) > 0 // Proteção
Local lProtTxAdm := NXG->(ColumnPos("NXG_TXADM")) > 0  .And. NXG->(ColumnPos("NXG_GROSUP")) > 0 // Proteção
Local lProtNatPg := NXP->(ColumnPos("NXP_CNATPG")) > 0 .And. NXG->(ColumnPos("NXG_CNATPG")) > 0 // Proteção
Local lProtImp   := NXG->(ColumnPos('NXG_PIRRF')) > 0  .And. NXG->(ColumnPos('NXG_PPIS'))   > 0 .And. NXG->(ColumnPos('NXG_PCOFIN')) > 0 .And. ; // Proteção
                    NXG->(ColumnPos('NXG_PCSLL')) > 0  .And. NXG->(ColumnPos('NXG_PINSS'))  > 0 .And. NXG->(ColumnPos('NXG_PISS')) > 0  // Proteção
Local lProtEmail := NXP->(ColumnPos("NXP_EMAIL")) > 0  .And. NXG->(ColumnPos("NXG_EMAIL"))  > 0 // @12.1.2310
Local lProtEMin  := NXP->(ColumnPos("NXP_EMLMIN")) > 0 .And. NXG->(ColumnPos("NXG_EMLMIN")) > 0 // @12.1.2310
Local lProtGrsHn := NXP->(ColumnPos("NXP_GROSHN")) > 0 // @12.1.2310

If Empty(cNVVCOD)

	cQuery := " SELECT NXP.NXP_CJCONT CJCONT, "
	cQuery +=        " NXP.NXP_FILIAL FILIAL, "
	cQuery +=        " NXP.NXP_COD COD, "
	cQuery +=        " NXP.NXP_CLIPG CLIPG, "
	cQuery +=        " NXP.NXP_LOJAPG LOJAPG, "
	cQuery +=        " NXP.NXP_PERCEN PERCEN, "
	cQuery +=        " NXP.NXP_CCONT CCONT, "
	cQuery +=        " NXP.NXP_FPAGTO FPAGTO, "
	cQuery +=        " NXP.NXP_CCDPGT CCDPGT, "
	cQuery +=        " NXP.NXP_CBANCO CBANCO, "
	cQuery +=        " NXP.NXP_CAGENC CAGENC, "
	cQuery +=        " NXP.NXP_CCONTA CCONTA, "
	cQuery +=        " NXP.NXP_DESPAD DESPAD, "
	cQuery +=        " NXP.NXP_CMOE CMOE, "
	cQuery +=        " NXP.NXP_CRELAT CRELAT, "
	cQuery +=        " NXP.NXP_CCARTA CCARTA, "
	cQuery +=        " NXP.NXP_CIDIO CIDIO, "
	cQuery +=        " NXP.NXP_CIDIO2 CIDIO2, "
	If NXP->(ColumnPos("NXP_TXADM")) > 0 .And. NXP->(ColumnPos("NXP_GROSUP")) > 0 // Proteção
		cQuery +=    " NXP.NXP_TXADM TXADM, "
		cQuery +=    " NXP.NXP_GROSUP GROSUP, "
	EndIf
	If lProtJuros // Proteção
		cQuery +=    " NXP.NXP_TXPERM TXPERM, "
		cQuery +=    " NXP.NXP_PJUROS PJUROS, "
		cQuery +=    " NXP.NXP_DESFIN DESFIN, "
		cQuery +=    " NXP.NXP_DIADES DIADES, "
		cQuery +=    " NXP.NXP_TPDESC TPDESC, "
	EndIf
	If lProtNatPg
		cQuery +=    " NXP.NXP_CNATPG CNATPG, "
	EndIf
	If lProtEmail
		cQuery +=    " NXP.NXP_EMAIL EMAIL, "
	EndIf
	If lProtEMin
		cQuery +=    " NXP.NXP_EMLMIN EMLMIN, "
	EndIf	
	If lProtGrsHn
		cQuery +=    " NXP.NXP_GROSHN CGROSHN, "
		cQuery +=    " NXP.NXP_PERCGH PERCGROSHN, "
	EndIf
	cQuery +=        " NXP.NXP_CCONTR CCONTR "
	cQuery += " FROM " + RetSqlName("NXP") + " NXP "
	cQuery +=       " WHERE NXP.NXP_FILIAL = '"+ xFilial("NXA") +"' "
	If !Empty(cNW2COD)
		cQuery +=     " AND NXP.NXP_CJCONT = '"+ cNW2COD +"' "
	ElseIf !Empty(cNT0COD)
		cQuery += " AND NXP.NXP_CCONTR = '"+ cNT0COD +"' "
	EndIf
	cQuery +=        " AND NXP.D_E_L_E_T_ = ' ' "

	cQuery  := ChangeQuery(cQuery, .F.)
	cQryRes := GetNextAlias()

	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	cTipoRF := oParams:GetTipRel()  // Tipo de relatorio de fatura especifico

	While !(cQryRes)->(EOF())
		If !Empty(cNW2COD)
			cEscrit := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CESCR")
		ElseIf !Empty(cNT0COD)
			cEscrit := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CESCR")
		EndIf
		
		cFilEscr := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")

		If lProtVlTrb // Proteção
			If Len(aValorImp := JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, {'NX0_VLFATH', 'NX0_VLTRIB'})) == 2
				nValorImp := (aValorImp[1] + aValorImp[2]) * ((cQryRes)->PERCEN / 100.00)
			EndIf
		Else
			If !Empty(aValorImp := JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, {'NX0_VLFATH'}))
				nValorImp := aValorImp * ((cQryRes)->PERCEN / 100.00)
			EndIf
		EndIf

		aPimposto := JA201CPerc((cQryRes)->CLIPG, (cQryRes)->LOJAPG, (cQryRes)->CMOE, oParams:GetDEmi(), nValorImp, (cQryRes)->CCDPGT, cFilEscr)

		RecLock("NXG", .T.)
		NXG->NXG_FILIAL      := xFilial("NXG")
		NXG->NXG_COD         := JurGetNum('NXG', 'NXG_COD')
		NXG->NXG_CPREFT      := cCodPre
		NXG->NXG_CFIXO       := ""
		NXG->NXG_CFATAD      := ""
		NXG->NXG_CLIPG       := (cQryRes)->CLIPG
		NXG->NXG_LOJAPG      := (cQryRes)->LOJAPG
		NXG->NXG_PERCEN      := (cQryRes)->PERCEN
		NXG->NXG_CCONT       := (cQryRes)->CCONT
		NXG->NXG_FPAGTO      := (cQryRes)->FPAGTO
		NXG->NXG_CCDPGT      := (cQryRes)->CCDPGT
		NXG->NXG_CBANCO      := (cQryRes)->CBANCO
		NXG->NXG_CAGENC      := (cQryRes)->CAGENC
		NXG->NXG_CCONTA      := (cQryRes)->CCONTA
		NXG->NXG_DESPAD      := (cQryRes)->DESPAD
		NXG->NXG_CMOE        := (cQryRes)->CMOE
		NXG->NXG_CRELAT      := If(Empty(cTipoRF), (cQryRes)->CRELAT, cTipoRF)   // Tipo de relatorio de fatura especifico
		NXG->NXG_CCARTA      := (cQryRes)->CCARTA
		NXG->NXG_CIDIO       := (cQryRes)->CIDIO
		NXG->NXG_CIDIO2      := (cQryRes)->CIDIO2
		NXG->NXG_CCONTR      := (cQryRes)->CCONTR
		If lProtTxAdm
			NXG->NXG_TXADM   := (cQryRes)->TXADM
			NXG->NXG_GROSUP  := (cQryRes)->GROSUP
		EndIf
		If lProtNatPg
			NXG->NXG_CNATPG  := (cQryRes)->CNATPG
		EndIf
		If lProtEmail
			NXG->NXG_EMAIL   := (cQryRes)->EMAIL
		EndIf
		If lProtEMin
			NXG->NXG_EMLMIN  := (cQryRes)->EMLMIN
		EndIf
		If lProtImp
			NXG->NXG_PIRRF   := aPImposto[1]
			NXG->NXG_PPIS    := aPImposto[2]
			NXG->NXG_PCOFIN  := aPImposto[3]
			NXG->NXG_PCSLL   := aPImposto[4]
			NXG->NXG_PINSS   := aPImposto[5]
			NXG->NXG_PISS    := aPImposto[6]
		EndIf
		If lProtJuros // Proteção
			NXG->NXG_TXPERM :=  (cQryRes)->TXPERM
			NXG->NXG_PJUROS :=  (cQryRes)->PJUROS
			NXG->NXG_DESFIN :=  (cQryRes)->DESFIN
			NXG->NXG_DIADES :=  (cQryRes)->DIADES
			NXG->NXG_TPDESC :=  (cQryRes)->TPDESC
		EndIf
		If lProtGrsHn
			NXG->NXG_GROSHN := (cQryRes)->CGROSHN
			NXG->NXG_PERCGH := (cQryRes)->PERCGROSHN
		EndIf
		NXG->(MsUnlock())
		NXG->(DbCommit())

		// Verifica cotação
		aConvLanc := JA201FConv('01', (cQryRes)->CMOE, 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
		nVTAXA1 := aConvLanc[2] // Moeda da condição (TS)
		nVTAXA2 := aConvLanc[3] // Moeda da pré

		J201DCotac(cCodPre, (cQryRes)->CMOE, nVTAXA1, "1" )

		(cQryRes)->(DBSkip())

		aRet := {.T., "JA201CPag()" }
	EndDo

	(cQryRes)->(dbCloseArea())

Else

	DbSelectArea("NXG")
	NXG->(DbSetorder(4)) //NXG_FILIAL + NXG_CFATAD
	If NXG->(DbSeek(xFilial("NXG") + cNVVCOD))
		While NXG->NXG_FILIAL + NXG->NXG_CFATAD == xFilial("NXG") + cNVVCOD
			RecLock("NXG", .F.)
			NXG->NXG_CPREFT := cCodPre
			NXG->(MsUnlock())
			NXG->(DbCommit())
			NXG->(DBSkip())
		EndDo
		aRet := {.T., "JA201CPag()" }
	EndIf

EndIf

RestArea( aArea )

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201CEnc()
Rotina para vincular os encaminhamentos de fatura da junção, do contrato 
ou da fatura adicional na pré-fatura.

@param cCodPre  , Código da Pré-Fatura
@param cFatAdic , Código da Fatura Adicional
@param cJuncCont, Código da Junção de Contratos
@param cContr   , Código do Contrato

@return aRet    , Retorno da Rotina
                  aRet[1] - .T. - Executado com sucesso - .F. - Houve erro
                  aRet[2] - Nome da função

@author Luciano Pereira dos Santos
@since 03/12/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201CEnc(cCodPre, cFatAdic, cJuncCont, cContr)
	Local aRet        := {.F., "JA201CEnc (cCodPre, cFatAdic, cJuncCont, cContr): " + cCodPre +"-"+ cFatAdic +"-"+ cJuncCont +"-"+ cContr }
	Local cQuery      := " "
	Local aArea       := GetArea()
	Local cQryRes     := GetNextAlias()
	Local aStruct     := NVN->(DbStruct())
	Local cCampos     := ''
	Local aCampos     := {}
	Local nI          := 0
	Local xValor      := Nil

	Default cCodPre   := ""
	Default cFatAdic  := ""
	Default cJuncCont := ""
	Default cContr    := ""

	aEval( aStruct, {|a| Aadd(aCampos, a[1])} )
	aEval( aCampos, {|a, nI| cCampos += a + IIf(nI != Len(aCampos), ',', '')} )

	cQuery := " SELECT " + cCampos + " "
	cQuery +=         " FROM " + RetSqlName("NVN") + " NVN "
	cQuery +=        " WHERE NVN.NVN_FILIAL = '"+ xFilial("NVN") +"' "
	If Empty(cFatAdic)
		If !Empty(cJuncCont)
			cQuery +=  " AND NVN.NVN_CJCONT = '"+ cJuncCont +"' "
		ElseIf !Empty(cContr)
			cQuery +=  " AND NVN.NVN_CCONTR = '"+ cContr +"' "
		EndIf
	Else
		cQuery +=      " AND NVN.NVN_CFATAD = '"+ cFatAdic +"' "
	EndIf
	cQuery +=          " AND NVN.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NVN.NVN_CLIPG, NVN.NVN_LOJPG, NVN_CCONT"

	cQuery := ChangeQuery(cQuery, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->(EOF())
		RecLock("NVN", .T.)
		For nI := 1 To Len(aCampos)
			Do Case
				Case aCampos[nI] == 'NVN_CCONTR' .Or. aCampos[nI] == 'NVN_CJCONT' .Or. aCampos[nI] == 'NVN_CFATAD' // Não usar o contido $, pois o existe um campo NVN_CCONT que não pode ser limpo.
					xValor := ""
				Case aCampos[nI] == 'NVN_CPREFT'
					xValor := cCodPre
				OtherWise
					xValor := (cQryRes)->(FieldGet(FieldPos(aCampos[nI])))
			EndCase
			NVN->(FieldPut(FieldPos(aCampos[nI]), xValor))
		Next nI
		NVN->(MsUnlock())
		NVN->(DbCommit())
		(cQryRes)->(DBSkip())
	EndDo

	(cQryRes)->(dbCloseArea())
	RestArea( aArea )

	aRet := {.T., "JA201CEnc" }

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201CPerc
Rotina para retornar as porcentagens dos impostos apartir do pagador

@param cCodcli   , Cliente pagador
@param cLoja     , Loja do cliente pagador
@param cMoeda    , Moeda do cliente pagador
@param dData     , Data de emisão da Pré-Fatura
@param nValorHon , Valor de honorários do pagador (Valor de Hon + Desp. Trib) * o perc do pagador
@param cCondPag  , Condição de pagamento do pagador
@param cFilEscr  , Código da Filial do escritório de faturamento do contrato ou junção
@param aValImp   , Array para acumular os valores dos impostos

@return aPImposto, Array com alíquotas dos impostos

@author Anderson Carvalho
@since  28/06/2018
/*/
//-------------------------------------------------------------------
Function JA201CPerc(cClien, cLoja, cMoeda, dData, nValorHon, cCondPag, cFilEscr, aValImp)
Local lRet      := .F.
Local aPImposto := {0, 0, 0, 0, 0, 0}
Local nCliIR    := 0
Local cNatHon   := ""
Local cNatcli   := ""
Local aSA1      := {}
Local cProd     := SuperGetMV('MV_JPRODH' ,, '')
Local nPAliqiss := SuperGetMV('MV_ALIQISS',, 0)
Local nAliqiss  := 0
Local cCndPgInt := SuperGetMv('MV_JCPGINT',, '')
Local cCndPgNac := SuperGetMv('MV_JCPGNAC',, '')
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
Local aParcHon  := {}
Local nI        := 0

Default cClien    := ""
Default cLoja     := ""
Default cMoeda    := ""
Default dData     := ""
Default nValorHon := ""
Default cCondPag  := ""
Default cFilEscr  := ""
Default aValImp   := {0, 0, 0, 0, 0, 0}

	If Len(aSA1 := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, {'A1_NATUREZ', 'A1_ALIQIR'})) == 2
		cNatcli := aSA1[1]
		nCliIR  := aSA1[2]
	EndIf

	nAliqiss := JurGetDados('SB1', 1, xFilial('SB1') + cProd, 'B1_ALIQISS')
	nAliqiss := IIf(Empty( nAliqiss ), nPAliqiss, nAliqiss)

	cNatHon  := PadR(SuperGetMV('MV_JNATFAT',, '', cFilEscr), TamSX3('ED_CODIGO')[1])
	cNatHon  := IIf(Empty( cNatcli ), cNatHon, cNatcli)

	If Empty(cCondPag)
		If cMoeda == cMoedaNac
			cCondPag := cCndPgNac
		Else
			cCondPag := cCndPgInt
		EndIf
	EndIf

	aParcHon := Condicao(nValorHon, cCondPag,, dData)

	For nI := 1 To Len(aParcHon)
		aSE1 := {}
		aAdd(aSE1, { "E1_TIPO"   , AvKey("FT", "E1_TIPO"), Nil})
		aAdd(aSE1, { "E1_NATUREZ", cNatHon               , Nil})
		aAdd(aSE1, { "E1_CLIENTE", cClien                , Nil})
		aAdd(aSE1, { "E1_LOJA"   , cLoja                 , Nil})
		aAdd(aSE1, { "E1_MULTNAT", "2"                   , Nil})
		aAdd(aSE1, { "E1_VALOR"  , aParcHon[nI][2]       , Nil})
		aAdd(aSE1, { "E1_IRRF"   , 0                     , Nil})
		aAdd(aSE1, { "E1_ISS"    , 0                     , Nil})
		aAdd(aSE1, { "E1_INSS"   , 0                     , Nil})
		aAdd(aSE1, { "E1_PIS"    , 0                     , Nil})
		aAdd(aSE1, { "E1_COFINS" , 0                     , Nil})
		aAdd(aSE1, { "E1_CSLL"   , 0                     , Nil})
		aAdd(aSE1, { "E1_VENCTO" , aParcHon[nI][1]       , Nil})
		aAdd(aSE1, { "E1_VENCREA", aParcHon[nI][1]       , Nil})
		aAdd(aSE1, { "E1_MOEDA"  , Val(cMoeda)           , Nil})
		aAdd(aSE1, { "E1_BASEIRF", aParcHon[nI][2]       , Nil})

		//Verifica os impostos e alimenta o array aImpostos
		If !(lRet := J203VerImp(aSE1, "2", @aValImp, , cMoeda)[1])
			Exit
		EndIf
	Next nI

	If lRet
		aPImposto := JurGetDados('SED', 1, xFilial('SED') + cNatHon, {"ED_PERCIRF", "ED_PERCPIS", "ED_PERCCOF", "ED_PERCCSL", "ED_PERCINS"})

		If Len(aPImposto) == 5
			aPImposto[1] := IIf(Empty(nCliIR), aPImposto[1], nCliIR)
			aAdd(aPImposto, nAliqiss)
		Else
			aPImposto := {0, 0, 0, 0, 0, 0}
		EndIf

		aPImposto[1] := IIf(aValImp[1] > 0.00, aPImposto[1], 0) //IRRF
		aPImposto[2] := IIf(aValImp[4] > 0.00, aPImposto[2], 0) //PIS
		aPImposto[3] := IIf(aValImp[5] > 0.00, aPImposto[3], 0) //COFINS
		aPImposto[4] := IIf(aValImp[6] > 0.00, aPImposto[4], 0) //CSLL
		aPImposto[5] := IIf(aValImp[3] > 0.00, aPImposto[5], 0) //INSS
		aPImposto[6] := IIf(aValImp[2] > 0.00, aPImposto[6], 0) //ISS
	EndIf

Return (aPImposto)
