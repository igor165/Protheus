#INCLUDE "PWSC060.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC060   ºAutor  ³ Microsiga           º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Selecao de Cliente - Para estatistica de vendas     º±±
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
Web Function PWSC060()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSC060CLI	:= GetUserCli()

HttpSession->PWSC060APH := {	STR0001 ,;	// Processamento de Pedidos //"Estatistica de vendas"
										"W_PWSC061.APW"	,;				// Proxima Tela
										""	} 									// Msg de Erro

If Len( HTTPPOST->PWSC060CLI ) <= 1
	
	HttpSession->PWSC060APH[3] := STR0002 //"Não há clientes a consultar."
	cHtml += ExecInPage( "PWSC060" )
	
ElseIf Len( HTTPPOST->PWSC060CLI ) == 2
	
	// Apenas 1 cliente . Define a navegação para pular a tela de seleção de cliente
	
	HTTPPOST->CODCLIERP	:= HTTPPOST->PWSC060CLI[2][2]
	
	cHtml += W_PWSC061()
	
Else
	
	// Mais de 1 cliente ? Chama tela de seleção de CLientes
	
	cHtml += ExecInPage( "PWSC060" )
	
EndIf

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC061   ºAutor  ³ Microsiga           º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para chamar Grid de Produtos com a busca             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³14/06/07³126832³Alteracao no aWebCols para permitir consulta º±±
±±º          ³        ³      ³F3 no campo Produto (PRODUCTCODE).           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC061()

Local cHtml		:= ""							//Pagina HTML
Local aWebCols	:= {}							//Array com os campos a serem apresentados
Local oObj		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMtProduct' ), WSMtProduct():New() )	//Objeto WS - MTPRODUCT
Local oIndex	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )	//Objeto WS - CFGDICTIONARY

Private cMsg := ""								//Mensagem
Private aJsGrid := {}							//Array do Grid

HTTPPost->_BrwProducts := {}

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl(@oObj,"MtProduct.apw")
WsChgUrl(@oIndex,"CFGDICTIONARY.apw")

If !Empty(HTTPPOST->CODCLIERP)
	HttpSession->ETCLIERP := HTTPPOST->CODCLIERP
EndIf

If Empty( HttpSession->Head060_1 ) .OR. Empty( HttpSession->Head060_2 ) .OR. Empty( HttpSession->Index060_1 )
	If oObj:GetHeader("PRODUCTVIEW")
		HttpSession->Head060_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf

	If oIndex:GETHEADER( "GENERICSTRUCT" )
		HttpSession->Head060_2 := oIndex:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf

	If oIndex:GETINDEX( GetUsrCode(), "SB1" )
		HttpSession->Index060_1 := oIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If HttpPost->CPRODUCTCODE == Nil .OR. HttpPost->CTYPEOFPRODUCT == Nil
	HttpSession->_Busca := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
	If ExistBlock( "PEC061" )
		aWebCols := ExecBlock( "PEC061", .F., .F., {1} )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "PRODUCTCODE", "N", { "GETCATALOG", ;
												{ "CPRODUCTCODE", "CPRODUCTCODE" } }, ;
												{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
													{ "CGROUPOFPRODUCT", "CGROUPCODE" };
													}, ;
													{ "CGROUPCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
													{ "CTYPEOFPRODUCT", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
	EndIf

	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->_Busca, HttpSession->Head060_1, aWebCols )

	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEx( {  HttpSession->_Busca, ;
				HttpSession->Head060_1, ;
				MTPRODUCT_PRODUCTVIEW():New(), ;
				aWebCols, .T. ,"A",,0 } )

	aWebCols := {}

	If ExistBlock( "PEC061" )
		aWebCols := ExecBlock( "PEC061", .F., .F., {2} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "CODE" )
	EndIf

	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->_Busca, HttpSession->Head060_2, aWebCols )

	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"
	HTTPPost->_030TEMPCTR := "1"
Else
	//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GetCatalog(GetUsrCode(), HttpPost->CTYPEOFPRODUCT, HttpPost->CGROUPOFPRODUCT, IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" ), IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" ), 50, 0, "", IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, ) )
		HttpSession->PWSC060INFO := oObj:oWSGETCATALOGRESULT:OWSPRODUCTVIEW
	Else
		cMsg := PWSGetWSError()
	EndIf

EndIf

If !Empty(HttpSession->PWSC060INFO)
		
	If ExistBlock( "PEC061" )
		aWebCols := ExecBlock( "PEC061", .F., .F., {3} )
	Else
		aWebCols := {}
		aadd( aWebCols, "PRODUCTCODE" )
		aadd( aWebCols, "DESCRIPTION" )
	EndIf

		GridHeader(	HTTPPost->_BrwProducts ,;
						HttpSession->Head060_1 ,;
						aWebCols )
	
		GridLinesEx( { 	HTTPPost->_BrwProducts ,;
						HttpSession->Head060_1,;
						HttpSession->PWSC060INFO, ;
						aWebCols, .F., "A",, 0 } )
	
EndIf

cHtml += ExecInPage( "PWSC061" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC062   ºAutor  ³ Microsiga           º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para mostrar os parametros da estatistica de vendas  º±±
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
Web Function PWSC062()

Local cHtml := ""

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->radio )
	HttpSession->ETCODPRT := HttpPost->radio
EndIf

cHtml += ExecInPage( "PWSC062" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC063   ºAutor  ³ Microsiga           º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para mostrar a tela de estatistica de vendas		   º±±
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
Web Function PWSC063()

Local cHtml := ""
Local aWebCols := {}
Local oWS := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTCUSTOMERSALESSUMMARY' ), WSFTCUSTOMERSALESSUMMARY():NEW() )

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl(@oWS,"FTCUSTOMERSALESSUMMARY.apw")

HTTPPost->BrwEstVend := {}

If Empty( HttpSession->PWS060HEADER )
	If oWS:GETHEADER("VALUESUMMARY")
		HttpSession->PWS060HEADER := oWS:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf
                           
If ExistBlock( "PEC063" )
	aWebCols := ExecBlock( "PEC063", .F., .F., {1} )
Else
	aWebCols := {}
	aadd( aWebCols, "CODE" )
	aadd( aWebCols, "DESCRIPTION" )
	aadd( aWebCols, "VALUE"	)
EndIf

GridHeader(	HTTPPost->BrwEstVend ,;
HttpSession->PWS060HEADER ,;
aWebCols )

If oWS:GETRETURNINVOICE( GetUsrCode(), HttpSession->ETCLIERP, CtoD(HttpPost->DataDe), CtoD(HttpPost->DataAte), "", "", HttpSession->ETCODPRT, Val(HttpPost->Moeda) )
	     
	If ExistBlock( "PEC063" )
		aWebCols := ExecBlock( "PEC063", .F., .F., {2} )
	Else
		aWebCols := {}
		aadd( aWebCols, "CODE" )
		aadd( aWebCols, "DESCRIPTION" )
		aadd( aWebCols, "VALUE"	)
	EndIf
	
	GridLinesEx( {	HTTPPost->BrwEstVend ,;
	HttpSession->PWS060HEADER,;
	oWS:oWSGETRETURNINVOICERESULT:OWSGENERICSTRUCT ,;
	aWebCols, .F., "A",, 0 } )
	
Else
	cMsg := PWSGetWSError()
EndIf

If oWS:GETSALESINVOICE( GetUsrCode(), HttpSession->ETCLIERP, CtoD(HttpPost->DataDe), CtoD(HttpPost->DataAte), "", "", HttpSession->ETCODPRT, Val(HttpPost->Moeda), "" )
	                                                  
	If ExistBlock( "PEC063" )
		aWebCols := ExecBlock( "PEC063", .F., .F., {3} )
	Else
		aWebCols := {}
		aadd( aWebCols, "CODE" )
		aadd( aWebCols, "DESCRIPTION" )
		aadd( aWebCols, "VALUE"	)
	EndIf
	
	GridLinesEx( {	HTTPPost->BrwEstVend ,;
	HttpSession->PWS060HEADER,;
	oWS:oWSGETSALESINVOICERESULT:OWSGENERICSTRUCT ,;
	aWebCols, .F., "A",, 0 } )
	
Else
	cMsg := PWSGetWSError()
EndIf

If oWS:GETSALESORDER( GetUsrCode(), HttpSession->ETCLIERP, CtoD(HttpPost->DataDe), CtoD(HttpPost->DataAte), "", "", HttpSession->ETCODPRT, Val(HttpPost->Moeda), "" )
	                       
	If ExistBlock( "PEC063" )
		aWebCols := ExecBlock( "PEC063", .F., .F., {4} )
	Else
		aWebCols := {}
		aadd( aWebCols, "CODE" )
		aadd( aWebCols, "DESCRIPTION" )
		aadd( aWebCols, "VALUE"	)
	EndIf
	
	GridLinesEx( {	HTTPPost->BrwEstVend ,;
	HttpSession->PWS060HEADER,;
	oWS:oWSGETSALESORDERRESULT:OWSGENERICSTRUCT ,;
	aWebCols, .F., "A",, 0 } )
	
Else
	cMsg := PWSGetWSError()
EndIf

cHtml += ExecInPage( "PWSC063" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MntMoeda  ºAutor  ³ Microsiga           º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar as moedas do sistema				   º±±
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
Function MntMoeda()

Local nI	:=  0
Local nTam	:= 0
Local oWS	:= Nil

If Empty( HttpSession->WS_MOEDA )
	
	oWS := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCURRENCY' ), WSMTCURRENCY():NEW() )
	
	WsChgUrl(@oWS,"MTCURRENCY.apw")
	
	HttpSession->WS_MOEDA := {}
	
	If oWS:GETHEADER()
		aAdd( HttpSession->WS_MOEDA, { oWS:oWSGETHEADERRESULT:OWSBRWHEADER[1]:CHEADERTITLE, ;
		oWS:oWSGETHEADERRESULT:OWSBRWHEADER[2]:CHEADERTITLE } )
	Else
		Return HttpSession->WS_MOEDA
	EndIf
	
	If oWS:GETCURRENCY( GetUsrCode() )
		nTam := Len( oWS:oWSGETCURRENCYRESULT:OWSGENERICSTRUCT )
		For nI := 1 To nTam
			aAdd( HttpSession->WS_MOEDA, { oWS:oWSGETCURRENCYRESULT:OWSGENERICSTRUCT[nI]:CCODE, ;
			oWS:oWSGETCURRENCYRESULT:OWSGENERICSTRUCT[nI]:CDESCRIPTION } )
		Next
	Else
		Return HttpSession->WS_MOEDA
	EndIf
	
EndIf

Return HttpSession->WS_MOEDA

