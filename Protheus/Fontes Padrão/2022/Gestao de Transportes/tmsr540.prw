#INCLUDE "TMSR540.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR540  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Pendencias                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR540()

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
���Uso       � TMSR540                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
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
oReport:= TReport():New("TMSR540",STR0012,"TMR540", {|oReport| ReportPrint(oReport,cAliasQry)},STR0013) // "Relat�rio de Pend�ncias"	### "Emite a rela��o de Pend�ncias geradas a partir da rotina de ocorr�ncias conforme os par�metros "
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Cliente De                                    �
//� mv_par02	 // Loja De                                       �
//� mv_par03	 // Cliente Ate                                   �
//� mv_par04	 // Loja Ate                                      �
//� mv_par05	 // Periodo De                                    �
//� mv_par06	 // Periodo Ate                                   �
//� mv_par07	 // Status 													  �
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
Aadd( aOrdem, STR0014 ) // "Tipo de Pend�ncia"

oTipPnd := TRSection():New(oReport,STR0014,{"DUU"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Tipo de Pend�ncia"
oTipPnd:SetTotalInLine(.F.)
TRCell():New(oTipPnd,"DUU_TIPPND","DUU",/*cTitle*/,/*Picture*/,2 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipPnd,"DUU_DESPND","DUU",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DUU_TIPPND',.F.) },,,,,,.T.)

oPend := TRSection():New(oTipPnd,STR0015,{"DUU","SA1","DT6","DT2"},/*Array com as Ordens*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Pend�ncia"
oPend:SetTotalInLine(.F.)
TRCell():New(oPend,"DUU_FILPND","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Fil.Pend." 
TRCell():New(oPend,"DUU_NUMPND","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Num.Pend"
TRCell():New(oPend,"DUU_DATPND","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Data"
TRCell():New(oPend,"DUU_HORPND","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Hora"
TRCell():New(oPend,"A1_NREDUZ" ,"SA1",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Cliente"
TRCell():New(oPend,"DUU_FILDOC","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Fil.Doc."
TRCell():New(oPend,"DUU_DOC"   ,"DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Docto"
TRCell():New(oPend,"DUU_SERIE" ,"DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Serie"
TRCell():New(oPend,"DUU_FILORI","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Fil.Ori."
TRCell():New(oPend,"DUU_VIAGEM","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Viagem"
TRCell():New(oPend,"DUU_CODOCO","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.) // "Cod.Ocor."
TRCell():New(oPend,"DT2_DESCRI","DT2",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.) // "Des.Ocor."
TRCell():New(oPend,"DUU_QTDOCO","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Qtde"
TRCell():New(oPend,"DT6_VALMER","DT6",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.) // "Val.Merc."
TRCell():New(oPend,"DUU_VALPRE","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.) // "Val.Prejuizo"
TRCell():New(oPend,"DUU_DATENC","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Data Enc."
TRCell():New(oPend,"DUU_HORENC","DUU",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) // "Hora Enc."
TRCell():New(oPend,"DUU_STATUS","DUU",,/*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.) // "Status"
TRCell():New(oPend,"DUU_NUMCON","DUU",,/*Picture*/,6 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.) // "Status"

TRFunction():New(oPend:Cell("DT6_VALMER"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPend:Cell("DUU_VALPRE"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
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

Local cTipVei := ''
Local cFroVei := ''
Local cCodVei := ''
Local cQuery  := ''

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

cQuery :="%"
If mv_par07 <> 5
	cQuery += "  AND DUU_STATUS = '" + Alltrim(Str(mv_par07)) + "' "
EndIf
cQuery +="%"

BeginSql Alias cAliasQry
	SELECT DUU_FILPND,DUU_NUMPND,DUU_DATPND,DUU_HORPND,DUU_FILDOC,DUU_DOC,
	   	 DUU_SERIE,DUU_FILORI,DUU_VIAGEM ,DUU_CODOCO,DUU_QTDOCO,DUU_VALPRE,
	   	 DUU_DATENC,DUU_HORENC,DUU_STATUS,DUU_TIPPND,DUU_CODCLI,DUU_LOJCLI
	FROM %table:DUU%
	WHERE DUU_FILIAL = %xFilial:DUU%
		AND DUU_CODCLI BETWEEN %Exp:mv_par01% AND %Exp:mv_par03%
		AND DUU_LOJCLI BETWEEN %Exp:mv_par02% AND %Exp:mv_par04%
		AND DUU_DATPND BETWEEN %Exp:DtoS(mv_par05)% AND %Exp:DtoS(mv_par06)%
		AND %NotDel%
		%Exp:cQuery%
	ORDER BY DUU_TIPPND,DUU_CODCLI,DUU_LOJCLI,DUU_NUMPND,DUU_FILDOC,DUU_DOC,DUU_SERIE
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
oReport:SetMeter(DUU->(LastRec()))

TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+(cAliasQry)->DUU_CODCLI+(cAliasQry)->DUU_LOJCLI })
TRPosition():New(oReport:Section(1):Section(1),"DT6",1,{|| xFilial("DT6")+(cAliasQry)->DUU_FILDOC+(cAliasQry)->DUU_DOC+(cAliasQry)->DUU_SERIE })
TRPosition():New(oReport:Section(1):Section(1),"DT2",1,{|| xFilial("DT2")+(cAliasQry)->DUU_CODOCO })

//-- Utiliza a query do Pai
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DUU_TIPPND == cParam },{ || (cAliasQry)->DUU_TIPPND })

oReport:Section(1):Print()

(cAliasQry)->(DbCloseArea())

Return