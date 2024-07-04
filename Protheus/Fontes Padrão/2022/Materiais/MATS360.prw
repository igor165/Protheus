#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function MATS360()

Return

/*/{Protheus.doc} paymentCondition
API de integração de Cadastro de Condição de Pagamento

@author		Squad Faturamento/CRM
@since		21/09/2018
@version	12.1.21
/*/

WSRESTFUL paymentcondition DESCRIPTION "Cadastro de Condição de Pagamento" 
    
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
    WSDATA code         	AS STRING	OPTIONAL
		
    WSMETHOD GET Main;
    DESCRIPTION "Retorna todas condições de pagamento";
    WSSYNTAX "/api/fat/v1/paymentcondition/{Order, Page, PageSize, Fields}";
    PATH "/api/fat/v1/paymentcondition"

    WSMETHOD POST Main;
    DESCRIPTION "Cadastra uma condição de pagamento";
    WSSYNTAX "/api/fat/v1/paymentcondition/{Fields}";
    PATH "/api/fat/v1/paymentcondition"

    WSMETHOD GET Code;
    DESCRIPTION "Retorna uma condição de pagamento especifica";
    WSSYNTAX "/api/fat/v1/paymentcondition/{code}{Order, Page, PageSize, Fields}";
    PATH "/api/fat/v1/paymentcondition/{code}"

    WSMETHOD PUT Code;
    DESCRIPTION "Altera uma condição de pagamento especifica";
    WSSYNTAX "/api/fat/v1/paymentcondition/{code}{Order, Page, PageSize, Fields}";
    PATH "/api/fat/v1/paymentcondition/{code}"

    WSMETHOD DELETE Code;
    DESCRIPTION "Exclui uma condição de pagamento especifica";
    WSSYNTAX "/api/fat/v1/paymentcondition/{code}{Order, Page, PageSize, Fields}";
    PATH "/api/fat/v1/paymentcondition/{code}"
 
ENDWSRESTFUL

/*/{Protheus.doc} GET /paymentcondition/fat/paymentcondition
Retorna todas Condições de pagamento

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		24/09/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE paymentcondition

    Local cError			:= ""
	Local aRet              := {.F., Nil}
	Local oApiManager		:= Nil
    Local nPage             := 1
    Local nPageSize         := 20
    Local cIndex            := ""
    Local cFields           := ""
    Local aFilter           := {}
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("MATS360","2.001") 

    SetApiQstring(Self:aQueryString, @nPage, @nPageSize, @cIndex, @cFields, @aFilter)

    aRet    := RetGet(cIndex, cFields, nPage, nPageSize, .F., aFilter)

	If aRet[1]
		Self:SetResponse( EncodeUtf8(FwJsonSerialize(aRet[2],.T.,.T.)) )
	Else
        aRet[2] := SetJsonError("404","Registro não encontrado.","Não foi encontrado o registro especificado.",/*cHelpUrl*/,/*aDetails*/)
		cError := EncodeUtf8(FwJsonSerialize(aRet[2],.T.,.T.))
		SetRestFault( Val(aRet[2]['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return aRet[1]

/*/{Protheus.doc} POST /paymentcondition/fat/paymentCondition
Cadastra uma Condição de pagamento

@param	Fields	, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE paymentcondition

	Local aFilter       := {}
    Local aJson         := {}
    Local aRet          := {.F., Nil}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager   := FWAPIManager():New("MATS360","2.001")    
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SE4","items", "items"})
	oApiManager:SetApiMap(ApiMapE4())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutSE4(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
            aAdd(aFilter, {"BRANCHID"   , SE4->E4_FILIAL})
            aAdd(aFilter, {"CODE"       , SE4->E4_CODIGO})
            
            aRet := GetSE4(@oApiManager, Self, aFilter)            
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Condição de Pagamento!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If aRet[1]
		Self:SetResponse( EncodeUtf8(FwJsonSerialize(aRet[2],.T.,.T.)) )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
    aSize(aFilter,0)
    FreeObj( oJson )

Return aRet[1]

/*/{Protheus.doc} PUT /paymentcondition/fat/paymentCondition/{code}
Altera uma Condição de Pagamento específico

@param	code	        , caracter, Código da Condição de pagamento
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/
WSMETHOD PUT code PATHPARAM paymentcondition WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE paymentcondition

	Local aFilter		:= {}
	Local aRet          := {.F., Nil}
    Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.  
    Local oApiManager 	:= FWAPIManager():New("MATS360","1.000")
	Local oJson			:= THashMap():New()	

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SE4","items", "items"})
	oApiManager:SetApiMap(ApiMapE4())
	oApiManager:Activate()

    lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        DBSelectArea("SE4")
        DBSetOrder(1)
        If DbSeek(Self:Code)
            If SE4->E4_TIPO $ "5#6#8"
                lRet := ManutSE4(oApiManager, Self:aQueryString, 4, aJson, Self:code, oJson, cBody)
                If lRet                    
                    aAdd(aFilter, {"BRANCHID"   , SE4->E4_FILIAL})
                    aAdd(aFilter, {"CODE"       , SE4->E4_CODIGO})
                    
                    aRet := GetSE4(@oApiManager, Self, aFilter)            
                Endif
            Else
                lRet := .F.
                oApiManager:SetJsonError("400","Erro ao alterar Condicao de pagamento!", "Tipo de Condicao de pagamento invalido!.",/*cHelpUrl*/,/*aDetails*/)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar Condicao de pagamento!", "Condicao de pagamento "+ Self:Code +" não encontrada.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.
        oApiManager:SetJsonError("400","Erro ao alterar Condicao de pagamento!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If aRet[1]
		Self:SetResponse( EncodeUtf8(FwJsonSerialize(aRet[2],.T.,.T.)) )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize( aFilter, 0)
	aSize( aJson, 0)
    FreeObj( oJson )

Return aRet[1]

/*/{Protheus.doc} GET /paymentcondition/fat/paymentCondition/{code}
Retorna uma condição de pagamento específica

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/09/2018
@version	12.1.21
/*/
WSMETHOD GET code PATHPARAM paymentcondition WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE paymentcondition

	Local aFilter			:= {}
    Local cCodigo           := ""
	Local cError			:= ""
    Local cFil              := ""
    Local aRet              := {.F., Nil}
	Local oApiManager		:= Nil

    cFil    := Substr(Self:code,1,FWSizeFilial())
    cCodigo := Substr(Self:code,FWSizeFilial()+1)
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("MATS360","2.001")

    aAdd(aFilter, {"BRANCHID"   , cFil})
    aAdd(aFilter, {"CODE"       , cCodigo})
    
	aRet := GetSE4(@oApiManager, Self, aFilter)

	If aRet[1]		
		Self:SetResponse( EncodeUtf8(FwJsonSerialize(aRet[2],.T.,.T.)) )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return aRet[1]

/*/{Protheus.doc} DELETE /paymentcondition/fat/paymentCondition/{code}
Deleta uma Condição de pagamento específico

@param	code    	        , caracter, Código da Condição de pagamento
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		26/09/2018
@version	12.1.21
/*/

WSMETHOD DELETE code PATHPARAM code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE paymentcondition

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("MATS360","2.001")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SE4","items", "items"})
	oApiManager:SetApiMap(ApiMapE4())
	oApiManager:Activate()

   	DBSelectArea("SE4")
    DBSetOrder(1)
    If DbSeek(Self:code)
		lRet := ManutSE4(oApiManager, Self:aQueryString, 5, aJson, Self:code, , cBody)
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Condicao de pagamento!", "Condicao de pagamento "+ Self:code +" não encontrada.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutSE4
Realiza a manutenção (inclusão/alteração/exclusão) da Condição de pagamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpcx			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo da condição de pagamento (E4_CODIGO)
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/09/2018
@version	12.1.21
/*/

Static Function ManutSE4(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)
                
    Local aCondPgto  := {}
    Local aMsgErro  := {}    
    Local aAux      := {}
    Local cResp	    := ""
    Local lRet      := .T.
    Local nPosCod   := 0
    Local nI        := 0
    Local oModel    := Nil
    Local oModelSE4 := Nil

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

    If nOpcx != 5

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCondPgto)
		EndIf

        If Len(aJson[1][2]) > 0
			For nI := 1 To Len(aJson[1][2][1])
				oApiManager:ToExecAuto(1, aJson[1][2][1][nI][2], aCondPgto)
			Next
		EndIf

        If Len(aCondPgto) > 0 .or. nOpcx == 4
            MontaCond(cBody,@aCondPgto)
        Endif

        nPosCod	:= (aScan(aCondPgto ,{|x| AllTrim(x[1]) == "E4_CODIGO"}))

    Else
        aAdd(aCondPgto,{"E4_CODIGO" ,SE4->E4_CODIGO     ,Nil})
    Endif

    If Len(aCondPgto) > 0
        oModel := FwLoadModel("MATA360")

        If nOpcx == 3
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            INCLUI  := .T.
            ALTERA  := .F.
        Elseif nOpcx == 4
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            INCLUI  := .F.
            ALTERA  := .T.
        Elseif nOpcx == 5
            oModel:SetOperation(MODEL_OPERATION_DELETE)
            INCLUI  := .F.
            ALTERA  := .F.
        Endif

        oModel:Activate()
        oModelSE4 := oModel:GetModel("SE4MASTER") 

        aAux := oModelSE4:GetStruct():GetFields()

        For nI := 1 To Len(aCondPgto)        
            If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aCondPgto[nI][1])}) > 0            
                If oModel:nOperation <> MODEL_OPERATION_DELETE
	                If !oModel:SetValue('SE4MASTER', aCondPgto[nI][1], aCondPgto[nI][2]) .And. (aCondPgto[nI][1] != "E4_CODIGO" .Or. oModel:nOperation != MODEL_OPERATION_UPDATE)
	                    lRet := .F.
	                    cResp := "Não foi possível atribuir o valor " + AllToChar(aCondPgto[nI][2]) + " ao campo " + aCondPgto[nI][1] + "." 	                    
                        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Contato!.", cResp,/*cHelpUrl*/,/*aDetails*/)
	                EndIf
	            Endif
            EndIf
        Next nI

        If lRet
            If oModel:VldData()
                oModel:CommitData()            
            Else
                lRet := .F.
                aMsgErro := oModel:GetErrorMessage()            

                cResp := "Mensagem do erro: " + StrTran( StrTran( AllToChar(aMsgErro[6]), "<", "" ), "-", "" ) + (" ")
                cResp += "Mensagem da solução: " + StrTran( StrTran( AllToChar(aMsgErro[7]), "<", "" ), "-", "" ) + (" ")
                cResp += "Valor atribuído: " + StrTran( StrTran( AllToChar(aMsgErro[8]), "<", "" ), "-", "" ) + (" ")
                cResp += "Valor anterior: " + StrTran( StrTran( AllToChar(aMsgErro[9]), "<", "" ), "-", "" ) + (" ")
                cResp += "Id do formulário de origem: " + StrTran( StrTran( AllToChar(aMsgErro[1]), "<", "" ), "-", "" ) + (" ")
                cResp += "Id do campo de origem: " + StrTran( StrTran( AllToChar(aMsgErro[2]), "<", "" ), "-", "" ) + (" ")
                cResp += "Id do formulário de erro: " + StrTran( StrTran( AllToChar(aMsgErro[3]), "<", "" ), "-", "" ) + (" ")
                cResp += "Id do campo de erro: " + StrTran( StrTran( AllToChar(aMsgErro[4]), "<", "" ), "-", "" ) + (" ")
                cResp += "Id do erro: " + StrTran( StrTran( AllToChar(aMsgErro[5]), "<", "" ), "-", "" ) + (" ")
                
                oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Contato!.", cResp,/*cHelpUrl*/,/*aDetails*/)
            Endif
        Endif
        oModel:DeActivate()        
    Endif

    aSize(aMsgErro,0)
    aSize(aCondPgto,0)
    aSize(aAux,0)
    FreeObj(oModelSE4)
    FreeObj(oModel)

Return lRet


/*/{Protheus.doc} MontaCond
Realiza o Get das condições de pagamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		21/09/2018
@version	12.1.21
/*/

Static Function MontaCond(cBody,aCondPgto)

    Local cCondicao     := ""
    Local cDias         := ""    
    Local cDiaMes       := ""
    Local cDiaSemana    := ""
    Local cDaysCond     := ""
    Local cDueDay       := ""
    Local cIntervalo    := ""
    Local cParcelas     := ""
    Local cPercent      := ""
    Local nI            := 0
    Local oJson         := Nil

    FWJsonDeserialize(cBody,@oJson)

    If AttIsMemberOf(oJson, "Plots") .And. ValType(oJson:Plots) == "A" .And. Len(oJson:Plots) > 0

        For nI := 1 To Len(oJson:Plots)

            If AttIsMemberOf(oJson:Plots[nI],"Dueday") .And. !Empty(oJson:Plots[nI]:Dueday)
                cDueDay  += cValToChar(oJson:Plots[nI]:Dueday)
            Endif

            If AttIsMemberOf(oJson:Plots[nI],"Percentage") .And. !Empty(oJson:Plots[nI]:Percentage)
                cPercent += cValToChar(oJson:Plots[nI]:Percentage)
            Endif

            If nI < Len(oJson:Plots)
                cDueDay  += ','
                cPercent += ','
            Endif

        Next nI

        cCondicao := "[" + cDueDay + "],[" + cPercent + "]"            
        aAdd( aCondPgto, { 'E4_TIPO'  , "8", Nil})

        If AttIsMemberOf(oJson, "DaysCondition") .And. !Empty(oJson:DaysCondition)
            cDaysCond := FDiasCond(oJson:DaysCondition)
            aAdd( aCondPgto, { 'E4_DDD'  , cDaysCond, Nil})
        Endif

    Else

        If AttIsMemberOf(oJson, "DaysFirstDue") .And. !Empty(oJson:DaysFirstDue)
            cDias := CValToChar(oJson:DaysFirstDue)
        Elseif AttIsMemberOf(oJson, "DaysFirstDue") .And. Empty(oJson:DaysFirstDue)
            cDias := "0"
        Endif

        If AttIsMemberOf(oJson, "QuantityPlots") .And. !Empty(oJson:QuantityPlots)
            cParcelas := CValToChar(oJson:QuantityPlots)
        Endif

        If AttIsMemberOf(oJson, "RangePlots") .And. !Empty(oJson:RangePlots)
            cIntervalo := CValToChar(oJson:RangePlots)
        Endif

        If AttIsMemberOf(oJson, "WeekDayFixed") .And. !Empty(oJson:WeekDayFixed)
            cDiaSemana := CValToChar(oJson:WeekDayFixed)
        Endif

        If AttIsMemberOf(oJson, "DayMonthFixed") .And. !Empty(oJson:DayMonthFixed)
            cDiaMes := CValToChar(oJson:DayMonthFixed)
        Endif

        If AttIsMemberOf(oJson, "DaysCondition") .And. !Empty(oJson:DaysCondition)
            cDaysCond := FDiasCond(oJson:DaysCondition)
            aAdd( aCondPgto, { 'E4_DDD'  , cDaysCond, Nil})
        Endif

        If !Empty(cDiaSemana) 
            aAdd( aCondPgto, { 'E4_TIPO'  , "6", Nil})
            cCondicao := cParcelas + "," + cDias + "," + cDiaSemana + ',' + cIntervalo
        Elseif !Empty(cParcelas) .And. !Empty(cDias) .And. !Empty(cIntervalo)
            aAdd( aCondPgto, { 'E4_TIPO'  , "5", Nil})
            cCondicao := cDias + "," + cParcelas + "," + cIntervalo
        EndIf

    Endif

    If !Empty(cCondicao)
        aAdd( aCondPgto, { 'E4_COND'  , cCondicao, Nil})
    Endif

    FreeObj( oJson )

Return Nil

/*/{Protheus.doc} GetSE4
Realiza o Get das condições de pagamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@param aFilter      , array     , Filtros a serem executados

@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		21/09/2018
@version	12.1.21
/*/

Static Function GetSE4(oApiManager, Self, aFilter)
	Local aRet              := {.F., Nil}
    Local nPage             := 1
    Local nPageSize         := 20
    Local cIndex            := ""
    Local cFields           := ""
	
    SetApiQstring(Self:aQueryString, @nPage, @nPageSize, @cIndex, @cFields, @aFilter)

    aRet    := RetGet(cIndex, cFields, nPage, nPageSize, .T., aFilter)

	If !aRet[1]
        oApiManager:SetJsonError("404","Registro não encontrado.","Não foi encontrado o registro especificado.",/*cHelpUrl*/,/*aDetails*/)
	EndIf
	
Return aRet

/*/{Protheus.doc} DefRelation
Define o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		21/09/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aRelation     :=  {{"E4_FILIAL", "E4_FILIAL"},{"E4_CODIGO", "E4_CODIGO"}}
    Local aFatherAlias	:=	{"SE4","items"  ,"items"    }	
    Local aDueType      :=  {"SE4",""       ,"dueType"  }
    Local aPlot		    :=	{"SE4","Plots"  ,"Plots"    }
    Local cIndexKey		:=  "E4_FILIAL, E4_CODIGO"

    oApiManager:SetApiRelation(aPlot	, aFatherAlias  	, aRelation, cIndexKey)
    oApiManager:SetApiRelation(aDueType	, aPlot  	        , aRelation, cIndexKey)

    oApiManager:SetApiMap(ApiMapE4())

Return Nil

/*/{Protheus.doc} ApiMapE4
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author		Squad Faturamento/CRM
@since		21/09/2018
@version	12.1.21
/*/

Static Function ApiMapE4()

    Local aApiMap   :=  {}
    Local aStrDue   :=  {}
    Local aStrPlt   :=  {}
    Local aStrSE4   :=  {}
    lOCAL aStruct   :=  {}

    aStrSE4 := {"SE4","field","items","items",;
        {;
            {"CompanyId"                ,"Exp:cEmpAnt"                          },;
            {"BranchId"                 ,"E4_FILIAL"                            },;
            {"CompanyInternalId"        ,"Exp:cEmpAnt, E4_FILIAL, E4_CODIGO"    },;
            {"Code"                     ,"E4_CODIGO"                            },;
            {"InternalId"               ,"E4_FILIAL, E4_CODIGO"                 },;
            {"Description"              ,"E4_DESCRI"                            },;
            {"MeanTime"                 ,""                                     },;
            {"DaysFirstDue"             ,"Exp:'cDias'"                          },;
            {"QuantityPlots"            ,"Exp:'cParcelas'"                      },;
            {"RangePlots"               ,"Exp:'cIntervalo'"                     },;
            {"WeekDayFixed"             ,"Exp:'cDiaSemana'"                     },;
            {"DayMonthFixed"            ,"Exp:'cDiaMes'"                        },;
            {"DaysCondition"            ,"Exp:'cDaysCond'"                      },;
            {"FinancialDiscountDays"    ,"E4_DIADESC"                           },;
            {"PercentageDiscountDays"   ,"E4_DESCFIN"                           },;
            {"PercentageIncrease"       ,"E4_ACRSFIN"                           };
        },;
    }

    aStrPlt := {"SE4","item","Plots","Plots",;
        {},;
    }

    aStrDue := {"SE4","Object","","dueType",;    
        {;
            {"DueDay"                   ,"Exp:'cDueDay'"                        },;
            {"Percentage"               ,"Exp:'cPercentag'"                     };
        },;
    }

    aStruct := {aStrSE4,aStrPlt,aStrDue}

    aApiMap := {"MATS360","items","2.001","MATS360",aStruct, "items"}

Return aApiMap

//-------------------------------------------------------------------
/*/{Protheus.doc} FDiasCond
De/para para preenchimento do campo E4_DDD

@param Caracter , cTipo, Tipo recebido na mensagem

@author		Squad Faturamento/CRM
@since		25/09/2018
@version	12.1.21

@return Caracter, Valor transformado
/*/
//-------------------------------------------------------------------

Static Function FDiasCond(cTipo)

    Local cRet  := ""

    Do Case
      Case cTipo == 1
        cRet := 'D' // Data do Dia
      Case cTipo == 2
        cRet := 'L' // Fora o Dia
      Case cTipo == 3
        cRet := 'S' // Fora Semana
      Case cTipo == 4
        cRet := 'Q' // Fora Quinzena
      Case cTipo == 5
        cRet := 'F' // Fora Mês
      Case cTipo == 6
        cRet := 'Z' // Fora Dezena
   EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetApiQstring
Função que seta o Fields, PageSize, Page, Order e Filtros no ApiMap

@param aQueryString   , array, Parâmetros passados na chamada do WebService (Self:aQueryString)
@param nPage        , numérico  , Número da Página
@param nPageSize    , numérico  , Número de registros por página
@param cIndex       , catacter  , Ordem de Retorno
@param cFields      , catacter  , Campos a serem retornados
@param aFilter      , array     , Filtros da consulta

@author Squad CRM/Faturamento
@since 24/07/2018
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function SetApiQstring(aQueryString, nPage, nPageSize, cIndex, cFields, aFilter)
    Local nQueryString  := 0
    Local nLen          := len(aQueryString)

    Default aQueryString := {}
   
	For nQueryString := 1 to nLen
		Do Case
			Case Upper(aQueryString[nQueryString][1]) == "PAGE"
				nPage := aQueryString[nQueryString][2]
			
			Case Upper(aQueryString[nQueryString][1]) == "PAGESIZE"
				nPageSize := aQueryString[nQueryString][2]
			
			Case Upper(aQueryString[nQueryString][1]) == "ORDER"
				cIndex := Upper(aQueryString[nQueryString][2])

			Case Upper(aQueryString[nQueryString][1]) == "FIELDS"
				cFields += aQueryString[nQueryString][2] + "|"

			OtherWise
              
              aAdd(aFilter, {aQueryString[nQueryString][1], aQueryString[nQueryString][2]})

		EndCase 
	Next nQueryString

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetGet
Realiza o Get das condições de pagamento

@param cIndex       , catacter  , Ordem de Retorno
@param cFields      , catacter  , Campos a serem retornados
@param nPage        , numérico  , Número da Página
@param nPageSize    , numérico  , Número de registros por página
@param lEspecifico  , lógico    , Retorna apenas uma condição ou várias
@param aFilter      , array     , Filtros da consulta

@author Squad CRM/Faturamento
@since 24/07/2018
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function RetGet(cIndex, cFields, nPage, nPageSize, lEspecifico, aFilter)
	Local aRet			:= {}
	Local aParcelas		:= {}
	Local cQuery 		:= ""
	Local cCondicao 	:= ""
	Local cDias			:= "" 
	Local cParcelas		:= ""
	Local cIntervalo	:= ""
	Local cDiaSemana	:= ""	
	Local cTemp     	:= ""
	Local lHasNext		:= .F.
	Local lMktPlace		:= .F.
    Local lRet          := .F.
    Local lProc         := .T.
	Local nStart		:= 0
	Local nCount		:= 1
    Local nX            := 0
    Local oObj          := Nil

	Default cFiltro		:= ""
	Default cIndex		:= ""
	Default cFields		:= ""
	Default nPage		:= 1
	Default nPageSize	:= 20
	Default lEspecifico	:= .F.
    Default aFilter      := {}

    cTemp     	:= GetNextAlias()
    lMktPlace 	:= SuperGetMv("MV_MKPLACE",.F.,.F.)
    
    cQuery 		:= " SELECT E4_CODIGO, E4_COND, E4_TIPO, E4_DESCRI, E4_DDD, R_E_C_N_O_ RECNO "
    cQuery 		+= " FROM " + RetSqlName("SE4") + " " + " SE4 "
    cQuery 		+= " WHERE "
    cQuery 		+= " E4_FILIAL = '" + xFilial("SE4") + "' "
    cQuery 		+= " AND E4_TIPO <> '9' "
    cQuery 		+= " AND E4_TIPO <> 'A' "
    cQuery 		+= " AND E4_TIPO <> 'B' "
    cQuery 		+= " AND D_E_L_E_T_ = '' "

    If !Empty(cFiltro)
        cQuery 	+=  cFiltro
    EndIf

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery( cQuery, cTemp )

    If nPage > 1
        nStart := ( (nPage-1) * nPageSize )
        If nStart > 0
            (cTemp)->( DbSkip( nStart ) )
        EndIf
    EndIf

    While (cTemp)->(!EOF()) .And. nCount <= nPageSize
        lProc           := .T.
        cCondicao 	    := ""
        cDias		    := "" 
        cParcelas	    := ""
        cCondicao	    := ""
        aParcelas	    := {}
        cIntervalo	    := ""
        cDiaSemana	    := ""
        cDaysCondition  := ""
        Do Case
            Case (cTemp)->E4_TIPO == '1'
                cCondicao       := RTrim((cTemp)->E4_COND)
                aParcelas       := MontaVencimentos(MntParcela(cCondicao), 1)
                cParcelas       := cValToChar(Len(aParcelas))
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)

            Case (cTemp)->E4_TIPO == '2'
                nMult           := Val(RTrim((cTemp)->E4_COND))
                cCondicao       := (cTemp)->E4_CODIGO
                cDias           := SubStr(cCondicao, 1, 1)
                cDias           := cValToChar(Val(cDias) * nMult)
                cParcelas       := SubStr(cCondicao, 2, 1)
                cIntervalo      := SubStr(cCondicao, 3, 1)
                cIntervalo      := cValToChar(Val(cIntervalo) * nMult)
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)
                aParcelas       := {}

            Case (cTemp)->E4_TIPO == '3'
                cCondicao       := (cTemp)->E4_COND
                cDias           := StrTokArr(cCondicao, ',')[2]                                                
                cParcelas       := StrTokArr(cCondicao, ',')[1]                                                
                cCondicao       := (cTemp)->E4_CODIGO
                aParcelas       := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
                aParcelas       := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
                aParcelas       := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))}) 
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)

            Case (cTemp)->E4_TIPO == '4'
                cCondicao       := RTrim((cTemp)->E4_COND)
                aParcelas       := MntParcela(cCondicao)
                cParcelas       := aParcelas[1][1]
                cIntervalo      := aParcelas[2][1]
                cDiaSemana      := aParcelas[3][1]
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)
                aParcelas       := {}

            Case (cTemp)->E4_TIPO == '5'
                cCondicao       := RTrim((cTemp)->E4_COND)
                aParcelas       := MntParcela(cCondicao)
                cDias           := aParcelas[1][1]
                cParcelas       := aParcelas[2][1]
                cIntervalo      := aParcelas[3][1]
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)
                aParcelas       := {}

            Case (cTemp)->E4_TIPO == '6'
                cCondicao       := RTrim((cTemp)->E4_COND)
                aParcelas       := MntParcela(cCondicao)
                cParcelas       := aParcelas[1][1]
                cDias           := aParcelas[2][1]
                cDiaSemana      := aParcelas[3][1]
                cIntervalo      := aParcelas[4][1]
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)
                aParcelas       := {}

            Case (cTemp)->E4_TIPO == '7'
                If lMktPlace
                    cCondicao   := RTrim((cTemp)->E4_COND)
                    cDias       := StrTokArr(cCondicao, ',')[2]                                                
                    cParcelas   := StrTokArr(cCondicao, ',')[1]
                    cCondicao   := (cTemp)->E4_CODIGO
                    aParcelas   := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
                    aParcelas   := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
                    aParcelas   := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))})       
                    cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)                                          
                Endif
            Case (cTemp)->E4_TIPO == '8'
                cCondicao       := RTrim((cTemp)->E4_COND)
                aParcelas       := MntParcela(cCondicao, 8)
                cParcelas       := cValToChar(Len(aParcelas))
                cDaysCondition  := DiasDaCond((cTemp)->E4_DDD)
        EndCase
        
        If Len(aFilter) > 0
            For nX := 1 To Len(aFilter)
                If aFilter[nX][1] == "QUANTITYPLOTS"
                    If AllTrim(aFilter[nX][2]) != AllTrim(cParcelas)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "BRANCHID"
                    If AllTrim(aFilter[nX][2]) != AllTrim(cFilAnt)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "CODE"
                    If AllTrim(aFilter[nX][2]) != AllTrim((cTemp)->E4_CODIGO)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "DAYSFIRSTDUE"
                    If AllTrim(aFilter[nX][2]) != AllTrim(cDias)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "DAYMONTHFIXED"
                    If AllTrim(aFilter[nX][2]) != ""
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "RANGEPLOTS"
                    If AllTrim(aFilter[nX][2]) != AllTrim(cParcelas)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "COMPANYID"
                    If AllTrim(aFilter[nX][2]) != AllTrim(cEmpAnt)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "COMPANYINTERNALID"
                    If AllTrim(aFilter[nX][2]) != cEmpAnt + cFilAnt + AllTrim((cTemp)->E4_CODIGO)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "DUEDAY"
                    If AllTrim(aFilter[nX][2]) != aParcelas[01][01]
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "PERCENTAGE"
                    If AllTrim(aFilter[nX][2]) != aParcelas[01][02]
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "INTERNALID"
                    If AllTrim(aFilter[nX][2]) != cFilAnt + AllTrim((cTemp)->E4_CODIGO)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "WEEKDAYFIXED"
                    If AllTrim(aFilter[nX][2]) != AllTrim(cIntervalo)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "DESCRIPTION"
                    If AllTrim(aFilter[nX][2]) != AllTrim((cTemp)->E4_DESCRI)
                        lProc := .F.
                    EndIf
                ElseIf aFilter[nX][1] == "DAYSCONDITION"
                    If AllTrim(aFilter[nX][2]) != cDaysCondition
                        lProc := .F.
                    EndIf
                EndIf
            Next
        EndIf

        If lProc
            Aadd(aRet,{(cTemp)->E4_CODIGO, (cTemp)->E4_TIPO, (cTemp)->E4_DESCRI, cCondicao, cDias, cParcelas, cCondicao, aParcelas, cIntervalo, cDiaSemana, cDaysCondition})
            nCount ++
            lRet := .T.
        EndIf

        (cTemp)->(DbSkip())
    EndDo

    lHasNext    := (cTemp)->(!EOF())

    If lRet
        If !Empty(cIndex)
            If cIndex == "QUANTITYPLOTS"
                ASORT(aRet, , , { | x,y | x[06] < y[06] } )
            ElseIf cIndex == "CODE"
                ASORT(aRet, , , { | x,y | x[01] < y[01] } )
            ElseIf cIndex == "DAYSFIRSTDUE"
                ASORT(aRet, , , { | x,y | x[05] < y[05] } )
            ElseIf cIndex == "RANGEPLOTS"
                ASORT(aRet, , , { | x,y | x[09] < y[09] } )
            ElseIf cIndex == "COMPANYINTERNALID"
                ASORT(aRet, , , { | x,y | x[01] < y[01] } )
            ElseIf cIndex == "INTERNALID"
                ASORT(aRet, , , { | x,y | x[01] < y[01] } )
            ElseIf cIndex == "WEEKDAYFIXED"
                ASORT(aRet, , , { | x,y | x[10] < y[10] } )
            ElseIf cIndex == "DESCRIPTION"
                ASORT(aRet, , , { | x,y | x[03] < y[03] } )
            ElseIf cIndex == "DAYSCONDITION"
                ASORT(aRet, , , { | x,y | x[11] < y[11] } )                
            EndIf
        EndIf
        oObj := MontaJson(aRet, lHasNext, lEspecifico, cFields)    
    EndIf
    
    (cTemp)->(DBCloseArea())

Return {lRet, oObj}

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaVencimentos
Monta array com os prazos das parcelas do campo E4_COND.

@param Caracter, cCondicao, Conteudo do campo E4_COND
@param Numérico, nTipo, Tipo da condição de pagamento (E4_TIPO)

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 26/06/2012

@return Array, Array com os valores da condição.
/*/
//-------------------------------------------------------------------
Static Function MontaVencimentos(aParcelas, nTipo)
   Local nI            := 1
   Local nParcelas     := Len(aParcelas)
   Local nTotal        := 0
   Local nValorParcela := Round(100 / nParcelas, 2)

   Do Case
      Case nTipo == 1 .Or. nTipo == 7
         For nI := 1 To nParcelas -1
            aParcelas[nI][2] := cValToChar(nValorParcela)
            nTotal += nValorParcela
         Next nI

         aParcelas[nParcelas][2] := cValToChar(100 - nTotal)
   EndCase
Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} DiasDaCond
Funcao que retorna o número de dias de prazo para o início da primeira
parcela da condição conforme o campo E4_DDD.

@param Caracter, CCond, Valor do campo E4_DDD.

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012

@return Caracter, Quantidade de dias de prazo.
/*/
//-------------------------------------------------------------------
Static Function DiasDaCond(cCond)
   Local cDias := ''

   Do Case
      Case cCond == 'D'
         cDias := 1
      Case cCond == 'L'
         cDias := 2
      Case cCond == 'S'
         cDias := 3
      Case cCond == 'Q'
         cDias := 4
      Case cCond == 'F'
         cDias := 5
      Case cCond == 'Z'
         cDias := 6
   EndCase
Return cDias

//-------------------------------------------------------------------
/*/{Protheus.doc} MntParcela
Monta array com os prazos das parcelas do campo E4_COND.

@param Caracter, cCondicao, Conteudo do campo E4_COND
@param Numérico, nTipo, Tipo da condição de pagamento (E4_TIPO)

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012

@return Array, Array com os valores da condição.

@obs
Alterado para contemplar o tipo 8
Mateus Gustavo de Freitas e Silva 19/07/2012
/*/
//-------------------------------------------------------------------
Static Function MntParcela(cCondicao, nTipo)
   Local nI           := 1  //Controla a posicao do ponteiro que varre os prazos em cCondicao
   Local nInicio      := 1  //Indica a posicao inicial para o SubStr separar o prazo
   Local nQtde        := 1  //Indica a quantidade de caracteres que o SubStr deve pegar
   Local aParcelas    := {} //Array com os prazos da condicao
   local aVencimentos := {} //Array com as datas de vencimento
   Local aPercentuais := {} //Array com os percentuais das parcelas

   If Empty(nTipo) //Parâmetro não informado
      //Varre o conteudo de cCondicao com conteudo do E4_COND
      For nI := 1 To Len(cCondicao)
         //Se caracter atual for uma vírgula, não faz nada
         If (SubStr(cCondicao, nI, 1) != ',')
            If (SubStr(cCondicao, nI + 1, 1) == ',') .Or. ((nI + 1) > Len(cCondicao))
               //Adiciona no array o prazo de vencimento de acordo com nInicio e nQtde
               aAdd(aParcelas, {SubStr(cCondicao, nInicio, nQtde), ''})
               nInicio := nI + 2   //Atualiza nInicio com a posicao inicial do proximo prazo
               nQtde := 0          //Zera nQtde para contar quantos digitos tem o proximo prazo
            EndIf

            nQtde += 1             //Incrementa a quantidade de digitos para o SubStr
         EndIf
      Next nI
   ElseIf nTipo = 8
      For nI := 1 To Len(AllTrim(cCondicao))
         If (SubStr(cCondicao, nI, 1) != '[')
            If (SubStr(cCondicao, nI + 1, 1) == ']') .Or. ((nI + 1) > Len(cCondicao))
               If Empty(aVencimentos)
                  aVencimentos := StrTokArr(SubStr(cCondicao, nInicio, nQtde), ',')
               Else
                  aPercentuais := StrTokArr(SubStr(cCondicao, nInicio, nQtde - 2), ',')
                  Exit
               EndIf

               nQtde := 0
            EndIf

            nQtde += 1
         Else
            nInicio := nI + 1
         EndIf
      Next nI

      For nI := 1 To Len(aVencimentos)
         aAdd(aParcelas, {aVencimentos[nI], aPercentuais[nI]})
      Next nI
   EndIf
Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaJson
Retorna o Json da consulta

@param aRet         , array     , Dados a serem retornados
@param cFields      , catacter  , Campos a serem retornados
@param lHasNext     , lógico    , Informa se existe mais de uma página de retorno
@param lEspecifico  , lógico    , Retorna apenas uma condição ou várias

@author Squad CRM/Faturamento
@since 24/07/2018
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MontaJson(aRet, lHasNext, lEspecifico, cFields)
    Local nX		 := 0
    Local nY		 := 0
    Local oResponse     := JsonObject():New()
    Local oItem         := JsonObject():New()

    If !lEspecifico
        oResponse['items'] := {}
    EndIf

    For nX := 1 To Len(aRet)
        oItem := JsonObject():New()

        If Empty(cFields) .Or. "QuantityPlots" $ cFields
            oItem['QuantityPlots']		:= aRet[nX][06]
        EndIf
        If Empty(cFields) .Or. "BranchId" $ cFields
            oItem['BranchId']			:= cFilAnt
        EndIf
        If Empty(cFields) .Or. "Code" $ cFields
            oItem['Code']				:= aRet[nX][01]
        EndIf
        If Empty(cFields) .Or. "DaysFirstDue" $ cFields
            oItem['DaysFirstDue']		:= aRet[nX][05]
        EndIf
        If Empty(cFields) .Or. "DayMonthFixed" $ cFields
            oItem['DayMonthFixed']		:= ""
        EndIf
        If Empty(cFields) .Or. "RangePlots" $ cFields
            oItem['RangePlots']			:= aRet[nX][09]
        EndIf
        If Empty(cFields) .Or. "CompanyId" $ cFields
            oItem['CompanyId']			:= cEmpAnt
        EndIf
        If Empty(cFields) .Or. "CompanyInternalId" $ cFields
            oItem['CompanyInternalId']	:= cEmpAnt + cFilAnt + aRet[nX][01]
        EndIf
        oItem['Plots']    := {}
        For nY := 1 To Len(aRet[nX][08])
            oPlots := JsonObject():New()
            If Empty(cFields) .Or. "DueDay" $ cFields
                oPlots['DueDay']	:= aRet[nX][08][nY][01]
            EndIf
            If Empty(cFields) .Or. "Percentage" $ cFields
                oPlots['Percentage']:= aRet[nX][08][nY][02]
            EndIf
            aAdd(oItem['Plots'], oPlots)
        Next nY
        If Empty(cFields) .Or. "InternalId" $ cFields
            oItem['InternalId']			:= cFilAnt + aRet[nX][01]
        EndIf
        If Empty(cFields) .Or. "WeekDayFixed" $ cFields
            oItem['WeekDayFixed']		:= aRet[nX][10]
        EndIf
        If Empty(cFields) .Or. "Description" $ cFields
            oItem['Description']		:= aRet[nX][03]
        EndIf
        If Empty(cFields) .Or. "DaysCondition" $ cFields
            oItem['DaysCondition']		:= aRet[nX][11]
        EndIf
    
        If !lEspecifico
            aAdd(oResponse['items'], oItem)
        Else
            oResponse := oItem
        EndIf

    Next nX

    If !lEspecifico
        oResponse['hasNext'] := lHasNext
    EndIf

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} SetJsonError
Função que monta o Json com as descrições dos erros ocorridos.

@param cCode	        , caracter, Código da mensagem
@param cMessage     	, caracter, Mensagem de erro.
@param cDetailedMessage	, caracter, Detelhes da mensagem.
@param cHelpUrl     	, caracter, Url da publicação do help.
@param aDetails     	, array   , Lista com os erros no formato
{{cCode,cMessage,cDetailedMessage,cHelpUrl}}

@author Squad CRM/Faturamento
@since 24/07/2018
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function SetJsonError(cCode,cMessage,cDetailedMessage, cHelpUrl, aDetails)
	Local oItem         := Nil
	Local aItem			:= {}
	Local nLenDetails   := 0
	Local nX            := 0
    Local oJsonError    := Nil

	Default cCode               := ""
	Default cMessage            := ""
	Default cDetailedMessage    := ""
	Default cHelpUrl            := ""
	Default aDetails            := {}

	oJsonError := JsonObject():New()
	oJsonError["code"]             := cCode
	oJsonError["message"]          := cMessage
	oJsonError["detailedMessage"]  := cDetailedMessage
	oJsonError["helpUrl"]          := cHelpUrl

	If Empty( aDetails )
		oItem := JsonObject():New()
		oItem["code"]             := cCode
		oItem["message"]          := cMessage
		oItem["detailedMessage"]  := cDetailedMessage
		aItem := {oItem}
	Else
		nLenDetails := Len(aDetails)
		For nX := 1 To nLenDetails
			aAdd(aItem,JsonObject():New())
			aItem[nX]["code"]             := aDetails[nX][1]
			aItem[nX]["message"]          := aDetails[nX][2]
			aItem[nX]["detailedMessage"]  := aDetails[nX][3]
		Next nX
	EndIf

	oJsonError["details"] := aItem
	
	If !Empty(aItem)
		aSize(aItem,0)
		aItem := {}
	EndIf
Return oJsonError