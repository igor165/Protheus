#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CTBI030O.CH"

//dummy function
Function CTBI030O()
Return

/*/{Protheus.doc} CostCenters

API de integração de CostCenters

@author		Squad Control/CTB
@since		16/10/2018
/*/
WSRESTFUL CostCenters DESCRIPTION STR0001 //"Cadastro de Centro de Custo" 
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
	WSDATA InternalId		AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION STR0002 ; //"Carrega todos os Centros de Custos" 
    WSSYNTAX "/api/ctb/v1/CostCenters/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/CostCenters"

    WSMETHOD POST Main ;
    DESCRIPTION STR0003 ; //"Cadastra um novo Centro de Custo" 
    WSSYNTAX "/api/ctb/v1/CostCenters/{Fields}" ;
    PATH "/api/ctb/v1//CostCenters"

	WSMETHOD GET InternalId ; //Code ;
    DESCRIPTION STR0004 ; //"Carrega Centro de Custo específico" 
    WSSYNTAX "/api/ctb/v1/CostCenters/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/CostCenters/{InternalId}"	

	WSMETHOD PUT InternalId ;
    DESCRIPTION  STR0005 ; //"Altera Centro de Custo específico"
    WSSYNTAX "/api/ctb/v1/CostCenters/{InternalId}/{Fields}" ;
    PATH "/api/ctb/v1/CostCenters/{InternalId}"	

	WSMETHOD DELETE InternalId ;
    DESCRIPTION STR0006 ; //"Deleta Centro de Custo específico" 
    WSSYNTAX "/api/ctb/v1/CostCenters/{InternalId}" ;
    PATH "/api/ctb/v1/CostCenters/{InternalId}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET / CostCenters/api/ctb/v1/CostCenters
Retorna todos os Centros de Custos

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		16/10/2018
@version	12.1.23
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CostCenters

	Local cError			:= ""
	Local aFatherAlias		:= {"CTT", "items", "items"}
	Local cIndexKey			:= "CTT_FILIAL, CTT_CUSTO"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIMANAGER():New("CTBS030","1.000") 	
	
	oApiManager:SetApiAdapter("CTBS030") 
	oApiManager:SetApiMap(ApiMap())
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

/*/{Protheus.doc} POST / CostCenters/api/ctb/v1/CostCenters
Inclui um novo CENTRO DE CUSTO

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		16/10/2018
@version	12.1.23
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CostCenters
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIMANAGER():New("CTBS030","1.000")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTT","items", "items"})

	lRet := ManutCC(oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",CTT->CTT_CUSTO})
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

/*/{Protheus.doc} GET / CostCenters/api/ctb/v1/CostCenters/{Code}
Retorna um centro de custo específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		16/10/2018
@version	12.1.23
/*/
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code  WSSERVICE CostCenters

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIMANAGER():New("CTBS030","1.000")
	Local nLenFil			:= TamSX3("CTT_FILIAL")[1]
	local nLenCC			:= TamSX3("CTT_CUSTO")[1]
	Local cFilAux			:= ""
	Local cCCAux			:= ""
	
	Default Self:InternalId:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCCAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCC),nLenCC)
	
	oApiManager:SetApiMap(ApiMap()) 
    Self:SetContentType("application/json")

	If Len(cFilAux) >= nLenFil .And. Len(cCCAux) >= nLenCC
		Aadd(aFilter, {"CTT", "items",{"CTT_CUSTO  = '"+ cCCAux + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0007, STR0008+cValToChar(nLenFil+nLenCC)+STR0009,/*cHelpUrl*/,/*aDetails*/) //"Erro buscar o Centro de Custo!"#"O Centro de Custo ID deve possuir pelo menos "#" caracteres."
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

/*/{Protheus.doc} PUT / CostCenters/api/ctb/v1/CostCenters/{Code}
Altera um centro de custo específico

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		16/10/2018
@version	12.1.23
/*/

WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE CostCenters

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIMANAGER():New("CTBS030","1.000")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("CTT_FILIAL")[1] + TamSX3("CTT_CUSTO")[1]
	Local nLenFil		:= TamSX3("CTT_FILIAL")[1]
	local nLenCC		:= TamSX3("CTT_CUSTO")[1]
	Local cFilAux		:= ""
	Local cCCAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCCAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCC),nLenCC)
	
	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTT","items", "items"})

	If  Len(cFilAux) >= nLenFil .And. Len(cCCAux) >= nLenCC
		If CTT->(Dbseek(cFilAux+cCCAux))
			lRet := ManutCC(@oApiManager, Self:aQueryString, 4,, self:InternalId, cBody)
		Else 
			lRet := .F.
			oApiManager:SetJsonError("404",STR0011, STR0010,/*cHelpUrl*/,/*aDetails*/) //"Erro ao alterar o Centro de Custo!"#"Centro de Custo não encontrado."
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0011, STR0008 + cValToChar(nLenFields)+STR0009,/*cHelpUrl*/,/*aDetails*/)//"Erro ao alterar o Centro de Custo!"#"O Centro de Custo ID deve possuir pelo menos "  #" caracteres." 
	EndIf

	If lRet
		Aadd(aFilter, {"CTT", "items",{"CTT_CUSTO = '" + CTT->CTT_CUSTO + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete / CostCenters/api/ctb/v1/CostCenters/{Code}
Deleta um centro de custo específico

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		16/10/2018
@version	12.1.23
/*/

WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE CostCenters

	Local cResp			:= STR0012 //"Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIMANAGER():New("CTBS030","1.000")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("CTT_FILIAL")[1] + TamSX3("CTT_CUSTO")[1]
	Local nLenFil		:= TamSX3("CTT_FILIAL")[1]
	local nLenCC		:= TamSX3("CTT_CUSTO")[1]
	Local cFilAux		:= ""
	Local cCCAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCCAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCC),nLenCC)
	
	Self:SetContentType("application/json")
	
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If Len(cFilAux) >= nLenFil .And. Len(cCCAux) >= nLenCC
		If CTT->(Dbseek(cFilAux+cCCAux))
			lRet := ManutCC(@oApiManager, Self:aQueryString, 5,, self:InternalId, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404",STR0011, STR0010,/*cHelpUrl*/,/*aDetails*/) //"Erro ao alterar o Centro de Custo!"#"Centro de Custo não encontrado."
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0011, STR0008 + cValToChar(nLenFields) + STR0009,/*cHelpUrl*/,/*aDetails*/) //"Erro ao alterar o Centro de Custo!"#"O Centro de Custo ID deve possuir pelo menos "#" caracteres."
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

/*/{Protheus.doc} ManutCC
Realiza a manutenção (inclusão/alteração/exclusão) do Centro de Custo

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código 
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Control/CTB
@since		16/10/2018
@version	12.1.23
/*/
Static Function ManutCC(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cError			:= ""
	Local cCusto			:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nPosCod			:= 0
	Local nPosDesc          := 0
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
	Local oModel			:= Nil

	Default aJson			:= {}
	Default cChave 			:= ""

	Private lAutoErrNoFile	:= .T.
	Private lMsErroAuto 	:= .F.

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf
	EndIf

	If !Empty(cChave)
		cCusto 	:= SubStr(cChave, TamSX3("CTT_FILIAL")[1] + 1, TamSX3("CTT_CUSTO")[1] )
	EndIf

	nPosCod	 := (aScan(aCab ,{|x| AllTrim(x[1]) == "CTT_CUSTO"}))
	nPosDesc := (aScan(aCab ,{|x| AllTrim(x[1]) == "CTT_DESC01"}))

	If nOpc == 4 .Or. nOpc == 5

		If nPosCod == 0
			aAdd( aCab, {'CTT_CUSTO' ,cCusto, Nil})
		Else
			aCab[nPosCod][2]  := cCusto
		EndIf

		If nOpc == 4 .AND. nPosDesc > 0
			aCab[nPosDesc][2]  := DecodeUTF8(aCab[nPosDesc][2])
		EndIf

	Else

		If nPosDesc > 0
			aCab[nPosDesc][2]  := DecodeUTF8(aCab[nPosDesc][2])
		EndIf

	EndIf

	If lRet
		MSExecAuto({|x, y| CTBA030(x, y)},aCab, nOpc)
		If lMsErroAuto	
			lRet := .F.
			aMsgErro:= GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				If ValType(aMsgErro[nX]) == "C"
					cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
				EndIf
			Next nX	
			oApiManager:SetJsonError("400",STR0013, cResp,/*cHelpUrl*/,/*aDetails*/) //"Erro durante Inclusão/Alteração/Exclusão do Centro de Custo!"
		Else	
			CTT->(DbSeek(xFilial("CTT") + CTT->CTT_CUSTO))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get do Centro de Custo

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Control/CTB
@since		16/10/2018
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

@author		Squad Contol/CTB
@since		16/10/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrAOB		:= {}

	aStrAOB			:=	{"CTT","Fields","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "CTT_FILIAL"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, CTT_FILIAL, CTT_CUSTO"			},;								
								{"Code"							, "CTT_CUSTO"									},;
								{"InternalId"					, "CTT_FILIAL, CTT_CUSTO"						},;
								{"RegisterSituation"			, "CTT_BLOQ"									},;
								{"Name"							, "CTT_DESC01"									},;
								{"ShortCode"					, "CTT_RES"										},;
								{"Class"						, "CTT_CLASSE"									},;
								{"TopCode"						, "CTT_CCSUP"									};
							},;
						}

	aStructAlias  := {aStrAOB}

	aApiMap := {"CTBS030","items","1.000","CTBA030",aStructAlias, "items"}

Return aApiMap