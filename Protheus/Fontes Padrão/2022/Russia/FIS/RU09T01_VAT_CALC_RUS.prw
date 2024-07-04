#Include "Protheus.ch"

/*/{Protheus.doc} RU09T01I
Function that returns VAT rate, base or value. This function must be called in Variable Taxes (MATA995) by filling the field "Inf. Formula" (FB_FORMENT).
@author felipe.morais
@since 16/05/2017
@version P12.1.16
@param cCalculo, characters, Needs to receive "A" to return rate, "B" to base and "V" to value.
@param nItem, numeric, Number of the line in the Purchase Order or Inflow Invoice.
@param aInfo, array, Array that contains at first position the number of the tax and at second position the tax code.
@type function
/*/
Function RU09T01I(cCalculo as Character, nItem as Numeric, aInfo as Array)
Local xRet := 0
Local nBase := 0
Local nTotal := 0
Local nVATValue := 0
Local nAliq := 0

Local aArea := GetArea()
Local aAreaSFC := SFC->(GetArea())

DbSelectArea("SFC")
SFC->(DbSetOrder(2))

// 1=Sum;
// 2=Subtract;
// 3=Indifferent

// Fuction is asked to return VAT Rate.
If (cCalculo == "A")
	// Returns VAT Rate by the seeking current Fiscal Code (IT_CF) in tables F31 and F30
	xRet := RU09GetRate(MaFisRet(nItem, "IT_CF"))[1]

// Fuction is asked to return VAT Base.
Elseif (cCalculo == "B")
	// Gets the total sum of the current item
	nBase := MaFisRet(nItem, "IT_VALMERC")
	// Seeks and apllies discount to the total sum to get the VAT Base
	If (SFC->(DbSeek(xFilial("SFC") + MaFisRet(nItem, "IT_TES") + aInfo[1])))
		If (SFC->FC_LIQUIDO == "S")
			nBase -= MaFisRet(nItem, "IT_DESCONTO")
		EndIf
		// VAT value included in total means that this values shouldn't be sum to the gross value.
		If (SFC->FC_INCNOTA == "3")
			nAliq := RU09GetRate(MaFisRet(nItem, "IT_CF"))[1]
			// Calcs the Base in the case, when Base doesn't equal total.
			If nAliq != Nil
				nVATValue := nBase / (100 + nAliq) * nAliq
				nBase := nBase - Round(nVATValue,2) 
			EndIf
		EndIf
	EndIf
	xRet := Round(nBase, 2)

// Fuction is asked to return VAT Value
Elseif (cCalculo == "V")
	// Gets the total sum of the current item
	nTotal := MaFisRet(nItem, "IT_VALMERC")
	nAliq := RU09GetRate(MaFisRet(nItem, "IT_CF"))[1]
	// Multiplication of VAT Rate and VAT Total equals VAT Value.
	// VAT Rate formula is different for different TIO codes.
	// Seeks and apllies discount to the total sum to get the VAT Base
	If (SFC->(DbSeek(xFilial("SFC") + MaFisRet(nItem, "IT_TES") + aInfo[1]))) .And. nAliq != Nil
		If (SFC->FC_INCNOTA == "3")
			// Calcs the VAT Value in the case, when Base doesn't equal total.
			nVATValue := nTotal / (100 + nAliq) * nAliq
		Else
			nVATValue := nTotal * nAliq / 100
		EndIf
	EndIf
	xRet := Round(nVATValue, 2)
EndIf

RestArea(aAreaSFC)
RestArea(aArea)
Return(xRet)



/*/{Protheus.doc} RU09T01I
Function that returns the VAT Rate according to the VAT Code.
@author felipe.morais
@since 16/05/2017
@version P12.1.16
@param cCFO, characters, VAT Code.
@type function
/*/
Function RU09GetRate(cCFO as Character)
Local aRet := { Nil, 100 }
Local aArea := GetArea()
Local aAreaF30 := F30->(GetArea())
Local aAreaF31 := F31->(GetArea())
Local aImposto as Array

DbSelectArea("F31")
F31->(DbSetOrder(1))
If (F31->(DbSeek(xFilial("F31") + AllTrim(cCFO))))
	DbSelectArea("F30")
	F30->(DbSetOrder(1))
	// Trying to find VAT Rate.
	If (F30->(DbSeek(xFilial("F30") + F31->F31_RATE)))
		// Needs to check if it is a formula or a rate.
		If ("/" $ F30->F30_RATE)
			aImposto := StrTokArr(F30->F30_RATE, "/")
			aRet := {Val(aImposto[1]), Val(aImposto[2])}
		Else
			aRet := {Val(F30->F30_RATE), 100}
		EndIf
	EndIf
EndIf
RestArea(aAreaF31)
RestArea(aAreaF30)
RestArea(aArea)
Return(aRet)

/*/{Protheus.doc} RU09T01O
Function that returns VAT rate, base or value. This function must be called in Variable Taxes (MATA995) by filling the field "Outf. Formula" (FB_FORMSAI).
@author felipe.morais
@since 16/05/2017
@version P12.1.16
@param cCalculo, characters, Needs to receive "A" to return rate, "B" to base and "V" to value.
@param nItem, numeric, Number of the line in the Purchase Order or Inflow Invoice.
@param aInfo, array, Array that contains at first position the number of the tax and at second position the tax code.
@type function
/*/

Function RU09T01O(cCalculo as Character, nItem as Numeric, aInfo as Array, lFromComInv as Logical, lIncrease as Logical)
Local xRet := 0
Local nBase := 0
Local nDesconto := 0
Local nVATValue := 0
Local nAliq := 0
Local cSeekSFC := ""
Local cSubModel := ""

Local oModel as Object

Local aArea := GetArea()
Local aAreaSFC := SFC->(GetArea())

Default lFromComInv := .T.
Default lIncrease := Nil

DbSelectArea("SFC")
SFC->(DbSetOrder(2))

// Needs to check if it is called by Sales Order or Outflow Document.
// If ValType returns "U" it means that is called by Outflow Document.
If (ValType(cCalculo) == "U")
	MaFisSave() // Saves the actual status. Created by MATXFIS.
	MaFisEnd() // Clears all references of tax calculation. Created by MATXFIS.
	// Starts the header of tax calculation. Created by MATXFIS.
	MaFisIni(SC5->C5_CLIENTE,; // Customer Code
	SC5->C5_LOJAENT,; // Customer´s Branch Code
	"C",;
	SC5->C5_TIPO,; // Sales Order Type
	SC5->C5_TIPOCLI,; // Customer Type
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	"MATA461",; // Source Code Name
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	{"", ""},,,SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,(SC6->C6_QTDVEN*SC6->C6_PRCVEN),,SC5->C5_TPFRETE)
	// Alters values or base of item. Created by MATXFIS.
	MaFisAlt('NF_MOEDA',M->C5_MOEDA)
	// Starts the items of tax calculation. Created by MATXFIS.
	MaFisAdd(SC6->C6_PRODUTO,; // Product Code
				SC6->C6_TES,; // Inflow Type
				SC6->C6_QTDVEN,; // Quantity
				SC6->C6_PRCVEN,; // Price
				SC6->C6_DESCONT,; // Discount
				"",;
				"",;
				0,;
				0,;
				0,;
				0,;
				0,;
				(SC6->C6_QTDVEN*SC6->C6_PRCVEN),; // Total
				0,;	
				Nil,;
				Nil,;
				SC6->C6_ITEM,; // Item
				0,;
				0,;
				SC6->C6_CF,; // Tax Operation
				{},;	
				"",;
				0,;
				"",;
				"",;
				Nil,;
				Nil,;
				"")
	// Writes the values after started the process of tax calculation. Created by MATXFIS.
    MaFisWrite(1)
	// Receives all tax calculation by parameter and redo tax calculation.
	xRet := ParamIXB[2]
	// Returns VAT Rate by the seeking current Fiscal Code (IT_CF) in tables F31 and F30
	// If fiscal code is found and VAT rate is parsed and returned as result.
	nAliq := RU09GetRate(MaFisRet(nItem, "IT_CF"))[1]
	xRet[2] := nAliq
	// Gets the total sum of the current item.
	nBase := MaFisRet(1, "IT_VALMERC")
	// Seeks and apllies discount to the total sum to get the VAT Base
	If (SFC->(DbSeek(xFilial("SFC") + MaFisRet(1, "IT_TES")))) .And. nAliq <> Nil
		If (SFC->FC_LIQUIDO == "S")
			nBase -= MaFisRet(nItem, "IT_DESCONTO")
		EndIf
		// VAT value included in total means that this values shouldn't be sum to the gross value.
		If (SFC->FC_INCNOTA == "3")
			// Calcs the VAT Value in the case, when Base doesn't equal total.
			nVATValue := nBase / (100 + nAliq) * nAliq
			// Calcs the Base in the case, when Base doesn't equal total.
			nBase -= nVATValue
		Else
			nVATValue := nBase * nAliq / 100
		EndIf
	EndIf
	xRet[3] := Round(nBase, 2)
	xRet[4] := Round(nVATValue, 2)
	MaFisEnd() // Clears all references of tax calculation. Created by MATXFIS.
Else
	If (lFromComInv)
		// Gets the total sum of the current item
		nBase := MaFisRet(nItem, "IT_VALMERC")
		nDesconto := MaFisRet(nItem, "IT_DESCONTO")
		// Returns VAT Rate by the seeking current Fiscal Code (IT_CF) in tables F31 and F30
		// If fiscal code is found and VAT rate is parsed and returned as result.
		nAliq := RU09GetRate(MaFisRet(nItem, "IT_CF"))[1]
		cSeekSFC := MaFisRet(nItem, "IT_TES") + aInfo[1]
	Else
		oModel := FwModelActive()
		If (ValType(oModel) == 'O' .and. oModel:GetId() == "RU05D01")
			If lIncrease <> Nil
				cSubModel := Iif( lIncrease, "SD2DETAIL_INCREASE", "SD2DETAIL_DECREASE")
			EndIf
			nBase := Iif( lIncrease <> Nil ,oModel:GetModel(cSubModel):GetValue("D2_TOTAL"),FwFldGet("F5Z_TOTAL"))
			nDesconto := 0
			nAliq := RU09GetRate(Iif(lIncrease <> Nil,oModel:GetModel(cSubModel):GetValue("D2_CF"),FwFldGet("F5Z_VATCOD")))[1]
			cSeekSFC := Iif(lIncrease <> Nil,oModel:GetModel(cSubModel):GetValue("D2_TES"),FwFldGet("F5Z_TES")) + aInfo[1]
		EndIf
	EndIf
	// Seeks and apllies discount to the total sum to get the VAT Base
	If (SFC->(DbSeek(xFilial("SFC") + cSeekSFC))) .And. nAliq != Nil
		If (SFC->FC_LIQUIDO == "S")
			nBase -= nDesconto
		EndIf
		// Multiplication of VAT Rate and VAT Total equals VAT Value.
		// VAT Rate formula is different for different TIO codes.
		If (SFC->FC_INCNOTA == "3")
			// Calcs the VAT Value in the case, when Base doesn't equal total.
			nVATValue := nBase / (100 + nAliq) * nAliq
			// VAT value included in total means that this values shouldn't be sum to the gross value.
			// Calcs the Base in the case, when Base doesn't equal total.
			nBase := nBase-Round(nVATValue,2)
		Else
			nVATValue := nBase * nAliq / 100
		EndIf
	EndIf
	// If ValType returns "C" it means that is called by Sales Order.
	If (cCalculo == "A")
		xRet  := nAliq
	// Fuction is asked to return VAT Base.
	Elseif (cCalculo == "B")
		xRet := Round(nBase, 2)
	// Fuction is asked to return VAT Value
	Elseif (cCalculo == "V")
		xRet := Round(nVATValue, 2)
	EndIf
EndIf

RestArea(aAreaSFC)
RestArea(aArea)
Return(xRet)
//merge branch 12.1.19
// Russia_R5
