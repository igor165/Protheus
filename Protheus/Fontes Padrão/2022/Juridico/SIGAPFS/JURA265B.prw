#INCLUDE "JURA265B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

#DEFINE cLote      LoteCont("PFS") // Lote contábil do lançamento, cada módulo tem o seu e está configurado na tabela 09 do SX5
#DEFINE cRotina    "JURA265B"      // Rotina que está gerando o Lançamento para ser possivel fazer o posterior rastreamento
#DEFINE cLPLanc    "942"           // Lançamento Padrão (CT5) - Lançamentos
#DEFINE cLPDesdBx  "943"           // Lançamento Padrão (CT5) - Desdobramentos Baixa
#DEFINE cLPDesdPP  "944"           // Lançamento Padrão (CT5) - Desdobramentos Pós Pagamento
#DEFINE cLPDesInc  "947"           // Lançamento Padrão (CT5) - Inclusão de Desdobramento (Provisão)
#DEFINE cLPEstDInc "948"           // Lançamento Padrão (CT5) - Estorno da Inclusão do Desdobramento
#DEFINE cLPEstDPos "949"           // Lançamento Padrão (CT5) - Estorno de Desdobramento Pós Pagamento
#DEFINE cLPEstLan  "956"           // Lançamento Padrão (CT5) - Estorno Lançamento
#DEFINE cLPEstDBx  "957"           // Lançamento Padrão (CT5) - Estorno Desdobramento Baixa

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA265B
Contabilização On-Line

@param   cLP     , caractere, Código do lançamento padrão
@param   nRecno  , numerico , Recno do registro a ser contabilizado
@param   lDataBase, logico   , Informa se utiliza a data base do sistema para contabilizar

@return  lGrvCont, logico , Retorna .T. quando foi contabilizado

@author  Jonatas Martins
@since   10/10/2019
@Obs     Quando informado um recno será considerado apenas um registro
         caso o contrário será feita uma query para buscar os dados
/*/
//-------------------------------------------------------------------
Function JURA265B(cLP, nRecno, lDataBase)
	Local aArea    := GetArea()
	Local lGrvCont := .F.
	
	Default cLP       := ""
	Default nRecno    := 0
	Default lDataBase := .T.

	If J265BVld(cLP)
		FWMsgRun(Nil, {|| lGrvCont := JA265BCTB(cLP, nRecno, lDataBase)}, STR0001, STR0002 ) // "Contabilizando" # "Aguarde..."
	Else
		JurMsgErro(STR0003) // "Dados inválidos para contabilização!"
	EndIf
	
	RestArea( aArea )

Return (lGrvCont)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BVld
Valida dados para contabilização

@param   cLP     , caractere, Código do lançamento padrão

@return  lValid  , logico   , Se .T. dados válidos

@author  Jonatas Martins
@since   10/10/2019
/*/
//-------------------------------------------------------------------
Static Function J265BVld(cLP)
	Local lValid := .F.

	If Empty(cLP)
		JurMsgErro(STR0006, , STR0007) // "Código do lançamento padrão está vazio!" # Preencha o código do lançamento padrão."
	
	ElseIf !VerPadrao(cLP)
		JurMsgErro(I18N(STR0008, {cLP}), , STR0009) // "Lançamento padrão: '#1' não configurado!" ## "Configure o lançamento padrão." 
	
	ElseIf cLP == "948" .And. OHF->(ColumnPos("OHF_DTCONI")) == 0
		JurMsgErro(STR0004, , STR0005) // "Campo OHF_DTCONI não encontrado!" # "Atualize seu dicionário de dados."
	
	Else
		lValid := .T.
	EndIf

Return (lValid)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA265BCTB
Executa a contabilização

@param   cLP      , caractere, Código do lançamento padrão
@param   nRecno   , numerico , Recno do registro a ser contabilizado
@param   lDataBase, logico   , Informa se utiliza a data base do sistema para contabilizar

@return  lCont    , logico   , Se .T. foi contabilizado

@author  Jonatas Martins
@since   10/10/2019
/*/
//-------------------------------------------------------------------
Static Function JA265BCTB(cLP, nRecno, lDataBase)
	Local cTabOrig  := J265LpTab(cLP) // Encontra tabela de origem
	Local aAreas    := {(cTabOrig)->(GetArea(cTabOrig)), SED->(GetArea("SED")), SA2->(GetArea("SA2"))}
	Local aDadosTab := {}
	Local aFlagCTB  := {}
	Local cArquivo  := ""
	Local cCpoFlag  := ""
	Local cCpoData  := ""
	Local nRecnoTab := 0
	Local nHdlPrv   := 0
	Local nOpc      := 3
	Local nTotal    := 0
	Local nDesd     := 0
	Local lCont     := .T.
	Local dDataCont := Date()
	Local cQuery    := ""
	Local cCpoValor := ""
	Local cCodLPCtb := ""
	Local nValor    := 0
	Local cFilAtu   := cFilAnt
	
	If nRecno > 0
		aDadosTab := {{nRecno}}
	Else
		cQuery    := J265BQry(cLP)
		aDadosTab := JurSql(cQuery, "*")
	EndIf

	// Obtem campo de flag
	cCpoFlag := J265LpFlag(cLP)

	// Obtem o campo de Valor
	cCpoValor := J265BCpVl(cLP)

	//Campo de data da contabilização
	cCpoData := IIF(lDataBase, "", J265LpData(cLP))

	For nDesd := 1 To Len(aDadosTab)
		nRecnoTab := aDadosTab[nDesd][1]
	
		(cTabOrig)->(DbGoTo(nRecnoTab))

		cFilAnt := (cTabOrig)->(FieldGet(FieldPos(cTabOrig + "_FILIAL")))

		// Posiciona nas demais tabelas
		J265BPosTab(cLP)

		// Abertura do lançamento contábil
		nHdlPrv := HeadProva(cLote, cRotina, Substr(cUsername,1,6), @cArquivo)

		If nHdlPrv > 0
			// Data da contabilização
			dDataCont := IIF(lDataBase .Or. (cTabOrig)->(FieldPos(cCpoData)) == 0, dDataBase, (cTabOrig)->(FieldGet(FieldPos(cCpoData))))
			// Monta array com dados para contabilização
			aFlagCTB  := {{cCpoFlag, dDataCont, cTabOrig, nRecnoTab, 0, 0, 0}}

			// Realiza o tratamento de valores negativos
			nValor := (cTabOrig)->(FieldGet(FieldPos(cCpoValor)))
			If !Empty(cCpoValor) .And. nValor < 0
				Do Case
					Case cLP == cLPDesdBx       // "943" Desdobramento Baixa
						cCodLPCtb := cLPEstDBx  // "957" Estorno Desdobramento Baixa
					Case cLP == cLPDesInc       // "947" Inclusão de Desdobramento
						cCodLPCtb := cLPEstDInc // "948" Estorno de Inclusão de Desdobramento
					Case cLP == cLPDesdPP       // "944" Desdobramento Pós Pagamento
						cCodLPCtb := cLPEstDPos // "949" Estorno de Desdobramento Pós Pagamento
					Case cLP == cLPEstDBx       // "957" Estorno Desdobramento Baixa
						cCodLPCtb := cLPDesdBx  // "943" Desdobramento Baixa
					Case cLP == cLPEstDInc      // "948" Estorno de Inclusão de Desdobramento
						cCodLPCtb := cLPDesInc  // "947" Inclusão de Desdobramento
					Case cLP == cLPEstDPos      // "949" Estorno de Desdobramento Pós Pagamento 
						cCodLPCtb := cLPDesdPP  // "944" Desdobramento Pós Pagamento
					OtherWise
						cCodLPCtb := cLP
				EndCase
			Else
				cCodLPCtb := cLP
			EndIf

			// Obtem valores da contabilização
			nTotal    := DetProva(nHdlPrv, cCodLPCtb, cRotina, cLote)

			// Fechamento do lançamento contábil
			RodaProva(nHdlPrv, nTotal)

			// Gravação do lote contábil
			cA100Incl(cArquivo, nHdlPrv, nOpc, cLote, .F./*lMostra*/, .F./*lAglutina*/, , dDataCont, , aFlagCTB)

			// Limpa campo de flag de contabilização no estorno de desdobramento baixa
			If cLP == cLPEstDBx
				RecLock("OHF")
				OHF->OHF_DTCONT = CtoD("  /  /    ")
				OHF->(MsUnLock())
			EndIf

			JurFreeArr(aFlagCTB)
		EndIf
	Next nDesd

	cFilAnt := cFilAtu

	AEVal(aAreas, {|aArea| RestArea(aArea)})
	JurFreeArr(aAreas)

Return (lCont)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BQry
Chama a função de query específica com base no lançamento padrão

@param   cLP     , caractere, Código do lançamento padrão

@return  cQueryLP, caractere, Faz chamada da query com base no lançamento padrão

@author  Jonatas Martins
@since   10/10/2019
@obs     Somente monta a query quando não for passado um recno
/*/
//-------------------------------------------------------------------
Static Function J265BQry(cLP)
	Local cQueryLP := ""

	If cLP == cLPDesInc .Or. cLP == cLPEstDInc .Or. cLP == cLPEstDBx
		cQueryLP := J265BQDesd(cLP)
	ElseIf cLP == cLPDesdPP .Or. cLP == cLPEstDPos
		cQueryLP := J265BQPos(cLP)
	EndIf

Return (cQueryLP)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BQDesd
Query específica para buscar dados do desdobramentos

@param   cLP      , caractere, Código do lançamento padrão

@return  cQueryDes, caractere, Query de dados do desdobramento

@author  Jonatas Martins
@since   10/10/2019
@obs     Somente monta a query quando não for passado um recno
/*/
//-------------------------------------------------------------------
Static Function J265BQDesd(cLP)
	Local cChave    := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
	Local cIdDoc    := FINGRVFK7('SE2', cChave)
	Local cQueryDes := ""

	cQueryDes := "SELECT R_E_C_N_O_ "
	cQueryDes += " FROM " + RetSqlName("OHF")
	cQueryDes += " WHERE OHF_FILIAL = '" + xFilial("OHF", SE2->E2_FILIAL) + "'"
	cQueryDes +=   " AND OHF_IDDOC = '" + cIdDoc + "'"
	If cLP == cLPDesInc // 947 - Inclusão de Desdobramento
		cQueryDes += " AND OHF_DTCONI = '        '"
	ElseIf cLP == cLPEstDInc // 948 - Estorno de Inclusão de Desdobramento
		cQueryDes += " AND OHF_DTCONI <> '        '"
	ElseIf  cLP == cLPEstDBx // 957 - Estorno de Desdobramento Baixa
		cQueryDes += " AND OHF_DTCONT <> '        '"
	EndIf
	cQueryDes += " AND D_E_L_E_T_ = ' ' "
	
Return (cQueryDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BQPos
Query específica para buscar dados do desdobramentos pós pagamento

@param   cLP      , caractere, Código do lançamento padrão

@return  cQueryDes, caractere, Query de dados do desdobramento

@author  Jonatas Martins
@since   10/10/2019
@obs     Somente monta a query quando não for passado um recno
/*/
//-------------------------------------------------------------------
Static Function J265BQPos(cLP)
	Local cChave    := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
	Local cIdDoc    := FINGRVFK7('SE2', cChave)
	Local cQueryDes := ""

	cQueryDes := "SELECT R_E_C_N_O_ "
	cQueryDes += " FROM " + RetSqlName("OHG")
	cQueryDes += " WHERE OHG_FILIAL = '" + xFilial("OHG", SE2->E2_FILIAL) + "'"
	cQueryDes +=   " AND OHG_IDDOC = '" + cIdDoc + "'"
	If cLP == cLPDesdPP // Inclusão de Desdobramento Pós Pagamento
		cQueryDes += " AND OHG_DTCONT = '        '"
	ElseIf cLP == cLPEstDPos // Estorno de Desdobramento Pós Pagamento
		cQueryDes += " AND OHG_DTCONT <> '        '"
	EndIf
	cQueryDes += " AND D_E_L_E_T_ = ' ' "
	
Return (cQueryDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BPosTab
Função para posicionar nas tabelas necessárias

@param   cLP     , caractere, Código do lançamento padrão

@author  Jonatas Martins
@since   10/10/2019
/*/
//----------------------------------------------------------------
Static Function	J265BPosTab(cLP)

	Do Case
		Case cLP == cLPDesInc .Or. ; // 947 - Desdobramentos Inclusão (Provisão)
		     cLP == cLPEstDInc .Or.; // 948 - Estorno da Inclusão do Desdobramento
		     cLP == cLPEstDBx .Or. ;       // 957 - Estorno de desdobramento baixa
			 cLP == cLPDesdBx .Or. ;       // 943 - Desdobramento Baixa
			SED->(DbSeek(xFilial("SED") + OHF->OHF_CNATUR))
			SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
		
		Case cLP == cLPDesdPP .Or.;  // 944 - Desdobramento Pós Pagamento
		     cLP == cLPEstDPos       // 949 - Estorno desdorbamento pós pagamento
			SED->(DbSeek(xFilial("SED") + OHG->OHG_CNATUR))
			SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))

		Case cLP == cLPLanc .Or. ;   // 942 - Lançamento
		     cLP == cLPEstLan        // 956 - Estorno de Lançamento
			SED->(DbSeek(xFilial("SED") + OHB->OHB_NATORI))
	End Case

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} J265BCpVl
Indica o campo de data/flag de contabilização de valor

@param cCodLP     , Código do lançamento padrão

@return cCpoValor , Campo de valor da contabilização considerando o LP

@author fabiana.silva
@since  21/07/2021
/*/
//-------------------------------------------------------------------
Static Function J265BCpVl(cCodLP)
Local cCpoFlag := ""

Default cCodLP := ""

	If !Empty(cCodLP)
		If cCodLP == cLPLanc .Or. cCodLP == cLPEstLan // 942 - Lançamentos ou 956 - Estorno Lançamento
			cCpoFlag := "OHB_VALOR"
		ElseIf (cCodLP == cLPDesdBx .Or. cCodLP == cLPEstDBx) .Or. ; // 943 - Desdobramento Baixa ou 957 - Estorno Desdobramento Baixa
		       (cCodLP == cLPDesInc .Or. cCodLP == cLPEstDInc)   //947 - Inclusão de Desdobramento ou 948 - Estorno de Inclusão de Desdobramento 
			cCpoFlag := "OHF_VALOR"
		ElseIf cCodLP == cLPDesdPP .Or. cCodLP == cLPEstDPos // 944 - Desdobramento Pós Pagamento ou 949 - Estorno de desdobramento Pós Pagamento
			cCpoFlag := "OHG_VALOR"
		EndIf
	EndIf

Return cCpoFlag
