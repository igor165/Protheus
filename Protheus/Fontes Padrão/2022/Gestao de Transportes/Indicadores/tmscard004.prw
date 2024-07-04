#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TMSCARDS.CH"

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSRESTFUL tmscard004 DESCRIPTION STR0004 // "Viagens em Trânsito"
    WSDATA Fields              AS Character   
    WSDATA  Order              AS Character   
    WSDATA  Page               AS Integer 
    WSDATA  PageSize           AS Integer  
    
   WSMETHOD POST itemsDetails ;
        DESCRIPTION "Carrega os Itens Utilizados para Montagem do Painel" ;
        WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
        PATH "/cards/itemsDetails";
        PRODUCES APPLICATION_JSON
    

   WSMETHOD GET cardFilter;
        DESCRIPTION "Disponibiliza os campos que poderão ser utilizados no filtro do Card" ;
        WSSYNTAX "/cards/cardFilter/" ;
        PATH "/cards/cardFilter";
        PRODUCES APPLICATION_JSON
 
    WSMETHOD GET cardInfo ;
        DESCRIPTION "Carrega as informações do Painel" ;
        WSSYNTAX "/cards/cardInfo/" ;
        PATH "/cards/cardInfo";
        PRODUCES APPLICATION_JSON
 
    WSMETHOD GET fieldsInfo ;
        DESCRIPTION "Carrega os campos que podem que ser utilizados" ;
        WSSYNTAX "/cards/fieldsInfo/" ;
        PATH "/cards/fieldsInfo";
        PRODUCES APPLICATION_JSON

    
    WSMETHOD GET headerItens ;
    DESCRIPTION "Carrega os Cabeçalho a ser apresentado nos detalhes" ;   // #"Carrega os Cabeçalho a ser apresentado nos detalhes"
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON
 
ENDWSRESTFUL
 
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE tmscard004
 
    Local aHeader       := {}
    Local aRet          := {}
    Local lRet          := .T.
    Local oCoreDash    := CoreDash():New()
 
    Self:SetContentType("application/json")
 
  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;    // #"Data de Emissão"
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        // #"Produto"
    {"rota"	        ,  FWX3Titulo('DTQ_ROTA')        },;      // #"Grupo de Produto"
    {"datfec"       ,  FWX3Titulo('DTQ_DATFEC')      },;    // #"CFOP"
    {"horfec"	    ,  FWX3Titulo('DTQ_HORFEC')      },;    // #"Cliente"
    {"datini"       ,  FWX3Titulo('DTQ_DATINI')      },;    // #"Loja"
    {"status"       ,  FWX3Titulo('DTQ_STATUS')      };    // #"Loja"
  }
 
    //Chama a função responsavel por montar a Expressão SQL
    aRet := TmsCd04Qry()
 
    //Define a Query padrão utilizada no Serviço
    oCoreDash:SetQuery(aRet[1])
    oCoreDash:SetWhere(aRet[2])
    oCoreDash:SetFields(DePara())
    oCoreDash:SetApiQstring(Self:aQueryString)

    lRet := oCoreDash:BuildJson()
 
    If lRet
        oCoreDash:SetPOHeader(aHeader)
        Self:SetResponse( oCoreDash:ToObjectJson())
    EndIf
 
    oCoreDash:Destroy()
 
    aSize(aRet, 0)
    aSize(aHeader, 0)

Return lRet
 
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD GET cardFilter WSSERVICE tmscard004
 
    Local aHeader       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
 
  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;    // #"Data de Emissão"
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        // #"Produto"
    {"rota"	        ,  FWX3Titulo('DTQ_ROTA')        },;      // #"Grupo de Produto"
    {"datfec"       ,  FWX3Titulo('DTQ_DATFEC')      },;    // #"CFOP"
    {"horfec"	    ,  FWX3Titulo('DTQ_HORFEC')      },;    // #"Cliente"
    {"datini"       ,  FWX3Titulo('DTQ_DATINI')      },;    // #"Loja"
    {"status"       ,  FWX3Titulo('DTQ_STATUS')      };    // #"Loja"
  }
 
    oResponse["items"]      := oCoreDash:SetPOHeader(aHeader)
 
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.
 
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD GET cardInfo WSSERVICE tmscard004
 
    Local aFilter       := {}
    Local cWhere        := ""
    Local nFiltro       := 0
    Local oCoreDash     := CoreDash():New()
    Local oResponse     := JsonObject():New()
 
    //Converte os campos utilizados na consulta para os campos utilizados no card.
    oCoreDash:SetFields(DePara())
 
    //Converte o Filtro informado no parametro Query String.
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()
     
    For nFiltro := 1 to Len(aFilter)
        cWhere += " AND " + aFilter[nFiltro][1]
    Next
 
    RetCardInfo( @oResponse )
 
    self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )
 
    oResponse := Nil
    FreeObj( oResponse )
 
    oCoreDash:Destroy()
    FreeObj( oCoreDash )

Return .T.
 
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD GET fieldsInfo WSSERVICE tmscard004
    Local oItem         := Nil 
    Local aItems        := {}   
    Local oResponse     := JsonObject():New()
        
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0070 // "Em Trânsito:"
    oItem["value"] :=	"totalTran"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0071 //"Em Aberto:"
    oItem["value"] :=	"totalOpen"

    AADD(aItems, oItem)

    
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0072 // "Fechadas: "
    oItem["value"] :=	"totalFec"

    AADD(aItems, oItem)
    
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0073 //"Chegada em Filial: "
    oItem["value"] :=	"totalFilial"

    AADD(aItems, oItem)
    /*Retorna um Objeto no formato de Value e Label*/
    oResponse["items"] := aItems
 
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.
 
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
 WSMETHOD GET headerItens WSSERVICE tmscard004

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;    // #"Data de Emissão"
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        // #"Produto"
    {"rota"	        ,  FWX3Titulo('DTQ_ROTA')        },;      // #"Grupo de Produto"
    {"datfec"       ,  FWX3Titulo('DTQ_DATFEC')      },;    // #"CFOP"
    {"horfec"	    ,  FWX3Titulo('DTQ_HORFEC')      },;    // #"Cliente"
    {"datini"       ,  FWX3Titulo('DTQ_DATINI')      },;    // #"DATINI"
    {"status"       ,  FWX3Titulo('DTQ_STATUS')      };    // #"Status"
  }
    
  oResponse["items"]   := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

/*/{Protheus.doc} TmsCd04Qry
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function TmsCd04Qry(cCampos)
    Local cQuery := ""
    Local cWhere := ""
    Local dData  := FirstDate(dDataBase)                                          

    Default cCampos := " DTQ_FILORI, DTQ_VIAGEM, DTQ_ROTA, DTQ_DATFEC , DTQ_HORFEC , DTQ_DATINI , DTQ_HORINI, " +;
                        " CASE WHEN DTQ_STATUS = '1' THEN '1-Em aberto' " + ;
                        " WHEN DTQ_STATUS = '2' THEN '1-Em trânsito' " + ;
                        " WHEN DTQ_STATUS = '4' THEN '4-Chegada em Filial' " + ;
                        " WHEN DTQ_STATUS = '5' THEN '5-Fechada' END AS DTQ_STATUS"
 
    cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("DTQ") + " DTQ "
    

    cWhere  := " DTQ_FILIAL = '" + xFilial("DTQ") + "' "
    cWhere  += " AND DTQ_FILORI = '" + cFilAnt + "' "
    cWhere  += " AND DTQ_STATUS IN ('1', '2', '5', '4')  "
    cWhere  += " AND DTQ.D_E_L_E_T_ = ' ' "

Return {cQuery, cWhere}
 
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function DePara()
    Local aCampos := {}
 
    aCampos := {;
        {"filori"   , "DTQ_FILORI"         },;
        {"viagem"   , "DTQ_VIAGEM"         },;
        {"rota"     , "DTQ_ROTA"           },;
        {"datini"   , "DTQ_DATINI"         },;
        {"datfec"   , "DTQ_DATFEC"         },;
        {"horfec"  , "DTQ_HORFEC"          },;
        {"status"   , "DTQ_STATUS"         };
        }

Return aCampos
 
/*/{Protheus.doc} RetCardInfo
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetCardInfo( oResponse )
 
    Local oItem     := Nil 
    Local aItems    := {}
    oItem := JsonObject():New()
    
    oItem["totalTran"]          := cValToChar( TmsCd04Vge("2") )
    oItem["totalOpen"]          := cValToChar( TmsCd04Vge("1")  )
    oItem["totalFec"]           := cValToChar( TmsCd04Vge("5")  )
    oItem["totalFilial"]        := cValToChar( TmsCd04Vge("4")  )

    aAdd(aItems, oItem)   
 
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems

Return Nil

/*/{Protheus.doc} TmsCd04Vge
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function TmsCd04Vge( cTipo ) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde     := 0 
Local dData     := FirstDate(dDataBase)

Default cTipo	:= ""

cQuery  := " SELECT COUNT(DTQ_VIAGEM)  CONT FROM " + RetSqlName("DTQ") + " DTQ "
cQuery  += " WHERE DTQ_FILIAL  = '" + xFilial("DTQ") + "' "
cQuery  += " AND DTQ_STATUS    = '" + cTipo + "' " 
cQuery  += " AND DTQ_FILORI = '" + cFilAnt + "' "
cQuery  += " AND DTQ.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde



