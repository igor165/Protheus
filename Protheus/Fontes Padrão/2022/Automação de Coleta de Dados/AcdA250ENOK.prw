#include "rwmake.ch" 


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���  Funcao  � CBA250ENOK � Autor � Anderson Rodrigues � Data �Wed  26/03/03���
���������������������������������������������������������������������������͹��
���Descri��o � Validacao do Encerramento da OP - Mata250 			       	���
���������������������������������������������������������������������������͹��
���Uso       � SIGAACD                                                  	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CBA250ENOK()
Local lErro:= .f.
Local cLocProc:= GetMvNNR('MV_LOCPROC',space(tamsx3('B1_LOCPAD')[1]))

If !SuperGetMV("MV_CBPE004",.F.,.F.)
	Return .t.
EndIf

If Type("l250AUTO") == "L" .and. l250AUTO // ---> Executa somente Se for Protheus 
	Return .t.
EndIf

//����������������������������������������������������Ŀ
//�Verifica se OP ja foi encerrada                     �
//������������������������������������������������������

If !Empty(SC2->C2_DATRF)
	Help(" ",1,"A250ENCERR")
	Return .f.
EndIf

//����������������������������������������������������Ŀ
//�Verifica se OP possui empenho                       �
//������������������������������������������������������

SD4->(DbSetOrder(2))
If SD4->(DbSeek(xFilial("SD4")+Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)))
   While ! SD4->(EOF()) .and. SD4->(D4_FILIAL+Alltrim(D4_OP)) == xFilial("SD4")+Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
      If SD4->D4_LOCAL # cLocProc
         SD4->(DbSkip())
         Loop
      Endif
      If SD4->D4_EMPROC > 0         
         AutoGrLog("Produto "+Alltrim(SD4->D4_COD)+" possui saldo empenhado para a OP "+Alltrim(SD4->D4_OP))
         lErro:= .t.
      Endif
      SD4->(DbSkip())
   Enddo
Endif
   
If lErro
   MostraErro()    
   Return .f.
Endif

//������������������������������������������������������Ŀ
//�Verifica se tem operador ativo na OP e libera o mesmo �
//��������������������������������������������������������

CB1->(DbSetOrder(1))
CB1->(DbGoTop())
While ! CB1->(EOF())
   If ! Empty(CB1->CB1_OP+CB1->CB1_OPERAC) .and. SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) == Alltrim(CB1->CB1_OP)
      RecLock('CB1',.f.)
      CB1->CB1_OP    := Space(13)
      CB1->CB1_OPERAC:= Space(02)
      CB1->(MsUnlock())
   Endif
   CB1->(DbSkip())
Enddo

Return .t.