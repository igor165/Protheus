#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS180()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} selleractivity
API de integraçao de Cadastro de Atividades do Vendedor

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSRESTFUL selleractivity DESCRIPTION "Cadastro de Atividades do Vendedor" 

	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA InternalId	    AS STRING	OPTIONAL
	
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todas Atividades" ;
    WSSYNTAX "/api/crm/v1/selleractivity/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/selleractivity"

    WSMETHOD POST Main ;
    DESCRIPTION "Inclui um Atividade" ;
    WSSYNTAX "/api/crm/v1/selleractivity/{Fields}";
    PATH "/api/crm/v1/selleractivity"

    WSMETHOD GET InternalId ;
    DESCRIPTION "Retorna uma Atividade especifico" ;
    WSSYNTAX "/api/crm/v1/selleractivity/{InternalId}{Fields}" ;
    PATH "/api/crm/v1/selleractivity/{InternalId}"

    WSMETHOD PUT InternalId ;
    DESCRIPTION "Altera uma Atividade específico" ;
    WSSYNTAX "/api/crm/v1/selleractivity/{InternalId}{Fields}" ;
    PATH "/api/crm/v1/selleractivity/{InternalId}"

    WSMETHOD DELETE InternalId ;
    DESCRIPTION "Deleta uma Atividade específico" ;
    WSSYNTAX "/api/crm/v1/selleractivity/{InternalId}{Fields}" ;
    PATH "/api/crm/v1/selleractivity/{InternalId}"

ENDWSRESTFUL

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /selleractivity/crm/selleractivity
Retorna lista com todas Atividades

@param	Order		, caracter, Ordenaçao da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serao retornados na requisiçao.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE selleractivity

	Local aFilter		:= {}
    Local cError		:= ""
	Local lRet			:= .T.
	Local oApiManager	:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("CRMS180","1.000")
	aAdd(aFilter, {"AOF", "items",{"AOF_TIPO <> '3'"}})
	oApiManager:SetApiFilter(aFilter)

	If aScan(Self:aQueryString,{|x|x[1]=="DESCRIPTION"}) > 0
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao Listar Atividade!", "Nao e possivel a utilizar o campo Description como Filtro da Atividade.",/*cHelpUrl*/,/*aDetails*/)
	Else
    	lRet    := GetAOF(@oApiManager, Self)
	Endif

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} POST /selleractivity/crm/selleractivity
Inclui uma Atividade

@param	Fields	, caracter, Campos que serao retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE selleractivity

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS180","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AOF","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutAOF(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
            aAdd(aFilter, {"AOF", "items",{"AOF_FILIAL = '" + AOF->AOF_FILIAL + "'"}})
            aAdd(aFilter, {"AOF", "items",{"AOF_CODIGO = '" + AOF->AOF_CODIGO + "'"}})

	        oApiManager:SetApiFilter(aFilter)
			lRet    := GetMain(oApiManager, Self:aQueryString)
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Atividade!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /selleractivity/crm/selleractivity/{InternalId}
Lista uma Atividade específica

@param	InternalId	, caracter, Código do Apontamento
@param	Fields		, caracter, Campos que serao retornados na requisiçao.
@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Fields WSSERVICE selleractivity

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("CRMS180","1.000")

	If aScan(Self:aQueryString,{|x|x[1]=="DESCRIPTION"}) > 0
		lRet := .F.
		oApiManager:SetJsonError("400","Erro ao Listar Atividade!", "Nao e possivel utilizar o campo Description como Filtro da Atividade.",/*cHelpUrl*/,/*aDetails*/)
	Else 
		AOF->(DbSetOrder(1))
		If AOF->(DbSeek( Self:InternalId ))

			aAdd(aFilter, {"AOF", "items",{"AOF_FILIAL = '" + AOF->AOF_FILIAL + "'"}})
			aAdd(aFilter, {"AOF", "items",{"AOF_CODIGO = '" + AOF->AOF_CODIGO + "'"}})
			aAdd(aFilter, {"AOF", "items",{"AOF_TIPO <> '3'"}})

			oApiManager:SetApiFilter(aFilter)
			lRet := GetAOF(@oApiManager, Self)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404","Erro ao listar Atividade!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} PUT /selleractivity/crm/selleractivity/{InternalId}
Altera uma Atividade específica

@param	InternalId	        , caracter, Código do Documento
@param	Order				, caracter, Ordenaçao da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serao retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE selleractivity

	Local aFilter		:= {}
	Local aJson			:= {}
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("CRMS180","1.000")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AOF","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
		AOF->(DbSetOrder(1))
        If AOF->(DbSeek( Self:InternalId ))
			If AOF->AOF_TIPO $ "1#2"
				lRet := ManutAOF(oApiManager, Self:aQueryString, 4, aJson, Self:InternalId, oJson, cBody)
				If lRet
					aAdd(aFilter, {"AOF", "items",{"AOF_FILIAL = '" + AOF->AOF_FILIAL + "'"}})
					aAdd(aFilter, {"AOF", "items",{"AOF_CODIGO = '" + AOF->AOF_CODIGO + "'"}})

					oApiManager:SetApiFilter(aFilter)
					lRet    := GetMain(oApiManager, Self:aQueryString)
				Endif
			Else
				oApiManager:SetJsonError("400","Nao foi possivel alterar atividade informada!", "Tipo de Atividade Invalido",/*cHelpUrl*/,/*aDetails*/)
				lRet := .F.
			Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar Atividade!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Atividade!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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
//--------------------------------------------------------------------
/*/{Protheus.doc} DELETE /selleractivity/crm/selleractivity/{InternalId}
Deleta uma Atividade específica

@param	Code		        , caracter, Código do Documento
@param	Fields				, caracter, Campos que serao retornados na requisiçao.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE Fields WSSERVICE selleractivity

	Local aJson			:= {}
	Local cResp			:= "Registro Excluido com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("CRMS180","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AOF","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	AOF->(DbSetOrder(1))
    If AOF->(DbSeek( Self:InternalId ))
		If AOF->AOF_TIPO $ "1#2"
			lRet := ManutAOF(oApiManager, Self:aQueryString, 5, aJson, Self:InternalId, , cBody)
		Else 			
			oApiManager:SetJsonError("400","Nao foi possivel excluir atividade informada!", "Tipo de Atividade Invalido",/*cHelpUrl*/,/*aDetails*/)
			lRet := .F.
		Endif
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao excluir Atividade!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
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

//--------------------------------------------------------------------
/*/{Protheus.doc} GetAOF
Realiza o Get das Atividades

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetAOF(oApiManager, Self)

	Local aFatherAlias	:=  {"AOF", "items"             , "items"           } 
	Local cIndexKey		:=  "AOF_FILIAL, AOF_CODIGO"
    Local lRet          :=  .T.

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetMain
Realiza o Get das Atividades

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informaçao se existem ou nao mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou nao processar o Get.

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura
@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ApiMap()

    Local aApiMap   := {}
    Local aStrAOF   := {}
    Local aStruct   := {}

    aStrAOF := {"AOF","field","items","items",;
		{;
			{"CompanyId"		    , "Exp:cEmpAnt" 			},;
			{"BranchId"			    , "AOF_FILIAL"				},;
            {"Code" 			    , "AOF_CODIGO"				},;
            {"InternalId"			, "AOF_FILIAL, AOF_CODIGO"  },;
            {"Type"                 , "AOF_TIPO"                },;
            {"Participant"          , "AOF_PARTIC"              },;
            {"LocalActivity"        , "AOF_LOCAL"               },;
            {"Subject"              , "AOF_ASSUNT"              },;
            {"Status"               , "AOF_STATUS"              },;
            {"RegisterDate"         , "AOF_DTCAD"               },;
            {"Description"          , "AOF_DESCRI"              },;
            {"Owner"                , "AOF_CODUSR"              },;
            {"Priority"             , "AOF_PRIORI"              },;
            {"StartDate"            , "AOF_DTINIC"              },;
            {"StartTime"            , "AOF_HRINIC"              },;
            {"EndDate"              , "AOF_DTFIM"               },;
            {"EndTime"              , "AOF_HRFIM"               },;
            {"Duration"             , "AOF_DURACA"              },;
            {"EntityId"             , "AOF_ENTIDA"              },;
            {"KeyEntity"            , "AOF_CHAVE"               },;
            {"RemindDate"           , "AOF_DTLEMB"              },;
            {"RemindTime"           , "AOF_HRLEMB"              },;
            {"Complete"             , "AOF_PERCEN"              },;
            {"ConclusionDate"       , "AOF_DTCONC"              },;
            {"RegisterSituation"    , "AOF_MSBLQL"              };
		},;
	}

    aStruct := {aStrAOF}
	aApiMap := {"CRMS180","items","1.000","CRMS180", aStruct, "items"}

Return aApiMap

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutAOF
Realiza a manutençao (inclusao/alteraçao/exclusao) da Atividade

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operaçao a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do apontamento
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou nao o processo

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutAOF(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)

	Local aCabec	:= {}	
	Local aModif	:= {}
	Local aMsgErro	:= {}
	Local aAux  	:= {}
    Local cResp		:= ""
    Local lRet		:= .T.
    Local nX		:= 0
    Local nType     := 0
	Local oModel  	:= FWLoadModel("CRMA180")
	Local oModelFld	:= oModel:GetModel("AOFMASTER")
	
	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

    If nOpcx <> MODEL_OPERATION_DELETE

        If AttIsMemberOf(oJson, "Type") .And. !Empty(oJson:Type)
			nType   := IIF(ValType(oJson:Type) == "C",Val(oJson:Type),oJson:Type)
		Else
			If nOpcx == MODEL_OPERATION_UPDATE
				nType := Val(AOF->AOF_TIPO)
			Else 
				lRet := .F.
				cResp   := "Tipo da Atividade nao foi informado!"
			Endif			
		Endif

		If lRet 
			If nType <> 1 .And. nType <> 2
				cResp   := "Tipo da Atividade invalido!"
				lRet := .F.
			Endif

			If lRet
				aJson := oApiManager:ToArray(cBody)

				If Len(aJson[1][1]) > 0
					oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabec)
				EndIf

				If nOpcx == MODEL_OPERATION_INSERT
					oModel:SetOperation(MODEL_OPERATION_INSERT)
				Elseif nOpcx == MODEL_OPERATION_UPDATE
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
				Endif
			Endif
		Endif        
	Else
		oModel:SetOperation(MODEL_OPERATION_DELETE)
    Endif    

	If lRet .And. oModel:Activate()
		If oModel:nOperation <> MODEL_OPERATION_DELETE
			aAux := oModelFld:GetStruct():GetFields()
			For nX := 1 To Len (aCabec)
				If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aCabec[nX][1])}) > 0					
                    If VldTpFld( aCabec[nX,1] , nType)
						If !oModelFld:SetValue(aCabec[nX,1], aCabec[nX,2])
							lRet := .F.
							cResp := "Nao foi possivel atribuir o valor " + AllToChar(aCabec[nX,2]) + " ao campo " + aCabec[nX,1] + "."
							Exit
						EndIf
					Endif
				Endif
			Next nX
		Endif

		If lRet
			If oModel:VldData()
				oModel:CommitData()				
			Else
				lRet:= .F.
				aMsgErro	:= oModel:GetErrorMessage()				
				cResp := " Mensagem do erro: " 			 + FwNoAccent( AllToChar( aMsgErro[6]))
				cResp += " Mensagem da solucao: " 		 + FwNoAccent( AllToChar( aMsgErro[7]))
				cResp += " Valor atribuido: " 			 + FwNoAccent( AllToChar( aMsgErro[8]))
				cResp += " Valor anterior: " 			 + FwNoAccent( AllToChar( aMsgErro[9]))
				cResp += " Id do formulário de origem: " + FwNoAccent( AllToChar( aMsgErro[1]))
				cResp += " Id do campo de origem: " 	 + FwNoAccent( AllToChar( aMsgErro[2]))
				cResp += " Id do formulario de erro: " 	 + FwNoAccent( AllToChar( aMsgErro[3]))
				cResp += " Id do campo de erro: " 		 + FwNoAccent( AllToChar( aMsgErro[4]))
				cResp += " Id do erro: " 				 + FwNoAccent( AllToChar( aMsgErro[5]))
			EndIf
		Endif
	Endif
    
    If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusao/Alteracao/Exclusao da Atividade!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	aSize(aModif,0)
	aSize(aAux,0)
	aSize(aCabec,0)
	aSize(aMsgErro,0)
	FreeObj(oModel)
	FreeObj(oModelFld)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} VldTpFld
Validada se os campos informados na requisiçao correspondem ao tipo da Atividade informada.
@param cField	    , Caractere	, Nome do Campo
@param nType		, Numérico	, Tipo da Atividade
@return lRet	    , Lógico	, Retorna se realizou ou nao o processo

@author		Squad Faturamento/CRM
@since		01/11/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function VldTpFld( cField , nType )

    Local aFronze   := {"AOF_FILIAL","AOF_CODIGO","AOF_DTCAD","AOF_DURACA","AOF_DTCONC"}
    Local aCompro   := {"AOF_PARTIC","AOF_HRFIM","AOF_LOCAL"}
    Local aTarefa   := {"AOF_DTLEMB","AOF_HRLEMB"}
    Local lRet  := .T.

    Default cField  := ""
    Default nType   := 0

    If aScan(aTarefa, cField) .And. nType <> 1
        lRet := .F.
    Elseif aScan(aCompro, cField) .And. nType <> 2
        lRet := .F.    
    Elseif aScan(aFronze, cField)
        lRet := .F.
    Endif

    aSize(aCompro,0)
    aSize(aCompro,0)
    aSize(aFronze,0)

Return lRet