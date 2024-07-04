#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T06.CH"

/*/{Protheus.doc} RU07T06RUS
Terminations (RUS localization os routine)

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T06RUS()
	Local	aArea
	Local	aCoors
	Local	oScreen
	Local	cIdBrowse	as Character
	Local	cIdGrid		as Character
	Local	oPanelUp
	Local	oPanelDown
	Local	oRelacSRG
	Local 	aParam
	Local 	cFilt		as Character	

	Private	oDlgPrinc
	Private	oBrowseUp
	Private	oBrowseDwn

	aParam  := {}

	aArea		:= GetArea()
	aCoors		:= FWGetDialogSize( oMainWnd )

	Define	MsDialog oDlgPrinc	Title OemToAnsi(STR0001)	From aCoors[1], aCoors[2] To aCoors[3], aCoors[4]	OF oMainWnd Pixel  // "Action of Termination"

	// Create container where panels will be created
	oScreen		:= FWFormContainer():New( oDlgPrinc )
	cIdBrowse	:= oScreen:CreateHorizontalBox( 60 )
	cIdGrid		:= oScreen:CreateHorizontalBox( 35 )

	If PERGUNTE ("GPEA010RUS", .T.)
		AAdd( aParam, UPPER( alltrim( MV_PAR01 ) ) )
		AAdd( aParam, UPPER( alltrim( MV_PAR02 ) ) )
		AAdd( aParam, UPPER( alltrim( MV_PAR03 ) ) )
		AAdd( aParam, DTOS( MV_PAR04 ) )
		AAdd( aParam, UPPER( alltrim( MV_PAR05 ) ) )
	EndIf

	cFilt := ActFiltRUS( aParam )

	oScreen:Activate( oDlgPrinc, .F. )

	// Create panels where browses will be created
	oPanelUp  	:= oScreen:GeTPanel( cIdBrowse )
	oPanelDown  := oScreen:GeTPanel( cIdGrid )

	// FWmBrowse Superior: Employees
	oBrowseUp	:= FWmBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )			// Associate browse with panel
	oBrowseUp:SetDescription( STR0002 )	
	oBrowseUp:SetMenuDef( "RU07T0" )
	oBrowseUp:DisableDetails()
	oBrowseUp:SetAlias( "SRA" )
	oBrowseUp:SetProfileID( "1" )
	oBrowseUp:SetCacheView( .F. ) 
	oBrowseUp:ExecuteFilter( .T. )
	oBrowseUp:SetFilterDefault(cFilt)
	
	// Set caption for Employees
	oBrowseUp:AddLegend( "SRA->RA_MSBLQL == '2'", 	"GREEN" ,	OemToAnsi( STR0013 ) )
	oBrowseUp:AddLegend( "SRA->RA_MSBLQL == '1'", 	"RED"  ,	OemToAnsi( STR0014 ) ) 

	oBrowseUp:Activate()

	oBrowseDwn	:=	BrowseDef()
	oBrowseDwn:SetOwner( oPanelDown )

	// Set relationship between panels
	oRelacSRG	:= FWBrwRelation():New()
	oRelacSRG:AddRelation( oBrowseUp, oBrowseDwn, { { "RG_FILIAL", "RA_FILIAL" }, { "RG_CODE", "RA_CODUNIC" }, { "RG_MAT", "RA_MAT" } } )
	oRelacSRG:Activate()

	oBrowseDwn:Activate()

	oBrowseUp:Refresh()
	oBrowseDwn:Refresh()

	Activate MsDialog oDlgPrinc Center

	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} BrowseDef
Browse definition.

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU07T06")

Return oBrowse 

/*/{Protheus.doc} MenuDef
Menu Definition.

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07T06")

Return aRotina

/*/{Protheus.doc} ModelDef
Model Definition.

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object

	oModel 	:= FwLoadModel( "RU07T06" )

	oModel:GetModel("GPEM040_MSRG"):GetStruct():SetProperty( "RG_CODE", MODEL_FIELD_INIT, FwBuildFeature(  STRUCT_FEATURE_INIPAD, "SRA->RA_CODUNIC" ) )
	oModel:GetModel("GPEM040_MSRG"):GetStruct():SetProperty( "RG_MAT", MODEL_FIELD_INIT, FwBuildFeature(  STRUCT_FEATURE_INIPAD, "SRA->RA_MAT" ) )
	oModel:GetModel("GPEM040_MSRG"):GetStruct():SetProperty( "RG_NOME", MODEL_FIELD_INIT, FwBuildFeature(  STRUCT_FEATURE_INIPAD, "SRA->RA_NOME" ) )

Return oModel

/*/{Protheus.doc} ViewDef
View Definition.

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView		as object

oView	:= 	FWLoadView( "RU07T06" )

oView:AddUserButton( STR0009, "RU07T06", { |oView| RU07T06Prt( oView ) } )

Return oView

/*/
{Protheus.doc} RU07T06Prt()
Function for print the order
@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
/*/
Function RU07T06Prt()
	Local oWord as Object
    Local cFileOpen as Character 
    Local cFileSave as Character 

	if pergunte("SAVEORD01",.T.)
		cFileOpen	:= alltrim(MV_PAR01)
		cFileSave	:= alltrim(MV_PAR02) + STR0010 + "_"+ SRA->RA_MAT + ".Docx"   //name of files "AdmissOrder_%CODE%"
		If cFileOpen!="" .AND. !RAT(".DOC", UPPER(cFileOpen)) 
			MsgInfo(STR0008, STR0009)    //error message "The file of the incorrect type is selected."
		Else
			oWord := OLE_CreateLink()
			If File(cFileOpen)
				OLE_OpenFile(oWord, cFileOpen)
			Else
				OLE_NewFile(oWord)
			EndIf
			OLE_SaveAsFile( oWord, cFileSave,,,.F. )
		ENDIF
	endIf
 
RETURN (.T.)
