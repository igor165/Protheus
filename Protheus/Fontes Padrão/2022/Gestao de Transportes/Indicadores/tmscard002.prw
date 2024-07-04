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
WSRESTFUL TMSCARD002 DESCRIPTION STR0002 //"MDF-es não transmitidos"
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
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE TMSCARD002
 
    Local aHeader       := {}
    Local aRet          := {}
    Local lRet          := .T.
    Local oCoreDash    := CoreDash():New()
 
    Self:SetContentType("application/json")
 
  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DTX_FILMAN')      },;    // #"Data de Emissão"
    {"num"	        ,  FWX3Titulo('DTX_MANIFE')      },;        // #"Produto"
    {"serie"	    ,  FWX3Titulo('DTX_SERMAN')      },;      // #"Grupo de Produto"
    {"data"         ,  FWX3Titulo('DTX_DATMAN')      },;    // #"CFOP"
    {"filori"	    ,  FWX3Titulo('DTX_FILORI')      },;    // #"Cliente"
    {"viagem"       ,  FWX3Titulo('DTX_VIAGEM')      },;    // #"Loja"
    {"uf"           ,  FWX3Titulo('DTX_UFATIV')      },;    // #"Loja"
    {"rtimdf"       ,  FWX3Titulo('DTX_RTIMDF')      },;    
    {"rtfmdf"       ,  FWX3Titulo('DTX_RTFMDF')      },;  
    {"rtcmdf"       ,  FWX3Titulo('DYN_RTCMDF')      },;
    {"dynrtcmdf"    ,  FWX3Titulo('DYN_RTIMDF')      };
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
WSMETHOD GET cardFilter WSSERVICE TMSCARD002
 
    Local aHeader       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
 

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DTX_FILMAN')      },;    // #"Data de Emissão"
    {"num"	        ,  FWX3Titulo('DTX_MANIFE')      },;        // #"Produto"
    {"serie"	    ,  FWX3Titulo('DTX_SERMAN')      },;      // #"Grupo de Produto"
    {"data"         ,  FWX3Titulo('DTX_DATMAN')      },;    // #"CFOP"
    {"filori"	    ,  FWX3Titulo('DTX_FILORI')      },;    // #"Cliente"
    {"viagem"       ,  FWX3Titulo('DTX_VIAGEM')      },;    // #"Loja"
    {"uf"           ,  FWX3Titulo('DTX_UFATIV')      },;    // #"Loja"
    {"rtimdf"       ,  FWX3Titulo('DTX_RTIMDF')        },;    
    {"rtfmdf"       ,  FWX3Titulo('DTX_RTFMDF')         },;
    {"rtcmdf"       ,  FWX3Titulo('DYN_RTCMDF')      },;
    {"dynrtcmdf"    ,  FWX3Titulo('DYN_RTIMDF')      };    
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
WSMETHOD GET cardInfo WSSERVICE TMSCARD002
 
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
WSMETHOD GET fieldsInfo WSSERVICE TMSCARD002
    Local oItem         := Nil 
    Local aItems        := {}   
    Local oResponse     := JsonObject():New()
        
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0008 //-- "Autorizados:"
    oItem["value"] :=	"totalNTrans"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0009 //-- "Nao Autorizados:"
    oItem["value"] :=	"totalNAut"

    AADD(aItems, oItem)

    
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0091 //-- Cancelamento pendente
    oItem["value"] :=	"totalCancel"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0092 //-- Encerramento pendente
    oItem["value"] :=	"totalEncerra"

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
 WSMETHOD GET headerItens WSSERVICE TMSCARD002

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DTX_FILMAN')      },;    // #"Data de Emissão"
    {"num"	        ,  FWX3Titulo('DTX_MANIFE')      },;        // #"Produto"
    {"serie"	    ,  FWX3Titulo('DTX_SERMAN')      },;      // #"Grupo de Produto"
    {"data"         ,  FWX3Titulo('DTX_DATMAN')      },;    // #"CFOP"
    {"filori"	    ,  FWX3Titulo('DTX_FILORI')      },;    // #"Cliente"
    {"viagem"       ,  FWX3Titulo('DTX_VIAGEM')      },;    // #"Loja"
    {"uf"           ,  FWX3Titulo('DTX_UFATIV')      },;    // #"Loja"
    {"rtimdf"       ,  FWX3Titulo('DTX_RTIMDF')      },;    // #"Loja"
    {"rtfmdf"       ,  FWX3Titulo('DTX_RTFMDF')      },;    // #"Loja"
    {"rtcmdf"       ,  FWX3Titulo('DYN_RTCMDF')      },;
    {"dynrtcmdf"    ,  FWX3Titulo('DYN_RTIMDF')      };
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
Local cQuery
Local cWhere
Local dData     := FirstDate(dDataBase)

Default cCampos := " DTX_FILMAN, DTX_MANIFE, DTX_SERMAN, DTX_DATMAN, DTX_FILORI , DTX_VIAGEM, DTX_UFATIV , DTX_RTIMDF , DTX_RTFMDF , DYN_RTCMDF , DYN_RTIMDF "

cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("DTX") + " DTX "
cQuery  += " LEFT JOIN " + RetSqlName("DYN") + " DYN "
cQuery  += " ON DYN_FILIAL  = '" + xFilial("DYN") + "' "
cQuery  += " AND DYN_FILMAN = DTX_FILMAN "
cQuery  += " AND DYN_MANIFE = DTX_MANIFE "
cQuery  += " AND DYN_SERMAN = DTX_SERMAN "
cQuery  += " AND DYN.D_E_L_E_T_ = '' "

cWhere  := " DTX_FILIAL = '" + xFilial("DTX") + "' "
cWhere  += " AND DTX_FILMAN = '" + cFilAnt + "' "
cWhere  += " AND DTX_STIMDF IN ('','3','4','5','6')  "
cWhere  += " AND DTX_DATMAN >= '" + DToS(dData) + "' "
cWhere  += " AND DTX.D_E_L_E_T_ = ' ' "
cWhere  += " AND DTX_FILMAN = '" + cFilAnt + "' "

cQuery := ChangeQuery(cQuery)

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
        {"filial"   , "DTX_FILMAN"           },;
        {"num"      , "DTX_MANIFE"           },;
        {"serie"    , "DTX_SERMAN"          },;
        {"data"     , "DTX_DATMAN"         },;
        {"filori"   , "DTX_FILORI"         },;
        {"viagem"   , "DTX_VIAGEM"         },;
        {"uf"       , "DTX_UFATIV"         },;
        {"rtimdf"   ,  'DTX_RTIMDF'         },;    
        {"rtfmdf"   ,  'DTX_RTFMDF'         },;    
        {"rtcmdf"   ,  'DYN_RTCMDF'         },;
        {"dynrtcmdf"    ,  'DYN_RTIMDF'     };
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
    
    oItem["totalNTrans"]        := cValToChar( TmsCd02Man("1") + TmsCd02Man("6") + TmsCd02Man(,"1") )
    oItem["totalNAut"]          := cValToChar( TmsCd02Man("3") + TmsCd02Man("5") )
    oItem["totalCancel"]        := cValToChar( TmsCd02Can() )
    oItem["totalEncerra"]       := cValToChar( TmsCd02Enc() )

    aAdd(aItems, oItem)   
 
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems

Return Nil

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
Function TmsCd02Man( cTipo , cStatus ) 
Local dData     := FirstDate(dDataBase) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default cTipo	:= SPACE(Len(DTX->DTX_STIMDF)) 
Default cStatus := "" 

cQuery  := " SELECT COUNT(*)  CONT FROM " + RetSqlName("DTX") + " DTX "
cQuery  += " WHERE DTX_FILIAL = '" + xFilial("DTX") + "' "
cQuery  += " AND DTX_DATMAN >= '" + DToS(dData) + "' "
If !Empty( cTipo )
	cQuery  += " AND DTX_STIMDF = '"+  cTipo +"' " //-- Autorizados
Else 
	cQuery  += " AND DTX_STIMDF <> '2' " //-- Autorizados
EndIf 

If !Empty(cStatus)
    cQuery  += " AND DTX_STATUS = '" + cStatus + "' "
EndIf 

cQuery  += " AND DTX_FILMAN = '" + cFilAnt + "' "
cQuery  += " AND DTX.D_E_L_E_T_ = ' ' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde

/*/{Protheus.doc} TmsCd02Can
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
Function TmsCd02Can( cTipo ) 
Local dData     := FirstDate(dDataBase) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default cTipo	:= ""

cQuery  := " SELECT COUNT(*)  CONT FROM " + RetSqlName("DYN") + " DYN "
cQuery  += " WHERE DYN_FILIAL = '" + xFilial("DYN") + "' "
cQuery  += " AND DYN_IDCMDF <> '101' "
cQuery  += " AND DYN_DATMAN >= '" + DToS(dData) + "' "
cQuery  += " AND DYN_FILMAN = '" + cFilAnt + "' "
cQuery  += " AND DYN.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde


/*/{Protheus.doc} TmsCd02Enc
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
Function TmsCd02Enc( cTipo ) 
Local dData     := FirstDate(dDataBase) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default cTipo	:= ""

cQuery  := " SELECT COUNT(*)  CONT FROM " + RetSqlName("DTX") + " DTX "
cQuery  += " WHERE DTX_FILIAL   = '" + xFilial("DTX") + "' "
cQuery  += " AND DTX_IDIMDF     = '100' "
cQuery  += " AND DTX_IDFMDF     = '' "
cQuery  += " AND DTX_DATMAN >= '" + DToS(dData) + "' "
cQuery  += " AND DTX_FILMAN = '" + cFilAnt + "' "
cQuery  += " AND DTX.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde

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
Static Function Mes( dData )
Local cMes      := ""
Local nMes		:= 0 

Default dData	:= dDataBase 

nMes	:= Month(dData )

If nMes == 1 
    cMes    := STR0048 //-- "JANEIRO"
ElseIf nMes == 2 
    cMes    := STR0049 // "FEVEREIRO"
ElseIf nMes == 3 
    cMes    := STR0050 //"MARÇO"
ElseIf nMes == 4 
    cMes    := STR0051 //"ABRIL"
ElseIf nMes == 5 
    cMes    := STR0052 //"MAIO"
ElseIf nMes == 6 
    cMes    := STR0053 //-- "JUNHO"
ElseIf nMes == 7 
    cMes    := STR0054 // "JULHO"
ElseIf nMes == 8 
    cMes    := STR0055 //"AGOSTO"
ElseIf nMes == 9 
    cMes    := STR0056 //"SETEMBRO"
ElseIf nMes == 10 
    cMes    := STR0057 //"OUTUBRO"
ElseIf nMes == 11 
    cMes    := STR0058 //"NOVEMBRO"
ElseIf nMes == 12 
    cMes    := STR0059 //"DEZEMBRO"
EndIf  

Return cMes 

