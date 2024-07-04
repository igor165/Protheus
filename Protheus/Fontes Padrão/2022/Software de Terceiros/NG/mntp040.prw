#INCLUDE "MNTP040.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTP040   � Autor � Elisangela Costa      � Data � 05/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 1: Ordens de Abertas/  ���
���          �Liberadas                                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MNTP040()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Array = {{cText1,cValor,nColorValor,bClick},...}              ���
���          �cTexto1     = Texto da Coluna                       		    ���
���          �cValor      = Valor a ser exibido (string)          		    ���
���          �nColorValor = Cor do valor no formato RGB (opcional)          ���
���          �bClick      = Funcao executada no click do valor (opcional)   ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAMDI                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MNTP040()

Local aArea         := GetArea()
Local aAreaSTJ      := STJ->(GetArea())
Local aRetPanel     := {}
Local cMensagem1 := "", cMensagem2 := ""
Private vVETP040IND := {0,0}

Pergunte("MNTP040",.F.)

#IFDEF TOP

   BeginSql Alias "TRBSTJ"
      Select STJ.TJ_DTMPFIM
      	  From %table:STJ% STJ
	      Where STJ.TJ_FILIAL = %xFilial:STJ%
	         And (STJ.TJ_DTMPINI >= %Exp:mv_par01% And STJ.TJ_DTMPINI <= %Exp:mv_par02%)
		     And (STJ.TJ_SITUACA = "L" And STJ.TJ_TERMINO = "N")
		     And STJ.%NotDel%
	  Order by STJ.TJ_DTMPFIM
   EndSql

   dbSelectArea("TRBSTJ")
   dbGotop()
   While !Eof()
      MNTP40GAR(Stod(TRBSTJ->TJ_DTMPFIM))
      dbSkip()
   End
   dbSelectArea("TRBSTJ")
   dbCloseArea()

#ELSE

    dbSelectArea("STJ")
    dbSetOrder(08)
    dbSeek(xFilial("STJ")+DTOS(MV_PAR01),.T.)
    While !Eof() .And. STJ->TJ_DTMPINI <= MV_PAR02
       If STJ->TJ_SITUACA = "L" .And. STJ->TJ_TERMINO = "S"
          MNTP40GAR(STJ->TJ_DTMPINI)
       EndIf
       dbSkip()
    End
    dbSelectArea("STJ")
    dbSetOrder(01)

#ENDIF

//������������������������������������������������������������������������Ŀ
//�Monta mensagens apresentadas ao clicar nas medias                       �
//��������������������������������������������������������������������������
cMensagem1 := STR0003+chr(13)+chr(10) //"Quantidade de ordens de servi�o com situa��o"
cMensagem1 += STR0004+chr(13)+chr(10) //"de liberadas/n�o conlu�das que est�o em atraso,"
cMensagem1 += STR0005 //"no per�odo selecionado no par�metro."

cMensagem2 := STR0003+chr(13)+chr(10) //"Quantidade de ordens de servi�o com situa��o"
cMensagem2 += STR0006+chr(13)+chr(10) //"de liberadas/n�o conlu�das que est�o em dia,"
cMensagem2 += STR0005 //"no per�odo selecionado no par�metro."

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
Aadd(aRetPanel,{STR0007, Transform(vVETP040IND[1],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem1)}} ) //"Abertas/Liber. em Atraso"
Aadd(aRetPanel,{STR0008, Transform(vVETP040IND[2],"99999"),CLR_BLUE,{ || MsgInfo(cMensagem2)}} ) //"Abertas/Liberadas em Dia"

RestArea(aAreaSTJ)
RestArea(aArea)

Return aRetPanel

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTP40GAR � Autor � Elisangela Costa      � Data �06/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava valores na array                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�dDATMPFIM => Data de manutencao prevista fim                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTP040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTP40GAR(dDATMPFIM)

If dDATMPFIM < dDataBase
   vVETP040IND[1] += 1
Else
   vVETP040IND[2] += 1
EndIf

Return .T.