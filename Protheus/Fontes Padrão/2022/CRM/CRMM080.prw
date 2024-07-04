#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "CRMM080.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMENTITIES

Classe responsável por retornar uma listagem de clientes/prospect do usuário autenticado
no appCRM.

@author	Squad CRM/Faturamento
@since		01/02/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSRESTFUL CRMMENTITIES DESCRIPTION STR0001  // "Retorna uma lista das entidades SA1 - Cliente/ SUS - Prospect"

	WSDATA EntityType	AS STRING	OPTIONAL
	WSDATA SearchKey 	AS STRING	OPTIONAL
	WSDATA Fields		AS STRING	OPTIONAL
	WSDATA UserId       AS STRING   OPTIONAL
	WSDATA Language     AS STRING   OPTIONAL
	WSDATA Page			AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
	WSDATA Content      AS BOOLEAN  OPTIONAL

	WSMETHOD GET Main;
	DESCRIPTION STR0001;  // "Retorna uma lista das entidades SA1 - Cliente/ SUS - Prospect"
	WSSYNTAX "/CRMMENTITIES/{SearchKey, Fields, EntityType, Language, Page, PageSize}"

	WSMETHOD GET Fields;
	DESCRIPTION STR0002;  // "Retorna uma lista de campos de dicionário das entidades SA1 - Cliente/ SUS - Prospect"
	WSSYNTAX "/CRMMENTITIES/Fields/{EntityType}/{Fields, Language}";
	PATH "/Fields/{EntityType}"

END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/CRMMENTITIES
Retorna uma lista das entidades cliente e prospects do usuário autenticado no appCRM.

@param  EntityType - caracter - Informa a entidade que será utilizada para retorno da lista. Nulo retorna todos.
        SearchKey  - caracter - Chave de pesquisa para ser considerada na consulta.
        Fields     - caracter - Lista os campos para montagem da consulta.
        Language   - caracter - Idioma de retorno dos campos.
		Page       - numérico - Posição da página para ser considerada na consulta. Ex: a partir da página 3.
        PageSize   - numérico - Quantidade de registros a ser retornado na consulta. Ex: 10 registros.

@return cResponse  - caracter - JSON com os clientes/prospects.

@author     Squad CRM/Faturamento
@since		01/02/2018
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE UserId, EntityType, SearchKey, Fields, Language, Page, PageSize WSSERVICE CRMMENTITIES

    Local cAlias            := ''
    Local cResponse         := ''
    Local lContent          := .T.
    Local lListDetail       := .T.
    Local aFields           := {}
	Local aSA1Fields        := {}
	Local aSUSFields        := {}
    Local nStatusCode       := 500
    Local cMessage          := STR0003  // 'Erro Interno'
    Local lRet              := .T.
    Local nCount            := 0
    Local nRecord           := 0
    Local nEntJson          := 0
    Local nStart            := 0

    Default Self:UserId     := ''
    Default Self:EntityType := ''
    Default Self:SearchKey  := ''
    Default Self:Fields     := ''
    Default Self:Language   := 'pt'
    Default Self:Page       := 1
    Default Self:PageSize   := 20

    Self:SetContentType("application/json")

    If Empty(Self:UserId)
        Self:UserId := __cUserId
    EndIf

    If (Positivo(Self:Page) .And. Positivo(Self:PageSize))

        If !Empty(Self:UserId)

			If Self:UserId <> "000000"
				AO3->(DBSetOrder(1))
				If AO3->(MSSeek(xFilial("AO3") + Self:UserId))
					If Empty(AO3->AO3_VEND)
						lRet := .F.
						nStatusCode := 400
						cMessage	:= STR0004 // "Nao foi possível identificar o vendedor deste usuário..."
					EndIf
				Else
					lRet := .F.
					nStatusCode	:= 400
					cMessage 	:= STR0005 // "Nao foi possível identificar este usuário como usuário do CRM..."
				EndIf
			EndIf

            If lRet                
				cAlias := MPSysOpenQuery(BuildQry(Self:EntityType, Self:SearchKey))
                If (cAlias)->(!EOF())

                    COUNT TO nRecord
                    (cAlias)->(DBGoTop())

                    //-------------------------------------------------------------------
					// Limita a página.
					//-------------------------------------------------------------------
					If Self:PageSize > 30
						Self:PageSize := 20
					EndIf
                    If Self:Page > 1
                        nStart := ((Self:Page-1) * Self:PageSize) + 1
                    EndIf

					// Acerta os nomes dos campos.
					If !Empty(Self:Fields)
						aFields := StrToArray(Alltrim(UPPER(Self:Fields)), ",")
						For nCount := 1 to len(aFields)
							aAdd(aSA1Fields, "A1_" + SubStr(aFields[nCount], 4))
							aAdd(aSUSFields, "US_" + SubStr(aFields[nCount], 4))
						Next nCount
					Endif

					nCount := 0
                    cResponse += '{"entities":['
                    While (cAlias)->(!EOF())

                        nCount++

                        If (nCount >= nStart)
                            nEntJson++

                            cResponse += '{'
                            cResponse +=    '"type":"'   +              (cAlias)->ENTITY                    + '",'
                            cResponse +=    '"branch":"' +              ( cAlias )->BRANCH                  + '",'
                            cResponse +=    '"number":"' +              (cAlias)->COD                       + '",'
                            cResponse +=    '"unit":"' +                (cAlias)->UNIT                      + '",'
                            cResponse +=    '"name":"'   + EncodeUTF8(  AllTrim( (cAlias)->NAME      ) )    + '",'
                            cResponse +=    '"fields":['

                            If  AllTrim((cAlias)->ENTITY) == 'SA1'
			                    SA1->(DbSetOrder(1))
                                If SA1->(DbSeek(xFilial('SA1') + (cAlias)->(COD + UNIT), .F.))
                                    cResponse += CRMXGetJFields('SA1', Self:Language, aSA1Fields, lContent, lListDetail)
                                EndIf
                            Else
			                    SUS->(DbSetOrder(1))
                                If SUS->(DbSeek(xFilial('SUS') + (cAlias)->(COD + UNIT), .F.))
                                    cResponse += CRMXGetJFields('SUS', Self:Language, aSUSFields, lContent, lListDetail)
                                EndIf
                            EndIf

                            cResponse += ']}'                            
                            
                        EndIf
                       
                        (cAlias)->(DbSkip())

                        If (cAlias)->(!eof()) .And. nEntJson < Self:PageSize .And. nCount >= nStart
                            cResponse += ', '                        
                        Endif

                        If ( nEntJson == Self:PageSize )
                            Exit
						EndIf
                        
                    EndDo

                    If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord
                        cResponse += ' ], "hasNext":' + IIF((cAlias)->(!eof()),"true","false")  + '}'
                    Else
                        cResponse += ' ], "hasNext":' + IIF((cAlias)->(!eof()),"true","false")  + '}'
                    EndIf
                Else
                    cResponse := '{"entities":[ ], "hasNext":false}'
                EndIf
				(cAlias)->(dbCloseArea())
            EndIf
        Else
            lRet := .F.
            nStatusCode	:= 400
			cMessage 	:= STR0007 // "Nao foi possível identificar usuário..."
        EndIf
    Else
        lRet := .F.
        nStatusCode := 400
        cMessage := STR0008 // "Parâmetros de paginação com valores Negativos..."
    EndIf

    If lRet
        Self:SetResponse(cResponse)
    Else
        SetRestFault(nStatusCode, EncodeUTF8(cMessage))
    EndIf

	Asize(aFields, 0)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/CRMMENTITIES/Fields
Retorna uma lista de  campos do dicionario X3 das entidades Cliente/Prospect.

@param  EntityType - caracter - Informa a entidade que será utilizada para retorno da lista.
        Fields     - caracter - Lista os campos para montagem da consulta.
        Language   - caracter - Idioma de retorno dos campos.

@return Response   - caracter - JSON com os campos da tabelas SA1 - Clientes OU SUS - Prospects.

@author     Squad CRM/Faturamento
@since		01/02/2018
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Fields PATHPARAM EntityType WSRECEIVE Fields, Language WSSERVICE CRMMENTITIES

    Local lRet       := .T.
    Local cEntAlias  := Upper(Self:aURLParms[2])
    Local cMsgError  := ''
	Local aFields    := {}

    Default Self:Language := 'pt'

    Self:SetContentType("application/json")

    If cEntAlias == 'SA1' .Or. cEntAlias == 'SUS'
		If !Empty(Self:Fields)
			aFields := StrToArray(Alltrim(UPPER(Self:Fields)), ",")
		Endif

		Self:SetResponse(CRMXGetJFields(cEntAlias, Self:Language, aFields))
    Else
        lRet := .F.
        cMsgError := STR0009 + ' ' + cEntAlias + ' ' // 'A Entidade informada:'
        cMsgError += STR0010 + ' ' // 'é inválida.'
        cMsgError += STR0011 // 'Apenas os valores SA1 ou SUS são permitidos'
        SetRestFault(400, EncodeUTF8(cMsgError))
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQry()
Constroi um Query para ser utilizada no DBUseAerea

@param  cSearch     - caracter - Define quais valores serão utilizados como chave de consulta.
        cAliasQry   - caracter - Define qual alias o usuário do AppCRM definiu para consulta no arquivo de dados.

@return cQuery  	- caracter - Retorna para o usuário uma query pronta para realizar a consulta de acordo com o alias
"SA1", "SUS" ou "Todos" quando não informado nada.

@author	Squad CRM/Faturamento
@since		01/02/2018
@version	12.1.17
/*/
//-------------------------------------------------------------------
Static Function BuildQry(cAliasQry, cSearch)

    Local cQuery        := ''
    Local cFilterSA1    := ''
    Local cFilterSUS    := ''

	// Variável usada pela função CRMXFilEnt().
	Private nModulo    := 73

    Default cAliasQry  := ''
    Default cSearch    := ''

    cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))

    cQuery := "SELECT 'SA1' ENTITY, A1_FILIAL BRANCH, A1_COD COD, A1_LOJA UNIT, A1_NOME NAME FROM "
    cQuery += RetSqlName("SA1") + " SA1 "

    cFilterSA1 := CRMXFilEnt("SA1", .T.)
    If !Empty(cFilterSA1)
        cQuery += "INNER JOIN " + RetSqlName("AO4") + " AO4 on AO4.D_E_L_E_T_ = '' "
		cQuery += "and AO4.AO4_FILIAL = '" + xFilial('AO4') + "' " + CRLF
		cQuery += "and AO4.AO4_ENTIDA = 'SA1' " + CRLF
        cQuery += "and AO4.AO4_CHVREG = A1_FILIAL || A1_COD || A1_LOJA "
        cQuery += "and " + cFilterSA1
    EndIf

    cQuery += " WHERE A1_VEND <> ' ' AND "

    If cAliasqry == 'SUS'
        cQuery += " A1_COD = ' ' AND A1_LOJA = ' ' AND "
    EndIf

    If !Empty(cSearch)
        cQuery  += "( A1_COD    LIKE '%"   + cSearch + "%' OR"
        cQuery  += "  A1_NOME   LIKE '%"   	+ cSearch + "%' OR"
        cQuery  += "  A1_NREDUZ LIKE '%"   	+ cSearch + "%' OR"
        cQuery  += "  A1_CGC    LIKE '%"   	+ cSearch + "%' ) AND  "
    EndIf

    cQuery += " A1_FILIAL = '" + xFilial('SA1') + "' AND SA1.D_E_L_E_T_ = ''"

    cQuery += " UNION "

    cQuery += " SELECT 'SUS' ENTITY, US_FILIAL BRANCH, US_COD COD, US_LOJA UNIT, US_NOME NAME FROM "
    cQuery += RetSqlName("SUS") + " SUS "

    cFilterSUS := CRMXFilEnt("SUS", .T.)
    If !Empty(cFilterSUS)
        cQuery += "INNER JOIN " + RetSqlName("AO4") + " AO4 on AO4.D_E_L_E_T_ = '' "
		cQuery += "and AO4.AO4_FILIAL = '" + xFilial('AO4') + "' " + CRLF
		cQuery += "and AO4.AO4_ENTIDA = 'SUS' " + CRLF
        cQuery += "and AO4.AO4_CHVREG = US_FILIAL || US_COD || US_LOJA "
        cQuery += "and " + cFilterSUS
    EndIf

    cQuery += " WHERE US_VEND <> ' ' AND US_CODCLI = ' ' AND US_LOJACLI = ' ' AND "

    If cAliasqry == 'SA1'
        cQuery += " US_COD = ' ' AND US_LOJA = ' ' AND "
    EndIf

    If !Empty(cSearch)
        cQuery  += "( US_COD    LIKE '%"    + cSearch + "%' OR"
        cQuery  += "  US_NOME   LIKE '%"   	+ cSearch + "%' OR"
        cQuery  += "  US_NREDUZ LIKE '%"   	+ cSearch + "%' OR"
        cQuery  += "  US_CGC    LIKE '%"   	+ cSearch + "%') AND "
    EndIf

    cQuery += " US_FILIAL = '" + xFilial('SUS') + "' AND SUS.D_E_L_E_T_ = ''"

    cQuery += " order by 1, 2, 3, 4 "

Return ChangeQuery(cQuery)
