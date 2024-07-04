#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI420
//TODO GTPI420 - Adapter da rotina de Categorias
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
Function GTPI420(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'SalesType'
Local aArea		:= GetArea()
Do Case
	//Envio da Mensage
	Case nTypeTrans == TRANS_SEND
		cXmlRet := GI420Send(@lRet)
	Case nTypeTrans == TRANS_RECEIVE
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				cXmlRet := GI420Resp(cXml,@lRet)
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cXmlRet := GI420Receb(cXml,@lRet)
		EndCase
EndCase
RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420Send
//TODO GI420 Send - Função utilizada para montagem do Xml de Envio
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param lRet, logical, Valor passado por referencia para validar o processamento do adapter
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI420Send(lRet)
Local oModel	:= FwModelActive()
Local oMdlGZC	:= oModel:GetModel("GZCMASTER")
Local cXmlRet	:= ""
Local cXmlCont	:= ""
Local lDelete	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lMsblql	:= AllTrim(GetSx3Cache("GZC_MSBLQL", "X3_CAMPO")) == "GZC_MSBLQL"
Local cCode		:= oMdlGZC:GetValue("GZC_CODIGO")
Local cDesc		:= oMdlGZC:GetValue("GZC_DESCRI")
Local cType		:= oMdlGZC:GetValue("GZC_TIPO")
Local cOwn			:= oMdlGZC:GetValue("GZC_PROPRI")
Local cIntId		:= GTPxMakeId(cCode, 'GZC')

cXMLRet := FWEAIBusEvent( 'SalesType',oModel:GetOperation(), { { "InternalId", cIntID } } ) 

cXmlCont+= GxSetNode('CompanyId'		,cEmpAnt)
cXmlCont+= GxSetNode('BranchId'			,cFilAnt)
cXmlCont+= GxSetNode('CompanyInternalId',cEmpAnt + '|' + cFilAnt)
cXmlCont+= GxSetNode('Code'				,cCode)
cXmlCont+= GxSetNode('InternalId'		,cIntId)
cXmlCont+= GxSetNode('Description'		,cDesc)
cXmlCont+= GxSetNode('Type	'			,cType)
cXmlCont+= GxSetNode('Own	'			,cOwn)


If lMsblql
	cXmlCont+= GxSetNode('Situation',oMdlGZC:GetValue("GZC_MSBLQL"))
Endif
cXMLRet += GxSetNode('BusinessContent',cXmlCont,.T.,.F.)

If lDelete
	CFGA070MNT(NIL, "GZC", "GZC_CODIGO", NIL, cIntID, lDelete)
Endif

Return cXmlRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420Resp
//TODO GI011Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI420Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"SalesType","GZC","GZC_CODIGO"})

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
/*/{Protheus.doc} GI420Receb
//TODO GI011Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI420Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA420")
Local oMdlGZC		:= Nil
Local oStruGZC	:= oModel:GetModel('GZCMASTER'):GetStruct()
Local oXml			:= tXMLManager():New()
Local cXmlRet		:= ""
Local cBusiMsg	:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont	:= cBusiMsg+'/BusinessContent'
Local lDelete		:= .F.
Local cMarca		:= "PROTHEUS"
Local cIntID		:= ""
Local cExtID		:= ""
Local cCode		:= ""
Local nOpc			:= 0
Local lOk			:= .T.
Local cErro		:= ""
Local aCampos		:= {"GZC_FILIAL","GZC_CODIGO"}
Local aDados		:= {}
Local aIntId		:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("GZC_MSBLQL", "X3_CAMPO")) == "GZC_MSBLQL"
Local n1			:= 0
Local cCodGZC		:= ""

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cCode	:= GTPxRetId(cMarca, "GZC", "GZC_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. GZC->(DbSeek(xFilial('GZC')+cCode))
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
			oMdlGZC:= oModel:GetModel("GZCMASTER")
			
			If !lDelete
			
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGZC:GetValue("GZC_CODIGO"))
					cCodGZC := GI420PrxNum()
					oMdlGZC:SetValue('GZC_CODIGO', cCodGZC)
					oMdlGZC:SetValue('GZC_PROPRI', 'S')
					
					aAdd(aDados,{"GZC_CODIGO",cCodGZC,cBusiCont + '/Code'})
				Endif

				aAdd(aDados,{"GZC_DESCRI",,cBusiCont + '/Description'})
				aAdd(aDados,{"GZC_TIPO",,cBusiCont + '/Type'})
				
				If lMsblql
					aAdd(aDados,{"GZC_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGZC,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				
			Endif
			
			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGZC:GetValue('GZC_CODIGO'), 'GZC')
				Endif
				
				aAdd(aIntId, {"SalesType",cExtId,cIntId,cMarca,"GZC","GZC_CODIGO"})
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

Static Function GI420PrxNum()
Local cCodigo 	:= ""
Local cAliasGZC	:= GetNextAlias()

	BeginSql Alias cAliasGZC
	 		
		SELECT ISNULL(MAX(GZC_CODIGO),'000') CODIGO
	 	FROM %Table:GZC% GZC
		WHERE
		GZC.GZC_FILIAL = %xFilial:GZC%
		   AND GZC.%NotDel%
			      
	EndSql 		    
	  
	cCodigo	:= Soma1((cAliasGZC)->CODIGO)
	
	(cAliasGZC)->(dbCloseArea())	

Return cCodigo



