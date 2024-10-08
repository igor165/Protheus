#INCLUDE "CTBR650.CH"

STATIC _oCtbr650

// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR650	� Autor � Cicero J. Silva	    � Data � 01.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio do Cadastro de Historico (CT8)                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR650(void)											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum        											  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGACTB  												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum         											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr650()

Local aArea := GetArea()
Local oReport

PRIVATE cPerg    := "CTR650"
PRIVATE nomeprog := "CTBR650"

Pergunte(cPerg,.F.) // Precisa ativar as perguntas antes das definicoes.

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Cicero J. Silva    � Data �  01/08/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1
Local aOrdem := {}
Local cAliasCT8 := GetNextAlias()

oReport:= TReport():New(nomeprog,STR0003,cPerg, {|oReport| ReportPrint(oReport,cAliasCT8,aOrdem)},STR0001+" "+STR0002)// "Este programa ira emitir o cadastro de Historico."
oReport:SetLandscape()
oReport:SetPortrait(.T.)

Aadd( aOrdem, STR0009 ) // "Por Codigo"
Aadd( aOrdem, STR0010 ) // "Por Descri��o"

oSection1 := TRSection():New(oReport,STR0003,{"CT8"},aOrdem) //"Relacao de Pedidos de Compras"
oSection1 :SetHeaderPage()

TRCell():New(oSection1,"CT8_HIST"	,"CT8",STR0009,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CT8_IDENT"	,"CT8",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CT8_DESC"	,"CT8",STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CT8_SEQUEN"	,"CT8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection1:Cell("CT8_SEQUEN"):Disable()

Return oReport

Static Function ReportPrint(oReport,cAliasCT8,aOrdem)

Local oSection1 := oReport:Section(1)
Local nOrdem    := oReport:Section(1):GetOrder()
Local cWhere := ""

dbSelectArea("CT8")
dbSetOrder(nOrdem)

oReport:SetTitle( oReport:Title()+STR0013+ aOrdem[nOrdem] ) // " - POR CODIGO / DESCRICAO"

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

cWhere :="%"
cWhere += ""
cWhere +="%"

BeginSql Alias cAliasCT8

SELECT CT8.*

FROM %table:CT8% CT8

WHERE CT8_FILIAL = %xFilial:CT8% AND
      CT8_SEQUEN = '000001' AND
	  CT8_HIST BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	  CT8.%NotDel%
	  %Exp:cWhere%

ORDER BY %Order:CT8%

EndSql

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
oReport:SetMeter(CT8->(LastRec()))

oSection1:Print()

Return NIL