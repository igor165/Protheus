#INCLUDE "QAXA070.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QAXA070    � Autor � Eduardo de Souza   � Data � 23/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Cadastro de Normas                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QAXA070()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QUALITY                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���   Data   �  BOPS  � Programador � Alteracao                           ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui"	,	0, 1,,.F.},; // 'Pesquisar'
				 {OemToAnsi(STR0002),"QX070Telas",	0, 2},; // 'Visualizar'
				 {OemToAnsi(STR0003),"QX070Telas",	0, 3},; // 'Incluir'
				 {OemToAnsi(STR0004),"QX070Telas",	0, 4},; // 'Alterar'
				 {OemToAnsi(STR0005),"QX070Telas",	0, 5} } // 'Excluir'

Return aRotina

Function QAXA070()

Private cCadastro:= OemToAnsi(STR0006) // 'Cadastro de Normas'
Private aRotina  := MenuDef()

DbSelectArea("QAK")
DbSetOrder(1)
DbGoTop()

mBrowse(006,001,022,075,"QAK")

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QX070Telas� Autor � Eduardo de Souza      � Data � 23/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Normas                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QX070Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX070Telas(cAlias,nReg,nOpc)

Local nI       := 0
Local nOpcao   := 0
Local nSaveSX8 := GetSX8Len()
Local oDlg     := Nil

Private aGETS      := {}
Private aTELA      := {}
Private bCampo     := {|nCPO| Field( nCPO ) }
Private lFwExecSta := FindClass( Upper("FwExecStatement") )


DbSelectArea("QAK")
DbSetOrder(1)

If nOpc == 3 
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, 'X3_RELACAO') )
          
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, 'X3_TAMANHO') )
          EndIf
          If M->&( cCampo ) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
   Next nI
	M->QAK_FILIAL:= xFilial("QAK") 
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Cadastro de Normas"

Enchoice("QAK",nReg,nOpc,,,,,{032,002,190,312})

If nOpc == 3 .Or. nOpc == 4
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. QX070GrNor(nOpc),(nOpcao:= 1,oDlg:End()),.F.)},{|| oDlg:End()}) CENTERED
ElseIf nOpc == 2 .Or. nOpc == 5
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc == 5,If(QX070Dele(),oDlg:End(),),oDlg:End())},{|| oDlg:End()}) CENTERED	
EndIf

IF nOpc == 3
	While (GetSX8Len() > nSaveSx8)
		If nOpcao == 1
		   	ConfirmSX8()		
		Else
			RollBackSX8()
		Endif
	Enddo
Endif

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QX070GrNor� Autor � Eduardo de Souza      � Data � 23/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Normas                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QX070GrNor(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX070GrNor(nOpc)

Local lRecLock:= .F.
Local nI      := 0

If nOpc == 3
	lRecLock:= .T.
EndIf

Begin Transaction
	
	RecLock("QAK",lRecLock)
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	QAK->(MsUnLock())
	
End Transaction
	
Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QX070Dele  � Autor � Eduardo de Souza   � Data � 23/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Normas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QX070Dele()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QAXA070                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QX070Dele()
Local cAliasQDH := GetNextAlias()
Local cAliasQDV := GetNextAlias()
Local cQuery    := ""
Local lQDHAchou := .F.
Local lQDVAchou := .F.
Local lRet      := .F.
Local oExec     := Nil

DEFAULT lFwExecSta := .F. //Para facilitar a cobertuar de c�digo n�o declarar essa variavel na user function

If nModulo == 24 // SIGAQDO
	
	If !lFwExecSta
		//Verifica se tem registros na QDH
		cQuery := " SELECT QDH.R_E_C_N_O_ "
		cQuery += "   FROM " + RetSqlName("QDH") + " QDH "
		cQuery += "  WHERE QDH.QDH_NORMA = '" + QAK->QAK_NORMA + "' "
		cQuery += "    AND QDH.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQDH)

		//Verifica se tem registros na QDV
		cQuery := " SELECT QDV.R_E_C_N_O_ "
		cQuery += "   FROM " + RetSqlName("QDV") + " QDV "
		cQuery += "  WHERE QDV.QDV_NORMA = '" + QAK->QAK_NORMA + "' "
		cQuery += "    AND QDV.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQDV)

	Else
		//Verifica se tem registros na QDH
		cQuery := " SELECT QDH.R_E_C_N_O_ "
		cQuery += "   FROM " + RetSqlName("QDH") + " QDH "
		cQuery += "  WHERE QDH.QDH_NORMA  = ? "
		cQuery += "    AND QDH.D_E_L_E_T_  = ' ' "
		oExec := FwExecStatement():New(cQuery)
		oExec:setString( 1, QAK->QAK_NORMA )
		cAliasQDH := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 

		//Verifica se tem registros na QDV
		cQuery := " SELECT QDV.R_E_C_N_O_ "
		cQuery += "   FROM " + RetSqlName("QDV") + " QDV "
		cQuery += "  WHERE QDV.QDV_NORMA  = ? "
		cQuery += "    AND QDV.D_E_L_E_T_  = ' ' "
		oExec := FwExecStatement():New(cQuery)
		oExec:setString( 1, QAK->QAK_NORMA )
		cAliasQDV := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 
		
	EndIf

	If &(cAliasQDH+"->(!Eof())")
		lQDHAchou := .T.
	EndIf
	&(cAliasQDH+"->(DbCloseArea())")

	If &(cAliasQDV+"->(!Eof())")
		lQDVAchou := .T.
	EndIf
	&(cAliasQDV+"->(DbCloseArea())")

	If !lQDHAchou .AND. !lQDVAchou //Se n�o tem registro vinculado nem na QDV nem QDH, deleta
		Begin Transaction
			If RecLock("QAK",.F.)
				QAK->(DbDelete())
				QAK->(MsUnlock())
				QAK->(DbSkip())
			Endif
		End Transaction
		lRet := .T.
	Else
		Help(" ",1,"QD_DCTOEXT") // Existe documentos cadastrados associados a esta informacao.
	EndIf

Endif

Return lRet
