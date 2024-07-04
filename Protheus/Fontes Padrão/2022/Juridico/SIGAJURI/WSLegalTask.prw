#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSLEGALTASK.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLegalTask
Métodos WS do Jurídico para integração com o LegalTask.

@author SIGAJURI
@since 11/03/17
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL JURFWREST DESCRIPTION STR0001 //"WS de Integração com LegalTask"

	WSDATA page               AS INTEGER
	WSDATA pageSize           AS INTEGER
	WSDATA codFup             AS STRING
	WSDATA codDoc             AS STRING
	WSDATA periFilt           AS STRING
	WSDATA cateFilt           AS STRING
	WSDATA srchKey            AS STRING
	WSDATA fields             AS STRING
	WSDATA searchKey          AS STRING
	WSDATA numPro             AS STRING
	WSDATA partCont           AS STRING
	WSDATA dataIni            AS STRING
	WSDATA dataFim            AS STRING
	WSDATA status             AS STRING
	WSDATA filterFup          AS STRING
	WSDATA filtrosAtividades  AS STRING
	WSDATA lWSTlegal          AS BOOLEAN
	WSDATA showTaskMembers    AS BOOLEAN

	// Métodos GET
	WSMETHOD GET ListFups      DESCRIPTION STR0002  PATH "fup"             PRODUCES APPLICATION_JSON //"Lista de Follow-ups"
	WSMETHOD GET DetailFup     DESCRIPTION STR0003  PATH "fup/{codFup}"    PRODUCES APPLICATION_JSON //"Detalhes do Follow-up"
	WSMETHOD GET ReturnDocsFup DESCRIPTION STR0004  PATH "docs/{codDoc}"   PRODUCES APPLICATION_JSON //"Retorno de Documentos do Follow-up"
	WSMETHOD GET ListTypeFup   DESCRIPTION STR0005  PATH "categories"      PRODUCES APPLICATION_JSON //"Lista de categorias do Follow-up"
	WSMETHOD GET ListStatsFups DESCRIPTION STR0006  PATH "status"          PRODUCES APPLICATION_JSON //"Lista de Resultados do Follow-up"
	WSMETHOD GET RelFUP        DESCRIPTION STR0032  PATH "exportTarefa"    PRODUCES APPLICATION_JSON //"Realiza a exportação de tarefas a vencer"
	WSMETHOD GET RelPDF        DESCRIPTION STR0033  PATH "exportPauta"     PRODUCES APPLICATION_JSON //"Realiza a exportação de relatório em pauta das tarefas a vencer"
	
	// Métodos POST
	WSMETHOD POST CreateDocsFup DESCRIPTION STR0007  PATH "fup/{codFup}/docs"  PRODUCES APPLICATION_JSON //"Criação de Documentos no Follow-up"

	// Métodos PUT
	WSMETHOD PUT  UpdateFup     DESCRIPTION STR0008  PATH "fup/{codFup}"       PRODUCES APPLICATION_JSON //"Atualização do Follow-up"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListFups
Lista de Follow-ups

@param [Opcional] page:      Numero da Página
@param [Opcional] pageSize:  Quantidade de registros por pagina
@param [Opcional] periFilt:  Período filtrado (1: Hoje/ 2:Amanhã/ 3:Semana Corrente/ 4:Atrasados em aberto /
							 				5: Periodo de 7 dias a contar com o dia atual )
@param [Opcional] cateFilt:  Categoria do Follow-up
@param [Opcional] fields:    Nome do campo
@param [Opcional] searchKey: Valor a ser pesquisado nos campos  NTA_DESC, NQS_DESC, NUQ_NUMPRO E NT9_NOME
@param [Opcional] numPro:    Número do processo
@param [Opcional] cDataIni:  Data inicio da busca
@param [Opcional] dataFim:   Data final da busca
@param [Opcional] status:    Status do FUP
@param [Opcional] lWSTlegal: Vem do totvs legal?

@author SIGAJURI
@since 11/03/17
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/fup
@example [Com Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/fup?page=1&pageSize=10&periFilt=1&cateFilt=1
@example [Com Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/fup?page=1&pageSize=10&periFilt=1&cateFilt=1&fields=sigla,pedidos,numpro
/*/
//-------------------------------------------------------------------
WSMETHOD GET ListFups WSRECEIVE page, pageSize, periFilt, cateFilt, fields, searchKey, numPro, dataIni, dataFim, status, lWSTlegal, filterFup WSREST JURFWREST
Local aRet       := { .T., Nil, ""}
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local cPeriFilt  := Self:periFilt
Local nCateFilt  := Self:cateFilt
Local cFields    := Self:fields
Local cSearchKey := Self:searchKey
Local cNumPro    := Self:numpro
Local cDataIni   := Self:dataIni
Local cDataFim   := Self:dataFim
Local cStatsFup  := Self:status
Local lWSTlegal  := Self:lWSTlegal
Local cFiltroFup := Self:filterFup

	Self:SetContentType("application/json")
	If (!Empty(nPage) .AND. nPage < 1)
		aRet[1] := .F.
		//"Numero da página não pode ser menor que 1!"
		SetRestFault(1001,STR0028)
	Else
		aRet := JWsLtGetFp(,nPage, nPageSize, cPeriFilt, nCateFilt, cFields, cSearchKey, cNumPro, cDataIni, cDataFim, cStatsFup, lWSTlegal, cFiltroFup)
	EndIf

	// Tratativa dos retornos
	Self:SetResponse(FWJsonSerialize(aRet[2], .F., .F., .T.))
	FreeObj(aRet[2])
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DetailFup
Retorna os dados detalhe do Follow-up

@example GET -> http://127.0.0.1:9090/rest/JURFWREST/fup/000001
@Param [Obrigatório] codFup: Código do Follow-up

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET DetailFup PATHPARAM codFup WSRECEIVE fields WSREST JURFWREST
Local oResponse   := Nil
Local aRet        := {.T., oResponse, ""}

	Self:SetContentType("application/json")

	aRet := JWsLtGetFp(Self:codFup,,,,, Self:fields)

	// Tratativa dos retornos
	Self:SetResponse(FWJsonSerialize(aRet[2], .F., .F., .T.))
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET ReturnDocsFup
Retorno de Informações sobre o Documento vinculado ao

@param [Obrigatório] codDoc: Código do Documento na NUM
@example GET -> http://127.0.0.1:9090/rest/JURFWREST/docs/000001"
@example Body -> {   "result": "004", "text": "",  "location": "" }

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET ReturnDocsFup PATHPARAM codDoc WSREST JURFWREST
	Local cAlias     := GetNextAlias()
	Local oResponse  := JsonObject():New()
	Local lReturn    := .T.
	Local nIndexJSon := 1
	Local cQuerySel  := ""
	Local cQueryFrm  := ""
	Local cQueryWhr  := ""
	Local cQueryOrd  := ""
	Local cQuery     := ""

	oResponse['operation'] := "ReturnDocsFup"
	Self:SetContentType("application/json")
	oResponse['data'] := {}

	// Clausula Select ---------------------------------------------------------------------------------------
	cQuerySel := "SELECT NUM_FILIAL, "
	cQuerySel +=        "NUM_COD, "
	cQuerySel +=        "NUM_FILENT, "
	cQuerySel +=        "NUM_ENTIDA, "
	cQuerySel +=        "NUM_CENTID, "
	cQuerySel +=        "NUM_DOC, "
	cQuerySel +=        "NUM_NUMERO, "
	cQuerySel +=        "NUM_DESC, "
	cQuerySel +=        "NUM_EXTEN "

	// Clausula From -----------------------------------------------------------------------------------------
	cQueryFrm := " FROM " + RetSqlName('NUM') + " NUM"

	// Clausula Where ----------------------------------------------------------------------------------------
	cQueryWhr := " WHERE NUM.NUM_COD = '" + Self:codDoc + "'"
	cQueryWhr += " AND (NUM.NUM_ENTIDA = 'NTA') "
	cQueryWhr += " AND (NUM.D_E_L_E_T_ = ' ') "

	// Clausula Order ----------------------------------------------------------------------------------------
	cQueryOrd := ""

	cQuery := "" + cQuerySel + cQueryFrm + cQueryWhr + cQueryOrd

	cQuery := ChangeQuery(cQuery)

	// Execução da Query
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If(cAlias)->(!Eof())
		Aadd(oResponse['data'], JsonObject():New())
		oResponse['data'][nIndexJSon]['idCod']     := JurEncUTF8(AllTrim(Self:codDoc))
		oResponse['data'][nIndexJSon]['filialDoc'] := JurEncUTF8(AllTrim((cAlias)->NUM_FILENT))
		oResponse['data'][nIndexJSon]['origemDoc'] := AllTrim((cAlias)->NUM_ENTIDA)
		oResponse['data'][nIndexJSon]['codigoDoc'] := AllTrim((cAlias)->NUM_CENTID)
		oResponse['data'][nIndexJSon]['nomeDoc']   := JurEncUTF8(AllTrim((cAlias)->NUM_DOC))
		oResponse['data'][nIndexJSon]['numeroDoc'] := AllTrim((cAlias)->NUM_NUMERO)
		oResponse['data'][nIndexJSon]['descrDoc']  := JurEncUTF8(AllTrim((cAlias)->NUM_DESC))
		oResponse['data'][nIndexJSon]['extDoc']    := JurEncUTF8(AllTrim((cAlias)->NUM_EXTEN))
    Else
		SetRestFault(1004,JurEncUTF8(STR0009)) //"Não foram encontrado registros."
		lReturn := .F.
	EndIf

	(cAlias)->(DbCloseArea())
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListTypeFup
Metodo de listagem dos Tipos de Follow-up

@author SIGAJURI
@since 03/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET ListTypeFup WSREST JURFWREST
	Local cAlias     := GetNextAlias()
	Local oResponse  := JsonObject():New()
	Local lReturn    := .T.
	Local cQuerySel  := ""
	Local cQueryFrm  := ""
	Local cQueryWhr  := ""
	Local cQueryOrd  := ""
	Local cQuery     := ""
	Local nIndexJSon := 0

	oResponse['operation'] := "ListTypeFup"
	Self:SetContentType("application/json")
	oResponse['data'] := {}

	// Clausula Select ---------------------------------------------------------------------------------------
	cQuerySel := "SELECT NQS_FILIAL, "
	cQuerySel +=        "NQS_COD, "
	cQuerySel +=        "NQS_DESC "

	// Clausula From -----------------------------------------------------------------------------------------
	cQueryFrm := "FROM " + RetSqlName('NQS') + " NQS "

	// Clausula Where ----------------------------------------------------------------------------------------
	cQueryWhr := "WHERE NQS.D_E_L_E_T_ = ' '"

	// Clausula Order ----------------------------------------------------------------------------------------
	cQueryOrd := ""

	cQuery := cQuerySel + cQueryFrm + cQueryWhr + cQueryOrd

	cQuery := ChangeQuery(cQuery)

	// Execução da Query
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	//
	If(cAlias)->(!Eof())
		While (cAlias)->(!Eof())
			nIndexJSon++
			Aadd(oResponse['data'], JsonObject():New())
			oResponse['data'][nIndexJSon]['filialTipoFup']  := AllTrim((cAlias)->NQS_FILIAL)
			oResponse['data'][nIndexJSon]['codigoTipoFup']     := AllTrim((cAlias)->NQS_COD)
			oResponse['data'][nIndexJSon]['descriTipoFup']    := JurEncUTF8(AllTrim((cAlias)->NQS_DESC))
			(cAlias)->(DbSkip())
		End
	Else
		SetRestFault(1004,JurEncUTF8(STR0009)) //"Não foi encontrado registros."
		lReturn := .F.
	EndIf
	(cAlias)->(DbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListStatsFups
Metodo de listagem dos Status de Follow-up

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET  ListStatsFups WSREST JURFWREST
	Local cQryStats  := GetNextAlias()
	Local oResponse  := JsonObject():New()
	Local lReturn    := .T.
	Local cQuerySel  := ""
	Local cQueryFrm  := ""
	Local cQueryWhr  := ""
	Local cQueryOrd  := ""
	Local cQuery     := ""
	Local nIndexJSon := 0

	oResponse['operation'] := "ListStatsFups"
	Self:SetContentType("application/json")
	oResponse['data'] := {}

	// Clausula Select ---------------------------------------------------------------------------------------
	cQuerySel := "SELECT NQN_FILIAL, "
	cQuerySel +=        "NQN_COD, "
	cQuerySel +=        "NQN_DESC, "
	cQuerySel +=        "NQN_TIPO "

	// Clausula From -----------------------------------------------------------------------------------------
	cQueryFrm := "FROM " + RetSqlName('NQN') + " NQN "

	// Clausula Where ----------------------------------------------------------------------------------------
	cQueryWhr := "WHERE NQN.D_E_L_E_T_ = ' '"

	// Clausula Order ----------------------------------------------------------------------------------------
	cQueryOrd := ""

	cQuery := cQuerySel + cQueryFrm + cQueryWhr + cQueryOrd

	cQuery := ChangeQuery(cQuery)

	// Execução da Query
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryStats, .F., .F. )

	If(cQryStats)->(!Eof())
		While (cQryStats)->(!Eof())
			nIndexJSon++
			Aadd(oResponse['data'], JsonObject():New())
			oResponse['data'][nIndexJSon]['filialResultFup']  := AllTrim((cQryStats)->NQN_FILIAL)
			oResponse['data'][nIndexJSon]['codigoResultFup']  := AllTrim((cQryStats)->NQN_COD)
			oResponse['data'][nIndexJSon]['descriResultFup']  := JurEncUTF8(AllTrim((cQryStats)->NQN_DESC))
			oResponse['data'][nIndexJSon]['tipoResultFup']    := JurEncUTF8(AllTrim((cQryStats)->NQN_TIPO))
			(cQryStats)->(DbSkip())
		End
	Else
		SetRestFault(1004,JurEncUTF8(STR0009)) //"Não foi encontrado registros."
		lReturn := .F.
	EndIf
	(cQryStats)->(DbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT UpdateFup
Alteração de informações do detalhe do Follow-up a partir do Body

@example PUT -> http://127.0.0.1:9090/rest/JURFWREST/fup/{codFup}
@example Body -> {   "result": "004", "text": "",  "location": "" }
}

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD PUT UpdateFup PATHPARAM codFup WSREST JURFWREST
	Local oResponse  := JsonObject():New()
	Local oMessage   := JsonObject():New()
	Local oRequest   := JsonObject():New()
	Local aRet       := {.F.,""}
	Local cQryUpdFup := GetNextAlias()
	Local cData      := ""
	Local cHora      := ""
	Local cText      := ""
	Local cStatus    := ""
	Local cCajuri    := JurGetDados('NTA',1,xFilial('NTA') + Self:codFup,  'NTA_CAJURI')
	Local cSituac    := JurGetDados('NSZ',1,xFilial('NSZ') + cCajuri,  'NSZ_SITUAC')
	Local cLocal
	Local cQrySel    := ""
	Local cQryFrm    := ""
	Local cQryWhere  := ""
	Local cQuery     := ""
	Local cBody
	Local oReqBody

	oResponse['operation'] := "UpdateFup"
	Self:SetContentType("application/json")
	oResponse['messages'] := {}

	cBody := Self:GetContent()

	If !Empty(cBody)
		aRet      := {.T.,""}
		varinfo('getProperties', oRequest:getProperties())
		varinfo('hasProperty(name)', oRequest:hasProperty('name'))

		FWJsonDeserialize(cBody,@oReqBody)

		If ('"text":"' $ StrTran(cBody, " ", ""))
			cText := oReqBody:text
			cBody := StrTran(cBody,cText,"")
		EndIf

		If ('"status":"' $ StrTran(cBody, " ", ""))
			cStatus := oReqBody:status
		EndIf

		If ('"data":"' $ StrTran(cBody, " ", ""))
			cData := oReqBody:data
		EndIf

		If ('"hora":"' $ StrTran(cBody, " ", ""))
			cHora := oReqBody:hora
		EndIf

		// Verifica se o status foi informado
		If Empty(cStatus)
			aRet := {.F., STR0015} //"O campo 'Status' não foi informado."
		EndIf

		// Verifica o status do Assunto jurídico
		If cSituac == '2' .AND. aRet[1]
			aRet := {.F., STR0029} //"O assunto jurídico está encerrado, sendo assim não é possivel alterar os follow-ups."
		EndIf

		// Se não houve erro até o momento
		If aRet[1]
			// Clausula Select -------------------------------------------------
			cQrySel   := "SELECT NQN_TIPO "

			// Clausula From ---------------------------------------------------
			cQryFrm   := "FROM " + RetSqlName('NQN') + " "

			// Clausula Where --------------------------------------------------
	       cQryWhere := "WHERE NQN_COD = '" + AllTrim(cStatus) + "' "

			// Montagem da Query
			cQuery := cQrySel + cQryFrm + cQryWhere

			cQuery := ChangeQuery(cQuery)

			// Execução da Query
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryUpdFup, .F., .F. )

			// Verifica se o Result informado é do tipo"Pendente", "Concluido" ou "Em Andamento"
			If ((cQryUpdFup)->(NQN_TIPO) $ '125')

				// Atualiza o Follow-up
				aRet := JWsLtUpNTA(Self:codFup, cStatus, cData, cHora, cLocal)

				// Gera o Andamento
				If aRet[1]
					aRet := JWsLtGrNT4(Self:codFup, cText)
				EndIf
			Else
				aRet := {.F.,STR0017} //"O Status informado não é válido."
			Endif
		Endif
	Else
		aRet := {.F.,STR0027} //"Não há envio de informações no Body da requisição!"
	EndIf

	if aRet[1]
		oMessage := JRestMsg('1000',STR0018,aRet[2]) //Success

		oResponse['messages'] := {oMessage}
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		SetRestFault(400, aRet[2])
	Endif

Return aRet[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} POST CreateDocsFup
Criação de documentos do Follow-up

@example PUT -> http://127.0.0.1:9090/rest/JURFWREST/fup/{codFup}/docs
@example BODY -> { "name":"nome_do_arquivo.pdf", "content":"conteudo em Encode64"}

@author Marcelo Araujo Dente
@since 07/07/17
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD POST CreateDocsFup PATHPARAM codFup  WSREST JURFWREST
	Local oResponse 	:= JsonObject():New()
	Local cName     	:= ''
	Local cContent  	:= ''
	Local nHandle    	:= -1
	Local aOkDoc 		:= {}
	Local cDestino   	:= "/SPOOL/"
	Local cAssuntoJur	:= JurGetDados("NTA",1,XFilial("NTA")+ Self:codFup, "NTA_CAJURI")
	Local cBody 		:= ""
	Local aRet    	:= {.T.,""}
	Local oReqBody

	cBody := Self:GetContent()

	If !Empty(cAssuntoJur)

		If aRet[1]
			If !Empty(cBody)
				aRet[1] := FWJsonDeserialize(cBody,@oReqBody)

				If aRet[1]
					If ('"name":"' $ StrTran(cBody, " ", ""))
						cName := "\" + oReqBody:name
					EndIf

					If ('"content":"' $ StrTran(cBody, " ", ""))
						cContent	:= oReqBody:content
					EndIf

					If Empty(cName) .OR. Empty(cContent)
						//"Parâmetros obrigatórios faltando, favor verificar!"
						aRet := {.F., STR0021}
					Else
						nHandle:= FCREATE(cDestino + cName, 0)
					EndIf
				Else
					// "Erro ao desmembrar o JSon"
					aRet[2] := STR0031
				EndIf
			EndIf

			If nHandle == -1 .AND. aRet[1]
				//"O Arquivo não foi criado: "
				aRet := {.F., STR0010 + STR(FERROR()) }

			ElseIf aRet[1]
			    FWRITE(nHandle, Decode64(cContent))

				If FCLOSE(nHandle) .And. File(cDestino +  cName)
					aOkDoc:= J026Anexar("NTA", xFilial("NTA"), Self:codFup, cAssuntoJur, cDestino + cName )

					If aOkDoc[1]
						//'Documento criado com sucesso '
						aRet := {.T., STR0011 + aOkDoc[2]}
					Else
						//'Não foi possível criar o documento '
						aRet := {.F., STR0012 + aOkDoc[2]}
					EndIf
				Else
					//'Não foi possível criar o documento '
					aRet[2] := STR0012 + STR(FERROR())
				EndIf
			EndIf
		EndIf
	Else
		// "Registro não inexistente : "
		aRet := {.F., STR0014 + Self:codFup + " " + FWTimeStamp(3)}
	EndIf

	// Tratativa final
	If aRet[1]
		oMessage := JRestMsg('1000',STR0018,aRet[2]) //Success

		oResponse['messages'] := {oMessage}
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		SetRestFault(1001, aRet[2])
	EndIf
Return aRet[1]

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} DataFormat
Formata data

@param cOption

@return dtSem

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DataFormat(cOption)
Local nS    := DOW(date())
Local dtSem := ''

	If cOption == '1'
		dtSem := dtIni(nS)
	Else
		dtSem := dtFim(nS)
	Endif

Return dtSem

//-------------------------------------------------------------------
/*/{Protheus.doc} dtIni
Data Inicial

@param dSemana

@return dIni

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function dtIni(dSemana)
Local dIni := DaySub(date(), dSemana - 1)

Return dIni

//-------------------------------------------------------------------
/*/{Protheus.doc} dtFim
Data Final

@param dSemana

@return dFim

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function dtfim(dSemana)
Local dFim := DaySum(date(), 7 - dSemana)

Return dFim

//-------------------------------------------------------------------
/*/{Protheus.doc} JRestMsg
Retorna mensagem de erro ou sucesso

@author SIGAJURI
@since 06/07/17
@version 1.0
@param nCode: Codigo da mensagem
@param cType: Sucess / Error
@param cError: Mensagem

@example JRestMsg('1001','error','Registro não encontrado ')
/*/
//-------------------------------------------------------------------
Static Function JRestMsg(nCode, cType, cError)
	Local oMessage := JsonObject():New()
	Default cType := STR0019

	oMessage['code']   := nCode
	oMessage['type']   := cType
	oMessage['detail'] := JurEncUTF8(cError)

Return oMessage


//-------------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Formata o valor em UTF8 e retira os espaços

@param nInsta - Numero da Instância

@Return cDesInsta - Descrição da instância

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JConvUTF8(cValue)
Local cReturn := ""

	cReturn := EncodeUTF8(Alltrim(cValue))

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} _JURFWREST

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

Function _JURFWREST

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET JWsLtGetFp
Lista de Follow-ups

@param [Opcional] cCodfup:    Código do FUP
@param [Opcional] nPage:      Numero da Página
@param [Opcional] nPageSize:  Quantidade de registros por pagina
@param [Opcional] cPeriFilt:  Período filtrado (1: Hoje/ 2:Amanhã/ 3:Semana Corrente/ 4:Atrasados em aberto /
												5: Periodo de 7 dias a contar com o dia atual )
@param [Opcional] cCateFilt:  Categoria do Follow-up
@param [Opcional] cFields:    Nome do campo
@param [Opcional] cSearchKey: Valor a ser pesquisado nos campos  NTA_DESC, NQS_DESC, NUQ_NUMPRO E NT9_NOME
@param [Opcional] cNumPro:    Número do processo
@param [Opcional] cDataIni:   Data inicio da busca
@param [Opcional] cDataFim:   Data final da busca
@param [Opcional] cStatsFup:  Status do FUP
@param [Opcional] lWSTlegal:  Vem do totvs legal?
@param [Opcional] cFiltroFup: Filtro a ser aplicado na função WsJurCWhrAtv() para obter as atividades (TotvsLegal)

@author SIGAJURI
@since 11/03/17
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/fup
@example [Com Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/fup?page=1&pageSize=10&periFilt=1&cateFilt=1
/*/
//------------------------------------------------------------------
Function JWsLtGetFp(cCodfup,nPage, nPageSize, cPeriFilt, cCateFilt, cFields, cSearchKey, cNumPro, cDataIni, cDataFim, cStatsFup, lWSTlegal, cFiltroFup)
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local oResponse   := JsonObject():New()
Local nQtdReg     := 0
Local nLenResp    := 0
Local nIndexJSon  := 0
Local aParts      := {}
Local aPedido     := {}
Local nQtdRegIni  := 0
Local nQtdRegFim  := 0
Local lHasNext    := .F.
Local aCpoFlt     := {}
Local nValPedTot  := 0
Local lRet        := .T.
Local aRet        := {lRet, oResponse, ""}
Local cWhere      := ""
Local cUsrFup     := ""

Default nPage      := 1
Default nPageSize  := 10
Default cCodFup    := ""
Default cFields    := ""
Default lWSTlegal  := .F.
Default cFiltroFup := ""

	If !Empty(cFiltroFup)
		cWhere := WsJurCWhrAtv(cFiltroFup)
	EndIf

	// Monta array com os campos dados no paramentro
	aCpoFlt := JStrArrDst(cFields,',')

	cQuery := JWsLTQryFup(cCodFup, cStatsFup, cCateFilt, cDataIni, cDataFim, cPeriFilt, cSearchKey, cNumPro, lWSTlegal, cWhere)

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse['data'] := {}

	// Define o range para inclusão no JSON
	nQtdRegIni := ((nPage-1) * nPageSize)
	nQtdRegFim := (nPage * nPageSize)

	If !Empty(cCodFup)
		oResponse['operation'] := "DetailFup"
	Else
		oResponse['operation'] := "ListFup"
	EndIf

	While (cAlias)->(!Eof())

		nQtdReg++
		// Verifica se o registro está no range da pagina
		if (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			// Count do index para inclusão no JSON
			nIndexJSon++
			Aadd(oResponse['data'], JsonObject():New())
			
			oResponse['data'][nIndexJSon]['idFu']     := (cAlias)->NTA_COD
			oResponse['data'][nIndexJSon]['empresa']     := JConvUTF8((cAlias)->EMPRESA)

			If Empty(cFields) .OR. aScan( aCpoFlt, 'FILIAL'  ) > 0
				oResponse['data'][nIndexJSon]['filial']    := (cAlias)->FILIAL
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'CAJURI'  ) > 0
				oResponse['data'][nIndexJSon]['cajuri']    := (cAlias)->CAJURI
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'TIPOASJ'  ) > 0
				oResponse['data'][nIndexJSon]['tipoasj']    := (cAlias)->TIPOASJ
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'SIGLA'  ) > 0
				oResponse['data'][nIndexJSon]['sigla']    := Alltrim((cAlias)->RD0_SIGLA)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'USER'  ) > 0
				oResponse['data'][nIndexJSon]['codUserResp']    := Alltrim((cAlias)->RD0_USER)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'CODIGO'  ) > 0
				oResponse['data'][nIndexJSon]['codResp']    := Alltrim((cAlias)->RD0_CODIGO)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'DATAFU'  ) > 0
				oResponse['data'][nIndexJSon]['datafu']   := SubStr((cAlias)->NTA_DTFLWP, 1,4) + "-" + SubStr((cAlias)->NTA_DTFLWP,5,2) + "-" + SubStr((cAlias)->NTA_DTFLWP,7,2)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'TIPOFU'  ) > 0
				oResponse['data'][nIndexJSon]['tipofu']     := {}
				Aadd(oResponse['data'][nIndexJSon]['tipofu'], JsonObject():New())
				aTail(oResponse['data'][nIndexJSon]['tipofu'])['codigo'] := JConvUTF8((cAlias)->CODTIPOFU)
				aTail(oResponse['data'][nIndexJSon]['tipofu'])['descri'] := JConvUTF8((cAlias)->TIPOFU)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'NUMPRO'  ) > 0
				oResponse['data'][nIndexJSon]['numpro']   := AllTrim((cAlias)->NUQ_NUMPRO)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'FORO'  ) > 0
				oResponse['data'][nIndexJSon]['foro']     := JConvUTF8((cAlias)->FORO)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'ENDFORO'  ) > 0
				oResponse['data'][nIndexJSon]['endForo']  := JConvUTF8((cAlias)->ENDE)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'HORA'  ) > 0
				oResponse['data'][nIndexJSon]['hora']     := SubStr(AllTrim((cAlias)->NTA_HORA), 1, 2) +":"+ SubStr(AllTrim((cAlias)->NTA_HORA), 3, 2)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'DURACAO'  ) > 0
				oResponse['data'][nIndexJSon]['duracao']  := AllTrim((cAlias)->NTA_DURACA)
			Endif

			If Empty(cFields) .OR. aScan( aCpoFlt, 'DESC'  ) > 0
				oResponse['data'][nIndexJSon]['desc']     := JConvUTF8((cAlias)->NTA_DESC)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'POLOATIVO'  ) > 0
				oResponse['data'][nIndexJSon]['autor']        := JConvUTF8((cAlias)->POLOATIVO)
				oResponse['data'][nIndexJSon]['autorCpfCnpj'] := JConvUTF8((cAlias)->ATIVO_CGC)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'POLOPASSIVO'  ) > 0
				oResponse['data'][nIndexJSon]['reu']          := JConvUTF8((cAlias)->POLOPASSIVO)
				oResponse['data'][nIndexJSon]['reuCpfCnpj']   := JConvUTF8((cAlias)->PASSIVO_CGC)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'VARA'  ) > 0
				oResponse['data'][nIndexJSon]['vara']     := JConvUTF8((cAlias)->VARA)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'RESULT'  ) > 0
				oResponse['data'][nIndexJSon]['result']   := Alltrim((cAlias)->NTA_CRESUL)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'DETAIL'  ) > 0
				oResponse['data'][nIndexJSon]['detail']   := JConvUTF8((cAlias)->DETAIL)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'ACAO'  ) > 0
				oResponse['data'][nIndexJSon]['acao']     := JConvUTF8((cAlias)->ACAO)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'PROV'  ) > 0
				oResponse['data'][nIndexJSon]['prov']     := (cAlias)->VPROV
		 	EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'SITUAC'  ) > 0
				oResponse['data'][nIndexJSon]['situacao'] := JConvUTF8((cAlias)->SITUAC)
			EndIf
			
			If Empty(cFields) .OR. aScan( aCpoFlt, 'DESCRESUL'  ) > 0
				oResponse['data'][nIndexJSon]['descresul'] := JConvUTF8((cAlias)->DESCRESUL)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'DTFUP'  ) > 0 // traz a data como é salva no banco, para TOTVSLEGAL
				oResponse['data'][nIndexJSon]['dtfup']   := (cAlias)->NTA_DTFLWP
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'ASSJURORIG'  ) > 0 // traz o assunto jurídico origem do processo
				oResponse['data'][nIndexJSon]['tipoAsjOrig']   := (cAlias)->ASSJURORIG
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'TIPO_STATUS'  ) > 0 // status da situação do FUP
				oResponse['data'][nIndexJSon]['tipoStatus']   := (cAlias)->TIPO_STATUS
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'REAGEN'  ) > 0 // reagendado?
				oResponse['data'][nIndexJSon]['reagendado']   := (cAlias)->REAGEN == "1"
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'CPART'  ) > 0 // Código participante
				oResponse['data'][nIndexJSon]['codPart']   := (cAlias)->CPART
			EndIf

			If lWSTlegal
				cUsrFup := Posicione("RD0", 9, xFilial("RD0")+(cAlias)->RD0_SIGLA,"RD0_USER")
				oResponse['data'][nIndexJSon]['usrLogged'] :=  cUsrFup == __CUSERID
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'SOLIC'  ) > 0 // SOLICITANTE
				oResponse['data'][nIndexJSon]['solicitante']   := JConvUTF8((cAlias)->SOLIC)
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'TPSOLIC'  ) > 0 // TIPO DE SOLICITAÇÃO
				oResponse['data'][nIndexJSon]['tipoSolicitacao']   := JConvUTF8((cAlias)->TPSOLIC)
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'NOMEMARCA'  ) > 0 // Nome da Marca
				oResponse['data'][nIndexJSon]['nomeMarca']   := JConvUTF8((cAlias)->NOMEMARCA)
			EndIf

			If lWSTlegal .AND. Empty(cFields) .OR. aScan( aCpoFlt, 'SITMARCA'  ) > 0 // Situação da marca
				oResponse['data'][nIndexJSon]['situacaoMarca']   := JConvUTF8((cAlias)->SITMARCA)
			EndIf


			If Empty(cFields) .OR. aScan( aCpoFlt, 'PREPOSTO'  ) > 0
				oResponse['data'][nIndexJSon]['preposto'] := {}

				Aadd(oResponse['data'][nIndexJSon]['preposto'], JsonObject():New())
				aTail(oResponse['data'][nIndexJSon]['preposto'])['nome']     := JConvUTF8((cAlias)->PREP)
				aTail(oResponse['data'][nIndexJSon]['preposto'])['telefone'] := JConvUTF8((cAlias)->TEL)
				aTail(oResponse['data'][nIndexJSon]['preposto'])['email']    := JConvUTF8((cAlias)->EMAIL)
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'RESP'  ) > 0
				oResponse['data'][nIndexJSon]['resp']     := {}
				aParts  := JWsLtGtNTE((cAlias)->NTA_COD, (cAlias)->FILIAL )//busca os participantes que estão vinculados ao FUP

				// Loop para inclusão dos Responsáveis
				While nLenResp < len(aParts)
					nLenResp++
					Aadd(oResponse['data'][nIndexJSon]['resp'], JsonObject():New())
					aTail(oResponse['data'][nIndexJSon]['resp'])['sigla']   := JConvUTF8(aParts[nLenResp][1])
					aTail(oResponse['data'][nIndexJSon]['resp'])['nome']    := JConvUTF8(aParts[nLenResp][2])
					aTail(oResponse['data'][nIndexJSon]['resp'])['fone']    := JConvUTF8(aParts[nLenResp][3])
					aTail(oResponse['data'][nIndexJSon]['resp'])['email']   := JConvUTF8(aParts[nLenResp][4])
					aTail(oResponse['data'][nIndexJSon]['resp'])['codPart'] := JConvUTF8(aParts[nLenResp][5])
					aTail(oResponse['data'][nIndexJSon]['resp'])['codUser'] := JConvUTF8(aParts[nLenResp][6])
				End
				nLenResp := 0
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'PEDIDOS'  ) > 0
				oResponse['data'][nIndexJSon]['pedidos']  := {}

				aPedido := JWsLtGtNSY((cAlias)->NTA_CAJURI) //busca os pedidos/objetos que vinculados ao assunto juridico
				// Loop para inclusão dos pedidos/objetos
				While nLenResp < len(aPedido)
					nLenResp++
					Aadd(oResponse['data'][nIndexJSon]['pedidos'], JsonObject():New())
					aTail(oResponse['data'][nIndexJSon]['pedidos'])['tipo']  := JConvUTF8(aPedido[nLenResp][1])
					aTail(oResponse['data'][nIndexJSon]['pedidos'])['prog']  := JConvUTF8(aPedido[nLenResp][2])
					aTail(oResponse['data'][nIndexJSon]['pedidos'])['valor'] := aPedido[nLenResp][3]
					nValPedTot := nValPedTot + aPedido[nLenResp][3]
				End
				oResponse['data'][nIndexJSon]['pedvaltot'] := nValPedTot
				nLenResp := 0
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'OUTROSENVOLVIDOS'  ) > 0
				oResponse['data'][nIndexJSon]['outrosEnvolvidos']  := {}

				aEnvol  := JWsLtGtNT9((cAlias)->CAJURI )//busca os participantes que estão vinculados ao FUP
				//Loop para inclusão dos envolvidos/
				While nLenResp < len(aEnvol)
					nLenResp++
					Aadd(oResponse['data'][nIndexJSon]['outrosEnvolvidos'], JsonObject():New())
					aTail(oResponse['data'][nIndexJSon]['outrosEnvolvidos'])['Nome']     := JConvUTF8(aEnvol[nLenResp][1])
					aTail(oResponse['data'][nIndexJSon]['outrosEnvolvidos'])['TipoEnv']  := JConvUTF8(aEnvol[nLenResp][2])
					aTail(oResponse['data'][nIndexJSon]['outrosEnvolvidos'])['Telefone'] := JConvUTF8(aEnvol[nLenResp][3])
					aTail(oResponse['data'][nIndexJSon]['outrosEnvolvidos'])['Email']    := JConvUTF8(aEnvol[nLenResp][4])
					aTail(oResponse['data'][nIndexJSon]['outrosEnvolvidos'])['CpfCnpj']  := JConvUTF8(aEnvol[nLenResp][5])
				End
				nLenResp := 0
			EndIf

			If Empty(cFields) .OR. aScan( aCpoFlt, 'DOCUMENTOS' ) > 0
				oResponse['data'][nIndexJSon]['documentos']  := {}

				aDocs := JWsLtGtNUM((cAlias)-> NTA_COD)//Busca os documentos que estão anexados ao FUP
				//Loop para inclusão dos documentos anexados
				While nLenResp < len(aDocs)
					nLenResp++
					Aadd(oResponse['data'][nIndexJSon]['documentos'], JsonObject():New())
					aTail(oResponse['data'][nIndexJSon]['documentos'])['NomeDoc'] := JConvUTF8(aDocs[nLenResp][1]) + JConvUTF8(aDocs[nLenResp][2])
					aTail(oResponse['data'][nIndexJSon]['documentos'])['idDoc']   := JConvUTF8(aDocs[nLenResp][3])
				End
				nLenResp := 0
			EndIf

		Elseif (nQtdReg == nQtdRegFim+1)
			lHasNext := .T.
		Endif

		(cAlias)->(DbSkip())
	End

	// Verifica se há uma proxima pagina
	If (lHasNext)
		oResponse['hasNext'] := "true"
	Else
		oResponse['hasNext'] := "false"
	EndIf

	oResponse['length'] := nQtdReg

	if  nQtdReg == 0
		oMessage := JRestMsg('1001',STR0019 ,STR0009) //"Error" //"Não foram encontrados registros."
		oResponse['messages'] := {oMessage}
	EndIf

	if  nQtdReg == 0
		//"Não foram encontrados registros."
		aRet := {.F., oResponse,STR0009}
	Else
		aRet := {.T., oResponse, ""}
	EndIf
	(cAlias)->(DbCloseArea())
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLtUpNTA

Atualiza Follow-up com dados vindos do POST-REST

@param cIdFwp
@param cResult
@param cGPS

@return aRet

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLtUpNTA(cIdFwp, cStatus, cData, cHora, cLocal)
Local cMsg     := ''
Local aRet     := {.T.,''}
Local oModel   := Nil
DEFAULT cData  := ''
DEFAULT cHora  := ''
DEFAULT cLocal := ''

	DbSelectArea('NTA')
	NTA->( DbSetOrder(1) ) //NTA_FILIAL+NTA_COD

	If Empty( cIdFwp ) .Or. Empty( cStatus )
		Conout(STR0020 + STR0021)
		cMsg := STR0020 + STR0021 // "JurRestSyncFollowUp: Parâmetros obrigatórios faltando, favor verificar!"
		aRet := {.F.,cMsg}
	EndIf

	If !( NTA->( DbSeek(xFilial('NTA')+cIdFwp) ) )
		Conout(STR0020 + STR0022 + cIdFwp)
		cMsg := STR0020 + STR0022 + cIdFwp //"JurRestSyncFollowUp: Código não encontrado no cadastro de Follow-up! Código: "
		aRet := {.F.,cMsg}
	EndIf

	If aRet[1]
		oModel := FWLoadModel( 'JURA106' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oModel:SetValue('NTAMASTER','NTA_CRESUL', cStatus)  //Grava a mudança de Resultado

		If !Empty(cData) .Or. !Empty(cHora)
			If Empty(cHora) .Or. Empty(cData)
				cMsg := STR0020 + STR0021 // "JurRestSyncFollowUp: Parâmetros obrigatórios faltando, favor verificar!"
				aRet := {.F., cMsg}
			Else
				cData := STRTRAN(cData, "-", "")
				cData := SubStr(cData,7,2)+"/"+ SubStr(cData,5,2)+"/" + SubStr(cData,3,2)
				cHora := SubStr(StrTran(cHora,":",""),1,4)
				oModel:LoadValue('NTAMASTER','NTA_DTALT', CtoD(cData))
			EndIf
		EndIf

		If aRet[1]
	    	If  !( oModel:VldData() )
					Conout(STR0020 + STR0023 + oModel:GetErrorMessage()[6])
					cMsg := STR0020 + STR0023 + oModel:GetErrorMessage()[6] // "JurRestSyncFollowUp: Problema na validação do Follow-Up! Erro: "
					aRet := {.F.,cMsg}
				EndIf

				If  !( oModel:CommitData())
					Conout(STR0020 + STR0024 + oModel:GetErrorMessage()[6])
					cMsg := STR0020 + STR0024 + oModel:GetErrorMessage()[6] // "JurRestSyncFollowUp: Problema no commit do Follow-Up! Erro: "
					aRet := {.F.,cMsg}
				Endif
		EndIf

		oModel:DeActivate()
		oModel:Destroy()

	Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLtGrNT4
Função para gerar andamento


@param idFu - Identificação do Follow-up
@param cText - Descrição para o Andamento

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

Function JWsLtGrNT4(idFu, cText)
Local oMMaster := Nil
Local oModel   := Nil
Local cCajuri  := JurGetDados('NTA',1,xFilial('NTA') + idFu,  'NTA_CAJURI')
Local cTipo    := JurGetDados('NTA',1,xFilial('NTA') + idFu,  'NTA_CTIPO')
Local cAto     := JurGetDados('NQS',1,xFilial('NQS') + cTipo, 'NQS_CSUGES')
Local cMsg     := ''
Local aRet     := {.T.,''}

Default cText    := JurGetDados('NTA',1,xFilial('NTA') + idFu,  'NTA_DESC')

	cText := STR0013 + Iif(!Empty(cText), ': ' + cText,"")
	oMMaster := FWLoadModel("JURA100")
	oMMaster:SetOperation( 3 )
	oMMaster:Activate()

	oModel := oMMaster:GetModel( 'NT4MASTER' )
	oModel:SetValue('NT4_CAJURI', cCajuri )  //Seta o data do andamento
	oModel:SetValue('NT4_DTANDA', Date() )   //Seta o data do andamento
	oModel:SetValue('NT4_CATO', cAto )       //Seta o ato processual
	oModel:SetValue('NT4_DESC', cText )      //Seta texto do andamento
	oModel:SetValue('NT4_DTINCL', Date() )   //Seta o data de inclusao
	oModel:SetValue('NT4_USUINC', 'Admin' )  //Seta o usuário de inclusão
	oModel:SetValue('NT4_DTALTE', Date() )   //Seta a data de alteracao
	oModel:SetValue('NT4_USUALT', 'Admin' )  //Seta o usuário de alteração

	If  !( oMMaster:VldData() )
		Conout(STR0020 + STR0025 + oMMaster:GetErrorMessage()[6])
		cMsg := STR0020 + STR0025 + oMMaster:GetErrorMessage()[6] //"JurRestSyncFollowUp: Problema na validação do andamento! Erro: "
		aRet := {.F.,cMsg}
	EndIf

	If !( oMMaster:CommitData() )
		Conout(STR0020 + STR0026 + oMMaster:GetErrorMessage()[6])
		cMsg := STR0020 + STR0026 + oMMaster:GetErrorMessage()[6] // "JurRestSyncFollowUp: Problema no commit do andamento! Erro: "
		aRet := {.F.,cMsg}
	EndIf

	oModel:DeActivate()
	oModel:Destroy()

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLtGtNTE(cFollowup)
Retorna um array com os participantes responsáveis pelo Fup

@param cFollowup - código do follow-up
@param cFilFup - filial do follow-up
@Return	aSigla  array de participantes responsáveis pelo FUP.

@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLtGtNTE(cFollowup, cFilFup)
Local aSigla := {}
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := GetNextAlias()
Default cFilFup := xFilial('NTA')

	cSQL  := "SELECT RD0.RD0_SIGLA, "
	cSQL  +=       " RD0.RD0_NOME, "
	cSQL  +=       " RD0.RD0_EMAIL, "
	cSQL  +=       " RD0.RD0_FONE, "
	cSQL  +=       " RD0.RD0_CODIGO, "
	cSQL  +=       " RD0.RD0_USER "
	cSQL  += " FROM "+ RetSqlname('NTE') +" NTE "
	cSQL  += "INNER JOIN " + RetSqlname('RD0') + " RD0 "
	cSQL  +=   " ON (NTE.NTE_CPART = RD0.RD0_CODIGO) "
	cSQL  += "INNER JOIN " + RetSqlname('NTA') + " NTA "
	cSQL  +=   " ON (NTE.NTE_CFLWP = NTA.NTA_COD"
	cSQL  +=       " AND NTE.NTE_FILIAL = NTA.NTA_FILIAL) "
	cSQL  += " WHERE NTE.NTE_CFLWP  = '" + cFollowup + "' "
	cSQL  += " AND NTA.NTA_FILIAL  = '" + cFilFup + "' "
	cSQL  += " AND RD0.RD0_FILIAL = '" + xFilial('RD0') + "' "
	cSQL  += " AND RD0.D_E_L_E_T_ = ' ' "
	cSQL  += " AND NTA.D_E_L_E_T_ = ' ' "
	cSQL  += " AND NTE.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd( aSigla, { (cAlias)->RD0_SIGLA,;
						(cAlias)->RD0_NOME,;
						(cAlias)->RD0_FONE,;
						(cAlias)->RD0_EMAIL,;
						(cAlias)->RD0_CODIGO,;
						(cAlias)->RD0_USER;
		} )
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)
Return aSigla

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLtGtNSY(cCajuri)
Retorna um array com os pedidos/objetos relacionados ao processo


@Return	aPedido array com as informações necessárias para visualização do pedido/objeto

@author Beatriz Gomes
@since 24/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLtGtNSY(cCajuri)
local aPedido := {}
Local cSQL    := ''
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()

	cSQL  := "SELECT NSP.NSP_DESC TIPO, "
	cSQL  +=       " NQ7.NQ7_DESC PROG, "
	cSQL  +=       " ROUND(NSY.NSY_PEVLRA,2) VALOR "
	cSQL  += " FROM "+ RetSqlName('NSY') + " NSY "
	cSQL  += " LEFT JOIN " + RetSqlName('NSP') + " NSP ON (NSP.NSP_COD  = NSY.NSY_CPEVLR "
	cSQL  +=        " AND NSP.D_E_L_E_T_ = ' ') "
	cSQL  += " LEFT JOIN " + RetSqlName('NQ7') + " NQ7 ON (NQ7.NQ7_COD  = NSY.NSY_CPROG "
	cSQL  +=        " AND NSP.D_E_L_E_T_ = ' ') "
	cSQL  += " WHERE NSY.NSY_CAJURI = '" + cCajuri + "'  AND NSY.D_E_L_E_T_ = ' '"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd( aPedido, { (cAlias)->TIPO, (cAlias)->PROG, (cAlias)->VALOR} )
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aPedido

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLtGtNT9(cFollowup)
Retorna um array com os envolvidos com o Fup

@param cFollowup

@Return	aEnvol array de envolvidos.

@author Beatriz Gomes
@since 29/06/17
@version 1.0t
/*/
//-------------------------------------------------------------------
Function JWsLtGtNT9(cCajuri)
Local aEnvol := {}
Local cSQL   := ''
Local aArea  := GetArea()
Local cAlias := GetNextAlias()

	cSQL  := "SELECT NT9.NT9_NOME "
	cSQL  +=       ",NQA.NQA_DESC "
	cSQL  +=       ",NT9.NT9_TELEFO "
	cSQL  +=       ",NT9.NT9_EMAIL "
	cSQL  +=       ",NT9.NT9_CGC "
	cSQL  += "FROM "+ RetSqlname('NT9') +" NT9 INNER JOIN " + RetSqlname('NQA') +" NQA ON (NQA.NQA_COD = NT9.NT9_CTPENV) "
	cSQL  += "WHERE NT9.D_E_L_E_T_ = ' ' "
	cSQL  +=  " AND NT9.NT9_FILIAL = '" + xFilial('NT9') + "' "
	cSQL  +=  " AND NT9.NT9_CAJURI = '" + cCajuri + "' "
	cSQL  +=  " AND NT9.NT9_TIPOEN = '3'"

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
      aAdd( aEnvol, { (cAlias)->NT9_NOME,(cAlias)->NQA_DESC, (cAlias)->NT9_TELEFO, (cAlias)->NT9_EMAIL, (cAlias)->NT9_CGC} )
      (cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)
Return aEnvol

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLtGtNUM(cFollowup)
Retorna um array com os documentos anexados ao Followup

@param cFollowup

@Return	aEnvol array de envolvidos.

@author Beatriz Gomes
@since 30/06/17
@version 1.0t
/*/
//-------------------------------------------------------------------
Function JWsLtGtNUM(cFup)

Local aDoc       := {}
Local cSQL       := ''
Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local cMvJDocume := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
Local cQuerySel  := ""
Local cQueryFrm  := ""
Local cQueryWhr  := ""

	// Clausula Select ---------------------------------------------------------------------------------------
	cQuerySel := "SELECT NUM_DOC, "
	cQuerySel +=       " NUM_EXTEN, "
	cQuerySel +=       " NUM.NUM_COD "

	// Clausula From -----------------------------------------------------------------------------------------
	cQueryFrm := " FROM " + RetSqlName('NUM') + " NUM "

	cQueryWhr := " WHERE ( NUM.NUM_ENTIDA = 'NTA' ) "
	cQueryWhr +=   " AND ( NUM.D_E_L_E_T_ = ' ' ) "

	If JurHasClas()
		cQueryWhr += " AND NUM.NUM_CENTID = '" + cFup + "' "
	Else
		If cMvJDocume == "3"
			cQueryWhr += " AND NUM.NUM_CENTID = '" + cFup + "' "
		Else
			cQueryWhr += " AND NUM.NUM_CENTID = '" + xFilial('NUM') + cFup + "' "
		EndIf
	EndIf

	cSQL := cQuerySel + cQueryFrm + cQueryWhr
	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd( aDoc, { (cAlias)->NUM_DOC, (cAlias)->NUM_EXTEN,(cAlias)->NUM_COD} )
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)
Return aDoc


//-------------------------------------------------------------------
/*/{Protheus.doc} POST RelFUP
Gera exportação de tarefas a vencer - Relatório em Excel
@param dataIni - Informe a data incial para busca
@param dataFim - Informe a data final para busca
@Return .T. - Lógico
@since 11/12/2019
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/exportTarefa
/*/
//-------------------------------------------------------------------
WSMETHOD GET RelFUP WSRECEIVE dataIni, dataFim, showTaskMembers, filtrosAtividades WSREST JURFWREST
Local lXlsx        := __FWLibVersion() >= '20201009' .And. GetRpoRelease() >= '12.1.023' .And. PrinterVersion():fromServer() >= '2.1.0'
Local cNomeArq     := "\spool\" + JurTimeStamp(1) + "_exportacao_" + RetCodUsr() + IIF( lXlsx, ".xlsx",".xls")
Local oResponse    := JsonObject():New()
Local aCamps       := {}
Local aFiltro      := {}
Local cDataIni     := Self:dataIni
Local cDataFim     := Self:dataFim
Local lTaskEquip   := Self:showTaskMembers
Local cResp        := IIF( VALTYPE(Self:GetHeader("resp")) <> "U", Self:GetHeader("resp"), "" )
Local cTipos       := IIF( VALTYPE(Self:GetHeader("tipos")) <> "U", Self:GetHeader("tipos"), "" )
Local cStatus      := IIF( VALTYPE(Self:GetHeader("status")) <> "U", Self:GetHeader("status"), Self:status )
Local aFilAtiv     := IIF( VALTYPE(Self:filtrosAtividades) <> "U", STRTOKARR(Self:filtrosAtividades, ','), {})
Local cQryAux      := ""
Local cOrderBy     := ""
Local nI           := 0

Default lTaskEquip := .F.

	//inclusão de filtros a serem considerados ao gerar a exportação
	//filtro de data, se data for maior ou igual a data de hoje
	If !Empty(cDataIni)
		Aadd(aFiltro, {RetSqlName('NTA'), " AND NTA001.NTA_DTFLWP >= '" + cDataIni + "' "})
	EndIf

	//Se a data for menor ou igual a data de hoje mais 7 dias
	If !Empty(cDataFim)
		Aadd(aFiltro, {RetSqlName('NTA'), " AND NTA001.NTA_DTFLWP <= '" + cDataFim + "' "})
	EndIf

	If !Empty(cTipos)
		Aadd(aFiltro, {RetSqlName('NTA'), " AND NTA001.NTA_CTIPO IN " + formatIn(cTipos,',') + " "})
	EndIf

	If !Empty(cStatus)
		If Len( Alltrim(cStatus) ) == 1
			Aadd(aFiltro, {RetSqlName('NQN'), " AND NQN001.NQN_TIPO = '1'"})//Status pendente
		else
			Aadd(aFiltro, {RetSqlName('NQN'), " AND NQN001.NQN_COD IN " + formatIn(cStatus,',') + " "})
		Endif
	Endif
	
	If Empty(cResp) .and. len(aFilAtiv) == 0
		If !lTaskEquip //Não mostra as tarefas da equipe
			Aadd(aFiltro, {RetSqlName('NTE'), " AND NTA001.NTA_COD = NTE_CFLWP AND EXISTS (SELECT 1 FROM " + RetSqlName('RD0') + " WHERE RD0_CODIGO = NTE_CPART AND RD0_USER = '" + __CUSERID + "') "})
		Else
			//Mostra as tarefas da equipe
			Aadd(aFiltro, {RetSqlName('NTE'), " AND NTA001.NTA_COD = NTE_CFLWP AND EXISTS (SELECT 1 FROM " + RetSqlName('RD0') + " WHERE RD0_CODIGO = NTE_CPART AND RD0_CODIGO IN "+FormatIn(getEquipe(__CUSERID),',')+" )"})
		Endif
	Endif

	// Filtros do painel de atividades
	If Len(aFilAtiv) > 0 .or. !Empty(cResp)
		cQryAux := ''
		If !Empty(cResp)
			cQryAux += " EXISTS (SELECT 1 FROM " + RetSqlName('NTE') + " NTE1 WHERE NTE1.D_E_L_E_T_ = '' AND NTA001.NTA_COD = NTE1.NTE_CFLWP AND NTE1.NTE_CPART IN " + FormatIn(cResp,',') + " ) "
		Endif
		

		For nI := 1 To Len(aFilAtiv)
			cQryAux += IIF( !Empty(cQryAux), " OR ", "" ) + WsJurCWhrAtv(aFilAtiv[nI])
		Next nI
		cQryAux := StrTran(cQryAux,'NTA.','NTA001.')
		
		Aadd(aFiltro, { RetSqlName('NTA'), " AND ( " + cQryAux + " ) " } )
	EndIf

	Aadd(aFiltro, {RetSqlName('NTA'), " AND 1 = 1"})

	//-- Inclusão dos campos que serão utilizados no relatório
	aAdd(aCamps, {"Número do Processo",       "  -  ( Instancias do Processo )", "NUQ_NUMPRO", "NTA", "NUQ", "NTA001", "NUQFUP", "08", "C", "NUQFUP.NUQ_COD = NTA001.NTA_CINSTA",                 "",           .F., "NUMPRO1",  ""})
	aAdd(aCamps, {"Tipo de Follow-up" ,       "  -  ( Tipos de Follow Up )",     "NQS_DESC"  , "NTA", "NQS", "NTA001", "NQS001", "05", "C", "",                                                   "NTA_DTIPO",  .T., "DESC2",    ""})
	aAdd(aCamps, {"Data do Follow-up ",       "  -  ( Follow-ups )",             "NTA_DTFLWP", "NTA", "NTA", "NTA001", "NTA001", "08", "D", "",                                                   "",           .T., "DTFLWP3",  ""})	
	aAdd(aCamps, {"Descrição do Follow-up",   "  -  ( Follow-ups )",             "NTA_DESC",   "NTA", "NTA", "NTA001", "NTA001", "27", "M", "",                                                   "",           .T., "DESC4",    ""})
	aAdd(aCamps, {"Hora do Follow-up",        "  -  ( Follow-ups )",             "NTA_HORA",   "NTA", "NTA", "NTA001", "NTA001", "09", "C", "",                                                   "",           .T., "HORA5",    ""})
	aAdd(aCamps, {"Autor",                    "  -  ( Pólo Ativo )",             "NT9_NOME",   "NT9", "NT9", "NT9001", "NT9001", "16", "C", "NT9001.NT9_TIPOEN= '1' AND NT9001.NT9_PRINCI = '1'", "",           .F., "NOME6",    ""})
	aAdd(aCamps, {"Réu",                      "  -  ( Pólo Passivo )",           "NT9_NOME",   "NT9", "NT9", "NT9002", "NT9002", "16", "C", "NT9002.NT9_TIPOEN= '2' AND NT9002.NT9_PRINCI = '1'", "",           .F., "NOME7",    ""})
	aAdd(aCamps, {"Correspondente",           "  -  ( Fornecedores )",           "A2_NOME",    "NUQ", "SA2", "NUQFUP", "SA2001", "04", "C", "",                                                   "NUQ_DCORRE", .F., "",         ""})
	aAdd(aCamps, {"Prognóstico",              "  -  ( Assuntos Juridicos )",     "NSZ_CPROGN", "NSZ", "NSZ", "NSZ001", "NSZ001", "54", "C", "",                                                   "",           .F., "CPROGN8",  ""})
	aAdd(aCamps, {"Valor Provisão",           "  -  ( Assuntos Juridicos )",     "NSZ_VLPROV", "NSZ", "NSZ", "NSZ001", "NSZ001", "C7", "N", "",                                                   "",           .F., "VLPROV12", ""})
	aAdd(aCamps, {"Comarca ",                 "  -  ( Comarca )",                "NQ6_DESC",   "NUQ", "NQ6", "NUQFUP", "NQ6FUP", "17", "C", "NUQFUP.NUQ_COD = NTA001.NTA_CINSTA ",                "NUQ_DCOMAR", .F., "DESC9",    ""})
	aAdd(aCamps, {"Foro / Tribunal ",         "  -  ( Foro / Tribunal )",        "NQC_DESC",   "NUQ", "NQC", "NUQFUP", "NQCFUP", "19", "C", "NUQFUP.NUQ_COD = NTA001.NTA_CINSTA ",                "NUQ_DLOC2N", .F., "DESC10",   ""})
	aAdd(aCamps, {"Vara / Camara ",           "  -  ( Vara / Camara )",          "NQE_DESC",   "NUQ", "NQE", "NUQFUP", "NQEFUP", "21", "C", "NUQFUP.NUQ_COD = NTA001.NTA_CINSTA ",                "NUQ_DLOC3N", .F., "DESC11",   ""})
	aAdd(aCamps, {"Resultado Follow-up",      "  -  ( Resultado de Followup )",  "NQN_DESC",   "NTA", "NQN", "NTA001", "NQN001", "22", "C", "NQN001.NQN_COD = NTA001.NTA_CRESUL",                 "NTA_DRESUL", .T., "DESC13",   ""})
	aAdd(aCamps, {"Responsáveis",             "  -  ( Resp Follow-up )",         "NTE_DPART",  "NTA", "NTE", "NTA001", "NTE001", "06", "C", "",                                                   "",           .T., "",         ""})

	// Campos do order by
	cOrderBy := "NTA_DTFLWP,NTA_HORA"

	//-- Chama a Exportação passando a estrutura dos campos
	J108ExpPer(1 ,aCamps ,'' ,.F. ,.F. ,"" ,aFiltro , .F., {}, 0, cNomeArq, .T., .F., 'NSZ_FILIAL',,,,cOrderBy)

	//-- Monta Json para o Download
	Self:SetContentType("application/json")
	oResponse['operation'] := "ExportTarefasVencer"
	oResponse['export']    := {}
	Aadd(oResponse['export'], JsonObject():New())

	oResponse['export'][1]['namefile'] := JConvUTF8(substr(cNomeArq,8))
	oResponse['export'][1]['filedata'] := encode64(DownloadBase(cNomeArq))

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RelPDF
Gera relatorio de pauta das tarefas a vencer - Relatório em PDF

@author SIGAJURI
@since 12/12/2019
@param [Opcional] periFilt  - Período filtrado (1: Hoje
                                                2:Amanhã
                                                3:Semana Corrente
                                                4:Atrasados em aberto
                                                5: Periodo de 7 dias a contar com o dia atual)
@param [Opcional] status   - Status do Follow-up
@param dataIni - Informe a data incial para busca
@param dataFim - Informe a data final para busca
@param lWSTlegal            - Indica se a chamada do serviço é feita via Totvs legal
@param showTaskMembers      - Indica se irá filtrar tarefas de todos os membros da equipe
@param filtrosAtividades    - String - Lista de filtros do painel de atividades (valores separados por virgula)


@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURFWREST/exportPauta
/*/
//-------------------------------------------------------------------
WSMETHOD GET RelPDF WSRECEIVE periFilt, status, dataIni, dataFim, lWSTlegal, showTaskMembers, filtrosAtividades WSREST JURFWREST
Local aArea        := GetArea()
Local cThread      := SubStr(AllTrim(Str(ThreadId())),1,4)
Local cQuery       := ''
Local cWhere       := ''
Local cQryAux      := ""
Local cTipos       := IIF( VALTYPE(Self:GetHeader("tipos")) <> "U", Self:GetHeader("tipos"), "")
Local cResp        := IIF( VALTYPE(Self:GetHeader("resp")) <> "U", Self:GetHeader("resp"), "")
Local aFilAtiv     := IIF( VALTYPE(Self:filtrosAtividades) <> "U", STRTOKARR(Self:filtrosAtividades, ','), {})
Local cStatus      := IIF( VALTYPE(Self:GetHeader("status")) <> "U", Self:GetHeader("status"), Self:status)
Local cPerifilt    := Self:periFilt
Local cDataIni     := Self:dataIni
Local cDataFim     := Self:dataFim
Local lWSTlegal    := Self:lWSTlegal
local lTaskEquip   := Self:showTaskMembers
Local cAlias       := GetNextAlias()
Local cUser        := __CUSERID
Local cCaminho     := "\spool\"
Local cNomeArq     := JurTimeStamp(1) + "_relatoriopauta_" + RetCodUsr() 
Local oResponse    := JsonObject():New()
Local nI           := 0

Default cPerifilt  := '5' //proximos 7 dias
Default lTaskEquip := .F.
Default lWSTlegal  := .F.

	//-- Monta Json para o Download
	Self:SetContentType("application/json")
	oResponse['operation'] := "RelatorioPauta"
	oResponse['pauta']     := {}

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cCaminho := StrTran(cCaminho,"\","/")
	Endif

	If Empty(cResp) .and. len(aFilAtiv) == 0
		If lTaskEquip
			cWhere := " RD0.RD0_CODIGO IN "+FormatIn(getEquipe(__CUSERID),',')+" "
		Else
			cWhere := " RD0.RD0_USER = '" + __CUSERID + "' "
		EndIf
	EndIf

	// Filtros do painel de atividades
	If Len(aFilAtiv) > 0 .OR. !Empty(cResp)
		cQryAux := ''
		If !Empty(cResp)
			cQryAux += " EXISTS (SELECT 1 FROM " + RetSqlName('NTE') + " NTE1 WHERE NTE1.D_E_L_E_T_ = ' ' "
			cQryAux += " AND NTA.NTA_COD = NTE1.NTE_CFLWP AND NTE1.NTE_CPART IN " + FormatIn(cResp,',') + " ) "
		Endif

		For nI := 1 To Len(aFilAtiv)
			cQryAux += IIF( !Empty(cQryAux), " OR ", "" ) + WsJurCWhrAtv(aFilAtiv[nI])
		Next nI

		cWhere += " ( " + cQryAux + " ) "
	EndIf

	cQuery := JWsLTQryFup('', cStatus, cTipos, cDataIni, cDataFim, cPeriFilt, , , lWSTlegal, cWhere)

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	If (cAlias)->(!Eof())
		While (cAlias)->(!Eof())
			NWG->(DbSetOrder(3)) //NWG_FILIAL+NWG_CUSER+NWG_SECAO+NWG_FILORI+NWG_CAJURI+DTOS(NWG_DTFLWP)+NWG_HORA
			If !(NWG->(dbSeek(xFilial("NWG") + cUser + cThread + (cAlias)->FILIAL + (cAlias)->CAJURI + (cAlias)->NTA_DTFLWP + (cAlias)->NTA_HORA )))
				If NWG->(RecLock('NWG',.T. ))
					NWG->NWG_FILIAL := xFilial("NWG")
					NWG->NWG_CAJURI := (cAlias)->CAJURI
					NWG->NWG_CODFOL := (cAlias)->NTA_COD
					NWG->NWG_DTFLWP := STOD((cAlias)->NTA_DTFLWP)
					NWG->NWG_CUSER  := cUser
					NWG->NWG_HORA   := (cAlias)->NTA_HORA
					NWG->NWG_SECAO  := cThread
					NWG->NWG_FILORI := (cAlias)->FILIAL
					NWG-> (MsUnlock())
				Endif
			EndIf
			(cAlias)->(dbSkip())
		End

		If Existblock( 'JURR106P' )
			U_JURR106P(cUser, cThread,cNomeArq + ".rel", cCaminho)
		Else
			JURR106P(cUser, cThread, cNomeArq + ".rel", cCaminho, ,aFilAtiv, cDataIni, cDataFim, cTipos, cStatus, cResp)
		EndIf
		
		DelRegFila(cUser, cThread)
	
		Aadd(oResponse['pauta'], JsonObject():New())
		
		oResponse['pauta'][1]['namefile'] := JConvUTF8(cNomeArq + ".pdf")
		oResponse['pauta'][1]['filedata'] := encode64(DownloadBase(cCaminho + cNomeArq + ".pdf"))


	Endif
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	
(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLTQryFup(cCodFup, cStatsFup, cCateFilt, cDataIni, cDataFim, cPeriFilt, cSearchKey, cNumPro, lWSTlegal, cWhere)
Criação de query de follow-ups

@param [Opcional] page       - Numero da Página
@param [Opcional] pageSize   - Quantidade de registros por pagina
@param [Opcional] cCodFup    - Código do Follow-up
@param [Opcional] cStatsFup  - Status do Follow-up
@param [Opcional] cCateFilt  - Categoria do Follow-up
@param [Opcional] cDataIni   - Data inicial do Follow-up
@param [Opcional] cDataFim   - Data final do Follow-up
@param [Opcional] cPeriFilt  - Período filtrado (1: Hoje/ 2:Amanhã/ 3:Semana Corrente/ 4:Atrasados em aberto /
												 5: Periodo de 7 dias a contar com o dia atual )
@param [Opcional] cSearchKey - Valor a ser pesquisado nos campos  NTA_DESC, NQS_DESC, NUQ_NUMPRO E NT9_NOME
@param [Opcional] cNumPro    - Número do processo
@param [Opcional] lWSTlegal  - Vem do totvs legal?
@param [Opcional] cWhere     - Trecho inicial da cláusula WHERE a ser modificada

@author SIGAJURI
@since 11/12/2019

@return Query final da lista de um ou mais follow-ups
/*/
//-------------------------------------------------------------------
Function JWsLTQryFup(cCodFup, cStatsFup, cCateFilt, cDataIni, cDataFim, cPeriFilt, cSearchKey, cNumPro, lWSTlegal, cWhere)
Local cQuerySel   := ""
Local cQueryFrm   := ""
Local cQueryWhr   := ""
Local cQueryOrd   := ""

Default cStatsFup  := ""
Default cCateFilt  := ""
Default cPeriFilt  := "0"
Default cSearchKey := ""
Default cNumPro    := ""
Default cDataIni   := ""
Default cDataFim   := ""
Default lWSTlegal  := .F.
Default cWhere     := ""

// Clausula Select ---------------------------------------------------------------------------------------
	cQuerySel := "SELECT NTA.NTA_COD, "
	cQuerySel +=        "RD0.RD0_SIGLA, "
	cQuerySel +=        "RD0.RD0_USER, "
	cQuerySel +=        "RD0.RD0_CODIGO, "
	cQuerySel +=        "NTA.NTA_DTFLWP, "
	cQuerySel +=        "NQC.NQC_DESC, "
	cQuerySel +=        "NUQ.NUQ_NUMPRO, "
	cQuerySel +=        "NQU.NQU_DESC ACAO, "
	cQuerySel +=        "NTA.NTA_CTIPO CODTIPOFU, "
	cQuerySel +=        "NQS.NQS_DESC TIPOFU, "
	cQuerySel +=        "NQC.NQC_DESC FORO, "
	cQuerySel +=        "NQC.NQC_ENDERE ENDE, "
	cQuerySel +=        "NQM.NQM_DESC PREP, "
	cQuerySel +=        "NQM.NQM_TELEFO TEL, "
	cQuerySel +=        "NQM.NQM_EMAIL EMAIL, "
	cQuerySel +=        "NQE.NQE_DESC VARA, "
	cQuerySel +=        "SA1.A1_NOME EMPRESA, "

	if (Upper(TcGetDb())) == "ORACLE"
		cQuerySel +=    "TO_CHAR(SUBSTR(NSZ.NSZ_DETALH,1,4000)) DETAIL, "
	Else
		cQuerySel +=    "CAST(NSZ.NSZ_DETALH AS VARCHAR(4000)) DETAIL, "
	Endif

	cQuerySel +=        "NSZ.NSZ_VLPROV VPROV, "
	cQuerySel +=        "NSZ.NSZ_COD CAJURI, "
	cQuerySel +=        "NTA.NTA_CAJURI, "
	cQuerySel +=        "NTA.NTA_CRESUL, "
	cQuerySel +=        "NTA.NTA_HORA, "
	cQuerySel +=        "NTA.NTA_DURACA, "

	if (Upper(TcGetDb())) == "ORACLE"
		cQuerySel +=    "TO_CHAR(SUBSTR(NTA.NTA_DESC,1,4000)) NTA_DESC, "
	Else
		cQuerySel +=    "CAST(NTA.NTA_DESC AS VARCHAR(4000)) NTA_DESC, "
	Endif

	cQuerySel +=        "NT9A.NT9_NOME  POLOATIVO, "
	cQuerySel +=        "NT9A.NT9_CGC   ATIVO_CGC, "
	cQuerySel +=        "NT9R.NT9_NOME  POLOPASSIVO, "
	cQuerySel +=        "NT9R.NT9_CGC   PASSIVO_CGC, "
	cQuerySel +=        "NTA.NTA_FILIAL FILIAL, "
	cQuerySel +=        "NSZ.NSZ_TIPOAS TIPOASJ, "
	cQuerySel +=        "NSZ.NSZ_SITUAC SITUAC, "
	cQuerySel +=        "NQN.NQN_DESC   DESCRESUL "

	If lWSTlegal
		cQuerySel += ", NYB.NYB_CORIG   ASSJURORIG "
		cQuerySel += ", NQN.NQN_TIPO    TIPO_STATUS "
		cQuerySel += ", NTA.NTA_REAGEN  REAGEN "
		cQuerySel += ", NTE.NTE_CPART   CPART "
		cQuerySel += ", NSZ_SOLICI SOLIC"
		cQuerySel += ", COALESCE(NYA.NYA_DESC,'"+STR0034+"') TPSOLIC"//Tipo não definido
		cQuerySel += ", NSZ_NOMEMA NOMEMARCA"
		cQuerySel += ", NY7_DESC SITMARCA"
	EndIf

	// Clausula From -----------------------------------------------------------------------------------------
	cQueryFrm := " FROM " + RetSqlName('NTA') +" NTA "
	cQueryFrm +=        "INNER JOIN " + RetSqlName('NSZ') + " NSZ ON ( "
	cQueryFrm +=                  "NSZ.NSZ_FILIAL = NTA.NTA_FILIAL "
	cQueryFrm +=              "AND NSZ.NSZ_COD  = NTA.NTA_CAJURI "
	cQueryFrm +=              "AND NSZ.D_E_L_E_T_ = ' ') "
	cQueryFrm +=      " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQueryFrm +=           " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQueryFrm +=              " AND SA1.A1_COD = NSZ.NSZ_CCLIEN "
	cQueryFrm +=              " AND SA1.A1_LOJA = NSZ.NSZ_LCLIEN "
	cQueryFrm +=              " AND SA1.D_E_L_E_T_ = ' ' "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NUQ') + " NUQ ON (NUQ.NUQ_CAJURI = NTA.NTA_CAJURI "
	cQueryFrm +=              "AND NUQ.NUQ_INSATU  = '1' "
	cQueryFrm +=              "AND NUQ.NUQ_FILIAL  = NTA_FILIAL "
	cQueryFrm +=              "AND NUQ.D_E_L_E_T_ = ' ' ) "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NQU') + " NQU ON ( "
	cQueryFrm +=                  "NQU.NQU_COD  = NUQ.NUQ_CTIPAC "
	cQueryFrm +=              "AND NQU.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NTE') + " NTE ON (NTE.NTE_FILIAL = NTA_FILIAL "
	cQueryFrm +=              "AND NTE.NTE_CFLWP  = NTA_COD "
	cQueryFrm +=              "AND NTE.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON (RD0.RD0_FILIAL = '"+xFilial('RD0') + "' "
	cQueryFrm +=              "AND RD0.RD0_CODIGO = NTE.NTE_CPART "
	cQueryFrm +=              "AND RD0.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NQS') + " NQS ON (NQS.NQS_COD = NTA.NTA_CTIPO "
	cQueryFrm +=              "AND NQS.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NQC') + " NQC ON (NQC.NQC_COD    = NUQ.NUQ_CLOC2N "
	cQueryFrm +=              "AND NQC.NQC_CCOMAR = NUQ.NUQ_CCOMAR "
	cQueryFrm +=              "AND NQC.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NQM') + " NQM ON (NQM.NQM_COD = NTA.NTA_CPREPO "
	cQueryFrm +=              "AND NQM.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NQE') + " NQE ON (NQE.NQE_COD = NUQ.NUQ_CLOC3N "
	cQueryFrm +=              "AND NQE.NQE_CLOC2N = NUQ.NUQ_CLOC2N "
	cQueryFrm +=              "AND NQE.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NT9') + " NT9A ON (NT9A.NT9_CAJURI = NTA.NTA_CAJURI "
	cQueryFrm +=              "AND NT9A.NT9_FILIAL  = NTA.NTA_FILIAL "
	cQueryFrm +=              "AND NT9A.NT9_PRINCI = '1' "
	cQueryFrm +=              "AND NT9A.NT9_TIPOEN = '1' "
	cQueryFrm +=              "AND NT9A.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName('NT9') + " NT9R ON (NT9R.NT9_CAJURI = NTA_CAJURI "
	cQueryFrm +=              "AND NT9R.NT9_FILIAL  = NTA.NTA_FILIAL "
	cQueryFrm +=              "AND NT9R.NT9_PRINCI = '1' "
	cQueryFrm +=              "AND NT9R.NT9_TIPOEN = '2' "
	cQueryFrm +=              "AND NT9R.D_E_L_E_T_ = ' ') "
	cQueryFrm +=        "LEFT JOIN " + RetSqlName("NQN") + " NQN  ON (NQN.NQN_COD = NTA.NTA_CRESUL) "
	cQueryFrm +=              "AND (NQN.NQN_FILIAL = '"+xFilial('NQN')+"') "

	IF lWSTlegal
		cQueryFrm +=        "LEFT JOIN " + RetSqlName("NYB") + " NYB  ON NYB.NYB_COD = NSZ.NSZ_TIPOAS "
		cQueryFrm +=              "AND NYB.NYB_FILIAL = '" + xFilial('NYB') + "' "
		cQueryFrm +=              "AND NYB.D_E_L_E_T_=' ' "

		cQueryFrm +=        " LEFT JOIN "+RetSqlName("NYA")+" NYA ON "
		cQueryFrm +=              " NYA.NYA_FILIAL = '" + xFilial('NYA') + "' "
		cQueryFrm +=              " AND NSZ.NSZ_CTPSOL = NYA.NYA_COD "
		cQueryFrm +=              " AND NYA.D_E_L_E_T_ = ' ' "

		cQueryFrm +=        " LEFT JOIN "+RetSqlName("NY7")+" NY7 ON "
		cQueryFrm +=              " NY7.NY7_FILIAL = '" + xFilial('NY7') + "' "
		cQueryFrm +=              " AND NY7.NY7_COD = NSZ.NSZ_CSITMA"
		cQueryFrm +=              " AND NY7.D_E_L_E_T_ = ' ' "
	EndIf

	//Clausula Where ----------------------------------------------------------------------------------------
	cQueryWhr +=  " WHERE NTA.D_E_L_E_T_ = ' ' "

	If lWSTlegal .And. !Empty(cWhere)
		cQueryWhr += " AND " + cWhere
	Else
		cQueryWhr += " AND RD0.RD0_USER = '" + __CUSERID + "' "
	EndIf

	// Código do Follow-up
	If !Empty(cCodFup)
		// Clausula Where DetailFup
		cQueryWhr +=  " AND NTA.NTA_COD = '" + cCodFup + "'"
		cQueryWhr +=  " AND NTA.NTA_FILIAL = '" + xFilial('NTA') + "'""
	Else

		// Clausula Where ListFup
		If !Empty(cStatsFup)
			If Len( Alltrim(cStatsFup) ) == 1
				cQueryWhr += " AND NQN.NQN_TIPO IN ('" + AllTrim(cStatsFup) + "') "
			Else
				cQueryWhr += " AND NQN.NQN_COD IN " + formatIn(AllTrim(cStatsFup),',') + " "
			EndIf
		EndIf

		If !Empty(cCateFilt)
			cCateFilt := "'"+StrTran(cCateFilt,",","','")+"'"
			cQueryWhr += "AND NTA.NTA_CTIPO IN(" + cCateFilt + ") "
		EndIf

		If Empty(cDataIni) .AND. Empty(cDataFim)
			Do Case
				Case AllTrim(cPeriFilt) == '1'
					cQueryWhr += "AND NTA.NTA_DTFLWP =  '" + dtos(date()) + "' "
				Case AllTrim(cPeriFilt) == '2'
					cQueryWhr += "AND NTA.NTA_DTFLWP =  '" + dtos(DaySum(date(),1)) + "' "
				Case AllTrim(cPeriFilt) == '3'
					cQueryWhr += "AND NTA.NTA_DTFLWP >= '" + dtos(DataFormat('1')) + "' "
					cQueryWhr += "AND NTA.NTA_DTFLWP <= '" + dtos(DataFormat('2')) + "' "
				Case AllTrim(cPeriFilt) == '4'
					cQueryWhr +="AND NTA.NTA_DTFLWP < '" + dtos(date()) + "' "
				Case AllTrim(cPeriFilt) == '5'
					cQueryWhr += " AND NTA.NTA_DTFLWP >= '" + dtos(date()) + "' "
					cQueryWhr += " AND NTA.NTA_DTFLWP <= '" + dtos(date() + 7 ) + "' "
			End Case
		Else
			If !Empty(cDataIni)
				cQueryWhr += " AND NTA.NTA_DTFLWP >= '" + StrTran(cDataIni,"-","") + "' "
			EndIf

			If !Empty(cDataFim)
				cQueryWhr += " AND NTA.NTA_DTFLWP <= '" + StrTran(cDataFim,"-","") + "' "
			EndIf
		EndIf

		// SearchKey
		If !Empty(cSearchKey)
			cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

			cQueryWhr +=  " AND ( "+ JurFormat("NTA_DESC", .T.,.T.) +" Like Lower('%" + cSearchKey + "%') "
			cQueryWhr +=  " OR "+ JurFormat("NQS_DESC", .T.,.T.) + " Like Lower('%" + cSearchKey + "%') "
			cQueryWhr +=  " OR "+ JurFormat("NUQ_NUMPRO", .T.,.T.) + " Like Lower('%" + cSearchKey + "%') "
			cQueryWhr +=  " OR EXISTS(SELECT 1 "
			cQueryWhr +=            " FROM " + RetSqlName('NT9')
			cQueryWhr +=            " WHERE NT9_CAJURI = NSZ.NSZ_COD ""
			cQueryWhr +=              " AND "+ JurFormat("NT9_NOME", .T.,.T.) + " LIKE Lower('%" + cSearchKey + "%'))  ) "

		EndIf

		// Numero do processo
		If !Empty(cNumPro)
			cNumPro := Lower(StrTran(JurLmpCpo( cNumPro,.F. ),'#',''))
			cQueryWhr  +=  " AND "+ JurFormat("NUQ_NUMPRO", .T.,.T.) + " Like Lower('%" + cNumPro + "%') "
		EndIf
	EndIf

	// Clausula Order ----------------------------------------------------------------------------------------
	cQueryOrd  :=  "ORDER BY NTA.NTA_DTFLWP, NTA.NTA_HORA "


return cQuerySel + cQueryFrm + cQueryWhr + cQueryOrd

//-----------------------------------------------------------------
/*/{Protheus.doc} DelRegFila
Deleta a Thread da fila de impressão após exportar os dados

@param   cUser   - Código do usuário Protheus
@param   cThread - Numero da Threa atual da exportação
@Return  lRet    - Verifica se executou a query no banco
@since 12/12/2019
/*/
//-----------------------------------------------------------------
Static Function DelRegFila(cUser, cThread)
Local lRet   := .T.
Local cQuery := ""

	cQuery += "DELETE FROM " + RetSqlName("NWG")
	cQuery += " WHERE NWG_FILIAL = '" + xFilial("NWG") + "'"
	cQuery +=      " AND NWG_CUSER = '" + cUser + "'"
	cQuery +=      " AND NWG_SECAO = '" + cThread + "'"

	lRet := TcSqlExec(cQuery) < 0

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} getEquipe
Busca os participates da equipe, incluindo o lider

@param   cUser   - Código do usuário Protheus
@since 12/12/2019
/*/
//-----------------------------------------------------------------
Static Function getEquipe(cUser)
Local cRet   := ''
Local cAlias := getNextAlias()
Local cQuery := ''

	cQuery += "SELECT NZ9_CPART CODPART 
	cQuery +=  " FROM "+RetSqlName('NZ9')+" NZ9 "
	cQuery += " WHERE NZ9.NZ9_CEQUIP IN (SELECT NZ8.NZ8_COD "
	cQuery +=							 " FROM "+RetSqlName('RD0')+" RD0 "
	cQuery +=							" INNER JOIN "+RetSqlName('NZ8')+" NZ8 ON "
	cQuery +=								" NZ8.NZ8_FILIAL = ' "+xFilial('NZ8')+" ' "
	cQuery +=								" AND NZ8.D_E_L_E_T_ = ' ' "
	cQuery +=							" INNER JOIN "+RetSqlName('NZ9')+" NZ9 ON  "
	cQuery +=								" NZ9.NZ9_FILIAL = NZ8.NZ8_FILIAL "
	cQuery +=								" AND NZ9.NZ9_CEQUIP = NZ8.NZ8_COD "
	cQuery +=								" AND NZ9.D_E_L_E_T_ = ' ' "
	cQuery +=							" WHERE  RD0.RD0_FILIAL = ' "+xFilial('RD0')+" ' "
	cQuery +=							  " AND RD0.RD0_USER = '"+cUser+"' "
	cQuery +=							  " AND ( NZ8_CPARTL = RD0.RD0_CODIGO  "
	cQuery +=									" OR NZ9_CPART = RD0.RD0_CODIGO ) "
	cQuery +=							  " AND RD0.D_E_L_E_T_ = ' ' ) "
	cQuery += " AND NZ9.D_E_L_E_T_ = ' ' "
	cQuery += " AND NZ9.NZ9_FILIAL = ' "+xFilial('NZ8')+" ' "

	cQuery += " UNION "

	cQuery += "SELECT "
	cQuery +=     "RD0_CODIGO CODPART"
	cQuery += "FROM "+RetSqlName('RD0')+" RD0 "
	cQuery += "WHERE "
	cQuery +=     "RD0.RD0_FILIAL = '"+xFilial('RD0')+"' "
	cQuery +=     "AND RD0.RD0_USER = '"+cUser+"' "
	cQuery +=     "AND RD0.D_E_L_E_T_ = ' ' "


	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While (cAlias)->(!Eof())
		cRet += (cAlias)->CODPART + ','
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

	If !Empty(cRet)
		cRet := SubStr(cRet,1,Len(cRet)-1)
	Endif


Return cRet

