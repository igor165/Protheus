#Include "MATA999.CH"
#Include "FIVEWIN.CH"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � MATA999  � Autor � Sergio S. Fuzinaka      � Data � 22.11.01 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de Vinculo Empresas x Zonas Fiscais (SFH)           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe e � MATA999(ExpA1,ExpN1)                                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array da Rotina Automatica                           ���
���          � ExpN1 - Numero da Opcao                                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS   �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Marco A.   �21/02/16� MMI-149�Se realiza replica para V12.1.14 del      ���
���            �        �        �llamado TDVGIT de V11.8, el cual soluciona���
���            �        �        �error al modificar un registro en la tabla���
���            �        �        �SFH - Emp. vs Z. Fiscal (ARG)             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MATA999(aRotAuto, nOpc)

	Private aAC 	:= {STR0001, STR0002}	//"Abandona"###"Confirma"
	Private aRotina	:= MenuDef()

	//���������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes  �
	//�����������������������������������������������
	Private cCadastro := OemtoAnsi(STR0008)	// "Atualizacao do Cadastro de Vinculo Empresa x Zona Fiscal"

	//��������������������������������������������������������Ŀ
	//� Definicao de variaveis utilizadas na rotina automatica �
	//����������������������������������������������������������
	Private Inclui := .F.
	Private Altera := .F.

	//��������������������������������������������������������������Ŀ
	//� Definicao de variaveis para rotina de inclusao automatica    �
	//����������������������������������������������������������������
	Private l999Auto := ( aRotAuto <> NIL )
	
	nOpc := IIf(nOpc == Nil, 3, nOpc)

	//�����������������������������Ŀ
	//� Endereca a funcao de BROWSE �
	//�������������������������������
	If l999Auto
		dbSelectArea("SFH")
		MsRotAuto(nOpc, aRotAuto, "SFH")
	Else
		dbSelectArea("SFH")
		mBrowse(6, 1, 22, 75, "SFH")
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A999Inclui� Autor � Sergio S. Fuzinaka    � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Inclusao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A999Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA999()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999Inclui(cAlias, nReg, nOpc)
	Local aArea
	Local nOpcA := 0

	Private lInclui:= .T.
	
	//�������������������������������������������Ŀ
	//� Variaveis utilizadas na rotina automatica �
	//���������������������������������������������
	Inclui := .T.
	Altera := .F.
	
	If (l999Auto)
		nOpcA := AxIncluiAuto(cAlias,"A999TudoOk()")
	Else
		nOpcA:=AxInclui(cAlias,nReg,nOpc,,,,"A999TudoOk()")
	EndIf
	aArea:=SFH->(GetArea())
	IF nOpcA == 1
		If SFH->FH_TIPO=="V"
			If !Empty(SFH->FH_FORNECE)
				cCodigo:=SFH->FH_FORNECE
				cLoja:=SFH->FH_LOJA         
				cWhile:= FH_FORNECE + FH_LOJA
				DbSetOrder(1)
			Else
				cCodigo:=SFH->FH_CLIENTE
				cLoja:=SFH->FH_LOJA
				cWhile:= "FH_CLIENTE + FH_LOJA"
				DbSetOrder(3)
			EndIf

			DbGotop()
			DbSeek(xFilial("SFH")+cCodigo + cLoja)
			While(xFilial("SFH")+cCodigo + cLoja== FH_FILIAL + cWhile .And. !EOF())
				If !Empty(FH_TIPO) .And. FH_TIPO<> "N"
					RecLock("SFH",.F.)
					If FH_TIPO=="X"
						Replace FH_ISENTO with "S"
					EndIf
					MsUnLock()
				EndIf 
				DbSkip()	
			EndDo		
		EndIf
	Endif
	SFH->(RestArea(aArea))
	dbSelectArea(cAlias)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A999Altera� Autor � Sergio S. Fuzinaka    � Data � 30.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Alteracao                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A999Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA999()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999Altera(cAlias,nReg,nOpc)

	Local nOpcA := 0
	Private lInclui := IIf(nOpc == 4, .F., .T.)

	l999Auto := If(Type("l999Auto") == "U", .F.,l999Auto)

	//�������������������������������������������Ŀ
	//� Variaveis utilizadas na rotina automatica �
	//���������������������������������������������
	Inclui := .F.
	Altera := .T.

	If (l999Auto)
		nOpcA := AxIncluiAuto(cAlias,,,nOpc,SFH->(RecNo()))
	Else
		nOpcA:=AxAltera(cAlias,nReg,nOpc,,,,,"A999TudoOk()")
	EndIf

	dbSelectArea(cAlias)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A999TudoOk� Autor � Sergio S. Fuzinaka    � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Consistencia do registro                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A999TudoOk()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA999()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999TudoOk()

	Local lRet := .F.

	If !Empty(M->FH_FORNECE) .Or. !Empty(M->FH_CLIENTE)
		lRet:= .T.
		If !Empty(M->FH_FORNECE)
			lRet:=	ExistReg("",M->FH_FORNECE,M->FH_LOJA, M->FH_IMPOSTO, M->FH_ZONFIS)  
		Else
			lRet:=	ExistReg(M->FH_CLIENTE,"",M->FH_LOJA, M->FH_IMPOSTO, M->FH_ZONFIS)  
		Endif
	Else
		MsgAlert(OemtoAnsi(STR0011),OemToAnsi(STR0010))	
		lRet := .F.
	Endif

Return (lRet)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ExistReg  � Autor � Graziele Paro         � Data � 17.12.12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Verifica se j� existe o registro                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   |ExistReg(cCli,cFor,cLoja, cImposto, cZona)                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA999()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/    
Static Function ExistReg(cCli,cFor,cLoja,cImposto,cZona)  

	Local lRet		:= .T.
	Local cForcli	:= 0
	Local cForcli2	:= 0     
	Local lDel		:= .F.

	dbSelectArea("SFH")
	If !(cCli) == ""  
		cForcli:=cCli
		cForcli2:="SFH->FH_CLIENTE" 
		DbSetOrder(3) 
	Else
		cForcli:=cFor
		cForcli2:="SFH->FH_FORNECE"      
		DbSetOrder(1)
	Endif

	If !Empty(cForcli)          				     
		If lInclui .And. DbSeek(xFilial("SFH")+cForcli+cLoja+cImposto+cZona) //Localiza o registro                                                                   
			While (!EOF() .And.  xFilial("SFH")+cForcli+cLoja+cImposto+cZona==SFH->FH_FILIAL+&(cForcli2)+SFH->FH_LOJA +SFH->FH_IMPOSTO+SFH->FH_ZONFIS)  
				lDel := Deleted()
				/*BEGINDOC
				//�������������������������������������������������������Ĵ
				//�Datas Iniciais (cadastro e novo) est�o em branco ou    �
				//�Datas Finais (cadastro e novo) est�o em branco ou      �
				//�Datas Iniciais/Finais (cadastro e novo) est�o em branco�
				//�N�o deixa cadastrar pois j� existe periodo em aberto   �
				//���������������������������������������������������������
				ENDDOC*/
				If (Empty(M->FH_INIVIGE) .And. Empty(SFH->FH_INIVIGE)) ;
				      .Or. (Empty(M->FH_FIMVIGE) .And. Empty(SFH->FH_FIMVIGE));
				      .Or. (Empty(M->FH_INIVIGE)  .And. Empty(SFH->FH_INIVIGE);
				      .And. Empty(M->FH_FIMVIGE) .And. Empty(SFH->FH_FIMVIGE) .And. !lDel)   
					lRet := .F.
					MsgAlert(OemtoAnsi(STR0012),OemToAnsi(STR0010))
				Elseif (!Empty(M->FH_INIVIGE) .And. !Empty(M->FH_FIMVIGE) .And. !Empty(SFH->FH_INIVIGE) .And. !Empty(SFH->FH_FIMVIGE) .And. !lDel)// Se nenhuma data (cadastro e novo) est� em branco 
					/*BEGINDOC
					//�������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
					//�Se a data inicial(Nova) � maior um igual a data inicial (cadastro) e a  Se a data final(Nova) � menor um igual a data inicial (cadastro)  ou     �
					//�Se a data inicial(Nova) � menor ou igual a data inicial (cadastro) e a  Se a data final(Nova) � maior um igual a data inicial (cadastro)  ou     �
					//�Data inicial (nova) � menor ou igual a data final(cadastro) ou                                                                                   �
					//�Data final (nova) � menor ou igual a data inicial(cadastro)   n�o deixa cadastrar, pois j� existe registro neste periodo.                        �
					//���������������������������������������������������������������������������������������������������������������������������������������������������
					ENDDOC*/
					If ((M->FH_INIVIGE >= SFH->FH_INIVIGE) .And.  (M->FH_FIMVIGE <= SFH->FH_FIMVIGE));
						.Or. ((M->FH_INIVIGE <= SFH->FH_INIVIGE) .And.  (M->FH_FIMVIGE >= SFH->FH_FIMVIGE));
						.Or. ((M->FH_INIVIGE >= SFH->FH_INIVIGE) .And.  (M->FH_FIMVIGE >= SFH->FH_FIMVIGE) .And. (M->FH_INIVIGE >= SFH->FH_INIVIGE) .And.(M->FH_INIVIGE <= SFH->FH_FIMVIGE));
						.Or. ((M->FH_INIVIGE <= SFH->FH_INIVIGE) .And.  (M->FH_FIMVIGE <= SFH->FH_FIMVIGE) .And. (M->FH_INIVIGE <= SFH->FH_INIVIGE) .And.(M->FH_INIVIGE >= SFH->FH_FIMVIGE))  
						MsgAlert(OemtoAnsi(STR0013),OemToAnsi(STR0010))
						lRet := .F.       
					Endif   
				EndIf
				DbSkip()
			EndDo
		Else
			lRet := .T. 
		Endif
	Endif
	
Return(lRet)        

/*
���Funcao    �A999Deleta� Autor � Sergio S. Fuzinaka    � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de exclusao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A999Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA999()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999Deleta(cAlias,nReg,nOpc)

	Local nOpcA := 0

	l999Auto := If (Type("l999Auto") =="U",.F.,l999Auto)

	//�������������������������������������������Ŀ
	//� Monta tela de exclusao de dados do arquivo�
	//���������������������������������������������
	Private aTELA[0][0], aGETS[0]
	
	IF !SoftLock(cAlias)
		Return
	Endif

	If !( l999Auto )
		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }                                        
		aPosObj := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",OemToAnsi(STR0009),,aPosObj[1] )//"Quanto a exclusao?"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	Else
		nOpcA := 2
	EndIf

	IF nOpcA == 2  
		//����������������������Ŀ
		//� Exclusao do registro �
		//������������������������
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.,.T.)
		dbDelete()
	ENDIF

	MsUnlock()

	dbSelectArea(cAlias)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A999Loja  � Autor � Sergio S. Fuzinaka    � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consiste a Filial                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A999Loja()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA999()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999Loja()

	Local lRet := .T.

	If !Empty(M->FH_FORNECE) .And. !Empty(M->FH_LOJA)
		lRet := ExistCpo("SA2",M->FH_FORNECE+M->FH_LOJA)
	Elseif !Empty(M->FH_CLIENTE) .And. !Empty(M->FH_LOJA)
		lRet := ExistCpo("SA1",M->FH_CLIENTE+M->FH_LOJA)
	Endif

	If lRet
		A999CliFor()
	Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A999CliFor� Autor � Sergio S. Fuzinaka    � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consiste Cliente e Fornecedor                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A999CliFor()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA999()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999CliFor()

	Local cCampo := ReadVar()
	Local aArea  := GetArea()
	Local lRet   := .T.

	If cCampo == "M->FH_CLIENTE" .Or. (cCampo == "M->FH_LOJA" .And. !Empty(M->FH_CLIENTE))
		If !Empty(M->FH_CLIENTE)
			dbSelectArea("SA1")
			dbSetOrder(1)
			If !Empty(M->FH_LOJA)
				IF dbSeek(xFilial()+M->FH_CLIENTE+M->FH_LOJA)
					M->FH_FORNECE := Space(TamSX3("FH_FORNECE")[1])
					M->FH_NOME    := SA1->A1_NOME
				Else
					If !Empty(M->FH_CLIENTE)
						Help("",1,"REGNOIS")						
						lRet := .F.
					Endif
				Endif
			Else
				IF dbSeek(xFilial()+M->FH_CLIENTE)
					M->FH_FORNECE := Space(TamSX3("FH_FORNECE")[1])
					M->FH_NOME    := Space(TamSX3("FH_NOME")[1])
				Else
					Help("",1,"REGNOIS")						
					lRet := .F.
				EndIf	 
			EndIf	
		Endif
	ElseIf cCampo == "M->FH_FORNECE" .Or. (cCampo == "M->FH_LOJA" .And. !Empty(M->FH_FORNECE))
		If !Empty(M->FH_FORNECE)
			dbSelectArea("SA2")
			dbSetOrder(1)
			If !Empty(M->FH_LOJA)
				IF dbSeek(xFilial()+M->FH_FORNECE+M->FH_LOJA)
					M->FH_CLIENTE := Space(TamSX3("FH_CLIENTE")[1])
					M->FH_NOME    := SA2->A2_NOME
				Else
					If !Empty(M->FH_FORNECE)
						Help("",1,"REGNOIS")
						lRet := .F.
					Endif
				Endif
			Else
				IF dbSeek(xFilial()+M->FH_FORNECE)
					M->FH_CLIENTE := Space(TamSX3("FH_CLIENTE")[1])
					M->FH_NOME    := Space(TamSX3("FH_NOME")[1])
				Else
					Help("",1,"REGNOIS")						
					lRet := .F.
				EndIf	 
			EndIf	
		Endif
	Endif                                   

	If (Empty(M->FH_FORNECE) .And. Empty(M->FH_CLIENTE)) .Or. Empty(M->FH_LOJA)
		M->FH_NOME := ""
	Endif

	RestArea( aArea )		

Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()

	Private aRotina := {	{ STR0003, "AxPesqui"  , 0 , 1 , 0 , .F.},;	//"Pesquisar"
							{ STR0004, "AxVisual"  , 0 , 2 , 0 , NIL},;	//"Visualizar"
							{ STR0005, "A999Inclui", 0 , 3 , 0 , NIL},;	//"Incluir"
							{ STR0006, "A999Altera", 0 , 4 , 0 , NIL},;	//"Alterar"
							{ STR0007, "A999Deleta", 0 , 5 , 0 , NIL}}	//"Excluir"

	If ExistBlock("MA999MNU")
		ExecBlock("MA999MNU",.F.,.F.)
	EndIf

Return(aRotina)