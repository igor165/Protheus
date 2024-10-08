#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "CTBI040O.CH"

//dummy function
Function CTBI040O()
Return

/*/{Protheus.doc} AccountingItems

API de integra��o de Item Cont�bil

@author		Squad Control/CTB
@since		07/11/2018
/*/
WSRESTFUL AccountingItems DESCRIPTION STR0001  //"Cadastro de Item Cont�bil"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL	
	WSDATA InternalId		AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION STR0002 ; //"Carrega todos os Itens Cont�beis"
    WSSYNTAX "/api/ctb/v1/AccountingItems/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/AccountingItems"

    WSMETHOD POST Main ;
    DESCRIPTION STR0003 ; //"Cadastra um novo Item Cont�bil"
    WSSYNTAX "/api/ctb/v1/AccountingItems/{Fields}" ;
    PATH "/api/ctb/v1/AccountingItems"

	WSMETHOD GET InternalId ;
    DESCRIPTION STR0004 ; //"Carrega um Item Cont�bil espec�fico"
    WSSYNTAX "/api/ctb/v1/AccountingItems/{InternalId}/{Order, Page, PageSize, Fields, InternalId}" ;
    PATH "/api/ctb/v1/AccountingItems/{InternalId}"	

	WSMETHOD PUT InternalId ;
    DESCRIPTION STR0005 ; //"Altera um Item Cont�bil espec�fico"
    WSSYNTAX "/api/ctb/v1/AccountingItems/{InternalId}/{Fields}" ;
    PATH "/api/ctb/v1/AccountingItems/{InternalId}"	

	WSMETHOD DELETE InternalId ;
    DESCRIPTION STR0006 ; //"Deleta um Item Cont�bil espec�fico"
    WSSYNTAX "/api/ctb/v1/AccountingItems/{InternalId}/{InternalId}" ;
    PATH "/api/ctb/v1/AccountingItems/{InternalId}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET / AccountingItems /api/ctb/v1/AccountingItems
Retorna todos Itens Cont�beis

@param	Order		, caracter, Ordena��o da tabela principal
@param	Page		, num�rico, N�mero da p�gina inicial da consulta
@param	PageSize	, num�rico, N�mero de registro por p�ginas
@param	Fields		, caracter, Campos que ser�o retornados no GET.

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE AccountingItems

	Local cError			:= ""
	Local aFatherAlias		:= {"CTD", "items", "items"}
	Local cIndexKey			:= "CTD_FILIAL, CTD_ITEM"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIMANAGER():New("CTBI040O","1.000") 	

	oApiManager:SetApiAdapter("CTBI040O") 
	oApiManager:SetApiMap(ApiMap())
   	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate()

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError["code"]), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / AccountingItems /api/ctb/v1/AccountingItems
Inclui um novo Item Cont�bil

@param	Order		, caracter, Ordena��o da tabela principal
@param	Page		, num�rico, N�mero da p�gina inicial da consulta
@param	PageSize	, num�rico, N�mero de registro por p�ginas
@param	Fields		, caracter, Campos que ser�o retornados no GET.

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/
WSMETHOD POST Main WSRECEIVE Fields WSSERVICE AccountingItems
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIMANAGER():New("CTBI040O","1.000")

	Self:SetContentType("application/json")
    cBody := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTD","items", "items"})

	lRet := ManutItem(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",CTD->CTD_ITEM})
		lRet := GetMain(@oApiManager, aQueryString, .F.)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError["code"]), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} GET / AccountingItems /api/ctb/v1/AccountingItems/{InternalId}
Retorna um Item Cont�bil espec�fico

@param	Order		, caracter, Ordena��o da tabela principal
@param	Page		, num�rico, N�mero da p�gina inicial da consulta
@param	PageSize	, num�rico, N�mero de registro por p�ginas
@param	Fields		, caracter, Campos que ser�o retornados no GET.

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, InternalId  WSSERVICE AccountingItems

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIMANAGER():New("CTBI040O","1.000")
	Local nLenFil			:= TamSX3("CTD_FILIAL")[1]
	local nLenItem			:= TamSX3("CTD_ITEM")[1]
	Local cFilAux			:= ""
	Local cItemAux			:= ""
	
	Default Self:InternalId:= ""

	cFilAux  := Left(self:InternalId,nLenFil)
	cItemAux := SubStr(self:InternalId,nLenFil+1,nLenItem)
	
	cFilAux  := PadR(cFilAux,nLenFil)
	cItemAux := PadR(cItemAux,nLenItem)
	
	oApiManager:SetApiMap(ApiMap()) 
    Self:SetContentType("application/json")
	
	Aadd(aFilter, {"CTD", "items",{"CTD_ITEM = '"+ cItemAux + "'"}})
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

/*/{Protheus.doc} PUT /  AccountingItems /api/ctb/v1/AccountingItems/{InternalId}
Altera um Item Cont�bil espec�fico

@param	InternalId			, caracter, C�digo 
@param	Order				, caracter, Ordena��o da tabela principal
@param	Page				, num�rico, Numero da p�gina inicial da consulta
@param	PageSize			, num�rico, Numero de registro por p�ginas
@param	Fields				, caracter, Campos que ser�o retornados no GET.

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Fields, InternalId WSSERVICE AccountingItems

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIMANAGER():New("CTBI040O","1.000")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFil		:= TamSX3("CTD_FILIAL")[1]
	local nLenItem		:= TamSX3("CTD_ITEM")[1]
	Local cFilAux		:= ""
	Local cItemAux		:= ""

	cFilAux  := Left(self:InternalId,nLenFil)
	cItemAux := SubStr(self:InternalId,nLenFil+1,nLenItem)
	
	cFilAux  := PadR(cFilAux,nLenFil)
	cItemAux := PadR(cItemAux,nLenItem)
	
	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTD","items", "items"})

	If CTD->(Dbseek(cFilAux+cItemAux))
		lRet := ManutItem(@oApiManager, Self:aQueryString, 4,, self:InternalId, cBody)
	Else 
		lRet := .F.
		oApiManager:SetJsonError("404",STR0007, STR0008,/*cHelpUrl*/,/*aDetails*/)  //"Erro ao alterar o Item Cont�bil!" //"Item Cont�bil n�o encontrado."
	EndIf
	
	If lRet
		Aadd(aFilter, {"CTD", "items",{"CTD_ITEM = '" + CTD->CTD_ITEM + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete /  AccountingItems /api/ctb/v1/AccountingItems/{InternalId}
Deleta um proscpect espec�fico

@param	InternalId			, caracter, C�digo 
@param	Order				, caracter, Ordena��o da tabela principal
@param	Page				, num�rico, Numero da p�gina inicial da consulta
@param	PageSize			, num�rico, Numero de registro por p�ginas
@param	Fields				, caracter, Campos que ser�o retornados no GET.

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE InternalId WSSERVICE AccountingItems
	Local cResp			:= STR0009 //"Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIMANAGER():New("CTBI040O","1.000")
	Local cBody			:= Self:GetContent()
	Local nLenFil		:= TamSX3("CTD_FILIAL")[1]
	local nLenItem		:= TamSX3("CTD_ITEM")[1]
	Local cFilAux		:= ""
	Local cItemAux		:= ""

	cFilAux  := Left(self:InternalId,nLenFil)
	cItemAux := SubStr(self:InternalId,nLenFil+1,nLenItem)
	
	cFilAux  := PadR(cFilAux,nLenFil)
	cItemAux := PadR(cItemAux,nLenItem)
	
	Self:SetContentType("application/json")
	
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If CTD->(Dbseek(cFilAux+cItemAux))
		lRet := ManutItem(@oApiManager, Self:aQueryString, 5,, self:InternalId, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404",STR0010, STR0008,/*cHelpUrl*/,/*aDetails*/) //"Item Cont�bil n�o encontrado." //"Erro na exclus�o do Item Cont�bil!"
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

/*/{Protheus.doc} ManutItem
Realiza a manuten��o (inclus�o/altera��o/exclus�o) do Item Cont�bil

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no m�todo 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Num�rico	, Opera��o a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com C�digo 
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, L�gico	, Retorna se realizou ou n�o o processo

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/
Static Function ManutItem(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cError			:= ""
	Local cItem				:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nPosCod			:= 0
	Local nPosDesc          := 0
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
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
		cItem 	:= SubStr(cChave, TamSX3("CTD_FILIAL")[1] + 1, TamSX3("CTD_ITEM")[1] )
	EndIf

	nPosCod	 := (aScan(aCab ,{|x| AllTrim(x[1]) == "CTD_ITEM"}))
	nPosDesc := (aScan(aCab ,{|x| AllTrim(x[1]) == "CTD_DESC01"}))

	If nOpc == 4 .Or. nOpc == 5

		If nPosCod == 0
			aAdd( aCab, {'CTD_ITEM' ,cItem, Nil})
		Else
			aCab[nPosCod][2]  := cItem
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
		MSExecAuto({|x, y| CTBA040(x, y)},aCab, nOpc)
		If lMsErroAuto	
			lRet := .F.
			aMsgErro:= GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				If ValType(aMsgErro[nX]) == "C"
					cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
				EndIf
			Next nX	
			oApiManager:SetJsonError("400",STR0011, cResp,/*cHelpUrl*/,/*aDetails*/) //"Erro durante Inclus�o/Altera��o/Exclus�o do Item Cont�bil!"
		Else	
			CTD->(DbSeek(xFilial("CTD") + CTD->CTD_ITEM))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get do Item Cont�bil

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no m�todo 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informa��o se existem ou n�o mais paginas a serem exibidas
@param cIndexKey	, String	, �ndice da tabela pai

@return lRet	, L�gico	, Retorna se conseguiu ou n�o processar o Get.

@author		Squad Control/CTB
@since		07/11/2018
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
@since		07/11/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrAOB		:= {}

	aStrAOB			:=	{"CTD","Fields","items","items",;
							{;
								{"CompanyId"			, "Exp:cEmpAnt"							},;
								{"BranchId"				, "CTD_FILIAL"							},;
								{"CompanyInternalId"	, "Exp:cEmpAnt, CTD_FILIAL, CTD_ITEM"	},;								
								{"Code"					, "CTD_ITEM"							},;
								{"InternalId"			, "CTD_FILIAL, CTD_ITEM"				},;
								{"Description"			, "CTD_DESC01"							},;
								{"Class"				, "CTD_CLASSE"							},;
								{"RegisterSituation"	, "CTD_BLOQ"							},;
								{"TopCode"				, "CTD_ITSUP"							};								
							},;
						}
	
	aStructAlias  := {aStrAOB}

	aApiMap := {"CTBI040O","items","1.000","CTBI040O",aStructAlias, "items"}

Return aApiMap
