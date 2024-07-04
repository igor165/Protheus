#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function OMSS010()
Return

/*/{Protheus.doc} PriceListHeaderItems

API de integração de tabelas de Preço

@author		Squad Faturamento/SRM
@since		02/08/2018
/*/
WSRESTFUL PriceListHeaderItems DESCRIPTION "Tabela de Preços de Venda" //"Tabela de Preços de Venda"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
	WSDATA ItemList 		AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todas as tabelas de preço" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Order, Page, PageSize, Fields}" ;
    PATH "/api/supply/v2/PriceListHeaderItems"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra uma nova tabela de preço" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/" ;
    PATH "/api/supply/v2/PriceListHeaderItems"

	WSMETHOD GET MainHeaderOnly;
    DESCRIPTION "Carrega todas as tabelas de preços, apenas cabeçalho" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/HeaderOnly/{Order, Page, PageSize, Fields}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/HeaderOnly"


    WSMETHOD GET TableID ;
    DESCRIPTION "Carrega uma tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}"

    WSMETHOD PUT TableID ;
    DESCRIPTION "Altera uma tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}"
    
    WSMETHOD DELETE TableID ;
    DESCRIPTION "Deleta uma tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}"    
    	
    WSMETHOD GET itensTablePrice ;
    DESCRIPTION "Carrega os itens da tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{Order, Page, PageSize, Fields, ItemList}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice"
    
    WSMETHOD POST itensTablePrice ;
    DESCRIPTION "Carrega os itens da tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice"    
    
    WSMETHOD GET ItemID ;
    DESCRIPTION "Carrega os itens da tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{Order, Page, PageSize, Fields, ItemList}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{ItemList}"	
    
    WSMETHOD PUT ItemID ;
    DESCRIPTION "Carrega os itens da tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{ItemList}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{ItemList}"    
    
    WSMETHOD DELETE ItemID ;
    DESCRIPTION "Carrega os itens da tabela de preço específica" ;
    WSSYNTAX "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{ItemList}" ;
    PATH "/api/supply/v2/PriceListHeaderItems/{Code}/itensTablePrice/{ItemList}"        
ENDWSRESTFUL

/*/{Protheus.doc} GET / PriceListHeaderItems/pricelist
Retorna todas as tabelas de preços cadastradas

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE PriceListHeaderItems

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("omss010","2.001") 
	
	DefRelation(@oApiManager)

	lRet := GetMain(@oApiManager, Self:aQueryString)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	FreeObj(oApiManager)

Return lRet

/*/{Protheus.doc} GET / PriceListHeaderItems/pricelist/HeaderOnly
Retorna todas as tabelas de preços cadastradas, apenas cabeçalho.

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Alessandro Afonso
@since		11/02/2022
@version	12.1.20
/*/

WSMETHOD GET MainHeaderOnly WSRECEIVE Order, Page, PageSize, Fields WSSERVICE PriceListHeaderItems

	Local cError			:= ""
	Local lRet				:= .T.
	Local oCoreDash		    := CoreDash():New()
	
    Self:SetContentType("application/json")
	If Len(Self:aQueryString) == 0
    	oCoreDash:SetPageSize(500)
	 Endif

 	GetMainHeader(@oCoreDash, Self:aQueryString)

	Self:SetResponse( oCoreDash:ToObjectJson() )
	
	FreeObj(oCoreDash)

Return lRet

/*/{Protheus.doc} POST/ PriceListHeaderItems
Inclui uma nova tabela de preço

@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD POST Main WSSERVICE PriceListHeaderItems
	Local aQueryString	:= Self:aQueryString
	Local aJson			:= {}
	Local aFatherAlias	:= {"DA0","items","items"}
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("omss010","2.001")
	Local oJson			:= Nil
    
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()
    
	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate()

	If !oApiManager:IsActive()
		lRet := .F.
	Else
		lRet = FWJsonDeserialize(cBody,@oJson)
		If lRet
			lRet := GravaTab(oApiManager, aQueryString, 3,, oJson, cBody)
			aJson := oApiManager:GetJsonArray(cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("400","Erro ao Incluir Tabela de Preço!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)			
		EndIf
		
		If lRet
			aAdd(aQueryString,{"Code",DA0->DA0_CODTAB})
			lRet := GetMain(@oApiManager, aQueryString, .F.)
		EndIf

		If lRet
			Self:SetResponse( oApiManager:ToObjectJson() )
		Else
			cError := oApiManager:GetJsonError()
			SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
		EndIf
	EndIf

	FreeObj( oApiManager )
	FreeObj( aFatherAlias )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} GET / PriceListHeaderItems/pricelist/{tableid}
Retorna uma tabela de preço específica

@param	Code	, caracter, Código da tabela de preço
@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET tableid PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE PriceListHeaderItems

	Local aFilter			:= {}
	Local aQueryString		:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("omss010","2.001") 

	Aadd(aFilter, {"DA0", "items",{"DA0_CODTAB = '" + Self:Code + "'"}})
	oApiManager:SetApiFilter(aFilter) 	
	
	DefRelation(@oApiManager)

	lRet := GetMain(@oApiManager, Self:aQueryString)

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	FreeObj( oApiManager )
	FreeObj( aFilter )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} PUT / PriceListHeaderItems/{TableID}
Altera dados da tabela de preço

@param	Code	, caracter, Código da tabela de preço

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD PUT TableID PATHPARAM Code WSSERVICE PriceListHeaderItems
	Local aQueryString	:= {}
	Local aJson			:= {}
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("omss010","2.001")
	Local oJson			:= Nil
    
    Default Self:Code := ""
    
	If Empty(Self:Code) .Or. !(DA0->(DbSeek(xFilial("DA0") + Self:Code)))
		lRet := .F.
		oApiManager:SetJsonError("404","Registro não encontrado!", "Informe o código da tabela.",/*cHelpUrl*/,/*aDetails*/)
	EndIf    
    
	If lRet
		cBody 	   := Self:GetContent()

		oApiManager:SetApiQstring(Self:aQueryString)
		oApiManager:Activate()

		If oApiManager:IsActive()
			oApiManager:SetApiMap(ApiMapDA0())
			lRet = FWJsonDeserialize(cBody,@oJson)
			If lRet
				lRet := GravaTab(oApiManager, aQueryString, 4,, oJson, cBody)
				aJson := oApiManager:GetJsonArray(cBody)
			Else
				lRet := .F.
				oApiManager:SetJsonError("400","Erro ao Alterar a Tabela de Preço!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)			
			EndIf
		EndIf
	EndIf

	If lRet
		aAdd(aQueryString,{"code", Self:Code})
		lRet := GetMain(@oApiManager, aQueryString, .F.)
	EndIf

    If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    FreeObj( oApiManager )
	FreeObj( aQueryString )
	
Return lRet

/*/{Protheus.doc} DELETE / PriceListHeaderItems/{TableID}
Deleta uma tabela de preço

@param	Code	, caracter, Código da tabela de preço

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD DELETE TableID PATHPARAM Code WSSERVICE PriceListHeaderItems
    Local lRet				:= .T.
	Local aMsgErro			:= {}
	Local cError			:= ""
    Local cResp				:= "Registro Deletado com Sucesso!"
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
	Local oModel 		:= Nil 
	Local oModelDA0		:= Nil
	Local oModelDA1		:= Nil	
	Local oApiManager 	:= FWAPIManager():New("omss010","2.001")
    
   	Private	lAutoOMS010 := .T.
    
    Default Self:Code := ""

    cBody 	   := Self:GetContent()
    
    If lRet
	    If DA0->(DbSeek(xFilial("DA0") + Self:Code))
			oModel 	:= FwLoadModel( 'OMSA010' )
			oModel:SetOperation(5)
			oModel:Activate()
				
			oModelDA0 := oModel:GetModel('DA0MASTER')	//Model parcial Master (DA0)
			oModelDA1 := oModel:GetModel('DA1DETAIL')	//Model parcial Detail (DA1)
			
			If oModel:IsActive()
				If !oModel:VldData()
					lRet := .F.
					aMsgErro := oModel:GetErrorMessage()
					cError := ''
					
					For nX := 1 To Len(aMsgErro)
					
						If ( ValType( aMsgErro[nX] ) == 'C' )
							cError += aMsgErro[nX] + '|'
						EndIf 
						
					Next nX
					
					oApiManager:SetJsonError("400","Erro durante a exclusão da tabela de preço!",cError,/*cHelpUrl*/,/*aDetails*/)
				Else
					oModel:CommitData()
				EndIf
			EndIf
	    Else
			lRet := .F.
	    	oApiManager:SetJsonError("404","Erro durante a exclusão da tabela de preço!!","Tabela não encontrada",/*cHelpUrl*/,/*aDetails*/)
	    EndIf
    EndIf

	If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    FreeObj( oJsonPositions )
    FreeObj( oApiManager )
	FreeObj( aMsgErro )
	FreeObj( oModel )
	FreeObj( oModelDA0 )
	FreeObj( oModelDA1 )

Return lRet

/*/{Protheus.doc} GET / PriceListHeaderItems/pricelist/{tableid}/itensTablePrice
Retorna os itens da tabela de preço

@param	Code	, caracter, Código da tabela de preço
@param	ItemList	, caracter, Código do item da tabela de preço
@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET itensTablePrice PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE PriceListHeaderItems

	Local aApiMap			:= ApiMapDA1()
	Local aFilter			:= {}
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("omss010","2.001")
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")
    
	Aadd(aFilter, {"DA1", "items",{"DA1_CODTAB = '" + Self:Code + "'"}})
	oApiManager:SetApiFilter(aFilter) 	

	If lRet
		lRet := GetItens(@oApiManager, Self:aQueryString)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	FreeObj(oApiManager)
	FreeObj(aApiMap)
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} GET / PriceListHeaderItems/pricelist/{tableid}/itensTablePrice/{ItemID}
Retorna os itens da tabela de preço

@param	Code	, caracter, Código da tabela de preço
@param	ItemList	, caracter, Código do item da tabela de preço
@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET ItemID PATHPARAM Code, ItemList WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE PriceListHeaderItems

	Local aApiMap			:= ApiMapDA1()
	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("omss010","2.001")
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")
    
	Aadd(aFilter, {"DA1", "items",{"DA1_CODTAB = '" + Self:Code + "'"}})
	Aadd(aFilter, {"DA1", "items",{"DA1_ITEM = '" + Self:ItemList + "'"}})

	oApiManager:SetApiFilter(aFilter) 	

	If lRet
		lRet := GetItens(@oApiManager, Self:aQueryString)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	FreeObj(oApiManager)
	FreeObj(aApiMap)
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT / PriceListHeaderItems/pricelist/{tableid}/itensTablePrice/{ItemID}
Altera um item da tabela de preço

@param	Code	, caracter, Código da tabela de preço
@param	ItemList	, caracter, Código do item da tabela de preço

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD PUT ItemID PATHPARAM Code, ItemList WSRECEIVE Fields WSSERVICE PriceListHeaderItems
	Local aApiMap		:= ApiMapDA1()
	Local aFilter		:= {}
	Local aQueryString	:= {}
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("omss010","2.001")
    
    Default Self:Code 	:= ""
    Default Self:ItemList		:= ""
	
	Aadd(aFilter, {"DA1", "items",{"DA1_CODTAB = '" + Self:Code + "'"}})
	Aadd(aFilter, {"DA1", "items",{"DA1_ITEM = '" + Self:ItemList + "'"}})
	oApiManager:SetApiFilter(aFilter)

	oApiManager:SetApiMap(aApiMap)

	If lRet
		oApiManager:SetApiQstring(Self:aQueryString)
		oApiManager:Activate()
		IF !oApiManager:IsActive()
			lRet := .F.
		Else
			cBody 	   := Self:GetContent()
			lRet := GravaItem(Self:Code, 4, @oApiManager, cBody)
		EndIf
	EndIf

	If lRet
		lRet := GetItens(@oApiManager, Self:aQueryString, .F.)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson())
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	FreeObj( aApiMap )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} POST / PriceListHeaderItems/pricelist/{tableid}/itensTablePrice
Incluir um item na tabela de preço

@param	Code	, caracter, Código da tabela de preço

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD POST itensTablePrice PATHPARAM Code WSSERVICE PriceListHeaderItems
	Local aApiMap		:= ApiMapDA1()
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("omss010","2.001")

	oApiManager:SetApiMap(aApiMap)

    Default Self:Code 	:= ""
    
	If lRet
		oApiManager:SetApiQstring(Self:aQueryString)
		oApiManager:Activate()
		If !oApiManager:IsActive()
			lRet := .F.
		Else
			cBody 	   := Self:GetContent()
			lRet := GravaItem(Self:Code, 3, @oApiManager, cBody)
		EndIf
	EndIf

	If lRet
		aAdd(aQueryString,{"code", Self:Code})
			aAdd(aQueryString,{"itemList"	, DA1->DA1_ITEM})

		lRet := GetItens(@oApiManager, aQueryString, .F.)
	EndIf	

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
    FreeObj( aApiMap )
	FreeObj( aQueryString )
		
Return lRet


/*/{Protheus.doc} DELETE / PriceListHeaderItems/pricelist/{tableid}/itensTablePrice/{ItemID}
Deleta um item da tabela de preço

@param	Code	, caracter, Código da tabela de preço
@param	ItemList	, caracter, Código do item da tabela de preço

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD DELETE ItemID PATHPARAM Code, ItemList WSRECEIVE ItemList WSSERVICE PriceListHeaderItems
    Local aBusca			:= {}
	Local aMsgErro			:= {}
	Local cResp			 	:= "Operação Realizada com Sucesso"
    Local lRet			 	:= .T.
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
	Local oModel 		:= Nil 
	Local oModelDA0		:= Nil
	Local oModelDA1		:= Nil
	Local oApiManager 		:= FWAPIManager():New("omss010","2.001")
    
   	Private	lAutoOMS010 := .T.
    
    Default Self:Code 	:= ""
    Default Self:ItemList 		:= ""

    cBody 	   := Self:GetContent()
    
    If lRet
	    If DA0->(DbSeek(xFilial("DA0") + Self:Code))
			oModel 	:= FwLoadModel( 'OMSA010' )
			oModel:SetOperation(4)
			oModel:Activate()

			If oModel:IsActive()	
				oModelDA0 := oModel:GetModel('DA0MASTER')	//Model parcial Master (DA0)
				oModelDA1 := oModel:GetModel('DA1DETAIL')	//Model parcial Detail (DA1)
				
				aBusca := {}
				aAdd( aBusca, { 'DA1_CODTAB', DA0->DA0_CODTAB 	} )	
				aAdd( aBusca, { 'DA1_ITEM'	, Self:ItemList		} )					

				If (oModelDA1:SeekLine( aBusca ))
					If !oModelDA1:DeleteLine() .Or. !oModel:VldData()
						lRet := .F.
						aMsgErro := oModel:GetErrorMessage()
						cError := ''
						
						For nX := 1 To Len(aMsgErro)
						
							If ( ValType( aMsgErro[nX] ) == 'C' )
								cError += aMsgErro[nX] + '|'
							EndIf 
							
						Next nX
						
						oApiManager:SetJsonError("400","Erro durante a exclusão da tabela de preço!",cError,/*cHelpUrl*/,/*aDetails*/)
					Else
						oModel:CommitData()
					EndIf
				Else
					lRet := .F.
					oApiManager:SetJsonError("404","Erro durante a exclusão da tabela de preço!!","Item da Tabela não encontrado",/*cHelpUrl*/,/*aDetails*/)
				EndIf
			EndIf
	    Else
			lRet := .F.
	    	oApiManager:SetJsonError("404","Erro durante a exclusão da tabela de preço!!","Tabela não encontrada",/*cHelpUrl*/,/*aDetails*/)
	    EndIf
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
	FreeObj( aBusca )
	FreeObj( aMsgErro )
	FreeObj( oModel )
	FreeObj( oModelDA0 )
	FreeObj( oModelDA1 )

Return lRet

/*/{Protheus.doc} GravaTab
Realiza manutenção na tabela de preço.

@param	aCab		, array		, Dados do cabeçalho da tabela de preço
@param	aItens		, array		, Dados dos itens da tabela de preço
@param	nOper		, numérico	, Operação realizada (Inlusão/Alteração)
@param	cCodTab		, caracter	, Código da tabela de preço
@param	oApiManager	, objeto , Objeto ApiManager

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function GravaTab(oApiManager, aQueryString, nOpcx, cChave, oJson, cBody)
	Local oModel 		:= Nil 
	Local oModelDA0		:= Nil
	Local oModelDA1		:= Nil
	Local aBusca 		:= {}
	Local aMsgErro		:= {}
	Local cNewItem 		:= '0001'
	Local cResp			:= ""
	Local lRet			:= .T.
	Local nPosItem		:= 0
	Local aCabec		:= {}
	Local aItens		:= {}
	Local nLenaItnX		:= 0
	Local nX			:= 0
	Local nY			:= 0
	
	Private	lAutoOMS010 := .T.

	DefRelation(@oApiManager)

	oModel 	:= FwLoadModel( 'OMSA010' )

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

	oModel:Activate()
		
	oModelDA0 := oModel:GetModel('DA0MASTER')	//Model parcial Master (DA0)
	oModelDA1 := oModel:GetModel('DA1DETAIL')	//Model parcial Detail (DA1)
	
	nLenaCab := Len(aCabec)
	For nX := 1 To nLenaCab
		If oModelDA0:CanSetValue(aCabec[nX][1])//Verifica os campos que não podem ser editados
			oModelDA0:SetValue( aCabec[nX][1], aCabec[nX][2] )
		EndIf
	Next

	nLenaItens := Len(aItens)
	For nX := 1 To nLenaItens
		nPosItem 	:= aScan( aItens[nX], { |x| x[1] == 'DA1_ITEM' } )	//Posicao do Cod. Produto no array
		If nOpcx == MODEL_OPERATION_UPDATE
			If nPosItem > 0
				aBusca := {}
				aAdd( aBusca, { 'DA1_CODTAB', DA0->DA0_CODTAB } )	
				aAdd( aBusca, { 'DA1_ITEM', aItens[nX][nPosItem][2] } )	
				If !(oModelDA1:SeekLine( aBusca ))
					lRet := .F. 
					oApiManager:SetJsonError("400","Não foi possível realizar alterar o item na tabela!","Item: " + AllTrim(aItens[nX][nPosItem][2]) + "não encontrado",/*cHelpUrl*/,/*aDetails*/)
					Exit
				EndIf
			EndIf
		Else
			If nX > 1 
				nAux := oModelDA1:Length()
				If ( !oModelDA1:AddLine() == nAux + 1 )
						lRet := .F. 
						oApiManager:SetJsonError("400","Não foi possível realizar incluir um novo item na tabela!","Item: " + AllTrim(Str(nAux)),/*cHelpUrl*/,/*aDetails*/)
						Exit
				EndIf			
			EndIf

			If nPosItem <= 0
				If oModelDA1:CanSetValue("DA1_ITEM")
					lRet := oModelDA1:SetValue( "DA1_ITEM", cNewItem )
					cNewItem := Soma1(cNewItem)
				EndIf							
			EndIf
		EndIf

		nLenaItnX := Len(aItens[nX])	
		
		For nY := 1 To nLenaItnX
			If oModelDA1:CanSetValue(aItens[nX][nY][1])
				oModelDA1:SetValue( aItens[nX][nY][1], aItens[nX][nY][2] )
			EndIf
		Next
		aBusca := Nil
	Next	

	If lRet .And. oModel:VldData()
		oModel:CommitData()
	Else
		lRet := .F.
		aMsgErro := oModel:GetErrorMessage()
		cResp := ''
		
		For nX := 1 To Len(aMsgErro)
		
			If ( ValType( aMsgErro[nX] ) == 'C' )
				cResp += aMsgErro[nX] + '|'
			EndIf 
			
		Next nX
		
		oApiManager:SetJsonError("400","Erro ao alterar a tabela de preço!", cResp,/*cHelpUrl*/,/*aDetails*/)
	EndIf	

Return lRet

/*/{Protheus.doc} GravaItem
Realiza manutenção nos itens da tabela de preço.

@param	aItens		, array		, Dados dos itens da tabela de preço
@param	cResp		, caracter	, Retorno da operação
@param	cCodTab		, caracter	, Código da tabela de preço
@param	nTipo		, caracter	, Informa se é uma inclusão ou alteração de item
@param oApiManager	, object	, Objeto ApiManager

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function GravaItem(cCodTab, nOpcx, oApiManager, cBody)
	Local aBusca		:= {}
	Local aItens		:= {}
	Local aMsgErro		:= {}
	Local cNewItem		:= ""
	Local lRet			:= .T.
	Local nPosItem		:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local oModel 		:= Nil 
	Local oModelDA0		:= Nil
	Local oModelDA1		:= Nil
	Local aCabec		:= {}

	Default aItens		:= {}
	Default cResp		:= ""
	Default cCodTab		:= ""
	Default nTipo		:= 4

	Private	lAutoOMS010 := .T.
	
	If DA0->(DbSeek(xFilial("DA0") + cCodTab))
	
		oModel 	:= FwLoadModel( 'OMSA010' )
		oModel:SetOperation(nOpcx)
			
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabec)
		EndIf

		oModel:SetOperation(MODEL_OPERATION_UPDATE)

		oModel:Activate()

		oModelDA0 := oModel:GetModel('DA0MASTER')	//Model parcial Master (DA0)
		oModelDA1 := oModel:GetModel('DA1DETAIL')	//Model parcial Detail (DA1)
	
		aAdd(aItens, aCabec)

		If Len(aItens) == 1
			nPosItem 	:= aScan( aItens[01], { |x| x[01] == 'DA1_ITEM' } )	//Posicao do Cod. Produto no array
			If nOpcx == 4 .And. nPosItem > 0
				aBusca := {}
				aAdd( aBusca, { 'DA1_CODTAB', DA0->DA0_CODTAB } )	
				aAdd( aBusca, { 'DA1_ITEM', aItens[01][nPosItem][2] } )	
				If !(oModelDA1:SeekLine( aBusca ))
					lRet	:= .F.
					oApiManager:SetJsonError("404","Erro durante a alteração da tabela de preço!!","Item " + aItens[01][nPosItem][2] + "não encontrado",/*cHelpUrl*/,/*aDetails*/)
				EndIf
			Else 
				nAux := oModelDA1:Length()
				If oModelDA1:GoLine(nAux)
					cNewItem := Soma1(oModelDA1:GetValue("DA1_ITEM"))
					If ( !oModelDA1:AddLine() == nAux + 1 )
						lRet	:= .F.
						oApiManager:SetJsonError("404","Erro durante a alteração da tabela de preço!!","Problema ao editar o item " + aItens[01][nPosItem][2],/*cHelpUrl*/,/*aDetails*/)
					EndIf

					If oModelDA1:CanSetValue("DA1_ITEM")
						lRet := oModelDA1:SetValue( "DA1_ITEM", cNewItem )
					EndIf					
				EndIf
			EndIf

			For nY := 1 To Len(aItens[01])
				If AllTrim(aItens[01][nY][1]) != "DA1_CODTAB"
					If oModelDA1:CanSetValue(aItens[01][nY][1])
						lRet := oModelDA1:SetValue( aItens[01][nY][1], aItens[01][nY][2] )
					EndIf
				EndIf
			Next
			
			If lRet .And. oModel:VldData()
				oModel:CommitData()
			Else
				lRet := .F.
				aMsgErro := oModel:GetErrorMessage()
				cResp := ''
				
				For nX := 1 To Len(aMsgErro)
				
					If ( ValType( aMsgErro[nX] ) == 'C' )
						cResp += aMsgErro[nX] + '|'
					EndIf 
					
				Next nX
				oApiManager:SetJsonError("400","Erro durante a alteração da tabela de preço!!",cResp,/*cHelpUrl*/,/*aDetails*/)	
			EndIf
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro durante a alteração da tabela de preço!!","Tabela não encontrado",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro durante a alteração da tabela de preço!!","Só é possível incluir/alterar um item",/*cHelpUrl*/,/*aDetails*/)	
	EndIf

	FreeObj( aBusca )
	FreeObj( aMsgErro )
	FreeObj( oModel )
	FreeObj( oModelDA0 )
	FreeObj( oModelDA1 )	
Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get considerando cabeçalho e filho (DA0 e DA1)

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function GetMain(oApiManager, aQueryString, lHasNext)
	Local aChildrenAlias	:= {"DA1", "itensTablePrices", "itensTablePrices"}
	Local aFatherAlias		:= {"DA0", "items", "items"}
	Local cIndexKey			:= "DA1_FILIAL, DA1_CODTAB, DA1_ITEM"
    Local lRet 				:= .T.

	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} GetItens
Realiza o Get considerando o filho (DA1)

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function GetItens(oApiManager, aQueryString, lHasNext)
	Local aApiMap			:= ApiMapDA1()
	Local aFatherAlias		:= {"DA1","items", "items"}
    Local lRet 				:= .T.

	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.
	
	oApiManager:SetApiMap(aApiMap)
	oApiManager:SetApiAlias(aFatherAlias)

	lRet := ApiMainGet(@oApiManager, aQueryString, , , aFatherAlias, , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aApiMap )
	FreeObj( aFatherAlias )

Return lRet

Static Function DefRelation(oApiManager)
	Local aRelation 		:= {{"DA0_FILIAL","DA1_FILIAL"},{"DA0_CODTAB","DA1_CODTAB"}}
	Local aChildrenAlias	:= {"DA1", "itensTablePrices", "itensTablePrices"}
	Local aFatherAlias		:= {"DA0", "items", "items"}
	Local cIndexKey			:= "DA1_FILIAL, DA1_CODTAB, DA1_ITEM"

	oApiManager:SetApiRelation(aChildrenAlias, aFatherAlias, aRelation, cIndexKey)
    oApiManager:SetApiMap(ApiMap())
Return

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function ApiMap()
	Local apiMap		:= {}
	Local aStructDA0    := {}
	Local aStructDA1    := {}
	Local aStructAlias  := {}
	
	aStructDA0    :=	{"DA0","Field","items","items",;
							{;
								{"branchId"					, "Exp:cFilAnt"													},;
								{"companyInternalId"		, "Exp:cEmpAnt, Exp:cFilAnt"									},;
								{"internalId"				, "Exp:cEmpAnt, DA0_FILIAL, DA0_CODTAB"							},;
								{"companyId"				, "Exp:cEmpAnt"													},;
								{"code"						, "DA0_CODTAB"													},;
								{"name"						, "DA0_DESCRI"													},;
								{"initialDate"				, "DA0_DATDE" 													},;
								{"finalDate"				, "DA0_DATATE"													},;
								{"initiaHour"				, "DA0_HORADE"													},;
								{"finalHour"				, "DA0_HORATE"													},;
								{"valueDescount"			, ""															},;
								{"activeTablePrice"			, "DA0_ATIVO"													};
							},;
						}
							
	aStructDA1    := 	{"DA1","Item","itensTablePrices","itensTablePrices",;
							{;
								{"code"						, "DA1_CODTAB"													},;
								{"itemList"					, "DA1_ITEM"  													},;
								{"itemCode"					, "DA1_CODPRO"													},;
								{"itemInternalId"			, "Exp:cEmpAnt, DA1_FILIAL, DA1_CODPRO, DA1_CODTAB, DA1_ITEM"	},;
								{"referenceCode"			, ""															},;
								{"unitOfMeasureCode"		, ""															},;
								{"minimumSalesPrice"		, "DA1_PRCVEN"													},;
								{"minimumSalesPriceFOB"		, ""															},;								
								{"discountValue"			, "DA1_VLRDES"													},;
								{"discountFactor"			, "DA1_PERDES"													},;
								{"minimumAmount"			, ""															},;
								{"cifPrice"					, ""															},;
								{"fobPrice"					, ""															},;
								{"itemValidity"				, "DA1_DATVIG"													},;
								{"typePrice"				, ""															},;
								{"activeItemPrice"			, "DA1_ATIVO"													};																					
							},;
						}
	
	aStructAlias  := {aStructDA0, aStructDA1}
	
	apiMap := {"OMSS010","items","2.001","OMSA010",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} ApiMapDA0
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function ApiMapDA0()
	Local apiMap		:= {}
	Local aStructDA0    := {}
	Local aStructAlias  := {}
	
	aStructDA0    :=	{"DA0","Field","items","items",;
							{;
								{"branchId"					, "Exp:cFilAnt"													},;
								{"companyInternalId"		, "Exp:cEmpAnt, Exp:cFilAnt"									},;
								{"internalId"				, "Exp:cEmpAnt, DA0_FILIAL, DA0_CODTAB"							},;
								{"companyId"				, "Exp:cEmpAnt"													},;								
								{"code"						, "DA0_CODTAB"													},;
								{"name"						, "DA0_DESCRI"													},;
								{"initialDate"				, "DA0_DATDE" 													},;
								{"finalDate"				, "DA0_DATATE"													},;
								{"initiaHour"				, "DA0_HORADE"													},;
								{"finalHour"				, "DA0_HORATE"													},;
								{"valueDescount"			, ""															},;
								{"activeTablePrice"			, "DA0_ATIVO"													};
							},;
						}
							
	aStructAlias  := {aStructDA0}
	
	apiMap := {"OMSS010","items","2.001","OMSA010",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} ApiMapDA1
Estrutura a ser utilizada na classe ServicesApiManager para a tabela DA1

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function ApiMapDA1()
	Local apiMap		:= {}
	Local aStructDA1    := {}
	Local aStructAlias  := {}
							
	aStructDA1    := 	{"DA1","Field","items","items",;
							{;
								{"code"						, "DA1_CODTAB"													},;
								{"itemList"					, "DA1_ITEM"  													},;
								{"itemCode"					, "DA1_CODPRO"													},;
								{"itemInternalId"			, "Exp:cEmpAnt, DA1_FILIAL, DA1_CODPRO, DA1_CODTAB, DA1_ITEM"	},;
								{"referenceCode"			, ""															},;
								{"unitOfMeasureCode"		, ""															},;
								{"minimumSalesPrice"		, "DA1_PRCVEN"													},;
								{"minimumSalesPriceFOB"		, ""															},;								
								{"discountValue"			, "DA1_VLRDES"													},;
								{"discountFactor"			, "DA1_PERDES"													},;
								{"minimumAmount"			, ""															},;
								{"cifPrice"					, ""															},;
								{"fobPrice"					, ""															},;
								{"itemValidity"				, "DA1_DATVIG"													},;
								{"typePrice"				, ""															},;
								{"activeItemPrice"			, "DA1_ATIVO"													};																					
							},;
						}
	
	aStructAlias  := {aStructDA1}
	
	apiMap := {"OMSS010","items","2.001","OMSA010",aStructAlias,"itensTablePrices"}

Return apiMap


/*/{Protheus.doc} GetMainHeader
Realiza o Get considerando a tabela (DA0).

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return Nil

@author Alessandro Afonso
@since 11/02/2022
@version	12.1.20
/*/

Static Function GetMainHeader(oCoreDash, aQueryString, lHasNext)
	Local aApiMap			:= ApiMapHeader()
	Local aFatherAlias		:= {"DA0","items", "items"}

	Default aQueryString	:={,}
	Default oCoreDash		:= Nil
	Default lHasNext		:= .T.
	
	aRet := MntQueryHeader()
    oCoreDash:SetQuery(aRet[1])
    oCoreDash:SetWhere(aRet[2])
	oCoreDash:SetFields(aApiMap)
	oCoreDash:SetApiQstring(aQueryString)
	oCoreDash:BuildJson()

	FreeObj( aRet )
	FreeObj( aFatherAlias )

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MntQueryHeader
Monta a query responsável por trazer a capa da tabelas precos.

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Alessandro Afonso
@since 11/02/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQueryHeader(cSelect)
  Local cQuery  := ""
  Local cWhere  := ""

  Default cSelect := " DA0_FILIAL, DA0_CODTAB, DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA0_HORADE, DA0_HORATE, DA0_ATIVO "

  if Ascan(TCStruct(RetSqlName("DA0")), {|x| x[1] == 'S_T_A_M_P_'}) > 0
	 cSelect += " ,S_T_A_M_P_ "
  Endif

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("DA0") + " DA0 "

  cWhere := " DA0.D_E_L_E_T_ = ' ' AND DA0.DA0_FILIAL = '" + xFilial("DA0") + "'

Return {cQuery, cWhere}
/*/{Protheus.doc} ApiMapHeader
Estrutura a ser utilizada na classe CoreDash

@return aCampos Campos para retorno.

@author Alessandro Afonso
@since 11/02/2022
@version	12.1.20
/*/

Static Function ApiMapHeader()
  Local aCampos := {}
  aCampos := {;
 				{"branchId"					, "DA0_FILIAL"													},;
				{"internalId"				, "DA0_CODTAB"							                        },;
				{"code"						, "DA0_CODTAB"													},;
				{"name"						, "DA0_DESCRI"													},;
				{"initialDate"				, "DA0_DATDE" 													},;
				{"finalDate"				, "DA0_DATATE"													},;
				{"initiaHour"				, "DA0_HORADE"													},;
				{"finalHour"				, "DA0_HORATE"													},;
				{"valueDescount"			, ""															},;
				{"activeTablePrice"			, "DA0_ATIVO"													};
  }
  
  if Ascan(TCStruct(RetSqlName("DA0")), {|x| x[1] == 'S_T_A_M_P_'}) > 0
	aAdd(aCampos,{"S_T_A_M_P_", "S_T_A_M_P_"})
  Endif	
  
Return aCampos
