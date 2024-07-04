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
WSRESTFUL tmschart004 DESCRIPTION STR0074 // "Viagens 

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
WSMETHOD GET form WSSERVICE tmschart004

	Local oResponse  := JsonObject():New()
	Local oCoreDash  := CoreDash():New()

	oCoreDash:SetPOForm(STR0025 , "charttype"       , 6   , STR0025 , .T., "string" , oCoreDash:SetPOCombo({{"bar",STR0026}}))
	oCoreDash:SetPOForm(STR0027 , "datainicio"      , 6   , STR0028 , .T., "date")
	oCoreDash:SetPOForm(""      , "datafim"         , 6   , STR0029 , .T., "date")
	
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
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL tmschart004

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
				{"filori"	    ,  FWX3Titulo('DTQ_FILORI') ,"link"     ,,.T.,.T.     },;    // #"Data de Emissão"
				{"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM') ,     		,,.T.,.T.    },;        // #"Produto"
				{"rota"	    	,  FWX3Titulo('DTQ_ROTA')  ,            ,,.T.,.T.    },;      // #"Grupo de Produto"
				{"datfec"	    ,  FWX3Titulo('DTQ_DATFEC') ,           ,,.T.,.T.     },;    // #"Cliente"
				{"horfec"       ,  FWX3Titulo('DTQ_HORFEC') ,           ,,.T.,.T.     },;    // #"Loja"
				{"datini"       ,  FWX3Titulo('DTQ_DATINI') ,           ,,.T.,.T.     },;
				{"status"       ,  FWX3Titulo('DTQ_STATUS') ,           ,,.T.,.T.     };    // #"CFOP"
				}

			aItems := {;
				{"filori"   , "DTQ_FILORI"           },;
				{"viagem"   , "DTQ_VIAGEM"           },;
				{"rota"   , "DTQ_ROTA"          },;
				{"datini"   , "DTQ_DATINI"         },;
				{"datfec"   , "DTQ_DATFEC"         },;
				{"horfec"  , "DTQ_HORFEC"         },;
				{"status"   , "DTQ_STATUS"         };
				}
			
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

			aRet := QueryDTQ(,cFilter)
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
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE tmschart004

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

/*/{Protheus.doc} retDados
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

		aAdd(aCab,STR0070 ) // "Viagens em Trânsito:"
		aAdd(aCab,STR0071 ) // "Viagens em Aberto:"
		aAdd(aCab,STR0072 ) // "Viagens Fechadas:"
		aAdd(aCab,STR0073 ) // "Viagens com Chegada em Filial: "

		aAdd(aData, TmsCd04Vge("2") )
		aAdd(aData, TmsCd04Vge("1") )
		aAdd(aData, TmsCd04Vge("5") )
		aAdd(aData, TmsCd04Vge("4") )
	

		For nX := 1 To Len(aData)
			nAuxClr++
			oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nX + nAuxClr][3] /*"cColorBackground"*/ )
		Next  

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({STR0074},,/*lCurrency*/.F.,, STR0074  )) //-- "Viagens 
	EndIf

	oResponse["items"] := aDataFim

Return

/*/{Protheus.doc} QueryDTQ
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
Static Function QueryDTQ(cSelect as Char, cFilter as Char)

	Local cQuery  := ""
	Local cWhere  := ""
	Local cGroup  := ""

	Default cSelect := " DTQ_FILORI, DTQ_VIAGEM, DTQ_ROTA, DTQ_DATFEC , DTQ_HORFEC , DTQ_DATINI , DTQ_HORINI,  " +;
			 			" CASE WHEN DTQ_STATUS = '1' THEN '1-Em aberto' " + ;
                        " WHEN DTQ_STATUS = '2' THEN '1-Em trânsito' " + ;
                        " WHEN DTQ_STATUS = '4' THEN '4-Chegada em Filial' " + ;
                        " WHEN DTQ_STATUS = '5' THEN '5-Fechada' END AS DTQ_STATUS"
	Default cFilter := ""

	
	cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("DTQ") + " DTQ "

	cWhere := " DTQ_FILIAL = '" + xFilial("DTQ") + "' "

	If !Empty(cFilter)
		cWhere += cFilter
	Endif

	cWhere += " AND DTQ.D_E_L_E_T_ = ' ' "
	
Return { cQuery, cWhere, cGroup }

/*/{Protheus.doc} FilterForm
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

cFilter  += " AND DTQ_STATUS IN ('2') " //-- 2=Em Trânsito
cFilter	+= " AND DTQ_FILORI = '" + cFilAnt + "' "


Return cFilter


