#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FISA813.CH'

#define Confirma 1
#define Redigita 2
#define Abandona 3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA813  ³ Autor ³ Luis Samaniego        ³ Data ³ 12/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mantenimiento de Catalogos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA813()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico ( DOS e Windows )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS     ³  Motivo da Alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³04/12/2019³DMINA-5912³Se agrega fun fis813CBol se ejecuta ³±±
±±³            ³          ³          ³en Menudef para obt. Cat.SIN  (BOL) ³±±
±±³ARodriguez  ³19/08/2021³DMINA-    ³f813Alt() checa primer registro del ³±±
±±³            ³          ³     12690³catálogo para determinar contenido  ³±±
±±³            ³          ³          ³en vez de leer todo el catálogo.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA813()
Local aArea     := GetArea()
Local aAreaF3H  := F3H->(GetArea())
Local aAreaF3I  := F3I->(GetArea())

Private cCodigo    := CriaVar("F3H_CODIGO")
Private cDescri    := CriaVar("F3H_DESC")
Private aIndexF3H  := {} //Variavel Para Filtro
Private oBar, oBtOk, oBtCan
Private oBtnCop, oBtnPas, oBtnCalc, oBtnHlp, oBtnPrn, oBtnAplica, oBtnDupl, oBtnReaj, oBtnAg, oBtnPesq, oBtOrder, oBtnImp
Private nP := 0
Private aButtons   := {}
Private lF813Inc   := .F.
Private cAuxSeq    := ""
Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cCadastro  := OemToAnsi(STR0001) //'Cadastro de Tabelas'
Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

	If F812ModComp("F3H")

		FISA814()

		dbSelectArea("F3H")
		dbGotop()
		cFiltraF3H	:=	'F3H_ORDEM == "01"'

		bFiltraBrw 	:= {|| FilBrowse("F3H",@aIndexF3H,@cFiltraF3H) }
		Eval(bFiltraBrw)

		mBrowse(06,01,22,75,'F3H',, , , , , fUseCor(), , , ,)

		EndFilBrw("F3H",aIndexF3H)
	Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Restaura Area e Ordem de Entrada                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RestArea( aArea )
	RestArea( aAreaF3I)
	RestArea( aAreaF3H)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ f813Alt  ³ Autor ³ R.H - Natie           ³ Data ³ 13/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao de Estrutura do Parametro                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := AxAltera(ExpC1,ExpN2,ExpN3,ExpA1,ExpA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao devolvida pela funcao                        ³±±
±±³          ³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN2 = Numero do registro                                 ³±±
±±³          ³ ExpN3 = Numero da opcao selecionada                        ³±±
±±³          ³ ExpA1 = Array contendo campos a serem mostrados            ³±±
±±³          ³ ExpA2 = Array limitando campos a serem aceitos com Get     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function f813Alt(cAlias,nReg,nOpcx)
Local aArea         := GetArea()
Local aKeys         := GetKeys()
Local nOpca         := 0
Local nCnt          := 0
Local aAreaF3I      := F3I->( GetArea() )
Local aAreaF3H      := F3H->( GetArea() )
Local a813nField	  := {}
Local aColsRec	  := {}
Local aColsAnt	  := {}
Local cCond		  := "", cChave:= ""
Local oFont
Local oDlgMain
//-- Variaveis dimensoes do objeto tela
Local aAdvSize     := {}
Local aInfoAdvSize := {}
Local aObjSize     := {}
Local aObjCoords   := {}
Local bSet15       := {|| NIL}
Local bSet24       := {|| NIL}

Private nOpcao     := nOpcx
Private oGeT
Private oCodigo, oDescri, oFil, oChave
Private oGroup1, oGroup2
Private oFont1, oFont2
Private aVisual
Private aAntes
Private aColsBkp
Private nBkp

	nBkp     := 0
	aHeader  := {}
	aColsBkp := {}
	aVisual  := {}
	aAntes   := {}
	aColsBkp := {}
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	cCodigo		:= F3H->F3H_CODIGO
	cDescri		:= F3H->F3H_DESC

	//-- Verifica a existencia da estrutura do parametro
	DbSelectArea(cAlias)
	dbSeek( xFilial(cAlias) )
	If (eof() .and. bof())
		Help(" ",1,"A320SPAR")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("F3H",aIndexF3H)
	aIndexF3H := {}
	cAlias := "F3I"
	cFilF3I := xFilial(cAlias)

	Do while .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Nao editaveis no aCols                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		a813nField	:= {"F3I_FILIAL","F3I_CODIGO","F3I_CONTEU"}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica existencia de registro qdo for alteracao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAlias)
		dbSetOrder(1)
		dbSeek( cFilF3I + cCodigo )
		If !eof() .and. cFilF3I + cCodigo = F3I->F3I_FILIAL+F3I->F3I_CODIGO
			nCnt++
		EndIf

	    If nCnt > 0 .And. nOpcx == 3 //--Quando Inclusao e existir Registro
	    	If lF813Inc
				lF813Inc := .F.
				Exit
			EndIf
			Help(" ",1,"A310REG")
			Exit
		ElseIf nCnt == 0 .And. nOpcx # 3 //--Quando Nao for Inclusao e nao existir Registro
			Aviso(STR0014,STR0026,{'OK'}) //"Atencao"###"Nao existem registros cadastrados para esta tabela. Utilize a opcao 'Incluir'."
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a entrada de dados do arquivo                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCond	:= "F3I_FILIAL + F3I_CODIGO"
		cChave	:= cFilF3I + cCodigo

		aHeader	:= f813aHead(a813nField,cAlias) // Array contendo header
		If Empty(aHeader)
			Exit
		EndIf
		aCols	:= f813aCols(a813nField,cAlias,cCond,cChave,nOpcx,@aColsRec,@aColsAnt) // Array contendo aCols

		IF nOpcx==3 .and. (Type("N") != "U")
			n := 1
		EndIF

		DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
		SetaPilha()

		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup1 TO aObjSize[1,3] ,aObjSize[1,4]*0.20 LABEL OemToAnsi(STR0011) OF oDlgMain PIXEL // "Codigo da Tabela:"
			oGroup1:oFont:= oFont
			@ aObjSize[1,1] , aObjSize[1,4]*0.21 GROUP oGroup2 TO aObjSize[1,3] ,aObjSize[1,4] LABEL OemToAnsi(STR0012) OF oDlgMain PIXEL // "Descricao"
			oGroup2:oFont:= oFont
			@ aObjSize[1,1]+10 , aObjSize[1,2]+10 SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
		 	@ aObjSize[1,1]+10 , aObjSize[1,4]*0.21+10 SAY cDescri SIZE 120,10 OF oDlgMain PIXEL FONT oFont
			oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4], nOpcx,"f813LinOk","f813tudOk",,If(nOpcx=2 .Or. nOpcx=5,Nil,.T.),,,,999999)
			oGet:lf3Header := .T. //Habilita o uso da Consulta F3 na GetDados
		 	bSet15 := { || nOpca := 1, If(f813tudOk(oGet),oDlgMain:End(),nOpca:=0)}
			bSet24 := { || 	RestKeys(aKeys,.T.), oDlgMain:End()}
			FchoBar813(oDlgMain,,,nOpcx)

		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15, bSet24, NIL, aButtons) CENTERED
		SetaPilha()

		IF nOpcA == Redigita
			Return
		ELSEIF nOpcA == Confirma .And. nOpcx # 2
			Begin Transaction
				//--Gravacao
				f813Grava(cAlias,nOpcx,if(nOpcx = 4,aColsRec,""),if(nOpcx = 4,aColsAnt,""))
				//--Processa Gatilhos
				EvalTrigger()
			End Transaction
		Endif
		Exit
	Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o filtro F3H utilizando a funcao FilBrowse                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aArea )
RestArea( aAreaF3I)
RestArea( aAreaF3H)
RestKeys(aKeys,.T.)

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f813Exc   ³ Autor ³ R.H. -  Natie         ³ Data ³ 23/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ f813Exc(cAlias,nReg,nOpca)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias= Alias do arquivo                                   ³±±
±±³          ³ nREg  = Numero do registro                                 ³±±
±±³          ³ nOpca = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function f813Exc(cAlias,nReg,nOpcx,aAcho,aCpos,nColMens,cMensagem,cTudoOk)
//-- Cria variaveis
Local aKeys       := GetKeys()
Local nOpca       := 0
Local aArea       := GetArea()
Local aAreaF3I    := F3I->( GetArea() )
Local aAreaF3H    := F3H->( GetArea() )
Local a813nField	:= {}
Local aColsRec	:= {} //--Array que contem o Recno() dos registros da aCols
Local aColsAnt	:= {}
Local cCond		:= "", cChave:= ""
Local oFont
Local oDlgMain
//-- Variaveis dimensoes do objeto tela
Local aAdvSize      := {}
Local aInfoAdvSize  := {}
Local aObjSize      := {}
Local aObjCoords    := {}

Private cCodigo     := CriaVar("F3H_CODIGO")
Private cDescri     := CriaVar("F3H_DESC")
Private nOpcao      := nOpcx
Private oGet
Private oCodigo
Private oDescri
Private oFil
Private oChave
Private oGroup1
Private oGroup2

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos Nao editaveis                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a813nField := {"F3I_FILIAL","F3I_CODIGO","F3I_CONTEU"}
	cFilF3H    := F3H->F3H_FILIAL
	cCodigo    := F3H->F3H_CODIGO
	cDescri    := F3H->F3H_DESC

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite exclusao de Parametro  padrao do Sistema                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !fChkUser()
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Se for um Parametro Definido Pela Microsiga Altera a Opcao ³
		³ para Visualizacao											 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		MsgInfo( oEmToAnsi(STR0015) + CRLF + oEmToAnsi(STR0014) )
		nOpcx := 2
		Return
	Endif

	cAlias		:= "F3I"
	DbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek( xFilial(cAlias)+ cCodigo )
	If F3I->( eof() )
		Help(" ",1,"A320NPAR") //Nao existe tabela para o parametro solicitado
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("F3H",aIndexF3H)
	aIndexF3H := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCond	:= "F3I_FILIAL+ F3I_CODIGO"
	cChave	:= xFilial("F3I")+ cCodigo
	aHeader := {}
	aHeader := f813aHead(a813nField,cAlias) // Array contendo cabecalho
	If Empty(aHeader)
		Return
	EndIf
	aCols	:= f813aCols(a813nField,cAlias,cCond,cChave,nOpcx,@aColsRec,@aColsAnt) // Array contendo aCols

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
	SetaPilha()

		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup1 TO aObjSize[1,3] ,aObjSize[1,4]*0.20 LABEL OemToAnsi(STR0011) OF oDlgMain PIXEL // "Codigo da Tabela:"
			oGroup1:oFont:= oFont
			@ aObjSize[1,1] , aObjSize[1,4]*0.21 GROUP oGroup2 TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0012) OF oDlgMain PIXEL // "Descricao"
			oGroup2:oFont:= oFont
			@ aObjSize[1,1]+10 , aObjSize[1,2]+10 SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
		 	@ aObjSize[1,1]+10 , aObjSize[1,4]*0.21+10 SAY cDescri SIZE 120,10 OF oDlgMain PIXEL FONT oFont
			oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"",,,,,,,999999)
			bSet15 := { || nOpca := 1,RestKeys(aKeys,.T.),oDlgMain:End(),.F.}
			bSet24 := { || RestKeys(aKeys,.T.), oDlgMain:End()}
			FchoBar813(oDlgMain,,,nOpcx)

		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15, bSet24, NIL, aButtons) CENTERED
		SetaPilha()

	If nOpcA == Confirma  .and. nOpcx = 5 //-- Confirma Exclusao
		Begin Transaction
		// Exclusao na F3I
			dbSelectArea( "F3H" )
			dbSetOrder(1)
			If dbSeek( cFilF3H + cCodigo )
				While cFilF3H + cCodigo == F3H->F3H_FILIAL+F3H->F3H_CODIGO .And. !Eof()
					RecLock("F3H",.F.,.T.)
					F3H->(dbDelete())
					MsUnlock()
					F3H->(DbSkip())
				EndDo
			EndIf
		// Exclusao na F3I
			dbSelectArea( "F3I" )
			dbSetOrder(1)
			If dbSeek( cFilF3H + cCodigo )
				While cFilF3H + cCodigo == F3I->F3I_FILIAL+F3I->F3I_CODIGO .And. !Eof()
					RecLock("F3I",.F.,.T.)
					F3I->(dbDelete())
					MsUnlock()
					F3I->(DbSkip())
				EndDo
			EndIf
		End Transaction
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o filtro F3H utilizando a funcao FilBrowse                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aArea )
RestArea( aAreaF3I)
RestArea( aAreaF3H)

Return(Nil)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f813Grava ³ Autor ³ Natie                 ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Parametros                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ f813Grava                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function f813Grava(cAlias,nOpcx,aColsRec,aColsAnt)
Local nPosSeq   := GdFieldPos("F3I_SEQUEN")
Local nMaxArray := Len(aHeader)
Local nTamSeq   := TamSX3( "F3I_SEQUEN")[1]
Local nSeq      := 0
Local xConteudo := ""
Local nX 		  := 0
Local nY 		  := 0
Local nTamAnt	  := Len(aColsAnt)
Local nCntDel   := 0
Local lTudoIgual

	nUsado := Len(aHeader)

	dbSelectArea(cAlias)
	If len(aColsRec) <> 0
		For nX	:=	1 to Len(aCols)
			lTudoIgual := .T.
			If nX <= nTamAnt
				For nY := 1 To Len(aHeader)
					If aCols[nX,nY] # aColsAnt[nX,nY]
						lTudoIgual := .F.
						Exit
					Endif
				Next nY
			Else
				lTudoIgual := .F.
			EndIf
			If lTudoIgual .And. aCols[nX,nUsado+1] = .F.
				Loop
			Endif
			If aScanX( aColsRec, { |X,Y|  y == nX}) != 0
				dbgoto(aColsRec[nX])
				RecLock(cAlias,.F.)
			Else
				RecLock(cAlias,.T.)
			Endif
			If aCols[nX,nUsado+1] = .T.
				nCntDel ++
				dbDelete( )
			Else
				F3I->F3I_FILIAL   := xFilial(cAlias)
				F3I->F3I_CODIGO   := cCodigo
				F3I->F3I_SEQUEN   := aCols[nX,nPosSeq]
				//-- Grava  os Campos definidos no F3H no campo F3I_CONTEU
				For ny := 2 To nMaxArray
					cCampo    := Trim(aHeader[nY][2])
					If a813Transf(aCols[nX,nY],aHeader[nY][8],aHeader[nY][4],aHeader[nY][5]) == "  /  /    "
						xConteudo += Space(8)
					Else
						xConteudo += a813Transf(aCols[nX,nY],aHeader[nY][8],aHeader[nY][4],aHeader[nY][5])
					EndIf
				Next ny
				//-Nao permite alterar a Descricao dos Fornecedores 001 a 004, da tabela S018
				F3I->F3I_CONTEU := xConteudo
				//-- Reinicia variavel
				xConteudo	:= ""
				F3I->(MsUnlock())
			EndIf
		Next nX
	Else
		f813Grinc( cAlias ,1 )
	Endif

	If nCntDel > 0
		//Reordena sequencia da tabela atualizada.
		Begin Transaction
			dbSelectArea( cAlias )
			dbSetOrder(1)
			If dbSeek( xFilial(cAlias) + cCodigo )
				While xFilial(cAlias) + cCodigo == F3I->F3I_FILIAL+F3I->F3I_CODIGO .And. !Eof()
		 		    RecLock(cAlias,.F.)
				    nSeq ++
				    Replace F3I->F3I_SEQUEN With StrZero(nSeq,nTamSeq)
					MsUnlock()
					DbSkip()
				EndDo
			EndIf
		End Transaction
	Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a813Transf³ Autor ³ Natie                 ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ a813Transf                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function a813Transf(xCampo,cTipo,nTam,nDecima)

	If cTipo = "C"
		cCampo := Upper(xCampo)
	ElseIf cTipo = "N"
		cCampo := Str(xCampo,nTam,nDecima)
	ElseIf cTipo = "D"
		cCampo := If( empty(xcampo) , DTOC(xCampo), DTOS(xCampo) )
	Endif

Return (cCampo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f813aHead ºAutor  ³Ricardo             º Data ³  17/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao f813aHead() - Monta o array de header - SRB         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f813aHead(aFields,cAlias)
Local aArea     := GetArea()
Local aExclF3I  := { 'F3I_FILIAL','F3I_CODIGO','F3I_CONTEU'}

Private aHeader := {}, nUsado := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array dos campos do arquivo de pesquisa.							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("Sx2")
	dbSeek(cAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array dos campos do arquivo de pesquisa.							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( 'SX3' )
	dbSeek( 'F3I' )
	Do While !Eof() .and. ( x3_arquivo == 'F3I' )
		If !(alltrim(x3_campo) =="F3I_CHAVE" .Or. alltrim(x3_campo) =="F3I_FIL")
			If x3uso(x3_usado) .AND. cNivel >= x3_nivel .and.;
				ASCAN(aExclF3I,{ |x| x == Trim(x3_campo) } ) == 0
				nUsado ++
				Aadd(aHeader,{ TRIM(x3Titulo()), x3_campo, x3_picture,;
									x3_tamanho, x3_decimal, x3_valid,;
									x3_usado, x3_tipo, x3_F3,;
									x3_context } )
			EndIf
		EndIf
		dbSkip()
	EndDo

	dbSelectArea("F3H")
	dbSetOrder(1)
	If !dbSeek(xFilial(cAlias) + cCodigo,.F.)
		MsgAlert(OemToAnsi(STR0089), OemToAnsi(STR0083)) //-"Nao existe esta tabela para a Empresa/Un.Negocio/Filial selecionada !"###"Atenção"
		aHeader := {}
	EndIf
	Do While !Eof() .and. xFilial("F3H")+ cCodigo  = (F3H->F3H_FILIAL + F3H->F3H_CODIGO)
			nUsado ++
			Aadd(aHeader,{  Trim(F3H_DESCPO),F3H_CAMPOS ,F3H_PICTUR,;
								F3H_TAMAN, F3H_DECIMA, F3H_VALID,;
								'X', F3H_TIPO, F3H_PADRAO, ' '} )
		dbSkip()
	EndDo
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aArea )

Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f813aCols ³ Autor ³ Natie                 ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criar os Arrays do aCols dos arquivos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FISA813                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function f813aCols(aFields,cAlias,cCond,cChave,nOpcx,aColsRec,aColsAnt)
Local nCntFor  := 0
Local nAcols   := 0
Local nTamCpo  := 0
Local nPosicao := 0
Local aArea    := GetArea()
Local aConteu  := {"F3I_FILIAL","F3I_CODIGO","F3I_SEQUEN"} //--Array com  os cpos q estao fora do Conteudo
Local nTamSeq   := TamSX3( "F3I_SEQUEN")[1]

Private nUsado := Len(aheader)
Private aCols  :={}

	//--Quando for Inclusao criar com 1 elemento
	If nOpcx = 3 //Inclusao
		nCnt := 1
		aCols := Array( nCnt , nUsado+1 )
	Endif

	dbSelectArea(cAlias)

	If dbSeek(cCHAVE) .and. nOpcx # 3
		While !Eof() .And. &cCond == cChave
			aadd(aCols,Array(nUsado+If(nOpcx#1,1,0)))
			nAcols 		:= Len(aCols)
			nPosicao	:= 1
			cConteu	:= FieldGet(FieldPos( "F3I_CONTEU" ) )
			For nCntFor := 1 To Len(aHeader)
				nTamCpo	:= aHeader[nCntFor][4] //-- Tamanho do Campo
				cCampo  := Trim(aHeader[nCntFor][2])
				If	ASCAN(aConteu,{ |x| x == cCampo } ) > 0
					aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					//-- Carrega o conteudo do F3I_CONTEU na aCols
					If aHeader[nCntFor,8] = "C" // tipo Caracter
						aCols[nAcols][nCntFor] := Substr(cConteu,nPosicao,nTamCpo)
					ElseIf  aHeader[nCntFor,8] = "N" // tipo Numerico
						aCols[nAcols][nCntFor] := VAL( Substr(cConteu,nPosicao,nTamCpo) )
					ElseIf aHeader[nCntFor,8] = "D" // tipo Data
						aCols[nAcols][nCntFor] := Stod(Substr(cConteu,nPosicao,nTamCpo) )
					Endif
					nPosicao += nTamCpo
				Endif
			Next nCntFor
			If nOpcx # 1
				aCols[nAcols][nUsado+1] := .F.
			EndIf
			dbSelectArea(cAlias)
			Aadd(aColsRec,Recno())
			dbSkip()
		EndDo

	ElseIf nOpcx = 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbseek(cAlias) //F3I
		nUsado:=0
		//--afields:={"F3I_FILIAL","F3I_CODIGO","F3I_CONTEU"} campos nao editaveis no aCols
		While !EOF() .And. (x3_arquivo == cAlias)
			IF x3uso(x3_usado) .AND. cNivel >= x3_nivel .and. ASCAN(aFields,{|x| x == Trim(x3_campo)}) == 0
				nUsado++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta Array do 1§ Elemento Vazio. Se Inclusao                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				ELSEIF x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				ELSEIF x3_tipo == "D"
					aCOLS[1][nUsado] := CTOD("  /  /  ")
				Endif
			Endif
			dbSkip()
		EndDo

		dbSelectArea("F3H")
		dbSetOrder(1)
		dbSeek( cChave)
		While !EOF() .and.  cChave = xFilial("F3H") + F3H->F3H_CODIGO
		    nUsado ++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Array do 1§ Elemento Vazio utilizando F3H              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If F3H_TIPO = "C"
				aCOLS[1][nUsado] := SPACE(F3H_TAMAN)
			ElseIf F3H_TIPO = "N"
				aCOLS[1][nUsado] := 0
			ElseIf F3H_TIPO = "D"
				aCOLS[1][nUsado] := CTOD("  /  /  ")
			ELSE
				aCOLS[1][nUsado] := .F.
			Endif
			F3H->( dbSkip() )
		Enddo
		aCOLS[1,nUsado+1] := .F.
	Endif

	aCols[1][GdFieldPos("F3I_SEQUEN")] := Strzero(Val('01'), nTamSeq) //-- Inicia Ordem com 1

	// Copia o vetor aCols
	If nOpcx == 4
		aColsAnt := Aclone(aCols)
	EndIf

	aColsBkp := Aclone(aCols)
	nBkp     := Len(aColsBkp)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Restaura Area e Ordem de Entrada                              ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RestArea(aArea)

Return aCols

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f813LinOk³ Autor  ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function f813LinOk(o)
Local lTudoOk   := .T.
Local nX        := 0
Local nPosSeq   := GdFieldPos("F3I_SEQUEN")
Local nUsado    := Len(aHeader)
Local nUsaCols  := 0
Local cChaveGet := ""
Local aCopyCols := aClone(aCols)
Local lEmpty    := .T.

	nUsaCols  := Len(aCols)
	//-- Salva Chave atual
	cChaveGet	:= cFilF3I+ cCodigo + aCopyCols[n,nPosSeq]
	If !Empty(aCopyCols[n,nPosSeq])
		cAuxSeq := aCopyCols[n,nPosSeq]
	EndIf
	//--Verifica se tem alguma coluna preenchida alem da chave
	For nX := 1 to len(aCopyCols[n])
	    If nX == nPosSeq .or. (nX ==(nUsado+1) .and. aCopyCols[n,nX]==.F.)
	    	Loop
	    EndIf
	    lEmpty := Empty(aCopyCols[n,nX])
	    If !lEmpty
	    	exit
	    EndIf
	Next

	If lEmpty
		Aviso(STR0014,STR0027,{'OK'}) //"Atencao" ##"Preencha os dados da tabela."
		lTudoOk := .F.
	Else
		If aCopyCols[n,nUsado+1]  = .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Muda a Sequencia da Tabela de acordo com  a chave            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fPlusSeq813(@aCopyCols,cChaveGet,nUsado)
			F3H->(DbSetOrder(1))
			F3H->(DbSeek(xFilial("F3H")+cCodigo))
			While F3H->F3H_CODIGO == cCodigo .and. lTudoOk
				If !aCopyCols[n,Len(aCopyCols[n])]       //nao é deletado
					If "NAOVAZIO" $ F3H->F3H_VALID
						If Empty(aCopyCols[n,Val(F3H->F3H_ORDEM)+1])
							lTudoOk := .F.
							Aviso(STR0014,STR0087+ Alltrim(F3H->F3H_DESCPO) +STR0088,{"OK"})
						EndIf
					EndIf
				EndIf
				F3H->(DbSkip())
			EndDo
			If Empty(AcopyCols)
				aCols := {}
				Eval(oGet:oBrowse:badd)
			Else
				aCols	:= aClone(aCopyCols)
			Endif
			oGet:oBrowse:nAt 	:= n
			oGet:oBrowse:Refresh(.T.)
		Else
	   	  	fPlusSeq813(@aCopyCols,cChaveGet,nUsado)
			If Empty(AcopyCols)
				aCols := {}
				Eval(oGet:oBrowse:badd)
			Else
				aCols	:= aClone(aCopyCols)
			Endif
			oGet:oBrowse:nAt 	:= n
			oGet:oBrowse:Refresh(.T.)
			fAtualizaBkp2()
		Endif
		oGet:oBrowse:nAt 	:= n
		oGet:oBrowse:Refresh(.T.)
	EndIf

	If lTudoOk == .T.
		lF813Inc := .T.
	Endif

Return lTudoOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³f813tudOk  ³ Autor ³ Natie                ³ Data ³ 25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta as getdados dos arquivos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³f813Alt                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function f813tudOk(o)
Local lTudoOk  := .T.

	lTudoOk := f813LinOk()

Return lTudoOk



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FchoBar813³ Autor ³R.H.-Natie             ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ carrega abuttons, para enchoicebar						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FchoBar813(oDlg,cGrupos,lEnable,nOpcx)
Local bCopy      := { || NIL } //-- Botao Copiar
Local bPaste     := { || NIL } //-- Botao Colar
Local bReOrder   := { || NIL }
Local bDuplic813 := { || Duplic813() }
Local bReaj      := { || Rejusta813() }
Local bAplicar   := { || Aplicar(aCols) }
Local aCopyTab   := {}

DEFAULT lEnable		:= .T.

	aButtons	:= {}
	If nOpcx == 4 .or. nOpcx == 3
		bReOrder := { || fReorder813() }
		aAdd(aButtons, { NIL, { || Eval( bReOrder )  } ,  OemToAnsi(STR0068) } ) // Atualizar
		SetKey( VK_F8 , bReOrder )
	Endif

	IF nOpcx == 4
		aAdd(aButtons, { NIL, { || Eval( bDuplic813 )  } ,  OemToAnsi(STR0034)  } ) //"Duplic813"
		aAdd(aButtons, { NIL, { || Eval( bReaj )  } ,  OemToAnsi(STR0041) } ) //"Rejusta813"
	Endif

	IF ( lEnable ) .AND. (nOpcx == 3 .OR. nOpcx == 4)
		bCopy		:= { || aCopyTab := fCopia813(oGet:oBrowse:nAt) }
		bPaste		:= { || fColar813( aCopyTab , .T.,oGet:oBrowse:nAt,.f.) }
		aAdd(aButtons, { NIL, { || Eval( bCopy )  } ,  OemToAnsi(STR0016)} ) //"Copiar"
		SetKey( VK_F4 , bCopy )
		If Empty(aCopyTab)
			aAdd(aButtons, { NIL, { || Eval( bPaste )  } ,  OemToAnsi(STR0017) } )//"Colar"
			SetKey( VK_F5 , bPaste )
		EndIf
	EndIf

	IF nOpcx == 3
		aAdd(aButtons, { NIL, { || Eval( bAplicar )  } ,  OemToAnsi(STR0044) } ) //"Aplicar"
	Endif

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fUseCor  | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function fUsecor()
Local aMarks := {}

	aMarks := { { "Substr(F3H->F3H_CODIGO,1,1)=='U'" , "BR_VERDE" } ,;
	            { "Substr(F3H->F3H_CODIGO,1,1)$'S*G'", "BR_AZUL"  } }

Return( aClone( aMarks ) )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ f813Leg  | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legenda de Cores                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function f813Leg()
Local aLegenda	:= {}

	aLegenda := { { "BR_AZUL", OemToAnsi(STR0008) } ,; //"Tabela Definida Pela Microsiga"
	              { "BR_VERDE" , OemToAnsi(STR0009) } } //"Tabela Definida Pelo Usuario"

	BrwLegenda( cCadastro, oEmToAnsi(STR0010), aLegenda ) //Legenda do Cadastro de Paramentros

Return( NIL )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCopia813 | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³efetua copia do registro atual                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function fCopia813(nLin)
Local aCopyTab	:= {}

	If Empty(nLin)
	   nLin := n
	EndIf
	// O tratamento do MsNewGetDados e diferente do MSGetDados
	//Copia Linha inteira
	If AllTrim(Upper(oGet:cClassName)) == "MSGETDADOS"
	   aCopyTab := ( aClone ( aCols[nLin] ) )
	Else
	   aCopyTab := ( aClone ( oGet:aCols[ nLin ] ) )
	EndIf

Return aCopyTab

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fColar813 | Autor ³Mohanad Odeh           ³ Data ³12/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cola registro na posicao atual                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function fColar813(aCopyTab,lLinha,nLin, lMsNewGetDados)
Local cSeq      := ""
Local aAux      := aClone(aCols)
Local nPosSeq
Local cChaveGet := ""
Local nTamAux
Local aString   := {}
Local nX := 0
Local aCampos   := {"F3I_SEQUEN"}
Local lF3I      := .F.
Local nPos1     := aScan(aHeader,{|x| AllTrim(x[2]) == aCampos[1]})

DEFAULT lLinha         := .T.
DEFAULT lMsNewGetDados := .F.

	If(nPos1 <> 0, lF3I := .T., lF3I)

	If Empty(nLin)
		nLin := n
	ENDIF

	If (lF3I)
		nPosSeq	:= GdFieldPos("F3I_SEQUEN")
		nTamAux	:= Len(cFilF3I + cCodigo)
		If !Empty(aCopyTab)
			// Chave da sequência
			cChaveGet	:= cFilF3I+ cCodigo + aCopyTab[nPosSeq]// aCopyTab[nPosFil]+ aCopyTab[nPosCha]+
			// Cria array(aString) com registros que tenham a mesma chave para obter a sequência
			For nx := 1 To Len(aAux)
				cString := cFilF3I+ cCodigo//+ aAux[nx,nPosFil]+ aAux[nx,nPosCha]
				If Len(cString) > 0 .And. !Empty(aAux[nx,nPosSeq]) .And. ;
					Substr(cChaveGet,01,(nTamAux)) == cString
					Aadd(aString,{cString,aAux[nx,nPosSeq]})
				Endif
			Next
			If !Empty(aString)
				cSeq:= f813SeqAlfa(aString[Len(aString)][2])
			EndIf
			aCopyTab[nPosSeq] := cSeq
		EndIf
	EndIf

	If !Empty(aCopyTab)
		If  lLinha
			// O tratamento do MsNewGetDados e diferente do MSGetDados
			IF lMsNewGetDados
				oGet:aCols[nLin] := aClone( aCopyTab )
			ELSE
				For nX := 1 To Len( aHeader )
					aCols[nLin, nX] := aCopyTab[nX]
				Next nX
			ENDIF
		Else
			For nX := 1 To Len( aHeader )
				aCols[nLin, nX] := aCopyTab[nX]
			Next nX
	    Endif
	    n := nLin
	    oGet:lNewLine := .F.
	    oGet:lEditLine := .T.
	    oGet:oBrowse:Refresh(.T.)
	EndIF

Return (nil)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fReorder813| Autor ³Mauricio Takakura     ³ Data ³29/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Reordenar os Registros da Tabela                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function fReorder813()
Local nPosSeq	:= GdFieldPos("F3I_SEQUEN") //-- Posicao Campo Sequencia no aCols

	aSort( aCols,,,{ |x,y,z| x[nPosSeq] < y[nPosSeq]} ) //-- Ordena para acertar a sequencia
	oGet:oBrowse:nAt := n
	oGet:oBrowse:Refresh(.T.)

Return (nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fPlusSeq813| Autor ³Natie                 ³ Data ³ 30/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controla a Sequencia de acordo com  a Chave digitada        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function  fPlusSeq813(aAux,cChaveAux,nUsado)
Local cSeq      := "" //-- Variavel sequencia
Local nLin      := 0
Local nPosSeq   := GdFieldPos("F3I_SEQUEN") //-- Posicao Campo Sequencia no aCols
Local nIniChave := 0
Local nFimChave := 0

	nIniChave := GetSx3Cache("F3I_FILIAL", "X3_TAMANHO") + GetSx3Cache("F3I_CODIGO", "X3_TAMANHO") + 1
	nFimChave := GetSx3Cache("F3I_FILIAL", "X3_TAMANHO") + GetSx3Cache("F3I_CODIGO", "X3_TAMANHO")
	If (nPos:=(Ascan(aAux,{|x| x[1]= substr(cChaveAux,nIniChave,nFimChave)}))) >0
		//-- procura a ultima sequencia da chave
		If nPos > 1
			nPos -= 1
		EndIf
		For nLin := nPos to len(aAux)
			If aAux[nLin,nUsado+1] == .F. .And. !Empty( aAux[nLin][nPosSeq] )
				cSeq := aAux[nLin][nPosSeq]
			ElseIf aAux[nLin,nUsado+1] == .F. .And. Empty( aAux[nLin][nPosSeq] )
				If Empty(cSeq)
					aAux[nLin][nPosSeq] := Soma1(cAuxSeq)
				Else
					aAux[nLin][nPosSeq] := Soma1(cSeq)
				EndIf
			Endif
		Next nLin
	EndIF

	oGet:oBrowse:nAt := n
	oGet:oBrowse:Refresh(.T.)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f813Grinc ³ Autor ³ Andreia dos Santos    ³ Data ³ 11.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os registros Incluidos na GetDados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ f813Grava                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function f813Grinc( cAlias , nIniciar )
Local nX        := 1
Local nY
Local nPosSeq   := GdFieldPos("F3I_SEQUEN")
Local nMaxArray := Len(aHeader)
Local cCampo
Local xConteudo := ""

	For nX	:=	nIniciar TO Len(aCols)
		If aCols[nX,nUsado+1]  = .F.
			F3I->( RecLock(cAlias,.T.,.T.) ) //Inclusao
			F3I->F3I_FILIAL 	:= xFilial(cAlias)
			F3I->F3I_CODIGO 	:= cCodigo
			F3I->F3I_SEQUEN		:= aCols[nX,nPosSeq]
			For nY := 2 To nMaxArray
				cCampo    := Trim(aHeader[nY][2])
				xConteudo += a813Transf(aCols[nX,nY],aHeader[nY][8],aHeader[nY][4],aHeader[nY][5])
			Next nY
			F3I->F3I_CONTEU := xConteudo
			xConteudo	:= ""
			F3I->( MsUnlock() )
		EndIf
	Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FISA813MovºAutor  ³Andreia dos Santos  º Data ³  13/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Movimenta o cursor para nao parar na coluna sequencia       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f813Mov( lMov )
Local ni        := 0.00
Local nPosicao  := 0.00
Local nPosTip   := 0.00
Local nStep     := 0.00
Local nPulos    := 0.00

DEFAULT lMov    := .F.

	If !lMov
		Return( .T. )
	Endif

	nPosicao  := GdFieldPos( "F3I_SEQUEN" )
	nPosicao ++
	nStep  := IF(nPosTip > nPosicao , -1 , 1)
	nPulos := Abs( nPosicao - nPosTip )

	If nStep > 0
		nPulos --
	Else
		If nPostip != Len(aHeader)
			nPulos ++
		Endif
	Endif

	For ni := 1 to nPulos
		If nStep > 0
			oGet:oBrowse:GoRight()
		Else
			oGet:oBrowse:GoLeft()
		Endif
	Next
	IF nPulos <= 0
		oGet:oBrowse:bEditCol:= { || Alwaystrue() }
	EndIF

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Duplic813 ºKelly  ³                    º Data ³  20/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Duplicar uma tabela ja existente                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA813                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Duplic813()
Local aKeys        := GetKeys()
Local oDlg
Local oFont1
// variaveis para controle de coordenadas da janela //
Local aAdvSize     := {}
Local aInfoAdvSize := {}
Local aObjSize     := {}
Local aObjCoords   := {}
Local bSet15       := { || NIL } // Bloco com as validacoes do botao OK
Local bSet24       := { || NIL } // Bloco com as validacoes do botao Cancelar
Local cConsPad     := "XM0" // Consulta padrao do campo F3I_FILIAL

Private lChkBox1   := .F.
Private oChkBox1, oNovaFilOrig, oNovoMesAnoOrig, oFilDest, oMesAnoDest
Private cNovaFilOrig
Private cNovoMesAnoOrig
Private cFilOrig    := CriaVar("F3I_FILIAL")
Private cFilDest    := CriaVar("F3I_FILIAL")

	cFilOrig 		:= aCols[n][1]
	cMesAnoOrig 	:= aCols[n][2]
	cNovaFilOrig 	:= cFilOrig
	cNovoMesAnoOrig := cMesAnoOrig

	FilDato813(cFilOrig,cMesAnoOrig)

	oGet:Goto(1)
	oGet:oBrowse:Refresh(.T.)

		DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13
		DEFINE FONT oFont2  NAME "Arial" SIZE 0,-13 BOLD
		DEFINE FONT oFont3  NAME "Arial" SIZE 0,-11

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta as Dimensoes dos Objetos         					   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aAdvSize		:= MsAdvSize()
		aAdvSize[5]		:=	460 //horizontal
		aAdvSize[3]		:=	230 // LARGURA
		aAdvSize[4]		:=	130 // ALTURA
		aAdvSize[6]		:=  250 //Vertical
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
		aAdd( aObjCoords , { 000 , 070 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	    DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0035) OF GetWndDefault() STYLE DS_MODALFRAME PIXEL //"Manutencao de Tabelas"

	   		@aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0039) OF oDlg PIXEL //"Origem"
			@aObjSize[1,1]+10,aObjSize[1,2]+5 SAY OemToAnsi(STR0037) SIZE 030,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE //"Filial:"
			@aObjSize[1,1]+10,aObjSize[1,2]+50 SAY cFilOrig SIZE 030,007 OF oDlg  PIXEL FONT oFont2 COLOR CLR_BLUE
			@aObjSize[1,1]+10,aObjSize[1,2]+100  SAY OemToAnsi(STR0038) SIZE 033,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE //"Mes/Ano:"
			@aObjSize[1,1]+10,aObjSize[1,2]+150  SAY SubStr(cMesAnoOrig,1,2) + " / " + SubStr(cMesAnoOrig,3,4) SIZE 030,007 OF oDlg PIXEL FONT oFont2 COLOR CLR_BLUE
			@aObjSize[1,1]+25,aObjSize[1,2]+5 TO aObjSize[1,3]-5,aObjSize[1,4]-5 OF oDlg PIXEL //"Alterar Origem"
			@aObjSize[1,1]+30,aObjSize[1,2]+10 CHECKBOX oChkBox1 VAR lChkBox1 PROMPT STR0043 PIXEL SIZE 70,7 OF oDlg ON CHANGE ( fChkBox() )
			@aObjSize[1,1]+50,aObjSize[1,2]+10 SAY OemToAnsi(STR0037) SIZE 030,007	OF oDlg PIXEL FONT oFont1 //"Filial:"
			@aObjSize[1,1]+50,aObjSize[1,2]+50 MSGET oNovaFilOrig VAR cNovaFilOrig SIZE 015,007 OF oDlg PIXEL FONT oFont3	F3 cConsPad
			@aObjSize[1,1]+50,aObjSize[1,2]+100 SAY OemToAnsi(STR0038) SIZE 033,007	OF oDlg PIXEL  FONT oFont1 //"Mes/Ano:"
			@aObjSize[1,1]+50,aObjSize[1,2]+150 MSGET oNovoMesAnoOrig VAR cNovoMesAnoOrig	SIZE 030,007	OF oDlg PIXEL  FONT oFont3
			@aObjSize[2,1], aObjSize[2,2] TO aObjSize[2,3],aObjSize[2,4] LABEL OemToAnsi(STR0040)						OF oDlg PIXEL //"Destino"
	       @aObjSize[2,1]+10, aObjSize[2,2]+10 SAY OemToAnsi(STR0037) SIZE 030,007 OF oDlg PIXEL  FONT oFont1 //"Filial:"
			@aObjSize[2,1]+10, aObjSize[2,2]+50 MSGET oFilDest VAR cFilDest SIZE 015,007 OF oDlg PIXEL  FONT oFont3  F3 cConsPad
			@aObjSize[2,1]+10, aObjSize[2,2]+100 SAY OemToAnsi(STR0038) SIZE 033,007 OF oDlg PIXEL FONT oFont1 //"Mes/Ano:"
			@aObjSize[2,1]+10, aObjSize[2,2]+150 MSGET oMesAnoDest VAR cMesAnoDest SIZE 030,007 OF oDlg PIXEL FONT oFont3

			If lChkbox1
				oNovaFilOrig:Enable()
				oNovoMesAnoOrig:Enable()
			Else
				oNovaFilOrig:Disable()
				oNovoMesAnoOrig:Disable()
			Endif

			bSet15 := { || nOpcA := 1 , If(!fExiste813(cFilOrig,cMesAnoOrig,cNovaFilOrig,cNovoMesAnoOrig,cFilDest,cMesAnoDest,lChkBox1),   oDlg:End(),)}
			bSet24 := { || nOpcA := 2 , Aplicar(aVisual) , fReorder813() , RestKeys(aKeys,.T.), oDlg:End()}

			oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fChkBox  ³ Autor ³ Kelly                 ³ Data ³ 24/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/Desabilita os campos de origem, de acordo com a   ³±±
±±|          | marcacao do CheckBox                                       |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Duplicar                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkBox()

	If lChkBox1
		oNovaFilOrig:Enable()
		oNovoMesAnoOrig:Enable()
		oNovaFilOrig:SetFocus()
	Else
		oNovaFilOrig:Disable()
		oNovoMesAnoOrig:Disable()
	EndIf
	oNovaFilOrig:Refresh()
	oNovoMesAnoOrig:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GerRegs813      ³Kelly  |                    º Data ³  20/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera os novos registros a partir da tabela origem indicada        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³fExiste813                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GerRegs813(cFil, cChav)
Local aTabela := {}
Local nReg    := len(aCols)
Local nCols   := len(aHeader)
Local nX      := 0
Local nY      := 0
Local nCont   := 1

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Alimenta a array temporaria com os registros que deverao ser duplicados.  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	FOR nX := 1 to nReg
		if (aCols[nX][1] == cFil .and. aCols[nX][2] == cChav) .and. (aCols[nX,nCols+1] == .F.)
			aAdd(aTabela,Array(nCols+1))
			for nY := 1 to nCols+1
				if nY == nCols+1
					aTabela[nCont][nY] := .F.
				else
					aTabela[nCont][nY] := aCols[nX][nY]
				endif
			next nY
			nCont++
		endif
	Next nX

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Atualiza aCols com os novos registros.                                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If (len(aTabela)>0)
		nCont := nReg + 1

		FOR nX := 1 to len(aTabela)
			aAdd(aCols,Array(nCols+1))
			aCols[nCont][1] := cFilDest
			aCols[nCont][2] := cMesAnoDest
			FOR nY := 3 to nCols+1
				aCols[nCont][nY] := aTabela[nX][nY]
			NEXT nY
			nCont++
		NEXT nX

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Atualiza os registros de origem caso o usuario tenha marcado a opcao ALTERAR ORIGEM.  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If lChkBox1
			FOR nX := 1 to nReg
				if (aCols[nX][1] = cFil .and. aCols[nX][2] = cChav) .and. (aCols[nX,nCols+1] = .F.)
					aCols[nX][1] := cNovaFilOrig
					aCols[nX][2] := cNovoMesAnoOrig
				endif
			Next nX
		Endif
		Aplicar(aCols)
	Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Aplicar   ³Kelly  |                    º Data ³  25/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplicar as alteracoes efetuadas, atualizando o aCols        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA813                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Aplicar(aArray)
Local nRegAntes	:= len(aAntes)
Local nRegACols := len(aArray)
Local nCont
Local nX, nY

Private nCols := len(aHeader)

	nCont := nRegAntes + 1

	// Adiciona os novos registros na matriz dos dados mantidos
	FOR nX := 1 to nRegACols
		aAdd(aAntes,Array(nCols+1))
		FOR nY := 1 to nCols+1
			aAntes[nCont][nY] := aArray[nX][nY]
		NEXT nY
		nCont++
		nRegAntes++
	NEXT nX

	// Limpa o aCols
	aCols := {}
	aCols := Array (0,0)

	// Atualiza o aCols de acordo com a matriz anterior
	FOR nX := 1 To nRegAntes
		aAdd(aCols,Array(nCols+1))
		FOR nY := 1 to nCols+1
			aCols[nX][nY] := aAntes[nX][nY]
		NEXT nY
	NEXT nX

	fReorder813()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Rejusta813³Kelly  |                    º Data ³  25/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplicar um percetual ou somar um valor nos dados da tabela  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA813                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Rejusta813()
Local aKeys		  := GetKeys()
Local nX
Local oDlg
Local oFont1
Local oRadio
Local bBlock        := { || NIL }
Local cFilOrig      := CriaVar("F3I_FILIAL")
// variaveis para controle de coordenadas da janela //
Local aAdvSize      := {}
Local aInfoAdvSize  := {}
Local aObjSize      := {}
Local aObj2Size     := {}
Local aObjCoords    := {}
Local aObj2Coords   := {}
Local bSet15        := { || NIL }
Local bSet24        := { || NIL }

Private lChkPerc    := .F.
Private lChkSomar   := .F.
Private nPerc       := 0
Private nSomar      := 0
Private oPerc, oSomar
Private nItem       := 1
Private oLbx,cLbx
Private aLbx	      := {}
Private cFilial1    := aCols[n][1]
Private cChave1     := aCols[n][2]
Private oOk         := LoadBitmap( GetResources(), "LBOK" )
Private oNo         := LoadBitmap( GetResources(), "LBNO" )
Private nCampos     := 0
Private nRadio      := 0

	cFilOrig	:= aCols[n][1]
	cMesAnoOrig	:= aCols[n][2]
	FilDato813(cFilOrig,cMesAnoOrig)
	oGet:Goto(1)
	oGet:oBrowse:Refresh(.T.)

	dbSelectArea( "F3H" )
	dbSetOrder(1)
	dbSeek(xFilial("F3H") + cCodigo)
	nX := 1
	While !eof() .and. F3H->F3H_CODIGO == cCodigo
		If F3H->F3H_TIPO == "N"
			aAdd(aLbx, { .F. , F3H->F3H_DESCPO , nX })
		Endif
		nX++
		nCampos++
		dbSkip()
	Enddo

	// Se nao existir campo numerico nem apresenta a tela de reajuste
	If len(aLbx) == 0
		oGet:oBrowse:Refresh(.T.)
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0074),{'OK'},,STR0014) //"Atencao" ### "Nao ha campos a serem reajustados."
	Else

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta as Dimensoes dos Objetos         					   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aAdvSize    := MsAdvSize()
		aAdvSize[5] :=	543 //horizontal
		aAdvSize[3] :=	270 // LARGURA
		aAdvSize[4] :=	140  // ALTURA
		aAdvSize[6] :=  375 //Vertical
		aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3 }
		aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 090 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 045 , .T. , .F. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		aAdd( aObj2Coords , { 000 , 025 , .T. , .F. } )
		aAdd( aObj2Coords , { 000 , 090 , .T. , .F. , .T. } )
		aAdd( aObj2Coords , { 000 , 050 , .T. , .F. } )
		aObj2Size		:= MsObjSize( aInfoAdvSize , aObj2Coords )

	    DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13
		DEFINE FONT oFont2  NAME "Arial" SIZE 0,-13 BOLD
		DEFINE FONT oFont3  NAME "Arial" SIZE 0,-11

		DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0042) OF GetWndDefault() STYLE DS_MODALFRAME PIXEL //"Manutencao de Tabelas"

			@aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] LABEL "" OF oDlg PIXEL
			@aObjSize[1,1]+10,aObjSize[1,2]+5 SAY OemToAnsi(STR0037) SIZE 030,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE //"Filial:"
			@aObjSize[1,1]+10,aObjSize[1,2]+50 SAY cFilial1			 SIZE 030,007 OF oDlg PIXEL FONT oFont2 COLOR CLR_BLUE
			@aObjSize[1,1]+10,aObjSize[1,2]+100 SAY OemToAnsi(STR0038)	SIZE 033,007 OF oDlg PIXEL FONT oFont1 COLOR CLR_BLUE //"Mes/Ano:"
			@aObjSize[1,1]+10,aObjSize[1,2]+150 SAY SubStr(cChave1,1,2) + " / " + SubStr(cChave1,3,4) SIZE 030,007 OF oDlg PIXEL FONT oFont2 COLOR CLR_BLUE
			@aObjSize[2,1],aObjSize[2,2] TO aObjSize[2,3],aObjSize[2,4] LABEL "" OF oDlg PIXEL
			@aObjSize[2,1]+10,aObjSize[2,2]+10 TO aObjSize[2,3]*0.65,aObjSize[2,4]*0.50 LABEL "" OF oDlg PIXEL
		  	@aObjSize[2,1]+20,aObjSize[2,2]+20 CHECKBOX oChkPerc VAR lChkPerc PROMPT "" PIXEL SIZE 7,7 OF oDlg ON CHANGE ( fChkPerc() ) //"Aplicar Percentual:"
			@aObjSize[2,1]+20,aObjSize[2,2]+30 SAY OemToAnsi(STR0046) SIZE 030,009 OF oDlg FONT oFont1 PIXEL
			@aObjSize[2,1]+20,aObjSize[2,2]+70 MSGET oPerc VAR nPerc SIZE 030,007 OF oDlg PICTURE "@E 999.99" FONT oFont3 PIXEL HASBUTTON
			@aObjSize[2,3]*0.66,aObjSize[2,2]+10 TO aObjSize[2,3]-10, aObjSize[2,4]*0.50 LABEL "" OF oDlg PIXEL
			@(aObjSize[2,3]*0.66)+10,aObjSize[2,2]+20 CHECKBOX oChkSomar VAR lChkSomar PROMPT "" PIXEL SIZE 7,7 OF oDlg ON CHANGE ( fChkSomar() ) //"Somar:"
			@aObjSize[2,3]*0.66+10,aObjSize[2,2]+30 SAY OemToAnsi(STR0047) SIZE 030,007 OF oDlg  FONT oFont1 PIXEL
			@aObjSize[2,3]*0.66+10,aObjSize[2,2]+70 MSGET oSomar VAR nSomar SIZE 030,007 OF oDlg PIXEL	PICTURE "@E 9,999.99" FONT oFont3 HASBUTTON

		   	If lChkPerc
				oPerc:Enable()
			Else
				oPerc:Disable()
			Endif
			If lChkSomar
				oSomar:Enable()
			Else
				oSomar:Disable()
			Endif

			@aObj2Size[2][1]+10, aObj2Size[2][2]+132 LISTBOX oLbx VAR cLbx FIELDS HEADER  "", OemtoAnsi(STR0048) SIZE aObj2Size[2][3]/2.2 ,aObj2Size[2][4]-20 ON DBLCLICK (aLbx:=fSelLbx(oLbx:nAt,aLbx),oLbx:Refresh()) PIXEL //"Colunas"
			oLbx:SetArray(aLbx)
			oLbx:LHSCROLL := .F.
			oLbx:LVSCROLL := .T.
			oLbx:nFreeze  := 1
			oLbx:bLine    := { || {If(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2]}}
		   	oLbx:nAt      := Max(nItem,1)
			oLbx:nRowPos  := 1
			@aObjSize[3,1],aObjSize[3,2] GROUP oGroup TO aObjSize[3,3],aObjSize[3,4] PROMPT OemtoAnsi(STR0078) OF oDlg PIXEL COLOR CLR_BLUE //"Arredondamento"
			oGroup:SetFont(oFont1)
			bBlock	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) }
			oRadio	:= TRadMenu():New( aObjSize[3,1]+10,aObjSize[3,2]+10, {oEmToAnsi(STR0079), oEmToAnsi(STR0080), oEmToAnsi(STR0081)},bBlock,oDlg,,,,,,,,80,10)	//"Nenhum"###"Padrao"###"Acima"
			nRadio	:= oRadio:nOption
			bSet15 := { || nOpcA := 1 , If(fValido813(),  oDlg:End() , )}
			bSet24 := { || nOpcA := 2 , Aplicar(aVisual) , fReorder813() , 	RestKeys(aKeys,.T.), oDlg:End() }
			oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fChkPerc ³ Autor ³ Kelly                 ³ Data ³ 26/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/Desabilita os campos de "Aplicar Percentual"      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rejusta813                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkPerc()

	If lChkPerc
		oPerc:Enable()
		oPerc:Setfocus()
	Else
		oPerc:Disable()
	EndIf
	oPerc:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fChkSomar³ Autor ³ Kelly                 ³ Data ³ 26/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/Desabilita os campos de "Somar"                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rejusta813                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkSomar()

	If lChkSomar
		oSomar:Enable()
		oSomar:Setfocus()
	Else
		oSomar:Disable()
	EndIf
	oSomar:Refresh()

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fSelLbx  ³ Autor ³ Kelly                 ³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca e desmarca itens da ListBox                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rejusta813                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelLbx(nAt,aArray)

	aArray[nAt,1] := If(aArray[nAt,1], .F., .T.)

Return aArray


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FilDato813  ³ Autor ³ Kelly                 ³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra a grade apresentando apenas os dados da tabela         ³±±
±±³          | selecionada                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FilDato813(cFilDe, cMesAnoDe)
Local nX, nY
Local nCont  := 1
Local nCont2 := 1
Local nCols  := len(aHeader)
Local nReg   := len(aCols)
Local nRegVis

	aVisual := {}
	aAntes  := {}
	// Alimenta a array de visualizacao apenas com os registros da tab. selecionada.
	FOR nX := 1 to nReg
		If (aCols[nX][1] = cFilDe .and. aCols[nX][2] = cMesAnoDe) .and. (aCols[nX][nCols+1] = .F.)
			aAdd(aVisual,Array(nCols+1))
			for nY := 1 to nCols+1
				aVisual[nCont][nY]	:= aCols[nX][nY]
			next nY
			nCont++
		Else
			aAdd(aAntes,Array(nCols+1))
			for nY := 1 to nCols+1
				aAntes[nCont2][nY]	:= aCols[nX][nY]
			next nY
			nCont2++
		Endif
	Next nX

	nRegVis := len(aVisual)
	// Limpa o aCols
	aCols := {}
	aCols := Array( 0 , 0 )
	// Alimenta o aCols com os dados da array de visualizacao.
	FOR nX := 1 to nRegVis
		aAdd(aCols,Array(nCols+1))
		for nY := 1 to nCols+1
			aCols[nX][nY] := aVisual[nX][nY]
		next nY
	Next nX

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fValido813     ³ Autor ³ Kelly                 ³ Data ³ 26.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as opcoes e os campos e faz o reajuste                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rejusta813                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fValido813()
Local lOk         := .T.
Local nP, nX, nY
Local nReg        := len(aCols)
Local nCols       := len(aHeader)
Local nRSoma, nRPerc
Local nAux
Local nEstouro    := 0

	// Verifica se alguma opcao foi marcada e se o valor ou o % foi informado
	If !lChkPerc .and. !lChkSomar
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0049),{'OK'},,STR0053) //"Atencao" ### "Selecione pelo menos uma opcao de reajuste"
	Elseif (lChkPerc .and. nPerc == 0)
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0051),{'OK'},,STR0053) //"Atencao" ### "Informe o percentual de reajuste."
	Elseif (lChkSomar .and. nSomar == 0)
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0052),{'OK'},,STR0053) //"Atencao" ### "Informe o valor do reajuste"
	Endif

	nP := Ascan( aLbx, { |x| x[1] == .T. } )
	If (nP = 0) .and. (lOk)
		lOk := .F.
		AVISO(OemToAnsi(STR0014),OemToAnsi(STR0050),{'OK'},,STR0053) //"Atencao" ### "Selecione pelo menos uma coluna a ser reajustada"
	Endif

	// Estando tudo ok, aplica o reajuste
	If lOk
		For nY := 1 to nCols
			If aScan(aLbx,{ |x| (Upper(AllTrim(x[2])) == Upper(AllTrim(aHeader[nY][1])) .and. (x[1] == .T.)) } ) > 0
				For nX := 1 to nReg
					nRSoma := aCols[nX][nY] + nSomar
					If nRadio == 1
						nRPerc := NoRound(aCols[nX][nY] * (nPerc/100))
					Elseif nRadio == 2
						nRPerc := Round(aCols[nX][nY] * (nPerc/100),MsDecimais(1))
					Else
						nAux := aCols[nX][nY] * (nPerc/100)
						If nAux - Round(nAux,MsDecimais(1)) > 0.00
							nAux := NoRound((nAux + .01),MsDecimais(1))
						Else
							nAux := Round(nAux,MsDecimais(1))
						Endif
						nRPerc := nAux
					Endif
					If 	Len(Transform((nRSoma + nRPerc),aHeader[nY][3])) > aHeader[nY][4]
						nEstouro := nEstouro + 1
						aCols[nX][nY] := Val(aHeader[nY][3])
					Else
						aCols[nX][nY] := nRSoma + nRPerc
					EndIf
				Next nX
			Endif
		Next nY
		If nEstouro > 0
			MsgAlert(OemToAnsi(STR0091) + AllTrim(STR(nEstouro)) + OemToAnsi(STR0092), OemToAnsi(STR0083)) // "O Valor do reajuste excedeu em " ### " campo(s)" ### "Atenção"
		EndIf
	Endif

	oGet:oBrowse:Refresh(.T.)
	If lOk
		Aplicar(Acols)
	Endif

Return lOk


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fExiste813     ³ Autor ³ Kelly                 ³ Data ³ 28.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica no aCols e no aAntes a existencia de registros com      ³±±
±±³          ³ a filial e o mes/ano indicados.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil01 = Filial Origem                                           ³±±
±±³          ³ cChave01 = Mes/Ano Origem                                        ³±±
±±³          ³ cFil02 = Nova Filial Origem                                      ³±±
±±³          ³ cChave02 = Novo Mes/Ano Origem                                   ³±±
±±³          ³ cFil03 = Filial Destino                                          ³±±
±±³          ³ cChave03 = Mes/Ano Destino                                       ³±±
±±³          ³ lAltOrig = CheckBox "ALTERA ORIGEM"                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Duplicar                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fExiste813(cFil01,cChave01,cFil02,cChave02,cFil03,cChave03,lAltOrig)
Local nA      := 0
Local nB      := 0
Local nC      := 0
Local nD      := 0
Local lExiste := .F.
local cOk     := fCposOk813(cFil02,cChave02,cFil03,cChave03,lAltOrig)

	If cOk <> ""
		lExiste := .T.
		AVISO(OemToAnsi(STR0014),OemToAnsi(cOk),{'OK'},,STR0014)
	Else
		If lAltOrig
			nA := ( Ascan( aCols, { |x| x[1] == cFil02 .and. x[2] == cChave02 } ) )
			nB := ( Ascan( aAntes,{ |x| x[1] == cFil02 .and. x[2] == cChave02 } ) )
		Else
			nC := ( Ascan( aCols, { |x| x[1] == cFil03 .and. x[2] == cChave03 } ) )
			nD := ( Ascan( aAntes,{ |x| x[1] == cFil03 .and. x[2] == cChave03 } ) )
		Endif
		If (nA > 0) .or. (nB > 0) .or. (nC > 0) .or. (nD > 0)
			lExiste := .T.
			AVISO(OemToAnsi(STR0014),OemToAnsi(STR0054),{'OK'},,STR0014) //"Atencao" ### "Já existe(m) registro(s) com Filial e Mês/Ano indicados."
		Endif
		If !lExiste
			GerRegs813(cFil01,cChave01)
		Endif
	Endif

Return lExiste


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fCposOk813     ³ Autor ³ Kelly                 ³ Data ³ 31.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os campos digitados                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilOk1 = Filial Origem                                          ³±±
±±³          ³ cChaveOk1 = Mes/Ano Orige                                        ³±±
±±³          ³ cFilOk2 = Nova Filial Origem                                     ³±±
±±³          ³ cChaveOk2 = Novo Mes/Ano Origem                                  ³±±
±±³          ³ lOrigem = CheckBox "ALTERA ORIGEM"                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fExiste813                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fCposOk813(cFilOk1,cChaveOk1,cFilOk2,cChaveOk2,lOrigem)
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cExibeAviso := ""

	dbSelectArea("SM0")
	dbSetOrder(1)

	If lOrigem
		If (AllTrim(cFilOk1) <> "") .and. (!dbSeek(cEmpAnt + AllTrim(cFilOk1)))
			cExibeAviso := STR0055 // Filial Origem Invalida
		ElseIf (AllTrim(cChaveOk1) <> "") .and. (Len(AllTrim(cChaveOk1)) < 6)
			cExibeAviso := STR0057 // Mes/Ano Origem Invalido
		Elseif (AllTrim(cChaveOk1) <> "") .and. ((VAL(SubStr(cChaveOk1,1,2)) < 1) .or. (VAL(SubStr(cChaveOk1,1,2)) > 12))
			cExibeAviso := STR0059 // Mes Origem Invalido
		Elseif (AllTrim(cChaveOk1) <> "") .and. (VAL(SubStr(cChaveOk1,3,4)) < 1900)
			cExibeAviso := STR0060 // Ano Origem Invalido
		Endif
	Endif
	If (AllTrim(cFilOk2) <> "") .and. (!dbSeek(cEmpAnt + AllTrim(cFilOk2)))
		cExibeAviso := STR0056 // Filial Destino Invalida
	ElseIf (AllTrim(cChaveOk2) <> "") .and. (Len(AllTrim(cChaveOk2)) < 6)
		cExibeAviso := STR0058 // Mes/Ano Destino Invalido
	Elseif (AllTrim(cChaveOk2) <> "") .and. ((VAL(SubStr(cChaveOk2,1,2)) < 1) .or. (VAL(SubStr(cChaveOk2,1,2)) > 12))
		cExibeAviso := STR0061 // Mes Destino Invalido
	Elseif (AllTrim(cChaveOk2) <> "") .and. (VAL(SubStr(cChaveOk2,3,4)) < 1900)
		cExibeAviso := STR0062 // Ano Destino Invalido
	Endif

	RestArea(aArea)
	RestArea(aAreaSM0)

Return cExibeAviso

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Pesq813        ³ Autor ³ Kelly                 ³ Data ³ 31.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa um registro                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilOk1 = Filial Origem                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA813                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*Function Pesq813()
Local aKeys          := GetKeys()
Local oDlg
Local oFont1, oFont2
//-- Variaveis dimensoes do objeto tela
Local aAdvSize       := {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords     := {}
Local bSet15         := {|| NIL}
Local bSet24         := {|| NIL}

Private oPesqFilial, oPesqChave, oChkFilial, oChkChave


	aAdvSize       := MsAdvSize()
	aAdvSize[5]    :=	460 //horizontal
	aAdvSize[3]    :=	230 // LARGURA
	aAdvSize[4]    :=	50  // ALTURA
	aAdvSize[6]    :=  110 //Vertical
	aInfoAdvSize   := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13
	DEFINE FONT oFont2  NAME "Arial" SIZE 0,-11

	DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0065) OF GetWndDefault() STYLE DS_MODALFRAME PIXEL //"Pesquisar Registro"

		@aObjSize[1,1]+10, aObjSize[1,2]+10 SAY OemToAnsi(STR0037) SIZE 040,007 OF oDlg PIXEL FONT oFont1 //"Filial:"
		@aObjSize[1,1]+10, aObjSize[1,2]+50 MSGET oPesqFilial VAR cPesqFilial	SIZE 050,007	OF oDlg PIXEL FONT oFont2
		@aObjSize[1,1]+25, aObjSize[1,2]+10 SAY OemToAnsi(STR0038) SIZE 043,007 OF oDlg PIXEL FONT oFont1	//"Mes/Ano:"
		@aObjSize[1,1]+25, aObjSize[1,2]+50 MSGET oPesqChave  VAR cPesqChave SIZE 050,007	OF oDlg PIXEL FONT oFont2

		bSet15 := { || nOpcA := 1 , fFind813(cPesqFilial,cPesqChave) ,  oDlg:End()}
		bSet24 := { || nOpcA := 2 , RestKeys(aKeys,.T.), oDlg:End() }
		oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15 , bSet24 ) CENTERED

Return

Return*/

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fFind813       ³ Autor ³ Kelly                 ³ Data ³ 31.10.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa um registro com a filial e a chave indicadas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPFil = Filial Origem                                            ³±±
±±³          ³ cPChave = Mes/Ano Orige                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pesq813                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*Function fFind813(cPFil,cPChave)

	nP := ( Ascan( aCols, { |x| x[1]+Right(x[2],4)+Left(x[2],2) >= cPFil+Right(cPChave,4)+Left(cPChave,2) } ) )
	If nP = 0
	   nP := 1
	Endif
	oGet:Goto( nP )
	oGet:oBrowse:Refresh(.T.)

Return*/






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fExcluirOk2 ³ Autor: Kelly Soares        ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica integridade dos dados da Tabela com o Lancto Fixo.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*Static Function fExcluirOk2()
Local lOk  := .T.

	lOk := !fTemLanctoFixo( cCodigo , Val(aColsBkp[Len(aColsBkp),3]) , 0 , "2" )

Return lOk*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAtualizaBkp2  ³ Autor: Kelly Soares     ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a array de bkp dp aCols.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fAtualizaBkp2()
Local nX

	If nBkp < Len(aCols)
		aAdd(aColsBkp , Array(len(aCols[n])))
		For nX := 1 to len(aCols[n])
			aColsBkp[Len(aColsBkp),nX] := aCols[n,nX]
		Next nX
		nBkp ++
	Endif

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef        ³Autor³  Luiz Gustavo     ³ Data ³04/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >                                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³FISA813                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

Local aRotina := { { STR0002   , 'PesqBrw'   , 0 , 1,,.F.},; //'Pesquisar'
                   { STR0003   , 'f813Alt'   , 0 , 2},; //'Visualizar'
                   { STR0004   , 'f813Alt'   , 0 , 3},; //'Incluir'
                   { STR0005   , 'f813Alt'   , 0 , 4},; //'Alterar'
                   { STR0006   , 'f813Exc'   , 0 , 5},; //'Excluir'
                   { STR0007   , 'f813Leg'   , 0 , 7,,.F.} } //'Legenda'
 If cPaisLoc == "BOL"
 	AADD(aRotina,{ STR0093 , 'fis813CBol'   , 0 , 6}) //'Obtener Catálogos del SIN '
 EndIf

Return aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ f813SeqAlfa()  ³Autor³  Mohanad Odeh     ³ Data ³12/12/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Gera sequência de valores alfanuméricos                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >                                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³FISA813                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³cRet                                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function f813SeqAlfa(cSeq)
Local nConta  := 3
Local cLetra  := ""
Local cRet    := ""
Local nAux    := 0
Local blMuda  := .F.

	If Val(cSeq) >= 000 .AND. Val(cSeq) <= 998
		cRet := Soma1(cSeq)
	ElseIf Val(cSeq) == 999
		cRet := "AA1"
	Else
		For nConta:= 3 To 1 step - 1
			cLetra := SubStr(cSeq, nConta, 1)
			If nConta == 3 .Or. blMuda
				IF (Asc(cLetra) >= 48 .and. Asc(cLetra) <= 56)
					cLetra := AllTrim(Str(val(cLetra) + 1))
					blMuda := .F.
				ElseIf Asc(cLetra) == 57
					cLetra := "A"
					blMuda := .F.
				ElseIf (Asc(cLetra) >= 65 .and. Asc(cLetra) <= 89)
					nAux := Asc(cLetra) + 1
					cLetra := CHR(nAux)
					blMuda := .F.
				ElseIf Asc(cLetra) == 90
					cLetra := "1"
					blMuda := .T.
				Endif
			Endif
			cRet := cLetra + cRet
		Next
	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fis813CBol ³ Autor ³ Alf. Medrano        ³ Data ³ 14/10/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ejecuta la función de descarga de catalogos del SIN        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ N/A                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MenuDef                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fis813CBol()
	Local cPerg := "FISA813C"
	Local cMsg  := ""
	Local aDatosSM0 := {}
	Private cMVCFDIAMB := SuperGetMV("MV_CFDIAMB",,"")//Cod. Ambiente
	Private cMVSISTEMA := SuperGetMV("MV_SINSIS",,"") //Cod. Sistema
	Private cMVNUMSUC  := alltrim(STR(SuperGetMV("MV_NUMSUC",,0)))  //Cod. Sucursal
	Private cMVCUIS    := SuperGetMV("MV_CUIS",,"")	  //CUIS
	Private cMVNIT     := ""                          //NIT
	Private cMV814PATH := SuperGetMV("MV_PATH814 ",,"") //Direccion donde se guardaran los archivos csv
	Private cRutaSMR   := &(SuperGetMV("MV_CFDSMAR",,""))//ruta donde reside el cliente de WS
	Private cMVMODAL   := SuperGetMV("MV_SINMOD",,"") //Modalidad 1=Electrónica, 2=Computarizada, 3=Manual, 4=Prevalorada Electrónica, 5=Prevalorada Computarizada

	aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , {"M0_CGC"} )
	cMVNIT := aDatosSM0[1][2]

	If F813VldPar()
		If Pergunte(cPerg,.T.)
			If mv_par01 == 1
				cMsg += STR0094 + chr(13)+ Chr(10)//"Sincronización diaria."
				cMsg += STR0095 + chr(13)+ Chr(10)//"Este proceso sincroniza de manera total el catálogo "
				cMsg += STR0096 + chr(13)+ Chr(10)//"cuando se ejecuta la primera vez, para la siguiente  "
				cMsg += STR0097 + chr(13)+ Chr(10)//"ejecución solo se actualizarán los nuevos códigos  "
				cMsg += STR0098 + chr(13)+ Chr(10)//"obtenidos del proceso de sincronización con el SIAT."
			ElseIf mv_par01 == 2
				cMsg += STR0099 + chr(13)+ Chr(10)//"Sincronización por solicitud. "
				cMsg += STR0100 + chr(13)+ Chr(10) //"Esta forma reemplaza en su totalidad los catálogos "
				cMsg += STR0101 + chr(13)+ Chr(10) //"existentes en el sistema por los catálogos obtenidos "
				cMsg += STR0102 + chr(13)+ Chr(10) //"por medio del proceso de sincronización SIAT."
			EndIf
			cMsg += STR0103 //"¿Desea continuar?"
			If MsgYESNO(cMsg)
				processa({|| fis813Cat()}, STR0104, STR0105,.f.) //'Aguarde...', 'Obteniendo catálogos del SIN'
			EndIf
		EndIf
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fis813Cat ³ Autor ³ Alf. Medrano         ³ Data ³ 14/10/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Comunicación con el WS para la obtencion de catalogos SIN  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ N/A                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ fis813CBol                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fis813Cat()
	Local cParams    := ""
	Local cMVCFDIPA  := SuperGetMV("MV_CFDI_PA",,"")   //Nombre del ejecutable del servicio web a utiliza.
	Local cPath 	 := &(SuperGetMV("MV_CFDDOCS",,""))
	Local cMsg 		 := ""
	Local cCodigo 	 := ""
	Local cDescrip 	 := ""
	Local cError 	 := ""
	Local cCatOk 	 := ""
	Local cWarning 	 := ""
	Local lHasError  := .F.
	Local cCodTab 	 := ""
	Local nX		 := 0
	Local nOpc 		 := 0
	Local nHandle 	 := 0
	Local nRet		 := 0
	Local nTipoDesc  := MV_PAR01
	Local cCodAut	 := "1"
	Local oDlg       := Nil
	Local oMemo      := Nil
	Local oButton    := Nil

	Private cFilF3I  := xFilial("F3I")

	If nTipoDesc == 2 // Descarga Completa
		If !Empty(MV_PAR02)
			cCodAut := alltrim(MV_PAR02)
		EndIf
	EndIf

	cParams := "L "//Opción para carga de catálogos
	cParams += cMVCFDIAMB + " "
	cParams += cMVSISTEMA + " "
	cParams += cMVNUMSUC + " "
	cParams += cMVCUIS + " "
	cParams += cMVNIT + " "
	cParams += cMV814PATH + " "
	cParams += cRutaSMR	 + " "
	cParams += cMVMODAL + " "
	cParams += "X "
	cParams += "X "
	cParams += "X "
	cParams += "X "
	cParams += "1 "
	cParams += "1 "
	cParams += cCodAut + " "
	cParams += "X "
	cParams += "0 "

	CursorWait()
	nOpc := WAITRUN( cRutaSMR + cMVCFDIPA + ".exe " + cParams, 0 )	// Se ejecuta exe
	If nOpc == 0
		If File(cRutaSMR  + "catalogos.xml.out")
			CpyT2S(cRutaSMR  + "catalogos.xml.out" , cPath)
			// Procesar archivo out
			oXMLResp := XmlParserFile(EncodeUtf8(cPath + "catalogos.xml.out"), "_", @cError, @cWarning )
			If oXMLResp <> Nil
				If ValType( oXMLResp:_RESPONSES:_RESPONSE) == "A"
					ProcRegua((Len(oXMLResp:_RESPONSES:_RESPONSE)))
					For nX := 1 To Len(oXMLResp:_RESPONSES:_RESPONSE)
						lHasError := "True" $ oXMLResp:_RESPONSES:_RESPONSE[nX]:_HASERROR:TEXT
						If lHasError // Si el .out reportó error
							cCodigo := oXMLResp:_RESPONSES:_RESPONSE[nX]:_EXCEPTION:_CODE:TEXT
							cDescrip:= oXMLResp:_RESPONSES:_RESPONSE[nX]:_EXCEPTION:_MESSAGE:TEXT
							cError 	+=  STR0113 + " - " + cDescrip + STR0108  + chr(13)+ Chr(10)// "Catálogo", " no se cargo."
							cError  +=  STR0106 + cCodigo + " " + ObtColSAT('S012',cCodigo,1,4,5,120) +  chr(13)+ Chr(10) //"Codigo Respuesta: "
							IncProc(STR0107+cDescrip)//"No se cargo el catálogo : "
						Else
							cCodigo	:= oXMLResp:_RESPONSES:_RESPONSE[nX]:_MESSAGE:_CODE:TEXT
							cDescrip:= oXMLResp:_RESPONSES:_RESPONSE[nX]:_MESSAGE:_DESCRIPTION:TEXT
							cDataTim:= StrTran(ALLTRIM(oXMLResp:_RESPONSES:_RESPONSE[nX]:_MESSAGE:_DATE:TEXT),"-","")
							cCodTab	:= StrTran(ALLTRIM(oXMLResp:_RESPONSES:_RESPONSE[nX]:_MESSAGE:_CODTAB:TEXT),"-","")
							IncProc(STR0109+cDescrip) //"Cargando catálogo : "
							nHandle := fopen(cMV814PATH + cDescrip +".csv")
							If FRead( nHandle, "", 1) > 0 // Lee el primer byte
								F813LisCat(cCodTab) // borra de F3I
								cCatOk	+=  STR0113 + " - " + cDataTim +  " " + cDescrip +  " " + cCodTab +  STR0110 + chr(13)+ Chr(10)// "Catálogo", " se ha cargado en csv "
								nRet++
							EndIf
						EndIf
					Next
				EndIf
			EndIf

			IIf(nRet>0,FISA814(),) // vuelve a generar el contenido de los catalogos

			cMsg := cCatOk + cError
			DEFINE MSDIALOG oDlg FROM 0,0 TO 375,440 PIXEL TITLE STR0111 //'Observaciones'
			oMemo:= tMultiget():New(10,10,{|u|if(Pcount()>0,cMsg:=u,cMsg)} ,oDlg,200,150,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
			oButton  := TButton():New(165, 160,STR0112,oDlg,{||oDlg:End()},30,11,,,,.T.) //	"Salir"
			ACTIVATE MSDIALOG oDlg CENTERED

			//borrar archivo de la carpeta del smarth
			Ferase( cRutaSMR + "catalogos.xml.out" )
		EndIf
		CursorArrow()
	Else
		MsgAlert(STR0114 + cRutaSMR + cMVCFDIPA + ".exe ", STR0014) //"Ha ocurrido un error al ejecutar: " //"¡Atención!"
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ F813LisCat ³ Autor ³ Alf. Medrano       ³ Data ³ 14/10/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Comunicación con el WS para la obtencion de catalogos SIN  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ N/A                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ fis813Cat                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F813LisCat(cCodTab)
	Local lRet   := .T.
	Local cQuery := ""
	Default cCodTab := ""

	If cCodTab != ""
		If MV_PAR01 == 1 // carga los registros nuevos (actualización de catalogos)
			fs814UpBol( cCodTab, MV_PAR01)
		ElseIf MV_PAR01 == 2 // carga de manera total los catalogos
			cCodTab := Alltrim(cCodTab)
			If F3I->(dbSeek(cFilF3I + cCodTab))
				cQuery := "DELETE FROM " + RetSqlName("F3I") + " WHERE F3I_CODIGO ='" + cCodTab +"'"
				If TcSqlExec(cQuery) <> 0
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} F813VldPar
Valida confoguración de parámetros necesarios para factura electróncia.
@type function
@author luis.enríquez
@since 13/12/2019
@version 1.0
@return lRet, Valor lógico .T. sin errores, .F. faltó configuración de parámetros.
/*/
Static Function F813VldPar()
	Local lRet := .T.
	Local cMsg := STR0115 + Chr(10) + Chr(13) //"Falta configuración de los siguientes parámetros: "

	If Empty(cMVCFDIAMB)
		cMsg += " - MV_CFDIAMB - " + STR0116 + Chr(10) + Chr(13) //"Ambiente de trabajo; 1=Producción, 2=Pruebas."
		lRet := .F.
	EndIf

	If Empty(cMVSISTEMA)
		cMsg += " - MV_SINSIS - " + STR0117 + Chr(10) + Chr(13) //"Código de Sistema (Solicitud de Certificación de Sistemas)."
		lRet := .F.
	EndIf
	If Empty(cMVNUMSUC)
		cMsg += " - MV_NUMSUC - " + STR0118 + Chr(10) + Chr(13) //"Número de sucursal. Máximo hasta la 9999, también puede ser 0 (casa matriz)."
		lRet := .F.
	EndIf
	If Empty(cMVCUIS)
		cMsg += " - MV_CUIS - " + STR0119 + Chr(10) + Chr(13) //"Código Único de Inicio de Sistemas (Solicitud de Certificación de Sistemas)."
		lRet := .F.
	EndIf
	If Empty(cMV814PATH)
		cMsg += " - MV_PATH814 - " + STR0120 + Chr(10) + Chr(13) //"Ruta para tomar los archivos csv y generar los catálogos."
		lRet := .F.
	EndIf
	If Empty(cRutaSMR)
		cMsg += " - MV_CFDSMAR - " + STR0121 + Chr(10) + Chr(13) //"Carpeta local en donde se procesaran las facturas para generar el timbres fiscales."
		lRet := .F.
	EndIf
	If Empty(cMVMODAL)
		cMsg += " - MV_SINMOD - " + STR0121 + Chr(10) + Chr(13) //"Modalidad factura electrónica Bolivia; 1=Electrónica/2=Computarizada/3=Manual/4=Prevalorada Electrónica/5=Prevalorada Computarizada."
		lRet := .F.
	EndIf

	If !lRet
		MsgAlert(cMsg, STR0014) //"¡Atención!"
	EndIf
Return lRet
