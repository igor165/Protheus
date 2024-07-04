#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TRhWorkArea.CH"

//-------------------------------------------------------------------
Function __TRhWorkArea() // Function Dummy
ApMsgInfo( 'TRhWorkArea -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} TRhWorkArea
CLASS TRhWorkArea

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TRhWorkArea

DATA oMainDlg 	//Janela Principal
DATA oWorkarea 
DATA cTitulo 	//Título da janela
DATA nMenuSize	//Tamanho do Menu
DATA oMenu		//Menu
DATA aSizeDlg


METHOD New (cTitulo) CONSTRUCTOR
METHOD Activate()
METHOD Sair()

METHOD LoadMenu(oMenu,cTipo)

METHOD GetPanel(cId)
METHOD GetRelSize(nPerc)

METHOD SetMenu(oMenu, nSize)
METHOD SetMenuRotina(oMenu, aMenu)
METHOD SetLayout(aTelas)
METHOD SetWidget( oPanel, cAliasEnt, cFonte, cType, cFiltro )
METHOD SetBrowse( oPanel, cAliasEnt, cMenuDef, cDescric,cFilterDefault,lDisableDet,lDisableRep,lDisableConf)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurAreaTrabalho
CLASS TRhWorkArea

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTitulo) CLASS TRhWorkArea	
Self:aSizeDlg := FWGetDialogSize( oMainWnd ) //Pega o tamanho da tela atual do SmartClient

Self:nMenuSize := 200 //define o valor default para o tamanho do menu
Self:oMainDlg := MSDialog():New( Self:aSizeDlg[1], Self:aSizeDlg[2], Self:aSizeDlg[3], Self:aSizeDlg[4], cTitulo, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

Self:oWorkarea := FWUIWorkArea():New( Self:oMainDlg ) //instancia a WorkArea
   
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} loadMenu(oMenu)
Método que carrega o menu lateral.

@Param	oMenu		Objeto FWMenu previamente carregado.

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD LoadMenu(oMenu,cTipo) CLASS TRhWorkArea


Default oMenu := NIL
Default cTipo := 1

if (oMenu == NIL) //inicialização padrão do menu
	Self:oMenu := FWMenu():New()
	Self:oMenu:Init()
	Self:oMenu:AddContent( STR0001		, "E", "" )	// "Área de trabalho"
	If cTipo == 1
		Self:oMenu:AddContent( STR0008		, "E", { || GPEW020(self,2) } )	// Layout sem grafico		
	Else
		Self:oMenu:AddContent( STR0007		, "E", { || GPEW020(self,1) } )	// layout com grafico		
	EndIf
	Self:oMenu:AddContent( STR0005		, "E", {|| Self:Sair()} )	// "Sair"
	Self:oMenu:AddSeparator()
Else
	Self:oMenu := oMenu
Endif

Return Self:oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMenu(oMenu)
Método que carrega o menu lateral.

@Param	oMenu		Objeto FWMenu com os itens
@Param	nSize		Tamanho <-> do menu na tela, padrão 200.

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetMenu(oMenu, nSize) CLASS TRhWorkArea
Default nSize := 200

Self:nMenuSize := nSize
Self:oMenu := oMenu
Self:oWorkarea:SetMenu( Self:oMenu )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMenuRotina(oMenu,aMenu)
Método que carrega o menu lateral.

@Param	oMenu		Objeto FWMenu previamente carregado.

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetMenuRotina(oMenu,aMenu) CLASS TRhWorkArea
	Local lHasAccess := .T.
	Local nI		 := 1
	Local nY		 := 1
	Local cMenuItem
	Local nBKPnMod := nModulo

	For nI := 1 To Len(aMenu) //LEN 7
		cMenuItem := oMenu:AddFolder( aMenu[nI][1], "E" )
		
		For nY := 1 To Len(aMenu[nI][2]) // LEN 4
			If nY == 1
				oMenuItem := oMenu:GetItem( cMenuItem )
			EndIf
			
			nModulo    := aMenu[nI][2][nY][4]
			lHasAccess := MPUserHasAccess(aMenu[nI][2][nY][3],,,,)
			
			If lHasAccess
				cMenuItem := oMenuItem:AddContent(aMenu[nI][2][nY][1], "E", aMenu[nI][2][nY][2])
			EndIf

		Next nY
		oMenu:AddSeparator()
	Next nI	
	nModulo := nBKPnMod
Return Self:oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLayout(aTelas)
Método que vai receber a forma que será criada o layout da tela.

@Param	aTelas		Array com detalhes referentes as telas. {'01' ID da tela, 50 % tamanho vertical da tela útil, .T. Indica se ocupará a linha inteira ou não}
@Param	lColunas	Variável lógica que indica se o layout será quebrado em colunas ou uma tela por linha

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetLayout(aTelas) CLASS TRhWorkArea
Local nT := 0
Local nL := 0
Local nTelas := 0
Local cLinha := ""
Local nPanels	:= 0
Local aPanels	
Local nI		:= 1
Local oTmp 		:= Nil

Default aTelas := {{"01",70,.T.},{"02",30,.T.}}

//Monta as talas a partir do array informado
nTelas := len(aTelas)

nL := 0
nT := 0

For nT := 1 to nTelas
	nL++
	
	cLinha := PADL(AllTrim(Str(nL)),2,'0')
	Self:oWorkarea:CreateHorizontalBox( "LINE" + cLinha, Self:getRelSize(aTelas[nT][2]), .T. )
	
	//Inicializa a posição do array caso não tenha sido informada.
	If Len(aTelas[nT]) == 2
		aAdd(aTelas[nT] , .F.)
	EndIf
	
	If aTelas[nT][3] == .F. .And. nT < nTelas 
		Self:oWorkarea:SetBoxCols( "LINE" + cLinha, { "WDGT" + aTelas[nT][1], "WDGT" + aTelas[nT+1][1] } )
		nT++
	ElseIf (nL == nTelas .Or. aTelas[nT][3] == .T.)
		Self:oWorkarea:SetBoxCols( "LINE" + cLinha, { "WDGT" + aTelas[nT][1] } )
	EndIf
Next

//Tamanho menu
Self:oWorkarea:SetMenuWidth( Self:nMenuSize )

//Ativa a WorkArea
Self:oWorkarea:Activate()

nPanels	:= Len(Self:oWorkarea:aPanels)
aPanels	:= Self:oWorkarea:aPanels

For nI := 1 To nPanels
	oTmp := Self:oWorkarea:GetPanel(aPanels[nI][1] )
	oTmp:cName := aPanels[nI][1]
Next nI

Return

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRelSize(nPerc)
Método que recebe uma porcentagem e devolve o tamanho absoluto do camponente

@Param	nPerc		Percentagem do tamanho relativo do componente

@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetRelSize(nPerc) CLASS TRhWorkArea
Local nSize

nSize := Round( (( Self:aSizeDlg[3] * nPerc) / 100) ,0) +10

Return nSize 

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Método que inicializa o componente na tela


@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Activate() CLASS TRhWorkArea

Self:oMainDlg:Activate( , , , , , , ) //ativa a janela

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Sair()
Método que fecha a tela


@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Sair() CLASS TRhWorkArea

Local nPanels	:= Len(Self:oWorkarea:aPanels)
Local aPanels	:= Self:oWorkarea:aPanels
Local nI		:= 1
Local oTmp 		:= Nil

For nI := 1 To nPanels
	oTmp := Self:oWorkarea:GetPanel(aPanels[nI][1] )
	oTmp:Destroy()
Next nI
Self:oMainDlg:End() //fecha a janela

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPanel(cId)
Método que fecha a tela


@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetPanel(cId) CLASS TRhWorkArea
Return Self:oWorkarea:GetPanel( "WDGT" + cId )


//-------------------------------------------------------------------
/*/{Protheus.doc} SetWidget(oPanel, cAliasEnt, cFonte, cType ,cFiltro)
Monta uma widget de acordo com os parametros


@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetWidget( oPanel, cAliasEnt, cFonte, cType ,cFiltro,cDescr) CLASS TRhWorkArea
Local oWidget      := FWTableAttachWidget():New()
Local oTableAttach := FWGetAttSrc( cFonte ) 
Local aVisions     := {}
Local aCharts      := {}
Local oMBrowse     := oWidget:GetBrowse()

If ValType( oPanel ) == "O"
	If oTableAttach <> nil
		oMBrowse:SetMenuDef( cFonte )      
		aVisions := oTableAttach:aViews
		aCharts  := oTableAttach:aCharts	
		
		oWidget:setVisions( aVisions )
		oWidget:setCharts( aCharts )
		oWidget:setAlias( cAliasEnt )	
		oWidget:setBrwDescription(cDescr)
		oWidget:setVisionDefault( aVisions[1] )
		oWidget:setChartDefault( aCharts[1] )
		oWidget:setDisplayMode( cType )	
		oWidget:setOwner( oPanel )
		oWidget:setOpenChart( .T. )
		If !Empty(cFiltro)
			oWidget:AddFilter( STR0006 , cFiltro )//"Filtro"
		EndIf 
		oWidget:Activate()
		
		//feito desse jeito, por que o Frame não passou uma maneira de inibir o menu padrao do objeto.
		If valtype(oWidget:owidgetchart) != "U" .And. Len(oWidget:owidgetchart:odropmenu:aitems) == 4
			adel(oWidget:owidgetchart:odropmenu:aitems,4)
			adel(oWidget:owidgetchart:odropmenu:aitems,3)
			aSize(oWidget:owidgetchart:odropmenu:aitems,2)
		EndIf	
	EndIf
EndIf

Return oWidget

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBrowse( oPanel, cAliasEnt, cMenuDef, cDescric,cFilterDefault,lDisableDet,lDisableRep,lDisableConf)
Monta browse de acordo com os parametros


@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetBrowse( oPanel, cAliasEnt, cMenuDef, cDescric,cFilterDefault,lDisableDet,lDisableRep,lDisableConf) CLASS TRhWorkArea

Local oBrw
Default lDisableDet 	:= .F.
Default lDisableRep 	:= .F.
Default lDisableConf 	:= .F.

oBrw:= FwMBrowse():New()
oBrw:SetAlias(cAliasEnt)
oBrw:SetDescription(oEmToAnsi(cDescric)) 			
If lDisableDet
	oBrw:DisableDetails()
EndIf
If lDisableRep
	oBrw:DisableReport()
EndIf
If lDisableConf
	oBrw:DisableConfig()
	oBrw:DisableSaveConfig()
EndIf
If !Empty(cMenuDef)
	oBrw:SetmenuDef( cMenuDef )
EndIf
If !Empty(cFilterDefault)
	oBrw:SetFilterDefault(cFilterDefault)
EndIf   
If ValType( oPanel ) == "O"
	oPanel:FreeChildren()
	oBrw:Activate(oPanel)  
EndIf

Return oBrw

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Flavio S. Correa

@since 27/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()

oView := FWFormView():New()

oView:SetModel(oModel)

Return oView

