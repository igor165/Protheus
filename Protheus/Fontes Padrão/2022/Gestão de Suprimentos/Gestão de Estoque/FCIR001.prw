#include "FCIR001.CH"
#Include 'Protheus.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FCIR001  � Autor � Materiais           � Data � 22/04/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio FCI Sintetico                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FCIR001()
Local oReport

//������������������������Ŀ
//� Interface de impressao �
//��������������������������
oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportDef � Autor � Materiais 		     � Data � 22/04/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oSection1
Local oSection2
Local oReport 
Local oCell
Local nEspaco := 5
Local nTipo		:= 0

oReport := TReport():New("FCIR001","","FCR001"/*Pergunte*/,{|oReport| ReportPrint(oReport)}/*Bloco OK*/,STR0001)//"Este relat�rio tem como objetivo apresentar os valores sint�ticos calculados na apura��o do FCI."
oReport:SetEdit(.T.)

Pergunte("FCR001",.F.)

//�������������������������������������Ŀ
//� Sessao 1: Informacoes da Tabela SA8 �
//���������������������������������������
oSection1 := TRSection():New(oReport,STR0002/*Descricao*/,{"SA8","SB1"})//"Pr�-Apura��o FCI"
oSection1:SetHeaderPage()
oSection1:SetReadOnly()
	
TRCell():New(oSection1,"A8_COD"		,"SA8"	,STR0003		,/*Picture*/,TamSX3("A8_COD")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"C�digo"
TRCell():New(oSection1,"B1_DESC"	,"SB1"	,STR0004		,/*Picture*/,TamSX3("B1_DESC")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Descri��o"
TRCell():New(oSection1,"B1_TIPO"	,"SB1"	,STR0025		,/*Picture*/,TamSX3("B1_TIPO")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Tipo"
TRCell():New(oSection1,"A8_PERIOD"	,"SA8"	,STR0005		,/*Picture*/,TamSX3("A8_PERIOD")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Periodo"
TRCell():New(oSection1,"A8_PROCOM"	,"SA8"	,STR0006		,/*Picture*/,14/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Origem"
TRCell():New(oSection1,"A8_VLRVI"	,"SA8"	,STR0007		,/*Picture*/,TamSX3("A8_VLRVI")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor VI"

//�������������������������������������Ŀ
//� Sessao 2: Informacoes da Tabela CFD �
//���������������������������������������
oSection2 := TRSection():New(oReport,STR0008/*Descricao*/,{"CFD","SB1"})//"Ficha de Conte�do de Importa��o"
oSection2:SetHeaderPage()
oSection2:SetReadOnly()
	
TRCell():New(oSection2,"CFD_COD"		,"CFD"	,STR0009	,/*Picture*/,TamSX3("CFD_COD")[1]+nEspaco	,/*lPixel*/,/*{|| code-block de impressao }*/)//"C�digo"
TRCell():New(oSection2,"B1_DESC"		,"SB1"	,STR0010	,/*Picture*/,TamSX3("B1_DESC")[1]+nEspaco	,/*lPixel*/,/*{|| code-block de impressao }*/)//"Descri��o"
TRCell():New(oSection2,"CFD_PERVEN"	,"CFD"	,STR0011	,/*Picture*/,TamSX3("CFD_PERVEN")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Per.Apur."
TRCell():New(oSection2,"CFD_PERCAL"	,"CFD"	,STR0012	,/*Picture*/,TamSX3("CFD_PERCAL")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/)//"Per.Fat."
TRCell():New(oSection2,"CFD_VPARIM"	,"CFD"	,STR0013	,/*Picture*/,TamSX3("CFD_VPARIM")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Parcela Imp."
TRCell():New(oSection2,"CFD_VSAIIE"	,"CFD"	,STR0014	,/*Picture*/,TamSX3("CFD_VSAIIE")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor Sa�das"
TRCell():New(oSection2,"CFD_CONIMP"	,"CFD"	,STR0015	,/*Picture*/,TamSX3("CFD_CONIMP")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Cont. Import."
TRCell():New(oSection2,"CFD_ORIGEM"	,"CFD"	,STR0016	,/*Picture*/,TamSX3("CFD_ORIGEM")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Origem"
TRCell():New(oSection2,"CFD_FCICOD"	,"CFD"	,STR0017	,/*Picture*/,TamSX3("CFD_FCICOD")[1]+nEspaco,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"C�digo FCI"

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportPrint � Autor � Materiais        � Data � 22/04/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Impressao do relatorio                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		oReport:SetTitle(STR0018+STR0023)//"Rela��o FCI Sint�tico " // "(Pr�-Apura��o FCI)"
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
		oReport:SetTitle(STR0021+STR0024)//"Rela��o FCI Sint�tico " //"(Ficha de Conte�do de Importa��o)"
		//���������������������������������������������Ŀ
		//�					  SELECT					�
		//�---------------------------------------------�
		//�TABELA CFD->	CFD_COD							�
		//�				CFD_PERVEN						�
		//�				CFD_PERCAL						�
		//�				CFD_VPARIM						�
		//�				CFD_VSAIIE						�
		//�				CFD_CONIMP						�
		//�				CFD_ORIGEM						�
		//�				CFD_FCICOD						�
		//�TABELA SB1->	B1_DESC							�
		//�����������������������������������������������
		cSelect	+=	"CFD_COD, B1_DESC, CFD_PERVEN, CFD_PERCAL, CFD_VPARIM, CFD_VSAIIE, CFD_CONIMP, CFD_ORIGEM, CFD_FCICOD"
		//���������������������������������������������Ŀ
		//�					  FROM						�
		//�---------------------------------------------�
		//�TABELA CFD -> FICHA DE CONTEUDO DE IMPORTACAO�
		//�TABELA SB1 -> CADASTRO DE PRODUTO ( JOIN )	�
		//�����������������������������������������������
		cFrom	+=	RetSQLName( "CFD" ) + " CFD "
		cFrom	+=	"JOIN " + RetSQLName( "SB1" ) + " SB1 ON SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' AND SB1.B1_COD = CFD.CFD_COD AND SB1.D_E_L_E_T_ = '' "
		//���������������������������������������������Ŀ
		//�					  WHERE						�
		//�---------------------------------------------�
		//�TABELA CFD->	CFD_FILIAL						�
		//�				CFD_COD ( DE - ATE )			�
		//�				CFD_PERVEN ( DENTRO PERIODO )	�
		//�				NOT D_E_L_E_T_					�
		//�����������������������������������������������
		cWhere	+=	"CFD.CFD_FILIAL = '" + xFilial( "CFD" ) + "' AND "
		cWhere	+=	"CFD_COD >= '" + cPrdDe + "' AND "
		cWhere	+=	"CFD_COD <= '" + cPrdAte + "' AND "
		cWhere	+=	"CFD_PERVEN = '" + cPeriod + "' AND "
		cWhere	+=	"CFD.D_E_L_E_T_ = ''"
		//���������������������������������������������Ŀ
		//�					 ORDER BY					�
		//�---------------------------------------------�
		//�TABELA CFD -> CFD_COD						�
		//�����������������������������������������������
		cOrder	+=	" ORDER BY CFD_COD "
		//���������������������������������������������Ŀ
		//�Define estrutura para execucao do BeginSQL	�
		//�����������������������������������������������
		cSelect	:= "%"	+ cSelect + "%" 
		cFrom	:= "%"	+ cFrom + "%" 
		cWhere	:= "%"	+ cWhere + cOrder + "%"
		//���������������������Ŀ
		//�Execucao do BeginSQL	�
		//�����������������������
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


