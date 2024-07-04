#Include "Protheus.ch"
#Include "FWAdapterEAI.ch"
#Include "NGMUCH.ch"

#Define _ADAPT_ 'NGMUGetSit'				//Nome do Adapter
#Define _DESCR_ 'GetEmployeeSituations'	//Nome da Mensagem �nica

//----------------------------------------------------------------------------------
/*/{Protheus.doc} NGMUGetSit
Realiza chamada da fun��o respons�vel pela integra��o com mensagem unica (IntegDef)
para consulta da situa��o de um ou mais funcion�rios num determinado per�odo de tempo.

@author Pedro Henrique Soares de Souza
@since 07/05/15

@param cCodIni		Funcion�rio(Code) em que deseja iniciar a consulta. (Obrigat.)
@param dDataIni	Data em que deseja iniciar a consulta. (Obrigat.)
@param dDataFim	Data onde a consulta deve ser finalizada.
@param cFilFun	Filial do funcion�rio

@example NGMUGetSit('000001', '07/05/2015')
@example NGMUGetSit('000001', '01/04/2015', '30/04/2015')

@return aEmpSit	Array bidimensional contendo c�digo e situa��o do func.
/*/
//----------------------------------------------------------------------------------
Function NGMUGetSit( cCodIni, dDataIni, dDataFim ,cFilFun)

	Default dDataFim	:= dDataIni
	Default cFilFun		:= xFilial("SRA")

	Private _aEmpSit	:= Array(2) //Array bidimensional contendo c�digo e situa��o do func.

	Private _cCodIni	:= cCodIni
	Private _cFilFun	:= cFilFun

	Private _dDataIni	:= dDataIni
	Private _dDataFim	:= dDataFim

	MsgRun(STR0023, _DESCR_,; //'Aguarde integra��o com backoffice...'
			{|| FWIntegDef(_ADAPT_, EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, _ADAPT_) })

Return _aEmpSit[1]

//--------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integra��o com Mensagem �nica: Consulta da Situa��o de um ou mais funcion�rios.

@author Pedro Henrique Soares de Souza
@since 07/05/15

@return aRet	[1] lRet -> Define se o envio foi realizado com sucesso. [.T. = Sim]
				[2] cXmlRet -> String do conteudo do xml.
/*/
//--------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local lXmlRet := .F.
	Local cXmlRet := ""
	Local aXmlRet := {}

	//Recebimento de mensagem XML de outro sistema
	If nTypeTrans == TRANS_RECEIVE

		//Mensagem enviada de outro sistema
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			lXmlRet    := .T.

		//Retorno da mensagem XML enviada para outro sistema
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			lXmlRet := fRespXML(cXML, nTypeTrans, cTypeMessage )
			_aEmpSit[1] := lXmlRet

		Endif

	//Envio de mensagem XML para outro sistema
	ElseIf nTypeTrans == TRANS_SEND

		aXmlRet := fSendXML()
		lXmlRet := aXmlRet[1]
		cXmlRet := aXmlRet[2]

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet, '< --', ':::')

	//Ponto de entrada para altera��o do XML
	If ExistBlock("NGMUPE01")
   		cXmlRet := ExecBlock("NGMUPE01", .F., .F., {cXmlRet, lXmlRet, _ADAPT_, 1, nTypeTrans, cTypeMessage})
	Endif

Return { lXmlRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} fSendXML
Fun��o respons�vel pelo envio da Mensagem �nica.

@author Pedro Henrique Soares de Souza
@since 07/05/15
/*/
//-------------------------------------------------------------------
Static Function fSendXML()

	Local cXmlSend	:= ""

	//Carrega apenas data do retorno da FWTimeStamp
	Local cDataIXML	:= SubStr( FWTimeStamp ( 3, _dDataIni, '00:00:00' ), 1, 10)
	Local cDataFXML	:= SubStr( FWTimeStamp ( 3, _dDataFim, '00:00:00' ), 1, 10)

	cXmlSend += FWEAIBusRequest( Upper(_DESCR_) )

	cXmlSend += '<BusinessContent>'
	cXmlSend += '  <RequestEmployeeSituations>'
	cXmlSend += '    <StartEmployeeCode>'	+ _cCodIni									+ '</StartEmployeeCode>'
	cXmlSend += '	 <InternalId>'          + cEmpAnt + '|' + _cFilFun + '|' + _cCodIni + '</InternalId>'
	cXmlSend += '    <CompanyId>'			+ cEmpAnt									+ '</CompanyId>'
	cXmlSend += '    <BranchId>'			+ cFilAnt									+ '</BranchId>'
	cXmlSend += '    <CompanyInternalId>'	+ cEmpAnt + '|' + cFilAnt					+ '</CompanyInternalId>'
	cXmlSend += '    <StartDate>'			+ cDataIXML									+ '</StartDate>'
	cXmlSend += '    <FinishDate>'			+ cDataFXML									+ '</FinishDate>'
	cXmlSend += '    <FinishEmployeeCode/>'
	cXmlSend += '  </RequestEmployeeSituations>'
	cXmlSend += '</BusinessContent>'

Return {.T., cXmlSend}

//-------------------------------------------------------------------
/*/{Protheus.doc} fRespXML
Fun��o respons�vel pelo recebimento da Mensagem �nica.

@author Pedro Henrique Soares de Souza
@since	07/05/15
/*/
//-------------------------------------------------------------------
Static Function fRespXML(cXml, nTypeTrans, cTypeMessage)

	Local cError, cWarning, nX, xEmpSit
	Local cRetResp  := ""
	Local aXml 		:= {}
	Local lXmlRet := .T.

	Store ''  To cError, cWarning

	oXmlMU 	:= XmlParser(cXML, "_", @cError, @cWarning)

	If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

		aXml := NGMUValRes(oXmlMU,STR0024)

		//Retorno da mensagem XML n�o apresenta problemas, possui cosist�ncia em outro ambiente integrado
		If !aXml[1]

			lXmlRet := .F.

			NGIntMULog(_ADAPT_, cValToChar(nTypeTrans) + "|" + cTypeMessage, cXml)

		//Retorno da mensagem XML bem sucedida
		Else
			xEmpSit := oXmlMU:_TotvsMessage:_ResponseMessage:_ReturnContent:_ReturnEmployeeSituations:_ListOfEmployeeSituations:_Employee:_ListOfSituations:_Situation

			//Verifica se h� uma situa��o ou mais. Caso seja apenas uma situa��o:
			If ValType( xEmpSit ) == "O"

				If xEmpSit:_SituationInformation:_SituationMeaning:Text <> '1'

					lXmlRet := .F. //Indica afastamento

				EndIf

			//Caso sejam mais de uma situa��o:
			ElseIf ValType( xEmpSit ) == "A"

				For nX := 1 To Len(xEmpSit)

					If xEmpSit[nX]:_SituationInformation:_SituationMeaning:Text <> '1'

						lXmlRet := .F.
						Exit

					EndIf
				Next nX

			EndIf
		EndIf
	Else
		lXmlRet := .F.
	EndIf

Return lXmlRet
