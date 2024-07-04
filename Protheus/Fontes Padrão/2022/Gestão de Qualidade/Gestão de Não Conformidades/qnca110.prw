#Include "PROTHEUS.CH"
#INCLUDE "QNCA110.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA110  � Autor � Aldo Marini Junior    � Data � 01/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Tipos de Etapas/Passos                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA110()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4

Local aRotina := { { STR0001 ,"AxPesqui" , 0, 1,,.F.},;  //"Pesquisar"
					  { STR0002 ,"AxVisual" , 0, 2},;  //"Visualizar"
					  { STR0003 ,"QNC110Inc" , 0, 3},;  //"Incluir"  
					  { STR0004 ,"QNC110Alt" , 0, 4},;  //"Alterar"  
					  { STR0005 ,"Qnc110Del", 0, 5} }  //"Excluir"

If lIntegra
	aAdd( aRotina, { "Exp. p/ Tp.Trf", "QNC110Exp", 0, 5 } ) //"Exp. p/ Fun��es"
EndIf

Return aRotina

Function QNCA110
Local aUsrMat    := QNCUSUARIO()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Etapas/Passos"

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina  := MenuDef()
Private cFilOrig := aUsrMat[2]

Private lMsErroAuto := .F.

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QID")

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qnc110Del� Autor � Aldo Marini Junior    � Data � 01/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Etapas/Passos                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qnc110del(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Qnc110Del(cAlias,nReg,nOpc)
Local nOpcA		:= 1
Local aAC 		:= { STR0007 , STR0008 }  //"Abandona"###"Confirma"
Local lAchou    := .F.
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4
Local nTamCod	:= 0
local aPos := {}
Local oSize

Private aMsSize		:= MsAdvSize()
Private aObjects  := {{ 100, 100, .T., .T., .T. }}
Private aInfo		:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Private aPosObj	:= MsObjSize( aInfo, aObjects, .T. , .T. )


//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Define tamanho da tela                                       �
//����������������������������������������������������������������
oSize := FwDefSize():New()
oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

aPos	:= {	oSize:GetDimension("TELA","LININI"), oSize:GetDimension("TELA","COLINI"), ;
				(oSize:GetDimension("TELA","LINEND")), oSize:GetDimension("TELA","COLEND") }
				
DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE cCadastro  OF oMainWnd pixel
nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",STR0009,,aPos)  //"Quanto � exclus�o?"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

If nOpcA == 2
	//��������������������������������������������������������������Ŀ
	//� Envia mensagem sobre a verificacao nos arquivos              �
	//����������������������������������������������������������������
	If MsgYesNo(OemToAnsi(STR0010 + CHR(013) + ;  		//"Esta rotina verifica a exist�ncia de Lancamentos de"
						STR0011 + CHR(013) + ;  		//"Etapas/Passos a serem excluidos nos diversos arquivos do"
						STR0012 + CHR(013) + ;			//"m�dulo. A verifica��o pode ser demorada !!         "
						STR0013),OemToAnsi(STR0014)) 	//"Confirma a exclus�o ?                              "###"Aten��o"
			
		dbSelectArea("QI5") // Ficha de Ocorrencia/Nao-Conformidades
		dbGoTop()
		While !Eof()
			If QI5->QI5_TPACAO == QID->QID_TPACAO
				lAchou := .T.
				Exit
			Endif
			dbSkip()
		Enddo

		//��������������������������������������������������������������Ŀ
		//� Verificar lancamentos no Cadastro de Modelos de Etapas/Passos�
		//����������������������������������������������������������������
		If !lAchou
			dbSelectArea("QIC") // Modelo de Etapas/Passos
			dbGoTop()
			While !Eof()
				If QIC->QIC_TPACAO == QID->QID_TPACAO
					lAchou := .T.
					Exit
				Endif
				dbSkip()
			Enddo
		Endif

		//��������������������������������������������������������������Ŀ
		//� Se nao Achou pode Deletar                                    �
		//����������������������������������������������������������������
		If lAchou == .F.

			Begin Transaction
	            If lIntegra
	            	nTamCod	:= TamSX3("AN4_TIPO")[1]
					DbSelectArea( "AN4" )
					AN4->( DbSetOrder( 1 ) )
					If AN4->( DbSeek( xFilial( "AN4" ) + Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod ) + "1" ) )
						If PA025Delet( .T. )
							RecLock( "AN4" )
							DbDelete()
							MsUnlock()
						EndIf
					EndIf
				EndIf

				dbSelectArea( cAlias )
				RecLock(cAlias,.F.,.T.)
				dbDelete()
				MsUnlock()
				WRITESX2(cAlias,1)
				dbSkip()
			End Transaction
		Else
			MsgStop(OemToAnsi(STR0015 + CHR(013) +;  				//"O Lancamento a ser excluido est� presente nos"
								STR0016 + CHR(013) +; 				//"Lancamentos dos Modelos e Planos, o registro"
								STR0017),OemToAnsi(STR0018))  		//"nao sera excluido.                           "###"Aten��o"
		Endif
	EndIf
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qnc110Inc� Autor � Totvs                 � Data � 29/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para inclusao de Etapas/Passos                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qnc110inc(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Qnc110Inc(cAlias,nReg,nOpc)
Local aArea		:= {}
Local aAuto		:= {}
Local nOpca 	:= AxInclui( cAlias, nReg, nOpc,,,, /*"A180TudOk()"*/ )
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4
Local nTamCod	:= 0

If nOpca == 1 .AND. lIntegra
	nTamCod	:= TamSX3("AN4_TIPO")[1]
	nOper	:= 3

	DbSelectArea( "AN4" )
	AN4->( DbSetOrder( 1 ) )
	If AN4->( DbSeek( xFilial( "AN4" ) + Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod ) + "1" ) )
		nOper := 4
	EndIf

	aAuto	:= {}
	aAdd( aAuto, { "AN4_TIPO" 	, Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod )	, 	Nil } )
	aAdd( aAuto, { "AN4_DESCRI"	, QID->QID_DESCTP									, 	Nil } )
	aAdd( aAuto, { "AN4_INTQNC"	, "1"												,	Nil } )
	MSExecAuto( {|x,y| PMSA025( x, y ) }, aAuto, nOper )

	If lMsErroAuto
		MostraErro()
	EndIf
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qnc110Alt� Autor � Totvs                 � Data � 29/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para alteracao de Etapas/Passos                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qnc110alt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Qnc110Alt(cAlias,nReg,nOpc)
Local aArea		:= {}
Local aAuto		:= {}
Local nOpca 	:= AxAltera( cAlias, nReg, nOpc,,,, /*"A180TudOk()"*/ )
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4
Local nOper		:= 3
Local nTamCod	:= 0

If nOpca == 1 .AND. lIntegra
	nTamCod	:= TamSX3("AN4_TIPO")[1]
	nOper	:= 3

	DbSelectArea( "AN4" )
	AN4->( DbSetOrder( 1 ) )
	If AN4->( DbSeek( xFilial( "AN4" ) + Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod ) + "1" ) )
		nOper := 4
	EndIf

	aAuto	:= {}
	aAdd( aAuto, { "AN4_TIPO" 	, Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod )	, 	Nil } )
	aAdd( aAuto, { "AN4_DESCRI"	, QID->QID_DESCTP									, 	Nil } )
	aAdd( aAuto, { "AN4_INTQNC"	, "1"												,	Nil } )
	MSExecAuto( {|x,y| PMSA025( x, y ) }, aAuto, nOper )

	If lMsErroAuto
		MostraErro()
	EndIf
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNC110Exp � Autor � Totvs                 � Data � 28/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para exportar as etapas para tipo de tarefa.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QNC110Exp()
Local aArea		:= QID->( GetArea() )
Local aAuto		:= {}
Local nOper		:= 3
Local nTamCod	:= 0
Local lShow		:= .T.

Private lMsErroAuto	:= .F.

DbSelectArea( "QID" )
QID->( DbSetOrder( 1 ) )
QID->( DbSeek( xFilial( "QID" ) ) )
While QID->( !Eof() ) .AND. QID->QID_FILIAL == xFilial( "QID" )
	nTamCod	:= TamSX3("AN4_TIPO")[1]
	nOper	:= 3

	DbSelectArea( "AN4" )
	AN4->( DbSetOrder( 1 ) )
	If AN4->( DbSeek( xFilial( "AN4" ) + Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod ) + "1" ) )
		nOper := 4
	EndIf

	aAuto	:= {}
	aAdd( aAuto, { "AN4_INTQNC"	, "1"												,	Nil } )
	aAdd( aAuto, { "AN4_DESCRI"	, QID->QID_DESCTP									, 	Nil } )
	aAdd( aAuto, { "AN4_TIPO" 	, Left( PadR( QID->QID_TPACAO, nTamCod ), nTamCod )	, 	Nil } )
	MSExecAuto( {|x,y| PMSA025( x, y ) }, aAuto, nOper )

	If lMsErroAuto
		MostraErro()
		lShow	:= .F.

		Exit
	EndIf

	QID->( DbSkip() )
End

If lShow
	MsgAlert( "As etapas foram exportadas com sucesso!" ) //"Os cargos foram exportados com sucesso!"
EndIf

RestArea( aArea )

Return
