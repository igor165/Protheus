#INCLUDE "Protheus.ch"
#INCLUDE "RU07D04.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D04
Tax Deductions Register File 

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Function RU07D04()
Local oBrowse as Object

oBrowse := BrowseDef()

oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse 	:= FWmBrowse():New()
oBrowse:SetAlias( "SRA" )
oBrowse:SetDescription( STR0001 ) // Tax Deductions
oBrowse:DisableDetails()

	
Return ( oBrowse ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel		as Object
Local oStructRD0 	as Object
Local oStructF4W 	as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
    Help(Nil, Nil, "ERROR", Nil, STR0013, 1, 0)
EndIf	 
	
oModel:= MPFormModel():New("RU07D04", /*bPreValid*/,/* bTudoOK*/, /* bCommit*/, /*bCancel*/)
oModel:SetDescription( STR0001 ) //"Tax Deductions" 
    
// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oModel:AddFields("RU07D04_MRD0", NIL, oStructRD0 )
oModel:GetModel("RU07D04_MRD0"):SetDescription( STR0001 ) //"Tax Deductions" 
oModel:GetModel("RU07D04_MRD0"):SetOnlyQuery(.T.)
oModel:GetModel("RU07D04_MRD0"):SetOnlyView(.T.)

// Items structure - F4W Tax Deductions
oStructF4W := FWFormStruct(1, "F4W")
oModel:AddGrid("RU07D04_MF4W", "RU07D04_MRD0", oStructF4W,, /*bLinOk*/  )
oModel:GetModel("RU07D04_MF4W"):SetUniqueLine( { 'F4W_DTSTAR', 'F4W_DTEND', 'F4W_CTXGRD', 'F4W_CTXPRL' } )
oModel:SetPrimaryKey({'F4W_FILIAL','F4W_DTSTAR','F4W_DTEND','F4W_CTXGRD','F4W_CTXPRL'})
oModel:GetModel("RU07D04_MF4W"):SetDescription( STR0001 ) //"Tax Deductions" 
oModel:GetModel("RU07D04_MF4W"):SetOptional( .T. )
oStructF4W:RemoveField( "F4W_CODE" ) 

oModel:SetRelation( "RU07D04_MF4W", { { "F4W_FILIAL", 'RD0_FILIAL' }, { "F4W_CODE", 'RD0_CODIGO' }}, F4W->( IndexKey( 1 ) ) )

oModel:SetVldActivate( { |oModel|  RD04VldIni( oModel,oModel:GetOperation()) } )  

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStructRD0 	as Object
Local oStructF4W 	as Object

oModel := FWLoadModel("RU07D04")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStructRD0:SetNoFolder()
oView:AddField("RU07D04_VRD0", oStructRD0, "RU07D04_MRD0" )
oView:SetViewProperty("RU07D04_VRD0","OnlyView")

// Items structure - F4W Tax Deductions
oStructF4W := FWFormStruct(2, "F4W")
oStructF4W:RemoveField( "F4W_CODE" )

oView:AddGrid("RU07D04_VF4W", oStructF4W, "RU07D04_MF4W" )

oView:CreateHorizontalBox("RD0_HEAD", 15)
oView:CreateHorizontalBox("F4W_ITEM", 85)

oView:SetOwnerView( "RU07D04_VRD0", "RD0_HEAD" )
oView:SetOwnerView( "RU07D04_VF4W", "F4W_ITEM" )

oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD04VldIni
Check if there is record for Tax Deductions.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function RD04VldIni(oModel as Object,nOperacao as Numeric)
Local lRet 	as Logical

lRet	:= .T.

If nOperacao == MODEL_OPERATION_DELETE  
	If RD04Null()
		Help(, ,'HELP', , STR0008 ,1,0 ) //"There is no record of Tax Deduction for this employee."
		lRet := .F.
	EndIf	
EndIf


Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD04Null
Check if there is record for Tax Deductions.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function RD04Null()
Local aAreaF4W as Array
Local lRet	as Logical

lRet := .T.

aAreaF4W := F4W->(GetArea())

F4W->(DbSetOrder(1))
If F4W->(DbSeek(xFilial("RD0") + RD0->RD0_CODIGO))
	lRet := .F.
EndIf

RestArea(aAreaF4W)

Return ( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} fRD0Legend
Legend of the Colors

@author ekaterina.moskovkira
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function fRD0Legend( )
Local aLegend as Array
aLegend := {}

Aadd( aLegend, { "BR_VERDE"	  , STR0012} )
Aadd( aLegend, { "BR_VERMELHO", STR0013} )

BrwLegenda ( STR0017, STR0016, aLegend ) //"Legend"###"Employee's Status"

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} fRD04LinOk()
Validate inclusion of Taxing Grade+Taxing Privilege for the same 
period.
@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Function  fRD04Tax(cType as Character)
Local aSaveLin	as Array
Local bLinePost	as Block
Local bTempo	as Block
Local lRet 		as Logical
Local cTxPr		as Character
Local dDtStart	as Data
Local dDtEnd	as Data
Local oModel 	as Object
Local oGrid 	as Object
Local nX		as Numeric
Local nTxGr		as Numeric
Local nActual	as Numeric

lRet 		:= .T.
oModel 		:= FWModelActive()
oGrid 		:= oModel:GetModel( "RU07D04_MF4W" )

If cType == "1" // Call from Taxing Grade
	nTxGr		:= &( ReadVar() )
	cTxPr		:= oGrid:GetValue( "F4W_CTXPRL" ) 
Else // Call from Taxing Privilege
	nTxGr		:= oGrid:GetValue( "F4W_CTXGRD" )
	cTxPr		:= &( ReadVar() ) 
EndIf

If !oGrid:IsDeleted() .And. !Empty( nTxGr ) .And. !Empty( cTxPr )

	dDtStart		:= oGrid:GetValue( "F4W_DTSTAR" ) // Start Date from posicioned line
	dDtEnd			:= oGrid:GetValue( "F4W_DTEND" )  // End Date from posicioned line
	nActual			:= oGrid:GetLine()
	bTemp 			:= oGrid:bLinePost
	oGrid:bLinePost := { || .T. }
	aSaveLin		:= FWSaveRows()

	For nX := 1 To oGrid:Length()
		oGrid:GoLine( nX )

		If !oGrid:Isdeleted() .And. nX <> nActual
			If AllTrim( Str( oGrid:GetValue( "F4W_CTXGRD" ) ) ) + AllTrim( oGrid:GetValue( "F4W_CTXPRL" ) ) == AllTrim( Str( nTxGr ) ) + AllTrim( cTxPr )
				If dDtStart >= oGrid:GetValue( "F4W_DTSTAR" ) .And. dDtStart <= oGrid:GetValue( "F4W_DTEND" ) .Or. dDtEnd >= oGrid:GetValue( "F4W_DTSTAR" ) .And. dDtEnd <= oGrid:GetValue( "F4W_DTEND" )
					lRet := .F.
					Help( , ,'HELP', , STR0010, 1, 0 ) //"Already exist a period for selected Taxing Grade and Taxing Privilege."
					Exit
				EndIf
			EndIf
		EndIf
	Next 
	
	FWRestRows( aSaveLin )
	aSize( aSaveLin,0 )
	aSaveLin := Nil
	
	oGrid:bLinePost :=  bTemp
		
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.RU07D04'	OPERATION 2 ACCESS 0 //"View" 
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.RU07D04' 	OPERATION 4 ACCESS 0 //"Update"
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.RU07D04' 	OPERATION 5 ACCESS 0 //"Delete" 
ADD OPTION aRotina TITLE STR0016 	ACTION 'fRD0Legend()' 		OPERATION 10 ACCESS 0 //"Legend" 

Return aRotina