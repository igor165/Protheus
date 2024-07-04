#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FATS900.CH"

//dummy function
Function FATS900()

Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} CustomerCreditLimit
API de integração Limite de Credito do cliente
Definido nome da classe "CustomerCreditLimit" devido EndPoint

@author	    Squad Faturamento/CRM
@since	    10/06/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSRESTFUL CustomerCreditLimit DESCRIPTION STR0001 FORMAT APPLICATION_JSON //Limite de Crédito do Cliente

    WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA InternalId	    AS STRING	OPTIONAL
    WSDATA aQueryString		AS ARRAY	OPTIONAL

    WSMETHOD GET Main ;
    DESCRIPTION STR0002 ; //Retorna o Limite de crédito de todos os Clientes.
    WSSYNTAX "/api/fat/v1/CustomerCreditLimit/{Order, Page, PageSize, Fields}" ;
    PATH "/api/fat/v1/CustomerCreditLimit" ;
    PRODUCES APPLICATION_JSON ;
    TTALK "v1"

    WSMETHOD GET internalId ;
    DESCRIPTION STR0003 ; //Retorna o Limite de crédito de um cliente especifico.
    WSSYNTAX "/api/fat/v1/CustomerCreditLimit/{InternalId}{Fields}" ;
    PATH "/api/fat/v1/CustomerCreditLimit/{InternalId}" ;
    PRODUCES APPLICATION_JSON ;
    TTALK "v1"

ENDWSRESTFUL

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET /api/fat/v1/CustomerCreditLimit
Retorna todos Processos de Venda

@param	Order		, Caractere , Ordenação da tabela principal
@param	Page		, Numérico  , Número da página inicial da consulta
@param	PageSize	, Numérico  , Número de registro por páginas
@param	Fields		, Caractere , Campos que serão retornados no GET.
@return lRet	    , Lógico    , Informa se o processo foi executado com sucesso.
@author Squad Faturamento/CRM
@since  10/06/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CustomerCreditLimit

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil    
	
    Self:SetContentType(APPLICATION_JSON)

	oApiManager := FWAPIManager():New(STR0004,"1.000") //FATS900
    
    lRet := GetMain(@oApiManager, Self:aQueryString)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()
    FreeObj(oApiManager)

Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET /api/fat/v1/CustomerCreditLimit/{InternalId}
Retorna os Estágios de um Processo de Venda específico

@param  InternalId  , Caractere , Chave composta do registro (Filial + Codigo + Loja)
@param	Order		, Caractere , Ordenação da tabela principal.
@param	Page		, Numérico  , Número da página inicial da consulta.
@param	PageSize	, Numérico  , Número de registro por páginas.
@param	Fields		, Caractere , Campos que serão retornados no GET.
@return lRet	    , Lógico    , Informa se o processo foi executado com sucesso.
@author	Squad Faturamento/CRM
@since	10/06/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET internalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CustomerCreditLimit

    Local aFilter       := {}
    Local cError		:= ""
    Local cCredCli      := GetMv("MV_CREDCLI",,"L")
	Local lRet			:= .T.
	Local oApiManager	:= Nil

    Default InternalId  := ""

    Self:SetContentType(APPLICATION_JSON)
	oApiManager := FWAPIManager():New(STR0004,"1.000") //FATS900

    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(Self:InternalId))
        aAdd(aFilter, {"SA1", "items",{"A1_FILIAL   = '" + SA1->A1_FILIAL   +  "'"}})
        aAdd(aFilter, {"SA1", "items",{"A1_COD	    = '" + SA1->A1_COD 	    +  "'"}})

        If cCredCli == "L"
            aAdd(aFilter, {"SA1", "items",{"A1_LOJA	    = '" + SA1->A1_LOJA 	+  "'"}})
        Endif

        oApiManager:SetApiFilter(aFilter)
        lRet := GetMain(@oApiManager, Self:aQueryString, cCredCli)
    Else
        lRet := .F.
		oApiManager:SetJsonError("404",STR0005, STR0006,/*cHelpUrl*/,/*aDetails*/) //"Erro ao listar Limite de crédito do Cliente!" / Cliente não encontrado
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

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GetMain
Efetua a consulta dos Clientes considerando o parametro MV_CREDCLI

@param  oApiManager	    , Objeto	, Objeto ApiManager inicializado no método.
@param  aQueryString    , Array		, Array com os filtros a serem utilizados no Get.
@param  cCredCli        , Caractere	, Utilize "L" para controle de credito por loja ou "C" para controle de credito por cliente.
@return lRet	    	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author	Squad Faturamento/CRM
@since	10/06/2020
@version    12.1.27
/*/
//-----------------------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, cCredCli)

    Local aQuery            := {}
	Local aChildrenAlias	:= {}
    Local aFatherAlias	    := {"SA1","items", "items"}
	Local aRelation 		:= {}
	Local cIndexKey		    := ""
	Local lRet 			    := .T.
	
	Default aQueryString	:= {,}
    Default cCredCli        := GetMv("MV_CREDCLI",,"L")
	Default oApiManager	    := Nil	

    If cCredCli == "L"
        cIndexKey := " A1_FILIAL, A1_COD, A1_LOJA "
        aQuery := MntQueryL()
        oApiManager:SetApiMap(ApiMapL())
    Else
        cIndexKey := " A1_FILIAL, A1_COD "
        aQuery := MntQueryC()
        oApiManager:SetApiMap(ApiMapC())
    Endif

    oApiManager:SetQuery("items",aQuery[1],aQuery[2])
    oApiManager:DisplayEmptyFld(.T.)

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), .T.)

    aSize( aQuery, 0 )
	aSize( aRelation, 0 )
	aSize( aChildrenAlias, 0 )
	aSize( aFatherAlias, 0 )

Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} ApiMapL
Estrutura de campos utilizadas no objeto/classe FWAPIManager - MV_CREDCLI = L

@return aApiMap , Array , Estrutura de campos
@author	Squad Faturamento/CRM
@since  10/06/2020
@version    12.1.27
/*/
//-----------------------------------------------------------------------------------
Static Function ApiMapL()

    Local aApiMap   := {}
    Local aStrSA1   := {}
    Local aStruct   := {}

    aStrSA1 := {"SA1","field","items","items",;
        {;  
            {"CompanyInternalId"                             ,"Exp: '" + FWCodEmp() + "'"           },;
            {"CustomerInternalId"                            ,"A1_FILIAL, A1_COD, A1_LOJA"          },;
            {"DocumentType"                                  ,"Exp: ''"                             },;
            {"CreditLimit"                                   ,"SALDO"                               },;// Saldo disponível para uso
            {"Description"                                   ,"Exp: '" + STR0007 + "'"              },;// Saldo disponivel do Cliente
            {"LimitDate"                                     ,"A1_VENCLC"                           },;// Data de limite de crédito 
            {"TotalCreditLimit"                              ,"A1_LC"                               },;// Total de limite concedido ao cliente
            {"CreditLimitUsedByBilling"                      ,"A1_SALDUPM"                          },;// Saldo em duplicatas
            {"CreditLimitUsedBySalesOrders"                  ,"TOTLIMPED"                           },;// Saldo em pedidos aberto + liberado
            {"CreditLimitUsedByOrdersAndFinance"             ,"TOTLIMPEDFIN"                        }; // Saldo Pedidos aberto + Saldo em duplicatas
        },;
    }

    aStruct := {aStrSA1}
	aApiMap := {STR0004, "items", "1.000", STR0004, aStruct, "items"} //FATS900

Return aApiMap

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} ApiMapC
Estrutura de campos utilizadas no objeto/classe FWAPIManager - MV_CREDCLI = L

@return aApiMap , Array , Estrutura de campos
@author	Squad Faturamento & CRM
@since  11/06/2020
@version    12.1.27
/*/
//-----------------------------------------------------------------------------------
Static Function ApiMapC()

    Local aApiMap   := {}
    Local aStrSA1   := {}
    Local aStruct   := {}

    aStrSA1 := {"SA1","field","items","items",;
        {;
            {"CompanyInternalId"                             ,"Exp: '" + FWCodEmp() + "'"           },;
            {"CustomerInternalId"                            ,"A1_FILIAL, A1_COD"                   },;
            {"DocumentType"                                  ,"Exp: ''"                             },;
            {"CreditLimit"                                   ,"SALDO"                               },;// Saldo disponível para uso
            {"Description"                                   ,"Exp: '" + STR0007 + "'"              },;// Saldo disponivel do Cliente
            {"LimitDate"                                     ,"A1_VENCLC"                           },;// Data de limite de crédito 
            {"TotalCreditLimit"                              ,"A1_LC"                               },;// Total de limite concedido ao cliente
            {"CreditLimitUsedByBilling"                      ,"A1_SALDUPM"                          },;// Saldo em duplicatas
            {"CreditLimitUsedBySalesOrders"                  ,"TOTLIMPED"                           },;// Saldo em pedidos aberto + liberado
            {"CreditLimitUsedByOrdersAndFinance"             ,"TOTLIMPEDFIN"                        }; // Saldo Pedidos aberto + Saldo em duplicatas
        },;
    }

    aStruct := {aStrSA1}
	aApiMap := {STR0004, "items", "1.000", STR0004, aStruct, "items"} //FATS900

Return aApiMap

//--------------------------------------------------------------------
/*/{Protheus.doc} MntQueryL
Monta query utilizada no FwApiManager quando parametro MV_CREDCLI = L

@return aQuery , Array , Retorna um array de uma dimensão com duas posições (Query,Order).
@author	Squad Faturamento & CRM
@since  11/06/2020
@version    12.1.27
/*/
//--------------------------------------------------------------------
Static Function MntQueryL()

    Local aRet      := {}
    Local cGroup    := ""
    Local cQuery    := ""

    cQuery += " SELECT items.A1_FILIAL, items.A1_COD, items.A1_LOJA, items.A1_VENCLC, items.A1_LC, items.A1_SALDUPM , items.A1_SALPED, "
    cQuery += " SUM(A1_LC - A1_SALDUPM - A1_SALPEDL) SALDO, "
    cQuery += " SUM(A1_SALPED + A1_SALPEDL) TOTLIMPED, "
    cQuery += " SUM(A1_LC) - SUM(A1_LC - A1_SALDUPM - A1_SALPEDL) TOTLIMPEDFIN "
    cQuery += " FROM " + RetSqlName("SA1") + " items "
    cGroup += " items.A1_FILIAL, "
    cGroup += " items.A1_COD, "
    cGroup += " items.A1_LOJA, "
    cGroup += " items.A1_VENCLC, "
    cGroup += " items.A1_LC, "
    cGroup += " items.A1_SALDUPM, "
    cGroup += " items.A1_SALPED "

    aAdd(aRet, cQuery)
    aAdd(aRet, cGroup)

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} MntQueryC
Monta query utilizada no FwApiManager quando parametro MV_CREDCLI = C

@return aQuery , Array , Retorna um array de uma dimensão com duas posições (Query,Order).
@author	Squad Faturamento & CRM
@since  11/06/2020
@version    12.1.27
/*/
//--------------------------------------------------------------------
Static Function MntQueryC()

    Local aRet      := {}
    Local cGroup    := ""
    Local cQuery    := ""

    cQuery += " SELECT items.A1_FILIAL, items.A1_COD, "
    cQuery += " MAX(items.A1_VENCLC) A1_VENCLC, "
    cQuery += " SUM(A1_LC - A1_SALDUPM - A1_SALPEDL) SALDO, "
    cQuery += " SUM(A1_LC) A1_LC, "
    cQuery += " SUM(A1_SALDUPM) A1_SALDUPM, "
    cQuery += " SUM(A1_SALPED) A1_SALPED, "
    cQuery += " SUM(A1_SALPED + A1_SALPEDL) TOTLIMPED, "
    cQuery += " SUM(A1_LC) - SUM(A1_LC - A1_SALDUPM - A1_SALPEDL) TOTLIMPEDFIN "
    cQuery += " FROM " + RetSqlName("SA1") + " items "
    cGroup += " items.A1_FILIAL, "
    cGroup += " items.A1_COD "

    aAdd(aRet, cQuery)
    aAdd(aRet, cGroup)

Return aRet