#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//Dummy function
Function MATS050()

Return

/*/{Protheus.doc} Transportadora
API de integração de Cadastro de Transportadoras

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

WSRESTFUL carrier DESCRIPTION "Cadastro de Transportadoras" 

    WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
    WSDATA Page				AS INTEGER	OPTIONAL
    WSDATA PageSize			AS INTEGER	OPTIONAL
    WSDATA carrierCode  	AS STRING	OPTIONAL
	
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todas as Transportadoras" ;
    WSSYNTAX "/api/fat/v1/carrier/{Order, Page, PageSize, Fields}" ;
    PATH "/api/fat/v1/carrier"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra uma Transportadora" ;
    WSSYNTAX "/api/fat/v1/carrier/{Fields}";
    PATH "/api/fat/v1/carrier"

    WSMETHOD GET CarrierCode ;
    DESCRIPTION "Retorna uma Transportadora" ;
    WSSYNTAX "/api/fat/v1/carrier/{carrierCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/fat/v1/carrier/{carrierCode}"

    WSMETHOD PUT CarrierCode ;
    DESCRIPTION "Altera uma Transportadora específica" ;
    WSSYNTAX "/api/fat/v1/carrier/{carrierCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/fat/v1/carrier/{carrierCode}"

    WSMETHOD DELETE CarrierCode ;
    DESCRIPTION "Deleta uma Transportadora específica" ;
    WSSYNTAX "/api/fat/v1/carrier/{carrierCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/fat/v1/carrier/{carrierCode}"
 
ENDWSRESTFUL

/*/{Protheus.doc} GET / carrier/carrier
Retorna todas Transportadoras

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE carrier

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("MATS050","1.000")
	
    lRet    := GetSA4(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / carrier/carrier
Cadastra uma Transportadora

@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet		, Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE carrier

	Local aFilter      	:= {}
	Local aJson       	:= {}
	Local cError			:= ""
	Local cBody 	  		:= Self:GetContent()
	Local lRet				:= .T.
	Local oApiManager		:= FWAPIManager():New("MATS050","1.000")
	Local oJson			:= THashMap():New()    
	
    Self:SetContentType("application/json")

   	oApiManager:SetApiAlias({"SA4","items", "items"})
	oApiManager:SetApiMap(ApiMapSA4())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutSA4(@oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
	       Aadd(aFilter, {"SA4", "items",{"A4_COD = '" + SA4->A4_COD + "'"}})
	       oApiManager:SetApiFilter(aFilter)	    
        	lRet    := GetSA4(@oApiManager, Self)
        Endif
    Else        
        oApiManager:SetJsonError("400","Erro ao Incluir Transportadora!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError["code"]), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
   	aSize(aFilter,0)
   	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} GET / carrier/carrier/{carrierCode}
Retorna uma Transportadora específica

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

WSMETHOD GET carrierCode PATHPARAM carrierCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE carrier

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
	Local oApiManager		:= Nil
	Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("MATS050","1.000")
	
	cCode := Substr(Self:carrierCode,TamSX3("A4_FILIAL")[1]+1,Len(Self:carrierCode))   
	
	If  Len(cCode) <> TamSX3("A4_COD")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição da Transportadora!", "O código da filial ou da Transportadora não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"SA4", "items",{"A4_COD = '" + cCode + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetSA4(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} PUT / carrier/{carrierCode}
Altera uma Transportadora específica

@param	carrierCode	, caracter, Código da Transportadora
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

WSMETHOD PUT carrierCode PATHPARAM carrierCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE carrier

    Local aFilter			:= {}
    Local aJson			:= {}	
    Local cBody 	   		:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.    
    Local oApiManager 	:= FWAPIManager():New("MATS050","1.000")
    Local oJson			:= THashMap():New()
    Local cCode			:= ""	

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SA4","items", "items"})
    oApiManager:SetApiMap(ApiMapSA4())
    oApiManager:Activate()

    lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
    	cCode := Substr(Self:carrierCode,TamSX3("A4_FILIAL")[1]+1,Len(Self:carrierCode))   
	
		If  Len(cCode) <> TamSX3("A4_COD")[1]
			lRet := .F.
	       oApiManager:SetJsonError("400","Erro na requisição da Transportadora!", "O código da filial ou da Transportadora não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
	    EndIf
	    
       If lRet 
	        If SA4->(DbSeek(xFilial("SA4") + cCode))
			    lRet := ManutSA4(oApiManager, Self:aQueryString, 4, aJson, cCode, oJson, cBody)
	            If lRet
		            Aadd(aFilter, {"SA4", "items",{"A4_COD = '" + SA4->A4_COD + "'"}})
	                oApiManager:SetApiFilter(aFilter)	    
	                lRet    := GetSA4(@oApiManager, Self)
	            Endif
	        Else
	            lRet := .F.
	            oApiManager:SetJsonError("404","Erro ao alterar a Transportadora!", "Transportadora não encontrada.",/*cHelpUrl*/,/*aDetails*/)
	        Endif
       EndIf
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Transportadora!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DELETE / carrier/{carrierCode}/
Deleta uma Transportadora específica

@param	carrierCode	, caracter, Código da Transportadora
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

WSMETHOD DELETE carrierCode PATHPARAM carrierCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE carrier

    Local aJson			:= {}
    Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("MATS050","1.000")
    Local oJsonPositions	:= JsonObject():New()
    Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"SA4","items", "items"})
	oApiManager:SetApiMap(ApiMapSA4())
	oApiManager:Activate()
	
	cCode := Substr(Self:carrierCode,TamSX3("A4_FILIAL")[1]+1,Len(Self:carrierCode))   
	
	If  Len(cCode) <> TamSX3("A4_COD")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição da Transportadora!", "O código da filial ou da Transportadora não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf

	If lRet
	    If SA4->(DbSeek(xFilial("SA4") + cCode))
			lRet := ManutSA4(oApiManager, Self:aQueryString, 5, aJson, cCode, , cBody)        
	    Else
	        lRet := .F.
	        oApiManager:SetJsonError("404","Erro ao Excluir a Transportadora!", "Transportadora não encontrada.",/*cHelpUrl*/,/*aDetails*/)
	    Endif
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
	aSize(aJson,0)
   	FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} ManutSA4
Realiza a manutenção (inclusão/alteração/exclusão) da Transportadora

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson			, Array		, Array tratado de acordo com os dados do json recebido
@param cChave			, Caracter	, Chave com codigo da Transportadora (A4_COD)
@param oJson			, Objeto	, Objeto com Json parceado
@param cBody       	, Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function ManutSA4(oApiManager, aQueryString, nOpc, aJson, cChave, oJson, cBody)
                
	Local   aTransp   		:= {}
	Local   aMsgErro     	:= {}			
	Local   cCodigo      	:= ""
	Local   cResp	       	:= ""
	Local   lRet         	:= .T.	
	Local   nX           	:= 0

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

    If !Empty(cChave)
		cCodigo := SubStr(cChave, 1, TamSX3("A4_COD")[1] )
	EndIf

    If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aTransp)
		EndIf
		
       If Len(aJson[1][3]) > 0
			For nX := 1 To Len(aJson[1][3][1])
				MontaCab(aJson[1][3][1][nX], aTransp)
			Next
		EndIf

		If nOpc == 4 .And. Ascan(aTransp,{|x|x[1]=="A4_COD"}) == 0			
			aAdd(aTransp,{"A4_COD" ,cChave     ,Nil})			
		Endif
    Else
        aAdd(aTransp,{"A4_COD" ,cChave     ,Nil})
    Endif
       	
    If lRet
    	MSExecAuto({|x,y|MATA050(x,y)},aTransp,nOpc) 	
	   If lMsErroAuto
	        aMsgErro := GetAutoGRLog()
	        cResp	 := ""
	        For nX := 1 To Len(aMsgErro)
	            cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ")
	        Next nX	
	        lRet := .F.
	        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão da Transportadora!.", cResp,/*cHelpUrl*/,/*aDetails*/)
	    EndIf
    EndIf

    aSize(aMsgErro,0)
    aSize(aTransp,0)    

Return lRet

/*/{Protheus.doc} MontaCab
Monta o array do cabeçalho que será utilizado no execauto

@param	oJson				, objeto  , Objeto com o array parseado
@param	aCabOportu			, array   , Array que será populado com os dados do Json parciado
@return Nil               	, Nulo	   

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function MontaCab(oJson, aInfGov)

	If AttIsMemberOf(oJson, "name") .And. AttIsMemberOf(oJson, "id") .And. !Empty(oJson:id) .And. !Empty(oJson:name)
		If AllTrim(oJson:name) $ "CNPJ/CPF"
			aAdd( aInfGov, {'A4_CGC' 	,oJson:id, Nil}) 
       ElseIf AllTrim(oJson:name) $ "INSCRICAO ESTADUAL"
			aAdd( aInfGov, {'A4_INSEST' ,oJson:id, Nil}) 
       ElseIf AllTrim(oJson:name) $ "SUFRAMA"
			aAdd( aInfGov, {'A4_SUFRAMA',oJson:id, Nil}) 
	   	EndIf
	Endif
    
Return Nil

/*/{Protheus.doc} GetSA4
Realiza o Get das Transportadoras

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	   		, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function GetSA4(oApiManager, Self)

	Local aFatherAlias	:=  {"SA4","items", "items"}
	Local cIndexKey		:=  " A4_FILIAL, A4_COD "
   	Local lRet          	:=  .T.

	If Len(oApiManager:GetApiRelation()) == 0
		DefRelation(@oApiManager)
	EndIf
	
	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         	, Nulo

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

	Local aRelation    	:=	{{"A4_FILIAL", "A4_FILIAL"},{"A4_COD", "A4_COD"}}
	Local aFatherAlias	:=	{"SA4",	"items"							, "items"}
	Local aChiGovInf	:=	{"SA4",	"governamentalInformation"		, "GovernamentalInformation"}
	Local aChiInfoIE	:=	{"SA4",	""								, "GovInfIE"}
	Local aChiInfCGC	:=	{"SA4",	""								, "GovInfCGC"}
	Local aChiInfSuf	:=	{"SA4",	""								, "GovInfSuf"}
	Local aChiAdress	:=	{"SA4",	"address"						, "Address"}
	Local aChiCity		:=	{"SA4",	"city"							, "City"}
	Local aChiState		:=	{"SA4",	"state"							, "State"}
	Local aChiCountr	:=	{"SA4",	"country"						, "Country"}
	Local aLstCmnInf	:=	{"SA4",	"listofComunicationInformation"	, "ListofComunicationInformation"}
	Local cIndexKey		:=	"A4_FILIAL, A4_COD"

	oApiManager:SetApiRelation(aChiGovInf	, aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoIE	, aChiGovInf	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfCGC	, aChiGovInf	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfSuf	, aChiGovInf	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aChiAdress	, aFatherAlias	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aChiCity		, aChiAdress	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aChiState	, aChiAdress	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aChiCountr	, aChiAdress	, aRelation, cIndexKey)	
	oApiManager:SetApiRelation(aLstCmnInf	, aChiAdress	, aRelation, cIndexKey)

    oApiManager:SetApiMap(ApiMapSA4())

Return Nil

/*/{Protheus.doc} GetMain
Realiza o Get das Transportadoras

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey		, String	, Índice da tabela pai
@return lRet	    	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 			:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager	:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMapSA4
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author	Squad Faturamento/CRM
@since		08/11/2018
@version	12.1.21
/*/

Static Function ApiMapSA4()

	Local aApiMap			:=	{}
	Local aStruct			:=	{}
	Local aStrSA4			:=	{}
	Local aStrGovInf		:=	{}
	Local aStrInfoIE		:=	{}
	Local aStrInfCGC		:=	{}
	Local aStrInfSuf		:=	{}
	Local aStrAddres		:=	{}
	Local aStrCity			:=	{}
	Local aStrState			:=	{}
	Local aStrCountr		:=	{}
	Local aStrCttInf		:=	{}

	aStrSA4 		:=	{"SA4","field","items","items",;
		{;
			{"BranchId"						,"A4_FILIAL"												},;
			{"CompanyInternalId"			,""															},;
			{"InternalId"       	    	,"A4_FILIAL, A4_COD"										},;
			{"Code"              	       	,"A4_COD"													},;
			{"Name"							,"A4_NOME"													},;
			{"ShortName"					,"A4_NREDUZ"												},;
			{"RegisterSituation"			,"A4_MSBLQL"												},;
			{"CarrierType"					,"A4_TPTRANS"												};
		},;
	}
	
	aStrGovInf		:=	{"SA4","item","governamentalInformation","GovernamentalInformation",;
		{},;
	}
		
	aStrInfoIE		:=	{"SA4","Object","","GovInfIE",;
		{;
			{"id"							, "A4_INSEST"												},;
			{"name"							, "Exp:'INSCRICAO ESTADUAL'"							},;
			{"scope"						, "Exp:'Estadual'"										};
		},;
	}
	
	aStrInfCGC		:=	{"SA4","Object","","GovInfCGC",;
		{;
			{"id"							, "A4_CGC"													},;
			{"name"							, "Exp:'CNPJ/CPF'"										},;
			{"scope"						, "Exp:'Federal'"											};
		},;
	}
					
	aStrInfSuf		:=	{"SA4","Object","","GovInfSuf",;
		{;
			{"id"							, "A4_SUFRAMA"											},;
			{"name"							, "Exp:'SUFRAMA'"											},;
			{"scope"						, "Exp:'Federal'"											};
		},;
	}	

    aStrAddres 	:=	{"SA4","field","address","Address",;
        {;
           {"address"						,"A4_END"													},;
           {"number"						,""															},;
           {"complement"					,"A4_COMPLEM"												},;
           {"district"						,"A4_BAIRRO"												},;
           {"zipCode"						,"A4_CEP"													},;
           {"region"						,""  														},;								
           {"poBox"							,""															},;
           {"mainAddress"					,""															},;
           {"shippingAddress"				,""															},;
           {"billingAddress"				,""															};
        },;
    }

    aStrCity 		:=	{"SA4","field","city","City",;
		{;
			{"cityCode"						,"A4_COD_MUN" 						       			},;
			{"cityInternalId"				,"A4_COD_MUN"		        								},;
			{"cityDescription"				,""															};
		},;
	}
	
	aStrState 		:=	{"SA4","field","state","State",;
        {;
        	{"stateId"						,"A4_EST"													},;
        	{"stateInternalId"				,"A4_EST"													},;
        	{"stateDescription"				,""															};
        },;
    }
    
    aStrCountr 	:=	{"SA4","field","country","Country",;
        {;
           {"countryCode"					,"A4_CODPAIS"												},;
           {"countryInternalId"				,"A4_CODPAIS"												},;
           {"countryDescription"			,""														   	};
        },;
    }
    
    aStrCttInf	:=	{"SA4","field","listofComunicationInformation","ListofComunicationInformation",;
        {;
			{"Type"							,"" 						       						},;
			{"PhoneNumber"					,"A4_TEL"		        									},;
			{"PhoneExtension"				,""															},;
			{"FaxNumber"					,"A4_TELEX"												},;
			{"FaxNumberExtension"			,""															},;
			{"HomePage"						,"A4_HPAGE"												},;
			{"Email"						,"A4_EMAIL"												},;
			{"DiallingCode"					,"A4_DDD"													},;
			{"InternationalDiallingCode"	,"A4_DDI"													};
        },;
    }

	aStruct := {aStrSA4,aStrGovInf,aStrInfoIE,aStrInfCGC,aStrInfSuf,aStrAddres,aStrCity,aStrState,aStrCountr,aStrCttInf}

	aApiMap := {"MATS050","items","1.000","MATS050",aStruct, "items"}

Return aApiMap