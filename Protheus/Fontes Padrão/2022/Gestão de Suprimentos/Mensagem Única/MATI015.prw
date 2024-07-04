#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH" 
#INCLUDE "MATI015.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static oModelSBE

Function MATI015MOD(oNewModel)
	oModelSBE := oNewModel
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI015

Funcao de integracao com o adapter EAI para recebimento do cadastro de
Endere�os (SBE) utilizando o conceito de mensagem unica.

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
Function MATI015(cXml, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
   Local cVersao     := ""
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local aRet        := {}

   Private lIntegPPI := .F.
   Private oXml      := Nil

   Default cVersion	 := ''
   Default cTransac	 := ''
   Default lEAIObj	 := .F.

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
         aRet := v1000( cXml, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXml )
      Else
			If ( Empty( cVersion ) )
	           lRet    := .F.
	           cXmlRet := STR0001 //"Vers�o n�o informada no cadastro do adapter."
	           Return {lRet, cXmlRet}
			Else
				cVersao := StrTokArr( cVersion, ".")[1]
			EndIf

	     If cVersao == "1"
	        aRet := v1000( cXml, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXml )
	     Else
	        lRet    := .F.
	        cXmlRet := STR0003 //"A vers�o da mensagem informada n�o foi implementada!"
	        Return {lRet, cXmlRet}
	     EndIf

	   EndIf
   EndIf

   If lIntegPPI
      lRet    := aRet[1] 
      cXMLRet := aRet[2]
   Else
      lRet    := IIf( Type( 'aRet[1]' ) == 'U', .F., aRet[1] )
      cXMLRet := IIf( Type( 'aRet[2]' ) == 'U', "" , aRet[2] )
   EndIf
Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para envio do  cadastro de
Endere�os (SBE) utilizando o conceito de mensagem unica.

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
Static Function v1000( cXml, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, oXml )
	Local lRet       := .T.
	Local lLog       := .T. //FindFunction("AdpLogEAI")
	Local cXMLRet    := ""
	Local cEvent     := ""
	Local cEntity	 := 'AddressStock'
	Local aAreaAnt   := GetArea()
	Local oModel
	Local cRotina	 := "MATA015"
	
	If !lIntegPPI
		IIf(lLog, AdpLogEAI(1, cRotina , nTypeTrans, cTypeMessage, cXML), Nil ) //"Atualize o UPDINT01.prw para utilizar o log"
	EndIf

	If Empty(oModelSBE)
		oModel := FwModelActive()
	Else
		oModel := oModelSBE
	EndIf
	
	oModel := oModel:GetModel("MdFieldSBE")
	
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
		cXMLRet +=       '<key name="InternalID">' + IntEndeExt(/*Empresa*/, /*Filial*/, oModel:GetValue('BE_LOCAL')+'|'+oModel:GetValue('BE_LOCALIZ'), /*Vers�o*/)[2] + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<WarehouseCode>'+ oModel:GetValue('BE_LOCAL') +'</WarehouseCode>'
		cXMLRet +=    '<LocationCode>'+ oModel:GetValue('BE_LOCALIZ') +'</LocationCode>'
		cXMLRet +=    '<AddressInternalId>'+ cEmpAnt+'|'+cFilAnt+'|'+oModel:GetValue('BE_LOCAL')+'|'+oModel:GetValue('BE_LOCALIZ') +'</AddressInternalId>'
		cXMLRet +=    '<AddressStockDescription>'+ oModel:GetValue('BE_DESCRIC') +'</AddressStockDescription>'
		cXmlRet += '</BusinessContent>'
		
		If lIntegPPI
			completXml(@cXMLRet)
		EndIf
	EndIf

	If !lIntegPPI
		IIf(lLog, AdpLogEAI(5, cRotina , cXMLRet, lRet), Nil ) //"Atualize o UPDINT01.prw para utilizar o log"
	EndIf
	RestArea(aAreaAnt)
Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntEndeExt
Monta o InternalID do endere�o de acordo com o c�digo passado
no par�metro.

@param   cEmpresa   C�digo da empresa (Default cEmpAnt)
@param   cFil       C�digo da Filial (Default cFilAnt)
@param   cEnder     C�digo do endere�o
@param   cVersao    Vers�o da mensagem �nica (Default 1.000)

@author  Lucas Konrad Fran�a
@version P118
@since   04/04/2016
@return  aResult Array contendo no primeiro par�metro uma vari�vel
         l�gica indicando se o registro foi encontrado.
         No segundo par�metro uma vari�vel string com o InternalID
         montado.

@sample  IntEndeExt(,,'01') ir� retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntEndeExt(cEmpresa, cFil, cEnder, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SBE')
   Default cVersao  := '1.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cEnder))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0005 + Chr(10) + STR0006) // "Vers�o do recurso n�o suportada." "As vers�es suportadas s�o: 1.000"
   EndIf   
Return aResult

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
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/AddressStock_1_000.xsd">'
   cCabec +=     '<MessageInformation version="1.000">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>AddressStock</Transaction>'
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
