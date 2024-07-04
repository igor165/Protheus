#include "FCIR002.CH"
#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FCIR002  ³ Autor ³ Materiais           ³ Data ³ 23/06/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio FCI Sintetico                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCIR002()
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
Local nEspaco := 5
Local nTipo		:= 0
Local cAliasTRB := GetNextAlias()

oReport := TReport():New("FCIR002","","FCR002"/*Pergunte*/,{|oReport| ReportPrint(oReport,cAliasTRB)}/*Bloco OK*/,STR0001)//"Este relatório tem como objetivo apresentar os valores analíticos calculados na apuração do FCI para as Notas Fiscais de Entrada."
oReport:SetTitle(STR0002)//"Relação FCI Analítica - NF de Entrada"
oReport:SetLandscape()
oReport:DisableOrientation()

Pergunte("FCR002",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 1: Itens das Notas Fiscais   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0003,{"SD1","SB1",cAliasTRB})//"Itens das Notas Fiscais"
oSection1:SetHeaderPage()
oSection1:SetReadOnly()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueia a edicao de celulas e filtros do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetEditCell(.F.)
oSection1:SetNoFilter("SD1")
oSection1:SetNoFilter("SB1")
	
TRCell():New(oSection1,"D1_COD"		,"SD1"	   ,STR0004,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Código"
TRCell():New(oSection1,"B1_DESC"	,"SB1"	   ,STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Descrição"
TRCell():New(oSection1,"D1_FORNECE","SD1"	   ,STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Forn."
TRCell():New(oSection1,"D1_LOJA"   ,"SD1"	   ,STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Loja"
TRCell():New(oSection1,"D1_DOC"    ,"SD1"	   ,STR0008,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"NF Num."
TRCell():New(oSection1,"D1_SERIE"  ,"SD1"	   ,STR0009,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Série"
TRCell():New(oSection1,"D1_TIPO"   ,"SD1"	   ,STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Tipo"
TRCell():New(oSection1,"D1_DTDIGIT","SD1"	   ,STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Dt. Ent."
TRCell():New(oSection1,"D1_CLASFIS","SD1"	   ,STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Sit. Trib"
TRCell():New(oSection1,"D1_TOTAL"  ,"SD1"	   ,STR0013,PesqPict("SD1","D1_TOTAL"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Total NF"
TRCell():New(oSection1,"D1_VALFRE" ,"SD1"	   ,STR0014,PesqPict("SD1","D1_VALFRE"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Frete"
TRCell():New(oSection1,"D1_SEGURO" ,"SD1"	   ,STR0015,PesqPict("SD1","D1_SEGURO"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Seguro"
TRCell():New(oSection1,"D1_II"     ,"SD1"	   ,STR0016,PesqPict("SD1","D1_II"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"I.I."
TRCell():New(oSection1,"D1_VALICM" ,"SD1"	   ,STR0017,PesqPict("SD1","D1_VALICM"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"ICMS"
TRCell():New(oSection1,"D1_VALIPI" ,"SD1"	   ,STR0023,PesqPict("SD1","D1_VALIPI"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"IPI"
TRCell():New(oSection1,"QUANTIDADE",cAliasTRB,STR0018,PesqPict("SD1","D1_QUANT"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Quant. (A)"
TRCell():New(oSection1,"VI"        ,cAliasTRB,STR0019,PesqPict("SA8","A8_VLRVI"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Vl. Imp. (B)"
TRCell():New(oSection1,"VI_UN"     ,cAliasTRB,STR0020,PesqPict("SA8","A8_VLRVI"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Vl. Imp.UN (C)"

Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportPrint ³ Autor ³ Materiais        ³ Data ³ 22/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport,cAliasTRB)

Local cPrdDe		:= mv_par01
Local cPrdAte		:= mv_par02
Local cPeriod		:= Substr(Alltrim(mv_par03),3,6) + Substr(Alltrim(mv_par03),1,2)
Local lFCIComp		:= SuperGetMV("MV_FCICOMP",.F.,.F.)       // Indica se considera NF's de Complemento de Preco
Local cFCICF		:= AllTrim(SuperGetMV("MV_FCICF",.F.,"")) // Parametro para filtrar CFOP's que nao serao processadas
Local cFuncNull		:= ""
Local cQuery		:= ""
Local cProdAtu		:= ""
Local cProdAnt		:= ""
Local lImpComp		:= .F.
Local cDbType		:= TCGetDB()
Local cAliasCp		:= GetNextAlias()
Local oSection1		:= oReport:Section(1)
Local lSigaEIC		:= (GetNewPar("MV_EASY",.F.) == "S")
Local cFuncSubst	:= "SUBSTRING"
Local oBreak01

oReport:SetTitle(STR0021+Substr(Alltrim(mv_par03),1,2)+"/"+Substr(Alltrim(mv_par03),3,6)+")")//"Relação FCI Analítica - NF de Entrada (Periodo: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ATENCAO: A impressao deste relatorio foi dividida em duas querys (NF e Complementos) para ³
//³ manter a mesma logica utilizada no processamento das Notas Fiscais de Entradas realizadas ³
//³ na funcao FciMedEnt() do fonte FCIXFUN.PRW. Caso seja necessario alterar a logica do cal- ³
//³ culo no relatorio, deve-se avaliar a necessidade de alteracao da funcao FciMedEnt() e     ³
//³ vice-versa.                                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quebra de secoes e totalizadores do Relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBreak01 := TRBreak():New(oSection1,oSection1:Cell("D1_COD"),STR0022,.F.)//"Total do Produto (C = B / A)"
TRFunction():New(oSection1:Cell('QUANTIDADE'),"TOTQT","SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection1:Cell('VI'        ),"TOTVI","SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection1:Cell('VI_UN'     ),NIL,"ONPRINT",oBreak01,/*Titulo*/,/*cPicture*/,{|lSection,lReport,lPage| oSection1:GetFunction("TOTVI"):GetValue() / oSection1:GetFunction("TOTQT"):GetValue()},.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para ISNULL em diferentes BD's ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para SUBSTRING em diferentes BD's ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDbType $ "ORACLE/POSTGRES/DB2"
	cFuncSubst  := "SUBSTR"
EndIf

If !oReport:Cancel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo com Entradas do Periodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT SUM(SD1.D1_QUANT) AS QUANTIDADE, "
	cQuery += "SUM(CASE "
	// Fator Agrega Valor (VL)
	cQuery += "WHEN SF4.F4_AGREG IN ('I','S') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_II)) "
	If lSigaEIC
		cQuery += "WHEN SF4.F4_AGREG IN ('C','B') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)- " + cFuncNull + " (SWN.WN_IIVAL+SWN.WN_DESPADU,SD1.D1_II)) "
	EndIf
	cQuery += "WHEN SF4.F4_AGREG IN ('A','N','R') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)) "
	cQuery += "WHEN SF4.F4_AGREG = 'H' AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_ICMSRET)) "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_VALICM)) "
	cQuery += "ELSE ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_VALICM+SD1.D1_II)) END"
	// Fator Situacao Tributaria (FST)
	cQuery += "*(CASE "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '3' THEN 0.5 "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '8' THEN 1 "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '2' THEN 1 "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '1' THEN 1 ELSE 0 END)) AS VI, "
	// Fim (VL)+(FST)                                    
	cQuery += "SD1.D1_COD,"
	// --------- Diferenca FCIXFUN ---------
	cQuery += "SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_CLASFIS,SD1.D1_TIPO,"
	cQuery += "SD1.D1_DTDIGIT,SD1.D1_TOTAL,SD1.D1_VALFRE,SD1.D1_SEGURO,SD1.D1_II,SD1.D1_VALICM,SD1.D1_VALIPI "
	// --------- Diferenca FCIXFUN ---------
	cQuery += "FROM "+RetSqlName("SD1")+" SD1 JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial('SF4')+"' "
	cQuery += "AND SF4.F4_CODIGO = SD1.D1_TES "
	cQuery += "AND SF4.D_E_L_E_T_ = '' "  
	If lSigaEIC
		cQuery += "LEFT JOIN " + RetSqlName ("SWN") + " SWN ON SWN.WN_FILIAL = SD1.D1_FILIAL "
		cQuery += "AND SWN.WN_DOC = SD1.D1_DOC AND SWN.WN_SERIE = SD1.D1_SERIE AND (SWN.WN_TEC||SWN.WN_EX_NCM||SWN.WN_EX_NBM) = SD1.D1_TEC "
		cQuery += "AND SWN.WN_FORNECE = SD1.D1_FORNECE AND SWN.WN_LOJA = SD1.D1_LOJA AND SWN.WN_PRODUTO = SD1.D1_COD AND SWN.WN_LINHA = CAST(SD1.D1_ITEM AS DECIMAL(20)) "
		cQuery += " AND SWN.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND "+cFuncSubst+"(SD1.D1_DTDIGIT,1,6) = '"+cPeriod
	cQuery += "' AND SD1.D_E_L_E_T_ = '' AND SD1.D1_COD >= '"+cPrdDe+"' AND SD1.D1_COD <= '"+cPrdAte+"'"+" AND SD1.D1_TIPO = 'N' "
	cQuery += " AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('1','2','3','8') "
	If !Empty(cFCICF)
		cQuery += "AND SD1.D1_CF NOT IN ("+cFCICF+") "
	EndIf
	cQuery += "GROUP BY SD1.D1_COD,"
	// --------- Diferenca FCIXFUN ---------
	cQuery += "SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_CLASFIS,SD1.D1_TIPO,"
	cQuery += "SD1.D1_DTDIGIT,SD1.D1_TOTAL,SD1.D1_VALFRE,SD1.D1_SEGURO,SD1.D1_II,SD1.D1_VALICM,SD1.D1_VALIPI "
	cQuery += "ORDER BY 3, 6, 7, 4, 5"
	// --------- Diferenca FCIXFUN ---------
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo com Complementos do Periodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFCIComp
		cQuery := "SELECT SUM(SD1C.D1_QUANT) AS QUANTIDADE, SUM(CASE "
		// Fator Agrega Valor (VL)
		cQuery += "WHEN SF4.F4_AGREG IN ('I','S') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_II)) "
		If lSigaEIC
			cQuery += "WHEN SF4.F4_AGREG IN ('C','B') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)- "+cFuncNull+" (SWN.WN_IIVAL+SWN.WN_DESPADU,SD1C.D1_II)) "
		EndIf
		cQuery += "WHEN SF4.F4_AGREG IN ('A','N','R') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)) "
		cQuery += "WHEN SF4.F4_AGREG = 'H' AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_ICMSRET)) "
		cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_VALICM)) "
		cQuery += "ELSE ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_VALICM+SD1.D1_II)) END*"
		// Fator Situacao Tributaria (FST)
		cQuery += "(CASE "
		cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '3' THEN 0.5 "
		cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '8' THEN 1 "
		cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '2' THEN 1 "
		cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '1' THEN 1 ELSE 0 END)) AS VI, "
		// Fim (VL)+(FST) 
		cQuery += "SD1C.D1_COD, "
		// --------- Diferenca FCIXFUN ---------
		cQuery += "SD1C.D1_DOC,SD1C.D1_SERIE,SD1C.D1_FORNECE,SD1C.D1_LOJA,SD1C.D1_CLASFIS,SD1C.D1_TIPO,"
		cQuery += "SD1C.D1_DTDIGIT,SD1C.D1_TOTAL,SD1C.D1_VALFRE,SD1C.D1_SEGURO,SD1C.D1_II,SD1C.D1_VALICM,SD1C.D1_VALIPI "
		// --------- Diferenca FCIXFUN ---------
		cQuery += "FROM "+RetSqlName("SD1")+" SD1 JOIN "+RetSqlName("SF4")+" SF4 ON "
		cQuery += "SF4.F4_FILIAL = '"+xFilial('SF4')+"' AND "
		cQuery += "SF4.F4_CODIGO = SD1.D1_TES AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += "RIGHT JOIN "+RetSqlName("SD1")+" SD1C ON "
		cQuery += "SD1.D1_DOC = SD1C.D1_NFORI AND "
		cQuery += "SD1.D1_SERIE = SD1C.D1_SERIORI AND "
		cQuery += "SD1.D1_COD = SD1C.D1_COD AND "
		cQuery += "SD1.D1_FORNECE = SD1C.D1_FORNECE AND "
		cQuery += "SD1.D1_LOJA = SD1C.D1_LOJA "
		If lSigaEIC
			cQuery += "LEFT JOIN "+RetSqlName("SWN")+" SWN ON SWN.WN_FILIAL = SD1C.D1_FILIAL "
			cQuery += "AND SWN.WN_DOC = SD1C.D1_DOC AND SWN.WN_SERIE = SD1C.D1_SERIE AND (SWN.WN_TEC||SWN.WN_EX_NCM||SWN.WN_EX_NBM) = SD1C.D1_TEC "
			cQuery += "AND SWN.WN_FORNECE = SD1C.D1_FORNECE AND SWN.WN_LOJA = SD1C.D1_LOJA AND SWN.WN_PRODUTO = "
			cQuery += "SD1C.D1_COD AND SWN.WN_LINHA = CAST(SD1C.D1_ITEM AS DECIMAL(20)) AND SWN.D_E_L_E_T_ = ' ' "
		EndIf	
		cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND "
		cQuery += ""+cFuncSubst+"(SD1.D1_DTDIGIT,1,6) = '"+cPeriod+"' AND "
		cQuery += "SD1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SD1C.D_E_L_E_T_ = ' ' AND "
		cQuery += "SD1.D1_TIPO = 'N' AND "
		cQuery += cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('1','2','3','8') AND "
		If !Empty(cFCICF)
			cQuery += "SD1.D1_CF NOT IN ("+cFCICF+") AND SD1C.D1_CF NOT IN ("+cFCICF+") AND "
		EndIf
		cQuery += "SD1C.D1_TIPO = 'C' GROUP BY SD1C.D1_COD, "
		// --------- Diferenca FCIXFUN ---------
		cQuery += "SD1C.D1_DOC, SD1C.D1_SERIE, SD1C.D1_FORNECE, SD1C.D1_LOJA, SD1C.D1_CLASFIS,SD1C.D1_TIPO, "
		cQuery += "SD1C.D1_DTDIGIT,SD1C.D1_TOTAL,SD1C.D1_VALFRE,SD1C.D1_SEGURO,SD1C.D1_II,SD1C.D1_VALICM,SD1C.D1_VALIPI "
		cQuery += "ORDER BY 3, 6, 7, 4, 5"
		// --------- Diferenca FCIXFUN ---------
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCp,.T.,.T.)
	
	EndIf
	
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	cProdAnt := (cAliasTRB)->D1_COD
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da Impressao do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter((cAliasTRB)->(LastRec()))
	oSection1:Init()
	While !(cAliasTRB)->(Eof()) .And. !oReport:Cancel()
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		
		oSection1:Cell("D1_COD"    ):setValue((cAliasTRB)->D1_COD)
		If SB1->(MsSeek(xFilial('SB1')+(cAliasTRB)->D1_COD))
			oSection1:Cell("B1_DESC"   ):setValue(SB1->B1_DESC)
		EndIf
		oSection1:Cell("QUANTIDADE"):setValue((cAliasTRB)->QUANTIDADE)
		oSection1:Cell("VI"        ):setValue((cAliasTRB)->VI)
		oSection1:Cell("VI_UN"     ):setValue((cAliasTRB)->VI/(cAliasTRB)->QUANTIDADE)
		oSection1:Cell("D1_FORNECE"):setValue((cAliasTRB)->D1_FORNECE)
		oSection1:Cell("D1_LOJA"   ):setValue((cAliasTRB)->D1_LOJA)
		oSection1:Cell("D1_DOC"    ):setValue((cAliasTRB)->D1_DOC)
		oSection1:Cell("D1_SERIE"  ):setValue((cAliasTRB)->D1_SERIE)
		oSection1:Cell("D1_TIPO"   ):setValue((cAliasTRB)->D1_TIPO)
		oSection1:Cell("D1_DTDIGIT"):setValue(StoD((cAliasTRB)->D1_DTDIGIT))
		oSection1:Cell("D1_CLASFIS"):setValue((cAliasTRB)->D1_CLASFIS)
		oSection1:Cell("D1_TOTAL"  ):setValue((cAliasTRB)->D1_TOTAL)
		oSection1:Cell("D1_VALFRE" ):setValue((cAliasTRB)->D1_VALFRE)
		oSection1:Cell("D1_SEGURO" ):setValue((cAliasTRB)->D1_SEGURO)
		oSection1:Cell("D1_II"     ):setValue((cAliasTRB)->D1_II)
		oSection1:Cell("D1_VALICM" ):setValue((cAliasTRB)->D1_VALICM)
		oSection1:Cell("D1_VALIPI" ):setValue((cAliasTRB)->D1_VALIPI)
		oSection1:PrintLine()
		(cAliasTRB)->(dbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para impressao dos Complementos sempre no final  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProdAtu := (cAliasTRB)->D1_COD
		If cProdAnt <> cProdAtu
			lImpComp := .T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Complementos do Periodo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFCIComp .And. lImpComp
			While !(cAliasCp)->(Eof()) .And. cProdAnt == (cAliasCp)->D1_COD .And. !oReport:Cancel()
				oSection1:Cell("D1_COD"    ):setValue((cAliasCp)->D1_COD)
				If SB1->(MsSeek(xFilial('SB1')+(cAliasCp)->D1_COD))
					oSection1:Cell("B1_DESC"   ):setValue(SB1->B1_DESC)
				EndIf
				oSection1:Cell("QUANTIDADE"):setValue((cAliasCp)->QUANTIDADE)
				oSection1:Cell("VI"        ):setValue((cAliasCp)->VI)
				oSection1:Cell("VI_UN"     ):setValue((cAliasCp)->VI/(cAliasCp)->QUANTIDADE)
				oSection1:Cell("D1_FORNECE"):setValue((cAliasCp)->D1_FORNECE)
				oSection1:Cell("D1_LOJA"   ):setValue((cAliasCp)->D1_LOJA)
				oSection1:Cell("D1_DOC"    ):setValue((cAliasCp)->D1_DOC)
				oSection1:Cell("D1_SERIE"  ):setValue((cAliasCp)->D1_SERIE)
				oSection1:Cell("D1_TIPO"   ):setValue((cAliasCp)->D1_TIPO)
				oSection1:Cell("D1_DTDIGIT"):setValue(StoD((cAliasCp)->D1_DTDIGIT))
				oSection1:Cell("D1_CLASFIS"):setValue((cAliasCp)->D1_CLASFIS)
				oSection1:Cell("D1_TOTAL"  ):setValue((cAliasCp)->D1_TOTAL)
				oSection1:Cell("D1_VALFRE" ):setValue((cAliasCp)->D1_VALFRE)
				oSection1:Cell("D1_SEGURO" ):setValue((cAliasCp)->D1_SEGURO)
				oSection1:Cell("D1_II"     ):setValue((cAliasCp)->D1_II)
				oSection1:Cell("D1_VALICM" ):setValue((cAliasCp)->D1_VALICM)
				oSection1:Cell("D1_VALIPI" ):setValue((cAliasCp)->D1_VALIPI)
				oSection1:PrintLine()
				(cAliasCp)->(dbSkip())
			EndDo
			cProdAnt := cProdAtu
			lImpComp := .F.		
		EndIf
		
	EndDo		
	oSection1:Finish()
EndIf

(cAliasTRB)->(DbCloseArea())
If lFCIComp
	(cAliasCp)->(DbCloseArea())
EndIf

Return

