#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI002
// GTPI002 - Adapter da rotina de Tipos de Órgãos
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
Function GTPI002(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'Line'
Local aArea		:= GetArea()

If nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem única TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI002Resp(cXml,@lRet)
		
		//chegada de mensagem de negócios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI002Receb(cXml,@lRet)
	EndCase
Endif

RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI002Resp
// GI002Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI002Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"Line","GI2","GI2_COD"})

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
/*/{Protheus.doc} GI002Receb
// GI002Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI002Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA002")
Local oMdlGI2		:= Nil
Local oMdlG5I		:= Nil
Local oXml			:= tXMLManager():New()
Local cXmlRet		:= ""
Local cBusiMsg	:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont	:= cBusiMsg+'/BusinessContent'
Local cLstOFItem	:= cBusiCont+'/ListOfStretch/Stretch'
Local cLine		:= ""
Local lDelete		:= .F.
Local cMarca		:= "PROTHEUS"
Local cIntID		:= ""
Local cExtID		:= ""
Local cCode		:= ""
Local nOpc			:= 0
Local lOk			:= .T.
Local cErro		:= ""
Local cMsgErro	:= ""
Local aCampos		:= {"GI2_FILIAL","GI2_COD",{"GI2_HIST","2"}}
Local aCpoG9U		:= {"G9U_FILIAL","G9U_CODIGO"}//VIAS
Local aCpoGI0		:= {"GI0_FILIAL","GI0_COD"}//ÓRGÃOS
Local aCpoGQC		:= {"GQC_FILIAL","GQC_CODIGO"}//Tipos de Linhas
Local aCpoGYR		:= {"GYR_FILIAL","GYR_CODIGO"}//Categoria
Local aCpoGI1		:= {"GI1_FILIAL","GI1_COD"}//Localidade
Local aDados		:= {}
Local aDadosSeq	:= {}
Local aIntId		:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("GI2_MSBLQL", "X3_CAMPO")) == "GI2_MSBLQL"
Local n1			:= 0
Local n2			:= 0
Local nCont		:= 0
Local cViaExt 	:= ""
Local cViaCode	:= ""
Local cOrgaoExt	:= ""
Local cOrgaoCode	:= ""
Local cTpLineExt	:= ""
Local cTpLineCod	:= ""
Local cLnCatExt	:= ""
Local cLnCatCode	:= ""
Local cOriLocExt	:= ""
Local cOriLocCod	:= ""
Local cDesLocExt	:= ""
Local cDesLocCod	:= ""
Local cTempo		:= ""
Local oStruGI2		:= oModel:GetModel('FIELDGI2'):GetStruct()

oStruGI2:SetProperty('GI2_TIPLIN'  , MODEL_FIELD_OBRIGAT,     .F. )

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	
	cCode	:= GTPxRetId(cMarca, "GI2", "GI2_COD", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,4)
	
	GI2->(DbSetOrder(4))
	If !lDelete
		If Empty(cIntID)
			nOpc := MODEL_OPERATION_INSERT
		ElseIf lOk .and. GI2->(DbSeek(xFilial('GI2')+cCode+"2"))
			nOpc := MODEL_OPERATION_UPDATE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Else
		If lOk .and. GI2->(DbSeek(xFilial('GI2')+cCode+"2"))
			nOpc := MODEL_OPERATION_DELETE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		endif
	Endif
	
	If lRet .and. !Empty(cViaExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/RouteInternalId')))
		cViaCode	:= GTPxRetId(cMarca, "G9U", "G9U_CODIGO", cViaExt, , 3,@lOk,@cErro,aCpoG9U,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	If lRet .and. !Empty(cOrgaoExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/GrantingAgencyInternalId')))
		cOrgaoCode	:= GTPxRetId(cMarca, "GI0", "GI0_COD", cOrgaoExt, , 3,@lOk,@cErro,aCpoGI0,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	If lRet .and. !Empty(cTpLineExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TypeOfLineInternalId')))
		cTpLineCod	:= GTPxRetId(cMarca, "GQC", "GQC_CODIGO", cTpLineExt, , 3,@lOk,@cErro,aCpoGQC,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	If lRet .and. !Empty(cLnCatExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LineCategoryInternalId')))
		cLnCatCode	:= GTPxRetId(cMarca, "GYR", "GYR_CODIGO", cLnCatExt, , 3,@lOk,@cErro,aCpoGYR,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	If lRet .and. !Empty(cOriLocExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/OriginLocalityInternalId')))
		cOriLocCod	:= GTPxRetId(cMarca, "GI1", "GI1_COD", cOriLocExt, , 3,@lOk,@cErro,aCpoGI1,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	If lRet .and. !Empty(cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DestinyLocalityInternalId')))
		cDesLocCod	:= GTPxRetId(cMarca, "GI1", "GI1_COD", cDesLocExt, , 3,@lOk,@cErro,aCpoGI1,1)
		If !lOk
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Endif
	
	
	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlGI2:= oModel:GetModel("FIELDGI2")
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGI2:GetValue("GI2_COD"))
					aAdd(aDados,{"GI2_COD"	,			,cBusiCont + '/Code'})
				Endif
				aAdd(aDados,{"GI2_VIA"	,cViaCode	,cBusiCont + '/RouteInternalId'})
				aAdd(aDados,{"GI2_ORGAO"	,cOrgaoCode	,cBusiCont + '/GrantingAgencyInternalId'})
				aAdd(aDados,{"GI2_TIPLIN"	,cTpLineCod	,cBusiCont + '/TypeOfLineInternalId'})
				aAdd(aDados,{"GI2_CATEG"	,cLnCatCode	,cBusiCont + '/LineCategoryInternalId'})
				aAdd(aDados,{"GI2_LOCINI"	,cOriLocCod	,cBusiCont + '/OriginLocalityInternalId'})
				aAdd(aDados,{"GI2_LOCFIM"	,cDesLocCod	,cBusiCont + '/DestinyLocalityInternalId'})
				aAdd(aDados,{"GI2_PREFIX"	,			,cBusiCont + '/Prefix'})
				aAdd(aDados,{"GI2_KMIDA"	,			,cBusiCont + '/TravelDistance'})
				aAdd(aDados,{"GI2_HRIDA"	,			,cBusiCont + '/TravelTime'})
				aAdd(aDados,{"GI2_KMVOLT"	,			,cBusiCont + '/ReturnDistance'})
				aAdd(aDados,{"GI2_HRVOLT"	,			,cBusiCont + '/ReturnTravelTime'})
				aAdd(aDados,{"GI2_KMTOTA"	,			,cBusiCont + '/TotalDistance'})
				aAdd(aDados,{"GI2_HRPADR"	,			,cBusiCont + '/StandardTime'})
				aAdd(aDados,{"GI2_PASESC"	,			,cBusiCont + '/AllowsSchoolPass'})
				aAdd(aDados,{"GI2_NUMLIN"	,			,cBusiCont + '/LineNumber'})
				
				oModel:GetModel("GRIDG5I"):DelAllLine()
				
				If lMsblql
					aAdd(aDados,{"GI2_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGI2,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				oMdlG5I := oModel:GetModel("GRIDG5I")
				
				If lRet .and. (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfStretch') ) > 0
					
					For n2 := 1 to nCont
						cLine		:= cLstOFItem+"["+cValToChar(n2)+"]"
						cLocExt		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/LocalityInternalId')) 
						cTempo		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/StretchTravelTime'))
						cSeq		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/Sequence'))
						If !Empty(cSeq)
							cSeq		:= StrZero(Val(cSeq),TamSx3('G5I_SEQ')[1])
						Else
							cSeq		:= StrZero(n2,TamSx3('G5I_SEQ')[1])
						Endif
						If  n2 == nCont
							cSeq := Replicate("9",TamSx3('G5I_SEQ')[1] )
						Endif
						If lRet .and. !Empty(cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/LocalityInternalId')))
							cLocCod	:= GTPxRetId(cMarca, "GI1", "GI1_COD", cLocExt, , 3,@lOk,@cErro,aCpoGI1,1)
							If !lOk
								lRet := .F.
								cXmlRet := GTPXErro(oModel,cErro)
								Exit
							Endif
						Endif
						If !oMdlG5I:SeekLine({{"G5I_SEQ",cSeq}})
							oMdlG5I:AddLine()
						Endif
						aSize(aDadosSeq,0)
						
						aAdd(aDadosSeq,{'G5I_SEQ'	,cSeq	,cLine + '/Sequence'})
						aAdd(aDadosSeq,{'G5I_LOCALI',cLocCod,cLine + '/LocalityInternalId'})
						aAdd(aDadosSeq,{'G5I_VENDA'	,		,cLine + '/TicketSale'})
						If cSeq <>  Replicate("9",TamSx3('G5I_SEQ')[1] )
							aAdd(aDadosSeq,{'G5I_TEMPO'	,GTFormatHour(cTempo,'9999')		,cLine + '/StretchTravelTime'})
							aAdd(aDadosSeq,{'G5I_KM'	,		,cLine + '/StretchTravelDistance'})
						Endif
						For n1 := 1 to Len(aDadosSeq)
							If !GxGetNdXml(oMdlG5I,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3])
								lRet := .F.
								Exit
							Endif
						Next
						If !lRet .or. !oMdlG5I:VldLineData()
							lRet := .F.
							Exit
						Endif
					Next
					GA002Order(oMdlG5I)
				Endif
			
			Endif
			
			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGI2:GetValue('GI2_COD'), 'GI2')
				Endif
				aAdd(aIntId, {"Line",cExtId,cIntId,cMarca,"GI2","GI2_COD"})
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
GTPDestroy(oMdlG5I)
GTPDestroy(oXml)
GTPDestroy(aDados)
GTPDestroy(aIntId)
GTPDestroy(aCampos)
GTPDestroy(aCpoG9U)
GTPDestroy(aCpoGI0)
GTPDestroy(aCpoGQC)
GTPDestroy(aCpoGYR)
GTPDestroy(aCpoGI1)
GTPDestroy(aDadosSeq)
Return cXmlRet
