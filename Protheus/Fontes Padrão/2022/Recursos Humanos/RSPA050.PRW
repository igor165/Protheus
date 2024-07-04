#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FOLDER.CH"
#INCLUDE "RSPA050.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSPA050  ³ Autor ³ Cristina Ogura        ³ Data ³  13.11.97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de cadastramento das questoes e alternativas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPA050()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/2014³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³          ³      ³da a limpeza.                             ³±±
±±³Cecilia Car.³30/09/2014³TQGQAC³Alteracao efetuada para alertar o usuario ³±±
±±³            ³          ³      ³a preencher os dados da aba Alteranativa  ³±±
±±³            ³          ³      ³quando o campo QO_ESCALA nao for preenchi ³±±
±±³            ³          ³      ³do.                                       ³±±
±±³Cecilia Car.³06/10/2014³TQSV71³Alteracao efetuada para alertar o usuario ³±±
±±³            ³          ³      ³quando preencher o campo 'Alternativa'    ³±±
±±³            ³          ³      ³(QO_ESCALA) e os dados da aba Alternativa.³±±
±±³Willian U.  ³10/07/2017³ DRHPONTP-29 ³Ajuste realizado para que o campo Descrição³±±
±±³            ³          ³             ³Detalhada seja salvo na alteração, mesmo   ³±±
±±³            ³          ³             ³que sem conteúdo.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA050()

Local aArea			:= GetArea()
Local aAreaSQP		:= SQP->( GetArea() )
Local aAreaSQQ		:= SQQ->( GetArea() )
Local aAreaSQO		:= SQO->( GetArea() )
Local cFiltraSQO	:= ""

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³So Executa se o Modo de Acesso dos Arquivos SQO e SQP   estive³
³rem OK (Devem ser iguais)									   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF xRetModo( "SQO" , "SQP" , .T. ) .And. fUsoSqoSqp()

	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	Private aIndexSQO	:= {}
	Private bFiltraBrw	:= { || NIL }
	Private cCadastro	:= OemToAnsi(STR0006) //"Questoes e Alternativas"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Aceita acentuacoes									   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	__lAcento := .T.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Seleciona a Area do Cadastro de Questoes              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SQO")

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Quando Modulo APD (Avaliacao e Pesquisa de Desempenho)³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( cModulo == "APD" )
		cFiltraSQO := "QO_TIPO == 'APD'"
	Else
		cFiltraSQO := "QO_TIPO <> 'APD'"
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Filtra o Arquivo de Questoes                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	bFiltraBrw 	:= { || FilBrowse( "SQO" , @aIndexSQO , @cFiltraSQO ) }
	Eval( bFiltraBrw )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Endereca a funcao de BROWSE 					       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	mBrowse( 6 , 1 , 22 , 75 , "SQO" , NIL , NIL , NIL , NIL , NIL ,Rspa050MrkBrw() )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Deleta o filtro utilizando a funcao FilBrowse		   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	EndFilBrw( "SQO" , aIndexSQO )

EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura os Dados de Entrada 											 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aAreaSQP )
RestArea( aAreaSQQ )
RestArea( aAreaSQO )
RestArea( aArea )

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSP050Rot³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de controle dos dados das questoes e alternativas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSP050Rot(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo 								  ³±±
±±³ 		 ³ ExpN1 = Numero do registro								  ³±±
±±³ 		 ³ ExpN2 = Numero da opcao Selecionada						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA050  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RSP050Rot(cAlias1,nReg,nOpcx)

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords 	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords 	:= {}
Local aPages		:= {}
Local aTitles		:= {}
Local aSaveArea 	:= GetArea()
Local bCampo		:= { |nCPO| Field(nCPO) }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local lGetd 		:= .F.
Local lOpcOk		:= .F.
Local nControl		:= 0
Local nI			:= 0
Local nFCount		:= 0
Local oDlgFolder	:= NIL
Local oNome			:= NIL
Local oFont			:= NIL
Local oGetDados		:= NIL
Local oEnchoice		:= NIL

Private oFolder
Private cNome		:= ""
Private aCols		:= {}
Private aHeader 	:= {}
Private nOpcao 		:= nOpcx
Private nGetSX8Len := GetSX8Len()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SQO",aIndexSQO)
	aIndexSQO := {}
	SQO->( MsGoto(nReg) )

	Begin Sequence

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lock do Registro quanto Alteracao ou Exclusao		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ( ( nOpcX == 4 ) .or. ( nOpcx == 5 ) )
			IF !( SoftLock( "SQO" ) )
				Break
			EndIF
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura‡Æo da Enchoice  - Folder 01				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SQO")
		SQO->( dbSetOrder(1) )
		nFCount := SQO->( FCount() )
		For nI := 1 To nFCount
			M->&(Eval(bCampo,nI)) := SQO->( FieldGet(nI) )
			If ( nOpcao == 3 )		// inclusao
				If ( lInit := ExistIni(Eval(bCampo,nI)) )
					M->&(Eval(bCampo,nI)) := InitPad(SX3->X3_RELACAO)
					If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
						M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)),SX3->X3_TAMANHO)
					Endif
					If ( M->&(Eval(bCampo,nI)) == NIL )
						lInit := .F.
					EndIf
				EndIf
				If ( !lInit )
					If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
						M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
					ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
						M->&(Eval(bCampo,nI)) := 0
					ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
						M->&(Eval(bCampo,nI)) := Ctod("  /  /  ")
					ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
						M->&(Eval(bCampo,nI)) := .F.
					EndIf
				EndIf
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura‡Æo da GetDados - Folder 02				 ³
		//³ *** Alternativas das Questoes            			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A050Config("SQP",1,"QP_QUESTAO",nOpcx)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura variaveis do Objeto Folder				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aTitles,OemToAnsi(STR0007)) //"&Questoes"
		Aadd(aTitles,OemToAnsi(STR0008)) //"&Alternativas"
		nControl++

		Aadd(aPages,"HEADER")
		Aadd(aPages,"DETAIL")
		nControl++

		If nOpcao # 2			// Visual
			lGetD :=.T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula as Dimensoes do Dialogo Principal ³
		//³ e do Objeto Folder						  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		aAdv1Size    := MsAdvSize(.F.)//aClone(aObjSize[2])
		aInfo1AdvSize    := { 5 , 3 , aAdv1Size[3] , aAdv1Size[4] , 5 , 5 }
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
		aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords )

		aAdv2Size    := MsAdvSize(.F.)//aClone(aObjSize[2])
		aInfo2AdvSize    := { aAdv2Size[1] , aAdv2Size[2] , aAdv2Size[3] , aAdv2Size[4] , 5 , 5 }
		aAdd( aObj2Coords , { 050 , 000 , .T. , .T. } )
		aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )

		SETAPILHA()
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
		DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			@ aObjSize[1,1],aObjSize[1,2] SAY oNome PROMPT cNome SIZE 300,7 OF oDlgFolder PIXEL FONT oFont
			oFolder := TFolder():New(aObjSize[2,1],aObjSize[2,2],aTitles,aPages,oDlgFolder,NIL,NIL,NIL,.T.,.F.,aObjSize[2,3],aObjSize[2,4])
			oFolder:bSetOption := {|nAtu| A050Muda(nAtu,oFolder:nOption,oNome,M->QO_TIPOOBJ,oEnchoice)}

			For nI := 1 to Len(oFolder:aDialogs)
				oFolder:aDialogs[nI]:oFont := oDlgFolder:oFont
			Next nI

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajusta as Coordenadas da Enchoice e da Get³
			//³ dados para que se ajustem ao objeto Folder³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjSize[2,1] -= 20
			aObjSize[2,2] += 02
			aObjSize[2,3] -= 35
			aObjSize[2,4] -= 02

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 01								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Zero()
			oEnchoice := MsMGet():New("SQO",nReg,nOpcao,,,,,{aObj1Size[1,1],aObj1Size[1,2], aObj1Size[1,3]-55,aObj1Size[1,4]-15},,,,,,oFolder:aDialogs[1],,,.T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 02								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGetDados := MSGetDados():New(aObj2Size[1,1],aObj2Size[1,2],aObj2Size[1,3]-55,aObj2Size[1,4]-15,nOpcao,"A050LinOk","A050TudOk","+QP_ALTERNA",lGetD,,1,,,,,,,oFolder:aDialogs[2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Define os Blocos para os Botoes OK e Cancel³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bSet15 := { || IF( oGetDados:TudoOK() .And. A050Chk(nOpcx,oEnchoice).AND. ParDis() ,(A050Grava( cAlias1 , nReg , nOpcx ), lOpcOk := .T. , oDlgFolder:End()),.F.) }
			bSet24 := { || lOpcOk := .F. , oDlgFolder:End() }

		ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar( oDlgFolder, bSet15  , bSet24 ) CENTERED

		SETAPILHA()

	End Sequence

	IF ( lOpcOk )
		While ( GetSX8Len() > nGetSX8Len )
			ConfirmSX8()
		End While

		RSPA050EPMInt(nOpcx)
	Else
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ RollBack da Numeracao Automatica            				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		While ( GetSX8Len() > nGetSX8Len )
			RollBackSX8()
		End While
	EndIF


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval( bFiltraBrw )
	SQO->( MsGoTo(nReg) )
	SQO->( MsUnLock() )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Restaura Arquivos								       		   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RestArea(aSaveArea)

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050Config³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configura os arrays da Getdados.           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050CONF(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias selecionado								  ³±±
±±³          ³ ExpN1 := Numero do Folder								  ³±±
±±³          ³ ExpC2 := Campos que nao devem aparecer na Getdados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Config(cAlias,nFolder,cString,nOpcx)
Local nUsado	:= 0
Local nCnt		:= 0
Local nI		:= 0
Local cChave	:= ""
Local cQuest	:= ""
Local nSqpOrd	:= RetOrdem("SQP","QP_FILIAL+QP_QUESTAO+QP_ALTERNA")
Local bSeekWhile:= {|| SQP->QP_FILIAL + SQP->QP_QUESTAO }
Local aNoFields	:= {"QP_FILIAL","QP_QUESTAO"}
Local aYesFields:= {"QP_ALTERNA","QP_DESCRIC","QP_PERCENT"}

	If nOpcx # 3	// Diferente de Inclusao
		cQuest	:= SQO->QO_QUESTAO
		cChave 	:= SQO->QO_FILIAL+cQuest
	Else
		cQuest	:= IIF(EMPTY(M->QO_QUESTAO),CriaVar("QO_QUESTAO",.T.),CriaVar("QO_QUESTAO",.F.))
		cChave 	:= xFilial("SQO")+cQuest
	EndIf

	//==> Monta FilGetDados para Walk Thru
	FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				"SQP"					,; //2-cAlias - area a ser utilizada;
				nSqpOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				aYesFields				,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				nOpcx==3				,;	//nOpcx==3 12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
				NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atribui valor inicial ao codigo da alternativa do primeiro registro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcao==3) .Or. Empty(aCols[1][1])		//Inclusao ou arquivo vazio
		aCols[1][1] := strzero(0,TamSx3("QP_ALTERNA")[1]-1)+"1"
	EndIf

	If nOpcao # 2	//# visual
		For nI:=1 To Len(aCols)
			aCols[nI][Len(aHeader)+1] := .F.
		Next nI
	EndIf
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050Muda ³ Autor ³ Cristina Ogura        ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa a mudanca do Folder                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050Muda(ExpN1,ExpN2,ExpO1,ExpC1)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Folder indo                       				  ³±±
±±³			 ³ ExpN2 = Folder estou                       				  ³±±
±±³			 ³ ExpO1 = Objeto em uso                      				  ³±±
±±³			 ³ ExpC1 = Tipo de Objeto (1-Check 2-Radio 3-Memo).		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Muda(nIndo,nEstou,oNome,cTipoObj,oEnchoice)
Local lRetChg   := .T.

If cTipoObj == "3"
	Help(" ",1,"A050DISSE")
	lRetChg := .F.

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Salva Ambiente do Folder Atual 								  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf ( nEstou == 1 )
	lRetChg 	:= Obrigatorio(oEnchoice:aGets,oEnchoice:aTela)
	cNome		:= OemtoAnsi(STR0009)+M->QO_QUESTAO+" - "+M->QO_QUEST //"Questao: "
	oNome:Refresh()
EndIf

If ( nIndo == 2 .And. !Empty(M->QO_ESCALA))
	Help(" ",1,"A050ALTER")
	lRetChg := .F.
EndIf

Return( lRetChg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050Grava³ Autor ³ Cristina Ogura        ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os arquivos SQP, SQO                			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050Grava()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A050Grava( cAlias , nReg , nOpc )

Local bCampo    := { |nCPO| Field(nCPO) }
Local nI		:= 0
Local lChkVld	:= .T.
Local cTopico	:= ""
Local cArea		:= ""
Local cQuestao	:= ""
Local cFilSQO	:= xFilial("SQO")
Local nFcount	:= 0

If ( nOpcao == 2 )     // Visual
    Return( .T. )
EndIf

cTopico	 := M->QO_TOPICO
cArea	 := M->QO_AREA
cQuestao := M->QO_QUESTAO

IF ( nOpcao == 5 )
	dbSelectArea("SQP")
	dbSelectArea("SQQ")
	dbSelectArea("SQR")
	IF ( cModulo == "APD" )
		dbSelectArea("RD8")
		dbSelectArea("RDB")
	EndIF
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica se a Questao pode ser Excluida			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( Rspa050ChkDel( cAlias , nReg , nOpc , cQuestao ) )
		Return( .F. )
	EndIF
EndIF

dbSelectArea("SQO")
SQO->( dbSetOrder(1) )
SQO->( dbSeek(cFilSQO+M->QO_QUESTAO) )
If nOpcao # 5
	//Atualizar dados das Questoes - SQO
	SQO->( RecLock("SQO",If(Found(), .F., .T.)) )
		nFcount := SQO->( FCount() )
		For nI:=1 To nFcount
			If ( FieldName(nI) == "QO_FILIAL" )
				SQO->( FieldPut(nI, cFilSQO) )
			Else
				SQO->( FieldPut(nI, M->&(FieldName(nI))) )
			EndIf
		Next nI
	SQO->( MsUnlock() )

	//Atualizar dados das Alternativas
	If Empty(M->QO_ESCALA) .And. M->QO_TIPOOBJ != "3"
		A050Atu("SQP",cTopico,cArea,cQuestao,1)
	EndIf

	// Grava campo Memo
	MSMM(QO_CODMEM,,,M->QO_MEMO,1,,,"SQO","QO_CODMEM")

Else
	//Atualizar dados das Alternativas
	A050Atu("SQP",cTopico,cArea,cQuestao,1)

	//Deleta o memo relativo ao registro a ser apagado
	MSMM(SQO->QO_CODMEM	,,,,2)

	SQO->( RecLock("SQO",.F.) )
	SQO->( DbDelete() )
	SQO->( MsUnlock() )
EndIf

Return( lChkVld )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050ATU  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza dados das alternativas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050ATU(ExpC1,ExpC2,ExpC3,ExpC4,ExpO1)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias                             				  ³±±
±±³			 ³ ExpC2 = Codigo do TOPICO                  			 	  ³±±
±±³			 ³ ExpC3 = Codigo da Area                     			 	  ³±±
±±³			 ³ ExpC4 = Codigo da Questao                  			 	  ³±±
±±³			 ³ ExpO2 = Objeto em uso                      			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP    												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050Atu(cAlias,cTopico,cArea,cQuestao,nFolder)

Local nPosRec	:= GdfieldPos("QP_REC_WT")
Local cFilSQP	:= xFilial("SQP")
Local lTravou	:= .F.
Local ny		:= 0
Local nx		:= 0


// Quando nao possui alternativas
If Len(aCols) == 1 .And. Empty(aCols[1][2])
	Return( .T. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao de Arquivo das Alternativas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 3 .or. nOpcao == 4 //  Inclusao ou Alteracao
	dbSelectArea("SQP")
	For nx :=1 to Len(aCols)
	    Begin Transaction
			If aCols[nx][nPosRec]>0		//Alteracao
				MsGoto(aCols[nx][nPosRec])
				RecLock("SQP",.F.)
				lTravou:=.T.
			Else                        //Inclusao
			    If !(aCols[nx][Len(aCols[nx])])
					RecLock("SQP",.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou
				//--Verifica se esta deletado
				If aCols[nx][Len(aCols[nx])]
					dbDelete()
		        Else
					Replace SQP->QP_FILIAL 	WITH cFilSQP
					Replace SQP->QP_QUESTAO	WITH cQuestao
				EndIf
				For ny := 1 To Len(aHeader)
					If aHeader[ny][10] <> "V"
						SQP->(FieldPut(FieldPos(aHeader[ny][2]),aCols[nx][ny]))
					EndIf
				Next ny
				MsUnlock()
				lTravou:=.F.
			EndIf
		End Transaction
	Next nx

	If (nOpcao == 4, A050Reseq(cTopico,cArea,cQuestao),)

ElseIf nOpcao == 5 	// Exclusao
	( cAlias )->( dbSetOrder(1) )
	( cAlias )->( dbSeek(cFilSQP+cQuestao) )
	While ( cAlias )->( !Eof() .And. cFilSQP+cQuestao == QP_FILIAL+QP_QUESTAO )
		( cAlias )->( RecLock(cAlias,.F.,.T.) )
			( cAlias )->( dbDelete() )
		( cAlias )->( MsUnlock() )
		( cAlias )->( dbSkip() )
	End
EndIf


Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050LinOk³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica a linha da getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050LinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050LinOk()
Local ny	:= 0
Local nTam	:= Len(aCols)
Local nReg	:= SQO->( Recno() )
Local nDel:= 0
Local i:= 1

If nTam <> 0
	If M->QO_TIPOOBJ <> "3" .And. !Empty(M->QO_ESCALA)
	    If Empty(aCols[n][GdFieldPos("QP_DESCRIC")]) .Or. !aCols[n][Len(aCols[n])]
           Return( .T. )
     	Else
     	   Help(" ",1,"A050ALTER")
          Return( .F. )
       EndIf
    EndIf
Endif

If nTam > 1
	For ny := 1 to Len(aHeader)
		If (Trim(aHeader[ny][2]) == "QP_ALTERNA"  .Or.;
			 Trim(aHeader[ny][2]) == "QP_DESCRIC") .And.;
			 Empty(aCols[n][ny]) .And.;
			 !aCols[n][Len(aCols[n])]
			 Help(" ",1,"A050Vazio")		// Verifique os campos de Alternativa ou descricao devirmuem ser preenchidos
			 Return( .F. )
		EndIf
	Next ny
ElseIf nTam == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando apenas Enchoice: para Dissertativa ou Escala  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->QO_TIPOOBJ == "3" .Or. ( M->QO_TIPOOBJ <> "3" .And. !Empty(M->QO_ESCALA))
		Return( .T. )
	EndIf

	If 	Empty(aCols[n][GdFieldPos("QP_DESCRIC")])
		 Help(" ",1,"A050Vazio")		// Verifique os campos de Alternativa ou descricao devirmuem ser preenchidos
		Return( .F. )
	EndIf
EndIf

If aCols[n,Len(aCols[n])]

	lChkDelOk  := ChkDelRegs(	"SQO"				,;	//01 -> Alias do Arquivo Principal
						   		nReg				,;	//02 -> Registro do Arquivo Principal
								NIL					,;	//03 -> Opcao para a AxDeleta
								NIL					,;	//04 -> Filial do Arquivo principal para Delecao
								NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
								NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
								NIL					,;	//07 -> Mensagem para MsgYesNo
								NIL					,;	//08 -> Titulo do Log de Delecao
								NIL					,;	//09 -> Mensagem para o corpo do Log
								NIL				 	,;	//10 -> Se executa AxDeleta
								NIL					,;	//11 -> Se deve Mostrar o Log
								NIL					,;	//12 -> Array com o Log de Exclusao
								NIL		 			,;	//13 -> Array com o Titulo do Log
								NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
								NIL					,;	//15 -> Bloco para a Condicao While
								NIL					,;	//16 -> Bloco para Skip/Loop no While
								.T.					,;	//17 -> Verifica os Relacionamentos no SX9
								{"SQP"}				 ;	//18 -> Alias que nao deverao ser Verificados no SX9
						    )
	If !lChkDelOk
	    aCols[n,Len(aCols[n])]:= .F.
	Else
	    aCols[n,Len(aCols[n])]:= .T.
	EndIf
   //se excluir as alternativas, deve verificar como esta configurado o tipo de resposta e o campo alternativa
	If M->QO_TIPOOBJ <> "3" .And. Empty(M->QO_ESCALA)
		For i:=1 To Len(aCols)
			If aCols[i][Len(aCols[i])]
				nDel:= nDel+1
			EndIf
		Next i

       If nDel == Len(aCols)
			 Help(" ",1,"A050Vazio")		// Verifique os campos de Alternativa ou descricao devirmuem ser preenchidos
			 Return( .F. )
		EndIf
   EndIf
EndIf

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050TudOk³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica todas as linhas e colunas da getdados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050TudOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050TudOk()
Local ny		:= 0
Local nPosPerc	:= 0
Local nContPerc	:= 0
Local i			:= 0
Local lDel		:= .T.
Local lAlter  := .F.
Local nDel    := 0
Local nItem   := 0

If M->QO_TIPOOBJ <> "3" .And. Empty(M->QO_ESCALA)
	lAlter := .T. //os campos de alternativa deve ser preenchidos
EndIf

If Len(aCols) == 1 .And. Empty(aCols[1][2]).And. lAlter
	Help(" ",1,"A050Vazio")			// Verifique os campos de Alternativa ou descricao devirmuem ser preenchidos
	Return( .F. )
EndIf

For i:=1 To Len(aCols)
	If aCols[i][Len(aCols[i])]
		nDel:= nDel+1
	Else
	If !Empty(aCols[i][2])
		nItem := nItem+1
	EndIf
	EndIf
Next i

If nDel == Len(aCols)
	If lAlter
		Help(" ",1,"A050Vazio")		// Verifique os campos de Alternativa ou descricao devirmuem ser preenchidos
		Return( .F. )
	EndIf
Else
	If !lAlter
		If nItem<>0
			Help(" ",1,"A050ALTER")		// Verifique os campos de Alternativa ou descricao devirmuem ser preenchidos
			Return( .F. )
		EndIf
	EndIf
EndIf

For ny = 1 to Len(aHeader)
	If Trim(aHeader[ny][2]) == "QP_PERCENT"
		nPosPerc := ny
	EndIf
Next ny

If nPosPerc > 0
	For ny = 1 to Len(aCols)
		If !aCols[ny][Len(aCols[ny])]
			nContPerc+= aCols[ny][nPosPerc]
		EndIf
	Next ny

	If nContPerc # 100 .And. M->QO_TIPOOBJ # "4"
		If M->QO_TIPOOBJ == "3" .Or. !Empty(M->QO_ESCALA)
			Return( .T. )
		Else
			Help(" ",1,"A050Perc")			// A soma dos percentuais das questoes devem ser 100
			Return( .F. )
		EndIf
	EndIf
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050Reseq³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Resequencia o codigo da alternativa                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050Reseq(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do TOPICO                 				  ³±±
±±³			 ³ ExpC2 = Codigo do Area                     				  ³±±
±±³			 ³ ExpC3 = Codigo da Questao                  			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050Reseq(cTopico,cArea,cQuestao)

Local cFilSQP	:= xFilial("SQP")
Local nItem		:= 0

dbSelectArea("SQP")
SQP->( dbSetOrder(1) )
If SQP->( dbSeek(cFilSQP+cQuestao) )
	While SQP->( !Eof() .And. cFilSQP+cQuestao== QP_FILIAL+QP_QUESTAO )
		nItem++
		SQP->( RecLock("SQP",.F.) )
			SQP->QP_ALTERNA := StrZero(nItem,2)
		SQP->( MsUnlock() )
		SQP->( dbSkip() )
	EndDo
EndIf
Return( .T. )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³QoQuestaoVld	 ³Autor³Marinaldo de Jesus³ Data ³14/08/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Valid para o campo QO_QUESTAO                				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³X3_VALID para o campo QO_QUESTAO		                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function QoQuestaoVld()

Local lQoQuestaoOk := .T.

Begin Sequence

	IF !( lQoQuestaoOk := ExistChav( "SQO" , M->QO_QUESTAO ) )
		Break
	EndIF

	IF !( lQoQuestaoOk := MayIUseCode("SQO"+xFilial("SQO")+M->QO_QUESTAO) )
		//"A chave selecionada j  est  em uso por outro usu rio"###"Aviso de Inconsistˆncia!"
		MsgInfo( OemToAnsi( STR0013 ) , OemToAnsi( STR0012 ) )
		Break
	EndIF

End Sequence

Return( lQoQuestaoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QoTipoInit³ Autor ³ Marinaldo de Jesus    ³ Data ³27/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para Inicializacao padrao do campo QO_TIPO			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QoTipoInit()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³X3_RELACAO para o campo QO_TIPO							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QoTipoInit()

Local cQoTipoInit

IF ( cModulo == "APD" )
	cQoTipoInit := "APD"
Else
	cQoTipoInit := Space( TamSx3( "QO_TIPO" )[1] )
EndIF

Return( cQoTipoInit )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³QoTipoVld		 ³Autor³Marinaldo de Jesus³ Data ³14/08/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Valid para o campo QO_TIPO                   				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³X3_VALID para o campo QO_TIPO		                        ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function QoTipoVld()

Local lQoTipoOk := .T.

Begin Sequence

	IF !( lQoTipoOk := ExistCpo("SX5","RJ"+M->QO_TIPO) )
		Break
	EndIF

	IF ( cModulo == "APD" )
		IF !( lQoTipoOk := ( M->QO_TIPO == "APD" ) )
			//"O Tipo para o Modulo SIGAAPD deverao ser 'APD'"###"Aviso de Inconsistˆncia!"
			MsgInfo( OemToAnsi( STR0011 ) , OemToAnsi( STR0012 ) )
			Break
		EndIF
	EndIF

End Sequence

Return( lQoTipoOk )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Rspa050ChkDel³Autor³Marinaldo de Jesus    ³ Data ³05/08/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica se os Registros podem ser Deletados                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Rspa050()	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Rspa050ChkDel(	cAlias	,;  //01 -> Alias do Arquivo Principal
								nReg	,;	//02 -> Recno do Arquivo Principal
								nOpc	,;	//03 -> Opcao conforme aRotina
								cCodQue	 ;	//04 -> Codigo da Questao
 							)

Local aArea			:= GetArea()
Local aAreas		:= {}
Local aNotSelect	:= {}
Local cKeyDel		:= ""
Local lChkDelOk 	:= .T.
Local nArea			:= 0.00

Local nLoop
Local nLoops

DEFAULT cAlias		:= Alias()
DEFAULT nReg		:= ( cAlias )->( Recno() )
DEFAULT nOpc		:= 5
DEFAULT	cCodQue		:= ""

cKeyDel	:= cCodQue

IF ( Select( "SQQ" ) == 0 )
	aAdd( aNotSelect , "SQQ" )
EndIF
IF CheckExecForm( { || dbSelectArea( "SQQ" ) } , .F. )
	aAdd( aAreas , Array( 03 ) )
	nArea := Len( aAreas )
	aAreas[nArea,01] := SQQ->( GetArea() )
	aAreas[nArea,02] := Array( 02 )
					aAreas[nArea,02,01] := "QQ_FILIAL"
					aAreas[nArea,02,02] := "QQ_QUESTAO"
	aAreas[nArea,03] := RetOrdem( "SQQ" , "QQ_FILIAL+QQ_QUESTAO" , .T. )
EndIF

IF ( Select( "SQR" ) == 0 )
	aAdd( aNotSelect , "SQR" )
EndIF
IF CheckExecForm( { || dbSelectArea( "SQR" ) } , .F. )
	aAdd( aAreas , Array( 03 ) )
	nArea := Len( aAreas )
	aAreas[nArea,01] := SQR->( GetArea() )
	aAreas[nArea,02] := Array( 02 )
					aAreas[nArea,02,01] := "QR_FILIAL"
					aAreas[nArea,02,02] := "QR_QUESTAO"
	aAreas[nArea,03] := RetOrdem( "SQR" , "QR_FILIAL+QR_QUESTAO" , .T. )
EndIF

IF ( Select( "RD8" ) == 0 )
	aAdd( aNotSelect , "RD8" )
EndIF
IF CheckExecForm( { || dbSelectArea( "RD8" ) } , .F. )
	aAdd( aAreas , Array( 03 ) )
	nArea := Len( aAreas )
	aAreas[nArea,01] := RD8->( GetArea() )
	aAreas[nArea,02] := Array( 02 )
					aAreas[nArea,02,01] := "RD8_FILIAL"
					aAreas[nArea,02,02] := "RD8_CODQUE"
	aAreas[nArea,03] := RetOrdem( "RD8" , "RD8_FILIAL+RD8_CODQUE" , .T. )
EndIF

IF ( Select("RDB") == 0.00 )
	aAdd( aNotSelect , "RDB" )
EndIF
IF CheckExecForm( { || dbSelectArea( "RDB" ) } , .F. )
	aAdd( aAreas , Array( 03 ) )
	nArea := Len( aAreas )
	aAreas[nArea,01] := RDB->( GetArea() )
	aAreas[nArea,02] := Array( 02 )
					aAreas[nArea,02,01] := "RDB_FILIAL"
					aAreas[nArea,02,02] := "RDB_CODQUE"
	aAreas[nArea,03] := RetOrdem( "RDB" , "RDB_FILIAL+RDB_CODQUE" , .T. )
EndIF

( cAlias )->( MsGoto( nReg ) )

lChkDelOk  := ChkDelRegs(	cAlias				,;	//01 -> Alias do Arquivo Principal
							nReg				,;	//02 -> Registro do Arquivo Principal
							nOpc				,;	//03 -> Opcao para a AxDeleta
							xFilial( cAlias )	,;	//04 -> Filial do Arquivo principal para Delecao
							cKeyDel				,;	//05 -> Chave do Arquivo Principal para Delecao
							aAreas				,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	//07 -> Mensagem para MsgYesNo
							NIL					,;	//08 -> Titulo do Log de Delecao
							NIL					,;	//09 -> Mensagem para o corpo do Log
							.F.				 	,;	//10 -> Se executa AxDeleta
							NIL					,;	//11 -> Se deve Mostrar o Log
							NIL					,;	//12 -> Array com o Log de Exclusao
							NIL		 			,;	//13 -> Array com o Titulo do Log
							NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
							NIL					,;	//15 -> Bloco para a Condicao While
							NIL					,;	//16 -> Bloco para Skip/Loop no While
							.T.					,;	//17 -> Verifica os Relacionamentos no SX9
							{"SQP"}				 ;	//18 -> Alias que nao deverao ser Verificados no SX9
					    )

nLoops := Len( aNotSelect )
For nLoop := 1 To nLoops
	IF ( Select( aNotSelect[ nLoop ] ) > 0 )
		( aNotSelect[ nLoop ] )->( dbCloseArea() )
	EndIF
Next nLoop

RestArea( aArea )

Return( lChkDelOk  )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Rspa050MrkBrw³Autor³Marinaldo de Jesus    ³ Data ³05/08/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Array com as Cores para a mBrowse                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Rspa050  	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Rspa050MrkBrw()

Local aCoresBrw	:=	{;
						{ "SQO->QO_ATIVO=='1'" , 'BR_VERDE'		}	,;
             			{ "SQO->QO_ATIVO<>'1'" , 'BR_VERMELHO'	}	 ;
					 }
Return( aCoresBrw )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Rspa050LegBrw³Autor³Marinaldo de Jesus    ³ Data ³05/08/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Legenda de Cores para a mBrowse                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Rspa050  	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function Rspa050LegBrw()

IF ( Type( "cCadastro" ) == "U" )
	Private cCadastro := STR0016							//"Legenda"
EndIF

BrwLegenda(	OemToAnsi(cCadastro)						,;	//Titulo do Cadastro
			OemToAnsi( STR0016 )						,;	//"Legenda"
			{;
				{"BR_VERDE"		,OemToAnsi(STR0014)	}	,;	//"Quest„o Ativa"
				{"BR_VERMELHO"	,OemToAnsi(STR0015)	}	 ;	//"Quest„o Inativa"
			};
		 )

Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³QoEscalaVld  ³Autor³Aline Correa do Vale  ³ Data ³02/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Valida a existencia da escala na tabela                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Rspa050  	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function QoEscalaVld()
Local lRetorno := .F.

If Vazio()
	lRetorno := .T.
Else
	lRetorno := ExistCpo( "RBK" )
	If lRetorno .And. M->QO_TIPOOBJ == "3"
		Help(" ",1,"A050DISSE")
		lRetorno := .F.
	EndIf
EndIf

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A050Chk	³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Folders				             			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050chk(nOpc,oEnchoice)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGARSP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A050Chk(nOpc,oEnchoice)

Local nPosDesc	:= GdFieldPos("QP_DESCRIC")
Local lChkVld	:= .T.

If nOpc == 3 .Or. nOpc == 4
	If !( Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) )
		lChkVld := .F.

	ElseIf 	( Len(acols) == 1 .And. Empty(acols[1][nPosDesc]) ) .And.;
			( Empty(M->QO_ESCALA) .And. M->QO_TIPOOBJ != "3" )

		Aviso(STR0017,STR0018,{"OK"})	//"Atencao"###"Para este tipo de questao deve ser informado Alternativas."
		lChkVld := .F.
	EndIf
EndIf

If !lChkVld
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ RollBack da Numeracao Automatica            				   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	While ( GetSX8Len() > nGetSX8Len )
		RollBackSX8()
	End While
EndIf

Return( lChkVld )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA050                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Array contendo as Rotinas a executar do programa 	   ³
	³ ----------- Elementos contidos por dimensao ------------	   ³
	³ 1. Nome a aparecer no cabecalho 							   ³
	³ 2. Nome da Rotina associada 								   ³
	³ 3. Usado pela rotina										   ³
	³ 4. Tipo de Transa‡„o a ser efetuada 						   ³
	³    1 - Pesquisa e Posiciona em um Banco de Dados			   ³
	³    2 - Simplesmente Mostra os Campos						   ³
	³    3 - Inclui registros no Bancos de Dados				   ³
	³    4 - Altera o registro corrente							   ³
	³    5 - Remove o registro corrente do Banco de Dados 		   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private aRotina := {;
							{ STR0001 ,"AxPesqui"		, 0 , 1,,.F.}	,;	//"Pesquisa"
	                    	{ STR0002 ,"RSP050Rot"		, 0 , 2	}	,;	//"Visual"
	                    	{ STR0003 ,"RSP050Rot"		, 0 , 3	}	,;	//"Inclui"
	                    	{ STR0004 ,"RSP050Rot"		, 0 , 4 }	,;	//"Altera"
	                    	{ STR0005 ,"RSP050Rot"		, 0 , 5	}	,; 	//"Exclui"
	                    	{ STR0016 ,"Rspa050LegBrw"	, 0 , 4,,.F.}	 ; 	//"Legenda"
	                    }

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} RSPA050EPMInt

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RSPA050EPMInt(nOpcao)
	Local oWSQuestao, oQuestao, oAlternativa
	Local nOldSet 	 := SetVarNameLen(255)
	Local cEmp       := ""
	Local cUni       := ""
	Local cFil	     := ""
	Local cPai       := ""
	Local cFilho     := ""

	Local nTamLayEmp := len(FWSM0Layout(cEmpAnt,1))
	Local nTamLayUni := len(FWSM0Layout(cEmpAnt,2))
	Local nTamLayFil := len(FWSM0Layout(cEmpAnt,3))

	dbSelectArea("RBL")
	dbSetOrder(1)
	dbSelectArea("SQP")
	dbSetOrder(1)
	dbSelectArea("SQO")
	dbSetOrder(1)

	If SuperGetMv("MV_TRMINTG", NIL, .F.)
		oWSQuestao:= AMSWSNew("Questao")

		If nOpcao == MODEL_OPERATION_UPDATE .OR.;
		   nOpcao == MODEL_OPERATION_INSERT
			oQuestao					:= QuestaoWSService_QuestaoWSHolder():New()
			oQuestao:cCdExterno 		:= SQO->QO_FILIAL+SQO->QO_QUESTAO
			oQuestao:cPergunta 			:= AllTrim(SQO->QO_QUEST)
			oQuestao:cDescricao			:= ""
			oQuestao:cTipo 				:= GetQuestType(SQO->QO_TIPOOBJ)
			oQuestao:lAtivo 			:= IIF(SQO->QO_ATIVO == "1", .T., .F.)
			oQuestao:nScore 			:= Int(SQO->QO_PONTOS)
			oQuestao:dDataCriacao		:= SQO->QO_DATA
			oQuestao:cCdTopicoExterno 	:= SQO->QO_AREA

			oQuestao:oWSListaAlternativa:= QuestaoWSService_ListaAlternativaWSHolder():New()
			oQuestao:oWSListaAlternativa:oWSAlternativa:= {}

			If Empty(SQO->QO_ESCALA)
				SQP->(dbSeek(xFilial("SQP") + SQO->QO_QUESTAO))

				While !SQP->(Eof()) .AND.;
					   SQP->QP_FILIAL  == xFilial("SQP") .AND.;
					   SQP->QP_QUESTAO == SQO->QO_QUESTAO

					oAlternativa:= QuestaoWSService_AlternativaWSHolder():New()
					oAlternativa:cCdQuestaoExterno 	:= SQP->QP_FILIAL + SQP->QP_QUESTAO
					oAlternativa:cCdExterno 		:= SQP->QP_FILIAL + SQP->QP_QUESTAO + SQP->QP_ALTERNA
					oAlternativa:cDescricao 		:= AllTrim(SQP->QP_DESCRIC)
					oAlternativa:cScore 			:= AllTrim(Str(SQP->QP_PERCENT))

					AAdd(oQuestao:oWSListaAlternativa:oWSAlternativa, oAlternativa)
					SQP->(DBSkip())
				EndDo
			Else
				RBL->(dbSeek(xFilial("RBL") + SQO->QO_ESCALA))

				While !RBL->(Eof()) .AND.;
					   RBL->RBL_FILIAL == xFilial("RBL", SQO->QO_FILIAL) .AND.;
					   RBL->RBL_ESCALA == SQO->QO_ESCALA

					oAlternativa:= QuestaoWSService_AlternativaWSHolder():New()
					oAlternativa:cCdQuestaoExterno 	:= SQO->QO_FILIAL + SQO->QO_QUESTAO
					oAlternativa:cCdExterno 		:= SQO->QO_FILIAL + SQO->QO_QUESTAO + RBL->RBL_ITEM
					oAlternativa:cDescricao			:= AllTrim(RBL->RBL_DESCRI)
					oAlternativa:cScore 			:= AllTrim(Str(RBL->RBL_VALOR))

					AAdd(oQuestao:oWSListaAlternativa:oWSAlternativa, oAlternativa)
					RBL->(DBSkip())
				EndDo
			EndIf


			// Prepara relacionamento com unidade
			If Empty(SQO->QO_FILIAL)
	           cPai   := FWCodEmp() + FWunitBusiness()
			   cFilho := FWCodFil()
			else
				//Captura Empresa
				cEmp := substr(SQO->QO_FILIAL, 1, nTamLayEmp)
				//Captura Unidade
				cUni := substr(SQO->QO_FILIAL, nTamLayEmp+1, nTamLayUni)
				//Captura Filial
				cFil := substr(SQO->QO_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)

		        // Tratamento para Gestao de Empresas //
	   			If nTamLayEmp > 0 .Or. nTamLayUni > 0
			     	//Identifica Pai-Filho para Filial SQO
					If !Empty(cFil) .and. cFil <> Nil
						cPai   := cEmp+cUni
						cFilho := cEmp+cUni+cFil
					Else
						If !Empty(cUni) .and. cUni <> Nil
							cPai   := cEmp
							cFilho := cEmp+cUni
						Else
							If !Empty(cEmp) .and. cEmp <> Nil
								cPai   := FWGrpCompany()
								cFilho := cEmp
							EndIf
						EndIf
			        EndIf
			   Else
			   		cPai	 	:= FWGrpCompany()
		   			cFilho 		:= SQO->QO_FILIAL
			   Endif
			EndIf

			oQuestao:oWSListaUnidade				:= QuestaoWSService_ListaUnidadeWSHolder():New()
			oQuestao:oWSListaUnidade:oWSUnidade		:= {}
			AAdd(oQuestao:oWSListaUnidade:oWSUnidade, QuestaoWSService_UnidadeWSHolder():New())
			oQuestao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadePaiExterno  := cPai
			oQuestao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadeFilhoExterno:= cFilho

			If !oWSQuestao:InsertQuestao(oQuestao)
				Alert("Nao foi possivel gravar a questao no EPM!" + Chr(10) + Chr(13)+ GetWSCError())
			EndIF
		ElseIf nOpcao == MODEL_OPERATION_DELETE
			If !oWSQuestao:deleteQuestao(  SQO->QO_FILIAL + SQO->QO_QUESTAO )
				Alert("Nao foi possivel excluir no EPM a questao!" + Chr(10) + Chr(13)+ GetWSCError())
			EndIf
		EndIf
	EndIf

	SetVarNameLen(nOldSet)
Return


Function GetQuestType(cType)
	Local cRet:= ""

	Do Case
		Case cType == "1"
			cRet:= "MULTIPLA"
		Case cType == "2"
			cRet:= "OBJETIVA"
		Case cType == "3"
			cRet:= "DISSERTATIVA"
		Case cType == "4"
			cRet:= "MULTIPLA"
	EndCase
Return cRet


Function EPMWSNew(cWS)
	Local oWS:= &("WS" + cWS + "WSService():New()")
	oWS:_URL := SuperGetMv("MV_TRMEPMW", NIL, "")
	oWS:_URL += IIF(Right(oWS:_URL, 1) != "/", "/", "") + cWS + "WS"
Return oWS

Function AMSWSNew(cWS)
	Local oWS:= &("WS" + cWS + "WSService():New()")
	oWS:_URL := SuperGetMv("MV_TRMAMSW", NIL, "")
	oWS:_URL += IIF(Right(oWS:_URL, 1) != "/", "/", "") + cWS + "WS"
Return oWS

Function ParDis()

Local cParam := (SuperGetMv("MV_SQODISS",NIL,"1") == "0" )
Local cObj	 := M->QO_TIPOOBJ
Local nPonto := M->QO_PONTOS
Local lRet:=.T.

IF nPonto == 0  .AND. cObj != "3"
	lRet := .F.
	Help(" ",1,"PONOBRIG")
ELSEIF cParam == .T. .AND. cObj == "3"
	If nPonto == 0
		lRet := .F.
		Help(" ",1,"PARDISS")
	Endif
ENDIF

Return(lRet)

/*/{Protheus.doc} fUsoSqoSqp
Verificar uso dos campos das tabelas SQO e SQP pelo módulo corrente
@type  Static Function
@author isabel.noguti
@since 08/07/2020
@version 1.0
/*/
Static Function fUsoSqoSqp()
	Local aSqoSqp	:= {"QO_PONTOS","QO_ESCALA","QO_TIPOOBJ","QP_ALTERNA","QP_PERCENT","QP_DESCRIC"}
	Local cNaoUsado	:= ""
	Local lRet		:= .T.
	Local nI		:= 0

	For nI := 1 to Len(aSqoSqp)
		If !CpoUsado(aSqoSqp[nI])
			lRet := .F.
			cNaoUsado += CRLF + aSqoSqp[nI]
		EndIf
	Next nI

	If !Empty(cNaoUsado)
		Help(" ",1, STR0021,, STR0022 + cNaoUsado,1,0)	//"Campos não usados no módulo corrente"Verifique os módulos em uso do(s) campo(s):"
	EndIf

Return lRet
