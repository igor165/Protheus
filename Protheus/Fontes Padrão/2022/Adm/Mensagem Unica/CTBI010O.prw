#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CTBI010O.CH"

//dummy function
Function CTBI010O()
Return

/*/{Protheus.doc} AccountingCalendar

API de integração de AccountingCalendar

@author		Squad Control/CTB
@since		13/11/2018
/*/
WSRESTFUL AccountingCalendar DESCRIPTION STR0001 //"Cadastro de Calendário Contábil"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
	WSDATA InternalId		AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION STR0002; //"Carrega todos os Calendários Contábeis"
    WSSYNTAX "/api/ctb/v1/AccountingCalendar/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/AccountingCalendar"

    WSMETHOD POST Main ;
    DESCRIPTION STR0003; //"Cadastra uma Novo Calendário Contábil"
    WSSYNTAX "/api/ctb/v1/AccountingCalendar/{Fields}" ;
    PATH "/api/ctb/v1/AccountingCalendar"

	WSMETHOD GET InternalId ; //Code ;
    DESCRIPTION STR0004; //"Carrega um Calendário Contábil Especifíco"
    WSSYNTAX "/api/ctb/v1/AccountingCalendar/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/AccountingCalendar/{InternalId}"	

	WSMETHOD PUT InternalId ;
    DESCRIPTION  STR0005; //"Altera um Calendário Contábil"
    WSSYNTAX "/api/ctb/v1/AccountingCalendar/{InternalId}/{Fields}" ;
    PATH "/api/ctb/v1/AccountingCalendar/{InternalId}"	

	WSMETHOD DELETE InternalId ;
    DESCRIPTION STR0006; //"Deleta um Calendário Contábil específico"
    WSSYNTAX "/api/ctb/v1/AccountingCalendar/{InternalId}" ;
    PATH "/api/ctb/v1/AccountingCalendar/{InternalId}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET / AccountingCalendar/api/ctb/v1/AccountingCalendar
Retorna todos os Calendários Contábeis

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		13/11/2018
@version	12.1.23
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE AccountingCalendar

	Local cError			:= ""
	Local aFatherAlias		:= {"CTG", "items", "items"}
	Local cIndexKey			:= "CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIMANAGER():New("CTBS010","1.001") 	
	
	oApiManager:SetApiAdapter("CTBS010") 
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

/*/{Protheus.doc} POST / AccountingCalendar/api/ctb/v1/AccountingCalendar
Inclui um novo Calendário Contábil

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		13/11/2018
@version	12.1.23
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE AccountingCalendar
	Local aQueryString	:= Self:aQueryString
	Local aFatherAlias		:= {"CTG", "items", "items"}
	Local cIndexKey			:= "CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD"
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIMANAGER():New("CTBS010","1.001")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTG","items", "items"})

	lRet := ManutCV(oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",CTG->CTG_CALEND})
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

/*/{Protheus.doc} GET / AccountingCalendar/api/ctb/v1/AccountingCalendar/{InternalId}
Retorna um Calendário Contábil especifíco

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		13/11/2018
@version	12.1.23
/*/
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code  WSSERVICE AccountingCalendar

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local aFatherAlias		:= {"CTG", "items", "items"}
	Local cIndexKey			:= "CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD"
	Local oApiManager		:= FWAPIMANAGER():New("CTBS010","1.001")
	Local nLenFil			:= TamSX3("CTG_FILIAL")[1]
	local nLenCV			:= TamSX3("CTG_CALEND")[1]
    local nLenEX			:= TamSX3("CTG_EXERC")[1]
	local nLenPD			:= TamSX3("CTG_PERIOD")[1]
	Local cFilAux			:= ""
	Local cCVAux			:= ""
    Local cPDAux			:= ""
	Local cEXAux			:= ""
	
	Default Self:InternalId:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCVAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCV),nLenCV)
	cEXAux  := PADR(SubStr(self:InternalId,nLenFil+nLenCV+1,nLenEX),nLenEX)
	cPDAux  := PADR(SubStr(self:InternalId,nLenFil+nLenCV+nLenEX+1,nLenPD),nLenPD)
	
	oApiManager:SetApiMap(ApiMap()) 
    Self:SetContentType("application/json")

	If Len(cFilAux) >= nLenFil .And. Len(cCVAux) >= nLenCV .And. Len(cPDAux) >= nLenPD
		Aadd(aFilter, {"CTG", "items",{"CTG_CALEND  = '"+ cCVAux + "' AND CTG_EXERC  = '"+ cEXAux + "' AND CTG_PERIOD  = '"+ cPDAux + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, .F., cIndexKey)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0008, STR0007+cValToChar(nLenFil+nLenCV+nLenEX+nLenPD)+"caracteres",/*cHelpUrl*/,/*aDetails*/) //"O Calendário deve possuir pelo menos" //"Erro buscar o Calendário Contábil!"
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

/*/{Protheus.doc} PUT / AccountingCalendar/api/ctb/v1/AccountingCalendar/{Code}
Altera um Calendário Contábil

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		13/11/2018
@version	12.1.23
/*/

WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE AccountingCalendar

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIMANAGER():New("CTBS010","1.001")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("CTG_FILIAL")[1] + TamSX3("CTG_CALEND")[1]
	Local nLenFil		:= TamSX3("CTG_FILIAL")[1]
	local nLenCV		:= TamSX3("CTG_CALEND")[1]
    local nLenEX		:= TamSX3("CTG_EXERC")[1]
	local nLenPD		:= TamSX3("CTG_PERIOD")[1]
	Local cFilAux		:= ""
	Local cCVAux		:= ""
    Local cPDAux		:= ""
	Local cEXAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCVAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCV),nLenCV)
	cEXAux  := PADR(SubStr(self:InternalId,nLenFil+nLenCV+1,nLenEX),nLenEX)
	cPDAux  := PADR(SubStr(self:InternalId,nLenFil+nLenCV+nLenEX+1,nLenPD),nLenPD)
	
	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTG","items", "items"})

	If  Len(cFilAux) >= nLenFil .And. Len(cCVAux) >= nLenCV
		If CTG->(Dbseek(cFilAux+cCVAux+cEXAux+cPDAux))
			lRet := ManutCV(@oApiManager, Self:aQueryString, 4,, self:InternalId, cBody)
		Else 
			lRet := .F.
			oApiManager:SetJsonError("404",STR0010, STR0009,/*cHelpUrl*/,/*aDetails*/) //"Erro ao alterar a Calendário Contábil!" //"Calendário Contábil não encontrado."
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0011, STR0012 + cValToChar(nLenFields)+"caracteres",/*cHelpUrl*/,/*aDetails*/) //"O Calendário Contábil deve possuir pelo menos " //"Erro ao alterar Calendário Contábil!"
	EndIf

	If lRet
		Aadd(aFilter, {"CTG", "items",{"CTG_CALEND  = '"+ CTG->CTG_CALEND + "' AND CTG_EXERC  = '"+ CTG->CTG_EXERC + "' AND CTG_PERIOD  = '"+ CTG->CTG_PERIOD + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete / AccountingCalendar/api/ctb/v1/AccountingCalendar/{Code}
Deleta um Calendário Contábil específico

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		13/11/2018
@version	12.1.23
/*/

WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE AccountingCalendar

	Local cResp			:= STR0013 //"Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIMANAGER():New("CTBI010O","1.001")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("CTG_FILIAL")[1] + TamSX3("CTG_CALEND")[1]
	Local nLenFil		:= TamSX3("CTG_FILIAL")[1]
	local nLenCV		:= TamSX3("CTG_CALEND")[1]
    local nLenEX		:= TamSX3("CTG_EXERC")[1]
	local nLenPD		:= TamSX3("CTG_PERIOD")[1]
	Local cFilAux		:= ""
	Local cCVAux		:= ""
    Local cPDAux		:= ""
	Local cEXAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCVAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCV),nLenCV)
	cEXAux  := PADR(SubStr(self:InternalId,nLenFil+nLenCV+1,nLenEX),nLenEX)
	cPDAux  := PADR(SubStr(self:InternalId,nLenFil+nLenCV+nLenEX+1,nLenPD),nLenPD)
	
	Self:SetContentType("application/json")
	
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If Len(cFilAux) >= nLenFil .And. Len(cCVAux) >= nLenCV
		If CTG->(Dbseek(cFilAux+cCVAux+cEXAux+cPDAux))
			lRet := ManutCV(@oApiManager, Self:aQueryString, 5,, self:InternalId, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404",STR0014, STR0015,/*cHelpUrl*/,/*aDetails*/) //"Calendário Contábilr não encontrado." //"Erro ao deletar o Calendário Contábil!"
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0015,  STR0016+ cValToChar(nLenFields) + "caracteres",/*cHelpUrl*/,/*aDetails*/) //"Erro ao deletar o Calendário Contábil!" //"O Calendário Contábil deve possuir pelo menos"
	EndIf

	If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError))
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} ManutCV
Realiza a manutenção (inclusão/alteração/exclusão) do Calendário Contábil

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código 
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Control/CTB
@since		13/11/2018
@version	12.1.23
/*/
Static Function ManutCV(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cError			:= ""
	Local cCalend			:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nPosCod			:= 0
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
	Local oModel			:= Nil
	Local nPos				:= 0
	
	Default aJson			:= {}
	Default cChave 			:= ""
	Default aItens			:= {}
	Default aItems			:= {}

	Private lAutoErrNoFile	:= .T.
	Private lMsErroAuto 	:= .F.

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf
		
		aItens := {}

		If (nPos:= Ascan(aCab,{|x| Alltrim(x[1]) = "CTG_PERIOD"})) > 0
			aadd(aItens, aCab[nPos][2])
		EndIf
		
		If (nPos:= Ascan(aCab,{|x| Alltrim(x[1]) = "CTG_DTINI"})) > 0
			aadd(aItens, aCab[nPos][2])
		EndIf
		
		If (nPos:= Ascan(aCab,{|x| Alltrim(x[1]) = "CTG_DTFIM"})) > 0
			aadd(aItens, aCab[nPos][2])
		EndIf
		
		If (nPos:= Ascan(aCab,{|x| Alltrim(x[1]) = "CTG_STATUS"})) > 0
			aadd(aItens, aCab[nPos][2])
		EndIf
				
		aadd(aItens, .F.)
		aadd(aItems, aItens)
		
	EndIf
	
	If !Empty(cChave)
		cCalend 	:= SubStr(cChave, TamSX3("CTG_FILIAL")[1] + 1, TamSX3("CTG_CALEND")[1])
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CTG_CALEND"}))

	If nOpc == 4 .Or. nOpc == 5
		If nPosCod == 0
			aAdd( aCab, {'CTG_CALEND' ,cCalend, Nil})
		Else
			aCab[nPosCod][2]  := cCalend
		EndIf
	EndIf

	If lRet
		MSExecAuto({|x,y,z| CTBA010(x,y,z)}, aCab, aItems, nOpc)
		If lMsErroAuto	
			lRet := .F.
			aMsgErro:= GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				If ValType(aMsgErro[nX]) == "C"
					cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
				EndIf
			Next nX	
			oApiManager:SetJsonError("400",STR0017, cResp,/*cHelpUrl*/,/*aDetails*/) //"Erro durante Inclusão/Alteração/Exclusão do Calendário Contábil"
		Else	
			If nOpc != 5
			CTG->(DbSeek(xFilial("CTG") + aCab[5][2] + aCab[2][2] + aCab[1][2]))
			Endif
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get do Calendário Contábil

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Control/CTB
@since		13/11/2018
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

@author		Squad Contol/CTB
@since		13/11/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrCTG		:= {}

	aStrCTG			:=	{"CTG","Fields","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									   			  },;
								{"BranchId"						, "CTG_FILIAL"								   	   			  },;
								{"CompanyInternalId"			, "Exp:cEmpAnt, CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD"},;								
								{"Code"							, "CTG_CALEND"									   			  },;
								{"InternalId"					, "CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD"  			  },;
								{"RegisterSituation"			, "CTG_STATUS"									   			  },;
								{"Year"							, "CTG_EXERC"									   			  },;
								{"Period"   					, "CTG_PERIOD"									   			  },;
								{"InitialDate"					, "CTG_DTINI"									   			  },;
								{"FinalDate"					, "CTG_DTFIM"									   			  };
							},;
						}

	aStructAlias  := {aStrCTG}

	aApiMap := {"CTBS010","items","1.001","CTBI010O",aStructAlias, "items"}

Return aApiMap
