#INCLUDE "JURAPAD032.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE IMP_PDF   6
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   3000 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     2350 // Linha Final da página de um relatório
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relatório

Static __lAuto := .F.  // Indica se a chamada foi feita via automação

//-------------------------------------------------------------------
/*/{Protheus.doc} JURTOTAIS
Classe para controle dos tipos de contas do PFS, utilizado no financeiro/Centro de custos

@author Luciano Pereira / Jorge Martins
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class JURTOTAIS

Data aSection  // Lista de Sessões

Method New() Constructor
Method SetSections()
Method GetSection()
Method OperSection()

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Construtor da Classe JURTOTAIS

@author Luciano Pereira / Jorge Martins
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JURTOTAIS

	Self:aSection := Array(14)

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSections(aSessao)
Método para armazenar o array totalizador da sessão

@author Luciano Pereira / Jorge Martins
@since 22/03/2018
/*/
//-------------------------------------------------------------------
Method SetSections(aSessao, nSessao) Class JURTOTAIS

	Self:aSection[nSessao] := aClone(aSessao)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSection(aSessao)
Método para retornar o array totalizador da sessão

@author Luciano Pereira / Jorge Martins
@since 22/03/2018
/*/
//-------------------------------------------------------------------
Method GetSection(nSection) Class JURTOTAIS
Local aRet := {}

aRet := Self:aSection[nSection]

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OperSection(aSessao)
Método para gerar array de sessões de resultado

@author Luciano Pereira / Jorge Martins
@since 22/03/2018
/*/
//-------------------------------------------------------------------
Method OperSection(nSection1, nSection2, nSecResult) Class JURTOTAIS
Local aSection1 := Self:GetSection(nSection1)
Local aSection2 := Self:GetSection(nSection2)
Local aSection3 := Array(Len(aSection1))
Local nI        := 0

For nI := 1 to Len(aSection1)

	aSection3[nI] := aSection1[nI] - aSection2[nI]

Next nI

Self:aSection[nSecResult] := aClone(aSection3)

Return aSection3

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD032
Relatório de Resultado Financeiro

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameAuto, Nome do arquivo de relatório usado na automação

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD032(lAutomato, cNameAuto)
	Local aArea     := GetArea()
	Local lCanc     := .F.
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	Default lAutomato := .F.
	Default cNameAuto := ""

	__lAuto := lAutomato

	If lPDUserAc
		While !lCanc
			If __lAuto .Or. JPergunte()
				If JP032TdOk(MV_PAR01, MV_PAR02, MV_PAR03)
					Processa( {|| JP032Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, cNameAuto)} , STR0014, STR0034, .F. ) //#"Relatório de Resultado Financeiro", ##"Gerando relatório..."
					If __lAuto // Se for automação seta lCanc .T. para sair do while
						lCanc := .T.
					EndIf
				EndIf
			Else
				lCanc := .T.
			Endif
		EndDo
	Else
		MsgInfo(STR0035, STR0036) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
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

	lRet := Pergunte('JURAPAD032')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP032VlAno
Valida o ano de referência.

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP032VlAno(nAno)
Local lRet := .T.

If nAno < 0
	JurMsgErro(STR0001,,STR0002) // "O ano não pode ser negativo." - "Informe um ano valido."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP032VlMes
Valida o mês inicial e final

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP032VlMes(nMesInc, nMesFim)
Local lRet := .T.

If nMesInc < 0 .Or. nMesFim < 0
	JurMsgErro(STR0003,,STR0004) // "O mês não pode ser negativo." - "Informe um mês valido."
	lRet := .F.
EndIf

If nMesInc > 12 .Or. nMesFim > 12
	JurMsgErro(STR0005,,STR0004) // "Mês não pode ser maior que '12'." - "Informe um mês valido."
	lRet := .F.
EndIf

If lRet .And. nMesInc > 0 .And. nMesFim > 0 .And. nMesInc > nMesFim
	JurMsgErro(STR0006,,STR0004) // "O mês inicial não pode ser maior que o mês final." - "Informe um mês valido."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP032VlEct
Valida o escritório.

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP032VlEct(cEscrt)
Local lRet    := .T.
Local cRetNS7 := ""

If !Empty(cEscrt)
	cRetNS7 := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrt, "NS7_COD" )
	If Empty(cRetNS7)
		JurMsgErro(STR0007,,STR0008) // "Escritório não encontrado." - "Informe um escritório valido."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP032TdOk
Rotina validar os dados do pergunte

@author Bruno Ritter
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JP032TdOk(nAno, nMesInc, nMesFim)
Local lRet := .T.

If lRet .And. nAno == 0
	JurMsgErro(STR0009,,STR0010) // "O ano é obrigatório." - "Informe um ano válido."
	lRet := .F.
EndIf

If lRet .And. ( nMesInc == 0 .Or. nMesFim == 0 )
	JurMsgErro(STR0011,,STR0012) // "O mês é obrigatório." - "Informe um mês válido."
	lRet := .F.
EndIf

If ( nMesFim - nMesInc + 1 ) > 6
	JurMsgErro(STR0013,,STR0004) // "O periódo não pode ser maior que 6 meses" - "Informe um mês valido."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP032Relat
Rotina para o processamento do relatório.

@author Jorge Martins / Luciano Pereira
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JP032Relat(nAno, nMesIni, nMesFinal, cEscrit, cNameAuto)
Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.)   // Fonte usada no nome do relatório
Local oFontCabec := TFont():New("Arial",,-16,,.T.,,,,.T.,.F.)   // Fonte usada no cabeçalho
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos títulos do relatório (Título de campos e títulos no cabeçalho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos títulos das sessões

Local cTpContTmp := ""
Local nI         := 0
Local nPosIni    := 0
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}
Local aCampos    := {}
Local aMeses     := JGetMeses(nAno, nMesIni, nMesFinal)
Local cDataHora  := Alltochar(Date()) + " - " + Time()
Local oTpConta   := JurTpConta():New()

ProcRegua(0)
IncProc()

oTpConta:GeraTmp()
cTpContTmp := oTpConta:GetTmpName()

//Título do Relatório
  // 1 - Título,
  // 2 - Posição da descrição,
  // 3 - Fonte do título
aRelat := {STR0014, 1150, oFont} //"Relatório de Resultado Financeiro"

//Cabeçalho do Relatório
  // 1 - Título,
  // 2 - Conteúdo,
  // 3 - Posição de início da descrição(considere 20,5 para cada caractere do título, ou seja se o título tiver 6 caracteres indique 6x20,5 = 123.
  //     Indique esse número para todos os itens do cabeçalho, para que todos tenham o mesmo alinhamento.
  //     Para isso considere sempre a posição da maior descrição),
  // 4 - Fonte do título,
  // 5 - Fonte da descrição
//aCabec := {{"Data Compromisso: "   ,DToC(Date()) ,(nTamCarac*16),oFontTit,oFontDesc}}//,;

For nI := 1 To Len(aMeses)
	aAdd(aCabec, {aMeses[nI][1] , "", (nTamCarac*9), oFontCabec, oFontCabec} )
Next

//Campos do Relatório
  //Exemplo da primeira parte -> aAdd(aSessao, {"Relatório de Follow-ups",65,oFontSub,.F.,;//
  // 1 - Título da sessão do relatório,
  // 2 - Posição de início da descrição,
  // 3 - Fonte no quadro com título da sessão,
  // 4 - Impressão na horizontal -> Título e descrição na mesma linha (Ex: Data: 01/01/2016)
  // 5 - Query do subreport - Se for parte do relatório principal não precisa ser indicado
  // 6 - Tipo de Sessão - 1 - Normal, 2 - Totalizador de Sessão, 3 - Sessão de Resultados
  // 7 - aCampos - Arrays de Campos da sessão com as seguintes
      // 1 - Título do campo,
      // 2 - Tabela do campo,
      // 3 - Nome do campo no dicionário,
      // 4 - Nome do Campo na Query,
      // 5 - Tipo do Campo,
      // 6 - Indica a coordenada horizontal em pixels ou caracteres,
      // 7 - Tamanho que o conteúdo pode ocupar,
      // 8 - Fonte do título,
      // 9 - Fonte da descrição
      // 10 - Posição de início da descrição
      // 11 - Quebra Linha após impressão do conteúdo?
  // 8 - Array com número da sessão para totalizador -> {1}     - Indica que deve totalizar o conteúdo da sessão 1
  //                                                    {1,3,5} - Indica que deve gravar na sessão 5, o valor total da sessão 1 - valor total da sessão 3

nPosIni := 750

aAdd(aCampos, {"", "SED","ED_CODIGO"  ,"ED_CODIGO"  ,"C",65     , 500 ,oFontTit,oFontDesc,0,.F.})
aAdd(aCampos, {"", "SED","ED_DESCRIC" ,"ED_DESCRIC" ,"C",250    , 900 ,oFontTit,oFontDesc,0,.F.})

For nI := 1 To Len(aMeses)
	aAdd(aCampos, {"", "OHB","OHB_VALOR", aMeses[nI][3],"N",nPosIni, 500 ,oFontTit,oFontDesc,0,.F.})
	nPosIni += 250
Next

aAdd(aCampos, {"", "OHB","OHB_VALOR" ,"REALIZADO" ,"N",nPosIni + 50 , 500 ,oFontTit,oFontDesc,0,.F.})
aAdd(aCampos, {"", "SE7","E7_VALJAN1","ORCADO"    ,"N",2600         , 500 ,oFontTit,oFontDesc,0,.F.})
aAdd(aCampos, {"", "AA1","AA1_RATE  ","PERCEN"    ,"N",2775         , 500 ,oFontTit,oFontDesc,0,.T.})

aAdd(aSessao, { STR0015, 65, oFontSub, .T., JSubReport("3", aMeses, cTpContTmp),1, aCampos             } ) // "ENTRADAS"
aAdd(aSessao, { STR0016, 65, oFontSub, .T.,                                    ,2, aCampos, {1}        } ) // "1 - TOTAL DE ENTRADAS"

aAdd(aSessao, { STR0017, 65, oFontSub, .T., JSubReport("2", aMeses, cTpContTmp),1, aCampos             } ) // "CUSTOS"
aAdd(aSessao, { STR0018, 65, oFontSub, .T.,                                    ,2, aCampos, {3}        } ) // "2 - TOTAL DE CUSTOS"

aAdd(aSessao, { STR0019, 65, oFontSub, .T.,                                    ,3, aCampos, {1,3,5}    } ) // "3 - MARGEM DE CONTRIBUIÇÃO (1-2)"

aAdd(aSessao, { STR0020, 65, oFontSub, .T., JSubReport("8", aMeses, cTpContTmp),1, aCampos             } ) // "DESPESAS"
aAdd(aSessao, { STR0021, 65, oFontSub, .T.,                                    ,2, aCampos, {6}        } ) // "4 - TOTAL DE DESPESAS"

aAdd(aSessao, { STR0022, 65, oFontSub, .T.,                                    ,3, aCampos, {5,6,8}    } ) // "5 - RESULTADO ANTES DO IR (3-4)"

aAdd(aSessao, { STR0023, 65, oFontSub, .T., JSubReport("6", aMeses, cTpContTmp),1, aCampos             } ) // "OBRIGAÇÕES FISCAIS"
aAdd(aSessao, { STR0024, 65, oFontSub, .T.,                                    ,2, aCampos, {9}        } ) // "6 - TOTAL DE OBRIGAÇÕES"

aAdd(aSessao, { STR0025, 65, oFontSub, .T.,                                    ,3, aCampos, {8,9,11}   } ) // "7 - RESULTADO LÍQUIDO (5-6)"

aAdd(aSessao, { STR0026, 65, oFontSub, .T., JSubReport("4", aMeses, cTpContTmp),1, aCampos             } ) // "INVESTIMENTOS"
aAdd(aSessao, { STR0027, 65, oFontSub, .T.,                                    ,2, aCampos, {12}       } ) // "8 - TOTAL DE INVESTIMENTOS"

aAdd(aSessao, { STR0028, 65, oFontSub, .T.,                                    ,3, aCampos, {11,12,14} } ) // "9 - RESULTADO FINANCEIRO (7-8)"

JRelatorio(aRelat,aCabec,aSessao, JMainReport(cEscrit, aMeses), nAno, nMesIni, nMesFinal, cDataHora, cNameAuto) //Chamada da função de impressão do relatório em FWMsPrinter

oTpConta:Destroy()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JMainReport(cEscrit, aMeses)
Rotina para gerar a query do report principal do relatorio de
Resumo Financeiro.

@param cEscrit - Escritório para filtro
@param aMeses  - Array com as informações dinamicas dos meses
                 aMeses[nI][1] Descrição do mês.
                 aMeses[nI][2] Mês do saldo por Natureza.
                 aMeses[nI][3] Campo da SE7.

@return cQry   - Query principal do relatório (Filtro por escritório)

@author Luciano Pereira dos Santos
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JMainReport(cEscrit, aMeses)
Local cQry     := " "
Local cMesIni  := DtoS(aMeses[1][2])
Local cMesFin  := DtoS(LastDay(aMeses[Len(aMeses)][2]))
Local cFilEscr := ""

If !Empty(cEscrit)
	cFilEscr := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
EndIf

cQry := " SELECT NS7.NS7_RAZAO, NS7.NS7_CFILIA "
cQry +=     "  FROM " + RetSqlName("NS7") + " NS7 "
cQry +=     " WHERE NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
If !Empty(cEscrit)
	cQry +=   " AND NS7.NS7_COD = '" + cEscrit + "' "
EndIf
cQry +=       " AND NS7.D_E_L_E_T_ = ' ' "
cQry +=       " AND EXISTS (SELECT DISTINCT SED.R_E_C_N_O_ "
cQry +=                     " FROM " + RetSqlName("SED") + " SED "
cQry +=                    " INNER JOIN " + RetSqlName("OHB") + " OHB "
cQry +=                          " ON (OHB.OHB_NATORI = SED.ED_CODIGO OR OHB.OHB_NATDES = SED.ED_CODIGO) "
If !Empty(cEscrit)
	cQry +=                     " AND OHB.OHB_FILIAL = '" + cFilEscr + "' "
EndIf
cQry +=                         " AND OHB.D_E_L_E_T_ = ' ' "
cQry +=                         " AND OHB.OHB_DTLANC BETWEEN '"+ cMesIni +"' AND '"+ cMesFin +"' "
cQry +=                       " WHERE SED.ED_FILIAL = '" + xFilial("SED") + "' "
cQry +=                         " AND SED.ED_TPCOJR IN ('2','3','4','6','8') "
cQry +=                         " AND SED.D_E_L_E_T_ = ' ' )"

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} JSubReport(cEscrit, aMeses)
Rotina para gerar a query dos Subreports do relatorio de Resumo Financeiro.

@Param cTpConta - Tipo de Conta do Escritório
@Param aMeses   - Array com as informações dinamicas dos meses
		aMeses[nI][1] Descrição do mês.
		aMeses[nI][2] Mês do saldo por Natureza.
		aMeses[nI][3] Campo da SE7.
@Param cTpContTmp - Tabela temporária com os dados dos tipos de conta

@return cQry   Query do Subreport por Natureza.

@author Luciano Pereira dos Santos
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JSubReport(cTpConta, aMeses, cTpContTmp)
Local cQry        := ""
Local nI          := 0
Local cSaldoMes   := ""
Local cOrcado     := ""
Local cOrcado2    := ""
Local cRealiazado := ""

For nI := 1 to Len(aMeses)
	cSaldoMes += "SUM(TOTAL."+aMeses[nI][3] + " ) "+aMeses[nI][3]+ ", "
	cOrcado   += "SUM(SE7."+aMeses[nI][3] + " ) + "
Next nI

cRealiazado := " SUM(TOTAL.REALIZADO) "
cOrcado2    := " (" + Left(cOrcado, Len(cOrcado)-2) + ") " //Remove o ultimo '+'

cQry += " SELECT "
cQry +=     " TOTAL.ED_FILIAL, "
cQry +=     " TOTAL.ED_CODIGO, "
cQry +=     " TOTAL.ED_DESCRIC, "
cQry +=     " TOTAL.ED_CMOEJUR, "
cQry +=     cSaldoMes
cQry +=     cRealiazado + " REALIZADO, "
cQry +=     cOrcado2 + " ORCADO, "
cQry +=                " (CASE WHEN " + cOrcado2 + " IS NULL THEN 0
cQry +=                           " WHEN " + cOrcado2 + " = 0 THEN 0
cQry +=                           " ELSE (" + cRealiazado + " / " + cOrcado2 +") * 100 END) PERCEN "
cQry += " FROM ( "
cQry +=        JQryTotal(cTpContTmp, aMeses, "O" , cTpConta)
cQry +=        " UNION ALL"
cQry +=        JQryTotal(cTpContTmp, aMeses, "D" , cTpConta)
cQry += " ) TOTAL "

cQry += " LEFT OUTER JOIN " + RetSqlName("SE7") + " SE7 "
cQry +=       " ON ( SE7.E7_FILIAL = '@#NS7_CFILIA#@' "
cQry +=       " AND SE7.E7_NATUREZ = TOTAL.ED_CODIGO "
cQry +=       " AND SE7.D_E_L_E_T_ = ' ' ) "

cQry += " GROUP BY TOTAL.ED_FILIAL, "
cQry +=       " TOTAL.ED_CODIGO, "
cQry +=       " TOTAL.ED_DESCRIC, "
cQry +=       " TOTAL.ED_CMOEJUR "
cQry += " ORDER BY TOTAL.ED_CODIGO "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} JSaldoMes(aMeses)
Rotina para gerar a SubQuery saldo de naturezas por mês.

@Param aMeses  - Array com as informações dinamicas dos meses
		aMeses[1] Descrição do mês.
		aMeses[2] Mês do saldo por Natureza.
		aMeses[3] Campo da SE7.

@Param cOriDest - O tipo da natureza no lançamento O = Origem, D = Destino

@return cQry    - SubQuery de somatória de saldo de naturezas por mês.

@author Luciano Pereira dos Santos
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JSaldoMes(aMeses, cOriDest, cTpContTmp)
Local cQry       := ""
Local cCpoOriDes := Iif(cOriDest == "O", "OHB_NATORI", "OHB_NATDES")
Local cMes       := aMeses[3]

cQry += " ( SELECT SUM( OHBMES.OHB_VLNAC * TPCONTA.SINAL) VALOR "
cQry +=   " FROM " + RetSqlName("OHB") + " OHBMES, "
cQry +=        " " + cTpContTmp        + " TPCONTA "
cQry +=   " WHERE OHBMES.OHB_FILIAL = '@#NS7_CFILIA#@' "
cQry +=     " AND OHBMES." + cCpoOriDes + " = SED.ED_CODIGO "
cQry +=     " AND TPCONTA.TIPO = '" + cOriDest + "'
cQry +=     " AND TPCONTA.CODIGO = SED.ED_TPCOJR "
cQry +=     " AND OHBMES.OHB_DTLANC BETWEEN '" + DtoS(aMeses[2]) + "' AND '" + DtoS(LastDay(aMeses[2])) + "' "
cQry +=     " AND OHBMES.D_E_L_E_T_ = ' ') "+cMes

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetMeses(nAno, nMesIni, nMesFinal)
Rotina para gerar o array para os campos dinâmicos dos meses.

@Param nAno       - Ano do resultado financeiro
@Param nMesIni    - Mês Inicial do balanço
@Param nMesFinal  - Mês Final do balanço

@return aMeses[nI][1] Descrição do mês.
		 aMeses[nI][2] Mês do saldo por Natureza.
		 aMeses[nI][3] Campo da SE7.

@author Luciano Pereira dos Santos
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetMeses(nAno, nMesIni, nMesFinal)
Local nI       := 0
Local nQtdMes  := (nMesFinal - nMesIni) + 1
Local dData    := CToD('  /  /  ')
Local cDescMes := ""
Local aMeses   := {}
Local cCpoSE7  := ""

For nI := 1 to nQtdMes

	dData    := StoD(cValtochar(nAno)+ StrZero(nMesIni, 2) +'01')
	cDescMes := MesExtenso( dData )
	cCpoSE7  := "E7_VAL" + LEFT(UPPER(cDescMes), 3) + "1"

	Aadd(aMeses, {cDescMes, dData, cCpoSE7} )

	nMesIni += 1

Next nI

Return aMeses

//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio(aRelat, aCabec, aSessao, cQuery, nAno, nMesIni, nMesFinal, cDataHora)
Executa a query principal e inicia a impressão do relatório.
Ferramenta FWMsPrinter
Uso Geral.

@param aRelat     Dados do título do relatório
@param aCabec     Dados do cabeçalho do relatório
@param aSessao    Dados do conteúdo do relatório
@param cQuery     Query que será executada
@param nAno       Ano para filtro do relatório
@param nMesIni    Mês inicial para filtro do relatório
@param nMesFinal  Mês final para filtro do relatório
@param cDataHora  Data e hora da Impressão

@Return nil

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat, aCabec, aSessao, cQuery, nAno, nMesIni, nMesFinal, cDataHora, cNameAuto)
Local cNomeRel  := aRelat[1] //Nome do Relatório
Local oPrint    := Nil
LOcal aCampos   := Nil
Local lHori     := .F.
Local lQuebPag  := .F.
Local lTitulo   := .T.
Local lLinTit   := .F.
Local lPagina1  := .T.
Local nI        := 0    // Contador
Local nJ        := 0    // Contador
Local nLin      := 0    // Linha Corrente
Local nLinCalc  := 0    // Contator de linhas - usada para os cálculos de novas linhas
Local nLinCalc2 := 0
Local nLinFinal := 0
Local nTipoSec  := 0
Local aDados    := {}
Local aLinha    := {}
Local aPos      := {}
Local cValor    := ""
Local cTabela   := ""
Local cCpoTab   := ""
Local cTipo     := ""
Local TMP       := GetNextAlias()
Local oTotalSub := JurTotais():New()

If !__lAuto
	oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,, .T.,,, "PDF" ) // Inicia o relatório
Else
	oPrint := FWMSPrinter():New( cNameAuto, IMP_SPOOL,,, .T.,,,,.T.) // Inicia o relatório
	// Alterar o nome do arquivo de impressão para o padrão de impressão automatica
	oPrint:CFILENAME  := cNameAuto
	oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMP,.T.,.T.)

If (TMP)->(!EOF())

	ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Imprime cabeçalho
	nLinCalc := nLin // Inicia o controle das linhas impressas

	While (TMP)->(!EOF())

		If lPagina1 // nLin >= nFimL // Verifica se a linha corrente é maior que linha final permitida por página
			lPagina1 := .F.
		Else
			oPrint:EndPage() // Se for maior, encerra a página atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o título pode ser impresso
			lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
		EndIf

		For nI := 1 To Len(aSessao) // Inicia a impressão de cada sessão do relatório

			lHori    := aSessao[nI][4]
			nTipoSec := aSessao[nI][6] // Tipo de Sessão - 1 - Normal, 2 - Totalizador de Sessão comum, 3 - Sessão de somas

			If !Empty(aSessao[nI][5]) // Nessa posição é indicada a query de um subreport
				JImpSub(aSessao[nI][5], TMP, aSessao[nI],@nLinCalc,@lQuebPag, aRelat, aCabec, @oPrint, @nLin, @lTitulo, @lLinTit, nAno, nMesIni, nMesFinal, @oTotalSub, nI, cDataHora) // Imprime os dados do subreport
			Else

				nLinCalc2 := nLinCalc // Backup da próxima linha a ser usada, pois na função JDadosCpo abaixo a variavel tem seu conteúdo alterado para
				                      // que seja realizada uma simulação das linhas usadas para impressão do conteúdo.

				nLinFinal := 0 // Limpa a variável

				If Len(aSessao[nI]) == 8

					aPos := aSessao[nI][8] // Posição das sessões para totalizadores

					If nTipoSec == 2 // Totalizador de Sessão
						aLinha := oTotalSub:GetSection(aPos[1])

					ElseIf nTipoSec == 3 // Sessão de Resultados

						oTotalSub:OperSection(aPos[1],aPos[2], aPos[3])

						aLinha := oTotalSub:GetSection(nI)

					EndIf
				EndIf

				aCampos := aSessao[nI][7]

				For nJ := 1 to Len(aCampos) // Lê as informações de cada campo a ser impresso. O contador começa em 6 pois é a partir dessa posição que estão as informações sobre o campo
					cTabela  := aCampos[nJ][2] //Tabela
					cCpoTab  := aCampos[nJ][3] //Nome do campo na tabela
					cTipo    := aCampos[nJ][5] //Tipo do campo

					If nTipoSec == 3
						If nJ == (Len(aCampos)-1) .Or. nJ == Len(aCampos)
							cValor := ""
						Else
							cValor := JTrataTotal(cTipo, aLinha[nJ])
						EndIf
					Else
						cValor := JTrataTotal(cTipo, aLinha[nJ])
					EndIf

					aAdd(aDados,JDadosCpo(aCampos[nJ],cValor,@nLinCalc,@lQuebPag)) // Título e conteúdo de cada campo são inseridos do array com os dados para serem impressos abaixo
				Next nJ

				nLinCalc := nLinCalc2 // Retorno do valor original da variável

				If lQuebPag // Verifica se é necessário ocorrer a quebra de pagina
					oPrint:EndPage() // Se é necessário, encerra a página atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lQuebPag := .F. // Limpa a variável de quebra de página
					lTitulo  := .T. // Indica que o título pode ser impresso
					lLinTit  := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
				EndIf

				If lTitulo .And. !Empty(aSessao[nI][1])
					If (nLin + 80) >= nFimL // Verifica se o título da sessão cabe na página
						oPrint:EndPage() // Se for maior, encerra a página atual
						ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
						nLinCalc := nLin // Inicia o controle das linhas impressas
						lTitulo := .T. // Indica que o título pode ser impresso
						lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
					EndIf

				EndIf

				JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI], aSessao[nI][6], nI == 1 ) //Imprime o título da sessão no relatório

				If !lHori // Caso a impressão dos títulos seja na vertical - Todos os títulos na mesma linha e os conteúdos vem em colunas abaixo dos títulos (Ex: Relatório de andamentos)
					// Os títulos devem ser impressos
					lTitulo := .T. // Indica que o título pode ser impresso
					lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
				EndIf

				//Imprime os campos do relatório
				JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec,, nAno, nMesIni, nMesFinal, cDataHora)

				//Limpa array de dados
				aSize(aDados,0)
				aDados := {}

				nLinCalc  := nLinFinal         // Indica a maior refência de uso de linhas para que sirva como referência para começar a impressão do próximo registro
				nLinFinal := 0                 // Limpa a variável
				nLin      := nLinCalc + nSalto // Recalcula a linha de referência para impressão
				nLinCalc  := nLin              // Indica a linha de referência para impressão

			EndIf

		Next nI

		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório

		nLin += nSalto //Adiciona uma linha em branco após a linha impressa
		nLinCalc := nLin

		(TMP)->(DbSkip())
	End

	(TMP)->(dbCloseArea())

	aSize(aDados,0)  //Limpa array de dados
	aSize(aRelat,0)  //Limpa array de dados do relatório
	aSize(aCabec,0)  //Limpa array de dados do cabeçalho do relatório
	aSize(aSessao,0) //Limpa array de dados das sessões do relatório

	oPrint:EndPage() // Finaliza a página

	If !__lAuto
		oPrint:CFILENAME := cNomeRel + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') + '.rel'
		oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
	EndIf
	
	oPrint:Print()

	If !__lAuto
		FErase(oPrint:CFILEPRINT)
	EndIf

Else

	ApMsgInfo(STR0033) // "Não foram encontrados valores para o filtro selecionado."

EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec(oPrint, nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora)
Imprime cabeçalho do relatório

Uso Geral.

@param oPrint     Objeto do Relatório (FWMsPrinter)
@param nLin       Linha Corrente
@param aRelat     Dados do título do relatório
@param aCabec     Dados do cabeçalho do relatório
@param TMP        Alias aberto da query principal
@param nAno       Ano para filtro do relatório
@param nMesIni    Mês inicial para filtro do relatório
@param nMesFinal  Mês final para filtro do relatório
@param cDataHora  Data e hora da Impressão

@Return nil

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpCabec(oPrint, nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora)
Local cTit       := aRelat[1] // Título
Local nColTit    := aRelat[2] // Posição da Título
Local oFontTit   := aRelat[3] // Fonte do Título
Local cTitulo    := ""
Local cValor     := ""
Local cAnoMesIni := cValtoChar(nAno) + "-" + StrZero( nMesIni  , 2 )
Local cAnoMesFim := cValtoChar(nAno) + "-" + StrZero( nMesFinal, 2 )
Local cTexto     := I18N(STR0029, {cAnoMesIni,cAnoMesFim,AllTrim((TMP)->NS7_RAZAO)} ) // "Período de #1 a #2 - Escritório #3."
Local nPosTit    := 800 // Posição do primeiro título
Local nPosValor  := 0
Local nRazao     := 0
Local nRazaoCP   := 0
Local nSaltoCabe := 40
Local nI         := 0
Local oFontRoda  := TFont():New("Arial",,-10,,.F.,,,,.T.,.F.) // Fonte usada no Rodapé
Local oFontInfo  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.) // Fonte usada nos dados do cabeçalho
Local oFontCabec := TFont():New("Arial",,-14,,.T.,,,,.T.,.F.) // Fonte usada no cabeçalho
Local aTitulos   := {}

oPrint:SetLandscape()

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()

If !__lAuto
	oPrint:Say( nFimL, 1400, cDataHora, oFontInfo )
EndIf
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )

nLin := 150

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )

nLin += 2 * nSaltoCabe // Espaço para que o cabeçalho fique um pouco abaixo do Título do Relatório

// Imprime dados complementares do cabeçalho
oPrint:Say( nLin, 65, cTexto, oFontInfo )

nLin += 40

oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório

nLin += 40

If Len(aCabec) > 0
	If !EMPTY(aCabec[1][1])

		nLin += nSaltoCabe

		// Imprime o Título
		oPrint:Say( nLin , 65, STR0030 , oFontCabec )  // "Contas"

		// Array com títulos
		aEval(aCabec, {|a,x| Aadd(aTitulos, aCabec[x][1]) })
		aAdd(aTitulos, STR0031)
		aAdd(aTitulos, STR0032)

		// Verifica qual é o maior título do relatório e usa o tamanho dele como razão
		For nI := 1 to Len(aTitulos)
			cTitulo  := aTitulos[nI]  // Título
			If oPrint:GetTextWidth(cTitulo, oFontCabec ) > nRazao
				nRazao := oPrint:GetTextWidth(cTitulo, oFontCabec )
			EndIf
		Next nI

		For nI := 1 to Len(aCabec)

			nRazaoCp := 0 // Razão do campo
			cTitulo  := aCabec[nI][1]  // Título

			While nRazao > nRazaoCp .And. (nRazao - nRazaoCp) > oPrint:GetTextWidth(" ", oFontCabec )
				nRazaoCP := oPrint:GetTextWidth( cTitulo, oFontCabec )
				cTitulo  := " " + cTitulo
			EndDo

			cValor     := aCabec[nI][2] // Conteúdo
			nPosValor  := aCabec[nI][3] // Posição do conteúdo (considere 20,5 para cada caractere do título, ou seja se o título tiver 6 caracteres indique 6x20,5 = 123. Indique esse número para todos os itens do cabeçalho, para que todos tenham o mesmo alinhamento. Para isso considere sempre a posição da maior descrição)
			oFontTit   := aCabec[nI][4] // Fonte do título

			If !__lAuto
				oPrint:Say( nLin , nPosTit , cTitulo , oFontCabec   ) //Imprime o Título
			EndIf

			nPosTit += 250

		Next
	EndIf
EndIf

oPrint:Say( nLin , nPosTit + 50, STR0031, oFontCabec ) // Imprime o Título - "Total Geral"
oPrint:Say( nLin , 2650        , STR0032, oFontCabec )    // Imprime o Título - "Orçamento"
oPrint:Say( nLin , 2950        , "%"    , oFontCabec )    // Imprime o Título - "%"

nLin += 20

oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório

nLin += 40 //Recalcula a linha de referência para impressão

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Trata os tipos de campos e imprime os valores

Uso Geral.

@param cTabela Nome da tabela
@param cCpoTab Nome do campo na tabela
@param cCpoQry Nome do campo na query
@param cTipo   Tipo do campo
@param TMP     Alias aberto da query principal
@param SUB     Alias aberto da query do sub relatório que esta sendo impresso
@param lSub    Indica se é um sub relatório

@return cValor Valor do campo na Query

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Local cValor   := ""
Local cPicture := ""

Local TAB      := IIf(lSub, SUB, TMP)

If cTipo == "D" // Tipo do campo
	TCSetField(TAB, cCpoQry , "D") //Muda o tipo do campo para data.
	cValor   := AllTrim(AllToChar((TAB)->&(cCpoQry))) //Conteúdo a ser gravado

ElseIf cTipo == "M"
	DbSelectArea(cTabela)
	(cTabela)->(dbGoTo((TAB)->&(cCpoQry))) // Esse seek é para retornar o valor de um campo MEMO
	cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo

ElseIf cTipo == "N"
	TcSetField( TAB, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
	cPicture := "@E 999,999,999.99"

	cValor   := TRANSFORM((TAB)->&(cCpoQry), cPicture)

Else
	cValor := AllTrim(AllToChar((TAB)->&(cCpoQry)))
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpSub(cQuerySub, TMP, aSessao, nLinCalc, lQuebPag, aRelat, aCabec, oPrint, nLin, lTitulo, lLinTit, nAno, nMesIni, nMesFinal, oTotalSub, nSessao)
Imprime o sub relatório

Uso Geral.

@param cQuerySub  Query do sub Relatório
@param TMP        Alias aberto da query principal
@param aSessao    Dados do conteúdo do relatório
@param nLinCalc   Variável de cálculo de linhas
@param lQuebPag   Indica se deve existir quebra de pagina
@param aRelat     Dados do título do relatório
@param aCabec     Dados do cabeçalho do relatório
@param oPrint     Objeto do Relatório (FWMsPrinter)
@param nLin       Linha Corrente
@param lTitulo    Indica se o titulo de ser impresso
@param lLinTit    Indica se a linha onde será impresso o titulo foi definida
@param nAno       Ano para filtro do relatório
@param nMesIni    Mês inicial para filtro do relatório
@param nMesFinal  Mês final para filtro do relatório
@param oTotalSub  Objeto da classe JURTOTAIS
@param nSessao    Número da sessão atual
@param cDataHora  Data e hora da Impressão

@return nil

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpSub(cQuerySub, TMP, aSessao, nLinCalc, lQuebPag, ;
                        aRelat , aCabec, oPrint, nLin, lTitulo, lLinTit, ;
                        nAno, nMesIni, nMesFinal, oTotalSub, nSessao, cDataHora)

Local xValor  // Valor do campo
Local nJ
Local cVar     := "" // Campo
Local cValor   := ""
Local aDados   := {}
Local SUB      := GetNextAlias()
Local lHori    := aSessao[4]
Local aCampos  := aSessao[7]
Local aTotal   := Array(Len(aCampos))
Local cTxt     := cQuerySub
Local lImpTit  := .T.
Local lSessao1 := nSessao == 1

aEval(aTotal, {|a,x| IIf(x <= 2, aTotal[x] := "", aTotal[x] := 0 ) })

While RAT("#@", cTxt) > 0 // Substitui os nomes dos campos passados na query por seus respectivos valores
	cVar     := SUBSTR(cTxt,AT("@#", cTxt) + 2,AT("#@", cTxt) - (AT("@#", cTxt) + 2))
	xValor   := (TMP)->(FieldGet(FieldPos(cVar)))
	cTxt     := SUBSTR(cTxt, 1,AT("@#", cTxt)-1) + ALLTRIM(xValor) + SUBSTR(cTxt, AT("#@", cTxt)+2)
End

cQuerySub := cTxt

cQuerySub := ChangeQuery(cQuerySub)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySub),SUB,.T.,.T.)

While (SUB)->(!EOF())

	If nLin >= nFimL // Verifica se a linha corrente é maior que linha final permitida por página
		oPrint:EndPage() // Se for maior, encerra a página atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
		nLinCalc := nLin // Inicia o controle das linhas impressas
		lTitulo := .T. // Indica que o título pode ser impresso
		lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
	EndIf

	nLinCalc2 := nLinCalc // Backup da próxima linha a ser usada, pois na função JDadosCpo abaixo a variavel tem seu conteúdo alterado para
	                      // que seja realizada uma simulação das linhas usadas para impressão do conteúdo.

	For nJ := 1 to Len(aCampos) // Lê as informações de cada campo a ser impresso. O contador começa em 6 pois é a partir dessa posição que estão as informações sobre o campo

		nLinFinal := 0 // Limpa a variável

		cTabela  := aCampos[nJ][2] //Tabela
		cCpoTab  := aCampos[nJ][3] //Nome do campo na tabela
		cCpoQry  := aCampos[nJ][4] //Nome do campo na query
		cTipo    := aCampos[nJ][5] //Tipo do campo
		cValor   := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,,SUB,.T.) // Retorna o conteúdo/valor a ser impresso. Chama essa função para tratar o valor caso seja um memo ou data

		If cTipo == "N"
			xValor := (SUB)->(FieldGet(FieldPos(cCpoQry)))

			aTotal[nJ] += xValor
		EndIf

		aAdd(aDados,JDadosCpo(aCampos[nJ],cValor,@nLinCalc,@lQuebPag)) // Título e conteúdo de cada campo são inseridos do array com os dados para serem impressos abaixo
	Next

	nLinCalc := nLinCalc2 // Retorno do valor original da variável

	If lQuebPag // Verifica se é necessário ocorrer a quebra de pagina
		oPrint:EndPage() // Se é necessário, encerra a página atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
		nLinCalc := nLin // Inicia o controle das linhas impressas
		lQuebPag := .F. // Limpa a variável de quebra de página
		lTitulo  := .T. // Indica que o título pode ser impresso
		lLinTit  := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
	EndIf

	If lTitulo .And. !Empty(aSessao[1])
		If (nLin + 80) >= nFimL // Verifica se o título da sessão cabe na página
			oPrint:EndPage() // Se for maior, encerra a página atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o título pode ser impresso
			lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
		EndIf
	EndIf

	If lImpTit
		JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao, aSessao[6], lSessao1) //Imprime o título da sessão no relatório
		lImpTit := .F.
	EndIf

	If !lHori // Caso a impressão dos títulos seja na vertical - Todos os títulos na mesma linha e os conteúdos vem em colunas abaixo dos títulos (Ex: Relatório de andamentos)
		// Os títulos devem ser impressos
		lTitulo := .T. // Indica que o título pode ser impresso
		lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
	EndIf

	//Imprime os campos do relatório
	JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat, aCabec,, nAno, nMesIni, nMesFinal, cDataHora)

	//Limpa array de dados
	aSize(aDados,0)
	aDados := {}

	nLinCalc := nLinFinal //Indica a maior refência de uso de linhas para que sirva como referência para começar a impressão do próximo registro

	nLinFinal := 0 // Limpa a variável

	nLin := nLinCalc

	(SUB)->(DbSkip())

EndDo

// Calcula percentual de proporção entre Total Geral e Orçamento
aTotal[Len(aTotal)] := (aTotal[Len(aTotal)-2] / aTotal[Len(aTotal)-1]) * 100.00

// Atribuí os valores totais na sessão de totalização
oTotalSub:SetSections(aTotal, nSessao)

aSize(aDados,0)

(SUB)->(dbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDadosCpo(aSessao, cValor, nLinCalc, lQuebPag)
Função para montar array com as descrições e conteúdos dos campos que serão impressos,
assim como suas coordenadas, fontes e quebra de linha após a impressão de cada campo.

Uso Geral.

@param aSessao  Dados do conteúdo do relatório
@param cValor   Conteúdo do campo que será impresso
@param nLinCalc Variável de cálculo de linhas
@param lQuebPag Indica se deve existir quebra de pagina

@return aDados Array com a Sessão formatada

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDadosCpo(aSessao, cValor, nLinCalc, lQuebPag)
Local aDados    := {}
Local cTitulo   := ""
Local cTipo     := ""
Local nPosTit   := 0
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local lQuebLin  := .F.
Local oFontVal
Local oFontTit

cTitulo  := aSessao[1] //Título da Coluna
cTipo    := aSessao[5] //Tipo do Campo
nPosTit  := aSessao[6] //Indica a coordenada horizontal em pixels ou caracteres
oFontTit := aSessao[8] //Fonte do título
nPos     := aSessao[6] //Indica a coordenada horizontal para imprimir o valor do campo
nQtdCar  := aSessao[7] //Quantidade de caracteres para que seja feita a quebra de linha
oFontVal := aSessao[9] //Fonte usada para impressão do conteúdo
nPosValor:= aSessao[10] //Fonte usada para impressão do conteúdo
lQuebLin := aSessao[11] //Indica se deve existir a quebra de linha

If !lQuebPag // Verifica se será necessária quebra de página para essa sessão
	lQuebPag := ((Int((Len(cValor)/nQtdCar) + 1) * nSalto) + nLinCalc) > nFimL
	If lQuebLin
		nLinCalc += (Int((Len(cValor)/nQtdCar) + 1) * nSalto) // Indica a linha que será usada para cada valor quando forem impressos - Usado apenas para uma simulação.
	EndIf
EndIf

aDados := {cTitulo, nPosTit, oFontTit, cValor, nQtdCar, oFontVal, nPos, nPosValor, lQuebLin, cTipo}

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta, nAno, nMesIni, nMesFinal, cDataHora)
Função que trata as quebras de pagina e imprime as Sessões na vertical e horizontal

Uso Geral.

@param aDados    Array com a Sessão formatada
@param nLin      Linha Corrente
@param nLinCalc  Variável de cálculo de linhas
@param oPrint    Objeto do Relatório (FWMsPrinter)
@param nLinFinal Ultima linha que tem conteúdo impresso
@param lHori     Indica se impressão será na horizontal ou vertical
@param lTitulo   Indica se o titulo deve ser impresso
@param lLinTit   Indica se a linha onde será impresso o titulo foi definida
@param aRelat    Dados do título do relatório
@param aCabec    Dados do cabeçalho do relatório
@param lSalta    Indica se precisa continuar a impressão do conteúdo atual na próxima página
@param nAno      Ano para filtro do relatório
@param nMesIni   Mês inicial para filtro do relatório
@param nMesFinal Mês final para filtro do relatório
@param cDataHora Data e hora da Impressão

@return nil

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta, nAno, nMesIni, nMesFinal, cDataHora)
Local nJ
Local oFontTit
Local oFontVal
Local lQuebLin  := .F.
Local lImpTit   := .T.
Local cTitulo   := ""
Local cValor    := ""
Local cTipo     := ""
Local nPosTit   := 0
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local nLinTit   := 0
Local nLinAtu   := 0
Local aSobra    := aClone(aDados)

aEval(aSobra,{|x| x[4] := ""}) // Limpa a posição de conteúdo/valor dos campos no array de sobra, pois ele é preenchido com os dados do array aDados. Limpa para que seja preenchido com o conteúdo da sobra.

Default lSalta  := .F.
Default lHori   := .T.

If lSalta // Se for continuação de impressão do conteúdo que não coube na página anterior
	lImpTit := .F. // Indica que os títulos não precisam ser impressos
	lSalta  := .F. // Limpa variável
EndIf

For nJ := 1 to Len(aDados)

	cTitulo  := aDados[nJ][1] //Título da Coluna
	nPosTit  := aDados[nJ][2] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aDados[nJ][3] //Fonte do título
	cValor   := aDados[nJ][4] //Valor a ser impresso
	nQtdCar  := aDados[nJ][5] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aDados[nJ][6] //Fonte usada para impressão do conteúdo
	nPos     := aDados[nJ][7] //Indica a coordenada horizontal para imprimir o valor do campo
	nPosValor:= aDados[nJ][8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
	lQuebLin := aDados[nJ][9] // Indica se deve existir quebra de linha após a impressão do campo
	cTipo    := aDados[nJ][10] // Indica o tipo do campo

	If lHori // Impressão na horizontal -> título e descrição na mesma linha (Ex: Data: 01/01/2016)
		nLinTit  := nLin
		nLinCalc := nLin
		oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os títulos das colunas
	Else // Impressão na vertical -> Todos os títulos na mesma linha e os conteúdos vem em colunas abaixo dos títulos (Ex: Data
	     //                                                                                                                01/01/2016 )

		If lImpTit // Essa variável indica se deve imprimir o título dos campos - Será .F. somente quando ocorrer quebra de um conteúdo em mais de uma página (lSalta == .T.).
			If !lLinTit // Como a linha onde será impresso o título dos campos ainda não foi definida entrará nessa condição

				If (nLin + 2*nSalto) >= nFimL // Verifica se a linha corrente é maior que linha final permitida por página
					oPrint:EndPage() // Se for maior, encerra a página atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, nAno, nMesIni, nMesFinal, cDataHora) // Cria um novo cabeçalho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lTitulo := .T. // Indica que o título pode ser impresso
					lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
					nLinFinal := 0
				EndIf

				nLinTit  := nLin
				nLin     += nSalto
				nLinCalc := nLin
				lLinTit := .T. // Indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
			EndIf

			If lTitulo // Indica que o título pode ser impresso
				oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os títulos das colunas
				lTitulo := Len(aDados) <> nJ // Enquanto estiver preenchendo os títulos indica .T., para que os outros títulos sejam impressos.
				                             // Após o preenchimento do último título indica .F., não permitindo mais a impressão dos títulos nessa página.

				// Deve imprimir apenas uma vez por página para que a letra não fique mais grossa.
				// Se não tiver esse tratamento a impressão será feita várias vezes sobre a mesma palavra devido as condições do laço,
				// fazendo com que a grossura das letras nas palavras aumente e isso atrapalha.

			EndIf
		EndIf
		nPosValor := nPosTit // Indica que a posição (coluna) do conteúdo/valor a ser impresso é a mesma que foi impresso o titulo, ou seja, o conteúdo/valor ficará logo abaixo do título
	EndIf

	nLinAtu := nLinCalc // Controle de linhas usadas para imprimir o conteúdo atual

	//Imprime as linhas com os conteúdos/valores
	JImpLin(@oPrint,@nLinAtu,nPosValor,cValor,oFontVal,nQtdCar,@aSobra[nJ], @lSalta, lImpTit, cTipo)

	// Verifica qual campo precisou de mais linhas para ser impresso
	// para usar esse valor como referência para começar a impressão do próximo registro
	If nLinAtu > nLinFinal
		nLinFinal := nLinAtu
	EndIf

	If lQuebLin // Indica que é necessária quebra de linha, ou seja, o próximo campo será impresso na próxima linha
		If nLinFinal >= nLin // Se a próxima linha a ser impressa (nLin) for menor que a última linha que tem conteúdo impresso (nLinFinal)
			nLin     := nLinFinal // Deve-se indicar a maior referência
		Else
			nLin     += nSalto // Caso contrário, pule uma linha.
		EndIf
		nLinTit  := nLin // Recebe a próxima linha disponível para impressão do título
		nLinCalc := nLin // Atualiza variável de cálculo de linhas
		lLinTit  := .F.  // Indica que a linha de impressão do título precisa ser definida, pois iniciará uma nova linha.
	EndIf
Next nJ

If lSalta // Se precisa continuar a impressão do conteúdo atual na próxima página
	oPrint:EndPage() // Finaliza a página atual
	ImpCabec(@oPrint, @nLin, aRelat, aCabec, TMP, , , , cDataHora) // Cria um novo cabeçalho na próxima página
	nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
	nLinAtu   := nLinCalc // Atualiza variável linha atual
	lQuebPag  := .F. // Indica que não é necessário ocorrer a quebra de pagina, pois já está sendo quebrada nesse momento.
	lTitulo   := .T. // Indica que o título pode ser impresso
	lLinTit   := .F. // Indica que a linha de impressão do título precisa ser definida, pois iniciará uma nova linha.
	nLinFinal := 0 // Limpa variável de controle da última linha impressa.

	// Imprime o restante do conteúdo que não coube na página anterior.
	JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta, nAno, nMesIni, nMesFinal, cDataHora)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit, cTipo)
Função para impressão das linhas no relatório

Uso Geral.

@param oPrint    Objeto do Relatório (FWMsPrinter)
@param nLinAtu   Linha onde será impresso a próxima informação
@param nPosValor Posição do conteúdo
@param cTexto    Conteúdo completo de cada coluna
@param oFontVal  Fonte usada para impressão do conteúdo
@param nQtdCar   Quantidade de caracteres para que seja feita a quebra de linha
@param aSobra    Array com o valor que não coube em alguma das colunas da página anterior, e falta ser impresso
@param lSalta    Indica se precisa continuar a impressão do conteúdo atual na próxima página
@param lImpTit   Indica se o título precisa ser impresso
@param cTipo     Tipo do campo a ser impresso

@return nil

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit, cTipo)
Local nRazao    := oPrint:GetTextWidth( "oPrint:nPageWidth", oFontVal )
Local nTam      := (nRazao * nQtdCar) / 350
Local aCampForm := {} // Array com cada palavra a ser escrita.
Local cValor    := ""
Local cValImp   := "" // Valor impresso
Local nX        := 0

cTexto    := StrTran(cTexto, Chr(13)+Chr(10), '')
cTexto    := StrTran(cTexto, Chr(10), '')

If cTipo == "N"
	aCampForm := {cTexto}
	oFontVal  := TFont():New("Arvo",,-12,,.T.,,,,.T.,.F.)   // Fonte usada para valores númericos
Else
	aCampForm := STRTOKARR(cTexto, " ")
	//oFontVal  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
EndIf

If Len(aCampForm) == 0 // Caso não exista conteúdo/valor
	If lImpTit // E o título do campo foi impresso
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Será inserida a linha com conteúdo em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conteúdo/valor
	For nX := 1 To Len(aCampForm) // Laço para cada palavra a ser escrita
		If oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal ) <= nTam // Se a palavra atual for impressa e NÃO passar do limite de tamanho da linha
			cValor += aCampForm[nX] + " " // Preenche a linha com a palavra atual

			If Len(aCampForm) == nX // Caso esteja na última palavra
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conteúdo que estava em cValor
				nLinAtu += nSalto // Pula para a próxima linha
			EndIf

		Else // Se a palavra atual for impressa e passar do limite de tamanho da linha
			oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conteúdo que estava em cValor sem a palavra que ocasionou a quebra.
			nLinAtu += nSalto // Pula para a próxima linha

			If nLinAtu + 2*nSalto > nFimL // Se a próxima linha a ser impressa NÃO couber na página atual
				lSalta := .T. // Indica que precisa continuar a impressão do conteúdo atual na próxima página
				If Empty(SubStr(cTexto,Len(cValImp+cValor)+2,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+3,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor)+1,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+2,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor),1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor),Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				EndIf
				Exit
			Else // Se a próxima linha a ser impressa couber na página atual
				cValImp += cValor // Guarda todo o texto que já foi impresso para que caso necessite de quebra o sistema saiba até qual parte o texto já foi impresso.
				cValor := aCampForm[nX] + " " // Preenche a linha com a palavra atual
				If Len(aCampForm) == nX
					oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conteúdo que estava em cValor sem a palavra que ocasionou a quebra.
					nLinAtu += nSalto // Pula para a próxima linha
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

//Limpa array
aSize(aCampForm,0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpTitSes()
Imprime o título da sessão no relatório

Uso Geral.

@param oPrint    Objeto do Relatório (FWMsPrinter)
@param nLin      Linha corrente
@param nLinCalc  Variável de cálculo de linhas
@param aSessao   Dados do conteúdo do relatório
@param nTipoSec  Tipo de Sessão - 1 - Normal, 2 - Totalizador de Sessão, 3 - Sessão de Resultados
@param lSessao1  Indica se é a primeira sessão do relatório

@return Nil

@author Jorge Martins
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpTitSes(oPrint, nLin, nLinCalc, aSessao, nTipoSec, lSessao1)
Local oBrush1
Local xColor := RGB(192,192,192)

If nTipoSec == 1 .And. !lSessao1

	nLin += nSalto //Adiciona uma linha em branco após a linha impressa
	nLinCalc := nLin

ElseIf nTipoSec == 2

	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório

	nLin += nSalto //Adiciona uma linha em branco após a linha impressa
	nLinCalc := nLin

	xColor := RGB(220,220,220)
ElseIf nTipoSec == 3

	nLin += nSalto //Adiciona uma linha em branco após a linha impressa
	nLinCalc := nLin

	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório

	nLin += nSalto //Adiciona uma linha em branco após a linha impressa
	nLinCalc := nLin

	xColor := RGB(220,220,220) // CLR_LIGHTGRAY
EndIf

oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)

oBrush1 := TBrush():New( , xColor )
oPrint:FillRect( {nLin-20, nColIni, (nLin + 30), nColFim}, oBrush1 )
oBrush1:End()

//aSessao[1] - Título da sessão do relatório
//aSessao[2] - Posição da descrição
//aSessao[3] - Fonte da sessão
oPrint:Say( nLin+15, aSessao[2], aSessao[1], aSessao[3])

If nTipoSec == 1
	nLin += 80

ElseIf nTipoSec == 2
	nLin += 15

ElseIf nTipoSec == 3

	oPrint:Line( nLin+nSalto + 15, nColIni, nLin+nSalto + 15, nColFim ) // Imprime uma linha na horizontal no relatório
	oPrint:Line( nLin+nSalto + 15, nColIni, nLin+nSalto + 15, nColFim ) // Imprime uma linha na horizontal no relatório

	nLin += 15

EndIf

nLinCalc := nLin

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataTotal(cTipo, xValor)
Trata valores de campos de totalizadores

Uso Geral.

@param cTipo   Tipo do campo
@param xValor  Conteúdo do campo

@return cValor Valor tratado

@author Jorge Martins
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTrataTotal(cTipo, xValor)
Local cValor   := ""
Local cPicture := "@E 999,999,999.99"

If cTipo == "N"
	cValor := TRANSFORM(xValor, cPicture)
Else
	cValor := ""
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryTotal()
Query principal com os totalizadores dos meses

@Param cTpContTmp - Tabela temporária com os dados dos tipos de conta
@param aMeses     - Array com as informações dinamicas dos meses
                   aMeses[nI][1] Descrição do mês.
                   aMeses[nI][2] Mês do saldo por Natureza.
                   aMeses[nI][3] Campo da SE7.
@Param cOriDest   - O tipo da natureza no lançamento O = Origem, D = Destino
@Param cTpConta   - Tipo de conta de Natureza

@return cQry   - Query principal do relatório (Filtro por escritório)

@author Bruno Ritter
@since 29/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQryTotal(cTpContTmp, aMeses, cOriDest, cTpConta)
Local cQuery     := ""
Local cCpoOriDes := Iif(cOriDest == "O", "OHB_NATORI", "OHB_NATDES")
Local nI         := 0
Local cMesIni    := ""
Local cMesFin    := ""
Local cSaldoMes  := ""

For nI := 1 to Len(aMeses)
	IIf(nI == 1          , cMesIni := DtoS(aMeses[nI][2]), Nil)
	IIf(nI == Len(aMeses), cMesFin := DtoS(LastDay(aMeses[nI][2])), Nil)

	cSaldoMes += JSaldoMes(aMeses[nI], cOriDest, cTpContTmp) +", "
Next nI

cRealizado := " Sum( OHB.OHB_VLNAC ) * (SELECT SINAL FROM " + cTpContTmp + " WHERE TIPO = '" + cOriDest + "' AND CODIGO = SED.ED_TPCOJR) "

cQuery += " SELECT "
cQuery +=     " SED.ED_TPCOJR, "
cQuery +=     " SED.ED_FILIAL, "
cQuery +=     " SED.ED_CODIGO, "
cQuery +=     " SED.ED_DESCRIC, "
cQuery +=     " SED.ED_CMOEJUR, "
cQuery +=     cSaldoMes
cQuery +=     cRealizado + " REALIZADO"

cQuery += " FROM " + RetSqlName("OHB") + " OHB "
cQuery += " INNER JOIN " + RetSqlName("SED") + " SED "
cQuery +=       "  ON SED.ED_FILIAL = '"+xFilial("SED") + "' "
cQuery +=       " AND SED.ED_CODIGO = OHB."+cCpoOriDes
cQuery +=       " AND SED.D_E_L_E_T_ = ' ' "
cQuery += " WHERE OHB.OHB_FILIAL = '@#NS7_CFILIA#@' "
cQuery +=       " AND OHB.OHB_DTLANC BETWEEN '"+ cMesIni +"' AND '"+ cMesFin +"' "
cQuery +=       " AND SED.ED_TPCOJR = '"+ cTpConta +"' "
cQuery +=       " AND SED.ED_CCJURI IN (' ','1','2','3','4','5') "
cQuery +=       " AND OHB.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SED.ED_FILIAL, "
cQuery +=       " SED.ED_CODIGO, "
cQuery +=       " SED.ED_DESCRIC, "
cQuery +=       " SED.ED_CMOEJUR, "
cQuery +=       " SED.ED_TPCOJR "

Return cQuery
