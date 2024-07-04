#INCLUDE "Protheus.ch"
#INCLUDE "RU07D10.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} RU07D10
Action of Vacation Register File 

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D10()
Local aCoors  		as Array
Local cIdBrowse 	as Character
Local cIdGrid 		as Character
Local cEntida		as Character
Local oPanelUp 		as Object
Local oPanelDown 	as Object
Local oTela 		as Object
Local oRelacAGA 	as Object

Private oDlgPrinc	as Object
Private oBrowseUp	as Object
Private oBrowseDwn	as Object

cEntida	:="RD0"

aCoors	:= FWGetDialogSize( oMainWnd )

Define MsDialog oDlgPrinc Title OemToAnsi( STR0001 ) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Addresses"

// Create container where panels will be created
oTela     := FWFormContainer():New( oDlgPrinc )
cIdBrowse := oTela:CreateHorizontalBox( 50 )
cIdGrid   := oTela:CreateHorizontalBox( 50 )

oTela:Activate( oDlgPrinc, .F. )

// Create panels where browses will be created
oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
oPanelDown  := oTela:GeTPanel( cIdGrid )

// FWmBrowse Superior: Employees
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )   
oBrowseUp:SetDescription(STR0002 ) //"Employees"
//oBrowseUp:SetMenuDef( 'FAKE' )
oBrowseUp:SetAlias( 'RD0' )
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.) 
//oBrowseUp:ExecuteFilter(.T.)

// Set caption for Employees
oBrowseUp:AddLegend( "RD0->RD0_MSBLQL == '2'", 	"GREEN", STR0014) // Active
oBrowseUp:AddLegend( "RD0->RD0_MSBLQL == '1'", 	"RED"  , STR0015 )//Inactive

oBrowseUp:Activate()

// FWmBrowse Inferior: Vacation items
oBrowseDwn:= BrowseDef()
oBrowseDwn:SetOwner( oPanelDown )

// Set relationship between panels
oRelacAGA:= FWBrwRelation():New()
oRelacAGA:AddRelation( oBrowseUp  , oBrowseDwn , {{ 'AGA_ENTIDA', "'"+cEntida+"'" }, { 'AGA_CODENT' , 'RD0_FILIAL'+"+"+'Padr(RD0_CODIGO,(TamSx3("AGA_CODENT")[1])-(TamSx3("RD0_FILIAL")[1]))' } } )
oRelacAGA:Activate()

oBrowseDwn:Activate()

oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Private oBrowse as object

// FWmBrowse Inferior: Addresses items
oBrowse:= FWMBrowse():New()
oBrowse:SetMenuDef( 'RU07D10' )
oBrowse:DisableDetails()
oBrowse:SetAlias( 'AGA' )
oBrowse:SetProfileID( '2' )
oBrowse:ForceQuitButton()	
oBrowse:SetCacheView(.F.)
oBrowse:SetOnlyFields( { 'AGA_CODENT', 'AGA_NAMENT', 'AGA_TIPO', 'AGA_FROM', 'AGA_TO', 'AGA_FULLV' } )
oBrowse:AddLegend( "AGA->AGA_TO >= dDatabase" , "GREEN"	, STR0014 ) 	//"Active"
oBrowse:AddLegend( "AGA->AGA_TO < dDatabase"  , "RED" 	, STR0015 ) 	//"Inactive"	

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina Title STR0011 	Action 'VIEWDEF.RU07D10' OPERATION 2  ACCESS 0 DISABLE MENU  //"View"
ADD OPTION aRotina Title STR0012 	Action 'VIEWDEF.RU07D10' OPERATION 3  ACCESS 0 DISABLE MENU  //"Add"
ADD OPTION aRotina Title STR0013 	Action 'VIEWDEF.RU07D10' OPERATION 4  ACCESS 0 DISABLE MENU  //"Edit"

Return aRotina 


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel		as Object
Local oStructAGA	as Object
Local cEntida		as Character
Local cPais 		as Character
Local cPaisde 		as Character
Local cCodEnt       as Character

cEntida	:= "RD0"
cPais   :="643"
cCodEnt := RD0->RD0_FILIAL+RD0->RD0_CODIGO 
cPaisde :=IIF(!INCLUI,Posicione("SYA",1,xFilial("SYA")+AGA->AGA_PAIS,"YA_DESCR"),Posicione("SYA",1,xFilial("SYA")+"643","YA_DESCR")) 

oModel:= MPFormModel():New("RU07D10", /*bPreValid*/,/* bTudoOK*/, /* bCommit*/, /*bCancel*/)

// Structure - AGA Addresses
oStructAGA := FWFormStruct(1, "AGA")
oStructAGA:AddField(GetSx3Info("RD0_CODIGO")[1], GetSx3Info("RD0_CODIGO")[2], "RD0_CODIGO", "C", TamSX3("RD0_CODIGO")[1], 0, Nil, Nil, {}, .T., Nil, .F.)

oStructAGA:SetProperty( 'AGA_ENTIDA',MODEL_FIELD_INIT,{||cEntida})
oStructAGA:SetProperty( 'AGA_CODENT',MODEL_FIELD_INIT,{||cCodEnt})
oStructAGA:SetProperty( 'AGA_PAIS',MODEL_FIELD_INIT,{||cPais})
oStructAGA:SetProperty( 'AGA_PAISDE',MODEL_FIELD_INIT,{||cPaisde})
oStructAGA:SetProperty( 'AGA_NAMENT',MODEL_FIELD_INIT,{||RD0->RD0_NOME})

oModel:AddFields("RU07D10_MAGA", NIL, oStructAGA)
oModel:SetPrimaryKey({'AGA_FILIAL','AGA_CODIGO','AGA_ENTIDA','AGA_CODENT'})
oModel:SetRelation("RU07D10_MAGA",{{ 'AGA_FILIAL', 'xFilial( "RD0" )' },{ 'AGA_ENTIDA', "'"+cEntida+"'" },{ 'AGA_CODENT' , 'RD0->RD0_FILIAL'+"+"+'Padr(RD0->RD0_CODIGO,(TamSx3("AGA_CODENT")[1])-(TamSx3("RD0_FILIAL")[1]))'  }, {'AGA_CODIGO', 'AGA->AGA_CODIGO' }})

oModel:SetActivate({ |oModel| RU07D1002(oModel)})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()

Local oView 		as Object
Local oModel 		as Object
Local oStructAGA 	as Object

oModel := FWLoadModel("RU07D10")

oView := FWFormView():New()
oView:SetModel(oModel)

// structure - AGA addresses
oStructAGA := FWFormStruct(2, "AGA")
oStructAGA:SetNoFolder()
oStructAGA:RemoveField( "AGA_ENTIDA" )
oStructAGA:RemoveField( "AGA_FILIAL" )
oStructAGA:RemoveField( "AGA_CODIGO" )
oStructAGA:RemoveField( "AGA_CODENT" )

oStructAGA:AddField("RD0_CODIGO", ; // Field ID
    "01", ;                         // Order of the field
    GetSx3Info("RD0_CODIGO")[1], ;  // Title of the field
    GetSx3Info("RD0_CODIGO")[2], ;  // Full field description
    Nil, ;                          // Array with Field Help
    "C", ;                          // Type
    "",  ;                          // Picture of the field
    Nil, ;                          // Picture block Var
    Nil, ;                          // Key to be used in LooKUp
    .F., ;                          // Logical indicating if the field can be changed
    Nil, ;                          // Folder ID where the field is
    Nil, ;                          // Group ID where the field is
    Nil, ;                          // Array with Combo Values (not mandatory)
    Nil, ;                          // Maximum size of the largest combo option (not mandatory)
    Nil, ;                          // Browse Initializer
    .T., ;                          // Indicates whether the field is virtual
    Nil, ;                          // Variable Picture
    Nil)                            // If true, indicates linefeed after field

oView:AddField("RU07D10_VAGA", oStructAGA, "RU07D10_MAGA" )

oView:CreateHorizontalBox("AGA_HEAD", 100)

oView:SetOwnerView( "RU07D10_VAGA", "AGA_HEAD" )

oView:SetCloseOnOk( { || .T. } )

Return ( oView )


/*/{Protheus.doc} RU07D1001
check aga_tipo .
Use SX3 for aga_tipo cbox
@author Marina Dubovaya
@since 30/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D1001()
Local cOpcBox	:= "" 

IF  FwIsInCallStack("RU07D10RUS")
	 cOpcBox += ( "3=" + STR0004 + ";"	)	//"Registration Address"
	 cOpcBox += ( "4=" + STR0005 + ";"	)	//"Actual Address"
	 cOpcBox += ( "5=" + STR0006 + ";"	)	//"Address for information"
 	 cOpcBox += ( "6=" + STR0007       )	//"Foreigner`s Address"	
	Else 
     cOpcBox += ( "0=" + STR0008 + ";"	)	//"Legal"
	 cOpcBox += ( "1=" + STR0009 + ";"	)	//"Factual"
	 cOpcBox += ( "2=" + STR0010       )	//"Postal" 
EndIf

Return( cOpcBox )


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D1002
Fills RD0_CODIGO when Model is activated

@author dtereshenko
@since 07/05/2019
@version 1.0
@project MA3 - Russia
/*/
Static Function RU07D1002(oModel as Object)
    Local oStructAGA As Object 

    oStructAGA := oModel:GetModel("RU07D10_MAGA")

    oStructAGA:LoadValue("RD0_CODIGO", RD0->RD0_CODIGO)

Return .T.


// Russia_R5
