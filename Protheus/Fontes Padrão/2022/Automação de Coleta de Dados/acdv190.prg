#INCLUDE "ACDV190.ch" 
#include "protheus.ch"
#include "apvt100.ch"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDV190   � Autor � Sandro                � Data � 23/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizacao da caixa de entrada                           ���
���          � Mensagens Enviadas                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA                     ACDV190.PRG ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data         |BOPS:             ���
�������������������������������������������������������������������������Ĵ��
���      01  �                          �              |                  ���
���      02  �Flavio Luiz Vicco         �30/08/2006    |00000106272       ���
���      03  �                          �              |                  ���
���      04  �                          �              |                  ���
���      05  �                          �              |                  ���
���      06  �                          �              |                  ���
���      07  �                          �              |                  ���
���      08  �                          �              |                  ���
���      09  �                          �              |                  ���
���      10  �Flavio Luiz Vicco         �30/08/2006    |00000106272       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/   
Function ACDV190()
Local aTela:= VtSave()
Local aFields := {"CBF_PARA","CBF_DATA","CBF_HORA","CBF_MSG"}
Local aSize   := {6,8,8,18}
Local aHeader := {STR0002,STR0003,STR0004,STR0005} //"Para"###"Data"###"Hora"###"Assunto"
Local cCodOpe := CBRetOpe()
Local cTop,cBottom
Local nRecno

CBF->(dbSetOrder(1))
If CBF->(dbSeek(xFilial("CBF")+cCodOpe))
	nRecno := CBF->(Recno())
	ctop:="xfilial('CBF')+CB1->CB1_CODOPE"
	cBottom:="xfilial('CBF')+CB1->CB1_CODOPE"
	While .t.
		VtClear()
		If VTModelo()=="RF"
			@ 0,0 VTSay STR0001 //"Enviadas"
			nRecno := VTDBBrowse(1,0,VTMaxRow(),VTMaxCol(),"CBF",aHeader,aFields,aSize,,cTop,cBottom)
		Else
			nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxCol(),"CBF",aHeader,aFields,aSize,,cTop,cBottom)
		EndIf
		If VtLastkey() == 27
			Exit
		EndIf
		VtAlert(CBF->CBF_MSG,STR0006+CBF->CBF_DE,.T.) //"Para:"
	End
EndIf
VTRestore(,,,,aTela)
Return