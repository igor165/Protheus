#include 'protheus.ch'
#include 'FATXFUMI.ch'

/*/{Protheus.doc} FATXMIDsIt
Función para tratamineto de descuentos por ítem de Pedidos de Venta (Mercado Internacional)
@type
@author luis.enriquez
@since 04/03/2020
@version 1.0
@param nPrUnit, numeric, Precio Unitario del ítem
@param nPrcVen, numeric, Precio de Venta del ítem
@param nQtdVen, numeric, Cantidad del ítem
@param nTotal, numeric, Valor total del ítem
@param nPerc, numeric, Porcentaje de descuento del ítem
@param nDesc, numeric, Importe de descuento del ítem
@param nDescOri, numeric, Importe de descuento original del ítem
@param nTipo, numeric, Tipo de descuento del ítem (1-Porcentaje, 2-Valor descuento)
@param nQtdAnt, numeric, Cantidad anterior del ítem
@param nMoeda, numeric, Moneda del ítem
@return nPreco, numeric, Precio del ítem con descuento
@example
LXMexAcc(@aRotina)
@see (links_or_references)
/*/
Function FATXMIDsIt(nPrUnit,nPrcVen,nQtdVen,nTotal,nPerc,nDesc,nDescOri,nTipo,nQtdAnt,nMoeda)
	Local nPreco 		:= 0
	Local nValTot		:= 0

	Default nMoeda		:= Nil
	Default nTipo		:= 1
	Default nQtdAnt		:= nQtdVen

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo o Preco de Lista quando nao houver tabela de preco    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPrUnit == 0
		nPrUnit += a410Arred((nTotal + nDescOri) / nQtdAnt,"D2_PRCVEN")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o novo preco de Venda                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 1
		nPreco := A410Arred(nPrUnit * (1-(nPerc/100)),"D2_PRCVEN")
		If nPerc > 0 .and. cPAisLoc == "ARG"
			nTotal := nPreco * nQtdVen
		ELSE
			nTotal := A410Arred((nPrUnit * nQtdVen) * (1-(nPerc/100)),"D2_TOTAL")
		EndIf
	Else
		If nDesc > 0 .And. (IsInCallStack('CN120GrvPed') .Or. IsInCallStack('CN121GerDoc'))
			nPreco := (nTotal - nDesc) / nQtdVen
		Else
			nPreco := A410Arred(nPrUnit-(nDesc/nQtdVen),"D2_PRCVEN",nMoeda)
			If  cPAisLoc == "ARG" .And.  (nDesc > 0 .and.  nPreco > 0 .and.  nQtdVen > 0)
				nTotal := nPreco * nQtdVen
			ELSE
				nTotal := A410Arred((nPrUnit * nQtdVen) - nDesc,"D2_TOTAL")
			Endif
		EndIf
	EndIf

	nValTot:= A410Arred(nPrUnit * nQtdVen,"D2_TOTAL",nMoeda)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo dos descontos                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nPrUnit == 0
		nDesc := 0
		nPerc := 0
	Else
		nDesc := A410Arred(nValTot-nTotal,"D2_DESCON")
		If nTipo <> 1
			nPerc := A410Arred((1-(nPreco/nPrUnit))*100,"C6_DESCONT")
		EndIf
	EndIf
Return(nPreco)

/*/{Protheus.doc} FxMIVldItS
Valida que el item seleccionado pertenezca a un documento transmitido en la
rutina MATA465N para NCC - Colombia/Bolivia.
@author Marco Augusto Gonzalez Rivera
@since 25/04/2019
@version 1.0
@param cNumDoc, caracter, (Folio del documento)
@param cSerie,	caracter, (Serie del documento)
@return lRet, Verdadero si el documento se entra transmitido.
/*/
Function FxMIVldItS(cNumDoc, cSerie)
	Local lRet		:= .T.
	Local lM465PE  := .T.
	Local cFunName	:= FunName()
	Local aArea		:= {}
	Local lFactElec	:= !Empty(GetMV("MV_PROVFE", .F., "")) //Facturacion Electronica Activa
	Local cTpDoc := ""
	Local cVldD  := ""
	Local lValFE := .T.
	Local lCFDUso  := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0", .T.,.F.)

	Default cNumDoc	:= ""
	Default cSerie	:= ""

	If ExistBlock("M465DORIFE")
		lM465PE := ExecBlock("M465DORIFE",.F.,.F.,{xFilial("SF2"),cNumDoc,cSerie,M->F1_FORNECE,M->F1_LOJA})
	EndIf

	If lM465PE
		IF cPaisLoc=="COL"
			cTpDoc := AllTrim(ObtColSAT("S017",Alltrim(M->F1_TIPOPE),1,4,85,3))
			cVldD  := AllTrim(ObtColSAT("S017",Alltrim(M->F1_TIPOPE),1,4,88,1))
			lValFE := IIf((cTpDoc == "NCC" .And. cVldD $ "1|2") .Or. !(cTpDoc $ "NF|NDC|NCC") .Or. !(cVldD $ "0|1|2"),.T.,.F.)
			If cFunName $ "MATA465N" .And. lFactElec .And. lValFE
				aArea := GetArea()
				dbSelectArea("SF2")
				SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				//Regla de negocio
				If SF2->(MsSeek(xFilial("SF2") + cNumDoc + cSerie))
					If (Empty(SF2->F2_FLFTEX) .Or. SF2->F2_FLFTEX == "0") .Or. Empty(SF2->F2_UUID)
						MsgAlert(StrTran(STR0001, '###', AllTrim(SF2->F2_SERIE) + " " +  AllTrim(SF2->F2_DOC))) //"El documento seleccionado (###), no ha sido transmitido. Realice la transmisión e intente nuevamente."
						lRet := .F.
					EndIf
					If lRet .And. cVldD == "2" .And. Len(Alltrim(SF2->F2_UUID)) <> 40
						MsgAlert(StrTran(STR0002, '###', AllTrim(SF2->F2_SERIE) + " " +  AllTrim(SF2->F2_DOC))) //"El UUID del documento seleccionado (###), no pertenece a un documento emitido con el modelo de validación posterior."
						lRet := .F.
					EndIf
				EndIf
				RestArea(aArea)
			EndIf
			EndIf
		EndIf
Return lRet

/*/{Protheus.doc} LxActCpos
Función para habilitar los campos en el Pedido de Venta.
@type
@author veronica.flores
@since 15/04/2021
@version 1.0
@param aPedCpo, array , Array con los campos que se habilitaran.
@see (links_or_references)
/*/
Function LxActCpos(aPedCpo)

	Local aArea		:= GetArea()

	DbSelectArea("SC5")
	If SC5->(ColumnPos( "C5_CODMUN" ))  > 0
		AAdd(aPedCpo[1],"C5_CODMUN")
	EndIf
	If SC5->(ColumnPos( "C5_TPACTIV" )) > 0
		AAdd(aPedCpo[1],"C5_TPACTIV")
	EndIf
	IF SC5->(ColumnPos( "C5_TRMPAC" ))  > 0
		AAdd(aPedCpo[1],"C5_TRMPAC")
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} FatxVUni
Función que actualiza el valor del descuento apartir del valor unitario modificado
@type
@author veronica.flores
@since 31/05/2021
@version 1.0
@param
@see (links_or_references)
/*/
Function FatxVUni()
	Local nValCant	:= 0
	Local nValUni	:= 0
	Local cDescsai	:= SuperGetMV("MV_DESCSAI",.F.)
	Local nPosTotal := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosDesc  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_VALDESC"})
	Local nPosCant  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_QUANT"})
	Local nPosPDes  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_DESC"})
	Local cFunName	:= AllTrim(FunName())

	If cFunName $ "MATA465N" .And. acols[n][nPosDesc] > 0 .And. acols[n][nPosTotal] > 0 .And. cDescsai == "1"
		nValCant := aCols[n][nPosCant]
		nValUni	 := acols[n][nPosTotal] / nValCant
		If nValUni <> M->D1_VUNIT
			ACOLS[n][nPosTotal] := M->D1_VUNIT * nValCant
			ACOLS[n][nPosPDes]  := 0
			ACOLS[n][nPosDesc]  := 0
			MaFisAlt("IT_DESCONTO",ACOLS[n][nPosDesc],n)
			MaFisAlt("IT_PRCUNI",M->D1_VUNIT,n)
			MaFisAlt("IT_VALMERC", aCols[n][nPosTotal], n)
		EndIF

	EndIf
Return .T.

/*/{Protheus.doc} FxDesc
Función que calcula y actualiza el valor del descuento apartir del porcentaje modificado
@type
@author veronica.flores
@since 31/05/2021
@version 1.0
@param
@return  aCols[n][nPosDesc] - Valor del Descuento
@see (links_or_references)
/*/
Function FxDesc()
	Local nDescAc	:= 0
	Local cDescsai	:= SuperGetMV("MV_DESCSAI")
	Local nPosTotal := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosDesc  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_VALDESC"})
	Local nTotal 	:= 0
	Local cFunName	:= AllTrim(FunName())

	nTotal	:= acols[n][nPosTotal]
	nDescAc	:= acols[n][nPosDesc]

	If cFunName $ "MATA465N" .And. nDescAc > 0 .And. nTotal > 0 .And. cDescsai == "1"
		If nDescAc <> M->D1_DESC
			aCols[n][nPosDesc] := NoRound((nDescAc + nTotal)* (M->D1_DESC/100),TamSx3("D1_VALDESC")[2])
		EndIF
	Else
		aCols[n][nPosDesc] := NoRound(nTotal*M->D1_DESC/100,TamSx3("D1_VALDESC")[2])
	EndIf
Return aCols[n][nPosDesc]

/*/{Protheus.doc} FatPorDesc
Función que calcula y actualiza el porcentaje del descuento
@type
@author veronica.flores
@since 31/05/2021
@version 1.0
@param
@return  aCols[n][nPosPDes] - Porcentaje del Descuento
@see (links_or_references)
/*/
Function FatPorDesc()
	Local cDescsai	:= SuperGetMV("MV_DESCSAI",.F.)
	Local nPosTotal := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosDesc  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_VALDESC"})
	Local nPosPDes  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_DESC"})
	Local cFunName	:= AllTrim(FunName())

	If cFunName $ "MATA465N" .And. acols[n][nPosDesc] > 0  .And. cDescsai == "1"
		aCols[n][nPosPDes]  := Round((aCols[n][nPosDesc]*100)/(aCols[n][nPosTotal] + aCols[n][nPosDesc]),TamSx3("D1_DESC")[2])
	Else
		aCols[n][nPosPDes]  := 0
	EndIf
Return aCols[n][nPosPDes]

/*/{Protheus.doc} FxValStock
Función para validar stock al generar docto desde MATA410.

@type function
@author oscar.lopez
@since 28/06/2021
@version 1.0
@param cAlias, char, Alias de la tabla con la información del pedido de venta.
@param nReg, numeric, Numero de registro en la tabla cAlias del pedido de venta.
@return  lRet, logic, Regresa Falso si existen documentos que siperen saldo de stock.
/*/
Function FxValStock(cAlias,nReg)
	Local lRet		:= .T.
	Local aAreaSC5	:= {}
	Local aAreaSC6	:= {}
	Local aAreaSC9	:= {}
	Local aAreaSB2	:= {}
	Local aAreaSF4	:= {}
	Local cFilSC6	:= xFilial("SC6")
	Local cFilSC9	:= xFilial("SC9")
	Local cFilSB2	:= xFilial("SB2")
	Local cFilSF4	:= xFilial("SF4")
	Local lEstNeg	:= (SuperGetMV("MV_ESTNEG") == "S")
	Local cPedido	:= ""
	Local cProd		:= ""
	Local nCantidad	:= 0
	Local aLog		:= {} //ítems que dejarán stock negativo.
	Local aLogTitle	:= {}
	Local aReturn	:= {"", 1, "", 2, 2, 1, "",1 }
	Local cFunName	:= FunName()
	Local nLenProd	:= GetSX3Cache("C9_PRODUTO", "X3_TAMANHO") + 2
	Local nLenPed	:= GetSX3Cache("C9_PEDIDO", "X3_TAMANHO") + 4

	Default cAlias	:= ""
	Default nReg	:= 0

	If !lEstNeg .And. cPaisLoc $ "MEX" .And. IsInCallStack("MATA410") .And. !Empty(cAlias) .And. nReg > 0
		aAreaSC5 := SC5->(GetArea())
		aAreaSC6 := SC6->(GetArea())
		aAreaSC9 := SC9->(GetArea())
		aAreaSB2 := SB2->(GetArea())
		aAreaSF4 := SF4->(GetArea())

		SC5->(DbGoTo(nReg))
		cPedido := SC5->C5_NUM

		SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO

		DbSelectArea("SC9")
		SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED

		If SC9->(MsSeek(cFilSC9+cPedido))

			while !SC9->(EoF()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == (cFilSC9+cPedido)
				If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) //Solo procesa productos sin bloqueos.
					cProd := SC9->C9_PRODUTO
					cLocal := SC9->C9_LOCAL
					nCantidad := SC9->C9_QTDLIB
					If  SC6->(msSeek(cFilSC6+cPedido+SC9->C9_ITEM+cProd)) .And. ;
						SF4->(msSeek(cFilSF4+SC6->C6_TES)) .And. SF4->F4_ESTOQUE == "S" .And. ;
						SB2->(MsSeek(cFilSB2 + cProd + cLocal)) .And. ( SaldoSB2(,.F.,,,,,,,.F.) <  nCantidad )
						AAdd(aLog, {PadR(SC9->C9_PEDIDO, nLenPed) + PadR(SC9->C9_ITEM, 5) + PadR(cProd, nLenProd) + cLocal})
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo

		EndIf

		SC5->(RestArea(aAreaSC5))
		SC6->(RestArea(aAreaSC6))
		SC9->(RestArea(aAreaSC9))
		SB2->(RestArea(aAreaSB2))
		SF4->(RestArea(aAreaSF4))

		If Len(aLog) > 0
			lRet := .F.
			If isBlind()
				Conout(STR0004) //"Se identificaron productos que sobrepasan el límite de stock, no se permite dejar el saldo en stock Negativo. (MV_ESTNEG) \n ¿Desea visualizar el log?"
			ElseIf MsgYesNo(STR0004 + CRLF + STR0011, "MV_ESTNEG") //"Se identificaron productos que sobrepasan el límite de stock, no se permite dejar el saldo en stock Negativo. (MV_ESTNEG) \n ¿Desea visualizar el log?"
				AAdd(aLogTitle, Padr(STR0005, nLenPed) + STR0006 + PadR(STR0007, nLenProd) + STR0008) //"Pedido " ## "Ítem " ## "Producto " ## "Local"
				MsAguarde( { ||fMakeLog( aLog , aLogTitle , "", .T. , cFunName , STR0009 , , "P" , aReturn, .F. )}, STR0010) //"Impresión de Log" ## "Generando Log de proceso..."
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} fDesDocMI

@author Luis Arturo Samaniego
@since 20/08/2021
@param cTipoDoc, String, Valor de campo D1/D2_ESPECIE
@return cDesDoc, String, Tipo de documento
/*/
Function fDesDocMI(cTipoDoc)
Local cDesDoc    := ""
Default cTipoDoc := ""

	cDesDoc    := Alltrim(cTipoDoc)

	If cDesDoc == "NF"
		cDesDoc := "FAC"
	EndIf

Return cDesDoc
