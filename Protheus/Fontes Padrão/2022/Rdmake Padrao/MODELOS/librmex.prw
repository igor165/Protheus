#INCLUDE "PROTHEUS.CH"
#INCLUDE "LIBRMEX.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LIBRMEX   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 26.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Livro de Apuracao de IVA                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Mexico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LibrMex()

Local oReport
Local cPerg		:= "LIBMEX"

Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³10.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oSecao1
Local oSecao2
Local oSecao3
Local oSecao4
Local oTotaliz
Local oTotal
Local cReport	:= "LIBRMEX"
Local cPerg		:= "LIBMEX"
Local cTitulo	:= OemToAnsi(STR0001)	//"Livro de Apuração IVA"
Local cDesc		:= OemToAnsi(STR0002)	//"Este programa tem como objetivo imprimir os Livros Fiscais de IVA Compras e Vendas."

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
oReport := TReport():New(cReport,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cDesc)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecao1:=TRSection():New(oReport,OemToAnsi(STR0025),{"SM0"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oSecao1,"M0_NOMECOM","SM0",OemToAnsi(STR0003),/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"M0_CGC","SM0",OemToAnsi(STR0004),/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)

oSecao2:=TRSection():New(oReport,OemToAnsi(STR0026),{"SF3","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao2:SetTotalInLine(.F.)
oSecao2:SetTotalText(Upper(OemToAnsi(STR0024)))
TRCell():New(oSecao2,"F3_NFISCAL","SF3",/*Titulo*/,/*Picture*/,TamSx3("F3_NFISCAL")[1]+ 2,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"ESPECIE","","","@!",2,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"F3_ENTRADA","SF3",OemToAnsi(STR0005),/*Picture*/,TamSx3("F3_ENTRADA")[1]+ 1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"A1_NOME","SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"A1_CGC","SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"TOTAL","",OemToAnsi(STR0006),PesqPict("SF3","F3_VALCONT"),TamSx3("F3_VALCONT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"GRAVADA","",OemToAnsi(STR0007),PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"ISENTA","",OemToAnsi(STR0008),PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"IVA","",OemToAnsi(STR0009),PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao2,"RETENC","",OemToAnsi(STR0010),PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oSecao2:Cell("TOTAL"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao2:Cell("GRAVADA"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao2:Cell("ISENTA"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao2:Cell("IVA"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao2:Cell("RETENC"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)

oSecao2:Cell("TOTAL"):SetHeaderAlign("RIGHT")
oSecao2:Cell("GRAVADA"):SetHeaderAlign("RIGHT")
oSecao2:Cell("ISENTA"):SetHeaderAlign("RIGHT")
oSecao2:Cell("IVA"):SetHeaderAlign("RIGHT")
oSecao2:Cell("RETENC"):SetHeaderAlign("RIGHT")

oSecao3:=TRSection():New(oReport,OemToAnsi(STR0016),/*{Tabelas da secao}*/,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao3:SetPageBreak()
oSecao3:SetTotalInLine(.F.)
oSecao3:SetTotalText(Upper(OemToAnsi(STR0024)))
TRCell():New(oSecao3,"IMPOSTO","",OemToAnsi(STR0016),PesqPict("SFB","FB_DESCR"),TamSx3("FB_DESCR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao3,"VALOR","",OemToAnsi(STR0020),PesqPict("SF3","F3_BASIMP1"),TamSx3("F3_BASIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oSecao3:Cell("VALOR"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)

oSecao4:=TRSection():New(oReport,OemToAnsi(STR0024),/*{Tabelas da secao}*/,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao4:SetTotalInLine(.F.)
oSecao4:SetTotalText(Upper(OemToAnsi(STR0024)))
TRCell():New(oSecao4,"IMPOSTO","",OemToAnsi(STR0016),PesqPict("SFB","FB_DESCR"),TamSx3("FB_DESCR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao4,"VENDA","",OemToAnsi(STR0017),PesqPict("SF3","F3_BASIMP1"),TamSx3("F3_BASIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao4,"COMPRA","",OemToAnsi(STR0018),PesqPict("SF3","F3_BASIMP1"),TamSx3("F3_BASIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oSecao4:Cell("VENDA"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao4:Cell("COMPRA"),NIL,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)

oSecao4:Cell("VENDA"):SetHeaderAlign("RIGHT")
oSecao4:Cell("COMPRA"):SetHeaderAlign("RIGHT")
//-- Totalizador
oTotaliz := TRFunction():New(oSecao4:Cell("VENDA"),"VENDA_T","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz := TRFunction():New(oSecao4:Cell("COMPRA"),"COMPRA_T","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

//-- Secao Totalizadora
oTotal := TRSection():New(oReport,Alltrim(OemToAnsi(STR0028)),{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) 
oTotal:SetHeaderSection()
TRCell():New(oTotal,"TEXTO1","","",/*cPicture*/,27,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTotal,"SALDO","","","@E 999,999,999,999.99",18,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTotal,"TEXTO2","","",/*cPicture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Sergio S. Fuzinaka     ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                            ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local cCondicao	:= ""
Local cAliasSF3	:= "SF3"
Local cCabec	:= ""
Local cNomeCom	:= ""
Local cCGC		:= ""
Local cNFiscal	:= ""
Local cEspecie	:= ""
Local dEntrada	:= Ctod("")
Local cNome		:= ""
Local nTotal	:= 0
Local nGravada	:= 0
Local nIsenta	:= 0
Local nIVA		:= 0
Local nRetenc	:= 0
Local nLastRec	:= 0
Local cImposto	:= ""
Local nVenda	:= 0
Local nCompra	:= 0
Local nG		:= 0
Local nGG		:= 0
Local aTES		:= {}
Local aImpSaida	:= {}
Local aImpEntr	:= {}
Local nPos		:= 0
Local aResumo	:= {}
Local nPrinc	:= 0
Local nSecun	:= 0
Local cImp2		:= ""
Local nValor	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Empresa                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):Cell("M0_NOMECOM"):SetBlock({|| cNomeCom})
oReport:Section(1):Cell("M0_CGC"):SetBlock({|| cCGC})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(2):Cell("F3_NFISCAL"):SetBlock({|| cNFiscal})
oReport:Section(2):Cell("ESPECIE"):SetBlock({|| cEspecie})
oReport:Section(2):Cell("F3_ENTRADA"):SetBlock({|| dEntrada})
oReport:Section(2):Cell("A1_NOME"):SetBlock({|| cNome})
oReport:Section(2):Cell("A1_CGC"):SetBlock({|| cCGC})
oReport:Section(2):Cell("TOTAL"):SetBlock({|| nTotal})
oReport:Section(2):Cell("GRAVADA"):SetBlock({|| nGravada})
oReport:Section(2):Cell("ISENTA"):SetBlock({|| nIsenta})
oReport:Section(2):Cell("IVA"):SetBlock({|| nIVA})
oReport:Section(2):Cell("RETENC"):SetBlock({|| nRetenc})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 3                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(3):Cell("IMPOSTO"):SetBlock({|| cImp2})
oReport:Section(3):Cell("VALOR"):SetBlock({|| nValor})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 4 - Resumo                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(4):Cell("IMPOSTO"):SetBlock({|| cImposto})
oReport:Section(4):Cell("VENDA"):SetBlock({|| nVenda})
oReport:Section(4):Cell("COMPRA"):SetBlock({|| nCompra})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o titulo para impressao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par03 == 1	//Vendas
		cCabec := OemToAnsi(STR0011)+OemToAnsi(STR0014)+DtoC(mv_par01)+OemToAnsi(STR0015)+DtoC(mv_par02)
	Case mv_par03 == 2	//Compras
		cCabec := OemToAnsi(STR0012)+OemToAnsi(STR0014)+DtoC(mv_par01)+OemToAnsi(STR0015)+DtoC(mv_par02)	
	Otherwise
		cCabec := OemToAnsi(STR0013)+OemToAnsi(STR0014)+DtoC(mv_par01)+OemToAnsi(STR0015)+DtoC(mv_par02)		
EndCase

oReport:SetTitle(cCabec)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento das Tabelas                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(dbsetorder(1))
SA2->(dbsetorder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	cCondicao	:= "%"
	If mv_par03 == 1
		cCondicao += "F3_TIPOMOV = 'V' "
	ElseIf mv_par03 == 2		
		cCondicao += "F3_TIPOMOV = 'C' "	
	Else
		cCondicao += "F3_TIPOMOV <> ' ' "	
	Endif
	If mv_par04 == 2	//Nao considera canceladas
		cCondicao += "AND F3_DTCANC = ' '"
	Endif	
	cCondicao	+= "%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(2):BeginQuery()	
	
	cAliasSF3 := GetNextAlias()

	BeginSql Alias cAliasSF3
		SELECT SF3.*
		FROM %table:SF3% SF3
		WHERE F3_FILIAL = %xFilial:SF3%		AND 
			F3_ENTRADA	>=	%Exp:mv_par01%	AND 
			F3_ENTRADA	<=	%Exp:mv_par02%	AND 
			%Exp:cCondicao%					AND
			SF3.%NotDel% 
		ORDER BY %Order:SF3%
	EndSql 

	oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)
		
#ELSE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr(oReport:uParam)

	cCondicao := "F3_FILIAL == '"+xFilial("SF3")+"' .And. "
	
	If mv_par03 == 1
		cCondicao += "F3_TIPOMOV == 'V' .And. "
	ElseIf mv_par03 == 2		
		cCondicao += "F3_TIPOMOV == 'C' .And. "	
	Endif
	If mv_par04 == 2	//Nao considera canceladas
		cCondicao += "Empty(F3_DTCANC) .And. "
	Endif	
	
	cCondicao += "Dtos(F3_ENTRADA) >= '"+Dtos(mv_par01)+"' .And. "
	cCondicao += "Dtos(F3_ENTRADA) <= '"+Dtos(mv_par02)+"'"

	oReport:Section(2):SetFilter(cCondicao,IndexKey())
	
#ENDIF		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeCom	:= SM0->M0_NOMECOM
cCGC		:= SM0->M0_CGC
oReport:SetMeter(1)
oReport:Section(1):Init()
oReport:Section(1):PrintLine() 	
oReport:Section(1):Finish()	

dbSelectArea((cAliasSF3))
dbGoTop()
nLastRec := (cAliasSF3)->(LastRec())
oReport:SetMeter(nLastRec)

If mv_par03 < 3
	oReport:Section(2):Init()
Endif

While !Eof()
	
	oReport:IncMeter()
	
	cNF		:= (cAliasSF3)->F3_NFISCAL
	cCLie	:= (cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
	dEnt	:= (cAliasSF3)->F3_ENTRADA
	nTot	:= (nBas:=(nRet:=(nImp:=(nIse:=0))))
	cEsp	:= Left(Upper(Trim((cAliasSF3)->F3_ESPECIE)),2)
	         
            
	If (lCancelada:=(!Empty((cAliasSF3)->F3_DTCANC)))
		dbSkip()
	Else   
		While (cAliasSF3)->F3_ENTRADA==dEnt .And. ((cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)==cCLie .And. (cAliasSF3)->F3_NFISCAL==cNF
            nTot += (cAliasSF3)->F3_VALCONT
                      
            If (cAliasSF3)->F3_BASIMP1 == 0
            	nIse += (cAliasSF3)->F3_VALCONT
         	Else
            	nBas += (cAliasSF3)->F3_BASIMP1
             	nImp += (cAliasSF3)->F3_VALIMP1
        		nRet += (cAliasSF3)->F3_VALIMP2
         	Endif                       
            
            PosImpIVA(@aTES, (cAliasSF3)->F3_TES)  // Posiciona o SFB respectivo 
            
         	If (cAliasSF3)->F3_TIPOMOV == "C"
            	If (nPos:=Ascan(aImpEntr,{|x| x[1]==SFB->FB_CODIGO})) > 0
                	If (nPosAliq:=Ascan(aImpEntr[nPos,2],{|x| (x[2]==(cAliasSF3)->F3_ALQIMP1)})) == 0
                    	AADD(aImpEntr[nPos,2],{(cAliasSF3)->F3_BASIMP1,(cAliasSF3)->F3_ALQIMP1,(cAliasSF3)->F3_VALIMP1,(cAliasSF3)->F3_VALIMP2})     
                   	Else
             			If cEsp == "NC"  
                        	aImpEntr[nPos,2,nPosAliq,1] -= (cAliasSF3)->F3_BASIMP1
                        	aImpEntr[nPos,2,nPosAliq,3] -= (cAliasSF3)->F3_VALIMP1
                      		aImpEntr[nPos,2,nPosAliq,4] -= (cAliasSF3)->F3_VALIMP2
                     	Else
                        	aImpEntr[nPos,2,nPosAliq,1] += (cAliasSF3)->F3_BASIMP1
                        	aImpEntr[nPos,2,nPosAliq,3] += (cAliasSF3)->F3_VALIMP1
                       		aImpEntr[nPos,2,nPosAliq,4] += (cAliasSF3)->F3_VALIMP2
                     	Endif    
                 	Endif 
            	Else
                 	AADD(aImpEntr,{SFB->FB_CODIGO,{{(cAliasSF3)->F3_BASIMP1,(cAliasSF3)->F3_ALQIMP1,(cAliasSF3)->F3_VALIMP1,(cAliasSF3)->F3_VALIMP2}}}) 
    			Endif
   			Else
            	If (nPos:=Ascan(aImpSaida,{|x| x[1]==SFB->FB_CODIGO})) > 0
                	If (nPosAliq:=Ascan(aImpSaida[nPos,2],{|x| (x[2]==(cAliasSF3)->F3_ALQIMP1)})) == 0
                    	AADD(aImpSaida[nPos,2],{(cAliasSF3)->F3_BASIMP1,(cAliasSF3)->F3_ALQIMP1,(cAliasSF3)->F3_VALIMP1,(cAliasSF3)->F3_VALIMP2})
                  	Else
                    	If cEsp == "NC"  
                     		aImpSaida[nPos,2,nPosAliq,1] -= (cAliasSF3)->F3_BASIMP1
                      		aImpSaida[nPos,2,nPosAliq,3] -= (cAliasSF3)->F3_VALIMP1
                     		aImpSaida[nPos,2,nPosAliq,4] -= (cAliasSF3)->F3_VALIMP2
                  		Else
                        	aImpSaida[nPos,2,nPosAliq,1] += (cAliasSF3)->F3_BASIMP1
                         	aImpSaida[nPos,2,nPosAliq,3] += (cAliasSF3)->F3_VALIMP1
                       		aImpSaida[nPos,2,nPosAliq,4] += (cAliasSF3)->F3_VALIMP2
                    	Endif    
                	Endif 
             	Else
                	If cEsp == "NC"
                   		AADD(aImpSaida,{SFB->FB_CODIGO,{{-(cAliasSF3)->F3_BASIMP1,-(cAliasSF3)->F3_ALQIMP1,-(cAliasSF3)->F3_VALIMP1,-(cAliasSF3)->F3_VALIMP2}}})     
                	Else   
                    	AADD(aImpSaida,{SFB->FB_CODIGO,{{(cAliasSF3)->F3_BASIMP1,(cAliasSF3)->F3_ALQIMP1,(cAliasSF3)->F3_VALIMP1,(cAliasSF3)->F3_VALIMP2}}})     
                 	Endif    
            	Endif           
      		Endif   
            dbSkip()
		Enddo    
	Endif
            
	If mv_par03 < 3
       	If mv_par03 == 1
           	SA1->(dbSeek(xFilial("SA1")+cCLie))
       	Else   
           	SA2->(dbSeek(xFilial("SA2")+cCLie))
       	Endif
                  
   		cNFiscal	:= cNF
       	cEspecie	:= IIf(cEsp=="NC","CR",IIf(cEsp=="ND","DB","FA"))
      	dEntrada	:= dEnt
      	cNome		:= IIf(mv_par03==1,SA1->A1_NOME,SA2->A2_NOME)    

		If lCancelada
			nTotal		:= nTot
	   		nGravada	:= nBas
			nIsenta		:= nIse
	   		nIVA		:= nImp
	   		nRetenc		:= nRet		
			cCGC 		:= "CANCELADA"
		Else
			cCGC := IIf(mv_par03==1,SA1->A1_CGC,SA2->A2_CGC)
           	If cEsp == "NC"
          		nTotal		:= (nTot *-1)
   				nGravada	:= (nBas *-1)
				nIsenta		:= (nIse *-1)
   				nIVA		:= (nImp *-1)
   				nRetenc		:= (nRet *-1)
   			Else
          		nTotal		:= nTot
   				nGravada	:= nBas
				nIsenta		:= nIse
   				nIVA		:= nImp
   				nRetenc		:= nRet   			
           	Endif   
       	Endif
		oReport:Section(2):PrintLine() 	
   	Endif        
Enddo 
If mv_par03 < 3
	oReport:Section(2):Finish()	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Resumo                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 3

	oReport:Section(4):Init()

    For nG:=1 To Len(aImpSaida)
    	aadd(aResumo,{aImpSaida[nG][1],{}})
        For nGG:=1 to len(aImpSaida[nG][2])
        	aadd(aResumo[len(aResumo)][2],{aImpSaida[nG][2][nGG][2],aImpSaida[nG][2][nGG][1],aImpSaida[nG][2][nGG][3],0,0})
        next    
	next
    for nG:=1 to len(aImpEntr)
    	if (nPos:=ascan(aResumo,{|x| x[1]==aImpEntr[nG][1]}))==0
        	aadd(aResumo,{aImpEntr[nG][1],{}})
            nPos:=len(aResumo)
        endif
        for nGG:=1 to len(aImpEntr[nG][2])
        	if (nPosAliq:=ascan(aResumo[nPos,2],{|x| (x[1]==aImpEntr[nG][2][nGG][2])}))==0
            	aadd(aResumo[nPos][2],{aImpEntr[nG][2][nGG][2],0,0,aImpEntr[nG][2][nGG][1],aImpEntr[nG][2][nGG][3]})
            else
            	aResumo[nPos][2][nPosAliq][4]+=aImpEntr[nG][2][nGG][1]
            	aResumo[nPos][2][nPosAliq][5]+=aImpEntr[nG][2][nGG][3]
          	endif    
       	next    
 	next
    for nG:=1 to len(aResumo)
    	SFB->(dbseek(xfilial("SFB")+aResumo[nG][1]))
    	
    	oReport:SetTitle(OemToAnsi(STR0019))
    	
        for nGG:=1 to len(aResumo[nG][2])
        	if (aResumo[nG][2][nGG][2]+aResumo[nG][2][nGG][4])<>0 
        		cImposto	:= Trim(SFB->FB_DESCR)+" ("+str(aResumo[nG][2][nGG][1],6,2)+"% )"
				nVenda		:= aResumo[nG][2][nGG][3]
              	nCompra		:= aResumo[nG][2][nGG][5]

				oReport:Section(4):PrintLine()
           	endif    
    	next
	next   
	oReport:Section(4):Finish()	 	
	
	//-- Impressao dos totalizadores
	oReport:SkipLine()	
	oReport:Section(5):Init()
	oReport:Section(5):Cell("TEXTO1"):SetValue(OemToAnsi(STR0021))
	oReport:Section(5):Cell("SALDO"):SetValue(oReport:Section(4):GetFunction("COMPRA_T"):ReportValue()-oReport:Section(4):GetFunction("VENDA_T"):ReportValue())
	oReport:Section(5):Cell("TEXTO2"):SetValue(OemToAnsi(STR0022))
	oReport:Section(5):PrintLine()
	oReport:Section(5):Finish()	 		
	
Else

	oReport:Section(3):Init()
	
	If mv_par03 == 1	//Vendas
	   	oReport:SetTitle(OemToAnsi(STR0011)+OemToAnsi(STR0023))	
	Else
	   	oReport:SetTitle(OemToAnsi(STR0012)+OemToAnsi(STR0023))	
	Endif
	
	nPrinc:=if(mv_par03==1,len(aImpSaida),len(aImpEntr))
    for nG:=1 to nPrinc
    	SFB->(dbseek(xfilial("SFB")+if(mv_par03==1,aImpSaida[nG][1],aImpEntr[nG][1])))
        nSecun:=len(if(mv_par03==1,aImpSaida[nG][2],aImpEntr[nG][2]))
        for nGG:=1 to nSecun
           	if mv_par03==1
           		if aImpSaida[nG][2][nGG][1]<>0
              		cImp2	:= Trim(SFB->FB_DESCR)+" ("+str(aImpSaida[nG][2][nGG][2],6,2)+"% )"
                	nValor	:= aImpSaida[nG][2][nGG][3]
                endif   
          	elseif mv_par03==2   
            	if aImpEntr[nG][2][nGG][1]<>0
                	cImp2	:= Trim(SFB->FB_DESCR)+" ("+str(aImpEntr[nG][2][nGG][2],6,2)+"% )"
                 	nValor	:= aImpEntr[nG][2][nGG][3]
              	endif   
         	endif       
			oReport:Section(3):PrintLine()         	
   		next
	next   
	oReport:Section(3):Finish()	

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PosImpIVA ºAutor  ³Microsiga           º Data ³  07/24/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Posiciona no registro do SFB respectivo ao imposto1 - IVA  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PosImpIVA(aTES, cTES)
Local nPosTES := 0
nPosTES := aScan( aTES, {|x| x[1]==cTES} )
If nPosTES = 0
	SFC->(dbSeek(xFilial("SFC")+cTES))
	While !(SFC->(Eof())) .And. SFC->FC_TES==cTES
		SFB->(dbSeek(xfilial("SFB")+SFC->FC_IMPOSTO))
	 	If SFB->FB_CPOLVRO=="1"
			SFC->(dbGoBottom())
		EndIf
		SFC->(dbSkip())
	EndDo    
	Aadd( aTES, {cTES, SFB->(Recno()) } )
Else
	SFB->(dbGoTo(aTES[nPosTES][2]))
EndIf	
Return
