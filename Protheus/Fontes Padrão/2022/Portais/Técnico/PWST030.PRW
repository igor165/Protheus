#INCLUDE "PWST030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//**********************************************************************
// Tela de Seleção de tecnico
Web Function PWST030()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST020TEC := GetUserTec()

HttpSession->PWST020APH := { STR0001 ,;					// Base Instalada
								"W_PWST031.APW"	,;		// Proxima Tela
								"" }	 				// Msg de Erro
										
If Len( HttpPost->PWST020TEC ) <= 1
	HttpSession->PWST020APH[3] := STR0002 	//"Não há tecnicnos a consultar."

	cHtml += ExecInPage( "PWST020" )
ElseIf Len( HttpPost->PWST020TEC ) == 2
	// Apenas 1 tecnico . Define a navegação para pular a tela de seleção de tecnico
	HttpPost->CODTECERP := HttpPost->PWST020TEC[2][2]

	cHtml += W_PWST031()
Else
	// Mais de 1 tecnico ? Chama tela de seleção de tecnicos
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

/************************************************************/
Web Function PWST031()

Local cHtml := ""
Local oObj
Local oObjCustomer
Local oObjProduct
Local aWebCols := {}

WEB EXTENDED INIT cHtml

oObj := WSFSINSTALLBASE():New()
oObjCustomer := WSMTSYSTEMCUSTOMER():New()
oObjProduct := WSMTPRODUCT():New()

WsChgURL( @oObj, "FSINSTALLBASE.APW" )
WsChgURL( @oObjCustomer, "MTSYSTEMCUSTOMER.APW" )
WsChgURL( @oObjProduct, "MTPRODUCT.APW" )

If Empty( HttpSession->HEADER031_1 ) .OR. Empty( HttpSession->HEADER031_2 ) .OR. Empty( HttpSession->HEADER031_3 )
	If oObjCustomer:GETHEADER( "CUSTOMERVIEW" )
		HttpSession->HEADER031_1 := oObjCustomer:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf
	
	If oObjProduct:GETHEADER( "PRODUCTVIEW" )
		HttpSession->HEADER031_2 := oObjProduct:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "EQUIPMENTVIEW" )
		HttpSession->HEADER031_3 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf
EndIf

If Empty( HttpSession->PWST031INFO )
	HttpSession->PWST031INFO := { {}, {} }

	If ExistBlock( "PET031" )
		aWebCols := ExecBlock( "PET031", .F., .F., {1} )
	EndIf
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWST031INFO[1], HttpSession->HEADER031_1, aWebCols )
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEX( { HttpSession->PWST031INFO[1], ;
				HttpSession->HEADER031_1, ;
				MTSYSTEMCUSTOMER_CUSTOMERVIEW():New(), ;
				aWebCols, .T., "A",,0 } )
	
	aWebCols := {}
       
	If ExistBlock( "PET031" )
		aWebCols := ExecBlock( "PET031", .F., .F., {2} )
	EndIf

	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWST031INFO[2], HttpSession->HEADER031_2, aWebCols )
	
	GridLinesEX( { HttpSession->PWST031INFO[2], ;
				HttpSession->HEADER031_2, ;
				MTPRODUCT_PRODUCTVIEW():New(), ;
				aWebCols, .T., "A",,0 } )
EndIf

HttpSession->PWST031RESULT := {}
HttpSession->PWST031BRW := {}
HttpSession->_031TEMPCTR := "1"

If ( !Empty( HttpPost->CCUSTOMERCODE ) .AND. !Empty( HttpPost->CUNITCUSTOMERCODE ) ) .OR. ;
	!Empty( HttpPost->CPRODUCTCODE )
	HttpSession->_031TEMPCTR := ""
	
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:cCUSTOMERID	:= HttpPost->CCUSTOMERCODE + HttpPost->CUNITCUSTOMERCODE
	oObj:cPRODUCTCODE	:= HttpPost->CPRODUCTCODE
	oObj:cINDEXKEY		:= NIL
	oObj:cQUERYADDWHERE	:= ""
	
	//cUSERCODE,cCUSTOMERID,cPRODUCTCODE,cINDEXKEY,cQUERYADDWHERE
	If oObj:BRWINSTALLBASE()
		HttpSession->PWST031RESULT := oObj:oWSBRWINSTALLBASERESULT:oWSEQUIPMENTVIEW
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf
EndIf

If !Empty( HttpSession->PWST031RESULT )
	aWebCols := {}

	If ExistBlock( "PET031" )
		aWebCols := ExecBlock( "PET031", .F., .F., {3} )
	EndIf

	GridHeader( HttpSession->PWST031BRW, HttpSession->HEADER031_3, aWebCols )
	
	GridLinesEX( { HttpSession->PWST031BRW, ;
				HttpSession->HEADER031_3, ;
				HttpSession->PWST031RESULT, aWebCols, .F., "A",,0 } )
EndIf

cHtml += ExecInPage( "PWST031" )

WEB EXTENDED END

Return cHtml

/************************************************************/
Web Function PWST032()

Local cHtml := ""
Local oObj
Local aDados := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml

oObj := WSFSINSTALLBASE():New()
WsChgURL( @oObj, "FSINSTALLBASE.APW" )

If Empty( HttpSession->HEADER032_1 ) .OR. Empty( HttpSession->HEADER032_2 )
	If oObj:GETHEADER( "EQUIPMENTVIEW" )
		HttpSession->HEADER032_1 := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "ACCESSORYVIEW" )
		HttpSession->HEADER032_2 := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf
EndIf

If !Empty( HttpPost->cBase )
	If HttpPost->cAcao == "V"
		HttpSession->_TMPBIBOTOES := "V"
	EndIf
	
	HttpSession->PWST032INFO := { {}, {} }
	HttpSession->PWST032RESULT := { NIL, NIL }
	aDados := Separa( HttpPost->cBase, "|" )
	
	oObj:cUSERCODE				:= "MSALPHA"
	oObj:cPRODUCTCODE			:= aDados[1]
	oObj:cSERIALNUMBER			:= aDados[2]
	oObj:cMANUFACTURERCODE		:= aDados[3]
	oObj:cUNITMANUFACTURERCODE	:= aDados[4]

	//cUSERCODE,cPRODUCTCODE,cSERIALNUMBER,cMANUFACTURERCODE,cUNITMANUFACTURERCODE
	If oObj:GETINSTALLBASE()
		HttpSession->PWST032RESULT[1] := oObj:oWSGETINSTALLBASERESULT:oWSEQUIPMENT
		HttpSession->PWST032RESULT[2] := oObj:oWSGETINSTALLBASERESULT:oWSACCESSORIES:oWSACCESSORYVIEW
		            
		If ExistBlock( "PET032" )
			aWebCols := ExecBlock( "PET032", .F., .F., {1} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST032INFO[1], ;
						HttpSession->HEADER032_1,;
						HttpSession->PWST032RESULT[1], aWebCols, .F., "H",,0 } )
        
        aWebCols := {}                                                       
        
		If ExistBlock( "PET032" )
			aWebCols := ExecBlock( "PET032", .F., .F., {2} )
		EndIf

		GridHeader(	HttpSession->PWST032INFO[2], ;
						HttpSession->HEADER032_2,;
						aWebCols )

		GridLinesEX( {	HttpSession->PWST032INFO[2], ;
						HttpSession->HEADER032_2,;
						HttpSession->PWST032RESULT[2], aWebCols, .F., "A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
	EndIf

	cHtml += ExecInPage( "PWST032" )
Else
	cHtml += ExecInPage( "PWST031" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST032A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml

HttpSession->PWST032AINFO := {}

If HttpSession->_TMPBIBOTOES == "I"

	If ExistBlock( "PET032A" )
		aWebCols := ExecBlock( "PET032A", .F., .F., {} )
	EndIf

	GridHeader( HttpSession->PWST032AINFO, HttpSession->HEADER033_2, aWebCols )

	GridLinesEX( {	HttpSession->PWST032AINFO, ;
					HttpSession->HEADER033_2, ;
					FSINSTALLBASE_ACCESSORYVIEW():New(), ;
					aWebCols, .F., "A",,0 } )
EndIf

cHtml += ExecInPage( "PWST032A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST033()

Local cHtml := ""
Local oObj
Local oObjView
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSINSTALLBASE():New()
oObjView := FSINSTALLBASE_EQUIPMENTVIEW():New()

WsChgURL( @oObj, "FSINSTALLBASE.APW" )

HttpSession->PWST033INFO := { {}, {} }

If HttpPost->cAcao == "I" .OR. HttpGet->cAcao == "I"
	HttpSession->_TMPBIBOTOES := "I"

	If Empty( HttpGet->cAcao )
		HttpSession->PWST033GRAVA := { FSINSTALLBASE_EQUIPMENTVIEW():New(), {} }
	EndIf

	If Empty( HttpSession->HEADER033_1 ) .OR. Empty( HttpSession->HEADER033_2 )
		If oObj:GETHEADER( "EQUIPMENTVIEW" )
			HttpSession->HEADER033_1 := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
		EndIf
	
		If oObj:GETHEADER( "ACCESSORYVIEW" )
			HttpSession->HEADER033_2 := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWST030.APW" )//"Erro"
		EndIf
	EndIf

	oObjView:dSALESDATE			:= Date()
	oObjView:dINSTALLATIONDATE	:= Date()
	oObjView:dWARRANTYDATE		:= Date()
         
	If ExistBlock( "PET033" )
		aWebCols := ExecBlock( "PET033", .F., .F., {1} )
	EndIf

	GridLinesEX( {	HttpSession->PWST033INFO[1], ;
					HttpSession->HEADER033_1, ;
					IIf( !Empty( HttpGet->cAcao ), HttpSession->PWST033GRAVA[1], oObjView ), ;
					aWebCols, .T., "H",,0 } )
ElseIf HttpPost->cAcao == "AC"
    
	If ExistBlock( "PET033" )
		aWebCols := ExecBlock( "PET033", .F., .F., {2} )
	EndIf
	
	GridLinesEX( {	HttpSession->PWST033INFO[1], ;
					HttpSession->HEADER033_1, ;
					HttpSession->PWST033GRAVA[1], ;
					aWebCols, .T., "H",,0 } )
EndIf

cHtml += ExecInPage( "PWST033" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST034()

Local cHtml := ""
Local lExclui := .F.
Local oObjView
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSINSTALLBASE_ACCESSORYVIEW():New()

HttpSession->PWST034INFO := { {}, {} }

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "AI"
		aBI := Separa( HttpPost->cSelItem, "|" )
		nPosProd := aScan( HttpSession->PWST033GRAVA[2], { |x| AllTrim( x:cPRODUCTCODE ) == AllTrim( aBI[1] ) .AND. AllTrim( x:cSERIALNUMBER ) == AllTrim( aBI[2] ) } )

		If nPosProd > 0
		
			If ExistBlock( "PET034" )
				aWebCols := ExecBlock( "PET034", .F., .F., {1} )
			EndIf
		
			GridLinesEX( {	HttpSession->PWST034INFO[1], ;
							HttpSession->HEADER033_1, ;
							HttpSession->PWST033GRAVA[1], ;
							aWebCols, .F., "H",,0 } )
			
			GridLinesEX( {	HttpSession->PWST034INFO[2], ;
							HttpSession->HEADER033_2, ;
							HttpSession->PWST033GRAVA[2][nPosProd], ;
							aWebCols, .T., "H","1",0 } )
		EndIf
	Else
		PWSSetObjToPost( HttpSession->PWST033GRAVA[1], HttpSession->HEADER033_1, HttpPost->aPost )
		                        
		aWebCols := {}
		         
		If ExistBlock( "PET034" )
			aWebCols := ExecBlock( "PET034", .F., .F., {2} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST034INFO[1], ;
						HttpSession->HEADER033_1, ;
						HttpSession->PWST033GRAVA[1], ;
						aWebCols, .F., "H",,0 } )
		
		oObjView:dINSTALLATIONDATE	:= Date()
		oObjView:dWARRANTYDATE		:= Date()
	
		GridLinesEX( {	HttpSession->PWST034INFO[2], ;
						HttpSession->HEADER033_2, ;
						oObjView, ;
						aWebCols, .T., "H","1",0 } )
	EndIf
EndIf

ExecInPage( "PWST034" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST034A()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWST034AINFO := {}

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "EI"
		aBI := Separa( HttpPost->cSelItem, "|" )
		nPosProd := aScan( HttpSession->PWST033GRAVA[2], { |x| AllTrim( x:cPRODUCTCODE ) == AllTrim( aBI[1] ) .AND. AllTrim( x:cSERIALNUMBER ) == AllTrim( aBI[2] ) } )
		
		If nPosProd > 0
			aDel( HttpSession->PWST033GRAVA[2], nPosProd )
			aSize( HttpSession->PWST033GRAVA[2], Len( HttpSession->PWST033GRAVA[2] ) - 1 )
		EndIf
                    
		If ExistBlock( "PET034A" )
			aWebCols := ExecBlock( "PET034A", .F., .F., {1} )
		EndIf

		GridHeader( HttpSession->PWST034AINFO, HttpSession->HEADER033_2, aWebCols )
	
		GridLinesEX( {	HttpSession->PWST034AINFO, ;
						HttpSession->HEADER033_2, ;
						HttpSession->PWST033GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	Else                                                                         
	
		If ExistBlock( "PET034A" )
			aWebCols := ExecBlock( "PET034A", .F., .F., {2} )
		EndIf
	
		GridHeader( HttpSession->PWST034AINFO, HttpSession->HEADER033_2, aWebCols )
	
		GridLinesEX( {	HttpSession->PWST034AINFO, ;
						HttpSession->HEADER033_2, ;
						HttpSession->PWST033GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	EndIf
EndIf

ExecInPage( "PWST034A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST035()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local oObjView
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSINSTALLBASE_ACCESSORYVIEW():New()

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "II"
		aAdd( HttpSession->PWST033GRAVA[2], FSINSTALLBASE_ACCESSORYVIEW():New() )
		PWSSetObjToPost( HttpSession->PWST033GRAVA[2][Len( HttpSession->PWST033GRAVA[2] )], HttpSession->HEADER033_2, HttpPost->aPost, "1" )
	ElseIf HttpPost->cAcao == "AI"
		aBI := Separa( HttpPost->cSelItem, "|" )
		nPosProd := aScan( HttpSession->PWST033GRAVA[2], { |x| AllTrim( x:cPRODUCTCODE ) == AllTrim( aBI[1] ) .AND. AllTrim( x:cSERIALNUMBER ) == AllTrim( aBI[2] ) } )
		
		If nPosProd > 0
			PWSSetObjToPost( HttpSession->PWST033GRAVA[2][nPosProd], HttpSession->HEADER033_2, HttpPost->aPost, "1" )
		EndIf
		
		HttpSession->PWST034INFO := { {}, {} }
                    
		If ExistBlock( "PET035" )
			aWebCols := ExecBlock( "PET035", .F., .F., {1} )
		EndIf

		GridLinesEX( {	HttpSession->PWST034INFO[1], ;
						HttpSession->HEADER033_1, ;
						HttpSession->PWST033GRAVA[1], ;
						aWebCols, .F., "H",,0 } )
		
		oObjView:dINSTALLATIONDATE	:= Date()
		oObjView:dWARRANTYDATE		:= Date()

		If ExistBlock( "PET035" )
			aWebCols := ExecBlock( "PET035", .F., .F., {2} )
		EndIf
	        
		GridLinesEX( {	HttpSession->PWST034INFO[2], ;
						HttpSession->HEADER033_2, ;
						oObjView, ;
						aWebCols, .T., "H","1",0 } )		
		HttpPost->cAcao := ""
	EndIf
EndIf

cHtml := ExecInPage( "PWST034" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST036()

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSINSTALLBASE():New()
WsChgURL( @oObj, "FSINSTALLBASE.APW" )

If HttpSession->_TMPBIBOTOES == "I"
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:oWSINSTALLBASE	:= FSINSTALLBASE_INSTALLBASEVIEW():New()
	oObj:oWSINSTALLBASE:oWSEQUIPMENT	:= HttpSession->PWST033GRAVA[1]
	oObj:oWSINSTALLBASE:oWSACCESSORIES	:= FSINSTALLBASE_ARRAYOFACCESSORYVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWST033GRAVA[2] )
		aAdd( oObj:oWSINSTALLBASE:oWSACCESSORIES:oWSACCESSORYVIEW, FSINSTALLBASE_ACCESSORYVIEW():New() )
		oObj:oWSINSTALLBASE:oWSACCESSORIES:oWSACCESSORYVIEW[nI] := HttpSession->PWST033GRAVA[2][nI]
	Next nI

	//cUSERCODE,oWSINSTALLBASE
	If oObj:PUTINSTALLBASE()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST030.APW" )//"Atenção","Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST033.APW?cAcao=I" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml