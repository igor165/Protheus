#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "GPEM921B.CH"


/*/{Protheus.doc} function fSendComp
Realiza a consulta dos dados de acordo com a competência e os envia através da API.
@author  hugo.de.oliveira
@since   25/11/2019
@version 1.0
/*/
Function GPEM921B( aParam )
	Local aData	:= {}
	Local aMV	:= {}

	DEFAULT aParam 	:= {}

	Conout( EncodeUTF8( STR0001 ) ) // STR0001: "JOB de Consulta de Eventos Iniciado"

	If !Empty( aParam )
		RpcSetType(3) // Licença
		RPCsetEnv(aParam[1], aParam[2]) // Abertura do Ambiente

		// Verifica se a rotina está sendo executada e realiza o Lock
		If LockByName( "GPEM921B" + cEmpAnt + cFilAnt, .T., .T., .T. )
			// Seleção dos Parâmetros
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_GPEAMBE",, "" ) ) ) // Tipo de Ambiente a ser utilizado
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_GPEMURL",, "" ) ) ) // Ambiente TSS Configurado
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI01",, "" ) ) ) // URL do ambiente com serviço Rest Configurado
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI03",, "" ) ) ) // Tipo de Inscrição
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI04",, "" ) ) ) // Inscrição
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI09",, "" ) ) ) // Serviço, método e a versão da API de Envio e Consulta do Middleware

			aData := fGetData( aMV ) // Selecão dos dados com base nos filtros e suas regras
			fGetEvt( aData, aMV )	// Chamada da API de consulta

			// Libera a rotina após finalizar a execução das Threads
			UnLockByName("GPEM921B" + cEmpAnt + cFilAnt, .T., .T., .T.)
		Else
			Conout( EncodeUTF8( STR0002 ) ) // STR0002: "A rotina 'GPEM921B' está sendo executada por outro processo"
		EndIf

		RpcClearEnv()
	Else
		Conout( EncodeUTF8( STR0003 ) ) // STR0003: "Erro no recebimento dos parâmetros utilizados na execução do JOB"
	EndIf

	Conout( EncodeUTF8( STR0004 ) ) // STR0004: "JOB de Consulta de Eventos Finalizado"
Return


/*/{Protheus.doc} function fGetData
Retorna todos os dados para processamento
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fGetData( aMV )
	Local aData 	:= {}
	Local cEvt 		:= ""
	Local cRetKey	:= ""
	Local cXML 		:= ""
	Local cRJE		:= "RJE"

	// Consulta a tabela de Eventos
	DbSelectArea( cRJE )
	( cRJE )->( DbSetOrder( 2 ) ) // RJE_TPINSC, RJE_INSCR
	DbSeek( aMV[4] + SUBSTR( aMV[5], 0, 8 ) )

	While ( cRJE )->( !EOF() ) .AND. aMV[4] + SUBSTR( aMV[5], 0, 8 ) == ALLTRIM( ( cRJE )->RJE_TPINSC ) + ALLTRIM( ( cRJE )->RJE_INSCR )
		If ( cRJE )->RJE_STATUS == "2" // Aguardando Retorno
			cEvt	:= ALLTRIM( ( cRJE )->RJE_EVENTO )
			cRetKey	:= ALLTRIM( ( cRJE )->RJE_RETKEY )
			cXML	:= ALLTRIM( ( cRJE )->RJE_XML )
			Aadd( aData, { cEvt, cRetKey, cXML } )
		EndIf

		( cRJE )->( dbSkip() )
	EndDo

	aData := fSortEvt( aData) // Ordenação dos eventos
Return aData


/*/{Protheus.doc} function fGetEvt
Realiza a consulta do retorno do processamento do Middleware.
@author  hugo.de.oliveira
@since   01/10/2019
@version 1.0
/*/
Static Function fGetEvt( aData, aMV )
	Local oMID
	Local oRet
	Local oItem
	Local oBody
	Local nY		:= 1
	Local nX 		:= 1
	Local lRet	 	:= .F.
	Local lRetResp	:= .T.
	Local aHeader   := {}
	Local aLote 	:= {}
	Local cBody		:= ""
	Local cEvtRJE 	:= ""
	Local cRetKey 	:= ""
	Local cSrcBra	:= ""
	Local cRJEAlias	:= "RJE"
	Local cRJ9Alias	:= "RJ9"
	Local nQtdeReg 	:= Len( aData )
	Local cEvenExcl := "S3000"
	Local cEvenTot 	:= "S1200/S2299/S2399"
	Local cVersTss	:= ""
	Local cClient	:= ""
	Local cSecret	:= ""
	Local nFimTxt	:= 0
	Local cToken	:= ""

	If nQtdeReg < 1
		Return
	EndIf

	// Divide os dados em lotes de 50 itens
	aData 	 := fGetLote( aData )
	nQtdeReg := Len( aData )

	// Pega a entidade do cadastro do trabalhador
	DbSelectArea( cRJ9Alias )
	( cRJ9Alias )->( DbSetOrder( 5 ) ) // RJ9_NRINSC, RJ9_INI
	( cRJ9Alias )->( DbGoTop() )

	If ( cRJ9Alias )->( DbSeek( aMV[5] ) ) .Or. ( cRJ9Alias )->( DbSeek( SubStr( aMV[5], 1, 8 ) ) )
		If ( cRJ9Alias )->( ColumnPos( "RJ9_IDENT" ) ) > 0
			cSrcBra := ( cRJ9Alias )->RJ9_IDENT
			If ( cRJ9Alias )->( ColumnPos( "RJ9_CLIENT" ) ) > 0
				cClient := ( cRJ9Alias )->RJ9_CLIENT
				cSecret := ( cRJ9Alias )->RJ9_SECRET
			EndIf
		EndIf
	EndIf

	//Verifica versão do TSS
	If FindFunction("GpeVerTSS")
		cVersTss 	:= GpeVerTSS(cSrcBra)
		nFimTxt		:= AT( "|", cVersTss )
		cVersTss	:= alltrim(Substr(cVersTss, 1, nFimTxt -1))
	EndIf

	//Procura o token válido
	If  FindFunction("fGPETokenMid") .And. cVersTss >= "12.1.033" .And. !Empty(cClient) .And. !Empty(cSecret)
		cToken := fGPETokenMid(cClient,cSecret)
	EndIf

	// Montagem do Header
	If Empty(cToken)
		aadd(aHeader, "Content-Type: application/json; charset=UTF-8")
	Else
		aadd(aHeader, "TokenAuthTSS: " + cToken)
	EndIf

	// Processamento dos registros
	For nY := 1 To nQtdeReg
		For nX := 1 to LEN( aData[nY] )
			cEvtRJE	:= aData[nY][nX][1]
			cRetKey	:= aData[nY][nX][2]

			// Montagem dos dados do array de propriedades 'Lote'
			oItem	:= JsonObject():new()
			oItem["registryType"] := SUBSTR(cEvtRJE, 1, 1) + "-" + SUBSTR(cEvtRJE, 2)

			dbSelectArea( cRJEAlias )
			( cRJEAlias )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
			( cRJEAlias )->( DbGoTop() )

			If ( cRJEAlias )->( DbSeek( cEvtRJE + cRetKey ) )
				oItem['ticketCode'] := ALLTRIM( ( cRJEAlias )->RJE_TCK )
			EndIf

			oItem["registryKey"]		:= cRetKey
			oItem["returnRetResponse"]	:= lRetResp

			// Adiciona os items no array de Lote
			AAdd( aLote, oItem )

			FreeObj( oItem )
		Next nX

		// Montagem do Body
		oBody := JsonObject():new()
		oBody['sourceBranch']	:= cSrcBra	// Código Identificador da entidade TSS ( retornado na configuração do certificado)
		oBody['tpAmb']			:= aMV[1] 	// Parâmetro contendo o Tipo do Ambiente
		oBody['urlTSS']			:= aMV[2]	// Parâmetro contendo a URL do Ambiente

		// Adiciona o Array de Itens no 'Body'
		oBody["lote"] := aLote

		// Compress String And Set Response
		cBody := fCompress( @oBody )

		// Chamada da API
		oMID := FwRest():New( aMV[3] )
		oMID:setPath( "/" + aMV[6] + "/get/" )
		oMID:SetPostParams( cBody )

		// Verificação de Retorno
		FreeObj( oRet )
		oRet	:= JsonObject():New()

		lHeader := oMID:Post( aHeader )
		lRet 	:= FWJsonDeserialize( oMID:GetResult(), @oRet )

		If lHeader .And. lRet .And. LEN(oRet:ITEMS) > 0
			For nX := 1 To LEN(oRet:ITEMS)
				dbSelectArea( cRJEAlias )
				( cRJEAlias )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
				( cRJEAlias )->( DbGoTop() )

				If ( cRJEAlias )->( DbSeek( REPLACE(oRet:ITEMS[nX]:registrytype,"-","") + oRet:ITEMS[nX]:registrykey ) )
					Begin Transaction
						Reclock( cRJEAlias, .F.)
							( cRJEAlias )->RJE_STATUS	:= oRet:ITEMS[nX]:STATUSCODE
							( cRJEAlias )->RJE_RTN 		:= Decode64( oRet:items[nX]:XMLRETRESPONSE )
							( cRJEAlias )->RJE_RECIB	:= ALLTRIM( oRet:ITEMS[nX]:RECEIPTNUMBER )
						MsUnlock()

						If ( cRJEAlias )->RJE_EVENTO == cEvenExcl .And. oRet:ITEMS[nX]:STATUSCODE == "4"
						   fGrvExcOri(alltrim(( cRJEAlias )->RJE_KEY))
						Endif

						If ( cRJEAlias )->RJE_EVENTO $ cEvenTot .And. oRet:ITEMS[nX]:STATUSCODE == "4"
						   fGrvTotal( ( cRJEAlias )->RJE_FILIAL, ( cRJEAlias )->RJE_FIL, ( cRJEAlias )->RJE_TPINSC, ( cRJEAlias )->RJE_INSCR, ( cRJEAlias )->RJE_INI, ( cRJEAlias )->RJE_KEY, ( cRJEAlias )->RJE_RTN )
						EndIf

					End Transaction
				EndIf
			Next nX
		EndIf

		// Limpeza dos Objetos utilizados
		aLote := {}
		FreeObj( oBody )
		FreeObj( oItem )
		FreeObj( oRet )
		FreeObj( oMID )
	Next nY
Return

/*/{Protheus.doc} function fCompress
Compress String Object
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.

	// Set gzip format to Json Object
	cJson := oObj:toJSON()

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf

	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp


/*/{Protheus.doc} function fSortEvt
Realiza a ordenação dos eventos
@author  Hugo de Oliveira
@since   30/10/2019
@version 1.0
/*/
Static Function fSortEvt( aData)
	Local nX 		:= 1
	Local cEvtRJE 	:= ""
	Local nInd		:= 0

	// Cria uma nova posição no Array de dados para servir de "Índice" e assim poder ser ordenado
	For nX := 1 To Len( aData )
		cEvtRJE		:= aData[nX][1]

		// Eventos de Cadastro
		If cEvtRJE == "S1000" // Empregador
			nInd := 1
		ElseIf cEvtRJE == "S1070" // Processos
			nInd := 2
		ElseIf cEvtRJE == "S1005" // Estabelecimentos
			nInd := 3
		ElseIf cEvtRJE == "S1010" // Verbas
			nInd := 4
		ElseIf cEvtRJE == "S1020" // Lotações
			nInd := 5
		ElseIf cEvtRJE == "S1030" // Cargos
			nInd := 6
		ElseIf cEvtRJE == "S1040" // Funções
			nInd := 7
		ElseIf cEvtRJE == "S1050" // Horários
			nInd := 8

		// Eventos Não Periódicos
		ElseIf cEvtRJE == "S2190" // Adm Preliminar
			nInd := 9
		ElseIf cEvtRJE == "S2200" // Admissão
			nInd := 10
		ElseIf cEvtRJE == "S2300" // Início TSV
			nInd := 11
		ElseIf cEvtRJE == "S2205" // Alteração Cadastral
			nInd := 12
		ElseIf cEvtRJE == "S2206" // Alteração Contratual
			nInd := 13
		ElseIf cEvtRJE == "S2306" // Alteração Contratual TSV
			nInd := 14
		ElseIf cEvtRJE == "S2210" // CAT
			nInd := 15
		ElseIf cEvtRJE == "S2220" // Monitoramento Saúde Trabalhador
			nInd := 16
		ElseIf cEvtRJE == "S2221" // Exame Toxicológico
			nInd := 17
		ElseIf cEvtRJE == "S2230" // Afastamentos
			nInd := 18
		ElseIf cEvtRJE == "S2240" // Condições de trabalho
			nInd := 19
		ElseIf cEvtRJE == "S2245" // Treinamentos
			nInd := 20
		ElseIf cEvtRJE == "S2250" // Aviso Prévio
			nInd := 21
		ElseIf cEvtRJE == "S2298" // Reintegração
			nInd := 22
		ElseIf cEvtRJE == "S2299" // Rescisão
			nInd := 23
		ElseIf cEvtRJE == "S2299" // Rescisão
			nInd := 24
		ElseIf cEvtRJE == "S2399" // Término TSV
			nInd := 25
		ElseIf cEvtRJE == "S3000" // Exclusão
			nInd := 26

		// Periódicos
		ElseIf cEvtRJE == "S1200" // Folha
			nInd := 27
		ElseIf cEvtRJE == "S1210" // Pagamentos
			nInd := 28
		ElseIf cEvtRJE == "S1280" // Desoneração
			nInd := 29
		ElseIf cEvtRJE == "S1300" // Contribuições Sindicais
			nInd := 30
		EndIf

		AADD( aData[nX], nInd )
	Next nX

	// Ordena os dados
	ASORT(aData, , , { | x,y | x[4] < y[4] } )

Return aData


/*/{Protheus.doc} function fGetLote
Divide os dados em Lote
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fGetLote( aArray )
	Local aLote
	Local aClone	:= {}
	Local nSizeDef	:= 50
	Local nX		:= 1
	Local nPos		:= 1
	Local nEndPos	:= nSizeDef
	Local nSize 	:= Len(aArray)
	Local nSzClone	:= ( nSize / nSizeDef )

	// Caso os lotes não possuam tamanho completo de 50 itens
	If (nSize % nSizeDef) > 0
		nSzClone := INT(nSzClone) + 1
	EndIf

	aLote := ARRAY( nSzClone, {} )
	For nX := 1 To nSzClone
		aClone	:= {}
		For nPos := nPos  To nEndPos
			If  nPos <= nSize
				aadd( aClone, aArray[nPos] )
			EndIf
		Next nPos

		aLote[nX] := aClone
		nEndPos += nSizeDef
	Next nX

Return aLote

/*/{Protheus.doc} function fGetLote
Efetiva exclusão evento original
@author  Silvia Taguti
@since   18/12/2019
@version 1.0
/*/
Static Function fGrvExcOri(cRecibOr)

	Local aAreaRJE 		:= GetArea()
	Local cRJE			:= "RJE"
	Default cRecibOr 	:= ""

	dbSelectArea( cRJE )
	( cRJE )->(dbSetOrder(6))

	If ( cRJE )->(dbSeek( cRecibOr ) )
		Reclock( cRJE, .F.)
			( cRJE )->RJE_EXC := "1"
		( cRJE )->(MsUnlock())
	Endif

	RestArea( aAreaRJE )

Return


/*/{Protheus.doc} fGrvTotal()
Função que grava os totalizadores (S-5001/S-5003) na tabela RJE
@author allyson.mesashi
@since 03/02/2020
@version 1.0
@param cRJEFilial	= Filial da RJE
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cRJEIni		= Período do registro
@param cRJEKey		= Key do registro
@param cXMLRet		= XML de Retorno

/*/
Function fGrvTotal( cRJEFilial, cRJEFil, cRJETpIns, cRJEInsc, cRJEIni, cRJEKey, cXMLRet )

	Local lNovo		:= .T.
	Local nIni5001	:= At('<tot tipo="S5001">', cXMLRet)
	Local nFim5001	:= 0
	Local nIni5003	:= At('<tot tipo="S5003">', cXMLRet)
	Local nFim5003	:= 0
	Local nIniId	:= 0

	RJE->( dbSetOrder(4) )//RJE_EVENTO+RJE_KEY

	If nIni5001 > 0
		nIni5001 := At('<eSocial', cXMLRet, nIni5001)
		nFim5001 := At('</eSocial>', cXMLRet, nIni5001) + 10
		nIniId	 := At('<evtBasesTrab Id=', cXMLRet, nIni5001) + 18

		lNovo := !RJE->( dbSeek( "S5001" + cRJEKey ) )

		If RJE->(Reclock( "RJE", lNovo) )
			RJE->RJE_FILIAL	:= cRJEFilial
			RJE->RJE_FIL	:= cRJEFil
			RJE->RJE_TPINSC	:= cRJETpIns
			RJE->RJE_INSCR	:= cRJEInsc
			RJE->RJE_EVENTO	:= "S5001"
			RJE->RJE_INI	:= cRJEIni
			RJE->RJE_KEY	:= cRJEKey
			RJE->RJE_RETKEY	:= SubStr( cXMLRet, nIniId, 36 )
			RJE->RJE_VERS	:= "12"
			RJE->RJE_STATUS	:= "4"
			RJE->RJE_XML	:= SubStr( cXMLRet, nIni5001, nFim5001-nIni5001 )
			RJE->RJE_DTG	:= Date()
			RJE->RJE_HORAG	:= Time()
			RJE->( MsUnlock() )
		EndIf
		fGrvTotCS( RJE->RJE_FIL, RJE->RJE_TPINSC, RJE->RJE_INSCR, RJE->RJE_XML )
	EndIf

	If nIni5003 > 0
		nIni5003 := At('<eSocial', cXMLRet, nIni5003)
		nFim5003 := At('</eSocial>', cXMLRet, nIni5003) + 10
		nIniId	 := At('<evtBasesFGTS Id=', cXMLRet, nIni5003) + 18

		lNovo := !RJE->( dbSeek( "S5003" + cRJEKey ) )

		If RJE->(Reclock( "RJE", lNovo) )
			RJE->RJE_FILIAL	:= cRJEFilial
			RJE->RJE_FIL	:= cRJEFil
			RJE->RJE_TPINSC	:= cRJETpIns
			RJE->RJE_INSCR	:= cRJEInsc
			RJE->RJE_EVENTO	:= "S5003"
			RJE->RJE_INI	:= cRJEIni
			RJE->RJE_KEY	:= cRJEKey
			RJE->RJE_RETKEY	:= SubStr( cXMLRet, nIniId, 36 )
			RJE->RJE_VERS	:= "12"
			RJE->RJE_STATUS	:= "4"
			RJE->RJE_XML	:= SubStr( cXMLRet, nIni5003, nFim5003-nIni5003 )
			RJE->RJE_DTG	:= Date()
			RJE->RJE_HORAG	:= Time()
			RJE->( MsUnlock() )
		EndIf
		fGrvTotFG( RJE->RJE_FIL, RJE->RJE_TPINSC, RJE->RJE_INSCR, RJE->RJE_XML )
	EndIf

Return

/*/{Protheus.doc} fGrvTotCS()
Função que grava o totalizador (S-5001) na tabela RJO
@author allyson.mesashi
@since 03/02/2020
@version 1.0
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cXMLRet		= XML de Retorno

/*/
Static Function fGrvTotCS( cRJEFil, cRJETpIns, cRJEInsc, cXMLRet )

	Local cCabec		:= "/eSocial/evtBasesTrab/"
	Local cPCpCal		:= ""
	Local cPIdeEstL		:= ""
	Local cPInfCatI		:= ""
	Local cPInfBasC		:= ""
	Local cTpFolha		:= ""
	Local cPerApur		:= ""
	Local cCpfTrab		:= ""
	Local cTpCR			:= ""
	Local cVrCpSeg		:= ""
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cCodLota		:= ""
	Local cMatric		:= ""
	Local cCodCateg		:= ""
	Local cInd13		:= ""
	Local cTpValor		:= ""
	Local cValor		:= ""
	Local nCpCal		:= 0
	Local nIdeEstL		:= 0
	Local nInfCatI		:= 0
	Local nInfBasC		:= 0
	Local oXml 			:= tXmlManager():New()
	Local cNome			:= ""

	If oXml:Parse( fMidTrPath(cXMLRet,"eSocial") )
		cTpFolha := oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/indApuracao" )
		cPerApur := AllTrim( StrTran( oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/perApur" ), "-" ) )
		cCpfTrab := oXml:XPathGetNodeValue( cCabec + "ideTrabalhador[1]" + "/cpfTrab" )
		fExcRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, "S-5001" )

		// ENCONTRA AS INFORMAÇÕES DE MATRICULA E NOME DO FUNCIONARIO.
		If !Empty(cCpfTrab)
			cMatric 	:= Posicione("SRA", 5, xFilial("SRA") + cCpfTrab, "RA_CODUNIC")
			cNome		:= Alltrim(SRA->RA_NOME)
		EndIf

		nCpCal := 1
		cPCpCal := cCabec + "infoCpCalc[" + cValToChar(nCpCal) + "]"
		While oXml:XPathHasNode(cPCpCal)
			cTpCR 		:= AllTrim( StrTran( oXml:XPathGetNodeValue( cPCpCal + "/tpCR" ), "-" ) )
			cVrCpSeg 	:= oXml:XPathGetNodeValue( cPCpCal + "/vrCpSeg" )

			fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, /*cCateg*/, /*cTpInsc*/, /*cNrInsc*/, /*cCodLot*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cVrCpSeg), "S-5001", /*cIndDec*/, "99", cTpCR )

			nCpCal++
			cPCpCal := cCabec + "infoCpCalc[" + cValToChar(nCpCal) + "]"
		EndDo

		nIdeEstL := 1
		cPIdeEstL := cCabec + "infoCp/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		While oXml:XPathHasNode(cPIdeEstL)
			cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/nrInsc" )
			cCodLota 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/codLotacao" )

			nInfCatI := 1
			cPInfCatI := cPIdeEstL + "/infoCategIncid[" + cValToChar(nInfCatI) + "]"
			While oXml:XPathHasNode(cPInfCatI)

				cCodCateg 	:= oXml:XPathGetNodeValue( cPInfCatI + "/codCateg" )
				cMatric 	:= oXml:XPathGetNodeValue( cPInfCatI + "/matricula" )

				nInfBasC := 1
				cPInfBasC := cPInfCatI + "/infoBaseCS[" + cValToChar(nInfBasC) + "]"
				While oXml:XPathHasNode(cPInfBasC)
					cInd13 		:= oXml:XPathGetNodeValue( cPInfBasC + "/ind13" )
					cTpValor 	:= oXml:XPathGetNodeValue( cPInfBasC + "/tpValor" )
					cValor 		:= oXml:XPathGetNodeValue( cPInfBasC + "/valor" )

					If cTpValor $ "11/12/13/14/15/16/17/18/19/21/22/23/31/32/41/42/43/44/45/46/47/48/49"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5001", cInd13, cTpValor )
					EndIf

					nInfBasC++
					cPInfBasC := cPInfCatI + "/infoBaseCS[" + cValToChar(nInfBasC) + "]"
				EndDo

				nInfCatI++
				cPInfCatI := cPIdeEstL + "/infoCategIncid[" + cValToChar(nInfCatI) + "]"
			EndDo

			nIdeEstL++
			cPIdeEstL := cCabec + "infoCp/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		EndDo

	EndIf

	oXml := Nil

Return

/*/{Protheus.doc} fGrvTotFG()
Função que grava o totalizador (S-5003) na tabela RJO
@author allyson.mesashi
@since 20/02/2020
@version 1.0
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cXMLRet		= XML de Retorno

/*/
Static Function fGrvTotFG( cRJEFil, cRJETpIns, cRJEInsc, cXMLRet )

	Local cCabec		:= "/eSocial/evtBasesFGTS/"
	Local cPIdeEstL		:= ""
	Local cPTrabFgt		:= ""
	Local cPBaseFgt		:= ""
	Local cPTrabDps		:= ""
	Local cPDpsPA		:= ""
	Local cPInfDPAE		:= ""
	Local cTpFolha		:= ""
	Local cPerApur		:= ""
	Local cCpfTrab		:= ""
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cCodLota		:= ""
	Local cMatric		:= ""
	Local cCodCateg		:= ""
	Local cTpValor		:= ""
	Local cValor		:= ""
	Local cIncid		:= ""
	Local cPIdeEst		:= ""
	Local cPIdeLot		:= ""
	Local nIdeEst		:= 0
	Local nIdeLot		:= 0
	Local nIdeEstL		:= 0
	Local nInfTraF		:= 0
	Local nBaseFgt		:= 0
	Local nInfTraD		:= 0
	Local nDpsPA		:= 0
	Local nInfDPAE		:= 0
	Local oXml 			:= tXmlManager():New()
	Local cNome			:= ""

	If oXml:Parse( fMidTrPath(cXMLRet,"eSocial") )
		cPerApur := AllTrim( StrTran( oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/perApur" ), "-" ) )
		cTpFolha := Iif( Len(cPerApur) == 4, "2", "1" )
		cCpfTrab := oXml:XPathGetNodeValue( cCabec + "ideTrabalhador[1]" + "/cpfTrab" )
		fExcRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, "S-5003" )

		// ENCONTRA AS INFORMAÇÕES DE MATRICULA E NOME DO FUNCIONARIO.
		If !Empty(cCpfTrab)
			cMatric 	:= Posicione("SRA", 5, xFilial("SRA") + cCpfTrab, "RA_CODUNIC")
			cNome		:= Alltrim(SRA->RA_NOME)
		EndIf

		nIdeEstL := 1
		cPIdeEstL := cCabec + "infoFGTS/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		While oXml:XPathHasNode(cPIdeEstL)
			cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/nrInsc" )
			cCodLota 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/codLotacao" )

			nInfTraF := 1
			cPTrabFgt := cPIdeEstL + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
			While oXml:XPathHasNode(cPTrabFgt)

				cCodCateg 	:= oXml:XPathGetNodeValue( cPTrabFgt + "/codCateg" )

				nBaseFgt := 1
				cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
				While oXml:XPathHasNode(cPBaseFgt)
					cTpValor 	:= oXml:XPathGetNodeValue( cPBaseFgt + "/tpValor" )
					cValor 		:= oXml:XPathGetNodeValue( cPBaseFgt + "/remFGTS" )

					If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
					EndIf

					nBaseFgt++
					cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
				EndDo

				nBasePAE := 1
				cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
				While oXml:XPathHasNode(cPBasPAE)
					cTpValor 	:= oXml:XPathGetNodeValue( cPBasPAE + "/tpValorE" )
					cValor 		:= oXml:XPathGetNodeValue( cPBasPAE + "/remFGTSE" )

					If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
					EndIf

					nBasePAE++
					cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
				EndDo

				nInfTraF++
				cPTrabFgt := cPIdeEstL + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
			EndDo

			nIdeEstL++
			cPIdeEstL := cCabec + "infoFGTS/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		EndDo

		nInfTraD := 1
		cPTrabDps := cCabec + "/infoDpsFGTS/infoTrabDps[" + cValToChar(nInfTraD) + "]"
		While oXml:XPathHasNode(cPTrabDps)

			cCodCateg 	:= oXml:XPathGetNodeValue( cPTrabDps + "/codCateg" )

			nDpsPA := 1
			cPDpsPA := cPTrabDps + "/dpsPerApur[" + cValToChar(nDpsPA) + "]"
			While oXml:XPathHasNode(cPDpsPA)
				cTpValor 	:= oXml:XPathGetNodeValue( cPDpsPA + "/tpDps" )
				cValor 		:= oXml:XPathGetNodeValue( cPDpsPA + "/dpsFGTS" )

				If cTpValor $ "51/52/53/54/55/56/57/58/61/62/63/64/65/66/67/68/69/70/71/72"
					fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
				EndIf

				nDpsPA++
				cPDpsPA := cPTrabDps + "/dpsPerApur[" + cValToChar(nDpsPA) + "]"
			EndDo

			nInfDPAE := 1
			cPInfDPAE := cPTrabDps + "/infoDpsPerAntE[" + cValToChar(nInfDPAE) + "]"
			While oXml:XPathHasNode(cPInfDPAE)
				nDpsPAE  := 1
				cPDpsPAE := cPInfDPAE + "/dpsPerAntE[" + cValToChar(nDpsPAE) + "]"

				While oXml:XPathHasNode(cPDpsPAE)
					cTpValor 	:= oXml:XPathGetNodeValue( cPDpsPAE + "/tpDpsE" )
					cValor 		:= oXml:XPathGetNodeValue( cPDpsPAE + "/dpsFGTSE" )

					If cTpValor $ "51/52/53/54/55/56/57/58/61/62/63/64/65/66/67/68/69/70/71/72"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
					EndIf

					nDpsPAE++
					cPDpsPAE := cPInfDPAE + "/dpsPerAntE[" + cValToChar(nDpsPAE) + "]"
				EndDo

				nInfDPAE++
				cPInfDPAE := cPTrabDps + "/infoDpsPerAntE[" + cValToChar(nInfDPAE) + "]"
			EndDo

			nInfTraD++
			cPTrabDps := cCabec + "/infoDpsFGTS/infoTrabDps[" + cValToChar(nInfTraD) + "]"
		EndDo

		//S-1.0
		nIdeEst := 1
		cPIdeEst := cCabec + "infoFGTS/ideEstab[" + cValToChar(nIdeEst) + "]" //9.0 n tem o grupo, é infoFGTS/ideEstab[ /ideLotacao[]]
		While oXml:XPathHasNode(cPIdeEst)
			cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeEst + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeEst + "/nrInsc" )

			nIdeLot := 1
			cPIdeLot := cPIdeEst + "/ideLotacao[" + cValToChar(nIdeLot) + "]" //infoFGTS/ideEstab/ideLotacao[]
			While oXml:XPathHasNode(cPIdeLot)
				cCodLota 	:= oXml:XPathGetNodeValue( cPIdeLot + "/codLotacao" )
				//Tratar se tipo de Lotacao 04, query do relatório hoje busca pelo estab
					//cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeLot + "/tpInsc" )
					//cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeLot + "/nrInsc" )

				nInfTraF := 1
				cPTrabFgt := cPIdeLot + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
				While oXml:XPathHasNode(cPTrabFgt)
					cCodCateg 	:= oXml:XPathGetNodeValue( cPTrabFgt + "/codCateg" )

					nBaseFgt := 1
					cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
					While oXml:XPathHasNode(cPBaseFgt)
						cTpValor 	:= oXml:XPathGetNodeValue( cPBaseFgt + "/tpValor" )
						cValor 		:= oXml:XPathGetNodeValue( cPBaseFgt + "/remFGTS" )
						cIncid		:= oXml:XPathGetNodeValue( cPBaseFgt + "/indIncid" )

						If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32/41/42/43/44/45/46/47/48/49/50"
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
						EndIf

						If cIncid == '1' //dps só informa se indIncid = 1
							cValor	:= oXml:XPathGetNodeValue( cPBaseFgt + "/dpsFGTS" )
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, /*cTpValor*/ )
						EndIf

						nBaseFgt++
						cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
					EndDo


					nBasePAE := 1
					cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
					While oXml:XPathHasNode(cPBasPAE)
						cTpValor 	:= oXml:XPathGetNodeValue( cPBasPAE + "/tpValorE" )
						cValor 		:= oXml:XPathGetNodeValue( cPBasPAE + "/remFGTSE" )
						cIncid		:= oXml:XPathGetNodeValue( cPBaseFgt + "/indIncidE" )


						If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32/43/44/48/49/50"
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
						EndIf

						If cIncid == '1'
							cValor 		:= oXml:XPathGetNodeValue( cPDpsPAE + "/dpsFGTSE" )
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, /*cTpValor*/ )
						EndIf


						nBasePAE++
						cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
					EndDo

					nInfTraF++
					cPTrabFgt := cPIdeLot + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
				EndDo

				nIdeLot++
				cPIdeLot := cPIdeEst + "/ideLotacao[" + cValToChar(nIdeLot) + "]" //infoFGTS/ideEstab/ideLotacao[]
			EndDo

			nIdeEst++
			cPIdeEst := cCabec + "infoFGTS/ideEstab[" + cValToChar(nIdeEst) + "]" //9.0 nao tem
		EndDo

	EndIf

	oXml := Nil

Return
