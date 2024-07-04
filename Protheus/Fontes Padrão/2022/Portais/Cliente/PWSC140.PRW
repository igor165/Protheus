#INCLUDE "PWSC140.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/**************************************************************************************************/
//Tela de selecao de Clientes
Web Function PWSC140()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC020CLI := GetUserCli()

HttpSession->PWSC020APH := { STR0001, ;					//"Ordens de Produção"
								"W_PWSC141.APW", ;		// Proxima Tela
								""	} 					// Msg de Erro

If Len( HttpPost->PWSC020CLI ) <= 1
	HttpSession->PWSC020APH[3] := STR0002 //"Não há clientes a consultar."

	cHtml += ExecInPage( "PWSC020" )
ElseIf Len(HttpPost->PWSC020CLI) = 2
	//Apenas 1 cliente. Define a navegação para pular a tela de seleção de cliente
	HttpPost->CODCLIERP	:= HttpPost->PWSC020CLI[2][2]

	cHtml += W_PWSC141()
Else
	//Mais de 1 cliente? Chama tela de seleção de CLientes
	cHtml += ExecInPage( "PWSC020" )
EndIf

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de ordem de producao
Web Function PWSC141()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
WsChgURL( @oObj, "MTCUSTOMERPRODUCTIONORDER.APW" )

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

If Empty( HttpSession->PWSC141HEADER )
	HttpSession->PWSC141HEADER := { {}, {}, {} }
	
	If oObj:GETHEADER( "PRODUCTIONORDERVIEW" )
		HttpSession->PWSC141HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
	EndIf
	
	If oObj:GETHEADER( "GOODSMOVEMENTSVIEW" )
		HttpSession->PWSC141HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "POLOSSVIEW" )
		HttpSession->PWSC141HEADER[3] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC141APH := { STR0004, "W_PWSC142.APW" }//"Processamento de Ordem de Produção"

cHtml += ExecInPage( "PWSC141" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de ordem de producao
Web Function PWSC142()

Local cHtml 	:= ""
Local oObj
Local oObjTotalOP
Local aWebCols 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
oObjTotalOP := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
WsChgURL( @oObj, "MTCUSTOMERPRODUCTIONORDER.APW" )
WsChgURL( @oObjTotalOP, "MTCUSTOMERPRODUCTIONORDER.APW" )

HttpSession->PWSC142APH := { STR0005, "W_PWSC143.APW" }//"Resultado Busca"

If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
EndIf

If !Empty( HttpGet->dPODATEFROM ) .AND. !Empty( HttpGet->dPODATETO )
	HttpPost->dPODATEFROM := HttpGet->dPODATEFROM
	HttpPost->dPODATETO := HttpGet->dPODATETO
EndIf

If !Empty( HttpGet->dSTARTFORECASTDATEFROM ) .AND. !Empty( HttpGet->dSTARTFORECASTDATETO )
	HttpPost->dSTARTFORECASTDATEFROM := HttpGet->dSTARTFORECASTDATEFROM
	HttpPost->dSTARTFORECASTDATETO := HttpGet->dSTARTFORECASTDATETO
EndIf

If !Empty( HttpGet->dFINISHFORECASTDATEFROM ) .AND. !Empty( HttpGet->dFINISHFORECASTDATETO )
	HttpPost->dFINISHFORECASTDATEFROM := HttpGet->dFINISHFORECASTDATEFROM
	HttpPost->dFINISHFORECASTDATETO := HttpGet->dFINISHFORECASTDATETO
EndIf

oObj:cUSERCODE := GetUsrCode()
oObj:cCUSTOMERID := HttpSession->CODCLIERP
oObjTotalOP:cUSERCODE := GetUsrCode()
oObjTotalOP:cCUSTOMERID := HttpSession->CODCLIERP

If !Empty( HttpPost->dPODATEFROM ) .AND. !Empty( HttpPost->dPODATETO )
	oObj:dPODATEFROM 		:= CToD( HttpPost->dPODATEFROM )
	oObj:dPODATETO	 		:= CToD( HttpPost->dPODATETO )
	oObjTotalOP:dPODATEFROM	:= CToD( HttpPost->dPODATEFROM )
	oObjTotalOP:dPODATETO	:= CToD( HttpPost->dPODATETO )
EndIf

If !Empty( HttpPost->dSTARTFORECASTDATEFROM ) .AND. !Empty( HttpPost->dSTARTFORECASTDATETO )
	oObj:dSTARTFORECASTDATEFROM 		:= CToD( HttpPost->dSTARTFORECASTDATEFROM )
	oObj:dSTARTFORECASTDATETO	 		:= CToD( HttpPost->dSTARTFORECASTDATETO )
	oObjTotalOP:dSTARTFORECASTDATEFROM	:= CToD( HttpPost->dSTARTFORECASTDATEFROM )
	oObjTotalOP:dSTARTFORECASTDATETO 	:= CToD( HttpPost->dSTARTFORECASTDATETO )
EndIf

If !Empty( HttpPost->dFINISHFORECASTDATEFROM ) .AND. !Empty( HttpPost->dFINISHFORECASTDATETO )
	oObj:dFINISHFORECASTDATEFROM 		:= CToD( HttpPost->dFINISHFORECASTDATEFROM )
	oObj:dFINISHFORECASTDATETO	 		:= CToD( HttpPost->dFINISHFORECASTDATETO )
	oObjTotalOP:dFINISHFORECASTDATEFROM	:= CToD( HttpPost->dFINISHFORECASTDATEFROM )
	oObjTotalOP:dFINISHFORECASTDATETO 	:= CToD( HttpPost->dFINISHFORECASTDATETO )
EndIf

If !Empty( HttpPost->cBuscaAv )
	oObj:cQUERYADDWHERE := "C2_NUM='" + HttpPost->cBuscaAv + "'"
	oObjTotalOP:cQUERYADDWHERE := "C2_NUM='" + HttpPost->cBuscaAv + "'"
EndIf

If HttpPost->cGrafico <> "1"
	oObj:nPAGELEN 		:= 10
	oObj:nPAGEFIRST 	:= ( Val( HttpGet->cPagina ) * 10 ) + 1
EndIf

//cUSERCODE,dPODATEFROM,dPODATETO,dSTARTFORECASTDATEFROM,dSTARTFORECASTDATETO,dFINISHFORECASTDATEFROM,dFINISHFORECASTDATETO,dSTARTADJUSTEDDATEFROM,dSTARTADJUSTEDDATETO,dFINISHADJUSTEDDATEFROM,dFINISHADJUSTEDDATETO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
If oObj:BRWPRODUCTIONORDER()
	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,dPODATEFROM,dPODATETO,dSTARTFORECASTDATEFROM,dSTARTFORECASTDATETO,dFINISHFORECASTDATEFROM,dFINISHFORECASTDATETO,dSTARTADJUSTEDDATEFROM,dSTARTADJUSTEDDATETO,dFINISHADJUSTEDDATEFROM,dFINISHADJUSTEDDATETO,cQUERYADDWHERE
		If oObjTotalOP:BRWTOTALPRODUCTIONORDER()
			HttpSession->nTotalOP := oObjTotalOP:nBRWTOTALPRODUCTIONORDERRESULT
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
		EndIf
	EndIf

	HttpSession->PWSC142RESULT := { oObj:oWSBRWPRODUCTIONORDERRESULT:oWSPRODUCTIONORDERVIEW }
	HttpSession->PWSC142INFO := {}

	If ExistBlock( "PEC142" )
		aWebCols := ExecBlock( "PEC142", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWSC142INFO, ;
					HttpSession->PWSC141HEADER[1][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC142INFO, ;
					HttpSession->PWSC141HEADER[1][1], ;
					HttpSession->PWSC142RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
EndIf

If HttpPost->cGrafico == "1"
	cHtml += W_PWSC144()
Else
	cHtml += ExecInPage( "PWSC142" )
EndIf

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes da ordem de producao
Web Function PWSC143()

Local cHtml 	:= ""
Local oObj
Local aWebCols 	:= {}
Local aOP		:= {}

WEB EXTENDED INIT cHtml START "InSite"

aOP := Separa( HttpGet->cOP, "|" )

HttpSession->PWSC143APH := { STR0006 + aOP[1], "W_PWSC144.APW" }//"Ordem de Produção Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
WsChgUrl( @oObj, "MTCUSTOMERPRODUCTIONORDER.apw" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID 	:= HttpSession->CODCLIERP
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
If oObj:GETPRODUCTIONORDER()
	HttpSession->PWSC143RESULT := { oObj:oWSGETPRODUCTIONORDERRESULT }
	HttpSession->PWSC143INFO := {}
	
	If ExistBlock( "PEC143" )
		aWebCols := ExecBlock( "PEC143", .F., .F., {} )
	EndIf

	GridLinesEx( { HttpSession->PWSC143INFO, ;
					HttpSession->PWSC141HEADER[1][1], ;
					HttpSession->PWSC143RESULT[1], ;
					aWebCols, .F., "H",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC143" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizaco grafico de gantt
Web Function PWSC144()

Local cHtml 		:= ""
Local oObj
Local aOP			:= {}
Local nI 			:= 0
Local nJ 			:= 0
Local cPOID	 		:= ""
Local cPOITEM		:= ""
Local cPOSEQUENCE	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
WsChgUrl( @oObj, "MTCUSTOMERPRODUCTIONORDER.apw" )

HttpSession->aSemanas := {}
HttpSession->aDatas := {}

If HttpPost->cGrafico == "1"
	HttpSession->PWSC144APH := { STR0007 }//"Gráfico de Gantt"
	
	For nI := 1 To Len( HttpSession->PWSC142RESULT[1] )
		cPOID := HttpSession->PWSC142RESULT[1][nI]:cPOID + HttpSession->PWSC142RESULT[1][nI]:cPOITEM +;
					HttpSession->PWSC142RESULT[1][nI]:cPOSEQUENCE

		SetDatas( cPOID )
	
		oObj:cUSERCODE 		:= GetUsrCode()
		oObj:cCUSTOMERID 	:= HttpSession->CODCLIERP
		oObj:cPOID 			:= cPOID
		oObj:cPOITEM		:= ""
		oObj:cPOSEQUENCE	:= ""
		
		//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
		If oObj:BRWPOREQUIREMENTS()
			HttpSession->PWSC144RESULT := { oObj:oWSBRWPOREQUIREMENTSRESULT:oWSPOREQUIREMENTSVIEW }
		Else
			HttpSession->PWSC144RESULT := { {} }
		EndIf

		For nJ := 1 To Len( HttpSession->PWSC144RESULT[1] )
			If !Empty( HttpSession->PWSC144RESULT[1][nJ]:cPOORIGIN )
				SetDatas( HttpSession->PWSC144RESULT[1][nJ]:cPOORIGIN )
			EndIf
		Next nJ
	Next nI

	aSort( HttpSession->aSemanas,,, { |x, y| x < y } )
	InsSemana( HttpSession->aSemanas )
Else
	aOP := Separa( HttpPost->cOP, "|" )

	HttpSession->PWSC144APH := { STR0008 + aOP[1] + "/" + aOP[2] + "/" + aOP[3] }//"Gráfico de Gantt - OP: "
	
	cPOID := HttpSession->PWSC143RESULT[1]:cPOID + HttpSession->PWSC143RESULT[1]:cPOITEM +;
				HttpSession->PWSC143RESULT[1]:cPOSEQUENCE

	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cCUSTOMERID 	:= HttpSession->CODCLIERP
	oObj:cPOID			:= aOP[1]
	oObj:cPOITEM		:= aOP[2]
	oObj:cPOSEQUENCE	:= aOP[3]
	
	//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
	If oObj:BRWPOREQUIREMENTS()
		HttpSession->PWSC144RESULT := { oObj:oWSBRWPOREQUIREMENTSRESULT:oWSPOREQUIREMENTSVIEW }
		
		HttpSession->aSemanas := {}
		HttpSession->aDatas := {}
		
		SetDatas( cPOID )
		
		For nI := 1 To Len( HttpSession->PWSC144RESULT[1] )
			If !Empty( HttpSession->PWSC144RESULT[1][nI]:cPOORIGIN )
				SetDatas( HttpSession->PWSC144RESULT[1][nI]:cPOORIGIN )
			EndIf
		Next nI
	Else
		SetDatas( cPOID )
	EndIf

	aSort( HttpSession->aSemanas,,, { |x, y| x < y } )
	InsSemana( HttpSession->aSemanas )
EndIf
	
cHtml += ExecInPage( "PWSC144" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizaco apontamentos
Web Function PWSC145()

Local cHtml 		:= ""
Local oObj
Local aWebCols		:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
WsChgUrl( @oObj, "MTCUSTOMERPRODUCTIONORDER.apw" )

HttpSession->PWSC145APH := { STR0009 }//"Apontamentos"
HttpSession->PWSC145INFO := {}

aOP := Separa( HttpPost->cOP, "|" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cCUSTOMERID,cPOID,cPOITEM,cPOSEQUENCE
If oObj:BRWPOAPPOINTMENT()
	HttpSession->PWSC145RESULT := { oObj:oWSBRWPOAPPOINTMENTRESULT:oWSGOODSMOVEMENTSVIEW }
	
	If ExistBlock( "PEC145" )
		aWebCols := ExecBlock( "PEC145", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWSC145INFO, ;
					HttpSession->PWSC141HEADER[2][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC145INFO, ;
					HttpSession->PWSC141HEADER[2][1], ;
					HttpSession->PWSC145RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC145" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizaco perdas
Web Function PWSC146()

Local cHtml 		:= ""
Local oObj
Local aWebCols		:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
WsChgUrl( @oObj, "MTCUSTOMERPRODUCTIONORDER.apw" )

HttpSession->PWSC146APH := { STR0010 }//"Perdas"
HttpSession->PWSC146INFO := {}

aOP := Separa( HttpPost->cOP, "|" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cCUSTOMERID,cPOID,cPOITEM,cPOSEQUENCE
If oObj:BRWPOLOSS()
	HttpSession->PWSC146RESULT := { oObj:oWSBRWPOLOSSRESULT:oWSPOLOSSVIEW }

	If ExistBlock( "PEC146" )
		aWebCols := ExecBlock( "PEC146", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWSC146INFO, ;
					HttpSession->PWSC141HEADER[3][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC146INFO, ;
					HttpSession->PWSC141HEADER[3][1], ;
					HttpSession->PWSC146RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC146" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
Function PrimDataSem( dData )

Local nDia := Dow( dData )
Local dPrimData := dData - ( nDia - 1 )

Return dPrimData

/**************************************************************************************************/
Function SetDatas( cPOID, lCustomer, lRetorno )

Local oObj

DEFAULT lCustomer := .T.
DEFAULT lRetorno := .T.

If lCustomer
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCTIONORDER' ), WSMTCUSTOMERPRODUCTIONORDER():New() )
	WsChgUrl( @oObj, "MTCUSTOMERPRODUCTIONORDER.apw" )

	oObj:cUSERCODE 		:= GetUsrCode()
	oObj:cCUSTOMERID 	:= HttpSession->CODCLIERP
	oObj:cPOID			:= cPOID
	oObj:cPOITEM		:= ""
	oObj:cPOSEQUENCE	:= ""
Else
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCTIONORDER' ), WSMTPRODUCTIONORDER():New() )
	WsChgUrl( @oObj, "MTPRODUCTIONORDER.apw" )

	oObj:cUSERCODE 		:= GetUsrCode()
	oObj:cPOID			:= cPOID
	oObj:cPOITEM		:= ""
	oObj:cPOSEQUENCE	:= ""
EndIf

//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
If oObj:GETPRODUCTIONORDER()
	nPos := aScan( HttpSession->aDatas, { |x| AllTrim( x[1] ) == AllTrim( cPOID ) } )

	If nPos == 0
		nPosPrim := aScan( HttpSession->aSemanas, { |x| x == PrimDataSem( oObj:oWSGETPRODUCTIONORDERRESULT:dSTARTFORECASTDATE ) } )
		
		If nPosPrim == 0
			aAdd( HttpSession->aSemanas, PrimDataSem( oObj:oWSGETPRODUCTIONORDERRESULT:dSTARTFORECASTDATE ) )
		EndIf
		
		nPosUlt := aScan( HttpSession->aSemanas, { |x| x == PrimDataSem( oObj:oWSGETPRODUCTIONORDERRESULT:dFINISHFORECASTDATE ) } )
	
		If nPosUlt == 0
			aAdd( HttpSession->aSemanas, PrimDataSem( oObj:oWSGETPRODUCTIONORDERRESULT:dFINISHFORECASTDATE ) )
		EndIf
	
		aAdd( HttpSession->aDatas, { cPOID, ;
			PrimDataSem( oObj:oWSGETPRODUCTIONORDERRESULT:dSTARTFORECASTDATE ), ;
			PrimDataSem( oObj:oWSGETPRODUCTIONORDERRESULT:dFINISHFORECASTDATE ), ;
			oObj:oWSGETPRODUCTIONORDERRESULT:dSTARTFORECASTDATE, ;
			oObj:oWSGETPRODUCTIONORDERRESULT:dFINISHFORECASTDATE,;
			oObj:oWSGETPRODUCTIONORDERRESULT:dSTARTFORECASTDATE + ;
				Int( ( oObj:oWSGETPRODUCTIONORDERRESULT:nQuantityProduced + ;
					oObj:oWSGETPRODUCTIONORDERRESULT:nQuantityLoss ) / ;
					( oObj:oWSGETPRODUCTIONORDERRESULT:nQuantity / ;
					( ( oObj:oWSGETPRODUCTIONORDERRESULT:dFINISHFORECASTDATE - ;
					oObj:oWSGETPRODUCTIONORDERRESULT:dSTARTFORECASTDATE ) + 1 ) ) ) } )
	EndIf
Else
	lRetorno := .F.
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC140.APW" )//"Erro"
EndIf

lRetorno := .T.

Return lRetorno

/**************************************************************************************************/
Function TransDataGraf( dData )

Local aMes := { STR0011, STR0012, STR0013, STR0014, STR0015, STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0022 }//"Jan.","Fev.","Mar.","Abr.","Mai.","Jun.","Jul.","Ago.","Set.","Out.","Nov.",
Local cData := DToS( dData )

cData := SubStr( cData, 7, 2 ) + " " + aMes[Month( dData )] + " " + SubStr( cData, 1, 4 )

Return cData

/**************************************************************************************************/
Function InsSemana( aSemanas )

Local nDiasSem		:= 0
Local nI 			:= 1
Local nSemaforo		:= 1

Do While nSemaforo == 1
	If nI < Len( aSemanas )
		nDiasSem := aSemanas[nI + 1] - aSemanas[nI]
		
		If nDiasSem > 7
			aSize( aSemanas, Len( aSemanas ) + 1 )
			aIns( aSemanas, nI + 1 )
			aSemanas[nI + 1] := aSemanas[nI] + 7
		EndIf
	Else
		nSemaforo := 0
	EndIf
	
	nI++
EndDo

Return