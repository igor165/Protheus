#include "protheus.ch"
#include "MSMGADD.CH"
#include "FINA010N.ch"
#Include 'FWMVCDef.CH'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010N
Cadastro de Naturezas modelo Estruturado(Arvore)

@author  jose.aribeiro
@since   19/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function Fina010N()
Local oFWLayer	As Object
Local oMenuPop	As Object
Local aCoors 	As Array
Local oBtnBar1	As Object
Local cAlias := "SED"

Private INCLUI		As Logical		
Private ALTERA		As Logical 
Private EXCLUI		As Logical 
Private cCopiaRef	As Character
Private oGetSED		As Object
Private oPanel1		As Object				// Tela de Apresentacao da Rotina
Private oPanel2		As Object				// Tela de Apresentacao da Rotina
Private oTreeNat	As Object
Private oPanel3		As Object
Private oBtnBar2	As Object

aCoors := FWGetDialogSize( oMainWnd )

INCLUI		:= .F.
ALTERA		:= .F.
EXCLUI		:= .F.
cCopiaRef	:= ''
				
DEFINE DIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL 


 	// Cria instancia do fwlayer
	oFWLayer := FWLayer():New()
	// Inicializa componente passa a Dialog criada, 
	// o segundo parametro é para criação de um botao de fechar utilizado para Dlg sem cabeçalho
	oFWLayer:init( oDlg, .T. )

	// Adiciona coluna passando nome, porcentagem da largura, e se ela é redimensionada ou não
	// Cria windows passando, nome da coluna onde sera criada, nome da window
	// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
	// se é redimensionada em caso de minimizar outras janelas e a ação no click do split
	oFWLayer:addCollumn( "Col01", 30, .F. )
	oFWLayer:addWindow( "Col01", "Win01", STR0001, 95, .T., .F., /*{|| oFWChart01:refresh() }*/ ) // #Estrutura de Naturezas#
	oPanel1	:= oFWLayer:getWinPanel( "Col01", "Win01" )

		// TREE
		oTreeNat			:= XTree():New( 000, 000, 000, 000, oPanel1 )
		oTreeNat:Align		:= CONTROL_ALIGN_ALLCLIENT
	 	oTreeNat:bChange	:= {|x1,x2,x3| PosicionaSED( oTreeNat, oGetSED, oPanel1 ) }
		oTreeNat:bValid		:= {|| !INCLUI .and. !ALTERA .and.!EXCLUI }
		oTreeNat:bWhen		:= {|| !INCLUI .and. !ALTERA .and.!EXCLUI }	
		oTreeNat:BrClicked	:= {|x,y,z| oMenuPop:Activate( y-40, z-185, oPanel1 ) }
		
		//Cria o primeiro nodo
		oTreeNat:AddTree	( STR0002, ; //descricao do node###"#Cadastro de Naturezas" 
								"FOLDER5", ; //bitmap fechado
								"FOLDER6", ; //bitmap aberto
								'ID_PRINCIPAL', ; //cargo (id)
								/*bAction*/, /*bRClick*/, /*bDblClick*/ )
		AddTreeSED(oTreeNat,Criavar("ED_CODIGO"))
		oTreeNat:EndTree()

		MENU oMenuPop POPUP  																	         
			MENUITEM STR0003 ACTION actButtons( 3, oPanel2, oGetSED, oTreeNat, oPanel1 )	RESOURCE 'BMPINCLUIR'
			MENUITEM STR0004 ACTION actButtons( 4, oPanel2, oGetSED, oTreeNat, oPanel1 )	RESOURCE 'NOTE'
			MENUITEM STR0005 ACTION actButtons( 5, oPanel2, oGetSED, oTreeNat, oPanel1 )	RESOURCE 'EXCLUIR'
			MENUITEM '________________' DISABLED
			MENUITEM STR0006 ACTION NatCopiar( oTreeNat ) 									RESOURCE 'S4WB005N'
			MENUITEM STR0007 ACTION NatColar( oTreeNat, oPanel2 ) 							RESOURCE 'S4WB007N'
		ENDMENU          

		// BUTTONS
		oBtnBar1 := FWButtonBar():new()
		oBtnBar1:Init( oPanel1, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )
		oBtnBar1:addBtnImage( "RELOAD.PNG",	STR0008,	{|| RefreshTreeSED( oTreeNat, oPanel1, oGetSED ) }, , .T., CONTROL_ALIGN_LEFT) //"Refresh"
		oBtnBar1:addBtnImage( "S4WB005N.PNG",	STR0006,	{|| NatCopiar( oTreeNat ) },, .T., CONTROL_ALIGN_LEFT) //"Copiar"
		oBtnBar1:addBtnImage( "S4WB007N.PNG",	STR0007,	{|| NatColar( oTreeNat, oPanel2 )},, .T., CONTROL_ALIGN_LEFT) //"Colar"
		oBtnBar1:addBtnImage( "PESQUISA.PNG",	STR0009,	{|| PesqTree(  oTreeNat, oGetSED, oPanel1 ) },, .T., CONTROL_ALIGN_LEFT) //"Pesquisa Rápida"
			

	// Adiciona coluna passando nome, porcentagem da largura, e se ela é redimensionada ou não
	// Cria windows passando, nome da coluna onde sera criada, nome da window
	// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
	// se é redimensionada em caso de minimizar outras janelas e a ação no click do split
	oFWLayer:addCollumn( "Col02", 70, .F. )
	oFWLayer:addWindow( "Col02", "Win01", STR0011, 95, .F., .F., {|| } )
	oPanel2	:= oFWLayer:getWinPanel( "Col02", "Win01" )
	oPanel2:FreeChildren()
	oPanel3 := TPanel():New(0,0,'',oPanel2,, .T., .T.,, ,20,20,.T.,.T. )
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	@ 20,5 SAY oSay VAR HTMLDEF() OF oPanel3 FONT oPanel2:oFont PIXEL SIZE 350, 550 HTML 	
	// Painel 2 - Enchoice
			
	oGetSED				:= MsMGet():New( "SED", SED->( RecNo() ), 2,,,,, { 0, 0, 290, 252 },, 4,,,, oPanel3 )
	oGetSED:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
	oGetSED:Hide()
	oGetSED:oBox:Hide()

	// BUTTONS
	oBtnBar2 := FWButtonBar():new()
	oBtnBar2:Init( oPanel2, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )
	oBtnBar2:addBtnImage( "BMPINCLUIR.PNG",	STR0003, 			{|| actButtons( 3, oPanel2, oGetSED, oTreeNat, oPanel1 ) }, { || !INCLUI .AND. !ALTERA .AND. !EXCLUI }, .T., CONTROL_ALIGN_LEFT) //"Incluir"
	oBtnBar2:addBtnImage( "NOTE.PNG",			STR0004, 		{|| actButtons( 4, oPanel2, oGetSED, oTreeNat, oPanel1 ) }, { || !INCLUI .AND. !ALTERA .AND. !EXCLUI }, .T., CONTROL_ALIGN_LEFT) //"Alterar"
	oBtnBar2:addBtnImage( "EXCLUIR.PNG",		STR0005, 		{|| actButtons( 5, oPanel2, oGetSED, oTreeNat, oPanel1 ) }, { || !INCLUI .AND. !ALTERA .AND. !EXCLUI }, .T., CONTROL_ALIGN_LEFT) //"Excluir"

	// Posiciona a arvore no cabecalho para mostrar a tela de apresentacao
	oTreeNat:TreeSeek( "ID_PRINCIPAL" )
	PosicionaSED( oTreeNat, oGetSED, oPanel1 )

	ACTIVATE DIALOG oDlg

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddTreeSED
Rotina que inclui na arvore os nos no objeto Xtree

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTree, objeto  , passa o objeto tree para ser adicionado
@param	 cPai , Caracter, passa o codigo do caracter que vai ser buscado
@return	 lRet , Logico  , saber se a natureza foi adicionado na arvore ou nao
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function AddTreeSED( oTree, cPai ) As Logical
Local lRet		As Logical                                                                                               
Local cCodigo	As Character               
Local cCargo	As Object    
Local aArea 	As Array 
Local cPaiItem	As Character
Local nRecSED 	As Numeric
Local bPosiciona 	As codeblock
Local bReg_Memory 	As codeblock
Local bAtlz_Ench 	As codeblock
Local bAction		As codeblock

nRecSED := FinRecnSED( oTree:GetCargo() )

bPosiciona 	:= { ||	If( nRecSED > 0, SED->(dbGoto(nRecSED)), { ||  } ) } 

bReg_Memory := {|cAlias, lGet_Incl | 	lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Incl) }

bAtlz_Ench 	:= { |oGetSED, cAlias, lGet_Incl | 	Eval(bReg_Memory,cAlias,lGet_Incl), ;	
													oGetSED:EnchRefreshAll() }

bAction  	:= 	{|| Eval(bPosiciona), Eval(bAtlz_Ench, oGetSED, "SED") }

lRet		:= .F.              
cCodigo		:= ''                  
cCargo		:= oTree:GetCargo()
aArea		:= GetArea() 
cPaiItem	:= ''

If	aScan( oTree:aNodes, { |x| x[1] == oTree:CurrentNodeID } ) == 0
	cPai := PadR(cPai, TAMSX3("ED_CODIGO")[1])
	DbSelectArea("SED")
	SED->(DbSetOrder(2))
	If(SED->(DbSeek( xFilial() + cPai )))
		While !SED->( Eof() ) .And. SED->( ED_FILIAL + ED_PAI ) == xFilial() + cPai
			cCodigo 	:= AllTrim( SED->ED_CODIGO )
			cPaiItem	:= SED->ED_PAI
			If (SED->ED_TIPO) == '1' .AND. !oTree:TreeSeek( cCodigo )
				If Empty(SED->ED_PAI)
					oTree	:AddTree ( 	cCodigo + ' - ' + SED->ED_DESCRIC,  "FOLDER5","FOLDER6" , AllTrim(SED->ED_CODIGO), bAction )	
					oTree	:EndTree()
		   		Else
					oTree	:AddItem (  cCodigo + ' - ' + SED->ED_DESCRIC ,	AllTrim(SED->ED_CODIGO),  "FOLDER5","FOLDER6",2, bAction )	
				Endif
				lRet := .T. 
			ElseIf (SED->ED_TIPO) == '2' .AND. !oTree:TreeSeek( cCodigo )
				If Empty(SED->ED_PAI)
					oTree	:AddTree ( 	cCodigo + ' - ' + SED->ED_DESCRIC, "BMPVISUAL","BMPVISUAL",	AllTrim(SED->ED_CODIGO), bAction )	
					oTree	:EndTree()
				Else
					oTree	:AddItem ( 	cCodigo + ' - ' + SED->ED_DESCRIC ,	AllTrim(SED->ED_CODIGO), "BMPVISUAL","BMPVISUAL",2, bAction )	
				EndIf
				lRet := .T.
			EndIf

			SED->(DbSkip())
		EndDo
	EndIf
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosicionaSED
Rotina que efetua o posicionamento na tabela SED

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTree	 , objeto  , passa o objeto tree para ser adicionado
@param	 oGetSED , objeto  , passa o objeto que ira ser criado a tela
@param	 oArea	 , objeto  , passa o objeto que vai ser criad a area
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function PosicionaSED( oTree, oGetSED, oArea )
Local aArea		As Array
Local cCodigo	As Character

	cCodigo := oTree:GetCargo()

	If ValType( cCodigo ) <> "C"
		cCodigo := ""
	EndIf
	dbSelectArea("SED")     
	SED->(dbSetOrder(1))
	aArea := GetArea()
	If(SED->(dbSeek(xFilial()+cCodigo)))
		If SED->ED_TIPO == '1'
			AddTreeSED(oTree, Alltrim(SED->ED_CODIGO))
		Endif
		//ED_TIPO -> 1=Nat.Sintética;2=Nat.Analítica
		If ValType(oArea) == 'O'
			If cCodigo == 'ID_PRINCIPAL'

				oPanel3:FreeChildren()
				@ 20,5 SAY oSay VAR HTMLDEF() OF oPanel3 FONT oPanel2:oFont PIXEL SIZE 350, 550 HTML 	
				oBtnBar2:oPanel:Hide()

			Else

				oPanel3:FreeChildren()
				oBtnBar2:oPanel:Show()
				// Painel 2 - Enchoice
				oGetSED				:= MsMGet():New( "SED", SED->( RecNo() ), 2,,,,, { 0, 0, 290, 252 },, 4,,,, oPanel3 )
				oGetSED:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
				If ValType( oGetSED ) =='O' .and. cCodigo <> 'ID_PRINCIPAL'

					oGetSED:EnchRefreshAll()

				EndIf
			EndIf
		EndIf
	EndIf
Return 

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RefreshTreeSED
Atualiza a arvore

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTree	 , objeto	, passa o objeto tree para ser adicionado
@param	 oPanel1 , objeto	, passa o objeto que ira de Painel da tela
@param	 oGetSED , objeto	, passa o objeto que ira da tela
@param	 cPosic	 , caracter , passa o caracter do posicionamento original da Tree
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function RefreshTreeSED( oTree, oPanel1, oGetSED, cPosic )
Local aArea		As Array
Local cCodigo	As Character
Local cPaiItem	As Character
Local cPai		As Character

Local nRecSED 	As Numeric
Local bPosiciona 	As codeblock
Local bReg_Memory 	As codeblock
Local bAtlz_Ench 	As codeblock
Local bAction		As codeblock

nRecSED := FinRecnSED( oTree:GetCargo() )

bPosiciona 	:= { ||	If( nRecSED > 0, SED->(dbGoto(nRecSED)), { ||  } ) } 

bReg_Memory := {|cAlias, lGet_Incl | 	lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Incl) }

bAtlz_Ench 	:= { |oGetSED, cAlias, lGet_Incl | 	Eval(bReg_Memory,cAlias,lGet_Incl), ;	
													oGetSED:EnchRefreshAll() }

bAction  	:= 	{|| Eval(bPosiciona), Eval(bAtlz_Ench, oGetSED, "SED") }

aArea		:= GetArea()
cCodigo		:= ""
cPaiItem	:= ""
cPai		:= CriaVar( "ED_CODIGO" )

// Item a ser posicionado apos atualizacao
Default cPosic	:= "ID_PRINCIPAL"

	If oTree:GetCargo() <> "ID_PRINCIPAL"
		// Limpa a arvore
		oTree:BeginUpdate()
		oTree:Reset()
		oTree:EndUpdate()

		// Cria novamente 
		oTree:Hide()
		oTree:BeginUpdate()

		oTree:TreeSeek( "" )
		oTree:AddItem( STR0002, "ID_PRINCIPAL", "FOLDER5","FOLDER6", 1 )
		If	aScan( oTree:aNodes, { |x| x[1] == oTree:CurrentNodeID } ) == 0
			cPai := PadR( cPai, TamSX3( "ED_CODIGO" )[1] )
			DbSelectArea( "SED" )
			SED->( DbSetOrder( 2 ) )
			If SED->( DbSeek( xFilial( "SED" ) + cPai ) )
				While !SED->( Eof() ) .And. ( SED->( ED_FILIAL + ED_PAI ) == xFilial( "SED" ) + cPai )
					cCodigo 	:= AllTrim( SED->ED_CODIGO )
					cPaiItem	:= SED->ED_PAI
					If Empty( cPaiItem )

						cPaiItem := "ID_PRINCIPAL"

					EndIf
					If (SED->ED_TIPO) == '1'
						
						oTree:TreeSeek( "ID_PRINCIPAL" )
						oTree	:AddItem (  cCodigo + ' - ' + SED->ED_DESCRIC ,	AllTrim(SED->ED_CODIGO),  "FOLDER5","FOLDER6", 2, bAction  )

					ElseIf (SED->ED_TIPO) == '2'
							
						oTree:TreeSeek( cPaiItem )
						oTree	:AddItem ( 	cCodigo + ' - ' + SED->ED_DESCRIC ,	AllTrim(SED->ED_CODIGO), "BMPVISUAL","BMPVISUAL",2, bAction )

					EndIf
					SED->( DbSkip() )
				End
			EndIf
		Endif      
		oTree:EndUpdate()
		oTree:Show()

		// Posiciona na arvore o item que sofreu alteracao ou simplesmente no cabecalho
		oTreeNat:TreeSeek( cPosic )
		PosicionaSED( oTreeNat, oGetSED, oPanel1 )
	EndIf

	RestArea(aArea)
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqTree
Efetua a pesquisa de um codigo na arvore e chama função de posicionamento da arvore

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTree	 , objeto	, passa o objeto tree para ser adicionado
@param	 oGetSED , objeto	, passa o objeto que ira da tela
@param	 oArea	 , objeto	, passa o objeto da area original da Tree
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function PesqTree( oTree, oGetSED, oArea )
Local cCodAtu	As Character
Local nPesq		As Numeric

	cCodAtu := SED->ED_CODIGO

	DbSelectArea( "SED" )
	nPesq := AxPesqui()
	If cCodAtu <> SED->ED_CODIGO
		
		PosicTree( oTree, oGetSED, oArea )

	Endif	

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosicTree
Efetua a pesquisa de um codigo na arvore e efetua o  posicionamento da arvore

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTree	 , objeto	, passa o objeto tree para ser adicionado
@param	 oGetSED , objeto	, passa o objeto que ira da tela
@param	 oArea	 , objeto	, passa o objeto da area original da Tree
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function PosicTree( oTree, oGetSED, oArea )
Local aPais		As Array
Local lAchou	As Logical
Local cCodPesq	As Character
Local cCargo	As Character
Local nX		As Numeric

	aPais		:= {}
	lAchou		:= .F.
	cCodPesq	:= SED->ED_CODIGO
	cCargo		:= SED->ED_CODIGO
	nX			:= 0

	While !lAchou
		lAchou	:=	oTree:TreeSeek(Alltrim(cCargo))
		If !lAchou
		
			cCargo	:=	SED->ED_PAI
			AAdd(aPais,cCargo)
			SED->(DbSeek(xFilial("SED")+SED->ED_PAI))

		Endif
		If AllTrim(SED->ED_PAI) == ''
			
			lAchou := .T.
		EndIf
	Enddo
	For nX:= Len(aPais) TO 1 STEP -1
		If !oTree:TreeSeek(Alltrim(aPais[nX]))	
			AddTreeSED(oTree, Alltrim(aPais[nX]))	
		EndIf
		
		oTree:TreeSeek(Alltrim(aPais[nX]))	
	Next
	SED->(DbSeek(xFilial("SED")+cCodPesq))
	oTree:TreeSeek(Alltrim(SED->ED_CODIGO))	
	PosicionaSED( oTree, oGetSED, oArea )

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} acButton
Ação dos Botões para enchoice

@author  jose.aribeiro
@since   19/05/2017
@param 	 nOpc	 , numerico	, numero de opção escolhida(inclusão,alteração ou exclusão)
@param 	 oPanel2 , objeto 	, Objeto Painel, onde encontra se o MsmGet
@param	 oGetSED , objeto	, passa o objeto que ira da tela
@param 	 oTree	 , objeto	, passa o objeto tree para ser adicionado
@param	 oPanel1 , objeto	, Objeto Painel, onde se encontra o xTree
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function actButtons( nOpc, oPanel2, oGetSED, oTree, oPanel1 )
Local cOldPai	As Character
Local cNaturez	As Character
Local nOk		As Numeric
Local cCodItem	As Character
Local cDescItem	As Character
Local cTipoItem As Character

Local nRecSED 	As Numeric
Local bPosiciona 	As codeblock
Local bReg_Memory 	As codeblock
Local bAtlz_Ench 	As codeblock
Local bAction		As codeblock

nRecSED := FinRecnSED( oTree:GetCargo() )

bPosiciona 	:= { ||	If( nRecSED > 0, SED->(dbGoto(nRecSED)), { ||  } ) } 

bReg_Memory := {|cAlias, lGet_Incl | 	lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Incl) }

bAtlz_Ench 	:= { |oGetSED, cAlias, lGet_Incl | 	Eval(bReg_Memory,cAlias,lGet_Incl), ;	
													oGetSED:EnchRefreshAll() }

bAction  	:= 	{|| Eval(bPosiciona), Eval(bAtlz_Ench, oGetSED, "SED") }

cOldPai		:= ""
cNaturez	:= ""
nOk			:= 0
cCodItem	:= ""
cDescItem	:= ""  
cTipoItem	:= ""

If nOpc == 3
	INCLUI := .T.
	nOk := FwExecView('Inclusão de Naturezas','FINA010',MODEL_OPERATION_INSERT,,, {|| .T.})
	If nOk == 0
		If Empty( SED->ED_PAI )
			oTree:TreeSeek( "ID_PRINCIPAL" )
			If SED->ED_TIPO == "1"
				oTree:AddItem( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( SED->ED_CODIGO ), "FOLDER5","FOLDER6", 2, bAction,/*bRClick*/,/*bDblClick*/ )
			Else
				oTree:AddItem( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( SED->ED_CODIGO ), "BMPVISUAL","BMPVISUAL", 2, bAction,/*bRClick*/,/*bDblClick*/ )
			EndIf
		Else
			oTree:TreeSeek( AllTrim( SED->ED_PAI ) )
			oTree:AddItem( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( SED->ED_CODIGO ), "BMPVISUAL","BMPVISUAL", 2, bAction,/*bRClick*/,/*bDblClick*/ )
		EndIf
	EndIf
ElseIf nOpc == 4
	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial('SED')+oTree:GetCargo()))
	nOk			:= FwExecView('Alteracao de Naturezas','FINA010',MODEL_OPERATION_UPDATE,,, {|| .T.})
	If nOk == 0 .AND. Alltrim(SED->ED_PAI) <> cOldPai
		cCodItem	:= AllTrim( SED->ED_CODIGO )
		cDescItem	:= SED->ED_DESCRIC
		cTipoItem	:= SED->ED_TIPO

		oTree:TreeSeek( oTree:GetCargo() )
		oTree:DelItem()

		If Empty( SED->ED_PAI )
			oTree:TreeSeek( "ID_PRINCIPAL" )
			If cTipoItem == "1"
				oTree:AddItem( cCodItem + ' - ' + cDescItem, cCodItem, "FOLDER5","FOLDER6", 2, bAction,/*bRClick*/,/*bDblClick*/ )
			Else
				oTree:AddItem( cCodItem + ' - ' + cDescItem, cCodItem, "BMPVISUAL","BMPVISUAL", 2, bAction,/*bRClick*/,/*bDblClick*/ )
			EndIf
			oTree:TreeSeek( cCodItem )
			PosicionaSED( oTree, oGetSED, oPanel1 )				
		Else
			oTree:TreeSeek( AllTrim( SED->ED_PAI ) )
			If !oTree:TreeSeek( cCodItem )
				If cTipoItem == "1"
					oTree:AddItem( cCodItem + ' - ' + cDescItem, cCodItem, "FOLDER5","FOLDER6", 2, bAction,/*bRClick*/,/*bDblClick*/ )
				Else
					oTree:AddItem( cCodItem + ' - ' + cDescItem, cCodItem, "BMPVISUAL","BMPVISUAL", 2, bAction,/*bRClick*/,/*bDblClick*/ )
				EndIf
				oTree:TreeSeek( cCodItem )
			EndIf
			PosicionaSED( oTree, oGetSED, oPanel1 )
		EndIf
	Else
		If nOk == 1
			// Atualiza a descricao do item na arvore
			oTree:ChangePrompt( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( cNaturez ) )
		EndIf
	EndIf
ElseIf nOpc == 5
	EXCLUI := .T.
	FAExcNat( "SED", oTree, oPanel2 )
EndIf

INCLUI := .F.
ALTERA := .F.
EXCLUI := .F.
	
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NatCopiar
Armazena o codigo da natureza que deverá ser copiada

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTreeNat , objeto	, Objeto oTree da Natureza
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function NatCopiar( oTreeNat )
	If oTreeNat:GetCargo() <> "ID_PRINCIPAL"
		cCopiaRef := oTreeNat:GetCargo()
	Else
		Aviso( STR0012, STR0017, { STR0018 } ) // "Atencao", "Impossivel copiar esse registro, esta posicionado no cabecalho da arvore.", "Ok"
		cCopiaRef := ""
	EndIf
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NatColar
Faz a gravação da natureza copiada

@author  jose.aribeiro
@since   19/05/2017
@param 	 oTreeNat , objeto	, Objeto oTree da Natureza
@param 	 oPanel2  , objeto	, Objeto Painel, onde se encontra o MsmGet
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function NatColar( oTreeNat, oPanel2 )
Local aCampoSED	As Array
Local nCount	As Numeric
Local nTamField	As Numeric
Local nRecNo	As Numeric
Local cCargo	As Character
Local cPai		As Character
Local cTipo		As Character
Local oModel	As Object
Local oModelSED	As Object
Local cLog		As Character
Local aArea		As Array
Local nX		As Numeric
Local aAux		As Array
Local cAux		As Character
Local lParamJur	As Logical

	aCampoSED	:= {}
	nCount		:= 0
	nTamField	:= TamSX3( "ED_CODIGO" )[1]
	nRecNo		:= 0
	cCargo		:= oTreeNat:GetCargo()
	cPai		:= ""
	cTipo		:= ""
	oModel		:= FwLoadModel("FINA010")
	oModelSED	:= oModel:GetModel("SEDMASTER")
	cLog		:= ""
	aArea		:= SED->( GetArea() )
	nX			:= 0
	aAux		:= {}
	cAux		:= ""
	lParamJur	:= GetMv("MV_JURXFIN",,.F.) 

	If Empty( cCopiaRef )
		Aviso( STR0012, STR0019, { STR0018 } )
		Return
	EndIf
	DbSelectArea( "SED" )
	SED->( DbSetOrder( 1 ) )
	If SED->( DbSeek( xFilial( "SED" ) + cCargo ) )
		cPai 	:= SED->ED_PAI
		cTipo	:= SED->ED_TIPO
		nRecNo	:= SED->( RecNo() )
	EndIf
	If ParamBox( { { 1, STR0020, Space( nTamField ), "@!", "", "", "", 60, .T. } }, STR0007,, )
		If SED->( DbSeek( xFilial( "SED" ) + MV_PAR01 ) )
			Alert( STR0021 ) // "O código da natureza já existe! Informe um novo código."
			Return
		EndIf
		//Armazena a composicao aux   em array para posteriormente
		//duplicar alterando o codigo informado na ParamBox
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		aAux := SED->(DbStruct())
		For nX:= 1 to Len(aAux)
			
			If(aAux[nX][1] == "ED_FILIAL")

				oModelSED:SetValue(aAux[nX][1],xFilial("SED"))

			ElseIf(aAux[nX][1] == "ED_CODIGO")

				oModelSED:SetValue(aAux[nX][1],MV_PAR01)
			
			ElseIf(aAux[nX][1] == "ED_DTINCLU")

				oModelSED:SetValue(aAux[nX][1],dDataBase)
			
			ElseIf(aAux[nX][1] == "ED_IRRFCAR"  )

				cAux:= Alltrim(SED->&(aAux[nX][1]))
				If(!Empty(cAux) .And. SED->ED_CALCIRF == 'S')
				
					oModelSED:SetValue(aAux[nX][1],cAux)

				EndIf

			ElseIf(aAux[nX][1] == "ED_BASEIRC"  )

				cAux:= Alltrim(SED->&(aAux[nX][1]))
				If(!Empty(cAux).And. SED->ED_IRRFCAR == 'S')
				
					oModelSED:SetValue(aAux[nX][1],cAux)

				EndIf
			
			ElseIf(aAux[nX][1] == "ED_INSSCAR"  )

				cAux:= Alltrim(SED->&(aAux[nX][1]))
				If(!Empty(cAux) .And. SED->ED_CALCINS == 'S')
				
					oModelSED:SetValue(aAux[nX][1],cAux)

				EndIf
	
			ElseIf(AllTrim(aAux[nX][1]) $ "ED_GRPNAT|ED_RATOBR|ED_ESCRIT|ED_GRPJUR|ED_BANCJUR|ED_CRJUR|ED_CPJUR|ED_TPCOJR|ED_CFJUR")	
				
				If(lParamJur)

					oModelSED:SetValue(aAux[nX][1],cAux)

				EndIf
			//Pulando os campos que não existem no modelo. Não usados.
			ElseIf(oModelSED:HasField(aAux[nX][1]))
				
				cAux:= SED->&(aAux[nX][1])
				
				If(!Empty(cAux))
				
					oModelSED:SetValue(aAux[nX][1],cAux)

				EndIf

			EndIf
		Next
		If(oModel:VldData())
			oModel:CommitData()	
			SED->( DbGoTo( nRecNo ) )
			DbSelectArea( "SED" )
			SED->( DbSetOrder( 1 ) )
			If SED->( DbSeek( xFilial( "SED" ) + MV_PAR01 ) )
				If Empty( SED->ED_PAI )
					oTreeNat:TreeSeek( "ID_PRINCIPAL" )
					If SED->ED_TIPO == "1"

						oTreeNat:AddItem( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( SED->ED_CODIGO ), "FOLDER5","FOLDER6", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )

					Else
							
						oTreeNat:AddItem( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( SED->ED_CODIGO ), "BMPVISUAL","BMPVISUAL", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )

					EndIf
				Else
						
					oTreeNat:TreeSeek( AllTrim( SED->ED_PAI ) )
					oTreeNat:AddItem( AllTrim( SED->ED_CODIGO ) + ' - ' + SED->ED_DESCRIC, AllTrim( SED->ED_CODIGO ), "BMPVISUAL","BMPVISUAL", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )

				EndIf
			EndIf
				oTreeNat:TreeSeek( cCargo )
				PosicionaSED( oTreeNat, oGetSED, oPanel1 )
		Else

			cLog := cValToChar(oModel:GetErrorMessage()[4]) + " - "
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + " - "
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			HELP(' ',1,"FINA010NNATCOL" ,,cLog,2,0,,,,,,)
			PosicionaSED( oTreeNat, oGetSED, oPanel1 )
		EndIf
	EndIf
	RestArea( aArea )
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAExcNat()
Função para exclusão da Natureza

@author  jose.aribeiro
@since   19/05/2017
@param 	 cAlias	  , Caracter , Alias do Arquivo
@param 	 oTreeNat , objeto	 , Objeto oTree da Natureza
@param 	 oPanel   , objeto	 , Objeto Painel, onde se encontra o MsmGet
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function FAExcNat(cAlias,oTree,oPanel)
Local aDeleta	As Array
Local nX		As Numeric
Local lCancelOK As Logical
Local oModel 	As Object
Local nCampos	As Numeric
Local cPai 		As Character
Local oObjDef	As Object
Local cLog    As Character

	cLog := ""
	aDeleta		:= {}
	nX			:= 0
	lCancelOK	:= .F.
	oModel		:= FwLoadModel("FINA010")
	nCampos		:= 0
	cPai		:= SED->ED_PAI

	oObjDef := FINA010EVDEF():New()

	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial('SED')+oTree:GetCargo()))
	aDeleta := oObjDef:CheckDel()
	oModel:SetOperation(MODEL_OPERATION_DELETE)

	//lCancelOk := FWFormCommit(oModel)
	oModel:Activate()
	If oModel:VldData()
		oModel:CommitData()
		lCancelOk := .T.
	Else
		lCancelOk := .F.
		cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[6])        	
		Help( ,,"FA010NAT",,cLog, 1, 0 )
	Endif

	If lCancelOK
		oTree :TreeSeek(aDeleta[2,Len(aDeleta[2])])
		oTree :DelItem()						
	EndIf
	//Final da protecao via TTS
	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil	
	oTree :TreeSeek(cPai)
	(cAlias)->(dbSetOrder(1))
	dbSelectArea(cAlias)

Return 

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HTMLDEF()
Função para retornar o texto de apresentação da rotina

@author  jose.aribeiro
@since   19/05/2017
@return	 cRet	, Caracter , Texto em HTML da exibição
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function HTMLDEF() As Character
Local cRet	As Character

	cRet	:= ""

	cREt	:=	"<H1>" + STR0026 + "</H1>"
	cREt	+=	"<br>         "
	cREt	+=	"<FONT size=+1>"
	cREt	+=	STR0027 + "<br> "
	cREt	+=	STR0028 + "<br> "
	cREt	+=	STR0029 + "<br> "
	cREt	+=	STR0030
	cREt	+=	"</FONT>"

Return cRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinRecnSED
Função para retornar Recno do registro da natureza posicinada na árvore da estrutura

@author  rogerio.melonio
@since   04/12/2017
@return	 nRet, numérico, recno do registro
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function FinRecnSED(cIdEntid)
Local nRet := 0    
DbSelectArea("SED")
DbSetOrder(1)
If DbSeek( xFilial("SED")+ cIdEntid )
	nRet := SED->(Recno())
EndIf

Return(nRet)
