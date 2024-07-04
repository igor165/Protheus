#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS480()

Return

/*/{Protheus.doc} salestargets
API de integração de Cadastro de Metas de Venda

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

WSRESTFUL SalesTargets DESCRIPTION "Cadastro de Metas de Venda" 

	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code 	        AS STRING	OPTIONAL
	WSDATA SequenceId       AS STRING	OPTIONAL

	//---------------------------------------------------------------------
    WSMETHOD GET Main ;
    DESCRIPTION "Lista todas Metas de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/salestargets"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra uma nova Meta de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Fields}" ;
    PATH "/api/crm/v1/salestargets"
	//---------------------------------------------------------------------
    WSMETHOD GET Code ;
    DESCRIPTION "Lista uma Meta de Venda Especifica" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}"

    WSMETHOD PUT Code ;
    DESCRIPTION "Altera uma Meta de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}"

    WSMETHOD DELETE Code ;
    DESCRIPTION "Exclui uma Meta de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}"
	//---------------------------------------------------------------------//itensSalesTarget
	WSMETHOD GET Itens ;
    DESCRIPTION "Lista os itens da Meta de Venda informada" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}/ListOfsalestargets"

 	WSMETHOD POST Itens ;
    DESCRIPTION "Cadastra um novo item na Meta de Venda informada" ;
    WSSYNTAX "/api/crm/v1/salestarget/{Code}/ListOfsalestargets/{Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}/ListOfsalestargets"
	//-----------------------------------------------------------------------
	WSMETHOD GET ItemId ;
    DESCRIPTION "Lista um item específico da Meta de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{SequenceId}/{Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{SequenceId}"

    WSMETHOD PUT ItemId ;
    DESCRIPTION "Altera/Inclui um item específico da Meta de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{SequenceId}/{Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{SequenceId}"

    WSMETHOD DELETE ItemId ;
    DESCRIPTION "Exclui um item específico da Meta de Venda" ;
    WSSYNTAX "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{SequenceId}/{Fields}" ;
    PATH "/api/crm/v1/salestargets/{Code}/ListOfsalestargets/{SequenceId}"

ENDWSRESTFUL

/*/{Protheus.doc} GET /salestargets/crm/salestargets/
Lista todas Metas de Venda

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SalesTargets

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	Local aRelation			:= {{"CT_FILIAL","CT_FILIAL"},{"CT_DOC","CT_DOC"}}
	Local aFatherAlias		:= {"SCT", "items","items"}
	Local aChildrenAlias    := {"SCT", "ListOfsalestargets", "ListOfsalestargets" }
	Local cIndexKey			:= "CT_FILIAL, CT_DOC"

	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("crms480","1.000") 
	DefRelation(@oApiManager)
	oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)
    
	lRet    := GetSCT(@oApiManager, Self)	

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	FreeObj(oApiManager)

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} POST /salestargets/crm/salestargets/

Inclui uma nova meta de venda.
@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		crm/fat
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD POST Main WSRECEIVE Fields  WSSERVICE SalesTargets

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("crms480","1.000")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SCT","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet
        lRet := ManutSCT(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
			Aadd(aFilter, {"SCT", "items",{"CT_FILIAL = '" 	+ SCT->CT_FILIAL + "'"}})
			Aadd(aFilter, {"SCT", "items",{"CT_DOC	  = '" + SCT->CT_DOC + 	   "'"}})			
			oApiManager:SetApiFilter(aFilter)
			lRet    := GetMain(oApiManager, Self:aQueryString)
        Endif
    Else
		lRet := .F.
        oApiManager:SetJsonError("400","Erro ao Incluir Meta de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
    aSize(aFilter,0)
    FreeObj( oJson )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GET /salestargets/crm/salestargets/{Code}
Consulta uma Meta de Venda específica

@param	Code		        , caracter, Código da Meta de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
WSMETHOD GET Code PATHPARAM Code WSRECEIVE  Order, Page, PageSize, Fields  WSSERVICE SalesTargets

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("crms480","1.000")
	Local aRelation			:= {{"CT_FILIAL","CT_FILIAL"},{"CT_DOC","CT_DOC"}}
	Local aFatherAlias		:= {"SCT", "items","items"}
	Local aChildrenAlias    := {"SCT", "ListOfsalestargets", "ListOfsalestargets" }
	Local cIndexKey			:= "CT_FILIAL, CT_DOC"

	Default Self:Code:= ""

	Self:SetContentType("application/json")
	oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)

	SCT->(DbSetOrder(1))
	If SCT->(DbSeek(Self:Code))
		aAdd(aFilter, {"SCT", "items",{"CT_FILIAL  = '" + SCT->CT_FILIAL  + "'"}})
		aAdd(aFilter, {"SCT", "items",{"CT_DOC	   = '" + SCT->CT_DOC +  "'"}})
		oApiManager:SetApiFilter(aFilter)
		lRet := GetMain(@oApiManager, Self:aQueryString, .F.)
	Else 
	    lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar Meta de Venda!", "Meta de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet
/*/{Protheus.doc} GET /salestargets/crm/salestargets/{Code}
Altera uma Meta de Venda específica

@param	Code		        , caracter, Código da Meta de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesTargets

	Local aFilter		:= {}
	Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.    
	Local oApiManager 	:= FWAPIManager():New("crms480","1.000")
	Local oJson			:= THashMap():New()	

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SCT","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
		SCT->(DbSetOrder(1))
        If SCT->(DbSeek( Self:Code ))
       		lRet := ManutSCT(oApiManager, Self:aQueryString, 4, aJson,, oJson, cBody)
        	If lRet
				Aadd(aFilter, {"SCT", "items",{"CT_FILIAL = '" 	+ SCT->CT_FILIAL + "'"}})
				Aadd(aFilter, {"SCT", "items",{"CT_DOC	  = '" + SCT->CT_DOC + "'"}})
                oApiManager:SetApiFilter(aFilter)
				lRet    := GetMain(oApiManager, Self:aQueryString)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar a Meta de Venda!", "Meta de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Meta de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize( aFilter, 0)
	aSize( aJson, 0)
    FreeObj( oJson )

Return lRet

/*/{Protheus.doc} DELETE /salestargets/crm/salestargets/{Code}
Deleta uma Meta de Venda específica

@param	Code		        , caracter, Código do Meta de Venda
@param	Fields				, caracter, Campos que serão retornados na requisição.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/09/2018
@version	12.1.21
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Fields WSSERVICE SalesTargets

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("crms480","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SCT","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	SCT->(DbSetOrder(1))
    If SCT->(DbSeek( Self:Code ))
		lRet := ManutSCT(oApiManager, Self:aQueryString, 5, aJson, Self:Code, , cBody)        
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Meta de Venda!", "Meta de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize(aJson,0)
    FreeObj( oJsonPositions )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GET /salestargets/crm/salestargets/{Code}
Consulta uma Meta de Venda específica

@param	Code		        , caracter, Código do Meta de Venda
@return lRet				, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
WSMETHOD GET Itens PATHPARAM Code  WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SalesTargets

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("crms480","1.000")

	Default Self:Code		:= ""
	
	Self:SetContentType("application/json")
	oApiManager:SetApiMap(ApiMapItem())

	SCT->(DbSetOrder(1))
	If SCT->(DbSeek(Self:Code)) 
		aAdd(aFilter, {"SCT", "items",{"CT_FILIAL  = '" + SCT->CT_FILIAL +  "'"}})
		aAdd(aFilter, {"SCT", "items",{"CT_DOC	   = '" + SCT->CT_DOC 	 +  "'"}})		
		
		oApiManager:SetApiFilter(aFilter)
		lRet := GetItem(@oApiManager, Self:aQueryString)
	Else 
	    lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar item da Meta de Venda!", "Item da Meta de Venda não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} POST /salestargets/crm/salestargets/{Code}/
Altera um item de uma Meta de Venda específica

@param	Code		        , caracter, Código da Meta de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

WSMETHOD POST Itens PATHPARAM Code WSRECEIVE Fields  WSSERVICE SalesTargets

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local cChave		:= Self:Code
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("crms480","1.000")
	Local oJson			:= THashMap():New()

	Private Inclui 	:= .T.

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SCT","items", "items"})
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet
		SCT->(DbSetOrder(1))
		If SCT->(DbSeek(Self:Code))
			lRet := ManutItem(oApiManager, Self:aQueryString, 3, aJson, cChave, oJson, cBody)
			If lRet
				Aadd(aFilter, {"SCT", "items",{"CT_FILIAL = '" + SCT->CT_FILIAL + "'"}})
				Aadd(aFilter, {"SCT", "items",{"CT_DOC = '" + SCT->CT_DOC 	  + "'"}})
				Aadd(aFilter, {"SCT", "items",{"CT_SEQUEN = '" + SCT->CT_SEQUEN + "'"}})
				oApiManager:SetApiFilter(aFilter)
				lRet := GetItem(@oApiManager, Self:aQueryString)
			Endif
		Else
			lRet := .F.
            oApiManager:SetJsonError("404","Erro ao Incluir Item!", "Meta de Venda informada nao foi encontrada.",/*cHelpUrl*/,/*aDetails*/)
		Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Item!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
    aSize(aFilter,0)
    FreeObj( oJson )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GET /salestargets/crm/salestargets/{Code}
Lista um item de Meta de Venda específica

@param	Code		        , caracter, Código do Meta de Venda
@param	Sequence ID			, caracter, Código do Item da meta de venda.

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ItemId PATHPARAM Code, SequenceId WSRECEIVE Fields  WSSERVICE SalesTargets

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("crms480","1.000")

	Default Self:Code		:= ""
	Default Self:SequenceId	:= ""
	
	Self:SetContentType("application/json")
	oApiManager:SetApiMap(ApiMapItem())

	SCT->(DbSetOrder(1))
	If SCT->(DbSeek(Self:Code + Self:SequenceId))
		Aadd(aFilter, {"SCT", "items",{"CT_FILIAL = '" 	+ SCT->CT_FILIAL + "'"}})
		Aadd(aFilter, {"SCT", "items",{"CT_DOC	  = '" + SCT->CT_DOC + 	   "'"}})
		aAdd(aFilter, {"SCT", "items",{"CT_SEQUEN = '" + SCT->CT_SEQUEN +  "'"}})
		oApiManager:SetApiFilter(aFilter)
		lRet := GetItem(@oApiManager, Self:aQueryString)
	Else 
	    lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar item da Meta de Venda!", "Item da Meta de Venda não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT /salestargets/crm/salestargets/{Code}
Altera um item de uma Meta de Venda específica

@param	Code		        , caracter, Código do Meta de Venda
@param	Sequence ID			, caracter, Código do Item da meta de venda.
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

WSMETHOD PUT ItemId PATHPARAM Code, SequenceId  WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesTargets

	Local aFilter		:= {}
	Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.    
	Local oApiManager 	:= FWAPIManager():New("crms480","1.000")
	Local oJson			:= THashMap():New()	
	Local cChave		:= ""

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SCT","items", "items"})
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)
	cChave := Self:Code + Self:SequenceId 
    If lRet
		SCT->(DbSetOrder(1))
        If SCT->(DbSeek(cChave))
       		lRet := ManutItem(oApiManager, Self:aQueryString, 4, aJson, Self:SequenceId , oJson, cBody)
        	If lRet
				SCT->(DbSeek(cChave))
				Aadd(aFilter, {"SCT", "items",{"CT_FILIAL = '" 	+ SCT->CT_FILIAL + "'"}})
				Aadd(aFilter, {"SCT", "items",{"CT_DOC	  = '" + SCT->CT_DOC + 	   "'"}})
				aAdd(aFilter, {"SCT", "items",{"CT_SEQUEN = '" + SCT->CT_SEQUEN +  "'"}})
                oApiManager:SetApiFilter(aFilter)
				lRet := GetItem(@oApiManager, Self:aQueryString)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar a Meta de Venda!", "Meta de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Meta de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize( aFilter, 0)
	aSize( aJson, 0)
    FreeObj( oJson )

Return lRet

/*/{Protheus.doc} DELETE /salestargets/crm/salestargets/{Code}
Deleta uma Meta de Venda específica

@param	Code		        , caracter, Código do Meta de Venda
@param	Sequence ID			, caracter, Código do Item da meta de venda.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/09/2018
@version	12.1.21
/*/

WSMETHOD DELETE ItemId PATHPARAM Code, SequenceId  WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SalesTargets

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cChave		:= Self:Code + Self:SequenceId
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("crms480","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SCT","items", "items"})
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:Activate()

	SCT->(DbSetOrder(1))
    If SCT->(DbSeek(cChave ))
		lRet := ManutItem(oApiManager, Self:aQueryString, 5, aJson, Self:SequenceId , , cBody)        
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir item da Meta de Venda!", "Item da Meta de Venda não encontrado.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize(aJson,0)
    FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get da tabela SCT

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, lHasNext)

	Local aFatherAlias		:= {"SCT", "items","items"}
	Local aChildrenAlias    := {"SCT", "ListOfSalestargets", "ListOfSalestargets" }
	Local cIndexKey			:= "CT_FILIAL, CT_DOC"
	Local lRet 				:= .T.
	Local nLenJson			:= 0
	Local oJson				:= Nil

	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, , aChildrenAlias,aFatherAlias,cIndexKey,oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	If lRet
		oJson := oApiManager:GetJsonObject()
		nLenJson := Len(oJson[oApiManager:cApiName])
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	FreeObj( aFatherAlias )	
	FreeObj( aChildrenAlias )	

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetSCT
Realiza o Get SALEStARGETS

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetSCT(oApiManager, Self)

	Local aFatherAlias	:=  {"SCT","items"           ,"items"            }
    Local aQuery        := {}
	Local cIndexKey		:=  "CT_FILIAL, CT_DOC, CT_SEQUEN"
    Local lRet          :=  .T.

	If Len(oApiManager:GetApiRelation()) == 0
		DefRelation(@oApiManager)
	EndIf

    aQuery := MntQuery()
	oApiManager:setQuery("items",aQuery[1],aQuery[2])
    
	lRet := GetMain(@oApiManager, Self:aQueryString, .F.)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetItem
Realiza o Get dos Items

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		13/12/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetItem(oApiManager, aQueryString, lHasNext)

	Local aFatherAlias		:= {"SCT","items"           ,"items"            }
    Local lRet 				:= .T.
    Local cIndexKey		    := " CT_FILIAL, CT_DOC, CT_SEQUEN "

	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.
	
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:SetApiAlias(aFatherAlias)

	lRet := ApiMainGet(@oApiManager, aQueryString, , , aFatherAlias, cIndexKey , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)    

Return lRet

/*/{Protheus.doc} ManutSCT
Realiza a manutenção (inclusão/alteração/exclusão) da Meta de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do apontamento
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

Static Function ManutSCT(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)
	
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aFronze	:= {"CT_DOC"}
	Local aModif	:= {}
	Local aMsgErro	:= {}
	Local aAuxFld	:= {}
	Local aAuxGd	:= {}  
	Local cCodCamp 	:= ""
	Local cCodEven 	:= ""	
	Local cCodProd 	:= ""
	Local cCodScri 	:= ""
	Local cResp		:= ""	
	Local lRet		:= .T.
    Local nX		:= 0	
	Local nY		:= 0
	Local nPosCamp 	:= 0
	Local nPosEven 	:= 0
	Local nPosScri 	:= 0
	Local nPosProd 	:= 0
	Local oModel	:= FWLoadModel("FATA050")
	Local oModelFld := oModel:GetModel("SCTCAB")
	Local oModelGd	:= oModel:GetModel("SCTGRID")

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

	If nOpcx <> MODEL_OPERATION_DELETE

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabec)
		EndIf

		If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2])
				oApiManager:ToExecAuto(2, aJson[1][2][nX][1][2], aItens)
			Next
		EndIf

		If nOpcx == MODEL_OPERATION_INSERT
			oModel:SetOperation(MODEL_OPERATION_INSERT)
		Elseif nOpcx == MODEL_OPERATION_UPDATE
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
		Endif
	Else
		oModel:SetOperation(MODEL_OPERATION_DELETE)
    Endif
	
	If oModel:Activate()
		If oModel:nOperation <> MODEL_OPERATION_DELETE
			aAuxFld := oModelFld:GetStruct():GetFields()
			aAuxGd	:= oModelGd:GetStruct():GetFields()
			
			For nY := 1 To Len (aCabec)
				If aScan(aAuxFld, {|x| AllTrim(x[3]) == AllTrim(aCabec[nY][1])}) > 0
					If aScan(aFronze, aCabec[nY,1]) == 0 .or. oModel:nOperation != MODEL_OPERATION_UPDATE
						If !oModelFld:SetValue(aCabec[nY,1], aCabec[nY,2]) 
							lRet := .F.
							cResp := "Não foi possível atribuir o valor " + AllToChar(aCabec[nY,2]) + " ao campo " + aCabec[nY,1] + "."
							Exit
						EndIf
					Endif
				Endif
			Next nY

			If lRet
				For nX := 1 To Len(aItens)

					If nX > 1 .And. oModel:nOperation == MODEL_OPERATION_INSERT
						oModelGd:AddLine()
					Elseif oModel:nOperation == MODEL_OPERATION_UPDATE

						nPosSeq := aScan(aItens[nX], {|x| AllTrim(x[1]) == "CT_SEQUEN"})
						cSequen := IIf(nPosSeq > 0 ,aItens[nX,nPosSeq,2],CriaVar("CT_SEQUEN"))
												
						If !oModelGd:SeekLine({{"CT_SEQUEN",cSequen}})
							If nX > 1
								oModelGd:AddLine()
							Endif
						Endif
					Endif
					For nY := 1 To Len(aItens[nX])
						If aScan(aAuxGd, {|x| AllTrim(x[3]) == AllTrim(aItens[nX,nY,1])}) > 0
							If oModel:nOperation == MODEL_OPERATION_INSERT .Or. (oModel:nOperation == MODEL_OPERATION_UPDATE .And. AllTrim(aItens[nX][nY][1]) <> "CT_SEQUEN")
								If !oModelGd:SetValue(aItens[nX,nY,1], aItens[nX,nY,2])
									lRet := .F.
									cResp := "Não foi possível atribuir o valor " + AllToChar(aItens[nX,nY,2]) + " ao campo " + aItens[nX,nY,1] + "."
									Exit
								EndIf
							EndIf	
						Endif
					Next nY

					If lRet .And. Len(aItens) > 0
						If oModelGd:IsModified()
							If !oModelGd:VldLineData(.F.)
								lRet := .F.
								aMsgErro := oModel:GetErrorMessage()				
								cResp := "Mensagem do erro: " 			+ StrTran( StrTran( AllToChar(aMsgErro[6]), "<", "" ), "-", "" ) + (" ")
								cResp += "Mensagem da solução: " 		+ StrTran( StrTran( AllToChar(aMsgErro[7]), "<", "" ), "-", "" ) + (" ")
								cResp += "Valor atribuído: " 			+ StrTran( StrTran( AllToChar(aMsgErro[8]), "<", "" ), "-", "" ) + (" ")
								cResp += "Valor anterior: " 			+ StrTran( StrTran( AllToChar(aMsgErro[9]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do formulário de origem: " + StrTran( StrTran( AllToChar(aMsgErro[1]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do campo de origem: " 		+ StrTran( StrTran( AllToChar(aMsgErro[2]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do formulário de erro: " 	+ StrTran( StrTran( AllToChar(aMsgErro[3]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do campo de erro: " 		+ StrTran( StrTran( AllToChar(aMsgErro[4]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do erro: " 				+ StrTran( StrTran( AllToChar(aMsgErro[5]), "<", "" ), "-", "" ) + (" ")
								Exit
							Elseif !oModelGd:IsInserted(oModelGd:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
								oModelGd:SetLineModify(oModelGd:GetLine())
							Endif
						Elseif !oModelGd:IsInserted(oModelGd:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
							oModelGd:SetLineModify(oModelGd:GetLine())
						Endif
					Else
						Exit
					Endif				
				Next nX
			Endif

			If oModel:nOperation == MODEL_OPERATION_UPDATE .AND. lRet
				aModif := oModelGd:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
				If Len(aModif) > 0
					For nY := 1 To oModelGd:Length()
						If !aScan(aModif, {|x| x == nY})
							oModelGd:GoLine(nY)
							oModelGd:DeleteLine()
						Endif
					Next nY
				Elseif Len(aItens) == 0
					oModelGd:DelAllLine()
				Endif
			Endif
		Endif

		If lRet
			If oModel:VldData()
				oModel:CommitData()				
			Else
				lRet:= .F.
				aMsgErro	:= oModel:GetErrorMessage()				
				cResp := "Mensagem do erro: " 			+ StrTran( StrTran( AllToChar(aMsgErro[6]), "<", "" ), "-", "" ) + (" ")
				cResp += "Mensagem da solução: " 		+ StrTran( StrTran( AllToChar(aMsgErro[7]), "<", "" ), "-", "" ) + (" ")
				cResp += "Valor atribuído: " 			+ StrTran( StrTran( AllToChar(aMsgErro[8]), "<", "" ), "-", "" ) + (" ")
				cResp += "Valor anterior: " 			+ StrTran( StrTran( AllToChar(aMsgErro[9]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do formulário de origem: " + StrTran( StrTran( AllToChar(aMsgErro[1]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do campo de origem: " 		+ StrTran( StrTran( AllToChar(aMsgErro[2]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do formulário de erro: " 	+ StrTran( StrTran( AllToChar(aMsgErro[3]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do campo de erro: " 		+ StrTran( StrTran( AllToChar(aMsgErro[4]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do erro: " 				+ StrTran( StrTran( AllToChar(aMsgErro[5]), "<", "" ), "-", "" ) + (" ")
			EndIf
		Endif
	Endif

	If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Meta de Venda!.", cResp,/*cHelpUrl*/,/*aDetails*/)
	Else
		If oModel:nOperation == MODEL_OPERATION_INSERT	
			If !SCT->(DbSeek(xFilial("SCT") + oModelFld:GetValue("CT_DOC")))
				oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Meta de Venda!.", cResp,/*cHelpUrl*/,/*aDetails*/)
				lRet := .F.
			Endif
		Endif
    EndIf

	aSize(aCabec,0)
	aSize(aItens,0)
	aSize(aFronze,0)
	aSize(aModif,0)
	aSize(aMsgErro,0)
	aSize(aAuxFld,0)
	aSize(aAuxGd,0)
	FreeObj(oModelGd)
	FreeObj(oModelFld)
	FreeObj(oModel)

Return lRet

/*/{Protheus.doc} ManutItem
Realiza a manutenção (inclusão/alteração/exclusão) da Meta de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do apontamento
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

Static Function ManutItem(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)

	Local aAux		:= {}
	Local aFronze	:= {"CT_SEQUEN"}
	Local aItens	:= {}
	Local aMsgErro	:= {}
	Local cItem		:= ""
	Local cResp		:= ""
	Local lRet		:= .T.
	Local oModel	:= Nil
	Local oModelFld	:= Nil
	Local oModelGd	:= Nil
	Local nI		:= 0
	Local nPosItem	:= 0

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	oModel := FwLoadModel( "FATA050" )
    oModel:SetOperation( MODEL_OPERATION_UPDATE )
    oModel:Activate()

	If oModel:IsActive()
		oModelFld	:= oModel:GetModel("SCTCAB")
		oModelGd	:= oModel:GetModel("SCTGRID")
		aAux := oModelGd:GetStruct():GetFields()

		If nOpcx <> 5
			If nOpcx == 3
				cItem := fSeqItem(oModelGd)
				oModelGd:AddLine()
				oModelGd:SetValue("CT_SEQUEN",cItem)
			Elseif nOpcx == 4
				If !oModelGd:SeekLine({{"CT_SEQUEN",cChave}})
					lRet := .F.
					cResp := "Item nao localizado!"
				Else
					cItem := cChave
				Endif
			Endif

			aJson := oApiManager:ToArray(cBody)

			If lRet .And. Len(aJson[1][1]) > 0
				oApiManager:ToExecAuto(1, aJson[1][1][1][2], aItens)
				aItens := FWVetByDic(aItens,"SCT",.F.)
			EndIf
			
			If lRet
				For nI := 1 To Len(aItens)
					If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aItens[nI,1])}) > 0
						If aScan(aFronze, aItens[nI,1]) == 0
							If !oModelGd:SetValue(aItens[nI,1], aItens[nI,2])
								lRet := .F.
								cResp := "Nao foi possível atribuir o valor " + AllToChar(aItens[nI,2]) + " ao campo " + aItens[nI,1] + "."
								Exit
							EndIf
						Endif
					Endif
				Next nI
			Endif
		Else
			If oModelGd:SeekLine({{"CT_SEQUEN",cChave}})
				oModelGd:DeleteLine()
			Else
				lRet := .F.
				cResp := "Item nao localizado!"
			Endif
		Endif

		If lRet
			If oModel:VldData()
				oModel:CommitData()				
			Else
				lRet:= .F.
				aMsgErro	:= oModel:GetErrorMessage()				
				cResp := "Mensagem do erro: " 			+ StrTran( StrTran( AllToChar(aMsgErro[6]), "<", "" ), "-", "" ) + (" ")
				cResp += "Mensagem da solução: " 		+ StrTran( StrTran( AllToChar(aMsgErro[7]), "<", "" ), "-", "" ) + (" ")
				cResp += "Valor atribuído: " 			+ StrTran( StrTran( AllToChar(aMsgErro[8]), "<", "" ), "-", "" ) + (" ")
				cResp += "Valor anterior: " 			+ StrTran( StrTran( AllToChar(aMsgErro[9]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do formulário de origem: " + StrTran( StrTran( AllToChar(aMsgErro[1]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do campo de origem: " 		+ StrTran( StrTran( AllToChar(aMsgErro[2]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do formulário de erro: " 	+ StrTran( StrTran( AllToChar(aMsgErro[3]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do campo de erro: " 		+ StrTran( StrTran( AllToChar(aMsgErro[4]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do erro: " 				+ StrTran( StrTran( AllToChar(aMsgErro[5]), "<", "" ), "-", "" ) + (" ")
			EndIf
		Endif

	Else
		lRet := .F.
		cResp := "Nao foi possivel Incluir/Alterar/Excluir item da Meta de Venda."
	Endif

	If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Meta de Venda!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	FreeObj(oModelGd)
	FreeObj(oModelFld)
	FreeObj(oModel)
	aSize(aMsgErro,0)
	aSize(aItens,0)	
	aSize(aFronze,0)
	aSize(aAux,0)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"SCT", "ListOfsalestargets"      , "ListOfsalestargets"  	}
    Local aFatherSCT	:=	{"SCT", "items"                , "items"           		}        
    Local aRelation     :=  {}
	Local cIndexKey		:=  "CT_FILIAL, CT_DOC, CT_SEQUEN"

    aAdd(aRelation,{"CT_FILIAL"	,"CT_FILIAL"   	})
    aAdd(aRelation,{"CT_DOC"  	,"CT_DOC"   	})

	oApiManager:SetApiRelation(aChildren, aFatherSCT, aRelation, cIndexKey)
    oApiManager:SetApiMap(ApiMap())

Return Nil

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/
Static Function ApiMap()

	Local apiMap		:= {}
	Local aStrSCTPai    := {}
	Local aStructGrid   := {}
	Local aStructAlias  := {}

	aStrSCTPai    :=	{"SCT","Field","items","items",;
							{;
								{"CompanyId"							, "Exp:cEmpAnt"									},;
								{"InternalId"							, "Exp:cFilAnt, CT_DOC"							},;							
								{"BranchID"								, "Exp:cFilAnt"									},;
								{"CompanyInternalId"					, "Exp:cEmpAnt, Exp:cFilAnt, UO_CODCAMP"		},;
								{"Code"		                            , "CT_DOC"										},;
								{"SalesTargetDescription"               , "CT_DESCRI" 									};
							};
						}
	aStructGrid :=      { "SCT", "ITEM", "ListOfsalestargets", "ListOfsalestargets",;
							{;
								{"InternalId"     						, "Exp:cFilAnt, CT_DOC	, CT_SEQUEN"			},;
								{"SalesTargetItem"     					, "CT_SEQUEN"									},;
								{"BillingDate"     						, "CT_DATA"										},;
								{"SellerCode"     						, "CT_VEND"										},;
								{"RegionCode"     						, "CT_REGIAO"									},;
								{"CategoryCode"    						, "CT_CATEGO"									},;
								{"ProductType"     						, "CT_TIPO"										},;
								{"Quantity"		     					, "CT_QUANT"									},;
								{"Price"		     					, "CT_VALOR"									},;
								{"Currency"		     					, "CT_MOEDA"									},;
								{"BlockedRecord"     					, "CT_MSBLQL"									};
							};
						}

	aStructAlias  := {aStrSCTPai,aStructGrid} 

	apiMap := {"crms480","items","1.000","CRMA480",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} ApiMapItem
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/
Static Function ApiMapItem()

	Local ApiMapItem	:= {}
	Local aStructGrid   := {}
	Local aStructAlias  := {}

	aStructGrid :=      { "SCT","Field","items","items",;
							{;
								{"InternalId"     						, "Exp:cFilAnt, CT_DOC	, CT_SEQUEN"			},;
								{"SalesTargetItem"     					, "CT_SEQUEN"									},;
								{"BillingDate"     						, "CT_DATA"										},;
								{"SellerCode"     						, "CT_VEND"										},;
								{"RegionCode"     						, "CT_REGIAO"									},;
								{"CategoryCode"    						, "CT_CATEGO"									},;
								{"ProductType"     						, "CT_TIPO"										},;
								{"Quantity"		     					, "CT_QUANT"									},;
								{"Price"		     					, "CT_VALOR"									},;
								{"Currency"		     					, "CT_MOEDA"									},;
								{"BlockedRecord"     					, "CT_MSBLQL"									};
							};
						}

	aStructAlias  := {aStructGrid}

	ApiMapItem := {"crms480","items","1.000","CRMA480",aStructAlias,"ListOfsalestargets"} 

Return ApiMapItem

/*/{Protheus.doc} MntQuery
Monta Query Pai

@return aQuery	 		, Array 	, Retorna um array de uma dimenssão com duas posições (Query,Order).
@author	Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/

Static Function MntQuery()

    Local aRet      := {}
    Local cGroup    := ""
    Local cQuery    := ""

    cQuery += " SELECT items.CT_FILIAL, items.CT_DOC "   
    cQuery += " FROM "+RetSqlName("SCT")+ " items "
    cQuery += " INNER JOIN "+RetSqlName("SCT")+ " ListOfsalestargets "
    cQuery += " ON items.CT_FILIAL = ListOfsalestargets.CT_FILIAL "
	cQuery += " AND items.CT_DOC = ListOfsalestargets.CT_DOC "
	cQuery += " AND items.CT_SEQUEN = ListOfsalestargets.CT_SEQUEN "
	cQuery += " AND items.D_E_L_E_T_ = ListOfsalestargets.D_E_L_E_T_ "

    cGroup += " items.CT_FILIAL, "
    cGroup += " items.CT_DOC "

    aAdd(aRet, cQuery)
    aAdd(aRet, cGroup)    

Return aRet

/*/{Protheus.doc} fSeqItem
Retorno o codigo do proximo item.
@param oModel   , Objeto , Modelo de dados do Item (Produtos)

@author     Squad Faturamento/CRM
@since      13/12/2018
@version    12.1.21
/*/
Static Function fSeqItem(oModel)

	Local cRet		:= "00"
	Local nI		:= oModel:Length()
	Local nPosItem	:= aScan(oModel:aHeader,{|x|AllTrim(x[2]) == "CT_SEQUEN"})

	cRet := oModel:GetValueByPos(nPosItem,nI)
	cRet := Soma1(cRet)

Return cRet