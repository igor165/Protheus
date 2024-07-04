#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} Events

API de integração de "Cadastro de Eventos"

@author		Squad Faturamento/SRM
@since		09/10/2018
/*/
WSRESTFUL Events DESCRIPTION "Cadastro de Eventos" //"Cadastro de Eventos"
	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code 	        AS STRING	OPTIONAL

WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os eventos" ;
    WSSYNTAX "/api/crm/v1/events/{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/events"

WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo Evento" ;
    WSSYNTAX "/api/crm/v1/events/" ;
    PATH "/api/crm/v1/events"

WSMETHOD GET Code ;
    DESCRIPTION "Consulta um Evento específico" ;
    WSSYNTAX "/api/crm/v1/events/{Code}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/events/{Code}"

WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Evento" ;
    WSSYNTAX "/api/crm/v1/events/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/events/{Code}"

WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um Evento" ;
    WSSYNTAX "/api/crm/v1/events/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/events/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET / Events
Retorna todos as comissões dos vendedores

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.20
/*/
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Events

Local cError			:= ""
Local lRet				:= .T.
Local oApiManager		:= Nil
Local aRelation			:= {{"ACD_FILIAL","ACE_FILIAL"},{"ACD_CODIGO","ACE_CODIGO"}}
Local aFatherAlias		:= {"ACD", "items","items"}
Local aChildrenAlias    := {"ACE", "ListOfEvents", "ListOfEvents" }
Local cIndexKey			:= "ACE_FILIAL, ACE_CODIGO"

Self:SetContentType("application/json")
oApiManager := FwApiManager():New("crms340","1.000") 
oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)

lRet := GetMain(@oApiManager, Self:aQueryString)

If lRet
	Self:SetResponse( oApiManager:GetJsonSerialize() )
Else
	cError := oApiManager:GetJsonError()	
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

FreeObj(oApiManager)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Events

    Return a object with a list of Events data.

@author		Renato da Cunha
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD POST Main  WSSERVICE Events

Local cBody 		    := ""
Local cError		    := ""
Local lRet			    := .T.
Local oJsonPositions    := JsonObject():New()
Local oApiManager 	    := FwApiManager():New("CRMS340","1.000")
Local aRelation			:= {{"ACD_FILIAL","ACE_FILIAL"},{"ACD_CODIGO","ACE_CODIGO"}}
Local aFatherAlias		:= {"ACD", "items","items"}
Local aChildrenAlias    := {"ACE", "ListOfEvents", "ListOfEvents" }
Local cIndexKey			:= "ACE_FILIAL, ACE_CODIGO"
Local aFilter           := {}

Self:SetContentType("application/json")
oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)

cBody := Self:GetContent()

lRet := AtuEvents(3, @oApiManager, cBody)

If lRet
    Aadd(aFilter, {"ACD", "items",{"ACD_FILIAL = '" +ACD->ACD_FILIAL + "'"}})
    Aadd(aFilter, {"ACD", "items",{"ACD_CODIGO = '" +ACD->ACD_CODIGO + "'"}})
    oApiManager:SetApiFilter(aFilter)        
    lRet := GetMain(oApiManager, Self:aQueryString)                      
EndIf 

If lRet
	Self:SetResponse( oApiManager:ToObjectJson() )
Else
	cError := oApiManager:GetJsonError()
	SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
EndIf

oApiManager:Destroy()
FreeObj( oJsonPositions )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Get(Code)
Realiza o Get da tabela ACD

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Events

Local aFilter			:= {}
Local cError			:= ""
Local lRet 				:= .T.
Local oApiManager		:= FwApiManager():New("crms340","1.000")
Local aRelation			:= {{"ACD_FILIAL","ACE_FILIAL"},{"ACD_CODIGO","ACE_CODIGO"}}
Local aFatherAlias		:= {"ACD", "items","items"}
Local aChildrenAlias    := {"ACE", "ListOfEvents", "ListOfEvents" }
Local cIndexKey			:= "ACE_FILIAL, ACE_CODIGO"

Default Self:Code:= ""

Self:SetContentType("application/json")
oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)

Aadd(aFilter, {"ACD", "items",{"ACD_CODIGO = '" + Self:Code + "'"}})
oApiManager:SetApiFilter(aFilter) 	

If lRet
	lRet := GetMain(@oApiManager, Self:aQueryString, .F.)
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

/*/{Protheus.doc} PUT/Events/Code
Altera um evento especíifco

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Events

Local aQueryString		:= Self:aQueryString
Local aAreaACD			:= ACD->(GetArea())
Local cBody 			:= ""
Local cError			:= ""
Local lRet				:= .T.
Local oJsonPositions	:= JsonObject():New()
Local oApiManager 		:= FwApiManager():New("crms340","1.000")
Local cExpression		:= Self:Code
Local aRelation			:= {{"ACD_FILIAL","ACE_FILIAL"},{"ACD_CODIGO","ACE_CODIGO"}}
Local aFatherAlias		:= {"ACD", "items","items"}
Local aChildrenAlias    := {"ACE", "ListOfEvents", "ListOfEvents" }
Local cIndexKey			:= "ACE_FILIAL, ACE_CODIGO"

Self:SetContentType("application/json")

cBody	:= Self:GetContent()
oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)
	
ACD->(dbSetOrder(1))
If ACD->(Dbseek(xFilial("ACD") + cExpression))
    lRet := AtuEvents(4, @oApiManager, cBody, aQueryString, Self:Code)
    If !lRet
        cError := oApiManager:GetJsonError()
	    SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
    EndIf
Else 
    lRet := .F.
    oApiManager:SetJsonError("404","Erro ao alterar o Evento!", "Evento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
EndIf	

If lRet 
    aAdd(aQueryString,{"Code",Self:Code})
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

RestArea(aAreaACD)

Return lRet

/*/{Protheus.doc} DELETE/Events/Code
Deleta um evento especíifco

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		30/08/2018
@version	12.1.20
/*/
WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Events

Local aQueryString		:= Self:aQueryString
Local aAreaACD			:= ACD->(GetArea())
Local cBody 			:= ""
Local cError			:= ""
Local lRet				:= .T.
Local oJsonPositions	:= JsonObject():New()
Local oApiManager 		:= FwApiManager():New("crms340","1.000")
Local cExpression		:= Self:Code
Local aRelation			:= {{"ACD_FILIAL","ACE_FILIAL"},{"ACD_CODIGO","ACE_CODIGO"}}
Local aFatherAlias		:= {"ACD", "items","items"}
Local aChildrenAlias    := {"ACE", "ListOfEvents", "ListOfEvents" }
Local cIndexKey			:= "ACE_FILIAL, ACE_CODIGO"
Local cResp             := "Registro Deletado com Sucesso"

Self:SetContentType("application/json")

cBody	:= Self:GetContent()
oApiManager:SetApiRelation(aChildrenAlias,aFatherAlias,aRelation,cIndexKey)
	
ACD->(dbSetOrder(1))
If ACD->(Dbseek(xFilial("ACD") + cExpression))
    lRet := AtuEvents(5, @oApiManager, cBody, aQueryString, Self:Code)
Else 
    lRet := .F.
    oApiManager:SetJsonError("404","Erro ao deletar o Evento!", "Evento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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
FreeObj( aQueryString )	

RestArea(aAreaACD)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetMain
Realiza o Get da tabela ACD

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param lHasNext		, Lógico	, Informa se informará se existem ou não mais páginas a serem exibidas

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, lHasNext)

//Local aRelation			:= //{{"ACD_FILIAL","ACE_FILIAL"},{"ACD_CODIGO","ACE_CODIGO"}}
Local aFatherAlias		:= {"ACD", "items","items"}
Local aChildrenAlias    := {"ACE", "ListOfEvents", "ListOfEvents" }
Local cIndexKey			:= "ACE_FILIAL, ACE_CODIGO"
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
//FreeObj( aRelation )
FreeObj( aFatherAlias )	
FreeObj( aChildrenAlias )	

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
Static Function ApiMap()
Local apiMap		:= {}
Local aStrACDPai    := {}
Local aStructAlias  := {}

aStrACDPai    :=	{"ACD","Field","items","items",;
						{;
							{"CompanyId"							, "Exp:cEmpAnt"									},;
							{"BranchID"								, "Exp:cFilAnt"									},;
							{"CompanyInternalId"					, "Exp:cEmpAnt, Exp:cFilAnt, ACD_CODIGO"		},;
							{"Code"		                            , "ACD_CODIGO"									},;
							{"Description"		                    , "ACD_DESC"									},;
							{"Location"		                        , "ACD_LOCAL"									},;
							{"InitDate"	                            , "ACD_DTINI"									},;
							{"EndDate"              				, "ACD_DTFIM"							        },;
							{"InitialTime"					        , "ACD_HRINI"									},;
							{"EndTime"					            , "ACD_HRFIM"									},;
							{"Blocked"							    , "ACD_MSBLQL"									};
                        };
                    }
aStructGrid :=      { "ACE", "ITEM", "ListOfEvents", "ListOfEvents",;
                        {;
                            {"GradeDescription"						, "ACE_GRADE"									},;
                            {"ThemeDescription"						, "ACE_TEMA"									},;
							{"InitialTimeGrade"     				, "ACE_HRINI"									},;
							{"EndTimeGrade"							, "ACE_HRFIM"									},;
							{"GradeInitDate"						, "ACE_DATA"									},;
							{"Room"         						, "ACE_SALA"									},;
							{"Responsible"     						, "ACE_PALEST"									},;
							{"RoomCapacity"    						, "ACE_CAPAC"									},;
							{"Margin"					            , "ACE_MARGEM"									},;
							{"Status"								, "ACE_STATUS"									};
						};
					}

aStructAlias  := {aStrACDPai,aStructGrid}

apiMap := {"CRMS340","items","1.000","CRMA340",aStructAlias,"items"}

Return apiMap

/*/{Protheus.doc} AtuEvents
Atulizção dos Eventos

@return lRet,  .T. Atualizado com sucesso
               .F. Problema na atualização
@author		Squad Faturamento/CRM
@since		09/10/2018
@version	12.1.20
/*/
Static Function AtuEvents(nOpc, oApiManager, cBody, aQueryString, cEvent)

Local lRet              := .T.
Local aCab              := {}
Local aItens            := {}
Local aItem             := {}
Local aJson             := {}
Local aMsgErro          := {}
Local aFatherAlias	    := {"ACD","items", "items"}
Local nX                := 0    

Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T. 
Private lMsHelpAuto	    := .T. 

Default aQueryString    := {}
Default cEvent          := ""

oApiManager:SetApiQstring(aQueryString)
oApiManager:SetApiAlias(aFatherAlias)
oApiManager:Activate()

If !oApiManager:IsActive()
	lRet := .F.
Else
    If nOpc != 5
        aJson := oApiManager:ToArray(cBody)

        If Len(aJson[1][1]) > 0
            oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
        EndIf

        If Len(aCab) > 0
            aCab	:= oApiManager:ToExecAuto(1,aJson[1][1][1][2], aCab)
            aSort(aCab,,,{ | x,y | x[1] < y[1] } )
            If Len(aJson[1][2]) > 0
                For nX:= 1 to Len(aJson[1][2][1])
                    oApiManager:ToExecAuto(2,aJson[1][2][1][nX][2],aItens)
                Next nX
            EndIf        
        Else
			lRet := .F.
			oApiManager:SetJsonError("400","Erro na Leitura do Json!.", "Informe um Json Válido",/*cHelpUrl*/,/*aDetails*/)
        EndIf
    Else
        aAdd( aCab, {'ACD_CODIGO' ,ACD->ACD_CODIGO, Nil})
        aAdd( aCab, {'ACD_DESC' ,ACD->ACD_DESC, Nil})
        aAdd( aCab, {'ACD_LOCAL' ,ACD->ACD_LOCAL, Nil})
        aAdd( aCab, {'ACD_DTINI' ,ACD->ACD_DTINI, Nil})
        aAdd( aCab, {'ACD_DTFIM' ,ACD->ACD_DTFIM, Nil})
        aAdd( aCab, {'ACD_HRINI' ,ACD->ACD_HRINI, Nil})
        aAdd( aCab, {'ACD_HRFIM' ,ACD->ACD_HRFIM, Nil})
        aAdd( aCab, {'ACD_MSBLQL' ,ACD->ACD_MSBLQL, Nil})

        If ACE->(DbSeek(xFilial("ACE") + ACD->ACD_CODIGO))
            While ACE->ACE_CODIGO == ACD->ACD_CODIGO
                Aadd(aItem,{"ACE_CODIGO", ACE->ACE_CODIGO, Nil})
                Aadd(aItem,{"ACE_GRADE", ACE->ACE_GRADE, Nil})
                Aadd(aItem,{"ACE_TEMA", ACE->ACE_TEMA, Nil})
                Aadd(aItem,{"ACE_HRINI", ACE->ACE_HRINI, Nil})
                Aadd(aItem,{"ACE_HRFIM", ACE->ACE_HRFIM, Nil})
                Aadd(aItem,{"ACE_DATA", ACE->ACE_DATA, Nil})
                Aadd(aItem,{"ACE_SALA", ACE->ACE_SALA, Nil})
                Aadd(aItem,{"ACE_PALEST", ACE->ACE_PALEST, Nil})
                Aadd(aItem,{"ACE_CAPAC", ACE->ACE_CAPAC, Nil})
                Aadd(aItem,{"ACE_MARGEM", ACE->ACE_MARGEM, Nil})
                Aadd(aItem,{"ACE_STATUS", ACE->ACE_STATUS, Nil})
                ACE->(DbSkip())
            EndDo
            Aadd(aItens,aItem)
        EndIf
    EndIf

    If lRet
        MSExecAuto( { |a, b, c, d, e| Tmka340(a, b, c, d, e ) },,,aCab, aItens, nOpc )
        If lMsErroAuto
            aMsgErro := GetAutoGRLog()
            cResp	 := ""
            For nX := 1 To Len(aMsgErro)
                cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
            Next nX	
            lRet := .F.
            oApiManager:SetJsonError("400","Erro durante inclusão/alteração do Evento!.", cResp,/*cHelpUrl*/,/*aDetails*/)
        EndIf
    Else
        oApiManager:SetJsonError("400","Erro durante a conversão do Json!.", "Verifique o Json Informado",/*cHelpUrl*/,/*aDetails*/)
    EndIf
EndIf

FreeObj( aCab )
FreeObj( aItens )
Return lRet