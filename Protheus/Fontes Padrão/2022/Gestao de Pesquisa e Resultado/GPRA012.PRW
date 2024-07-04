#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"

#DEFINE STR0019 "Geração de Lista" 
#DEFINE STR0020 "Informe os dados para gerar lista."
#DEFINE STR0045 "Lista selecionada :"
#DEFINE STR0021 "Data da nova Lista:"
#DEFINE STR0045 "Pesquisa selecionada :"
#DEFINE STR0023 "Confirmação" 
#DEFINE STR0022 "Nome da Lista:   "
#DEFINE STR0025 "Aguarde enquanto a nova lista é gerada... "
#DEFINE STR0024 "Os dados informados foram: "


//ÚPendencias da RotinaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
//³- X3_VALID, para os campos   
//³  KL_CODLST                  
//³  KL_TABELA                  
//³  KL_ORDEM                   
//³-  Processar a lista: Alteracao
//³                      Exclusao  (Na deletação da pesquisa deletar tb a lista)                                                                      
//³-  ajustar a funcao de delecao das entidades, tira "[x]", nas funcoes Wizard.                                                                "
//³-  ajustar a funcao de delecao das Indices, tira "[x]", nas funcoes Wizard.                                                                "
//³-  Definir posicionamento do listbox atraves da variavel oBLis:nat
//³-  Na funcao Wizard, criar get para digitacao do nome da lista
//³-  Centralizar a tela de pesquisa das Pesquisa cadastradas.              
//³-  Criar Botao para chamada de uma funcao de browse dos itens da lista.  
//³-  Definicao das indicadores de processamento.
//³-  Criacao do arquivo CH, da rotina.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRA012    ³Autor  ³ Marcos Alves         ³ Data ³ 28/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista de respondentes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPRA012(aRotAuto,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adicionando as Cores como Semaforo para ver Inativacao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local aCores 	  := {	{'KL_STATUS == "1"' , "BR_VERMELHO" },;
//						{'KL_STATUS == "2" ', "BR_VERDE"	}}
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := "Cadastro de listas"
Private cString   := "SKL"     	// Alias de Trabalho - LISTAS

Private aMemos    := {{"KL_CODFLT","KL_FILTRO"}} // Array resp. pela gravacao dos campos memo
Private aRotina   := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis para rotina de inclusao automatica    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private l010Auto := ( aRotAuto <> NIL )

nOpc := IIF(nOpc == NIL, 3, nOpc)

DbSelectArea(cString)
DbSetOrder(1)

If l010Auto
	MsRotAuto(nOpc,aRotAuto,cString)
Else
	//mBrowse(6,1,22,75,cString,,,,,,aCores)
	mBrowse(6,1,10,75,cString,,,,,,)
Endif

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 12.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{"Pesquisar"  ,"AXPESQUI"	,0 ,1 ,0 ,.F. }	,;	//Pesquisar
						{"Visualizar" ,"GPRA012VIS"	,0 ,2 ,0 ,.T. }	,;	//Visualizar
						{"Incluir"    ,"GPRA012INC"	,0 ,3 ,0 ,.T. }	,;	//Incluir
						{"Alterar"    ,"GPRA012LST"	,0 ,4 ,0 ,.T. }	,;	//Alterar
						{"Excluir"    ,"GPRA012EXC"	,0 ,5 ,0 ,.T. }	,;	//Excluir
						{"Assistente" ,"GPRA012LST"	,0 ,0 ,0 ,.T. }	,;	//Excluir
						{"Legenda"    ,"GPRA012LEG"	,0 ,7 ,0 ,.T. }	}	//Legenda
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRA012VIS ³Autor  ³ Marcos Alves         ³ Data ³ 28/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Visualiza‡ao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPRA012VIS(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opção selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPRA012VIS(cAlias,nReg,nOpc)

AxVisual(cAlias,nReg,nOpc,NIL,NIL,NIL,NIL,NIL,NIL,NIL)

DbSelectarea(cAlias)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRA010INC ³Autora ³ Solange Zanardi      ³ Data ³ 20/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Inclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPRA010INC(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opção selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPRA012INC(cAlias,nReg,nOpc)

// Inserindo o Botao com a opcao de contrutor de filtros
Local aButtons  := {}
Local cFiltro   := ""
Local nOpcao    := 0

AAdd(aButtons,{"FILTRO", { || GPRA012Exp(M->KL_TABELA,cFiltro, "M->KL_FILTRO") } , "Construtor Filtros" } ) // "Construtor Filtros"

If ( Type("l010Auto") == "U" ) .OR. !l010Auto
	nOpcao := AxInclui(cAlias,nReg,nOpc,NIL,NIL,NIL,NIL,NIL,NIL,aButtons)
Else
	nOpcao := AxIncluiAuto(cAlias,NIL,NIL,NIL,NIL)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processar a geracao da lista com os dados incluidos					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 1
	GPRProcLst(SKL->KL_CODIGO,nOpc)
EndIf

DbSelectarea(cAlias)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRA012ALT ³Autor  ³ Marcos Alves         ³ Data ³ 28/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Alteracao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPRA012ALT(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opção selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPRA012ALT(cAlias,nReg,nOpc)

Local aButtons  := {}		// Array com os Botoes da Toolbar
//Local cFiltro   := ""		// Filtro do botao de Construtor de Filtros
Local nOpcao    := 0		// Retorno da opcao de Confirmacao da alteracao	

//AAdd(aButtons,{"FILTRO", { || GPRA010FIL(@cfiltro) } , STR0002 } ) // "Construtor Filtros"

nOpcao := AxAltera(cAlias,nReg,nOpc,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aButtons)

DbSelectarea(cAlias)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRA012EXC ³Autor  ³ Marcos Alves         ³ Data ³ 28/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPRA012EXC(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opção selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPRA012EXC(cAlias,nReg,nOpc)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPRA012LST³Autor ³Marcos Alves        º Data ³  24/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geracao de lista para pesquisa atraves de wizard           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista pesquisa                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPRA012LST(cAlias,nReg,nOpc)

Local lRet			:= .F.						// Retorno da funcao
Local oWizard
Local oPesq 		
Local cPesq         :=Space(TamSx3("KC_DESC")[1])
Local oCodPQ 		
Local cCodPQ        :=Space(TamSx3("KC_CODPQ")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do listBox das entidades            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oListBox                                             	//Objeto da listbox
Local aEntidade   := {{.F.,"","",""}}                       //Array da ListBox)
Local cListBox    := ""										// recebe os dados do listbox selecionado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do listBox dos Indices da entidade  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oListInd                                             	//Objeto da listbox dos Indices da entidade selecionada
Local aIndice     := {{.F.,"",""}}								//Array da ListBoxdos Indices da entidade selecionada
Local cListInd    := ""

Local oOk         := LoadBitmap(GetResources(), "LBOK")    	//Desenho do Checked
Local oNo         := LoadBitmap(GetResources(), "LBNO")    	//Desenho do Not Checked
Local lOk         := .F.                                   	//Confirmacao da tela
Local nI	      := 0										//Contador de Laco
//Local cAlias	  := "SKC"

Local cFiltro     := ""

cFiltro     := MSMM(SKL->KL_CODFLT)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao para criacao das tabelas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SKL")
dbSelectArea("SKM")

If nOpc==4 //ALTERACAO
	cCodPq	:= SKL->KL_CODPQ
	cPesq	:= SKD->KD_DESC
EndIf

dbSelectArea("SKC")
//"Copia de Lista" "Informe os dados para cópia."
DEFINE WIZARD oWizard TITLE "Assistente para geração da lista da amostra" HEADER "Seleção dos dados" MESSAGE "Informe a Pesquisa" TEXT "" ;
	NEXT {|| !Empty(cPesq).AND.GPR012Entidade(aEntidade,oListBox,oOk,oNo,nOpc)} FINISH {||.F.} PANEL NOFIRSTPANEL 
	//NEXT {|| !Empty(cPesq).AND.GPR012Ent()} FINISH {||.F.} PANEL NOFIRSTPANEL 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 1 - Selecao da pesquisa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:GETPANEL(1)
	@ 30,20 SAY "Pesquisa:" OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 //"Pesquisa:"
	@ 40,20 MSGET oCodPQ VAR cCodPQ SIZE 35, 10  OF oWizard:GETPANEL(1) F3 "SKC" VALID (!Empty(cCodPq),cPesq :=SKC->KC_DESC,oPesq:Refresh()) PIXEL
	@ 42,65 SAY oPesq    VAR cPesq OF oWizard:GETPANEL(1) PIXEL SIZE 210,9 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 2 - Selecao da Entidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER "Seleção dos dados" MESSAGE "Informe a Entidade" BACK {||.T.} ;
		NEXT {|| GPRSetAlias(aEntidade,@cAlias),GPR012Indice(cAlias,aIndice,oListInd,oOk,oNo,nOpc)} FINISH {||.T.} PANEL
	oWizard:GETPANEL(2)
	@ .5,.7  LISTBOX oListBox VAR cListBox Fields HEADER "","Entidade"+Space(30),Substr("Apelido",1,30) SIZE 280,130 OF oWizard:GETPANEL(2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a configuracao da ListBox.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oListBox:SetArray(aEntidade)
	oListBox:bLine      := { || { IIf(aEntidade[oListBox:nAt][1],oOk,oNo),aEntidade[oListBox:nAt,2],aEntidade[oListBox:nAt,3]} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 3 - Selecao do Indice da Entidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER "Seleção dos dados" MESSAGE "Informe a Indice da Entidade" BACK {||.T.} ;
	   NEXT {|| GPRSetAlias(aEntidade,@cAlias),	BuildExpr(cAlias,oWizard,@cFiltro,.T.,,oWizard:GETPANEL(4)),.T.} FINISH {||.F.} PANEL 

	oWizard:GETPANEL(3)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Listbox dos indices da entidade selecionada.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ .5,.7  LISTBOX oListInd VAR cListInd Fields HEADER "","Ordem","Chave"+space(30) SIZE 280,130 OF oWizard:GETPANEL(3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a configuracao da ListBox dos indicesda entidade selecionada        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oListInd:SetArray(aIndice)
	oListInd:bLine      := { || { IIf(aIndice[oListInd:nAt][1],oOk,oNo),aIndice[oListInd:nAt,2],aIndice[oListInd:nAt,3]} }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 4 - Selecao do Filtro             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER "Seleção dos dados" MESSAGE "Informe a Filtro da Entidade" BACK {||.T.} ;
			NEXT {||  .T.} FINISH {||.F.} PANEL
	oWizard:GETPANEL(4)                                            


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 5 - Resultado do Wizard           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER "Seleção dos dados" MESSAGE "Resultado do Wizard" BACK {||.T.} ;
		NEXT {||.T.} FINISH {|| GPRPl05(cCodPQ,aEntidade,oListBox,aIndice,oListInd,cFiltro,nOpc)} PANEL
	oWizard:GETPANEL(5)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresenta os dados do wizard                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 03,05 TO 60,280 LABEL "" OF oWizard:GETPANEL(5) PIXEL	
	@ 15,20 SAY "Pesquisa : " + cPesq OF oWizard:GETPANEL(5) PIXEL SIZE 150,9  //
	@ 25,20 SAY "Entidade : " + oListBox:aArray[oListBox:nRowPos][3]+" - "+oListBox:aArray[oListBox:nRowPos][2] OF oWizard:GETPANEL(5) PIXEL SIZE 150,9  //
	@ 35,20 SAY "Ordem    : " + oListInd:aArray[oListInd:nRowPos][3] OF oWizard:GETPANEL(5) PIXEL SIZE 150,9  //

	@ 70,06 GET oMFiltro VAR cFiltro MULTILINE SIZE 270, 40 OF oWizard:GETPANEL(5) PIXEL WHEN .F.  READONLY
	
ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPR012EntidadeºAutor  ³Marcos Alves    º Data ³  01/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista pesquisa                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPR012Entidade(aEntidade,oListBox,oOk,oNo,nOpc)
Local lRet		  := .T.									// Retorno da funcao
Local nI	      := 0										// Contador de Laco
Local aTabela 	  := {{"T5",.T.},{"T8",.F.}} 				// Contem as tabelas com ou sem contatos - Formato:[Nome da tabela, .T. (Com contato)]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se já foi inicializada não refaz o processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aEntidade[1][2])
	Return .T.
EndIf      

aEntidade := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazenas as entidade cadastradas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorWait()     
DbSelectArea("SX5")
DbSetOrder(1)
For nI := 1 TO Len(aTabela)
	If DbSeek(xFilial("SX5") + aTabela[nI,1]) //"T5,T8"
		While !Eof() .AND. (xFilial("SX5") == SX5->X5_FILIAL) .AND. (SX5->X5_TABELA == aTabela[nI,1])
			Aadd(aEntidade,{If(nOpc=4.AND.Alltrim(SX5->X5_CHAVE)==Alltrim(SKL->KL_TABELA),.T.,.F.),;	// [01] - Desabilitado
							AllTrim(X5DESCRI()),;									// [02] - Nome da Tabela
							AllTrim(SX5->X5_CHAVE),;    							// [03] - Alias da tabela	
							aTabela[nI,2]})             							// [04] - Tipo da entidade("T5"/"T8"),com ou sem contatos (.T. - Com contato)]
			DbSkip()
		End
	Endif
Next nI
CursorArrow()

If Len(aEntidade) == 0
	MsgStop("Nao existem entidades parametrizadas nesta filial para a utilização do Construtor de Filtros") // "Nao existem entidades parametrizadas nesta filial para a utilização do Construtor de Filtros"
	lRet	:= .F.
Else
	oListBox:SetArray(aEntidade)
	If nOpc=0 
		oListBox:bLine      := { || { aEntidade[oListBox:nAt,2],aEntidade[oListBox:nAt,3]} }
	Else	
		oListBox:bLine      := { || { IIf(aEntidade[oListBox:nAt][1],oOk,oNo),aEntidade[oListBox:nAt,2],aEntidade[oListBox:nAt,3]} }
		oListBox:bLDblClick := { || aEval(aEntidade,{|ExpA1| ExpA1[1] := .F.}),aEntidade[oListBox:nAt][1] := !aEntidade[oListBox:nAt][1],oListBox:Refresh() }
	EndIf	
	//oListBox:nAt:=3
	oListBox:Refresh()
Endif
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPR012Indice  ºAutor  ³Marcos Alves    º Data ³  02/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista pesquisa                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Static Function GPR012Indice(aEntidade,aIndice,oListInd,oOk,oNo,nOpc)
Static Function GPR012Indice(cAlias,aIndice,oListInd,oOk,oNo,nOpc)
Local lRet	 := .T.
Local nI	 :=  0										// Contador de Laco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tem que selecionar uma entidade                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cAlias)
	Return .F.
EndIf      
aIndice := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazenas as entidade cadastradas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SIX")
DbSetOrder(1)     
dbSeek(cAlias)
While !Eof() .AND. INDICE==cAlias
	Aadd(aIndice,{If(nOpc=4.AND.SIX->ORDEM==SKL->KL_ORDEM,.T.,.F.)     ,;     				// [01] - Desabilitado
				 ORDEM    ,;					// [02] - numero do Indice
			     Capital( SIXDescricao())})     // [03] - Descricao do indice
	DbSkip()
End

If Len(aIndice) == 0
	MsgStop("Nao existem entidades parametrizadas nesta filial para a utilização do Construtor de Filtros") // "Nao existem entidades parametrizadas nesta filial para a utilização do Construtor de Filtros"
	lRet	:= .F.
Else
	oListInd:SetArray(aIndice)
	If nOpc=0
	   oListInd:bLine      := { || { aIndice[oListInd:nAt,2],aIndice[oListInd:nAt,3]} }
    Else
	   oListInd:bLine      := { || { IIf(aIndice[oListInd:nAt][1],oOk,oNo),aIndice[oListInd:nAt,2],aIndice[oListInd:nAt,3]} }
	   oListInd:bLDblClick := { || aEval(aIndice,{|ExpA1| ExpA1[1] := .F.}),aIndice[oListInd:nAt][1] := !aIndice[oListInd:nAt][1],oListInd:Refresh() }
    EndIf
	oListInd:Refresh()
Endif
Return lRet

Function GprBuildExpr(cAlias,oWizard,oListInd,oListBox,cFiltro)

//cFiltro:=BuildExpr(cAlias,,,,,oWizard:GETPANEL(4))
cFiltro:=BuildExpr(cAlias,,cFiltro,,,oWizard:GETPANEL(4))
//cFiltro:=BuildExpr(cAlias,oWizard:GETPANEL(4),cFiltro)

Return( cFiltro )                                      

// --------------------------

Static Function GPRSetAlias(aEntidade,cAlias)
Local aArea := GetArea()    // Salva a area atual
Local nI					// Contador

For nI:=1 to Len(aEntidade)
	If aEntidade[nI][1] 
    	cAlias :=aEntidade[nI][3]
        Exit
    EndIf
Next nI

RestArea(aArea)
Return(.T.)

//Static Function GPRPL04(cPesq,cListBox,cListInd,cFiltro,oWizard,nOpc)
//Local lRet:=.T.

//Return lRet

Static Function GPRPl05(cCodPQ,aEntidade,oListBox,aIndice,oListInd,cFiltro,nOpc)
Local lRet		:= .T.
Local aArea 	:= GetArea()    // Salva a area atual
Local nReg		:= 0
Local nSaveSx8 	:= GetSX8Len()                      // Funcao de numeracao
Local nPosEnt	:= Ascan( oListBox:aArray, {|X| X[1]}) // Qual das Entidades foi selecionad 
Local nPosInd	:= Ascan( oListInd:aArray, {|X| X[1]}) // Qual dos Indices foi selecionad

BEGIN TRANSACTION

dbSelectArea("SKL")
If nOpc=4
	RecLock("SKL",.F.)
Else	
	RecLock("SKL",.T.)
	KL_CODIGO 	:= GetSxeNum("SKL","KL_CODIGO")
EndIf
KL_FILIAL 	:= xFilial("SKL")
KL_TABELA	:= oListBox:aArray[nPosEnt][3]
KL_ORDEM    := oListInd:aArray[nPosInd][2]
KL_CODFLT   := MSMM(SKL->KL_CODFLT,,,cFiltro,1,,,"SKL","KL_CODFLT")
KL_CODPQ	:= cCodPQ
MsUnLock()

END TRANSACTION 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para gravacao dos itens da lista                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GPRProcLst(SKL->KL_CODIGO,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirmar os numeros utilizados                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (GetSx8Len() > nSaveSx8)
	ConfirmSX8()
End	

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPR012Ent ³ Autor ³ Marcos Alves          ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta das tabelas T5 e T8, para se utilizado na          ³±±
±±³          ³consulta SXB                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAGPR - SXB (GP1)                             		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPR012Ent()

Local oDlgEnt            								   // Tela
Local oListBox                                             // Listbox
Local nPosBox  	 := 3                                      // Posicao do List
Local nPos       := 0                                      // Posicao no array
Local lRet    	 := .F.                                    // Retorno da funcao
Local aEntidade  := {{.F.,"","",""}}                       // Array da ListBox)
Local oOk        := LoadBitmap(GetResources(), "LBOK")     // Desenho do Checked
Local oNo        := LoadBitmap(GetResources(), "LBNO")     // Desenho do Not Checked

DEFINE MSDIALOG oDlgEnt FROM  50,003 TO 260,500 TITLE "Lista tas tabelas" PIXEL  //

	//@ 03,10  LISTBOX oListBox VAR nPosBox Fields HEADER "","Entidade"+Space(30),Substr("Apelido",1,30) SIZE 280,130 OF oDlgEnt PIXEL NOSCROLL 
	@ 03,10  LISTBOX oListBox VAR nPosBox Fields HEADER "Entidade"+Space(30),Substr("Apelido",1,30) SIZE 280,130 OF oDlgEnt PIXEL //NOSCROLL 

	oListBox:SetArray(aEntidade)
	oListBox:bLine      := { || { aEntidade[oListBox:nAt,2],aEntidade[oListBox:nAt,3]} }
    oListBox:BlDblClick := { || (lRet:= .T.,nPos:= oListBox:nAt, oDlgEnt:End())}
	oListBox:Refresh()
	
    DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgEnt ACTION (lRet:= .T.,nPos := oListBox:nAt,oDlgEnt:End())
    DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgEnt ACTION (lRet:= .F.,oDlgEnt:End())

ACTIVATE MSDIALOG oDlgEnt CENTERED ON INIT GPR012Entidade(aEntidade,oListBox,oOk,oNo,0)

If lRet
   DbSelectarea("SX2")
   DbSetorder(1)
   DbSeek(aEntidade[nPos][3])
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³GPR012Ind ³ Autor ³ Marcos Alves          ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta dos indices das entidades selecionadas.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAGPR - SXB (GP2)                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPR012Ind()

Local oDlgInd            								   // Tela
Local oListInd                                             // ListBox dos Indices da tabela
Local nPosBox  	 := 3                                      // Posicao do List
Local nPos       := 0                                      // Posicao no array
Local lRet    	 := .F.                                    // Retorno da funcao
Local aIndice     := {{"",""}}					       //Array da ListBoxdos Indices da entidade selecionada
Local oOk        := LoadBitmap(GetResources(), "LBOK")     // Desenho do Checked
Local oNo        := LoadBitmap(GetResources(), "LBNO")     // Desenho do Not Checked

DEFINE MSDIALOG oDlgInd FROM  50,003 TO 260,500 TITLE "Lista das ordem" PIXEL  //
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a configuracao da ListBox dos indicesda entidade selecionada        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 03,10  LISTBOX oListInd VAR cListInd Fields HEADER "Ordem","Chave"+space(30) SIZE 280,130 OF oDlgInd PIXEL 
	oListInd:SetArray(aIndice)
	oListInd:bLine      := { || { aIndice[oListInd:nAt,1],aIndice[oListInd:nAt,2]} }
    oListInd:BlDblClick := { || (lRet:= .T.,nPos:= oListInd:nAt, oDlgInd:End())}
	oListInd:Refresh()
	
    DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgInd ACTION (lRet:= .T.,nPos := oListInd:nAt,oDlgInd:End())
    DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgInd ACTION (lRet:= .F.,oDlgInd:End())

ACTIVATE MSDIALOG oDlgInd CENTERED ON INIT GPR012Indice(M->KL_TABELA,aIndice,oListInd,oOk,oNo,0)

If lRet
   DbSelectarea("SIX")
   DbSetorder(1)
   DbSeek(M->KL_TABELA+aIndice[nPos][2])
Endif

Return(lRet)

Function GPRA012Exp(cAlias,cFiltro, cCampo)
Local lRet	:= .T.

If !Empty(M->KL_FILTRO)
	cFiltro:=M->KL_FILTRO
EndIf

If Empty(cAlias)
  MsgInfo("Endidade nao foi identificada")
  Return .F.
EndIf

If ReadVar()<>cCampo
	MsgInfo("função nao disponivel para este campo")
	Return .F.
EndIf

cFiltro:=BuildExpr(cAlias,,@cFiltro,.T.)
If !Empty(cFiltro)
	M->KL_FILTRO := cFiltro
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPRProcLst ³Autor  ³ Marcos Alves         ³ Data ³ 07/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de geracaod dos itens da lista                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPRProcLst(cCodLst,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodLst = Codigo da lista                                  ³±±
±±³          ³ nOpc    = Tipo de tratamento, sendo:                       ³±±
±±³          ³           0 - Assistente                                   ³±±
±±³          ³           1 - Pesquisar                                    ³±±
±±³          ³           2 - Visualizar                                   ³±±
±±³          ³           3 - Incluir                                      ³±±
±±³          ³           4 - Alterar                                      ³±±
±±³          ³           5 - Excluir                                      ³±±
±±³          ³           7 - Legenda                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGPR                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPRProcLst(cCodLst,nOpc)
Local lRet		:= .T.      	// Variavel do Retorno da funcao
Local aArea 	:= GetArea()    // Salva a area atual
Local nReg		:= 0            // Contador de registro da query
Local cQuery    := ""			// Variavel da query
Default nOpc	:= 0

dbSelectArea("SKL")
dbSeek(xFilial("SKL")+cCodLst)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da query                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SIX->(dbSeek(SKL->KL_TABELA+SKL->KL_ORDEM))
cQuery:="SELECT "
cQuery+=SIX->CHAVE+" IDLST "
cQuery+="FROM "
cQuery+=RetSqlName(KL_TABELA)
cQuery+="WHERE "+ Alltrim(MSMM(SKL->KL_CODFLT)) + " AND "
cQuery+="D_E_L_E_T_ <> '*'                 "

cQuery := ChangeQuery(cQuery)
MsgRun("Lendo entidade selecionada, Aguarde...","Gerando lista para a pesquisa:"+SKL->KL_CODPQ ,{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.F.)}) 
nReg:=Select("TRB")

If nReg=0
    lRet:=.F.
EndIf
If nOpc=4 //Alteracao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice 1 do Arquivo de Trabalho com a nova lista gerada             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cInd1TRB := CriaTrab(Nil, .F.)
	IndRegua("TRB",cInd1TRB,"IDLST",,,"Indexando Arquivo de Trabalho")  //"Indexando Arquivo de Trabalho"
	dbClearIndex()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar se os registros gerados ja estao na lista gerada (SKM)         ³
	//³ os registro da lista antiga que nao estiverem na nova lista terao que ser³
	//³ deletados para ser incluidos os novos registros                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("SKM")
    dbSetOrder(1)
    dbSeek(xFilial("SKM")+SKL->KL_CODIGO)
	While !SKM->(eof()) .AND. SKM->KM_FILIAL==xFilial("SKM") .AND. SKM->KM_CODLST==SKL->KL_CODIGO
 		If !TRB->(dbSeek(SKM->KM_IDLST))
			RecLock("SKM",.F.)
			SKM->(dbDelete())
		EndIf
		SKM->(dbSkip())			
	End	
EndIf

TRB->(dbGoTop())
// Controle de Regua para exibicao
ProcRegua(nReg)

BEGIN TRANSACTION 
While !TRB->(eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso seja inclusao (nOpc=3), ou o registro da query nao esta na lista    ³
	//³ atual, incluir novo registro na tabela.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nOpc=3 .OR.!SKM->(dbSeek(xFilial("SKM")+SKL->KL_CODIGO+TRB->IDLST))
		RecLock("SKM",.T.)
		SKM->KM_FILIAL	:= xFilial("SKM")
		SKM->KM_CODLST	:= SKL->KL_CODIGO
		SKM->KM_IDLST	:= TRB->IDLST
		SKM->(MsUnLock())
		DbCommit()
    EndIf
	TRB->(dbSkip())
	// Movimentando a Barra
	IncProc("Aguarde... Gravando elementos na lista...")
End
END TRANSACTION 
TRB->(dbCloseArea())

RestArea(aArea)
Return lRet
