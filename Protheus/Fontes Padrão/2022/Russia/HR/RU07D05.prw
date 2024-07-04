#INCLUDE "Protheus.ch"
#INCLUDE "RU07D05.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D05
Family Members 

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D05()
Local oBrowse as Object

oBrowse := BrowseDef()

oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrwTMP 	as Object

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "SRA" )
oBrowse:SetDescription( STR0001 ) // Family Members 
oBrowse:DisableDetails()

Return ( oBrowse ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel		as Object
Local oStructRD0 	as Object
Local oStructSRB 	as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
	Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
EndIf	 
	
oModel:= MPFormModel():New("RU07D05", /*bPreValid*/,/* bTudoOK*/, /* bCommit*/, /*bCancel*/)
oModel:SetDescription( STR0001 ) //"Family Members" 
    
// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oModel:AddFields("RU07D05_MRD0", NIL, oStructRD0 )
oModel:GetModel("RU07D05_MRD0"):SetDescription( STR0001 ) //"Family Members " 
oModel:GetModel("RU07D05_MRD0"):SetOnlyQuery(.T.)
oModel:GetModel("RU07D05_MRD0"):SetOnlyView(.T.)

// Items structure - SRB Family Members 
oStructSRB := FWFormStruct(1, "SRB")
oModel:AddGrid("RU07D05_MSRB", "RU07D05_MRD0", oStructSRB,/*bLinePre*/,/* bLinePost*/,/*bPre*/, { |oGrid| RU07D05TOk(oGrid) }/*bPost*/,/*bLoad*/  )
oModel:GetModel("RU07D05_MSRB"):SetUniqueLine( { 'RB_MAT','RB_COD', 'RB_DATAINI', 'RB_FECFIN', 'RB_GRAUPAR', 'RB_NOME', 'RB_SECNOME', 'RB_SURNME', 'RB_DTNASC', 'RB_SEXO', 'RB_NACIONA' } )                                                                   
oModel:SetPrimaryKey({'RB_FILIAL','RB_MAT','RB_COD'})
oModel:GetModel("RU07D05_MSRB"):SetDescription( STR0001 ) //"Family Members" 
oModel:GetModel("RU07D05_MSRB"):SetOptional( .T. )
oStructSRB:RemoveField( "RB_MAT" ) 

oModel:SetRelation( "RU07D05_MSRB", { { "RB_FILIAL", 'RD0_FILIAL' }, { "RB_MAT", 'RD0_CODIGO' }}, SRB->( IndexKey( 2 ) ) )

oModel:SetVldActivate( { |oModel|  RD05VldIni( oModel,oModel:GetOperation()) } )  

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStructRD0 	as Object
Local oStructSRB 	as Object

oModel := FWLoadModel("RU07D05")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStructRD0:SetNoFolder()
oView:AddField("RU07D05_VRD0", oStructRD0, "RU07D05_MRD0" )
oView:SetViewProperty("RU07D05_VRD0","OnlyView")

// Items structure - SRB Family Members 
oStructSRB := FWFormStruct(2, "SRB")
oStructSRB:RemoveField( "RB_MAT" )

oView:AddGrid("RU07D05_VSRB", oStructSRB, "RU07D05_MSRB" )
oView:AddIncrementField( "RU07D05_VSRB", "RB_COD" )

oView:CreateHorizontalBox("RD0_HEAD", 15)
oView:CreateHorizontalBox("RB_ITEM", 85)

oView:SetOwnerView( "RU07D05_VRD0", "RD0_HEAD" )
oView:SetOwnerView( "RU07D05_VSRB", "RB_ITEM" )

oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD05VldIni
Check if there is record for Family Members .

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RD05VldIni(oModel as Object ,nOperacao as Numeric)
Local lRet 	as Logical

lRet	:= .T.

If nOperacao == MODEL_OPERATION_DELETE  
	If RD05Null()
		Help(,,'HELP',, STR0008 ,1,0 ) //"There is no record of Family Members for this employee."
		lRet := .F.
	EndIf	
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD05Null
Check if there is record for Family Members .

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RD05Null()
Local aAreaSRB as Array
Local lRet	as Logical
aAreaSRB	:= SRB->(GetArea())
lRet	:= .T.

SRB->(DbSetOrder(1))
If SRB->(DbSeek(xFilial("RD0") + RD0->RD0_CODIGO))
	lRet := .F.
EndIf

RestArea(aAreaSRB)

Return ( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.RU07D05'	OPERATION 2 ACCESS 0 //"View" 
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.RU07D05' 	OPERATION 4 ACCESS 0 //"Update"
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.RU07D05' 	OPERATION 5 ACCESS 0 //"Delete" 
ADD OPTION aRotina TITLE STR0016 	ACTION 'fRD0Legend()' 		OPERATION 10 ACCESS 0 //"Legend" 

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D05TOk()
Confirmation of deleting
@author anastasiya.kulagina
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D05TOk(oGrid)
	Local lDel as Logical
	If oGrid:IsDeleted()
		lDel := MSGYESNO (STR0018,STR0019) //Confirmation of deleting
		if !lDel
			oGrid:UnDeleteLine()
		endif
	EndIf
Return .T.
//Checked and merged by AS for Russia_R4 * *
// Russia_R5
