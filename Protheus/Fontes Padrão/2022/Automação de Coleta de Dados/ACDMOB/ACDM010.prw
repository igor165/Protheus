#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'protheus.ch'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "ACDM010.ch"



//------------------------------------------------------------------------------
/*/{Protheus.doc} ACDMOB

Classe responsável por retornar uma Listagem de Documentos para conferencia

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSRESTFUL ACDMOB DESCRIPTION "Retorna uma lista de Documentos para conferencia"

WSDATA SearchKey 		AS STRING	OPTIONAL
WSDATA Status			AS STRING  	OPTIONAL
WSDATA Page				AS INTEGER	OPTIONAL
WSDATA PageSize			AS INTEGER	OPTIONAL
WSDATA Code				AS STRING	OPTIONAL

WSDATA Sku				AS STRING	OPTIONAL
WSDATA Warehouse		AS STRING	OPTIONAL
WSDATA Document			AS STRING	OPTIONAL
WSDATA Serie			AS STRING	OPTIONAL
WSDATA Sequence			AS STRING	OPTIONAL
WSDATA Supplier			AS STRING	OPTIONAL
WSDATA Store			AS STRING	OPTIONAL


/*------------------------GETs--------------------------------------------*/

/*-------------------Get Conferência--------------------------------------*/
WSMETHOD GET;
DESCRIPTION "Retorna uma lista de Documentos para conferencia";
WSSYNTAX "CHECKINGS/{SearchKey, Status, Page, PageSize}";
PATH "checkings"       PRODUCES APPLICATION_JSON

WSMETHOD GET  Code;
DESCRIPTION "Retorna uma  Documento para conferencia";
WSSYNTAX "CHECKINGS/{Code}";
PATH "checkings/{code}"       PRODUCES APPLICATION_JSON

/*-------------------Get Separação--------------------------------------*/
WSMETHOD GET  Separations;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "separations/{SearchKey, Status, Page, PageSize}";
PATH "separations"       PRODUCES APPLICATION_JSON


/*-------------------Get Separação--------------------------------------
WSMETHOD GET  oneSeparations;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "oneseparations/{SearchKey, Status, Page, PageSize}";
PATH "oneseparations"       PRODUCES APPLICATION_JSON */

/*-------------------Get Inventario--------------------------------------*/
WSMETHOD GET  inventories;
DESCRIPTION "Retorna uma lista de Documentos para inventario";
WSSYNTAX "inventories/{SearchKey, Status, Page, PageSize}";
PATH "inventories"       PRODUCES APPLICATION_JSON


WSMETHOD GET  Code_inventories ;
DESCRIPTION "Retorna uma lista de Documentos para inventario";
WSSYNTAX "inventories/{Code}";
PATH "inventories/{code}"       PRODUCES APPLICATION_JSON


/*-------------------Gets Transferencia--------------------------------------*/

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  Products;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}";
PATH "products"       PRODUCES APPLICATION_JSON

/*-------------------Get Armazens--------------------------------------*/
WSMETHOD GET  Warehouse;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "warehouse/{SearchKey, Status, Page, PageSize}";
PATH "warehouse"       PRODUCES APPLICATION_JSON

/*-------------------Get Endereços--------------------------------------*/
WSMETHOD GET  Address;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "address/{SearchKey, Status, Page, PageSize}";
PATH "address"       PRODUCES APPLICATION_JSON


/*-------------------Gets Endereçamento--------------------------------------*/

/*-------------------Get Produtos a Endereçar--------------------------------*/
WSMETHOD GET toAddressDetail;
DESCRIPTION "Retorna uma lista de produtos a endereçar";
WSSYNTAX "toAddressDetail/{SearchKey, Page, PageSize, Sku, Warehouse, Document, Serie, Sequence, Supplier, Store}";
PATH "toAddressDetail"       PRODUCES APPLICATION_JSON

/*-------------------Get Produtos a Endereçar--------------------------------*/
WSMETHOD GET docToAddr;
DESCRIPTION "Retorna uma lista de documentos a endereçar";
WSSYNTAX "docToAddr/{SearchKey, Page, PageSize}";
PATH "docToAddr"       PRODUCES APPLICATION_JSON


/*------------------------PUTs--------------------------------------------*/

/*-------------------Put Conferência--------------------------------------*/
WSMETHOD PUT;
DESCRIPTION "Atualiza o Status da conferência no Protheus.";
WSSYNTAX "CHECKINGS/{Code}";
PATH "checkings/{code}"   PRODUCES APPLICATION_JSON

/*-------------------Put Separação--------------------------------------*/
WSMETHOD PUT Separations;
DESCRIPTION "Atualiza o Status da separação no Protheus.";
WSSYNTAX "SEPARATIONS/{Code}";
PATH "separations/{Code}"   PRODUCES APPLICATION_JSON

/*-------------------Put Separação--------------------------------------
WSMETHOD PUT oneSeparations;
DESCRIPTION "Atualiza o Status da separação no Protheus.";
WSSYNTAX "ONESEPARATIONS/{Code}";
PATH "oneseparations/{Code}"   PRODUCES APPLICATION_JSON */

/*-------------------Put Inventario--------------------------------------*/
WSMETHOD PUT inventories;
DESCRIPTION "Atualiza o Status do inventario no Protheus.";
WSSYNTAX "inventories/{Code}";
PATH "inventories/{Code}"   PRODUCES APPLICATION_JSON

/*------------------------POSTs--------------------------------------------*/
/*-------------------POST transferencia--------------------------------------*/
WSMETHOD POST transfer;
DESCRIPTION "Finaliza a transferencia do produto no Protheus.";
WSSYNTAX "transfer";
PATH "transfer"   PRODUCES APPLICATION_JSON

/*-------------------POST endereçamento --------------------------------------*/
WSMETHOD POST ToAddress ; 
    DESCRIPTION "Inclusao de enderecamento de produto." ;
    WSSYNTAX "toAddress" ;
    PATH "toAddress" PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de Documentos para conferencia.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cType				:= '1'
Local cCodOpe   		:= CBRetOpe()
Local oJCheck 			:= JsonObject():New()
Local aJCheck		  	:= {}
Local lHasNext			:= .F.
Local cFilOld			:= cFilant
Local cTpConf           := ''

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA CONFERENCIA ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0002 //'Usuario nao cadastrado como conferente'
	 lRet			   := .F.
EndIf
If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetCheck(1,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

			cTpConf := SuperGetMv("MV_TPCONFF", .F., "1")

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 10
				Self:PageSize := 10
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJCheck 			:=  JsonObject():New()

	        While (cAlias)->(!EOF())

				// Conferencia por pre-nota exibir somente notas nao classificadas
				If ((cAlias)->TPCOF == "1" .Or. ((cAlias)->TPCOF == "0" .And. cTpConf == "1")) .And. !Empty((cAlias)->STATUS)
					(cAlias)->(DbSkip())
					Loop
				EndIf

	            nCount++

	            If (nCount >= nStart)

	                nEntJson++
	                 cType := If ( (cAlias)->TPCOF <> '0' , (cAlias)->TPCOF, cTpConf )

	                aAdd( aJCheck,  JsonObject():New() )
	                aJCheck[nEntJson]["code"			]	:= AllTrim( (cAlias)->CODE   				)
					aJCheck[nEntJson]["type"			]	:= cType
					aJCheck[nEntJson]["number"			]	:= AllTrim( (cAlias)->DOC    				)
	                aJCheck[nEntJson]["supplier_name"	]	:= EncodeUTF8(  AllTrim( (cAlias)->NAME 	) )
	                aJCheck[nEntJson]["danfe"			]	:= AllTrim( (cAlias)->DANFE      			)
	                aJCheck[nEntJson]["status"			]	:= '0'



	                If nEntJson < Self:PageSize .And. nCount < nRecord
	                    //cResponse += ', '
	                Else
	                    Exit
	                EndIf

	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

	            (cAlias)->(DbSkip())
	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord
	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJCheck 				:=  JsonObject():New()
	    	oJCheck["checkings"]	:= aJCheck
	    	oJCheck["hasNext"] 		:= lHasNext

	    Endif

	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif


If lRet
	oJCheck["checkings"]	:= aJCheck
	oJCheck["hasNext"] 	:= lHasNext
	cResponse := FwJsonSerialize( oJCheck )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJCheck) == "O"
	FreeObj(oJCheck)
	oJCheck := Nil
Endif


Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetCheck()
Constroi um Query com a Seleção de dados para conferencias

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetCheck(nGet,cSearch,cStatus,cAliasQry,cCode )

Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cWhere		:= "% "
Local cSelect		:= "% ,F1_DOC " +  cConcat + " F1_SERIE " +  cConcat + " F1_FORNECE " +  cConcat + " F1_LOJA  CODE %"

Default cSearch     := ''
Default cStatus   	:= '1'
Default cCode	  	:= ' '

If nGet == 1

	If 	Len(alltrim(cSearch))== 1
		If alltrim(cSearch) == "'"
			cSearch     := '"'
		Endif
	Else
		cSearch := REPLACE(cSearch,"'","")
	Endif
	cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))
	If !Empty(cSearch)
	    cWhere  += " AND ( F1_DOC LIKE '%"  + cSearch + "%' OR"
	    cWhere  += "  F1_CHVNFE  LIKE '%"  	+ cSearch + "%' OR"
	    cWhere  += "  A2_COD    LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  A2_NOME	LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  A2_CGC    LIKE '%"   	+ cSearch + "%')
	EndIf
	cWhere  += " %"

	BeginSQL Alias cAliasQry

	SELECT F1_DOC DOC, F1_STATUS STATUS, F1_CHVNFE DANFE, A2_NOME NAME, A2_CONFFIS TPCOF
	%EXP:cSelect%
	FROM
		%Table:SF1% SF1
		INNER JOIN %Table:SA2% SA2
			On SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SF1.F1_FORNECE
			AND SA2.A2_LOJA = SF1.F1_LOJA
			AND SA2.%NotDel%
	WHERE
		SF1.F1_FILIAL = %xFilial:SF1%
		AND SF1.F1_STATCON	= '0'
		AND SF1.%NotDel%
		%EXP:cWhere%
	EndSQL

Else

	cWhere += " AND F1_DOC " +  cConcat + " F1_SERIE " +  cConcat + " F1_FORNECE " +  cConcat + " F1_LOJA  = '" +  cCode + "' %"

	BeginSQL Alias cAliasQry

	SELECT F1_DOC DOC,F1_CHVNFE DANFE, A2_NOME NAME, A2_CONFFIS TPCOF,CBE_NOTA NOTA, CBE_CODPRO CODPRO
	FROM
		%Table:SF1% SF1
		INNER JOIN %Table:SA2% SA2
			On SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SF1.F1_FORNECE
			AND SA2.A2_LOJA = SF1.F1_LOJA
			AND SA2.%NotDel%
		LEFT JOIN %Table:CBE% CBE On
			CBE.CBE_FILIAL = SF1.F1_FILIAL
			AND	CBE.CBE_NOTA = SF1.F1_DOC
			AND	CBE.CBE_SERIE = SF1.F1_SERIE
			AND	CBE.CBE_FORNEC = SF1.F1_FORNECE
			AND	CBE.CBE_LOJA = SF1.F1_LOJA
			AND CBE.%NotDel%
	WHERE
		SF1.F1_FILIAL = %xFilial:SF1%
		AND SF1.%NotDel%
		%EXP:cWhere%
	EndSQL

EndIf


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT / ACDMOB
 Altera o Status da conferencia ou finaliza no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE ACDMOB
Local oJChecking	:= Nil
Local nStatusCode   := 500
Local nDocItem		:= 0
Local cMessage		:= STR0001 //'Erro Interno'
Local cResponse 	:= ""
Local cBody			:= ""
Local cAliasDoc		:= CriaTrab(Nil,.F.)
Local nX			:= 0
Local lRet			:= .T.
Local cNota     	:= ""
Local cSerie    	:= ""
Local cFornec   	:= ""
Local cLoja     	:= ""
Local cType			:= '1'
Local cCodOpe   	:= CBRetOpe()
Local oJCheck 		:= JsonObject():New()
Local aJCheck	  	:= {}
Local aJCheckDoc	:= {}
Local lHasNext		:= .F.
Local cFilOld		:= cFilant
Local cLote			:= ''
Local cDtValid		:= ''


Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA CONFERENCIA ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          :=STR0002 // 'Usuario nao cadastrado como conferente'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(Upper(cBody),@oJChecking)


			If !Empty( oJChecking )
				cNota     := Substr(Self:aURLParms[2],1,TamSX3("F1_DOC")[1])
				cSerie    := Substr(Self:aURLParms[2],TamSX3("F1_DOC")[1]+1,TamSX3("F1_SERIE")[1])
				cFornec   := Substr(Self:aURLParms[2],TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+1,TamSX3("F1_FORNECE")[1])
				cLoja     := Substr(Self:aURLParms[2],TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+ 1,TamSX3("F1_LOJA")[1])

				SF1->(DbSetOrder(1))
				If SF1->( DbSeek( padr(xFilial("SF1"),TAMSX3("F1_FILIAL")[1]) + cNota + cSerie + cFornec + cLoja) ) .AND. !SF1->F1_STATCON $ "1|4" .AND. !EMPTY(SF1->F1_STATCON)
					SA2->(DbSetOrder(1))
					SA2->( DbSeek( padr(xFilial("SA2"),TAMSX3("A2_FILIAL")[1]) + cFornec + cLoja) )
					cType := If ( SA2->A2_CONFFIS <> '0' , SA2->A2_CONFFIS,SuperGetMv("MV_TPCONFF",.F.,'1') )
					If oJChecking:Status == '2'

						If AttIsMemberOf(oJChecking,"products")
							oJCheck 			:=  JsonObject():New()
							For nX := 1 To Len( oJChecking:products )
								cLote			:= ''
								cDtValid		:= CtoD("  /  /  ")
								If VALTYPE(oJChecking:products[nX]:batch) <> Nil .AND. !EMPTY(oJChecking:products[nX]:batch)
									cLote	:= oJChecking:products[nX]:batch
								EndIf
								If AttIsMemberOf(oJChecking:products[nX],"batchDate")
									If VALTYPE(oJChecking:products[nX]:batchDate) <> Nil .And. !EMPTY(oJChecking:products[nX]:batchDate)
										cDtValid := CtoD(oJChecking:products[nX]:batchDate)
									EndIf
								EndIf
								lRet:= GrvCBE(oJChecking:Status,Space(10),cNota,cSerie,cFornec,cLoja,oJChecking:products[nX]:code,;
								             oJChecking:products[nX]:quantity,cLote,cDtValid,@cMessage,@nStatusCode,cCodOpe)//

								If !lRet
									Exit
								Endif

							Next nX

							If lRet
								//aAdd( aJCheck,  JsonObject():New() )
					            oJCheck["code"			]	:= Alltrim(Self:aURLParms[2]   				)
								oJCheck["type"			]	:= cType
								oJCheck["number"		]	:= cNota
					            oJCheck["supplier_name"	]	:= EncodeUTF8(  AllTrim(SA2->A2_NOME  	) )
					            oJCheck["danfe"			]	:= Alltrim(SF1->F1_CHVNFE     			)
					            oJCheck["status"		]	:= '2'

				            Endif
				        Else
				        	lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0014 //"Dados da conferencia nao enviados..."
						Endif

					Else

						RecLock("SF1",.F.)
						SF1->F1_STATCON := "3"
						SF1->(MsUnlock())

					    oJCheck["code"			]	:= Alltrim(Self:aURLParms[2]   				)
						oJCheck["type"			]	:= cType
						oJCheck["number"		]	:= cNota
						oJCheck["supplier_name"	]	:= EncodeUTF8(  AllTrim(SA2->A2_NOME  	) )
					    oJCheck["danfe"			]	:= Alltrim(SF1->F1_CHVNFE     			)
					    oJCheck["status"		]	:= '1'

					    GetItNota(@cAliasDoc)
						While (cAliasDoc)->(!EOF())
							nDocItem++
							aAdd( aJCheckDoc,  JsonObject():New() )
							aJCheckDoc[nDocItem]["item"				]	:= (cAliasDoc)->D1_ITEM
							aJCheckDoc[nDocItem]["product"			]	:= (cAliasDoc)->D1_COD
							aJCheckDoc[nDocItem]["barcode"			]	:= (cAliasDoc)->B1_CODBAR
							aJCheckDoc[nDocItem]["quantity"			]	:= (cAliasDoc)->D1_QUANT
							aJCheckDoc[nDocItem]["batch"			]	:= (cAliasDoc)->D1_LOTECTL
							aJCheckDoc[nDocItem]["batchDate"		]	:= (cAliasDoc)->D1_DTVALID

							(cAliasDoc)->(DbSkip())
						End
						 oJCheck["itensDoc"] := aJCheckDoc
						 aJCheckDoc := {}
						If Select(cAliasDoc) > 0
							(cAliasDoc)->(dbCloseArea())
						EndIf

					Endif
				Else
					lRet 		:= .F.
					nStatusCode	:= 404
					cMessage 	:= STR0004 //"Conferencia nao encontrada..."
				Endif
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf



If lRet
	cResponse := FwJsonSerialize( oJCheck )
    Self:SetResponse(cResponse)
    If oJChecking:Status == '2'
		StatusSF1(cNota,cSerie,cFornec,cLoja)
	Endif
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
    Self:SetResponse( cMessage )
EndIf
If ValType(oJCheck) == "O"
	FreeObj(oJCheck)
	oJCheck := Nil
Endif


Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCBE
 Função que grava a tabela CBE
@param	Code, array com dados para mudança do status

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvCBE(cStatus,cID,cNota,cSerie,cFornec,cLoja,cProduto,nQtde,cLote,dValid,cMessage,nStatusCode,cCodOpe)

Local lRet		  := .T.
Local lDiverg	  := .F.
Local lPesqSA5    := SuperGetMv("MV_CBSA5",.F.,.F.)
Local cAliasB1	  := GetnextAlias()
Local aProd		  := {}

Static aCB0  	  := {}

Default cProduto  := ''
Default nQtde 	  := 0
Default cLote 	  := ''
Default dValid 	  := CtoD("  /  /  ")

If !Empty(cLote) .And. Empty(dValid)

	aProd := CBRetEtiEan(cProduto)

	If Len(aProd) > 0
		dValid := aProd[4]
	EndIf

EndIf

If cStatus = '2'
	CBE->(DbSetOrder(1))
	cID := Padr(cID,10)
	If	CBE->(DBSeek(padr(xFilial("CBE"),TAMSX3("CBE_FILIAL")[1])+cID+cNota+cSerie+cFornec+cLoja+cProduto+cLote))
		If ! UsaCB0("01")
			RecLock("CBE",.f.)
			CBE->CBE_CODUSR	:= cCodOpe
			CBE->CBE_DATA	:= dDatabase
			CBE->CBE_HORA	:= Time()
			CBE->CBE_QTDE   += nQtde
			CBE->(MsUnLock())
		EndIf
	Else
		lDiverg	:= .F.

		BeginSQL Alias cAliasB1

		SELECT B1_COD, B1_PRVALID
		FROM
			%Table:SB1% SB1
		WHERE
			SB1.B1_FILIAL = %xFilial:SB1%
			AND (SB1.B1_CODBAR	= %Exp:cProduto% OR SB1.B1_COD	= %Exp:cProduto%)
			AND SB1.B1_MSBLQL  <> '1' AND SB1.%NotDel%
		EndSQL

		If (cAliasB1)->(!EOF())
			cProduto := (cAliasB1)->B1_COD

			If !Empty(cLote) .And. Empty(dValid)
				dValid := dDataBase + (cAliasB1)->B1_PRVALID
			EndIf

		Else
			SA5->(dbSetorder(8)) //A5_CODBAR
			If lPesqSA5 .and. SA5->(dbSeek(padr(xFilial("SA5"),TAMSX3("A5_FILIAL")[1])+cFornec+cLoja+Padr(AllTrim(cProduto),TamSX3("A5_CODBAR")[1])))
				cProduto := SA5->A5_PRODUTO
				SB1->(DbSetOrder(1))
				If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
					lDiverg	:= .T.
				Else
					If !Empty(cLote) .And. Empty(dValid)
						dValid := dDataBase + SB1->B1_PRVALID
					EndIf
				Endif
			Else
				SLK->( dbSetOrder(1) )
				If SLK->( DBSeek(padr(xFilial("SLK"),TAMSX3("LK_FILIAL")[1])+cProduto) )
					cProduto := SLK->LK_CODIGO
					If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
						lDiverg	:= .T.
					Else
						If !Empty(cLote) .And. Empty(dValid)
							dValid := dDataBase + SB1->B1_PRVALID
						EndIf
					Endif
				Else
					lDiverg	:= .T.
				Endif
			Endif

		Endif
		If !lDiverg
			RecLock("CBE",.t.)
			CBE->CBE_FILIAL	:= xFilial("CBE")
			CBE->CBE_NOTA	:= cNota
			CBE->CBE_SERIE	:= cSerie    //SerieNfId("CBE",1,"CBE_SERIE",,,cSerie)
			CBE->CBE_FORNEC	:= cFornec
			CBE->CBE_LOJA	:= cLoja
			CBE->CBE_CODPRO	:= cProduto
			CBE->CBE_QTDE	:= nQtde
			CBE->CBE_LOTECT	:= cLote
			CBE->CBE_CODUSR	:= cCodOpe
			CBE->CBE_DTVLD	:= dValid
			CBE->CBE_CODETI	:= cID
			CBE->CBE_DATA	:= dDatabase
			CBE->CBE_HORA	:= Time()
			CBE->(MsUnLock())

			DistQtdConf(cProduto,nQtde,,cLote,dValid,cNota,cSerie,cFornec,cLoja)

			If Usacb0("01")
				aAdd(aCB0,CB0->CB0_CODETI) //-- Codigo da Etiqueta
				CBGrvEti("01",{,nQtde,cCodOpe,cNota,cSerie,cFornec,cLoja,NIL,NIL,NIL,NIL,NIL,,,,cLote,NIL,dValid},cID)
			EndIf
		Else
			D3V->(DbSetOrder(2))
			If	!D3V->(DBSeek(padr(xFilial("D3V"),TAMSX3("D3V_FILIAL")[1])+'1'+ cNota+cSerie+cFornec+cLoja+cProduto+cLote))
				// Grava a tabela de divergencia
				RecLock("D3V",.t.)
				D3V->D3V_FILIAL	:= xFilial("D3V")
				D3V->D3V_CODIGO	:= GetSXENum("D3V", "D3V_CODIGO")
				D3V->D3V_ORIGEM	:= '1'
				D3V->D3V_MOTIVO	:= '1'
				D3V->D3V_NOTA	:= cNota
				D3V->D3V_SERIE	:= cSerie  // SerieNfId("D3V",1,"D3V_SERIE",,,cSerie)
				D3V->D3V_FORNEC	:= cFornec
				D3V->D3V_LOJA	:= cLoja
				D3V->D3V_CODPRO	:= cProduto
				D3V->D3V_QTDE	:= nQtde
				D3V->D3V_LOTECT	:= cLote
				D3V->D3V_CODUSR	:= cCodOpe
				D3V->D3V_DTVLD	:= dValid
				D3V->D3V_CODETI	:= cID
				D3V->D3V_DATA	:= dDatabase
				D3V->D3V_HORA	:= Time()
				D3V->D3V_STATUS	:= '1'
				D3V->(MsUnLock())
				ConfirmSx8()
			Endif

		Endif
	EndIf
Endif

If Select(cAliasB1) > 0
	(cAliasB1)->(dbCloseArea())
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados do codigo informado

@param  Code    , caracter, Codigo para Pesquisa.


@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		15/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  Code WSRECEIVE Code WSSERVICE ACDMOB


Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local cType				:= '1'
Local cCodOpe   		:= CBRetOpe()
Local cStatus			:= ''
Local cFilOld			:= cFilant

Default Self:Code  := ''


Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA CONFERENCIA ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif
If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0002 //'Usuario nao cadastrado como conferente'
	 lRet			   := .F.
EndIf
If lRet
   GetCheck(2,,,cAlias,Self:Code )
    If (cAlias)->(!EOF())

        cType 	:= If ( (cAlias)->TPCOF <> '0' , (cAlias)->TPCOF,SuperGetMv("MV_TPCONFF",.F.,1) )
        If Empty((cAlias)->NOTA ) .AND. Empty((cAlias)->CODPRO )
        	cStatus	:= '0'
        ElseIf	!Empty((cAlias)->NOTA) .AND. Empty((cAlias)->CODPRO)
        	cStatus	:= '2'
        Else
        	cStatus	:= '1'
        Endif
        cResponse += '{'
        cResponse +=    '"code":"'   		+ AllTrim( Self:Code		   				)      + '",'
        cResponse +=    '"type":"' 			+ cType											   + '",'
        cResponse +=    '"number":"'   		+ AllTrim( (cAlias)->DOC      )    				   + '",'
        cResponse +=    '"supplier_name":"' + EncodeUTF8(  AllTrim( (cAlias)->NAME 		) )    + '",'
        cResponse +=    '"danfe":"'   		+ AllTrim( (cAlias)->DANFE      			)	   + '",'
        cResponse +=    '"status":"' 		+ cStatus     							       	   + '"'
        cResponse += '}'

    Else
       nStatusCode      := 404
       cMessage         :=STR0004 // "Conferencia nao encontrada"
       lRet			   	:= .F.
    EndIf

Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSep()
Constroi um Query com a Seleção de dados para separação

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetSep(nMet,cSearch,cStatus,cAliasQry,cSep )

Local cFilterSA1    := ''
Local cFilterSUS    := ''
Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cWhere		:= "% "
Local oStatement 	:= Nil
Default cSearch     := ''
Default cStatus   	:= '1'
Default cSep   		:= ''

If nMet == 1

	If 	Len(alltrim(cSearch))== 1
		If alltrim(cSearch) == "'"
			cSearch     := '"'
		Endif
	Else
		cSearch := REPLACE(cSearch,"'","")
	Endif
	cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))

	If !Empty(cSearch)
		cWhere  += " AND ( CB7_ORDSEP  LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  CB7_PEDIDO    LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  A1_NOME		LIKE '%"   	+ cSearch + "%')


	EndIf
	cWhere  += " %"

	BeginSQL Alias cAliasQry

	SELECT DISTINCT(CB7_ORDSEP) ORDEM,CB7_STATUS STATUS,CB7_TIPEXP TPSEP,CB7_ORIGEM ORIGEM, A1_NOME NAME, SC5.C5_NUM PEDIDO
	FROM
		%Table:CB7% CB7
		INNER JOIN %Table:CB8% CB8 On
			CB8.CB8_FILIAL = CB7.CB7_FILIAL
			AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP
			AND CB8.%NotDel%
		LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
		LEFT JOIN %Table:SA1% SA1 On
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENTE
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%NotDel%
		INNER JOIN %Table:SB1% SB1 On
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = CB8.CB8_PROD
			AND SB1.B1_MSBLQL <> '1'
			AND SB1.%NotDel%
	WHERE
		CB7.CB7_FILIAL = %xFilial:CB7%
		AND CB7.CB7_STATUS	= '0'
		AND CB7.%NotDel%
		%EXP:cWhere%
	ORDER BY CB7_ORDSEP
	EndSQL

ElseIf nMet == 2
	cWhere += " AND CB7_ORDSEP  = '" +  cSep + "' "
	cWhere  += " %"

	BeginSQL Alias cAliasQry

	SELECT CB7_ORDSEP ORDEM,CB7_STATUS STATUS,CB7_TIPEXP TPSEP,CB7_ORIGEM ORIGEM, A1_NOME NAME,
			CB8_PROD PROD, CB8_ITEM ITEM, CB8_SEQUEN SEQ, CB8_QTDORI QUANT, CB8_LOCAL ARMAZEM,CB8_LCALIZ ADRESS, CB8_NUMSER SERIALNO ,CB8_LOTECT LOTE, CB8_NUMLOT SUBLOT ,CB8_PEDIDO PEDIDO, CB8_NOTA NOTA,
			B1_DESC PRODNAME,B1_CODBAR CODBAR
	FROM
		%Table:CB7% CB7
		INNER JOIN %Table:CB8% CB8 On
			CB8.CB8_FILIAL = CB7.CB7_FILIAL
			AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP
			AND CB8.%NotDel%
		LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
		LEFT JOIN %Table:SA1% SA1 On
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENTE
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%NotDel%
		INNER JOIN %Table:SB1% SB1 On
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = CB8.CB8_PROD
			SB1.B1_MSBLQL  <> '1'
			AND SB1.%NotDel%
	WHERE
		CB7.CB7_FILIAL = %xFilial:CB7%
		AND CB7.CB7_STATUS	= '1'
		AND CB7.%NotDel%
		%EXP:cWhere%
	EndSQL
ElseIf nMet == 3
	If 	Len(alltrim(cSearch))== 1
		If alltrim(cSearch) == "'"
			cSearch     := '"'
		Endif
	Else
		cSearch := REPLACE(cSearch,"'","")
	Endif
	cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))

	If !Empty(cSearch)
		cWhere  += " AND ( CB7_ORDSEP  LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  CB8_PEDIDO     LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  CB8_OP     	 LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  CB8_NOTA	     LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  B1_COD	     LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  B1_DESC	     LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  F2_CHVNFE  	 LIKE '%"  		+ cSearch + "%' OR"
	    cWhere  += "  A1_NOME		 LIKE '%"   	+ cSearch + "%')

	EndIf
	cWhere  += " %"

	cSelect		:= "% (CASE WHEN CB7_ORIGEM = '1'THEN CB8_PEDIDO ELSE (CASE WHEN CB7_ORIGEM = '2' THEN "
	cSelect		+= " CB8_NOTA " +  cConcat + " CB8_SERIE ELSE CB8_OP END)END) DOC %"

	BeginSQL Alias cAliasQry

	SELECT DISTINCT(CB7_ORDSEP) ORDEM,CB7_STATUS STATUS,CB7_TIPEXP TPSEP,CB7_ORIGEM ORIGEM,
	CB8_PROD,CB8_ITEM,CB8_PEDIDO PEDIDO,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_NUMSER,CB8_LOTECT,CB8_NUMLOT,CB8_QTDORI,A1_NOME NOME, B1_DESC DESCRI, B1_CODBAR CODBAR,
	%EXP:cSelect%
	FROM
		%Table:CB7% CB7
	INNER JOIN %Table:CB8% CB8 ON
			CB8.CB8_FILIAL = CB7.CB7_FILIAL
			AND CB8.CB8_ORDSEP	= CB7.CB7_ORDSEP
			AND CB8.%NotDel%
	LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
	LEFT JOIN %Table:SA1% SA1 On
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENTE
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%NotDel%
	LEFT JOIN %Table:SF2% SF2 On
			SF2.F2_FILIAL = %xFilial:SF2%
			AND SF2.F2_DOC 		= CB8.CB8_NOTA
			AND SF2.F2_SERIE 	= CB8.CB8_SERIE
			AND SF2.F2_CLIENTE 	= SC5.C5_CLIENTE
			AND SF2.F2_LOJA 	= SC5.C5_LOJACLI
			AND SF2.%NotDel%
	INNER JOIN %Table:SB1% SB1 On
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = CB8.CB8_PROD
			AND SB1.B1_MSBLQL <> '1'
			AND SB1.%NotDel%
	WHERE
		CB7.CB7_FILIAL = %xFilial:CB7%
		AND CB7.CB7_STATUS	= '0'
		AND CB7.%NotDel%
		%EXP:cWhere%
	ORDER BY CB7_ORDSEP,DOC
	EndSQL
Else


	cWhere += " AND CB7_ORDSEP  = '" +  cSep + "' "
	cWhere  += " %"


	cSelect		:= "% (CASE WHEN CB7_ORIGEM = '1'THEN CB8_PEDIDO ELSE (CASE WHEN CB7_ORIGEM = '2' THEN "
	cSelect		+= " CB8_NOTA " +  cConcat + " CB8_SERIE ELSE CB8_OP END)END) DOC %"

	BeginSQL Alias cAliasQry

	SELECT DISTINCT(CB7_ORDSEP) ORDEM,CB7_STATUS STATUS,CB7_TIPEXP TPSEP,CB7_ORIGEM ORIGEM,
	CB8_PROD,CB8_ITEM,CB8_PEDIDO PEDIDO,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_NUMSER,CB8_LOTECT,CB8_NUMLOT,CB8_QTDORI,A1_NOME NOME, B1_DESC DESCRI, B1_CODBAR CODBAR,
	%EXP:cSelect%
	FROM
		%Table:CB7% CB7
	INNER JOIN %Table:CB8% CB8 ON
			CB8.CB8_FILIAL = CB7.CB7_FILIAL
			AND CB8.CB8_ORDSEP	= CB7.CB7_ORDSEP
			AND CB8.%NotDel%
	LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
	LEFT JOIN %Table:SA1% SA1 On
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENTE
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%NotDel%
	LEFT JOIN %Table:SF2% SF2 On
			SF2.F2_FILIAL = %xFilial:SF2%
			AND SF2.F2_DOC 		= CB8.CB8_NOTA
			AND SF2.F2_SERIE 	= CB8.CB8_SERIE
			AND SF2.F2_CLIENTE 	= SC5.C5_CLIENTE
			AND SF2.F2_LOJA 	= SC5.C5_LOJACLI
			AND SF2.%NotDel%
	INNER JOIN %Table:SB1% SB1 On
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = CB8.CB8_PROD
			AND SB1.B1_MSBLQL  <> '1'
			AND SB1.%NotDel%
	WHERE
		CB7.CB7_FILIAL = %xFilial:CB7%
		AND CB7.CB7_STATUS	= '0'
		AND CB7.%NotDel%
		%EXP:cWhere%
	ORDER BY CB7_ORDSEP,DOC
	EndSQL

Endif

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCB9
 Função que grava a tabela CB9
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvCB9(cItem,cSeq,cProd,nQtde,cCodSep,cStatus,cCodOpe,nStatusCode,cMessage)

Local lRet := .T.

CB8->(DbSetOrder(1))
If CB8->(DbSeek(padr(xFilial("CB8"),TAMSX3("CB8_FILIAL")[1])+ cCodSep + cItem+cSeq+cProd ))



	CB9->(DbSetOrder(10))
	If CB9->(DbSeek(padr(xFilial("CB9"),TAMSX3("CB9_FILIAL")[1])+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT)))
		reclock("CB9",.F.)
		CB9->(dbDelete())
		CB9->(msUnlock())
	Endif
	RecLock("CB9",.T.)
	CB9->CB9_FILIAL := xFilial("CB9")
	CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
	CB9->CB9_CODETI := ''
	CB9->CB9_PROD   := CB8->CB8_PROD
	CB9->CB9_CODSEP := cCodOpe
	CB9->CB9_ITESEP := CB8->CB8_ITEM
	CB9->CB9_SEQUEN := CB8->CB8_SEQUEN
	CB9->CB9_LOCAL  := CB8->CB8_LOCAL
	CB9->CB9_LCALIZ := CB8->CB8_LCALIZ
	CB9->CB9_LOTECT := CB8->CB8_LOTECT
	CB9->CB9_NUMLOT := CB8->CB8_NUMLOT
	CB9->CB9_NUMSER := CB8->CB8_NUMSER
	CB9->CB9_LOTSUG := CB8->CB8_LOTECT
	CB9->CB9_SLOTSU := CB8->CB8_NUMLOT
	CB9->CB9_NSERSU := CB8->CB8_NUMSER
	CB9->CB9_PEDIDO := CB8->CB8_PEDIDO
	CB9->CB9_QTESEP += nQtde
	CB9->CB9_STATUS := cStatus // separado
	CB9->(MsUnlock())

Else
	lRet := .F.
	nStatusCode	:= 404
	cMessage 	:= STR0018 //"Item da separacao nao encontrada..."
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de Documentos para inventario.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com os inventarios pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET inventories WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonInv 			:= JsonObject():New()
Local aJsonInv		  	:= {}
Local aJProdInv			:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local nX				:= 0
Local aProdInv			:= {}
Local nSaldo			:= 0
Local cFilOld			:= cFilant

Default Self:SearchKey  	:= ''
Default Self:Status			:= '1'
Default Self:Page       	:= 1
Default Self:PageSize   	:= 20

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO No INVENTARIO ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif
If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventário'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))

	    GetInv(1,UPPER(Self:SearchKey),Self:Status,cAlias,,cCodOpe,@nStatusCode,@cMessage )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 10
				Self:PageSize := 10
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonInv 			:=  JsonObject():New()


	        While (cAlias)->(!EOF())
	            nCount++


	            If (nCount >= nStart)

	                nEntJson++
	                aAdd( aJsonInv,  JsonObject():New() )
	                aJsonInv[nEntJson]["code"			]	:= Padr((cAlias)->CODINV,TamSX3("CBA_CODINV")[1]) + (cAlias)->NUM
	                aJsonInv[nEntJson]["inventorydate"	]	:= (cAlias)->DTMESTRE
					aJsonInv[nEntJson]["type"			]	:= AllTrim( (cAlias)->TIPINV 				)
					aJsonInv[nEntJson]["warehouse"		]	:= EncodeUTF8(AllTrim(Posicione("NNR",1,padr(xFilial("NNR"),TamSX3("NNR_FILIAL")[1])+AllTrim( (cAlias)->ARMAZEM),"NNR_DESCRI")))
	                aJsonInv[nEntJson]["address"		]	:= AllTrim( (cAlias)->LOCALIZ      			)
	                aJsonInv[nEntJson]["guided"			]	:= If(AllTrim( (cAlias)->INVGUI)== '1', 1, 0 )
	                aJsonInv[nEntJson]["recount"		]	:= If(AllTrim( (cAlias)->RECINV)== '1', 1, 0 )
					aJsonInv[nEntJson]["status"			]	:= AllTrim( (cAlias)->STATUS     		    )

	                If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf


	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				(cAlias)->(DbSkip())

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonInv 				:=  JsonObject():New()
	    	oJsonInv["inventories"]	:= aJsonInv
	    	oJsonInv["hasNext"] 	:= lHasNext

	    EndIf

	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonInv["inventories"]	:= aJsonInv
	oJsonInv["hasNext"] 	:= lHasNext
	cResponse := FwJsonSerialize( oJsonInv )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonInv) == "O"
	FreeObj(oJsonInv)
	oJsonInv := Nil
Endif

Return (lRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} PUT  inventories / ACDMOB
 Altera o Status da separacao ou finaliza no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD PUT inventories WSSERVICE ACDMOB

Local nStatusCode   := 500
Local oJInvent		:= Nil
Local cMessage		:= STR0001 //'Erro Interno'
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local cAlias        := GetnextAlias()
Local oJsonInv 		:= JsonObject():New()
Local aJProdInv		:= {}
Local aProdInv		:= {}
Local nSaldo		:= 0
Local nQtd			:= 0
Local cCode			:= ""
Local cDescription	:= ""
Local cBatch		:= ""
Local cWarehouse	:= ""
Local cStatus		:= ""
Local cStatusAnt    := ""
Local aprodend		:= {}
Local lModelo1

Local cFilOld		:= cFilant

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NO INVENTARIO ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

lModelo1 := GetMv("MV_CBINVMD")=="1"

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventario'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(Upper(cBody),@oJInvent)

			If !Empty( oJInvent )

				CBA->(DbSetOrder(1))
				If CBA->( DbSeek( PADR(xFilial("CBA"),TamSX3("CBA_FILIAL")[1]) + Substr(Self:aURLParms[2],1,TamSX3("CBA_CODINV")[1])) )

					If oJInvent:Status == '2'
						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						If CBA->CBA_STATUS $ ('0|1') .AND. CBB->CBB_STATUS <> "2"

							If AttIsMemberOf(oJInvent,"readproducts")
								oJsonInv 					:=  JsonObject():New()
								oJsonInv["code"]			:= oJInvent:Code
								oJsonInv["type"]			:= oJInvent:Type
								oJsonInv["warehouse"]		:= oJInvent:warehouse
								oJsonInv["address"]			:= oJInvent:address
								oJsonInv["guided"]			:= oJInvent:guided
								oJsonInv["recount"]			:= oJInvent:recount
								oJsonInv["status"]			:= oJInvent:status

								If lRet
									For nX := 1 To Len( oJInvent:readproducts )
										If !empty(oJInvent:readproducts[nX]:Code)
											SB1->(DbSetOrder(1))
											cCode			:= ""
											cDescription	:= ""
											If SB1->(DbSeek(PadR(xFilial("SB1"),TamSX3("B1_FILIAL")[1])+ oJInvent:readproducts[nX]:code ))
												cCode			:= SB1->B1_COD
												cDescription	:= SB1->B1_DESC
											EndIf
										Else
											SB1->(DbSetOrder(5))
											cCode			:= ""
											cDescription	:= ""
											If SB1->(DbSeek(PadR(xFilial("SB1"),TamSX3("B1_FILIAL")[1])+ oJInvent:readproducts[nX]:Barcode ))
												cCode			:= SB1->B1_COD
												cDescription	:= SB1->B1_DESC
											EndIf
										EndIf
										// verifica se o produto tem embalagem
										nQtd := AcdMobEmb(cCode,oJInvent:readproducts[nX]:Quantity)

										// pega o lote do produto
										cBatch := oJInvent:readproducts[nX]:Batch

										// pega o armazem do produto
										cWarehouse := CBA->CBA_LOCAL

										lRet := GrvInv(cCode,oJInvent:readproducts[nX]:Address,;
														oJInvent:readproducts[nX]:Batch,nQtd,;
														cCodOpe,@nStatusCode,@cMessage,oJInvent:readproducts[nX]:Barcode)

										cStatus := GetStsInv(cCode, cWarehouse, cBatch, nQtd, cStatus) //Retorna o Status do Lote

										If lRet

											aAdd( aJProdInv,  JsonObject():New() )
						                    aJProdInv[nX]["code"			]	:= cCode
						                    aJProdInv[nX]["barcode"			]	:= oJInvent:readproducts[nX]:Barcode
						                    aJProdInv[nX]["description"		]	:= EncodeUTF8(Alltrim(cDescription))
						                    aJProdInv[nX]["address"			]	:= oJInvent:readproducts[nX]:Address
						                    aJProdInv[nX]["batch"			]	:= oJInvent:readproducts[nX]:Batch
						                    aJProdInv[nX]["quantity"		]	:= nQtd

										Else
											exit
										Endif
									Next nX
								EndIf
								If lRet
									oJsonInv["products"] := aJProdInv
									aJProdInv := {}

										RecLock("CBA",.F.)
										CBA->CBA_CONTR := CBA->CBA_CONTR + 1
										If !lModelo1
											CBA->CBA_AUTREC:="2" // BLOQUEADO
											CBA->CBA_STATUS := cStatus
										else
											If CBA->CBA_CONTR < CBA->CBA_CONTS
												CBA->CBA_STATUS := '1'
											Else
												CBA->CBA_STATUS := '4'
											Endif	
										EndIf
										CBA->(MsUnlock())

										RecLock("CBB",.F.)
										CBB->CBB_STATUS := "2"
										CBB->(MsUnlock())

										AjustInv() // Ajusta inventario gravando com quantia 0 os produtos nao encontrados na contagem
								Else
									cResponse 	:= ''
								Endif
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0021 //"Dados do inventario nao enviados..."
							Endif
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0020 //"inventario ja foi finalizada..."
						Endif
					ElseIf oJInvent:Status == '1'
						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						If CBA->CBA_STATUS $ '0|1' .AND. CBB->CBB_STATUS == "0"

							cStatusAnt := CBA->CBA_STATUS

							RecLock("CBA",.F.)
							CBA->CBA_STATUS := oJInvent:Status  // Iniciando inventario
							If CBA->(ColumnPos("CBA_DISPOS")) > 0
								CBA->CBA_DISPOS := "2" // Identifica que o inventario foi selecionado pelo App, nao podendo ser conferido via coletor
							EndIf
							CBA->(MsUnlock())

							RecLock("CBB",.F.)
							CBB->CBB_USU	:= cCodOpe
							CBB->CBB_NCONT 	:=  CBB->CBB_NCONT + 1
							CBB->CBB_STATUS := "1"
							CBB->(MsUnlock())

							GetInv(2,,oJInvent:Status,cAlias,Substr(Self:aURLParms[2],1,TamSX3("CBA_CODINV")[1]) )

							While (cAlias)->(!EOF())
								oJsonInv 		:=  JsonObject():New()

								oJsonInv["code"]			:= Self:aURLParms[2]
								oJsonInv["type"]			:= AllTrim( (cAlias)->TIPINV 				)
								oJsonInv["inventorydate"]	:= (cAlias)->DTMESTRE
								oJsonInv["warehouse"]		:= EncodeUTF8(AllTrim(Posicione("NNR",1,padr(xFilial("NNR"),TamSX3("NNR_FILIAL")[1])+AllTrim( (cAlias)->ARMAZEM),"NNR_DESCRI")))
								oJsonInv["address"]			:= AllTrim( (cAlias)->LOCALIZ      			)
								oJsonInv["guided"]			:= If(AllTrim( (cAlias)->INVGUI)== '1', 1, 0 )
								oJsonInv["recount"]			:= If(AllTrim( (cAlias)->RECINV)== '1', 1, 0 )
								oJsonInv["status"]			:= oJInvent:Status

								CBLoadEst(@aProdInv,.F.)
								// Tratamento para nao duplicar os registros da tabela CBM
								If cStatusAnt == "0"
									IniciaCBM(aProdInv)
								EndIf
								SB1->(DbSetOrder(1))
								For nX := 1 to Len(aProdInv)

									SB1->(DbSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+ aProdInv[nX,1] ))

									aAdd( aJProdInv,  JsonObject():New() )
									aJProdInv[nX]["code"			]	:= AllTrim(aProdInv[nX,1])
									aJProdInv[nX]["barcode"			]	:= AllTrim(SB1->B1_CODBAR)
									aJProdInv[nX]["description"		]	:= EncodeUTF8(Alltrim(SB1->B1_DESC))
									aJProdInv[nX]["address"			]	:= AllTrim(aProdInv[nX,5])
									aJProdInv[nX]["batch"			]	:= AllTrim(aProdInv[nX,2])
									aJProdInv[nX]["unity"			]	:= SB1->B1_UM

									If AllTrim( (cAlias)->INVGUI )== '1'
										nSaldo	:= 0
										If aProdInv[nX,7] <> 0
											nSaldo := aProdInv[nX,7]
										Else
											If  AllTrim( (cAlias)->TIPINV ) == '1'
												SB2->(DbSetOrder(1))
												SB2->(DbSeek(padr(xFilial('SB2'),TAMSX3("B2_FILIAL")[1])+aProdInv[nX,1]+CBA->CBA_LOCAL))
												nSaldo := SaldoSB2(,.F.)
											Else
												nSaldo := SaldoSBF(CBA->CBA_LOCAL,aProdInv[nX,5],aProdInv[nX,1],,aProdInv[nX,2],)
											EndIf
										Endif

										aJProdInv[nX]["quantity"		]	:= nSaldo

									EndIf

								Next nX
								oJsonInv["products"] := aJProdInv
								aJProdInv := {}

								(cAlias)->(dbSkip())
							End

							If Select(cAlias) > 0
								(cAlias)->(dbCloseArea())
							Endif

						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0007 // "Inventario ja iniciada por outro contador ou finalizado..."

						EndIf
					ElseIf oJInvent:Status == '3'
						// Atualiza numero de contagens realizadas
						CBA->(DbSetOrder(1))
						CBA->(DbSeek(Padr(xFilial("CBA"),TamSX3("CBA_FILIAL")[1]) + Substr(Self:aURLParms[2],1,TamSX3("CBA_CODINV")[1])))
						RecLock("CBA",.F.)
						CBA->CBA_CONTR := CBA->CBA_CONTR + 1
						CBA->(MsUnlock())
						// Finaliza contagem
						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						RecLock("CBB",.F.)
						CBB->CBB_USU	:= cCodOpe
						CBB->CBB_NCONT 	:=  1
						CBB->CBB_STATUS := "2"
						CBB->(MsUnlock())
						// Grava contagens com quantidade zero
						AjustInv()	
					ElseIf oJInvent:Status == '9'

						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						If CBA->CBA_STATUS $ '1' .AND. CBB->CBB_STATUS == "1"
							RecLock("CBA",.F.)
							CBA->CBA_STATUS := "0"
							If CBA->(ColumnPos("CBA_DISPOS")) > 0
								CBA->CBA_DISPOS := " "	// Desfaz relacionamento do inventario com o App
							EndIf
							CBA->(MsUnlock())

							RecLock("CBB",.F.)
							CBB->CBB_USU	:= ""
							CBB->CBB_NCONT 	:=  0
							CBB->CBB_STATUS := "0"
							CBB->(MsUnlock())
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= EncodeUTF8("Não foi possível remover a seleção do inventário.")
						EndIf					
					Endif
				Else
					lRet 		:= .F.
					nStatusCode	:= 400
					cMessage 	:= STR0008  //"Inventario nao encontrado..."
				Endif
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonInv )
    Self:SetResponse( cResponse )
    If oJInvent:Status $ '2|3' .AND. CBA->CBA_CONTR >= CBA->CBA_CONTS
    	SB1->(DbSetOrder(1))
    	aiv035Fim(.T.,aprodend,.F.)
    	IF CBA->CBA_ANALIS = '2' .And. lModelo1
    		GrvCBB(CBA->CBA_CODINV,cCodOpe,@nStatusCode,@cMessage,.T.,lModelo1,.F.)
    	Endif
    EndIf
Else
	SetRestFault( nStatusCode, cMessage )
	Self:SetResponse( cMessage )
EndIf
If ValType(oJsonInv) == "O"
	FreeObj(oJsonInv)
	oJsonInv := Nil
Endif
Return( lRet )



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados do codigo informado

@param  Code    , caracter, Codigo para Pesquisa.


@return cResponse	, Array, JSON com Array

@author	 	Fernando Amorim (Cafu)
@since		15/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  Code_inventories WSRECEIVE Code WSSERVICE ACDMOB


Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local cType				:= '1'
Local cCodOpe   		:= CBRetOpe()
Local cStatus			:= ''
Local oJsonInv 			:= JsonObject():New()

Local cFilOld			:= cFilant

Default Self:Code  := ''


Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO No INVENTARIO ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventario'
	 lRet			   := .F.
EndIf
If lRet
   GetInv(3,,,cAlias,Self:Code )
    If (cAlias)->(!EOF())

        While (cAlias)->(!EOF())
			oJsonInv 		:=  JsonObject():New()

			oJsonInv["code"]			:= Padr((cAlias)->CODINV,TamSX3("CBA_CODINV")[1]) + (cAlias)->NUM
			oJsonInv["type"]			:= AllTrim( (cAlias)->TIPINV 				)
			oJsonInv["warehouse"]		:= AllTrim(Posicione("NNR",1,padr(xFilial("NNR"),TamSX3("NNR_FILIAL")[1])+AllTrim( (cAlias)->ARMAZEM),"NNR_DESCRI"))
			oJsonInv["address"]			:= AllTrim( (cAlias)->LOCALIZ      			)
			oJsonInv["guided"]			:= If(AllTrim( (cAlias)->INVGUI)== '1', 1, 0 )
			oJsonInv["recount"]			:= If(AllTrim( (cAlias)->RECINV)== '1', 1, 0 )
			oJsonInv["status"]			:= AllTrim( (cAlias)->STATUS				)

			(cAlias)->(dbSkip())
		End

    Else
       nStatusCode      := 404
       cMessage         := STR0008 //"Inventario nao encontrada"
       lRet			   	:= .F.
    EndIf

Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	cResponse := FwJsonSerialize( oJsonInv )
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, cMessage )
	Self:SetResponse( cMessage )
EndIf
If ValType(oJsonInv) == "O"
	FreeObj(oJsonInv)
	oJsonInv := Nil
Endif


Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetInv()
Constroi um Query com a Seleção de dados para inventario

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetInv(nGet,cSearch,cStatus,cAliasQry,cInv,cCodOpe,nStatusCode,cMessage )

Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cWhere		:= "% "
Local cSelect		:= ""
Local cCamposCBA	:= ""
Local cAliasCBA     := ""
Local cTamProd      := Space(TamSX3("CBA_PROD")[1])
Local cSelInvGui    := ""
Local cNotInvGui    := ""
Local cExpJoin      := ""
Local cJoinSB8      := ""
Local cTypeProd     := ""
Local cCampos       := ""
Local lExistSB2     := .F.
Local lDesLotZer    := .F.
Local lModelo1      := SuperGetMv("MV_CBINVMD",.F.,"1") == "1"
Local lCbaInvGui    := CBA->(ColumnPos("CBA_INVGUI")) > 0
Local lCbaRecInv    := CBA->(ColumnPos("CBA_RECINV")) > 0
Local lCbaDispos    := CBA->(ColumnPos("CBA_DISPOS")) > 0
Local cFilStatus    := ""
Local cFilData      := ""
Local lRecont       := .F.

Default cSearch     := ''
Default cStatus   	:= '1'
Default cInv   		:= ''

// Colunas que serao adicionadas ao Select do App
If lCbaInvGui
	cSelect := "% ,CBA_INVGUI INVGUI"
Else
	cSelect := "% ,1 INVGUI"
EndIf
If lCbaRecInv
	cSelect += " ,CBA_RECINV RECINV %"
Else
	cSelect += " ,1 RECINV %"
EndIf

// Retorna lista de inventarios
If nGet == 1
	// Filtro por Status
	cFilStatus := " AND ((CBA.CBA_STATUS IN ('0','1')"
	// Se o campo CBA_DISPOS existir, retira inventarios iniciados pelo Coletor e adiciona os iniciados pelo App com recontagem autorizada pelo monitor do ACD
	If lCbaDispos
		cFilStatus += " AND CBA.CBA_DISPOS <> '1') OR (CBA.CBA_STATUS = '3' AND CBA.CBA_DISPOS = '2' AND CBA.CBA_AUTREC = '1'))"
	Else
		cFilStatus += "))"
	EndIf
	// Filtro por data
	cFilData := " AND CBA.CBA_DATA <= '" + DToS(dDataBase) + "' %"

	// Filtro para inventario guiado
	cSelInvGui := "% AND CBA.CBA_TIPINV = '1'"
	If lCbaInvGui
		cSelInvGui += " AND CBA.CBA_INVGUI = '1'"
	EndIf
	cSelInvGui += cFilStatus
	cSelInvGui += cFilData

	// Filtro para inventario nao guiado
	cNotInvGui := "% AND (CBA.CBA_TIPINV <> '1' OR CBA.CBA_PROD = '" + cTamProd + "'"
	If lCbaInvGui
		cNotInvGui += " OR CBA.CBA_INVGUI <> '1')"
	Else
		cNotInvGui += ")"
	EndIf
	cNotInvGui += cFilStatus
	cNotInvGui += cFilData

	// Parametro para considerar somente produtos com tipos definidos
	cTypeProd := SuperGetMV("MV_MCDTPPR", .F., "")
	If Valtype(cTypeProd) != "C"
		cTypeProd := ""
	Else
		cTypeProd := StrTran(cTypeProd, " ", "")
	EndIf
	If !Empty(cTypeProd)
		cTypeProd := "'" + StrTran( cTypeProd, ",", "','" ) + "'"
		cExpJoin := " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cExpJoin += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cExpJoin += " AND SB1.B1_COD = CBA.CBA_PROD"
		cExpJoin += " AND SB1.B1_TIPO IN (" + cTypeProd + ")"
		cExpJoin += " AND SB1.D_E_L_E_T_ = ' ' "
	EndIf

	// Parametro para considerar somente produtos que constam na SB2
	lExistSB2 := SuperGetMV("MV_MCDPRSL", .F., .F.)
	If Valtype(lExistSB2) != "L"
	 	lExistSB2 := .F.
	EndIf
	If lExistSB2
		cSelInvGui := SubStr(cSelInvGui, 1, Len(cSelInvGui)-2) + " AND CBA.CBA_PROD <> '" + cTamProd + "' %"
		If Empty(cExpJoin)
			cExpJoin := " INNER JOIN " + RetSqlName("SB2") + " SB2"
		Else
			cExpJoin += " INNER JOIN " + RetSqlName("SB2") + " SB2"
		EndIf
		cExpJoin += " ON SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
		cExpJoin += " AND SB2.B2_COD = CBA.CBA_PROD"
		cExpJoin += " AND SB2.B2_LOCAL = CBA.CBA_LOCAL"
		cExpJoin += " AND SB2.D_E_L_E_T_ = ' ' "
	EndIf

	lDesLotZer := SuperGetMV( "MV_MCDLTZR", .F., .F. ) // Desconsidera produtos com lote zerado e nao traz o inventario
	If lDesLotZer
		cJoinSB8 := " LEFT JOIN " + RetSqlName("SB8") + " SB8"
		cJoinSB8 += " ON SB8.B8_FILIAL = '" + xFilial("SB8") + "'"
		cJoinSB8 += " AND SB8.B8_PRODUTO = CBA.CBA_PROD"
		cJoinSB8 += " AND SB8.D_E_L_E_T_ = ' ' "

		If Empty(cExpJoin)
			cExpJoin := cJoinSB8
		Else
			cExpJoin += cJoinSB8
		EndIf

		cSelInvGui := SubStr(cSelInvGui, 1, Len(cSelInvGui)-2) + " AND (SB8.B8_SALDO > 0 OR " + MATIsNull() + "(SB8.B8_LOTECTL, ' ') = ' ') %"
		cNotInvGui := SubStr(cNotInvGui, 1, Len(cNotInvGui)-2) + " AND (SB8.B8_SALDO > 0 OR " + MATIsNull() + "(SB8.B8_LOTECTL, ' ') = ' ') %"
	EndIf

	cExpJoin := "%" + cExpJoin + "%"
	cJoinSB8 := "%" + cJoinSB8 + "%"

	// Primeiro select, retorna os inventarios conforme filtros para que seja gravada a tabela CBB
	cAliasCBA := GetNextAlias()
	If lCbaDispos
		cCamposCBA := "% CBA_CODINV CODINV, CBA_STATUS STATUS, CBA_AUTREC AUTREC, CBA_DISPOS DISPOS %"
	Else
		cCamposCBA := "% CBA_CODINV CODINV, CBA_STATUS STATUS, CBA_AUTREC AUTREC, ' ' DISPOS %"
	EndIf
	// Seleciona inventarios por produto e guiados respeitando os parametros MV_MCDTPPR e MV_MCDPRSL
	// mais os inventarios que nao sejam por produto ou nao sejam guiados (UNION)
	BeginSQL Alias cAliasCBA

		SELECT %EXP:cCamposCBA%
		FROM
			%Table:CBA% CBA
		%EXP:cExpJoin%
		WHERE
			CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cSelInvGui%
			AND CBA.%NotDel%
		UNION
		SELECT %EXP:cCamposCBA%
		FROM %Table:CBA% CBA
		%EXP:cJoinSB8%
		WHERE CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cNotInvGui%
			AND CBA.%NotDel%
		ORDER BY CODINV DESC

	EndSQL

	If (cAliasCBA)->(!EOF())
		While (cAliasCBA)->(!EOF())
			If !lModelo1 .And. (cAliasCBA)->AUTREC == "1" .And. (cAliasCBA)->DISPOS == "2"
				lRecont := .T.
			Else
				lRecont := .F.
			EndIf
			GrvCBB((cAliasCBA)->CODINV,cCodOpe,@nStatusCode,@cMessage,.F.,lModelo1,lRecont)
			(cAliasCBA)->(DBSKIP())
		End
	EndIf

	If Select(cAliasCBA) > 0
		(cAliasCBA)->(dbCloseArea())
	EndIf

	// Segundo select, retorna os inventarios definitivos para o App
	cCampos := "CBA.R_E_C_N_O_ RECCBA,CBA_CODINV CODINV,CBA_STATUS STATUS,CBA_TIPINV TIPINV,CBA_PROD PROD,CBA_LOCAL ARMAZEM,CBA_DATA DTMESTRE,CBA_LOCALI LOCALIZ,CBA_CONTS CONTS,CBB_NUM NUM"
	cCampos += SubStr(cSelect,3,Len(cSelect))
	cSelect := "% " + cCampos

	If Len(AllTrim(cSearch)) == 1
		If AllTrim(cSearch) == "'"
			cSearch := '"'
		EndIf
	Else
		cSearch := REPLACE(cSearch,"'","")
	EndIf
	cSearch := AllTrim(Upper(FwNoAccent(cSearch)))

	If !Empty(cSearch)
		cWhere  += " AND ( CBA_CODINV  LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += "  CBB_CODINV " +  cConcat + " CBB_NUM  LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  CBA_PROD    LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  CBA_LOCAL    LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  CBA_LOCALI	LIKE '%"   	+ cSearch + "%')
	EndIf
	cWhere  += " %"

	BeginSQL Alias cAliasQry

		SELECT
			%EXP:cSelect%
		FROM
			%Table:CBA% CBA
		INNER JOIN 	%Table:CBB% CBB ON
			CBB.CBB_FILIAL = CBA.CBA_FILIAL
			AND CBB.CBB_CODINV = CBA.CBA_CODINV
			AND CBB.CBB_STATUS	= '0'
			AND CBB.CBB_USU <> %EXP:cCodOpe%
			AND CBB.%NotDel%
		%EXP:cExpJoin%
		WHERE
			CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cSelInvGui%
			AND CBA.%NotDel%
			%EXP:cWhere%
		UNION
		SELECT %EXP:cSelect%
		FROM %Table:CBA% CBA
		INNER JOIN 	%Table:CBB% CBB ON
			CBB.CBB_FILIAL = CBA.CBA_FILIAL
			AND CBB.CBB_CODINV = CBA.CBA_CODINV
			AND CBB.CBB_STATUS	= '0'
			AND CBB.CBB_USU <> %EXP:cCodOpe%
			AND CBB.%NotDel%
		%EXP:cJoinSB8%
		WHERE
			CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cNotInvGui%
			AND CBA.%NotDel%
			%EXP:cWhere%
		ORDER BY CODINV DESC

	EndSQL
// Retorna inventario especifico
ElseIf nGet == 2
	BeginSQL Alias cAliasQry

	SELECT CBA.R_E_C_N_O_  AS RECCBA,CBA_CODINV CODINV,CBA_STATUS STATUS,CBA_TIPINV TIPINV,CBA_PROD PROD,CBA_LOCAL ARMAZEM,CBA_LOCALI LOCALIZ,CBA_CONTS CONTS,CBA_DATA DTMESTRE
	%EXP:cSelect%
	FROM
		%Table:CBA% CBA
	WHERE
		CBA.CBA_FILIAL = %xFilial:CBA%
		AND CBA.CBA_STATUS	=  %Exp:cStatus%
		AND CBA.CBA_CODINV	= %Exp:cInv%
		AND CBA.%NotDel%
		ORDER BY CODINV DESC
	EndSQL
Else


	cWhere += " AND CBA.CBA_CODINV  = '" +  Substr(cInv,1,TamSX3("CBA_CODINV")[1]) + "' "
	cWhere += " AND CBB.CBB_NUM    = '" +  Substr(cInv,TamSX3("CBA_CODINV")[1]+1,TamSX3("CBB_NUM")[1]) + "' %"

	BeginSQL Alias cAliasQry

	SELECT 	CBA.R_E_C_N_O_  AS RECCBA,CBA_CODINV CODINV,CBA_STATUS STATUS,CBA_TIPINV TIPINV,CBA_PROD PROD,CBA_LOCAL ARMAZEM,CBA_DATA DTMESTRE,
			CBA_LOCALI LOCALIZ,CBA_CONTS CONTS,CBB_NUM NUM
	%EXP:cSelect%
	FROM
		%Table:CBA% CBA
	INNER JOIN 	%Table:CBB% CBB ON
		CBB.CBB_FILIAL = CBA.CBA_FILIAL
		AND CBB.CBB_CODINV = CBA.CBA_CODINV
		AND CBB.CBB_STATUS	= '0'
		AND CBB.%NotDel%
	WHERE
		CBA.CBA_FILIAL = %xFilial:CBA%
		AND CBA.CBA_STATUS	IN ('0','1')
		AND CBA.CBA_DATA	<= %Exp:ddatabase%
		AND CBA.%NotDel%
		%EXP:cWhere%
		ORDER BY CODINV DESC
	EndSQL

Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCBB
 Função que grava as tabelas de inventario do acd
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvCBB(cCodInv,cCodOpe,nStatusCode,cMessage,lExtra, lModelo1, lRecont)

Local nX			:= 0
Local nY			:= 0
Local lEncontrou    := .F.
Local nCriaCBB		:= 1
Local cUltCont      := ""
Local aCBC          := {}

Default lExtra		:= .F.
Default lModelo1	:= .T.
Default lRecont     := .F.

CBA->(dbSetOrder(1))
If CBA->(dbSeek(PADR(xFilial('CBA'),TamSX3("CBA_FILIAL")[1])+cCodInv))

	If !lExtra .And. !lRecont
		CBB->(dbSetOrder(1))
		lEncontrou := CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ CBA->CBA_CODINV ))
		If !lEncontrou
			If lModelo1
				nCriaCBB :=	CBA->CBA_CONTS
			EndIf
			For nX :=  1 To nCriaCBB
				Reclock("CBB",.T.)
				CBB->CBB_FILIAL := xFilial("CBB")
				CBB->CBB_NUM    := CBProxCod('MV_USUINV') // pega o proximo id para o inventario por usuario
				CBB->CBB_CODINV := CBA->CBA_CODINV
				//CBB->CBB_USU    := cCodOpe
				CBB->CBB_STATUS := "0"
				CBB->(MsUnlock())
			Next nX
		EndIf
	Else
		If lRecont .And. !lModelo1
			// Retorna a ultima contagem do inventario
			cUltCont := CBUltCont(CBA->CBA_CODINV)

			// Tratamento para nao gravar CBB em duplicidade
			If !Empty(cUltCont)
				CBB->(dbSetOrder(3))
				lEncontrou := CBB->(DbSeek(PADR(xFilial("CBB"),TamSX3("CBB_FILIAL")[1]) + CBA->CBA_CODINV + cUltCont)) .And. CBB->CBB_STATUS $ "01"
			EndIf
		EndIf

		If !lEncontrou
			Reclock("CBB",.T.)
			CBB->CBB_FILIAL := xFilial("CBB")
			CBB->CBB_NUM    := CBProxCod('MV_USUINV') // pega o proximo id para o inventario por usuario
			CBB->CBB_CODINV := CBA->CBA_CODINV
			//CBB->CBB_USU    := cCodOpe
			CBB->CBB_STATUS := "0"
			CBB->(MsUnlock())

			RecLock("CBA",.F.)
			CBA->CBA_STATUS := '1'
			CBA->(MsUnlock())

			//-- transpor as contagens batidas para este usuario (mesmo tratamento do ACDV035)
			If lRecont .And. !Empty(cUltCont)
				CBC->(DbSetOrder(1))
				CBC->(DbSeek(xFilial("CBC")+cUltCont))
				While CBC->(!Eof() .And. xFilial("CBC")+cUltCont == CBC_FILIAL+CBC_NUM)
					If CBC->CBC_CONTOK == "1"
						aAdd(aCBC,Array(CBC->(FCount())))
						For nX := 1 To CBC->(FCount())
							aCBC[Len(aCBC),nX] := CBC->(FieldGet(nX))
						Next nX
					EndIf
					CBC->(DbSkip())
				End
				For nX := 1 to Len(aCBC)
					Reclock("CBC", .T.)
					For nY := 1 To CBC->(FCount())
						If CBC->(FieldName(nY)) == "CBC_CODINV"
							CBC->CBC_CODINV := CBB->CBB_CODINV
						ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
							CBC->CBC_NUM := CBB->CBB_NUM
						Else
							CBC->(FieldPut(nY,aCBC[nX,nY]))
						EndIf
					Next nY
					CBC->(MsUnLock())
				Next nX
			EndIf
		EndIf

	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvInv
 Função que grava as tabelas de inventario do acd
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvInv(cProd,cEnder,cLoteProd,nQuantInv,cCodOpe,nStatusCode,cMessage,cCodBar)

Local lRet 		:= .T.
Local aProdInv	:= {}
LOcal nPos		:= 0
Local cAliasB1	:= GetnextAlias()

If !Empty(cProd)
	CBLoadEst(@aProdInv,.F.)
	nPos := ascan(aProdInv,{|x| x[1]+x[2]+x[4]+x[5]==PADR(cProd,TamSX3("CBC_COD")[1])+PADR(cLoteProd,TamSX3("CBC_LOTECT")[1]);
	+PADR(CBA->CBA_LOCAL,TamSX3("CBA_LOCAL")[1])+PADR(cEnder,TamSX3("CBC_LOCALI")[1])})
EndIf
If nPos > 0
	RecLock("CBC",.T.)
	CBC->CBC_FILIAL := xFilial("CBC")
	CBC->CBC_CODINV := CBB->CBB_CODINV
	CBC->CBC_NUM    := CBB->CBB_NUM
	CBC->CBC_LOCAL  := CBA->CBA_LOCAL
	CBC->CBC_LOCALI := cEnder
	CBC->CBC_COD    := cProd
	CBC->CBC_LOTECT := cLoteProd
	CBC->CBC_QUANT  := nQuantInv
	CBC->CBC_QTDORI := nQuantInv
	CBC->(MSUNLOCK())

Else
	BeginSQL Alias cAliasB1

	SELECT B1_COD
	FROM
		%Table:SB1% SB1
	WHERE
		SB1.B1_FILIAL = %xFilial:SB1%
		AND (SB1.B1_CODBAR	= %Exp:cCodBar% OR SB1.B1_COD	= %Exp:cCodBar%)
		AND SB1.%NotDel%
	EndSQL
	If (cAliasB1)->(!EOF())	.And. !Empty(cCodBar)

		If  !SB2->(DbSeek(padr(xFilial("SB2"),TAMSX3("B2_FILIAL")[1])+(cAliasB1)->B1_COD+CBA->CBA_LOCAL))
			CriaSB2((cAliasB1)->B1_COD,CBA->CBA_LOCAL,xFilial("SB2"))
		EndIf
		//-----------------------------------//
		//	Calculo de ambalagem 			//
		//---------------------------------//
		nQuantInv := AcdMobEmb((cAliasB1)->B1_COD,nQuantInv)
		
		RecLock("CBC",.T.)
		CBC->CBC_FILIAL := xFilial("CBC")
		CBC->CBC_CODINV := CBB->CBB_CODINV
		CBC->CBC_NUM    := CBB->CBB_NUM
		CBC->CBC_LOCAL  := CBA->CBA_LOCAL
		CBC->CBC_LOCALI := cEnder
		CBC->CBC_COD    := (cAliasB1)->B1_COD
		CBC->CBC_LOTECT := cLoteProd
		CBC->CBC_QUANT  := nQuantInv
		CBC->CBC_QTDORI := nQuantInv
		CBC->(MSUNLOCK())
	Else
		//grava D3V
		D3V->(DbSetOrder(3))
		If	!D3V->(DBSeek(padr(xFilial("D3V"),TAMSX3("D3V_FILIAL")[1])+'3'+ CBB->CBB_CODINV + cProd))
			// Grava a tabela de divergencia
			RecLock("D3V",.t.)
			D3V->D3V_FILIAL	:= xFilial("D3V")
			D3V->D3V_CODIGO	:= GetSXENum("D3V", "D3V_CODIGO")
			D3V->D3V_ORIGEM	:= '3'
			D3V->D3V_MOTIVO	:= '1'
			D3V->D3V_CODINV	:= CBB->CBB_CODINV
			D3V->D3V_NUMINV := CBB->CBB_NUM
			D3V->D3V_CODPRO	:= cProd
			D3V->D3V_CODBAR	:= cCodBar
			D3V->D3V_QTDE	:= nQuantInv
			D3V->D3V_LOCORI	:= CBA->CBA_LOCAL
			D3V->D3V_LOTECT	:= cLoteProd
			D3V->D3V_LCZORI	:= cEnder
			D3V->D3V_CODUSR	:= cCodOpe
			D3V->D3V_DATA	:= dDatabase
			D3V->D3V_HORA	:= Time()
			D3V->D3V_STATUS	:= '1'
			D3V->(MsUnLock())
			CONFIRMSX8()
		Endif


	Endif

	If Select(cAliasB1) > 0
		(cAliasB1)->(dbCloseArea())
	Endif
Endif
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AjustInv
 Função que grava as tabelas de inventario do acd
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function AjustInv()

Local aProdInv		:= {}
Local nX			:= 0

CBC->(dbSetOrder(2))
CBLoadEst(@aProdInv,.F.)

For nX := 1 to Len(aProdInv)
	If !CBC->(dbSeek(padr(xFilial('CBC'),TAMSX3("CBC_FILIAL")[1])+CBB->CBB_NUM+aProdInv[nX,1]+aProdInv[nX,4]+aProdInv[nX,5]+aProdInv[nX,2]+aProdInv[nX,3]+aProdInv[nX,6]))
		RecLock("CBC",.T.)
		CBC->CBC_FILIAL := xFilial("CBC")
		CBC->CBC_CODINV := CBB->CBB_CODINV
		CBC->CBC_NUM    := CBB->CBB_NUM
		CBC->CBC_LOCAL  := aProdInv[nX,4]
		CBC->CBC_LOCALI := aProdInv[nX,5]
		CBC->CBC_COD    := aProdInv[nX,1]
		CBC->CBC_LOTECT := aProdInv[nX,2]
		CBC->CBC_NUMLOT := aProdInv[nX,3]
		CBC->CBC_NUMSER := aProdInv[nX,6]
		CBC->CBC_QUANT  := 0
		CBC->(MSUNLOCK())
	Endif
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Products WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cCodOpe   		:= CBRetOpe()
Local lHasNext			:= .F.
Local cFilOld			:= cFilant
Local cDadosProd		:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cProductCode		:= ''
Local oJsonLot			:= NIL

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NO PRODUTOS ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
	    GetTransf(1, UPPER(Self:SearchKey), Self:Status, cAlias, self:Page, self:PageSize )

	    If (cAlias)->(!EOF())

	        COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        oJsonProd 			:=  JsonObject():New()

			oJsonProd["branch"	]	:= FWModeAccess("SB1",3)
			oJsonProd["business"]	:= FWModeAccess("SB1",1)
			oJsonProd["unit"	]	:= FWModeAccess("SB1",2)

	        While (cAlias)->(!EOF())
	            nCount++

	            If (nCount >= nStart)
					If cProductCode <> (cAlias)->PROD
						nEntJson++
						aAdd( aJsonProd,  JsonObject():New() )

						aJsonProd[ nEntJson ][ "code" ]			:= ( cAlias )->PROD
						aJsonProd[ nEntJson ][ "barcode" ]		:= ( cAlias )->CODBAR
						aJsonProd[ nEntJson ][ "description" ]	:= EncodeUTF8(  AllTrim( ( cAlias )->DESCRI) )
						If cDadosProd <> "SBZ"
							aJsonProd[ nEntJson ][ "address" ]	:= IIf( AllTrim( ( cAlias )->LOCALIZ ) = 'S', .T., .F. )
						Else
							aJsonProd[ nEntJson ][ "address" ]	:= IIf( AllTrim( IIf( !EMPTY( ( cAlias )->LOCALIZZ ), ( cAlias )->LOCALIZZ, ( cAlias )->LOCALIZ ) ) = 'S', .T., .F. )
						EndIf
						aJsonProd[ nEntJson ][ "batch" ] 		:= AllTrim( ( cAlias )->RASTRO ) // S=sublote,L=lote,N= não controla
						aJsonProd[ nEntJson ][ "batchs" ] 		:= {}

						If ( ( !Empty( ( cAlias )->RASTRO ) .And. AllTrim( ( cAlias )->RASTRO ) <> 'N' ) .And. !Empty( ( cAlias )->ARMAZEM ) )
							oJsonLot := JsonObject():New()
							oJsonLot[ "warehouse" ]	:= ( cAlias )->ARMAZEM
							oJsonLot[ "batch" ]		:= ( cAlias )->LOTE

							aAdd( aJsonProd[ nEntJson ][ "batchs" ], oJsonLot )
						EndIf

						If nEntJson < Self:PageSize .And. nCount < nRecord

						Else
							Exit
						EndIf
					Else
						If ( !Empty( ( cAlias )->RASTRO ) .And. AllTrim( ( cAlias )->RASTRO ) <> 'N' )
							oJsonLot := JsonObject():New()
							oJsonLot[ "warehouse" ]	:= ( cAlias )->ARMAZEM
							oJsonLot[ "batch" ]		:= ( cAlias )->LOTE

							aAdd( aJsonProd[ nEntJson ][ "batchs" ], oJsonLot ) 
						EndIf
					EndIf
	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				cProductCode := (cAlias)->PROD

				(cAlias)->(DbSkip())

	        EndDo

			If nRecord  < Self:PageSize
				lHasNext	:= .F.
			else
				lHasNext	:= .T.
			EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd
	    	oJsonProd["hasNext"] 	:= lHasNext
	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

FWFreeArray( aJsonProd )
FreeObj( oJsonProd )
FreeObj( oJsonLot )
oJsonProd := Nil
oJsonLot := Nil

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de armazens.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Warehouse WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonArm			:= JsonObject():New()
Local aJsonArm		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0012 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cOrdem			:= ''
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local cFilOld			:= cFilant

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NO ARMAZEM ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetTransf(2,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 20
				Self:PageSize := 20
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonArm 			:=  JsonObject():New()

			oJsonArm["branch"	]	:= FWModeAccess("NNR",3)
			oJsonArm["business" ]	:= FWModeAccess("NNR",1)
			oJsonArm["unit"	    ]	:= FWModeAccess("NNR",2)

	        While (cAlias)->(!EOF())
	            nCount++


	            If (nCount >= nStart)

	                nEntJson++
	                aAdd( aJsonArm,  JsonObject():New() )

	                aJsonArm[nEntJson]["warehouse"			]	:= (cAlias)->CODARM
					aJsonArm[nEntJson]["description"		]	:= EncodeUTF8(Alltrim((cAlias)->DESCRI))

					If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf


	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				(cAlias)->(DbSkip())

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonArm 				:=  JsonObject():New()
	    	oJsonArm["warehouses"]	:= aJsonArm
	    	oJsonArm["hasNext"] 	:= lHasNext

	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonArm["warehouses"]		:= aJsonArm
	oJsonArm["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonArm )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonArm) == "O"
	FreeObj(oJsonArm)
	oJsonArm := Nil
Endif

Return (lRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de endereços.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Address WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonEnd			:= JsonObject():New()
Local aJsonEnd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cOrdem			:= ''
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local cFilOld			:= cFilant

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NO ENDEREÇO ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetTransf(3,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())


	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonEnd 			:=  JsonObject():New()

			oJsonEnd["branch"	]	:= FWModeAccess("SBE",3)
			oJsonEnd["business" ]	:= FWModeAccess("SBE",1)
			oJsonEnd["unit"	    ]	:= FWModeAccess("SBE",2)

	        While (cAlias)->(!EOF())
	            nCount++


	            If (nCount >= nStart)
					SBE->(DbGoTo((cAlias)->REC))
	                nEntJson++
	                aAdd( aJsonEnd,  JsonObject():New() )

	                aJsonEnd[nEntJson]["warehouse"			]	:= (cAlias)->CODARM
	                aJsonEnd[nEntJson]["address"			]	:= (cAlias)->ADDRESS
					aJsonEnd[nEntJson]["description"		]	:= EncodeUTF8(Alltrim((cAlias)->DESCRIC))
					aJsonEnd[nEntJson]["status"				]	:= (cAlias)->STATUS
					If !RegistroOk("SBE")
						aJsonEnd[nEntJson]["status_msblql"	]	:= '1'
					Else
						aJsonEnd[nEntJson]["status_msblql"	]	:= '2'
					EndIf
					If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf


	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				(cAlias)->(DbSkip())

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonEnd 				:=  JsonObject():New()
	    	oJsonEnd["addresses"]	:= aJsonEnd
	    	oJsonEnd["hasNext"] 	:= lHasNext

	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonEnd["addresses"]		:= aJsonEnd
	oJsonEnd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonEnd )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonEnd) == "O"
	FreeObj(oJsonEnd)
	oJsonEnd := Nil
Endif

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetTransf()
Constroi um Query com a Seleção de produtos, uma com selação de armazens, uma com seleção de endereços

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.
		nPage		, numeric, Define qual o número da página a ser processada
		nPageSize	, numeric, Define a quantidade de registros por página

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetTransf( nTp, cSearch, cStatus, cAliasQry, nPage, nPageSize )

Local cWhere		:= "% "
Local cDadosProd	:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cTypeProduct	:= '' 
Local nRecStart		:= 0  // Define a quantidade de registros ja retornados
Local nRecFinish	:= 0  // Define o registro máximo à retornar
Local lExistSB2		:= .F.
Local lDesLotZer    := .F.
Local cExpJoin      := ""

Default cSearch     := ''
Default cStatus   	:= '1'
default nTp			:= 1
Default nPage		:= 1
Default nPageSize	:= 1

nRecStart := ( (nPage - 1) * nPageSize ) + 1

nRecFinish := ( nRecStart + nPageSize ) - 1

If 	Len(alltrim(cSearch))== 1
	If alltrim(cSearch) == "'"
		cSearch     := '"'
	Endif
Else
	cSearch := REPLACE(cSearch,"'","")
Endif
cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))

If nTp == 1 // produto
	
	cTypeProduct	:= SuperGetMV( "MV_MCDTPPR", .F., "" )	// Determina os tipos de produto que serão sincronizados.
	lExistSB2		:= SuperGetMV( "MV_MCDPRSL", .F., .F. ) // Apresenta somente os registros presentes na SB2
	lDesLotZer		:= SuperGetMV( "MV_MCDLTZR", .F., .F. ) // Desconsidera produtos com lote zerado

	// Corrige eventuais erros no preenchimento dos parâmetros
	If Valtype(lExistSB2) != "L"
	 	lExistSB2 := .F.
	EndIf

	If Valtype( cTypeProduct ) != "C"
		cTypeProduct := ""	
	Else
		// Retira os espaços do parâmetro MV_MCDTPPR, pois eles podem resultar em erro na montagem da query
		cTypeProduct := StrTran( cTypeProduct, " ", "" )
	EndIf

	If !Empty(cSearch)
		cWhere  += " AND ( B1_COD LIKE '%" + cSearch + "%' OR "
	    cWhere  += "B1_CODBAR LIKE '%" + cSearch + "%' OR "
	    cWhere  += "B1_DESC LIKE '%" + cSearch + "%' )"
	EndIf

	If !Empty(cTypeProduct)
		cTypeProduct := "'" + StrTran( cTypeProduct, ",", "','" ) + "'"
		cWhere += " AND B1_TIPO IN ( " + cTypeProduct + " ) "
	EndIf

	If lExistSB2
		cWhere += " AND B1_COD IN ( SELECT DISTINCT B2_COD FROM " + RetSqlName("SB2") + " SB2 WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.D_E_L_E_T_ = ' ' ) "
	EndIf

	cExpJoin := "% LEFT JOIN " + RetSqlName("SB8") + " SB8"
	cExpJoin += " ON SB8.B8_FILIAL = '" + xFilial("SB8") + "'"
	cExpJoin += " AND SB8.B8_PRODUTO = SB1.B1_COD"
	cExpJoin += " AND SB8.D_E_L_E_T_ = ' ' %"

	If lDesLotZer
		cWhere += " AND (SB8.B8_SALDO > 0 OR " + MATIsNull() + "(SB8.B8_LOTECTL, ' ') = ' ')"
	EndIf
	cWhere  += " %"

	If cDadosProd <> 'SBZ'
		BeginSQL Alias cAliasQry 
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER (ORDER BY B1_COD, B8_LOCAL, B8_LOTECTL) AS LINHA, B1_COD PROD, B1_CODBAR CODBAR, B1_DESC DESCRI, 
					B1_RASTRO RASTRO, B1_LOCALIZ LOCALIZ, 
					B8_LOCAL ARMAZEM, B8_LOTECTL LOTE
				FROM %Table:SB1% SB1
				%EXP:cExpJoin%
				WHERE SB1.B1_FILIAL = %xFilial:SB1%
					AND SB1.B1_MSBLQL <> '1'
					AND SB1.%NotDel%
					%EXP:cWhere%) TABLE_SB1
			WHERE LINHA BETWEEN %EXP:nRecStart% AND %EXP:nRecFinish%
		EndSQL
	Else
		BeginSQL Alias cAliasQry
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER (ORDER BY B1_COD, B8_LOCAL, B8_LOTECTL) AS LINHA, B1_COD PROD, B1_CODBAR CODBAR, B1_DESC DESCRI,
					B1_RASTRO RASTRO, BZ_LOCALIZ LOCALIZZ, B1_LOCALIZ LOCALIZ,
					B8_LOCAL ARMAZEM, B8_LOTECTL LOTE
				FROM %Table:SB1% SB1
				%EXP:cExpJoin%
				LEFT JOIN %Table:SBZ% SBZ ON
					SBZ.BZ_FILIAL = %xFilial:SBZ%
					AND SBZ.BZ_COD = SB1.B1_COD
					AND SBZ.%NotDel%
				WHERE SB1.B1_FILIAL = %xFilial:SB1%
					AND SB1.B1_MSBLQL <> '1'
					AND SB1.%NotDel%
					%EXP:cWhere%) TABLE_SB1
			WHERE LINHA BETWEEN %EXP:nRecStart% AND %EXP:nRecFinish%
		EndSQL
	Endif

ElseIf nTp == 2

	If !Empty(cSearch)
		cWhere  += " AND ( NNR_CODIGO  	LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  NNR_DESCRI    	LIKE '%"   	+ cSearch + "%' )
	EndIf
	cWhere  += " %"


	BeginSQL Alias cAliasQry

	SELECT NNR_CODIGO CODARM,NNR_DESCRI DESCRI
	FROM
		%Table:NNR% NNR
	WHERE
		NNR.NNR_FILIAL = %xFilial:NNR%
		AND NNR.%NotDel%
		%EXP:cWhere%
	ORDER BY NNR_CODIGO
	EndSQL

Else

	If !Empty(cSearch)
		cWhere  += " AND ( BE_LOCAL  	LIKE '%"   	+ cSearch + "%' OR"
		cWhere  += " AND ( BE_LOCALIZ  	LIKE '%"   	+ cSearch + "%' OR"
	    cWhere  += "  BE_DESCRIC    	LIKE '%"   	+ cSearch + "%' )
	EndIf
	cWhere  += " %"


	BeginSQL Alias cAliasQry

	SELECT SBE.BE_LOCAL CODARM, SBE.BE_LOCALIZ ADDRESS, SBE.BE_DESCRIC DESCRIC, 
	SBE.BE_STATUS STATUS, SBE.R_E_C_N_O_ REC
	FROM
		%Table:SBE% SBE
	WHERE
		SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.%NotDel%
		%EXP:cWhere%
	ORDER BY BE_LOCAL,BE_LOCALIZ
	EndSQL

Endif

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} POST  transfer / ACDMOB
 finaliza a transferencia

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD POST transfer WSSERVICE ACDMOB

Local nStatusCode   := 500
Local oJTransfer	:= Nil
Local cMessage		:= ""
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local nQtdEmb		:= 0
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local cAlias        := GetnextAlias()
Local cOrdem		:= ''
Local nCounReg		:= 0
Local aTransf		:= {}
Local oJsontrans	:= JsonObject():New()
Local aJtrans		:= {}
Local aSaldo		:= {}
Local lGrvD3V		:= .F.
Local cMotivo		:= ''
Local cPath     	:= GetSrvProfString("StartPath","")
Local cFile     	:= NomeAutoLog()
Local cMsgErro		:= ''
Local dValid		:= dDatabase
Local nCount 		:= 1
Local lAchouSB1		:= .F.
Local cDadosProd 	:= ''
Local lDadosSBZ		:= .T.

Local oError := ErrorBlock({|e| cMessage := STR0022, nStatusCode := 500, lRet := .F.}) // "Erro na leitura da requisicao. Contate o administrador do sistema."

Private lMsHelpAuto , lMsErroAuto, lMsFinalAuto := .f.

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA TRANSFERENCIA ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventario'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(Upper(cBody),@oJTransfer)

			If !Empty( oJTransfer )

				Begin Sequence

					oJsonTrans 		:=  JsonObject():New()
					aTransf	:= {}
					dbSelectArea("SD3")
					aadd (aTransf,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
					nCount := 1
					For nX := 1 To Len( oJTransfer )
						lGrvD3V	:= .F.
						lAchouSB1 := .F.
						SB1->(DbSetOrder(5))
						If SB1->(MsSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+oJTransfer[nX]:Code))
							lAchouSB1 := .T.
						Else
							SB1->(DbSetOrder(1))
							If SB1->(MsSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+oJTransfer[nX]:Code))
								lAchouSB1 := .T.
							EndIf
						Endif
						SB1->(DbSetOrder(1))
						If lAchouSB1
							nQtdEmb := AcdMobEmb(SB1->B1_COD,oJTransfer[nX]:Quantity)

							aSaldo  := CalcEst(SB1->B1_COD,oJTransfer[nX]:WarehouseOrigin,ddatabase+1)
							If aSaldo[1] < nQtdEmb
								lGrvD3V	:= .T.
								cMotivo := "2" // saldo divergente
							Else
								If  !SB2->(DbSeek(padr(xFilial("SB2"),TAMSX3("B2_FILIAL")[1])+SB1->B1_COD+oJTransfer[nX]:WarehouseEnd))
									//{Filial, Armazem, Estoque Disponivel, Branco}
									CriaSB2(SB1->B1_COD,oJTransfer[nX]:WarehouseEnd,xFilial("SB2"))

								EndIf
								lDadosSBZ		:= .F.
								If cDadosProd == "SBZ"
									dbSelectArea("SBZ")
									lDadosSBZ:=!RetArqProd(cCodPro)
								EndIf
								If BlqInvent(SB1->B1_COD,oJTransfer[nX]:WarehouseOrigin,,;
								If(IF(lDadosSBZ,SBZ->BZ_LOCALIZ,SB1->B1_LOCALIZ) = 'S',oJTransfer[nX]:AddressOrigin,""))
									lGrvD3V	:= .T.
									cMotivo := "3" // bloqueio por inventario
								Else
									If BlqInvent(SB1->B1_COD,oJTransfer[nX]:WarehouseEnd,,;
									If(IF(lDadosSBZ,SBZ->BZ_LOCALIZ,SB1->B1_LOCALIZ) = 'S',oJTransfer[nX]:AddressEnd,""))
										lGrvD3V	:= .T.
										cMotivo := "3" // bloqueio por inventario
									EndIf

								EndIf
								/*If Localiza(SB1->B1_COD,.T.)
									If EmpTy(oJTransfer[nX]:SerialNumber)
										lGrvD3V	:= .T.
										cMotivo := "4" // serial number não encontrado para o endereço
									Endif

								EndIf	*/

							Endif
						Else
							lGrvD3V	:= .T.
							cMotivo := "1" // produto não encontrado
						Endif
						If !lGrvD3V
							nCount ++
							dValid := dDatabase+SB1->B1_PRVALID
							If Rastro(SB1->B1_COD)
								SB8->(DbSetOrder(3))
								If SB8->(DbSeek(padr(xFilial("SB8"),TAMSX3("B8_FILIAL")[1])+SB1->B1_COD+oJTransfer[nX]:WarehouseOrigin+oJTransfer[nX]:Batch))
									dValid := SB8->B8_DTVALID
								EndIf
							EndIf
							aAdd(aTransf,{})
							//Origem
							aTransf[nCount]:= {{"D3_COD"      , SB1->B1_COD              									,NIL}}
							aAdd(aTransf[nCount],{"D3_DESCRI" , SB1->B1_DESC               									,NIL})
							aAdd(aTransf[nCount],{"D3_UM"     , SB1->B1_UM                 									,NIL})
							aAdd(aTransf[nCount],{"D3_LOCAL"  , padr(oJTransfer[nX]:WarehouseOrigin,TAMSX3("D3_LOCAL")[1])	,NIL})
							aAdd(aTransf[nCount],{"D3_LOCALIZ", padr(oJTransfer[nX]:AddressOrigin,TAMSX3("D3_LOCALIZ")[1])	,NIL})
							//Destino
							aAdd(aTransf[nCount],{"D3_COD"    , SB1->B1_COD             	  								,NIL})
							aAdd(aTransf[nCount],{"D3_DESCRI" , SB1->B1_DESC               									,NIL})
							aAdd(aTransf[nCount],{"D3_UM"     , SB1->B1_UM             	  									,NIL})
							aAdd(aTransf[nCount],{"D3_LOCAL"  , padr(oJTransfer[nX]:WarehouseEnd,TAMSX3("D3_LOCAL")[1])		,NIL})
							aAdd(aTransf[nCount],{"D3_LOCALIZ", padr(oJTransfer[nX]:AddressEnd,TAMSX3("D3_LOCALIZ")[1])		,NIL})

							//Origem
							aAdd(aTransf[nCount],{"D3_NUMSERI", padr(oJTransfer[nX]:SerialNumber,TAMSX3("D3_NUMSERI")[1])	,NIL})
							aAdd(aTransf[nCount],{"D3_LOTECTL", padr(oJTransfer[nX]:Batch,TAMSX3("D3_LOTECTL")[1])			,NIL})
							aadd(aTransf[nCount],{"D3_NUMLOTE", CriaVar('D3_NUMLOTE')									    ,Nil})
							aAdd(aTransf[nCount],{"D3_DTVALID", dValid      												,NIL})

							aAdd(aTransf[nCount],{"D3_POTENCI", CriaVar("D3_POTENCI")      									,NIL})
							aAdd(aTransf[nCount],{"D3_QUANT"  , nQtdEmb  													,NIL})
							aAdd(aTransf[nCount],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM")      									,NIL})
							aAdd(aTransf[nCount],{"D3_ESTORNO", CriaVar("D3_ESTORNO")      									,NIL})
							aAdd(aTransf[nCount],{"D3_NUMSEQ" , CriaVar("D3_NUMSEQ")		  								,NIL})

							//Destino
							aAdd(aTransf[nCount],{"D3_LOTECTL", padr(oJTransfer[nX]:Batch,TAMSX3("D3_LOTECTL")[1])			,NIL})
							aadd(aTransf[nCount],{"D3_NUMLOTE", CriaVar('D3_NUMLOTE') 										,Nil})
							aAdd(aTransf[nCount],{"D3_DTVALID", dValid	    												,NIL})


						Else
							D3V->(DbSetOrder(4))
							If	!D3V->(DBSeek(padr(xFilial("D3V"),TAMSX3("D3V_FILIAL")[1])+'4'+ oJTransfer[nX]:WarehouseOrigin+SB1->B1_COD + oJTransfer[nX]:Batch + oJTransfer[nX]:AddressOrigin))
								// Grava a tabela de divergencia
								RecLock("D3V",.t.)
								D3V->D3V_FILIAL	:= xFilial("D3V")
								D3V->D3V_CODIGO	:= GetSXENum("D3V", "D3V_CODIGO")
								D3V->D3V_ORIGEM	:= '4'
								D3V->D3V_MOTIVO	:= cMotivo
								D3V->D3V_CODPRO	:= SB1->B1_COD
								D3V->D3V_QTDE	:= nQtdEmb
								D3V->D3V_LOTECT	:= oJTransfer[nX]:Batch
								D3V->D3V_CODUSR	:= cCodOpe
								D3V->D3V_DTVLD	:= dValid
								D3V->D3V_CODETI	:= ''
								D3V->D3V_DATA	:= dDatabase
								D3V->D3V_HORA	:= Time()
								D3V->D3V_STATUS	:= '1'
								D3V->D3V_UM     :=  SB1->B1_UM
								D3V->D3V_LOCORI := oJTransfer[nX]:WarehouseOrigin
								D3V->D3V_LCZORI := oJTransfer[nX]:AddressOrigin
								D3V->D3V_LOCDES := oJTransfer[nX]:WarehouseEnd
								D3V->D3V_LCZDES := oJTransfer[nX]:AddressEnd
								D3V->D3V_NUMSER := oJTransfer[nX]:SerialNumber

								D3V->(MsUnLock())
								ConfirmSx8()
							Endif

							// Grava D3V
						EndIf

						aAdd( aJtrans,  	JsonObject():New() )
											aJtrans[nX]["code"				]	:= oJTransfer[nX]:Code
											aJtrans[nX]["WarehouseOrigin"	]	:= oJTransfer[nX]:WarehouseOrigin
											aJtrans[nX]["AddressOrigin"		]	:= padr(oJTransfer[nX]:AddressOrigin,TAMSX3("D3_LOCALIZ")[1])
											aJtrans[nX]["WarehouseEnd"		]	:= padr(oJTransfer[nX]:WarehouseEnd,TAMSX3("D3_LOCAL")[1])
											aJtrans[nX]["AddressEnd"		]	:= padr(oJTransfer[nX]:AddressOrigin,TAMSX3("D3_LOCALIZ")[1])
											aJtrans[nX]["SerialNumber"		]	:= padr(oJTransfer[nX]:SerialNumber,TAMSX3("D3_NUMSERI")[1])
											aJtrans[nX]["batch"				]	:= oJTransfer[nX]:Batch
											aJtrans[nX]["quantity"			]	:= nQtdEmb

					Next nX

				End Sequence

				ErrorBlock(oError)

				oJsonTrans["transfers"] := aJtrans
				aJtrans := {}

				If !lRet
					cResponse 	:= ''
				Endif

			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf

		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonTrans )
    Self:SetResponse( cResponse )
    If Len(aTransf) > 1
    	lMsErroAuto := .F.
	    MSExecAuto({|x| MATA261(x)},aTransf)
	    If !lMsErroAuto
			CONFIRMSX8()
		Else
	    	lRet := .F.
			cMsgErro := MostraErro(cPath,cFile)
			conout( cMsgErro )
			nStatusCode := 500
			cMessage := cMsgErro // "Erro durante a transferencia. Contate o administrador do sistema."
		EndIf
	Endif
EndIf
If !lRet
	If empty(cMessage) 
		 cMessage := STR0012  //'Erro Interno'
	EndIF
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
	Self:SetResponse( EncodeUTF8(cMessage) )
EndIf

If ValType(oJsonTrans) == "O"
	FreeObj(oJsonTrans)
	oJsonTrans := Nil
Endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de Documentos para conferencia.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET separations WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cAliasCB8         := GetnextAlias()
Local cResponse         := ''
Local oJsonSep 			:= JsonObject():New()
Local aJsonSep		  	:= {}
Local aJProdSep			:= {}
Local aJItemSep			:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cOrdem			:= ''
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local nCounProd			:= 0
Local cFilOld			:= cFilant

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA SEPARACAO ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetSep(3,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 10
				Self:PageSize := 10
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonSep 			:=  JsonObject():New()

	        cOrdem:= ''
	        While (cAlias)->(!EOF())
	        	If cOrdem <> (cAlias)->ORDEM
	        		nCount++
	        		cOrdem :=  (cAlias)->ORDEM

	        	ENdif


	            If (nCount >= nStart)
	                cOrdem :=  (cAlias)->ORDEM
	                nEntJson++
	                aAdd( aJsonSep,  JsonObject():New() )
	                cOrdem := (cAlias)->ORDEM
	                aJsonSep[nEntJson]["code"			]	:= AllTrim( (cAlias)->ORDEM 				)
					aJsonSep[nEntJson]["type"			]	:= AllTrim( (cAlias)->ORIGEM 				)
					aJsonSep[nEntJson]["activitys"		]	:= AllTrim( (cAlias)->TPSEP   				)
	               	aJsonSep[nEntJson]["status"			]	:= AllTrim( (cAlias)->STATUS     		    )

	                nCounReg := 0

	                While (cAlias)->(!EOF() .AND. (cAlias)->ORDEM == cOrdem)

	                	cDoc :=  (cAlias)->DOC
	                	nCounReg ++
	                	aAdd( aJItemSep,  JsonObject():New() )
	                	aJItemSep[nCounReg]["document"		]	:= (cAlias)->DOC
	                    aJItemSep[nCounReg]["name"			]	:= AllTrim( (cAlias)->NOME  		)
	                 	nCounProd:= 0
	                 	While (cAlias)->(!EOF()) .AND. (cAlias)->ORDEM == cOrdem .AND. (cAlias)->DOC == cDoc
	                 		nCounProd++
		                    aAdd( aJProdSep,  JsonObject():New() )
		                    aJProdSep[nCounProd]["code"			]	:= (cAlias)->CB8_PROD
		                    aJProdSep[nCounProd]["barcode"		]	:= AllTrim( (cAlias)->CODBAR					)
		                    aJProdSep[nCounProd]["item"			]	:= (cAlias)->CB8_ITEM	 				
		                    aJProdSep[nCounProd]["sequence"		]	:= (cAlias)->CB8_SEQUEN 				
		                    aJProdSep[nCounProd]["description"	]	:= EncodeUTF8( (cAlias)->DESCRI			 		)
		                    aJProdSep[nCounProd]["warehouse"	]	:= (cAlias)->CB8_LOCAL		   			
		                    aJProdSep[nCounProd]["address"		]	:= (cAlias)->CB8_LCALIZ     			
							aJProdSep[nCounProd]["serialnumber"	]	:= (cAlias)->CB8_NUMSER				
		                    aJProdSep[nCounProd]["batch"		]	:= (cAlias)->CB8_LOTECT 				
							aJProdSep[nCounProd]["sublot"		]	:= (cAlias)->CB8_NUMLOT				
		                    aJProdSep[nCounProd]["quantity"		]	:= (cAlias)->CB8_QTDORI

							// -------------------------------------------------------------------------------------------//
							// Futura implementação de alteração de Lot e SubLot										  //
							//--------------------------------------------------------------------------------------------//
							aJProdSep[nCounProd]["newSNumber"	]	:= CriaVar('CB8_NUMSER')   						
					        aJProdSep[nCounProd]["newbatch"		]	:= CriaVar('CB8_LOTECTL') 		 				
							aJProdSep[nCounProd]["newsublot"	]	:= CriaVar('CB8_NUMLOTE')						

		                	(cAlias)->(DbSkip())
		                End
		                aJItemSep[nCounReg]["products"] := aJProdSep
		                aJProdSep := {}
	                End

	                aJsonSep[nEntJson]["items"] := aJItemSep
					aJItemSep := {}


	                If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf

	            Else
	        		(cAlias)->(DbSkip())
	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonSep 				:=  JsonObject():New()
	    	oJsonSep["separations"]	:= aJsonSep
	    	oJsonSep["hasNext"] 	:= lHasNext

	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If Select(cAliasCB8) > 0
	(cAliasCB8)->(dbCloseArea())
Endif
If lRet
	oJsonSep["separations"]	:= aJsonSep
	oJsonSep["hasNext"] 	:= lHasNext
	cResponse := FwJsonSerialize( oJsonSep )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonSep) == "O"
	FreeObj(oJsonSep)
	oJsonSep := Nil
Endif

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetRastro()
Constroi um Query com a Seleção de produtos, uma com selação de armazens, uma com seleção de endereços

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetIsep(cAliasCB8,cOrdSep,cOrigem )
Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cSelect		:= ""
If cOrigem == '1'

	BeginSQL Alias cAliasCB8

		SELECT CB8_PROD,CB8_ITEM,CB8_PEDIDO DOC,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI,A1_NOME NOME, B1_DESC DESCRI, B1_CODBAR CODBAR
		FROM
			%Table:CB8% CB8
			LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
			LEFT JOIN %Table:SA1% SA1 On
				SA1.A1_FILIAL = %xFilial:SA1%
				AND SA1.A1_COD = SC5.C5_CLIENTE
				AND SA1.A1_LOJA = SC5.C5_LOJACLI
				AND SA1.%NotDel%
			INNER JOIN %Table:SB1% SB1 On
				SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = CB8.CB8_PROD
				AND SB1.B1_MSBLQL  <> '1'
				AND SB1.%NotDel%
		WHERE
			CB8.CB8_FILIAL = %xFilial:CB8%
			AND CB8.CB8_ORDSEP	= %Exp:cOrdSep%
			AND CB8.%NotDel%

		ORDER BY CB8_ORDSEP,CB8_PEDIDO
	EndSQL
ElseIf cOrigem == '2'

	cSelect		:= "% ,CB8_NOTA " +  cConcat + " CB8_SERIE DOC  %"

	BeginSQL Alias cAliasCB8

		SELECT CB8_PROD,CB8_ITEM,CB8_PEDIDO PEDIDO,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI,A1_NOME NOME, B1_DESC DESCRI, B1_CODBAR CODBAR
		%EXP:cSelect%
		FROM
			%Table:CB8% CB8
			LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
			LEFT JOIN %Table:SA1% SA1 On
				SA1.A1_FILIAL = %xFilial:SA1%
				AND SA1.A1_COD = SC5.C5_CLIENTE
				AND SA1.A1_LOJA = SC5.C5_LOJACLI
				AND SA1.%NotDel%
			INNER JOIN %Table:SB1% SB1 On
				SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = CB8.CB8_PROD
				AND SB1.B1_MSBLQL  <> '1'
				AND SB1.%NotDel%
		WHERE
			CB8.CB8_FILIAL = %xFilial:CB8%
			AND CB8.CB8_ORDSEP	= %Exp:cOrdSep%
			AND CB8.%NotDel%

		ORDER BY CB8_ORDSEP,CB8_NOTA
	EndSQL

Else
	BeginSQL Alias cAliasCB8

		SELECT CB8_PROD,CB8_ITEM,CB8_OP DOC,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI, B1_DESC DESCRI, B1_CODBAR CODBAR, ' ' NOME
		FROM
			%Table:CB8% CB8
			INNER JOIN %Table:SB1% SB1 On
				SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = CB8.CB8_PROD
				AND SB1.B1_MSBLQL  <> '1'
				AND SB1.%NotDel%
		WHERE
			CB8.CB8_FILIAL = %xFilial:CB8%
			AND CB8.CB8_ORDSEP	= %Exp:cOrdSep%
			AND CB8.%NotDel%

		ORDER BY CB8_ORDSEP,CB8_OP
	EndSQL
EndIf




return



//-------------------------------------------------------------------
/*/{Protheus.doc} PUT  Separations / ACDMOB
 Altera o Status da separacao ou finaliza no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD PUT Separations WSSERVICE ACDMOB
Local oJSepara		:= Nil
Local nStatusCode   := 500
Local cMessage	
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local cAlias        := GetnextAlias()
Local cAliasCB8     := GetnextAlias()
Local cOrdem		:= ''
Local nCounReg		:= 0
Local nTamProd		:= 	TamSX3("CB8_PROD")	[1]
Local nTamCTL		:=	TamSX3("CB8_LOTECT")[1]
Local nTamSCTL		:=	TamSX3("CB8_NUMLOT")[1]
Local nTamNserie	:=	TamSX3("CB8_NUMSER")[1]
Local nTamEnd		:=  TamSX3("CB8_LCALIZ")[1]
Local oJsonSep 		:= JsonObject():New()
Local aJProdSep		:= {}
Local aJItemSep		:= {}
Local nCounProd		:= 0
LOcal cDoc			:= ""
Local cFilOld		:= cFilant

Self:SetContentType("application/json")

If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA SEPARACAO ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
	ConOut( Replicate("R",80) )

	RpcClearEnv()

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL padr(cFilOld,TamSX3("B1_FILIAL")[1]) MODULO "SIGAACD" TABLES "SB1","SD1","SF1","SA1","CBE","CBA","CB7","CBB","CB8"
Endif

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0013 // 'Usuario nao cadastrado para separacao'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(cBody,@oJSepara)

			If !Empty( oJSepara )

				CB7->(DbSetOrder(1))
				If CB7->( DbSeek( padr(xFilial("CB7"),TAMSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )

					If oJSepara:Status == '2'
						If CB7->CB7_STATUS $ ('0|1')

							If AttIsMemberOf(oJSepara,"products")
								oJsonSep 				:=  JsonObject():New()
								oJsonSep["code"]		:= oJSepara:Code
								oJsonSep["type"]		:= oJSepara:Type
								oJsonSep["activitys"]	:= oJSepara:Activitys
								oJsonSep["status"]		:= oJSepara:Status

								cCodCB0				:= CriaVar('CB0_CODETI')

								For nX := 1 To Len( oJSepara:products )            //Parametros da funcao
									lRet := GravaCB8(oJSepara:products[nX]:quantity,;    //1  Quantidade 
													 oJSepara:products[nX]:Warehouse,;   //2  armazém
													Padr(oJSepara:products[nX]:Address,nTamEnd) ,; //3  endereço
													Padr(oJSepara:products[nX]:Code,nTamProd)  	,; //4  Produto separado
													Padr(oJSepara:products[nX]:Batch,nTamCTL)	,; //5  Lote
													Padr(oJSepara:products[nX]:sublot,nTamSCTL)	,; //6  S Lote
													Padr(oJSepara:products[nX]:newbatch,nTamCTL),; //7  novo  Lote 
													Padr(oJSepara:products[nX]:newsublot,nTamSCTL),; //8  numero de série
													Padr(oJSepara:products[nX]:serialnumber,nTamNserie)	,; //9 numero de série
													cCodCB0										,;//10 código etiqueta CB0
													Padr(oJSepara:products[nX]:newsnumber,nTamNserie),;//11 Novo numero de série 
													.T.											,;//12   lApp - ativa tratamento mobile
													oJSepara:products[nX]:Item					,;//13 item 
													CB7->CB7_ORDSEP								,;//14 ordem de separação
													oJSepara:Type								,;//15 tipo de gravação
													oJSepara:products[nX]:Document				,;//16  documento
													oJSepara:products[nX]:Sequence)      		  //17 sequencia do pedido/doc/op

									If lRet

										aAdd( aJProdSep,  JsonObject():New() )
					                    aJProdSep[nX]["code"			]	:= oJSepara:products[nX]:Code
					                    aJProdSep[nX]["barcode"			]	:= oJSepara:products[nX]:Barcode
					                    aJProdSep[nX]["item"			]	:= oJSepara:products[nX]:Item
					                    aJProdSep[nX]["sequence"		]	:= oJSepara:products[nX]:Sequence
					                    aJProdSep[nX]["description"		]	:= oJSepara:products[nX]:Description
					                    aJProdSep[nX]["warehouse"		]	:= oJSepara:products[nX]:Warehouse
					                    aJProdSep[nX]["address"			]	:= oJSepara:products[nX]:Address
										aJProdSep[nX]["serialnumber"	]	:= oJSepara:products[nX]:serialnumber
					                    aJProdSep[nX]["batch"			]	:= oJSepara:products[nX]:Batch
										aJProdSep[nX]["sublot"			]	:= oJSepara:products[nX]:sublot
					                    aJProdSep[nX]["quantity"		]	:= oJSepara:products[nX]:Quantity

										aJProdSep[nX]["newbatch"			]	:= oJSepara:products[nX]:newbatch
										aJProdSep[nX]["newsublot"		]	:= oJSepara:products[nX]:newsublot
										aJProdSep[nX]["newsnumber"		]	:= oJSepara:products[nX]:newsnumber



									Else
										exit
									Endif
								Next nX

								If lRet
									FimProc166(.T.,CB7->CB7_ORDSEP)
									oJsonSep["products"] := aJProdSep
									aJProdSep := {}

								Else
									cResponse := ''
								Endif
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0014 //"Dados da separacao nao enviados..."
							Endif
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0015  //"Separacao ja foi finalizada..."
						Endif
					ElseIf oJSepara:Status == '1'

						If CB7->CB7_STATUS == '0'

							GetSep(4,,,cAlias,Alltrim(Self:aURLParms[2]) )

							While (cAlias)->(!EOF())
								oJsonSep 		:=  JsonObject():New()

								cOrdem	:= (cAlias)->ORDEM

								oJsonSep["code"]		:= AllTrim( (cAlias)->ORDEM   				)
								oJsonSep["type"]		:= AllTrim( (cAlias)->ORIGEM   				)
								oJsonSep["activitys"]	:= AllTrim( (cAlias)->TPSEP   				)
								oJsonSep["status"]		:= oJSepara:Status


								While (cAlias)->(!EOF() .AND. (cAlias)->ORDEM == cOrdem)

				                	cDoc :=  (cAlias)->DOC
				                	nCounReg ++
				                	aAdd( aJItemSep,  JsonObject():New() )
				                	aJItemSep[nCounReg]["document"		]	:= (cAlias)->DOC
				                    aJItemSep[nCounReg]["name"			]	:= AllTrim( (cAlias)->NOME  		)
				                 	nCounProd:= 0
				                 	While (cAlias)->(!EOF()) .AND. (cAlias)->ORDEM == cOrdem .AND. (cAlias)->DOC == cDoc
				                 		nCounProd++
					                    aAdd( aJProdSep,  JsonObject():New() )
					                    aJProdSep[nCounProd]["code"			]	:= (cAlias)->CB8_PROD
					                    aJProdSep[nCounProd]["barcode"		]	:= AllTrim( (cAlias)->CODBAR					)
					                    aJProdSep[nCounProd]["item"			]	:= (cAlias)->CB8_ITEM	 				
					                    aJProdSep[nCounProd]["sequence"		]	:= (cAlias)->CB8_SEQUEN 				
					                    aJProdSep[nCounProd]["description"	]	:= EncodeUTF8((cAlias)->DESCRI			 		)
					                    aJProdSep[nCounProd]["warehouse"	]	:= (cAlias)->CB8_LOCAL		   			
					                    aJProdSep[nCounProd]["address"		]	:= (cAlias)->CB8_LCALIZ     			
										aJProdSep[nCounProd]["SerialNumber"	]	:= (cAlias)->CB8_NUMSER     			
					                    aJProdSep[nCounProd]["batch"		]	:= (cAlias)->CB8_LOTECT 				
										aJProdSep[nCounProd]["sublot"		]	:= (cAlias)->CB8_NUMLOT				
										aJProdSep[nCounProd]["quantity"		]	:= (cAlias)->CB8_QTDORI
									// -------------------------------------------------------------------------------------------//
									// Futura implementação de alteração de Lot e SubLot										  //
									//--------------------------------------------------------------------------------------------//
										aJProdSep[nCounProd]["newSNumber"	]	:= CriaVar('CB8_NUMSER')   						
					                    aJProdSep[nCounProd]["newbatch"		]	:= CriaVar('CB8_LOTECTL') 		 				
										aJProdSep[nCounProd]["newsublot"	]	:= CriaVar('CB8_NUMLOTE')						

					                	(cAlias)->(DbSkip())
					                End
					                aJItemSep[nCounReg]["products"] := aJProdSep
					                aJProdSep := {}
				                End


								oJsonSep["items"] := aJItemSep
								aJItemSep := {}

							End

							RecLock("CB7",.F.)
							CB7->CB7_STATUS := oJSepara:Status
							CB7->CB7_DTINIS := dDataBase
							CB7->CB7_HRINIS := StrTran(Time(),":","")
							CB7->CB7_CODOPE := cCodOpe
							CB7->(MsUnlock())

							If Select(cAlias) > 0
								(cAlias)->(dbCloseArea())
							Endif

						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0016 //"Separacao ja iniciada por outro separador ou finalizada..."

						EndIf

					Endif
				Else
					lRet 		:= .F.
					nStatusCode	:= 400
					cMessage 	:= STR0017 //"Separacao nao encontrada..."
				Endif
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf

		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005  //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonSep )
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, cMessage )
	Self:SetResponse( cMessage )
EndIf
If ValType(oJsonSep) == "O"
	FreeObj(oJsonSep)
	oJsonSep := Nil
Endif
Return( lRet )


/*/{Protheus.doc} retorna itens da nota/pre nota
 Altera o Status da separacao ou finaliza no protheus

@param	tabela Temp
@author	 	andre.maximo
@since		25/09/2019
@version	12.1.25
/*/

Static Function GetItNota(cTab)

BeginSQL Alias cTab

SELECT D1_ITEM,
       D1_COD,
       B1_CODBAR,
       D1_QUANT,
       D1_LOTECTL,
	   D1_DTVALID
FROM   %table:SD1% SD1
       JOIN %table:SB1% SB1
         	ON SB1.B1_FILIAL = %xfilial:SB1%
            AND SB1.B1_COD = SD1.D1_COD AND
            SB1.%NotDel%
WHERE  SD1.D1_FILIAL = %xfilial:SD1%
	   AND SD1.D1_DOC =  %Exp:SF1->F1_DOC%
       AND SD1.D1_Serie =%Exp:SF1->F1_SERIE%
       AND SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE%
       AND SD1.D1_LOJA = %Exp:SF1->F1_LOJA%
       AND SD1.%NotDel%
EndSQL

return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de produtos a endereçar.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Page         , numerico, Número da página para retorno dos dados
        PageSize	 , numerico, Quantidade de registros por página

@return cResponse	, Array, JSON com os endereçamentos disponíveis

@author	 	Marcia Junko
@since		15/03/2021
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET toAddressDetail WSRECEIVE SearchKey, Page, PageSize, Sku, Warehouse, Document, Serie, Sequence, Supplier, Store WSSERVICE ACDMOB
    Local oResponse     := JsonObject():New() 
	Local cJson         := ""
    Local lRet          := .F.

    Default Self:searchKey  := ""
    Default Self:page       := 1
    Default Self:pageSize   := 10
	Default Self:Sku    	:= ""
	Default Self:Warehouse  := ""
	Default Self:Document   := ""
	Default Self:Serie    	:= ""
	Default Self:Sequence   := ""
	Default Self:Supplier   := ""
	Default Self:Store   	:= ""


    
	lRet := DTLstToAddress( @oResponse, @Self )
    
    cJson := oResponse:TOJSON()

	oResponse := nil

    ::SetResponse( cJson )

	FreeObj( oResponse )
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de produtos a endereçar.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Page         , numerico, Número da página para retorno dos dados
        PageSize	 , numerico, Quantidade de registros por página

@return cResponse	, Array, JSON com os endereçamentos disponíveis

@author	 	Marcia Junko
@since		15/03/2021
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET docToAddr WSRECEIVE SearchKey, Page, PageSize WSSERVICE ACDMOB
    Local oResponse     := JsonObject():New() 
	Local cJson         := ""
    Local lRet          := .F.

    Default Self:searchKey	:= ""
    Default Self:page		:= 1
    Default Self:pageSize	:= 10

	cBody := ::GetContent()
    
	lRet := GRLstToAddress( @oResponse, @Self )
    
    cJson := oResponse:TOJSON()

	oResponse := nil

    ::SetResponse( cJson )

	FreeObj( oResponse )
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} DTLstToAddress
Função responsável pela busca das informações de pedidos de compras

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Marcia Junko
@since 15/03/2021
/*/
//----------------------------------------------------------------------------------
Static Function DTLstToAddress( oResponse, oSelf)
	Local aSvAlias		:= GetArea()
	Local aJResult		:= {}
	Local cQuery		:= ''
	Local cWhere		:= ''
	Local cTmpAlias     := GetnextAlias()
	Local cMessage      := STR0001 //'Erro Interno'
	Local cCodOpe   	:= CBRetOpe()
	Local nStatusCode	:= 500
	Local nRecord       := 0
	Local nRecStart		:= 0  // Define a quantidade de registros ja retornados
	Local nRecFinish	:= 0  // Define o registro máximo à retornar
	Local nLenResult	:= 0
	Local lHasNext		:= .F.
	Local lRet          := .T.
	Local oJResult		:= NIL
	Local oMessages		:= NIL

	If Empty( cCodOpe )
		nStatusCode := 403
		cMessage	:= STR0011 //'Usuario nao cadastrado como conferente'
		lRet		:= .F.
	EndIf

	If lRet
		oMessages  := JsonObject():New()

		nRecStart := ( ( oSelf:Page - 1 ) * oSelf:PageSize ) + 1

		nRecFinish := ( nRecStart + oSelf:PageSize ) - 1

		If !Empty( oSelf:searchKey )
			cWhere += " AND ( DA_PRODUTO LIKE '%" + oSelf:searchKey + "%' )"
		EndIf

		If !Empty( oSelf:Document )
			cWhere += " AND ( DA_DOC = '" + oSelf:Document + "' )"
		EndIf

		If !Empty( oSelf:Serie )
			cWhere += " AND ( DA_SERIE = '" + oSelf:Serie + "' )"
		EndIf

		If !Empty( oSelf:Sequence )
			cWhere += " AND ( DA_NUMSEQ = '" + oSelf:Sequence + "' )"
		EndIf

		If !Empty( oSelf:Supplier )
			cWhere += " AND ( DA_CLIFOR = '" + oSelf:Supplier + "' )"
		EndIf

		If !Empty( oSelf:Store )
			cWhere += " AND ( DA_LOJA = '" + oSelf:Store + "' )"
		EndIf

		If !Empty( oSelf:Warehouse )
			cWhere += " AND ( DA_LOCAL = '" + oSelf:Warehouse + "' )"
		EndIf

		cQuery := "SELECT "
		cQuery += "	DA_PRODUTO, "
		cQuery += "	B1_DESC, "
		cQuery += "	DA_QTDORI, "
		cQuery += "	DA_SALDO, "
		cQuery += "	DA_DATA, "
		cQuery += "	DA_LOTECTL, "
		cQuery += "	DA_NUMLOTE, "
		cQuery += "	NNR_DESCRI, "
		cQuery += "	DA_LOCAL, " 
		cQuery += " DA_DOC, "
		cQuery += " DA_SERIE, "
		cQuery += " DA_CLIFOR, "
		cQuery += " DA_LOJA, "
		cQuery += " DA_TIPONF, "
		cQuery += " DA_ORIGEM, "
		cQuery += " DA_NUMSEQ FROM "
		cQuery += " 	( " 
		
		cQuery += " 		SELECT ROW_NUMBER() OVER (ORDER BY DA_PRODUTO, "

		cQuery += "			DA_LOCAL, DA_NUMSEQ) AS LINHA, "
		
		cQuery += "	 		DA_PRODUTO, "
		cQuery += "	 		DA_QTDORI, "
		cQuery += "	 		B1_DESC, "
		cQuery += "	 		DA_SALDO, "
		cQuery += "	 		DA_DATA, "
		cQuery += "	 		DA_LOTECTL, "
		cQuery += "	 		DA_NUMLOTE, "
		cQuery += "	 		NNR_DESCRI, "
		cQuery += "	 		DA_LOCAL, " 
		cQuery += "	 		DA_DOC, "
		cQuery += "	 		DA_SERIE, "
		cQuery += "	 		DA_CLIFOR, "
		cQuery += "	 		DA_LOJA, "
		cQuery += "	 		DA_TIPONF, "
		cQuery += "	 		DA_ORIGEM, "
		cQuery += "	 		DA_NUMSEQ " 
		cQuery += "	 	FROM " + RetSQLName( "SDA" ) + " SDA "
		cQuery += "	 	INNER JOIN " + RetSQLName( "SB1" ) + " SB1 ON B1_COD = DA_PRODUTO AND B1_FILIAL = '"+XFILIAL("SB1")+"' AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "	 	INNER JOIN " + RetSQLName( "NNR" ) + " NNR ON NNR_CODIGO = DA_LOCAL AND NNR_FILIAL = '"+XFILIAL("NNR")+"' AND NNR.D_E_L_E_T_ = ' ' "
		cQuery += " 	WHERE DA_FILIAL = '" + xFilial( "SDA" ) + "' " 
		cQuery += " 		AND DA_SALDO > 0 "
		
		cQuery += IIF( !Empty( cWhere ), cWhere, '' ) + " " 
		
		cQuery += " 	AND SDA.D_E_L_E_T_ = ' ' " 

		cQuery += " ) TABLE_TEMP "

		cQuery += " WHERE LINHA BETWEEN " + Alltrim( Str( nRecStart ) ) + " AND " + Alltrim( Str( nRecFinish ) )

		cQuery := ChangeQuery( cQuery )
		MPSysOpenQuery( cQuery, cTmpAlias )

		If ( cTmpAlias )->( !EOF() )
			nRecord := Contar( cTmpAlias, "!Eof()" )
		
			( cTmpAlias )->( DBGoTop() )

			oJResult :=  JsonObject():New()

			While ( cTmpAlias )->( !Eof() )
				aAdd( aJResult,  JsonObject():New() )
				nLenResult := Len( aJResult )

				aJResult[ nLenResult ][ "product" ]			 := ( cTmpAlias )->DA_PRODUTO
				aJResult[ nLenResult ][ "productName" ]		 := AllTrim(( cTmpAlias )->B1_DESC)
				aJResult[ nLenResult ][ "originalAmount" ]	 := ( cTmpAlias )->DA_QTDORI 
				aJResult[ nLenResult ][ "balance" ]			 := ( cTmpAlias )->DA_SALDO 

				aJResult[ nLenResult ][ "date" ] 			 := ( cTmpAlias )->DA_DATA 
				aJResult[ nLenResult ][ "lot" ] 			 := ( cTmpAlias )->DA_LOTECTL
				aJResult[ nLenResult ][ "sublot" ] 			 := ( cTmpAlias )->DA_NUMLOTE
				aJResult[ nLenResult ][ "warehouse" ]		 := AllTrim(( cTmpAlias )->DA_LOCAL) +"-"+ UPPER(AllTrim(( cTmpAlias )->NNR_DESCRI))
				aJResult[ nLenResult ][ "document" ]		 := ( cTmpAlias )->DA_DOC
				aJResult[ nLenResult ][ "invoiceSerie" ]	 := ( cTmpAlias )->DA_SERIE
				aJResult[ nLenResult ][ "customerCode" ]	 := ( cTmpAlias )->DA_CLIFOR
				aJResult[ nLenResult ][ "customerUnit" ]	 := ( cTmpAlias )->DA_LOJA
				aJResult[ nLenResult ][ "invoiceType" ]		 := ( cTmpAlias )->DA_TIPONF
				aJResult[ nLenResult ][ "source" ]			 := ( cTmpAlias )->DA_ORIGEM
				aJResult[ nLenResult ][ "sequencialNumber" ] := ( cTmpAlias )->DA_NUMSEQ

				( cTmpAlias )->( DBSkip() )
			End

			If nRecord < oSelf:PageSize
				lHasNext := .F.
			else
				lHasNext := .T.
			EndIf
		Else
			oResponse :=  JsonObject():New()
			oResponse[ "address" ] := aJResult
			oResponse[ "hasNext" ] := lHasNext
		EndIf

		( cTmpAlias )->( DBCloseArea() )
	EndIf

	If lRet
		oResponse["address"]	:= aClone( aJResult )
		oResponse["hasNext"] 	:= lHasNext
	Else
		SetRestFault( nStatusCode, EncodeUTF8( cMessage ) )
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aJResult )
	FreeObj( oJResult )
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRLstToAddress
Função responsável pela busca das informações de pedidos de compras

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Marcia Junko
@since 15/03/2021
/*/
//----------------------------------------------------------------------------------
Static Function GRLstToAddress( oResponse, oSelf)
	Local aSvAlias		:= GetArea()
	Local aJResult		:= {}
	Local cQuery		:= ''
	Local cWhere		:= ''
	Local cTmpAlias     := GetnextAlias()
	Local cMessage      := STR0001 //'Erro Interno'
	Local cCodOpe   	:= CBRetOpe()
	Local nStatusCode	:= 500
	Local nRecord       := 0
	Local nRecStart		:= 0  // Define a quantidade de registros ja retornados
	Local nRecFinish	:= 0  // Define o registro máximo à retornar
	Local nLenResult	:= 0
	Local lHasNext		:= .F.
	Local lRet          := .T.
	Local oJResult		:= NIL
	Local oMessages		:= NIL

	If Empty( cCodOpe )
		nStatusCode := 403
		cMessage	:= STR0011 //'Usuario nao cadastrado como conferente'
		lRet		:= .F.
	EndIf

	If lRet
		oMessages  := JsonObject():New()

		nRecStart := ( ( oSelf:Page - 1 ) * oSelf:PageSize ) + 1

		nRecFinish := ( nRecStart + oSelf:PageSize ) - 1

		If !Empty( oSelf:searchKey )
			cWhere += " AND (( DA_DOC LIKE '%" + oSelf:searchKey + "%' ) OR ( DA_CLIFOR LIKE '%" + oSelf:searchKey + "%' ))"
		EndIf

		cQuery := "SELECT "
		cQuery += "	DA_DATA, "
		cQuery += "	DA_LOTECTL, "
		cQuery += "	DA_NUMLOTE, "
		cQuery += " DA_DOC, "
		cQuery += " DA_SERIE, "
		cQuery += " DA_CLIFOR, "
		cQuery += " DA_LOJA, "
		cQuery += " DA_TIPONF, "
		cQuery += " DA_ORIGEM FROM "
		cQuery += " 	( " 
		
		cQuery += " 		SELECT ROW_NUMBER() OVER (ORDER BY "

		cQuery += "			DA_DATA) AS LINHA, "
		
		cQuery += "	 		DA_DATA, "
		cQuery += "	 		DA_LOTECTL, "
		cQuery += "	 		DA_NUMLOTE, "
		cQuery += "	 		DA_DOC, "
		cQuery += "	 		DA_SERIE, "
		cQuery += "	 		DA_CLIFOR, "
		cQuery += "	 		DA_LOJA, "
		cQuery += "	 		DA_TIPONF, "
		cQuery += "	 		DA_ORIGEM "
		cQuery += "	 	FROM " + RetSQLName( "SDA" ) + " SDA "
		cQuery += " 	WHERE DA_FILIAL = '" + xFilial( "SDA" ) + "' " 
		cQuery += " 		AND DA_SALDO > 0 "
		
		cQuery += IIF( !Empty( cWhere ), cWhere, '' ) + " " 
		
		cQuery += " 	AND SDA.D_E_L_E_T_ = ' ' "

		cQuery += "GROUP BY "
		cQuery += "	DA_DATA, "
		cQuery += "	DA_LOTECTL, "
		cQuery += "	DA_NUMLOTE, " 
		cQuery += " DA_DOC, "
		cQuery += " DA_SERIE, "
		cQuery += " DA_CLIFOR, "
		cQuery += " DA_LOJA, "
		cQuery += " DA_TIPONF, "
		cQuery += " DA_ORIGEM "

		cQuery += " ) TABLE_TEMP "

		cQuery += " WHERE LINHA BETWEEN " + Alltrim( Str( nRecStart ) ) + " AND " + Alltrim( Str( nRecFinish ) )

		cQuery := ChangeQuery( cQuery )
		MPSysOpenQuery( cQuery, cTmpAlias )

		If ( cTmpAlias )->( !EOF() )
			nRecord := Contar( cTmpAlias, "!Eof()" )
		
			( cTmpAlias )->( DBGoTop() )

			oJResult :=  JsonObject():New()

			While ( cTmpAlias )->( !Eof() )
				aAdd( aJResult,  JsonObject():New() )
				nLenResult := Len( aJResult )

				aJResult[ nLenResult ][ "date" ] 			 := ( cTmpAlias )->DA_DATA 
				aJResult[ nLenResult ][ "lot" ] 			 := ( cTmpAlias )->DA_LOTECTL
				aJResult[ nLenResult ][ "sublot" ] 			 := ( cTmpAlias )->DA_NUMLOTE
				aJResult[ nLenResult ][ "warehouse" ]		 := ""
				aJResult[ nLenResult ][ "document" ]		 := ( cTmpAlias )->DA_DOC
				aJResult[ nLenResult ][ "invoiceSerie" ]	 := ( cTmpAlias )->DA_SERIE
				aJResult[ nLenResult ][ "customerCode" ]	 := ( cTmpAlias )->DA_CLIFOR

				If AllTrim(( cTmpAlias )->DA_TIPONF) $ "NB "
					aJResult[ nLenResult ][ "customerName" ]	 := AllTrim(Posicione("SA2",1,XFILIAL("SA2")+( cTmpAlias )->DA_CLIFOR+( cTmpAlias )->DA_LOJA, "A2_NOME"))
				Else
					aJResult[ nLenResult ][ "customerName" ]	 := AllTrim(Posicione("SA1",1,XFILIAL("SA1")+( cTmpAlias )->DA_CLIFOR+( cTmpAlias )->DA_LOJA, "A1_NOME"))
				EndIf
				aJResult[ nLenResult ][ "customerUnit" ]	 := ( cTmpAlias )->DA_LOJA
				aJResult[ nLenResult ][ "invoiceType" ]		 := ( cTmpAlias )->DA_TIPONF

				If AllTrim((cTmpAlias)->DA_ORIGEM) == 'SD5'
					cOrigem := "REQ. LOTE"
				ElseIf  AllTrim((cTmpAlias)->DA_ORIGEM) == 'SD1'
					cOrigem := "DOC. ENTRADA"
				ElseIf  AllTrim((cTmpAlias)->DA_ORIGEM) == 'SD3'
					cOrigem := "MOV. INTERNA"
				ElseIf  AllTrim((cTmpAlias)->DA_ORIGEM) == 'SB9'
					cOrigem := "SLD. INICIAL"
				Else
					cOrigem := (cTmpAlias)->DA_ORIGEM
				EndIf

				aJResult[ nLenResult ][ "source" ]			 := cOrigem
				aJResult[ nLenResult ][ "sequencialNumber" ] := ""

				( cTmpAlias )->( DBSkip() )
			End

			If nRecord < oSelf:PageSize
				lHasNext := .F.
			else
				lHasNext := .T.
			EndIf
		Else
			oResponse :=  JsonObject():New()
			oResponse[ "address" ] := aJResult
			oResponse[ "hasNext" ] := lHasNext
		EndIf

		( cTmpAlias )->( DBCloseArea() )
	EndIf

	If lRet
		oResponse["address"]	:= aClone( aJResult )
		oResponse["hasNext"] 	:= lHasNext
	Else
		SetRestFault( nStatusCode, EncodeUTF8( cMessage ) )
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aJResult )
	FreeObj( oJResult )
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} POST  Address / ACDMOB
Serviço de inclusão de endereçamento de produto.

@return boolean, identifica se o endereçamento foi gerado.
@author	Marcia Junko
@since	15/03/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST ToAddress WSSERVICE ACDMOB
    Local cBody     As Character
    Local cJson     As Character
    Local lRet      As Logical
    Local oToAddress As Object

    cBody 	   := ::GetContent()
    oToAddress  := JsonObject():New()

    lRet := NewAddress( @oToAddress, cBody )

    cJson := FWJsonSerialize( oToAddress, .F., .F., .T. )
    ::SetResponse( cJson )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NewAddress
Cria o endereçamento do produto

@param oToAddress, object, Objeto da resposta
@param cBody, caracter, corpo da requisição

@return boolean, identifica se o endereçamento foi gerado.
@author	Marcia Junko
@since	15/03/2021
/*/
//-------------------------------------------------------------------
Static Function NewAddress( oToAddress, cBody )
	Local aHeader 		:= {}
	Local aItem   		:= {}
	Local aAddress		:= {}
	Local aDiverg		:= {}
	Local cCatch		:= ''
	Local cProduct 		:= ''
	Local cWarehouse	:= ''
	Local cAddress		:= ''
	Local cSeqNumber	:= ''
	Local cMessage		:= ''
	Local cPath     	:= ''
	Local cFile     	:= ''
	Local cIdent 		:= ''
	Local cItem			:= ''
	Local nAmount		:= 0
	Local nCodeSize		:= 0
	Local nWareSize		:= 0
	Local nSeqSize		:= 0
	Local nStatusCode	:= 0
	Local lRet			:= .T.
	Local oJsonTmp		:= NIL
	Local oMessages		:= NIL

    Private	lMsErroAuto := .F.

	oJsonTmp := JsonObject():New()
	oMessages := JsonObject():New()
	If !Empty( cBody )
		cCatch   := oJsonTmp:FromJSON( cBody )
		If cCatch == Nil
			SDA->( DbSetOrder(1) )  //DA_FILIAL + DA_PRODUTO + DA_LOCAL + DA_NUMSEQ + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA -- SALDO A DISTRIBUIR

			cProduct := oJsonTmp[ "productCode" ]
			cWarehouse := oJsonTmp[ "warehouse" ]
			cAddress := oJsonTmp[ "address" ]
			cSeqNumber := oJsonTmp[ "sequenceNumber" ]
			cItem := NextSDBItem( cProduct, cWarehouse, cSeqNumber )
			nAmount := oJsonTmp[ "amount" ]

			nCodeSize	:= TamSX3( "DA_PRODUTO" )[1]
			nWareSize	:= TamSX3( "DA_LOCAL" )[1]
			nSeqSize	:= TamSX3( "DA_NUMSEQ" )[1]

			If ( SDA->( MSSeek( xFilial( "SDA" ) + Padr( cProduct, nCodeSize ) + Padr( cWarehouse, nWareSize ) + Padr( cSeqNumber, nSeqSize ) ) ) ) 
				aHeader := { { "DA_PRODUTO", cProduct, Nil }, ;	  
							{ "DA_NUMSEQ", cSeqNumber, Nil } }

				aItem := { { "DB_ITEM", cItem, Nil }, ;                   
						{ "DB_ESTORNO", " ", Nil }, ;                   
						{ "DB_LOCALIZ", cAddress, Nil }, ;                   
						{ "DB_DATA", dDataBase, Nil }, ;                   
						{ "DB_QUANT", nAmount, Nil } }       

				aadd( aAddress, aItem )

				MSExecAuto( { | x, y, z | MATA265( x, y, z ) }, aHeader, aAddress, 3 ) 

				If !lMsErroAuto
					oToAddress[ "productCode" ]	:= cProduct
					oToAddress[ "warehouse" ] := cWarehouse
					oToAddress[ "address" ]	:= cAddress
					oToAddress[ "sequenceNumber" ] := cSeqNumber
					oToAddress[ "item" ] := cItem
					oToAddress[ "amount" ] := nAmount
				Else
					lRet := .F.
					nStatusCode := 403
					cPath := GetSrvProfString( "StartPath", "" )
					cFile := NomeAutoLog()
					cMessage := MostraErro( cPath, cFile )	

					cIdent := SDA->( DA_FILIAL + DA_PRODUTO + DA_LOCAL + DA_NUMSEQ + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA )

					Aadd( aDiverg, {'D3V_ORIGEM', '5'} )
					Aadd( aDiverg, {'D3V_MOTIVO', '5' } )
					Aadd( aDiverg, {'D3V_IDENT', cIdent } )
					Aadd( aDiverg, {'D3V_INFO', cMessage } )

					ACDM020GRV( aDiverg )
				EndIf
			Else
				nStatusCode := 400
        		cMessage := STR0024 //"Solicitação de endereçamento não localizada."
				lRet := .F.
			EndIf
		Else
			nStatusCode := 400
			cMessage := cCatch 
			lRet := .F.
		EndIf
	Else
		nStatusCode := 400
		cMessage := STR0025 //"Dados para endereçamento não foram informados." 
		lRet := .F.
	EndIf

    If !lRet
		oMessages[ "errorCode" ] := nStatusCode
        oMessages[ "errorMessage" ] := EncodeUTF8( cMessage )
        oToAddress := oMessages
        SetRestFault( oMessages["errorCode"], oMessages["errorMessage"] )
    EndIf

	FWFreeArray( aHeader )
	FWFreeArray( aItem )
	FWFreeArray( aAddress )
	FWFreeArray( aDiverg )
	FreeObj( oJsonTmp )
	FreeObj( oMessages )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NextSDBItem
Retorna o próximo sequencial para endereçar o produto

@param cProduct, caracter, código do produto
@param cWarehouse, caracter, código do armazén
@param cNumSeq, caracter, número sequencial

@return caracter, sequencial do endereçamento
@author	Marcia Junko
@since	15/03/2021
/*/
//-------------------------------------------------------------------
Static Function NextSDBItem( cProduct, cWarehouse, cNumSeq ) 
    Local cQuery := ''
    Local cTmp := GetNextAlias()
    Local nItem := 0

    cQuery := "SELECT MAX(DB_ITEM) AS ITEM FROM " + RetSQLName( "SDB" ) + " SDB " + ;
        " WHERE DB_FILIAL = '" + xFilial( "SDB" ) + "' " + ;
            " AND DB_PRODUTO = '" + cProduct + "' " + ;
			" AND DB_LOCAL = '" + cWarehouse + "' " + ;
            " AND DB_NUMSEQ = '" + cNumSeq + "' " + ;
            " AND SDB.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmp )

    If ( cTmp )->( !EOF() )
        nItem := Val( ( cTmp )->ITEM )
    Endif

    nItem++

    ( cTmp )->( DbCloseArea() )
Return StrZero( nItem, 4 )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStsInv
Retorna retorna o status da contagem verificando quantidade do
produto em estoque.

@param cCode, caracter, código do produto
@param cWarehouse, caracter, código do armazem
@param cBatch, caracter, código do lote
@param nQtd, numeric, quantidade

@return caracter, status da CBA
@author	Leonardo Kichitaro
@since	20/09/2021
/*/
//-------------------------------------------------------------------
Static Function GetStsInv(cCode, cWarehouse, cBatch, nQtd, cStatus)

Local cRet		:= ''
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSB8	:= SB8->(GetArea())

If Empty(cStatus) .Or. cStatus == '4'
	If !Empty(cBatch)
		SB8->(dbSetOrder(3))
		If SB8->(dbSeek(xFilial("SB8")+cCode+cWarehouse+cBatch))
			If SB8->B8_SALDO - SB8->B8_EMPENHO <> nQtd
				cRet := '3'
			Else
				cRet := '4'
			EndIf
		EndIf
	Else
		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2")+cCode+cBatch))
			If SaldoSB2() <> nQtd
				cRet := '3'
			Else
				cRet := '4'
			EndIf
		EndIf
	EndIf
Else
	cRet := cStatus
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSB8)

Return cRet
