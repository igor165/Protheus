#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T06.CH"
#Include "TopConn.ch"
#Include "MSOle.ch"

/*/{Protheus.doc} RU07T06
Terminations

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T06()

	Local	aArea
	Local	aCoors

	Local	oScreen		as Object
	Local	oPanelUp	as Object
	Local	oPanelDown	as Object
	Local	oRelacSRG	as Object
	Local	cIdBrowse	as Character 
	Local	cIdGrid		as Character 

	Private	oDlgPrinc	as Object
	Private	oBrowseUp	as Object
	Private	oBrowseDwn	as Object

	aArea		:= GetArea()
	aCoors  	:= FWGetDialogSize( oMainWnd )

	Define	MsDialog oDlgPrinc	Title OemToAnsi(STR0001)	From aCoors[1], aCoors[2] To aCoors[3], aCoors[4]	OF oMainWnd Pixel  // "Action of Termination"

	// Create container where panels will be created
	oScreen		:= FWFormContainer():New( oDlgPrinc )
	cIdBrowse	:= oScreen:CreateHorizontalBox( 60 )
	cIdGrid		:= oScreen:CreateHorizontalBox( 35 )

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

	oBrowseUp:Activate()

	oBrowseDwn	:=	BrowseDef()
	oBrowseDwn:SetOwner( oPanelDown )

	// Set relationship between panels
	oRelacSRG:= FWBrwRelation():New()
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
	Private	oBrowse as Object

	// FWmBrowse Inferior: Termination items
	oBrowse:= FWMBrowse():New()
	oBrowse:SetDescription( STR0003 )	
	oBrowse:SetMenuDef( "RU07T06" )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( "SRG" )
	oBrowse:SetProfileID( "2" )
	oBrowse:ForceQuitButton()		// Quit button on that browse
	oBrowse:SetCacheView( .F. )
	oBrowse:ExecuteFilter( .T. )

	// Set caption for Discharge items
	oBrowse:AddLegend( "SRG->RG_EFETIVA=='S'",	"RED",	STR0012 ) 
	oBrowse:AddLegend( "SRG->RG_EFETIVA=='N'",	"BLUE",	STR0011 ) 

Return oBrowse

/*/{Protheus.doc} ModelDef
Model Definition.

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()

	Local 	oModel		as Object
	Local 	oStructSRG 	as Object	

	oModel 		:=	MPFormModel():New( "RU07T06" )
	oStructSRG 	:=	FWFormStruct( 1, "SRG" )
	
	oModel:AddFields( "GPEM040_MSRG", /*Owner*/, oStructSRG , /*Pre-Validation*/, /*Pos-Validation*/, /*Load*/ )

	oModel:GetModel("GPEM040_MSRG"):SetDescription("Termination")

	oModel:SetVldActivate( { |oModel| .T. } )
	oModel:SetActivate( { |oModel| fInitModel( oModel, oModel:GetOperation() ) } ) 

Return ( oModel )

/*/{Protheus.doc} ViewDef
View Definition.

@author ekaterina.moskovkira
@since 16/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()

	Local	oView		as Object
	Local 	oModel		as Object
	Local 	oStructSRG 	as Object	

	oModel	:= FWLoadModel( "RU07T06" )
	oView	:= FWFormView():New()

	oView:SetModel( oModel )

	oStructSRG 	:= FWFormStruct( 2, "SRG" )
	oStructSRG:RemoveField( "RG_EFETIVA" )
	oStructSRG:RemoveField( "RG_MEDATU" )
	oStructSRG:RemoveField( "RG_PERIODO" )
	oStructSRG:RemoveField( "RG_SEMANA" )
	oStructSRG:RemoveField( "RG_ROTEIR" )
	oStructSRG:RemoveField( "RG_NORMAL" )
	oStructSRG:RemoveField( "RG_SALMES" )
	oStructSRG:RemoveField( "RG_SALDIA" )
	oStructSRG:RemoveField( "RG_SALHORA" )
	oStructSRG:RemoveField( "RG_PROCES" )
	oStructSRG:RemoveField( "RG_PDRESC" )
	oStructSRG:RemoveField( "RG_DFERPRO" )

	oView:AddField("GPEM040_VSRG", oStructSRG, "GPEM040_MSRG" )

	oView:SetCloseOnOk( { || .T. } )

Return ( oView )

Static Function MenuDef()
	Local aRotina as Array

	aRotina := {}

	ADD	OPTION aRotina	TITLE STR0004 	ACTION 'VIEWDEF.RU07T06'	OPERATION 2	ACCESS 0	//"View" 
	ADD	OPTION aRotina	TITLE STR0005	ACTION 'VIEWDEF.RU07T06'	OPERATION 3	ACCESS 0	//"Insert"
	ADD	OPTION aRotina	TITLE STR0006	ACTION 'VIEWDEF.RU07T06'	OPERATION 4	ACCESS 0	//"Update"
	ADD	OPTION aRotina	TITLE STR0007 	ACTION 'VIEWDEF.RU07T06'	OPERATION 5	ACCESS 0	//"Delete"

Return ( aRotina )

/*/{Protheus.doc} fInitModel
	(long_description)
	@type  Function
	@author ekaterina.moskovkira
	@since 16/05/2018
	@version 1.0
	@param 	oModel		Object	Model that we need to change 
			nOperation	Numeric	Type of operation
	@return Nil
	/*/
Static Function fInitModel( oModel, nOperation )
	Local nSalario	as Numeric
	Local nSalHora	as Numeric
	Local nSalDia	as Numeric
	Local nSalMes	as Numeric

	nSalario	:= 0
	nSalHora	:= 0
	nSalDia		:= 0
	nSalMes		:= 0

	fSalario( @nSalario, @nSalHora, @nSalDia, @nSalMes, "", , )

	If nOperation == MODEL_OPERATION_INSERT
		oModel:SetValue( "GPEM040_MSRG", "RG_SALMES", nSalMes )
		oModel:SetValue( "GPEM040_MSRG", "RG_SALDIA", nSalDia )
		oModel:SetValue( "GPEM040_MSRG", "RG_SALHORA", nSalHora )   
	ElseIf nOperation <> MODEL_OPERATION_DELETE                          
		oModel:SetValue( "GPEM040_MSRG", "RG_DESCTPR", fDescRCC( "S026", SRG->RG_TIPORES, 1, 2, 3, 100 ) )	
	EndIf

Return Nil

// Russia_R5
