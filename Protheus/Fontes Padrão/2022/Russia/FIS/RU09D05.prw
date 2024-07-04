#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'RU09XXX.ch'



/*/{Protheus.doc} RU09D05
All the Open Balances of money values from VAT Purchases Invoices.
The values from Open Balances could be put into a Purchases Books or written-off 
@author Artem Kostin
@since 1/23/2018
@version P12.1.20
@type function
/*/
Function RU09D05()
Local oBrowse as Object

// Initalization of the table, if they do not exist.
DbSelectArea("F32")
F32->(dbSetOrder(1))

oBrowse := FWLoadBrw("RU09D05")
oBrowse:Activate()

Return(.T.)
// The end of Function RU09D05()



/*/{Protheus.doc} BrowseDef
Defines the browser for the Purchases VAT Balances.
@author Artem Kostin
@since 26/03/2017
@version P12.1.20
@type function
/*/
Static Function BrowseDef()
Local oBrowse as Object

Private aRotina as Array

aRotina := MenuDef()

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("F32")
oBrowse:SetDescription(STR0938)
oBrowse:DisableDetails()

Return(oBrowse)



/*/{Protheus.doc} MenuDef
Defines the menu to Purchases VAT Balances.
@author Artem Kostin
@since 01/23/2017
@version P12.1.20
@type function
/*/
Static Function MenuDef()
Local aRet as Array

aRet := {{STR0902, "", 0, 2, 0, Nil}}

Return(aRet)
// The end of Function MenuDef()



/*/{Protheus.doc} ModelDef
Creates the model of Purchases VAT Balances.
@author Artem Kostin
@since 01/23/2017
@version P12.1.20
@type function
/*/
Static Function ModelDef()
Local oModel as Object

Local oCab as Object
Local oStructF32 as Object

oCab := FWFormModelStruct():New()
oStructF32 := FWFormStruct(1, "F32")

oModel := MPFormModel():New("RU09D05")
// FWFORMMODELSTRUCT (): AddTable (<cAlias>, [aPK], <cDescription>, <bRealName>) -> NIL
oCab:AddTable('F32', ,'F32',)
//FWFORMMODELSTRUCT (): AddField (<cTitle>, <cTooltip>, <cIdField>, <cType>, <nSize>, [nDecimal], [bValid], [bWhen], [aValues], [lBrigat], [bInit] <lKey>, [lNoUpd], [lVirtual], [cValid]) -> NIL
oCab:AddField("Id","","F32_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)

oModel:AddFields("F32MASTER", /*cOwner*/, oCab , , ,{|o|{}})
oModel:GetModel('F32MASTER'):SetDescription(STR0938)
oModel:SetPrimaryKey({})

oModel:AddGrid("F32DETAIL", "F32MASTER", oStructF32)
oModel:SetOptional("F32DETAIL", .T.)

Return(oModel)
// The end of Function ModelDef()



/*/{Protheus.doc} ViewDef
Creates the view of Purchases VAT Balances.
@author Artem Kostin
@since 01/23/2017
@version P12.1.20
@type function
/*/
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStructF32 as Object

oModel := FwLoadModel("RU09D05")
oStructF32 := FWFormStruct(2, "F32")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("F32_D", oStructF32, "F32DETAIL")

oView:CreateHorizontalBox("MAINBOX", 100)

oView:SetOwnerView("F32_D", "MAINBOX")
oView:SetNoInsertLine("F32_D")
oView:SetNoUpdateLine("F32_D")
oView:SetNoDeleteLine("F32_D")

Return(oView)
// The end of Function ViewDef()



/*/{Protheus.doc} RU09D05Add
Creates a procedure to register the new balances of Purchases VAT Invoices values.
Function should be used in the moment, when object Model is commited, but still exists.
@author Artem Kostin
@since 01/23/2017
@version P12.1.20
@type function
/*/
Function RU09D05Add(oModel as Object)
Local lRet := .T.

Local cTab := ""
Local cModelId as Character

Local cEmptyZD as Character

// Checks, if routine get an argument of object type and if routine has an object to extract data.
If ValType(oModel) != "O"
	lRet := .F.
	Help("",1,"RU09D05Add01",,STR0910,1,0)
EndIf

If lRet
	cModelId := oModel:GetId()
	// If routine is called from Purchases VAT Invoices.
	If (cModelId == "RU09T03")
		dbSelectArea("F32")
		F32->(dbSetOrder(1))
	
	Else // Caller is unknown.
		lRet := .F.
		Help("",1,"RU09D05Add02",,STR0926,1,0)
	EndIf
EndIf

// Performs an SQL query and fills the cTab alias.
lRet := lRet .and. getTempTable(oModel, @cTab)

If lRet
	cEmptyZD := StoD(Space(TamSX3("F32_ZERODT")[1]))

	// Setting values into the Balances table model line by line.
	Begin Transaction
	
	(cTab)->(DBGoTop())
	While !(cTab)->(Eof())
		RecLock("F32", .T.)

		F32->F32_FILIAL := xFilial('F32')
		F32->F32_KEY := (cTab)->VAT_KEY	// Purchase VAT Invoice Key.
		F32->F32_SUPPL := (cTab)->SUPPLIER	// Supplier's Code
		F32->F32_SUPUN := (cTab)->SUPP_BRANCH	// Supplier's Unit Code
		F32->F32_DOC := (cTab)->DOC_NUM	// Purchase VAT Invoice Document Number.
		F32->F32_RDATE := StoD((cTab)->REAL_DATE) // The Balance Date must be equal real inclusion date of the VAT Purchases Invoice
		F32->F32_PDATE := StoD((cTab)->PRINT_DATE) // The Balances table holds print date of the VAT Purchases Invoice
		F32->F32_VATCOD := (cTab)->INTCODE	// Purchase VAT Invoice Internal Code.
		F32->F32_VATCD2 := (cTab)->EXTCODE	// Purchase VAT Invoice External (Operational) Code.
		F32->F32_VATRT := (cTab)->VAT_RATE	// Tax Rate related to Internals and Externals Codes.
		F32->F32_OPBAL := (cTab)->INIT_BALANCE	// VAT Value based on Open Balance.
		F32->F32_OPBS := (cTab)->INIT_BASE	// Purchase VAT Invoice Base ready to reclaim or write-off.
		F32->F32_BOOKVL := 0	// Current Purchase Book (Reclaimed) VAT Value.
		F32->F32_BOOKBS := 0	// Current Purchase Book (Reclaimed) VAT Base.
		F32->F32_WOFFVL := 0	// Current Write-Off VAT Value.
		F32->F32_WOFFBS := 0	// Current Write-Off VAT Base.
		F32->F32_RESTBS := 0	// Current Restored Base
		F32->F32_RESTVL := 0	// Current Restored Value
		F32->F32_INIBAL := (cTab)->INIT_BALANCE	// Initial Balance Value at this date.
		F32->F32_INIBS := (cTab)->INIT_BASE	// Initial Balance Base at this date.
		
		MsUnlock("F32")
		
		(cTab)->(DbSkip())
	EndDo
	End Transaction
EndIf

CloseTempTable(cTab)

Return(lRet)
// The end of Function RU09D05Add



/*/{Protheus.doc} RU09D05Edt
Creates a procedure to register the new Balances of Purchases VAT Invoices values.
Function should be used in the moment, when object Model is commited, but still exists.
@author Artem Kostin
@since 01/23/2017
@version P12.1.20
@type function
/*/
Function RU09D05Edt(oModel as Object)
Local lRet := .T.

Local cTab := ""
Local cTabDel := ""
Local cSeek as Character
Local cModelId as Character
Local oModelDetail as Object

Local cEmptyZD as Character

Local nLine as Numeric

Local nOpenBase as Numeric

// Checks, if routine get an argument of object type and if routine has an object to extract data.
If ValType(oModel) != "O"
	lRet := .F.
	Help("",1,"RU09D05Edt01",,STR0910,1,0)
EndIf

If lRet
	cModelId := oModel:GetId()
	If !(cModelId $ "RU09T03|RU09T05|RU09T06|RU09T08") // Caller is unknown.
		lRet := .F.
		Help("",1,"RU09D05Edt04",,STR0926,1,0)
	EndIf
EndIf

// Performs an SQL query and fills the cTab, cTabDel aliases.
lRet := lRet .and. getTempTable(oModel, @cTab, @cTabDel)

If lRet
	cEmptyZD := StoD(Space(TamSX3("F32_ZERODT")[1]))

	// Changing the working area to F32 Purchases VAT Invoices Balances table.
	dbSelectArea("F32")
	F32->(dbSetOrder(1))

	Begin Transaction
	// If routine is called from Purchases VAT Invoices.
	If cModelId == "RU09T03"
		// Setting values into the Balances table model line by line.
		nLine := 1
		F32->(DBGoTop())
		(cTab)->(DBGoTop())
		While !(cTab)->(Eof())
			cSeek := PadR((cTab)->VAT_KEY, TamSX3("F32_KEY")[1], " ");
					+ PadR((cTab)->INTCODE, TamSX3("F32_VATCOD")[1], " ");
					+ PadR((cTab)->EXTCODE, TamSX3("F32_VATCD2")[1], " ")
			// If record is found in the  Balances Table, update it.
			If !Empty(cSeek) .and. F32->(dbSeek(xFilial("F32") + cSeek))
				RecLock("F32", .F.)

			Else // If record is not found, add it.
				RecLock("F32", .T.)
			EndIf

			nOpenBase := (cTab)->INIT_BASE

			F32->F32_FILIAL := xFilial('F32')
			F32->F32_KEY := (cTab)->VAT_KEY	// Purchase VAT Invoice Key.
			F32->F32_SUPPL := (cTab)->SUPPLIER	// Supplier's Code
			F32->F32_SUPUN := (cTab)->SUPP_BRANCH	// Supplier's Unit Code
			F32->F32_DOC := (cTab)->DOC_NUM	// Purchase VAT Invoice Document Number.
			F32->F32_RDATE := StoD((cTab)->REAL_DATE)	// The Balance Date must be equal real inclusion date of th VAT Purchases Invoice
			F32->F32_PDATE := StoD((cTab)->PRINT_DATE) // The Balances table holds print date of the VAT Purchases Invoice
			F32->F32_VATCOD := (cTab)->INTCODE	// Purchase VAT Invoice Internal Code.
			F32->F32_VATCD2 := (cTab)->EXTCODE	// Purchase VAT Invoice External (Operational) Code.
			F32->F32_VATRT := (cTab)->VAT_RATE	// VAT Rate
			F32->F32_OPBAL := (cTab)->INIT_BALANCE	// VAT Value based on Open Balance.
			F32->F32_OPBS := nOpenBase	// Purchase VAT Invoice Base ready to reclaim or write-off.
			F32->F32_BOOKVL := 0	// Current Purchase Book (Reclaimed) VAT Value.
			F32->F32_BOOKBS := 0	// Current Purchase Book (Reclaimed) VAT Base.
			F32->F32_WOFFVL := 0	// Current Write-Off VAT Value.
			F32->F32_WOFFBS := 0	// Current Write-Off VAT Base.
			F32->F32_INIBAL := (cTab)->INIT_BALANCE	// Initial Balance Value at this date.
			F32->F32_INIBS := (cTab)->INIT_BASE	// Initial Balance Base at this date.
			F32->F32_ZERODT := dDataBase

			MsUnlock("F32")
			(cTab)->(DbSkip())
		EndDo

		F32->(DBGoTop())
		While !(cTabDel)->(Eof())
			cSeek := PadR((cTabDel)->VAT_KEY, TamSX3("F32_KEY")[1], " ");
					+ PadR((cTabDel)->INTCODE, TamSX3("F32_VATCOD")[1], " ")
			// If record is found in the  Balances Table, delete it.
			If !Empty(cSeek) .and. F32->(dbSeek(xFilial("F32") + cSeek))
				RecLock("F32", .F.)
					F32->(DbDelete())
				MsUnlock("F32")
			EndIf
			
			(cTabDel)->(DbSkip())
		EndDo

	// If routine is called from the Purchases Book
	ElseIf cModelId == "RU09T05"
		oModelDetail := oModel:GetModel("F3CDETAIL")
		// Setting values into the Balances table model line by line.
		For nLine := 1 to oModelDetail:Length()
			oModelDetail:GoLine(nLine)

			If !Empty(oModelDetail:GetValue("F3C_KEY"))
				cSeek := oModelDetail:GetValue("F3C_KEY");
						+ oModelDetail:GetValue("F3C_VATCOD");
						+ oModelDetail:GetValue("F3C_VATCD2")
						
				If !Empty(cSeek) .and. F32->(DbSeek(xFilial("F32") + cSeek))
					RecLock("F32", .F.)
					If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
						F32->F32_OPBS := F32->F32_OPBS + oModelDetail:GetValue("F3C_RECBAS") // Purchase VAT Invoice Base ready to reclaim or write-off.
						F32->F32_OPBAL := F32->F32_OPBAL + oModelDetail:GetValue("F3C_VALUE")	// VAT Value based on Open Balance.
						F32->F32_BOOKBS := F32->F32_BOOKBS - oModelDetail:GetValue("F3C_RECBAS")	// Current Purchase Book (Reclaimed) VAT Base.
						F32->F32_BOOKVL := F32->F32_BOOKVL - oModelDetail:GetValue("F3C_VALUE")	// Current Purchase Book (Reclaimed) VAT Value.				
						F32->F32_ZERODT := cEmptyZD
					Else
						nOpenBase := F32->F32_OPBS - oModelDetail:GetValue("F3C_RBSDIF")
					
						F32->F32_OPBS := nOpenBase	// Purchase VAT Invoice Base ready to reclaim or write-off.
						F32->F32_OPBAL := F32->F32_OPBAL - oModelDetail:GetValue("F3C_RVLDIF")	// VAT Value based on Open Balance.
						F32->F32_BOOKBS := F32->F32_BOOKBS + oModelDetail:GetValue("F3C_RBSDIF")	// Current Purchase Book (Reclaimed) VAT Base.
						F32->F32_BOOKVL := F32->F32_BOOKVL + oModelDetail:GetValue("F3C_RVLDIF")	// Current Purchase Book (Reclaimed) VAT Value.				
						If nOpenBase > 0
							F32->F32_ZERODT := cEmptyZD
						Else
							F32->F32_ZERODT := oModel:GetModel("F3BMASTER"):GetValue("F3B_FINAL")	// Date of final the balance.
						EndIf
					EndIf
					MsUnlock("F32")
				Else
					lRet := .F.
					Help("",1,"RU09D05Edt02",,STR0940 + STR0938,1,0,,,,,,{oModelDetail:GetValue("F3C_ITEM")})
					DisarmTransaction()
					Exit
				EndIf
			EndIf
		Next nLine

	// If routine is called from Write-Off Document.
	ElseIf cModelId == "RU09T06"
		oModelDetail := oModel:GetModel("F3EDETAIL")
		// Setting values into the Balances table model line by line.
		For nLine := 1 to oModelDetail:Length()
			oModelDetail:GoLine(nLine)

			If !Empty(oModelDetail:GetValue("F3E_KEY"))
			
				cSeek := oModelDetail:GetValue("F3E_KEY");
						+ oModelDetail:GetValue("F3E_VATCOD");
						+ oModelDetail:GetValue("F3E_VATCD2")

				If !Empty(cSeek) .and. F32->(DbSeek(xFilial("F32") + cSeek))

					RecLock("F32", .F.)
					If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
						F32->F32_OPBS := F32->F32_OPBS + oModelDetail:GetValue("F3E_WOFBAS")	// Purchase VAT Invoice Base ready to reclaim or write-off.
						F32->F32_OPBAL := F32->F32_OPBAL + oModelDetail:GetValue("F3E_VALUE")	// VAT Value based on Open Balance.
						F32->F32_WOFFBS := F32->F32_WOFFBS - oModelDetail:GetValue("F3E_WOFBAS")	// Current Purchase Book (Reclaimed) VAT Base.
						F32->F32_WOFFVL := F32->F32_WOFFVL - oModelDetail:GetValue("F3E_VALUE")	// Current Purchase Book (Reclaimed) VAT Value.				
						F32->F32_ZERODT := cEmptyZD
					Else
						nOpenBase := F32->F32_OPBS - oModelDetail:GetValue("F3E_WBSDIF")
					
						F32->F32_OPBS := nOpenBase	// Purchase VAT Invoice Base ready to reclaim or write-off.
						F32->F32_OPBAL := F32->F32_OPBAL - oModelDetail:GetValue("F3E_WVLDIF")	// VAT Value based on Open Balance.
						F32->F32_WOFFBS := F32->F32_WOFFBS + oModelDetail:GetValue("F3E_WBSDIF")	// Current Purchase Book (Reclaimed) VAT Base.
						F32->F32_WOFFVL := F32->F32_WOFFVL + oModelDetail:GetValue("F3E_WVLDIF")	// Current Purchase Book (Reclaimed) VAT Value.				
						If nOpenBase > 0
							F32->F32_ZERODT := cEmptyZD
						Else
							F32->F32_ZERODT :=  oModel:GetModel("F3DMASTER"):GetValue("F3D_FINAL")	// Date of final the balance.
						EndIf
					EndIf
					MsUnlock("F32")
				Else
					lRet := .F.
					Help("",1,"RU09D05Edt03",,STR0940 + STR0938,1,0,,,,,,{oModelDetail:GetValue("F3E_ITEM")})
					DisarmTransaction()
					Exit
				EndIf
			EndIf
		Next nLine
	
	// If routine is called from VAT Restoration.
	ElseIf cModelId == "RU09T08"
		oModelDetail := oModel:GetModel("F53DETAIL")
		// Setting values into the Balances table model line by line.
		
		For nLine := 1 to oModelDetail:Length()
			oModelDetail:GoLine(nLine)

			If !Empty(FWFldGet("F53_KEY"))
			
				// Updates existing Balances with Old VAT Code from the line of Restoration
				cSeek := FWFldGet("F53_KEY") + FWFldGet("F53_OVTCOD")
				If !Empty(cSeek) .and. F32->(DbSeek(xFilial("F32") + cSeek))
					RecLock("F32", .F.)
					If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
						F32->F32_RESTBS := F32->F32_RESTBS - FWFldGet("F53_RESTBS")
						F32->F32_RESTVL := F32->F32_RESTVL - FWFldGet("F53_RESTVL")
					ElseIf oModelDetail:IsDeleted()
						F32->F32_RESTBS := F32->F32_RESTBS - FWFldGet("F53_RBSBKP")
						F32->F32_RESTVL := F32->F32_RESTVL - FWFldGet("F53_RVLBKP")
					Else
						F32->F32_RESTBS := F32->F32_RESTBS - FWFldGet("F53_RBSBKP") + FWFldGet("F53_RESTBS")
						F32->F32_RESTVL := F32->F32_RESTVL - FWFldGet("F53_RVLBKP") + FWFldGet("F53_RESTVL")
					EndIf
					MsUnlock("F32")
				Else
					lRet := .F.
					Help("",1,"RU09D05Edt05",,STR0940 + STR0938,1,0,,,,,,{oModelDetail:GetValue("F53_ITEM")})
					DisarmTransaction()
					Exit
				EndIf

				// Updates existing or created new Balances with New VAT Code from the line of Restoration
				If (FWFldGet("F52_WRIOFF") == "2")
					cSeek := FWFldGet("F53_KEY") + FWFldGet("F53_NVTCDB")
					If !Empty(cSeek) .and. F32->(DbSeek(xFilial("F32") + cSeek))
						RecLock("F32", .F.)
						F32->F32_OPBS := F32->F32_OPBS - FWFldGet("F53_RBSBKP")
						F32->F32_OPBAL := F32->F32_OPBAL - FWFldGet("F53_RVLBKP")
						If (FWFldGet("F53_OVTCOD") != FWFldGet("F53_NVTCDB"))
							F32->F32_RESTBS := F32->F32_RESTBS - FWFldGet("F53_RBSBKP")
							F32->F32_RESTVL := F32->F32_RESTVL - FWFldGet("F53_RVLBKP")
							F32->F32_INIBS := F32->F32_INIBS - FWFldGet("F53_RBSBKP")
							F32->F32_INIBAL := F32->F32_INIBAL - FWFldGet("F53_RVLBKP")
						EndIf
						MsUnlock("F32")
					EndIf

					cSeek := FWFldGet("F53_KEY") + FWFldGet("F53_NVTCOD")
					If !Empty(cSeek) .and. F32->(DbSeek(xFilial("F32") + cSeek))
						RecLock("F32", .F.)
						If (oModel:GetOperation() == MODEL_OPERATION_INSERT) .or. (oModel:GetOperation() == MODEL_OPERATION_UPDATE) .or. (! oModelDetail:IsDeleted())
							F32->F32_OPBS := F32->F32_OPBS + FWFldGet("F53_RESTBS")
							F32->F32_OPBAL := F32->F32_OPBAL + FWFldGet("F53_RESTVL")
							If (FWFldGet("F53_OVTCOD") != FWFldGet("F53_NVTCOD"))
								F32->F32_RESTBS := F32->F32_RESTBS + FWFldGet("F53_RESTBS")
								F32->F32_RESTVL := F32->F32_RESTVL + FWFldGet("F53_RESTVL")
								F32->F32_INIBS := F32->F32_INIBS + FWFldGet("F53_RESTBS")
								F32->F32_INIBAL := F32->F32_INIBAL + FWFldGet("F53_RESTVL")
							EndIf
						EndIf

					ElseIf (!oModelDetail:IsDeleted())
						RecLock("F32", .T.)
						F32->F32_FILIAL := xFilial('F32')
						F32->F32_KEY := FWFldGet("F53_KEY")	// Purchase VAT Invoice Key.
						F32->F32_SUPPL := FWFldGet("F53_SUPPL")	// Supplier's Code
						F32->F32_SUPUN := FWFldGet("F53_SUPUN")	// Supplier's Unit Code
						F32->F32_DOC := FWFldGet("F53_DOC")	// Purchase VAT Invoice Document Number.
						F32->F32_RDATE := FWFldGet("F52_DATE")	// The Balance Date must be equal real inclusion date of th VAT Purchases Invoice
						F32->F32_PDATE := FWFldGet("F53_PDATE") // The Balances table holds print date of the VAT Purchases Invoice
						F32->F32_VATCOD := FWFldGet("F53_NVTCOD")	// Purchase VAT Invoice Internal Code.
						F32->F32_VATCD2 := FWFldGet("F53_NVTCD2")	// Purchase VAT Invoice External (Operational) Code.
						F32->F32_OPBAL := FWFldGet("F53_RESTVL")	// VAT Value based on Open Balance.
						F32->F32_OPBS := FWFldGet("F53_RESTBS")	// Purchase VAT Invoice Base ready to reclaim or write-off.
						F32->F32_VATRT := FWFldGet("F53_VATRT")	// VAT percent Rate
						F32->F32_BOOKVL := 0	// Current Purchase Book (Reclaimed) VAT Value.
						F32->F32_BOOKBS := 0	// Current Purchase Book (Reclaimed) VAT Base.
						F32->F32_WOFFVL := 0	// Current Write-Off VAT Value.
						F32->F32_WOFFBS := 0	// Current Write-Off VAT Base.
						F32->F32_RESTBS := FWFldGet("F53_RESTBS")
						F32->F32_RESTVL := FWFldGet("F53_RESTVL")
						F32->F32_INIBS := FWFldGet("F53_RESTBS")	// Initial Balance Base at this date.
						F32->F32_INIBAL := FWFldGet("F53_RESTVL")	// Initial Balance Value at this date.
					EndIf
					MsUnlock("F32")
				EndIf
			EndIf
		Next nLine
	EndIf
	End Transaction
EndIf

CloseTempTable(cTab)
CloseTempTable(cTabDel)
Return(lRet)
// The end of Function RU09D05Edt



/*/{Protheus.doc} RU09D05Del
Creates a procedure to delete Balances of Purchases VAT Invoices values.
Function should be used in the moment, when object Model is commited, but still exists.
@author Artem Kostin
@since 01/22/2017
@version P12.1.20
@type function
/*/
Function RU09D05Del(oModel as Object)
Local lRet := .T.

Local cModelId as Character

Local cSeek as Character

// Checks, if routine get an argument of object type and if routine has an object to extract data.
If ValType(oModel) != "O"
	lRet := .F.
	Help("",1,"RU09D05Del01",,STR0910,1,0)
EndIf

If lRet
	cModelId := oModel:GetId()	
	If (cModelId != "RU09T03") // Caller is unknown.
		lRet := .F.
		Help("",1,"RU09D05Del02",,STR0926,1,0)
	EndIf
EndIf

If lRet
	// Changing the working area to F32 VAT Purchases Balances table.
	dbSelectArea("F32")
	F32->(dbSetOrder(1))

	cSeek := oModel:getModel("F37master"):getValue("F37_KEY")
	F32->(DBGoTop())
	Begin Transaction
	While !Empty(cSeek) .and. F32->(dbSeek(xFilial("F32") + cSeek))
		RecLock("F32", .F.)
			F32->(DbDelete())
		MsUnlock("F32")
	EndDo
	End Transaction
EndIf

Return(.T.)
// The end of Function RU09D05Del


/*/{Protheus.doc} getTempTable
Function gets alias of the temporary table and fills this table with the data from the query.
@author Artem Kostin
@since 03/12/2017
@version P12.1.20
@type function
/*/
Static Function getTempTable(oModel as Object, cTab as Character, cTabDel as Character)
Local lRet := .T.

Local cQuery := ""
Local cQueryDel := ""
Local cQforModel := ""
Local cQueryOrder	as Character
Local cModelId := ""

Default cTab := ""
Default cTabDel := ""

cQueryOrder	:= " ORDER BY 1, 2, 3"

If lRet
	cModelId := oModel:GetId()

	// If routine is called from Purchases VAT Invoices.
	If (cModelId == "RU09T03")
		cQuery := " SELECT"
		// Order matters.
		cQuery += " T0.F37_FILIAL	AS FILIAL,"
		cQuery += " T0.F37_KEY		AS VAT_KEY,"
		cQuery += " T1.F38_VATCOD	AS INTCODE,"
		cQuery += " T0.F37_DOC AS DOC_NUM,"
		cQuery += " T0.F37_RDATE AS REAL_DATE,"
		cQuery += " T0.F37_PDATE AS PRINT_DATE,"
		cQuery += " T0.F37_FORNEC AS SUPPLIER,"
		cQuery += " T0.F37_BRANCH AS SUPP_BRANCH,"
		cQuery += " T1.F38_VATCD2 AS EXTCODE,"
		cQuery += " T1.F38_VATRT AS VAT_RATE,"
		cQuery += " SUM(T1.F38_VATBS1) AS INIT_BASE,"
		cQuery += " SUM(T1.F38_VATVL1) AS INIT_BALANCE"
		cQuery += " FROM " + RetSQLName("F37") + " AS T0"
		cQuery += " INNER JOIN " + RetSQLName("F38") + " AS T1"
		cQuery += " ON ("
		cQuery += " T1.F38_FILIAL = '" + xFilial("F38") + "'"
		cQuery += " AND T1.F38_KEY = T0.F37_KEY"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " WHERE T0.F37_FILIAL = '" + xFilial("F37") + "'"
		cQuery += " AND T0.F37_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY T0.F37_FILIAL"
		cQuery += " ,T0.F37_FORNEC"
		cQuery += " ,T0.F37_BRANCH"
		cQuery += " ,T0.F37_DOC"
		cQuery += " ,T0.F37_RDATE"
		cQuery += " ,T0.F37_KEY"
		cQuery += " ,T0.F37_PDATE"
		cQuery += " ,T1.F38_VATCOD"
		cQuery += " ,T1.F38_VATCD2"
		cQuery += " ,T1.F38_VATRT"	
		cTab := MPSysOpenQuery(ChangeQuery(cQuery + cQueryOrder))

		cQforModel += " AND T0.F32_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
		
		cQueryDel := " SELECT"
		// Order matters.
		cQueryDel += " T0.F32_FILIAL	AS FILIAL,"
		cQueryDel += " T0.F32_KEY		AS VAT_KEY,"
		cQueryDel += " T0.F32_VATCOD	AS INTCODE,"
		cQueryDel += " T0.F32_VATRT AS VAT_RATE,"
		cQueryDel += " T0.F32_BOOKBS AS RECLAIM_BASE,"
		cQueryDel += " T0.F32_BOOKVL AS RECLAIM_VALUE"
		cQueryDel += " FROM " + RetSQLName("F32") + " AS T0"
		cQueryDel += " LEFT JOIN ("
		cQueryDel += cQuery
		cQueryDel += ") AS NEW_BALANCE"
		cQueryDel += " ON ("
		cQueryDel += " NEW_BALANCE.FILIAL = '" + XFILIAL("F32") + "'"
		cQueryDel += " AND NEW_BALANCE.VAT_KEY = T0.F32_KEY"
		cQueryDel += " AND NEW_BALANCE.INTCODE = T0.F32_VATCOD"
		cQueryDel += ")"
		cQueryDel += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "'"
		cQueryDel += cQforModel // Specific coniditions for every model
		cQueryDel += " AND T0.D_E_L_E_T_ = ' '"
		cQueryDel += " AND NEW_BALANCE.FILIAL IS NULL"
		cQueryDel += " AND NEW_BALANCE.VAT_KEY IS NULL"
		cQueryDel += " AND NEW_BALANCE.INTCODE IS NULL"

		cTabDel := MPSysOpenQuery(ChangeQuery(cQueryDel + cQueryOrder))
	EndIf
EndIf

Return(lRet)
// The end of the Static Function getTempTable(oModel, cTab, cTabDel)
