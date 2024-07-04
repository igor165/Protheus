#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
//dummy function
Function FATS600()

Return

/*/{Protheus.doc} commercialproposal
API de integração de Cadastro de Proposta Comercial
Definido nome da classe "opportunities" devido EndPoint 
utilizar oportunidade de Vendda

@author		Squad Faturamento/CRM
@since		14/11/2018
@version	12.1.21
/*/

WSRESTFUL opportunities DESCRIPTION "Cadastro de Proposta Comercial" 

	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA InternalId       AS STRING	OPTIONAL
	WSDATA OpportunityId    AS STRING	OPTIONAL
	WSDATA ItemId           AS STRING	OPTIONAL
    //---------------------------------------------------------------------
    WSMETHOD GET Main ;
    DESCRIPTION "Lista todas Proposta Comercial" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal"
	//---------------------------------------------------------------------
    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra uma nova Proposta Comercial" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal"
    //---------------------------------------------------------------------
    WSMETHOD GET Code ;
    DESCRIPTION "Lista uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}"
	//---------------------------------------------------------------------
    WSMETHOD PUT Code ;
    DESCRIPTION "Altera uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}"
	//---------------------------------------------------------------------
    WSMETHOD DELETE Code ;
    DESCRIPTION "Exclui uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}"
    //---------------------------------------------------------------------
    WSMETHOD GET ListofProducts ;
    DESCRIPTION "Lista uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts"
    //---------------------------------------------------------------------
    WSMETHOD POST ListofProducts ;
    DESCRIPTION "Cadastra uma nova Proposta Comercial" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts{Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts"
     //---------------------------------------------------------------------
    WSMETHOD GET ItemId ;
    DESCRIPTION "Lista uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{ItemId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{ItemId}"
	//---------------------------------------------------------------------
    WSMETHOD PUT ItemId ;
    DESCRIPTION "Altera uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{ItemId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{ItemId}"
	//---------------------------------------------------------------------
    WSMETHOD DELETE ItemId ;
    DESCRIPTION "Exclui uma Proposta Comercial Especifica" ;
    WSSYNTAX "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{ItemId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunities/{OpportunityId}/commercialproposal/{InternalId}/listofproducts/{ItemId}"

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

WSMETHOD GET Main PATHPARAM OpportunityId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
    Local aFilter           := {}

    Default OpportunityId   := ""

	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("fats600","1.000")
	oApiManager:SetApiMap(ApiMap())
	DefRelation(@oApiManager)
    
    ADY->(dbSetOrder(2))// "ADY_FILIAL+ADY_OPORTU+ADY_REVISA+ADY_PROPOS"
    If ADY->(dbSeek(self:OpportunityId))
		aAdd(aFilter, {"ADY", "items",{"ADY_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
		aAdd(aFilter, {"ADY", "items",{"ADY_OPORTU	    = '" + ADY->ADY_OPORTU 	+  "'"}})
        aAdd(aFilter, {"ADY", "items",{"ADY_REVISA	    = '" + ADY->ADY_REVISA 	+  "'"}})		
		oApiManager:SetApiFilter(aFilter)
        lRet := ApiMainGet(@oApiManager, Self:aQueryString, , , , , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), .T.)

        If lRet
            Self:SetResponse( oApiManager:GetJsonSerialize() )
        Else
            cError := oApiManager:GetJsonError()	
            SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
        EndIf
    Else 
	    lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar Oportunidade de Venda!", "Oportunidade de venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
        cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	Endif
	oApiManager:Destroy()
	aSize(aFilter,0)
    FreeObj(oApiManager)
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} POST /commercialproposal/crm/{OpportunityId}/commercialproposal
Inclui proposta comercial

@param	Fields	, caracter, Campos que serao retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		27/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------

WSMETHOD POST Main PATHPARAM OpportunityId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("FATS600","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"ADY","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet 
		AD1->(DbSetOrder(1))
		If AD1->(DbSeek(Self:OpportunityId))
			If !(AD1->AD1_STATUS $ "2#9")// Propos ganha / Propos Perdida				
				lRet := ManutADY(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
				If lRet
					aAdd(aFilter, {"ADY", "items",{"ADY_FILIAL = '" + ADY->ADY_FILIAL + "'"}})
					aAdd(aFilter, {"ADY", "items",{"ADY_PROPOS = '" + ADY->ADY_PROPOS + "'"}})
					aAdd(aFilter, {"ADY", "items",{"ADY_REVISA = '" + ADY->ADY_REVISA + "'"}})

					oApiManager:SetApiFilter(aFilter)            
					lRet    := GetMain(oApiManager, Self:aQueryString)
				Endif
			Else
				lRet := .F.
                oApiManager:SetJsonError("400","Erro ao Listar Oportunidade + Proposta Comercial!", "O Status da Oportunidade nao permite inclusao de nova proposta comercial.",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			lRet := .F.
            oApiManager:SetJsonError("404","Erro ao Incluir Proposta Comercial!", "A chave informada nao foi encontrada.",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		oApiManager:SetJsonError("400","Erro ao Incluir Proposta Comercial!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

WSMETHOD GET Code PATHPARAM OpportunityId, InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
    Local aFilter           := {}

    Default OpportunityId   := ""

	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("FATS600","1.000")
	oApiManager:SetApiMap(ApiMap())
	DefRelation(@oApiManager)

	AD1->(DbSetOrder(1))
	If AD1->(DbSeek(Self:OpportunityId))			
		ADY->(DbSetOrder(1))
		If ADY->(DbSeek(Self:InternalId))
			aAdd(aFilter, {"ADY", "items",{"ADY_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
			aAdd(aFilter, {"ADY", "items",{"ADY_OPORTU	    = '" + ADY->ADY_OPORTU 	+  "'"}})
			aAdd(aFilter, {"ADY", "items",{"ADY_REVISA	    = '" + ADY->ADY_REVISA 	+  "'"}})
			aAdd(aFilter, {"ADY", "items",{"ADY_PROPOS	    = '" + ADY->ADY_PROPOS 	+  "'"}})
	
			oApiManager:SetApiFilter(aFilter)
			lRet := ApiMainGet(@oApiManager, Self:aQueryString, , , , , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), .T.)
			
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)
    FreeObj(oApiManager)
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} PUT /selleractivity/crm/selleractivity/{InternalId}
Altera uma proposta comercial

@param	Code		        , caracter, Código do Documento
@param	Fields				, caracter, Campos que serao retornados na requisiçao.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD PUT Code PATHPARAM OpportunityId, InternalId WSRECEIVE Fields WSSERVICE opportunities
	
	Local aFilter		:= {}
	Local aJson			:= {}	
	Local cError		:= ""
	Local cBody 	   	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("FATS600","1.000")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"ADY","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)
	If lRet
		AD1->(DbSetOrder(1))
		If AD1->(DbSeek(Self:OpportunityId))
			If !(AD1->AD1_STATUS $ "2#9")
				ADY->(DbSetOrder(1))
				If ADY->(DbSeek(Self:InternalId))
					lRet := ManutADY(oApiManager, Self:aQueryString, 4, aJson,Self:InternalId, oJson, cBody)
					If lRet
						aAdd(aFilter, {"ADY", "items",{"ADY_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
						aAdd(aFilter, {"ADY", "items",{"ADY_OPORTU	    = '" + ADY->ADY_OPORTU 	+  "'"}})
						aAdd(aFilter, {"ADY", "items",{"ADY_REVISA	    = '" + ADY->ADY_REVISA 	+  "'"}})
						aAdd(aFilter, {"ADY", "items",{"ADY_PROPOS	    = '" + ADY->ADY_PROPOS 	+  "'"}})
						
						oApiManager:SetApiFilter(aFilter)
						lRet := ApiMainGet(@oApiManager, Self:aQueryString, , , , , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), .T.)
					Endif
				Else
					lRet := .F.
					oApiManager:SetJsonError("404","Erro ao alterar Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
				Endif
			Else
				oApiManager:SetJsonError("400","Nao foi possivel alterar Proposta Comercial!", "O Status da Oportunidade nao permite a alteracao de uma proposta comercial.",/*cHelpUrl*/,/*aDetails*/)
				lRet := .F.
			Endif
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao alterar Proposta Comercial!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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
//--------------------------------------------------------------------
/*/{Protheus.doc} DELETE /selleractivity/crm/selleractivity/{InternalId}
Deleta uma Atividade específica

@param	Code		        , caracter, Código do Documento
@param	Fields				, caracter, Campos que serao retornados na requisiçao.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD DELETE Code PATHPARAM OpportunityId, InternalId WSRECEIVE Fields WSSERVICE opportunities

	Local aJson			:= {}	
	Local cError		:= ""
	Local cResp			:= "Registro Excluido com Sucesso"	
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("FATS600","1.000")
	Local oJsonPositions:= JsonObject():New()

	AD1->(DbSetOrder(1))
	If AD1->(DbSeek(Self:OpportunityId))
		If !(AD1->AD1_STATUS $ "2#9")
			ADY->(DbSetOrder(1))
			If ADY->(DbSeek(Self:InternalId))
				lRet := ManutADY(oApiManager, Self:aQueryString, 5, aJson)
			Else
				lRet := .F.
				oApiManager:SetJsonError("404","Erro ao excluir Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			oApiManager:SetJsonError("400","Nao foi possivel excluir Proposta Comercial!", "O Status da Oportunidade nao permite a exclusao de uma proposta comercial.",/*cHelpUrl*/,/*aDetails*/)
			lRet := .F.
		Endif
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao excluir Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
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
WSMETHOD GET ListofProducts PATHPARAM OpportunityId, InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil

    Default OpportunityId   := ""
	Default InternalId		:= ""

	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("FATS600","1.000")

	AD1->(DbSetOrder(1))
	If AD1->(DbSeek(Self:OpportunityId))			
		ADY->(DbSetOrder(1))
		If ADY->(DbSeek(Self:InternalId))

			If AD1->AD1_NROPOR == ADY->ADY_OPORTU

				aAdd(aFilter, {"ADZ", "items",{"ADZ_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
				aAdd(aFilter, {"ADZ", "items",{"ADZ_PROPOS	    = '" + ADY->ADY_PROPOS 	+  "'"}})
				aAdd(aFilter, {"ADZ", "items",{"ADZ_REVISA	    = '" + ADY->ADY_PREVIS 	+  "'"}})
				aAdd(aFilter, {"ADZ", "items",{"ADZ_FOLDER	    = '1'"}})
				
				oApiManager:SetApiFilter(aFilter)
				lRet := GetItem(@oApiManager, Self:aQueryString)
			Else
				oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
	Endif
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)
    FreeObj(oApiManager)

Return lRet

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
WSMETHOD POST ListofProducts PATHPARAM OpportunityId, InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local aFilter       := {}
    Local aJson         := {}    
	Local cBody 	  	:= Self:GetContent()
    Local cError		:= ""
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("FATS600","1.000")
	Local oJson			:= THashMap():New()

    Default OpportunityId   := ""
	Default InternalId		:= ""

	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)
		
	If lRet
		AD1->(DbSetOrder(1))
		If AD1->(DbSeek(Self:OpportunityId))			
			ADY->(DbSetOrder(1))
			If ADY->(DbSeek(Self:InternalId))
				If AD1->AD1_NROPOR == ADY->ADY_OPORTU					
					lRet := ManutItem(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
					If lRet
						aAdd(aFilter, {"ADZ", "items",{"ADZ_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
						aAdd(aFilter, {"ADZ", "items",{"ADZ_PROPOS	    = '" + ADY->ADY_PROPOS 	+  "'"}})
						aAdd(aFilter, {"ADZ", "items",{"ADZ_REVISA	    = '" + ADY->ADY_PREVIS 	+  "'"}})
						aAdd(aFilter, {"ADZ", "items",{"ADZ_FOLDER	    = '1'"}})
						
						oApiManager:SetApiFilter(aFilter)
						lRet := GetItem(@oApiManager, Self:aQueryString)
					Endif
				Else
					oApiManager:SetJsonError("404","Erro ao Incluir item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
				Endif
			Else
				lRet := .F.
				oApiManager:SetJsonError("404","Erro ao Incluir item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao Incluir item da Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		oApiManager:SetJsonError("400","Erro ao Incluir item da Proposta Comercial!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
	Endif
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
    aSize(aFilter,0)
    FreeObj( oJson )
Return lRet

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

WSMETHOD GET ItemId PATHPARAM OpportunityId, InternalId, ItemId WSRECEIVE  Fields WSSERVICE opportunities
	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil

    Default OpportunityId   := ""
	Default InternalId		:= ""

	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("FATS600","1.000")

	AD1->(DbSetOrder(1))
	If AD1->(DbSeek(Self:OpportunityId))			
		ADY->(DbSetOrder(1))
		If ADY->(DbSeek(Self:InternalId))
			If AD1->AD1_NROPOR == ADY->ADY_OPORTU
				ADZ->(DbSetOrder(1))
				If ADZ->(DbSeek(Self:InternalId + Self:ItemId))
				
					aAdd(aFilter, {"ADZ", "items",{"ADZ_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
					aAdd(aFilter, {"ADZ", "items",{"ADZ_PROPOS	    = '" + ADY->ADY_PROPOS 	+  "'"}})
					aAdd(aFilter, {"ADZ", "items",{"ADZ_REVISA	    = '" + ADY->ADY_PREVIS 	+  "'"}})
					aAdd(aFilter, {"ADZ", "items",{"ADZ_FOLDER	    = '1'"}})
					aAdd(aFilter, {"ADZ", "items",{"ADZ_ITEM	    = '" + ADZ->ADZ_ITEM 	+  "'"}})
					
					oApiManager:SetApiFilter(aFilter)
					lRet := GetItem(@oApiManager, Self:aQueryString)
				Else
					lRet := .F.
					oApiManager:SetJsonError("404","Erro ao listar Item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
				Endif
			Else 
				lRet := .F.
				oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao listar Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf	

	oApiManager:Destroy()
	aSize(aFilter,0)
    FreeObj(oApiManager)
Return lRet

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
WSMETHOD PUT ItemId PATHPARAM OpportunityId, InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local aFilter       := {}
    Local aJson         := {}    
	Local cBody 	  	:= Self:GetContent()
    Local cError		:= ""
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("FATS600","1.000")
	Local oJson			:= THashMap():New()

    Default OpportunityId   := ""
	Default InternalId		:= ""

	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)
		
	If lRet
		AD1->(DbSetOrder(1))
		If AD1->(DbSeek(Self:OpportunityId))			
			ADY->(DbSetOrder(1))
			If ADY->(DbSeek(Self:InternalId))
				If AD1->AD1_NROPOR == ADY->ADY_OPORTU
					ADZ->(DbSetOrder(1))
					If ADZ->(DbSeek(Self:InternalId + Self:ItemId))				
						lRet := ManutItem(oApiManager, Self:aQueryString, 4, aJson, Self:ItemId, oJson, cBody)
						If lRet
							aAdd(aFilter, {"ADZ", "items",{"ADZ_FILIAL      = '" + ADY->ADY_FILIAL  +  "'"}})
							aAdd(aFilter, {"ADZ", "items",{"ADZ_PROPOS	    = '" + ADY->ADY_PROPOS 	+  "'"}})
							aAdd(aFilter, {"ADZ", "items",{"ADZ_REVISA	    = '" + ADY->ADY_PREVIS 	+  "'"}})
							aAdd(aFilter, {"ADZ", "items",{"ADZ_ITEM	    = '" + Self:ItemId		+  "'"}})
							aAdd(aFilter, {"ADZ", "items",{"ADZ_FOLDER	    = '1'"}})
							
							oApiManager:SetApiFilter(aFilter)
							lRet := GetItem(@oApiManager, Self:aQueryString)
						Endif
					Else
						lRet := .F.
						oApiManager:SetJsonError("404","Erro ao alterar Item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
					Endif
				Else
					oApiManager:SetJsonError("404","Erro ao alterar item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
				Endif
			Else
				lRet := .F.
				oApiManager:SetJsonError("404","Erro ao alterar item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar item da Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		oApiManager:SetJsonError("400","Erro ao alterar item da Proposta Comercial!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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
WSMETHOD DELETE ItemId PATHPARAM OpportunityId, InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunities

	Local cError		:= ""
    Local cResp			:= "Registro Excluido com Sucesso"
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS040","1.000")
	Local oJson			:= THashMap():New()
    Local oJsonPositions:= JsonObject():New()

    Default OpportunityId   := ""
	Default InternalId		:= ""

	Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:Activate()		
	
	AD1->(DbSetOrder(1))
	If AD1->(DbSeek(Self:OpportunityId))			
		ADY->(DbSetOrder(1))
		If ADY->(DbSeek(Self:InternalId))
			If AD1->AD1_NROPOR == ADY->ADY_OPORTU
				ADZ->(DbSetOrder(1))
				If ADZ->(DbSeek(Self:InternalId + Self:ItemId))				
					lRet := ManutItem(oApiManager, Self:aQueryString, 5, , Self:ItemId)
				Else
					lRet := .F.
					oApiManager:SetJsonError("404","Erro ao excluir Item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
				Endif
			Else
				lRet := .F.
				oApiManager:SetJsonError("404","Erro ao excluir item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
			Endif
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao excluir item da Proposta Comercial!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao excluir item da Proposta Comercial!", "Oportunidade de Venda não encontrada",/*cHelpUrl*/,/*aDetails*/)
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
    FreeObj( oJson )

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto FWAPIManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"ADZ", "ListofProducts"      , "ListofProducts"  	}
    Local aFatherADY	:=	{"ADY", "items"                , "items"           		}        
    Local aRelation     :=  {}
	Local cIndexKey		:=  "ADZ_FILIAL, ADZ_PROPOS"

    aAdd(aRelation,{"ADY_FILIAL"	,"ADZ_FILIAL"   	})
    aAdd(aRelation,{"ADY_PROPOS"  	,"ADZ_PROPOS"   	})
    aAdd(aRelation,{"ADY_PREVIS"  	,"ADZ_REVISA"   	})

	oApiManager:SetApiRelation(aChildren, aFatherADY, aRelation, cIndexKey)    

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
	Local aStrADYPai    := {}
	Local aStructGrid   := {}
	Local aStructAlias  := {}

	aStrADYPai    :=	{"ADY","Field","items","items",;
							{;
								{"CompanyId"							, "Exp:cEmpAnt"									},;
								{"InternalId"							, "Exp:cFilAnt, ADY_PROPOS"						},;							
								{"BranchID"								, "Exp:cFilAnt"									},;
								{"CompanyInternalId"					, "Exp:cEmpAnt, Exp:cFilAnt, ADY_PROPOS"		},;
								{"ProposalNumber"		                , "ADY_PROPOS"									},;
								{"ProposalReview"		                , "ADY_PREVIS"									},;
								{"OpportunityId"		                , "ADY_OPORTU"									},;
								{"OpportunityReview"		            , "ADY_REVISA"									},;
								{"OpportunityDescription"		        , "ADY_DESOPO"									},;
								{"EntityType"		                    , "ADY_ENTIDA"									},;
								{"EntityCode"		                    , "ADY_CODIGO"									},;
								{"EntityUnit"		                    , "ADY_LOJA"									},;
								{"EntityDescription"		            , "ADY_DESENT"									},;
								{"SellerId"		                        , "ADY_VEND"									},;
								{"RegisterDate"		                    , "ADY_DTREVI"									},;
								{"PriceListId"		                    , "ADY_TABELA"									},;
								{"DiscountPercentage"		            , "ADY_DESCON"									},;
								{"SynchronizeProposal"		            , "ADY_SINCPR"									},;
								{"RegisterSituation"                    , "ADY_MSBLQL" 									};
							};
						}
	aStructGrid :=      { "ADZ", "ITEM", "ListofProducts", "ListofProducts",;
							{;
								{"InternalId"     						, "Exp:cFilAnt, ADZ_PROPOS	, ADZ_ITEM"			},;
								{"BranchId"          					, "Exp:cFilAnt"									},;
								{"ItemId"     						    , "ADZ_ITEM"									},;
								{"ProductId"     						, "ADZ_PRODUT"								   	},;
								{"ProductDescription"          			, "ADZ_DESCRI"									},;
								{"UnitOfMeasurement"   					, "ADZ_UM"									    },;
								{"Currency"     						, "ADZ_MOEDA"									},;
								{"PaymentModeId"		    			, "ADZ_CONDPG"									},;
								{"TypeOut"		     					, "ADZ_TES"									    },;
								{"Quantity"		     					, "ADZ_QTDVEN"									},;
								{"UnitPrice"		     	    		, "ADZ_PRCVEN"									},;
								{"UnitPriceList"		     			, "ADZ_PRCTAB"									},;
								{"TotalValue"		     				, "ADZ_TOTAL"									},;
								{"ItemDiscountPercentage"		    	, "ADZ_DESCON"									},;
								{"ItemDiscountValue"		     		, "ADZ_VALDES"									};
							};
						}

	aStructAlias  := {aStrADYPai,aStructGrid} 

	apiMap := {"fats600","items","1.000","FATS600",aStructAlias,"items"}

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

	aStructGrid :=      { "ADZ","field","items","items",;
							{;
								{"InternalId"     						, "Exp:cFilAnt, ADZ_PROPOS	, ADZ_ITEM"			},;
								{"BranchId"          					, "Exp:cFilAnt"									},;
								{"ItemId"     						    , "ADZ_ITEM"									},;
								{"ProductId"     						, "ADZ_PRODUT"								   	},;
								{"ProductDescription"          			, "ADZ_DESCRI"									},;
								{"UnitOfMeasurement"   					, "ADZ_UM"									    },;
								{"Currency"     						, "ADZ_MOEDA"									},;
								{"PaymentModeId"		    			, "ADZ_CONDPG"									},;
								{"TypeOut"		     					, "ADZ_TES"									    },;
								{"Quantity"		     					, "ADZ_QTDVEN"									},;
								{"UnitPrice"		     	    		, "ADZ_PRCVEN"									},;
								{"UnitPriceList"		     			, "ADZ_PRCTAB"									},;
								{"TotalValue"		     				, "ADZ_TOTAL"									},;
								{"ItemDiscountPercentage"		    	, "ADZ_DESCON"									},;
								{"ItemDiscountValue"		     		, "ADZ_VALDES"									};
							};
						}

	aStructAlias  := {aStructGrid}

	ApiMapItem := {"fats600","items","1.000","FATA600",aStructAlias,"ListofProducts"} 

Return ApiMapItem

/*/{Protheus.doc} GetMain
Realiza o Get da tabela ADY

@param oApiManager	, Objeto	, Objeto FWAPIManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, lHasNext)

	Local aFatherAlias		:= {"ADY", "items","items"}
	Local aChildrenAlias    := {"ADZ", "ListofProducts", "ListofProducts" }
	Local cIndexKey		    :=  "ADZ_FILIAL, ADZ_PROPOS"
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
/*/{Protheus.doc} GetItem
Realiza o Get dos Items

@param oApiManager	, Objeto	, Objeto FWAPIManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		28/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetItem(oApiManager, aQueryString, lHasNext)

	Local aFatherAlias		:= {"ADZ","items"           ,"items"            }
    Local lRet 				:= .T.
    Local cIndexKey		    := " ADZ_FILIAL, ADZ_PROPOS, ADZ_REVISA, ADZ_FOLDER, ADZ_ITEM "

	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.
	
	oApiManager:SetApiMap(ApiMapItem())
	oApiManager:SetApiAlias(aFatherAlias)

	lRet := ApiMainGet(@oApiManager, aQueryString, , , aFatherAlias, cIndexKey , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)    

Return lRet

/*/{Protheus.doc} ManutPropos
Realiza a manutenção (inclusão/alteração/exclusão) da Proposta Comercial

@param oApiManager	, Objeto	, Objeto FWAPIManager inicializado no método 
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
Static Function ManutADY(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)
	
	Local aAux			:= {}
	Local aADYMaster	:= {}
	Local aADZProdut	:= {}
	Local aFronze		:= {"ADY_FILIAL","ADY_PROPOS","ADY_PREVIS","ADY_OPORTU","ADY_ENTIDA","ADY_CODIGO","ADY_LOJA","ADY_VEND","ADY_REVISA","ADZ_FILIAL","ADZ_ITEM","ADZ_DESCRI","ADZ_UM","ADZ_TOTAL"}
	Local aMsgErro		:= {}
	Local cResp			:= ""
	Local cItem			:= "00"
	Local lRet			:= .T.
    Local oMdlOpor  	:= Nil
    Local oMdlADY   	:= Nil
    Local oMdlADZ   	:= Nil
    Local oMdlProp  	:= Nil
	Local nX			:= 0
	Local nY			:= 0
	Local nPosItem		:= 0

	Private INCLUI		:= .T.

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	oMdlOpor := FwLoadModel( "FATA300" )
    oMdlOpor:SetOperation( MODEL_OPERATION_UPDATE )
    oMdlOpor:Activate()

	If oMdlOpor:IsActive()
		oMdlProp := FwLoadModel( "FATA600" )
		DefRelation(@oApiManager)

		If nOpcx == MODEL_OPERATION_INSERT
			INCLUI := .T.
		Else
			INCLUI := .F.
		Endif

		If nOpcx <> MODEL_OPERATION_DELETE

			aJson := oApiManager:ToArray(cBody)

			If Len(aJson[1][1]) > 0
				oApiManager:ToExecAuto(1, aJson[1][1][1][2], aADYMaster)
			EndIf

			If Len(aJson[1][2]) > 0
				For nX := 1 To Len(aJson[1][2])
					oApiManager:ToExecAuto(2, aJson[1][2][nX][1][2], aADZProdut)
				Next nX
			EndIf
			OrdExec(@aADZProdut)
			If nOpcx == MODEL_OPERATION_INSERT
				oMdlProp:SetOperation(MODEL_OPERATION_INSERT)
			Elseif nOpcx == MODEL_OPERATION_UPDATE
				oMdlProp:SetOperation(MODEL_OPERATION_UPDATE)
			Endif	
		Else
			oMdlProp:SetOperation(MODEL_OPERATION_DELETE)
		Endif		

		oMdlProp:Activate()
        If oMdlProp:IsActive()
			oMdlADY := oMdlProp:GetModel("ADYMASTER")
			aAux := oMdlADY:GetStruct():GetFields()

			For nX := 1 To Len (aADYMaster)
				If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aADYMaster[nX][1])}) > 0
					If aScan(aFronze, aADYMaster[nX,1]) == 0
						If !oMdlADY:SetValue(aADYMaster[nX,1], aADYMaster[nX,2]) 
							lRet := .F.
							cResp := "Não foi possível atribuir o valor " + AllToChar(aADYMaster[nX,2]) + " ao campo " + aADYMaster[nX,1] + "."
							Exit
						EndIf
					Endif
				Endif
			Next nX		

			oMdlADZ := oMdlProp:GetModel("ADZPRODUTO")
			aAux := oMdlADZ:GetStruct():GetFields()

			For nY := 1 To Len(aADZProdut)				

				If nOpcx == MODEL_OPERATION_INSERT
					cItem := Soma1(cItem)
				Else
					nPosItem := aScan(aADZProdut[nY], {|x| AllTrim(x[1]) == "ADZ_ITEM"})
					If nPosItem == 0
						lRet := .F.			
						cResp:=  "Item não informado"
					Else
						cItem 	 := aADZProdut[nY,nPosItem,2]
					Endif
				Endif
				
				If oMdlADZ:SeekLine({{"ADZ_ITEM",cItem}})
					oMdlADZ:SetValue("ADZ_ITEM",cItem)
				Else
					If nY > 1
						oMdlADZ:AddLine()
					Endif
					oMdlADZ:SetValue("ADZ_ITEM",cItem)
				Endif

				If Len(aADZProdut) > 0
					For nX := 1 To Len(aADZProdut[nY])
						If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aADZProdut[nY,nX,1])}) > 0
							If aScan(aFronze, aADZProdut[nY,nX,1]) == 0
								If !oMdlADZ:SetValue(aADZProdut[nY,nX,1], aADZProdut[nY,nX,2]) 
									lRet := .F.
									cResp := "Não foi possível atribuir o valor " + AllToChar(aADZProdut[nY,nX,2]) + " ao campo " + aADZProdut[nY,nX,1] + "."
									Exit
								EndIf
							Endif
						Endif
					Next nX
				EndIf

				If !oMdlADZ:VldLineData(.F.)
					lRet := .F.
					aMsgErro := oMdlProp:GetErrorMessage()				
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
				Endif
			Next nY

			If lRet
				If oMdlProp:VldData()
					oMdlProp:CommitData()				
				Else
					lRet:= .F.
					aMsgErro	:= oMdlProp:GetErrorMessage()				
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
	Else 
		cResp := "Falha ao carregar Oportunidade de Venda"
		lRet := .F.
	EndIf

	If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Proposta comercial!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	aSize(aAux,0)
	aSize(aADYMaster,0)
	aSize(aADZProdut,0)
	aSize(aFronze,0)
	aSize(aMsgErro,0)
	Freeobj(oMdlADZ)
	Freeobj(oMdlADY)
	Freeobj(oMdlProp)
	Freeobj(oMdlOpor)

Return lRet

/*/{Protheus.doc} ManuItem
Realiza a manutenção (inclusão/alteração/exclusão) da Itens da Proposta Comercial

@param oApiManager	, Objeto	, Objeto FWAPIManager inicializado no método 
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

	Local aAux			:= {}	
	Local aADZProdut	:= {}
	Local aFronze		:= {"ADZ_FILIAL","ADZ_ITEM","ADZ_DESCRI","ADZ_UM","ADZ_TOTAL"}
	Local aMsgErro		:= {}
	Local cResp			:= ""
	Local cItem			:= "00"
	Local lRet			:= .T.
    Local oMdlOpor  	:= Nil
    Local oMdlADY   	:= Nil
    Local oMdlADZ   	:= Nil
    Local oMdlProp  	:= Nil
	Local nX			:= 0
	Local nY			:= 0

	Private INCLUI		:= .F.

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	oMdlOpor := FwLoadModel( "FATA300" )
    oMdlOpor:SetOperation( MODEL_OPERATION_UPDATE )
    oMdlOpor:Activate()

	If oMdlOpor:IsActive()
		oMdlProp := FwLoadModel( "FATA600" )
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aADZProdut)
		EndIf

		oMdlProp:SetOperation(MODEL_OPERATION_UPDATE)			

		oMdlProp:Activate()
        If oMdlProp:IsActive()
			oMdlADY := oMdlProp:GetModel("ADYMASTER")
			oMdlADZ := oMdlProp:GetModel("ADZPRODUTO")
			aAux := oMdlADZ:GetStruct():GetFields()			
			nPosItem := aScan(aADZProdut, {|x| AllTrim(x[1]) == "ADZ_ITEM"})			
								
			If nOpcx == MODEL_OPERATION_INSERT
				cItem := fSeqItem(oMdlADZ)
			Else
				cItem := cChave
			Endif

			If oMdlADZ:SeekLine({{"ADZ_ITEM",cItem}})
				If nOpcx == MODEL_OPERATION_INSERT
					lRet := .F.			
					cResp:=  "Esse item " + AllToChar(cItem)+ " ja existe na Proposta Comercial"
				Elseif nOpcx == MODEL_OPERATION_UPDATE
					oMdlADZ:SetValue("ADZ_ITEM",cItem)
				Elseif nOpcx == MODEL_OPERATION_DELETE
					oMdlADZ:DeleteLine()
				Endif
			Else
				If nOpcx == MODEL_OPERATION_INSERT
					oMdlADZ:AddLine()
					oMdlADZ:SetValue("ADZ_ITEM",cItem)					
				Else
					lRet := .F.			
					cResp:=  "Item nao localizado"
				Endif
			Endif
	
			If lRet .And. nOpcx <> MODEL_OPERATION_DELETE
				aADZProdut := FWVetByDic(aADZProdut,"ADZ",.F.)
				For nX := 1 To Len (aADZProdut)
					If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aADZProdut[nX,1])}) > 0
						If aScan(aFronze, aADZProdut[nX,1]) == 0
							If !oMdlADZ:SetValue(aADZProdut[nX,1], aADZProdut[nX,2])
								lRet := .F.
								cResp := "Não foi possível atribuir o valor " + AllToChar(aADZProdut[nX,2]) + " ao campo " + aADZProdut[nX,1] + "."
								Exit
							EndIf
						Endif
					Endif
				Next nX
			EndIf
		
			If lRet
				If oMdlProp:VldData()
					oMdlProp:CommitData()				
				Else
					lRet:= .F.
					aMsgErro	:= oMdlProp:GetErrorMessage()				
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
	
	Else 
		cResp := "Falha ao carregar Oportunidade de Venda"
		lRet := .F.
	EndIf

	If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Proposta comercial!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	
	aSize(aADZProdut,0)
	aSize(aFronze,0)
	aSize(aMsgErro,0)
	Freeobj(oMdlADZ)
	Freeobj(oMdlADY)
	Freeobj(oMdlProp)
	Freeobj(oMdlOpor)

Return lRet 

/*/{Protheus.doc} OrdExec
Move posição do campo Numero de oportunidade.
@param aCabec   , Array , Array de Campos que seram utilizados no ExecAuto


@author     Squad Faturamento/CRM
@since      03/10/2018
@version    12.1.21

/*/

Static Function OrdExec(aADZProdut)

    Local aTemp := {}
	Local nZ    := 0
    Local nI    := 0
    Local nY    := 0
	
	If Len(aADZProdut) > 0
    	nI    := Len(aADZProdut[1]) - 1
    	nY    := aScan(aADZProdut[1],{|x|x[1]=="ADZ_CONDPG"})
	EndIf

    If nI > 0 .And. nY > 0
		For nZ:= 1 To Len(aADZProdut)
			aTemp := aADZProdut[nZ][nY]
			aDel(aADZProdut[nZ],nY)
			aSize(aADZProdut[nZ],nI)
			aAdd(aADZProdut[nZ],aTemp)
		Next nZ
    Endif

Return Nil

/*/{Protheus.doc} fSeqItem
Move posição do campo Numero de oportunidade.
@param oModel   , Objeto , Modelo de dados do Item (Produtos)


@author     Squad Faturamento/CRM
@since      29/11/2018
@version    12.1.21

/*/
Static Function fSeqItem(oModel)

	Local cRet		:= "00"
	Local nI		:= oModel:Length()
	Local nPosItem	:= aScan(oModel:aHeader,{|x|AllTrim(x[2]) == "ADZ_ITEM"})

	cRet := oModel:GetValueByPos(nPosItem,nI)
	cRet := Soma1(cRet)

Return cRet