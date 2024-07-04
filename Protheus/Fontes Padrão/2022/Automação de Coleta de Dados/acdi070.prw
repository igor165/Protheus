#INCLUDE "acdi070.ch" 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ACDI070  � Autor � Anderson Rodrigues    � Data � 07/11/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de etiquetas dos recursos                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template function ACDI070(uPar1,uPar2,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDI070(uPar1,uPar2,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDI070()	

If IsTelNet()
   ACDI070EXEC()
Else
   Processa({||ACDI070EXEC()})
EndIf
Return

/*
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    �ACDI070EXEC � Autor � Anderson Rodrigues   � Data � 07/11/02 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Execucao da  Funcao Chamada pelo programa ACDI070		     ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ACDI070EXEC
Local nCopias
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Recurso de                                   �
//� mv_par02     // Recurso ate                                  �
//� mv_par03     // Numero de copias                             �
//� mv_par04     // Local de Impressao                           �
//����������������������������������������������������������������

IF ! &(cPerg)("AII070",.T.)
   Return
EndIF
If IsTelNet()
   VtMsg(STR0001)  //'Imprimindo'
EndIF

If ! CB5SetImp(MV_PAR04,IsTelNet())
	IF ! IsTelNet()
		MSGAlert(STR0002)    //'Codigo do tipo de impressao invalido'
	Else
		VTAlert(STR0002)            //'Codigo do tipo de impressao invalido'
	EndIf
	Return .f.
EndIF
nCopias := Alltrim(MV_PAR03)
SH1->(DbSetOrder(1))
SH1->(DbSeek(xFilial("SH1")+MV_PAR01,.T.))
While ! SH1->(Eof()).and. SH1->H1_CODIGO >= MV_PAR01 .and. SH1->H1_CODIGO <= MV_PAR02            		
   If ExistBlock('IMG08')
      ExecBlock('IMG08',,,{nCopias})
   EndIf
	SH1->(DbSkip())	
Enddo      	
If ExistBlock('IMG00')
   ExecBlock('IMG00',,,{"ACDI070",MV_PAR01,MV_PAR02})
EndIf
MSCBCLOSEPRINTER()   
Return

