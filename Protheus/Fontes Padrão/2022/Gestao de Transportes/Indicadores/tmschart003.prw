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
WSRESTFUL tmschart003 DESCRIPTION STR0003 //"Sol. coletas pendentes"

	WSDATA JsonFilter       AS STRING	OPTIONAL
	WSDATA drillDownFilter  AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL

	WSMETHOD GET form ;
		DESCRIPTION "Carrega os campos que ser�o apresentados no formul�rio" ; // #"Carrega os campos que ser�o apresentados no formul�rio"
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
WSMETHOD GET form WSSERVICE tmschart003

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
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL tmschart003

	Local aHeader     := {}
	Local aItems      := {}
	Local aRet        := {}
	Local aFilter     := {}
	Local lRet	      := .T.
	Local cSelect     := ""
	Local cFilter     := ""
	Local cError	  := STR0062 //-- Erro na requisi��o
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
				{"filial"	    ,  FWX3Titulo('DT5_FILORI') ,"link"     ,,.T.,.T.     },;    // #"Data de Emiss�o"
				{"numsol"	    ,  FWX3Titulo('DT5_NUMSOL') ,     		,,.T.,.T.     },;        // #"Produto"
				{"datsol"	    ,  FWX3Titulo('DT5_DATSOL') ,           ,,.T.,.T.     },;      // #"Grupo de Produto"
				{"codsol"	    ,  FWX3Titulo('DT5_CODSOL') ,           ,,.T.,.T.     },;    // #"Cliente"
				{"nomesol"      ,  FWX3Titulo('DUE_NREDUZ') ,           ,,.T.,.T.     },;    // #"Loja"
				{"numcot"       ,  FWX3Titulo('DT5_NUMCOT') ,           ,,.T.,.T.     },;
				{"status"       ,  FWX3Titulo('DT5_STATUS') ,           ,,.T.,.T.     };    // #"Status"
				}
 
			aItems := {;
				{"filial"	    ,  "DT5_FILORI"     },;    // #"Data de Emiss�o"
				{"numsol"	    ,  "DT5_NUMSOL"      },;        // #"Produto"
				{"datsol"	    ,  "DT5_DATSOL"      },;      // #"Grupo de Produto"
                {"codsol"	    ,  "DT5_CODSOL"      },;    // #"Cliente"
				{"nomesol"	    ,  "DUE_NREDUZ"      },;    // #"Cliente"
				{"numcot"       ,  "DT5_NUMCOT"      },;    // #"Loja"
				{"status"       ,  "DT5_STATUS"     };    // #"Status"
			}

			cSelect :=" DT5_FILORI, DT5_NUMSOL, DT5_DATSOL, DT5_CODSOL, DUE.DUE_NREDUZ, DT5_NUMCOT, DT5_STATUS "

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

			aRet := QueryDT5(cSelect,cFilter)
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
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE tmschart003

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
	Local aClrChart := oCoreDash:GetColorChart() //cor do gr�fico
	Local cFilter   := ""
	Local nX        := 0
	Local nAuxClr	:= 0

	cFilter := FilterForm(oJson) 

	If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0

		aAdd(aCab,"5" + STR0077 ) //5 dias
		aAdd(aCab,"10 " + STR0077 ) // 10 dias 
		aAdd(aCab,"20 " + STR0077  + " " + STR0101 ) // 20 dias ou mais

		aAdd(aData, RetDiasCol(0,5) )
		aAdd(aData, RetDiasCol(6,10) )
		aAdd(aData, RetDiasCol(11,0) )
	
		For nX := 1 To Len(aData)
			nAuxClr++
			oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nX + nAuxClr][3] /*"cColorBackground"*/ )
		Next  

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({STR0003},,/*lCurrency*/.F.,, STR0003  ))// "Sol. coletas pendentes"
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
Static Function QueryDT5(cSelect as Char, cFilter as Char)

	Local cQuery  := ""
	Local cWhere  := ""
	Local cGroup  := ""

	Default cSelect := "DT5_FILORI, DT5_NUMSOL, DT5_DATSOL, DT5_CODSOL, DUE.DUE_NREDUZ  , DT5_NUMCOT, DT5_STATUS   "
	Default cFilter := ""

	cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("DT5") + " DT5 "
    cQuery  += " INNER JOIN " + RetSqlName("DUE") + " DUE "
    cQuery  += " ON DUE_FILIAL      = '" + xFilial("DUE") + "' "
    cQuery  += " AND DUE_CODSOL     = DT5.DT5_CODSOL "
    cQuery  += " AND DUE.D_E_L_E_T_ = '' "

	cWhere := " DT5_FILIAL = '" + xFilial("DT5") + "' "
	
	If !Empty(cFilter)
		cWhere += cFilter
	Endif

	cWhere += " AND DT5.D_E_L_E_T_ = ' ' "
	
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

	cFilter  += " AND DT5_STATUS IN ('1','6') "
	cFilter	+= " AND DT5_FILORI = '" + cFilAnt + "' "

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
Static Function RetDiasCol( nDiasDe , nDiasAte ) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default nDiasDe     := 0 
Default nDiasAte    := 0 

cQuery  := " SELECT COUNT(*)  CONT FROM " + RetSqlName("DT5") + " DT5 "
cQuery  += " WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
cQuery  += " AND DT5_STATUS IN ('1') "
cQuery	+=  "AND DT5_FILORI	= '" + cFIlAnt + "' "
If nDiasAte > 0 
    cQuery  += " AND DT5_DATSOL  BETWEEN '" + DToS(dDataBase  - nDiasAte ) + "' AND '" + DToS( dDataBase - nDiasDe ) + "' "
Else 
    cQuery  += " AND DT5_DATSOL <= '"+ DToS( dDataBase - nDiasDe ) + "' "
EndIf 
cQuery  += " AND DT5.D_E_L_E_T_ = ' ' "

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
    cMes    := STR0050 //"MAR�O"
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



