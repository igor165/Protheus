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
WSRESTFUL tmscard008 DESCRIPTION STR0086 //-- XML NFe Sefaz Vge em Transito
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
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE tmscard008
 
    Local aHeader       := {}
    Local aRet          := {}
    Local lRet          := .T.
    Local oCoreDash    := CoreDash():New()
 
    Self:SetContentType("application/json")
  
    If aliasInDic("DMH")
  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;   
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        
    {"chvnfe"	    ,  FWX3Titulo('DMH_CHVNFE')      },;      
    {"status"       ,  FWX3Titulo('DMH_STATUS')      };
  }
     
 
    //Chama a função responsavel por montar a Expressão SQL
    aRet := TmsCd08Qry()
 
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
    EndIf
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
WSMETHOD GET cardFilter WSSERVICE tmscard008
 
    Local aHeader       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
 
    If AliasInDic("DMH")
  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;   
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        
    {"chvnfe"	    ,  FWX3Titulo('DMH_CHVNFE')      },;      
    {"status"       ,  FWX3Titulo('DMH_STATUS')      };
  }
    EndIf 
 
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
WSMETHOD GET cardInfo WSSERVICE tmscard008
 
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
WSMETHOD GET fieldsInfo WSSERVICE tmscard008
    Local oItem         := Nil 
    Local aItems        := {}   
    Local oResponse     := JsonObject():New()
        
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0087 //"Qtde NF Coletadas" // "Documentos Vencidos:"
    oItem["value"] :=	"totalNf"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0088 //"NFs Processadas:" 
    oItem["value"] :=	"totalProc"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0089 //"NFs Pendentes" 
    oItem["value"] :=	"totalPend"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0090 //"NFs Não Encontradas"
    oItem["value"] :=	"totalErro"

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
 WSMETHOD GET headerItens WSSERVICE tmscard008

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

    If AliasInDic("DMH")
  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;   
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        
    {"chvnfe"	    ,  FWX3Titulo('DMH_CHVNFE')      },;      
    {"status"       ,  FWX3Titulo('DMH_STATUS')      };
  }
    EndIf 
  oResponse["items"]   := oCoreDash:SetPOHeader(aHeader)

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
Function TmsCd08Qry(cCampos)
Local cQuery    := ""
Local cWhere    := ""
Local dData     := FirstDate(dDataBase) 
Local cGroup    := "" 

Default cCampos := " DTQ_FILORI, DTQ_VIAGEM, DMH_CHVNFE, CASE WHEN DMH_STATUS = '3' THEN '3-Não Encontrado'" +;
                                                             " WHEN DMH_STATUS = '1' THEN '1-Pendente' END AS DMH_STATUS"

If AliasInDic("DMH")
    cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("DTQ") + " DTQ "
    cQuery  += " INNER JOIN " + RetSqlName("DMH") + " DMH "
    cQuery  += " ON DMH_FILIAL  = '" + xFilial("DMH") + "' "
    cQuery  += " AND DMH_FILORI     = DTQ_FILORI "
    cQuery  += " AND DMH_VIAGEM     = DTQ_VIAGEM "
    cQuery  += " AND DMH.DMH_STATUS IN ('1', '3')"
    cQuery  += " AND DMH.D_E_L_E_T_ = '' "

    cWhere  += " DTQ.DTQ_FILIAL      = '" + xFilial("DTQ") + "' "
    cQuery  += " AND DTQ.DTQ_FILORI     = '" + cFilAnt + "' "
    cWhere  += " AND DTQ.DTQ_FILORI = '" + cFilAnt + "' "
    cWhere  += " AND DTQ.D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)

Else 
    cCampos := "" 
EndIf 

Return {cQuery, cWhere ,  cGroup }
 
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
        {"filori"	    ,  'DTQ_FILORI'      },;   
        {"viagem"	    ,  'DTQ_VIAGEM'      },;        
        {"chvnfe"	    ,  'DMH_CHVNFE'      },;      
        {"status"       ,  'DMH_STATUS'      };
        }

Return aCampos
 
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
Static Function RetCardInfo( oResponse )
 
    Local oItem     := Nil 
    Local aItems    := {}

    oItem := JsonObject():New()
    
    oItem["totalNf"]        := cValToChar( TmsCd08Col() )
    oItem["totalProc"]      := cValToChar( TmsCd08Col("1") )
    oItem["totalPend"]      := cValToChar( TmsCd08Col("2") )
    oItem["totalErro"]      := cValToChar( TmsCd08Col("3") )

    aAdd(aItems, oItem)   
 
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems

Return Nil

/*/{Protheus.doc} RetNFCol
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
Function TmsCd08Col(cStatus) 
Local cQuery    := ""
Local cAliasQry := "" 
Local nQtde     := 0 
Local dData     := FirstDate(dDataBase)

Default cStatus	:= ""
If AliasInDic("DMH")
    cAliasQry := GetNextAlias() 

    cQuery  := " SELECT COUNT(DMH_CHVNFE)  CONT FROM " + RetSqlName("DMH") + " DMH "
    cQuery  += " INNER JOIN " + RetSqlName("DTQ") + " DTQ "
    cQuery  += " ON DTQ.DTQ_FILIAL      = '" + xFilial("DTQ") + "' "
    cQuery	+= " AND DTQ.DTQ_FILORI		= DMH_FILORI "
    cQuery	+= " AND DTQ.DTQ_VIAGEM		= DMH_VIAGEM "
    cQuery  += " AND DTQ.DTQ_STATUS     = '2' "
    cQuery  += " WHERE DMH_FILIAL   = '" + xFilial("DMH") + "' "
    If !Empty(cStatus)
        cQuery  += " AND DMH_STATUS     = '" + cStatus + "' "
    EndIf 

    cQuery  +=  "AND DMH_FILORI = '" + cFilAnt + "' "
    cQuery  += " AND DMH.D_E_L_E_T_ = ' ' "
    cQuery  += " AND DTQ.D_E_L_E_T_ = '' "


    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

    If (cAliasQry)->(!Eof())
        nQtde   := (cAliasQry)->CONT
    EndIf 

    
    (cAliasQry)->(dbCloseArea())

EndIf 

Return nQtde
