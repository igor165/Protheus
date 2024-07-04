#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function SFCA003API()
Return

/*/{Protheus.doc} Motivos de Refugo

API de integração de Motivos de Refugo

@author		Renan Roeder
@since		15/10/2018
/*/
WSRESTFUL SFCA003API DESCRIPTION "Cadastro de Motivos de Refugo"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET WasteReason ;
    DESCRIPTION "Carrega todos os Motivos de Refugo" ;
    PATH "/api/pcp/v1/wasteReasons"

    WSMETHOD POST WasteReason ;
    DESCRIPTION "Cadastra um novo Motivo de Refugo" ;
    PATH "/api/pcp/v1/wasteReasons"

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um Motivo de Refugo específico" ;
    PATH "/api/pcp/v1/wasteReasons/{Code}"

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Motivo de Refugo específico" ;
    PATH "/api/pcp/v1/wasteReasons/{Code}"

	WSMETHOD DELETE Code ;
    DESCRIPTION "Exclui um Motivo de Refugo específico" ;
    PATH "/api/pcp/v1/wasteReasons/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/pcp/v1/wasteReasons
Retorna todos os Motivos de Refugo

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/

WSMETHOD GET WasteReason WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA003API

	Local cError			:= ""
	Local aFatherAlias		:= {"CYO", "items", "items"}
	Local cIndexKey			:= "CYO_FILIAL, CYO_CDRF"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("SFCA003API","1.000")

	oApiManager:SetApiAdapter("SFCA003API") 
   	oApiManager:SetApiAlias(aFatherAlias)
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

/*/{Protheus.doc} POST /api/pcp/v1/wasteReasons
Inclui um novo Motivo de Refugo

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/
WSMETHOD POST WasteReason WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA003API
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("SFCA003API","1.000")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CYO","items", "items"})

	lRet := ManutWR(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",CYO->CYO_CDRF})
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

/*/{Protheus.doc} GET /api/pcp/v1/wasteReasons/{Code}
Retorna um Motivo de Refugo específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SFCA003API

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("SFCA003API","1.000")
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	Aadd(aFilter, {"CYO", "items",{"CYO_CDRF  = '" + self:Code + "'"}})
	oApiManager:SetApiFilter(aFilter) 		
	lRet := GetMain(@oApiManager, Self:aQueryString)

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT /api/pcp/v1/wasteReasons/{Code}
Altera um Motivo de Refugo específico

@param	Code				, caracter, Código do motivo de refugo
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA003API

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("SFCA003API","1.000")
	Local cBody 	   	:= Self:GetContent()	

	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CYO","items", "items"})

	If CYO->(Dbseek(xFilial("CYO") + PADR(Self:Code,TamSx3("CYO_CDRF")[1] ," ")))
		lRet := ManutWR(@oApiManager, Self:aQueryString, 4,, self:Code, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao alterar o Motivo de Refugo!", "Motivo de Refugo não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Aadd(aFilter, {"CYO", "items",{"CYO_CDRF = '" + CYO->CYO_CDRF + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete /api/pcp/v1/wasteReasons/{Code}
Deleta um Motivo de Refugo específico

@param	Code				, caracter, Código do Motivo de Refugo
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA003API

	Local cResp			:= "Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("SFCA003API","1.000")
	Local cBody			:= Self:GetContent()
	
	Self:SetContentType("application/json")

	oApiManager:Activate()

	If CYO->(Dbseek(xFilial("CYO") + PADR(Self:Code,TamSx3("CYO_CDRF")[1] ," ")))
		lRet := ManutWR(@oApiManager, Self:aQueryString, 5,, self:Code, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao excluir o Motivo de Refugo!", "Motivo de Refugo não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutWR
Realiza a manutenção (inclusão/alteração/exclusão) de Motivos de Refugo

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código do Motivo de Refugo
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/
Static Function ManutWR(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nX				:= 0
	Local oModel			:= Nil
	Local nPosCod           := 0

	Default aJson			:= {}
	Default cChave 			:= ""

	//Private lAutoErrNoFile	:= .T.
	//Private lMsErroAuto 	:= .F.

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf

	EndIf

	If nOpc == 4
		nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CYO_CDRF"}))
		If nPosCod > 0
			aDel(aCab,nPosCod)
			aSize(aCab,Len(aCab)-1)		
		EndIf
	EndIf	

	If lRet
		oModel := FwLoadModel('SFCA003')
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			If nOpc != 5
				For nX := 1 To Len(aCab)
					If !oModel:SetValue('CYOMASTER', aCab[nX][1], aCab[nX][2])
						lRet := .F.
						Exit
					EndIf
				Next nX
			EndIf
			If !((oModel:VldData() .and. oModel:CommitData())) .Or. !lRet
				aMsgErro := oModel:GetErrorMessage()
				cResp	 := ""
				For nX := 1 To Len(aMsgErro)
					If ValType(aMsgErro[nX]) == "C"
						cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
					EndIf
				Next nX	
				lRet := .F.
				oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Motivo de Refugo!.", cResp,/*cHelpUrl*/,/*aDetails*/)
			Else
				CYO->(DbSeek(xFilial("CYO") + oModel:GetValue('CYOMASTER', 'CYO_CDRF')))
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Motivos de Refugo

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default oApiManager		:= Nil	
	Default aQueryString	:={,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Renan Roeder
@since		15/10/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrCYO		:= {}

	aStrCYO			:=	{"CYO","Fields","items","items",;
							{;
								{"Code"					, "CYO_CDRF"				},;
								{"Description"			, "CYO_DSRF"				},;
								{"IsRework"				, "CYO_LGRT"				},;								
								{"IsScrapMaterial"		, "CYO_LGRFMP"				};
							},;
						}

	aStructAlias  := {aStrCYO}

	aApiMap := {"SFCA003API","items","1.000","SFCA003",aStructAlias, "items"}

Return aApiMap