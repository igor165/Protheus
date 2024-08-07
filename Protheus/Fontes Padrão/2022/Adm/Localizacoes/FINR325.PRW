#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINR325.CH"

#DEFINE _DELETED_ "*"

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Funcao    � FINR325  � Autor � Cristiano D. Alarcon         � Data � 02.07.03 ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Relatorio da lista de Clientes X Cobrador                         ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR325( void )                                                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                           ���
��������������������������������������������������������������������������������Ĵ��
���                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.            ���
��������������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR � DATA   �    BOPS    �  MOTIVO DA ALTERACAO                     ���
��������������������������������������������������������������������������������Ĵ��
���Paulo Augusto�18/07/06�            �Conversao release 8.11 R.4                ���
���   Marco A.  �08/12/16�SERINN001   �Se aplica CTREE para evitar la creacion   ���
���             �        �-138        �de tablas temporales de manera fisica     ���
���             �        �            �en system.                                ���
���   Marco A.  �16/04/18� DMINA-2310 �Se remueven sentencias CriaTrab y se apli-���
���             �        �            �ca FWTemporaryTable(), para el manejo de  ���
���             �        �            �las tablas temporales.                    ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function FINR325()

	Local oReport		:= Nil
	
	If TRepInUse()
		//�����������������������Ŀ
		//�Interface de impressao �
		//�������������������������
		oReport	:= ReportDef()
		oReport:PrintDialog()
	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Augusto          � Data �18/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local cReport	:= "FINR325"
	Local cTitulo	:= OemToAnsi(STR0004)
	Local cDescri	:= OemToAnsi(STR0001) + " " + OemToAnsi(STR0002) + OemToAnsi(STR0003)
	Local oBreak1	:= Nil

	Pergunte("FIR325", .F.)

	oReport  := TReport():New(cReport, cTitulo, "FIR325", {|oReport| ReportPrint(oReport, "TRB")}, cDescri)
	oReport:SetTotalInLine(.F.)

	//������������������������������������������������������Ŀ
	//� Define a 1a. secao do relatorio Valores nas Moedas   �
	//��������������������������������������������������������
	oSection1 := TRSection():New( oReport,STR0010 , {"TRB","SAQ"},{STR0008,STR0009},/*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oSection1, "AQ_COD"	, "SAQ", /*X3Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/, {||SAQ->AQ_COD})
	TRCell():New(oSection1, "AQ_NOME"	, "SAQ", /*X3Titulo*/, /*Picture*/, 25, /*lPixel*/, {||SAQ->AQ_NOME})

	Trposition():New(oSection1,"SAQ",1,{|| xFilial('SAQ')+ TRB->TRB_CODCOB})

	oBreak1 := TRBreak():New( oSection1,oSection1:Cell("AQ_COD") ,"")
	oSection1:SetTotalInLine(.T.)

	oSection2 := TRSection():New( oSection1, STR0004, {"TRB","SAR","SA1"} )

	TRCell():New(oSection2, "AR_SEQUENC"	, "SAR"	, /*X3Titulo*/	, /*Picture*/, 8			, /*lPixel*/, {||TRB->TRB_SEQUEN })
	TRCell():New(oSection2, "AR_CODCLI"		, "SAR"	, /*X3Titulo*/	, /*Picture*/, /*Tamanho*/	, /*lPixel*/, {||TRB->TRB_CODCLI})
	TRCell():New(oSection2, "AR_LOJCLI"		, "SAR"	, /*X3Titulo*/	, /*Picture*/, /*Tamanho*/	, /*lPixel*/, {||TRB->TRB_LOJCLI })
	TRCell():New(oSection2, "A1_NOME"		, "SA1"	, /*X3Titulo*/	, /*Picture*/, /*Tamanho*/	, /*lPixel*/)
	TRCell():New(oSection2, "QTD"			, ""	, STR0011		, /*Picture*/, 8			, /*lPixel*/, {||1})

	Trposition():New(oSection2, "SA1", 1, {|| xFilial('SA1') + TRB->TRB_CODCLI + TRB->TRB_LOJCLI})
	Trposition():New(oSection2, "SAR", 1, {|| xFilial('SAR') + TRB->TRB_CODCOB + TRB->TRB_CODCLI + TRB->TRB_LOJCLI})
	oSection2:SetParentFilter({|cParam| TRB->TRB_CODCOB == cParam }, {||SAQ->AQ_COD})

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Paulo Augusto          � Data �18/07/2006���
���������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao a ReportPrint devera ser criada para todos os        ���
���          �relatorios urilizam relatorios configuraveis                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                           ���
���������������������������������������������������������������������������Ĵ��
���          �               �                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )
	
	Local oSection1		:= oReport:Section(1)
	Local oSection2		:= oSection1:Section(1)
	
	Private cAreaTRB	:= "TRB"
	Private nOrdem		:= oReport:Section(1):GetOrder()
	
	FIR325Arq(oReport)
	
	dbGoTop()

	oSection2:Cell("QTD"):Hide()

	oSection1:Print()

	dbSelectArea(cAreaTRB)
	dbCloseArea()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FIR325Arq � Autor � Cristiano D. Alarcon  � Data � 02.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cria a tabela temporaria com a mesma estrutura, usando      ���
���          �TOP ou DBF.                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR325A ( void )                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� void                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINR000                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FIR325Arq(oReport)

	Local cKey		:= ""
	
	If ( nOrdem == 1 )
		cKey:="SAR.AR_CODCOBR, SAR.AR_SEQUENC "
	Else
		cKey:="SAQ.AQ_NOME, SAR.AR_SEQUENC"
	EndIf
	cKey := "%" + cKey + "%"
	oReport:Section(1):BeginQuery()
	BeginSql alias "TRB"
		// Query de consulta ao Banco Relacional
		SELECT	SAR.AR_FILIAL TRB_XFILIAL, SAR.AR_CODCOBR TRB_CODCOB ,
				SAR.AR_SEQUENC TRB_SEQUEN, SAR.AR_CODCLI TRB_CODCLI,
				SAR.AR_LOJCLI TRB_LOJCLI,
				SAQ.AQ_NOME TRB_NOMCOB,
				SA1.A1_NOME TRB_NOMCLI
		FROM	%table:SAR% SAR, %table:SA1% SA1, %table:SAQ% SAQ
		WHERE	SAR.AR_CODCOBR  = SAQ.AQ_COD
				and SAR.AR_CODCLI   = SA1.A1_COD
				and SAR.AR_LOJCLI   = SA1.A1_LOJA
				and SAR.AR_FILIAL   = %xfilial:SAR%
				and SAQ.AQ_FILIAL   = %xfilial:SAQ%
				and SA1.A1_FILIAL   = %xfilial:SA1%
				and SA1.%notDel%
				and SAQ.%notDel%
				and SAR.%notDel%
				and SAR.AR_CODCOBR >= %exp:mv_par01%
				and SAR.AR_CODCOBR <= %exp:mv_par02%
		ORDER BY %Exp:cKey%
	EndSql
	
	oReport:Section(1):EndQuery()

Return