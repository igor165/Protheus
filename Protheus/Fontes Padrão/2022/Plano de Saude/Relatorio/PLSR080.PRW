#INCLUDE "plsr080.ch"

#include "PLSMGER.CH"
#include "protheus.ch"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR080 � Autor � Marco Paulo            � Data � 13.11.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Produtos de Saude                             ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR080()                                                  ����
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
Function PLSR080()
PlsRelPad(STR0001,"PLSR080","PLSR20",STR0002,"PLSM090DEF") //"Relatorio de Produtos de Saude"###"Produtos de Saude"
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PlsR080QLc� Autor � Marco Paulo           � Data � 13.11.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Controla a quebra por Operadora                            ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PlsR080QLc(lRodape)                                        ����
�������������������������������������������������������������������������Ĵ���
���Parametros� lRodape - Se .F. e' condicao da linha, se for .T. e' rodape����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PlsR080QLc(lRodape)
If uContro == NIL  // variavel de controle (PRIVATE da funcao de relatorio) - NAO DECLARAR NESTA FUNCAO POIS ELA E' UMA PRIVATE DA FUNCAO ANTERIOR
   uContro := {}
   aadd(uContro,{"LOCANT",NIL})  // controla operadora anterior
   aadd(uContro,{"TOTLOC",0})    // controla total por operadora  
   aadd(uContro,{"TOTGER",0})    // controla total geral
EndIf
If !lRodape
   If uContro[01,02] == NIL .or. uContro[01,02] # BI3->BI3_CODINT
      If uContro[01,02] # NIL
         @ nLin++,00 pSay "     "+Str(uContro[02,02],6)+STR0003 //" Produtos de Saude nesta Operadora"
      EndIf
      @ nLin++,00 pSay ""
      @ nLin++,00 pSay STR0004+BI3->BI3_CODINT //"Operadora : "
//    uContro[01,02] := BRA->BRA_DESINT
      uContro[02,02] := 0
   EndIf
   uContro[02,02]++  // soma total por localidade
   uContro[03,02]++  // soma total geral
Else
   @ nLin++,00 pSay "     "+Str(uContro[02,02],6)+STR0005 //" Produtos de Saude nesta Operadora."
   nLin++
   @ nLin++,00 pSay "     "+Str(uContro[03,02],6)+STR0006 //" Produtos de Saude listados."
EndIf   
Return .T.

