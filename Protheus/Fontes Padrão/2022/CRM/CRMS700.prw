#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS700()
Return

/*/{Protheus.doc} Prospects

API de integração de Prospect

@author		Squad Faturamento/SRM
@since		02/08/2018
/*/
WSRESTFUL Prospects DESCRIPTION "Cadastro de Prospects" //"Cadastro de Prospects"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os Prospects" ;
    WSSYNTAX "/api/crm/v1/Prospects/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Prospects"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo Prospesct" ;
    WSSYNTAX "/api/crm/v1/Prospects/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Prospects"

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um Prospect específico" ;
    WSSYNTAX "/api/crm/v1/Prospects/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Prospects/{Code}"	

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Prospect específico" ;
    WSSYNTAX "/api/crm/v1/Prospects/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Prospects/{Code}"	

	WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um Prospect específico" ;
    WSSYNTAX "/api/crm/v1/Prospects/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Prospects/{Code}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET / Prospects/crm/Prospects
Retorna todos os Prospects

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Prospects

	Local cError			:= ""
	Local aFatherAlias		:= {"SUS","items"							, "items"}
	Local cIndexKey			:= "US_FILIAL, US_COD, US_LOJA"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("CRMS700","1.000") 	

	oApiManager:SetApiAdapter("CRMS700") 
   	oApiManager:SetApiAlias(aFatherAlias)
	DefRelation(@oApiManager)
	oApiManager:Activate()

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / Prospects/crm/Prospects
Inclui um novo vendedor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Prospects
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("CRMS700","1.000")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiAlias({"SUS","items", "items"})
	oApiManager:SetApiMap(APIMap())

	lRet := ManutProspect(@oApiManager, Self:aQueryString, 3,,, cBody)

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet
		If lRet
			aAdd(aQueryString,{"Code",SUS->US_COD})
			lRet := GetMain(@oApiManager, aQueryString, .F.)
		EndIf		
	Else
		lRet := .F.        
		oApiManager:SetJsonError("400","Erro ao Incluir Prospect!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )
	FreeObj( aQueryString )	
	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} GET / Prospects/crm/Prospects/{Code}
Retorna um vendedor específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Prospects

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("CRMS700","1.000")
	Local nLenFields	:= TamSX3("US_COD")[1] + TamSX3("US_LOJA")[1]
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	DefRelation(@oApiManager)
	
	If Len(AllTrim(Self:Code)) >= nLenFields
		Aadd(aFilter, {"SUS", "items",{"US_COD  = '" + SubStr(self:Code, 1, TamSX3("US_COD")[1]) 							  + "'"}})
		Aadd(aFilter, {"SUS", "items",{"US_LOJA = '" + SubStr(self:Code, TamSX3("US_COD")[1] + 1, Len(self:Code)) + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Prospect!", "O Prospect ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT / Prospects/crm/Prospects/{Code}
Altera um proscpect específico

@param	Code				, caracter, Código + loja  do prospect
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Prospects

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS700","1.000")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("US_COD")[1] + TamSX3("US_LOJA")[1]
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SUS","items", "items"})
	oApiManager:SetApiMap(APIMap())

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet
		If Len(AllTrim(Self:Code)) >= nLenFields
			If SUS->(Dbseek(xFilial("SUS") + Self:Code))
				lRet := ManutProspect(@oApiManager, Self:aQueryString, 4,, self:Code, cBody)

				If lRet
					Aadd(aFilter, {"SUS", "items",{"US_COD  = '" + SubStr(self:Code, 1, TamSX3("US_COD")[1]) 							  + "'"}})
					Aadd(aFilter, {"SUS", "items",{"US_LOJA = '" + SubStr(self:Code, TamSX3("US_COD")[1] + 1, Len(self:Code)) + "'"}})
					oApiManager:SetApiFilter(aFilter) 		
					GetMain(@oApiManager, Self:aQueryString)
				Endif	

			Else
				lRet := .F.
				oApiManager:SetJsonError("404","Erro ao alterar o Prospect!", "Prospect não encontrado.",/*cHelpUrl*/,/*aDetails*/)
			EndIf
		Else
			lRet := .F.
			oApiManager:SetJsonError("400","Erro ao alterar o Prospect!", "O Prospect ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.        
		oApiManager:SetJsonError("400","Erro ao alterar o Prospect!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} Delete / Prospects/crm/Prospects/{Code}
Deleta um proscpect específico

@param	Code				, caracter, Código + loja  do prospect
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Prospects

	Local cResp			:= "Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("CRMS700","1.000")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("US_COD")[1] + TamSX3("US_LOJA")[1]
	
	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SUS","items", "items"})
	oApiManager:SetApiMap(APIMap())
	oApiManager:Activate()

	If Len(AllTrim(Self:Code)) >= nLenFields
		If SUS->(Dbseek(xFilial("SUS") + Self:Code))
			lRet := ManutProspect(@oApiManager, Self:aQueryString, 5,, self:Code, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar o prospect!", "Prospect não encontrado.",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o prospect!", "O Prospect ID deve possuir pelo menos "+ cValToChar(nLenFields) +" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} ManutProspect
Realiza a manutenção (inclusão/alteração/exclusão) de Prospects

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código + Loja do prospect
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function ManutProspect(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cProspect			:= ""
	Local cConteudo			:= ""
	Local cLoja				:= ""
	Local cError			:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nX				:= 0
	Local nPosCod			:= 0
	Local nPosLoja			:= 0
	Local nPosPessoa		:= 0
	Local nPosTipo			:= 0
	Local nPosQtdFun		:= 0
	Local nPosOrigem		:= 0
    Local oJsonPositions	:= JsonObject():New()

	Default cChave 			:= ""
	Default aJson				:= {}


	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	DefRelation(@oApiManager)

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf

		If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2][1])
				oApiManager:ToExecAuto(1, aJson[1][2][1][nX][2], aCab)
			Next
		EndIf

		iF Len(aCab) > 0
			ASORT(aCab, , , { | x,y | x[1] > y[1] } )
		Endif

		If Len(aJson[1][3]) > 0
			For nX := 1 To Len(aJson[1][3][1])
				MontaCab(aJson[1][3][1][nX], aCab)
			Next
		EndIf
	EndIf

	If !Empty(cChave)
		cProspect := SubStr(cChave, 1                       , TamSX3("US_COD")[1] )
		cLoja	  := SubStr(cChave, TamSX3("US_COD")[1] + 1 , Len(cChave)         )
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_COD"}))
	nPosLoja:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_LOJA"}))

	If nOpc == 3
		If nPosCod == 0 .And. nPosLoja == 0
			aAdd( aCab, {'US_LOJA','01', Nil})
		ElseIf nPosCod != 0 .And. nPosLoja == 0
			aAdd( aCab, {'US_LOJA','01', Nil})
		EndIf
	Else 
		If nPosCod == 0 .And. nPosLoja == 0
			aAdd( aCab, {'US_COD' ,cProspect, Nil})
			aAdd( aCab, {'US_LOJA',cLoja, Nil})
		ElseIf nPosCod == 0 .And. nPosLoja != 0
			aAdd( aCab, {'US_COD' ,cProspect, Nil})
			aCab[nPosLoja][2] := cLoja
		ElseIf nPosCod != 0 .And. nPosLoja == 0
			aCab[nPosCod][2]  := cProspect
			aAdd( aCab, {'US_LOJA','01', Nil})
		Else
			aCab[nPosCod][2]  := cProspect
			aCab[nPosLoja][2] := cLoja		
		EndIf
	EndIf

	nPosPessoa 	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_PESSOA"}))
	nPosTipo 	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_TIPO"}))
	nPosQtdFun 	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_QTFUNC"}))
	nPosOrigem	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_ORIGEM"}))

	If nPosPessoa > 0
		aCab[nPosPessoa][2] := CRMS700A(aCab[nPosPessoa][2], 2)
	EndIf

	If nPosTipo > 0
		aCab[nPosTipo][2] := CRMS700B(aCab[nPosTipo][2], 2)
	EndIf

	If nPosQtdFun > 0
		aCab[nPosQtdFun][2] := CRMS700C(aCab[nPosQtdFun][2], 2)
	EndIf	

	If nPosOrigem > 0
		aCab[nPosOrigem][2] := CRMS700D(aCab[nPosOrigem][2], 2)
	EndIf

	If lRet

		MsExecAuto({|x,y|TMKA260(x,y)},aCab,nOpc)

		If lMsErroAuto
			aMsgErro := GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
			Next nX	
			lRet := .F.
			oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do prospect!.", cResp,/*cHelpUrl*/,/*aDetails*/)
		Else
			nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "US_COD"}))
			SUS->(DbSeek(xFilial("SUS") + SUS->US_COD ))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Prospects

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/09/2018
@version	12.1.17
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default oApiManager		:= Nil	
	Default aQueryString	:={,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(),;
	 lHasNext)

	TrataJson(@oApiManager)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o Get dos prospects

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 

@return Nil	

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function DefRelation(oApiManager)
	Local aRelation			:= {{"US_FILIAL","US_FILIAL"},{"US_COD","US_COD"},{"US_LOJA","US_LOJA"}}
	Local aFatherAlias		:=	{"SUS","items"							, "items"}
	Local aStrEndM   		:= 	{"SUS","address","addressM"}
	Local aStrCidM   		:= 	{"SUS","city","cityM"}
	Local aStrEstM   		:= 	{"SUS","state","stateM"}
	Local aStrConM   		:= 	{"SUS","country","countryM"}
	Local aStrComInf		:=	{"SUS","CompanyInfo","CompanyInfo"}
	Local aStrIntInf		:=	{"SUS","InternalInformation","InternalInformation"}
	Local aStrMktSeg		:=	{"SUS","marketsegment","marketsegment"}
	Local aStrGovInfo		:=	{"SUS","GovernmentalInformation","GovernmentalInformation"}
	Local aStrInfoIE		:=	{"SUS","","GovInfoIE"}
	Local aStrInfoC			:=	{"SUS","","GovInfoC"}
	Local aStrInfoSF		:=	{"SUS","","GovInfoSF"}
	Local cIndexKey			:= "US_FILIAL, US_COD, US_LOJA"

	oApiManager:SetApiRelation(aStrEndM		,aFatherAlias	, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aStrCidM		,aStrEndM	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrEstM		,aStrEndM		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrConM		,aStrEndM		, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aStrComInf	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrIntInf	,aFatherAlias	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aStrMktSeg	,aFatherAlias	, aRelation, cIndexKey)	


	oApiManager:SetApiRelation(aStrGovInfo	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrInfoIE	,aStrGovInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrInfoC	,aStrGovInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrInfoSF	,aStrGovInfo	, aRelation, cIndexKey)

Return

/*/{Protheus.doc} MontaCab
Monta o array do cabeçalho que será utilizado no execauto

@param	oJson				, objeto  , Objeto com o array parseado
@param	aCab				, array   , Array que será populado com os dados do Json parciado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function MontaCab(oJson, aCab)

	If AttIsMemberOf(oJson, "name") .And. AttIsMemberOf(oJson, "id") .And. !Empty(oJson:id) .And. !Empty(oJson:name)
		If AllTrim(oJson:name) $ "INSCRICAO ESTADUAL"
			aAdd( aCab, {'US_INSCR'		,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "CNPJ|CPF" 
			aAdd( aCab, {'US_CGC' 		,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "SUFRAMA"
			aAdd( aCab, {'US_SUFRAMA' 	,oJson:id, Nil}) 
		EndIf
	EndIf

Return

/*/{Protheus.doc} TrataJson
Realiza o de/para dos campos US_PESSOA, US_TIPO, US_ORIGEM e US_QDTFUN

@param	oApiManager	, Objeto, Objeto da APIManager

@return Nil

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function TrataJson(oApiManager)
	Local nX		:= 0
	Local oJson 	:= oApiManager:GetJsonObject()

	If oJson != Nil
		If ValType(oJson['items']) == "A"
			For nX := 1 To Len(oJson['items'])
				If oJson['items'][nX]["EntityType"] != Nil
					oJson['items'][nX]["EntityType"] 				:= CRMS700A(oJson['items'][nX]["EntityType"])
				EndIf
				If oJson['items'][nX]["StrategicType"] != Nil
					oJson['items'][nX]["StrategicType"]				:= CRMS700B(oJson['items'][nX]["StrategicType"])
				EndIf
				If oJson['items'][nX]["Origin"] != Nil
					oJson['items'][nX]["Origin"]					:= CRMS700D(oJson['items'][nX]["Origin"])
				EndIf
				If oJson['items'][nX]["CompanyInfo"]["Employees"] != Nil
					oJson['items'][nX]["CompanyInfo"]["Employees"]	:= CRMS700C(oJson['items'][nX]["CompanyInfo"]["Employees"])
				EndIf
			Next
		EndIf
	EndIf

	If oJson != Nil
		oApiManager:SetJson(oJson["hasNext"], oJson['items'])
	EndIf

Return

/*/{Protheus.doc} CRMS700A
Realiza o de/para do campo US_PESSOA

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Function CRMS700A(cConteudo, nTipo)
	Default cConteudo := ""
	Default nTipo	  := 1

	If nTipo == 2
		cConteudo := StrTran(cConteudo,"1","F")
		cConteudo := StrTran(cConteudo,"2","J")

		If !(cConteudo $ "FJ")
			cConteudo := ""
		EndIf
	Else
		cConteudo := StrTran(cConteudo,"F","1")
		cConteudo := StrTran(cConteudo,"J","2")

		If !(cConteudo $ "12")
			cConteudo := ""
		EndIf
	EndIf

Return cConteudo

/*/{Protheus.doc} CRMS700B
Realiza o de/para do campo US_TIPO

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Function CRMS700B(cConteudo, nTipo)
	Default cConteudo := ""
	Default nTipo	  := 1

	If nTipo == 2
		cConteudo := StrTran(cConteudo,"1","F")
		cConteudo := StrTran(cConteudo,"2","L")
		cConteudo := StrTran(cConteudo,"3","R")
		cConteudo := StrTran(cConteudo,"4","S")
		cConteudo := StrTran(cConteudo,"5","X")

		If !(cConteudo $ "FLRSX")
			cConteudo := ""
		EndIf
	Else
		cConteudo := StrTran(cConteudo,"F","1")
		cConteudo := StrTran(cConteudo,"L","2")
		cConteudo := StrTran(cConteudo,"R","3")
		cConteudo := StrTran(cConteudo,"S","4")
		cConteudo := StrTran(cConteudo,"X","5")

		If !(cConteudo $ "12345")
			cConteudo := ""
		EndIf
	EndIf

Return cConteudo

/*/{Protheus.doc} CRMS700C
Realiza o de/para do campo US_QDTFUN

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Function CRMS700C(cConteudo, nTipo)
	Default cConteudo := ""
	Default nTipo	  := 1

	If nTipo == 2
		cConteudo	:= Tira1(cConteudo)
	Else
		cConteudo	:= Soma1(cConteudo)
	EndIf

Return cConteudo

/*/{Protheus.doc} CRMS700D
Realiza o de/para do campo US_ORIGEM

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Function CRMS700D(cConteudo, nTipo)
	Default cConteudo := ""
	Default nTipo	  := 1

	If nTipo == 2
		cConteudo	:= RetAsc(cConteudo, 1, .T.)
	Else
		cConteudo	:= RetAsc(cConteudo, 1, .F.)
	EndIf

Return cConteudo

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/09/2018
@version	12.1.20
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrSUS		:= {}
	Local aStructAlias	:= {}
	Local aStrContacts	:= {}
	Local aStrEndM		:= {}
	Local aStrCidM		:= {}
	Local aStrEstM		:= {}
	Local aStrConM		:= {}
	Local aStrComInf	:= {}
	Local aStrIntInf	:= {}
	Local aStrMktSeg	:= {}
	Local aStrGovInfo	:= {}
	Local aStrInfoIE	:= {}
	Local aStrInfoC		:= {}
	Local aStrInfoSF	:= {}


	aStrSUS			:=	{"SUS","Field","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "US_FILIAL"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, US_FILIAL, US_COD, US_LOJA"		},;								
								{"Code"							, "US_COD"										},;
								{"StoreId"						, "US_LOJA"										},;
								{"InternalId"					, "Exp:cEmpAnt, US_FILIAL, US_COD, US_LOJA"		},;
								{"ShortName"					, "US_NREDUZ"									},;
								{"Name"							, "US_NOME"										},;
								{"EntityType"					, "US_PESSOA"									},;
								{"StrategicType"				, "US_TIPO"										},;
								{"Origin"						, "US_ORIGEM"									},;
								{"OriginEntity"					, "US_ENTORI"									},;
								{"RegisterSituation"			, "US_MSBLQL"									},;
								{"ProspectSituation"			, "US_STATUS"									};
							},;
						}

	aStrContacts	:=	{"SUS","Field","ContactInformation", "ContactInformation",;
							{;
								{"type"							, ""											},;
								{"phoneNumber"					, "US_TEL"										},;
								{"phoneExtension"				, ""											},;
								{"faxNumber"					, "US_FAX"										},;
								{"faxNumberExtension"			, ""											},;
								{"homePage"						, "US_URL"										},;								
								{"email"						, "US_EMAIL"									},;
								{"diallingCode"					, "US_DDD"										},;
								{"internationalDiallingCode"	, "US_DDI"										};
							},;
						}					

	aStrEndM   		:= 	{"SUS","field","address","addressM",;
							{;
								{"address"						, "US_END"										},;
								{"number"						, ""											},;
								{"complement"					, ""											},;
								{"district"						, "US_BAIRRO"									},;
								{"zipCode"						, "US_CEP"  									},;
								{"region"						, "US_REGIAO"									},;
								{"poBox"						, ""											},;
								{"mainAddress"					, "Exp:.T."										},;
								{"shippingAddress"				, "Exp:.F."										},;
								{"billingAddress"				, "Exp:.F."										};
							},;
					}	

	aStrCidM   		:= 	{"SUS","Field","city","cityM",;
							{;
								{"cityCode"						, "US_COD_MUN"									},;
								{"cityInternalId"				, "US_COD_MUN"									},;
								{"cityDescription"				, "US_MUN"										};
							},;
					}

	aStrEstM   		:= 	{"SUS","Field","state","stateM",;
							{;
								{"stateId"						, "US_EST"										},;
								{"stateInternalId"				, "US_EST"										},;
								{"stateDescription"				, ""											};
							},;
					}

	aStrConM   		:= 	{"SUS","Field","country","countryM",;
							{;
								{"countryCode"					, "US_PAIS"										},;
								{"countryInternalId"			, "US_PAIS"										},;
								{"countryDescription"			, ""											};
							},;
					}

	aStrComInf		:=	{"SUS","Field","CompanyInfo","CompanyInfo",;
							{;
								{"CNAE"							, "US_CNAE"							},;
								{"Annualbilling"				, "US_FATANU"						},;
								{"Employees"					, "US_QTFUNC"						},;
								{"CreditLimit"					, "US_LC"							},;
								{"CreditLimitCurrency"			, "US_MOEDALC"						},;
								{"CreditLimitDate"				, "US_VENCLC"						};
							},;
						}

	aStrIntInf		:=	{"SUS","Field","InternalInformation","InternalInformation",;
							{;
								{"LastVisit"					, "US_ULTVIS"				},;
								{"VendorTypeCode"				, "US_VEND"					};
							},;
						}
						
	aStrMktSeg		:=	{"SUS","Field","marketsegment","marketsegment",;
							{;
								{"marketSegmentCode"							, "SU_CODSEG"					},;
								{"marketSegmentInternalId"						, ""							},;
								{"marketSegmentDescription"						, "US_DESSEG"					};
							},;
						}

	aStrGovInfo		:=	{"SUS","ITEM","GovernmentalInformation","GovernmentalInformation",;
							{;
							},;
						}
	
	aStrInfoIE		:=	{"SUS","Object","","GovInfoIE",;
							{;
								{"id"							, "US_INSCR"									},;
								{"name"							, "Exp:'INSCRICAO ESTADUAL'"					},;
								{"scope"						, ""											},;
								{"expireOn"						, ""											},;
								{"issueOn"						, ""											};
							},;
						}

	aStrInfoC		:=	{"SUS","Object","","GovInfoC",;
							{;
								{"id"							, "US_CGC"										},;
								{"name"							, "Exp:'CNPJ|CPF'"								},;
								{"scope"						, ""											},;
								{"expireOn"						, ""											},;
								{"issueOn"						, ""											};
							},;
						}

	aStrInfoSF		:=	{"SUS","Object","","GovInfoSF",;
							{;
								{"id"							, "US_SUFRAMA"									},;
								{"name"							, "Exp:'SUFRAMA'"								},;
								{"scope"						, ""											},;
								{"expireOn"						, ""											},;
								{"issueOn"						, ""											};
							},;
						}
						
	aStructAlias  := {aStrSUS, aStrContacts, aStrEndM, aStrCidM, aStrEstM, aStrConM, aStrComInf, aStrIntInf, aStrMktSeg, aStrGovInfo, aStrInfoIE, aStrInfoC, aStrInfoSF }

	aApiMap := {"CRMS700","items","1.000","CRMA700",aStructAlias, "items"}

Return aApiMap