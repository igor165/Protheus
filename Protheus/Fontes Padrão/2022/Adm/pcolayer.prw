// Classe PCOArea
// Copyright (C) 2008, Microsiga
//

#include "protheus.ch"

#DEFINE OBJID       1
#DEFINE OBJETO      2
#DEFINE OBJWINID    3
#DEFINE OBJLYTID    4
#DEFINE OBJVISIBLE  5
#DEFINE OBJFOLDER   6
#DEFINE OBJBCHANGE  7
#DEFINE OBJBLOAD    8
#DEFINE OBJBCONFIRM 9

#DEFINE OBJTOTMAT	9

Static	oBjt

Class PCOLayer

	Data oDlg  		As Object
	Data oPainel	As Object
	Data oArea 		As Object
	Data oTree		As Object
	Data oSideBar	As Object
	Data aObjetos 	As Array
	//*********************************
	// x[1]= Id do Objeto             *
	// x[2]= Objeto                   *
	// x[3]= Id da Janela que utiliza *
	// x[4]= Id do Layout que utiliza *
	// x[5]= Controle do Visible (F/T)*
	// x[6]= Folder do Objeto         *
	// x[7]= Block bChange do Objeto  *
	// x[8]= Block bLoad do Objeto    *
	// x[9]= Block bCOnfirm do Objeto *
	// x[x]= Especificos do Objeto    *
	//*********************************
	Data aWindows 	As Array
	Data aLayouts 	As Array
	Data Estrutura 	As Array
	Data aObjLock	As Array
	Data aWindow	As Array

	Data nPercMain	As Integer
	Data lRun
	Data lMax
	
	Method New( nLeft, nTop, nWidth, nHeight, cTitulo) Constructor

	// m้todos
	Method AddWindow(nAltura,cWindow,cTitulo,lBut,cLayout,oMother,aButs)
	Method AddLayout(cLyt,bAction,lLytArea)
	Method ShowLayout( cLayout )
	Method AddBrw( cID, cTitulo, aCabec, cWindow, cLayout, bShow)
	Method GetBrw( cID )	
	Method AddGtD( cID, cTitulo, cWindow, cLayout, aHeader, aCols, bChange, bLoad, bConfirm )
	Method GetGtD( cID)
	Method AddMsm( cID, cTitulo, cAlias, nRecno, cWindow, cLayout, bLoad, bConfirm, _aGetValues , nOpc)
	Method GetMsm( cID )
	Method Getobj(cWindow)
	Method AddSide(nPerc,cTitulo)
	Method GetSidebar()
	Method BarBut( aButs, cWindow, cLayout )
	Method Bt( nOpc, cWindow )
	Method AddTre(cID,cWindow,cLayout,bVldNo,lEdit)
	Method GetTre( cID )
	Method No_Tree(cTitulo,cAlias,cMacro,cIMG,bAction,bRClick,bDblClick,bLoad,lPosic,cChvSup,nOrdSup,lInclui,bVld)
	Method LoadTree(oTree,cAliasTre,cDe,cAte,nTree,lLoad,aSubItem,cFilMacro,cChave)
	Method addLockObj( nOpc, nObj, aLocks )
	Method Activate(lCentered,lAtuTre)
	// Protheus 11
	Data aLayers 	As Array
	Method AddMBrowse(cID,cTitulo,cAlias,nOrder,cSeek,aCposNao,aCposSim,cWindow,cLayout,bShow)
	Method AddGetDado(cID,cTitulo,cAlias,nOrder,cSeek,aCposNao,aCposSim,cWindow,cLayout,bOk ,bChange, bLoad, bConfirm, bSave , cAutoInc)
	Method RefreshTre(cIdTre)
	Method GetWindow( cWindow )

EndClass

/*---------------------------------------------------------------------
Metodo New() CONSTRUTOR
-----------------------------------------------------------------------*/
Method New(nTop,nLeft,nWidth, nHeight,cTitulo,lMax) Class PCOLayer	 

Default nTop	:= 0
Default nLeft	:= 0
Default nWidth	:= 1000
Default nHeight	:= 700
Default cTitulo	:= ''
Default lMax	:= .F.

	Self:aWindow	:= {}
	Self:aObjetos 	:= {}
	Self:aWindows  	:= {}
	Self:aLayouts	:= {}
	Self:Estrutura 	:= {}
	self:aObjLock	:= {}
	Self:lRun		:= .F.
	Self:lMax		:= lMax
	
	Self:oDlg := TDialog():New( nTop, nLeft, nWidth, nHeight,cTitulo,/*<cResName>*/,/*<hResources>*/,/*<.vbx.>*/,/*<nStyle>*/If(lMax,nOr(WS_VISIBLE,WS_POPUP),nil),;
                /*<nClrText>*/,/*<nClrBack>*/,/*<oBrush>*/,/*<oWnd>*/,.t.,;
                /*<oIco>*/,/*<oFont>*/,/*<nHelpId>*/,nWidth,nHeight ) 

		Self:oArea 	:= 	FWLayer():New()
		Self:oArea:init( Self:oDlg, lMax )

		oBjt:= Self // Cria Static

Return Self

/*---------------------------------------------------------------------
Metodo Activate()
-----------------------------------------------------------------------*/
Method 	Activate(lCentered,lAtuTre,cIdTre)	Class PCOLayer

Local nX

Default lCentered 	:= .T.
Default lAtuTre		:=  .F.
Default cIdTre		:= "001"

If lAtuTre .and. Len(Self:Estrutura)>0

	Self:RefreshTre(cIdTre)

EndIf

Self:lRun		:= .T.

Self:oArea:Show()
Self:oDlg:Activate(,,,lCentered)

Return self

/*---------------------------------------------------------------------
Metodo AddSide()
-----------------------------------------------------------------------*/
Method AddSide(nPerc,cTitulo) Class PCOLayer	 

	Self:oArea:addCollumn( "SIDE", nPerc, .F. )
	Self:oArea:setColSplit( "SIDE", CONTROL_ALIGN_RIGHT,, {|| } )

	Self:oArea:addCollumn( "MAIN",  100- nPerc, .F. )
	//Self:oArea:setColSplit( "MAIN", CONTROL_ALIGN_LEFT,, {|| } )
	
	Self:nPercMain := 100 - nPerc
   
Return Self	

/*---------------------------------------------------------------------
Metodo GetSidebar()

   Retorna o Objeto Side bar
-----------------------------------------------------------------------*/
Method GetSidebar() Class PCOLayer // Depreciado
Return self:oArea:GetSidebar("SIDE")


/*---------------------------------------------------------------------
Metodo AddWindow()

   Adiciona janela
-----------------------------------------------------------------------*/
Method AddWindow(nAltura,cWindow,cTitulo,lBut,cLayout,aButs)	Class PCOLayer

Local aButtons := {}
Local nX
Local nWin

Default lBut	:= .F.       
Default cLayout	:= "SIDE"
Default aButs	:= {}
// Monta Janela

If !Self:lMax
	nAltura := ROUND(nAltura / 1.04,0)
EndIf

If cLayout=="SIDE"
	Self:oArea:addWindow( cLayout, cWindow, cTitulo, nAltura, .T., .T., {|| } )
	aAdd(Self:aWindow,{cWindow,nil,nil,cLayout})
	nWin	:= Len(Self:aWindow)
	Self:aWindow[nWin,3] := Self:oArea:getWinPanel( cLayout, cWindow )

ElseIf (nX := aScan(::aLayouts,{|x| x[1]==cLayout .and. x[5]}))>0

	Self:aLayouts[nX,3]:addWindow( cLayout, cWindow, cTitulo, nAltura, .T., .T., {|| } )
	aAdd(Self:aWindow,{cWindow,nil,nil,cLayout})
	nWin	:= Len(Self:aWindow)
	Self:aWindow[nWin,3] := Self:aLayouts[nX,3]:getWinPanel( cLayout, cWindow )

EndIf

If lBut
	// Cria Vetor de Bot๕es
	aAdd(aButtons,{1,"NOTE"			,{|| Self:Bt(1,cWindow) 	},	"Editar"	,.T.}	)
	aAdd(aButtons,{2,"Confirmar"	,{|| Self:Bt(2,cWindow) 	},	"Confirmar"	,.T.}	)
	aAdd(aButtons,{2,"Cancelar"		,{|| Self:Bt(3,cWindow)		},	"Cancelar"	,.T.}	)

EndIf

// Adiciona Bot๕es
For nX := 1 to Len(aButs)
	aAdd(aButtons,aButs[nX])
Next

If Len(aButtons)>0
	oPanel	:= TPanel():New( 0, 0,/*<cText>*/,Self:aWindow[nWin,3]/*[<oWnd>]*/,/*<oFont>*/,/*<.lCenter.>*/,/*<.lRight.>*/,/*<nClrText>*/,/*<nClrBack>*/,250/*<nWidth>*/,15/*<nHeight>*/,/*<.lLowered.>*/,/*<.lRaised.>*/ )
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	Self:aWindow[nWin,2] := oPanel
	self:BarBut(aButtons,cWindow,cLayout)

EndIf

Return Self	

/*---------------------------------------------------------------------
Metodo GetWindow()

	Retorno Obejeto Painel da Janela
-----------------------------------------------------------------------*/
Method GetWindow( cWindow )	Class PCOLayer

Local nI	
Local oBjt
	
	If (nI	:= aScan(Self:aWindow,{|x| x[1]==cWindow}))>0
		oBjt	:= Self:aWindow[nI,3]
	else
		oBjt	:= nil
	EndIf
Return oBjt

/*---------------------------------------------------------------------
Metodo AddLayout()

	Adiciona Layouts da Tela
-----------------------------------------------------------------------*/
Method AddLayout(cLyt,bAction,lLytArea) Class PCOLayer

Local nLayAtu
Default lLytArea := .F.
	aAdd(::aLayouts,{cLyt,bAction,nil,.F.,lLytArea})
	nLayAtu := Len(::aLayouts)

	If lLytArea	
		Self:aLayouts[nLayAtu,3] := 	FWLayer():New()
		Self:aLayouts[nLayAtu,3]:init( Self:oArea:getColPanel("MAIN"), .F. )
		Self:aLayouts[nLayAtu,3]:addCollumn( cLyt, 100/*Self:nPercMain*/ , .F. )
		//Self:aLayouts[nLayAtu,3]:setColSplit( cLyt, CONTROL_ALIGN_RIGHT,, {|| } )
	EndIf
Return Self

/*---------------------------------------------------------------------
Metodo ShowLayout()

	Executa o :Show() nos objetos do layout e :Hide() nos de mais
-----------------------------------------------------------------------*/
Method 	ShowLayout(cLayout,lTre,cIdTre)	Class PCOLayer

Local nX,nI,nZ
Local oTre,aTre

Default lTre  	:=	.T.
Default cIdTre  :=	"001"

oTre := Self:GetTre(cIdTre)

// Verrifica se tem  Layout criado 
If (nI := aScan(Self:aLayouts,{|x| x[1]==cLayout})) > 0 .and. Self:aLayouts[nI,5]
	aEval(Self:aLayouts, {|x| x[4] := .F.,x[3]:Hide() })
	Self:aLayouts[nI,3]:Show()
	Self:aLayouts[nI,4]	:= .T.
EndIf

// Verrifica se estrutura deve estar posicionada
If VALTYPE(oTre)=="O" .and. !Empty(oTre:CURRENTNODEID)

	nI 	:= aScan(oTre:aNodes,{|x| x[2]==oTre:CURRENTNODEID})
	aTre:= {}
	
	Do While nI > 0

		If SubStr(oTre:aCargo[nI,1],4,1)<>"X"
			nX	:= aScan(Self:Estrutura,{|x| x[2]==Substr(oTre:aCargo[nI,1],1,3)})
			If Self:Estrutura[nX,10]
	
				Aadd(aTre,{Self:Estrutura[nX,2],Substr(oTre:aCargo[nI,1],4)})
			
			EndIf
		EndIf
		nI := aScan(oTre:aNodes,{|x| x[2]==oTre:aNodes[nI,1]})
	EndDo
	
	For nX:= Len(aTre) To 1 Step -1

		DbSelectArea(aTre[nX,1])
		DbGoTo(VAL(aTre[nX,2]))
		
	Next
EndIf
//	aAdd(Self:Estrutura,{cTitulo,cAlias,cMacro,,cIMG,bAction,bRClick,bDblClick,bLoad,lPosic,cChvSup,nOrdSup,lInclui})

	For nX := 1 To Len(Self:aObjetos)

		If Self:aObjetos[nX,OBJLYTID]==cLayout .and. !Empty(oTre:aCargo)

			If VALTYPE(Self:aObjetos[Nx,OBJETO])=="O"

				If VALTYPE(Self:aObjetos[nX,OBJBLOAD])=="B"
					Eval(Self:aObjetos[nX,OBJBLOAD],Self:aObjetos[Nx,OBJETO])
					If SubStr(self:aObjetos[nX,OBJID],1,3)="MSM"
						self:aObjetos[nX,OBJETO]:EnchRefreshAll()     
					Else
						Self:aObjetos[nX,OBJETO]:Refresh()
					EndIf
				EndIf

				Self:aObjetos[nX,OBJETO]:Hide()
				Self:aObjetos[nX,OBJETO]:Show()
				Self:aObjetos[nX,OBJVISIBLE] := .T.

				//--------------------------------------------
				// Caso seja folder posiciona na primeira aba
				//--------------------------------------------
				If SubStr(self:aObjetos[nX,OBJID],1,3)="FLD" .And. !("L3WIN7" $ self:aObjetos[nX,OBJID])
					Self:aObjetos[nX,OBJETO]:ShowPage(1)
				EndIf

			ElseIf VALTYPE(Self:aObjetos[nX,OBJETO])=="A"

				For Ni:=1 To Len(Self:aObjetos[nX,OBJETO])

					Self:aObjetos[nX,OBJETO,Ni]:Hide()
					Self:aObjetos[nX,OBJETO,Ni]:Show()
					Self:aObjetos[nX,OBJVISIBLE] := .T.

				Next 

			EndIf

		ElseIf Self:aObjetos[nX,OBJLYTID]<>nil

			If VALTYPE(Self:aObjetos[nX,OBJETO])=="O"

				Self:aObjetos[nX,OBJETO]:Show()		
				Self:aObjetos[nX,OBJETO]:Hide()
				Self:aObjetos[nX,OBJVISIBLE] := .F.

				//--------------------------------------------
				// Caso seja folder posiciona na primeira aba
				//--------------------------------------------
				If SubStr(self:aObjetos[nX,OBJID],1,3)="FLD" .And. !("L3WIN7" $ self:aObjetos[nX,OBJID])
					Self:aObjetos[nX,OBJETO]:ShowPage(1)
				EndIf

			ElseIf VALTYPE(Self:aObjetos[nX,OBJETO])=="A"

				For nI:=1 To Len(Self:aObjetos[nX,OBJETO])
					Self:aObjetos[nX,OBJETO,nI]:Show()
					Self:aObjetos[nX,OBJETO,nI]:Hide()
					Self:aObjetos[nX,OBJVISIBLE] := .F.
				Next 

			EndIf

		Else        

			If SubStr(self:aObjetos[nX,OBJID],1,3)="BTR"

                cIdTrePai	:= self:aObjetos[nX,OBJTOTMAT+1]
                If Self:lRun .and. !Empty(Self:GetTre(cIdTrePai):aCargo) .and. !Empty(Self:GetTre(cIdTrePai):GetCargo())
	                nZ	:= aScan(Self:Estrutura,{|x| x[2]==SubStr(Self:GetTre(cIdTrePai):GetCargo(),1,3)})
                Else
	                nZ	:= 1
                EndIf
				If Self:Estrutura[nZ,13]
					Self:aObjetos[nX,OBJETO]:Hide()
					Self:aObjetos[nX,OBJETO]:Show()
					Self:aObjetos[nX,OBJVISIBLE] := .T.
				Else
					Self:aObjetos[nX,OBJETO]:Show()
					Self:aObjetos[nX,OBJETO]:Hide()
					Self:aObjetos[nX,OBJVISIBLE] := .F.
				EndIf			
			EndIf

		EndIf

	Next
	
Return Self	

/*---------------------------------------------------------------------
Metodo AddTre()

	Inclui xTree
-----------------------------------------------------------------------*/
Method AddTre(cID,cWindow,cLayout,bVldNo,lEdit) Class PCOLayer

Local nObj

Default lEdit	:= .F.

aAdd(self:aObjetos,Array(OBJTOTMAT))
nObj	:= Len(self:aObjetos)

self:aObjetos[nObj,OBJID]		:= "TRE"+cID
self:aObjetos[nObj,OBJWINID]	:= cWindow
self:aObjetos[nObj,OBJLYTID]	:= cLayout
self:aObjetos[nObj,OBJVISIBLE]	:= .F.

self:aObjetos[nObj,OBJETO] 		:= XTree():New(0, 0, 240, 150, Self:GetWindow( cWindow ) )
self:aObjetos[nObj,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT	
If VALTYPE(bVldNo)<>"B"
	self:aObjetos[nObj,OBJETO]:bValidNodes := {|| self:GetTre(cID):lActive }
Else
	self:aObjetos[nObj,OBJETO]:bValidNodes := bVldNo
EndIf

If lEdit

	oTBar := TBar():New( Self:GetWindow( cWindow ),32,32,.T.,,,"",.F. )
	oTBar:Align := CONTROL_ALIGN_BOTTOM
	oBtn := TBtnBmp2():New( 00, 0, 32, 32, "rpmnew" ,,,,{|| BtTre("001",1,Self) },oTBar,"Incluir",,.T.,.T. )
	oBtn2 := TBtnBmp2():New( 00, 0, 32, 32, "excluir" ,,,,{|| BtTre("001",3,Self) },oTBar,"Excluir",,.T.,.T. )
	oBtn:Align := CONTROL_ALIGN_LEFT
	oBtn2:Align := CONTROL_ALIGN_LEFT
//	aAdd( self:oArea:aContainer[Len(self:oArea:aContainer),3] , oBtn )
//	aAdd( self:oArea:aContainer[Len(self:oArea:aContainer),3] , oBtn2 )
	
	aAdd(self:aObjetos,Array(OBJTOTMAT + 1))
	nObj := Len(self:aObjetos)
	self:aObjetos[nObj,OBJID]		:= "BTR"+"001"
	self:aObjetos[nObj,OBJWINID]	:= cWindow
	self:aObjetos[nObj,OBJLYTID]	:= nil
	self:aObjetos[nObj,OBJFOLDER]	:= 0
	self:aObjetos[nObj,OBJETO] 		:= oBtn
	self:aObjetos[nObj,OBJTOTMAT+1]	:= cID
	
	aAdd(self:aObjetos,Array(OBJTOTMAT + 1))
	nObj := Len(self:aObjetos)
	self:aObjetos[nObj,OBJID]		:= "BTR"+"002"
	self:aObjetos[nObj,OBJWINID]	:= cWindow
	self:aObjetos[nObj,OBJLYTID]	:= nil
	self:aObjetos[nObj,OBJFOLDER]	:= 0
	self:aObjetos[nObj,OBJETO] 		:= oBtn2
	self:aObjetos[nObj,OBJTOTMAT+1]	:= cID

EndIf

Return self:aObjetos[nObj,OBJETO]

/*---------------------------------------------------------------------
Metodo GetTre()

	Retorna Objeto Tree com o Id Informado
-----------------------------------------------------------------------*/
Method GetTre(cID) Class PCOLayer

Local nPosIt 	:= aScan(self:aObjetos,{|x|x[1]=="TRE"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo AddGtD()

	Inclui GetDados
-----------------------------------------------------------------------*/
Method AddGtD(cID,cTitulo,cWindow,cLayout,aHeaderGtd,aColsGtd,bChange,bLoad,bConfirm) Class PCOLayer

Local nObj	
Local nIpFolder := 0

aHeader := aClone(aHeaderGtd)
aCols 	:= aClone(aColsGtd)
n		:= 1

If VALTYPE(aCols)<>"A"

	aCols := {}
	aAdd(aCols,Array(Len(aHeader) + 1))
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader) + 1] := .F. 

EndIf
If cTitulo<>nil

	If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

		aAdd(self:aObjetos,Array(OBJTOTMAT))
		nIpFolder := Len(self:aObjetos)

		self:aObjetos[nIpFolder,OBJID]		:= "FLD"+cLayout+cWindow
		self:aObjetos[nIpFolder,OBJWINID]	:= cWindow
		self:aObjetos[nIpFolder,OBJLYTID]	:= cLayout
		self:aObjetos[nIpFolder,OBJVISIBLE]	:= .F.
		self:aObjetos[nIpFolder,OBJETO] 	:= TFolder():New(0,0,{cTitulo},{}, Self:GetWindow( cWindow ),,,, .F., .F.,490,100,)			
		self:aObjetos[nIpFolder,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT

	Else

		self:aObjetos[nIpFolder,OBJETO]:AddItem( cTitulo )

	EndIf

	oBjtPai := self:aObjetos[nIpFolder,OBJETO]:aDialogs[Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)]

Else

	oBjtPai := Self:GetWindow( cWindow )
                            
EndIf

// Cria GetDados da Distribui็ใo
aAdd(self:aObjetos,Array(OBJTOTMAT+2))
nObj	:= Len(self:aObjetos)

self:aObjetos[nObj,OBJID]		:= "GTD"+cID
self:aObjetos[nObj,OBJWINID]	:= cWindow
self:aObjetos[nObj,OBJLYTID]	:= cLayout
self:aObjetos[nObj,OBJVISIBLE]	:= .F.
self:aObjetos[nObj,OBJBCHANGE]  := bChange
self:aObjetos[nObj,OBJBLOAD]	:= bLoad
self:aObjetos[nObj,OBJBCONFIRM]	:= bConfirm
self:aObjetos[nObj,OBJTOTMAT+2] := {|| .T.}
self:aObjetos[nObj,OBJETO] 		:= MsNewGetDados():New(0,0,90,305,7,,,,,,,,,,oBjtPai,aHeader,aCols)
self:aObjetos[nObj,OBJETO]:lInsert := .F.
self:aObjetos[nObj,OBJETO]:lUpdate := .F.
self:aObjetos[nObj,OBJETO]:lDelete := .F.
self:aObjetos[nObj,OBJETO]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
self:aObjetos[nObj,OBJETO]:Refresh()                                  
self:aObjetos[nObj,OBJETO]:bChange			:= self:aObjetos[nObj,OBJBCHANGE]
self:aObjetos[nObj,OBJETO]:oBrowse:bGotFocus:= self:aObjetos[nObj,OBJBCHANGE]

If nIpFolder > 0
	self:aObjetos[nObj,OBJFOLDER] := Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)
EndIf

Return self:aObjetos[nObj,OBJETO]

/*---------------------------------------------------------------------
Metodo AddMsm()

	Inclui MsmGet
-----------------------------------------------------------------------*/
Method AddMsm(cID,cTitulo,cAlias,nRecno,cWindow,cLayout,bLoad,bConfirm,_aGetValues,nOpc,aCposNot) Class PCOLayer

Local nObj		
Local nIpFolder := 0
Local cBlock	:= ""
Local aCpos		:= {}

Default nOpc	:= 4
Default bLoad	:= MontaBlock("{|x| PcoD2M('" + cAlias + "'," + cAlias + "->(RECNO())) }")
Default aCposNot:= {}

// Caso a tabela utilizada exista na estrtura for็a Refresh
If aScan(Self:Estrutura,{|x| x[2]==cAlias})>0
	cBlock	:= ",Self:RefreshTre()"
EndIf
Default bConfirm:= MontaBlock("{|x| PcoM2D('" + cAlias + "'," + cAlias + "->(RECNO()),,.T.)" + cBlock + " }")

	If cTitulo<>nil

		If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

		aAdd(self:aObjetos,Array(OBJTOTMAT))
		nIpFolder := Len(self:aObjetos)

		self:aObjetos[nIpFolder,OBJID]		:= "FLD"+cLayout+cWindow
		self:aObjetos[nIpFolder,OBJWINID]	:= cWindow
		self:aObjetos[nIpFolder,OBJLYTID]	:= cLayout
		self:aObjetos[nIpFolder,OBJVISIBLE]	:= .F.
		self:aObjetos[nIpFolder,OBJETO] 	:= TFolder():New(0,0,{cTitulo},{}, Self:GetWindow( cWindow ),,,, .F., .F.,490,100,)			
		self:aObjetos[nIpFolder,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT

	Else

		self:aObjetos[nIpFolder,OBJETO]:AddItem( cTitulo )

		EndIf

		oBjtPai := self:aObjetos[nIpFolder,OBJETO]:aDialogs[Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)]

	Else

		oBjtPai := Self:GetWindow( cWindow )

	EndIf
	
	aAdd(self:aObjetos,Array(OBJTOTMAT))
	nObj := Len(self:aObjetos)
	self:aObjetos[nObj,OBJID]		:= "MSM"+cID
	self:aObjetos[nObj,OBJWINID]	:= cWindow
	self:aObjetos[nObj,OBJLYTID]	:= cLayout
	self:aObjetos[nObj,OBJBLOAD]	:= bLoad
	self:aObjetos[nObj,OBJBCONFIRM]	:= bConfirm
	self:aObjetos[nObj,OBJVISIBLE]	:= .F.

	If VALTYPE(_aGetValues)<>"A"
		aEval(GetaHeader(cAlias,,aCposNot) , {|x| aAdd( aCpos , x[2] ) } )
		self:aObjetos[nObj,OBJETO]	:= MsMGet():New(cAlias,nRecno,nOpc,,,,aCpos,{0, 0, 640, 480},,4,,,,oBjtPai,,,.F.)
		self:aObjetos[nObj,OBJETO]:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
		self:aObjetos[nObj,OBJETO]:Disable()

	Else

		self:aObjetos[nObj,OBJETO] := MsMGet():New(cAlias,nRecno,4,,,,,{0, 0, 640, 480},,4,,,,oBjtPai,,,,,,.T.,_aGetValues)
		self:aObjetos[nObj,OBJETO]:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
		self:aObjetos[nObj,OBJETO]:Disable()

	EndIf

	If nIpFolder > 0
		self:aObjetos[nObj,OBJFOLDER] := Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)
	EndIf

Return Self

/*---------------------------------------------------------------------
Metodo GetBrw()

	Busca Browse
-----------------------------------------------------------------------*/
Method GetBrw(cID) Class PCOLayer

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="BRW"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo GetGtD()

	Busca GetDados
-----------------------------------------------------------------------*/
Method GetGtD(cID) Class PCOLayer

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="GTD"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo GetMsm()

	Busca Msmget
-----------------------------------------------------------------------*/
Method GetMsm(cID) Class PCOLayer

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="MSM"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo AddBrw()

	Adiciona Browse
-----------------------------------------------------------------------*/
Method AddBrw(cID,cTitulo,aCabec,cWindow,cLayout,bShow) Class PCOLayer

Local nObj
Local nIpFolder := 0

	If cTitulo<>nil

		If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

		aAdd(self:aObjetos,Array(OBJTOTMAT))
		nIpFolder := Len(self:aObjetos)

		self:aObjetos[nIpFolder,OBJID]		:= "FLD"+cLayout+cWindow
		self:aObjetos[nIpFolder,OBJWINID]	:= cWindow
		self:aObjetos[nIpFolder,OBJLYTID]	:= cLayout
		self:aObjetos[nIpFolder,OBJVISIBLE]	:= .F.
		self:aObjetos[nIpFolder,OBJETO] 	:= TFolder():New(0,0,{cTitulo},{}, Self:GetWindow( cWindow ),,,, .F., .F.,490,100,)			
		self:aObjetos[nIpFolder,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT

	Else

		self:aObjetos[nIpFolder,OBJETO]:AddItem( cTitulo )

		EndIf

		oBjtPai := self:aObjetos[nIpFolder,OBJETO]:aDialogs[Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)]

	Else

		oBjtPai := Self:GetWindow( cWindow )

	EndIf
	
	aAdd(self:aObjetos,Array(OBJTOTMAT))
	nObj := Len(self:aObjetos)
	self:aObjetos[nObj,OBJID]		:= "BRW"+cID
	self:aObjetos[nObj,OBJWINID]	:= cWindow
	self:aObjetos[nObj,OBJLYTID]	:= cLayout
	self:aObjetos[nObj,OBJVISIBLE]	:= .F.
	self:aObjetos[nObj,OBJBLOAD]	:= bShow
	self:aObjetos[nObj,OBJETO] := 	TWBrowse():New(0, 0,305,90, ,aCabec,,oBjtPai,,,,,,,/*oPnlDistVal:oFont*/,,,,,.F.,,.T.,,.F.,,,)

	If nIpFolder > 0

		self:aObjetos[nObj,OBJFOLDER] := Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)

	EndIf

	self:aObjetos[nObj,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT
	Eval(bShow) // Executa Refresh

Return self:aObjetos[nObj,OBJETO]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod  ณAddMBrowseบAutor  ณAcacio Egas         บ Data ณ  06/25/09   บฑฑ
ฑฑฬออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Metodo de Cria็ใo de uma Browse de acordo com SX3.         บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddMBrowse(cID,cTitulo,cAlias,nOrder,cSeek,aCposNao,aCposSim,cWindow,cLayout,bShow) Class PCOLayer

Local nObj
Local nIpFolder := 0

Local aCabec:= {}
Local nI

Default aCposNao := {}
Default aCposSim := {}
Default cSeek	 := "xFilial('"+cAlias+"')"

Default bShow := MontaBlock("{|x| RBrow(x,'"+cAlias+"',"+Str(nOrder)+",'"+cSeek+"') }")


	If cTitulo<>nil

		If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

			aAdd(self:aObjetos,Array(OBJTOTMAT))
			nIpFolder := Len(self:aObjetos)
	
			self:aObjetos[nIpFolder,OBJID]		:= "FLD"+cLayout+cWindow
			self:aObjetos[nIpFolder,OBJWINID]	:= cWindow
			self:aObjetos[nIpFolder,OBJLYTID]	:= cLayout
			self:aObjetos[nIpFolder,OBJVISIBLE]	:= .F.
			self:aObjetos[nIpFolder,OBJETO] 	:= TFolder():New(0,0,{cTitulo},{}, Self:GetWindow( cWindow ),,,, .F., .F.,490,100,)			
			self:aObjetos[nIpFolder,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT

		Else

			self:aObjetos[nIpFolder,OBJETO]:AddItem( cTitulo )

		EndIf

		oBjtPai := self:aObjetos[nIpFolder,OBJETO]:aDialogs[Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)]

	Else

		oBjtPai := Self:GetWindow( cWindow )

	EndIf

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias	
		If	(Len(aCposNao)>0) .AND. (aScan(aCposNao,{|x|AllTrim(Upper(x)) == AllTrim(SX3->X3_CAMPO) })<>0)
			SX3->(DbSkip())
			Loop		
		Endif	
		If (SX3->X3_BROWSE = 'S' .AND. SX3->X3_CONTEXT <> "V" .AND. SX3->X3_TIPO <> "M") .OR.;
			(If((Len(aCposSim)>0),(aScan(aCposSim,{|x|AllTrim(Upper(x)) == AllTrim(SX3->X3_CAMPO) })<>0),.F.))
			aAdd(aCabec, IIF(cPaisLoc == "RUS", TRIM(X3TITULO()), SX3->X3_TITULO) )
		EndIf
		SX3->(DbSkip())
	End
	
	aAdd(self:aObjetos,Array(OBJTOTMAT))
	nObj := Len(self:aObjetos)
	self:aObjetos[nObj,OBJID]		:= "BRW"+cID
	self:aObjetos[nObj,OBJWINID]	:= cWindow
	self:aObjetos[nObj,OBJLYTID]	:= cLayout
	self:aObjetos[nObj,OBJVISIBLE]	:= .F.
	self:aObjetos[nObj,OBJBLOAD]	:= bShow
	self:aObjetos[nObj,OBJETO] 		:= TWBrowse():New(0, 0,305,90, ,aCabec,,oBjtPai,,,,,,,/*oPnlDistVal:oFont*/,,,,,.F.,,.T.,,.F.,,,)

	If nIpFolder > 0

		self:aObjetos[nObj,OBJFOLDER] := Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)

	EndIf  

	self:aObjetos[nObj,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT
	If VALTYPE(bShow)=="B"
		Eval(bShow ,self:aObjetos[nObj,OBJETO] ) // Executa Refresh
	EndIf

Return self:aObjetos[nObj,OBJETO]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod  ณAddGetDadoบAutor  ณAcacio Egas         บ Data ณ  06/25/09   บฑฑ
ฑฑฬออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Metodo de Cria็ใo de uma MsNewGetDados com cria็ใo de      บฑฑ
ฑฑบDesc.   ณ aCols e aHeader e valida็ใo automatica.                    บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AddGetDado(cID,cTitulo,cAlias,nOrder,cSeek,aCposNao,aCposSim,cWindow,cLayout,bOk ,bChangeUsr, bLoad, bConfirm , bSave , cAutoInc) Class PCOLayer

Local nIpFolder := 0	
Local aHeader,aCols
Local aRecno	:= {}
Local cBlok
Local cBlok2	:= ""
Local n		:= 1
Local bChange	:= {|| aRec := self:aObjetos[aScan(self:aObjetos,{|x|x[1]=='GTD'+ cID }),10],DbSelectArea(cAlias),If(self:GetGtD(cID):nAt<=Len(aRec),DbGoTo(aRec[self:GetGtD(cID):nAt]),DbGoTo(0)),eVal(self:aObjetos[aScan(self:aObjetos,{|x|x[1]=='GTD'+cID}),7]) }

								//"{|| If(Valtype('Self')=='O',(aRec := self:aObjetos[aScan(self:aObjetos,{|x|x[1]=='GTD'+'" + cID + "'}),10], If(self:GetGtD('" + cID + "'):nAt<=Len(aRec),(DbSelectArea('" + cAlias +"'),DbGoTo(aRec[self:GetGtD('" + cID + "'):nAt])),.F.)," +;
								//"eVal(self:aObjetos[aScan(self:aObjetos,{|x|x[1]=='GTD'+'" + cID + "'}),7])),Alert('teste')) }")

Default cAutoInc	:= ""

aHeader := GetaHeader(cAlias,aCposSim,aCposNao)

cBlok := "'" + cAlias + "',"+Str(nOrder)+"," + cSeek+ ",Self:GetGtD('"+cID+;
		 "'):aHeader,Self:GetGtD('"+cID+"'):aCols,@self:aObjetos[aScan(self:aObjetos,{|x|x[1]=='GTD'+'" + cID + "'}),10],'" + SubStr(cAutoInc,2) + "')"

Default bOk := {|| .T.}
Default bChangeUsr := {|| .T. }
Default bLoad 	:= MontaBlock("{|| RWaCols('R'," + cBlok + "}")
Default bSave	:= {|| }

If aScan(Self:Estrutura,{|x| x[2]==cAlias})>0
	cBlok2	:= ",Self:RefreshTre()"
EndIf

Default bConfirm:= MontaBlock("{|| RWaCols('W'," + cBlok + cBlok2 + "}")

// Monta aCols de Acordo com Tabela e Seek
If !Empty(nOrder) .and. !Empty(cSeek)
    
	RWaCols("R",cAlias,nOrder,&(cSeek),aHeader,@aCols,@aRecno,SubStr(cAutoInc,2))
	
EndIf

If VALTYPE(aCols)<>"A"

	aCols := {}    
	aRecno:= {}
	aAdd(aCols,Array(Len(aHeader) + 2))
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader) + 1] := .F. 

EndIf
If cTitulo<>nil

	If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

		aAdd(self:aObjetos,Array(OBJTOTMAT))
		nIpFolder := Len(self:aObjetos)

		self:aObjetos[nIpFolder,OBJID]		:= "FLD"+cLayout+cWindow
		self:aObjetos[nIpFolder,OBJWINID]	:= cWindow
		self:aObjetos[nIpFolder,OBJLYTID]	:= cLayout
		self:aObjetos[nIpFolder,OBJVISIBLE]	:= .F.
		self:aObjetos[nIpFolder,OBJETO] 	:= TFolder():New(0,0,{cTitulo},{}, Self:GetWindow( cWindow ),,,, .F., .F.,490,100,)			
		self:aObjetos[nIpFolder,OBJETO]:Align := CONTROL_ALIGN_ALLCLIENT

	Else

		self:aObjetos[nIpFolder,OBJETO]:AddItem( cTitulo )

	EndIf

	oBjtPai := self:aObjetos[nIpFolder,OBJETO]:aDialogs[Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)]

Else

	oBjtPai := Self:GetWindow( cWindow )
                            
EndIf

// Cria GetDados da Distribui็ใo

aAdd(self:aObjetos,Array(OBJTOTMAT+3))
nObj := Len(self:aObjetos)
self:aObjetos[nObj,OBJID]		:= "GTD"+cID
self:aObjetos[nObj,OBJWINID]	:= cWindow
self:aObjetos[nObj,OBJLYTID]	:= cLayout
self:aObjetos[nObj,OBJVISIBLE]	:= .F.
self:aObjetos[nObj,OBJBCHANGE]	:= bChangeUsr
self:aObjetos[nObj,OBJBLOAD]	:= bLoad
self:aObjetos[nObj,OBJBCONFIRM]	:= bConfirm
self:aObjetos[nObj,OBJTOTMAT+1]	:= aRecno
self:aObjetos[nObj,OBJTOTMAT+2] := bOk
self:aObjetos[nObj,OBJTOTMAT+3] := bSave

self:aObjetos[nObj,OBJETO] 		:= MsNewGetDados():New(0,0,90,305,7,,,cAutoInc,,,,,,,oBjtPai,aHeader,aCols)
self:aObjetos[nObj,OBJETO]:lInsert := .F.
self:aObjetos[nObj,OBJETO]:lUpdate := .F.
self:aObjetos[nObj,OBJETO]:lDelete := .F.
self:aObjetos[nObj,OBJETO]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
self:aObjetos[nObj,OBJETO]:Refresh()                                  
self:aObjetos[nObj,OBJETO]:bChange 			:= bChange
self:aObjetos[nObj,OBJETO]:oBrowse:bGotFocus:= bChange
self:aObjetos[nObj,OBJETO]:bLinhaOk			:= self:aObjetos[nObj,OBJTOTMAT+2]
self:aObjetos[nObj,OBJETO]:bDelOk			:= self:aObjetos[nObj,OBJTOTMAT+2]
If nIpFolder > 0
	self:aObjetos[nObj,OBJFOLDER] := Len(self:aObjetos[nIpFolder,OBJETO]:aDialogs)
EndIf

Return self:aObjetos[nObj,OBJETO]

/*---------------------------------------------------------------------
Metodo No_Tree()

	Adiciona Estrutura do Tree
-----------------------------------------------------------------------*/
Method No_Tree(cTitulo,cAlias,cMacro,cIMG,bAction,bRClick,bDblClick,bLoad,lPosic,cChvSup,nOrdSup,lInclui,bVld) Class PCOLayer

Default lPosic	:= .F.
Default nOrdSup	:= 1
Default lInclui	:= .F.
Default bVld	:= {|| .T.}

	aAdd(Self:Estrutura,{cTitulo,cAlias,cMacro,,cIMG,bAction,bRClick,bDblClick,bLoad,lPosic,cChvSup,nOrdSup,lInclui,bVld})

Return Self

/*---------------------------------------------------------------------
Metodo BarBut()

	Inclui Bot๕es
-----------------------------------------------------------------------*/
Method BarBut(aButs,cWindow,cLayout) Class PCOLayer

Local nX
Local oPainel	:= Self:aWindow[aScan(Self:aWindow,{|x| x[1]==cWindow}),2]
Local aBut	:= {}
Local aEdt  := {}

	For Nx:=1 To Len(aButs)

		aAdd(aBut,nil)
		If aButs[Nx,1]=1         
			aBut[Len(aBut)]	:= TBtnBmp2():New( 0, 0, 30, 25,aButs[Nx,2],aButs[Nx,2],/*<cBmpFile1>*/, /*<cBmpFile2>*/,aButs[Nx,3]/*[{|Self|<uAction>}]*/,oPainel/*<oWnd>*/,aButs[Nx,4]/*<cMsg>*/,/*<{uWhen}>*/,/*<.adjust.>*/,/*<.lUpdate.>*/)
			aBut[Len(aBut)]:Align := CONTROL_ALIGN_LEFT
		Else
			aBut[Len(aBut)]	:= tButton():New( 0, 0,aButs[Nx,2],oPainel,aButs[Nx,3],40,25,,,,.T.)
			aBut[Len(aBut)]:Align := CONTROL_ALIGN_RIGHT
		EndIf	

		If Len(aButs[Nx])>4
			aAdd(aEdt,aButs[Nx,5])
		Else
			aAdd(aEdt,.F.)
		EndIf

	Next

	aAdd(self:aObjetos,Array(OBJTOTMAT+1))
	nObj := Len(self:aObjetos)
	self:aObjetos[nObj,OBJID]		:= "BUT"+cWindow
	self:aObjetos[nObj,OBJWINID]	:= cWindow
	self:aObjetos[nObj,OBJLYTID]	:= cLayout
	self:aObjetos[nObj,OBJFOLDER]	:= 0
	self:aObjetos[nObj,OBJETO] 		:= aBut
	self:aObjetos[Len(self:aObjetos),OBJTOTMAT+1] := aEdt // Controla bot๕es com edi็ใo ou nao
    
Return Self

/*---------------------------------------------------------------------
Metodo Getobj()

	Retorna o objeto atual da janela
-----------------------------------------------------------------------*/

Method Getobj(cWindow) Class PCOLayer

Local nFld 	:= aScan(Self:aObjetos,{|x|SubStr(x[1],1,3)=='FLD' .and. x[3]==cWindow .and. x[5]=.T.})
Local nDlg	:= self:aObjetos[nFld][2]:NOPTION
Local nObj 	:= aScan(Self:aObjetos,{|x|x[6]=nDlg .and. x[3]=cWindow .and. x[5]=.T.})

Return Self:aObjetos[nObj,2]

/*---------------------------------------------------------------------
Metodo Bt()

	A็ใo do Bot๕es
-----------------------------------------------------------------------*/
Method Bt(nOpc,cWindow) Class PCOLayer

Local lRet	:= .T.
Local nX,nI
Local nFld,nDlg,nObj,nBut

// Localiza Folder
nFld 	:= aScan(Self:aObjetos,{|x|SubStr(x[OBJID],1,3)=='FLD' .and. x[OBJWINID]==cWindow .and. x[OBJVISIBLE]=.T.})
// Localiza Aba Ativa do Folder
If nFld > 0
	nDlg	:= self:aObjetos[nFld][OBJETO]:NOPTION
Else
	nDlg	:= nil
EndIf
// Localiza Objeto do Folder ou da Janela
nObj 	:= aScan(Self:aObjetos,{|x|x[OBJFOLDER]=nDlg .and. x[OBJWINID]=cWindow .and. x[OBJVISIBLE]=.T.})
// Localiza Botoes
nBut  := aScan(Self:aObjetos,{|x|SubStr(x[OBJID],1,3)=='BUT' .and. x[OBJWINID]=cWindow})

Do Case
	//GetDados
	Case SubStr(self:aObjetos[nObj][OBJID],1,3)="GTD"

		Do Case

			Case nOpc=1

				Eval(self:aObjetos[nObj,OBJBCHANGE],self:aObjetos[nObj,OBJETO],nObj) //bChange
							
				self:aObjetos[nObj,OBJETO] :lInsert := .T.
				self:aObjetos[nObj,OBJETO] :lUpdate := .T.
				self:aObjetos[nObj,OBJETO] :lDelete := .T.
				self:aObjetos[nObj,OBJETO] :Refresh()
				
			Case nOpc=2

  				lRetEval	:= Eval(self:aObjetos[nObj,OBJBCONFIRM],nObj) //bConfirm
				If VALTYPE(lRetEval)=="L"
					lRet		:= lRetEval
					lRetEval	:= Eval(self:aObjetos[nObj,OBJTOTMAT+2],self:aObjetos[nObj,OBJETO]:oBrowse,.T.) //bTOk
					If VALTYPE(lRetEval)=="L"
						lRet	:= lRetEval
					EndIf
				EndIf
				If lRet
					Eval(self:aObjetos[nObj,OBJTOTMAT+3],self:aObjetos[nObj,OBJTOTMAT+1])
					self:aObjetos[nObj,OBJETO] :lInsert 	:= .F.
					self:aObjetos[nObj,OBJETO] :lUpdate 	:= .F.
					self:aObjetos[nObj,OBJETO] :lDelete 	:= .F.
					Eval(self:aObjetos[nObj,OBJBLOAD],nObj) //bLoad // Atualizada acols
					self:aObjetos[nObj,OBJETO] :Refresh()
				EndIf

			Case nOpc=3

 				Eval(self:aObjetos[nObj,OBJBLOAD],nObj) //bLoad
				self:aObjetos[nObj,OBJETO] :lInsert 	:= .F.
				self:aObjetos[nObj,OBJETO] :lUpdate 	:= .F.
				self:aObjetos[nObj,OBJETO] :lDelete 	:= .F.
				self:aObjetos[nObj,OBJETO] :Refresh()

		EndCase

	//MsmGet
	Case SubStr(self:aObjetos[nObj,OBJID],1,3)="MSM"

		Do Case

			Case nOpc=1

				self:aObjetos[nObj,OBJETO]:Enable()

			Case nOpc=2

  				lRetEval := Eval(self:aObjetos[nObj,OBJBCONFIRM],nObj) //bConfirm
				If VALTYPE(lRetEval)=="L"
					lRet	:= lRetEval
				EndIf
				If lRet
					self:aObjetos[nObj,OBJETO]:Disable()
					self:aObjetos[nObj,OBJETO]:EnchRefreshAll()
				EndIf
			Case nOpc=3

 				If VALTYPE(self:aObjetos[nObj,OBJBCHANGE])=="B"
	 				Eval(self:aObjetos[nObj,OBJBCHANGE],nObj) //bLoad
	 			EndIf
				self:aObjetos[nObj,OBJETO]:Disable()
				self:aObjetos[nObj,OBJETO]:EnchRefreshAll()

		EndCase

EndCase

If lRet
	// Lock dos outros objeto
	For nX := 1 To Len(self:aObjetos)
	    
		// Nใo Desativa Objetos editados
		If nX==nFld
			For nI := 1 To Len(self:aObjetos[nX,OBJETO]:aDialogs)
				If nI<>self:aObjetos[nObj,OBJFOLDER]
					If nOpc=1
						self:aObjetos[nX,OBJETO]:aDialogs[nI]:Disable()
					Else
						self:aObjetos[nX,OBJETO]:aDialogs[nI]:Enable()
					EndIf
				EndIf
			Next
		ElseIf nX<>nObj .and. nX<>nBut
		
			If nOpc=1
			
				If VALTYPE(self:aObjetos[nX,OBJETO])="A"
				
					aEval( self:aObjetos[nX,OBJETO] ,{|x| x:Disable()} )
				
				Else
					// Nใo Disabilita GetDados nem MSMGet			
					If !(SubStr(self:aObjetos[nX,OBJID],1,3)$"MSM#GTD#BTR")
						self:aObjetos[nX,OBJETO]:Disable()
				    EndIf
				
				EndIf
			
			Else
			
				If VALTYPE(self:aObjetos[nX,OBJETO])="A"
				
					aEval( self:aObjetos[nX,OBJETO] ,{|x,y| If(self:aObjetos[nX,OBJBCONFIRM + 1,y],x:Disable(),.F.) } )
					self:aObjetos[nX,OBJETO,1]:Enable()
					
				Else
			
					// Nใo Abilita GetDados nem MSMGet			
					If !(SubStr(self:aObjetos[nX,OBJID],1,3)$"MSM#GTD#BTR")
						self:aObjetos[nX,OBJETO]:Enable()
				    EndIf
				
				EndIf
	
			EndIf
		
		//Trata Bot๕es
		ElseIf nX==nBut
	
			If nOpc=1
				
				If VALTYPE(self:aObjetos[nX,OBJETO])="A"
					
					aEval( self:aObjetos[nX,OBJETO] ,{|x,y| If(self:aObjetos[nX,OBJBCONFIRM+1,y],x:Enable(),.F.) } )
					If self:aObjetos[nX,OBJBCONFIRM+1,1]
						self:aObjetos[nX,OBJETO,1]:Disable()
					EndIf
	
				EndIf
				
			Else
			
				If VALTYPE(self:aObjetos[nX,OBJETO])="A"
					
					aEval( self:aObjetos[nX,OBJETO] ,{|x,y| If(self:aObjetos[nX,OBJBCONFIRM+1,y],x:Disable(),.F.) } )
					If self:aObjetos[nX,OBJBCONFIRM+1,1]
						self:aObjetos[nX,OBJETO,1]:Enable()
					EndIf
					
				EndIf	
			
			EndIf
	
		EndIf
	
	Next
Endif

Return Self

/*---------------------------------------------------------------------
Metodo addLockObj()

   Locks de Objetos nos Bot๕es do Browse
-----------------------------------------------------------------------*/
Method addLockObj(nOpc,nObj,aLocks) Class PCOLayer

	aAdd(self:aObjLock,{nOpc,nObj,aLocks})

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRefreshTreบAutor  ณAcacio Egas         บ Data ณ  30/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para atualizar o tree de acordo com a estrtura.     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RefreshTre(cIdTre) Class PCOLayer

Local oTre
Local nI
Local cCargo
Default cIdTre	:= "001"

oTre	:=	Self:GetTre(cIdTre)

If Self:lRun
	cCargo := Self:GetTre(cIdTre):GetCargo()
	oTre:Reset()
EndIf	

//**************************
// Atualiza o Objeto Tre   *
//**************************
If Empty(Self:Estrutura[1,11])
	Self:LoadTree(oTre,Self:Estrutura[1,2],,,1)
Else
	Self:LoadTree(oTre,Self:Estrutura[1,2],&(Self:Estrutura[1,11]),,1)
EndIf

//***********************************
// Restaura posicao do Objeto Tre   *
//***********************************
If Self:lRun

	oPlanej:GetTre("001"):Display()
	cCargo := oTre:aCargo[1][1]
	oPlanej:GetTre("001"):TreeSeek(cCargo)

EndIf

//**********************************
// Atualiza layout do Objeto Tre   *
//**********************************
If (nI	:= aScan(Self:aLayouts, {|x| x[4]==.T.})) > 0
	Self:ShowLayout(Self:aLayouts[nI,1])
EndIf
	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadTree  บAutor  ณAcacio Egas         บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para carregar o obejto xTree.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LoadTree(oTree,cAliasTre,cDe,cAte,nType,lLoad,aSubItem,cFilMacro,cChave) Class PCOLayer
                         
Local nIt
Local nX
Local lRet:= .T.
Local aArea := GetArea()
Local aAuxArea
Local cUtil
Local cAlias
Local aAreaAlias
      
Default oTree		:= Self:GetTre("001")
Default cAliasTre	:= Self:Estrutura[1,2]
Default cDe			:= ''
Default nType		:= 2
Default lLoad		:= .T.
Default aSubItem	:= {}
Default cFilMacro 	:= ".T."

nIt := aScan(Self:Estrutura,{|x|x[2]==cAliasTre})
cAlias := SubStr(cAliasTre,1,3) // Retirar este tratamento

Default cChave		:= "Str(RECNO())"

If nIt>0

	If !Empty(RetSqlName(cAlias))
	   	//*************************************
	   	// Inclui item com rela็ใo com Alias  *
	   	//*************************************

		aAreaAlias := (cAlias)->(GetArea())
		DbSelectArea(cAlias)
		DbSetOrder(Self:Estrutura[nIt,12])
		DbGoTop()	
	
		If !DbSeek(xFilial(cAlias)+cDe) //.AND. (&(cFilMacro))
	
			Return
	
		EndIf
	
		If Empty(cDe)
			cAte := "ZZZZ"
		ElseIf Empty(cAte)
			cAte := cDe
		EndIf
		Do While !Eof() .and. &(IndexKey())>=xFilial(cAlias)+cDe .and. &(IndexKey())<=xFilial(cAlias)+cAte
	
			//**********************************
			// Localiza sub-itens na estrutura *
			//**********************************
			If Len(aSubItem)==0 .and. Len(Self:Estrutura) > nIt
			
				If Empty(RetSqlName(Self:Estrutura[nIt+1,2]))	
					Aadd(aSubItem,{Self:Estrutura[nIt+1,2],,{},,Self:Estrutura[nIt+1,3]})			
				ElseIf !Empty(Self:Estrutura[nIt+1,11])
		
					DbSelectArea(Self:Estrutura[nIt+1,2])
					DbSetOrder(Self:Estrutura[nIt+1,12])
					cUtil := xFilial(Self:Estrutura[nIt+1,2])+ &(Self:Estrutura[nIt+1,11])
					DbSeek(cUtil)
					
					Do While !Eof() .and. cUtil==SUbStr(&(IndexKey()),1,Len(cUtil))		
						Aadd(aSubItem,{Self:Estrutura[nIt+1,2],RECNO(),{},RECNO(),Self:Estrutura[nIt+1,3]})
						DbSkip()
				   	EndDo
				EndIf
				
			
			EndIf	    
	
			If &(cFilMacro)
	
				If lLoad .and. VALTYPE(Self:Estrutura[nIt,9])="B"       
					aAuxArea := GetArea()
					lRet := Eval(Self:Estrutura[nIt,9],cAlias+&(cChave) , oTree:GetCargo() ) // Load
					RestArea(aAuxArea)
				EndIf
	
				DbSelectArea(cAlias)
				If nType=1 .and. lRet
	
					oTree:AddTree(&(Self:Estrutura[nIt,3]),Self:Estrutura[nIt,5],Self:Estrutura[nIt,5],cAliasTre+&(cChave), Self:Estrutura[nIt,6],Self:Estrutura[nIt,7],Self:Estrutura[nIt,8])
	
					LoadItTree(oTree,aSubItem,Self:Estrutura,nIt,nType,Self:lRun,lLoad)
	
					oTree:EndTree()
	
				ElseIf nType=2 .and. lRet
	
					oTree:AddItem( &(Self:Estrutura[nIt,3]), cAliasTre+&(cChave), Self:Estrutura[nIt,5], Self:Estrutura[nIt,5], 2,Self:Estrutura[nIt,6],Self:Estrutura[nIt,7],Self:Estrutura[nIt,8])
					
					LoadItTree(oTree,aSubItem,Self:Estrutura,nIt,nType,Self:lRun,lLoad)
	
				EndIf
	
			EndIf
	
			DbSelectArea(cAlias)
			aSubItem := {}
			(cAlias)->(DbSkip())
		EndDo
		RestArea(aAreaAlias)
    Else
    	//*************************************
    	// Inclui item sem rela็ใo com Alias  *
    	//*************************************
		If lLoad .and. VALTYPE(Self:Estrutura[nIt,9])="B"
                
			aAuxArea := GetArea()
			lRet := Eval(Self:Estrutura[nIt,9],cAlias+oTree:GetCargo() , oTree:GetCargo() ) // Load
			RestArea(aAuxArea)

		EndIf

		If nType=1 .and. lRet

			oTree:AddTree(&(Self:Estrutura[nIt,3]),Self:Estrutura[nIt,5],Self:Estrutura[nIt,5],cAliasTre+&(cChave), Self:Estrutura[nIt,6],Self:Estrutura[nIt,7],Self:Estrutura[nIt,8])

			LoadItTree(oTree,aSubItem,Self:Estrutura,nIt,nType,Self:lRun,lLoad)

			oTree:EndTree()

		ElseIf nType=2 .and. lRet

			oTree:AddItem( &(Self:Estrutura[nIt,3]), cAliasTre+&(cChave), Self:Estrutura[nIt,5], Self:Estrutura[nIt,5], 2,Self:Estrutura[nIt,6],Self:Estrutura[nIt,7],Self:Estrutura[nIt,8])
			
			LoadItTree(oTree,aSubItem,Self:Estrutura, nIt ,nType,Self:lRun,lLoad)

		EndIf

    EndIf
EndIf

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA491   บAutor  ณMicrosiga           บ Data ณ  08/17/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo Para Incluir Itens de um No                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOLayer                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadItTree(oTree,aItens,Estrutura,nEstIni,nType,lRun,lLoad)

Local nX,nI
Local nItSub
Local aArea := GetArea()
Local aAreaTre
Local aAuxArea
Local cAlias
Local cAliasTre
Local lRet := .T.
Local lSeek
Local cSeek
Local cChave
Local cChvPri
Default nEstIni	:= 0
Default nType 	:= 2

If VALTYPE(aItens)<>"A"

	aItens := {}

EndIf

If nType==2 .or. lRun
	cSeek := oTree:aCargo[Len(oTree:aCargo),1]
EndIf
For nX:=1 to Len(aItens)
    
	If nType==2 .or. lRun // Pontera Item incluido
		oTree:TreeSeek(cSeek)
	EndIf
	cAliasTre 	:= aItens[nX,1]
	cAlias		:= SubStr(aItens[nX,1],1,3)//Retirar 
	
	If Empty(RetSqlName(cAlias))
		lSeek := .T.
		nItSub := aScan(Estrutura,{|x|x[2]==cAliasTre})
		cChvPri	:= cAlias+oTree:GetCargo()
	Else
		// Busca Chave especifica
		If Len(aItens[nX])>=4 .and. !Empty(aItens[nX,4])
			cChave := aItens[nX,4]
		Else
			cChave := (cAlias)->(IndexKey())
		EndIf
		
		aEval(Estrutura,{|x,y| If(x[2]==cAliasTre.and.y==nEstIni+1,nItSub := y,.F.)})
		DbSelectArea(cAlias)
		DbSetOrder(1)
		If VALTYPE(aItens[nX,2])=="N"
			DbGoTo(aItens[nX,2])	
			lSeek := aItens[nX,2]==recno()
			cChvPri	:= cAlias+Str(cChave)
		Else
			DbGoTop()
			lSeek := DbSeek(xFilial(cAlias)+aItens[nX,2])
			cChvPri	:= cAlias+&(cChave)
		EndIf
	EndIf
	If lSeek

		If nItSub>0
            
			If VALTYPE(aItens[nX,3])=="A"
                
               	If Len(aItens[nX,3])==0 .and. Len(Estrutura) > nItSub
	
					If Empty(RetSqlName(Estrutura[nItSub+1,2]))
					
						Aadd(aItens[nX,3],{Estrutura[nItSub+1,2],,{},,Estrutura[nItSub+1,3]})
				
					ElseIf !Empty(Estrutura[nItSub+1,11])
			            aAreaTre	:= GetArea()
			            DbSelectArea(Estrutura[nItSub+1,2])
						DbSetOrder(Estrutura[nItSub+1,12])
						cUtil := xFilial(Estrutura[nItSub+1,2]) + &(Estrutura[nItSub+1,11])
						If DbSeek(cUtil)					
							Do While !Eof() .and. cUtil==SUbStr(&(IndexKey()),1,Len(cUtil))
				
								Aadd(aItens[nX,3],{Estrutura[nItSub+1,2],RECNO(),{},RECNO(),Estrutura[nItSub+1,3]})
								DbSkip()
						   	EndDo
					   	EndIf
					   	RestArea(aAreaTre)
					EndIf
					
				
				EndIf
                
                // Adiciona SubItem
				If nType==1

					If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
                	    //								, Chave a ser incluida,			Chave do Pai dela
						aAuxArea := GetArea()
						lRet := Eval(Estrutura[nItSub,9], cChvPri , oTree:GetCargo() ) // Load
                        RestArea(aAuxArea)
					EndIf
					
					If lRet

						oTree:AddTree(&(Estrutura[nItSub,3]),Estrutura[nItSub,5],Estrutura[nItSub,5], cChvPri , Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8])
						LoadItTree( oTree , aItens[nX,3] , Estrutura, nItSub , nType , lRun, lLoad) // Inclui SubItem
						oTree:EndTree()

					EndIf
	
				Else

					If lRun

						If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
	                	    //								, Chave a ser incluida,			Chave do Pai dela	                	
							aAuxArea := GetArea()
							lRet := Eval(Estrutura[nItSub,9], cChvPri , oTree:GetCargo() ) // Load
							RestArea(aAuxArea)
	
						EndIf
						
						If lRet
	
							oTree:AddItem( &(Estrutura[nItSub,3]), cChvPri , Estrutura[nItSub,5], Estrutura[nItSub,5], 2,Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8])
							LoadItTree( oTree , aItens[nX,3] , Estrutura , nItSub , nType , lRun , lLoad)
	
						EndIf
						
					Else
                    	Aviso("Aten็ใo","Erro na Constru็ใo do Objeto xTree",{"OK"})
                    EndIf
				EndIf				
			Else
                // Adiciona Item
				If nType==1
				
					If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
                	    //								, Chave a ser incluida,			Chave do Pai dela                	
						aAuxArea := GetArea()
						lRet := Eval(Estrutura[nItSub,9], cChvPri , oTree:GetCargo() ) // Load
						RestArea(aAuxArea)

					EndIf
					
					If lRet
				
						oTree:AddTreeItem( &(Estrutura[nItSub,3]), Estrutura[nItSub,5], cChvPri , Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8] )
                
					EndIf
					
                Else
					If lRun                
					
						If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
                	
							aAuxArea := GetArea()
							lRet := Eval(Estrutura[nItSub,9], cChvPri , oTree:GetCargo() ) // Load
							RestArea(aAuxArea)

						EndIf
					
						If lRet

							oTree:AddItem( &(Estrutura[nItSub,3]), cChvPri , Estrutura[nItSub,5], Estrutura[nItSub,5], 2,Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8])
					
						EndIf
	
					Else
    
                    	Aviso("Aten็ใo","Erro na Constru็ใo do Objeto xTree",{"OK"})
    
                    EndIf
    
                EndIf
                
            EndIf
	
		EndIf

	EndIf					

Next

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบStatic  ณRWaCols   บAutor  ณAcacio Egas         บ Data ณ  06/25/09   บฑฑ
ฑฑฬออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Funcao para ler ou (gravar e Validar) um aCols na          บฑฑ
ฑฑบDesc.   ณ Tabelam SX3.                                               บฑฑ
ฑฑฬออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.  ณ cRW = "R" : Preenche o aCols                               บฑฑ
ฑฑบParam.  ณ cRW = "W" : Valida e grava o aCols                         บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RWaCols(cRW,cAlias,nOrder,cSeek,aHeader,aCols,aRecno,cAutoInc)

Local lRet	:= .T.
Local nX,nPos,nHead

Default aRecno	:= {}
Default cAutoInc	:= ""

If cRW=="R"

	DbSelectArea(cAlias)
	DbSetOrder(nOrder)
	cSeek := RTrim(cSeek)
	aCols := {}
	aRecno:= {}
	If DbSeek(cSeek)
		Do While (cAlias)->(!Eof()) .and. (ValType(cSeek)=="C" .and. cSeek==SubStr(&((cAlias)->(IndexKey())),1,Len(cSeek)))
			aAdd(aCols,Array(Len(aHeader) + 1))
			AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
			aAdd(aRecno,(cAlias)->(Recno()))
			aCols[Len(aCols)][Len(aHeader) + 1] := .F. // Deleted
			(cAlias)->(DbSkip())
		EndDo
	EndIf

ElseIf cRW=="W"

	For nX:= 1 to Len(aCols)
		// Trata linha deletada
		If	aCols[nX,Len(aHeader)+1] .and. Len(aRecno)>=nX
			DbSelectArea(cAlias)
			DbGoTo(aRecno[nX])
			RecLock(cAlias,.F.,.T.)
			DbDelete()
			MsUnlock()
		ElseIf !aCols[nX,Len(aHeader)+1] // Linha nใo deletadao

			DbSelectArea("SX3")
			DbSetOrder(1)
			DbSelectArea(cAlias)
			If Len(aRecno)>=nX
				DbGoTo(aRecno[nX])
				RecLock(cAlias,.F.)
			Else
				RecLock(cAlias,.T.)
				Aadd(aRecno,Recno())
			EndIf
			SX3->(DbSeek(cAlias))
			While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == cAlias
				If SX3->X3_CONTEXT <> "V"
					If (nPos := (cAlias)->(FieldPos(SX3->X3_CAMPO))) > 0 
						If ("_FILIAL" $ SX3->X3_CAMPO)
							(cAlias)->(FieldPut(nPos,xFilial(cAlias)))
						ElseIf (nHead := aScan(aHeader,{|x| x[2]==SX3->X3_CAMPO })) == 0
							If !Empty(SX3->X3_RELACAO)
								(cAlias)->(FieldPut(nPos,CriaVar(SX3->X3_CAMPO,.T.) ))
							EndIf
						Else
							(cAlias)->(FieldPut(nPos,aCols[nX,nHead]))
						EndIf					
					EndIf
				EndIf
				SX3->(DbSkip())
			EndDo
			MsUnlock()
		EndIf
	Next
    /*
	DbSelectArea(cAlias)
	DbSetOrder(nOrder)
	cSeek := RTrim(cSeek)
	If DbSeek(cSeek)
		aCols := {}
		aRecno:= {}
		Do While (cAlias)->(!Eof()) .and. (ValType(cSeek)=="C" .and. cSeek==SubStr(&((cAlias)->(IndexKey())),1,Len(cSeek)))
			aAdd(aCols,Array(Len(aHeader) + 1))
			AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
			aAdd(aRecno,(cAlias)->(Recno()))
			aCols[Len(aCols)][Len(aHeader) + 1] := .F. // Deleted
			(cAlias)->(DbSkip())
		EndDo
	Else
		// Deleta linhas no acols
		While (nX:= aScan(aCols,{|x| x[Len(aHeader)+1]==.T. }))>0
			aDel(aCols,nX)
			aSize(aCols,Len(aCols)-1)
		End
	EndIf
	*/
EndIf

// Cria linha para aCols vazio
If Len(aCols)==0
	aAdd(aCols,Array(Len(aHeader) + 1))
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT" , NIL , 	If(cAutoInc==Alltrim(x[2]), Soma1(CriaVar(AllTrim(x[2]))),CriaVar(AllTrim(x[2]))) ) })
	aCols[Len(aCols)][Len(aHeader) + 1] := .F. // Deleted
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOM2D    บAutor  ณAcacio Egas         บ Data ณ  06/26/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva conteudo da variavel de memoria na Tabela.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoM2D(cAlias,nRec,lInclui,lObrigat,bLoad)

Local aArea    	:= GetArea()
Local aAreaAlias:=	(cAlias)->(GetArea())
Local aAreaSX3 	:= SX3->(GetArea())
Local nX    := 0
Local lRet	:= .T.
Local cCpo  := ""

Default lInclui := .F.
Default lObrigat:= .F.

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek(cAlias)
	If lObrigat
		While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == cAlias
			If VerByte(SX3->X3_RESERV,7) .or. (X3Obrigat(SX3->X3_CAMPO))
				cCpo := "M->"+SX3->X3_CAMPO
				If Empty(&cCpo)
					lRet	:= .F.
					Help(1," ","OBRIGAT",,SX3->X3_TITULO,3,0)
					Exit
				EndIf			
			EndIf
			SX3->(DbSkip())
		EndDo
	EndIf
	If lRet
		SX3->(DbSeek(cAlias))
		DbSelectArea(cAlias)
		DbGoTo(nRec)
		RecLock(cAlias,lInclui)
		While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == cAlias
		
			If SX3->X3_CONTEXT <> "V"
				If (nX := (cAlias)->(FieldPos(SX3->X3_CAMPO))) > 0
					cCpo := "M->"+SX3->X3_CAMPO
					If TYPE(cCpo)==SX3->X3_TIPO
						(cAlias)->(FieldPut(nX,&cCpo))
					EndIf
				EndIf
			EndIf
			SX3->(DbSkip())
		EndDo
		MsUnlock()
	EndIf
EndIf

If VALTYPE(bLoad)=="B"
	Eval(bLoad)
EndIf

RestArea(aAreaSX3)
RestArea(aAreaAlias)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOD2M    บAutor  ณAcacio Egas         บ Data ณ  06/26/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva conteudo da Tabela na variavel de memoria.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoD2M(cAlias,nRec,bLoad)

Local aArea    	:= GetArea()
Local aAreaAlias:=	(cAlias)->(GetArea())
Local aAreaSX3 	:= SX3->(GetArea())
Local nX    := 0
Local lRet	:= .F.
Local cCpo  := ""
Local lInclui	:= (VALTYPE(nRec)<>"N")

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek(cAlias)
	If !lInclui
		DbSelectArea(cAlias)
		DbGoTo(nRec)
	EndIf
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == cAlias
	
		If SX3->X3_CONTEXT <> "V"
			If (nX := (cAlias)->(FieldPos(SX3->X3_CAMPO))) > 0
				cCpo := "M->"+SX3->X3_CAMPO
				If TYPE(cCpo)==SX3->X3_TIPO
					If lInclui
						&cCpo := CriaVar(SX3->X3_CAMPO)
					Else
						&cCpo := (cAlias)->(FieldGet(nX))
					EndIf
				EndIf
			EndIf
		EndIf
		SX3->(DbSkip())
	EndDo
	lRet := .T.
EndIf

If VALTYPE(bLoad)=="B"
	Eval(bLoad)
EndIf

RestArea(aAreaSX3)
RestArea(aAreaAlias)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRBrow     บAutor  ณAcacio Egas         บ Data ณ  06/26/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza dados do Browse                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RBrow(oBjBrow,cAlias,nOrder,cSeek)

Local aItens:= {}	
Local aFixe	:= {}
Local aCabec:= {}
Local nI
Local AreaAtu  := GetArea()
Local aAreaSx3 := SX3->(GetArea())
Local aAreaBrw

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias)

While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias

	If (nI := aScan(oBjBrow:aHeaders,{ |x| x == IIF(cPaisLoc == "RUS", TRIM(X3TITULO()), SX3->X3_TITULO) }) > 0)
	
		AAdd(aFixe,{	SX3->X3_TITULO	,;
						SX3->X3_CAMPO	,;
						SX3->X3_TIPO	,;
						SX3->X3_TAMANHO	,;
						SX3->X3_DECIMAL	,;
						SX3->X3_PICTURE	})
		aAdd(aCabec, SX3->X3_TITULO)
	EndIf

	SX3->(DbSkip())

End

RestArea(aAreaSx3)

If Len(aFixe)==0
	Return
EndIf

aAreaBrw := (cAlias)->(GetArea())

DbSelectArea(cAlias)
DbSetOrder(nOrder)
cSeek := RTrim(&(cSeek))
If	DbSeek(cSeek)
	Do While (cAlias)->(!Eof()) .and. (ValType(cSeek)=="C" .and. cSeek==SubStr(&((cAlias)->(IndexKey())),1,Len(cSeek)))
		aAdd(aItens,Array(Len(aFixe)))
		For nI:=1 To Len(aFixe)
			aItens[len(aItens),nI] := Transform(((cAlias)->&(aFixe[nI,2])),aFixe[nI,6])
		Next
		(cAlias)->(DbSkip())
	EndDo
Else
	aAdd(aItens,Array(Len(aFixe)))
EndIf	

oBjBrow:SetArray(aItens)
oBjBrow:bLine := {|| aItens[oBjBrow:nAt] }

RestArea(aAreaBrw)
RestArea(AreaAtu)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBtTre     บAutor  ณAcacio Egas         บ Data ณ  06/26/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui ou deleta item do tre.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BtTre(cId,nOpc,Self)           

Local nI,lRet
Local aArea	:= GetArea()
Local oTre	:= Self:GetTre(cId)
Local cAlias:= If(Empty(oTre:aCargo),Self:Estrutura[1,2],SubStr(oTre:GetCargo(),1,3))
Local nRecno:= If(Empty(oTre:aCargo),0,Val(SubStr(oTre:GetCargo(),4)))

Private cCadastro

If (nI	:= aScan(Self:Estrutura,{|x| x[2]==cAlias})) > 0 .and. Self:Estrutura[nI,13]
	If nOpc==1	
		cCadastro	:= "Incluir - "+ Self:Estrutura[nI,1]
		INCLUI	:= .T.
		lRet := AxInclui(cAlias)
		INCLUI	:= .F.
		If lRet==1
			Self:RefreshTre(cId)
		EndIf
	ElseIf nOpc==3 .and. !Empty(nRecno)
		cCadastro	:= "Excluir -" + Self:Estrutura[nI,1]	
		aAreaA	:= (cAlias)->(GetArea())
		DbSelectArea(cAlias)
		DbGoTo(nRecno)
		lRet	:= Eval(Self:Estrutura[nI,14],nOpc)
		If VALTYPE(lRet)=="L" .and. lRet
			lRet :=	AxDeleta(cAlias,nRecno,5)
			If lRet==2
				Self:RefreshTre(cId)
			EndIf
		EndIf
		RestArea(aAreaA)
	EndIf
EndIf

RestArea(aArea)

Return

// Fun็ใo dummp para objeto
Function PCOLayer()

Return .T.
