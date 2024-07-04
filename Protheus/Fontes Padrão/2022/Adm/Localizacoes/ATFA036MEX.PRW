#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GenNF

Funcion utilizada para generar Factura de Venta con rutina automatica.

@return		ARRAY aNotas - aNotas[1][13] Numero de Documento generado.
@author 	marco.rivera@totvs.com
@since 		02/07/2019
@version 	1.0

/*/
//-------------------------------------------------------------------
Function AF036GenNF(aNotas)

	Local aCab			:= {}
	Local aItem			:= {}
	Local aItems		:= {}
	Local aDataSeri		:= {}
	Local cFilSF2		:= xFilial("SF2")
	Local cFilSD2		:= xFilial("SD2")

	/*
	* aNotas[1][1] - Codigo base del Bien (N1_CBASE)
	* aNotas[1][2] - Serie Nota Fiscal (F2_SERIE)
	* aNotas[1][3] - Cliente (F2_CLIENTE)
	* aNotas[1][4] - Tienda (F2_LOJA)
	* aNotas[1][5] - Condicion de Pago (F2_COND)
	* aNotas[1][6] - Campos requeridos para Transmición o Timbrado MEX-(F2_USOCFDI)/PER-(F2_TPDOC/F2_TIPONF)/COL-(F2_CODMUN/F2_TPACTIV/F2_TRMPAC/F2_TIPOPE)
	* aNotas[1][7] - Fecha Baja (F2_EMISSAO)
	* aNotas[1][8] - Item de del Activo (N1_ITEM)
	* aNotas[1][9] - Producto (N1_PRODUTO)
	* aNotas[1][10] - Cantidad bajada
	* aNotas[1][11] - Valor de Nota Fiscal
	* aNotas[1][12] - TES Salida
	* aNotas[1][13] - Reservado para Folio de NF generada
	*/
	If cPaisLoc != "EQU"
		cNumDoc		:= ATF036NumD(aNotas[1][2]) //Se obtiene el numero de documento.
		aDataSeri	:= ATF036Cert(aNotas[1][2]) //Se obtiene el certificado y Folio Aprovado para NF

		//Encabezado
		aAdd(aCab, {"F2_FILIAL"		, cFilSF2			, Nil})
		aAdd(aCab, {"F2_ESPECIE"	, "NF"				, Nil})
		aAdd(aCab, {"F2_TIPO"		, "N"				, Nil})
		aAdd(aCab, {"F2_FORMUL"		, "S"				, Nil})
		aAdd(aCab, {"F2_CLIENTE"	, aNotas[1][3]		, Nil})
		aAdd(aCab, {"F2_LOJA"		, aNotas[1][4]		, Nil})
		aAdd(aCab, {"F2_SERIE"		, aNotas[1][2]		, Nil})
		aAdd(aCab, {"F2_DOC"		, cNumDoc			, Nil})
		aAdd(aCab, {"F2_EMISSAO"	, aNotas[1][7]		, Nil})
		aAdd(aCab, {"F2_MOEDA"		, 1					, Nil})
		aAdd(aCab, {"F2_TXMOEDA"	, 1					, Nil})
		aAdd(aCab, {"F2_TIPODOC"	, "01"				, Nil})
		aAdd(aCab, {"F2_COND"		, aNotas[1][5]		, Nil})
		aAdd(aCab, {"F2_PREFIXO"	, aNotas[1][2]		, Nil})
		aAdd(aCab, {"F2_REFMOED"	, 1					, Nil})
		If cPaisLoc == "MEX"
			aAdd(aCab, {"F2_CERTFOL", aDataSeri[1][1]	, Nil})
			aAdd(aCab, {"F2_APROFOL", aDataSeri[1][2]	, Nil})
			aAdd(aCab, {"F2_USOCFDI", aNotas[1][6][1]	, Nil})
		EndIf
		If cPaisLoc == "PER"
			aAdd(aCab, {"F2_SERIE2"	, aDataSeri[1][1]	, Nil})
			If lExisCpo
				aAdd(aCab, {"F2_TPDOC"	, aNotas[1][6][1]	, Nil})
				aAdd(aCab, {"F2_TIPONF", aNotas[1][6][2]	, Nil})
			EndIF
		EndIf
		If cPaisLoc == "COL"
			aAdd(aCab, {"F2_SERIE2"	, aDataSeri[1][1]	, Nil})
			If lExisCpo
				aAdd(aCab, {"F2_CODMUN"	, aNotas[1][6][1]	, Nil})
				aAdd(aCab, {"F2_TPACTIV", aNotas[1][6][2]	, Nil})
				aAdd(aCab, {"F2_TRMPAC"	, aNotas[1][6][3]	, Nil})
				aAdd(aCab, {"F2_TIPOPE"	, aNotas[1][6][4]	, Nil})
			EndIF
		EndIf
		If !Empty(aNotas[1][14])
			aAdd(aCab, {"F2_NATUREZ", aNotas[1][14]		, Nil})
		EndIf
		//Item 01
		aAdd(aItem, {"D2_FILIAL"	, cFilSD2						, Nil})
		aAdd(aItem, {"D2_ITEM"		, "01"							, Nil})
		aAdd(aItem, {"D2_COD"		, aNotas[1][9]					, Nil})
		aAdd(aItem, {"D2_QUANT"		, aNotas[1][10]					, Nil})
		aAdd(aItem, {"D2_PRCVEN"	, aNotas[1][11]/aNotas[1][10]	, Nil})
		aAdd(aItem, {"D2_TOTAL"		, aNotas[1][11]					, Nil})
		aAdd(aItem, {"D2_TES"		, aNotas[1][12]					, Nil})

		aAdd(aItems, aItem)

		If Len(aCab) > 0 .And. Len(aItems) > 0
			lMSErroAuto := .F.
			MSExecAuto({|x,y,z| MATA467N(x,y,z)}, aCab, aItems, 3)
			If lMSErroAuto //Si hubo error durante la grabacion
				MostraErro()
			Else
				aNotas[1][13] := nNumDocNF //Se almacena Numero de Documento generado.
			EndIf
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036Cert

Funcion utilizada para obtener el certificado de la serie utilizada,
para la Factura de Venta.

@param   String cCodSer - Codigo de la Serie.
@return  Array aDataSer - aDataSer[1] Certificado / aDataSer[2] Folio Aprovado.
@author marco.rivera@totvs.com
@since 02/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ATF036Cert(cCodSer)

	Local aArea		:= GetArea()
	Local cFilSFP	:= xFilial("SFP")
	Local aDataSer	:= {}

	Default cCodSer	:= ""

	DBSelectArea("SFP")
	SFP->(DBSetOrder(5)) //FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV
	If SFP->(MsSeek(cFilSFP+cFilAnt+cCodSer+"1"))
		If cPaisLoc == "MEX"
			aAdd(aDataSer, {SFP->FP_NRCERT, SFP->FP_CAI})
		Else
			aAdd(aDataSer, {SFP->FP_SERIE2})
		EndIf
	EndIf

	RestArea(aArea)

Return aDataSer

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036NumD

Funcion utilizada para obtener el Folio de acuerdo a tabla 01 - de SX5.

@param   String cSerie - Codigo de la Serie.
@return  String cNumDoc - Numero de Documento.
@author marco.rivera@totvs.com
@since 02/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ATF036NumD(cSerie)

	Local aArea			:= GetArea()
	Local aSeries		:= {}
	Local nDoc			:= 0
	Local nI			:= 0
	Local nTamNumDoc	:= TamSX3("F2_DOC")[1]
	Local cNumDoc		:= ""

	aSeries  := FWGetSX5("01")

	For nI := 1 To Len(aSeries)
		If AllTrim(aSeries[nI][3]) == AllTrim(cSerie)
			nDoc := Val(aSeries[nI][4])
		EndIf
	Next nI

	cNumDoc := StrZero(nDoc, nTamNumDoc)

	RestArea(aArea)

Return cNumDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036ValC

Funcion utilizada para validar la existencia de los campos en la FN6

@param
@return  Boolean lRet - Existencia de campos
@author Verónica Flores
@since 06/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Function ATF036ValC()

Local lRet:= .F.

If cPaisLoc == "PER" .And. FN6->(ColumnPos("FN6_TPDOC")) > 0 .And. FN6->(ColumnPos("FN6_TIPONF")) > 0
	lRet := .T.
EndIf

If cPaisLoc == "COL" .And. FN6->(ColumnPos("FN6_CODMUN")) > 0 .And. FN6->(ColumnPos("FN6_TPACTI")) > 0 .And. FN6->(ColumnPos("FN6_TRMPAC")) > 0 .And. FN6->(ColumnPos("FN6_TIPOPE")) > 0
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} ATF036Cte
	Lee datos de cliente; municipio y actividad
	@type    Function
	@author  ARodriguez
	@since   26/08/2022
	@version 1.0
	@param   oModelFN6, object, modelo MVC FN6
	@return  nil
	/*/
Function ATF036Cte(oModelFN6)
	If !Empty(oModelFN6:GetValue("FN6_CLIENT")) .And. !Empty(oModelFN6:GetValue("FN6_LOJA"))
		SA1->(dbSetOrder(1))	//A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(MsSeek(xFilial("SA1") + oModelFN6:GetValue("FN6_CLIENT") + oModelFN6:GetValue("FN6_LOJA")))
			oModelFN6:LoadValue("FN6_CODMUN",SA1->A1_COD_MUN)
			oModelFN6:LoadValue("FN6_TPACTI",SA1->A1_ATIVIDA)
		EndIf
	Endif
Return Nil
