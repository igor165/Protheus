#INCLUDE "ACDI040.ch" 
#include "rwmake.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDI040  � Autor � Sandro                � Data � 05/02/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de etiquetas de ID sem titulo                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ACDI040
Local cPerg	:= If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

IF ! &(cPerg)("AII040",.T.) 
   Return
EndIF  
If IsTelNet() 
   VtMsg(STR0001) //'Imprimindo'
   I040()
Else 
   Processa({||I040()})
EndIf   
Return       

/*
Fun��o I040
*/
Static Function I040()
Local nX		:= 0
Local lIMGTMP	:= ExistBlock('IMGTMP')

IF ! CB5SetImp(MV_PAR02,IsTelNet())
   Return
EndIF   
For nX := 1 to MV_PAR01
   If lIMGTMP
      ExecBlock("IMGTMP",,,{})
   EndIf
Next nX
MSCBCLOSEPRINTER()
Return 	
                                        
