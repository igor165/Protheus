#INCLUDE "JURA265B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

#DEFINE cLote      LoteCont("PFS") // Lote cont�bil do lan�amento, cada m�dulo tem o seu e est� configurado na tabela 09 do SX5
#DEFINE cRotina    "JURA265B"      // Rotina que est� gerando o Lan�amento para ser possivel fazer o posterior rastreamento
#DEFINE cLPLanc    "942"           // Lan�amento Padr�o (CT5) - Lan�amentos
#DEFINE cLPDesdBx  "943"           // Lan�amento Padr�o (CT5) - Desdobramentos Baixa
#DEFINE cLPDesdPP  "944"           // Lan�amento Padr�o (CT5) - Desdobramentos P�s Pagamento
#DEFINE cLPDesInc  "947"           // Lan�amento Padr�o (CT5) - Inclus�o de Desdobramento (Provis�o)
#DEFINE cLPEstDInc "948"           // Lan�amento Padr�o (CT5) - Estorno da Inclus�o do Desdobramento
#DEFINE cLPEstDPos "949"           // Lan�amento Padr�o (CT5) - Estorno de Desdobramento P�s Pagamento
#DEFINE cLPEstLan  "956"           // Lan�amento Padr�o (CT5) - Estorno Lan�amento
#DEFINE cLPEstDBx  "957"           // Lan�amento Padr�o (CT5) - Estorno Desdobramento Baixa

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA265B
Contabiliza��o On-Line

@param   cLP     , caractere, C�digo do lan�amento padr�o
@param   nRecno  , numerico , Recno do registro a ser contabilizado
@param   lDataBase, logico   , Informa se utiliza a data base do sistema para contabilizar

@return  lGrvCont, logico , Retorna .T. quando foi contabilizado

@author  Jonatas Martins
@since   10/10/2019
@Obs     Quando informado um recno ser� considerado apenas um registro
         caso o contr�rio ser� feita uma query para buscar os dados
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
		JurMsgErro(STR0003) // "Dados inv�lidos para contabiliza��o!"
	EndIf
	
	RestArea( aArea )

Return (lGrvCont)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BVld
Valida dados para contabiliza��o

@param   cLP     , caractere, C�digo do lan�amento padr�o

@return  lValid  , logico   , Se .T. dados v�lidos

@author  Jonatas Martins
@since   10/10/2019
/*/
//-------------------------------------------------------------------
Static Function J265BVld(cLP)
	Local lValid := .F.

	If Empty(cLP)
		JurMsgErro(STR0006, , STR0007) // "C�digo do lan�amento padr�o est� vazio!" # Preencha o c�digo do lan�amento padr�o."
	
	ElseIf !VerPadrao(cLP)
		JurMsgErro(I18N(STR0008, {cLP}), , STR0009) // "Lan�amento padr�o: '#1' n�o configurado!" ## "Configure o lan�amento padr�o." 
	
	ElseIf cLP == "948" .And. OHF->(ColumnPos("OHF_DTCONI")) == 0
		JurMsgErro(STR0004, , STR0005) // "Campo OHF_DTCONI n�o encontrado!" # "Atualize seu dicion�rio de dados."
	
	Else
		lValid := .T.
	EndIf

Return (lValid)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA265BCTB
Executa a contabiliza��o

@param   cLP      , caractere, C�digo do lan�amento padr�o
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

	//Campo de data da contabiliza��o
	cCpoData := IIF(lDataBase, "", J265LpData(cLP))

	For nDesd := 1 To Len(aDadosTab)
		nRecnoTab := aDadosTab[nDesd][1]
	
		(cTabOrig)->(DbGoTo(nRecnoTab))

		cFilAnt := (cTabOrig)->(FieldGet(FieldPos(cTabOrig + "_FILIAL")))

		// Posiciona nas demais tabelas
		J265BPosTab(cLP)

		// Abertura do lan�amento cont�bil
		nHdlPrv := HeadProva(cLote, cRotina, Substr(cUsername,1,6), @cArquivo)

		If nHdlPrv > 0
			// Data da contabiliza��o
			dDataCont := IIF(lDataBase .Or. (cTabOrig)->(FieldPos(cCpoData)) == 0, dDataBase, (cTabOrig)->(FieldGet(FieldPos(cCpoData))))
			// Monta array com dados para contabiliza��o
			aFlagCTB  := {{cCpoFlag, dDataCont, cTabOrig, nRecnoTab, 0, 0, 0}}

			// Realiza o tratamento de valores negativos
			nValor := (cTabOrig)->(FieldGet(FieldPos(cCpoValor)))
			If !Empty(cCpoValor) .And. nValor < 0
				Do Case
					Case cLP == cLPDesdBx       // "943" Desdobramento Baixa
						cCodLPCtb := cLPEstDBx  // "957" Estorno Desdobramento Baixa
					Case cLP == cLPDesInc       // "947" Inclus�o de Desdobramento
						cCodLPCtb := cLPEstDInc // "948" Estorno de Inclus�o de Desdobramento
					Case cLP == cLPDesdPP       // "944" Desdobramento P�s Pagamento
						cCodLPCtb := cLPEstDPos // "949" Estorno de Desdobramento P�s Pagamento
					Case cLP == cLPEstDBx       // "957" Estorno Desdobramento Baixa
						cCodLPCtb := cLPDesdBx  // "943" Desdobramento Baixa
					Case cLP == cLPEstDInc      // "948" Estorno de Inclus�o de Desdobramento
						cCodLPCtb := cLPDesInc  // "947" Inclus�o de Desdobramento
					Case cLP == cLPEstDPos      // "949" Estorno de Desdobramento P�s Pagamento 
						cCodLPCtb := cLPDesdPP  // "944" Desdobramento P�s Pagamento
					OtherWise
						cCodLPCtb := cLP
				EndCase
			Else
				cCodLPCtb := cLP
			EndIf

			// Obtem valores da contabiliza��o
			nTotal    := DetProva(nHdlPrv, cCodLPCtb, cRotina, cLote)

			// Fechamento do lan�amento cont�bil
			RodaProva(nHdlPrv, nTotal)

			// Grava��o do lote cont�bil
			cA100Incl(cArquivo, nHdlPrv, nOpc, cLote, .F./*lMostra*/, .F./*lAglutina*/, , dDataCont, , aFlagCTB)

			// Limpa campo de flag de contabiliza��o no estorno de desdobramento baixa
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
Chama a fun��o de query espec�fica com base no lan�amento padr�o

@param   cLP     , caractere, C�digo do lan�amento padr�o

@return  cQueryLP, caractere, Faz chamada da query com base no lan�amento padr�o

@author  Jonatas Martins
@since   10/10/2019
@obs     Somente monta a query quando n�o for passado um recno
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
Query espec�fica para buscar dados do desdobramentos

@param   cLP      , caractere, C�digo do lan�amento padr�o

@return  cQueryDes, caractere, Query de dados do desdobramento

@author  Jonatas Martins
@since   10/10/2019
@obs     Somente monta a query quando n�o for passado um recno
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
	If cLP == cLPDesInc // 947 - Inclus�o de Desdobramento
		cQueryDes += " AND OHF_DTCONI = '        '"
	ElseIf cLP == cLPEstDInc // 948 - Estorno de Inclus�o de Desdobramento
		cQueryDes += " AND OHF_DTCONI <> '        '"
	ElseIf  cLP == cLPEstDBx // 957 - Estorno de Desdobramento Baixa
		cQueryDes += " AND OHF_DTCONT <> '        '"
	EndIf
	cQueryDes += " AND D_E_L_E_T_ = ' ' "
	
Return (cQueryDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BQPos
Query espec�fica para buscar dados do desdobramentos p�s pagamento

@param   cLP      , caractere, C�digo do lan�amento padr�o

@return  cQueryDes, caractere, Query de dados do desdobramento

@author  Jonatas Martins
@since   10/10/2019
@obs     Somente monta a query quando n�o for passado um recno
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
	If cLP == cLPDesdPP // Inclus�o de Desdobramento P�s Pagamento
		cQueryDes += " AND OHG_DTCONT = '        '"
	ElseIf cLP == cLPEstDPos // Estorno de Desdobramento P�s Pagamento
		cQueryDes += " AND OHG_DTCONT <> '        '"
	EndIf
	cQueryDes += " AND D_E_L_E_T_ = ' ' "
	
Return (cQueryDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} J265BPosTab
Fun��o para posicionar nas tabelas necess�rias

@param   cLP     , caractere, C�digo do lan�amento padr�o

@author  Jonatas Martins
@since   10/10/2019
/*/
//----------------------------------------------------------------
Static Function	J265BPosTab(cLP)

	Do Case
		Case cLP == cLPDesInc .Or. ; // 947 - Desdobramentos Inclus�o (Provis�o)
		     cLP == cLPEstDInc .Or.; // 948 - Estorno da Inclus�o do Desdobramento
		     cLP == cLPEstDBx .Or. ;       // 957 - Estorno de desdobramento baixa
			 cLP == cLPDesdBx .Or. ;       // 943 - Desdobramento Baixa
			SED->(DbSeek(xFilial("SED") + OHF->OHF_CNATUR))
			SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
		
		Case cLP == cLPDesdPP .Or.;  // 944 - Desdobramento P�s Pagamento
		     cLP == cLPEstDPos       // 949 - Estorno desdorbamento p�s pagamento
			SED->(DbSeek(xFilial("SED") + OHG->OHG_CNATUR))
			SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))

		Case cLP == cLPLanc .Or. ;   // 942 - Lan�amento
		     cLP == cLPEstLan        // 956 - Estorno de Lan�amento
			SED->(DbSeek(xFilial("SED") + OHB->OHB_NATORI))
	End Case

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} J265BCpVl
Indica o campo de data/flag de contabiliza��o de valor

@param cCodLP     , C�digo do lan�amento padr�o

@return cCpoValor , Campo de valor da contabiliza��o considerando o LP

@author fabiana.silva
@since  21/07/2021
/*/
//-------------------------------------------------------------------
Static Function J265BCpVl(cCodLP)
Local cCpoFlag := ""

Default cCodLP := ""

	If !Empty(cCodLP)
		If cCodLP == cLPLanc .Or. cCodLP == cLPEstLan // 942 - Lan�amentos ou 956 - Estorno Lan�amento
			cCpoFlag := "OHB_VALOR"
		ElseIf (cCodLP == cLPDesdBx .Or. cCodLP == cLPEstDBx) .Or. ; // 943 - Desdobramento Baixa ou 957 - Estorno Desdobramento Baixa
		       (cCodLP == cLPDesInc .Or. cCodLP == cLPEstDInc)   //947 - Inclus�o de Desdobramento ou 948 - Estorno de Inclus�o de Desdobramento 
			cCpoFlag := "OHF_VALOR"
		ElseIf cCodLP == cLPDesdPP .Or. cCodLP == cLPEstDPos // 944 - Desdobramento P�s Pagamento ou 949 - Estorno de desdobramento P�s Pagamento
			cCpoFlag := "OHG_VALOR"
		EndIf
	EndIf

Return cCpoFlag
