#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI000
// GTPI000 - Adapter da rotina de Tipos de Órgãos
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
Function GTPI000(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'GrantingAgency'
Local aArea		:= GetArea()

if nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem única TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI000Resp(cXml,@lRet)
		
		//chegada de mensagem de negócios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI000Receb(cXml,@lRet)
	EndCase
endif

RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI000Resp
//GI000Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI000Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"GrantingAgency","GI0","GI0_COD"})

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
/*/{Protheus.doc} GI000Receb
// GI000Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI000Receb(cXml,lRet)
Local oModel	:= FwLoadModel("GTPA000")
Local oMdlGI0	:= Nil
Local oMdlGQD	:= Nil
Local oXml		:= tXMLManager():New()
Local cXmlRet	:= ""
Local cBusiMsg	:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont := cBusiMsg+'/BusinessContent'
Local cLstOFItem:= cBusiCont+'/ListOfTypeOfLine/TypeOfLine[XXX]'
Local cLine		:= ""
Local lDelete	:= .F.
Local cMarca	:= "PROTHEUS"
Local cIntID	:= ""
Local cExtID	:= ""
Local cCode		:= ""
Local cCodeGQC	:= ""
Local cExtGQC	:= ""
Local nOpc		:= 0
Local lOk		:= .T.
Local cErro		:= ""
Local cMsgErro	:= ""
Local aCampos	:= {"GI0_FILIAL","GI0_COD"}
Local aCpoGQC	:= {"GQC_FILIAL","GQC_CODIGO"}
Local aDados	:= {}
Local aIntId	:= {}
Local aItens	:= {}
Local lMsblql	:= AllTrim(GetSx3Cache("GI0_MSBLQL", "X3_CAMPO")) == "GI0_MSBLQL"
Local n1		:= 0
Local n2		:= 0
Local nCont		:= 0
If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cCode	:= GTPxRetId(cMarca, "GI0", "GI0_COD", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. GI0->(DbSeek(xFilial('GI0')+cCode))
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
			oMdlGI0:= oModel:GetModel("GI0MASTER")
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGI0:GetValue("GI0_COD"))
					aAdd(aDados,{"GI0_COD",,cBusiCont + '/Code'})
				Endif
				aAdd(aDados,{"GI0_DESCRI",,cBusiCont + '/Description'})
				aAdd(aDados,{"GI0_SIGLA",,cBusiCont + '/Initials'})

				If lMsblql
					aAdd(aDados,{"GI0_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGI0,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				
				If lRet .and. (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfTypeOfLine') ) > 0
					oMdlGQD := oModel:GetModel("GQDDETAIL")
					For n2 := 1 to nCont
						cLine	:= StrTran(cLstOFItem,"[XXX]","["+cValToChar(n2)+"]")
						cExtGQC	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/TypeOfLineInternalId'))
						cCodeGQC:= PadR(GTPxRetId(cMarca, "GQC", "GQC_CODIGO", cExtGQC,, 3,@lOk,@cErro,aCpoGQC,1),TamSx3("GQC_CODIGO")[1])
						If lOk
							If !oMdlGQD:SeekLine({{"GQD_CODGQC",cCodeGQC}})
								If oMdlGQD:IsEmpty() .or. (oMdlGQD:Length() < oMdlGQD:AddLine())
									If !(lRet := oMdlGQD:SetValue('GQD_CODGQC',cCodeGQC))
										Exit
									Endif
								Endif
							Endif
						Else
							lRet := .F.
							cMsgErro := cErro
							Exit
						Endif
						aAdd(aItens,cCodeGQC)
						If 	!oMdlGQD:VldLineData()
							lRet := .F.
						Endif
					Next
					For n2 := 1 to oMdlGQD:Length()
						oMdlGQD:GoLine(n2)
						If aScan(aItens,oMdlGQD:GetValue("GQD_CODGQC")) == 0
							If !(lRet := oMdlGQD:DeleteLine())
								Exit
							Endif
						Endif
					Next
				Endif
			Endif
			
			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGI0:GetValue('GI0_COD'), 'GI0')
				Endif
				aAdd(aIntId, {"GrantingAgency",cExtId,cIntId,cMarca,"GI0","GI0_COD"})
				cXmlRet := GxListOfId(aIntId,lDelete)
			Else
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cMsgErro)
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
GTPDestroy(oMdlGQD)
GTPDestroy(oXml)
GTPDestroy(aDados)
GTPDestroy(aIntId)
GTPDestroy(aCampos)
GTPDestroy(aCpoGQC)
Return cXmlRet
