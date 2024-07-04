#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS090()
Return

/*/{Protheus.doc} Notes

API de integração de Note

@author		Squad Faturamento/CRM
@since		02/08/2018
/*/
WSRESTFUL Notes DESCRIPTION "Cadastro de Notes" //"Cadastro de Notes"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os Notes" ;
    WSSYNTAX "/api/crm/v1/Notes/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/notes"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo Prospesct" ;
    WSSYNTAX "/api/crm/v1/Notes/{Fields}" ;
    PATH "/api/crm/v1/notes"

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um Note específico" ;
    WSSYNTAX "/api/crm/v1/Notes/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/notes/{Code}"	

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Note específico" ;
    WSSYNTAX "/api/crm/v1/Notes/{Code}/{Fields}" ;
    PATH "/api/crm/v1/notes/{Code}"

	WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um Note específico" ;
    WSSYNTAX "/api/crm/v1/Notes/{Code}" ;
    PATH "/api/crm/v1/notes/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET / Notes/crm/Notes
Retorna todos os Notes

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Notes

	Local cError			:= ""
	Local aFatherAlias		:= {"AOB", "items", "items"}
	Local cIndexKey			:= "AOB_FILIAL, AOB_IDNOTA"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	Local aQueryString		:= Self:aQueryString
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("CRMS090","1.000")

	oApiManager:SetApiMap(ApiMap())
   	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate()	

	lRet := ApiMainGet(@oApiManager, aQueryString,  , , aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion())
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / Notes/crm/Notes
Inclui um novo vendedor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Notes
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("CRMS090","1.000")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"AOB","items", "items"})

	lRet := ManutNote(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",AOB->AOB_IDNOTA})
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

/*/{Protheus.doc} GET / Notes/crm/Notes/{Code}
Retorna um vendedor específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Notes

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("CRMS090","1.000")
	Local nLenFields		:= TamSX3("AOB_FILIAL")[1] + TamSX3("AOB_IDNOTA")[1]
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")

	If Len(AllTrim(Self:Code)) >= nLenFields
		Aadd(aFilter, {"AOB", "items",{"AOB_IDNOTA  = '" + SubStr(self:Code, TamSX3("AOB_FILIAL")[1] + 1, TamSX3("ACH_CODIGO")[1]) 							  + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro buscar o Note!", "O Note ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT / Notes/crm/Notes/{Code}
Altera um proscpect específico

@param	Code				, caracter, Código + loja  do Note
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Notes

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS090","1.000")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("AOB_FILIAL")[1] + TamSX3("AOB_IDNOTA")[1]

	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"AOB","items", "items"})

	If Len(AllTrim(Self:Code)) >= nLenFields
		If AOB->(Dbseek(xFilial("AOB") + SubStr(self:Code, TamSX3("AOB_FILIAL")[1] + 1, TamSX3("ACH_CODIGO")[1])))
			lRet := ManutNote(@oApiManager, Self:aQueryString, 4,, self:Code, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar o Note!", "Note não encontrado.",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Note!", "O Note ID deve possuir pelo menos "+cValToChar(nLenFields)+" caracteres.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		Aadd(aFilter, {"AOB", "items",{"AOB_IDNOTA = '" + AOB->AOB_IDNOTA + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete / Notes/crm/Notes/{Code}
Deleta um proscpect específico

@param	Code				, caracter, Código + loja  do Note
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Notes

	Local cResp			:= "Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("CRMS090","1.000")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("AOB_FILIAL")[1] + TamSX3("AOB_IDNOTA")[1]
	
	Self:SetContentType("application/json")

	oApiManager:Activate()

	If Len(AllTrim(Self:Code)) >= nLenFields
		If AOB->(Dbseek(xFilial("AOB") + SubStr(self:Code, TamSX3("AOB_FILIAL")[1] + 1, TamSX3("ACH_CODIGO")[1])))
			lRet := ManutNote(@oApiManager, Self:aQueryString, 5,, self:Code, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao alterar o Note!", "Note não encontrado.",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao alterar o Note!", "O Note ID deve possuir pelo menos "+ cValToChar(nLenFields) +" caracteres.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutNote
Realiza a manutenção (inclusão/alteração/exclusão) de Notes

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código + Loja do Note
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function ManutNote(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cError			:= ""
	Local cNote				:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nPosCod			:= 0
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
	Local oModel			:= Nil

	Default aJson			:= {}
	Default cChave 			:= ""

	Private lAutoErrNoFile	:= .T.
	Private lMsErroAuto 	:= .F.

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf

		If Len(aCab) <= 0
			lRet := .F.
			oApiManager:SetJsonError("400","Erro na Leitura do Json!.", "Informe um Json Válido",/*cHelpUrl*/,/*aDetails*/)
		EndIf
	EndIf

	If !Empty(cChave)
		cNote 	:= SubStr(cChave, TamSX3("AOB_FILIAL")[1] + 1, TamSX3("AOB_IDNOTA")[1] )
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "AOB_IDNOTA"}))

	If nOpc == 4
		If nPosCod == 0
			aAdd( aCab, {'AOB_IDNOTA' ,cNote, Nil})
		Else
			aCab[nPosCod][2]  := cNote
		EndIf
	EndIf

	aAdd( aCab, {'AOB_OWNER', RetCodUsr(), Nil})

	If lRet
		oModel := FwLoadModel('CRMA090')
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			If nOpc != 5
				For nX := 1 To Len(aCab)
					If !oModel:SetValue('AOBMASTER', aCab[nX][1], aCab[nX][2])
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
				oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Note!.", cResp,/*cHelpUrl*/,/*aDetails*/)
			Else
				AOB->(DbSeek(xFilial("AOB") + oModel:GetValue('AOBMASTER', 'AOB_IDNOTA')))
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Notes

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/09/2018
@version	12.1.17
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

@author		Squad Faturamento/CRM
@since		06/09/2018
@version	12.1.20
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrAOB		:= {}

	aStrAOB			:=	{"AOB","Fields","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "Exp:cFilAnt"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, AOB_FILIAL, AOB_IDNOTA"			},;								
								{"Code"							, "AOB_IDNOTA"									},;
								{"InternalId"					, "AOB_FILIAL, AOB_IDNOTA"						},;
								{"Description"					, "AOB_TITULO"									},;
								{"ResourceType"					, "AOB_ENTIDA"									},;
								{"ResourceCode"					, "AOB_CHAVE"									},;
								{"Date"							, "AOB_DTNOTA"									},;
								{"Content"						, "AOB_CONTEU"									},;
								{"Bloqued"						, "AOB_MSBLQL"									};
							},;
						}

	aStructAlias  := {aStrAOB}

	aApiMap := {"CRMS090","items","1.000","CRMA090",aStructAlias, "items"}

Return aApiMap