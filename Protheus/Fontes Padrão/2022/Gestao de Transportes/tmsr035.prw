#INCLUDE "TMSR035.ch"
#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR035   � Autor �Rodolfo K. Rosseto     � Data �31/05/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da Rela�ao de Prazos e Regioes por Cliente          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR035()

Local oReport
Local aArea := GetArea()

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oItens
Local cAliasQry   := GetNextAlias()

oReport := TReport():New("TMSR035",STR0010,"TMR030", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011)
oReport:SetTotalInLine(.F.)
Pergunte("TMR030",.F.)

oItens := TRSection():New(oReport,STR0012,{"DVN","DUY","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oItens:SetTotalInLine(.F.)
TRCell():New(oItens,"DVN_CDRORI"		,"DVN",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DUY_DESCORI"	,"DUY",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DVN_CDRDES"		,"DVN",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DUY_DESCDES"	,"DUY",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DVN_TIPTRA"		,"DVN",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DESCTIPTRA"		,"   ",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DVN_TIPTRA',.F.) })
TRCell():New(oItens,"DVN_CODCLI"		,"DVN",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DVN_LOJCLI"		,"DVN",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"A1_NOME"			,"SA1",STR0021,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DVN_TMCLII"		,"DVN",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oItens,"DVN_TMCLIF"		,"DVN",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo Riera          � Data �04.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasQry)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Regioes                                     �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

	BeginSql Alias cAliasQry
	
	SELECT DVN_CDRORI, DUY1.DUY_DESCRI DUY_DESCORI, DVN_CDRDES, DUY2.DUY_DESCRI DUY_DESCDES, DVN_TIPTRA,
          DVN_CODCLI, DVN_LOJCLI, A1_NOME, DVN_TMCLII, DVN_TMCLIF

	FROM %table:DVN% DVN

	JOIN %table:DUY% DUY1 ON
	DUY1.DUY_FILIAL = %xFilial:DUY%
	AND DUY1.DUY_GRPVEN = DVN_CDRORI
	AND DUY1.%NotDel%

	JOIN %table:DUY% DUY2 ON
	DUY2.DUY_FILIAL = %xFilial:DUY%
	AND DUY2.DUY_GRPVEN = DVN_CDRDES
	AND DUY2.%NotDel%

	JOIN %table:SA1% SA1 ON
	A1_FILIAL = %xFilial:SA1%
	AND A1_COD = DVN_CODCLI
	AND A1_LOJA = DVN_LOJCLI
	AND SA1.%NotDel%

	WHERE DVN_FILIAL = %xFilial:DVN%
		AND DVN_CDRORI >= %Exp:mv_par01%
		AND DVN_CDRORI <= %Exp:mv_par02%
		AND DVN_CDRDES >= %Exp:mv_par03%
		AND DVN_CDRDES <= %Exp:mv_par04%
		AND DVN.%NotDel%

	EndSql

oReport:Section(1):EndQuery()

oReport:Section(1):Print()

oReport:SetMeter(DVN->(LastRec()))

Return