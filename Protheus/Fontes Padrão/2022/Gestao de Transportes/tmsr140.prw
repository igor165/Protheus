#INCLUDE "tmsr140.ch"
#INCLUDE "FIVEWIN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR140   � Autor �Rodolfo K. Rosseto     � Data �07/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Carta de Comprovantes de Entrega                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSR140()

Local oReport
Local aArea := GetArea()
Local cPerg := "TMR140"

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
Local oQuebra
Local oComprov
Local cPerg := "TMR140"
                     
oReport := TReport():New("TMSR140",STR0015,"TMR140", {|oReport| ReportPrint(oReport)},STR0016)
oReport:SetTotalInLine(.F.)
Pergunte("TMR140",.F.)

//Secao utiliza apenas para quebra, devido ao Print Text nao quebrar da mesma forma
oQuebra := TRSection():New(oReport,STR0018,{},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oQuebra:SetPageBreak()
oQuebra:SetTotalInLine(.F.)

oComprov := TRSection():New(oQuebra,STR0017,{"DU1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oComprov:SetTotalInLine(.F.)
TRCell():New(oComprov,"DU1_NUMNFC","DU1",STR0017,/*Picture*/,15,/*lPixel*/,/*{||  }*/)

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
Static Function ReportPrint(oReport)

Local cAliasQry   := GetNextAlias()
Local cLote       := ''
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao Ocorrencias                                 �
//��������������������������������������������������������������������������
oReport:Section(1):Section(1):BeginQuery()

	BeginSql Alias cAliasQry

		SELECT DU1_FILIAL, DU1_LOTCET, DU1_NUMNFC, A1_NOME, DUO_RESCPV, DU1.R_E_C_N_O_ DU1_RECNO

		FROM %table:DU1% DU1

		JOIN %table:SA1% SA1
		ON A1_FILIAL = %xFilial:SA1%
		AND A1_COD   = DU1_CODCLI
		AND A1_LOJA  = DU1_LOJCLI
		AND SA1.%NotDel%

		LEFT JOIN %table:DUO% DUO
		ON DUO_FILIAL = %xFilial:DUO%
		AND DUO_CODCLI = A1_COD
		AND DUO_LOJCLI = A1_LOJA
		AND DUO.%NotDel%

		WHERE DU1_FILIAL = %xFilial:DU1%
			AND DU1_LOTCET BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DU1_FIMP = %Exp:IIf(mv_par04 == 1,StrZero(0,Len(DU1->DU1_FIMP)),StrZero(1,Len(DU1->DU1_FIMP)))%
			AND DU1.%NotDel%

		ORDER BY DU1_FILIAL,DU1_LOTCET
	
	EndSql

oReport:Section(1):Section(1):EndQuery()

oReport:SetMeter(DUA->(LastRec()))

dbSelectArea(cAliasQry)
While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
	oReport:Section(1):Init()
	cLote := (cAliasQry)->DU1_LOTCET

	oReport:SkipLine(10)
	oReport:PrintText(STR0019,oReport:Row(),10) //"A"
	oReport:SkipLine(1)
	oReport:PrintText((cAliasQry)->A1_NOME,oReport:Row(),10)
	oReport:SkipLine(1)
	oReport:PrintText(STR0020 + (cAliasQry)->DUO_RESCPV,oReport:Row(),10) //"Sr(a): "
	oReport:SkipLine(3)
	oReport:PrintText(STR0021,oReport:Row(),10) //"Ref.: COMPROVANTE DE ENTREGA"
	oReport:SkipLine(2)
	oReport:PrintText(STR0022,oReport:Row(),70) //"Anexo a esta, estamos enviando-lhes canhotos de suas notas fiscais, datados"
	oReport:SkipLine(1)
	oReport:PrintText(STR0023,oReport:Row(),10) //"e assinados por vossos clientes."

	oReport:SkipLine(2)
	
	oReport:Section(1):Section(1):Init()
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof()) .And. (cAliasQry)->DU1_LOTCET == cLote
		oReport:Section(1):Section(1):PrintLine()

		If MV_PAR04 == 1 //So gravar na impressao
			DU1->(DbGoTo((cAliasQry)->DU1_RECNO))
			RecLock("DU1",.F.)
			DU1->DU1_FIMP := StrZero(1, Len(DU1->DU1_FIMP)) //Grava Flag de Impressao
			DU1->( MsUnlock() )		
		EndIf
			
		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo
	oReport:Section(1):Section(1):Finish()

	oReport:SkipLine(3)
	oReport:PrintText(STR0024,oReport:Row(),10) //"Sem mais para o momento."
	oReport:SkipLine(2)
	oReport:PrintText(STR0025,oReport:Row(),500) //"Atenciosamente"
	oReport:SkipLine(1)
	oReport:PrintText(AllTrim(mv_par03),oReport:Row(),600)

	oReport:Section(1):Finish()

EndDo

Return