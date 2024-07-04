#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "APWEBEX.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

//Programa responsável por agrupar as estruturas de dados dos webservices
Function TMSXWS()
Return
/*/{Protheus.doc} deliveryUnit
	Contém os itens da viagem
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct deliveryUnit
	wsdata identifier as string
	wsdata viagem as string
	wsdata RegionalSourceId as string
	wsdata orderSourceId as string
	wsdata orderTypeSourceId as string
	wsdata orderItemSourceId as string
	wsdata productSourceId as string
	wsdata sequenceComposition as integer OPTIONAL
	wsdata quantity as float
	wsdata price as float OPTIONAL
	wsdata deliveryDate as Date
	wsdata integrationSource as string
	wsdata classifications as array of classification OPTIONAL
	wsdata deliveryUnitAttributes as array of tripAttribute OPTIONAL 
	wsmethod new
endwsstruct

wsmethod new wsclient deliveryUnit
	::classifications  := {}
	::deliveryUnitAttributes := {}
Return Self
/*/{Protheus.doc} shipmentUnit
	Dados quantitativos das unidades enviadas/recebidas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct shipmentUnit
	wsdata identifier as integer
	wsdata shipmentUnitCategoryId as integer
	wsdata shipmentUnitDescription as string OPTIONAL
	wsdata shipmentUnitQty as float
	wsdata weight as float OPTIONAL
	wsdata volume as float OPTIONAL
	wsdata length as float OPTIONAL
	wsdata width as float OPTIONAL
	wsdata height as float OPTIONAL
	wsdata palletHeightTotal as float OPTIONAL
	wsdata deliveryUnitList as array of deliveryUnit
	wsmethod new
endwsstruct

wsmethod new wsclient shipmentUnit
	::deliveryUnitList := {}
Return Self
/*/{Protheus.doc} subStop
	Representa uma operação dentro de um conjunto de paradas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct subStop
	wsdata identifier as integer
	wsdata arrivalTime as Date
	wsdata startServiceTime as Date OPTIONAL
	wsdata endServiceTime as Date OPTIONAL
	wsdata departureTime as Date
	wsdata dockId as string OPTIONAL
	wsdata dockDescription as string OPTIONAL
	wsdata loadedShipmentUnits as array of shipmentUnit OPTIONAL
	wsdata unloadedShipmentUnits as array of shipmentUnit OPTIONAL
	wsmethod new
endwsstruct

wsmethod new wsclient subStop
	::loadedShipmentUnits := {}
	::unloadedShipmentUnits := {}
Return Self
/*/{Protheus.doc} stop
	Agrupa as paradas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct stop
	wsdata identifier as integer
	wsdata localitySourceId as string
	wsdata transportZoneId as string
	wsdata transportZoneDescription as string optional
	wsdata sequenceOnLoad as integer
	wsdata subStops as array of subStop
	wsmethod new
endwsstruct

wsmethod new wsclient stop
	::subStops := {}
Return Self
/*/{Protheus.doc} load
	Classifica a operação de carregamento/descarregamento para as paradas relacionadas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct load
	wsdata identifier as integer
	wsdata serviceTypeId as integer
	wsdata serviceDescriptionType as string
	wsdata loadMode as integer
	wsdata modal as integer
	wsdata distance as float
	wsdata freight as float
	wsdata dispatchLimitTime as Date OPTIONAL
	wsdata stops as array of stop
	wsdata stopsLoads as array of stop //Controla o carregamento
	wsdata loadid as integer
	wsdata loadSourceId as STRING optional
	wsmethod new
endwsstruct

wsmethod new wsclient load
	::stops := {}
	::stopsLoads := {}
Return Self
/*/{Protheus.doc} classification
	Classe genérica para guardar atributos genéricos
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct classification
	wsdata type  AS string
	wsdata value AS string
	wsmethod new
endwsstruct

wsmethod new wsclient classification
Return Self
/*/{Protheus.doc} tripAttribute
	Classe genérica para guardar atributos genéricos
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct tripAttribute
	wsdata name  AS string
	wsdata value AS string
	wsmethod new
endwsstruct

wsmethod new wsclient tripAttribute
Return Self
/*/{Protheus.doc} orderBreakPart
	Identifica as quebras de um pedido
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct orderBreakPart
	wsdata regionSourceId AS string 	
	wsdata orderBreakPartId AS integer 	
	wsdata orderSourceId AS string 		
	wsdata orderTypeSourceId AS string 	
	wsdata orderItemSourceId AS string 	
	wsdata loadId AS integer 			
	wsdata shipmentUnitId AS integer 	
	wsdata quantShipmUnits AS float 	
	wsdata quantProdUnits AS float 		
	wsdata orderBreakPartAttributes AS ARRAY OF tripAttribute OPTIONAL
	wsmethod new
endwsstruct

wsmethod new wsclient orderBreakPart
	::orderBreakPartAttributes := {}
Return Self
/*/{Protheus.doc} tripReleaseRequest
	Solicitação de liberação de viagem, possui todos os dados da viagem
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct tripReleaseRequest
	wsdata regionSourceId AS string 	
	wsdata basketSourceId AS string OPTIONAL
	wsdata identifier AS integer 		
	wsdata freightValue AS float 	
	wsdata carrierId AS string 	
	wsdata vehicleId AS string 			
	wsdata vehicleDescription as string
	wsdata truckLicensePlate as string
	wsdata truckStateLicensePlate as string
	wsdata truckStatusId as string
	wsdata truckDescriptionStatus as string
	wsdata truckAxlesQuantity as integer
	wsdata tripClassificationSourceId as string
	wsdata classifications as array of classification
	wsdata tripReleaseRequestAttributes as array of tripAttribute
	wsdata comments as string
 	wsdata loads as array of load
	wsmethod new
endwsstruct

wsmethod new wsclient tripReleaseRequest
	::classifications := {}
	::tripReleaseRequestAttributes := {}
	::loads := {}
Return Self
/*/{Protheus.doc} trip
	Classe que representa uma viagem do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct trip
	wsdata tripId AS integer
	wsdata loads as array of load
	wsmethod new
	wsmethod newload
endwsstruct

wsmethod new wsclient trip
	::loads := {}
Return Self

wsmethod newload wsclient trip
	Local oLoad := load():New()
	oLoad:loadid := 0
	oLoad:loadSourceId := ""
	aAdd(::loads,oLoad)
Return oLoad
/*/{Protheus.doc} ServiceReprogram
	Classe que representa a entrada das solicitações de cancelamento e reprogramação do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct ServiceReprogram
	wsdata basketSourceId as String
	wsdata regionSourceId as String
	wsdata trips as array of trip
	wsmethod new
	wsmethod newtrip
endwsstruct

wsmethod new wsclient ServiceReprogram
	::trips := {}
Return Self

wsmethod newtrip wsclient ServiceReprogram
	Local oTrip := trip():New()
	oTrip:tripId := 0
	aAdd(::trips,oTrip)
Return oTrip
/*/{Protheus.doc} ReprogramResponse
	Classe que representa a resposta das solicitações de cancelamento e reprogramação do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct ReprogramResponse
	wsdata Result as ReprogramResponse_Result
	wsmethod new
	WSMETHOD SOAPSEND
endwsstruct

wsmethod new WSCLIENT ReprogramResponse
	::Result := ReprogramResponse_Result():New()
Return Self 

WSMETHOD SOAPSEND WSCLIENT ReprogramResponse
	Local cSoap := ""
	cSoap += WSSoapValue("Result", ::Result, Result , "ReprogramResponse_Result", .F. , .F., 0 , NIL, .F.)
Return cSoap

wsstruct ReprogramResponse_Result
	wsData items as array of ReprogramResponse_item
	WSMETHOD SOAPSEND
	wsmethod new
	wsmethod newitem
endwsstruct

WSMETHOD new WSCLIENT ReprogramResponse_Result
	::items := {}
Return Self

WSMETHOD newitem WSCLIENT ReprogramResponse_Result
	Local oItem := ReprogramResponse_item():New()
	aAdd(::items,oItem)
Return oItem

WSMETHOD SOAPSEND WSCLIENT ReprogramResponse_Result
	Local cSoap := ""
	aEval( ::items , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "item", .F. , .F., 0 , NIL, .F.)  } )
Return cSoap
/*/{Protheus.doc} ReprogramResponse_item
	Classe que representa os itens das respostas das solicitações de cancelamento e reprogramação do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct ReprogramResponse_item
	wsdata Tripid as INTEGER
	wsdata Regionsourceid as String 
	WSDATA Status AS INTEGER
	WSDATA Errormessage AS ARRAY OF String OPTIONAL
	WSMETHOD SOAPSEND
	wsmethod new
	wsmethod newErrormessage
endwsstruct

WSMETHOD new WSCLIENT ReprogramResponse_item
	::Errormessage := {}
Return Self

WSMETHOD newErrormessage WSSEND cMsg WSCLIENT ReprogramResponse_item
	aAdd(::Errormessage,NoAcento(cMsg))
Return Len(::Errormessage)

WSMETHOD SOAPSEND WSCLIENT ReprogramResponse_item
	Local cSoap := ""
	cSoap += WSSoapValue("Tripid", ::Tripid, Tripid , "INTEGER", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("Regionsourceid", ::Regionsourceid, Regionsourceid , "STRING", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("Status", ::Status, Status , "INTEGER", .F. , .F., 0 , NIL, .F.)
	If !Empty(::Errormessage)
		aEval( ::Errormessage , {|x| cSoap := cSoap  +  WSSoapValue("Errormessage", x , x , "STRING", .F. , .F., 0 , NIL, .F.)  } )
	EndIf
Return cSoap
//Rotina chamada na criação de um nova thread para recebimento de informações.
//Enquanto a thread persistir, serão mantidos as informações de conexão com o ambiente/banco de dados

Static __aWsMethod := {}
Static __aWsWsdl   := {}
Static __TmsSoapFault := {"","",""}
Static __cStrEnv := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body>'
Static __cEndEnv := '</soapenv:Body></soapenv:Envelope>'
Static __XmlDef := '<?xml version="1.0" encoding="UTF-8"?>'


Function ReprogramService(oXmlBody,cConteudo, lAutom)
	Local cRet := ""
	Local oRet
	Local bErrorF := Errorblock({|e| TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Default lAutom := .F. //Nao permite execucao de envio soap com automacao

	OsLogCpl("TMSXWS -> ReprogramService -> Validação no Ambiente","INFO" )
	
	Begin Sequence
	If nModulo == 39 .And. ExistFunc("OmsRepTrip")
		oRet := OmsRepTrip(oXmlBody,@cConteudo)
	EndIf
	End Sequence
	Errorblock(bErrorF)

	cRet += StrTran(__cStrEnv,'/"><', '/" xmlns:ns1="urn:neolog:cockpit:TripReprogrammingRequestService"><')
	If !lAutom
		cRet += WSSoapValue("ns1:publishReprogrammingServiceResponse", oRet, oRet , "publishReprogrammingService", .F. , .F., 0 , NIL, .F.)
	EndIf
	cRet += __cEndEnv

	OsLogCpl("TMSXWS -> ReprogramService -> Fim do processo.","INFO")
	
Return cRet


Function CancelService(oXmlBody,cConteudo,lAutom)
	Local cRet := ""
	Local oRet
	Local bErrorF := Errorblock({|e| TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Default lAutom := .F. //Nao permite execucao de envio soap com automacao

	OsLogCpl("TMSXWS -> CancelService -> Validação no Ambiente","INFO" )

	Begin Sequence
	If nModulo == 39 .And. ExistFunc("OmsCanTrip")
		oRet := OmsCanTrip(oXmlBody,@cConteudo)
	EndIf
	End Sequence
	Errorblock(bErrorF)
	
	cRet += StrTran(__cStrEnv,'/"><', '/" xmlns:ns1="urn:neolog:cockpit:TripCancelRequestService"><')
	If !lAutom
		cRet += WSSoapValue("ns1:publishCancelServiceResponse", oRet, oRet , "publishCancelServiceResponse", .F. , .F., 0 , NIL, .F.)
	EndIf
	cRet += __cEndEnv

	OsLogCpl("TMSXWS -> CancelService -> Fim do processo.","INFO")
	
Return cRet

Function PublishReleasedTrip(oXmlBody,cConteudo)
	Local cRet := ""
	Local bErrorF := Errorblock({|e| lRet := .F.,TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Local lRet := .F.
	Local lOMSTOL01	 := ExistBlock("OMSTOL01")

	Begin Sequence
		If nModulo == 39 .And. ExistFunc("OmsRecTrip")
			If lOMSTOL01
				OsLogCpl("TMSXWS -> PublishReleasedTrip -> Inicio execução do Ponto de entrada OMSTOL01.","INFO")
				lRet := ExecBlock("OMSTOL01",.F.,.F.,{@oXmlBody,@cConteudo})
				OsLogCpl("TMSXWS -> PublishReleasedTrip -> Retorno da execução do Ponto de entrada OMSTOL01." + cValToChar(lRet),"INFO")
			EndIf
			If !lRet
				lRet := OmsRecTrip(oXmlBody,@cConteudo)
			EndIf
		EndIf
	End Sequence
	Errorblock(bErrorF)
	cRet += __cStrEnv
	cRet += '<ns1:publishReleasedTripResponse xmlns:ns1="urn:neolog:cockpit:TripReleaseRequestPublishingService">' + If(lRet,"S","N") + '</ns1:publishReleasedTripResponse>'
	cRet += __cEndEnv
Return cRet


/*/{Protheus.doc} TMSXStart
	
@author siegklenes.beulke
@since 01/09/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function TMSXStart()
	Local lRet := TMSWSInit(,"TMSWS")
Return lRet

Function TMSXConnect()
 	Local cHtml := ""
 	Local cContent := HttpOtherContent()
 	Local cError
	Local cWarning
	Local oXmlSoap
	Local nX
	Local cScan
	Local cFault
	Local cStr
	Local bError := Errorblock({|e|})
	Private XMLREC
	If HTTPHEADIN->MAIN == "TMSXCONNECT"
		//TODO Listar os webservices de recepção disponíveis
		Return ""
	EndIf
	// Inicializa o objeto de falha, para desconsiderar falhas de chamadas anteriores
	__TmsSoapFault := {"","",""}
 	httpHeadOut->CONTENT_TYPE := "application/xml"
 	If "WSDL" $ UPPER(HTTPHEADIN->AHEADERS[1]) .And. Empty(cContent)
 		//Requisição de WSDL
 		cScan := "WSDL" + HTTPHEADIN->MAIN
 		nX := aScan(__aWsWsdl, {|x| x == cScan})
 		
 		If nX == 0
 			If FindFunction(cScan)
 				aAdd(__aWsWsdl,cScan)
 				nX := Len(__aWsWsdl)
 			Else
 				SetFaultTMS('Falha ambiente',"Metodo " + cScan + " não encontrado")
 			EndIf
 		EndIf
 		
 		If nX != 0
 			cHtml := &cScan.()
 		EndIf
 	
	Else
		cScan := HTTPHEADIN->MAIN
 		nX := aScan(__aWsMethod, {|x| x == cScan})
 		
 		If nX == 0
 			If FindFunction(cScan)
 				aAdd(__aWsMethod,cScan)
 				nX := Len(__aWsMethod)
 			Else
 				SetFaultTMS('Falha ambiente',"Metodo " + cScan + " não encontrado")
 			EndIf
 		EndIf
 		
 		If nX != 0
				
			cError := ""
			cWarning := ""
			oXmlSoap := XmlParser(cContent, "NS1", @cError,  @cWarning )
			
			If !Empty(cWarning)
				TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] Aviso ' + cWarning)
			EndIf
			
			If Empty(cError)
				XMLREC := oXmlSoap
 				cHtml := &cScan.(TMSXGetItens("Envelope:Body","O"),@cContent)
 			Else
 				Begin Sequence
				OMSXGRVLOG("TMSXWS",@cContent,"DJZ")
				End Sequence
				ErrorBlock(bError)
				SetFaultTMS('Erro ao interpretar o xml recebido',cError)
			EndIf
		EndIf
		
	EndIf

	cFault := GetFaultTMS()
	If !Empty(cFault)
		cHtml := cFault
		TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + cHtml)
	EndIf
	
Return cHtml

Function SetFaultTMS(cCod,cMsg,cTipo)
	Default cTipo := "Server"
	If !Empty(cTipo) .And. LOWER(cTipo) != "client" .And. LOWER(cTipo) != "server"
		TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] SetFaultTMS:Tipo de mensagem pode nao ser suportado ' + cTipo)
	Else
		If LOWER(cTipo) == "client"
			cTipo := "Client"
		Else
			cTipo := "Server"
		EndIf
	EndIf
	__TmsSoapFault := {EncodeUtf8(cCod),EncodeUtf8(cMsg),cTipo}
Return

Function GetFaultTMS()
	Local cRet := ""
	If !Empty(__TmsSoapFault[1]) .And. !Empty(__TmsSoapFault[2]) .And. !Empty(__TmsSoapFault[3])
		cRet += __XmlDef
		cRet += __cStrEnv
		cRet += "<soapenv:Fault>"
		cRet += "<faultcode>" + __TmsSoapFault[1] + ":" + __TmsSoapFault[3] + "</faultcode>"
		cRet += "<faultstring>" + __TmsSoapFault[2] + "</faultstring>"
		cRet += "</soapenv:Fault>"
		cRet += __cEndEnv
	EndIf
Return cRet


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
