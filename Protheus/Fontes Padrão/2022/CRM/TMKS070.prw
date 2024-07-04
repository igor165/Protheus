#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function TMKS070()

Return

/*/{Protheus.doc} Contact
API de integração de Cadastro de Contatos

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

WSRESTFUL contact DESCRIPTION "Cadastro de Contatos" 

	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA contactId    	AS STRING	OPTIONAL
	
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todos Contatos" ;
    WSSYNTAX "/api/crm/v1/contact/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contact"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um Contato" ;
    WSSYNTAX "/api/crm/v1/contact/{Fields}";
    PATH "/api/crm/v1/contact"

    WSMETHOD GET ContactId ;
    DESCRIPTION "Retorna um Contato" ;
    WSSYNTAX "/api/crm/v1/contact/{contactId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contact/{contactId}"

    WSMETHOD PUT ContactId ;
    DESCRIPTION "Altera um Contato específico" ;
    WSSYNTAX "/api/crm/v1/contact/{contactId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contact/{contactId}"

    WSMETHOD DELETE ContactId ;
    DESCRIPTION "Deleta um Contato específico" ;
    WSSYNTAX "/api/crm/v1/contact/{contactId}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/contact/{contactId}"
 
ENDWSRESTFUL

/*/{Protheus.doc} GET / contact/contact
Retorna todos Contatos

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contact

    Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("TMKS070","1.000") 

    lRet    := GetSU5(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / contact/contact
Cadastra um Contatos

@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE contact

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("TMKS070","1.000")
	Local oJson			:= THashMap():New()    
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SU5","items", "items"})
	oApiManager:SetApiMap(ApiMapU5())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutSU5(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
	        Aadd(aFilter, {"SU5", "items",{"U5_CODCONT = '" + SU5->U5_CODCONT + "'"}})
	        oApiManager:SetApiFilter(aFilter)	    
            lRet    := GetSU5(@oApiManager, Self)
        Endif
    Else        
        oApiManager:SetJsonError("400","Erro ao Incluir Contato!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} GET / contact/contact/{contactId}
Retorna um Contato específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.20
/*/

WSMETHOD GET contactId PATHPARAM contactId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE contact

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("TMKS070","1.000")   

	Aadd(aFilter, {"SU5", "items",{"U5_CODCONT = '" + Self:contactId + "'"}})
	oApiManager:SetApiFilter(aFilter)    
	lRet := GetSU5(@oApiManager, Self)

	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} PUT / contact/{contactId}
Altera um Contato específico

@param	contactId	        , caracter, Código do Contato
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

WSMETHOD PUT contactId PATHPARAM contactId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE contact

	Local aFilter		:= {}
	Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.    
	Local oApiManager 	:= FWAPIManager():New("TMKS070","1.000")
	Local oJson			:= THashMap():New()	

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SU5","items", "items"})
	oApiManager:SetApiMap(ApiMapU5())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        If SU5->(DbSeek(xFilial("SU5") + Self:contactId))
		    lRet := ManutSU5(oApiManager, Self:aQueryString, 4, aJson, Self:contactId, oJson, cBody)
            If lRet
	            Aadd(aFilter, {"SU5", "items",{"U5_CODCONT = '" + SU5->U5_CODCONT + "'"}})
                oApiManager:SetApiFilter(aFilter)	    
                lRet    := GetSU5(@oApiManager, Self)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar o Contato!", "Contato não encontrado.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Contato!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DELETE / contact/{contactId}/
Deleta um Contato específico

@param	contactId	        , caracter, Código do Contato
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		11/09/2018
@version	12.1.21
/*/

WSMETHOD DELETE contactId PATHPARAM contactId WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE contact

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("TMKS070","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SU5","items", "items"})
	oApiManager:SetApiMap(ApiMapU5())
	oApiManager:Activate()

    If SU5->(DbSeek(xFilial("SU5") + Self:contactId))
		lRet := ManutSU5(oApiManager, Self:aQueryString, 5, aJson, Self:contactId, , cBody)        
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Contato!", "Contato não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} ManutSU5
Realiza a manutenção (inclusão/alteração/exclusão) do Contato

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do contato (U5_CODCONT)
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function ManutSU5(oApiManager, aQueryString, nOpc, aJson, cChave, oJson, cBody)
                
    Local   aContato        := {}
    Local   aEndereco       := {}
    Local   aTelefone       := {}
    Local   aMsgErro        := {}			
    Local   cCodigo         := ""
    Local   cResp	        := ""
    Local   lRet            := .T.
    Local   nPosCod         := 0
    Local   nX              := 0

    Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

    If !Empty(cChave)
		cCodigo := SubStr(cChave, 1, TamSX3("U5_CODCONT")[1] )
	EndIf

    If nOpc != 5

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aContato)
		EndIf

        If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2][1])
				oApiManager:ToExecAuto(1, aJson[1][2][1][nX][2], aContato)
			Next
		EndIf

        If Len(aJson[1][3]) > 0
			For nX := 1 To Len(aJson[1][3][1])
				MontaCab(aJson[1][3][1][nX], aContato)
			Next
		EndIf

        nPosCod	:= (aScan(aContato ,{|x| AllTrim(x[1]) == "U5_CODCONT"}))

        If nOpc == 4 .And. nPosCod > 0
			aContato[nPosCod][2]  := cCodigo
        Elseif nOpc == 4 .And. nPosCod == 0
            aAdd(aContato,{"U5_CODCONT" ,cChave     ,Nil})
        Endif

    Else
        aAdd(aContato,{"U5_CODCONT" ,cChave     ,Nil})
        aAdd(aContato,{"U5_CONTAT"  ,"Exclusao" ,Nil})
    Endif
    
    MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},aContato,nOpc,aEndereco,aTelefone, .T.) 

    If lMsErroAuto
        aMsgErro := GetAutoGRLog()
        cResp	 := ""
        For nX := 1 To Len(aMsgErro)
            cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ")
        Next nX	
        lRet := .F.
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Contato!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

    aSize(aMsgErro,0)
    aSize(aTelefone,0)
    aSize(aEndereco,0)
    aSize(aContato,0)    

Return lRet

/*/{Protheus.doc} MontaCab
Monta o array do cabeçalho que será utilizado no execauto

@param	oJson				, objeto  , Objeto com o array parseado
@param	aContato				, array   , Array que será populado com os dados do Json parciado
@return Nil                 , Nulo	   

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function MontaCab(oJson, aContato)

	If AttIsMemberOf(oJson, "name") .And. AttIsMemberOf(oJson, "id") .And. !Empty(oJson:id) .And. !Empty(oJson:name)
		If AllTrim(oJson:name) $ "CPF|CNPJ"
			aAdd( aContato, {'U5_CPF' 		,oJson:id, Nil}) 
        ElseIf AllTrim(oJson:name) $ "RG"
			aAdd( aContato, {'U5_RG' 		,oJson:id, Nil}) 
        ElseIf AllTrim(oJson:name) $ "OAB"
			aAdd( aContato, {'U5_OAB' 		,oJson:id, Nil}) 
	    EndIf
    Endif
    
Return Nil

/*/{Protheus.doc} GetSU5
Realiza o Get dos contatos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function GetSU5(oApiManager, Self)

	Local aFatherAlias	:=  {"SU5","items"							, "items"}
	Local cIndexKey		:=  " U5_FILIAL, U5_CODCONT "
    Local lRet          :=  .T.

    If Len(oApiManager:GetApiRelation()) == 0
	    DefRelation(@oApiManager)
    Endif

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aRelation     :=  {{"U5_FILIAL", "U5_FILIAL"},{"U5_CODCONT", "U5_CODCONT"}}
    Local aFatherAlias	:=	{"SU5", "items"							, "items"                           }
    Local aChiAddres   	:= 	{"SU5","address"						, "address"                         }
    Local aChiCity   	:= 	{"SU5","city"							, "city"                            }	
    Local aChiComInfo	:=	{"SU5","listOfCommunicationInformation"	, "listOfCommunicationInformation"  }
	Local aChiCountr   	:= 	{"SU5","country"						, "country"                         }
    Local aChiGoInfo	:=	{"SU5", "GovernmentalInformation"		, "GovernmentalInformation"         }
    Local aChiInfoAB	:=	{"SU5", ""		                        , "GovInfoOAB"                      }
    Local aChiInfoCp	:=	{"SU5", ""		                        , "GovInfoCp"                       }
    Local aChiInfoRg	:=	{"SU5", ""		                        , "GovInfoRG"                       }
    Local aChiState   	:= 	{"SU5","state"							, "state"                           }	
	Local cIndexKey		:=  "U5_FILIAL, U5_CODCONT"

	oApiManager:SetApiRelation(aChiAddres	, aFatherAlias  	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCountr	, aChiAddres	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiState	, aChiAddres	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCity 	, aChiAddres	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiComInfo 	, aFatherAlias	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiGoInfo 	, aFatherAlias	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoAB 	, aChiGoInfo	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoCp 	, aChiGoInfo	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoRg 	, aChiGoInfo	    , aRelation, cIndexKey)

    oApiManager:SetApiMap(ApiMapU5())

Return Nil

/*/{Protheus.doc} GetMain
Realiza o Get dos Contatos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMapU5
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function ApiMapU5()

    Local aApiMap	    :=  {}
    Local aStrAddres    :=  {}
    Local aStrCity      :=  {}
    Local aStrComInf    :=  {}
    Local aStrCountr    :=  {}
    Local aStrInfoAB    :=  {}
    Local aStrInfoCp    :=  {}
    Local aStrGoInfo    :=  {}
    Local aStrInfoRG    :=  {}
    Local aStrSU5       :=  {}
    Local aStrState     :=  {}
    Local aStruct       :=  {}

    aStrSU5 :=  {"SU5","field","items","items",;
        {;
            {"companyId"                ,""                                     },;
            {"branchId"                 ,"U5_FILIAL"                            },;
            {"companyInternalId"        ,""                                     },;
            {"code"                     ,"U5_CODCONT"                           },;
            {"internalId"               ,"Exp:cEmpAnt, U5_FILIAL, U5_CODCONT"   },;
            {"name"                     ,"U5_CONTAT"                            },;
            {"treatment"                ,"U5_TRATA"                             },;
            {"gender"                   ,"U5_SEXO"                              },;
            {"birthday"                 ,"U5_NIVER"                             },;
            {"requester"                ,"U5_SOLICTE"                           },;
            {"situation"                ,"U5_MSBLQL"                            };
        },;
    }

    aStrAddres :=  {"SU5","field","address","address",;
        {;
            {"address"				    , "U5_END"							    },;
            {"number"					, ""									},;
            {"complement"				, ""									},;
            {"district"					, "U5_BAIRRO"					        },;
            {"zipCode"					, "U5_CEP"						        },;
            {"region"					, ""									},;
            {"poBox"					, ""									},;
            {"mainAddress"				, "Exp:.T."								},;
            {"shippingAddress"			, "Exp:.F."								},;
            {"billingAddress"			, "Exp:.F."								};
        },;
    }

    aStrCountr :=   {"SU5","field","country","country",;
		{;
			{"countryCode"					, "U5_PAIS"										},;
			{"countryInternalId"			, "U5_PAIS"										},;
			{"countryDescription"			, ""											};
		},;
	}	

    aStrState :=    {"SU5","field","state","state",;
		{;
            {"stateId"						, "U5_EST"							},;
            {"stateInternalId"				, "U5_EST"							},;
            {"stateDescription"				, ""								};
        },;
	}

    aStrCity := {"SU5","field","city","city",;
		{;
			{"cityCode"						, ""        						},;
			{"cityInternalId"				, ""		        				},;
			{"cityDescription"				, "U5_MUN"							};
		},;
	}

    aStrComInf :=   {"SU5","item","listOfCommunicationInformation", "listOfCommunicationInformation",;
        {;
            {"type"							, ""											},;
            {"phoneNumber"					, "U5_FONE"										},;
            {"phoneExtension"				, ""											},;
            {"faxNumber"					, "U5_FAX"										},;
            {"faxNumberExtension"			, ""											},;
            {"homePage"						, "U5_URL"  									},;								
            {"email"						, "U5_EMAIL"									},;
            {"diallingCode"					, "U5_DDD"										},;
            {"internationalDiallingCode"	, "U5_CODPAIS"									};
        },;
    }

    aStrGoInfo :=  {"SU5","item","GovernmentalInformation","GovernmentalInformation",;
        {;
        },;
    }

    aStrInfoCp :=   {"SU5","Object","","GovInfoCp",;
        {;
            {"id"							, "U5_CPF"									    },;
            {"name"							, "Exp:'CPF|CNPJ'"				                },;
            {"scope"						, ""											},;
            {"expireOn"						, ""											},;
            {"issueOn"						, ""											};
        },;
    }

    aStrInfoRG :=   {"SU5","Object","","GovInfoRG",;
        {;
            {"id"							, "U5_RG"									    },;
            {"name"							, "Exp:'RG'"				                    },;
            {"scope"						, ""											},;
            {"expireOn"						, ""											},;
            {"issueOn"						, ""											};
        },;
    }

    aStrInfoAB :=   {"SU5","Object","","GovInfoOAB",;
        {;
            {"id"							, "U5_OAB"									    },;
            {"name"							, "Exp:'OAB'"				                    },;
            {"scope"						, ""											},;
            {"expireOn"						, ""											},;
            {"issueOn"						, ""											};
        },;
    }

	aStruct := {aStrSU5,aStrAddres,aStrCountr,aStrState,aStrCity,aStrComInf,aStrGoInfo,aStrInfoCp,aStrInfoRG,aStrInfoAB}

	aApiMap := {"TMKS070","items","1.000","TMKS070",aStruct, "items"}

Return aApiMap