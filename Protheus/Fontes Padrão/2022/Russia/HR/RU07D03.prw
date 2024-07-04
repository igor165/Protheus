#INCLUDE "Protheus.ch"
#INCLUDE "ru07d03.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D03
Residence Status Register File 

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/

Function RU07D03()

Local oBrowse as Object

oBrowse := BrowseDef()

oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( "SRA" )
oBrowse:SetDescription( STR0001 ) // Residence Status
oBrowse:DisableDetails() 
	
Return ( oBrowse ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()

Local oModel		as Object
Local oStructRD0 	as Object
Local oStructF4Z 	as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
	Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
EndIf	 
	
oModel	:= MPFormModel():New( "RU07D03")
oModel:SetDescription( STR0001 ) //"Residence Status" 
    
// Header structure - RD0 Persons (temporary file)
oStructRD0	:= FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})

oModel:AddFields( "RU07D03_MRD0", NIL, oStructRD0 )
oModel:GetModel ( "RU07D03_MRD0" ):SetDescription( STR0001 ) //"Residence Status" 
oModel:GetModel ( "RU07D03_MRD0" ):SetOnlyQuery( .T.)
oModel:GetModel ( "RU07D03_MRD0" ):SetOnlyView( .T.)

// Items structure - F4Z Residence Status
oStructF4Z 	:= FWFormStruct( 1, "F4Z" )

oModel:AddGrid( "RU07D03_MF4Z", "RU07D03_MRD0", oStructF4Z, , /*bLinOk*/ )

oModel:GetModel( "RU07D03_MF4Z"):SetUniqueLine( ;
				{ 'F4Z_SEQ', 'F4Z_RESSTC', 'F4Z_RESSTD', 'F4Z_NMPERM', 'F4Z_DTEXY', 'F4Z_DISSUE', 'F4Z_DTENT', 'F4Z_PASNMR' } )
				
oModel:SetPrimaryKey( {'F4Z_FILIAL','F4Z_CODE','F4Z_SEQ'} )

oModel:GetModel( "RU07D03_MF4Z" ):SetDescription( STR0001 ) //"Residence Status" 
oModel:GetModel( "RU07D03_MF4Z" ):SetOptional( .T. )

oModel:SetRelation( "RU07D03_MF4Z", { { "F4Z_FILIAL", 'RD0_FILIAL' }, { "F4Z_CODE", 'RD0_CODIGO' }}, F4Z->( IndexKey( 1 ) ) )

oModel:SetVldActivate( { |oModel|  RD03VldIni( oModel,oModel:GetOperation()) } )  
oModel:SetActivate( { |oModel| fInitModel( oModel, oModel:GetOperation() ) } ) 

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()

Local oView 		as Object
Local oModel 		as Object
Local oStructRD0 	as Object
Local oStructF4Z 	as Object

oModel	:= FWLoadModel( "RU07D03" )

oView	:= FWFormView():New()
oView:SetModel( oModel )

// Header structure - RD0 Persons
oStructRD0	:= FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStructRD0:SetNoFolder()
	
oView:AddField( "RU07D03_VRD0", oStructRD0, "RU07D03_MRD0" )
oView:SetViewProperty( "RU07D03_VRD0","OnlyView" )

//oView:AddUserButton( STR0010, 'CLIPS', { |oView| fRD0Legend() } )  //Legend

// Items structure - F4Z Residence Status
oStructF4Z := FWFormStruct( 2, "F4Z" )
oStructF4Z:RemoveField( "F4Z_CODE" )
oView:AddGrid( "RU07D03_VF4Z", oStructF4Z, "RU07D03_MF4Z" )
oView:AddIncrementField( "RU07D03_VF4Z", "F4Z_SEQ" )

oView:CreateHorizontalBox( "RD0_HEAD", 15 )
oView:CreateHorizontalBox( "F4Z_ITEM", 85 )

oView:SetOwnerView( "RU07D03_VRD0", "RD0_HEAD" )
oView:SetOwnerView( "RU07D03_VF4Z", "F4Z_ITEM" )

oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD03VldIni
Check if there is record for Residence Status.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RD03VldIni( oModel as Object, nOperacao as Numeric)

Local lRet 	as Logical

lRet := .T.

If nOperacao == MODEL_OPERATION_DELETE 
	If RD03Null()
		Help( , , 'HELP', , STR0008, 1, 0 ) //"There is no record of Residence Status for this employee."
		lRet := .F.
	EndIf
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD03Null
Check if there is record for Residence Status.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RD03Null()

Local aAreaF4Z as Array
Local lRet	as Logical

lRet	:= .T.
aAreaF4Z := F4Z->(GetArea())

F4Z->( DbSetOrder( 1 ) )
If F4Z->(DbSeek( xFilial("RD0") + RD0->RD0_CODIGO ))
	lRet := .F.
EndIf

RestArea( aAreaF4Z )

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.RU07D03'	OPERATION 2  ACCESS 0 //"View" 
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.RU07D03' 	OPERATION 4  ACCESS 0 //"Update"
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.RU07D03' 	OPERATION 5  ACCESS 0 //"Delete"
ADD OPTION aRotina TITLE STR0016 	ACTION 'fRD0Legend()' 		OPERATION 10 ACCESS 0 //"Legend"  

Return ( aRotina )

/*/{Protheus.doc} fInitModel
	@type  Function
	@author ekaterina.moskovkira
	@since 01/06/2018
	@version 1.0
	@param 	oModel		Object	Model that we need to change 
			nOperation	Numeric	Type of operation
	@return Nil
	/*/
Static Function fInitModel( oModel, nOperation )
Local oModelF4Z	as Object
Local nModelLen	as Numeric
Local cCode		as Character
Local cDesc		as Character

oModelF4Z 	:= 	oModel:GetModel("RU07D03_MF4Z")
nModelLen	:=	oModelF4Z:Length()

cCode	:=	"RE02"
cDesc	:=	fDescRCC("S019", cCode, 1, 4, 5, 100 )

If nOperation == MODEL_OPERATION_UPDATE .And. nModelLen == 1 
	oModelF4Z:GoLine( nModelLen )

	If Empty( oModelF4Z:GetValue( "F4Z_RESSTC" ) )
		oModel:LoadValue( "RU07D03_MF4Z", "F4Z_RESSTC", cCode )
		oModel:LoadValue( "RU07D03_MF4Z", "F4Z_RESSTD", cDesc )
	EndIf
EndIf

Return Nil
//Checked and merged by AS for Russia_R4 * *
// Russia_R5
