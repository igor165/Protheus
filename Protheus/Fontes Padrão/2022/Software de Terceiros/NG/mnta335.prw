#INCLUDE "MNTA335.ch"
#INCLUDE "COLORS.CH"
#Include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � MNTA335  � Autor � Elisangela Costa      � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alteracao do Status da OS                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAMNT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA335()

	//Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := NGBEGINPRM()

	Private aRotina    := MenuDef()
	Private cCADASTRO  := Oemtoansi(STR0001)  //"Altera��o de Status da OS"
	Private aCORES335  := {}
	Private aCORESSTA  := {}
	Private aIndSTJ    := {}
	Private bFiltraBrw := {|| Nil}
	Private cRetPar    := ""
	aPOS1 := {15,1,95,315}
	dbSelectArea("STJ")

	ccondicao := 'STJ->TJ_FILIAL = "'+ xFilial("STJ")+'"'+'.And. '
	ccondicao += 'STJ->TJ_LUBRIFI <> "S" .And. STJ->TJ_TERMINO = "N" .And.'
	ccondicao += 'STJ->TJ_SITUACA = "P"  .And. STJ->TJ_ORDEPAI = "' +  Space(Len(STJ->TJ_ORDEPAI)) + '"'
	ccondicao += '.And. MNT335FIL()'

	MNT335GLE()

	If Len(aCORESSTA) < 6
		MsgInfo(STR0018+CHR(13)+; //"N�o foi cadastrado todos os tipos de status. Cadastre todos os tipos de status"
				STR0019,STR0005)  //"na rotina de cadastramento de status da OS."# "N�O CONFORMIDADE"
		Return .T.
	EndIf

	aCores := {{"TJ_STFOLUP = '"+aCORESSTA[1][1]+"'" ,aCORESSTA[1][2]},;
			   {"TJ_STFOLUP = '"+aCORESSTA[2][1]+"'" ,aCORESSTA[2][2]},;
			   {"TJ_STFOLUP = '"+aCORESSTA[3][1]+"'" ,aCORESSTA[3][2]},;
			   {"TJ_STFOLUP = '"+aCORESSTA[4][1]+"'" ,aCORESSTA[4][2]},;
			   {"TJ_STFOLUP = '"+aCORESSTA[5][1]+"'" ,aCORESSTA[5][2]},;
			   {"TJ_STFOLUP = '"+aCORESSTA[6][1]+"'" ,aCORESSTA[6][2]}}

	bFiltraBrw := {|| FilBrowse("STJ",@aIndSTJ,@cCondicao) }
	Eval(bFiltraBrw)

	nINDSTJ := INDEXORD()

	mBrowse(6,1,22,75,"STJ",,,,,,aCores)
	aEval(aIndSTJ,{|x| Ferase(x[1]+OrdBagExt())})
	ENDFILBRW("STJ",aIndSTJ)

	dbSelectArea("STJ")
	Set Filter To
	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFILIAL("STJ"))

	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT335FIL � Autor �Elisangela Costa       � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Filtra as OS de Aguardando Programacao                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA335                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT335FIL()

	Local lRETOSFIL := .F.

	dbSelectArea("TQW")
	dbSetOrder(01)
	If dbSeek(xFilial("TQW")+STJ->TJ_STFOLUP)
		If TQW->TQW_TIPOST <> "7 "
			lRETOSFIL := .T.
		EndIf
	EndIf
	dbSelectArea("STJ")

Return lRETOSFIL

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT335BOTF � Autor �Elisangela Costa      � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Filtra as OS do Browse conforme filtro                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA335                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT335BOTF()

	dbSelectArea("STJ")
	ENDFILBRW("STJ",aIndSTJ)
	cRetPar   := BuildExpr("STJ",,cRetPar,.F.)
	ccondicao := " "

	If !Empty(cRetPar)

		ccondicao := 'STJ->TJ_FILIAL = "'+ xFilial("STJ")+'"'+'.And. '
		ccondicao += 'STJ->TJ_LUBRIFI <> "S" .And. STJ->TJ_TERMINO = "N" .And.'
		ccondicao += 'STJ->TJ_SITUACA = "P"  .And. STJ->TJ_ORDEPAI = "' +  Space(Len(STJ->TJ_ORDEPAI)) + '"'
		ccondicao += '.And. MNT335FIL() .And.'
		ccondicao +=  cRetPar

		dbSelectArea("STJ")
		Set Filter To
		bFiltraBrw := {|| FilBrowse("STJ",@aIndSTJ,@cCondicao) }
		Eval(bFiltraBrw)

	Else

		ccondicao := 'STJ->TJ_FILIAL = "'+ xFilial("STJ")+'"'+'.And. '
		ccondicao += 'STJ->TJ_LUBRIFI <> "S" .And. STJ->TJ_TERMINO = "N" .And.'
		ccondicao += 'STJ->TJ_SITUACA = "P"  .And. STJ->TJ_ORDEPAI = "' +  Space(Len(STJ->TJ_ORDEPAI)) + '"'
		ccondicao += '.And. MNT335FIL()'

		dbSelectArea("STJ")
		bFiltraBrw := {|| FilBrowse("STJ",@aIndSTJ,@cCondicao) }
		Eval(bFiltraBrw)

	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA335ST � Autor �Elisangela Costa       � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Permite alterar o campo de status e observacao da OS        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA335                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNTA335ST()

	Local bValid     := {|| }
	Local aField     := {}
	Local oSize      := FwDefSize():New(.T.)
	Local nLinIniTla := oSize:aWindSize[1] // Linha  inicial da tela
	Local nColIniTla := oSize:aWindSize[2] // Coluna inicial da tela
	Local nLinFimTla := oSize:aWindSize[3] // Linha  final   da tela
	Local nColFimTla := oSize:aWindSize[4] // Coluna final   da tela
	Local aPos 	     := {0,0,0,0}
	Local cValid     := ""
	Local cNivel := ""
	Local cRelacao := ""
	Local cWhen := ""
	Local cFolder := ""
	Local cPictVar := ""
	Local cTrigger := ""
	Local cF3 := ""

	Private cSTASALVO := ""
	Private oEnch     := Nil

	If Empty(Posicione("SX3",2,"TQW_STATUS","X3_VALID"))
		bValid := {||Naovazio() .And. MNT335VSTA(M->TQW_STATUS)}
	Else
		cValid := AllTrim(Posicione("SX3",2,"TQW_STATUS","X3_VALID"))
		bValid := {||Naovazio() .And. MNT335VSTA(M->TQW_STATUS) .And. &cValid}
	EndIf

	cNivel := Posicione("SX3",2,"TQW_STATUS","X3_NIVEL")
	cRelacao := Posicione("SX3",2,"TQW_STATUS","X3_RELACAO")
	cWhen := Posicione("SX3",2,"TQW_STATUS","X3_WHEN")
	cFolder := Posicione("SX3",2,"TQW_STATUS","X3_FOLDER")
	cPictVar := Posicione("SX3",2,"TQW_STATUS","X3_PICTVAR")
	cTrigger := Posicione("SX3",2,"TQW_STATUS","X3_TRIGGER")

	aAdd(aField,{X3TITULO(),"TQW_STATUS", TamSX3("TQW_STATUS")[3], TamSX3("TQW_STATUS")[1], TamSX3("TQW_STATUS")[2], X3Picture(""), bValid, .T., cNivel, cRelacao, "TQW", cWhen, .F., .F., X3CBox(), Val(cFolder), .F., cPictVar, cTrigger})

	cNivel := Posicione("SX3",2,"TQW_DESTAT","X3_NIVEL")
	cRelacao := Posicione("SX3",2,"TQW_DESTAT","X3_RELACAO")
	cWhen := Posicione("SX3",2,"TQW_DESTAT","X3_WHEN")
	cFolder := Posicione("SX3",2,"TQW_DESTAT","X3_FOLDER")
	cPictVar := Posicione("SX3",2,"TQW_DESTAT","X3_PICTVAR")
	cTrigger := Posicione("SX3",2,"TQW_DESTAT","X3_TRIGGER")
	cF3 := Posicione("SX3",2,"TQW_DESTAT","X3_F3")

	aAdd(aField,{X3TITULO(),"TQW_DESTAT", TamSX3("TQW_DESTAT")[3], TamSX3("TQW_DESTAT")[1], TamSX3("TQW_DESTAT")[2], X3Picture(""), bValid, .T., cNivel, cRelacao, cF3, {||.F. }, .F., .F., X3CBox(), Val(cFolder), .F., cPictVar, cTrigger})

	cNivel := Posicione("SX3",2,"TQ9_MOTALT","X3_NIVEL")
	cRelacao := Posicione("SX3",2,"TQ9_MOTALT","X3_RELACAO")
	cWhen := Posicione("SX3",2,"TQ9_MOTALT","X3_WHEN")
	cFolder := Posicione("SX3",2,"TQ9_MOTALT","X3_FOLDER")
	cPictVar := Posicione("SX3",2,"TQ9_MOTALT","X3_PICTVAR")
	cTrigger := Posicione("SX3",2,"TQ9_MOTALT","X3_TRIGGER")
	cF3 := Posicione("SX3",2,"TQW_DESTAT","X3_F3")

	aAdd(aField,{X3TITULO(),"TQ9_MOTALT", TamSX3("TQ9_MOTALT")[3], TamSX3("TQ9_MOTALT")[1], TamSX3("TQ9_MOTALT")[2], X3Picture(""), bValid, .T., cNivel, cRelacao, cF3, cWhen, .F., .F., X3CBox(), Val(cFolder), .F., cPictVar, cTrigger})

	dbSelectArea("STJ")
	M->TQW_STATUS := STJ->TJ_STFOLUP
	M->TQW_DESTAT := NGSEEK("TQW",STJ->TJ_STFOLUP,1,"SubStr(TQW_DESTAT,1,40)")
	M->TQ9_MOTALT := Space(TamSX3('TQ9_MOTALT')[1])
	cSTASALVO     := STJ->TJ_STFOLUP

	nOpcc := 0

	 //"Alteracao do Status da OS:"
	Define MsDialog oDlgOS From nLinIniTla,nColIniTla TO nLinFimTla,nColFimTla Title STR0016 Pixel STYLE nOR(WS_VISIBLE,WS_POPUP)

		oPanelTot        := TPanel():Create(oDlgOS,0,0,,,.F.,,,CLR_WHITE,0,0)
		oPanelTot:Align  := CONTROL_ALIGN_ALLCLIENT

		oEnch            := MsmGet():New(,0,4,,,,,aPos,,,,,,oPanelTot,,,,,,.T.,aField,,.T.)
		oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate Msdialog oDlgOS On Init EnchoiceBar(oDlgOS,{||nOpcc:=1,If(!MNTA335VAL(M->TQW_STATUS,cSTASALVO),nOpcc := 0,oDlgOS:End())},{||oDlgOS:End()})

	If nOpcc == 1

		dbSelectArea("STJ")
		RecLock("STJ",.F.)
		STJ->TJ_STFOLUP := M->TQW_STATUS
		STJ->(MsUnLock())

		dbSelectArea("TQ9")
		RecLock("TQ9",.T.)
		TQ9->TQ9_FILIAL := xFilial("TQ9")
		TQ9->TQ9_ORDEM  := STJ->TJ_ORDEM
		TQ9->TQ9_PLANO  := STJ->TJ_PLANO
		TQ9->TQ9_USUARI := cUserName
		TQ9->TQ9_STAORI := cSTASALVO
		TQ9->TQ9_STAALT := M->TQW_STATUS
		TQ9->TQ9_DATAAL := dDATABASE
		TQ9->TQ9_HRALTE := Substr(TIME(),1,5)
		TQ9->TQ9_MOTALT := M->TQ9_MOTALT
		TQ9->(MsUnLock())

		dbSelectArea("STJ")
		Set Filter To
		bFiltraBrw := {|| FilBrowse("STJ",@aIndSTJ,@cCondicao) }
		Eval(bFiltraBrw)

		If ExistBlock("MNTA3352")
		If cSTASALVO <> M->TQW_STATUS
			ExecBlock("MNTA3352",.F.,.F.,{TQ9->TQ9_ORDEM,TQ9->TQ9_PLANO,TQ9->TQ9_STAALT})
		EndIf
	EndIf

	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT335VSTA� Autor �Elisangela Costa       � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o status da OS                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA335ST                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNT335VSTA(cSTATUS)

	If !EXISTCPO("TQW",cSTATUS)
		dbSelectArea("STJ")
		Return .F.
	Endif

	dbSelectArea("TQW")
	dbSetOrder(01)
	If dbSeek(xFilial("TQW")+cSTATUS)
		M->TQW_DESTAT := SubStr(TQW->TQW_DESTAT,1,40)
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA335VAL� Autor �Elisangela Costa       � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida alteracao de status no botao de ok                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA335ST                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MNTA335VAL(cSTATUS,cSTATUSAL)

	If cSTATUSAL == cSTATUS
		MsgInfo(STR0004,STR0005) //"O Status da OS n�o foi alterado, altere o status."###"N�O CONFORMIDADE"
		Return .F.
	EndIf

	If X3Obrigat("TQ9_MOTALT") .And. Empty(M->TQ9_MOTALT)
		MsgInfo(STR0021,STR0005) //"A motivo da altera��o n�o foi informado."###"N�O CONFORMIDADE"
		Return .F.
	EndIf

	If Empty(M->TQW_STATUS)
		MsgInfo(STR0022,STR0005) //"O Status da altera��o n�o foi informado."###"N�O CONFORMIDADE"
		Return .F.
	EndIf

	If Empty(M->TQW_DESTAT)
		MsgInfo(STR0023,STR0005) //"A descri��o do status n�o foi informado."###"N�O CONFORMIDADE"
		Return .F.
	EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �MNT335GLE � Autor � Elisangela Costa      � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Carrega a array com a informacoes de legenda e samafaro     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT335GLE()

	Local xt

	For xt := 1 To 6

		dbSelectArea("TQW")
		dbSetOrder(03)
		If dbSeek(xFilial("TQW")+Str(xt,1)+" ")

			If xt == 1
				M->TQW_DESTAT := STR0006 //"Programada com Altera��o de Data"
			ElseIf xt == 2
				M->TQW_DESTAT := STR0007 //"Aguardando Material"
			ElseIf xt == 3
				M->TQW_DESTAT := STR0008 //"Aguardando M�o de Obra"
			ElseIf xt == 4
				M->TQW_DESTAT := STR0009 //"Aguardando Ferramenta"
			ElseIf xt == 5
				M->TQW_DESTAT := STR0010 //"Aguardando Equiptos Auxiliares"
			Else
				M->TQW_DESTAT := STR0011 //"Aguardando Programacao"
			End

			If TQW->TQW_CORSTA = "1 "
				Aadd(aCORES335,{"BR_PINK",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_PINK"})
			ElseIf TQW->TQW_CORSTA = "2 "
				Aadd(aCORES335,{"BR_VERMELHO",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_VERMELHO"})
			ElseIf TQW->TQW_CORSTA = "3 "
				Aadd(aCORES335,{"BR_AMARELO",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_AMARELO"})
			ElseIf TQW->TQW_CORSTA = "4 "
				Aadd(aCORES335,{"BR_AZUL",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_AZUL"})
			ElseIf TQW->TQW_CORSTA = "5 "
				Aadd(aCORES335,{"BR_VERDE",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_VERDE"})
			ElseIf TQW->TQW_CORSTA = "6 "
				Aadd(aCORES335,{"BR_PRETO",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_PRETO"})
			ElseIf TQW->TQW_CORSTA = "7 "
				Aadd(aCORES335,{"BR_LARANJA",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_LARANJA"})
			ElseIf TQW->TQW_CORSTA = "8 "
				Aadd(aCORES335,{"BR_CINZA",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_CINZA"})
			ElseIf TQW->TQW_CORSTA = "9 "
				Aadd(aCORES335,{"BR_MARRON",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_MARRON"})
			Else
				Aadd(aCORES335,{"BR_BRANCO",M->TQW_DESTAT})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_BRANCO"})
			EndIf
		EndIf

	Next xt

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Elisangela Costa       � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

	Local aRotina := {{STR0012,"PesqBrw"  ,0,1},; //"Pesquisar"
					  {STR0013,"NGCAD01"  ,0,2},; //"Visualizar"
					  {STR0014,"MNT335LEG",0,3},; //"Legenda"
					  {STR0015,"MNTA335ST",0,4}}  //"Alt. Status"

	If ExistBlock("MNTA3351")
		_aRotina := ExecBlock("MNTA3351",.F.,.F.,{aRotina})
		If (ValType(_aRotina) == "A")
			aRotina := ACLONE(_aRotina)
		EndIf
	EndIf

Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNT335LEG � Autor � Elisangela Costa      � Data �27/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Monta a legenda                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT335LEG()

	NGLEGENDA(cCadastro,STR0014,aCORES335) //"Legenda"

Return .T.
