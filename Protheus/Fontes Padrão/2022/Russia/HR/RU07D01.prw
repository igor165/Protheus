#INCLUDE "Protheus.ch"
#INCLUDE "RU07D01.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D01
Personal Data Register File 

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D01()
Local oBrowse as Object

oBrowse := BrowseDef()
oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias( "SRA" )
oBrowse:SetDescription( STR0001 ) //"Personal Data"  
oBrowse:DisableDetails() 


Return ( oBrowse ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oStrEmpRD0 	as Object
Local oStrDocTMP 	as Object
Local oModel		as Object
Local oStructF4J 	as Object
Local oStructSRB 	as Object
Local oStructF4M 	as Object
Local oStructF4L 	as Object	 
Local oStructF4H 	as Object
Local oStructF4G	as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
    Help(Nil, Nil, "ERROR", Nil, STR0011, 1, 0)
EndIf


oModel:= MPFormModel():New("RU07D01", /*bPreValid*/,/* bTudoOK*/, /* */, /*bCancel*/)
oModel:SetDescription( STR0001 ) //"Personal Data"  
    
// Header structure - RD0 Persons
oStrEmpRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oModel:AddFields("RU07_MRD0", NIL, oStrEmpRD0 )
oModel:GetModel("RU07_MRD0"):SetDescription( STR0001 ) //"Personal Data" 
oModel:GetModel("RU07_MRD0"):SetOnlyQuery(.T.)
oModel:GetModel("RU07_MRD0"):SetOnlyView(.T.)

// Items structure - F4J Marital Status
oStructF4J := FWFormStruct(1, "F4J")
oModel:AddGrid("RU07D01_MF4J", "RU07_MRD0", oStructF4J,, /*bLinOk*/  )
oModel:SetPrimaryKey({'F4J_FILIAL','F4J_CODE'})
oModel:GetModel("RU07D01_MF4J"):SetDescription( STR0004 ) //"Marital Status" 
oModel:GetModel("RU07D01_MF4J"):SetOptional( .T. ) 
oModel:SetRelation( "RU07D01_MF4J", { { "F4J_FILIAL", 'RD0_FILIAL' }, { "F4J_CODE", 'RD0_CODIGO' } }, F4J->( IndexKey( 1 ) ) )

// Items structure - F4L Education
oStructF4L := FWFormStruct(1, "F4L")
oModel:AddGrid("RU07D01_MF4L", "RU07_MRD0", oStructF4L,, /*bLinOk*/  )
oModel:SetPrimaryKey({'F4L_FILIAL','F4L_CODE', 'F4L_SEQ'})
oModel:GetModel("RU07D01_MF4L"):SetDescription( STR0008 ) //"Education" 
oModel:GetModel("RU07D01_MF4L"):SetOptional( .T. ) 
oModel:SetRelation( "RU07D01_MF4L", { { "F4L_FILIAL", 'RD0_FILIAL' }, { "F4L_CODE", 'RD0_CODIGO' } }, F4L->( IndexKey( 1 ) ) )

// Documents Included - Temporary Table
oStrDocTMP := DefStrMDoc()
oModel:AddGrid("RU07D01_MALLD", "RU07_MRD0", oStrDocTMP, /*bPreValidacao*/	, /*bPosValidacao*/	,,, {|oModel| fLoadALL(oModel)}/* bLoad*/ )
oModel:GetModel("RU07D01_MALLD"):SetDescription( STR0007 ) // Documents
oModel:GetModel("RU07D01_MALLD"):SetOnlyQuery(.T.)
oModel:GetModel("RU07D01_MALLD"):SetOnlyView(.T.)
oModel:GetModel('RU07D01_MALLD'):SetNoInsertLine(.T.)

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.
@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStrEmpRD0 	as Object
Local oStrDocTMP 	as Object
Local oStructF4J 	as Object
Local oStructSRB 	as Object
Local oStructF4L 	as Object	 
Local oStructF4G 	as Object

oModel := FWLoadModel("RU07D01")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - RD0 Persons
oStrEmpRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStrEmpRD0:SetNoFolder()
oView:AddField("RU07D01_VRD0", oStrEmpRD0, "RU07_MRD0" )
oView:SetViewProperty("RU07D01_VRD0","OnlyView")


// Items structure - F4J Marital Status
oStructF4J := FWFormStruct(2, "F4J")
oStructF4J:RemoveField( "F4J_CODE" )
oView:AddGrid("RU07D01_VF4J", oStructF4J, "RU07D01_MF4J" )
oView:AddIncrementField( "RU07D01_VF4J", "F4J_SEQ" )

// Items structure - F4L Education
oStructF4L := FWFormStruct(2, "F4L")
oStructF4L:RemoveField( "F4L_CODE" )
oView:AddGrid("RU07D01_VF4L", oStructF4L, "RU07D01_MF4L" )
oView:AddIncrementField("RU07D01_VF4L","F4L_SEQ")

// Documents Included - Temporary Table
oStrDocTMP := DefStrVALL()
oView:AddGrid("RU07D01_VALLD", oStrDocTMP, "RU07D01_MALLD" )
oView:SetViewProperty("RU07D01_VALLD","OnlyView")

oView:CreateHorizontalBox( 'SUPERIOR'	, 15 )
oView:CreateHorizontalBox( 'INFERIOR'  	, 85 )
oView:CreateFolder( 'PASTAS' , 'INFERIOR' )

oView:AddSheet( 'PASTAS', 'FLD01', STR0004 ) 	//"Marital Status" 
oView:AddSheet( 'PASTAS', 'FLD02', STR0008 ) 	//"Education" 
oView:AddSheet( 'PASTAS', 'FLD03', STR0007 )	//"Documents" 

oView:CreateHorizontalBox( 'ITEM1', 100,,,'PASTAS','FLD01' )
oView:CreateHorizontalBox( 'ITEM2', 100,,,'PASTAS','FLD02' )
oView:CreateHorizontalBox( 'ITEM3', 100,,,'PASTAS','FLD03' )

oView:SetOwnerView( 'RU07D01_VRD0' , 'SUPERIOR'  )
oView:SetOwnerView( 'RU07D01_VF4J' , 'ITEM1'  )
oView:SetOwnerView( 'RU07D01_VF4L' , 'ITEM2'  )
oView:SetOwnerView( 'RU07D01_VALLD', 'ITEM3'  )


oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.RU07D01'	OPERATION 2 ACCESS 0 //"View" 
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.RU07D01' 	OPERATION 4 ACCESS 0 //"Update"

Return aRotina
// Russia_R5
