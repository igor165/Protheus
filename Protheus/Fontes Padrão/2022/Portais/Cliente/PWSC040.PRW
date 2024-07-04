#INCLUDE "PWSC040.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"

#DEFINE CLIENTERP_ENTIDADE		1
#DEFINE CLIENTERP_CODIGO		2
#DEFINE CLIENTERP_NOMEFANT		3
#DEFINE CLIENTERP_RAZAOSOC		4
#DEFINE CLIENTERP_CPFCNPJ		5

#DEFINE CLIENT_CADASTRO			1
#DEFINE CLIENT_ENDERECOS		2
#DEFINE CLIENT_TELEFONES		3
#DEFINE CLIENT_OBJCUSTOMER		4

#DEFINE CONTACT_CADASTRO		1
#DEFINE CONTACT_ENDERECOS		2
#DEFINE CONTACT_TELEFONES		3
#DEFINE CONTACT_OBJCONTACT 	4

#DEFINE CLIENT_TYPEOFADDRESSES	1
#DEFINE CLIENT_TYPEOFPHONES		2

#DEFINE MYUSERCODE		GetUsrCode()

/* ======================================================================

Funções Pertinentes ao Menu de Gerenciamento de Dados Cadastrais

	Alteração de Dados Cadastrais		[  ]		W_PWSC040

Aphs Envolvidos : 

	PWSC020.APH 		Seleção de Clientes
	PWSC041.APH 		Dados do Cliente , Endereços e Fones

====================================================================== */


//-------------------------------------------------------------------------------------------------------------------------
// Tela 01 : Seleção de Cliente
//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC040()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSC020CLI	:= GetUserCli()

HttpSession->PWSC020APH := {	STR0001 ,;		// Titulo  //'Gerenciamento de Informações Cadastrais'
										'W_PWSC043.APW'	,;			// Proxima Tela
										''	} 								// Msg de Erro
	
HttpSession->PWSC040APH := {	STR0002 ,;		// Titulo  //'Dados Cadastrais'
										''	} 								// Msg de Erro

If len(HTTPPOST->PWSC020CLI) <= 1   

	HttpSession->PWSC020APH[3] := STR0003 //'Não há clientes a consultar.'
	cHtml += ExecInPage( "PWSC020" )
	
ElseIF len(HTTPPOST->PWSC020CLI) = 2 

	// Apenas 1 cliente . Define a navegação para pular a tela de seleção de cliente
	
	HTTPPOST->CODCLIERP	:= HTTPPOST->PWSC020CLI[2][CLIENTERP_CODIGO]
	
	cHtml += W_PWSC043()

Else

	// Mais de 1 cliente ? Chama tela de seleção de CLientes
	
	cHtml += ExecInPage( "PWSC020" )

Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC041   ºAutor  ³ Microsiga           º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela2 : Dados Cadastrais , endereços e Telefones            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³28/03/07³120862³Alterado o nome do campo destino CSTATE ref. º±±
±±º          ³        ³      ³ao retorno da consulta F3.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC041()

Local cHtml := ""			//Pagina Web
Local oObj					//Objeto WS - MTCUSTOMER
Local nPosCli				//Posicao Cliente
Local aWebCols := {}		//Array contendo os campos que serao apresentados na tela
Local nX := 0				//Usada em lacos For...Next

Private aJsGrid := {}		//Grid JavaScript

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSC020CLI		:= GetUserCli()
HTTPPost->_CustomerInfo := { { } , { { }, { }, { } } , { { }, { } } }

If !Empty(HTTPPOST->CODCLIERP)
	
	nPosCli := ascan(HTTPPOST->PWSC020CLI , {|x| x[CLIENTERP_CODIGO] == HTTPPOST->CODCLIERP } ) 

	If nPosCli > 0 

		HttpSession->PWSC040APH[1] := STR0002+HTTPPOST->PWSC020CLI[nPosCli][CLIENTERP_RAZAOSOC] //'Dados Cadastrais : '

		oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():NEW() )
		WsChgUrl(@oObj,"MTCUSTOMER.apw")

		If empty(Httpsession->PWSC040TYPES)
			Httpsession->PWSC040TYPES := { NIL , NIL }
		Endif
		
		// Busca os tipos de Endereços 
		If empty(HttpSession->PWSC020APH[3]) .and. Httpsession->PWSC040TYPES[1] = NIL 
			If oObj:GETTYPEOFADDRESS()
				Httpsession->PWSC040TYPES[1] := oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT
			Else
				HttpSession->PWSC020APH[3] := PWSGetWSError()
			Endif
		Endif
		
		// Busca os tipos de Telefones
		If empty(HttpSession->PWSC020APH[3]) .and. Httpsession->PWSC040TYPES[2] = NIL 
			If oObj:GETTYPEOFPHONE()
				Httpsession->PWSC040TYPES[2] := oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT
			Else
				HttpSession->PWSC020APH[3] := PWSGetWSError()
			Endif
		Endif

		If Empty(HttpSession->PWSC040Info)
			HttpSession->PWSC040Info 	:= { NIL , NIL , NIL , NIL }
		Endif
		
		// Busca definição de Header de Informações de Cliente
		If empty(HttpSession->PWSC020APH[3]) .and. HttpSession->PWSC040Info[CLIENT_CADASTRO] = NIL 
			If oObj:GETHEADER("CUSTOMERVIEW") //1
				HttpSession->PWSC040Info[CLIENT_CADASTRO]	:= oObj:oWSGETHEADERRESULT:OWSBRWHEADER
			Else
				HttpSession->PWSC020APH[3] := PWSGetWSError()
			Endif
		Endif
		
		// Busca definição de Header de Endereços
		If empty(HttpSession->PWSC020APH[3]) .and. HttpSession->PWSC040Info[CLIENT_ENDERECOS] = NIL 
			If oObj:GETHEADER("ADDRESSVIEW") //2
				HttpSession->PWSC040Info[CLIENT_ENDERECOS] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
			Else
				HttpSession->PWSC020APH[3] := PWSGetWSError()
			Endif
		Endif

		// Busca definição de Header de Telefones
		If empty(HttpSession->PWSC020APH[3]) .and. HttpSession->PWSC040Info[CLIENT_TELEFONES] = NIL 
			If oObj:GETHEADER("PHONEVIEW") //3
				HttpSession->PWSC040Info[CLIENT_TELEFONES] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
			Else
				HttpSession->PWSC020APH[3] := PWSGetWSError()
			Endif
		Endif

		// Busca dados do Cliente em si
		If empty(HttpSession->PWSC020APH[3])
			If oObj:GETCUSTOMER( MYUSERCODE  , HTTPPOST->CODCLIERP )
				HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER] := oObj:oWSGETCUSTOMERRESULT 
			Else
				HttpSession->PWSC020APH[3] := PWSGetWSError()
			Endif
		Endif
			
	Else
		HttpSession->PWSC020APH[3] := STR0005 //'ERRO PWSC040#001 : Cliente Inválido'
	Endif
	
ElseIF empty(HttpSession->PWSC040Info)

	HttpSession->PWSC020APH[3] := STR0006 //'ERRO PWSC040#002 : Acesso Inválido'

Endif

If !Empty(HttpSession->PWSC020APH[3])

	// Houve ocorrÊncia de erro ? Volta para a Tela 020
	cHtml += ExecInPage( "PWSC020" )

Else
	nX := aScan(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,{|x| x:cTYPEOFADDRESS == "1"})

	If nX == 0
		aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
		Atail(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW):cTYPEOFADDRESS := "1"
	EndIf

	nX := aScan(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,{|x| x:cTYPEOFADDRESS == "2"})

	If nX == 0
		aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
		Atail(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW):cTYPEOFADDRESS := "2"
	EndIf

	nX := aScan(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,{|x| x:cTYPEOFADDRESS == "3"})

	If nX == 0
		aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
		Atail(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW):cTYPEOFADDRESS := "3"
	EndIf

	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := aSort(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,,,{|x,y| x:cTypeOfAddress < y:cTypeOfAddress })
	
	If Len( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW ) < 3
		If Len( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW ) == 1
			aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
			aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
		ElseIf Len( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW ) == 2
			aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
		Else
			aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
			aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )
			aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW, MTSUPPLIER_ADDRESSVIEW():New() )								
		EndIf
	EndIf

	nX := aScan(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,{|x| x:cTYPEOFPHONE == "1"})
	If nX == 0
		aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW, MTSUPPLIER_PHONEVIEW():New() )
		Atail(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW):cTYPEOFPHONE := "1"			
	EndIf
	nX := aScan(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,{|x| x:cTYPEOFPHONE == "2"})
	If nX == 0
		aadd( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW, MTSUPPLIER_PHONEVIEW():New() )
		Atail(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW):cTYPEOFPHONE := "2"
	EndIf

	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW := aSort(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,,,{|x,y| x:cTypeOfPhone < y:cTypeOfPhone })	
                                
	If ExistBlock( "PEC041" )
		aWebCols := ExecBlock( "PEC041", .F., .F., {1} )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "CUSTOMERCODE", "D" } )
		aAdd( aWebCols, { "UNITCUSTOMERCODE", "D" } )
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "NICKNAME" )
		aAdd( aWebCols, "FEDERALID" )
		aAdd( aWebCols, "STATEID" )
		aAdd( aWebCols, "DISTRICTID" )
		aAdd( aWebCols, "HOMEPAGE" )
		aAdd( aWebCols, "EMAIL" )
	EndIf

	GridLinesEx( {  	HTTPPost->_CustomerInfo[1],;
	 				HttpSession->PWSC040Info[CLIENT_CADASTRO],;
	 				HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER],;
	 				aWebCols,;
	 				IIf( HttpPost->cEnvEmail == "1", .F., .T. ), "H",,0 },"MTCUSTOMER", "SA1" )
	
	aadd( aJsGrid, GetJsGridLines() )
                                
	If ExistBlock( "PEC041" )
		aWebCols := ExecBlock( "PEC041", .F., .F., {2} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ADDRESS" )
		aAdd( aWebCols, "ADDRESSNUMBER" )
		aAdd( aWebCols, "DISTRICT" )
		aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
														{ "CSTATE", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "ZIPCODE" )
		aAdd( aWebCols, "ZONE" )
	EndIf

	GridLinesEx( { 	HTTPPost->_CustomerInfo[2][1],;
	 				HttpSession->PWSC040Info[CLIENT_ENDERECOS],;
	 				HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[1],;
	 				aWebCols,;
	 				IIf( HttpPost->cEnvEmail == "1", .F., .T. ), "H", "1",0 } )
	
	aadd( aJsGrid, GetJsGridLines() )

	aWebCols := {}
	
	If ExistBlock( "PEC041" )
		aWebCols := ExecBlock( "PEC041", .F., .F., {3} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ADDRESS" )
		aAdd( aWebCols, "ADDRESSNUMBER" )
		aAdd( aWebCols, "DISTRICT" )
		aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
														{ "CSTATE", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "ZIPCODE" )
		aAdd( aWebCols, "ZONE" )
	EndIf                   

	GridLinesEx( { 	HTTPPost->_CustomerInfo[2][2],;
	 				HttpSession->PWSC040Info[CLIENT_ENDERECOS],;
	  				HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[2],;
	   				aWebCols,;
	   				IIf( HttpPost->cEnvEmail == "1", .F., .T. ), "H", "2", 0 } )

	aWebCols := {}
                           
	If ExistBlock( "PEC041" )
		aWebCols := ExecBlock( "PEC041", .F., .F., {4} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ADDRESS" )
		aAdd( aWebCols, "ADDRESSNUMBER" )
		aAdd( aWebCols, "DISTRICT" )
		aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
														{ "CSTATE", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "ZIPCODE" )
		aAdd( aWebCols, "ZONE" )
	EndIf                   

	GridLinesEx( { 	HTTPPost->_CustomerInfo[2][3],;
	 				HttpSession->PWSC040Info[CLIENT_ENDERECOS],;
	 				HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[3],;
	 				aWebCols,;
	 				IIf( HttpPost->cEnvEmail == "1", .F., .T. ), "H", "3", 0 } )
	aWebCols := {}
                        
	If ExistBlock( "PEC041" )
		aWebCols := ExecBlock( "PEC041", .F., .F., {5} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "COUNTRYAREACODE" )
		aAdd( aWebCols, "LOCALAREACODE" )
		aAdd( aWebCols, "PHONENUMBER" )    
	EndIf                   

	GridLinesEx( { 	HTTPPost->_CustomerInfo[3][1],;
					HttpSession->PWSC040Info[CLIENT_TELEFONES],;
					HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[1],;
					aWebCols,;
					IIf( HttpPost->cEnvEmail == "1", .F., .T. ), "H", "1",0 } )

	aWebCols := {}
                      
	If ExistBlock( "PEC041" )
		aWebCols := ExecBlock( "PEC041", .F., .F., {6} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "PHONENUMBER" )
	EndIf                   
	
	GridLinesEx( { 	HTTPPost->_CustomerInfo[3][2],;
					HttpSession->PWSC040Info[CLIENT_TELEFONES],;
					HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[2],;
					aWebCols,;
					IIf( HttpPost->cEnvEmail == "1", .F., .T. ), "H", "2", 0 } )
	
	If HttpPost->cEnvEmail == "1"
		cHtml += H_PWSC042()
	Else
		cHtml += ExecInPage( "PWSC040" )
	EndIf
Endif

WEB EXTENDED END

Return cHtml


/* --------------------------------------------------------------------------
					Função de Gravação de Alteração de Dados
-------------------------------------------------------------------------- */

Web Function PWSC042()
Local cHtml := ""
Local cCustomerId
Local oObj, oChk
Local nI

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

PWSSetObjToPost( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER], HttpSession->PWSC040Info[CLIENT_CADASTRO], HttpPost->aPost )
PWSSetObjToPost( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[1], HttpSession->PWSC040Info[CLIENT_ENDERECOS], HttpPost->aPost, "1" )
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[1]:cTYPEOFADDRESS := "1"
PWSSetObjToPost( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[2], HttpSession->PWSC040Info[CLIENT_ENDERECOS], HttpPost->aPost, "2" )
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[2]:cTYPEOFADDRESS := "2"
PWSSetObjToPost( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[3], HttpSession->PWSC040Info[CLIENT_ENDERECOS], HttpPost->aPost, "3" )
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[3]:cTYPEOFADDRESS := "3"
nI := 0
If Empty(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[nI+1]:cADDRESS)
	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := Adel(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,nI+1)
	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := aSize(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,Len(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW)-1)
	nI--
EndIf
If Empty(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[nI+2]:cADDRESS)
	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := Adel(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,nI+2)
	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := aSize(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,Len(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW)-1)
	nI--
EndIf
If Empty(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[nI+3]:cADDRESS)
	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := Adel(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,nI+3)
	HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW := aSize(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW,Len(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW)-1)
EndIf

PWSSetObjToPost( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[1], HttpSession->PWSC040Info[CLIENT_TELEFONES], HttpPost->aPost, "1" )
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[1]:cTYPEOFPHONE := "1"
PWSSetObjToPost( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[2], HttpSession->PWSC040Info[CLIENT_TELEFONES], HttpPost->aPost, "2" )
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[2]:cTYPEOFPHONE := "2"
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[2]:cCOUNTRYAREACODE := HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[1]:cCOUNTRYAREACODE
HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[2]:cLOCALAREACODE := HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[1]:cLOCALAREACODE

nI := 0
If Empty(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[nI+1]:cPHONENUMBER)
  HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW := Adel(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,nI+1)
  HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW := ASize(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,Len(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW)-1)
  nI--
EndIf
If Empty(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW[nI+2]:cPHONENUMBER)
  HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW := Adel(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,nI+2)
  HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW := ASize(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW,Len(HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSPHONES:OWSPHONEVIEW)-1)
  nI--
EndIf

oChk := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGVALIDATION' ), WSCFGVALIDATION():NEW() )
WsChgUrl(@oChk,"CFGVALIDATION.apw")

//cUSERCODE,cCOUNTRY,cFEDERALID
If !Empty( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:cFEDERALID )
	If !oChk:CHECKFEDERALID( GetUsrCode(), "BRA", HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:cFEDERALID )
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSC041.APW" ) //"Erro"
	EndIf
EndIf

If !Empty( HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:cSTATEID )
	//cUSERCODE,cSTATE,cSTATEID
	If !oChk:CHECKSTATEID( GetUsrCode(), HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:OWSADDRESSES:OWSADDRESSVIEW[1]:cSTATE, HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER]:cSTATEID )
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSC041.APW" ) //"Erro"
	EndIf
EndIf

cCustomerId := HttpSession->PWSC040Info[4]:cCustomerCode + ;
					HttpSession->PWSC040Info[4]:cUnitCustomerCode

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():NEW() )

WsChgUrl(@oObj,"MTCUSTOMER.apw")

If oObj:PUTCUSTOMER( MYUSERCODE, cCustomerId, HttpSession->PWSC040Info[CLIENT_OBJCUSTOMER] )
	HTTPPOST->CODCLIERP := cCustomerId
	Return PWSHTMLALERT( "", STR0011, STR0012, "W_PWSC040.APW" ) //"Dados Cadastrais"###"Informações cadastradas com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0007, "", "W_PWSC041.APW" ) //"Erro"
EndIf

WEB EXTENDED END

Return cHtml


/**********************************************************************
	Verifica se cliente cadastro será de Dados Pessoais ou Contatos
**********************************************************************/
Web Function PWSC043()                
   Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
   	
		cHtml += ExecInPage( "PWSC041" )
   	
	WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC044   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com os contatos para o cliente selecionado.            º±±
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
Web Function PWSC044()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols 	:= {}				//Array com os campos a serem mostrados na tela
Local oObj							//Objeto WS - WSCRMCUSTOMERCONTACT

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com as informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSC044APH := { STR0015	,;                           //"Contatos - CONTATOS"
							  	"W_PWSC045.APW"	,;			//Pagina para onde sera enviado o POST
							  	"W_PWSC043.APW" }			//Pagina de Volta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMCUSTOMERCONTACT' ), WSCRMCUSTOMERCONTACT():New() )
WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array contendo os headers dos WS utilizados nesta pagina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSC044HEADER )
	HttpSession->PWSC044HEADER := { NIL, NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura CONTACTVIEW - Contato          ³
	//|- CONTACTID             : Codigo                   |
	//|- NAME                  : Nome                     |
	//|- FEDERALID             : CNPJ                     |
	//|- EMAIL                 : E-mail                   |
	//|- HOMEPAGE              : HomePage                 |
	//|- POSITION              : Cargo                    |
	//|- POSITIONDESCRIPTION   : Descricao do Cargo       |
	//|- GROUP                 : Grupo                    |
	//|- GROUPDESCRIPTION      : Descricao do Grupo       |
	//|- DEPARTMENT            : Departamento             |
	//|- DEPARTMENTDESCRIPTION : Descricao do Departamento|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSC044HEADER[1] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cHEADERTYPE := "CONTACTVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSC044HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0016, "", "W_PWSV180.APW" )     //Atencao
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura ADDRESSVIEW - Endereco³
	//|- ADDRESS       : Endereco                |
	//|- ADDRESSNUMBER : Numero                  |
	//|- DISTRICT      : Cidade                  |
	//|- STATE         : Estado                  |
	//|- ZIPCODE       : CEP                     |
	//|- ZONE          : Bairro                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSC044HEADER[2] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSC044HEADER[2] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0016, "", "W_PWSV180.APW" )    //Atencao
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura PHONEVIEW - Telefone³
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSC044HEADER[3] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSC044HEADER[3] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0016, "", "W_PWSV180.APW" )    //Atencao
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros do metodo BRWCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 		:= GetUsrCode()
oObj:cCUSTOMERID 	:= HttpSession->CODCLIERP

//cUSERCODE,cCUSTOMERID,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWCONTACT()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes dos campos que seram mostrados na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSC044INFO := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do metodo WS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSC044RESULT := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do metodo BRWCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSC044RESULT := { oObj:oWSBRWCONTACTRESULT:oWSCONTACTVIEW }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada WS - WSCRMCUSTOMERCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEC044" )
		aWebCols := ExecBlock( "PEC044", .F., .F., {} )
	Else
		aAdd( aWebCols, "CONTACTID" )
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "FEDERALID" )
		aAdd( aWebCols, "EMAIL" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSC044INFO, HttpSession->PWSC044HEADER[1][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEX( { 	HttpSession->PWSC044INFO		, HttpSession->PWSC044HEADER[1][1]	,;
					HttpSession->PWSC044RESULT[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0016, "", "W_PWSC043.APW" )    //Atencao
EndIf

cHtml := ExecInPage( "PWSC044" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC045   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com os dados do contato selecionado.                   º±±
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
Web Function PWSC045()

Local cHtml 		:= ""						//Pagina WEB
Local nI 			:= 0						//Variavel de apoio
Local nPosCli		:= 0						//Posicao do cliente no array de Clientes
Local nPosCon		:= 0						//Posicao do contato no array de Contatos
Local nPosEnd		:= 0						//Posicao do tipo do endereco dentro do array de Enderecos do Contato
Local nPosTel		:= 0						//Posicao do tipo do telefone dentro do array de Telefones do Contato
Local aWebCols 		:= {}						//Array contendo os campos que serao utilizados na tela
Local oObj										//Objeto WS - WSCRMCUSTOMERCONTACT

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com as informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSC045APH := { 	STR0001				,;			//Titulo da pagina
								"W_PWSC046.APW"	,;			//Pagina para onde sera enviado o POST
								"W_PWSC044.APW" }			//Pagina de Volta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Session de armazenagem do objeto WS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSC045RESULT := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes dos campos que seram mostrados na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSC045INFO := { {}, {}, {} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMCUSTOMERCONTACT' ), WSCRMCUSTOMERCONTACT():New() )
WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com os tipos de informacoes que serao apresentados na tela³
//³Ex: Tipo de Telefone, Tipos de Endereco, etc.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( Httpsession->PWSC045TYPES )
	Httpsession->PWSC045TYPES := { NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Endereco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSC045TYPES[1] )
		If oObj:GETTYPEOFADDRESS()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFADDRESS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSC045TYPES[1] := { oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0016, "", "W_PWSC045.APW" )       //Atencao
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Telefone³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSC045TYPES[2] )
		If oObj:GETTYPEOFPHONE()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFPHONE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSC045TYPES[2] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0016, "", "W_PWSC045.APW" )   	//Atencao
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alteracao de Contatos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HttpGet->cAcao == "A"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicao do contato dentro do array de retorno do metodo BRWCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosCon := ascan( HttpSession->PWSC044RESULT[1], { |x| x:cCONTACTID == HttpGet->cCONTACTID } )

	If nPosCon > 0
		HttpSession->PWSC045APH[1] := STR0002 + " - " + STR0017 + HttpSession->PWSC044RESULT[1][nPosCon]:cNAME //"Dados Cadastrais : /Contatos:
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETCONTACT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
		oObj:cCONTACTID		:= HttpGet->cCONTACTID
		
		//cUSERCODE,cCUSTOMERID,cCONTACTID
		If oObj:GETCONTACT()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETCONTACT³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSC045RESULT := { oObj:oWSGETCONTACTRESULT }
		Else
			Return PWSHtmlAlert( "", STR0016, "", "W_PWSC044.APW" )     //Atencao
		EndIf
	EndIf
Else
	HttpSession->PWSC045APH[1] :=STR0004								// "Inclusão - Dados Cadastrais"

	aAdd( HttpSession->PWSC045RESULT, CRMCUSTOMERCONTACT_CONTACTVIEW():New() )

	HttpSession->PWSC045RESULT[1]:oWSADDRESSES 	:= CRMCUSTOMERCONTACT_ARRAYOFADDRESSVIEW():New()
	HttpSession->PWSC045RESULT[1]:oWSPHONES 	:= CRMCUSTOMERCONTACT_ARRAYOFPHONEVIEW():New()
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereco do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSC045TYPES[1][1] )
	If Empty( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		nPosEnd := 0
	Else
		nPosEnd := aScan( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, { |x| x:cTYPEOFADDRESS == Str( nI, 1 ) } )
	EndIf
	
	If nPosEnd == 0
		aAdd( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, CRMCUSTOMERCONTACT_ADDRESSVIEW():New() )
		aTail( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW ):cTYPEOFADDRESS := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones :         ³
//³Comercial   - Tipo 1³
//³FAX         - Tipo 2³
//³Celular     - Tipo 3³
//|Residencial - Tipo 4|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSC045TYPES[2][1] )
	If Empty( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		nPosTel := 0
	Else
		nPosTel := aScan( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW, { |x| x:cTYPEOFPHONE == Str( nI, 1 ) } )
	EndIf

	If nPosTel == 0
		aAdd( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW, CRMCUSTOMERCONTACT_PHONEVIEW():New() )
		aTail( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW ):cTYPEOFPHONE := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones ordenado pelo Tipo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Dados do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEC045" )
	aWebCols := ExecBlock( "PEC045", .F., .F., { 1 } )
Else
	If HttpGet->cAcao == "A"
		aAdd( aWebCols, { "CONTACTID", "D" } )
	EndIf
	
	aAdd( aWebCols, "NAME" )
	aAdd( aWebCols, "FEDERALID" )
	aAdd( aWebCols, "EMAIL" )
	aAdd( aWebCols, "HOMEPAGE" )
	aAdd( aWebCols, { "POSITION", "N", { "GETPOSITION",;
											{ "CPOSITION"			, "CCODE" }				,;
											{ "CPOSITIONDESCRIPTION", "CDESCRIPTION" } }	,;
										{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, { "POSITIONDESCRIPTION", "D" } )
	aAdd( aWebCols, { "GROUP", "N", { "GETGROUP",;
										{ "CGROUP"				, "CCODE" },;
										{ "CGROUPDESCRIPTION"	, "CDESCRIPTION" } },;
									{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, { "GROUPDESCRIPTION", "D" } )
	aAdd( aWebCols, { "DEPARTMENT", "N", { "GETDEPARTMENT",;
											{ "CDEPARTMENT"				, "CCODE" },;
											{ "CDEPARTMENTDESCRIPTION"	, "CDESCRIPTION" } },;
										{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, { "DEPARTMENTDESCRIPTION", "D" } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSC045INFO[1]		, HttpSession->PWSC044HEADER[1][1]	,;
				HttpSession->PWSC045RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 } )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Endereco do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEC045" )
	aWebCols := ExecBlock( "PEC045", .F., .F., { 2 } )
Else
	aAdd( aWebCols, "ADDRESS" )
	aAdd( aWebCols, "ADDRESSNUMBER" )
	aAdd( aWebCols, "DISTRICT" )
	aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
										{ "CSTATE", "CCODE" };
									}, ;
									{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, "ZIPCODE" )
	aAdd( aWebCols, "ZONE" )
EndIf

For nI := 1 To Len( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	aAdd( HttpSession->PWSC045INFO[2], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSC045INFO[2][nI]									, HttpSession->PWSC044HEADER[2][1]	,;
					HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	, aWebCols							,;
					.T.																, "H", Str( nI, 1 ), 2 } )
Next nI

aWebCols := {}
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEC045" )
	aWebCols := ExecBlock( "PEC045", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "COUNTRYAREACODE" )
	aAdd( aWebCols, "LOCALAREACODE" )
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSC045INFO[3], {} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSC045INFO[3][1]							, HttpSession->PWSC044HEADER[3][1]	,;
				HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 } )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEC045" )
	aWebCols := ExecBlock( "PEC045", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSC045INFO[3], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSC045INFO[3][nI]								, HttpSession->PWSC044HEADER[3][1]	,;
					HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols							,;
					.T.															, "H", Str( nI, 1 ), IIf( nI <> Len( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) } )
Next nI

cHtml += ExecInPage( "PWSC045" )
	
WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC046   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao ou alteracao do contato.                           º±±
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
Web Function PWSC046()

Local cHtml := ""						//Pagina WEB
Local nI	:= 0						//Variavel de apoio
Local oObjCRM							//Objeto WS - WSCRMCUSTOMERCONTACT
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjCRM := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMCUSTOMERCONTACT' ), WSCRMCUSTOMERCONTACT():New() )
WsChgUrl( @oObjCRM, "CRMCUSTOMERCONTACT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCFGVALIDATION³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCFGVal := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGVALIDATION' ), WSCFGVALIDATION():New() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica CNPJ / CGC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSC045RESULT[1]:cFEDERALID )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo CHECKFEDERALID³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSC045RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		Return PWSHtmlAlert( "", STR0016, "", "W_PWSC045.APW?cCONTACTID=" + HttpPost->cCONTACTID + "&cAcao=" + HttpPost->cAcao )       //Atencao
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Contato - CONTACTVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSSetObjToPost( HttpSession->PWSC045RESULT[1], HttpSession->PWSC044HEADER[1][1], HttpPost->aPost )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Endereco do Contato - ADDRESSVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	PWSSetObjToPost( 	HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	,;
						HttpSession->PWSC044HEADER[2][1]								,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Telefone do Contato - PHONEVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	PWSSetObjToPost( 	HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSC044HEADER[3][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Clone do Objeto WS                                           |
//³Utilizado para a armazenagem da Session no Objeto de Gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjClone := HttpSession->PWSC045RESULT[1]:CLONE()

If HttpPost->cAcao == "A" .OR. HttpPost->cAcao == "I"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo PUTCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRM:cUSERCODE		:= GetUsrCode()
	oObjCRM:cCUSTOMERID		:= HttpSession->CODCLIERP
	oObjCRM:oWSCONTACT 		:= oObjClone
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Endereco do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRM:oWSCONTACT:oWSADDRESSES := CRMCUSTOMERCONTACT_ARRAYOFADDRESSVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		aAdd( oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW, CRMCUSTOMERCONTACT_ADDRESSVIEW():New() )

		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS			:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS
		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER	:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER
		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT		:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT
		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE			:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE
		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS	:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS
		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE			:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE
		oObjCRM:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE			:= HttpSession->PWSC045RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Telefone do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRM:oWSCONTACT:oWSPHONES := CRMCUSTOMERCONTACT_ARRAYOFPHONEVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		aAdd( oObjCRM:oWSCONTACT:oWSPHONES:oWSPHONEVIEW, CRMCUSTOMERCONTACT_PHONEVIEW():New() )

		oObjCRM:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE 	:= HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
		oObjCRM:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE 	:= HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
		oObjCRM:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER 		:= HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
		oObjCRM:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE		:= HttpSession->PWSC045RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Informacoes do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cUSERCODE,cCUSTOMERID,oWSCONTACT 
	If oObjCRM:PUTCONTACT()
		HttpGet->cCONTACTID := oObjCRM:cPUTCONTACTRESULT

		Return PWSHtmlAlert( "",STR0015, STR0012 , "W_PWSC045.APW?cCONTACTID=" + HttpPost->cCONTACTID + "&cAcao=" + HttpPost->cAcao )              //"Contato - CONTATO", "Informações cadastradas com SUCESSO!"
	Else
		Return PWSHtmlAlert( "", STR0016, "", "W_PWSC045.APW?cCONTACTID=" + HttpPost->cCONTACTID + "&cAcao=" + HttpPost->cAcao )
	EndIf                                                                                                                                           //"Atencao"
EndIf

WEB EXTENDED END

Return cHtml
