#INCLUDE "Matr917.ch"
#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Matr917   ³ Autor ³ Andressa Fagundes     ³ Data ³17/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatorio para totalizar os movimentos de entrada/saida     ³±±
±±³          ³de produtos incentivados ou nao pelo PRODEPE                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Matr917()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport	:= ReportDef()
	oReport:PrintDialog()
Else
	Matr917R3()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Andressa Fagundes      ³ Data ³17/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oCabec
Local oSaidni
Local oSaidi
Local oEntrni
Local oEntri
Local oResni
Local oResi
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Componente de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("MATR917","Resumo das Movimentacoes de Produtos Incentivados/Nao Incetivados-Prodepe","MTR917",{|oReport| ReportPrint(oReport)},STR0002+" "+STR0003) // Este relatorio ira imprimir os movimentos de entrada e saida de produtos incentivados ou nao pelo PRODEPE.
Pergunte("MTR917",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Cabecalho Padrao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCabec	:= TRSection():New(oReport,"Dados da Empresa/Filial",{"SM0"},{"Emissão"},/*Campos do SX3*/,/*Campos do SIX*/)
oCabec:SetTotalInLine(.F.)
TRCell():New(oCabec,"M0_NOMECOM"	,"SM0"	,"EMPRESA"	,/*Picture*/,50	,/*lPixel*/,{|| SM0->M0_NOMECOM })
TRCell():New(oCabec,"M0_CGC"		,"SM0"	,"C.N.P.J"	,"@R 99.999.999/9999-99" ,18 ,/*lPixel*/,{|| SM0->M0_CGC })
TRCell():New(oCabec,"M0_INSC"		,"SM0"	,"I.E"		,/*Picture*/,14	,/*lPixel*/,{|| SM0->M0_INSC })
TRCell():New(oCabec,"M0_ENDENT"		,"SM0"	,"ENDERECO"	,/*Picture*/,30	,/*lPixel*/,{|| SM0->M0_ENDENT })
TRCell():New(oCabec,"M0_CIDENT"		,"SM0"	,"CIDADE"	,/*Picture*/,20	,/*lPixel*/,{|| SM0->M0_CIDENT })
TRCell():New(oCabec,"M0_ESTENT"		,"SM0"	,"ESTADO"	,/*Picture*/,02,/*lPixel*/,{||  SM0->M0_ESTENT })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Movimentos de Saida com Produtos Nao Incentivados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSaidni := TRSection():New(oReport,"Saida Prod. Nao Incentivado",{"SD2","SB1","SF3","SB5"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSaidni:SetTotalInLine(.F.)
TRCell():New(oSaidni,"D2_EMISSAO"	,"SD2"	,"EMISSAO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidni,"D2_DOC"		,"SD2"	,"NUMERO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidni,SerieNfId("SD2",3,"D2_SERIE"),"SD2"	,"SERIE"			,/*Picture*/,SerieNfId("SD2",6,"D2_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidni,"D2_CF"		,"SD2"	,"CFOP"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidni,"D2_COD"		,"SD2"	,"CODIGO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidni,"B1_DESC"		,"SB1"	,"DESCRICAO"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidni,"D2_TOTAL"		,"SD2"	,"VALOR CONTABIL"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nValCont}*/)
TRCell():New(oSaidni,"D2_BASEICM"	,"SD2"	,"BASE DE CALCULO"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nBase}*/)
TRCell():New(oSaidni,"D2_VALICM"	,"SD2"	,"VALOR ICMS"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nICMS}*/)
//Totalizadores
TRFunction():New(oSaidni:Cell("D2_TOTAL")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSaidni:Cell("D2_BASEICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSaidni:Cell("D2_VALICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oReport:Section(2):SetTotalText("TOTALIZACAO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 3 - Movimentos de Saida com Produtos Incentivados      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSaidi := TRSection():New(oReport,"Saida Prod. Incentivado",{"SD2","SB1","SF3","SB5"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSaidi:SetTotalInLine(.F.)
TRCell():New(oSaidi,"D2_EMISSAO"	,"SD2"	,"EMISSAO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidi,"D2_DOC"		,"SD2"	,"NUMERO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidi,SerieNfId("SD2",3,"D2_SERIE")	,"SD2"	,"SERIE"			,/*Picture*/,SerieNfId("SD2",6,"D2_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidi,"D2_CF"			,"SD2"	,"CFOP"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidi,"D2_COD"		,"SD2"	,"CODIGO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidi,"B1_DESC"		,"SB1"	,"DESCRICAO"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSaidi,"D2_TOTAL"		,"SD2"	,"VALOR CONTABIL"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nValCont}*/)
TRCell():New(oSaidi,"D2_BASEICM"	,"SD2"	,"BASE DE CALCULO"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nBase}*/)
TRCell():New(oSaidi,"D2_VALICM"		,"SD2"	,"VALOR ICMS"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nICMS}*/)
//Totalizadores
TRFunction():New(oSaidi:Cell("D2_TOTAL")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSaidi:Cell("D2_BASEICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSaidi:Cell("D2_VALICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oReport:Section(3):SetTotalText("TOTALIZACAO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 4 - Movimentos de Entrada com Produtos Nao Incentivados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEntrni := TRSection():New(oReport,"Entrada Prod. Nao Incentivado",{"SD1","SB1","SF3","SB5"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oEntrni:SetTotalInLine(.F.)
TRCell():New(oEntrni,"D1_EMISSAO"	,"SD1"	,"EMISSAO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,"D1_DTDIGIT"	,"SD1"	,"DT.ENTRADA"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,"D1_DOC"		,"SD1"	,"NUMERO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,SerieNfId("SD1",3,"D1_SERIE")		,"SD1"	,"SERIE"			,/*Picture*/,SerieNfId("SD1",6,"D1_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,"D1_CF"		,"SD1"	,"CFOP"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,"D1_COD"		,"SD1"	,"CODIGO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,"B1_DESC"		,"SB1"	,"DESCRICAO"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntrni,"D1_TOTAL"		,"SD1"	,"VALOR CONTABIL"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nValCont}*/)
TRCell():New(oEntrni,"D1_BASEICM"	,"SD1"	,"BASE DE CALCULO"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nBase}*/)
TRCell():New(oEntrni,"D1_VALICM"	,"SD1"	,"VALOR ICMS"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nICMS}*/)
//Totalizadores
TRFunction():New(oEntrni:Cell("D1_TOTAL")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEntrni:Cell("D1_BASEICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEntrni:Cell("D1_VALICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oReport:Section(4):SetTotalText("TOTALIZACAO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 5 - Movimentos de Entrada com Produtos Incentivados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEntri := TRSection():New(oReport,"Entrada Prod. Incentivado",{"SD1","SB1","SF3","SB5"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oEntri:SetTotalInLine(.F.)
TRCell():New(oEntri,"D1_EMISSAO"	,"SD1"	,"EMISSAO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,"D1_DTDIGIT"	,"SD1"	,"DT.ENTRADA"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,"D1_DOC"		,"SD1"	,"NUMERO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,SerieNfId("SD1",3,"D1_SERIE")		,"SD1"	,"SERIE"			,/*Picture*/,SerieNfId("SD1",6,"D1_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,"D1_CF"			,"SD1"	,"CFOP"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,"D1_COD"		,"SD1"	,"CODIGO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,"B1_DESC"		,"SB1"	,"DESCRICAO"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEntri,"D1_TOTAL"		,"SD1"	,"VALOR CONTABIL"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nValCont}*/)
TRCell():New(oEntri,"D1_BASEICM"	,"SD1"	,"BASE DE CALCULO"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nBase}*/)
TRCell():New(oEntri,"D1_VALICM"		,"SD1"	,"VALOR ICMS"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||nICMS}*/)
//Totalizadores
TRFunction():New(oEntri:Cell("D1_TOTAL")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEntri:Cell("D1_BASEICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEntri:Cell("D1_VALICM")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oReport:Section(5):SetTotalText("TOTALIZACAO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 6 - Resumo por Produto Nao Incentivado         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oResni := TRSection():New(oReport,"Resumo Prod. Nao Incentivado",{"PRO","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oResni:SetTotalInLine(.F.)
TRCell():New(oResni,"PRO_COD"		,"PRO"	,"CODIGO"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oResni,"PRO_DESCR"		,"PRO"	,"DESCRICAO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oResni,"PRO_CONTE"		,"PRO"	,"VL.CONTABIL ENTRADA"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_CONTE }*/) //nValContS
TRCell():New(oResni,"PRO_BASEE"		,"PRO"	,"BS.CALCULO ENTRADA"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_BASEE }*/) //nBaseS
TRCell():New(oResni,"PRO_ICMSE"		,"PRO"	,"VL.ICMS ENTRADA"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_ICMSE }*/) //nICMSS
TRCell():New(oResni,"PRO_CONTS"		,"PRO"	,"VL.CONTABIL SAIDA"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_CONTS }*/) //nValContS
TRCell():New(oResni,"PRO_BASES"		,"PRO"	,"BS.CALCULO SAIDA"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_BASES }*/) //nBaseS
TRCell():New(oResni,"PRO_ICMSS"		,"PRO"	,"VL.ICMS SAIDA"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_ICMSS }*/) //nICMSS
//Totalizadores
TRFunction():New(oResni:Cell("PRO_CONTS")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResni:Cell("PRO_BASES")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResni:Cell("PRO_ICMSS")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResni:Cell("PRO_CONTE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResni:Cell("PRO_BASEE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResni:Cell("PRO_ICMSE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oReport:Section(6):SetTotalText("TOTALIZACAO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 7 - Resumo por Produto Incentivado             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oResi := TRSection():New(oReport,"Resumo Prod. Incentivado",{"PRO","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oResi:SetTotalInLine(.F.)
TRCell():New(oResi,"PRO_COD"		,"PRO"	,"CODIGO"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oResi,"PRO_DESCR"		,"PRO"	,"DESCRICAO"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oResi,"PRO_CONTE"		,"PRO"	,"VL.CONTABIL ENTRADA"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_CONTE }*/) //nValContS
TRCell():New(oResi,"PRO_BASEE"		,"PRO"	,"BS.CALCULO ENTRADA"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_BASEE }*/) //nBaseS
TRCell():New(oResi,"PRO_ICMSE"		,"PRO"	,"VL.ICMS ENTRADA"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_ICMSE }*/) //nICMSS
TRCell():New(oResi,"PRO_CONTS"		,"PRO"	,"VL.CONTABIL SAIDA"	,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_CONTS }*/) //nValContS
TRCell():New(oResi,"PRO_BASES"		,"PRO"	,"BS.CALCULO SAIDA"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_BASES }*/) //nBaseS
TRCell():New(oResi,"PRO_ICMSS"		,"PRO"	,"VL.ICMS SAIDA"		,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{||PRO->PRO_ICMSS }*/) //nICMSS
//Totalizadores
TRFunction():New(oResi:Cell("PRO_CONTS")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResi:Cell("PRO_BASES")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResi:Cell("PRO_ICMSS")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResi:Cell("PRO_CONTE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResi:Cell("PRO_BASEE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oResi:Cell("PRO_ICMSE")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,"@E 999,999,999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oReport:Section(7):SetTotalText("TOTALIZACAO")

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Eduardo Riera          ³ Data ³17/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cIncentivo:= Upper(GetNewPar("MV_SEF03",""))
Local cMvProCFn := (GetNewPar("MV_PRODCF",""))
Local cInc      := ""
Local cArqPRO   := ""
Local oSaidni   := oReport:Section(2)
Local oSaidi    := oReport:Section(3)
Local oEntrni   := oReport:Section(4)
Local oEntri    := oReport:Section(5)
Local lFirst    := .F.
Local lHouveMov := .F.
Local aStru     := {}
Local nTipoMov  := mv_par03
Local cProdepe  := ""
Local cCpoDt    := ""
Local cSelect   := ""
Local cSelect2  := ""
Local cSelectD1 := ""
Local cSeleD12  := ""

#IFNDEF TOP
	Local cCondicao := ""
	Local cChave    := ""
#ENDIF

Private	nValContS	:= 0
Private	nBaseS		:= 0
Private	nICMSS		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente processa se existir o parametro com conteudo valido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cIncentivo)
	MsgStop(OemToAnsi(STR0022) + Chr(13) + Chr(10) + OemToAnsi(STR0023),OemToAnsi(STR0024))
	// "Parametro MV_SEF03 (campo na tabela SB5 que indica o incentivo) nao cadastrado." "Verifique o cadastro para possibilitar a geracao do relatorio." "Parametro MV_SEF03"
	Return
Else
	If SB5->(FieldPos(cIncentivo)) == 0
		MsgStop(OemToAnsi(STR0025) + " (" + Alltrim(cIncentivo) + ") " + Chr(13) + Chr(10) + OemToAnsi(STR0026),OemToAnsi(STR0027))
		// "Campo da tabela SB5 que indica o incentivo inexistente." "Verifique o conteudo do parametro MV_SEF03 para possibilitar a geracao do relatorio." "Conteudo MV_SEF03"
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a estrutura do arquivo temporario para a impressao do relatorio.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"PRO_COD"		,"C",015,0})
AADD(aStru,{"PRO_DESCR"		,"C",030,0})
AADD(aStru,{"PRO_INCENT"	,"C",002,0})
AADD(aStru,{"PRO_CONTS"		,"N",013,2})
AADD(aStru,{"PRO_CONTE"		,"N",013,2})
AADD(aStru,{"PRO_BASES"		,"N",013,2})
AADD(aStru,{"PRO_BASEE"		,"N",013,2})
AADD(aStru,{"PRO_ICMSS"		,"N",013,2})
AADD(aStru,{"PRO_ICMSE"		,"N",013,2})

cArqPRO	:=	CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArqPRO,"PRO")
IndRegua("PRO",cArqPRO,"PRO_COD")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Movimentacao de Saida                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipoMov == 1 .Or. nTipoMov == 3

	#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transforma parametros Range em expressao SQL   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MakeSqlExpr(oReport:uParam)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatório da secao 2 e 3             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(2):BeginQuery()
		oReport:Section(3):BeginQuery()

		cAliasSD2 := GetNextAlias()
		cSelect:= "%"
		cSelect+= "D2_DOC,D2_SERIE,"
		cSelect+= Iif(SerieNfId("SD2",3,"D2_SERIE")<>"D2_SERIE",SerieNfId("SD2",3,"D2_SERIE")+", ","")
		cSelect+= "D2_CLIENTE,D2_LOJA,D2_EMISSAO,D2_CF,D2_COD,D2_TOTAL,D2_BASEICM,D2_VALICM,B5_COD,B1_DESC"
		cSelect+= "%"

		cSelect2:="%F3_NFISCAL,F3_SERIE,"
		cSelect2+= Iif(SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE",SerieNfId("SF3",3,"F3_SERIE")+", ","")
		cSelect2+="F3_CLIEFOR,F3_LOJA,F3_CFO%"

		BeginSql Alias cAliasSD2

		SELECT
			%Exp:cSelect%

		FROM
			%table:SD2% SD2, %table:SB1% SB1, %table:SB5% SB5

		WHERE
			D2_FILIAL = %xFilial:SD2% AND
			D2_TIPO <> 'S' AND
			D2_CF >= '5' AND
			D2_EMISSAO >= %Exp:Dtos(mv_par01)% AND
			D2_EMISSAO <= %Exp:Dtos(mv_par02)% AND
			B1_FILIAL = %xFilial:SB1% AND
			B1_COD = D2_COD AND
			SB1.%NotDel% AND
			B5_FILIAL = %xFilial:SB5% AND
			B5_COD = D2_COD AND
			SB5.%NotDel% AND
			SD2.%NotDel% AND EXISTS
				(	SELECT %Exp:cSelect2%
					FROM %table:SF3% SF3
					WHERE
						F3_FILIAL = %xFilial:SF3% AND
						F3_OBSERV NOT LIKE '%CANCELAD%' AND
						F3_DTCANC = ' ' AND
						SF3.%NotDel% AND
						F3_NFISCAL = D2_DOC AND
						F3_SERIE = D2_SERIE AND
						F3_CLIEFOR = D2_CLIENTE AND
						F3_LOJA = D2_LOJA AND
						F3_CFO = D2_CF )
		ORDER BY D2_EMISSAO,D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA

		EndSql
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatório para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)
		oReport:Section(3):EndQuery(/*Array com os parametros do tipo Range*/)

	#ELSE
		dbSelectArea("SD2")
		cChave    := 'DTOS(D2_EMISSAO)+D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE,D2_LOJA'
		cCondicao := "D2_FILIAL == '"+xFilial("SD2")+"' .AND. "
		cCondicao += "Dtos(D2_EMISSAO)>= '"+Dtos(mv_par01)+"' .AND. Dtos(D2_EMISSAO)<= '"+Dtos(mv_par02)+"' .AND. "
		cCondicao += "D2_TIPO <> 'S' .AND. SUBSTR(D2_CF,1,1) >= '5'"

		oReport:Section(2):SetFilter(cCondicao,cChave)
		oReport:Section(3):SetFilter(cCondicao,cChave)
	#ENDIF

	TRPosition():New(oSaidni,"SB1",1,{|| xFilial("SB1") + (cAliasSD2)->D2_COD})
	TRPosition():New(oSaidi ,"SB1",1,{|| xFilial("SB1") + (cAliasSD2)->D2_COD})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Movimentacao de Entrada                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipoMov == 2 .Or. nTipoMov == 3
	If mv_par05 == 1
		cCpoDt := "D1_DTDIGIT"
	Else
		cCpoDt := "D1_EMISSAO"
	EndIf
	#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transforma parametros Range em expressao SQL   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MakeSqlExpr(oReport:uParam)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatório da secao 4 e 5             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(4):BeginQuery()
		oReport:Section(5):BeginQuery()

		cAliasSD1 := GetNextAlias()

		cProdepe := "D1_CF NOT IN " + FisxForm(cMvProCFn,"/") + " AND "
		cProdepe := "%"+cProdepe+"%"
		cCpoDt   := "%"+cCpoDt+"%"

		cSelectD1:= "%"
		cSelectD1+= "D1_DOC,D1_SERIE,"
		cSelectD1+= IIF(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE",SerieNfId("SD1",3,"D1_SERIE")+", ","")
		cSelectD1+= "D1_FORNECE,D1_LOJA,D1_EMISSAO,D1_DTDIGIT,D1_CF,D1_COD,D1_TOTAL,D1_BASEICM,D1_VALICM,B5_COD,B1_DESC"
		cSelectD1+= "%"

		cSeleD12:= "%F3_NFISCAL,F3_SERIE,"
		cSeleD12+= Iif(SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE",SerieNfId("SF3",3,"F3_SERIE")+", ","")
		cSeleD12+= "F3_CLIEFOR,F3_LOJA,F3_CFO%"

		BeginSql Alias cAliasSD1

		SELECT
			%Exp:cSelectD1%

		FROM
			%table:SD1% SD1, %table:SB1% SB1,%table:SB5% SB5

		WHERE
			D1_FILIAL = %xFilial:SD1% AND
			D1_TIPO <> 'S' AND
			D1_CF < '5' AND
			%Exp:cCpoDt% >= %Exp:Dtos(mv_par01)% AND
			%Exp:cCpoDt% <= %Exp:Dtos(mv_par02)% AND
			%Exp:cProdepe%
			B1_FILIAL = %xFilial:SB1% AND
			B1_COD = D1_COD AND
			SB1.%NotDel% AND
			B5_FILIAL = %xFilial:SB5% AND
			B5_COD = D1_COD AND
			SB5.%NotDel% AND
			SD1.%NotDel% AND EXISTS
				(	SELECT %Exp:cSeleD12%
					FROM %table:SF3% SF3
					WHERE
						F3_FILIAL = %xFilial:SF3% AND
						F3_OBSERV NOT LIKE '%CANCELAD%' AND
						F3_DTCANC = ' ' AND
						SF3.%NotDel% AND
						F3_NFISCAL = D1_DOC AND
						F3_SERIE = D1_SERIE AND
						F3_CLIEFOR = D1_FORNECE AND
						F3_LOJA = D1_LOJA AND
						F3_CFO = D1_CF )
		ORDER BY %Exp:cCpoDt%,D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA

		EndSql
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatório para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(4):EndQuery(/*Array com os parametros do tipo Range*/)
		oReport:Section(5):EndQuery(/*Array com os parametros do tipo Range*/)

	#ELSE
		dbSelectArea("SD1")
		cChave    := 'DTOS('+cCpoDt+')+D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE,D1_LOJA'
		cCondicao := "D1_FILIAL == '"+xFilial("SD1")+"' .AND. "
		cCondicao += "Dtos("+cCpoDt+")>= '"+Dtos(mv_par01)+"' .AND. Dtos("+cCpoDt+")<= '"+Dtos(mv_par02)+"' .AND. "
		cCondicao += "D1_TIPO <> 'S' .AND. SUBSTR(D1_CF,1,1) < '5' .AND."
		cCondicao += "!(alltrim(D1_CF) $ '" + cMvProCFn + "')"

		oReport:Section(4):SetFilter(cCondicao,cChave)
		oReport:Section(5):SetFilter(cCondicao,cChave)
	#ENDIF

	TRPosition():New(oEntrni,"SB1",1,{|| xFilial("SB1") + (cAliasSD1)->D1_COD})
	TRPosition():New(oEntri ,"SB1",1,{|| xFilial("SB1") + (cAliasSD1)->D1_COD})

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Cabecalho                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(1)
	oReport:Section(1):Init()
	oReport:Section(1):PrintLine()
	oReport:Section(1):Finish()

If nTipoMov == 1 .Or. nTipoMov == 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Movimentos de Saida com Produtos Nao Incentivados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cAliasSD2)->(dbGoTop())
	dbSelectArea(cAliasSD2)
	oReport:SetMeter(SD2->(LastRec()))
	oReport:SkipLine()
	oReport:Section(2):Init()
	oReport:PrintText("MOVIMENTOS DE SAIDA COM PRODUTOS NAO INCENTIVADOS")
	oReport:SkipLine()

	While !oReport:Cancel() .And. !(cAliasSD2)->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		SF3->(dbSetOrder(1))
		If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_CF))
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5") + (cAliasSD2)->D2_COD))
		cInc := SB5->&(cIncentivo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos sem incentivo = 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc <> "01"
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.
		oReport:SetMeter(1)
		oReport:Section(2):PrintLine()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD2)->D2_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD2)->D2_COD
			PRO->PRO_DESCR	:= SB1->B1_DESC
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTS	:= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	:= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	:= (cAliasSD2)->D2_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTS	+= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	+= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	+= (cAliasSD2)->D2_VALICM
		Endif
		MsUnlock()
		(cAliasSD2)->(dbSkip())
	EndDo

	If !lHouveMov
		oReport:SetMeter(1)
		oReport:Section(2):PrintLine()
		oReport:SkipLine()
		oReport:PrintText("*** NAO HOUVE MOVIMENTO ***")
		oReport:SkipLine(3)
	Endif

	oReport:Section(2):Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 3 - Movimentos de Saida com Produtos Incentivados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lHouveMov := .F.
	(cAliasSD2)->(dbGoTop())
	oReport:SetMeter(SD2->(LastRec()))
	oReport:EndPage()
	oReport:Section(3):Init()
	oReport:PrintText("MOVIMENTOS DE SAIDA COM PRODUTOS INCENTIVADOS")
	oReport:SkipLine()

	While !oReport:Cancel() .And. !(cAliasSD2)->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		SF3->(dbSetOrder(1))
		If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_CF))
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5") + (cAliasSD2)->D2_COD))
		cInc := SB5->&(cIncentivo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos com incentivo <> 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc == "01"
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.
		oReport:SetMeter(1)
		oReport:Section(3):PrintLine()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD2)->D2_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD2)->D2_COD
			PRO->PRO_DESCR	:= SB1->B1_DESC
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTS	:= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	:= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	:= (cAliasSD2)->D2_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTS	+= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	+= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	+= (cAliasSD2)->D2_VALICM
		Endif
		MsUnlock()
		(cAliasSD2)->(dbSkip())
	EndDo

	If !lHouveMov
		oReport:SetMeter(1)
		oReport:Section(3):PrintLine()
		oReport:SkipLine()
		oReport:PrintText("*** NAO HOUVE MOVIMENTO ***")
		oReport:SkipLine(3)
	Endif

	oReport:Section(3):Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()

	(cAliasSD2)->(DbCloseArea())
Endif

If nTipoMov == 2 .Or. nTipoMov == 3
	If mv_par05 == 1
		oReport:Section(4):Cell("D1_EMISSAO"):Disable()
		oReport:Section(4):Cell("D1_DTDIGIT"):Enable()
		oReport:Section(5):Cell("D1_EMISSAO"):Disable()
		oReport:Section(5):Cell("D1_DTDIGIT"):Enable()
	Else
		oReport:Section(4):Cell("D1_EMISSAO"):Enable()
		oReport:Section(4):Cell("D1_DTDIGIT"):Disable()
		oReport:Section(5):Cell("D1_EMISSAO"):Enable()
		oReport:Section(5):Cell("D1_DTDIGIT"):Disable()
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 4 - Movimentos de Entrada com Produtos Nao Incentivados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lHouveMov 	:= .F.
	(cAliasSD1)->(dbGoTop())
	dbSelectArea(cAliasSD1)
	oReport:SetMeter(SD1->(LastRec()))
	If nTipoMov == 3
		oReport:EndPage()
	Endif

	oReport:SkipLine()
	oReport:Section(4):Init()
	oReport:PrintText("MOVIMENTOS DE ENTRADA COM PRODUTOS NAO INCENTIVADOS")
	oReport:SkipLine()

	While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		SF3->(dbSetOrder(1))
		If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD1)->D1_EMISSAO)+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_CF))
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5") + (cAliasSD1)->D1_COD))
		cInc := SB5->&(cIncentivo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos sem incentivo = 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc <> "01"
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.
		oReport:SetMeter(1)
		oReport:Section(4):PrintLine()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD1)->D1_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD1)->D1_COD
			PRO->PRO_DESCR	:= SB1->B1_DESC
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTE	:= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	:= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	:= (cAliasSD1)->D1_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTE	+= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	+= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	+= (cAliasSD1)->D1_VALICM
		Endif
		MsUnlock()
		(cAliasSD1)->(dbSkip())
	EndDo

	If !lHouveMov
		oReport:SetMeter(1)
		oReport:Section(4):PrintLine()
		oReport:SkipLine()
		oReport:PrintText("*** NAO HOUVE MOVIMENTO ***")
		oReport:SkipLine(3)
	Endif

	oReport:Section(4):Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 5 - Movimentos de Entrada com Produtos Incentivados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lHouveMov := .F.
	(cAliasSD1)->(dbGoTop())
	oReport:SetMeter(SD1->(LastRec()))
	oReport:EndPage()
	oReport:Section(5):Init()
	oReport:PrintText("MOVIMENTOS DE ENTRADA COM PRODUTOS INCENTIVADOS")
	oReport:SkipLine()

	While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		SF3->(dbSetOrder(1))
		If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD1)->D1_EMISSAO)+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_CF))
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5") + (cAliasSD1)->D1_COD))
		cInc := SB5->&(cIncentivo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos com incentivo <> 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc == "01"
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.
		oReport:SetMeter(1)
		oReport:Section(5):PrintLine()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD1)->D1_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD1)->D1_COD
			PRO->PRO_DESCR	:= SB1->B1_DESC
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTE	:= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	:= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	:= (cAliasSD1)->D1_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTE	+= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	+= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	+= (cAliasSD1)->D1_VALICM
		Endif
		MsUnlock()
		(cAliasSD1)->(dbSkip())
	EndDo

	If !lHouveMov
		oReport:SetMeter(1)
		oReport:Section(5):PrintLine()
		oReport:SkipLine()
		oReport:PrintText("*** NAO HOUVE MOVIMENTO ***")
		oReport:SkipLine(3)
	Endif

	oReport:Section(5):Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()

	(cAliasSD1)->(DbCloseArea())

Endif

If mv_par04 == 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 6 - RESUMO POR PRODUTO NAO INCENTIVADO                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(PRO->(LastRec()))
	oReport:EndPage()
	oReport:Section(6):Init()
	oReport:PrintText("RESUMO POR PRODUTO NAO INCENTIVADO")
	oReport:SkipLine()

	oReport:Section(6):Cell("PRO_COD"):SetBlock({|| PRO->PRO_COD })
	oReport:Section(6):Cell("PRO_DESCR"):SetBlock({|| PRO->PRO_DESCR })
	oReport:Section(6):Cell("PRO_CONTE"):SetBlock({|| PRO->PRO_CONTE })
	oReport:Section(6):Cell("PRO_BASEE"):SetBlock({|| PRO->PRO_BASEE })
	oReport:Section(6):Cell("PRO_ICMSE"):SetBlock({|| PRO->PRO_ICMSE })
	oReport:Section(6):Cell("PRO_CONTS"):SetBlock({|| PRO->PRO_CONTS })
	oReport:Section(6):Cell("PRO_BASES"):SetBlock({|| PRO->PRO_BASES })
	oReport:Section(6):Cell("PRO_ICMSS"):SetBlock({|| PRO->PRO_ICMSS })

	// Produtos sem incentivo
	nValContE	:= 0
	nBaseE		:= 0
	nICMSE		:= 0
	nValContS	:= 0
	nBaseS		:= 0
	nICMSS		:= 0
	nLin		:= 0
	PRO->(dbSetOrder(1))
	PRO->(dbGoTop())
	While ! PRO->(Eof())
		If PRO->PRO_INCENT == "01"
			nValContE	+= PRO->PRO_CONTE
			nBaseE		+= PRO->PRO_BASEE
			nICMSE		+= PRO->PRO_ICMSE
			nValContS	+= PRO->PRO_CONTS
			nBaseS		+= PRO->PRO_BASES
			nICMSS		+= PRO->PRO_ICMSS
			lHouveMov := .T.
			oReport:SetMeter(1)
			oReport:Section(6):PrintLine()
		Endif
		PRO->(dbSkip())
	Enddo

	If !lHouveMov
		oReport:SetMeter(1)
		oReport:Section(6):PrintLine()
		oReport:SkipLine()
		oReport:PrintText("*** NAO HOUVE MOVIMENTO ***")
		oReport:SkipLine(3)
	Endif
	oReport:Section(6):Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 7 - RESUMO POR PRODUTO INCENTIVADO                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(PRO->(LastRec()))
	oReport:EndPage()
	oReport:Section(7):Init()
	oReport:PrintText("RESUMO POR PRODUTO INCENTIVADO")
	oReport:SkipLine()

	oReport:Section(7):Cell("PRO_COD"):SetBlock({|| PRO->PRO_COD })
	oReport:Section(7):Cell("PRO_DESCR"):SetBlock({|| PRO->PRO_DESCR })
	oReport:Section(7):Cell("PRO_CONTE"):SetBlock({|| PRO->PRO_CONTE })
	oReport:Section(7):Cell("PRO_BASEE"):SetBlock({|| PRO->PRO_BASEE })
	oReport:Section(7):Cell("PRO_ICMSE"):SetBlock({|| PRO->PRO_ICMSE })
	oReport:Section(7):Cell("PRO_CONTS"):SetBlock({|| PRO->PRO_CONTS })
	oReport:Section(7):Cell("PRO_BASES"):SetBlock({|| PRO->PRO_BASES })
	oReport:Section(7):Cell("PRO_ICMSS"):SetBlock({|| PRO->PRO_ICMSS })

	// Produtos com incentivo
	nValContE	:= 0
	nBaseE		:= 0
	nICMSE		:= 0
	nValContS	:= 0
	nBaseS		:= 0
	nICMSS		:= 0
	nLin		:= 0
	PRO->(dbSetOrder(1))
	PRO->(dbGoTop())
	While ! PRO->(Eof())
		If PRO->PRO_INCENT <> "01"
			nValContE	+= PRO->PRO_CONTE
			nBaseE		+= PRO->PRO_BASEE
			nICMSE		+= PRO->PRO_ICMSE
			nValContS	+= PRO->PRO_CONTS
			nBaseS		+= PRO->PRO_BASES
			nICMSS		+= PRO->PRO_ICMSS
			lHouveMov := .T.
			oReport:SetMeter(1)
			oReport:Section(7):PrintLine()
		Endif
		PRO->(dbSkip())
	Enddo

	If !lHouveMov
		oReport:SetMeter(1)
		oReport:Section(7):PrintLine()
		oReport:SkipLine()
		oReport:PrintText("*** NAO HOUVE MOVIMENTO ***")
		oReport:SkipLine(3)
	Endif
	oReport:Section(7):Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Excluindo tabela temporaria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("PRO")
dbCloseArea()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MATR917  ºAutor  ³Mary C. Hergert     º Data ³ 26/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para totalizar os movimentos de entrada/saida    º±±
±±º          ³ de produtos incentivados ou nao pelo PRODEPE               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigafis                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Matr917R3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao das variaveis                                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private titulo		:=	STR0001 //"Resumo de Movimentos de Produtos Incentivados / Nao Incentivados - PRODEPE"
Private cDesc1		:=	STR0002 //"Este relatório ira imprimir os movimentos de entrada e saida de"
Private cDesc2		:=	STR0003 //"produtos incentivados ou nao pelo PRODEPE."
Private cDesc3		:=	""
Private aReturn  	:=	{STR0004,1,STR0005,2,2,1,"",1} //"Zebrado"###"Administracao"
Private nomeprog 	:=	"MATR917"
Private cPerg    	:=	"MTR917"
Private nLastKey 	:=	0
Private Limite   	:=	220
Private Tamanho  	:=	"G"
Private lEnd   		:= 	.F.		// Controle de cancelamento do relatorio
Private m_pag  		:= 	1  		// Contador de Paginas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString  :=	"SD2"
Titulo   :=	STR0001 //"Resumo de Produtos Incentivados - PRODEPE"
cabec1   :=	""
cabec2   :=	""

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Data Inicial                         ³
//³ mv_par02             // Data Final                           ³
//³ mv_par03             // Movimentos a imprimir                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//| Nao havera filtro, o relatorio varre duas tabelas diferentes |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel	:=	"MATR917"   // Nome default do relatorio em disco
wnrel	:=	SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

nPagina	:=	1

If nLastKey == 27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| ImpRel(@lEnd,wnRel,cString,Tamanho, nPagina)},titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	Ourspool(wnrel)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImpRel   ºAutor  ³Mary C. Hergert     º Data ³ 26/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatorio                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Matr917                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpRel(lEnd,wnRel,cString,Tamanho, nPagina)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Variaveis                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cAlias    := ""
Local cMes      := ""
Local cNrLivro  := mv_par03
Local cLoja		:= ""
Local cDocto	:= ""
Local cSerie	:= ""
Local cCliente 	:= ""
Local cFornec	:= ""
Local cCfop		:= ""
Local cIncentivo:= Upper(GetNewPar("MV_SEF03",""))
Local cMvProCFn := GetNewPar("MV_PRODCF","")

Local cDescri   := ""
Local cInc 		:= ""
Local cCpoDt    := ""
Local dEmissao  := cTod("  /  /  ")

Local lQuery    := .F.
Local lHouveMov	:= .F.

Local aLay      := Array(40)
Local aTemp		:= {}

Local nLin      := 0
Local nTipoMov	:= mv_par03
Local nX		:= 0
Local nValCont  := 0
Local nBase 	:= 0
Local nICMS 	:= 0
Local nOutras	:= 0
Local nTValCont := 0
Local nTBase 	:= 0
Local nTICMS 	:= 0
Local nTOutras	:= 0
Local nValContE	:= 0
Local nBaseE	:= 0
Local nICMSE	:= 0
Local nValContS	:= 0
Local nBaseS	:= 0
Local nICMSS	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente processa se existir o parametro com conteudo valido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cIncentivo)
	MsgStop(OemToAnsi(STR0022) + Chr(13) + Chr(10) + OemToAnsi(STR0023),OemToAnsi(STR0024))
	// "Parametro MV_SEF03 (campo na tabela SB5 que indica o incentivo) nao cadastrado." "Verifique o cadastro para possibilitar a geracao do relatorio." "Parametro MV_SEF03"
	Return
Else
	If SB5->(FieldPos(cIncentivo)) == 0
		MsgStop(OemToAnsi(STR0025) + " (" + Alltrim(cIncentivo) + ") " + Chr(13) + Chr(10) + OemToAnsi(STR0026),OemToAnsi(STR0027))
		// "Campo da tabela SB5 que indica o incentivo inexistente." "Verifique o conteudo do parametro MV_SEF03 para possibilitar a geracao do relatorio." "Conteudo MV_SEF03"
		Return
	Endif
Endif

aTemp := Mtr917Stru()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Movimentacao de Saida                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipoMov == 1 .Or. nTipoMov == 3

	#IFDEF TOP
		lQuery := .T.
		cAliasSD2:= "SD2_PRODEPE"
		aStru  := SD2->(dbStruct())
		cQuery := "SELECT SD2.D2_DOC,SD2.D2_SERIE,"+Iif(SerieNfId("SD2",3,"D2_SERIE")<>"D2_SERIE","SD2.D2_SDOC,","")
		cQuery += "SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_EMISSAO,"
		cQuery += "SD2.D2_CF,SD2.D2_COD,SD2.D2_TOTAL,SD2.D2_BASEICM,SD2.D2_VALICM,"
		cQuery += "SB5.B5_COD,SB5." + AllTrim(cIncentivo) + ",SB1.B1_DESC "
		cQuery += "FROM " + RetSqlName("SD2") + " SD2 , "
		cQuery += RetSqlName("SB1") + " SB1 , "
		cQuery += RetSqlName("SB5") + " SB5 "
		cQuery += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
		cQuery += "SD2.D2_TIPO <> 'S' AND "
		cQuery += "SD2.D2_CF >= '5' AND "
		cQuery += "SD2.D2_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
		cQuery += "SD2.D2_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
		cQuery += "SB5." + AllTrim(cIncentivo) + " <> '"+Space(Len(SB5->&(cIncentivo)))+"' AND "
		cQuery += "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += "SB1.B1_COD = SD2.D2_COD AND "
		cQuery += "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQuery += "SB5.B5_COD = SD2.D2_COD AND "
		cQuery += "SD2.D_E_L_E_T_ = ' ' AND "
		cQuery += "EXISTS (SELECT SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_CFO "
		cQuery += "FROM " + RetSqlName("SF3") + " SF3 WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery += "SF3.F3_DTCANC = '"+Space(Len(Dtos(SF3->F3_DTCANC)))+"' AND "
		cQuery += "SF3.F3_OBSERV NOT LIKE '%CANCELAD%' AND SF3.D_E_L_E_T_ = ' ' AND "
		cQuery += "SF3.F3_NFISCAL = SD2.D2_DOC AND SF3.F3_SERIE = SD2.D2_SERIE AND "
		cQuery += "SF3.F3_CLIEFOR = SD2.D2_CLIENTE AND SF3.F3_LOJA = SD2.D2_LOJA AND "
		cQuery += "SF3.F3_CFO = SD2.D2_CF )"
		cQuery += "ORDER BY SD2.D2_EMISSAO,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(cAliasSD2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD2)
	#Else
		dbSelectArea("SD2")
		nIndex  := RetIndex("SD2")
		cArqInd := CriaTrab(NIL,.F.)
		cChave  := "DTOS(D2_EMISSAO)+D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE,D2_LOJA"
		cFiltro := "D2_FILIAL == '" + xFilial() + "' .AND. D2_TIPO <> 'S' .AND. SUBSTR(D2_CF,1,1) >= '5' .AND. "
		cFiltro += "DTOS(D2_EMISSAO) >= '" + Dtos(mv_par01) + "' .AND. DTOS(D2_EMISSAO) <= '" + Dtos(mv_par02) + "'"
		IndRegua(cAliasSD2,cArqInd,cChave,,cFiltro,STR0006) //"Selecionando Registros..."
		dbGotop()
		SetRegua(LastRec())
	#ENDIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Movimentacao de Entrada                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipoMov == 2 .Or. nTipoMov == 3
	If mv_par05 == 1
		cCpoDt := "D1_DTDIGIT"
	Else
		cCpoDt := "D1_EMISSAO"
	EndIf
	#IFDEF TOP
		lQuery := .T.
		cAliasSD1:= "SD1_PRODEPE"
		aStru  := SD1->(dbStruct())
		cQuery := "SELECT SD1.D1_DOC,SD1.D1_SERIE,"+Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1."+SerieNfId("SD1",3,"D1_SERIE")+",","")
		cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_EMISSAO,D1_DTDIGIT,"
		cQuery += "SD1.D1_CF,SD1.D1_COD,SD1.D1_TOTAL,SD1.D1_BASEICM,SD1.D1_VALICM,"
		cQuery += "SB5.B5_COD,SB5." + AllTrim(cIncentivo) + ",SB1.B1_DESC "
		cQuery += "FROM " + RetSqlName("SD1") + " SD1 , "
		cQuery += RetSqlName("SB1") + " SB1 , "
		cQuery += RetSqlName("SB5") + " SB5 "
		cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
		cQuery += "SD1.D1_TIPO <> 'S' AND "
		cQuery += "SD1.D1_CF < '5' AND "
		cQuery += "D1_CF NOT IN " + FisxForm(cMvProCFn,"/") + " AND "
		cQuery += "SD1."+cCpoDt+" >= '" + Dtos(mv_par01) + "' AND "
		cQuery += "SD1."+cCpoDt+" <= '" + Dtos(mv_par02) + "' AND "
		cQuery += "SB5." + AllTrim(cIncentivo) + " <> '"+Space(Len(SB5->&(cIncentivo)))+"' AND "
		cQuery += "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += "SB1.B1_COD = SD1.D1_COD AND "
		cQuery += "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQuery += "SB5.B5_COD = SD1.D1_COD AND "
		cQuery += "SD1.D_E_L_E_T_ = ' ' AND "
		cQuery += "EXISTS (SELECT SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_CFO "
		cQuery += "FROM " + RetSqlName("SF3") + " SF3 WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND SF3.F3_DTCANC = '"+Space(Len(Dtos(SF3->F3_DTCANC)))+"' AND "
		cQuery += "SF3.F3_OBSERV NOT LIKE '%CANCELAD%' AND SF3.D_E_L_E_T_ = ' 'AND "
		cQuery += "SF3.F3_NFISCAL = SD1.D1_DOC AND SF3.F3_SERIE = SD1.D1_SERIE AND "
		cQuery += "SF3.F3_CLIEFOR = SD1.D1_FORNECE AND SF3.F3_LOJA = SD1.D1_LOJA AND "
		cQuery += "SF3.F3_CFO = SD1.D1_CF) "
		cQuery += "ORDER BY SD1."+cCpoDt+",SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(cAliasSD1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD1)
	#Else
		dbSelectArea("SD1")
		nIndex  := RetIndex("SD1")
		cArqInd2:= CriaTrab(NIL,.F.)
		cChave  := "DTOS("+cCpoDt+")+D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE,D1_LOJA"
		cFiltro += "D1_FILIAL == '" + xFilial() + "' .AND. D1_TIPO <> 'S' .AND. SUBSTR(D1_CF,1,1) < '5' .AND. "
		cFiltro += "DTOS("+cCpoDt+") >= '" + Dtos(mv_par01) + "' .AND. DTOS("+cCpoDt+") <= '" + Dtos(mv_par02) +"' .AND. "
		cFiltro += "!(alltrim(D1_CF) $ '" + cMvProCFn + "')"
		IndRegua(cAliasSD1,cArqInd2,cChave,,cFiltro,STR0006) //"Selecionando Registros..."
		dbGotop()
		SetRegua(LastRec())
	#ENDIF
Endif

R917LayOut(@aLay)

If nTipoMov == 1 .Or. nTipoMov == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a Movimentacao de Saida - SEM INCENTIVO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAliasSD2)->(Eof())

		If !lQuery
			SF3->(dbSetOrder(1))
			If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_CF))
				(cAliasSD2)->(dbSkip())
				Loop
			Endif

			If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
				(cAliasSD2)->(dbSkip())
				Loop
			Endif

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			cDescri := SB1->B1_DESC

			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5") + (cAliasSD2)->D2_COD))
			cInc := SB5->&(cIncentivo)
		Else
			cDescri := (cAliasSD2)->B1_DESC
			cInc    := (cAliasSD2)->&(cIncentivo)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos sem incentivo = 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc <> "01"
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.

		nValCont	:= 0
		nBase		:= 0
		nICMS		:= 0
		nOutras		:= 0

		nValCont	+= (cAliasSD2)->D2_TOTAL
		nBase		+= (cAliasSD2)->D2_BASEICM
		nICMS		+= (cAliasSD2)->D2_VALICM
		nOutras		+= (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_BASEICM
		nTValCont	+= (cAliasSD2)->D2_TOTAL
		nTBase		+= (cAliasSD2)->D2_BASEICM
		nTICMS		+= (cAliasSD2)->D2_VALICM
		nTOutras	+= (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_BASEICM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o Cabecalho                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nLin > 54 .Or. nLin == 0)
			nLin := Mtr917Cabec(nPagina,1)
			nPagina += 1
		EndIf

		If !lQuery
			IncRegua()
		Endif

		If Interrupcao(@lEnd)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os Valores                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FmtLin({(cAliasSD2)->D2_EMISSAO,(cAliasSD2)->D2_DOC,Transform((cAliasSD2)->&(SerieNfId("SD2",3,"D2_SERIE")),"@e 99"),(cAliasSD2)->D2_CF,(cAliasSD2)->D2_COD,cDescri,nValCont,nBase,nICMS,nOutras},aLay[18],,,@nLin)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD2)->D2_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD2)->D2_COD
			PRO->PRO_DESCR	:= cDescri
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTS	:= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	:= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	:= (cAliasSD2)->D2_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTS	+= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	+= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	+= (cAliasSD2)->D2_VALICM
		Endif
		MsUnlock()
		(cAliasSD2)->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sem Movimento no Periodo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lHouveMov
		nLin := Mtr917Cabec(nPagina,1)
		nPagina += 1
		FmtLin(,aLay[20],,,@nLin)
		FmtLin(,aLay[21],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totalizacao dos Movimentos                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 54
		nLin := Mtr917Cabec(nPagina,1)
		nPagina += 1
	EndIf

	If nLin > 0 .And. lHouveMov
		FmtLin(,aLay[21],,,@nLin)
		FmtLin({nTValCont,nTBase,nTICMS,nTOutras},aLay[22],,,@nLin)
		FmtLin(,aLay[23],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a Movimentacao de Saida - COM INCENTIVO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cAliasSD2)->(dbGoTop())

	nTValCont	:= 0
	nTBase		:= 0
	nTICMS		:= 0
	nTOutras	:= 0
	nLin		:= 0
	lHouveMov	:= .F.

	While !(cAliasSD2)->(Eof())

		If !lQuery
			SF3->(dbSetOrder(1))
			If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_CF))
				(cAliasSD2)->(dbSkip())
				Loop
			Endif

			If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
				(cAliasSD2)->(dbSkip())
				Loop
			Endif

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			cDescri := SB1->B1_DESC

			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5") + (cAliasSD2)->D2_COD))
			cInc := SB5->&(cIncentivo)
		Else
			cDescri := (cAliasSD2)->B1_DESC
			cInc    := (cAliasSD2)->&(cIncentivo)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos com incentivo <> 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc == "01"
			(cAliasSD2)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.

		nValCont	:= 0
		nBase		:= 0
		nICMS		:= 0
		nOutras		:= 0

		nValCont	+= (cAliasSD2)->D2_TOTAL
		nBase		+= (cAliasSD2)->D2_BASEICM
		nICMS		+= (cAliasSD2)->D2_VALICM
		nOutras		+= (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_BASEICM
		nTValCont	+= (cAliasSD2)->D2_TOTAL
		nTBase		+= (cAliasSD2)->D2_BASEICM
		nTICMS		+= (cAliasSD2)->D2_VALICM
		nTOutras	+= (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_BASEICM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o Cabecalho                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nLin > 54 .Or. nLin == 0)
			nLin := Mtr917Cabec(nPagina,2)
			nPagina += 1
		EndIf

		If !lQuery
			IncRegua()
		Endif

		If Interrupcao(@lEnd)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os Valores                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FmtLin({(cAliasSD2)->D2_EMISSAO,(cAliasSD2)->D2_DOC,Transform((cAliasSD2)->&(SerieNfId("SD2",3,"D2_SERIE")),"@e 99"),(cAliasSD2)->D2_CF,(cAliasSD2)->D2_COD,cDescri,nValCont,nBase,nICMS,nOutras},aLay[18],,,@nLin)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD2)->D2_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD2)->D2_COD
			PRO->PRO_DESCR	:= cDescri
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTS	:= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	:= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	:= (cAliasSD2)->D2_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTS	+= (cAliasSD2)->D2_TOTAL
			PRO->PRO_BASES	+= (cAliasSD2)->D2_BASEICM
			PRO->PRO_ICMSS	+= (cAliasSD2)->D2_VALICM
		Endif
		MsUnlock()
		(cAliasSD2)->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sem Movimento no Periodo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lHouveMov
		nLin := Mtr917Cabec(nPagina,2)
		nPagina += 1
		FmtLin(,aLay[20],,,@nLin)
		FmtLin(,aLay[21],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totalizacao dos Movimentos                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 54
		nLin := Mtr917Cabec(nPagina,2)
		nPagina += 1
	EndIf

	If nLin > 0 .And. lHouveMov
		FmtLin(,aLay[21],,,@nLin)
		FmtLin({nTValCont,nTBase,nTICMS,nTOutras},aLay[22],,,@nLin)
		FmtLin(,aLay[23],,,@nLin)
	Endif
Endif

nTValCont	:= 0
nTBase		:= 0
nTICMS		:= 0
nTOutras	:= 0
nLin		:= 0
lHouveMov	:= .F.

If nTipoMov == 2 .Or. nTipoMov == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a Movimentacao de Entrada - SEM INCENTIVO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAliasSD1)->(Eof())

		If !lQuery
			SF3->(dbSetOrder(1))
			If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD1)->D1_EMISSAO)+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_CF))
				(cAliasSD1)->(dbSkip())
				Loop
			Endif

			If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
				(cAliasSD1)->(dbSkip())
				Loop
			Endif

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
			cDescri := SB1->B1_DESC

			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5") + (cAliasSD1)->D1_COD))
			cInc := SB5->&(cIncentivo)
		Else
			cDescri := (cAliasSD1)->B1_DESC
			cInc    := (cAliasSD1)->&(cIncentivo)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos sem incentivo = 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc <> "01"
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.

		nValCont	:= 0
		nBase		:= 0
		nICMS		:= 0
		nOutras		:= 0

		nValCont	+= (cAliasSD1)->D1_TOTAL
		nBase		+= (cAliasSD1)->D1_BASEICM
		nICMS		+= (cAliasSD1)->D1_VALICM
		nOutras		+= (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_BASEICM
		nTValCont	+= (cAliasSD1)->D1_TOTAL
		nTBase		+= (cAliasSD1)->D1_BASEICM
		nTICMS		+= (cAliasSD1)->D1_VALICM
		nTOutras	+= (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_BASEICM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o Cabecalho                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nLin > 54 .Or. nLin == 0)
			nLin := Mtr917Cabec(nPagina,3)
			nPagina += 1
		EndIf

		If !lQuery
			IncRegua()
		Endif

		If Interrupcao(@lEnd)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os Valores                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FmtLin({(cAliasSD1)->&cCpoDt,(cAliasSD1)->D1_DOC,Transform((cAliasSD1)->&(SerieNfId("SD1",3,"D1_SERIE")),"@e 99"),(cAliasSD1)->D1_CF,(cAliasSD1)->D1_COD,cDescri,nValCont,nBase,nICMS,nOutras},aLay[18],,,@nLin)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD1)->D1_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD1)->D1_COD
			PRO->PRO_DESCR	:= cDescri
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTE	:= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	:= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	:= (cAliasSD1)->D1_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTE	+= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	+= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	+= (cAliasSD1)->D1_VALICM
		Endif
		MsUnlock()
		(cAliasSD1)->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sem Movimento no Periodo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lHouveMov
		nLin := Mtr917Cabec(nPagina,3)
		nPagina += 1
		FmtLin(,aLay[20],,,@nLin)
		FmtLin(,aLay[21],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totalizacao dos Movimentos                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 54
		nLin := Mtr917Cabec(nPagina,3)
		nPagina += 1
	EndIf

	If nLin > 0 .And. lHouveMov
		FmtLin(,aLay[21],,,@nLin)
		FmtLin({nTValCont,nTBase,nTICMS,nTOutras},aLay[22],,,@nLin)
		FmtLin(,aLay[23],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a Movimentacao de Entrada - COM INCENTIVO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cAliasSD1)->(dbGoTop())
	nTValCont	:= 0
	nTBase		:= 0
	nTICMS		:= 0
	nTOutras	:= 0
	nLin		:= 0
	lHouveMov	:= .F.

	While !(cAliasSD1)->(Eof())

		If !lQuery
			SF3->(dbSetOrder(1))
			If ! SF3->(dbSeek(xFilial("SF3")+DtoS((cAliasSD1)->D1_EMISSAO)+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_CF))
				(cAliasSD1)->(dbSkip())
				Loop
			Endif

			If ! Empty (SF3->F3_DTCANC) .Or. "CANCELAD" $ SF3->F3_OBSERV
				(cAliasSD1)->(dbSkip())
				Loop
			Endif

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
			cDescri := SB1->B1_DESC

			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5") + (cAliasSD1)->D1_COD))
			cInc := SB5->&(cIncentivo)
		Else
			cDescri := (cAliasSD1)->B1_DESC
			cInc    := (cAliasSD1)->&(cIncentivo)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente produtos sem incentivo = 01³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInc) .Or. cInc == "01"
			(cAliasSD1)->(dbSkip())
			Loop
		Endif

		lHouveMov := .T.

		nValCont	:= 0
		nBase		:= 0
		nICMS		:= 0
		nOutras		:= 0

		nValCont	+= (cAliasSD1)->D1_TOTAL
		nBase		+= (cAliasSD1)->D1_BASEICM
		nICMS		+= (cAliasSD1)->D1_VALICM
		nOutras		+= (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_BASEICM
		nTValCont	+= (cAliasSD1)->D1_TOTAL
		nTBase		+= (cAliasSD1)->D1_BASEICM
		nTICMS		+= (cAliasSD1)->D1_VALICM
		nTOutras	+= (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_BASEICM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o Cabecalho                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nLin > 54 .Or. nLin == 0)
			nLin := Mtr917Cabec(nPagina,4)
			nPagina += 1
		EndIf

		If !lQuery
			IncRegua()
		Endif

		If Interrupcao(@lEnd)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os Valores                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FmtLin({(cAliasSD1)->&cCpoDt,(cAliasSD1)->D1_DOC,Transform((cAliasSD1)->&(SerieNfId("SD1",3,"D1_SERIE")),"@e 99"),(cAliasSD1)->D1_CF,(cAliasSD1)->D1_COD,cDescri,nValCont,nBase,nICMS,nOutras},aLay[18],,,@nLin)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valores por codigo de produto                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRO->(dbSetOrder(1))
		If ! PRO->(dbSeek((cAliasSD1)->D1_COD))
			RecLock("PRO",.T.)
			PRO->PRO_COD	:= (cAliasSD1)->D1_COD
			PRO->PRO_DESCR	:= cDescri
			PRO->PRO_INCENT	:= cInc
			PRO->PRO_CONTE	:= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	:= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	:= (cAliasSD1)->D1_VALICM
		Else
			RecLock("PRO",.F.)
			PRO->PRO_CONTE	+= (cAliasSD1)->D1_TOTAL
			PRO->PRO_BASEE	+= (cAliasSD1)->D1_BASEICM
			PRO->PRO_ICMSE	+= (cAliasSD1)->D1_VALICM
		Endif
		MsUnlock()
		(cAliasSD1)->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sem Movimento no Periodo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lHouveMov
		nLin := Mtr917Cabec(nPagina,4)
		nPagina += 1
		FmtLin(,aLay[20],,,@nLin)
		FmtLin(,aLay[21],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totalizacao dos Movimentos                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 54
		nLin := Mtr917Cabec(nPagina,4)
		nPagina += 1
	EndIf

	If nLin > 0 .And. lHouveMov
		FmtLin(,aLay[21],,,@nLin)
		FmtLin({nTValCont,nTBase,nTICMS,nTOutras},aLay[22],,,@nLin)
		FmtLin(,aLay[23],,,@nLin)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Imprime o resumo por produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If mv_par04 == 1

	// Produtos sem incentivo
	nValContE	:= 0
	nBaseE		:= 0
	nICMSE		:= 0
	nValContS	:= 0
	nBaseS		:= 0
	nICMSS		:= 0
	nLin		:= 0
	PRO->(dbSetOrder(1))
	PRO->(dbGoTop())
	While ! PRO->(Eof())
		If PRO->PRO_INCENT == "01"
			If (nLin > 54 .Or. nLin == 0)
				nLin := Mtr917Cabec(nPagina,5)
				nPagina += 1
			EndIf
			nValContE	+= PRO->PRO_CONTE
			nBaseE		+= PRO->PRO_BASEE
			nICMSE		+= PRO->PRO_ICMSE
			nValContS	+= PRO->PRO_CONTS
			nBaseS		+= PRO->PRO_BASES
			nICMSS		+= PRO->PRO_ICMSS
			FmtLin({PRO->PRO_COD,PRO->PRO_DESCR,PRO->PRO_CONTE,PRO->PRO_BASEE,PRO->PRO_ICMSE,PRO->PRO_CONTS,PRO->PRO_BASES,PRO->PRO_ICMSS},aLay[32],,,@nLin)
		Endif
		PRO->(dbSkip())
	Enddo

	If nLin > 0
		If nLin > 54
			nLin := Mtr917Cabec(nPagina,5)
			nPagina += 1
		EndIf
		FmtLin({},aLay[33],,,@nLin)
		FmtLin({nValContE,nBaseE,nICMSE,nValContS,nBaseS,nICMSS},aLay[34],,,@nLin)
		FmtLin({},aLay[35],,,@nLin)
	Endif

	// Produtos com incentivo
	nValContE	:= 0
	nBaseE		:= 0
	nICMSE		:= 0
	nValContS	:= 0
	nBaseS		:= 0
	nICMSS		:= 0
	nLin		:= 0
	PRO->(dbSetOrder(1))
	PRO->(dbGoTop())
	While ! PRO->(Eof())
		If PRO->PRO_INCENT <> "01"
			If (nLin > 54 .Or. nLin == 0)
				nLin := Mtr917Cabec(nPagina,6)
				nPagina += 1
			EndIf
			nValContE	+= PRO->PRO_CONTE
			nBaseE		+= PRO->PRO_BASEE
			nICMSE		+= PRO->PRO_ICMSE
			nValContS	+= PRO->PRO_CONTS
			nBaseS		+= PRO->PRO_BASES
			nICMSS		+= PRO->PRO_ICMSS
			FmtLin({PRO->PRO_COD,PRO->PRO_DESCR,PRO->PRO_CONTE,PRO->PRO_BASEE,PRO->PRO_ICMSE,PRO->PRO_CONTS,PRO->PRO_BASES,PRO->PRO_ICMSS},aLay[32],,,@nLin)
		Endif
		PRO->(dbSkip())
	Enddo

	If nLin > 0
		If nLin > 54
			nLin := Mtr917Cabec(nPagina,6)
			nPagina += 1
		EndIf
		FmtLin({},aLay[33],,,@nLin)
		FmtLin({nValContE,nBaseE,nICMSE,nValContS,nBaseS,nICMSS},aLay[34],,,@nLin)
		FmtLin({},aLay[35],,,@nLin)
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui as areas de trabalho                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipoMov == 1 .Or. nTipoMov == 3
	#IFDEF TOP
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	#ELSE
		Ferase(cArqInd+OrdBagExt())
		RetIndex("SD2")
	#ENDIF
Endif
If nTipoMov == 2 .Or. nTipoMov == 3
	#IFDEF TOP
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	#ELSE
		Ferase(cArqInd2+OrdBagExt())
		RetIndex("SD1")
	#ENDIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Excluindo a tabela temporaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(aTemp[1,2])
dbCloseArea()
Ferase(aTemp[1,1]+GetDBExtension())
Ferase(aTemp[1,1]+OrdBagExt())

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |R917LayOutºAutor  ³Mary C. Hergert     º Data ³ 27/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Layout de Impressao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR917                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R917LayOut(aLay)

	aLay[01] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0019 //"|                                                                       RESUMO DE MOVIMENTOS DE PRODUTOS INCENTIVADOS / NAO INCENTIVADOS - PRODEPE                                                        PAGINA: ######   |"
	aLay[03] :=           "|                                                                                                                                                                                                                          |"
	aLay[04] := STR0020 //"|  EMPRESA:    ########################################                         C.N.P.J.:   ##################                                    I.E.:     #####################                                          |"
	aLay[05] := STR0021 //"|  ENDERECO:   ######################################                           CIDADE:     #############################                         ESTADO:   ##                                                             |"
	aLay[06] :=           "|                                                                                                                                                                                                                          |"
	aLay[07] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[08] := STR0010 //"|                                                                                    MOVIMENTOS DE SAIDA COM PRODUTOS NAO INCENTIVADOS                                                                                     |"
	aLay[09] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[10] := STR0011 //"|                                                                                      MOVIMENTOS DE SAIDA COM PRODUTOS INCENTIVADOS                                                                                       |"
	aLay[11] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[12] := STR0012 //"|                                                                                   MOVIMENTOS DE ENTRADA COM PRODUTOS NAO INCENTIVADOS                                                                                    |"
	aLay[13] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[14] := STR0013 //"|                                                                                     MOVIMENTOS DE ENTRADA COM PRODUTOS INCENTIVADOS                                                                                      |"
	aLay[15] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[16] := STR0007 //"|     EMISSAO     |    NUMERO    |    SERIE    |     CFOP     |         CODIGO         |                    DESCRICAO                     |      VALOR CONTABIL      |     BASE DE CALCULO      |        VALOR ICMS        |"
	aLay[17] :=           "|-----------------+--------------+-------------+--------------+------------------------+--------------------------------------------------+--------------------------+--------------------------+--------------------------|"
	aLay[18] :=           "|     ########    |    ######    |     ###     |     ####     |    ###############     |     ########################################     |     ################     |     ################     |     ################     |"
	aLay[19] :=           "|-----------------+--------------+-------------+--------------+---------------------------------------------------------------------------+--------------------------+--------------------------+--------------------------+"
	aLay[20] := STR0008 //"|                                                      *** NAO HOUVE MOVIMENTO ***                                                        |                          |                          |                          |"
	aLay[21] :=           "|-----------------------------------------------------------------------------------------------------------------------------------------+--------------------------+--------------------------+--------------------------+"
	aLay[22] := STR0009 //"|                                                              TOTALIZACAO                                                                |     ################     |     ################     |     ################     |"
	aLay[23] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[24] := STR0014 //"|                                                                                              RESUMO POR PRODUTO INCENTIVADO                                                                                              |"
	aLay[25] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[26] := STR0015 //"|                                                                                            RESUMO POR PRODUTO NAO INCENTIVADO                                                                                            |"
	aLay[27] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[28] := STR0016 //"|                             PRODUTO                              |                          MOVIMENTOS DE ENTRADA                           |                            MOVIMENTOS DE SAIDA                             |"
	aLay[29] :=           "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[30] := STR0017 //"|        CODIGO       |                 DESCRICAO                  |     VALOR CONTABIL     |    BASE DE CALCULO     |      VALOR DO ICMS     |     VALOR CONTABIL     |    BASE DE CALCULO     |      VALOR DO ICMS       |"
	aLay[31] :=           "|---------------------+--------------------------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+--------------------------+"
	aLay[32] :=           "|   ###############   |  ########################################  |    ################    |    ################    |    ################    |    ################    |    ################    |     ################     |"
	aLay[33] :=           "|---------------------+--------------------------------------------+------------------------+------------------------+------------------------+------------------------+------------------------+--------------------------+"
	aLay[34] := STR0018 //"|                           TOTALIZACAO                            |    ################    |    ################    |    ################    |    ################    |    ################    |     ################     |"
	aLay[35] :=           "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[36] := STR0028 //"|   DT.ENTRADA    |    NUMERO    |    SERIE    |     CFOP     |         CODIGO         |                    DESCRICAO                     |      VALOR CONTABIL      |     BASE DE CALCULO      |        VALOR ICMS        |"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr917StruºAutor  ³Mary C. Hergert     º Data ³ 01/10/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria a estrutura do arquivo temporario para a impressao do  º±±
±±º          ³relatorio.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Matr917                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mtr917Stru()

Local aStru   := {}
Local aTemp   := {}
Local cArqPRO := ""

AADD(aStru,{"PRO_COD"		,"C",015,0})
AADD(aStru,{"PRO_DESCR"		,"C",030,0})
AADD(aStru,{"PRO_INCENT"	,"C",002,0})
AADD(aStru,{"PRO_CONTS"		,"N",013,2})
AADD(aStru,{"PRO_BASES"		,"N",013,2})
AADD(aStru,{"PRO_ICMSS"		,"N",013,2})
AADD(aStru,{"PRO_CONTE"		,"N",013,2})
AADD(aStru,{"PRO_BASEE"		,"N",013,2})
AADD(aStru,{"PRO_ICMSE"		,"N",013,2})

cArqPRO	:=	CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArqPRO,"PRO")
IndRegua("PRO",cArqPRO,"PRO_COD")

AADD(aTemp,{cArqPRO,"PRO"})

Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr917CabecºAutor  ³Mary C. Hergert     º Data ³ 01/10/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho do relatorio                                       º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Matr917                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mtr917Cabec(nPagina,nTipo)

Local nLinha := 0
Local aLay   := Array(40)

R917LayOut(@aLay)

@ nLinha,000 PSAY AvalImp(Limite)

FmtLin({},aLay[01],,,@nLinha)
FmtLin({StrZero(nPagina,6)},aLay[02],,,@nLinha)
FmtLin({},aLay[03],,,@nLinha)
FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC},aLay[04],,,@nLinha)
FmtLin({SM0->M0_ENDENT,SM0->M0_CIDENT,SM0->M0_ESTENT},aLay[05],,,@nLinha)
FmtLin({},aLay[06],,,@nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nTipo == 1 Cabecalho de Nao Incentivados Saida    ³
//³nTipo == 2 Cabecalho de Incentivados Saida        ³
//³nTipo == 3 Cabecalho de Nao Incentivados Entrada  ³
//³nTipo == 4 Cabecalho de Incentivados Entrada      ³
//³nTipo == 5 Cabecalho de Resumo de Nao Incentivados³
//³nTipo == 6 Cabecalho de Resumo de Incentivados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nTipo == 1
		FmtLin({},aLay[07],,,@nLinha)
		FmtLin({},aLay[08],,,@nLinha)
		FmtLin({},aLay[09],,,@nLinha)
		FmtLin({},aLay[16],,,@nLinha)
		FmtLin({},aLay[17],,,@nLinha)
	Case nTipo == 2
		FmtLin({},aLay[09],,,@nLinha)
		FmtLin({},aLay[10],,,@nLinha)
		FmtLin({},aLay[11],,,@nLinha)
		FmtLin({},aLay[16],,,@nLinha)
		FmtLin({},aLay[17],,,@nLinha)
	Case nTipo == 3
		FmtLin({},aLay[11],,,@nLinha)
		FmtLin({},aLay[12],,,@nLinha)
		FmtLin({},aLay[13],,,@nLinha)
		FmtLin({},aLay[36],,,@nLinha)
		FmtLin({},aLay[17],,,@nLinha)
	Case nTipo == 4
		FmtLin({},aLay[13],,,@nLinha)
		FmtLin({},aLay[14],,,@nLinha)
		FmtLin({},aLay[15],,,@nLinha)
		FmtLin({},aLay[36],,,@nLinha)
		FmtLin({},aLay[17],,,@nLinha)
	Case nTipo == 5
		FmtLin({},aLay[23],,,@nLinha)
		FmtLin({},aLay[26],,,@nLinha)
		FmtLin({},aLay[27],,,@nLinha)
		FmtLin({},aLay[28],,,@nLinha)
		FmtLin({},aLay[29],,,@nLinha)
		FmtLin({},aLay[30],,,@nLinha)
		FmtLin({},aLay[31],,,@nLinha)
	Case nTipo == 6
		FmtLin({},aLay[23],,,@nLinha)
		FmtLin({},aLay[24],,,@nLinha)
		FmtLin({},aLay[25],,,@nLinha)
		FmtLin({},aLay[28],,,@nLinha)
		FmtLin({},aLay[29],,,@nLinha)
		FmtLin({},aLay[30],,,@nLinha)
		FmtLin({},aLay[31],,,@nLinha)
EndCase

Return(nLinha)
