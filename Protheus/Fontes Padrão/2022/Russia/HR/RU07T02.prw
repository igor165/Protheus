#INCLUDE "Protheus.ch"
#INCLUDE "RU07T02.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T02
employment book

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T02()
	Local oBrowse as Object
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
	Local oBrowse 	as Object

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "SRA" )
	oBrowse:SetDescription(STR0001)  //length of service
	oBrowse:DisableDetails() 
	
Return ( oBrowse ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()

Local oModel		as Object
Local oStructRD0 	as Object
Local oStructF4P 	as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
	Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
EndIf	 
	
oModel:= MPFormModel():New("RU07T02")
 

// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})

oModel:AddFields("RD0MASTER", NIL, oStructRD0 )
 
oModel:GetModel("RD0MASTER"):SetOnlyQuery(.T.)
oModel:GetModel("RD0MASTER"):SetOnlyView(.T.)
	
// Items structure - F4O - F4P
oStructF4P := FWFormStruct(1, "F4P") //length of service
	
oStructF4P:SetProperty("F4P_DTGEN",MODEL_FIELD_VALID,{|a,b,c| RU072DT(a,b,c)})
oStructF4P:SetProperty("F4P_DTGEN",MODEL_FIELD_OBRIGAT,.T.)
oStructF4P:SetProperty("F4P_GNYEAR",MODEL_FIELD_OBRIGAT,.F.)
oStructF4P:SetProperty("F4P_GNMONT",MODEL_FIELD_OBRIGAT,.F.)
oStructF4P:SetProperty("F4P_GNDAYS",MODEL_FIELD_OBRIGAT,.F.)


oModel:AddGrid("F4PDETAIL", "RD0MASTER", oStructF4P )

oModel:GetModel("F4PDETAIL"):SetUniqueLine( { 'F4P_TPLCOD'} )
oModel:GetModel("F4PDETAIL"):SetNoInsertLine(.T.)

oModel:SetPrimaryKey({'F4P_FILIAL','F4P_MAT','F4P_TPLCOD'})

oModel:SetRelation( "F4PDETAIL", { { "F4P_FILIAL", 'RD0_FILIAL' }, { "F4P_MAT", 'RD0_CODIGO' }}, F4P->( IndexKey( 1 ) ) )


oModel:GetModel("RD0MASTER"):SetDescription( STR0013 ) //"Employment book"
oModel:GetModel("F4PDETAIL"):SetDescription( STR0001 ) //length of service
oModel:SetDescription( STR0001 ) //"Employment book"  

	
oModel:SetVldActivate( { |oModel|  RT02VldIni( oModel,oModel:GetOperation() ) } )
oModel:SetActivate( { |oModel|  RD03Ini( oModel,oModel:GetOperation() ) } )  

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStructRD0 	as Object
Local oStructF4P 	as Object

oModel := FWLoadModel("RU07T02")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStructRD0:SetNoFolder()

oView:AddField("VIEW_RD0", oStructRD0, "RD0MASTER" )
oView:SetViewProperty("VIEW_RD0","OnlyView")

// Items structure - F4O Residence Status
oStructF4P := FWFormStruct(2, "F4P",{|cCampo| !AllTrim(cCampo) $ "F4P_MAT|F4P_MANU"})

oStructF4P:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) //only view
oStructF4P:SetProperty('F4P_DTGEN', MVC_VIEW_CANCHANGE, .T.) //editable

oView:AddGrid("VIEW_F4P", oStructF4P, "F4PDETAIL" )


oView:AddIncrementField( "VIEW_F4P", "F4P_SEQ" )

oView:CreateHorizontalBox("RD0_HEAD", 20)
oView:CreateHorizontalBox("F4P_ITEM", 80)


oView:SetOwnerView( "VIEW_RD0", "RD0_HEAD" )
oView:SetOwnerView( "VIEW_F4P", "F4P_ITEM" )

oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} RT02VldIni
Check if there is record for Residence Status.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RT02VldIni(oModel,nOperacao)
Local lRet 	as Logical
Local aAreaF4P	as Array

aAreaF4P := F4P->(GetArea())
lRet	:= .T.

F4P->(DbSetOrder(1))
If !F4P->(DbSeek(xFilial("RD0") + RD0->RD0_CODIGO))
	lRet := .F.
	Help(, ,'HELP', , STR0014 ,1,0 ) // There is no records about Employment Book. Register Employment Book for this employee.
EndIf

RestArea(aAreaF4P)

Return ( lRet )

//-------------------------------------------------------------------
/*{Protheus.doc} RD03Ini
Check if there is record for Residence Status.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
*/
Static Function RD03Ini(oModel,nOperacao)
Local lRet as Logical
Local oStructF4P as Object 

oStructF4P := oModel:GetModel("F4PDETAIL")

lRet	:= .T.

If lRet .and. nOperacao == MODEL_OPERATION_UPDATE

	If (oStructF4P:Length() < 2)
		oStructF4P:GoLine(1)
		oStructF4P:LoadValue("F4P_TPLCOD","01")
		oStructF4P:LoadValue("F4P_TPLDES",fDescRCC('S023',"01",1,2,3,100))
		oStructF4P:LoadValue("F4P_MANU","1")
		oStructF4P:LoadValue("F4P_DTGEN",dDatabase)


		oStructF4P:AddLine()
		oStructF4P:GoLine(2)
		oStructF4P:LoadValue("F4P_TPLCOD","02")
		oStructF4P:LoadValue("F4P_TPLDES",fDescRCC('S023',"02",1,2,3,100))
		oStructF4P:LoadValue("F4P_MANU","1")
		oStructF4P:LoadValue("F4P_DTGEN",dDatabase)
		
	EndIf
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RU072DT
check date od RU072DT

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU072DT(oModelF4P as Object, b as Character, dValue as Date)
local n as number
local aDates as array
local nYears as number
local nMonths as number
local nDays as number
local lRet as logical
Local oModelF40 as Object

oModelF40 := FWModelActive()
dHirdt := oModelF40:GetValue('RD0MASTER','RD0_DTADMI') //HIRDT

lRet := .T.

If !Empty(dValue) 
	for n:= 1 to oModelF4P:Length()
		oModelF4P:GoLine(n)
		oModelF4P:LoadValue("F4P_DTGEN",dValue)
		
		aDates := DateDiffYMD(dHirdt,dValue) //take the difference between admission date and calc.sel.dt
		
		nYears 	:= aDates[1]
		nMonths := aDates[2]
		nDays 	:= aDates[3]
		
		//now we gather the dates
		nYears 	+= oModelF4P:GetValue("F4P_EBYEAR",n)
		nMonths += oModelF4P:GetValue("F4P_EBMONT",n)
		nDays 	+= oModelF4P:GetValue("F4P_EBDAY",n)
			
		nMonths += NOROUND(nDays/30,0) // in this kind of calculation for Russia one month can be considered 30 days
		nYears	+= NOROUND(nMonths/12,0)
	
		nMonths	-= NOROUND(nMonths/12,0)*12
		nDays 	-= NOROUND(nDays / 30,0)*30
		
		oModelF4P:LoadValue("F4P_GNYEAR",nYears)
		oModelF4P:LoadValue("F4P_GNMONT",nMonths)
		oModelF4P:LoadValue("F4P_GNDAYS",nDays)
	Next
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
	Local aRotina as Array
	
	aRotina := {}
	
	ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.RU07T02'	OPERATION 2 ACCESS 0 //"View" 
	ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.RU07T02' 	OPERATION 4 ACCESS 0 //"Update"
	ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.RU07T02' 	OPERATION 5 ACCESS 0 //"Delete" 

Return ( aRotina )