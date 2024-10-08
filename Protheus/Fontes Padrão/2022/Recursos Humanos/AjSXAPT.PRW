#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "AJSXAPT.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa    �AjSXAPT    �Autor    �Inova��o - RH       � Data �  29/06/2015 ���
������������������������������������������������������������������������������͹��
���Desc.       � Fonte respons�vels pelos ajustas na vers�o p12.               ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Programador � DATA      � Chamado     �  MOTIVO DA ALTERACAO                ���
���Gabriel A.  �11/07/2016 �TVKL10       �Ajuste no valid do campo REP_CC.     ���
���            �           �             �                                     ���
���            �           �             �                                     ���
���Oswaldo L   �27-04-17   �DRHPONTP300  �Entre os dias 24-04-17 e 26-04-17    ���
���            �           �             �baixamos os fontes do TFS das pastas ���
���            �           �             �MAIN, 12.1.14 e 12.1.16. Conforme    ���
���            �           �             �solicitado fizemos merge delas,depois���
���            �           �             �removemos alteracoes em SX           ���
���Isabel N.   � 25/07/2017�DRHPONTP-360 �Ajuste/Limpeza do fonte para 12.1.17.���
���Willian U.  �31/07/2017 �DRHPONTP-1111�Ajustes dos inicializadores padr�es  ���
���            �           �             �do browse das tabelas RE0, REA e RES ���
���            �           �             �para n�o gerar erro na tela de       ���
���            �           �             �consulta gen�rica.                   ���
��������������������ͱ��������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Main function APTLoad()

	Local lRet      := .T.

	AptMsgRH()

	lRet := fChkConv12()
	If !lRet
		Return
	Endif

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} AptMsgRH
Fun��o para exibir o comunicado sobre a descontinuidade do modulo SIGAAPT
@author  Philipe Couto
@since   29/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AptMsgRH()

Local oDlg
Local oChk1		:= .F.
Local lChk1		:= .F.
Local cTitulo	:= OemToAnsi(STR0001) //'COMUNICADO'
Local oFont1	:= TFont():New("Tahoma",,-12,.T.,.T.) 
Local cSession	:= GetPrinterSession()

//Verifica se o usuario marcou para nao visualizar a mensagem
lChkMsg := fwGetProfString(cSession,"MSG_RHOK_" + cUserName,'',.T.) == ""

If lChkMsg
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 250,760 PIXEL
	
	TSay():New( 010,010,{||OemToAnsi(STR0002)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'Estamos reformulando o acesso aos processos englobados pelo SIGAAPT (Acompanhamento de Processos Trabalhistas)'
	TSay():New( 025,010,{||OemToAnsi(STR0003)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'de maneira a trat�-lo efetivamente como mais uma opera��o de RH.'
	TSay():New( 040,010,{||OemToAnsi(STR0004)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'Nesse contexto, o mesmo ser� descontinuado, sendo que todas as suas funcionalidades ser�o migradas para o m�dulo '
	TSay():New( 055,010,{||OemToAnsi(STR0005)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'SIGAGPE (Gest�o de Pessoal), atrav�s de op��es espec�ficas de menu.'
	TSay():New( 070,010,{||OemToAnsi(STR0008)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'A previs�o inicial para conclus�o desse processo � agosto/2019.'		
	TSay():New( 085,010,{||OemToAnsi(STR0009)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'Em breve divulgaremos outras informa��es atrav�s do TOTVS News.'
	
	@ 110,10 CHECKBOX oChk1 VAR lChk1 PROMPT OemToAnsi(STR0006) SIZE 100,7 PIXEL OF oDlg //'N�o apresentar novamente'
			
	TButton():New(110,350, OemToAnsi(STR0007), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Ok"	
			
	ACTIVATE MSDIALOG oDlg CENTER 
	
	If lChk1
		fwWriteProfString(cSession,"MSG_RHOK_" + cUserName,'CHECKED',.T.)
	EndIf
	
EndIf
	
Return()
