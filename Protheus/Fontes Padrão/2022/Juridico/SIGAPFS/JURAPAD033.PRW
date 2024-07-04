#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURAPAD033.CH"

#DEFINE nTamCarac 5.5   // Tamanho de um caractere no relatório
#DEFINE nSalto    10    // Salto de uma linha a outra

#DEFINE nPCollData  0
#DEFINE nPCollSol   50
#DEFINE nPCollHist  100
#DEFINE nPCollNat   300
#DEFINE nPCollValCv 370
#DEFINE nPCollVal   450
#DEFINE nPCollSaldo 539

Static nPage       := 1    // Contador de páginas
Static __lAuto     := .F.  // Indica se a chamada foi feita via automação

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD033
Relatório de Resultado Financeiro por Moeda

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameAuto, Nome do arquivo de relatório usado na automação

@author Bruno Ritter
@since  21/03/2018
/*/
//-------------------------------------------------------------------
Main Function JURAPAD033(lAutomato, cNameAuto)
	Local aArea      := GetArea()
	Local lCanc      := .F.
	Local cDirectory := GetSrvProfString( "StartPath" , "" )
	Local bRun       := {||}
	Local aParams    := {}
	Local lPDUserAc  := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	Default lAutomato := .F.
	Default cNameAuto := ""

	Private nIniV     := 0  // Linha atual
	Private cBkFilAnt := '' // Backup Filial Ant
	Private cFilOri   := ''

	__lAuto := lAutomato

	If lPDUserAc
		While !lCanc
			If __lAuto .Or. JPergunte()
				If JP033TdOk(MV_PAR01, MV_PAR02, MV_PAR03)
					aParams := {MV_PAR01, MV_PAR02, MV_PAR03}
					If __lAuto
						PrintReport(cDirectory, aParams, cNameAuto)
						lCanc := .T.
					Else
						bRun := {|| PrintReport(cDirectory, aParams, cNameAuto)}
						Processa( bRun , STR0028, STR0029, .F. ) //#"Relatório de Resultado Financeiro por Moeda", ##"Gerando relatório..."
					EndIf
					If !Empty(cBkFilAnt)
						cFilAnt := cBkFilAnt
					EndIf
				EndIf
			Else
				lCanc := .T.
			Endif
		EndDo
	Else
		MsgInfo(STR0033, STR0034) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JPergunte
Abre o Pergunte para filtro do relatório

@author Jorge Martins
@since  26/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JPergunte()
Local lRet := .T.

	lRet := Pergunte('JURAPAD033', .T. )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP033VldAM
Valida o ano-mês de referência.

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP033VldAM(cAnoMes)
Local lRet  := .T.
Local dData := Nil

If !Empty(cAnoMes)
	dData := STOD(cAnoMes+"01")

	If Empty(dData)
		JurMsgErro(STR0001) // "Ano-Mês inválido."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP033VldMd
Valida a moeda informada

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP033VldMd(cMoeda)
Local lRet    := .T.
Local cRetCTO := ""

If !Empty(cMoeda)
	cRetCTO := JurGetDados("CTO",1,xFILIAL("CTO")+cMoeda, "CTO_MOEDA")
	If Empty(cRetCTO)
		JurMsgErro(STR0002,,STR0003) // "Escritório não encontrado." - "Informe um escritório válido."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP033TdOk
Rotina validar os dados do pergunte

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JP033TdOk(cAnoMes, cMoeda, cEscrit)
Local lRet 		:= .T.

If lRet .And. Empty(cAnoMes)
	JurMsgErro(STR0006,,STR0007) // "O Ano-Mês é obrigatório." - "Informe um Ano-Mês válido."
	lRet := .F.
EndIf

If lRet .And. Empty(cMoeda)
	JurMsgErro(STR0008,,STR0009) // "A Moeda é obrigatório." - "Informe uma Moeda válida."
	lRet := .F.
EndIf

If lRet .And. Empty(cEscrit)
	JurMsgErro(STR0010,,STR0011) // "O Escritório é obrigatório." - "Informe um Escritório válido."
	lRet := .F.
Else
	cFilOri   := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
	cBkFilAnt := cFilAnt
	cFilAnt   := cFilOri
EndIf

Return lRet


//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório de Balancete Plano/Empresa.

@param  cDirectory  , caracter , Caminho da pasta
@param  aParams     , array    , Parametros do filtro
@param  cNameAuto   , caracter , Nome do arquivo de relatório usado na automação

@author Nivia Ferreira
@since  29/03/2018
/*/
//=======================================================================
Static Function PrintReport(cDirectory, aParams, cNameAuto)
	Local oPrinter        := Nil
	Local cNameFile       := "Resultado_Financeiro_Moeda_" + FwTimeStamp(1)
	Local nIniH           := 1
	Local nFimH           := 560
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.

	// Tabela temporaria auxiliar
	Local oTpConta        := JurTpConta():New()
	Local cTpContTmp      := ""  //Alias da tabela temporaria de tipo de contas
	Local oSumCntTmp      := Nil //Objeto da tabela temporaria de totalização
	Local cSomCntTmp      := ""  //Alias da tabela temporaria de totalização

	// Parâmetros Filtro
	Local cAnoMes         := aParams[1]
	Local cMoeda          := aParams[2]
	Local cEscrit         := aParams[3]

	// Parametros das Querys
	Local dDtInicio  := StoD(cAnoMes+"01")
	Local dDtFinal   := Lastday(dDtInicio)

	Default cDirectory  := GetSrvProfString( "StartPath" , "" )

	ProcRegua(0)
	IncProc()

	// Monta a tabela temporaria auxiliar de Tipo de contas
	oTpConta:GeraTmp()
	cTpContTmp := oTpConta:GetTmpName()

	// Soma dos tipos de contas '2','3','4','6','8' e Transferência.
	oSumCntTmp  := JTmpSumTpC(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
	cSomCntTmp  := oSumCntTmp:GetRealName()

	//Adiciona os alias das tabelas temporarias no array de parametros
	Aadd(aParams, cTpContTmp)
	Aadd(aParams, cSomCntTmp)

	//Configurações do relatório
	If !__lAuto
		oPrinter := FWMsPrinter():New( cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,, "PDF" )
	Else
		oPrinter := FWMSPrinter():New( cNameAuto, IMP_SPOOL,,, .T.,,,,.T.) // Inicia o relatório
		// Alterar o nome do arquivo de impressão para o padrão de impressão automatica
		oPrinter:CFILENAME  := cNameAuto
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	EndIf
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60)

	//Gera nova folha
	NewPage( @oPrinter , nIniH , nFimH, aParams)

	//Imprime seção de escritório
	PrintRepData( @oPrinter , nIniH , nFimH, aParams)

	//Gera arquivo relatório
	oPrinter:Print()

	//Desmonta a tabela temporaria auxiliar
	oTpConta:Destroy()
	oSumCntTmp:Delete()

Return Nil

//=======================================================================
/*/{Protheus.doc} NewPage
Cria nova página do relatório.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final
@param  aParams , array    , Parametros do filtro

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function NewPage( oPrinter , nIniH , nFimH, aParams)

	//Inicio Página
	oPrinter:StartPage()

	//Monta cabeçalho
	PrintHead( @oPrinter , nIniH , nFimH , aParams)

	//Imprime Rodapé
	PrintFooter( @oPrinter , nIniH , nFimH )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintHead( oPrinter , nIniH , nFimH, aParams)
Imprime dados do cabeçalho.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final
@param  aParams , array    , Parametros do filtro

@author Nivia Ferreira
@since  29/03/2018
/*/
//=======================================================================
Static Function PrintHead( oPrinter , nIniH , nFimH, aParams)
	Local oFontHead   := Nil
	Local oFontHead1  := Nil
	Local oFontHead2  := Nil
	Local cHeader     := ""
	//Parametros Filtro
	Local cAnoMes     := aParams[1]
	Local cMoeda      := aParams[2]
	Local cEscrit     := aParams[3]
	Local cRazao      := JurGetDados("NS7", 1, xFilial("NS7")+cEscrit, "NS7_RAZAO")
	Local cSimMoed    := Alltrim(JurGetDados("CTO",1,xFILIAL("CTO")+cMoeda, "CTO_SIMB"))

	oFontHead   := TFont():New('Arial',,-16,,.T.,,,,,.F.,.F.)
	oFontHead1  := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	oFontHead2  := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)

	//---------------------
	// Título do relatório
	//---------------------
	cSimMoed := I18N(STR0030, {cSimMoed} ) //"(Moeda: #1)"

	oPrinter:SayAlign( 030, nIniH, STR0012 , oFontHead, nFimH, 200, CLR_BLACK, 2, 1 ) //"Posição Financeira Mensal"
	oPrinter:SayAlign( 045, nIniH, cSimMoed , oFontHead1, nFimH, 200, CLR_BLACK, 2, 1 ) //"(Moeda: #1)"

	//---------------------------------
	// Detalhes do filtro do relatório
	//---------------------------------

	cHeader := I18N(STR0031, {TRANSFORM(cAnoMes,"@R 9999-99"), Alltrim(cRazao)} ) //# "Período: #1 - Escritório: #2"

	nIniV := 60
	oPrinter:Line( nIniV, nIniH, nIniV, nFimH, 0, "-8")
	nIniV += nSalto
	oPrinter:Say( nIniV, nIniH , cHeader , oFontHead2, 1200,/*color*/)
	nIniV += nSalto
	oPrinter:Line( nIniV, nIniH, nIniV, nFimH, 0, "-8")
	nIniV += nSalto + 15

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintRepData
Imprime registros do relatório.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH	, numerico , Coordenada horizontal inicial
@param  nFimH	, numerico , Coordenada horizontal final

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintRepData( oPrinter , nIniH , nFimH , aParams)

	//Monta Resumo do Movimento Financeiro
	PrintTitS1( @oPrinter , nIniH , nFimH , @nIniV , aParams)

	//Monta Posição final de Caixa
	PrintTitS2( @oPrinter , nIniH , nFimH , @nIniV , aParams)

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintTitS1( oPrinter , nIniH , nFimH , nIniV , aParams)
Imprimide Resumo do Movimento Financeiro do Mes

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final
@param  nIniV   , numerico , Coordenada vertical inicial
@param  aParams , array    , Parametros do filtro

@author Nivia Ferreira
@since  29/03/2018
/*/
//=======================================================================
Static Function PrintTitS1( oPrinter , nIniH , nFimH , nIniV , aParams)
	Local oFontTitCol := Nil
	Local oFontTitSub := Nil

	//Parametros do relatório
	Local cAnoMes     := aParams[1]
	Local cMoeda      := aParams[2]
	Local cEscrit     := aParams[3]
	Local cTpContTmp  := aParams[4] //Alias da tabela temporaria de tipo de contas
	Local cSomCntTmp  := aParams[5] //Alias da tabela temporaria de totalização
	Local cPicture    := "@E 999,999,999.99"

	//Parametros das Querys
	Local dDtInicio  := StoD(cAnoMes+"01")
	Local dDtFinal   := Lastday(dDtInicio)
	//Local cFilOri    := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA" )
	Local nValor     := 0
	Local nValorAnt  := 0

	oFontTitCol := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	oFontTitSub := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)

	oPrinter:Say( nIniV, nIniH , STR0014 , oFontTitSub, 1200,/*color*/) //"Resumo do Movimento Financeiro do Mês:"
	nIniV += nSalto - 5
	oPrinter:Line( nIniV, nIniH, nIniV, 400, 0, "-8")
	nIniV += nSalto

	//---------------------------------
	//Saldos
	//---------------------------------
	// 1 - Saldo do Mês Anterior
	nValorAnt  := JQryMovAnt(cTpContTmp, dDtInicio, cMoeda, cFilOri)
	oPrinter:SayAlign( nIniV,  001, STR0015                           , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )//"1. Saldo do Mês Anterior "
	oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nValorAnt, cPicture)       , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	// 2 - Transferências entre Naturezas de outras Moedas
	nValor     := JRetSaldo('T', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  001, STR0016                     , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) //"2. Transferências entre Contas de Outras Moedas"
	oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	//"3. Receitas"
	nValor     := JRetSaldo('3', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  001, STR0017                     , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) //"3. Receitas"
	oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	//"4. Saídas"
	nValor  := JRetSaldo('S', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  001, STR0018                     , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) //"4. Saídas"
	oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+10

	nValor  := JRetSaldo('2', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  200, STR0019			           , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )//"Custo Direto:"
	oPrinter:SayAlign( nIniV, -200, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	nValor  := JRetSaldo('8', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  200, STR0020                     , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )//"Despesas Gerais do Escritório: "
	oPrinter:SayAlign( nIniV, -200, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	nValor  := JRetSaldo('4', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  200, STR0021  		              , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )//"Investimentos"
	oPrinter:SayAlign( nIniV, -200, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	nValor  := JRetSaldo('6', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  200, STR0022  		              , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )//"Obrigações Fiscais"
	oPrinter:SayAlign( nIniV, -200, TRANSFORM(nValor, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+5

	nValor  := JRetSaldo('S', cSomCntTmp)
	oPrinter:SayAlign( nIniV,  200, STR0023		  	           , oFontTitSub, 620, 200, CLR_BLACK, 0, 0 )//"Sub-total de Saídas"
	oPrinter:SayAlign( nIniV, -200, TRANSFORM(nValor, cPicture) , oFontTitSub, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto+10

	nValor  := JRetSaldo('R', cSomCntTmp, nValorAnt)
	oPrinter:SayAlign( nIniV,  001, STR0024			           , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) //"5. Resultado do Mês:"
	oPrinter:Line( nIniV, 480, nIniV, nFimH, 0, "-8")
	oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nValor, cPicture) , oFontTitSub, 620, 250, CLR_BLACK, 1, 1 )
	nIniV += nSalto
	oPrinter:Line( nIniV, 480, nIniV, nFimH, 0, "-8")
	nIniV += nSalto+15

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintTitS2
Imprimide Posição Final de Caixa

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final
@param  nIniV   , numerico , Coordenada vertical inicial

@author Nivia Ferreira
@since  29/03/2018
/*/
//=======================================================================
Static Function PrintTitS2( oPrinter , nIniH , nFimH , nIniV , aParams)
	Local oFontTitCol := Nil
	Local oFontTitSub

	//Parametros do relatório
	Local cAnoMes     := aParams[1]
	Local cMoeda      := aParams[2]
	Local cEscrit     := aParams[3]
	Local cTpContTmp  := aParams[4] //Alias da tabela temporaria de tipo de contas
	Local cPicture    := "@E 999,999,999.99"

	//Parametros das Querys
	Local dDtInicio  := StoD(cAnoMes+"01")
	Local dDtFinal   := Lastday(dDtInicio)
	//Local cFilOri    := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA" )

	Local aPosFinal  := {}
	Local aContas    := {}
	Local nConta     := 0
	Local aContaPai  := {}
	Local nContaPai  := 0
	Local aContaFil  := {}
	Local nContaFil  := 0

	Local lUltimo    := .F.

	oFontTitCol := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	oFontTitSub := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)

	oPrinter:Say( nIniV, nIniH , STR0032 , oFontTitSub, 1200,/*color*/) //"Posição Final de Caixa:"
	nIniV += nSalto - 5
	oPrinter:Line( nIniV, nIniH, nIniV, 400, 0, "-8")
	nIniV += nSalto


	// 6 - Banco Caixa || 7 - Contas de Sócios/Profissionais || 8. Resultado do Mês
	aPosFinal := JRetPosCx(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)

	For nConta := 1 To Len(aPosFinal)
		aContas := aPosFinal[nConta]

		//Contas
		EndPage( @oPrinter , nIniH , nFimH , @nIniV , /*nRegPos*/, nSalto*3 /*nNewIniV*/, aParams)
		oPrinter:SayAlign( nIniV,  001, aContas[1]                      , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )//Contas Ex: "6. Bancos/Caixas"
		Iif(nConta == Len(aPosFinal), oPrinter:Line( nIniV, 480, nIniV, nFimH, 0, "-8"), Nil)
		oPrinter:SayAlign( nIniV,  -60, TRANSFORM(aContas[2], cPicture) , oFontTitSub, 620, 250, CLR_BLACK, 1, 1 )
		nIniV += nSalto+5
		Iif(nConta == Len(aPosFinal), oPrinter:Line( nIniV, 480, nIniV, nFimH, 0, "-8"), Nil)

		aContaPai := Iif(Len(aContas)==3, aContas[3], {})

		For nContaPai :=1 To Len(aContaPai)
			EndPage( @oPrinter , nIniH , nFimH , @nIniV , /*nRegPos*/, nSalto*2 /*nNewIniV*/, aParams)
			//Conta Pai (Sintetica ou analitica com apenas um nivel)
			oPrinter:SayAlign( nIniV,  050, aContaPai[nContaPai][1]                        , oFontTitSub, 620, 200, CLR_BLACK, 0, 0 )
			oPrinter:SayAlign( nIniV,  -120, TRANSFORM(aContaPai[nContaPai][2] , cPicture) , oFontTitSub, 620, 250, CLR_BLACK, 1, 1 )
			nIniV += nSalto+5

			aContaFil := Iif(Len(aContaPai[nContaPai])==3, aContaPai[nContaPai][3], {})

			//Conta Filho (Analitica)
			For nContaFil :=1 To Len(aContaFil)
				lUltimo := nContaFil == Len(aContaFil)
				EndPage( @oPrinter , nIniH , nFimH , @nIniV , /*nRegPos*/, (Iif(lUltimo,4,1) * nSalto) /*nNewIniV*/, aParams)

				oPrinter:SayAlign( nIniV,  100, aContaFil[nContaFil][1]                       , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 )
				oPrinter:SayAlign( nIniV, -200, TRANSFORM(aContaFil[nContaFil][2] , cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 )
				nIniV += nSalto+5

				If lUltimo
					oPrinter:Line( nIniV, 370, nIniV, nFimH, 0, "-8")
					oPrinter:SayAlign( nIniV, -200, TRANSFORM(aContaPai[nContaPai][2] , cPicture) , oFontTitSub, 620, 250, CLR_BLACK, 1, 1 )
					oPrinter:Line( nIniV, 370, nIniV, nFimH, 0, "-8")
					nIniV += nSalto+5
				EndIf

			Next nContaFil

		Next nContaPai

		nIniV += nSalto+5
	Next nConta

	nIniV += nSalto+10

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintFooter
Imprimide rodapé do cabeçalho.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final

@author Jonatas Martins / Jorge Martins
@since	28/03/2018
/*/
//=======================================================================
Static Function PrintFooter( oPrinter , nIniH , nIniF )
	Local oFontRod := Nil
	Local cDate    := cValToChar( Date() )
	Local cTime    := Time()
	Local nLinRod  := 830

	oFontRod := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)

	oPrinter:Line( nLinRod, nIniH, nLinRod, nIniF, CLR_HRED, "-8")
	nLinRod += nSalto
	If !__lAuto
		oPrinter:SayAlign( nLinRod, nIniH, cDate + " - " + cTime, oFontRod, nIniF, 200, CLR_BLACK, 2, 1 )
		oPrinter:SayAlign( nLinRod, nIniH, cValToChar( nPage )  , oFontRod, nIniF, 200, CLR_BLACK, 1, 1 )
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} EndPage
Avalia quebra de página.

@param  oPrinter   , objeto    , Estrutra do relatório
@param  nIniH      , numerico  , Coordenada horizontal inicial
@param  nFimH      , numerico  , Coordenada horizontal final
@param  nIniV      , numerico  , Coordenada vertical inicial
@param  nRegPos    , numerico  , Contador de registros
@param  nNewIniV   , numerico  , Coordenada vertical que será verificada
@param  aParams    , array    , Parametros do filtro

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function EndPage( oPrinter , nIniH , nFimH , nIniV , nRegPos, nNewIniV, aParams)
	Local nIFimV := 825  // Coordenada vertical final

	Default nRegPos    := 1
	Default nNewIniV   := 0

	If ( nIniV + nNewIniV ) >= nIFimV
		nIniV :=  165
		nPage += 1
		oPrinter:EndPage()
		NewPage( @oPrinter , nIniH , nFimH, aParams )
		nRegPos := 1
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JP033VldEs
Valida o escritório.

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP033VldEs(cEscrit)
Local lRet    := .T.
Local cRetNS7 := ""

If !Empty(cEscrit)
	cRetNS7 := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrit, "NS7_COD" )
	If Empty(cRetNS7)
		JurMsgErro(STR0004,,STR0005) // "Escritório não encontrado." - "Informe um escritório válido."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JTmpSumTpC()
Rotina para gerar a tabela temporária com a soma dos valores dos tipos de conta
'2','3','4','6','8' e transferência

@author Bruno Ritter / Thiago Malaquias
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTmpSumTpC(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
Local cQuery := ""
Local aStruct   := {}
Local oTmpTable := Nil
Local cInsert   := ""

Aadd(aStruct, { "TP_CONTA", "C", 1 , 0 })
Aadd(aStruct, { "VALOR"   , "N", 12, 2 })

oTmpTable := FWTemporaryTable():New( GetNextAlias(), aStruct )
oTmpTable:AddIndex("TP_CONTA",{"TP_CONTA"})
oTmpTable:Create()

cQuery := JQrySumTpC(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
cQuery += " UNION ALL "
cQuery += JQryTransf(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)

cQuery := ChangeQuery(cQuery, .F.)

cInsert := " INSERT INTO "+ oTmpTable:GetRealName() +" ( "
cInsert += " TP_CONTA, VALOR ) "
cInsert += cQuery

If (TCSQLExec(cInsert) < 0) //Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
	JurLogMsg( TCSQLError() )
EndIf

Return oTmpTable

//-------------------------------------------------------------------
/*/{Protheus.doc} JQrySumTpC()
Rotina para gerar a query com os filtros e as soma do relatório
para os tipos de contas '2','3','4','6','8'.

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQrySumTpC(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
Local cQuery := ""

cQuery := " SELECT "
cQuery +=     " OHBCONTA.TP_CONTA, "
cQuery +=     " ISNULL(SUM(OHBCONTA.VALOR),0) VALOR "
cQuery += " FROM ( "
cQuery +=     " SELECT "
cQuery +=         " TMP_ORI.TP_CONTA_ORI TP_CONTA, "
cQuery +=         " TMP_ORI.OHB_VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = TMP_ORI.TP_CONTA_ORI AND TIPO = 'O') VALOR "
cQuery +=     " FROM ( "
cQuery += JQryFilTpC(dDtInicio, dDtFinal, cMoeda, cFilOri)
cQuery +=     " )TMP_ORI "

cQuery +=     " UNION ALL "

cQuery +=     " SELECT "
cQuery +=         " TMP_DES.TP_CONTA_DES TP_CONTA, "
cQuery +=         " TMP_DES.OHB_VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = TMP_DES.TP_CONTA_DES AND TIPO = 'D') VALOR "
cQuery +=     " FROM ( "
cQuery += JQryFilTpC(dDtInicio, dDtFinal, cMoeda, cFilOri)
cQuery +=     " )TMP_DES "
cQuery += " ) OHBCONTA "
cQuery += " GROUP BY OHBCONTA.TP_CONTA "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryFilTpC()
Rotina para gerar a sub query com os filtros do relatório para os tipos de contas
'2','3','4','6','8'.

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQryFilTpC(dDtInicio, dDtFinal, cMoeda, cFilOri)
Local cQuery := ""

cQuery += " SELECT "
cQuery +=     " OHB.OHB_VALOR, "
cQuery +=     " SEDO.ED_TPCOJR  TP_CONTA_ORI, "
cQuery +=     " SEDD.ED_TPCOJR  TP_CONTA_DES "
cQuery += " FROM " + RetSqlName("OHB") + " OHB "
cQuery +=     " INNER JOIN " + RetSqlName("SED") + " SEDO "
cQuery +=         " ON  SEDO.ED_FILIAL = '" +xFilial("SED") + "' "
cQuery +=         " AND SEDO.ED_CODIGO = OHB.OHB_NATORI "
cQuery +=         " AND SEDO.D_E_L_E_T_ = ' ' "
cQuery +=     " INNER JOIN " + RetSqlName("SED") + " SEDD "
cQuery +=         "ON  SEDD.ED_FILIAL = '" +xFilial("SED") + "' "
cQuery +=         "AND SEDD.ED_CODIGO = OHB.OHB_NATDES "
cQuery +=         "AND SEDD.D_E_L_E_T_ = ' ' "
cQuery += " WHERE OHB.OHB_FILORI = '" + cFilOri + "' "
cQuery +=     " AND OHB.OHB_CMOELC = '" + cMoeda + "' "
cQuery +=     " AND OHB.OHB_DTLANC >= '" + DTOS(dDtInicio) + "' AND OHB.OHB_DTLANC <= '" + DTOS(dDtFinal) + "' "
cQuery +=     " AND OHB.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryTransf()
Rotina para gerar a query de Transferências entre Naturezas de outras Moedas

@author Bruno Ritter / Thiago Malaquias
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQryTransf(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
Local cQuery := ""

cQuery := " SELECT "
cQuery +=        " 'T' TP_CONTA, "
cQuery +=        " ISNULL(SUM(SOMA.VALOR_TRANSF), 0) VALOR "
cQuery += " FROM ( "
cQuery += " SELECT "
cQuery +=       " CASE "
cQuery +=           " WHEN '" + cMoeda + "' = OHB_FILTER.MOEDA_ORI  THEN (VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = OHB_FILTER.TP_CONTA_ORI AND TIPO = 'O')) "
cQuery +=           " WHEN '" + cMoeda + "' = OHB_FILTER.MOEDA_DES  THEN (VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = OHB_FILTER.TP_CONTA_DES AND TIPO = 'D')) "
cQuery +=       " END VALOR_TRANSF "
cQuery += " FROM ( "
cQuery +=       " SELECT "
cQuery +=               " CASE "
cQuery +=                   " WHEN '" + cMoeda + "' = OHB.OHB_CMOEC  THEN OHB.OHB_VALORC "
cQuery +=                   " WHEN '" + cMoeda + "' = OHB.OHB_CMOELC THEN OHB.OHB_VALOR "
cQuery +=                   "ELSE 0 "
cQuery +=               " END VALOR, "
cQuery +=               " SEDO.ED_CMOEJUR MOEDA_ORI, "
cQuery +=               " SEDO.ED_TPCOJR  TP_CONTA_ORI, "
cQuery +=               " SEDD.ED_CMOEJUR MOEDA_DES, "
cQuery +=               " SEDD.ED_TPCOJR  TP_CONTA_DES "
cQuery +=       " FROM " + RetSqlName('OHB') + " OHB "
cQuery +=               " INNER JOIN " + RetSqlName('SED') + " SEDO "
cQuery +=                   " ON  SEDO.ED_FILIAL = '" +xFilial("SED") + "' "
cQuery +=                   " AND SEDO.ED_CODIGO = OHB.OHB_NATORI "
cQuery +=                   " AND SEDO.D_E_L_E_T_ = ' ' "
cQuery +=               " INNER JOIN " + RetSqlName('SED') + " SEDD "
cQuery +=                   " ON  SEDD.ED_FILIAL = '" +xFilial("SED") + "' "
cQuery +=                   " AND SEDD.ED_CODIGO = OHB.OHB_NATDES "
cQuery +=                   " AND SEDD.D_E_L_E_T_ = ' ' "
cQuery +=       " WHERE OHB.OHB_FILORI = '" + cFilOri + "' "
cQuery +=               " AND (OHB.OHB_CMOEC = '" + cMoeda + "' OR OHB.OHB_CMOELC = '" + cMoeda + "') "
cQuery +=               " AND OHB.OHB_DTLANC >= '" + DTOS(dDtInicio) +"' AND OHB.OHB_DTLANC <= '" + DTOS(dDtFinal) +"' "
cQuery +=               " AND OHB.D_E_L_E_T_ = ' ' "
cQuery +=               " AND SEDO.ED_CMOEJUR <> SEDD.ED_CMOEJUR "
cQuery +=               " AND (SEDO.ED_TPCOJR IN ('1', '7') OR SEDD.ED_TPCOJR IN ('1', '7')) "
cQuery +=       " ) OHB_FILTER "
cQuery += " ) SOMA "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryMovAnt()
Rotina para pegar toda a movimentacoes do mes anterior

@author Bruno Ritter / Thiago Malaquias
@since 29/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQryMovAnt(cTpContTmp, dDtInicio, cMoeda, cFilOri)
Local aArea   := GetArea()
Local cQuery  := ""
Local cQryRes := GetNextAlias()
Local nValor  := 0

cQuery := " SELECT "
cQuery +=    " SUM( "
cQuery +=        " CASE "
cQuery +=            " WHEN TOTAL.ED_TPCOJR = '1' THEN  TOTAL.VALOR "
cQuery +=            " WHEN TOTAL.ED_TPCOJR = '7' THEN - TOTAL.VALOR "
cQuery +=        " ELSE 0 "
cQuery +=     " END) VALOR "
cQuery += " FROM ( "
cQuery +=      " SELECT SUM(TAB.VALOR) VALOR, TAB.ED_TPCOJR "
cQuery +=       " FROM ( 
cQuery +=          " SELECT SED.ED_TPCOJR, SED.ED_CODIGO, (OHB.OHB_VALOR * TPCONTA.SINAL) VALOR "
cQuery +=          " FROM " + RetSqlName("OHB") + " OHB "
cQuery +=    " INNER JOIN " + RetSqlName("SED") + " SED "
cQuery +=            " ON SED.ED_FILIAL = '" +xFilial("SED") + "' "
cQuery +=           " AND SED.ED_CODIGO = OHB.OHB_NATORI "
cQuery +=           " AND SED.ED_TPCOJR IN ('1','7') "
cQuery +=           " AND SED.ED_CCJURI IN (' ','1','2','3','4','5') "
cQuery +=           " AND SED.D_E_L_E_T_ = ' ' "
cQuery +=    " INNER JOIN " + cTpContTmp + " TPCONTA "
cQuery +=            " ON TPCONTA.CODIGO = SED.ED_TPCOJR "
cQuery +=           " AND TPCONTA.TIPO = 'O' "
cQuery +=         " WHERE OHB.OHB_FILORI = '" + cFilOri + "' "
cQuery +=           " AND OHB.OHB_CMOELC = '" + cMoeda + "' "
cQuery +=         " AND OHB.OHB_DTLANC < " + DTOS(dDtInicio) + " "
cQuery +=           " AND OHB.D_E_L_E_T_ = ' ' "

cQuery += " UNION ALL "

cQuery +=       " SELECT SED.ED_TPCOJR, SED.ED_CODIGO, (OHB.OHB_VALOR * TPCONTA.SINAL) VALOR "
cQuery +=          " FROM " + RetSqlName("OHB") + " OHB "
cQuery +=    " INNER JOIN " + RetSqlName("SED") + " SED "
cQuery +=            " ON SED.ED_FILIAL = '" +xFilial("SED") + "' "
cQuery +=           " AND SED.ED_CODIGO = OHB.OHB_NATDES "
cQuery +=           " AND SED.ED_TPCOJR IN ('1','7') "
cQuery +=           " AND SED.ED_CCJURI IN (' ','1','2','3','4','5') "
cQuery +=           " AND SED.D_E_L_E_T_ = ' ' "
cQuery +=    " INNER JOIN " + cTpContTmp + " TPCONTA "
cQuery +=            " ON TPCONTA.CODIGO = SED.ED_TPCOJR "
cQuery +=           " AND TPCONTA.TIPO = 'D' "
cQuery +=         " WHERE OHB.OHB_FILORI = '" + cFilOri + "' "
cQuery +=           " AND OHB.OHB_CMOELC = '" + cMoeda + "' "
cQuery +=           " AND OHB.OHB_DTLANC < " + DTOS(dDtInicio) + " "
cQuery +=           " AND OHB.D_E_L_E_T_ = ' ' "
cQuery +=           " ) TAB "
cQuery += " GROUP BY TAB.ED_TPCOJR) TOTAL "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)

If (cQryRes)->(!EOF())
	nValor  := (cQryRes)->VALOR
EndIf

(cQryRes)->(DbCloseArea())

RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JRetSaldo()
Rotina para gerar a SubQuery saldo de naturezas por conta.

@Param cTpCont - Tipo de conta jurídica
				'T' - Transferências entre Naturezas de outras Moedas
				'S' - Sub-Total de Saídas
				'R' - Resultado do Mês
				'2' - Custo direto
				'3' - Receitas
				'4' - Investimentos
				'6' - Obrigações Fiscais
				'8' - Despesas Gerais do Escritório:

@cSomCntTmp  - Nome da tabela temporária com os valores para totalizar.

@nValorAnt   - Valor total do mês anterior (usado para calcular o resultado do mês)

@return nValor - Valor do saldo de naturezas por mês.

@author Luciano Pereira dos Santos
@since 30/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRetSaldo(cTpCont, cSomCntTmp, nValorAnt)
Local aArea   := GetArea()
Local cQuery  := ""
Local cQryRes := GetNextAlias()
Local nValor  := 0

Default nValorAnt := 0

If cTpCont $ "2|3|4|6|8|T"
	cQuery := "SELECT VALOR FROM " + cSomCntTmp + " WHERE TP_CONTA = '" + cTpCont + "'"

ElseIf cTpCont == 'S'
	cQuery := "SELECT (SUM(VALOR) * -1) VALOR FROM " + cSomCntTmp + " WHERE TP_CONTA IN('2','8','4','6') " // Sub-Total de Saídas

ElseIf cTpCont == 'R'
	cQuery := " SELECT ISNULL(SUM(RESULT.VALOR), 0) VALOR  FROM ("
	cQuery += " SELECT SUM(VALOR) VALOR FROM " + cSomCntTmp + " WHERE TP_CONTA IN('3','T') " // Sub-Total Receita e Transferencias
	cQuery += " UNION ALL "
	cQuery += " SELECT (SUM(VALOR) * -1) VALOR FROM " + cSomCntTmp + " WHERE TP_CONTA IN('2','8','4','6') " // Sub-Total de Saídas
	cQuery += " ) RESULT"  // Resultado do Mês
EndIf

cQuery := ChangeQuery(cQuery, .F.)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)

If (cQryRes)->(!EOF())
	nValor  := (cQryRes)->VALOR
EndIf

(cQryRes)->(DbCloseArea())

If cTpCont == 'R'
	nValor += nValorAnt 
EndIf

RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryPosCx()
Rotina para gerar a query com os filtros do relatório para os tipos de contas
'1','7'. (posição final de caixa)

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQryPosCx(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
Local cQuery := ""

cQuery := " SELECT TAB.ED_TIPO, TAB.ED_TPCOJR, TAB.COD_PAI, TAB.DESC_PAI,TAB.ED_CODIGO, TAB.ED_DESCRIC, SUM(TAB.VALOR) VALOR "
cQuery += " FROM ( SELECT "
cQuery +=              " SED.ED_TIPO, "
cQuery +=              " SED.ED_TPCOJR, "
cQuery +=              " SEDPAI.ED_CODIGO COD_PAI, "
cQuery +=              " SEDPAI.ED_DESCRIC DESC_PAI, "
cQuery +=              " SED.ED_CODIGO, "
cQuery +=              " SED.ED_DESCRIC, "
cQuery +=              " OHB.OHB_VALOR * TPCONTA.SINAL VALOR "
cQuery +=         " FROM " + RetSqlName("OHB") + " OHB "
cQuery +=         " INNER JOIN " + RetSqlName("SED") + " SED "
cQuery +=                 " ON SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
cQuery +=                " AND SED.ED_CODIGO = OHB.OHB_NATORI "
cQuery +=                " AND SED.ED_TPCOJR IN ('1','7') "
cQuery +=                " AND SED.ED_CCJURI IN (' ','1','2','3','4','5') "
cQuery +=                " AND SED.D_E_L_E_T_ = ' ' "
cQuery +=         " INNER JOIN " + cTpContTmp + " TPCONTA "
cQuery +=                 " ON TPCONTA.CODIGO = SED.ED_TPCOJR "
cQuery +=                " AND TPCONTA.TIPO = 'O' "
cQuery +=         " LEFT JOIN " + RetSqlName("SED") + " SEDPAI "
cQuery +=                " ON SEDPAI.ED_FILIAL = '"+ xFilial("SED")+ "' "
cQuery +=               " AND SEDPAI.ED_CODIGO = SED.ED_PAI "
cQuery +=               " AND SED.D_E_L_E_T_ = ' ' "
cQuery +=         " WHERE OHB.OHB_FILORI = '" + cFilOri + "' "
cQuery +=           " AND OHB.OHB_CMOELC = '" + cMoeda + "' "
cQuery +=           " AND OHB.OHB_DTLANC <= '" + DTOS(dDtFinal) + "' "
cQuery +=           " AND OHB.D_E_L_E_T_ = ' ' "

cQuery +=        " UNION ALL "

cQuery +=        " SELECT "
cQuery +=                " SED.ED_TIPO, "
cQuery +=                " SED.ED_TPCOJR, "
cQuery +=                " SEDPAI.ED_CODIGO COD_PAI, "
cQuery +=                " SEDPAI.ED_DESCRIC DESC_PAI, "
cQuery +=                " SED.ED_CODIGO, "
cQuery +=                " SED.ED_DESCRIC, "
cQuery +=                " OHB.OHB_VALOR * TPCONTA.SINAL VALOR "
cQuery +=         " FROM " + RetSqlName("OHB") + " OHB "
cQuery +=         " INNER JOIN " + RetSqlName("SED") + " SED "
cQuery +=                 " ON SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
cQuery +=                " AND SED.ED_CODIGO = OHB.OHB_NATDES "
cQuery +=                " AND SED.ED_TPCOJR IN ('1','7') "
cQuery +=                " AND SED.ED_CCJURI IN (' ','1','2','3','4','5') "
cQuery +=                " AND SED.D_E_L_E_T_ = ' ' "
cQuery +=         " INNER JOIN " + cTpContTmp + " TPCONTA "
cQuery +=                 " ON TPCONTA.CODIGO = SED.ED_TPCOJR "
cQuery +=                " AND TPCONTA.TIPO = 'D' "
cQuery +=         " LEFT JOIN " + RetSqlName("SED") + " SEDPAI "
cQuery +=                " ON SEDPAI.ED_FILIAL = '"+ xFilial("SED")+ "' "
cQuery +=               " AND SEDPAI.ED_CODIGO = SED.ED_PAI "
cQuery +=               " AND SED.D_E_L_E_T_ = ' ' "
cQuery +=         " WHERE OHB.OHB_FILORI = '" + cFilOri + "' "
cQuery +=           " AND OHB.OHB_CMOELC = '" + cMoeda + "' "
cQuery +=           " AND OHB.OHB_DTLANC <= '" + DTOS(dDtFinal) + "' "
cQuery +=           " AND OHB.D_E_L_E_T_ = ' ' "
cQuery +=        " ) TAB "
cQuery += " GROUP BY TAB.ED_TIPO, TAB.ED_TPCOJR, TAB.COD_PAI, TAB.DESC_PAI,TAB.ED_CODIGO, TAB.ED_DESCRIC "
cQuery += " ORDER BY TAB.ED_TPCOJR, TAB.ED_TIPO, TAB.COD_PAI "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JRetPosCx()
Rotina para gerar os dados '1','7'. (posição final de caixa)

@Return aRet, Retorno com os valores totais de contas, natureza pai, e naturezas analisticas

aRet[1] "6. Banco/Caixas" (ED_TPCOJR = '1')
aRet[2] "7. Contas de Sócios/Profissionais" (ED_TPCOJR = '7')
aRet[3] "8. Resultado do Mês"

aRet[n][1], Código da natureza Sintética
aRet[n][2], Valor total da natureza Sintética
aRet[n][3], Array com as naturezas Analitica detalhadas

aRet[n][n][1], Código - Descrição da Natureza Analitica
aRet[n][n][2], Valor da Natureza Analitica

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRetPosCx(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
Local cQRY       := GetNextAlias()
Local aRet       := {}
Local nVlTotal   := 2
Local nSubArray  := 3
Local nPosPaiAtu := 0
Local nPosTpCont := 0
Local nSinal     := 1
Local cQuery     := ""
Local cNatFilNm  := ""
Local cNatPaiAtu := ""
Local cNatPaiNm  := ""
Local cContAtu   := ""
Local cContDesc  := ""
Local nTotal     := 0

cQuery := JQryPosCx(cTpContTmp, dDtInicio, dDtFinal, cMoeda, cFilOri)
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQRY,.T.,.T.)
(cQRY)->( dbGoTop() )

While !(cQRY)->(EOF())

	If cContAtu != (cQRY)->ED_TPCOJR
		cNatPaiAtu := ""
		nPosPaiAtu := 0
		cContAtu   := (cQRY)->ED_TPCOJR
		nPosTpCont += 1
		nSinal     := Iif(cContAtu == "7", -1, 1) //Conta de Profissional inverte o sinal
		cContDesc  := Iif(cContAtu == "7", STR0026, STR0025) //#"7. Contas de Sócios/Profissionais" ##"6. Banco/Caixas"

		Aadd(aRet, {cContDesc, 0, {} })
	EndIf

	If cNatPaiAtu != (cQRY)->COD_PAI
		nPosPaiAtu += 1
		cNatPaiAtu := (cQRY)->COD_PAI

		cNatPaiNm := Iif(!Empty((cQRY)->COD_PAI + (cQRY)->DESC_PAI), AllTrim(cNatPaiAtu) + " - " + AllTrim((cQRY)->DESC_PAI), " ")

		Aadd(aRet[nPosTpCont][nSubArray], {cNatPaiNm, 0, {} })

	EndIf

	cNatFilNm := AllTrim((cQRY)->ED_CODIGO) + " - " + AllTrim((cQRY)->ED_DESCRIC)

	Aadd(aRet[nPosTpCont][nSubArray][nPosPaiAtu][nSubArray], {cNatFilNm, (cQRY)->VALOR} )

	nTotal += (cQRY)->VALOR * nSinal

	aRet[nPosTpCont][nVlTotal] += (cQRY)->VALOR

	aRet[nPosTpCont][nSubArray][nPosPaiAtu][nVlTotal] += (cQRY)->VALOR

	(cQRY)->(dbSkip())
EndDo

Aadd(aRet, {STR0027, nTotal, {}}) //#"8. Resultado do Mês"

(cQRY)->(dbCloseArea())

Return aRet
