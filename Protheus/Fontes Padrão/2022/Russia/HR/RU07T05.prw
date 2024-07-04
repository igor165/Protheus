#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T05.CH"

/*{Protheus.doc} RU07T05
	Basic Pay
	@type  Function
	@author Din Belotserkovsky
	@since 2018-09-04	
	*/
Function RU07T05()
	Local oBrowse as Object

	oBrowse := BrowseDef()

	oBrowse:Activate()

Return Nil
//-------------------------------------------------------------------

/*{Protheus.doc} BrowseDef	
	@type  Static Function
	@author  Din Belotserkovsky
	@since 2018-09-04
	*/
 Static Function BrowseDef()
	Local oBrwTMP 	as Object

	oBrwTMP	:= FWmBrowse():New()
	oBrwTMP:SetAlias("SRA")
	oBrwTMP:SetProfileID("2")
	oBrwTMP:SetCacheView(.F.)
	oBrwTMP:ExecuteFilter(.T.)
	oBrwTMP:AddLegend( "RA_MSBLQL == '2'", "GREEN", STR0009) 	// "Active"
	oBrwTMP:AddLegend( "RA_MSBLQL == '1'", "RED" , STR0010) 	// "Inactive"
	oBrwTMP:SetDescription(STR0001) //"Basic Pay"  
	oBrwTMP:DisableDetails()

Return oBrwTMP
//-------------------------------------------------------------------

/*{Protheus.doc} ModelDef()
	Function for create model of metadata
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-09-04
	*/
Static Function ModelDef()
	Local oModel        as Object
	Local oStructSRA	as Object
	Local oStructF5D	as Object
	Local oEvents as Object

	oModel:= MPFormModel():New("RU07T05", /*bPreValid*/,/* bTudoOK*/, /* bCommit*/, /*bCancel*/)
	oModel:SetDescription(STR0001) // "Basic Pay"
	// Data for Employee
	oStructSRA := FWFormStruct(1,"SRA",{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|RA_MAT|RA_CODUNIC|RA_NOME|RA_ADMISSA|"})
	oModel:AddFields("SRAMASTER", /*cOwner*/, oStructSRA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:GetModel("SRAMASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("SRAMASTER"):SetDescription(STR0011) //"Employee"

	// Data for Pay Scale
	oStructF5D := FWFormStruct(1, "F5D")
	oModel:AddFields("F5DCHILD", "SRAMASTER", oStructF5D, /*bLinePre*/, /*{ |oGrid| RUT07LOk(oGrid) }*/, /*bPre*/, /*{ |oGrid| RUT07TOk(oGrid) }*/,/*bLoad*/)
	oModel:GetModel("F5DCHILD"):SetDescription(STR0012) //"Pay Scale"
	oModel:SetPrimaryKey({"F5D_FILIAL","F5D_CODE","F5D_MAT","F5D_DTCH"})

	// set links between SRA and F5D
	oModel:SetRelation("F5DCHILD", { {"F5D_FILIAL", 'xFilial("F5D")'}, {"F5D_CODE","RA_CODUNIC"}, {"F5D_MAT","RA_MAT"} }, F5D->(IndexKey(1)) )

	// get link for events
	oEvents := EVRU07T05():New()
	oModel:InstallEvent("EVRU07T05", ,oEvents)

Return oModel
//-------------------------------------------------------------------

/*{Protheus.doc} ViewDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-09-04	
	*/
Static Function ViewDef()
	Local oView 		as Object
	Local oModel 		as Object
	Local oStructF5D 	as Object
	Local oStructSRA  	as Object

	oModel := FWLoadModel("RU07T05")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	// Employee"s data
	oStructSRA := FwFormStruct(2,"SRA",{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|RA_MAT|RA_CODUNIC|RA_NOME|RA_ADMISSA|"})
	oStructSRA:SetNoFolder()
	oView:AddField("RU07T05_VSRA", oStructSRA, "SRAMASTER" )
	oView:SetViewProperty("RU07T05_VSRA","ONLYVIEW")
	
	// PayScale information
	oStructF5D := FWFormStruct(2, "F5D")
	oStructF5D:RemoveField( "F5D_MAT" )
	oStructF5D:RemoveField( "F5D_CODE" )
	oStructF5D:RemoveField( "F5D_STAT" )
	oStructF5D:SetNoFolder()
	oView:AddField("RU07T05_VF5D", oStructF5D, "F5DCHILD" )

	oView:CreateHorizontalBox("SRA_HEAD", 20)
	oView:CreateHorizontalBox("F5D_HEAD", 80)

	oView:SetOwnerView( "RU07T05_VSRA", "SRA_HEAD" )
	oView:EnableTitleView("RU07T05_VSRA", STR0011) //"Employee"
	oView:SetOwnerView( "RU07T05_VF5D", "F5D_HEAD" )
	oView:EnableTitleView("RU07T05_VF5D", STR0012) //"Scale"

	oView:SetCloseOnOk( { || .T. } )

Return oView
//-------------------------------------------------------------------

/*{Protheus.doc} MenuDef
	Menu  
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-09-04	
	*/
 Static Function MenuDef()
 Local aMenu as Array

 aMenu := { {STR0004, "RU07T0510()", 0, 4, 0, Nil} ,; // "Add"
			{STR0006, "VIEWDEF.RU07T05", 0, 2, 0, Nil} ,; // "View"
			{STR0007, "PesqBrw", 0, 1, 0, Nil} ,; // "Search"
			{STR0008, "RU07T0511()", 0, 5, 0, Nil} }  // "Delete"

return aMenu
//------------------------------------------------------------------

/*{Protheus.doc} RU07T0501
	Function for validation F5D_PD and filtering in st.q. SRV-BP
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-10-16	
	*/
Function RU07T0501()
return SRV->RV_COD $ "001|002|003"
//---------------------------------------------------------------

/*{Protheus.doc} RU07T0502
	Function for filtering in st.q. RBR-GP
	@type  Static Function
	@author Din Belotserkovsky, Vadim Ivanov
	@since 2018-10-16
	@version 2
	*/
Function RU07T0502() 

Local lRet as Logical

	lRet := AllTrim(RBR->RBR_CDARE) == AllTrim(F5D_ARCD) .And. RBR->RBR_APLIC == "1"

return lRet

//---------------------------------------------------------------

/*{Protheus.doc} RU07T0503
	Function for get description of RB6_CLASSE. Used in st.q. RB6RUS
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-10-16
	*/
Function RU07T0503(cCLASSE)
Return FDESC("RBF", cCLASSE, "RBF_DESC")	
//---------------------------------------------------------------

/*{Protheus.doc} RU07T0504
	Function for get min valor via RB6_CLASSE. Used in st.q. RB6RUS
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-10-16
	*/
Function RU07T0504(cCLASSE) 
	Local nMin	 as Numeric

	nMin := Posicione( "RB6", 1, xFilial( "RB6" ) +  M->F5D_GRPCD + RB6->RB6_NIVEL + "01", "RB6_VALOR" ) 

Return nMin
//---------------------------------------------------------------

/*{Protheus.doc} RU07T0505
	Function for get max valor via RB6_CLASSE. Used in st.q. RB6RUS
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-10-16	
	*/
Function RU07T0505(cCLASSE)
	Local nMax	 as Numeric
	Local aArea as Array
	Local cTabAux as Character
	Local cQuery as Character

	aArea := GetArea()
	cTabAux:=GetNextAlias()

	//nMax := Posicione( "RB6", 1, xFilial( "RB6" ) + M->F5D_GRPCD + cNIVEL + "02", "RB6_VALOR" ) 

	cQuery := " SELECT "
	cQuery += "     RB6_VALOR NMAX  "
	cQuery += " FROM " + RetSQLName("RB6") + " RB6 "
	cQuery += " WHERE "
	cQuery += "     RB6_FILIAL = '"+xFilial("RB6")+"'	AND "
	cQuery += "     RB6_TABELA  = '"+M->F5D_GRPCD+"'   		AND "
	cQuery += "     RB6_CLASSE   = '"+cCLASSE+"'          AND "
	cQuery += "     RB6_FAIXA   = '02'          AND "
	cQuery += "     D_E_L_E_T_= '' "
	cQuery := ChangeQuery(cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cTabAux , .T. , .F.)

	nMax := (cTabAux)->NMAX

	RestArea(aArea)

Return nMax
//---------------------------------------------------------------

/*{Protheus.doc} RU07T0506
	Function for validation F5D_PD and filtering in st.q. RB6RUS
	@type Function
	@author Din Belotserkovsky
	@since 2018-10-16	
	*/
Function RU07T0506()
	Local cFilter as Character

	cFilter := "@#RB6->RB6_TABELA == '" + M->F5D_GRPCD + "' .And. RB6->RB6_FAIXA == '01'@#"

Return cFilter
//---------------------------------------------------------------

/*{Protheus.doc} RU07T0507
	Function for validation F5D_SAL. It should be bettwen min and max of valors
	@type   Function
	@author Din Belotserkovsky
	@since 2018-10-16
	*/
Function RU07T0507()
	Local res 	as Logical
	Local nMin	as Numeric
	Local nMax	as Numeric

	res := .F.

	DbSelectArea("RB6")

	RB6->(dbSetOrder(2))
	// if we get have group id, try to find min and max
	If dbSeek(xFilial( "RB6" ) + M->F5D_LVLCD +  M->F5D_GRPCD)    
		// find min and max
		nMin := Posicione( "RB6", 1, xFilial( "RB6" ) +  M->F5D_GRPCD + RB6->RB6_NIVEL + "01", "RB6_VALOR" ) 
		nMax := Posicione( "RB6", 1, xFilial( "RB6" ) +  M->F5D_GRPCD + RB6->RB6_NIVEL + "02", "RB6_VALOR" ) 
		// check if M->F5D_SAL is between min and max
		res :=IIF( (M->F5D_SAL >= nMin .And. nMax >= M->F5D_SAL) .Or. M->F5D_SAL == 0, .T., .F. )
	EndIf

Return res
//---------------------------------------------------------------

/*{Protheus.doc} RU07T0508()
	@description Function for getting name of currency via code (F5D_MOEDA)

	@type  Function
	@author Din Belotserkovsky
	@since 2018-10-16
	*/
Function RU07T0508()
	Local cName as Character
	cName := Posicione("CTO",1,xFilial("CTO")+StrZero(FwFldGet("F5D_MOEDA"),TamSX3("CTO_MOEDA")[1]),"CTO_SIMB")

Return cName


//---------------------------------------------------------------
/*{Protheus.doc} RU07T0509()
	@description Function returns number of existing BasicPay entries for current Employee 

	@type Function
	@author dtereshenko
	@since 01/09/2018
/*/
Function RU07T0509()
	Local aArea As Array
	Local aAreaF5D As Array
	Local nBasPayCnt As Numeric
	Local cRegNumber As Char //RA_MAT
	Local cPersCode As Char //RA_CODUNIC
	Local cF5DIndex As Char

	nBasPayCnt := 0
	cRegNumber := SRA->RA_MAT
	cPersCode := SRA->RA_CODUNIC

	cF5DIndex := xFilial("F5D") + cPersCode + cRegNumber

	aArea := GetArea()
	aAreaF5D := F5D->(GetArea())

	DbSelectArea("F5D")
	F5D->(DBSetOrder(1))
	DBSeek(cF5DIndex)

	While !Eof() .And. cF5DIndex == (F5D->F5D_FILIAL + F5D->F5D_CODE + F5D->F5D_MAT)
		nBasPayCnt++
		DBSkip()
	EndDo 

	RestArea(aAreaF5D)
	RestArea(aArea)

Return nBasPayCnt


//---------------------------------------------------------------
/*{Protheus.doc} RU07T0510()
	@description Function for checking if user is able to add new BasicPay entry (i.e. there are no existing entries)

	@type Function
	@author dtereshenko
	@since 01/10/2019
/*/
Function RU07T0510()
	Local nBasPayCnt As Numeric

	nBasPayCnt := RU07T0509()

	If nBasPayCnt > 0
		MsgStop(STR0013, STR0014)
	Else
		FWExecView("", "RU07T05", MODEL_OPERATION_UPDATE, ,{ || .T. })
	EndIf

Return


//---------------------------------------------------------------
/*{Protheus.doc} RU07T0511()
	@description Function for checking if user is able to remove BasicPay entry (i.e. there is only one existing entry)

	@type Function
	@author dtereshenko
	@since 01/10/2019
/*/
Function RU07T0511()
	Local nBasPayCnt As Numeric

	nBasPayCnt := RU07T0509()

	If nBasPayCnt > 1
		MsgStop(STR0015, STR0014)
	Else
		FWExecView("", "RU07T05", MODEL_OPERATION_DELETE, ,{ || .T. })
	EndIf

Return


//---------------------------------------------------------------
/*{Protheus.doc} RU07T0512()
	@description Returns BasicPay entry (as array) by transfered number

	@type Function
	@author dtereshenko
	@since 01/10/2019
/*/
Function RU07T0512(nEntryNumber As Numeric)
	Local aArea As Array
	Local aAreaF5D As Array
	Local cRegNumber As Char //RA_MAT
	Local cPersCode As Char //RA_CODUNIC
	Local cF5DIndex As Char
	Local aBsPayEntry As Array

	aBsPayEntry := {}

	cRegNumber := SRA->RA_MAT
	cPersCode := SRA->RA_CODUNIC

	cF5DIndex := xFilial("F5D") + cPersCode + cRegNumber

	aArea := GetArea()
	aAreaF5D := F5D->(GetArea())

	DbSelectArea("F5D")
	F5D->(DBSetOrder(1))
	
	If DBSeek(cF5DIndex)
		DBSkip(nEntryNumber - 1)

		AAdd(aBsPayEntry, {"F5D_CODE", F5D->F5D_CODE})
		AAdd(aBsPayEntry, {"F5D_MAT", F5D->F5D_MAT})
		AAdd(aBsPayEntry, {"F5D_DTCH", F5D->F5D_DTCH})
		AAdd(aBsPayEntry, {"F5D_TPCD", F5D->F5D_TPCD})
		AAdd(aBsPayEntry, {"F5D_ARCD", F5D->F5D_ARCD})
		AAdd(aBsPayEntry, {"F5D_GRPCD", F5D->F5D_GRPCD})
		AAdd(aBsPayEntry, {"F5D_LVLCD", F5D->F5D_LVLCD})
		AAdd(aBsPayEntry, {"F5D_UTLVL", F5D->F5D_UTLVL})
		AAdd(aBsPayEntry, {"F5D_STAT", F5D->F5D_STAT})
		AAdd(aBsPayEntry, {"F5D_RGCF", F5D->F5D_RGCF})
		AAdd(aBsPayEntry, {"F5D_RGCFV", F5D->F5D_RGCFV})
		AAdd(aBsPayEntry, {"F5D_SAL", F5D->F5D_SAL})
		AAdd(aBsPayEntry, {"F5D_PD", F5D->F5D_PD})
		AAdd(aBsPayEntry, {"F5D_NSURCH", F5D->F5D_NSURCH})
		AAdd(aBsPayEntry, {"F5D_MOEDA", F5D->F5D_MOEDA})
	EndIf

	RestArea(aAreaF5D)
	RestArea(aArea)

Return aBsPayEntry


//---------------------------------------------------------------

// implementation for model events
Class EVRU07T05 From FWModelEvent
	Method New() Public Constructor
	Method Activate(oModel, cModelid) Public
	Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Public

End Class


//Constructor method for EVRU07T05
Method New() Class EVRU07T05
Return Nil


// Try to use 
Method Activate(oModel, cModelid) Class EVRU07T05
	Local aArea As Array
	Local oModelF5D As Object
	Local nBasPayCnt As Numeric
	Local nCnt As Numeric
	Local aLastBP As Array

	aArea := GetArea()

	DbSelectArea("F5D")
	F5D->(DBSetOrder(1))
	
	oModelF5D := oModel:GetModel("F5DCHILD")

	// If there are multiple BasicPay entries, show the last one
	nBasPayCnt := RU07T0509()

	If oModelF5D:GetOperation() == MODEL_OPERATION_VIEW .And. nBasPayCnt > 0
		aLastBP := RU07T0512(nBasPayCnt)

		For nCnt:=1 To Len(aLastBP)
			oModelF5D:LoadValue(aLastBP[nCnt][1], aLastBP[nCnt][2])
		Next nX
	EndIf

	// If not found smth try to get data frim sx3
	If oModelF5D <> Nil .And. !DBSeek(xFilial("F5D") + SRA->RA_CODUNIC) ;
			.And. oModelF5D:GetOperation() == MODEL_OPERATION_UPDATE

		oModelF5D:LoadValue("F5D_DTCH", SRA->RA_ADMISSA)
		oModelF5D:SetValue("F5D_UTLVL", &(GetSX3Cache("F5D_UTLVL", "X3_RELACAO")))
		oModelF5D:SetValue("F5D_RGCF", &(GetSX3Cache("F5D_RGCF", "X3_RELACAO")))
		oModelF5D:SetValue("F5D_DESCPD", &(GetSX3Cache("F5D_DESCPD", "X3_RELACAO")))
		oModelF5D:SetValue("F5D_NSURCH", &(GetSX3Cache("F5D_NSURCH", "X3_RELACAO")))
		oModelF5D:SetValue("F5D_MOEDA", &(GetSX3Cache("F5D_MOEDA", "X3_RELACAO")))

	EndIf

	DBCloseArea()

	RestArea(aArea)

Return

Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class EVRU07T05
	Local lResult As Logical
	Local cF5CIndex As Char
	Local cRgCfVal As Char
	Local aArea As Array
	Local aAreaF5C As Array

	lResult := .T.

	If cAction == "SETVALUE" .And. cId == "F5D_ARCD" .And. !Empty(xValue)
		If cModelID == "F5DCHILD"

			cF5CIndex := xFilial("F5C") + xValue

			aArea := GetArea()
			aAreaF5C := F5C->(GetArea())

			DbSelectArea("F5C")
			F5C->(DBSetOrder(1))

			If DBSeek(cF5CIndex)
				cRgCfVal := F5C->F5C_RGCF
				lResult := oSubModel:SetValue("F5D_RGCFV", cRgCfVal)
			EndIf

			RestArea(aAreaF5C)
			RestArea(aArea)

		EndIf
	EndIf

Return lResult
