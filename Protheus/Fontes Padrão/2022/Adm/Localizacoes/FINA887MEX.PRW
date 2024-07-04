#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887MEX.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887MEX
Fonte de cobros diversos (México)
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Function FINA887MEX()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/

Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel	:= FwLoadModel(SOURCEFATHER)
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local oStruSEL	:= oModelSEL:oFormModelStruct
Local oEvtTit	:= F887FINMEX():New()
Local oStruCOM	:= FWFormModelStruct():New()

	oStruCOM:AddTable('', { '' }, "COMPENSACIONES",{|| ''})
	oStruCOM:AddField('Recno'	,'Recno'	,'RECNO'	,'N' ,16,0)
	
	oStruSEL:SetProperty( 'EL_CTABEN'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'F887PatCta("EL_CTABEN",2)') )
	oStruSEL:SetProperty( 'EL_CTAORD'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'F887PatCta("EL_CTAORD",1)') )
	If SEL->(ColumnPos("EL_FORPGO")) > 0
		oStruSEL:SetProperty( 'EL_FORPGO'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .or. ValidF3I("S005",M->EL_FORPGO,1,2) .and. F887WHEN()') )
		oStruSEL:SetProperty( 'EL_FORPGO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	EndIf
	If SEL->(ColumnPos("EL_HRPAGO")) > 0
		oStruSEL:SetProperty( 'EL_HRPAGO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
		oStruSEL:SetProperty( 'EL_HRPAGO'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887ValHr() } )
	EndIf

	
	oStruSEL:SetProperty( 'EL_CEPCAD'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_CEPCAD") } ) //FN087AWH
	oStruSEL:SetProperty( 'EL_CEPCER'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_CEPCER") } ) //FN087AWH
	oStruSEL:SetProperty( 'EL_CEPSEL'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_CEPSEL") } ) //FN087AWH
	If SEL->(ColumnPos("EL_CEPTIP")) > 0
		oStruSEL:SetProperty( 'EL_CEPTIP'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_CEPTIP") } ) //FN087AWH
	EndIf
	oStruSEL:SetProperty( 'EL_CTABEN'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_CTABEN") } ) //FN087AWH
	oStruSEL:SetProperty( 'EL_CTAORD'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_CTAORD") } ) //FN087AWH
	oStruSEL:SetProperty( 'EL_RFCEMI'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887AWH("EL_RFCEMI") } ) //FN087AWH
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")

	oModel:addGrid('COM_DETAIL','FJT_MASTER',oStruCOM,,)

	oModel:GetModel('COM_DETAIL'):SetOptional(.T.)
	oModel:GetModel('COM_DETAIL'):SetOnlyQuery(.T.)

	oModel:InstallEvent("F887FINMEX", "F887FIN", oEvtTit)
	
Return oModel

/*/{Protheus.doc} F887PatCta
Función para validación de uso de tipo de documento
@param		cCta - Cta. a validar
			nTipo - Ordenante o beneficiaria
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		09/04/2027
/*/
Function F887PatCta(cCta, nTipo)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local aAux1			:= {{},{},{}}
Local aAux2			:= {}
Local nPosIniPat	:= 0
Local nPosFinPat	:= 0
Local cPatron		:= ""
Local cCar			:= ""
Local aTipo			:= {}
Local nPosIni		:= 1
Local nPosFin		:= 0
Local nPosIni2		:= 0
Local nPosFin2		:= 0
Local nX			:= 0
Local nY			:= 0
Local nLonCta		:= 0
Local lRet			:= .F.
Local lAux			:= .F.
Local cRet			:= ""
Local nNumAlf		:= 0
Local cCpoCta		:= IIf(nTipo == 1 , "EL_CTAORD", "EL_CTABEN")
Local cMPatron		:= OemToAnsi(STR0001) + " -> " + OemToAnsi(STR0002) + CRLF//" Caracteres "#" Tamaño "
Local cMensaje		:= ""
Local cFPago		:= ""

Default cCta		:= ""
Default nTipo		:= 0

	cCta 	:= oModelSEL:GetValue(cCta)
	cFPago	:= Iif(SEL->(ColumnPos("EL_FORPGO")) > 0, oModelSEL:GetValue("EL_FORPGO"), "")

	cMensaje	:= OemToAnsi(STR0003) + IIf(nTipo == 1, OemToAnsi(STR0004), OemToAnsi(STR0005)) //"Cuenta Ordenante"#"Cuenta Benficiario"
	nPosIniPat	:= IIf(nTipo == 1, 43, IIf(nTipo == 2, 98, 0))
	nPosFinPat	:= IIf(nTipo == 1, 97, IIf(nTipo == 2, 154, 0))
	cRet		:= AllTrim(cCta)
	cPatron		:= AllTrim(ObtColSAT("S005", cFPago, 1, 2, nPosIniPat, nPosFinPat - nPosIniPat))

	If Empty(cPatron) .Or. Empty(cRet)
		Return .T.
	EndIf

	While Len(cPatron) > 0 //Almacena las longitudes admitidas para los valores Numericos/Alfanumericos
		cCar := SubStr(cPatron,nPosIni,1)
		Do Case
			Case cCar == "["
				nPosIni		:= AT("[", cPatron) +1
				nPosFin		:= AT("]", cPatron) - nPosIni
				cMPatron	+= SubStr(cPatron, nPosIni, nPosFin)
				aTipo		:= {}
				aAux2		:= {}
				For nX := nPosIni to AT("]", cPatron)
					nPosIni2 := AT("{", cPatron) + 1
					nPosFin2 := AT("}", cPatron) - nPosIni2
					aAux2 := STRTOKARR(SubStr(cPatron, nPosIni2, nPosFin2),",")
					If IsDigit(SubStr(cPatron,nX,1)) .And. aScan(aTipo, 1) == 0
						aAdd(aAux1[1],STRTOKARR(SubStr(cPatron, nPosIni2, nPosFin2),","))
						aadd(aTipo,1)
					EndIf
					If IsAlpha(SubStr(cPatron,nX,1)) .And. aScan(aTipo, 2) == 0
						aAdd(aAux1[2],STRTOKARR(SubStr(cPatron, nPosIni2, nPosFin2),","))
						aadd(aTipo,2)
					EndIf
				Next
				cMPatron += "->" + aAux2[1] + IiF(Len(aAux2) > 1 ,OemToAnsi(STR0006) + aAux2[1],"") + CRLF
				cPatron := SubStr(cPatron, AT("}", cPatron)+1, Len(cPatron))
				nPosIni := 1
			Case cCar == "|"
				nPosIni++
		EndCase
	EndDo
	nLonCta := Len(cRet) //Longitud de la Cta.
	If IsNumeric(cRet)//Numerico o Alfanumerico
		nNumAlf := 1
	Else
		nNumAlf := 2
	EndIf

	If Len(aAux1[nNumAlf]) == 0
		cMensaje += STR0007 + CRLF //" no cumple con el patrón requerido. "
		cMensaje += cMPatron
		oModel:SetErrorMessage('', '' , '' , '' , '', '', cMensaje)
		Return lRet
	Else
		For nX := 1 to Len(cRet)
			If (!IsDigit(SubStr(cRet,nX,1)) .And. !IsAlpha(SubStr(cRet,nX,1)) .And. SubStr(cRet,nX,1) <> "_")//Se valida que la cuenta no contenga caracteres no permitidos
				cMensaje += OemToAnsi(STR0008) + CRLF //" contien caracteres no permitidos."
				cMensaje += SubStr(cRet,nX,1)
				cMensaje += cMPatron
				oModel:SetErrorMessage('', '' , '' , '' , '', '', cMensaje)
				Return lRet
			EndIf
		Next
	EndIf

	For nX := 1 to Len(aAux1[nNumAlf])//Se valida que cumpla la longitud, si es menor, llena con 0 a la izquierda hasta obtener una longitud válida
		If aScan(aAux1[nNumAlf][nX], alltrim(str(nLonCta))) <> 0 //Tamaño igual a alguno de los elementos del array?
			lAux := lRet := .T.
			Exit
		Else
			For nY := 1 To Len(aAux1[nNumAlf][nX])
				If nY > 1
					If Len(cRet) >= Val(aAux1[nNumAlf][nX][1]) .And. Len(cRet) <= Val(aAux1[nNumAlf][nX][2])//Se valida si la longitud se encuentra entre un rango, si es así, no se completa con 0s a la izquierda
						lAux := lRet := .T.
						Exit
					EndIf
				EndIf
				While Len(cRet) < Val(aAux1[nNumAlf][nX][nY]) //Se completa la Cta. con 0s a la izquierda
					cRet := "0" + cRet
					cCta := cRet
					lAux := lRet := .T.
				EndDo
			Next nY
			If lAux
				oModelSEL:SetValue(cCpoCta,cRet)
				Exit
			EndIf
		EndIf
	Next nX
	If !lAux
		cMensaje += OemToAnsi(STR0009) + CRLF + cMPatron //" supera longitud máxima permitida."
		oModel:SetErrorMessage('', '' , '' , '' , '', '', cMensaje)
	EndIf

Return lRet

/*/{Protheus.doc} F887ValHr
Función para validación de la hora introducida en el recibo de cobro

@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		09/04/2027
/*/
Function F887ValHr()
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet  	:= .T.
Local cHoraPag	:= oModelSEL:GetValue("EL_HRPAGO")
Local cHora 	:= StrZero((Val(SubStr(cHoraPag,1,2))),2,0)
Local cMin		:= StrZero((Val(SubStr(cHoraPag,4,2))),2,0)
Local cSeg		:= StrZero((Val(SubStr(cHoraPag,7,2))),2,0)

If cHora > "24" .Or. cMin > "59" .Or. cSeg > "59"
	MsgAlert(STR0010 + cHora + ":" + cMin + ":" + cSeg + STR0011) // "La hora indicada " ## " no es válida."
	oModelSEL:LoadValue("EL_HRPAGO", "12:00:00")
	lRet := .F.
Else
	oModelSEL:LoadValue("EL_HRPAGO", cHora + ":" + cMin + ":" + cSeg)
EndIf 

Return lRet

/*/{Protheus.doc} F887WHEN
Función para validación de los campos relacionados al CEP

@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		09/04/2027
/*/
Function F887WHEN()
Local oModel 		:= FWModelActive()
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local lRet			:= .T.
Local cFormPag		:= Iif(SEL->(ColumnPos("EL_FORPGO")) > 0,oModelSEL:GetValue("EL_FORPGO"), "")
Local cPgoBan		:= "02,03,04,05,06,28,29"
Local cCpoBAN		:= IIf(cFormPag $ cPgoBan, "EL_BCOCHQ", "EL_BANCO")
Local cCpoAGE		:= IIf(cFormPag $ cPgoBan, "EL_AGECHQ", "EL_AGENCIA")
Local cCpoCON		:= IIf(cFormPag $ cPgoBan, "EL_CTACHQ", "EL_CONTA")
Local cCta			:= ""
Local cCGCBanco		:= ""
Local lCHVal		:= .F.
Local cRFCExt		:= ""
Local cFilSA6		:= xFilial("SA6")
Local cPatCtaOrd	:= AllTrim(ObtColSAT("S005", cFormPag, 1, 2, 43, 97 - 43))
Local cPatCtaBen	:= AllTrim(ObtColSAT("S005", cFormPag, 1, 2, 98, 154 - 98))

	If !Empty(cFormPag)
		If cFormPag $ "01,08,12,13,14,15,17,23,24,25,26,27,30,31"
			oModelSEL:LoadValue("EL_CEPCER","")
			oModelSEL:LoadValue("EL_CEPCAD","")
			oModelSEL:LoadValue("EL_CEPSEL","")
			oModelSEL:LoadValue("EL_RFCEMI",Space(GetSx3Cache("EL_RFCEMI","X3_TAMANHO")))
			oModelSEL:LoadValue("EL_CTAORD","")
			oModelSEL:LoadValue("EL_CTABEN","")
			If SEL->(ColumnPos("EL_CEPTIP")) > 0
				oModelSEL:LoadValue("EL_CEPTIP",Space(GetSx3Cache("EL_CEPTIP","X3_TAMANHO")))	
			EndIf
		Else
			If cFormPag == '02' //Cheque
				If !Empty(oModelSEL:GetValue(cCpoBAN)) .AND. !Empty(oModelSEL:GetValue(cCpoAGE)) .AND. !Empty(oModelSEL:GetValue(cCpoCON))
					cCGCBanco := Posicione("SA6",1,cFilSA6+oModelSEL:GetValue(cCpoBAN)+oModelSEL:GetValue(cCpoAGE)+oModelSEL:GetValue(cCpoCON),"A6_CGC")
					If AllTrim(SA6->A6_EST) == "EX"
						lCHVal := .F.
					Else
						lCHVal := IIf(Empty(cCGCBanco), .T., .F.)
					EndIf
				Else
					lCHVal := .T.
				EndIf
			EndIf

			If !(cFormPag $ cPgoBan) .or. lCHVal
				cCpoBAN := "EL_BANCO"
				cCpoAGE := "EL_AGENCIA"
				cCpoCON := "EL_CONTA"
			EndIf

			If AllTrim(oModelSEL:GetValue("EL_RFCEMI")) == ""
				cRFCExt := Posicione("SA6",1,cFilSA6+oModelSEL:GetValue(cCpoBAN)+oModelSEL:GetValue(cCpoAGE)+oModelSEL:GetValue(cCpoCON),"A6_EST")// A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				If AllTrim(cRFCExt) == "EX"
					cCGCBanco := "XEXX010101000"
				Else
					cCGCBanco := Posicione("SA6",1,cFilSA6+oModelSEL:GetValue(cCpoBAN)+oModelSEL:GetValue(cCpoAGE)+oModelSEL:GetValue(cCpoCON),"A6_CGC")// A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				EndIf
				oModelSEL:LoadValue("EL_RFCEMI",cCGCBanco)
			EndIf

			If AllTrim(oModelSEL:GetValue("EL_CTAORD")) == ""
				cCta := cCpoCON
				 F887PatCta(@(cCta),2)
				oModelSEL:LoadValue("EL_CTAORD",cCta)
			EndIf

			If AllTrim(oModelSEL:GetValue("EL_CTABEN")) == ""
				cCta := "EL_CONTA"
				F887PatCta(@(cCta),2)
				oModelSEL:LoadValue("EL_CTABEN", cCta)
			EndIf
		EndIf
		If cFormPag $ "02,03,04,05,06,28,29"		
			oModelSEL:LoadValue("EL_CEPCER", "")
			oModelSEL:LoadValue("EL_CEPCAD", "")
			oModelSEL:LoadValue("EL_CEPSEL", "")
			If SEL->(ColumnPos("EL_CEPTIP")) > 0
				oModelSEL:LoadValue("EL_CEPTIP", Space(GetSx3Cache("EL_CEPTIP","X3_TAMANHO")))
			EndIf
			If Empty(cPatCtaOrd)
				oModelSEL:LoadValue("EL_CTAORD", "")
			EndIf
			If Empty(cPatCtaBen)
				oModelSEL:LoadValue("EL_CTABEN", cCta)
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F887AWH
Función para validación de los campos relacionados al CEP
@param		cCamTip - campo que detona la validación 
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		09/04/2027
/*/
Function F887AWH(cCamTip)
Local oModel 		:= FWModelActive()
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local lRet			:= .T.
Local cFrmPag		:= ""
Local cCepTip		:= ""

	If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_FORPGO"})
		cFrmPag := oModelSEL:GetValue("EL_FORPGO")
	EndIf
	
	If !Empty(cFrmPag)
		If cFrmPag $ "01,08,12,13,14,15,17,23,24,25,26,27,30,31"
			lRet := .F.
		Endif
		If cFrmPag $ "02,04,05,06,28,29" .And. lRet
			If !(cCamTip $ 'EL_RFCEMI|EL_CTAORD|EL_CTABEN') .Or. (cFrmPag $ "06" .And. cCamTip $ "EL_CTABEN")
				lRet := .F.
			Endif
			If cCamTip $ 'EL_CEPCER|EL_CEPCAD|EL_CEPSEL' .And. lRet
				If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_CEPTIP"})
					cCepTip := oModelSEL:GetValue("EL_CEPTIP")
					If Empty(cCepTip)
						oModelSEL:LoadValue(cCamTip, "")
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	
	EndIf
	
Return lRet
