#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RU06D04.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"

/*{Protheus.doc} RU06D04EventRUS
This class is used in Payment Requests and Bank statements
RU06D04 and RU06D07
@type 		class
@author 	natasha
@version 	1.0
@since		27.04.2018
@description class for RU06D04
*/

Class RU06D04EventRUS From FwModelEvent 

	Method New() CONSTRUCTOR
	Method Activate()
	Method FieldPreVld()
	Method GridLinePreVld()
	Method ModelPosVld()
	Method InTTS()

EndClass


/*{Protheus.doc} RU06D04EventRUS
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description Basic constructor. 
*/
Method New() Class RU06D04EventRUS
Return Nil


/*{Protheus.doc} RU06D04EventRUS
@type 		method
@author 	natasha
@version 	1.0
@since		26.12.2018
@description field prevalidation 
*/
Method Activate(oModel, lCopy) Class RU06D04EventRUS
Local oView as Object
oView := FWViewActive()
If (oView != Nil .AND. oView:oModel:GetID() == "RU06D04" )
	RU06D0415_ViewConfig(oView, oModel)
EndIf
Return (Nil)


/*{Protheus.doc} RU06D04EventRUS
This method reacts on:
	- Supplier code or unit change attempt. Will check if new value is valid, show warning message and, if user agrees,
	will update FIL (supplier bank account) fields.
	- Total value changed. If it is set by usr, update global variable lUserValue
	- Prepayment (Y/N) field change attempt. It will not allow to change prepayment to Yes, if there are any APs (Lines)
	in the payment request
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description field prevalidation 
*/
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class RU06D04EventRUS
Local oModelDet		as Object
Local oModelF5M		as Object
Local cAlias		as Character
Local lGoOn			as Logical

Local lRet			as Logical
Local nOperation	as Numeric
Local lSuppExist	as Logical
Local aFldsToClean 		as Array

lRet:=.T.
lGoOn:=.F.

If cAction=="SETVALUE"
	If cModelID=="RU06D04_MHEAD" // payment request
		oModelDet:=oSubModel:GetModel():GetModel("RU06D04_MLNS")
		cAlias:="F47"
		aFldsToClean:={"F47_TYPCC","F47_BNKCOD","F47_BIK","F47_ACCNT","F47_BKNAME", "F47_ACNAME", "F47_REASON", "F47_RECNAM", "F47_CNT"}
		lGoOn:=.T.
	EndIf
EndIf

//If cModelID=="RU06D04_MHEAD" .and. cAction == "SETVALUE"
If lGoOn .and. cAction == "SETVALUE"
	nOperation:=oSubModel:GetOperation()
	// When User tries to update Supplier Code or Unit, show Warning
	If ((cId==cAlias+"_UNIT" .or. cId==cAlias+"_SUPP") .and. (nOperation==MODEL_OPERATION_UPDATE .OR. nOperation==MODEL_OPERATION_INSERT) .AND. RIGHT(readvar(),LEN(READVAR())-3)==cId)

		lSuppExist:=.T. // Check if Supplier Code+Unit is valid
		If Empty(FwFldGet(cAlias+"_SUPP")) 
			lSuppExist:=.F. // Not valid if Supplier Code is Empty
		Else
			If cId == cAlias+"_SUPP" .and. ( !(ExistCpo("SA2",xValue)) .or. (ExistCpo("SA2",xValue) .and. !(ExistCpo("SA2",FwFldGet(cAlias+"_SUPP"))) ) )
				lSuppExist:=.F. // Not valid if Supplier Code (current or new) does not exist in SA2
			EndIf		

			If cId == cAlias+"_UNIT" .and. ( !(ExistCpo("SA2",FwFldGet(cAlias+"_SUPP")+xValue) ) ) .or. ;
			 (ExistCpo("SA2",FwFldGet(cAlias+"_SUPP")+xValue) .and. !(ExistCpo("SA2",FwFldGet(cAlias+"_SUPP")+FwFldGet(cAlias+"_UNIT"))) )
				lSuppExist:=.F. // Not valid if Supplier Code+Unit (current or new) does not exist in SA2
			EndIf	
		EndIf

		If  lSuppExist // if valid, show message
			If MsgNoYes(STR0066, STR0067) //Are you sure?' -- Change Supp
            	RU06XFUN01_CleanFlds(aFldsToClean) // Load "" (empty) value to each field from the array
				oModelDet:DelAllLine()
				If !Empty(oModelF5M)
					oModelF5M:DelAllLine()
				EndIf
			Else 
				lRet:=.F.
			EndIf
		EndIf
	EndIf

	If  cId == "F47_VALUE" .and. !FwIsInCallStack("R0604VAL")
		lUserValue:=.T.
	EndIf

	If cId == cAlias+"_PREPAY" .and. xValue == "1" .and. !(oModelDet:IsEmpty())
		lRet:=.F.
		Help("",1,STR0091,,STR0068,1,0,,,,,,{STR0069}) // can't set prepayment - delete bills attached
	EndIf
EndIf

Return (lRet)



/*{Protheus.doc} RU06D04EventRUS
This method reacts on:
	- Creaion a line without Number of AP. Will not allow to do so.
	- Undeletion line attempt. Will not allow to undelete if currency of the line <> currency in header
	Except for conventional units in lines + currency == 01 in header
	- Update Exchange rate in line. Will show message if not in blind mode
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description grid prevalidation 
*/

Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RU06D04EventRUS
Local lRet as Logical
Local lPostPA as Logical
Local lDelLine as Logical
Local oModelHead as Object
Local oModelL as Object
Local oModelDet as Object
Local lCurrErr as Logical
Local lGoOn  as Logical
Local cAliasH	as Character
Local cAliasL	as Character
Local cDateConUni as Character

lRet:=.T.
lGoOn:=.F.
lPostPA := .T.
lDelLine := .F.

If Type("lRecurPreVld") == "U"
	Private lRecurPreVld := .F.
EndIf

If !lRecurPreVld
	lRecurPreVld := .T.
	If Left(cModelID, 7)=="RU06D04" // payment request
		oModelHead:=oSubModel:GetModel():GetModel("RU06D04_MHEAD")
		oModelDet:=oSubModel:GetModel():GetModel("RU06D04_MLNS")
		cAliasH:="F47"
		cAliasL:="F48"
		cDateConUni:=DTOC(oModelHead:GetValue("F47_DTPLAN"))
		lGoOn:=.T.
	ElseIf Left(cModelID, 7)=="RU06D07" // bank statement
		oModelHead:=oSubModel:GetModel():GetModel("RU06D07_MHEAD")
		oModelDet:=oSubModel:GetModel():GetModel("RU06D07_MVIRT")
		oModelL:=oSubModel:GetModel():GetModel("RU06D07_MLNS")
		cAliasH:="F4C"
		cAliasL:="B"
		cDateConUni:=DTOC(oModelHead:GetValue("F4C_DTTRAN"))
		lPostPA := !(oModelHead:GetValue("F4C_STATUS") =='1' .And. oModelDet:GetValue("B_TYPE") == "PA")
		lDelLine := ("DELETE" $ cAction) .And. (oModelHead:GetValue("F4C_STATUS") =='1')
		lGoOn:=.T.
	EndIf

	If Empty(oModelDet:GetValue(cAliasL+"_NUM")) .And. lPostPA// AP can not have empty Number but it can if it is not posted PA
		lRet:=.F.
	EndIf

	If cAction = "UNDELETE" .and. lGoOn // Not allowed to undelete Line if it's currency is not the same as currensy in F47 (except for conventional units)
		lCurrErr:=.F.
		If (STRZERO(oModelDet:GetValue(cAliasL+"_CURREN"), 2, 0) != oModelHead:GetValue(cAliasH+"_CURREN"))
			If oModelHead:GetValue(cAliasH+"_CURREN")=="01"
				If alltrim(oModelDet:GetValue(cAliasL+"_CONUNI"))=="" 
					lCurrErr:=.T.
				EndIf
			Else
				lCurrErr:=.T.
			EndIf
		EndIf

		If lCurrErr
			lRet:=.F.
			Help("",1,STR0089,,STR0033,1,0,,,,,,{STR0034}) //Currency - Currency is not same between header and lines
		EndIf
	EndIf

	If cAction == "CANSETVALUE" .and. oModelDet:GetValue(cAliasL+'_CONUNI')=="1" .and. lGoOn// For conventional Units line:
			If cID == "F48_BSVATC" .OR. cID == "F48_VLVATC"
			// fields which will be changed						
				lRet:=.T.
			EndIf
		if cId==cAliasL+"_EXGRAT" // if user tries to put Exchange Rate manually, show Warning
			If !IsBlind()
				lRet:=.F.	
				if MsgNoYes(STR0097,STR0098)//The system will no longer calculate the auto exchange rate for this line. Do you wish to continue?
					lRet:=.T.
				EndIf
			EndIf
		EndIf

		If cId==cAliasL+"_CHECK" .and. xCurrentValue // If user tries to return to Exchange rate from Table, show Warning
			If !IsBlind()
				lRet:=.F.	
				if MsgNoYes(STR0099 +cDateConUni+ STR0100,STR0098 ) // the cource will be changed according to the date -- Do you wish to continue? 
					lRet:=.T.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		If Left(cModelID, 7)=="RU06D04"
			If (cID == "F48_BSVATC" .OR. cID == "F48_VLVATC") .And. cAction=="SETVALUE"
			// fields which will be changed
				//aBackUp := {"F48_VLVATC", "F48_BSVATC"}
				//aRestVl := RU06D07E3_RetFldValuesForBackup(oModelDet, aBackUp)
				nDiff := 0
				If cID == "F48_BSVATC"
				//B_VLVATC
					nDiff := oModelDet:GetValue("F48_VLVATC")
					lRet := lRet .AND. oModelDet:LoadValue("F48_VLVATC",;
					oModelDet:GetValue("F48_VALCNV") - xValue)
					nDiff := oModelDet:GetValue("F48_VLVATC") - nDiff
				ElseIf cID == "F48_VLVATC"
				//B_BSVATC
					lRet := lRet .AND. oModelDet:LoadValue("F48_BSVATC",;
					oModelDet:GetValue("F48_VALCNV") - xValue)
					nDiff := oModelDet:GetValue("F48_BSVATC") - nDiff
				EndIf				
			EndIf
			R0604VAL(.F., nLine, cAction)  // Recalcualte totals in Payment Request			
		ElseIf Left(cModelID, 7)=="RU06D07"// .And. !lDelLine
			If !lDelLine
				RU06D0759_RecalcValue("F4C_VALUE",nLine,cAction)	// Recalcualte totals in Bank Statement
				oModelDet:GoLine(nLine)
			Else
				RU06D0759_RecalcValue("B_VALCNV",nLine,cAction)
				oModelDet:GoLine(nLine)
			EndIf
		EndIf
	EndIf
	lRecurPreVld := .F.
EndIf
Return (lRet)


/*{Protheus.doc} RU06D04EventRUS
This methodreturns FALSE if:
	- SUMM in rubles from lines is more than total value of PR
	- Class and Contract number are not specified in PR for Prepayment
It will set Status == 1 if for some reason it is empty
@type 		method
@author 	natalia.khozyainova
@version 	1.0
@since		27.04.2018
@description grid prevalidation 
*/
Method ModelPosVld(oModel, cModelID) Class RU06D04EventRUS
Local lRet as Logical
Local oModelF47 as Object
Local oModelF48 as Object
Local nVal as Numeric
Local nX as Numeric

lRet:=.T.
If cModelID=="RU06D04"

	nVal:=0
	oModelF47:=oModel:GetModel("RU06D04_MHEAD")
	oModelF48:=oModel:GetModel("RU06D04_MLNS")
			
	For nX:=1 to oModelF48:Length() // Calculate total from lines in rubles
		oModelF48:GoLine(nX)
		if !(oModelF48:IsDeleted()) 
			nVal+=oModelF48:GetValue("F48_VALCNV")
		EndIf
	Next nX

	if nVal>oModelF47:GetValue("F47_VALUE")// Total by lines (in RUB) should not be more than total in F47
		lRet:= .F.
		Help("",1,STR0073,,STR0074,1,0,,,,,,{STR0009})
	EndIf
	
	/* Temporary fix until contracts will be fixed in F47
	If lRet==.T. .and. oModelF47:GetValue("F47_PREPAY")=="1" .and. (Alltrim(oModelF47:GetValue("F47_CLASS"))='' .or. Alltrim(oModelF47:GetValue("F47_CNT"))='' )
		// If Class or Contract is empty in PR for prepayment
		lRet:=.F.
		Help("",1,STR0094,,STR0095,1,0,,,,,,{STR0088})
	EndIf */

	If lRet==.T. .and. Empty(oModelF47:GetValue("F47_STATUS")) // set Status == 1 if it is empty
		oModelF47:LoadValue("F47_STATUS","1")
	EndIf
EndIf

Return (lRet)




/*{Protheus.doc} RU06D04EventRUS
This method

@type 		method
@author 	natalia.khozyainova
@version 	1.0
@since		27.04.2018
@description grid prevalidation 
*/
Method InTTS (oModel, cModelId) Class RU06D04EventRUS
Local nOper		as Numeric
Local nX		as Numeric
Local nVALCNV   as Numeric
Local nVLVATC   as Numeric
Local nBSVATC   as Numeric
Local oModelF47 as Object
Local oModelF48 as Object
Local aArea 	as Array
Local aAreaF5M	as Array
Local cKeyF5M	as Character
Local cStatus 	as Character

If cModelID == "RU06D04"
	nOper:=oModel:GetOperation()
	oModelF47:=oModel:GetModel("RU06D04_MHEAD")
	oModelF48:=oModel:GetModel("RU06D04_MLNS")
	cStatus:=oModelF47:GetValue("F47_STATUS")
	aArea:=GetArea()
	aAreaF5M:=F5M->(GetArea())
	cKeyF5M:=""

	If  oModelF47:GetValue("F47_PREPAY")=="1" // If Prepayment, write only header
		nVALCNV := oModelF47:GetValue("F47_VALUE")
        nVLVATC := oModelF47:GetValue("F47_VATAMT")
		nBSVATC := nVALCNV - nVLVATC
		If (nOper==MODEL_OPERATION_UPDATE .or. nOper==MODEL_OPERATION_INSERT .or. nOper==9) .and. (cStatus=="1" .or. cStatus=="4") // Update, Add, Copy
			RU06XFUN07_WrToF5(oModelF47:GetValue("F47_IDF47"), "F47",, oModelF47:GetValue("F47_VALUE"), "2", 1,;
			                  /*cFil*/,/*lCtrBalOnl*/,nVALCNV,nBSVATC,nVLVATC                                  ) // 1 means update
		ElseIf nOper==5  //Deletion
			RU06XFUN07_WrToF5(oModelF47:GetValue("F47_IDF47"), "F47",, , , 2) // 2 means deletion
		ElseIf nOper == MODEL_OPERATION_UPDATE /*4*/ .and. cStatus == "2" /*included in PO */
			// so we included PR in PO we should change F5M_CTRBAL to '2' for F5M line with alias to F47
			RU06XFUN07_WrToF5(oModelF47:GetValue("F47_IDF47"), "F47",,, "2", 1, Nil, .T.) //update F5M_CTRBAL
		EndIf
	Else  // Else check lines in F48 (Accounts Payables)
		For nX:=1 to oModelF48:Length()
			oModelF48:GoLine(nX)
			 nVALCNV := oModelF48:GetValue("F48_VALCNV")
             nBSVATC := oModelF48:GetValue("F48_BSVATC")
             nVLVATC := oModelF48:GetValue("F48_VLVATC")
			If !Empty(oModelF48:GetValue("F48_NUM")) // If line is not empty
				cKeyF5M:=oModelF48:GetValue("F48_FLORIG")+"|"+oModelF48:GetValue("F48_PREFIX")+"|"+oModelF48:GetValue("F48_NUM")+"|"+ ;
				oModelF48:GetValue("F48_PARCEL")+"|"+oModelF48:GetValue("F48_TYPE")+"|"+oModelF47:GetValue("F47_SUPP")+"|"+oModelF47:GetValue("F47_UNIT")
			Else	
				cKeyF5M:=""
			EndIf

			If  (nOper==MODEL_OPERATION_UPDATE .or. nOper==MODEL_OPERATION_INSERT .or. nOper==9) .and. (cStatus=="1" .or. cStatus=="4") // UPD or Creation or Copy
				If oModelF48:IsDeleted() .and. !Empty(cKeyF5M)
					RU06XFUN07_WrToF5(oModelF48:GetValue("F48_UUID"), "F48", cKeyF5M, oModelF48:GetValue("F48_VALREQ"), "1", 2) // delete the line
				ElseIf !Empty(cKeyF5M)
					RU06XFUN07_WrToF5(oModelF48:GetValue("F48_UUID"), "F48", cKeyF5M, oModelF48:GetValue("F48_VALREQ"), "1", 1,;
					                  /*cFil*/,/*lCtrBalOnl*/,nVALCNV,nBSVATC,nVLVATC                                          ) // upd or create the line
				EndIf
			ElseIf nOper==5 //deletion
				If !Empty(cKeyF5M)
					RU06XFUN07_WrToF5(oModelF48:GetValue("F48_UUID"), "F48", cKeyF5M, oModelF48:GetValue("F48_VALREQ"), "1", 2) // delete the line
				EndIf
			ElseIf nOper == MODEL_OPERATION_UPDATE /*4*/ .and. cStatus == "2" /*included in PO */
				// so we included PR in PO we should change F5M_CTRBAL to '2' for F5M line with alias to F48
				If !Empty(cKeyF5M)
					RU06XFUN07_WrToF5(oModelF48:GetValue("F48_UUID"), "F48", cKeyF5M, oModelF48:GetValue("F48_VALREQ"), "2", 1, Nil, .T.)
				EndIf
			EndIf
		Next nX
	EndIf

	RestArea(aArea)
	RestArea(aAreaF5M)
	
	lUserValue := .F.	//(19/11/2019): return default value
EndIf

Return (.T.)

// Russia_R5