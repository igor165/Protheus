#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'
/*/{Protheus.doc} GTPI004
GTPI004 - Adapter da rotina de Horarios e Serviços
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
Function GTPI004(cXml, nTypeTrans, cTypeMessage,cVersao )
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'ServiceSchedule'
Local aArea		:= GetArea()

If nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem Ãºnica TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI004Resp(cXml,@lRet)
		
		//chegada de mensagem de negÃ³cios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI004Receb(cXml,@lRet)
	EndCase
EndIF

RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI004Resp
// GI004Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI004Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"ServiceSchedule","GID","GID_COD"})

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
/*/{Protheus.doc} GI004Receb
// GI004Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI004Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA004")
Local oMdlGID		:= Nil
Local oMdlGIE		:= Nil
Local oXml			:= tXMLManager():New()
Local cXmlRet		:= ""
Local cBusiMsg		:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont		:= cBusiMsg+'/BusinessContent'
Local cLstOFItem	:= cBusiCont+'/ListOfStretch/Stretch'
Local cLine			:= ""
Local lDelete		:= .F.
Local cMarca		:= "PROTHEUS"
Local cCode			:= ""
Local cIntID		:= ""
Local cExtID		:= ""
Local nOpc			:= 0
Local lOk			:= .T.
Local cErro			:= ""
Local aInt			:= {}
Local aCpoGI2		:= {"GI2_FILIAL","GI2_COD"}//Linhas
Local aCpoGI1		:= {"GI1_FILIAL","GI1_COD"}//localidades
Local aDados		:= {}
Local aDadosSeq		:= {}
Local aIntId		:= {}
Local aItens		:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("GID_MSBLQL", "X3_CAMPO")) == "GID_MSBLQL"
Local n1			:= 0
Local n2			:= 0
Local nCont			:= 0
Local cLinExt		:= ""
Local cOriLocExt	:= ""
Local cDesLocExt	:= ""
Local cHoraCab		:= ""
Local cHrOrig		:= ""
Local cHrDest		:= ""
Local cElapsed		:= ""
Local cTempo		:= ""
Static cCodeLin		:= ""
Static cOriLocCod	:= ""
Static cDesLocCod	:= ""

Local nDiaDec	:= 0

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	
	cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	cLinExt		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LineInternalId'))
	cHoraCab	:= GTFormatHour(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartureTime')),'9999')
	cCode		:= GTPxRetId(cMarca, "GID", "GID_COD", cExtID, @cIntID, 3,@lOk,@cErro)
	
	If lRet
		GID->(DbSetOrder(4))//GID_FILIAL+GID_COD+GID_HIST
		If !lDelete
			If Empty(cIntID)
				nOpc := MODEL_OPERATION_INSERT
			ElseIf GID->(DbSeek(xFilial('GID')+cCode+"2"))
				nOpc := MODEL_OPERATION_UPDATE
			Endif
		Else
			If lOk .and. GID->(DbSeek(xFilial('GID')+cCode+"2"))
				nOpc := MODEL_OPERATION_DELETE
			Else
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
			Endif
		Endif
	Endif
	
	aAdd(aInt,{cLinExt	,"cCodeLin"		,"GI2","GI2_COD"		,3,aCpoGI2,1})
	
	For n1 := 1 To Len(aInt)
		If !Empty(aInt[n1,1])
			&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
							
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
			oMdlGID := oModel:GetModel('GIDMASTER')
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGID:GetValue("GID_COD"))
					aAdd(aDados,{"GID_COD"	,			,cBusiCont + '/Code'})
				Endif
				aAdd(aDados,{"GID_LINHA"	,cCodeLin	,cBusiCont + '/LineInternalId'})
				aAdd(aDados,{"GID_SENTID"	,			,cBusiCont + '/Direction'})
				aAdd(aDados,{"GID_HORCAB"	,cHoraCab	,cBusiCont + '/DepartureTime'})
				aAdd(aDados,{"GID_INIVIG"	,			,cBusiCont + '/InitialDate'})
				aAdd(aDados,{"GID_FINVIG"	,			,cBusiCont + '/FinalDate'})
				
				aAdd(aDados,{"GID_SEG"		,			,cBusiCont + '/DayOfWeek/Monday'})
				aAdd(aDados,{"GID_TER"		,			,cBusiCont + '/DayOfWeek/Tuesday'})
				aAdd(aDados,{"GID_QUA"		,			,cBusiCont + '/DayOfWeek/Wednesday'})
				aAdd(aDados,{"GID_QUI"		,			,cBusiCont + '/DayOfWeek/Thursday'})
				aAdd(aDados,{"GID_SEX"		,			,cBusiCont + '/DayOfWeek/Friday'})
				aAdd(aDados,{"GID_SAB"		,			,cBusiCont + '/DayOfWeek/Saturday'})
				aAdd(aDados,{"GID_DOM"		,			,cBusiCont + '/DayOfWeek/Sunday'})
				
				aAdd(aDados,{"GID_LOTACA"	,			,cBusiCont + '/MaximumCapacity'})
				aAdd(aDados,{"GID_NUMSRV"	,			,cBusiCont + '/ServiceNumber'})
				
				If lMsblql
					aAdd(aDados,{"GID_MSBLQL",,cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGID,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
			Endif
			
			If lRet .and. !lDelete	.AND. (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfStretch') ) > 0
				oMdlGIE := oModel:GetModel("GIEDETAIL")
				oMdlGIE:SetNoInsertLine(.F.)// Permite inclusao no grid
				oMdlGIE:SetNoDeleteLine(.F.)// Permite deletar a linha
				If nOpc <> MODEL_OPERATION_INSERT
					oMdlGIE:DelAllLine()
				Endif
				For n2 := 1 to nCont
					cLine		:= cLstOFItem+"["+cValToChar(n2)+"]"
					
					cOriLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/DepartureLocalityInternalId'))
					cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/ArrivalLocalityInternalId'))
					cHrOrig		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/DepartureTime'))
					cHrDest		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/ArrivalTime'))
					cTempo		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/ExceptionTime'))
					cElapsed	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/ElapsedTime'))
					
					aSize(aInt,0)
					aAdd(aInt,{cOriLocExt	,"cOriLocCod"		,"GI1","GI1_COD"		,3,aCpoGI1,1})
					aAdd(aInt,{cDesLocExt	,"cDesLocCod"		,"GI1","GI1_COD"		,3,aCpoGI1,1})
					
					For n1 := 1 To Len(aInt)
						If !Empty(aInt[n1,1])
							&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
											
							If !lOk
								lRet := .F.
								cXmlRet := GTPXErro(oModel,cErro)
								Exit
							Endif
						Endif
					Next
					If lRet
						If (!oMdlGIE:SeekLine({{"GIE_IDLOCP",cOriLocCod},{'GIE_IDLOCD',cDesLocCod} });
							.and. !Empty(oMdlGIE:GetValue('GIE_SEQ'))) .or. oMdlGIE:Length(.T.) == 0
							
							oMdlGIE:AddLine()
						Endif
						aSize(aDadosSeq,0)
						
						aAdd(aDadosSeq,{'GIE_SEQ'	,StrZero(n2,TamSx3('GIE_SEQ')[1]),cLine + '/Sequence'})
						aAdd(aDadosSeq,{'GIE_IDLOCP',cOriLocCod						,cLine + '/DepartureLocalityInternalId'})
						aAdd(aDadosSeq,{'GIE_HORLOC',GTFormatHour(cHrOrig,'9999')	,cLine + '/DepartureTime'})
						aAdd(aDadosSeq,{'GIE_IDLOCD',cDesLocCod						,cLine + '/ArrivalLocalityInternalId'})
						aAdd(aDadosSeq,{'GIE_HORDES',GTFormatHour(cHrDest,'9999')	,cLine + '/ArrivalTime'})
						aAdd(aDadosSeq,{'GIE_TEMPO'	,GTFormatHour(cTempo,'9999')	,cLine + '/ExceptionTime'})
						aAdd(aDadosSeq,{'GIE_TPTR'	,GTFormatHour(cElapsed,'9999')	,cLine + '/ElapsedTime'})
												
						For n1 := 1 to Len(aDadosSeq)
							If !GxGetNdXml(oMdlGIE,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3])
								lRet := .F.
								Exit
							Endif
						Next
						oMdlGIE:SetValue('GIE_TEMPO',"0000")
						If "00:" $ cHrDest .AND. !(cHrDest > cHrOrig)
							oMdlGIE:SetValue('GIE_TPTR',GTFormatHour(VAL(STRTRAN(cHrDest,"00:","24.")) - VAL(STRTRAN(cHrOrig,":",".")),'9999'))
							nDiaDec++
						ElseIf "00:" $ cHrOrig
							oMdlGIE:SetValue('GIE_TPTR',GTFormatHour(VAL(STRTRAN(cHrDest,":",".")) - VAL(STRTRAN(cHrOrig,":",".")),'9999'))
						Else
							oMdlGIE:SetValue('GIE_TPTR',GTFormatHour(VAL(STRTRAN(cHrDest,":",".")) - VAL(STRTRAN(cHrOrig,":",".")),'9999'))
						EndIf

						oMdlGIE:LoadValue('GIE_DIA',nDiaDec)

						If !lRet .or. !oMdlGIE:VldLineData()
							lRet := .F.
							Exit
						Endif

						aAdd(aItens,oMdlGIE:GetValue("GIE_SEQ"))
				
					Else
						Exit
					Endif
			
				Next
				If lRet
					oMdlGID:RunTrigger('GID_HORCAB')
				Endif
			Endif

			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGID:GetValue('GID_COD'), 'GID')
				Endif
				aAdd(aIntId, {"ServiceSchedule",cExtID,cIntId,cMarca,"GID","GID_COD"})
				
				cXmlRet := GxListOfId(aIntId,lDelete)
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
GTPDestroy(oMdlGID)
GTPDestroy(oMdlGIE)
GTPDestroy(oXml)
GTPDestroy(aDados)
GTPDestroy(aIntId)
GTPDestroy(aCpoGI1)
GTPDestroy(aDadosSeq)
Return cXmlRet
