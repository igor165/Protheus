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
WSRESTFUL tmschart006 DESCRIPTION STR0086 // XML NFe Sefaz Vge em Transito 

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
WSMETHOD GET form WSSERVICE tmschart006

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
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL tmschart006

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

	If AliasInDic("DMH")
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
					{"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM') ,     		,,.T.,.T.     },;        // #"Produto"
					{"chvnfe"	    ,  FWX3Titulo('DMH_CHVNFE') ,           ,,.T.,.T.     },;      // #"Grupo de Produto"
					{"status"	    ,  FWX3Titulo('DMH_STATUS') ,           ,,.T.,.T. };    // #"Cliente" 
					}

				aItems := {;
					{"filori"   , "DTQ_FILORI"          },;
					{"viagem"   , "DTQ_VIAGEM"          },;
					{"chvnfe"   , "DMH_CHVNFE"          },;
					{"status"   , "DMH_STATUS"          };
					}

				cSelect := " DTQ_FILORI, DTQ_VIAGEM, DMH_CHVNFE, DMH_STATUS  "

				oCoreDash:SetFields(aItems) 
				oCoreDash:SetApiQstring(Self:aQueryString) 
			
				aRet := TmsCd08Qry(cSelect)
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
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE tmschart006

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
	Local nX        := 0
	Local nAuxClr	:= 0

	If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0

		aAdd(aCab, STR0087 ) // "Qtde NF Coletadas" ) 
		aAdd(aCab,STR0088 )// "NF Pendente" ) 
		aAdd(aCab,STR0089 ) //"NF Processada" )
		aAdd(aCab,STR0090 ) //"NF Não Encontrada" )

		aAdd(aData, TmsCd08Col() )
		aAdd(aData, TmsCd08Col("1") )
		aAdd(aData, TmsCd08Col("2") )
		aAdd(aData, TmsCd08Col("3") )

		For nX := 1 To Len(aData)
			nAuxClr++
			oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nX + nAuxClr][3] /*"cColorBackground"*/ )
		Next  

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({STR0086},,/*lCurrency*/.F.,, STR0086  )) //-- XML NFe Sefaz Vge em Transito 
	EndIf

	oResponse["items"] := aDataFim

Return



