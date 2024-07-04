#INCLUDE "PWSV080.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV080  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de Selecao de vendedor para processamento de orçamentos º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV080()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := {	STR0001 ,;	// Processamento de Orcamentos //"Processamento de Orçamentos"
										"W_PWSV081.APW"	,;				// Proxima Tela
										"" ,;	 								// Msg de Erro
										"80" }								// Função chamadora
										
HttpSession->FONTES := {"W_PWSV080.APW","W_PWSV082.APW"}
	
If Len(HTTPPOST->PWSV020VEN) <= 1   
	HttpSession->PWSV020APH[3] := STR0002 //"Nao ha vendedors a consultar."

	cHtml += ExecInPage( "PWSV020" )
ElseIF Len(HTTPPOST->PWSV020VEN) = 2
	// Apenas 1 vendedor . Define a navegacao para pular a tela de selecao de vendedor
	HTTPPOST->CODVENERP	:= HTTPPOST->PWSV020VEN[2][2]
	
	cHtml += W_PWSV081()
Else
	// Mais de 1 vendedor ? Chama tela de seleção de vendedors
	cHtml += ExecInPage( "PWSV020" )
Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV081  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para escolha de orcamentos			   		 	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV081()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERBUDGET' ), WSMTSELLERBUDGET():NEW() )
WsChgUrl(@oObj,"MTSELLERBUDGET.apw")

If !Empty( HttpPost->CODVENERP )
	HttpSession->CODVENERP := HttpPost->CODVENERP
EndIf

If Empty( HttpSession->PWSV082HEADER )
	HttpSession->PWSV082HEADER := { {}, {} }
	
	If oObj:GETHEADER( "BUDGETHEADERVIEW" )
		HttpSession->PWSV082HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0011, "", "W_PWSV080.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "BUDGETITENSVIEW" )
		HttpSession->PWSV082HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0011, "", "W_PWSC080.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSV084GRAVA := {}
HttpSession->PWSV081APH := { STR0001, "W_PWSV082.APW", "W_PWSV084.APW" }//"Processamento de Orçamentos"

cHtml += ExecInPage( "PWSV081" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV082   ºAutor  ³Microsiga            º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para escolha de orcamentos		   					   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³04/04/06³95211 ³- Corrigida a situacao em que estava conca-  º±±
±±º          ³        ³      ³tenando incorretamente 2 variaveis c/ tipos  º±±
±±º          ³        ³      ³diferentes.                                  º±±
±±ºNorbert W.³01/08/07³128328³- Incluido o campo loja na consulta de orca- º±±
±±º          ³        ³      ³mentos                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV082()

Local cHtml 	:= ""			//Pagina Web
Local oObj						//Objeto WS - WSMTSELLERBUDGET
Local oObjTotalSO				//Objeto WS - WSMTSELLERBUDGET
Local aWebCols 	:= {}			//Array contendo os campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERBUDGET' ), WSMTSELLERBUDGET():NEW() )
oObjTotalSO := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERBUDGET' ), WSMTSELLERBUDGET():NEW() )

WsChgURL( @oObj		  , "MTSELLERBUDGET.APW" )
WsChgURL( @oObjTotalSO, "MTSELLERBUDGET.APW" )

HttpSession->PWSV082APH := { STR0014, "W_PWSV083.APW" }//"Resultado Busca"

If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
EndIf

If ( !Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) ) .OR. ;
	( !Empty( HttpGet->cCUSTOMERUNITFROM ) .AND. !Empty( HttpGet->cCUSTOMERUNITTO ) ) .AND.;
	( !Empty( HttpGet->cCUSTOMERFROM ) .AND. !Empty( HttpGet->cCUSTOMERTO ) )
	
	HttpPost->dREGISTERDATEFROM := HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 	:= HttpGet->dREGISTERDATETO
	HttpPost->cCUSTOMERFROM 	:= HttpGet->cCUSTOMERFROM     
	HttpPost->cCUSTOMERUNITFROM := HttpGet->cCUSTOMERUNITFROM     	
	HttpPost->cCUSTOMERTO 		:= HttpGet->cCUSTOMERTO
	HttpPost->cCUSTOMERUNITTO 	:= HttpGet->cCUSTOMERUNITTO
EndIf

oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO	:= CToD( HttpPost->dREGISTERDATETO )
oObj:cINDEXKEY			:= "CJ_NUM"
oObj:nPAGELEN			:= 10
oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

oObjTotalSO:cUSERCODE			:= GetUsrCode()
oObjTotalSO:cSELLERCODE			:= HttpSession->CODVENERP
oObjTotalSO:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObjTotalSO:dREGISTERDATETO		:= CToD( HttpPost->dREGISTERDATETO )

If !Empty( HttpPost->cBuscaAv )
	Do Case
		Case HttpPost->cComboAv == "1"
			oObj:cQUERYADDWHERE			:= "SCJ.CJ_NUM='" + HttpPost->cBuscaAv + "'"
			oObjTotalSO:cQUERYADDWHERE	:= "SCJ.CJ_NUM='" + HttpPost->cBuscaAv + "'"
		Case HttpPost->cComboAv == "2"
			oObj:cQUERYADDWHERE			:= "SCJ.CJ_COTCLI='" + HttpPost->cBuscaAv + "'"
			oObjTotalSO:cQUERYADDWHERE	:= "SCJ.CJ_COTCLI='" + HttpPost->cBuscaAv + "'"
	EndCase
Else
	If !Empty(AllTrim(HttpPost->cCUSTOMERFROM)) .AND. !Empty(AllTrim(HttpPost->cCUSTOMERTO))
		oObj:cQUERYADDWHERE			:= "CJ_CLIENTE>='"+HttpPost->cCUSTOMERFROM+"' AND "+"CJ_CLIENTE<='"+HttpPost->cCUSTOMERTO+"' AND "+"CJ_LOJA>='"+HttpPost->cCUSTOMERUNITFROM+"' AND "+"CJ_LOJA<='"+HttpPost->cCUSTOMERUNITTO+"'"
		oObjTotalSO:cQUERYADDWHERE	:= "CJ_CLIENTE>='"+HttpPost->cCUSTOMERFROM+"' AND "+"CJ_CLIENTE<='"+HttpPost->cCUSTOMERTO+"' AND "+"CJ_LOJA>='"+HttpPost->cCUSTOMERUNITFROM+"' AND "+"CJ_LOJA<='"+HttpPost->cCUSTOMERUNITTO+"'"
	Else
		oObj:cQUERYADDWHERE			:= ""
		oObjTotalSO:cQUERYADDWHERE	:= ""
	EndIf
EndIf

//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,cQUOTATIONORORDERIDFROM,cQUOTATIONORORDERIDTO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
If oObj:BRWBUDGET()
	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,cQUOTATIONORORDERIDFROM,cQUOTATIONORORDERIDTO,cQUERYADDWHERE
		If oObjTotalSO:BRWTOTALBUDGET()
			HttpSession->nTotalSO := oObjTotalSO:nBRWTOTALBUDGETRESULT
		Else
			Return PWSHTMLALERT( "", STR0011, "", "W_PWSV080.APW" )//"Erro"
		EndIf
	EndIf

	HttpSession->PWSV082RESULT := { oObj:oWSBRWBUDGETRESULT:oWSBUDGETHEADERVIEW }
	HttpSession->PWSV082INFO := {}

	If ExistBlock( "PEV082" )
		aWebCols := ExecBlock( "PEV082", .F., .F., {} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "BUDGETID" )
		aAdd( aWebCols, "QUOTATIONORORDERID" )
		aAdd( aWebCols, "DESCRIPTIONSTATUS" )
	EndIf

	GridHeader(	HttpSession->PWSV082INFO, ;
					HttpSession->PWSV082HEADER[1][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSV082INFO, ;
					HttpSession->PWSV082HEADER[1][1], ;
					HttpSession->PWSV082RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0011, "", "W_PWSV080.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSV082" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV083  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para detalhes de de orcamentos			   		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV083()

Local cHtml 	:= ""
Local oObj
Local aWebCols 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV083APH := { STR0008 + HttpGet->cOrcamento, "W_PWSV082.APW" }//"Orçamento Número : "

oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERBUDGET' ), WSMTSELLERBUDGET():NEW() )
WsChgUrl(@oObj,"MTSELLERBUDGET.apw")

oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cBUDGETID		:= HttpGet->cOrcamento

If oObj:GETBUDGET()
	HttpSession->PWSV083RESULT := { oObj:oWSGETBUDGETRESULT }
	HttpSession->PWSV083INFO := { {}, {} }
	
	If ExistBlock( "PEV083" )
		aWebCols := ExecBlock( "PEV083", .F., .F., { 1 } )
	Else
		aWebCols := {}
	EndIf

	GridLinesEx( { HttpSession->PWSV083INFO[1], ;
					HttpSession->PWSV082HEADER[1][1], ;
					HttpSession->PWSV083RESULT[1]:oWSHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTSELLERBUDGET", "SCJ" )

	If ExistBlock( "PEV083" )
		aWebCols := ExecBlock( "PEV083", .F., .F., { 2 } )
	Else
		aWebCols := {}
	EndIf

	GridHeader(	HttpSession->PWSV083INFO[2], ;
					HttpSession->PWSV082HEADER[2][1], ;
					aWebCols, HttpSession->PWSV083RESULT[1]:oWSITENS:oWSBUDGETITENSVIEW, "MTSELLERBUDGET", "SCK" )

	GridLinesEx( { HttpSession->PWSV083INFO[2], ;
					HttpSession->PWSV082HEADER[2][1], ;
					HttpSession->PWSV083RESULT[1]:oWSITENS:oWSBUDGETITENSVIEW, ;
					aWebCols, .F., "A",, 0 }, "MTSELLERBUDGET", "SCK" )
Else
	Return PWSHTMLALERT( "", STR0011, "", "W_PWSV080.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSV083" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV083A  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para detalhes de Orcamentos            			   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV083A()
Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSV083A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV084  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao e alteracao de orcamentos			   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV084()

Local cHtml 	:= ""
Local aWebCols 	:= {}
Local oObj
Local nI		:= 0

WEB EXTENDED INIT cHtml START "InSite"

oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERBUDGET' ), WSMTSELLERBUDGET():NEW() )
WsChgURL( @oObj, "MTSELLERBUDGET.APW" )

HttpSession->PWSV084APH := { STR0015, "" }//"Inclusão Orçamento"
HttpSession->PWSV084INFO := { {}, {} }

//Limpa a variável de sessão do Pedido de Venda para não interferir na busca de produtos genérica do Orçamento
If !(Empty(HttpSession->PWSV044GRAVA))
	HttpSession->PWSV044GRAVA := {}
EndIf

If HttpPost->cAcao == "A"
    HttpSession->lInclusao := .F.    
	HttpPost->cAcao := "I"
	HttpSession->nTotalOrc := 0
	
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cSELLERCODE	:= HttpSession->CODVENERP
	oObj:cBUDGETID		:= HttpPost->cOrcamento
	
	If oObj:GETBUDGET()
		HttpSession->PWSV084GRAVA := { ,{} }
		HttpSession->PWSV084GRAVA[1] := oObj:oWSGETBUDGETRESULT:oWSHEADER

		For nI := 1 To Len( oObj:oWSGETBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW )
			aAdd( HttpSession->PWSV084GRAVA[2], MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
			HttpSession->PWSV084GRAVA[2][nI] := oObj:oWSGETBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW[nI]
			HttpSession->nTotalOrc += HttpSession->PWSV084GRAVA[2][nI]:nNETTOTAL
		Next nI
	Else
		Return PWSHTMLALERT( "", STR0011, "", "W_PWSV050.APW" )//"Erro"
	EndIf
Else
    If(HttpPost->cAcao <> Nil)
		HttpSession->lInclusao := .T.
	EndIf
	If Empty( HttpSession->PWSV084GRAVA )
		HttpSession->nTotalOrc := 0

		oObj := MTSELLERBUDGET_BUDGETHEADERVIEW():New()

		oObj:dREGISTERDATE	 	:= Date()
		oObj:dEXPIRATIONDATE	:= Date()
	
		HttpSession->PWSV084GRAVA := { oObj, { MTSELLERBUDGET_BUDGETITENSVIEW():New() } }
	EndIf
EndIf

If HttpPost->cAcao == "I" .AND. Empty( HttpSession->cAcao )
	HttpSession->cAcao := "I"
EndIf

If HttpSession->cAcao == "I"
	If ExistBlock( "PEV084" )
		aWebCols := ExecBlock( "PEV084", .F., .F., { 1 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "BUDGETID", "D" } )
		aAdd( aWebCols, { "REGISTERDATE", "D" } )
		If HttpSession->lInclusao
		aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
														{ "CCUSTOMERCODE", "CCODE" }, ;
														{ "CCUSTOMERUNIT", "CUNIT" } ;
													}, ;
													{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, { "DELIVERYCUSTOMER", "N", { "BRWCUSTOMER", ;
														{ "CDELIVERYCUSTOMER", "CCODE" }, ;
														{ "CDELIVERYUNITCODE", "CUNIT" } ;
													}, ;
													{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DELIVERYUNITCODE" )
		Else
			aAdd( aWebCols, { "CUSTOMERCODE", "D" } )
			aAdd( aWebCols, { "CUSTOMERUNIT", "D" } )
			aAdd( aWebCols, { "DELIVERYCUSTOMER", "D" } )
			aAdd( aWebCols, { "DELIVERYUNITCODE", "D" } )
		EndIf	
		aAdd( aWebCols, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
																{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
															}, ;
															{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		aAdd( aWebCols, { "PRICELISTCODE", "D" } )
		aAdd( aWebCols, { "DISCOUNT1", "D" } )
		aAdd( aWebCols, { "DISCOUNT2", "D" } )
		aAdd( aWebCols, { "DISCOUNT3", "D" } )
		aAdd( aWebCols, { "DISCOUNT4", "D" } )
		aAdd( aWebCols, "QUOTATIONORORDERID" )
		aAdd( aWebCols, { "FREIGHTVALUE", "D" } )
		aAdd( aWebCols, { "INSURANCEVALUE", "D" } )
		aAdd( aWebCols, { "ADDITIONALEXPENSEVALUE", "D" } )
		aAdd( aWebCols, { "INDEPENDENTFREIGHT", "D" } )
		aAdd( aWebCols, { "EXPIRATIONDATE", "D" } )
		aAdd( aWebCols, { "INDEMNITYVALUE", "D" } )
		aAdd( aWebCols, { "INDEMNITYPERCENTAGE", "D" } )
		aAdd( aWebCols, { "DESCRIPTIONSTATUS", "D" } )
	EndIf
	
	GridLinesEx( { HttpSession->PWSV084INFO[1], ;
					HttpSession->PWSV082HEADER[1][1], ;
					HttpSession->PWSV084GRAVA[1], ;
					aWebCols, .T., "H",, 1 }, "MTSELLERBUDGET", "SCJ" )
	
	aWebCols := {}

	If ExistBlock( "PEV084" )
		aWebCols := ExecBlock( "PEV084", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG", ;
														{ "CPRODUCTID", "CPRODUCTCODE" } ,;
														{ "CPRODUCTDESCRIPTION", "CDESCRIPTION"} ;
													}, ;
													{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		aAdd( aWebCols, { "PRODUCTDESCRIPTION", "N", 30, .T. } )
		aAdd( aWebCols, { "QUANTITY", "N", 3 } )
		aAdd( aWebCols, { "NETUNITPRICE", "N", 9, .T. } )
		aAdd( aWebCols, { "CUSTOMERBUDGETID", "N", 5 } )
		aAdd( aWebCols, { "NETTOTAL", "N", 0, .F. } )
	EndIf
	
	For nI := 1 To Len( HttpSession->PWSV084GRAVA[2] )
		If nI == 1
			GridHeader(	HttpSession->PWSV084INFO[2], ;
								HttpSession->PWSV082HEADER[2][1], ;
								aWebCols, HttpSession->PWSV084GRAVA[2][nI], "MTSELLERBUDGET", "SCK" )
		EndIf

		GridLinesEx( { HttpSession->PWSV084INFO[2], ;
						HttpSession->PWSV082HEADER[2][1], ;
						HttpSession->PWSV084GRAVA[2][nI], ;
						aWebCols, .T., "H", AllTrim( Str( nI ) ), ;
						IIf( nI == Len( HttpSession->PWSV084GRAVA[2] ), 3, 2 ), .T. }, "MTSELLERBUDGET", "SCK" )
	Next nI
EndIf

cHtml += ExecInPage( "PWSV084" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV085  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao e alteracao de orcamentos			   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV085()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->cItem )
	If Len( HttpSession->PWSV084GRAVA[2] ) > 1
		aDel( HttpSession->PWSV084GRAVA[2], Val( HttpPost->cItem ) )
		aSize( HttpSession->PWSV084GRAVA[2], Len( HttpSession->PWSV084GRAVA[2] ) - 1 )
	EndIf
Else
	PWSSetObjToPost( HttpSession->PWSV084GRAVA[1], HttpSession->PWSV082HEADER[1][1], HttpPost->aPost )
	
	nTam := Len( HttpSession->PWSV084GRAVA[2] )
	PWSSetObjToPost( HttpSession->PWSV084GRAVA[2][nTam], HttpSession->PWSV082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nTam ) ) )
	aAdd( HttpSession->PWSV084GRAVA[2], MTSELLERBUDGET_BUDGETITENSVIEW():New() )
EndIf

cHtml += W_PWSV084()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV086  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao e alteracao de orcamentos			   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV086()

Local cHtml 	:= ""
Local oObj
Local nI		:= 0
Local nPos//Serv

Private aProp 	:={} //Serv

WEB EXTENDED INIT cHtml START "InSite"

oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSIMULATIONBUDGET' ), WSMTSIMULATIONBUDGET():NEW() )
WsChgURL( @oObj, "MTSIMULATIONBUDGET.APW" )

//Forçar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV084GRAVA[1], "SCJ", "MTSELLERBUDGET" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV084GRAVA[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSV084GRAVA[1], HttpSession->PWSV082HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSV084GRAVA[2] )
For nI := 1 To nTam
	//Forçar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSV084GRAVA[2][nI], "SCK", "MTSELLERBUDGET" )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSV084GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSV084GRAVA[2][nI], HttpSession->PWSV082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSV084GRAVA[2][nI]:cBUDGETITEM := StrZero( nI, 2 )
Next nI

oObj:cUSERCODE			:= "MSALPHA"
oObj:oWSOLDBUDGET := MTSIMULATIONBUDGET_BUDGETVIEW():New()
oObj:oWSOLDBUDGET:oWSHEADER	:= HttpSession->PWSV084GRAVA[1]
oObj:oWSOLDBUDGET:oWSITENS	:= MTSIMULATIONBUDGET_ARRAYOFBUDGETITENSVIEW():New()

For nI := 1 To Len( HttpSession->PWSV084GRAVA[2] )
	aAdd( oObj:oWSOLDBUDGET:oWSITENS:oWSBUDGETITENSVIEW, MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
	oObj:oWSOLDBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI] := HttpSession->PWSV084GRAVA[2][nI]
Next nI

If oObj:PUTBUDGET()
    Iif(httpPost->CBUDGETID_H<>Nil,oObj:oWSPUTBUDGETRESULT:oWSHEADER:CBUDGETID:=httpPost->CBUDGETID_H,oObj:oWSPUTBUDGETRESULT:oWSHEADER:CBUDGETID:="")
	HttpSession->PWSV084GRAVA[1] := oObj:oWSPUTBUDGETRESULT:oWSHEADER

	HttpSession->PWSV084GRAVA[2] := {}
	HttpSession->nTotalOrc := 0
	For nI := 1 To Len( oObj:oWSPUTBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW )
		aAdd( HttpSession->PWSV084GRAVA[2], MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
		HttpSession->PWSV084GRAVA[2][nI] := oObj:oWSPUTBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW[nI]
		HttpSession->nTotalOrc += HttpSession->PWSV084GRAVA[2][nI]:nNETTOTAL
	Next nI
Else
	Return PWSHTMLALERT( "", STR0011, "", "W_PWSV084.APW" )//"Erro"
EndIf

cHtml += W_PWSV084()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSV087  ºAutor  ³Luiz Felipe Couto    º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao e alteracao de orcamentos			   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³25/04/07|124858|Corrigido o preenchimento com os campos de   º±±
±±º          ³        ³      ³usuario e retirada a funcao SetObj.	       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV087()

Local cHtml 	:= ""		//Pagina HTML
Local oObj		:= Nil		//Objeto WS - MTSELLERBUDGET
Local nI		:= 0		//Usada em lacos For...Next

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERBUDGET' ), WSMTSELLERBUDGET():NEW() )
WsChgURL( @oObj, "MTSELLERBUDGET.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche a session com os campos de usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSPutUsrFld( HttpSession->PWSV084GRAVA[1], "SCJ", "MTSELLERBUDGET" )
PWSSetObjToPost( HttpSession->PWSV084GRAVA[1], HttpSession->PWSV082HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSV084GRAVA[2] )
For nI := 1 To nTam
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenche a session com os campos de usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PWSPutUsrFld( HttpSession->PWSV084GRAVA[2][nI], "SCK", "MTSELLERBUDGET" )
	PWSSetObjToPost( HttpSession->PWSV084GRAVA[2][nI], HttpSession->PWSV082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSV084GRAVA[2][nI]:cBUDGETITEM := StrZero( nI, 2 )
Next nI

oObj:cUSERCODE				:= "MSALPHA"
oObj:cSELLERCODE			:= HttpSession->CODVENERP
oObj:oWSBUDGET 				:= MTSELLERBUDGET_BUDGETVIEW():New()
If HttpSession->lInclusao
	If oObj:GetNextNumber() 
    HttpSession->PWSV084GRAVA[1]:CBUDGETID :=oObj:cGETNEXTNUMBERRESULT
	EndIf
EndIf
oObj:oWSBUDGET:oWSHEADER	:= HttpSession->PWSV084GRAVA[1]
oObj:oWSBUDGET:oWSITENS		:= MTSELLERBUDGET_ARRAYOFBUDGETITENSVIEW():New()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o objeto com os dados dos itens ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSV084GRAVA[2] )
	aAdd( oObj:oWSBUDGET:oWSITENS:oWSBUDGETITENSVIEW, MTSELLERBUDGET_BUDGETITENSVIEW():New() )
	oObj:oWSBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI] := HttpSession->PWSV084GRAVA[2][nI]
	SetObj( oObj:oWSBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI], HttpSession->PWSV082HEADER[2][1], ;
			HttpSession->PWSV084GRAVA[2][nI] )
Next nI

//cUSERCODE,cSELLERCODE,oWSBUDGET
If oObj:PUTBUDGET()
	Return PWSHTMLALERT( "", STR0016, STR0008 + oObj:cPUTBUDGETRESULT + " " + STR0017, "W_PWSV080.APW" )//"Atenção","Orçamento Número "," cadastrado com SUCESSO!"
Else
	HttpSession->PWSV084GRAVA[1]:CBUDGETID :=""
	Return PWSHTMLALERT( "", STR0011, "", "W_PWSV084.APW" )//"Erro"
EndIf

cHtml += W_PWSV084()

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} PWSQtd084Gat
Gatilho do campo Quantidade do Orçamento no Portal do Fornecedor (PWSV084)

@author jose.eulalio

@since 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Web Function PWSQtd084Gat()
Local cHtml 	:= ""
Local oObjProd	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCT' ), WSMTPRODUCT():New() )
Local oParam	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
Local oCliente	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():New() )
Local oObj
Local nI		:= 0
Local nPos//Serv
Local nPrice		:= 0
Local nX			:= 0
Local nTam			:= 0
Local nVlrUnit	:= 0
Local cPWSUser	:= GetUsrCode()
Local lAchou		:= .F.

Private aProp 	:={} //Serv

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSIMULATIONBUDGET' ), WSMTSIMULATIONBUDGET():New() )
WsChgURL( @oObj, "MTSIMULATIONBUDGET.APW" )
WsChgUrl( @oObjProd, "MTPRODUCT.apw" )
WsChgUrl( @oParam,"CFGDICTIONARY.APW" )
WsChgUrl( @oCliente, "MTCUSTOMER.APW" )

//Forçar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV084GRAVA[1], "SCJ", "MTSELLERBUDGET" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV084GRAVA[1]:oWSuserfields := aProp[nPos][2]


PWSSetObjToPost( HttpSession->PWSV084GRAVA[1], HttpSession->PWSV082HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSV084GRAVA[2] )
For nI := 1 To nTam
	//Forçar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSV084GRAVA[2][nI], "SCK", "MTSELLERBUDGET" )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSV084GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSV084GRAVA[2][nI], HttpSession->PWSV082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSV084GRAVA[2][nI]:cBUDGETITEM := StrZero( nI, 2 )

Next nI

oObj:cUSERCODE			:= "MSALPHA"
oObj:oWSOLDBUDGET := MTSIMULATIONBUDGET_BUDGETVIEW():New()
oObj:oWSOLDBUDGET:oWSHEADER	:= HttpSession->PWSV084GRAVA[1]
oObj:oWSOLDBUDGET:oWSITENS	:= MTSIMULATIONBUDGET_ARRAYOFBUDGETITENSVIEW():New()

For nI := 1 To Len( HttpSession->PWSV084GRAVA[2] )

	lAchou := .F.
	nVlrUnit := 0
	
	aAdd( oObj:oWSOLDBUDGET:oWSITENS:oWSBUDGETITENSVIEW, MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
	oObj:oWSOLDBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI] := HttpSession->PWSV084GRAVA[2][nI]

	If !(Empty(HttpSession->PWSV084GRAVA[1]:cCustomerCode)) .Or. HttpSession->PWSV084GRAVA[2][nI]:cProductId
		
		//atualiza preço da tabela
		If oObjProd:GETPRICE( cPWSUser, HttpSession->PWSV084GRAVA[2][nI]:cProductId )
			nTam := Len(oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW)
			If oParam:GETPARAM( cPWSUser, "MV_PVTABOC" )
				cParam := oParam:cGETPARAMRESULT
				For nX := 1 to nTam
					If oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:cpricetablecode == cParam
						If nI == Len( HttpSession->PWSV084GRAVA[2] )
							HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE := oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice
						EndIf	
						lAchou		:= .T.
						Exit
					EndIf
				Next nX
			EndIf
			
			If !lAchou .And. oCliente:GETCUSTOMER( cPwsUser, HttpSession->PWSV084GRAVA[1]:cCustomerCode )
				For nX := 1 to nTam
					If oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:cpricetablecode == oCliente:oWSGETCUSTOMERRESULT:cPriceTableCode
						If nI == Len( HttpSession->PWSV084GRAVA[2] )
							HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE := oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice
						EndIf	
						lAchou := .T.
						Exit
					EndIf
				Next nX
			EndIf
			
			If !lAchou .And. oParam:GETPARAM( cPWSUser, "MV_TABPAD" )
				cParam := oParam:cGETPARAMRESULT
				For nX := 1 to nTam
					If oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:cpricetablecode == cParam
						If nI == Len( HttpSession->PWSV084GRAVA[2] )
							HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE := oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice
						EndIf	
						lAchou	:= .T.
						Exit
					EndIf
				Next nX
			EndIf
			
			If !lAchou	.And. !(Empty(oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice))
				If nI == Len( HttpSession->PWSV084GRAVA[2] )
					HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE  := oObjProd:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice //B1_PRV1
				EndIf	
				lAchou := .T.
			EndIf
			
			If !lAchou
				HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE  := 0
			ElseIf ValType(HttpSession->PWSV084GRAVA[2][nI]:nDiscountPercentage) <> "U" .And. HttpSession->PWSV084GRAVA[2][nI]:nDiscountPercentage > 0
				nVlrUnit	:= HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE 
				HttpSession->PWSV084GRAVA[2][nI]:nNETUNITPRICE := nVlrUnit - ( nVlrUnit * (HttpSession->PWSV084GRAVA[2][nI]:nDiscountPercentage / 100))  
			EndIf
			
		EndIf
	EndIf
	
Next nI

cHtml += " <script> $(document).ready( function() {"
cHtml += "	 window.location.href='#foo'});"
cHtml += " </script>"

cHtml += W_PWSV084()

WEB EXTENDED END

Return cHtml
