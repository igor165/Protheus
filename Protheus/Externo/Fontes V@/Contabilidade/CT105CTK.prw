#INCLUDE 'PROTHEUS.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH" 

/*/
����������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������Ŀ��
��� Programa  � CT105CTK  � Autor(a) � Ednilson Ap. Amarante - TOTVS   � Data � 03/05/2013 ���
������������������������������������������������������������������������������������������Ĵ��
��� Descricao � Ponto de entrada utilizado na contabilizacao para verificar se deve manter ���
���           � as entidades contabeis Centro de Cuto, Item e Classe Valor.                ���
������������������������������������������������������������������������������������������Ĵ��
���Parametros �                                                                            ���
������������������������������������������������������������������������������������������Ĵ��
��� Sintaxe   � U_CT105CTK()                                                               ���
������������������������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                                    ���
������������������������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                           ���
������������������������������������������������������������������������������������������Ĵ��
��� Programador            � Data       � Chamado � Motivo da Alteracao                    ���
������������������������������������������������������������������������������������������Ĵ��
���                        �            �         �                                        ���
�������������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������
/*/

User Function CT105CTK()

Local aArea		:= GetArea()
Local aAreaCTK	:= 	CTK->(GetArea())
Local aAreaCT5	:= 	CT5->(GetArea())
Local aAreaCT1	:= 	CT1->(GetArea())

DbSelectArea("CT1")
CT1->(DbSetOrder(1))

// Faz a analise das entidades a debito
If CTK->CTK_DC $ "1#3"
	If CT1->(DbSeek(xFilial("CT1")+CTK->CTK_DEBITO))
		If Right(Alltrim(ParamIXB[aScan(ParamIXB,{|x| x[1] == "CT5_CCD"})][2]),4) == '+" "'
			If CT1->CT1_ACCUST != "1"
				CTK->CTK_CCD := Space(TamSX3("CTK_CCD")[1])
			EndIf
		EndIf
		If Right(Alltrim(ParamIXB[aScan(ParamIXB,{|x| x[1] == "CT5_ITEMD"})][2]),4) == '+" "'
			If CT1->CT1_ACITEM != "1"
				CTK->CTK_ITEMD := Space(TamSX3("CTK_ITEMD")[1])
			EndIf
		EndIf
		If Right(Alltrim(ParamIXB[aScan(ParamIXB,{|x| x[1] == "CT5_CLVLDB"})][2]),4) == '+" "'
			If CT1->CT1_ACCLVL != "1"
				CTK->CTK_CLVLDB := Space(TamSX3("CTK_CLVLDB")[1])
			EndIf
		EndIf
	EndIf
EndIf

// Faz a analise das entidades a credito
If CTK->CTK_DC $ "2#3"
	If CT1->(DbSeek(xFilial("CT1")+CTK->CTK_CREDIT))
		If Right(Alltrim(ParamIXB[aScan(ParamIXB,{|x| x[1] == "CT5_CCC"})][2]),4) == '+" "'
			If CT1->CT1_ACCUST != "1"
				CTK->CTK_CCC := Space(TamSX3("CTK_CCC")[1])
			EndIf
		EndIf
		If Right(Alltrim(ParamIXB[aScan(ParamIXB,{|x| x[1] == "CT5_ITEMC"})][2]),4) == '+" "'
			If CT1->CT1_ACITEM != "1"
				CTK->CTK_ITEMC := Space(TamSX3("CTK_ITEMC")[1])
			EndIf
		EndIf
		If Right(Alltrim(ParamIXB[aScan(ParamIXB,{|x| x[1] == "CT5_CLVLCR"})][2]),4) == '+" "'
			If CT1->CT1_ACCLVL != "1"
				CTK->CTK_CLVLCR := Space(TamSX3("CTK_CLVLCR")[1])
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaCT1)
RestArea(aAreaCT5)
RestArea(aAreaCTK)
RestArea(aArea)

Return()