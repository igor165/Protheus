#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH" 
#INCLUDE "SFCI006.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static oModel

Function SFCI006MOD(oNewModel)
	oModel := oNewModel
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCI006

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Recursos (CYH) utilizando o conceito de mensagem unica.

@param   cXml        Vari�vel com conte�do XML para envio/recebimento.
@param   nTypeTrans   Tipo de transa��o. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad Fran�a
@version P118
@since   22/03/2016
@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
        o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
        TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
        O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Function SFCI006(cXml, nTypeTrans, cTypeMessage)
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local aRet        := {}
   
   Private lIntegPPI := .F.
   Private oXml      := Nil

   //Verifica se est� sendo executado para realizar a integra��o com o PPI.
   //Se a vari�vel lRunPPI estiver definida, e for .T., assume que � para o PPI.
   //Vari�vel � criada no fonte mata200.prw, na fun��o mata200PPI().
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      /*
         Mensagem desenvolvida para integra��o com o PCFactory, n�o possui recebimento.
      */
   ElseIf nTypeTrans == TRANS_SEND
      If lIntegPPI
         aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
			lRet    := aRet[1]
			cXMLRet := aRet[2]
	   EndIf
   EndIf


Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para envio do  cadastro de
Recursos (CYH) utilizando o conceito de mensagem unica.

@param   cXml        Vari�vel com conte�do XML para envio/recebimento.
@param   nTypeTrans   Tipo de transa��o. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad Fran�a
@version P118
@since   24/03/2016
@return  aRet  - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml)
	Local lRet       := .T.
	Local lLog       := .T. //FindFunction("AdpLogEAI")
	Local aArea      := GetArea()
	Local lIntgSFC   := Iif(SuperGetMV("MV_INTSFC",.F.,0)==1,.T.,.F.)
	Local aAreaRec   := Iif(lIntgSFC,CYH->(GetArea()),SH4->(GetArea())) 
	Local cXMLRet    := ""
	Local cEvent     := ""
	Local cEntity    := "Resource"
	Local nDias      := 0
	Local cTpVida    := ""
	Local nVidaUtil  := 0
	
	//Informa��es enviadas
	Local cCode      := ""
	Local cType      := ""
	Local cName      := ""
	Local cPrdArea   := ""
	Local cDPrdArea  := ""
	Local cShiftNum  := ""
	Local cLaborCode := ""
	Local dStExpDate := StoD("")
	Local dEdExpDate := StoD("")
	Local nCycle     := ""
	Local cToolCode  := ""
	Local cToolDesc  := ""
	
	
	If lIntgSFC
		If Empty(oModel)
			oModel := FwModelActive()
		EndIf
		cCode      := AllTrim(oModel:GetValue("CYHMASTER","CYH_CDRC"))
		cType      := AllTrim(oModel:GetValue("CYHMASTER","CYH_TPRC"))
		cName      := AllTrim(oModel:GetValue("CYHMASTER","CYH_NMRC"))
		cPrdArea   := AllTrim(oModel:GetValue("CYHMASTER","CYH_CDARPO"))
		cDPrdArea  := AllTrim(Posicione("CYA",1,xFilial("CYA")+oModel:GetValue("CYHMASTER","CYH_CDARPO"),"CYA_DSARPO"))
		cShiftNum  := AllTrim(oModel:GetValue("CYHMASTER","CYH_NRTN"))
		cLaborCode := AllTrim(oModel:GetValue("CYHMASTER","CYH_CDMOD"))
		dStExpDate := oModel:GetValue("CYHMASTER","CYH_DTVDBG")
		dEdExpDate := oModel:GetValue("CYHMASTER","CYH_DTVDED")
		nCycle     := oModel:GetValue("CYHMASTER","CYH_QTUNCI")
		cToolCode  := AllTrim(oModel:GetValue("CYHMASTER","CYH_CDMPRC"))
		cToolDesc  := AllTrim(Posicione("CZ3",1,XFILIAL("CZ3")+oModel:GetValue("CYHMASTER","CYH_CDMPRC"), "CZ3_DSAC"))
	Else
		cCode      := AllTrim(SH4->H4_CODIGO)
		cName      := AllTrim(SH4->H4_DESCRI)
		cShiftNum  := AllTrim(SH4->H4_TURNO)
		cTpVida    := AllTrim(SH4->H4_TIPOVID)
		nVidaUtil  := SH4->H4_VIDAUTI
		
		cType      := "2"		
		cPrdArea   := ""
		cDPrdArea  := ""
		cLaborCode := ""
		dStExpDate := dDataBase
		dEdExpDate := dDataBase
		
		If cTpVida == "D"
			dEdExpDate := dDataBase + nVidaUtil
		ElseIf cTpVida == "H"
			nDias   := Int(nVidaUtil/24)
			dEdExpDate := If(Empty(nDias),dDataBase,dDataBase + nDias)
		ElseIf cTpVida == "M"
			dEdExpDate := dDataBase + (nVidaUtil * 30)
		Else
			dEdExpDate := dDataBase + (nVidaUtil * 365)
		EndIf
		nCycle     := 1
		cToolCode  := ""
		cToolDesc  := ""
	EndIf

	If !lIntegPPI
	    If lLog
	    	AdpLogEAI(1, "SFCI006", nTypeTrans, cTypeMessage, cXML)    
	    EndIf
		//IIf(lLog, AdpLogEAI(1, "SFCI006", nTypeTrans, cTypeMessage, cXML), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
	EndIf

	If nTypeTrans == TRANS_RECEIVE
		/*
			Mensagem desenvolvida para integra��o com o PCFactory, e nao possui recebimento.
		*/
	ElseIf nTypeTrans == TRANS_SEND
		// Verifica se � uma exclus�o
		If !Inclui .And. !Altera
			cEvent := 'delete'
		Else
			cEvent := 'upsert'
		EndIf

		// Monta XML de envio de mensagem unica
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
		cXMLRet +=    '<Event>' + cEvent + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalID">' + IntRecExt(/*Empresa*/, /*Filial*/, cCode, /*Vers�o*/)[2] + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<Code>'+cCode+'</Code>'
		cXMLRet +=    '<Type>'+cType+'</Type>'
		cXMLRet +=    '<Name>'+cName+'</Name>'
		cXMLRet +=    '<ProductionAreaCode>'+cPrdArea+'</ProductionAreaCode>'
		cXMLRet +=    '<ProductionAreaDescription>'+cDPrdArea+'</ProductionAreaDescription>'
		cXMLRet +=    '<ProductionShiftNumber>'+cShiftNum+'</ProductionShiftNumber>'
		cXMLRet +=    '<LaborCode>'+cLaborCode+'</LaborCode>'
		cXMLRet +=    '<StartExpirationDate>'+getDate(dStExpDate)+'</StartExpirationDate>'
		cXMLRet +=    '<EndExpirationDate>'+getDate(dEdExpDate)+'</EndExpirationDate>'
		cXMLRet +=    '<UnitCycleQuantity>'+cValToChar(nCycle)+'</UnitCycleQuantity>'
		cXMLRet +=    '<ToolCode>'+cToolCode+'</ToolCode>'
		cXMLRet +=    '<ToolDescription>'+cToolDesc+'</ToolDescription>'
		cXmlRet += '</BusinessContent>'

		If lIntegPPI
			completXml(@cXMLRet)
		EndIf
	EndIf

	If !lIntegPPI
		If lLog
			AdpLogEAI(5, "SFCI006", cXMLRet, lRet)
		EndIf
		//IIf(lLog, AdpLogEAI(5, "SFCI006", cXMLRet, lRet), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
	EndIf
	If lIntgSFC
		CYH->(RestArea(aAreaRec))
	Else
		SH4->(RestArea(aAreaRec))
	EndIf
	RestArea(aArea)
Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabe�alho da mensagem quando utilizado integra��o com o PPI.

@param   cXML  - XML gerado pelo adapter. Par�metro recebido por refer�ncia.

@author  Lucas Konrad Fran�a
@version P12
@since   13/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
   Local cCabec     := ""
   Local cCloseTags := ""
   Local cGenerated := ""

   cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/Resource_1_000.xsd">'
   cCabec +=     '<MessageInformation version="1.000">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>Resource</Transaction>'
   cCabec +=         '<StandardVersion>1.0</StandardVersion>'
   cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
   cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
   cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
   cCabec +=         '<UserId>'+__cUserId+'</UserId>'
   cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
   cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
   cCabec +=         '<ContextName>PROTHEUS</ContextName>'
   cCabec +=         '<DeliveryType>Sync</DeliveryType>'
   cCabec +=     '</MessageInformation>'
   cCabec +=     '<BusinessMessage>'

   cCloseTags := '</BusinessMessage>'
   cCloseTags += '</TOTVSMessage>'
   
   cXML := cCabec + cXML + cCloseTags

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDate()
Formata uma data para o padr�o enviado por XML (YYYY-MM-DD)

@param   dDate  - Data que ser� transformada para String

@author  Lucas Konrad Fran�a
@version P12
@since   04/04/2016
@return  cDate
/*/
//-------------------------------------------------------------------
Static Function getDate(dDate)
   Local cDate     := ""

   If !Empty(dDate)
      cDate := DtoS(dDate)
      cDate := SubStr(cDate, 1, 4) + '-' + SubStr(cDate, 5, 2) + '-' + SubStr(cDate, 7, 2)
   EndIf
Return cDate