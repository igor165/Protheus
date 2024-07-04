#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI022
// GTPI022 - Adapter da rotina de Tipos de Linha
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
Function GTPI022(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'TypeOfLine'
Local aArea		:= GetArea()
Do Case
	//Envio da Mensage
	Case nTypeTrans == TRANS_SEND
		cXmlRet := GI022Send(@lRet)
	Case nTypeTrans == TRANS_RECEIVE
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				cXmlRet := GI022Resp(cXml,@lRet)
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cXmlRet := GI022Receb(cXml,@lRet)
		EndCase
EndCase
RestArea(aArea)
Return {lRet, cXmlRet, cMsgUnica}
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI022Send
// GI022Send - Função utilizada para montagem do Xml de Envio
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param lRet, logical, Valor passado por referencia para validar o processamento do adapter
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI022Send(lRet)
Local oModel	:= FwModelActive()
Local oMdlGQC	:= oModel:GetModel("GQCMASTER")
Local cXmlRet	:= ""
Local cXmlCont	:= ""
Local lDelete	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lMsblql	:= AllTrim(GetSx3Cache("GQC_MSBLQL", "X3_CAMPO")) == "GQC_MSBLQL"
Local cCode		:= oMdlGQC:GetValue("GQC_CODIGO")
Local cDesc		:= oMdlGQC:GetValue("GQC_DESCRI")
Local cIntId	:= GTPxMakeId(cCode, 'GQC')

cXMLRet := FWEAIBusEvent( 'TypeOfLine',oModel:GetOperation(), { { "InternalId", cIntID } } ) 

cXmlCont+= GxSetNode('CompanyId'		,cEmpAnt)
cXmlCont+= GxSetNode('BranchId'			,cFilAnt)
cXmlCont+= GxSetNode('CompanyInternalId',cEmpAnt + '|' + cFilAnt)
cXmlCont+= GxSetNode('Code'				,cCode)
cXmlCont+= GxSetNode('InternalId'		,cIntId)
cXmlCont+= GxSetNode('Description'		,cDesc)
If lMsblql
	cXmlCont+= GxSetNode('Situation',oMdlGQC:GetValue("GQC_MSBLQL"))
Endif
cXMLRet += GxSetNode('BusinessContent',cXmlCont,.T.,.F.)

If lDelete
	CFGA070MNT(NIL, "GQC", "GQC_CODIGO", NIL, cIntID, lDelete)
Endif

Return cXmlRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI022Resp
// GI022Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI022Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"TypeOfLine","GQC","GQC_CODIGO"})

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
/*/{Protheus.doc} GI022Receb
// GI022Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI022Receb(cXml,lRet)
Local oModel	:= FwLoadModel("GTPA022")
Local oMdlGQC	:= Nil
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
Local aCampos	:= {"GQC_FILIAL","GQC_CODIGO"}
Local aDados	:= {}
Local aIntId	:= {}
Local lMsblql	:= AllTrim(GetSx3Cache("GQC_MSBLQL", "X3_CAMPO")) == "GQC_MSBLQL"
Local n1		:= 0
If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cCode	:= GTPxRetId(cMarca, "GQC", "GQC_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. GQC->(DbSeek(xFilial('GQC')+cCode))
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
			oMdlGQC:= oModel:GetModel("GQCMASTER")
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGQC:GetValue("GQC_CODIGO"))
					aAdd(aDados,{"GQC_CODIGO",,cBusiCont + '/Code'})
				Endif
				aAdd(aDados,{"GQC_DESCRI",,cBusiCont + '/Description'})
				If lMsblql
					aAdd(aDados,{"GQC_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGQC,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
			Endif
			
			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGQC:GetValue('GQC_CODIGO'), 'GQC')
				Endif
				aAdd(aIntId, {"TypeOfLine",cExtId,cIntId,cMarca,"GQC","GQC_CODIGO"})
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
