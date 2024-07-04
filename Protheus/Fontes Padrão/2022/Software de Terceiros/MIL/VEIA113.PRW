#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA113.CH"

/*/{Protheus.doc} VEIA113
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA113()

	Local lSchedule := FWGetRunSchedule()

	Local bProcess := { |oSelf| VA1130013_Processar(oSelf , lSchedule) }
	Local oTProces
	Local cPerg := "VEIA113"
	Local aInfoCustom := {}
	
	If lSchedule
		VA1130013_Processar( NIL , lSchedule)
	Else

		oTProces := tNewProcess():New(;
			/* 01 */	"VEIA113",;
			/* 02 */	STR0001,;
			/* 03 */	bProcess,;
			/* 04 */	STR0002,;
			/* 05 */	cPerg ,;
			/* 06 */	aInfoCustom ,;
			/* 07 */	.t. /* lPanelAux */ ,;
			/* 08 */	 /* nSizePanelAux */ ,;
			/* 09 */	/* cDescriAux */ ,;
			/* 10 */	.t. /* lViewExecute */ ,;
			/* 11 */	.t. /* lOneMeter */ )

	EndIf

Return()


/*/{Protheus.doc} VA1130013_Processar
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oTProces, object, description
@param lSchedule, logical, description
@type function
/*/
Static Function VA1130013_Processar(oTProces, lSchedule)

	Local lContinua :=  .f.
	Local oJDQuote := VEJDQuoteMaintainQuote():New()
	Local nPosQuote
	Local aProcessar := {}		
	Local nRecVJJ := 0

	Local oModel110 := FWLoadModel( 'VEIA110' )

	Local lEscondeVencidas  := (MV_PAR02 == 2)
	Local lEscondeExpiradas := (MV_PAR03 == 2)

	Default lSchedule := .f.

	lContinua := VA1100093_GetQuote(oJDQuote, dDataBase - MV_PAR01, dDataBase, 0, .t.)
	If ! lContinua .or. Len(oJDQuote:aResponse) == 0
		Return .T.
	EndIf

	For nPosQuote := 1 to Len(oJDQuote:aResponse)

		lJaImportada := VA1100123_JaImportada(oJDQuote:aResponse[nPosQuote]:quoteId , @nRecVJJ)

		If oJDQuote:aResponse[nPosQuote]:deleteIndicator 
			If lJaImportada
				VA1130023_MarcarDeletada(nRecVJJ, oModel110)
			EndIf
			Loop
		EndIf

		// Vencida
		If lJaImportada == .f.
			If lEscondeVencidas .and. dDataBase > oJDQuote:aResponse[nPosQuote]:expirationDate
				Loop
			EndIf	
			If lEscondeExpiradas .and. Upper(oJDQuote:aResponse[nPosQuote]:quoteStatus) == "EXPIRADO"
				Loop
			EndIf
		EndIf
	
		AADD( aProcessar , { oJDQuote:aResponse[nPosQuote]:quoteId , "2" /* COTACAO */ } )

	Next nPosQuote

	oTProces:SetRegua1(Len(aProcessar))

	VA1100043_ImportarQuote(aProcessar, lSchedule, oTProces, .t.)
	
Return 

/*/{Protheus.doc} VA1130023_MarcarDeletada
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nRecVJJ, numeric, description
@param oModel110, object, description
@type function
/*/
Function VA1130023_MarcarDeletada(nRecVJJ, oModel110)

	Local oModelVJJ

	VJJ->(dbGoTo(nRecVJJ))

	oModel110:SetOperation( MODEL_OPERATION_UPDATE )
	lRet := oModel110:Activate()
	If lRet
		oModelVJJ := oModel110:GetModel( "MODEL_VJJ" )
		oModelVJJ:SetValue("VJJ_DELETE", "1")
		oModelVJJ:SetValue('VJJ_DTSINC' , Date() )
		oModelVJJ:SetValue('VJJ_HRSINC' , StrTran(Time(),":") )

		If ( lRet := oModel110:VldData() )
			lRet := oModel110:CommitData()
		EndIf
	EndIf
	oModel110:DeActivate()

Return lRet


/*/{Protheus.doc} SchedDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SchedDef()

	Local aParam := {;
		"P",;
		"VEIA113",;
		"",;
		"",;
		"" ;
	}

Return aParam
