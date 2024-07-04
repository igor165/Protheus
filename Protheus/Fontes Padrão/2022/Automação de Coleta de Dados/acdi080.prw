#INCLUDE "acdi080.ch" 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ACDI080  � Autor � Anderson Rodrigues    � Data � 08/11/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de etiquetas das transacoes da producao          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template function ACDI080(uPar1,uPar2,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDI080(uPar1,uPar2,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDI080()	

If IsTelNet()
   ACDI080EXEC()
Else
   Processa({||ACDI080EXEC()})
EndIf
Return

/*
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    �ACDI080EXEC� Autor � Anderson Rodrigues    � Data � 08/11/02 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Execucao da  Funcao Chamada pelo programa ACDI080		      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ACDI080EXEC
Local nCopias
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Transacao de                                 �
//� mv_par02     // Transacao ate                                �
//� mv_par03     // Numero de copias                             �
//� mv_par04     // Local de Impressao                           �
//����������������������������������������������������������������

IF ! &(cPerg)("AII080",.T.)
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
CBI->(DbSetOrder(1))
CBI->(DbSeek(xFilial("CBI")+MV_PAR01,.T.))
While ! CBI->(Eof()).and. Alltrim(CBI->CBI_CODIGO) >= Alltrim(MV_PAR01) .and. Alltrim(CBI->CBI_CODIGO) <= Alltrim(MV_PAR02)            		
   If ExistBlock('IMG09')
      ExecBlock('IMG09',,,{nCopias})
   EndIf
	CBI->(DbSkip())	
Enddo      	
If ExistBlock('IMG00')
   ExecBlock('IMG00',,,{"ACDI080",Alltrim(MV_PAR01),Alltrim(MV_PAR02)})
EndIf
MSCBCLOSEPRINTER()   
Return
