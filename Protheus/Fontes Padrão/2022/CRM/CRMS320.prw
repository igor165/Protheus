#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS320()

Return

/*/{Protheus.doc} Suspects

API de integração de Suspect

@author		Squad Faturamento/CRM
@since		02/08/2018
/*/
WSRESTFUL Suspects DESCRIPTION "Cadastro de Suspects" //"Cadastro de Suspects"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os Suspects" ;
    WSSYNTAX "/api/crm/v1/Suspects/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Suspects"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo Prospesct" ;
    WSSYNTAX "/api/crm/v1/Suspects/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Suspects"

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um Suspect específico" ;
    WSSYNTAX "/api/crm/v1/Suspects/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Suspects/{Code}"	

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Suspect específico" ;
    WSSYNTAX "/api/crm/v1/Suspects/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Suspects/{Code}"	

	WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um Suspect específico" ;
    WSSYNTAX "/api/crm/v1/Suspects/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/Suspects/{Code}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET / Suspects/crm/Suspects
Retorna todos os Suspects

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Suspects

	Local cError			:= ""
	Local aFatherAlias		:= {"ACH","items"							, "items"}
	Local cIndexKey			:= "ACH_FILIAL, ACH_CODIGO, ACH_LOJA"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("CRMS320","1.000") 	

	oApiManager:SetApiAdapter("CRMS320") 
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

/*/{Protheus.doc} POST / Suspects/crm/Suspects
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
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Suspects
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("CRMS320","1.000")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiAlias({"ACH","items", "items"})
	oApiManager:SetApiMap(APIMap())

	lRet := ManutSuspect(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",ACH->ACH_CODIGO})
		lRet := GetMain(@oApiManager, aQueryString, .F.)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} GET / Suspects/crm/Suspects/{Code}
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
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Suspects

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("CRMS320","1.000")
	Local nLenFields	:= TamSX3("ACH_CODIGO")[1] + TamSX3("ACH_LOJA")[1]
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	DefRelation(@oApiManager)
	
	If Len(AllTrim(Self:Code)) >= nLenFields
		Aadd(aFilter, {"ACH", "items",{"ACH_CODIGO  = '" + SubStr(self:Code, 1, TamSX3("ACH_CODIGO")[1]) 							  + "'"}})
		Aadd(aFilter, {"ACH", "items",{"ACH_LOJA = '" + SubStr(self:Code, TamSX3("ACH_CODIGO")[1] + 1, Len(self:Code)) + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Suspect!", "O Suspect ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} PUT / Suspects/crm/Suspects/{Code}
Altera um proscpect específico

@param	Code				, caracter, Código + loja  do Suspect
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Suspects

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS320","1.000")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("ACH_CODIGO")[1] + TamSX3("ACH_LOJA")[1]

	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"ACH","items", "items"})
	oApiManager:SetApiMap(APIMap())

	If Len(AllTrim(Self:Code)) >= nLenFields
		DBSelectArea("ACH")
		DBSetOrder(1)
		If Dbseek(xFilial("ACH") + Self:Code)
			lRet := ManutSuspect(@oApiManager, Self:aQueryString, 4,, self:Code, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar o Suspect!", "Suspect " + Self:Code + " não encontrado.",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Suspect!", "O Suspect ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Aadd(aFilter, {"ACH", "items",{"ACH_CODIGO  = '" + SubStr(self:Code, 1, TamSX3("ACH_CODIGO")[1]) 							  + "'"}})
		Aadd(aFilter, {"ACH", "items",{"ACH_LOJA = '" + SubStr(self:Code, TamSX3("ACH_CODIGO")[1] + 1, Len(self:Code)) + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete / Suspects/crm/Suspects/{Code}
Deleta um proscpect específico

@param	Code				, caracter, Código + loja  do Suspect
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Suspects

	Local cResp			:= "Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("CRMS320","1.000")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("ACH_CODIGO")[1] + TamSX3("ACH_LOJA")[1]
	
	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"ACH","items", "items"})
	oApiManager:SetApiMap(APIMap())
	oApiManager:Activate()

	If Len(AllTrim(Self:Code)) >= nLenFields
		DBSelectArea("ACH")
		DBSetOrder(1)
		If Dbseek(xFilial("ACH") + Self:Code)
			lRet := ManutSuspect(@oApiManager, Self:aQueryString, 5,, self:Code, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar o Suspect!", "Suspect " + Self:Code + " não encontrado.",/*cHelpUrl*/,/*aDetails*/)
		EndIf	
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Suspect!", "O Suspect ID deve possuir pelo menos "+ cValToChar(nLenFields) +" caracteres.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutSuspect
Realiza a manutenção (inclusão/alteração/exclusão) de Suspects

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código + Loja do Suspect
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function ManutSuspect(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cSuspect			:= ""
	Local cLoja				:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nX				:= 0
	Local nPosCod			:= 0
	Local nPosLoja			:= 0
	Local nPosPessoa		:= 0
	Local nPosStatus		:= 0
	Local nPosQtdFun		:= 0
	Local nPosOrigem		:= 0

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
		cSuspect := SubStr(cChave, 1                       , TamSX3("ACH_CODIGO")[1] )
		cLoja	  := SubStr(cChave, TamSX3("ACH_CODIGO")[1] + 1 , Len(cChave)         )
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_CODIGO"}))
	nPosLoja:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_LOJA"}))

	If nOpc == 3
		If nPosCod == 0 .And. nPosLoja == 0
			aAdd( aCab, {'ACH_LOJA','01', Nil})
		ElseIf nPosCod != 0 .And. nPosLoja == 0
			aAdd( aCab, {'ACH_LOJA','01', Nil})
		EndIf
	Else 
		If nPosCod == 0 .And. nPosLoja == 0
			aAdd( aCab, {'ACH_CODIGO' ,cSuspect, Nil})
			aAdd( aCab, {'ACH_LOJA',cLoja, Nil})
		ElseIf nPosCod == 0 .And. nPosLoja != 0
			aAdd( aCab, {'ACH_CODIGO' ,cSuspect, Nil})
			aCab[nPosLoja][2] := cLoja
		ElseIf nPosCod != 0 .And. nPosLoja == 0
			aCab[nPosCod][2]  := cSuspect
			aAdd( aCab, {'ACH_LOJA','01', Nil})
		Else
			aCab[nPosCod][2]  := cSuspect
			aCab[nPosLoja][2] := cLoja		
		EndIf
	EndIf

	nPosPessoa 	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_PESSOA"}))
	nPosQtdFun 	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_QTFUNC"}))
	nPosStatus 	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_STATUS"}))
	nPosOrigem	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_ORIGEM"}))

	If nPosPessoa > 0
		aCab[nPosPessoa][2] := CRMS320A(aCab[nPosPessoa][2], 2)
	EndIf

	If nPosQtdFun > 0
		aCab[nPosQtdFun][2] := CRMS320B(aCab[nPosQtdFun][2], 2)
	EndIf	

	If nPosStatus > 0
		aCab[nPosStatus][2] := CRMS320B(aCab[nPosStatus][2], 2)
	EndIf
	If nPosOrigem > 0
		aCab[nPosOrigem][2] := CRMS320C(aCab[nPosOrigem][2], 2)
	EndIf

	If lRet

		MsExecAuto({|x,y|TMKA341(x,y)},aCab,nOpc)

		If lMsErroAuto
			aMsgErro := GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
			Next nX	
			lRet := .F.
			oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Suspect!.", cResp,/*cHelpUrl*/,/*aDetails*/)
		Else
			nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "ACH_CODIGO"}))
			ACH->(DbSeek(xFilial("ACH") + ACH->ACH_CODIGO ))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Suspects

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
Realiza o Get dos Suspects

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 

@return Nil	

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function DefRelation(oApiManager)
	Local aRelation			:= {{"ACH_FILIAL","ACH_FILIAL"},{"ACH_CODIGO","ACH_CODIGO"},{"ACH_LOJA","ACH_LOJA"}}
	Local aFatherAlias		:=	{"ACH","items"							, "items"}
	Local aStrEndM   		:= 	{"ACH","address","addressM"}
	Local aStrCidM   		:= 	{"ACH","city","cityM"}
	Local aStrEstM   		:= 	{"ACH","state","stateM"}
	Local aStrConM   		:= 	{"ACH","country","countryM"}
	Local aStrComInf		:=	{"ACH","CompanyInfo","CompanyInfo"}
	Local aStrIntInf		:=	{"ACH","InternalInformation","InternalInformation"}
	Local aStrMktSeg		:=	{"ACH","marketsegment","marketsegment"}
	Local aStrGovInfo		:=	{"ACH","GovernmentalInformation","GovernmentalInformation"}
	Local aStrInfoC			:=	{"ACH","","GovInfoC"}
	Local cIndexKey			:= "ACH_FILIAL, ACH_CODIGO, ACH_LOJA"

	oApiManager:SetApiRelation(aStrEndM		,aFatherAlias	, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aStrCidM		,aStrEndM	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrEstM		,aStrEndM		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrConM		,aStrEndM		, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aStrComInf	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrIntInf	,aFatherAlias	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aStrMktSeg	,aFatherAlias	, aRelation, cIndexKey)	


	oApiManager:SetApiRelation(aStrGovInfo	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aStrInfoC	,aStrGovInfo	, aRelation, cIndexKey)

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
			aAdd( aCab, {'ACH_INSCR'		,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "CPF/CNPJ" 
			aAdd( aCab, {'ACH_CGC' 		,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "SUFRAMA"
			aAdd( aCab, {'ACH_SUFRAMA' 	,oJson:id, Nil}) 
		EndIf
	EndIf

Return

/*/{Protheus.doc} TrataJson
Realiza o de/para dos campos ACH_PESSOA, ACH_QDTFUN

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
					oJson['items'][nX]["EntityType"] 				:= CRMS320A(oJson['items'][nX]["EntityType"])
				EndIf
				If oJson['items'][nX]["SuspectSituation"] != Nil
					oJson['items'][nX]["SuspectSituation"] 			:= CRMS320B(oJson['items'][nX]["SuspectSituation"])
				EndIf			
				If oJson['items'][nX]["Origin"] != Nil
					oJson['items'][nX]["Origin"]					:= CRMS320C(oJson['items'][nX]["Origin"])
				EndIf					
				If oJson['items'][nX]["CompanyInfo"]["Employees"] != Nil
					oJson['items'][nX]["CompanyInfo"]["Employees"]	:= CRMS320B(oJson['items'][nX]["CompanyInfo"]["Employees"])
				EndIf
			Next
		EndIf
	EndIf

	If oJson != Nil
		oApiManager:SetJson(oJson["hasNext"], oJson['items'])
	EndIf

Return

/*/{Protheus.doc} CRMS320A
Realiza o de/para do campo ACH_PESSOA

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Function CRMS320A(cConteudo, nTipo)
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


/*/{Protheus.doc} CRMS320B
Realiza o de/para do campo ACH_QDTFUN

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Function CRMS320B(cConteudo, nTipo)
	Default cConteudo := ""
	Default nTipo	  := 1

	If nTipo == 2
		cConteudo	:= Tira1(cConteudo)
	Else
		cConteudo	:= Soma1(cConteudo)
	EndIf

Return cConteudo

/*/{Protheus.doc} CRMS320C
Realiza o de/para do campo ACH_ORIGEM

@param	cConteudo	, Caracter, Conteúdo original do campo
@param	nTipo		, Numérico, Tipo de operação 1 - Get, 2 - Post/PUT

@return cConteudo = Conteúdo tratado

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Function CRMS320C(cConteudo, nTipo)
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
	Local aStrACH		:= {}
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
	Local aStrInfoC		:= {}


	aStrACH			:=	{"ACH","Field","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "ACH_FILIAL"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, ACH_FILIAL, ACH_CODIGO, ACH_LOJA"},;								
								{"Code"							, "ACH_CODIGO"									},;
								{"StoreId"						, "ACH_LOJA"									},;
								{"InternalId"					, "Exp:cEmpAnt, ACH_FILIAL, ACH_CODIGO, ACH_LOJA"},;
								{"ShortName"					, "ACH_NFANT"									},;
								{"Name"							, "ACH_RAZAO"									},;
								{"EntityType"					, "ACH_PESSOA"									},;
								{"StrategicType"				, "ACH_TIPO"									},;
								{"Origin"						, "ACH_ORIGEM"									},;
								{"OriginEntity"					, "ACH_ENTORI"									},;
								{"RegisterSituation"			, "ACH_MSBLQL"									},;
								{"SuspectSituation"				, "ACH_STATUS"									};
							},;
						}

	aStrContacts	:=	{"ACH","Field","ContactInformation", "ContactInformation",;
							{;
								{"type"							, ""											},;
								{"phoneNumber"					, "ACH_TEL"										},;
								{"phoneExtension"				, ""											},;
								{"faxNumber"					, "ACH_FAX"										},;
								{"faxNumberExtension"			, ""											},;
								{"homePage"						, "ACH_URL"										},;								
								{"email"						, "ACH_EMAIL"									},;
								{"diallingCode"					, "ACH_DDD"										},;
								{"internationalDiallingCode"	, "ACH_DDI"										};
							},;
						}					

	aStrEndM   		:= 	{"ACH","field","address","addressM",;
							{;
								{"address"						, "ACH_END"										},;
								{"number"						, ""											},;
								{"complement"					, ""											},;
								{"district"						, "ACH_BAIRRO"									},;
								{"zipCode"						, "ACH_CEP"  									},;
								{"region"						, "ACH_REGIAO"									},;
								{"poBox"						, ""											},;
								{"mainAddress"					, "Exp:.T."										},;
								{"shippingAddress"				, "Exp:.F."										},;
								{"billingAddress"				, "Exp:.F."										};
							},;
					}	

	aStrCidM   		:= 	{"ACH","Field","city","cityM",;
							{;
								{"cityCode"						, "ACH_CODMUN"									},;
								{"cityInternalId"				, "ACH_CODMUN"									},;
								{"cityDescription"				, "ACH_CIDADE"									};
							},;
					}

	aStrEstM   		:= 	{"ACH","Field","state","stateM",;
							{;
								{"stateId"						, "ACH_EST"										},;
								{"stateInternalId"				, "ACH_EST"										},;
								{"stateDescription"				, ""											};
							},;
					}

	aStrConM   		:= 	{"ACH","Field","country","countryM",;
							{;
								{"countryCode"					, "ACH_PAIS"										},;
								{"countryInternalId"			, "ACH_PAIS"										},;
								{"countryDescription"			, ""											};
							},;
					}

	aStrComInf		:=	{"ACH","Field","CompanyInfo","CompanyInfo",;
							{;
								{"CNAE"							, "ACH_CNAE"						},;
								{"Annualbilling"				, "ACH_FATANU"						},;
								{"Employees"					, "ACH_QTFUNC"						};
							},;
						}

	aStrIntInf		:=	{"ACH","Field","InternalInformation","InternalInformation",;
							{;
								{"VendorTypeCode"				, "ACH_VEND"				},;
								{"Reserv"						, "ACH_RESERV"					};
							},;
						}
						
	aStrMktSeg		:=	{"ACH","Field","marketsegment","marketsegment",;
							{;
								{"marketSegmentCode"							, "ACH_CODSEG"					},;
								{"marketSegmentInternalId"						, ""							},;
								{"marketSegmentDescription"						, "ACH_DESSEG"					};
							},;
						}

	aStrGovInfo		:=	{"ACH","ITEM","GovernmentalInformation","GovernmentalInformation",;
							{;
							},;
						}
	
	aStrInfoC		:=	{"ACH","Object","","GovInfoC",;
							{;
								{"id"							, "ACH_CGC"										},;
								{"name"							, "Exp:'CPF/CNPJ'"								},;
								{"scope"						, ""											},;
								{"expireOn"						, ""											},;
								{"issueOn"						, ""											};
							},;
						}

	aStructAlias  := {aStrACH, aStrContacts, aStrEndM, aStrCidM, aStrEstM, aStrConM, aStrComInf, aStrIntInf, aStrMktSeg, aStrGovInfo, aStrInfoC }

	aApiMap := {"CRMS320","items","1.000","CRMA320",aStructAlias, "items"}

Return aApiMap