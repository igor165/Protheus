#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA645.CH'

Static __aSelFil		:= {}
Static __cSitCob		:= ''
Static __aDadosCli		:= {}
Static __cTmpSA1	  	:= ""
Static __cTmpSE1	  	:= ""
Static __F645PERG 		:= ExistBlock("F645PERG")
Static __F645CLIF	  	:= ExistBlock("F645CLIF")
Static __F645TITF	  	:= ExistBlock("F645TITF")
Static __F645SITP 	 	:= ExistBlock("F645SITP")
Static __lF645JZ		:= ExistBlock("F645LDFJ") //PE para
Static __lF645WZ		:= ExistBlock("F645LDFW") //PE para
Static __F645ALTS	  	:= ExistBlock("F645ALTS")
Static __lRefresh		:= .T.
Static __lAltSit		:= .F.
static __lPLSFN645       := findFunction("PLSFN645")
Static __lBAIXPDD		:= SuperGetMV("MV_BAIXPDD", .F., .F. )	

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA645
Rotina de Provisão de PDD
Montagem da modelo e interface

@author Thiago Murakami
@since 19/03/2015
@version 12
/*/
//--------------------------------------------------------------------
Function FINA645(lAuto, nOpc, aSitCob, cNroProc, aDdsAlt)

Local oBrowse
Local cPrograma	:= "FINA645"

Local cCompFFJX	:= FWModeAccess("FJX",3)
Local cCompUFJX	:= FWModeAccess("FJX",2)
Local cCompEFJX	:= FWModeAccess("FJX",1)

Local cCompFFJY	:= FWModeAccess("FJY",3)
Local cCompUFJY	:= FWModeAccess("FJY",2)
Local cCompEFJY	:= FWModeAccess("FJY",1)

Local cCompFFJZ	:= FWModeAccess("FJZ",3)
Local cCompUFJZ	:= FWModeAccess("FJZ",2)
Local cCompEFJZ	:= FWModeAccess("FJZ",1)

Local cCompFFWZ	:= FWModeAccess("FWZ",3)
Local cCompUFWZ	:= FWModeAccess("FWZ",2)
Local cCompEFWZ	:= FWModeAccess("FWZ",1)

Private aAuxEvalX	:= {}
Private aAuxEvalY 	:= {}
Private aAuxEvalZ 	:= {}
Private aAuxEvalW 	:= {}
Private nPosPerc 	:= 0
Private nPosVlr 	:= 0
Private nPosSld 	:= 0
Private nPosBaix 	:= 0
Private cSitPai 	:= ""
Private nTotalRat	:= 0
Private lAutomato	:= .F.

Default lAuto		:= .F.
Default nOpc		:= 0
Default aSitCob		:= {}
Default cNroProc	:= ""
Default aDdsAlt		:= {}

lAutomato 			:= lAuto

If !( TableIndic("FJX") .and. TableIndic("FJY") .and. TableIndic("FJZ") .and. TableIndic("FWZ") )
	HELP(" ",1,STR0070 ,, STR0071 ,2,0,,,,,,{ STR0072 }) // "FINA645 - ROTINA DE PDD (PREVISÃO DEVEDORES DUVIDOSOS)" # "Dicionário Desatualizado" # "Migrar para Protheus versão 12.1.25"
	Return .F.
Endif

If cCompFFJX != "C" .Or. cCompUFJX != "C" .Or. cCompEFJX != "C"
	HELP(" ",1,"FA645CompFJX",, STR0077 ,1,0) // "O compartilhamento da(s) tabela(s) de PDD não estão condizentes com as necessidades do sistema. Favor verificar."
	Return .F.
Endif

If cCompFFJY != "C" .Or. cCompUFJY  != "C" .Or. cCompEFJY != "C"
	HELP(" ",1,"FA645CompFJY",, STR0077 ,1,0) // "O compartilhamento da(s) tabela(s) de PDD não estão condizentes com as necessidades do sistema. Favor verificar."
	Return .F.
Endif

If cCompFFJZ != "C" .Or. cCompUFJZ != "C" .Or. cCompEFJZ != "C"
	HELP(" ",1,"FA645CompFJZ",, STR0077 ,1,0) // "O compartilhamento da(s) tabela(s) de PDD não estão condizentes com as necessidades do sistema. Favor verificar."
	Return .F.
Endif

If cCompFFWZ != "C" .Or. cCompUFWZ != "C" .Or. cCompEFWZ != "C"
	HELP(" ",1,"FA645CompFWZ",, STR0077 ,1,0) // "O compartilhamento da(s) tabela(s) de PDD não estão condizentes com as necessidades do sistema. Favor verificar."
	Return .F.
Endif

If !lAutomato .And. nOpc = 0
	//F12 - Ativa grupo de perguntas.
	SetKey( VK_F12, { || Pergunte("FINA645C",.T.) } )
	//Considera data Real?
	//Movimentos dos títulos maior que a data real HELP
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FJX' )
	oBrowse:SetDescription( STR0051 )//"Controle da Provisão para Devedores Duvidosos (PDD)"                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	oBrowse:AddLegend( "FJX_TIPO == '1' .And. FJX_STATUS == '1' ", "YELLOW"	, STR0047	) //"Constituição de PDD - Simulado"
	oBrowse:AddLegend( "FJX_TIPO == '1' .And. FJX_STATUS == '2' ", "GREEN"	, STR0048	) //"Constituição de PDD - Efetivado"
	oBrowse:AddLegend( "FJX_TIPO == '2' .And. FJX_STATUS == '1' ", "WHITE"	, STR0049	) //"Reversão de PDD - Simulado"
	oBrowse:AddLegend( "FJX_TIPO == '2' .And. FJX_STATUS == '2' ", "RED"	, STR0050	) //"Reversão de PDD - Efetivado"
	
	oBrowse:Activate()
	
	CtbTmpErase(__cTmpSE1)
	CtbTmpErase(__cTmpSA1)
Else
	If nOpc == 3 //Constituição
		FA645Simu(aSitCob)
	ElseIf nOpc == 4
		FA645Efe(,,,cNroProc)
	ElseIf nOpc == 5
		FA645Rev(,,,cNroProc)
	Elseif nOpc == 6
		FA645EfRev(,,,cNroProc)
	Elseif nOpc == 7
		FA645Alt(,,,cNroProc,aDdsAlt)
	ElseIf nOpc == 8
		DbSelectArea("FJX")
		FJX->(DbSetOrder(1))
		FJX->(DbGoTop())

		If !FJX->(DbSeek(xFilial("FJX") + cNroProc)) 
			HELP(" ",1,"FA645EfeExec",, STR0073 ,1,0) //"Processo não encontrado em base de dados."
			Return
		Endif
		FA645AUTO(cPrograma, 5)
	Endif
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição de Menu da Rotina de Provisão de PDD

@author Thiago Murakami
@since 19/03/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0008	Action 'PesqBrw'        	OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title STR0009	Action 'VIEWDEF.FINA645'	OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0010	Action 'FA645Simu()'    	OPERATION 3 ACCESS 0 //Constituição
ADD OPTION aRotina Title STR0011	Action 'FA645Efe()' 		OPERATION 4 ACCESS 0 //"Efetivação"
ADD OPTION aRotina Title STR0012	Action 'FA645Alt()'			OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title STR0013	Action 'FA645Rev()'			OPERATION 3 ACCESS 0 //Reversão
ADD OPTION aRotina Title STR0052	Action 'FA645EfRev()'		OPERATION 4 ACCESS 0 //Efetivação da Reversão
ADD OPTION aRotina Title STR0014	Action 'VIEWDEF.FINA645'	OPERATION 5 ACCESS 0 //Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo de Dados da rotina de Provisão de PDD

@author Thiago Murakami
@since 19/03/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruFJX 		:= FWFormStruct( 1, 'FJX', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFJY 		:= FWFormStruct( 1, 'FJY', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFJZ 		:= FWFormStruct( 1, 'FJZ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFWZ 		:= FWFormStruct( 1, 'FWZ', /*bAvalCampo*/, /*lViewUsado*/ )
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local oModel
Local bTudoOk		:= IIf(lConstituicao , { |oModel| FA645TOK( oModel ) },Nil)
Local bFJZVld		:= { |oModel, nLine, cAction, cField, xValue, xOldValue| FJZLinPre( oModel, nLine, cAction, cField, xValue, xOldValue ) }
Local lMostraRat	:= .T.

If lConstituicao
	Pergunte("FINA645C",.F.)
	lMostraRat	:= SUPERGETMV('MV_PDDRTNF',.F.,2)== 1 //MV_PAR13 == 1
ElseIf lReversao
	Pergunte("FINA645E",.F.)
EndIf

oStruFJZ:AddTrigger( "FJZ_OK" , "FJZ_OK", { || .T. }, { |oModel| F645TrigOK(oModel) } )

oModel := MPFormModel():New( 'FINA645' , /*bPreValidacao*/, /*bPosValidacao*/bTudoOk, { |oModel| FA645GRV( oModel ) } , /*bCancel*/{ || FA645CANC(  ) }  )

oStruFJZ:AddField( ;
                        AllTrim('') , ;  		// [01] C Titulo do campo
                        AllTrim('Legenda') , ;  // [02] C ToolTip do campo
                        'FJZ_LEGEND', ;         // [03] C identificador (ID) do Field
                        'C' , ;             	// [04] C Tipo do campo
                        50  , ;             	// [05] N Tamanho do campo
                        0   , ;             	// [06] N Decimal do campo
                        NIL , ;             	// [07] B Code-block de validação do campo
                        NIL , ;             	// [08] B Code-block de validação When do campo
                        NIL , ;             	// [09] A Lista de valores permitido do campo
                        NIL , ;             	// [10] L Indica se o campo tem preenchimento obrigatório
                        { | | F645LEGUPD(oModel) } , ; 	// [11] B Code-block de inicializacao do campo
                        NIL , ;             	// [12] L Indica se trata de um campo chave
                        NIL , ;             	// [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )               	// [14] L Indica se o campo é virtual

oStruFJY:AddTrigger( "FJY_OK" 		, "FJY_OK", {|| .T. }, {|| FA645Mark(oModel) } )
oStruFJY:AddTrigger( "FJY_SITPDD"	, "FJY_SITPDD", {|| .T. }, {|| FA645SitGat(oModel) } )

oStruFJZ:AddTrigger( "FJZ_OK" , "FJZ_OK", { || .T. }, { |      | FA645Check(oModel) } )

oModel:AddFields( 'FJXMASTER', /*cOwner*/, oStruFJX ,/*bPreVld*/, /*bPost*/ ,If(lConstituicao .Or. lReversao, { || FA645LoadX(oModel)},Nil)) 
oModel:AddGrid( 'FJYDETAIL', 'FJXMASTER', oStruFJY, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,If(lConstituicao .Or. lReversao, { |oModel| FA645LoadY(oModel)},Nil))
oModel:AddGrid( 'FJZDETAIL', 'FJYDETAIL', oStruFJZ, bFJZVld, /*bLinePost*/,  /*bPreVal*/, /*bPosVal*/,If(lConstituicao .Or. lReversao, { |oModel| FA645LoadZ(oModel)},Nil))

If lMostraRat
	oModel:AddGrid( 'FWZDETAIL', 'FJZDETAIL', oStruFWZ, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,If(lConstituicao .Or. lReversao, { |oModel| FA645LoadW(oModel)},Nil))
Endif

oModel:SetRelation( 'FJYDETAIL', { { 'FJY_FILIAL', 'xFilial( "FJY" )' }, { 'FJY_PROC' , 'FJX_PROC'  } }, FJY->(IndexKey(1)) )
oModel:SetRelation( 'FJZDETAIL', { { 'FJZ_FILIAL', 'xFilial( "FJZ" )' }, { 'FJZ_PROC' , 'FJX_PROC'  }, { 'FJZ_ITCLI', 'FJY_ITEM' } }, FJZ->(IndexKey(1)) )
If lMostraRat
	oModel:SetRelation( 'FWZDETAIL', { { 'FWZ_FILIAL', 'xFilial( "FWZ" )' }, { 'FWZ_PROC' , 'FJX_PROC'  }, { 'FWZ_ITCLI', 'FJY_ITEM' } , { 'FWZ_ITTIT', 'FJZ_ITEM' } }, FWZ->(IndexKey(1)) )
EndIf
oModel:GetModel('FJYDETAIL'):SetMaxLine(9990)
oModel:GetModel('FJZDETAIL'):SetMaxLine(9990)
If lMostraRat
	oModel:GetModel('FWZDETAIL'):SetMaxLine(9990)
endif
oModel:SetDescription( STR0015 ) //Transferência PDD\PPSC

oModel:GetModel( 'FJXMASTER' ):SetDescription( STR0024  )//'Provisão'
oModel:GetModel( 'FJYDETAIL' ):SetDescription( STR0025	)//'Clientes' 
oModel:GetModel( 'FJZDETAIL' ):SetDescription( STR0026  )//'Títulos'
If lMostraRat
	oModel:GetModel( 'FWZDETAIL' ):SetDescription( STR0027  )//'Item Nota'
	oModel:GetModel( 'FWZDETAIL' ):SetOptional( .T. )
EndIf

oModel:SetVldActivate( { |oModel| FA645PreVl(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da Interface da Rotina de Provisão do PDD

@author Thiago.Murakami
@since 19/03/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruFJX 		:= FWFormStruct( 2, 'FJX' )
Local oStruFJY 		:= FWFormStruct( 2, 'FJY' )
Local oStruFJZ 		:= FWFormStruct( 2, 'FJZ' )
Local oStruFWZ 		:= FWFormStruct( 2, 'FWZ' )
Local oModel   		:= FWLoadModel( 'FINA645' )
Local lEfetiva 		:= FwIsInCallStack("FA645Efe")
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local lEfeRev		:= FwIsInCallStack("FA645EfRev")
Local oView
Local lMostraRat	:= .T.

If lConstituicao
	Pergunte("FINA645C",.F.)
	lMostraRat	:= SUPERGETMV('MV_PDDRTNF',.F.,2)== 1 //MV_PAR13 == 1
ElseIf lReversao
	Pergunte("FINA645E",.F.)
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )

oStruFJZ:AddField(        ;	// Ord. Tipo Desc.
	'FJZ_LEGEND'        , ; // [01]  C   Nome do Campo
	"01"                , ; // [02]  C   Ordem
	AllTrim( '' ), ; 	// [03]  C   Titulo do campo
	AllTrim( '' ), ; 	// [04]  C   Descricao do campo
	{ 'Legenda' } 	    , ; // [05]  A   Array com Help
	'C'                 , ; // [06]  C   Tipo do campo
	'@BMP'              , ; // [07]  C   Picture
	NIL                 , ; // [08]  B   Bloco de Picture Var
	''                  , ; // [09]  C   Consulta F3
	.T.                 , ; // [10]  L   Indica se o campo é alteravel
	NIL                 , ; // [11]  C   Pasta do campo
	NIL                 , ; // [12]  C   Agrupamento do campo
	NIL				    , ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                 , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                 , ; // [15]  C   Inicializador de Browse
	.T.                 , ; // [16]  L   Indica se o campo é virtual
	NIL                 , ; // [17]  C   Picture Variavel
	NIL                   ) // [18]  L   Indica pulo de linha após o campo

oStruFJX:SetProperty( '*' , MVC_VIEW_CANCHANGE ,.F.)
oStruFJY:SetProperty( '*' , MVC_VIEW_CANCHANGE ,.F.)

oStruFJZ:SetProperty( '*' , MVC_VIEW_CANCHANGE ,.F.)
If lMostraRat
	oStruFWZ:SetProperty( '*' , MVC_VIEW_CANCHANGE ,.F.)
Endif 		

If !lEfetiva .And. !lEfeRev
	oStruFJY:SetProperty( 'FJY_OK' 		, MVC_VIEW_CANCHANGE ,.T.)
	oStruFJZ:SetProperty( 'FJZ_OK' 		, MVC_VIEW_CANCHANGE ,.T.)
EndIf

If !lEfetiva .And.  !lEfeRev .And. !lReversao .And. ( FJX->FJX_TIPO == "1" .OR. lConstituicao )
	oStruFJY:SetProperty( 'FJY_SITPDD' , MVC_VIEW_CANCHANGE ,.T.)
	oStruFJZ:SetProperty( 'FJZ_SITPDD' , MVC_VIEW_CANCHANGE ,.T.)
EndIf

oStruFJY:SetProperty( 'FJY_OK' 	   , MVC_VIEW_ORDEM ,"01")
oStruFJY:SetProperty( 'FJY_SITPDD' , MVC_VIEW_ORDEM ,"02")

oStruFJZ:SetProperty( 'FJZ_LEGEND' , MVC_VIEW_ORDEM ,"01")
oStruFJZ:SetProperty( 'FJZ_OK' 	   , MVC_VIEW_ORDEM ,"02")
oStruFJZ:SetProperty( 'FJZ_SITPDD' , MVC_VIEW_ORDEM ,"03")
oStruFJZ:SetProperty( 'FJZ_SITUAC' , MVC_VIEW_ORDEM ,"04")
oStruFJZ:SetProperty( 'FJZ_SITPAI' , MVC_VIEW_ORDEM ,"05")

oStruFJX:RemoveField( 'FJX_STATUS' )
oStruFJY:RemoveField( 'FJY_PROC'   )
oStruFJZ:RemoveField( 'FJZ_PROC'   )
oStruFJZ:RemoveField( 'FJZ_CODREV' )
oStruFJZ:RemoveField( 'FJZ_MOTBX'  ) 
oStruFJZ:RemoveField( 'FJZ_VLRBX'  )
oStruFJZ:RemoveField( 'FJZ_SLDBRT' )
oStruFJZ:RemoveField( 'FJZ_ULTSEQ' )
oStruFJZ:RemoveField( 'FJZ_DTBAIX' )
oStruFJZ:RemoveField( 'FJZ_LA'     )
If lMostraRat
	oStruFWZ:RemoveField( 'FWZ_PROC' 	)
	oStruFWZ:RemoveField( 'FWZ_VLRRAT'	)
	oStruFWZ:RemoveField( 'FWZ_BXRAT' 	)
	oStruFWZ:RemoveField( 'FWZ_LA' 		)
Endif

oView:AddField( 'VIEW_FJX', oStruFJX, 'FJXMASTER' )
oView:AddGrid(  'VIEW_FJY', oStruFJY, 'FJYDETAIL' )
oView:AddGrid(  'VIEW_FJZ', oStruFJZ, 'FJZDETAIL' )

If lMostraRat
	oView:AddGrid(  'VIEW_FWZ', oStruFWZ, 'FWZDETAIL' )
EndIf

oView:CreateHorizontalBox( "SUPERIOR", 20 ) 
oView:CreateHorizontalBox( "MEIO", 40 ) 
oView:CreateHorizontalBox( "INFERIOR", 40 ) 

oView:CreateFolder( 'PASTA_INFERIOR','INFERIOR' 					)
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_TITULO'     , STR0021 	) //"Titulos" 
If lMostraRat
	oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_NOTA'   , STR0022 	) //"Nota Fiscal"
Endif

oView:CreateHorizontalBox( 'TITULO'	,100,,, 'PASTA_INFERIOR', 'ABA_TITULO' )
If lMostraRat
	oView:CreateHorizontalBox( 'NOTA'		,100,,, 'PASTA_INFERIOR', 'ABA_NOTA' )
Endif

oView:SetOwnerView( 'VIEW_FJX', "SUPERIOR"	)
oView:SetOwnerView( 'VIEW_FJY', "MEIO" 		) 
oView:SetOwnerView( 'VIEW_FJZ', "TITULO"		)
If lMostraRat
	oView:SetOwnerView( 'VIEW_FWZ', "NOTA"			)
Endif

oView:AddUserButton( STR0082, '', {|| FA645Lege()   } ) //Definição da legenda
oView:AddUserButton( STR0004, '', {|| FA645Inv("1") } ) //Inverte Seleção Clientes.
oView:AddUserButton( STR0005, '', {|| FA645Inv("2") } ) //Inverte Seleção Títulos.
If !lEfetiva .And. !lEfeRev .And. !lReversao .And. ( FJX->FJX_TIPO == "1" .OR. lConstituicao )
	oView:AddUserButton( STR0061, '', {|| FA645SitPDD("1") } ) //"Situação PDD Clientes."
	oView:AddUserButton( STR0062, '', {|| FA645SitPDD("2") } ) //"Situação PDD Títulos."
	oView:AddUserButton( STR0069, '', {|| FA645Cons() } ) //"Rastro de Títulos."
EndIf

//Bloqueia a inclusão de novas linhas
oView:SetNoInsertLine('VIEW_FJY')
oView:SetNoInsertLine('VIEW_FJZ')

//Não permite apagar linha
oView:SetNoDeleteLine('VIEW_FJY')
oView:SetNoDeleteLine('VIEW_FJZ')

oView:EnableTitleView( 'VIEW_FJX' )
oView:EnableTitleView( 'VIEW_FJY' )
oView:EnableTitleView( 'VIEW_FJZ' )
oView:SetCloseOnOk({||.F.})

//Filtro
oView:SetViewProperty("VIEW_FJY", "GRIDFILTER", {.T.})
oView:SetViewProperty("VIEW_FJZ", "GRIDFILTER", {.T.})
oView:SetViewProperty("VIEW_FJY", "GRIDSEEK", {.T.})
oView:SetViewProperty("VIEW_FJZ", "GRIDSEEK", {.T.})

If lConstituicao .Or. lEfetiva .Or. lReversao .Or. lEfeRev  
	//Tratamento para permitir a confirmação, pois a ordem é de alterção  
	oView:lModify := .T.
	oView:oModel:lModify := .T.
EndIf

If lEfetiva .and. __lAltSit
	oView:SetAfterViewActivate({|| Processa({|| FA645AltZ(oView)},STR0067,,.F.)})	
Endif

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} FA645LoadX
Carrega os dados do cabeçalho

@author Thiago.Murakami
@since 25/03/2015
@version 12
/*/
//-----------------------------------------------------------
Function FA645LoadX(oModel)

Local aDados		:= {}
Local oFJXStruct	:= oModel:GetModelStruct("FJXMASTER")[3]:oFormModelStruct
Local aCposVlr		:= oFJXStruct:GetFields()
Local aFilCpos		:= {}
Local cCodSimul		:= ""
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local cCampo 		:= ""
Local nX			:= 0

If lConstituicao
	Pergunte("FINA645C",.F.)
ElseIf lReversao
	Pergunte("FINA645E",.F.)
EndIf

FJX->(dbSetOrder(1)) //FJX_FILIAL+FJX_PROC
While .T.
	cCodSimul := GetSxENum("FJX", "FJX_PROC")
	If FJX->(!dbSeek(xFilial("FJX") + cCodSimul))
		Exit
	EndIf
EndDo

For nX := 1 To Len(aCposVlr)
	
	cCampo := AllTrim(aCposVlr[nX][3])
	
	If cCampo == "FJX_FILIAL"
		AAdd(aFilCpos,xFilial('FJX'))
	ElseIf cCampo == "FJX_PROC"
		AAdd(aFilCpos,cCodSimul)
	ElseIf cCampo == "FJX_DTPROC"
		AAdd(aFilCpos,dDataBase)
	ElseIf cCampo == "FJX_DTREF"
		AAdd(aFilCpos,IIf(lConstituicao,MV_PAR01,MV_PAR07))
	ElseIf cCampo == "FJX_PARAM"
		AAdd(aFilCpos,IIf(lConstituicao,F645ConSX1('FINA645C'),F645ConSX1('FINA645E')))
	ElseIf cCampo == "FJX_TIPO"
		AAdd(aFilCpos,IIf(lConstituicao,'1','2'))
	ElseIf cCampo == "FJX_STATUS"
		AAdd(aFilCpos,'1')
	ElseIf cCampo == "FJX_VLRPRO"
		AAdd(aFilCpos,0)
	Else
		AAdd(aFilCpos,CriaVar(cCampo))
	EndIf	
	
Next nX

aDados := {aFilCpos,0}

Return aDados

//-----------------------------------------------------------
/*/{Protheus.doc} FA645LoadY
Função que retorna a carga da grid do Cliente

@author Thiago.Murakami
@since 25/03/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645LoadY(oModel)

Local aDados		As Array
Local oFJYStruct	As Object
Local oModelPai		As Object
Local oModelFJX		As Object
Local cProcesso		As Character
Local aCposVlr		As Array
Local aFilCpos		As Array
Local nItem			As Numeric
Local cCampo		As Character
Local nX			As Numeric
Local nY			As Numeric

aDados			:= {}
oFJYStruct		:= oModel:GetStruct()
oModelPai		:= oModel:GetModel()
oModelFJX		:= oModelPai:GetModel("FJXMASTER")
cProcesso		:= oModelFJX:GetValue("FJX_PROC")
aCposVlr		:= {}
aFilCpos		:= {}
nItem			:= 0
cCampo			:= ""
nX				:= 0
nY				:= 0

aCposVlr := oFJYStruct:GetFields()

//Tabela carregada na função FA645PreVl
For nY := 1 To Len(__aDadosCli)
	
	nItem := nItem + 1

	For nX := 1 To Len(aCposVlr)
		
		cCampo := Alltrim(aCposVlr[nX][3])
			
		If cCampo == "FJY_FILIAL"
			AAdd(aFilCpos,xFilial('FJY'))
		ElseIf cCampo == "FJY_OK"
			AAdd(aFilCpos,.T.)
		ElseIf cCampo == "FJY_CLIENT"
			AAdd(aFilCpos, __aDadosCli[nY, 1])
		ElseIf cCampo == "FJY_LOJA"
			AAdd(aFilCpos, __aDadosCli[nY, 2])
		ElseIf cCampo == "FJY_PROC"
			AAdd(aFilCpos,cProcesso)
		ElseIf cCampo == "FJY_ITEM"
			AAdd(aFilCpos,STRZERO(nItem,TamSX3('FJY_ITEM')[1]))
		ElseIf cCampo == "FJY_FILCLI"
			AAdd(aFilCpos, xFilial("SA1"))
		ElseIf cCampo == "FJY_NOME"
			AAdd(aFilCpos, Posicione("SA1", 1, xFilial("SA1") + __aDadosCli[nY, 1] + __aDadosCli[nY, 2], "A1_NOME" ))
		ElseIf cCampo == "FJY_QTDMAX"
			AAdd(aFilCpos,0)
		ElseIf cCampo == "FJY_VLRPRO"
			AAdd(aFilCpos,0)
		ElseIf cCampo == "FJY_SITPDD"
			AAdd(aFilCpos,MV_PAR11)
		Else
			AAdd(aFilCpos,CriaVar(cCampo))
		EndIf
		
	Next nX

	AADD(aDados,{0,aFilCpos})
	
	aFilCpos := {}
	
Next nY

Return aDados

//-----------------------------------------------------------
/*/{Protheus.doc} FA645LoadZ
Função que retorna a carga da grid de Títulos

@author Thiago.Murakami
@since 25/03/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645LoadZ(oModel)

Local aDados		:= {}
Local oFJZStruct	:= oModel:GetStruct()
Local oModelPai		:= oModel:GetModel()
Local oModelFJX		:= oModelPai:GetModel("FJXMASTER")
Local oModelFJY		:= oModelPai:GetModel("FJYDETAIL")
Local cProcesso		:= oModelFJX:GetValue("FJX_PROC")
Local cItemCli		:= oModelFJY:GetValue("FJY_ITEM")
Local aCposVlr		:= {}
Local aFilCpos		:= {}
Local nItem			:= 0
Local nTotal		:= 0
Local nMax			:= -100000
Local nAtraso		:= 0
Local cAliasFJZ		:= FA645QrySi(oModelFJY:GetValue("FJY_FILCLI"),oModelFJY:GetValue("FJY_CLIENT"),oModelFJY:GetValue("FJY_LOJA"))
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local cCampo		:= ""
Local aTitulo		:= {}
Local nAtrasoReal	:= 0
Local nValor 		:= 0
Local nSaldoBRT		:= 0
Local cMotBX		:= ""
Local cChaveOld 	:= ""
Local cChave		:= ""
Local dDataBx		:= CTOD("")
Local cFilAbat		:= ""
Local nTotProc		:= 0
Local cSomaAcre		:= Alltrim(SuperGetMV( "MV_PDDACRE" , .F. , '1' ))
Local lSomaAcre		:= .T.
Local lChkLiq		:= .F.
Local aAreaSE1		:= SE1->(GetArea())
Local lBxPer		:= .F.
Local cTitPai		:= ""
Local nX			:= 0
Local cAlsTMPPDD	:= GetNextAlias()
Local cAlsF465		:= GetNextAlias()
Local cQuery		:= ""
Local nAbat			:= 0
Local nChaveE1		:= 0
Local dSE1PaiAux	:= CTOD("")

Local nSaldoBx		:= 0
Local cPrefixo		:= ""
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
Local cNatTitulo	:= ""
Local cCliente		:= ""
Local cLoja			:= ""
Local nMoeda		:= ""
Local dBaixa		:= CTOD("")
Local dDataRef		:= CTOD("")
Local cFilTitulo	:= ""
Local cFilAux		:= ""

cSitPai := ""

// Se soma o acrecimo para o valor do saldo liquido
If cSomaAcre == '2'
	lSomaAcre := .F.
EndIf

aCposVlr := oFJZStruct:GetFields()

If lConstituicao
	Pergunte("FINA645C",.F.)
	dDataRef := MV_PAR01
ElseIf lReversao
	Pergunte("FINA645E",.F.)
	dDataRef := MV_PAR07
EndIf

/*
SaldoTit(;
(cAliasFJZ)->E1_PREFIXO,;			// Parâmetro 1 (Caractere) => Número do Prefixo
(cAliasFJZ)->E1_NUM,;				// Parâmetro 2 (Caractere) => Número do Titulo
(cAliasFJZ)->E1_PARCELA,;			// Parâmetro 3 (caractere) => Parcela
(cAliasFJZ)->E1_TIPO,;				// Parâmetro 4 (Caractere) => Tipo 
cNatTitulo,;						// Parâmetro 5 (Caractere) => Natureza
"R",;								// Parâmetro 6 (Caractere)  => Carteira R/P
(cAliasFJZ)->E1_CLIENTE,;			// Parâmetro 7 (Caractere) => Conforme Parâmetro 6 se for = 'R' Código Cliente se não Código Fornecedor.
(cAliasFJZ)->E1_MOEDA,;				// Parâmetro 8 (Numerico) => Moeda
,;									// Parâmetro 9 (Data) =>  Data para Conversão
STOD((cAliasFJZ)->E1_BAIXA),;		// Parâmetro 10 (Data) => Data Baixa a ser considerada.
(cAliasFJZ)->E1_LOJA,;				// Parâmetro 11 (Caractere) => Loja do Tipo
cFilTitulo,;						// Parâmetro 12 (Caractere) => Filial do Titulo
,; 									// Parâmetro 13 (Numerico) => Taxa da Moeda
1) 									// Parâmetro 14 (Numerico) => Tipo de Data para compor saldo(baixa/dispo/digit)
*/

(cAliasFJZ)->(DbGoTop())
While (cAliasFJZ)->(!Eof())

	cPrefixo	:= (cAliasFJZ)->E1_PREFIXO
	cNumero		:= (cAliasFJZ)->E1_NUM
	cParcela	:= (cAliasFJZ)->E1_PARCELA
	cTipo		:= (cAliasFJZ)->E1_TIPO
	cCliente	:= (cAliasFJZ)->E1_CLIENTE
	cLoja		:= (cAliasFJZ)->E1_LOJA
	nMoeda		:= (cAliasFJZ)->E1_MOEDA
	dBaixa		:= (cAliasFJZ)->E1_BAIXA

	If lConstituicao .Or. lReversao
		If (cAliasFJZ)->(E1_SALDO) == 0 .And. lConstituicao
			If MV_PAR03 = 1
				If (cAliasFJZ)->(E1_EMISSAO) > MV_PAR09
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			EndIF
			If MV_PAR03 = 2
				If (cAliasFJZ)->(E1_VENCTO) > (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
				If (cAliasFJZ)->(E1_BAIXA) < (MV_PAR01)
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			ElseIf  MV_PAR03 = 3
				If (cAliasFJZ)->(E1_VENCTO) >= (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
				If (cAliasFJZ)->(E1_BAIXA) <= (MV_PAR01)
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			Endif
		Endif

		If !Empty((cAliasFJZ)->(E1_NUMLIQ)) .And. lConstituicao
			
			If Select (cAlsF465) > 0
				(cAlsF465)->(DbCloseArea())
			Endif

			cFilAux := cFilAnt
			cFilAnt := (cAliasFJZ)->(E1_FILORIG)

			A460CalCan((cAliasFJZ)->(E1_NUMLIQ), lChkLiq, cAlsTMPPDD, @cQuery)

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlsF465, .F., .T.)

			cFilAnt := cFilAux

			If Select(cAlsF465) <= 0
				Return aDados
			Endif

			dSE1PaiAux	:= CTOD("")
			DbSelectArea("SE1")
			While !(cAlsF465)->(Eof())
				SE1->(dbGoto((cAlsF465)->CHAVE))
				If Empty(SE1->E1_NUMLIQ)
					If Empty(dSE1PaiAux)
						dSE1PaiAux	:= SE1->E1_VENCTO
					Else
						If SE1->E1_VENCTO <= dSE1PaiAux
							dSE1PaiAux	:= SE1->E1_VENCTO
							nChaveE1	:= (cAlsF465)->CHAVE
						Endif
					Endif
				Endif
				(cAlsF465)->(DbSkip())
			EndDo

			If Select (cAlsF465) > 0
				(cAlsF465)->(DbCloseArea())
			Endif

			If MV_PAR03 = 3
				If dSE1PaiAux >= (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(dbSkip())
					Loop
				Endif
			Elseif MV_PAR03 = 2
				If dSE1PaiAux > (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(dbSkip())
					Loop
				Endif
			Endif

			nAtraso		:= dSE1PaiAux - MV_PAR01
			nAtrasoReal	:= dSE1PaiAux - MV_PAR01
		Else
			If lConstituicao 
				If (cAliasFJZ)->E1_SALDO = 0
					If  Empty((cAliasFJZ)->E1_TIPOLIQ)
						If (MV_PAR03 = 1 .Or. MV_PAR03 = 2) .And. dBaixa < MV_PAR01
							(cAliasFJZ)->(dbSkip())
							Loop
						Endif
						
						If MV_PAR03 = 3 .And. dBaixa <= MV_PAR01
							(cAliasFJZ)->(dbSkip())
							Loop
						Endif
					Else
						If (MV_PAR03 = 1 .Or. MV_PAR03 = 2) .And. dBaixa <= MV_PAR01 .And. (cAliasFJZ)->E1_SALDO = 0
							(cAliasFJZ)->(dbSkip())
							Loop
						Endif
						
						If MV_PAR03 = 3 .And. dBaixa < MV_PAR01 .And. (cAliasFJZ)->E1_SALDO = 0
							(cAliasFJZ)->(dbSkip())
							Loop
						Endif
					Endif
					nAtraso		:= MV_PAR01 - (cAliasFJZ)->(E1_VENCTO)
					nAtrasoReal	:= MV_PAR01 - (cAliasFJZ)->(E1_VENCREA)
				Else
					If lReversao
						nAtraso		:= (cAliasFJZ)->(FJZ_QTDATR)
						nAtrasoReal	:= (cAliasFJZ)->(FJZ_QTDARE)
					ElseIf lConstituicao
						nAtraso		:= MV_PAR01 - (cAliasFJZ)->(E1_VENCTO)
						nAtrasoReal	:= MV_PAR01 - (cAliasFJZ)->(E1_VENCREA)
					Endif
					If MV_PAR03 == 3
						If MV_PAR02 >= nAtraso
							(cAliasFJZ)->(DbSkip())
							Loop
						Endif
					ElseIf MV_PAR03 == 2 
						If nAtraso < MV_PAR02
							(cAliasFJZ)->(DbSkip())
							Loop
						Endif
					Endif
				Endif
			ElseIf lReversao
				nAtraso		:= MV_PAR07 - (cAliasFJZ)->(E1_VENCTO)
				nAtrasoReal	:= MV_PAR07 - (cAliasFJZ)->(E1_VENCREA)
			Endif
		Endif	
	Else
		nAtraso 	:= (cAliasFJZ)->(FJZ_QTDATR)
		nAtrasoReal	:= (cAliasFJZ)->(FJZ_QTDARE)
	EndIf
	
	If nAtraso < 0 .And. nMax = -100000
		nMax := nAtraso
	Else
		If nMax = -100000
			nMax := nAtraso
		Else
			If nMax < 0 .And. nAtraso < 0
				If nAtraso < nMax 
					nMax := nAtraso
				Endif
			Else
				If nMax < nAtraso
					nMax := nAtraso
				Endif
			Endif
		Endif
	Endif

	//Ponto de entrada para adicionar campo no grid dos titulos
	If __lF645JZ .Or. __F645SITP
		aTitulo := {}
		//Array com a chave do titulo
		aadd(aTitulo,{"E1_FILORIG"	,  (cAliasFJZ)->E1_FILORIG})
		aadd(aTitulo,{"E1_PREFIXO"	,  (cAliasFJZ)->E1_PREFIXO})
		aadd(aTitulo,{"E1_NUM"		,  (cAliasFJZ)->E1_NUM})
		aadd(aTitulo,{"E1_PARCELA"	,  (cAliasFJZ)->E1_PARCELA})
		aadd(aTitulo,{"E1_TIPO"		,  (cAliasFJZ)->E1_TIPO})
		aadd(aTitulo,{"E1_CLIENTE"	,  (cAliasFJZ)->E1_CLIENTE})
		aadd(aTitulo,{"E1_LOJA"		,  (cAliasFJZ)->E1_LOJA})
	EndIf
	
	nSaldoBx := 0

	If (cAliasFJZ)->E1_TIPO $ MVABATIM
	
		If lReversao .and. cTitPai == AllTrim((cAliasFJZ)->E1_TITPAI)
			(cAliasFJZ)->(dbSkip())
			Loop
		EndIF
		
		nSaldo		:= (cAliasFJZ)->E1_SALDO
		nValor		:= 0
		nSaldoBRT	:= (cAliasFJZ)->E1_SALDO
		
		cSituaca	:= If (lConstituicao,(cAliasFJZ)->(E1_SITUACA),(cAliasFJZ)->(FJZ_SITUAC))
	Else
		cFilAbat	:= xFilial("SE1",(cAliasFJZ)->E1_FILORIG)
		
		//Posiciona no título SE1 para somar os abatimentos
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		
		If SE1->(dbSeek(cFilAbat+(cAliasFJZ)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
			nAbat	:= SomaAbat((cAliasFJZ)->E1_PREFIXO,(cAliasFJZ)->E1_NUM,(cAliasFJZ)->E1_PARCELA,"R",(cAliasFJZ)->E1_MOEDA,(cAliasFJZ)->E1_EMISSAO,(cAliasFJZ)->E1_CLIENTE,(cAliasFJZ)->E1_LOJA,cFilAbat,,(cAliasFJZ)->E1_TIPO)
		EndIf
		
		If (cAliasFJZ)->E1_SALDO = 0  .And. lConstituicao 
			cFilTitulo	:= Posicione("SE1", 1, xFilial("SE1") + (cAliasFJZ)->E1_PREFIXO + (cAliasFJZ)->E1_NUM + (cAliasFJZ)->E1_PARCELA + (cAliasFJZ)->E1_TIPO, "E1_FILORIG")
			cNatTitulo	:= Posicione("SE1", 1, xFilial("SE1") + (cAliasFJZ)->E1_PREFIXO + (cAliasFJZ)->E1_NUM + (cAliasFJZ)->E1_PARCELA + (cAliasFJZ)->E1_TIPO, "E1_NATUREZ")

			If (MV_PAR03 = 1 .Or. MV_PAR03 = 2) .And. dBaixa = MV_PAR01
				nSaldoBx 	:= SaldoTit(cPrefixo, cNumero, cParcela, cTipo, cNatTitulo, "R", cCliente, nMoeda, , MV_PAR01, cLoja, cFilTitulo, , 1)
			ElseIf (MV_PAR03 = 1 .Or. MV_PAR03 = 2 .Or. MV_PAR03 = 3) .And. dBaixa > MV_PAR01
				nSaldoBx 	:= SaldoTit(cPrefixo, cNumero, cParcela, cTipo, cNatTitulo, "R", cCliente, nMoeda, , MV_PAR01, cLoja, cFilTitulo, , 1)
			ElseIf (MV_PAR03 = 1 .Or. MV_PAR03 = 2) .And. dBaixa < MV_PAR01
				(cAliasFJZ)->(dbSkip())
				Loop
			Elseif MV_PAR03 = 3 .And. dBaixa <= MV_PAR01
				(cAliasFJZ)->(dbSkip())
				Loop
			Endif

			If nSaldoBx = 0
				(cAliasFJZ)->(dbSkip())
				Loop
			Endif

			nSaldo	:= nSaldoBx - nAbat
			
			If lSomaAcre
				nSaldo  += (cAliasFJZ)->E1_SDACRES - (cAliasFJZ)->E1_SDDECRE
			Endif
					
			nValor		:= (cAliasFJZ)->E1_VALOR
			nSaldoBRT	:= nSaldoBx
		Else
			If (cAliasFJZ)->E1_SALDO > 0 .And. !Empty((cAliasFJZ)->E1_BAIXA) .And. lConstituicao
				cFilTitulo	:= Posicione("SE1", 1, xFilial("SE1") + (cAliasFJZ)->E1_PREFIXO + (cAliasFJZ)->E1_NUM + (cAliasFJZ)->E1_PARCELA + (cAliasFJZ)->E1_TIPO, "E1_FILORIG")
				cNatTitulo	:= Posicione("SE1", 1, xFilial("SE1") + (cAliasFJZ)->E1_PREFIXO + (cAliasFJZ)->E1_NUM + (cAliasFJZ)->E1_PARCELA + (cAliasFJZ)->E1_TIPO, "E1_NATUREZ")
				If (MV_PAR03 = 1 .Or. MV_PAR03 = 2) .And. dBaixa = MV_PAR01
					nSaldoBx 	:= SaldoTit(cPrefixo, cNumero, cParcela, cTipo, cNatTitulo, "R", cCliente, nMoeda, , MV_PAR01, cLoja, cFilTitulo, , 1)
				ElseIf (MV_PAR03 = 1 .Or. MV_PAR03 = 2 .Or. MV_PAR03 = 3) .And. dBaixa > MV_PAR01
					nSaldoBx 	:= SaldoTit(cPrefixo, cNumero, cParcela, cTipo, cNatTitulo, "R", cCliente, nMoeda, , MV_PAR01, cLoja, cFilTitulo, , 1)
				ElseIf (MV_PAR03 = 1 .Or. MV_PAR03 = 2 .Or. MV_PAR03 = 3) .And. dBaixa > MV_PAR01
					nSaldoBx 	:= SaldoTit(cPrefixo, cNumero, cParcela, cTipo, cNatTitulo, "R", cCliente, nMoeda, , MV_PAR01, cLoja, cFilTitulo, , 1)
				Endif
				If nSaldoBx > 0
					nSaldo		:= nSaldoBx - nAbat
					nValor		:= (cAliasFJZ)->E1_VALOR
					nSaldoBRT	:= nSaldoBx
				Else
					nSaldo		:= (cAliasFJZ)->E1_SALDO - nAbat
					nValor		:= (cAliasFJZ)->E1_VALOR
					nSaldoBRT	:= (cAliasFJZ)->E1_SALDO
				Endif
				If lSomaAcre
					nSaldo  += (cAliasFJZ)->E1_SDACRES - (cAliasFJZ)->E1_SDDECRE
				Endif
			Else
				nSaldo		:= (cAliasFJZ)->E1_SALDO - nAbat

				If lSomaAcre
					nSaldo  += (cAliasFJZ)->E1_SDACRES - (cAliasFJZ)->E1_SDDECRE
				Endif

				nValor		:= (cAliasFJZ)->E1_VALOR
				nSaldoBRT	:= (cAliasFJZ)->E1_SALDO
			Endif 
		Endif
		//Guardo a situação do titulo principal para repassar, no model, a situação dos abatimentos.
		//Necessário para que, quando se utiliza Outras Ações -> Situação PDD Titulos, os abatimentos acompanhem os principais.
		cSituaca	:= If (lConstituicao,(cAliasFJZ)->(E1_SITUACA),(cAliasFJZ)->(FJZ_SITUAC))
		cSitPai	    := cSituaca
	EndIf
	
	If nSaldoBx > 0
		nSaldo := nSaldoBx
	Else
		nSaldo := IIF(nSaldo < 0, 0, nSaldo)
	Endif
	
	If lReversao
		nSaldoTit	:= (cAliasFJZ)->E1_SALDO
		nSaldo		:= (cAliasFJZ)->FJZ_SALDO	
	EndIf
	cChave := (cAliasFJZ)->E1_PREFIXO+(cAliasFJZ)->E1_NUM+(cAliasFJZ)->E1_PARCELA+(cAliasFJZ)->E1_TIPO
	If lConstituicao .Or. lReversao
		If lReversao
			If !(cAliasFJZ)->E1_TIPO $ MVABATIM 
				cRevSta := Alltrim(F645MotRev(cAliasFJZ))
				If cRevSta $ '1|4' .AND. MV_PAR01 <> 1 //verifica a baixa dos títulos.
					cChaveTit := (cAliasFJZ)->E1_FILIAL + "|" +;
									(cAliasFJZ)->E1_PREFIXO + "|" +;
									(cAliasFJZ)->E1_NUM		+ "|" +;
									(cAliasFJZ)->E1_PARCELA + "|" +;
									(cAliasFJZ)->E1_TIPO	+ "|" +;
									(cAliasFJZ)->E1_CLIENTE + "|" +;
									(cAliasFJZ)->E1_LOJA
					lBxPer := F645VerBx(cChaveTit, cAliasFJZ, (cAliasFJZ)->E1_FILORIG)
					If !lBxPer
						If MV_PAR01 == 2 //títulos baixados
							cTitPai := cChave + (cAliasFJZ)->E1_CLIENTE + (cAliasFJZ)->E1_LOJA
							(cAliasFJZ)->(dbSkip())
							Loop
						Else						
							cRevSta := "3" //Normal
						Endif
					ElseIf MV_PAR01 == 3 //títulos em aberto
						cTitPai := cChave + (cAliasFJZ)->E1_CLIENTE + (cAliasFJZ)->E1_LOJA
						(cAliasFJZ)->(dbSkip())
						Loop
					Endif
				Endif
			Endif
		EndIf
		If cChaveOld != cChave
			cChaveOld := cChave
			nTotal += nSaldo
		EndIf
		
	EndIf

	nItem := nItem + 1
	
	For nX := 1 To Len(aCposVlr)
		
	cCampo := AllTrim(aCposVlr[nX][3])
		
		If cCampo == "FJZ_LEGEND"
			If (cAliasFJZ)->E1_SALDO > 0      .And. Empty((cAliasFJZ)->E1_NUMLIQ)  .And. Empty((cAliasFJZ)->E1_BAIXA)
				AAdd(aFilCpos, "BR_VERDE")
			ElseIf (cAliasFJZ)->E1_SALDO > 0  .And. !Empty((cAliasFJZ)->E1_NUMLIQ) .And. Empty((cAliasFJZ)->E1_BAIXA)
				AAdd(aFilCpos, "BR_AZUL")
			ElseIf (cAliasFJZ)->E1_SALDO == 0 .And. Empty((cAliasFJZ)->E1_NUMLIQ)  .And. (cAliasFJZ)->E1_BAIXA >= (cAliasFJZ)->E1_VENCTO .And. (cAliasFJZ)->E1_BAIXA >= dDataRef
				AAdd(aFilCpos, "BR_PRETO")
			ElseIf (cAliasFJZ)->E1_SALDO == 0 .And. !Empty((cAliasFJZ)->E1_NUMLIQ) .And. (cAliasFJZ)->E1_BAIXA >= (cAliasFJZ)->E1_VENCTO .And. (cAliasFJZ)->E1_BAIXA >= dDataRef
				AAdd(aFilCpos, "BR_VERMELHO")
			ElseIf (cAliasFJZ)->E1_SALDO > 0  .And. Empty((cAliasFJZ)->E1_NUMLIQ)  .And. (cAliasFJZ)->E1_BAIXA <= dDataRef .And. !Empty((cAliasFJZ)->E1_BAIXA)
				AAdd(aFilCpos, "BR_BRANCO")
			ElseIf (cAliasFJZ)->E1_SALDO > 0  .And. !Empty((cAliasFJZ)->E1_NUMLIQ) .And. (cAliasFJZ)->E1_BAIXA <= dDataRef .And. !Empty((cAliasFJZ)->E1_BAIXA)
				AAdd(aFilCpos, "BR_AMARELO")
			ElseIf (cAliasFJZ)->E1_SALDO > 0  .And. Empty((cAliasFJZ)->E1_NUMLIQ)  .And. (cAliasFJZ)->E1_BAIXA >= dDataRef .And. !Empty((cAliasFJZ)->E1_BAIXA)
				AAdd(aFilCpos, "BR_PINK")
			ElseIf (cAliasFJZ)->E1_SALDO > 0  .And. !Empty((cAliasFJZ)->E1_NUMLIQ) .And. (cAliasFJZ)->E1_BAIXA >= dDataRef .And. !Empty((cAliasFJZ)->E1_BAIXA)
				AAdd(aFilCpos, "BR_LARANJA")
			ElseIf (cAliasFJZ)->E1_SALDO == 0 .And. !Empty((cAliasFJZ)->E1_NUMLIQ) .And. (cAliasFJZ)->E1_BAIXA <= (cAliasFJZ)->E1_VENCTO .And. (cAliasFJZ)->E1_BAIXA >= dDataRef
				AAdd(aFilCpos, "BR_AZUL_CLARO")
			Else
				AAdd(aFilCpos, "BR_MARRON")
			Endif

		ElseIf cCampo == "FJZ_FILIAL"
			AAdd(aFilCpos,xFilial('FJZ'))
		ElseIf cCampo == "FJZ_OK"
			AAdd(aFilCpos,.T.)
		ElseIf cCampo == "FJZ_PROC"
			AAdd(aFilCpos,cProcesso)
		ElseIf cCampo == "FJZ_ITCLI"
			AAdd(aFilCpos,cItemCli )
		ElseIf cCampo == "FJZ_ITEM"
			AAdd(aFilCpos,STRZERO(nItem,TamSX3('FJZ_ITEM')[1]))
		ElseIf cCampo == "FJZ_FILTIT"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_FILORIG))
		ElseIf cCampo == "FJZ_PREFIX"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_PREFIXO))
		ElseIf cCampo == "FJZ_NUM"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_NUM))
		ElseIf cCampo == "FJZ_PARCEL"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_PARCELA))
		ElseIf cCampo == "FJZ_TIPO"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_TIPO ))
		ElseIf cCampo == "FJZ_VALOR"
			AAdd(aFilCpos,nValor )
		ElseIf cCampo == "FJZ_SALDO"
			AAdd(aFilCpos,nSaldo)
		ElseIf cCampo == "FJZ_SLDBRT"
			AAdd(aFilCpos,nSaldoBRT)
		ElseIf cCampo == "FJZ_EMISS"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_EMISSAO))
		ElseIf cCampo == "FJZ_VENCTO"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_VENCTO))
		ElseIf cCampo == "FJZ_VENCRE"
			AAdd(aFilCpos,(cAliasFJZ)->(E1_VENCREA))
		ElseIf cCampo == "FJZ_VLRBX"
			AAdd(aFilCpos,0)
		ElseIf cCampo == "FJZ_QTDATR"
			AAdd(aFilCpos,nAtraso)
		ElseIf cCampo == "FJZ_QTDARE"
			AAdd(aFilCpos,nAtrasoReal)
		ElseIf cCampo == "FJZ_SITUAC"
			AAdd(aFilCpos,cSituaca)
		ElseIf cCampo == "FJZ_SITPAI"
			AAdd(aFilCpos,cSitPai)
		ElseIf cCampo == "FJZ_MOTBX"
			AAdd(aFilCpos,cMotbx)
		ElseIf cCampo == "FJZ_DTBAIX"
			AAdd(aFilCpos,dDataBx)
		ElseIf cCampo == "FJZ_SITPDD"
			AAdd(aFilCpos,IIf(lConstituicao,IIf(__F645SITP,ExecBlock('F645SITP',.F.,.F.,{(cAliasFJZ)->E1_SITUACA,aTitulo}),MV_PAR11),(cAliasFJZ)->FJZ_SITPDD))
		ElseIf cCampo == "FJZ_REVSTA"
			AAdd(aFilCpos,IIf(lConstituicao,CriaVar(cCampo),cRevSta))
		Else
			AAdd(aFilCpos,IIf(__lF645JZ,ExecBlock('F645LDFJ',.F.,.F.,{cCampo,aTitulo}),CriaVar(cCampo)))
		EndIf
		
	Next nX

	AADD(aFilCpos,.T.	)
	AADD(aDados,{0,aFilCpos})
	
	aFilCpos := {}
	
	(cAliasFJZ)->(DbSkip())
EndDo


oModelFJY:LoadValue('FJY_VLRPRO', nTotal )
oModelFJY:LoadValue('FJY_QTDMAX', nMax )

nTotProc := oModelFJX:GetValue('FJX_VLRPRO') + nTotal

oModelFJX:LoadValue('FJX_VLRPRO', nTotProc )

If Select(cAliasFJZ) > 0
	(cAliasFJZ)->(DbCloseArea())
EndIf

If Select (cAlsTMPPDD) > 0
	(cAlsTMPPDD)->(DbCloseArea())
Endif

RestArea(aAreaSE1)

Return aDados

//-----------------------------------------------------------
/*/{Protheus.doc} FA645LoadW
Função que retorna a carga da grid de Nota Fiscal

@author Thiago.Murakami
@since 25/03/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645LoadW(oModel)

Local aDados			:= {}
Local oModelPai		:= oModel:GetModel()
Local oModelFJY		:= oModelPai:GetModel("FJYDETAIL")
Local oModelFJZ		:= oModelPai:GetModel("FJZDETAIL")
Local cFilTit		:= oModelFJZ:GetValue("FJZ_FILTIT")
Local cPrefix		:= oModelFJZ:GetValue("FJZ_PREFIX")
Local cNum			:= oModelFJZ:GetValue("FJZ_NUM")
Local cParcela		:= oModelFJZ:GetValue("FJZ_PARCEL")
Local cCliente		:= oModelFJY:GetValue("FJY_CLIENT")
Local cLoja			:= oModelFJY:GetValue("FJY_LOJA")
Local cTipo			:= oModelFJZ:GetValue("FJZ_TIPO")
Local nValTit 		:= oModelFJZ:GetValue("FJZ_VALOR")
Local nValSal 		:= oModelFJZ:GetValue("FJZ_SALDO")
Local cTempFWZ		:= GetNextAlias()	
Local aStruFWZ		:= F645StFWZ()
Local oTempTableFWZ
Local aIndiceFWZ	:= {"FWZ_FILIAL","FWZ_PROC","FWZ_ITCLI","FWZ_ITTIT","FWZ_DOC","FWZ_SERIE","FWZ_ITEM"}

//-------------------
//Criação do objeto
//-------------------
oTempTableFWZ := FWTemporaryTable():New(cTempFWZ)
oTempTableFWZ:SetFields( aStruFWZ )
	
oTempTableFWZ:AddIndex("ORD1", aIndiceFWZ)
	
//------------------
//Criação da tabela
//------------------
oTempTableFWZ:Create()

DbSelectArea("SE1")
SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
If SE1->(MsSeek(xFilial("SE1",cFilTit)+cCliente+cLoja+cPrefix+cNum+cParcela+cTipo))
	If !Empty(SE1->E1_NUMLIQ) //título de liquidação
		FA645BLiq(oModel, cFilTit,cPrefix,cNum,cParcela, cTipo, cCliente,cLoja, cTempFWZ)
		FA645TmpFWZ(aDados,cTempFWZ, oModel)
	ElseIf Alltrim(SE1->E1_ORIGEM) == "MATA460"
		FA645ItNFFI7 (oModel, cFilTit,cPrefix,cNum,cCliente,cLoja, nValTit, nValSal, cTempFWZ)
		FA645TmpFWZ(aDados,cTempFWZ, oModel)
	EndIf
Endif

	If oTempTableFWZ <> Nil
		oTempTableFWZ:Delete()
		oTempTableFWZ := Nil
	EndIf
	
	If Select(cTempFWZ) > 0
		dbSelectArea(cTempFWZ)
		dbCloseArea()
		MsErase(cTempFWZ)
	Endif

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645QryNF
Query para rateio da nota fiscal

@author Alvaro Camillo neto
@since 17/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function FA645QryNF(cFilTit,cPrefix,cNum,cCliente,cLoja)

Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cFilSB1		:= xFilial("SB1",cFilTit)
Local cFilSD2		:= xFilial("SD2",cFilTit)

BeginSql Alias cNextAlias
	SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_ITEM,D2_COD,D2_TOTAL,B1_DESC
	FROM %table:SD2% SD2
	INNER JOIN %table:SB1% SB1 ON 
		SB1.B1_FILIAL = %Exp:cFilSB1% AND
		SB1.B1_COD = D2_COD AND  
		SB1.%NotDel%
	WHERE 
	SD2.D2_FILIAL = %Exp:cFilSD2% 
	AND SD2.D2_DOC = %Exp:cNum%
	AND SD2.D2_SERIE = %Exp:cPrefix%
	AND SD2.D2_CLIENTE = %Exp:cCliente%	
	AND SD2.D2_LOJA = %Exp:cLoja%
	AND SD2.%NotDel%
	ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_ITEM 
EndSql

RestArea(aArea)

Return (cNextAlias)

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645NFTot
Query para total da Nota

@author Alvaro Camillo neto
@since 17/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function FA645NFTot(cFilTit,cPrefix,cNum,cCliente,cLoja)

Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local nTotal		:= 0
Local cFilSD2		:= xFilial("SD2",cFilTit)

BeginSql Alias cNextAlias
	SELECT SUM(D2_TOTAL) TOTALNF
	FROM %table:SD2% SD2
	WHERE 
	SD2.D2_FILIAL = %Exp:cFilSD2% 
	AND SD2.D2_DOC = %Exp:cNum%
	AND SD2.D2_SERIE = %Exp:cPrefix%
	AND SD2.D2_CLIENTE = %Exp:cCliente%	
	AND SD2.D2_LOJA = %Exp:cLoja%
	AND SD2.%NotDel%
EndSql

If (cNextAlias)->(!EOF())
	nTotal := (cNextAlias)->TOTALNF
EndIf

(cNextAlias)->(dbCloseArea())
RestArea(aArea)

Return (nTotal)

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Mark
Função de validação da marca dos Clientes e Títulos.
Chamada da marca de clientes

@author Kaique Schiller
@since 27/03/2015
@version 12
/*/
//-------------------------------------------------------------------

Function FA645Mark(oModel)

Local aSaveLines	:= FWSaveRows()
Local oView			:= FWViewActive()
Local oModelCli 	:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local nLineAtu		:= oModelTit:GetLine()
Local lCheck 		:= oModelCli:GetValue("FJY_OK")
Local nX			:= 0
Local nLenTit		:= oModelTit:Length()

For nX := 1 to nLenTit
	oModelTit:GoLine(nX)
	oModelTit:LoadValue("FJZ_OK",lCheck)
Next nX

//Atualiza títulos - Valores
If nLenTit > 0
	FA645Check(oModel)
Endif

FWRestRows(aSaveLines)

oModelTit:GoLine(nLineAtu)
If __lRefresh
	If oView != Nil
		oView:Refresh()
	EndIf
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645SitGat
Gatilho do campo de situação de cobrança

@author Kaique Schiller
@since 27/03/2015
@version 12
/*/
//-------------------------------------------------------------------

Function FA645SitGat(oModel)

Local aSaveLines	:= FWSaveRows()
Local oView			:= FWViewActive()
Local oModelCli 	:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local nLineAtu		:= oModelTit:GetLine()
Local cSit 			:= oModelCli:GetValue("FJY_SITPDD")
Local nX			:= 0
Local nLenTit		:= oModelTit:Length()

For nX := 1 to nLenTit
	oModelTit:GoLine(nX)
	oModelTit:LoadValue("FJZ_SITPDD",cSit)
Next nX

FWRestRows(aSaveLines)

oModelTit:GoLine(nLineAtu)

If __lRefresh
	If oView != Nil
		oView:Refresh()
	EndIf
Endif

Return cSit

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Check
Função de validação da marca dos Clientes e Títulos.

@author Kaique Schiller
@since 27/03/2015
@version 12
/*/
//-------------------------------------------------------------------

Function FA645Check(oModel)

Local oView			:= FWViewActive()
Local oModelFJX		:= oModel:GetModel("FJXMASTER")
Local oModelCli 	:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local oFwGrid
Local nLineAtu		:= oModelTit:GetLine()
Local lOk			:= oModelCli:GetValue("FJY_OK")
Local lCheck 		:= oModelTit:GetValue("FJZ_OK")
Local nTotCliAtu	:= oModelCli:GetValue("FJY_VLRPRO")
Local nTotal 		:= 0
Local nTotProc		:= 0
Local nZ			:= 0
Local nAtraso 		:= 0
Local nMax			:= 0
Local cChave		:= ""
Local cChaveOld		:= ""
Local aSaveLines	:= FWSaveRows()
Local nLenTit		:= oModelTit:Length()

If !lAutomato
	oFwGrid		:= oView:GetSubView("FJZDETAIL")
	If lCheck .AND. !lOk
		If MsgYesNo(STR0006) //Não é possivel marcar Títulos de Clientes não selecionados. Deseja marcar o Cliente?
			oModelCli:LoadValue("FJY_OK" , .T. )
		Else
			oModelTit:LoadValue("FJZ_OK" , .F. )
		Endif
	Endif
Endif

nZ := 0

For nZ := 1 To nLenTit

	If oModelTit:GetValue("FJZ_OK",nZ)
		cChave := oModelTit:GetValue("FJZ_FILTIT",nZ)+oModelTit:GetValue("FJZ_PREFIX",nZ)+oModelTit:GetValue("FJZ_NUM",nZ)+oModelTit:GetValue("FJZ_PARCEL",nZ)+oModelTit:GetValue("FJZ_TIPO",nZ)

		If cChaveOld != cChave
			cChaveOld := cChave
			nTotal += oModelTit:GetValue("FJZ_SALDO",nZ)
		EndIf	
		nAtraso := oModelTit:GetValue("FJZ_QTDATR",nZ)

		If nMax = 0 .And. nAtraso != 0
			nMax := nAtraso
		ElseIf nMax <= nAtraso
			nMax := nAtraso
		Endif
	Endif
Next

oModelCli:SetValue("FJY_VLRPRO", nTotal )
oModelCli:SetValue('FJY_QTDMAX', nMax )

nTotProc := oModelFJX:GetValue('FJX_VLRPRO') - nTotCliAtu + nTotal

oModelFJX:LoadValue('FJX_VLRPRO', nTotProc )

oModelTit:GoLine(nLineAtu)

FWRestRows(aSaveLines)

If !lAutomato
	If __lRefresh
		If oView != Nil
			oView:Refresh()
		EndIf
	Endif
Endif

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645PreVl
Pré - Validação para títulos não encontrados 

@author Totvs
@since 08/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645PreVl( oModel )

Local lConstituicao := FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local lEfetiva		:= FwIsInCallStack("FA645Efe")
Local lEfeRev  		:= FwIsInCallStack("FA645EfRev")
Local lRet			:= .T.
Local nOperation 	:= oModel:GetOperation()
Local nCountFJZ		:= 0
Local lVerBas		:= .T.
Local aDadosTit		:= {}
Local nXFJZ			:= 0

//Limpeza de tabelas
If nOperation == MODEL_OPERATION_DELETE
	If FJX->FJX_STATUS != "1"
		HELP(" ",1,"FA645PreVl1",,STR0031 ,1,0) //"Status não permite essa operação"	
		lRet:=.F.
	EndIf
ElseIf lConstituicao .Or. lReversao
		CtbTmpErase(__cTmpSE1)
		CtbTmpErase(__cTmpSA1)
		cAliasFJZ	:= FA645QrySi(,,,lVerBas)
		If !((cAliasFJZ)->(!EOF()) .and. (cAliasFJZ)->(!BOF()))
			(cAliasFJZ)->(DbCloseArea())
			HELP(" ",1,"FA645PreVl",,STR0019 ,1,0) //Não foram localizados titulos de acordo com os parâmetros informados.
			lRet:=.F.
		Else
			__aDadosCli := {}
			aDadosTit := FA645TiBus(cAliasFJZ)
			If Len(aDadosTit) > 0
				For nXFJZ := 1 To Len(aDadosTit)
					If nCountFJZ == 0
						aAdd(__aDadosCli, { aDadosTit[nXFJZ, 1], aDadosTit[nXFJZ, 2] } )
					Else
						If AScan(__aDadosCli, {|x| AllTrim(x[1]) == AllTrim(aDadosTit[nXFJZ, 1] ) .And. AllTrim(aDadosTit[nXFJZ, 2] ) == AllTrim(x[2])}) == 0
							aAdd(__aDadosCli, { aDadosTit[nXFJZ, 1], aDadosTit[nXFJZ, 2] } )
						Endif
					Endif
					nCountFJZ++
				Next nXFJZ
			Else
				(cAliasFJZ)->(DbCloseArea())
				HELP(" ",1,"FA645PreVl",,STR0019 ,1,0) //Não foram localizados titulos de acordo com os parâmetros informados.
				lRet:=.F.
			Endif
		Endif
ElseIf nOperation == MODEL_OPERATION_UPDATE .And. !( lEfetiva .Or. lEfeRev)
	If FJX->FJX_STATUS != "1"
		HELP(" ",1,"FA645PreVl2",,STR0031 ,1,0) //"Status não permite essa operação"	
		lRet:=.F.
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645GRV
Gravação dos dados

@author Thiago.Murakami
@since 30/03/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645GRV( oModel )

Local aAreaSM0		:= SM0->(GetArea())
Local oModelMaster	:= oModel:GetModel("FJXMASTER")
Local aCpoMaster	:= oModelMaster:GetStruct():GetFields()
Local oModelCli 	:= oModel:GetModel('FJYDETAIL')
Local aCpoCli		:= oModelCli:GetStruct():GetFields()
Local oModelTit		:= oModel:GetModel('FJZDETAIL')
Local aCpoTit		:= oModelTit:GetStruct():GetFields() //aqui pam
Local oModelNF		
Local aCpoNF		:= {}
Local nCampo		:= 0
Local nOperacao		:= oModel:GetOperation()
Local nCliente		:= 0
Local nTitulo		:= 0
Local nNota			:= 0
Local lEfetiva		:= FwIsInCallStack("FA645Efe")
Local lEfeRev  		:= FwIsInCallStack("FA645EfRev")
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local lAlteracao	:= FwIsInCallStack("FA645Alt")
Local cFilBkp		:= cFilAnt
Local cStaTit		:= ""
Local cIdCV8		:= ""
Local cchave		:= ""
Local cChaveTit		:= ""
Local cMsg			:= ""
Local cFilOrigem	:= ""
Local cMensagem		:= FwNoAccent(AllTrim(STR0020) + " " + oModelMaster:GetValue("FJX_PROC"))
Local cUltSeq		:= ""
Local cIdDoc		:= ""

Local lMostraRat	:= .T.

If lConstituicao
	Pergunte("FINA645C",.F.)
	lMostraRat	:= SUPERGETMV('MV_PDDRTNF',.F.,2)== 1 //MV_PAR13 == 1
ElseIf lReversao
	Pergunte("FINA645E",.F.)
EndIf

If lMostraRat
	oModelNF	:= oModel:GetModel('FWZDETAIL')
	aCpoNF		:= oModelNF:GetStruct():GetFields()
EndIf
cChave 		:= xFilial("FJX") + oModelMaster:GetValue("FJX_PROC")
ProcLogIni({},"FJX" + cChave," ",@cIdCV8)

If nOperacao ==  MODEL_OPERATION_DELETE
	Begin Transaction		
		For nCliente := 1 to oModelCli:Length()
			oModelCli:GoLine( nCliente )
			oModelTit	:= oModel:GetModel('FJZDETAIL')			
			For nTitulo := 1 to oModelTit:Length()
				oModelTit:GoLine(nTitulo)
				cFilOrigem := oModelTit:GetValue("FJZ_FILTIT")
				cChaveTit := xFilial("SE1",cFilOrigem) + "|" + oModelTit:GetValue("FJZ_PREFIX") + "|" + oModelTit:GetValue("FJZ_NUM") + "|" + oModelTit:GetValue("FJZ_PARCEL") + "|" +  oModelTit:GetValue("FJZ_TIPO")  + "|" + oModelCli:GetValue("FJY_CLIENT") + "|" + oModelCli:GetValue("FJY_LOJA")
				cIdDoc    := FINGRVFK7("SE1", cChaveTit, cFilOrigem)
				//Somente gravo log para titulos selecionados
				If oModelTit:GetValue("FJZ_OK")
					ProcLogIni({},cIdDoc," ",@cIdCV8,cFilOrigem)
					ProcLogAtu("MENSAGEM",cMensagem,FwNoAccent(cMensagem + " - " + STR0066) ,,.F.,cFilOrigem)		//'Provisão PDD'###"Exclusão"
				Endif
			Next nTitulo
		Next nCliente
		FWFormCommit( oModel )
	End Transaction
Else
	If lConstituicao
		cStaTit := "1"
	ElseIf lReversao
		cStaTit := "3"
	EndIf
	
	Do Case
		Case lEfetiva
			cMsg := cMensagem + " - " + Alltrim(STR0011)		//'Provisão PDD'###"Efetivação"
		Case lEfeRev
			cMsg := cMensagem + " - " + Alltrim(STR0052)		//'Provisão PDD'###"Efetivaçãoda reversão"
		Case lConstituicao
			cMsg := cMensagem + " - " + Alltrim(STR0010)		//'Provisão PDD'###"Constituição"
		Case lReversao
			cMsg := cMensagem + " - " + Alltrim(STR0013)		//'Provisão PDD'###"Reversão"
	EndCase
	cMsg := FwNoAccent(cMsg)
	
	ProcLogAtu("INICIO",cMsg + " - " + cChave,,,.T.)
	
	//Grava Simulação
	If lConstituicao .Or. lReversao
		
		BEGIN TRANSACTION
			ConfirmSx8()
			
			FJX->(RecLock("FJX",.T.))
			For nCampo := 1 to Len(aCpoMaster)
				cCampo := aCpoMaster[nCampo][3]
				FJX->&(cCampo) := oModelMaster:GetValue(cCampo)
			Next nCampo
			FJX->FJX_FILIAL	:= xFilial("FJX")
			FJX->(MsUnLock())
			
			For nCliente := 1 to oModelCli:Length()
				
				oModelCli:GoLine( nCliente )
				FJY->(RecLock("FJY" , .T.))
				
				For nCampo := 1 to Len(aCpoCli)
					cCampo := aCpoCli[nCampo][3]
					FJY->&(cCampo) := oModelCli:GetValue(cCampo)
				Next nCampo
				FJY->FJY_FILIAL := xFilial("FJY")
				FJY->(MsUnlock())
				
				oModelTit	:= oModel:GetModel('FJZDETAIL')			
				For nTitulo := 1 to oModelTit:Length()
					oModelTit:GoLine(nTitulo)
					FJZ->(RecLock("FJZ" , .T.))
					
					For nCampo := 1 to Len(aCpoTit)
						cCampo := aCpoTit[nCampo][3]
						FJZ->&(cCampo) := oModelTit:GetValue(cCampo)
					Next nCampo
					
					FJZ->FJZ_FILIAL := xFilial("FJZ")
					FJZ->FJZ_STATUS := cStaTit								
					FJZ->(MsUnlock("FJZ"))
					
					cFilOrigem := oModelTit:GetValue("FJZ_FILTIT")
					cChaveTit  := xFilial("SE1",cFilOrigem) + "|" + oModelTit:GetValue("FJZ_PREFIX") + "|" + oModelTit:GetValue("FJZ_NUM") + "|" + oModelTit:GetValue("FJZ_PARCEL") + "|" +  oModelTit:GetValue("FJZ_TIPO")  + "|" + oModelCli:GetValue("FJY_CLIENT") + "|" + oModelCli:GetValue("FJY_LOJA")
					cIdDoc     := FINGRVFK7("SE1", cChaveTit, cFilOrigem)

					FK1->(DbSetOrder(2))

					If FK1->(DbSeek(xFilial("FK1",cFilOrigem) + cIdDoc + "01"))
						While !FK1->(Eof()) .And. FK1->(FK1_FILIAL + FK1_IDDOC) == xFilial("FK1",cFilOrigem) + cIdDoc 
							cUltSeq := FK1->FK1_SEQ
							FK1->(dbSkip())
						EndDo
					Else
						cUltSeq := ""
					EndIf
					
					FJZ->(RecLock("FJZ" , .F.))
						FJZ->FJZ_ULTSEQ := cUltSeq
					FJZ->(MsUnlock("FJZ"))
					
					//Somente gravo log para titulos selecionados
					If oModelTit:GetValue("FJZ_OK")
						ProcLogIni({},cIdDoc," ",@cIdCV8,cFilOrigem)
						ProcLogAtu("MENSAGEM",cMsg,cMsg,,.F.,cFilOrigem)
					Endif
					If lMostraRat							
						oModelNF := oModel:GetModel('FWZDETAIL')
						For nNota := 1 to oModelNF:Length()
							oModelNF:GoLine(nNota)
							If !Empty(oModelNF:GetValue("FWZ_DOC"))
								FWZ->(RecLock("FWZ" , .T.))
								For nCampo := 1 to Len(aCpoNF)
									cCampo := aCpoNF[nCampo][3]
									FWZ->&(cCampo) := oModelNF:GetValue(cCampo)
								Next nCampo
								FWZ->FWZ_FILIAL := xFilial("FWZ")
								FWZ->(MsUnlock("FJZ"))
							EndIf
						Next nNota
					EndIf	
				Next nTitulo	
			Next nCliente
		END TRANSACTION
		ConfirmSx8()	
	//Grava Efetivação
	ElseIf lEfetiva .Or. lEfeRev
		
		If FA645Situ(oModel)
			Begin Transaction		
				For nCliente := 1 to oModelCli:Length()
					oModelCli:GoLine( nCliente )
					oModelTit	:= oModel:GetModel('FJZDETAIL')			
					For nTitulo := 1 to oModelTit:Length()
						oModelTit:GoLine(nTitulo)
						cFilOrigem := oModelTit:GetValue("FJZ_FILTIT")
						cChaveTit := xFilial("SE1",cFilOrigem) + "|" + oModelTit:GetValue("FJZ_PREFIX") + "|" + oModelTit:GetValue("FJZ_NUM") + "|" + oModelTit:GetValue("FJZ_PARCEL") + "|" +  oModelTit:GetValue("FJZ_TIPO")  + "|" + oModelCli:GetValue("FJY_CLIENT") + "|" + oModelCli:GetValue("FJY_LOJA")
						cIdDoc    := FINGRVFK7("SE1", cChaveTit, cFilOrigem)
						If lEfetiva .AND. __lAltSit .AND. __F645ALTS 
							DbSelectArea("SE1")
							SE1->(dbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
							If SE1->(MsSeek(oModelTit:GetValue("FJZ_FILTIT") + oModelCli:GetValue("FJY_CLIENT") + oModelCli:GetValue("FJY_LOJA")+ oModelTit:GetValue("FJZ_PREFIX") + oModelTit:GetValue("FJZ_NUM") + oModelTit:GetValue("FJZ_PARCEL") + oModelTit:GetValue("FJZ_TIPO")  ))
								RecLock("SE1",.F.)
									SE1->E1_SITUACA := oModelTit:GetValue("FJZ_SITPDD")
								SE1->(MsUnlock())
							EndIF
						EndIf
						//Somente gravo log para titulos selecionados
						If oModelTit:GetValue("FJZ_OK")
							ProcLogIni({},cIdDoc," ",@cIdCV8,cFilOrigem)
							ProcLogAtu("MENSAGEM",cMsg,cMsg,,.F.,cFilOrigem)
						Endif
					Next nTitulo
				Next nCliente
				oModelMaster:SetValue('FJX_STATUS','2')
				oModelMaster:SetValue('FJX_DTEFET',dDataBase)
				FWFormCommit( oModel )
			End Transaction
		EndIf
	ElseIf lAlteracao
		FWFormCommit( oModel )
	EndIf
Endif

ProcLogIni({},"FJX" + cChave," ",@cIdCV8)
ProcLogAtu("FIM",cMsg + " - " + cChave,,,.F.)

cFilAnt := cFilBkp
RestArea(aAreaSM0)

Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Situ
Função para alterar a situação do título

@author Thiago Murakami
@since   09/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645Situ(oModel)

Local aArea			:= GetArea()
Local aAreaFJX		:= FJX->(GetArea())
Local aAreaFJY		:= FJY->(GetArea())
Local aAreaFJZ		:= FJZ->(GetArea())
Local aAreaFWZ		:= FWZ->(GetArea())
Local aAreaSM0		:= SM0->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaBM1		:= BM1->(GetArea())
Local lRet			:= .T.
Local cPrefixo		:= "" 
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
Local cFilTit		:= ""
Local cFilBkp		:= cFilAnt
Local cProc			:= FJX->FJX_PROC
Local cFilFJZ		:= xFilial("FJZ")
Local cFilFJY		:= xFilial("FJY")
Local cFilFWZ		:= xFilial("FWZ")
//Variaveis para contabilizacao
Local cLote			:= LoteCont("FIN")
Local cArquivo		:= ""
Local lLancPad		:= .F.
Local nHdlPrv		:= 0
Local nTotal		:= 0
local nI			:= 0
Local lMostrLanc	:= .T.
Local lAglutLanc	:= .T.
Local cFilX			:= ""
Local cStaTit		:= ""
Local lEfetiva		:= FwIsInCallStack("FA645Efe")
Local lEfeRev  		:= FwIsInCallStack("FA645EfRev")
Local lPadPDD		:= .F.
Local lPadRat		:= .F.
Local lPadPLS		:= .F.
local lSISPLS       := .f.
local cChvTIT		:= ''
Local cPadPDD		:= ''
Local cPadRat		:= ''
local cPadPLS       := ''
local cError		:= ''
Local dDataAux		:= dDataBase
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. , .F. ) 
Local aFlagCTB		:= {}
local aMatTIT		:= {}

Pergunte("FINA645D", .f.) 
lMostrLanc	:= MV_PAR01 == 1	
lAglutLanc	:= MV_PAR02 == 1

FJX->(dbSetOrder(1))//FJX_FILIAL+FJX_PROC
FJY->(dbSetOrder(1))//FJY_FILIAL+FJY_PROC+FJY_ITEM+FJY_FILCLI+FJY_CLIENT+FJY_LOJA
FJZ->(dbSetOrder(3))//FJZ_FILIAL+FJZ_PROC+FJZ_FILTIT+FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO+FJZ_ITCLI+FJZ_ITEM 
FWZ->(dbSetOrder(1))//FWZ_FILIAL+FWZ_PROC+FWZ_ITCLI+FWZ_ITTIT+FWZ_DOC+FWZ_SERIE+FWZ_ITEM                                                                                              
SE1->(dbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SD2->(dbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
BM1->(dbSetOrder(4))//BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP
FI7->(dbSetOrder(2))//FI7_FILIAL+FI7_PRFDES+FI7_NUMDES+FI7_PARDES+FI7_TIPDES+FI7_CLIDES+FI7_LOJDES	

BEGIN TRANSACTION

If FJZ->(MsSeek(cFilFJZ + cProc))

	dDataBase	:= FJX->FJX_DTREF 
	
	While FJZ->(!EOF()) .And. FJZ->(FJZ_FILIAL+FJZ_PROC) == cFilFJZ + cProc
		
		cFilTit		:= FJZ->FJZ_FILTIT
		cItCli		:= FJZ->FJZ_ITCLI
		cItTit		:= FJZ->FJZ_ITEM
		cPrefixo	:= FJZ->FJZ_PREFIX
		cNumero		:= FJZ->FJZ_NUM
		cParcela	:= FJZ->FJZ_PARCEL
		cTipo		:= FJZ->FJZ_TIPO

		If lEfetiva
			cSituac	:= FJZ->FJZ_SITPDD
			cPadPDD	:= "54A"
			cPadRat	:= "54C"
            cPadPLS := "54E"
			cStaTit	:= "2"
		Else
			cSituac	:= FJZ->FJZ_SITUAC
			cPadPDD	:= "54B"
			cPadRat	:= "54D"
            cPadPLS := "54F"
    		cStaTit	:= "4"
		EndIf
		
		If cFilX != xFilial("CT2",cFilTit)
			
			cFilAnt 	:= cFilTit
			cLote		:= LoteCont("FIN")
			lPadPDD		:= VerPadrao(cPadPDD)
			lPadRat		:= VerPadrao(cPadRat)
			lPadPLS		:= VerPadrao(cPadPLS)
			lLancPad	:= lPadPDD .or. lPadRat .or. lPadPLS
			cFilX		:= xFilial("CT2",cFilTit)
			
			If lLancPad
				nHdlPrv	:= HeadProva(cLote,"FINA645",Substr(cUsername,1,6),@cArquivo)
			Endif
			
		EndIf
		
		If FJY->( MsSeek(cFilFJY + cProc + cItCli)   ) .AND. FJY->FJY_OK .And. FJZ->FJZ_OK

			cCliente 	:= FJY->FJY_CLIENT
			cLoja		:= FJY->FJY_LOJA
			
			FJZ->(RecLock("FJZ" , .F.))
				FJZ->FJZ_STATUS := cStaTit
			FJZ->(MsUnlock("FJZ"))
						
			If lEfeRev
				F645FlgRev(cFilTit,cPrefixo,cNumero,cParcela,cTipo)
			EndIf
			
			If SA1->(MsSeek(xFilial("SA1",cFilTit) + cCliente + cLoja ))
				If SE1->(MsSeek(xFilial("SE1",cFilTit) + cCliente + cLoja + cPrefixo + cNumero + cParcela + cTipo  ))
                    //verificacao SIGAPLS
                    If __lPLSFN645
                        lSISPLS := PLSFN645()
                    Endif    

            		RecLock("SE1",.F.)
						SE1->E1_SITUACA := cSituac
					SE1->(MsUnlock())
                    //verificacao SIGAPLS
                    If lSISPLS 
						//verificar se a LP esta ativa
                        If lPadPLS	
							ratGLBPub('SE1')
							// Armazena em aFlagCTB para atualizar no modulo Contabil
							If lUsaFlag  
								aadd( aFlagCTB, {"FJZ_LA", "S", "FJZ", FJZ->( recno() ), 0, 0, 0} )
							Else
								FJZ->(recLock("FJZ" , .f.))
								FJZ->FJZ_LA := "S"
								FJZ->(msUnlock("FJZ"))
							Endif 

							//retorna titulo vinculado a tabela do PLS com liquidacao/reliquidacao ou nao.
							aMatTIT := PLSTITMOV('SE1')

							//processa BM1
							If len(aMatTIT) > 0
								For nI := 1 to len(aMatTIT)
									cChvTIT := aMatTIT[nI]
									If BM1->( msSeek( xFilial('BM1') + cChvTIT ) )
										//roda todas as BM1 do titulo PLS
										While ! BM1->(eof()) .and. xFilial('BM1') + cChvTIT == BM1->(BM1_FILIAL + BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT)
											nTotal += detProva(nHdlPrv, cPadPLS, "FINA645", cLote,/*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, { "BM1", BM1->(recno()) }, /*aDadosProva*/ )
											BM1->(dbSkip())
										EndDo
									Endif
								Next nI
							Else
								cError := 'Inconsistencia de base - [BM1/SE1]'
								FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cError, 0, 0, {})
								PlGrvlog(cError, 'PDD', 1)
							Endif
						Else
							cError := 'LP do SIGAPLS nao programadas - [54E/54F]'
							FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cError, 0, 0, {})
							PlGrvlog(cError, 'PDD-LP', 1)
                        Endif
                    else
                        If lPadPDD
                            If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
                                aAdd( aFlagCTB, {"FJZ_LA", "S", "FJZ", FJZ->( Recno() ), 0, 0, 0} )
                            Else
                                FJZ->(RecLock("FJZ" , .F.))
                                FJZ->FJZ_LA := "S"
                                FJZ->(MsUnlock("FJZ"))
                            Endif 
                            
                            nTotal += DetProva(nHdlPrv, cPadPDD, "FINA645", cLote,/*nLinha*/, /*lExecuta*/,;
                                        /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
                                        /*lPosiciona*/, @aFlagCTB, {"FJZ",FJZ->(Recno())}, /*aDadosProva*/ )
                        EndIf
                        
                        If FWZ->( MsSeek(cFilFWZ + cProc + cItCli + cItTit) ) .and. lPadRat
                            
                            While FWZ->(!EOF()) .And. FWZ->(FWZ_FILIAL+FWZ_PROC+FWZ_ITCLI+FWZ_ITTIT) == cFilFWZ + cProc + cItCli + cItTit
                                
                                cDoc	:= FWZ->FWZ_DOC
                                cSerie	:= FWZ->FWZ_SERIE
                                cProd	:= FWZ->FWZ_CODPRO
                                cItemNF := FWZ->FWZ_ITEM

                                If SD2->(MsSeek(xFilial("SD2",cFilTit) + cDoc + cSerie + cCliente + cLoja + cProd + cItemNF  ))
                                    If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
                                        aAdd( aFlagCTB, {"FWZ_LA", "S", "FWZ", FWZ->( Recno() ), 0, 0, 0} )
                                    Else
                                        FWZ->(RecLock("FWZ" , .F.))
                                        FWZ->FWZ_LA := "S"
                                        FWZ->(MsUnlock("FWZ"))
                                    Endif
                                    
                                    nTotal += DetProva(nHdlPrv, cPadRat, "FINA645", cLote,/*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, {"FWZ",FWZ->(Recno())}, /*aDadosProva*/ )
                                EndIf                                
                            	FWZ->(dbSkip())
                            EndDo
                        Endif
                    Endif    
				Endif
			Endif
		Endif
		
		FJZ->(dbSkip())
		
		cFilTit := FJZ->FJZ_FILTIT
		
		//Caso seja o ultimo regitro ou mudou de filial fecha a contabilização
		If lLancPad
			If FJZ->(EOF()) .OR. (FJZ->(FJZ_FILIAL+FJZ_PROC) != cFilFJZ + cProc) .Or. ( cFilX != xFilial("CT2",cFilTit) )
				FA645CAIN(cFilFJZ, cProc, cFilX, cFilTit, @nHdlPrv, @nTotal, @cArquivo, cLote, lMostrLanc, lAglutLanc, aFlagCTB)
			EndIf
		EndIf
				
	EndDo
EndIf

END TRANSACTION

cFilAnt	  := cFilBkp
dDataBase := dDataAux
RestArea(aAreaSE1)
RestArea(aAreaSD2)
RestArea(aAreaSM0)
RestArea(aAreaFWZ)
RestArea(aAreaFJZ)
RestArea(aAreaFJY)
RestArea(aAreaFJX)
RestArea(aAreaBM1)
RestArea(aArea) 

Return lRet

/*/{Protheus.doc} FA645CAIN
Executa a contabilização 

@author Francisco Oliveira
@since 01/08/2019
@version 12
/*/

Static Function FA645CAIN(cFilFJZ, cProc, cFilX, cFilTit, nHdlPrv, nTotal, cArquivo, cLote, lMostrLanc, lAglutLanc, aFlagCTB)

If nHdlPrv > 0 .and. nTotal > 0
	RodaProva(nHdlPrv, nTotal)
	cA100Incl(cArquivo, nHdlPrv, 3, cLote, lMostrLanc, lAglutLanc, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB)

	If Select("TMP") > 0                               
		TMP->( dbCloseArea() )
	EndIf

	cArquivo := ""
	nHdlPrv	 := 0
	nTotal   := 0
EndIf

Return

/*/{Protheus.doc} FA645QrySi
Provisão para Devedores Duvidosos

@author Thiago.Murakami
@since 23/03/2015
@version 12
/*/
Static Function FA645QrySi(cFilCli, cCliente, cLoja, lVerBas)

Local cNextAlias	:= ""
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")

Default lVerBas := .F.

If lConstituicao
	cNextAlias := FA645TiCon(cFilCli, cCliente, cLoja, lVerBas)
ElseIf lReversao
	cNextAlias := FA645TiRev(cFilCli, cCliente, cLoja, lVerBas)
EndIf

Return (cNextAlias)

//-----------------------------------------------------------
/*/{Protheus.doc} FA645TiRev
Títulos na Revisão do PDD

@author Alvaro Camillo Neto
@since 26/08/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645TiRev(cFilCli, cCliente, cLoja, lVerBas)

Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''
Local cWherePE		:= ""
Local cFilWhe		:= GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1)

Default lVerBas		:= .F.

If __F645TITF
	cWherePE := ExecBlock("F645TITF",.F.,.F.,{'2'})
Endif

Pergunte("FINA645E", .F.)

cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_FILIAL, E1_FILORIG, E1_NUM, E1_CLIENTE,  "
cQuery += " E1_LOJA, E1_EMISSAO, E1_VENCREA,E1_VENCTO, "
cQuery += " E1_SALDO, E1_VALOR, E1_PREFIXO, E1_PARCELA, "
cQuery += " E1_TIPO, E1_SITUACA ,FJZ_PROC, FJZ_QTDATR,FJZ_SITUAC,FJZ_SLDBRT,FJZ_SITPAI, "
cQuery += " FJZ_SITPDD , FJZ_SALDO , FJZ_VENCTO ,FJZ_VENCRE,FJZ_VALOR,FJZ_QTDARE,  "
cQuery += " E1_SDACRES,E1_SDDECRE,E1_MOEDA,E1_TITPAI,'1' TIPO  "
cQuery += " FROM " + RetSqlName("SE1") + " SE1PAI "
cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON "
cQuery += "  FRV_FILIAL = '" + xFilial("FRV") + "' AND  "
cQuery += "  FRV_CODIGO = E1_SITUACA AND  "
cQuery += "  FRV_SITPDD =  '1'  AND "
cQuery += "  FRV.D_E_L_E_T_ = ' '  "
cQuery += " INNER JOIN " + RetSqlName("FJZ") + " FJZ ON "
cQuery += "     FJZ_FILIAL = '" + xFilial("FJZ") + "' AND "
cQuery += "     FJZ_FILTIT = E1_FILORIG AND "
cQuery += "     FJZ_PREFIX = E1_PREFIXO AND "
cQuery += "     FJZ_NUM    = E1_NUM     AND "
cQuery += "     FJZ_PARCEL = E1_PARCELA AND "
cQuery += "     FJZ_TIPO   = E1_TIPO    AND "
cQuery += "     FJZ_STATUS = '2'        AND "
If MV_PAR01 == 3 //títulos em aberto
	cQuery += " FJZ_VENCTO = E1_VENCTO  AND "
	cQuery += " FJZ_VENCRE = E1_VENCREA AND "
EndIf 
cQuery += "     FJZ.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName("FJX") + " FJX ON "
cQuery += "     FJX_FILIAL = FJZ_FILIAL AND "
cQuery += "     FJX_PROC   = FJZ_PROC AND "
cQuery += "     FJX.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "
cQuery += " SE1PAI.D_E_L_E_T_ = ' ' "
If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
	cQuery += " AND SE1PAI.E1_TIPO NOT IN " + FormatIn(MVRECANT + "|" + MV_CRNEG + "|" + MVABATIM + "|" + MVPROVIS,"|")
EndIf

If !lVerBas
	cQuery += " AND E1_CLIENTE 	= '" + cCliente + "' " + CRLF
	cQuery += " AND E1_LOJA	    = '" + cLoja    + "' " + CRLF
Else
	cQuery += " AND E1_CLIENTE BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'" + CRLF
	cQuery += " AND E1_LOJA    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "'" + CRLF
Endif

cQuery += " AND E1_FILIAL 	" + cFilWhe 
cQuery += " AND FJX_DTREF BETWEEN	'" + DTOS(MV_PAR08) + "'	AND '" + DTOS(MV_PAR09)	+ "' "

If MV_PAR01 == 2 // Apenas Baixados/Prorrogados/Renegociados/Liquidados
	cQuery += "  AND  "
	cQuery += "  ( "
	cQuery += "  FJZ_SLDBRT <> E1_SALDO OR "
	cQuery += "  FJZ_VENCTO <> E1_VENCTO OR "
	cQuery += "  FJZ_VENCRE <> E1_VENCREA "
	cQuery += "  ) "
EndIf

If Valtype(cWherePE) == "C" .And. !Empty(cWherePE)
	cQuery += cWherePE 
EndIf

cQuery += "  UNION "

cQuery += "  SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_FILIAL, E1_FILORIG, E1_NUM, E1_CLIENTE, "
cQuery += "   E1_LOJA, E1_EMISSAO, E1_VENCREA,E1_VENCTO, "
cQuery += "   E1_SALDO, E1_VALOR, E1_PREFIXO, E1_PARCELA, "
cQuery += "   E1_TIPO, E1_SITUACA ,FJZ_PROC, FJZ_QTDATR,FJZ_SITUAC,FJZ_SLDBRT,FJZ_SITPAI, "
cQuery += "   FJZ_SITPDD , FJZ_SALDO , FJZ_VENCTO ,FJZ_VENCRE,FJZ_VALOR,FJZ_QTDARE, "
cQuery += "   E1_SDACRES,E1_SDDECRE,E1_MOEDA,E1_TITPAI,'2' TIPO "
cQuery += "   FROM " + RetSqlName("SE1") + " SE1ABT "
cQuery += "   INNER JOIN " + RetSqlName("FJZ") + " FJZ ON "
cQuery += "       FJZ_FILIAL = '" + xFilial("FJZ") + "' AND  "
cQuery += "       FJZ_FILTIT = E1_FILORIG AND  "
cQuery += "       FJZ_PREFIX = E1_PREFIXO AND "
cQuery += "       FJZ_NUM    = E1_NUM AND  "
cQuery += "       FJZ_PARCEL = E1_PARCELA AND "
cQuery += "       FJZ_TIPO   = E1_TIPO AND  "
If MV_PAR01 == 3 //títulos em aberto
	cQuery += "   FJZ_VENCTO = E1_VENCTO AND "
	cQuery += "   FJZ_VENCRE = E1_VENCREA AND "
EndIf 
cQuery += "       FJZ_STATUS = '2' AND  "
cQuery += "       FJZ.D_E_L_E_T_ = ' '  "
cQuery += "   WHERE  "
cQuery += "   SE1ABT.D_E_L_E_T_ = ' '  "
If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
	cQuery += " AND SE1ABT.E1_TIPO IN " + FormatIn(MVRECANT+"|" + MV_CRNEG + "|" + MVABATIM + "|"+MVPROVIS,"|")
EndIf

If !lVerBas
	cQuery += " AND E1_CLIENTE 	= '" + cCliente + "' " + CRLF
	cQuery += " AND E1_LOJA	    = '" + cLoja    + "' " + CRLF
Else
	cQuery += " AND E1_CLIENTE BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'" + CRLF
	cQuery += " AND E1_LOJA    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "'" + CRLF
Endif

cQuery += " AND E1_FILIAL 	" + cFilWhe 

cQuery += "   AND SE1ABT.E1_TITPAI IN "
cQuery += "   ( "
cQuery += " SELECT E1_PREFIXO||E1_NUM||E1_PARCELA||E1_TIPO||E1_CLIENTE||E1_LOJA TITPAI "
cQuery += "   FROM " + RetSqlName("SE1") + " SE1SUB  "
cQuery += "   INNER JOIN " + RetSqlName("FRV") + " FRV ON  "
cQuery += "    FRV_FILIAL = '"+xFilial("FRV")+"' AND  "
cQuery += "    FRV_CODIGO = E1_SITUACA AND   "
cQuery += "    FRV_SITPDD =  '1'  AND  "
cQuery += "    FRV.D_E_L_E_T_ = ' '   "
cQuery += "   INNER JOIN " + RetSqlName("FJZ") + " FJZ ON  "
cQuery += "       FJZ_FILIAL = '"+xFilial("FJZ")+"' AND  "
cQuery += "       FJZ_FILTIT = E1_FILORIG AND  "
cQuery += "       FJZ_PREFIX = E1_PREFIXO AND  "
cQuery += "       FJZ_NUM    = E1_NUM AND  "
cQuery += "       FJZ_PARCEL = E1_PARCELA AND  "
cQuery += "       FJZ_TIPO   = E1_TIPO AND  "
cQuery += "       FJZ_STATUS = '2' AND  "
If MV_PAR01 == 3 //títulos em aberto
	cQuery += "   FJZ_VENCTO = E1_VENCTO AND "
	cQuery += "   FJZ_VENCRE = E1_VENCREA AND "
EndIf 
cQuery += "       FJZ.D_E_L_E_T_ = ' '  "
cQuery += "   INNER JOIN " + RetSqlName("FJX") + " FJX ON  "
cQuery += "       FJX_FILIAL = FJZ_FILIAL AND  "
cQuery += "       FJX_PROC   = FJZ_PROC AND  "
cQuery += "       FJX.D_E_L_E_T_ = ' '  "


cQuery += "   WHERE  "
cQuery += "   SE1SUB.D_E_L_E_T_ = ' '  "
If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
	cQuery += " AND SE1SUB.E1_TIPO NOT IN " + FormatIn(MVRECANT + "|" + MV_CRNEG + "|" + MVABATIM + "|"+MVPROVIS,"|")
EndIf

If !lVerBas
	cQuery += " AND E1_CLIENTE 	= '" + cCliente + "' " + CRLF
	cQuery += " AND E1_LOJA	    = '" + cLoja    + "' " + CRLF
Else
	cQuery += " AND E1_CLIENTE BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'" + CRLF
	cQuery += " AND E1_LOJA    BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "'" + CRLF
Endif
cQuery += " AND E1_FILIAL 	" + cFilWhe 
cQuery += " AND FJX_DTREF BETWEEN	'"	+ DTOS(MV_PAR08) + "'	AND '" + DTOS(MV_PAR09)	+ "' "

If MV_PAR01 == 2 // Apenas Baixados/Prorrogados/Renegociados/Liquidados
	cQuery += "  AND  "
	cQuery += "  ( "
	cQuery += "   FJZ_SLDBRT <> E1_SALDO OR "
	cQuery += "   FJZ_VENCTO <> E1_VENCTO OR "
	cQuery += "   FJZ_VENCRE <> E1_VENCREA "
	cQuery += "   ) "
EndIf

If Valtype(cWherePE) == "C" .And. !Empty(cWherePE)
	cQuery += cWherePE 
EndIf

cQuery += "   ) "
cQuery += " ORDER BY E1_FILORIG,E1_PREFIXO, E1_NUM, E1_PARCELA,E1_TITPAI, E1_TIPO "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

TcSetField(cNextAlias, "E1_EMISSAO", "D", 8, 0)
TcSetField(cNextAlias, "E1_VENCREA", "D", 8, 0)
TcSetField(cNextAlias, "E1_VENCTO" , "D", 8, 0)
TcSetField(cNextAlias, "E1_BAIXA"  , "D", 8, 0)
TcSetField(cNextAlias, "FJZ_VENCTO", "D", 8, 0)
TcSetField(cNextAlias, "FJZ_VENCRE", "D", 8, 0)

RestArea(aArea)

Return (cNextAlias)
//-----------------------------------------------------------
/*/{Protheus.doc} FA645TiCon
Títulos na Constuição do PDD

@author Alvaro Camillo Neto
@since 26/08/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645TiCon(cFilCli, cCliente, cLoja, lVerBas)

Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''
Local dDataRef		:= SToD("")
Local dDtAtraso		:= SToD("")
Local cParVenc		:= AllTrim(SuperGetMV( 'MV_PDDREF ' ,.F., '1' ))
Local cCpoVenc		:= IIF(cParVenc == '1', "E1_VENCREA" , Iif(cParVenc == '2', "E1_VENCTO" , "E1_VENCORI"))
Local cWherePE		:= ""
Local cPerg			:= "FINA645C"
Local lF645QYDT		:= ExistBlock("F645QYDT")
Local lF645QYABT	:= ExistBlock("F645QYABT")
Local cFilWhe		:= FinSelFil( __aSelFil, "SE1", .T.)
Local cFilAuto		:= IIF(TYPE("cFilAuto") == "U","",cFilAuto)
Local lFilAuto		:= .F.
Default lVerBas		:= .F.

//AJUSTE PARA AUTOMATIZAR COM SELEÇÃO DE FILIAIS
IF !EMPTY(cFilAuto)
	cFilWhe		:= cFilAuto
	lFilAuto	:= .T.
ENDIF

If Select(cNextAlias) > 0
	(cNextAlias)->(DbCloseArea())
EndIf

If __F645TITF
	cWherePE := ExecBlock("F645TITF",.F.,.F.,{'1'})
Endif

Pergunte(cPerg, .F.)
MakeSqlExpr(cPerg)

dDataRef	:= MV_PAR01
dDtAtraso	:= MV_PAR01 - MV_PAR02 //Data de referencia - quantidade de dias de atraso

If MV_PAR13 == 2 // Regra padrão desconsiderando renegociados

	cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO," + CRLF
	cQuery += " E1_VENCREA,E1_VALOR,E1_SALDO,E1_SITUACA,E1_MOEDA,E1_FILORIG,E1_SDACRES,E1_SDDECRE," + CRLF
	cQuery += " E1_TITPAI,'1' TIPO, E1_VENCORI " + CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1PAI " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON " + CRLF
	cQuery += " FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND " + CRLF
	cQuery += " FRV.FRV_CODIGO = SE1PAI.E1_SITUACA AND " + CRLF
	cQuery += " FRV.FRV_SITPDD <>  '1' AND " + CRLF
	cQuery += " FRV.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " SE1PAI.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF

	If !lVerBas
		cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
		cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
	Else
		cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
		cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
	Endif	


	If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
		cQuery += " AND SE1PAI.E1_TIPO NOT IN " + FormatIn(MVRECANT + "|" + MV_CRNEG + "|" + MVABATIM + "|" + MVPROVIS,"|") + CRLF
	EndIf
	
	//Ponto de entrada para tratamento de datas de seleção de títulos, vencidos apos atraso
	If !lF645QYDT
		If MV_PAR03 == 2
			cQuery += " AND SE1PAI." + cCpoVenc + " <= '" + DToS(dDataRef)  + "' " + CRLF //Só os vencidos e vencidos a mais de 90 dias	
		ElseIf MV_PAR03 == 3
			cQuery += " AND SE1PAI." + cCpoVenc + " <= '" + DToS(dDataRef)  + "' " + CRLF //Só os vencidos e vencidos a mais de 90 dias	
			cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		EndIf
	Else
		cQuery +=  ExecBlock("F645QYDT",.F.,.F., cQuery) + CRLF
	EndIf
	
	cQuery += " AND SE1PAI.E1_SALDO > 0 " + CRLF

	If MV_PAR03 = 1
		cQuery += " AND SE1PAI." + cCpoVenc + " < '" + Dtos(dDtAtraso)  + "' " + CRLF 
		cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
	Endif
	
	If !Empty(__cSitCob)
		cQuery += " AND SE1PAI." + __cSitCob + CRLF
	EndIf
	
	cQuery += " AND SE1PAI.E1_NUMLIQ  = ' ' " + CRLF
	If lFilAuto
		cQuery += " AND SE1PAI.E1_FILORIG " + cFilWhe + " " + CRLF
	Else
		cQuery += " AND SE1PAI." + cFilWhe + " " + CRLF
	Endif

	cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF

	If __lBAIXPDD

		If MV_PAR03 == 1
			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
			cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		ElseIf MV_PAR03 == 2
			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
			cQuery += " AND SE1PAI." + cCpoVenc + " <= '" + DTOS(dDtAtraso) + "' " + CRLF
		ElseIf MV_PAR03 == 3
			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
			cQuery += " AND SE1PAI." + cCpoVenc + " < '" + DTOS(dDtAtraso) + "' " + CRLF
		Endif

		cQuery += " AND SE1PAI.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF
		
		If lFilAuto
			cQuery += " AND SE1PAI.E1_FILORIG " + cFilWhe + " " + CRLF
		Else
			cQuery += " AND SE1PAI." + cFilWhe + " " + CRLF
		Endif

		cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " AND SE1PAI.E1_NUMLIQ  = ' ' " + CRLF
		cQuery += " AND SE1PAI.E1_SITUACA  = FRV.FRV_CODIGO " + CRLF
		cQuery += " AND FRV.FRV_SITPDD <>  '1' " + CRLF
		If !Empty(__cSitCob)
			cQuery += " AND SE1PAI." + __cSitCob + CRLF
		EndIf
		If !lVerBas
			cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "'  " + CRLF
			cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' )" + CRLF
		Else
			cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'  " + CRLF
			cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' )" + CRLF
		Endif
	Endif
	
	If Valtype(cWherePE) == "C" .And. !Empty(cWherePE) 
		cQuery += cWherePE	+ CRLF
	EndIf
	
	If MV_PAR03 = 1
		cQuery += " UNION " + CRLF
		cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO," + CRLF
		cQuery += " E1_VENCREA,E1_VALOR,E1_SALDO,E1_SITUACA,E1_MOEDA,E1_FILORIG,E1_SDACRES,E1_SDDECRE," + CRLF
		cQuery += " E1_TITPAI,'1' TIPO, E1_VENCORI " + CRLF
		cQuery += " FROM " + RetSqlName("SE1") + " SE1PAI " + CRLF
		cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON " + CRLF
		cQuery += " FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND " + CRLF
		cQuery += " FRV.FRV_CODIGO = SE1PAI.E1_SITUACA AND " + CRLF
		cQuery += " FRV.FRV_SITPDD <>  '1' AND " + CRLF
		cQuery += " FRV.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += " SE1PAI.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF

		If !lVerBas
			cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
			cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
		Else
			cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
			cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
		Endif	


		If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
			cQuery += " AND SE1PAI.E1_TIPO NOT IN " + FormatIn(MVRECANT + "|" + MV_CRNEG + "|" + MVABATIM + "|" + MVPROVIS,"|") + CRLF
		EndIf
		
		//Ponto de entrada para tratamento de datas de seleção de títulos, vencidos apos atraso
		If lF645QYDT
			cQuery +=  ExecBlock("F645QYDT",.F.,.F., cQuery) + CRLF
		EndIf
		
		cQuery += " AND SE1PAI.E1_SALDO > 0 " + CRLF
		cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		cQuery += " AND SE1PAI." + cCpoVenc + " >= '" + Dtos(dDtAtraso)  + "' " + CRLF 

		If !Empty(__cSitCob)
			cQuery += " AND SE1PAI." + __cSitCob + CRLF
		EndIf
		
		cQuery += " AND SE1PAI.E1_NUMLIQ  = ' ' " + CRLF
		
		If lFilAuto
			cQuery += " AND SE1PAI.E1_FILORIG " + cFilWhe + " " + CRLF
		Else
			cQuery += " AND SE1PAI." + cFilWhe + " " + CRLF
		Endif

		cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF

		If __lBAIXPDD

			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF

			cQuery += " AND SE1PAI.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF
			
			If lFilAuto
				cQuery += " AND SE1PAI.E1_FILORIG " + cFilWhe + " " + CRLF
			Else
				cQuery += " AND SE1PAI." + cFilWhe + " " + CRLF
			Endif

			cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += " AND SE1PAI.E1_NUMLIQ  = ' ' " + CRLF
			cQuery += " AND SE1PAI.E1_SITUACA  = FRV.FRV_CODIGO " + CRLF
			cQuery += " AND FRV.FRV_SITPDD <>  '1' " + CRLF
			If !Empty(__cSitCob)
				cQuery += " AND SE1PAI." + __cSitCob + CRLF
			EndIf
			If !lVerBas
				cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "'  " + CRLF
				cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' )" + CRLF
			Else
				cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'  " + CRLF
				cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' )" + CRLF
			Endif
		Endif
		
		If Valtype(cWherePE) == "C" .And. !Empty(cWherePE) 
			cQuery += cWherePE	+ CRLF
		EndIf
	Endif

	//ABATIMENTOS
	cQuery += " UNION " + CRLF
	cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO," + CRLF
	cQuery += " E1_VENCREA,E1_VALOR,E1_SALDO,E1_SITUACA,E1_MOEDA,E1_FILORIG,E1_SDACRES,E1_SDDECRE," + CRLF
	cQuery += " E1_TITPAI,'2' TIPO, E1_VENCORI " + CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1ABT " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " SE1ABT.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF
	
	If !lVerBas
		cQuery += " AND SE1ABT.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
		cQuery += " AND SE1ABT.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
	Else
		cQuery += " AND SE1ABT.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
		cQuery += " AND SE1ABT.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
	Endif	

	If mv_par03 == 1
		cQuery += " AND SE1ABT.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
	EndIf
	
	cQuery += " AND SE1ABT.E1_TITPAI IN " + CRLF
	cQuery += " ( "  + CRLF
	cQuery += " SELECT E1_PREFIXO||E1_NUM||E1_PARCELA||E1_TIPO||E1_CLIENTE||E1_LOJA TITPAI " + CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1SUB " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON " + CRLF
	cQuery += " FRV_FILIAL = '"+xFilial("FRV")+"' AND " + CRLF
	cQuery += " FRV_CODIGO = SE1SUB.E1_SITUACA AND " + CRLF
	cQuery += " FRV_SITPDD <>  '1' AND " + CRLF
	cQuery += " FRV.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " SE1SUB.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF

	If !lVerBas
		cQuery += " AND SE1SUB.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
		cQuery += " AND SE1SUB.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
	Else
		cQuery += " AND SE1SUB.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
		cQuery += " AND SE1SUB.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
	Endif	
	
	If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
		cQuery += " AND SE1SUB.E1_TIPO NOT IN " + FormatIn(MVRECANT+"|"+MV_CRNEG+"|"+MVABATIM+"|"+MVPROVIS,"|") + CRLF
	EndIf
	
	//Ponto de entrada para tratamento de datas de seleção de títulos no abatimento, vencidos apos atraso
	If !lF645QYABT
		If mv_par03 == 1
			cQuery += " AND SE1SUB.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		EndIf
		
		If MV_PAR03 == 2
			cQuery += " AND SE1SUB."+cCpoVenc+" < '" + DToS(dDataRef) + "' " + CRLF //Só os vencidos
		ElseIf MV_PAR03 == 3
			cQuery += " AND SE1SUB."+cCpoVenc+" < '" + DToS(dDtAtraso) + "' " + CRLF //Só os vencidos a mais de 90 dias
		EndIf
	Else
		cQuery +=  ExecBlock("F645QYABT",.F.,.F., cQuery) + CRLF
	EndIf	
	
	If !Empty(__cSitCob)
		cQuery += " AND SE1SUB." + __cSitCob + CRLF
	EndIf
	
	cQuery += " AND SE1SUB.E1_SALDO   >  0 " + CRLF

	If lFilAuto
		cQuery += " AND SE1SUB.E1_FILORIG " + cFilWhe + " " + CRLF
	Else
		cQuery += " AND SE1SUB." + cFilWhe + " " + CRLF
	Endif

	cQuery += " AND SE1SUB.D_E_L_E_T_ = ' ' " + CRLF
	
	If Valtype(cWherePE) == "C" .And. !Empty(cWherePE)
		cQuery += cWherePE	+ CRLF
	EndIf
	
	cQuery += " ) " + CRLF
	
	cQuery += " AND SE1ABT.E1_SALDO > 0 " + CRLF

	If lFilAuto
		cQuery += " AND SE1ABT.E1_FILORIG " + cFilWhe + " " + CRLF
	Else
		cQuery += " AND SE1ABT." + cFilWhe + " " + CRLF
	Endif

	cQuery += " AND SE1ABT.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += " ORDER BY E1_FILORIG,E1_PREFIXO, E1_NUM, E1_PARCELA,E1_TITPAI, E1_TIPO" + CRLF
	
	cQuery := ChangeQuery(cQuery)
	
Else //Regra ANS
	cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO,"  + CRLF
	cQuery += " E1_VENCREA,E1_VALOR,E1_SALDO,E1_SITUACA,E1_MOEDA,E1_FILORIG,E1_SDACRES,E1_SDDECRE," + CRLF
	cQuery += " E1_TITPAI,'1' TIPO, E1_VENCORI "  + CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1PAI " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON " + CRLF
	cQuery += " FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND " + CRLF
	cQuery += " FRV.FRV_CODIGO = SE1PAI.E1_SITUACA AND " + CRLF
	cQuery += " FRV.FRV_SITPDD <>  '1' AND " + CRLF
	cQuery += " FRV.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " WHERE " + CRLF

	If !lVerBas
		cQuery += " SE1PAI.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
		cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
	Else
		cQuery += " SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
		cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
	Endif

	If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
		cQuery += " AND SE1PAI.E1_TIPO NOT IN " + FormatIn(MVRECANT+"|"+MV_CRNEG+"|"+MVABATIM+"|"+MVPROVIS,"|") + CRLF
	EndIf
	
	//Ponto de entrada para tratamento de datas de seleção de títulos, vencidos apos atraso
	If !lF645QYDT
		If MV_PAR03 == 1
				cQuery += " AND (SE1PAI." + cCpoVenc+" < '" + DToS(dDtAtraso) + "' " + CRLF //Só os vencidos
				cQuery += " OR SE1PAI.E1_NUMLIQ <> '') "
				cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		ElseIf MV_PAR03 == 2
				cQuery += " AND (" + cCpoVenc+" <= '" + DToS(dDtAtraso) + "' " //Só os vencidos
				cQuery += " OR SE1PAI.E1_NUMLIQ <> '') "
		ElseIf MV_PAR03 == 3
				cQuery += " AND (" + cCpoVenc+" < '" + DToS(dDtAtraso) + "' " //Só os vencidos
				cQuery += " OR SE1PAI.E1_NUMLIQ <> '') "
				cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		EndIf	
	Else
		cQuery +=  ExecBlock("F645QYDT",.F.,.F., cQuery)
	EndIf
		
	cQuery += " AND SE1PAI.E1_SALDO > 0 " + CRLF
		
	If !Empty(__cSitCob)
		cQuery += " AND SE1PAI." + __cSitCob + CRLF
	EndIf
		
	If lFilAuto
		cQuery += " AND SE1PAI.E1_FILORIG " + cFilWhe + " " + CRLF
	Else
		cQuery += " AND SE1PAI." + cFilWhe + " " + CRLF
	Endif

	cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF

	If __lBAIXPDD
		
		If MV_PAR03 == 1
			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
			cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		Endif

		If MV_PAR03 == 2
			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
			cQuery += " AND SE1PAI." + cCpoVenc + "   <= '" + DTOS(dDtAtraso) + "' " + CRLF
		Endif

		If MV_PAR03 == 3
			cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
			cQuery += " AND SE1PAI." + cCpoVenc + "   < '" + DTOS(dDtAtraso) + "' " + CRLF
		Endif

		cQuery += " AND SE1PAI.E1_SITUACA  = FRV.FRV_CODIGO " + CRLF
		cQuery += " AND FRV.FRV_SITPDD <>  '1' " + CRLF
		If !Empty(__cSitCob)
			cQuery += " AND SE1PAI." + __cSitCob + CRLF
		EndIf
		If !lVerBas
			cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
			cQuery += " AND SE1PAI.E1_LOJA	    = '" + cLoja    + "' ) " + CRLF
		Else
			cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
			cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' ) " + CRLF
		Endif
	Endif
	
	If Valtype(cWherePE) == "C" .And. !Empty(cWherePE)
		cQuery += cWherePE	+ CRLF
	EndIf
	
	If MV_PAR03 = 1
		cQuery += " UNION " + CRLF
		cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO," + CRLF
		cQuery += " E1_VENCREA,E1_VALOR,E1_SALDO,E1_SITUACA,E1_MOEDA,E1_FILORIG,E1_SDACRES,E1_SDDECRE," + CRLF
		cQuery += " E1_TITPAI,'1' TIPO, E1_VENCORI " + CRLF
		cQuery += " FROM " + RetSqlName("SE1") + " SE1PAI " + CRLF
		cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON " + CRLF
		cQuery += " FRV.FRV_FILIAL = '"+xFilial("FRV")+"' AND " + CRLF
		cQuery += " FRV.FRV_CODIGO = SE1PAI.E1_SITUACA AND " + CRLF
		cQuery += " FRV.FRV_SITPDD <>  '1' AND " + CRLF
		cQuery += " FRV.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += " SE1PAI.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF

		If !lVerBas
			cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
			cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
		Else
			cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
			cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
		Endif	


		If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
			cQuery += " AND SE1PAI.E1_TIPO NOT IN " + FormatIn(MVRECANT + "|" + MV_CRNEG + "|" + MVABATIM + "|" + MVPROVIS,"|") + CRLF
		EndIf
		
		//Ponto de entrada para tratamento de datas de seleção de títulos, vencidos apos atraso
		If !lF645QYDT
			If MV_PAR03 == 1
				cQuery += " AND (SE1PAI." + cCpoVenc+" >= '" + DToS(dDtAtraso) + "' " + CRLF //Só os vencidos
				cQuery += " OR SE1PAI.E1_NUMLIQ <> '') "
				cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
			ElseIf MV_PAR03 == 2
				cQuery += " AND (" + cCpoVenc+" >= '" + DToS(dDtAtraso) + "' " //Só os vencidos
				cQuery += " OR SE1PAI.E1_NUMLIQ <> '') "
			ElseIf MV_PAR03 == 3
				cQuery += " AND (" + cCpoVenc+" > '" + DToS(dDtAtraso) + "' " //Só os vencidos
				cQuery += " OR SE1PAI.E1_NUMLIQ <> '') "
				cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
			EndIf
		Else
			cQuery +=  ExecBlock("F645QYDT",.F.,.F., cQuery) + CRLF
		EndIf
		
		cQuery += " AND SE1PAI.E1_SALDO > 0 " + CRLF

		If !Empty(__cSitCob)
			cQuery += " AND SE1PAI." + __cSitCob + CRLF
		EndIf

		cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF

		If __lBAIXPDD

			If MV_PAR03 == 1
				cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
				cQuery += " AND SE1PAI.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
			ElseIf MV_PAR03 == 2
				cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
				cQuery += " AND SE1PAI." + cCpoVenc + " <= '" + DTOS(dDtAtraso) + "' " + CRLF
			ElseIf MV_PAR03 == 3
				cQuery += " Or (SE1PAI.E1_SALDO    = 0 AND SE1PAI.E1_BAIXA > '" + DTOS(MV_PAR01) + "'" + CRLF
				cQuery += " AND SE1PAI." + cCpoVenc + " < '" + DTOS(dDtAtraso) + "' " + CRLF
			Endif

			cQuery += " AND SE1PAI.E1_FILIAL 	" + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1) + CRLF

			If lFilAuto
				cQuery += " AND SE1PAI.E1_FILORIG " + cFilWhe + " " + CRLF
			Else
				cQuery += " AND SE1PAI." + cFilWhe + " " + CRLF
			Endif

			cQuery += " AND SE1PAI.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += " AND SE1PAI.E1_NUMLIQ  = ' ' " + CRLF
			cQuery += " AND SE1PAI.E1_SITUACA  = FRV.FRV_CODIGO " + CRLF
			cQuery += " AND FRV.FRV_SITPDD <>  '1' " + CRLF
			If !Empty(__cSitCob)
				cQuery += " AND SE1PAI." + __cSitCob + CRLF
			EndIf
			If !lVerBas
				cQuery += " AND SE1PAI.E1_CLIENTE 	= '" + cCliente + "'  " + CRLF
				cQuery += " AND SE1PAI.E1_LOJA 	    = '" + cLoja    + "' )" + CRLF
			Else
				cQuery += " AND SE1PAI.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'  " + CRLF
				cQuery += " AND SE1PAI.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' )" + CRLF
			Endif
		Endif
		
		If Valtype(cWherePE) == "C" .And. !Empty(cWherePE) 
			cQuery += cWherePE	+ CRLF
		EndIf
	Endif
	
	//ABATIMENTOS
	cQuery += " UNION " + CRLF
	cQuery += " SELECT E1_TIPOLIQ, E1_BAIXA, E1_NUMLIQ, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO," + CRLF
	cQuery += " E1_VENCREA,E1_VALOR,E1_SALDO,E1_SITUACA,E1_MOEDA,E1_FILORIG,E1_SDACRES,E1_SDDECRE," + CRLF
	cQuery += " E1_TITPAI,'2' TIPO, E1_VENCORI " + CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1ABT " + CRLF
	cQuery += " WHERE " + CRLF

	If !lVerBas
		cQuery += " SE1ABT.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
		cQuery += " AND SE1ABT.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
	Else
		cQuery += " SE1ABT.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
		cQuery += " AND SE1ABT.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
	Endif

	If mv_par03 == 1
		cQuery += " AND SE1ABT.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
	EndIf
	
	cQuery += " AND SE1ABT.E1_TITPAI IN " + CRLF
	cQuery += " ( " + CRLF
	cQuery += " SELECT E1_PREFIXO||E1_NUM||E1_PARCELA||E1_TIPO||E1_CLIENTE||E1_LOJA TITPAI " + CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1SUB " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("FRV") + " FRV ON " + CRLF
	cQuery += " FRV_FILIAL = '"+xFilial("FRV")+"' AND " + CRLF
	cQuery += " FRV_CODIGO = SE1SUB.E1_SITUACA AND " + CRLF
	cQuery += " FRV_SITPDD <>  '1' AND " + CRLF
	cQuery += " FRV.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " WHERE " + CRLF

	If !lVerBas
		cQuery += " SE1SUB.E1_CLIENTE 	= '" + cCliente + "' " + CRLF
		cQuery += " AND SE1SUB.E1_LOJA 	    = '" + cLoja    + "' " + CRLF
	Else
		cQuery += " SE1SUB.E1_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "'" + CRLF
		cQuery += " AND SE1SUB.E1_LOJA    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'" + CRLF
	Endif

	
	If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
		cQuery += " AND SE1SUB.E1_TIPO NOT IN " + FormatIn(MVRECANT+"|"+MV_CRNEG+"|"+MVABATIM+"|"+MVPROVIS,"|") + CRLF
	EndIf
	
	//Ponto de entrada para tratamento de datas de seleção de títulos no abatimento, vencidos apos atraso
	If !lF645QYABT
		If mv_par03 == 1
			cQuery += " AND SE1SUB.E1_EMISSAO 	BETWEEN	'" + Dtos(MV_PAR08) + "'	AND '" + Dtos(MV_PAR09) + "' " + CRLF
		EndIf

		If MV_PAR03 == 2
			cQuery += " AND SE1SUB."+cCpoVenc+" < '" + DToS(dDataRef) + "' " + CRLF //Só os vencidos
		ElseIf MV_PAR03 == 3
			cQuery += " AND SE1SUB."+cCpoVenc+" < '" + DToS(dDtAtraso) + "' " + CRLF //Só os vencidos a mais de 90 dias
		EndIf
	Else
		cQuery +=  ExecBlock("F645QYABT",.F.,.F., cQuery)
	EndIf	
	
	If !Empty(__cSitCob)
		cQuery += " AND SE1SUB." + __cSitCob + CRLF
	EndIf
	
	cQuery += " AND SE1SUB.E1_SALDO > 0 " + CRLF

	If lFilAuto
		cQuery += " AND SE1SUB.E1_FILORIG " + cFilWhe + " " + CRLF
	Else
		cQuery += " AND SE1SUB." + cFilWhe + " " + CRLF
	Endif

	cQuery += " AND SE1SUB.D_E_L_E_T_ = ' ' " + CRLF
	
	If Valtype(cWherePE) == "C" .And. !Empty(cWherePE)
		cQuery += cWherePE	+ CRLF
	EndIf
	
	cQuery += " ) " + CRLF
	
	cQuery += " AND SE1ABT.E1_SALDO > 0 " + CRLF

	If lFilAuto
		cQuery += " AND SE1ABT.E1_FILORIG " + cFilWhe + " " + CRLF
	Else
		cQuery += " AND SE1ABT." + cFilWhe + " " + CRLF
	Endif

	cQuery += " AND SE1ABT.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += " ORDER BY E1_FILORIG,E1_PREFIXO, E1_NUM, E1_PARCELA,E1_TITPAI, E1_TIPO" + CRLF
	
	cQuery := ChangeQuery(cQuery)

Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

TcSetField(cNextAlias, "E1_EMISSAO", "D", 8, 0)
TcSetField(cNextAlias, "E1_VENCREA", "D", 8, 0)
TcSetField(cNextAlias, "E1_VENCTO" , "D", 8, 0)
TcSetField(cNextAlias, "E1_VENCORI", "D", 8, 0)
TcSetField(cNextAlias, "E1_BAIXA"  , "D", 8, 0)

RestArea(aArea)

Return (cNextAlias)

//-----------------------------------------------------------
/*/{Protheus.doc} FA645ClRev
Clientes na reversão do PDD

@author Alvaro Camillo Neto
@since 26/08/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645ClRev()

Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''
Local cWherePE 		:= ""

If __F645CLIF
	cWherePE := ExecBlock("F645CLIF",.F.,.F.,{'2'})
Endif

Pergunte("FINA645E", .F.)

cQuery += " SELECT A1_FILIAL, E1_CLIENTE, E1_LOJA, A1_NOME  "
cQuery += "  FROM " + RetSqlName("SE1") + " SE1 "
cQuery += "  INNER JOIN " + RetSqlName("SA1") + " SA1 ON "
cQuery += "  A1_COD = E1_CLIENTE AND  "
cQuery += "  A1_LOJA = E1_LOJA AND  "
cQuery += "  SA1.D_E_L_E_T_ = ' '  "
cQuery += "  INNER JOIN " + RetSqlName("FRV") + " FRV ON "
cQuery += "  FRV_CODIGO = E1_SITUACA AND  "
cQuery += "  FRV_FILIAL = '"+xFilial("FRV")+"' AND  "
cQuery += "  FRV_SITPDD =  '1'  AND "
cQuery += "  FRV.D_E_L_E_T_ = ' '  "
cQuery += " INNER JOIN " + RetSqlName("FJZ") + " FJZ ON "
cQuery += "     FJZ_FILIAL = '"+xFilial("FJZ")+"' AND "
cQuery += "     FJZ_FILTIT = E1_FILORIG AND "
cQuery += "     FJZ_PREFIX = E1_PREFIXO AND "
cQuery += "     FJZ_NUM    = E1_NUM AND "
cQuery += "     FJZ_PARCEL = E1_PARCELA AND "
cQuery += "     FJZ_TIPO   = E1_TIPO AND "
cQuery += "     FJZ_STATUS = '2' AND "
cQuery += "     FJZ.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName("FJX") + " FJX ON "
cQuery += "     FJX_FILIAL = FJZ_FILIAL AND "
cQuery += "     FJX_PROC   = FJZ_PROC AND "
cQuery += "     FJX.D_E_L_E_T_ = ' ' "

cQuery += "  WHERE  "
cQuery += " SE1.D_E_L_E_T_ = ' '  "
cQuery += " AND E1_CLIENTE	BETWEEN	'"	+ MV_PAR02 					+ "' 	AND '" + MV_PAR04						+ "' "
cQuery += " AND E1_LOJA 		BETWEEN	'"	+ MV_PAR03						+ "'	AND '" + MV_PAR05						+ "' "
cQuery += " AND E1_FILIAL 	"  + GetRngFil( __aSelFil, "SE1", .T., @__cTmpSE1)
cQuery += " AND A1_FILIAL 	"  + GetRngFil( __aSelFil, "SA1", .T., @__cTmpSA1)
cQuery += " AND FJX_DTREF BETWEEN	'"	+ DTOS(MV_PAR08) + "'	AND '" + DTOS(MV_PAR09)	+ "' "


If !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .OR. !Empty(MVABATIM) .Or.!Empty(MVPROVIS)
	cQuery += " AND E1_TIPO NOT IN " + FormatIn(MVRECANT+"|"+MV_CRNEG+"|"+MVABATIM+"|"+MVPROVIS,"|")
EndIf
If MV_PAR01 <> 1 // Apenas Baixados/Prorrogados/Renegociados/Liquidados
	
	cQuery += "  AND ("
	cQuery += "E1_FILIAL || '|' || E1_PREFIXO || '|' || E1_NUM || '|' || E1_PARCELA || '|' "
	cQuery += "|| E1_TIPO || '|' ||  E1_CLIENTE || '|' ||  E1_LOJA IN "
	cQuery += "(SELECT FK7_CHAVE FROM " + RetSqlName("FK7") + " FK7 WHERE FK7.FK7_IDDOC "
	If MV_PAR01 == 2
		cQuery += "IN "
	Else
		cQuery += "NOT IN "
	Endif
	cQuery += "(Select FK1_IDDOC FROM " + RetSqlName("FK1") + " FK1A WHERE (FK1A.FK1_DATA BETWEEN	FJX.FJX_DTREF	AND '"+ DTOS(MV_PAR07) + "'"
	cQuery += "		OR	 FK1A.FK1_DATA BETWEEN	FJX.FJX_DTPROC	AND '"+ DTOS(MV_PAR07) + "') "
	cQuery += "		AND FK1A.FK1_IDDOC = FK7.FK7_IDDOC  "
	cQuery += "		AND ( FK1A.FK1_SEQ NOT IN "
	cQuery += "		(SELECT FK1_SEQ FROM " + RetSqlName("FK1") + " FK1B"
	cQuery += "		Where 	 (FK1B.FK1_DATA BETWEEN	FJX.FJX_DTREF	AND '"+ DTOS(MV_PAR07) + "'"
	cQuery += "		OR	 FK1B.FK1_DATA BETWEEN	FJX.FJX_DTPROC	AND '"+ DTOS(MV_PAR07) + "') "
	cQuery += "		AND FK1B.FK1_IDDOC = FK7.FK7_IDDOC "
	cQuery += "		AND FK1B.FK1_TPDOC = 'ES'  AND FK1B.D_E_L_E_T_ = '' )"
	cQuery += "		OR FK1A.FK1_TPDOC = 'ES' )"
	cQuery += "		AND FK1A.D_E_L_E_T_ = '' )"
	If MV_PAR01 == 2
		cQuery += "  AND  "
		cQuery += "  FJZ_SLDBRT <> E1_SALDO ) OR "
		cQuery += "  FJZ_VENCTO <> E1_VENCTO OR "
		cQuery += "  FJZ_VENCRE <> E1_VENCREA "
	Else
		cQuery += "  OR  "
		cQuery += "  FJZ_SLDBRT = E1_SALDO ) AND "
		cQuery += "  FJZ_VENCTO = E1_VENCTO AND "
		cQuery += "  FJZ_VENCRE = E1_VENCREA  "
	Endif
	
	cQuery += "     ) "
	
EndIf

If Valtype(cWherePE) == "C" .And. !Empty(cWherePE)
	cQuery += cWherePE	
EndIf
cQuery += "  GROUP BY A1_FILIAL,E1_CLIENTE, E1_LOJA, A1_NOME  "
cQuery += "  ORDER BY A1_FILIAL,E1_CLIENTE, E1_LOJA, A1_NOME  "

cQuery := ChangeQuery(cQuery)  

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)  

RestArea(aArea)

Return (cNextAlias)

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Simu
Rotina da Provisão do PDD

@author Thiago.Murakami
@since 25/03/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645Simu(aSitCob)

Local aArea			:= GetArea()
Local cTitulo		:= STR0020 //Provisão PDD
Local cPrograma		:= "FINA645"
Local nOperation	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local cAuxPDD		:= "FRV_SITPDD <> '1' "
Local nX			:= 0

Default aSitCob		:= {}

If Pergunte("FINA645C", !lAutomato)
	If MV_PAR10 == 1
		__aSelFil := ADMGETFIL(.F.,.F.,"SE1")
		If Len( __aSelFil ) <= 0
			lRet := .F.
		EndIf
	Else
		__aSelFil := {cFilAnt}
	EndIf
		
	//Seleciona Situação de Cobrança.
	__cSitCob := ""
	If MV_PAR12 == 1                                  
		
		//-------------------------------------------------------------------
		/*/{Protheus.doc} F77GetSit
		Funcao F770GetSit na versao original da CEMIG/TOTVS V12 foi alterada
		Para manter compatibilidade para CEMIG, alterado o nome e disponível
		no FINR645.
		/*/
		//-------------------------------------------------------------------

		__cSitCob	:= F77GetSit('E1_SITUACA',cAuxPDD,.F.)
	Else
		If Len(__cSitCob) > 0
			__cSitCob += "'"
			For nX := 1 To Len(aSitCob)
				If nX < Len(aSitCob)
					__cSitCob += aSitCob[nX] + "','"
				Else
					__cSitCob += aSitCob[nX] + "'"
				Endif
			Next nX
				__cSitCob := " E1_SITUACA IN ("  + __cSitCob + ")"
		Endif
	EndIf
	
	lRet := lRet .And. VldSitPDD(__aSelFil,MV_PAR11)
	If __F645PERG
		ExecBlock("F645PERG",.F.,.F.,{"1"})
	Endif
		
	If lRet
		MsgRun( STR0054, STR0053, {|| ProcPDD(cTitulo , cPrograma, nOperation) } )//"Processando PDD"##"Processamento"
	EndIf
EndIf

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Efe
Realiza a provisão do PDD

@author Thiago Murakami
@since   09/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645Efe(cAlias,nReg,nOpc,cNroProc)

Local aArea			:= GetArea()
Local cTitulo		:= STR0011 //Efetivar
Local cPrograma 	:= 'FINA645'
Local nOperation	:= MODEL_OPERATION_UPDATE

Default cNroProc	:= ""

If lAutomato
	DbSelectArea("FJX")
	FJX->(DbSetOrder(1))
	FJX->(DbGoTop())

	If !FJX->(DbSeek(xFilial("FJX") + cNroProc)) 
		HELP(" ",1,"FA645EfeExec",, STR0073 ,1,0) //"Processo não encontrado em base de dados."
		Return
	Endif
Endif

If FJX->FJX_TIPO != '1' 
	HELP(" ",1,"FA645Efe",,STR0055 ,1,0) //"Operação inválida para esse tipo de provisão"
ElseIf FJX->FJX_STATUS == '1'
	lRet := FA645VerFil(FJX->FJX_PROC)	
	If lRet
		lRet := VldEfetTit(FJX->FJX_FILIAL,FJX->FJX_PROC) 
	Endif
	If lRet 
		If !lAutomato
			FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. })
		Else
			FA645AUTO(cPrograma, nOperation)
		Endif
	EndIf
Else
	HELP(" ",1,"FA645Efe",,STR0031 ,1,0) //"Status não permite essa operação"
EndIf
	
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Alt
Realiza a provisão do PDD

@author Thiago Murakami
@since   09/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645Alt(cAlias,nReg,nOpc, cNroProc, aDdsAlt)

Local aArea			:= GetArea()
Local cTitulo		:= STR0012 //Alterar
Local cPrograma 	:= 'FINA645'
Local nOperation	:= MODEL_OPERATION_UPDATE

If lAutomato
	DbSelectArea("FJX")
	FJX->(DbSetOrder(1))
	FJX->(DbGoTop())

	If !FJX->(DbSeek(xFilial("FJX") + cNroProc)) 
		HELP(" ",1,"FA645EfeExec",, STR0073 ,1,0) //"Processo não encontrado em base de dados."
		Return
	Else
		FA645AUTO(cPrograma, nOperation, aDdsAlt)
	Endif
Else
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. })
Endif

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645EfRev
Efetiva a reversão da provisão do PDD

@author Alvaro Camillo Neto
@since   09/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645EfRev(cAlias,nReg,nOpc, cNroProc)

Local aArea			:= GetArea()
Local cTitulo		:= STR0011 //Efetivar
Local cPrograma 	:= 'FINA645'
Local nOperation	:= MODEL_OPERATION_UPDATE

If lAutomato
	DbSelectArea("FJX")
	FJX->(DbSetOrder(1))
	FJX->(DbGoTop())

	If !FJX->(DbSeek(xFilial("FJX") + cNroProc)) 
		HELP(" ",1,"FA645EfeExec",, STR0073 ,1,0) //"Processo não encontrado em base de dados."
		Return
	Endif
Endif

If FJX->FJX_TIPO != '2' 
	HELP(" ",1,"FA645Efe",,STR0055 ,1,0) //"Operação inválida para esse tipo de provisão"
ElseIf FJX->FJX_STATUS == '1'
	lRet := FA645VerFil(FJX->FJX_PROC)	
	If lRet
		lRet := VldEfetTit(FJX->FJX_FILIAL,FJX->FJX_PROC)
	Endif
	If lRet 
		If !lAutomato
			FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. })
		Else
			FA645AUTO(cPrograma, nOperation)
		Endif
	EndIf
Else
	HELP(" ",1,"FA645Efe",,STR0031 ,1,0) //"Status não permite essa operação"
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldEfetTit
Validação da efetivação da simulação

@author Alvaro Camillo Neto
@since   24/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function VldEfetTit(cFIlProc,cProc) 

Local lRet		:= .T.
Local aArea		:= GetArea()
Local cNextAlias:= GetNextAlias()
Local cFileLog	:= ""
Local cPath		:= ""
Local lEfetiva 	:= FwIsInCallStack("FA645Efe")
Local lEfeRev  	:= FwIsInCallStack("FA645EfRev")
Local cWhere	:= ""

__lAltSit		:= .F.

If Pergunte("FINA645D", !lAutomato)

	If lEfetiva
		cWhere := ' (FJZ_SITUAC <> E1_SITUACA '
	ElseIF lEfeRev
		cWhere := ' (FJZ_SITPDD <> E1_SITUACA '
	EndIf
		
	If MV_PAR03 == 1
		cWhere += 'OR FJZ_VENCTO <> E1_VENCTO OR FJZ_VENCRE <> E1_VENCREA OR FJZ_SLDBRT <> E1_SALDO) '
	Else
		cWhere += ") " 
	EndIf 
	
	cWhere := '%' + cWhere + '%'
	
	BeginSql Alias cNextAlias
		SELECT
			FJZ_OK,
			FJZ_FILTIT,
			FJZ_PREFIX,
			FJZ_NUM,
			FJZ_PARCEL,
			FJZ_TIPO,
			FJZ_VALOR,
			FJZ_SALDO,
			FJZ_VENCTO,
			FJZ_SITUAC,
			FJZ_SITPDD,
			FJZ_SLDBRT,
			FJZ_VENCRE,
			FJY_CLIENT,
			FJY_LOJA,
			E1_EMISSAO,
			E1_VENCTO,
			E1_VENCREA,
			E1_SITUACA,		
			E1_SALDO,
			E1_MOEDA,
			E1_SDACRES,
			E1_SDDECRE
		FROM %table:FJZ%  FJZ
			INNER JOIN %table:FJY% FJY ON
			FJZ_FILIAL=FJY_FILIAL AND
			FJZ_PROC=FJY_PROC AND
			FJZ_ITCLI=FJY_ITEM AND
			FJY.%NotDel%
		INNER JOIN %table:SE1% SE1 ON
			FJZ_PREFIX = E1_PREFIXO AND
			FJZ_NUM = E1_NUM AND
			FJZ_PARCEL = E1_PARCELA AND
			FJZ_TIPO = E1_TIPO AND
			FJY_CLIENT = E1_CLIENTE AND
			FJY_LOJA = E1_LOJA AND
			FJZ_FILTIT = E1_FILORIG AND
			SE1.%NotDel%
		WHERE
			FJZ_FILIAL = %Exp:cFIlProc% AND
			FJZ_OK = 'T' AND
			FJZ_PROC = %Exp:cProc% AND
			FJZ.%NotDel% AND
			%Exp:cWhere%
	EndSql
	
		If (cNextAlias)->(!EOF())
			AutoGrLog(STR0032)//"INICIO DO LOG"
			While (cNextAlias)->(!EOF())
				
				lRet := .F.
				
				AutoGrLog("---------------")
				AutoGrLog(STR0033 + (cNextAlias)->FJZ_FILTIT ) //"Filial Origem : "
				AutoGrLog(STR0034 + (cNextAlias)->FJZ_PREFIX ) //"Prefixo: "
				AutoGrLog(STR0035 + (cNextAlias)->FJZ_NUM    ) //"Número: "
				AutoGrLog(STR0036 + (cNextAlias)->FJZ_PARCEL ) //"Parcela: "
				AutoGrLog(STR0037 + (cNextAlias)->FJZ_TIPO   ) //"Tipo: "
				AutoGrLog(STR0038 + (cNextAlias)->FJY_CLIENT ) //"Cliente: "
				AutoGrLog(STR0039 + (cNextAlias)->FJY_LOJA   ) //"Loja: "
				AutoGrLog(STR0040)//"Inconsistência............."
				
				If (cNextAlias)->FJZ_SLDBRT != (cNextAlias)->E1_SALDO 
					AutoGrLog(STR0041)//"Saldo do título está diferente da simulação."
				EndIf
				
				If (cNextAlias)->FJZ_VENCTO != (cNextAlias)->E1_VENCTO
					AutoGrLog(STR0042)//"Data de vencimento está diferente da simulação."
				EndIf
				
				If (cNextAlias)->FJZ_VENCRE != (cNextAlias)->E1_VENCREA
					AutoGrLog(STR0043)//"Data de vencimento real está diferente da simulação."
				EndIf
				
				If (cNextAlias)->FJZ_SITUAC != (cNextAlias)->E1_SITUACA
					AutoGrLog(STR0044)//"Situação do título está diferente da simulação."
					__lAltSit		:= .T.
				EndIf
				
				AutoGrLog("---------------")
				(cNextAlias)->(dbSkip())
			EndDo	
			AutoGrLog(STR0045)//"FINAL DO LOG"
		
			If !lRet
				HELP(" ",1,"VldEfetTit",,STR0046 ,1,0)//"A simulação não está consistente com a base de dados. Por favor gerar nova simulação."
				cFileLog := NomeAutoLog()
				If cFileLog <> ""
					MostraErro(cPath,cFileLog)
				Endif
				If __lAltSit .and. MV_PAR03 == 2 .AND. lEfetiva
					lRet := MsgYesNo(STR0068)//"Ao efetivar este processo será atualizado a situação de cobrança da constitução. Deseja Continuar?"
			 	Else
					__lAltSit := .F.
				EndIf
			EndIf
		
		Else
	
			If lRet
				(cNextAlias)->(dbCloseArea())
				BeginSql Alias cNextAlias
					SELECT
					COUNT(FJZ_PROC) CONTADOR
					FROM %table:FJZ%  FJZ
					
					WHERE
					FJZ_OK = 'T' AND
					FJZ_FILIAL = %Exp:cFIlProc% AND
					FJZ_PROC = %Exp:cProc% AND
					FJZ.%NotDel%
				EndSql
				If (cNextAlias)->(!EOF())
					If (cNextAlias)->CONTADOR <= 0
						HELP(" ",1,"VldEfetTit2",,STR0056 ,1,0)//"Nenhum título selecionado, por favor selecione através da opção Alterar"			
						lRet := .F.
					EndIf 
				EndIf	
				(cNextAlias)->(dbCloseArea())
			EndIf
		EndIf
Else

	lRet:= .F.
Endif	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Rev
Realiza a reversão do PDD

@author Thiago Murakami
@since   09/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FA645Rev(cAlias,nReg,nOpc, cNroProc)

Local aArea			:= GetArea()
Local cTitulo		:= STR0013 //Reversão
Local cPrograma 	:= 'FINA645'
Local nOperation	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.

Default cNroProc	:= ""

If lAutomato
	DbSelectArea("FJX")
	FJX->(DbSetOrder(1))
	FJX->(DbGoTop())

	If !FJX->(DbSeek(xFilial("FJX") + cNroProc)) 
		HELP(" ",1,"FA645EfeExec",, STR0073 ,1,0) //"Processo não encontrado em base de dados."
		Return
	Endif
Endif

If Pergunte("FINA645E", !lAutomato )
	If MV_PAR06 == 1 
		__aSelFil := ADMGETFIL(.F.,.F.,"SE1")
		If Len( __aSelFil ) <= 0
			lRet := .F.
		EndIf
	Else
		__aSelFil := {cFilAnt}	
	EndIf

	If __F645PERG
		ExecBlock("F645PERG",.F.,.F.,{"2"})
	Endif
	
	If lRet
		MsgRun( STR0054, STR0053, {|| ProcPDD(cTitulo , cPrograma, nOperation) } )//"Processando PDD"##"Processamento"
	EndIf
EndIf
	
RestArea(aArea)

Return

Static Function ProcPDD(cTitulo , cPrograma, nOperation)
	If !lAutomato
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. })
	Else
		FA645AUTO(cPrograma, nOperation)
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Inv
Inverte Cliente e Títulos.

@author Kaique Schiller
@since 08/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Function FA645Inv(cInv)

Local aSaveLines	:= FWSaveRows()
Local oView			:= FWViewActive()
Local oModel		:= FWModelActive()
Local oModelCli 	:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local nLinha        := oModelTit:GetLine()
Local lEfetiva 		:= FwIsInCallStack("FA645Efe")
Local lEfeRev  		:= FwIsInCallStack("FA645EfRev")

Local nOperation 	:= oModel:GetOperation()
Local nX			:= 0

__lRefresh := .F.

If nOperation == MODEL_OPERATION_UPDATE .And. !( lEfetiva .Or. lEfeRev)
	If cInv == "1"
		For nX := 1 to oModelCli:Length()
			oModelCli:GoLine(nX)	
			If !oModelCli:GetValue("FJY_OK")
				oModelCli:SetValue("FJY_OK" , .T. )
			Else
				oModelCli:SetValue("FJY_OK" , .F. )
			Endif
		Next
	Elseif cInv == "2"
		For nX := 1 to oModelTit:Length()
			oModelTit:GoLine(nX)	
			If !oModelTit:GetValue("FJZ_OK")
				oModelTit:SetValue("FJZ_OK" , .T. )
			Else
				oModelTit:SetValue("FJZ_OK" , .F. )
			Endif
		Next
	Endif

	oModelTit:GoLine(nLinha)

	If oView != Nil
		oView:Refresh()
	EndIf
Else
	HELP(" ",1,"FA645Inv",,STR0030 ,1,0) //"Opção bloqueada."
EndIf

__lRefresh := .T.

FWRestRows(aSaveLines)

Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} F645ConSX1
Converte os parametros do SX1 para caractere

@author Totvs
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function F645ConSX1(cPergunta)

Local aSavArea	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local cRetorno	:= ""

Pergunte(cPergunta, .F.)

DbSelectArea("SX1")
SX1->(DbSetOrder(1))
SX1->(DbSeek(cPergunta))
While SX1->(!Eof()) .And. SX1->X1_GRUPO == Padr(cPergunta,Len(X1_GRUPO),' ')
	If	ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "C"
		cRetorno += PadR( SX1->X1_PERGUNT, 30 ) + " : " + &("MV_PAR"+SX1->X1_ORDEM) + CRLF
	ElseIf	ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "D"
		cRetorno += PadR( SX1->X1_PERGUNT, 30 ) + " : " + DToC( &("MV_PAR"+SX1->X1_ORDEM) ) + CRLF
	ElseIf	ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "N"
		cRetorno += PadR( SX1->X1_PERGUNT, 30 ) + " : " + AllTrim(Str( &("MV_PAR"+SX1->X1_ORDEM) )) + CRLF
	EndIf
SX1->( DbSkip() )
EndDo

RestArea(aAreaSX1)
RestArea(aSavArea)

Return(cRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA645SCli
Validação de situação de cobrança do Cliente

@author Alvaro Camillo Neto
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FINA645SCli()

Local lRet   		:= .T.
Local oModel 		:= FWModelActive()
Local oModelFJY		:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local cSituac		:= oModelFJY:GetValue("FJY_SITPDD")
Local nX			:= 0
Local aSaveLines	:= FWSaveRows()

For nX := 1 to oModelTit:Length()
	oModelTit:GoLine(nX)
	cFilTit := oModelTit:GetValue("FJZ_FILTIT")
	aFilSit := {cFilTit} 
	If !VldSitPDD(aFilSit,cSituac)
		lRet := .F.
		Exit
	EndIf
Next nX

FWRestRows(aSaveLines)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN645STit()
Validação de situação de cobrança do Titulo

@author Alvaro Camillo Neto
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FIN645STit()

Local lRet   		:= .F.
Local oModel 		:= FWModelActive()
Local oModelFJZ 	:= oModel:GetModel("FJZDETAIL")
Local cFilTit		:= oModelFJZ:GetValue("FJZ_FILTIT") 
Local cSituac		:= oModelFJZ:GetValue("FJZ_SITPDD")
Local aFilSit		:= {cFilTit}

lRet := VldSitPDD(aFilSit,cSituac)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSitPDD
Validação do Pergunte

@author Thiago Murakami
@since   09/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function VldSitPDD(aFilSit,cSituac)

Local lRet		:= .T.
Local nX		:= 0
Local cFilSit	:= ""
Local aArea		:= GetArea()
Local cFilX		:= ""

FRV->(dbSetOrder(1)) //FRV_FILIAL+FRV_CODIGO  

For nX := 1 to Len(aFilSit)
	
	cFilSit := xFilial("FRV",aFilSit[nX] )
	
	If cFilX != Alltrim(cFilSit)
	
		If FRV->(MsSeek( cFilSit + cSituac))
			If FRV->FRV_SITPDD != '1'
				Help( , ,"FIN645STit",, STR0023 + aFilSit[nX]  , 1, 0 )	//"Situação de cobrança não é de PDD. Por favor verificar cadastro na Filial "
				lRet := .F.
				Exit
			EndIf
		Else
			Help( , ,"FIN645STit1",, STR0028 + aFilSit[nX]  , 1, 0 )	//"Situação de cobrança não cadastrada. Por favor verificar cadastro na Filial "
			lRet := .F.
			Exit
		EndIf
		
		cFilX := cFilSit
		
	EndIf
	
Next nX

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} F645PROINI
Inicializador padrão dos campos de produto e descrição

@author Alvaro Camillo Neto
@since   20/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Function F645PROINI()

Local cRet 			:= ""
Local aArea			:= GetArea()
Local aAreaFJZ		:= FJZ->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local cFilTit		:= "" 
Local lConstituicao	:= FwIsInCallStack("FA645Simu")
Local lReversao		:= FwIsInCallStack("FA645Rev")
Local cProduto		:= ""
Local cProc			:= ""
Local cItCli		:= ""
Local cITTit		:= ""

SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD   
FJZ->(dbSetOrder(1))//FJZ_FILIAL+FJZ_PROC+FJZ_ITCLI+FJZ_ITEM+FJZ_FILTIT+FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO                                                                        

If !lConstituicao .And. !lReversao
	
	cProduto:= FWZ->FWZ_CODPRO
	cProc	:= FWZ->FWZ_PROC
	cItCli	:= FWZ->FWZ_ITCLI
	cITTit	:= FWZ->FWZ_ITTIT
	
	If FJZ->(MsSeek(xFilial("FJZ") + cProc + cItCli + cITTit ))
		cFilTit := FJZ->FJZ_FILTIT
	EndIf
	
	If SB1->(MSSeek( xFilial("SB1",cFilTit) + cProduto ) )
		cRet := SB1->B1_DESC
	EndIf
EndIf

RestArea(aAreaSB1)
RestArea(aAreaFJZ)
RestArea(aArea)
Return cRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} F645MotRev
Retorna o motivo de revisão do título

@author Alvaro Camillo Neto
@since   20/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function F645MotRev(cAliasFJZ)

Local cRevSta := ""


If (cAliasFJZ)->(FJZ_VENCTO != E1_VENCTO)
	cRevSta := "2" //Prorrogação
ElseIf (cAliasFJZ)->(FJZ_VENCRE != E1_VENCREA)
	cRevSta := "2" //Prorrogação
ElseIf (cAliasFJZ)->(FJZ_SLDBRT > E1_SALDO)
	cRevSta := "1" //Baixa
ElseIf (cAliasFJZ)->(FJZ_SLDBRT < E1_SALDO)
	cRevSta := "4" //Cancelamento de Baixa depois da constituição
Else
	cRevSta := "3" //Normal
EndIf

Return cRevSta

//-------------------------------------------------------------------
/*/{Protheus.doc} F645FlgRev
Flag os registros de constituição de PDD como revertidos

@author Alvaro Camillo Neto
@since   20/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function F645FlgRev(cFilTit,cPrefixo,cNumero,cParcela,cTipo)

Local nRecFJZ		:= 0
Local aArea			:= GetArea()
Local aAreaFJZ		:= FJZ->(GetArea())
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''

cQuery += " SELECT  "
cQuery += "     FJZ.R_E_C_N_O_ FJZREC  " 
cQuery += " FROM " + RetSqlName("FJZ") + " FJZ "
cQuery += " WHERE "
cQuery += "     FJZ_FILTIT = '"+cFilTit+"' AND "
cQuery += "     FJZ_PREFIX = '"+cPrefixo+"' AND "
cQuery += "     FJZ_NUM = '"+cNumero+"' AND "
cQuery += "     FJZ_PARCEL = '"+cParcela+"' AND "
cQuery += "     FJZ_TIPO = '"+cTipo+"' AND "
cQuery += "     FJZ_STATUS = '2' AND "
cQuery += "     FJZ.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

If (cNextAlias)->(!EOF())
	nRecFJZ := (cNextAlias)->FJZREC
	If nRecFJZ > 0
		FJZ->(dbGoTo(nRecFJZ))
		RecLock("FJZ",.F.)
			FJZ->FJZ_STATUS := '4'
		MsUnLock()
	EndIf
EndIf

(cNextAlias)->(dbCloseArea())

RestArea(aAreaFJZ)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645TOK
Faz validação para ver se o titulo já foi simulado. 

@author Mayara Alves
@since   17/11/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function FA645TOK( oModel ) 

Local lRet 			:= .T.
Local aArea			:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cQry			:= ""
Local oModelCli 	:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local nFJY 			:= 0
Local nFJZ			:= 0
Local lTitSil		:= .F.
Local cTitulo 		:= CRLF +STR0057+CRLF //"Cliente	-	Filial Tit.	- 	Prefixo	Num	-	Titulo	-	Parcela "
Local aSaveLines	:= FWSaveRows()
Local oPnlMsg		:= Nil
Local oDlg 			:= Nil
Local oSay			:= Nil

For nFJY:= 1 to oModelCli:Length()

	oModelCli:GoLine(nFJY)

	If oModelCli:GetValue("FJY_OK") //Verifica se o cliente está selecionado
	
		For nFJZ:= 1 to oModelTit:Length()
		
			oModelTit:GoLine(nFJZ)
			
			If	oModelTit:GetValue("FJZ_OK") //Verifica se o titulo está selecionado

				cQry := " SELECT  "
				cQry += "     FJZ.R_E_C_N_O_ FJZREC  " 
				cQry += " FROM " + RetSqlName("FJX") + " FJX "
				cQry += " LEFT JOIN " + RetSqlName("FJZ") + " FJZ ON "
				cQry += "     FJZ_FILIAL	=  '"+xFilial("FJZ")+"'"
				cQry += " AND FJZ_PROC 		= FJX_PROC "
				cQry += " AND FJZ_PREFIX	= '"+oModelTit:GetValue("FJZ_PREFIX")+"'"
				cQry += " AND FJZ_NUM		= '"+oModelTit:GetValue("FJZ_NUM")+"'"
				cQry += " AND FJZ_PARCEL	= '"+oModelTit:GetValue("FJZ_PARCEL")+"'"
				cQry += " AND FJZ_FILTIT	= '"+oModelTit:GetValue("FJZ_FILTIT") +"'"
				cQry += " WHERE "
				cQry += "     FJX_FILIAL		= '"+xFilial("FJX")+"' AND "
				cQry += "     FJX_TIPO 			= '1' AND "
				cQry += "     FJX_STATUS 		= '1' AND "
				cQry += "     FJX.D_E_L_E_T_ 	= ' '  AND "
				cQry += "     FJZ.D_E_L_E_T_ 	= ' ' "
				cQry := ChangeQuery(cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cNextAlias,.T.,.T.)

				If (cNextAlias)->(!EOF())
					lTitSil := .T.
					cTitulo += oModelCli:GetValue("FJY_CLIENT") + "	- " + oModelTit:GetValue("FJZ_FILTIT") + "	- " + oModelTit:GetValue("FJZ_PREFIX") + ;
					"	- " + oModelTit:GetValue("FJZ_NUM") +"	- " +  oModelTit:GetValue("FJZ_PARCEL") 
				EndIf
				
				(cNextAlias)->(dbCloseArea())
			EndIf
		Next nFJZ
	EndIF
Next nFJY

If lTitSil .And. !IsBlind()
	 
	If MSGYESNO( STR0058, "FA645TITSI" ) //"Existe processo em fase de simulação referente aos títulos selecionados, deseja continuar? "
		lRet := .T. 
	Else
		lRet := .F. 
		
		DEFINE DIALOG oDlg TITLE STR0059 FROM 180,180 TO 480,580 PIXEL //"Titulos em fase de simulação"
		oPnlMsg := TScrollBox():New(oDlg,01,01,150,200,.T.,.T.,.T.)
		
		oSay := TSay():New(01,01, {|| cTitulo }, oPnlMsg,,,,,,.T.,CLR_RED,CLR_WHITE,200,200)
		ACTIVATE DIALOG oDlg CENTERED
	
		HELP(" ",1,"FA645TITSI",,STR0060 ,1,0) //"Processo cancelado."
	EndIf
EndIf
FWRestRows(aSaveLines)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645SitPDD
Realiza a substituição das situações de PDD na tela

@author Alvaro Camillo Neto
@since 19/11/2015
@version 12
/*/
//-------------------------------------------------------------------

Function FA645SitPDD(cOpc)

Local aSaveLines	:= FWSaveRows()
Local oView			:= FWViewActive()
Local oModel		:= FWModelActive()
Local oModelCli 	:= oModel:GetModel("FJYDETAIL")
Local oModelTit		:= oModel:GetModel("FJZDETAIL")
Local lEfetiva 		:= FwIsInCallStack("FA645Efe")
Local lEfeRev  		:= FwIsInCallStack("FA645EfRev")
Local cSitOri		:= ""
Local cSitDest		:= ""
Local cSitTit		:= ""
Local lRet			:= .T.
Local cPerg			:= "FINA645G"
Local nOperation	:= oModel:GetOperation()
Local nX			:= 0
Local nZ			:= 0
Local lReversao		:= FwIsInCallStack("FA645Rev")

If nOperation == MODEL_OPERATION_UPDATE .And. !( lEfetiva .Or. lEfeRev .Or. lReversao)
	If Pergunte(cPerg,!lAutomato)
		cSitOri	:= MV_PAR01
		cSitDest	:= MV_PAR02
		cCampo		:= IIF(MV_PAR03 == 1,"FJZ_SITUAC","FJZ_SITPAI")
		FRV->(dbSetOrder(1)) //FRV_FILIAL+FRV_CODIGO
		If !Empty(cSitDest) .And. FRV->(dbSeek(xFilial("FRV") + cSitDest )) .And. FRV->FRV_SITPDD == '1'
			lRet := .T.
		Else
			lRet := .F.
			HELP(" ",1,"FA645SitPDD2",,STR0065 ,1,0) //"Situação de PDD inválida."
		EndIf
	
		If lRet
			If cOpc == "1" // Cliente
				If MsgYesNo(STR0063)//"Todos os títulos de todos os clientes da provisão serão alterados. Confirma operação?"
					For nX := 1 to oModelCli:Length()
						oModelCli:GoLine(nX)
						oModelTit:= oModel:GetModel("FJZDETAIL")
						oModelCli:LoadValue("FJY_SITPDD" , cSitDest )
						
						For nZ := 1 to oModelTit:Length()
							oModelTit:GoLine(nZ)
							cSitTit := oModelTit:GetValue(cCampo)
							If Empty(cSitOri)
								oModelTit:LoadValue("FJZ_SITPDD" , cSitDest )
							Else
								If Alltrim(cSitTit) $ Alltrim(cSitOri)
									oModelTit:LoadValue("FJZ_SITPDD" , cSitDest )
								EndIf
							EndIf
						Next nZ
					Next nX
				EndIf
			Elseif cOpc == "2"// Titulos
				If MsgYesNo(STR0064)//"Todos os títulos do cliente selecionado serão alterados. Confirma operação?"
					For nZ := 1 to oModelTit:Length()
						oModelTit:GoLine(nZ)
						cSitTit := oModelTit:GetValue(cCampo)
						If Empty(cSitOri)
							oModelTit:LoadValue("FJZ_SITPDD" , cSitDest )
						Else
							If Alltrim(cSitTit) $ Alltrim(cSitOri)
								oModelTit:LoadValue("FJZ_SITPDD" , cSitDest )
							EndIf
						EndIf
					Next nZ
				EndIf
			Endif
		EndIf
	EndIf
	
	FWRestRows(aSaveLines)
	
	oModelTit:GoLine(1)
	
	If __lRefresh
		If oView != Nil
			oView:Refresh()
		EndIf
	Endif
Else
	HELP(" ",1,"FA645SitPDD",,STR0030 ,1,0) //"Opção bloqueada."
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} F645VldGat
Realiza validação do gatilho.
@author William Gundim
@since 09/12/15
@version 12
/*/
//-------------------------------------------------------------------
Function FJZLinPre( oModel, nLine, cAction, cField, xValue, xOldValue )

Local lRet 		:= .F. 
Local lAltSit	:= FwIsInCallStack("FA645AltZ")

	If cField == 'FJZ_OK'
		lRet := !(oModel:GetValue('FJZ_TIPO') $ MVABATIM)
	ElseIf Alltrim(cField) == 'FJZ_SITPDD'
		lRet := .T.
	ElseIf lAltSit .and. (Alltrim(cField) == "FJZ_SITUAC" .or. Alltrim(cField) == "FJZ_SITPAI" .or. Alltrim(cField) == "FJZ_SITPDD" )
		lRet := .T.
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F645TrigOK
Realiza validação do gatilho.
@author William Gundim
@since 09/12/15
@version 12
/*/
//-------------------------------------------------------------------
Function F645TrigOK(oModel)

Local nX 	 	:= 0
Local aSaveLines:= FWSaveRows()
Local cTit		:= oModel:GetValue('FJZ_PREFIX') + oModel:GetValue('FJZ_NUM') + oModel:GetValue('FJZ_PARCEL') 	
Local nLinha  	:= oModel:GetLine()
Local aLines  	:= {}
Local lOK		:= oModel:GetValue('FJZ_OK')

	For nX := 1 To oModel:Length()
		If nX <> nLinha .AND. cTit == oModel:GetValue('FJZ_PREFIX', nX) 	+ oModel:GetValue('FJZ_NUM', nX) + oModel:GetValue('FJZ_PARCEL', nX) 
			aAdd(aLines, nX)
		EndIf
	Next nX
	
	//Atualiza os itens.
	For nX := 1 To Len(aLines)
		oModel:SetLine(aLines[nX])
		oModel:LoadValue('FJZ_OK', lOK )
	Next nX

aSize(aLines, 0)
aLines := {}
	
FWRestRows(aSaveLines)

Return lOK
//-------------------------------------------------------------------
/*/{Protheus.doc} F645VerBx
Verifica se as baixas do título ocorreram antes da data de referencia do PDD

@author Pâmela Bernardo
@since   07/10/16
@version 12
/*/
//-------------------------------------------------------------------
Static Function F645VerBx(cChaveTit, cAliasFJZ, cFilMov )

	Local lRet			:= .F.
	Local aArea			:= GetArea()
	Local aAreaFJX		:= FJX->(GetArea())
	Local cNextAlias	:= GetNextAlias()
	Local cChaveFK7		:= FINGRVFK7("SE1",cChaveTit, cFilMov)
	Local cQuery 		:= ""
	Local dDtRef		:= dDataBase //data de referencia da constituição
	Local cFilialFK1	:= xFilial("FK1", cFilMov)
	
	dbSelectArea("FJX")
	dbSetOrder(1)//FJX_FILIAL+FJX_PROC
	If FJX->(MsSeek(xFilial("FJX") +  (cAliasFJZ)->FJZ_PROC))
		If FJX->FJX_DTREF < FJX->FJX_DTPROC
			dDtRef := FJX->FJX_DTREF
		Else
			dDtRef := FJX->FJX_DTPROC
		Endif
	Endif
	
	cQuery := "SELECT Count(FK1_IDFK1) QTDE_BX "
	cQuery += " FROM " + RetSqlName("FK1") 
	cQuery += " Where FK1_FILIAL = '" + cFilialFK1 + "' " 
	cQuery += " AND FK1_IDDOC = '" + cChaveFK7 + "' " 
	cQuery += " AND FK1_DATA BETWEEN	'"	+ DTOS(dDtRef) + "'	AND '" + DTOS(MV_PAR07)	+ "' "
	cQuery += " AND ( FK1_SEQ NOT IN "
		cQuery += " (SELECT FK1_SEQ FROM " + RetSqlName("FK1") 
		cQuery += " Where FK1_FILIAL= '" + cFilialFK1 + "' " 
		cQuery += " AND FK1_IDDOC = '" + cChaveFK7 +  "' " 
		cQuery += " AND FK1_DATA BETWEEN	'"	+ DTOS(dDtRef) + "'	AND '" + DTOS(MV_PAR07)	+ "' "
		cQuery += " AND FK1_TPDOC = 'ES'  AND D_E_L_E_T_ = '' )"
	cQuery += " OR FK1_TPDOC = 'ES' )"   //CASO O TÍTULO TENHA SOFRIDO APENAS CANCELAMENTO DE BAIXA
	cQuery += " AND D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
		
	If (cNextAlias)->(!EOF())
		lRet := (cNextAlias)->QTDE_BX > 0
	EndIf
	
	(cNextAlias)->(dbCloseArea())
	
	RestArea(aArea)
	RestArea(aAreaFJX)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645ValFil
Verifica se as filiais selecionadas podem ser usadas

@author Pâmela Bernardo
@since   07/10/16
@version 12
/*/
//-------------------------------------------------------------------
Static Function FA645ValFil()

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local cBkpFil	:= cFilant
	Local nx		:= 0
	Local dBkpData	:= dDataBase
	
	If Empty(__aSelFil)
		__aSelFil:= {cFilant}
	Endif
	dDataBase:= FJX->FJX_DTREF
	For nx:=1 to len(__aSelFil)
		cFilant := __aSelFil[nx]
	
		If lRet
			lRet := CtbValiDt(,dDataBase,.T.,,,{"FIN002"})
		Else
			Exit
		Endif
	Next nx
	
	cFilant := cBkpFil
	dDataBase:= dBkpData
	RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645VerFil
Verifica se as filiais selecionadas podem ser usadas

@author Pâmela Bernardo
@since   07/10/16
@version 12
/*/
//-------------------------------------------------------------------
Static Function FA645VerFil(cProcess)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local cChaveFJZ	:= FJZ->(xFilial("FJZ")+cProcess)
	
	dbSelectArea("FJZ")
	dbSetOrder(1)//FJZ_FILIAL+FJZ_PROC+FJZ_ITCLI+FJZ_ITEM+FJZ_FILTIT+FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO
	If FJZ->(MsSeek(cChaveFJZ))
		While FJZ->(!Eof()) .AND. (FJZ->FJZ_FILIAL+FJZ_PROC == cChaveFJZ)
			If Empty(__aSelFil) .OR. ascan(__aSelFil,{|x| x == FJZ_FILTIT}) == 0
				AADD(__aSelFil, FJZ_FILTIT)
			EndIf
			FJZ->(dbSkip()) 
		EndDo
	Endif
	
	lRet:= FA645ValFil()
	RestArea(aArea)
	
Return lRet


//-----------------------------------------------------------
/*/{Protheus.doc} FA645AltZ
Função que altera a situaçao de cobrança,na efetivação da constituição, caso ocorra alteração na SE1
antes da efetivação da constituição.

@author Pâmela Bernardo
@since 20/10/2016
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645AltZ(oView)

	Local oModel 		:= oView:GetModel()
	Local oModelFJZ		:= oModel:GetModel("FJZDETAIL")
	Local oModelFJY		:= oModel:GetModel("FJYDETAIL")
	Local aArea			:= GetArea()
	Local nx			:= 0
	Local ny			:= 0
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local cChave		:= ""
	Local cSitPDD		:= ""
		
	dbSelectArea('SE1')
	SE1-> (DbSetOrder(1))
	
	For nx := 1 to  oModelFJY:Length()
	
		oModelFJY:GoLine(nX)
		cCliente		:= oModelFJY:GetValue("FJY_CLIENT")
		cLoja			:= oModelFJY:GetValue("FJY_LOJA")	
		
		For ny := 1 to  oModelFJZ:Length()
			oModelFJZ:GoLine(ny)
			cChave:= xFilial("SE1",oModelFJZ:GetValue("FJZ_FILTIT"))+ oModelFJZ:GetValue("FJZ_PREFIX")+ oModelFJZ:GetValue("FJZ_NUM")
			cChave+= oModelFJZ:GetValue("FJZ_PARCEL")+oModelFJZ:GetValue("FJZ_TIPO")+cCliente+cLoja
			If SE1->(MsSeek(cChave))
				oModelFJZ:SetValue("FJZ_SITUAC",SE1->E1_SITUACA)
				If !oModelFJZ:GetValue("FJZ_TIPO")$ MVABATIM	
					cSitPai := SE1->E1_SITUACA
				EndIF
				oModelFJZ:SetValue("FJZ_SITPAI",cSitPai)
				If __F645ALTS
					cSitPDD:= ExecBlock("F645ALTS",.F.,.F.)
					oModelFJZ:SetValue("FJZ_SITPDD",cSitPDD)
				EndIf
			Endif
		Next ny
	Next nX
	
	oModelFJY:GoLine(1)
	oModelFJZ:GoLine(1)
	
	RestArea(aArea)
	
	oView:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FA645Cons
Consulta Rastreamento Financeiro do titulo

@author Mauricio Pequim Jr
@since   07/12/16
@version 12
/*/
//-------------------------------------------------------------------
Function FA645Cons()

Local oModel	:= FWModelActive()
Local oModelFJZ	:= oModel:GetModel("FJZDETAIL")
Local oModelFJY	:= oModel:GetModel("FJYDETAIL")
Local aArea		:= GetArea()
Local cCliente	:= oModelFJY:GetValue("FJY_CLIENT")
Local cLoja		:= oModelFJY:GetValue("FJY_LOJA")	
Local cChave	:= ""
	
cChave		:= xFilial("SE1",oModelFJZ:GetValue("FJZ_FILTIT")) + oModelFJZ:GetValue("FJZ_PREFIX")+ oModelFJZ:GetValue("FJZ_NUM")
cChave		+= oModelFJZ:GetValue("FJZ_PARCEL") + oModelFJZ:GetValue("FJZ_TIPO")+cCliente+cLoja

dbSelectArea('SE1')
SE1-> (DbSetOrder(1))
If SE1->(MsSeek(cChave))
	F250Cons("SE1",SE1->(Recno()),2,,2,.T.)	
Endif

RestArea(aArea)

Return

//-----------------------------------------------------------
/*/{Protheus.doc} FA645BLiq
Função verifica a nota de origem da liquidação

@author Pâmela Bernardo
@since 18/01/2017
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645BLiq (oModel, cFilTit,cPrefix,cNum,cParcela, cTipo, cCliente,cLoja, cTempFWZ)

	Local aArea			:= GetArea()
	Local cTempFI7		:= GetNextAlias()	
	Local aStruFI7		:= F645StFI7()
	Local aIndiceFI7	:= {"FI7_FILIAL","FI7_PRFORI","FI7_NUMORI","FI7_PARORI","FI7_TIPORI","FI7_CLIORI","FI7_LOJORI"}
	Local oTempTableFI7
	
	//-------------------
	//Criação do objeto
	//-------------------
	oTempTableFI7 := FWTemporaryTable():New(cTempFI7)
	oTempTableFI7:SetFields( aStruFI7 )
	
	oTempTableFI7:AddIndex("ORD1", aIndiceFI7)
	
	//------------------
	//Criação da tabela
	//------------------
	oTempTableFI7:Create()

	//função para gravar cTempFI7
	FA645TmpFI7 (oModel, cTempFI7, cTempFWZ, cFilTit,cPrefix,cNum,cParcela, cTipo, cCliente,cLoja)	

	If oTempTableFI7 <> Nil
		oTempTableFI7:Delete()
		oTempTableFI7 := Nil
	EndIf
	
	If Select(cTempFI7) > 0
		dbSelectArea(cTempFI7)
		dbCloseArea()
		MsErase(cTempFI7)
	Endif
	
	RestArea(aArea)

Return 

//-----------------------------------------------------------
/*/{Protheus.doc} FA645TmpFI7
Função para gravação da tabela temporária espelho da FI7

@author Pâmela Bernardo
@since 18/01/2017
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645TmpFI7 (oModel, cTempFI7, cTempFWZ, cFilTit,cPrefix,cNum,cParcela, cTipo, cCliente,cLoja)

	Local aArea		:= GetArea()
	Local nRecnoFI7	:= 0
	Local nRecnoSE1	:= 0	
	Local nFator		:= 0//FI7->FI7_VALOR/SE1->E1_VALOR
	Local nValFator	:= 0
		
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	DbSelectArea("FI7")
	FI7->(DbSetOrder(2))//FI7_FILIAL+FI7_PRFDES+FI7_NUMDES+FI7_PARDES+FI7_TIPDES+FI7_CLIDES+FI7_LOJDES
	
	If SE1->(MsSeek(xFilial("SE1",cFilTit)+cCliente+cLoja+cPrefix+cNum+cParcela+cTipo))
	
		If !Empty(SE1->E1_NUMLIQ)
			If FI7->(MsSeek(xFilial("FI7",cFilTit)+ cPrefix+cNum+cParcela+cTipo+cCliente+cLoja))
				While FI7->(!Eof()) .AND. (xFilial("FI7",cFilTit)+ cPrefix+cNum+cParcela+cTipo+cCliente+cLoja == ;
						FI7->FI7_FILIAL+FI7->FI7_PRFDES+FI7->FI7_NUMDES+FI7->FI7_PARDES+FI7->FI7_TIPDES+FI7->FI7_CLIDES+FI7->FI7_LOJDES)
		
					nFator		:= FI7->FI7_VALOR/SE1->E1_VALOR
					
					DbSelectArea(cTempFI7)
					(cTempFI7)->(DbSetOrder(1))
					
					If (cTempFI7)->(MsSeek(FI7->FI7_FILIAL+FI7->FI7_PRFDES+FI7->FI7_NUMDES+FI7->FI7_PARDES+FI7->FI7_TIPDES+FI7->FI7_CLIDES+FI7->FI7_LOJDES))
						nValFator	:= (cTempFI7)->FI7_VLRFAT * nFator
					Else
						nValFator	:= SE1->E1_VALOR * nFator
					EndIf
					Reclock(cTempFI7, .T.)
						FI7_FILIAL := FI7->FI7_FILIAL
						FI7_PRFORI := FI7->FI7_PRFORI
						FI7_NUMORI := FI7->FI7_NUMORI
						FI7_PARORI := FI7->FI7_PARORI
						FI7_TIPORI := FI7->FI7_TIPORI
						FI7_CLIORI := FI7->FI7_CLIORI
						FI7_LOJORI := FI7->FI7_LOJORI
						FI7_PRFDES := FI7->FI7_PRFDES
						FI7_NUMDES := FI7->FI7_NUMDES
						FI7_PARDES := FI7->FI7_PARDES
						FI7_TIPDES := FI7->FI7_TIPDES
						FI7_CLIDES := FI7->FI7_CLIDES
						FI7_LOJDES := FI7->FI7_LOJDES
						FI7_VALOR  := FI7->FI7_VALOR
						FI7_VLRFAT := nValFator
					(cTempFI7)->(MSUNLOCK())
					
					nRecnoFI7:=FI7->(RECNO())
					nRecnoSE1:=SE1->(RECNO())
					
					//Verifico se o pai pertence a outra liquidação
					If FI7->(MsSeek(FI7->FI7_FILIAL+FI7->FI7_PRFORI+FI7->FI7_NUMORI+FI7->FI7_PARORI+FI7->FI7_TIPORI+FI7->FI7_CLIORI+FI7->FI7_LOJORI))
						FA645TmpFI7 (oModel, cTempFI7, cTempFWZ, FI7->FI7_FILIAL,FI7->FI7_PRFDES,FI7->FI7_NUMDES,FI7->FI7_PARDES,FI7->FI7_TIPDES,FI7->FI7_CLIDES,FI7->FI7_LOJDES)
					Else
						If SE1->(MsSeek(xFilial("SE1",(cTempFI7)->FI7_FILIAL)+(cTempFI7)->FI7_CLIORI+(cTempFI7)->FI7_LOJORI+(cTempFI7)->FI7_PRFORI+(cTempFI7)->FI7_NUMORI+(cTempFI7)->FI7_PARORI +(cTempFI7)->FI7_TIPORI))
							FA645ItNFFI7 (oModel, (cTempFI7)->FI7_FILIAL,(cTempFI7)->FI7_PRFORI,(cTempFI7)->FI7_NUMORI,(cTempFI7)->FI7_CLIORI,(cTempFI7)->FI7_LOJORI, (cTempFI7)->FI7_VLRFAT, (cTempFI7)->FI7_VLRFAT, cTempFWZ)
						Endif
					EndIf
					SE1->(DBGOTO(nRecnoSE1))
					FI7->(DBGOTO(nRecnoFI7))
					FI7->(dbSkip())
				
				Enddo
			Endif
		Endif
	EndIf		
	
	RestArea(aArea)
	
Return 

//-----------------------------------------------------------
/*/{Protheus.doc} F645StFI7
Função para definir a estrutura da tabela temporária espelho da FI7

@author Pâmela Bernardo
@since 18/01/2017
@version 12
/*/
//-----------------------------------------------------------
Static Function F645StFI7()

	Local aStru := FI7->(DbStruct())
	
	Aadd(aStru, {"FI7_VLRFAT","N",16,8})// VALOR DA FI7 PAI APLICADO AO FATOR
	
Return aStru

//-----------------------------------------------------------
/*/{Protheus.doc} F645StFWZ
Função para definir a estrutura da tabela temporária espelho da FWZ

@author Pâmela Bernardo
@since 23/01/2017
@version 12
/*/
//-----------------------------------------------------------
Static Function F645StFWZ()

	Local aStru := FWZ->(DbStruct())
	
	Aadd(aStru, {"FWZ_DESPRO","C",TAMSX3("FWZ_DESPRO")[1],0}) // FILIAL DA SD2
	Aadd(aStru, {"FWZ_D2FIL","C",TAMSX3("D2_FILIAL")[1],0}) // FILIAL DA SD2
	
Return aStru

//-----------------------------------------------------------
/*/{Protheus.doc} FA645ItNFFI7
Função para o rateio de nota fiscal por itens

@author Pâmela Bernardo
@since 19/01/2017
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645ItNFFI7 (oModel,cFilTit,cPrefix,cNum,cCliente,cLoja, nValTit, nValSal, cTempFWZ)

	Local aArea			:= GetArea()
	Local oModelPai		:= oModel:GetModel()
	Local oModelFJX		:= oModelPai:GetModel("FJXMASTER")
	Local oModelFJY		:= oModelPai:GetModel("FJYDETAIL")
	Local oModelFJZ		:= oModelPai:GetModel("FJZDETAIL")
	Local cProcesso		:= oModelFJX:GetValue("FJX_PROC")
	Local cItemCli		:= oModelFJY:GetValue("FJY_ITEM")
	Local cItemTit		:= oModelFJZ:GetValue("FJZ_ITEM") 
	Local cAliasFWZ		:= ""
	Local nTotalNF		:= 0
	Local nPercSoma		:= 0
	Local nSomaVlr		:= 0
	Local nSomaSal		:= 0
	Local nPerc			:= 0
	Local nValRat		:= 0
	Local nSalRat		:= 0
	Local nCentMd1		:= MsDecimais(1)
	
	
	If Alltrim(SE1->E1_ORIGEM) == "MATA460"	
		cAliasFWZ	:= FA645QryNF(cFilTit,cPrefix,cNum,cCliente,cLoja)
		nTotalNF	:= FA645NFTot(cFilTit,cPrefix,cNum,cCliente,cLoja) //total da nf
		nTotalRat  += nTotalNF
		
		While (cAliasFWZ)->(!Eof())
			
			nPerc := (cAliasFWZ)->(D2_TOTAL) / nTotalNF
			nValRat:= Round(NoRound(nValTit * nPerc,nCentMd1+1),nCentMd1)
			nSalRat:= Round(NoRound(nValSal * nPerc,nCentMd1+1),nCentMd1)
			
			DbSelectArea(cTempFWZ)
			(cTempFWZ)->(DbSetOrder(1)) //FWZ_FILIAL+FWZ_PROC+FWZ_ITCLI+FWZ_ITTIT+FWZ_DOC+FWZ_SERIE+FWZ_ITEM
			
			If (cTempFWZ)->(MsSeek(xFilial('FWZ')+cProcesso+cItemCli+cItemTit+(cAliasFWZ)->(D2_DOC)+(cAliasFWZ)->(D2_SERIE)+(cAliasFWZ)->(D2_ITEM)))
			
				Reclock(cTempFWZ, .F.)
				
					FWZ_VLRRAT += nValRat
					FWZ_SLDRAT += nSalRat
					
				(cTempFWZ)->(MSUNLOCK())
			
			Else
				Reclock(cTempFWZ, .T.)
					FWZ_FILIAL := xFilial('FWZ')
					FWZ_PROC   := cProcesso
					FWZ_ITCLI  := cItemCli
					FWZ_ITTIT  := cItemTit
					FWZ_DOC    := (cAliasFWZ)->(D2_DOC)
					FWZ_SERIE  := (cAliasFWZ)->(D2_SERIE)
					FWZ_ITEM   := (cAliasFWZ)->(D2_ITEM)
					FWZ_CODPRO := (cAliasFWZ)->(D2_COD)
					FWZ_DESPRO := (cAliasFWZ)->(B1_DESC)
					FWZ_PERCEC := nPerc * 100
					FWZ_VLRRAT := nValRat
					FWZ_SLDRAT := nSalRat
					FWZ_BXRAT  := 0
					FWZ_D2FIL  := (cAliasFWZ)->(D2_FILIAL)
				(cTempFWZ)->(MSUNLOCK())
			EndIf

			(cAliasFWZ)->(DbSkip())
			
			If (cAliasFWZ)->(EOF())
	
				nPerc := (1 - nPercSoma) * 100
	
				If nValTit > 0
					nValRat := nValTit - nSomaVlr
				Else
					nValRat := 0
				EndIf
				
				If nValSal > 0
					nSalRat := nValSal - nSomaSal
				Else
					nSalRat := 0
				EndIf	
			Else
				nPercSoma 		+= nPerc
				nSomaVlr		+= nValRat
				nSomaSal		+= nSalRat
			EndIf
				
		EndDo
		
		If Select(cAliasFWZ) > 0
			(cAliasFWZ)->(DbCloseArea())
		EndIf
	
	EndIf
	
	RestArea(aArea)

Return 

//-----------------------------------------------------------
/*/{Protheus.doc} FA645TmpFWZ
Função para gravação da tabela temporária espelho da FWZ, para aglutinar itens da mesma nota

@author Pâmela Bernardo
@since 23/01/2017
@version 12
/*/
//-----------------------------------------------------------
Static Function FA645TmpFWZ(aDados,cTempFWZ, oModel)

	Local oFWZStruct	:= oModel:GetStruct()
	Local aCposVlr		:= {}
	Local aFilCpos		:= {}
	Local cCampo		:= ""
	Local aRateio		:= {}
	Local nX			:= 0
	
	aCposVlr := oFWZStruct:GetFields()
	
	(cTempFWZ)->(DbGoTop())
	
	While (cTempFWZ)->(!Eof())
		If __lF645WZ
			
			//Array com a chave do titulo
			aRateio := {}
			
			aadd(aRateio,{"D2_DOC"	  ,  (cTempFWZ)->(FWZ_DOC)})
			aadd(aRateio,{"D2_SERIE"  ,  (cTempFWZ)->(FWZ_SERIE)})
			aadd(aRateio,{"D2_ITEM"	  ,  (cTempFWZ)->(FWZ_ITEM)})
			aadd(aRateio,{"D2_COD"	  ,  (cTempFWZ)->(FWZ_CODPRO)})
			aadd(aRateio,{"D2_FILIAL" ,  (cTempFWZ)->(FWZ_D2FIL)})
		EndIf
		
		For nX := 1 To Len(aCposVlr)
			
			cCampo := Alltrim(aCposVlr[nX][3])
			
			If cCampo == "FWZ_FILIAL"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_FILIAL))
			ElseIf cCampo == "FWZ_PROC"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_PROC))
			ElseIf cCampo == "FWZ_ITCLI"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_ITCLI))
			ElseIf cCampo == "FWZ_ITTIT"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_ITTIT))
			ElseIf cCampo == "FWZ_DOC"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_DOC))
			ElseIf cCampo == "FWZ_SERIE"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_SERIE))
			ElseIf cCampo == "FWZ_ITEM"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_ITEM))
			ElseIf cCampo == "FWZ_CODPRO"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_CODPRO))
			ElseIf cCampo == "FWZ_DESPRO"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_DESPRO))
			ElseIf cCampo == "FWZ_PERCEC"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_PERCEC))
			ElseIf cCampo == "FWZ_VLRRAT"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_VLRRAT))
			ElseIf cCampo == "FWZ_SLDRAT"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_SLDRAT))
			ElseIf cCampo == "FWZ_BXRAT"
				AAdd(aFilCpos,(cTempFWZ)->(FWZ_BXRAT))
			Else
				AAdd(aFilCpos,IIf(__lF645WZ,ExecBlock('F645LDFW',.F.,.F.,{cCampo,aRateio}),CriaVar(cCampo)))
			EndIf
		
		Next nX
		
		AADD(aDados,{0,aFilCpos})
		
		aFilCpos := {}
		(cTempFWZ)->(DbSkip())
	
	EndDo
	
Return

//-----------------------------------------------------------
/*/{Protheus.doc} FA645AUTO
Função para Chamada do model quando vier de execauto ou chamado do robo.

@author Francisco Oliveir
@since 06/05/2019
@version 12
/*/
//-----------------------------------------------------------

Static Function FA645AUTO(cPrograma, nOperation, aDdsAlt)

Local oModel
Local oModelFJX
Local oModelFJY
Local oModelFJZ

Local lEfetiva 		:= FwIsInCallStack("FA645Efe")
Local lEfeRev  		:= FwIsInCallStack("FA645EfRev")
Local lAlteracao	:= FwIsInCallStack("FA645Alt")

Local cParcela		:= ""
Local nX			:= 0
Local lRet			:= .F.
Local lRetModel		:= .T.

Default aDdsAlt		:= {}
Default cPrograma	:= "FINA645"

oModel	:= FWLoadModel(cPrograma)

oModel:SetOperation( nOperation ) //Define operação de inclusao
lRetModel := oModel:Activate()

oModelFJX	:= oModel:GetModel("FJXMASTER")
oModelFJY	:= oModel:GetModel("FJYDETAIL")
oModelFJZ	:= oModel:GetModel("FJZDETAIL")

If lRetModel
	If lEfetiva .Or. lEfeRev
		oModelFJX:LoadValue("FJX_DTEFET", dDataBase) 
	ElseIf lAlteracao
	
		If Len(aDdsAlt) > 0
			For nX := 1 To Len(aDdsAlt)
				If Empty(aDdsAlt[nX,2,8])
					cParcela := Space(TamSX3( "E1_PARCELA" )[ 1 ])
				Else
					cParcela := Alltrim(aDdsAlt[nX,2,8])
				Endif
				
				If oModelFJZ:SeekLine({{"FJZ_FILIAL",aDdsAlt[nX,2,1]},{"FJZ_PROC",aDdsAlt[nX,2,2]}, {"FJZ_ITCLI",aDdsAlt[nX,2,3]}, {"FJZ_ITEM",aDdsAlt[nX,2,4]}, {"FJZ_FILTIT",aDdsAlt[nX,2,5]},{"FJZ_PREFIX",aDdsAlt[nX,2,6]}, {"FJZ_NUM",aDdsAlt[nX,2,7]}, {"FJZ_PARCEL",cParcela}, {"FJZ_TIPO",aDdsAlt[nX,2,9]}})
					oModelFJZ:SetValue("FJZ_SITPDD", aDdsAlt[nX,1] )
					oModelFJZ:SetValue("FJZ_OK"    , aDdsAlt[nX,3] )
				Else
					HELP(" ",1,"FA645AltExec",, STR0075 ,1,0) //"Registro não encontrado na tabela FJZ"
				Endif			
			Next nX
		Else
			HELP(" ",1,"FA645AltExec",, STR0076 ,1,0) //"Array com os dados para alteração está vazio"
		Endif
	Endif
	
	If oModel:VldData()
		oModel:CommitData()
		lRet	:= .T. 
	EndIf
Else
	lRet := .F.
Endif

oModel:DeActivate(.T.)

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} FA645DblCl
Função para Chamada da tela de Legenda e Marca e desmarca titulos, chamada pelo model de clientes

@author Francisco Oliveira
@since 17/06/2019
@version 12
/*/
//-----------------------------------------------------------

Static Function FA645Lege()

	// Cria a legenda que identifica a estrutura
	oLegend := FWLegend():New()

	// Adiciona descrição para cada legenda
	oLegend:Add( { || }, 'BR_VERDE  '      , STR0078 ) // "Título Original 'sem' Liquidação com saldo maior que zero e sem valores de baixa"
	oLegend:Add( { || }, 'BR_AZUL'         , STR0079 ) // "Título Original 'com' Liquidação com saldo maior que zero e sem valores de baixa"
	oLegend:Add( { || }, 'BR_PRETO'        , STR0080 ) // "Título Original 'sem' Liquidação com saldo igual a zero e baixa maior ou igual que data de referencia"
	oLegend:Add( { || }, 'BR_VERMELHO'     , STR0081 ) // "Título Original 'com' Liquidação com saldo igual a zero e baixa maior ou igual que data de referencia"
	oLegend:Add( { || }, 'BR_BRANCO'       , STR0083 ) // "Título Original 'sem' Liquidação com saldo maior que zero e baixa menor ou igual que data de referencia"
	oLegend:Add( { || }, 'BR_AMARELO'      , STR0084 ) // "Título Original 'com' Liquidação com saldo maior que zero e baixa menor ou igual que data de referencia"
	oLegend:Add( { || }, 'BR_PINK'         , STR0087 ) // "Título Original 'sem' Liquidação com saldo maior que zero e baixa maior ou igual que data de referencia"
	oLegend:Add( { || }, 'BR_LARANJA'      , STR0089 ) // "Título Original 'com' Liquidação com saldo maior que zero e baixa maior ou igual que data de referencia"
	oLegend:Add( { || }, 'BR_AZUL_CLARO'   , STR0090 ) // "Título Original 'com' Liquidação com saldo igual a zero e baixa maior ou igual que data de refer. e data vencimento"
	oLegend:Add( { || }, 'BR_MARRON'       , STR0091 ) // "Outras Situações"

	// Ativa a Legenda
	oLegend:Activate()

	// Exibe a Tela de Legendas
	oLegend:View()

Return 

//-----------------------------------------------------------
/*/{Protheus.doc} FA645CANC
Função para retorno do valor do sequencial quando cancelado a operaçao.

@author Francisco Oliveira
@since 31/07/2019
@version 12
/*/
//-----------------------------------------------------------

Static Function FA645CANC()

RollBackSx8()

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} FA645TiBus
Títulos na Constuição do PDD

@author Francisco Oliveira
@since 22/08/2015
@version 12
/*/
//-----------------------------------------------------------

Static Function FA645TiBus(cAliasFJZ)

Local lConstituicao	AS Logical
Local lReversao		AS Logical
Local lChkLiq		AS Logical
Local aTitulo		AS Array
Local nAtraso		AS Numeric
Local cParVenc		AS Character
Local cCpoVenc		AS Character
Local cAlsF465		AS Character
Local cAlsTMPPDD	AS Character
Local cQuery		AS Character
Local cFilAux		AS Character
Local dSE1PaiAux	AS Date

dSE1PaiAux	:= CTOD("")
cQuery		:= ""
cAlsTMPPDD	:= GetNextAlias()
cAlsF465	:= GetNextAlias()
lChkLiq		:= .F.
cParVenc	:= AllTrim(SuperGetMV( 'MV_PDDREF ' ,.F., '1' ))
cCpoVenc	:= IIF(cParVenc == '1', "E1_VENCREA" , Iif(cParVenc == '2', "E1_VENCTO" , "E1_VENCORI"))
cFilAux		:= ""

Default cAliasFJZ := ""

lConstituicao	:= FwIsInCallStack("FA645Simu")
lReversao		:= FwIsInCallStack("FA645Rev")
aTitulo			:= {}

If Empty(cAliasFJZ)
	Return aTitulo
Endif

(cAliasFJZ)->(DbGoTop())
While (cAliasFJZ)->(!Eof())

	If lConstituicao 
		If !Empty((cAliasFJZ)->(E1_NUMLIQ))
			
			If Select (cAlsF465) > 0
				(cAlsF465)->(DbCloseArea())
			Endif

			cFilAux := cFilAnt
			cFilAnt := (cAliasFJZ)->(E1_FILORIG)

			A460CalCan((cAliasFJZ)->(E1_NUMLIQ), lChkLiq, cAlsTMPPDD, @cQuery)

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlsF465, .F., .T.)

			cFilAnt := cFilAux

			If Select(cAlsF465) <= 0
				Return aTitulo
			Endif

			dSE1PaiAux	:= CTOD("")
			DbSelectArea("SE1")
			While !(cAlsF465)->(Eof())
				SE1->(dbGoto((cAlsF465)->CHAVE))
				If Empty(SE1->E1_NUMLIQ)
					If Empty(dSE1PaiAux)
						dSE1PaiAux	:= SE1->E1_VENCTO
					Else
						If SE1->E1_VENCTO <= dSE1PaiAux
							dSE1PaiAux	:= SE1->E1_VENCTO
							nChaveE1	:= (cAlsF465)->CHAVE
						Endif
					Endif
				Endif
				(cAlsF465)->(DbSkip())
			EndDo

			If Select (cAlsF465) > 0
				(cAlsF465)->(DbCloseArea())
			Endif

			If MV_PAR03 = 3 .Or. MV_PAR03 = 1

				If MV_PAR03 == 1
					If (cAliasFJZ)->(E1_EMISSAO) > MV_PAR09
						(cAliasFJZ)->(DbSkip())
						Loop
					Endif
				Endif

				If dSE1PaiAux >= (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(dbSkip())
					Loop
				Endif
			Elseif MV_PAR03 = 2
				If dSE1PaiAux > (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(dbSkip())
					Loop
				Endif
			Endif
			aAdd(aTitulo, { (cAliasFJZ)->(E1_CLIENTE), (cAliasFJZ)->(E1_LOJA) })
		ElseIf (cAliasFJZ)->(E1_SALDO) == 0
			nAtraso := MV_PAR01 - (cAliasFJZ)->(&cCpoVenc)

			If MV_PAR03 == 1

				If (cAliasFJZ)->(E1_EMISSAO) > MV_PAR09
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif

				If MV_PAR02 >= nAtraso
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			ElseIf MV_PAR03 = 2
				If (cAliasFJZ)->(&cCpoVenc) > (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			ElseIf  MV_PAR03 = 3
				If (cAliasFJZ)->(&cCpoVenc) >= (MV_PAR01 - MV_PAR02)
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			Endif
			aAdd(aTitulo, { (cAliasFJZ)->(E1_CLIENTE), (cAliasFJZ)->(E1_LOJA) })
		ElseIf  (cAliasFJZ)->(E1_SALDO) > 0
			nAtraso := MV_PAR01 - (cAliasFJZ)->(&cCpoVenc)

			If MV_PAR03 == 1 .Or. MV_PAR03 == 3

				If MV_PAR03 == 1
					If (cAliasFJZ)->(E1_EMISSAO) > MV_PAR09
						(cAliasFJZ)->(DbSkip())
						Loop
					Endif
				Endif	

				If MV_PAR02 >= nAtraso
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			ElseIf MV_PAR03 == 2 .And. (cAliasFJZ)->(&cCpoVenc) < MV_PAR01
				If nAtraso < MV_PAR02
					(cAliasFJZ)->(DbSkip())
					Loop
				Endif
			Endif
			aAdd(aTitulo, { (cAliasFJZ)->(E1_CLIENTE), (cAliasFJZ)->(E1_LOJA) })
		Endif
	ElseIf lReversao
		aAdd(aTitulo, { (cAliasFJZ)->(E1_CLIENTE), (cAliasFJZ)->(E1_LOJA) })
	Endif
	(cAliasFJZ)->(DbSkip())
EndDo

If Select (cAlsTMPPDD) > 0
	(cAlsTMPPDD)->(DbCloseArea())
Endif

Return aTitulo

//-----------------------------------------------------------
/*/{Protheus.doc} F645LEGUPD
Valida e apresenta legenda para efetivação

@author Francisco Oliveira
@since 29/08/2015
@version 12
/*/
//-----------------------------------------------------------

Static Function F645LEGUPD(oModel)

Local aAreaSE1	 As Array
Local cFilTit 	 As Character
Local cPrefix	 As Character
Local cNumero	 As Character
Local cParcela	 As Character
Local cTipo		 As Character
Local cColor	 As Character
Local nOperation As Numeric
Local dDataRef	 As Date

aAreaSE1	:= SE1->(GetArea())
cFilTit 	:= FJZ->FJZ_FILTIT
cPrefix		:= FJZ->FJZ_PREFIX
cNumero		:= FJZ->FJZ_NUM
cParcela	:= FJZ->FJZ_PARCEL
cTipo		:= FJZ->FJZ_TIPO

dDataRef	:= Posicione("FJX", 1, FJZ->FJZ_FILIAL + FJZ->FJZ_PROC, "FJX_DTREF")

nOperation	:= oModel:GetOperation()

SE1->(DbSetOrder(1))

If nOperation == 3
	cColor := "BR_VERDE"
Else
	If SE1->(DbSeek(cFilTit + cPrefix + cNumero + cParcela + cTipo))
		If SE1->E1_SALDO > 0      .And. Empty(SE1->E1_NUMLIQ)  .And. Empty(SE1->E1_BAIXA)
			cColor := "BR_VERDE"  // "Título Original 'sem' Liquidação com saldo maior que zero e sem valores de baixa"
		Elseif SE1->E1_SALDO > 0  .And. !Empty(SE1->E1_NUMLIQ) .And. Empty(SE1->E1_BAIXA)
			cColor := "BR_AZUL"  // "Título Original 'com' Liquidação com saldo maior que zero e sem valores de baixa"
		ElseIf SE1->E1_SALDO = 0  .And. Empty(SE1->E1_NUMLIQ)  .And. SE1->E1_BAIXA > SE1->E1_VENCTO .And. SE1->E1_BAIXA > dDataRef
			cColor := "BR_PRETO"  // "Título Original 'sem' Liquidação com saldo igual a zero e baixa maior que data de referencia"
		ElseIf SE1->E1_SALDO = 0  .And. !Empty(SE1->E1_NUMLIQ) .And. SE1->E1_BAIXA > SE1->E1_VENCTO .And. SE1->E1_BAIXA > dDataRef 
			cColor := "BR_VERMELHO"  // "Título Original 'com' Liquidação com saldo igual a zero e baixa maior que data de referencia"
		ElseIf SE1->E1_SALDO > 0  .And. Empty(SE1->E1_NUMLIQ)  .And. SE1->E1_BAIXA <= dDataRef .And. !Empty(SE1->E1_BAIXA)
			cColor := "BR_BRANCO"  // "Título Original 'sem' Liquidação com saldo maior que zero e baixa menor que data de referencia"
		ElseIf SE1->E1_SALDO > 0  .And. !Empty(SE1->E1_NUMLIQ) .And. SE1->E1_BAIXA <= dDataRef .And. !Empty(SE1->E1_BAIXA)
			cColor := "BR_AMARELO" // "Título Original 'com' Liquidação com saldo maior que zero e baixa menor que data de referencia"
		ElseIf SE1->E1_SALDO > 0  .And. Empty(SE1->E1_NUMLIQ)  .And. SE1->E1_BAIXA > dDataRef  .And. !Empty(SE1->E1_BAIXA)
			cColor := "BR_PINK"  // "Título Original 'sem' Liquidação com saldo maior que zero e baixa maior que data de referencia"
		ElseIf SE1->E1_SALDO > 0  .And. !Empty(SE1->E1_NUMLIQ) .And. SE1->E1_BAIXA > dDataRef  .And. !Empty(SE1->E1_BAIXA)
			cColor := "BR_LARANJA"  // "Título Original 'com' Liquidação com saldo maior que zero e baixa maior que data de referencia"
		ElseIf SE1->E1_SALDO == 0 .And. !Empty(SE1->E1_NUMLIQ) .And. SE1->E1_BAIXA <= SE1->E1_VENCTO .And. SE1->E1_BAIXA >= dDataRef
			cColor := "BR_AZUL_CLARO"  // "Título Original 'com' Liquidação com saldo igual a zero e baixa maior ou igual que data de referencia e da data vencimento"
		Else
			cColor := "BR_MARRON"  // "Outras Situações"
		Endif
	Endif
Endif

RestArea(aAreaSE1)

Return cColor
