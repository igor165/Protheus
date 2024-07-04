#INCLUDE "CTBA160.CH"
#INCLUDE "PROTHEUS.CH"

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static __Release  :=  Iif(GetRPORelease() >= "12.1.2210", .T., .F.)  
Static __lCOLUN2   // indica se a coluna CTS_COLUN2 existe
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA160  ³ Autor ³ Felipe Aurelio de Melo³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastramento Plano Gerencial - SIGACTB                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA160()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA160()

Local cPerg       	:= "CTB160"
Private aRotina   	:= MenuDef()
Private cCadastro 	:= STR0006
Private lTrvNome  	:= .T.
Private aCVzo		:= {}
Private cAliasBrw	:= ""

// Acesso somente pelo SIGACTB
If !AMIIn(34) ; Return ; EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01		// Incrementa na inclusao de n em n         ³
//³ mv_par02		// "Gera Cod Entidade ?                     ³
//³ mv_par03		// "Formula Cod Entidade ?                  ³
//³ mv_par04		// "Formatar Cod Entidade ?                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ctb160IniVar()
SetKey( VK_F12, { |a,b| AcessaPerg( cPerg, .T. ) } )
Pergunte(cPerg,.F.)

cAliasBrw := IIf( MV_PAR06 == 2, "CVE", "CTS" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1, 22, 75, cAliasBrw )

dbSetOrder(1)
SET KEY VK_F12 to

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Felipe Aurelio de Melo³ Data ³09/10/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com opcoes da rotina.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aCT160BUT := {}
	Local nX
	Local aRotina 	:= { 	{ STR0001, "AxPesqui"				, 0 , 1},;  // // //"Pesquisar"
							{ STR0002, "Ctb160Cad( ,, 2, .F. )"	, 0 , 2},;  // // //"Visualizar"
							{ STR0003, "Ctb160Cad( ,, 3, .F. )"	, 0 , 3},;  // // //"Incluir"
							{ STR0004, "Ctb160Cad( ,, 4, .F. )"	, 0 , 4},;  // // //"Alterar"
							{ STR0025, "Ctb160Alt"				, 0 , 4},;  // // //"Alterar Cadastro"
							{ STR0024, "Ctb160Imp"				, 0 , 3},;  // // //"Imp. Estrutura"
							{ STR0023, "Ctb160Exp"				, 0 , 4},;  // // //"Exp. Estrutura"
							{ STR0005, "Ctb160Exc"				, 0 , 5} }  // // //"Excluir"
	If ExistBlock( "CT160BUT" )
		aCT160BUT := ExecBlock( "CT160BUT",.F.,.F.,aRotina)
		IF ValType(aCT160BUT) == "A" .AND. Len(aCT160BUT) > 0
			For nX := 1 To Len(aCT160BUT)
				aAdd(aRotina,aCT160BUT[nX])
			Next
		EndIf
	EndIf
							

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB160CAD ³ Autor ³ Felipe Aurelio de Melo³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe na tela enchoice e a getdados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Cad(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA160                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb160Cad(cAlias,nReg,nOpc, lUsaCad )
Local aCmpAdic		:= {}
Local nInc			:= 0

// Declaração das variaveis
Private oDlg,oEnch,oPanel,oScroll
Private oGet01,oGet02,oGet03,oGet04
Private lNegrito, lTotal, lSeparador, lTraco
Private lVldNegrito,lVldTotal,lVldSeparador,lVldTraco
Private oGDItens
Private nCtrlGet  	:= 1
Private aGets     	:= {} 
Private aTela     	:= {}
Private aButtons  	:= {}
Private nOpcao		:= 0
Private bOk       	:= { || IIf(  Ctb160TOk() , (nOpcao:=1,oDlg:End()) , nOpcao := 0) }
Private bCancel   	:= { || nOpcao:=0 , oDlg:End() }
Private nSuperior 	:= 0
Private nEsquerda 	:= 0
Private nInferior 	:= 0
Private nDireita  	:= 0
Private aSizeAut  	:= {}
Private aObjects  	:= {}
Private aInfo     	:= {}
Private aPosGet   	:= {}
Private aPosObj   	:= {}
Private aCT1Blq		:= {}
Private cIdent

Default lUsaCad		:= .T.

If __lCOLUN2 == NIL
	__lCOLUN2 :=  Iif(CTS->(FieldPos("CTS_COLUN2")) > 0, .T., .F.)
Endif
Ctb161Pos()

If nOpc != 3
	cIdent		:= CTS->CTS_IDENT
Else
	cIdent		:= CriaVar("CTS_IDENT",.T.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a forma de exibicao da visao gerencial.³
//³Modo tradicional ou arvore.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR06 == 2 .AND. !lUsaCad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³posiciona no CVE correspondente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		Ctb161Inc()
		Return
	Else
		If nOpc == 2					// Visuaizar
			Ctb161Cad( cAlias, nReg, nOpc )
			Return
		ElseIf nOpc == 4				// Alterar
			Ctb161Cad( cAlias, nReg, nOpc )
			Return
		EndIf
	EndIf
EndIf

nReg   := IIf(nOpc==3,Nil,CTS->(Recno()))
cAlias := "CTS"

// Maximizacao da tela em relação a area de trabalho
aSizeAut := MsAdvSize()
//aAdd(aObjects,{080,100,.T.,.T.})
//aAdd(aObjects,{020,100,.T.,.T.})
aAdd(aObjects,{100,083,.T.,.F.})
aAdd(aObjects,{100,100,.T.,.T.})

aInfo     := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj   := MsObjSize(aInfo,aObjects)

//Ajusta para ter mais um array com divisoes da dimenssao da tela
aAdd(aPosObj,{aPosObj[1,1],aPosObj[1,4]*0.7+3,aPosObj[1,3]-15,(aPosObj[1,4]*0.3)-3})
aPosObj[1,4]:=aPosObj[1,4]*0.7

// Verifica o tipo de chamada e trata a situação
If __Release  .and. __lCOLUN2 //Release 12.1.2210 - Sem tratativa do prime
	cExbCpos := "CTS_CODPLA/CTS_ORDEM/CTS_CONTAG/CTS_CTASUP/CTS_CLASSE/CTS_NORMAL/CTS_DESCCG/CTS_DETHCG/CTS_COLUN2/CTS_NOME"
Else
	cExbCpos := "CTS_CODPLA/CTS_ORDEM/CTS_CONTAG/CTS_CTASUP/CTS_CLASSE/CTS_NORMAL/CTS_DESCCG/CTS_DETHCG/CTS_COLUNA/CTS_NOME"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui os campos adicionais se os mesmos existirem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aCmpAdic, "CTS_TOTVIS" )
aAdd( aCmpAdic, "CTS_VISENT" )
aAdd( aCmpAdic, "CTS_FATSLD" )

For nInc := 1 To Len( aCmpAdic )
	cExbCpos += "/" + aCmpAdic[nInc]
Next

Do Case
	Case nOpc == 2	//Visualização
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
		
	Case nOpc == 3	//Inclusão
		nOpEnch:= 3
		aExbCpo:= fInitVarX3(cAlias,.T.,cExbCpos)
		
	Case nOpc == 4	//Alteração
		nOpEnch:= 3
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
		
	Case nOpc == 5	//Exclusão
		nOpEnch:= 5
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
		
	Otherwise //Outras situações
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cExbCpos)
EndCase

// Montagem da tela que serah apresentada para usuario (lay-out)
Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel

/*Cabeçalho		*/	oEnch := Msmget():New(cAlias,nReg,nOpEnch,,,,aExbCpo,aPosObj[1],aExbCpo,,,,,oDlg,,.T.)
/*CheckBox		*/	fChekBox(nOpc,oDlg,nReg)
/*Itens			*/ fGDItens(nOpc,oDlg,nReg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

Do Case
   //Se for inclusao e foi confirmado
   Case nOpc == 3 .And. nOpcao == 1
        fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)
   //Se for alteracao e foi confirmado
   Case nOpc == 4 .And. nOpcao == 1
        fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)

   //Se for exclusao e foi confirmado
   Case nOpc == 5 .And. nOpcao == 1
        fExcluiTudo()
EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fChekBox     ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Panel com checkbox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fChekBox()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fChekBox(nOpc,oDefTela,nReg)

@ aPosObj[3,1], aPosObj[3,2] MSPANEL oPanel SIZE aPosObj[3,4], aPosObj[3,3] Of oDlg
@ 000,000 SCROLLBOX oScroll SIZE 010,010 Pixel Of oPanel
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

//Inicializa variaveis do checkbox
CT160VlCkBx(1, nOpc)   //fVldCkBx(1,nOpc)

//se for analitica nao deve permitir alterar o check
If M->CTS_CLASSE == "2"
	lVldNegrito   := .F.
	lVldTotal     := .F.
	lVldSeparador := .F.
	lVldTraco     := .F.
EndIf

@ 09,15 Say STR0020 Size 050,009 COLOR CLR_HBLUE Of oScroll Pixel //"Identificadores"
@ 25,15 CHECKBOX oGet01 VAR lNegrito   Size 050,009 PROMPT STR0016 When (lVldNegrito  ) On Change(CT160VlCkBx(2,nOpc)) Of oScroll //"Negrito" 
@ 36,15 CHECKBOX oGet02 VAR lTotal     Size 050,009 PROMPT STR0017 When (lVldTotal    ) On Change(CT160VlCkBx(2,nOpc)) Of oScroll //"Total Geral"
@ 47,15 CHECKBOX oGet03 VAR lSeparador Size 050,009 PROMPT STR0018 When (lVldSeparador) On Change(CT160VlCkBx(2,nOpc)) Of oScroll //"Linha sem Valor"
@ 58,15 CHECKBOX oGet04 VAR lTraco     Size 050,009 PROMPT STR0019 When (lVldTraco    ) On Change(CT160VlCkBx(2,nOpc)) Of oScroll //"Separador"
//oGet01 := TCheckBox():New(20,15,STR0016,bSETGET(lNegrito  ),oScroll,050,009,,,,,,,,.T.)
//oGet02 := TCheckBox():New(31,15,STR0017,bSETGET(lTotal    ),oScroll,050,009,,,,,,,,.T.)
//oGet03 := TCheckBox():New(42,15,STR0018,bSETGET(lSeparador),oScroll,050,009,,,,,,,,.T.)
//oGet04 := TCheckBox():New(53,15,STR0019,bSETGET(lTraco    ),oScroll,050,009,,,,,,,,.T.)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGDItens     ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta MsNewGetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGDItens()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGDItens(nOpc,oDefTela,nReg)

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local cGetOpc        := GD_INSERT+GD_DELETE+GD_UPDATE    // GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinhaOk       := "Ctb160LOk"                     // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk        := "Ctb160GOk"                     // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos       := "+CTS_LINHA"                     // Nome dos campos do tipo caracter que utilizarao incremento automatico.                                                              
Local nFreeze        := Nil                              // Campos estaticos na GetDados.                                                               
Local nMax           := 35657                            // Numero maximo de linhas permitidas.                            
Local cCampoOk       := Nil                              // Funcao executada na validacao do campo                                           
Local cSuperApagar   := Nil                              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk       := Nil                              // Funcao executada para validar a exclusao de uma linha do aCols                   
Local aHead          := {}                               // Array do aHeader
Local aCols          := {}                               // Array do aCols

// Valor das variaveis que as rotinas faCols e faHead irá utilizar como referencia
Local x       := 1                                       //Variavel usada no For/Next
Local cGetAls := "CTS"                                   //Alias usado na função para montar o aHeader e o Acols
Local nGetOpc := nOpc                                    //Opção da operação que está sendo executada
Local cGetOrd := 1                                       //Ordem do Indice utilizado na função que carrega o aCols
Local nGetQtd := 1                                       //Quantidade de linhas iniciadas no aCols quando inclusão
Local cGetCnd := "xFilial('CTS')+M->CTS_CODPLA+M->CTS_ORDEM"
Local cGetCpo := "CTS->CTS_FILIAL+CTS->CTS_CODPLA+CTS->CTS_ORDEM"
Local cExbCpo := "CTS_LINHA/CTS_CT1INI/CTS_CT1FIM/CTS_CTTINI/CTS_CTTFIM/CTS_CTDINI/CTS_CTDFIM/CTS_CTHINI/CTS_CTHFIM/CTS_IDENTI/CTS_FORMUL/CTS_TPSALD" //Forçar mostrar no MsNewGetDados apenas os campos definidos nesta variavel
Local aTrtCpo := {}                                      //Array contendo campos com valores que serão usadas no aCols quando inclusão
Local aAuxHead		:= {}
Local cAuxExbCpo	:= ""

Ctb160IniVar()

//Montando um array conforme parametros acima para ser usada na função que montas o aCols
For x:=1 To nGetQtd
    aAdd(aTrtCpo,{"CTS_LINHA",StrZero(x,Len(CriaVar("CTS_LINHA"))),.F.})
Next x

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos a serem exibidos no MsNewGetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cExbCpo := "CTS_LINHA/CTS_CT1INI/CTS_CT1FIM/CTS_CTTINI/CTS_CTTFIM/CTS_CTDINI/CTS_CTDFIM/CTS_CTHINI/CTS_CTHFIM"

Iif (_lCpoEnt05,cExbCpo += "/CTS_E05INI/CTS_E05FIM",Nil) //Inclusao dos campos da entidade 05
Iif (_lCpoEnt06,cExbCpo += "/CTS_E06INI/CTS_E06FIM",Nil) //Inclusao dos campos da entidade 06
Iif (_lCpoEnt07,cExbCpo += "/CTS_E07INI/CTS_E07FIM",Nil) //Inclusao dos campos da entidade 07
Iif (_lCpoEnt08,cExbCpo += "/CTS_E08INI/CTS_E08FIM",Nil) //Inclusao dos campos da entidade 08
Iif (_lCpoEnt09,cExbCpo += "/CTS_E09INI/CTS_E09FIM",Nil) //Inclusao dos campos da entidade 09

//Execução das rotinas
aHead		:= faHead(cGetAls,cExbCpo)
cAuxExbCpo	:= "/CTS_IDENTI/CTS_FORMUL/CTS_TPSALD"
aAuxHead	:= faHead(cGetAls,cAuxExbCpo)

aEval(aAuxHead, {|x|aAdd(aHead, x)})

cExbCpo += cAuxExbCpo

aCVzo := faCols(aHead,cGetAls,nGetQtd,3      ,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)
aCols := faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)
oGDItens:=MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)                                   
oGDItens:oBrowse:bWhen := { || M->CTS_CLASSE $ "|2|" }

//Reposiciona a seta no registro inicial
If nOpc != 3 ; DbGoTo(nReg) ; EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fInitVarX3   ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega as variaveis em memoria                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fInitVarX3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fInitVarX3(cAlias,lInitVarX3,cExibeCpos)

Local aExibLst 	:= {}
Local cObrig	:= "CTS_CODPLA/CTS_ORDEM/CTS_CONTAG/CTS_DESCCG/CTS_NORMAL/CTS_CLASSE/CTS_NOME"
Local nRecSx3  	:= 0

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
//	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
	If cNivel >= SX3->X3_NIVEL .And. AllTrim(SX3->X3_CAMPO) != "CTS_SLDENT"
		If Empty(cExibeCpos) .Or. AllTrim(SX3->X3_CAMPO) $ cExibeCpos
			nRecSx3 := SX3->(Recno())
			
			SX3->(DbGoTo(nRecSx3))
			If lInitVarX3
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
			Else
				If SX3->X3_CONTEXT != "V"
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_CAMPO))
				Else
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_RELACAO))
				EndIf
			EndIf
			AADD(aExibLst,SX3->X3_CAMPO)
		//*********************************
		// Tratamento de campo de Usuario *
		//*********************************		
		ElseIf SX3->X3_PROPRI == "U"
			If lInitVarX3
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
			Else
				If SX3->X3_CONTEXT != "V"
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_CAMPO))
				Else
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),(cAlias)->&(SX3->X3_RELACAO))
				EndIf
			EndIf
			AADD(aExibLst,SX3->X3_CAMPO)		
		EndIf
	EndIf
	SX3->(DbSkip())
End

//Tratamento pra travar campo nome da visao
Ctb160Nome()

Return(aExibLst)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ faHead       ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega aHeader usado no MsNewGetDados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ faHead()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function faHead(cAlias,cExibeCpos)
Local aHead	:= {}
Local cCpoSX3	:= ""

// Montagem do aHeader
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL)

		cCpoSX3 := AllTrim(SX3->X3_CAMPO)

		If "CTS_IDENT" <> cCpoSX3 .And. (Empty(cExibeCpos) .Or. cCpoSX3 $ cExibeCpos)
			aAdd(aHead, { AllTrim(X3Titulo()),;
                        SX3->X3_CAMPO,;
                        SX3->X3_PICTURE,;
                        SX3->X3_TAMANHO,;
                        SX3->X3_DECIMAL,;
                        SX3->X3_VALID,;
                        SX3->X3_USADO,;
                        SX3->X3_TIPO,;
                        SX3->X3_F3,;
                        SX3->X3_CONTEXT,;
                        X3Cbox(),;
                        SX3->X3_RELACAO,;
                        SX3->X3_WHEN,;
                        SX3->X3_VISUAL,;
                        SX3->X3_VLDUSER,;
                        SX3->X3_PICTVAR,;
                        SX3->X3_OBRIGAT})
		EndIf
	EndIf
	SX3->(DbSkip())
End

Return(aHead)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb160Cbc ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Classe e condicao normal da conta co cabecalho      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Cbc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o do SX3 do Campo CTS_Conta                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb160Cbc()

Local lRet := .T.

If lRet .And. Empty(M->CTS_CODPLA)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CTS_CODPLA")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CTS_ORDEM)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CTS_ORDEM")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CTS_CONTAG)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CTS_CONTAG")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CTS_DESCCG)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CTS_DESCCG")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CTS_NOME)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CTS_NOME")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CTS_CLASSE) .And. !(cIdent $ "3/4/5/6" .Or. SubStr(M->CTS_DESCCG,1,1) = "-")
	Help("  ", 1, "EMPTYCLASS")
	lRet := .f.
EndIf

If lRet .And. Empty(M->CTS_NORMAL) .And. !(cIdent $ "5/6" .Or. SubStr(M->CTS_DESCCG,1,1) = "-")
	Help("  ", 1, "EMPTYCOND")
	lRet := .f.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb160Ent ³ Autor ³ Simone Mie Sato       ³ Data ³ 21.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da entidade.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb160Sup()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CTS->(GetArea())
                  
If !Empty(M->CTS_CONTAG)
	dbSelectArea("CTS")
	dbSetOrder(2)
	
	//A conta superior deve ser diferente da entidade atual
	If M->CTS_CONTAG == M->CTS_CTASUP
		Help("  ", 1, "NOENTIDADEDIF")
		lRet := .F.
	Else
		//A conta deve existir no Plano de Contas. 
		If !MsSeek(xFilial("CTS")+M->CTS_CODPLA+M->CTS_CTASUP) .And. !Empty(M->CTS_CTASUP)
			Help("  ", 1, "NOCADCTASU")
			lRet := .F.
	
			//A conta superior deve ser sintetica. 
			If lRet .And. CTS->CTS_CLASSE != "1"
				Help(" ",1,"NOCLASSESI")
				lRet := .F.
			Endif	
		EndIf
	EndIf
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb160Ent ³ Autor ³ Felipe Aurelio de Melo³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da entidade.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb160Ent(lInclui)

Local lRet	:= .T.
Local cAlias  := Alias()
Local aArea   := CTS->(GetArea())
                  
If !Empty(M->CTS_CONTAG) .And. lInclui
	lRet	:= ExistChav("CTS",M->CTS_CODPLA+M->CTS_CONTAG,2,)
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB160Ord ³ Autor ³ Simone Mie Sato       ³ Data ³ 17.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche com zeros a esquerda o campo ordem do Pl.Gerencial³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Plano de Contas Gerencial                ³±±
±±³          ³ ExpN1 = Ordem no Plano                                     ³±±
±±³          ³ ExpN2 = Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb160Ord(lInclui)

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CTS->(GetArea())
Local cFilCTS := xFilial("CTS")
Local nIncrementa := MV_PAR01

If lInclui
	If nIncrementa  > 0 .And. Empty(M->CTS_ORDEM)
		dbSelectArea("CTS")
		dbSetOrder(1)
		
		If MsSeek(cFilCTS+M->CTS_CODPLA, .F.)
			While CTS->(!Eof()) .and. CTS->CTS_FILIAL == cFilCTS .and. CTS->CTS_CODPLA == M->CTS_CODPLA
				CTS->(dbSkip())                                 
				If CTS->CTS_FILIAL <> cFilCTS .or. CTS->CTS_CODPLA <> M->CTS_CODPLA
					dbSkip(-1)
					M->CTS_ORDEM := StrZero(Val(CTS->CTS_ORDEM) + nIncrementa,Len(M->CTS_ORDEM))
					dbSkip()
				EndIf
			EndDo
		Else                                                       
			M->CTS_ORDEM := StrZero(1,Len(M->CTS_ORDEM))
		Endif

		RestArea(aArea)
		DbSelectArea(cAlias)
	Else
		M->CTS_ORDEM := If(!Empty(M->CTS_ORDEM),StrZero(Val(M->CTS_ORDEM),Len(M->CTS_ORDEM)),M->CTS_ORDEM)
	Endif
EndIf	

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb160Nome ³ Autor ³Simone Mie Sato       ³ Data ³ 10.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctb160Nome()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CTS->(GetArea())

dbSelectArea("CTS")
dbSetOrder(1)
If MsSeek(xFilial("CTS")+M->CTS_CODPLA,.F.)
	M->CTS_NOME := CTS->CTS_NOME
	lTrvNome := .F.
Else
	lTrvNome := .T.
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB160Key ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro do Plano de Contas Gerencial                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Key(cCts_CodPla,cCts_Ordem,nOpc)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Plano de Contas Gerencial                ³±±
±±³          ³ ExpN1 = Ordem no Plano                                     ³±±
±±³          ³ ExpN2 = Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctb160Key(lInclui)

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CTS->(GetArea())

If lInclui
	dbSelectArea("CTS")
	dbSetOrder(1)
	If dbSeek(xFilial()+M->CTS_CODPLA+M->CTS_ORDEM)
		Help("  ", 1, "PLANOEXIST")
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ faCols       ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega aCols usado no MsNewGetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ faCols()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)

Local lFoiTratado := .F.
Local aCol        := {}
Local y           := 1
Local k           := 1
Local cCpoSX3     := ""

//Reinicializa status dos campos trataveis
For y:=1 To Len(aTrtCpo)
	aTrtCpo[y,Len(aTrtCpo[y])]:=.F.
Next y

If nGetOpc == 3
	// Montagem do aCols em Branco
	For y := 1 To nGetQtd
		AADD(aCol,Array(Len(aHead)+1))
		nLin	:= Len(aCol)
		//Sempre reposicionar a set para o alias correto
		SX3->(DbSetOrder(1))
		SX3->(DbSeek(cGetAls))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
			If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
				//Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg

				cCpoSX3 := AllTrim(SX3->X3_CAMPO)

				If "CTS_IDENT" <> cCpoSX3 .And. (Empty(cExbCpo) .Or. cCpoSX3 $ cExbCpo)
					//Faz tratamento de campos especificas caso seja necessario
					lFoiTratado := .F.
					For k := 1 To Len(aTrtCpo)
						If aTrtCpo[k,1] $ SX3->X3_CAMPO .And. !aTrtCpo[k,3]
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := aTrtCpo[k,2]
							aTrtCpo[k,3] := .T.
							lFoiTratado := .T.
							k := Len(aTrtCpo)
						EndIf
					Next k
					//Caso não seja um tratamento especifico seguirá o padrão
					If !lFoiTratado
						If Empty(SX3->X3_RELACAO)
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := CriaVar(SX3->X3_CAMPO)
						Else
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := &(SX3->X3_RELACAO)
						EndIf
					EndIf
				EndIf
			EndIf
			SX3->(DbSkip())
		End
		aCol[nLin,Len(aHead)+1] := .F.
	Next y
Else
	// Montagem do aCols com registros caso tenha
	DbSelectArea(cGetAls)
	DbSetOrder(cGetOrd)
	If DbSeek(&(cGetCnd))
		While !EOF() .And. &(cGetCnd) == &(cGetCpo)
			
			aAdd(aCol,Array(Len(aHead)+1))
			nLin	:= Len(aCol)
			
			SX3->(DbSetOrder(1))
			SX3->(DbSeek(cGetAls))
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
				If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL

					cCpoSX3 := AllTrim(SX3->X3_CAMPO)

					//Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg
					If "CTS_IDENT" <> cCpoSX3 .And. (Empty(cExbCpo) .Or. cCpoSX3 $ cExbCpo)
						If SX3->X3_CONTEXT = "V"
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==cCpoSX3})] := &(SX3->X3_RELACAO)
						Else
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==cCpoSX3})] := &(SX3->X3_CAMPO)
						End
					EndIf
				EndIf
				SX3->(DbSkip())
			End

			aCol[nLin,Len(aHead)+1] := .F.
			DbSkip()
		End
	EndIf
EndIf

Return(aCol)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fSalvaTudo   ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSalvaTudo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fSalvaTudo(nOpc,cAlias,aExbCpo)

// Declara variaveis
Local x        := 1
Local nOrdSeek := 1
Local aGrvCps  := {}
Local cCpoItem := "CTS_LINHA"
Local cCndSeek := "xFilial('CTS')+M->CTS_CODPLA+M->CTS_ORDEM" 

//Trata campos do enchoice
For x:=1 To Len(aExbCpo)
    aAdd(aGrvCps,{aExbCpo[x] ,"M->"+aExbCpo[x]	})
Next x

//Trata campos extras
aAdd(aGrvCps,{"CTS_FILIAL"   ,"xFilial('CTS')"   })
aAdd(aGrvCps,{"CTS_LINHA"    ,"cCodItem"         })

If M->CTS_CLASSE == "1"
	aAdd(aGrvCps,{"CTS_IDENT"    ,"cIdent"           })
ElseIf M->CTS_CLASSE == "2"
	aAdd(aGrvCps,{"CTS_IDENT"    ,"M->CTS_IDENTI"           })
EndIf
	
//Executa rotina pra tratar gravação das variaveis acima e do MsNewGetDados
fGravaGD(oGDItens,cAlias,aGrvCps,nOpc,nOrdSeek,cCndSeek,cCpoItem)

//Reposiciona no primeiro registro no grupo em questão
CTS->(DbSetOrder(1))
CTS->(DbSeek(xFilial('CTS')+M->CTS_CODPLA+M->CTS_ORDEM))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGravaGD     ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±³          ³ apontadas no MsNewGetDados / tratamento por objeto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGravaGD(oObjct,cAlias,aCposAdd,nTpOper,nOrdSeek,cCndSeek,cCpoItm)

Local x 		:= 1
Local y 		:= 1
Local k 		:= 1
Local lCriaCVF	:= .F.
Local lTotVis	:= .T.
Local lVisEnt	:= .T.
Local lSldEnt	:=  .T.
Local lFatSld	:= .T.

Private cCodItem := StrZero(1,Len(CriaVar(cCpoItm)))

DbSelectArea(cAlias)

For x:=1 To Len(oObjct:aCols)
	If !oObjct:aCols[x,Len(oObjct:aHeader)+1]
		
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		
		If nTpOper == 3
			RecLock(cAlias,.T.)
		ElseIf DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		EndIf
		
		For y:=1 To Len(oObjct:aHeader)
			&(oObjct:aHeader[y,2]) := oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==AllTrim(oObjct:aHeader[y,2])})]
		Next y
		
		For k:=1 To Len(aCposAdd)
			&(aCposAdd[k,1]) := &(aCposAdd[k,2])
		Next k
		
		cCodItem := Soma1(cCodItem)
		MsUnLock()

		// Grava a tabela CVE
		If nTpOper == 3
			If CVE->( !DbSeek( xFilial( "CVE" ) + CTS->CTS_CODPLA ) )
				RecLock( "CVE", .T. )
				Replace CVE_FILIAL With xFilial( "CVE" )
				Replace CVE_CODIGO With CTS->CTS_CODPLA
				Replace CVE_DESCRI With CTS->CTS_NOME
				MsUnLock()
			EndIf
		EndIf		

		// Grava a tabela CVF
		CVF->( DbSetOrder( 1 ) )
		lCriaCVF := CVF->( !DbSeek( xFilial( "CVF" ) + CTS->CTS_CODPLA + CTS->CTS_CONTAG/*+ CTS->CTS_ORDEM*/ ) )
		RecLock( "CVF", lCriaCVF )
		Replace CVF_FILIAL 	With xFilial( "CVF" )
		Replace CVF_CODIGO 	With CTS->CTS_CODPLA
		Replace CVF_CONTAG 	With CTS->CTS_CONTAG
		Replace CVF_DESCCG 	With CTS->CTS_DESCCG
		Replace CVF_DETHCG 	With CTS->CTS_DETHCG
		Replace CVF_ORDEM 	With CTS->CTS_ORDEM	
		Replace CVF_CTASUP	With CTS->CTS_CTASUP
		Replace CVF_CLASSE	With CTS->CTS_CLASSE
		Replace CVF_NORMAL	With CTS->CTS_NORMAL	
		Replace CVF_COLUNA	With Iif(__Release .and. __lCOLUN2, CTS->CTS_COLUN2, GetCTSCol(CTS->CTS_COLUNA,'C',"CVF")) 
		Replace CVF_IDENT	With CTS->CTS_IDENT
		If lTotVis
			Replace CVF_TOTVIS	With CTS->CTS_TOTVIS
		EndIf
		If lVisEnt
			Replace CVF_VISENT	With CTS->CTS_VISENT
		EndIf
		If lSldEnt
			Replace CVF_SLDENT	With CTS->CTS_SLDENT
		EndIf
		If lFatSld
			Replace CVF_FATSLD	With CTS->CTS_FATSLD
		EndIf
		MsUnLock()
			
		// P E para sincronismo de campos do usuário
		If ExistBlock("CT160CVF")
			ExecBlock("CT160CVF",.F.,.F.)
		EndIf		
	Else
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		If nTpOper != 3
			If DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
				RecLock(cAlias,.F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
	EndIf
Next x

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fExcluiTudo  ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela exclusão de todos os itens         ³±±
±±³          ³ apresentados na tela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fExcluiTudo()

//Executa procedimento de exclusão de registros
CTS->(DbSetOrder(1))
If CTS->(DbSeek(xFilial('CTS')+M->(CTS_CODPLA+CTS_ORDEM)))
	While CTS->(!Eof()) .And. xFilial('CTS')+M->(CTS_CODPLA+CTS_ORDEM) == CTS->(CTS_FILIAL+CTS_CODPLA+CTS_ORDEM)
		RecLock("CTS",.F.)
		dbDelete()
		MsUnLock()
		CTS->(DbSkip())
	End
EndIf
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb160GOk    ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida todos os campos do MsNewGetDados de todas as linhas ³±±
±±³          ³ para obrigar preenchimento dos campos obrigatorio.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160TOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb160GOk()

Local aSaveArea:= GetArea()
Local aCols    := oGDItens:aCols
Local lRet     := .T.
Local nCont    := 0


For nCont := 1 To Len(aCols)
   oGDItens:oBrowse:nAt:=nCont
   oGDItens:oBrowse:Refresh()
   oGDItens:oBrowse:SetFocus()
	If !Ctb160LOK()
		lRet := .F.
		Exit
	EndIf
Next nCont

RestArea(aSaveArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb160LOk    ³ Autor ³ Felipe A. Melo    ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida linhas do MsNewGetDados para obrigar preenchimento  ³±±
±±³          ³ dos campos obrigatorio.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160LOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb160LOk()

Local aSaveArea   := GetArea()
Local aHeader     := oGDItens:aHeader
Local aCols       := oGDItens:aCols
Local n           := oGDItens:oBrowse:nAt
Local lRet		  := .T.
Local nPosCtaIni  := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CT1INI"})
Local nPosCtaFim  := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CT1FIM"})
Local nPosCCIni   := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTTINI"})
Local nPosCCFim   := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTTFIM"})
Local nPosItemIni := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTDINI"})
Local nPosItemFim := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTDFIM"})
Local nPosCLVLIni := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTHINI"})
Local nPosCLVLFim := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_CTHFIM"})
Local nPosIdent   := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_IDENTI"})
Local nPosFormula := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_FORMUL"})
//Campos referentes as novas entidades contabeis
Local nPosE05Ini := If(_lCpoEnt05,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E05INI"}),Nil)
Local nPosE05Fim := If(_lCpoEnt05,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E05FIM"}),Nil)
Local nPosE06Ini := If(_lCpoEnt06,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E06INI"}),Nil)
Local nPosE06Fim := If(_lCpoEnt06,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E06FIM"}),Nil)
Local nPosE07Ini := If(_lCpoEnt07,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E07INI"}),Nil)
Local nPosE07Fim := If(_lCpoEnt07,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E07FIM"}),Nil)
Local nPosE08Ini := If(_lCpoEnt08,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E08INI"}),Nil)
Local nPosE08Fim := If(_lCpoEnt08,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E08FIM"}),Nil)
Local nPosE09Ini := If(_lCpoEnt09,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E09INI"}),Nil)
Local nPosE09Fim := If(_lCpoEnt09,Ascan(aHeader,{|x|Alltrim(x[2]) == "CTS_E09FIM"}),Nil)

If M->CTS_CLASSE = "2"						// Verifica Analiticas
	If !aCols[n][Len(aHeader)+1]
		If Empty(aCols[n][nPosCtaIni]) 	.And. Empty(aCols[n][nPosCCIni]) 	.And.;
			Empty(aCols[n][nPosItemIni]) 	.And. Empty(aCols[n][nPosCLVLIni]) .And.;
			Empty(aCols[n][nPosCtaFim]) 	.And. Empty(aCols[n][nPosCCFim]) 	.And.;
			Empty(aCols[n][nPosItemFim]) 	.And. Empty(aCols[n][nPosCLVLFim]) .And.;
			Empty(aCols[n][nPosFormula])	.And.;
			(aCols[n][nPosIdent] == "1" .Or. aCols[n][nPosIdent] == "2") .And.;
			! (cIdent = "3" .Or. cIdent = "4" .Or. cIdent $ "5/6" .Or. M->CTS_DESCCG = "-")
			lRet := .F.
		EndIf

		If(_lCpoEnt05 .And. !lRet,lRet := !Empty(aCols[n][nPosE05Ini]),Nil)
		If(_lCpoEnt05 .And. !lRet,lRet := !Empty(aCols[n][nPosE05Fim]),Nil)
		If(_lCpoEnt06 .And. !lRet,lRet := !Empty(aCols[n][nPosE06Ini]),Nil)
		If(_lCpoEnt06 .And. !lRet,lRet := !Empty(aCols[n][nPosE06Fim]),Nil)
		If(_lCpoEnt07 .And. !lRet,lRet := !Empty(aCols[n][nPosE07Ini]),Nil)
		If(_lCpoEnt07 .And. !lRet,lRet := !Empty(aCols[n][nPosE07Fim]),Nil)
		If(_lCpoEnt08 .And. !lRet,lRet := !Empty(aCols[n][nPosE08Ini]),Nil)
		If(_lCpoEnt08 .And. !lRet,lRet := !Empty(aCols[n][nPosE08Fim]),Nil)
		If(_lCpoEnt09 .And. !lRet,lRet := !Empty(aCols[n][nPosE09Ini]),Nil)
		If(_lCpoEnt09 .And. !lRet,lRet := !Empty(aCols[n][nPosE09Fim]),Nil)

		If !lRet
			Help(" ",1,"C160NOENTI")
		EndIf

		If lRet
			If !Empty(aCols[n][nPosCtaIni]) .And. Empty(aCols[n][nPosCtaFim])
				Help(" ",1,"C160NOCTA")
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If !Empty(aCols[n][nPosCCIni]) .And. Empty(aCols[n][nPosCCFim])
				Help(" ",1,"C160NOCC")
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If !Empty(aCols[n][nPosItemIni]) .And. Empty(aCols[n][nPosItemFim])
				Help(" ",1,"C160NOITEM")
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If !Empty(aCols[n][nPosCLVLIni]) .And. Empty(aCols[n][nPosCLVLFim])
				Help(" ",1,"C160NOCLVL")
				lRet := .F.
			EndIf
		EndIf

		If _lCpoEnt05 .And. lRet
			If !Empty(aCols[n][nPosE05Ini]) .And. Empty(aCols[n][nPosE05Fim])
				Help(" ",1,"C160NOEC05")
				lRet := .F.
			EndIf
		EndIf
             
		If _lCpoEnt06 .And. lRet
			If !Empty(aCols[n][nPosE06Ini]) .And. Empty(aCols[n][nPosE06Fim])
				Help(" ",1,"C160NOEC06")
				lRet := .F.
			EndIf
		EndIf
		
		If _lCpoEnt07 .And. lRet
			If !Empty(aCols[n][nPosE07Ini]) .And. Empty(aCols[n][nPosE07Fim])
				Help(" ",1,"C160NOEC07")
				lRet := .F.
			EndIf
		EndIf
		
		If _lCpoEnt08 .And. lRet
			If !Empty(aCols[n][nPosE08Ini]) .And. Empty(aCols[n][nPosE08Fim])
				Help(" ",1,"C160NOEC08")
				lRet := .F.
			EndIf
		EndIf
		
		If _lCpoEnt09 .And. lRet
			If !Empty(aCols[n][nPosE09Ini]) .And. Empty(aCols[n][nPosE09Fim])
				Help(" ",1,"C160NOEC09")
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If	M->CTS_CLASSE = "1" .And. (Empty(aCols[n][nPosIdent]) .Or. !(cIdent $ "1/2"))
				Help(" ",1,"C160NOSIN")
				lRet := .F.
			EndIf
		EndIf
		
	EndIf
EndIf

If M->CTS_CLASSE = "1" .And. cIdent = "4"
	If !Empty(aCols[n][nPosCtaIni]) 	.Or. !Empty(aCols[n][nPosCCIni]) 	.Or.;
		!Empty(aCols[n][nPosItemIni]) 	.Or. !Empty(aCols[n][nPosCLVLIni]) .Or.;
		!Empty(aCols[n][nPosCtaFim]) 	.Or. !Empty(aCols[n][nPosCCFim]) 	.Or.;
		!Empty(aCols[n][nPosItemFim]) 	.Or. !Empty(aCols[n][nPosCLVLFim])
		lRet := .F.
	EndIf
                                                                         
		If(_lCpoEnt05 .And. lRet,lRet := Empty(aCols[n][nPosE05Ini]),Nil)
		If(_lCpoEnt05 .And. lRet,lRet := Empty(aCols[n][nPosE05Fim]),Nil)
		If(_lCpoEnt06 .And. lRet,lRet := Empty(aCols[n][nPosE06Ini]),Nil)
		If(_lCpoEnt06 .And. lRet,lRet := Empty(aCols[n][nPosE06Fim]),Nil)
		If(_lCpoEnt07 .And. lRet,lRet := Empty(aCols[n][nPosE07Ini]),Nil)
		If(_lCpoEnt07 .And. lRet,lRet := Empty(aCols[n][nPosE07Fim]),Nil)
		If(_lCpoEnt08 .And. lRet,lRet := Empty(aCols[n][nPosE08Ini]),Nil)
		If(_lCpoEnt08 .And. lRet,lRet := Empty(aCols[n][nPosE08Fim]),Nil)
		If(_lCpoEnt09 .And. lRet,lRet := Empty(aCols[n][nPosE09Ini]),Nil)
		If(_lCpoEnt09 .And. lRet,lRet := Empty(aCols[n][nPosE09Fim]),Nil)
    
		If !lRet
			MsgAlert(STR0021,STR0022) //"Conta de total somente pode possuir formula"###"Alerta")
        EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB160Exp ºAutor  ³Microsiga           º Data ³  12/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB160Exp()
	SaveInter()

	CTB161Exp()

	RestInter()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB160Imp ºAutor  ³Microsiga           º Data ³  12/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB160Imp()
	SaveInter()
	CTB161Imp()

	RestInter()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTBA160Alt³ Autor ³ Totvs                 ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o cadastro da visao gerencial                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb160Alt()
	Ctb161Alt()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb160Exc    ³ Autor ³ Totvs             ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui a visao gerencial.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb160Exc( cAlias, nReg, nOpc )

	Ctb161Del( cAlias, nReg, nOpc, MV_PAR06 == 2 )
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb160Prox ³ Autor ³ Pilar S.Albaladejo	³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb160Prox(lInclui)
Local aArea	  := GetArea()
Local cContag := ""

Do Case
	//Automatico
	Case Empty(M->CTS_CONTAG) .And. lInclui .And. MV_PAR02 = 1 
	
 		cContag := CTS->CTS_CONTAG
 		
 //	 	If cContag != "1"
 	 	dbSetOrder(2)   
	 	dbSeek(xFilial()+M->CTS_CODPLA+"zzzzzzzzzzzzzzzzzzzz",.T.)
		dbSkip(-1) 
		cContag := CTS->CTS_CONTAG
 //		Endif
	
		M->CTS_CONTAG := PadR(Soma1(AllTrim(cContag)),TamSx3("CTS_CONTAG")[1]) 
		
   //Formula
	Case lInclui .And. MV_PAR02 = 2
		If Empty(MV_PAR03)
			M->CTS_CONTAG := CriaVar("CTS_CONTAG")
		Else
			If C161VldFormula(MV_PAR03)
				M->CTS_CONTAG := &(MV_PAR03)
			EndIf
		EndIf
	
	//Digitacao
	Case Empty(M->CTS_CONTAG) .And. lInclui .And. MV_PAR02 = 3
		M->CTS_CONTAG := CriaVar("CTS_CONTAG")

EndCase

If lInclui .And. MV_PAR04 = 1
	M->CTS_CONTAG := StrZero(Val(M->CTS_CONTAG),TamSx3("CTS_CONTAG")[1],0)
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb160Vld    ³ Autor ³ Pilar S.Albaladejo³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida campos do cabecalho do rotina(tela)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb160Vld(cCpoVld,lInclui)

Local lRet := .T.
Local nCont:=  0

Do Case
	Case AllTrim(cCpoVld) == "CTS_CODPLA"
		If lRet
			lRet := NaoVazio(M->CTS_CODPLA)
		EndIf
		If lRet
			lRet := FreeForUse("CTS",M->CTS_CODPLA)
		EndIf
		If lRet
			lRet := Ctb160Ord(lInclui)
		EndIf
		If lRet           
			lRet := Ctb160Nome()
		EndIf
		If lRet
			lRet := Ctb160Prox(lInclui)
		EndIf

	Case AllTrim(cCpoVld) == "CTS_ORDEM"
		If lRet
			lRet := NaoVazio(M->CTS_ORDEM)
		EndIf
		If lRet
			lRet := Ctb160Ord(lInclui)
		EndIf
		If lRet
			lRet := Ctb160Key(lInclui)
		EndIf
		If lRet
			lRet := Ctb160Prox(lInclui)
		EndIf

	Case AllTrim(cCpoVld) == "CTS_CONTAG"
		If lRet
			lRet := NaoVazio(M->CTS_CONTAG)
		EndIf
		If lRet
			lRet := Ctb160Ent(lInclui)
		EndIf

	Case AllTrim(cCpoVld) == "CTS_CTASUP"
		If lRet
			lRet := Ctb160Sup()
		EndIf

	Case AllTrim(cCpoVld) == "CTS_CLASSE"
		If lRet
			lRet := NaoVazio(M->CTS_CLASSE)
		EndIf
		If !IsInCallStack('CTBA020') 
			If M->CTS_CLASSE = "1"
				cIdent := "3"
				For nCont:=1 To Len(oGDItens:aCols)
					oGDItens:aCols[nCont][Len(oGDItens:aHeader)+1]:=.T.
				Next nCont
				oGDItens:aCols[1]:=aCVzo[1]
				oGDItens:oBrowse:bWhen := { || .F. }
			Else
				cIdent := "1"
				oGDItens:oBrowse:bWhen := { || .T. }
			EndIf
			oGDItens:Refresh()
		
			//Inicializa variaveis do checkbox
			If lRet ; CT160VlCkBx(1,3,"*") ; EndIf
		Endif	

	Case AllTrim(cCpoVld) == "CTS_IDENT" .OR. AllTrim(cCpoVld) == "cIdent"
		If SubStr(cIdent,1,1) = "7"
			M->CTS_DESCCG := "-"
		Else
			If SubStr(M->CTS_DESCCG,1,1) = "-"
				M->CTS_DESCCG := SubStr(M->CTS_DESCCG,2,Len(M->CTS_DESCCG))
			EndIf
		EndIf
		If lRet .And. cIdent $ "1/2" .And. M->CTS_CLASSE = "1"
			Help(" ",1,"HELP","PROIBIDO","Para Identific. 1(soma) ou 2(subtrai), usar classe 2(analitica)",3,1)
			lRet:=.F.
		EndIf
		If lRet .And. cIdent $ "3/4/5/6/7" .And. M->CTS_CLASSE = "2"
			Help(" ",1,"HELP","PROIBIDO","Para Identific. diferente de 1(soma) ou 2(subtrai), usar classe 1(sintetica)",3,1)
			lRet:=.F.
		EndIf
		//Inicializa variaveis do checkbox
		If lRet ; CT160VlCkBx(1,3,"*") ; EndIf

	Case AllTrim(cCpoVld) == "CTS_NORMAL"
		If lRet
			lRet := NaoVazio(M->CTS_NORMAL)
		EndIf

	Case AllTrim(cCpoVld) == "CTS_DESCCG"
		If SubStr(M->CTS_DESCCG,1,1) = "-"
			cIdent := "7"
		Else
			cIdent := " "		
		EndIf
		//Inicializa variaveis do checkbox
		If lRet 
			if IsInCallStack("CTBA160")  
		 		CT160VlCkBx(1,3,"*")
		 	EndIf
		EndIf
	Case AllTrim(cCpoVld) == "CTS_TOTVIS"
      lRet := CT160VlTot()
		If lRet ; CT160VlCkBx(1,3,"*") ; EndIf


EndCase

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb160TOk ºAutor  ³Microsiga           º Data ³  09/24/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a validação da tela de cadastro                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb160TOk()
Local lRet := .T.
Local xRet := Nil
If lRet 
	lRet := Ctb160Key(INCLUI)
EndIf 

If lRet
	lRet := Ctb160Cbc() 
EndIf          

If lRet
	lRet := CT160VlTot() 
EndIf

If lRet 
	lRet := Ctb160GOk() 
EndIf

If lRet	
	lRet := Obrigatorio(aGets,aTela) 
EndIf

If lRet
	lRet := oGDItens:TudoOk()
EndIf

//Bloco de código com a validação do usuário
If lRet
	If ExistBlock("CT160TOK")
		xRet := ExecBlock("CT160TOK",.F.,.F.)
		If ValType(xRet) == "L"
			lRet := xRet
		EndIf
	EndIf
EndIf


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb160IniVar  ºAutor  ³Microsiga       º Data ³  18/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb160IniVar()

Local aSaveArea := GetArea()

dbSelectArea("CTS")

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CTS->(FieldPos("CTS_E05INI")>0 .And. FieldPos("CTS_E05FIM")>0)
EndIf
     
If _lCpoEnt06 == Nil
	_lCpoEnt06 := CTS->(FieldPos("CTS_E06INI")>0 .And. FieldPos("CTS_E06FIM")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CTS->(FieldPos("CTS_E07INI")>0 .And. FieldPos("CTS_E07FIM")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CTS->(FieldPos("CTS_E08INI")>0 .And. FieldPos("CTS_E08FIM")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CTS->(FieldPos("CTS_E09INI")>0 .And. FieldPos("CTS_E09FIM")>0)
EndIf

RestArea(aSaveArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb160aCpoºAutor  ³Microsiga           º Data ³  20/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb160aCpo(cAlias,lInitVarX3,cExibeCpos)
Return(fInitVarX3(cAlias,lInitVarX3,cExibeCpos))
