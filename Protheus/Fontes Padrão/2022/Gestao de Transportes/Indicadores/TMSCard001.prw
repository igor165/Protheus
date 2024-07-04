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
WSRESTFUL TMSCARD001 DESCRIPTION STR0001 // "CT-Es Autorizados - Nao Autorizados"
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
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE TMSCARD001
 
    Local aHeader       := {}
    Local aRet          := {}
    Local lRet          := .T.
    Local oCoreDash    := CoreDash():New()
 
    Self:SetContentType("application/json")
 

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DT6_FILDOC',)     },;    // #"Data de Emissão"
    {"num"	        ,  FWX3Titulo('DT6_DOC')         },;        // #"Produto"
    {"serie"	    ,  FWX3Titulo('DT6_SERIE')       },;      // #"Grupo de Produto"
    {"cliente"	    ,  FWX3Titulo('DT6_CLIREM')      },;    // #"Cliente"
    {"loja"         ,  FWX3Titulo('DT6_LOJREM')      },;    // #"Loja"
    {"nome"         ,  FWX3Titulo('DT6_NOMREM')      },;    // #"Loja"
    {"data"         ,  FWX3Titulo('DT6_DATEMI')      },;    // #"Emissao"
    {"retcte"       ,  FWX3Titulo('DT6_RETCTE')      };    // #"Retorno SEFAZ"
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
WSMETHOD GET cardFilter WSSERVICE TMSCARD001
 
    Local aHeader       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
 

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DT6_FILDOC')         },;    // #"Data de Emissão"
    {"num"	        ,  FWX3Titulo('DT6_DOC')            },;        // #"Produto"
    {"serie"	    ,  FWX3Titulo('DT6_SERIE')          },;      // #"Grupo de Produto"
    {"cliente"	    ,  FWX3Titulo('DT6_CLIREM')         },;    // #"Cliente"
    {"loja"         ,  FWX3Titulo('DT6_LOJREM')         },;    // #"Loja"
    {"data"         ,  FWX3Titulo('DT6_DATEMI')         },;    // #"Emissão"
    {"retcte"       ,  FWX3Titulo('DT6_RETCTE')         };    // #"Retorno SEFAZ"
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
WSMETHOD GET cardInfo WSSERVICE TMSCARD001
 
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
WSMETHOD GET fieldsInfo WSSERVICE TMSCARD001
    Local oItem         := Nil 
    Local aItems        := {}   
    Local oResponse     := JsonObject():New()
        
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0008 // "nÃO TRANSMITIDO:"
    oItem["value"] :=	"totalNTrans"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0009 // "Nao Autorizados:"
    oItem["value"] :=	"totalNAut"

    AADD(aItems, oItem)

    
    oItem := JsonObject():New()
    oItem["label"]  :=	STR0091 //-- Cancelamento pendente
    oItem["value"] :=	"totalCancel"

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
 WSMETHOD GET headerItens WSSERVICE TMSCARD001

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  aHeader := {;
    {"filial"	    ,  FWX3Titulo('DT6_FILDOC')         },;    // #"Data de Emissão"
    {"num"	        ,  FWX3Titulo('DT6_DOC')            },;        // #"Produto"
    {"serie"	    ,  FWX3Titulo('DT6_SERIE')          },;      // #"Grupo de Produto"
    {"cliente"	    ,  FWX3Titulo('DT6_CLIREM')         },;    // #"Cliente"
    {"loja"         ,  FWX3Titulo('DT6_LOJREM')         },;    // #"Loja"
    {"data"         ,  FWX3Titulo('DT6_DATEMI')         },;    // #"Emissão"
    {"retcte"       ,  FWX3Titulo('DT6_RETCTE')         };    // #Retorno Sefaz
  }
    
  oResponse["items"]   := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))



Return .T.
/*/{Protheus.doc} MntQuery(cCampos)
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

    Default cCampos := " DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CLIREM, DT6_LOJREM , A1_NREDUZ, DT6_DATEMI, DT6_RETCTE "
    
    cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("DT6") + " DT6 "
    cQuery  += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
    cQuery  += " ON A1_FILIAL   = '" + xFilial("SA1") + "' "
    cQuery  += " AND A1_COD     = DT6_CLIREM "
    cQuery  += " AND A1_LOJA    = DT6_LOJREM "
    cQuery  += " AND SA1.D_E_L_E_T_ = '' "

    cWhere  := " DT6_FILIAL = '" + xFilial("DT6") + "' "
    cWhere  += " AND DT6_FILDOC = '" + cFilAnt + "' "
    cWhere  += " AND DT6_SITCTE IN ('0', '3','4','5','6')  "
    cWhere  += " AND DT6_DATEMI  >= '" + DToS(dData) + "' "
    cWhere  += " AND DT6.D_E_L_E_T_ = ' ' "

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
        {"filial"   , "DT6_FILDOC"           },;
        {"num"      , "DT6_DOC"              },;
        {"serie"    , "DT6_SERIE"            },;
        {"cliente"  , "DT6_CLIREM"           },;
        {"loja"     , "DT6_LOJREM"           },;
        {"nome"     , "A1_NREDUZ"            },;
        {"data"     , "DT6_DATEMI"           },;
        {"retcte"   , "DT6_RETCTE"           };
        }

Return aCampos
 
/*/{Protheus.doc} RetCardInfo()
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
    Local nNaoAut   := 0 

    oItem := JsonObject():New()
    
    nNaoAut     := TmsCd01Cte("3") + TmsCd01Cte("5") + TmsCd01Cte("1") 
    
    oItem["totalNTrans"]    := cValToChar( TmsCd01Cte("0"))
    oItem["totalNAut"]      := cValToChar( nNaoAut )
    oItem["totalCancel"]    := cValToChar( TmsCd01Sta( "B" ) )

    aAdd(aItems, oItem)   
 
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems

Return Nil

/*/{Protheus.doc} TmsCd01Cte()
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
Function TmsCd01Cte( cTipo , cStatus ) 
Local dData     := FirstDate(dDataBase)
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default cTipo	:= ""
Default cStatus := "" 

cQuery  := " SELECT COUNT(DT6_DOC) CONT FROM " + RetSqlName("DT6") + " DT6 "
cQuery  += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery  += " AND DT6_DATEMI  >= '" + DToS(dData) + "' "
If !Empty( cTipo )
	cQuery  += " AND DT6_SITCTE = '"+  cTipo +"' " //-- Autorizados
Else 
	cQuery  += " AND DT6_SITCTE <> '2' " //-- Autorizados
EndIf 

If !Empty(cStatus)
    cQuery  += " AND DT6_STATUS = '" + cStatus + "' "
EndIf 
cQuery  += " AND DT6_FILDOC = '" + cFilAnt + "' "
cQuery  += " AND DT6.D_E_L_E_T_ = ' ' "

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
Function TmsCd01Sta( cStatus ) 
Local dData     := FirstDate(dDataBase)
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default cStatus := "" 

cQuery  := " SELECT COUNT(DT6_DOC)  CONT FROM " + RetSqlName("DT6") + " DT6 "
cQuery  += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery  += " AND DT6_DATEMI >= '" + DToS(dData) + "' "
cQuery  += " AND DT6_FILDOC = '" + cFilAnt + "' "
If !Empty(cStatus)
    cQuery  += " AND DT6_STATUS = '" + cStatus + "' "
EndIf 

cQuery  += " AND DT6.D_E_L_E_T_ = ' ' "

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

