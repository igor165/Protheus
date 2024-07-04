#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCOI195O.CH"

//dummy function
Function PCOI195O()
Return

/*/{Protheus.doc} BudgetBalanceType

API de integração de BudgetBalanceType

@author		Squad Control/PCO
@since		30/11/2018
/*/
WSRESTFUL BudgetBalanceType DESCRIPTION STR0001 //"Cadastro Tipo de Saldo Orçamentário"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
	WSDATA InternalId		AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION STR0002; //"Carrega todos os Tipos de Saldo Orçamentário"
    WSSYNTAX "/api/pco/v1/BudgetBalanceType/{Order, Page, PageSize, Fields}" ;
    PATH "/api/pco/v1/BudgetBalanceType"

    WSMETHOD POST Main ;
    DESCRIPTION STR0003; //"Cadastra um Novo Tipo de Saldo Orçamentário"
    WSSYNTAX "/api/pco/v1/BudgetBalanceType/{Fields}" ;
    PATH "/api/pco/v1/BudgetBalanceType"

	WSMETHOD GET InternalId ; 
    DESCRIPTION STR0004; //"Carrega Tipo de Saldo Orçamentário específico"
    WSSYNTAX "/api/pco/v1/BudgetBalanceType/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/pco/v1/BudgetBalanceType/{InternalId}"	

	WSMETHOD PUT InternalId ;
    DESCRIPTION  STR0005; //"Altera Tipo de Saldo Orçamentário específico"
    WSSYNTAX "/api/pco/v1/BudgetBalanceType/{InternalId}/{Fields}" ;
    PATH "/api/pco/v1/BudgetBalanceType/{InternalId}"	

	WSMETHOD DELETE InternalId ;
    DESCRIPTION STR0006; //"Deleta Tipo de Saldo Orçamentário específico"
    WSSYNTAX "/api/pco/v1/BudgetBalanceType/{InternalId}" ;
    PATH "/api/pco/v1/BudgetBalanceType/{InternalId}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET / BudgetBalanceType/api/pco/v1/BudgetBalanceTypes
Retorna Todos os Tipos de Saldo Orçamentário

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, númerico, Número da página inicial da consulta
@param	PageSize	, númerico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/PCO
@since		30/11/2018
@version	12.1.23
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE BudgetBalanceType

	Local cError			:= ""
	Local aFatherAlias		:= {"AL2", "items", "items"}
	Local cIndexKey			:= "AL2_FILIAL, AL2_TPSALD"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIMANAGER():New("PCOS195","1.001") 	
	
	oApiManager:SetApiAdapter("PCOS195") 
	oApiManager:SetApiMap(ApiMap())
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

/*/{Protheus.doc} POST / BudgetBalanceType/api/pco/v1/BudgetBalanceTypes
Inclui um novo Tipo de Saldo Orçamentário

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, númerico, Número da página inicial da consulta
@param	PageSize	, númerico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/PCO
@since		30/11/2018
@version	12.1.23
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE BudgetBalanceType
	Local aQueryString	:= Self:aQueryString
	Local aFatherAlias		:= {"AL2", "items", "items"}
	Local cIndexKey			:= "AL2_FILIAL, AL2_TPSALD"
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIMANAGER():New("PCOS195","1.001")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"AL2","items", "items"})

	lRet := ManutTP(oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",AL2->AL2_TPSALD})
		lRet := GetMain(@oApiManager, aQueryString, aFatherAlias,.F.,cIndexKey)
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

/*/{Protheus.doc} GET / BudgetBalanceType/api/pco/v1/BudgetBalanceTypes/{Code}
Retorna um Tipo de Saldo Orçamentário específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, númerico, Número da página inicial da consulta
@param	PageSize	, númerico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/PCO
@since		30/11/2018
@version	12.1.23
/*/
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code  WSSERVICE BudgetBalanceType

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
    Local aFatherAlias		:= {"AL2", "items", "items"}
	Local cIndexKey			:= "AL2_FILIAL, AL2_TPSALD"
	Local oApiManager		:= FWAPIMANAGER():New("PCOS195","1.001")
	Local nLenFil			:= TamSX3("AL2_FILIAL")[1]
	local nLenTpS			:= TamSX3("AL2_TPSALD")[1]
	Local cFilAux			:= ""
	Local cTpSAux			:= ""
	
	Default Self:InternalId:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cTpSAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenTpS),nLenTpS)
	
	oApiManager:SetApiMap(ApiMap()) 
    Self:SetContentType("application/json")

	If Len(cFilAux) >= nLenFil .And. Len(cTpSAux) >= nLenTpS
		Aadd(aFilter, {"AL2", "items",{"AL2_TPSALD  = '"+ cTpSAux + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, .F., cIndexKey)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0009, STR0007+cValToChar(nLenFil+nLenTpS)+STR0008,/*cHelpUrl*/,/*aDetails*/) //"O Tipo de Saldo Orçamentário deve possuir pelo menos" //"caracteres" //"Erro ao buscar o Tipo de Saldo Orçamentário!"
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

/*/{Protheus.doc} PUT / BudgetBalanceType/api/pco/BudgetBalanceTypes/{Code}
Altera um Tipo de Saldo Orçamentário específico

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, númerico, Número da página inicial da consulta
@param	PageSize			, númerico, Número de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/PCO
@since		30/11/2018
@version	12.1.23
/*/

WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE BudgetBalanceType

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIMANAGER():New("PCOS195","1.001")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("AL2_FILIAL")[1] + TamSX3("AL2_TPSALD")[1]
	Local nLenFil		:= TamSX3("AL2_FILIAL")[1]
	local nLenTpS		:= TamSX3("AL2_TPSALD")[1]
	Local cFilAux		:= ""
	Local cTpSAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cTpSAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenTpS),nLenTpS)
	
	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"AL2","items", "items"})

	If  Len(cFilAux) >= nLenFil .And. Len(cTpSAux) >= nLenTpS
		If AL2->(Dbseek(cFilAux+cTpSAux))
			lRet := ManutTP(@oApiManager, Self:aQueryString, 4,, self:InternalId, cBody)
		Else 
			lRet := .F.
			oApiManager:SetJsonError("404",STR0010, STR0011 ,/*cHelpUrl*/,/*aDetails*/) //"Erro ao alterar o Tipo de Saldo Orçamentário!" //"Tipo de Saldo Orçamentário não encontrado."
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0010, STR0012 + cValToChar(nLenFields)+STR0008,/*cHelpUrl*/,/*aDetails*/) //"Erro ao alterar o Tipo de Saldo Orçamentário!" //"caracteres" //"O Tipo de Saldo Orçamentário deve possuir pelo menos "
	EndIf

	If lRet
		Aadd(aFilter, {"CTH", "items",{"AL2_TPSALD = '" + AL2->AL2_TPSALD + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete / BudgetBalanceType/api/pco/BudgetBalanceTypes/{Code}
Deleta um Tipo de Saldo Orçamentário específico

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, númerico, Número da página inicial da consulta
@param	PageSize			, númerico, Número de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/PCO
@since		30/11/2018
@version	12.1.23
/*/

WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE BudgetBalanceType

	Local cResp			:= STR0013  //"Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIMANAGER():New("PCOS195","1.001")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("AL2_FILIAL")[1] + TamSX3("AL2_TPSALD")[1]
	Local nLenFil		:= TamSX3("AL2_FILIAL")[1]
	local nLenTpS		:= TamSX3("AL2_TPSALD")[1]
	Local cFilAux		:= ""
	Local cTpSAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cTpSAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenTpS),nLenTpS)
	
	Self:SetContentType("application/json")
	
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If Len(cFilAux) >= nLenFil .And. Len(cTpSAux) >= nLenTpS
		If AL2->(Dbseek(cFilAux+cTpSAux))
			lRet := ManutTP(@oApiManager, Self:aQueryString, 5,, self:InternalId, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404",STR0014 , STR0011,/*cHelpUrl*/,/*aDetails*/) //"Erro ao deletar o Tipo de Saldo Orçamentário!" //"Tipo de Saldo Orçamentário não encontrado."
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0014 , STR0007 + cValToChar(nLenFields) + STR0008,/*cHelpUrl*/,/*aDetails*/) //"Erro ao deletar o Tipo de Saldo Orçamentário!" //"caracteres" //"O Tipo de Saldo Orçamentário deve possuir pelo menos"
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

/*/{Protheus.doc} ManutTP
Realiza a manutenção (inclusão/alteração/exclusão) do Tipo de Saldo Orçamentário

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código 
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Control/PCO
@since		30/11/2018
@version	12.1.23
/*/
Static Function ManutTP(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
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

	EndIf

	If !Empty(cChave)
		cNote 	:= SubStr(cChave, TamSX3("AL2_FILIAL")[1] + 1, TamSX3("AL2_TPSALD")[1] )
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "AL2_TPSALD"}))

	If nOpc == 4
		If nPosCod == 0
			aAdd( aCab, {'AL2_TPSALD' ,cNote, Nil})
		Else
			aCab[nPosCod][2]  := cNote
		EndIf
	EndIf

	If lRet
		oModel := FwLoadModel('PCOA195')
		oModel:SetOperation(nOpc)
		If oModel:Activate()
			If nOpc != 5
				For nX := 1 To Len(aCab)
					If !oModel:SetValue('AL2MASTER', aCab[nX][1], aCab[nX][2])
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
				oApiManager:SetJsonError("400",STR0015, cResp,/*cHelpUrl*/,/*aDetails*/) //"Erro durante Inclusão/Alteração/Exclusão!."
			Else
				AL2->(DbSeek(xFilial("AL2") + oModel:GetValue('AL2MASTER', 'AL2_TPSALD')))
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get do Tipo de Saldo Orçamentário

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Control/PCO
@since		30/11/2018
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

@author		Squad Contol/PCO
@since		30/11/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrAL2		:= {}

	aStrAL2			:=	{"AL2","Fields","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "AL2_FILIAL"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, AL2_FILIAL, AL2_TPSALD"			},;								
								{"Code"							, "AL2_TPSALD"									},;
								{"InternalId"					, "AL2_FILIAL, AL2_TPSALD"						},;
								{"Description"					, "AL2_DESCRI"									};
							},;
						}

	aStructAlias  := {aStrAL2}

	aApiMap := {"PCOS195","items","1.001","PCOI195O",aStructAlias, "items"}

Return aApiMap
