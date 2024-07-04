#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "Report.ch"
#INCLUDE "HSPAHR82.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHR82 ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Consumo de Produtos por Paciente              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPAHR82()

Local oReport
 
Pergunte("HSPR82", .F.)
oReport := ReportDef() 
oReport:PrintDialog()  

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡…o ³ Impressao do relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef()

Local oReport 			// Objeto do relatorio
Local oSection1			// Objeto da secao 1 do relatorio
Local oSection2			// Objeto da secao 2 do relatorio
Local oSection3			// Objeto da secao 3 do relatorio
Local oSection4			// Objeto da secao 4 do relatorio
Local oSection5			// Objeto da secao 5 do relatorio
Local oCell				// Objeto das celulas
Local oTotaliz1			// Objeto totalizador do relatorio
Local oTotaliz2			// Objeto totalizador 2 do relatorio
Local nTotal	:= 0	// Totalizador da quantidade de produtos
Local nValor	:= 0	// Totalizador dos valores dos produtos
Local cCodDes	:= ""	// Variável para trazer o codigo do produto

oReport := TReport():New("HSPAHR82", STR0001, "HSPR82", {|oReport| R82IMP(oReport)}, STR0002 + " " + STR0003) //"RELATÓRIO DE CONSUMO DE PRODUTOS POR PACIENTE"###"Este programa tem como objetivo imprimir relatório "###"de acordo com os parâmetros informados pelo usuário."

oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, "", {"GCY"})

oSection1:SetHeaderBreak(.F.)	// Indica se cabecalho da secao sera impresso em cada quebra
oSection1:SetTotalInLine(.F.)	// Indica se o total da secao 1 vai ser impresso em linha
oSection1:SetHeaderPage(.T.)	// Indica que cabecalho da secao sera impresso no topo da pagina

oSection2 := TRSection():New(oSection1, "", {"GCY"})
oSection2:SetHeaderBreak(.F.)
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)     
oCell := TRCell():New(oSection2, "GCY_REGGER"	, "GCY", STR0019 ,, 20) //"Atend."
oCell := TRCell():New(oSection2, "GCY_NOME"  	, "GCY", STR0006 ,, 35) //"Nome"

oSection3 := TRSection():New(oSection2, "", {"GCY", "GBH","QRYR12"})
oSection3:SetHeaderPage(.T.) 
oSection3:SetHeaderBreak(.F.)
oSection3:SetTotalInLine(.F.)
oSection3:SetNoFilter({"QRYR82"})     
oCell := TRCell():New(oSection3, "GCY_DATATE"	, "GCY", STR0004 ,, 20) //"Dt. Atend"
oCell := TRCell():New(oSection3, "GCY_REGATE"	, "GCY", STR0018 ,, 20) //"Dt. Atend"
oCell := TRCell():New(oSection3, "GCY_CIDALT"	, "GCY", STR0007 ,, 10) //"CID"
oCell := TRCell():New(oSection3, "GAS_PATOLO"	, "GAS", STR0008 ,, 20) //"Descrição CID"

oSection4 := TRSection():New(oSection3, "", {"QRYR12"})                     
oSection4:SetHeaderPage(.T.) 
oSection4:SetHeaderBreak(.F.)
oSection4:SetTotalInLine(.F.)
oSection4:SetNoFilter({"QRYR82"})
oCell := TRCell():New(oSection4, "dDatDes"	, "GCY",STR0017,, 20,, {|| dDatDes := STOD(("QRYR82")->DATDES)}) //"Dt. Desp."

oSection5 := TRSection():New(oSection4, "", {"GCY", "GBH","QRYR12"})
oSection5:SetHeaderPage(.T.) 
oSection5:SetHeaderBreak(.F.)
oSection5:SetTotalInLine(.F.)
oSection5:SetNoFilter({"QRYR82"})
oCell := TRCell():New(oSection5, ""	 	        , ""      , ""		,			 , 20)						// Celula em Branco para alinhamento
oCell := TRCell():New(oSection5, "cCodDes"	 	,         , STR0010 ,			 , 30,,{||QRYR82->CODDES}) 	//"Cod Prod"
oCell := TRCell():New(oSection5, "B1_DESC"	 	, "SB1"   , STR0011 ,			 , 35) 						//"Descrição"
oCell := TRCell():New(oSection5, "nTotal"		,         , STR0012 ,"@E 9999"   , 10,,{||QRYR82->QTDDES}) 	//"Qtd Total"
oCell := TRCell():New(oSection5, ""	 	        , ""      , ""		,			 , 20)						// Celula em Branco para alinhamento
oCell := TRCell():New(oSection5, "nValor"		, "QRYR82", STR0013 ,"@E 9999.99", 10,,{||QRYR82->VALDES}) 	//"Val Tot Venda"

oSection3:SetTotalText(STR0016) //"Total Geral do Atendimento "

oSection5:SetTotalText(STR0014) //"Total Geral do Dia "                                                       

oSection2:SetTotalText(STR0009) //"Total Geral do Paciente "

oReport:SetTotalText(STR0015) //"Total Geral do Período "

oTotaliz1 := TRFunction():new(oSection5:Cell("nTotal"),,"SUM",,,"@E 9999"   ,,.T.,.T.,.F.)		//Imprime total dos valores por data e geral do periodo
oTotaliz1 := TRFunction():new(oSection5:Cell("nValor"),,"SUM",,,"@E 9999.99",,.T.,.T.,.F.)		//Imprime total das quantidades por data e geral do periodo

DEFINE FUNCTION FROM oSection5:Cell("nTotal")OF oSection2 FUNCTION SUM TITLE "" NO END REPORT	//Imprime total dos valores por paciente
DEFINE FUNCTION FROM oSection5:Cell("nValor")OF oSection2 FUNCTION SUM TITLE "" NO END REPORT	//Imprime total das quantidades por paciente                                                                                                                                          

DEFINE FUNCTION FROM oSection5:Cell("nTotal")OF oSection3 FUNCTION SUM TITLE "" NO END REPORT	//Imprime total dos valores por paciente
DEFINE FUNCTION FROM oSection5:Cell("nValor")OF oSection3 FUNCTION SUM TITLE "" NO END REPORT	//Imprime total das quantidades por paciente

Return(oReport)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R82Imp   ³ Autor ³ Saude                 ³ Data ³ 26/05/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Descri‡…o ³ Montagem da query e quebras do relatorio                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R82IMP(oReport)

Local oSection1 := oReport:Section(1)										// Vinculo da secao 1 com o objeto do relatorio
Local oSection2 := oReport:Section(1):Section(1)							// Vinculo da secao 2 com a secao 1 
Local oSection3 := oReport:Section(1):Section(1):Section(1)					// Vinculo da secao 3 com a secao 2 com a secao 1
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)		// Vinculo da secao 4 com a secao 3 com a secao 2 com a secao 1
Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)	// Vinculo da secao 5 com a secao 4 com a secao 3 com a secao 2 com a secao 1
Local cCondGD5	 := "% GCY_DATATE, GCY_REGATE, GCY_REGGER, GCY_NOME, GCY_CIDALT, GAS_PATOLO, GD5_DATDES DATDES, GD5_CODDES CODDES,GD5_QTDDES QTDDES," + HS_FValDes("GD5") + "VALDES, B1_DESC %"
Local cCondFrom := "", cCondWhere := "", cOrderBy := ""
//Local cCondGE5	:= "% GCY_DATATE, GCY_REGATE, GCY_REGGER, GCY_NOME, GCY_CIDALT, GAS_PATOLO, GE5_CODDES CODDES,GE5_QTDDES QTDDES," + HS_FValDes("GE5") + "VALDES, B1_DESC %"
 
cCondFrom := "% " + RetSqlName("GCY") + " GCY "
cCondFrom	+=	" LEFT JOIN " + RetSqlName("GAS") + " GAS ON GAS.GAS_FILIAL = '" + xFilial("GAS") + "' AND GAS.GAS_CODIGO = GCY.GCY_CIDALT AND GAS.D_E_L_E_T_ <> '*' "
cCondFrom	+=	" JOIN " + RetSqlName("GD5") + " GD5 ON GD5.GD5_FILIAL = '" + xFilial("GD5") + "' AND GD5.GD5_REGATE = GCY.GCY_REGATE AND GD5.D_E_L_E_T_ <> '*' " 
cCondFrom	+=	" JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_REGATE = GCY.GCY_REGATE "
cCondFrom	+=	" JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.GBI_PRODUT = GD5.GD5_CODDES AND GBI.GBI_PRODUT BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' AND GBI.D_E_L_E_T_ <> '*' "
cCondFrom	+=	" JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = GD5.GD5_CODDES AND SB1.D_E_L_E_T_ <> '*' "
cCondFrom	+=	" JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.GAW_CODGDE = GBI.GBI_CODGDE AND GAW.GAW_CODGDE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' AND GAW.D_E_L_E_T_ <> '*' %"
            
cCondWhere := "% GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
cCondWhere +=	"	AND GCY.GCY_REGATE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cCondWhere +=	"	AND GCY.GCY_CIDALT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cCondWhere +=	"	AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' %"
 
cOrderBy := "% GCY_REGGER, GCY_DATATE, GCY_REGATE, GD5_DATDES %"
 
MakeSqlExp("HSPR82")
oSection1:BeginQuery()

BeginSql Alias "QRYR82"

	SELECT %Exp:cCondGD5%
	FROM %Exp:cCondFrom%
	WHERE %Exp:cCondWhere%
	ORDER BY %Exp:cOrderBy%
 
EndSql

oSection1:EndQuery() 

oSection2:SetParentQuery()		// Controle da primeira quebra de pagina, de data do atendimento e registro do paciente
oSection2:SetParentFilter({|S| QRYR82->GCY_REGGER == S}, {|| QRYR82->GCY_REGGER})  

oSection3:SetParentQuery()		// Controle da primeira quebra de pagina, por registro do paciente + data de atendimento
oSection3:SetParentFilter({|X| QRYR82->GCY_REGGER == X}, {|| QRYR82->GCY_REGGER})

oSection4:SetParentQuery()		// Controle da segunda quebra por codigo do produto + registro do paciente + data do atendimento
oSection4:SetParentFilter({|L| QRYR82->GCY_REGATE + QRYR82->GCY_REGGER == L}, {|| QRYR82->GCY_REGATE + QRYR82->GCY_REGGER})                                         

oSection5:SetParentQuery()		// Controle da segunda quebra por codigo do produto + registro do paciente + data do atendimento
oSection5:SetParentFilter({|M| QRYR82->DATDES + QRYR82->GCY_REGATE == M}, {|| QRYR82->DATDES + QRYR82->GCY_REGATE})

oSection1:Print() 

Return(Nil)
