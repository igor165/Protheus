#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "OMSXCPLWS.CH"

//Fonte responsável por agrupar as funções de envio de dados para o cockpit logístico
#DEFINE CPL_SERVICE 1
#DEFINE CPL_INSERT 2
#DEFINE CPL_UPDATE 3
#DEFINE CPL_DELETE 4
#DEFINE CPL_XMLINS 5
#DEFINE CPL_TABELA 6

/*/{Protheus.doc} OMSXCPLWS
	Classe cliente de webService para transmitir a mensagem ao cockpit logístico.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
WSCLIENT OMSXCPLWS
	
	WSMETHOD New
	WSMETHOD SetUrl
	WSMETHOD SetServico
	WSMETHOD SetMetodo
	WSMETHOD SetTabela
	WSMETHOD SetOperacao
	WSMETHOD SetXmlNameSpace
	WSMETHOD SetIniMetodo
	WSMETHOD SetFimMetodo
	WSMETHOD SetNomeArquivoXML
	WSMETHOD SetMErroTk
	WSMETHOD AddSoap // Responsável por concatenar a string que será enviado ao CPL
	WSMETHOD Envia // Dispara o envio dos dados.
	WSMETHOD RegistraRetorno

	WSDATA   _URL		AS String
	WSDATA   _HEADOUT	AS Array of String
	WSDATA   _COOKIES	AS Array of String
	WSDATA   cServico	AS String //Serviço de aquisição do lado cockpit logístico
	WSDATA   cMetodo	AS String //Método  de aquisição do lado cockpit logístico
	WSDATA   cxmlins	AS String //XmlNameSpace, uso do cockpit logístico
	WSDATA   cSoapAdd	AS String //Xml Adicionado para envio
	WSDATA   cIniMetodo	AS String //Gerado automaticamente utilizando ::cMetodo e ::cxmlins. Em caso de problemas, pode-se substituir diretamente o conteúdo 
	WSDATA   cFimMetodo	AS String //Gerado automaticamente utilizando ::cMetodo. Em caso de problemas, pode-se substituir diretamente o conteúdo
	WSDATA   lSucesso	AS Boolean //Indica o resultado do método ENVIA
	WSDATA   cMsgRet	AS String //Indica a mensagem de retorno capturado pelo método envia
	WSDATA   cTabela	AS String //Indica a tabela do Protheus que está sendo enviada. Usado para diferenciar para ponto de entrada 
	WSDATA   cNomeXML	AS String //Nome do arquivo XML que será gravado
	WSDATA   nOperacao	AS Numeric//Indica operação que está sendo enviada. Usado para diferenciar para chamada ponto de entrada
	WSDATA   lReenvia   As Logic 
	WSDATA   oRetorno
	WSData   lMErroTk   As Logic
ENDWSCLIENT

WSMETHOD New WSCLIENT OMSXCPLWS
	::cSoapAdd := ""
	::lSucesso := .F.
	::lReenvia := .T.
	::cMsgRet  := ""
	::lMErroTk := .T.
Return Self

WSMETHOD SetUrl WSSEND cUrl WSCLIENT OMSXCPLWS
	// Se possuir a barra no final, desconsidera a mesma
	If Rat("/",cUrl) == Len(cUrl)
		::_URL := SubStr(cUrl,1,Len(cUrl)-1)
	Else
		::_URL := cUrl
	EndIf
Return

WSMETHOD SetServico WSSEND cTipoServ WSCLIENT OMSXCPLWS
	::cServico := cTipoServ
	::_URL += "/" + ::cServico
Return

WSMETHOD SetMetodo WSSEND cMetodo WSCLIENT OMSXCPLWS
	::cMetodo := cMetodo
Return

WSMETHOD SetXmlNameSpace WSSEND cXmlName WSCLIENT OMSXCPLWS
	::cxmlins := "http://www.neolog.com.br/cpl/acquisition/" +cXmlName + "/"
Return

WSMETHOD SetTabela WSSEND cTabela WSCLIENT OMSXCPLWS
	::cTabela := cTabela
Return

WSMETHOD SetOperacao WSSEND nOperacao WSCLIENT OMSXCPLWS
	::nOperacao := nOperacao
Return

WSMETHOD SetIniMetodo WSSEND cIniMetodo WSCLIENT OMSXCPLWS
	::cIniMetodo := cIniMetodo
Return

WSMETHOD SetFimMetodo WSSEND cFimMetodo WSCLIENT OMSXCPLWS
	::cFimMetodo := cFimMetodo
Return

WSMETHOD SetNomeArquivoXML WSSEND cNomeXML WSCLIENT OMSXCPLWS
	::cNomeXML := cNomeXML
Return

WSMETHOD AddSoap WSSEND cString WSCLIENT OMSXCPLWS
	::cSoapAdd += cString
Return

WSMETHOD SetMErroTk WSSEND lMErroTk WSCLIENT OMSXCPLWS
	::lMErroTk := lMErroTk
Return

WSMETHOD Envia WSCLIENT OMSXCPLWS
Local cSoap := ""
Local oXmlRet
Local aErros
Local nX
Local nY
Local aItems
Local cSoapPto
Local cToken
Local cSoapSend
Local XMLHeadRet
Local aHeadOut
Local XMLPostRet := ""
Local nTimeOut := SuperGetMv("MV_CPLTIME",.F.,30)  //TimeOut da comunicação
Local cErrParser := ""
Local cWarParser := ""
Local lViagJaLib := .F.
Private XMLREC

	PutGlbValue( "GLB_OMSLOG",GetSrvProfString("LOGCPLOMS", ".F.") )
	PutGlbValue( "GLB_OMSTIP",GetSrvProfString("LOGTIPOMS", "CONSOLE") )

	OsLogCPL("OMSXCPLWS -> Envia -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLWS -> Envia -> ENVIAR O XML PARA A NEOLOG","INFO")
	OsLogCPL("OMSXCPLWS -> Envia -> "+Replicate("-", 100),"INFO")
		
	If ::nOperacao != MODEL_OPERATION_DELETE .And. ::cTabela != "DJZ" .And. ExistBlock("OMSXCPL01")
		cSoapPto := ExecBlock("OMSXCPL01",.F.,.F.,{::cSoapAdd,::cTabela})

		OsLogCpl("OMSXCPLWS -> Envia -> Encontrou o Ponto de entrada OMSXCPL01.","INFO" )
		If !Empty(cSoapPto)
			::cSoapAdd := cSoapPto
			OsLogCpl("OMSXCPLWS -> Envia -> Conteudo da variavel cSoapPto: " + cValToChar(Trim(cSoapPto)),"INFO" )
		EndIf
	EndIf
	
	If Empty(::cIniMetodo)
		cSoap += '<' + ::cMetodo + ' xmlns="' + ::cxmlins + '">'
	Else
		cSoap += ::cIniMetodo
	EndIf
	
	cSoap += ::cSoapAdd
	
	If Empty(::cFimMetodo)
		cSoap += "</" + ::cMetodo + ">"
	Else
		cSoap += ::cFimMetodo
	EndIf

	If Empty(::cNomeXML)
		::cNomeXML := (::cTabela)->(&((::cTabela)->(IndexKey())))
	EndIf

	::cSoapAdd := cSoap

	cToken := OMGETTOKEN(::lMErroTk, @Self:cMsgRet)
	
	OsLogCpl("OMSXCPLWS -> Envia -> Valor do cToken: " + cValToChar(cToken),"INFO" )
	
	If Empty(cToken) //Quando não há token
		OMSXGRVXML(::cServico,cSoap,::cTabela,::cNomeXML)
		oXmlRet := SvcSoapCall(	Self,cSoap,"",	"DOCUMENT",::cxmlins,,,::_URL)
		XMLPostRet := XMLSaveStr(oXmlRet)
		OMSXGRVXML(::cServico,XMLPostRet,::cTabela,::cNomeXML+"_resp")
	Else
		cSoapSend := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
		cSoapSend += '<soapenv:Header/>'
		cSoapSend += '<soapenv:Body>'
		cSoapSend += cSoap
		cSoapSend += '</soapenv:Body>'
		cSoapSend += '</soapenv:Envelope>'
		XMLHeadRet:= ""
		aHeadOut  := {'user.token: ' + cToken ,'Content-Type: text/xml;charset=utf-8','SOAPAction: ""','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
		OMSXGRVXML(::cServico,cSoapSend,::cTabela,::cNomeXML)
		
		OsLogCpl("OMSXCPLWS -> Envia -> Valor do cSoapSend: " + cValToChar(cSoapSend),"INFO" )
		
		If Empty(XMLPostRet := HTTPSPost(::_URL, "", "", "", "", cSoapSend, nTimeOut , aHeadOut, @XMLHeadRet))
			::lSucesso := .F.
			::cMsgRet +=  OmsFmtMsg(STR0001,{{"[VAR01]",::_URL}}); //CPLERR01 - Não foi possível se comunicar com o endereço de webservice [VAR01].
			+ STR0002 //" Para obter mais informações, consulte o help (F1) da rotina. "
			OsLogCpl("OMSXCPLWS -> Envia -> 001 - Não foi possivel comunicação com Webservice. Conteúdo da variável cMsgRet: "+ cValToChar(::cMsgRet) + ".","INFO" )
			
		Else
			OMSXGRVXML(::cServico,XMLPostRet,::cTabela,::cNomeXML+"_resp")
			If Empty(oXmlRet := XmlParser( XMLPostRet, "NS1", @cErrParser,@cWarParser) )
				::lSucesso := .F.
				::cMsgRet +=  OmsFmtMsg(STR0001,{{"[VAR01]",::_URL}}); //CPLERR01 - Não foi possível se comunicar com o endereço de webservice [VAR01].
				+ STR0002 //" Para obter mais informações, consulte o help (F1) da rotina. "
				OsLogCpl("OMSXCPLWS -> Envia -> 002 - Não foi possivel comunicação com Webservice. Conteúdo da variável cMsgRet: "+ cValToChar(::cMsgRet) + ".","ERROR" )
			Else
				XMLREC := classdataarr(oXmlRet)[1][2]
				oXmlRet := TMSXGetItens("Body","O")
			EndIf
		EndIf
	EndIf

	OsLogCpl("OMSXCPLWS -> Envia -> Conteudo do XML de RETORNO da Integracao, XMLPostRet: "+ cValToChar(XMLPostRet),"INFO" )

	If !Empty(XMLPostRet) .And. !Empty(oXmlRet)
		XMLREC := classdataarr(oXmlRet)[1][2]
		If ::cTabela == "DK5" 
			aItems := TMSXGetAll("messages:responseMessage")
			For nY := 1 To Len(aItems)
				XMLREC := aItems[nY]
				If TMSXGetItens("_NS2_RESULT","O"):TEXT == "false"
					If ::lReenvia .And. TMSXGetItens("_NS2_CODE","O"):TEXT == "001"
						PutMv("MV_DTTOK","")
						PutMv("MV_TOKCPL","")
						::lReenvia := .F.
						::Envia()
					Else
						::lSucesso := .F.
						::cMsgRet += STR0003+ TMSXGetItens("_NS2_CODE","O"):TEXT  + " | " + STR0004+ TMSXGetItens("_NS2_DESCRIPTION","O"):TEXT + CRLF//Código de erro //Mensagem: 
						OsLogCpl("OMSXCPLWS -> Envia -> 001 - Código de erro : "+ cValToChar(::cMsgRet) + ".","ERROR")
					EndIf
				EndIf
			Next nY
		Else
			aItems := TMSXGetAll("RESULT:RESULTS:RESULT")
			For nY := 1 To Len(aItems)
				If aItems[nY]:_SUCESS:TEXT == "false"
					::lSucesso := .F.
					::cMsgRet +=  CRLF + STR0005 +  aItems[nY]:_IDENTIFIER:TEXT + CRLF + STR0006 + CRLF // "Identificador :" ## "Código(s) de erro(s):" 
					XMLREC := aItems[nY]
					aErros := TMSXGetAll("ERRORCODES:ERRORCODE:VALUE")
					For nX := 1 To Len(aErros)
						::cMsgRet += aErros[nX]:TEXT + CRLF
						
						//Se a Viagem já tiver sido liberada, setar a FLAG para poder retornar TRUE no final.
						If ::cTabela == "DK0"
							IF Substr(aErros[nX]:TEXT, 1, 20) == "TripAlreadyProcessed"
								lViagJaLib := .T.
							EndIf
						EndIf
					Next nX
				EndIf
			Next nY
			If !Empty(::cMsgRet)
				OsLogCpl("OMSXCPLWS -> Envia -> 002 - Código(s) de erro(s): "+ cValToChar(::cMsgRet) + ".","ERROR" )
			EndIf
			If lViagJaLib
				::lSucesso := .T.
			EndIf
		EndIf
	EndIf
		
	If Empty(GetWSCError()) .And. Empty(::cMsgRet)
		::lSucesso := .T.
	EndIf
	
	::oRetorno := oXmlRet

	::RegistraRetorno()
Return ::lSucesso

WSMETHOD RegistraRetorno WSCLIENT OMSXCPLWS
Local oData := OMSXCPL3CLS():New()
Local aAreaTmp := {}

	If !::lSucesso
		oData:lDjw := .T.
		oData:ACAO := If(::nOperacao == MODEL_OPERATION_DELETE,'2','1')
		If !Empty(GetWSCError())

			//Grava erro retornado pelo WebService
			::cMsgRet += cValToChar(GetWSCError() ) + CRLF
			::cMsgRet += cValToChar(GetWSCError(2)) + CRLF
			::cMsgRet += cValToChar(GetWSCError(3)) + CRLF
			oData:MSGREG :=  GetWSCError()

			If IsBlind()
				oData:USRREG := "ENVBATCH POR JOB"
			EndIf

			If (::cTabela)->(IndexOrd()) != 1
				aAreaTmp := (::cTabela)->(GetArea())
				(::cTabela)->(dbSetOrder(1))
			EndIf

			oData:TABELA := ::cTabela
			oData:CHAVE  := (::cTabela)->(&((::cTabela)->(IndexKey())))

			If !Empty(aAreaTmp)
				RestArea(aAreaTmp)
			EndIf

			oData:RECTAB := (::cTabela)->(RecNo())

			OMSXCPL3REG(oData,cValToChar(GetWSCError()) + CRLF + cValToChar(GetWSCError(2)) + CRLF + cValToChar(GetWSCError(3)))
		Else

			If (::cTabela)->(IndexOrd()) != 1
				aAreaTmp := (::cTabela)->(GetArea())
				(::cTabela)->(dbSetOrder(1))
			EndIf

			oData:TABELA := ::cTabela
			oData:CHAVE  := (::cTabela)->(&((::cTabela)->(IndexKey())))

			If !Empty(aAreaTmp)
				RestArea(aAreaTmp)
			EndIf

			oData:RECTAB := (::cTabela)->(RecNo())

			oData:MSGREG := STR0007 + CRLF + ::cMsgRet // Ocorreram os seguintes erros ao enviar o registro:
			If IsBlind()
				oData:USRREG := "ENVIO POR JOB"
			EndIf
			OMSXCPL4REG(oData)
		EndIf
	Else
		oData:TABELA := ::cTabela
		oData:RECTAB := (::cTabela)->(RecNo())
		OMSXCPL4VER(oData)
	EndIf
	FreeObj(oData)

	If !Empty(::cMsgRet)
		OsLogCpl("OMSXCPLWS -> Envia -> 003 - Código(s) de erro(s): "+ cValToChar(::cMsgRet) + ".","ERROR")
	EndIf
Return

/*/{Protheus.doc} Finishing
	Classe cliente de webService para recebimento do XML de Finalização de Monitoramento 
@author Aluizio/Amanda
@since 13/07/2020
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function Finishing(oXmlBody,cConteudo)
	Local cRet := "" //Não é necessário gravação de XML de resposta para recebimento de Cancelamento de Monitoramento. Por este motivo, esta variável não é preenchida em nenhum momento.
	Local bErrorF := Errorblock({|e| lRet := .F.,TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Local lRet := .F.
	Begin Sequence
		lRet := OmsRecFin(oXmlBody,@cConteudo)
	End Sequence
	Errorblock(bErrorF)
Return cRet

/*/{Protheus.doc} WsdlFinishing
	Classe utilizada no momento de acesso ao WSDL via Browser.
@author Aluizio/Amanda
@since 13/07/2020
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function WsdlFinishing(lAutom)
	Local cRet := ""
	Default lAutom := .F.

	cRet += "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjx3c2"
	cRet += "RsOmRlZmluaXRpb25zIA0KCXhtbG5zOndzZGxzb2FwPSJodHRwOi8vc2No"
	cRet += "ZW1hcy54bWxzb2FwLm9yZy93c2RsL3NvYXAvIg0KCXhtbG5zOnRucz0iaH"
	cRet += "R0cDovL3d3dy5uZW9sb2cuY29tLmJyL2NwbC9wdWJsaXNoL21vbml0b3Jp"
	cRet += "bmcvZmluaXNoaW5nLyINCgl4bWxuczp3c2RsPSJodHRwOi8vc2NoZW1hcy"
	cRet += "54bWxzb2FwLm9yZy93c2RsLyINCgl4bWxuczp4c2Q9Imh0dHA6Ly93d3cu"
	cRet += "dzMub3JnLzIwMDEvWE1MU2NoZW1hIg0KCXRhcmdldE5hbWVzcGFjZT0iaH"
	cRet += "R0cDovL3d3dy5uZW9sb2cuY29tLmJyL2NwbC9wdWJsaXNoL21vbml0b3Jp"
	cRet += "bmcvZmluaXNoaW5nLyI+DQoJPHdzZGw6dHlwZXM+DQoJCTx4c2Q6c2NoZW"
	cRet += "1hDQoJCQl4bWxuczp4c2Q9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1M"
	cRet += "U2NoZW1hIg0KCQkJYXR0cmlidXRlRm9ybURlZmF1bHQ9InF1YWxpZmllZC"
	cRet += "IgDQoJCQllbGVtZW50Rm9ybURlZmF1bHQ9InF1YWxpZmllZCINCgkJCXRh"
	cRet += "cmdldE5hbWVzcGFjZT0iaHR0cDovL3d3dy5uZW9sb2cuY29tLmJyL2NwbC"
	cRet += "9wdWJsaXNoL21vbml0b3JpbmcvZmluaXNoaW5nLyI+DQoJCQkNCgkJCTx4"
	cRet += "c2Q6Y29tcGxleFR5cGUgbmFtZT0icmVzcG9uc2VNZXNzYWdlVHlwZSI+DQ"
	cRet += "oJCQkJPHhzZDpzZXF1ZW5jZT4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9"
	cRet += "InJlc3BvbnNlTWVzc2FnZSIgbWF4T2NjdXJzPSJ1bmJvdW5kZWQiPg0KCQ"
	cRet += "kJCQkJPHhzZDpjb21wbGV4VHlwZT4NCgkJCQkJCQk8eHNkOnNlcXVlbmNl"
	cRet += "Pg0KCQkJCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0ic291cmNlSWQiIHR5cG"
	cRet += "U9InhzZDpzdHJpbmciIC8+DQoJCQkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1l"
	cRet += "PSJ0eXBlIiB0eXBlPSJ4c2Q6c3RyaW5nIiAvPgkJCQkJCQkNCgkJCQkJCQ"
	cRet += "kJPHhzZDplbGVtZW50IG5hbWU9InJlc3VsdCIgdHlwZT0ieHNkOmJvb2xl"
	cRet += "YW4iIC8+CQkJCQkJCQkNCgkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9Im"
	cRet += "NvZGUiIHR5cGU9InhzZDpzdHJpbmciLz4NCgkJCQkJCQkJPHhzZDplbGVt"
	cRet += "ZW50IG5hbWU9Im1lc3NhZ2UiIHR5cGU9InhzZDpzdHJpbmciLz4NCgkJCQ"
	cRet += "kJCQkJPHhzZDplbGVtZW50IG5hbWU9ImRlc2NyaXB0aW9uIiB0eXBlPSJ4"
	cRet += "c2Q6c3RyaW5nIi8+DQoJCQkJCQkJPC94c2Q6c2VxdWVuY2U+DQoJCQkJCQ"
	cRet += "k8L3hzZDpjb21wbGV4VHlwZT4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJ"
	cRet += "CQk8L3hzZDpzZXF1ZW5jZT4NCgkJCTwveHNkOmNvbXBsZXhUeXBlPg0KCQ"
	cRet += "kJDQoJCQk8eHNkOmVsZW1lbnQgbmFtZT0icmVxdWVzdCI+DQoJCQkJPHhz"
	cRet += "ZDpjb21wbGV4VHlwZT4NCgkJCQkJPHhzZDpzZXF1ZW5jZT4JDQoJCQkJCQ"
	cRet += "k8eHNkOmVsZW1lbnQgbmFtZT0iZmluaXNoaW5nU2V0IiBtYXhPY2N1cnM9"
	cRet += "InVuYm91bmRlZCI+CQkJCQkNCgkJCQkJCQk8eHNkOmNvbXBsZXhUeXBlPg"
	cRet += "0KCQkJCQkJCQk8eHNkOnNlcXVlbmNlPgkJCQkJCQkJDQoJCQkJCQkJCQk8"
	cRet += "eHNkOmVsZW1lbnQgbmFtZT0ibW9uaXRvcmFibGVTb3VyY2VJZCIgdHlwZT"
	cRet += "0ieHNkOnN0cmluZyIgLz4NCgkJCQkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1l"
	cRet += "PSJtb25pdG9yYWJsZVR5cGUiIHR5cGU9InhzZDpzdHJpbmciLz4NCgkJCQ"
	cRet += "kJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJmaW5pc2hlZCIgdHlwZT0ieHNk"
	cRet += "OmJvb2xlYW4iIC8+CQkJCQkJCQkJCQkJCQkJDQoJCQkJCQkJCTwveHNkOn"
	cRet += "NlcXVlbmNlPgkJCQkJCQkJDQoJCQkJCQkJPC94c2Q6Y29tcGxleFR5cGU+"
	cRet += "DQoJCQkJCQk8L3hzZDplbGVtZW50PgkJDQoJCQkJCTwveHNkOnNlcXVlbm"
	cRet += "NlPg0KCQkJCTwveHNkOmNvbXBsZXhUeXBlPgkJCQkJCQkJCQ0KCQkJPC94"
	cRet += "c2Q6ZWxlbWVudD4NCg0KCQkJPHhzZDplbGVtZW50IG5hbWU9InJlc3Bvbn"
	cRet += "NlIj4NCgkJCQk8eHNkOmNvbXBsZXhUeXBlPg0KCQkJCQk8eHNkOnNlcXVl"
	cRet += "bmNlPg0KCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9Im1lc3NhZ2VzIiB0eX"
	cRet += "BlPSJ0bnM6cmVzcG9uc2VNZXNzYWdlVHlwZSIgLz4JCQkJCQkJCQkJCQkJ"
	cRet += "CQkJCQkJCQkJCQkNCgkJCQkJPC94c2Q6c2VxdWVuY2U+DQoJCQkJPC94c2"
	cRet += "Q6Y29tcGxleFR5cGU+DQoJCQk8L3hzZDplbGVtZW50PgkJCQkJDQoJCTwv"
	cRet += "eHNkOnNjaGVtYT4NCgk8L3dzZGw6dHlwZXM+DQoJDQoJPHdzZGw6bWVzc2"
	cRet += "FnZSBuYW1lPSJwdWJsaXNoRmluaXNoaW5nIj4NCgkJPHdzZGw6cGFydCBu"
	cRet += "YW1lPSJwYXJhbWV0ZXJzIiBlbGVtZW50PSJ0bnM6cmVxdWVzdCIgLz4NCg"
	cRet += "k8L3dzZGw6bWVzc2FnZT4NCgk8d3NkbDptZXNzYWdlIG5hbWU9InB1Ymxp"
	cRet += "c2hGaW5pc2hpbmdSZXNwb25zZSI+DQoJCTx3c2RsOnBhcnQgbmFtZT0icG"
	cRet += "FyYW1ldGVycyIgZWxlbWVudD0idG5zOnJlc3BvbnNlIiAvPg0KCTwvd3Nk"
	cRet += "bDptZXNzYWdlPg0KCQ0KCTx3c2RsOnBvcnRUeXBlIG5hbWU9InB1Ymxpc2"
	cRet += "hGaW5pc2hpbmdTZXJ2aWNlUG9ydFR5cGUiPg0KCQk8d3NkbDpvcGVyYXRp"
	cRet += "b24gbmFtZT0icHVibGlzaEZpbmlzaGluZyI+DQoJCQk8d3NkbDppbnB1dC"
	cRet += "BuYW1lPSJwdWJsaXNoRmluaXNoaW5nIiBtZXNzYWdlPSJ0bnM6cHVibGlz"
	cRet += "aEZpbmlzaGluZyIgLz4NCgkJCTx3c2RsOm91dHB1dCBuYW1lPSJwdWJsaX"
	cRet += "NoRmluaXNoaW5nUmVzcG9uc2UiIG1lc3NhZ2U9InRuczpwdWJsaXNoRmlu"
	cRet += "aXNoaW5nUmVzcG9uc2UiIC8+DQoJCTwvd3NkbDpvcGVyYXRpb24+DQoJPC"
	cRet += "93c2RsOnBvcnRUeXBlPg0KCQ0KCTx3c2RsOmJpbmRpbmcgbmFtZT0icHVi"
	cRet += "bGlzaEZpbmlzaGluZ1NlcnZpY2VIdHRwQmluZGluZyIgdHlwZT0idG5zOn"
	cRet += "B1Ymxpc2hGaW5pc2hpbmdTZXJ2aWNlUG9ydFR5cGUiPg0KCQk8d3NkbHNv"
	cRet += "YXA6YmluZGluZyBzdHlsZT0iZG9jdW1lbnQiIHRyYW5zcG9ydD0iaHR0cD"
	cRet += "ovL3NjaGVtYXMueG1sc29hcC5vcmcvc29hcC9odHRwIiAvPg0KCQk8d3Nk"
	cRet += "bDpvcGVyYXRpb24gbmFtZT0icHVibGlzaEZpbmlzaGluZyI+DQoJCQk8d3"
	cRet += "NkbHNvYXA6b3BlcmF0aW9uIHNvYXBBY3Rpb249IiIgLz4NCgkJCTx3c2Rs"
	cRet += "OmlucHV0IG5hbWU9InB1Ymxpc2hGaW5pc2hpbmciPg0KCQkJCTx3c2Rsc2"
	cRet += "9hcDpib2R5IHVzZT0ibGl0ZXJhbCIgLz4NCgkJCTwvd3NkbDppbnB1dD4N"
	cRet += "CgkJCTx3c2RsOm91dHB1dCBuYW1lPSJwdWJsaXNoRmluaXNoaW5nUmVzcG"
	cRet += "9uc2UiPg0KCQkJCTx3c2Rsc29hcDpib2R5IHVzZT0ibGl0ZXJhbCIgLz4N"
	cRet += "CgkJCTwvd3NkbDpvdXRwdXQ+DQoJCTwvd3NkbDpvcGVyYXRpb24+DQoJPC"
	cRet += "93c2RsOmJpbmRpbmc+DQoJDQoJPHdzZGw6c2VydmljZSBuYW1lPSJwdWJs"
	cRet += "aXNoRmluaXNoaW5nU2VydmljZSI+DQoJCTx3c2RsOnBvcnQgYmluZGluZz"
	cRet += "0idG5zOnB1Ymxpc2hGaW5pc2hpbmdTZXJ2aWNlSHR0cEJpbmRpbmciIG5h"
	cRet += "bWU9InB1Ymxpc2hGaW5pc2hpbmdTZXJ2aWNlSHR0cFBvcnQiPg0KCQkJPH"
	cRet += "dzZGxzb2FwOmFkZHJlc3MgbG9jYXRpb249Imh0dHA6Ly9sb2NhbGhvc3Q6"
	cRet += "ODA4MC9jb2NrcGl0LWdhdGV3YXkvbW9uaXRvcmluZy1pbnRlZ3JhdGlvbi"
	cRet += "1zb2FwL3dzL3B1Ymxpc2hGaW5pc2hpbmciIC8+DQoJCTwvd3NkbDpwb3J0"
	cRet += "Pg0KCTwvd3NkbDpzZXJ2aWNlPg0KPC93c2RsOmRlZmluaXRpb25zPg=="

	cRet := Decode64(cRet)
	//Alteração da informação location para o endereço informado na requisição
	If !Empty(cRet) .And. !lAutom
		cRet := LocWsdl(cRet)
	EndIf
	
Return cRet

/*/{Protheus.doc} LocWsdl
	Classe cliente de webService para gerar os dados do WSDL no Browser.
@author Aluizio/Amanda
@since 13/07/2020
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function LocWsdl(cRet)
Local cEnd := ""
Local cStr := ""
Local nRat
	
	cStr := StrToKarr(HTTPHEADIN->AHEADERS[1]," ")[2]
	nRat :=  Rat("?",cStr)
	If nRat > 0
		cStr := SubStr(cStr,1,nRat-1)
	EndIf
	cEnd := "http://" + httpHeadIn->HOST + cStr	
	cRet := StrTran(cRet,"[LOCATION]",cEnd)
	
Return cRet
