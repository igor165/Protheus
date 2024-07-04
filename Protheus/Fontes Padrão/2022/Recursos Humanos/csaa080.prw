#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAA080.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CSAA080  ³ Autor ³ Cristina Ogura          ³ Data ³ 03.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Aumento Programado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSAA080()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA080                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³07/07/2014³TPZVTW³Incluido o fonte da 11 para a 12 e        ³±±
±±³            ³          ³      ³efetuada a limpeza.                       ³±±
±±³Esther V.   ³07/06/2016³TVFY37³Incluida validacao de acesso de usuario.  ³±±
±±³Oswaldo L    ³08/05/17 ³DRHPONTP11  ³Projeto SOYUZ ajuste Ctree          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAA080()

Local aIndexSRA		:= {}			//Variavel Para Filtro
Private aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Private bFiltraBrw	:= {|| Nil}		//Variavel para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada 								 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada 						 ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados			 ³
//³    2 - Simplesmente Mostra os Campos						 ³
//³    3 - Inclui registros no Bancos de Dados					 ³
//³    4 - Altera o registro corrente							 ³
//³    5 - Remove o registro corrente do Banco de Dados 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro := OemToAnsi(STR0004) //"Programar aumento para os funcionarios"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Arquivo Esta Vazio                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkVazio("SRA")
	Return
Endif

	//Tratamento de acesso a Dados Sensíveis
	If aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_CODFUNC"} ) )
		//"Dados Protegidos-Acesso Restrito"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Break
	EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³So Executa se o Modo de Acesso dos Arquivos do Ponto estiverem OK e o Ca³
³dastro de Funcionario Nao Estiver Vazio								 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !xRetModo( "SRA" , "RB7" )
	Break
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh := CHKRH(FunName(),"SRA","1")
bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
dbGoTop()

mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SRA",aIndexSRA)

dbSelectArea("SRA")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs080Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina principal do programa de Aumento dos funcionarios   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs080Rot(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo 								  ³±±
±±³ 		 ³ ExpN1 = Numero do registro							   	  ³±±
±±³ 		 ³ ExpN2 = Numero da opcao Selecionada					   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA080  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Rot(cAlias,nReg,nOpcx)

Local aSaveArea	:= GetArea()
Local aFields	:= {"RB7_FILIAL","RB7_MAT"}
Local aAlter	:= {}
Local aAvFields := {} //campos exibidos em tela a serem avaliados pelo gerenciamento de dados sensiveis
Local aPDFields := {} //campos que estao classificados como dados sensiveis
Local aOfuscaCpo:= { .F.,.F.,.F.,.F.,.F.,.F.,.F.,.F. }
Local oOk, oNo, o1Ok, o2Ok
Local oGroup
Local oDlgMain
Local nGrava	:= 2
Local nX		:= 0
Local nPos		:= 0
Local lTrDel	:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local lOk		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Private oGet, oSay1, oSay2, oSay3
Private oArq1Tmp, cSay, cSay2, cSay3
Private o1Lbx
Private nAuxSal	:=0
Private nPosAux :=0

Private aGets[0]
Private aTela[0][0]

Private aHeader	:= {}
Private aCols	:= {}
Private aGuarda := {}

// Variaveis da pergunte
Private cFilDe		:= ""
Private cFilAte		:= ""
Private cMatDe		:= ""
Private cMatAte		:= ""
Private cCCDe		:= ""
Private cCCAte		:= ""
Private cFuncaoDe	:= ""
Private cFuncaoAte	:= ""
Private nMostrar    := 0

Private aLbx		:= {}
Private nPosRec		:= 0		//Posicao do registro no Acols

// mv_par01		- Filial De
// mv_par02		- Filial Ate
// mv_par03		- Matricula de
// mv_par04		- Matricula ate
// mv_par05		- Centro Custo de
// mv_par06		- Centro Custo ate
// mv_par07		- Funcao de
// mv_par08		- Funcao ate
// mv_par09     - Mostrar por   (Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao)

Pergunte("CSA080",.F.)  // Trocar por CSA080

cFilDe		:= mv_par01
cFilAte     := mv_par02
cMatDe		:= mv_par03
cMatAte		:= mv_par04
cCCDe		:= mv_par05
cCCAte		:= mv_par06
cFuncaoDe	:= mv_par07
cFuncaoAte	:= mv_par08
nMostrar	:= mv_par09

oOk 	:= LoadBitmap( GetResources(), "Enable" )
oNo 	:= LoadBitmap( GetResources(), "LBNO" )
o1Ok 	:= LoadBitmap( GetResources(), "BR_VERDE" )
o2Ok	:= LoadBitmap( GetResources(), "BR_AMARELO" )

// Monta os dados dos ListBox e Getdados
Processa({||Cs080Monta(nOpcx,@lOk,aFields)},OemToAnsi(STR0005)+OemToAnsi(STR0006)) //"Aguarde..."###" Montando dados dos funcionarios"

If 	lOk

	PutFileInEof( "RB7" )

	// Verifica os campos criados pelo usuario
	Cs080Usuario(@aAlter)

	dbSelectArea("TR1")
	dbGotop()

	// Salvando dados do 1o funcionario
	aLbx:={}
	Aadd(aLbx,{TR1->TR1_FILIAL,TR1->TR1_MAT,TR1->TR1_NOME,TR1->TR1_CC,TR1->TR1_FUNCAO})

	// Monta o acols conforme o funcionario posicionado
	Cs080Troca(TR1->TR1_FILIAL,TR1->TR1_MAT,.T.)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 002 , 000 , .F. , .T. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords,  , .T.)

   	aAdv1Size		:= aClone(aObjSize[1])
	aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T., .T. } )
	aAdd( aObj1Coords , { 000 , 020 , .T. , .F. } )
	aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords )

	aAdv2Size		:= aClone(aObjSize[3])
	aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
	aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords )

	DEFINE MSDIALOG oDlgMain TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	  	//ListBox
		@ aObjSize[1,1],aObjSize[1,2] GROUP oGroup  TO aObjSize[1,3],aObjSize[1,4] OF oDlgMain PIXEL
		@ aObj1Size[1,1],aObj1Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS;
			 	 	HEADER 		"",;
								OemtoAnsi(STR0009),;			//"Fil."
								OemtoAnsi(STR0010),;			//"Nome"
								OemtoAnsi(STR0011),;			//"Matricula"
								OemtoAnsi(STR0012),;			//"Centro Custo"
								OemtoAnsi(STR0013),;			//"Descr. Centro Custo"
								OemtoAnsi(STR0014),;			//"Fun‡„o "
								OemtoAnsi(STR0015);				//"Descr. Fun‡„o"
					COLSIZES 	GetTextWidth(0, "W"),;
								GetTextWidth(0, Replicate("B", FWGETTAMFILIAL) ),;
								GetTextWidth(0, Replicate("B", GetSx3Cache("RA_NOME", "X3_TAMANHO")) ),;
								GetTextWidth(0, Replicate("B", GetSx3Cache("RA_MAT", "X3_TAMANHO"))),;
								GetTextWidth(0, Replicate("B", GetSx3Cache("RA_CC", "X3_TAMANHO")) ),;
								GetTextWidth(0, Replicate("B", GetSx3Cache("CTT_DESC01", "X3_TAMANHO"))),;
								GetTextWidth(0, Replicate("B", GetSx3Cache("RA_CODFUNC", "X3_TAMANHO")) ),;
								GetTextWidth(0, Replicate("B", GetSx3Cache("RJ_DESC", "X3_TAMANHO")) );
					SIZE aObj1Size[1,3],aObj1Size[1,4] OF oDlgMain PIXEL;
			ON CHANGE If(Cs080Ok(Nil,.T.),Cs080Troca(TR1->TR1_FILIAL,TR1->TR1_MAT,.F.),Cs080Posiciona(.T.))
			o1Lbx:bLine:= {||{	If(		TR1->TR1_AUMENT=1,o1Ok,If(TR1->TR1_AUMENT=3,o2Ok,oNo)),;
										TR1->TR1_FILIAL,;
										TR1->TR1_NOME,;
										TR1->TR1_MAT,;
										TR1->TR1_CC,;
										TR1->TR1_DESCCC,;
										TR1->TR1_FUNCAO,;
										TR1->TR1_DESCFUN}}
		//Tratamento de dados sensíveis
		If aOfusca[2] //Ofuscamento habilitado e usuário não possui acesso aos dados
			aAvFields := {"RA_NOME","RA_MAT","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
			aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList( aAvFields )
			o1Lbx:lObfuscate := .T.

			For nX := 1 to Len(aPDFields)
				nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
				If nPos == 1 //RA_NOME
					aOfuscaCpo[3] := .T.
				ElseIf nPos == 2 //RA_MAT
					aOfuscaCpo[4] := .T.
				ElseIf nPos == 3 //RA_CC
					aOfuscaCpo[5] := .T.
				ElseIf nPos == 4 //RA_DESCCC
					aOfuscaCpo[6] := .T.
				ElseIf nPos == 5 //RA_CODFUNC
					aOfuscaCpo[7] := .T.
				ElseIf nPos == 6 //RA_DESCFUN
					aOfuscaCpo[8] := .T.
				EndIf
			Next nX
			o1Lbx:aObfuscatedCols := aOfuscaCpo
		EndIf

		@  aObj1Size[2,1], aObj1Size[2,2] 		BITMAP NAME "BR_VERDE" SIZE 8,8 OF oDlgMain PIXEL NO BORDER
		@  aObj1Size[2,1] , aObj1Size[2,2]+20 	SAY STR0020 SIZE 100,7 OF oDlgMain PIXEL 	//"Aumento Atualizado"

		@  aObj1Size[2,1]+10, aObj1Size[2,2]	BITMAP NAME "BR_AMARELO" SIZE 8,8 OF oDlgMain PIXEL NO BORDER
		@  aObj1Size[2,1]+10, aObj1Size[2,2]+20	SAY STR0021	SIZE 100,7 OF oDlgMain PIXEL 	//"Aumento Nao Atualizado"

		// GetDados
		@ aObjSize[3,1],aObjSize[3,2] GROUP oGroup  TO aObjSize[3,3],aObjSize[3,4] OF oDlgMain PIXEL
		@ aObj2Size[1,1]+5, aObj2Size[1,2]+5  SAY STR0007 OF oDlgMain 			PIXEL	//"Nome: "
		@ aObj2Size[1,1]+5, aObj2Size[1,2]+30 SAY oSay1 PROMPT If(aOfuscaCpo[3], Replicate('*',15), cSay) OF oDlgMain PIXEL SIZE 100,7
		@ aObj2Size[1,1]+15,aObj2Size[1,2]+5  SAY STR0008 OF oDlgMain 			PIXEL	//"Salario: "
		@ aObj2Size[1,1]+15,aObj2Size[1,2]+30 SAY oSay2 PROMPT cSay2 OF oDlgMain PIXEL SIZE 100,7
		@ aObj2Size[1,1]+15,aObj2Size[1,2]+80  SAY STR0027 OF oDlgMain 			PIXEL	//"Data de Admissao: "
		@ aObj2Size[1,1]+15,aObj2Size[1,2]+130 SAY oSay3 PROMPT cSay3 OF oDlgMain PIXEL SIZE 100,7

		oGet := MSGetDados():New(aObj2Size[2,1],aObj2Size[2,2],aObj2Size[2,3],aObj2Size[2,4],nOpcx,"Cs080Ok","Cs080TOk","",lTrDel,aAlter,1, ,900,,,,,oDlgMain)

	ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||nGrava:=1,If( ( Obrigatorio( aGets , aTela ) .and. oGet:TudoOk() ) .and. Cs080Ok(Nil,.T.) ,oDlgMain:End(),) },	{|| nGrava := 2,oDlgMain:End()},,{})) //"Situacao do Funcionario"

	If 	nGrava == 1
		Begin Transaction
			Processa({||Cs080Grava()},OemToAnsi(STR0016)) //"Aguarde... Gravando dados"###"Atencao"
			EvalTrigger()
		End Transaction
	EndIf
Else
	Help("",1,"Cs080NOFUNC")	//Nao existem funcionarios selecionados. Verifique os parametros.
EndIf

dbSelectArea("TR1")
dbCloseArea()

If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf

RestArea(aSaveArea)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs080Perg ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada dos parametros no arotina                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Perg()
Pergunte("CSA080",.T.)		// Trocar por CSA080
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cs080Monta³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox com os dados dos funcionarios             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr090Monta(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC2 : Codigo do Curso                                    ³±±
±±³          ³ ExpC3 : Codigo da Turma                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA090       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Monta(nOpcx,lOk,aNoFields)

Local cDescCC	:= ""
Local cDescFunc	:= ""
Local cCateg	:= ""
Local cInicio	:= ""
Local cFim		:= ""
Local nAchou	:= 0
Local nI		:= 0
Local aFunc		:= {}

Local bSeekWhile	:= {|| RB7->RB7_FILIAL+RB7->RB7_MAT }
Local cSeekKey		:= ""
Local nRb7Ord		:= 1
Local bSeekFor		:= {|| Ascan(aFunc,{|X| MSGINFO(X[1]),X[1]==RB7->RB7_FILIAL+RB7->RB7_MAT})>0}
Local cFilAux		:= ""
Local cMatAux		:= ""
Local aHeaderAux	:={}
Local aColsAux		:={}

Private nPosRec		:= 0


// Cria arquivos temporarios para o Listbox
Cs080CriaArq()

dbSelectArea("SRA")
dbSetOrder(1)
dbSeek(cFilDe + cMatDe,.T.)
cInicio := "SRA->RA_FILIAL+SRA->RA_MAT"
cFim	:= cFilAte + cMatAte

ProcRegua(SRA->(Reccount()))

While !Eof() .And. &cInicio <= cFim

	aHeaderAux	:={}
	aColsAux	:={}
	nAchou		:= 2

	IncProc()
	If 	SRA->RA_MAT 	< cMatDe 	.Or.;
		SRA->RA_MAT 	> cMatAte 	.Or.;
		SRA->RA_SITFOLH == "D" 	.Or.;
	   	SRA->RA_CC 		< cCCDe		.Or.;
		SRA->RA_CC 		> cCCAte	.Or.;
		SRA->RA_CODFUNC	< cFuncaoDe .Or.;
		SRA->RA_CODFUNC	> cFuncaoAte
		SRA->(dbSkip())
		Loop
	EndIf

	If !( SRA->RA_FILIAL $ fValidFil() )
	    SRA->(dbSkip())
	   	Loop
	EndIf

	// Montando o ListBox 1
	cDescCC		:= FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
	cDescFunc	:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)
	cCateg	    := FDesc("X28","28"+SRA->RA_CATFUNC,fDescSX5(2),20)
	lOk := .T.

	RecLock("TR1",.T.)
	TR1->TR1_FILIAL		:=	SRA->RA_FILIAL
	TR1->TR1_NOME		:=	SRA->RA_NOME
	TR1->TR1_MAT		:=	SRA->RA_MAT
	TR1->TR1_CC			:=	SRA->RA_CC
	TR1->TR1_DESCCC		:=	cDescCC
	TR1->TR1_FUNCAO		:=	SRA->RA_CODFUNC
	TR1->TR1_DESCFUN	:=	cDescFunc
	TR1->TR1_CATEG		:= SRA->RA_CATFUNC
	TR1->TR1_DCATEG		:= cCateg
 	TR1->TR1_SALARI		:= Round( SRA->RA_SALARIO, MsDecimais(1))
	TR1->TR1_AUMENT		:= 2  //Default = Nao atualizado
	TR1->TR1_ADMISS		:= SRA->RA_ADMISSA
	MsUnlock()

	cSeekKey:=SRA->RA_FILIAL+SRA->RA_MAT

	//==> Cria aHeader e aCols para WalkThru
	FillGetDados(4						,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 "RB7"					,; //2-cAlias - area a ser utilizada;
				 nRb7Ord				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 NIL					,; //12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
				 aHeaderAux				,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				 aColsAux				)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

	If Len(aHeader)=0
		aHeader	:= aClone(aHeaderAux)
	EndIf
	Aadd(aGuarda,{SRA->RA_FILIAL,SRA->RA_MAT,aClone( aColsAux )})

	//==> Atualiza status de aumento no Funcionario
	If GdFieldGet("RB7_ATUALI",Len(aColsAux),,,aColsAux)=="S"	//Se o aumento estiver atualizado, acerta status do Funcionario
		nAchou := 1
	ElseIf !Empty(GdFieldGet("RB7_TPALT",Len(aColsAux),,,aColsAux))
		nAchou := 3
	EndIf

	RecLock("TR1",.F.)
	TR1->TR1_AUMENT		:= nAchou  //Considera o status do ultimo aumento do Funcionario
	MsUnlock()
	dbSelectArea("SRA")
	dbSkip()
EndDo

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs080CriaArq³ Autor ³ Cristina Ogura      ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo para gravar os dados do listbox                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs080CriaArq                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080CriaArq()
Local a1Stru:= {}
Local cCond	:= ""
Local aLstIndices := {}
Aadd(a1Stru,{"TR1_AUMENT"	,"N", 1,                       0})
Aadd(a1Stru,{"TR1_FILIAL"	,"C", FWGETTAMFILIAL,          0})
Aadd(a1Stru,{"TR1_NOME"		,"C", TamSX3("RA_NOME")[1],    TamSX3("RA_NOME")[2]})
Aadd(a1Stru,{"TR1_MAT"		,"C", TamSX3("RA_MAT")[1],     TamSX3("RA_MAT")[2]})
Aadd(a1Stru,{"TR1_CC"		,"C", TamSX3("RA_CC")[1],      TamSX3("RA_CC")[2]})
Aadd(a1Stru,{"TR1_DESCCC"	,"C", TamSX3("CTT_DESC01")[1], TamSX3("CTT_DESC01")[2]})
Aadd(a1Stru,{"TR1_FUNCAO"	,"C", TamSX3("RA_CODFUNC")[1], TamSX3("RA_CODFUNC")[2]})
Aadd(a1Stru,{"TR1_DESCFU"	,"C", TamSX3("RJ_DESC")[1],    TamSX3("RJ_DESC")[2]})
Aadd(a1Stru,{"TR1_SALARI"	,"N", TamSX3("RA_SALARIO")[1], TamSX3("RA_SALARIO")[2]})
Aadd(a1Stru,{"TR1_CATEG"	,"C", TamSX3("RA_CATFUNC")[1], TamSX3("RA_CATFUNC")[2]})
Aadd(a1Stru,{"TR1_DCATEG"	,"C", 20,                      0})
Aadd(a1Stru,{"TR1_ADMISS"	,"D", TamSX3("RA_ADMISSA")[1], TamSX3("RA_ADMISSA")[2]})



//Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
If nMostrar == 1				// Nome
	AAdd( aLstIndices, {"TR1_FILIAL","TR1_NOME","TR1_MAT"})
ElseIf nMostrar == 2			// Matricula
	AAdd( aLstIndices, {"TR1_FILIAL","TR1_MAT"})
ElseIf nMostrar == 3			// Centro de Custo
	AAdd( aLstIndices, {"TR1_FILIAL","TR1_CC","TR1_MAT"})
ElseIf nMostrar == 4			// Funcao
	AAdd( aLstIndices, {"TR1_FILIAL","TR1_FUNCAO","TR1_MAT"})
EndIf

oArq1Tmp := RhCriaTrab('TR1', a1Stru, aLstIndices)


Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs080Troca³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que troca o acols conforme a posicao do funcionario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Troca(cAuxFil,cMat,l1Vez)
Local nPos	:= 0

If !l1Vez .And. nPosAux > 0
	aGuarda[nPosAux][3] := aClone( aCols )
EndIf

cSay 	:= TR1->TR1_NOME
cSay2	:= Transform(TR1->TR1_SALARI,"@E 999,999,999.99")
cSay3    := DtoC(TR1->TR1_ADMISS)
nAuxSal	:= TR1->TR1_SALARI
nPos	:= Ascan(aGuarda,{|x| x[1]+x[2]== cAuxFil+cMat })

If nPos > 0
	aCols 	:= {}
	aCols 	:= aClone( aGuarda[nPos][3] )
	n		:= 1
EndIf

If !l1Vez
	aLbx := {}
	Aadd(aLbx,{TR1->TR1_FILIAL,TR1->TR1_MAT,TR1->TR1_NOME,TR1->TR1_CC,TR1->TR1_FUNCAO})
	oGet:ForceRefresh()
	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
EndIf

nPosAux := nPos

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs080Desc ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de retorno da descricao dos campos no SX3            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Desc(nQual)

Local cVar	:= &(ReadVar())
Local nPos	:= 0
Local nPos1	:= 0
Local nPos2	:= 0

If 	 !Cs080Atua()
	Return .F.
EndIf

If 	nQual == 1			//Descricao do Tipo de alteracao
	nPos	:= GdFieldPos("RB7_DTPALT")
	nPos1	:= GdFieldPos("RB7_DCATEG")
	nPos2	:= GdFieldPos("RB7_CATEG")
	If nPos1 > 0 .And. nPos2 > 0
		aCols[n][nPos1] := TR1->TR1_DCATEG
		aCols[n][nPos2] := TR1->TR1_CATEG
	EndIf
	If nPos > 0
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"41"+cVar)
			aCols[n][nPos] := Substr(fDescSX5(1),1,20)
		Else
			aCols[n][nPos] := STR0019			//"Nao cadastrado"
		EndIf
	EndIf
ElseIf nQual == 2		//Descricao da Funcao
	nPos	:= GdFieldPos("RB7_DESCFU")
	nPos1	:= GdFieldPos("RB7_SALARI")
	nPos2	:= GdFieldPos("RB7_CARGO")
	dbSelectArea("SRJ")
	dbSetOrder(1)
	If dbSeek(xFilial("SRJ")+cVar)
		aCols[n][nPos]	:= Substr(SRJ->RJ_DESC,1,20)
		aCols[n][nPos1]:= SRJ->RJ_SALARIO
		aCols[n][nPos2]:= SRJ->RJ_CARGO
	Else
		aCols[n][nPos]	:= STR0019		//"Nao cadastrado"
		aCols[n][nPos1]:= 0
	EndIf
ElseIf nQual == 3		//Descricao da Categoria
	nPos:= GdFieldPos("RB7_DCATEG")
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"28"+cVar)
		aCols[n][nPos] := Substr(fDescSX5(1),1,20)
	Else
		aCols[n][nPos] := STR0019	//"Nao cadastrado"
	EndIf
ElseIf nQual == 4		//Descricao do Cargo
	nPos:= GdFieldPos("RB7_DESCAR")
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cVar+TR1->TR1_CC)
		aCols[n][nPos]	:= Substr(SQ3->Q3_DESCSUM,1,20)
	ElseIf dbSeek(xFilial("SQ3")+cVar)
		aCols[n][nPos]	:= Substr(SQ3->Q3_DESCSUM,1,20)
	Else
		aCols[n][nPos]	:= STR0019		//"Nao cadastrado"
	EndIf
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs080Grava ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza os arquivos SQV.                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs080Grava()     				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA080   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Grava()

Local aColsAux		:= {}
Local cCampo		:= ""
Local xConteudo
Local nPos			:= 0
Local nx       		:= 0
Local nY			:= 0
Local nt        	:= 0
Local nPosTp		:= GdFieldPos("RB7_TPALT")
Local nPosRec		:= GdfieldPos("RB7_REC_WT")
Local aCols1		:= {}//variavel para PE CSA08001
Local lCSA0801Block := ExistBlock( "CSA08001" )//variavel para PE CSA08001

dbSelectArea("TR1")
dbGotop()
ProcRegua(TR1->(Reccount()))
While !Eof()

	IncProc()

	aRB7		:= {}
	aColsAux	:= {}
	nPos		:= Ascan(aGuarda,{|x| x[1]+x[2]== TR1->TR1_FILIAL+TR1->TR1_MAT })

	If 	nPos < 0
		dbSkip()
		Loop
	EndIf

	aGuarda[nPosAux][3] := aClone( aCols )

	aColsAux := aClone( aGuarda[nPos][3] )

	dbSelectArea("RB7")
	For nX :=1 to Len(aColsAux)
	    Begin Transaction
			If !Empty(aColsAux[nx][nPosTp])
				If aColsAux[nx][nPosRec]>0
					MsGoto(aColsAux[nX][nPosRec])
					RecLock("RB7",.F.)
					lTravou:=.T.
				Else
				    If !(aColsAux[nX][Len(aColsAux[nX])])
						RecLock("RB7",.T.)
						lTravou:=.T.
					EndIf
				EndIf
				If lTravou
					//--Verifica se esta deletado
					If aColsAux[nX][Len(aColsAux[nX])]
						dbDelete()
			        Else
						RB7->RB7_FILIAL := TR1->TR1_FILIAL
						RB7->RB7_MAT    := TR1->TR1_MAT
					EndIf
					For nY := 1 To Len(aHeader)
						If aHeader[nY][10] <> "V"
							RB7->(FieldPut(FieldPos(aHeader[nY][2]),aColsAux[nX][nY]))
						EndIf
					Next nY
					aAdd ( aCols1, aGuarda[nPos] )//adicao das informacoes de aumento para array auxiliar de PE
					MsUnlock()
				EndIf
			EndIf
		End Transaction
	Next nx

	dbSelectArea("TR1")
	dbSkip()
EndDo

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Ponto de Entrada Aumento Programado                		   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ( lCSA0801Block )
	ExecBlock( "CSA08001",.F.,.F.,{aHeader, aCols1} )
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs080Ok  ³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs080Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA080  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Ok(oObj,lListbox)

Local nPosData	:= GdFieldPos("RB7_DATALT")
Local nPosTipo	:= GdFieldPos("RB7_TPALT")
Local nPosFunc	:= GdFieldPos("RB7_FUNCAO")
Local nPosCateg	:= GdFieldPos("RB7_CATEG")
Local nPosSal   := GdFieldPos("RB7_SALARI")
Local nPosAtua	:= GdFieldPos("RB7_ATUALI")
Local lRet 		:= .T.
Local nx		:= 0

DEFAULT lListbox := .F.

// Nao posso deletar o aumento que ja foi atualizado
If 	nPosAtua > 0 .And. aCols[n][nPosAtua] == "S" .And. aCols[n,Len(aCols[n])]
	Help("",1,"Cs080Atua")
	Return .F.
EndIf

If !aCols[n,Len(aCols[n])]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se todos os campos obrigatorios estao preenchidos        	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosData > 0 .And. nPosTipo > 0 .And. nPosFunc > 0 .And. nPosCateg > 0 .And. nPosCateg > 0
		If	Empty(aCols[n][nPosData]) .And.;
			Empty(aCols[n][nPosTipo]) .And.;
			Empty(aCols[n][nPosFunc]) .And.;
			Empty(aCols[n][nPosCateg]).And.;
			Empty(aCols[n][nPosSal])
			Return .T. //ou seja, possibilita o Usuario mudar de campo
		Else
			If Empty(aCols[n][nPosData]) .Or. Empty(aCols[n][nPosTipo])
				Help("",1,"Cs080DTTP")			// Falta digitar o campo de data alteracao e tipo alteracao
				lRet := .F.
	      EndIf

	      If lRet .And. (Empty(aCols[n][nPosFunc]) .Or. Empty(aCols[n][nPosCateg]))
				Help("",1,"Cs080AUMENT")		// Para aumento salarial deve ser digitado a funcao ou categoria
				lRet := .F.
	      EndIf

	      If lRet .And. Empty(aCols[n][nPosSal])
	      	Help("",1,"Cs080SALARIO")		// Falta digitar o valor do salario novo
				lRet := .F.
			Endif
		EndIf
	EndIf

	If lRet
		// Verificando SALARIO NOVO nunca pode ser menor que o ATUAL
		// Se nao foi atualizado ainda.
		If 	aCols[n][nPosSal] < nAuxSal .And.;
			aCols[n][nPosAtua] != "S"
			Help("",1,"Cs080VALSAL")		// Salario novo esta menor que salario atual
			lRet:= .F.
		EndIf

		If lRet
			For nx := 1 To Len(aCols)
				//Nao permite inclusao qdo mesmo tipo de aumento salarial e mesma data
				If (aCols[n][nPosData]) == (aCols[nx][nPosData]) .And.;
					(aCols[n][nPosTipo])==(aCols[nx][nPosTipo]).And.;
					!aCols[nx][Len(aCols[nx])] .And. n != nx
					AVISO(OemToAnsi(STR0017),OemToAnsi(STR0024),{"Ok"}) //"Atencao"#"Nao deve-se programar aumento para funcionario numa mesma data para o mesmo tipo de alteracao salarial"
					lRet := .F.
					Exit
				EndIf

				If aCols[n][nPosSal]  == aCols[nx][nPosSal] .And.;
					aCols[n][nPosFunc] == aCols[nx][nPosFunc].And.;
					aCols[n][nPosCateg]== aCols[nx][nPosCateg] .And.;
					!aCols[nx][Len(aCols[nx])] .And.;
					nx != n
					Help("",1,"Cs080IGUAL")	// Programacao de aumento estao iguais ao atual do funcionariro.
					lRet := .F.
   					Exit
    			EndIf
			Next nx
		EndIf
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs080TOK ³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida toda a getdados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080RsTOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ CSAA080  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080TOk()

Local nPosData	:= GdFieldPos("RB7_DATALT")
Local nPosTipo	:= GdFieldPos("RB7_TPALT")
Local nPosFunc	:= GdFieldPos("RB7_FUNCAO")
Local nPosCateg	:= GdFieldPos("RB7_CATEG")
Local nx        := 0

If !aCols[n,Len(aCols[n])]
	If nPosData >0 .And. Empty(aCols[n][nPosData])
		Help("",1,"Cs080DATA")			// Falta digitar o data de alteracao do aumento
		Return .F.
	ElseIf nPosTipo >0 .And. Empty(aCols[n][nPosTipo])
		Help("",1,"Cs080DGRAU")			// Falta digitar o tipo de alteracao do aumento
		Return .F.
	ElseIf 	nPosFunc >0 .And. 	Empty(aCols[n][nPosFunc]) .And.;
			nPosCateg >0 .And. 	Empty(aCols[n][nPosCateg])
			Help("",1,"Cs080AUMENT")	// Para aumento salarial deve ser digitado a funcao ou categoria
			Return .F.
	EndIf

	For nx := 1 To Len(aCols)
		//Nao permite inclusao qdo mesmo tipo de aumento salarial e mesma data
		If (aCols[n][nPosData]) == (aCols[nx][nPosData]) .And.;
			(aCols[n][nPosTipo])==(aCols[nx][nPosTipo]).And.;
			!aCols[nx][Len(aCols[nx])] .And. n != nx
			AVISO(OemToAnsi(STR0017),OemToAnsi(STR0024),{"Ok"}) //"Atencao"#"Nao deve-se programar aumento para funcionario numa mesma data para o mesmo tipo de alteracao salarial"
			lRet := .F.
			Exit
		EndIf
	Next nx
EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs080aCols³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o acols da getdados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs080aCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA080   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080aCols(nOpcx,cChave,nAchou)

Local nCntFor := 0
Local nUsado  := Len(aHeader)
Local nAcols  := 0
Local aAuxCols:= {}

nAchou	:= 2
aAuxCols:= {}
dbSelectArea("RB7")
If dbSeek(cCHAVE)
	While !Eof() .And. RB7->RB7_FILIAL+RB7_MAT == cChave
		nAchou := 3
		Aadd(aAuxCols,Array(nUsado+If(nOpcx != 2 .And. nOpcx != 5,1,0)))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aHeader)
			If 	aHeader[nCntFor][10] != "V"
				aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf
			If 	RB7->RB7_ATUALIZ = "S"
				nAchou := 1
			EndIf
		Next nCntFor
		If nOpcx != 2 .And. nOpcx != 5
			aAuxCols[nAcols][nUsado+1] := .F.
		EndIf
		dbSelectArea("RB7")
		dbSkip()
	EndDo
Else
	dbSelectArea("SX3")
	dbSeek("RB7")
	Aadd(aAuxCols,Array(nUsado+If(nOpcx != 2 .And. nOpcx != 5,1,0)))
	nAcols := Len(aAuxCols)
	nAchou := 2
	For nCntFor := 1 To Len(aHeader)
		aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
	Next nCntFor
	If nOpcx != 2 .And. nOpcx != 5
		aAuxCols[1][nUsado+1] := .F.
	EndIf
EndIf

Aadd(aGuarda,{SRA->RA_FILIAL,SRA->RA_MAT,aAuxCols})

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs080Usuar ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica no SX3 se o usuario criou algum campo		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs080Usuar(aAlter)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Array com os campos       			 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Usuario(aAlter)
Local aSaveArea	:= GetArea()

Aadd(aAlter,"RB7_DATALT")
Aadd(aAlter,"RB7_TPALT")
Aadd(aAlter,"RB7_FUNCAO")
Aadd(aAlter,"RB7_CATEG")
Aadd(aAlter,"RB7_PERCEN")
Aadd(aAlter,"RB7_SALARI")
Aadd(aAlter,"RB7_CARGO")

dbSelectArea("SX3")
dbSeek("RB7")
While !Eof() .And. (X3_ARQUIVO == "RB7")
	If X3_PROPRI == "U"
		Aadd(aAlter,X3_CAMPO)
	EndIf
	dbSkip()
EndDo

RestArea(aSaveArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs080Atua  ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a linha do acols ja foi atualizada.		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs080Atua()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA060   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Atua()
Local nPosAtua	:= GdFieldPos("RB7_ATUALI")

If 	aCols[n][nPosAtua] = "S"
	Help("",1,"Cs080Atua")		// Esses dados nao podem ser alterados pois ja foi aplicado este aumento
	Return .F.
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fValidDta  ³ Autor ³ Raquel Hager         ³ Data ³ 28.03.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se a data da alteracao e anterior a data de admissao.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fValidDta(M->RB7_DATALT)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Cpo RB7_DATALT  											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fValidDta(cData)
Local aArea := GetArea()
Local lRet    := .T.

dbSelectArea("SRA")
dbSetOrder(1)
If dbSeek(aLbx[1][1]+aLbx[1][2])
	If (SRA->RA_ADMISSA > cData)
		lRet := .F.
		MsgAlert(OemToAnsi(STR0026))  // Data de Alteracao nao pode ser inferior a Data de Admissao do funcionario
	EndIf
EndIf

RestArea(aArea)
Return ( lRet )

Function Cs080Posiciona(lRet)
Local cLbx

If nMostrar == 1				// "TR1_FILIAL+TR1_NOME+TR1_MAT"
	cLbx:= aLbx[1][1]+aLbx[1][3]+aLbx[1][2]
ElseIf nMostrar == 2			// "TR1_FILIAL+TR1_MAT"
	cLbx:= aLbx[1][1]+aLbx[1][2]
ElseIf nMostrar == 3			// "TR1_FILIAL+TR1_CC+TR1_MAT"
	cLbx:= aLbx[1][1]+aLbx[1][4]+aLbx[1][2]
ElseIf nMostrar == 4			// "TR1_FILIAL+TR1_FUNCAO+TR1_MAT"
	cLbx:= aLbx[1][1]+aLbx[1][5]+aLbx[1][2]
EndIf

If lRet
	dbSelectarea("TR1")
	dbSetOrder(1)
	If	dbSeek(cLbx)
		o1Lbx:Refresh()
		oGet:ForceRefresh()
		oSay1:Refresh()
		oSay2:Refresh()
		oSay3:Refresh()		
	EndIf
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CS080SX7   ³ Autor ³ Eduardo Ju           ³ Data ³ 24.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Valor do Salario atraves do percentual informado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA080                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CS080SX7()

Local nSalAtu	:= 0
Local nPosAtua	:= GdFieldPos("RB7_ATUALI")
Local nPosSal  	:= GdFieldPos("RB7_SALARI")

If !Empty("RB7_PERCEN")
	If n == 1 .Or. (n > 1 .And. aCols[n-1][nPosAtua] == "S")
		nSalAtu		:= nAuxSal+(nAuxSal*((RB7_PERCEN)/100))
	Else
		nSalAtu := aCols[n-1][nPosSal]+(aCols[n-1][nPosSal]*((RB7_PERCEN)/100))
	EndIf
	RB7_SALARI	:= Round( nSalAtu, MsDecimais(1))
EndIf

Return(RB7_SALARI)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA080                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina :=  {	{ STR0001,"PesqBrw"		, 0, 1,,.F.},; 		//"Pesquisa"
						{ STR0002,'Cs080Perg'	, 0, 4},;		//"Para&metros"  --foi alterado de 3 para 4 pois quando no browser é usado a opção de incluir(3) ele automaticamente tira o Superfiltro, permitindo um usuario filtrado ver toda a SRA.
                    	{ STR0003,"Cs080Rot"	, 0, 4},; 		//"Prog. &Aumento" --foi alterado de 3 para 4 pois quando no browser é usado a opção de incluir(3) ele automaticamente tira o Superfiltro, carregando todo os usuarios para aumento programado.
						{ STR0022,'CSAM080'		, 0, 4},;	    //"Reajuste"--foi alterado de 3 para 4 pois quando no browser é usado a opção de incluir(3) ele automaticamente tira o Superfiltro, permitindo reajustar o salario de todos os funcionarios
						{ STR0023,'CSAR050'	    , 0, 4},;     	//Imprimir --foi alterado de 3 para 4 pois quando no browser é usado a opção de incluir(3) ele automaticamente tira o Superfiltro, permitindo imprimir todos funcionarios
  						{ STR0025,'gpLegend'    , 0, 5,,.F.}}	//"Legenda"


Return aRotina
