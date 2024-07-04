#include "protheus.ch"  
#include "ATFA330.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA330   �Autor  �Rodrigo Gimenes     � Data �  04/11/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � ROTINA PARA ATUALIZACAO DO PARAMETRO MV_ATFBLQM            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/

Function ATFA330()

Local oDlg
Local dDataBlq := GetNewPar("MV_ATFBLQM",CTOD("")) //Verifica a data atual do bloqueio
Local dDtFecha := dDatabase //Sugere a data base como data para o bloqueio
Local nOpca := 0

//��������������������������������������������������������������Ŀ
//� Desenha a tela do programa                                   �
//����������������������������������������������������������������

DEFINE MSDIALOG oDlg FROM  64,33 TO 235,435 TITLE STR0001 PIXEL
@ 00,000 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 35,oDlg:nBottom / 2.4 NOBORDER WHEN .F. PIXEL
@ 06,040 SAY STR0002 SIZE 245, 7 OF oDlg PIXEL
@ 13,040 SAY STR0003 SIZE 245, 7 OF oDlg PIXEL

@ 20,040 SAY STR0004 + Dtoc(dDataBlq) SIZE 245, 7 OF oDlg PIXEL

@ 48,040 SAY STR0005 SIZE 245, 7 OF oDlg PIXEL
@ 46,120 MSGET dDtFecha Picture "@D" OF oDlg PIXEL //VALID VldDt(dDtFecha,dDataBlq)

DEFINE SBUTTON FROM 67, 140 TYPE 1 ENABLE OF oDlg ACTION ( nOpca:=1,oDlg:End() )
DEFINE SBUTTON FROM 67, 170 TYPE 2 ENABLE OF oDlg ACTION ( nOpca:=0,oDlg:End() )
ACTIVATE MSDIALOG oDlg CENTERED

IF nOpca == 1

	PUTMV("MV_ATFBLQM", DTOC(dDtFecha))

ENDIF

RETURN

