#INCLUDE "CNTR050.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CNTR050  ³ Autor ³ Microsiga S/A         ³ Data ³23/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Listagem de Medicao X Notas Fiscais                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CNTR050()
Local oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= ReportDef()
oReport:PrintDialog()


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Microsiga S/A         ³ Data ³23.04.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oMedicao
Local oMedicao2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                     ³
//³ mv_par01         // Numero inicial da medicao ?          ³
//³ mv_par02         // Numero Final da medicao ?            ³
//³ mv_par03         // Numero inicial do contrato ?         ³
//³ mv_par04         // Numero final do contrato ?           ³
//³ mv_par05         // Codigo inicial do fornecedor ?       ³
//³ mv_par06         // Codigo final do fornecedor ?         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("CNT050",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("CNTR050",STR0001,"CNT050", {|oReport| ReportPrint(oReport)},STR0002) //"Este relatorio emite uma relacao de medicoes por notas fiscais geradas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 1 - Medicao x Notas Fiscais - Compra                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMedicao := TRSection():New(oReport,STR0003,{"CND","CNE","SD1"})
oMedicao:SetTotalInLine(.F.)
oMedicao:SetNoFilter("SD1")
oMedicao:SetNoFilter("CNE")
oMedicao:SetReadOnly()

// Numero do Contrato
TRCell():New(oMedicao,'CND_CONTRA'	,'CND',STR0004+CRLF+STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Numero da Medicao
TRCell():New(oMedicao,'CND_NUMMED'	,'CND',STR0006+CRLF+STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Valor da Medicao
TRCell():New(oMedicao,'CNE_VLTOT'	,'CNE',STR0008+CRLF+STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
// Numero da Nota Fiscal
TRCell():New(oMedicao,'D1_DOC'		,'SD1',STR0009+CRLF+STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Serie da Nota Fiscal
TRCell():New(oMedicao,'D1_SERIE'	,'SD1',STR0011+CRLF+STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Valor Total da Nota Fiscal
TRCell():New(oMedicao,'D1_TOTAL'	,'SD1',STR0008+CRLF+STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
// Valor Total Pago (Titulo)
TRCell():New(oMedicao,'E2_SALDO'	,'SE2',STR0008+CRLF+STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
// Valor da Retencao (Titulo)
TRCell():New(oMedicao,'E2_RETCNTR'	,'SE2',STR0008+CRLF+STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

oMedicao:SetTotalText(STR0016)  //"Total Geral :"
TRFunction():New(oMedicao:Cell("CNE_VLTOT")	,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oMedicao:Cell("D1_TOTAL")		,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oMedicao:Cell("E2_SALDO")		,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oMedicao:Cell("E2_RETCNTR")	,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 2 - Medicao x Notas Fiscais - Venda                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMedicao2 := TRSection():New(oReport,STR0018,{"CND","CNE","SD2"})
oMedicao2:SetTotalInLine(.F.)
oMedicao2:SetNoFilter("SD2")
oMedicao2:SetNoFilter("CNE")
oMedicao2:SetReadOnly()

// Numero do Contrato
TRCell():New(oMedicao2,'CND_CONTRA'	,'CND',STR0004+CRLF+STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Numero da Medicao
TRCell():New(oMedicao2,'CND_NUMMED'	,'CND',STR0006+CRLF+STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Valor da Medicao
TRCell():New(oMedicao2,'CNE_VLTOT'	,'CNE',STR0008+CRLF+STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
// Numero da Nota Fiscal
TRCell():New(oMedicao2,'D2_DOC'		,'SD1',STR0009+CRLF+STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Serie da Nota Fiscal
TRCell():New(oMedicao2,'D2_SERIE'		,'SD1',STR0011+CRLF+STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER")
// Valor Total da Nota Fiscal
TRCell():New(oMedicao2,'D2_TOTAL'		,'SD1',STR0008+CRLF+STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
// Valor Total Pago (Titulo)
TRCell():New(oMedicao2,'E1_SALDO'		,'SE2',STR0008+CRLF+STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
// Valor da Retencao (Titulo)
TRCell():New(oMedicao2,'E1_RETCNTR'	,'SE2',STR0008+CRLF+STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")


oMedicao2:SetTotalText(STR0016)  //"Total Geral :"
TRFunction():New(oMedicao2:Cell("CNE_VLTOT")	,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oMedicao2:Cell("D2_TOTAL")		,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oMedicao2:Cell("E1_SALDO")		,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oMedicao2:Cell("E1_RETCNTR")	,NIL,"SUM",/*oBreak1*/,,/*cPicture*/,/*uFormula*/,.T.,.F.)


Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Microsiga S/A         ³ Data ³23.04.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oMedicao := oReport:Section(1)
Local oMedicao2:= oReport:Section(2)
Local cAliasRel:= GetNextAlias()
Local cAliasSD1:= GetNextAlias()
Local cAliasSE2:= GetNextAlias()
Local cAliasSD2:= GetNextAlias()
Local cAliasSE1:= GetNextAlias()
Local cNumDoc  := ''
Local cSerie   := ''
Local lFstCpr  := .T.
Local lFstVnd  := .T.
Local oBreak01
Local oBreak02
Local cFornece := ''
Local cLoja    := ''
Local nMoedaD  := 1
Local dDataRef := If(Empty(mv_par09),dDataBase,mv_par09)
Local nPorcent := 0
Local cExpFil := "%"

cExpFil += "CND_FILCTR = CN9_FILCTR AND%"

// Quebra por Contrato
If mv_par05 == 1

	// Sub-Totais por Contrato
	oBreak01 := TRBreak():New(oMedicao,oMedicao:Cell("CND_CONTRA"),STR0017,.F.) //"Sub-Total por Contrato :"
	TRFunction():New(oMedicao:Cell("CNE_VLTOT")	,NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oMedicao:Cell("D1_TOTAL")	,NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oMedicao:Cell("E2_SALDO")	,NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oMedicao:Cell("E2_RETCNTR"),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)

	// Sub-Totais por Contrato
	oBreak02 := TRBreak():New(oMedicao2,oMedicao2:Cell("CND_CONTRA"),STR0017,.F.) //"Sub-Total por Contrato :"
	TRFunction():New(oMedicao2:Cell("CNE_VLTOT")	,NIL,"SUM",oBreak02,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oMedicao2:Cell("D2_TOTAL")	,NIL,"SUM",oBreak02,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oMedicao2:Cell("E1_SALDO")	,NIL,"SUM",oBreak02,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oMedicao2:Cell("E1_RETCNTR"),NIL,"SUM",oBreak02,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo := If(MV_PAR06==1,"1','2',' ",If(MV_PAR06==2,"1',' ","2"))

oMedicao:BeginQuery()
	BeginSql Alias cAliasRel
		SELECT 	DISTINCT
				CND_FILIAL,
				CND_CONTRA,
				CND_NUMMED,
				SUM(CNE_VLTOT) CNE_VLTOT,
				CNE_PEDIDO,
				CNE_ITEM,
				CN1_ESPCTR,
				CND_MOEDA,
				CN9_MOEDA
		FROM
				%table:CND% CND,
				%table:CNE% CNE,
				%table:CN9% CN9,
				%table:CN1% CN1

		WHERE %Exp:cExpFil%
				CNE_FILIAL = CND_FILIAL 		AND
				CNE_REVISA = CND_REVISA		 	AND
				CNE_NUMMED >= %Exp:mv_par03% 	AND
				CNE_NUMMED <= %Exp:mv_par04% 	AND

				CND_CONTRA = CNE_CONTRA 		AND
				CND_NUMMED = CNE_NUMMED 		AND
				CND_CONTRA = CN9_NUMERO 		AND
				CND_REVISA = CN9_REVISA 		AND

				CN9_FILIAL = %xFilial:CN9% 		AND
				CN9_NUMERO >= %Exp:mv_par01% 	AND
				CN9_NUMERO <= %Exp:mv_par02% 	AND

				CN1_FILIAL = %xFilial:CN1% 		AND
				CN1_ESPCTR in (%Exp:cTipo%) 	AND
				CN1_CODIGO = CN9_TPCTO 			AND

				CND.%NotDel%  					AND
				CNE.%NotDel% 					AND
				CN9.%NotDel% 					AND
				CN1.%NotDel%					
	
		GROUP BY
				CND_FILIAL,
				CND_CONTRA,
				CND_REVISA,
				CND_NUMMED,
				CND_MOEDA,
				CN9_MOEDA,
				CNE_PEDIDO,
				CNE_ITEM,
				CN1_ESPCTR
		ORDER BY CN1_ESPCTR,CND_CONTRA,CND_NUMMED
	EndSql
oMedicao:EndQuery()

If mv_par07 == 4
	nMoedaD := mv_par08 + 1
	oReport:SetTitle(oReport:Title() +STR0019 +AllTrim(GetMv("MV_SIMB" +Ltrim(Str(nMoedaD)))) +")")
EndIf

dbSelectArea(cAliasRel)
dbGoTop()

Do While !oReport:Cancel() .And. !(cAliasRel)->(Eof())

	If mv_par07 == 1
		nMoedaD := (cAliasRel)->CND_MOEDA
	ElseIf mv_par07 == 2
		nMoedaD := (cAliasRel)->CN9_MOEDA
	EndIf

	oReport:IncMeter()

	If (cAliasRel)->CN1_ESPCTR == '1' .OR. Empty((cAliasRel)->CN1_ESPCTR)
	
		If lFstCpr
			oMedicao:Init()
			lFstCpr := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query utilizada para compor o valor total da nota de entrada - SD1      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BeginSql Alias cAliasSD1
			SELECT C7_NUM, D1_DOC, D1_SERIE, SUM(D1_TOTAL) D1_TOTAL, D1_FORNECE, D1_LOJA
			FROM %table:SC7% SC7, %table:SD1% SD1 
			WHERE C7_FILIAL = %Exp:xFilial("SC7",(cAliasRel)->CND_FILIAL)% AND
					C7_CONTRA = %Exp:(cAliasRel)->CND_CONTRA% AND
					C7_MEDICAO = %Exp:(cAliasRel)->CND_NUMMED% AND 
					C7_ITEMED = %Exp:(cAliasRel)->CNE_ITEM% AND
					D1_PEDIDO = C7_NUM AND 
					SC7.%NotDel% AND 
					SD1.%NotDel%					
			GROUP BY C7_NUM, D1_DOC,D1_SERIE, D1_FORNECE, D1_LOJA
		EndSql

		dbSelectArea(cAliasSD1)
		dbGoTop()
		Do While !Eof()

			cNumDoc := (cAliasSD1)->D1_DOC
			cSerie  := (cAliasSD1)->D1_SERIE
			cFornece:= (cAliasSD1)->D1_FORNECE
			cLoja   := (cAliasSD1)->D1_LOJA
			nPorcent:= 1

			dbSelectArea("SF1")
			dbSetOrder(1)
			If msSeek(xFilial("SF1")+cNumDoc+cSerie+cFornece+cLoja)
				nPorcent := (cAliasSD1)->D1_TOTAL/SF1->F1_VALMERC
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query utilizada para compor o valor total do titulo - SE2               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BeginSql Alias cAliasSE2
				SELECT SUM(E2_VALOR) E2_VALOR,SUM(E2_SALDO) E2_SALDO,SUM(E2_RETCNTR) E2_RETCNTR, E2_MOEDA
				FROM %table:SE2% SE2
				WHERE E2_FILIAL = %Exp:xFilial("SE2",(cAliasRel)->CND_FILIAL)%    AND
						E2_NUM = %Exp:cNumDoc%     AND
						E2_PREFIXO = %Exp:cSerie%  AND
						E2_FORNECE = %Exp:cFornece% AND
						E2_LOJA    = %Exp:cLoja%   AND
						SE2.%NotDel%
				GROUP BY E2_PREFIXO,E2_NUM,E2_MOEDA
			EndSql

			dbSelectArea(cAliasSE2)
			dbGoTop()
			Do While !Eof()
				oMedicao:Cell('CND_CONTRA'):SetValue((cAliasRel)->CND_CONTRA)
				oMedicao:Cell('CND_NUMMED'):SetValue((cAliasRel)->CND_NUMMED)
				oMedicao:Cell('CNE_VLTOT' ):SetValue(Round(xMoeda((cAliasRel)->CNE_VLTOT,(cAliasRel)->CND_MOEDA,nMoedaD,dDataRef,6),TamSX3('CNE_VLTOT')[2]))
				oMedicao:Cell('D1_DOC'    ):SetValue((cAliasSD1)->D1_DOC)
				oMedicao:Cell('D1_SERIE'  ):SetValue(cSerie)
				oMedicao:Cell('D1_TOTAL'  ):SetValue(Round(xMoeda((cAliasSD1)->D1_TOTAL,1,nMoedaD,dDataRef,6),TamSX3('D1_TOTAL')[2]))
				oMedicao:Cell('E2_SALDO'  ):SetValue(Round(xMoeda((cAliasSE2)->E2_VALOR - (cAliasSE2)->E2_SALDO,(cAliasSE2)->E2_MOEDA,nMoedaD,dDataRef,6),TamSX3('E2_SALDO')[2]))
				oMedicao:Cell('E2_SALDO'  ):SetValue(Round(xMoeda(((cAliasSE2)->E2_VALOR - (cAliasSE2)->E2_SALDO) * nPorcent,(cAliasSE2)->E2_MOEDA,nMoedaD,dDataRef,6),TamSX3('E2_SALDO')[2]))
				oMedicao:Cell('E2_RETCNTR'):SetValue(Round(xMoeda((cAliasSE2)->E2_RETCNTR,(cAliasSE2)->E2_MOEDA,nMoedaD,dDataRef,6),TamSX3('E2_RETCNTR')[2]))
			 	oMedicao:PrintLine()
				dbSelectArea(cAliasSE2)
				dbSkip()
			EndDo

			// Fecha o alias da query
			(cAliasSE2)->(dbCloseArea())

			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo

		// Fecha o alias da query
		(cAliasSD1)->(dbCloseArea())
	Else
	
		If lFstVnd
			If !lFstCpr
				oMedicao:Finish()
				lFstCpr:=.T.
			EndIf

			oMedicao2:Init()
			lFstVnd := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query utilizada para compor o valor total da nota de saida - SD2        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BeginSql Alias cAliasSD2
			SELECT C5_NUM, D2_DOC, D2_SERIE, SUM(D2_TOTAL) D2_TOTAL
			FROM %table:SD2% SD2, %table:SC5% SC5, %table:SC6% SC6  
			WHERE C5_FILIAL = %Exp:xFilial("SC5",(cAliasRel)->CND_FILIAL)% AND 
				  C5_MDNUMED = %Exp:(cAliasRel)->CND_NUMMED% AND 
				  C6_FILIAL = %Exp:xFilial("SC6",(cAliasRel)->CND_FILIAL)% AND 
				  C6_NUM = C5_NUM AND 
				  C6_ITEMED = %Exp:(cAliasRel)->CNE_ITEM% AND 
				  D2_PEDIDO = C5_NUM AND 		
			SC5.%NotDel% AND
			SC6.%NotDel% AND
			SD2.%NotDel%
			GROUP BY C5_NUM, D2_DOC,D2_SERIE
		EndSql
		
		dbSelectArea(cAliasSD2)
		dbGoTop()
		Do While !Eof()

			cNumDoc := (cAliasSD2)->D2_DOC
			cSerie  := (cAliasSD2)->D2_SERIE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Query utilizada para compor o valor total do titulo - SE1               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BeginSql Alias cAliasSE1
				SELECT SUM(E1_VALOR) E1_VALOR,SUM(E1_SALDO) E1_SALDO,SUM(E1_RETCNTR) E1_RETCNTR, E1_MOEDA
				FROM %table:SE1% SE1
				WHERE E1_FILIAL = %Exp:xFilial("SE1",(cAliasRel)->CND_FILIAL)% AND
						E1_NUM = %Exp:cNumDoc%    AND
						E1_SERIE = %Exp:cSerie% AND
						SE1.%NotDel%
				GROUP BY E1_PREFIXO,E1_NUM,E1_MOEDA
			EndSql


			dbSelectArea(cAliasSE1)
			dbGoTop()
			Do While !Eof()
				oMedicao2:Cell('CND_CONTRA'):SetValue((cAliasRel)->CND_CONTRA)
				oMedicao2:Cell('CND_NUMMED'):SetValue((cAliasRel)->CND_NUMMED)
				oMedicao2:Cell('CNE_VLTOT' ):SetValue(Round(xMoeda((cAliasRel)->CNE_VLTOT,(cAliasRel)->CND_MOEDA,nMoedaD,dDataRef,6),TamSX3('CNE_VLTOT')[2]))
				oMedicao2:Cell('D2_DOC'    ):SetValue((cAliasSD2)->D2_DOC)
				oMedicao2:Cell('D2_SERIE'  ):SetValue(cSerie)
				oMedicao2:Cell('D2_TOTAL'  ):SetValue(Round(xMoeda((cAliasSD2)->D2_TOTAL,1,nMoedaD,dDataRef,6),TamSX3('D1_TOTAL')[2]))
				oMedicao2:Cell('E1_SALDO'  ):SetValue(Round(xMoeda((cAliasSE1)->E1_VALOR - (cAliasSE1)->E1_SALDO,(cAliasSE1)->E1_MOEDA,nMoedaD,dDataRef,6),TamSX3('E1_SALDO')[2]))
				oMedicao2:Cell('E1_RETCNTR'):SetValue(Round(xMoeda((cAliasSE1)->E1_RETCNTR,(cAliasSE1)->E1_MOEDA,nMoedaD,dDataRef,6),TamSX3('E1_RETCNTR')[2]))
			 	oMedicao2:PrintLine()
				dbSelectArea(cAliasSE1)
				dbSkip()
			EndDo

			// Fecha o alias da query
			(cAliasSE1)->(dbCloseArea())

			dbSelectArea(cAliasSD2)
			dbSkip()
		EndDo

		// Fecha o alias da query
		(cAliasSD2)->(dbCloseArea())
	EndIf
	dbSelectArea(cAliasRel)
	dbSkip()
EndDo

If !lFstCpr
	oMedicao:Finish()
EndIf

If !lFstVnd
	oMedicao2:Finish()
EndIf

Return

