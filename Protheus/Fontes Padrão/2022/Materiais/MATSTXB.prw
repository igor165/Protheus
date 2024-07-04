#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MATSTXB.CH"

/*/{Protheus.doc} BudgetsTaxes
API de consulta de Tributos de Orcamentos
Definido nome da classe "BudgetsTaxes" devido EndPoint 

@author		Squad Faturamento/CRM
@since		20/04/2022
@version	12.1.33
/*/

WSRESTFUL BudgetsTaxes DESCRIPTION STR0001  // #"Consulta de Valores e Tributos em Orçamentos" 

	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
    WSDATA Page				AS INTEGER	OPTIONAL
    WSDATA PageSize			AS INTEGER	OPTIONAL
    WSDATA BudgetId		    AS STRING	OPTIONAL

	//---------------------------------------------------------------------
    WSMETHOD GET BudgetsTaxes ;
    DESCRIPTION STR0002	; // #"Retorna os impostos de um orcamento já cadastrado"
    WSSYNTAX "/api/fat/v1/BudgetsTaxes/{BudgetId}{Order, Page, PageSize, Fields}" ;
    PATH     "/api/fat/v1/BudgetsTaxes/{BudgetId}"

	WSMETHOD POST BudgetsTaxes ;
    DESCRIPTION STR0003 ; // #"Retorna os impostos de uma simulação de orçamento"
    WSSYNTAX "/api/fat/v1/BudgetsTaxes/{Fields}";
    PATH "/api/fat/v1/BudgetsTaxes"
    //---------------------------------------------------------------------

ENDWSRESTFUL

/*/{Protheus.doc} GET / BudgetsTaxes/{BudetsId}
Retorna os Tributos de um Orcamento específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		20/04/2022
@version	12.1.33
/*/

WSMETHOD GET BudgetsTaxes PATHPARAM BudgetId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE BudgetsTaxes

	Local cError		:= ""
	Local lRet 			:= .T.
	Local cCode			:= ""
	Local aJson			:= {}
	Local cBody 	  	:= Self:GetContent()
	Local oJson			:= JsonObject():New()
	Local aRetMnt		:= {}   

	Private oApiManager	:= Nil

    Self:SetContentType("application/json")
	
	oApiManager := FWAPIManager():New("MATSTXB","1.000")
	oApiManager:SetApiAlias({"SCJ","items", "items"})
	oApiManager:Activate()
	
	If checkDbUseArea(@lRet)
		cCode := Self:BudgetId
	
		If  Len(cCode) <> TamSX3("CJ_NUM")[1]
			lRet := .F.
    		oApiManager:SetJsonError("400",STR0004 /*#"Erro na requisição de Impostos do Orçamento!"*/, STR0005 /*#"O código do Orçamento não condiz com os registros requisitados"*/,/*cHelpUrl*/,/*aDetails*/)
    	EndIf

		If lRet	
			aRetMnt := ManutSCJ(@oApiManager, Self:aQueryString, 4, aJson, cCode, oJson, cBody)
			If !aRetMnt[1]
				oApiManager:SetJsonError("404",STR0004 /*#"Erro na requisição de Impostos do Orçamento!"*/, aRetMnt[2],/*cHelpUrl*/,/*aDetails*/)
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
/*/{Protheus.doc} POST /BudgetsTaxes/
Simula um Orçamento para retornar seus Tributos

@param	Fields	, caracter, campos que compõe o Orçamento.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		20/04/2022
@version	12.1.33
/*/
//--------------------------------------------------------------------

WSMETHOD POST BudgetsTaxes WSRECEIVE Order, Page, PageSize, Fields WSSERVICE BudgetsTaxes

	Local aJson       	:= {}
	Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oJson			:= JsonObject():New()
	Local aRetMnt		:= {}  
	
	Private oApiManager	:= FWAPIManager():New("MATSTXB","1.000")

    Self:SetContentType("application/json")

   	oApiManager:SetApiAlias({"SCJ","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If checkDbUseArea(@lRet)
		lRet = FWJsonDeserialize(cBody,@oJson)

    	If lRet
    	    aRetMnt := ManutSCJ(@oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
			If !aRetMnt[1]
				oApiManager:SetJsonError("400",STR0004 /*#"Erro na requisição de Impostos do Orçamento!"*/, aRetMnt[2],/*cHelpUrl*/,/*aDetails*/)
				lRet := .F.
			EndIf
    	Else        
    	    oApiManager:SetJsonError("400",STR0004 /*#"Erro na requisição de Impostos do Orçamento!"*/, STR0006 /*#"Não foi possível tratar o Json recebido."*/,/*cHelpUrl*/,/*aDetails*/)
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
@since		20/04/2022
@version	12.1.27
/*/

Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"SCK", "ListofProducts"      , "ListofProducts"  	}
    Local aFatherSCJ	:=	{"SCJ", "items"                , "items"       		}        
    Local aRelation     :=  {}
	Local cIndexKey		:=  "CK_FILIAL, CK_NUM"

    aAdd(aRelation,{"CJ_FILIAL"	,"CK_FILIAL"   	})
    aAdd(aRelation,{"CJ_NUM"  	,"CK_NUM"   	})

	oApiManager:SetApiRelation(aChildren, aFatherSCJ, aRelation, cIndexKey)

Return Nil

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		20/04/2022
@version	12.1.33
/*/
Static Function ApiMap()

	Local apiMap		:= {}
	Local aStrSCJPai    := {}
	Local aStructGrid   := {}
	Local aStructAlias  := {}

	aStrSCJPai :=			{"SCJ","Field","items","items",;
							{;						
								{"CustomerId"		        , "CJ_CLIENTE"								},;
								{"CustomerUnit"		        , "CJ_LOJA"									},;
								{"CustomerIdDelivery"		, "CJ_CLIENT"								},;
								{"CustomerUnitDelivery"		, "CJ_LOJAENT"								},;
								{"Payment"		    	    , "CJ_CONDPAG"								},;
								{"DiscountPercentage1"		, "CJ_DESC1"								},;
								{"DiscountPercentage2"		, "CJ_DESC2"								},;
								{"DiscountPercentage3"		, "CJ_DESC3"								},;
								{"DiscountPercentage4"		, "CJ_DESC4"								},;
								{"Currency"					, "CJ_MOEDA"								},;
								{"Freight"					, "CJ_FRETE"								},;
								{"Insurance"				, "CJ_SEGURO"								},;
								{"Expense"					, "CJ_DESPESA"								};
							};
						}

	aStructGrid :=      { "SCK", "ITEM", "ListofProducts", "ListofProducts",;
							{;
								{"ItemId"    						    , "CK_ITEM"										},;
								{"ProductId"     						, "CK_PRODUTO"								   	},;
								{"Quantity"		     					, "CK_QTDVEN"									},;
								{"UnitaryValue"		     	    		, "CK_PRUNIT"									},;
								{"TES"			     					, "CK_TES"									    },;
								{"ItemDiscountPercentage"		    	, "CK_DESCONT"									},;
								{"ItemDiscountValue"		     		, "CK_VALDESC"									},;
								{"OperationType"		     		    , "CK_OPER"										},;
								{"SaleValue"		     	    		, "CK_PRCVEN"									},;
								{"TotalValue"		     	    		, "CK_VALOR"									};
							};
						}
	aStructAlias  := {aStrSCJPai,aStructGrid}

	apiMap := {"matstxb","items","1.000","MATSTXB",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} ManutSCJ
Realiza a chamada simulada (inclusão/alteração) do Orçamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do Orçamento (CJ_NUM)
@param oJson		, Objeto	, Objeto com Json parseado
@param cBody       	, Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author	Squad Faturamento/CRM
@since		20/04/2022
@version	12.1.33
/*/

Static Function ManutSCJ(oApiManager, aQueryString, nOpc, aJson, cChave, oJson, cBody)
                
	Local   aCabOrcam    := {}
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
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabOrcam)
			aAdd(aCabOrcam,{"CJ_NUM",     GetSxeNum("SCJ", "CJ_NUM"),      Nil})
			aCabOrcam := FWVetByDic(aCabOrcam,"SCJ",.F.)
		EndIf
		
		If Len(aJson[1][2]) > 0
			nTamItm	:= Len(aJson[1][2])
			For nX := 1 To nTamItm
				aItem := {}
				oApiManager:ToExecAuto(1, aJson[1][2][nX][1][2], aItem)
				aAdd(aProds,aItem)
			Next
			aProds := FWVetByDic(aProds,"SCK",.T.)
		EndIf
	Else
		aadd(aCabOrcam, {"CJ_NUM",     cChave,      Nil})
		DbSelectArea("SCJ")
		SCJ->(DbSetOrder(1)) // CJ_FILIAL, CJ_NUM, CJ_CLIENTE, CJ_LOJA
		SCJ->(DbSeek(xFilial("SCJ")  + cChave))
	EndIf

    If lRet
		MSExecAuto({|a, b, c, d, e| MATA415(a, b, c, d, e)}, aCabOrcam, aProds, nOpc, .F.)
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
    aSize(aCabOrcam,0)
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
	Local cLock  := "LOCK"
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