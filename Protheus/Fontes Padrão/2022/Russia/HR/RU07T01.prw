#INCLUDE "Protheus.ch"
#INCLUDE "RU07T01.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T01
employment book

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T01()
	Local oBrowse as Object

	oBrowse := BrowseDef()

	oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
	Local oBrowse As Object

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "SRA" )
	oBrowse:SetDescription(STR0001) // Employment book
	oBrowse:DisableDetails() 

Return oBrowse


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
	Local oModel		As Object
	Local oStructRD0 	As Object
	Local oStructF4O 	As Object
	Local oStructF4P 	As Object
  	Local cRaCodunic 	As Char
    Local cRd0Codigo 	As Char

    cRaCodunic := SRA->RA_CODUNIC

    cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

    If cRd0Codigo != cRaCodunic
        Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
    EndIf

	oModel:= MPFormModel():New("RU07T01", /*bPreValid*/,{ | oModel | fT01TdOk(oModel) }, /* bCommit*/, /*bCancel*/)
	oModel:SetDescription( STR0001 ) //"Employment book" 

	// Header structure - RD0 Persons
	oStructRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
	oModel:AddFields("RD0MASTER", NIL, oStructRD0 )
	oModel:GetModel("RD0MASTER"):SetDescription( STR0001 ) //"Employment book" 
	oModel:GetModel("RD0MASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("RD0MASTER"):SetOnlyView(.T.)

	// Items structure - F4O - F4P
	oStructF4O := FWFormStruct(1, "F4O")
	oStructF4P := FWFormStruct(1, "F4P") //length of service

	oModel:AddGrid("F4PDETAIL", "RD0MASTER", oStructF4P,, {|oModel|R07F4PLinOk(oModel)}/*bLinOk*/  )
	oModel:AddGrid("F4ODETAIL", "F4PDETAIL", oStructF4O,, {|oModel|R07F40LinOk(oModel)} /*bLinOk*/  )

	oModel:GetModel("F4PDETAIL"):SetUniqueLine( { 'F4P_TPLCOD'} )
	oModel:GetModel("F4ODETAIL"):SetUniqueLine( { 'F4O_SEQ'} )
	oModel:SetPrimaryKey({'F4P_FILIAL','F4P_MAT','F4P_TPLCOD'})
	oModel:SetPrimaryKey({'F4O_FILIAL','F4O_MAT','F4O_SEQ'})

	oModel:GetModel("F4PDETAIL"):SetDescription( STR0005 ) //"Length of Service"
	oModel:GetModel("F4ODETAIL"):SetDescription( STR0001 ) //"Employment Book"
	
	oModel:GetModel("F4ODETAIL"):SetOptional( .T. )	
	oModel:SetRelation( "F4PDETAIL", { { "F4P_FILIAL", 'RD0->RD0_FILIAL' }, { "F4P_MAT", 'RD0->RD0_CODIGO' }}, F4P->( IndexKey( 1 ) ) )
	oModel:SetRelation( "F4ODETAIL", { { "F4O_FILIAL", 'RD0->RD0_FILIAL' }, { "F4O_MAT", 'RD0->RD0_CODIGO' }, { "F4O_TPLCOD", 'F4P_TPLCOD' }}, F4O->( IndexKey( 1 ) ) )

	oModel:SetActivate( { |oModel|  RT01VldIni( oModel,oModel:GetOperation() ) } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
	Local oView 		As Object
	Local oModel 		As Object
	Local oStructRD0 	As Object
	Local oStructF4P 	As Object
	Local oStructF4O 	As Object
	

	oModel := FWLoadModel("RU07T01")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Header structure - RD0 Persons
	oStructRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
	oStructRD0:SetNoFolder()

	oView:AddField("VIEW_RD0", oStructRD0, "RD0MASTER" )
	oView:SetViewProperty("VIEW_RD0","OnlyView")

	// Items structure - F4O Residence Status
	oStructF4P := FWFormStruct(2, "F4P",{|cCampo| !AllTrim(cCampo) $ "F4P_MAT|F4P_GNYEAR|F4P_GNMONT|F4P_DTGEN|F4P_GNDAYS|"})
	oStructF4O := FWFormStruct(2, "F4O",{|cCampo| !AllTrim(cCampo) $ "F4O_MAT|F4O_TPLCOD|"})

	oView:AddGrid("VIEW_F4P", oStructF4P, "F4PDETAIL" )
	oView:AddGrid("VIEW_F4O", oStructF4O, "F4ODETAIL" )

	oView:AddIncrementField( "VIEW_F4P", "F4P_SEQ" )
	oView:AddIncrementField( "VIEW_F4O", "F4O_SEQ" )

	oView:CreateHorizontalBox("RD0_HEAD", 15)
	oView:CreateHorizontalBox("F4P_ITEM", 40)
	oView:CreateHorizontalBox("F4O_ITEM", 45)

	oView:SetOwnerView( "VIEW_RD0", "RD0_HEAD" )
	oView:SetOwnerView( "VIEW_F4P", "F4P_ITEM" )
	oView:SetOwnerView( "VIEW_F4O", "F4O_ITEM" )

	oView:SetCloseOnOk( { || .T. } )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} RT01VldIni
Check if there is record for Residence Status.

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RT01VldIni(oModel as Object, nOperacao as Numeric)
	Local lRet As Logical
	Local oStructF4P As Object 

	oStructF4P := oModel:GetModel("F4PDETAIL")
	oStructF4O := oModel:GetModel("F4ODETAIL")

	lRet	:= .T.
		
	If nOperacao == MODEL_OPERATION_UPDATE
		If (oStructF4P:Length() < 2)	
			oStructF4P:AddLine()
			oStructF4P:GoLine(1)
			oStructF4P:LoadValue("F4P_TPLCOD","01")
			oStructF4P:LoadValue("F4P_TPLDES",fDescRCC('S023',"01",1,2,3,100))
			oStructF4P:LoadValue("F4P_MANU","2")


			oStructF4P:AddLine()
			oStructF4P:GoLine(2)
			oStructF4P:LoadValue("F4P_TPLCOD","02")
			oStructF4P:LoadValue("F4P_TPLDES",fDescRCC('S023',"02",1,2,3,100))
			oStructF4P:LoadValue("F4P_MANU","2")

		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07Manu
Validation of F4P_TPLCOD

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russiar
/*/
Function RU07TpLCod(nLine as Numeric)
	Local cDesc As Char
	Local lRet As Logical

	if nLine < 3
		Help(,,'HELP',, STR0006 ,1,0 ) // "Length of Service Codes 01 and 02 are mandatory. Can not be deleted."
		lRet := .F.
	Else
		If  &(ReadVar()) $ "01/02"
			Help(,,'HELP',, STR0012 ,1,0 ) // "Length of Service Codes 01 and 02 can't be chosen twice."
			lRet := .F.
		Else
			lRet := .T.
			cDesc := fDescRCC('S023',M->F4P_TPLCOD,1,2,3,100)
			FwfldPut("F4P_TPLDES",cDesc)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} R07F40LinOk
Validation of F4O line R07F40LinOk

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function R07F40LinOk(oModelF4O as Object)
	Local aDates As Array 
	Local lRet As Logical
	Local n As Numeric
	Local nYear As Numeric
	Local nMonth As Numeric
	Local nDay As Numeric

	lRet := .T.

	If FwFldGet("F4P_MANU") == "1"
		Help(,,'HELP',, STR0007 ,1,0 ) // "To edit line, select 1=Yes on field 'Manual Input'."
		lRet := .F.
	EndIf

	If lRet
		If ( !empty(oModelF4O:GetValue("F4O_HIRDT")) .And. !Empty(oModelF4O:GetValue("F4O_DISDT"))) .And. ;
				oModelF4O:GetValue("F4O_DISDT") > oModelF4O:GetValue("F4O_HIRDT")
			If !oModelF4O:IsDeleted()
				aDates := DateDiffYMD(oModelF4O:GetValue("F4O_HIRDT"),oModelF4O:GetValue("F4O_DISDT"))
				
				oModelF4O:LoadValue("F4O_EBYEAR",aDates[1])
				oModelF4O:LoadValue("F4O_EBMONT",aDates[2])
				oModelF4O:LoadValue("F4O_EBDAYS",aDates[3])
			EndIf
		Else
			Help(,,'HELP',, STR0008 ,1,0 ) //"Incorrect date range"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		nYear := 0
		nMonth := 0
		nDay := 0

		for n:= 1 to oModelF4O:Length()
			If !oModelF4O:IsDeleted(n)
				
				nYear 	+= oModelF4O:GetValue("F4O_EBYEAR",n)
				nMonth 	+= oModelF4O:GetValue("F4O_EBMONT",n)
				nDay 	+= oModelF4O:GetValue("F4O_EBDAYS",n)
			EndIf
		Next

		nMonth 	+= NOROUND(nDay/30,0) // in this kind of calculation for Russia one month can be considered 30 days
		nYear	+= NOROUND(nMonth/12,0)

		nMonth	-= NOROUND(nMonth/12,0)*12
		nDay 	-= NOROUND(nday / 30,0)*30

		FwfldPut("F4P_EBYEAR",nYear,,,,.T.) // this parameter is lLoad (force)
		FwfldPut("F4P_EBMONT",nMonth,,,,.T.) // this parameter is lLoad (force)
		FwfldPut("F4P_EBDAY",nDay,,,,.T.) // this parameter is lLoad (force)
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} R07F4PLinOk
Validation of F4O line R07F4PLinOk

@author andrews.egas
@since 25/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function R07F4PLinOk(oModelF4P as Object)
	Local lRet As Logical

	lRet := .T.
	If oModelF4P:GetLine() < 3 .And. oModelF4P:IsDeleted() 
		Help(,,'HELP',, STR0006 ,1,0 ) // "Length of Service Codes 01 and 02 are mandatory. Can not be deleted."
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fT01TdOk
Validation for TudoOk of model.

@author raquel.andrade
@since 05/02/2018
@version 1.0
@project MA3 - Russia
/*/
Function fT01TdOk(oModel as Object)
	Local lRet 			As Logical
	Local oStructF4P 	As Object
	Local oStructF4O 	As Object
	Local aSaveLin		As Array
	Local bLinePost		As Block
	Local nX			As Numeric
	Local nActual		As Numeric

	oStructF4P := oModel:GetModel("F4PDETAIL")

	lRet := .T.

	If !oStructF4P:IsDeleted()

		nActual			:= oStructF4P:GetLine()
		bTemp 			:= oStructF4P:bLinePost
		oStructF4P:bLinePost := {||.T.}
		aSaveLin		:= FWSaveRows()

		For nX := 1 To oStructF4P:Length()
			oStructF4P:GoLine(nX)
			If oStructF4P:GetValue("F4P_MANU") == "1" .And. ;
					( Empty(oStructF4P:GetValue("F4P_EBYEAR")) .And. Empty(oStructF4P:GetValue("F4P_EBMONT")) .And. Empty(oStructF4P:GetValue("F4P_EBDAY")))
					lRet := .F.
					Help(,,'HELP',, STR0013 ,1,0 ) //"Field 'Manual Input' is set as 1=Yes, please inform information about Generated Years/Month/Days."
					Exit
			ElseIf oStructF4P:GetValue("F4P_MANU") == "2" .And. ;
					( Empty(oStructF4P:GetValue("F4P_EBYEAR")) .And. Empty(oStructF4P:GetValue("F4P_EBMONT")) .And. Empty(oStructF4P:GetValue("F4P_EBDAY")))
					lRet := .F.
					Help(,,'HELP',, STR0018 ,1,0 ) //"Field 'Manual Input' is set as 2=No, please inform information about Employment Book Years/Month/Days."
					Exit
			EndIf
		Next 
		
		FWRestRows(aSaveLin)
		aSize(aSaveLin,0)
		aSaveLin := Nil
		
		oStructF4P:bLinePost :=  bTemp
			
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Check if manual input to Length of Service is allowed

In a metadata thare are checking a condition: 'RU07T0101() == .T.' in block "when"

x3_cboxeng must be:
1. Yes
2. No

@author dtereshenko
@since 19/12/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T0101()
	Local oModel As Object
	Local cManu As Char

	oModel := FWModelActive()
	cManu := oModel:GetModel("F4PDETAIL"):GetValue("F4P_MANU")
	
Return (cManu == "1")


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

	ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.RU07T01'	OPERATION 2 ACCESS 0 //"View" 
	ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.RU07T01' 	OPERATION 4 ACCESS 0 //"Update"
	ADD OPTION aRotina TITLE STR0004 	ACTION 'VIEWDEF.RU07T01' 	OPERATION 5 ACCESS 0 //"Delete" 
	ADD OPTION aRotina TITLE STR0011 	ACTION 'fRD0Legend()' 		OPERATION 10 ACCESS 0 //"Legend" 

Return aRotina

//Checked and merged by AS for Russia_R4 * * *
// Russia_R5
