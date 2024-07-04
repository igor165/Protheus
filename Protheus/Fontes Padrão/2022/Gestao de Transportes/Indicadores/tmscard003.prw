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
WSRESTFUL tmscard003 DESCRIPTION STR0003 //-- "Solicitações de Coleta Pendentes"
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
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE tmscard003
 
    Local aHeader       := {}
    Local aRet          := {}
    Local lRet          := .T.
    Local oCoreDash    := CoreDash():New()
 
    Self:SetContentType("application/json")
 
  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DT5_FILORI')      },;    // #"Data de Emissão"
    {"numsol"	    ,  FWX3Titulo('DT5_NUMSOL')      },;        // #"Produto"
    {"datsol"	    ,  FWX3Titulo('DT5_DATSOL')      },;      // #"Grupo de Produto"
    {"codsol"       ,  FWX3Titulo('DT5_CODSOL')      },;    // #"CFOP"
    {"nomesol"	    ,  FWX3Titulo('DUE_NREDUZ')      },;    // #"Cliente"
    {"numcot"       ,  FWX3Titulo('DT5_NUMCOT')      },;    // #"Loja"
    {"status"       ,  FWX3Titulo('DT5_STATUS')      };    // #"Loja"
  }
 
    //Chama a função responsavel por montar a Expressão SQL
    aRet := MntQuery()
 
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
WSMETHOD GET cardFilter WSSERVICE tmscard003
 
    Local aHeader       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
 

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DT5_FILORI')      },;    // #"Data de Emissão"
    {"numsol"	    ,  FWX3Titulo('DT5_NUMSOL')      },;        // #"Produto"
    {"datsol"	    ,  FWX3Titulo('DT5_DATSOL')      },;      // #"Grupo de Produto"
    {"codsol"       ,  FWX3Titulo('DT5_CODSOL')      },;    // #"Cod Sol"
    {"nomesol"	    ,  FWX3Titulo('DUE_NREDUZ')      },;    // #"Cliente"
    {"numcot"       ,  FWX3Titulo('DT5_NUMCOT')      },;    // #"Loja"
    {"status"       ,  FWX3Titulo('DT5_STATUS')      };    // #"Loja"
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
WSMETHOD GET cardInfo WSSERVICE tmscard003
 
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
WSMETHOD GET fieldsInfo WSSERVICE tmscard003
    Local oItem         := Nil 
    Local aItems        := {}   
    Local oResponse     := JsonObject():New()
        
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0093 //-- "Qtde Coletas Bloqueadas:"
    oItem["value"] :=	"totalBlq"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0064 // "Mais antiga em Aberto:"
    oItem["value"] :=	"dataold"

    AADD(aItems, oItem)

    
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0065 //"Total em aberto: "
    oItem["value"] :=	"totalOpen"

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
 WSMETHOD GET headerItens WSSERVICE tmscard003

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DT5_FILORI')     },;    // #"Data de Emissão"
    {"numsol"	    ,  FWX3Titulo('DT5_NUMSOL')      },;        // #"Produto"
    {"datsol"	    ,  FWX3Titulo('DT5_DATSOL')      },;      // #"Grupo de Produto"
    {"codsol"       ,  FWX3Titulo('DT5_CODSOL')      },;    // #"Cod Sol"
    {"nomesol"	    ,  FWX3Titulo('DUE_NREDUZ')      },;    // #"Cliente"
    {"numcot"       ,  FWX3Titulo('DT5_NUMCOT')      },;    // #"Loja"
    {"status"       ,  FWX3Titulo('DT5_STATUS')      };    // #"Status"
  }
    
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
Static Function MntQuery(cCampos)
    Local cQuery := ""
    Local cWhere := ''
    Local dData  := FirstDate(dDataBase)

    Default cCampos := " DT5_FILORI, DT5_NUMSOL, DT5_DATSOL, DT5_CODSOL, DUE.DUE_NREDUZ, DT5_NUMCOT, " +;
            " CASE WHEN DT5_STATUS = '1' THEN '1-Em aberto' " +;
            " WHEN DT5_STATUS = '6' THEN '6-Bloqueada' END AS DT5_STATUS"

 
    cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("DT5") + " DT5 "
    cQuery  += " INNER JOIN " + RetSqlName("DUE") + " DUE "
    cQuery  += " ON DUE_FILIAL      = '" + xFilial("DUE") + "' "
    cQuery  += " AND DUE_CODSOL     = DT5.DT5_CODSOL "
    cQuery  += " AND DT5.DT5_DATSOL  >= '" + DToS(dData) + "' "
    cQuery  += " AND DUE.D_E_L_E_T_ = '' "

    cWhere  := " DT5_FILIAL = '" + xFilial("DT5") + "' "
    cWhere  += " AND DT5_FILORI = '" + cFIlAnt + "' "
    cWhere  += " AND DT5_STATUS IN ('1', '6')  "
    cWhere  += " AND DT5_FILORI = '" + cFilAnt + "' "
    cWhere  += " AND DT5.D_E_L_E_T_ = ' ' "

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
        {"filial"   , "DT5_FILORI"           },;
        {"numsol"   , "DT5_NUMSOL"           },;
        {"datsol"   , "DT5_DATSOL"          },;
        {"codsol"   , "DT5_CODSOL"         },;
        {"nomesol"  , "DUE_NREDUZ"         },;
        {"numcot"   , "DT5_NUMCOT"         },;
        {"status"   , "DT5_STATUS"         };
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
    
    oItem["totalBlq"]   := cValToChar( TmsCd03Col("6"))
    oItem["dataold"]    := TmsCd03Old("1")
    oItem["totalOpen"]  := cValToChar( TmsCd03Col("1")  )

    aAdd(aItems, oItem)   
 
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems

Return Nil

/*/{Protheus.doc} TmsCd03Col
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
Function TmsCd03Col( cTipo ) 
Local dData     := FirstDate(dDataBase)
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default cTipo	:= ""

cQuery  := " SELECT COUNT(*)  CONT FROM " + RetSqlName("DT5") + " DT5 "
cQuery  += " WHERE DT5_FILIAL   = '" + xFilial("DT5") + "' "
cQuery  += " AND DT5_STATUS     = '" + cTipo + "' " 
cQuery  += " AND DT5_DATSOL  >= '" + DToS(dData) + "' "
cQuery  += " AND DT5_FILORI = '" + cFilAnt + "' "
cQuery  += " AND DT5.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde

/*/{Protheus.doc} TmsCd03Old
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
Function TmsCd03Old(cTipo) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local dData     := FirstDate(dDataBase)

Default cTipo	:= ""

cQuery  := " SELECT MIN(DT5_DATSOL) DT5_DATSOL FROM " + RetSqlName("DT5") + " DT5 "
cQuery  += " WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
cQuery  += " AND DT5_STATUS   = '" + cTipo + "' " 
cQuery  += " AND DT5_DATSOL  >= '" + DToS(dData) + "' "
cQuery  += " AND DT5_FILORI = '" + cFilAnt + "' "
cQuery  += " AND DT5.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TcSetField(cAliasQry,"DT5_DATSOL","D",TamSX3("DT5_DATSOL")[1],TamSX3("DT5_DATSOL")[2])

If (cAliasQry)->(!Eof())
    dData   := (cAliasQry)->DT5_DATSOL
EndIf 

(cAliasQry)->(dbCloseArea())

Return Transform(DtoS(dData),"@R 9999-99-99")


