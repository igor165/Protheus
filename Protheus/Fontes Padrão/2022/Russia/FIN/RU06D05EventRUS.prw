#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RU06D05.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"

/*{Protheus.doc} RU06D05EventRUS
@type 		class
@author 	natalia.khozyainova
@version 	1.0
@since		27.07.2018
@description class for RU06D05
*/

Class RU06D05EventRUS From FwModelEvent 

	Method New() CONSTRUCTOR
	Method FieldPreVld()
	Method GridLinePreVld()
	Method ModelPosVld()
	Method BeforeTTS()
	Method AfterTTS()
	Method InTTS()

EndClass

/*{Protheus.doc} RU06D04EventRUS
@type 		method
@author 	natalia.khozyainova
@version 	1.0
@since		27.07.2018
@description Basic constructor. 
*/
Method New() Class RU06D05EventRUS
Return Nil


/*{Protheus.doc} RU06D04EventRUS
@type 		method
@author 	natalia.khozyainova
@version 	1.0
@since		27.07.2018
@description 
*/

Method BeforeTTS(oModel, cModelID) Class RU06D05EventRUS
Local lOk as Logical
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local cNumOrd as Character
Local cNumBnk as Character
Local nX as Numeric
Local nY as Numeric
Local cKey as Character
Local aArea as Array

cNumOrd:=''
cNumBnk:=''
aArea:= GetArea()

oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
oModelF4B:=oModel:GetModel("RU06D05_MF4B")
lOk:=oModel:GetOperation()==MODEL_OPERATION_INSERT .or. oModel:GetOperation()==9 // Insert or Copy
 
if lOk
	cNumOrd:=RU09D03NMB("PAYORD")
	while right(cNumOrd,3)='000'
    	cNumOrd:=RU09D03NMB("PAYORD")
	EndDo
	If RU99XFUN08_IsInteger(Right(cNumOrd,6))
		cNumBnk:=alltrim(str(val(right(cNumOrd,6))))
	Else
		cNumBnk:='000001'
		Help("",1,STR0063,,STR0076,1,0,,,,,,{STR0065}) // Bank Number is not allowed -- Can not include any letters -- Change the number
	EndIf
	oModelF49:LoadValue("F49_BNKORD",cNumBnk)
	oModelF49:LoadValue("F49_PAYORD",right(cNumOrd,TamSX3("F49_PAYORD")[1]))
	If !IsBlind() .AND. !FwIsInCallStack('RU06T0290_GenPayOrd')
		MsgInfo(STR0077 + alltrim(cNumBnk) + STR0093) // PO ## created 
	EndIf
EndIf

for nX:=1 to oModelF4A:Length()
	oModelF4A:GoLine(nX)
	if !oModelF4A:IsDeleted() .and. oModelF4A:IsUpdated()
		for nY:=1 to oModelF4B:Length()
			oModelF4B:GoLine(nY)
			if !oModelF4B:IsDeleted()
				cKey:=oModelF4B:GetValue("F4B_IDF4A")+oModelF4B:GetValue("F4B_PREFIX")+oModelF4B:GetValue("F4B_NUM")+oModelF4B:GetValue("F4B_PARCEL")+oModelF4B:GetValue("F4B_TYPE")
				dbSelectArea("F4B")
				F4B->(DbSetOrder(1))
				If (dbSeek(xFilial("F4B")+cKey))
					Reclock("F4B")
					dbDelete()
					MsUnlock()
				EndiF
			EndIf
		Next nY
		dbSelectArea("F4A")
		F4A->(DbSetOrder(1)) //F4A_FILIAL+F4A_CODREQ+F4A_IDF49 
		If (dbSeek(xFilial("F4A")+oModelF4A:GetValue("F4A_CODREQ")+oModelF4A:GetValue("F4A_IDF49")))
			Reclock("F4A")
			dbDelete()
			MsUnlock()
		EndIf
	EndIf
Next nX
RestArea(aArea)
Return .T.




Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class RU06D05EventRUS
Local lRet as Logical
Local oModelF4A as Object
Local nOperation as Numeric
Local aFields as Array

lRet:=.T.

If cAction == 'SETVALUE' .and. cModelId=="RU06D05_MF49"
	if (cId == "F49_DTACTP" .and. xValue<FwFldGet("F49_DTPAYM") .and. !Empty(xValue)).or. (cId=="F49_DTPAYM" .and. xValue>FwFldGet("F49_DTACTP") .and. TRIM(DTOS(FwFldGet("F49_DTACTP")))!="" )
		lRet:=.F.
		Help("",1,STR0048,,STR0047,1,0,,,,,,{STR0049}) // Actual date of payment can not be before listed date of payment -- Dates -- Change dates
	EndIf

	oModelF4A:=oSubModel:GetModel():GetModel("RU06D05_MF4A")
	nOperation:=oSubModel:GetOperation()

	If ((cId=="F49_UNIT" .or. cId=="F49_SUPP") .and. (nOperation==MODEL_OPERATION_UPDATE .OR. nOperation==MODEL_OPERATION_INSERT) .AND. AT(cId, readvar()) > 0)//RIGHT(readvar(),LEN(READVAR())-3)==cId)

		lSuppExist:=.T.
		if Empty(FwFldGet("F49_SUPP"))
			lSuppExist:=.F.
		Else
			if cId == "F49_SUPP" .and. ( !( ExistCpo("SA2",xValue) ) .or. (ExistCpo("SA2",xValue) .and. !(ExistCpo("SA2",FwFldGet("F49_SUPP"))) ) )
				lSuppExist:=.F.
			EndIf		

			if cId == "F49_UNIT" .and. ( !( ExistCpo("SA2",FwFldGet("F49_SUPP")+xValue) ) ) .or. ;
			 (ExistCpo("SA2",FwFldGet("F49_SUPP")+xValue) .and. !(ExistCpo("SA2",FwFldGet("F49_SUPP")+FwFldGet("F49_UNIT"))) )
				lSuppExist:=.F.
			EndIf	
		EndIf

		If  lSuppExist
			If MsgNoYes(STR0038, STR0039) //Are you sure?' -- Change Supp
				aFields:={"F49_TYPCC","F49_BNKREC","F49_RECBIK","F49_RECACC","F49_BKRNAM", "F49_ACRNAM", "F49_REASON", "F49_CNT"}
	            RU06XFUN01_CleanFlds(aFields) // Load "" (empty) value to each field from the array
				oModelF4A:DelAllLine()
			Else 
				lRet:=.F.
			EndIf
		EndIf
	EndIf

EndIf

Return (lRet)



Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RU06D05EventRUS
Local lRet as Logical
Local lNdel as Logical
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local oModelVirt as Object
Local nX as Numeric
Local nY as Numeric
Local nTheLine as Numeric
Local oView as Object

Local oGridF4A as Object
Local oGridF4B as Object
Local oGridFake as Object

lRet:=.T.
lNdel:=.F.

If cModelID=='RU06D05_MF4A'

	oModel:=oSubModel:GetModel()
	oModelF49:=oModel:GetModel("RU06D05_MF49")
	oModelF4A:=oModel:GetModel("RU06D05_MF4A")
	oModelF4B:=oModel:GetModel("RU06D05_MF4B")
	oModelVirt:=oModel:GetModel("RU06D05_MVIRT")

	if cAction = "UNDELETE" 
		lRet:=RU06D0539_OkToUnDelete(nLine)
	EndIf

	If lRet
		RU06D0531_TOTLS(.T., nLine, cAction) // Recalculate total Value, Total VAT
		RU06D0536_POReason(nLine,cAction) // Update Reason of Payment
		oModelF4A:GoLine(nLine)
	EndIf

	If cAction = "UNDELETE" .and. lRet 
		oModelF4B:SetNoDeleteLine(.F.)
		oModelVirt:SetNoDeleteLine(.F.)

		For nX:=1 to oModelF4B:Length() // On undeletion a line in Model F4A delete all conected lines from F4B
			oModelF4B:GoLine(nX)
			If oModelF4B:IsDeleted()
				oModelF4B:UnDeleteLine()
			EndIf
		Next nX

		For nY:=1 to oModelVirt:Length() // On undeletion a line in Model F4A delete all conected lines from Virtual Grid
			oModelVirt:GoLine(nY)
			if oModelVirt:GetValue("B_CODREQ")==oSubModel:GetValue("F4A_CODREQ")
				oModelVirt:UnDeleteLine()
			EndIf
		Next nY

		oModelF4B:SetNoDeleteLine(.T.)
		oModelVirt:SetNoDeleteLine(.T.)
	EndIf

	if cAction == "DELETE" 
		oModelF4B:SetNoDeleteLine(.F.)
		oModelVirt:SetNoDeleteLine(.F.)
		
		// check if there is another valid payment request in the model F4A otherwise clean the field F49_FILREQ	
		nTheLine:=oModelF4A:GetLine()
		nx:=1
		While nX <=  oModelF4A:Length() .and. !lNdel
			oModelF4A:GoLine(nX)
			if !(oModelF4A:IsDeleted()) .and. nX != nTheLine
				lNdel:=.T.
			EndIf
			nX++
		EndDo 
		oModelF4A:GoLine(nTheLine)
		if (!lNdel)
			oModelF49:ClearField("F49_FILREQ")
		Endif 
		for nX:=1 to oModelF4B:Length()
			oModelF4B:GoLine(nX)
			if !Empty(FwFldGet("F4B_IDF4A"))
				oModelF4B:DeleteLine()
			EndIf
		next nX

		for nY:=1 to oModelVirt:Length()
			oModelVirt:GoLine(nY)
			if oModelVirt:GetValue("B_CODREQ")==oSubModel:GetValue("F4A_CODREQ")
				oModelVirt:DeleteLine()
			EndIf
		next nY

		oModelF4B:SetNoDeleteLine(.T.)
		oModelVirt:SetNoDeleteLine(.T.)
	EndIf

	oView	:= FWViewActive()
	If oView != Nil
		oGridFake:= oView:GetViewObj("RU06D05_VVIRT")[3]
		oGridF4A:= oView:GetViewObj("RU06D05_VLNS")[3]
		oGridF4B:= oView:GetViewObj("RU06D05_VGLNS")[3]

		oGridF4A:Refresh( .T. /* lEvalChanges */, .F. /* lGoTop */)
		oGridFake:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
		oGridF4B:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
		oModelVirt:GoLine(1)
	EndIf
EndIf

Return (lRet)



Method ModelPosVld(oModel, cModelID) Class RU06D05EventRUS
Local lRet as Logical
Local oModelF49 as Object
Local oModelF4A as Object
Local nVal as Numeric
Local nX as Numeric

lRet:=.T.
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
nVal:=0
        
For nX:=1 to oModelF4A:Length()
    oModelF4A:GoLine(nX)
    If !(oModelF4A:IsDeleted()) 
        nVal+=oModelF4A:GetValue("F4A_VALUE")
    EndIf
Next nX

if nVal>oModelF49:GetValue("F49_VALUE")
	lRet:= .F.
	Help("",1,STR0078,,STR0079,1,0,,,,,,{STR0080,STR0081}) // Total Value is not correct -- Total value can not be less then sum from PRs -- Recalculate totals -- Update total value of PO manually
EndIf

Return (lRet)


Method InTTS (oModel, cModelId) Class RU06D05EventRUS
Local nOper 	as Numeric
Local nX 		as Numeric
Local nY 		as Numeric
Local nVALCNV   as Numeric
Local nVLVATC   as Numeric
Local nBSVATC   as Numeric
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local aArea 	as Array
Local aAreaF47 	as Array
Local cStatus 	as Character
Local cPayOrd 	as Character
Local cKeyF47 	as Character
Local cKeyF5M	as Character
Local cStatusPO 	as Character

nOper:=oModel:GetOperation()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
oModelF4B:=oModel:GetModel("RU06D05_MF4B")
aAreaF47:=F47->(GetArea())
aArea:=GetArea()
cStatusPO:=oModelF49:GetValue("F49_STATUS")

If (nOper==MODEL_OPERATION_INSERT .or. nOper==MODEL_OPERATION_UPDATE .or. nOper==9) .and. cStatusPO=="1"// Update, Create or Copy
	If oModelF49:GetValue("F49_PREPAY")=="1"
		nVALCNV := oModelF49:GetValue("F49_VALUE")
        nVLVATC := oModelF49:GetValue("F49_VATAMT")
		nBSVATC := nVALCNV - nVLVATC
		For nX:=1 to oModelF4A:Length()
			oModelF4A:GoLine(nX)
			If !oModelF4A:IsDeleted() 
				cStatus:="2"
				cPayOrd:=oModelF49:GetValue("F49_PAYORD")
			Else
				cPayOrd:=""
				cStatus:=IIF(SuperGetMv("MV_REQAPR",, 0)  == 1 , "4", "1")			
			EndIf
			cKeyF47:=oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
			RU06D0550_WrModelRU06D04(cKeyF47, cStatus, cPayOrd)
		Next nX
		RU06XFUN07_WrToF5(oModelF49:GetValue("F49_IDF49"), "F49", "", oModelF49:GetValue("F49_VALUE"), "2", 1,;
		                  /*cFil*/,/*lCtrBalOnl*/,nVALCNV,nBSVATC,nVLVATC                                     ) // write line 'F49'
	Else
		For nX:=1 to oModelF4A:Length()
			oModelF4A:GoLine(nX)
			If !oModelF4A:IsDeleted() 
				cStatus:="2"
				cPayOrd:=oModelF49:GetValue("F49_PAYORD")
				cKeyF47:=oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
				RU06D0550_WrModelRU06D04(cKeyF47, cStatus, cPayOrd)
				For nY:=1 to oModelF4B:Length()
					//Write line F4B
					oModelF4B:GoLine(nY)
					nVALCNV := oModelF4B:GetValue("F4B_VALCNV")
                    nBSVATC := oModelF4B:GetValue("F4B_BSVATC")
                    nVLVATC := oModelF4B:GetValue("F4B_VLVATC")
					cKeyF5M:=oModelF4B:GetValue("F4B_FLORIG")+"|"+oModelF4B:GetValue("F4B_PREFIX")+"|"+oModelF4B:GetValue("F4B_NUM")+"|"+ ;
					oModelF4B:GetValue("F4B_PARCEL")+"|"+oModelF4B:GetValue("F4B_TYPE")+"|"+oModelF49:GetValue("F49_SUPP")+"|"+oModelF49:GetValue("F49_UNIT")
					RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), "1", 1,;
					                  /*cFil*/,/*lCtrBalOnl*/,nVALCNV,nBSVATC,nVLVATC                                          ) // write line 'F4B'
				NExt nY
			Else
				cPayOrd:=""
				cStatus:=IIF(SuperGetMv("MV_REQAPR",, 0)  == 1 , "4", "1")
				cKeyF47:=oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
				RU06D0550_WrModelRU06D04(cKeyF47, cStatus, cPayOrd)
				For nY:=1 to oModelF4B:Length()
					oModelF4B:GoLine(nY)
					cKeyF5M:=oModelF4B:GetValue("F4B_FLORIG")+"|"+oModelF4B:GetValue("F4B_PREFIX")+"|"+oModelF4B:GetValue("F4B_NUM")+"|"+ ;
					oModelF4B:GetValue("F4B_PARCEL")+"|"+oModelF4B:GetValue("F4B_TYPE")+"|"+oModelF49:GetValue("F49_SUPP")+"|"+oModelF49:GetValue("F49_UNIT")
					RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), "1", 2) // delete line 'F4B'
				NExt nY		
			EndIf
		Next nX

	EndIf

EndIf
 
if nOper==5 /*Deletion*/ .or. (nOper==MODEL_OPERATION_UPDATE .and. cStatusPO=="2") /*sent to bank*/
	If oModelF49:GetValue("F49_PREPAY")=="1"
		For nX:=1 to oModelF4A:Length()
			oModelF4A:GoLine(nX)			
			cKeyF47:=oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
			If nOper == 5
				cPayOrd := ""
				cStatus:=IIF(SuperGetMv("MV_REQAPR",, 0)  == 1 , "4", "1")
				RU06D0550_WrModelRU06D04(cKeyF47, cStatus, cPayOrd)
			Else // change PR status to included in PO
				cPayOrd:=oModelF49:GetValue("F49_PAYORD")
				RU06D0550_WrModelRU06D04(cKeyF47, "2", cPayOrd)
			EndIf
		Next nX
		If nOper == 5
			RU06XFUN07_WrToF5(oModelF49:GetValue("F49_IDF49"), "F49", "", , "2", 2) // del line in F5M with alias to 'F49'
		Else // update F5M_CTRBAL
			RU06XFUN07_WrToF5(oModelF49:GetValue("F49_IDF49"), "F49", "", , "2", 1, Nil, .T.) // upd CTRBAL in F5M line
		EndIf
	Else
		For nX:=1 to oModelF4A:Length()
			oModelF4A:GoLine(nX)
			cKeyF47:=oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
			If nOper == 5
				cPayOrd:=""
				cStatus:=IIF(SuperGetMv("MV_REQAPR",, 0)  == 1 , "4", "1")
				RU06D0550_WrModelRU06D04(cKeyF47, cStatus, cPayOrd)
			Else // change PR status to included in PO
				cPayOrd:=oModelF49:GetValue("F49_PAYORD")
				RU06D0550_WrModelRU06D04(cKeyF47, "2", cPayOrd)
			EndIf
			For nY:=1 to oModelF4B:Length()
				oModelF4B:GoLine(nY)
				cKeyF5M:=oModelF4B:GetValue("F4B_FLORIG")+"|"+oModelF4B:GetValue("F4B_PREFIX")+"|"+oModelF4B:GetValue("F4B_NUM")+"|"+ ;
				oModelF4B:GetValue("F4B_PARCEL")+"|"+oModelF4B:GetValue("F4B_TYPE")+"|"+oModelF49:GetValue("F49_SUPP")+"|"+oModelF49:GetValue("F49_UNIT")
				If nOper == 5
					RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), "1", 2) //del line
				Else
					// so payment order sent to bank, change F5M_CTRBAL field in F5M record with alias to F4B
					RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), "2", 1, Nil, .T.)
				EndIf
			NExt nY	
		Next nX
	EndIf
EndIf

If nOper == MODEL_OPERATION_UPDATE /*4*/ .and. cStatusPO == "4" /*paid*/
	// so status of BS was posted in finance and we should change PO status
	// included to this BS and PR statuses included in PO
	For nX := 1 to oModelF4A:Length()
		oModelF4A:GoLine(nX)
		cPayOrd := oModelF49:GetValue("F49_PAYORD")
		cStatus := "3" //status for PR - 3 means paid
		cKeyF47 := oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
		RU06D0550_WrModelRU06D04(cKeyF47, cStatus, cPayOrd)
	Next nX
EndIf

RestArea(aArea)
RestArea(aAreaF47)

Return (.T.)




Method AfterTTS(oModel, cModelID) Class RU06D05EventRUS
Local nOper as Numeric
Local nX as Numeric
Local oModelF4A as Object
Local oModelF49 as Object
Local aArea as Array
Local aAreaF47 as Array
Local cStatus as Character

nOper:=oModel:GetOperation()
if nOper==4
	oModelF49:=oModel:GetModel("RU06D05_MF49")
	oModelF4A:=oModel:GetModel("RU06D05_MF4A")
	aAreaF47:=F47->(GetArea())
	aArea:=GetArea()
	cStatus:='1'

	cStatus:= ALLTRIM(STR(VAL(oModelF49:GetValue("F49_STATUS")) - 1 ))

	if cStatus == '2' .or. cStatus=='3'
		for nX:=1 to oModelF4A:Length()
			oModelF4A:GoLine(nX)
			DBSELECTAREA("F47")
			DBSETORDER(1) //F47_FILIAL+F47_CODREQ+DTOS(F47_DTREQ)
			iF DBSEEK(oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ")))			
				if !oModelF4A:IsDeleted() 
					if alltrim(F47->F47_PAYORD)==alltrim(oModelF49:GetValue("F49_PAYORD"))
						RECLOCK("F47",.F.)
						F47->F47_STATUS:=cStatus
						MSUNLOCK()
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
	RestArea(aArea)
	RestArea(aAreaF47)
EndIf

Return (.T.)


Static Function RU06D0550_WrModelRU06D04(cKeyF47 as Character, cStatus as Character, cPayOrd as Character)
Local oModelPR as Object

DbSelectArea("F47")
F47->(DbSetOrder(1)) //F47_FILIAL+F47_CODREQ+DTOS(F47_DTREQ)
If F47->(DBSEEK(cKeyF47))
	oModelPR:= FwLoadModel("RU06D04")
	oModelPR:SetOperation(4)
	oModelPR:Activate()
	oModelPR:GetModel("RU06D04_MHEAD"):SetValue("F47_STATUS", cStatus)
	oModelPR:GetModel("RU06D04_MHEAD"):SetValue("F47_PAYORD", cPayOrd)
	oModelPR:VldData() 
	oModelPR:CommitData()
	oModelPR:DeActivate()
EndIf
Return (Nil)

