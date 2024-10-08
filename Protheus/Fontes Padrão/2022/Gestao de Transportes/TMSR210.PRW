#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSR210.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR210  � Autor � Eduardo de Souza      � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as Viagens Efetivadas			                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR210()

Local oReport
Local aArea := GetArea()

DbSelectArea("DUV")
DUV->( DbSetOrder(1) )

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport	:= Nil
Local cAliasQry	:= GetNextAlias()
Local aOrdem	:= {}

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
oReport:= TReport():New("TMSR210",STR0012,"TMR210", {|oReport| ReportPrint(oReport,cAliasQry)},STR0013) // "Relacao de Viagens Efetivadas" ### "Emite as Viagens Efetivadas conforme os parametros informados"
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Data De ?   	                                �
//� mv_par02	 // Data Ate ?       							        |
//| mv_par03	 // Veiculo De ?                                  |
//| mv_par04	 // Veiculo Ate ?                                 �
//����������������������������������������������������������������
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
Aadd( aOrdem, STR0014 ) // "Ve�culo"

oVeiculo:= TRSection():New(oReport,STR0014,{"DUV","DA3"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oVeiculo:SetTotalInLine(.F.)
TRCell():New(oVeiculo,"DUV_CODVEI","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DUV_FILORI","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DUV_VIAGEM","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DUV_FILSAI","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/, { || (cAliasQry)->DUV_FILSAI } )
TRCell():New(oVeiculo,"DUV_FILENT","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/, { || (cAliasQry)->DUV_FILENT } )
TRCell():New(oVeiculo,"DUV_DATENT","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DUV_PESO"  ,"DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"KMPERC"    ,""   ,STR0016   ,PesqPict("DUV","DUV_ODOENT"),TamSx3("DUV_ODOENT")[1],/*lPixel*/,{|| (cAliasQry)->DUV_ODOENT-(cAliasQry)->DUV_ODOSAI } )
TRCell():New(oVeiculo,"DUV_ODOENT","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DUV_ODOSAI","DUV",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oVeiculo,oVeiculo:Cell("DUV_CODVEI"),STR0015,.F.) // "Total Ve�culo"
TRFunction():New(oVeiculo:Cell("DUV_CODVEI"),/*cId*/,"COUNT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oVeiculo:Cell("DUV_PESO"  ),/*cId*/,"SUM"  ,oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oVeiculo:Cell("KMPERC"    ),/*cId*/,"SUM"  ,oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR420                                                    ���
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
	SELECT DUV_FILIAL, DUV_CODVEI, DUV_FILORI, DUV_VIAGEM, DUV_FILSAI, DUV_FILENT, DUV_PESO, DUV_DATENT, DUV_ODOENT, DUV_ODOSAI
	   FROM %table:DUV% DUV
	   WHERE DUV_FILIAL  = %xFilial:DUV%
	     AND DUV_DATENT BETWEEN %Exp:Dtos(mv_par01)% AND %Exp:Dtos(mv_par02)%
	     AND DUV_CODVEI BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	     AND DUV.%NotDel%
	   ORDER BY DUV_FILIAL, DUV_CODVEI
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
oReport:SetMeter(DUV->(LastRec()))

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cCodVei := (cAliasQry)->DUV_CODVEI
		oReport:Section(1):Init()
		While !(cAliasQry)->(Eof()) .And. (cAliasQry)->DUV_CODVEI == cCodVei
			oReport:Section(1):PrintLine()
			oReport:Section(1):Cell("DUV_CODVEI"):Hide()
			(cAliasQry)->(DbSkip())
		EndDo
		oReport:Section(1):Cell("DUV_CODVEI"):Show()
	EndDo
EndIf

Return