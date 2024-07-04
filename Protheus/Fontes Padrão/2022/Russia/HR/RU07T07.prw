#INCLUDE "Protheus.ch"
#INCLUDE "RU07T07.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} RU07T07
Action of Vacation Register File 

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T07()
Local aCoors  		as Array
Local cIdBrowse 	as Character
Local cIdGrid 		as Character
Local oPanelUp 		as Object
Local oPanelDown 	as Object
Local oTela 		as Object
Local oRelacF4E 	as Object

Private oDlgPrinc	as Object
Private oBrowseUp	as Object
Private oBrowseDwn	as Object

aCoors	:= FWGetDialogSize( oMainWnd )

Define MsDialog oDlgPrinc Title OemToAnsi( STR0001 ) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Action of Vacation"

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
oBrowseUp:SetMenuDef( 'FAKE' )
oBrowseUp:SetAlias( 'SRA' )
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.) 
oBrowseUp:ExecuteFilter(.T.)

// Set caption for Employees
oBrowseUp:AddLegend( "SRA->RA_MSBLQL == '2'", 	"GREEN", STR0014) // Active
oBrowseUp:AddLegend( "SRA->RA_MSBLQL == '1'", 	"RED"  , STR0015 )//Inactive

oBrowseUp:Activate()

// FWmBrowse Inferior: Vacation items
oBrowseDwn:= BrowseDef()
oBrowseDwn:SetOwner( oPanelDown )

// Set relationship between panels
oRelacF4E:= FWBrwRelation():New()
oRelacF4E:AddRelation( oBrowseUp  , oBrowseDwn , { { 'F4E_FILIAL', 'RA_FILIAL' }, { 'F4E_CODE' , 'RA_CODUNIC'  }, { 'F4E_MAT' , 'RA_MAT'  } } )
oRelacF4E:Activate()

oBrowseDwn:Activate()

oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Private oBrowse as object

// FWmBrowse Inferior: Vacation items
oBrowse:= FWMBrowse():New()
oBrowse:SetDescription(STR0003)	//"Vacation items"
oBrowse:SetMenuDef( 'RU07T07' )
oBrowse:DisableDetails()
oBrowse:SetAlias( 'F4E' )
oBrowse:SetProfileID( '2' )
oBrowse:ForceQuitButton()	
oBrowse:SetCacheView (.F.)
oBrowse:ExecuteFilter(.T.)
oBrowse:AddLegend( "F4E_STATUS $ '1*2'" 	, "RED" 	, STR0004 ) 	//"Pending Vacation"  
oBrowse:AddLegend( "F4E_STATUS $ '3*4*5'" 	, "BLUE" 	, STR0005 ) 	//"Closed Vacation"	 

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina Title STR0006 	Action 'PesqBrw'         OPERATION 1  ACCESS 0 DISABLE MENU  //"Seach" 
ADD OPTION aRotina Title STR0007 	Action 'VIEWDEF.RU07T07' OPERATION 2  ACCESS 0 DISABLE MENU  //"View"
ADD OPTION aRotina Title STR0008 	Action 'VIEWDEF.RU07T07' OPERATION 3  ACCESS 0 DISABLE MENU  //"Add"
ADD OPTION aRotina Title STR0009 	Action 'VIEWDEF.RU07T07' OPERATION 4  ACCESS 0 DISABLE MENU  //"Edit"

Return aRotina 


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel		as Object
Local oStructF4E	as Object
Local oStructF4F 	as Object	

oModel:= MPFormModel():New("RU07T07", /*bPreValid*/,/* bTudoOK*/, /* bCommit*/, /*bCancel*/)
    
// Header structure - F4E Vacation Action
oStructF4E := FWFormStruct(1, "F4E") 
oModel:AddFields("RU07T07_MF4E", NIL, oStructF4E)
oModel:SetPrimaryKey({'F4E_FILIAL','F4E_CODE','F4E_MAT','F4E_INIDT'})

// Items structure - F4F Vacation Absences
oStructF4F := FWFormStruct(1, "F4F")
oModel:AddGrid("RU07T07_MF4F", "RU07T07_MF4E", oStructF4F, /*bLinePre*/, /*{ |oGrid| RUT07LOk(oGrid) }*/, /*bPre*/, /*{ |oGrid| RUT07TOk(oGrid) }*/,/*bLoad*/)
oModel:SetPrimaryKey({'F4F_FILIAL','F4F_MAT','F4F_SEQ','F4F_ABSCO','F4F_INIDT'})
oModel:GetModel("RU07T07_MF4F"):SetUniqueLine( {'F4F_ABSCO','F4F_ABSDY','F4F_INIDT' ,'F4F_FINDT'} )
oModel:GetModel("RU07T07_MF4F"):SetDescription( STR0010 ) //"Vacation Absences" 

oModel:SetRelation( "RU07T07_MF4F", { { "F4F_FILIAL", 'F4E_FILIAL' }, { "F4F_MAT", 'F4E_MAT' }, { "F4F_INIDT", 'F4E_INIDT' }}, F4F->( IndexKey( 1 ) ) )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStructF4E 	as Object
Local oStructF4F 	as Object

oModel := FWLoadModel("RU07T07")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - F4E Vacation Action
oStructF4E := FWFormStruct(2, "F4E")
oStructF4E:SetNoFolder()
oView:AddField("RU07T07_VF4E", oStructF4E, "RU07T07_MF4E" )

// Items structure - F4F Vacation Absences
oStructF4F := FWFormStruct(2, "F4F")
oStructF4F:RemoveField( "F4F_MAT" )

oView:AddGrid("RU07T07_VF4F", oStructF4F, "RU07T07_MF4F" )
oView:AddIncrementField("RU07T07_VF4F","F4F_SEQ")

oView:CreateHorizontalBox("F4E_HEAD", 50)
oView:CreateHorizontalBox("F4F_ITEM", 50)

oView:SetOwnerView( "RU07T07_VF4E", "F4E_HEAD" )
oView:SetOwnerView( "RU07T07_VF4F", "F4F_ITEM" )

oView:addUserButton(STR0011, "RU07T07", { |oView| RU07T07Prt( oView ) } ) 	//"Print Order" 

oView:SetCloseOnOk( { || .T. } )

Return ( oView )


//-------------------------------------------------------------------
/*
{Protheus.doc}  RU07T07Prt()
Function for print the order
@author raquel.andrade
@since 18/05/2018
@version 1.0
*/
Function RU07T07Prt(oView as Object)
Local cFileOpen as Character 
Local cFileSave as Character 
Local cSeq 		as Character 
Local cCode		as Character 
Local oWord 	as Object
Local oModel	as Object
Local oModelH	as Object
Local oModelI	as Object

oModel	:= oView:GetModel()
oModelH	:= oModel:GetModel("RU07T07_MF4E")
oModelI	:= oModel:GetModel("RU07T07_MF4F")
cCode	:= oModelH:GetValue('F4E_CODE')
cSeq 	:= oModelI:GetValue('F4F_SEQ')


If Pergunte("SAVEORD01",.T.)
	cFileOpen := alltrim(MV_PAR01)
	cFileSave := alltrim(MV_PAR02) + STR0012 +"_"+ cCode + "_" + cSeq + ".Docx" // VACOrder_Per.Reg.Number_Sequence
	If cFileOpen!="" .AND. !RAT(".DOC", UPPER(cFileOpen)) 
		MsgInfo(STR0013,STR0011) //"File selected has incorrect type."###"Print Order"
	Else
		oWord := OLE_CreateLink()
		If File(cFileOpen)
			OLE_OpenFile(oWord, cFileOpen)
		Else
			OLE_NewFile(oWord)
		EndIf
		OLE_SaveAsFile( oWord, cFileSave,,,.F. )
	EndIf
EndIf
	
Return (.T.)


	
// Russia_R5
