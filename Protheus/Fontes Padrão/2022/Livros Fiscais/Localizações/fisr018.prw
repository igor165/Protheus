#INCLUDE "FISR018.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISR018    ³ Autor ³ Luciana Pires      ³ Data ³21/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de Compras - GST              	    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISR018()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Austrália				 									  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function FISR018()

Private cPerg	  := "FISR018"
Private oReport 

/*********************************
//Parametros FISR018
//******************************** 
//MV_PAR01 - Data Inicial
//MV_PAR02 - Data Final
//MV_PAR03 - Fornecedor de
//MV_PAR04 - Loja de
//MV_PAR05 - Fornecedor ate
//MV_PAR06 - Loja ate
//********************************/ 
          
If FindFunction("TRepInUse") .And. TRepInUse()
		oReport:=ReportDef()
		oReport:PrintDialog()
Else
	MsgAlert(STR0001) //"Para utilizar este relatório configure o parâmetro MV_TREPORT"
	Return
EndIf

Return

RestArea(aArea)
Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef  ³ Autor ³Luciana Pires        ³ Data ³ 21/10/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                   ³±±
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

Local oSecao1
Local oBreak1
Local oReport

Local cReport	:= "FISR018"
Local cTitulo		:= OemToAnsi(STR0002)//"Registro de Compras - Good And Services Tax"	
Local cDesc		:= OemToAnsi(STR0003) //"Este programa tem como objetivo imprimir o Registro de Compras - Good and Services Tax"

oReport := TReport():New(cReport,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cDesc)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)
oReport:PageTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)
oReport:lHeaderVisible := .F. 


oSecao1:=TRSection():New(oReport,cTitulo,{"SD1","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecao1:SetPageBreak(.T.)
oSecao1:SetNoFilter({"SA2"})

TRCell():New(oSecao1,"A2_NOME","SA2",OemToAnsi(STR0004)/*"Fornecedor"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D1_DOC","SD1",OemToAnsi(STR0005)/*"Numero Nota"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D1_EMISSAO","SD1",OemToAnsi(STR0006)/*"Emissão"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D1_TIPO","SD1",OemToAnsi(STR0017)/*"Tipo Doc"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"B1_COD","SB1",OemToAnsi(STR0007)/*"Código Produto"*/,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"B1_DESC","SB1",OemToAnsi(STR0008)/*"Descrição Produto"*/,/*Picture*/,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D1_QUANT","SD1",OemToAnsi(STR0009)/*"Quantidade"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D1_VUNIT","SD1",OemToAnsi(STR0010)/*"Valor Unitário"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"SUBTOTAL","",OemToAnsi(STR0011)/*"Subtotal sem GST"*/,X3PICTURE("D1_VALIMP1"),TamSX3("D1_VALIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"MONTGST","",OemToAnsi(STR0012)/*"Montante GST"*/,X3PICTURE("D1_VALIMP1"),TamSX3("D1_VALIMP1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D1_TOTAL","SD1",OemToAnsi(STR0013)/*"Total Nota"*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSecao1:SetEdit(.F.)
oSecao1:SetLeftMargin(20)                               

oSecao1:Cell("D1_QUANT"):SetHeaderAlign("RIGHT")
oSecao1:Cell("D1_VUNIT"):SetHeaderAlign("RIGHT")
oSecao1:Cell("SUBTOTAL"):SetHeaderAlign("RIGHT")
oSecao1:Cell("MONTGST"):SetHeaderAlign("RIGHT") 
oSecao1:Cell("D1_TOTAL"):SetHeaderAlign("RIGHT") 

//Quebra por Fornecedor
oBreak1 := TRBreak():New(oSecao1,oSecao1:Cell("A2_NOME"),/*"Nome"*/,.F.)

//Totalizadores
TRFunction():New(oSecao1:Cell("D1_QUANT")	,Nil,"SUM",oBreak1,STR0009,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao1:Cell("D1_VUNIT")	,Nil,"SUM",oBreak1,STR0010,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao1:Cell("SUBTOTAL")	,Nil,"SUM",oBreak1,STR0011,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao1:Cell("MONTGST")	,Nil,"SUM",oBreak1,STR0012,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
TRFunction():New(oSecao1:Cell("D1_TOTAL")	,Nil,"SUM",oBreak1,STR0013,"@E 999,999,999.99",/*uFormula*/,.T.,.F.)
oReport:Section(1):SetTotalText(STR0014) //"TOTAIS"              


Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Luciana Pires        ³ Data ³ 21/10/2011 ³±±
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

Local oRegistro		:= oReport:Section(1)
Local oCabec			:= oReport:Section(2)			
Local oTFont 			:= TFont():New("Verdana",,10,.T.,,,,,,.F.) 

Local cAliasSD1	:= "SD1"
Local cTitulo			:= OemToAnsi(STR0002)//"Registro de Compras - Good And Services Tax"	
Local cPeriod			:= ""
Local cDoc			:= ""
Local cProd			:= ""
Local cDescProd	:= ""             
Local cCliFor			:= ""
Local cABN			:= ""                   
Local cOrderby		:= ""
Local cTipo			:= ""

Local dEmissao    	:= dDataBase 

Local nLinha			:= 0
Local nLastRec		:= 0
Local nPag			:= 1
Local nRow          	:= 0
Local nQtade			:= 0
Local nVUnit			:= 0
Local nSubTotal		:= 0
Local nMontGST	:= 0
Local nTotal			:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Detalhe (campos a serem impressos)                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oRegistro:Cell("D1_DOC"):SetBlock({|| cDoc})
oRegistro:Cell("D1_EMISSAO"):SetBlock({|| dEmissao})
oRegistro:Cell("D1_TIPO"):SetBlock({|| cTipo})
oRegistro:Cell("B1_COD"):SetBlock({|| cProd})
oRegistro:Cell("B1_DESC"):SetBlock({|| cDescProd})
oRegistro:Cell("D1_QUANT"):SetBlock({|| nQtade})
oRegistro:Cell("D1_VUNIT"):SetBlock({|| nVUnit})
oRegistro:Cell("SUBTOTAL"):SetBlock({|| nSubTotal})
oRegistro:Cell("MONTGST"):SetBlock({|| nMontGST})
oRegistro:Cell("D1_TOTAL"):SetBlock({|| nTotal})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o título do realório                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ä ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPeriod	:= OemToAnsi(STR0015)+dtoc(MV_PAR01)+SPACE(4)+OemToAnsi(STR0016)+SPACE(4)+dtoc(MV_PAR02) //Período: MV_PAR01 até MV_PAR02
oReport:SetTitle(cTitulo)
oReport:SetPageNumber(nPag)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Cabecalho      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCabec:SetLeftMargin(20)                               
oCabec:Init()
oReport:Say(150,290,cTitulo,oTFont)
oReport:Say(150,1500,cPeriod,oTFont)
oReport:Say(150,2800,"PAG.: "+StrZero(nPag,6),oTFont)
oCabec:Finish()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()	

cAliasSD1 := GetNextAlias()
cOrderBY 	:= '%SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_DOC,SD1.D1_SERIE%'

BeginSql Alias cAliasSD1
	SELECT SD1.D1_DOC, SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_TIPO, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL, SD1.D1_VALIMP1, SD1.D1_VALIMP4 
	FROM %table:SD1% SD1
	WHERE D1_FILIAL = %Exp:xFilial("SD1")% AND 
		D1_EMISSAO	>=	%Exp:mv_par01% AND 
		D1_EMISSAO	<=	%Exp:mv_par02% AND 
		D1_FORNECE	>=	%Exp:mv_par03% AND 
		D1_LOJA			>= 	%Exp:mv_par04% AND 
		D1_FORNECE	<=	%Exp:mv_par05% AND 
		D1_LOJA			<=	%Exp:mv_par06% AND    
		SD1.%NotDel% 
	ORDER BY %Exp:cOrderby%
EndSql 

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea((cAliasSD1))
dbGoTop()
nLastRec := (cAliasSD1)->(LastRec())
oReport:SetMeter(nLastRec)
oReport:SkipLine(9)

While !(cAliasSD1)->(Eof()) 
	oRegistro:Init()
	oReport:IncMeter()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
	//³Busca dados do Fornecedor no SA2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù	
	SA2->( dbSetOrder(1) )
	If SA2->( dbSeek( xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		cCliFor 	:= SA2->A2_NOME
		cABN  	:= SA2->A2_CGC
	Else
		cCliFor	:= ""
		cABN  	:= ""
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
	//³Busca dados do Produto no SB1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù	
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1")+(cAliasSD1)->D1_COD))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
	//³Verifico impressão cabeçalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù	
	If (oReport:Row() < nRow)	        
		oCabec:SetLeftMargin(20)                               
		oCabec:Init() 
		nPag++			
 		oReport:Say(150,290,cTitulo,oTFont)
		oReport:Say(150,1500,cPeriod,oTFont)
		oReport:Say(150,2800,"PAG.: "+StrZero(nPag,6),oTFont)
		oCabec:Finish()
		oReport:SkipLine(10)
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄœ¿
	//³Obtem dados para secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄœÙ	
	cDoc				:= (cAliasSD1)->D1_DOC
	dEmissao		:= (cAliasSD1)->D1_EMISSAO                                             
	cTipo				:= (cAliasSD1)->D1_TIPO
	cProd			:= SB1->B1_COD
	cDescProd	:= SB1->B1_DESC
	nQtade			:= (cAliasSD1)->D1_QUANT
	nVUnit			:= (cAliasSD1)->D1_VUNIT
	nSubTotal 		:= (cAliasSD1)->D1_TOTAL - Iif((cAliasSD1)->D1_VALIMP1 > 0, (cAliasSD1)->D1_VALIMP1, (cAliasSD1)->D1_VALIMP4)
	nMontGST		:= Iif((cAliasSD1)->D1_VALIMP1 > 0, (cAliasSD1)->D1_VALIMP1, (cAliasSD1)->D1_VALIMP4)
	nTotal			:= (cAliasSD1)->D1_TOTAL
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄœ¿
	//³Imprime a variável no objeto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄœÙ 	   
	oRegistro:Cell("D1_DOC"):Show()
	oRegistro:Cell("D1_EMISSAO"):Show()
	oRegistro:Cell("D1_TIPO"):Show()
	oRegistro:Cell("B1_COD"):Show()
	oRegistro:Cell("B1_DESC"):Show()
	oRegistro:Cell("D1_QUANT"):Show()
	oRegistro:Cell("D1_VUNIT"):Show()
	oRegistro:Cell("SUBTOTAL"):Show()
	oRegistro:Cell("MONTGST"):Show()
	oRegistro:Cell("D1_TOTAL"):Show()
	
	nRow := oReport:Row()	
	oRegistro:PrintLine()   	 

	(cAliasSD1)->(dbSkip())
	
Enddo

oRegistro:Finish()


Return
