#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'
/*/{Protheus.doc} GTPI427
GTPI427 - Adapter da rotina de Receitas e Despesas Adicionais
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
Function GTPI427(cXml, nTypeTrans, cTypeMessage,cVersao )
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'AdditionalSales'
Local aArea		:= GetArea()

If nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem Ãºnica TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI427Resp(cXml,@lRet)
		
		//chegada de mensagem de negÃ³cios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI427Receb(cXml,@lRet)
	EndCase
EndIF

RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GII427Resp

@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, loGZTal, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI427Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"AdditionalSales","GZT","GZT_CODIGO"})

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
/*/{Protheus.doc} GI427Receb

@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, loGZTal, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI427Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA427")
Local oMdlGZT		:= Nil
Local oMdlGZP		:= Nil
Local oStruGZT		:= oModel:GetModel('GZTMASTER'):GetStruct()
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
Local aInt			:= {}
Local aCpoGZT		:= {"GZT_FILIAL","GZT_CODIGO"}// Receitas/Despesas Adicionais
Local aCpoGI6		:= {"GI6_FILIAL","GI6_CODIGO"}//AGENCIA
Local aCpoGYG		:= {"GYG_FILIAL","GYG_CODIGO"}//COLAB
Local aCpoGIC		:= {"GIC_FILIAL","GIC_CODIGO"}//Bilhetes
Local aCpoGZC		:= {"GZC_FILIAL","GZC_CODIGO"}// Tipo de Receita e Despesa
Local aDados		:= {}
//Local lMsblql		:= AllTrim(GetSx3Cache("GZT_MSBLQL", "X3_CAMPO")) == "GZT_MSBLQL"
Local n1			:= 0
Local nCont			:= 0
Local n2			:= 0
Local nItem			:= 0
Local cLine			:= ''
Local cItem			:= ''
Local cLstOFItem	:= cBusiCont+'/ListOfPaymentForm/PaymentForm'
Local aDadosSeq		:= {}
Static cBilRef		:= ""
Static cCodeLin		:= ""
Static cCodeHr		:= ""
Static cCodeViag	:= ""
Static cOriLocCod	:= ""
Static cDesLocCod	:= ""
Static cAgencia     := ""
Static cColab       := ""
Static cEcf			:= ""
Static cTpVenda		:= ""
Static cBilhete		:= ""

If Type("Inclui") == "U"
	Private Inclui := .F.
Endif

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	
	cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
    cCode		:= GTPxRetId(cMarca, "GZT", "GZT_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCpoGZT,1)
	
	If lRet
		GZT->(DbSetOrder(1))//GZT_FILIAL+GZT_CODIGO
		If !lDelete
			If Empty(cIntID)
				nOpc := MODEL_OPERATION_INSERT
				Inclui := .T.
			ElseIf lOk .and. GZT->(DbSeek(xFilial('GZT')+cCode))
				nOpc := MODEL_OPERATION_UPDATE
			Else 
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
			Endif
		ElseIf lOk .and. GZT->(DbSeek(xFilial('GZT')+cCode))
			nOpc := MODEL_OPERATION_DELETE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,STR0007)
		Endif
	Endif

	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/AgencyInternalId'))			,"cAgencia"		,"GI6","GI6_CODIGO"		,3,aCpoGI6	,1})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CollaboratorInternalId'))   	,"cColab"		,"GYG","GYG_CODIGO"		,3,aCpoGYG	,1})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/TicketInternalId')) 			,"cBilhete"		,"GIC","GIC_CODIGO"		,3,aCpoGIC	,1})
	aAdd(aInt,{ AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/SalesTypeInternalId'))  		,"cTpVenda"		,"GZC","GZC_CODIGO"		,3,aCpoGZC	,1})
	
	For n1 := 1 To Len(aInt)
		If !Empty(aInt[n1,1])
			&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
						
			If !lOk .And. aInt[n1,2] $ 'cBilhete'
			
				&(aInt[n1,2]):= ''
			
				lOk := .T.
				
			Endif 
							
			If !lOk
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
				Exit
			Endif
		Endif
	Next

	If lRet
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlGZT := oModel:GetModel('GZTMASTER')

			If !lDelete
	
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGZT:GetValue("GZT_CODIGO"))
					aAdd(aDados,{"GZT_CODIGO"	,		,cBusiCont + '/Code'})
				Endif
              
              aAdd(aDados,{"GZT_NDOCTO"	,			,cBusiCont + '/DocumentNumber'})
              aAdd(aDados,{"GZT_DTVEND"	,			,cBusiCont + '/DateOfSale'})
              aAdd(aDados,{"GZT_AGENCI"	,cAgencia ,cBusiCont + '/AgencyInternalId'})
              aAdd(aDados,{"GZT_VALOR"		,			,cBusiCont + '/TotalValue'})
              aAdd(aDados,{"GZT_COLAB"		,cColab	,cBusiCont + '/CollaboratorInternalId'})
              aAdd(aDados,{"GZT_CODGZC"	,cTpVenda	,cBusiCont + '/SalesTypeInternalId'})
              aAdd(aDados,{"GZT_CODGIC"	,cBilhete	,cBusiCont + '/TicketInternalId'})
				aAdd(aDados,{"GZT_ECFSER"	,			,cBusiCont + '/ECFSerie'})
				aAdd(aDados,{"GZT_ECFSEQ"	,			,cBusiCont + '/ECFSequence'})
              
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGZT,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				
				/*If lRet .And. (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfPaymentForm') ) > 0 .AND. AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Status'))$('V|T')
					
					oMdlGZP := oModel:GetModel('GZPPAGTO')
					For n2 := 1 to nCont
						cLine		:= cLstOFItem+"["+cValToChar(n2)+"]"
						If AllTrim(oXml:XPathGetNodeValue(cLine + '/TypeOfPaymentForm'))$('CR|DE|')
							nItem ++					
							cSeq		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/Sequence'))
							If !Empty(cSeq)
								cItem		:= StrZero(val(cSeq),TamSx3('GZP_ITEM')[1])
							Else
								cItem		:= StrZero(nItem,TamSx3('GZP_ITEM')[1])
							Endif
							
							If !Empty(oMdlGZP:GetValue("GZP_ITEM")) .and. !oMdlGZP:SeekLine({{"GZP_ITEM",cItem}}) 
								oMdlGZP:AddLine()
							Endif
							aSize(aDadosSeq,0)
							
							aAdd(aDadosSeq,{'GZP_DCART'	,		,cLine + '/CardName'			,})
							aAdd(aDadosSeq,{'GZP_ITEM'	,cItem	,cLine + '/Sequence'			,.T.})
							aAdd(aDadosSeq,{'GZP_TPAGTO',       ,cLine + '/TypeOfPaymentForm'	,})
							aAdd(aDadosSeq,{'GZP_VALOR'	,		,cLine + '/Value'				,})
							aAdd(aDadosSeq,{'GZP_QNTPAR',		,cLine + '/Installments'		,})
							aAdd(aDadosSeq,{'GZP_NSU'	,		,cLine + '/NSU'					,})
							aAdd(aDadosSeq,{'GZP_AUT'	,		,cLine + '/Autorization'		,})
							If AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/Status'))$('T')
								aAdd(aDadosSeq,{"GZP_BILREF"	,cBilRef	,cBusiCont + '/ReferenceTicketInternalId',   })
							Endif
							
							For n1 := 1 to Len(aDadosSeq)
								If !GxGetNdXml(oMdlGZP,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3],aDadosSeq[n1][4])
									lRet := .F.
									Exit
								Endif
							Next
							If !lRet .or. !oMdlGZP:VldLineData()
								lRet := .F.
								Exit
							Endif
						Endif
					Next		
				
				Endif */
			Endif
			

			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGZT:GetValue('GZT_CODIGO'), 'GZT')
				Endif
				cXmlRet := GxListOfId({{"AdditionalSales",cExtID,cIntId,cMarca,"GZT","GZT_CODIGO"}},lDelete)
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
GTPDestroy(oMdlGZT)
GTPDestroy(oXml)
GTPDestroy(aInt)		
GTPDestroy(aCpoGI6)		
GTPDestroy(aCpoGYG)	
GTPDestroy(aCpoGZC)	
GTPDestroy(aCpoGIC)
GTPDestroy(aDados)		

Return cXmlRet
