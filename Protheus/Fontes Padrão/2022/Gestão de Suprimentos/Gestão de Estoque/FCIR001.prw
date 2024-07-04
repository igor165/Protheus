#include "FCIR001.CH"
#Include 'Protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FCIR001  ³ Autor ³ Materiais           ³ Data ³ 22/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio FCI Sintetico                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FCIR001()
Local oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Interface de impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef ³ Autor ³ Materiais 		     ³ Data ³ 22/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oSection1
Local oSection2
Local oReport 
Local oCell
Local nEspaco := 5
Local nTipo		:= 0

oReport := TReport():New("FCIR001","","FCR001"/*Pergunte*/,{|oReport| ReportPrint(oReport)}/*Bloco OK*/,STR0001)//"Este relatório tem como objetivo apresentar os valores sintéticos calculados na apuração do FCI."
oReport:SetEdit(.T.)

Pergunte("FCR001",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 1: Informacoes da Tabela SA8 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0002/*Descricao*/,{"SA8","SB1"})//"Pré-Apuração FCI"
oSection1:SetHeaderPage()
oSection1:SetReadOnly()
	
TRCell():New(oSection1,"A8_COD"		,"SA8"	,STR0003		,/*Picture*/,TamSX3("A8_COD")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Código"
TRCell():New(oSection1,"B1_DESC"	,"SB1"	,STR0004		,/*Picture*/,TamSX3("B1_DESC")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Descrição"
TRCell():New(oSection1,"B1_TIPO"	,"SB1"	,STR0025		,/*Picture*/,TamSX3("B1_TIPO")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Tipo"
TRCell():New(oSection1,"A8_PERIOD"	,"SA8"	,STR0005		,/*Picture*/,TamSX3("A8_PERIOD")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Periodo"
TRCell():New(oSection1,"A8_PROCOM"	,"SA8"	,STR0006		,/*Picture*/,14/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Origem"
TRCell():New(oSection1,"A8_VLRVI"	,"SA8"	,STR0007		,/*Picture*/,TamSX3("A8_VLRVI")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor VI"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 2: Informacoes da Tabela CFD ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oReport,STR0008/*Descricao*/,{"CFD","SB1"})//"Ficha de Conteúdo de Importação"
oSection2:SetHeaderPage()
oSection2:SetReadOnly()
	
TRCell():New(oSection2,"CFD_COD"		,"CFD"	,STR0009	,/*Picture*/,TamSX3("CFD_COD")[1]+nEspaco	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Código"
TRCell():New(oSection2,"B1_DESC"		,"SB1"	,STR0010	,/*Picture*/,TamSX3("B1_DESC")[1]+nEspaco	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Descrição"
TRCell():New(oSection2,"CFD_PERVEN"	,"CFD"	,STR0011	,/*Picture*/,TamSX3("CFD_PERVEN")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Per.Apur."
TRCell():New(oSection2,"CFD_PERCAL"	,"CFD"	,STR0012	,/*Picture*/,TamSX3("CFD_PERCAL")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Per.Fat."
TRCell():New(oSection2,"CFD_VPARIM"	,"CFD"	,STR0013	,/*Picture*/,TamSX3("CFD_VPARIM")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Parcela Imp."
TRCell():New(oSection2,"CFD_VSAIIE"	,"CFD"	,STR0014	,/*Picture*/,TamSX3("CFD_VSAIIE")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor Saídas"
TRCell():New(oSection2,"CFD_CONIMP"	,"CFD"	,STR0015	,/*Picture*/,TamSX3("CFD_CONIMP")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Cont. Import."
TRCell():New(oSection2,"CFD_ORIGEM"	,"CFD"	,STR0016	,/*Picture*/,TamSX3("CFD_ORIGEM")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Origem"
TRCell():New(oSection2,"CFD_FCICOD"	,"CFD"	,STR0017	,/*Picture*/,TamSX3("CFD_FCICOD")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Código FCI"

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
Static Function ReportPrint(oReport)

Local nTipo		:= mv_par01
Local cPrdDe		:= mv_par02
Local cPrdAte		:= mv_par03
Local cPeriod		:= mv_par04
Local cTpDe		:= mv_par05
Local cTpAte		:= mv_par06
Local oSection1	:= oReport:Section(1)
Local oSection2:= oReport:Section(2)
Local cQuery		:= ""
Local cAliasTRB	:= GetNextAlias()
Local cSelect	:=	''
Local cFrom		:=	''
Local cWhere	:=	''
Local cOrder	:=	''

If nTipo == 1 // Pre-apuracao
	oSection2:Hide()	// Deixo a Sessao 2 (Tabela CFD) invisivel
	If !oReport:Cancel()
		oReport:SetTitle(STR0018+STR0023)//"Relação FCI Sintético " // "(Pré-Apuração FCI)"
		cQuery := "SELECT A8_COD, B1_DESC, B1_TIPO, A8_PERIOD, A8_PROCOM,A8_VLRVI "
		cQuery += "FROM "+RetSqlName("SA8")+" SA8, "+RetSqlName("SB1")+" SB1 WHERE "
		cQuery += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
		cQuery += "A8_FILIAL = '"+xFilial("SA8")+"' AND "
		cQuery += "B1_COD = A8_COD AND "
		cQuery += "A8_COD >= '"+cPrdDe+"' AND "
		cQuery += "A8_COD <= '"+cPrdAte+"' AND "
		cQuery += "A8_PERIOD = '"+cPeriod+"' AND "
		cQuery += "B1_TIPO >= '"+cTpDe+"' AND "
		cQuery += "B1_TIPO <= '"+cTpAte+"' AND "
		cQuery += "SB1.D_E_L_E_T_ = '' AND "
		cQuery += "SA8.D_E_L_E_T_ = '' "
		cQuery += "ORDER BY A8_COD"	 
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
		
		oReport:SetMeter((cAliasTRB)->(LastRec()))
		oSection1:Init()
		While !(cAliasTRB)->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSection1:Cell("A8_COD"   ):setValue((cAliasTRB)->A8_COD)
			oSection1:Cell("B1_DESC"  ):setValue((cAliasTRB)->B1_DESC)
			oSection1:Cell("B1_TIPO"  ):setValue((cAliasTRB)->B1_TIPO)
			oSection1:Cell("A8_PERIOD"):setValue((cAliasTRB)->A8_PERIOD)
			oSection1:Cell("A8_VLRVI" ):setValue((cAliasTRB)->A8_VLRVI)
			If ((cAliasTRB)->A8_PROCOM) == "C"
				oSection1:Cell("A8_PROCOM"):setValue(STR0019)//"Comprado"
			ElseIf ((cAliasTRB)->A8_PROCOM) == "P"
				oSection1:Cell("A8_PROCOM"):setValue(STR0020)//"Produzido"
			EndIf
			oSection1:PrintLine()
			(cAliasTRB)->(dbSkip())
		EndDo		
		oSection1:Finish()
	EndIf
Else
	oSection1:Hide()	// Deixo a Sessao 1 (Tabela SA8) invisivel
	If !oReport:Cancel()
		oReport:SetTitle(STR0021+STR0024)//"Relação FCI Sintético " //"(Ficha de Conteúdo de Importação)"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³					  SELECT					³
		//³---------------------------------------------³
		//³TABELA CFD->	CFD_COD							³
		//³				CFD_PERVEN						³
		//³				CFD_PERCAL						³
		//³				CFD_VPARIM						³
		//³				CFD_VSAIIE						³
		//³				CFD_CONIMP						³
		//³				CFD_ORIGEM						³
		//³				CFD_FCICOD						³
		//³TABELA SB1->	B1_DESC							³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSelect	+=	"CFD_COD, B1_DESC, CFD_PERVEN, CFD_PERCAL, CFD_VPARIM, CFD_VSAIIE, CFD_CONIMP, CFD_ORIGEM, CFD_FCICOD"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³					  FROM						³
		//³---------------------------------------------³
		//³TABELA CFD -> FICHA DE CONTEUDO DE IMPORTACAO³
		//³TABELA SB1 -> CADASTRO DE PRODUTO ( JOIN )	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFrom	+=	RetSQLName( "CFD" ) + " CFD "
		cFrom	+=	"JOIN " + RetSQLName( "SB1" ) + " SB1 ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' AND SB1.B1_COD = CFD.CFD_COD AND SB1.D_E_L_E_T_ = '' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³					  WHERE						³
		//³---------------------------------------------³
		//³TABELA CFD->	CFD_FILIAL						³
		//³				CFD_COD ( DE - ATE )			³
		//³				CFD_PERVEN ( DENTRO PERIODO )	³
		//³				NOT D_E_L_E_T_					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere	+=	"CFD.CFD_FILIAL = '" + xFilial( "CFD" ) + "' AND "
		cWhere	+=	"CFD_COD >= '" + cPrdDe + "' AND "
		cWhere	+=	"CFD_COD <= '" + cPrdAte + "' AND "
		cWhere	+=	"CFD_PERVEN = '" + cPeriod + "' AND "
		cWhere	+=	"CFD.D_E_L_E_T_ = ''"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³					 ORDER BY					³
		//³---------------------------------------------³
		//³TABELA CFD -> CFD_COD						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOrder	+=	" ORDER BY CFD_COD "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define estrutura para execucao do BeginSQL	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSelect	:= "%"	+ cSelect + "%" 
		cFrom	:= "%"	+ cFrom + "%" 
		cWhere	:= "%"	+ cWhere + cOrder + "%"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Execucao do BeginSQL	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (TcSrvType ()<>"AS/400")
		
			BeginSql Alias cAliasTRB
				SELECT 
					%Exp:cSelect%
				FROM 
					%Exp:cFrom%
				WHERE 
					%Exp:cWhere%
			EndSql
		Endif
		
		oReport:SetMeter( ( cAliasTRB )->( LastRec() ) )
		
		oSection2:Init()
		
		While !( cAliasTRB )->( Eof() ) .And. !oReport:Cancel()
			
			oReport:IncMeter()
			
			If oReport:Cancel()
				Exit
			EndIf
			
			oSection2:Cell( "CFD_COD"		):setValue( ( cAliasTRB )->CFD_COD )
			oSection2:Cell( "B1_DESC"		):setValue( ( cAliasTRB )->B1_DESC )
			oSection2:Cell( "CFD_PERVEN"	):setValue( ( cAliasTRB )->CFD_PERVEN )
			oSection2:Cell( "CFD_PERCAL"	):setValue( ( cAliasTRB )->CFD_PERCAL )
			oSection2:Cell( "CFD_VPARIM"	):setValue( ( cAliasTRB )->CFD_VPARIM )
			oSection2:Cell( "CFD_VSAIIE"	):setValue( ( cAliasTRB )->CFD_VSAIIE )
			oSection2:Cell( "CFD_CONIMP"	):setValue( ( cAliasTRB )->CFD_CONIMP )
			oSection2:Cell( "CFD_ORIGEM"	):setValue( ( cAliasTRB )->CFD_ORIGEM )
			oSection2:Cell( "CFD_FCICOD"	):setValue( ( cAliasTRB )->CFD_FCICOD )
			
			oSection2:PrintLine()
			
			(cAliasTRB)->(dbSkip())
		EndDo		
		oSection2:Finish()
	Endif
Endif

Return


