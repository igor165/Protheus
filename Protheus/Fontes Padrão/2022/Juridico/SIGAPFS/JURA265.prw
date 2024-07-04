#INCLUDE "JURA265.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

#DEFINE cLPEmiWO   "940" // Lançamento Padrão (CT5) - Emissão de WO
#DEFINE cLPCanWO   "941" // Lançamento Padrão (CT5) - Cancelamento de WO
#DEFINE cLPLanc    "942" // Lançamento Padrão (CT5) - Lançamentos
#DEFINE cLPDesdBx  "943" // Lançamento Padrão (CT5) - Desdobramentos Baixa
#DEFINE cLPDesdPP  "944" // Lançamento Padrão (CT5) - Desdobramentos Pós Pagamento
#DEFINE cLPEmiFat  "945" // Lançamento Padrão (CT5) - Emissão de Fatura
#DEFINE cLPCanFat  "946" // Lançamento Padrão (CT5) - Cancelamento de Fatura
#DEFINE cLPDesInc  "947" // Lançamento Padrão (CT5) - Desdobramentos Inclusão (Provisão)
#DEFINE cLPEstDInc "948" // Lançamento Padrão (CT5) - Estorno da Inclusão do Desdobramento
#DEFINE cLPEstDPos "949" // Lançamento Padrão (CT5) - Estorno de Desdobramento Pós Pagamento
#DEFINE cLPEstLan  "956" // Lançamento Padrão (CT5) - Estorno Lançamento
#DEFINE cLPEstDBx  "957" // Lançamento Padrão (CT5) - Estorno Desdobramento Baixa

#DEFINE cLote     LoteCont("PFS") // Lote Contábil do Lançamento, cada módulo tem o seu e está configurado na tabela 09 do SX5
#DEFINE cRotina   "JURA265"       // Rotina que está gerando o Lançamento para ser possivel fazer o posterior rastreamento
#DEFINE cFilZZZ   Replicate("Z", TamSXG("033")[1]) // Usado em filtro de filial. Ex. "ZZZZZZZZ"
#DEFINE lViaTela  !IsBlind() // Se não for execução automática

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA265
Contabilização Off-line SIGAPFS

- Emissão de WO de Despesa
- Cancelamento de WO de Despesa
- Lançamento
- Desdobramento Baixa
- Desdobramento pós pagamento
- Emissão de Fatura
- Cancelamento de Fatura
- Inclusão de Desdobramento

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA265()
Local aArea := GetArea()
Local lCanc := .F.
Local lGrvCont := .T.

	While !lCanc
		If J265Perg()
			If JP265TdOk() // Validação de dados do pergunte
				Processa( {|| lGrvCont := JA265CTB()}, STR0021, STR0020 ) // "Preparando valores para o lançamento contábil." // "Processando..."
			EndIf
		Else
			lCanc := .T.
		EndIf
	EndDo

	RestArea( aArea )

Return (lGrvCont)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265Perg
Abre o Pergunte para filtro da contabilização

@author Jorge Martins
@since  01/08/2019
/*/
//-------------------------------------------------------------------
Static Function J265Perg()
	Local lRet := .F.

	If !OHF->(ColumnPos("OHF_DTCONI")) > 0 // Proteção - Inclusão de desdobramentos
		JurMsgErro(STR0029, , STR0030) // "Dicionário de dados desatualizado!" ## "Atualize o dicionário para continuar a contabilização."
	Else
		lRet := Pergunte("JURA265")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP265TdOk
Rotina para validar os dados do pergunte

Uso no Pergunte JURA265 durante a pós validação do pergunte.

@return lRet, lógico, Indica se as informações do pergunte estão corretas.

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JP265TdOk()
Local lRet     := .T.
Local lTodos   := MV_PAR03 == 1 // Contabiliza todos os tipos de lançamentos
Local lEmiWO   := MV_PAR04 == 1 // Contabiliza Emissão de WO
Local lCanWO   := MV_PAR05 == 1 // Contabiliza Cancelamento de WO
Local lLanc    := MV_PAR06 == 1 // Contabiliza Lançamentos
Local lDesdBx  := MV_PAR07 == 1 // Contabiliza Desdobramentos Baixa
Local lDesInc  := MV_PAR08 == 1 // Contabiliza Inclusão de Desdobramentos
Local lDesdPP  := MV_PAR09 == 1 // Contabiliza Desdobramentos Pós Pagamento
Local lEmiFat  := MV_PAR10 == 1 // Contabiliza Emissão de Fatura
Local lCanFat  := MV_PAR11 == 1 // Contabiliza Cancelamento de Fatura
Local dDataFim := MV_PAR13      // Data Final
Local cFilDe   := MV_PAR14      // Filial 'De'
Local cFilAte  := MV_PAR15      // Filial 'Até'

// Valida seleção de tipo de movimento
If !lTodos .And. !lEmiWO .And. !lCanWO .And. !lLanc .And. !lDesdBx .And. !lDesInc .And. !lDesdPP .And. !lEmiFat .And. !lCanFat
	lRet := JurMsgErro(STR0016,,STR0017) // "Nenhum tipo de movimento selecionado." - "Selecione ao menos um tipo de movimento, ou a opção 'Todos'."
EndIf

// Valida data
If lRet .And. Empty(dDataFim)
	lRet := JurMsgErro(STR0001,,STR0002) // "Data final é obrigatória." - "Preencha a data para filtro."
EndIf

// Valida Filial 'de'
If lRet .And. !Empty(cFilDe) .And. !(ExistCpo("SM0", cEmpAnt + cFilDe, 1, /*Help*/, .F.))
	lRet := JurMsgErro(STR0003,,STR0004) // "Filial 'de' inválida." - "Informe uma filial válida ou deixe o campo em branco."
EndIf

// Valida Filial 'ate'
If lRet
	If Empty(cFilAte)
		lRet := JurMsgErro(STR0005,,I18N(STR0006,{cFilZZZ})) // "Filial 'até' é obrigatória." - "Informe uma filial válida ou preencha o campo com '#1'."
	ElseIf !( cFilZZZ == Upper(cFilAte) .Or. ExistCpo("SM0", cEmpAnt + cFilAte, 1, /*Help*/, .F.))
		lRet := JurMsgErro(STR0007,,I18N(STR0006,{cFilZZZ}) ) // "Filial 'até' inválida." - "Informe uma filial valida ou preencha o campo com '#1'."
	ElseIf cFilAte < cFilDe
		lRet := JurMsgErro(STR0007,,I18N(STR0006,{cFilZZZ}) ) // "Filial 'até' inválida." - "Informe uma filial valida ou preencha o campo com '#1'."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP265VldDt
Valida as datas de inicio e fim do período do filtro de contabilização
Uso no Pergunte JURA265 durante o preenchimento dos campos

@param dDataIni, data  , Data Inicial do filtro
@param dDataFim, data  , Data Final do filtro

@return lRet   , lógico, Indica se as informações de datas estão corretas.

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP265VldDt(dDataIni, dDataFim)
Local lRet := .T.

If !Empty(dDataIni) .And. !Empty(dDataFim)

	If dDataIni > dDataFim
		lRet := JurMsgErro(STR0008,,STR0009) // "Data Final deve ser maior que a inicial." - "Informe uma data válida."
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP265VldFl
Valida as filiais (de/até) do filtro de contabilização.
Uso no Pergunte JURA265 durante o preenchimento dos campos.

@param nTipo  , numérico,  Indica qual campo está sendo validado
                           1 - Filial 'de' / 2 - Filial 'até'
@param cFilDe , caractere, Filial inicial
@param cFilAte, caractere, Filial final

@return lRet  , lógico   , Indica se as informações de filiais estão corretas.

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP265VldFl(nTipo, cFilDe, cFilAte)
Local lRet    := .T.

If nTipo == 1 // Filial 'de'
	If !( Empty(cFilDe) .Or. ExistCpo("SM0", cEmpAnt + cFilDe, 1, /*Help*/, .F.) )
		lRet := JurMsgErro(STR0010,,STR0004) // "Filial inválida." - "Informe uma filial válida ou deixe o campo em branco."
	EndIf

Else // Filial 'até'
	If !( Empty(cFilAte) .Or. cFilZZZ == Upper(cFilAte) .Or. ExistCpo("SM0", cEmpAnt + cFilAte, 1, /*Help*/, .F.) )
		lRet := JurMsgErro(STR0010,,I18N(STR0006,{cFilZZZ}) ) // "Filial inválida." - "Informe uma filial válida ou preencha o campo com '#1'."
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA265CTB
Contabilização dos registros

@return lRet, lógico, Indica se a contabilização foi efetuada.

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA265CTB()
Local aLPs       := {} // Array com LPs para contabilização
Local nLPs       := 0
Local nI         := 0
Local cCodLP     := ""
Local cChave     := "JA265CTB_"+DTOS(DATE())
Local cFilBckp   := cFilAnt
Local cFilDe     := MV_PAR14 // Filial 'De'
Local cFilAte    := MV_PAR15 // Filial 'Ate'
Local lFiltraFil := !(Empty(cFilDe) .And. cFilZZZ == Upper(cFilAte))
Local aRetFil    := {}
Local nX         := 0
Local cFilSemLP  := ""
Local cSql       := ""

If !LockByName( cChave, .T., .T. )
	JurMsgErro(STR0031) // "Outro usuário está usando a rotina. Tente novamente mais tarde."
Else
	// Query para processamento de Filiais do Escritório
	cSql :=   "SELECT DISTINCT NS7_CFILIA "
	cSql +=    " FROM " + RetSqlName("NS7")
	cSql +=   " WHERE D_E_L_E_T_= ' ' "
	cSql +=     " AND NS7_CEMP = '" + cEmpAnt + "' "
	cSql +=     " AND NS7_FILIAL = '" + xFilial("NS7") + "' "
	If lFiltraFil
		cSql += " AND NS7_CFILIA BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	EndIf
	aRetFil := JurSql(cSql, "NS7_CFILIA")

	For nX := 1 to Len(aRetFil)

		If !Empty(aRetFil[nX, 01])
			cFilAnt := aRetFil[nX, 01]
			aLPs    := JA265ALPs() // Array com LPs para contabilização
			nLPs    := Len(aLPs)

			If nLPs > 0

				For nI := 1 To nLPs
					cCodLP := aLPs[nI]

					// Prepara as linhas de detalhes dos movimentos para a contabilização.
					Do Case
						Case cCodLP == cLPEmiWO .Or. ; // Emissão de WO de Despesa ou
						     cCodLP == cLPCanWO        // Cancelamento de WO de Despesa
							J265DetWO(cCodLP, aRetFil[nX, 01], AllTrim(aRetFil[nX, 01]) == AllTrim(cFilBckp))
						
						Case cCodLP == cLPLanc   .Or. ; // Lançamentos
						     cCodLP == cLPDesdBx .Or. ; // Baixa de Desdobramentos
						     cCodLP == cLPDesInc .Or. ; // Inclusão de Desdobramentos
						     cCodLP == cLPDesdPP        // Desdobramentos pós pagamento
							J265DetLan(cCodLP, aRetFil[nX, 01])
						
						Case cCodLP == cLPEmiFat .Or. ; // Emissão de Fatura
						     cCodLP == cLPCanFat        // Cancelamento de Fatura
							JDetFatura(cCodLP, aRetFil[nX, 01])
					EndCase
				Next
			Else
				cFilSemLP += "," + cFilAnt
			EndIf
		EndIf
	Next nX
	cFilAnt := cFilBckp
	UnLockByName(cChave, .T., .T.)

	If !Empty(cFilSemLP)
		JurMsgErro(I18N(STR0032, {Right(cFilSemLP, Len(cFilSemLP)-1)}), , STR0019) // "Não existem lançamentos padronizados para a execução na(s) filial(ais): #1." ### "Verifique os LPs 940, 941, 942, 943, 944, 945, 946 e 947."
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA265ALPs
Monta array com os tipos de lançamentos que serão contabilizados

@return aLPs, array, Array com código dos LPs para contabilização

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA265ALPs()
Local lTodos  := (MV_PAR03 == 1)                 // Contabiliza todos os tipos de lançamentos
Local lEmiWO  := IIf(lTodos, .T., MV_PAR04 == 1) // Contabiliza Emissão de WO
Local lCanWO  := IIf(lTodos, .T., MV_PAR05 == 1) // Contabiliza Cancelamento de WO
Local lLanc   := IIf(lTodos, .T., MV_PAR06 == 1) // Contabiliza Lançamentos
Local lDesdBx := IIf(lTodos, .T., MV_PAR07 == 1) // Contabiliza Desdobramentos Baixa
Local lDesInc := IIf(lTodos, .T., MV_PAR08 == 1) // Contabiliza Inclusão de Desdobramentos
Local lDesdPP := IIf(lTodos, .T., MV_PAR09 == 1) // Contabiliza Desdobramentos Pós Pagamento
Local lEmiFat := IIf(lTodos, .T., MV_PAR10 == 1) // Contabiliza Emissão de Fatura
Local lCanFat := IIf(lTodos, .T., MV_PAR11 == 1) // Contabiliza Cancelamento de Fatura
Local aLPs    := {}

// Verifica flag dos tipos de lançamento no pergunte e caso exista o LP para a rotina, adiciona no array de controle para contabilização
IIf(lEmiWO  .And. VerPadrao(cLPEmiWO ), aAdd(aLPs, cLPEmiWO ), Nil)
IIf(lCanWO  .And. VerPadrao(cLPCanWO ), aAdd(aLPs, cLPCanWO ), Nil)
IIf(lLanc   .And. VerPadrao(cLPLanc  ), aAdd(aLPs, cLPLanc  ), Nil)
IIf(lDesdBx  .And. VerPadrao(cLPDesdBx), aAdd(aLPs, cLPDesdBx), Nil)
IIf(lDesInc  .And. VerPadrao(cLPDesInc), aAdd(aLPs, cLPDesInc), Nil)
IIf(lDesdPP .And. VerPadrao(cLPDesdPP), aAdd(aLPs, cLPDesdPP), Nil)
IIf(lEmiFat .And. VerPadrao(cLPEmiFat), aAdd(aLPs, cLPEmiFat), Nil)
IIf(lCanFat .And. VerPadrao(cLPCanFat), aAdd(aLPs, cLPCanFat), Nil)

Return aLPs

//-------------------------------------------------------------------
/*/{Protheus.doc} J265DetWO
Prepara as linhas de detalhes de WO (Emissão e Cancelamento)
para a contabilização.

@param cCodLP  , caractere, Indica o Lançamento padrão a ser detalhado 
                            (Emissão de WO ou Cancelamento de WO )
@param cFilProc, caractere, Indica a Filial que está sendo processada
@param lFiltVz , Lógica   , Indica que deve ser filtrada a filial vazia
                            (esta processando a filial corrente)
@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265DetWO(cCodLP, cFilProc, lFiltVz)
Local aArea      := GetArea()
Local aAreaNUF   := NUF->(GetArea())
Local aAreaNWZ   := NWZ->(GetArea())
Local lNWZFilLan := NVY->(ColumnPos("NVY_FILLAN")) > 0 .And. NWZ->(ColumnPos("NWZ_FILLAN")) > 0
Local cQuery     := J265QryWO(cCodLP, cFilProc, lNWZFilLan, lFiltVz) // Query que indica os registros para contabilização
Local nRecnoNUF  := 0
Local nRecnoNWZ  := 0
Local nQtdReg    := 0
Local nCount     := 0
Local cCpoFlag   := J265LpFlag(cCodLP, lNWZFilLan)
Local cTexto     := IIf(cCodLP == cLPEmiWO, STR0022, STR0023) // "Emissão de WO - #1 de #2." / "Cancelamento de WO - #1 de #2."
Local cQryRes    := GetNextAlias()
Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0
Local aFlagCTB   := {}
Local dDataCont  := dDataBase

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)

	If lViaTela
		dbSelectArea( cQryRes )
		Count To nQtdReg // Conta a quantidade de registros
		(cQryRes)->(DbGoTop())
		ProcRegua(nQtdReg)
	EndIf

	dbSelectArea("NWZ")
	dbSelectArea("NUF")

	While !(cQryRes)->(EOF())

		If lViaTela
			nCount++
			IncProc( I18n(cTexto,{cValToChar(nCount),cValToChar(nQtdReg)}) )
		EndIf

		If nHdlPrv == 0
			nHdlPrv := HeadProva(cLote, cRotina, Substr(cUsername,1,6), @cArquivo)
		EndIf

		nRecnoNUF  := (cQryRes)->RECNONUF
		nRecnoNWZ  := (cQryRes)->RECNONWZ

		// Posiciona as tabelas necessárias para execução dos lançamentos padrão
		NUF->(dbGoto( nRecnoNUF ))
		NWZ->(dbGoto( nRecnoNWZ ))

		dDataCont := StoD((cQryRes)->DATACONTAB)

		If !lNWZFilLan
			aAdd(aFlagCTB, {cCpoFlag, dDataCont, "NUF", nRecnoNUF, 0, 0, 0})
		Else
			aAdd(aFlagCTB, {"NUF" + SubStr(cCpoFlag, 4), dDataCont, "NUF", nRecnoNUF, 0, 0, 0})
			aAdd(aFlagCTB, {"NWZ" + SubStr(cCpoFlag, 4), dDataCont, "NWZ", nRecnoNWZ, 0, 0, 0})
		EndIf

		// Acumula valores para o Lancto Contábil
		If nHdlPrv > 0
			nTotal += DetProva(nHdlPrv, cCodLP, cRotina, cLote)
		EndIf

		(cQryRes)->(DbSkip())

		// Executa contabilização
		J265RunCtb(@nHdlPrv, @nTotal, @cArquivo, @aFlagCTB, dDataCont)

	EndDo

	(cQryRes)->(DbCloseArea())

	If nTotal > 0
		ApMsgInfo(STR0013) // "contabilização realizada com sucesso."
	EndIf

	RestArea(aAreaNUF)
	RestArea(aAreaNWZ)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J265QryWO
Gera a Query de detalhes de WO (Emissão e Cancelamento) para 
contabilização.

@param cCodLP     , caractere, Indica o Lançamento padrão a ser detalhado 
                              (Emissão de WO ou Cancelamento de WO )
@param cFilProc  , caractere, Indica a Filial de Processamento
@param lNWZFilLan, lógico   , Utiliza os novos campos da contabilização de WO
@param lFiltVz   , Lógica   , Indica que deve ser filtrada a filial vazia
                              (esta processando a filial corrente)

@return cQuery , caractere, Query que indica os registros para contabilização

@author Jorge Martins
@since 22/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265QryWO(cCodLP, cFilProc, lNWZFilLan, lFiltVz)
Local cQuery     := ""
Local cDataIni   := IIf( Empty(MV_PAR12), "19000101", DtoS(MV_PAR12) )
Local cDataFim   := DtoS(MV_PAR13)
Local cCpoDtCont := J265LpData(cCodLP)


	cQuery :=      " SELECT NUF.R_E_C_N_O_ RECNONUF, NWZ.R_E_C_N_O_ RECNONWZ, " + cCpoDtCont + " DATACONTAB"
	cQuery +=        " FROM " + RetSqlname('NUF', cFilProc) + " NUF "
	cQuery +=       " INNER JOIN " + RetSqlname('NWZ') + " NWZ "
	cQuery +=          " ON ( NWZ.NWZ_FILIAL = '" + xFilial("NWZ") + "' "
	cQuery +=         " AND NWZ.NWZ_CODWO  = NUF.NUF_COD "
	cQuery +=         " AND NWZ.D_E_L_E_T_ = ' ' ) "

	If !lNWZFilLan
		cQuery +=   " WHERE NUF.NUF_FILIAL = '" + xFilial("NUF", cFilProc) + "' "
		If cCodLP == cLPEmiWO // Emissão de WO
			cQuery += " AND NUF.NUF_DTCEMI = '" + Space(TamSx3('NUF_DTCEMI')[1]) + "' " // Filtra pela data de contabilização em branco
			cQuery += " AND NUF.NUF_DTEMI BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
		Else // Cancelamento de WO
			cQuery += " AND NUF.NUF_DTCCAN = '" + Space(TamSx3('NUF_DTCCAN')[1]) + "' " // Filtra pela data de contabilização em branco
			cQuery += " AND NUF.NUF_DTCAN BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
		EndIf
	Else
		cQuery +=   " WHERE ( NWZ.NWZ_FILLAN = '" + cFilProc + "'" + IIF(!lFiltVz, "", " OR NWZ.NWZ_FILLAN = '" + xFilial("NWZ", cFilProc) + "'") + " )"
		If cCodLP == cLPEmiWO // Emissão de WO
			cQuery += " AND ( NWZ.NWZ_DTCEMI = '" + Space(TamSx3('NWZ_DTCEMI')[1]) + "' OR NUF.NUF_DTCEMI = '" + Space(TamSx3('NUF_DTCEMI')[1]) + "' ) " // Filtra pela data de contabilização em branco
			cQuery += " AND NUF.NUF_DTEMI BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
		Else // Cancelamento de WO
			cQuery += " AND ( NWZ.NWZ_DTCCAN = '" + Space(TamSx3('NWZ_DTCCAN')[1]) + "' OR NUF.NUF_DTCCAN = '" + Space(TamSx3('NUF_DTCCAN')[1]) + "' ) " // Filtra pela data de contabilização em branco
			cQuery += " AND NUF.NUF_DTCAN BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
		EndIf
	EndIf
	cQuery +=         " AND NUF.D_E_L_E_T_ = ' ' "
	cQuery +=       " ORDER BY " + cCpoDtCont
	cQuery  := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J265DetLan
Prepara as linhas de detalhes de Lançamentos, Desdobramentos 
e Desdobramentos pós pagamento para a contabilização.

@param cCodLP  , caractere, Indica o Lançamento padrão a ser detalhado 
                            (Emissão de WO ou Cancelamento de WO )
@param cFilProc, caractere, Indica a Filial de Processamento

@return nTotal , numérico, Variável totalizadora da contabilização 
                           atualizada

@author Jorge Martins
@since  04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265DetLan(cCodLP, cFilProc)
Local aAreas     := {OHB->(GetArea()), SE2->(GetArea()), FK7->(GetArea()), SA2->(GetArea()), SED->(GetArea()), GetArea()}
Local cQryRes    := GetNextAlias()
Local cQuery     := ""
Local cTab       := ""
Local cTexto     := ""
Local cCpoFlag   := J265LpFlag(cCodLP, .F.)
Local nRecnoTab  := 0
Local nQtdReg    := 0
Local nCount     := 0
Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0
Local aFlagCTB   := {}
Local dDataCont  := dDataBase
Local cCodLPCtb  := cCodLP

Do Case
	Case cCodLP == cLPLanc   // Lançamentos
		cTab    := "OHB"
		cTexto  := STR0024 //"Lançamentos - #1 de #2."
		cQuery := J265QryLan(cCodLP, cFilProc) // Query que indica os registros para contabilização
		DbSelectArea("SED")
	
	Case cCodLP == cLPDesdBx .Or. cCodLP == cLPDesInc  // Desdobramentos Baixa ### Inclusão de Desdobramentos
		cTab    := "OHF"
		cTexto  := STR0025 // "Desdobramentos - #1 de #2."
		cQuery := J265QryDes(cCodLP, cFilProc) // Query que indica os registros para contabilização
		dbSelectArea("SE2")
		dbSelectArea("FK7")
		DbSelectArea("SA2")
		DbSelectArea("SED")

	Case cCodLP == cLPDesdPP // Desdobramentos pós pagamento
		cTab    := "OHG"
		cTexto  := STR0026 //"Desdobramentos pós pagamento - #1 de #2."
		cQuery := J265QryDPP(cCodLP, cFilProc) // Query que indica os registros para contabilização
		DbSelectArea("SE2")
		DbSelectArea("FK7")
		DbSelectArea("SA2")
		DbSelectArea("SED")
		DbSelectArea("OHB")
End Case

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)

If lViaTela
	dbSelectArea( cQryRes )
	Count To nQtdReg // Conta a quantidade de registros
	(cQryRes)->(DbGoTop())
	ProcRegua(nQtdReg)
EndIf

dbSelectArea(cTab)

While !(cQryRes)->(EOF())
	If lViaTela
		nCount++
		IncProc( I18n(cTexto,{cValToChar(nCount),cValToChar(nQtdReg)}) )
	EndIf

	If nHdlPrv == 0
		nHdlPrv := HeadProva(cLote, cRotina, Substr(cUsername,1,6), @cArquivo)
	EndIf

	nRecnoTab  := (cQryRes)->RECNOTAB
	dDataCont := StoD((cQryRes)->DATACONTAB)

	If cTab == "OHF" .Or. cTab == "OHG"
		SE2->(DbGoto( (cQryRes)->RECNOSE2 )) // Título a pagar
		FK7->(DbGoto( (cQryRes)->RECNOFK7 )) // Chave do título a pagar
		SA2->(DbGoto( (cQryRes)->RECNOSA2 )) // Fornecedor do título
	EndIf	
	SED->(DbGoto( (cQryRes)->RECNOSED )) // Natureza
	
	(cTab)->(dbGoto( nRecnoTab ))

	aAdd(aFlagCTB, { cCpoFlag, dDataCont, cTab, nRecnoTab, 0, 0, 0 })

	Do Case
		Case cCodLP == cLPDesdBx .And. (cQryRes)->VALOR < 0 // "943" Desdobramento Baixa
			cCodLPCtb := cLPEstDBx                          // "957" Estorno Desdobramento Baixa
		Case cCodLP == cLPDesInc .And. (cQryRes)->VALOR < 0 // "947" Inclusão de Desdobramento
			cCodLPCtb := cLPEstDInc                         // "948" Estorno de Inclusão de Desdobramento
		Case cCodLP == cLPDesdPP .And. (cQryRes)->VALOR < 0 // "944"  Desdobramento Pós Pagamento
			cCodLPCtb := cLPEstDPos                         // "949" Estorno de Desdobramento Pós Pagamento
		OtherWise
			cCodLPCtb := cCodLP
	EndCase


	// Acumula valores para o Lancto Contábil
	If nHdlPrv > 0
		nTotal += DetProva(nHdlPrv, cCodLPCtb, cRotina, cLote)
	EndIf

	(cQryRes)->(DbSkip())

	// Executa contabilização por data
	J265RunCtb(nHdlPrv, nTotal, cArquivo, aFlagCTB, dDataCont)
EndDo

(cQryRes)->(DbCloseArea())

AEVal(aAreas, {|aArea| RestArea(aArea)})
JurFreeArr(aAreas)

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} J265QryLan
Gera a Query de detalhes de Lançamentos para contabilização.

@param cCodLP  , caractere, Código do lançamento padrão
@param cFilProc, caractere, Filial de Processamento

@return cQuery , caractere, Query que indica os registros para contabilização

@author Jorge Martins
@since  04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265QryLan(cCodLP, cFilProc)
Local cQuery     := ""
Local cDataIni   := IIf( Empty(MV_PAR12), "19000101", DtoS(MV_PAR12) )
Local cDataFim   := DtoS(MV_PAR13)
Local cCpoDtCont := J265LpData(cCodLP)

cQuery := " SELECT OHB.R_E_C_N_O_ RECNOTAB, SED.R_E_C_N_O_ RECNOSED, " + cCpoDtCont + " DATACONTAB, OHB.OHB_VALOR VALOR "
cQuery +=   " FROM " + RetSqlname('OHB') + " OHB "
cQuery +=  " INNER JOIN " + RetSqlname('SED') + " SED "
cQuery +=     " ON ( SED.ED_FILIAL = '" + xFilial('SED', cFilProc) + "' "
cQuery +=    " AND SED.ED_CODIGO = OHB.OHB_NATORI "
cQuery +=    " AND SED.D_E_L_E_T_ = ' ' ) "
cQuery +=  " WHERE OHB.OHB_FILIAL = '" + cFilProc + "'" // OHB sempre será exclusiva
cQuery +=    " AND OHB.OHB_DTCONT = '" + Space(TamSx3('OHB_DTCONT')[1]) + "' " // Filtra pela data de contabilização em branco
cQuery +=    " AND OHB.OHB_DTLANC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery +=    " AND OHB.D_E_L_E_T_ = ' ' "
cQuery +=  " ORDER BY OHB." + cCpoDtCont

cQuery  := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J265QryDes
Gera a Query de detalhes de Desdobramentos para contabilização.

@param cCodLP  , caractere, Código do lançamento padrão de desdobramento ou 
                            inclusÃ£o de desdobramento.
@param cFilProc, caractere, Filial de Processamento

@return cQuery , caractere, Query que indica os registros para contabilização

@author Jorge Martins
@since  05/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265QryDes(cCodLP, cFilProc)
Local cQuery     := ""
Local cDataIni   := IIf( Empty(MV_PAR12), "19000101", DtoS(MV_PAR12) )
Local cDataFim   := DtoS(MV_PAR13)
Local cDataVazia := Space(TamSx3('OHF_DTCONT')[1])
Local cCpoDtCont := J265LpData(cCodLP)
Local cNTransPag := JurBusNat("7") // Natureza cujo tipo é o 7-Transitória de Pagamento
Local lBaixaDes  := cCodLP == cLPDesdBx // 943 - Baixa Desdobramento 

cQuery :=  " SELECT OHF.R_E_C_N_O_ RECNOTAB, SE2.R_E_C_N_O_ RECNOSE2, FK7.R_E_C_N_O_ RECNOFK7, SA2.R_E_C_N_O_ RECNOSA2, SED.R_E_C_N_O_ RECNOSED, " + cCpoDtCont + " DATACONTAB, OHF.OHF_VALOR VALOR "
cQuery +=    " FROM " + RetSqlname('SE2') + " SE2 "
cQuery +=   " INNER JOIN " + RetSqlname('SA2') + " SA2 "
cQuery +=      " ON ( SA2.A2_FILIAL = '" + xFilial('SA2', cFilProc) + "' "
cQuery +=     " AND SA2.A2_COD = SE2.E2_FORNECE "
cQuery +=     " AND SA2.A2_LOJA = SE2.E2_LOJA "
cQuery +=     " AND SA2.D_E_L_E_T_ = ' ' ) "
cQuery +=   " INNER JOIN " + RetSqlname('FK7') + " FK7 "
cQuery +=      " ON ( FK7.FK7_FILIAL = SE2.E2_FILIAL "
cQuery +=     " AND SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA = FK7.FK7_CHAVE "
cQuery +=     " AND FK7.D_E_L_E_T_ = ' ' ) "
cQuery +=   " INNER JOIN " + RetSqlname('OHF') + " OHF "
cQuery +=      " ON ( OHF.OHF_FILIAL = SE2.E2_FILIAL "
cQuery +=     " AND FK7.FK7_IDDOC = OHF.OHF_IDDOC "
If lBaixaDes // 943 - Desdobramento Baixa
	cQuery += " AND OHF.OHF_DTCONT = '" + cDataVazia + "' "
Else // 947 - Inclusão de Desdobramento
	cQuery += " AND OHF.OHF_DTCONI = '" + cDataVazia + "' "
	cQuery += " AND OHF.OHF_DTINCL BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
EndIf
cQuery +=     " AND OHF.D_E_L_E_T_ = ' ' ) "
cQuery +=   " INNER JOIN " + RetSqlname('SED') + " SED "
cQuery +=      " ON ( SED.ED_FILIAL = '" + xFilial('SED', cFilProc) + "' "
cQuery +=     " AND SED.ED_CODIGO = OHF.OHF_CNATUR "
cQuery +=     " AND SED.D_E_L_E_T_ = ' ' ) "
cQuery +=   " WHERE  SE2.E2_FILIAL = '" + xFilial("SE2", cFilProc) + "' "
If lBaixaDes // 943 - Desdobramento Baixa
	cQuery += " AND SE2.E2_VALOR <> SE2.E2_SALDO "
	cQuery += " AND SE2.E2_BAIXA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'  "
EndIf
cQuery +=     " AND SE2.E2_NATUREZ = '" + cNTransPag + "' " // Natureza cujo tipo é o 7-Transitória de Pagamento
cQuery +=     " AND SE2.D_E_L_E_T_ = ' ' "
cQuery +=   " ORDER BY " + cCpoDtCont

cQuery  := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J265QryDPP
Gera a Query de detalhes de desdobramentos pós pagamento para contabilização.

@param cCodLP  , caractere, Código do lançamento padrão
@param cFilProc, caractere, Filial de Processamento

@return cQuery , caractere, Query que indica os registros para contabilização

@author Jorge Martins
@since  05/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265QryDPP(cCodLP, cFilProc)
Local cQuery     := ""
Local cDataIni   := IIf( Empty(MV_PAR12), "19000101", DtoS(MV_PAR12) )
Local cDataFim   := DtoS(MV_PAR13)
Local cCpoDtCont := J265LpData(cCodLP)
Local cNTrans    := JurBusNat("7") // Natureza cujo tipo é o 6-Transitória Pós Pagamento

cQuery := " SELECT OHG.R_E_C_N_O_ RECNOTAB, SE2.R_E_C_N_O_ RECNOSE2, FK7.R_E_C_N_O_ RECNOFK7, SA2.R_E_C_N_O_ RECNOSA2, SED.R_E_C_N_O_ RECNOSED, " + cCpoDtCont + " DATACONTAB, OHG.OHG_VALOR VALOR "
cQuery +=   " FROM " + RetSqlname('OHG') + " OHG "
cQuery +=  " INNER JOIN " + RetSqlname('FK7') + " FK7 "
cQuery +=     " ON ( FK7.FK7_FILIAL = OHG.OHG_FILIAL "
cQuery +=    " AND FK7.FK7_IDDOC = OHG.OHG_IDDOC "
cQuery +=    " AND FK7.D_E_L_E_T_ = ' ' ) "
cQuery +=  " INNER JOIN " + RetSqlname('SE2') + " SE2 "
cQuery +=     " ON ( SE2.E2_FILIAL = FK7.FK7_FILIAL "
cQuery +=    " AND SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA = FK7.FK7_CHAVE "
cQuery +=    " AND SE2.E2_NATUREZ = '" + cNTrans + "' " // Natureza cujo tipo é o 7-Transitória de Pagamento
cQuery +=    " AND SE2.D_E_L_E_T_ = ' ' ) "
cQuery +=  " INNER JOIN " + RetSqlname('SA2') + " SA2 "
cQuery +=     " ON ( SA2.A2_FILIAL = '" + xFilial('SA2', cFilProc) + "' "
cQuery +=    " AND SA2.A2_COD = SE2.E2_FORNECE "
cQuery +=    " AND SA2.A2_LOJA = SE2.E2_LOJA "
cQuery +=    " AND SA2.D_E_L_E_T_ = ' ' ) "
cQuery +=  " INNER JOIN " + RetSqlname('SED') + " SED "
cQuery +=     " ON ( SED.ED_FILIAL = '" + xFilial('SED', cFilProc) + "' "
cQuery +=    " AND SED.ED_CODIGO = OHG.OHG_CNATUR "
cQuery +=    " AND SED.D_E_L_E_T_ = ' ' ) "
cQuery +=  " WHERE  OHG.OHG_FILIAL = '" + cFilProc + "'  " // OHG sempre será exclusiva
cQuery +=    " AND OHG.OHG_DTCONT = '" + Space(TamSx3('OHG_DTCONT')[1]) + "' " // Filtra pela data de contabilização em branco
cQuery +=    " AND OHG.OHG_DTINCL BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'  "
cQuery +=    " AND OHG.D_E_L_E_T_ = ' ' "
cQuery +=  " ORDER BY " + cCpoDtCont

cQuery  := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JDetFatura
Prepara as linhas de faturas para a contabilização.

@param cCodLP  , caractere, Indica o Lançamento padrão a ser detalhado 
                            (Emissão de Fatura ou Cancelamento de Fatura )
@param cFilProc, caractere, Indica a filial de processa

@author Abner Fogaça
@since 05/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDetFatura(cCodLP, cFilProc)
Local aArea      := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local cQuery     := J265QryFat(cCodLP, cFilProc) // Query que indica os registros para contabilização
Local nRecnoNXA  := 0
Local nQtdReg    := 0
Local nCount     := 0
Local cCpoFlag   := J265LpFlag(cCodLP, .F.)
Local cTexto     := IIf(cCodLP == cLPEmiFat, STR0027, STR0028) // "Emissão de fatura - #1 de #2." / "Cancelamento de fatura - #1 de #2."
Local cQryRes    := GetNextAlias()

Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0
Local aFlagCTB   := {}
Local dDataCont  := dDataBase

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)

If lViaTela
	dbSelectArea( cQryRes )
	Count To nQtdReg // Conta a quantidade de registros
	(cQryRes)->(DbGoTop())
	ProcRegua(nQtdReg)
EndIf

dbSelectArea("NXA")
DbSelectArea("SA1")

While !(cQryRes)->(EOF())

	If lViaTela
		nCount++
		IncProc( I18n(cTexto,{cValToChar(nCount),cValToChar(nQtdReg)}) )
	EndIf

	If nHdlPrv == 0
		nHdlPrv := HeadProva(cLote, cRotina, Substr(cUsername,1,6), @cArquivo)
	EndIf

	nRecnoNXA  := (cQryRes)->RECNONXA
	
	// Posiciona as tabelas necessárias para execução dos lançamentos padrão
	NXA->(dbGoto( nRecnoNXA ))
	SA1->(DbGoto( (cQryRes)->RECNOSA1 ))

	dDataCont := StoD((cQryRes)->DATACONTAB)
	
	aAdd(aFlagCTB, { cCpoFlag, dDataCont, "NXA", nRecnoNXA, 0, 0, 0 } )

	// Acumula valores para o Lancto Contábil
	If nHdlPrv > 0
		nTotal += DetProva(nHdlPrv, cCodLP, cRotina, cLote)
	EndIf

	(cQryRes)->(DbSkip())

	// Executa contabilização por data
	J265RunCtb(nHdlPrv, nTotal, cArquivo, aFlagCTB, dDataCont)

EndDo

(cQryRes)->(DbCloseArea())

RestArea( aAreaSA1 )
RestArea( aArea )

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} J265QryFat
Gera a Query de faturas para contabilização.

@param cCodLP  , caractere, Indica o Lançamento padrão a ser detalhado 
                            (Emissão de Fatura ou Cancelamento de Fatura )
@param cFilProc, caractere, Indica a Filial de Processamento

@return cQuery , caractere, Query que indica os registros para contabilização

@author Abner Fogaça
@since 05/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J265QryFat(cCodLP, cFilProc)
Local cQuery     := ""
Local cDataIni   := IIf( Empty(MV_PAR12), "19000101", DtoS(MV_PAR12) )
Local cDataFim   := DtoS(MV_PAR13)
Local cCpoDtCont := J265LpData(cCodLP)

cQuery :=  " SELECT NXA.R_E_C_N_O_ RECNONXA, SA1.R_E_C_N_O_ RECNOSA1, " + cCpoDtCont + " DATACONTAB "
cQuery +=    " FROM " + RetSqlname('NXA') + " NXA "
cQuery +=   " INNER JOIN " + RetSqlname('NS7') + " NS7 "
cQuery +=      " ON ( NS7.NS7_FILIAL = '" + xFilial('NS7', cFilProc) + "' "
cQuery +=     " AND NS7.NS7_COD = NXA.NXA_CESCR"
cQuery +=     " AND NS7.NS7_CFILIA = '" + cFilProc + "' "
cQuery +=     " AND NS7.NS7_CEMP = '" + cEmpAnt + "' "
cQuery +=     " AND NS7.D_E_L_E_T_ = ' ' ) "
cQuery +=   " INNER JOIN " + RetSqlname('SA1') + " SA1 "
cQuery +=      " ON ( SA1.A1_FILIAL = '" + xFilial('SA1', cFilProc) + "' "
cQuery +=     " AND SA1.A1_COD = NXA.NXA_CLIPG "
cQuery +=     " AND SA1.A1_LOJA = NXA.NXA_LOJPG "
cQuery +=     " AND SA1.D_E_L_E_T_ = ' ' ) "
cQuery +=   " WHERE NXA.NXA_TIPO = 'FT' "
If cCodLP == cLPEmiFat // 945 - Emissão de Fatura
	cQuery += " AND NXA.NXA_DTCEMI = '" + Space(TamSx3('NXA_DTCEMI')[1]) + "' "
	cQuery += " AND NXA.NXA_DTEMI BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Else // 946 - Cancelamento de Fatura
	cQuery += " AND NXA.NXA_SITUAC = '2' "
	cQuery += " AND NXA.NXA_DTCCAN = '" + Space(TamSx3('NXA_DTCCAN')[1]) + "' "
	cQuery += " AND NXA.NXA_DTCANC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
EndIf
cQuery +=     " AND NXA.D_E_L_E_T_ = ' ' "
cQuery +=   " ORDER BY " + cCpoDtCont

cQuery  := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J265LpFlag
Indica o campo de data/flag de contabilização que deve ser ajustado na 
contabilização.

@param cCodLP    , Código do lançamento padrão
@param lCpoNWZ   , Indica se já existem os campos novos da NWZ
                   (NWZ_FILLAN, NWZ_DTCEMI, NWZ_DTCCAN)

@return cCpoFlag , Campo de data da contabilização considerando o LP

@author Abner Fogaça / Cristina Cintra
@since 05/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J265LpFlag(cCodLP, lCpoNWZ)
Local cCpoFlag  := ""
Local lCancCTB  := FWIsInCallStack("CT2ClearLA") // Cancelamento da Contabilização

Default cCodLP  := ""
Default lCpoNWZ := NVY->(ColumnPos("NVY_FILLAN")) > 0 .And. NWZ->(ColumnPos("NWZ_FILLAN")) > 0

	If !Empty(cCodLP)
		If cCodLP == "940" // Emissão WO
			cCpoFlag := IIf(!lCpoNWZ .Or. (lCancCTB .And. CV3->CV3_TABORI == "NUF"), "NUF_DTCEMI", "NWZ_DTCEMI")
		ElseIf cCodLP == "941" // Cancelamento WO
			cCpoFlag := IIf(!lCpoNWZ .Or. (lCancCTB .And. CV3->CV3_TABORI == "NUF"), "NUF_DTCCAN", "NWZ_DTCCAN")
		ElseIf cCodLP == "942" .Or. cCodLP == "956" // Lançamentos ### Estorno Lançamento
			cCpoFlag := "OHB_DTCONT"
		ElseIf cCodLP == "943" .Or. cCodLP == "957" // Desdobramento Baixa ### Estorno Desdobramento Baixa
			cCpoFlag := "OHF_DTCONT"
		ElseIf cCodLP == "944" .Or. cCodLP == "949" // Desdobramento Pós Pagamento ### Estorno de desdobramento Pós Pagamento
			cCpoFlag := "OHG_DTCONT"
		ElseIf cCodLP == "945" // Emissão de Fatura
			cCpoFlag := "NXA_DTCEMI"
		ElseIf cCodLP == "946" // Cancelamento de Fatura
			cCpoFlag := "NXA_DTCCAN"
		ElseIf cCodLP == "947" .Or. cCodLP == "948" // Inclusão de Desdobramento ### Estorno da Inclusão do Desdobramento
			cCpoFlag := "OHF_DTCONI"
		EndIf
	EndIf

Return cCpoFlag

//-------------------------------------------------------------------
/*/{Protheus.doc} J265LpTab
Retorna a tabela de origem com base no lançamento padrão

@param cCodLP    , caractere, Código do lançamento padrão

@return cTabOrigem, caractere, Tabela de origem

@author Jonatas Martins
@since  11/10/2019
@Obs    Função utilizada no fonte CTBXCTB e JURA265B
/*/
//-------------------------------------------------------------------
Function J265LpTab(cLPadrao)
Local cTabOrigem := ""
Local lCpoNWZ    := NVY->(ColumnPos("NVY_FILLAN")) > 0 .And. NWZ->(ColumnPos("NWZ_FILLAN")) > 0

Default cLP      := ""

	Do Case
		Case cLPadrao == "940" .Or. cLPadrao == "941" // WO
			cTabOrigem := IIf(lCpoNWZ, "NWZ", "NUF")
		
		Case cLPadrao == "942" .Or. cLPadrao == "956" // Lançamento ### Estorno Lançamento
			cTabOrigem := "OHB"
		
		Case cLPadrao == "943" .Or.; // Desdobramento Baixa
		     cLPadrao == "947" .Or.; // Inclusão de Desdobramento
		     cLPadrao == "948" .Or.; // Estorno de Inclusão de Desdobramento
		     cLPadrao == "957"       // Estorno Desdobramento Baixa
			cTabOrigem := "OHF"

		Case cLPadrao == "944" .Or. cLPadrao == "949" // Desdobramento Pós Pagamento ### Estorno de Desdobramento Pós Pagamento
			cTabOrigem := "OHG"

		Case cLPadrao == "945" .Or. cLPadrao == "946" // Fatura
			cTabOrigem := "NXA"
	End Case

Return (cTabOrigem)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265LpData
Retorna qual o campo de data a ser considerado para contabilização CT2_DATA.
Esse campo não é o campo de flag.

@param cCodLP    , caractere, Código do lançamento padrão

@return cCpoData , caractere, Campo de data da contabilização considerando o LP

@author Jonatas Martins
@since  11/10/2019
@Obs    LP's de estorno 948 e 949 utilizam dDataBase por isso não possuem campo de data
/*/
//-------------------------------------------------------------------
Function J265LpData(cCodLP)
	Local cCpoData := ""

	Default cCodLP := ""

	If !Empty(cCodLP)
		If cCodLP == "940" // Emissão de WO de Despesa
			cCpoData := "NUF_DTEMI"
		ElseIf cCodLP == "941" // Cancelamento de WO de Despesa
			cCpoData := "NUF_DTCAN"
		ElseIf cCodLP == "942" // Lançamento
			cCpoData := "OHB_DTLANC"
		ElseIf cCodLP == "943" // Desdobramento Baixa
			cCpoData := "E2_BAIXA"
		ElseIf cCodLP == "947" // Inclusão de Desdobramento
			cCpoData := "OHF_DTINCL"
		ElseIf cCodLP == "944" // Desdobramento pós pagamento
			cCpoData := "OHG_DTINCL"
		ElseIf cCodLP == "945" // Emissão de Fatura
			cCpoData := "NXA_DTEMI"
		ElseIf cCodLP == "946" //Cancelamento de Fatura
			cCpoData := "NXA_DTCANC"
EndIf
	EndIf

Return (cCpoData)

//-----------------------------------------------------------------------------
Static Function J265RunCtb(nHdlPrv, nTotal, cArquivo, aFlagCTB, dDataCont)
	Local lMostra   := (MV_PAR01 == 1) // Mostra Lanï¿½amentos Contï¿½beis
	Local lAglutina := (MV_PAR02 == 1) // Aglutina Lanï¿½amentos Contï¿½beis
	Local nOpc      := 3
	Local lRet      := .F.

	If nHdlPrv > 0 .And. nTotal > 0
		// Fechamento do Lançamento contábil
		RodaProva(nHdlPrv, nTotal)

		// Gravação do lote contábil
		cA100Incl(cArquivo, nHdlPrv, nOpc, cLote, lMostra, lAglutina, , dDataCont, , aFlagCTB)
	Else
		lRet := .F.
	EndIf

	nHdlPrv  := 0
	nTotal   := 0
	cArquivo := ""
	JurFreeArr(aFlagCTB)

Return lRet
