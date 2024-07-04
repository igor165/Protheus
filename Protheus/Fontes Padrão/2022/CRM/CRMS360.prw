#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS360()

Return

/*/{Protheus.doc} Campaigns
API de integração de Cadastro de Campanhas

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

WSRESTFUL campaigns DESCRIPTION "Cadastro de Campanhas" 

	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code 	        AS STRING	OPTIONAL

    WSMETHOD GET Main ;
    DESCRIPTION "Lista todas Campanhas" ;
    WSSYNTAX "/api/crm/v1/campaigns/{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/campaigns"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra uma nova Campanha" ;
    WSSYNTAX "/api/crm/v1/campaigns/" ;
    PATH "/api/crm/v1/campaigns"

    WSMETHOD GET Code ;
    DESCRIPTION "Lista uma Campanha Especifica" ;
    WSSYNTAX "/api/crm/v1/campaigns/{Code}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/campaigns/{Code}"

    WSMETHOD PUT Code ;
    DESCRIPTION "Altera uma Campanha" ;
    WSSYNTAX "/api/crm/v1/campaigns/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/campaigns/{Code}"

    WSMETHOD DELETE Code ;
    DESCRIPTION "Exclui uma campanha" ;
    WSSYNTAX "/api/crm/v1/campaigns/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/campaigns/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET /campaigns/crm/campaigns/
Lista todas campanhas

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE campaigns

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	Local aRelation			:= {{"UO_FILIAL","UW_FILIAL"},{"UO_CODCAMP","UW_CODCAMP"}}
	Local aFatherAlias		:= {"SUO", "items","items"}
	Local aChildrenAlias    := {"SUW", "ListOfCampaigns", "ListOfCampaigns" }
	Local cIndexKey			:= "UW_FILIAL, UW_CODCAMP"

	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("crms360","1.000") 
	oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)

	lRet := GetMain(@oApiManager,Self:aQueryString)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	FreeObj(oApiManager)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} POST /campaigns/crm/campaigns/{Code}

    Return a object with a list of MarketSegments data.

@author		Renato da Cunha
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD POST Main WSRECEIVE Fields  WSSERVICE campaigns

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS360","1.000")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SUO","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet
        lRet := ManutSUO(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
			Aadd(aFilter, {"SUO", "items",{"UO_FILIAL = '" 	+ SUO->UO_FILIAL + "'"}})
			Aadd(aFilter, {"SUO", "items",{"UO_CODCAMP = '" + SUO->UO_CODCAMP + "'"}})
	        oApiManager:SetApiFilter(aFilter)            
			lRet    := GetMain(oApiManager, Self:aQueryString)						
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Campanha!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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
/*/{Protheus.doc} GET /campaigns/crm/campaigns/{Code}
Lista uma campanha específica

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE campaigns

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("crms360","1.000")
	Local aRelation			:= {{"UO_FILIAL","UW_FILIAL"},{"UO_CODCAMP","UW_CODCAMP"}}
	Local aFatherAlias		:= {"SUO", "items","items"}
	Local aChildrenAlias    := {"SUW", "ListOfCampaigns", "ListOfCampaigns" }
	Local cIndexKey			:= "UW_FILIAL, UW_CODCAMP"

	Default Self:Code:= ""

	Self:SetContentType("application/json")
	oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)

	SUO->(DbSetOrder(1))
	If SUO->(DbSeek(Self:Code))
		aAdd(aFilter, {"SUO", "items",{"UO_FILIAL  = '" + SUO->UO_FILIAL  + "'"}})
		aAdd(aFilter, {"SUO", "items",{"UO_CODCAMP = '" + SUO->UO_CODCAMP +  "'"}})
		oApiManager:SetApiFilter(aFilter)
		lRet := GetMain(@oApiManager, Self:aQueryString, .F.)
	Else 
	    lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar Campanha!", "Campanha não encontrada.",/*cHelpUrl*/,/*aDetails*/)
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
/*/{Protheus.doc} PUT /campaigns/crm/campaigns/{Code}
Altera uma Campanha específica

@param	Code		        , caracter, Código da Campanha
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE campaigns

	Local aFilter		:= {}
	Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.    
	Local oApiManager 	:= FWAPIManager():New("CRMS360","1.000")
	Local oJson			:= THashMap():New()	

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SUO","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
		SUO->(DbSetOrder(1))
        If SUO->(DbSeek( Self:Code ))
       		lRet := ManutSUO(oApiManager, Self:aQueryString, 4, aJson,, oJson, cBody)
        	If lRet
				Aadd(aFilter, {"SUO", "items",{"UO_FILIAL = '" 	+ SUO->UO_FILIAL + "'"}})
				Aadd(aFilter, {"SUO", "items",{"UO_CODCAMP = '" + SUO->UO_CODCAMP + "'"}})
                oApiManager:SetApiFilter(aFilter)
				lRet    := GetMain(oApiManager, Self:aQueryString)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar a Campanha!", "Campanha não encontrada.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Campanha!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DELETE /campaigns/crm/campaigns/{Code}
Deleta uma Campanha específica

@param	Code		        , caracter, Código do Campanha
@param	Fields				, caracter, Campos que serão retornados na requisição.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/09/2018
@version	12.1.21
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Fields WSSERVICE campaigns

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("CRMS360","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SUO","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	SUO->(DbSetOrder(1))
    If SUO->(DbSeek( Self:Code ))
		lRet := ManutSUO(oApiManager, Self:aQueryString, 5, aJson, Self:Code, , cBody)        
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Campanha!", "Campanha não encontrada.",/*cHelpUrl*/,/*aDetails*/)
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
Realiza o Get da tabela SE3

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, lHasNext)

	Local aFatherAlias		:= {"SUO", "items","items"}
	Local aChildrenAlias    := {"SUW", "ListOfCampaigns", "ListOfCampaigns" }
	Local cIndexKey			:= "UW_FILIAL, UW_CODCAMP"
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

/*/{Protheus.doc} ManutSUO
Realiza a manutenção (inclusão/alteração/exclusão) da Campanha

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

Static Function ManutSUO(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)
	
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aFronze	:= {"UO_CODCAMP"}
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
	Local oModel	:= FWLoadModel("TMKA310")
	Local oModelFld := oModel:GetModel("SUOMASTER")
	Local oModelGd	:= oModel:GetModel("SUWDETAIL")

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

						nPosCamp := aScan(aItens[nX], {|x| AllTrim(x[1]) == "UW_CODCAMP"})
						nPosEven := aScan(aItens[nX], {|x| AllTrim(x[1]) == "UW_CODEVE"})
						nPosScri := aScan(aItens[nX], {|x| AllTrim(x[1]) == "UW_CODSCRI"})
						nPosProd := aScan(aItens[nX], {|x| AllTrim(x[1]) == "UW_PRODUTO"})
						
						cCodCamp := IIf(nPosCamp > 0 ,aItens[nX,nPosCamp,2],CriaVar("UW_CODCAMP"))
						cCodEven := IIf(nPosEven > 0 ,aItens[nX,nPosEven,2],CriaVar("UW_CODEVE"))
						cCodScri := IIf(nPosScri > 0 ,aItens[nX,nPosScri,2],CriaVar("UW_CODSCRI"))
						cCodProd := IIf(nPosProd > 0 ,aItens[nX,nPosProd,2],CriaVar("UW_PRODUTO"))
						
						If !oModelGd:SeekLine({{"UW_CODCAMP",cCodCamp},{"UW_CODEVE",cCodEven},{"UW_CODSCRI",cCodScri},{"UW_PRODUTO",cCodProd}})
							If nX > 1
								oModelGd:AddLine()
							Endif
						Endif
					Endif
					For nY := 1 To Len(aItens[nX])
						If aScan(aAuxGd, {|x| AllTrim(x[3]) == AllTrim(aItens[nX,nY,1])}) > 0
							If !oModelGd:SetValue(aItens[nX,nY,1], aItens[nX,nY,2])
								lRet := .F.
								cResp := "Não foi possível atribuir o valor " + AllToChar(aItens[nX,nY,2]) + " ao campo " + aItens[nX,nY,1] + "."
								Exit
							EndIf
						Endif
					Next nY

					If lRet
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
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Campanha!.", cResp,/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"SUW", "ListOfCampaigns"      , "ListOfCampaigns"  	}
    Local aFatherSUO	:=	{"SUO", "items"                , "items"           		}        
    Local aRelation     :=  {}
	Local cIndexKey		:=  "UW_FILIAL, UW_CODEVE, UW_CODCAMP, UW_CODSCRI, UW_PRODUTO, UW_MIDIA"

    aAdd(aRelation,{"UO_FILIAL"		,"UW_FILIAL"   	})
    aAdd(aRelation,{"UO_CODCAMP"  	,"UW_CODCAMP"   })

	oApiManager:SetApiRelation(aChildren	, aFatherSUO  	, aRelation, cIndexKey)
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
	Local aStrSUOPai    := {}
	Local aStructAlias  := {}

	aStrSUOPai    :=	{"SUO","Field","items","items",;
							{;
								{"CompanyId"							, "Exp:cEmpAnt"									},;
								{"InternalId"							, "Exp:cFilAnt, UO_CODCAMP"						},;							
								{"BranchID"								, "Exp:cFilAnt"									},;
								{"CompanyInternalId"					, "Exp:cEmpAnt, Exp:cFilAnt, UO_CODCAMP"		},;
								{"Code"		                            , "UO_CODCAMP"									},;
								{"CampaingDescription"                  , "UO_DESC" 									},;
								{"Type"				                    , "UO_TIPO" 									},;
								{"InitDate"                             , "UO_DTINIR" 									},;
								{"EndDate"                              , "UO_DTTERMR" 									},;
								{"Objective"                            , "UO_OBJETIV" 									},;
								{"Attendance"                           , "UO_ATENDIM" 									},;
								{"ExpectedPorcentage"                   , "UO_TOTSUC" 									},;
								{"BlockedRecord"                        , "UO_MSBLQL" 									},;
								{"Campaign_Evolution_Status"            , "UO_STATUS" 									},;
								{"CampaingType"                         , "UO_TPCAMP" 									};
							};
						}
	aStructGrid :=      { "SUW", "ITEM", "ListOfCampaigns", "ListOfCampaigns",;
							{;
								{"EventCode"     						, "UW_CODEVE"									},;
								{"InternalId"     						, "Exp:cFilAnt, UW_CODEVE, UW_CODCAMP"			},;
								{"ScriptCode"     						, "UW_CODSCRI"									},;
								{"ProductCode"     						, "UW_PRODUTO"									},;
								{"MidiaCode"     						, "UW_MIDIA"									};
							};
						}

	aStructAlias  := {aStrSUOPai,aStructGrid}

	apiMap := {"CRMS360","items","1.000","CRMA360",aStructAlias,"items"}

Return apiMap