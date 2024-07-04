#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MATSIMP.CH"

//dummy function
Function MATSIMP()

Return

/*/{Protheus.doc} SalesTaxes
API de consulta de Tributos de Pedido de Venda
Definido nome da classe "SalesTaxes" devido EndPoint 

@author		Squad Faturamento/CRM
@since		04/12/2020
@version	12.1.27
/*/

WSRESTFUL SalesTaxes DESCRIPTION STR0001  // #"Consulta de Valores e Tributos em Pedidos de Venda" 

	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
    WSDATA Page				AS INTEGER	OPTIONAL
    WSDATA PageSize			AS INTEGER	OPTIONAL
    WSDATA SalesOrderId		AS STRING	OPTIONAL

	//---------------------------------------------------------------------
    WSMETHOD GET SalesTaxes ;
    DESCRIPTION STR0002	; // #"Retorna os impostos de um Pedido já cadastrado"
    WSSYNTAX "/api/fat/v1/SalesTaxes/{SalesOrderId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/fat/v1/SalesTaxes/{SalesOrderId}"

	WSMETHOD POST SalesTaxes ;
    DESCRIPTION STR0003 ; // #"Retorna os impostos de uma simulação de Pedido"
    WSSYNTAX "/api/fat/v1/SalesTaxes/{Fields}";
    PATH "/api/fat/v1/SalesTaxes"
    //---------------------------------------------------------------------

ENDWSRESTFUL

/*/{Protheus.doc} GET / SalesTaxes/{SalesOrderId}
Retorna os Tributos de um Pedido de Venda específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		04/12/2020
@version	12.1.27
/*/

WSMETHOD GET SalesTaxes PATHPARAM SalesOrderId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesTaxes

	Local cError		:= ""
	Local lRet 			:= .T.
	Local cCode			:= ""
	Local aJson			:= {}
	Local cBody 	  	:= Self:GetContent()
	Local oJson			:= THashMap():New()
	Local aRetMnt		:= {}   

	Private oApiManager	:= Nil

    Self:SetContentType("application/json")
	
	oApiManager := FWAPIManager():New("MATSIMP","1.000")
	oApiManager:SetApiAlias({"SC5","items", "items"})
	oApiManager:Activate()
	
	If checkDbUseArea(@lRet)	
		cCode := Self:SalesOrderId
		
		If  Len(cCode) <> TamSX3("C5_NUM")[1]
			lRet := .F.
    		oApiManager:SetJsonError("400",STR0004 /*#"Erro na requisição de Impostos do Pedido de Venda!"*/, STR0005 /*#"O código do Pedido de Venda não condiz com os registros requisitados"*/,/*cHelpUrl*/,/*aDetails*/)
    	EndIf

		If lRet	
			aRetMnt := ManutSC5(@oApiManager, Self:aQueryString, 4, aJson, cCode, oJson, cBody)
			If !aRetMnt[1]
				oApiManager:SetJsonError("404",STR0004 /*#"Erro na requisição de Impostos do Pedido de Venda!"*/, aRetMnt[2],/*cHelpUrl*/,/*aDetails*/)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			Self:SetResponse( oApiManager:ToObjectJson() )
		Else
			cError := oApiManager:GetJsonError()
			SetRestFault( Val(oApiManager:oJsonError['code']), cError )
		EndIf
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
	aSize(aRetMnt,0)
   	FreeObj( oJson )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} POST /SalesTaxes/
Simula um Pedido de Venda para retornar seus Tributos

@param	Fields	, caracter, campos que compõe o Pedido de Venda.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		04/12/2020
@version	12.1.27
/*/
//--------------------------------------------------------------------

WSMETHOD POST SalesTaxes WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SalesTaxes

	Local aJson       	:= {}
	Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oJson			:= THashMap():New()
	Local aRetMnt		:= {}  
	
	Private oApiManager	:= FWAPIManager():New("MATSIMP","1.000")

    Self:SetContentType("application/json")
	
   	oApiManager:SetApiAlias({"SC5","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If checkDbUseArea(@lRet)
		lRet = FWJsonDeserialize(cBody,@oJson)

    	If lRet 
    	    aRetMnt := ManutSC5(@oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
			If !aRetMnt[1]
				oApiManager:SetJsonError("400",STR0004 /*#"Erro na requisição de Impostos do Pedido de Venda!"*/, aRetMnt[2],/*cHelpUrl*/,/*aDetails*/)
				lRet := .F.
			EndIf
    	Else        
    	    oApiManager:SetJsonError("400",STR0004 /*#"Erro na requisição de Impostos do Pedido de Venda!"*/, STR0006 /*#"Não foi possível tratar o Json recebido."*/,/*cHelpUrl*/,/*aDetails*/)
    	Endif

		If lRet
			Self:SetResponse( oApiManager:ToObjectJson() )
		Else
			cError := oApiManager:GetJsonError()
			SetRestFault( Val(oApiManager:oJsonError["code"]), cError )
		EndIf
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
	aSize(aRetMnt,0)
   	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto FWAPIManager inicializado no método 
@return     Nil         , Nulo

@author		Squad Faturamento/CRM
@since		04/12/2020
@version	12.1.27
/*/

Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"SC6", "ListofProducts"      , "ListofProducts"  	}
    Local aFatherSC5	:=	{"SC5", "items"                , "items"           		}        
    Local aRelation     :=  {}
	Local cIndexKey		:=  "C6_FILIAL, C6_NUM"

    aAdd(aRelation,{"C5_FILIAL"	,"C6_FILIAL"   	})
    aAdd(aRelation,{"C5_NUM"  	,"C6_NUM"   	})

	oApiManager:SetApiRelation(aChildren, aFatherSC5, aRelation, cIndexKey)    

Return Nil

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		04/12/2020
@version	12.1.27
/*/
Static Function ApiMap()

	Local apiMap		:= {}
	Local aStrSC5Pai    := {}
	Local aStructGrid   := {}
	Local aStructAlias  := {}

	aStrSC5Pai :=			{"SC5","Field","items","items",;
							{;						
								{"CompanyId"				, ""										},;
								{"BranchId"					, "C5_FILIAL"								},;
								{"CompanyInternalId"		, "Exp:cEmpAnt, C5_FILIAL, C5_NUM"			},;	
								{"SalesType"		        , "C5_TIPO"									},;
								{"CustomerId"		        , "C5_CLIENTE"								},;
								{"CustomerUnit"		        , "C5_LOJACLI"								},;
								{"CustomerIdDelivery"		, "C5_CLIENT"								},;
								{"CustomerUnitDelivery"		, "C5_LOJAENT"								},;
		   						{"CustomerType"				, "C5_TIPOCLI"								},;
								{"Payment"		    	    , "C5_CONDPAG"								},;
								{"DiscountPercentage1"		, "C5_DESC1"								},;
								{"DiscountPercentage2"		, "C5_DESC2"								},;
								{"DiscountPercentage3"		, "C5_DESC3"								},;
								{"DiscountPercentage4"		, "C5_DESC4"								},;
								{"Currency"					, "C5_MOEDA"								},;
								{"Freight"					, "C5_FRETE"								},;
								{"Insurance"				, "C5_SEGURO"								},;
								{"Expense"					, "C5_DESPESA"								};
							};
						}

	aStructGrid :=      { "SC6", "ITEM", "ListofProducts", "ListofProducts",;
							{;
								{"CompanyId"							, ""													},;
								{"BranchId"								, "C6_FILIAL"											},;
								{"CompanyInternalId"					, "Exp:cEmpAnt, C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO"	},;
								{"ItemId"    						    , "C6_ITEM"												},;
								{"ProductId"     						, "C6_PRODUTO"								   			},;
								{"Quantity"		     					, "C6_QTDVEN"											},;
								{"UnitaryValue"		     	    		, "C6_PRCVEN"											},;
								{"PriceList"		     				, "C6_PRUNIT"											},;
								{"TES"			     					, "C6_TES"									   			},;
								{"ItemDiscountPercentage"		    	, "C6_DESCONT"											},;
								{"ItemDiscountValue"		     		, "C6_VALDESC"											},;
								{"OperationType"		     		    , "C6_OPER"												};
							};
						}
						//Retiramos a TAG TotalValue C6_VALOR, pois aprensentava falha na ExecAuto em conjunto com o campo C6_PRUNIT.Obs: O campo C6_PRUNIT já gatilha os valores para C6_VALOR. 
	aStructAlias  := {aStrSC5Pai,aStructGrid}

	apiMap := {"matsimp","items","1.000","MATSIMP",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} ManutSC5
Realiza a chamada simulada (inclusão/alteração) do Pedido de Venda

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do Pedido de Venda (C5_NUM)
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody       	, Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author	Squad Faturamento/CRM
@since		04/12/2020
@version	12.1.21
/*/

Static Function ManutSC5(oApiManager, aQueryString, nOpc, aJson, cChave, oJson, cBody)
                
	Local   aCabPedido   := {}
	Local   aItem		 := {}
	Local   aProds		 := {}
	Local   aMsgErro     := {}			
	Local   cResp	     := ""
	Local   lRet         := .T.
	Local   nX           := 0
	Local 	nTamItm		 := 0
	Local 	nTamErr		 := 0

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Default aJson			:= {}
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

	If Empty(cChave)
   		aJson := oApiManager:ToArray(cBody)
		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabPedido)
			aAdd(aCabPedido,{"C5_NUM",     GetSxeNum("SC5", "C5_NUM"),      Nil})
			aCabPedido := FWVetByDic(aCabPedido,"SC5",.F.)
		EndIf
		
		If Len(aJson[1][2]) > 0
			nTamItm	:= Len(aJson[1][2])
			For nX := 1 To nTamItm
				aItem := {}
				oApiManager:ToExecAuto(1, aJson[1][2][nX][1][2], aItem)
				aAdd(aProds,aItem)
			Next
			aProds := FWVetByDic(aProds,"SC6",.T.)
		EndIf
	Else
		aadd(aCabPedido, {"C5_NUM",     cChave,      Nil})
	EndIf

    If lRet
		MSExecAuto({|a, b, c, d, e| MATA410(a, b, c, d, e)}, aCabPedido, aProds, nOpc, .F.)
		If lMsErroAuto
			aMsgErro := GetAutoGRLog()
			cResp	 := ""
			nTamErr	 := Len(aMsgErro)
			For nX := 1 To nTamErr
				cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ")
			Next nX	
			lRet := .F.
		EndIf
		RollBackSX8()
	EndIf

    aSize(aMsgErro,0)
    aSize(aCabPedido,0)
	aSize(aProds,0)
	aSize(aItem,0)

Return {lRet,cResp}

//----------------------------------------------------------------------------
/*/{Protheus.doc} checkDbUseArea
	Verifica se o Protheus não está executando o REFAZ EMPENHOS(MATA215) e se as tabelas estão sendo processadas em modo exclusivo.
	@type function
	@version 12.1.33
	@author Eduardo Paro / Squad CRM & Faturamento
	@since 26/09/2022
	@return logico
/*/
//----------------------------------------------------------------------------
Static Function checkDbUseArea(lRet)
	Local cLock := "LOCK"
	Default lRet := .F.

	DBUseArea(.F., 'TOPCONN', RetSQLName("SB1"), cLock, .T., .F.)
	IF Select(cLock) > 0
		lRet:= .T.
		(cLock)->(dbCloseArea())
	Else
		SetRestFault(503, FWhttpEncode(STR0007))//'As tabelas necessarias para acessar essa rotina estão sendo processadas em modo exclusivo no Protheus'
		lRet:= .F.
	EndIf

Return lRet
