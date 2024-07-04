#include "pmsc140.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#include "pmsicons.ch"

Static aBrowse		:= {}
Static aRecNo		:= {}
Static lMark		:= .T.
Static cAliasOrig	:= ""
Static nRecNoOrig	:= 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSC140  ³ Autor ³ Totvs                 ³ Data ³ 07/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de EDT/Tarefas Selecionadas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC140()

If AMIIn(44) .And. !PMSBLKINT()
	PRIVATE cCadastro	:= STR0001		//"Consulta de EDT/Tarefa"
	PRIVATE aRotina		:= MenuDef()
	PRIVATE	aCores		:= PmsAF8Color()

	mBrowse( 6, 1, 22, 75, "AF8",,,,,, aCores )
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS140Leg³ Autor ³ Totvs                  ³ Data ³ 07-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exibicao de Legendas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC140Leg( cAlias, nReg, nOpcx )
Local i       	:= 0
Local aLegenda	:= {}

For i := 1 To Len( aCores )
	aAdd( aLegenda, { aCores[i,2], aCores[i,3] } )
Next

aLegenda := aSort( aLegenda,,, { |x,y| x[1] < y[1] } )
BrwLegenda( cCadastro, STR0004, aLegenda ) //"Legenda"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC140Dlg³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta ao Sistema de Informacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC140Dlg(cAlias,nReg,nOpcx)
Local aAreaAF8		:= AF8->( GetArea() )
Local cSavCadastro	:= cCadastro
Local oDlg
Local oTree
Local oMenu
Local cArquivo		:= CriaTrab(,.F.)

PRIVATE cRevisa		:= AF8->AF8_REVISA

cCadastro := STR0005 //"Consulta de EDT/Tarefa Filhas"

aMenu := {;
{TIP_PROJ_INFO, {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},; //"Informacoes do Projeto..."
{TIP_PROJ_CONSULTAS, {|| PMSC140MS( @oTree, cArquivo ) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS}} //"&Consultar"

aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
A200ChkPln(@aCampos)
PmsPlanAF8(cCadastro,cRevisa,aCampos,@cArquivo,,,,aMenu,@oDlg,,.F.,,.T.)

cCadastro := cSavCadastro

RestArea( aAreaAF8 )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Totvs                 ³ Data ³ 07/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,	"AxPesqui"   ,0 ,1 },; 			//"Pesquisar"
						{ STR0003,	"PMSC140Dlg" ,0 ,2 },; 			//"Consulta"
						{ STR0004,	"PMSC140Leg" ,0 ,2,,.F. }} 	//"Legenda"
Return( aRotina )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC140Pg  ³ Autor ³ Totvs                 ³ Data ³ 07-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre tela com perguntas da rotina PMSC140                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC140                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC140Pg
	Pergunte("PMA200",.T.)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSC140MS ³ Autor ³ Totvs                 ³ Data ³ 07-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta uma consulta das EDTs/Tarefas filhas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC140                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC140MS( oTree, cArquivo )
Local oDlg
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView		:= {}
Local aItens	:= {}
Local aColName	:= { "", STR0006, STR0007, STR0008, STR0009, STR0010 }
Local aColTam	:= { 10, 100, 150, 50, 30, 30 }
Local nInc		:= 0
Local oChkMark

// Limpa o array de navegacao
aBrowse		:= {}

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ! (cAlias $ "AFC|AF9")
	Aviso( STR0011, STR0012, { STR0013 },2) //"Atencao!"###"Selecao invalida. Selecione uma EDT ou uma Tarefa." //'Ok'
	Return
EndIf

// se o registro não estiver posicionado
If !( nRecView == NIL .OR. Empty( nRecView ) ) .AND. !( (cAlias)->( RecNo() ) == nRecView )
	(cAlias)->( DbGoto( nRecView ) )
EndIf

// Armazena o alias e recno de origem da consulta
cAliasOrig	:= cAlias
nRecNoOrig	:= (cAlias)->( RecNo() )

aSize := MsAdvSize(,.F.,400)
aObjects := {}
aAdd( aObjects, { 100, 100 , .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

If cAlias=="AF9"
	aItens := PC140EdtPredec( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA )
ElseIf cAlias=="AFC"
	aItens := PC140EdtFilhos( AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT )
EndIf

// Se nao houver itens a serem exibidos, abre a visualizacao do cadastro
If Empty( aItens )
	If cAlias == "AF9"
		PMSA203(2,,"000",,,,,,,,@lRefresh)
	ElseIf cAlias == "AFC"
		PMSA201(2,,"000",@lRefresh)
	EndIf
	
	Return
EndIf

For nInc := 1 To Len( aItens )
	aAdd( aView, { 	PmsRetRes( aItens[nInc][6][1], aItens[nInc][6][2] ),; // 01-Imagem da edt/tarefa
					aItens[nInc][3],;										// 02-Codigo
					aItens[nInc][4],;										// 03-Descricao
					Transform(aItens[nInc][5],"@E 999,999,999,999.99"),;	// 04-Perc. Execucao
					DtoC( aItens[nInc][7] ),;								// 05-Data Inicio
					DtoC( aItens[nInc][8] ),;								// 06-Data Termino
					aItens[nInc][6],;										// 07-Alias e Recno de controle
					{ cAlias, (cAlias)->( RecNo() ) } } )					// 08-Alias e Recno de controle
Next

// Adiciona o primeiro nivel no array para navegacao pelos botoes
aAdd( aBrowse, aClone( aView ) )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oView := TWBrowse():New( 4, 4, aPosObj[1,4]-6, aPosObj[1,3]-aPosObj[1,1]-6,, aColName, aColTam, oDlg, ,,,,,,,,,,, .F.,, .T.,, .F.,,, )
oView:SetArray( aView )
oView:bLine 		:= { || oView:aArray[oView:nAT] }
oView:bLDblClick	:= { || actButton( oView, 3 ) }

// Exibir EDT/Tarefas finalizadas
oChkMark := TCheckBox():New( aPosObj[1,3]-2, 212, STR0018, NIL,oDlg,300,10,, { || PC140Refresh( oView ) },,,,,,.T.) //"Exibir EDT/Tarefas finalizadas"

oChkMark:cVariable 	:= "lMark"
oChkMark:bSetGet 	:= { |x| IIf( PCount() > 0, lMark := x, lMark ) }

TButton():New( aPosObj[1,3]-4, 004, STR0014, oDlg, {|| actButton( oView, 1 )	},40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
TButton():New( aPosObj[1,3]-4, 046, STR0015, oDlg, {|| actButton( oView, 2 )	},40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
TButton():New( aPosObj[1,3]-4, 088, STR0016, oDlg, {|| actButton( oView, 4 )	},40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
TButton():New( aPosObj[1,3]-4, 130, STR0017, oDlg, {|| oDlg:End() 				},40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)

ACTIVATE MSDIALOG oDlg CENTER

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³actButton ³ Autor ³ Totvs                 ³ Data ³ 08-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela acao dos botoes.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC140                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function actButton( oView, nOpc )
Local aAreaAF9		:= AF9->( GetArea() )
Local aAreaAFC		:= AFC->( GetArea() )
Local aBrwAux		:= {}
Local aBrwFiltro	:= {}
Local aItens		:= {}
Local aView			:= {}
Local cAlias		:= ""
Local nRecNo		:= 0
Local nInc			:= 0
Local nLinAux		:= 0
Local nPosAnt		:= 0

Do Case
	Case nOpc == 1 // Atualiza o browse com o primeiro nivel selecionado
		oView:SetArray( aBrowse[1] )
		oView:bLine := { || aBrowse[1][oView:nAT] }

		// Libera os itens anterioes da memoria e sem deixar posicoes nulas
		aAdd( aBrwAux, aClone( aBrowse[1] ) )
		aBrowse := aClone( aBrwAux )

		PC140Refresh( oView )

	Case nOpc == 2 // Atualiza o browse com o nivel anterior
		If Len( aBrowse ) > 0
			nPosAnt := Len( aBrowse )-1
			If nPosAnt <= 0
				nPosAnt := 1
			EndIf

			oView:SetArray( aBrowse[nPosAnt] )
			oView:bLine := { || aBrowse[nPosAnt][oView:nAT] }
		EndIf

		// Libera os itens anterioes da memoria e sem deixar posicoes nulas
		aAdd( aBrwAux, aClone( aBrowse[1] ) )
		For nInc := 2 To nPosAnt
			aAdd( aBrwAux, aClone( aBrowse[nInc] ) )
		Next
		aBrowse := aClone( aBrwAux )

		PC140Refresh( oView )

	Case nOpc == 3 // Atualiza o browse com mais um nivel
		cAlias 	:= oView:aArray[ oView:nAT ][7][1]
		nRecNo	:= oView:aArray[ oView:nAT ][7][2]

		If cAlias == "AF9"
			AF9->( DbGoTo( nRecNo ) )
			aItens := PC140EdtPredec( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA )
		ElseIf cAlias == "AFC"
			AFC->( DbGoTo( nRecNo ) )
			aItens := PC140EdtFilhos( AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT )
		EndIf

		For nInc := 1 To Len( aItens )
			aAdd( aView, { 	PmsRetRes( aItens[nInc][6][1], aItens[nInc][6][2] ),; // 01-Imagem da edt/tarefa
							aItens[nInc][3],;										// 02-Codigo
							aItens[nInc][4],;										// 03-Descricao
							Transform(aItens[nInc][5],"@E 999,999,999,999.99"),;	// 04-Perc. Execucao
							DtoC( aItens[nInc][7] ),;								// 05-Data Inicio
							DtoC( aItens[nInc][8] ),;								// 06-Data Termino
							aItens[nInc][6],;										// 07-Alias e Recno de controle
							{ cAlias, (cAlias)->( RecNo() ) } } )					// 08-Alias e Recno de controle
		Next

		// Adiciona o primeiro nivel no array para navegacao pelos botoes
		If !Empty( aView )
			aAdd( aBrowse, aClone( aView ) )

			oView:SetArray( aView )
			oView:bLine := { || oView:aArray[oView:nAt] }
		Else
			If cAlias == "AF9"
				PMSA203(2,,"000",,,,,,,,@lRefresh)
			ElseIf cAlias == "AFC"
				PMSA201(2,,"000",@lRefresh)
			EndIf
		EndIf

	Case nOpc == 4 // Visualiza cadastro da EDT/Tarefa
		cAlias 	:= oView:aArray[ oView:nAT ][7][1]
		nRecNo	:= oView:aArray[ oView:nAT ][7][2]

		If cAlias == "AFC"
			AFC->( DbGoTo( nRecNo ) )
			PMSA201(2,,"000",@lRefresh)
		ElseIf cAlias == "AF9"
			AF9->( DbGoTo( nRecNo ) )
			PMSA203(2,,"000",,,,,,,,@lRefresh)
		EndIf
EndCase

oView:Refresh()

RestArea( aAreaAF9 )
RestArea( aAreaAFC )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PC140Refresh  ³ Autor ³ Totvs              ³ Data ³ 08-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o array com as edt/tarefa predecessoras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC140                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PC140Refresh( oView )
Local aItens	:= {}
Local aView		:= {}
Local cAlias	:= cAliasOrig
Local nRecNo	:= nRecNoOrig
Local nInc		:= 0

If Len( oView:aArray ) > 0
	// Pega fixo pois a origem eh a mesma
	cAlias	:= oView:aArray[1][8][1]
	nRecNo	:= oView:aArray[1][8][2]
EndIf

If cAlias == "AF9"
	AF9->( DbGoTo( nRecNo ) )
	aItens := PC140EdtPredec( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA )
ElseIf cAlias == "AFC"
	AFC->( DbGoTo( nRecNo ) )
	aItens := PC140EdtFilhos( AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT )
EndIf

For nInc := 1 To Len( aItens )
	aAdd( aView, { 	PmsRetRes( aItens[nInc][6][1], aItens[nInc][6][2] ),; // 01-Imagem da edt/tarefa
					aItens[nInc][3],;										// 02-Codigo
					aItens[nInc][4],;										// 03-Descricao
					Transform(aItens[nInc][5],"@E 999,999,999,999.99"),;	// 04-Perc. Execucao
					DtoC( aItens[nInc][7] ),;								// 05-Data Inicio
					DtoC( aItens[nInc][8] ),;								// 06-Data Termino
					aItens[nInc][6],;										// 07-Alias e Recno de controle
					{ cAlias, (cAlias)->( RecNo() ) } } )					// 08-Alias e Recno de controle
Next

If !Empty( aView )
	oView:SetArray( aView )
	oView:bLine := { || oView:aArray[oView:nAt] }
	oView:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PC140EdtPredec³ Autor ³ Totvs              ³ Data ³ 08-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as edt/tarefa predecessoras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC140                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PC140EdtPredec( cProjeto, cRevisa, cTarefa, lTaskAll, aPredecs )
Local aAreaAFD 	:= {}
Local aAreaAJ4 	:= {}
Local aAreaAF9 	:= {}
Local aAreaAFC 	:= {}
Local aAreaAFF 	:= {}
Local aAreaAFQ 	:= {}
Local nFisReal 	:= 0

DEFAULT aPredecs := {}
DEFAULT lTaskAll := lMark

// relacionamento tarefa-tarefa do projeto
DbselectArea( "AFD" )
aAreaAFD := AFD->( GetArea() )
AFD->( dbSetOrder( 1 ) )
AFD->( dbSeek( xFilial( "AFD" ) + cProjeto + cRevisa + cTarefa ) )
While AFD->( !Eof() ) .AND. xFilial( "AFD" ) + cProjeto + cRevisa + cTarefa == AFD->( AFD_FILIAL + AFD_PROJET + AFD_REVISA + AFD_TAREFA )
	// Tarefas do Projeto
	DbselectArea( "AF9" )
	aAreaAF9 := AF9->( GetArea() )
	AF9->( dbSetOrder( 1 ) )
	AF9->( dbSeek( xFilial( "AF9" ) + cProjeto + cRevisa + AFD->AFD_PREDEC ) )

	nFisReal := 0

	// Progresso fisico por data da tarefa
	DbselectArea("AFF")
	aAreaAFF := AFF->( GetArea() )
	AFF->( dbSetOrder( 1 ) )
	AFF->( dbSeek( xFilial( "AFF" ) + cProjeto + cRevisa + AF9->AF9_TAREFA ) )
	While AFF->( !Eof() ) .AND. xFilial( "AFF" ) + cProjeto + cRevisa + cTarefa == AFF->( AFF_FILIAL + AFF_PROJET + AFF_REVISA + AFF_TAREFA )
		nFisReal := AFF->AFF_PERC
		AFF->( dbSkip() )
	End

	RestArea( aAreaAFF )

	If !lTaskAll
		If nFisReal < 100
			aAdd( aPredecs, { AFD->AFD_PROJET,AFD->AFD_REVISA, AFD->AFD_PREDEC,AF9->AF9_DESCRI,nFisReal, { "AF9", AF9->( RecNo() ) }, AF9->AF9_START, AF9->AF9_FINISH })
			PC140EdtPredec( AFD->AFD_PROJET, AFD->AFD_REVISA, AFD->AFD_PREDEC, lTaskAll, aPredecs )
		EndIf
	Else
		aAdd( aPredecs, { AFD->AFD_PROJET,AFD->AFD_REVISA, AFD->AFD_PREDEC,AF9->AF9_DESCRI,nFisReal, { "AF9", AF9->( RecNo() ) }, AF9->AF9_START, AF9->AF9_FINISH })
		PC140EdtPredec( AFD->AFD_PROJET, AFD->AFD_REVISA, AFD->AFD_PREDEC, lTaskAll, aPredecs )
	EndIf

	RestArea(aAreaAF9)

	AFD->( DbSkip() )
End

RestArea(aAreaAFD)

// relacionamento tarefa-EDT do projeto
DbselectArea("AJ4")
aAreaAJ4 := AJ4->(GetArea())
AJ4->( dbSetOrder( 1 ) )
AJ4->( dbSeek( xFilial( "AJ4" ) + cProjeto + cRevisa + cTarefa ) )
While AJ4->( !Eof() ) .AND. xFilial( "AJ4" ) + cProjeto + cRevisa + cTarefa == AJ4->( AJ4_FILIAL + AJ4_PROJET + AJ4_REVISA + AJ4_TAREFA )
	// EDT do Projeto
	DbselectArea( "AFC" )
	aAreaAFC := AFC->( GetArea() )
	AFC->( dbSetOrder( 1 ) )
	AFC->( dbSeek( xFilial( "AFC" ) + cProjeto + cRevisa + AJ4->AJ4_PREDEC ) )

	nFisReal := 0
	// Progresso fisico por data da EDT
	DbselectArea("AFQ")
	aAreaAFQ := AFQ->(GetArea())
	AFQ->( dbSetOrder( 1 ) )
	AFQ->( dbSeek( xFilial( "AFQ" ) + cProjeto + cRevisa + AJ4->AJ4_PREDEC ) )
	While AFQ->( !Eof() ) .AND. xFilial( "AFQ" ) + cProjeto + cRevisa + AJ4->AJ4_PREDEC == AFQ->( AFQ_FILIAL + AFQ_PROJET + AFQ_REVISA + AFQ_TAREFA )
		nFisReal := AFQ->AFQ_PERC
		AFQ->( dbSkip() )
	End
	RestArea(aAreaAFQ)

	If !lTaskAll
		If nFisReal < 100
			aAdd( aPredecs, { AJ4->AJ4_PROJET,AJ4->AJ4_REVISA, AJ4->AJ4_PREDEC, AFC->AFC_DESCRI,nFisReal, { "AFC", AFC->( RecNo() ) }, AFC->AFC_START, AFC->AFC_FINISH })
		EndIf
	Else
		aAdd( aPredecs, { AJ4->AJ4_PROJET,AJ4->AJ4_REVISA, AJ4->AJ4_PREDEC, AFC->AFC_DESCRI,nFisReal, { "AFC", AFC->( RecNo() ) }, AFC->AFC_START, AFC->AFC_FINISH })
	EndIf

	RestArea(aAreaAFC)

	AJ4->( DbSkip() )
End

RestArea( aAreaAJ4 )

aSort( aPredecs,,, { |x,y| x[3] < y[3] } )

Return aPredecs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PC140EdtFilhos³ Autor ³ Totvs              ³ Data ³ 07-06-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as edt/tarefa filhos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC140                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PC140EdtFilhos( cProjeto, cRevisa, cEDT, lTaskAll )
Local aAreaAF9 	:= {}
Local aAreaAFC 	:= {}
Local aAreaAFF 	:= {}
Local aAreaAFQ 	:= {}
Local aRet		:= {}
Local nFisReal 	:= 0

DEFAULT lTaskAll := lMark

// Tarefas do Projeto
DbselectArea( "AF9" )
aAreaAF9 := AF9->( GetArea() )

AF9->( DbSetOrder( 2 ) )
AF9->( DbSeek( xFilial( "AF9" ) + cProjeto + cRevisa + cEDT ) )
While AF9->( !Eof() ) .AND. AF9->( AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI ) == xFilial( "AF9" ) + cProjeto + cRevisa + cEDT
	nFisReal := 0
	
	// Progresso fisico por data da tarefa
	DbSelectArea( "AFF" )
	aAreaAFF := AFF->( GetArea() )
	AFF->( DbSetOrder( 1 ) )
	AFF->( DbSeek( xFilial( "AFF" ) + cProjeto + cRevisa + AF9->AF9_TAREFA ) )
	While AFF->( !Eof() ) .AND. xFilial( "AFF" ) + cProjeto + cRevisa + AF9->AF9_TAREFA == AFF->( AFF_FILIAL + AFF_PROJET + AFF_REVISA + AFF_TAREFA )
		nFisReal := PMS310QT( .F., "AFF" )
		AFF->( DbSkip() )
	End

	RestArea(aAreaAFF)

	If !lTaskAll
		If nFisReal < 100
			aAdd( aRet, { AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, AF9->AF9_DESCRI, nFisReal, { "AF9", AF9->( RecNo() ) }, AF9->AF9_START, AF9->AF9_FINISH } )
		EndIf
	Else
		aAdd( aRet, { AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, AF9->AF9_DESCRI, nFisReal, { "AF9", AF9->( RecNo() ) }, AF9->AF9_START, AF9->AF9_FINISH } )
	EndIf

	AF9->( DbSkip() )
End
RestArea(aAreaAF9)

// EDT do Projeto
DbselectArea("AFC")
aAreaAFC := AFC->( GetArea() )
AFC->( DbSetOrder( 2 ) )
AFC->( DbSeek( xFilial( "AFC" ) + cProjeto + cRevisa + cEDT ) )
WHILE AFC->( !Eof() ) .AND. xFilial( "AFC" ) + cProjeto + cRevisa + cEDT == AFC->( AFC_FILIAL + AFC_PROJET + AFC_REVISA + AFC_EDTPAI )
	nFisReal := 0

	// Progresso fisico por data da EDT
	DbselectArea( "AFQ" )
	aAreaAFQ := AFQ->( GetArea() )
	AFQ->( DbSetOrder( 1 ) )
	AFQ->( DbSeek( xFilial( "AFQ" ) + cProjeto + cRevisa + cEDT ) )
	While AFQ->( !Eof() ) .AND. xFilial( "AFQ" ) + cProjeto + cRevisa + cEDT == AFQ->( AFQ_FILIAL + AFQ_PROJET + AFQ_REVISA + AFQ_EDT )
		nFisReal := PMS310QT( .F., "AFC" )
		AFQ->( DbSkip() )
	End

	RestArea(aAreaAFQ)

	If !lTaskAll
		If nFisReal < 100
			aAdd( aRet, { AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT, AFC->AFC_DESCRI, nFisReal, { "AFC", AFC->( RecNo() ) }, AFC->AFC_START, AFC->AFC_FINISH } )
		EndIf
	Else
		aAdd( aRet, { AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT, AFC->AFC_DESCRI, nFisReal, { "AFC", AFC->( RecNo() ) }, AFC->AFC_START, AFC->AFC_FINISH } )
	EndIf

	AFC->( DbSkip() )
End

RestArea(aAreaAFC)

aSort( aRet,,, { |x,y| x[3] < y[3] } )

Return aRet
