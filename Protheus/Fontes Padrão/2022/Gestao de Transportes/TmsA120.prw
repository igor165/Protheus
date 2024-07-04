#Include "Protheus.ch"
#Include "TMSA120.ch"
#Include "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120 ³ Autor ³ Alex Egydio            ³ Data ³09.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao na Estrutura de Regioes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 12/08/13 ³ Mauro Paladini³ Ajustes na funcao TMSA120Arg() para passar ³±±
±±³          ³               ³ os campos na ordem correta da ExecAuto     ³±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TmsA120()

Local aAreaAnt := GetArea()
Local aSizeAut := MsAdvSize( .F. )
Local aObjects := {}
Local aInfo    := {}
Local aObj     := {}

Local nLin     := 0
Local nCol     := 0

Local oDlg
Local oMenu
Local oOpc
Local oFont    := TFont():New( "Mono As", 6, 15 )
Local cParAli  := ""

// Folder
Local oFolder
Local aPastas   := {}
Local aPages    := {"HEADER"}

Local nSuperior := 0
Local nEsquerda := 0
Local nInferior := 0
Local nDireita  := 0
Local aAlter    := {}
Local nOpc      := GD_UPDATE
Local cLinOk    := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
Local nFreeze   := 000
Local nMax      := 999
Local cFieldOk  := "AllwaysTrue"
Local cSuperDel := ""
Local cDelOk    := "AllwaysTrue"

// - Botoes
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5

Private cCadastro   := STR0001 //'Estrutura de Regioes'
Private aGrupoAtu   := {}
Private aGrupoExc   := {}
Private aGrpTaxa    := {}
Private aGrpNiv     := {}
Private cUfGrupo    := ''
Private cFlGrupo    := ''
Private cVisCatGrp  := ''
Private nGrupo      := Len(DUY->DUY_GRPVEN)
Private oTree       := Nil
Private lAlianca    := TMSAlianca() //-- Indica se utiliza Alianca
Private lMenuWizard := .F.
// Panel
Private oPanel1     := Nil
Private oPanel2     := Nil
Private oPanel3     := Nil
Private oPanel4     := Nil

// MsNewGetdados
Private oNewGetEst
Private oNewGetFil
Private oNewGetReg
Private oNewGetGrp

// Variaveis do Getdados
Private aHeaderEst := {}
Private aColsEst   := {}
Private aHeaderFil := {}
Private aColsFil   := {}
Private aHeaderReg := {}
Private aColsReg   := {}
Private aHeaderGrp := {}
Private aColsGrp   := {}

// Folder
Aadd(aPastas,STR0035) // "Estado"
Aadd(aPastas,STR0036) // "Filial"
Aadd(aPastas,STR0037) // "Cad. Municipio"
Aadd(aPastas,STR0038) // Grupos Regiao"

//-- Alimenta todas filiais aliancas
If lAlianca
	DbSelectArea("DVL")
	DbSetOrder(1)
	MsSeek(xFilial("DVL"))
	While DVL->(!Eof()) .And. DVL->DVL_FILIAL == xFilial("DVL")
		cParAli += DVL->DVL_FILALI + ";"
		DVL->(DbSkip())
	EndDo
EndIf

Aadd( aObjects, { 100, 100, .T., .T. , .T.} ) 
Aadd( aObjects, { 037, 100, .F., .T. , .T.} ) 
Aadd( aObjects, { 227, 100, .F., .T. , .T.} ) 
Aadd( aObjects, { 037, 100, .F., .T. , .T.} ) 

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 1, 1 } 
aObj  := MsObjSize( aInfo, aObjects, , .T. ) 

DEFINE MSDIALOG oDlg FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

	oPanel1:= TPanel():New(aObj[1,1],aObj[1,2],,oDlg,,,,,/*CLR_BLUE*/,aObj[1,3],aObj[1,4],.F.,.F.)
	oPanel2:= TPanel():New(aObj[2,1],aObj[2,2],,oDlg,,,,,/*CLR_RED*/,aObj[2,3],aObj[2,4],.T.,.F.)
	oPanel3:= TPanel():New(aObj[3,1],aObj[3,2],,oDlg,,,,,/*CLR_WHITE*/,aObj[3,3],aObj[3,4],.T.,.F.)
	oPanel4:= TPanel():New(aObj[4,1],aObj[4,2],,oDlg,,,,,/*CLR_RED*/,aObj[4,3],aObj[4,4],.T.,.F.)

	oFolder := TFolder():New(,,aPastas,aPages,oPanel3,,,, .F., .F.,aObj[3,3],aObj[3,4],)

	oFolder:aEnable(1, .T.)
	oFolder:aEnable(2, .T.)
	oFolder:aEnable(3, .T.)
	oFolder:aEnable(4, .T.)

oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,4], aObj[1,3],oPanel1,,,.T.)
oTree:LShowHint := .F.
oTree:oFont := oFont
@ aObj[4,1] - 1, aObj[4,2] TO aObj[4,3], aObj[4,4] PIXEL 

nLin := aObj[2,1] +  8
nCol := aObj[2,2] + 10
//Buttons -Panel 2

oBtn1 := TBtnBmp2():New((aObj[2,4] / 2) - 070,020, 030,025,"SELECTALL",,,,{|| TMSA120Mrk(2, oFolder:nOption)},oPanel2,,,.T. )
oBtn2 := TBtnBmp2():New((aObj[2,4] / 2) - 024,020, 030,025,"PGPREV",,,,{|| TMSA120Arg(oMenu, oFolder:nOption)},oPanel2,,,.T. )
oBtn3 := TBtnBmp2():New((aObj[2,4] / 2) + 024,020, 030,025,"PGNEXT",,,,{|| TMA120Menu( oMenu, 'EXCLU' )},oPanel2,,,.T. )
oBtn4 := TBtnBmp2():New((aObj[2,4] / 2) + 070,020, 030,025,'UNSELECTALL',,,,{|| TMSA120Mrk(3, oFolder:nOption)},oPanel2,,,.T. )
oBtn5 := TBtnBmp2():New((aObj[2,4] / 2) + 116,020, 030,025,'S4WB011N',,,,{|| TMS120Psq(oFolder:nOption)},oPanel2,,,.T. )

//GetDados - Panel3

nSuperior := C(001)
nEsquerda := C(001)
nInferior := aObj[3,4] - 25
nDireita  := aObj[3,3]

TMS120EST()
oNewGetEst := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,,,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[1],aHeaderEst,aColsEst)
oNewGetEst:oBrowse:blDblClick := { || TMS120CLIC(oNewGetEst, 1) }

TMS120FIL()
oNewGetFil := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,,,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[2],aHeaderFil,aColsFil)
oNewGetFil:oBrowse:blDblClick := { || TMS120CLIC(oNewGetFil, 1) }

TMS120REG()
oNewGetReg := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,,,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[3],aHeaderReg,aColsReg)
oNewGetReg:oBrowse:blDblClick := { || TMS120CLIC(oNewGetReg, 1) }

TMS120GPR() 
oNewGetGrp := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,,,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[4],aHeaderGrp,aColsGrp)
oNewGetGrp:oBrowse:blDblClick := { || TMS120CLIC(oNewGetGrp, 1) }

MENU oMenu POPUP
	MENUITEM STR0002 Action TMA120Pesq( @oTree )					//'Pesquisar'
	MENUITEM STR0003 Action TMA120Menu( oMenu, 'VISUA' )			//'Visualizar'
	MENUITEM STR0004 Action TMA120Menu( oMenu, 'INCEST' )			//'Incluir Estado'
	MENUITEM STR0005 Action TMA120Menu( oMenu, 'INCFIL' )			//'Incluir Filial'
	MENUITEM STR0006 Action TMA120Menu( oMenu, 'INCALI', cParAli )	//'Filial Alianca'
	MENUITEM STR0007 Action TMA120Menu( oMenu, 'INCREG' )			//'Incluir Regiao'
	MENUITEM STR0008 Action TMA120Menu( oMenu, 'NIVEL' )			//'Adicionar Nivel'
	MENUITEM STR0009 Action TMA120Menu( oMenu, 'EXCLU' )			//'Excluir'
	MENUITEM STR0010 Action TMA120Menu( oMenu, 'BASET' )			//'Base para Taxa'
	MENUITEM STR0011 Action TMA120Menu( oMenu, 'LEGEN' )			//'Legenda'
	MENUITEM STR0039 Action TMA120Menu( oMenu, 'WIZARD' )			//'Wizard'
	MENUITEM STR0040 Action TMA120Menu( oMenu, 'SALVAR' )			//'Salvar'
	MENUITEM STR0056 Action TMA120Menu( oMenu, 'REFRESH' )			//"Refresh'

ENDMENU

oTree:bRClicked  := { |o,x,y| TMA120MAct( oMenu, x, y ) } // Posição x,y em relação a Dialog 

@ aObj[4,1] + 41, aObj[4,3] - 30 BUTTON oOpc PROMPT STR0012 ACTION TMA120MAct( oMenu, oOpc:nRight - 5, oOpc:nTop - 118 ) SIZE 27, 12 OF oPanel4 Pixel //oDlg PIXEL //"Opcoes"

DEFINE SBUTTON FROM aObj[4,1] + 7, aObj[4,3] - 30 TYPE 1 ENABLE OF oPanel4 pixel;
			ACTION ( TMA120Grava(), oDlg:End() )

DEFINE SBUTTON FROM aObj[4,1] + 24, aObj[4,3] - 30 TYPE 2 ENABLE OF oPanel4 Pixel;
			ACTION If(TMA120VEstr(1),oDlg:End(),.F.)

//-- Chama a rotina de construcao do Tree
Processa( { || TMA120Monta() }, , STR0013 ) //"Construindo Estrutura..."

oPanel2:Hide()
oPanel3:Hide()
ACTIVATE MSDIALOG oDlg

DeleteObject( oDlg  )
DeleteObject( oTree )
DeleteObject( oMenu )
DeleteObject( oOpc  )

RestArea( aAreaAnt )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Pesq ³ Autor ³ Alex Egydio        ³ Data ³09.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa o grupo/item no tree.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120Pesq( oTree )

Local aItems     := {}
Local aSeek      := {}
Local cChavePesq := Space( 20 )
Local cChave     := Space( 20 )
Local cVar       := ''
Local cCargo     := ''
Local nCombo     := 1
Local nOpca      := 0
Local oCombo
Local oDlg
Local oBut1
Local oBut2
Local oGetPesq
Local oGetPesq1
Local cCatGrp    := cVisCatGrp

cVisCatGrp := '1.2.3'

cCargo := oTree:GetCargo()
AAdd( aItems, Posicione('SX3',2,'DUY_GRPVEN','X3Titulo()') )
AAdd( aItems, Posicione('SX3',2,'DUY_DESCRI','X3Titulo()') )

AAdd( aSeek, { '', 1, PesqPict('DUY','DUY_GRPVEN'), Posicione('SX3',2,'DUY_GRPVEN','X3Titulo()'), 'DUY' } )
AAdd( aSeek, { '', 1, PesqPict('DUY','DUY_DESCRI'), Posicione('SX3',2,'DUY_DESCRI','X3Titulo()'), 'DUY' } )

DEFINE MSDIALOG oDlg TITLE CCADASTRO FROM 09,0 TO 21.2,43.5 OF oMainWnd
	DEFINE FONT oBold NAME 'Arial'							SIZE  0,-13 BOLD
	@ 00,00 BITMAP oBmp RESNAME 'LOGIN'				OF oDlg	SIZE 30,120 NOBORDER WHEN .F. PIXEL
	@ 03,40 SAY STR0002 FONT oBold PIXEL //"Pesquisar"
	@ 14,30 TO 16 ,400 LABEL ''						OF oDlg				PIXEL
	@ 23,40 SAY STR0002										SIZE 40, 09	PIXEL 			//"Pesquisar"
	@ 23,80 COMBOBOX oCombo VAR cVar ITEMS aItems	OF oDlg	SIZE 80, 10	PIXEL
	@ 35,40 SAY STR0014										SIZE 40, 09	PIXEL 			//"Chave"
	@ 35,80 MSGET oGetPesq1 VAR cChave WHEN .F.				SIZE 80, 10 VALID .T. PIXEL 
	@ 48,40 SAY STR0015										SIZE 40, 09	PIXEL 			//"Pesquisa"
	@ 48,80 MSGET oGetPesq VAR cChavePesq					SIZE 80, 10 VALID .T. PIXEL
	oGetPesq:bGotFocus := { || oGetPesq:oGet:Picture := aSeek[ oCombo:nAt, 3 ],;
	cChave := aSeek[ oCombo:nAt, 4 ], oGetPesq:cF3 := aSeek[ oCombo:nAt, 5 ],;
	oGetPesq1:Refresh() }

	DEFINE SBUTTON oBut1 FROM 67,  99	TYPE 1 ACTION ( nOpca := 1, nCombo := oCombo:nAt, oDlg:End() )	ENABLE OF oDlg

	DEFINE SBUTTON oBut2 FROM 67, 132	TYPE 2 ACTION ( nOpca := 0,oDlg:End() )						ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	//-- Pesquisa por Descricao
	If	nCombo == 2
		cChavePesq := Posicione('DUY',3,xFilial('DUY')+AllTrim(cChavePesq),'DUY_GRPVEN')
	EndIf
	cChavePesq := RTRIM( cChavePesq )
	If !oTree:TreeSeek( cChavePesq )
		Help(' ',1,'TMSA12002')		//-- Regiao nao encontrada.
	EndIf
EndIf

cVisCatGrp := cCatGrp

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120MAct ³ Autor ³ Alex Egydio        ³ Data ³09.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o menu.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Menu                                        ³±±
±±³          ³ ExpN1 = Dimensao X                                         ³±±
±±³          ³ ExpN2 = Dimensao Y                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120MAct( oMenu, nX, nY )

Local aAreaDUY	:= DUY->(GetArea())
Local cCargo	:= ''
Local cCodUser := __cUserID

//-- Desabilita todos os itens do menu
//-- aItems[1] = Pesquisar
//-- aItems[2] = Visualiza
//-- aItems[3] = Incluir Estado
//-- aItems[4] = Incluir Filial
//-- aItems[5] = Filial Alianca
//-- aItems[6] = Incluir Regiao
//-- aItems[7] = Excluir
//-- aItems[8] = Base para Taxa
//-- aItems[9] = Legenda
AEval( oMenu:aItems, { |x| x:Disable() } ) 

cCargo := oTree:GetCargo() 
//-- Habilita as opcoes de acordo com o grupo do tree
If	cCargo == PadR('MAINGR',nGrupo)

	If	TmsAcesso(,'TMSA120',cCodUser,3)		//-- Verifica se tem acesso para incluir
		oMenu:aItems[3]:Enable()
		oMenu:aItems[4]:Enable()
		oMenu:aItems[6]:Enable()
		oMenu:aItems[11]:Enable()
	EndIf

Else

	If	TmsAcesso(,'TMSA120',cCodUser,2)		//-- Verifica se tem acesso para consultar
		oMenu:aItems[2]:Enable()
	EndIf

	If	TmsAcesso(,'TMSA120',cCodUser,3)		//-- Verifica se tem acesso para incluir
		oMenu:aItems[3]:Enable()
		oMenu:aItems[4]:Enable()
		oMenu:aItems[11]:Enable()
		If lAlianca
			oMenu:aItems[5]:Enable()
		EndIf
		oMenu:aItems[6]:Enable()
	EndIf

	If	TmsAcesso(,'TMSA120',cCodUser,5)		//-- Verifica se tem acesso para excluir
		oMenu:aItems[7]:Enable()
	EndIf

	//-- Nao habilita a opcao base para taxa, quando a regiao nao estiver gravada no duy, ha controles que dependem
	//-- das funcoes tmsnivsup e tmsnivinf e estas funcoes se baseiam no duy
	DUY->(DbSetOrder(1))
	If	DUY->(MsSeek(xFilial('DUY') + Left(cCargo,nGrupo))) .And. ! Empty(DUY->DUY_GRPSUP)
		If TmsAcesso(,'TMSA120',cCodUser,8)
			oMenu:aItems[8]:Enable()
		EndIf	
	EndIf	
EndIf
oMenu:aItems[1]:Enable()
If TmsAcesso(,'TMSA120',cCodUser,9)
	oMenu:aItems[9]:Enable()
EndIf	

oMenu:aItems[10]:Enable()

If TmsAcesso(,'TMSA120',cCodUser,12)
	oMenu:aItems[12]:Enable()
EndIf
If TmsAcesso(,'TMSA120',cCodUser,13)	
	oMenu:aItems[13]:Enable()
EndIf	
//-- Ativa o Menu PopUp
oMenu:Activate( nX, nY, oTree )
RestArea( aAreaDUY )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Menu ³ Autor ³ Alex Egydio        ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acoes efetuadas pelo menu.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Menu                                        ³±±
±±³          ³ ExpC1 = Indica a acao do men                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120Menu( oMenu, cAction, cParAli, lWizard, cCargoWiz )

Local aRegiao      := {}
Local aFilAli      := {}
Local cCargo       := ''
Local cCatPai      := ''
Local cCatGrp      := ''
Local cFilAli      := ''
Local cNivSup      := ''
Local cCdrTax      := ''
Local nCntFor      := 0
Local nDeleted     := 0
Local nLoop        := 0
Local nRegDUY      := 0
Local nRet         := 0
Local nSeek        := 0
Local lBaseTx      := .F.
Local lFound       := .F.
Local lMsgErr      := .F.
Local cFilgrp
Local cRegAli      := ""
Local cGrupoSup    := ""
Local aAreaDUY     := {}
Local lExistFilAli := .F.
Local lCond        := .F.
Local cCampo       := Space(Len(DUY->DUY_CDRCOL))
Local lCdrCol      := .F.
Local nCount       := 0
Local aVisErr      := {}
// - Controle de Versao
Local lR5          := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao      := VAL(GetVersao(.F.))     // Indica a versao do Protheus
Local aDados
Local nPos
Local aParam	   := {}

PRIVATE aRotina
PRIVATE aGrpTmpExc := {}
PRIVATE Inclui     := .T.	//-- Nao retirar
Private lRefresh   := .T.	//-- Nao retirar usado pela funcao axinclui()
Default lWizard    := .F.
Default cCargoWiz  := ""

//-- Verifica se permite modificar a estrutura atual.
If !Empty(aGrpNiv)
	If !( cAction $ 'VISUA/RESET/LEGEN' )
		If !TMA120VEstr(2)
			Return( .F. )
		Else
			aGrupoExc := {}
			aGrupoAtu := {}
			aGrpNiv   := {}
		EndIf
	EndIf
EndIf

If	cAction == 'VISUA'

	cCargo := oTree:GetCargo()

	//-- Visualizacao do Grupo
	aRotina := {	{ STR0002 ,'AxPesqui', 0 , 1},; //"Pesquisar"
					{ STR0003 ,'AxVisual', 0 , 2} } //"Visualizar"

	DUY->(DbSetOrder( 1 ))
	If DUY->(MsSeek(xFilial('DUY') + Left(cCargo,nGrupo)))
		AxVisual('DUY',DUY->(Recno()),2)
	EndIf 
			
ElseIf	cAction == 'EXCLU'

	cCargo := oTree:GetCargo()

	//-- Analisa niveis inferiores
	aRegiao := {}
	TmsNivInf( Left(cCargo,nGrupo), aRegiao, , .T. )
	
	If Ascan(aRegiao,{|x| x[3] == .T. }) > 0
		aSort(aRegiao,,,{|x,y|x[3]<y[3]})
		
		For nCount := Ascan(aRegiao,{|x| x[3] == .T. }) To Len(aRegiao)
			Aadd(aVisErr,{STR0041 +" "+ aRegiao[nCount,4] +" "+ STR0042 +" "+ aRegiao[nCount,1] }) // "Regiao " XXX  " está coligada a regiao " YYY
		Next nCount
		TmsMsgErr(aVisErr, STR0043)
		Return .T.
	EndIf
	
	For nCntFor := 1 To Len(aRegiao)
		//-- Verifica se Existe filial alianca para niveis inferiores
		If	!lExistFilAli .And. TmsFilAli(aRegiao[nCntFor,1],'')
			cRegAli := aRegiao[nCntFor,1]
			lExistFilAli := .T.
		EndIf
		
		If !lMsgErr
			//-- Procura se a Regiao a ser excluida, esta sendo utilizada como Regiao Origem em alguma Tabela de Frete             
			DT0->(DbSetOrder(2))
			If DT0->(MsSeek(xFilial('DT0')+ aRegiao[nCntFor,1]))
				lMsgErr := .T.
				If !MsgYesNo(STR0016,STR0021) //"Existem Tabelas de Frete utilizando a Regiao a ser excluida  ... Continua ?"###"Atencao"
					Return( .T. )
				EndIf
			Else
				//-- Procura se a Regiao a ser excluida, esta sendo utilizada como Regiao Destino em alguma Tabela de Frete       
				DT0->(DbSetOrder(3))
				If DT0->(MsSeek(xFilial('DT0')+aRegiao[nCntFor,1]))
					lMsgErr := .T.
					If !MsgYesNo(STR0016,STR0021) //"Existem Tabelas de Frete utilizando a Regiao a ser excluida  ... Continua ?"###"Atencao"
						Return( .T. )
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	//-- Verifica se a regiao esta sendo usada por alguma rota
	DUN->(DbSetOrder(3)) //DUN_FILIAL+DUN_CDRDES
	If	DUN->(MsSeek(xFilial('DUN')+Left(cCargo,nGrupo)))
		Help('',1,'TMSA12009',, STR0019 + Left(cCargo,nGrupo) + STR0020 + DUN->DUN_ROTEIR,4,1) //"Existe rota utilizando esta regiao" ### "Regiao:" ### "Rota"
		Return( .T. )
	EndIf
	DUN->(DbSetOrder(4)) //DUN_FILIAL+DUN_CDRDCA
	If	DUN->(MsSeek(xFilial('DUN')+Left(cCargo,nGrupo)))
		Help('',1,'TMSA12009',, STR0019 + Left(cCargo,nGrupo) + STR0020 +DUN->DUN_ROTEIR,4,1) //"Existe rota utilizando esta regiao" ### "Regiao:" ### "Rota"
		Return( .T. )
	EndIf

	If Aviso(STR0021,STR0022 + AllTrim(oTree:GetPrompt())+' ?',{STR0017,STR0018},2,'') == 1 //"Atencao" ### "Confirma a exclusao de" ### "Sim" ### "Nao"

		cGrupoExc := Left(cCargo,nGrupo)
		DUY->(DbSetOrder(1))
		DUY->(MsSeek(xFilial('DUY') + cGrupoExc))
		cGrupoSup := DUY->DUY_GRPSUP

		//-- Armazenam os niveis inferiores para atualizacao.
		aAreaDUY := DUY->(GetArea())
		DUY->(DbSetOrder(2))
		If DUY->(MsSeek(xFilial('DUY')+cGrupoExc)) .And. Aviso(STR0021,STR0023,{STR0017,STR0018},2,'') == 1 //"Atencao" ### "Exclui niveis inferiores da regiao atual ?" ### "Sim" ### "Nao"
			//-- Existe filial de alianca para esta regiao
			If lExistFilAli
				Help('',1,'TMSA12008',,STR0019 + cRegAli,4,1) //"Existe filial de alianca para esta regiao" ### "Regiao"
				Return( .T. )
			Else
				TMA120ExcN(cGrupoExc,' ')
			EndIf
		Else
			TMA120ExcN(cGrupoExc,cGrupoSup)
		EndIf
		RestArea( aAreaDUY )

		TMA120IncGrp( DUY->DUY_GRPSUP, cGrupoExc )

		//-- Exclusao do Grupo
		oTree:DelItem()
		oTree:Refresh()

		aGrpTmpExc := {}

		TMA120ExcGrp( cGrupoExc )
		
		nDeleted := 0
		//-- Exclui do grupo atual, os grupos do array de exclusao temporario.
		For nLoop := 1 To Len( aGrpTmpExc )
			If !( Empty( nSeek := AScan( aGrupoAtu, { |x| x[1] == aGrpTmpExc[ nLoop ] } ) ) )
				ADel( aGrupoAtu, nSeek )
				nDeleted++
			EndIf
		Next nLoop
	
		ASize( aGrupoAtu, Len( aGrupoAtu ) - nDeleted )
		aGrpTmpExc := {}
	EndIf
ElseIf	cAction == 'INCEST'
	//-- Inclui Estado

	aDados:= FWGetSX5('12')

	lCond := IIF(lWizard, lWizard, ConPad1(,,,'12',,,.F.))
	
	If	lCond

		// aParam[1] = Funcao executada antes da interface
		// aParam[2] = Funcao executada ao confirmar (TudoOk)
		// aParam[3] = Funcao executada dentro da transacao (AxInclui)
		// aParam[4] = Funcao executada apos a transacao

		aParam := {    {|| TmsA120Est(aDados,nPos) }, ;
								{|| .T. },;
								{|| .T. },;
								{|| .T. }} // Utilizado na AxInclui

		nPos:= Ascan( aDados,{ |x| x[4] == Alltrim(X5Descri()) } )
		
		//-- Posiciona no arquivo de grupos de regioes pelo estado, se nao encontrar permite a inclusao
		DUY->(DbSetOrder(4))
		If	! DUY->(MsSeek(xFilial('DUY') + IIF(lWizard,DUY->DUY_EST, PadR(aDados[nPos][3],Len(DUY->DUY_EST)) )+ StrZero(1,Len(DUY->DUY_CATGRP))))
			DUY->(DbSetOrder(1))
			If AxInclui('DUY',DUY->(Recno()),,,,,/*cTudoOk*/,,,,aParam,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/) != 1
			   Return( .T. )
			EndIf
		EndIf
				
		cUfGrupo := DUY->DUY_EST
		DUY->(DbSetOrder(1))

		cCargo := IIF(lWizard,cCargoWiz, oTree:GetCargo())
		lFound := oTree:TreeSeek( DUY->DUY_GRPVEN )
		
		oTree:TreeSeek( cCargo )

		If lFound
			Help(' ',1,'TMSA12001')		//-- Regiao ja cadastrada
		Else 
			//-- Nao deixa incluir um estado dentro de um estado
			nSeek	:= ASCan(aGrupoAtu,{|x| x[1] == cCargo })

			If Empty(nSeek)
				//-- Avalia a estrutura nao permitindo incluir um estado dentro de outro estado ( depois que gravou DUY )
				nRegDUY := DUY->(Recno())
				DUY->(DbSetOrder(1))
				DUY->(MsSeek(xFilial('DUY') + cCargo))
				cFilgrp := DUY->DUY_FILDES
				cCatPai := DUY->DUY_CATGRP
				DUY->(DbGoTo(nRegDUY))
				//-- Niveis superiores e historico da regiao selecionada
				nRet := TmsSupFil(cCargo,cCatPai,DUY->DUY_GRPVEN,DUY->DUY_CATGRP)
				If nRet == 1
					Help(' ',1,'TMSA12006')						//-- Ja existe um estado informado neste nivel
					Return( .T. )
				ElseIf nRet == 2
					Help(' ',1,'TMSA12010')						//-- Ja existe um estado ou filial no historico e neste nivel
					Return( .T. )
				EndIf
			Else
				//-- Avalia a estrutura nao permitindo incluir um estado dentro de outro estado ( antes de gravar DUY )
				While nSeek > 0
					If	aGrupoAtu[nSeek,3]==StrZero(1,Len(DUY->DUY_CATGRP))
						Help(' ',1,'TMSA12006')						//-- Ja existe um estado informado neste nivel
						Return( .T. )
					EndIf
					If	aGrupoAtu[nSeek,2] == 'MAINGR'
						Exit
					EndIf
					cNivSup	:= aGrupoAtu[nSeek,2]
					nSeek		:= ASCan(aGrupoAtu,{|x| x[1] == cNivSup })
				EndDo
			EndIf
			oTree:AddItem( TmsA120Lbl(), DUY->DUY_GRPVEN, 'FOLDER10','FOLDER11',,,2)
			oTree:TreeSeek( DUY->DUY_GRPVEN )
			oTree:Refresh() 
				
			TMA120IncGrp( cCargo, DUY->DUY_GRPVEN, StrZero(1,Len(DUY->DUY_CATGRP)) ,DUY->DUY_FILDES)
			TmsA120Bmp( DUY->DUY_CATREG, DUY->DUY_CATGRP )
			
		EndIf	
	EndIf	
ElseIf	cAction == 'INCFIL'
	//-- Inclui Filial
	lCond := IIF(lWizard, lWizard, ConPad1(,,,'DLB',,,.F.))
	
	If	lCond
		//-- Posiciona no arquivo de grupos de regioes pela filial de destino, se nao encontrar permite a inclusao
		DUY->(DbSetOrder(5))
		If	! DUY->(MsSeek(xFilial('DUY') + IIF(lWizard,DUY->DUY_FILDES,PadR(FWGETCODFILIAL,FWGETTAMFILIAL)) + StrZero(2,Len(DUY->DUY_CATGRP))))
			DUY->(DbSetOrder(1))
			If	AxInclui('DUY',DUY->(Recno()),,,'TmsA120Fil') != 1
				Return( .T. )
			EndIf
		EndIf
		cFlGrupo := DUY->DUY_FILDES
		DUY->(DbSetOrder(1))

		cCargo := IIF(lWizard,cCargoWiz, oTree:GetCargo())
		lFound := oTree:TreeSeek( DUY->DUY_GRPVEN )
		
		oTree:TreeSeek( cCargo )

		If lFound
			Help(' ',1,'TMSA12001')		//-- Regiao ja cadastrada
		Else 
			//-- Nao deixa incluir uma filial dentro de uma filial
			nSeek	:= ASCan(aGrupoAtu,{|x| x[1] == cCargo })

			If Empty(nSeek)
				//-- Avalia a estrutura nao permitindo incluir uma filial dentro de outra filial ( depois que gravou DUY )
				nRegDUY := DUY->(Recno())
				DUY->(DbSetOrder(1))
				DUY->(MsSeek(xFilial('DUY') + cCargo))
				cFilgrp := DUY->DUY_FILDES
				cCatPai := DUY->DUY_CATGRP
				cCdrTax := Space(Len(DUY->DUY_CDRTAX))
				If DUY->DUY_CATREG == StrZero(2, Len(DUY->DUY_CATREG)) // Se o pai for base para Taxa
					cCdrTax := cCargo
				EndIf

				DUY->(DbGoTo(nRegDUY))
				//-- Niveis superiores e historico da regiao selecionada
				nRet := TmsSupFil(cCargo,cCatPai,DUY->DUY_GRPVEN,DUY->DUY_CATGRP)
				If nRet == 1
					Help(' ',1,'TMSA12007')						//-- Ja existe um filial informado neste nivel
					Return( .T. )
				ElseIf nRet == 2
					Help(' ',1,'TMSA12010')						//-- Ja existe um estado ou filial no historico e neste nivel
					Return( .T. )
				EndIf
			Else
				While nSeek > 0
					If	aGrupoAtu[nSeek,3]==StrZero(2,Len(DUY->DUY_CATGRP))
						Help(' ',1,'TMSA12007')						//-- Ja existe uma filial informada neste nivel
						Return( .T. )
					EndIf
					If	aGrupoAtu[nSeek,2] == 'MAINGR'
						Exit
					EndIf
					cNivSup	:= aGrupoAtu[nSeek,2]
					nSeek		:= ASCan(aGrupoAtu,{|x| x[1] == cNivSup })
				EndDo
			EndIf

			oTree:AddItem( TmsA120Lbl(), DUY->DUY_GRPVEN, 'FOLDER12','FOLDER13',,,2)
			oTree:TreeSeek( DUY->DUY_GRPVEN )
			oTree:Refresh()

			TMA120IncGrp( cCargo, DUY->DUY_GRPVEN, StrZero(2,Len(DUY->DUY_CATGRP)),,DUY->DUY_EST, cCdrTax )

			TmsA120Bmp( DUY->DUY_CATREG, DUY->DUY_CATGRP )
			
		EndIf	
	EndIf	

ElseIf	cAction == 'INCALI'
	//-- Identifica as filiais de alianca
	aFilAli := {}
	cCargo := oTree:GetCargo()
	cFilAli := ''
	For nCntFor := 1 To Len(cParAli)
		cFilAli += Subs(cParAli,nCntFor,1)
		If Subs(cParAli,nCntFor,1)==';'
			//-- Mostra marcado se ja foi especificado uma filial alianca
			AAdd(aFilAli,{TmsFilAli(Left(cCargo,nGrupo),cFilAli),Left(cFilAli,Len(cFilAli)-1),UPPER(Posicione('SM0',1,SM0->M0_CODIGO+cFilAli,'M0_FILIAL'))})
			cFilAli := ''
		EndIf
	Next

	If !Empty(aFilAli)
		//-- Ordenar o Array, para mostrar primeiro as filiais de Alianca selecionadas
		aSort(aFilAli,,,{|x,y| x[1] > y [1] })     
		//-- Guarda em uma string as filiais de alianca selecionadas
		If	TMSABrowse( aFilAli,STR0006,,,.T.,, {STR0024,STR0025} ) //'Filial Alianca' ### 'Filial' ### 'Descricao'
			//-- Guarda na regiao as filiais de alianca
			nSeek := ASCan(aGrupoAtu,{|x| x[1]==cCargo })
			If nSeek <= 0
				DUY->(DbSetOrder( 1 ))
				If	DUY->(MsSeek(xFilial('DUY') + Left(cCargo,nGrupo)))
					TMA120IncGrp( DUY->DUY_GRPSUP, DUY->DUY_GRPVEN, DUY->DUY_CATGRP, DUY->DUY_FILDES, DUY->DUY_EST )
					nSeek := Len(aGrupoAtu)
				EndIf
			EndIf
			aGrupoAtu[nSeek,6] := AClone(aFilAli)			
		EndIf	
	EndIf


ElseIf	cAction == 'INCREG'
	cCargo := IIF(lWizard, cCargoWiz,  oTree:GetCargo())
	
	aAreaDUY := DUY->(GetArea())

	DUY->(DbSetOrder( 1 )) 
	If DUY->(MsSeek(xFilial('DUY') + Left(cCargo,nGrupo)))
		cFlGrupo := DUY->DUY_FILDES
		cUfGrupo := DUY->DUY_EST
	EndIf
		
	RestArea( aAreaDUY )
	//-- Inclui Regiao
	cVisCatGrp := '3'						//-- Variavel utilizada pela consulta SXB( DUY )

	lCond := IIF(lWizard, lWizard, ConPad1(,,,'DUY',,,.F.	))
	
	If !lWizard .And. lCond
		If (cUfGrupo <> DUY->DUY_EST  .And. !Empty(cUfGrupo) .And. !lCdrCol .And. Empty(DUY->DUY_CDRCOL)) .Or.;
			(cUfGrupo == DUY->DUY_EST  .And. !Empty(DUY->DUY_CDRCOL))

			If cUfGrupo	# DUY->DUY_EST

				If !Empty(aGrupoExc) .Or. !Empty(aGrupoAtu)
				//-- Atualizacao da estrutura.
					If TMA120VEstr(2)
						aGrupoExc := {}
						aGrupoAtu := {}
					EndIf
				EndIf
				lCdrCol := TMSA120COL(@cCampo)
				cCampo  := Alltrim(cCampo)
			Else
				lCdrCol := .T.
			EndIf
					
			If !lCdrCol		
				lCond := .F.
			Else
				RecLock("DUY" , .F.)
				DUY->DUY_CDRCOL := cCampo
				MsUnLock()
			EndIf
		EndIf
	EndIf
	
	If lCond
		lFound := oTree:TreeSeek( DUY->DUY_GRPVEN )

		oTree:TreeSeek( cCargo )

		If lFound
			Help(' ',1,'TMSA12001')		//-- Regiao ja cadastrada.
		Else 
		
			nRegDUY := DUY->(Recno())
			DUY->(DbSetOrder(1))
			DUY->(MsSeek(xFilial('DUY') + cCargo))
			cFilgrp := DUY->DUY_FILDES
			cCatPai := DUY->DUY_CATGRP
			cCdrTax := DUY->DUY_CDRTAX
			DUY->(DbGoTo(nRegDUY))
			//-- Niveis superiores e historico da regiao selecionada
			nRet := TmsSupFil(cCargo,cCatPai,DUY->DUY_GRPVEN,DUY->DUY_CATGRP)
			If nRet == 1
				Help(' ',1,'TMSA12006')						//-- Ja existe um estado informado neste nivel
				Return( .T. )
			ElseIf nRet == 2
				Help(' ',1,'TMSA12010')						//-- Ja existe um estado ou filial no historico e neste nivel
				Return( .T. )
			EndIf
			oTree:AddItem( TmsA120Lbl(), DUY->DUY_GRPVEN, 'FOLDER5','FOLDER6',DUY->DUY_FILDES,DUY->DUY_EST,2)
			oTree:TreeSeek( DUY->DUY_GRPVEN )
			oTree:Refresh() 

			TMA120IncGrp( cCargo, DUY->DUY_GRPVEN, StrZero(3,Len(DUY->DUY_CATGRP)), cFlGrupo, cUfGrupo, cCdrTax )

			TmsA120Bmp( DUY->DUY_CATREG, DUY->DUY_CATGRP )
		EndIf
	EndIf
ElseIf	cAction == 'BASET'
	//-- Configura regiao como 'Praca a Praca ou Regiao base para taxa'
	cCargo	:= Left(oTree:GetCargo(),nGrupo)
	nSeek		:= AScan(aGrpTaxa,{|x| x[1] == cCargo })
	If Empty(nSeek)
		DUY->(DbSetOrder(1))
		If	DUY->(MsSeek(xFilial('DUY') + cCargo))
			AAdd( aGrpTaxa, { cCargo, DUY->DUY_CATREG, DUY->DUY_CATGRP } )
		EndIf
		nSeek := Len(aGrpTaxa)
	EndIf

	//-- Nao permite configurar a regiao se o grupo superior ja estiver configurado como regiao para taxa
	If nSeek > 0
		If	aGrpTaxa[ nSeek, 2 ] == StrZero(1,Len(DUY->DUY_CATREG))
			//-- Somente regioes de grupo superior podem ser definadas como regiao base para taxa
			lBaseTx := ! TmsA120Sup(aGrupoAtu,cCargo)

			If	lBaseTx
				Help(' ',1,'TMSA12004')		//-- Somente regioes de grupo superior podem ser definadas como regiao base para taxa
			Else
				//-- Niveis superiores da regiao selecionada
				aRegiao := TmsNivSup( cCargo )
				//-- Verifica se alguma das regioes de nivel superior ja foi configurada como base para taxa
				lBaseTx := TmsA120Btx(aRegiao,aGrpTaxa,aGrupoAtu,.T.)

				If	lBaseTx
					Help(' ',1,'TMSA12003')		//-- Regiao superior ja definida como regiao base para taxa
				Else

					//-- Analisa niveis inferiores
					aRegiao := {}
					TmsNivInf( aGrpTaxa[nSeek,1], aRegiao )
					//-- Verifica se alguma das regioes de nivel inferior ja foi configurada como base para taxa
					lBaseTx := TmsA120Btx(aRegiao,aGrpTaxa,aGrupoAtu,.F.)
	
					If	lBaseTx
						Help(' ',1,'TMSA12005')		//-- Regiao inferior ja definida como regiao base para taxa
					EndIf
	
				EndIf
			EndIf

		EndIf

		If	lBaseTx
			//-- Retira a regiao do vetor
			cCatGrp := aGrpTaxa[nSeek,3]
			ADel(aGrpTaxa,nSeek)
			ASize(aGrpTaxa,Len(aGrpTaxa)-1)
			//-- Muda a cor da pasta do tree, para amarelo indicando que a regiao nao esta configurada como base para taxa
			TmsA120Bmp( StrZero(1,Len(DUY->DUY_CATREG)), cCatGrp )
		Else
			aGrpTaxa[ nSeek, 2 ] := Iif( aGrpTaxa[ nSeek, 2 ] == StrZero(1,Len(DUY->DUY_CATREG)),StrZero(2,Len(DUY->DUY_CATREG)),StrZero(1,Len(DUY->DUY_CATREG)))
			//-- Muda a cor da pasta do tree, para vermelho indicando que a regiao esta configurada como base para taxa
			TmsA120Bmp( aGrpTaxa[ nSeek, 2 ], aGrpTaxa[ nSeek, 3 ] )
		EndIf
	EndIf
ElseIf	cAction == 'RESET'
	oTree:Reset()
ElseIf	cAction == 'LEGEN'
	TmsA120Leg()
ElseIf   cAction == 'NIVEL' //-- Adiciona nivel inferior
	cCargo := Left(oTree:GetCargo(),nGrupo)
	TmsA120Niv(cCargo)
ElseIf	cAction == 'WIZARD'
	//-- Verificação de Release .5 do Protheus 11
	If nVersao <= 11
		If nVersao == 11 .And. !lR5
			Aviso(STR0052, STR0053 + Chr(10)+Chr(13) + STR0054, {STR0055}, 1) //"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
			Return( .T. )
		ElseIf nVersao < 11
			Aviso(STR0052, STR0053 + Chr(10)+Chr(13) + STR0054, {STR0055}, 1) //"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
			Return( .T. )
		EndIf
	EndIf

	lMenuWizard := !lMenuWizard
	If lMenuWizard
		oPanel2:Show()
		oPanel3:Show()
		oNewGetEst:oBrowse:SetFocus()
	Else
		oPanel2:Hide()
		oPanel3:Hide()
	EndIf

ElseIf cAction == 'SALVAR'
	If !Empty(aGrupoExc) .Or. !Empty(aGrupoAtu) .Or. !Empty(aGrpTaxa)
	//-- Atualizacao da estrutura.
		If TMA120VEstr(2)
			aGrupoExc := {}
			aGrupoAtu := {}
			aGrpTaxa  := {}
		EndIf
	EndIf
ElseIf cAction == 'REFRESH'
	oTree:Reset()
	Processa( { || TMA120Monta() }, , STR0013 ) //"Construindo Estrutura..."
	oTree:Refresh()

	TMS120EST()
	oNewGetEst:aCols := aClone(aColsEst)
	oNewGetEst:Refresh()
	oNewGetEst:oBrowse:Refresh()

	TMS120FIL()
	oNewGetFil:aCols := aClone(aColsFil)
	oNewGetFil:Refresh()
	oNewGetFil:oBrowse:Refresh()

	TMS120REG()
	oNewGetReg:aCols := aClone(aColsReg)
	oNewGetReg:Refresh()
	oNewGetReg:oBrowse:Refresh()

	TMS120GPR()
	oNewGetGrp:aCols := aClone(aColsGrp)
	oNewGetGrp:Refresh()
	oNewGetGrp:oBrowse:Refresh()

EndIf
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA120Est ³ Autor ³ Alex Egydio         ³ Data ³09.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa as informacoes do grupo conforme tabela generica³±±
±±³          ³ (12 - Estados)                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Est(aDados,nPos)

M->DUY_DESCRI   := PadR(aDados[nPos][4],Len(DUY->DUY_DESCRI))
M->DUY_EST    	:= PadR(aDados[nPos][3],Len(DUY->DUY_EST))
M->DUY_CATGRP 	:= StrZero(1,Len(DUY->DUY_CATGRP))

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA120Fil ³ Autor ³ Alex Egydio         ³ Data ³09.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa as informacoes do grupo conforme consulta SXB   ³±±
±±³          ³ (DLB - Filiais)                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Fil()

M->DUY_DESCRI := UPPER(PadR(SM0->M0_FILIAL,Len(DUY->DUY_DESCRI)))
M->DUY_EST    := cUfGrupo
M->DUY_FILDES := PadR(FWGETCODFILIAL,FWGETTAMFILIAL)
M->DUY_CATGRP := StrZero(2,Len(DUY->DUY_CATGRP))

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA120IncGrp³ Autor ³ Alex Egydio        ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui um grupo nos arrays de controle                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cargo do tree                                      ³±±
±±³          ³ ExpC2 = Grupo de regiao                                    ³±±
±±³          ³ ExpC3 = Categoria do grupo    (cGrupoNovo)                 ³±±
±±³          ³ ExpC4 = Filial da Regiao      (cGrupoNovo)                 ³±±
±±³          ³ ExpC5 = Estado da Regiao      (cGrupoNovo)                 ³±±
±±³          ³ ExpC6 = Regiao Base para Taxa (cGrupoNovo)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120IncGrp( cCargo, cGrupoNovo, cCatGrp, cFlGrp, cUfGrp, cCdrTax )

Local cGrupoSup := Left(cCargo,nGrupo)
Local nScan     := 0

DEFAULT cCatGrp	:= ''
DEFAULT cFlGrp  := ''
DEFAULT cUfGrp  := ''
DEFAULT cCdrTax := ''

//-- Formato do vetor aGrupoAtu
//-- aGrupoAtu[01] = Codigo da regiao
//-- aGrupoAtu[02] = Codigo da regiao de grupo superior
//-- aGrupoAtu[03] = Categoria do grupo. Determina se o codigo da regiao se refere a um estado, filia l ou regiao
//-- aGrupoAtu[04] = Filial da regiao
//-- aGrupoAtu[05] = Estado da regiao
//-- aGrupoAtu[06] = Vetor contendo as filiais de alianca. Preenchido na funcao tmsa120menu()
//-- aGrupoAtu[07] = Codigo da Regiao Base para Taxa

//-- Adiciona ao array de grupos atuais.
If Empty( nScan := AScan( aGrupoAtu, { |x| x[1] == cGrupoNovo } )  ) 
	AAdd( aGrupoAtu, { cGrupoNovo, cGrupoSup, cCatGrp, cFlGrp, cUfGrp, {}, cCdrTax } )
EndIf 

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA120ExcGrp³ Autor ³ Alex Egydio        ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui grupos dos arrays de controle                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Grupo para exclusao.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120ExcGrp( cGrupoExc )

Local aBackGrpAtu := AClone( aGrupoAtu ) 
Local cGrpExcRec  := ''
Local nScanGrp    := 0 
Local nScanSup    := 0
Local nLoop       := 0  

nScanGrp := AScan( aGrupoAtu, { |x| x[1] == cGrupoExc } ) 

If !Empty( nScanGrp ) 
	//-- Inclui no array de exclusao temporaria
	AAdd( aGrpTmpExc, cGrupoExc ) 
	//-- Adiciona ao grupo de excluidos
	If Empty( AScan( aGrupoExc, cGrupoExc ) ) 
		AAdd( aGrupoExc, cGrupoExc ) 	
	EndIf
	//-- Verifica se outros grupos estavam abaixo deste e os exclui tambem
	ASort( aGrupoAtu,,, { |x,y| y[2] > x[2] } )  

	If !Empty( nScanSup := AScan( aGrupoAtu, { |x| x[2] == cGrupoExc } ) )
		For nLoop := nScanSup To Len( aGrupoAtu )
			If aGrupoAtu[ nLoop, 2 ] <> cGrupoExc .Or. Empty( aGrupoAtu[ nLoop, 2 ] )
				Exit
			EndIf
			cGrpExcRec := aGrupoAtu[ nLoop,1 ] 
			TMA120ExcGrp( cGrpExcRec )
		Next nLoop
	EndIf
EndIf
    
aGrupoAtu := aClone( aBackGrpAtu ) 

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA120Bmp³ Autor ³ Alex Egydio           ³ Data ³16.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera a cor da pasta do tree, vermelho indica que a regiao³±±
±±³          ³ esta configurada como base para taxa, amarelo indica que   ³±±
±±³          ³ a regiao nao esta configurada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Categoria da regiao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Bmp( cCatReg, cCatGrp,lRetBMP )

Local cFolderA := ''
Local cFolderB := ''

DEFAULT lRetBMP :=.F.

//-- Estado
If	cCatGrp == StrZero(1,Len(DUY->DUY_CATGRP))
	cFolderA := 'FOLDER10'
	cFolderB := 'FOLDER11'
//-- Filial
ElseIf cCatGrp == StrZero(2,Len(DUY->DUY_CATGRP))
	cFolderA := 'FOLDER12'
	cFolderB := 'FOLDER13'
//-- Regiao
ElseIf cCatGrp == StrZero(3,Len(DUY->DUY_CATGRP))
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'
EndIf

If	cCatReg == StrZero(2,Len(DUY->DUY_CATREG))
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf

If !lRetBMP
	oTree:ChangeBmp( cFolderA, cFolderB )
EndIf 

Return {cFolderA,cFolderB}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA120Sup³ Autor ³ Alex Egydio           ³ Data ³16.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a regiao eh de nivel superior                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Regioes qd houver uma alteracao no tree            ³±±
±±³          ³ ExpC1 = Regiao                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Sup(aGrpAtu,cRegiao)

Local lRet     := .T.

If	AScan(aGrpAtu,{|x|x[2]==cRegiao})==0
	DUY->(DbSetOrder( 2 )) 
	If ! DUY->(MsSeek(xFilial('DUY') + cRegiao))
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA120Btx³ Autor ³ Alex Egydio           ³ Data ³16.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a regiao ja esta configurada como base p/taxa  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Regioes do grupo superior ou inferior              ³±±
±±³          ³ ExpA2 = Regioes definidas como base para taxa              ³±±
±±³          ³ ExpA3 = Regioes qd houver uma alteracao no tree            ³±±
±±³          ³ ExpL1 = .T. Vetor ExpA1 com regioes de nivel superior      ³±±
±±³          ³         .F. Vetor ExpA1 com regioes de nivel inferior      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Btx(aRegiao,aGrpTaxa,aGrpAtu,lNivSup)

Local cRegiao := ''
Local lRet    := .F.
Local nCntFor := 0
Local nSeek   := 0

For nCntFor := 1 To Len( aRegiao )
	If	lNivSup
		cRegiao := aRegiao[nCntFor]
	Else
		cRegiao := aRegiao[nCntFor,1]
	EndIf

	//-- Analisa niveis inferiores
	If	! lNivSup .And. ! TmsA120Sup(aGrpAtu,cRegiao)
		Loop
	EndIf

	nSeek := AScan(aGrpTaxa,{|x| x[1] == cRegiao })
	If	nSeek > 0
		lRet := aGrpTaxa[nSeek,2] == StrZero(2,Len(DUY->DUY_CATREG))
	Else
		DUY->(DbSetOrder( 1 ))
		If DUY->(MsSeek(xFilial('DUY') + cRegiao))
			lRet := DUY->DUY_CATREG == StrZero(2,Len(DUY->DUY_CATREG))
		EndIf
	EndIf
			
	If lRet
		Exit
	EndIf
Next

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA120Monta ³ Autor ³ Alex Egydio        ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120Monta()

Local aAreaAnt	:= GetArea()

ProcRegua(DUY->(LastRec()))
TMA120MonGr("MAINGR")
RestArea( aAreaAnt )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA120MonGR ³ Autor ³Rodrigo de A Sartorio Data ³29.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cGrupoInc - Grupo de Regioes superior a ser pesquisado     ³±±
±±³          ³ lSeek     - Flag indicando se precisa ser posicionado o    ³±±
±±³          ³ registro no arquivo DUY ou nao (.T. nao posiciona)         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120MonGr(cGrupoInc,lSeek)

Local aArea := GetArea()
Local aBmp  := {}
Local cSeek := "",cTexto:=""
Local nRec  := 0

DEFAULT lSeek := .F.

DbSelectArea("DUY")

// Posiciona na regiao para verificar BMP
nRec:=Recno()
DbSetOrder(1) //DUY_FILIAL+DUY_GRPVRN
If dbSeek(xFilial('DUY')+cGrupoInc)
	aBmp   := TmsA120Bmp(DUY->DUY_CATREG,DUY->DUY_CATGRP,.T.)
	cTexto := TmsA120Lbl()
Else
	cTexto := PADR(STR0001,100) //"Estrutura de Regioes"
	aBmp   := {"FOLDER5","FOLDER6"}
EndIf
DbGoTo(nRec)

// Verifica se a regiao e´ regiao superior
DbSetOrder(2)
If !lSeek
	lSeek := dbSeek(xFilial('DUY')+cGrupoInc)
EndIf

If lSeek
	oTree:AddTree(cTexto,.T.,,,aBmp[1],aBmp[2],cGrupoInc)
	While !Eof() .And. DUY_FILIAL+DUY_GRPSUP == xFilial('DUY')+cGrupoInc
		IncProc()
		nRec:=Recno()
		cTexto := TmsA120Lbl()
		cSeek  := DUY->DUY_GRPVEN
		aBmp   := TmsA120Bmp(DUY->DUY_CATREG,DUY->DUY_CATGRP,.T.)
		lSeek  := dbSeek(xFilial('DUY')+cSeek)		
		If !lSeek
			oTree:AddTreeItem(cTexto,aBmp[1],aBmp[2],cSeek)
		Else
			TMA120MonGr(cSeek,lSeek)		
		EndIf
		DbGoTo(nRec)
		DbSkip()
	End
	oTree:EndTree()	
ElseIf cGrupoInc == "MAINGR"
	IncProc()
	oTree:AddTree(cTexto,.T.,,,aBmp[1],aBmp[2],cGrupoInc)
	oTree:EndTree()	
EndIf
RestArea( aArea )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Grava³ Autor ³ Alex Egydio        ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao no arquivo DUY                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA120Grava()

Local nCntFo1    := 0
Local aAreaAnt   := GetArea()
Local aRegiao    := {}
Local aAreaDUY   := {}
Local bCampo     := {|x| FieldName(x) }
Local cGrupoExc  := ''
Local cGrpSup    := ''
Local cEstBranco := Space(Len(DUY->DUY_EST))
Local cFilBranco := Space(Len(DUY->DUY_FILDES))
Local cGrpBranco := Space(Len(DUY->DUY_GRPSUP))
Local cCdrTax    := Space(Len(DUY->DUY_CDRTAX))
Local nCampos    := 0
Local nCntFor    := 0
Local nCnt1      := 0
Local nCnt2      := 0

DbSelectArea("DUY")

Begin Transaction

	//-- Processa os grupos excluidos
	For nCntFor := 1 To Len( aGrupoExc )
		cGrupoExc := aGrupoExc[ nCntFor ]

		If	ValType( cGrupoExc ) == 'C'
			//-- Atualiza a tabela de grupos
			DUY->( DbSetOrder( 1 ) )
			If	DUY->( MsSeek( xFilial('DUY') + cGrupoExc ) )
				RecLock( 'DUY', .F. )
				//-- Grava o grupo superior 
				If Empty(DUY->DUY_CODMUN) .And. Empty(DUY->DUY_CDRCOL) .And. DUY->DUY_CATGRP == StrZero(3,Len(DUY->DUY_CATGRP))
					DUY->DUY_EST    := cEstBranco
				EndIf
				If DUY->DUY_CATGRP <> StrZero(2,Len(DUY->DUY_CATGRP))
					DUY->DUY_FILDES := cFilBranco
				EndIf
				DUY->DUY_CATREG := PadR("1",Len(DUY->DUY_CATREG))
				DUY->DUY_GRPSUP := cGrpBranco
				DUY->DUY_CDRTAX := cCdrTax
				DUY->( MsUnLock() )
			EndIf
		EndIf

	Next

	//-- Processa os grupos incluidos
	For nCntFor := 1 To Len( aGrupoAtu )
		//-- Atualiza a tabela de grupos
		DUY->( DbSetOrder( 1 ) )
		If	DUY->( MsSeek( xFilial('DUY') + aGrupoAtu[ nCntFor, 1 ] ) )
			RecLock( 'DUY', .F. )
			//-- Grava o grupo superior
			DUY->DUY_GRPSUP := aGrupoAtu[ nCntFor, 2 ]
			DUY->DUY_CATGRP := aGrupoAtu[ nCntFor, 3 ]
			If	DUY->DUY_CATGRP == '1'										//-- Se o filho eh estado so atualiza filial
				DUY->DUY_FILDES := aGrupoAtu[ nCntFor, 4 ]
			ElseIf DUY->DUY_CATGRP == '2'									//-- Se o filho eh filial atualiza estado	e a Base para Taxa	
				DUY->DUY_EST    := aGrupoAtu[ nCntFor, 5 ]
				DUY->DUY_CDRTAX := aGrupoAtu[ nCntFor, 7 ]
			Else															//-- Se for regiao atualiza a filial, o estado e a Base para Taxa
				aAreaDUY := DUY->(GetArea())
				cGrpSup := DUY->DUY_GRPSUP
				DUY->(DbSetOrder(1))
				If DUY->(MsSeek(xFilial('DUY')+cGrpSup))		//-- Posiciona no Grupo superior para obter a Filial de Destino/Reg.Taxa do pai
					aGrupoAtu[ nCntFor, 4 ]	:= DUY->DUY_FILDES
					aGrupoAtu[ nCntFor, 7 ] := DUY->DUY_CDRTAX
				EndIf
				RestArea( aAreaDUY )
				DUY->DUY_FILDES := aGrupoAtu[ nCntFor, 4 ]
			If Empty(DUY->DUY_CODMUN) .And. Empty(DUY->DUY_CDRCOL)
				DUY->DUY_EST    := aGrupoAtu[ nCntFor, 5 ]
			EndIf
				DUY->DUY_CDRTAX := aGrupoAtu[ nCntFor, 7 ]
			EndIf
			DUY->(MsUnLock())
			//-- Atualiza os filhos deste pai
			TmsAtuFil(DUY->DUY_GRPVEN,DUY->DUY_CATGRP,DUY->DUY_EST,DUY->DUY_FILDES,DUY->DUY_CDRTAX)
			//-- Grava filial alianca
			For nCnt1 := 1 To Len(aGrupoAtu[nCntFor,6])
				If	aGrupoAtu[nCntFor,6,nCnt1,1]
					RegToMemory('DVK',.T.)
					M->DVK_FILIAL := xFilial('DVK')
					M->DVK_GRPVEN := aGrupoAtu[nCntFor,1]
					M->DVK_FILALI := aGrupoAtu[nCntFor,6,nCnt1,2]
				
					nCampos := DVK->(FCount())
				
					If	TmsFilAli(M->DVK_GRPVEN,M->DVK_FILALI)
						RecLock('DVK',.F.)
					Else
						RecLock('DVK',.T.)
					EndIf

					For nCnt2 := 1 To nCampos
						FieldPut( nCnt2, M->&( Eval( bCampo,nCnt2 ) ) )
					Next
					DVK->(MsUnLock())
				Else
					//-- Desmarcou
					If	TmsFilAli(aGrupoAtu[nCntFor,1],aGrupoAtu[nCntFor,6,nCnt1,2])
						RecLock('DVK',.F.,.T.)
						DVK->(DbDelete())
						MsUnLock()
					EndIf
				EndIf
			Next

		EndIf
	Next

	For nCntFor := 1 To Len(aGrpTaxa)
		cCdrTax := Space(Len(DUY->DUY_CDRTAX))
		//-- Ao incluir um Estado/Filial/Regiao e marca-lo como 'Base para Taxa', o campo DUY_CDRTAX devera' ser ele mesmo.
		//-- Isto porque, ao incluir por exemplo, uma regiao abaixo, o campo DUY_CDRTAX desta regiao devera' 
		//-- ser igual ao campo DUY_CDRTAX do Estado/Filial/Regiao marcado como 'Base para Taxa'
		If aGrpTaxa[nCntFor,2] == StrZero(2, Len(DUY->DUY_CATREG))  //-- Se a categoria da Regiao for 'Base para Taxa'
			cCdrTax := aGrpTaxa[nCntFor,1]  //-- A Regiao base para taxa sera' ela mesmo
		EndIf
		DUY->(DbSetOrder(1))
		If	DUY->(MsSeek(xFilial('DUY') + aGrpTaxa[nCntFor,1]))
			RecLock('DUY',.F.)
			DUY->DUY_CATREG := aGrpTaxa[nCntFor,2]
			DUY->DUY_CDRTAX := cCdrTax
			MsUnLock()

			aRegiao := {}
			TmsNivInf( aGrpTaxa[nCntFor,1], aRegiao )
			For nCntFo1 := 1 To Len( aRegiao )
				DUY->(DbSetOrder(1))
				If	DUY->(MsSeek(xFilial('DUY') + aRegiao[nCntFo1,1]))
					RecLock('DUY',.F.)
					DUY->DUY_CDRTAX := Iif( aGrpTaxa[nCntFor,2] == StrZero(2,Len(DUY->DUY_CATREG)), aGrpTaxa[nCntFor,1], cGrpBranco )
					MsUnLock()
				EndIf	
			Next		
		EndIf
	Next

	//-- Processa nivel inferior
	If !Empty(aGrpNiv)
		aSort(aGrpNiv,,,{|x,y| x[1] > y [1] })
		For nCntFor := 1 To Len( aGrpNiv )
			//-- Atualiza a tabela de grupos	selecionadas
			If !aGrpNiv[ nCntFor, 1 ]
				Exit
			EndIf
			DUY->( DbSetOrder( 1 ) )
			If	DUY->( MsSeek( xFilial('DUY') + aGrpNiv[ nCntFor, 2 ] ) )
				RecLock( 'DUY', .F. )
				//-- Grava o grupo superior
				DUY->DUY_GRPSUP := aGrpNiv[ nCntFor, 4 ]
				MsUnlock()
			EndIf
		Next
	EndIf

End Transaction

RestArea( aAreaAnt )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Ini ³ Autor ³ Alex Egydio         ³ Data ³26.12.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa campos do grupo de regioes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Inicializa o campo Estado ou Filial de Destino.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Ini(nCampo)

Local cRet	 := ''
Local cCargo := ''
Local nGrupo := Len(DUY->DUY_GRPVEN)

If	Type('oTree')!='O'
	If	nCampo == 1									//-- DUY_EST
		cRet := Space(Len(DUY->DUY_EST))
	ElseIf nCampo == 2								//-- DUY_FILDES
		cRet := Space(FWGETTAMFILIAL)
	EndIf
	Return( cRet )
EndIf

cCargo := oTree:GetCargo()

DUY->(DbSetOrder(1))
If	DUY->(MsSeek(xFilial('DUY') + Left(cCargo,nGrupo)))
	cUfGrupo := DUY->DUY_EST
	cFlGrupo := DUY->DUY_FILDES 
EndIf

If	cCargo == PadR('MAINGR',nGrupo)
	If	nCampo == 1										//-- DUY_EST
		cRet := cUfGrupo := Space(Len(DUY->DUY_EST))
	ElseIf nCampo == 2									//-- DUY_FILDES
		cRet := cFlGrupo := Space(FWGETTAMFILIAL)
	EndIf
Else
	If	nCampo == 1										//-- DUY_EST
		cRet := Iif(Type('cUfGrupo')=='C',cUfGrupo,'')
	ElseIf nCampo == 2									//-- DUY_FILDES
		cRet := Iif(Type('cFlGrupo')=='C',cFlGrupo,'')
	EndIf
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA120Leg³ Autor ³ Alex Egydio           ³ Data ³11.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda p/identificar a categoria do grupo de regioes      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA120Leg()

BrwLegenda( cCadastro,   STR0026 ,;	//"Categoria do Grupo"
		{	{'FOLDER10' ,STR0027},;	//"Estado"
			{'FOLDER12' ,STR0024},;	//"Filial"
			{'FOLDER5'  ,STR0028},;	//"Regiao"
			{'FOLDER7'  ,STR0010}})	//"Base para Taxa"

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA120Lbl³ Autor ³ Alex Egydio           ³ Data ³01.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o nome da pasta indicando se ha regiao coligada e    ³±±
±±³          ³ filial de alianca                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA120Lbl()

Local cRet := ''

cRet := PadR( DUY->DUY_GRPVEN + '-' + Padr( Capital(DUY->DUY_DESCRI) ,Len(DUY->DUY_DESCRI)) +;
Iif(Empty(DUY->DUY_CDRCOL),'',Space(10) + '(' + STR0029 + DUY->DUY_CDRCOL+')') +; //"Coligada a Regiao"
Iif(TmsFilAli(DUY->DUY_GRPVEN,''),Space(10) + '(' + STR0030 + ')','') , 100 ) //"Alianca"

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsFilAli ³ Autor ³ Alex Egydio           ³ Data ³01.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se ha filial de alianca para a regiao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsFilAli(cRegiao,cFilAli,aFilAli)

Local cSeek	:= ''
Local lRet	:= .F.

DEFAULT cFilAli:= ''
//-- Verifica sa ha filial de alianca para a regiao
DVK->(DbSetOrder(1))
lRet := DVK->(MsSeek(cSeek:=xFilial('DVK')+cRegiao+cFilAli))
If	lRet .And. ValType(aFilAli)=='A'
	//-- Retorna as filiais de alianca da regiao
	aFilAli := {}
	While DVK->( ! Eof() .And. DVK->DVK_FILIAL + DVK->DVK_GRPVEN == cSeek )
		AAdd(aFilAli,DVK->DVK_FILALI)
		DVK->(DbSkip())
	EndDo
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsAtuFil ³ Autor ³ Wellington A Santos   ³ Data ³26.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para atualizar "filhos" para herdar as propriedades ³±±
±±³          ³ do pai                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³TmsAtuFil(cPai,cCatPai,cEstPai,cFilPai,cCdrTax)             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³lRet ,.T. caso tenha filhos e .F. caso nao                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsAtuFil(cPai,cCatPai,cEstPai,cFilPai,cTaxPai)

Local cSeekDUY  := ""
Local lRetgrp
Local nRecAnt   := 0
Local nRecPri   := 0

DEFAULT cPai    := ""
DEFAULT cCatPai := ""
DEFAULT cEstPai := ""
DEFAULT cFilPai := ""
DEFAULT cTaxPai := ""

nRecPri := DUY->( Recno() ) //guarda posicao do registro para quando sair da funcao retornar para este ponto

DUY->( DbSetOrder( 2 ) ) //DUY->DUY_FILIAL + DUY->DUY_GRPSUP
cSeekDUY := xFilial( "DUY" ) + cPai

If DUY->( MsSeek( cSeekDUY ) )
	lRetgrp :=	.T. //se encontrou retorna .T. dizendo que esse pai possui filhos
	While !DUY->( Eof() ) .And. DUY->DUY_FILIAL + DUY->DUY_GRPSUP == cSeekDUY
		nRecAnt := DUY->( Recno() )
		
		RecLock( 'DUY', .F. )   // Categorias DUY 1 - Estado   2 - Filial   3 - Regiao
		If DUY->DUY_CATGRP == StrZero(1,Len(DUY->DUY_CATGRP)) // Se o filho e estado so atualiza filial
			DUY->DUY_FILDES := cFilPai
		ElseIf DUY->DUY_CATGRP == StrZero(2,Len(DUY->DUY_CATGRP)) // Se o filho e filial atualiza estado e a Base para Taxa
			DUY->DUY_EST    := cEstPai
			DUY->DUY_CDRTAX := cTaxPai						
		ELSE // Se for regiao atualiza a filial, o estado e a regiao base para Taxa
			DUY->DUY_FILDES := cFilPai
			DUY->DUY_EST    := cEstPai
			DUY->DUY_CDRTAX := cTaxPai			
		EndIf
		DUY->(MsUnLock())
		
		
		TmsAtuFil(DUY->DUY_GRPVEN,DUY->DUY_CATGRP,DUY->DUY_EST,DUY->DUY_FILDES,DUY->DUY_CDRTAX)
		DUY->( DbSetOrder( 2 ) )  //DUY->DUY_FILIAL + DUY->DUY_GRPSUP
		DUY->( DbGoTo( nRecAnt ) )
		DUY->( DbSkip() )
		
	EndDo
	
Else
	lRetgrp := .F. //se nao encontrou retorna .F. dizendo que esse nao pai possui filhos
EndIf

DUY->(DbGoTo(nRecPri))

Return( lRetgrp )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsSupFil ³ Autor ³ Wellington A Santos   ³ Data ³26.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para verificar "filhos" para validar se possui      ³±±
±±³          ³ historico que nao possa ser incluido em baixo da arvore    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsSupFil(cPai,cCatPai,cFilho,cCatFil)                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³nRet = 0 caso o historico nao tenha nenhum problema         ³±±
±±³          ³nRet = 2 caso o historico tenha problema                    |±±
±±³          ³mais informacoes ver help tms12007 e tms12010               |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsSupFil(cPai,cCatPai,cFilho,cCatFil)

Local aAreaDUY := DUY->( GetArea() )
Local nRet     := 0
Local cGrupo   := ''
Local aPesqui  := {}
Local nLevel   := 0
Local nPos     := 0
//Se o pai e o filho sao iguais e sao diferentes de 3 (regiao) ja barra a inclusao do item
If cCatPai == cCatFil .and. cCatPai <> StrZero(3,Len(DUY->DUY_CATGRP))
	nRet := 1
ElseIf cCatPai <> StrZero(3,Len(DUY->DUY_CATGRP))
	AAdd(aPesqui,{cCatPai,nLevel})
EndIf

If cCatFil <> StrZero(3,Len(DUY->DUY_CATGRP))
	AAdd(aPesqui,{cCatFil,nLevel})
EndIf

//Varre toda a estrutura acima do pai
DUY->( DbSetOrder( 1 ) )//-- DUY_FILIAL + DUY_GRPVEN
If	DUY->( MsSeek( xFilial('DUY') + cPai, .F.) )
	
	cGrupo := DUY->DUY_GRPSUP
	
	While	DUY->( MsSeek( xFilial('DUY') + cGrupo, .F. ) ) .and. nRet == 0
		
		cGrupo := DUY->DUY_GRPSUP
		nPos := AScan( aPesqui, { |x| x[1] == DUY->DUY_CATGRP } )
		If nPos <> 0 
			nRet := 1
		ElseIf DUY->DUY_CATGRP <> StrZero(3,Len(DUY->DUY_CATGRP))
			AAdd(aPesqui,{DUY->DUY_CATGRP,nLevel})
		EndIf
		
	EndDo
	
EndIf
//Caso a situacao ainda seja valida verifica o historico do filho que possa existir na base
If nRet == 0
	nRet :=	TmsInfFil(cFilho,aPesqui,@nRet)
EndIf

RestArea( aAreaDUY )

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsInfFil ³ Autor ³ Wellington A Santos   ³ Data ³26.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para verificar "filhos" para validar se possui      ³±±
±±³          ³ historico que nao possa ser incluido em baixo da arvore    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsInfFil(cPai,cCatPai,nRet)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Retorno   ³nRet = 0 caso o historico nao tenha nenhum problema         ³±±
±±³          ³nRet = 2 caso o historico tenha problema                    |±±
±±³          ³ver mensagem de erro tms12006 e tms12010                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsInfFil(cPai,aPesqui,nRet,nLevel)

Local cSeekDUY := ""
Local nRecAnt  := 0
Local aAreaDUY := DUY->( GetArea() )

DEFAULT nLevel := 0

DUY->( DbSetOrder( 2 ) ) //DUY->DUY_FILIAL + DUY->DUY_GRPSUP
//Varre toda a estrutura de historico armazenada na base de dados
cSeekDUY := xFilial( "DUY" ) + cPai 
nLevel ++
If DUY->( MsSeek( cSeekDUY ) )
	
	While !DUY->( Eof() ) .And. DUY->DUY_FILIAL + DUY->DUY_GRPSUP == cSeekDUY .and. nRet == 0
		
		nRecAnt := DUY->( Recno() )
		
		nPos := AScan( aPesqui, { |x| x[1] == DUY->DUY_CATGRP } )
		If nPos <> 0 .and. nLevel > aPesqui[nPos,2]
			nRet := 2 //caso seja encontrado no historico uma restricao entao retorna 2 para mudar a mensagem de erro
		ElseIf DUY->DUY_CATGRP <> StrZero(3,Len(DUY->DUY_CATGRP))
			AAdd(aPesqui,{DUY->DUY_CATGRP,nLevel})
		EndIf
		
		TmsInfFil( DUY->DUY_GRPVEN,@aPesqui,@nRet,@nLevel)//Funcao recursiva para buscar todos os filhos do historico

		DUY->( DbSetOrder( 2 ) )
		DUY->( DbGoTo( nRecAnt ) )
		DUY->( DbSkip() )

	EndDo
	
EndIf

RestArea( aAreaDUY )
nLevel --

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA120Niv ³ Autor ³Eduardo de Souza      ³ Data ³ 17/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona nivel inferior para a regiao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA120Niv(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Regiao                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA120Niv(cGrpVen)

Local cAliasTRB1 := ""
Local cQuery     := ""
Local lRet       := .T.
Local aGrpAux    := AClone(aGrpNiv)

If lRet .And. !Empty(aGrupoExc) .Or. !Empty(aGrupoAtu)
	//-- Atualizacao da estrutura.
	If TMA120VEstr(2)
		aGrupoExc := {}
		aGrupoAtu := {}
	Else
		lRet := .F.
	EndIf
EndIf

DUY->(DbSetOrder( 1 ))
DUY->(MsSeek(xFilial('DUY')+cGrpVen))

If lRet
	//-- Verifica se foi selecionado outro grupo.
	If !Empty(aGrpNiv) .And. aGrpNiv[Len(aGrpNiv),4] <> cGrpVen
		aGrpNiv := {}
		aGrpAux := {}
	EndIf
	If Empty(aGrpNiv) .And. !Empty(DUY->DUY_GRPSUP)
		cAliasTRB1 := GetNextAlias()
		cQuery := " SELECT DUY_GRPVEN, DUY_DESCRI "
		cQuery += "  FROM "
		cQuery += RetSqlName("DUY")
		cQuery += "  WHERE DUY_FILIAL = '" + xFilial("DUY") + "' "
		cQuery += "    AND DUY_GRPSUP = '" + DUY->DUY_GRPSUP + "' "
		cQuery += "    AND DUY_GRPVEN <> '" + cGrpVen + "' "
		cQuery += "    AND ( DUY_CATGRP = '" + StrZero(3,Len(DUY->DUY_CATGRP)) + "' "
		cQuery += "    	OR DUY_CATGRP <> '" + DUY->DUY_CATGRP + "' ) "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB1, .F., .T.)	
		While (cAliasTRB1)->(!Eof())
			AAdd( aGrpNiv, { .F., (cAliasTRB1)->DUY_GRPVEN, (cAliasTRB1)->DUY_DESCRI, cGrpVen } )
			(cAliasTRB1)->(DbSkip())
		EndDo
		(cAliasTRB1)->(DbCloseArea())
	EndIf
	//-- Selecao do nivel inferior
	If !Empty(aGrpNiv)
		If !TMSABrowse( aGrpNiv,STR0031,,,.T.,, {STR0032,STR0025} ) //"Nivel Inferior" ### "Codigo" ### "Descricao"
			aGrpNiv := AClone(aGrpAux)
		EndIf
	EndIf
EndIf
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA120ExcN ³ Autor ³Eduardo de Souza      ³ Data ³ 17/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica exclusao de nivel inferior                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA120ExcN(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Regiao                                             ³±±
±±³          ³ ExpC2 - Nivel Superior                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA120ExcN(cGrpVen,cGrpSup)

Local cAliasTRB1 := ""
Local cQuery     := ""

cAliasTRB1 := GetNextAlias()
cQuery := " SELECT DUY_GRPVEN "
cQuery += "  FROM "
cQuery += RetSqlName("DUY")
cQuery += "  WHERE DUY_FILIAL = '" + xFilial("DUY") + "' "
cQuery += "    AND DUY_GRPSUP = '" + cGrpVen + "' "
cQuery += "    AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB1, .F., .T.)
While (cAliasTRB1)->(!Eof())
	AAdd( aGrpNiv, { .T., (cAliasTRB1)->DUY_GRPVEN, ' ', cGrpSup } )
	(cAliasTRB1)->(DbSkip())
EndDo
(cAliasTRB1)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA120VEstr³ Autor ³Eduardo de Souza      ³ Data ³ 18/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a necessidade de atualizacao da estrutura         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA120VEstr(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao (1=Mensag.Cancelamento / 2=Atualiza Estrut.) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA120VEstr(nOpcao)

Local lRet := .T.

//-- Verifica se existem alteracoes na estrutura.
If nOpcao == 1
	If !Empty(aGrpNiv)
		If !MsgYesNo(STR0033,STR0021) //"Existem alteracoes na estrutura atual, deseja sair sem gravar as modificacoes ?"###"Atencao"
			lRet := .F.
		EndIf
	EndIf
ElseIf nOpcao == 2
	If !MsgYesNo(STR0034,STR0021) //"Existem alteracoes na estrutura atual, deseja gravar as modificacoes ?"###"Atencao"
		lRet := .F.
	Else
		TMA120Grava()
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS120Est  ³ Autor ³ Jefferson Tomaz     ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega dados dos estados que nao estao na estrutura       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS120Est()

Local lRet			:= .T.
Local nX            := 0
Local nCnt			:= 0
Local aCpoGDa       := { "X5_CHAVE" , "X5_DESCRI" }
Local cQry1         := ""
Local cAliasQry     := GetNextAlias()
Local aSX5			:= {}
Local aCampos  		:= FwFormStruct(2,"SX5")
Local nPos          := 0
Local nY			:= 0

// Carrega aHead
aHeaderEst 	:= {}
aColsEst 	:= {}

Aadd(aHeaderEst,{"","OK","@BMP",1,0,"","","","","","",""})

For nX := 1 to Len(aCpoGDa)
        
	nPos := AScan(aCampos:aFields, { |coluna| AllTrim(coluna[1]) == Alltrim(aCpoGDa[nX])}) 
	              
	If nPos > 0

		AAdd( aHeaderEst,{ FWX3Titulo(aCampos:aFields[nPos,1])     				,; //| Titulo do Campo
				 		   AllTrim( aCampos:aFields[nPos,1])                 	,; //| X3_Campo
						   X3Picture(aCampos:aFields[nPos][1])	            	,; //| picture
						   TamSx3(aCampos:aFields[nPos][1])[1]					,; //| tamanho
						   TamSX3(aCampos:aFields[nPos][1])[2]					,; //| decimal
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_VALID")  	,; //| valid
                       	   GetSx3Cache(aCampos:aFields[nPos][1],"X3_USADO")  	,; //| usado
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_TIPO")   	,; //| tipo
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_ARQUIVO")	,; //| arquivo
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_CONTEXT")	,; //| context
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_CBOX")		,; //| CBOX
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_RELACAO")})  //| relacao	 
		 				 
	EndIf
Next nX

//Retorna quais estados estão na estrutura de regiões
cQry1 :=         " SELECT DUY_EST "
cQry1 += CRLF +  " FROM " +RetSqlName("DUY")+ " DUY "
cQry1 += CRLF +  " WHERE DUY.DUY_FILIAL = '"+xFilial("DUY")+"' "
cQry1 += CRLF +  "   AND DUY.DUY_CATGRP = '1' " 
cQry1 += CRLF +  "   AND DUY.DUY_GRPSUP > ' ' "
cQry1 += CRLF +  "   AND DUY.D_E_L_E_T_ = ' ' "
cQry1 += CRLF +  " GROUP BY DUY_EST "

cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

//Carrega registros da tabela SX5
aSX5 := FWGetSX5('12')

Do While (cAliasQry)->(!Eof())
    //Remove estados que estão na estrutura de região, restando apenas os que não estão. 
    If (nY := aScan(aSX5,{|x| Alltrim(x[3]) == AllTrim((cAliasQry)->DUY_EST) })) > 0
        aDel(aSX5, nY )
        aSize(aSX5, Len(aSX5)-1)
    Endif
    (cAliasQry)->(dbSkip())
EndDo

For nCnt := 1 To Len(aSX5)
    Aadd(aColsEst, { "LBNO",;
                aSX5[nCnt][3],;
                aSX5[nCnt][4],;
                .F. })
Next nCnt

// Carregar aqui as Colunas da GetDados.
if Len(aColsEst) == 0
	Aadd(aColsEst, {    "LBNO", "", "", .F.})
Endif

aSize(aSX5,0) // LIbera memoria
(cAliasQry)->( DbCloseArea() )

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS120Fil  ³ Autor ³ Jefferson Tomaz     ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega dados das filiais do sistema que nao estao na estru³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS120Fil()

Local lRet     := .T.
Local nX       := 0
Local aCpoGDa  := {}
Local aStruSm0 := SM0->(DbStruct())
Local nPos     := 0
Local aSm0     := FwLoadSm0()
Local nCount   := 0
Local cFilDUY  := AllTrim(cEmpAnt+FwXFilial("DUY",,FwModeAccess("DUY",1),FwModeAccess("DUY",2),FwModeAccess("DUY",3)))
Local bCompFil := {||}

Aadd(aCpoGDa,{ "M0_CODFIL", STR0044	}) // "Cod. Filial"
Aadd(aCpoGDa,{ "M0_FILIAL", STR0045	}) // "Filial"
Aadd(aCpoGDa,{ "M0_NOME"  , STR0046	}) // "Nome"
Aadd(aCpoGDa,{ "M0_ESTCOB", STR0035	}) // "Estado"
Aadd(aCpoGDa,{ "M0_CIDCOB", STR0047	}) // "Municipio"
Aadd(aCpoGDa,{ "M0_CODMUN", STR0048	}) // "IBGE"

// Carrega aHead
aHeaderFil := {}
aColsFil   := {}

Aadd(aHeaderFil,{"","OK","@BMP",1,0,"","","","","","",""})
For nX := 1 to Len(aCpoGDa)
	nPos:= aScan(aStruSm0,{|x| AllTrim(x[1]) == aCpoGDa[nX,1]})
	If nPos > 0
		Aadd(aHeaderFil,{aCpoGDa[nX,2],aCpoGDa[nX,1],"@",aStruSm0[nPos,3],0,"","","","","","",""})
	EndIf
Next nX
Aadd(aHeaderFil,{"RECNO","RECNO","@",9999,0,"","","","","","",""})

DUY->(DbSetOrder(5))

If FwModeAccess("DUY",3) == "E"
	bCompFil := {|| AllTrim( aSm0[nCount, SM0_GRPEMP] + aSm0[nCount, SM0_CODFIL] )}
ElseIf FwModeAccess("DUY",2) == "E"
	bCompFil := {|| AllTrim( aSm0[nCount, SM0_GRPEMP] + aSm0[nCount, SM0_EMPRESA] + aSm0[nCount, SM0_UNIDNEG] )}
ElseIf FwModeAccess("DUY",1) == "E"
	bCompFil := {|| Alltrim( aSm0[nCount, SM0_GRPEMP] + aSm0[nCount, SM0_EMPRESA] )}
Else
	bCompFil := {|| Alltrim( aSm0[nCount, SM0_GRPEMP] )}
EndIf

// Carregar aqui as Colunas da GetDados.
For nCount := 1 To Len(aSm0)
	If !Empty(cFilDUY)
		If cFilDUY <>  Eval(bCompFil)
			Loop
		EndIf
	EndIf

	If (!DUY->(MsSeek(xFilial("DUY") + aSm0[nCount, SM0_CODFIL] + StrZero(2,Len(DUY->DUY_CATGRP)))) .Or. Empty(DUY->DUY_GRPSUP));
		 .And. cEmpAnt == aSm0[nCount, SM0_GRPEMP]
		
		SM0->(DbGoto(aSm0[nCount, SM0_RECNO]))			
				
		Aadd(aColsFil, {                       ;
		"LBNO"                                ,;
		aSm0[nCount, SM0_CODFIL]              ,;
		aSm0[nCount, SM0_FILIAL]              ,;
		aSm0[nCount, SM0_NOMRED]              ,;
		SM0->M0_ESTENT                        ,;
		SM0->M0_CIDENT                        ,;
		SM0->M0_CODMUN                        ,;
		AllTrim(Str(aSm0[nCount, SM0_RECNO])) ,;
		.F. })
	EndIf
Next nCount

If Len(aColsFil) == 0
Aadd(aColsFil,{"LBNO","","","","","","","",.F.})
EndIf
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS120Reg  ³ Autor ³ Jefferson Tomaz     ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega dados dos municipios que nao estao na estrutura    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS120Reg(cUF)

Local lRet:= .T.
Local aCpoGDa         := { "CC2_EST" , "CC2_CODMUN" , "CC2_MUN" }
Local nX              := 0
Local cQry1           := ""
Local cAliasQry       := GetNextAlias()
Local nPos          := 0
Local aCampos  		:= FwFormStruct(2,"CC2")

Default cUf	:= ""

// Carrega aHead
aHeaderReg 	:= {}
aColsReg 	:= {}

Aadd(aHeaderReg,{"","OK","@BMP",1,0,"","","","","","",""})

For nX := 1 to Len(aCpoGDa)
	nPos := AScan(aCampos:aFields, { |coluna| AllTrim(coluna[1]) == Alltrim(aCpoGDa[nX])}) 
	              
	If nPos > 0

		AAdd( aHeaderReg,{ FWX3Titulo(aCampos:aFields[nPos,1])     				,; //| Titulo do Campo
				 		   AllTrim( aCampos:aFields[nPos,1])                 	,; //| X3_Campo
						   X3Picture(aCampos:aFields[nPos][1])	            	,; //| picture
						   TamSx3(aCampos:aFields[nPos][1])[1]					,; //| tamanho
						   TamSX3(aCampos:aFields[nPos][1])[2]					,; //| decimal
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_VALID")  	,; //| valid
                       	   GetSx3Cache(aCampos:aFields[nPos][1],"X3_USADO")  	,; //| usado
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_TIPO")   	,; //| tipo
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_ARQUIVO")	,; //| arquivo
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_CONTEXT")	,; //| context
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_CBOX")		,; //| CBOX
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_RELACAO")})  //| relacao	 
		 				 
	EndIf
Next nX


cQry1 :=         " SELECT
cQry1 += CRLF +  "    CC2_EST, CC2_CODMUN, CC2_MUN "
cQry1 += CRLF +  " FROM " +RetSqlName("CC2")+ " CC2 "
cQry1 += CRLF +  " WHERE
cQry1 += CRLF +  "       CC2.CC2_FILIAL = '" +xFilial("CC2")+"' "
If !Empty(cUf)
	cQry1 += CRLF + " AND CC2.CC2_EST = '" +cUf+"' "
EndIf
cQry1 += CRLF +  "   AND CC2.D_E_L_E_T_ = ' ' "
cQry1 += CRLF +  "   AND NOT EXISTS(SELECT 1 
cQry1 += CRLF +  " 				FROM " +RetSqlName("DUY")+ " DUY "
cQry1 += CRLF +  " 				WHERE	DUY_FILIAL = '"+xFilial("DUY")+"' "
cQry1 += CRLF +  " 	           AND DUY_EST = CC2.CC2_EST "
cQry1 += CRLF +  " 				  AND DUY_CATGRP = '3' "
cQry1 += CRLF +  " 				  AND DUY_GRPSUP <> '' "
cQry1 += CRLF +  " 				  AND DUY_CODMUN = CC2_CODMUN "
cQry1 += CRLF +  " 				  AND DUY.D_E_L_E_T_ = '') "
cQry1 += CRLF +  "ORDER BY CC2_EST, CC2_MUN "

cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

// Carregar aqui as Colunas da GetDados.

If (cAliasQry)->( Eof() )
	Aadd(aColsReg, { 	"LBNO", "", "", "", .F.})
EndIf

While (cAliasQry)->( !Eof() )
	Aadd(aColsReg, { ;
		"LBNO",;
		(cAliasQry)->CC2_EST      ,;
		(cAliasQry)->CC2_CODMUN       ,;
		(cAliasQry)->CC2_MUN       ,;
		.F. })
	(cAliasQry)->( DbSkip() )
EndDo

(cAliasQry)->( DbCloseArea() )

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS120Grp  ³ Autor ³ Jefferson Tomaz     ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega dados do grupo de regiao que nao estao na estrutura³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS120Gpr()

Local lRet			:= .T.
Local nX            := 0
Local aCpoGDa       := { "DUY_GRPVEN","DUY_DESCRI","DUY_EST", "DUY_CODMUN" }
Local cQry1         := ""
Local cAliasQry     := GetNextAlias()
Local nPos          := 0
Local aCampos  		:= FwFormStruct(2,"DUY")

// Carrega aHead
aHeaderGrp := {}
aColsGrp   := {}

Aadd(aHeaderGrp,{"","OK","@BMP",1,0,"","","","","","",""})

For nX := 1 to Len(aCpoGDa)
  	nPos := AScan(aCampos:aFields, { |coluna| AllTrim(coluna[1]) == Alltrim(aCpoGDa[nX])}) 
	              
	If nPos > 0

		AAdd( aHeaderGrp,{ FWX3Titulo(aCampos:aFields[nPos,1])     				,; //| Titulo do Campo
				 		   AllTrim( aCampos:aFields[nPos,1])                 	,; //| X3_Campo
						   X3Picture(aCampos:aFields[nPos][1])	            	,; //| picture
						   TamSx3(aCampos:aFields[nPos][1])[1]					,; //| tamanho
						   TamSX3(aCampos:aFields[nPos][1])[2]					,; //| decimal
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_VALID")  	,; //| valid
                       	   GetSx3Cache(aCampos:aFields[nPos][1],"X3_USADO")  	,; //| usado
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_TIPO")   	,; //| tipo
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_ARQUIVO")	,; //| arquivo
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_CONTEXT")	,; //| context
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_CBOX")		,; //| CBOX
						   GetSx3Cache(aCampos:aFields[nPos][1],"X3_RELACAO")})  //| relacao	 
		 				 
	EndIf
Next nX


cQry1 := CRLF +  " SELECT DUY_GRPVEN, DUY_DESCRI, DUY_EST, DUY_CODMUN "
cQry1 += CRLF +  "  FROM " +RetSqlName("DUY")+ " DUY "
cQry1 += CRLF +  " WHERE DUY_FILIAL = '" +xFilial("DUY")+"' "
cQry1 += CRLF +  "   AND DUY_GRPSUP = '' "
cQry1 += CRLF +  "   AND DUY_CATGRP = '3' "
cQry1 += CRLF +  "   AND D_E_L_E_T_ = '' "
cQry1 += CRLF +  " ORDER BY DUY_EST "

cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

// Carregar aqui as Colunas da GetDados.

If (cAliasQry)->( Eof() )
	Aadd(aColsGrp, { 	"LBNO", "", "", "", "", .F.})
EndIf

While (cAliasQry)->( !Eof() )
	Aadd(aColsGrp, { ;
		"LBNO",;
		(cAliasQry)->DUY_EST          ,;
		(cAliasQry)->DUY_GRPVEN      ,;
		(cAliasQry)->DUY_DESCRI       ,;
		(cAliasQry)->DUY_CODMUN       ,;
		.F. })
	(cAliasQry)->( DbSkip() )
EndDo

(cAliasQry)->( DbCloseArea() )

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Mrk ³ Autor ³ Jefferson Tomaz     ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama função para marcar ou desmarcar no grid              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMSA120Mrk(nTipSel, nOption)

Default nTipSel := 0
Default nOption := 0

If nOption == 1
	TMS120Clic(oNewGetEst, nTipSel)
ElseIf nOption == 2
	TMS120Clic(oNewGetFil, nTipSel)
ElseIf nOption == 3
	TMS120Clic(oNewGetReg, nTipSel, .T.)
ElseIf nOption == 4
	TMS120Clic(oNewGetGrp, nTipSel)
EndIf

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS120Clic ³ Autor ³ Jefferson Tomaz     ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca e desmarca no grid                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS120Clic(oGetdTab,nTpSel, lMrkUfMun)
Local nCount := 0

Default oGetdTab  := Nil
Default nTpSel    := 0
Default lMrkUfMun := .F.

If nTpSel = 1
	If	oGetdTab:aCols[oGetdTab:oBrowse:nAt, GdFieldPos("OK", oGetdTab:aHeader)] == "LBOK"
		oGetdTab:aCols[oGetdTab:oBrowse:nAt, GdFieldPos("OK", oGetdTab:aHeader)] := "LBNO"
	Else
		oGetdTab:aCols[oGetdTab:oBrowse:nAt, GdFieldPos("OK", oGetdTab:aHeader)] := "LBOK"
	EndIf
ElseIf nTpSel = 2 
	If !lMrkUfMun
		For nCount := 1 to Len(oGetdTab:aCols)
			oGetdTab:aCols[nCount, GdFieldPos("OK", oGetdTab:aHeader)] := "LBOK"
		Next nCount
	Else	
		cEst   := oGetdTab:aCols[oGetdTab:nAt, GdFieldPos("CC2_EST", oGetdTab:aHeader)]
		For nCount := aScan(oGetdTab:aCols,{|x| x[2] == oGetdTab:aCols[oGetdTab:nAt, GdFieldPos("CC2_EST", oGetdTab:aHeader)] }) to Len(oGetdTab:aCols)
			If cEst == oGetdTab:aCols[nCount, GdFieldPos("CC2_EST", oGetdTab:aHeader)]
				oGetdTab:aCols[nCount, GdFieldPos("OK", oGetdTab:aHeader)] := "LBOK"
			Else
				Exit
			EndIf
		Next nCount
	EndIf
ElseIf nTpSel = 3
	For nCount := 1 to Len(oGetdTab:aCols)
		oGetdTab:aCols[nCount, GdFieldPos("OK", oGetdTab:aHeader)] := "LBNO"
	Next nCount	
EndIf

oGetdTab:Refresh()
oGetdTab:oBrowse:Refresh()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSa120Arg  ³ Autor ³ Jefferson Tomaz    ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Uf/Filial/regiao atraves de rot. automatica          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 12/08/13 ³ Mauro Paladini³ Corrigido ordem que os campos estavam sendo³±±
±±³          ³               ³ passados na Execauto de criacao da TMSA115 ³±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMSA120Arg(oMenu, nOption)

Local lRet    := .T.
Local aCab    := {}
Local nI      := 0
Local cCargo  := oTree:GetCargo()
Local lSeek   := .F.
Local cUfSup  := Posicione("DUY",1,xFilial("DUY")+ cCargo, "DUY_EST")
Local cCampo  := Space(Len(DUY->DUY_CDRCOL))
Local lCdrCol := .F.
Local cCodReg := ""
Local cMvCodReg1 := SuperGetMv('MV_CESTREG',.F.,"__cEstReg")
Local cMvCodReg2 := SuperGetMv('MV_CFILREG',.F., "'FL'+__cFilReg")
Local cMvCodReg3 := SuperGetMv('MV_CGRPREG',.F.,"TMS120CDUF(__cEstReg)+__cCodIbge")

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private __cEstReg   := ''
Private __cFilReg   := ''
Private __CodIbge   := ''

Default oMenu       := Nil
Default nOption     := 0

If nOption == 1
	For nI:= 1 To Len(oNewGetEst:aCols)
		If oNewGetEst:aCols[nI, GdFieldPos("OK", oNewGetEst:aHeader)] == "LBOK"
			
			__cEstReg := oNewGetEst:aCols[nI, GdFieldPos("X5_CHAVE", oNewGetEst:aHeader)]
			cCodReg   := &(cMvCodReg1)
			If !oTree:TreeSeek( cCodReg )
				DUY->(DbSetOrder(4))
				If lSeek := ( !DUY->(MsSeek(xFilial("DUY")+Padr(__cEstReg, Len(DUY->DUY_EST)) + StrZero(1,Len(DUY->DUY_CATGRP)) )) )
					aCab := {}
					
					Aadd(aCab,{"DUY_EST"   ,Padr(oNewGetEst:aCols[nI, GdFieldPos("X5_CHAVE",  oNewGetEst:aHeader)], TamSx3("DUY_EST")[1] ),NIL})
					Aadd(aCab,{"DUY_GRPVEN",cCodReg,".T."})
					Aadd(aCab,{"DUY_DESCRI",Padr(oNewGetEst:aCols[nI, GdFieldPos("X5_DESCRI", oNewGetEst:aHeader)], TamSx3("DUY_DESCRI")[1] ),NIL})
					Aadd(aCab,{"DUY_GRPSUP","",NIL})
					Aadd(aCab,{"DUY_FILDES","",NIL})
					Aadd(aCab,{"DUY_CDRCOL","",NIL})
					Aadd(aCab,{"DUY_REGCOL","",NIL})
					Aadd(aCab,{"DUY_CATREG","1",NIL})
					Aadd(aCab,{"DUY_CDRTAX","",NIL})
					Aadd(aCab,{"DUY_CATGRP","1",NIL})
					Aadd(aCab,{"DUY_REGISE","2",NIL})
					Aadd(aCab,{"DUY_ALQISS",0,NIL}) 

					MsExecAuto({|x,y,z|Tmsa115(x,y,z)},aCab,3)
					
					If lMsErroAuto
						MostraErro()
						lRet := .F.
						Exit
					Else
						DUY->(DbSetOrder(4))
						If !DUY->(MsSeek(xFilial("DUY")+Padr(oNewGetEst:aCols[nI, GdFieldPos("X5_CHAVE",  oNewGetEst:aHeader)], TamSx3("DUY_EST")[1] ) + StrZero(1,Len(DUY->DUY_CATGRP)) ))
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				If lRet .Or. !lSeek					
					TMA120Menu(oMenu , 'INCEST', , .T., cCargo)
				EndIf
				lRet  := .T.
				lSeek := .F.
			EndIf
			oNewGetEst:aCols[nI, GdFieldPos("OK", oNewGetEst:aHeader)] := "LBNO"
		EndIf
	Next nI
	
ElseIf nOption == 2
	For nI:= 1 To Len(oNewGetFil:aCols)
		If oNewGetFil:aCols[nI, GdFieldPos("OK", oNewGetFil:aHeader)] == "LBOK"
			
			__cFilReg := oNewGetFil:aCols[nI, GdFieldPos("RECNO", oNewGetFil:aHeader)]
			cCodReg   := &(cMvCodReg2)
			If !oTree:TreeSeek( cCodReg )
				DUY->(DbSetOrder(5))
				If lSeek := ( !DUY->(MsSeek(xFilial("DUY")+;
					Padr(oNewGetFil:aCols[nI, GdFieldPos("M0_CODFIL", oNewGetFil:aHeader)], Len(DUY->DUY_FILDES))+;
					StrZero(2,Len(DUY->DUY_CATGRP)) )) )

					aCab := {}

					Aadd(aCab,{"DUY_EST"	,Padr(oNewGetFil:aCols[nI, GdFieldPos("M0_ESTCOB", oNewGetFil:aHeader)], TamSx3("DUY_EST")[1] ),NIL})
					Aadd(aCab,{"DUY_CODMUN"	,Padr(SubStr(oNewGetFil:aCols[nI, GdFieldPos("M0_CODMUN", oNewGetFil:aHeader)],3,5), TamSx3("DUY_CODMUN")[1] ),NIL})					
					Aadd(aCab,{"DUY_GRPVEN"	,cCodReg,NIL})
					Aadd(aCab,{"DUY_DESCRI"	,Padr(oNewGetFil:aCols[nI, GdFieldPos("M0_NOME", oNewGetFil:aHeader)], TamSx3("DUY_DESCRI")[1] ),NIL})
					Aadd(aCab,{"DUY_GRPSUP"	,"",NIL})
					Aadd(aCab,{"DUY_FILDES"	,Padr(oNewGetFil:aCols[nI, GdFieldPos("M0_CODFIL", oNewGetFil:aHeader)], TamSx3("DUY_FILDEST")[1] ),NIL})
					Aadd(aCab,{"DUY_CDRCOL"	,"",NIL})
					Aadd(aCab,{"DUY_REGCOL"	,"",NIL})
					Aadd(aCab,{"DUY_CATREG"	,"1",NIL})
					Aadd(aCab,{"DUY_CDRTAX"	,"",NIL})
					Aadd(aCab,{"DUY_CATGRP"	,"2",NIL})
					Aadd(aCab,{"DUY_REGISE"	,"2",NIL})
					Aadd(aCab,{"DUY_ALQISS"	,0,NIL})
					
					MsExecAuto({|x,y,z|Tmsa115(x,y,z)},aCab,3)
					
					If lMsErroAuto
						MostraErro()
						lRet := .F.
						Exit
					Else
						DUY->(DbSetOrder(5))
						If !DUY->(MsSeek(xFilial("DUY")+Padr(oNewGetFil:aCols[nI, GdFieldPos("M0_CODFIL", oNewGetFil:aHeader)], TamSx3("DUY_FILDEST")[1] ) + StrZero(2,Len(DUY->DUY_CATGRP))+cCodReg ))
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				If (lRet .Or. !lSeek)
					TMA120Menu(oMenu , 'INCFIL', , .T., cCargo)
				EndIf
				lRet  := .T.
				lSeek := .F.
			EndIf
			oNewGetFil:aCols[nI, GdFieldPos("OK", oNewGetFil:aHeader)] := "LBNO"
		EndIf
	Next nI
	
ElseIf nOption == 3
	
	For nI:= 1 To Len(oNewGetReg:aCols)
		If oNewGetReg:aCols[nI, GdFieldPos("OK", oNewGetReg:aHeader)] == "LBOK"
			
			__cEstReg  := AllTrim(oNewGetReg:aCols[nI, GdFieldPos("CC2_EST", oNewGetReg:aHeader)])
			__cCodIbge := oNewGetReg:aCols[nI, GdFieldPos("CC2_CODMUN", oNewGetReg:aHeader)]
			
			cCodReg    := &(cMvCodReg3)
			If !oTree:TreeSeek( cCodReg )

				aCab := {}
				
				If (cUfSup <> oNewGetReg:aCols[nI, GdFieldPos("CC2_EST", oNewGetReg:aHeader)] .And. !Empty(cUfSup)) .And. !lCdrCol
					
					If !Empty(aGrupoExc) .Or. !Empty(aGrupoAtu)
						//-- Atualizacao da estrutura.
						If TMA120VEstr(2)
							aGrupoExc := {}
							aGrupoAtu := {}
						EndIf
					EndIf
					
					lCdrCol := TMSA120COL(@cCampo)
					cCampo  := Alltrim(cCampo)
					
					If !lCdrCol
						Exit
					EndIf
				ElseIf cUfSup == oNewGetReg:aCols[nI, GdFieldPos("CC2_EST", oNewGetReg:aHeader)] .And. lCdrCol
					cCampo	:= ""
					lCdrCol	:= .F.
				EndIf
				
				DUY->(DbSetOrder(1))
				If lSeek := !DUY->(MsSeek(xFilial("DUY")+ Padr(cCodReg, Len(DUY->DUY_GRPVEN))  ))
					
					Aadd(aCab,{"DUY_EST"	,Padr(oNewGetReg:aCols[nI, GdFieldPos("CC2_EST", oNewGetReg:aHeader)], TamSx3("DUY_EST")[1] ),NIL})
					Aadd(aCab,{"DUY_CODMUN"	,Padr(AllTrim(oNewGetReg:aCols[nI, GdFieldPos("CC2_CODMUN", oNewGetReg:aHeader)]), TamSx3("DUY_CODMUN")[1] ),NIL})
					Aadd(aCab,{"DUY_GRPVEN"	,cCodReg,NIL})
					Aadd(aCab,{"DUY_DESCRI"	,Padr(oNewGetReg:aCols[nI, GdFieldPos("CC2_MUN", oNewGetReg:aHeader)], TamSx3("DUY_DESCRI")[1] ),NIL})
					Aadd(aCab,{"DUY_GRPSUP"	,"",NIL})
					Aadd(aCab,{"DUY_FILDES"	,"",NIL})
					Aadd(aCab,{"DUY_CDRCOL"	,cCampo,NIL})
					Aadd(aCab,{"DUY_REGCOL"	,"",NIL})
					Aadd(aCab,{"DUY_CATREG"	,"1",NIL})
					Aadd(aCab,{"DUY_CDRTAX"	,"",NIL})
					Aadd(aCab,{"DUY_CATGRP"	,"3",NIL})
					Aadd(aCab,{"DUY_REGISE"	,"2",NIL})
					Aadd(aCab,{"DUY_ALQISS"	,0,NIL})
					
					MsExecAuto({|x,y,z|Tmsa115(x,y,z)},aCab,3)
					
					If lMsErroAuto
						MostraErro()
						lRet := .F.
						Exit
					Else
						DUY->(DbSetOrder(1))
						If !DUY->(MsSeek(xFilial("DUY")+cCodReg ))
							lRet := .F.
							Exit
						EndIf
					EndIf
				ElseIf AllTrim(DUY->DUY_CDRCOL) <> cCampo
					RecLock("DUY",.F.)
					DUY->DUY_CDRCOL := cCampo
					MsUnLock()
				EndIf
				
				If (lRet .Or. !lSeek)
					TMA120Menu(oMenu , 'INCREG', , .T., cCargo)
				EndIf
				lRet  := .T.
				lSeek := .F.
			EndIf
			oNewGetReg:aCols[nI, GdFieldPos("OK", oNewGetReg:aHeader)] := "LBNO"
		EndIf
	Next nI	

ElseIf nOption == 4

	For nI:= 1 To Len(oNewGetGrp:aCols)
		If oNewGetGrp:aCols[nI, GdFieldPos("OK", oNewGetGrp:aHeader)] == "LBOK" .And.;
			!oTree:TreeSeek( oNewGetGrp:aCols[nI, GdFieldPos("DUY_GRPVEN", oNewGetGrp:aHeader)] )
			
			If (cUfSup <> oNewGetGrp:aCols[nI, GdFieldPos("DUY_EST", oNewGetGrp:aHeader)] .And. !Empty(cUfSup)) .And. !lCdrCol
				
				If lRet .And. !Empty(aGrupoExc) .Or. !Empty(aGrupoAtu)
					//-- Atualizacao da estrutura.
					If TMA120VEstr(2)
						aGrupoExc := {}
						aGrupoAtu := {}
					EndIf
				EndIf
				
				lCdrCol := TMSA120COL(@cCampo)
				cCampo  := Alltrim(cCampo)
				
				If !lCdrCol
					Exit
				EndIf
			ElseIf cUfSup == oNewGetGrp:aCols[nI, GdFieldPos("DUY_EST", oNewGetGrp:aHeader)] .And. lCdrCol
				cCampo	:= ""
				lCdrCol	:= .F.
			EndIf
			
			DUY->(DbSetOrder(1))
			If DUY->(MsSeek(xFilial("DUY")+oNewGetGrp:aCols[nI, GdFieldPos("DUY_GRPVEN", oNewGetGrp:aHeader)]))
				If (!Empty(cCampo) .And. Alltrim(DUY->DUY_CDRCOL) <> cCampo) .Or.;
					cUfSup == oNewGetGrp:aCols[nI, GdFieldPos("DUY_EST", oNewGetGrp:aHeader)]
					
					RecLock("DUY",.F.)
					DUY->DUY_CDRCOL := cCampo
					MsUnLock()
					
				EndIf
				TMA120Menu(oMenu , 'INCREG', , .T., cCargo)
			EndIf
			oNewGetGrp:aCols[nI, GdFieldPos("OK", oNewGetGrp:aHeader)] := "LBNO"
		EndIf
	Next nI
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS120CdUf  ³ Autor ³ Jefferson Tomaz    ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o codigo IBGE do estado ou um codigo sequencial    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMS120CdUf(cEst, cTipRet)

Local aUF  := {}
Local cRet := ""
Local nPos := 0

Default cTipRet := "2"

Aadd(aUF,{"AC","12","1"})
Aadd(aUF,{"AL","27","2"})
Aadd(aUF,{"AM","13","3"})
Aadd(aUF,{"AP","16","4"})
Aadd(aUF,{"BA","29","5"})
Aadd(aUF,{"CE","23","6"})
Aadd(aUF,{"DF","53","7"})
Aadd(aUF,{"ES","32","8"})
Aadd(aUF,{"GO","52","9"})
Aadd(aUF,{"MA","21","A"})
Aadd(aUF,{"MG","31","B"})
Aadd(aUF,{"MS","50","C"})
Aadd(aUF,{"MT","51","D"})
Aadd(aUF,{"PA","15","E"})
Aadd(aUF,{"PB","25","F"})
Aadd(aUF,{"PE","26","G"})
Aadd(aUF,{"PI","22","H"})
Aadd(aUF,{"PR","41","I"})
Aadd(aUF,{"RJ","33","J"})
Aadd(aUF,{"RN","24","K"})
Aadd(aUF,{"RO","11","L"})
Aadd(aUF,{"RR","14","M"})
Aadd(aUF,{"RS","43","N"})
Aadd(aUF,{"SC","42","O"})
Aadd(aUF,{"SE","28","P"})
Aadd(aUF,{"SP","35","Q"})
Aadd(aUF,{"TO","17","R"})

/*---------------------------------------------------------------
cTipRet = 1 - Retorno do código do estado
cTipRet = 2 - Retorno de letra
cTipRet = 3 - Retorno da silga do estado

cEst - Sigla do estado ou Código do estado (para cTipRet = 3)

------------------------------------------------------------------*/

If cTipRet == "3"
	nPos := Ascan(aUF, {|x| x[2] == cEst})
Else
	nPos := Ascan(aUF,{|x| x[1] == cEst})
EndIF

If nPos > 0  
	If cTipRet == "1"
		cRet := aUF[nPos,2]
	ElseIf cTipRet == "2"	
		cRet := aUF[nPos,3]
	ElseIf cTipRet == "3"
		cRet := aUF[nPos,1]
	EndIf
Else
	If cTipRet == "1"
		cRet := "99"
	Else
		cRet := "Z"
	EndIf
EndIf

Return(cRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Psq  ³ Autor ³ Jefferson Tomaz    ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de pesquisa                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS120Psq(nOption )

Local aCbx		:= {}
Local cCampo	:= ''
Local cOrd
Local lSeek		:= .F.
Local nOrdem	:= 1
Local nSeek		:= 0
Local oCbx
Local oDlg
Local oPsqGet
Local nPosCpIdx1 := 0
Local nPosCpIdx2 := 0

Default nOption := 0

If nOption == 1
	nPosCpIdx1 := GdFieldPos("X5_CHAVE",oNewGetEst:aHeader)
	cCampo := oNewGetEst:aHeader[nPosCpIdx1,1]
	Aadd( aCbx, AllTrim(cCampo) )
ElseIf nOption == 2
	nPosCpIdx1 := GdFieldPos("M0_CODFIL",oNewGetFil:aHeader)
	cCampo := oNewGetFil:aHeader[nPosCpIdx1,1]
	Aadd( aCbx, AllTrim(cCampo) )
ElseIf nOption == 3
	nPosCpIdx1 := GdFieldPos("CC2_EST",oNewGetReg:aHeader)
	cCampo := oNewGetReg:aHeader[nPosCpIdx1,1]
	Aadd( aCbx, AllTrim(cCampo) )
	
	nPosCpIdx1 := GdFieldPos("CC2_EST",oNewGetReg:aHeader)
	nPosCpIdx2 := GdFieldPos("CC2_MUN",oNewGetReg:aHeader)
	cCampo := oNewGetReg:aHeader[nPosCpIdx1,1] +"+"+ oNewGetReg:aHeader[nPosCpIdx2,1]
	Aadd( aCbx, AllTrim(cCampo) )
ElseIf nOption == 4
	nPosCpIdx1 := GdFieldPos("DUY_EST",oNewGetGrp:aHeader)
	cCampo := oNewGetGrp:aHeader[nPosCpIdx1,1]
	Aadd( aCbx, AllTrim(cCampo) )

	nPosCpIdx2 := GdFieldPos("DUY_GRPVEN",oNewGetGrp:aHeader)
	cCampo := oNewGetGrp:aHeader[nPosCpIdx2,1]
	Aadd( aCbx, AllTrim(cCampo) )
EndIf

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0002	// -- "Pesquisar"

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL 

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	cCampo := Upper(AllTrim( cCampo ))
	If nOption == 1
		nSeek := aScan( oNewGetEst:aCols,{ | x | AllTrim( x[ nPosCpIdx1 ] ) == Alltrim(cCampo) } )		
	ElseIf nOption == 2
		nSeek := aScan( oNewGetFil:aCols,{ | x | AllTrim( x[ nPosCpIdx1 ] ) == Alltrim(cCampo) } )
	ElseIf nOption == 3
		If nOrdem == 1
			nSeek := aScan( oNewGetReg:aCols,{ | x | AllTrim( x[ nPosCpIdx1 ] ) == Alltrim(cCampo) } )
		ElseIf nOrdem == 2
			nSeek := aScan( oNewGetReg:aCols,{ | x | AllTrim( x[ nPosCpIdx1 ] + x[ nPosCpIdx2 ] ) == Alltrim(cCampo) } )
		EndIf
	ElseIf nOption == 4
		If nOrdem == 1
			nSeek := aScan( oNewGetGrp:aCols,{ | x | AllTrim( x[ nPosCpIdx1 ] ) == Alltrim(cCampo) } )
		ElseIf nOrdem == 2
			nSeek := aScan( oNewGetGrp:aCols,{ | x | AllTrim( x[ nPosCpIdx2 ] ) == Alltrim(cCampo) } )
		EndIf
	EndIf
EndIf

If nSeek > 0
	If nOption == 1
		oNewGetEst:oBrowse:nAt := nSeek
		oNewGetEst:oBrowse:Refresh()
	ElseIf nOption == 2
		oNewGetFil:oBrowse:nAt := nSeek
		oNewGetFil:oBrowse:Refresh()
	ElseIf nOption == 3
		oNewGetReg:oBrowse:nAt := nSeek
		oNewGetReg:oBrowse:Refresh()
	ElseIf nOption == 4
		oNewGetGrp:oBrowse:nAt := nSeek
		oNewGetGrp:oBrowse:Refresh()
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA120Col³ Autor ³ Jefferson Tomaz      ³ Data ³18.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informar a Regiao Coligada                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMSA120Col(cCampo)

Local oDlg	 		:= Nil
Local oCrdColGet	:= Nil
Local lCdrCol	 	:= .F.

Default cCampo		:= ""
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 100,350 PIXEL TITLE STR0049	// -- "Informe a Regiao Coligada"
	
	@ 04,05 Say STR0050 OF oDlg PIXEL // "O estado do nível superior é difernte do enviado a"
	@ 11,05 Say STR0051 OF oDlg PIXEL //"estrutura. Informe a Regiao coligada:"
	
	@ 22,05 MSGET oCrdColGet VAR cCampo  F3 "DUY1" Valid !Empty(cCampo) .And. ExistCpo("DUY",cCampo,1) SIZE 125,10 PIXEL
	
	DEFINE SBUTTON FROM 05,140 TYPE 1 OF oDlg ENABLE ACTION (lCdrCol := .T.,oDlg:End())
	DEFINE SBUTTON FROM 20,140 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return(lCdrCol)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA120XBI  ³ Autor ³ Mauro Paladini     ³ Data ³ 16/10/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Inclusao - TMSA115 - MVC                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - DCY                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador    ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA120XBI()

Local aArea := GetArea()

SAVEINTER()

FWExecView(STR0010,"VIEWDEF.TMSA115", MODEL_OPERATION_INSERT,, { || .T. } ,,  /*nPerReducTela*/ ) //'Inclusão'

RESTINTER()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSA120XBV  ³ Autor ³ Mauro Paladini     ³ Data ³ 16/10/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Visualizacao - TMSA115 - MVC               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - DCY                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador    ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA120XBV()

Local aArea      := GetArea()
Local cOldFilter := DCY->(dbFilter())
Local IncOld     := Inclui

Inclui := .F.

SAVEINTER()

DCY->( dbClearFilter() )

FWExecView(STR0011,"VIEWDEF.TMSA115", MODEL_OPERATION_VIEW ,, { || .T. } ,, /*nPerReducTela*/ ) //'Visualizar'

RESTINTER()

If !Empty( cOldFilter )
	Set Filter to &cOldFilter
EndIf

Inclui := IncOld

RestArea(aArea)

Return
