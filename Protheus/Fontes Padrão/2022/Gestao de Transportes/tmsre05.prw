#INCLUDE "TMSRE05.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSRE05  � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Pre-Fatura                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSRE05()

Local oReport
Local aArea := GetArea()

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSRE05                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry := GetNextAlias()
Local aOrdem    := {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("TMSRE05",STR0010,"TMRE05", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011) // "Lista de Pre-Faturas" ### "Este programa ir� imprimir uma rela��o de Pre-Faturas de acordo com os parametros do usuario."
oReport:SetTotalInLine(.F.)
oReport:SetLandscape(.T.)

//���������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                            �
//�����������������������������������������������������������������
//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                          �
//� mv_par01	// De Pre-Fatura                                   �
//� mv_par02	// Ate Pre-Fatura                                  �
//� mv_par03	// De Nota Fiscal                                  �
//� mv_par04	// Ate Nota Fiscal                                 �
//�����������������������������������������������������������������
Pergunte(oReport:uParam,.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
Aadd( aOrdem, STR0012 ) // "Remetente + Nota + Serie"

oPreFat:= TRSection():New(oReport,STR0013,{"DEB"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oPreFat:SetTotalInLine(.F.)
oPreFat:SetLineBreak(.T.)
TRCell():New(oPreFat,"DEB_CGCREM","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_DOC"   ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_SERIE" ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_CODDEP","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_NOMCLI","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_CODTRA","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_NUMPRE","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_TIPFRE","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_MODALI","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_DATVEN","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_VALBRT","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_DATINI","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_DATFIM","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_VLRBAC","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_VLRDSB","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_NUMPRO","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_CHAPA" ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_SAICTR","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_QTDVOL","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_PESO"  ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_VALOR" ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_FRTPES","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_TAXA"  ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_TRIBUT","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_PEDAG" ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_ADEME" ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_ICMS"  ,"DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_VALTOT","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_FRTURB","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_EMINFC","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_PESONF","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_VALMER","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_NUMROT","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DEB_CGCDES","DEB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPreFat,"DT6_VALTOT","DT6",STR0014   ,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| TMRE05Tot((cAliasQry)->DEB_CGCREM,(cAliasQry)->DEB_DOC,(cAliasQry)->DEB_SERIE) } )

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR490                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DEB_CGCREM, DEB_DOC   , DEB_SERIE , DEB_CODDEP, DEB_NOMCLI, DEB_CODTRA, DEB_NUMPRE, 
			 DEB_TIPFRE, DEB_MODALI, DEB_DATVEN, DEB_VALBRT, DEB_DATINI, DEB_DATFIM, DEB_VLRBAC,
			 DEB_VLRDSB, DEB_NUMPRO, DEB_CHAPA , DEB_SAICTR, DEB_QTDVOL, DEB_PESO  , DEB_VALOR ,
			 DEB_FRTPES, DEB_TAXA  , DEB_TRIBUT, DEB_PEDAG , DEB_ADEME , DEB_ICMS  , DEB_VALTOT,
			 DEB_FRTURB, DEB_EMINFC, DEB_PESONF, DEB_VALMER, DEB_NUMROT, DEB_CGCDES
		FROM %table:DEB% DEB
		WHERE DEB_FILIAL = %xFilial:DEB%
			AND DEB_NUMPRE BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DEB_DOC    BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND DEB.%NotDel%
	ORDER BY DEB_FILIAL, DEB_CGCREM, DEB_DOC, DEB_SERIE
EndSql 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DEB->(LastRec()))

oReport:Section(1):Print()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMRE05Tot� Autor �Eduardo de Souza       � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valor Total do documento                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: CGC do Remetente                                     ���
���          �ExpC2: Nota Fiscal                                          ���
���          �ExpC3: Serie                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR490                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMRE05Tot(cCgcRem,cDocto,cSerie)

Local cCliRem := Posicione("SA1",3,xFilial("SA1")+cCgcRem,"A1_COD")
Local cLojRem := SA1->A1_LOJA
Local cFilDoc := Posicione("DTC",2,xFilial("DTC")+cDocto+cSerie+cCliRem+cLojRem,"DTC_FILDOC")
Local cDoc    := DTC->DTC_DOC
Local cSer    := DTC->DTC_SERIE

Return Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSer,"DT6_VALTOT")