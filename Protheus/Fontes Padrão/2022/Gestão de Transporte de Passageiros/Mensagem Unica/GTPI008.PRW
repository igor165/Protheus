#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI008
// GTPI008 - Adapter da rotina de Agencias
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
Function GTPI008(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'Collaborator'
Local aArea		:= GetArea()

If nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem única TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI008Resp(cXml,@lRet)
		
		//chegada de mensagem de negócios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI008Receb(cXml,@lRet)
	EndCase
Endif
RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI008Resp
// GI008Resp - Função utilizada para receber os valores da integração (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI008Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"Collaborator","GYG","GYG_CODIGO"})

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
/*/{Protheus.doc} GI008Receb
// GI008Receb - Função utilizada para executar o recebimento da integração e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela função do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI008Receb(cXml,lRet)
Local oModel	:= FwLoadModel("GTPA008")
Local oMdlGYG	:= Nil
Local oStruct	:= oModel:GetModel('GYGMASTER'):GetStruct()
Local oXml		:= tXMLManager():New()
Local cXmlRet	:= ""
Local cBusiMsg	:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont := cBusiMsg+'/BusinessContent'
Local lDelete	:= .F.
Local cMarca	:= "PROTHEUS"
Local cIntID	:= ""
Local cExtID	:= ""
Local cCode		:= ""
Local cAgeExt	:= ""
Local cLocExt	:= ""
Local nOpc		:= 0
Local lOk		:= .T.
Local cErro		:= ""
Local aCampos	:= {"GYG_FILIAL","GYG_CODIGO"}
Local aCpoGI1	:= {"GI1_FILIAL","GI1_COD"}
Local aCpoGI6	:= {"GI6_FILIAL","GI6_CODIGO"}
Local aDados	:= {}
Local aIntId	:= {}
Local aInt		:= {}
Local lMsblql	:= AllTrim(GetSx3Cache("GYG_MSBLQL", "X3_CAMPO")) == "GYG_MSBLQL"
Local n1		:= 0
Local cCpf		:= ""
Local cCodGYG   := ""
Static cAgeCode	:= ""
Static cLocCode	:= ""

oStruct:SetProperty('GYG_FUNCIO', MODEL_FIELD_WHEN, {||.T.})
oStruct:SetProperty('GYG_DTNASC', MODEL_FIELD_OBRIGAT, .F.)
If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))

	cExtID	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/InternalId'))
	cCode	:= GTPxRetId(cMarca, "GYG", "GYG_CODIGO", cExtID, @cIntID, 3,@lOk,@cErro,aCampos,1)
	
	cCpf	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CPF'))
	cCpf	:= StrTran(cCpf,'.','')
	cCpf	:= StrTran(cCpf,'-','')

	If !lDelete
		If Empty(cIntID)

		    If !Empty(cCpf)
				cCodGYG := VldCpfExist(cCpf)
			Endif

			If !Empty(cCodGYG)
				cIntId := GTPxMakeId(cCodGYG, 'GYG')
				aAdd(aIntId, {"Collaborator", cExtID ,cIntId,cMarca,"GYG","GYG_CODIGO"})
				cXmlRet := GxListOfId(aIntId,lDelete)	
			Else
				nOpc	:= MODEL_OPERATION_INSERT
				cCode	:= GetSxeNum("GYG","GYG_CODIGO")
			Endif

		ElseIf lOk .and. GYG->(DbSeek(xFilial('GYG')+cCode))
			nOpc	:= MODEL_OPERATION_UPDATE
		Else
			lRet	:= .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
		
	Else
		If lOk
			nOpc	:= MODEL_OPERATION_DELETE
		Else
			lRet	:= .F.
			cXmlRet := GTPXErro(oModel,cErro)
		endif
	Endif

	If Empty(cCodGYG)
		cAgeExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/AgencyInternalId'))
		cLocExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/StandardLocalityInternalId'))
		cCpf	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/CPF'))
		cCpf	:= StrTran(cCpf,'.','')
		cCpf	:= StrTran(cCpf,'-','')
		aAdd(aInt,{cAgeExt	,"cAgeCode"	,"GI6","GI6_CODIGO"	,3,aCpoGI6,1})
		aAdd(aInt,{cLocExt	,"cLocCode"	,"GI1","GI1_COD"	,3,aCpoGI1,1})
		
		
		For n1 := 1 To Len(aInt)
			If !Empty(aInt[n1,1])
				&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1],, aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
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
				oMdlGYG:= oModel:GetModel("GYGMASTER")
				If !lDelete
					If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGYG:GetValue("GYG_CODIGO"))
						aAdd(aDados,{"GYG_CODIGO",cCode,cBusiCont + '/InternalId'})
					Endif
					aAdd(aDados,{"GYG_NOME"		,			,cBusiCont + '/Name'})
					aAdd(aDados,{"GYG_RG"		,			,cBusiCont + '/RG'})
					aAdd(aDados,{"GYG_CPF"		,cCpf		,cBusiCont + '/CPF'})
					aAdd(aDados,{"GYG_DTNASC"	,			,cBusiCont + '/DayOfBorn'})
					aAdd(aDados,{"GYG_AGENCI"	,cAgeCode	,cBusiCont + '/AgencyInternalId'})
					aAdd(aDados,{"GYG_LOCPAD"	,cLocCode	,cBusiCont + '/StandardLocalityInternalId'})
					If lMsblql
						aAdd(aDados,{"GYG_MSBLQL",,cBusiCont + '/Situation'})
					Endif
					For n1 := 1 to Len(aDados)
						If !GxGetNdXml(oMdlGYG,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
							lRet := .F.
							Exit
						Endif
					Next
					
					If lRet .and. Empty(oMdlGYG:GetValue('GYG_FUNCIO')) .and. !Empty(cCpf) 
						lRet := GetMatricula(oMdlGYG,cCpf)
					Endif
					
				Endif
				
				If lRet .and. oModel:VldData() 
					oModel:CommitData()
					If Empty(cIntId)
						cIntId := GTPxMakeId(oMdlGYG:GetValue('GYG_CODIGO'), 'GYG')
					Endif
					aAdd(aIntId, {"Collaborator", cExtID ,cIntId,cMarca,"GYG","GYG_CODIGO"})
					cXmlRet := GxListOfId(aIntId,lDelete)
					ConfirmSX8()
				Else
					lRet := .F.
					cXmlRet := GTPXErro(oModel)
					RollBackSXE()
				Endif
				oModel:DeActivate()
			Endif
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
GTPDestroy(aInt)
GTPDestroy(aCpoGI1)
GTPDestroy(aCpoGI6)
Return cXmlRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetMatricula(oMdlGYG,cCpf)

@type Static Function
@author jacomo.fernandes
@since 16/01/2020
@version 1.0
@param oMdlGYG, object, (Descrição do parâmetro)
@param cCpf, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function GetMatricula(oMdlGYG,cCpf)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp
    Select 
		SRA.RA_FILIAL,
		SRA.RA_MAT
	From %Table:SRA% SRA
	Where
		SRA.RA_FILIAL LIKE %Exp:AllTrim(xFilial('GYG'))% || '%'
		AND SRA.RA_SITFOLH NOT IN ('D','T')
		AND SRA.RA_CIC = %Exp:cCPF%
		and SRA.%NotDel%
	Order By
		SRA.RA_FILIAL,
		SRA.RA_MAT

EndSql

If (cAliasTmp)->(!Eof())
    lRet := oMdlGYG:LoadValue('GYG_FUNCIO',(cAliasTmp)->RA_MAT)
    lRet := lRet .and. oMdlGYG:LoadValue('GYG_FILSRA',(cAliasTmp)->RA_FILIAL)
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldCpfExist(cCpf)

@type Static Function
@author flavio.martins
@since 03/11/2020
@version 1.0
@param oMdlGYG, object, (Descrição do parâmetro)
@param cCpf, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function VldCpfExist(cCpf)
Local lRet 		:= .T.
Local cAliasGYG := GetNextAlias()
Local cCodGYG	:= ''

BeginSql Alias cAliasGYG

	SELECT GYG.GYG_FILIAL,
		   GYG.GYG_CODIGO,
		   GYG.GYG_FUNCIO,
		   GYG.GYG_CPF
	FROM %Table:GYG% GYG
	WHERE GYG.GYG_FILIAL = %xFilial:GYG%
	AND GYG.GYG_CPF = %Exp:cCpf%
	AND GYG.%NotDel%
	ORDER BY GYG.GYG_FUNCIO DESC

EndSql

If (cAliasGYG)->(!Eof())
	cCodGYG := (cAliasGYG)->GYG_CODIGO
Endif

(cAliasGYG)->(dbCloseArea())

Return cCodGYG


