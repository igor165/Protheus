#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA091.CH"
#INCLUDE "TMKDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA091 � Autor � Vendas CRM            � Data �  08/05/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao utilizada para alternar entre grupos de atendimento  ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMKA091()    
	Local aArea			:= GetArea()	// Salva a area atual
	Local aCbGroups		:= {}			// Lista de grupos do operador que ser� apresentado no cambobox
	Local cIndex		:= ""			// Item selecionado do combobox
	Local oDlg			:= Nil			// Di�logo de sele��o de grupos de atendimento
	Local aGroups		:= {}			// Lista de grupos de atendimento do operador
	Local nCount 		:= 0			// Contador tempor�rio
	Local cActiveGroup	:= ""			// Grupo ativo do operador
	Local cUserCode		:= ""			// C�digo do operador
	Local lSave			:= .F.			// Ser� ser� feita a troca do grupo ou n�o
	Local uTemp1		:= Nil			// Tempor�rio
	Local uTemp2		:= Nil			// Tempor�rio
	
	//�������������������������������������������Ŀ
	//�Pega o c�digo de operador do usu�rio atual.�
	//���������������������������������������������
	DbSelectArea("SU7")
	DbSetOrder(4)
	If DbSeek(xFilial("SU7") + __cUserId) // Nome completo
		cUserCode := SU7->U7_COD
	Endif

	//�������������������������������������������������������������������Ŀ
	//�Se o banco de dados com os grupos de atendimento x operador existe.�
	//���������������������������������������������������������������������
	
	//�����������������������������������������������������������������Ŀ
	//�Verifica se o operador pode alterar o grupo de atendimento.      �
	//�S� � poss�vel alterar se o operador n�o estiver rodando          �
	//�determinadas rotinas.                                            �
	//�Isso ocorre pois as rotinas utilizam o campo U7_POSTO            �
	//�para determinar qual � o grupo de atendimento do operador.       �
	//�Se for alterado durante a execu��o das rotinas, erros inesperados�
	//�podem acontecer.                                                 �
	//�������������������������������������������������������������������
	If TK091CanChange()	
		If !Empty(cUserCode)
			//������������������������������Ŀ
			//�Se pos�vel pega o grupo ativo.�
			//��������������������������������
			If TK091OperGroup(cUserCode, @cActiveGroup)		
				//����������������������������������������������������������Ŀ
				//�Se poss�vel pega os grupos habilitados para esse operador.�
				//������������������������������������������������������������
				If TK091GetGroups(cUserCode, @aGroups)
					//��������������������������������������������������Ŀ
					//�Cria as op��es do combo com os grupos dispon�veis.�
					//����������������������������������������������������
					For nCount := 1 To Len(aGroups)
						aAdd(aCbGroups, aGroups[nCount] + "=" + Posicione("SU0",1,xFilial("SU0") + aGroups[nCount],"U0_NOME"))
						If aGroups[nCount] == cActiveGroup
							cIndex := aGroups[nCount]
						EndIf
					Next		
				
					DEFINE MSDIALOG oDlg TITLE STR0001 FROM 372,282 TO 482,533 PIXEL	// "Alternar Grupo de Atendimento"
					DEFINE FONT oFont NAME "Arial" SIZE 0,14 BOLD
					@ 005,005 Say STR0002 Font oFont Size 040,006 COLOR CLR_BLACK PIXEL OF oDlg	// "Grupo Atual:"
					@ 005,042 Say Posicione("SU0",1,xFilial("SU0") + cActiveGroup,"U0_NOME") Size 095,006 COLOR CLR_BLACK PIXEL OF oDlg
					@ 015,005 Say STR0003 Font oFont Size 075,006 COLOR CLR_BLACK PIXEL OF oDlg	// "Alternar para o Grupo:"
					@ 025,005 ComboBox cIndex Items aCbGroups Size 072,010 PIXEL OF oDlg
					@ 040,020 Button STR0004 Size 037,012 PIXEL OF oDlg ACTION (lSave := .T., oDlg:End())	// "OK"
					@ 040,080 Button STR0005 Size 037,012 PIXEL OF oDlg ACTION (lSave := .F., oDlg:End())	// "Cancelar"
					ACTIVATE MSDIALOG oDlg CENTERED 	
				Else
					Aviso(STR0006, STR0007, {"OK"})	// "Aten��o" "O operador logado n�o est� habilitado para trabalhar com m�ltiplos grupos"
				EndIf
			EndIf
		EndIf
	Else
		//���������������������������������������������������Ŀ
		//�Exibe as rotinas que est�o em execu��o que impede o�
		//�operador de trocar de grupo.                       �
		//�����������������������������������������������������
		uTemp1 := TK091GetActiveProcess()
		uTemp2 := STR0008 + CRLF + STR0009 + CRLF + STR0010 + CRLF	// "As seguintes rotinas est�o em execu��o" "e devem ser fechadas para que seja" "poss�vel alternar entre os grupos de atendimento: "
		For nCount := 1 To Len( uTemp1 )
			uTemp2 += TK091GetProcessName( uTemp1[nCount] ) + CRLF
		Next 
		Alert(uTemp2)
	EndIf	
	
	//���������������������������Ŀ
	//�Se o usu�rio deseja gravar.�
	//�����������������������������
	If lSave
		DbSelectArea("SU7")
		DbSetOrder(4)
		If SU7->(DbSeek(xFilial("SU7") + __cUserId))
			RecLock("SU7", .F.)
			Replace SU7->U7_POSTO With cIndex
			SU7->(MsUnLock())
		EndIf
	EndIf
	
	RestArea( aArea )
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091OperGroup� Autor � Vendas CRM     � Data �  08/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega o grupo ativo do operador.                             ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1: C�digo do usu�rio                                    ���
���          �ExpL2: Vari�vel que recebe o grupo procurado                ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TK091OperGroup(cUserCode, cActiveGroup)
	Local aArea	:= GetArea()	// Salva a area
	Local lRet	:= .F.			// Retorno da fun��o
	
	DbSelectArea("SU7")
	DbSetOrder(1)	
	If DbSeek( xFilial("SU7") + cUserCode )
		cActiveGroup := SU7->U7_POSTO
		lRet := .T.
	EndIf	
	
	RestArea( aArea )
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091GetGroups� Autor � Vendas CRM     � Data �  08/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega os grupos do operador.                                 ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1: C�digo do usu�rio                                    ���
���          �ExpL2: Vari�vel que recebe os grupos procurados             ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TK091GetGroups(cUserCode, aGroups)
	Local aArea			:= GetArea()	// Salva a area
	Local lRet			:= .F.			// Retorno da fun��o

	//�������������������������������������Ŀ
	//�Pega os grupos que o operador atende.�
	//���������������������������������������
	DbSelectArea("AG9")
	DbSetOrder(1)	
	If DbSeek( xFilial("AG9") + cUserCode )
		lRet := .T.	
		While 	!AG9->(EOF()) .And.;
				AG9->AG9_FILIAL == xFilial("AG9") .And.;
				AllTrim(AG9->AG9_CODSU7) == AllTrim(cUserCode)
			aAdd(aGroups, AG9->AG9_CODSU0)
			AG9->(DbSkip())
		End
	EndIf	
	
	aSort(aGroups)
	
	RestArea( aArea )
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091Titulo� Autor � Vendas CRM        � Data �  08/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o gen�rica que retorna uma string com �nforma��es do   ���
���          �operador.                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1: C�digo do usu�rio                                    ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TK091Titulo(cCodUser)
	Local aArea := GetArea()
	Local cRet	:= ""

	DbSelectArea("SU7")
	DbSetOrder(1)
	
	If DbSeek( xFilial("SU7") + cCodUser )
		DbSelectArea("SU0")
		DbSetOrder(1)
		If DbSeek( xFilial("SU0") + SU7->U7_POSTO )
			cRet := "[" + AllTrim(SU0->U0_CODIGO) + " - " + AllTrim(SU0->U0_NOME) + " / " + AllTrim(SU7->U7_COD) + " - " + AllTrim(SU7->U7_NOME) + "]"
		EndIf
	EndIf
	
	RestArea( aArea )
Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091Start � Autor � Vendas CRM        � Data �  08/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria um sem�foro para a rotina solicitada.                  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1: C�digo da rotina                                     ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TK091Start( nRotina )
Return LockByName( "TMK" + AllTrim(Str(nRotina)) + __cUserId )	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091Start � Autor � Vendas CRM        � Data �  08/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Apaga um sem�foro para a rotina solicitada.                 ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1: C�digo da rotina                                     ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TK091End( nRotina )
Return UnLockByName( "TMK" + AllTrim(Str(nRotina)) + __cUserId )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091CanChange � Autor � Vendas CRM    � Data �  08/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o operador pode alterar o grupo ativo.          ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TK091CanChange()
	Local lRet				:= .F.
	Local aActiveProcess	:= {}

	//�����������������������������������������
	//�Verifica se existe alguma rotina ativa.�
	//�����������������������������������������
	aActiveProcess := TK091GetActiveProcess()
	If Len(aActiveProcess) > 0
		lRet	:= .F.
	Else
		lRet	:= .T.
	EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091GetActiveProcess� Autor � Vendas CRM � Data � 08/05/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega a lista das rotinas em execu��o.                       ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TK091GetActiveProcess()
	Local aActiveProcess	:= {}

	//������������������������������������������
	//�Para cada rotina tenta criar o sem�foro.�
	//������������������������������������������
	If TK091Start( AGENDAOPERADOR )
		TK091End( AGENDAOPERADOR )
	Else
		aAdd( aActiveProcess, AGENDAOPERADOR )
	EndIf
	If TK091Start( SERVICEDESK )
		TK091End( SERVICEDESK )
	Else
		aAdd( aActiveProcess, SERVICEDESK )
	EndIf
	If TK091Start( PREATENDIMENTO )
		TK091End( PREATENDIMENTO )
	Else
		aAdd( aActiveProcess, PREATENDIMENTO )
	EndIf
	If TK091Start( CALLCENTER )
		TK091End( CALLCENTER )
	Else
		aAdd( aActiveProcess, CALLCENTER )
	EndIf
	If TK091Start( TELEATENDIMENTO )
		TK091End( TELEATENDIMENTO )
	Else
		aAdd( aActiveProcess, TELEATENDIMENTO )
	EndIf
Return aActiveProcess  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK091GetProcessName� Autor � Vendas CRM � Data �  08/05/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega o nome de um determinado processo.                     ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1: C�digo da rotina                                     ���
�������������������������������������������������������������������������͹��
���Uso       �CALL CENTER                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TK091GetProcessName( nRotina )
	Local cRet := ""

	If nRotina == 1
		cRet := STR0011	// "Agenda do operador"
	ElseIf nRotina == 2
		cRet := STR0012	// "Service desk"
	ElseIf nRotina == 3
		cRet := STR0013	// "Pr�-atendimento"
	ElseIf nRotina == 4
		cRet := STR0014	// "Call Center"
	ElseIf nRotina == 5
		cRet := STR0015	// "Teleatendimento"
	EndIf		
Return cRet