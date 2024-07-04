#INCLUDE "CTBS030.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TCBROWSE.CH"
#INCLUDE "ECD.CH"

//Compatibiliza็ใo de fontes 30/05/2018

Static __aPosField := NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBS030( cCodRev )
Local aArea			:= GetArea()

Local cFilter 		:= ""
Local uAlias
Local nButtonSize 	:= 35

Local bVisual 		:= {|| Visualiza( oDialog ) }
Local bPesquisa 	:= {|| Pesquisar( oDialog, oBrowse )}
Local bImprime		:= {|| Imprimir( oDialog, oTabs, dbfilter() )}
Local bExpExcel 	:= {|| ExportarExcel( uAlias, aCampos ), oBrowse:Gotop(), oBrowse:SetFocus() }
Local bSair			:= {|| RefreshIndex( uAlias ), oDialog:End() }

Local oDialog, oTabs, oBrowse

Private aBrowse 	:= {}
Private aEcdTab 	:= {}
Private aCampos 	:= {}
Private aUsados 	:= {}
Private aReturn 	:= {STR0009, 1,STR0010, 2, 2, 1,"",1}
Private aRet 		:= {}

Private cFiltro		:= ""

Private nWidth 		:= 640
Private nHeight 	:= 480

uAlias := Seleciona( oDialog, oTabs, .F., cFilter, cCodRev )

If uAlias == NIL .Or. (  ValType(uAlias) == "A" .And. Len(uAlias) == 0 )
	Return
EndIf

// oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDialog TITLE STR0001 FROM 00,00 TO nHeight,nWidth PIXEL OF oMainWnd //"Consulta Dados ECD"

// oDialog:lMaximized := .T.

@0,0 MSPANEL oBtnPanel PROMPT "" SIZE 14,14
oBtnPanel:Align := CONTROL_ALIGN_BOTTOM

@0,0 MSPANEL oPanel1 PROMPT "" SIZE 5,5
oPanel1:Align := CONTROL_ALIGN_BOTTOM

@08,00 TABS oTabs PROMPT uAlias OF oDialog ACTION ExibeForm(oTabs, oDialog, cFilter, cCodRev) SIZE 10,10

// Monta o Primeiro Browse do Primeiro TAB
oBrowse := MontaBrowse( oDialog, uAlias, {16,25, 600, 250},,, aCampos, cCodRev )

oDialog:cCaption += Iif(SX2->(DbSeek(uAlias))," - "+Capital( AllTrim( X2Nome() ) ),"")
aAdd( aBrowse, {oBrowse, uAlias, Aclone(aCampos), Aclone(aUsados) })

oTabs:SetOption(1)

If ( ValType(oBrowse) == 'O' )
	oBrowse:Gotop()
	oBrowse:Refresh()
	
	SetFocus( oBrowse:hWnd )
EndIf

oTabs:Align := CONTROL_ALIGN_BOTTOM

TButton():New( 1, 1+((1-1)*nButtonSize), STR0002	, oBtnPanel , bPesquisa	, nButtonSize, 12,,oDialog:oFont, .F., .T., .F.,, .F.,, ) //"&Pesquisa"
TButton():New( 1, 2+((2-1)*nButtonSize), STR0003	, oBtnPanel , bImprime  , nButtonSize, 12,,oDialog:oFont, .F., .T., .F.,, .F.,, ) // //"&Impressใo"
TButton():New( 1, 3+((3-1)*nButtonSize), STR0004	, oBtnPanel , bVisual	, nButtonSize, 12,,oDialog:oFont, .F., .T., .F.,, .F.,, ) // //"&Visualizar"

If RemoteType() == 1 // Apenas para cliente windows
	TButton():New( 1, 4+((4-1)*nButtonSize), STR0005, oBtnPanel , bExpExcel , nButtonSize, 12,,oDialog:oFont, .F., .T., .F.,, .F.,, ) //"&Exp.Excel"
	TButton():New( 1, 5+((5-1)*nButtonSize), STR0006	, oBtnPanel , bSair  , nButtonSize, 12,,oDialog:oFont, .F., .T., .F.,, .F.,, ) //"&Sair"
Else
	TButton():New( 1, 4+((4-1)*nButtonSize), STR0006	, oBtnPanel , bSair  , nButtonSize, 12,,oDialog:oFont, .F., .T., .F.,, .F.,, ) //"&Sair"
EndIf

If !Empty(oBrowse)
	oBrowse:Refresh()
	SetFocus(oBrowse:hWnd)
EndIf

ACTIVATE MSDIALOG oDialog CENTER ON INIT ( RestConsulta( uAlias, @oTabs, oDialog, @oBrowse, .T. ) )

//Efetua atualiza็ใo para o index original
RefreshIndex(uAlias)

RestArea( aArea )

//atribui NIL para variavel static que contem posicao dos campos - FIELDPOS
__aPosField := NIL

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Visualiza(oWin)
Local aArea	:= GetArea()

Private cCadastro	:= oWin:cTiTle
Private aRotina		:=	{{"","",0,1},;
{"","",0,2},;
{"","",0,3},;
{"","",0,4},;
{"","",0,5} }

oWin:Disable()

AxVisual( Alias(), Recno(), 1, aUsados,,)

oWin:Enable()

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RestConsulta( aCons, oTabs, oWin, oBrowse, lDiv)
Local i
Default lDiv := .F.

CursorWait()

If ValType(aCons) != "A"
	Return .t.
EndIf

For i := 1 to Len(aCons)
	// Posiciona no Arquivo
	DbSelectArea(aCons[i][1])
	// Muda o Ordem
	DbSetOrder(aCons[i][2])
	// Set o Filtro
	cFiltro:= aCons[i][3]
	
	Set Filter To &cFiltro
	
	If Len(oTabs:aPrompts) < i
		// Adiciona novo TAB
		oTabs:AddItem(aCons[i][1])
	Else
		oTabs:aPrompts[i] := aCons[i][1]
	EndIf
	
	// Monta o Browse para este TAB
	Browser(oWin,aCons[i][1],oTabs,aCons[i][4],@oBrowse,.F.)
Next i

// Posiciona no primeiro TAB
DbSelectArea(aCons[1][1])
oTabs:SetOption(1)
aBrowse[1][1]:Refresh(.F.)

CursorArrow()
SysRefresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Seleciona(oWin, oTabs, lSalva, cFilter, cCodRev )
Local oDlg
Local oLbx
Local oDel
Local oSav
Local nOAt := 0
Local lOK := .F.
Local cRet
Local aConsulta
Local cLine := "CS0/CS1/CS2/CS3/CS4/CS5/CS6/CS7/CS8/CS9/CSA/CSB/CSC/CSD/CSE/CSF/CSG/CSH/CSI/CSX/CSY/CSJ/CSK/CSL/CSM/CSN/CSO/CSZ/CSP/CSR/CST/CSS"
Local nPosLbx
Local cPesq := Space(20)
Local oPesq
Local nPosArq
Local i
Local cChave	

// Monta array com os dados do SX2
If Len(aEcdTab) == 0
	DbSelectArea("SX2")
	SX2->(DbGoTop())
	
	While SX2->(!Eof())
		cChave	:= FWX2CHAVE()
		If cChave $ cLine
			CHKFILE(cChave)
			aAdd(aEcdTab,{cChave,AllTrim( SX2->(X2Nome()) ),.F.})
		EndIf
		
		DbSelectArea("SX2")
		SX2->(DbSkip())
	EndDo
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO 350,640 TITLE STR0007 + cCodRev PIXEL //"Consulta dos dados da ECD - Revisใo: "

@20,05 LISTBOX oLbx FIELDS HEADER "", STR0008 OF oDlg PIXEL SIZE 310,150 ; //"Tabelas de Consulta"
ON DBLCLICK ( If(ValidaUso(aEcdTab[oLbx:nAt,1]),( lOk := ValidSelect(@aEcdTab,oLbx:nAt,oDel),nPosLbx:=oLbx:nAt,oDlg:End() )	,))

oLbx:SetArray(aEcdTab)
oLbx:bLine := {|| {aEcdTab[oLbx:nAt,1],aEcdTab[oLbx:nAt,2]}}

@06,05 SAY OemToAnsi(STR0011) SIZE 25,10 OF oDlg PIXEL
@05,35 MSGET oPesq VAR cPesq SIZE 200,10 OF oDlg PIXEL PICTURE "@!" ;
VALID ( nPosArq := SelecPesq(cPesq, oLbx), If( nPosArq # 0,oLbx:nAt := nPosArq, MsgStop(OemtoAnsi(STR0012))),oLbx:Refresh(),If(nPosArq#0,nPosLbx:=nPosArq,),(nPosArq#0))

// Define Botao Confirma
DEFINE SBUTTON FROM 05,290 TYPE 1 Enable OF oDlg ;
ACTION ( If(ValidaUso(aEcdTab[oLbx:nAt,1]),( lOk := ValidSelect( @aEcdTab, oLbx:nAt, oDel ), nPosLbx := oLbx:nAt, oDlg:End() ),))

// Define Botao Cancelar
DEFINE SBUTTON FROM 05,260 TYPE 2 Enable OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED VALID (nOAt := oLbx:nAt,.T.)

If lOK
	// Monta os TABS da Consulta … Restaurar
	If aConsulta # nil
		If oTabs # nil
			// Apaga todos os outros TABS se existirem
			For i:=Len(oTabs:aPrompts) To 1 STEP -1
				// Posiciona no TAB
				oTabs:SetOption(i)
				// Apaga o TAB
				oTabs:DelItem()
				// Atualiza flag de TAB
				oTabs:nOption := Len(oTabs:aPrompts)
				
				// Destroi o Browse utilizado pelo arquivo
				aBrowse[i][1]:End()
				// Retira o Browse da Pilha
				aDel(aBrowse,i)
				// Ajusta o tamanho da pilha
				aSize(aBrowse,Len(aBrowse)-1)
				// Ativa para ser escolhida novamente na Selecao
				aEcdTab[nOAt][3] := .F.		// nPosLbx
			Next
		EndIf
		
		Return aConsulta
	Else
		// VerIfica o Total de Tabs ja abertos
		If Len(aBrowse)+1 > 20
			Help(" ",1,"SOVINTE")
		Else
			// Pega o Alias escolhido
			cRet := aEcdTab[nPosLbx,1]
			If !Eof() .and. (cRet)->(Recno()) == 0
				(cRet)->(DbGoTop())
			EndIf
			
			If oTabs # NIL
				// Monta o Browse para este TAB
				Browser(oWin,cRet,oTabs)
				
				// Adiciona novo TAB
				oTabs:AddItem( cRet )
				
				// Set na opcao do TAB deste arquivo
				oTabs:SetOption(Len(aBrowse))
			EndIf
		EndIf
	EndIf
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidSelect( aEcdTab, nPos, oDel )
Local lRet := .T.

// Se ja foi selecionado, nao permite novamente
If aEcdTab[nPos][3]
	oDel:SetEnable()
	lRet := .F.
EndIf

aEcdTab[nPos][3] := .T.

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaBrowse(oWin,cAlias,aCoord,oBrow,lDic,aCampos, cCodRev )
Local oBrowse
Local nAlias
Local i
Local lUsado
Local lVazio	:= .F.
Local cField	:= ''
Local cBranch	:= ''
Local cCodFil 	:= CS0->CS0_FILIAL
Local cNomealias    := ""

nAlias := Select(cAlias)

Default aCoord 	:= {32, 4, 620, 230}
Default lDic 	:= .T.

// Se nao veio da alteracao do dicion rio,
If lDic
	If Empty(cCodFil)
		cCodFil := xFilial(cAlias)
	EndIf
	
	// Posiciona Alias
	DbSelectArea(cAlias)
	dbSetOrder(1)
	cIndex	:= CriaTrab(nil,.f.)
	
	If cAlias $ "CSH/CSI" 
		cChave  := (cAlias)->(IndexKey(1))
		cFiltro := cAlias+"_FILIAL == '" +xFilial(cAlias)+ "'
	Else
		cChave  := cAlias + "_FILIAL+" + cAlias + "_CODREV"
		cFiltro := cAlias + "_FILIAL == '" + cCodFil + "' .AND. " + cAlias+"_CODREV == '" + cCodRev + "'"
	EndIf
	
	IndRegua(cAlias,cIndex,cChave,,cFiltro)
	

	If LastRec() == 0
        //tratamento para o dbacess atualizar e subir a tabela
        cNomealias := retsqlname(cAlias)
        tcrefresh(cNomealias)
        dbgotop()
        sleep(10000)

        If LastRec() == 0
		    Tone(3000,1)
		    Help(" ",1,"NORECS")
        EndIf
	EndIf
	
	nAlias := Select()
	
	// Cria Objeto BROWSE
	cField := Iif(Empty(cFilial),Nil,cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL")
	cBranch := Iif(cField!=Nil,cCodFil,Nil)
	oMainWnd:ReadClientCoors()
	oBrowse:= TcBrowse():New(0,0,oMainWnd:nClientHeight/2,oMainWnd:nClientWidth/2,,,,oWin,cField,cBranch,cBranch,,{|| Visualiza(oWin)},,oWin:oFont,,,,,.F.,cAlias,.T.,,.F.,,,.F.)
	oBrowse:lDisablePaint := .T.
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowse:lLineDrag	:= .T.
	//oBrowse   := oBrowse:GetBrowse()
	// Posiciona Dicionario
	DbSelectArea("SX3")
	DbSetOrder(1)
	// Busca Arquivo
	DbSeek(cAlias)
	
	// Limpa Array de Usados
	aUsados := {}
	
	If Empty(aCampos)
		lVazio := .T.
	EndIf
	
	// Monta array com os campos do arquivo
	While !EOF() .And. (x3_arquivo == cAlias)
		If cNivel < X3_NIVEL  .or. X3_CONTEXT == "V"
			DbSkip()
			Loop
		EndIf
		If lVazio
			lUsado := x3Uso(X3_USADO)
		Else
			lUsado := !(Ascan(aCampos,X3_CAMPO)>0)
		EndIf
		If lUsado
			oBrowse:AddColumn( TCColumn():New( Trim(X3Titulo()), FieldWBlock( x3_campo, nAlias ),AllTrim(X3_PICTURE),,, If(X3_TIPO=="N","RIGHT","LEFT"), CalcFieldSize(X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_PICTURE,X3Titulo()), .F., .F.,,,, .F., ) )
			aAdd(aUsados,X3_CAMPO)
		EndIf
		
		aAdd(aCampos,{X3_CAMPO,X3Titulo(),lUsado,X3_ORDEM,X3_TAMANHO,AllTrim(X3_PICTURE),X3_TIPO,X3_DECIMAL})
		DbSkip()
	End
	
	oBrowse:lDisablePaint := .F.
	oBrowse:Reset()
Else
	
	// Atribui o browse de fundo no atual
	oBrowse := oBrow
	
	// Adiciona as colunas no Browse conforme o Uso
	For i := 1 to len(aCampos)
		If aCampos[i][3]
			oBrowse:AddColumn( TCColumn():New( Trim(aCampos[i][2]), FieldWBlock( aCampos[i][1], nAlias ),aCampos[i][6],,, If(aCampos[i][7]=="N","RIGHT","LEFT"), CalcFieldSize(aCampos[i][7],aCampos[i][5],aCampos[i][8],aCampos[i][6],aCampos[i][2]), .F., .F.,,,, .F., ) )
		EndIf
	Next i
	
EndIf

// Posiciona no Browse
DbSelectArea(cAlias)

Return oBrowse

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Browser(oWin, cAlias,oTabs,aCampos,oBrow,lDiv,cCodRev )
Local i,nElem,nSoma := 0
Local lUsado,lVazio:=.F.
Local aRestCampos,cPict45,cField, cBranch

Default aCampos := {}, lDiv := .T.

aRestCampos := Iif(Len(aCampos)>0,Aclone(aCampos),{})

// Se !Empty, Esta restaurando uma consulta.
If !Empty(aRestCampos)
	aCampos := {}
EndIf

If Empty(aCampos)
	lVazio := .T.
EndIf

DbSelectArea(cAlias)
Set Filter to (cAlias)->CODREV == cCodRev

If RecCount() == 0 .and. lVazio
	Tone(3000,1)
	Help(" ",1,"NORECS")
EndIf

nAlias := Select()

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias)
While !EOF() .And. (x3_arquivo == cAlias)
	
	If cNivel < X3_NIVEL  .or. X3_CONTEXT == "V"
		DbSkip()
		Loop
	EndIf
	
	If lVazio .and. Len(aRestCampos) == 0
		lUsado := x3Uso(X3_USADO)
		nElem := X3_ORDEM
	Else
		nElem := Ascan(aRestCampos,X3_CAMPO)
		lUsado := (nElem > 0)
		If !lUsado
			nSoma++
			nElem := RetAsc(Str(Len(ARestCampos)+nSoma),2,.T.)
		Else
			nElem := RetAsc(Str(nElem),2,.T.)
		EndIf
	EndIf
	
	aAdd(aCampos,{X3_CAMPO,X3Titulo(),lUsado,If(!lDiv,nElem,X3_ORDEM),X3_TAMANHO,Trim(X3_PICTURE),X3_TIPO,X3_DECIMAL})
	
	DbSkip()
End

DbSelectArea(cAlias)

ASORT(aCampos,,,{|x,y| x[4] < y[4] })
cField := Iif(Empty(cFilial),Nil,cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL")
cBranch:= Iif(cField!=Nil,xFilial(cAlias),Nil)

oMainWnd:ReadClientCoors()
oBrow := TcBrowse():New(0,0,oMainWnd:nClientHeight/2,oMainWnd:nClientWidth/2,,,,oWin,cField,cBranch,cBranch,,{|| Visualiza(oWin)},,oWin:oFont,,,,,.F.,cAlias,.T.,,.F.,,,.F.)
oBrow:lDisablePaint := .T.
oBrow:Align := CONTROL_ALIGN_ALLCLIENT

aRet := {}
For i := 1 to Len(aCampos)
	If aCampos[i][3]
		oBrow:AddColumn( TCColumn():New( Trim(aCampos[i][2]), FieldWBlock( aCampos[i][1], nAlias ),aCampos[i][6],,, If(aCampos[i][7]=="N","RIGHT","LEFT"), CalcFieldSize(aCampos[i][7],aCampos[i][5],aCampos[i][8],aCampos[i][6],aCampos[i][2]), .F., .F.,,,, .F., ) )
		aAdd(aUsados,aCampos[i][1])
		cPict45 := aCampos[i,6]+Space(45-Len(aCampos[i,6]))
		aAdd(aRet,StrZero(i,2)+" "+aCampos[i,2]+" "+"["+If(aCampos[i,3],"x"," ")+"]"+cPict45+aCampos[i,1]+StrZero(aCampos[i,5],3))
	EndIf
Next i

oBrow:lDisablePaint := .F.
oBrow:Reset()

// Adiciona na Pilha
aAdd(aBrowse,{oBrow,cAlias,aCampos,aUsados})

// Coloca o Foco
SetFocus(oBrow:hWnd)

// Posiciona no Arquivo
DbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Imprimir(oWin,oTab,cFilter)
Local nRegCorrente := RECNO()
Local cAlias := ALIAS()
Local titulo := Iif(SX2->(DbSeek(cAlias)),Capital( AllTrim( X2Nome() ) ),"")
Local tamanho:= " "
Local limite := 132
Local cDesc1
Local cDesc2 := ""
Local cDesc3 := ""
Local i
Local aOrd   := {}
Local cSvFilter := dbFilter()

Private aLinha := { }
Private nOrdem := indexord()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreenche campos utilizados para emissao dos Relatorios                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nomeprog := "CTBS030",nLastKey := 0

Private AParDef := {}

Set Filter To

oWin:DISABLE()

cDesc1 := titulo

cOrd   := If(SIX->(DbSeek(cAlias+STR(INDEXORD()))),Capital(SixDescricao())," ")

SIX->(DbSeek(cAlias+"1"))
While SIX->INDICE == cAlias
	aAdd(aOrd,Capital(SixDescricao()))
	SIX->(DbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega aReturn para passagem para SetPrint                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aReturn[7] := cFilter
aReturn[8] := nOrdem

If Len( aRet ) > 0
	For i := 1 to Len(aRet)
		aAdd(aReturn,aRet[i])
	Next i
EndIf

cbtxt	:= SPACE(10)
cbcont	:= 0
wnrel	:= "CTBS030"
cabec1	:= cDesc1
cabec2	:= Replicate("-",limite)
cabec3	:= " "
cString	:= cAlias
li		:= 80
m_pag	:= 1
nTam	:= 0

wnrel := SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,"G",,.T.)

If nLastKey = 27
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtiva a Janela Pai                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oWin:Enable()
	
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtiva a Janela Pai                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF Empty(cSvFilter)
		Set Filter to
	Else
		Set Filter to &cSvFilter
	Endif
	
	DbGoTo(nRegCorrente)
	
	oWin:Enable()
	
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Controle para regua de processamento                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|lEnd| Imp(@lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)},Titulo)

IF Empty(cSvFilter)
	Set Filter to
Else
	Set Filter to &cSvFilter
Endif

DbGoTo(nRegCorrente)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtiva a Janela Pai                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWin:Enable()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Imp(lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)
Local nChar

DbSelectArea(cString)

If Len(aReturn) > 8
	Mont_dic(cString)
Else
	Mont_Array(cString)
EndIf

nChar := Iif(aReturn[4]==1,15,18) // Comprimido ou Normal

ImpCadast(Cabec1,Cabec2,Cabec3,NomeProg,Tamanho,Limite,cString,@lEnd,nChar)

If li != 80
	roda(cbcont,cbtxt,"M")
EndIf

DbSelectArea(cString)

If aReturn[5] = 1
	Set Printer TO
	Commit
	ourspool(wnrel)
EndIf

MS_FLUSH()

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExibeForm( oTab, oWnd, cFilter, cCodRev )
Local i
Local cTitle := "Consulta dados ECD"

If oTab:nOption > 0 .and. !Empty(aBrowse)
	
	// Esconde os outros browses
	For i := 1 to Len(aBrowse)
		aBrowse[i][1]:Hide()
	Next
	
	// Posiciona no arquivo
	DbSelectArea( aBrowse[oTab:nOption][2] )
	cFilter := DbFilter()
	
	// Atualiza array aCampos
	aCampos := aBrowse[oTab:nOption][3]
	aUsados := {}
	
	For i := 1 to Len(aCampos)
		If aCampos[i][3] // Se o campo est  em uso
			aAdd( aUsados, aCampos[i][1] )
		EndIf
	Next i
	
	// Mostra o browse correto
	aBrowse[oTab:nOption][1]:Show()
	
	// Coloca o Foco no browse
	SetFocus(aBrowse[oTab:nOption][1]:hWnd )
	
	aBrowse[oTab:nOption][1]:Hide()
	aBrowse[oTab:nOption][1]:Show()
	aBrowse[oTab:nOption][1]:Refresh()
	
	// Muda o Titulo da Janela
	oWnd:cTitle( cTiTle + Iif( SX2->( DbSeek( aBrowse[oTab:nOption][2] ) ), " - " + Capital( AllTrim( X2Nome() ) ) , "" ))
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pesquisar(oWnd,oBrow)

AxPesqui()

oBrow:nRowPos := 1
SetFocus(oBrow:hWnd)
oWnd:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelecPesq(cPesq, oLbx)
Local nPos := 0

If !Empty(cPesq)
	nPos := ASCAN(aEcdTab,{|z| Upper(AllTrim(cPesq)) $ Upper(AllTrim(z[1])) })
	If nPos == 0
		nPos := ASCAN(aEcdTab,{|z| AllTrim(cPesq) $ z[2]})
	EndIf
Else
	nPos := oLbx:nAt
EndIf

Return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExportarExcel(cAlias,aCampos)
Local cDirDocs  := MsDocPath()
Local cPath		:= AllTrim( GetTempPath() )
Local nX        := 0
Local cBuffer   := ""
Local oExcelApp := Nil
Local nHandle   := 0
Local cArquivo  := CriaTrab(,.F.)
Local aCfgTab	:= {}
Local  nPosCpo 	:= 0

If ! ApOleClient( "MsExcel" )
	MsgStop(STR0013)
	Return
EndIf

cArquivo += ".CSV"

nHandle := FCreate(cDirDocs + "\" + cArquivo)

If nHandle == -1
	MsgStop(STR0014)
	Return
EndIf

cBuffer	:= ""
cBuffer := cAlias

FWrite(nHandle, cBuffer)
FWrite(nHandle, CRLF)
FWrite(nHandle, CRLF)

cBuffer	:= ""

For nx := 1 To Len(aCampos)
	If aCampos[nx,3]
		If nx == Len(aCampos)
			cBuffer += ToXlsFormat(Alltrim(aCampos[nx,2]))
		Else
			cBuffer += ToXlsFormat(Alltrim(aCampos[nx,2])) + ";"
		EndIf
	EndIf
Next nx

FWrite(nHandle, cBuffer)
FWrite(nHandle, CRLF)

//array static para colocar a posicao do campo - FIELDPOS
//sera utilizado no proximo laco da CS1
//tratado como excessao
If __aPosField == NIL

	__aPosField := Array( Len(aCampos) )

	For nX := 1 To Len( aCampos )
		If aCampos[nx,3]
			nPosCpo := FieldPos( AllTrim(aCampos[nx,1]) ) 	
			__aPosField[nX] := nPosCpo 	
		Else
			__aPosField[nX] := 0 	
		EndIf
	Next

EndIf

cBuffer := ""

dbSelectArea(cAlias)
aAuxArea := GetArea()
dbGoTop()

While !Eof()		
	For nx := 1 to Len( aCampos )
		If aCampos[nx,3] .And. __aPosField[nX] > 0
			If nx == Len( aCampos )
				cBuffer += ToXlsFormat(FieldGet( __aPosField[nX] ),AllTrim(aCampos[nx,1]))
			Else
				cBuffer += ToXlsFormat(FieldGet( __aPosField[nX] ),AllTrim(aCampos[nx,1]))+";"
			EndIf
		EndIf
	Next
		
	FWrite(nHandle, cBuffer)
	FWrite(nHandle, CRLF)
	cBuffer := ""
	dbSkip()
EndDo

FWrite(nHandle, CRLF)
FClose(nHandle)

// copia o arquivo do servidor para o remote
CpyS2T(cDirDocs + "\" + cArquivo, cPath, .T.)

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath + cArquivo)
oExcelApp:SetVisible(.T.)
oExcelApp:Destroy()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaUso(alias)
Local lUsado 	:= .F.
Local cAlias	:= Alias()
Local nOrdSX3	:= 0

DbSelectArea( "SX3" )
nOrdSX3	:= IndexOrd()

DbSetOrder(1)
DbGoTop()

DbSeek(alias)
While ( X3_ARQUIVO == alias )
	
	If x3uso(x3_usado)
		lUsado := .T.
	Endif
	
	DbSkip()
EndDo

If !lUsado
	Help(" ",1,"NAO_USADO")
EndIf

DbSelectArea( 'SX3' )
DbSetOrder( nOrdSX3 )

If ( ! Empty( cAlias ) )
	DbSelectArea(cAlias)
EndIf

Return lUsado

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS030   บAutor  ณ Equipe CTB         บ Data ณ  03/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Central de Escritura็ใo Contabil                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RefreshIndex(cAlias, cIndex)

Default cAlias	:= ""
Default	cIndex	:= ""

dbSelectArea(cAlias)
dbCloseArea()

Ferase( cIndex + OrdBagExt() )

dbSelectArea( cAlias )
DbSetOrder(1)
DbGoTop()

Return
