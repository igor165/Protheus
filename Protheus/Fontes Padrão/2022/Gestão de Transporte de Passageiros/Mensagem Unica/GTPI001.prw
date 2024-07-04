#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI001
// GTPI001 - Adapter da rotina de Localidades
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param cXml, characters, O XML recebido pelo EAI Protheus
@param nTypeTrans, numeric, Tipo de transacao
		0	- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
		1	- para mensagem sendo enviada (DEFINE TRANS_SEND) 
@param cTypeMessage, characters, Tipo da mensagem do EAI
		20	- Business Message (DEFINE EAI_MESSAGE_BUSINESS)
		21	- Response Message (DEFINE EAI_MESSAGE_RESPONSE)
		22	- Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
		23	- WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@Return aRet, array, Retorna um array contendo as informações do adaper
		aRet[1]	- lRet		- Indica se ocorreu com sucesso
		aRet[2]	- cXMLRet	- String contendo o Xml que será Enviado
		aRet[3]	- cMsgUnica	- Nome do Adapter
@type function
/*/
Function GTPI001(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'Locality'
Local aArea		:= GetArea()

if nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem única TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI001Resp(cXml,@lRet)
		
		//chegada de mensagem de negócios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI001Receb(cXml,@lRet)
	EndCase
endif
		
RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001Resp
//GI001Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI001Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"Locality","GI1","GI1_COD"})

If oXml:Parse(cXml)
	GxResponse(oXml,aMsgUnic)
Else
	lRet	:= .F.
	cXmlRet := STR0009//"Falha no Parse"
Endif

GTPDestroy(aMsgUnic)
GTPDestroy(oXml)
Return cXMLRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001Receb
//GI001Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI001Receb(cXml,lRet)
Local oModel	:= FwLoadModel("GTPA001")
Local oMdlGI1	:= Nil
Local oXml		:= tXMLManager():New()
Local cXmlRet	:= ""
Local cBusiMsg	:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont := cBusiMsg+'/BusinessContent'
Local lDelete	:= .F.
Local cMarca	:= "PROTHEUS"
Local cIntID	:= ""
Local cExtID	:= ""
Local cCode		:= ""
Local nOpc		:= 0
Local lOk		:= .T.
Local cErro		:= ""
Local aCampos	:= {"GI1_FILIAL","GI1_COD"}
Local aDados	:= {}
Local aIntId	:= {}
Local lMsblql	:= AllTrim(GetSx3Cache("GI1_MSBLQL", "X3_CAMPO")) == "GI1_MSBLQL"
Local n1		:= 0
Local cExtLoc	:= ""
Local cIntLoc	:= ""
Local cLoc		:= ""
Local cHrGrRd	:= ""
Local cHrRdGr	:= ""

If oXml:Parse(cXml)
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cHrGrRd	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TravelTimeToRoad'))
	cHrRdGr	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TravelTimeToGarage'))
	
	cCode	:= GTPxRetId(cMarca, "GI1", "GI1_COD", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	GI1->(DbSetOrder(1))
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. GI1->(DbSeek(xFilial('GI1')+cCode))
			nOpc := MODEL_OPERATION_UPDATE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
		
	Else
		If lOk
			nOpc := MODEL_OPERATION_DELETE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		endif
	Endif
	If lRet .and. !Empty(cExtLoc	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LocalityTypeInternalId')))
		cLoc	:= GTPxRetId(cMarca, "G9V", "G9V_CODIGO", cExtLoc, @cIntLoc, 3,@lOk,@cErro,{"G9V_FILIAL","G9V_CODIGO"},1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlGI1:= oModel:GetModel("GI1MASTER")
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGI1:GetValue("GI1_COD"))
					aAdd(aDados,{"GI1_COD"	,			,cBusiCont + '/Code'})
				Endif
				aAdd(aDados,{"GI1_DESCRI"	,								,cBusiCont + '/Description'})
				aAdd(aDados,{"GI1_CODTIP"	,cLoc							,cBusiCont + '/LocalityTypeInternalId'})
				aAdd(aDados,{"GI1_PAIS"		,								,cBusiCont + '/Address/Country/CountryInternalId'})
				aAdd(aDados,{"GI1_UF"		,								,cBusiCont + '/Address/State/StateInternalId'})
				aAdd(aDados,{"GI1_CDMUNI"	,								,cBusiCont + '/Address/City/CityInternalId'})
				aAdd(aDados,{"GI1_AGENCI"	,								,cBusiCont + '/Agency'})
				aAdd(aDados,{"GI1_KMRDGR"	,								,cBusiCont + '/DistanceToGarage'})
				aAdd(aDados,{"GI1_KMGRRD"	,								,cBusiCont + '/DistanceToRoad'})
				aAdd(aDados,{"GI1_HRGRRD"	,GTFormatHour(cHrGrRd, '9999')	,cBusiCont + '/TravelTimeToRoad'})
				aAdd(aDados,{"GI1_HRRDGR"	,GTFormatHour(cHrRdGr, '9999')	,cBusiCont + '/TravelTimeToGarage'})
				aAdd(aDados,{"GI1_CODINT"	,								,cBusiCont + '/InternalCode'})
				
				If lMsblql
					aAdd(aDados,{"GI1_MSBLQL",			,cBusiCont + '/Situation'})
				Endif

				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGI1,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next

			Endif
			
			If lRet .and. oModel:VldData()
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGI1:GetValue('GI1_COD'), 'GI1')
				Endif
				aAdd(aIntId, {"Locality",cExtId,cIntId,cMarca,"GI1","GI1_COD"})
				cXmlRet := GxListOfId(aIntId,lDelete)
			Else
				lRet := .F.
				cXmlRet := GTPXErro(oModel)
			Endif
			oModel:DeActivate()
		Endif
	Endif
Else
	lRet	:= .F.
	cXmlRet := STR0009//"Falha no Parse"
Endif

oModel:Destroy()

GTPDestroy(oModel)
GTPDestroy(oXml)
GTPDestroy(aDados)
GTPDestroy(aIntId)
GTPDestroy(aCampos)
Return cXmlRet
