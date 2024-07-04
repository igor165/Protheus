#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "JURA220.CH"

/* ===============================================================================
WSDL Location    http://www.kurier.com.br/wsdistribuicao/wsDistribuicao.asmx?WSDL
Gerado em        05/17/16 12:35:54
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _DOPNEIU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA220 - Web Service de distribuição da Kurrier
------------------------------------------------------------------------------- */
WSCLIENT JURA220

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RecuperarNovaDistribuicao
	WSMETHOD RecuperarDistribuicao
	WSMETHOD ConfirmacaoDistribuicaoEnviada
	WSMETHOD ConfirmacaoDistribuicaoEnviadaPorNumeroProcesso

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   clogin                    AS string
	WSDATA   oWSRecuperarNovaDistribuicaoResult AS SCHEMA
	WSDATA   cdataEnvio                AS string
	WSDATA   oWSRecuperarDistribuicaoResult AS SCHEMA
	WSDATA   oWSds                     AS SCHEMA
	WSDATA   cstatus                   AS string
	WSDATA   lConfirmacaoDistribuicaoEnviadaResult AS boolean
	WSDATA   oWSListaNumerosProcesso   AS Service1_ArrayOfString
	WSDATA   lConfirmacaoDistribuicaoEnviadaPorNumeroProcessoResult AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA220
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA220
	::oWSRecuperarNovaDistribuicaoResult := NIL 
	::oWSRecuperarDistribuicaoResult := NIL 
	::oWSds              := NIL 
	::oWSListaNumerosProcesso := Service1_ARRAYOFSTRING():New()
Return

WSMETHOD RESET WSCLIENT JURA220
	::clogin             := NIL 
	::oWSRecuperarNovaDistribuicaoResult := NIL 
	::cdataEnvio         := NIL 
	::oWSRecuperarDistribuicaoResult := NIL 
	::oWSds              := NIL 
	::cstatus            := NIL 
	::lConfirmacaoDistribuicaoEnviadaResult := NIL 
	::oWSListaNumerosProcesso := NIL 
	::lConfirmacaoDistribuicaoEnviadaPorNumeroProcessoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA220
Local oClone := JURA220():New()
	oClone:_URL          := ::_URL 
	oClone:clogin        := ::clogin
	oClone:cdataEnvio    := ::cdataEnvio
	oClone:cstatus       := ::cstatus
	oClone:lConfirmacaoDistribuicaoEnviadaResult := ::lConfirmacaoDistribuicaoEnviadaResult
	oClone:oWSListaNumerosProcesso :=  IIF(::oWSListaNumerosProcesso = NIL , NIL ,::oWSListaNumerosProcesso:Clone() )
	oClone:lConfirmacaoDistribuicaoEnviadaPorNumeroProcessoResult := ::lConfirmacaoDistribuicaoEnviadaPorNumeroProcessoResult
Return oClone

// WSDL Method RecuperarNovaDistribuicao of Service JURA220

WSMETHOD RecuperarNovaDistribuicao WSSEND clogin WSRECEIVE oWSRecuperarNovaDistribuicaoResult WSCLIENT JURA220
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RecuperarNovaDistribuicao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RecuperarNovaDistribuicao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/RecuperarNovaDistribuicao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv("MV_JDISURL", .T., ""))	//"http://www.kurier.com.br/wsdistribuicao/wsDistribuicao.asmx"

::Init()
::oWSRecuperarNovaDistribuicaoResult :=  WSAdvValue( oXmlRet,"_RECUPERARNOVADISTRIBUICAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RecuperarDistribuicao of Service JURA220

WSMETHOD RecuperarDistribuicao WSSEND clogin,cdataEnvio WSRECEIVE oWSRecuperarDistribuicaoResult WSCLIENT JURA220
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RecuperarDistribuicao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("dataEnvio", ::cdataEnvio, cdataEnvio , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RecuperarDistribuicao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/RecuperarDistribuicao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv("MV_JDISURL", .T., ""))	//"http://www.kurier.com.br/wsdistribuicao/wsDistribuicao.asmx"

::Init()
::oWSRecuperarDistribuicaoResult :=  WSAdvValue( oXmlRet,"_RECUPERARDISTRIBUICAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmacaoDistribuicaoEnviada of Service JURA220

WSMETHOD ConfirmacaoDistribuicaoEnviada WSSEND clogin,oWSds,cstatus WSRECEIVE lConfirmacaoDistribuicaoEnviadaResult WSCLIENT JURA220
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmacaoDistribuicaoEnviada xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ds", ::oWSds, oWSds , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("status", ::cstatus, cstatus , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConfirmacaoDistribuicaoEnviada>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConfirmacaoDistribuicaoEnviada",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv("MV_JDISURL", .T., ""))		//"http://www.kurier.com.br/wsdistribuicao/wsDistribuicao.asmx"

::Init()
::lConfirmacaoDistribuicaoEnviadaResult :=  WSAdvValue( oXmlRet,"_CONFIRMACAODISTRIBUICAOENVIADARESPONSE:_CONFIRMACAODISTRIBUICAOENVIADARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmacaoDistribuicaoEnviadaPorNumeroProcesso of Service JURA220

WSMETHOD ConfirmacaoDistribuicaoEnviadaPorNumeroProcesso WSSEND clogin,oWSListaNumerosProcesso WSRECEIVE lConfirmacaoDistribuicaoEnviadaPorNumeroProcessoResult WSCLIENT JURA220
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmacaoDistribuicaoEnviadaPorNumeroProcesso xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ListaNumerosProcesso", ::oWSListaNumerosProcesso, oWSListaNumerosProcesso , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConfirmacaoDistribuicaoEnviadaPorNumeroProcesso>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConfirmacaoDistribuicaoEnviadaPorNumeroProcesso",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv("MV_JDISURL", .T., ""))		//"http://www.kurier.com.br/wsdistribuicao/wsDistribuicao.asmx"

::Init()
::lConfirmacaoDistribuicaoEnviadaPorNumeroProcessoResult :=  WSAdvValue( oXmlRet,"_CONFIRMACAODISTRIBUICAOENVIADAPORNUMEROPROCESSORESPONSE:_CONFIRMACAODISTRIBUICAOENVIADAPORNUMEROPROCESSORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfString

WSSTRUCT Service1_ArrayOfString
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service1_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service1_ArrayOfString
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Service1_ArrayOfString
	Local oClone := Service1_ArrayOfString():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service1_ArrayOfString
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

//-------------------------------------------------------------------
//	FIM DO CLIENTE WEBSERVICES
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} J220CfmDis
Função para dar baixa\confirmar as distribuicoes recebidas da Kurier
Uso JURA172.

@param 	 cLoginDis - Codigo do login que foi utilizado para efetuar as importações de distribuições
@param	 aDadosRet - Distribuições que já foram importadas e devem ser confirmadas
@return  lRet 	   - Define se as distribuições foram confirmadas com sucesso
@author	 Rafael Tenorio da Costa
@since	 16/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J220CfmDis(cLoginDis, aDadosRet)

	Local nC        := 0
	Local lRet      := .F.
	Local cUrl      := SuperGetMv("MV_JDISURL", .T., "")						//URL do Web Service de distribuicao
	Local oWsdl     := Nil
	Local cMensagem := ''
	Local xRet      := ''
	Local cMsg      := ''
	Local oXml      := Nil
	Local cErro     := ""
	Local cAviso    := ""
	Local nElementos:= 0
	Local aSimple	:= {}	
	Local cDs		:= ""
	Local nPos		:= 0
	
	Begin Sequence

	  	//Faz o parse de uma URL
		cUrl := IIF( At(Upper(cUrl), "?WSDL") == 0, cUrl + "?WSDL", "")

		//Cria o objeto da classe TWsdlManager
	  	oWsdl :=  JurConWsdl(cUrl, @cErro) 

	    If  !Empty(cErro)
	        cMensagem := STR0001 + oWsdl:cError		//"Problema para configurar a URL do webservice de distribuição da Kurier: "
	        Break
	    EndIf
	
	  	//Define a operação
	    If  !( lRet := oWsdl:SetOperation("ConfirmacaoDistribuicaoEnviada") )
	        cMensagem := STR0002 + oWsdl:cError		//"Problema para configurar o método do webservice de distribuição da Kurier: "
	        Break
	    EndIf
	
	  	//Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	 	oWsdl:cLocation := StrTran(cUrl, "?WSDL", "")

		//Retona os elementos para preenchimento	
	    aSimple := oWsdl:SimpleInput()
	    
		nPos := aScan( aSimple, {|x| x[2] == "login"} )
        If !( lRet := oWsdl:SetValue(aSimple[nPos][1], cLoginDis) )
            cMensagem := STR0003 + oWsdl:cError		//"Problema para configurar os valores da tags : "
            Break
        EndIf
	    
		cDs := '<xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">'
		cDs +=    '<xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:UseCurrentLocale="true">'
		cDs += 	  	'<xs:complexType>'
		cDs += 		 '<xs:choice minOccurs="0" maxOccurs="unbounded">'
		cDs += 			'<xs:element name="Table">'
		cDs += 			   '<xs:complexType>'
		cDs += 				  '<xs:sequence>'
		cDs += 					 '<xs:element name="NumeroProcesso" type="xs:string" minOccurs="0"/>'
		cDs += 				  '</xs:sequence>'
		cDs += 			   '</xs:complexType>'
		cDs += 			'</xs:element>'
		cDs += 		 '</xs:choice>'
		cDs += 	  	'</xs:complexType>'
		cDs +=    '</xs:element>'
		cDs += '</xs:schema>'
		cDs += '<diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1">'
		cDs += 	'<NewDataSet xmlns="">'

	    For nElementos:=1 To Len(aDadosRet)
			cDs += 	  '<Table diffgr:id="Table'+ cValToChar(nElementos) + '" msdata:rowOrder="' + cValTochar(nElementos-1) + '">'	// <Table diffgr:id="Table1" msdata:rowOrder="0">'
			cDs += 		 '<NumeroProcesso>' 	+ aDadosRet[nElementos][05][2] + '</NumeroProcesso>'
			cDs += 	  '</Table>'
		Next nElementos

		cDs += 	'</NewDataSet>'
		cDs += '</diffgr:diffgram>'
		
		nPos := aScan( aSimple, {|x| x[2] == "ds"} )
        If !( lRet := oWsdl:SetValue(aSimple[nPos][1], cDs) )
            cMensagem := STR0003 + oWsdl:cError		//"Problema para configurar os valores da tags : "
            Break
        EndIf
        
		//Pega a mensagem que sera enviada para Web Service
	    cMsg := oWsdl:GetSoapMsg()
	
	    //Envia a mensagem SOAP ao servidor
	    xRet := oWsdl:SendSoapMsg(cMsg)
	
	  	//Pega a mensagem de resposta
	    xRet := oWsdl:GetSoapResponse()
	  	
	  	//Obtem somente Result Tag do XML de retorno  
	    nC   := At('<ConfirmacaoDistribuicaoEnviadaResult>', xRet)
	    xRet := SubStr(xRet, nC, Len(xRet))
	    nC   := At('</ConfirmacaoDistribuicaoEnviadaResult>', xRet) + 38
	    xRet := Left(xRet, nC)
	
	  	//Gera o objeto do Result Tag  
	    oXml := XmlParser(xRet, "_", @cErro, @cAviso)
	     
	    If Empty(oXml)
	        cMensagem := STR0004 + oWsdl:cError		//"Problema no retorno da baixa da distribuição da Kurier: "
	        Break
	    EndIf
	
	  	//Verifica se esta concluido ou nao.
	    lRet := (oXml:_ConfirmacaoDistribuicaoEnviadaResult:TEXT == 'true')
	
	End Sequence
	
	If !Empty(cMensagem)
	    ConOut("J220CfmDis: " + STR0005 + cMensagem)		//"Erro ao dar baixa na distribuição da Kurier: "
	    lRet := .F.
	EndIf
	
	If lRet
		JurConOut(STR0006, {(JurTimeStamp() + " ("+cLoginDis+")"), Len(aDadosRet)})		//"#1 - Aviso: Foram confirmadas #2 distribuções na Kurier."
	EndIf
	
	//Limpa a memória
	FWFreeObj(oXml)
	FWFreeObj(oWsdl)
	xRet := ""
	cMsg := ""
	cDs	 := ""

Return lRet
