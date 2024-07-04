#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "WSJURCONTENCIOSO.ch"
#Include "FWMVCDEF.CH"
#Include "FILEIO.CH"
#Include "PARMTYPE.CH"
#Include "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurContencioso
Métodos WS REST do Jurídico para Contencioso.

@author SIGAJURI
@since 25/09/2020

/*/
//-------------------------------------------------------------------

WSRESTFUL JURCONTENCIOSO DESCRIPTION STR0001 // "WS Jurídico Contencioso"
	WSDATA cajuri       As String
	WSDATA codFil       As String
	WSDATA dtInicial    AS String
	WSDATA dtFinal      AS String
	WSDATA searchKey    AS String
	WSDATA pk           AS String
	WSDATA tabela       AS String
	WSDATA campo        AS String
	WSDATA codEntid     AS String
	WSDATA entidade     AS String
	WSDATA page         AS Integer
	WSDATA pageSize     AS Integer
	WSDATA status       AS Integer
	WSDATA myTasks      AS Boolean
	WSDATA viewType     AS Boolean
	WSDATA codRel       AS String
	WSDATA codCfgRel    AS String
	WSDATA corrige      AS String
	WSDATA creden       AS String
	WSDATA assunto      AS String
	WSDATA filter       AS Boolean
	WSDATA valor        As Float
	WSDATA total        As Boolean

	// Métodos GET
	WSMETHOD GET ReprocPub    DESCRIPTION STR0003 PATH "publicacao/reprocessa"                       PRODUCES APPLICATION_JSON  // "Reprocessar publicação"
	WSMETHOD GET FaseProc     DESCRIPTION STR0009 PATH "fase"                                        PRODUCES APPLICATION_JSON  // "Obtém a Fase Processual"
	WSMETHOD GET ExtratoGar   DESCRIPTION STR0011 PATH "extratoGar"                                  PRODUCES APPLICATION_JSON  // "Gera o extrato da Garantia"
	WSMETHOD GET ESocialXML   DESCRIPTION STR0012 PATH "esocialXML"                                  PRODUCES APPLICATION_JSON  // "Gera o arquivo XML e-social"
	WSMETHOD GET EscCorresp   DESCRIPTION STR0020 PATH "escritorioCorresp"                           PRODUCES APPLICATION_JSON  // "Obtém o escritório do correspondente"
	WSMETHOD GET ExtrtDespe   DESCRIPTION STR0011 PATH "extratoDes"                                  PRODUCES APPLICATION_JSON  // "Gera o extrato da Garantia"
	WSMETHOD GET CodSeqTab    DESCRIPTION STR0022 PATH "codSeqTab"                                   PRODUCES APPLICATION_JSON  // "Busca Sequencial da tabela"
	WSMETHOD GET Subsidios    DESCRIPTION STR0023 PATH "subsidios"                                   PRODUCES APPLICATION_JSON  // "Lista subsídios solicitados"
	WSMETHOD GET TituloPag    DESCRIPTION STR0025 PATH "tituloPag"                                   PRODUCES APPLICATION_JSON  // "Obtém os títulos da despesa"
	WSMETHOD GET TitValores   DESCRIPTION STR0026 PATH "valoresTitulo"                               PRODUCES APPLICATION_JSON  // "Obtém os valores dos títulos para atualizar o status"
	WSMETHOD GET ModExport    DESCRIPTION STR0028 PATH "modExport"                                   PRODUCES APPLICATION_JSON  // "Busca modelos de exportação em excel e pdf para pesquisa avançada"
	WSMETHOD GET GetProvisao  DESCRIPTION STR0037 PATH "getProvisao/{cajuri}"                        PRODUCES APPLICATION_JSON  // "Retorna os valores de provisão"
	WSMETHOD GET Fornecedor   DESCRIPTION STR0038 PATH "fornecedor/{creden}"                         PRODUCES APPLICATION_JSON  // "Obtém os fornecedores (escritório credenciado)"
	WSMETHOD GET Unidade      DESCRIPTION STR0039 PATH "unidade"                                     PRODUCES APPLICATION_JSON  // "Obtém as unidades"
	WSMETHOD GET Gerente      DESCRIPTION STR0040 PATH "gerente"                                     PRODUCES APPLICATION_JSON  // "Obtém os gerentes"
	WSMETHOD GET Pedido       DESCRIPTION STR0041 PATH "pedido"                                      PRODUCES APPLICATION_JSON  // "Obtém os pedidos"
	WSMETHOD GET qtdPub       DESCRIPTION STR0042 PATH "qtdPub"                                      PRODUCES APPLICATION_JSON // "Método para obter a quantidade de publicações"
	WSMETHOD GET GetAndPro    DESCRIPTION STR0064 PATH "getAnd/{codFil}/{cajuri}"                    PRODUCES APPLICATION_JSON  // "Retorna os andamentos do processo"
	WSMETHOD GET listPedidos  DESCRIPTION STR0065 PATH "listPedidos/{pk}"                            PRODUCES APPLICATION_JSON // "Busca os dados de pedidos para a widget e pagina de pedidos de processos"
	WSMETHOD GET SugLev       DESCRIPTION STR0067 PATH "suglev/{codEntid}/{dtFinal}/{valor}/{total}" PRODUCES APPLICATION_JSON // "Sugere valores para levantamento"

	// Métodos POST
	WSMETHOD POST ImpPubli   DESCRIPTION STR0004 PATH "publicacao/importar"      PRODUCES APPLICATION_JSON //"Realiza a importação em lote de publicações"
	WSMETHOD POST AtuModel   DESCRIPTION STR0006 PATH "distribuicao/updateModel" PRODUCES APPLICATION_JSON //"Atualização de modelo"
	WSMETHOD POST LocProc    DESCRIPTION STR0008 PATH "publicacao/localizar"     PRODUCES APPLICATION_JSON  // "Vincular publicação não localizada"
	WSMETHOD POST PdfExport  DESCRIPTION STR0029 PATH "pdfExport"                PRODUCES APPLICATION_JSON  // "Relatório de exportação de processos em PDF"
	WSMETHOD POST GetDistrib DESCRIPTION STR0041 PATH "GetDistribuicoes"         PRODUCES APPLICATION_JSON  // "Obtém as distribuições"
	WSMETHOD POST BuscaPubs  DESCRIPTION STR0043 PATH "BuscaPubs"                PRODUCES APPLICATION_JSON  // "Obtém as publicações"
	WSMETHOD POST ExportPubs DESCRIPTION STR0044 PATH "exportPubs"               PRODUCES APPLICATION_JSON //"Realiza a exportação das publicações"

	// Métodos PUT
	WSMETHOD PUT  SetIncidente  DESCRIPTION STR0013 PATH "processo/incidente"   PRODUCES APPLICATION_JSON //"Seta incidente"
	WSMETHOD PUT  ResendMailSub DESCRIPTION STR0027 PATH "subsidios/resendMail" PRODUCES APPLICATION_JSON //"Reenvia email dos subsidios"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} ReprocPub()
Metódo responsável por realizar o reprocessamento das publicações
levantamentos no Totvs Jurídico.

@param dtInicial - Data Inicial para busac
@param dtFinal   - Data Final para busca
@param searchKey - Palavra chave

@since 01/10/2020
/*/
//-------------------------------------------------------------------
WSMETHOD GET ReprocPub WSRECEIVE dtInicial, dtFinal, searchKey WSREST JURCONTENCIOSO
Local oResponse  := JsonObject():New()

	J283RepPub(Self:dtInicial,Self:dtFinal,Self:searchKey)
	Self:SetContentType("application/json")

	oResponse['ok']   := .T.


	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} impPubli
Efetua o tombamento em lote das publicações

@return result - 'Processando' Indica que o tombamento será executado em segundo plano

@since 02/10/2020

@example POST -> http://localhost:12173/rest/JURCONTENCIOSO/impPubli
Body ->:{
			"publicacoes": [
				"ICA5OTk5MDAwMDAwMDAyOQ==",
				"ICA5OTk5MDAwMDAwMDAzNQ==",
				"ICA5OTk5MDAwMDAwMDY4NQ==",
				"ICA5OTk5MDAwMDAwMDc2OA==",
				"ICA5OTk5MDAwMDAwMDc2OQ=="
			],
			"codAto": "002"
		}
 
/*/
//-------------------------------------------------------------------
WSMETHOD POST impPubli WSREST JURCONTENCIOSO
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cBody      := Self:GetContent()
Local aPub       := {}
Local cAto       := ""
Local aTread     := {}
Local nReg       := 0
Local nQtd       := 0

	oRequest:fromJson(cBody)
	cAto := oRequest['codAto']
	aPub := oRequest['publicacoes']

	ProcessPub(aPub)

	If Len(aPub) > 40

		For nReg := 1 To len(aPub)

			nQtd ++
			Aadd(aTread, aPub[nReg])

			// Abre até 4 Treads
			If (nQtd >= len(aPub) / 4) .Or. (nReg == len(aPub) )

				STARTJOB("J283ImpPub", GetEnvServer(), .F.,;
					aTread, cAto, cEmpAnt, cFilAnt, __CUSERID )
				aTread := {}
				nQtd := 0

			EndIf
		Next nReg
	Else
		STARTJOB("J283ImpPub", GetEnvServer(), .F.,;
			aPub, cAto, cEmpAnt, cFilAnt, __CUSERID )
	EndIf

	oResponse['result'] := STR0005 //Processando

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aPub, 0)
	aSize(aTread, 0)
	aPub := Nil
	aTread := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} atuModel
Efetua a atualização ou gravação de modelo para tombar uma distribuição

@since 14/10/2020

@example POST -> http://localhost:12173/rest/JURCONTENCIOSO/distribuicao/updateModel
Body ->:{
	"hasUpdateModel": false, // 'True' indica se é atualização de modelo, caso contrário é 'false'.
	"nameTemplate": "Nome do Modelo",
	"codModel":"", // Código do modelo que irá sofrer atualização
	"tipoAssunto":"001", // Assunto jurídico do modelo que está sendo cadastrado
	"detModelo": [
		 // Listagem dos campos que serão atualizados ou gravados.
		["Campo"     , "Modelo do campo", "Valor" , "Tipo"]
 		["NSZ_CCLIEN", "NSZMASTER"      , "DFR999", "C" ]
 	]
 }
 
/*/
//-------------------------------------------------------------------
WSMETHOD POST atuModel WSREST JURCONTENCIOSO
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cBody      := Self:GetContent()
Local cNomeModel := ''
Local cCodMod    := ''
Local cTpAss     := ''
Local aModelo    := {}
Local aRet       := {}
Local lUpdate    := .F.

	oRequest:fromJson(cBody)
	aModelo    := oRequest['detModelo']
	lUpdate    := oRequest['hasUpdateModel']
	cNomeModel := oRequest['nameTemplate']
	cCodMod    := oRequest['codModel']
	cTpAss     := oRequest['tipoAssunto']
	aEval(aModelo,{|x|if(x[2]=="C", x[3] := decodeUTF8(x[3]),nil)})
	If Len(aModelo) > 0
		aRet := J279SvMdl(aModelo, lUpdate, cNomeModel, cCodMod, cTpAss, '2')
	Else
		aRet := {.F., STR0007}
	EndIf

	oResponse['ok']           := aRet[1]
	oResponse['messageError'] := JConvUTF8(aRet[2])

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aModelo, 0)
	aModelo := Nil
	aSize(aRet, 0)
	aRet := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Formata o valor em UTF8 e retira os espaços

@param cValue - Texto que será encodado

@since 15/10/2020
/*/
//-------------------------------------------------------------------
Static Function JConvUTF8(cValue)
	Local cReturn := ""

	cReturn := JurEncUTF8(Alltrim(cValue))

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} Vincular()
Metódo responsável por localizar o processo e vincular a publicação,
além de atualizar o número do processo e em seguida, reprocessar as 
publicações não localizadas

@since 27/10/2020
/*/
//-------------------------------------------------------------------
WSMETHOD POST LocProc WSREST JURCONTENCIOSO

Local aArea      := GetArea()
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cBody      := Self:GetContent()
Local cFilPro    := ""
Local cCajuri    := ""
Local cCodseq    := ""
Local lReproc    := .F.
Local lAtuProc   := .F.
Local lCmpFilPro := .F.
Local lRet       := .F.
Local cPk        := ""

	oRequest:fromJson(cBody)
	cFilPro  := oRequest['filial']
	cCajuri  := oRequest['cajuri']
	lReproc  := oRequest['reprocessar']
	lAtuProc := oRequest['atualiza']
	cCodseq  := oRequest['codSeq']
	cPk      := IIF( VALTYPE(oRequest['pk']) <> 'U' .AND. !Empty(oRequest['pk']),  Decode64(oRequest['pk']), '')

	If !Empty(cPk)

		DbSelectArea("NUQ")
		NUQ->( DbSetOrder(2) ) // NUQ_FILIAL + NUQ_CAJURI + NUQ_INSATU

		DbSelectArea("NR0")
		NR0->( DbSetOrder(1) ) // NR0_FILIAL + NR0_CODIMP + NR0_CODSEQ
		lRet := NR0->( DbSeek( cPk ) )

		lCmpFilPro := NR0->( FieldPos("NR0_FILPRO") ) > 0

		If lRet
			lRet := J20Vincula(cFilPro, cCajuri, lCmpFilPro, lAtuProc)
		EndIf

		If lRet .AND. lReproc .AND. lAtuProc
			J283RepPub()
		EndIf

		NUQ->(DbCloseArea())
		NR0->(DbCloseArea())
	EndIf

	Self:SetContentType("application/json")
	oResponse['ok'] := lRet

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} FaseProc()
Metódo para obter a Fase do processo

@param cajuri - Código do processo
@param codFil - Filial do processo

@since 29/10/2020

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/fase?codFil=        &cajuri=0000000170
/*/
//-------------------------------------------------------------------
WSMETHOD GET FaseProc WSRECEIVE codFil, cajuri WSREST JURCONTENCIOSO
Local oResponse  := JsonObject():New()
Local cCajuri    := Self:cajuri
Local cFilPro    := Self:codFil
Local cFase      := ""

	cFase := JURA100Fase(cCajuri, cFilPro, .F.)
	Self:SetContentType("application/json")
	
	oResponse['faseProc']   := JConvUTF8(cFase)
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtratoGar()
Metódo para gerar o Extrato da garantia

@param cajuri - Código do processo
@param codFil - Filial do processo

@since 05/11/2020

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/extratoGar?codFil=        &cajuri=0000000170
/*/
//-------------------------------------------------------------------
WSMETHOD GET ExtratoGar WSRECEIVE codFil, cajuri WSREST JURCONTENCIOSO
Local oResponse    := JsonObject():New()
Local cCajuri      := Self:cajuri
Local cFilPro      := Self:codFil
Local cNomeRel     := Replace(AllTrim(STR0010),'.','') + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') // "extrato de garantia"
Local cCaminho     :=  "\spool\"
Local cFileContent := ""

	If "Linux" $ GetSrvInfo()[2]
		cCaminho := StrTran(cCaminho,"\","/")
	Endif

	JA098RelG(cCajuri, cFilPro, , cNomeRel, cCaminho )
	Self:SetContentType("application/json")
	
	cFileContent := encode64(DownloadBase(cCaminho+cNomeRel + ".pdf"))

	If Empty(cFileContent)
		SetRestFault(400, STR0024) //"Falha ao Gerar arquivo"
	Else
		oResponse['namefile'] := JConvUTF8(cNomeRel+ ".pdf")
		oResponse['filedata'] := cFileContent 
		Self:SetResponse(oResponse:toJson())

	EndIf

	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ESocialXML()
Metódo para gerar o XML do e-social

@param cajuri - Código do processo

@since 30/12/2020

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/esocialXML?cajuri=0000000170
/*/
//-------------------------------------------------------------------
WSMETHOD GET ESocialXML WSRECEIVE cajuri WSREST JURCONTENCIOSO
Local oResponse  := JsonObject():New()
Local cCajuri    := Self:cajuri
Local cCaminho   :=  "\spool\"
Local cNomeArq   := ''

	cNomeArq := cEmpAnt + Alltrim(xFilial('O08')) + '_s-1070_' + cCajuri
	Self:SetContentType("application/json")

	oResponse['namefile'] := JConvUTF8(cNomeArq+ ".xml")
	oResponse['filedata'] := encode64(DownloadBase(cCaminho+cNomeArq + ".xml"))

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} PUT SetIncidente
Seta o código do processo origem no incidente

@example PUT -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/processo/incidente
@example Body -> {   
					"filialIncidente": "01", 
					"cajuriIncidente": "0000000010",  
					"filialOrigem": "01", 
					"cajuriOrigem": "0000000010"
				 }
}

@since 28/01/2021
/*/
//-------------------------------------------------------------------

WSMETHOD PUT SetIncidente  WSREST JURCONTENCIOSO
Local aArea    := GetArea()
Local aAreaNSZ := NSZ->( GetArea() )
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cBody      := Self:GetContent()
Local nCodError   := 404
Local lRet       := .T.

	oRequest:FromJson(cBody)

	If ( JVldRestri(oRequest['assJur'], "'01','02','17'", oRequest['nOpc']) )
		DbSelectArea('NSZ')
		NSZ->(DBSetOrder(1)) //NSZ_FILIAL + NSZ_COD

		if Empty(oRequest['cajuriOrigem']) .Or. ;
			( NSZ->( dbSeek(oRequest['filialOrigem'] + oRequest['cajuriOrigem'])) )

			if NSZ->( dbSeek(oRequest['filialIncidente'] + oRequest['cajuriIncidente']))

					RecLock("NSZ", .F.)
						NSZ->NSZ_FPRORI := oRequest['filialOrigem']
						NSZ->NSZ_CPRORI := oRequest['cajuriOrigem']
					NSZ->(MsUnlock())
					NSZ->(DbCommit())
					ConfirmSX8()
			else
				lRet := .F.
				SetRestFault(nCodError, JConvUTF8(STR0014) ) //"O incidente informado não foi localizado na base de dados!"
			endif
		else	
			lRet := .F.
			SetRestFault(nCodError, JConvUTF8(STR0015) ) //"O processo origem informado não foi localizado na base de dados!"
		endif

		if lRet
			if Empty(oRequest['cajuriOrigem'])
				oResponse['result'] := STR0017 // Incidente desvinculado com sucesso
			else
				oResponse['result'] := STR0016 // Incidente vinculado com sucesso
			endif 

			Self:SetResponse(oResponse:toJson())

		endif
	Else
		SetRestFault(403, STR(oRequest['nOpc']) + STR0018) //" : Acesso negado."
		ConOut(STR0019) // "Sem permissão para PUT em  JURA289."
		lRet := .F.
	EndIf

	oResponse:fromJson("{}")
	oResponse := NIL
	RestArea( aAreaNSZ )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EscCorresp()
Obtém o escritório do correspondente

@since 10/03/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/escritorioCorresp
/*/
//-------------------------------------------------------------------
WSMETHOD GET EscCorresp WSREST JURCONTENCIOSO
Local oResponse := JsonObject():New()
Local cUser     := __CUSERID 
Local cGrupos   := ArrTokStr(J218RetGru(cUser),"','")
Local cAlias    := ""
Local cQuery    := ""

	cQuery := " SELECT NVK_CCORR, NVK_CLOJA "
	cQuery += " FROM " + RetSqlName('NVK') 
 	cQuery += " WHERE NVK_FILIAL = '" + xFilial("NVK") + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' " 
	cQuery += " AND (NVK_CUSER = '" + cUser + "' " 
	cQuery += " OR NVK_CGRUP IN ('" + cGrupos + "')) "

	cAlias := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	Self:SetContentType("application/json")
	If !(cAlias)->(Eof())
		oResponse['codEscritorio']  := JConvUTF8((cAlias)->NVK_CCORR)
		oResponse['lojaEscritorio'] := JConvUTF8((cAlias)->NVK_CLOJA)
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtratoDes()
Metódo para gerar o Extrato da despesa

@param cajuri - Código do processo
@param codFil - Filial do processo

@since 30/03/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/ExtratoDes?codFil=        &cajuri=0000000170
/*/
//-------------------------------------------------------------------
WSMETHOD GET ExtrtDespe WSRECEIVE codFil, cajuri WSREST JURCONTENCIOSO
Local oResponse    := JsonObject():New()
Local cCajuri      := Self:cajuri
Local cFilPro      := Self:codFil
Local cNomeRel     := Replace(AllTrim(STR0021),'.','') + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') // "relatorio de despesas"
Local cCaminho     :=  "\spool\"
Local cFileContent := ""

	If "Linux" $ GetSrvInfo()[2]
		cCaminho := StrTran(cCaminho,"\","/")
	Endif

	JURR099(cCajuri, cFilpro, , cNomeRel, cCaminho)
	Self:SetContentType("application/json")
	cFileContent := encode64(DownloadBase(cCaminho+cNomeRel + ".pdf"))
	If Empty(cFileContent)
		SetRestFault(400, STR0024) //"Falha ao Gerar arquivo"
	Else
		oResponse['namefile'] := JConvUTF8(cNomeRel + ".pdf")
		oResponse['filedata'] := cFileContent
		Self:SetResponse(oResponse:toJson())
	EndIf

	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} codSeqTab
Busca o proximo sequencial disponivel na tabela

@since 13/05/21
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/codSeqTab
/*/
//-----------------------------------------------------------------
WSMETHOD GET codSeqTab WSRECEIVE tabela, campo WSREST JURCONTENCIOSO
	
	Local cCodigo   := ""
	Local cQuery    := ""
	Local oResponse := Nil
	Local cAlias    := GetNextAlias()
	Local cTabela   := IIF( VALTYPE(Self:tabela) <> "U", Self:tabela, "")
	Local cCampo    := IIF( VALTYPE(Self:campo) <> "U", Self:campo, "")

	If !Empty(cTabela) .AND. !Empty(cCampo)
		oResponse := JsonObject():New()
		cAlias := GetNextAlias()

		cQuery := " SELECT COALESCE(MAX(" + cCampo + "),'0') MAXCOD "
		cQuery +=   " FROM " + RetSqlName(cTabela) + " " + cTabela + " "
		cQuery += " WHERE " + cTabela + "." + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' "
		cQuery +=       " AND " + cTabela + ".D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		If (cAlias)->(!Eof())
			cCodigo := (cAlias)->MAXCOD
		End

		(cAlias)->(dbCloseArea())

		oResponse['sequencial'] := ALLTRIM( STR(VAL(cCodigo) + 1) )
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Subsidios
Metódo responsável por Listar os subsídios solicitados ou que devem
ser atendidos pelo usuário e/ou equipe.

@param viewType -   Tipo de pesquisa: .T. = Advogado
					Tipo de pesquisa: 'F' = Analista
@param page      -  Página   
@param pageSize  -  Tamanho da página
@param status   -   Status da solicitação: 0 = 'Todos'
					Status da solicitação: 1 = 'No prazo'
					Status da solicitação: 2 = 'Atrasada'
					Status da solicitação: 3 = 'Concluída'
					Status da solicitação: 4 = 'Revisão'
@param myTasks  -   Filtra Solicitante/Responsável: = .T. Minhas
					Filtra Solicitante/Responsável: = .F. Equipe
@param codEntid -   Código da solicitação

@since 04/06/2021
/*/
//-------------------------------------------------------------------
WSMETHOD GET Subsidios ;
	WSRECEIVE viewType, page , pageSize, status, myTasks, codEntid ;
	WSREST JURCONTENCIOSO

	Local oResponse  := JsonObject():New()

	Self:SetContentType("application/json")
	oResponse := getSubsidios(Self:viewType, Self:page, Self:pageSize, Self:status, Self:myTasks, Self:codEntid)
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getSubsidios
Função responsável por Listar os subsídios solicitados ou que devem 
ser atendidos pelo usuário e/ou equipe.

@param lViewType -   Tipo de pesquisa: .T. = Advogado
					Tipo de pesquisa: 'F' = Analista
@param page     -   Página
@param pageSize -   Tamanho da página
@param status   -   Status da solicitação: 0 = 'Todos'
					Status da solicitação: 1 = 'No prazo'
					Status da solicitação: 2 = 'Atrasada'
					Status da solicitação: 3 = 'Concluída'
					Status da solicitação: 4 = 'Revisão'
@param myTasks  -   Filtra Solicitante/Responsável: = .T. Minhas
					Filtra Solicitante/Responsável: = .F. Equipe
@param cCodSolic-   Código da solicitação
@return oResponse - Objeto Json com a lestagem de subsídios

@since 04/06/2021
/*/
//-------------------------------------------------------------------
Static Function getSubsidios(lViewType, nPage, nPageSize, nStatus, lMyTasks, cCodSolic)
Local aAreaO0L := O0L->(GetArea())
Local oResponse   := JsonObject():New()
Local cAlias      := GetNextAlias()
Local cSelect     := ""
Local cFrom       := ""
Local cWhere      := ""
Local cOrder      := ""
Local cQuery      := ""
Local cStatus     := ""
Local cPrazo      := ""
Local nAtrasado   := 0
Local nNoPrazo    := 0 
Local nConcluido  := 0
Local nRevisao    := 0
Local nIJson      := 0
Local nPageIni    := 0
Local nPageFim    := 0
Local nTotal      := 0
Local lAddJson    := .T.
Local lRevisa     := .F.
Local lAnexo      := .F.

Default lViewType := .T. 
Default lMyTasks  := .T.
Default nStatus   := 0 
Default nPage     := 1
Default nPageSize := 10

	// Verifica se o campo existe no dicionário
	DBSelectArea("O0L")
		lRevisa := (O0L->(FieldPos('O0L_REVISA')) > 0)
		lAnexo := (O0L->(FieldPos('O0L_S_ANEX')) > 0)
	O0L->( DBCloseArea() )
	RestArea(aAreaO0L)

	cSelect := "SELECT DISTINCT O0M_FILIAL, "
	cSelect +=        "O0M_CAJURI, "
	cSelect +=        "O0M_COD, "
	cSelect +=        "O0M_CUSRSL, "
	cSelect +=        "O0M_USRSOL, "
	cSelect +=        "O0M_DTSOLI, "
	cSelect +=        "NVE_TITULO, "
	cSelect +=        "O0N_PRZENT, "
	cSelect +=        "O0N_SEQ, "
	cSelect +=        "O0N_CTPDOC, "
	cSelect +=        "O0L_NOME, "
	cSelect +=        "RD0_R.RD0_NOME, "
	cSelect +=        "O0N_CPART, "
	cSelect +=        "O0N_STATUS, "
	cSelect +=        "NT9_NOME, "
	cSelect +=        "O0M.R_E_C_N_O_ NRECNO, "
	cSelect +=        "O0N.R_E_C_N_O_ O0NRECNO "
	cSelect +=        IIf(lRevisa, " , O0L_REVISA ", ", '2'" ) + " REVISA "
	cSelect +=        IIf(lAnexo, " , O0L_S_ANEX ", ", 'F'" ) + " S_ANEX "

	cFrom := "FROM " + RetSqlName("O0M") + " O0M "
	cFrom += "INNER JOIN " + RetSqlName("NSZ") + " NSZ "
	cFrom +=   "ON( NSZ_FILIAL = O0M_FILIAL "
	cFrom +=       "AND NSZ_COD = O0M_CAJURI "
	cFrom +=       "AND NSZ.D_E_L_E_T_ = ' ') "
	cFrom += "INNER JOIN " + RetSqlName("NVE") + " NVE "
	cFrom +=   "ON( NVE_FILIAL = '" + xFilial("NVE") + "' "
	cFrom +=       "AND NSZ_CCLIEN = NVE_CCLIEN "
	cFrom +=       "AND NSZ_LCLIEN = NVE_LCLIEN  "
	cFrom +=       "AND NSZ_NUMCAS = NVE_NUMCAS "
	cFrom +=       "AND NVE.D_E_L_E_T_ = ' ') "
	cFrom += "INNER JOIN " + RetSqlName("O0N") + " O0N  "
	cFrom +=   "ON( O0M_FILIAL =  O0N_FILIAL "
	cFrom +=       "AND O0M_COD = O0N_CSLDOC "
	cFrom +=       "AND O0N.D_E_L_E_T_ = ' ') "
	cFrom += "INNER JOIN " + RetSqlName("O0L") + " O0L "
	cFrom +=   "ON( O0L_FILIAL = '" + xFilial("O0L") + "' "
	cFrom +=       "AND O0N_CTPDOC = O0L_COD "
	cFrom +=       "AND O0L.D_E_L_E_T_ = ' ') "
	cFrom += "LEFT JOIN " + RetSqlName("RD0") + " RD0_S "
	cFrom +=   "ON( RD0_S.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cFrom +=       "AND O0M_CUSRSL = RD0_S.RD0_USER "
	cFrom +=       "AND RD0_S.D_E_L_E_T_ = ' ') "
	cFrom += "LEFT JOIN " + RetSqlName("RD0") + " RD0_R "
	cFrom +=   "ON( RD0_R.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cFrom +=       "AND O0N_CPART = RD0_R.RD0_CODIGO "
	cFrom +=       "AND RD0_R.D_E_L_E_T_ = ' ') "
	cFrom += "LEFT JOIN " + RetSqlName("NT9") + " NT9 "
	cFrom +=   "ON( NT9_FILIAL = O0M_FILIAL " 
	cFrom +=       "AND O0M_CENVOL = NT9_COD "
	cFrom +=       "AND NT9.D_E_L_E_T_ = ' ') "

	cWhere := "WHERE O0M.D_E_L_E_T_ = ' ' "

	If lViewType // Advogado
		cWhere += " AND ( RD0_S.RD0_USER = '" + __CUSERID + "' "

		If !(lMyTasks) //Adiciona equipe no filtro
			cWhere += " OR RD0_S.RD0_CODIGO IN(" + JQryEquipe(.T., .T.) + ") "
		EndIf

	Else // Analista
		cWhere += " AND ( RD0_R.RD0_USER = '" + __CUSERID + "' "

		If !(lMyTasks) //Adiciona equipe no filtro
			cWhere += " OR RD0_R.RD0_CODIGO IN(" + JQryEquipe(.T., .T.) + ") "
		EndIf

	EndIf

	cWhere +=          ")"

	cOrder := " ORDER BY O0N_STATUS, O0N_PRZENT "

	cQuery := ChangeQuery(cSelect + cFrom + cWhere + cOrder)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	// Paginação
	nPageFim := nPageSize

	if nPage > 1
		nPageIni := (nPage-1) * nPageSize + 1  
		nPageFim := nPageIni + nPageSize -1
	endif

	oResponse["solicitacoes"] := {}

	While (cAlias)->(!Eof())

		cStatus := (cAlias)->O0N_STATUS
		cPrazo  := (cAlias)->O0N_PRZENT

		If !( (cStatus == '2') .AND. (SToD(cPrazo) <= (DATE() - 30) ) )
			
			If !Empty(cCodSolic) 
				lAddJson :=  (cAlias)->O0M_FILIAL+(cAlias)->O0M_COD == Padr(cCodSolic,TamSx3('O0M_FILIAL')[1]+TamSx3('O0M_COD')[1])
			Else 
				lAddJson := .T.
			Endif

			cStatus := (cAlias)->O0N_STATUS
			cPrazo  := (cAlias)->O0N_PRZENT

			// Pendente
			if (cStatus == '1') .AND. (SToD(cPrazo) >= DATE())
				nNoPrazo++
				lAddJson := lAddJson .and. (nStatus == 1 .Or. nStatus == 0 )
			// Atrasado
			Elseif (cStatus == '1') .AND. (SToD(cPrazo) < DATE())
				nAtrasado++
				lAddJson := lAddJson .and. (nStatus == 2 .Or. nStatus == 0 )
			// Concluído
			Elseif (cStatus == '2')
				nConcluido++ 
				lAddJson := lAddJson .and. (nStatus == 3 .Or. nStatus == 0 )
			// Revisao
			Elseif (cStatus == '3')
				nRevisao++ 
				lAddJson := lAddJson .and. (nStatus == 4 .Or. nStatus == 0)
			Else 
				lAddJson := .F.
			Endif

			If lAddJson
				setJsonO0N(@oResponse, cAlias, @nIJson, @nPageIni, @nPageFim, @nTotal)
			Endif
		EndIf

		(cAlias)->(DbSkip())
	End

	(cAlias)->( DbCloseArea() )

	oResponse["hasmore"] := nTotal > nPageFim
	oResponse["atrasado"] := nAtrasado
	oResponse["noprazo"] := nNoPrazo
	oResponse["concluido"] := nConcluido
	oResponse["revisao"] := nRevisao

return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} getIdO0N
Função responsável por retornar o id do ítem no modelo 

@param cFilIten - Filial O0N
@param cCodSol  - Código da solicitação
@param cCodSeq  - Código do ducumento

@return nId     - id do ítem no modelo

@since 04/06/2021
/*/
//-------------------------------------------------------------------
Static Function getIdO0N(cFilIten, cCodSol,cCodSeq)
Local cAlias := GetNextAlias()
Local cQuery := ""
Local nId    := 0

	cQuery := "SELECT O0N_SEQ FROM " + RetSqlName("O0N") 
	cQuery += " WHERE O0N_FILIAL = '" + cFilIten + "' "
	cQuery +=   " AND O0N_CSLDOC = '"+cCodSol+"' "
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY O0N_SEQ "

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While (cAlias)->(!Eof())
		if (cCodSeq == (cAlias)->O0N_SEQ)
			Exit
		endif

		nId++
		(cAlias)->(DbSkip())
	End

	(cAlias)->( DbCloseArea() )

Return cValToChar(nId)

//-------------------------------------------------------------------
/*/{Protheus.doc} setJsonO0N
Função responsável por montar o Json de resposta

@param oResponse - Json de solicitações
@param cAlias    - Alias da query
@param nIJson    - Index do íten no Json
@param nPageIni  - Primeiro registro da página
@param nPageFim  - Ultimo registro da página
@param nTotal    - Total de registros na query

@since 04/06/2021
/*/
//-------------------------------------------------------------------
Static Function setJsonO0N(oResponse, cAlias, nIJson, nPageIni, nPageFim, nTotal)
Local cFilIten := (cAlias)->O0M_FILIAL
Local cCodSol  := (cAlias)->O0M_COD
Local cCodSeq  := (cAlias)->O0N_SEQ
Local cObserv  := " "

	// Verifica se o campo existe no dicionário
	DBSelectArea("O0N")
		If (O0N->(FieldPos('O0N_OBSERV')) > 0)
			cObserv := JConvUTF8(JDescriMemo((cAlias)->O0NRECNO, 'O0N_OBSERV'))
		EndIf		
	O0N->( DBCloseArea() )

	nTotal ++

	if ( nTotal >= nPageIni ) .AND. ( nTotal <= nPageFim )

		nIJson++
		Aadd(oResponse["solicitacoes"], JsonObject():New())
		oResponse["solicitacoes"][nIJson]["NVE_TITULO"] := JConvUTF8((cAlias)->NVE_TITULO)
		oResponse["solicitacoes"][nIJson]["O0M_FILIAL"] := cFilIten
		oResponse["solicitacoes"][nIJson]["O0M_CAJURI"] := (cAlias)->O0M_CAJURI
		oResponse["solicitacoes"][nIJson]["O0M_COD"]    := cCodSol
		oResponse["solicitacoes"][nIJson]["O0M_CUSRSL"] := (cAlias)->O0M_CUSRSL
		oResponse["solicitacoes"][nIJson]["O0M_USRSOL"] := JConvUTF8((cAlias)->O0M_USRSOL)
		oResponse["solicitacoes"][nIJson]["O0M_DTSOLI"] := (cAlias)->O0M_DTSOLI
		oResponse["solicitacoes"][nIJson]["NT9_NOME"]   := JConvUTF8((cAlias)->NT9_NOME)
		oResponse["solicitacoes"][nIJson]["O0M_OBS"]    := JConvUTF8(JDescriMemo((cAlias)->NRECNO, 'O0M_OBS'))
		oResponse["solicitacoes"][nIJson]["O0N_PRZENT"] := (cAlias)->O0N_PRZENT
		oResponse["solicitacoes"][nIJson]["O0N_SEQ"]    := cCodSeq
		oResponse["solicitacoes"][nIJson]["O0N_CTPDOC"] := (cAlias)->O0N_CTPDOC
		oResponse["solicitacoes"][nIJson]["O0L_NOME"]   := JConvUTF8((cAlias)->O0L_NOME)
		oResponse["solicitacoes"][nIJson]["RD0_SIGLA"]  := JConvUTF8((cAlias)->RD0_NOME)
		oResponse["solicitacoes"][nIJson]["O0N_CPART"]  := (cAlias)->O0N_CPART
		oResponse["solicitacoes"][nIJson]["O0N_STATUS"] := (cAlias)->O0N_STATUS
		oResponse["solicitacoes"][nIJson]["ID_O0N"]     := getIdO0N(cFilIten, cCodSol,cCodSeq)
		oResponse["solicitacoes"][nIJson]["O0N_OBSERV"] := cObserv
		oResponse["solicitacoes"][nIJson]["O0L_REVISA"] := IIF((cAlias)->REVISA == '1', '1', '2')
		oResponse["solicitacoes"][nIJson]["hasAnexos"]  := JTemAnexo("O0N",(cAlias)->O0M_CAJURI,cCodSol+cCodSeq)
		oResponse["solicitacoes"][nIJson]["O0L_S_ANEX"] := (cAlias)->S_ANEX

	endif 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TituloPag()
Metódo para obter a Fase do processo

@param cajuri    - Código do processo
@param codFil    - Filial do processo
@param codEntid  - Código da entidade (Despesa/ Garantia)
@param entidade  - NT3 - Despesa/ NT2 - Garantia

@since 19/07/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/tituloPag
/*/
//-------------------------------------------------------------------
WSMETHOD GET TituloPag WSRECEIVE codFil, cajuri, codEntid, entidade WSREST JURCONTENCIOSO
Local oResponse  := JsonObject():New()
Local cCajuri    := Self:cajuri
Local cFilDest   := Self:codFil
Local cCodEnt    := Self:codEntid
Local cEntid     := Self:entidade
Local aDados     := {}
Local nI         := 1

	Self:SetContentType("application/json")
	oResponse := JsonObject():New()
	oResponse['titulos'] := {}
	
	JurTitPag(cEntid, cCajuri, cCodEnt, .F. /*lConfirma*/, cFilDest, @aDados)

	For nI := 1 To Len(aDados)
		If !Empty(aDados[nI][1])
			Aadd(oResponse["titulos"], JsonObject():New())
			oResponse["titulos"][nI]["numeroTitulo"] := aDados[nI][1]
			oResponse["titulos"][nI]["prefixo"]      := aDados[nI][2]
			oResponse["titulos"][nI]["parcela"]      := aDados[nI][3]
			oResponse["titulos"][nI]["tipo"]         := aDados[nI][4]
			oResponse["titulos"][nI]["fornecedor"]   := aDados[nI][5]
			oResponse["titulos"][nI]["loja"]         := aDados[nI][6]
			oResponse["titulos"][nI]["filOrigem"]    := aDados[nI][7]
			oResponse["titulos"][nI]["dataEmissao"]  := aDados[nI][8]
			oResponse["titulos"][nI]["dataVenc"]     := aDados[nI][9]
			oResponse["titulos"][nI]["valor"]        := aDados[nI][10]
			Do Case
				Case aDados[nI][11] == 0
					cStatus := "baixado"
				Case aDados[nI][11] <> aDados[nI][10]
					cStatus := "baixadoParc"
				Case aDados[nI][11] == aDados[nI][10]
					cStatus := "aberto"

			EndCase
			oResponse["titulos"][nI]["status"] := cStatus
		EndIf
	Next nI

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aDados, 0)
	aDados := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TitValores()
Metódo para obter os valores dos títulos financeiros das garantias/ despesas do processo

@param cajuri    - Código do processo
@param codFil    - Filial do processo
@param entidade  - NT3 - Despesa/ NT2 - Garantia

@since 19/07/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/valoresTitulo
/*/
//-------------------------------------------------------------------
WSMETHOD GET TitValores WSRECEIVE codFil, cajuri, entidade WSREST JURCONTENCIOSO
Local oResponse  := JsonObject():New()
Local cCajuri    := Self:cajuri
Local cFilDest   := Self:codFil
Local cEntid     := Self:entidade
Local nCount     := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""

	cQuery += " SELECT "+cEntid+"."+cEntid+"_COD CODENTID, "
	cQuery +=            cEntid+"."+cEntid+"_FILDES FILDES, "
	cQuery +=        " SUM(E2.E2_SALDO) SALDO, "
	cQuery +=        " SUM(E2.E2_VALOR) VALOR "
	cQuery +=   " FROM " + RetSqlName("SE2") + " E2 "
	cQuery +=   " JOIN " + RetSqlName("NV3") + " NV3 "
	cQuery +=     " ON NV3.NV3_NUM = E2.E2_NUM "
	cQuery +=    " AND NV3.NV3_FILIAL = '" + cFilDest + "' "
	cQuery +=    " AND NV3.D_E_L_E_T_ = ' ' "
	cQuery +=   " JOIN " + RetSqlName(cEntid) + " "+cEntid+" "
	cQuery +=     " ON "+cEntid+"."+cEntid+"_CAJURI = '"+cCajuri+"' "
	cQuery +=    " AND NV3.NV3_CODLAN = "+cEntid+"."+cEntid+"_COD "
	cQuery +=    " AND "+cEntid+"."+cEntid+"_FILIAL = '" + cFilDest + "' "
	cQuery +=    " AND "+cEntid+".D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE E2.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND ( E2.E2_FILIAL = '" + xFilial("SE2") + "' "
	cQuery +=    " OR E2.E2_FILIAL = "+cEntid+"."+cEntid+"_FILDES ) "
	cQuery += " GROUP BY "+cEntid+"."+cEntid+"_COD, "+cEntid+"."+cEntid+"_FILDES "
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F.)
	
	Self:SetContentType("application/json")
	oResponse := JsonObject():New()
	oResponse['entidade'] := {}

	While !(cAlias)->( EOF() )
		nCount++
		Aadd(oResponse["entidade"], JsonObject():New())
		oResponse["entidade"][nCount]["codEntidade"] := (cAlias)->CODENTID
		oResponse["entidade"][nCount]["saldo"]       := (cAlias)->SALDO
		oResponse["entidade"][nCount]["valor"]       := (cAlias)->VALOR
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->( dbCloseArea() )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} resendMailSub()
Metódo para Reenviar o email ao responsável/solicitante

@param codEntid    - Código da solicitação

@since 29/07/2021

@example put -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/subsidios/resendMail?codEntid=
/*/
//-------------------------------------------------------------------
WSMETHOD PUT resendMailSub WSRECEIVE codEntid WSREST JURCONTENCIOSO
Local oResponse  := JsonObject():New()
Local cCodSolic  := Self:codEntid
Local lEnd       := .F.
Local cMsgErro   := ""

Default cCodSoli := ""

	J254LimpaFlag(cCodSolic)

	lRet := J254EnvEml(cCodSolic, '1', @lEnd, @cMsgErro) .and. J254EnvEml(cCodSolic, '2', lEnd, @cMsgErro)
		

	Self:SetContentType("application/json")
	oResponse := JsonObject():New()
	oResponse['status'] := lRet
	IF !Empty(cMsgErro)
		oResponse['message'] := JConvUTF8(cMsgErro)
	Endif

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET modExport
Metódo responsável por realizar a busca dos modelos de exportação 
em Excel e PDF para a pesquisa avançada

@param searchKey - Palavra chave de busca de modelo / nome do relatório
@param pageSize  - Quantidade de itens a ser retornado

@since 03/08/2021
@example GET -> http://127.0.0.1:9090/rest/JURCONTENCIOSO/modExport?searchKey=contencioso&pageSize=10
/*/
//-------------------------------------------------------------------
WSMETHOD GET modExport WSRECEIVE searchKey, pageSize WSREST JURCONTENCIOSO
Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local oResponse  := JsonObject():New()
Local cSearchKey := IIF( VALTYPE(Self:searchKey) <> "U", Self:searchKey, "" )
Local nPageSize  := IIF( VALTYPE(Self:pageSize) <> "U", Self:pageSize, 10 )
Local nPage      := 1
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local nQtdReg    := 0
Local nIndexJSon := 0

	Self:SetContentType("application/json")

	cQuery := WSJCMdExpt(cSearchKey)
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If !(cAlias)->(EOF())
		oResponse['modelo'] := {}

		// Define o range para inclusão no JSON
		nQtdRegIni := ((nPage-1) * nPageSize)
		nQtdRegFim := (nPage * nPageSize)
		nQtdReg    := 0

		While !(cAlias)->(EOF())
			nQtdReg++

			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				nIndexJSon++
				Aadd(oResponse['modelo'], JsonObject():New())
				oResponse['modelo'][nIndexJSon]['codConfig']  := AllTrim( (cAlias)->COD_CONFIG )
				oResponse['modelo'][nIndexJSon]['descConfig'] := JConvUTF8( (cAlias)->DESC_CONFIG )
				oResponse['modelo'][nIndexJSon]['codRel']     := AllTrim( (cAlias)->COD_REL )
				oResponse['modelo'][nIndexJSon]['descRel']    := JConvUTF8( (cAlias)->DESC_REL )
				oResponse['modelo'][nIndexJSon]['tipo']       := JConvUTF8( (cAlias)->TIPO )
			EndIf

			(cAlias)->( dbSkip() )
		End

	Endif

	oResponse['total'] := nIndexJSon

	(cAlias)->(dbCloseArea())

	RestArea(aArea)
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJCMdExpt
Constroi a query que busca modelos excel (NQ5) e modelos em PDF (NQR e
NQY) para a exportação na pesquisa avançada

@param cSearchKey - Palavra chave de busca de pelo nome do modelo 
ou tipo (EXCEL / PDF)

@since 03/08/2021
/*/
//-------------------------------------------------------------------
Static Function WSJCMdExpt(cSearchKey)

Local cQuery     := ""

Default cSearchKey := ""

	// Modelos PDF
	cQuery := " SELECT NQY.NQY_COD COD_CONFIG, "
	cQuery +=       "  NQY.NQY_DESC DESC_CONFIG, "
	cQuery +=       "  NQR.NQR_COD COD_REL, "
	cQuery +=       "  NQR.NQR_NOMRPT DESC_REL, "
	cQuery +=       "  'PDF' TIPO "
	cQuery += " FROM " + RetSqlName('NQR') + " NQR "
	cQuery +=         " INNER JOIN " + RetSqlName('NQY') + " NQY "
	cQuery +=           " ON NQY.NQY_FILIAL = '" + xFilial("NQY") + "' "
	cQuery +=             " AND NQY.NQY_CRPT = NQR.NQR_COD "
	cQuery +=             " AND NQY.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NQR.NQR_FILIAL = '" + xFilial("NQR") + "' "
	cQuery +=       " AND NQR.NQR_EXTENS = '3' "
	cQuery +=       " AND NQR.NQR_NOMRPT IN ('JURR095', 'U_JURR095') "
	If !Empty(cSearchKey)
		cQuery +=   " AND (UPPER(NQY.NQY_DESC) LIKE UPPER('%" + cSearchKey + "%') "
		cQuery +=       " OR 'PDF' LIKE UPPER('%" + cSearchKey + "%') ) "
	EndIf
	cQuery +=       " AND NQR.D_E_L_E_T_ = ' ' "

	// Modelos Excel
	cQuery += " UNION "
	cQuery += " SELECT NQ5.NQ5_COD COD_CONFIG, "
	cQuery +=        " NQ5.NQ5_DESC DESC_CONFIG, "
	cQuery +=        " '' COD_REL, "
	cQuery +=        " '' DESC_REL, "
	cQuery +=        " 'EXCEL' TIPO "
	cQuery += " FROM " + RetSqlName('NQ5') + " NQ5 "
	cQuery += " WHERE NQ5.NQ5_FILIAL = '" + xFilial("NQ5") + "' "
	cQuery +=      " AND NQ5.NQ5_CTPASJ NOT IN ( '005' , '006' ) "
	cQuery +=      " AND (NQ5.NQ5_TIPO ='2' OR (NQ5.NQ5_TIPO = '1' AND NQ5.NQ5_USER = '" + __cUserID + "' )) "
	If !Empty(cSearchKey)
		cQuery +=  " AND (UPPER(NQ5.NQ5_DESC) LIKE UPPER('%" + cSearchKey + "%') "
		cQuery +=      " OR 'EXCEL' LIKE UPPER('%" + cSearchKey + "%') ) "

	EndIf
	cQuery += " AND NQ5.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLPJURRel
Responsável por realizar a chamada do relatório de acordo com a configuração

@param cRelat   - Fonte do relatório
@param cAssJur  - Assuntos Jurídicos
@param cUser    - Código do usuário
@param cThread  - Thread da fila de impressão
@param cParams  - Parametros do relatório
@param cCfgRel  - Código da configuração do relatório (NQY)
@param cNomerel - Nome do arquivo a ser gerado
@param cCaminho - Local da geração do arquivo
@param cJsonRel - Dados da gestão de relatório do Totvs Jurídico

@return lRet   - Lógico (.T./.F.)
@since 03/08/2021
/*/
//-------------------------------------------------------------------
Static Function WSLPJURRel(cRelat, cAssJur, cUser, cThread, cParams, cCfgRel, cNomerel, cCaminho, cJsonRel)

Local bRelat := ""
Local lRet   := .F.
Local lAuto  := .F.

	bRelat := &("{|cAssJur,cUser, cThread,cParams, cCfgRel, lAuto, cNomerel, cCaminho, cJsonRel| " + ;
				 (cRelat) + "(cAssJur,cUser, cThread,cParams,cCfgRel, lAuto, cNomerel, cCaminho, cJsonRel)}")
	Eval(bRelat ,cAssJur, cUser, cThread, cParams, cCfgRel, lAuto, cNomerel, cCaminho, cJsonRel) //Chamada do relatório PRW

	If FILE(cCaminho + cNomerel + '.pdf')
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLPCfgRel
Responsável por buscar o código do relatório de acordo com a configuração

@param cCodRel  - Código da configuração do relatório (NQY)
@return cCodigo - Código do relatório (NQR)
@since 03/08/2021
/*/
//-------------------------------------------------------------------
Static Function WSLPCfgRel(cCodRel)

Local aArea   := GetArea()
Local cAlias  := ""
Local cCodigo := ""
Local cQuery  := ""

	If !Empty(cCodRel)
		cAlias := GetNextAlias()

		cQuery := " SELECT NQY.NQY_COD COD_CONFIG "
		cQuery += " FROM " + RetSqlName("NQY") + " NQY "
		cQuery += " WHERE NQY.NQY_FILIAL = '" + xFilial("NQY") + "' "
		cQuery += " AND NQY.NQY_CRPT = '" + cCodRel + " ' "
		cQuery += " AND NQY.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		If !(cAlias)->(EOF())
			cCodigo := (cAlias)->COD_CONFIG
		EndIf

		(cAlias)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return cCodigo
//-------------------------------------------------------------------
/*/{Protheus.doc} POST pdfExport
Recebe os dados filtrados na Pesquisa Avançada e gera a exportação - Relatório em Excel

@param corrige - Boolean que indica se será aplicada correção monetária
@Return	 .T. - Lógico
@since 27/09/2019
@example [Sem Opcional] POST -> http://127.0.0.1:9090/rest/JURCONTENCIOSO/pdfExport
Body: {
		"count":1,
		 "listProcess":[{"ProcessFilial":"D MG 01 ", "ProcessId":"0000000122"}],
		"modeloExp": '0005',
		"background": true
	}
/*/
//-------------------------------------------------------------------
WSMETHOD POST pdfExport WSRECEIVE corrige WSREST JURCONTENCIOSO

Local oResponse   := JsonObject():New()
Local oRequest    := JsonObject():New()
Local cBody       := Self:GetContent()
Local lRet        := .T.
Local lO17        := .F.
Local lCorrige    := Self:corrige == 'true'
Local oJsonRel    := nil
Local cThread     := ""
Local cCajuri     := ""
Local cCodRel     := ""
Local cCodCfgRel  := ""
Local cNomerel    := ""
Local cTipoAss    := ""
Local cQuery      := ""
Local cUser       := __CUSERID
Local cFilPro     := xFilial('NSZ')
Local cNameCfg    := "JURR095"
Local cParams     := cUser + ";" + cThread + ";S;T;N;0;N;01/01/1900;31/12/2050;S;S;" + cFilPro + ";N;;"
Local cCaminho    := "\spool\"
Local aDadosImp   := {}
Local aCorrecao   := {}
Local aTables     := JURRELASX9('NSZ', .F.)

	Self:SetContentType("application/json")
	oRequest:FromJson(cBody)

	oRequest['cEmpAnt']      := cEmpAnt
	oRequest['cFilAnt']      := cFilAnt
	oRequest['cUserId']      := __CUSERID
	
	cCodRel := oRequest['codRel']

	// Busca configurações do relatório
	If Empty(cCodRel)
		cCodRel    := AllTrim(JurGetDados("NQR", 2, xFilial("NQR") + cNameCfg, "NQR_COD")) // NQR_FILIAL + NQR_NOMRPT
	Else
		cNameCfg := AllTrim(JurGetDados("NQR", 1, xFilial("NQR") + cCodRel, "NQR_NOMRPT")) // NQR_FILIAL + NQR_COD
	EndIf

	cCodCfgRel := WSLPCfgRel(cCodRel)
	cNomerel   := JurTimeStamp(1) + "_relatorioprocesso_" + cUser
	cTipoAss   := oRequest['assuntos']
	cThread    := oRequest['thread']

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cCaminho := StrTran(cCaminho,"\","/")
	EndIf

	oRequest['cPathSpool'] := cCaminho
	oRequest['cPathDown']  := "\thf\download\"
	oRequest['cPathArq'] := oRequest['cPathSpool'] + cNomerel

	aAdd(aDadosImp, cNameCfg )
	aAdd(aDadosImp, cTipoAss )
	aAdd(aDadosImp, cUser )
	aAdd(aDadosImp, cThread )
	aAdd(aDadosImp, cParams )
	aAdd(aDadosImp, cCodCfgRel )
	aAdd(aDadosImp, cNomerel )
	aAdd(aDadosImp, cCaminho )
	aAdd(aDadosImp, cFilPro )
	aAdd(aDadosImp, cCajuri )

	/*
	 * Verifica se existe a tabela de notificação 
	 * caso exista, compara com o conteudo da propriedade background 
	 * caso não, ignora o conteudo da propriedade e define que será em primeiro plano
	*/
	If FWAliasInDic('O12')
		If VALTYPE(oRequest['background']) <> 'L'
			oRequest['background'] := .T.
		EndIf
	Else
		oRequest['background'] := .F.
	EndIf

	If oRequest['count'] > 0
	
		If lCorrige
			cQuery += " SELECT NQ3_CAJURI, NQ3_FILORI "
			cQuery += " FROM " + RetSqlName("NQ3")
			cQuery += " WHERE NQ3_FILIAL = '" + xFilial("NQ3") + "' "
			cQuery +=   " AND NQ3_SECAO = '" + oRequest["thread"] + "' "
			cQuery +=   " AND NQ3_CUSER = '" + __cUserID + "' "

			aCorrecao := JurSQL(cQuery, '*')
		EndIf

		If !oRequest['background']
			oResponse['operation'] := "DownloadFile"

			WSJCExpRel(oRequest:toJson(),, aDadosImp, lCorrige, aCorrecao, aTables )

			If File(cCaminho + cNomerel + ".pdf")
				oResponse['export'] := {}
				Aadd(oResponse['export'], JsonObject():New())
				oResponse['export'][1]['namefile'] := JConvUTF8(cNomerel + ".pdf")
				oResponse['export'][1]['filedata'] := encode64(DownloadBase(cCaminho + cNomerel + ".pdf"))
			Else
				lRet := .F.
			EndIf
		Else
			oResponse['operation'] := "Notification"
			oResponse['message']   := JConvUTF8(STR0030) // "O arquivo será gerado em segundo plano. Quando finalizado, será enviado uma notificação para realizar o download."
			If (lO17 := FWAliasInDic('O17'))
				oJsonRel := J288JsonRel()
				oJsonRel['O17_FILE']   := cNomerel + ".pdf"
				oJsonRel['O17_URLREQ'] := Substr(Self:GetPath(), At('JURCONTENCIOSO',Self:GetPath()))
				oJsonRel['O17_BODY']   := oRequest:toJson()
				J288GestRel(oJsonRel)

			EndIf

			STARTJOB("WSJCExpRel", GetEnvServer(), .F., oRequest:toJson(), ;
			         Iif(lO17, oJsonRel:toJson(),''), aDadosImp, lCorrige, aCorrecao, aTables )

		EndIf
	EndIf

	If lRet
		Self:SetResponse(oResponse:toJson())
	Else
		SetRestFault(400,EncodeUTF8(STR0031)) // "Arquivo não existe."
	EndIf

	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aDadosImp, 0)
	aDadosImp := Nil
	aSize(aCorrecao, 0)
	aCorrecao := Nil
	aSize(aTables, 0)
	aTables := Nil

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} WSJCExpRel
Função responsavel pela geração do relatório em excel, podendo ser chamada via job

@param cRequest  - string contendo o Json contendo os dados da requisição para ser gerado o pdf
@param cJsonRel  - String contendo json da gestão de relatórios (O17)
@param aDadosImp - Dados da configuração do relatório pdf
@param lCorrige  - Verifica se deve corrigir os valores
@param aCorrecao - Lista dos processos para serem corrigidos
@param aTables   - Lista de tabelas

@since 06/08/2021
/*/
//-----------------------------------------------------------------
Function WSJCExpRel(cRequest, cJsonRel, aDadosImp, lCorrige, aCorrecao, aTables)

Local aArea      := GetArea()
Local lRet       := .T.
Local oRequest   := JsonObject():New()
Local cFile2Down := ""
Local cPathArq   := ""
Local lO17       := .F.
Local oJsonRel   := nil
Local cNameCfg   := IIF( VALTYPE(aDadosImp[1]) <> "U", aDadosImp[1],   "" )
Local cTipoAss   := IIF( VALTYPE(aDadosImp[2]) <> "U", aDadosImp[2],   "" )
Local cUser      := IIF( VALTYPE(aDadosImp[3]) <> "U", aDadosImp[3],   "" )
Local cThread    := IIF( VALTYPE(aDadosImp[4]) <> "U", aDadosImp[4],   "" )
Local cParams    := IIF( VALTYPE(aDadosImp[5]) <> "U", aDadosImp[5],   "" )
Local cCodCfgRel := IIF( VALTYPE(aDadosImp[6]) <> "U", aDadosImp[6],   "" )
Local cNomerel   := IIF( VALTYPE(aDadosImp[7]) <> "U", aDadosImp[7],   "" )
Local cCaminho   := IIF( VALTYPE(aDadosImp[8]) <> "U", aDadosImp[8],   "" )
Local aListInd   := {}
Local nX         := 0

Default cJsonRel  := ""

	oRequest:FromJson(cRequest)

		// Caso chamado via StartJob, inicializa o ambiente
		If oRequest['background']
			RPCSetType(3) // Prepara o ambiente e não consome licença
			RPCSetEnv(oRequest["cEmpAnt"],oRequest["cFilAnt"], , , 'JURI') // Abre o ambiente
			__CUSERID := oRequest["cUserId"]

			If !Empty(cJsonRel)
				lO17 := .T.
				oJsonRel:= JsonObject():New()
				oJsonRel:FromJson(cJsonRel)
			Endif
		EndIf

		// Trava a execução atual
		oRequest['cIdThredExec'] := "WSJCExpRel" + __CUSERID + StrZero(Randomize(1,9999),4)

		If LockByName(oRequest["cIdThredExec"], .T., .T.)
			If lO17 
				oJsonRel['O17_BODY'] := oRequest:toJson() // cBody
				J288GestRel(oJsonRel)
			Endif
			// Executa a correção monetária para os processos
			If lCorrige .AND. Len(aCorrecao) > 0

				aListInd := oRequest['listAtuInd']
				If !Empty(aListInd) .And. Len(aListInd) > 0
					If lO17
						oJsonRel['O17_DESC'] := STR0032 // "Atualizando valores dos indíces"
						oJsonRel['O17_MAX']  := Len(aListInd)
						oJsonRel['O17_MIN']  := 0
						oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN']*100/oJsonRel['O17_MAX'],0)
						J288GestRel(oJsonRel)
					EndIf
					For nX := 1 to len(aListInd)

						JA216AtuAut(aListInd[nX])
						If lO17
							oJsonRel['O17_MIN']  := oJsonRel['O17_MIN'] + 1
							oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN']*100/oJsonRel['O17_MAX'],0)
							J288GestRel(oJsonRel)
						EndIf
					Next nX
				EndIf
			
				If lO17
					oJsonRel['O17_DESC']   := STR0033 // "Aplicando correção monetária"
					J288GestRel(oJsonRel)
				Endif
				JURA002( aCorrecao, aTables,.T. ,,,,.F. ,,,, oJsonRel)
			EndIf

			// Chama a função para gerar o relatório
			WSLPJURRel(cNameCfg, cTipoAss, cUser, cThread, cParams, cCodCfgRel, cNomerel, cCaminho, cJsonRel)

			// Deleta os registros da fila de impressão - NQ3
			DelRegFila(oRequest['cUserId'], oRequest['thread'])

			If oRequest['background']

				lRet := CreatePathDown(oRequest['cPathDown'])

				/*
				* Caso encontrado o arquivo, moverá para a pasta do \thf\download
				* e enviará a notificação para realizar o donwload do arquivo
				* Caso não encontrado, enviará uma notificação informando que não foi possivel gerar o arquivo
				*/
				cPathArq := cCaminho + cNomerel + '.pdf'
				If lRet .and. File(cPathArq)

					cFile2Down  := oRequest['cPathDown'] + cNomerel  + '.pdf'

					If __COPYFILE( cPathArq , cFile2Down )
						// Cria um registro na tabela O12 - do tipo de Download
						JA280Notify(I18n(STR0034,{oRequest['nomeModelo'],DtoC(dDataBase),Time()}), oRequest['cUserId'], "download", '3', "pdfExport", cFile2Down) // 'O relatório#1 ficou pronto, clique para fazer o download #2 às #3'

						If lO17
							DbSelectArea('O17')
							O17->(DbGoTo(oJsonRel['O17RECNO']))

							If O17->(Recno()) == oJsonRel['O17RECNO']
								O17->(RecLock('O17', .F.))
								O17->O17_FILE   :=  cNomerel + '.pdf'
								O17->O17_DESC   := STR0035 // "Arquivo pronto para download"
								O17->O17_URLDWN := cFile2Down
								O17->O17_STATUS := "2" // Sucesso
								O17->(MsUnLock())
							EndIf
						Endif
					Else
						lRet := .F.
					Endif
				Else
					lRet := .F.
				Endif

				If !lRet 
					// Cria um registro na tabela O12 - do tipo de notificação
					JA280Notify(I18n(STR0036,{oRequest['nomeModelo']}) , oRequest['cUserId'], "exclamation", '1', "pdfExport") //"Falha na geração do relatório#1"
					If lO17
						// Finaliza o arquivo com erro na gestão de download
						oJsonRel['O17_DESC']   := STR0036 //"Falha na geração do relatório#1"
						oJsonRel['O17_STATUS'] := "1" // Erro
						J288GestRel(oJsonRel)
					Endif
				Endif
				RpcClearEnv() // Reseta o ambiente
			Endif

			UnLockByName(oRequest["cIdThredExec"], .T., .T.)
		EndIf

	RestArea(aArea)
	aSize(aListInd, 0)
	aListInd := Nil

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} CreatePathDown
Função responsavel pela criação do caminho da pasta /thf/download/

@param cPathDown - Caminho para criar a pasta de download
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Static Function CreatePathDown(cPathDown)
	Local lRet     := .T.
	Local aAuxPath := nil
	Local cPathAux := ""
	Local cSlash   := If("Linux" $ GetSrvInfo()[2],'/','\')
	Local n1       := 0

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cPathDown := StrTran(cPathDown,"\","/")
	Endif

	If !ExistDir(cPathDown)
		aAuxPath := Separa(cPathDown,cSlash)
		For n1 := 1 To Len(aAuxPath)
			If Empty(aAuxPath[n1])
				loop
			Endif

			cPathAux += cSlash+aAuxPath[n1]

			If !ExistDir(cPathAux)
				If MakeDir(cPathAux) <> 0
					lRet := .F.
					exit
				Endif
			Endif
		Next
		//Redundancia para garantir que a pasta foi criada depois de realizar a criação
		lRet := lRet .and. ExistDir(cPathDown)

		aSize(aAuxPath,0)
		aAuxPath := nil
	EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DelRegFila
Deleta a Thread da fila de impressão após exportar os dados

@param   cUser   - Código do usuário Protheus
@param   cThread - Numero da Threa atual da exportação
@Return  lRet    - Verifica se executou a query no banco
@since 30/09/2019
/*/
//-----------------------------------------------------------------
Static Function DelRegFila(cUser, cThread)
	Local lRet   := .T.
	Local cQuery := ""

	cQuery += " DELETE FROM " + RetSqlName("NQ3") + " "
	cQuery += " WHERE NQ3_FILIAL ='" + xFilial("NQ3") + "' AND "
	cQuery += " NQ3_CUSER ='" + cUser + "' AND "
	cQuery += " NQ3_SECAO ='" + cThread + "' "

	lRet := TcSqlExec(cQuery) < 0

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetProvisao
Busca da estrutura de uma determinada rotina.

@param  cajuri     Caractere - Id do processo "cajuri em base64"
@return aProv      Array     - Array com os valores de provisão
		{
			[1] = O0W_VPROVA
			[2] = O0W_VATPRO
			[3] = O0W_VPOSSI
			[4] = O0W_VATPOS
			[5] = O0W_VREMOT
			[6] = O0W_VATREM
			[7] = O0W_VINCON
			[8] = O0W_VATINC 
		}
@since 04/08/12/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/getProvisao/MDAwMDAwMDEzNw==
/*/
//-------------------------------------------------------------------
WSMETHOD GET GetProvisao PATHPARAM cajuri WSREST JURCONTENCIOSO
Local oResponse := JsonObject():New()
Local aCampos   := {"O0W_VPROVA","O0W_VATPRO","O0W_VPOSSI","O0W_VATPOS","O0W_VREMOT","O0W_VLREDU","O0W_VATREM","O0W_VINCON","O0W_VATINC"}
Local aValores  := {}
Local nI        := 0
Local lRet      := .F.

	aValores := J270_PROV(Decode64(Self:cajuri))
	lRet:= (Len(aValores) > 0)

	Self:SetContentType("application/json")
	oResponse['provisao'] := JsonObject():New()
	oResponse['provisao']['temValor'] := .F.

	For nI := 1 To Len(aCampos )
		If lRet .And. aValores[1][nI] > 0
			oResponse['provisao'][aCampos[nI]] := aValores[1][nI]
			oResponse['provisao']['temValor'] := .T.
		Else
			oResponse['provisao'][aCampos[nI]] := 0
		EndIf

	Next nI

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aCampos, 0)
	aCampos := Nil
	aSize(aValores, 0)
	aValores := Nil

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} fornecedor
Monta o Json para retornar os fornecedores (escritório credenciados)

@param   creden    - Parametro para ver se o escritório é credenciado
@param   pk        - Chave primária
@param   searchKey - Palavra pesquisada
@Return  lRet      - .T.
@since 14/12/2021
/*/
//-----------------------------------------------------------------
WSMETHOD GET fornecedor PATHPARAM creden WSRECEIVE pk, searchKey, filter WSREST JURCONTENCIOSO
Local oResponse    := JsonObject():New()
Local nIJson       := 0
Local cQuery       := ''
Local cAlias       := GetNextAlias()
Local cChave       := Self:pk
Local cSearchKey   := Self:searchKey
Local cTipoBusc    := IIf(Self:creden=='credenciado', '1', '2')
Local lFilter      := Self:filter

Default lFilter    := .F.

	oResponse["escritorios"] := {}

	If !Empty(cChave)
		DbSelectArea("SA2")
			SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
			If(SA2->(dbSeek(xFilial('SA2')+cChave)))
			
				Aadd(oResponse["escritorios"], JsonObject():New())

				oResponse["escritorios"][1]["nome"]   := JConvUTF8(SA2->(A2_NOME))
				oResponse["escritorios"][1]["chave"]  := SA2->(A2_COD) + '<separador>' + SA2->(A2_LOJA)
				oResponse["escritorios"][1]["cgc"]    := SA2->(A2_CGC)
			EndIf

		SA2->(DbCloseArea())
	Else
		cQuery := QryEscCred(cSearchKey, cTipoBusc, lFilter)

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While (cAlias)->(!Eof()) .And. nIJson < 10
			nIJson++
			Aadd(oResponse["escritorios"], JsonObject():New())
			oResponse["escritorios"][nIJson]["nome"]   := JConvUTF8((cAlias)->(A2_NOME))
			oResponse["escritorios"][nIJson]["chave"]  := (cAlias)->(A2_COD) + '<separador>' + (cAlias)->(A2_LOJA)
			oResponse["escritorios"][nIJson]["cgc"]    := (cAlias)->(A2_CGC)
			
			(cAlias)->(DbSkip())
		End

		(cAlias)->( DbCloseArea() )
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} QryEscCred
Faz a query para retornar os escritórios credenciados

@param   cFiltro   - Filtro digitado pelo usuãrio
@param   cCreden   - Credenciado
@param   lFilter   - Se aplica o filtro A2_MJURIDI='1'
@Return  cQuery    - Query a ser consultada
@since 14/12/2021
/*/
//-----------------------------------------------------------------
Static Function QryEscCred(cFiltro, cCreden, lFilter)
Local cQuery      := ""

Default cFiltro   := ""
Default cCreden   := "2"

	cQuery := 'SELECT '
	cQuery += 	' A2_NOME, '
	cQuery += 	' A2_LOJA, '
	cQuery += 	' A2_COD, '
	cQuery += 	' A2_CGC '

	cQuery += ' FROM ' + RetSqlName("SA2")

	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=   " AND A2_FILIAL = '" + xFilial('SA2') + "' "
	cQuery += 	" AND A2_MSBLQL = '2' "

	If lFilter
		cQuery += 	" AND A2_MJURIDI = '" + cCreden + "' "
	EndIf
	
	If !Empty(cFiltro)
		cQuery += " AND " + JA020QryFil(cFiltro, 'A2_NOME || A2_CGC || A2_NREDUZ')
	EndIf

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} unidade
Monta o Json para retornar as unidades

@param   pk        - Chave primária
@param   searchKey - Palavra pesquisada
@param   filter    - Filtro para unidades
@Return  lRet      - .T.
@since 14/12/2021
/*/
//-----------------------------------------------------------------
WSMETHOD GET unidade WSRECEIVE pk, searchKey, filter WSREST JURCONTENCIOSO
Local oResponse    := JsonObject():New()
Local nIJson       := 0
Local cQuery       := ''
Local cAlias       := GetNextAlias()
Local cChave       := Self:pk
Local cSearchKey   := Self:searchKey
Local lFilter      := Self:filter
Local aCodLoja     := {}

Default lFilter    := .F.

	oResponse["unidades"] := {}

	If !Empty(cChave)
		aCodLoja := Separa(cChave,'<separador>')

		If Len(aCodLoja) == 2
			cChave := Padr(aCodLoja[1],TamSx3('A1_COD')[1])+Padr(aCodLoja[2],TamSx3('A1_LOJA')[1])
		EndIf

		DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
			If(SA1->(dbSeek(xFilial('SA1')+cChave)))
			
				Aadd(oResponse["unidades"], JsonObject():New())

				oResponse["unidades"][1]["nome"]    := JConvUTF8(SA1->(A1_NOME))
				oResponse["unidades"][1]["cgc"]     := SA1->(A1_CGC)
				oResponse["unidades"][1]["chave"]   := SA1->(A1_COD) + '<separador>' + SA1->(A1_LOJA)
			EndIf

		SA1->(DbCloseArea())
	Else
		cQuery := QryUnidade(cSearchKey, lFilter)

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While (cAlias)->(!Eof()) .And. nIJson < 10
			nIJson++
			Aadd(oResponse["unidades"], JsonObject():New())
			oResponse["unidades"][nIJson]["nome"]   := JConvUTF8((cAlias)->(A1_NOME))
			oResponse["unidades"][nIJson]["cgc"]    := (cAlias)->(A1_CGC)
			oResponse["unidades"][nIJson]["chave"]  := (cAlias)->(A1_COD) + '<separador>' + (cAlias)->(A1_LOJA)
			
			(cAlias)->(DbSkip())
		End

		(cAlias)->( DbCloseArea() )
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aCodLoja, 0)
	aCodLoja := Nil

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} QryUnidade
Faz a query para retornar as unidades

@param   cFiltro   - Filtro digitado pelo usuãrio
@param   lFilter   - Filtro para unidade
@Return  cQuery    - Query a ser consultada
@since 14/12/2021
/*/
//-----------------------------------------------------------------
Static Function QryUnidade(cFiltro, lFilter)
Local cQuery      := ""

Default cFiltro   := ""

	cQuery := 'SELECT '
	cQuery += 	' A1_NOME, '
	cQuery += 	' A1_CGC, '
	cQuery += 	' A1_COD, '
	cQuery += 	' A1_LOJA '

	cQuery += ' FROM ' + RetSqlName("SA1") + " SA1 "

	If lFilter
		cQuery += ' INNER JOIN ' + RetSqlName("NUH") + " NUH "
		cQuery +=    " ON ( NUH_FILIAL = A1_FILIAL "
		cQuery +=        " AND NUH_COD = A1_COD "
		cQuery +=        " AND NUH_LOJA = A1_LOJA "
		cQuery +=        " AND NUH.D_E_L_E_T_ = ' ' "
		cQuery +=        " AND NUH_CASAUT = '1' ) "
	EndIf

	cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery += 	" AND A1_MSBLQL = '2' "
	cQuery +=   " AND A1_FILIAL = '" + xFilial('SA1') + "' "

	If !Empty(cFiltro)
		cQuery += " AND " + JA020QryFil(cFiltro, 'A1_COD || A1_NOME || A1_CGC || A1_NREDUZ')
	EndIf

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} gerente
Monta o Json para retornar os gerentes

@param   pk        - Chave primária
@param   searchKey - Palavra pesquisada
@Return  lRet      - .T.
@since 14/12/2021
/*/
//-----------------------------------------------------------------
WSMETHOD GET gerente WSRECEIVE pk, searchKey WSREST JURCONTENCIOSO
Local oResponse    := JsonObject():New()
Local nIJson       := 0
Local cQuery       := ''
Local cAlias       := GetNextAlias()
Local cChave       := Self:pk
Local cSearchKey   := Self:searchKey

	oResponse["gerente"] := {}

	cQuery := QryGerente(cSearchKey, cChave)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While (cAlias)->(!Eof()) .And. nIJson < 10
		nIJson++
		Aadd(oResponse["gerente"], JsonObject():New())
		oResponse["gerente"][nIJson]["nome"]     := JConvUTF8((cAlias)->(RD0_NOME))
		oResponse["gerente"][nIJson]["cic"]      := (cAlias)->(RD0_CIC)
		oResponse["gerente"][nIJson]["chave"]    := JConvUTF8((cAlias)->(RD0_SIGLA))
		oResponse["gerente"][nIJson]["codUser"]  := JConvUTF8((cAlias)->(RD0_USER))
		oResponse["gerente"][nIJson]["codigo"]   := JConvUTF8((cAlias)->(RD0_CODIGO))

		(cAlias)->(DbSkip())
	End

	(cAlias)->( DbCloseArea() )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} QryGerente
Faz a query para retornar os gerentes

@param   cFiltro   - Filtro digitado pelo usuãrio
@Return  cQuery    - Query a ser consultada
@since 14/12/2021
/*/
//-----------------------------------------------------------------
Static Function QryGerente(cFiltro, cChave)
Local cQuery      := ""

Default cFiltro   := ""
Default cChave    := ""

	cQuery := 'SELECT '
	cQuery += 	' RD0_NOME, '
	cQuery += 	' RD0_CIC, '
	cQuery += 	' RD0_SIGLA, '
	cQuery +=   ' RD0_USER, '
	cQuery +=   ' RD0_CODIGO '

	cQuery += ' FROM ' + RetSqlName("RD0")

	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=   " AND RD0_TPJUR = '1' "
	cQuery +=   " AND RD0_SIGLA <> ' ' "
	cQuery +=   " AND RD0_MSBLQL <> '1' "
	cQuery +=   " AND RD0_FILIAL = '" + xFilial('RD0') + "' "

	If !Empty(cChave)
		If At(',', cChave) > 0
			cQuery += " AND ( RD0_CODIGO IN " + FormatIn( cChave, ',' )
			cQuery +=       " OR RD0_SIGLA IN " + FormatIn( cChave, ',' ) + " ) "
		Else
			cQuery += " AND ( RD0_CODIGO = '" + cChave + "' "
			cQuery +=       " OR RD0_SIGLA = '" + cChave + "' ) "
		EndIf
	EndIf
	
	If !Empty(cFiltro)
		cQuery += " AND " + JA020QryFil(cFiltro, 'RD0_NOME || RD0_CIC || RD0_SIGLA')
	EndIf

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} pedido
Monta o Json para retornar os pedidos

@param   pk        - Palavra chave (código)
@param   searchKey - Palavra pesquisada
@param   assunto   - Código de Assunto Jurídico
@Return  lRet      - .T.
@since 17/12/2021
/*/
//-----------------------------------------------------------------
WSMETHOD GET pedido WSRECEIVE pk, searchKey, assunto WSREST JURCONTENCIOSO
Local oResponse    := JsonObject():New()
Local nIJson       := 0
Local cQuery       := ''
Local cAlias       := GetNextAlias()
Local cSearchKey   := Self:searchKey
Local cAssunto     := Self:assunto
Local cChave       := Self:pk
Local aArea        := {}

	oResponse["pedido"] := {}

	If !Empty(cChave)
		aArea := NSP->(GetArea())
		DbSelectArea("NSP")
			NSP->(DbSetOrder(1)) //NSP_FILIAL+NSP_CODIGO
			If(NSP->(dbSeek(xFilial('NSP')+cChave)))
			
				Aadd(oResponse["pedido"], JsonObject():New())

				oResponse["pedido"][1]["descricao"]   := JConvUTF8(NSP->(NSP_DESC))
				oResponse["pedido"][1]["codigo"]      := NSP->(NSP_COD)
			EndIf

		NSP->(DbCloseArea())
		RestArea(aArea)
	Else
		cQuery := QryPedido(cSearchKey, cAssunto)

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While (cAlias)->(!Eof()) .And. nIJson < 10
			nIJson++
			Aadd(oResponse["pedido"], JsonObject():New())
			oResponse["pedido"][nIJson]["descricao"]   := JConvUTF8((cAlias)->(NSP_DESC))
			oResponse["pedido"][nIJson]["codigo"]      := (cAlias)->(NSP_COD)
			
			(cAlias)->(DbSkip())
		End

		(cAlias)->( DbCloseArea() )
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} QryPedido
Faz a query para retornar os pedidos

@param   cFiltro   - Filtro digitado pelo usuário
@param   cAssunto  - Código de Assunto Jurídico

@Return  cQuery    - Query a ser consultada
@since 17/12/2021
/*/
//-----------------------------------------------------------------
Static Function QryPedido(cFiltro, cAssunto)
Local cQuery := ""

Default cFiltro  := ""
Default cAssunto := ""

	cQuery := JUR94NSP(cAssunto)

	If !Empty(cFiltro)
		cQuery += " AND " + JA020QryFil(cFiltro, 'NSP_DESC || NSP_COD')
	EndIf

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDistrib
Monta o Json para retornar as Distribuições

@body   filtros  Json  { "filtros": "(NZZ_STATUS = '2' OR NZZ_STATUS = '3')"
						"palavraChave": ["abc", "def", "ghi"]
						}
@Return  distribuicoes Json {}
@since 21/12/2021
/*/
//-----------------------------------------------------------------
WSMETHOD POST GetDistrib WSRECEIVE pk, searchKey, assunto WSREST JURCONTENCIOSO
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local aRet       := {}
Local cBody      := Self:GetContent()
Local nI         := 0
Local cLink      := ""

	If !Empty(cBody)
		oRequest:fromJson(cBody)
		aRet := GetDist(oRequest)
	EndIf

	oResponse['total']:= Len(aRet)

	If Len(aRet) > 0

		oResponse['distribuicao'] := {}

		For nI := 1 To Len(aRet)

			If nI <= oRequest['pageSize']
				
				Aadd(oResponse['distribuicao'], JsonObject():New())

				cLink :=  JURGETDADOS("NZZ", 1, xFilial("NZZ") + aRet[nI][18], "NZZ_LINK")
				cLink := IIF( VALTYPE(cLink) <> "U", cLink, "")

				oResponse['distribuicao'][nI]['NZZ_CAJURI'] := aRet[nI][1]
				oResponse['distribuicao'][nI]['NZZ_NUMPRO'] := JConvUTF8(aRet[nI][2])
				oResponse['distribuicao'][nI]['NZZ_AUTOR']  := JConvUTF8(aRet[nI][3])
				oResponse['distribuicao'][nI]['NZZ_REU']    := JConvUTF8(aRet[nI][4])
				oResponse['distribuicao'][nI]['NZZ_DTDIST'] := aRet[nI][5]
				oResponse['distribuicao'][nI]['NZZ_DTREC']  := aRet[nI][6]
				oResponse['distribuicao'][nI]['NZZ_OCORRE'] := JConvUTF8(aRet[nI][7])
				oResponse['distribuicao'][nI]['NZZ_VALOR']  := aRet[nI][8]
				oResponse['distribuicao'][nI]['NZZ_DTAUDI'] := aRet[nI][9]
				oResponse['distribuicao'][nI]['NZZ_TRIBUN'] := JConvUTF8(aRet[nI][10])
				oResponse['distribuicao'][nI]['NZZ_ERRO']   := JConvUTF8(aRet[nI][11])
				oResponse['distribuicao'][nI]['NZZ_STATUS'] := JConvUTF8(aRet[nI][12])
				oResponse['distribuicao'][nI]['NZZ_CIDADE'] := JConvUTF8(aRet[nI][13])
				oResponse['distribuicao'][nI]['NZZ_FORUM']  := JConvUTF8(aRet[nI][14])
				oResponse['distribuicao'][nI]['NZZ_VARA']   := JConvUTF8(aRet[nI][15])
				oResponse['distribuicao'][nI]['NZZ_ESTADO'] := JConvUTF8(aRet[nI][16])
				oResponse['distribuicao'][nI]['NZZ_COD']    := JConvUTF8(aRet[nI][18])
				oResponse['distribuicao'][nI]['NZZ_LINK']   := JConvUTF8(cLink)
				oResponse['distribuicao'][nI]['pk']         := Encode64( aRet[nI][17] + aRet[nI][18] )
			Else
				Exit
			End
		Next nI

	Endif

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	aSize(aRet, 0)

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDist
Busca a lista de publicvações conforme os filtros especificados

@body   oRequest  Json  { "filtros": "(NZZ_STATUS = '2' OR NZZ_STATUS = '3')",
						"palavraChave": ["abc", "def", "ghi"],
						"pageSize": 8
						}
@Return  array registros
@since 21/12/2021
/*/
//-----------------------------------------------------------------
Static Function GetDist(oRequest)
Local cSQL       := ""
Local cFrom      := ""
Local cWhere     := ""
Local aFieldsRet := ""
Local cFldSearch := ""
Local cKeyWord   := ""
Local nI         := 0
Local aPk        := getPk('NZZ')

	cFldSearch := 'NZZ_ESCRI||NZZ_TERMO||NZZ_TRIBUN||NZZ_OCORRE||NZZ_REU||NZZ_LOGIN||'
	cFldSearch += 'NZZ_AUTOR||NZZ_FORUM||NZZ_VARA||NZZ_CIDADE||NZZ_ESTADO||NZZ_ADVOGA||'
	cFldSearch += 'NZZ_NUMPRO'

	aFieldsRet := {'NZZ_CAJURI','NZZ_NUMPRO','NZZ_AUTOR','NZZ_REU','NZZ_DTDIST','NZZ_DTREC',;
				'NZZ_OCORRE','NZZ_VALOR','NZZ_DTAUDI','NZZ_TRIBUN','NZZ_ERRO','NZZ_STATUS',;
				'NZZ_CIDADE','NZZ_FORUM','NZZ_VARA','NZZ_ESTADO' }

	For nI := 1 to Len(aPk) -1
		aAdd(aFieldsRet, aPk[nI])
	Next nI

	nI   := 0
	cSQL := 'SELECT '
	
	For nI := 1 to Len(aFieldsRet)
		If nI == 1
			cSQL += aFieldsRet[nI]
		Else
			cSQL += ", " + aFieldsRet[nI]
		EndIf	
	Next nI

	cFrom += ' FROM ' + RetSqlName("NZZ") 

	cWhere += " WHERE D_E_L_E_T_ = ' ' "

	If !Empty(oRequest["filtros"])
		cWhere += " AND " + oRequest["filtros"]
	End

	nI := Len(oRequest["palavraChave"])	
	
	If nI > 0
		cKeyWord := JA020QryFil("palavraChave", cFldSearch, .F.)
		cKeyWord := STRTRAN(cKeyWord, ')  LIKE ', ') LIKE ')
		cKeyWord := SubStr(cKeyWord,0, At(') LIKE ', cKeyWord) +1 )
		cSQL += ", " + cKeyWord + " PALAVRA "
		cSQL:= " SELECT * FROM (" + cSQL + cFrom + cWhere + ") NZZ "

		While nI > 0
			cKeyWord := DecodeUTF8(oRequest["palavraChave"][nI])
			cKeyWord := JurClearStr(cKeyWord, .T., .T., .F., ,  )
			cKeyWord := StrTran(cKeyWord,'#','')
			
			If nI == Len(oRequest["palavraChave"])
				cWhere := " WHERE "
			Else
				cWhere += " AND "
			EndIf

			cWhere +=  " PALAVRA LIKE '%" + cKeyWord + "%' "
			nI--
		End

	else
		 cSQL := cSQL + cFrom
	EndIf

	cSQL := StrTran(cSQL + cWhere,'#','')

Return JurSql(cSQL, aFieldsRet,,,.F.)


//-----------------------------------------------------------------
/*/{Protheus.doc} getPk
Busca os campos da pk da tabela

@Return  array registros
@since 21/12/2021
/*/
//-----------------------------------------------------------------
Static Function getPk(cTable)
Local aPK := {}

	cPk := FWX2Unico(cTable)
	aPK := StrToArray(cPk, '+' )
	aAdd(aPK, StrTran(cPk, '+', ', ' ))

Return aPK

//-------------------------------------------------------------------
/*/{Protheus.doc} qtdPub()
Metódo responsável por buscar a quantidade de publicações
@param dtInicial - data inicial do filtro
@param dtFinal   - data final do filtro

@since 23/12/2021
/*/
//-------------------------------------------------------------------
WSMETHOD GET qtdPub WSRECEIVE dtInicial, dtFinal WSREST JURCONTENCIOSO
Local oResponse   := JsonObject():New()
Local cAlias      := GetNextAlias()
Local dDtInicial  := Self:dtInicial
Local dDtFinal    := Self:dtFinal
Local cQuery      := ""

Default dDtInicial := ''
Default dDtFinal   := DTOS(Date())

	Self:SetContentType("application/json")

	cQuery += " SELECT COUNT(1) QTD "
	cQuery += " FROM " + RetSqlName("NR0") + " NR0 "
	cQuery += " WHERE NR0.NR0_FILIAL = '" + xFilial('NR0') + "' "
	cQuery +=        " AND NR0.NR0_DTCHEG BETWEEN '" + dDtInicial + "' AND '" + dDtFinal + "' "
	cQuery +=        " AND NR0.NR0_SITUAC IN ('1','3') "
	cQuery +=        " AND NR0.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['qtd'] := (cAlias)->QTD

	(cAlias)->( DbCloseArea() )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} BuscaPubs
Metódo responsável por buscar o relatório das publicações
Monta o Json para retornar as Publicações

@body   filtros  Json  { "filtros": " NRO_SITUAC = ('2','3') "
						"palavraChave": ["abc", "def", "ghi"]
						"pageSize": 8,
						"area":'004'
						}
@Return  publicações Json {}
@since 05/01/2022
/*/
//-----------------------------------------------------------------
WSMETHOD POST BuscaPubs WSREST JURCONTENCIOSO

Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cBody      := Self:GetContent()
Local cTeorPub   := ""
Local cQuery     := ""
Local nI         := 1
Local nTotal     := 0

	oResponse['publicacoes'] := {}

	If !Empty(cBody)
		oRequest:fromJson(cBody)
		cQuery := WSJCGetPub(oRequest)
	EndIf

	If !Empty(cQuery)

		cQuery := StrTran(cQuery,'#','')

		DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

		While !(cAlias)->( EOF())
			If nI <= oRequest['pageSize']
				
				aAdd(oResponse['publicacoes'], JsonObject():New())

				cTeorPub := JURGETDADOS("NR0", 1, (cAlias)->NR0_FILIAL + (cAlias)->NR0_CODIMP + (cAlias)->NR0_CODSEQ, "NR0_TEORPB")
				cTeorPub := IIF( VALTYPE(cTeorPub) <> "U", cTeorPub, "")

				oResponse['publicacoes'][nI]['NR0_NUMPRO'] := JConvUTF8( (cAlias)->NR0_NUMPRO )
				oResponse['publicacoes'][nI]['NR0_NOME']   := JConvUTF8( (cAlias)->NR0_NOME )
				oResponse['publicacoes'][nI]['NR0_ORGAO']  := JConvUTF8( (cAlias)->NR0_ORGAO )
				oResponse['publicacoes'][nI]['NR0_TEORPB'] := IIF( VALTYPE(EncodeUTF8( cTeorPub )) <> "U", JConvUTF8( cTeorPub ), cTeorPub)
				oResponse['publicacoes'][nI]['NR0_ERRO']   := JConvUTF8( (cAlias)->NR0_ERRO )
				oResponse['publicacoes'][nI]['NR0_CAJURI'] := JConvUTF8( (cAlias)->NR0_CAJURI )
				oResponse['publicacoes'][nI]['NR0_FILPRO'] := JConvUTF8( (cAlias)->NR0_FILPRO )
				oResponse['publicacoes'][nI]['NR0_CODREL'] := JConvUTF8( (cAlias)->NR0_CODREL )
				oResponse['publicacoes'][nI]['NR0_JORNAL'] := JConvUTF8( (cAlias)->NR0_JORNAL )
				oResponse['publicacoes'][nI]['NR0_CIDADE'] := JConvUTF8( (cAlias)->NR0_CIDADE )
				oResponse['publicacoes'][nI]['NR0_VARA']   := JConvUTF8( (cAlias)->NR0_VARA )
				oResponse['publicacoes'][nI]['NR0_CAJURP'] := JConvUTF8( (cAlias)->NR0_CAJURP )
				oResponse['publicacoes'][nI]['NR0_DTPUBL'] := (cAlias)->NR0_DTPUBL
				oResponse['publicacoes'][nI]['NR0_DTCHEG'] := (cAlias)->NR0_DTCHEG
				oResponse['publicacoes'][nI]['NR0_SITUAC'] := (cAlias)->NR0_SITUAC
				oResponse['publicacoes'][nI]['NR0_FILIAL'] := (cAlias)->NR0_FILIAL
				oResponse['publicacoes'][nI]['NR0_CODIMP'] := JConvUTF8( (cAlias)->NR0_CODIMP )
				oResponse['publicacoes'][nI]['NR0_CODSEQ'] := JConvUTF8( (cAlias)->NR0_CODSEQ )
				oResponse['publicacoes'][nI]['pk']         := Encode64( (cAlias)->NR0_FILIAL + (cAlias)->NR0_CODIMP + (cAlias)->NR0_CODSEQ )
				nI++
			Else
				Exit
			EndIf
			(cAlias)->( dbSkip() )
		End
		nTotal := (cAlias)->(ScopeCount())
	EndIf

	oResponse['total']:= nTotal

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} WSJCGetPub
Busca a lista de publicações conforme os filtros especificados

@body   oRequest  Json  { "filtros": "NRO_SITUAC IN ('2','3')",
						"palavraChave": ["abc", "def", "ghi"],
						"pageSize": 8,
						"area:'004' "
						}
@Return  array registros
@since 21/12/2021
/*/
//-----------------------------------------------------------------
Static Function WSJCGetPub(oRequest)
Local cSQL       := ""
Local cFrom      := ""
Local cWhere     := ""
Local aFieldsRet := ""
Local cFldSearch := ""
Local cKeyWord   := ""
Local cOrderBy   := ""
Local nI         := 0
Local aPk        := getPk('NR0')

	cFldSearch := JQryMemo("NR0_NOME") + " || " 
	cFldSearch += JQryMemo("NR0_NUMPRO") + " || " 
	cFldSearch += JQryMemo("NR0_TEORPB ",,TAMSX3('NR0_NOME')[1] + TAMSX3('NR0_NUMPRO')[1]) + " "

	aFieldsRet := { 'NR0_NUMPRO', 'NR0_NOME',   'NR0_ORGAO',  'NR0_TEORPB', 'NR0_ERRO',;
					'NR0_CAJURI', 'NR0_FILPRO', 'NR0_CODREL', 'NR0_JORNAL', 'NR0_CIDADE',;
					'NR0_VARA',   'NR0_CAJURP', 'NR0_DTPUBL', 'NR0_DTCHEG', 'NR0_SITUAC' }

	For nI := 1 to Len(aPk) -1
		aAdd(aFieldsRet, aPk[nI])
	Next nI

	nI   := 0
	cSQL := 'SELECT '

	cFrom += ' NR0.* FROM ' + RetSqlName("NR0") + " NR0"
	cWhere += " WHERE D_E_L_E_T_ = ' ' "

	If !Empty(oRequest["filtros"])
		cWhere += " AND " + oRequest["filtros"]
	End

	nI := Len(oRequest["palavraChave"])
	
	If nI > 0
		cKeyWord := JA020QryFil("palavraChave", cFldSearch, .F.)
		cKeyWord := SubStr(cKeyWord,0, At(") LIKE '",cKeyWord) +1 )
		cSQL += " " + cKeyWord + " PALAVRA "
		cSQL :=  cSQL + ' , ' + cFrom
		cSQL:= " SELECT * FROM (" + cSQL + cWhere + ") SUB1 "

		While nI > 0
			cKeyWord := DecodeUTF8(oRequest["palavraChave"][nI])
			cKeyWord := JurClearStr(cKeyWord, .T., .T., .F., ,  )
			
			If nI == Len(oRequest["palavraChave"])
				cWhere := " WHERE "
			Else
				cWhere += " AND "
			EndIf

			cWhere += " PALAVRA LIKE '%" + cKeyWord + "%' "
			nI--
		End
	else
		cSQL := ( cSQL + cFrom )
	EndIf

	If !Empty(oRequest["area"])
		cWhere += " AND EXISTS( "
		cWhere +=          " SELECT 1 "
		cWhere +=          " FROM " + RetSqlName('NSZ') + " NSZ "
		cWhere +=          " WHERE NSZ.D_E_L_E_T_ = ' ' "
		cWhere +=            " AND NSZ.NSZ_FILIAL = NR0_FILPRO "
		cWhere +=            " AND NSZ.NSZ_COD = NR0_CAJURI "
		cWhere +=            " AND NSZ.NSZ_CAREAJ = '" + oRequest["area"] + "') "
	EndIf

	cOrderBy := " ORDER BY NR0_SITUAC, NR0_ERRO DESC "



Return ChangeQuery(cSQL + cWhere + cOrderBy)

//-------------------------------------------------------------------
/*/{Protheus.doc} POST ExportPubs
Recebe os dados filtrados no painel de Publicações e gera a exportação  em Excel (XLSX)

@Return lRet - Lógico que indica se o arquivo foi gerado.
@since 07/01/2022
@example [Sem Opcional] POST -> http://127.0.0.1:9090/rest/JURCONTENCIOSO/exportPubs
@body   oRequest  Json  { "filtros": " NRO_SITUAC IN ('2','3') ",
						"palavraChave": ["abc", "def", "ghi"],
						"pageSize": 8,
						"area": '0004'
						}
/*/
//-------------------------------------------------------------------
WSMETHOD POST ExportPubs WSREST JURCONTENCIOSO

Local aArea     := GetArea()
Local cAlias    := GetNextAlias()
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()
Local oJsonRel  := nil
Local cBody     := Self:GetContent()
Local lO17      := FWAliasInDic('O17')
Local lRet      := .T.
Local lXlsx     := .F.
Local lError    := .F.
Local aDetail   := {}
Local aDadosRel := {}
Local aDadosErr := {}
Local aHeader   := {}
Local nTotal    := 0
Local cQuery    := ""
Local cAuxSitua := ""
Local cPathArq  := ""
Local cSpool    := ""
Local cPathDown := ""
Local cTeorPub  := ""
Local cNomeArq  := JurTimeStamp(1) + "_" + STR0045 + "_" + RetCodUsr() //"Publicações"

	lXlsx := __FWLibVersion() >= '20201009' .And. ;
			GetRpoRelease() >= '12.1.023' .And. ;
			PrinterVersion():fromServer() >= '2.1.0'

	lRet := lXlsx

	If lRet

		If !Empty(cBody)
			aAdd( aHeader, { 'NR0_FILIAL','NR0_CODIMP','NR0_CODSEQ','NR0_CAJURI','NR0_NUMPRO',;
					'NR0_DTPUBL','NR0_OBS','NR0_TEORPB','NR0_PAGINA',;
					'NR0_CODREL','NR0_NOME','NR0_JORNAL','NR0_VARA','NR0_CIDADE',;
					'NR0_ORGAO','NR0_DTALTE','NR0_USRALT','NR0_DTEXCL','NR0_USREXC',;
					'NR0_SITUAO','NR0_CCLIEN','NR0_DCLIEN','NR0_PROCO','NR0_DADVOG',;
					'NR0_NOMEPC','NR0_DADVPC', 'NR0_NOMEPI','NR0_FONTE','NR0_DTCHEG',;
					'NR0_CAJURP','NR0_SIGLA','NR0_FILPRO','NR0_LOGIN','NR0_ERRO'} )
			
			oRequest:fromJson(cBody)
			oRequest['cEmpAnt']  := cEmpAnt
			oRequest['cFilAnt']  := cFilAnt
			oRequest['cUserId']  := __CUSERID
			oRequest['cNomeArq'] := cNomeArq + ".xlsx"

			If lO17
				oJsonRel := J288JsonRel()
				oJsonRel['O17_FILE']   := oRequest['cNomeArq']
				oJsonRel['O17_URLREQ'] := Substr(Self:GetPath(), At('JURCONTENCIOSO', Self:GetPath()))
				oJsonRel['O17_BODY']   := oRequest:toJson()
				J288GestRel(oJsonRel)
			EndIf

			cQuery := WSJCGetPub(oRequest)
			cQuery := StrTran(cQuery,'#','')
			DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

			nTotal := (cAlias)->(ScopeCount())
			(cAlias)->(DbGoTop())
		EndIf

		If !Empty(cQuery) .AND. !(cAlias)->(EOF())

			// Tratamento para S.O Linux
			If "Linux" $ GetSrvInfo()[2]
				cSpool    := "/spool/"
				cPathDown := "/thf/download/"
			Else
				cSpool    := "\spool\"
				cPathDown := "\thf\download\"
			EndIf

			oRequest['cPathDown'] := cPathDown
			cPathArq := cSpool + cNomeArq

			If lO17
				oJsonRel['O17_MAX']  := nTotal
				oJsonRel['O17_MIN']  := 0
			EndIf

			// Organiza os dados de acordo com o status
			While !(cAlias)->(EOF())

				If lO17
					oJsonRel['O17_MIN']  := oJsonRel['O17_MIN'] + 1
					oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN'] * 100 / oJsonRel['O17_MAX'], 0)
					J288GestRel(oJsonRel)
				EndIf

				If (Empty(cAuxSitua) .OR. cAuxSitua == (cAlias)->NR0_SITUAC)
					cAuxSitua := (cAlias)->NR0_SITUAC
				Else
					cTitulo   := setaTitAba( cAuxSitua, lError )
					aAdd( aDetail, {aClone(aDadosRel), cTitulo, cAuxSitua } )
					aSize(aDadosRel, 0)
					cAuxSitua := (cAlias)->NR0_SITUAC
				Endif

				lError := (cAlias)->NR0_SITUAC == '1' .AND. !Empty(Alltrim((cAlias)->NR0_ERRO))
				cTeorPub := JURGETDADOS("NR0", 1, (cAlias)->NR0_FILIAL + (cAlias)->NR0_CODIMP + (cAlias)->NR0_CODSEQ, "NR0_TEORPB")
				cTeorPub := IIF( VALTYPE(cTeorPub) <> "U", cTeorPub, "")

				aAdd( aDadosRel, { (cAlias)->NR0_FILIAL, Alltrim((cAlias)->NR0_CODIMP),;
									Alltrim((cAlias)->NR0_CODSEQ), Alltrim((cAlias)->NR0_CAJURI),;
									Alltrim((cAlias)->NR0_NUMPRO), ;
									Alltrim((cAlias)->NR0_DTPUBL), Alltrim((cAlias)->NR0_OBS),;
									Alltrim(cTeorPub),             Alltrim((cAlias)->NR0_PAGINA),;
									Alltrim((cAlias)->NR0_CODREL), Alltrim((cAlias)->NR0_NOME),;
									Alltrim((cAlias)->NR0_JORNAL), Alltrim((cAlias)->NR0_VARA),;
									Alltrim((cAlias)->NR0_CIDADE), Alltrim((cAlias)->NR0_ORGAO),;
									Alltrim((cAlias)->NR0_DTALTE), Alltrim((cAlias)->NR0_USRALT),;
									Alltrim((cAlias)->NR0_DTEXCL), Alltrim((cAlias)->NR0_USREXC),;
									Alltrim((cAlias)->NR0_SITUAO), Alltrim((cAlias)->NR0_CCLIEN),;
									Alltrim((cAlias)->NR0_DCLIEN), Alltrim((cAlias)->NR0_PROCO),;
									Alltrim((cAlias)->NR0_DADVOG), Alltrim((cAlias)->NR0_NOMEPC),;
									Alltrim((cAlias)->NR0_DADVPC), Alltrim((cAlias)->NR0_NOMEPI),;
									Alltrim((cAlias)->NR0_FONTE),  Alltrim((cAlias)->NR0_DTCHEG),;
									Alltrim((cAlias)->NR0_CAJURP), Alltrim((cAlias)->NR0_SIGLA),;
									(cAlias)->NR0_FILPRO,          Alltrim((cAlias)->NR0_LOGIN),;
									Alltrim((cAlias)->NR0_ERRO) } )

				If lError
					aAdd ( aDadosErr, { (cAlias)->NR0_FILIAL, Alltrim((cAlias)->NR0_CODIMP),;
									Alltrim((cAlias)->NR0_CODSEQ), Alltrim((cAlias)->NR0_CAJURI),;
									Alltrim((cAlias)->NR0_NUMPRO), ;
									Alltrim((cAlias)->NR0_DTPUBL), Alltrim((cAlias)->NR0_OBS),;
									Alltrim(cTeorPub),             Alltrim((cAlias)->NR0_PAGINA),;
									Alltrim((cAlias)->NR0_CODREL), Alltrim((cAlias)->NR0_NOME),;
									Alltrim((cAlias)->NR0_JORNAL), Alltrim((cAlias)->NR0_VARA),;
									Alltrim((cAlias)->NR0_CIDADE), Alltrim((cAlias)->NR0_ORGAO),;
									Alltrim((cAlias)->NR0_DTALTE), Alltrim((cAlias)->NR0_USRALT),;
									Alltrim((cAlias)->NR0_DTEXCL), Alltrim((cAlias)->NR0_USREXC),;
									Alltrim((cAlias)->NR0_SITUAO), Alltrim((cAlias)->NR0_CCLIEN),;
									Alltrim((cAlias)->NR0_DCLIEN), Alltrim((cAlias)->NR0_PROCO),;
									Alltrim((cAlias)->NR0_DADVOG), Alltrim((cAlias)->NR0_NOMEPC),;
									Alltrim((cAlias)->NR0_DADVPC), Alltrim((cAlias)->NR0_NOMEPI),;
									Alltrim((cAlias)->NR0_FONTE),  Alltrim((cAlias)->NR0_DTCHEG),;
									Alltrim((cAlias)->NR0_CAJURP), Alltrim((cAlias)->NR0_SIGLA),;
									(cAlias)->NR0_FILPRO,          Alltrim((cAlias)->NR0_LOGIN),;
									Alltrim((cAlias)->NR0_ERRO) } )
				EndIf

				(cAlias)->( dbSkip() )
			End

			If (cAlias)->(EOF()) .AND. Len(aDadosRel) > 0
				cTitulo   := setaTitAba( cAuxSitua, lError )
				aAdd( aDetail, {aClone(aDadosRel), cTitulo, cAuxSitua } )
				aSize(aDadosRel, 0)
			EndIf

			(cAlias)->(dbCloseArea())

			If Len(aDadosErr) > 0
				cTitulo   := setaTitAba( '8', .T. )
				aAdd( aDetail, {aClone(aDadosErr), cTitulo, '8' } )
				aSize(aDadosErr, 0)
			EndIf
		EndIf

		If Len(aDetail) > 0
			oResponse['operation'] := "Notification"
			oResponse['message']   := JConvUTF8(STR0046) // "O arquivo será gerado em segundo plano. Quando finalizado, será enviado uma notificação para realizar o download."

			// Geração do relatório
			STARTJOB( "JCExpRel", GetEnvServer(), .F.,;
					cPathArq, aHeader, aDetail, oRequest:toJson(), oJsonRel:toJson(), nTotal, lO17 )

			Self:SetResponse(oResponse:toJson())
		EndIf

	Else
		SetRestFault( 201, EncodeUTF8(STR0047) ) // "A versão do printer não permite exportar o relatório na extensão xlsx. Verifique!"
	EndIf

	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

	aSize(aDadosRel, 0)
	aSize(aDadosErr, 0)
	aSize(aDetail, 0)
	aSize(aHeader, 0)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} JCExpPubs
Responsável por montar o EXCEL (XLSX) de exportação
de Publicações do TOTVS Jurídico.


@param cPathArq  - Caminho do arquivo + nome do arquivo
@param  aHeader  - Campos do cabeçalho do excel
@param  aDetail  - Dados das linhas do excel
@param  cJsonRel - Json com as configurações para a gestão de relatórios
@param  nTotal   - Total de registros que serão exportados
@param  lO17     - Indica se o ambiente possui a tabela de gestão de relatórios

@Return  lRet - Boolean que indica se o arquivo de exportação foi gerado
@since 10/01/2022
/*/
//-----------------------------------------------------------------
Function JCExpPubs( cPathArq, aHeader, aDetail, cJsonRel, nTotal, lO17 )
Local oExcel         := FwPrinterXlsx():New()
Local lRet           := .F.
Local nCols          := 1
Local nLinha         := 1
Local nY             := 0
Local nR             := 0
Local nX             := 0
Local nI             := 0
Local aCamps         := {}
Local aDados         := {}
Local xValor         := ""
Local cTipoDado      := ""

	If lO17
		oJsonRel := JsonObject():New()
		oJsonRel:FromJson(cJsonRel)
		oJsonRel["O17_MIN"]  := 0
		oJsonRel["O17_MAX"]  := nTotal
		oJsonRel['O17_DESC'] := STR0048 // "Gravando dados do relatório"
		J288GestRel(oJsonRel)
	Endif

	oExcel:Activate(cPathArq + ".rel")

	If At(".xlsx",cPathArq) == 0
		cPathArq += ".xlsx"
	Endif

	// Inicia a montagem das abas do arquivo
	For nY := 1 To Len(aDetail)
		aCamps := {}
		aDados := {}

		oExcel:AddSheet(aDetail[nY][2])
		nCols  := 1
		nLinha := 1

		// Titulo da planilha
		oExcel:MergeCells(nLinha, nCols, nLinha, Len(aHeader[1]) )
		JurCellFmt(@oExcel, , "TITULO")
		oExcel:SetFont(FwPrinterFont():Arial(), 12, .F., .T., .F.)
		oExcel:setText(nLinha, 1, AllTrim(aDetail[nY][2])) // "Título da aba"
		nLinha++

		For nR := 1 To Len(aHeader[1])
			// Cabeçalho dos campos selecionados
			cNomeCpo   := Alltrim(getSx3Cache(aHeader[1][nR], "X3_TITULO"))
			cTipoDado  := IIF( aHeader[1][nR] == "NR0_ERRO", "M" , getSx3Cache(aHeader[1][nR], "X3_TIPO") )
			oExcel:SetFont(FwPrinterFont():Arial(), 10, .F., .T., .F.)
			oExcel:SetBorder(.T., .T., .T., .T., FwXlsxBorderStyle():Thin(), "000000")
			JurRowSize(@oExcel,nR, nR, cTipoDado, aHeader[1][nR], Len(Alltrim(cNomeCpo)) + 2, .F.)
			JurCellFmt(@oExcel, ,"CABECALHO")
			oExcel:SetValue( nLinha, nCols, cNomeCpo )
			nCols ++
		Next nR

		nCols := 1
		nLinha ++

		// Linhas

		For nX := 1 To Len(aDetail[nY][1])

			If lO17
				oJsonRel['O17_DESC'] := STR0048 // "Gravando dados do relatório"
				oJsonRel['O17_MIN']  := oJsonRel['O17_MIN'] + 1
				oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN'] * 100 / oJsonRel['O17_MAX'], 0)
				J288GestRel(oJsonRel)
			Endif

			// Colunas - Preenche campo a campo
			For nI := 1 To Len(aHeader[1])

				cNomeCpo   :=  Alltrim(getSx3Cache(aHeader[1][nI], "X3_TITULO"))
				cCampo     := aHeader[1][nI]
				cTipoDado  := IIF( aHeader[1][nI] == "NR0_ERRO", "M" , getSx3Cache(aHeader[1][nI], "X3_TIPO") )
				If cTipoDado $ "M | C"
					xValor := SubStr(aDetail[nY][1][nX][nI], 0, 32767) // Limite de caracteres para célula no excel
				Else
					xValor := aDetail[nY][1][nX][nI]
				Endif
				
				aAdd(aCamps, { cNomeCpo, cCampo })
				oExcel:SetBorder(.T., .T., .T., .T., FwXlsxBorderStyle():Thin(), "000000")
				oExcel:SetFont(FwPrinterFont():Arial(), 10, .F., .F., .F.)
				JurCellFmt(@oExcel, cTipoDado)

				If VALTYPE(xValor) <> "U"

					If cTipoDado == "D"
						If !Empty( xValor )
							oExcel:SetDate(nLinha, nI, STOD(xValor) )
						Else
							oExcel:SetValue(nLinha, nI, "-")
						EndIf
					Else
						oExcel:SetValue(nLinha, nI, xValor)
					EndIf

				Else
					oExcel:SetValue(nLinha, nI, "")
				EndIf
				nCols ++
			Next nI

			nLinha ++
		Next nX

	Next nY

	oExcel:toXlsx()

	// Aguarda a geração do arquivo
	nI := 0
	While !File(cPathArq) .And. nI < 10 
		nI++
		Sleep(1000)
	EndDo

	lRet := File(cPathArq)

	// tratamento para apagar .rel
	If lRet
		cPathArq := SUBSTR(cPathArq, 1, LEN(cPathArq) -5)
		cPathArq := cPathArq + ".rel"
		If FILE(cPathArq)
			FERASE(cPathArq)
		EndIf
	EndIf

	If lO17 .AND. !lRet
		oJsonRel['O17_DESC']   := STR0049 // "Não foi possível gerar o relatório."
		oJsonRel['O17_STATUS'] := "1" // Erro
		J288GestRel(oJsonRel)
	EndIf

	oExcel:DeActivate()

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} setaTitAba
Retorna o título da aba de acordo com o status da publicação.
Utilizado no relatório de exportação de Publicações do TOTVS Jurídico.

@param cStatus - Status da publicação
            1 - Localizadas
            2 - Duplicadas
            3 - Não localizadas
            4 - Excluídas
            5 - Importadas
            6 - Prováveis
			7 - Processando
			8 - Erro de importação
@param lError - Indica se a publicação pertence a aba de Erro de importação

@Return  cTitulo - Titulo da aba para o excel
@since 10/01/2022
*/
//-----------------------------------------------------------------
Static Function setaTitAba(cStatus, lError)

Local cTitulo := ""

	Do Case
		Case cStatus == '1'
			cTitulo := IIF( lError, STR0056, STR0061 ) // "Publicações erro de importação" / "Publicações localizadas"
		Case cStatus == '2'
			cTitulo := STR0050 // "Publicações duplicadas"
		Case cStatus == '3'
			cTitulo := STR0051 // "Publicações não localizadas"
		Case cStatus == '4
			cTitulo := STR0052 // "Publicações excluídas"
		Case cStatus == '5'
			cTitulo := STR0053 // "Publicações importadas"
		Case cStatus == '6'
			cTitulo := STR0054 // "Publicações prováveis"
		Case cStatus == '7'
			cTitulo := STR0055 // "Publicações processando"
		Case cStatus == '8'
			cTitulo := STR0056 // "Publicações erro de importação"
	EndCase

Return cTitulo

//-----------------------------------------------------------------
/*/{Protheus.doc} JCExpRel
Responsável por gerar o relatório de publicações e enviar
o download para as notificações

@param cPathArq  - Caminho do arquivo + nome do arquivo
@param  aHeader  - Campos do cabeçalho do excel
@param  aDetail  - Dados das linhas do excel
@param cRequest  - Json com os dados da requisição
@param  cJsonRel - Json com as configurações para a gestão de relatórios
@param  nTotal   - Total de registros que serão exportados
@param  lO17     - Indica se o ambiente possui a tabela de gestão de relatórios

@since 10/01/2022
/*/
//-----------------------------------------------------------------
Function JCExpRel( cPathArq, aHeader, aDetail, cRequest, cJsonRel, nTotal, lO17 )
Local oRequest := JsonObject():New()
Local lRet       := .T.

	oRequest:FromJson(cRequest)
	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(oRequest['cEmpAnt'], oRequest['cFilAnt'], , , 'JURI') // Abre o ambiente

	__CUSERID := oRequest["cUserId"]
		
	If !Empty(cJsonRel)
		oJsonRel := JsonObject():New()
		oJsonRel:FromJson(cJsonRel) 
	Endif

	oRequest['cIdThredExec'] := "JCExpRel" + __CUSERID + StrZero(Randomize(1,9999),4)

	// Trava a execução atual
	If LockByName(oRequest["cIdThredExec"], .T., .T.)
		If lO17
			oJsonRel['O17_DESC'] := STR0048 // "Gravando dados do relatório"
			oJsonRel['O17_BODY'] := oRequest:toJson()
			J288GestRel(oJsonRel)
			cJsonRel := oJsonRel:toJson()
		Endif

		// Geração do relatório
		JCExpPubs( cPathArq, aHeader, aDetail, cJsonRel, nTotal, lO17 )

		lRet := CreatePathDown(oRequest['cPathDown'])

		If lRet .and. File(cPathArq + '.xlsx')

			If __COPYFILE( cPathArq + '.xlsx' , oRequest['cPathDown'] + oRequest["cNomeArq"] )
				// Cria um registro na tabela O12 - do tipo de Download
				JA280Notify(I18n(STR0057,{oRequest["cNomeArq"], DtoC(dDataBase), Time()}),; //'O relatóriode publicações #1 ficou pronto, clique para fazer o download #2 às #3'
							oRequest['cUserId'], "download", '3', "ExportPubs", oRequest['cPathDown'] + oRequest["cNomeArq"])

				If lO17
					// Finaliza o arquivo com sucesso na gestão de download
					oJsonRel['O17_DESC']    := STR0058 // "Arquivo pronto para download"
					oJsonRel['O17_URLDWN']  := oRequest['cPathDown'] + oRequest["cNomeArq"]
					oJsonRel['O17_STATUS']  := "2" // Sucesso
					J288GestRel(oJsonRel)
				Endif
			Else
				lRet := .F.
			Endif
		Else
			lRet := .F.
		Endif

		If !lRet 
			// Cria um registro na tabela O12 - do tipo de notificação
			JA280Notify(I18n(STR0059,{oRequest["cNomeArq"]}) , oRequest['cUserId'],; // Falha na geração do relatório de publicações #1
						"exclamation", '1', "ExportPubs") 
			If lO17
				// Finaliza o arquivo com erro na gestão de download
				oJsonRel['O17_DESC']   := STR0060 // "Falha na geração do relatório"
				oJsonRel['O17_STATUS'] := "1" // Erro
				J288GestRel(oJsonRel)
			Endif
		Endif

		UnLockByName(oRequest["cIdThredExec"], .T., .T.)
	Endif

	RpcClearEnv() // Reseta o ambiente

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAndPro
Obtém a listagem de andamentos do processo
@param codFil = código da filial 
@param cajuri = código do processo 
@param searchKey = termo de busca
@param codEntid = código da instancia
@param pageSize = tamanho da página
@since 17/02/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/getAnd/{codFil}/{cajuri}
/*/
//-------------------------------------------------------------------
WSMETHOD GET GetAndPro  PATHPARAM codFil,cajuri WSRECEIVE searchKey,codEntid,pageSize  WSREST JURCONTENCIOSO
Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cCajuri    := Self:cajuri
Local cFilPro    := Self:codFil
Local nPageSize  := iIF (Empty(Self:pageSize),3,Self:pageSize)
Local cSearchKey := Self:searchKey
Local cInstancia := Self:codEntid  
Local cAlias     := ""
Local cQuery     := ""
Local cDescri    := ""
Local nCount     := 0
Local cTpAssJur  := JurGetDados("NSZ", 1, cFilPro + cCajuri, "NSZ_TIPOAS")
Local lRet       := JVldRestri(cTpAssJur, "'04'", 2)


	If !lRet
		SetRestFault(403, '2' + STR0018) // ": Acesso negado."
	Else 
		
		cQuery := "SELECT DISTINCT "
		cQuery +=  		" NT4_FILIAL, "
		cQuery +=       " NT4_CAJURI, "
		cQuery +=       " NT4_COD, "
		cQuery +=       " NT4_DTANDA, "
		cQuery +=       " NT4_CATO, "
		cQuery +=       " NRO_DESC, "
		cQuery +=       " NT4_CFASE, "
		cQuery +=       " NQG_DESC, "
		cQuery +=       " NUM_CENTID NT4__TEMANX "
		cQuery += " FROM " + RetSqlName('NT4') + " NT4 "
		cQuery += " LEFT JOIN " + RetSqlName("NRO") + " NRO "
		cQuery +=     " ON (NRO.NRO_FILIAL = '"+xFilial("NRO")+"' "
		cQuery +=         " AND NRO.NRO_COD = NT4_CATO "
		cQuery +=         " AND NRO.D_E_L_E_T_ = '' )"
		cQuery += " LEFT JOIN " + RetSqlName("NQG") + " NQG "
		cQuery +=     " ON (NQG.NQG_FILIAL = '"+xFilial("NQG")+"' "
		cQuery +=         " AND NQG.NQG_COD = NT4_CFASE "
		cQuery +=         " AND NQG.D_E_L_E_T_ = ' ')"
		cQuery += " LEFT JOIN " + RetSqlName("NUM") + " NUM "
		cQuery +=     " ON (NUM_CENTID = NT4_COD "
        cQuery +=         " AND NUM_ENTIDA = 'NT4' "
        cQuery +=         " AND NUM.D_E_L_E_T_ = ' ' "
        cQuery +=         " AND NUM_FILENT = NT4_FILIAL )"
		cQuery += " WHERE NT4_FILIAL = '" + cFilPro + "' "
		cQuery +=   " AND   NT4_CAJURI = '" + cCajuri +  "' "
		cQuery +=   " AND NT4.D_E_L_E_T_ = ' ' " 

		If(!Empty(cSearchKey))
			cQuery += " AND NT4_CATO = '" + cSearchKey + "' "
		EndIf	

	    If(!Empty(cInstancia))
			cQuery += " AND NT4_CINSTA = '" + cInstancia + "' "
		EndIf

		cQuery += " ORDER BY NT4_DTANDA DESC" 
		
		cAlias := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		Self:SetContentType("application/json")
		oResponse['andamento'] := {}
		
		While (cAlias)->(!Eof())
			nCount++

			If nPageSize >= nCount
				cDescri := JURGETDADOS('NT4', 1, (cALIAS)->NT4_FILIAL + (cALIAS)->NT4_COD, 'NT4_DESC')

				Aadd(oResponse["andamento"], JsonObject():New())
				oResponse["andamento"][nCount]["codFil"]      := (cAlias)->NT4_FILIAL
				oResponse["andamento"][nCount]["cajuri"]      := (cAlias)->NT4_CAJURI
				oResponse["andamento"][nCount]["NT4_COD"]     := (cAlias)->NT4_COD
				oResponse["andamento"][nCount]["NT4_CATO"]    := JConvUTF8((cAlias)->NT4_CATO)
				oResponse["andamento"][nCount]["NRO_DESC"]    := JConvUTF8((cAlias)->NRO_DESC)
				oResponse["andamento"][nCount]["NT4_CFASE"]   := JConvUTF8((cAlias)->NT4_CFASE)
				oResponse["andamento"][nCount]["NQG_DESC"]    := JConvUTF8((cAlias)->NQG_DESC)
				oResponse["andamento"][nCount]["NT4_DESC"]    := JConvUTF8(cDescri)
				oResponse["andamento"][nCount]["NT4_DTANDA"]  := (cAlias)->NT4_DTANDA
				oResponse["andamento"][nCount]["NT4__TEMANX"] :=  Iif(Empty(AllTrim((cAlias)->NT4__TEMANX)),"00","01")
			EndIf

			(cAlias)->(DbSkip())
		EndDo

		oResponse ["total"] := nCount
		
		(cAlias)->( dbCloseArea() )

		Self:SetResponse(oResponse:toJson())
	
	EndIf
 
	oResponse:fromJson("{}")
	oResponse := NIL
	RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listPedidos
Listagem de pedidos de Processos

@param codFil   - Filial
@param cajuri  - Código do processo (cajuri)
@param pageSize - Quantidade de itens na página

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/listPedidos/ICAgICAgICAwMDAwMDAwMjQ5
/*/
//-------------------------------------------------------------------
WSMETHOD GET listPedidos PATHPARAM pk WSREST JURCONTENCIOSO
Local lRet        := .T.
Local oResponse   := Nil
Local cPK         := Self:pk

Default cPK   := ''

	Self:SetContentType("application/json")
	cPk := Decode64(cPk)
	If JVldRestri(JurGetDados("NSZ",1, cPK, "NSZ_TIPOAS"), "'06'", 2)
		oResponse := getListPedidos(cPK)
		Self:SetResponse(oResponse:toJson())
	Else
		lRet := .F.
		SetRestFault(403, "5"+ STR0018) // 5: Acesso negado
		ConOut(STR0066)  // "Sem permissão para GET em pedidos"
	Endif
	
	oResponse:fromJson("{}")
	oResponse := NIL

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getListPedidos
Retorna os dados dos pedidos do processo

@param cCodFil   - codigo da Filial
@param cTpAssJur - codigo do processo
@param nPageSize - Quantidade de itens na página

@return json contendo a lista de pedidos
/*/
//-------------------------------------------------------------------
Static Function getListPedidos(cPK)
Local oResponse := JsonObject():New()
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local nQtd      := 0
Local cCodArea  := JurGetDados("NSZ",1, cPK, "NSZ_CAREAJ")

	oResponse["pedidos"]               := {}
	oResponse["length"]                := 0
	oResponse["totalProvavel"]         := 0
	oResponse["totalProvavelAtu"]      := 0
	oResponse["totalvalorRedutor"]     := 0
	oResponse["totalPossivel"]         := 0
	oResponse["totalPossivelAtu"]      := 0
	oResponse["totalRemoto"]           := 0
	oResponse["totalRemotoAtu"]        := 0
	oResponse["totalIncontroverso"]    := 0
	oResponse["totalIncontroversoAtu"] := 0

	cQuery += "SELECT "
	cQuery +=     "O0W_COD, "
	cQuery +=     "NSP_DESC O0W_DTPPED, "
	cQuery +=     "O0W_DATPED, "
	cQuery +=     "O0W_VPROVA, "
	cQuery +=     "O0W_VATPRO, "
	cQuery +=     "O0W_PROGNO, "
	cQuery +=     "O0W_VPEDID, "
	cQuery +=     "O0W_VATPED, "
	cQuery +=     "O0W_CODWF , "
	cQuery +=     "O0W_VLREDU, "
	cQuery +=     "O0W_VPOSSI, "
	cQuery +=     "O0W_VREMOT, "
	cQuery +=     "O0W_VINCON, "
	cQuery +=     "O0W_VATPOS, "
	cQuery +=     "O0W_VATREM, "
	cQuery +=     "O0W_VATINC "
	cQuery += "FROM "+RetSqlName('O0W')+" O0W "
	cQuery +=     "INNER JOIN "+RetSqlName('NSP')+" NSP ON "
	cQuery +=         "NSP.NSP_FILIAL = '"+xFilial('NSP')+"' "
	cQuery +=         "AND NSP.NSP_COD = O0W.O0W_CTPPED "
	cQuery +=         "AND NSP.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE  "
	cQuery +=     "O0W.O0W_FILIAL||O0W.O0W_CAJURI = '"+cPK+"' "
	cQuery +=     "AND O0W.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While (cAlias)->(!EoF())
			nQtd++
			aAdd(oResponse["pedidos"],JsonObject():New())
			aTail(oResponse["pedidos"])["codPedido"]      := (cAlias)->O0W_COD
			aTail(oResponse["pedidos"])["indice"]         := nQtd
			aTail(oResponse["pedidos"])["pedido"]         := JConvUTF8((cAlias)->O0W_DTPPED)
			aTail(oResponse["pedidos"])["dtValor"]        := (cAlias)->O0W_DATPED
			aTail(oResponse["pedidos"])["vlrProvisao"]    := (cAlias)->O0W_VPROVA
			aTail(oResponse["pedidos"])["vlrProvisaoAtu"] := (cAlias)->O0W_VATPRO
			aTail(oResponse["pedidos"])["prognostico"]    := JConvUTF8((cAlias)->O0W_PROGNO)
			aTail(oResponse["pedidos"])["vlrPedido"]      := (cAlias)->O0W_VPEDID
			aTail(oResponse["pedidos"])["vlrAtuPed"]      := (cAlias)->O0W_VATPED
			aTail(oResponse["pedidos"])["codWf"]          := (cAlias)->O0W_CODWF
			aTail(oResponse["pedidos"])["valorRedutor"]   := (cAlias)->O0W_VLREDU
			aTail(oResponse["pedidos"])["urlWf"]          := J270UrlWF( (cAlias)->O0W_CODWF)
			aTail(oResponse["pedidos"])["editarPedido"]   := {'pedido', 'history'}

			oResponse["totalProvavel"]         += (cAlias)->O0W_VPROVA
			oResponse["totalProvavelAtu"]      += (cAlias)->O0W_VATPRO
			oResponse["totalvalorRedutor"]     += (cAlias)->O0W_VLREDU
			oResponse["totalPossivel"]         += (cAlias)->O0W_VPOSSI
			oResponse["totalPossivelAtu"]      += (cAlias)->O0W_VATPOS
			oResponse["totalRemoto"]           += (cAlias)->O0W_VREMOT
			oResponse["totalRemotoAtu"]        += (cAlias)->O0W_VATREM
			oResponse["totalIncontroverso"]    += (cAlias)->O0W_VINCON
			oResponse["totalIncontroversoAtu"] += (cAlias)->O0W_VATINC

			(cAlias)->(DbSkip())
		End
		
		oResponse["length"]       := nQtd
		oResponse["areaJuridica"] := JConvUTF8(Posicione('NRB',1,xFilial('NRB')+cCodArea,'NRB_DESC'))
		
	(cAlias)->(DbCloseArea())

Return oResponse


//-------------------------------------------------------------------
/*/{Protheus.doc} GET SugLev 
Sugere valores para levantamento

@param codEntid - Código da garantia
@param dtFinal  - Data do levantamento
@param valor    - Valor do levantamento
@param total    - Levantamento total ou parcial

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURCONTENCIOSO/suglev/{codEntid}/{dtFinal}/{valor}/{total}
/*/
//-------------------------------------------------------------------
WSMETHOD GET SugLev PATHPARAM codEntid, dtFinal, valor, total WSRECEIVE pk WSREST JURCONTENCIOSO
Local aArea      := GetArea()
Local aValores   := {0,0}
Local cAlias     := GetNextAlias()
Local cCodGar    := self:codEntid
Local cdtFinal   := self:dtFinal
Local cDtInicial := ""
Local cDtAux     := ""
Local cFCorrGar  := ""
Local cSql       := ""
Local lTotal     := self:total
Local nCorrecao  := 0
Local nJuros     := 0
Local nPrincipal := 0
Local nSaldo     := self:valor
Local nValInfo   := self:valor
Local oResponse  := JsonObject():New()
Local cCodLev    := self:pk

	If ValType(cCodLev) == 'U'
		cCodLev := '0'
	EndIf

	// Busca garantia e levantamentos
	cSql := "SELECT NT2_MOVFIN, "
	cSql +=        "NT2_CCOMON, "
	cSql +=        "NT2_DATA, "
	cSql +=        "NT2_VALOR, "
	cSql +=        "NT2_VCPROV, "
	cSql +=        "NT2_VJPROV "
	cSql +=  "FROM " + RetSqlName("NT2")
	cSql += "WHERE D_E_L_E_T_ = ' ' "
	cSql +=   "AND NT2_FILIAL = '" + xFilial("NT2") + "' "
	cSql +=   "AND NT2_COD != '" + cCodLev + "' "
	cSql +=   "AND ( ( NT2_MOVFIN = '2' AND NT2_CGARAN = '" + cCodGar + "') OR "
	cSql +=         "( NT2_MOVFIN = '1' AND NT2_COD = '" + cCodGar + "' ) ) "
	cSql += "ORDER BY NT2_MOVFIN, NT2_DATA "
	cSql := ChangeQuery(cSql)
	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cSql), cAlias, .F., .F. )
		While (cAlias)->(!Eof())
			If (cAlias)->NT2_MOVFIN == '1'
				// Pega os valores da garantia
				nPrincipal := (cAlias)->NT2_VALOR
				nSaldo     := (cAlias)->NT2_VALOR
				nCorrecao  := 0
				nJuros     := 0
				cFCorrGar  := (cAlias)->NT2_CCOMON
				cDtInicial := (cAlias)->NT2_DATA
				cDtAux     := cDtInicial

			Else
				nPrincipal := nPrincipal - (cAlias)->NT2_VALOR
				// Atualiza a garantia até o levantamento
				aValores   := {0,0}
				JA002Valor(cFCorrGar, nSaldo, cDtAux, (cAlias)->NT2_DATA, cDtAux, , , , , , , @aValores, .T.)
				nCorrecao := nCorrecao + aValores[1]
				nJuros    := nJuros + aValores[2]
				nSaldo    := nSaldo + aValores[1] + aValores[2]

				// Subtrai os valores do levantamento
				nCorrecao := nCorrecao - (cAlias)->NT2_VCPROV
				nJuros    := nJuros - (cAlias)->NT2_VJPROV
				nSaldo    := nSaldo - (cAlias)->NT2_VALOR - (cAlias)->NT2_VCPROV - (cAlias)->NT2_VJPROV

				// Seta a nova data inicial
				cDtAux := (cAlias)->NT2_DATA
			EndIf

			(cAlias)->(DbSkip())
		EndDo

	(cAlias)->( dbCloseArea() )

	Self:SetContentType("application/json")
	oResponse["sugere"] := cdtFinal >= cDtAux

	// Calcula o saldo disponível
	aValores   := {0,0}
	JA002Valor(cFCorrGar, nSaldo, cDtAux, cdtFinal, cDtAux, , , , , , , @aValores, .T.)
	nCorrecao := round(nCorrecao + aValores[1], 2)
	nJuros :=  round(nJuros + aValores[2], 2)

	oResponse["valorDisponvel"] := JsonObject():New()
		oResponse["valorDisponvel"]["vlrPrincipal"] := nPrincipal
		oResponse["valorDisponvel"]["vlrCorrecao"] := nCorrecao
		oResponse["valorDisponvel"]["vlrJuros"] := nJuros

	// Calcula o valor sugerido
	If !lTotal
		// Calcula o Levantamento parcial
		aValores   := {0,0}
		JA002Valor(cFCorrGar, nValInfo, cDtInicial, cdtFinal, cDtInicial, , , , , , , @aValores, .T.)
		nCorrecao := iIf(aValores[1] > nCorrecao, nCorrecao, aValores[1])
		nJuros := iIf(aValores[2] > nJuros, nJuros, aValores[2])
	EndIf

	oResponse["valorSugerido"] := JsonObject():New()
		oResponse["valorSugerido"]["vlrCorrecao"] := Round(nCorrecao, 2)
		oResponse["valorSugerido"]["vlrJuros"] := Round(nJuros, 2)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
	JA002Valor(cFCorrGar, 0, cDtAux, cdtFinal, cDtAux, , , , , , , @aValores, .T.)
	aSize(aValores,0)
	aValores := Nil
	RestArea(aArea)

Return .T.
