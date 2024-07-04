#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI035
// GTPI035 - Adapter da rotina de Tipos de localidade
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param cXml, characters, O XML recebido pelo EAI Protheus
@param nTypeTrans, numeric, Tipo de transacao
		0	- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
		1	- para mensagem sendo enviada (DEFINE TRANS_So EAIEND) 
@param cTypeMessage, characters, Tipo da mensagem d
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
Function GTPI035(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'LocalityType'
Local aArea		:= GetArea()
Do Case
	//Envio da Mensage
	Case nTypeTrans == TRANS_SEND
		cXmlRet := GI035Send(@lRet)
	Case nTypeTrans == TRANS_RECEIVE
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				cXmlRet := GI035Resp(cXml,@lRet)
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cXmlRet := GI035Receb(cXml,@lRet)
		EndCase
EndCase
RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI035Send
// GI035Send - Função utilizada para montagem do Xml de Envio
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param lRet, logical, Valor passado por referencia para validar o processamento do adapter
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI035Send(lRet)
Local oModel	:= FwModelActive()
Local oMdlG9V	:= oModel:GetModel("G9VMASTER")
Local cXmlRet	:= ""
Local cXmlCont	:= ""
Local lDelete	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lMsblql	:= AllTrim(GetSx3Cache("G9V_MSBLQL", "X3_CAMPO")) == "G9V_MSBLQL"
Local cCode		:= oMdlG9V:GetValue("G9V_CODIGO")
Local cDesc		:= oMdlG9V:GetValue("G9V_DESCRI")
Local cIntId	:= GTPxMakeId(cCode, 'G9V')

cXMLRet := FWEAIBusEvent( 'LocalityType',oModel:GetOperation(), { { "InternalId", cIntID } } ) 

cXmlCont+= GxSetNode('CompanyId'		,cEmpAnt)
cXmlCont+= GxSetNode('BranchId'			,cFilAnt)
cXmlCont+= GxSetNode('CompanyInternalId',cEmpAnt + '|' + cFilAnt)
cXmlCont+= GxSetNode('Code'				,cCode)
cXmlCont+= GxSetNode('InternalId'		,cIntId)
cXmlCont+= GxSetNode('Description'		,cDesc)
If lMsblql
	cXmlCont+= GxSetNode('Situation',oMdlG9V:GetValue("G9V_MSBLQL"))
Endif
cXMLRet += GxSetNode('BusinessContent',cXmlCont,.T.,.F.)

If lDelete
	CFGA070MNT(NIL, "G9V", "G9V_CODIGO", NIL, cIntID, lDelete)
Endif

Return cXmlRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI035Resp
// GI035Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI035Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"LocalityType","G9V","G9V_CODIGO"})

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
/*/{Protheus.doc} GI035Receb
// GI035Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI035Receb(cXml,lRet)
Local oModel	:= FwLoadModel("GTPA035")
Local oMdlG9V	:= Nil
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
Local aCampos	:= {"G9V_FILIAL","G9V_CODIGO"}
Local aDados	:= {}
Local aIntId	:= {}
Local lMsblql	:= AllTrim(GetSx3Cache("G9V_MSBLQL", "X3_CAMPO")) == "G9V_MSBLQL"
Local n1		:= 0
If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cCode	:= GTPxRetId(cMarca, "G9V", "G9V_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. G9V->(DbSeek(xFilial('G9V')+cCode))
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
	
	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlG9V:= oModel:GetModel("G9VMASTER")
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlG9V:GetValue("G9V_CODIGO"))
					aAdd(aDados,{"G9V_CODIGO",,cBusiCont + '/Code'})
				Endif
				aAdd(aDados,{"G9V_DESCRI",,cBusiCont + '/Description'})
				If lMsblql
					aAdd(aDados,{"G9V_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlG9V,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
			Endif
			
			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlG9V:GetValue('G9V_CODIGO'), 'G9V')
				Endif
				aAdd(aIntId, {"LocalityType",cExtId,cIntId,cMarca,"G9V","G9V_CODIGO"})
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
