#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function CRMS610()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarketSegments

RESTfull service to perform a list of HTTP Verbs for the MarketSegment  

@author		Renato da Cunha
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSRESTFUL MarketSegments DESCRIPTION "Segmentos"

    WSDATA MarketSegmentID	AS STRING 	OPTIONAL
    WSDATA Order        	AS STRING 	OPTIONAL
	WSDATA Fields        	AS STRING 	OPTIONAL
    WSDATA Page			    AS INTEGER	OPTIONAL
	WSDATA PageSize		    AS INTEGER	OPTIONAL 

    WSMETHOD GET Main  ;
    DESCRIPTION "Lista todos os Seguimentos cadastrados na tabela AOV";
    WSSYNTAX "/api/crm/v1/marketSegments/{Order, Page, PageSize, Fields}";
    PATH "/api/crm/v1/marketSegments" 

    WSMETHOD Post Main  ;
    DESCRIPTION "Inclui um cadastrado na tabela AOV";
    WSSYNTAX "/api/crm/v1/marketSegments/";
    PATH "/api/crm/v1/marketSegments" 
	
    WSMETHOD GET segmentId;
    DESCRIPTION  "Obtem um segmento pelo seu código (AOV_CODSEG)";
    WSSYNTAX "/api/crm/v1/marketSegments/{MarketSegmentID}/{Order, Page, PageSize, Fields}";
    PATH "/api/crm/v1/marketSegments/{MarketSegmentID}"

    WSMETHOD PUT segmentId;
    DESCRIPTION "Altera um segmento pelo seu código (AOV_CODSEG)";
    WSSYNTAX "/api/crm/v1/marketSegments/{MarketSegmentID}";
    PATH "/api/crm/v1/marketSegments/{MarketSegmentID}"

    WSMETHOD DELETE segmentId;
    DESCRIPTION  "Excluí um segmento pelo seu código (AOV_CODSEG)";
    WSSYNTAX "/api/crm/v1/marketSegments/{MarketSegmentID}";
    PATH "/api/crm/v1/marketSegments/{MarketSegmentID}"

ENDWSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarketSegments

Return a object with a list of MarketSegments data.

@author		Squad Faturamento/CRM
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE MarketSegments

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil

    Self:SetContentType("application/json")
	oApiManager := FWApiManager():New("CRMS610","2.000")

    lRet    := GetAOV(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarketSegments

    Return a object with a list of MarketSegments data.

@author		Squad Faturamento/CRM
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD POST Main  WSSERVICE MarketSegments

	Local aFilter       := {}
    Local aJson         := {}
    Local cBody 	  	:= Self:GetContent()
    Local cChave        := ""
    Local cError		:= ""	
	Local lRet			:= .T.
	Local oApiManager   := FWAPIManager():New("CRMS610","2.000")    
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AOV","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutAOV(oApiManager, Self:aQueryString, 3, aJson, @cChave, oJson, cBody)
        If lRet
	        aAdd(aFilter, {"AOV", "items",{"AOV_CODSEG = '" + cChave + "'"}})
	        oApiManager:SetApiFilter(aFilter)
            lRet    := GetAOV(@oApiManager, Self)
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Segmento!", "Nao foi possivel tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    aSize(aFilter,0)
	aSize(aJson,0)
    FreeObj( oJson )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarketSegments

Obtem segmento pelo ID

@author		Squad Faturamento/CRM
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD GET SegmentId PATHPARAM MarketSegmentID  WSSERVICE MarketSegments

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("CRMS610","2.000")   

	Aadd(aFilter, {"AOV", "items",{"AOV_CODSEG = '" + Self:MarketSegmentID + "'"}})
	oApiManager:SetApiFilter(aFilter)
	lRet := GetAOV(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarketSegments
Altera um Segmento

@author		Squad Faturamento/CRM
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD PUT SegmentId PATHPARAM MarketSegmentID  WSSERVICE MarketSegments

	Local aFilter       := {}
    Local aJson         := {}
    Local cBody 	  	:= Self:GetContent()
    Local cChave        := Self:MarketSegmentID
    Local cError		:= ""	
	Local lRet			:= .T.
	Local oApiManager   := FWAPIManager():New("CRMS610","2.000")    
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AOV","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        If FindMyAOV(cChave)
            lRet := ManutAOV(oApiManager, Self:aQueryString, 4, aJson, @cChave, oJson, cBody)
            If lRet
                aAdd(aFilter, {"AOV", "items",{"AOV_CODSEG = '" + cChave + "'"}})
                oApiManager:SetApiFilter(aFilter)
                lRet    := GetAOV(@oApiManager, Self)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao Alterar Segmento!", "Segment nao encontrado.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Alterar Segmento!", "Nao foi possivel tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    aSize(aFilter,0)
	aSize(aJson,0)
    FreeObj( oJson )
    
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarketSegments
Deleta o segmento informado

@author		Squad Faturamento/CRM
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSMETHOD DELETE SegmentId PATHPARAM MarketSegmentID  WSSERVICE MarketSegments

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("CRMS610","2.000")  
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AOV","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

    If FindMyAOV(Self:MarketSegmentID)		
        lRet := ManutAOV(oApiManager, Self:aQueryString, 5, aJson, Self:MarketSegmentID, , cBody)
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Segmento!", "Segmento nao encontrado.",/*cHelpUrl*/,/*aDetails*/)
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

//------------------------------------------------------------------------------
/*/{Protheus.doc} FindMyAOV

Indica se o registro existe na base.

@author		Renato da Cunha
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function FindMyAOV(cChave)

    Local lRet := .T.

    Default cChave := ""
    
    If Empty(cChave)
        lRet := .F.
    Else
        DbSelectArea('AOV')
        DbSetOrder(1)//AOV_FILIAL+AOV_CODSEG
        If !MsSeek(xFilial('AOV') + cChave)
            lRet := .F.
        EndIf
    EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ApiMap
Mapa de dados utilizado pela classe APIManager

@author		Renato da Cunha
@since		26/07/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function ApiMap()

    Local aStructAOV    := {}
	Local aStructAlias  := {}
    Local aStructChilds := {}
    Local aApiMap       := {}
	
    aStructAOV := {"AOV","Field","items", "items",;
							{;
								{"MarketSegmentID"                  , "AOV_CODSEG"      },;
								{"BranchID"				            , "AOV_FILIAL" 	    },;
								{"MarketSegmentDescription"			, "AOV_DESSEG"  	},;
								{"MainMarketSegment"				, "AOV_PRINC"       },;
								{"ParentMarketSegment"				, "AOV_PAI"	    	},;
								{"ParentMarketSegmentDescription"	, "AOV_DESPAI"		};
							};
					}
    aStructChilds := { "AOV", "ITEM", "childs", "childs",;
                        {;
                        	{"ChildMarketSegmentId"			, "AOV_CODSEG" 	},;
							{"ChildMarketSegmantDescription" , "AOV_DESSEG"   };
                        };
                    }
	aStructAlias  := {aStructAOV,aStructChilds}
	aApiMap := {"CRMS610","items","2.000","CRMS610",aStructAlias}

Return aApiMap

//------------------------------------------------------------------------------
/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		27/12/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"AOV", "childs", "childs"  }
    Local aFatherAOV	:=	{"AOV", "items" , "items"   }
    Local aRelation     :=  {{"AOV_FILIAL","AOV_FILIAL"},{"AOV_CODSEG","AOV_PAI"}}
	Local cIndexKey		:=  " AOV_FILIAL, AOV_CODSEG "

	oApiManager:SetApiRelation(aChildren, aFatherAOV, aRelation, cIndexKey)
    oApiManager:SetApiMap(ApiMap())

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetAOV
Realiza o Get dos Segmentos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		27/12/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
Static Function GetAOV(oApiManager, Self)

	Local aFatherAlias	:=  {"AOV", "items" , "items"   }
	Local cIndexKey		:=  " AOV_FILIAL, AOV_CODSEG "
    Local lRet          :=  .T.

    If Len(oApiManager:GetApiRelation()) == 0
	    DefRelation(@oApiManager)
    Endif

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetMain
Realiza o Get dos Segmentos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		27/12/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	aSize( aRelation, 0)
	aSize( aChildrenAlias, 0)
	aSize( aFatherAlias, 0)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ManutAOV
Realiza a manutenção (inclusão/alteração/exclusão) do Segmento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do contato (U5_CODCONT)
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		27/12/2018
@version	12.1.21
/*/
//------------------------------------------------------------------------------
Static Function ManutAOV(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)

    Local aHeader           := {}    
    Local aMsgErro          := {}
    Local cResp	            := ""    
    Local lRet              := .T.
    Local lSx8Num           := .F.
    Local nPosCodSeg        := 0
    Local nPosPrinc         := 0
    Local nPosMain          := 0
    Local nX                := 0

    Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

    DefRelation(@oApiManager)

    If nOpcx != 5

        aJson := oApiManager:ToArray(cBody)

        If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aHeader)
		EndIf

        If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2][1])
				oApiManager:ToExecAuto(1, aJson[1][2][1][nX][2], aHeader)
			Next nX
		EndIf        
        
        nPosCodSeg := aScan( aHeader, { |x| x[1] == 'AOV_CODSEG' } )
        nPosPrinc  := aScan( aHeader, { |x| x[1] == 'AOV_PRINC' } )
        nPosMain   := aScan( aHeader, { |x| x[1] == 'AOV_PAI' } )

        If nPosCodSeg ==  0 .And. nOpcx == 3
            cChave := GetSX8num("AOV", "AOV_CODSEG")
            lSx8Num     := .T.
            aadd(aHeader, {"AOV_CODSEG", cChave} )
        Elseif nPosCodSeg <> 0 .And. nOpcx == 3
            cChave := aHeader[nPosCodSeg][2]
            lRet := !FindMyAOV(cChave)
            If !lRet
                cResp := "Ja existe registro com esta informacao, troque a chave principal deste registro!"
            Endif
        Elseif nPosCodSeg ==  0 .And. nOpcx == 4
            aAdd(aHeader, {"AOV_CODSEG", cChave, Nil})             
        EndIf

        If nPosPrinc > 0 .And. (aHeader[nPosPrinc][2] <> "2" .or. (nOpcx == 4 .And. nPosPrinc == 0 .And. AOV->AOV_PRINC <> "2"))
            If nPosMain > 0
                aDel(aHeader, nPosMain)
                aSize(aHeader,Len(aHeader)-1)
            Endif
        Endif
    Else
        aAdd(aHeader, {"AOV_CODSEG", cChave, Nil})
    Endif

    If lRet
        aHeader := FWVetByDic(aHeader,"AOV",.F.)
        MSExecAuto({|x, y| CRMA610(x, y)}, aHeader,nOpcx)
        If lMsErroAuto
            If lSx8Num
                RollBackSx8()
            EndIf
            aMsgErro := GetAutoGRLog()
            cResp	 := ""
            For nX := 1 To Len(aMsgErro)
                cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ")
            Next nX	
            lRet := .F.            
        Else
            If lSx8Num
                ConfirmSx8()
            EndIf
        EndIf        
    Endif

    If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusao/Alteracao/Exclusao do Segmento!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    Endif

    aSize(aMsgErro, 0)    
    aSize(aHeader, 0)

Return lRet