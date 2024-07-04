#INCLUDE "TMSR350.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR350  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Enderecos para Embarque                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR350()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR350                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oFilDes
Local oEnder
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()

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
oReport:= TReport():New("TMSR350",STR0014,"TMR350", {|oReport| ReportPrint(oReport,cAliasQry)},STR0015) // "Relacao de Enderecos para Embarque" ### "Emite Relacao de Enderecos para Embarque conforme os parametros informados"
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
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
Aadd( aOrdem, STR0016 ) // "Filial Destino + Regi�o Origem"

oFilDes := TRSection():New(oReport,STR0017,{"DUH"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Filial Destino"
oFilDes:SetPageBreak(.T.)
oFilDes:SetTotalInLine(.F.)
TRCell():New(oFilDes,"DUH_FILDES","DUH",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilDes,"DES.FILIAL",""   ,STR0018,""        ,15         ,          , {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DUH_FILDES,"M0_FILIAL") }) // 'Regi�o Origem'

oEnder := TRSection():New(oFilDes,STR0019,{"DUH","SBE","DUY","DTC"},/*Array com as Ordens do relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Endere�os"
oEnder:SetTotalInLine(.F.)
TRCell():New(oEnder,"DUY_DESCRI","DUY",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"DUH_LOCAL" ,"DUH",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"DUH_LOCALI","DUH",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"QTDNFC"    ," "  ,STR0020   ,/*Picture*/,4          ,/*lPixel*/,/*{|| code-block de impressao }*/) // "Notas"
TRCell():New(oEnder,"QTDDOC"    ," "  ,STR0021   ,/*Picture*/,4          ,/*lPixel*/,/*{|| code-block de impressao }*/) // "Documentos"
TRCell():New(oEnder,"DTC_QTDVOL","DTC",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"BE_DATGER" ,"SBE",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"BE_HORGER" ,"SBE",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"DTC_PESO"  ,"DTC",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnder,"DTC_VALOR" ,"DTC",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oEnder:Cell("QTDNFC"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEnder:Cell("QTDDOC"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEnder:Cell("DTC_QTDVOL"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEnder:Cell("DTC_PESO"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oEnder:Cell("DTC_VALOR" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2)

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DUH_FILDES, MAX(DUY_DESCRI) DUY_DESCRI, DUH_LOCAL, DUH_LOCALI, 
	       SUM(DTC_QTDVOL) DTC_QTDVOL, MAX(BE_DATGER) BE_DATGER, MAX(BE_HORGER) BE_HORGER,
	       SUM(DTC_PESO) DTC_PESO, SUM(DTC_VALOR) DTC_VALOR, 
	       COUNT(QTDNFC) QTDNFC, COUNT(DTC_DOC) QTDDOC
		FROM (
		SELECT DUH_FILDES, MAX(DUY_DESCRI) DUY_DESCRI, DUH_LOCAL, DUH_LOCALI, 
		       SUM(DTC_QTDVOL) DTC_QTDVOL, MAX(BE_DATGER) BE_DATGER, MAX(BE_HORGER) BE_HORGER,
		       SUM(DTC_PESO) DTC_PESO, SUM(DTC_VALOR) DTC_VALOR, COUNT(DTC_NUMNFC) QTDNFC, DTC_DOC
			FROM (
				SELECT DUH_FILDES, MIN(DUY_DESCRI) DUY_DESCRI, DUH_LOCAL, DUH_LOCALI, 
				       SUM(DTC_QTDVOL) DTC_QTDVOL, MAX(BE_DATGER) BE_DATGER, MAX(BE_HORGER) BE_HORGER,
				       SUM(DTC_PESO) DTC_PESO, SUM(DTC_VALOR) DTC_VALOR, DTC_NUMNFC,
				       MIN(DTC_FILDOC) DTC_FILDOC, MIN(DTC_DOC) DTC_DOC, MIN(DTC_SERIE) DTC_SERIE
				  FROM %table:DUH% DUH 
				  JOIN %table:DTC% DTC 
				    ON DTC_FILIAL = %xFilial:DTC%
				    AND DTC_NUMNFC = DUH_NUMNFC 
				    AND DTC_SERNFC = DUH_SERNFC 
				    AND DTC_CLIREM = DUH_CLIREM 
				    AND DTC_LOJREM = DUH_LOJREM 
				    AND DTC_DOC   <> ' ' 
				    AND DTC_SERIE <> 'PED'
				    AND DTC.%NotDel%
				  JOIN %table:SBE% SBE 
				    ON BE_FILIAL   = %xFilial:SBE%
				    AND BE_LOCAL   = DUH_LOCAL
				    AND BE_LOCALIZ = DUH_LOCALI
				    AND SBE.%NotDel%
				  JOIN %table:DUY% DUY 
				    ON DUY_FILIAL  = %xFilial:DUY%
				    AND DUY_GRPVEN = DTC_CDRORI
				    AND DUY.%NotDel%
				  WHERE DUH_FILIAL = %xFilial:DUH%
				    AND DUH_FILDES >= %Exp:mv_par01%
				    AND DUH_FILDES <= %Exp:mv_par02%
				    AND DUH_LOCAL  >= %Exp:mv_par03%
				    AND DUH_LOCAL  <= %Exp:mv_par04%
				    AND DUH_LOCALI >= %Exp:mv_par05%
				    AND DUH_LOCALI <= %Exp:mv_par06%
				    AND DUH_STATUS = %Exp:StrZero(1,Len(DUH->DUH_STATUS))%
				    AND DUH.DUH_FILORI = %Exp:cFilAnt%
				    AND DUH.%NotDel%
				GROUP BY DUH_FILDES, DUH_LOCAL, DUH_LOCALI, DTC_NUMNFC ) QUERY
			GROUP BY DUH_FILDES, DUH_LOCAL, DUH_LOCALI, DTC_FILDOC, DTC_DOC, DTC_SERIE ) QUERY1
		GROUP BY DUH_FILDES, DUH_LOCAL, DUH_LOCALI
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
oReport:SetMeter(DUH->(LastRec()))

//-- Utiliza a query do Pai
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DUH_FILDES == cParam },{ || (cAliasQry)->DUH_FILDES })

oReport:Section(1):Print()

(cAliasQry)->(DbCloseArea())

Return