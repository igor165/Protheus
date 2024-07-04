#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI006
// GTPI006 - Adapter da rotina de Agencias
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
Function GTPI006(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'Agency'
Local aArea		:= GetArea()
Do Case
	//Envio da Mensage
	Case nTypeTrans == TRANS_SEND
		cXmlRet := GI006Send(@lRet)
	Case nTypeTrans == TRANS_RECEIVE
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				cXmlRet := GI006Resp(cXml,@lRet)
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cXmlRet := GI006Receb(cXml,@lRet)
		EndCase
EndCase
RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI006Send
// GI006Send - Função utilizada para montagem do Xml de Envio
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param lRet, logical, Valor passado por referencia para validar o processamento do adapter
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI006Send(lRet)
Local oModel	:= FwModelActive()
Local oMdlGI6	:= oModel:GetModel("GI6MASTER")
Local cXmlRet	:= ""
Local cXmlCont	:= ""
Local lDelete	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lMsblql	:= AllTrim(GetSx3Cache("GI6_MSBLQL", "X3_CAMPO")) == "GI6_MSBLQL"
Local cCode		:= oMdlGI6:GetValue("GI6_CODIGO")
Local cIntId	:= GTPxMakeId(cCode, 'GI6')
Local cColCode	:= oMdlGI6:GetValue("GI6_COLRSP")
Local cColIntId	:= GTPxMakeId(cColCode, 'GYG')
Local cLocCode	:= oMdlGI6:GetValue("GI6_LOCALI")
Local cLocIntId	:= GTPxMakeId(cLocCode, 'GI1')
Local cForn		:= oMdlGI6:GetValue("GI6_FORNEC")
Local cFornLj	:= oMdlGI6:GetValue("GI6_LOJA")
Local cCliente	:= oMdlGI6:GetValue("GI6_CLIENT")
Local cCliLj	:= oMdlGI6:GetValue("GI6_LJCLI")
cXMLRet := FWEAIBusEvent( 'Agency',oModel:GetOperation(), { { "InternalId", cIntID } } ) 

cXmlCont+= GxSetNode('CompanyId'				,cEmpAnt)
cXmlCont+= GxSetNode('BranchId'					,cFilAnt)
cXmlCont+= GxSetNode('CompanyInternalId'		,cEmpAnt + '|' + cFilAnt)
cXmlCont+= GxSetNode('Code'						,cCode)
cXmlCont+= GxSetNode('InternalId'				,cIntId)
cXmlCont+= GxSetNode('Description'				,oMdlGI6:GetValue("GI6_DESCRI"))
cXmlCont+= GxSetNode('Type'						,oMdlGI6:GetValue("GI6_TIPO"))
cXmlCont+= GxSetNode('CollaboratorCode'			,cColCode)
cXmlCont+= GxSetNode('CollaboratorInternalId'	,cColIntId)
cXmlCont+= GxSetNode('LocalityCode'				,cLocCode)
cXmlCont+= GxSetNode('LocalityInternalId'		,cLocIntId)
cXmlCont+= GxSetNode('VendorCode'				,cForn)
cXmlCont+= GxSetNode('VendorStore'				,cFornLj)
cXmlCont+= GxSetNode('VendorInternalId'			,IntForExt(, , cForn, cFornLj)[2])
cXmlCont+= GxSetNode('CustomerCode'				,cCliente)
cXmlCont+= GxSetNode('CustomerStore'			,cCliLj)
cXmlCont+= GxSetNode('CustomerInternalId'		,IntCliExt(, , cCliente,cCliLj)[2])
cXmlCont+= GxSetNode('DepositType'				,oMdlGI6:GetValue("GI6_DEPOSI"))
cXmlCont+= GxSetNode('ClosureType'				,oMdlGI6:GetValue("GI6_FCHCAI"))
cXmlCont+= GxSetNode('DaysToClosure'			,cValToChar(oMdlGI6:GetValue("GI6_DIASFC")))
cXmlCont+= GxSetNode('OnBoardSale'				,oMdlGI6:GetValue("GI6_VEMBAR"))

If lMsblql
	cXmlCont+= GxSetNode('Situation',oMdlGI6:GetValue("GI6_MSBLQL"))
Endif
cXMLRet += GxSetNode('BusinessContent',cXmlCont,.T.,.F.)

If lDelete
	CFGA070MNT(NIL, "GI6", "GI6_CODIGO", NIL, cIntID, lDelete)
Endif

Return cXmlRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI006Resp
// GI006Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI006Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"Agency","GI6","GI6_CODIGO"})

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
/*/{Protheus.doc} GI006Receb
// GI006Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI006Receb(cXml,lRet)
Local oModel	:= FwLoadModel("GTPA006")
Local oMdlGI6	:= oModel:GetModel("GI6MASTER")
Local oStrGI6	:= oMdlGI6:GetStruct() 
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
Local aCampos	:= {"GI6_FILIAL","GI6_CODIGO"}
Local aCpoGI1	:= {"GI1_FILIAL","GI1_COD"}
Local aCpoGYG	:= {"GYG_FILIAL","GYG_CODIGO"}
Local aDados	:= {}
Local aIntId	:= {}
Local aForn		:= {}
Local aCli		:= {}
Local lMsblql	:= AllTrim(GetSx3Cache("GI6_MSBLQL", "X3_CAMPO")) == "GI6_MSBLQL"
Local n1		:= 0

Local cExtLoc	:= ""
Local cLocCode	:= ""
Local cExtCol	:= ""
Local cColCode	:= ""
Local cForExt	:= ""
Local cForn		:= ""
Local cFornLj	:= ""
Local cCliExt	:= ""
Local cCliente	:= ""
Local cCliLj	:= ""


oStrGI6:SetProperty('GI6_FILRES',MODEL_FIELD_OBRIGAT,.F.)

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cCode	:= GTPxRetId(cMarca, "GI6", "GI6_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. GI6->(DbSeek(xFilial('GI6')+cCode))
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
	If lRet .and. !Empty(cExtLoc	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LocalityInternalId')))
		cLocCode	:= GTPxRetId(cMarca, "GI1", "GI1_COD", cExtLoc, , 3,@lOk,@cErro,aCpoGI1,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	If lRet .and. !Empty(cExtCol	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CollaboratorInternalId')))
		cColCode	:= GTPxRetId(cMarca, "GYG", "GYG_CODIGO", cExtCol, , 3,@lOk,@cErro,aCpoGYG,1)
		If !lOk
			lRet	:= .F.
			cXmlRet	:= GTPXErro(oModel,cErro)
		Endif
	Endif
	If lRet .and. !Empty(cForExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/VendorInternalId')))
		aForn	:= IntForInt(cForExt, cMarca)
		If !aForn[1]
			lRet		:= .F.
			cXmlRet		:= GTPXErro(oModel,aForn[2])
		Else
			cForn 	:= aForn[2][3]
			cFornLj	:= aForn[2][4]
		Endif
	Endif
	If lRet .and. !Empty(cCliExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CustomerInternalId')))
		aCli	:= IntCliInt(cCliExt, cMarca)
		If !aCli[1]
			lRet		:= .F.
			cXmlRet		:= GTPXErro(oModel,aCli[2])
		Else
			cCliente	:= aCli[2][3]
			cCliLj		:= aCli[2][4]
		Endif
	Endif
	
	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT
                    
                    If Empty(oMdlGI6:GetValue("GI6_CODIGO"))
                        aAdd(aDados,{"GI6_CODIGO",,cBusiCont + '/Code'})
                    Endif
                    
                    aAdd(aDados,{"GI6_TIPO"		,			,cBusiCont + '/Type'})

                Endif
                    
				aAdd(aDados,{"GI6_DESCRI"	,			,cBusiCont + '/Description'})				
				aAdd(aDados,{"GI6_COLRSP"	,cColCode	,cBusiCont + '/CollaboratorInternalId'})
				aAdd(aDados,{"GI6_LOCALI"	,cLocCode	,cBusiCont + '/LocalityInternalId'})
				aAdd(aDados,{"GI6_FORNEC"	,cForn		,cBusiCont + '/VendorInternalId'})
				aAdd(aDados,{"GI6_LOJA"		,cFornLj	,cBusiCont + '/VendorInternalId'})
				aAdd(aDados,{"GI6_CLIENT"	,cCliente	,cBusiCont + '/CustomerInternalId'})
				aAdd(aDados,{"GI6_LJCLI"	,cCliLj		,cBusiCont + '/CustomerInternalId'})
				aAdd(aDados,{"GI6_DEPOSI"	,			,cBusiCont + '/DepositType'})
				aAdd(aDados,{"GI6_FCHCAI"	,			,cBusiCont + '/ClosureType'})
				aAdd(aDados,{"GI6_DIASFC"	,			,cBusiCont + '/DaysToClosure'})
				aAdd(aDados,{"GI6_VEMBAR"	,			,cBusiCont + '/OnBoardSale'})
				If lMsblql
					aAdd(aDados,{"GI6_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGI6,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
			Endif
			
			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGI6:GetValue('GI6_CODIGO'), 'GI6')
				Endif
				aAdd(aIntId, {"Agency",cExtId,cIntId,cMarca,"GI6","GI6_CODIGO"})
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
GTPDestroy(aForn)
GTPDestroy(aCli)
GTPDestroy(aCpoGI1)
GTPDestroy(aCpoGYG)
Return cXmlRet