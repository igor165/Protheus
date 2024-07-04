#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI118
GTPI118 - Adapter da rotina de Receitas e Despesas Adicionais
@author jacomo.fernandes
@since 16/08/2017
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
		aRet[2]	- cXMLRet	- String contendo o Xml que serÃ¡ Enviado
		aRet[3]	- cMsgUnica	- Nome do Adapter
@type function
/*/

Function GTPI118(cXml, nTypeTrans, cTypeMessage,cVersao )
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'TicketCategory'
Local aArea		:= GetArea()
Do Case
	//Envio da Mensage
	Case nTypeTrans == TRANS_SEND
		cXmlRet := GI118Send(@lRet)
	Case nTypeTrans == TRANS_RECEIVE
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem Única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				cXmlRet := GI118Resp(cXml,@lRet)
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cXmlRet := GI118Receb(cXml,@lRet)
		EndCase
EndCase
RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI118Send

@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param lRet, loG9Bal, Valor passado por referencia para validar o processamento do adapter
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI118Send(lRet)
Local oModel	:= FwModelActive()
Local oMdlG9B	:= oModel:GetModel("G9BMASTER")
Local cXmlRet	:= ""
Local cXmlCont	:= ""
Local lDelete	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lMsblql   := AllTrim(GetSx3Cache("G9B_MSBLQL", "X3_CAMPO")) == "G9B_MSBLQL"
Local cIntId	:= GTPxMakeId(oMdlG9B:GetValue('G9B_CODIGO'), 'G9B')

cXMLRet := FWEAIBusEvent( 'TicketCategory',oModel:GetOperation(), { { "InternalId", cIntID } } ) 

cXmlCont+= GxSetNode('CompanyId'		,cEmpAnt)
cXmlCont+= GxSetNode('BranchId'			,cFilAnt)
cXmlCont+= GxSetNode('CompanyInternalId',cEmpAnt + '|' + cFilAnt)
cXmlCont+= GxSetNode('Code'				,oMdlG9B:GetValue('G9B_CODIGO'))
cXmlCont+= GxSetNode('InternalId'		,cIntId)
cXmlCont+= GxSetNode('Description'		,oMdlG9B:GetValue('G9B_DESCRI'))

If lMsblql
	cXmlCont+= GxSetNode('Situation',oMdlG9B:GetValue("G9B_MSBLQL"))
Endif

cXMLRet += GxSetNode('BusinessContent'	,cXmlCont	,.F.,.F.)

If lDelete
	CFGA070MNT(NIL, "G9B", "G9B_CODIGO", NIL, cIntID, lDelete)
Endif

Return cXmlRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GII118Resp

@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, loG9Bal, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI118Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"TicketCategory","G9B","G9B_CODIGO"})

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
/*/{Protheus.doc} GI118Receb

@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, loG9Bal, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI118Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA118")
Local oMdlG9B		:= Nil
Local oXml			:= tXMLManager():New()
Local cXmlRet		:= ""
Local cBusiMsg		:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont		:= cBusiMsg+'/BusinessContent'
Local lDelete		:= .F.
Local cMarca		:= "PROTHEUS"
Local cCode			:= ""
Local cIntID		:= ""
Local cExtID		:= ""
Local nOpc			:= 0
Local lOk			:= .T.
Local cErro			:= ""
Local aCpoG9B		:= {"G9B_FILIAL","G9B_CODIGO"}// Receitas/Despesas Adicionais
Local aDados		:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("G9B_MSBLQL", "X3_CAMPO")) == "G9B_MSBLQL"
Local n1			:= 0

If Type("Inclui") == "U"
	Private Inclui := .F.
Endif

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	
	cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
    cCode		:= GTPxRetId(cMarca, "G9B", "G9B_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCpoG9B,1)
	
	If lRet
		G9B->(DbSetOrder(1))//G9B_FILIAL+G9B_CODIGO
		If !lDelete
			If Empty(cIntID)
				nOpc := MODEL_OPERATION_INSERT
				Inclui := .T.
			ElseIf lOk .and. G9B->(DbSeek(xFilial('G9B')+cCode))
				nOpc := MODEL_OPERATION_UPDATE
			Else 
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
			Endif
		ElseIf lOk .and. G9B->(DbSeek(xFilial('G9B')+cCode))
			nOpc := MODEL_OPERATION_DELETE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,STR0007)
		Endif
	Endif


	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlG9B := oModel:GetModel('G9BMASTER')

			If !lDelete
	
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlG9B:GetValue("G9B_CODIGO"))
					aAdd(aDados,{"G9B_CODIGO"	,		,cBusiCont + '/Code'})
				Endif
              
				aAdd(aDados,{"G9B_DESCRI"	,			,cBusiCont + '/Description'})
              	If lMsblql
              		aAdd(aDados,{"G9B_MSBLQL"	,			,cBusiCont + '/Situation'})
              	Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlG9B,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				
			Endif
			

			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlG9B:GetValue('G9B_CODIGO'), 'G9B')
				Endif
				cXmlRet := GxListOfId({{"TicketCategory",cExtID,cIntId,cMarca,"G9B","G9B_CODIGO"}},lDelete)
			Else
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
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
GTPDestroy(oMdlG9B)
GTPDestroy(oXml)
GTPDestroy(aDados)		

Return cXmlRet