#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

Static aXMLG300 := Nil
/*/{Protheus.doc} GTPI300
GTPI300 - Adapter da rotina de Horarios e Serviços
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
Function GTPI300(cXml, nTypeTrans, cTypeMessage,cVersao )

	Local lRet      := .T. 
	Local cXmlRet	:= ""
	Local cMsgUnica := 'TravelService'
	Local aArea		:= GetArea()

	if nTypeTrans == TRANS_RECEIVE
		Do Case
			//whois
			Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				cXmlRet := '1.000'
			
			//resposta da mensagem única TOTVS
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
				cXmlRet := GI300Resp(cXml,@lRet)
			
			//chegada de mensagem de negócios
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				cXmlRet := GI300Receb(cXml,@lRet)
		EndCase
	endif

	RestArea(aArea)
	GTPDestroy(aArea)
	GTPDestroy(aXMLG300)

Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI300Resp
// GI300Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI300Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"TravelService","GYN","GYN_CODIGO"})

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
/*/{Protheus.doc} GI300Receb
// GI300Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI300Receb(cXml,lRet)
Local oModel		:= FwLoadModel("GTPA300")
Local oMdlGYN		:= Nil
Local oMdlG55		:= Nil
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
Local aCpoGID		:= {"GID_FILIAL","GID_COD"}//Linhas
Local aCpoGI2		:= {"GI2_FILIAL","GI2_COD"}//Linhas
Local aCpoGI1		:= {"GI1_FILIAL","GI1_COD"}//localidades
Local aDados		:= {}
Local aDadosSeq		:= {}
Local aIntId		:= {}
Local aItens		:= {}
Local lMsblql		:= AllTrim(GetSx3Cache("GYN_MSBLQL", "X3_CAMPO")) == "GYN_MSBLQL"
Local n1			:= 0
Local n2			:= 0
Local nCont			:= 0
Local cLinExt		:= ""
Local cCodSrvExt    := ""
Local cOriLocExt	:= ""
Local cDesLocExt	:= ""
Local cHrOrig		:= ""
Local cHrDest		:= ""
Local nSeq			:= 0
Static cCodSrv		:= ""
Static cCodeLin		:= ""
Static cOriLocCod	:= ""
Static cDesLocCod	:= ""

If Type("Inclui") == "U"
	Private Inclui := .F.
Endif

oModel:GetModel('GYNMASTER'):GetStruct():SetProperty('GYN_LOCORI'	, MODEL_FIELD_WHEN,{||	.T. })
oModel:GetModel('GYNMASTER'):GetStruct():SetProperty('GYN_LOCDES'	, MODEL_FIELD_WHEN,{||  .T. })
oModel:GetModel('GYNMASTER'):GetStruct():SetProperty('GYN_DTINI'	, MODEL_FIELD_WHEN,{||  .T. })
oModel:GetModel('GYNMASTER'):GetStruct():SetProperty('GYN_HRINI'	, MODEL_FIELD_WHEN,{||  .T. })
oModel:GetModel('GYNMASTER'):GetStruct():SetProperty('GYN_DTFIM'	, MODEL_FIELD_WHEN,{||  .T. })
oModel:GetModel('GYNMASTER'):GetStruct():SetProperty('GYN_HRFIM'	, MODEL_FIELD_WHEN,{||  .T. })
oModel:GetModel('G55DETAIL'):SetUniqueLine({"G55_SEQ",'G55_LOCORI','G55_LOCDES'})
If oXml:Parse(cXml)

	aXMLG300 := {oXml,cBusiMsg,cBusiCont,cLstOFItem}

	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	
	cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	cCodSrvExt  := AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ServiceScheduleInternalId'))
    cLinExt		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LineInternalId'))
	cOriLocExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartureLocalityInternalId'))
    cHrOrig		:= GTFormatHour(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/DepartureTime')),'9999')
    cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ArrivalLocalityInternalId'))
    cHrDest		:= GTFormatHour(AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/ArrivalTime')),'9999')

    cCode		:= GTPxRetId(cMarca, "GYN", "GYN_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro)
    
	If lRet
		GYN->(DbSetOrder(1))//GYN_FILIAL+GYN_COD+GYN_HIST
		If !lDelete
			If Empty(cIntID)
				nOpc := MODEL_OPERATION_INSERT
                Inclui := .T.
			ElseIf GYN->(DbSeek(xFilial('GYN')+cCode))
				nOpc := MODEL_OPERATION_UPDATE
			Endif
		ElseIf GYN->(DbSeek(xFilial('GYN')+cCode))
			nOpc := MODEL_OPERATION_DELETE
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,STR0007)
		Endif
	Endif
                
    aSize(aInt,0)
    aAdd(aInt,{cCodSrvExt   ,"cCodSrv"		    ,"GID","GID_COD"		,3,aCpoGID,1})
	aAdd(aInt,{cLinExt	    ,"cCodeLin"		    ,"GI2","GI2_COD"		,3,aCpoGI2,1})
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
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			oMdlGYN := oModel:GetModel('GYNMASTER')
			If !lDelete
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGYN:GetValue("GYN_CODIGO"))
					aAdd(aDados,{"GYN_CODIGO"	,			,cBusiCont + '/Code'})
				Endif

                aAdd(aDados,{"GYN_EXTRA"	,			,cBusiCont + '/Extra'})
				aAdd(aDados,{"GYN_LINCOD"	,cCodeLin	,cBusiCont + '/LineInternalId'})
				aAdd(aDados,{"GYN_LINSEN"	,			,cBusiCont + '/Direction'})
                aAdd(aDados,{"GYN_CODGID"	,cCodSrv   	,cBusiCont + '/ServiceScheduleInternalId'})
				aAdd(aDados,{"GYN_LOCORI"	,cOriLocCod	,cBusiCont + '/DepartureLocalityInternalId'})
                aAdd(aDados,{"GYN_DTINI"	,       	,cBusiCont + '/DepartureDate'})
				aAdd(aDados,{"GYN_HRINI"	,cHrOrig   	,cBusiCont + '/DepartureTime'})
				aAdd(aDados,{"GYN_LOCDES"	,cDesLocCod	,cBusiCont + '/ArrivalLocalityInternalId'})
                aAdd(aDados,{"GYN_DTFIM"	,			,cBusiCont + '/ArrivalDate'})
                aAdd(aDados,{"GYN_HRFIM"	,cHrDest	,cBusiCont + '/ArrivalTime'})
				aAdd(aDados,{"GYN_LOTACA"	,			,cBusiCont + '/MaximumCapacity'})
				aAdd(aDados,{"GYN_NUMSRV"	,			,cBusiCont + '/ServiceNumber'})
				
				If lMsblql
					aAdd(aDados,{"GYN_MSBLQL",'2',cBusiCont + '/Situation'})
				Endif
				For n1 := 1 to Len(aDados)
					If !GxGetNdXml(oMdlGYN,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
				oMdlGYN:LoadValue('GYN_MONIT','1')
			Endif
			
			If lRet .and. !lDelete	.AND. (nCont := oXml:xPathChildCount(cBusiCont + '/ListOfStretch') ) > 0
				oMdlG55 := oModel:GetModel("G55DETAIL")
				For n2 := 1 to nCont
					cLine		:= cLstOFItem+"["+cValToChar(n2)+"]"
					
					cOriLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/DepartureLocalityInternalId'))
					cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/ArrivalLocalityInternalId'))
					cHrOrig		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/DepartureTime'))
					cHrDest		:= AllTrim(oXml:XPathGetNodeValue(cLine + '/ArrivalTime'))
					nSeq		:= Val(AllTrim(oXml:XPathGetNodeValue(cLine + '/Sequence')))
					If Empty(nSeq)
						nSeq := n2
					Endif
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
                        oMdlG55:SetNoUpdateLine(.F.)// Permite alteração no grid
							
						If !oMdlG55:SeekLine({{"G55_SEQ",StrZero(nSeq,TamSx3('G55_SEQ')[1])}})
							oMdlG55:SetNoInsertLine(.F.)// Permite inclusao no grid
							oMdlG55:AddLine()
						Endif
						aSize(aDadosSeq,0)
						
						aAdd(aDadosSeq,{'G55_SEQ'	 ,StrZero(nSeq,TamSx3('G55_SEQ')[1]),cLine + '/Sequence'})
						aAdd(aDadosSeq,{'G55_LOCORI' ,cOriLocCod						,cLine + '/DepartureLocalityInternalId'})
						aAdd(aDadosSeq,{'G55_DTPART' ,									,cLine + '/DepartureDate'})
						aAdd(aDadosSeq,{'G55_HRINI'  ,GTFormatHour(cHrOrig,'9999')		,cLine + '/DepartureTime'})
						aAdd(aDadosSeq,{'G55_LOCDES' ,cDesLocCod						,cLine + '/ArrivalLocalityInternalId'})
						aAdd(aDadosSeq,{'G55_DTCHEG' ,									,cLine + '/ArrivalDate'})
						aAdd(aDadosSeq,{'G55_HRFIM'  ,GTFormatHour(cHrDest,'9999')		,cLine + '/ArrivalTime'})
						
						For n1 := 1 to Len(aDadosSeq)
							If !GxGetNdXml(oMdlG55,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3])
								lRet := .F.
								Exit
							Endif
						Next
						
						If !lRet .or. !oMdlG55:VldLineData()
							lRet := .F.
							Exit
						Endif

						aAdd(aItens,oMdlG55:GetValue("G55_SEQ"))
				
					Else
						Exit
					Endif
			
				Next
				If lRet .and. !lDelete
					oModel:GetModel( 'G55DETAIL' ):SetNoDeleteLine(.F.)// Não permite deletar a linha
					For n2 := 1 to oMdlG55:Length()
						oMdlG55:GoLine(n2)
						If aScan(aItens,oMdlG55:GetValue("G55_SEQ")) == 0
							If !(lRet := oMdlG55:DeleteLine())
								Exit
							Endif
						Endif
					Next
				Endif
			Endif

			//Acrescentado por Fernando Radu em 22/09/2021
			If ( lRet )
				ViagExtraUpd(oModel)
			EndIf

			If lRet .and. oModel:VldData() 
				oModel:CommitData()
				If Empty(cIntId)
					cIntId := GTPxMakeId(oMdlGYN:GetValue('GYN_CODIGO'), 'GYN')
				Endif
				aAdd(aIntId, {"TravelService",cExtID,cIntId,cMarca,"GYN","GYN_CODIGO"})
				
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
GTPDestroy(oMdlGYN)
GTPDestroy(oMdlG55)
GTPDestroy(oXml)
GTPDestroy(aDados)
GTPDestroy(aIntId)
GTPDestroy(aCpoGI1)
GTPDestroy(aDadosSeq)
Return cXmlRet

Function GI300GetXML()
//aXMLG300 := {oXml,cBusiMsg,cBusiCont,cLstOFItem}
Return(aClone(aXMLG300))


Static Function ViagExtraUpd(oModel)

	Local oMaster	:= oModel:GetModel("GYNMASTER")
	
	Local dArrival		:= SToD("")
	Local cTimeArrival	:= ""

	//Viagem Extraordinaria
	If ( (oMaster:GetValue("GYN_EXTRA")) )
		
		dArrival 		:= GTPCastType(DtFromXML("ArrivalDate"),"D")		//oDetail:GetValue("G55_DTCHEG",oDetail:Length())
		cTimeArrival 	:= GTFormatHour(DtFromXML("ArrivalTime"),'9999')	//oDetail:GetValue("G55_HRFIM",oDetail:Length())

		If ( !Empty(dArrival) .And. dArrival != oMaster:GetValue("GYN_DTFIM") )
			oMaster:LoadValue("GYN_DTFIM",dArrival)
		EndIf

		If ( !Empty(cTimeArrival) .And. cTimeArrival != oMaster:GetValue("GYN_HRFIM") )
			oMaster:LoadValue("GYN_HRFIM",cTimeArrival)
		EndIf

	EndIf

Return()

Static Function DtFromXML(cNodeXML)

	Local xRet
	
	Local aXml 		:= GI300GetXML()
	
	Local oXml
	
	Local cBMsg		:= ""
	Local cBCont	:= ""
	Local cList		:= ""

	Local nQtdItens	:= 0

	If ( Len(aXml) > 0  )
		
		If ( Valtype(aXml[1]) == "O" )

			oXml	:= aXml[1]

			cBMsg	:= aXml[2]
			cBCont	:= aXml[3]
			cList 	:= aXml[4]
			
			nQtdItens := oXml:xPathChildCount(cBCont + '/ListOfStretch')
			
			xRet := oXml:XPathGetNodeValue(cBCont  + '/ListOfStretch/Stretch[' + cValToChar(nQtdItens) + ']/' + cNodeXML)
			
		EndIf
	
	EndIf

Return(xRet)
/*
	oXml:xPathChildCount(cBusiCont + '/ListOfStretch')
	Local cBusiMsg		:= '/TOTVSMessage/BusinessMessage'
	Local cBusiCont		:= cBusiMsg+'/BusinessContent'
	Local cLstOFItem	:= cBusiCont+'/ListOfStretch/Stretch'
*/
