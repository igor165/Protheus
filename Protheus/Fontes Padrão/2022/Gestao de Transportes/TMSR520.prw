#INCLUDE "TMSR520.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR520  � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Clientes Preservados                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR520()

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
���Uso       � TMSR520                                                    ���
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
oReport:= TReport():New("TMSR520",STR0006,/*cPerg*/, {|oReport| ReportPrint(oReport,cAliasQry)},STR0007) // 'Clientes Preservados' ### 'Impressao de Clientes Preservados'
oReport:SetTotalInLine(.F.)

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
Aadd( aOrdem, STR0008 ) // "Cliente"

oCliente:= TRSection():New(oReport,STR0008,{"DWO","SA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oCliente:SetTotalInLine(.F.)
TRCell():New(oCliente,"DWO_CODCLI","DWO",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCliente,"DWO_LOJCLI","DWO",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCliente,"A1_NOME"   ,"SA1",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oCliente,"DWO_TIPFRE","DWO",/*cTitle*/,/*Picture*/,3 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCliente,"DWO_STATUS","DWO",/*cTitle*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oCliente,"DWO_MOTIVO","DWO",STR0009   ,/*Picture*/,80/*Tamanho*/,/*lPixel*/, {|| MSMM(DWO->DWO_CODMOT) } )

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
���Uso       � TMSR520                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DWO_FILIAL, DWO_CODCLI, DWO_LOJCLI, DWO_TIPFRE, DWO_STATUS, DWO_CODMOT, A1_NOME
		FROM %table:DWO% DWO
		JOIN %table:SA1% SA1
			ON A1_FILIAL = %xFilial:SA1%
			AND A1_COD  = DWO_CODCLI
			AND A1_LOJA = DWO_LOJCLI
			AND SA1.%NotDel%
		WHERE DWO_FILIAL = %xFilial:DWO%
			AND DWO.%NotDel%
	ORDER BY DWO_FILIAL, DWO_CODCLI, DWO_LOJCLI
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
oReport:SetMeter(DWO->(LastRec()))

oReport:Section(1):Print()

Return