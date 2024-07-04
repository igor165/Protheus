#INCLUDE "PLSPRO01.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TOPCONN.CH"
#include "PLSMGER.CH"
#INCLUDE "PARMTYPE.CH"    

/*/PLSPRO01
Cadastro dos Programas de Sa˙de (PromoÁ„o ‡ Sa˙de)

@author Sa˙de
@since 08/2012
@version P11.5
/*/

Static oView

Function PLSPRO01()
Local oBrowse
//Variaveis apoio consulta padr„o RE
Private cRetRis
//Private cRetDes
Private cRetEleg   := ""
Private aSx3CodTab := {"BTS","BA1"}
Private cCpoSX3    := "M->BOP_DADO"
Private cRetSX3    := ""
Private cCodTab    := ""
Private cCodPro    := ""
Private cBofCdTb   := ""//BOFCodTab()
Private lPassou    := .F.
Private aRotina	   := MenuDef()
Private lExiBO6		:=.T.
Private cCadastro := "" 
If PLSALIASEX("BO6")
	lExiBO6:=.T.
Else 
	lExiBO6:=.F.
Endif

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BOA' )
oBrowse:SetDescription( STR0002 ) //'Programa Saude'
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
/*/MenuDef
Menudef utilizado no cadastros do programa e tambÈm na janela de 
movimentaÁ„o para algumas funcionalidades

@author Sa˙de
@since 08/2012
@version P11.5
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotConh 	:= {}	//Array com as opÁıes de conhecimento
Private aRotina 	:= {}
aAdd( aRotConh, { 'Programa',			'PRO90BCO(1)'		, 0, 9, 0, NIL } )
aAdd( aRotConh, { 'Trat.N„o Med.',		'PRO90BCO(2)'		, 0, 9, 0, NIL } )

If FunName() == "PLSMPROM"	
	aAdd( aRotina, { 'Carrega lista',			'PProLoadPrg()'	  	, 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         	, 0, 1, 0, .T. } )
	aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSPRO01'	, 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Conhecimento',			'PRO90BCO(1)'	  	, 0, 9, 0, NIL } )
//	aAdd( aRotina, { 'Indicadores',				'PMPROMIND()'	  	, 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Campanhas/Eventos',		'PMPROMEVE()'	  	, 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Buscar ElegÌveis',		'PMPROMBUS()'	  	, 0, 2, 0, NIL } )	
	aAdd( aRotina, { STR0062,			'PMHISTSIN()'	  	, 0, 2, 0, NIL } )		
Else
	aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         	, 0, 1, 0, .T. } )
	aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSPRO01'	, 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSPRO01'	, 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSPRO01'	, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSPRO01'	, 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'  , 				'VIEWDEF.PLSPRO01'	, 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Copiar'    , 				'VIEWDEF.PLSPRO01'	, 0, 9, 0, NIL } )
	//aAdd( aRotina, { 'Conhecimento',			'PRO90BCO()'		, 0, 4, , .T.} )
	aAdd( aRotina, { 'Conhecimento',			aRotConh		, 0, 9, 0, NIL } )
EndIf

//oView:AddUserButton( 'Banco do Conhecimento', 'CLIPS', {|oView| Pro90Bco()} )
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBOA := FWFormStruct( 1, 'BOA', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOB := FWFormStruct( 1, 'BOB', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOC := FWFormStruct( 1, 'BOC', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOD := FWFormStruct( 1, 'BOD', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOE := FWFormStruct( 1, 'BOE', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOF := FWFormStruct( 1, 'BOF', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOG := FWFormStruct( 1, 'BOG', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOH := FWFormStruct( 1, 'BOH', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOI := FWFormStruct( 1, 'BOI', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOV := FWFormStruct( 1, 'BOV', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBOP := FWFormStruct( 1, 'BOP', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruBO6 :=NIL
Local lExiBO6:=.F.
If PLSALIASEX("BO6")
	lExiBO6:=.T.
Else 
	lExiBO6:=.F.
Endif
If lExiBO6
	oStruBO6 := FWFormStruct( 1, 'BO6', /*bAvalCampo*/, /*lViewUsado*/ )
Endif

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*{|oModel| PProVLDPos(oModel)}*/, {|oModel| PLSPROMGRV(oModel)}, /*bCancel*/ ) //'Programas de Saude'

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( 'BOAMASTER', NIL, oStruBOA )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por grid
oModel:AddGrid( 'BOBDETAIL', 'BOAMASTER', oStruBOB, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOCDETAIL', 'BOAMASTER', oStruBOC, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BODDETAIL', 'BOAMASTER', oStruBOD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOEDETAIL', 'BOAMASTER', oStruBOE, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOFDETAIL', 'BOAMASTER', oStruBOF, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOHDETAIL', 'BOAMASTER', oStruBOH, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOIDETAIL', 'BOAMASTER', oStruBOI, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOGDETAIL', 'BOAMASTER', oStruBOG, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOVDETAIL', 'BOAMASTER', oStruBOV, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'BOPDETAIL', 'BOCDETAIL', oStruBOP, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
If lExiBO6
	oModel:AddGrid( 'BO6DETAIL', 'BOGDETAIL', oStruBO6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
Endif
// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'BOBDETAIL', { { 'BOB_FILIAL', 'xFilial( "BOB" ) ' } , { 'BOB_CODPRO', 'BOA_CODPRO' } } ,  BOB->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOCDETAIL', { { 'BOC_FILIAL', 'xFilial( "BOC" ) ' } , { 'BOC_CODPRO', 'BOA_CODPRO' } } ,  BOC->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BODDETAIL', { { 'BOD_FILIAL', 'xFilial( "BOD" ) ' } , { 'BOD_CODPRO', 'BOA_CODPRO' } } ,  BOD->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOEDETAIL', { { 'BOE_FILIAL', 'xFilial( "BOE" ) ' } , { 'BOE_CODPRO', 'BOA_CODPRO' } } ,  BOE->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOFDETAIL', { { 'BOF_FILIAL', 'xFilial( "BOF" ) ' } , { 'BOF_CODPRO', 'BOA_CODPRO' } } ,  BOF->( IndexKey( 1 ) ) )  
oModel:SetRelation( 'BOHDETAIL', { { 'BOH_FILIAL', 'xFilial( "BOH" ) ' } , { 'BOH_CODPRO', 'BOA_CODPRO' } } ,  BOH->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOIDETAIL', { { 'BOI_FILIAL', 'xFilial( "BOI" ) ' } , { 'BOI_CODPRO', 'BOA_CODPRO' } } ,  BOI->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOGDETAIL', { { 'BOG_FILIAL', 'xFilial( "BOG" ) ' } , { 'BOG_CODPRO', 'BOA_CODPRO' } } ,  BOG->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOVDETAIL', { { 'BOV_FILIAL', 'xFilial( "BOV" ) ' } , { 'BOV_CODPRO', 'BOA_CODPRO' } } ,  BOV->( IndexKey( 1 ) ) )
oModel:SetRelation( 'BOPDETAIL', { { 'BOP_FILIAL', 'xFilial( "BOP" ) ' } , { 'BOP_ITEREG', 'BOC_REGRA' } } ,   BOP->( IndexKey( 1 ) ) )
If lExiBO6
	oModel:SetRelation( 'BO6DETAIL', { { 'BO6_FILIAL', 'xFilial( "BO6" ) ' } , { 'BO6_ITEM', 'BOG_ITEM' },{ 'BO6_CODCAM', 'BOG_CODCAM' },{ 'BO6_CODPRO', 'BOA_CODPRO' }   } ,   BO6->( IndexKey( 1 ) ) )// ,  
Endif	
                                             
//Define que o preenchimento È opcional para os GRIDS

oModel:SetOptional("BOEDETAIL", .T. )
oModel:SetOptional("BOFDETAIL", .T. )
oModel:SetOptional("BOHDETAIL", .T. )
oModel:SetOptional("BOIDETAIL", .T. )
oModel:SetOptional("BOGDETAIL", .T. )
oModel:SetOptional("BOVDETAIL", .T. )
If lExiBO6
	oModel:SetOptional("BO6DETAIL", .T. )
Endif
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0002 ) //'Programa Saude'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BOAMASTER' ):SetDescription( STR0002 ) //'Programa Saude'
oModel:GetModel( 'BOBDETAIL' ):SetDescription( STR0003  ) //'ClassificaÁ„o de Risco'
oModel:GetModel( 'BOCDETAIL' ):SetDescription( STR0004  ) //'Elegibilidade'
oModel:GetModel( 'BODDETAIL' ):SetDescription( STR0005  ) //'Exames/Procedimentos'
oModel:GetModel( 'BOEDETAIL' ):SetDescription( STR0006  ) //'Tratamento Nao Medicamentoso'
oModel:GetModel( 'BOFDETAIL' ):SetDescription( STR0007  ) //'Tratamento Medicamentoso'
oModel:GetModel( 'BOHDETAIL' ):SetDescription( STR0008  ) //'Sinalizadores X Programa'
oModel:GetModel( 'BOIDETAIL' ):SetDescription( STR0009  ) //'Indicadores X Programa'
oModel:GetModel( 'BOGDETAIL' ):SetDescription( STR0010  ) //'Campanhas e Eventos'
oModel:GetModel( 'BOVDETAIL' ):SetDescription( STR0011  ) //'EvoluÁao Relatorio'
oModel:GetModel( 'BOPDETAIL' ):SetDescription( "Config. Elegibilidade"  ) //'EvoluÁao Relatorio'
If lExiBO6
	oModel:GetModel( 'BO6DETAIL' ):SetDescription( "Config. Brinde"  ) //'EvoluÁao Relatorio'
Endif

//Valida se existem codigos duplicados no aCols
oModel:GetModel('BOBDETAIL'):SetUniqueLine({'BOB_GRAU'})
//oModel:GetModel('BOFDETAIL'):SetUniqueLine({'BOF_CODMED'})
oModel:GetModel('BOHDETAIL'):SetUniqueLine({'BOH_CODSIN'})
oModel:GetModel('BOIDETAIL'):SetUniqueLine({'BOI_CODIND'})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruBOA := FWFormStruct( 2, 'BOA' )
Local oStruBOB := FWFormStruct( 2, 'BOB' )
Local oStruBOC := FWFormStruct( 2, 'BOC' )
Local oStruBOD := FWFormStruct( 2, 'BOD' )
Local oStruBOE := FWFormStruct( 2, 'BOE' )
Local oStruBOF := FWFormStruct( 2, 'BOF' )
Local oStruBOG := FWFormStruct( 2, 'BOG' )
Local oStruBOH := FWFormStruct( 2, 'BOH' )
Local oStruBOI := FWFormStruct( 2, 'BOI' )
Local oStruBOV := FWFormStruct( 2, 'BOV' )
Local oStruBOP := FWFormStruct( 2, 'BOP' )
Local oStruBO6 :=NIL 
Local oModel   := FWLoadModel( 'PLSPRO01' )
Local lExiBO6:=.F.
If PLSALIASEX("BO6")
	lExiBO6:=.T.
Else 
	lExiBO6:=.F.
Endif
If lExiBO6
	oStruBO6 := FWFormStruct( 2, 'BO6' )
Endif
 // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser· utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BOA' , oStruBOA, 'BOAMASTER'   )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_BOB' , oStruBOB, 'BOBDETAIL'   )
oView:AddGrid(  'VIEW_BOC' , oStruBOC, 'BOCDETAIL'   )
oView:AddGrid(  'VIEW_BOD' , oStruBOD, 'BODDETAIL'   )
oView:AddGrid(  'VIEW_BOE' , oStruBOE, 'BOEDETAIL'   )
oView:AddGrid(  'VIEW_BOF' , oStruBOF, 'BOFDETAIL'   )
oView:AddGrid(  'VIEW_BOH' , oStruBOH, 'BOHDETAIL'   )
oView:AddGrid(  'VIEW_BOI' , oStruBOI, 'BOIDETAIL'   )
oView:AddGrid(  'VIEW_BOG' , oStruBOG, 'BOGDETAIL'   )
oView:AddGrid(  'VIEW_BOV' , oStruBOV, 'BOVDETAIL'   )
oView:AddGrid(  'VIEW_BOP' , oStruBOP, 'BOPDETAIL'   )
If lExiBO6
	oView:AddGrid(  'VIEW_BO6' , oStruBO6, 'BO6DETAIL'   )
Endif	

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRIDS', 50 )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'GRIDS' )
// Cria pastas nas folders
//addSheet(cIdFolder,cIDSheet,cTitulo,bAction)
oView:AddSheet( 'PASTAS', "ABABOB", STR0012  ) //'Class. Risco'
oView:AddSheet( 'PASTAS', "ABABOC", STR0004 ) //'Elegibilidade'
oView:AddSheet( 'PASTAS', "ABABOD", STR0013 ) //'Exames / Proc'
oView:AddSheet( 'PASTAS', "ABABOE", STR0014 ) //'Trat n„o Medic'
oView:AddSheet( 'PASTAS', "ABABOF", STR0015 ) //'Trat Medicamentoso'
oView:AddSheet( 'PASTAS', "ABABOH", STR0016 ) //'Sinalizadores X Prog '
oView:AddSheet( 'PASTAS', "ABABOI", STR0017 ) //'Indicadores X Prog'
oView:AddSheet( 'PASTAS', "ABABOG", STR0010 ) //'Campanhas e Eventos'
oView:AddSheet( 'PASTAS', "ABABOV", STR0011 ) //'EvoluÁao Relatorio'
                       
//createHorizontalBox(cID,nPercHeight,cIDOwner,lFixPixel,cIDFolder,cIDSheet)
oView:CreateHorizontalBox( 'GRID1', 100,,, 'PASTAS', "ABABOB" )
oView:CreateHorizontalBox( 'GRID2', 50,,, 'PASTAS', "ABABOC" )
oView:CreateHorizontalBox( 'GRID10', 50,,, 'PASTAS', "ABABOC" )
oView:CreateHorizontalBox( 'GRID3', 100,,, 'PASTAS', "ABABOD" )
oView:CreateHorizontalBox( 'GRID4', 100,,, 'PASTAS', "ABABOE" )
oView:CreateHorizontalBox( 'GRID5', 100,,, 'PASTAS', "ABABOF" )
oView:CreateHorizontalBox( 'GRID6', 100,,, 'PASTAS', "ABABOH" )
oView:CreateHorizontalBox( 'GRID7', 100,,, 'PASTAS', "ABABOI" )
oView:CreateHorizontalBox( 'GRID8', 50,,, 'PASTAS', "ABABOG" )
oView:CreateHorizontalBox( 'GRID11', 50,,, 'PASTAS', "ABABOG" )
oView:CreateHorizontalBox( 'GRID9', 100,,, 'PASTAS', "ABABOV" )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BOA' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_BOB' , 'GRID1'  )
oView:SetOwnerView( 'VIEW_BOC' , 'GRID2'  )
oView:SetOwnerView( 'VIEW_BOD' , 'GRID3'  )
oView:SetOwnerView( 'VIEW_BOE' , 'GRID4'  )
oView:SetOwnerView( 'VIEW_BOF' , 'GRID5'  )
oView:SetOwnerView( 'VIEW_BOH' , 'GRID6'  )
oView:SetOwnerView( 'VIEW_BOI' , 'GRID7'  )
oView:SetOwnerView( 'VIEW_BOG' , 'GRID8'  )
oView:SetOwnerView( 'VIEW_BOV' , 'GRID9'  )
oView:SetOwnerView( 'VIEW_BOP' , 'GRID10'  )
If lExiBO6
	oView:SetOwnerView( 'VIEW_BO6' , 'GRID11'  )
Endif
                    
oView:EnableTitleView( 'VIEW_BOA' )
oView:EnableTitleView( 'VIEW_BOB' )
oView:EnableTitleView( 'VIEW_BOC' )
oView:EnableTitleView( 'VIEW_BOD' )
oView:EnableTitleView( 'VIEW_BOE' )
oView:EnableTitleView( 'VIEW_BOF' )
oView:EnableTitleView( 'VIEW_BOH' )
oView:EnableTitleView( 'VIEW_BOI' )
oView:EnableTitleView( 'VIEW_BOG' )
oView:EnableTitleView( 'VIEW_BOV' )
oView:EnableTitleView( 'VIEW_BOP' )
If lExiBO6
	oView:EnableTitleView( 'VIEW_BO6' )
Endif

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_BOA', 'BOA_CODPRO' )
oView:AddIncrementField( 'VIEW_BOB', 'BOB_ITEM' )
//oView:AddIncrementField( 'VIEW_BOC', 'BOC_REGRA' )
oView:AddIncrementField( 'VIEW_BOD', 'BOD_ITEM' )
oView:AddIncrementField( 'VIEW_BOE', 'BOE_ITEM' )
oView:AddIncrementField( 'VIEW_BOF', 'BOF_ITEM' )
oView:AddIncrementField( 'VIEW_BOH', 'BOH_ITEM' )
oView:AddIncrementField( 'VIEW_BOI', 'BOI_ITEM' )
oView:AddIncrementField( 'VIEW_BOG', 'BOG_ITEM' )
oView:AddIncrementField( 'VIEW_BOV', 'BOV_ITEM' )
oView:AddIncrementField( 'VIEW_BOP', 'BOP_ITECND' )
If lExiBO6
	oView:AddIncrementField( 'VIEW_BO6', 'BO6_SEQNRO' )
Endif
//Inclus„o de Botoes
//					 Titulo do botao		nome img			funÁao
//oView:AddUserButton( 'Banco do Conhecimento', 'CLIPS', {|oView| Pro90Bco()} )
  
Return oView  

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PLSPRO01  ∫Autor  ≥Microsiga           ∫ Data ≥  08/24/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function Pro90Bco(nOpcCnh)                 

Local aArea		:= GetArea()
Local aAreaBOA	:= BOA->(GetArea())
Local aRotBack  := {}
Local cQuery	:= ""
Local cIndex	:= ""


If Type("aRotina") == "U"
	Private aRotina := {}
	//FunÁ„o exige que tenha 4 opÁıes no aRotina ================================
	AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
	AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
	AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
	aAdd( aRotina, { "Conhecimento",		"MsDocument", 0, 3, 0, NIL } )
	//============================================================================
	aRotBack := aRotina
EndIf 
If nOpcCnh == 1
	cCadastro := STR0018 //"Banco de Conhecimento Programas de Sa˙de"
	MsDocument( "BOA", BOA->( RecNo() ), 4 )
Else
	cCadastro := STR0019 //"Banco de Conhecimento Tratamentos N„o Medicamentoso"
aRotina := {{STR0020,'MsDocument',0,3}} //"Conhecimento"
	DbSelectArea("BOE")
cIndex := CriaTrab(NIL,.F.)
	//cQuery := "BOE_FILIAL == '" + xFilial("BOE") + "' "
	cQuery += " BOE_CODPRO == '" + BOA->BOA_CODPRO + "'"

	IndRegua("BOE",cIndex,BOE->(IndexKey()),,cQuery)

	If !BOE->(Eof())
		MaWndBrowse(0,0,300,600,cCadastro,"BOE",,aRotina,,,,.T.,,,,,,.F.)   
EndIf

	RetIndex( "BOE" )    
dbClearFilter()
FErase( cIndex+OrdBagExt() )
aRotina := aRotBack

EndIf
BOA->( RestArea(aAreaBOA) )
RestArea(aArea)

Return .T.      
 
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥PLSPRORIS ≥ Autor ≥ Saude              ≥ Data ≥ 20.08.20121 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Consulta da classificaÁ„o de risco cadastrada no grid      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function PLSPRORIS()
 
Local aArea     := getArea()
Local nOpca     := 0 
Local nX        := 0
Local lRet      := .T. // Retorno da configuraÁ„o escolhida
Local nPosMark  := 0
Local nLin      := 0
Local nCol      := 0
Local cTabs     := ""  
local cTitulo		:= STR0021 //"Consulta ClassificaÁ„o de Risco"
Local oModel		:= FwModelActive()
Local oBOB		:= oModel:GetModel( 'BOBDETAIL' ) //Risco		
Local aHeadBOB  	:= {}
Local aColsBOB  	:= {}
Local nPosGrau 	:= 0 
lOCAL nTamt		:=25
LOCAL oDlgBOB
Local nI		:= 0
Local nJ		:= 0
 
Private oGDDATA
Private aTrbPro := {}             

If Type("lOutModel") # "U" .AND. lOutModel
	Store Header "BOB" TO aHeadBOB For .T.	
	BOB->(DbSetOrder(1))
	If ! BOB->(DbSeek(xFilial("BOB")+BOA->BOA_CODPRO))
		Store COLS Blank "BOB" TO aColsBOB FROM aHeadBOB
	Else
		Store COLS "BOB" TO aColsBOB FROM aHeadBOB VETTRAB aTrbPro While BOB->BOB_CODPRO == BOA->BOA_CODPRO //xFilial("BOB")+BOA->BOA_CODPRO == BOB->(BOB_FILIAL+BOB_CODPRO)
	EndIf	
Else	

	oModel		:= FwModelActive()
	aHeadBOB  	:= oModel:getModel("BOBDETAIL"):aHeader  //oView:aViews[nView,3]:oBrowse:aHeader
	
	For nI := 1 To oBOB:Length() //Verifica quantas linhas tem o Model 
		oBOB:GoLine( nI ) //Vai para a primeira referente a nI
		 aAdd( aColsBOB, { oBOB:GetValue('BOB_FILIAL'), oBOB:GetValue('BOB_CODPRO'),oBOB:GetValue('BOB_ITEM'), oBOB:GetValue('BOB_GRAU'), oBOB:GetValue('BOB_RISCO'), oBOB:GetValue('BOB_IDMARK'),.F.})
	Next
				
 EndIf

nPosGrau 	:= GdFieldPos("BOB_GRAU" , aHeadBOB)  //Ascan(aHeadBOB,{ |x| x[2] == "BOB_GRAU"})
nPosRisc 	:= GdFieldPos("BOB_RISCO" , aHeadBOB) //nPosRisc 	:= Ascan(aHeadBOB,{ |x| x[2] == "BOB_RISCO"})
                                                                           
DEFINE MSDIALOG oDlgBOB TITLE cTitulo From 000, 000 To 300, 700 Of oMainWnd Pixel  
 
oGDDATA := MsNewGetDados():New(020+nTamt, 000, 300, 700,0,,,,,,,,,, oDlgBOB, aHeadBOB, aColsBOB)
                             
Activate MsDialog oDlgBOB Centered ON INIT EnchoiceBar (oDlgBOB, {	|| nOpcA := 1, oDlgBOB:End()},	{|| oDlgBOB:End()} )
        
If nOpcA == 1        
	cRetRis := oGDDATA:aCols[oGDDATA:nAt,nPosGrau]
	If Type("M->BOM_CLARIS") # "U"
		M->BOM_CLARIS := oGDDATA:aCols[oGDDATA:nAt,nPosRisc]
	EndIf  
Else
	cRetRis := "0"	
EndIf 
                                  
RestArea(aArea)
Return(lRet)  


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥PPROCOND  ≥ Autor ≥ Saude              ≥ Data ≥ 31.08.2012  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ Consulta de configuraÁ„o da condiÁ„o da elegibilidade      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function PPROCOND(cTipEle)
Local aArea     	:= getArea()
Local oModel		:= FwModelActive()
//Local oView		:= FwViewActive()
Local nOpca     	:= 0
Local lRet      	:= .T. // Retorno da configuraÁ„o escolhida
//Local cTipEle	  	:= ""
Local cTipPer		:= ""
local cTitulo		:= ""
Local cF3			:= ""
Local cDesTip		:= ""
Local cCondUsr	:= "" // CondiÁ„o para apresentar ao usuario
Local cCondStx	:= "" // Sintaxe da Condicao
Local cTitLbl		:= ""
Local cPict		:= ""
Local cX3CBox 	:= ""
Local cTitCpo 	:= ""
Local nPosTip		:= 0                                                                        
Local oDlgCond
Local cDado		:= ""
Local aTipCpo		:= {}
Local aRetBox		:= {}
Local aItensCBox	:={}
Local aItensCont	:= {"Igual", "Entre"}
Local nI			:= 0
Local cTipCpo		:= ""
Local nPosView	:= GetPosView("VIEW_BOP")
Local nLinha    	:= oModel:GetModel("BOPDETAIL"):GetLine() //Controle de numero da linha
Local nTanT			:=28

Default cTipEle 	:=  ""

Private cNum1		
Private cNum2				
Private dData1		:= CTOD("")
Private dData2		:= CTOD("")
Private cCarac1		:= SPACE(30)
Private cCarac2		:= ""
Private cCampo 		:= Space(TamSx3("GCH_CODPER")[1])
Private cCpoOld 		:= Space(TamSx3("GCH_CODPER")[1])
Private oGetCarac1
Private oComboC
Private oComboT
Private cComboT		:= ""
Private nComboT		:= 0
Private lCombo		:= .F.
Private cComboC		:= ""
Private nComboC		:= 0

If Empty(cTipEle)
	cTipEle := oModel:GetValue("BOPDETAIL", "BOP_TIPELE")	 
EndIf
cDado := Alltrim(oModel:GetValue("BOPDETAIL", "BOP_DADO"))

cTitulo	:=	STR0022 + RetCBOX("BOP_TIPELE",cTipEle) //"CondiÁ„o/Elegibilidade por: "
// Atribui variaveis de acordo com o tipo selecionado 
//0=Perguntas;1=Campos;2=Procedimento;3=PontuaÁ„o;4=Diagnostico;5=Pesquisa
If cTipEle == "0"	
	cCampo		:= IIf(!Empty(cDado), cDado, Space(TamSx3("GCH_CODPER")[1]))
	cF3			:= "GCH"
	cDesTip	:= STR0023 //"Informe a Pergunta"
	cTitLbl	:= 	STR0024 //"Resposta(s)"
ElseIf cTipEle == "1"
	cCampo	:= IIf(!Empty(cDado), cDado, Space(LEN(SX3->X3_CAMPO)))
	cF3		:= "HSPSX3"
	cDesTip:= STR0025 //"Informe o Campo"
	cTitLbl	:= 	STR0024 //"Resposta(s)"
	cCpoSX3:= "cCampo"
ElseIf cTipEle == "2" 
	cCODTAB	:= Space(TamSx3("BR8_CODPAD")[1])
	cCampo		:= Space(TamSx3("BR8_CODPSA")[1])
	cF3			:= "PLSPRO"
	cDesTip	:= STR0026 //"Informe a Tabela e o Procedimento"
	cTitLbl	:= 	STR0027 //"RecorrÍncia"
ElseIf cTipEle == "3"
	cCampo	:= Space(TamSx3("UZ_CODSCRI")[1])
	cF3		:= "SUZ1  "
	cDesTip:= STR0028 //"Informe o Script"
	cTitLbl	:= 	STR0029	 //"PontuaÁ„o"
ElseIf cTipEle == "4"	
	cCampo		:= Space(TamSx3("BA9_CODDOE")[1])
	cF3			:= "BA9PLS"
	cDesTip	:= STR0030 //"Informe o Diagnostico"
	cTitLbl	:= 	STR0027	 //"RecorrÍncia"
EndIf
DEFINE MSDIALOG oDlgCond TITLE cTitulo From 000, 000 To 230, 410 Of oMainWnd Pixel  
	
	@ 05+nTanT,010 SAY cDesTip  SIZE 120,18 PIXEL COLOR CLR_HBLUE OF oDlgCond
	@ 030+nTanT, 010 TO 0113, 150 Label cTitLbl PIXEL COLOR CLR_BLUE OF oDlgCond
	oSayDe		:= tSay():New(52+nTanT,15,{||""},oDlgCond,,,,,,.T.,CLR_HBLUE,,130,100)
	oSayAte	:= tSay():New(52+nTanT,70,{||""},oDlgCond,,,,,,.T.,CLR_HBLUE,,130,100)
	oSayAteC	:= tSay():New(67+nTanT,15,{||""},oDlgCond,,,,,,.T.,CLR_HBLUE,,130,100)
	oSayCond	:= tSay():New(05+nTanT,90,{||""},oDlgCond,,,,,,.T.,CLR_HBLUE,,130,100)
	If cTipEle == "2"
		@ 15+nTanT,15 MSGET cCODTAB F3 "B41PLS" VALID VldElegi(cTipEle) SIZE 30,10 PIXEL COLOR CLR_HBLUE OF oDlgCond				
		@ 15+nTanT,50 MSGET cCampo F3 cF3 VALID VldElegi(cTipEle, .T.) SIZE 60,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
	Else		
		@ 15+nTanT,10 MSGET cCampo F3 cF3 VALID VldElegi(cTipEle, .T.,@cTipCpo) SIZE 60,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
		//@ 25,15 MSGET cCampo F3 cF3 VALID VldElegi(cTipEle) SIZE 60,10 PIXEL COLOR CLR_HBLUE OF oDlgCond		
	EndIf
		
	If cTipEle $ "01"
		If !Empty(cDado)
			cCampo	 := cDado
			aTipCpo := ProGetTipCpo(cDado, cTipEle) //{SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE, SX3->X3_CBOX , TITULO}
			If Len(aTipCpo) > 0
				cPict	 := aTipCpo[4]
				cTipCpo := aTipCpo[1]
				cX3CBox := Alltrim(aTipCpo[5])
				cTitCpo := Alltrim(aTipCpo[6])
				If cTipCpo == "N"
					cNum1 := Space(aTipCpo[2])
					cNum2 := Space(aTipCpo[2])
				ElseIF cTipCpo == "C" .AND. !Empty(cX3CBox)				
					aRetBox := RetSx3Box( cX3CBox,,, 1)			
					For nI := 1 To Len(aRetBox)
						AADD(aItensCBox, aRetBox[nI,1])
					Next nI
				ElseIf cTipCpo == "D"
					dData1 := CTOD("")
					dData1 := CTOD("")
				Else
					
					cCarac1 := SPACE(aTipCpo[2])
					cCarac2 := SPACE(aTipCpo[2])
										
				EndIf
			EndIf		
		EndIf
		
		// CriaÁ„o dos controles		
		oSayCpo 	:= tSay():New(40+nTanT,15,{||Alltrim(cTitCpo)},oDlgCond,,,,,,.T.,CLR_HBLUE,,130,100)		
		@ 60+nTanT,15 MSGET oGetNum1 VAR cNum1 PICTURE cPict SIZE 50,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
		@ 60+nTanT,70 MSGET oGetNum2 VAR cNum2 PICTURE cPict SIZE 50,10 WHEN {|| cComboC == STR0031} PIXEL COLOR CLR_HBLUE OF oDlgCond //"Entre"
		@ 60+nTanT,15 MSGET oGetDate1 VAR dData1 PICTURE "@D" SIZE 50,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
		@ 60+nTanT,70 MSGET oGetDate2 VAR dData2 PICTURE "@D" SIZE 50,10 WHEN {|| cComboC == STR0031} PIXEL COLOR CLR_HBLUE OF oDlgCond //"Entre"
		oComboT	:= tComboBox():New(40+nTanT,015,{|u|if(PCount()>0,cComboT:=u,cComboT)},aItensCBox,065,20,oDlgCond,,,,,,.T.,,,,,,,,,"cComboT")
		@ 50+nTanT,30 MSGET oGetCarac1 VAR cCarac1 PICTURE cPict SIZE 110,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
		@ 68+nTanT,30 MSGET oGetCarac2 VAR cCarac2 PICTURE cPict WHEN {|| cComboC == STR0031} SIZE 110,10 PIXEL COLOR CLR_HBLUE OF oDlgCond //"Entre"
		oComboC 	:= tComboBox():New(15+nTanT,090,{|u|if(PCount()>0,cComboC:=u,cComboC)},aItensCont,060,20,oDlgCond,,,,,,.T.,,,,,,,,,"cComboC")
				
		// Habiltia/Desabilita visualizaÁ„o dos controles
		oGetNum1:lVisible := (cTipCpo == "N")
		oGetNum2:lVisible := (cTipCpo == "N")
		oGetDate1:lVisible := (cTipCpo == "D")
		oGetDate2:lVisible := (cTipCpo == "D")
		oComboT:lVisible := (cTipCpo == "C" .AND. !Empty(cX3CBox))
		lCombo := (cTipCpo == "C" .AND. !Empty(cX3CBox))
		oComboC:lVisible := (cTipCpo == "C" .AND. Empty(cX3CBox))		
		oGetCarac1:lVisible := (cTipCpo == "C" .AND. Empty(cX3CBox))
		oGetCarac2:lVisible := (cTipCpo == "C" .AND. Empty(cX3CBox))
		
		// Atualiza controles
		oGetNum1:Refresh()
		oGetNum2:Refresh()
		oGetDate1:Refresh()
		oGetDate2:Refresh()
		oComboT:Refresh()
		oComboC:Refresh()		
		oGetCarac1:Refresh()
		oGetCarac2:Refresh()
		// Caso nao tenha campo selecionado deixa como padr„o o de Caracter habilitado
		If Empty(cDado) 
			oGetCarac1:lVisible := .T.
			oGetCarac1:Refresh()			
		EndIf	
	ElseIf cTipEle $ "24"
		cNum1 := Space(3)
		cNum2 := Space(3)
		aItensCBox := {STR0032, STR0033, STR0034}		 //"Dia"###"MÍs"###"Ano"
		@ 38+nTanT,15 SAY STR0035  SIZE 100,8 PIXEL COLOR CLR_HBLUE OF oDlgCond	 //"Qtd. Ocorr."
		//oGetNum1 	:= tGet():New(45,15,{||cNum1}, oDlgCond, 50,10,"99",,,,,,,.T.,,,,,,,,,,"cNum1")
		@ 38+nTanT,70 SAY STR0036  SIZE 100,8 PIXEL COLOR CLR_HBLUE OF oDlgCond //"Tempo"
		//oGetNum2 	:= tGet():New(45,70,{||cNum2}, oDlgCond, 50,10,"999",,,,,,,.T.,,,,,,,,,,"cNum2")
		@ 60+nTanT,15 SAY STR0037  SIZE 100,8 PIXEL COLOR CLR_HBLUE OF oDlgCond //"Ind. Tempo"
		
		@ 45+nTanT,15 MSGET oGetNum1 VAR cNum1 PICTURE "999" SIZE 50,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
		@ 45+nTanT,70 MSGET oGetNum2 VAR cNum2 PICTURE "999" SIZE 50,10 PIXEL COLOR CLR_HBLUE OF oDlgCond		
		
		oComboT 	:= tComboBox():New(67+nTanT,015,{|u|if(PCount()>0,cComboT:=u,cComboT)},aItensCBox,080,20,oDlgCond,,,,,,.T.,,,,,,,,,"cComboT")
		oComboT:select(3)
	ElseIf cTipEle == "3"
		cNum1 := Space(3)
		cNum2 := Space(3)	
		oSayDe:setText(STR0038) //"De:"
		oSayAte:setText(STR0039) //"AtÈ:"
		@ 60+nTanT,15 MSGET oGetNum1 VAR cNum1 PICTURE "999" SIZE 50,10 PIXEL COLOR CLR_HBLUE OF oDlgCond
		@ 60+nTanT,70 MSGET oGetNum2 VAR cNum2 PICTURE "999" SIZE 50,10 PIXEL COLOR CLR_HBLUE OF oDlgCond		
								
	EndIf	
	
ACTIVATE MSDIALOG oDlgCond Centered ON INIT EnchoiceBar (oDlgCond, {	|| nOpcA := 1, oDlgCond:End()},	{|| oDlgCond:End()} )
               
If nOpcA == 1
	//Retorno do Dado	
	If cTipEle $ "01234"
		cDado := IIf(cTipEle == "2", cCODTAB+cCampo, cCampo)
	Else
		cDado := ""
	EndIf
	//Retorno da CondiÁ„o
	cCondUsr := PPro01GetCond(cTipEle, cCampo, cTipCpo, cCODTAB, @cCondStx)
	If !Empty(cDado)		
		If "DADO" $ ReadVar()		
			cRetEleg := cDado
		Else	
			oModel:SetValue("BOPDETAIL", "BOP_DADO", cDado)			
		EndIf			
	EndIf	
	If !Empty(cCondUsr)				
		If "CONDIC" $ ReadVar()
			cRetEleg := cCond
		Else
			oModel:SetValue("BOPDETAIL", "BOP_CONDIC", cCondUsr)
			oModel:SetValue("BOPDETAIL", "BOP_STXCND", cCondStx)	
		EndIf		
		// Apenas para atualizar o aCols //SÛ esta atualizando o aCols dessa maneira (setValue nao esta atribuindo atravÈs de consulta padr„o)
/*		nColCond := aScan( oView:aViews[nPosView,3]:oBrowse:aHeader, {|aVet| aVet[2] == "BOP_CONDIC"})
		nColSTX := aScan( oView:aViews[nPosView,3]:oBrowse:aHeader, {|aVet| aVet[2] == "BOP_STXCND"})						
		oView:aViews[nPosView,3]:oBrowse:aCols[nLinha, nColCond] := cCondUsr
		oView:aViews[nPosView,3]:oBrowse:aCols[nLinha, nColSTX] := cCondStx */                            
		//---------------------------------------------------------------------------------------------
	EndIf	
Else
	lRet := .F.	
EndIf 
                              
RestArea(aArea)
Return(lRet) 
 
//-----------------------------------------------------------------------------
//Retorna a estrutura e caracteristicas do campo e/ou pergunta do questionario |
//-----------------------------------------------------------------------------
Static Function ProGetTipCpo(cDado, cTipEle)
Local aRet := {}
If cTipEle == "0"
	GCH->(DbSetOrder(1))
	If GCH->(MsSeek(xFilial("GCH")+Alltrim(cDado)))
		aRet := {GCH->GCH_TIPPER, GCH->GCH_TAMRES, GCH->GCH_DECRES, GCH->GCH_PICRES, GCH->GCH_CBOX, GCH->GCH_DESPER  }
	EndIf
ElseIf cTipEle == "1"
	SX3->(DbSetOrder(2))
	If SX3->(MsSeek(Alltrim(cDado)))
		aRet := {SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE, SX3->X3_CBOX, SX3->X3_TITULO}
	EndIf
EndIf
Return(aRet)

//--------------------------------------------------------------------------
//Atualiza o dado dos controles									                |
//--------------------------------------------------------------------------
Function PPro01AtCtrl(cTipCpo, cTitCpo, cPict, cX3CBox , nTam)
Local aItensCBox 	:= {}
Local aItensCont	:= {STR0040, STR0031} //"Igual"###"Entre"
Local aRetBox		:= {}
Local nI			:= 0
// Habiltia/Desabilita visualizaÁ„o dos controles

If cCampo == cCpoOld
	Return()	
EndIf

cCpoOld := cCampo

If cTipCpo == "C" .AND. Empty(cX3CBox)
	aItensCont	:= {STR0040, STR0031, STR0041, STR0042 , STR0043, STR0044} //"Igual"###"Entre"###"Esta contido em"###"ContÈm a express„o"###"Maior Que"###"Menor Que"
EndIf

oGetNum1:lVisible := (cTipCpo == "N")
oGetNum2:lVisible := (cTipCpo == "N")
oGetDate1:lVisible := (cTipCpo == "D")
oGetDate2:lVisible := (cTipCpo == "D")
If cTipCpo == "C" .AND. !Empty(cX3CBox)
	oSayCond:setText("")
//oComboT:Show()
	If ValType(oComboT) == "O"
		oComboT:lVisible := .T.
	EndIf
//oComboC:Hide()
	If ValType(oComboC) == "O"
	EndIf
Else
	oSayCond:setText(STR0045) //"CondiÁ„o:"
	If ValType(oComboT) == "O"
		oComboT:lVisible := .F.
	EndIf
//oComboC:Hide()
	If ValType(oComboC) == "O"
		oComboC:lVisible := .T.
	EndIf

EndIf
//oComboT:lVisible := (cTipCpo == "C" .AND. !Empty(cX3CBox))
oGetCarac1:lVisible := (cTipCpo == "C" .AND. Empty(cX3CBox))
oGetCarac2:lVisible := (cTipCpo == "C" .AND. Empty(cX3CBox))

If cTipCpo == "N" //Tipo Numerico
	cNum1 := Space(nTam)
	cNum2 := Space(nTam)
	oGetNum1:Refresh()
	oGetNum2:Refresh()
	oSayDe:setText(STR0038) //"De:"
	oSayAte:setText(STR0039) //"AtÈ:"
	oSayAteC:setText("")
	If ValType(oComboC) == "O"
		oComboC:Show()
		oComboC:SetItems(aItensCont)
		oComboC:Refresh()
	EndIf
ElseIF cTipCpo == "C" .AND. !Empty(cX3CBox) //Tipo Caracter com combo/lista

	lCombo := .T.
	aRetBox := RetSx3Box( cX3CBox,,, 1)
	For nI := 1 To Len(aRetBox)
		AADD(aItensCBox, aRetBox[nI,1])
	Next nI
	oComboT:SetItems(aItensCBox)
	oComboT:Refresh()
	oSayDe:setText("")
	oSayAte:setText("")
	oSayAteC:setText("")

ElseIf cTipCpo == "D" //Tipo data

	dData1 := CTOD("")
	dData1 := CTOD("")
	oGetDate1:Refresh()
	oGetDate2:Refresh()
	oSayDe:setText(STR0038) //"De:"
	oSayAte:setText(STR0039) //"AtÈ:"
	oSayAteC:setText("")
	If ValType(oComboC) == "O"
		oComboC:Show()
		oComboC:SetItems(aItensCont)
		oComboC:Refresh()
	EndIf

Else //Tipo Caracter 

	cCarac1 := SPACE(nTam)
	cCarac2 := SPACE(nTam)
	cCpoOld := cCampo

	oGetCarac1:Picture := IIf(Empty(cPict), "@!", cPict)
	oGetCarac2:Picture := IIf(Empty(cPict), "@!", cPict)
	oGetCarac1:Refresh()
	oGetCarac2:Refresh()
	oSayDe:setText(STR0038) //"De:"
	oSayAte:setText("")
	oSayAteC:setText(STR0039) //"AtÈ:"
	If ValType(oComboC) == "O"
		oComboC:Show()
		oComboC:SetItems(aItensCont)
		oComboC:Refresh()
	EndIf
EndIf
oSayCpo:setText(cTitCpo)

Return()


//--------------------------------------------------------------------------
// VALID do campo de pesquisa de acordo com o tipo de elegibilidade        |
//--------------------------------------------------------------------------
Static Function VldElegi(cTipEle, lAtObj, cType)
Local aArea 	:= GetArea()
Local lRet 	:= .F.
Local cValue	:= &(ReadVar())

Default cType := ""

//0=Perguntas;1=Campos;2=Procedimento;3=PontuaÁ„o;4=Diagnostico;5=Pesquisa
If cTipEle == "0" //Pergunta Questionario Prontuario Eletronico
	GCH->(DbSetOrder(1))
	lRet 	:= GCH->(MsSeek(xFilial("GCH")+cValue))	
	If lRet
		If !(lRet := (GCH->GCH_TIPPER   <> "M"))			
			HELP('PLSPRO01',, 'PLSPRO01',, STR0046, 1, 0)    //"Perguntas do tipo Memo campo livre n„o s„o permitidas na condiÁ„o de busca!"
		Else
			cType := GCH->GCH_TIPPER
		EndIf
	EndIf
	If lRet .AND. lAtObj
		PPro01AtCtrl(GCH->GCH_TIPPER  , GCH->GCH_DESPER, GCH->GCH_PICRES, GCH->GCH_CBOX , GCH->GCH_TAMRES)		
	EndIf	
ElseIf cTipEle == "1" //Campos do cadastro do paciente/vida	
	SX3->(DbSetOrder(2))
	lRet := SX3->(MsSeek(cValue))
	If lRet
		If !(lRet := (SX3->X3_TIPO <> "M"))
			HELP('PLSPRO01',, 'PLSPRO01',, STR0046, 1, 0)    //"Perguntas do tipo Memo campo livre n„o s„o permitidas na condiÁ„o de busca!"
		Else
			cType := SX3->X3_TIPO		
		EndIf
	EndIf	
	If lRet .AND. lAtObj
		PPro01AtCtrl(SX3->X3_TIPO, SX3->X3_TITULO, SX3->X3_PICTURE, SX3->X3_CBOX , SX3->X3_TAMANHO)				
	EndIf	
ElseIf cTipEle == "3" //Script do modulo do call center
	SUZ->(DbSetOrder(1))
	lRet := SUZ->(MsSeek(xFilial("SUZ")+cValue))
ElseIf cTipEle == "2" //Procedimentos		
	If ReadVar() == "CCODTAB"
		lRet := (Vazio() .OR. BR4->(ExistCpo('BR4',cValue,1)))
	Else
		(lRet :=Vazio() .OR. BR8->(ExistCpo('BR8',CCODTAB+cValue,1)))
	EndIf
ElseIf cTipEle == "4" //Diagonosticos		
	BA9->(DbSetOrder(1))	
	lRet := BA9->(MsSeek(xFilial("BA9")+cValue))
EndIf

RestArea(aArea)
Return(lRet)

//--------------------------------------------------------------------------
//Retorna a posicaÁ„o da VIEW da tabela desejada dentro do objeto principal |
//--------------------------------------------------------------------------
Static Function GetPosView(cView)
local nPos := aScan(oView:aViews, {| aVet | AllTrim(aVet[1]) == cView})
Return(nPos)

//--------------------------------------------------------------------------
//VALID dos campos do formulario de cadastro dos programas 					|
//--------------------------------------------------------------------------
Function PlsPro01Vld()
Local cCpo    := ReadVar() 
Local lRet    := .T.
Local cTipo   := ""   
Local cTabPad := ""  
Local cFatGer := ""  
Local cDurac  := ""  
Local oModel  := FwModelActive()
Local nI	:=0
Local oBOB		:= oModel:GetModel( 'BOBDETAIL' ) //EndereÁo
Local aHeadBOB:={}
Local aColsBOB :={}
           
aHeadBOB  	:= oModel:getModel("BOBDETAIL"):aHeader //oView:aViews[nView,3]:oBrowse:aCols		
For nI := 1 To oBOB:Length() //Verifica quantas linhas tem o Model 
	oBOB:GoLine( nI ) //Vai para a primeira referente a nI
    aAdd( aColsBOB, { oBOB:GetValue('BOB_FILIAL'), oBOB:GetValue('BOB_CODPRO'),oBOB:GetValue('BOB_ITEM'), oBOB:GetValue('BOB_GRAU'), oBOB:GetValue('BOB_RISCO'), oBOB:GetValue('BOB_IDMARK'),.F.})
Next
		

If "BOA_INDPRI" $ cCpo
	If (lRet := (Vazio() .OR. GTA->(ExistCpo('GTA',M->BOA_INDPRI,1))))
		cCodTab := &(cCpo)
	EndIf	
                      
ElseIf "BOA_INDIND" $ cCpo
	If (lRet := (Vazio() .OR. GTA->(ExistCpo('GTA',M->BOA_INDIND,1))))
		cCodTab := &(cCpo)
	EndIf
	
ElseIf "BOA_CONPAD" $ cCpo
	If (lRet := (Vazio() .OR. BR8->(ExistCpo('BR8',M->BOA_CONPAD,3))))
		cCodTab := &(cCpo)
	EndIf			
	
ElseIf "BOP_TIPELE" $ cCpo
	cTipo := &(ReadVar())
	oModel:SetValue("BOPDETAIL", "BOP_DADO", Space(TamSx3("BOP_DADO")[1]))
	oModel:SetValue("BOPDETAIL", "BOP_CONDIC", Space(TamSx3("BOP_CONDIC")[1]))	
	PPROCOND(cTipo, .F.)

ElseIf "BOC_RISCO" $ cCpo

    nPosH := aScan(aHeadBOB, {| X | X[2] == "BOB_GRAU"})
    nPos := aScan(aColsBOB, {| aVet | aVet[nPosH] == M->BOC_RISCO})
	If (lRet := (Vazio() .OR. BOB->(ExistCpo('BOB',M->BOC_RISCO+M->BOA_CODPRO,2))).OR. nPos > 0 ) 
		cCodTab := &(cCpo)
	EndIf	

ElseIf "BOD_CODTAB" $ cCpo
	If (lRet := (Vazio() .OR. BR4->(ExistCpo('BR4',M->BOD_CODTAB,1))))
		cCodTab := &(cCpo)
	EndIf
	
ElseIf "BOD_PROCED" $ cCpo                         
	cTabPad := oModel:GetValue('BODDETAIL','BOD_CODTAB')
	If (lRet := (Vazio() .OR. BR8->(ExistCpo('BR8',cTabPad+M->BOD_PROCED,1))))
		cCodTab := &(cCpo)
	EndIf
	
ElseIf "BOD_CODSIN" $ cCpo 
	If (lRet := Vazio() .OR. BOJ->(ExistCpo('BOJ',M->BOD_CODSIN,1)))
		cCodSin := &(cCpo)
	EndIf		
	
ElseIf "BOD_CODDIS" $ cCpo 
	If (lRet := Vazio() .OR. GM6->(ExistCpo('GM6',M->BOD_CODDIS,1)))
		cCodSin := &(cCpo)
	EndIf			

ElseIf "BOD_RISCO" $ cCpo
	nPosH := aScan(aHeadBOB, {| X | X[2] == "BOB_GRAU"})
    nPos := aScan(aColsBOB, {| aVet | aVet[nPosH] == M->BOD_RISCO})  
	If (lRet := (Vazio() .OR. BOB->(ExistCpo('BOB',M->BOD_RISCO+M->BOA_CODPRO,2))).OR. nPos>0)
		cCodTab := &(cCpo)
	EndIf	
	
ElseIf "BOE_RISCO" $ cCpo
	nPosH := aScan(aHeadBOB, {| X | X[2] == "BOB_GRAU"})
    nPos := aScan(aColsBOB, {| aVet | aVet[nPosH] == M->BOE_RISCO})
	If (lRet := (Vazio() .OR. BOB->(ExistCpo('BOB',M->BOE_RISCO+M->BOA_CODPRO,2))).OR. nPos>0)
		cCodTab := &(cCpo)
	EndIf	
	
ElseIf "BOF_RISCO" $ cCpo 
	nPosH := aScan(aHeadBOB, {| X | X[2] == "BOB_GRAU"})
    nPos := aScan(aColsBOB, {| aVet | aVet[nPosH] == M->BOF_RISCO})
	If (lRet := (Vazio() .OR. BOB->(ExistCpo('BOB',M->BOF_RISCO+M->BOA_CODPRO,2))) .OR. nPos>0)
		cCodTab := &(cCpo)
	EndIf				
	
ElseIf "BOF_CODTAB" $ cCpo
	If (lRet := Vazio() .OR. BR4->(ExistCpo('BR4',M->BOF_CODTAB,1)))
		cCodTab := &(cCpo)
	EndIf	    
	
ElseIf "BOF_CODMED" $ cCpo 
	cTabPad := oModel:GetValue('BOFDETAIL','BOF_CODTAB')
	If (lRet := Vazio() .OR. BR8->(ExistCpo('BR8',cTabPad+M->BOF_CODMED,1)))
		cCodTab := &(cCpo)
	EndIf		
	
ElseIf "BOF_CODSIN" $ cCpo 
	If (lRet := Vazio() .OR. BOJ->(ExistCpo('BOJ',M->BOF_CODSIN,1)))
		cCodSin := &(cCpo)
	EndIf
	
ElseIf "BOF_PRINAT" $ cCpo 
	If (lRet := Vazio() .OR. GA0->(ExistCpo('GA0',M->BOF_PRINAT,1)))
		cCodSin := &(cCpo)
	EndIf			
	
ElseIf "BOG_CODSIN" $ cCpo 
	If (lRet := Vazio() .OR. BOJ->(ExistCpo('BOJ',M->BOG_CODSIN,1)))
		cCodSin := &(cCpo)
	EndIf	
	
ElseIf "BOG_CODCAM" $ cCpo 
	If (lRet := Vazio() .OR. SUO->(ExistCpo('SUO',M->BOG_CODCAM,1)))
		cCodTab := &(cCpo)
	EndIf 
	
ElseIf "BOG_CODSIN" $ cCpo 
	If (lRet := Vazio() .OR. BOJ->(ExistCpo('BOJ',M->BOG_CODSIN,1)))
		cCodSin := &(cCpo)
	EndIf				

ElseIf "BOH_CODSIN" $ cCpo 
	If (lRet := Vazio() .OR. BOJ->(ExistCpo('BOJ',M->BOH_CODSIN,1)))
		cCodSin := &(cCpo)
	EndIf		
	
ElseIf "BOI_CODIND" $ cCpo 
	If (lRet := Vazio() .OR. GTA->(ExistCpo('GTA',M->BOI_CODIND,1)))
		cCodTab := &(cCpo)
	EndIf			

ElseIf "BOD_DURACA" $ cCpo
	cFatGer := oModel:GetValue('BODDETAIL','BOD_FATGER')  

	If (cFatGer == '0' .And. M->BOD_DURACA == '0')
		HELP('PLSPRO01',, 'PLSPRO01',, STR0047, 1, 0) //"Para Fator de GeraÁ„o por Cotagem n„o È possivel que o campo DuraÁ„o seja  0 = Durante Programa."
		lRet := .F.
    ElseIf (cFatGer == '1' .And. M->BOD_DURACA == '1')
		HELP('PLSPRO01',, 'PLSPRO01',, STR0061, 1, 0) //"Para Fator de GeraÁ„o por PerÌodo n„o È possivel que o campo DuraÁ„o seja  1 = Dias."
		lRet := .F.		
	EndIf	 

ElseIf "BOD_FATGER" $ cCpo
	cDurac := oModel:GetValue('BODDETAIL','BOD_DURACA')  

	If (cDurac == '0' .And. M->BOD_FATGER == '0')
		HELP('PLSPRO01',, 'PLSPRO01',, STR0047, 1, 0) //"Para Fator de GeraÁ„o por Cotagem n„o È possivel que o campo DuraÁ„o seja  0 = Durante Programa."
		lRet := .F.  
	ElseIf (cDurac == '1' .And. M->BOD_FATGER == '1')
		HELP('PLSPRO01',, 'PLSPRO01',, STR0061, 1, 0) //"Para Fator de GeraÁ„o por PerÌodo n„o È possivel que o campo DuraÁ„o seja  1 = Dias."
		lRet := .F.	
	EndIf	

ElseIf "BOB_GRAU" $ cCpo


	IF len( ALLTRIM(M->BOB_GRAU))< TamSx3("BOB_GRAU  ")[1]
   		oModel:SetValue("BOBDETAIL", "BOB_GRAU", PADL(ALLTRIM(M->BOB_GRAU), TamSx3("BOB_GRAU")[1],"0"))
	Endif

ElseIf "BOV_CODPER" $ cCpo
    If (lRet := Vazio() .OR. GCH->(ExistCpo('GCH',M->BOV_CODPER,1)))
		cCodTab := &(cCpo)
	EndIf
EndIf

Return(lRet) 


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PlsIniPad   ∫Autor  ≥Microsiga         ∫ Data ≥  09/10/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function PlsIniPad()
Local cCpo    := ReadVar() 
Local cRet    := ""

Local oModel	:= FwModelActive()
Local aHeadBOI  := oModel:getModel("BOIDETAIL"):aHeader
Local aColsBOI  := oModel:getModel("BOIDETAIL"):aCols 
Local nCdIndPos := 0

nCdIndPos := Ascan(aHeadBOI,{ |x| x[2] == "BOI_CODIND"})

If "BOI_CODIND" $ cCpo
	If Inclui
		cRet := ""
	Else
		cRet := Posicione("GTA",1,sFilial("GTA")+M->BOI_CODIND,"GTA_TITULO")
	EndIf
EndIf
Return(cRet)      


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PlsVldWhen  ∫Autor  ≥Microsiga         ∫ Data ≥  09/10/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function PlsVldWhen()

Local cCpo   := ReadVar() 
Local lRet   := .F.
Local cDurac := ""
Local cTipo  := "" 
Local cTrat  := "" 
Local cItem  := "" 
Local cGerac := "" 
Local nPerio := 0
Local dData 
Local dDtFim 
Local oModel := FwModelActive()

If "BOA_DURACA" $ cCpo
	dData := oModel:GetValue('BOAMASTER','BOA_DATINI')  
	dDtFim := oModel:GetValue('BOAMASTER','BOA_DATFIM')  
	If dData == CTOD(" / / ") .And. dDtFim == CTOD(" / / ")
		lRet := .T.
	EndIf
ElseIf "BOA_DATINI" $ cCpo .Or. "BOA_DATFIM"  $ cCpo
	cDurac := oModel:GetValue('BOAMASTER','BOA_DURACA')
	If Empty(cDurac)
		lRet := .T.
	EndIf
ElseIf "BOH_DATSIN" $ cCpo
	cDurac := oModel:GetValue('BOHDETAIL','BOH_DURSIN')
	nPerio := oModel:GetValue('BOHDETAIL','BOH_PERSIN')
	If nPerio == 0 .And. Empty(cDurac)
		lRet := .T.
	EndIf
ElseIf "BOH_DURSIN" $ cCpo   
	dData := oModel:GetValue('BOHDETAIL','BOH_DATSIN')
	If dData == CTOD(" / / ")
		lRet := .T.
	EndIf
ElseIf "BOH_PERSIN" $ cCpo 
	cDurac := oModel:GetValue('BOHDETAIL','BOH_DURSIN')  
	dData := oModel:GetValue('BOHDETAIL','BOH_DATSIN')
	If dData == CTOD(" / / ") .And. !Empty(cDurac)
		lRet := .T.
	EndIf	     
ElseIf "BOD_DATPRO" $ cCpo 
	cDurac := oModel:GetValue('BODDETAIL','BOD_DURACA')  
	nPerio := oModel:GetValue('BODDETAIL','BOD_PERIOD')
	cGerac := oModel:GetValue('BODDETAIL','BOD_FATGER')
	If nPerio == 0 .And. Empty(cDurac).And. Empty(cGerac)
		lRet := .T.
	EndIf
ElseIf "BOD_PERIOD" $ cCpo 
	dData := oModel:GetValue('BODDETAIL','BOD_DATPRO')
	If dData == CTOD(" / / ")
		lRet := .T.
	EndIf
ElseIf "BOD_DURACA" $ cCpo 
	cDurac := oModel:GetValue('BODDETAIL','BOD_PERIOD')  
	dData  := oModel:GetValue('BODDETAIL','BOD_DATPRO')
	If ((dData == CTOD(" / / ") .And. !Empty(cDurac)).or. cDurac==0)
		lRet := .T.
	EndIf		
ElseIf "BOP_DADO" $ cCpo	 
	cTipo := oModel:GetValue('BOPDETAIL','BOP_TIPELE')	
	lRet :=  (cTipo <> '5')
ElseIf "BOP_CONDIC" $ cCpo 	
	cTipo := oModel:GetValue('BOPDETAIL','BOP_TIPELE')	
	lRet :=  (cTipo <> '5')
//ElseIf "BOC_QUERY" $ cCpo 	
//	cTipo := oModel:GetValue('BOPDETAIL','BOC_TIPELE')
//	lRet :=  (cTipo == '5')		
ElseIf "BOF_PRINAT" $ cCpo 	
	cTipo := oModel:GetValue('BOFDETAIL','BOF_CODMED')
	lRet  := Empty(cTipo)                                       
ElseIf "BOF_CODTAB" $ cCpo .Or. "BOF_CODMED" $ cCpo 	
	cTipo := oModel:GetValue('BOFDETAIL','BOF_PRINAT')
	lRet :=  Empty(cTipo)
ElseIf "BOE_TRATAM" $ cCpo
	cTrat := oModel:GetValue('BOEDETAIL','BOE_TRATAM') 
	cItem := oModel:GetValue('BOEDETAIL','BOE_ITEM') 
	
	dbSelectArea("AC9")
	dbSetOrder(2)//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ
	If AC9->(DbSeek(xFilial("AC9")+"BOE"+xFilial("BOE")+xFilial("BOE")+M->BOA_CODPRO+cItem+cTrat))
   		lRet :=  .F.
   	Else
   		lRet :=  .T.	
	EndIf
EndIf

Return(lRet)                                                

/*
//=====================================================================================================
Montagem da String de CondiÁ„o de Busca de forma amigavel para interpretaÁ„o do usu·rio, exemplos:    |
                                                                                                      |
Resposta da Pergunta 'Peso' igual a '090,00 kg'                               *[C001001 = '090,00 KG']|
Resposta da Pergunta 'Peso' entre '090,00 kg' e '100,00 kg'                    *[C001001  '090,00 KG']|
Resposta da Pergunta 'Peso' Esta contido em 'PACIENTE COM DORES'       *[C001001 $ 'TESTE DE SISTEMA']|
Resposta da Pergunta 'Peso' ContÈm a express„o 'DORES'                 *['TESTE DE SISTEMA' $ C001001]|
'Matricula da Vida' do cadastro Vida/Paciente igual a '45789457845'    *[BTS_MATVID = '1457854258777']|
Realizado o Procedimento/Exame: 'CONSULTA ELETIVA', 1 vez(es) no(s) ultimo(s) 1 dia(s)                |
Diagonosticado(a) com: 'INTOXICACAO ALIMENTAR ESTAFILOCOCICA', 1 vez(es) no(s) ultimo(s) 1 dia(s)     |
Obteve Score entre '10' e '20' no script de perguntas no Call Center                                  |
//=====================================================================================================
*/
Static Function PPro01GetCond(cTipEle, cCpoChv, cTipCpo, cCODTAB, cSintaxe)
Local aArea 		:= getArea()
Local cCondicao	:= ""
Local cStrUser	:= ""

Default cSintaxe	:= ""

//0=Perguntas;1=Campos;2=Procedimento;3=PontuaÁ„o;4=Diagnostico;5=Pesquisa
If cTipEle $ "01"	
	If cTipEle == "0"
		cStrUser := STR0048 //"Resposta da Pergunta: "
		GCH->(DbSetOrder(1))
		If GCH->(MsSeek(xFilial("GCH")+Alltrim(cCpoChv)))
			If !Empty(GCH->GCH_DESEXT)
				cStrUser += Alltrim(GCH->GCH_DESEXT) + " "
			Else		
				cStrUser += Alltrim(GCH->GCH_DESPER) + " "
			EndIf
		EndIf
	Else
		SX3->(DbSetOrder(2))
		If SX3->(MsSeek(Alltrim(cCpoChv)))
			cStrUser := "  " + Alltrim(SX3->X3_DESCRIC) + STR0049 //"  do cadastro da Vida "
		EndIf	
	EndIf		
	cStrUser += cComboC + " "
	Do Case
	Case cTipCpo == "N"
		If cComboC == STR0031 //"Entre"
			cStrUser += Alltrim(cNum1) + " e " + Alltrim(cNum2) + " "
			
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESNUM >= '" +  Alltrim(cNum1) + "' AND GFK.GFK_RESNUM <= '" +  Alltrim(cNum2) + "' "
			Else
				If "BTS_IDADE" == Alltrim(cCpoChv) // Tratamento para o campo idade que eh virtual ser utilizado calculo atraves da data de nascimento
					cCondicao := "BTS_DATNAS >= [PPrMenosDT(dDataBase," + Alltrim(Str(Val(cNum2)*365)) + ")] AND BTS_DATNAS <= [PPrMenosDT(dDataBase," + Alltrim(Str(Val(cNum1)*365)) + ")]"				
				Else				
					cCondicao := Alltrim(cCpoChv) + " >= " +  Alltrim(cNum1) + " AND " + Alltrim(cCpoChv) + " <= " +  Alltrim(cNum2) + " "
				EndIf
			EndIf
		ElseIf cComboC == STR0043 //"Maior Que"
			cStrUser += Alltrim(cNum1) + " "
			
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESNUM > '" +  Alltrim(cNum1) + "' "
			Else				
				If "BTS_IDADE" == Alltrim(cCpoChv) // Tratamento para o campo idade que eh virtual ser utilizado calculo atraves da data de nascimento
					cCondicao := "BTS_DATNAS >= [PPrMenosDT(dDataBase," + Alltrim(Str(Val(cNum1)*365)) + ")] "				
				Else				
					cCondicao := Alltrim(cCpoChv) + " > " +  Alltrim(cNum1) + " "
				EndIf
			EndIf
		
		ElseIf cComboC == STR0044 //"Menor Que"
			cStrUser += Alltrim(cNum1) + " "
			
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESNUM < '" +  Alltrim(cNum1) + "' "
			Else	
				If "BTS_IDADE" == Alltrim(cCpoChv) // Tratamento para o campo idade que eh virtual ser utilizado calculo atraves da data de nascimento
					cCondicao := "BTS_DATNAS <= [PPrMenosDT(dDataBase," + Alltrim(Str(Val(cNum1)*365)) + ")] "				
				Else						
					cCondicao := Alltrim(cCpoChv) + " < " +  Alltrim(cNum1) + " "
				EndIf
			EndIf
			
		Else
			cStrUser += Alltrim(cNum1) + " "
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESNUM = '" +  Alltrim(cNum1) + "'"
			Else				                                          
				If "BTS_IDADE" == Alltrim(cCpoChv) // Tratamento para o campo idade que eh virtual ser utilizado calculo atraves da data de nascimento
					cCondicao := "BTS_DATNAS >= [PPrMenosDT(dDataBase," + Alltrim(Str((Val(cNum1)+1)*365)) + ")] AND BTS_DATNAS < [PPrMenosDT(dDataBase," + Alltrim(Str(Val(cNum1)*365)) + ")]"				
				Else			
					cCondicao := Alltrim(cCpoChv) + " = " +  Alltrim(cNum1) 
				EndIf
			EndIf
			//cCondicao := "*["+cCpoChv + " = '" +  Alltrim(cNum1) + "']"
		EndIf
	Case cTipCpo == "D"
		If cComboC == STR0031 //"Entre"
			cStrUser += DTOC(dData1) + " e " + DTOC(dData2) + " "
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESDAT >= '" +  DTOS(dData1) + "' AND GFK.GFK_RESDAT <= '" +  DTOS(dData2) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " >= '" +  DTOS(dData1) + "' AND '" + Alltrim(cCpoChv) + "' <= '" +  DTOS(dData2) + "' "
			EndIf
			//cCondicao := "*["+cCpoChv + ">= '" + DTOC(dData1) + "' | " + "<= '" + DTOC(dData2) + "']"		
			//cCondicao := ">= '" + DTOC(dData1) + "' | '" + "<= " + DTOC(dData2) + "'|"
		
		ElseIf cComboC == STR0043 //"Maior Que"
			cStrUser += DTOC(dData1) + "  " 
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESDAT > '" +  DTOS(dData1) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " >= '" +  DTOS(dData1) + "' "
			EndIf

		ElseIf cComboC == STR0044 //"Menor Que"
			cStrUser += DTOC(dData1) + "  " 
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESDAT < '" +  DTOS(dData1) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " <= '" +  DTOS(dData1) + "' "
			EndIf

		Else
			cStrUser += Alltrim(cNum1) + " "
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESDAT = '" +  DTOS(dData1) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " = '" +  DTOS(dData1) + "' " 
			EndIf
			//cCondicao := "*["+cCpoChv + " = '" +  DTOC(dData1) + "']"		
			//cCondicao := " = " +  DTOC(dData1) + "|"
		EndIf
	Case cTipCpo == "C" .AND. lCombo	
		cStrUser += Alltrim(cComboT) + " "
		If cTipEle == "0"
			cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
			cCondicao += "AND GFK.GFK_RESCAR = '" +  Alltrim(cComboT) + "' "
		Else				
			cCondicao := Alltrim(cCpoChv) + " = '" +  Alltrim(cComboT) + "' " 
		EndIf		
		//cCondicao := "*["+cCpoChv + " = '" +  Alltrim(cComboT) + "']"	
		//cCondicao := " = '" +  cComboT + "'|"
	Case cTipCpo == "C" .AND. !lCombo
		If cComboC == STR0040 //"Igual"
			cStrUser += Alltrim(cCarac1) + " "
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESCAR = '" +  Alltrim(cCarac1) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " = '" +  Alltrim(cCarac1) + "' " 
			EndIf	
			//cCondicao := "*["+cCpoChv + " = '" +  Alltrim(cCarac1) + "']"		
			//cCondicao := " = '" + Alltrim(cCarac1) + "' | "
		ElseIf cComboC == STR0031 //"Entre"
			cStrUser += Alltrim(cCarac1) + STR0050 + Alltrim(cCarac2) + " " //" e "
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESCAR >= '" +  Alltrim(cCarac1) + "' AND GFK.GFK_RESCAR <= '" +  Alltrim(cCarac2) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " >= '" +  Alltrim(cCarac1) + "' AND '" + Alltrim(cCpoChv) + "' <= '" +  Alltrim(cCarac2) + "' "
			EndIf			
			//cCondicao := "*[>= '" + Alltrim(cCarac1) + "' | " + "<= '" + Alltrim(cCarac2) + "']"	
			//cCondicao := ">= '" + Alltrim(cCarac1) + "' | '" + "<= " + Alltrim(cCarac2) + "'|"
		ElseIf "ContÈm" $ cComboC
			cStrUser += Alltrim(cCarac1) + " "
			//cCondicao := "*['" + Alltrim(cCarac1) + "' $ " + cCpoChv + "]"								
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESCAR LIKE '%" +  Alltrim(cCarac1) + "%' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " LIKE '%" +  Alltrim(cCarac1) + "%' " 
			EndIf					
		ElseIf STR0051 $ cComboC //"Esta"
			cStrUser += Alltrim(cCarac1) + " "
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "				
				cCondicao += "'" + Alltrim(cCarac1) + "' LIKE '%'+RTRIM(GFK.GFK_RESCAR)+'%'" // Usa o RTRIM pra retirar os espaÁos				
			Else				
				cCondicao := "'" + Alltrim(cCarac1) + "' LIKE '%'+RTRIM(" + Alltrim(cCpoChv) + ")+'%'" // Usa o RTRIM pra retirar os espaÁos 
			EndIf			

		ElseIf cComboC $ STR0043 //"Maior Que"
			cStrUser += Alltrim(cCarac1) + "  " 
			
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESNUM > '" +  Alltrim(cCarac1) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " > '" +  Alltrim(cCarac1) + "' "
			EndIf
		
		ElseIf cComboC $ STR0044 //"Menor Que"
			cStrUser += Alltrim(cCarac1) +  "  "
			
			If cTipEle == "0"
				cCondicao := "GFK.GFK_CODPER = '" + Alltrim(cCpoChv) + "' "
				cCondicao += "AND GFK.GFK_RESNUM < '" +  Alltrim(cCarac1) + "' "
			Else				
				cCondicao := Alltrim(cCpoChv) + " < '" +  Alltrim(cCarac1) + "' "
			EndIf
						
			//cCondicao := "*["+cCpoChv + " $ '" +  Alltrim(cCarac1) + "']"			
			
		EndIf
	EndCase
ElseIf cTipEle $ "24"
	//BA9_CODDOE, BA9_DOENCA
	If cTipEle == "2"
		cStrUser := STR0052 //"Realizado o Procedimento/Exame: "
		BR8->(DbSetOrder(1))	
		If BR8->(MsSeek(xFilial("BR8")+cCODTAB + cCpoChv))
			cStrUser += Alltrim(BR8->BR8_DESCRI) + " "
		EndIf
	Else
		cStrUser := STR0053 //"Diagonosticado(a) com: "
		BA9->(DbSetOrder(1))	
		If BA9->(MsSeek(xFilial("BA9")+cCpoChv))
			cStrUser += Alltrim(BA9->BA9_DOENCA) + " "
		EndIf			
	EndIf	
			
	//1 vez(es) no(s) ultimo(s) 1 dia(s)			
	If Alltrim(cNum1) <> "0" .AND. !Empty(cNum1)
		cStrUser  += Alltrim(cNum1) + STR0054 //" vez(es) "
		If Alltrim(cNum2) <> "0" .AND. !Empty(cNum2)
			cStrUser  += STR0055 + Alltrim(cNum2) + " " + cComboT + IIf("M" $ cComboT, STR0056,STR0057)	 //" no(s) ultimos(s) "###"(es)"###"(s)"
		EndIf	
		If cTipEle == "2"
			//cCondicao := "*[" + Alltrim(cCODTAB) + "|" + Alltrim(cCpoChv) + "'|" +  Alltrim(cNum1) + "|" + Alltrim(cNum2) + "|" + SubStr(cComboT, 1,1) + "]"
			cCondicao := " BD6.BD6_CODPAD = '" +  Alltrim(cCODTAB) + "' AND BD6.BD6_CODPRO = '" +  Alltrim(cCpoChv) + "' "
			cCondicao += " AND BD6.BD6_DATPRO >= [PPrMenosDT(dDataBase," + IIf("A" $ cComboT, Alltrim(Str(Val(cNum2)*365)), IIf("M" $ cComboT, Alltrim(Str(Val(cNum2)*30)), Alltrim(cNum2) )) +  ")] "
			If Val(cNum1) > 1
				cCondicao += " HAVING COUNT(*) > " + Alltrim(Str(Val(cNum1)-1))
			EndIf 			
		Else
			cCondicao := " BD6.BD6_CID = '" +  Alltrim(cCpoChv) + "' "
			cCondicao += " AND BD6.BD6_DATPRO >= [PPrMenosDT(dDataBase," + IIf("A" $ cComboT, Alltrim(Str(Val(cNum2)*365)), IIf("M" $ cComboT, Alltrim(Str(Val(cNum2)*30)), Alltrim(cNum2) )) +  ")] "
			If Val(cNum1) > 1
				cCondicao += " HAVING COUNT(*) > " + Alltrim(Str(Val(cNum1)-1))
			EndIf 
		EndIf
	Else
		If cTipEle == "2"
			cCondicao := " BD6.BD6_CODPAD = '" +  Alltrim(cCODTAB) + "' AND BD6.BD6_CODPRO = '" +  Alltrim(cCpoChv) + "' "
		Else
			cCondicao := " BD6.BD6_CID = '" +  Alltrim(cCpoChv) + "' "
		EndIf
	EndIf
ElseIf cTipEle == "3" // Obteve Score entre '10' e '20' no script de perguntas no Call Center 
	cStrUser := STR0058 + Alltrim(cNum1) + " e " + Alltrim(cNum2) + STR0059 //"Obteve Score entre: "###" para o script "
	SUZ->(DbSetOrder(1))	
	If SUZ->(MsSeek(xFilial("SUZ")+cCpoChv))
		cStrUser += Alltrim(SUZ->UZ_DESC) + " "
	EndIf
	//cCondicao := "*[>= " + Alltrim(cNum1) + " | " + "<= " + Alltrim(cNum2) + "]"
	cCondicao := " ACI.ACI_CODSCR = '" + cCpoChv + "'  "
	cCondicao += " HAVING SUM(SUK.UK_SCORE) BETWEEN " +  Alltrim(cNum1) + " AND " +  Alltrim(cNum2)	
EndIf
If !Empty( cCondicao )   
	cSintaxe := cCondicao
EndIf
// Verifica o tamanho da string de apoio ao usuario e o tamanho da condiÁ„o, coloca a condiÁ„o no fim da String de acordo com o tamanho do campo
//nLenCnd	:= Len(Alltrim(cCondicao))
//nLenUsr	:= TamSx3("BOC_CONDIC")[1]-nLenCnd
//cCondicao	:= PADR(Alltrim(Substr(cStrUser,1,nLenUsr)),nLenUsr) + cCondicao
RestArea(aArea)
Return(cStrUser)

//--------------------------------------------------------------------------
//CriaHeader - Cria aHeader da tabela desejada								  |
//--------------------------------------------------------------------------
Static Function CriaHeader(cAlias, cExcessao)
Local  aArea		:= (cAlias)->(GetArea())
Local 	aHeadRet 	:= {}
DEFAULT cExcessao	:= "" // Campos que n„o considerados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao)) .And. (X3USO(SX3->X3_USADO))
		aAdd( aHeader, { AlLTrim( X3Titulo() ),; // 01 - Titulo
		SX3->X3_CAMPO	,;			// 02 - Campo
		SX3->X3_Picture	,;			// 03 - Picture
		SX3->X3_TAMANHO	,;			// 04 - Tamanho
		SX3->X3_DECIMAL	,;			// 05 - Decimal
		SX3->X3_Valid  	,;			// 06 - Valid
		SX3->X3_USADO  	,;			// 07 - Usado
		SX3->X3_TIPO   	,;			// 08 - Tipo
		SX3->X3_F3		,;			// 09 - F3
		SX3->X3_CONTEXT ,;       	// 10 - Contexto
		SX3->X3_CBOX	,; 	  		// 11 - ComboBox
		SX3->X3_RELACAO , } )  		// 12 - Relacao
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

//--------------------------------------------------------------------------
//PProVLDPos - ValidaÁ„o apÛs confirmaÁ„o e CriaÁ„o da Query do Progorama	  |
//--------------------------------------------------------------------------
Static Function PProVLDPos(oModel)
Local lRet			:= .T. //Variavel de retorno
Local nOperation 	:= oModel:GetOperation() // OperaÁ„o atual //inclus„o,alteraÁ„o, exclus„o,visualizaÁ„o
Local aHeadBOC	:= {} //aHeader Eleg.
Local aColsBOC	:= {} //aCols Eleg.
Local aHeadBOB	:= {} //aHeader Risco
Local aColsBOB	:= {} //aCols Risco
Local nPosGrau	:= 0 // PosiÁ„o do campo BOB_GRAU
Local nPBOBRisco	:= 0 // PosiÁ„o do campo BOB_RISCO
Local nPosDado	:= 0 // PosiÁ„o do campo BOC_DADO
Local nPosIteCnd	:= 0 // PosiÁ„o do campo BOC_ITECND
Local nPosTipEle	:= 0 // PosiÁ„o do campo BOC_TIPELE
Local nPosCondic	:= 0 // PosiÁ„o do campo BOC_CONDIC
Local nPosRisco	:= 0 // PosiÁ„o do campo BOC_RISCO
Local nPosQuery	:= 0 // PosiÁ„o do campo BOC_QUERY
Local nPosItem	:= 0 // PosiÁ„o do campo BOC_ITEM
Local nPosStxCnd 	:= 0 //  PosiÁ„o do campo BOC_STXCND
Local cCodProg	:= "" // Codigo do Programa
Local nI			:= 0 // Contador
Local cQueryFull	:= "" // Query que sera gravada no campo
Local cOpCnd		:= "" // Operador da condiÁ„o da Query OR ou AND
Local cBkIteCnd	:= "" // Guarda o item anterior da condiÁ„o pra verificar se faz parte da mesma condiÁ„o .AND. ou .OR.
Local cSelect		:= "" // Campos retorno do SELECT
Local cFrom		:= "" // Montagemdo FROM e JOIN
Local cWhere		:= "" // MOntagem das condiÁıes gerais WHERE

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE //Inclus„o ou AlteraÁ„o
	// MONTAGEM DA QUERY DE ELEGIBILIDADE DO PROGRAMA BOA_QRYELE
	// CONTROLES DO GRID DE ELEGIBILIDADE	
	aHeadBOC  	:= oModel:getModel("BOCDETAIL"):aHeader  
	aColsBOC  	:= oModel:getModel("BOCDETAIL"):aCols 
	aHeadBOP  	:= oModel:getModel("BOPDETAIL"):aHeader  
	aColsBOP  	:= oModel:getModel("BOPDETAIL"):aCols		
	
	nPosDado	:= Ascan(aHeadBOP,{ |x| x[2] == "BOP_DADO"})
	nPosIteCnd	:= Ascan(aHeadBOP,{ |x| x[2] == "BOP_ITECND"})
	nPosTipEle	:= Ascan(aHeadBOP,{ |x| x[2] == "BOP_TIPELE"}) //0=Perguntas;1=Campos;2=Procedimento;3=PontuaÁ„o;4=Diagnostico;5=Pesquisa
	nPosCondic	:= Ascan(aHeadBOP,{ |x| x[2] == "BOP_CONDIC"})
	nPosStxCnd	:= Ascan(aHeadBOP,{ |x| x[2] == "BOP_STXCND"})
	nPosRisco	:= Ascan(aHeadBOC,{ |x| x[2] == "BOC_RISCO"})
	//nPosQuery	:= Ascan(aHeadBOC,{ |x| x[2] == "BOC_QUERY"})
	nPosItem	:= Ascan(aHeadBOC,{ |x| x[2] == "BOC_REGRA"})	
	aColsBOB := aSort(aColsBOC,,, {|x,y| x[nPosRisco] + x[nPosIteCnd]  > y[nPosRisco] + y[nPosIteCnd] })  // Organiza por Risco e Intem da CondiÁ„o
	
	// CONTROLES DO GRID DE RISCO
	aHeadBOB  	:= oModel:getModel("BOBDETAIL"):aHeader  
	aColsBOB  	:= oModel:getModel("BOBDETAIL"):aCols		
	nPosGrau	:= Ascan(aHeadBOB,{ |x| x[2] == "BOB_GRAU"})
	nPBOBRisco	:= Ascan(aHeadBOB,{ |x| x[2] == "BOB_RISCO"})
	cCodProg := oModel:GetValue('BOAMASTER', 'BOA_CODPRO')
	cDesProg := Alltrim(oModel:GetValue('BOAMASTER', 'BOA_DESPRO'))	
	//"BTS_MATVID", "BTS_NOMUSR", "BOA_CODPRO", "BOA_DESPRO", "BOM_STATUS", "BOB_GRAU", "BOB_RISCO", "BOC_ITECND"
	For nI := 1 To Len(aColsBOC)
		cSelect 	:= ""
		cFrom 		:= ""
		cWhere		:= ""
		PProMntSelect(@cSelect, cCodProg, cDesProg,aColsBOC[nI,nPosIteCnd], aColsBOC[nI,nPosItem], aColsBOC[nI,nPosCondic], aColsBOC[nI,nPosRisco], PProRetQtd(aColsBOC, nPosIteCnd, aColsBOC[nI,nPosIteCnd]), aColsBOC[nI,nPosTipEle])
		PProMntJoin(@cFrom, cCodProg, aColsBOC[nI,nPosTipEle], aColsBOC[nI,nPosDado])				
		PProMntWhere(@cWhere ,aColsBOC[nI,nPosStxCnd], aColsBOC[nI,nPosTipEle])
		If !Empty(cSelect) .AND. !Empty(cFrom) .AND. !Empty(cWhere)
			If !Empty(cQueryFull)		   
				cQueryFull += Chr(10)+Chr(13)+ " UNION " + Chr(10)+Chr(13)
			EndIf
			cQueryFull += cSelect + Chr(10)+Chr(13)
			cQueryFull += cFrom + Chr(10)+Chr(13)
			cQueryFull += cWhere + Chr(10)+Chr(13)
		EndIf
	Next nI   
	
	If nI<=30  // Sera executada a query direto na Busca da Elegibili
		If !Empty(cQueryFull) // Grava a Query
			cQueryFull += Chr(10)+Chr(13) + " ORDER BY BOA_CODPRO, BTS_MATVID, BOB_GRAU DESC, BOC_ITECND, BOC_ITEM "		
			oModel:SetValue("BOAMASTER", "BOA_QRYELE", cQueryFull)
		EndIf
    Endif
EndIf

Return(.T.) //lRet

//--------------------------------------------------------------------------
//PProMntSelect - Monta a clausula SELECT da query de elegi.do Programa    |
//--------------------------------------------------------------------------
Function PProMntSelect(cStrSelect,  cTipo, cGroupBy)
If Empty(cStrSelect) // Sempre que adicionar colunas no retorno devera ser adicionado no Group By da PProMntWhere
	cStrSelect := " SELECT BTS.BTS_MATVID, BA1.BA1_USRVIP  " 
	If "2" $ cTipo .OR. "4" $ cTipo
		cStrSelect += ",BD6.BD6_DATPRO AS DATPROC, BD6.BD6_LOCAL AS PROLOCAL, '0' AS SCORE, '' AS CODSUK, '' AS CODSUC  "		
		cGroupBy := " BTS.BTS_MATVID, BA1.BA1_USRVIP, BD6.BD6_LOCAL , BD6.BD6_DATPRO "	
	ElseIf "0" $ cTipo
		cStrSelect += ",GCY.GCY_DATATE AS DATPROC, GCY.GCY_CODLOC AS PROLOCAL, '0' AS SCORE, '' AS CODSUK, '' AS CODSUC "
		cGroupBy := " BTS.BTS_MATVID, BA1.BA1_USRVIP, GCY.GCY_CODLOC , GCY.GCY_DATATE "		
	Else                                                
		If "3" $ cTipo
			cStrSelect += ",ACI_DATA AS DATPROC, '' AS PROLOCAL, '1' AS SCORE, UK_CODIGO, ACI_CODSCR "
			cGroupBy := " BTS.BTS_MATVID, BA1.BA1_USRVIP, UK_CODIGO, ACI_CODSCR,ACI_DATA "
		Else 
			cStrSelect += ", '' AS PROLOCAL, '0' AS SCORE, '' AS CODSUK, '' AS CODSUC  "   
			cGroupBy := " BTS.BTS_MATVID, BA1.BA1_USRVIP "
		EndIf
	EndIf
EndIf
Return()

//"BTS_MATVID", "BTS_NOMUSR", "BOA_CODPRO", "BOA_DESPRO", "BOM_STATUS", "BOB_GRAU", "BOB_RISCO", "BOC_ITECND"
//--------------------------------------------------------------------------
//PProMntJoin - Monta a clausula FROM  da query de elegi.do Programa 		  |
//--------------------------------------------------------------------------
 Function PProMntJoin(cFromCnd, cTipo)
Local cILJoin := "" 

If  "0" $ cTipo 
	cILJoin := ""
Else
	cILJoin := " LEFT "
EndIf	
If Empty(cFromCnd)
	//AS EXPRESS’ES ENTAO DENTRO DE [] COLCHETES PORQUE SER√O EXECUTADAS POSTERIORMENTE (NAO PODEM FICAR FIXAS NA CRIA«√O DA QUERY)
	//cFromCnd := " FROM [RetSqlName('BOA')] BOA ON BOA_CODPRO ='" + cProg + "' AND  BOA_FILIAL = '[xFilial('BOA')]'," 
	//cFromCnd += " [RetSqlName('BTS')] BTS ON BTS_FILIAL = '[xFilial('BTS')]'"
	cFromCnd += " FROM [RetSqlName('BTS')] BTS "
	cFromCnd += " JOIN [RetSqlName('BA1')] BA1 ON BTS_FILIAL = '[xFilial('BTS')]' AND BA1_FILIAL = BTS_FILIAL AND BA1_MATVID = BTS_MATVID AND BA1.D_E_L_E_T_ <> '*' "

	If HS_EXISDIC({{"C", "GBH_MATVID"}},.F.) // INTEGRA«√O VIDA X PACIENTE
		cFromCnd += cILJoin + " JOIN [RetSqlName('GBH')] GBH ON GBH_FILIAL = '[xFilial('GBH')]' AND GBH_MATVID = BTS_MATVID AND GBH.D_E_L_E_T_ <> '*' "
	Else 	
		If AllTrim(TCGetDB()) $  "MSSQL"
			cFromCnd += cILJoin + " JOIN [RetSqlName('GD4')] GD4 ON GD4_FILIAL = '[xFilial('GD4')]' AND GD4_MATRIC = (BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) AND GD4.D_E_L_E_T_ <> '*' "	
		Else
			cFromCnd += cILJoin + " JOIN [RetSqlName('GD4')] GD4 ON GD4_FILIAL = '[xFilial('GD4')]' AND GD4_MATRIC = (BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO) AND GD4.D_E_L_E_T_ <> '*' "	
        EndIf
		cFromCnd += cILJoin + " JOIN [RetSqlName('GBH')] GBH ON GBH_FILIAL = '[xFilial('GBH')]' AND GBH_CODPAC = GD4_REGGER AND GBH.D_E_L_E_T_ <> '*' "		
	EndIf
EndIf
If "0" $ cTipo .AND. !("[RetSqlName('GFU')]" $ cFromCnd)// Perguntas			
	cFromCnd += " JOIN [RetSqlName('GFU')] GFU ON GFU_FILIAL = '[xFilial('GFU')]' AND GFU_REGGER = GBH_CODPAC AND GFU.D_E_L_E_T_ <> '*' "
	cFromCnd += " JOIN [RetSqlName('GFK')] GFK ON GFK_FILIAL = '[xFilial('GFK')]' AND GFK_CDANAM = GFU_CDANAM AND GFK.D_E_L_E_T_ <> '*' "
	cFromCnd += " JOIN [RetSqlName('GCY')] GCY ON GCY_FILIAL = '[xFilial('GCY')]' AND GCY_REGATE = GFU_REGATE AND GCY.D_E_L_E_T_ <> '*' "
EndIf
If ("2" $ cTipo .OR. "4" $ cTipo) .AND. !("[RetSqlName('BD6')]" $ cFromCnd)// Perguntas// Procedimentos e Diagnosticos
	cFromCnd += " JOIN [RetSqlName('BD6')] BD6 ON BD6_FILIAL = '[xFilial('BD6')]' AND BD6_OPEUSR = BA1_CODINT  "
	cFromCnd += " AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC AND BD6_TIPREG = BA1_TIPREG AND BD6.D_E_L_E_T_ <> '*' "
EndIf

If "3" $ cTipo .AND. !("[RetSqlName('AC8')]" $ cFromCnd) // PontuaÁ„o Call Center
	cFromCnd += " JOIN [RetSqlName('AC8')] AC8 ON AC8_FILIAL = '[xFilial('AC8')]' AND AC8_ENTIDA = 'BA1'  " //PEGA O CONTATO NO CALL CENTER
	If AllTrim(TCGetDB()) $  "MSSQL"
		cFromCnd += " AND (AC8_CODENT = (BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO) "
		cFromCnd += " OR AC8_CODENT = (BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO)) "
		cFromCnd += " AND AC8.D_E_L_E_T_ <> '*' "
    Else
		cFromCnd += " AND (AC8_CODENT = (BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO) "
		cFromCnd += " OR AC8_CODENT = (BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPUSU || BA1_TIPREG || BA1_DIGITO)) "
		cFromCnd += " AND AC8.D_E_L_E_T_ <> '*' "
	EndIf
	cFromCnd += " JOIN [RetSqlName('ACI')] ACI ON ACI_FILIAL = '[xFilial('ACI')]' AND ACI_CODCON = AC8_CODCON AND  ACI.D_E_L_E_T_ <> '*' " 
	cFromCnd += " JOIN [RetSqlName('SUK')] SUK ON UK_FILIAL = '[xFilial('SUK')]' AND UK_CODIGO = ACI_CODIGO  AND  SUK.D_E_L_E_T_ <> '*' " 	
EndIf
   
Return()

//--------------------------------------------------------------------------
//PProMntWhere - Monta a clausula WHERE  da query de elegi.do Programa 		  |
//--------------------------------------------------------------------------
Function PProMntWhere(cWhereMnt, cSintaxe, cTipoMnt,cProgram)
Local nAt			:= 0
Local cWhereAux 	:= ""
Local cHaving 	:= ""
If  "2" $ cTipoMnt .OR. "3" $ cTipoMnt .OR. "4" $ cTipoMnt
	If "HAVING" $ cSintaxe
		nAt := At("HAVING", cSintaxe)
		cWhereAux := " WHERE "  
		cWhereAux += Alltrim(SubStr(cSintaxe, 1 , nAt-1))
		cWhereAux += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("BOM") + " BOM WHERE BOM.BOM_VIDA = BTS_MATVID AND BOM.BOM_CODPRO = '"+ cProgram+ "'
		cWhereAux += " AND BOM.D_E_L_E_T_ <> '*' AND"
		
		If  "2" $ cTipoMnt .OR.  "4" $ cTipoMnt
		
			cWhereAux += " ( BOM_STATUS IN('0','1','3','4') OR  (BOM_STATUS IN('2') 
      		cWhereAux += "AND BD6.BD6_DATPRO < BOM.BOM_DATALT"
      		cWhereAux += "))) "
		Else
			cWhereAux += " BOM_STATUS IN('0','1','3','4')) "
		Endif
		  		
		cWhereAux += "  [__cProWhere] "			
		cWhereAux += " GROUP BY  BTS.BTS_MATVID, BA1.BA1_USRVIP, UK_CODIGO, ACI_CODSCR,ACI_DATA "
		cWhereAux += Alltrim(SubStr(cSintaxe, nAt , Len(cSintaxe)))  + " "		
		cWhereMnt := cWhereAux
	Else
		cWhereMnt := " WHERE " + Alltrim(cSintaxe)
		cWhereMnt += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("BOM") + " BOM WHERE BOM.BOM_VIDA = BTS_MATVID AND BOM.BOM_CODPRO = '"+ cProgram+ "'
		cWhereMnt += " AND BOM.D_E_L_E_T_ <> '*' AND " 
		
		If  "2" $ cTipoMnt .OR.  "4" $ cTipoMnt
		
			cWhereMnt += " ( BOM_STATUS IN('0','1','3','4') OR  (BOM_STATUS IN('2') 
      		cWhereMnt += "AND BD6.BD6_DATPRO< BOM.BOM_DATALT"
      		cWhereMnt += "))) "
		Else
			cWhereMnt += " BOM_STATUS IN('0','1','3','4')) "
		Endif
		 
		cWhereMnt += " [__cProWhere]"   
		If "2" $ cTipoMnt .or. "4" $ cTipoMnt
			cWhereMnt += " GROUP BY  BTS.BTS_MATVID, BA1.BA1_USRVIP, BD6.BD6_LOCAL, BD6.BD6_DATPRO "    
		EndIf
	EndIf 
Else
//	cWhereMnt := " WHERE " + Alltrim(cSintaxe) + " [__cProWhere]"
	cWhereMnt := " WHERE " + Alltrim(cSintaxe)
	cWhereMnt += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("BOM") + " BOM WHERE BOM.BOM_VIDA = BTS_MATVID AND BOM.BOM_CODPRO = '"+ cProgram+ "'
	cWhereMnt += " AND BOM.D_E_L_E_T_ <> '*' AND " 
	If  "0" $ cTipoMnt 
		cWhereMnt += " ( BOM_STATUS IN('0','1','3','4') OR  (BOM_STATUS IN('2') 
   		cWhereMnt += "AND GCY.GCY_DATATE< BOM.BOM_DATALT"
   		cWhereMnt += "))) "
	Else
		cWhereMnt += " BOM_STATUS IN('0','1','3','4')) "
	Endif

 
	cWhereMnt += " [__cProWhere]"  
	If "0" $ cTipoMnt
		cWhereMnt += " GROUP BY  BTS.BTS_MATVID, BA1.BA1_USRVIP, GCY.GCY_CODLOC , GCY.GCY_DATATE "  
	Else
		cWhereMnt += " GROUP BY  BTS.BTS_MATVID, BA1.BA1_USRVIP"
	EndIf
EndIf

Return()
//--------------------------------------------------------------------------
//PProRetQtd - Retorna o numero da quantidade de condiÁıes que devem ser 	  |
//atendidas para aquela condiÁ„o ITECND									 	  |
//--------------------------------------------------------------------------
Function PProRetQtd(aColsRet, nPosCampo, cIteCND)
Local cRet		:= ""
Local nI		:= 1
Local nCount	:= 0
For nI := 1 To Len(aColsRet)
	If aColsRet[nI, nPosCampo] == cIteCND
		nCount ++
	EndIf
Next nI
cRet := Alltrim(Str(nCount))  
Return(cRet)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VldAltBod ∫Autor  ≥Microsiga          ∫ Data ≥  11/21/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Valida a alteraÁ„o da tabela BOD - Exames / Procedimentos  ∫±±
±±∫          ≥ caso exista registro na BOQ - Planejamento deve avusar ao  ∫±±
±±∫          ≥ usuarios que existe o relacionamento. 					  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SEGMENTO SAUDE                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function VldAltBod()
Local lRet	 := .T.

dbSelectArea("BOD")
dbSetorder(1) //BOD_FILIAL, BOD_CODPRO, BOD_ITEM, BOD_PROCED
BOD->(dbGoTop())

If BOD->(DbSeek(xFilial("BOD")+M->BOA_CODPRO))

	dbSelectArea("BOQ")
	dbSetorder(3) //BOQ_FILIAL, BOQ_PROGRA
	BOQ->(dbGoTop())

	If BOQ->(DbSeek(xFilial("BOQ")+BOD->BOD_CODPRO)) 
		MsgInfo(STR0060) //"Este Programa possui Planejamento Gerado!"
	Endif
Endif

Return(lRet)       

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ WhenMed    ∫Autor  ≥Microsiga         ∫ Data ≥  11/21/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ When no campo BOF_CODMED para alimentar a variavel cCodTab ∫±±
±±∫          ≥ com o conteudo do campo BOF_CODTAB.  					  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SEGMENTO SAUDE                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function PLSWhenMed()
Local cCpo    := ReadVar() 
Local oModel  := FwModelActive() 
Local lRet   := .F. 
Local cBofCdTb   := "" 

If "BOF_CODMED" $ cCpo
	cBofCdTb := oModel:GetValue('BOFDETAIL','BOF_CODTAB')

	If  !Empty(cBofCdTb)
		lRet := .T.  
		cCodTab := cBofCdTb 
	EndIf
Elseif "BOD_PROCED" $ cCpo
 
	cBofCdTb := oModel:GetValue('BODDETAIL','BOD_CODTAB')

	If  !Empty(cBofCdTb)
		lRet := .T.  
		cCodTab := cBofCdTb 
	EndIf
EndIf

Return(lRet)

Static Function PLSPROMGRV(oModel)
Local nOpc := oModel:nOperation

If nOpc != 5 
	MsgInfo("Para que a busca por Elegiveis seja eficaz, È necessario que os nÌveis de Risco cadastrados na pasta Class. Risco, "+chr(13)+chr(10)+;
			" estejam associados nos cadastros de Elegibilidade, Exames / Proc, Trat n„o Medic e Trat Medicamentoso.")
	FwFormCommit(oModel)
ElseIf nOpc == 5
	dbSelectArea("BOM")
	dbSetOrder(1)//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
	If BOM->(DbSeek(xFilial("BOM")+BOA->BOA_CODPRO))
		Help( ,, 'AtenÁ„o',, 'Este Programa nao pode ser excluido, pois, possui participantes.' , 1, 0 )
	Else
		FwFormCommit(oModel)	
	EndIf  
EndIf      

Return .T.


Function PLSVLDBON()
Local cCpo    := ReadVar() 
Local lRet    := .T.  
Local cCodTab := ""  
Local oModel  := FwModelActive()     

If "BON_CODIGO" $ cCpo
    If (lRet := Vazio() .OR. GA0->(ExistCpo('GA0',M->BON_CODIGO,1)))
		cCodTab := &(cCpo)
	EndIf	
ElseIf "BOO_CODINT" $ cCpo
    If (lRet := Vazio() .OR. GA0->(ExistCpo('GA0',M->BOO_CODINT,1)))
		cCodTab := &(cCpo)
	EndIf		
EndIf	

dbSelectArea("BON")
dbSetOrder(1)
If BON->(MsSeek(xFilial("BON")+M->BON_CODIGO))
	MsgAlert("Codigo j· gravado!")	
	lRet    := .F.
EndIf	  
	
Return lRet   

Function PLSVLDBOM()
Local cCpo    := ReadVar() 
Local lRet    := .T.  
Local cCodTab := ""  
Local oModel  := FwModelActive()    

If "BOM_CODLOC" $ cCpo
	If (lRet := (Vazio() .OR. BD1->(ExistCpo('BD1',PlsIntPad()+M->BOM_CODLOC,1))))
		cCodTab := &(cCpo)  
	EndIf		
EndIf	
	
Return lRet

Function PlsProBOP()
Local cCpo     := ReadVar() 
Local lRet     := .T.
Local cDado    := ""
local cValue	 := ""   
Local aHeadBOP := {}  
Local aColsBOP := {}    
Local oModel   := FwModelActive()
local n			:=1
Local oBOP		:= oModel:GetModel( 'BOPDETAIL' ) //EndereÁo	
Local nI		:=0
If "BOP_DADO" $ cCpo
	cDado := &(ReadVar())

	aHeadBOP  	:= oModel:getModel("BOPDETAIL"):aHeader  //oView:aViews[nView,3]:oBrowse:aHeader
	
		For nI := 1 To oBOP:Length() //Verifica quantas linhas tem o Model 
			oBOP:GoLine( nI ) //Vai para a primeira referente a nI
		 	aAdd( aColsBOP, { oBOP:GetValue('BOP_FILIAL'), oBOP:GetValue('BOP_ITEREG'),oBOP:GetValue('BOP_ITECND'), oBOP:GetValue('BOP_TIPELE'), oBOP:GetValue('BOP_DADO'), oBOP:GetValue('BOP_CONDIC'), oBOP:GetValue('BOP_STXCND'),.F.})
		Next
	//aColsBOP  	:= oModel:getModel("BOPDETAIL"):aCols //oView:aViews[nView,3]:oBrowse:aCols		
 	nPosTipo 	:= GdFieldPos("BOP_TIPELE" , aHeadBOP) 
 	
 	cTipo := aColsBOP[1][nPosTipo]
 	
 	If cTipo == '0' //PERGUNTAS
 		If (lRet := (Vazio() .OR. GCH->(ExistCpo('GCH',M->BOP_DADO,1))))
			cCodTab := &(cCpo)
		EndIf
 	
 	ElseIf cTipo == '1' //CAMPOS
 		cValue := &('M->BOP_DADO')
 		dbSelectArea("SX3")
 		dbSetOrder(2)
 		If (lRet := (Vazio() .OR. SX3->(MsSeek(cValue)))) 
			cCodTab := &(cCpo)
		EndIf
		
 	ElseIf cTipo == '2' //PROCEDIMENTO
 		If (lRet := (Vazio() .OR. BR8->(ExistCpo('BR8',M->BOP_DADO,1))))
			cCodTab := &(cCpo)
		EndIf
 	
 	ElseIf cTipo == '3' //PONTUA«AO
 		If (lRet := (Vazio() .OR. SUZ->(ExistCpo('SUZ',M->BOP_DADO,1))))
			cCodTab := &(cCpo)
		EndIf
		
 	ElseIf cTipo == '4' //DIAGNOSTICO
		If (lRet := (Vazio() .OR. BA9->(ExistCpo('BA9',M->BOP_DADO,1))))
			cCodTab := &(cCpo)
		EndIf
	EndIf	
EndIf

Return(lRet) 
