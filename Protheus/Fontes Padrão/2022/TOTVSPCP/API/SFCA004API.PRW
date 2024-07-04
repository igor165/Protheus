#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function SFCA004API()
Return

/*/{Protheus.doc} Motivos de Parada

API de integração de Motivos de Parada

@author		Renan Roeder
@since		10/10/2018
/*/
WSRESTFUL SFCA004API DESCRIPTION "Cadastro de Motivos de Parada"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET StopReason ;
    DESCRIPTION "Carrega todos os Motivos de Parada" ;
    PATH "/api/pcp/v1/stopReasons"

    WSMETHOD POST StopReason ;
    DESCRIPTION "Cadastra um novo Motivo de Parada" ;
    PATH "/api/pcp/v1/stopReasons"

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um Motivo de Parada específico" ;
    PATH "/api/pcp/v1/stopReasons/{Code}"

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Motivo de Parada específico" ;
    PATH "/api/pcp/v1/stopReasons/{Code}"

	WSMETHOD DELETE Code ;
    DESCRIPTION "Exclui um Motivo de Parada específico" ;
    PATH "/api/pcp/v1/stopReasons/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/pcp/v1/stopReasons
Retorna todos os Motivos de Parada

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		10/10/2018
@version	12.1.23
/*/

WSMETHOD GET StopReason WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA004API

	Local cError			:= ""
	Local aFatherAlias		:= {"CYN", "items", "items"}
	Local cIndexKey			:= "CYN_FILIAL, CYN_CDSP"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("SFCA004API","1.000") 	

	oApiManager:SetApiAdapter("SFCA004API") 
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

/*/{Protheus.doc} POST /api/pcp/v1/stopReasons
Inclui um novo Motivo de Parada

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		10/10/2018
@version	12.1.23
/*/
WSMETHOD POST StopReason WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA004API
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("SFCA004API","1.000")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CYN","items", "items"})

	lRet := ManutSR(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",CYN->CYN_CDSP})
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

/*/{Protheus.doc} GET /api/pcp/v1/stopReasons/{Code}
Retorna um Motivo de Parada específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		10/10/2018
@version	12.1.23
/*/
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SFCA004API

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("SFCA004API","1.000")
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	Aadd(aFilter, {"CYN", "items",{"CYN_CDSP  = '" + self:Code + "'"}})
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

/*/{Protheus.doc} PUT /api/pcp/v1/stopReasons/{Code}
Altera um Motivo de Parada específico

@param	Code				, caracter, Código do motivo de parada
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		10/10/2018
@version	12.1.23
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA004API

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("SFCA004API","1.000")
	Local cBody 	   	:= Self:GetContent()	

	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CYN","items", "items"})

	If CYN->(Dbseek(xFilial("CYN") + PADR(Self:Code,TamSx3("CYN_CDSP")[1] ," ")))
		lRet := ManutSR(@oApiManager, Self:aQueryString, 4,, self:Code, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao alterar o Motivo de Parada!", "Motivo de Parada não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Aadd(aFilter, {"CYN", "items",{"CYN_CDSP = '" + CYN->CYN_CDSP + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete /api/pcp/v1/stopReasons/{Code}
Deleta um Motivo de Parada específico

@param	Code				, caracter, Código do Motivo de Parada
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		10/10/2018
@version	12.1.23
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA004API

	Local cResp			:= "Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("SFCA004API","1.000")
	Local cBody			:= Self:GetContent()
	
	Self:SetContentType("application/json")

	oApiManager:Activate()

	If CYN->(Dbseek(xFilial("CYN") + PADR(Self:Code,TamSx3("CYN_CDSP")[1] ," ")))
		lRet := ManutSR(@oApiManager, Self:aQueryString, 5,, self:Code, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao excluir o Motivo de Parada!", "Motivo de Parada não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutSR
Realiza a manutenção (inclusão/alteração/exclusão) de Motivos de Parada

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Num�rico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código do Motivo de Parada
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Renan Roeder
@since		10/10/2018
@version	12.1.23
/*/
Static Function ManutSR(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
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
		nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CYN_CDSP"}))
		If nPosCod > 0
			aDel(aCab,nPosCod)
			aSize(aCab,Len(aCab)-1)		
		EndIf
	EndIf	

	If lRet
		oModel := FwLoadModel('SFCA004')
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			If nOpc != 5
				For nX := 1 To Len(aCab)
					If !oModel:SetValue('CYNMASTER', aCab[nX][1], aCab[nX][2])
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
				oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Motivo de Parada!.", cResp,/*cHelpUrl*/,/*aDetails*/)
			Else
				CYN->(DbSeek(xFilial("CYN") + oModel:GetValue('CYNMASTER', 'CYN_CDSP')))
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Motivos de Parada

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Renan Roeder
@since		10/10/2018
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
@since		10/10/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrCYN		:= {}

	aStrCYN			:=	{"CYN","Fields","items","items",;
							{;
								{"Code"						, "CYN_CDSP"				},;
								{"Description"				, "CYN_DSSP"				},;
								{"IsEfficiency"				, "CYN_LGEF"				},;								
								{"IsEmailEquipment"			, "CYN_LGELEQ"				},;
								{"IsServiceRequest"			, "CYN_LGSS"				},;
								{"IsSetup"					, "CYN_LGSU"				};
							},;
						}

	aStructAlias  := {aStrCYN}

	aApiMap := {"SFCA004API","items","1.000","SFCA004",aStructAlias, "items"}

Return aApiMap