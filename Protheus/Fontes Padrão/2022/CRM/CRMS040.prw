#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS040()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} contactrelationship
API de integraçao de Cadastro de Relacionamento de Contatos x Entidade

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSRESTFUL contactrelationship DESCRIPTION "Cadastro de Relacionamento Contato x Entidade" 

	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA InternalId	    AS STRING	OPTIONAL
    WSDATA ContactId        AS STRING	OPTIONAL
	
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todos Relacionamento de Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contactrelationship"

    WSMETHOD POST Main ;
    DESCRIPTION "Inclui um Relacionamento de Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{Fields}";
    PATH "/api/crm/v1/contactrelationship"

    WSMETHOD GET InternalId ;
    DESCRIPTION "Retorna um Relacionamento de Contatos x Entidade espefico" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}{Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}"

    WSMETHOD PUT InternalId ;
    DESCRIPTION "Altera um Relacionamento de Contatos x Entidade específico" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}{Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}"

    WSMETHOD DELETE InternalId ;
    DESCRIPTION "Deleta um Relacionamento de Contatos x Entidade específico" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}{Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}"

    WSMETHOD GET listofcontact ;
    DESCRIPTION "Retorna todos items de um Relacionamento de Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}/listofcontact{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}/listofcontact"

    WSMETHOD POST listofcontact ;
    DESCRIPTION "Inclui um item em um Relacionamento de Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{Fields}";
    PATH "/api/crm/v1/contactrelationship/{InternalId}/listofcontact"

    WSMETHOD GET ContactId ;
    DESCRIPTION "Retorna um item especifico de um relacionamnto Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{ContactId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{ContactId}"

    WSMETHOD PUT ContactId ;
    DESCRIPTION "Altera um item especifico de um relacionamnto Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{ContactId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{ContactId}"

    WSMETHOD DELETE ContactId ;
    DESCRIPTION "Deleta um item especifico de um relacionamnto Contatos x Entidade" ;
    WSSYNTAX "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{ContactId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contactrelationship/{InternalId}/listofcontact/{ContactId}"

ENDWSRESTFUL

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /contactrelationship/crm/contactrelationship
Retorna lista com todos Relacionamento de contatos x Entidade

@param	Order		, caracter, Ordenaçao da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serao retornados na requisiçao.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contactrelationship

    Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("CRMS040","1.000")

    lRet    := GetAC8(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} POST /contactrelationship/crm/contactrelationship
Inclui uma Relacionamento de um Contato

@param	Fields	, caracter, Campos que serao retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		07/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contactrelationship

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS040","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutAC8(oApiManager, 3, oJson)
        If lRet
            aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
            aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
            aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
            aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})
            
            oApiManager:SetApiFilter(aFilter)
            lRet := GetAC8(@oApiManager, Self)
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Relacionamento do Contato!", "Nao foi possivel tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /contactrelationship/crm/contactrelationship/{InternalId}
Lista um Relacionamento de contato x Entidade específica

@param	InternalId	, caracter, Código do Apontamento
@param	Fields		, caracter, Campos que serao retornados na requisiçao.
@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Fields WSSERVICE contactrelationship

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("CRMS040","1.000")

	AC8->(DbSetOrder(2))
	If AC8->(DbSeek( Self:InternalId ))

		aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})
		
		oApiManager:SetApiFilter(aFilter)
		lRet := GetAC8(@oApiManager, Self)
	Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao listar Relacionamento do Contato x Entidade!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} PUT /selleractivity/crm/selleractivity/{InternalId}
Altera uma Atividade específica

@param	InternalId	        , caracter, Código do Documento
@param	Order				, caracter, Ordenaçao da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serao retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE contactrelationship

	Local aFilter		:= {}
	Local aJson			:= {}
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("CRMS040","1.000")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
		AC8->(DbSetOrder(2))
        If AC8->(DbSeek( Self:InternalId ))
		    lRet := ManutAC8(oApiManager, 4, oJson)
            If lRet
                aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})

                oApiManager:SetApiFilter(aFilter)
		        lRet := GetAC8(@oApiManager, Self)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar Relacionamento do contato!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao alterar Relacionamento do contato!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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
/*/{Protheus.doc} DELETE /contactrelationship/crm/contactrelationship/{InternalId}
Deleta um Relacionamento de contato x Entidade específica

@param	InternalId	        , caracter, Chave composta do Relacionamento
@param	Fields				, caracter, Campos que serao retornados na requisiçao.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		07/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE Fields WSSERVICE contactrelationship

	Local aJson			:= {}
	Local cResp			:= "Registro Excluido com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("CRMS040","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	AC8->(DbSetOrder(2))
    If AC8->(DbSeek( Self:InternalId ))
		lRet := ManutAC8(oApiManager, 5)
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao excluir Relacionamento do contato!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /contactrelationship/crm/contactrelationship/{InternalId}/listofcontact
Lista um Relacionamento de contato x Entidade específica

@param	InternalId	, caracter, Código do Apontamento
@param	Fields		, caracter, Campos que serao retornados na requisiçao.
@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET listofcontact PATHPARAM InternalId  WSRECEIVE Fields WSSERVICE contactrelationship

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("CRMS040","1.000")

	AC8->(DbSetOrder(2))
	If AC8->(DbSeek( Self:InternalId ))

		aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})		

		oApiManager:SetApiFilter(aFilter)
		lRet := GetItem(@oApiManager, Self:aQueryString)
	Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao listar Relacionamento do Contato x Entidade!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
	Endif

    If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} POST /contactrelationship/crm/contactrelationship/{InternalId}/listofcontact
Inclui um Item (Contato) de Relacionamento de um Contato

@param	InternalId	, caracter, Código da Entidade
@param	Fields	, caracter, Campos que serao retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		09/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD POST listofcontact WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contactrelationship

	Local aFilter       := {}
    Local aJson         := {}    
	Local cBody 	  	:= Self:GetContent()
    Local cContact      := ""
    Local cError		:= ""
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS040","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMapI())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        AC8->(DbSetOrder(2))
        If AC8->(DbSeek( Self:InternalId ))
            lRet := ManutItm(oApiManager, 3, oJson, @cContact)
            If lRet
                aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_CODCON = '" + cContact        + "'"}})
                
                oApiManager:SetApiFilter(aFilter)
                lRet := GetItem(@oApiManager, Self:aQueryString)
            Endif
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir item do Relacionamento!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /contactrelationship/crm/contactrelationship/{InternalId}/listofcontact/{ContactCode}
Lista um Relacionamento de contato x Entidade específica

@param	InternalId	, caracter, Código da Entidade
@param  ContactId   , caracter, Código do Contato
@param	Fields		, caracter, Campos que serao retornados na requisiçao.
@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET ContactId PATHPARAM InternalId , ContactId WSRECEIVE Fields WSSERVICE contactrelationship

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("CRMS040","1.000")

	AC8->(DbSetOrder(2))
	If AC8->(DbSeek( Self:InternalId ))

		aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})
		aAdd(aFilter, {"AC8", "items",{"AC8_CODCON = '" + Self:ContactId  + "'"}})

		oApiManager:SetApiFilter(aFilter)		
        lRet := GetItem(@oApiManager, Self:aQueryString)
	Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao listar Relacionamento do Contato x Entidade!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} PUT /contactrelationship/crm/contactrelationship/{InternalId}/listofcontact/{ContactId}
Altera um Item (Contato) de Relacionamento de um Contato

@param	InternalId	, caracter, Código da Entidade
@param  ContactId   , caracter, Código do Contato
@param	Fields	, caracter, Campos que serao retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		12/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD PUT ContactId PATHPARAM InternalId , ContactId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contactrelationship

	Local aFilter       := {}
    Local aJson         := {}    
	Local cBody 	  	:= Self:GetContent()
    Local cContact      := ""
    Local cError		:= ""
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS040","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMapI())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        AC8->(DbSetOrder(2))
        If AC8->(DbSeek( Self:InternalId ))
            lRet := ManutItm(oApiManager, 4, oJson, @cContact, Self:ContactId)
            If lRet
                aAdd(aFilter, {"AC8", "items",{"AC8_FILIAL = '" + AC8->AC8_FILIAL + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_ENTIDA = '" + AC8->AC8_ENTIDA + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_CODENT = '" + AC8->AC8_CODENT + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_FILENT = '" + AC8->AC8_FILENT + "'"}})
                aAdd(aFilter, {"AC8", "items",{"AC8_CODCON = '" + cContact        + "'"}})
                
                oApiManager:SetApiFilter(aFilter)
                lRet := GetItem(@oApiManager, Self:aQueryString)
            Endif
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Alterar Item do Relacionamento!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} DELETE /contactrelationship/crm/contactrelationship/{InternalId}/listofcontact/{ContactId}
Exclui um Item (Contato) de Relacionamento de um Contato

@param	InternalId	, caracter, Código da Entidade
@param  ContactId   , caracter, Código do Contato
@param	Fields	, caracter, Campos que serao retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		12/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD DELETE ContactId PATHPARAM InternalId , ContactId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contactrelationship
	    
    Local cError		:= ""
    Local cResp			:= "Registro Excluido com Sucesso"
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS040","1.000")
	Local oJson			:= THashMap():New()
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC8","items", "items"})
	oApiManager:SetApiMap(ApiMapI())
	oApiManager:Activate()
    
    AC8->(DbSetOrder(2))
    If AC8->(DbSeek( Self:InternalId ))
        lRet := ManutItm(oApiManager, 5, oJson, , Self:ContactId)
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao excluir Relacionamento do contato!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} GetAC8
Realiza o Get do Relacionamento de contatos x Entidade

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetAC8(oApiManager, Self)

	Local aFatherAlias	:= {"AC8","items"           ,"items"            }
    Local aQuery        := {}
	Local cIndexKey		:= " AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT "
    Local lRet          := .T.

	If Len(oApiManager:GetApiRelation()) == 0
		DefRelation(@oApiManager)
	EndIf

    aQuery := MntQuery()
	oApiManager:setQuery("items",aQuery[1],aQuery[2])
    
	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetItem
Realiza o Get dos Items de um Relacionamento de contatos x Entidade

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetItem(oApiManager, aQueryString, lHasNext)

	Local aFatherAlias		:= {"AC8","items"           ,"items"            }
    Local lRet 				:= .T.
    Local cIndexKey		    := " AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT "

	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.
	
	oApiManager:SetApiMap(ApiMapI())
	oApiManager:SetApiAlias(aFatherAlias)

	lRet := ApiMainGet(@oApiManager, aQueryString, , , aFatherAlias, cIndexKey , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)    

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetMain
Realiza o Get do Relacionamento de contatos x Entidade

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informaçao se existem ou nao mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)
	
    Local aRelation 		:= {}
    Local aChildrenAlias    := {}
    Local lRet 				:= .T.

	Default oApiManager		:= Nil
	Default aQueryString	:= {,}    
	Default lHasNext		:= .T.
    Default cIndexKey		:= ""    

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager - Completo

@return     aApiMap , Array , Array com estrutura
@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ApiMap()

    Local aApiMap   := {}
    Local aStrAC8   := {}
    Local aStrChld  := {}
    Local aStruct   := {}

    aStrAC8 := {"AC8","field","items","items",;
		{;
			{"CompanyId"		    , "Exp:cEmpAnt" 			},;
            {"CompanyInternalId"    , ""                        },;
            {"InternalId"			, "AC8_FILIAL, AC8_ENTIDA, AC8_FILENT, AC8_CODENT"  },;
			{"BranchId"			    , "AC8_FILIAL"				},;
            {"Code" 			    , "AC8_CODENT"				},;  
            {"Entity"               , "AC8_ENTIDA"              };
		},;
	}

    aStrChld := {"AC8","Item","ListOfContacts","ListOfContacts",;
        {;
            {"ContactCode"          ,"AC8_CODCON"               },;
            {"ContactInternalId"    ,"AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT"};
        },;
    }

    aStruct := {aStrAC8, aStrChld}
	aApiMap := {"CRMS180","items","1.000","CRMS180", aStruct, "items"}

Return aApiMap

//--------------------------------------------------------------------
/*/{Protheus.doc} ApiMapI
Estrutura a ser utilizada na classe ServicesApiManager - Item

@return     aApiMap , Array , Array com estrutura
@author		Squad Faturamento/CRM
@since		07/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ApiMapI()

    Local aApiMap   := {}
    Local aStrAC8   := {}    
    Local aStruct   := {}

    aStrAC8 := {"AC8","field","items","items",;
        {;
            {"ContactCode"          ,"AC8_CODCON"               },;
            {"ContactInternalId"    ,"AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT"};
        },;
    }

    aStruct := {aStrAC8}
	aApiMap := {"CRMS180","items","1.000","CRMS180", aStruct, "items"}

Return aApiMap

//--------------------------------------------------------------------
/*/{Protheus.doc} DefRelation
Define o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function DefRelation(oApiManager)

    Local aRelation     := {}
    Local aFatherAlias	:= {"AC8","items"           ,"items"            }
    Local aChldAlias    := {"AC8","ListOfContacts"  ,"ListOfContacts"   }
    Local cIndexKey		:= "AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT"

    aAdd(aRelation,{"AC8_FILIAL"	,"AC8_FILIAL"   })
    aAdd(aRelation,{"AC8_ENTIDA"  	,"AC8_ENTIDA"   })
    aAdd(aRelation,{"AC8_CODENT"	,"AC8_CODENT"   })
    aAdd(aRelation,{"AC8_FILENT"  	,"AC8_FILENT"   })    

    oApiManager:SetApiRelation(aChldAlias	, aFatherAlias  	, aRelation, cIndexKey)    
    oApiManager:SetApiMap(ApiMap())

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} MntQuery
Monta Query Pai

@return aQuery	 		, Array 	, Retorna um array de uma dimenssao com duas posições (Query,Order).
@author	Squad Faturamento/CRM
@since		06/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function MntQuery()

    Local aRet      := {}
    Local cGroup    := ""
    Local cQuery    := ""

    cQuery += " SELECT items.AC8_FILIAL, items.AC8_FILENT, items.AC8_ENTIDA, items.AC8_CODENT "    
    cQuery += " FROM " + RetSqlName("AC8") + " AS items "
    cQuery += " INNER JOIN " + RetSqlName("AC8") + " AS ListOfContacts "
    cQuery += " ON items.AC8_FILIAL = ListOfContacts.AC8_FILIAL  "
	cQuery += " AND items.AC8_ENTIDA = ListOfContacts.AC8_ENTIDA "
	cQuery += " AND items.AC8_CODENT = ListOfContacts.AC8_CODENT "
	cQuery += " AND items.AC8_FILENT = ListOfContacts.AC8_FILENT "
    cQuery += " AND items.D_E_L_E_T_ = ListOfContacts.D_E_L_E_T_ "

    cGroup += " items.AC8_FILIAL, "
    cGroup += " items.AC8_FILENT, "
    cGroup += " items.AC8_ENTIDA, "
    cGroup += " items.AC8_CODENT "

    aAdd(aRet, cQuery)
    aAdd(aRet, cGroup)    

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutAC8
Realiza a manutençao (inclusao/alteraçao/exclusao) do Relacionamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param nOpcx		, Numérico	, Operaçao a ser realizada
@param oJson		, Objeto	, Objeto com Json parceado
@return lRet	    , Lógico	, Retorna se realizou ou nao o processo

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutAC8(oApiManager, nOpcx, oJson)

    Local aMsgErro  := {}
    Local cEntity	:= ""
	Local cCode		:= ""
    Local cCodCon   := ""
    Local cResp     := ""
    Local lRet      := .T.
    Local nI        := 0
    Local nLength   := 0
    Local oMdlGrid	:= Nil
    Local oModel	:= FwLoadModel("CRMA060")	

    If nOpcx <> MODEL_OPERATION_DELETE
        If AttIsMemberOf(oJson, "Entity") .And. !Empty(oJson:Entity)
            cEntity := oJson:Entity            
        Else 
            lRet := .F.
        Endif

        If lRet .And. AttIsMemberOf(oJson, "Code") .And. !Empty(oJson:Code)
            cCode := oJson:Code
        Else 
            lRet := .F.
        Endif

        If lRet .And. FWAliasInDic(cEntity)
            If ExistCpo(cEntity, cCode, 1 )
                If lRet .And. AttIsMemberOf(oJson, "ListOfContacts") .And. ValType(oJson:ListOfContacts) == "A"
                    oModel:SetOperation(MODEL_OPERATION_UPDATE)
                    oModel:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity ),cEntity,cCode,""}}
                    oModel:Activate()
                    If oModel:IsActive()                        
                        oMdlGrid := oModel:GetModel("AC8CONTDET")
                        For nI := 1 To Len(oJson:ListOfContacts)
                            If AttIsMemberOf(oJson:ListOfContacts[nI], "ContactCode") .And. !Empty(oJson:ListOfContacts[nI]:ContactCode)
                                cCodCon := oJson:ListOfContacts[nI]:ContactCode
                            Else
                                cResp := "Codigo do Contato nao informado..."
                                lRet := .F.
                                Exit
                            Endif
                            If !oMdlGrid:SeekLine({{"AC8_CODCON",cCodCon}})                                
                                If oMdlGrid:AddLine()
                                    If !oMdlGrid:SetValue("AC8_CODCON",cCodCon)
                                        lRet := .F.                                        
                                        aMsgErro	:= oModel:GetErrorMessage()
                                    Endif
                                Else
                                    lRet := .F.
                                    aMsgErro := oModel:GetErrorMessage()
                                    Exit
                                EndIf
                            Else 
                                If !oMdlGrid:SetValue("AC8_CODCON",cCodCon)
                                    lRet := .F.                                    
                                    aMsgErro	:= oModel:GetErrorMessage()
                                Endif
                            Endif
                        Next nI
                    Else 
                        cResp   := "Nao foi possivel Incluir/Alterar o Relacionamento"
                        lRet := .F.
                    Endif
                Else 
                    cResp := "Codigo do contato nao informado..."
                    lRet := .F.
                Endif                
            Else
                cResp := "Entidade nao encontrada..."
                lRet := .F.
            Endif
        Else 
            cResp := "O Alias informado nao existe nos arquivos de dados..."
            lRet := .F.
        Endif
    Else
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()
        If !oModel:IsActive()
            cResp   := "Nao foi possivel Excluir o Relacionamento"
            lRet := .F.
        Endif
    Endif

    If lRet        
        If oModel:VldData()
            oModel:CommitData()
        Else
            lRet:= .F.
            aMsgErro	:= oModel:GetErrorMessage()
        EndIf
    Else
        If Len(aMsgErro) > 0
            cResp := " Mensagem do erro: " 			 + FwNoAccent( AllToChar( aMsgErro[6]))
            cResp += " Mensagem da solucao: " 		 + FwNoAccent( AllToChar( aMsgErro[7]))
            cResp += " Valor atribuido: " 			 + FwNoAccent( AllToChar( aMsgErro[8]))
            cResp += " Valor anterior: " 			 + FwNoAccent( AllToChar( aMsgErro[9]))
            cResp += " Id do formulário de origem: " + FwNoAccent( AllToChar( aMsgErro[1]))
            cResp += " Id do campo de origem: " 	 + FwNoAccent( AllToChar( aMsgErro[2]))
            cResp += " Id do formulario de erro: " 	 + FwNoAccent( AllToChar( aMsgErro[3]))
            cResp += " Id do campo de erro: " 		 + FwNoAccent( AllToChar( aMsgErro[4]))
            cResp += " Id do erro: " 				 + FwNoAccent( AllToChar( aMsgErro[5]))
        Endif
        oApiManager:SetJsonError("400","Erro durante Inclusao/Alteracao/Exclusao do Relacionamento do Contato x Entidade!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    Endif

    aSize(aMsgErro,0)
    FreeObj(oModel)
    FreeObj(oMdlGrid)
    
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutAC8
Realiza a manutençao (inclusao/alteraçao/exclusao) do Relacionamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param nOpcx		, Numérico	, Operaçao a ser realizada
@param oJson		, Objeto	, Objeto com Json parceado
@param cContact	    , Caractere	, Codigo do Contato
@return lRet	    , Lógico	, Retorna se realizou ou nao o processo

@author		Squad Faturamento/CRM
@since		09/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutItm(oApiManager, nOpcx, oJson, cContact , cChave)

    Local aMsgErro  := {}
    Local cEntity	:= ""
	Local cCode		:= ""
    Local cCodCon   := ""
    Local cResp     := ""
    Local lAchou    := .T.
    Local lRet      := .T.        
    Local oMdlGrid	:= Nil
    Local oModel	:= FwLoadModel("CRMA060")

    cEntity := AC8->AC8_ENTIDA
    cCode   := AC8->AC8_CODENT
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity ),cEntity,cCode,""}}
    oModel:Activate()

    If oModel:IsActive()        
        If AttIsMemberOf(oJson,"ContactCode") .And. !Empty(oJson:ContactCode)
            cContact  := oJson:ContactCode
            If Empty(cChave)
                cChave := cContact
            Endif
        Elseif nOpcx <> 5
            cResp := "Codigo do Contato nao informado..."
            lRet := .F.
        Endif

        If lRet 
            oMdlGrid := oModel:GetModel("AC8CONTDET")
            If oMdlGrid:SeekLine({{"AC8_CODCON",cChave}})
                lAchou := .T.
            Else 
                lAchou := .F.
            Endif
            
            If nOpcx == 3
                If !lAchou
                    If oMdlGrid:AddLine()
                        If !oMdlGrid:SetValue("AC8_CODCON",cContact)
                            lRet := .F.
                            aMsgErro := oModel:GetErrorMessage()
                        Endif
                    Else
                        lRet := .F.
                        aMsgErro := oModel:GetErrorMessage()
                    EndIf
                Else
                    cResp := "Relacionamento da entidade " + cEntity + "\" + AllTrim(cCode) + " ja possui o contato " + cContact + " cadastrado."
                    lRet := .F.                
                Endif
            Elseif nOpcx == 4
                If lAchou
                    If !oMdlGrid:SeekLine({{"AC8_CODCON",cContact}})
                        If !oMdlGrid:SetValue("AC8_CODCON",cContact)
                            lRet := .F.
                            aMsgErro := oModel:GetErrorMessage()
                        Endif
                    Else
                        cResp := "Relacionamento da entidade " + cEntity + "\" + AllTrim(cCode) + " ja possui o contato " + cContact + " cadastrado."
                        lRet := .F.
                    Endif
                Else
                    cResp := "Nao existe registro relacionado ao codigo do Contato informado"
                    lRet := .F.
                Endif
            Elseif nOpcx == 5
                If lAchou
                    oMdlGrid:DeleteLine()
                Else
                    cResp := "Nao existe registro relacionado ao codigo do Contato informado"
                    lRet := .F.
                Endif
            Endif
        Endif
    Endif

    If lRet        
        If oModel:VldData()
            oModel:CommitData()
        Else
            lRet:= .F.
            aMsgErro	:= oModel:GetErrorMessage()
        EndIf
    ElseIf Len(aMsgErro) > 0
            cResp := " Mensagem do erro: " 			 + FwNoAccent( AllToChar( aMsgErro[6]))
            cResp += " Mensagem da solucao: " 		 + FwNoAccent( AllToChar( aMsgErro[7]))
            cResp += " Valor atribuido: " 			 + FwNoAccent( AllToChar( aMsgErro[8]))
            cResp += " Valor anterior: " 			 + FwNoAccent( AllToChar( aMsgErro[9]))
            cResp += " Id do formulário de origem: " + FwNoAccent( AllToChar( aMsgErro[1]))
            cResp += " Id do campo de origem: " 	 + FwNoAccent( AllToChar( aMsgErro[2]))
            cResp += " Id do formulario de erro: " 	 + FwNoAccent( AllToChar( aMsgErro[3]))
            cResp += " Id do campo de erro: " 		 + FwNoAccent( AllToChar( aMsgErro[4]))
            cResp += " Id do erro: " 				 + FwNoAccent( AllToChar( aMsgErro[5]))
        oApiManager:SetJsonError("400","Erro durante Inclusao/Alteracao/Exclusao do Relacionamento do Contato x Entidade!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    Else
        If nOpcx == 3 .or. (nOpcx == 4 .And. lAchou)
            oApiManager:SetJsonError("400","Erro durante Inclusao/Alteracao/Exclusao do Relacionamento do Contato x Entidade!.", cResp,/*cHelpUrl*/,/*aDetails*/)
        Else
            oApiManager:SetJsonError("404","Erro durante Inclusao/Alteracao/Exclusao do Relacionamento do Contato x Entidade!.", cResp,/*cHelpUrl*/,/*aDetails*/)
        Endif
    Endif
   
    aSize(aMsgErro,0)
    FreeObj(oModel)
    FreeObj(oMdlGrid)

Return lRet