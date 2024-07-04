#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RU06D07.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"


/*{Protheus.doc} RU06D07EventRUS
@type 		class
@author 	natasha
@version 	1.0
@since		27.04.2018
@description class for RU06D07
*/

Class RU06D07EventRUS From FwModelEvent 

	Method New() CONSTRUCTOR
	Method GridLinePosVld()
	Method GridLinePreVld()
	Method BeforeTTS()
	Method Activate()
	Method ModelPosVld()

EndClass


/*{Protheus.doc} RU06D07EventRUS
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description Basic constructor. 
*/
Method New() Class RU06D07EventRUS
Return Nil


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld

<Short description>

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       August/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Method GridLinePosVld(oSubModel, cModelID, nLine)                     Class RU06D07EventRUS

	Local lRet       As Logical
	Local oModel     As Object
	local oMdlHdr    As Object

	lRet := .T.
	oModel  := oSubModel:GetModel()
	oMdlHdr := oModel:GetModel("RU06D07_MHEAD")
	If cModelID == "RU06D07_MVIRT"
		If !oSubModel:IsEmpty() .AND. !oSubModel:IsDeleted()
			lRet := RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, "UPDATE")
		EndIf
	EndIf
	
Return (lRet) /*-----------------------------------------------------------GridLinePosVld*/



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld METHOD

<Short description>

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       July/26/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Method GridLinePreVld(oSubModel, cModelID, nLine,;
                      cAction, cID, xNVal, xCVal)                      Class RU06D07EventRUS

    Local lRet       As Logical
	Local lInflow    As Logical
	Local cFields    As Character
	Local oModel     As Object
	Local oMdlHdr    As Object
	Local nValue     As Numeric
	Local nVATAMT    As Numeric
	Local nDiffVl    As Numeric
	Local nDiffVA    As Numeric
	lRet := .T.

	//"B_CHECK", "B_VALPAY", "B_EXGRAT", "B_VLVATC", "B_BSVATC"
	oModel  := oSubModel:GetModel()
	oMdlHdr := oModel:GetModel("RU06D07_MHEAD")
	oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
	lInflow := (oMdlHdr:GetValue("F4C_OPER") == "1")
	    //Validate virtual model lines in set action
		cFields := "B_CHECK|B_VALPAY|B_EXGRAT|B_BSVATC|B_VLVATC"
		If cModelID == "RU06D07_MVIRT" .AND. cAction == "CANSETVALUE" .AND.;
		   cID == "B_VALPAY" //can't change valpay for identical currencies, for prepay
		   If AllTrim(oMdlVrt:GetValue("B_TYPE")) == "PA" .AND.; 
		       oMdlVrt:GetValue("B_CURREN") == Val(oMdlHdr:GetValue("F4C_CURREN"))
			   lRet := .F.
		   EndIf
		EndIf
		If cModelID == "RU06D07_MVIRT" .AND. cAction == "SETVALUE"
			If !oSubModel:IsEmpty()
				Do Case
					Case cID $ cFields
						nDiffVl  := oSubModel:GetValue("B_VALCNV")
						nDiffVA  := oSubModel:GetValue("B_VLVATC")
						lRet := RU06D07E1_RecalcVrtLinesValues(oSubModel, cID, nLine,;
						                                       xNVal    , xCVal      )
						If lRet .AND. cID $ "B_CHECK|B_VALPAY|B_EXGRAT"
							If lInflow
								nDiffVl := oSubModel:GetValue("B_VALCNV") - nDiffVl
								nDiffVA := oSubModel:GetValue("B_VLVATC") - nDiffVA
							Else
								nDiffVl := oSubModel:GetValue("B_VALCNV") - nDiffVl
								nDiffVA := oSubModel:GetValue("B_VLVATC") - nDiffVA
							EndIf
							If nDiffVl != 0
								If lInflow
									oMdlHdr:LoadValue("F4C_ITTOTA",;
											oMdlHdr:GetValue("F4C_ITTOTA" ) + nDiffVl)
									oMdlHdr:LoadValue("F4C_ITBALA",;
											oMdlHdr:GetValue("F4C_VALUE" ) - oMdlHdr:GetValue("F4C_ITTOTA" ))
								Else
									oMdlHdr:LoadValue("F4C_VALUE",;
											oMdlHdr:GetValue("F4C_VALUE" ) + nDiffVl)
								EndIf
							EndIf
							If nDiffVA != 0
								If lInflow
									oMdlHdr:LoadValue("F4C_ITVATF",;
										oMdlHdr:GetValue("F4C_ITVATF") + nDiffVA)
									oMdlHdr:LoadValue("F4C_ITVATO",;
										oMdlHdr:GetValue("F4C_ITVATO") +  xMoeda(nDiffVA,;
																				Val(oMdlHdr:GetValue("F4C_CURREN")),;
																				oSubModel:GetValue("B_CURREN"),;
																				oMdlHdr:GetValue("F4C_DTTRAN"),;
																				TamSx3("F4C_ITVATO")[2],;
																				);
													)
								Else
									oMdlHdr:LoadValue("F4C_VATAMT",;
								    	oMdlHdr:GetValue("F4C_VATAMT") + nDiffVA)
								EndIf
								RU06D0717_Rsn()
								oSubModel:GoLine(nLine)
							EndIf
						EndIf
				EndCase
			Else
				lRet := .F.
			EndIf
	    EndIf
		If cModelID == "RU06D07_MVIRT" .AND. (cAction == "DELETE" .OR. cAction == "UNDELETE")
			lRet    := RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, cAction)
			If lRet
				If lInflow
					nValue  := oMdlHdr:GetValue("F4C_ITTOTA" )
					nVATAMT := oMdlHdr:GetValue("F4C_ITVATF")
					nDiffVA := oMdlHdr:GetValue("F4C_ITVATO")
				Else
					nValue  := oMdlHdr:GetValue("F4C_VALUE" )
					nVATAMT := oMdlHdr:GetValue("F4C_VATAMT")
				EndIf
				If     cAction == "DELETE"
					nValue  := nValue  - oSubModel:GetValue("B_VALCNV")
					nVATAMT := nVATAMT - oSubModel:GetValue("B_VLVATC")
					If lInflow
						nDiffVA	:= nDiffVA - Round(oSubModel:GetValue("B_VLVATC")/RecMoeda(oMdlHdr:GetValue("F4C_DTTRAN"),Val(oMdlHdr:GetValue("F4C_CURREN"))),TamSx3("F4C_ITVATO")[2])
					EndIf
				ElseIf cAction == "UNDELETE"
					nValue  := nValue  + oSubModel:GetValue("B_VALCNV")
					nVATAMT := nVATAMT + oSubModel:GetValue("B_VLVATC")
					If lInflow
						nDiffVA	:= nDiffVA + Round(oSubModel:GetValue("B_VLVATC")/RecMoeda(oMdlHdr:GetValue("F4C_DTTRAN"),Val(oMdlHdr:GetValue("F4C_CURREN"))),TamSx3("F4C_ITVATO")[2])
					EndIf
					lRet    := lRet .AND. RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, "UPDATE")
				EndIf
				If lInflow
					lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITTOTA", nValue )
					lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITBALA", oMdlHdr:GetValue("F4C_VALUE" ) - oMdlHdr:GetValue("F4C_ITTOTA" ))
					lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITVATF",nVATAMT)
					lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITVATO",nDiffVA)
				Else
					lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_VALUE", nValue )
					lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_VATAMT",nVATAMT)
				EndIf
				RU06D0717_Rsn(,nLine,cAction)
				oSubModel:GoLine(nLine)
			EndIf
		EndIf
Return (lRet) /*-----------------------------------------------------------GridLinePreVld>*/


/*{Protheus.doc} RU06D07EventRUS
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description field prevalidation 
*/

Method BeforeTTS(oModel, cModelID) Class RU06D07EventRUS
Local lNewBS 		as Logical
Local oModelF4C 	as Object
Local cNumStt 		as Character
Local aArea 		as Array

aArea:= GetArea()

oModelF4C:=oModel:GetModel("RU06D07_MHEAD")
lNewBS:=oModel:GetOperation()==MODEL_OPERATION_INSERT .or. oModel:GetOperation()==9 // Insert or Copy
 
If lNewBS
	cNumStt:=RU09D03NMB("BNKSTM")
	oModelF4C:LoadValue("F4C_INTNUM",cNumStt)
	If !IsBlind()
		MsgInfo(STR0017 + alltrim(cNumStt) + STR0032) // BS ## created
	EndIf
EndIf

RestArea(aArea)
Return (.T.)

Method Activate(oModel, lCopy) Class RU06D07EventRUS

	Local oView    as Object
	Local oMdlVrt  as Object
	Local oMdlF4C  as Object
	Local nPos     as Numeric
	Local nTotDiff as Numeric
	Local nVATDiff as Numeric
	Local nX       as Numeric

	oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
	oMdlF4C := oModel:GetModel("RU06D07_MHEAD")

	oView:= FWViewActive()
	If ValType(oView) == "O" .AND. oView:GetModel():GetId()=="RU06D07"
		RU06D0748_ViewConfig(oView)
	EndIf

	//added according to JIRA task: 
	//https://jiraproducao.totvs.com.br/browse/RULOC-456
	If oMdlF4C:GetValue("F4C_OPER") == "2" .AND. oMdlF4C:GetValue("F4C_PREPAY") == "1"
		// Outflow and only prepayment
		// When we copy BS, we don't copy F5M lines
		// so we are in case when SUM(F5M_VALCNV) != F4C_VALUE.
		// We need to check this case and return a help message to the user
		// if we are in.
		nPos := oMdlVrt:GetLine()
		nTotDiff := oMdlF4C:GetValue("F4C_VALUE")
		nVATDiff := oMdlF4C:GetValue("F4C_VATAMT")
		For nX := 1 To oMdlVrt:Length()
			oMdlVrt:GoLine(nX)
			If !oMdlVrt:IsDeleted()
				nTotDiff -= oMdlVrt:GetValue("B_VALCNV")
				nVATDiff -= oMdlVrt:Getvalue("B_VLVATC")
			EndIf
		Next nX
		oMdlVrt:GoLine(nPos)
		If nTotDiff != 0 .OR. nVATDiff != 0
			HELP("",1,  STR0017 + STR0052,,; //BS - information
			STR0078+cValToChar(nTotDiff)+;   //BS value exceeds total amount by lns on:
			STR0079+cValToChar(nVATDiff),;   //incl. VAT: 
			1,0,,,,,,;
			{STR0202})
		//STR0202:
		//If you do not wish to change the value of prepayment, nevertheless 
		//you should go to the folder "Values", change the total value to any 
		//other and then to change it back.
		EndIf
	EndIf

Return (Nil)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld

Model pos validation method

@param       Object           oModel
             Character        cModelID
@return      Logical          lRet
@example     
@author      astepanov
@since       May/07/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Method ModelPosVld(oModel, cModelID) Class RU06D07EventRUS

	Local lRet       As Logical
	Local lCommitRAL As Logical
	Local oMdlVrt    As Object
	Local oMdlF4C    As Object
	Local nX         As Numeric
	Local nPos       As Numeric
	Local nVATDiff   As Numeric
	Local nTotDiff   As Numeric
	Local cAdvFlgFld As Character
	Local cAdvTipo   As Character

	lRet := .T.

	If cModelID == "RU06D07"
		If oModel:GetValue("RU06D07_MHEAD", "F4C_OPER") == "1"      // Inflow
			cAdvFlgFld := "F4C_PREREC"
			cAdvTipo   := "RA"
			If Empty(oModel:GetValue("RU06D07_MHEAD" , "F4C_CUST")) .OR.;
			   Empty(oModel:GetValue("RU06D07_MHEAD", "F4C_CUNI"))
				oModel:SetErrorMessage("RU06D07_MHEAD", "F4C_CUST",;
				                       "RU06D07_MHEAD", "F4C_CUST",;
									   "RU06D07_CustEmpty"        ,;
									   STR0101  /*Customer Empty*/,; 
									   STR0102) /*In an Inflow Bank 
									              statement we must have 
									              a customer*/
				lRet := .F.
			EndIf
		ElseIf oModel:GetValue("RU06D07_MHEAD", "F4C_OPER") == "2"  // Outflow
			cAdvFlgFld := "F4C_PREPAY"
			cAdvTipo   := "PA"
			If Empty(oModel:GetValue("RU06D07_MHEAD", "F4C_SUPP")) .OR.;
			   Empty(oModel:GetValue("RU06D07_MHEAD", "F4C_UNIT"))
				oModel:SetErrorMessage("RU06D07_MHEAD", "F4C_SUPP" ,;
				                       "RU06D07_MHEAD", "F4C_SUPP" ,;
									   "RU06D07_SuppEmpty"         ,;
									    STR0098  /*Supplier Empty*/,;
										STR0099) /*In an Outflow Bank 
										           statement we must have
										           a Supplier*/
				lRet := .F.
			Endif
		EndIf
		If lRet .AND. !Empty(cAdvFlgFld) .AND.;
		   oModel:GetValue("RU06D07_MHEAD", cAdvFlgFld) == "2"
			oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
			lRet := .F.
			nPos := oMdlVrt:GetLine()
			For nX := 1 To oMdlVrt:Length()
				oMdlVrt:GoLine(nX)
				If !oMdlVrt:IsDeleted() .AND.;
					!(Empty(oMdlVrt:GetValue("B_TYPE"))) .AND.;
					!(AllTrim(oMdlVrt:GetValue("B_TYPE")) == cAdvTipo)
					lRet := .T.
					Exit
				EndIf
			Next nX
			oMdlVrt:GoLine(nPos)
			If !lRet
			HELP("",1,  STR0017 + STR0052,,; //BS - information
				STR0180,;                    // Need 1 or more postpayment APs
				1,0,,,,,,;
				{STR0181})                   //Please add AP
			EndIf
		EndIf
	EndIf

	If lRet .AND. cModelID == "RU06D07"
		oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
		oMdlF4C := oModel:GetModel("RU06D07_MHEAD")
		If oMdlF4C:GetValue("F4C_OPER") == "1"      // Inflow
			nVATDiff   := oMdlF4C:GetValue("F4C_ITVATF") -;
						  oMdlF4C:GetValue("F4C_VATAMT")
			If (oMdlF4C:GetValue("F4C_ITBALA") < 0)
				HELP("",1,  STR0017 + STR0052,,; //BS - information
					 STR0128,;  //The sum of the accounts paybles 
					 1,0,,,,,,; //is higher than the amount in the header
					 {}) //Solution
				lRet := .F.
			EndIf
			lCommitRAL := .F.
			//If ITBALA > 0 we add new RA line
			If lRet .AND. (oMdlF4C:GetValue("F4C_ITBALA") > 0)
				// After adding new RA Line VAT difference should be equal 0
				lRet := RU06D07012_CommitRALine(oModel)
				lCommitRAL := .T.
			EndIf
			If lRet .AND. !lCommitRAL .AND. nVATDiff <> 0
				// in case ITBALA == 0 and ITVATF - VATAMT <> 0 we perform
				// very dangerous operation, we go to last(why last?) line in Vrt model and
				// decrease B_VLVATC on nVATDiff, so if we have B_VLVATC == 0.25
				// and nVATDiff == 0.50, we will store negative value in B_VLVATC (-0.25).
				// Another problem, we think that last will not be receivable in advance, but
				// if we work with only prepayment variant, last line (line number 1) will be
				// reciavable in advance.
				nX := oMdlVrt:GetLine()
				oMdlVrt:GoLine(oMdlVrt:Length())
				lRet := RU06D07E2_RecalcVlsForNonPA("B_VLVATC"/*cID*/,;
						oMdlVrt:GetValue("B_VLVATC")-nVATDiff/*xNVal*/,;
						oMdlVrt:GetValue("B_VLVATC")/*xCVal*/,;
						oMdlVrt/*oModel*/,;
						oMdlF4C/*oMdlHdr*/)
				lRet := lRet .AND. oMdlVrt:LoadValue("B_VLVATC",;
				                   oMdlVrt:GetValue("B_VLVATC")-nVATDiff)
				lRet := lRet .AND. RU06D07E9_UpdateF5MLine(oMdlVrt/*oSubModel*/,;
				                   oMdlF4C/*oMdlHdr*/, "UPDATE"/*cAction*/)
				oMdlVrt:GoLine(nX)
			EndIf
		EndIf
		If oMdlF4C:GetValue("F4C_OPER") == "2"      // Outflow
			// When we copy BS, we don't copy F5M lines
			// so we are in case when SUM(F5M_VALCNV) != F4C_VALUE.
			// We need to check this case and return a help message to the user
			// if we are in.
			nPos := oMdlVrt:GetLine()
			nTotDiff := oMdlF4C:GetValue("F4C_VALUE")
			nVATDiff := oMdlF4C:GetValue("F4C_VATAMT")
			For nX := 1 To oMdlVrt:Length()
				oMdlVrt:GoLine(nX)
				If !oMdlVrt:IsDeleted()
					nTotDiff -= oMdlVrt:GetValue("B_VALCNV")
					nVATDiff -= oMdlVrt:Getvalue("B_VLVATC")
				EndIf
			Next nX
			oMdlVrt:GoLine(nPos)
			If nTotDiff != 0 .OR. nVATDiff != 0
				HELP("",1,  STR0017 + STR0052,,; //BS - information
				STR0078+cValToChar(nTotDiff)+;   //BS value exceeds total amount by lns on:
				STR0079+cValToChar(nVATDiff),;   //incl. VAT: 
				1,0,,,,,,;
				{STR0072})                       //Please check the data
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return (lRet) /*---------------------------------------------------------------ModelPosVld*/