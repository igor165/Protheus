#include "FCIR003.CH"
#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FCIR003  ³ Autor ³ Materiais           ³ Data ³ 23/06/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio FCI Sintetico                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCIR003()
Local oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Interface de impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
oReport:PrintDialog()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef ³ Autor ³ Materiais 		     ³ Data ³ 23/06/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oSection1
Local oSection2
Local oReport 
Local oCell
Local nEspaco   := 5
Local nTipo     := 0
Local cAliasTR1 := GetNextAlias()
Local cAliasTR2 := GetNextAlias()

oReport := TReport():New("FCIR003","","FCR003",{|oReport| ReportPrint(oReport,cAliasTR1,cAliasTR2)},STR0001)//"Este relatório tem como objetivo apresentar os valores analíticos calculados na apuração do FCI para as Produções."
oReport:SetTitle(STR0002)//"Relação FCI Analítica - Produção"
oReport:SetLandscape()
oReport:DisableOrientation()

Pergunte("FCR003",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 1: Producoes do Periodo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0003,{"SD3","SB1",cAliasTR1})//"Produções do Periodo"
oSection1:SetLineStyle()
oSection1:SetReadOnly()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueia a edicao de celulas e filtros do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetEditCell(.F.)
oSection1:SetNoFilter("SD3")
oSection1:SetNoFilter("SB1")

TRCell():New(oSection1,"D3_COD" ,"SD3"    ,STR0004,/*Picture*/,TamSX3("D3_COD")[1]+nEspaco,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)//"PRODUTO"
TRCell():New(oSection1,"B1_DESC","SB1"    ,STR0005,/*Picture*/,TamSX3("B1_DESC")[1]+nEspaco,/*lPixel*/,/*bBlock*/,/*cAlign*/,,,,,,,,/*lBold*/.T.)//"Descrição"
TRCell():New(oSection1,"QUANT"  ,cAliasTR1,STR0006,PesqPict("SD3","D3_QUANT"),TamSX3("D3_QUANT")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"LEFT",,,,,,,,/*lBold*/.T.)//"Quantidade"
TRCell():New(oSection1,"VI_UN"  ,cAliasTR1,STR0007,PesqPict("SA8","A8_VLRVI"),TamSX3("A8_VLRVI")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"LEFT",,,,,,,,/*lBold*/.T.)//"Vl. Imp. Unitário"
TRCell():New(oSection1,"VI"     ,cAliasTR1,STR0008         ,PesqPict("SA8","A8_VLRVI"),TamSX3("A8_VLRVI")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"LEFT",,,,,,,,/*lBold*/.T.)//"Vl. Imp."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 2: Requisicoes/Devolucoes das Producoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oReport,STR0009,{"SD3","SB1","SA8","SC2",cAliasTR2})//"Requisições/Devoluções das Produções"
oSection2:SetHeaderPage()
oSection2:SetReadOnly()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueia a edicao de celulas e filtros do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:SetEditCell(.F.)
oSection2:SetNoFilter("SD3")
oSection2:SetNoFilter("SB1")
oSection2:SetNoFilter("SA8")
oSection2:SetNoFilter("SC2")

TRCell():New(oSection2,"D3_COD"   ,"SD3"    ,STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*bBlock*/)//"Produto"
TRCell():New(oSection2,"B1_DESC"  ,"SB1"    ,STR0011,/*Picture*/,TamSX3("B1_DESC")[1]+(2*nEspaco),/*lPixel*/,/*bBlock*/)//"| Descrição"
TRCell():New(oSection2,"D3_OP"    ,"SD3"    ,STR0012,/*Picture*/,TamSX3("D3_OP")[1]+nEspaco,/*lPixel*/,/*bBlock*/)//"| Ordem de Produção"
TRCell():New(oSection2,"D3_CF"    ,"SD3"    ,STR0013,/*Picture*/,TamSX3("D3_CF")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"CENTER")//"| C/F"
TRCell():New(oSection2,"QUANT"    ,cAliasTR2,STR0014,PesqPict("SD3","D3_QUANT"),TamSX3("D3_QUANT")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"RIGHT")//"| Quantidade"
TRCell():New(oSection2,"A8_VLRVI" ,"SA8"    ,STR0015,PesqPict("SA8","A8_VLRVI"),TamSX3("A8_VLRVI")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"RIGHT")//"| Vl. Imp. Uni. "
TRCell():New(oSection2,"VITOT"    ,cAliasTR2,STR0016,PesqPict("SA8","A8_VLRVI"),TamSX3("A8_VLRVI")[1]+nEspaco,/*lPixel*/,/*bBlock*/,"RIGHT")//"| Vl. Imp."
TRCell():New(oSection2,"A8_PROCOM","SA8"    ,STR0017,/*Picture*/,25,/*lPixel*/,/*bBlock*/,"CENTER")//"| Comprado / Produzido ?"
TRCell():New(oSection2,"A8_PERIOD","SA8"    ,STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*bBlock*/,"CENTER")//"| Periodo Apuração"

TRFunction():New(oSection2:Cell("QUANT"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
TRFunction():New(oSection2:Cell("VITOT"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
oSection2:SetTotalInLine(.F.)
oSection2:SetTotalText(STR0019)//"T O T A I S"

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportPrint ³ Autor ³ Materiais        ³ Data ³ 22/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasTR1,cAliasTR2)

Local cPrdDe		:= mv_par01
Local cPrdAte		:= mv_par02
Local cPeriod		:= Substr(Alltrim(mv_par03),3,6) + Substr(Alltrim(mv_par03),1,2)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oReport:Section(2)
Local cQuery		:= ""
Local aProdPer	:= {}

oReport:SetTitle(STR0020+Substr(Alltrim(mv_par03),1,2)+"/"+Substr(Alltrim(mv_par03),3,6)+")")//"Relação FCI Analítica - Produção (Periodo: "

If !oReport:Cancel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo com Producoes do Periodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT SUM(D3_QUANT) AS QUANT, SUM(D3_VLRVI) AS VI, D3_COD, B1_DESC FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1	ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = D3_COD "
	cQuery += "WHERE D3_FILIAL = '"+xFilial('SD3')+"' AND D3_COD BETWEEN '"+cPrdDe+"' AND '"+cPrdAte+"' AND "
	cQuery += "SUBSTRING(D3_EMISSAO,1,6) = '"+cPeriod+"' AND D3_ESTORNO = '' AND D3_CF IN ('PR0','PR1') AND "
	cQuery += "SD3.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' GROUP BY D3_COD, B1_DESC ORDER BY 3"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTR1,.T.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo com Requisicoes/Devolucoes das Producoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cQuery := "SELECT SUM(D3_QUANT) AS QUANT, C2_PRODUTO, D3_COD, B1_DESC, D3_OP, D3_CF, "
	cQuery += "A8_VLRVI, A8_PROCOM, A8_PERIOD FROM "+RetSqlName("SD3")+" SD3 JOIN "+RetSqlName("SB1")
	cQuery += " SB1 ON D3_FILIAL = '"+xFilial('SD3')+"' AND B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = D3_COD " 		
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial('SC2')+"' AND C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD = D3_OP "
	cQuery += "LEFT JOIN "+RetSqlName("SA8")+" SA8 ON A8_FILIAL = '"+xFilial('SA8')+"' AND A8_COD = D3_COD AND A8_PERIOD = '"+mv_par03
	cQuery += "' AND SA8.D_E_L_E_T_ = '' WHERE D3_FILIAL = '"+xFilial('SD3')+"' AND D3_OP IN "
	cQuery += "(SELECT D3_OP FROM "+RetSqlName("SD3")+" WHERE D3_FILIAL = '"+xFilial('SD3')+"' AND D3_COD BETWEEN '"+cPrdDe+"' AND '"+cPrdAte
	cQuery += "' AND D3_ESTORNO = '' AND D3_OP <> '' AND SUBSTRING(D3_EMISSAO,1,6) = '"+cPeriod+"' AND D3_CF IN ('PR0','PR1') AND D_E_L_E_T_ = '') AND D3_ESTORNO = '' AND "
	cQuery += "D3_CF NOT IN ('PR0','PR1') AND SB1.D_E_L_E_T_ = '' AND SD3.D_E_L_E_T_ = '' AND SC2.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY D3_COD, D3_OP, D3_CF, C2_PRODUTO, B1_DESC, A8_VLRVI, A8_PROCOM, A8_PERIOD ORDER BY 2, 5, 3"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTR2,.T.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da Impressao do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter((cAliasTR1)->(LastRec()))
	
	While !(cAliasTR1)->(Eof()) .And. !oReport:Cancel()
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		oSection1:Init()
		oSection1:Cell("D3_COD" ):setValue((cAliasTR1)->D3_COD)
		oSection1:Cell("B1_DESC"):setValue((cAliasTR1)->B1_DESC)
		oSection1:Cell("QUANT"  ):setValue((cAliasTR1)->QUANT)
		oSection1:Cell("VI"     ):setValue((cAliasTR1)->VI)
		oSection1:Cell("VI_UN"  ):setValue((cAliasTR1)->VI /(cAliasTR1)->QUANT)
		oSection1:PrintLine()
		oReport:PrintText(STR0021)//"C O M P O N E N T E S"
		oReport:ThinLine()
		
		While !(cAliasTR2)->(Eof()) .And. !oReport:Cancel() .And. (cAliasTR2)->C2_PRODUTO == (cAliasTR1)->D3_COD
			oSection2:Init()
			
			oSection2:Cell("D3_COD"   ):setValue((cAliasTR2)->D3_COD)
			oSection2:Cell("B1_DESC"  ):setValue((cAliasTR2)->B1_DESC)
			oSection2:Cell("D3_OP"    ):setValue((cAliasTR2)->D3_OP)
			oSection2:Cell("D3_CF"    ):setValue((cAliasTR2)->D3_CF)
			
			If Len(Alltrim((cAliasTR2)->A8_PERIOD)) == 0
				aProdPer := FR003CPer((cAliasTR2)->D3_COD)
			Else
				aProdPer := {(cAliasTR2)->D3_COD,(cAliasTR2)->A8_VLRVI,(cAliasTR2)->A8_PERIOD,(cAliasTR2)->A8_PROCOM}
			EndIf
			
			If Substr((cAliasTR2)->D3_CF,1,2) == "DE"
				oSection2:Cell("QUANT"    ):setValue((cAliasTR2)->QUANT * -1)
				oSection2:Cell("VITOT"    ):setValue(aProdPer[2] * (cAliasTR2)->QUANT * -1)
			Else
				oSection2:Cell("QUANT"    ):setValue((cAliasTR2)->QUANT)
				oSection2:Cell("VITOT"    ):setValue(aProdPer[2] * (cAliasTR2)->QUANT)
			EndIf
						
			oSection2:Cell("A8_PERIOD"):setValue(aProdPer[3])
			oSection2:Cell("A8_VLRVI" ):setValue(aProdPer[2])
			
			If aProdPer[4] ==  "C"
				oSection2:Cell("A8_PROCOM"):setValue(STR0022)//"Comprado"
			ElseIf aProdPer[4] == "P"
				oSection2:Cell("A8_PROCOM"):setValue(STR0023)//"Produzido"
			Else
				oSection2:Cell("A8_PROCOM"):setValue("---------")
			EndIf

			oSection2:PrintLine()
			(cAliasTR2)->(dbSkip())
		EndDo
		oSection2:Finish()
		oSection1:Finish()		
		(cAliasTR1)->(dbSkip())
	EndDo		

EndIf

(cAliasTR1)->(DbCloseArea())
(cAliasTR2)->(DbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FR003CPer ³ Autor ³ Materiais            ³ Data ³23/06/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca ultima apuracao do produto, se nao estiver no periodo³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FR003CPer(cProd)

Local cQuery		:= ""
Local cAliasTRB	:= GetNextAlias()
Local aRet			:= {}
Local cCmdCut		:= ''

If Upper(AllTrim(TcGetDb())) $ "DB2|ORACLE|INFORMIX|POSTGRES"
	
	cCmdCut := "SUBSTR"
	
Else
	
	cCmdCut += "SUBSTRING"
	
EndIf

cQuery := "SELECT MAX(A8_PERIOD) AS A8_PERIOD, " + cCmdCut + "(A8_PERIOD,3,4)||" + cCmdCut + "(A8_PERIOD,1,2) AS PERIODO,  A8_COD, A8_VLRVI, A8_PROCOM "
cQuery += "FROM "+RetSqlName("SA8")+" "
cQuery += "WHERE A8_COD = '"+cProd+"' AND A8_FILIAL = '"+xFilial('SA8')+"' AND D_E_L_E_T_ = '' "
cQuery += "GROUP BY A8_COD, A8_VLRVI, A8_PROCOM, A8_PERIOD ORDER BY 2 DESC "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)

Aadd(aRet,(cAliasTRB)->A8_COD)
Aadd(aRet,(cAliasTRB)->A8_VLRVI)
Aadd(aRet,(cAliasTRB)->A8_PERIOD)
Aadd(aRet,(cAliasTRB)->A8_PROCOM)

(cAliasTRB)->(DbCloseArea())

Return aRet
