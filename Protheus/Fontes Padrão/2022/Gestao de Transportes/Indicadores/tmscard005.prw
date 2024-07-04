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
WSRESTFUL tmscard005 DESCRIPTION STR0006 //--"Documentos Pendentes X Viagens em Trânsito"
    WSDATA Fields              AS Character   
    WSDATA  Order              AS Character   
    WSDATA  Page               As Integer 
    WSDATA  PageSize           As Integer
    
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
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE tmscard005
 
    Local aHeader       := {}
    Local aRet          := {}
    Local lRet          := .T.
    Local oCoreDash    := CoreDash():New()
 
    Self:SetContentType("application/json")
  
  aHeader := {;
    {"filori"	    ,   FWX3Titulo('DTQ_FILORI')      },;   
    {"viagem"	    ,   FWX3Titulo('DTQ_VIAGEM')      },;        
    {"fildoc"	    ,   FWX3Titulo('DT6_FILDOC')      },;      
    {"doc"          ,   FWX3Titulo('DT6_DOC')         },;   
    {"serie"	    ,   FWX3Titulo('DT6_SERIE')       },;  
    {"clirem"       ,   FWX3Titulo('DT6_CLIREM')      },;   
    {"lojrem"       ,   FWX3Titulo('DT6_LOJREM')      },;    
    {"nomrem"       ,   FWX3Titulo('DT6_NOMREM')      },; 
    {"clides"       ,   FWX3Titulo('DT6_CLIDES')      },; 
    {"lojdes"       ,   FWX3Titulo('DT6_LOJDES')      },; 
    {"nomdes"       ,   FWX3Titulo('DT6_NOMDES')      }; 
  }
 
    //Chama a função responsavel por montar a Expressão SQL
    aRet := TmsCd05Qry()
 
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
WSMETHOD GET cardFilter WSSERVICE tmscard005
 
    Local aHeader       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
 
  aHeader := {;
    {"filori"	    ,   FWX3Titulo('DTQ_FILORI')      },;   
    {"viagem"	    ,   FWX3Titulo('DTQ_VIAGEM')      },;        
    {"fildoc"	    ,   FWX3Titulo('DT6_FILDOC')      },;      
    {"doc"          ,   FWX3Titulo('DT6_DOC')         },;   
    {"serie"	    ,   FWX3Titulo('DT6_SERIE')       },;  
    {"clirem"       ,   FWX3Titulo('DT6_CLIREM')      },;   
    {"lojrem"       ,   FWX3Titulo('DT6_LOJREM')      },;    
    {"nomrem"       ,   FWX3Titulo('DT6_NOMREM')      },; 
    {"clides"       ,   FWX3Titulo('DT6_CLIDES')      },; 
    {"lojdes"       ,   FWX3Titulo('DT6_LOJDES')      },; 
    {"nomdes"       ,   FWX3Titulo('DT6_NOMDES')      }; 
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
WSMETHOD GET cardInfo WSSERVICE tmscard005
 
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
WSMETHOD GET fieldsInfo WSSERVICE tmscard005
    Local oItem         := Nil 
    Local aItems        := {}   
    Local oResponse     := JsonObject():New()
    

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0096 // total DOCUMENTOS 
    oItem["value"] :=	"totalCte1"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"]  :=	STR0094 // "Documentos não entregues" 
    oItem["value"] :=	"totalCte2"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"] :=	STR0095 //-- "% de entregas realizadas"  
    oItem["value"] :=	"percentEnt"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"] :=	STR0103 //-- "% de entregas não realizadas"  
    oItem["value"] :=	"totalCte3"

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
 WSMETHOD GET headerItens WSSERVICE tmscard005

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  aHeader := {;
    {"filori"	    ,  FWX3Titulo('DTQ_FILORI')      },;   
    {"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM')      },;        
    {"fildoc"	    ,  FWX3Titulo('DT6_FILDOC')      },;      
    {"doc"          ,  FWX3Titulo('DT6_DOC')         },;   
    {"serie"	    ,  FWX3Titulo('DT6_SERIE')       },;  
    {"clirem"       ,  FWX3Titulo('DT6_CLIREM')      },;   
    {"lojrem"       ,  FWX3Titulo('DT6_LOJREM')      },;    
    {"nomrem"       ,  FWX3Titulo('DT6_NOMREM')      },; 
    {"clides"       ,  FWX3Titulo('DT6_CLIDES')      },; 
    {"lojdes"       ,  FWX3Titulo('DT6_LOJDES')      },; 
    {"nomdes"       ,  FWX3Titulo('DT6_NOMDES')      }; 
  }
    
  oResponse["items"]   := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

/*/{Protheus.doc} TmsCd05Qry
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
Static Function TmsCd05Qry(cCampos)
    Local cQuery := ""
    Local cWhere := ""
    Local dData  := FirstDate(dDataBase)

    Default cCampos := " DTQ_FILORI, DTQ_VIAGEM, DT6_FILDOC, DT6_DOC , DT6_SERIE , DT6_CLIREM , DT6_LOJREM , SA1REM.A1_NREDUZ AS DT6_NOMREM , DT6_CLIDES, DT6_LOJDES , SA1DES.A1_NREDUZ AS DT6_NOMDES"
 
    cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("DTQ") + " DTQ "
    cQuery  += " INNER JOIN " + RetSqlName("DUD") + " DUD "
    cQuery  += " ON DUD_FILIAL  = '" + xFilial("DUD") + "' "
    cQuery  += " AND DUD_FILORI     = DTQ_FILORI "
    cQuery  += " AND DUD_VIAGEM     = DTQ_VIAGEM "
    cQuery  += " AND DUD_STATUS     IN ('3', '2') "
    cQuery  += " AND DUD.D_E_L_E_T_ = '' "
    cQuery  += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
    cQuery  += " ON DT6_FILIAL      = '" + xFilial("DT6") + "' "
    cQuery  += " AND DT6_FILDOC     = DUD_FILDOC "
    cQuery  += " AND DT6_DOC        = DUD_DOC "
    cQuery  += " AND DT6_SERIE      = DUD_SERIE "
    cQuery  += " AND DT6.D_E_L_E_T_ = '' "
    cQuery  += " LEFT JOIN " + RetSqlName("SA1") + " SA1REM "
    cQuery  += " ON SA1REM.A1_FILIAL       = '" + xFilial("SA1") + "' "
    cQuery  += " AND SA1REM.A1_COD         = DT6_CLIREM "
    cQuery  += " AND SA1REM.A1_LOJA        = DT6_LOJREM "
    cQuery  += " AND SA1REM.D_E_L_E_T_ = '' "
    cQuery  += " LEFT JOIN " + RetSqlName("SA1") + " SA1DES "
    cQuery  += " ON SA1DES.A1_FILIAL       = '" + xFilial("SA1") + "' "
    cQuery  += " AND SA1DES.A1_COD         = DT6_CLIDES "
    cQuery  += " AND SA1DES.A1_LOJA        = DT6_LOJDES "
    cQuery  += " AND SA1DES.D_E_L_E_T_ = '' "

    cWhere  := " DTQ_FILIAL = '" + xFilial("DTQ") + "' "
    cWhere  += " AND DTQ_STATUS IN ('2')  "
    cWhere  += " AND DTQ.D_E_L_E_T_ = ' ' "
    cWhere  += " AND DTQ_FILORI = '" + cFilAnt + "' 
    cWhere  += " AND DUD_SERIE  <> 'COL' "

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
        {"filori"   , "DTQ_FILORI"          },;
        {"viagem"   , "DTQ_VIAGEM"          },;
        {"fildoc"   , "DT6_FILDOC"          },;
        {"doc"      , "DT6_DOC"             },;
        {"serie"    , "DT6_SERIE"           },;
        {"clirem"   , "DT6_CLIREM"          },;
        {"lojrem"   , "DT6_LOJREM"          },;
        {"nomrem"   , "DT6_NOMREM"          },;
        {"clides"   , "DT6_CLIDES"          },;
        {"lojdes"   , "DT6_LOJDES"          },;
        {"nomdes"   , "DT6_NOMDES"          };
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
    Local nCte1     := 0 
    Local nCte2     := 0 
    Local nTotal3   := 0 
    Local nPercent  := 0 

    oItem := JsonObject():New()
    
    nCte1   := TmsCd05Vge("2",  ) 
    nCte2   := TmsCd05Vge( "2", "3" ) + TmsCd05Vge( "2", "2" )
    nTotal3 := Round( 100 * ( nCte2 / nCte1 ), 2 )
    

    oItem["totalCte1"]           := nCte1
    oItem["totalCte2"]           := nCte2
    If nCte1 <> nCte2
        oItem["totalCte3"]      := Iif( nTotal3 >= 0 , nTotal3 , 0 )
    Else
         oItem["totalCte3"]     := 0
    EndIf

    nPercent    := 100 - oItem["totalCte3"]

    oItem["percentEnt"]           := Iif( nPercent >=0 , nPercent , 0 )

    aAdd(aItems, oItem)   
 
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems

Return Nil

/*/{Protheus.doc} TmsCd05Vge
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
Function TmsCd05Vge( cVgeSt , cDocSt , cSerie ) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde     := 0 
Local dData     := FirstDate(dDataBase)

Default cVgeSt	:= ""
Default cDocSt  := ""
Default cSerie  := ""

cQuery  := " SELECT COUNT(DUD_DOC)  CONT FROM " + RetSqlName("DTQ") + " DTQ "
cQuery  += " INNER JOIN " + RetSqlName("DUD") + " DUD "
cQuery  += " ON DUD_FILIAL      = '" + xFilial("DUD") + "' "
cQuery  += " AND DUD_FILORI     = DTQ_FILORI    "
cQuery  += " AND DUD_VIAGEM     = DTQ_VIAGEM "

If !Empty(cDocSt)
    cQuery  += " AND DUD_STATUS     = '" + cDocSt + "' "
EndIf 

If !Empty(cSerie)
    cQuery  += " AND DUD_SERIE  = '" + cSerie + "' "
Else 
    cQuery  += " AND DUD_SERIE  <> 'COL' "
EndIf 
cQuery  += " AND DUD.D_E_L_E_T_ = '' "
cQuery  += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery  += " ON  DT6_FILIAL     = '" + xFilial("DT6") + "' "
cQuery  += " AND DT6_FILDOC     = DUD_FILDOC "
cQuery  += " AND DT6_DOC        = DUD_DOC "
cQuery  += " AND DT6_SERIE      = DUD_SERIE "
cQuery  += " AND DT6.D_E_L_E_T_ = '' " 
cQuery  += " WHERE DTQ_FILIAL   = '" + xFilial("DTQ") + "' "
cQuery  += " AND DTQ_FILORI = '" + cFilAnt + "' "
cQuery  += " AND DTQ_STATUS     = '" + cVgeSt + "' " 
cQuery  += " AND DTQ.D_E_L_E_T_ = ' ' "
cQuery  += " AND DTQ_FILORI = '" + cFilAnt + "' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde
