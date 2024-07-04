#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//Dummy function
Function FATS010()

Return

/*/{Protheus.doc} Processo de Venda
API de integração de Cadastro de Processos de Venda

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSRESTFUL salesProcess DESCRIPTION "Cadastro de Processos de Venda" 

    WSDATA Fields				AS STRING	OPTIONAL
    WSDATA Order				AS STRING	OPTIONAL
    WSDATA Page				AS INTEGER	OPTIONAL
    WSDATA PageSize			AS INTEGER	OPTIONAL
    WSDATA salesProcessCode AS STRING	OPTIONAL
    WSDATA stages				AS STRING	OPTIONAL
    WSDATA InternalId		AS STRING	OPTIONAL
    WSDATA StageId			AS STRING	OPTIONAL
    WSDATA rules				AS STRING	OPTIONAL
    WSDATA RuleId				AS STRING	OPTIONAL
	
	//EndPoints dos Processos de Venda
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todos os Processos de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{Fields}";
    PATH "/api/crm/v1/SalesProcess"

    WSMETHOD GET salesProcessCode ;
    DESCRIPTION "Retorna um Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{salesProcessCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{salesProcessCode}"

    WSMETHOD PUT salesProcessCode ;
    DESCRIPTION "Altera um Processo de Venda específica" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{salesProcessCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{salesProcessCode}"

    WSMETHOD DELETE salesProcessCode ;
    DESCRIPTION "Deleta um Processo de Venda específica" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{salesProcessCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{salesProcessCode}"
    
    //EndPoints dos Estágios
    WSMETHOD GET Mstages ;
    DESCRIPTION "Retorna todos os Estágios do Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfStages"

    WSMETHOD POST Mstages ;
    DESCRIPTION "Não utilizado" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{Fields}";
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfStages"

    WSMETHOD GET stage ;
    DESCRIPTION "Retorna um Estágio do Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{StageId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{StageId}"

    WSMETHOD PUT stage ;
    DESCRIPTION "Não utilizado" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{StageId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{StageId}"

    WSMETHOD DELETE stage ;
    DESCRIPTION "Não utilizado" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{StageId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfStages/{StageId}"
    
    //EndPoints das Regras
    WSMETHOD GET Mrules ;
    DESCRIPTION "Retorna todos as Regras do Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfRules"

    WSMETHOD POST Mrules ;
    DESCRIPTION "Cadastra uma Regra no Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfRules"

    WSMETHOD GET rule ;
    DESCRIPTION "Retorna uma Regra Específica do Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{StageId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{RuleId}"

    WSMETHOD PUT rule ;
    DESCRIPTION "Altera uma Regra Específica do Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{StageId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{RuleId}"

    WSMETHOD DELETE rule ;
    DESCRIPTION "Deleta uma Regra Específica do Processo de Venda" ;
    WSSYNTAX "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{StageId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/SalesProcess/{InternalId}/listOfRules/{RuleId}"
     
ENDWSRESTFUL

/*/{Protheus.doc} GET / salesProcess/salesProcess
Retorna todos Processos de Venda

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("FATS010","1.000")
	
    lRet    := GetAC1(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / salesProcess/salesProcess
Cadastra um Processo de Venda

@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet		, Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local aFilter      	:= {}
	Local aJson       	:= {}
	Local cError			:= ""
	Local cBody 	  		:= Self:GetContent()
	Local lRet				:= .T.
	Local oApiManager		:= FWAPIManager():New("FATS010","1.000")
	Local oJson			:= THashMap():New()    
	
    Self:SetContentType("application/json")

   	oApiManager:SetApiAlias({"AC1","items", "items"})
	oApiManager:SetApiMap(ApiMapAC1())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutAC1(@oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
	       Aadd(aFilter, {"AC1", "items",{"AC1_PROVEN = '" + AC1->AC1_PROVEN + "'"}})
	       oApiManager:SetApiFilter(aFilter)	    
        	lRet    := GetAC1(@oApiManager, Self)
        Endif
    Else        
        oApiManager:SetJsonError("400","Erro ao Incluir Processo de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError["code"]), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
   	aSize(aFilter,0)
   	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} GET / salesProcess/salesProcess/{salesProcessCode}
Retorna um Processo de Venda específica

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD GET salesProcessCode PATHPARAM salesProcessCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE salesProcess

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
	Local oApiManager		:= Nil
	Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("FATS010","1.000")
	
	cCode := Substr(Self:salesProcessCode,TamSX3("AC1_FILIAL")[1]+1,Len(Self:salesProcessCode))   
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"AC1", "items",{"AC1_PROVEN = '" + cCode + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetAC1(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} PUT / salesProcess/{salesProcessCode}
Altera um Processo de Venda específica

@param	salesProcessCode	, caracter, Código do Processo de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD PUT salesProcessCode PATHPARAM salesProcessCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE salesProcess

    Local aFilter			:= {}
    Local aJson			:= {}	
    Local cBody 	   		:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.    
    Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
    Local oJson			:= THashMap():New()
    Local cCode			:= ""	

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC1","items", "items"})
    oApiManager:SetApiMap(ApiMapAC1())
    oApiManager:Activate()

    lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
    	cCode := Substr(Self:salesProcessCode,TamSX3("AC1_FILIAL")[1]+1,Len(Self:salesProcessCode))   
	
		If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
			lRet := .F.
	       oApiManager:SetJsonError("400","Erro na requisição do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
	    EndIf
	    
       If lRet
	        If AC1->(DbSeek(xFilial("AC1") + cCode))
			    lRet := ManutAC1(oApiManager, Self:aQueryString, 4, aJson, cCode, oJson, cBody)
	            If lRet
		            Aadd(aFilter, {"AC1", "items",{"AC1_PROVEN = '" + AC1->AC1_PROVEN + "'"}})
	                oApiManager:SetApiFilter(aFilter)	    
	                lRet    := GetAC1(@oApiManager, Self)
	            Endif 
	        Else
	            lRet := .F.
	            oApiManager:SetJsonError("404","Erro ao alterar a Processo de Venda!", "Processo de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
	        Endif
       EndIf
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Processo de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DELETE / salesProcess/{salesProcessCode}/
Deleta um Processo de Venda específica

@param	salesProcessCode	, caracter, Código do Processo de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD DELETE salesProcessCode PATHPARAM salesProcessCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE salesProcess

    Local aJson			:= {}
    Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
    Local oJsonPositions	:= JsonObject():New()
    Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AC1","items", "items"})
	oApiManager:SetApiMap(ApiMapAC1())
	oApiManager:Activate()
	
	cCode := Substr(Self:salesProcessCode,TamSX3("AC1_FILIAL")[1]+1,Len(Self:salesProcessCode))   
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf

	If lRet
	    If AC1->(DbSeek(xFilial("AC1") + cCode))
			lRet := ManutAC1(oApiManager, Self:aQueryString, 5, aJson, cCode, , cBody)        
	    Else
	        lRet := .F.
	        oApiManager:SetJsonError("404","Erro ao Excluir a Processo de Venda!", "Processo de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
	    Endif
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
	aSize(aJson,0)
   	FreeObj( oJsonPositions )

Return lRet

//Estágios

/*/{Protheus.doc} GET / salesProcess/{InternalId}/listOfStages/
Retorna os Estágios de um Processo de Venda específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD GET Mstages PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
   	Local oJson			:= THashMap():New()
   	Local cCode			:= ""	

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC2","items", "items"})
    oApiManager:SetApiMap(ApiMapAC2())
    oApiManager:Activate()
	
	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))   
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição dos Estágios do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"AC2", "items",{"AC2_PROVEN = '" + cCode + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetAC2(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} POST / salesProcess/{InternalId}/listOfStages/
Cadastra um Estágio no Processo de Venda (Não Utilizado)

@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet		, Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD POST Mstages PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local cError			:= ""
	Local lRet 			:= .F.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")

    Self:SetContentType("application/json")

	SetRestFault( 400, EncodeUtf8("O EndPoint ListOfStages não é utilizado com o verbo POST no Protheus") )

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} GET / salesProcess/{InternalId}/listOfStages/{StageId}
Retorna um Estágio específico do Processo de Venda

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD GET stage PATHPARAM InternalId, StageId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE salesProcess

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
   	Local oJson			:= THashMap():New()
   	Local cCode			:= ""
   	Local cStage			:= ""

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC2","items", "items"})
    oApiManager:SetApiMap(ApiMapAC2())
    oApiManager:Activate()
	
	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))   
	cStage:= Self:StageId
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição dos Estágios do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"AC2", "items",{"AC2_PROVEN = '" + cCode + "'"}})
		Aadd(aFilter, {"AC2", "items",{"AC2_STAGE = '" + cStage + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetAC2(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} PUT / salesProcess/{InternalId}/listOfStages/{StageId}
Altera um Estágio específico do Processo de Venda (Não Utilizado)

@param	salesProcessCode	, caracter, Código do Processo de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD PUT stage PATHPARAM InternalId, StageId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local cError			:= ""
	Local lRet 			:= .F.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")

    Self:SetContentType("application/json")

	SetRestFault( 400, EncodeUtf8("O EndPoint StagesId não é utilizado com o verbo PUT no Protheus") )

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} DELETE / salesProcess/{InternalId}/listOfStages/{StageId}
Deleta um Estágio específico do Processo de Venda (Não Utilizado)

@param	salesProcessCode	, caracter, Código do Processo de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD DELETE stage PATHPARAM InternalId, StageId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local cError			:= ""
	Local lRet 			:= .F.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")

    Self:SetContentType("application/json")

	SetRestFault( 400, EncodeUtf8("O EndPoint StageId não é utilizado com o verbo DELETE no Protheus") )

	oApiManager:Destroy()

Return lRet


//Rules

/*/{Protheus.doc} GET / salesProcess/{InternalId}/listOfRules/
Retorna as Regras de um Processo de Venda específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD GET Mrules PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
   	Local oJson			:= THashMap():New()
   	Local cCode			:= ""	

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"ACZ","items", "items"})
    oApiManager:SetApiMap(ApiMapACZ())
    oApiManager:Activate()
	
	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))   
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição das Regras do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"ACZ", "items",{"ACZ_PROVEN = '" + cCode + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetAC2(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} POST / salesProcess/{InternalId}/listOfRules/
Cadastra uma Regra no Processo de Venda

@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet		, Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD POST Mrules PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local aFilter      	:= {}
	Local aJson       	:= {}
	Local cError			:= ""
	Local cBody 	  		:= Self:GetContent()
	Local lRet				:= .T.
	Local oApiManager		:= FWAPIManager():New("FATS010","1.000")
	Local oJson			:= THashMap():New()
	Local nItem			:= 0	
	Local cItem			:= ""
	Local cCode			:= ""    
	
    Self:SetContentType("application/json")

   	oApiManager:SetApiAlias({"ACZ","items", "items"})
	oApiManager:SetApiMap(ApiMapACZ())
	oApiManager:Activate()

	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))   
	
    If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição das Regras do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
    If lRet
    	lRet = FWJsonDeserialize(cBody,@oJson)
    EndIf

    If lRet
        lRet := ManutACZ(@oApiManager, Self:aQueryString, 3, aJson, cCode, oJson, cBody)
        If lRet
        	nItem := aScan(aJson[1][1][1][2],{|x| AllTrim(x[1])=="ACZ_ITEM"})
    		cItem := aJson[1][1][1][2][nItem][2]
	       Aadd(aFilter, {"ACZ", "items",{"ACZ_PROVEN = '" + cCode + "'"}})
	       Aadd(aFilter, {"ACZ", "items",{"ACZ_ITEM = '" + cItem + "'"}})
	       oApiManager:SetApiFilter(aFilter)	    
        	lRet    := GetACZ(@oApiManager, Self)
        Endif
    Else        
        oApiManager:SetJsonError("400","Erro ao Incluir a Regra no Processo de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError["code"]), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
   	aSize(aFilter,0)
   	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} GET / salesProcess/{InternalId}/listOfRules/{RuleId}
Retorna uma Regra específica do Processo de Venda

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD GET rule PATHPARAM InternalId, RuleId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE salesProcess

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
   	Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
   	Local oJson			:= THashMap():New()
   	Local cCode			:= ""
   	Local cRule			:= ""

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"ACZ","items", "items"})
    oApiManager:SetApiMap(ApiMapACZ())
    oApiManager:Activate()
	
	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))   
	cRule:= Self:RuleId
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição da Regra do Processo de Venda!", "O código da filial, do Processo de Venda ou da Regra não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"ACZ", "items",{"ACZ_PROVEN = '" + cCode + "'"}})
		Aadd(aFilter, {"ACZ", "items",{"ACZ_ITEM = '" + cRule + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetAC2(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} PUT / salesProcess/{InternalId}/listOfRules/{RuleId}
Altera uma Regra específica do Processo de Venda

@param	salesProcessCode	, caracter, Código do Processo de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD PUT rule PATHPARAM InternalId, RuleId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE salesProcess

	Local aFilter      	:= {}
	Local aJson       	:= {}
	Local cError			:= ""
	Local cBody 	  		:= Self:GetContent()
	Local lRet				:= .T.
	Local oApiManager		:= FWAPIManager():New("FATS010","1.000")
	Local oJson			:= THashMap():New()
	Local nItem			:= 0	
	Local cItem			:= ""
	Local cCode			:= ""    
	
    Self:SetContentType("application/json")

   	oApiManager:SetApiAlias({"ACZ","items", "items"})
	oApiManager:SetApiMap(ApiMapACZ())
	oApiManager:Activate()

	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))
	cRule := Self:RuleId   
	
    If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição das Regras do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
    If lRet
    	lRet = FWJsonDeserialize(cBody,@oJson)
    EndIf

    If lRet
        ACZ->(dbSetOrder(1)) 
        If ACZ->(DbSeek(xFilial("ACZ") + cCode + cRule))
		    lRet := ManutACZ(oApiManager, Self:aQueryString, 4, aJson, cCode, oJson, cBody, cRule)
            If lRet
                Aadd(aFilter, {"ACZ", "items",{"ACZ_PROVEN = '" + ACZ->ACZ_PROVEN + "'"}})
                Aadd(aFilter, {"ACZ", "items",{"ACZ_ITEM = '" + cRule + "'"}})
                oApiManager:SetApiFilter(aFilter)	    
                lRet    := GetACZ(@oApiManager, Self)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar a Regra do Processo de Venda!", "Processo de Venda não encontrada.",/*cHelpUrl*/,/*aDetails*/)
       EndIf
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar a Regra do Processo de Venda!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

Return lRet

/*/{Protheus.doc} DELETE / salesProcess/{InternalId}/listOfRules/
Deleta um Estágio específico do Processo de Venda

@param	salesProcessCode	, caracter, Código do Processo de Venda
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

WSMETHOD DELETE rule PATHPARAM InternalId, RuleId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE salesProcess

    Local aJson			:= {}
    Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("FATS010","1.000")
    Local oJsonPositions	:= JsonObject():New()
    Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"ACZ","items", "items"})
	oApiManager:SetApiMap(ApiMapAC1())
	oApiManager:Activate()
	
	cCode := Substr(Self:InternalId,TamSX3("AC1_FILIAL")[1]+1,Len(Self:InternalId))
	cRule := Self:RuleId    
	
	If  Len(cCode) <> TamSX3("AC1_PROVEN")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição do Processo de Venda!", "O código da filial ou do Processo de Venda não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf

	If lRet
	    ACZ->(dbSetOrder(1)) 
	    If ACZ->(DbSeek(xFilial("ACZ") + cCode + cRule))
			lRet := ManutACZ(oApiManager, Self:aQueryString, 5, aJson, cCode, , cBody, cRule)        
	    Else
	        lRet := .F.
	        oApiManager:SetJsonError("404","Erro ao Excluir a Regra do Processo de Venda!", "Regra não encontrada.",/*cHelpUrl*/,/*aDetails*/)
	    Endif
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
	aSize(aJson,0)
   	FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} GetAC1
Realiza o Get dos Processos de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	   		, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function GetAC1(oApiManager, Self)

	Local aFatherAlias	:=  {"AC1","items", "items"}
	Local cIndexKey		:=  " AC1_FILIAL, AC1_PROVEN "
   	Local lRet          	:=  .T.

	If Len(oApiManager:GetApiRelation()) == 0
		DefRelation(@oApiManager)
	EndIf
	
	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} GetAC2
Realiza o Get dos Estágios do Processo de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	   		, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function GetAC2(oApiManager, Self)

	Local aFatherAlias	:=  {"AC2","items", "items"}
	Local cIndexKey		:=  " AC2_FILIAL, AC2_PROVEN, AC2_STAGE "
   	Local lRet          	:=  .T.
	
	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} GetACZ
Realiza o Get das Regras do Processo de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	   		, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function GetACZ(oApiManager, Self)

	Local aFatherAlias	:=  {"ACZ","items", "items"}
	Local cIndexKey		:=  " ACZ_FILIAL, ACZ_PROVEN, ACZ_ITEM "
   	Local lRet          	:=  .T.
	
	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         	, Nulo

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

	Local aRelatStg    	:=	{{"AC1_FILIAL", "AC2_FILIAL"},{"AC1_PROVEN", "AC2_PROVEN"}}
	Local aRelatRle    	:=	{{"AC1_FILIAL", "ACZ_FILIAL"},{"AC1_PROVEN", "ACZ_PROVEN"}}
	Local aFatherAlias	:=	{"AC1",	"items",								"items"}
	Local aChiLstStg		:=	{"AC2",	"ListofStages",			"ListofStages"}
	Local aChiLstRls		:=	{"ACZ",	"ListofRules",			"ListofRules"}
	Local cIndStg			:=	"AC2_FILIAL, AC2_PROVEN"
	Local cIndRule		:=	"ACZ_FILIAL, ACZ_PROVEN"

	oApiManager:SetApiRelation(aChiLstStg,		aFatherAlias,		aRelatStg, cIndStg)
	oApiManager:SetApiRelation(aChiLstRls,		aFatherAlias,		aRelatRle, cIndRule)

	oApiManager:SetApiMap(ApiMapAC1())

Return Nil

/*/{Protheus.doc} GetMain
Realiza o Get dos Processos de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey		, String	, Índice da tabela pai
@return lRet	    	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 			:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager	:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMapAC1
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function ApiMapAC1()

	Local aApiMap			:=	{}
	Local aStruct			:=	{}
	Local aStrAC1			:=	{}
	Local aStrStage		:=	{}
	Local aStrRules		:=	{}

	aStrAC1 		:=	{"AC1","field","items","items",;
		{;
			{"BranchId"						,"AC1_FILIAL"												},;
			{"CompanyInternalId"				,""															},;
			{"InternalId"       	    		,"AC1_FILIAL, AC1_PROVEN"								},;
			{"Code"              	       ,"AC1_PROVEN"												},;
			{"Description"					,"AC1_DESCRI"												},;
			{"RegisterSituation"				,"AC1_MSBLQL"												};
		},;
	}

    aStrStage 	:=	{"AC2","item","ListofStages","ListofStages",;
        {;
           {"BranchId"						,"AC2_FILIAL"												},;
           {"StageInternalId"				,"AC2_FILIAL, AC2_PROVEN, AC2_STAGE"					},;
           {"StageId"						,"AC2_STAGE"												},;
           {"StageDescription"				,"AC2_DESCRI"												},;
           {"Contribute"						,"AC2_RELEVA"												},;
           {"Notify"							,"AC2_SENDWF"												},;
           {"Action"							,"AC2_ACAO"  												},;								
           {"FinancialEvaluation"			,"AC2_AVFIN"												},;
           {"ValueOverdue"					,"AC2_VLRLIM"												},;
           {"DaysOverdue"					,"AC2_DIALIM"												},;
           {"ProspectEvaluation"			,"AC2_AVLPRO"												},;
           {"DurationDays"					,"AC2_DDURAC"												},;
           {"DurationHours"					,"AC2_HDURAC"												};
        },;
    }
    
    aStrRules 	:=	{"ACZ","item","ListofRules","ListofRules",;
        {;
			{"BranchId"						,"ACZ_FILIAL" 						       			},;
			{"RuleInternalId"					,"ACZ_FILIAL, ACZ_PROVEN, ACZ_ITEM"		        	},;
			{"RuleId"							,"ACZ_ITEM"												},;
			{"Operation"						,"ACZ_OPER"												},;
			{"Event"							,"ACZ_EVENTO"												},;
			{"Action"							,"ACZ_ACAO"												},;
			{"Stage"							,"ACZ_STAGE"												};
        },;
    }

	aStruct := {aStrAC1,aStrStage,aStrRules}

	aApiMap := {"FATS010","items","1.000","FATS010",aStruct, "items"}

Return aApiMap

/*/{Protheus.doc} ApiMapAC2
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function ApiMapAC2()

	Local aApiMap			:=	{}
	Local aStruct			:=	{}
	Local aStrAC1			:=	{}

    aStrAC2	 	:=	{"AC2","field","items","items",;
        {;
           {"BranchId"						,"AC2_FILIAL"												},;
           {"StageInternalId"				,"AC2_FILIAL, AC2_PROVEN, AC2_STAGE"					},;
           {"StageId"						,"AC2_STAGE"												},;
           {"StageDescription"				,"AC2_DESCRI"												},;
           {"Contribute"						,"AC2_RELEVA"												},;
           {"Notify"							,"AC2_SENDWF"												},;
           {"Action"							,"AC2_ACAO"  												},;								
           {"FinancialEvaluation"			,"AC2_AVFIN"												},;
           {"ValueOverdue"					,"AC2_VLRLIM"												},;
           {"DaysOverdue"					,"AC2_DIALIM"												},;
           {"ProspectEvaluation"			,"AC2_AVLPRO"												},;
           {"DurationDays"					,"AC2_DDURAC"												},;
           {"DurationHours"					,"AC2_HDURAC"												};
        },;
    }
    
	aStruct := {aStrAC2}

	aApiMap := {"FATS010","items","1.000","FATS010",aStruct, "items"}

Return aApiMap

/*/{Protheus.doc} ApiMapACZ
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author	Squad Faturamento/CRM
@since		26/11/2018
@version	12.1.21
/*/

Static Function ApiMapACZ()

	Local aApiMap			:=	{}
	Local aStruct			:=	{}
	Local aStrAC1			:=	{}

    aStrACZ	 	:=	{"ACZ","field","items","items",;
        {;
           {"BranchId"						,"ACZ_FILIAL"												},;
           {"RuleInternalId"				,"ACZ_FILIAL, ACZ_PROVEN, ACZ_ITEM"					},;
           {"RuleId"							,"ACZ_ITEM"												},;
           {"Operation"						,"ACZ_OPER"												},;
           {"Event"							,"ACZ_EVENTO"												},;
           {"Action"							,"ACZ_ACAO"												},;
           {"Stage"							,"ACZ_STAGE"  											};
        },;
    }
    
	aStruct := {aStrACZ}

	aApiMap := {"FATS010","items","1.000","FATS010",aStruct, "items"}  

Return aApiMap

/*/{Protheus.doc} ManutAC1
Realiza a manutenção (inclusão/alteração/exclusão) do Processo de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson			, Array		, Array tratado de acordo com os dados do json recebido
@param cChave			, Caracter	, Chave com codigo da Transportadora (A4_COD)
@param oJson			, Objeto	, Objeto com Json parceado
@param cBody       	, Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function ManutAC1(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)
	
	Local aPrcVnd   := {}
	Local aStage   := {}
	Local aRule   := {}
	Local aFrzAC1	:= {"AC1_PROVEN"}//não altera
	Local aFrzAC2	:= {"AC2_PROVEN","AC2_STAGE"}//não altera
	Local aFrzACZ	:= {"ACZ_PROVEN","ACZ_ITEM"}//não altera
	Local aModif	:= {}
	Local aMsgErro	:= {}
	Local aAuxFld	:= {}
	Local aAuxGd1	:= {}
	Local aAuxGd2	:= {}  
	Local cCodPcVn 	:= ""
	Local cCodStge 	:= ""	
	Local cCodRule 	:= ""
	Local cResp		:= ""	
	Local lRet		:= .T.
   	Local nX		:= 0	
	Local nY		:= 0
	Local nZ		:= 0
	Local nK		:= 0
	Local nR		:= 0
	Local nT		:= 0
	Local nGrid1	:= 0
	Local nPosStge 	:= 0
	Local nPosRule 	:= 0
	Local oModel	:= FWLoadModel("FATA010")
	Local oModelFld := oModel:GetModel("AC1MASTER")
	Local oModelGd1	:= oModel:GetModel("AC2DETAIL")
	Local oModelGd2	:= oModel:GetModel("ACZDETAIL")

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

	If nOpcx <> MODEL_OPERATION_DELETE

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aPrcVnd)
		EndIf

		If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2])
				If aJson[1][2][nX][1][1] == "AC2"
					oApiManager:ToExecAuto(2, aJson[1][2][nX][1][2], aStage)
				Else
					oApiManager:ToExecAuto(2, aJson[1][2][nX][1][2], aRule)
				EndIf
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
	oModel:Activate()
	If oModel:isActive()
		If oModel:nOperation <> MODEL_OPERATION_DELETE
			aAuxFld	:= oModelFld:GetStruct():GetFields()
			aAuxGd1	:= oModelGd1:GetStruct():GetFields()
			aAuxGd2	:= oModelGd2:GetStruct():GetFields()
			
			For nY := 1 To Len (aPrcVnd)
				If aScan(aAuxFld, {|x| AllTrim(x[3]) == AllTrim(aPrcVnd[nY][1])}) > 0
					If aScan(aFrzAC1, aPrcVnd[nY,1]) == 0 .or. oModel:nOperation != MODEL_OPERATION_UPDATE
						If !oModelFld:SetValue(aPrcVnd[nY,1], aPrcVnd[nY,2]) 
							lRet := .F.
							cResp := "Não foi possível atribuir o valor " + AllToChar(aPrcVnd[nY,2]) + " ao campo " + aPrcVnd[nY,1] + "."
							Exit
						EndIf
					Endif
				Endif
			Next nY

			If lRet
				nPosPcVn := aScan(aPrcVnd, {|x| AllTrim(x[1]) == "AC1_PROVEN"})
				cCodPcVn := aPrcVnd[nPosPcVn,2]
				nGrid1	:= oModelGd1:Length()
				nGrid2	:= oModelGd2:Length()
				If nPosPcVn > 0
					For nX := 1 To Len(aStage)
	
						If nX > 1 .And. oModel:nOperation == MODEL_OPERATION_INSERT
							oModelGd1:AddLine()
						Elseif oModel:nOperation == MODEL_OPERATION_UPDATE
	
							nPosStge := aScan(aStage[nX], {|x| AllTrim(x[1]) == "AC2_STAGE"})
							cCodStge := IIf(nPosStge > 0 ,aStage[nX,nPosStge,2],CriaVar("AC2_STAGE"))
							
							If !oModelGd1:SeekLine({{"AC2_PROVEN",cCodPcVn},{"AC2_STAGE",cCodStge}})
								If nX > 1
									oModelGd1:AddLine()
								Endif
							Endif
						Endif
						For nY := 1 To Len(aStage[nX])
							If aScan(aAuxGd1, {|x| AllTrim(x[3]) == AllTrim(aStage[nX,nY,1])}) > 0
								If aScan(Iif(nGrid1 >= nX, aFrzAC2, {}), aStage[nX,nY,1]) == 0 .or. oModel:nOperation != MODEL_OPERATION_UPDATE
									If !oModelGd1:SetValue(aStage[nX,nY,1], aStage[nX,nY,2])
										lRet := .F.
										cResp := "Não foi possível atribuir o valor " + AllToChar(aStage[nX,nY,2]) + " ao campo " + aStage[nX,nY,1] + "."
										Exit
									EndIf
								EndIf
							Endif
						Next nY
	
						If lRet
							If oModelGd1:IsModified()
								If !oModelGd1:VldLineData(.F.)
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
								Elseif !oModelGd1:IsInserted(oModelGd1:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
									oModelGd1:SetLineModify(oModelGd1:GetLine())
								Endif
							Elseif !oModelGd1:IsInserted(oModelGd1:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
								oModelGd1:SetLineModify(oModelGd1:GetLine())
							Endif
						Else
							Exit
						Endif				
					Next nX
					For nZ := 1 To Len(aRule)
	
						If nZ > 1 .And. oModel:nOperation == MODEL_OPERATION_INSERT
							oModelGd2:AddLine()
						Elseif oModel:nOperation == MODEL_OPERATION_UPDATE
	
							nPosRule := aScan(aRule[nZ], {|x| AllTrim(x[1]) == "ACZ_ITEM"})
							cCodRule := IIf(nPosRule > 0 ,aRule[nZ,nPosRule,2],CriaVar("ACZ_ITEM"))
							
							If !oModelGd2:SeekLine({{"ACZ_PROVEN",cCodPcVn},{"ACZ_ITEM",cCodRule}})
								If nZ > 1
									oModelGd2:AddLine()
								Endif
							Endif
						Endif
						For nK := 1 To Len(aRule[nZ])
							If aScan(aAuxGd2, {|x| AllTrim(x[3]) == AllTrim(aRule[nZ,nK,1])}) > 0
								If aScan(Iif(nGrid2 >= nZ, aFrzACZ, {}), aRule[nZ,nK,1]) == 0 .or. oModel:nOperation != MODEL_OPERATION_UPDATE
									If !oModelGd2:SetValue(aRule[nZ,nK,1], aRule[nZ,nK,2])
										lRet := .F.
										cResp := "Não foi possível atribuir o valor " + AllToChar(aRule[nZ,nK,2]) + " ao campo " + aRule[nZ,nK,1] + "."
										Exit
									EndIf
								EndIf
							Endif
						Next nK
	
						If lRet
							If oModelGd2:IsModified()
								If !oModelGd2:VldLineData(.F.)
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
								Elseif !oModelGd2:IsInserted(oModelGd2:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
									oModelGd1:SetLineModify(oModelGd1:GetLine())
								Endif
							Elseif !oModelGd2:IsInserted(oModelGd2:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
								oModelGd2:SetLineModify(oModelGd2:GetLine())
							Endif
						Else
							Exit
						Endif				
					Next nZ
				Endif
			Endif

			If oModel:nOperation == MODEL_OPERATION_UPDATE .AND. lRet
				aModif := oModelGd1:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
				If Len(aModif) > 0
					For nR := 1 To oModelGd1:Length()
						If !aScan(aModif, {|x| x == nR})
							oModelGd1:GoLine(nR)
							oModelGd1:DeleteLine()
						Endif
					Next nR
				Elseif Len(aStage) == 0
					oModelGd1:DelAllLine()
				Endif
				aModif := oModelGd2:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
				If Len(aModif) > 0
					For nT := 1 To oModelGd2:Length()
						If !aScan(aModif, {|x| x == nT})
							oModelGd2:GoLine(nT)
							oModelGd2:DeleteLine()
						Endif
					Next nT
				Elseif Len(aRule) == 0
					oModelGd2:DelAllLine()
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
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Processo de Venda!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	aSize(aPrcVnd,0)
	aSize(aStage,0)
	aSize(aFrzAC1,0)
	aSize(aModif,0)
	aSize(aMsgErro,0)
	aSize(aAuxFld,0)
	aSize(aAuxGd1,0)
	aSize(aAuxGd2,0)
	FreeObj(oModelGd1)
	FreeObj(oModelFld)
	FreeObj(oModel)

Return lRet

/*/{Protheus.doc} ManutACZ
Realiza a manutenção (inclusão/alteração/exclusão) das Regras do Processo de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson			, Array		, Array tratado de acordo com os dados do json recebido
@param cChave			, Caracter	, Chave com codigo da Transportadora (A4_COD)
@param oJson			, Objeto	, Objeto com Json parceado
@param cBody       	, Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function ManutACZ(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody, cRule)
	
	Local aStage   := {}
	Local aRule   := {}
	Local aFrzACZ	:= {"ACZ_PROVEN","ACZ_ITEM"}//não altera
	Local aModif	:= {}
	Local aMsgErro	:= {}
	Local aAuxGd1	:= {}
	Local aAuxGd2	:= {}  
	Local cCodStge 	:= ""	
	Local cCodRule 	:= ""
	Local cResp		:= ""	
	Local lRet		:= .T.
   	Local nX		:= 0	
	Local nY		:= 0
	Local nZ		:= 0
	Local nK		:= 0
	Local nR		:= 0
	Local nT		:= 0
	Local nGrid1	:= 0
	Local nPosStge 	:= 0
	Local nPosRule 	:= 0
	Local oModel
	Local oModelFld
	Local oModelGd2

	Default aJson			:= {}
	Default cChave 		:= ""
	Default oJson			:= Nil
	Default cBody			:= ""
	Default cRule			:= ""
	
	AC1->(dbSetOrder(1)) 
	If AC1->(dbSeek(xFilial("AC1") + cChave)) 
		oModel	:= FWLoadModel("FATA010")
		oModelFld := oModel:GetModel("AC1MASTER")
		oModelGd2	:= oModel:GetModel("ACZDETAIL")
	
		aJson := oApiManager:ToArray(cBody)
	
		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aRule)
		EndIf
			
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		
		If oModel:Activate()
			If nOpcx <> MODEL_OPERATION_DELETE
				aAuxGd2	:= oModelGd2:GetStruct():GetFields()
				nGrid2	:= oModelGd2:Length()
					
				If nOpcx == MODEL_OPERATION_INSERT
					oModelGd2:AddLine()
				ElseIf nOpcx == MODEL_OPERATION_UPDATE
					If !oModelGd2:SeekLine({{"ACZ_PROVEN",cChave},{"ACZ_ITEM",cRule}})
						lRet := .F.
						cResp := "Não foi localizada a Regra " + cRule + " no Processo de Venda " + cChave + "."
					EndIf
				EndIf
				
				If lRet
					For nK := 1 To Len(aRule)
						If aScan(aAuxGd2, {|x| AllTrim(x[3]) == AllTrim(aRule[nK,1])}) > 0
							If aScan(aFrzACZ, aRule[nK,1]) == 0 .or. nOpcx == MODEL_OPERATION_INSERT
								If !oModelGd2:SetValue(aRule[nK,1], aRule[nK,2])
									lRet := .F.
									cResp := "Não foi possível atribuir o valor " + AllToChar(aRule[nK,2]) + " ao campo " + aRule[nK,1] + "."
									Exit
								EndIf
							EndIf
						Endif
					Next nK
				Endif				

				If lRet
					If oModelGd2:IsModified()
						If !oModelGd2:VldLineData(.F.)
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
						Elseif !oModelGd2:IsInserted(oModelGd2:GetLine())
							oModelGd2:SetLineModify(oModelGd2:GetLine())
						Endif
					Elseif !oModelGd2:IsInserted(oModelGd2:GetLine())
						oModelGd2:SetLineModify(oModelGd2:GetLine())
					Endif				
				Endif
			Else
				If oModelGd2:SeekLine({{"ACZ_PROVEN",cChave},{"ACZ_ITEM",cRule}})
					oModelGd2:DeleteLine()
				Else
					lRet:= .F.
					cResp := "Não foi localizada a Regra " + cRule + "."
				EndIf
			EndIf
			
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
	Else
		lRet := .F.
		cResp := "Não foi possível localizar o Processo de Venda " + cChave + "."
	Endif
	
	If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão de Regras no Processo de Venda!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	aSize(aModif,0)
	aSize(aMsgErro,0)
	aSize(aAuxGd2,0)
	FreeObj(oModelFld)
	FreeObj(oModel)

Return lRet