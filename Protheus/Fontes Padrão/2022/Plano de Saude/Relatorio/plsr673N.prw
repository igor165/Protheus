#INCLUDE "plsr673n.ch"
#include "PROTHEUS.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR673N� Autor � Luciano Aparecido      � Data � 21.03.07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Demonstrativo de An�lise de Contas M�dicas                 ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR673N()                                                 ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSR673N(lAutoma)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
Local cDesc1   := STR0001 //"Emite Relat�rio das Contas M�dicas"
Local cDesc2   := ""
Local cDesc3   := " "
Local cTamanho  := "M"
Local wRel     := "PLSR673N"
Local cString  := "BD7"
Local aOrd     := {}
//��������������������������������������������������������������������������Ŀ
//� Parametros do relatorio (SX1)...                                         �
//����������������������������������������������������������������������������
Local cCodOpe
Local cRdaDe
Local cRdaAte
Local cAno
Local cMes
Local cClaPre
Local nLayout

Private cPerg    := "PL673N    "
Private Titulo   := STR0002 //"Demonstrativo de An�lise da Conta M�dica"
Private aReturn  := { "Zebrado", 1,"Administra��o", 2, 2, 1, "", 1 }
Private nLastKey :=0
Private cabec1   := ""
Private cabec2   := ""
private lDadosM	 := .f.
default lAutoma	 := .f.

	//��������������������������������������������������������������������������Ŀ
	//� Acessa parametros do relatorio...                                        �
	//����������������������������������������������������������������������������
	Pergunte(cPerg,.F.)

	//��������������������������������������������������������������������������Ŀ
	//� Chama SetPrint                                                           �
	//����������������������������������������������������������������������������

	wnRel := SetPrint(cString, wRel,cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .F., cTamanho)

	//��������������������������������������������������������������������������Ŀ
	//� Verifica se foi cancelada a operacao                                     �
	//����������������������������������������������������������������������������

	If nLastKey = 27
		Set Filter To
		Return
	EndIf

	cCodOpe   := mv_par01
	cRdaDe    := mv_par02
	cRdaAte   := mv_par03
	cAno      := mv_par04
	cMes      := mv_par05
	cClaPre   := mv_par06
    nLayout   := mv_par07

	RptStatus({|lEnd| R673NImp(@lEnd, wnRel, cString,cCodOpe,cRdaDe,cRdaAte,cAno,cMes,cClaPre,nLayout,lAutoma)}, Titulo)

Return ( iif(lAutoma, lDadosM, nil) )

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R673NImp � Autor � Luciano Aparecido     � Data � 21.03.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Chamada do Relatorio                                       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R673NImp(lEnd, wnRel, cString, cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre,nLayout,lAutoma)
Local cTissVer := PLSTISSVER()
Local aDados    := {}

aAdd(aDados, MtaDados(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cTissVer))

if !lAutoma  //relat�rio usa componente visual descontinuado.
	If (cTissVer < "3")
		PLSTISS7(aDados, nLayout)
	Else
		PLSTISS7B(aDados, nLayout)
	EndIf
endif	
lDadosM := iif(lAutoma, len(aDados) > 0, .f.)
Return 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � MtaDados  � Autor � Luciano Aparecido    � Data � 21.03.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � chama a funcao "PLSDACM"                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function MtaDados(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cTissVer)

Local aDados := {}

// Funcao que monta o array com os dados da guia
If (cTissVer < "3")
	aDados := PLSDACM(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, nil)
Else
	aDados := PLSDACMB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, nil)
EndIf

Return aDados