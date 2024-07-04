#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "QDOA160.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOA160  � Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Funcoes                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOA160()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO - Generico                                         ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �27/08/02� ---- � Incluido validacao no codigo da funcao   ���
���            �        �      � quando integrado com SIGAGPE.            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()
Local aRotina 	:= {} 
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4

Private lIntLox := GetMV("MV_QALOGIX") == "1"

If lIntLox
	aRotina  := {{ OemToAnsi(STR0002),"AxPesqui" ,0 ,1,,.F.},; //"Pesquisar"
		{ OemToAnsi(STR0003),"QD160Telas",0 ,2},; //"Visualizar"
		{ OemToAnsi(STR0005),"QD160Telas",0 ,4}} //"Alterar"
Else
	aRotina  := {{ OemToAnsi(STR0002),"AxPesqui" ,0 ,1,,.F.},; //"Pesquisar"
		{ OemToAnsi(STR0003),"QD160Telas",0 ,2},; //"Visualizar"
		{ OemToAnsi(STR0004),"QD160Telas",0 ,3},; //"Incluir"
		{ OemToAnsi(STR0005),"QD160Telas",0 ,4},; //"Alterar"
		{ OemToAnsi(STR0006),"QD160Telas",0 ,5}}  // "Excluir"

	If lIntegra
		aAdd( aRotina, { "Exp. p/ Fun��es", "QD160Exp", 0, 5 } ) //"Exp. p/ Fun��es"
	EndIf
Endif

Return aRotina

Function QDOA160()

Private cCadastro:= OemToAnsi(STR0001)  //"Cadastro de Funcoes"
Private aRotina  := MenuDef()

mBrowse(006,001,022,075,"QAC")

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QD160Telas� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Centro de Custos                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD160Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD160Telas(cAlias,nReg,nOpc)

Local oDlg
Local nOpcao:= 0
Local nSaveSx8:=GetSX8Len()
Local oEnchoice
Local cPriFil 		:= ""
Local aArea 		:= {}
Local cKeyPriFil    := ""
Local cKeySRJ       := ""
Local cModoQAC      := "" 
Local cFilFun 		:= cFilAnt           

Private lIntGPE:= If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
Private bCampo := {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("QAC")
DbSetOrder(1)

RegToMemory("QAC", nOpc = 3)
If nOpc = 3
	M->QAC_FILIAL:= xFilial("QAC")
Else
	If (nOpc = 4 .Or. nOpc = 5) .And. lIntGPE 
		aArea     := GetArea()
		cKeyPriFil:= QXPOSFIL(cEmpAnt)

		If Subst(M->QAC_FUNCAO,1,Len(cEmpAnt)) == cEmpAnt
			cKeySRJ   := Subst(M->QAC_FUNCAO,len(cEmpAnt)+len(cKeyPriFil)+1)
			cModoQAC  := FWModeAccess("QAC",3)
			
			If cModoQAC == "C"
				cFilFun:= xFilial("QAC")
			EndIf

			DbSelectArea("SRJ")
			DbSetOrder(1)
			If SRJ->(DbSeek(cFilFun+cKeySRJ))
				If nOpc = 4 
					MsgAlert(OemToAnsi(STR0009),OemToAnsi(STR0007))  //"Devido a integracao, a manutencao do Cargo somente podera ser feita atraves do Gestao de Pessoal!" # "Aten��o"
				Else
					If nOpc = 5
						MsgAlert(OemToAnsi(STR0010),OemToAnsi(STR0007))  //"Devido a integracao, a exclusao do Cargo somente podera ser feita atraves do Gestao de Pessoal!" # "Aten��o"				
					Endif			
				Endif		
				Return()
			Endif	
				
			RestaRea(aArea)
		Endif	
	Endif	
Endif

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Cadastro de Funcoes"

oEnchoice := Msmget():New("QAC",nReg,nOpc,,,,,{014,002,190,312})

oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

aArea := GetArea()
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()})
RestaRea(aArea)

If nOpc <> 2
	If nOpcao == 1
		If nOpc == 3 .Or. nOpc == 4
			QDA160GFun(nOpc)
			While (GetSX8Len() > nSaveSx8)
			   	ConfirmSX8()		
			Enddo
		ElseIf nOpc == 5
			QDA160Dele()
		EndIf
	Else
		While (GetSX8Len() > nSaveSx8)
			RollBackSX8()
		Enddo
	Endif
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDA160GFun� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Funcoes                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDA160GFun(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDA160GFun(nOpc)
Local aAuto		:= {}
Local lRecLock	:= .F.
Local nI      	:= 0
Local lRet    	:= .F.
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4
Local nOpca
Local cNivSup
Local nTamFld	:= 9
Local cAuxFunc

Private lMsErroAuto := .F.

If nOpc == 3
	lRecLock:= .T.
EndIf
if nOpc <> 3
	DbSelectArea("QAC")
	DbSetOrder(1)
	Dbseek(xfilial("QAC")+M->QAC_FUNCAO)        
EndIF

If RecLock("QAC",lRecLock)
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnLock()      
	lRet:= .T.
EndIf

//Integracao entre PMS x TMK x QNC
If lRet .AND. lIntegra
	
	If TamSX3("AN1_CODIGO")[1] < TamSX3("QAC_FUNCAO")[1] 
		cAuxFunc :=  "SubStr(QAC->QAC_FUNCAO, 1, TamSX3('AN1_CODIGO')[1])"
	Else
		cAuxFunc :=  "QAC->QAC_FUNCAO"
	EndIf

	DbSelectArea( "AN1" )
	AN1->( DbSetOrder( 1 ) )
	If AN1->( DbSeek( xFilial( "AN1" ) + &cAuxFunc + "1" ) )
		nOpca := 4
		cNivSup := AN1->AN1_NIVSUP
	Else
		nOpca := 3
		cNivSup := ""
	EndIf
	
	cNivSup := QAC->QAC_NIVSUP
	
	aAdd( aAuto, { "AN1_CODIGO" , PadR( QAC->QAC_FUNCAO, nTamFld ), 	Nil } )
	aAdd( aAuto, { "AN1_DESCRI" , M->QAC_DESC, 							Nil } )
	aAdd( aAuto, { "AN1_INTQNC" , "1", 									Nil } )
	aAdd( aAuto, { "AN1_NIVSUP" , cNivSup,								Nil } )

	MSExecAuto( {|x,y| PMSA095( x, y ) }, aAuto, nOpca )

	If lMsErroAuto
		MostraErro()
	EndIf
EndIf
	
Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDA160Dele� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Funcoes                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDA160Dele()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDA160Dele(lRetorno)

Local lAchou	:= .F.
Local cFilQAC 	:= xFilial("QAC")
Local lIntGPE 	:= If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4
Local lDeleta	:= .T.
Local cCodigo
Local aArea
Local aAreaQAC

Default lRetorno := ""

// Verifica se esta sendo usado como nivel superior e nao permite exclusao
cCodigo:=  Padr(QAC->QAC_FUNCAO, Len(QAC->QAC_NIVSUP))
aArea	:= GetArea()
aAreaQAC:= QAC->(GetArea())
DbSelectArea( "QAC" )
QAC->( DbSetOrder( 1 ) )
QAC->( DbSeek( xFilial( "QAC" ) ) )
Do While QAC->( !Eof() ) .And. QAC->QAC_FILIAL == xFilial( "QAC" )
	If QAC->QAC_NIVSUP == cCodigo
		lDeleta := .F.
		MsgAlert(OemToAnsi("A fun��o esta sendo usada e n�o pode ser excluida!"),OemToAnsi(STR0007))  //"A fun��o esta sendo usada e n�o pode ser excluida!" # "Aten��o"
		Exit
	EndIf
	QAC->( DbSkip() )
EndDo

RestArea(aAreaQAC)
RestArea(aArea)

If lDeleta
	IF FWModeAccess("QAC")=="C"//EMPTY(cFilQAC)
		QAA->(DbGoTop())
		While QAA->(!Eof())
			If QAA->QAA_CODFUN == QAC->QAC_FUNCAO
				lAchou := .T.
				Exit
			Endif
			QAA->(DbSkip())
		EndDo
	Else
		QAA->(MSSEEK(cFilQAC))
		While QAA->(!Eof()) .AND. QAA->QAA_FILIAL == cFilQAC
			If QAA->QAA_CODFUN == QAC->QAC_FUNCAO
				lAchou := .T.
				Exit
			Endif
			QAA->(DbSkip())
		EndDo
	Endif

	If lIntGPE .And. !Empty(lRetorno) .And. lAchou
		MsgAlert(OemToAnsi(STR0008),OemToAnsi(STR0007))  //"A exclusao nao pode ser realizada, porque existe usuario cadastrado nesta funcao!" # "Aten��o"
		lRetorno := .F.
		Return
	Else 
		//Integracao entre PMS x TMK x QNC
		If !lAchou .AND. lIntegra
			If !PA095Del( "AN1",, QAC->QAC_FUNCAO )
				lAchou		:= .T.
			EndIf
		EndIf

		If !lAchou
			Begin Transaction
				RecLock("QAC",.F.)                                                
				QAC->(DbDelete())
				MsUnlock()
			End Transaction
			QAC->(DbSkip())
			lRetorno := .T.
		Else
			HELP(' ',1,'EXISTEUSR')
			lRetorno := .F.
		Endif
	Endif
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QD160Exp  � Autor � Totvs                 � Data � 28/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para exportar os cargos para o cadastro de funcoes  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD160Exp()
Local aArea	:= QAC->( GetArea() )
Local aAuto	:= {}
Local lShow	:= .T.
Local nOpca
Local cNivSup
Local nTamFld	:= 9
Local cAuxFunc

Private lMsErroAuto	:= .F.

DbSelectArea( "QAC" )
QAC->( DbSetOrder( 1 ) )
QAC->( DbSeek( xFilial( "QAC" ) ) )
While QAC->( !Eof() ) .AND. QAC->QAC_FILIAL == xFilial( "QAC" )
	lMsErroAuto := .F.
	lShow		:= .T.

	If TamSX3("AN1_CODIGO")[1] < TamSX3("QAC_FUNCAO")[1] 
		cAuxFunc :=  "SubStr(QAC->QAC_FUNCAO, 1, TamSX3('AN1_CODIGO')[1])"
	Else
		cAuxFunc :=  "QAC->QAC_FUNCAO"
	EndIf

	DbSelectArea( "AN1" )
	AN1->( DbSetOrder( 1 ) )
	If AN1->( DbSeek( xFilial( "AN1" ) + &cAuxFunc + "1" ) )
		nOpca := 4
		cNivSup := AN1->AN1_NIVSUP
	Else
		nOpca := 3
		cNivSup := ""
	EndIf
	cNivSup := QAC->QAC_NIVSUP
	
	aAuto	:= {}
	aAdd( aAuto, { "AN1_INTQNC" , "1", 									Nil } )
	aAdd( aAuto, { "AN1_CODIGO" , PadR( QAC->QAC_FUNCAO, nTamFld ),	Nil } )
	aAdd( aAuto, { "AN1_DESCRI" , QAC->QAC_DESC,   						Nil } )
	aAdd( aAuto, { "AN1_NIVSUP" , cNivSup,								Nil } )
	MSExecAuto( {|x,y| PMSA095( x, y ) }, aAuto, nOpca )

	If lMsErroAuto
		MostraErro()
		lShow	:= .F.
	EndIf

	QAC->( DbSkip() )
End

If lShow
	MsgAlert( "Os cargos foram exportados com sucesso!" ) //"Os cargos foram exportados com sucesso!"
EndIf

RestArea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QA160Vld  � Autor � Marcelo Akama         � Data � 11/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para validar o codigo do nivel superior             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA160Vld( cCodigo )                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = codigo da funcao superior a ser validado           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QA160Vld()
Local aArea		:= GetArea()
Local aAreaQAC	:= QAC->( GetArea() )
Local lRet		:= .T.

If M->QAC_NIVSUP == M->QAC_FUNCAO
	lRet := .F.
Else
	lRet := QA160Loop( M->QAC_NIVSUP, Upper( M->QAC_FUNCAO ) )
EndIf

If !lRet
	Help( " ", 1, "Q160LOOP",, STR0012, 1, 0 ) // "Este codigo causar� refer�ncia circular e n�o pode ser usado! Selecione outro c�digo."
EndIf

RestArea( aAreaQAC )
RestArea( aArea )
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QA160Loop � Autor � Marcelo Akama         � Data � 11/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para verificar recursividade ao informar o niv.sup  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA160Loop( cCodigo )                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = codigo da funcao superior a ser validado           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QA160Loop( cCodigo, cCodSup )
Local aArea		:= GetArea()
Local aAreaQAC	:= QAC->( GetArea() )
Local lRet		:= Empty( cCodigo )

If !lRet
	DbSelectArea( "QAC" )
	QAC->( DbSetOrder( 1 ) )
	If QAC->( DbSeek( xFilial( "QAC" ) + cCodigo ) )
		If QAC->QAC_NIVSUP == cCodSup
			lRet := .F.
		Else
			lRet := QA160Loop( QAC->QAC_NIVSUP, cCodSup )
		EndIf
	Else
		lRet := .T.
	EndIf
EndIf

RestArea( aAreaQAC )
RestArea( aArea )
Return lRet                
