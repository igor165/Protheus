#include 'totvs.ch'
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
WSRESTFUL TMSCHART001 DESCRIPTION STR0001 //-- CT-es não transmitidos"

	WSDATA JsonFilter       AS STRING	OPTIONAL
	WSDATA drillDownFilter  AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL

	WSMETHOD GET form ;
		DESCRIPTION "Carrega os campos que serão apresentados no formulário" ; // #"Carrega os campos que serão apresentados no formulário"
	WSSYNTAX "/charts/form/" ;
		PATH "/charts/form";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST retdados ;
		DESCRIPTION "Carrega os itens" ; // # "Carrega os itens"
	WSSYNTAX "/charts/retdados/{JsonFilter}" ;
		PATH "/charts/retdados";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST itemsDetails ;
		DESCRIPTION "Carrega os Itens Utilizados para Montagem do itens" ; // # "Carrega os Itens Utilizados para Montagem do itens"
	WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
		PATH "/charts/itemsDetails";
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
WSMETHOD GET form WSSERVICE TMSCHART001

	Local oResponse  := JsonObject():New()
	Local oCoreDash  := CoreDash():New()

	oCoreDash:SetPOForm(STR0039 , "charttype"       , 6   , STR0039 , .T., "string" , oCoreDash:SetPOCombo({{"bar",STR0043}}))
	oCoreDash:SetPOForm(STR0040 , "datainicio"      , 6   , STR0041 , .T., "date")
	oCoreDash:SetPOForm(""      , "datafim"         , 6   , STR0042 , .T., "date")
	
	oResponse  := oCoreDash:GetPOForm()

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
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL TMSCHART001

	Local aHeader     := {}
	Local aItems      := {}
	Local aRet        := {}
	Local aFilter     := {}
	Local lRet	      := .T.
	Local cSelect     := ""
	Local cFilter     := ""
	Local cError	  := STR0062 //-- Erro na requisição
	Local cBody       := DecodeUtf8(Self:GetContent())
	Local oCoreDash   := CoreDash():New()
	Local oBody       := JsonObject():New()
	Local oJsonFilter := JsonObject():New()
	Local oJsonDD     := JsonObject():New()
	Local nLenFilter  := 0
	Local nX          := 0

	If !Empty(cBody)
		oBody:FromJson(cBody)

		If ValType(oBody["chartFilter"]) == "J"
			oJsonFilter := oBody["chartFilter"]
		EndIf

		If ValType(oBody["detailFilter"]) == "A"
			oJsonDD := oBody["detailFilter"]
		EndIf
	EndIf

	Self:SetContentType("application/json")

	If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
		If Len(oJsonDD) == 0
			
			aHeader := {;
				{"filial"	    ,  FWX3Titulo('DT6_FILDOC') ,"link"     ,,.T.,.T.     },;    // #"Data de Emissão"
				{"num"	        ,  FWX3Titulo('DT6_DOC')   ,     ,,.T.,.T.    },;        // #"Produto"
				{"serie"	    ,  FWX3Titulo('DT6_SERIE')  ,           ,,.T.,.T.    },;      // #"Grupo de Produto"
				{"cliente"	    ,  FWX3Titulo('DT6_CLIREM') ,           ,,.T.,.T.     },;    // #"Cliente"
				{"loja"         ,  FWX3Titulo('DT6_LOJREM') ,           ,,.T.,.T.     },;    // #"Loja"
				{"nome"         ,  FWX3Titulo('DT6_NOMREM') ,           ,,.T.,.T.     },;
				{"data"         ,  FWX3Titulo('DT6_DATEMI') ,           ,,.T.,.T.     },;    // #"CFOP"
				{"retcte"        ,  FWX3Titulo('DT6_RETCTE') ,           ,,.T.,.T.     };    // #"CFOP"
				}

			aItems := {;
				{"filial"	    ,  "DT6_FILDOC"     },;    // #"Data de Emissão"
				{"num"	        ,  "DT6_DOC"      },;        // #"Produto"
				{"serie"	    ,  "DT6_SERIE"      },;      // #"Grupo de Produto"
				{"cliente"	    ,  "DT6_CLIREM"      },;    // #"Cliente"
				{"loja"         ,  "DT6_LOJREM"      },;    // #"Loja"
				{"data"         ,  "DT6_DATEMI"     },;    // #"DATEMI"
				{"retcte"		, "DT6_RETCTE" };
			}

			cSelect :=" DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CLIREM, DT6_LOJREM, DT6_DATEMI , A1_NREDUZ , DT6_RETCTE " 

			cFilter += FilterForm(oJsonFilter) 
			oCoreDash:SetFields(aItems) 
			oCoreDash:SetApiQstring(Self:aQueryString) 
			aFilter := oCoreDash:GetApiFilter() 
			nLenFilter := Len(aFilter)
			If nLenFilter > 0
				For nX := 1 to nLenFilter
					cFilter += " AND " + aFilter[nX][1]
				Next
			EndIf

			aRet := QueryDT6(cSelect,cFilter)
			oCoreDash:SetQuery(aRet[1])
			oCoreDash:SetWhere(aRet[2])
			oCoreDash:SetGroupBy(aRet[3])

		Endif
	EndIf

	oCoreDash:BuildJson()

	If lRet
		oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
	FreeObj(oJsonDD)
	FreeObj(oJsonFilter)
	FreeObj(oBody)

	aSize(aRet, 0)
	aSize(aItems, 0)
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
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE TMSCHART001

	Local oResponse := JsonObject():New()
	Local oCoreDash := CoreDash():New()
	Local oJson     := JsonObject():New()

	oJson:FromJson(DecodeUtf8(Self:GetContent()))

	retDados(@oResponse, oCoreDash, oJson)

	Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

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
Static Function retDados(oResponse, oCoreDash, oJson)

	Local aData     := {}
	Local aDataFim  := {}
	Local aCab      := {}
	Local aClrChart := oCoreDash:GetColorChart() //cor do gráfico
	Local cFilter   := ""
	Local nX        := 0
	Local nAuxClr	:= 0

	cFilter := FilterForm(oJson) 

	If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0

		aAdd(aCab,STR0009 ) //-- "Não Autorizados")
		aAdd(aCab,STR0046) //"Falha Comunicação")
		aAdd(aCab,STR0047 ) //"Não Transmitido")
		aAdd(aCab,STR0091 ) //"	//-- Cancelamento pendente

		aAdd(aData, TmsCd01Cte("3") )
		aAdd(aData, TmsCd01Cte("5") )
		aAdd(aData, TmsCd01Cte("0") )
		aAdd(aData, TmsCd01Sta("B") )
		
		For nX := 1 To Len(aData)
			nAuxClr++
			oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nX + nAuxClr][3] /*"cColorBackground"*/ )
		Next  

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({STR0001 },,/*lCurrency*/.F.,, STR0001 + " " + Mes(dDataBase) )) //--  "CT-es não transmitidos"
	EndIf
	oResponse["items"] := aDataFim

Return

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
Static Function QueryDT6(cSelect as Char, cFilter as Char)

	Local cQuery  := ""
	Local cWhere  := ""
	Local cGroup  := ""
	Local dData   := FirstDate(dDataBase)

	Default cSelect := " DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CLIREM, DT6_LOJREM, DT6_DATEMI , A1_NREDUZ , DT6_RETCTE"
	Default cFilter := ""

	cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("DT6") + " DT6 "
	cQuery  += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
    cQuery  += " ON A1_FILIAL   = '" + xFilial("SA1") + "' "
    cQuery  += " AND A1_COD     = DT6_CLIREM "
    cQuery  += " AND A1_LOJA    = DT6_LOJREM "
    cQuery  += " AND SA1.D_E_L_E_T_ = '' "

	cWhere := " DT6_FILIAL = '" + xFilial("DT6") + "' "
	cWhere += " AND DT6_DATEMI >= '" + DToS(dData) + "' "
	If !Empty(cFilter)
		cWhere += cFilter
	Endif

	cWhere += " AND DT6.D_E_L_E_T_ = ' ' "
	
Return { cQuery, cWhere, cGroup }

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
Static Function FilterForm(oJson)

	Local cFilter 	:= ""

	cFilter += " AND DT6_SITCTE IN ('3','4','5','6')  
	cFilter	+= " AND DT6_FILDOC		= '" + cFilAnt + "' "
	cFilter += " AND DT6_DATEMI >= '" + DToS( FirstDate(dDataBase) ) + "' "

Return cFilter

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



