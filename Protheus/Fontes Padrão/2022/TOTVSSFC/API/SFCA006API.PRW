#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function SFCA006API()
Return

/*/{Protheus.doc} Recursos

API de integração de Recursos

@author		Renan Roeder
@since		12/11/2018
/*/
WSRESTFUL SFCA006API DESCRIPTION "Cadastro de Recursos"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA ResourceId		AS STRING	OPTIONAL
 
    WSMETHOD GET Resource ;
    DESCRIPTION "Carrega todos os Recursos" ;
    PATH "/api/sfc/v1/resources"

    WSMETHOD POST Resource ;
    DESCRIPTION "Cadastra um novo Recurso" ;
    PATH "/api/sfc/v1/resources"

	WSMETHOD GET ResId ;
    DESCRIPTION "Carrega um Recurso específico" ;
    PATH "/api/sfc/v1/resources/{ResourceId}"

	WSMETHOD PUT ResId ;
    DESCRIPTION "Altera um Recurso específico" ;
    PATH "/api/sfc/v1/resources/{ResourceId}"

	WSMETHOD DELETE ResId ;
    DESCRIPTION "Exclui um Recurso específico" ;
    PATH "/api/sfc/v1/resources/{ResourceId}"

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/sfc/v1/resources
Retorna todos os Recursos

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

WSMETHOD GET Resource WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA006API

	Local cError			:= ""
	Local aFatherAlias		:= {"CYH", "items", "items"}
	Local cIndexKey			:= "CYH_FILIAL, CYH_IDRC, CYH_TPRC, CYH_CDRC"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("SFCA006API","1.001")

	oApiManager:SetApiAdapter("SFCA006API")
   	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate()

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST /api/sfc/v1/resources
Inclui um novo Recurso

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/
WSMETHOD POST Resource WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA006API
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("SFCA006API","1.001")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CYH","items", "items"})

	lRet := ManutRes(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"ResourceId",CYH->CYH_IDRC})
		lRet := GetMain(@oApiManager, aQueryString, .F.)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} GET /api/sfc/v1/resources/{ResourceId}
Retorna um Recurso específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/
WSMETHOD GET ResId PATHPARAM ResourceId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SFCA006API

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("SFCA006API","1.001")
	
	Default Self:ResourceId:= ""

    Self:SetContentType("application/json")

	Aadd(aFilter, {"CYH", "items",{"CYH_IDRC  = '" + self:ResourceId + "'"}})
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

/*/{Protheus.doc} PUT /api/sfc/v1/resources/{ResourceId}
Altera um Recurso específico

@param	ResourceId			, caracter, Id do Recurso
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

WSMETHOD PUT ResId PATHPARAM ResourceId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA006API

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("SFCA006API","1.001")
	Local cBody 	   	:= Self:GetContent()	

	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CYH","items", "items"})

	CYH->(dbSetOrder(2))
	If CYH->(Dbseek(xFilial("CYH") + PADR(Self:ResourceId,TamSx3("CYH_IDRC")[1] ," ")))
		lRet := ManutRes(@oApiManager, Self:aQueryString, 4,, self:ResourceId, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao alterar o Recurso!", "Recurso não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Aadd(aFilter, {"CYH", "items",{"CYH_IDRC = '" + CYH->CYH_IDRC + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete /api/sfc/v1/resources/{ResourceId}
Deleta um Recurso específico

@param	ResourceId			, caracter, Id do Recurso
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

WSMETHOD DELETE ResId PATHPARAM ResourceId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SFCA006API

	Local cResp			:= "Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("SFCA006API","1.001")
	Local cBody			:= Self:GetContent()
	
	Self:SetContentType("application/json")

	oApiManager:Activate()

	CYH->(dbSetOrder(2))
	If CYH->(Dbseek(xFilial("CYH") + PADR(Self:ResourceId,TamSx3("CYH_IDRC")[1] ," ")))
		lRet := ManutRes(@oApiManager, Self:aQueryString, 5,, self:ResourceId, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao excluir o Recurso!", "Recurso não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutRes
Realiza a manutenção (inclusão/alteração/exclusão) de Recursos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com o Id do Recurso
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/
Static Function ManutRes(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab		:= {}
	Local cResp		:= ""
    Local lRet		:= .T.
	Local nX		:= 0
	Local oModel	:= Nil
	Local nPosId    := 0
	Local nPosTp    := 0
	Local nPosCd    := 0


	Default aJson			:= {}
	Default cChave 			:= ""

	//Private lAutoErrNoFile	:= .T.
	//Private lMsErroAuto 	:= .F.

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf

		nPosId	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CYH_IDRC"}))
		If nPosId > 0
			aDel(aCab,nPosId)
			aSize(aCab,Len(aCab)-1)		
		EndIf
	EndIf

	If nOpc == 4
		nPosTp	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CYH_TPRC"}))
		If nPosTp > 0
			aDel(aCab,nPosTp)
			aSize(aCab,Len(aCab)-1)		
		EndIf
		nPosCd	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CYH_CDRC"}))
		If nPosCd > 0
			aDel(aCab,nPosCd)
			aSize(aCab,Len(aCab)-1)
		EndIf		
	EndIf

	If lRet
		oModel := FwLoadModel('SFCA006')
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			If nOpc != 5
				For nX := 1 To Len(aCab)
					If !oModel:SetValue('CYHMASTER', aCab[nX][1], aCab[nX][2])
						lRet := .F.
						Exit
					EndIf
				Next nX
			EndIf
			If !((oModel:VldData() .and. oModel:CommitData())) .Or. !lRet
				aMsgErro := oModel:GetErrorMessage()
				cResp	 := ""
				For nX := 1 To Len(aMsgErro)
					If ValType(aMsgErro[nX]) == "C"
						cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
					EndIf
				Next nX	
				lRet := .F.
				oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Recurso!.", cResp,/*cHelpUrl*/,/*aDetails*/)
			Else
				CYH->(dbSetOrder(2))
				CYH->(DbSeek(xFilial("CYH") + oModel:GetValue('CYHMASTER', 'CYH_IDRC')))
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Recursos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Renan Roeder
@since		12/11/2018
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

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrCYH		:= {}

	aStrCYH			:=	{"CYH","Fields","items","items",;
							{;
								{"ResourceId"				, "CYH_IDRC"						},;
								{"Code"						, "CYH_CDRC"						},;
								{"Type"						, "CYH_TPRC"						},;
								{"Name"						, "CYH_NMRC"						},;
								{"ProductionAreaCode"		, "CYH_CDARPO"						},;
								{"ProductionAreaDescription", "Exp:GETPADESC(CYH->CYH_CDARPO)"	},;
								{"ProductionShiftNumber"	, "CYH_NRTN"						},;
								{"LaborCode"				, "CYH_CDMOD"						},;
								{"StartExpirationDate"		, "CYH_DTVDBG"						},;
								{"EndExpirationDate"		, "CYH_DTVDED"						},;
								{"UnitCycleQuantity"		, "CYH_QTUNCI"						},;
								{"ToolCode"					, "CYH_CDMPRC"						},;
								{"ToolDescription"			, "Exp:GETTLDESC(CYH->CYH_CDMPRC)"	};
							},;
						}
	aStructAlias  := {aStrCYH}

	aApiMap := {"SFCA006API","items","1.001","SFCA006",aStructAlias, "items"}

Return aApiMap

/*/{Protheus.doc} GETPADESC
Busca a descrição da área de produção

@return cRet	, caracter	, Descrição da área de produção.

@author		Renan Roeder
@since		15/11/2018
@version	12.1.23
/*/
Function GETPADESC(cPACod)
	Local cPADesc := ""

	CYA->(dbSetOrder(1))
	If CYA->(DbSeek(xFilial("CYA") + cPACod))
		cPADesc := CYA->CYA_DSARPO
	EndIf

Return cPADesc

/*/{Protheus.doc} GETTLDESC
Busca a descrição do item ferramenta

@return cRet	, caracter	, Descrição do item ferramenta.

@author		Renan Roeder
@since		15/11/2018
@version	12.1.23
/*/
Function GETTLDESC(cTLCod)
	Local cTLDesc := ""

	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1") + cTLCod))
		cTLDesc := SB1->B1_DESC
	EndIf

Return cTLDesc