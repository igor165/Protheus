#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} SalesCharge

API de integraï¿½ï¿½o de Cadastro de Comissï¿½o de Vendas
@author		Squad Faturamento/CRM
@since		30/08/2018
/*/
WSRESTFUL SalesCharge DESCRIPTION "Cadastro de Comissão de Vendas"
	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA SellerId	        AS STRING	OPTIONAL
	WSDATA Title	        AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todas as comissões" ;
    WSSYNTAX "Fat/SalesCharge/{Order,Page, PageSize, Fields}" ;
    PATH "/api/Fat/v1/SalesCharge"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra uma nova comissão" ;
    WSSYNTAX "/api/Fat/v1/SalesCharge/" ;
    PATH "/api/Fat/v1/SalesCharge"	

	WSMETHOD GET SellerId ;
    DESCRIPTION "Carrega as comissões de um vendedor especifico" ;
    WSSYNTAX "/api/Fat/v1/SalesCharge/{SellerId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/Fat/v1/SalesCharge/{SellerId}"

	WSMETHOD GET TitleId ;
    DESCRIPTION "Carrega a comissão especifica" ;
    WSSYNTAX "/api/Fat/v1/SalesCharge/{SellerId}/{Title}/{Order,Page, PageSize, Fields}" ;
    PATH "/api/Fat/v1/SalesCharge/{SellerId}/{Title}"

	WSMETHOD PUT TitleId ;
    DESCRIPTION "Altera uma comissão especifica" ;
    WSSYNTAX "/api/Fat/v1/SalesCharge/{SellerId}/{Title}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/Fat/v1/SalesCharge/{SellerId}/{Title}"

	WSMETHOD DELETE TitleId ;
    DESCRIPTION "Deleta uma comissão especifica" ;
    WSSYNTAX "/api/Fat/v1/SalesCharge/{SellerId}/{Title}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/Fat/v1/SalesCharge/{SellerId}/{Title}"
 
ENDWSRESTFUL

/*/{Protheus.doc} GET / SalesCharge
Retorna todos as comissï¿½es dos vendedores

@param	Order		, caracter, Ordenaï¿½ï¿½o da tabela principal
@param	Page		, numï¿½rico, Nï¿½mero da pï¿½gina inicial da consulta
@param	PageSize	, numï¿½rico, Nï¿½mero de registro por pï¿½ginas
@param	Fields		, caracter, Campos que serï¿½o retornados no GET.

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SalesCharge

Local cError			:= ""
Local lRet				:= .T.
Local oApiManager		:= Nil

Self:SetContentType("application/json") 

oApiManager := FWAPIManager():New("mats490","1.001") 

lRet := GetMain(@oApiManager, Self:aQueryString)

If lRet
	Self:SetResponse( oApiManager:GetJsonSerialize() )
Else
	cError := oApiManager:GetJsonError()	
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

FreeObj(oApiManager)

Return lRet

/*/{Protheus.doc} POST / SalesCharge/SalesCharges
Inclui uma Comissï¿½o de Vendas"

@param	Order		, caracter, Ordenaï¿½ï¿½o da tabela principal
@param	Page		, numï¿½rico, Nï¿½mero da pï¿½gina inicial da consulta
@param	PageSize	, numï¿½rico, Nï¿½mero de registro por pï¿½ginas
@param	Fields		, caracter, Campos que serï¿½o retornados no GET.

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE SalesCharge
Local aQueryString	:= Self:aQueryString
Local cBody 		:= ""
Local cError		:= ""
Local lRet			:= .T.
Local oJsonPositions:= JsonObject():New()
Local oApiManager 	:= FWAPIManager():New("mats490","1.001")

Self:SetContentType("application/json")
cBody := Self:GetContent()

lRet := AtuPgtComi(3, @oApiManager, cBody)

If lRet
	aAdd(aQueryString,{"SellerId",SE3->E3_VEND})
	aAdd(aQueryString,{"customerVendorCode",SE3->E3_CODCLI})
	aAdd(aQueryString,{"customerVendorStore",SE3->E3_LOJA})
	aAdd(aQueryString,{"accountReceivableDocumentPrefix",SE3->E3_PREFIXO})
	aAdd(aQueryString,{"accountReceivableDocumentNumber",SE3->E3_NUM})
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

/*/{Protheus.doc} GET / SalesCharge/SalesCharges/SellerId
Retorna um vendedor especï¿½fico

@param	Order		, caracter, Ordenaï¿½ï¿½o da tabela principal
@param	Page		, numï¿½rico, Nï¿½mero da pï¿½gina inicial da consulta
@param	PageSize	, numï¿½rico, Nï¿½mero de registro por pï¿½ginas
@param	Fields		, caracter, Campos que serï¿½o retornados no GET.

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD GET SellerId PATHPARAM SellerId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesCharge

Local aFilter			:= {}
Local cError			:= ""
Local lRet 				:= .T.
Local oApiManager		:= FWAPIManager():New("mats490","1.001")

Default Self:SellerId:= ""

Self:SetContentType("application/json")

Aadd(aFilter, {"SE3", "items",{"E3_VEND = '" + Self:SellerId + "'"}})
oApiManager:SetApiFilter(aFilter) 	

If lRet
	lRet := GetMain(@oApiManager, Self:aQueryString)
EndIf

If lRet
	Self:SetResponse( oApiManager:GetJsonSerialize() )
Else
	cError := oApiManager:GetJsonError()
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

oApiManager:Destroy()
FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} GET / SalesCharge/SalesCharges/SellerId
Retorna um vendedor especï¿½fico

@param	Order		, caracter, Ordenaï¿½ï¿½o da tabela principal
@param	Page		, numï¿½rico, Nï¿½mero da pï¿½gina inicial da consulta
@param	PageSize	, numï¿½rico, Nï¿½mero de registro por pï¿½ginas
@param	Fields		, caracter, Campos que serï¿½o retornados no GET.

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD GET titleId PATHPARAM SellerId, Title WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesCharge

Local aQueryString		:= Self:aQueryString
Local cError			:= ""
Local lRet 				:= .T.
Local oApiManager		:= FWAPIManager():New("mats490","1.001")
Local nChvPrincipal		:= TamSX3("E3_VEND")[1] + TamSX3("E3_CODCLI")[1] + TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] 
Local oRet				:= Nil

Default Self:SellerId:= ""

Self:SetContentType("application/json")

If Len(Self:SellerId) + Len(Self:Title) >=  (nChvPrincipal - TamSX3("E3_NUM")[1] +1)// Chave de campos obrigatï¿½rios, atï¿½ o campo E3_NUM pega apenas a primeira posiï¿½ï¿½o caso o nr do tï¿½tulo tenha apenas 1 caracter
	aAdd(aQueryString,{"SellerId",Self:SellerId})
	aAdd(aQueryString,{"customerVendorCode",				SubStr(Self:Title,1,TamSX3("E3_CODCLI")[1])}) //, SE3->E3_CODCLI + SE3->E3_LOJA + E3_PREFIXO + E3_NUM + E3_PARCELA + E3_TIPO + E3_SEQ})
	aAdd(aQueryString,{"customerVendorStore",				SubStr(Self:Title,TamSX3("E3_CODCLI")[1] + 1, TamSX3("E3_LOJA")[1])}) 
	aAdd(aQueryString,{"accountReceivableDocumentPrefix",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + 1, TamSX3("E3_PREFIXO")[1])}) 
	aAdd(aQueryString,{"accountReceivableDocumentNumber",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + 1, TamSX3("E3_NUM")[1])}) 
Else
	lRet := .F.
	oApiManager:SetJsonError("400","Erro na chave da comissão!", "A chave SelerId + Title, deve possuir pelo menos "+ AllTrim(Str(nChvPrincipal))+" caracteres.",/*cHelpUrl*/,/*aDetails*/)	
	cError := oApiManager:GetJsonError()
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf	
If lRet .And. Len(Self:SellerId) + Len(Self:Title) > nChvPrincipal //Chave definida no swagger ate campo e3_tipo //E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO
	aAdd(aQueryString,{"accountReceivableDocumentParcel",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] +1,TamSX3("E3_PARCELA")[1])}) 
	aAdd(aQueryString,{"accountReceivableDocumentTypeCode",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] + TamSX3("E3_PARCELA")[1] +1, TamSX3("E3_TIPO")[1])}) 
EndIf

If lRet
	lRet := GetMain(@oApiManager, Self:aQueryString)
EndIf	

If lRet
	oRet:= oApiManager:GetJsonObject()
	If ValType(oRet["items"]) == "A" .And. Len(oRet["items"]) > 1
		lRet:= .F.
		oApiManager:SetJsonError("404","Erro na consulta!", "Existe mais de um registro com essa informação",/*cHelpUrl*/,/*aDetails*/)	
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	Else
		Self:SetResponse( oApiManager:ToObjectJson() )
	EndIf	
Else
	cError := oApiManager:GetJsonError()
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} PUT / SalesCharge/SalesCharges/SellerId
Altera um vendedor especï¿½ifco

@param	Order		, caracter, Ordenaï¿½ï¿½o da tabela principal
@param	Page		, numï¿½rico, Nï¿½mero da pï¿½gina inicial da consulta
@param	PageSize	, numï¿½rico, Nï¿½mero de registro por pï¿½ginas
@param	Fields		, caracter, Campos que serï¿½o retornados no GET.

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD PUT TitleId PATHPARAM SellerId,Title WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesCharge

Local aQueryString		:= Self:aQueryString
Local aAreaSE3			:= SE3->(GetArea())
Local cBody 			:= ""
Local cError			:= ""
Local lRet				:= .T.
Local oJsonPositions	:= JsonObject():New()
Local oApiManager 		:= FWAPIManager():New("mats490","1.001")
Local nChvPrincipal		:= TamSX3("E3_VEND")[1] + TamSX3("E3_CODCLI")[1] + TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] 
Local cChvParc			:= ""
Local lChaveParc		:= Len(Self:SellerId) + Len(Self:Title) > nChvPrincipal 
Local cExpression		:= Self:SellerId + Self:Title
Local nRecno			:= 0
Self:SetContentType("application/json")

cBody	:= Self:GetContent()
	
If lRet	.And. Len(Self:SellerId) + Len(Self:Title) >= (nChvPrincipal - TamSX3("E3_NUM")[1] +1) 	
	SE3->(dbSetOrder(3))
	If SE3->(Dbseek(xFilial("SE3") + cExpression))
		nRecno := SE3->(Recno())
		While SE3->(!EOF() ) .And. xFilial("SE3") == SE3->E3_FILIAL .And.;
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½SE3->E3_VEND == Self:SellerId .And. SE3->E3_CODCLI == SubStr(Self:Title,1,TamSX3("E3_CODCLI")[1]) .And. ;
				SE3->E3_LOJA == SubStr(Self:Title,TamSX3("E3_CODCLI")[1] + 1, TamSX3("E3_LOJA")[1]) .And. ;
				SE3->E3_PREFIXO == SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + 1, TamSX3("E3_PREFIXO")[1]) .And. ;
				RTrim(SE3->E3_NUM) == RTrim(SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + 1, TamSX3("E3_NUM")[1]))
				
				If lChaveParc
					cChvParc := SubStr(cExpression,nChvPrincipal+1,Len(Self:SellerId) + Len(Self:Title))
					If AllTrim(cChvParc) == AllTrim(SE3->E3_PARCELA + SE3->E3_TIPO)
						If nRecno <> SE3->(Recno())
							lRet := .F.
							Exit
						EndIf	
					EndIf
				Else				
					If nRecno <> SE3->(Recno())
						lRet := .F. 
						Exit
					EndIf	
				EndIf	
			SE3->(DbSkip())
		EndDo
		If nRecno <> SE3->(Recno())
			SE3->(dbGoTo(nRecno))
		EndIf	
		If lRetï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
		ï¿½ï¿½ï¿½ï¿½lRet := AtuPgtComi(4, @oApiManager, cBody, aQueryString, Self:SellerId, Self:Title)
		Else
		ï¿½ï¿½ï¿½ï¿½oApiManager:SetJsonError("404","Existe mais de um registro com essa chave!","Nao sera possvel realizar a alteracao",/*cHelpUrl*/,/*aDetails*/)
		EndIfï¿½ï¿½ï¿½
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao alterar o comissao !", "Comissao nao encontrada.",/*cHelpUrl*/,/*aDetails*/)
	EndIf	
	
	If lRet 
		aAdd(aQueryString,{"SellerId",Self:SellerId})
		aAdd(aQueryString,{"customerVendorCode",				SubStr(Self:Title,1,TamSX3("E3_CODCLI")[1])}) //, SE3->E3_CODCLI + SE3->E3_LOJA + E3_PREFIXO + E3_NUM + E3_PARCELA + E3_TIPO + E3_SEQ})
		aAdd(aQueryString,{"customerVendorStore",				SubStr(Self:Title,TamSX3("E3_CODCLI")[1] + 1, TamSX3("E3_LOJA")[1])}) 
		aAdd(aQueryString,{"accountReceivableDocumentPrefix",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + 1, TamSX3("E3_PREFIXO")[1])}) 
		aAdd(aQueryString,{"accountReceivableDocumentNumber",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + 1, TamSX3("E3_NUM")[1])}) 
		If Len(Self:SellerId) + Len(Self:Title) >= 27
			aAdd(aQueryString,{"accountReceivableDocumentParcel",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] +1,TamSX3("E3_PARCELA")[1])}) 
			aAdd(aQueryString,{"accountReceivableDocumentTypeCode",	SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] + TamSX3("E3_PARCELA")[1] +1, TamSX3("E3_TIPO")[1])}) 
		EndIf
		lRet := GetMain(@oApiManager, aQueryString, .F.)
	EndIf 

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
Else
	lRet := .F.
	oApiManager:SetJsonError("400","Erro ao alterar comissao!", "A chave SelerId + Title, deve possuir pelo menos "+ AllTrim(Str(nChvPrincipal))+" caracteres.",/*cHelpUrl*/,/*aDetails*/)	
	cError := oApiManager:GetJsonError()
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

oApiManager:Destroy()
FreeObj( oJsonPositions )
FreeObj( aQueryString )	

RestArea(aAreaSE3)
Return lRet

/*/{Protheus.doc} DELETE / SalesCharge/SalesCharges/SellerId/Title
Deleta um vendedor

@param	Order		, caracter, Ordenaï¿½ï¿½o da tabela principal
@param	Page		, numï¿½rico, Nï¿½mero da pï¿½gina inicial da consulta
@param	PageSize	, numï¿½rico, Nï¿½mero de registro por pï¿½ginas
@param	Fields		, caracter, Campos que serï¿½o retornados no GET.

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD DELETE TitleId PATHPARAM SellerId, Title WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE SalesCharge
Local aFilter			:= {}
Local aAreaSE3			:= SE3->(GetArea())
Local aQueryString		:= Self:aQueryString
Local cError			:= ""
Local cResp				:= "Registro Deletado com Sucesso"
Local lRet 				:= .T.
Local oApiManager		:= FWAPIManager():New("mats490","1.001")
Local oJsonPositions	:= JsonObject():New()
Local nChvPrincipal		:= TamSX3("E3_VEND")[1] + TamSX3("E3_CODCLI")[1] + TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + TamSX3("E3_NUM")[1] 
Local cChvParc			:= ""
Local lChaveParc		:= Len(Self:SellerId) + Len(Self:Title) > nChvPrincipal 
Local cExpression		:= Self:SellerId + Self:Title

Self:SetContentType("application/json")
cBody	:= Self:GetContent()
	
If Len(Self:SellerId) + Len(Self:Title) >= (nChvPrincipal - TamSX3("E3_NUM")[1] +1) 	
	SE3->(dbSetOrder(3))
	If SE3->(Dbseek(xFilial("SE3") + cExpression))
		nRecno := SE3->(Recno())
		While SE3->(!EOF() ) .And. xFilial("SE3") == SE3->E3_FILIAL .And.;
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½SE3->E3_VEND == Self:SellerId .And. SE3->E3_CODCLI == SubStr(Self:Title,1,TamSX3("E3_CODCLI")[1]) .And. ;
			SE3->E3_LOJA == SubStr(Self:Title,TamSX3("E3_CODCLI")[1] + 1, TamSX3("E3_LOJA")[1]) .And. ;
			SE3->E3_PREFIXO == SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + 1, TamSX3("E3_PREFIXO")[1]) .And. ;
			RTrim(SE3->E3_NUM) == RTrim(SubStr(Self:Title,TamSX3("E3_CODCLI")[1]+TamSX3("E3_LOJA")[1] + TamSX3("E3_PREFIXO")[1] + 1, TamSX3("E3_NUM")[1]))
			If lChaveParc
				cChvParc := SubStr(cExpression,nChvPrincipal+1,Len(Self:SellerId) + Len(Self:Title))
				If AllTrim(cChvParc) == AllTrim(SE3->E3_PARCELA + SE3->E3_TIPO)
					If nRecno <> SE3->(Recno())
						lRet := .F.
						Exit
					EndIf	
				EndIf
			Else				
				If nRecno <> SE3->(Recno())
					lRet := .F. 
					Exit
				EndIf	
			EndIf	
			SE3->(DbSkip())
		EndDo
		If nRecno <> SE3->(Recno())
			SE3->(dbGoTo(nRecno))
		EndIf	
		If lRetï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
		ï¿½ï¿½ï¿½ï¿½lRet := AtuPgtComi(5, @oApiManager, cBody, aQueryString, Self:SellerId, Self:Title)
		Else
		ï¿½ï¿½ï¿½ï¿½lRet := .F.
			oApiManager:SetJsonError("404","Existe mais de um registro com essa chave!","Nao sera possvel realizar a exclusivo",/*cHelpUrl*/,/*aDetails*/)
			cError := oApiManager:GetJsonError()
			SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
		EndIfï¿½
	Else
		lRet:= .F.
		oApiManager:SetJsonError("404","Erro ao alterar o comissao!", "Comissao nao encontrada.",/*cHelpUrl*/,/*aDetails*/)
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf	
Else
	lRet := .F.
	oApiManager:SetJsonError("400","Erro ao alterar comissao!", "A chave SelerId + Title, deve possuir pelo menos "+ AllTrim(Str(nChvPrincipal))+" caracteres.",/*cHelpUrl*/,/*aDetails*/)	
	cError := oApiManager:GetJsonError()
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

If lRet
	oJsonPositions['response'] := cResp
	cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
	Self:SetResponse( cResp )
EndIf

oApiManager:Destroy()
FreeObj(aFilter)
RestArea(aAreaSE3)
Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get da tabela SE3

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no mï¿½todo 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lï¿½gico	, Informa se informarï¿½ se existem ou nï¿½o mais pï¿½ginas a serem exibidas

@return lRet	, Lï¿½gico	, Retorna se conseguiu ou nï¿½o processar o Get.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function GetMain(oApiManager, aQueryString, lHasNext)

Local aRelation			:= {{"E3_FILIAL","E3_FILIAL"},{"E3_VEND","E3_VEND"}}
Local aFatherAlias		:= {"SE3", "items","items"}
Local lRet 				:= .T.
Local nLenJson			:= 0
Local oJson				:= Nil

Default aQueryString	:={,}
Default oApiManager		:= Nil
Default lHasNext		:= .T.

lRet := ApiMainGet(@oApiManager, aQueryString, , , , , oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

If lRet
	oJson := oApiManager:GetJsonObject()
	nLenJson := Len(oJson[oApiManager:cApiName])
Else
	cError := oApiManager:GetJsonError()	
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf
FreeObj( aRelation )
FreeObj( aFatherAlias )	

Return lRet

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function ApiMap()
Local apiMap		:= {}
Local aStrSE3Pai    := {}
Local aStructAlias  := {}

aStrSE3Pai    :=	{"SE3","Field","items","items",;
						{;
							{"companyId"							, "Exp:cEmpAnt"									},;
							{"branchID"								, "Exp:cFilAnt"									},;
							{"CompanyInternalId"					, "Exp:cEmpAnt, Exp:cFilAnt"					},;
							{"internalId"							, "E3_PREFIXO,E3_NUM,E3_PARCELA,E3_SEQ,E3_VEND"	},;
							{"sellerInternalId"						, "E3_VEND"										},;
							{"SellerId"								, "E3_VEND"										},;
							{"accountReceivableDocumentPrefix"		, "E3_PREFIXO"									},;
							{"accountReceivableDocumentNumber"		, "E3_NUM"										},;
							{"accountReceivableDocumentParcel"		, "E3_PARCELA"									},;
							{"accountReceivableDocumentTypeCode"	, "E3_TIPO"										},;
							{"customerVendorInternalId"				, "E3_CODCLI,E3_LOJA"							},;
							{"customerVendorCode"					, "E3_CODCLI"									},;
							{"customerVendorStore"					, "E3_LOJA"										},;
							{"issueDate"							, "E3_EMISSAO"									},;
							{"baseValue"							, "E3_BASE"										},;
							{"salesChargePercentage"				, "E3_PORC"										},;
							{"value"								, "E3_COMIS"									},;
							{"dueDate"								, "E3_VENCTO"									},;
							{"currencyInternalId"					, "E3_DATA"										},;
							{"currency"								, "E3_MOEDA"									};
						},;
					}

aStructAlias  := {aStrSE3Pai}

apiMap := {"MATS490","items","1.001","MATA490",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} AtuPgtComi
Funï¿½ï¿½o para incluir/alterar/excluir uma comissï¿½o

@param	nOpc			, numï¿½rico	, Informa se ï¿½ uma inclusï¿½o (3), alteraï¿½ï¿½o (4) ou exclusï¿½o (5)
@param	oApiManager		, objeto	, Objeto com a classe API Manager
@param	cBody			, caracter	, Json recebido
@param	aQueryString	, array		, Array com os filtros

@return lRet	, Lï¿½gico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
Static Function AtuPgtComi(nOpc,oApiManager,cBody,aQueryString,cVendedor,cTitulo)

Local aCab			:= {}
Local aMsgErro		:= {}
Local aJson			:= {}
Local aFatherAlias	:= {"SE3","items", "items"}
Local lRet			:= .T.
Local nX			:= 0

Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile	:= .T.

Default cVendedor	:= ""
Default aQueryString:= ""

oApiManager:SetApiQstring(aQueryString)
oApiManager:SetApiAlias(aFatherAlias)
oApiManager:Activate()

If !oApiManager:IsActive()
	lRet := .F.
Else
	aJson := oApiManager:ToArray(cBody)
	If Len(aJson[1][1]) > 0
		aCab := aJson[1][1][1][2]
		aCab	:= oApiManager:ToExecAuto(1, aCab)	
		aSort(aCab,,,{ | x,y | x[1] < y[1] } )
		MSExecAuto( { |x, y| MATA490( x, y ) }, aCab, nOpc )

		If lMsErroAuto
			aMsgErro := GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
			Next nX	
			lRet := .F.
			oApiManager:SetJsonError("400","Erro durante inclusao/alteracao da comissao!.", cResp,/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		oApiManager:SetJsonError("400","Erro durante a conversap do Json!.", "Verifique o Json Informado",/*cHelpUrl*/,/*aDetails*/)
	EndIf
EndIf
FreeObj( aCab )
Return lRet
