#INCLUDE "MATRBOLA.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATRBOLA ³ Autor ³ Ricardo Berti         ³ Data ³ 09/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ANEXO 10: Resumo Mensal de Entradas e Saidas (BOLIVIA)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATRBOLA()
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
±±³Programa  ³ReportDef ³ Autor ³Microsiga              ³ Data ³23.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local cTamQt  := TamSX3('D1_QUANT')[1]
Local cPictQt := X3Picture('D1_QUANT')
Local oReport , oSection1, oEmpresa, oSection2

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
oReport:= TReport():New("MATRBOLA",STR0001,"MTRBOA", {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003) //"ANEXO 10"##"Movimento fisico de inventarios por produtos gravados com ICE e IEHD"##"Este relatório imprime um resumo mensal de entradas e saídas."
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
oReport:HideHeader()
oReport:HideFooter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Data Inicial                                 ³
//³ mv_par02     // Data Final                                   ³
//³ mv_par03     // Produto inicial                              ³
//³ mv_par04     // Produto Final                                ³
//³ mv_par05     // Pagina inicial				                 ³
//³ mv_par06     // Unidade de Medida:Primaria ou Secund.		 ³
//³ mv_par07     // M.I. p/ Mermas                               ³
//³ mv_par08     // Almoxarifado De                              ³
//³ mv_par09     // Almoxarifado Ate                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTRBOA",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1  - Dados do Produto				                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0010,{"SB1"}) //"Descricao do Produto"
oSection1:SetNoFilter("SB1")
oSection1:SetReadOnly()
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderSection(.T.)	// Desabilita Impressao Cabec.no Topo da Pagina, .T.= imprime cab.na quebra da secao
//oSection2:SetHeaderBreak(.T.)  // imprime cabec.apos uma quebra (TRBreak), .T.= salta pag.

TRCell():New(oSection1,"B1_DESC","SB1",STR0010,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/,,,/*"RIGHT"*/) //"Descricao do Produto"
TRCell():New(oSection1,"B1_UM"	,"SB1",STR0011,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/,,,/*"RIGHT"*/) //"Unidade de Medida"
TRCell():New(oSection1,"PRODUTO","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Dados dos Movimentos		                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,STR0001,{"SB1","SD1","SD2","SD3"}) //"ANEXO 10"
oSection2:SetTotalInLine(.F.)
oSection2:SetNoFilter("SD1")
oSection2:SetNoFilter("SD2")
oSection2:SetNoFilter("SD3")
oSection2:SetEditCell(.F.)
oSection2:SetCellBorder("LEFT")
oSection2:SetCellBorder("RIGHT")
oSection2:SetCellBorder("BOTTOM")
oSection2:SetCellBorder("TOP")
oSection2:SetReadOnly(.T.)

TRCell():New(oSection2,"cMes"		,"   ",CRLF+CRLF+STR0012																	,	    /*Picture*/,7			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"nSalAnt"	,"   ",STR0014+CRLF+STR0015+CRLF			+CRLF+Replic("_",14)+CRLF+PadC("A",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Inventario"##"inicial"
TRCell():New(oSection2,"nCompras"	,"   ",STR0016+CRLF+STR0017+CRLF+STR0018	+CRLF+Replic("_",14)+CRLF+PadC("B",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Excesso de"##"producao"##"ou compras"
TRCell():New(oSection2,"nEntrTerc"	,"   ",STR0019+CRLF+STR0020+CRLF+STR0021	+CRLF+Replic("_",14)+CRLF+PadC("C",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Producao"##"encomendada"##"a terceiros"
TRCell():New(oSection2,"nEntrImp"	,"   ",STR0022+CRLF+STR0023+CRLF	  	 	+CRLF+Replic("_",14)+CRLF+PadC("D",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Importacoes"##"realizadas"
TRCell():New(oSection2,"nEntrTot"	,"   ",STR0024+CRLF+STR0025+CRLF		 	+CRLF+Replic("_",14)+CRLF+PadC("E=B+C+D",14)	,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Entradas"##"totais"
TRCell():New(oSection2,"nVendas"	,"   ",STR0026+CRLF+STR0027+CRLF		 	+CRLF+Replic("_",14)+CRLF+PadC("F",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Saidas"##"por vendas"
TRCell():New(oSection2,"nPerdas"	,"   ",        CRLF+STR0028+CRLF		 	+CRLF+Replic("_",14)+CRLF+PadC("G",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Perdas"
TRCell():New(oSection2,"nSaiTerc"	,"   ",STR0029+CRLF+STR0030+CRLF+STR0031	+CRLF+Replic("_",14)+CRLF+PadC("H",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Saidas por"##"consumo"##"proprio"
TRCell():New(oSection2,"nSaiImp"	,"   ",STR0032+CRLF+STR0033+CRLF+STR0034	+CRLF+Replic("_",14)+CRLF+PadC("I",14)			,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Saidas de"##"produtos"##"importados"
TRCell():New(oSection2,"nSaiTot"	,"   ",STR0035+CRLF+STR0036+CRLF		 	+CRLF+Replic("_",14)+CRLF+PadC("J=F+G+H+I",14)	,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Saidas"##"totais"
TRCell():New(oSection2,"nSaldoAtu"	,"   ",STR0037+CRLF+STR0038+CRLF			+CRLF+Replic("_",14)+CRLF+PadC("K=A+E-J",14)	,cPictQt/*Picture*/,/*cTamQt*/		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"CENTER") //"Saldo"##"Atual"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 / 2 - Dados da Empresa	 	                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEmpresa := TRSection():New(oSection1,STR0006,{"SM0"},/*Ordem*/) 
TRCell():New(oEmpresa,"M0_NOME"	,"SM0",STR0006,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Empresa"
TRCell():New(oEmpresa,"NIT"	 	,"   ",STR0007,/*Picture*/,60,/*lPixel*/,{|| Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) }) //"NIT"
TRCell():New(oEmpresa,"GESTAO"	,"   ",STR0039,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Periodo"
oEmpresa:SetLineStyle(.T.)
oEmpresa:SetCols(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao das quebras e totalizadores que serao Impressos.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oBreak1 := TRBreak():New(oSection1,oSection1:Cell("PRODUTO"),STR0004,.F.,"PRO") // "Totais"

TRFunction():New(oSection2:Cell("nCompras"  ),"TCOLB","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nEntrTerc" ),"TCOLC","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nEntrImp"  ),"TCOLD","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nEntrTot"  ),"TCOLE","ONPRINT",oBreak1,"",cPictQt,{|| oSection2:GetFunction("TCOLB"):GetLastValue() + oSection2:GetFunction("TCOLC"):GetLastValue() + oSection2:GetFunction("TCOLD"):GetLastValue() }/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nVendas"   ),"TCOLF","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nPerdas"   ),"TCOLG","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nSaiTerc"  ),"TCOLH","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nSaiImp"   ),"TCOLI","SUM"	,oBreak1,"",cPictQt,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nSaiTot"   ),"TCOLJ","ONPRINT",oBreak1,"",cPictQt,{|| oSection2:GetFunction("TCOLF"):GetLastValue() + oSection2:GetFunction("TCOLG"):GetLastValue()+ oSection2:GetFunction("TCOLH"):GetLastValue()+ oSection2:GetFunction("TCOLI"):GetLastValue() }/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection2:Cell("nSaldoAtu" ),"TCOLK","ONPRINT",oBreak1,"",cPictQt,{|| oSection2:Cell("nSaldoAtu"):GetValue(.T.) }/*uFormula*/,.F.,.F.) 
	
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Microsiga             ³ Data ³19.03.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection1	:= oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oEmpresa	:= oReport:Section(1):Section(2)

Local cSelectD1 := '', cWhereD1 := ''
Local cSelectD2 := '', cWhereD2 := ''
Local cSelectD3 := '', cWhereD3 := ''
Local cSelectB2 := '', cWhereB2 := ''
Local cFiltroUsr:= ''
Local cSelect	:= ''
Local cSelect1	:= ''
Local cName		:= ''
Local cCodAnt   := ''
Local cPer      := ''
Local cAliasTop := 'SB1'

Local lContinua :=.T. 
Local lPassou   :=.F.
Local lTotal    :=.F.
Local lFirst    :=.T.

Local nPrinted	:= 0
Local nX        := 0
Local nSaldoAnt := 0
Local nSaldoAtu := 0
Local nValor    := 0
Local nPerdas   := 0
Local nEntrImp  := 0
Local nSaiTerc  := 0
Local nProducao := 0
Local nVendas   := 0
Local nDevVendas:= 0
Local nDevComprs:= 0
Local nEntrTot  := 0
Local nSaiImp   := 0
Local nSalAnt   := 0

Local nCompras  := 0
Local nEntrTerc := 0
Local nPeriodos := 0

Local aSaldoAnt := {}
Local aPeriodos := {}	

Local nPagina	:= mv_par05
Local dCntData	:= mv_par01

//-- Posiciona na Empresa/Filial 
dbSelectArea("SM0")
dbSetOrder(1)
dbSeek(cEmpAnt+cFilAnt)

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

cFiltroUsr := oSection1:GetAdvplExp()

dbSelectArea("SD2")
dbSetOrder(1)
nRegs := SD2->(LastRec())

dbSelectArea("SD3")
dbSetOrder(1)
nRegs += SD3->(LastRec())

dbSelectArea("SD1")
dbSetOrder(1)
nRegs += SD1->(LastRec())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)
	
	cAliasTop := GetNextAlias()    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do WHERE da tabela SD1                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cWhereD1 := "%"
	cWhereD1 += " AND D1_REMITO = '" + Space(TamSx3("D1_REMITO")[1]) + "' "
	cWhereD1 += "%"	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do WHERE da tabela SD2                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cWhereD2 := "%"
	cWhereD2 += " AND D2_REMITO = '" + Space(TamSx3("D2_REMITO")[1]) + "' "
	cWhereD2 += "%"	
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do WHERE da tabela SD3                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cWhereD3 := "%"
	cWhereD3 += "%"	
	
	BeginSql Alias cAliasTop

		Column DATA as Date

		SELECT 	'SD1' ARQ, 					//-- 01 ARQ
				 SB1.B1_COD PRODUTO, 		//-- 02 PRODUTO
				 SB1.B1_UM UM,   			//-- 03 UM
				 SB1.B1_SEGUM SEGUM,		//-- 04 SEGUM
				 SB1.B1_DESC DESCR,  		//-- 05 DESCR
				 SD1.D1_DTDIGIT DATA,		//-- 06 DATA
				 SD1.D1_TES TES,			//-- 07 TES
				 SD1.D1_CF CF,				//-- 08 CF
				 SD1.D1_NUMSEQ SEQUENCIA,	//-- 09 SEQUENCIA
				 SD1.D1_DOC DOCUMENTO,		//-- 10 DOCUMENTO
				 SD1.D1_SERIE SERIE,		//-- 11 SERIE
				 SD1.D1_QUANT QUANTIDADE,	//-- 12 QUANTIDADE
				 SD1.D1_QTSEGUM QUANT2UM,	//-- 13 QUANT2UM
				 SD1.D1_LOCAL ARMAZEM,		//-- 14 ARMAZEM
				 SD1.D1_TIPO TIPONF,		//-- 15 TIPO NF
				 SD1.R_E_C_N_O_ NRECNO,  	//-- 16 RECNO
				 SB1.B1_IMPORT IMPORT,	  	//-- 17 IMPORT
				 0 PERDAS,					//-- 18 PERDAS	
				 SD1.D1_OP OP				//-- 19 OP

		FROM %table:SB1% SB1,%table:SD1% SD1,%table:SF4% SF4
	
		WHERE SB1.B1_COD     =  SD1.D1_COD		AND  	SD1.D1_FILIAL  =  %xFilial:SD1%		AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%  	AND 	SD1.D1_TES     =  SF4.F4_CODIGO		AND
			  SF4.F4_ESTOQUE =  'S'				AND 	SD1.D1_DTDIGIT >= %Exp:mv_par01%	AND
			  SD1.D1_DTDIGIT <= %Exp:mv_par02%	AND		SD1.D1_ORIGLAN <> 'LF'				AND
			  SD1.D1_LOCAL   >= %Exp:mv_par08%	AND		SD1.D1_LOCAL   <= %Exp:mv_par09%	AND
			  SD1.%NotDel%						AND 	SF4.%NotDel%                        AND
	          SB1.B1_COD     >= %Exp:mv_par03%	AND		SB1.B1_COD     <= %Exp:mv_par04% 	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND	    SB1.%NotDel%						   		  
			  %Exp:cWhereD1%
		
	    UNION
	    
		SELECT 'SD2',	     			//-- 01 ARQ
				SB1.B1_COD,	        	//-- 02 PRODUTO
				SB1.B1_UM,				//-- 03 UM
				SB1.B1_SEGUM,			//-- 04 SEGUM
				SB1.B1_DESC,		    //-- 05 DESCR
				SD2.D2_EMISSAO,			//-- 06 DATA
				SD2.D2_TES,				//-- 07 TES
				SD2.D2_CF,				//-- 08 CF
				SD2.D2_NUMSEQ,			//-- 09 SEQUENCIA
				SD2.D2_DOC,				//-- 10 DOCUMENTO
				SD2.D2_SERIE,			//-- 11 SERIE
				SD2.D2_QUANT,			//-- 12 QUANTIDADE
				SD2.D2_QTSEGUM,			//-- 13 QUANT2UM
				SD2.D2_LOCAL,			//-- 14 ARMAZEM
				SD2.D2_TIPO,			//-- 15 TIPO NF
				SD2.R_E_C_N_O_ ,		//-- 16 RECNO
			 	SB1.B1_IMPORT IMPORT,	//-- 17 IMPORT
			 	0, 						//-- 18 PERDAS	
			    SD2.D2_OP OP			//-- 19 OP
				
		FROM %table:SB1% SB1,%table:SD2% SD2,%table:SF4% SF4
			
		WHERE	SB1.B1_COD     =  SD2.D2_COD		AND	SD2.D2_FILIAL  = %xFilial:SD2%		AND
				SF4.F4_FILIAL  = %xFilial:SF4% 		AND	SD2.D2_TES     =  SF4.F4_CODIGO		AND
				SF4.F4_ESTOQUE =  'S'				AND	SD2.D2_EMISSAO >= %Exp:mv_par01%	AND
				SD2.D2_EMISSAO <= %Exp:mv_par02%	AND	SD2.D2_ORIGLAN <> 'LF'				AND
				SD2.D2_LOCAL   >= %Exp:mv_par08%	AND	SD2.D2_LOCAL   <= %Exp:mv_par09%	AND
				SD2.%NotDel%						AND SF4.%NotDel%						AND
		        SB1.B1_COD     >= %Exp:mv_par03%	AND	SB1.B1_COD  <= %Exp:mv_par04% 		AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND	SB1.%NotDel%						   		  
  				%Exp:cWhereD2%
				
		UNION		
	
		SELECT 	'SD3',	    			//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_UM,				//-- 03 UM
				SB1.B1_SEGUM,			//-- 04 SEGUM
				SB1.B1_DESC,		    //-- 05 DESCR
				SD3.D3_EMISSAO,			//-- 06 DATA
				SD3.D3_TM,				//-- 07 TES
				SD3.D3_CF,				//-- 08 CF
				SD3.D3_NUMSEQ,			//-- 09 SEQUENCIA
				SD3.D3_DOC,				//-- 10 DOCUMENTO
				' ',					//-- 11 SERIE
				SD3.D3_QUANT,			//-- 12 QUANTIDADE
				SD3.D3_QTSEGUM,			//-- 13 QUANT2UM
				SD3.D3_LOCAL,			//-- 14 ARMAZEM
				' ',					//-- 15 TIPO NF
				SD3.R_E_C_N_O_ ,		//-- 16 RECNO
				SB1.B1_IMPORT IMPORT,	//-- 17 IMPORT
			 	SD3.D3_PERDA, 			//-- 18 PERDAS	
				SD3.D3_OP OP			//-- 19 OP
	
		FROM %table:SB1% SB1,%table:SD3% SD3
		
		WHERE	SB1.B1_COD     =  SD3.D3_COD 		AND SD3.D3_FILIAL  =  %xFilial:SD3%		AND
				SD3.D3_EMISSAO >= %Exp:mv_par01%	AND	SD3.D3_EMISSAO <= %Exp:mv_par02%	AND
				SD3.D3_LOCAL   >= %Exp:mv_par08%	AND	SD3.D3_LOCAL   <= %Exp:mv_par09%	AND
				SD3.D3_ESTORNO <> 'S'				AND SD3.%NotDel%						AND
		        SB1.B1_COD     >= %Exp:mv_par03%	AND	SB1.B1_COD  <= %Exp:mv_par04% 		AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND	SB1.%NotDel%
				%Exp:cWhereD3%				
			
		ORDER BY 2,6
	
	EndSql 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatorio para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	oSection2:SetParentQuery()
	
	oSection1:Cell("PRODUTO"):Disable()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula Periodos a serem processados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dCntData  := mv_par01
	cPer      := STR(Year(dCntData),4)+STRZERO(Month(dCntData),2)
	aPeriodos := {cPer}
	While dCntData < mv_par02
		dCntData++
		If cPer <> (STR(Year(dCntData),4)+STRZERO(Month(dCntData),2))
			cPer := STR(Year(dCntData),4)+STRZERO(Month(dCntData),2)
			aAdd(aPeriodos,cPer)
		EndIf
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o CodeBlock com o PrintLine da Secao 1 toda vez que rodar o oSection1:Init()    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:onPageBreak( { || nPrinted := 0 , CabecRBolA(oReport,oSection2,@nPagina,cCodAnt,aPeriodos) })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatorio                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTop)
	oReport:SetMeter(nRegs)
	oSection2:Init()
	oSection1:Init()

	While !oReport:Cancel() .And. !(cAliasTop)->(Eof())	
		
		If oReport:Cancel()
			Exit
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para filtro de usuario              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFiltroUsr)
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek( xFilial("SB1") + (cAliasTop)->PRODUTO )
				If !&(cFiltroUsr)
					dbSelectArea(cAliasTop)
					dbSkip()
					Loop
				EndIf
			Else
				dbSelectArea(cAliasTop)
				dbSkip()
				Loop
			EndIf
		EndIf
		dbSelectArea(cAliasTop)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento de Impressao por Produto/Periodo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lFirst	  := .T.
		cCodAnt   := (cAliasTop)->PRODUTO
		oSection1:Cell("PRODUTO"  	):SetValue(cCodAnt)
		lPassou	  := .F.
		
		For nPeriodos := 1 to Len(aPeriodos)

			//-- Inicializar Variaveis
			nCompras   := 0
			nEntrTerc  := 0
			nEntrImp   := 0
			nEntrTot   := 0
			nVendas    := 0
			nPerdas    := 0
			nSaiTerc   := 0
			nSaiImp    := 0
			nSaiTot    := 0
			nSaldoAtu  := 0
			nPerdas    := 0
			nDevComprs := 0
			nImport    := 0
			lPassou    := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcular o Saldo anterior somente no primeiro periodo        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPeriodos == 1
				nSalAnt := CalcSaldo(cCodAnt,mv_par08,mv_par09,mv_par01)
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento por Produto				                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->PRODUTO == cCodAnt .And.;
			       STR(Year((cAliasTop)->DATA),4)+STRZERO(Month((cAliasTop)->DATA),2)  == AllTrim(aPeriodos[nPeriodos])

				If oReport:Cancel()
					Exit
				EndIf
	        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtro de Usuario                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cFiltroUsr)
			    	If !(&cFiltroUsr)
						dbSelectArea(cAliasTop)
						dbSkip()
						Loop
					EndIf	
				EndIf

				oReport:IncMeter()
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Analise dos Movimentos da Tabela SD1  		                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cCodAnt .And. Alltrim((cAliasTop)->ARQ) == "SD1" .And.;
						       STR(Year((cAliasTop)->DATA),4)+STRZERO(Month((cAliasTop)->DATA),2)  == AllTrim(aPeriodos[nPeriodos])
					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial()+(cAliasTop)->TES)
					If SF4->F4_ESTOQUE == "S"
						nValor := IIf(mv_par06==2,(cAliasTop)->QUANT2UM,(cAliasTop)->QUANTIDADE)
						If SF4->F4_PODER3 == "N" .Or. Empty(SF4->F4_PODER3)
							If (cAliasTop)->TIPONF == "D"
								nDevVendas  += nValor
							Else
								If (cAliasTop)->IMPORT == 'S'
									nEntrImp += nValor
								Else
									nCompras += nValor
								EndIf	
							EndIf
						Else
							nEntrTerc += nValor
						EndIf
						lPassou := .T.
					EndIf
					dbSelectArea(cAliasTop)
					dbSkip()
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Analise dos Movimentos da Tabela SD3  		                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cCodAnt .And. Alltrim((cAliasTop)->ARQ) == "SD3" .And.;
						  	   STR(Year((cAliasTop)->DATA),4)+STRZERO(Month((cAliasTop)->DATA),2)  == AllTrim(aPeriodos[nPeriodos])
					nValor := IIf(mv_par06==2,(cAliasTop)->QUANT2UM,(cAliasTop)->QUANTIDADE)
					If (cAliasTop)->TES > "500"
						nValor := nValor*-1
					EndIf
					//-- Considera perdas pelo tipo de movimento selecionado no parametro MV_PAR07
					If (cAliasTop)->TES $ mv_par07
						nPerdas   += IIf(mv_par06 == 2,ConvUm(cCodAnt,(cAliasTop)->PERDAS,0,2),(cAliasTop)->PERDAS)
					//-- Considera perdas pela tabela SBC
					ElseIf Substr((cAliasTop)->CF,1,3) $ "RE4|DE4" .And. !Empty((cAliasTop)->OP)
						nPerdas   += IIf(mv_par06 == 2,ConvUm(cCodAnt,(cAliasTop)->PERDAS,0,2),(cAliasTop)->PERDAS)
					//-- Considera perdas pelo apontamento de producao
					ElseIf Substr((cAliasTop)->CF,1,2) == "PR"
						nProducao += nValor
						nPerdas   += IIf(mv_par06 == 2,ConvUm(cCodAnt,(cAliasTop)->PERDAS,0,2),(cAliasTop)->PERDAS)
					EndIf
					lPassou := .T.
					dbSelectArea(cAliasTop)
					dbSkip()
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Analise dos Movimentos da Tabela SD2                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cCodAnt .And. Alltrim((cAliasTop)->ARQ) == "SD2" .And.;
							   STR(Year((cAliasTop)->DATA),4)+STRZERO(Month((cAliasTop)->DATA),2)  == AllTrim(aPeriodos[nPeriodos])
					dbSelectArea("SF4")
					dbSeek(xFilial()+(cAliasTop)->TES)
					If SF4->F4_ESTOQUE == "S" 
						nValor := IIf(mv_par06==2,(cAliasTop)->QUANT2UM,(cAliasTop)->QUANTIDADE)
						If SF4->F4_PODER3 == "N" .Or. Empty(SF4->F4_PODER3)
							If (cAliasTop)->TIPONF == "D"
								nDevComprs += nValor
							Else
								If (cAliasTop)->IMPORT == 'S'
									nSaiImp += nValor
								Else
									nVendas  += nValor
								EndIf	
							EndIf
						Else
							nSaiTerc += nValor
						EndIf
						lPassou := .T.
					EndIf
					dbSelectArea(cAliasTop)
					dbSkip()
				EndDo
			EndDo
	
			oSection1:Cell("PRODUTO"  	):SetValue((cAliasTop)->PRODUTO)

			If lPassou
				lTotal:=.T.
				If lFirst
					dbSelectArea("SB1")
					dbSetorder(1)
					dbSeek(xFilial("SB1")+cCodAnt)
					oSection1:Cell("B1_UM"		):SetValue(If(mv_par06==1,SB1->B1_UM,SB1->B1_SEGUM))
					oSection1:PrintLine()
					oReport:SkipLine()
					oReport:SkipLine()
					lFirst := .F.
				EndIf
				oSection2:Cell("cMes"   	):SetValue(SubsTr(aPeriodos[nPeriodos],5,2)+'/'+SubsTr(aPeriodos[nPeriodos],1,4))
				//-- Coluna "A"
				oSection2:Cell("nSalAnt"  	):SetValue(nSalAnt)
				//-- Coluna "B"			
				oSection2:Cell("nCompras"  	):SetValue(nCompras-nDevComprs+nProducao)
				//-- Coluna "C"			
				oSection2:Cell("nEntrTerc"  ):SetValue(nEntrTerc)
				//-- Coluna "D"			
				oSection2:Cell("nEntrImp" 	):SetValue(nEntrImp)
				//-- Coluna "E=(B+C+D)"
				nEntrTot := ((nCompras-nDevComprs+nProducao)+nEntrTerc+nEntrImp)
				oSection2:Cell("nEntrTot" 	):SetValue(nEntrTot)
				//-- Coluna "F"			
				oSection2:Cell("nVendas"   	):SetValue(nVendas)
				//-- Coluna "G"			
				oSection2:Cell("nPerdas"  	):SetValue(nPerdas)
				//-- Coluna "H"			
				oSection2:Cell("nSaiTerc"	):SetValue(nSaiTerc)
				//-- Coluna "I"			
				oSection2:Cell("nSaiImp"	):SetValue(nSaiImp)
				//-- Coluna "J=(F+G+H+I)"
				nSaiTot := (nVendas+nPerdas+nSaiTerc+nSaiImp)
				oSection2:Cell("nSaiTot" 	):SetValue(nSaiTot)
				//-- Coluna "K=(A+E+J)"
				nSalAtu := (nSalAnt+nEntrTot-nSaiTot)
				oSection2:Cell("nSaldoAtu"	):SetValue(nSalAtu)
				oSection2:PrintLine()
				nSalAnt := nSalAtu
			EndIf
			dbSelectArea(cAliasTop)

        Next nPeriodos
	EndDo
	oSection2:Finish()
	oSection1:Finish()

#ELSE


#ENDIF		

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CabecRBolA³ Autor ³Ricardo Berti          ³Data  ³11/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cabecalho para relat.Anexo 10						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabecRBolA(ExpO1,ExpO2,ExpN1,ExpN1,ExpC1,ExpA1)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
±±³          ³ ExpO2 = Objeto da secao1 - detalhe	                      ³±±
±±³          ³ ExpN1 = Numero de Pagina                                   ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpA1 = Array dos meses	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CabecRBolA(oReport,oSection2,nPagina,cProduto,aPeriodos)

Local aAreaAnt := GetArea()
Local oEmpresa := oReport:Section(1):Section(2)
Local nLin

oEmpresa:Init()

oReport:PrintText( STR0001,,oSection2:Cell("nSaldoAtu"):ColPos()) 				//"Anexo 10"
oReport:SkipLine()
oReport:PrintText( STR0041+'  '+Ltrim(Str(nPagina)),,oSection2:Cell("nSaldoAtu"):ColPos())	//"Folha: "
nPagina++

oEmpresa:Cell("GESTAO"):SetValue(SubsTr(aPeriodos[1],5,2)+'/'+SubsTr(aPeriodos[1],1,4)+STR0040+SubsTr(aPeriodos[Len(aPeriodos)],5,2)+'/'+SubsTr(aPeriodos[Len(aPeriodos)],1,4))
oEmpresa:PrintLine()
oEmpresa:finish()

nLin := oReport:Row()
oReport:PrintText( STR0008,nLin,oSection2:Cell("nEntrTerc"):ColPos())	//"INFORMACION SOBRE EL MOVIMIENTO DE INVENTARIOS DE PRODUCTOS GRAVADOS CON TASAS ESPECIFICAS Y PORCENTAJES"
oReport:SkipLine()
oReport:PrintText( STR0009,,oSection2:Cell("nEntrTot"):ColPos()) 		//"(EXPRESADO EN CANTIDADES)"
oReport:SkipLine()
nLin := oReport:Row()
oReport:PrintText( STR0002,nLin,oSection2:Cell("nEntrImp"):ColPos()) //"Movimiento fisico de inventarios por productos gravados con ICE e IEHD"
oReport:SkipLine()
RestArea(aAreaAnt)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CalcSaldo ³ Autor ³Microsiga S/A          ³Data  ³19/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para calculo do Saldo  						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcSaldo(ExpC1,ExpC2,ExpC3,ExpD1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto                   	              ³±±
±±³          ³ ExpC2 = Codigo do Armazem De                               ³±±
±±³          ³ ExpC3 = Codigo do Armazem Ate                              ³±±
±±³          ³ ExpD1 = Data de Processamento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcSaldo(cProduto,cLocalDe,cLocalAte,dDataIni)
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSD3 := SD3->(GetArea())

Local nValor     := 0
Local nDevVendas := 0
Local nEntrImp   := 0
Local nCompras   := 0
Local nEntrTerc  := 0
Local nPerdas    := 0
Local nProducao  := 0
Local nDevComprs := 0
Local nSaiTerc   := 0
Local nVendas    := 0
Local nEntrTot   := 0
Local nSaiTot    := 0
Local nSalAtu    := 0
Local nSaiImp    := 0
Local nSalAnt    := 0
Local cSeek      := ''

Default cProduto := ''
Default cLocalDe := ''
Default cLocalAte:= ''
Default dDataIni := CTOD('01/01/1980')

dbSelectArea("SB1")
dbSetorder(1)
dbSeek(xFilial("SB1")+cProduto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analise dos Movimentos da Tabela SD1  		                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(5)
dbSeek(cSeek:=xFilial("SD1")+cProduto)
While !Eof() .And. cSeek == SD1->D1_FILIAL+SD1->D1_COD 
	// Filtra Data de Processamento
	If dDataIni < SD1->D1_DTDIGIT
		dbSkip()
		Loop
	EndIf
	//-- Filtrar Armazens
	If SD1->D1_LOCAL < cLocalDe .And.;
	   SD1->D1_LOCAL > cLocalAte
		dbSkip()
		Loop
	EndIf
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+SD1->D1_TES)
	If SF4->F4_ESTOQUE == "S"
		nValor := IIf(mv_par06==2,SD1->D1_QTSEGUM,SD1->D1_QUANT)
		If SF4->F4_PODER3 == "N" .Or. Empty(SF4->F4_PODER3)
			If SD1->D1_TIPO == "D"
				nDevVendas  += nValor
			Else
				If SB1->B1_IMPORT == 'S'
					nEntrImp += nValor
				Else
					nCompras += nValor
				EndIf	
			EndIf
		Else
			nEntrTerc += nValor
		EndIf
	EndIf
	dbSelectArea("SD1")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analise dos Movimentos da Tabela SD3  		                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD3")
dbSetOrder(3)
dbSeek(cSeek:=xFilial("SD3")+cProduto)
While !Eof() .And. cSeek == SD3->D3_FILIAL+SD3->D3_COD
	// Filtra Data de Processamento
	If dDataIni < SD3->D3_EMISSAO
		dbSkip()
		Loop
	EndIf
	//-- Filtrar Armazens
	If SD3->D3_LOCAL < cLocalDe .And.;
	   SD3->D3_LOCAL > cLocalAte
		dbSkip()
		Loop
	EndIf

	//-- Nao Considerar movimentos estornados
	If SD3->D3_ESTORNO == 'S'
		dbSkip()
		Loop
	EndIf

	nValor := IIf(mv_par06==2,SD3->D3_QTSEGUM,SD3->D3_QUANT)
	If SD3->D3_TM > "500"
		nValor := nValor*-1
	EndIf
	//-- Considera perdas pelo tipo de movimento selecionado no parametro MV_PAR07
	If SD3->D3_TM $ mv_par07
		nPerdas   += IIf(mv_par06 == 2,ConvUm(cProduto,SD3->D3_PERDA,0,2),SD3->D3_PERDA)
	//-- Considera perdas pela tabela SBC
	ElseIf Substr(SD3->D3_CF,1,2) $ "RE4|DE4" .And. !Empty(SD3->D3_OP)
		nPerdas   += IIf(mv_par06 == 2,ConvUm(cProduto,SD3->D3_PERDA,0,2),SD3->D3_PERDA)
	//-- Considera perdas pelo apontamento de producao
	ElseIf Substr(SD3->D3_CF,1,2) == "PR"
		nProducao += nValor
		nPerdas   += IIf(mv_par06 == 2,ConvUm(cProduto,SD3->D3_PERDA,0,2),SD3->D3_PERDA)
	EndIf
	dbSelectArea("SD3")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analise dos Movimentos da Tabela SD2                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(1)
dbSeek(cSeek:=xFilial("SD2")+cProduto)
While !Eof() .And. cSeek == SD2->D2_FILIAL+SD2->D2_COD
	// Filtra Data de Processamento
	If dDataIni < SD2->D2_EMISSAO
		dbSkip()
		Loop
	EndIf
	//-- Filtrar Armazens
	If SD2->D2_LOCAL < cLocalDe .And.;
	   SD2->D2_LOCAL > cLocalAte
		dbSkip()
		Loop
	EndIf
	dbSelectArea("SF4")
	dbSeek(xFilial("SD2")+SD2->D2_TES)
	If SF4->F4_ESTOQUE == "S" 
		nValor := IIf(mv_par06==2,SD2->D2_QTSEGUM,SD2->D2_QUANT)
		If SF4->F4_PODER3 == "N" .Or. Empty(SF4->F4_PODER3)
			If SD2->D2_TIPO == "D"
				nDevComprs += nValor
			Else
				If SB1->B1_IMPORT == 'S'
					nSaiImp += nValor
				Else
					nVendas  += nValor
				EndIf	
			EndIf
		Else
			nSaiTerc += nValor
		EndIf
	EndIf
	dbSelectArea("SD2")
	dbSkip()
EndDo

//-- Coluna "E=(B+C+D)"
nEntrTot := ((nCompras-nDevComprs+nProducao)+nEntrTerc+nEntrImp)
//-- Coluna "J=(F+G+H+I)"
nSaiTot  := (nVendas+nPerdas+nSaiTerc+nSaiImp)
//-- Coluna "K=(A+E+J)"
nSalAtu  := (nSalAnt+nEntrTot-nSaiTot)

RestArea(aAreaSD3)
RestArea(aAreaSD2)
RestArea(aAreaSD1)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return nSalAtu