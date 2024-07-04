// Classe PCOArea
// Copyright (C) 2008, Microsiga
//

#include "protheus.ch"
#include "pcoa491.ch"	//Include de Biblioteca
#include "pcoa491a.ch"	//Include de Traducao

Class PCOArea

	Data oDlg  		As Object
	Data oPainel	As Object
	Data oArea 		As Object
	Data oTree		As Object
	Data oSideBar	As Object
	Data aObjetos 	As Array
	Data aWindows 	As Array
	Data aLayouts 	As Array
	Data Estrutura 	As Array
	Data aObjLock	As Array
	Data aWindow	As Array

	Data nMaxWin	As Integer
	Data lRun		As Array

	Method New( nLeft, nTop, nWidth, nHeight, cTitulo) Constructor

	// métodos
	Method AddWindow( nAltura, cWindow, cTitulo, cWinAlter, lBut, cLayout, oMother, aButs)
	Method AddLayout( cLyt, bAction)
	Method ShowLayout( cLayout )
	Method AddBrw( cID, cTitulo, aCabec, cWindow, cLayout, bShow)
	Method GetBrw( cID )	
	Method AddGtD( cID, cTitulo, cWindow, cLayout, aHeader, aCols, bChange, bLoad, bConfirm )
	Method GetGtD( cID)
	Method AddMsm( cID, cTitulo, cAlias, cRecno, cWindow, cLayout, bLoad, bConfirm, _aGetValues , nOpc)
	Method GetMsm( cID )
	Method Getobj(cWindow)
	Method AddSide( cTitulo )
	Method GetSidebar()
	Method BarBut( aButs, cWindow, cLayout )
	Method Bt( nOpc, cWindow )
	Method AddTre(cID,cWindow,cLayout,bVldNo)
	Method GetTre( cID )
	Method No_Tree( cTitulo, cAlias, cMacro, cIMG, bAction, bRClick, bDblClick, bLoad )
	Method LoadTree(oTree,cAliasTre,cDe,cAte,nTree,lLoad,aSubItem,cFilMacro,cChave)
	Method addLockObj( nOpc, nObj, aLocks )
	Method Activate(lCentered)

EndClass

/*---------------------------------------------------------------------
Metodo New() CONSTRUTOR
-----------------------------------------------------------------------*/
Method New(nTop,nLeft,nWidth, nHeight,cTitulo) Class PCOArea	 

	Self:aWindow	:= {}
	Self:aObjetos 	:= {}
	Self:aWindows  	:= {}
	Self:aLayouts	:= {}
	Self:Estrutura 	:= {}
	self:aObjLock	:= {}
	Self:nMaxWin 	:= 0   
	Self:lRun		:= .F.
	iF nTop>0 .or. nLeft>0

		Self:oDlg := TDialog():New( nTop, nLeft, nWidth, nHeight,cTitulo,/*<cResName>*/,/*<hResources>*/,/*<.vbx.>*/,/*<nStyle>*/,;
                 /*<nClrText>*/,/*<nClrBack>*/,/*<oBrush>*/,/*<oWnd>*/,.t.,;
                 /*<oIco>*/,/*<oFont>*/,/*<nHelpId>*/,nWidth,nHeight ) 

	Endif

		Self:oArea 	:= 	FwArea():New(nTop,nLeft , nWidth, nHeight,@Self:oDlg, 1,cTitulo)

	// Monta Objeto FWAREA

	Self:oArea:CreateBorder(3)
	Self:oArea:AddLayout("LYT0")

Return Self

/*---------------------------------------------------------------------
Metodo Activate()
-----------------------------------------------------------------------*/
Method 	Activate(lCentered)	Class PCOArea

Default lCentered := .T.

Self:lRun		:= .T.

If VALTYPE(Self:oDlg)=='O'
	Self:oDlg:Activate(,,,lCentered)
Else
	Self:oArea:ActDialog()
EndIf


Return self

/*---------------------------------------------------------------------
Metodo AddSide()
-----------------------------------------------------------------------*/
Method AddSide(nPerc,cTitulo) Class PCOArea	 

	Self:oArea:AddSidebar(nPerc, 1, "SIDE")
	::oSideBar	:= Self:oArea:GetSidebar("SIDE")
    
Return Self	

/*---------------------------------------------------------------------
Metodo GetSidebar()

   Retorna o Objeto Side bar
-----------------------------------------------------------------------*/
Method GetSidebar() Class PCOArea
Return self:oArea:GetSidebar("SIDE")


/*---------------------------------------------------------------------
Metodo AddWindow()

   Adiciona janela
-----------------------------------------------------------------------*/
Method 	AddWindow(nAltura,cWindow,cTitulo,cWinAlter,lBut,cLayout,oMother,aButs)	Class PCOArea

Local nWinAlter
Local aButtons := {}
Local nX

Default lBut	:= .F.       
Default oMother := Self:oArea:GetLayout ( "LYT0" )
Default aButs	:= {}
// Monta Janela
Self:nMaxWin++

If (nWinAlter := aScan(Self:aWindow,{|x|x[2]==cWinAlter}))==0 // Localiza Window a ser alterada

	nWinAlter := Self:nMaxWin +1

EndIf

Self:oArea:AddWindow ( 100, nAltura, cWindow, cTitulo, Self:nMaxWin, nWinAlter, oMother)
Self:oArea:AddPanel  ( 50, 25, cWindow )
aAdd(Self:aWindow,{cWindow,Self:nMaxWin,nil})
Self:aWindow[Len(Self:aWindow),3] := Self:oArea:GetPanel( cWindow )

If lBut
	// Cria Vetor de Botões
	aAdd(aButtons,{1,"NOTE"		,{|| Self:Bt(1,cWindow) 	},	STR0003	,.T.}	)	//"Editar"
	aAdd(aButtons,{2,STR0001	,{|| Self:Bt(2,cWindow) 	},	STR0001	,.T.}	)	//"Confirmar"
	aAdd(aButtons,{2,STR0002	,{|| Self:Bt(3,cWindow)		},	STR0002	,.T.}	)	//"Cancelar"

EndIf

// Adiciona Botões
For nX := 1 to Len(aButs)
	aAdd(aButtons,aButs[nX])
	//aButs := { {2,"Cancelar"		,{|| Self:Bt(3,cWindow)	},	"Cancelar"	,lEdit,  } }
Next

If Len(aButtons)>0
	self:BarBut(aButtons,cWindow,cLayout)
EndIf

Return Self	

/*---------------------------------------------------------------------
Metodo AddLayout()

	Adiciona Layouts da Tela
-----------------------------------------------------------------------*/
Method AddLayout(cLyt,bAction) Class PCOArea

	aAdd(::aLayouts,{cLyt,bAction})

Return Self

/*---------------------------------------------------------------------
Metodo ShowLayout()

	Executa o :Show() nos objetos do layout e :Hide() nos de mais
-----------------------------------------------------------------------*/
Method 	ShowLayout(cLayout)	Class PCOArea

Local nX,nI

	For nX := 1 To Len(Self:aObjetos)

		If Self:aObjetos[nX,4]==cLayout

			If VALTYPE(Self:aObjetos[Nx,2])=="O"

				Self:aObjetos[nX,2]:Hide()
				Self:aObjetos[nX,2]:Show()
				Self:aObjetos[nX,5] := .T.

				//--------------------------------------------
				// Caso seja folder posiciona na primeira aba
				//--------------------------------------------
				If SubStr(self:aObjetos[nX,1],1,3)="FLD" .And. !("DistriWIN3" $ self:aObjetos[nX,1])
					Self:aObjetos[nX,2]:ShowPage(4)
					Self:aObjetos[nX,2]:ShowPage(1)	
				EndIf


			ElseIf VALTYPE(Self:aObjetos[nX,2])=="A"

				For Ni:=1 To Len(Self:aObjetos[nX,2])

					Self:aObjetos[nX,2,Ni]:Hide()
					Self:aObjetos[nX,2,Ni]:Show()
					Self:aObjetos[nX,5] := .T.

				Next 

			EndIf

		ElseIf Self:aObjetos[nX,4]<>nil

			If VALTYPE(Self:aObjetos[nX,2])=="O"

				Self:aObjetos[nX,2]:Show()		
				Self:aObjetos[nX,2]:Hide()
				Self:aObjetos[nX,5] := .F.

				//--------------------------------------------
				// Caso seja folder posiciona na primeira aba
				//--------------------------------------------
				If SubStr(self:aObjetos[nX,1],1,3)="FLD" .And. !("DistriWIN3" $ self:aObjetos[nX,1])
					Self:aObjetos[nX,2]:ShowPage(1)
				EndIf

				//--------------------------------------------
				// Caso seja folder posiciona na primeira aba
				//--------------------------------------------
				If SubStr(self:aObjetos[nX,1],1,3)="FLD" .And. self:aObjetos[nX,4] == "CC_Funcao" /* .And.!("DistriWIN3" $ self:aObjetos[nX,4]) */
					Self:aObjetos[nX,2]:ShowPage(2)
					Self:aObjetos[nX,2]:ShowPage(1)	
				EndIf 

			ElseIf VALTYPE(Self:aObjetos[nX,2])=="A"

				For nI:=1 To Len(Self:aObjetos[nX,2])
					Self:aObjetos[nX,2,nI]:Show()
					Self:aObjetos[nX,2,nI]:Hide()
					Self:aObjetos[nX,5] := .F.
				Next 

			EndIf

		EndIf

	Next
	
Return Self	

/*---------------------------------------------------------------------
Metodo AddTre()

	Inclui xTree
-----------------------------------------------------------------------*/
Method AddTre(cID,cWindow,cLayout,bVldNo) Class PCOArea

aAdd(self:aObjetos,{"TRE"+cID,nil,cWindow,cLayout,.F.,nil})
self:aObjetos[Len(self:aObjetos),2] := XTree():New(0, 0, 240, 150, Self:oArea:GetPanel( cWindow ) )
self:aObjetos[Len(self:aObjetos),2]:Align := CONTROL_ALIGN_ALLCLIENT	
If VALTYPE(bVldNo)<>"B"
	self:aObjetos[Len(self:aObjetos),2]:bValidNodes := {|| self:GetTre(cID):lActive }
Else
	self:aObjetos[Len(self:aObjetos),2]:bValidNodes := bVldNo
EndIf

Return self

/*---------------------------------------------------------------------
Metodo GetTre()

	Retorna Objeto Tree com o Id Informado
-----------------------------------------------------------------------*/
Method GetTre(cID) Class PCOArea

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="TRE"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo AddGtD()

	Inclui GetDados
-----------------------------------------------------------------------*/
Method AddGtD(cID,cTitulo,cWindow,cLayout,aHeaderGtd,aColsGtd,bChange,bLoad,bConfirm) Class PCOArea
	
Local nIpFolder

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

		aAdd(self:aObjetos,{"FLD"+cLayout+cWindow,nil,cWindow,cLayout,.F.,nil})
		nIpFolder := Len(self:aObjetos)
		self:aObjetos[nIpFolder,2] := TFolder():New(0,0,{cTitulo},{}, Self:oArea:GetPanel( cWindow ),,,, .F., .F.,490,100,)			
		self:aObjetos[nIpFolder,2]:Align := CONTROL_ALIGN_ALLCLIENT	

	Else

		self:aObjetos[nIpFolder,2]:AddItem( cTitulo )
		self:aObjetos[nIpFolder][2]:SetOption(1)
		self:aObjetos[nIpFolder,2]:Refresh()

	EndIf

	oBjtPai := self:aObjetos[nIpFolder,2]:aDialogs[Len(self:aObjetos[nIpFolder,2]:aDialogs)]

Else

	oBjtPai := Self:oArea:GetPanel( cWindow )
                            
EndIf

// Cria GetDados da Distribuição
aAdd(self:aObjetos,{"GTD"+cID,nil,cWindow,cLayout,.F.,nil,bChange,bLoad,bConfirm})  
self:aObjetos[Len(self:aObjetos),2] := MsNewGetDados():New(0,0,90,305,7,,,,,,,,,,oBjtPai,aHeader,aCols)
self:aObjetos[Len(self:aObjetos),2] :lInsert := .F.
self:aObjetos[Len(self:aObjetos),2] :lUpdate := .F.
self:aObjetos[Len(self:aObjetos),2] :lDelete := .F.
self:aObjetos[Len(self:aObjetos),2]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
self:aObjetos[Len(self:aObjetos),2] :Refresh()                                  
self:aObjetos[Len(self:aObjetos),2] :bChange 			:= self:aObjetos[Len(self:aObjetos),7] //bChange
self:aObjetos[Len(self:aObjetos),2] :oBrowse:bGotFocus 	:= self:aObjetos[Len(self:aObjetos),7] //bChange
self:aObjetos[Len(self:aObjetos),6] := Len(self:aObjetos[nIpFolder,2]:aDialogs)

Return Self

/*---------------------------------------------------------------------
Metodo AddMsm()

	Inclui MsmGet
-----------------------------------------------------------------------*/
Method AddMsm(cID,cTitulo,cAlias,cRecno,cWindow,cLayout,bLoad,bConfirm,_aGetValues,nOpc,aCposNot) Class PCOArea

Local aCpos	:= {}

Default nOpc := 4
Default aCposNot:= {}

	If cTitulo<>nil

		If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

			aAdd(self:aObjetos,{"FLD"+cLayout+cWindow,nil,cWindow,cLayout,.F.,nil})
			nIpFolder := Len(self:aObjetos)
			self:aObjetos[nIpFolder,2] := TFolder():New(0,0,{cTitulo},{}, Self:oArea:GetPanel( cWindow ),,,, .F., .F.,490,100,)
			self:aObjetos[nIpFolder,2]:Align := CONTROL_ALIGN_ALLCLIENT	

		Else

			self:aObjetos[nIpFolder,2]:AddItem( cTitulo )
			self:aObjetos[nIpFolder][2]:NOPTION := Len(self:aObjetos[nIpFolder,2]:aDialogs)

		EndIf

		oBjtPai := self:aObjetos[nIpFolder,2]:aDialogs[Len(self:aObjetos[nIpFolder,2]:aDialogs)]

	Else

		oBjtPai := Self:oArea:GetPanel( cWindow )

	EndIf
	
	
	aAdd(self:aObjetos,{"MSM"+cID,nil,cWindow,cLayout,.F.,nil,bLoad,bConfirm})

	If VALTYPE(_aGetValues)<>"A"
		aEval( GetaHeader(cAlias,,aCposNot) , {|x| aAdd( aCpos , x[2] ) } )
		self:aObjetos[Len(self:aObjetos),2] := MsMGet():New(cAlias,cRecno,nOpc,,,,aCpos,{0, 0, 640, 480},,4,,,,oBjtPai,,,.F.)
		self:aObjetos[Len(self:aObjetos),2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
		self:aObjetos[Len(self:aObjetos),2]:Disable()
		self:aObjetos[Len(self:aObjetos),6] := Len(self:aObjetos[nIpFolder,2]:aDialogs)

	Else

		self:aObjetos[Len(self:aObjetos),2] := MsMGet():New(cAlias,cRecno,4,,,,,{0, 0, 640, 480},,4,,,,oBjtPai,,,,,,.T.,_aGetValues)
		self:aObjetos[Len(self:aObjetos),2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
		self:aObjetos[Len(self:aObjetos),2]:Disable()
		self:aObjetos[Len(self:aObjetos),6] := Len(self:aObjetos[nIpFolder,2]:aDialogs)

	EndIf

Return Self

/*---------------------------------------------------------------------
Metodo GetBrw()

	Busca Browse
-----------------------------------------------------------------------*/
Method GetBrw(cID) Class PCOArea

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="BRW"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo GetGtD()

	Busca GetDados
-----------------------------------------------------------------------*/
Method GetGtD(cID) Class PCOArea

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="GTD"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo GetMsm()

	Busca Msmget
-----------------------------------------------------------------------*/
Method GetMsm(cID) Class PCOArea

Local nPosIt := aScan(self:aObjetos,{|x|x[1]=="MSM"+cID})

Return 	Self:aObjetos[nPosIt,2]

/*---------------------------------------------------------------------
Metodo AddBrw()

	Adiciona Browse
-----------------------------------------------------------------------*/
Method AddBrw(cID,cTitulo,aCabec,cWindow,cLayout,bShow) Class PCOArea

	If cTitulo<>nil

		If ( nIpFolder := aScan(self:aObjetos,{|x|x[1]=="FLD"+cLayout+cWindow}) )==0

			aAdd(self:aObjetos,{"FLD"+cLayout+cWindow,nil,cWindow,cLayout,.F.,nil})
			nIpFolder := Len(self:aObjetos)
			self:aObjetos[nIpFolder,2] := TFolder():New(0,0,{cTitulo},{}, Self:oArea:GetPanel( cWindow ),,,, .F., .F.,490,100,)
			self:aObjetos[nIpFolder,2]:Align := CONTROL_ALIGN_ALLCLIENT	

		Else

			self:aObjetos[nIpFolder,2]:AddItem( cTitulo )
			self:aObjetos[nIpFolder][2]:NOPTION := Len(self:aObjetos[nIpFolder,2]:aDialogs)

		EndIf

		oBjtPai := self:aObjetos[nIpFolder,2]:aDialogs[Len(self:aObjetos[nIpFolder,2]:aDialogs)]

	Else

		oBjtPai := Self:oArea:GetPanel( cWindow )

	EndIf
	
	aAdd(self:aObjetos,{"BRW"+cID,nil,cWindow,cLayout,.F.,nil,bShow})	
	self:aObjetos[Len(self:aObjetos),2] := 	TWBrowse():New(0, 0,305,90, ,aCabec,,oBjtPai,,,,,,,/*oPnlDistVal:oFont*/,,,,,.F.,,.T.,,.F.,,,)
	If cTitulo<>nil

		self:aObjetos[Len(self:aObjetos),6] := Len(self:aObjetos[nIpFolder,2]:aDialogs)

	EndIf

	self:aObjetos[Len(self:aObjetos),2]:Align := CONTROL_ALIGN_ALLCLIENT
	Eval(bShow) // Executa Refresh

Return self

/*---------------------------------------------------------------------
Metodo No_Tree()

	Adiciona Estrutura do Tree
-----------------------------------------------------------------------*/
Method No_Tree(cTitulo,cAlias,cMacro,cIMG,bAction,bRClick,bDblClick,bLoad) Class PCOArea

	aAdd(Self:Estrutura,{cTitulo,cAlias,cMacro,,cIMG,bAction,bRClick,bDblClick,bLoad})

Return Self

/*---------------------------------------------------------------------
Metodo BarBut()

	Inclui Botões
-----------------------------------------------------------------------*/
Method BarBut(aButs,cWindow,cLayout) Class PCOArea

Local nX
Local aBut
Local aImgIMG := {}
Local aActIMG := {}
Local aLabIMG := {}
Local aEdtIMG := {}

Local aTxtTXT := {}
Local aActTXT := {}
Local aLabTXT := {}
Local aEdtTXT := {}

	For Nx:=1 To Len(aButs)

		If aButs[Nx,1]=1

			aAdd(aImgIMG,aButs[Nx,2])
			aAdd(aActIMG,aButs[Nx,3])
			aAdd(aLabIMG,aButs[Nx,4])
			If Len(aButs[Nx])>4
				aAdd(aEdtIMG,aButs[Nx,5])
			Else
				aAdd(aEdtIMG,.F.)
			EndIf

		Else

			aAdd(aTxtTXT,aButs[Nx,2])
			aAdd(aActTXT,aButs[Nx,3])
			aAdd(aLabTXT,aButs[Nx,4])
			If Len(aButs[Nx])>4
				aAdd(aEdtTXT,aButs[Nx,5])
			Else
				aAdd(aEdtTXT,.F.)
			EndIf
		EndIf	

	Next

	self:oArea:AddButtonBar({ aImgIMG, aActIMG, aLabIMG })
	aAdd(self:aObjetos,{"BUT",nil,cWindow,cLayout,.F.,nil,nil})
	self:aObjetos[Len(self:aObjetos),2] := {}
	self:aObjetos[Len(self:aObjetos),7] := {} // Controla botões com edição ou nao
	aBut := Self:oArea:GetButtonBar(cWindow)
	For nX:= 1 To Len(aBut)
		
		aAdd( self:aObjetos[Len(self:aObjetos),2] , aBut[nX] )
		aAdd( self:aObjetos[Len(self:aObjetos),7] , aEdtIMG[nX] )
		
	Next
	
	self:oArea:AddTextButton({aTxtTXT,aActTXT,aLabTXT})
//	aAdd(self:aObjetos,{"BUT",nil,cWindow,cLayout,.F.,nil})
	aBut := Self:oArea:GetTextButton(cWindow)
	For nX:= 1 To Len(aBut)

		aBut[nX]:Disable() // Desabilita Botões de Confirmar e cancelar
		aAdd( self:aObjetos[Len(self:aObjetos),2] , aBut[nX] 	)
		aAdd( self:aObjetos[Len(self:aObjetos),7] , aEdtTXT[nX] )

	Next
Return Self

/*---------------------------------------------------------------------
Metodo Getobj()

	Retorna o objeto atual da janela
-----------------------------------------------------------------------*/

Method Getobj(cWindow) Class PCOArea

Local nFld 	:= aScan(Self:aObjetos,{|x|SubStr(x[1],1,3)=='FLD' .and. x[3]==cWindow .and. x[5]=.T.})
Local nDlg	:= self:aObjetos[nFld][2]:NOPTION
Local nObj 	:= aScan(Self:aObjetos,{|x|x[6]=nDlg .and. x[3]=cWindow .and. x[5]=.T.})

Return Self:aObjetos[nObj,2]

/*---------------------------------------------------------------------
Metodo Bt()

	Ação do Botões
-----------------------------------------------------------------------*/
Method Bt(nOpc,cWindow) Class PCOArea

Local nX,nI
Local nFld 	:= aScan(Self:aObjetos,{|x|SubStr(x[1],1,3)=='FLD' .and. x[3]==cWindow .and. x[5]=.T.})
Local nDlg	:= self:aObjetos[nFld][2]:NOPTION
Local nObj 	:= aScan(Self:aObjetos,{|x|x[6]=nDlg .and. x[3]=cWindow .and. x[5]=.T.})
Local nBut  := aScan(Self:aObjetos,{|x|SubStr(x[1],1,3)=='BUT' .and. x[3]=cWindow})   
Local nPosGET01 := 0
Local nPosLin := 0

Do Case
	//GetDados
	Case SubStr(self:aObjetos[nObj][1],1,3)="GTD"

		Do Case

			Case nOpc=1
//				Eval(self:aObjetos[nObj,7],nObj) //bChange				

				self:aObjetos[nObj,2] :lInsert := .T.
				self:aObjetos[nObj,2] :lUpdate := .T.
				self:aObjetos[nObj,2] :lDelete := .T.
//				self:aObjetos[nObj,2]:bChange := self:aObjetos[nObj,7] //bChange
				self:aObjetos[nObj,2] :Refresh()

			Case nOpc=2

  				Eval(self:aObjetos[nObj,9],nObj) //bConfirm
				self:aObjetos[nObj,2] :lInsert 	:= .F.
				self:aObjetos[nObj,2] :lUpdate 	:= .F.
				self:aObjetos[nObj,2] :lDelete 	:= .F.
//				self:aObjetos[nObj,2]:bChange 	:= {|| }
				self:aObjetos[nObj,2] :Refresh()			

			Case nOpc=3

 				Eval(self:aObjetos[nObj,8],nObj) //bLoad
				self:aObjetos[nObj,2] :lInsert 	:= .F.
				self:aObjetos[nObj,2] :lUpdate 	:= .F.
				self:aObjetos[nObj,2] :lDelete 	:= .F.
//				self:aObjetos[nObj,2]:bChange 	:= {|| }
				self:aObjetos[nObj,2] :Refresh()

		EndCase

	//MsmGet
	Case SubStr(self:aObjetos[nObj][1],1,3)="MSM"

		Do Case

			Case nOpc=1

				self:aObjetos[nObj,2]:Enable()

			Case nOpc=2
			
				nPosGET01 := aScan(self:aObjetos,{|x|x[1]=="GTD001"})
				nPosLin := self:aObjetos[nPosGET01,2]:nAt
  				Eval(self:aObjetos[nObj,8],nObj) //bConfirm
				self:aObjetos[nPosGET01,2]:ForceRefresh() //atualiza getdados PAI
				self:aObjetos[nPosGET01,2]:GoTo(nPosLin) //restaura a posicao selecionada pelo usuario na linha da get
				self:aObjetos[nPosGET01,2]:oBrowse:setFocus() //volta o foco para a grid
				self:aObjetos[nObj,2]:Disable()
		
			Case nOpc=3                       

 				Eval(self:aObjetos[nObj,7],nObj) //bLoad
				self:aObjetos[nObj,2]:Disable() 
				
		EndCase

EndCase

// Lock dos outros objeto
For nX := 1 To Len(self:aObjetos)
    
	// Não Desativa Objetos editados
	If nX==nFld
		For nI := 1 To Len(self:aObjetos[nX,2]:aDialogs)
			If nI<>self:aObjetos[nObj,6]
				If nOpc=1
					self:aObjetos[nX,2]:aDialogs[nI]:Disable()
				Else
					self:aObjetos[nX,2]:aDialogs[nI]:Enable()
				EndIf
			EndIf
		Next
	ElseIf nX<>nObj .and. nX<>nBut
	
		If nOpc=1
		
			If VALTYPE(self:aObjetos[nX,2])="A"
			
				aEval( self:aObjetos[nX,2] ,{|x| x:Disable()} )
			
			Else
				// Não Disabilita GetDados nem MSMGet			
				If !(SubStr(self:aObjetos[nX,1],1,3)$"MSM#GTD")
					self:aObjetos[nX,2]:Disable()
				Else
					self:aObjetos[nX,2]:Refresh()
			    EndIf
			    
			
			EndIf
		
		Else
		
			If VALTYPE(self:aObjetos[nX,2])="A"
			
				aEval( self:aObjetos[nX,2] ,{|x| x:Enable()} )
				
			Else
		
				// Não Abilita GetDados nem MSMGet			
				If !(SubStr(self:aObjetos[nX,1],1,3)$"MSM#GTD")
					self:aObjetos[nX,2]:Enable()  
				Else	
					self:aObjetos[nX,2]:Refresh()
			    EndIf
			
			EndIf

		EndIf
	
	//Trata Botões
	ElseIf nX==nBut

		If nOpc=1
			
			If VALTYPE(self:aObjetos[nX,2])="A"
				
				aEval( self:aObjetos[nX,2] ,{|x,y| If(self:aObjetos[nX,7,y],x:Enable(),.F.) } )
				If self:aObjetos[nX,7,1]
					self:aObjetos[nX,2,1]:Disable()
				EndIf

			EndIf
			
		Else
		
			If VALTYPE(self:aObjetos[nX,2])="A"
				
				aEval( self:aObjetos[nX,2] ,{|x,y| If(self:aObjetos[nX,7,y],x:Disable(),.F.) } )
				If self:aObjetos[nX,7,1]
					self:aObjetos[nX,2,1]:Enable()
				EndIf
				
			EndIf	
		
		EndIf

	EndIf

Next

Return Self

/*---------------------------------------------------------------------
Metodo addLockObj()

   Locks de Objetos nos Botões do Browse
-----------------------------------------------------------------------*/
Method addLockObj(nOpc,nObj,aLocks) Class PCOArea

	aAdd(self:aObjLock,{nOpc,nObj,aLocks})

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadTree  ºAutor  ³Acacio Egas         º Data ³  03/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para carregar o obejto xTree.                       º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºSintaxe   ³ LoadTree(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ ExpC1 - Objeto xTree a ser alterado.                       º±±
±±º          ³ ExpC2 - Alias da tabela e ser incluida no xTree.           º±±
±±º          ³ ExpC3 - Macro a para preencher a descrição do No           º±±
±±º          ³ ExpC4 - Filtro De utiizado na tabela p/ incluir Nos        º±±
±±º          ³ ExpC4 - Filtro Ate utiizado na tabela p/ incluir Nos       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	
Method LoadTree(oTree,cAliasTre,cDe,cAte,nType,lLoad,aSubItem,cFilMacro,cChave) Class PCOArea
                         
Local nIt := aScan(Self:Estrutura,{|x|x[2]==cAliasTre})
Local nX
Local lRet:= .T.
Local aArea := GetArea()
Local aAuxArea
Local cAlias := SubStr(cAliasTre,1,3)
Local aAreaAlias := &(cAlias)->(GetArea())

Default nType		:= 2
Default lLoad		:= .T.
Default aSubItem	:= {}
Default cFilMacro 	:= ".T."
Default cChave		:= (cAlias)->(IndexKey())
If nIt>0

	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbGoTop()	

	If !DbSeek(xFilial()+cDe) //.AND. (&(cFilMacro))

		Return

	EndIf

	If Empty(cAte)
		cAte := cDe
	EndIf
	Do While !Eof() .and. &(IndexKey())>=xFilial()+cDe .and. &(IndexKey())<=xFilial()+cAte

		If &(cFilMacro)

			If lLoad .and. VALTYPE(Self:Estrutura[nIt,9])="B"
                
				aAuxArea := GetArea()
				lRet := Eval(Self:Estrutura[nIt,9],cAlias+&((cAlias)->(IndexKey())) , oTree:GetCargo() ) // Load
				RestArea(aAuxArea)

			EndIf

			DbSelectArea(cAlias)
			If nType=1 .and. lRet

				oTree:AddTree(&(Self:Estrutura[nIt,3]),Self:Estrutura[nIt,5],Self:Estrutura[nIt,5],cAliasTre+&(cChave), Self:Estrutura[nIt,6],Self:Estrutura[nIt,7],Self:Estrutura[nIt,8])

				LoadItTree(oTree,aSubItem,Self:Estrutura,nType,Self:lRun,lLoad)

				oTree:EndTree()

			ElseIf nType=2 .and. lRet

				oTree:AddItem( &(Self:Estrutura[nIt,3]), cAliasTre+&(cChave), Self:Estrutura[nIt,5], Self:Estrutura[nIt,5], 2,Self:Estrutura[nIt,6],Self:Estrutura[nIt,7],Self:Estrutura[nIt,8])
				
				LoadItTree(oTree,aSubItem,Self:Estrutura,nType,Self:lRun,lLoad)

			EndIf

		EndIf

		DbSelectArea(cAlias)
		(cAlias)->(DbSkip())

	EndDo

EndIf

RestArea(aAreaAlias)
RestArea(aArea)

Return

// Função Para Incluir Itens de um No
Static Function LoadItTree(oTree,aItens,Estrutura,nType,lRun,lLoad)

Local nX
Local nItSub
Local aArea := GetArea()
Local aAuxArea
Local cAlias
Local cAliasTre
Local lRet := .T.
Local cSeek
Local cChave
Default nType := 2

If VALTYPE(aItens)<>"A"

	aItens := {}

EndIf

If nType==2
	cSeek := oTree:aCargo[Len(oTree:aCargo),1]
EndIf

For nX:=1 to Len(aItens)
    
	If nType==2 // Pontera Item incluido
		oTree:TreeSeek(cSeek)
	EndIf
	cAliasTre 	:= aItens[nX,1]
	cAlias		:= SubStr(aItens[nX,1],1,3)
	// Busca Chave especifica
	If Len(aItens[nX])>=4
		cChave := aItens[nX,4]
	Else
		cChave := (cAlias)->(IndexKey())
	EndIf
	
	nItSub := aScan(Estrutura,{|x|x[2]==cAliasTre})
	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbGoTop()	
	If DbSeek(xFilial(cAlias)+aItens[nX,2])

		If nItSub>0
            
			If VALTYPE(aItens[nX,3])=="A"
                // Adiciona SubItem
				If nType==1

					If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
                	    //								, Chave a ser incluida,			Chave do Pai dela
						aAuxArea := GetArea()
						lRet := Eval(Estrutura[nItSub,9],cAlias+&((cAlias)->(IndexKey())) , oTree:GetCargo() ) // Load
                        RestArea(aAuxArea)
					EndIf
					
					If lRet

						oTree:AddTree(&(Estrutura[nItSub,3]),Estrutura[nItSub,5],Estrutura[nItSub,5],cAliasTre+&(cChave), Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8])
						LoadItTree( oTree , aItens[nX,3] , Estrutura , nType , lRun, lLoad) // Inclui SubItem
						oTree:EndTree()

					EndIf
	
				Else

					If lRun

						If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
	                	    //								, Chave a ser incluida,			Chave do Pai dela	                	
							aAuxArea := GetArea()
							lRet := Eval(Estrutura[nItSub,9],cAlias+&((cAlias)->(IndexKey())) , oTree:GetCargo() ) // Load
							RestArea(aAuxArea)
	
						EndIf
						
						If lRet
	
							oTree:AddItem( &(Estrutura[nItSub,3]), cAliasTre+&(cChave), Estrutura[nItSub,5], Estrutura[nItSub,5], 2,Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8])
							LoadItTree( oTree , aItens[nX,3] , Estrutura , nType , lRun , lLoad)
	
						EndIf
						
					Else
                    	Aviso(STR0004,STR0005 + " xTree",{"OK"})	//"Atenção"##"Erro na Construção do Objeto"
                    EndIf
				EndIf				
			Else
                // Adiciona Item
				If nType==1
				
					If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
                	    //								, Chave a ser incluida,			Chave do Pai dela                	
						aAuxArea := GetArea()
						lRet := Eval(Estrutura[nItSub,9],cAlias+&((cAlias)->(IndexKey())) , oTree:GetCargo() ) // Load
						RestArea(aAuxArea)

					EndIf
					
					If lRet
				
						oTree:AddTreeItem( &(Estrutura[nItSub,3]), Estrutura[nItSub,5], cAliasTre+&(cChave), Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8] )
                
					EndIf
					
                Else
					If lRun                
					
						If lLoad .and. VALTYPE(Estrutura[nItSub,9])="B"
                	
							aAuxArea := GetArea()
							lRet := Eval(Estrutura[nItSub,9],cAlias+&((cAlias)->(IndexKey())) , oTree:GetCargo() ) // Load
							RestArea(aAuxArea)

						EndIf
					
						If lRet

							oTree:AddItem( &(Estrutura[nItSub,3]), cAliasTre+&(cChave), Estrutura[nItSub,5], Estrutura[nItSub,5], 2,Estrutura[nItSub,6],Estrutura[nItSub,7],Estrutura[nItSub,8])					
					
						EndIf
	
					Else
    
                    	Aviso(STR0004,STR0005 + " xTree",{"OK"})	////"Atenção"##"Erro na Construção do Objeto"
    
                    EndIf
    
                EndIf
                
            EndIf
	
		EndIf

	EndIf					

Next

RestArea(aArea)

Return
