#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSLEGALPROCESS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLegalProcess
Métodos WS do Jurídico para integração com o LegalProcess.

@author SIGAJURI
@since 11/03/17
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL JURLEGALPROCESS DESCRIPTION STR0001 //"WS de Integração com LegalProcess"

	WSDATA page          AS INTEGER
	WSDATA pageSize      AS INTEGER
	WSDATA codProc       AS STRING
	WSDATA searchKey     AS STRING
	WSDATA searhKeyRet   AS STRING
	WSDATA qryorder      AS STRING
	WSDATA tpFilter      AS STRING
	WSDATA saldoNT2      AS STRING
	WSDATA nomeEnt       AS STRING
	WSDATA codEntidade   AS STRING
	WSDATA codDoc        AS STRING
	WSDATA qtdCarac      AS INTEGER // Quantidade de caracteres que serão exibidos no campo NT4_DESC
	WSDATA codTabela     AS STRING
	WSDATA chaveTab      AS STRING
	WSDATA codParam      AS STRING
	WSDATA url           AS STRING
	WSDATA campof3       AS STRING
	WSDATA codComarca    AS STRING
	WSDATA codForo	     AS STRING
	WSDATA codDistr      AS STRING
	WSDATA tipoDistr     AS STRING
	WSDATA codFil        AS STRING
	WSDATA dataIni       AS STRING
	WSDATA dataFinal     AS STRING
	WSDATA campo         AS STRING
	WSDATA codWf         AS STRING
	WSDATA tipoAssjur    AS STRING
	WSDATA nomeFunc      AS STRING
	WSDATA buscaInfo     AS STRING
	WSDATA pathArq       AS STRING
	WSDATA usuario       AS ARRAY
	WSDATA correcao      AS STRING
	WSDATA filialProcOri AS STRING
	WSDATA tabela        AS STRING
	WSDATA isNew         AS BOOLEAN
	WSDATA codModelo     AS STRING
	WSDATA tpAsJ         AS STRING
	WSDATA relaciona     AS STRING
	WSDATA cajuriIN      AS STRING
	WSDATA lTLegal       AS STRING
	WSDATA lTotal        AS BOOLEAN
	WSDATA listFiliais   AS STRING
	WSDATA subPasta      AS STRING
	WSDATA gtAnexos      AS BOOLEAN

	// Métodos GET
	WSMETHOD GET    ListProcess     DESCRIPTION STR0002  PATH "process"                                    PRODUCES APPLICATION_JSON //"Listagem de Processos"
	WSMETHOD GET    DetailProcess   DESCRIPTION STR0003  PATH "process/{codProc}"                          PRODUCES APPLICATION_JSON //"Detalhe do Processo"
	WSMETHOD GET    ListAreas       DESCRIPTION STR0004  PATH "area"                                       PRODUCES APPLICATION_JSON //"Listagem de áreas"
	WSMETHOD GET    ListFup         DESCRIPTION STR0013  PATH "process/{codProc}/fups"                     PRODUCES APPLICATION_JSON //"Listagem de Followups"
	WSMETHOD GET    StockEvolution  DESCRIPTION STR0013  PATH "evolution"                                  PRODUCES APPLICATION_JSON //"Evolução do Estoque de ações"
	WSMETHOD GET    SearchProcess   DESCRIPTION STR0019  PATH "searchProcess"                              PRODUCES APPLICATION_JSON //"Pesquida rápida de Processos"
	WSMETHOD GET    ListAndamentos  DESCRIPTION STR0019  PATH "process/{codProc}/andamentos"               PRODUCES APPLICATION_JSON //"Listagem de Andamentos"
	WSMETHOD GET    ListDoc         DESCRIPTION STR0020  PATH "process/{codFil}/{codProc}/docs/{nomeEnt}"  PRODUCES APPLICATION_JSON //"Lista docs"
	WSMETHOD GET    attachments     DESCRIPTION STR0020  PATH "process/docs/{nomeEnt}"                     PRODUCES APPLICATION_JSON //"Lista docs"
	WSMETHOD GET    DownloadFile    DESCRIPTION STR0021  PATH "downloadFile"                               PRODUCES APPLICATION_JSON //"Download de arquivos"
	WSMETHOD GET    DetalheProcesso DESCRIPTION STR0003  PATH "tlprocess/detail/{codFil}/{codProc}"        PRODUCES APPLICATION_JSON //"Informações Resumidas do Processo"       PRODUCES APPLICATION_JSON //"Pesquida rápida de Processos"
	WSMETHOD GET    GrpAprovNT2     DESCRIPTION STR0026  PATH "tlprocess/grupoAprv"                        PRODUCES APPLICATION_JSON //"Busca o grupo de Aprovação da Garantia"
	WSMETHOD GET    TabGenerica     DESCRIPTION STR0027  PATH "tlprocess/tabGen/{codTabela}"               PRODUCES APPLICATION_JSON //"Busca nas tabelas genéricas (SX5)"
	WSMETHOD GET    SysParam        DESCRIPTION STR0028  PATH "tlprocess/sysParam/{codParam}"              PRODUCES APPLICATION_JSON //"Consulta de Parâmetros do sistema"
	WSMETHOD GET    Favorite        DESCRIPTION STR0029  PATH "favorite"                                   PRODUCES APPLICATION_JSON //"Busca os processos favoritos"
	WSMETHOD GET    ListFields      DESCRIPTION STR0031  PATH "fields"                                     PRODUCES APPLICATION_JSON //"Listagem de Campos para Pesquisa Avançada"
	WSMETHOD GET    GetListF3       DESCRIPTION STR0032  PATH "f3list/{campof3}"                           PRODUCES APPLICATION_JSON //"Listagem de Ítens para campo tabelado - F3"
	WSMETHOD GET    SrchForo        DESCRIPTION STR0034  PATH "comarca/{codComarca}/foros"                 PRODUCES APPLICATION_JSON //"Busca todas as varas de um Foro"
	WSMETHOD GET    LtFuncionarios  DESCRIPTION STR0036  PATH "funcionarios"                               PRODUCES APPLICATION_JSON //"Listagem de Funcionários"
	WSMETHOD GET    DtRecebidas     DESCRIPTION STR0037  PATH "distr/list/{tipoDistr}"                     PRODUCES APPLICATION_JSON //"Distribuições / Recebidas"
	WSMETHOD GET    J219Distr       DESCRIPTION STR0038  PATH "distr/cod/{codDistr}"                       PRODUCES APPLICATION_JSON //"Informações de uma distribuição"
	WSMETHOD GET    SrchVara        DESCRIPTION STR0035  PATH "comarca/{codComarca}/foros/{codForo}/varas" PRODUCES APPLICATION_JSON //"Busca todas as varas de um Foro"
	WSMETHOD GET    EmpresaLogada   DESCRIPTION STR0044  PATH "empresaLogada"                              PRODUCES APPLICATION_JSON //"Busca a Empresa Logada"
	WSMETHOD GET    FilUserList     DESCRIPTION STR0045  PATH "listFiliaisUser"                            PRODUCES APPLICATION_JSON // " Busca a lista de filiais que o usuário tem acesso"
	WSMETHOD GET    TpAssuntoJur    DESCRIPTION STR0046  PATH "listTpAssuntoJur"                           PRODUCES APPLICATION_JSON // "Busca assuntos juridicos que contenha instância, vinculados ao usuario "
	WSMETHOD GET    Historico       DESCRIPTION STR0047  PATH "process/{codProc}/historico"                PRODUCES APPLICATION_JSON // "Histórico de Alterações"
	WSMETHOD GET    StatusSolic     DESCRIPTION STR0049  PATH "solicitation/{codWf}"                       PRODUCES APPLICATION_JSON // "Busca o status da solicitação no Fluig"
	WSMETHOD GET    ExportPDF       DESCRIPTION STR0050  PATH "exportpdf/{codProc}"                        PRODUCES APPLICATION_JSON // "Exporta resumo do processo em PDF"
	WSMETHOD GET    ListFavorite    DESCRIPTION STR0029  PATH "listFavorite"                               PRODUCES APPLICATION_JSON // "Lista os favoritos do processo."
	WSMETHOD GET    getSequencial   DESCRIPTION STR0053  PATH "getSequencial"                              PRODUCES APPLICATION_JSON // "Busca o proximo sequencial disponivel na tabela SA1"
	WSMETHOD GET    SeqNXY          DESCRIPTION STR0054  PATH "getSeqNXY/{codProc}"                        PRODUCES APPLICATION_JSON // "Busca o proximo sequencial disponivel na tabela NXY"
	WSMETHOD GET    getRotinas      DESCRIPTION STR0063  PATH "getRotinas"                                 PRODUCES APPLICATION_JSON // "Busca as rotinas disponives na configuração de exportação Personalizada"
	WSMETHOD GET    getCamposExp    DESCRIPTION STR0064  PATH "getCamposExp/{tabela}"                      PRODUCES APPLICATION_JSON // "Busca os campos disponives na configuração de exportação Personalizada de acordo com a rotina"
	WSMETHOD GET    PesquisaRapida  DESCRIPTION STR0079  PATH "pesquisaRapida"                             PRODUCES APPLICATION_JSON // "Pesquida rápida de Processos para Home totvs legal"
	WSMETHOD GET    provision       DESCRIPTION STR0081  PATH "provision"                                  PRODUCES APPLICATION_JSON // "Busca os dados de provisão para a home e pagina de provisão de processos"
	WSMETHOD GET    anexosFlu       DESCRIPTION STR0083  PATH "anexosFlu/{codFil}/{codProc}"               PRODUCES APPLICATION_JSON // "Busca os dados da pasta de anexos do fluig"
	WSMETHOD GET    ExpJurr100      DESCRIPTION STR0084  PATH "exportJurr100/{codProc}"                    PRODUCES APPLICATION_JSON // "Exporta os andamentos de um processo""

	// Métodos POST
	WSMETHOD POST   Favorite        DESCRIPTION STR0030  PATH "favorite"       PRODUCES APPLICATION_JSON //"Inclui/ exclui os processos da tabela de favoritos"
	WSMETHOD POST   UploadFile      DESCRIPTION STR0025  PATH "anexo"          PRODUCES APPLICATION_JSON //"Upload de arquivos"
	WSMETHOD POST   leInicial       DESCRIPTION STR0039  PATH "inicial"        PRODUCES APPLICATION_JSON //"Leitura de Iniciais"
	WSMETHOD POST   SetFilter       DESCRIPTION STR0025  PATH "setfilter"      PRODUCES APPLICATION_JSON // Executa a pesquisa avançada de processos
	WSMETHOD POST   RltPesq         DESCRIPTION STR0040  PATH "exportPesquisa" PRODUCES APPLICATION_JSON //"Realiza a exportação da Pesquisa Avançada"
	WSMETHOD POST   VldCNJ          DESCRIPTION STR0048  PATH "validNumPro"    PRODUCES APPLICATION_JSON //"Valida o número CNJ e busca comarca, foro e vara no cadastro De/Para de comarcas"
	WSMETHOD POST   distribuicoes   DESCRIPTION STR0058  PATH "distribuicoes"  PRODUCES APPLICATION_JSON //"Realiza a importação em lote de distribuições"
	WSMETHOD POST   ModExpUpd       DESCRIPTION STR0065  PATH "updtModExp"     PRODUCES APPLICATION_JSON //"Realiza alterações em modelos de Exportação"


	// Métodos PUT
	WSMETHOD PUT    UpdateDistr     DESCRIPTION STR0041  PATH "distr/cod/{codDistr}/proc/{codProc}" PRODUCES APPLICATION_JSON //"Atualização da distribuição"

	// Métodos DELETE
	WSMETHOD DELETE DeleteDoc       DESCRIPTION STR0022  PATH "process/{codFil}/{codProc}/docs/{codDoc}" PRODUCES APPLICATION_JSON //"Deleta anexos"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} _JURFWREST

@author SIGAJURI
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------

Function _JURLEGALP
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} JGetNqnDes(nCodNqn)
Retorna a descrição do status do tipo de resultado

@param nCodNqn - Código da NQN

@Return cDesNqn - Descritivo da Nqn

@author Willian Kazahaya
@since 08/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetNqnDes(nCodNqn)
	Local cDesNqn := ""
	//1=Pendente;2=Concluído;3=Cancelado;4=Em Aprovação;5=Em aprovação
	Do Case
	Case nCodNqn == "1"
		cDesNqn := STR0014
	Case nCodNqn == "2"
		cDesNqn := STR0015
	Case nCodNqn == "3"
		cDesNqn := STR0016
	Case nCodNqn == "4"
		cDesNqn := STR0017
	Case nCodNqn == "5"
		cDesNqn := STR0018
	End Case

Return cDesNqn

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetInsDes(nInsta)
Retorna a descrição da Instância

@param nInsta - Numero da Instância

@Return cDesInsta - Descrição da instância

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetInsDes(nInsta)
	Local cDesInsta := ""

	// 1=1ª Instância;2=2ª Instância;3=Tribunal Superior
	Do Case
	Case nInsta == "1"
		cDesInsta := STR0010
	Case nInsta == "2"
		cDesInsta := STR0011
	Case nInsta == "3"
		cDesInsta := STR0012
	End Case
Return cDesInsta

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
Function JConvUTF8(cValue)
	Local cReturn := ""
	cReturn := EncodeUTF8(Alltrim(cValue))
Return cReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListProcess
Listagem de Processos

@author Willian Yoshiaki Kazahaya
@since 17/10/17
@version 1.0

@param nPage      - Numero da página
@param nPageSize  - Quantidade de itens na página
@param cSearchKey - Código do processo (cajuri)
@param cQryOrder  - Order by da query ("1 - Ordena decrescente por Vlr. Provisão , 2 - Ordena decrescente por Dt. Ult. Andamento)
@param tpFilter   - Filtra a query (1 = Processos em Andamento, 2 = Casos Novos, 3 = Encerrados)
@param cTpAssJur  - Qual é o tipo de assunto jurídico que deseja filtrar?
@param lTLegal    - Indica se é Totvs Legal
@param lWidgetProv - Indica se a chamada da função é para widget de provisão da home do TOTVS Jurídico
@param lTotal      - Indica se a chamada da função é para buscar qtd para widgets de acompanhamento

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/process

/*/
//-------------------------------------------------------------------
WSMETHOD GET ListProcess WSRECEIVE page, pageSize, searchKey, qryOrder, tpFilter, tipoAssjur, lTLegal, lTotal WSREST JURLEGALPROCESS
Local oResponse   := Nil
Local nPage       := Self:page
Local nPageSize   := Self:pageSize
Local cSearchKey  := Self:searchKey
Local cQryOrder   := Self:qryOrder
Local cFilter     := Self:tpFilter
Local cTpAssJur   := Self:tipoAssjur
Local cTLegal     := Self:lTLegal
Local lTotal      := Self:lTotal

	Self:SetContentType("application/json")

	oResponse := JWsLpGtNsz(,nPage,nPageSize,cSearchKey,cQryOrder,cFilter,, cTpAssJur, cTLegal, lTotal)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DetailProcess
Detalhe do Processo

@author Willian Yoshiaki Kazahaya
@since 17/10/17
@version 1.0

@param codProc  - Código do processo
@param saldoNT2 - Indica o saldo que deseja mostrar de garantias (1= Garantia)
@param lTLegal  - Indica se é totvs legal

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/{codProc}

/*/
//-------------------------------------------------------------------
WSMETHOD GET DetailProcess PATHPARAM codProc WSRECEIVE saldoNT2, lTLegal WSREST JURLEGALPROCESS
Local oResponse := Nil
Local cCodPro   := Self:codProc
Local cSaldoNt2 := Self:saldoNT2
Local cTLegal   := Self:lTLegal

	Self:SetContentType("application/json")

	oResponse := JWsLpGtNsz(cCodPro,,,,,,cSaldoNT2,, cTLegal)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListArea
Listagem de Area Jurídica

@author Willian Yoshiaki Kazahaya
@since 17/10/17
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/area

/*/
//-------------------------------------------------------------------
	WSMETHOD GET ListAreas WSREST JURLEGALPROCESS
	Local oResponse := Nil

	Self:SetContentType("application/json")

	oResponse := JWsLpArea()

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListFup
Listagem de Follow-ups

@author Marcelo Araujo Dente
@since 16/11/17
@version 1.0

@param page - Numero da página
@param pageSize - Quantidade de itens na página

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/{codProc}/fups

/*/
//-------------------------------------------------------------------
	WSMETHOD GET ListFup PATHPARAM codProc WSREST JURLEGALPROCESS
	Local oResponse := JSonObject():New()
	Local cCodPro   := Self:codProc

	Self:SetContentType("application/json")
	oResponse['fup'] := {}
	oResponse['fup'] := JWsListFup(cCodPro,,,.F.)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListAndamentos
Listagem de Andamentos

@since 23/07/19

@param cCodPro - Código do Processo
@param nPage - Numero da página
@param nPageSize - Quantidade de itens na página
@param nQtdCarac - Quantidade de caracteres exibidos no campo NT4_DESC

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/{codProc}/andamentos
/*/
//-------------------------------------------------------------------
	WSMETHOD GET ListAndamentos PATHPARAM codProc WSRECEIVE page, pageSize, qtdCarac, searchKey WSREST JURLEGALPROCESS
	Local oResponse  := JSonObject():New()
	Local cCodPro    := Self:codProc
	Local nPage      := Self:page
	Local nPageSize  := Self:pageSize
	Local nQtdCarac  := Self:qtdCarac
	Local cSearchKey := Self:searchKey

	Self:SetContentType("application/json")
	oResponse['history'] := {}
	oResponse['history'] := JWsListAnd(cCodPro,nPage,nPageSize,nQtdCarac,cSearchKey)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET SearchProcess
Pesquisa rápida de processos

@since 15/07/2019 palavra a ser pesquisada no Nome do Envolvido
					(NT9_NOME) e Número do Processo (NUQ_NUMPRO)

@param cSearchKey -

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/searchProcess
/*/
//-------------------------------------------------------------------
	WSMETHOD GET SearchProcess WSRECEIVE searchKey, pageSize, filialProcOri, tpAsJ, relaciona, codProc, codFil, cajuriIN WSREST JURLEGALPROCESS
	Local oResponse  := Nil
	Local cSearchKey := Self:searchKey
	Local nPageSize  := Self:pageSize
	Local filProOri  := Self:filialProcOri
	Local cTpAsJ     := Self:tpAsJ
	Local cRelaciona := Self:relaciona
	Local cCajuriOri := Self:codProc
	Local cFilialOri := Self:codFil

	Self:SetContentType("application/json")
	oResponse := JWSPsqRNSZ(cSearchKey,nPageSize, filProOri, cTpAsJ, cRelaciona, cCajuriOri, cFilialOri, Self:cajuriIN)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET StockEvolution
Traz o total de casos Em andamento e a movimentação (Novos e Encerrados) mês a mês

@param tipoAssJur: Tipo de assunto jurídico

@since 26/06/2019
@version 1.0

@example GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/evolution
/*/
//-------------------------------------------------------------------
WSMETHOD GET StockEvolution WSRECEIVE tipoAssjur WSREST JURLEGALPROCESS
Local oResponse := Nil
Local cTpAssJur := Self:tipoAssjur
Local cTpAsCfg  := J293CfgQry('1')

	Self:SetContentType("application/json")
	oResponse := GetStkEvo(cTpAssJur, cTpAsCfg)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DetalheProcesso
Busca as informações do processo de forma resumida.
Utilizado na tela resumo do processo TOTVS Legal

@since 24/07/2019

@param page - Numero da página
@param pageSize - Quantidade de itens na página
@param saldoNT2 - Indica o saldo que deseja mostrar de garantias (1= Garantia)

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/{codProc}
/*/
//-------------------------------------------------------------------
WSMETHOD GET DetalheProcesso PATHPARAM codFil, codProc WSRECEIVE saldoNT2,gtAnexos WSREST JURLEGALPROCESS
Local oResponse := Nil
Local cCodFil   := Self:codFil
Local cCodPro   := Self:codProc
Local cSaldoNt2 := Self:saldoNT2
Local lgtAnexos := Self:gtAnexos

	Self:SetContentType("application/json")

	oResponse := JWsLpGtPro(cCodPro,,,,,,cSaldoNT2,cCodFil,lgtAnexos)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNsz
Listagem de Processos

@author Willian Yoshiaki Kazahaya
@since 17/10/17
@version 1.0

@param cCodProc    - Código do processo a ser pesquisado
@param nPage       - Numero da página
@param nPageSize   - Quantidade de itens na página
@param cSearchKey  - Código do processo (cajuri)
@param cQryOrder   - Order by da query ("1 - Ordena decrescente por Vlr. Provisão , 2 - Ordena decrescente por Dt. Ult. Andamento)
@param cFilter     - Filtra a query (1 = Processos em Andamento, 2 = Casos Novos, 3 = Encerrados)
@param cSaldoNT2   - Busca o saldo da garantia (1 - garantia)
@param cTpAssJur   - Qual é o tipo de assunto jurídico que deseja filtrar?
@param cTLegal     - Indica se é totvs legal
@param lTotal      - Indica se a chamada da função é para buscar qtd para widgets de acompanhamento
/*/
//-------------------------------------------------------------------
Function JWsLpGtNsz(cCodProc, nPage, nPageSize, cSearchKey, cQryOrder, cFilter, cSaldoNT2, cTpAssJur, cTLegal, lTotal)
Local cQrySelect   := ""
Local cQryFrom     := ""
Local cQryWhere    := ""
Local cQuery       := ""
Local cCajuri      := ""
Local cInstan      := ""
Local nCount       := 0
Local oResponse    := JsonObject():New()
Local lHasNext     := .F.
Local aSQLRest     := Ja162RstUs(,,,.T.)
Local cAlias       := GetNextAlias()
Local nIndexJSon   := 0
Local aNuq         := {}
Local aNt9         := {}
Local aNsy         := {}
Local aNt3         := {}
Local aNt2         := {}
Local aNszEnc      := {}
Local aNT4Dec      := {}
Local aNT4Inj      := {}
Local cNszSituac   := ""
Local cNuqInstan   := ""
Local cExists      := ""
Local cWhere       := ""
Local cDtIni       := DTOS(FirstDate( Date() ))
Local cFiltAnd     := " AND NSZ.NSZ_SITUAC = '1' "
Local cFiltNew     := " AND NSZ.NSZ_DTINCL >= '" + cDtIni + "' "
Local cFiltEnc     := " AND NSZ.NSZ_DTENCE >= '" + cDtIni + "' AND NSZ.NSZ_SITUAC = '2'"
Local cQryCfgTL    := ""
Local cNSZName     := Alltrim(RetSqlName("NSZ"))
Local aFilUsr      := JURFILUSR( __CUSERID, "NSZ" )
Local cAssJurGrp   := ""
Local cCfgTLegal   := ""
Local cQryFilter   := ""

Default cCodProc    := ""
Default nPage       := 1
Default nPageSize   := 10
Default cSearchKey  := ""
Default cTpAssJur   := ""
Default cQryOrder   := "0"
Default cFilter     := "0"
Default cSaldoNT2   := "0"
Default cTLegal     := ''
Default lTotal      := .F.

	cQrySelect :=  " SELECT NSZ.NSZ_FILIAL NSZ_FILIAL "
	cQrySelect +=       " ,NSZ.NSZ_COD    NSZ_COD "
	cQrySelect +=       " ,NSZ.NSZ_CCLIEN NSZ_CCLIEN "
	cQrySelect +=       " ,NSZ.NSZ_LCLIEN NSZ_LCLIEN "
	cQrySelect +=       " ,SA1.A1_NOME    SA1_NOME "
	cQrySelect +=       " ,NSZ.NSZ_NUMCAS NSZ_NUMCAS "
	cQrySelect +=       " ,NVE.NVE_TITULO NVE_TITULO "
	cQrySelect +=       " ,NSZ.NSZ_TIPOAS NSZ_TIPOAS "
	cQrySelect +=       " ,NYB.NYB_DESC   NYB_DESC "
	cQrySelect +=       " ,NSZ.NSZ_DTENTR NSZ_DTENTR "
	cQrySelect +=       " ,NSZ.NSZ_VLPROV VPROV "
	cQrySelect +=       " ,NSZ.NSZ_SITUAC NSZ_SITUAC "
	cQrySelect +=       " ,NYB.NYB_CORIG  NYB_CORIG "

	if (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=       " ,TO_CHAR(SUBSTR(NSZ.NSZ_DETALH,1,4000))  NSZ_DETALH "
		cQrySelect +=       " ,TO_CHAR(SUBSTR(NSZ.NSZ_OBSERV,1,4000))  NSZ_OBSERV "
	Else
		cQrySelect +=       " ,CAST(NSZ.NSZ_DETALH AS VARCHAR(4000))  NSZ_DETALH "
		cQrySelect +=       " ,CAST(NSZ.NSZ_OBSERV AS VARCHAR(4000))  NSZ_OBSERV "
	Endif

	cQrySelect +=       " ,NSZ.NSZ_CSTATL NSZ_CSTATL "
	cQrySelect +=       " ,NSZ.NSZ_DTINLI NSZ_DTINLI "
	cQrySelect +=       " ,NSZ.NSZ_DTFILI NSZ_DTFILI "

	if (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=       " ,TO_CHAR(SUBSTR(NSZ.NSZ_OBSLIV,1,4000)) NSZ_OBSLIV "
		cQrySelect +=       " ,TO_CHAR(SUBSTR(NSZ.NSZ_OBSLIR,1,4000)) NSZ_OBSLIR "
	Else
		cQrySelect +=       " ,CAST(NSZ.NSZ_OBSLIV AS VARCHAR(4000)) NSZ_OBSLIV "
		cQrySelect +=       " ,CAST(NSZ.NSZ_OBSLIR AS VARCHAR(4000)) NSZ_OBSLIR "
	Endif

	cQrySelect +=       " ,RD01.RD0_NOME  RD0_NOMERESP  "
	cQrySelect +=       " ,RD01.RD0_SIGLA RD0_SIGLARESP "
	cQrySelect +=       " ,RD02.RD0_NOME  RD0_NOMEADVO  "
	cQrySelect +=       " ,RD02.RD0_SIGLA RD0_SIGLAADVO "
	cQrySelect +=       " ,RD03.RD0_NOME  RD0_NOMEESTA  "
	cQrySelect +=       " ,RD03.RD0_SIGLA RD0_SIGLAESTA "
	cQrySelect +=       " ,NSZ.NSZ_CAREAJ NSZ_CAREAJ "
	cQrySelect +=       " ,NRB.NRB_DESC   NRB_DESC "
	cQrySelect +=       " ,NSZ.NSZ_CSUBAR NSZ_CSUBAR "
	cQrySelect +=       " ,NRL.NRL_DESC   NRL_DESC "
	cQrySelect +=       " ,NUQ.NUQ_NUMPRO NUMPRO"
	cQrySelect +=       " ,NSZ.NSZ_VAPROV NSZ_VAPROV"
	cQrySelect +=       " ,NQ4.NQ4_DESC NQ4_DESC"
	cQrySelect +=       " ,SA2.A2_NOME SA2_CORRESP"
	cQrySelect +=       " ,NSZ.NSZ_SJUIZA NSZ_SJUIZA"
	cQrySelect +=       " ,NSZ.NSZ_VAENVO NSZ_VAENVO"

	//-- Valores
	cQrySelect +=       " ,(CASE WHEN NSZ.NSZ_VAPROV = 0 "
	cQrySelect +=                " THEN NSZ.NSZ_VLPROV "
	cQrySelect +=                " ELSE NSZ.NSZ_VAPROV END "
	cQrySelect +=        "  ) VALOR "

	cQryFrom   := " FROM " + cNSZName + " NSZ "
	cQryFrom   +=  " INNER JOIN " + RetSqlName('SA1') + " SA1  ON (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=                                          " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=                                          " AND " + JQryFilial("NSZ","SA1","NSZ","SA1")
	cQryFrom   +=                                          " AND (SA1.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NVE') + " NVE  ON (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
	cQryFrom   +=                                          " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=                                          " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=                                          " AND (NVE.NVE_FILIAL = '" + xFilial("NVE") + "') "
	cQryFrom   +=                                          " AND (NVE.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NYB') + " NYB  ON (NYB.NYB_COD = NSZ.NSZ_TIPOAS) "
	cQryFrom   +=                                          " AND (NYB.NYB_FILIAL = '" + xFilial("NYB") + "') "
	cQryFrom   +=                                          " AND (NYB.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NYB') + " NYB2 ON (NYB2.NYB_COD = NYB.NYB_CORIG) "
	cQryFrom   +=                                          " AND (NYB2.NYB_FILIAL = '" + xFilial("NYB") + "') "
	cQryFrom   +=                                          " AND (NYB2.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('RD0') + " RD01 ON (RD01.RD0_CODIGO = NSZ.NSZ_CPART1) "
	cQryFrom   +=                                          " AND (RD01.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom   +=                                          " AND (RD01.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('RD0') + " RD02 ON (RD02.RD0_CODIGO = NSZ.NSZ_CPART2) "
	cQryFrom   +=                                          " AND (RD02.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom   +=                                          " AND (RD02.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('RD0') + " RD03 ON (RD03.RD0_CODIGO = NSZ.NSZ_CPART3) "
	cQryFrom   +=                                          " AND (RD03.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom   +=                                          " AND (RD03.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NRB') + " NRB  ON (NRB.NRB_COD = NSZ.NSZ_CAREAJ) "
	cQryFrom   +=                                          " AND (NRB.NRB_FILIAL = '" + xFilial("NRB") + "') "
	cQryFrom   +=                                          " AND (NRB.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NRL') + " NRL  ON (NRL.NRL_COD = NSZ.NSZ_CSUBAR) "
	cQryFrom   +=                                          " AND (NRL.NRL_CAREA = NRB.NRB_COD) "
	cQryFrom   +=                                          " AND (NRL.NRL_FILIAL = '" + xFilial("NRL") + "') "
	cQryFrom   +=                                          " AND (NRL.D_E_L_E_T_ = ' ') "
	cQryFrom   +=  " INNER JOIN "+ RetSqlName('NUQ') + " NUQ  ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrom   +=                                          " AND NUQ.NUQ_INSATU  = '1' "
	cQryFrom   +=                                          " AND NUQ.NUQ_FILIAL  = NSZ.NSZ_FILIAL "
	cQryFrom   +=                                          " AND NUQ.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('SA2') + " SA2  ON (SA2.A2_COD = NUQ.NUQ_CCORRE "
	cQryFrom   +=                                          " AND SA2.A2_LOJA = NUQ.NUQ_LCORRE "
	cQryFrom   +=                                          " AND SA2.A2_FILIAL  = '" + xFilial("SA2") + "' "
	cQryFrom   +=                                          " AND SA2.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NQ4') + " NQ4  ON (NQ4.NQ4_COD = NSZ.NSZ_COBJET "
	cQryFrom   +=                                          " AND NQ4.NQ4_FILIAL  = NSZ.NSZ_FILIAL "
	cQryFrom   +=                                          " AND NQ4.D_E_L_E_T_ = ' ' ) "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQryWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cQryWhere  +=     " AND NSZ.D_E_L_E_T_ = ' ' "

	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cWhere    :=  " AND " + JurFormat("NT9_NOME", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " AND (" + SUBSTR(JurGtExist(RetSqlName("NT9"), cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists

		cWhere    :=  " AND " + JurFormat("NUQ_NUMPRO", .F.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NUQ"), cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists

		cWhere    :=  " AND " + JurFormat("NSZ_DETALH", .T.,.T.) + " Like '%" + cSearchKey + "%')"
		cExists   :=  " OR " + SUBSTR(JurGtExist(cNSZName, cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
	EndIf

	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest)+") "
	EndIf

	If !Empty(cCodProc)
		cQryWhere += " AND NSZ.NSZ_COD = '" + cCodProc + "'"
	EndIf

	// Define o Filtro aplicado na query
	If cFilter == "1" // Processos em Andamento
		cQryFilter := cFiltAnd
	ElseIf cFilter == "2" // Processos Cadastrados no mês corrente
		cQryFilter := cFiltNew
	ElseIf cFilter == "3" // Processos Encerrados no mês corrente
		cQryFilter := cFiltEnc
	EndIf

	//Filtro de assuntos juridico do grupo de usuário
	cAssJurGrp := JurTpAsJr(__CUSERID)
	cQryWhere += " AND NSZ.NSZ_TIPOAS IN (" + cAssJurGrp + ") " // Permissões do grupo do usuário

	// -- Preferencias de usuário
	If !Empty(cTpAssJur)
		cQryWhere += " AND NSZ.NSZ_TIPOAS IN " + FormatIn(cTpAssJur, ",") 
	Endif

	cQryWhere  += VerRestricao(,, cAssJurGrp)

	// Valida a configuração global de assuntos da Home totvs legal
	cCfgTLegal := J293CfgQry('1', cTLegal)
	If cTLegal == "true" .AND. !Empty(cCfgTLegal)
		cQryCfgTL := " UNION ALL "
		cQryCfgTL += cQrySelect
		cQryCfgTL += StrTran(cQryFrom," INNER JOIN "+ RetSqlName('NUQ')," LEFT JOIN "+ RetSqlName('NUQ') ) 
		cQryCfgTL += cQryWhere
		cQryCfgTL += " AND NSZ.NSZ_TIPOAS IN " + FormatIn(cCfgTLegal, ",")
	EndIf
	
	//Define a ordenação da query
	If  cQryOrder == "1"
		cQryOrder := " ORDER BY VALOR DESC"
	Else
		cQryOrder := " ORDER BY NSZ.NSZ_COD "
	EndIf

	cQuery := cQrySelect + cQryFrom + cQryWhere + cQryFilter 

	If !Empty(cCfgTLegal)
		cQuery += cQryCfgTL+cQryFilter
	Endif
	cQuery += cQryOrder
	
	cQuery := ChangeQuery(cQuery)
	
	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['processes'] := {}

	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	If !Empty(cCodProc)
		oResponse['operation'] := "DetailProcess"
	Else
		oResponse['operation'] := "ListProcess"
	EndIf

	oResponse['userName'] := cUserName

	While (cAlias)->(!Eof()) .AND. nIndexJSon <= nPageSize .AND. !lTotal

		nQtdReg++
		// Verifica se o registro está no range da pagina
		if (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndexJSon++

			// Assunto Juridico
			cCajuri := (cAlias)->NSZ_COD

			Aadd(oResponse['processes'], JsonObject():New())
			oResponse['processes'][nIndexJSon]['processBranch']      := (cAlias)->NSZ_FILIAL
			oResponse['processes'][nIndexJSon]['processId']          := cCajuri
			oResponse['processes'][nIndexJSon]['assJur']             := JConvUTF8((cAlias)->NSZ_TIPOAS)
			oResponse['processes'][nIndexJSon]['assJurDesc']         := JConvUTF8((cAlias)->NYB_DESC)
			oResponse['processes'][nIndexJSon]['entryDate']          := JConvUTF8((cAlias)->NSZ_DTENTR)
			oResponse['processes'][nIndexJSon]['provisionValue']     := ROUND((cAlias)->VPROV,2)
			oResponse['processes'][nIndexJSon]['atualizedprovision'] := ROUND((cAlias)->VALOR,2)
			oResponse['processes'][nIndexJSon]['balanceInCourt']     := ROUND((cAlias)->NSZ_SJUIZA,2) 
			oResponse['processes'][nIndexJSon]['atualizedinvolved']  := ROUND((cAlias)->NSZ_VAENVO,2)
			oResponse['processes'][nIndexJSon]['subject']            := JConvUTF8((cAlias)->NQ4_DESC)
			oResponse['processes'][nIndexJSon]['office']             := JConvUTF8((cAlias)->SA2_CORRESP)

			If cSaldoNT2 == "1"//valor do saldo das garantias
				oResponse['processes'][nIndexJSon]['balanceguarantees'] := ROUND(JUR98G('1',cCodProc),2)
			EndIf

			// Area
			oResponse['processes'][nIndexJSon]['area'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['area'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['area'])['code']        := JConvUTF8((cAlias)->NSZ_CAREAJ)
			aTail(oResponse['processes'][nIndexJSon]['area'])['description'] := JConvUTF8((cAlias)->NRB_DESC)

			// Subarea
			oResponse['processes'][nIndexJSon]['subarea'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['subarea'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['subarea'])['code']        := JConvUTF8((cAlias)->NSZ_CSUBAR)
			aTail(oResponse['processes'][nIndexJSon]['subarea'])['description'] := JConvUTF8((cAlias)->NRL_DESC)

			// Caso
			oResponse['processes'][nIndexJSon]['matter'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['matter'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['matter'])['code']        := JConvUTF8((cAlias)->NSZ_NUMCAS)
			aTail(oResponse['processes'][nIndexJSon]['matter'])['description'] := JConvUTF8((cAlias)->NVE_TITULO)

			// Cliente
			oResponse['processes'][nIndexJSon]['company'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['company'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['company'])['code'] := JConvUTF8((cAlias)->NSZ_CCLIEN) + '-' + JConvUTF8((cAlias)->NSZ_LCLIEN)
			aTail(oResponse['processes'][nIndexJSon]['company'])['name'] := JConvUTF8((cAlias)->SA1_NOME)

			// Status do Processo
			cNszSituac := JConvUTF8((cAlias)->NSZ_SITUAC)
			oResponse['processes'][nIndexJSon]['status'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['status'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['status'])['code'] := cNszSituac

			If (cNszSituac == '1')
				aTail(oResponse['processes'][nIndexJSon]['status'])['description'] := JConvUTF8(STR0005) // Em andamento
			Else
				aTail(oResponse['processes'][nIndexJSon]['status'])['description'] := JConvUTF8(STR0006) // Encerrado
			EndIf

			// Participantes do Processo
			// Responsável
			oResponse['processes'][nIndexJSon]['staff'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['staff'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['staff'])['position'] := JConvUTF8(STR0007)  // Responsável
			aTail(oResponse['processes'][nIndexJSon]['staff'])['name']     := JConvUTF8((cAlias)->RD0_NOMERESP)
			aTail(oResponse['processes'][nIndexJSon]['staff'])['initials'] := JConvUTF8((cAlias)->RD0_SIGLARESP)

			// Advogado
			Aadd(oResponse['processes'][nIndexJSon]['staff'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['staff'])['position'] := JConvUTF8(STR0008)  // Advogado
			aTail(oResponse['processes'][nIndexJSon]['staff'])['name']     := JConvUTF8((cAlias)->RD0_NOMEADVO)
			aTail(oResponse['processes'][nIndexJSon]['staff'])['initials'] := JConvUTF8((cAlias)->RD0_SIGLAADVO)

			// Estagiário
			Aadd(oResponse['processes'][nIndexJSon]['staff'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['staff'])['position'] := JConvUTF8(STR0009) // Estagiário
			aTail(oResponse['processes'][nIndexJSon]['staff'])['name']     := JConvUTF8((cAlias)->RD0_NOMEESTA)
			aTail(oResponse['processes'][nIndexJSon]['staff'])['initials'] := JConvUTF8((cAlias)->RD0_SIGLAESTA)

			// Envolvidos - Parte contraria
			oResponse['processes'][nIndexJSon]['oppositeParty'] := getPartCont(cCajuri)

			// Para o ListProcess
			If Empty(cCodProc)
				// Instância
				aNuq := JWsLpGtNuq(cCajuri,.T.) // Somente a instância atual

				oResponse['processes'][nIndexJSon]['instance'] := {}

				if !Empty(aNuq)
					nCount := 0

					For nCount := 1 to Len(aNuq)
						Aadd(oResponse['processes'][nIndexJSon]['instance'], JsonObject():New())
						cInstan    := JConvUTF8(aNuq[nCount][1])
						cNuqInstan := JConvUTF8(aNuq[nCount][3])

						aTail(oResponse['processes'][nIndexJSon]['instance'])['id']             := cInstan
						aTail(oResponse['processes'][nIndexJSon]['instance'])['instaAtual']     := JConvUTF8(aNuq[nCount][2])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['numInstance']    := JConvUTF8(aNuq[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['displayName']    := JGetInsDes(cNuqInstan)
						aTail(oResponse['processes'][nIndexJSon]['instance'])['processNumber']  := JConvUTF8(aNuq[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['natureCode']     := JConvUTF8(aNuq[nCount][5])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['nature']         := JConvUTF8(aNuq[nCount][6])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['cityCode']       := JConvUTF8(aNuq[nCount][7])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['city']           := JConvUTF8(aNuq[nCount][8])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['distribution']   := JConvUTF8(aNuq[nCount][9])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['local']          := JConvUTF8(aNuq[nCount][10])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['districtCourt']  := JConvUTF8(aNuq[nCount][11])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['branch']         := JConvUTF8(aNuq[nCount][12])
					Next
				EndIf

				// Para o DetailProcess
			Else
				// Follow-up
				oResponse['processes'][nIndexJSon]['fup'] := {}
				oResponse['processes'][nIndexJSon]['fup'] :=  JWsListFup(cCajuri,oResponse,nIndexJSon)

				// Instância
				aNuq := JWsLpGtNuq(cCajuri,.F.) // Todas as instâncias

				oResponse['processes'][nIndexJSon]['instance'] := {}

				if !Empty(aNuq)
					nCount := 0

					For nCount := 1 to Len(aNuq)
						Aadd(oResponse['processes'][nIndexJSon]['instance'], JsonObject():New())
						cInstan    := JConvUTF8(aNuq[nCount][1])
						cNuqInstan := JConvUTF8(aNuq[nCount][3])

						aTail(oResponse['processes'][nIndexJSon]['instance'])['id']             := cInstan
						aTail(oResponse['processes'][nIndexJSon]['instance'])['instaAtual']     := JConvUTF8(aNuq[nCount][2])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['numInstance']    := JConvUTF8(aNuq[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['displayName']    := JGetInsDes(cNuqInstan)
						aTail(oResponse['processes'][nIndexJSon]['instance'])['processNumber']  := JConvUTF8(aNuq[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['natureCode']     := JConvUTF8(aNuq[nCount][5])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['nature']         := JConvUTF8(aNuq[nCount][6])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['cityCode']       := JConvUTF8(aNuq[nCount][7])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['city']           := JConvUTF8(aNuq[nCount][8])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['distribution']   := JConvUTF8(aNuq[nCount][9])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['local']          := JConvUTF8(aNuq[nCount][10])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['districtCourt']  := JConvUTF8(aNuq[nCount][11])
						aTail(oResponse['processes'][nIndexJSon]['instance'])['branch']         := JConvUTF8(aNuq[nCount][12])

					Next
				EndIf

				// Envolvidos
				aNt9 := JWsLpGtNt9(cCajuri,0)
				oResponse['processes'][nIndexJSon]['party'] := {}

				If !Empty(aNt9)
					nCount := 0
					For nCount := 1 to Len(aNt9)
						Aadd(oResponse['processes'][nIndexJSon]['party'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['party'])['id']           := JConvUTF8(aNt9[nCount][1])
						aTail(oResponse['processes'][nIndexJSon]['party'])['entity']       := JConvUTF8(aNt9[nCount][2])
						aTail(oResponse['processes'][nIndexJSon]['party'])['sourceEntity'] := JConvUTF8(aNt9[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['party'])['main']         := JConvUTF8(aNt9[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['party'])['name']         := JConvUTF8(aNt9[nCount][5])
						aTail(oResponse['processes'][nIndexJSon]['party'])['code']         := JConvUTF8(aNt9[nCount][6])
						aTail(oResponse['processes'][nIndexJSon]['party'])['relationCode'] := JConvUTF8(aNt9[nCount][7])
						aTail(oResponse['processes'][nIndexJSon]['party'])['relationName'] := JConvUTF8(aNt9[nCount][8])
						aTail(oResponse['processes'][nIndexJSon]['party'])['positionCode'] := JConvUTF8(aNt9[nCount][9])
						aTail(oResponse['processes'][nIndexJSon]['party'])['position']     := JConvUTF8(aNt9[nCount][10])
					Next
				EndIf

				// Objetos
				aNsy := JWsLpGtNsy(cCajuri)
				oResponse['processes'][nIndexJSon]['values_and_contingency'] := {}

				If !Empty(aNsy)
					For nCount := 1 to Len(aNsy)
						Aadd(oResponse['processes'][nIndexJSon]['values_and_contingency'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['probability_of_winning']       := aNsy[nCount][6]
						aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['description']                  := JConvUTF8(aNsy[nCount][3])

						aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['values'] := {}
						Aadd(aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['values'], JsonObject():New())

						aTail(aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['values'])['description'] := JConvUTF8(aNsy[nCount][5])
						aTail(aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['values'])['value']       := aNsy[nCount][7]
						aTail(aTail(oResponse['processes'][nIndexJSon]['values_and_contingency'])['values'])['currency']    := JConvUTF8(aNsy[nCount][10])
					Next
				EndIf

				// Andamento - Decisão
				aNT4Dec := JWsLpGtNt4(cCajuri, 1)
				oResponse['processes'][nIndexJSon]['decisions'] := {}
				If !Empty(aNT4Dec)
					For nCount := 1 to Len(aNT4Dec)
						Aadd(oResponse['processes'][nIndexJSon]['decisions'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['decisions'])['id']       := JConvUTF8(aNT4Dec[nCount][1])
						aTail(oResponse['processes'][nIndexJSon]['decisions'])['title']    := JConvUTF8(aNT4Dec[nCount][2])
						aTail(oResponse['processes'][nIndexJSon]['decisions'])['date']     := JConvUTF8(aNT4Dec[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['decisions'])['sentence'] := JConvUTF8(aNT4Dec[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['decisions'])['instance'] := JConvUTF8(aNT4Dec[nCount][5])
					Next
				EndIf

				// Andamento - Liminar
				aNT4Inj := JWsLpGtNt4(cCajuri, 2)
				oResponse['processes'][nIndexJSon]['injuctions'] := {}
				If !Empty(aNT4Inj)
					For nCount := 1 to Len(aNT4Inj)
						Aadd(oResponse['processes'][nIndexJSon]['injuctions'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['injuctions'])['id']       := JConvUTF8(aNT4Inj[nCount][1])
						aTail(oResponse['processes'][nIndexJSon]['injuctions'])['title']    := JConvUTF8(aNT4Inj[nCount][2])
						aTail(oResponse['processes'][nIndexJSon]['injuctions'])['date']     := JConvUTF8(aNT4Inj[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['injuctions'])['sentence'] := JConvUTF8(aNT4Inj[nCount][4])
					Next
				EndIf

				// Andamento
				oResponse['processes'][nIndexJSon]['history'] := {}
				oResponse['processes'][nIndexJSon]['history'] := JWsListAnd(cCajuri,nPage,nPageSize,,cSearchKey)

				// Garantia
				aNt2 := JWsLpGtNt2(cCajuri)
				oResponse['processes'][nIndexJSon]['guarantees'] := {}
				If !Empty(aNt2)
					For nCount := 1 to Len(aNt2)
						Aadd(oResponse['processes'][nIndexJSon]['guarantees'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['guarantees'])['identifier']  := JConvUTF8(aNt2[nCount][2])
						aTail(oResponse['processes'][nIndexJSon]['guarantees'])['description'] := JConvUTF8(aNt2[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['guarantees'])['date']        := JConvUTF8(aNt2[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['guarantees'])['value']       := aNt2[nCount][5]
					Next
				EndIf

				// Despesas
				aNt3 := JWsLpGtNt3(cCajuri)
				oResponse['processes'][nIndexJSon]['expenses'] := {}
				If !Empty(aNt3)
					For nCount := 1 to Len(aNt3)
						Aadd(oResponse['processes'][nIndexJSon]['expenses'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['expenses'])['identifier']  := JConvUTF8(aNt3[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['expenses'])['description'] := JConvUTF8(aNt3[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['expenses'])['date']        := JConvUTF8(aNt3[nCount][5])
						aTail(oResponse['processes'][nIndexJSon]['expenses'])['value']       := aNt3[nCount][6]
					Next
				EndIf

				// Encerramento
				aNszEnc := JWsLpGtEnc(cCajuri)
				oResponse['processes'][nIndexJSon]['closure'] := {}
				If !Empty(aNszEnc)
					For nCount := 1 to Len(aNszEnc)
						Aadd(oResponse['processes'][nIndexJSon]['closure'], JsonObject():New())
						aTail(oResponse['processes'][nIndexJSon]['closure'])['type']        := JConvUTF8(aNszEnc[nCount][3])
						aTail(oResponse['processes'][nIndexJSon]['closure'])['description'] := JConvUTF8(aNszEnc[nCount][4])
						aTail(oResponse['processes'][nIndexJSon]['closure'])['date']        := JConvUTF8(aNszEnc[nCount][5])
						aTail(oResponse['processes'][nIndexJSon]['closure'])['finalValue']  := aNszEnc[nCount][6]
						aTail(oResponse['processes'][nIndexJSon]['closure'])['veredict']    := JConvUTF8(aNszEnc[nCount][7])
					Next
				EndIf
			EndIF
		Elseif (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
			lTotal   := .T.
		Endif

		(cAlias)->(DbSkip())

	End
	(cAlias)->( DbCloseArea() )

	// Verifica se há uma proxima pagina
	If (lHasNext)
		oResponse['hasNext'] := "true"
	Else
		oResponse['hasNext'] := "false"
	EndIf

	oResponse['qtdAndamento']  := WSLPQtdReg(cQryFrom + cQryWhere + cFiltAnd)
	oResponse['qtdNovos']      := WSLPQtdReg(cQryFrom + cQryWhere + cFiltNew)
	oResponse['qtdEncerrados'] := WSLPQtdReg(cQryFrom + cQryWhere + cFiltEnc)
	if !Empty(cQryCfgTL)
		cQryCfgTL := SUBSTR(cQryCfgTL,At(" FROM " + cNSZName + " NSZ ",cQryCfgTL))
		oResponse['qtdAndamento']  += WSLPQtdReg(cQryCfgTL + cFiltAnd )
		oResponse['qtdNovos']      += WSLPQtdReg(cQryCfgTL + cFiltNew )
		oResponse['qtdEncerrados'] += WSLPQtdReg(cQryCfgTL + cFiltEnc )
	Endif

	aSize(aFilUsr, 0)
	aSize(aNT9, 0)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET anexosFlu
Busca os dados de Anexo do Fluig

@param codFil  - Código da Filial
@param codProc - Código do Processo

@since 24/07/2019
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/anexosFlu/{codFil}/{codProc}
/*/
//-------------------------------------------------------------------
WSMETHOD GET anexosFlu PATHPARAM codFil, codProc  WSREST JURLEGALPROCESS
Local cCodfil   := Self:codFil
Local cCajuri   := Self:codProc
Local cQuery    := ""
Local nIndexJSon:= 0
Local oResponse := JsonObject():New()
Local cAlias    := GetNextAlias()

	cQuery := " SELECT NSZ.NSZ_CCLIEN, "
	cQuery +=        " NSZ.NSZ_LCLIEN, "
	cQuery +=        " NSZ.NSZ_NUMCAS, "
	cQuery +=        " NZ7.NZ7_LINK "
	cQuery += " FROM " + RetSqlName("NSZ") + " NSZ "
	cQuery +=        " LEFT JOIN " + RetSqlName("NZ7") + " NZ7 "
	cQuery +=               " ON ( NZ7.NZ7_CCLIEN = NSZ.NSZ_CCLIEN "
	cQuery +=                " AND NZ7.NZ7_LCLIEN = NSZ.NSZ_LCLIEN "
	cQuery +=                " AND NZ7.NZ7_NUMCAS = NSZ.NSZ_NUMCAS "
	cQuery +=                " AND NZ7.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NSZ.NSZ_COD = '"  + cCajuri +  "' "
	cQuery +=   " AND NSZ.NSZ_FILIAL = '"  + cCodfil +  "' "
	cQuery +=   " AND NSZ.D_E_L_E_T_ = ' ' "

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While (cAlias)->(!Eof())
		nIndexJSon++

		oResponse['folderFluig'] := JPrcAnxFlg((cAlias)->NSZ_CCLIEN, ;
											(cAlias)->NSZ_LCLIEN, ;
											(cAlias)->NSZ_NUMCAS, ;
											(cAlias)->NZ7_LINK, ;
											cCajuri)
		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->( DbCloseArea() )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JPrcAnxFlg(cCodClien, cLojClien, cNumCaso, cLink, cCajuri)
Busca os dados da Pasta do Fluig. Caso não tenha, irá criar a pasta

@param cCodClien - Código do Cliente
@param cLojClien - Loja do Cliente
@param cNumCaso  - Numero do Caso
@param cLink     - Link da Pasta no Fluig
@param cCajuri   - Código do Assunto Jurídico

@since 22/07/2022
/*/
//-------------------------------------------------------------------
Function JPrcAnxFlg(cCodClien, cLojClien, cNumCaso, cLink, cCajuri)
Local oResponse   := JsonObject():New()
Local cLinkNZ7    := ''
Local cCriaPasta  := ''

	If (AllTrim(SuperGetMv('MV_JDOCUME',,'1'))) == '3' // Se usa Fluig
		If !Empty(cLink) // Verifica se há conteúdo no campo NZ7_LINK obtido na query
			cLinkNZ7 := AllTrim(cLink)
		Else
			cCriaPasta := J070PFluig( cCodClien + cLojClien + cNumCaso, "") // Realiza a criação da pasta no Fluig

			If cCriaPasta == "2"
				cLinkNZ7 := AllTrim(JurGetDados("NZ7", 1, xFilial("NZ7") + cCodClien + cLojClien + cNumCaso, "NZ7_LINK"))
			Endif
		Endif

		If !Empty(cLinkNZ7)
			oAnexo := WSgetAnexo("NSZ", cCajuri)
			oResponse['link']    := SubStr(cLinkNZ7,1,at(";",cLinkNZ7)-1  )
			oResponse['version'] := SubStr(cLinkNZ7  ,at(";",cLinkNZ7)+1,4)
			oResponse['url']     := oAnexo:Abrir(.F.,cLinkNZ7)
		EndIf
	EndIf

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNta(cFollowup)
Retorna um array com os Follow-ups do Assunto Jurídico

@param cCajuri - Cajuri para consulta
@param lMax - Irá retornar somente o Ultimo Follow-up com base na Data/Hora

@Return	aFollowup Array de Follow-ups

@author Willian Yoshiaki Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNta(cCajuri, lMax)
	Local aFollowup := {}
	Local cSQL    := ''
	Local cSqlSelect, cSqlFrom, cSqlWhere
	Local aArea   := GetArea()
	Local cAlias  := GetNextAlias()
	Local cSqlMax := ""

	Default lMax := .T.

	cSqlSelect := " SELECT NTA.NTA_COD    NTA_COD "
	cSqlSelect += 		 ",NTA.NTA_DTFLWP NTA_DTFLWP "
	cSqlSelect += 		 ",NTA.NTA_HORA   NTA_HORA "
	cSqlSelect += 		 ",NTA.NTA_CRESUL NTA_CRESUL "
	cSqlSelect += 		 ",NQS.NQS_DESC   NQS_DESC "
	cSqlSelect += 		 ",NQN.NQN_TIPO   NQN_TIPO "

	cSqlFrom := " FROM " + RetSqlName("NTA") + " NTA INNER JOIN " + RetSqlName("NQN") + " NQN ON (NQN.NQN_COD = NTA.NTA_CRESUL) "
	cSqlFrom +=                 					                 	     " AND (NQN.NQN_FILIAL = '" + xFilial("NQN") + "') "
	cSqlFrom +=                 					                 	     " AND (NQN.D_E_L_E_T_ = ' ') "
	cSqlFrom +=                 " INNER JOIN " + RetSqlName("NTE") + " NTE ON (NTE.NTE_CFLWP = NTA.NTA_COD) "
	cSqlFrom +=                 					                 	     " AND (NTE.NTE_CAJURI = NTA.NTA_CAJURI) "
	cSqlFrom +=                 					                 	     " AND (NTE.NTE_FILIAL = '" + xFilial("NTE") + "') "
	cSqlFrom +=                 					                 	     " AND (NTE.D_E_L_E_T_ = ' ') "
	cSqlFrom +=                 " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_CODIGO = NTE.NTE_CPART) "
	cSqlFrom +=                 					                 	     " AND (RD0.RD0_FILIAL = '" + xFilial("RD0") + "')"
	cSqlFrom +=                 					                 	     " AND (RD0.D_E_L_E_T_ = ' ') "
	cSqlFrom +=                 " INNER JOIN " + RetSqlName("NQS") + " NQS ON (NQS.NQS_COD = NTA.NTA_CTIPO) "
	cSqlFrom +=                 					                 	     " AND (NQS.NQS_FILIAL = '" + xFilial("NQS") + "')"
	cSqlFrom +=                 					                 	     " AND (NQS.D_E_L_E_T_ = ' ') "

	cSqlWhere := " WHERE NTA.NTA_FILIAL = '" + xFilial("NTA") + "'"
	cSqlWhere +=   " AND NTA.NTA_CAJURI = '" + cCajuri + "'"

	If lMax
		cSqlMax := " SELECT MAX(R_E_C_N_O_) R_E_C_N_O_ "
		cSqlMax += " FROM " + RetSqlName("NTA") + " NTA2 "
		cSqlMax += " WHERE NTA2.NTA_CAJURI = '" + cCajuri +"'"
		cSqlMax +=   " AND NTA2.NTA_FILIAL = '" + xFilial("NTA") + "'"

		cSqlWhere += " AND NTA.R_E_C_N_O_ = (" + cSqlMax + ")"
	EndIf

	cSql := cSqlSelect + cSqlFrom + cSqlWhere

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSql ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd( aFollowup, { (cAlias)->NTA_COD, (cAlias)->NTA_DTFLWP, (cAlias)->NTA_HORA, (cAlias)->NTA_CRESUL, (cAlias)->NQS_DESC, (cAlias)->NQN_TIPO} )
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aFollowup


//-------------------------------------------------------------------
/*/{Protheus.doc} getPar(cFollowup)
Retorna um array com os participantes responsáveis pelo Fup

@param cFollowup

@Return	aSigla  array de participantes responsáveis pelo FUP.

@author Beatriz Gomes
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNte(cFollowup)
	Local aSigla := {}
	Local cSQL   := ''
	Local aArea  := GetArea()
	Local cAlias := GetNextAlias()

	cSQL  := "SELECT RD0.RD0_CODIGO RD0_COD "
	cSQL  +=      " ,RD0.RD0_SIGLA  RD0_SIGLA "
	cSQL  +=      " ,RD0.RD0_NOME   RD0_NOME "
	cSQL  +=      " ,RD0.RD0_EMAIL  RD0_EMAIL "
	cSQL  +=      " ,RD0.RD0_FONE   RD0_FONE "
	cSQL  += " FROM "+ RetSqlname('NTE') +" NTE INNER JOIN " + RetSqlname('RD0') + " RD0 ON (NTE.NTE_CPART = RD0.RD0_CODIGO) "
	cSQL  +=                 					                 	         	            " AND (RD0.D_E_L_E_T_ = ' ') "
	cSQL  += " WHERE NTE.D_E_L_E_T_ = ' ' "
	cSQL  +=   " AND NTE.NTE_FILIAL = '" + xFilial('NTA') + "' "
	cSQL  +=   " AND NTE.NTE_CFLWP  = '" + cFollowup + "' "
	cSQL  +=   " AND RD0.RD0_FILIAL = '" + xFilial('RD0') + "' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	While !(cAlias)->( EOF() )
		aAdd( aSigla, { (cAlias)->RD0_COD,(cAlias)->RD0_SIGLA,(cAlias)->RD0_NOME, (cAlias)->RD0_EMAIL,(cAlias)->RD0_FONE} )
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)
Return aSigla


//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNyb()
Retorna a lista de Nyb

@Return cListNyb - Lista dos tipos de assunto juridicos concatenados

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNyb()
	Local cListNyb := ""
	Local cSql     := ""
	Local aArea    := GetArea()
	Local cAliasNyb:= GetNextAlias()

	cSql := "SELECT NYB_COD FROM " + RetSqlname("NYB") + " WHERE D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNyb, .T., .F.)

	While !(cAliasNyb)->(Eof())
		cListNyb += "'" + AllTrim((cAliasNyb)->NYB_COD) + "',"
		(cAliasNyb)->( dbSkip() )
	End

	If !Empty(cListNyb)
		cListNyb := Left(cListNyb,Len(cListNyb)-1)
	EndIf

	(cAliasNyb)->( DbCloseArea() )
	RestArea(aArea)
Return cListNyb

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNuq(cCajuri, lOrigem)
Retorna a lista de Nuq

@param cCajuri - Código do assunto jurídico

@Return cListNuq - Lista da instância do assunto juridico

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNuq(cCajuri, lOrigem)
	Local aNuq      := {}
	Local cSql      := ""
	Local aArea     := GetArea()
	Local cAliasNuq := GetNextAlias()
	Default lOrigem := .F.

	cSQL  := " SELECT NUQ.NUQ_COD    NUQ_COD "
	cSQL  +=        ",NUQ.NUQ_INSATU NUQ_INSATU "
	cSQL  +=        ",NUQ.NUQ_INSTAN NUQ_INSTAN "
	cSQL  +=        ",NUQ.NUQ_NUMPRO NUQ_NUMPRO "
	cSQL  +=        ",NUQ.NUQ_CNATUR NUQ_CNATUR "
	cSQL  +=        ",NQ1.NQ1_DESC   NQ1_DESC "
	cSQL  +=        ",NUQ.NUQ_CMUNIC NUQ_CMUNIC "
	cSQL  +=        ",CC2.CC2_MUN    CC2_MUN "
	cSQL  +=        ",NUQ.NUQ_DTDIST NUQ_DTDIST "
	cSQL  +=        ",NQ6.NQ6_DESC   NQ6_DESC "
	cSQL  +=        ",NQC.NQC_DESC   NQC_DESC "
	cSQL  +=        ",NQE.NQE_DESC   NQE_DESC "
	cSQL  +=        ",NUQ.NUQ_CDECIS NUQ_CDECIS "
	cSQL  +=        ",NQQ.NQQ_DESC   NQQ_DESC "
	cSQL  +=        ",NUQ.NUQ_DTDECI NUQ_DTDECI "

	cSQL  += "FROM "+ RetSqlname('NUQ') +" NUQ INNER JOIN "+ RetSqlname('NQ1') +" NQ1 ON (NQ1.NQ1_COD    = NUQ.NUQ_CNATUR) AND (NQ1.NQ1_FILIAL = '" + xFilial("NQ1") + "') "
	cSQL  +=                                                                       " AND (NQ1.D_E_L_E_T_ = ' ' ) "
	cSQL  +=                                  "LEFT  JOIN "+ RetSqlname('CC2') +" CC2 ON (CC2.CC2_CODMUN = NUQ.NUQ_CMUNIC) AND (CC2.CC2_FILIAL = '" + xFilial("CC2") + "') "
	cSQL  +=                                                                       " AND (CC2.D_E_L_E_T_ = ' ' ) "
	cSQL  +=                                  "LEFT  JOIN "+ RetSqlname('NQ6') +" NQ6 ON (NQ6.NQ6_COD    = NUQ.NUQ_CCOMAR) AND (NQ6.NQ6_FILIAL = '" + xFilial("NQ6") + "') "
	cSQL  +=                                                                       " AND (NQ6.D_E_L_E_T_ = ' ' ) "
	cSQL  +=                                  "LEFT  JOIN "+ RetSqlname('NQC') +" NQC ON (NQC.NQC_COD    = NUQ.NUQ_CLOC2N) AND (NQC.NQC_CCOMAR = NQ6.NQ6_COD) AND (NQC.NQC_FILIAL = '" + xFilial("NQC") + "') "
	cSQL  +=                                                                       " AND (NQC.D_E_L_E_T_ = ' ' ) "
	cSQL  +=                                  "LEFT  JOIN "+ RetSqlname('NQE') +" NQE ON (NQE.NQE_COD    = NUQ.NUQ_CLOC3N) AND (NQE.NQE_CLOC2N = NQC.NQC_COD) AND (NQE.NQE_FILIAL = '" + xFilial("NQE") + "') "
	cSQL  +=                                                                       " AND (NQE.D_E_L_E_T_ = ' ' ) "
	cSQL  +=                                  "LEFT  JOIN "+ RetSqlname('NQQ') +" NQQ ON (NQQ.NQQ_COD    = NUQ.NUQ_CDECIS) AND (NQQ.NQQ_FILIAL = '" + xFilial("NUQ") + "') "
	cSQL  +=                                                                       " AND (NQQ.D_E_L_E_T_ = ' ' ) "
	cSQL  += "WHERE NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "' "
	cSQL  +=  " AND NUQ.NUQ_CAJURI = '" + cCajuri + "' "
	cSQL  +=  " AND NUQ.D_E_L_E_T_  = ' ' "

	If lOrigem
		cSQL += " AND NUQ.NUQ_INSATU = '1' "
	EndIf

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNuq, .T., .F.)

	While !(cAliasNuq)->(Eof())
		aAdd( aNuq, { (cAliasNuq)->NUQ_COD,(cAliasNuq)->NUQ_INSATU,(cAliasNuq)->NUQ_INSTAN, (cAliasNuq)->NUQ_NUMPRO,(cAliasNuq)->NUQ_CNATUR,;
			(cAliasNuq)->NQ1_DESC, (cAliasNuq)->NUQ_CMUNIC, (cAliasNuq)->CC2_MUN, (cAliasNuq)->NUQ_DTDIST,(cAliasNuq)->NQ6_DESC,;
			(cAliasNuq)->NQC_DESC, (cAliasNuq)->NQE_DESC, (cAliasNuq)->NUQ_CDECIS, (cAliasNuq)->NQQ_DESC, (cAliasNuq)->NUQ_DTDECI} )

		(cAliasNuq)->( dbSkip() )
	End

	(cAliasNuq)->( DbCloseArea() )
	RestArea(aArea)
Return aNuq

//-------------------------------------------------------------------
/*/{Protheus.doc} JwsLpGtNt9(cCajuri, cTipoEnt)
Retorna a lista de NT9

@param cCajuri  - Código do assunto jurídico
@param cTipoEnt - Numero do Polo
cFilCajuri      - Filial do cajuri

@Return aNt9 - Lista do Envolvido
        aNT9[1] - codigo NT9
        aNT9[2] - codigo Entidade
        aNT9[3] - entidade
        aNT9[4] - principal?
        aNT9[5] - nome entidade
        aNT9[6] - codigo + Loja
        aNT9[7] - codigo Tipo Envolvimento
        aNT9[8] - desc Tipo Envolvimento
        aNT9[9] - codigo Cargo
        aNT9[10] - desc Cargo
        aNT9[11] - polo
        aNT9[12] - % participacao
        aNT9[13] - cpf/cnpj

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNt9(cCajuri, cTipoEnt, cFilCajuri)
	Local aNt9       := {}
	Local cSql       := ""
	Local aArea      := GetArea()
	Local cAliasNt9  := GetNextAlias()
	Local cNT9Codigo := ""
	Local cNT9Loja   := ""
	Local cNT9Entida := ""

	Default cTipoEnt := 0
	Default cFilCajuri := xFilial("NT9")

	cSQL  := " SELECT  NT9.NT9_COD    NT9_COD "
	cSQL  +=        ", NT9.NT9_CODENT NT9_CODENT "
	cSQL  +=        ", NT9.NT9_ENTIDA NT9_ENTIDA "
	cSQL  +=        ", NT9.NT9_PRINCI NT9_PRINCI "
	cSQL  +=        ", NT9.NT9_NOME   NT9_NOME "
	cSQL  +=        ", NT9.NT9_CEMPCL NT9_CEMPCL "
	cSQL  +=        ", NT9.NT9_LOJACL NT9_LOJACL "
	cSQL  +=        ", NT9.NT9_CFORNE NT9_CFORNE "
	cSQL  +=        ", NT9.NT9_LFORNE NT9_LFORNE "
	cSQL  +=        ", NT9.NT9_CTPENV NT9_CTPENV "
	cSQL  +=        ", NQA.NQA_DESC   NQA_DESC "
	cSQL  +=        ", NT9.NT9_ENDECL NT9_ENDECL "
	cSQL  +=        ", NT9.NT9_CCRGDP NT9_CCRGDP "
	cSQL  +=        ", SQ3.Q3_DESCSUM Q3_DESCSUM "
	cSQL  +=        ", NT9.NT9_TIPOEN NT9_TIPOEN "
	cSQL  +=        ", NT9.NT9_PERCAC NT9_PERCAC "
	cSQL  +=        ", NT9.NT9_CGC    NT9_CGC "
	cSQL  += " FROM "+ RetSqlname('NT9') +" NT9 INNER JOIN "+ RetSqlname('NQA') +" NQA ON (NQA.NQA_COD = NT9.NT9_CTPENV) "
	cSQL  +=                                                                        " AND (NQA.NQA_FILIAL = '" + xFilial("NQA") + "') "
	cSQL  +=                                                                        " AND (NQA.D_E_L_E_T_ = ' ') "
	cSQL  +=                                  " LEFT  JOIN "+ RetSqlName('SQ3') +" SQ3 ON (SQ3.Q3_CARGO = NT9.NT9_CCRGDP) "
	cSQL  +=                                                                        " AND (SQ3.Q3_FILIAL = '" + xFilial("SQ3") + "') "
	cSQL  +=                                                                        " AND (SQ3.D_E_L_E_T_ = ' ') "
	cSQL  += " WHERE NT9.NT9_CAJURI = '" + cCajuri + "'"
	cSQL  +=   " AND NT9.NT9_FILIAL = '" + cFilCajuri + "' "
	cSQL  +=   " AND NT9.D_E_L_E_T_ = ' ' "

	Do Case
	Case cTipoEnt == 1 // Polo Ativo
		cSQL += "AND NQA.NQA_POLOAT =  '1' "
	Case cTipoEnt == 2 // Polo Passivo
		cSQL += "AND NQA.NQA_POLOPA =  '1' "
	Case cTipoEnt == 3 // Terceiro Interessado
		cSQL += "AND NQA.NQA_TERCIN =  '1' "
	Case cTipoEnt == 4 // Sociedade Envolvida
		cSQL += "AND NQA.NQA_SOCIED =  '1' "
	Case cTipoEnt == 5 // Participação Societária
		cSQL += "AND NQA.NQA_PARTIC =  '1' "
	Case cTipoEnt == 6 // Administração
		cSQL += "AND NQA.NQA_ADMINI =  '1' "
	End Case

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNt9, .T., .F.)

	While !(cAliasNt9)->(Eof())
		cNT9Entida := (cAliasNt9)->NT9_ENTIDA

		Do Case
		Case cNT9Entida == "SA1"
			cNT9Codigo := (cAliasNt9)->NT9_CEMPCL
			cNT9Loja   := (cAliasNt9)->NT9_LOJACL

		Case cNT9Entida == "SA2"
			cNT9Codigo := (cAliasNt9)->NT9_CFORNE
			cNT9Loja   := (cAliasNt9)->NT9_LFORNE
		End Case


		aAdd( aNt9, {(cAliasNt9)->NT9_COD,;
			(cAliasNt9)->NT9_CODENT,;
			(cAliasNt9)->NT9_ENTIDA,;
			(cAliasNt9)->NT9_PRINCI,;
			(cAliasNt9)->NT9_NOME,;
			cNT9Codigo + '-' + cNT9Loja,;
			(cAliasNt9)->NT9_CTPENV,;
			(cAliasNt9)->NQA_DESC,;
			(cAliasNt9)->NT9_CCRGDP,;
			(cAliasNt9)->Q3_DESCSUM,;
			(cAliasNt9)->NT9_TIPOEN,;
			(cAliasNt9)->NT9_PERCAC,;
			(cAliasNt9)->NT9_CGC } )

		(cAliasNt9)->( dbSkip() )
	End

	(cAliasNt9)->( DbCloseArea() )
	RestArea(aArea)

Return aNt9


//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNsy(cCajuri)
Retorna a lista de NSY

@param cCajuri - Código do assunto jurídico

@Return aNsy - Lista do Objetos

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNsy(cCajuri)
	Local aNsy       := {}
	Local cSql       := ""
	Local aArea      := GetArea()
	Local cAliasNsy  := GetNextAlias()

	cSQL  := " SELECT NSY.NSY_COD	    NSY_COD "
	cSQL  +=        ",NSY.NSY_CAJURI    NSY_CAJURI "
	cSQL  +=        ",CAST(NSY.NSY_DESC AS VARCHAR(4000)) NSY_DESC "
	cSQL  +=        ",NSY.NSY_CPROG     NSY_CPROG "
	cSQL  +=        ",NQ7.NQ7_DESC      NQ7_DESC "
	cSQL  +=        ",NQ7.NQ7_PORCEN    NQ7_PORCEN "
	cSQL  +=        ",NSY.NSY_PEVLR     NSY_PEVLR "
	cSQL  +=        ",NSY.NSY_CMOPED    NSY_CMOPED "
	cSQL  +=        ",CTO.CTO_DESC      CTO_DESC "
	cSQL  +=        ",CTO.CTO_SIMB      CTO_SIMB "
	cSQL  += " FROM "+ RetSqlname('NSY') +" NSY LEFT JOIN "+ RetSqlname('NQ7') +" NQ7 ON (NQ7.NQ7_COD = NSY.NSY_CPROG) "
	cSQL  +=                                                                       " AND (NQ7.NQ7_FILIAL = '" + xFilial("NQ7") + "') "
	cSQL  +=                                                                       " AND (NQ7.D_E_L_E_T_ = ' ') "
	cSQL  +=                                  " LEFT JOIN "+ RetSqlname('CTO') +" CTO ON (CTO.CTO_MOEDA  = NSY.NSY_CMOPED) "
	cSQL  +=                                                                       " AND (CTO.CTO_FILIAL = '" + xFilial("CTO") + "') "
	cSQL  +=                                                                       " AND (CTO.D_E_L_E_T_ = ' ') "
	cSQL  += " WHERE NSY.NSY_CAJURI = '" + cCajuri + "' "
	cSQL  +=   " AND NSY.NSY_FILIAL = '" +xFilial("NSY")+ "' "
	cSQL  +=   " AND NSY.D_E_L_E_T_ = ' ' "
	cSQL  := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNsy, .T., .F.)

	While !(cAliasNsy)->(Eof())
		aAdd( aNsy, {(cAliasNsy)->NSY_COD;
			, (cAliasNsy)->NSY_CAJURI;
			, (cAliasNsy)->NSY_DESC;
			, (cAliasNsy)->NSY_CPROG;
			, (cAliasNsy)->NQ7_DESC;
			, (cAliasNsy)->NQ7_PORCEN;
			, (cAliasNsy)->NSY_PEVLR;
			, (cAliasNsy)->NSY_CMOPED;
			, (cAliasNsy)->CTO_DESC;
			, (cAliasNsy)->CTO_SIMB})

		(cAliasNsy)->( dbSkip() )
	End

	(cAliasNsy)->( dbCloseArea() )
	RestArea(aArea)
Return aNsy

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNt3(cCajuri)
Retorna a lista de NT3

@param cCajuri - Código do assunto jurídico

@Return aNt3 - Lista de Despesas

@author Leandro Silva
@since 26/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNt3(cCajuri)
	Local aNt3         := {}
	Local cSql         := ""
	Local aArea        := GetArea()
	Local cAliasNt3    := GetNextAlias()

	cSQL  := " SELECT NT3.NT3_COD      NT3_COD    "
	cSQL  +=        ",NT3.NT3_CTPDES   NT3_CTPDES "
	cSQL  +=        ",NSR.NSR_DESC     NSR_DESC   "
	cSQL  +=        ",CAST(NT3.NT3_DESC AS VARCHAR(4000)) NT3_DESC   "
	cSQL  +=        ",NT3.NT3_DATA     NT3_DATA   "
	cSQL  +=        ",NT3.NT3_VALOR    NT3_VALOR  "
	cSQL  +=        ",NT3.NT3_CMOEDA   NT3_CMOEDA "
	cSQL  +=        ",CTO.CTO_DESC     CTO_DESC   "
	cSQL  +=        ",CTO.CTO_SIMB     CTO_SIMB   "
	cSQL  += " FROM "+ RetSqlname('NT3') +" NT3 LEFT JOIN "+ RetSqlname('NSR') +" NSR ON (NSR.NSR_COD = NT3.NT3_CTPDES) "
	cSQL  +=                                                                       " AND (NSR.NSR_FILIAL = '" + xFilial("NSR") + "') "
	cSQL  +=                                  " LEFT JOIN "+ RetSqlname('CTO') +" CTO ON (CTO.CTO_MOEDA  = NT3.NT3_CMOEDA) "
	cSQL  +=                                                                       " AND (CTO.CTO_FILIAL = '" + xFilial("CTO") + "') "
	cSQL  += " WHERE NT3.NT3_CAJURI = '" + cCajuri + "' "
	cSQL  +=   " AND NT3.NT3_FILIAL = '" +xFilial("NT3")+ "' "
	cSQL  +=   " AND NT3.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNt3, .T., .F.)

	While !(cAliasNt3)->(Eof())
		aAdd( aNt3, {(cAliasNt3)->NT3_COD;
			,(cAliasNt3)->NT3_CTPDES;
			,(cAliasNt3)->NSR_DESC;
			,(cAliasNt3)->NT3_DESC;
			,(cAliasNt3)->NT3_DATA;
			,(cAliasNt3)->NT3_VALOR;
			,(cAliasNt3)->NT3_CMOEDA;
			,(cAliasNt3)->CTO_DESC;
			,(cAliasNt3)->CTO_SIMB})

		(cAliasNt3)->( dbSkip() )
	End

	(cAliasNt3)->( DbCloseArea() )
	RestArea(aArea)
Return aNt3


//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNt2(cCajuri)
Retorna a lista de NT2

@param cCajuri - Código do assunto jurídico

@author Marcelo Araujo Dente
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNt2(cCajuri)
	Local aNt2      := {}
	Local cSql      := ""
	Local aArea     := GetArea()
	Local cAliasNt2 := GetNextAlias()

	cSQL  := "SELECT NT2.NT2_COD   NT2_COD "
	cSQL  += 		 ",NQW.NQW_DESC  NQW_DESC " 	                     //identifier: Identificador do tipo de garantia (G, A, etc).
	cSQL  +=		 ",CAST(NT2.NT2_DESC AS VARCHAR(4000)) NT2_DESC " 	//description: Descrição da garantia.
	cSQL  +=		 ",NT2.NT2_DATA  NT2_DATA "  						 	//date: Data da garantia.
	cSQL  +=		 ",NT2.NT2_VALOR NT2_VALOR " 							//value: Valor da garantia.
	cSQL  += "FROM " + RetSqlname("NT2") + " NT2 LEFT JOIN "+ RetSqlname('NQW') +" NQW ON (NQW.NQW_COD = NT2.NT2_CTPGAR) "
	cSQL  +=                                                                        " AND (NQW.NQW_FILIAL = '" + xFilial("NQW") + "') "
	cSQL  +=                                                                        " AND (NQW.D_E_L_E_T_ = ' ') "
	cSQL  += "WHERE NT2.NT2_FILIAL = '" + xFilial("NT2") + "' "
	cSQL  +=  		"AND NT2.NT2_CAJURI = '" + cCajuri + "' "
	cSQL  +=  		"AND NT2.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNt2, .T., .F.)

	While !(cAliasNt2)->(Eof())
		aAdd( aNt2, { (cAliasNt2)->NT2_COD;
			,(cAliasNt2)->NQW_DESC;
			,(cAliasNt2)->NT2_DESC;
			,(cAliasNt2)->NT2_DATA;
			,(cAliasNt2)->NT2_VALOR} )
		(cAliasNt2)->( dbSkip() )
	End

	(cAliasNt2)->( DbCloseArea() )

	RestArea(aArea)
Return aNt2

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNt4(cCajuri, nNroTipo)
Retorna a lista de NT4 ( Tipo Decisão)

@param cCajuri - Código do assunto jurídico


@author Marcelo Araujo Dente
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNt4(cCajuri, nNroTipo)
	Local aNt4      := {}
	Local cSql      := ""
	Local aArea     := GetArea()
	Local cAliasNt4 := GetNextAlias()

	Default nNroTipo := 0

	cSql  := "SELECT NT4.NT4_COD "
	cSql  +=       ",NRO.NRO_DESC NRO_DESC "
	cSql  +=       ",NQG.NQG_DESC NQG_DESC "
	cSql  +=       ",NT4.NT4_DTANDA NT4_DTANDA "
	cSql  +=       ",CAST(NT4.NT4_DESC AS VARCHAR(4000)) NT4_DESC "
	cSQL  +=       ",NUQ.NUQ_INSTAN NUQ_INSTAN "
	cSQL  += " FROM " + RetSqlName('NT4') + " NT4 LEFT JOIN " + RetSqlName('NRO') + " NRO ON (NRO.NRO_COD = NT4.NT4_CATO) "
	cSQL  +=                                                                           " AND (NRO.NRO_FILIAL = '"  + xFilial('NRO') + "') "
	cSQL  +=                                                                           " AND (NRO.D_E_L_E_T_ = ' ') "
	cSQL  +=                                    " LEFT JOIN " + RetSqlName('NQG') + " NQG ON (NQG.NQG_COD = NT4.NT4_CFASE) "
	cSQL  +=                                                                           " AND (NQG.NQG_FILIAL = '"  + xFilial('NQG') + "') "
	cSQL  +=                                                                           " AND (NQG.D_E_L_E_T_ = ' ') "
	cSQL  +=                                    " LEFT JOIN " + RetSqlName('NQQ') + " NQQ ON (NQQ.NQQ_COD = NRO.NRO_COD) "
	cSQL  +=                                                                           " AND (NQQ.NQQ_FILIAL = '"  + xFilial('NQQ') + "') "
	cSQL  +=                                                                           " AND (NQQ.D_E_L_E_T_ = ' ') "
	cSQL  +=                                    " LEFT JOIN " + RetSqlName('NUQ') + " NUQ ON (NUQ.NUQ_COD = NT4.NT4_CINSTA) "
	cSQL  +=                                                                           " AND (NUQ.NUQ_CAJURI = NT4.NT4_CAJURI) "
	cSQL  +=                                                                           " AND (NUQ.NUQ_FILIAL = '"+ xFilial('NUQ') + "') "
	cSQL  +=                                                                           " AND (NUQ.D_E_L_E_T_ = ' ') "
	cSQL  += "WHERE NT4.NT4_FILIAL = '" + xFilial("NT4") + "' "
	cSQL  +=  " AND NT4.NT4_CAJURI = '" + cCajuri + "' "
	cSQL  +=  " AND NT4.D_E_L_E_T_ = ' ' "

	If nNroTipo > 0
		cSQL += " AND NRO.NRO_TIPO = '" + cValToChar(nNroTipo) + "'"
	EndIf

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasNt4, .T., .F.)

	While !(cAliasNt4)->(Eof())
		aAdd( aNt4, { (cAliasNt4)->NT4_COD;
			,(cAliasNt4)->NRO_DESC;
			,(cAliasNt4)->NT4_DTANDA;
			,(cAliasNt4)->NT4_DESC;
			,(cAliasNt4)->NUQ_INSTAN;
			,(cAliasNt4)->NQG_DESC} )
		(cAliasNt4)->( dbSkip() )
	End

	(cAliasNt4)->( DbCloseArea() )
	RestArea(aArea)
Return aNt4

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtEnc(cCajuri)
Retorna a lista de Encerramento

@param cCajuri - Código do assunto jurídico

@Return aEnc - lista de Encerramento

@author Leandro Silva
@since 26/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtEnc(cCajuri)
	Local aNszEnc   := {}
	Local cSql      := ""
	Local aArea     := GetArea()
	Local cAliasEnc := GetNextAlias()

	cSQL  := " SELECT NSZ.NSZ_COD      NSZ_COD    "
	cSQL  +=         ",NSZ.NSZ_SITUAC  NSZ_SITUAC "
	cSQL  +=         ",NSZ.NSZ_CMOENC  NSZ_CMOENC "
	cSQL  +=         ",CAST(NQI.NQI_DESC AS VARCHAR(4000))     NQI_DESC "
	cSQL  +=         ",NSZ.NSZ_DTENCE  NSZ_DTENCE "
	cSQL  +=         ",NSZ.NSZ_VLFINA  NSZ_VLFINA "
	cSQL  +=         ",CAST(NSZ.NSZ_DETENC AS VARCHAR(4000))   NSZ_DETENC "

	cSQL  += " FROM "+ RetSqlname('NSZ') +" NSZ LEFT JOIN "+ RetSqlname('NQI') +" NQI ON (NQI.NQI_COD = NSZ.NSZ_CMOENC) "
	cSQL  +=                                                                       " AND (NQI.NQI_FILIAL = '" + xFilial("NQI") + "') "
	cSQL  +=                                                                       " AND (NQI.D_E_L_E_T_ = ' ') "
	cSQL  += " WHERE NSZ.NSZ_COD = '" + cCajuri + "' "
	cSQL  +=   " AND NSZ.NSZ_FILIAL = '" +xFilial("NSZ")+ "' "
	cSQL +=    " AND NSZ.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasEnc, .T., .F.)

	While !(cAliasEnc)->(Eof())
		aAdd( aNszEnc, {(cAliasEnc)->NSZ_COD;
			, (cAliasEnc)->NSZ_SITUAC;
			, (cAliasEnc)->NSZ_CMOENC;
			, (cAliasEnc)->NQI_DESC;
			, (cAliasEnc)->NSZ_DTENCE;
			, (cAliasEnc)->NSZ_VLFINA;
			, (cAliasEnc)->NSZ_DETENC})
		(cAliasEnc)->( dbSkip() )
	End
	(cAliasEnc)->( DbCloseArea() )
	RestArea(aArea)
Return aNszEnc

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetInsDes(nInsta)
Retorna a descrição da Instância

@param nInsta - Numero da Instância

@Return cDesInsta - Descrição da instância

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpArea()
	Local cSqlSelect, cSqlFrom, cSqlWhere, cSqlQuery := ""
	Local oResponse  := JSonObject():New()
	Local cAliasNrb  := GetNextAlias()
	Local aArea 	   := GetArea()
	Local nIndexJSon := 0
	Local aNrb       := {}
	Local nCount     := 0

	cSqlSelect := " SELECT NRB.NRB_COD   NRB_COD "
	cSqlSelect +=       " ,NRB.NRB_DESC  NRB_DESC "
	cSqlSelect +=       " ,NRB.NRB_ATIVO NRB_ATIVO "

	cSqlFrom   := " FROM " + RetSqlname('NRB') + " NRB "

	cSqlWhere  := " WHERE NRB.NRB_ATIVO = '1' "

	cSqlQuery  := "" + cSqlSelect + cSqlFrom + cSqlWhere
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSqlQuery ) , cAliasNrb, .T., .F.)

	oResponse['areas'] := {}

	While !(cAliasNrb)->(Eof())
		nIndexJSon++
		Aadd(oResponse['areas'], JsonObject():New())

		oResponse['areas'][nIndexJSon]['id'] := JConvUTF8((cAliasNrb)->NRB_COD)
		oResponse['areas'][nIndexJSon]['description'] := JConvUTF8((cAliasNrb)->NRB_DESC)

		aNrb := JWsLpGtNrl((cAliasNrb)->NRB_COD)
		oResponse['areas'][nIndexJSon]['subarea'] := {}

		If !Empty(aNrb)
			For nCount := 1 to Len(aNrb)
				Aadd(oResponse['areas'][nIndexJSon]['subarea'], JsonObject():New())
				aTail(oResponse['areas'][nIndexJSon]['subarea'])['idSub']          := JConvUTF8(aNrb[nCount][1])
				aTail(oResponse['areas'][nIndexJSon]['subarea'])['descriptionSub'] := JConvUTF8(aNrb[nCount][2])
			Next
		EndIf

		(cAliasNrb)->( dbSkip())
	End

	(cAliasNrb)->( DbCloseArea() )
	RestArea(aArea)
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtNrl(codArea)
Retorna array com as informações da subarea

@param codArea - Código da Área

@Return cDesInsta - Descrição da instância

@author Willian Kazahaya
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsLpGtNrl(codArea)
	Local aNrl     := {}
	Local cSql     := ""
	Local aArea    := GetArea()
	Local cAliasNrl:= GetNextAlias()

	cSql := " SELECT NRL_COD "
	cSql +=       " ,NRL_DESC "

	cSql += " FROM " + RetSqlname("NRL") + " NRL "
	cSql += " WHERE NRL.D_E_L_E_T_ = ' ' "
	cSql +=   " AND NRL.NRL_CAREA = '" + AllTrim(codArea) + "'"
	cSql +=   " AND NRL.NRL_ATIVO = '1' "

	cSql := ChangeQuery(cSql)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSql ) , cAliasNrl, .T., .F.)

	While !(cAliasNrl)->(Eof())
		aAdd( aNrl, {(cAliasNrl)->NRL_COD;
			,(cAliasNrl)->NRL_DESC})

		(cAliasNrl)->( dbSkip() )
	End

	(cAliasNrl)->( DbCloseArea() )
	RestArea(aArea)
Return aNrl

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsListFup(codProc)
Retorna Follow-ups de um Assunto Jurídico ( Processo )

@param codProc - Código do Processo

@Return oFups - Follow-ups

@author Marcelo Araujo Dente
@since 16/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWsListFup(cCodProc,oResponse,nIndexJSon,lFupMax)
	Local aNta := JWsLpGtNta(cCodProc,lFupMax)
	Local nCount
	Local cFollowup
	Local aNte
	Local nCountAux
	Local cResp
	Local oRespFup  := JsonObject():New()

	oRespFup := {}
	If !Empty(aNta)
		For nCount := 1 to Len(aNta)
			Aadd(oRespFup, JsonObject():New())
			cFollowup := aNta[nCount][1]

			oRespFup[nCount]['id']          := cFollowup
			oRespFup[nCount]['date']        := JConvUTF8(aNta[nCount][2])
			oRespFup[nCount]['hour']        := SubStr(AllTrim(aNta[nCount][3]),1,2) + ":" + SubStr(AllTrim(aNta[nCount][3]), 3, 2)
			oRespFup[nCount]['status']      := JConvUTF8(aNta[nCount][4])
			oRespFup[nCount]['title']       := JConvUTF8(aNta[nCount][5])
			oRespFup[nCount]['tipFup']      := JConvUTF8(aNta[nCount][6])
			oRespFup[nCount]['tipFupDesc']  := JGetNqnDes(aNta[nCount][6])

			aNte := JWsLpGtNte(cFollowup)

			oRespFup[nCount]['responsable'] := {}

			If !Empty(aNte)
				nCountAux := 0
				for nCountAux := 1 to Len(aNte)
					cResp := aNte[nCountAux][1]
					Aadd(oRespFup[nCount]['responsable'], JsonObject():New())
					aTail(oRespFup[nCount]['responsable'])['id']      := cResp
					aTail(oRespFup[nCount]['responsable'])['acronym'] := JConvUTF8(aNte[nCountAux][2])
					aTail(oRespFup[nCount]['responsable'])['name']    := JConvUTF8(aNte[nCountAux][3])
					aTail(oRespFup[nCount]['responsable'])['email']   := JConvUTF8(aNte[nCountAux][4])
					aTail(oRespFup[nCount]['responsable'])['fone']    := JConvUTF8(aNte[nCountAux][5])
				Next
			EndIf
		Next
	EndIf
Return oRespFup

//-------------------------------------------------------------------
/*/{Protheus.doc} STATIC FUNCTION GetStkEvo()
Traz o total de casos Em andamento e a movimentação (Novos e Encerrados) mês a mês

@param cTpAssJur  - Qual é o tipo de assunto jurídico que deseja filtrar?
@param cTpAsCfg  - Assunto jurídico da configuração do produto TOTVS Jurídico Dept.

@return  oResponse, Json, Objeto Json contendo o consolidado de casos Novos, Encerrados e Em Andamento nos ultimos 12 mêses.
@since 26/06/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function GetStkEvo(cTpAssJur, cTpAsCfg)
Local dData      := Date()
Local dDataIni   := FirstDate( MonthSub( dData , 11 ) )
Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local aSQLRestri := Ja162RstUs(,,,.T.)
Local nQtdAnd    := 0
Local aMov       := {}
Local nI         := 0
Local nJ         := 0
Local oResponse  := JsonObject():New()
Local cNSZName   := Alltrim(RetSqlName("NSZ"))
Local aFilUsr    := nil
Local cAssJurGrp := JurTpAsJr(__CUSERID)
Local cQry       := ""
Local cWhere     := ""
Local cJoinNUQ   := ""
Local cNotNUQ    := ""
Local cWhere1    := ""
Local cWhrDtInc  := ""
Local cWhrDtEnc  := ""

Default cTpAssJur := ''
Default cTpAsCfg  := ''
	
	cJoinNUQ := " JOIN " + RetSqlName("NUQ") + " NUQ ON ( "
	cJoinNUQ +=     " NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cJoinNUQ +=     " AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cJoinNUQ +=     " AND NUQ.NUQ_INSATU = '1' "
	cJoinNUQ +=     " AND NUQ.D_E_L_E_T_ = ' ') "

	cNotNUQ := " AND NOT EXISTS ( "
	cNotNUQ +=             " SELECT 1 FROM " + RetSqlName("NUQ") + " NUQ "
	cNotNUQ +=             " WHERE "
	cNotNUQ +=                 " NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cNotNUQ +=                 " AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cNotNUQ +=                 " AND NUQ.D_E_L_E_T_ = ' ' "
	cNotNUQ +=             " ) "

	cWhere += " NSZ.D_E_L_E_T_ = ' ' "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		aFilUsr := JURFILUSR( __CUSERID, "NSZ" )
		cWhere += " AND NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cWhere += " AND NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cWhere += " AND NSZ.NSZ_TIPOAS IN (" + cAssJurGrp + ")" //--ACESSO GRUPO 

	//-- ACESSO PREFERENCIAS 
	If !Empty(cTpAssJur)
		cWhere += " AND NSZ.NSZ_TIPOAS IN " + FormatIn(cTpAssJur, ",") 
	Endif

	cWhere  += VerRestricao(,, cAssJurGrp)

	If !Empty(aSQLRestri)
		cWhere += " AND ("+Ja162SQLRt(aSQLRestri)+")"
	EndIf

	cWhere1 := " AND (NSZ.NSZ_DTINCL < '" + DToS(dDataIni) + "'"
	cWhere1 += " AND (NSZ.NSZ_SITUAC = '1' OR NSZ.NSZ_DTENCE > '" + DToS(dDataIni) + "'))"

	If !Empty(cTpAsCfg)
		cWhrTpAsCfg := " AND NSZ.NSZ_TIPOAS IN " + FormatIn(cTpAsCfg, ",") // -- PREFERÊNCIA A CFG PRODUTO
	Endif


	cQry := " SELECT COUNT(1) QTD "
	cQry += " FROM ( "
	// -- Processos com NUQ
	cQry +=     " SELECT 1 QTD"
	cQry +=     " FROM "+ cNSZName + " NSZ "
	cQry +=         cJoinNUQ
	cQry +=     " WHERE "
	cQry +=         cWhere
	cQry +=         cWhere1
	
	If !Empty(cTpAsCfg)
		cQry += " UNION ALL "

		// --- Processos sem NUQ (filho de procurações)
		cQry +=     " SELECT 1 QTD"
		cQry +=     " FROM "+ cNSZName + " NSZ "
		cQry +=     " WHERE "
		cQry +=         cWhere
		cQry +=         cWhere1
		cQry +=         cNotNUQ
		cQry +=         cWhrTpAsCfg
		
	Endif
	cQry += " ) TabQTD"

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ) , cAlias, .T., .F.)

	If !(cAlias)->(Eof())
		nQtdAnd := (cAlias)->QTD
	EndIf

	(cAlias)->( dbcloseArea() )
	cAlias     := GetNextAlias()
	
	cWhrDtInc := " AND NSZ.NSZ_DTINCL BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dData) + "' "
	cWhrDtEnc := " AND NSZ.NSZ_DTENCE BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dData) + "' "

	cQry := " SELECT "
	cQry +=     " COALESCE(NOVOS.ANOMES,ENCERRADOS.ANOMES) MES, "
	cQry +=     " COALESCE(NOVOS.QTD,0)      AS NOVO, "
	cQry +=     " COALESCE(ENCERRADOS.QTD,0) AS ENCERRADO "
	cQry += " FROM "
	//--- novos
	cQry += " ( "
	cQry += " SELECT COUNT(1) QTD, ANOMES "
	cQry += " FROM (
	cQry +=       " SELECT  1 QTD,CONCAT(SUBSTRING(NSZ.NSZ_DTINCL,1,6),'01') AS ANOMES "
	cQry +=       " FROM "+ cNSZName + " NSZ "
	cQry +=         cJoinNUQ
	cQry += " WHERE "
	cQry +=         cWhere
	cQry +=         cWhrDtInc
	
	If !Empty(cTpAsCfg)
		cQry += " UNION ALL "
		cQry +=       " SELECT  1 QTD,CONCAT(SUBSTRING(NSZ.NSZ_DTINCL,1,6),'01') AS ANOMES "
		cQry +=       " FROM "+ cNSZName + " NSZ "
		cQry += " WHERE "
		cQry +=     cWhere
		cQry +=     cWhrDtInc
		cQry +=     cNotNUQ
		cQry +=     cWhrTpAsCfg
	Endif
	cQry += " ) T "
	cQry += " GROUP BY ANOMES "

	cQry += " ) NOVOS "

	cQry += " FULL JOIN "

	//-- Encerrados
	cQry += " ( "
	cQry += " SELECT COUNT(1) QTD, ANOMES "
	cQry += " FROM (
	cQry +=       " SELECT  1 QTD,CONCAT(SUBSTRING(NSZ.NSZ_DTENCE,1,6),'01') AS ANOMES "
	cQry +=       " FROM "+ cNSZName + " NSZ "
	cQry +=         cJoinNUQ
	cQry +=  " WHERE "
	cQry +=      cWhere
	cQry +=      " AND NSZ.NSZ_SITUAC = '2' "
	cQry +=      cWhrDtEnc
	
	If !Empty(cTpAsCfg)
		cQry += " UNION ALL "
		cQry +=       " SELECT  1 QTD,CONCAT(SUBSTRING(NSZ.NSZ_DTENCE,1,6),'01') AS ANOMES "
		cQry +=       " FROM "+ cNSZName + " NSZ "
		cQry += " WHERE "
		cQry +=     cWhere
		cQry +=     " AND NSZ.NSZ_SITUAC = '2' "
		cQry +=     cWhrDtEnc
		cQry +=     cWhrTpAsCfg
		cQry +=     cNotNUQ
	Endif

	cQry += " ) T "
	cQry += " GROUP BY ANOMES "

	cQry += " ) ENCERRADOS ON "
	cQry +=    " NOVOS.ANOMES = ENCERRADOS.ANOMES "
	cQry += " ORDER BY MES ASC "

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ) , cAlias, .T., .F.)

	// Inclui as movimentações somando a quantidade de andamentos
	While !(cAlias)->(Eof())
		nQtdAnd := (nQtdAnd + (cAlias)->NOVO - (cAlias)->ENCERRADO)
		aAdd( aMov, {AllTrim((cAlias)->MES), (cAlias)->NOVO, (cAlias)->ENCERRADO, nQtdAnd})
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	//Monta o Json com os valores para os 12 mêses
	dData := FirstDate( MonthSub( dData , 11 ) )
	
	oResponse['evolution'] := {}
	oResponse['operation'] := "StockEvolution"

	// Loop do Mês a Mês
	For nI := 1 to 12
		Aadd(oResponse['evolution'], JsonObject():New())
		oResponse['evolution'][nI]['mesano']      := AllTrim(DToS(dData))
		oResponse['evolution'][nI]['novos']       := 0
		oResponse['evolution'][nI]['encerrados']  := 0
		oResponse['evolution'][nI]['andamento']   := nQtdAnd

		// Verifica se houve geração de processo e qual a posição no Array
		nJ := aScan(aMov,{|x| AllTrim(x[1]) == AllTrim(DToS(dData))})

		If (nJ > 0)
			// Atualiza a Quantidade de Andamentos
			nQtdAnd := aMov[nJ][4]

			// Inclui os valores
			oResponse['evolution'][nI]['novos']      := aMov[nJ][2]
			oResponse['evolution'][nI]['encerrados'] := aMov[nJ][3]
			oResponse['evolution'][nI]['andamento']  := nQtdAnd
		EndIf

		// Adiciona 1 mês
		dData := MonthSum( dData , 1 )
	Next

	RestArea(aArea)
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSPsqRNSZ
Listagem de Processos para a barra de Pesquisa Rápida TotvsLegal

@author nishizaka.cristiane
@since 15/07/2019

@param cSearchKey - palavra a ser pesquisada no Nome do Envolvido
					(NT9_NOME) e Número do Processo (NUQ_NUMPRO)
@param nPageSize  - Quantidade de itens na página

@param filProOri - Filial do processo origem
@param cCajuriIN - Relação de cajuris separados por virgula para utilização na cláusula "in()" da query. 

/*/
//-------------------------------------------------------------------
Function JWSPsqRNSZ(cSearchKey,nPageSize, filProOri, cTpAsJ, cRelaciona, cCajuriOri, cFilialOri, cCajuriIN)
Local cQrySelect   := ""
Local cQryFrom     := ""
Local cQryWhere    := ""
Local cQuery       := ""
Local oResponse    := JsonObject():New()
Local aSQLRest     := Ja162RstUs(,,,.T.)
Local cTpAJ        := JWsLpGtNyb()
Local cAlias       := GetNextAlias()
Local nIndexJSon   := 0
Local cExists      := ''
Local cWhere       := ''
Local aFilUsr      := JURFILUSR( __CUSERID, "NSZ" )
Local nPage        := 1
Local cAssJurGrp   := ""
Local bFiliais     := .F.
Local aNT9         := {}
Local nCount       := 0
Local cProcesso    := ""
Local cTpAsJOrig   := ""
Local cWhrTpAsJ    := ""
Local cAssJurRel   := ""
Local nY           := 1
Local aCajuriOri   := {}
Local cExistInc    := ""
Local lFiltraRel   := .F.
	
Default cSearchKey := ""
Default nPageSize  := 10
Default filProOri  := ""
Default cTpAsJ     := ""
Default cRelaciona := ""
Default cCajuriOri := ""
Default cFilialOri := ""
Default cCajuriIN  := ""
	
	If !Empty(cRelaciona)

		If cRelaciona == "incidente"
			// Obtém os cajuris dos processos origens dos incidentes
			CajuriOriInc(cFilialOri, cCajuriOri, @aCajuriOri)
		EndIf

		// Clausula EXISTS para não filtrar o cajuri origem
		cExistInc += "SELECT 1 FROM "+ RetSqlName('NSZ') + " NSZ1 WHERE ("
		
		If Len(aCajuriOri) > 0
			cExistInc += " ( "
		EndIf

		cExistInc += " ( "
		cExistInc += "NSZ1.NSZ_FILIAL = '" + cFilialOri + "' AND "
		cExistInc += "NSZ1.NSZ_COD = '" + cCajuriOri + "' ) "

		If Len(aCajuriOri) > 0
			cExistInc += " OR "
		EndIf

		Do Case 
			Case cRelaciona == "incidente"

				// Somente processos de tipos de assuntos juridicos iguais do processo origem 
				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS = '" + cTpAsJ + "' "
				cWhrTpAsJ += " AND NSZ.NSZ_FPRORI = ' ' "
				cWhrTpAsJ += " AND NSZ.NSZ_CPRORI = ' ' "

				// Complemento da clausula EXISTS para não filtrar incidentes filho do cajuri origem
				For nY := 1 To Len(aCajuriOri)
					cExistInc += " ( "
					cExistInc += "NSZ1.NSZ_FILIAL = '" + aCajuriOri[nY][1] + "' AND "
					cExistInc += "NSZ1.NSZ_COD = '" + aCajuriOri[nY][2] + "' ) "
					
					If nY == Len(aCajuriOri) 
						cExistInc += " ) "
					Else
						cExistInc += " OR "
					EndIf
				Next nY
			Case cRelaciona == "vinculado"
			
				cTpAsJ := JurGetDados("NSZ",1,xFilial("NSZ") + cCajuriOri, "NSZ_TIPOAS")
				// Obtém os assuntos jurídicos filhos do assunto juridico do processo origem.
				cTpAsJ := WsJGetTpAss("'"+cTpAsJ+"'", .T.)
				// Para Vinculados, serão filtrados os tipos de assuntos jurídicos filhos ou iguais ao do processo origem.
				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN (" + cTpAsJ + ") "

			Case cRelaciona == "relacionado"
				cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cTpAsJ, 'NYB_CORIG')
 				If Empty(cTpAsJOrig)
					lFiltraRel := cTpAsJ == "001"
				Else
					lFiltraRel := cTpAsJOrig == "001"
				EndIf

				// Obtém os assuntos jurídicos filhos do assunto juridico do processo origem.
				cAssJurRel := WsJGetTpAss("'001'", .T.)
				If lFiltraRel
					// Trata a string, para retirar o assunto juridico do processo origem
					If "'"+ cTpAsJ +"'" == cAssJurRel
						cAssJurRel := "''"
					ElseIf at(",'"+ cTpAsJ +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cTpAsJ +"',", ",")
					ElseIf at("'"+ cTpAsJ +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,"'"+ cTpAsJ +"',", "")
					ElseIf at(",'"+ cTpAsJ +"'", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cTpAsJ +"'", "")
					EndIf
				EndIf

				If !Empty(cAssJurRel)
					// Somente processos de tipos de assuntos juridicos diferentes do processo origem
					cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJurRel+") "
				EndIf
		EndCase

		cExistInc += " AND NSZ1.D_E_L_E_T_ = ' ' "
		cExistInc += " AND NSZ1.NSZ_COD = NSZ.NSZ_COD "
		cExistInc += " AND NSZ1.NSZ_FILIAL = NSZ.NSZ_FILIAL) "

	Else
		// Filtar Filiais que o usuário possui acesso
		cAssJurGrp := JurTpAsJr(__CUSERID)
		cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN (" + cAssJurGrp + ") "
		cWhrTpAsJ  += VerRestricao(,,cAssJurGrp)
	EndIf

	cQrySelect := " SELECT DISTINCT NSZ.NSZ_COD    NSZ_COD "
	cQrySelect +=        " ,NVE.NVE_TITULO NVE_TITULO , NSZ.NSZ_FILIAL"
	cQrySelect +=        " ,NUQ.NUQ_NUMPRO NUMPRO , NQU.NQU_DESC TIPOACAO"
	cQrySelect +=        " ,NSZ.NSZ_TIPOAS NSZ_TIPOAS "

	cQryFrom   :=   " FROM " + RetSqlName('NSZ') + " NSZ "
	cQryFrom   +=   " JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom   +=     " ON  (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
	cQryFrom   +=     " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=     " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=     " AND (NVE.NVE_FILIAL = '" + xFilial("NVE") + "') "
	cQryFrom   +=     " AND (NVE.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " INNER JOIN " + RetSqlName('NUQ') + " NUQ "
	cQryFrom   +=     " ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrom   +=    " AND NUQ.NUQ_INSATU = '1' "
	cQryFrom   +=    " AND NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrom   +=    " AND NUQ.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NQU') + " NQU "
	cQryFrom   +=         " ON ( NQU.NQU_COD = NUQ.NUQ_CTIPAC ) "
	cQryFrom   +=        " AND ( NQU.NQU_FILIAL =  '" + xFilial("NQU") + "' ) "
	cQryFrom   +=        " AND ( NQU.D_E_L_E_T_ = ' ' ) "

	If Empty(cFilialOri)
		If ( VerSenha(114) .or. VerSenha(115) )
			cQryWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
			If "," $ FORMATIN(aFilUsr[1],aFilUsr[2])
				bFiliais := .T.
			EndIf
		Else
			cQryWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
		Endif
	Else
		cQryWhere := " WHERE NSZ.NSZ_FILIAL = '" + cFilialOri + "'"
		bFiliais := .T.
	EndIF
	cQryWhere += cWhrTpAsJ

	cQryWhere  +=  " AND NSZ.D_E_L_E_T_ = ' ' "

	If !Empty(cCajuriIN)
		cQryWhere +=            " AND NSZ.NSZ_COD in (" + cCajuriIN + ")  "

	Elseif !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cWhere    := " AND " + JurFormat("NT9_NOME", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=     " AND (" + SUBSTR(JurGtExist(RetSqlName("NT9"), cWhere, "NSZ.NSZ_FILIAL"),5)

		If !Empty(cExistInc)
			cQryWhere += "AND NOT EXISTS (" + cExistInc + ") "
		EndIf

		cQryWhere += cExists

		cWhere    :=     " AND " + JurFormat("NUQ_NUMPRO", .F.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=      " OR " + SUBSTR(JurGtExist(RetSqlName("NUQ"), cWhere, "NSZ.NSZ_FILIAL"),5)

		cQryWhere += cExists + " OR NSZ.NSZ_COD  Like '%" + cSearchKey + "%' )"
		
	endif

	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
	EndIf

	cQryOrder := " ORDER BY NSZ.NSZ_COD "

	cQuery := cQrySelect + cQryFrom + cQryWhere + cQryOrder

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['processes'] := {}
	oResponse['userName']  := cUserName
	oResponse['hasMoreBranch']  := bFiliais

	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While (cAlias)->(!Eof())

		nQtdReg++

		// Assunto Juridico
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndexJSon++
			Aadd(oResponse['processes'], JsonObject():New())

			oResponse['processes'][nIndexJSon]['processCompany'] := cEmpAnt
			oResponse['processes'][nIndexJSon]['processBranch']  := (cAlias)->NSZ_FILIAL
			oResponse['processes'][nIndexJSon]['processId']      := (cAlias)->NSZ_COD
			oResponse['processes'][nIndexJSon]['description']    := JConvUTF8((cAlias)->NVE_TITULO )
			oResponse['processes'][nIndexJSon]['tipoAcao']       := JConvUTF8((cAlias)->TIPOACAO )
			oResponse['processes'][nIndexJSon]['assJur']         := JConvUTF8((cAlias)->NSZ_TIPOAS )
			
			cProcesso := (cAlias)->NUMPRO 
			//Se tiver 20 caracteres, aplica a mascara
			If(len(Alltrim(cProcesso)) >= 20)
				cProcesso := AllTrim( Transform(cProcesso, "@R XXXXXXX-XX.XXXX.X.XX.XXXX") )
			EndIf
			
			oResponse['processes'][nIndexJSon]['numProcesso']    := JConvUTF8(cProcesso)

			// Autor/Reu
			aNT9 := JWsLpGtNt9((cAlias)->NSZ_COD,0)
			For nCount := 1 to Len(aNT9)
				If (JConvUTF8(aNT9[nCount][4])) == '1' // É principal?
					If (JConvUTF8(aNT9[nCount][11])) == '1' // Polo Ativo
						oResponse['processes'][nIndexJSon]['author'] := JConvUTF8(aNT9[nCount][5])
					Elseif (JConvUTF8(aNT9[nCount][11])) == '2' // Polo Passivo
						oResponse['processes'][nIndexJSon]['reu'] := JConvUTF8(aNT9[nCount][5])
					Endif
				Endif
			Next

			oResponse['length'] := nQtdReg
		Endif

		(cAlias)->(DbSkip())

	End

	(cAlias)->( DbCloseArea() )

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsListAnd(codProc)
Retorna Andamentos de um Assunto Jurídico ( Processo )

@param cCajuri - Código do Processo
@param nPage - Numero da página
@param nPageSize - Quantidade de itens na página
@param nQtdCarac - Quantidade de caracteres exibidos no campo NT4_DESC

@Return oRespAnd - Andamentos

@since 23/07/19
/*/
//-------------------------------------------------------------------
Function JWsListAnd(cCajuri,nPage,nPageSize,nQtdCarac,cSearchKey)

	Local nIndexJson
	Local oRespAnd  := JsonObject():New()
	Local aNt4      := {}
	Local cQuery    := ""
	Local cQrySel   := ""
	Local cQryFrm   := ""
	Local cQryWhr   := ""
	Local aArea     := GetArea()
	Local cAliasNt4 := GetNextAlias()

	Default nPage      := 1
	Default nPageSize  := 10
	Default nQtdCarac  := 4000
	Default cSearchKey := ""

	cQrySel  := "SELECT NT4.NT4_COD "
	cQrySel  +=       ",NRO.NRO_DESC NRO_DESC "
	cQrySel  +=       ",NQG.NQG_DESC NQG_DESC "
	cQrySel  +=       ",NT4.NT4_DTANDA NT4_DTANDA "
	cQrySel  +=       ",Cast(NT4.NT4_DESC AS VARCHAR("+ cValToChar(nQtdCarac) +")) NT4_DESC "
	cQrySel  +=       ",NUQ.NUQ_INSTAN NUQ_INSTAN "

	cQryFrm  += " FROM " + RetSqlName('NT4') + " NT4 LEFT JOIN " + RetSqlName('NRO') + " NRO ON (NRO.NRO_COD = NT4.NT4_CATO) "
	cQryFrm  +=                                                                           " AND (NRO.NRO_FILIAL = '"  + xFilial('NRO') + "') "
	cQryFrm  +=                                                                           " AND (NRO.D_E_L_E_T_ = ' ') "
	cQryFrm  +=                                    " LEFT JOIN " + RetSqlName('NQG') + " NQG ON (NQG.NQG_COD = NT4.NT4_CFASE) "
	cQryFrm  +=                                                                           " AND (NQG.NQG_FILIAL = '"  + xFilial('NQG') + "') "
	cQryFrm  +=                                                                           " AND (NQG.D_E_L_E_T_ = ' ') "
	cQryFrm  +=                                    " LEFT JOIN " + RetSqlName('NQQ') + " NQQ ON (NQQ.NQQ_COD = NRO.NRO_COD) "
	cQryFrm  +=                                                                           " AND (NQQ.NQQ_FILIAL = '"  + xFilial('NQQ') + "') "
	cQryFrm  +=                                                                           " AND (NQQ.D_E_L_E_T_ = ' ') "
	cQryFrm  +=                                    " LEFT JOIN " + RetSqlName('NUQ') + " NUQ ON (NUQ.NUQ_COD = NT4.NT4_CINSTA) "
	cQryFrm  +=                                                                           " AND (NUQ.NUQ_CAJURI = NT4.NT4_CAJURI) "
	cQryFrm  +=                                                                           " AND (NUQ.NUQ_FILIAL = '"+ xFilial('NUQ') + "') "
	cQryFrm  +=                                                                           " AND (NUQ.D_E_L_E_T_ = ' ') "
	cQryFrm  +=                                    " LEFT JOIN " + RetSqlName('NSZ') + " NSZ ON (NSZ.NSZ_COD = NT4.NT4_CAJURI) "
	cQryFrm  +=                                                                           " AND (NSZ.NSZ_FILIAL = '"+ xFilial('NSZ') + "') "
	cQryFrm  +=                                                                           " AND (NSZ.D_E_L_E_T_ = ' ') "

	cQryWhr  += "WHERE NT4.NT4_FILIAL = '" + xFilial("NT4") + "' "
	cQryWhr  +=  " AND NT4.NT4_CAJURI = '" + cCajuri + "' "
	cQryWhr  +=  " AND NT4.D_E_L_E_T_ = ' ' "

	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cQryWhr += " AND (" + JurFormat("NRO_DESC", .T.,.T.) + " Like '%" + cSearchKey + "%'"

		cQryWhr += " OR  " + JurFormat("NQG_DESC", .F.,.T.) + " Like '%" + cSearchKey + "%'"

		cQryWhr += " OR  " + JurFormat("NT4_DESC", .T.,.T.) + " Like '%" + cSearchKey + "%'"

		cQryWhr += " OR " + JurFormat("NT4_USUINC", .T.,.T.) + " Like '%" + cSearchKey + "%')"
	EndIf

	cQryWhr  +=  " ORDER BY NT4_DTANDA DESC "

	cQuery := cQrySel + cQryFrm + cQryWhr

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasNt4, .T., .F.)

	While !(cAliasNt4)->(Eof())
		aAdd( aNt4, { (cAliasNt4)->NT4_COD;
			,(cAliasNt4)->NRO_DESC;
			,(cAliasNt4)->NT4_DTANDA;
			,(cAliasNt4)->NT4_DESC;
			,(cAliasNt4)->NUQ_INSTAN;
			,(cAliasNt4)->NQG_DESC} )
		(cAliasNt4)->( dbSkip() )
	End

	(cAliasNt4)->(dbCloseArea())

	RestArea(aArea)

	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	oRespAnd := {}
	If !Empty(aNT4)
		For nIndexJSon := 1 to Len(aNT4)
			nQtdReg++
			// Verifica se o registro está no range da pagina
			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				Aadd(oRespAnd, JsonObject():New())
				oRespAnd[nIndexJSon]['id']          := JConvUTF8(aNT4[nIndexJSon][1])
				oRespAnd[nIndexJSon]['title']       := JConvUTF8(aNT4[nIndexJSon][2])
				oRespAnd[nIndexJSon]['date']        := JConvUTF8(aNT4[nIndexJSon][3])
				oRespAnd[nIndexJSon]['description'] := JConvUTF8(aNT4[nIndexJSon][4])
				oRespAnd[nIndexJSon]['phase']       := JConvUTF8(aNT4[nIndexJSon][6])
			Endif
		Next
	EndIf

Return oRespAnd

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsLpGtPro
Listagem de processos com informações resumidas
Utilizado na tela de resumo do processo TOTVS Legal

@since 24/07/19

@param cCodProc - Código do processo a ser pesquisado
@param nPage - Numero da página
@param nPageSize  - Quantidade de itens na página
@param cSearchKey - Código do processo (cajuri)
@param cQryOrder  - Order by da query ("1 - Ordena decrescente por Vlr. Provisão , 2 - Ordena decrescente por Dt. Ult. Andamento)
@param cFilter    - Filtra a query (1 = Processos em Andamento, 2 = Casos Novos, 3 = Encerrados)
@param cSaldoNT2  - Busca o saldo da garantia (1 - garantia)
@param cCodFil    - Código da filial
@param lGtAnexos  - Busca dados de Anexos

@example - http://localhost:4200/juri/JURLEGALPROCESS/tlprocess/detail/0000000066
/*/
//-------------------------------------------------------------------
Function JWsLpGtPro(cCodProc, nPage, nPageSize, cSearchKey, cQryOrder, cFilter,cSaldoNT2,cCodFil,lgtAnexos)
Local cQrySelect   := ""
Local cQryFrom     := ""
Local cQryWhere    := ""
Local cQuery       := ""
Local cCajuri      := ""
Local cInstan      := ""
Local nCount       := 0
Local nIndexJSon   := 0
Local oResponse    := JsonObject():New()
Local lHasNext     := .F.
Local aSQLRest     := Ja162RstUs(,,,.T.)
Local cTpAJ        := JWsLpGtNyb()
Local cAlias       := GetNextAlias()
Local aNuq         := {}
Local aNT9         := {}
Local cNszSituac   := ''
Local cNuqInstan   := ''
Local cTpAsCfg     := J293CfgQry('1')

Default cCodProc   := ""
Default nPage      := 1
Default nPageSize  := 10
Default cSearchKey := ""
Default cQryOrder  := "0"
Default cFilter    := "0"
Default cSaldoNT2  := "0"
Default cCodFil    := xFilial('NSZ')
Default lgtAnexos  := .T.

	cQrySelect := " SELECT NSZ.NSZ_COD    NSZ_COD "
	cQrySelect +=       " ,NSZ.NSZ_CCLIEN NSZ_CCLIEN "
	cQrySelect +=       " ,NSZ.NSZ_LCLIEN NSZ_LCLIEN "
	cQrySelect +=       " ,SA1.A1_NOME    SA1_NOME "
	cQrySelect +=       " ,NSZ.NSZ_NUMCAS NSZ_NUMCAS "
	cQrySelect +=       " ,NVE.NVE_TITULO NVE_TITULO "
	cQrySelect +=       " ,NSZ.NSZ_TIPOAS NSZ_TIPOAS "
	cQrySelect +=       " ,NYB.NYB_DESC   NYB_DESC "
	cQrySelect +=       " ,NSZ.NSZ_DTENTR NSZ_DTENTR "
	cQrySelect +=       " ,NSZ.NSZ_VLPROV VPROV "
	cQrySelect +=       " ,NSZ.NSZ_SITUAC NSZ_SITUAC "
	cQrySelect +=       " ,RD01.RD0_NOME  RD0_NOMERESP  "
	cQrySelect +=       " ,RD01.RD0_SIGLA RD0_SIGLARESP "
	cQrySelect +=       " ,RD02.RD0_NOME  RD0_NOMEADVO  "
	cQrySelect +=       " ,RD02.RD0_SIGLA RD0_SIGLAADVO "
	cQrySelect +=       " ,NSZ.NSZ_CAREAJ NSZ_CAREAJ "
	cQrySelect +=       " ,NRB.NRB_DESC   NRB_DESC "
	cQrySelect +=       " ,NUQ.NUQ_NUMPRO NUMPRO "
	cQrySelect +=       " ,NUQ.NUQ_ANDAUT NUQ_ANDAUT "
	cQrySelect +=       " ,NSZ.NSZ_VAPROV NSZ_VAPROV "
	cQrySelect +=       " ,NQ4.NQ4_DESC   NQ4_DESC "
	cQrySelect +=       " ,SA2.A2_NOME    SA2_CORRESP "
	cQrySelect +=       " ,NSZ.NSZ_SJUIZA NSZ_SJUIZA "
	cQrySelect +=       " ,NZ7.NZ7_LINK   NZ7_LINK "

	// Valores
	cQrySelect +=       " ,(CASE WHEN NSZ.NSZ_VAPROV = 0 "
	cQrySelect +=                " THEN NSZ.NSZ_VLPROV "
	cQrySelect +=                " ELSE NSZ.NSZ_VAPROV END "
	cQrySelect +=        "  ) VALOR "
	cQrySelect +=       " ,NSZ.NSZ_CPRORI NSZ_CPRORI"
	cQrySelect +=       " ,NSZ.NSZ_FPRORI NSZ_FPRORI"
	cQrySelect +=       " ,NSZ.NSZ_VLENVO NSZ_VLENVO"
	cQrySelect +=       " ,NSZ.NSZ_VAENVO NSZ_VAENVO"
	cQrySelect +=       " ,NSZ.NSZ_VLCAUS NSZ_VLCAUS"
	cQrySelect +=       " ,NSZ.NSZ_VACAUS NSZ_VACAUS"
	
	//Prognostico
	cQrySelect +=       " ,COALESCE(NQ7.NQ7_DESC,'') NSZ_DPROGN"


	cQryFrom   := " FROM " + RetSqlName('NSZ') + " NSZ " 
	cQryFrom   +=   " INNER JOIN " + RetSqlName('SA1') + " SA1 ON (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=                                           " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=                                           " AND " + JQryFilial("NSZ","SA1","NSZ","SA1")
	cQryFrom   +=                                           " AND (SA1.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('NVE') + " NVE  ON (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
	cQryFrom   +=                                           " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=                                           " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=                                           " AND (NVE.NVE_FILIAL = '" + xFilial("NVE") + "') "
	cQryFrom   +=                                           " AND (NVE.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('NYB') + " NYB  ON (NYB.NYB_COD = NSZ.NSZ_TIPOAS) "
	cQryFrom   +=                                           " AND (NYB.NYB_FILIAL = '" + xFilial("NYB") + "') "
	cQryFrom   +=                                           " AND (NYB.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('NYB') + " NYB2 ON (NYB2.NYB_COD = NYB.NYB_CORIG) "
	cQryFrom   +=                                           " AND (NYB2.NYB_FILIAL = '" + xFilial("NYB") + "') "
	cQryFrom   +=                                           " AND (NYB2.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('RD0') + " RD01 ON (RD01.RD0_CODIGO = NSZ.NSZ_CPART1) "
	cQryFrom   +=                                           " AND (RD01.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom   +=                                           " AND (RD01.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('RD0') + " RD02 ON (RD02.RD0_CODIGO = NSZ.NSZ_CPART2) "
	cQryFrom   +=                                           " AND (RD02.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom   +=                                           " AND (RD02.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('NRB') + " NRB  ON (NRB.NRB_COD = NSZ.NSZ_CAREAJ) "
	cQryFrom   +=                                           " AND (NRB.NRB_FILIAL = '" + xFilial("NRB") + "') "
	cQryFrom   +=                                           " AND (NRB.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NUQ') + " NUQ ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrom   +=                                           "AND NUQ.NUQ_INSATU  = '1' "
	cQryFrom   +=                                           "AND NUQ.NUQ_FILIAL  = '" + xFilial("NUQ") + "' "
	cQryFrom   +=                                           "AND NUQ.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('SA2') + " SA2 ON (SA2.A2_COD = NUQ.NUQ_CCORRE "
	cQryFrom   +=                                          " AND SA2.A2_LOJA = NUQ.NUQ_LCORRE "
	cQryFrom   +=                                           "AND SA2.A2_FILIAL  = '" + xFilial("SA2") + "' "
	cQryFrom   +=                                           "AND SA2.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NQ4') + " NQ4 ON (NQ4.NQ4_COD = NSZ.NSZ_COBJET "
	cQryFrom   +=                                           "AND NQ4.NQ4_FILIAL  = '" + xFilial("NQ4") + "' "
	cQryFrom   +=                                           "AND NQ4.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NZ7') + " NZ7 ON (NZ7.NZ7_NUMCAS = NSZ.NSZ_NUMCAS "
	cQryFrom   +=                                           "AND NZ7.NZ7_CCLIEN = NSZ.NSZ_CCLIEN "
	cQryFrom   +=                                           "AND NZ7.NZ7_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrom   +=                                           "AND NZ7.NZ7_FILIAL  = '" + xFilial("NZ7") + "' "
	cQryFrom   +=                                           "AND NZ7.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NQ7') + " NQ7 ON "
	cQryFrom   +=             " (NQ7.NQ7_FILIAL = '" + xFilial("NQ7") + "' "
	cQryFrom   +=             " AND NQ7.NQ7_COD = NSZ.NSZ_CPROGN "
	cQryFrom   +=             " AND NQ7.D_E_L_E_T_ = ' ') "

	cQryWhere  := " WHERE NSZ.NSZ_FILIAL = '" + Iif(!Empty(cCodFil), cCodFil, xFilial('NSZ'))+ "'"
	cQryWhere  += "   AND NSZ.D_E_L_E_T_ = ' ' "
	cQryWhere  += "   AND NSZ.NSZ_TIPOAS IN (" + cTpAJ + ") "

	cQryWhere  += VerRestricao()

	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
	EndIf

	If !Empty(cCodProc)
		cQryWhere += " AND NSZ.NSZ_COD = '" + cCodProc + "'"
	EndIf

	// Define o Filtro aplicado na query
	If cFilter == "1" // Processos em Andamento
		cQryWhere += " AND NSZ.NSZ_SITUAC = '1' "
	ElseIf cFilter == "2" // Processos Cadastrados no mês corrente
		cQryWhere += " AND NSZ.NSZ_DTINCL >= '" + DTOS(FirstDate( Date() )) + "' "
	ElseIf cFilter == "3" // Processos Encerrados no mês corrente
		cQryWhere += " AND NSZ.NSZ_DTENCE >= '" + DTOS(FirstDate( Date() )) + "' "
		cQryWhere += " AND NSZ.NSZ_SITUAC = '2' "
	EndIf

	cQryWhere += " AND ( NUQ.NUQ_COD <> ' ' "

	If !Empty(cTpAsCfg)
		cQryWhere += " OR NSZ.NSZ_TIPOAS IN " + FORMATIN(cTpAsCfg, ',')
	EndIf

	cQryWhere += " ) "

	//Define a ordenação da query
	cQryOrder := " ORDER BY NSZ.NSZ_COD "

	cQuery := cQrySelect + cQryFrom + cQryWhere + cQryOrder

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['processes'] := {}

	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	If !Empty(cCodProc)
		oResponse['operation'] := "DetailProcess"
	Else
		oResponse['operation'] := "ListProcess"
	EndIf

	oResponse['userName'] := cUserName

	While (cAlias)->(!Eof())

		nQtdReg++
		// Verifica se o registro está no range da pagina
		if (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndexJSon++

			// Assunto Juridico
			cCajuri := (cAlias)->NSZ_COD
			Aadd(oResponse['processes'], JsonObject():New())

			oResponse['processes'][nIndexJSon]['descFilial']         := If(!Empty(ALLTRIM(xFilial('NSZ'))), JConvUTF8(FWFilialName( , cCodFil )), '')
			oResponse['processes'][nIndexJSon]['processId']          := cCajuri
			oResponse['processes'][nIndexJSon]['assJur']             := JConvUTF8((cAlias)->NSZ_TIPOAS)
			oResponse['processes'][nIndexJSon]['assJurDesc']         := JConvUTF8((cAlias)->NYB_DESC)
			oResponse['processes'][nIndexJSon]['entryDate']          := JConvUTF8((cAlias)->NSZ_DTENTR)
			oResponse['processes'][nIndexJSon]['provisionValue']     := ROUND((cAlias)->VPROV,2)
			oResponse['processes'][nIndexJSon]['atualizedprovision'] := ROUND((cAlias)->VALOR,2)
			oResponse['processes'][nIndexJSon]['balanceInCourt']     := ROUND((cAlias)->NSZ_SJUIZA,2)
			oResponse['processes'][nIndexJSon]['valorEnvolvido']     := ROUND((cAlias)->NSZ_VLENVO,2)
			oResponse['processes'][nIndexJSon]['atualizedInvolved']  := ROUND((cAlias)->NSZ_VAENVO,2)
			oResponse['processes'][nIndexJSon]['subject']            := JConvUTF8((cAlias)->NQ4_DESC)
			oResponse['processes'][nIndexJSon]['office']             := JConvUTF8((cAlias)->SA2_CORRESP)
			oResponse['processes'][nIndexJSon]['valorCausa']         := ROUND((cAlias)->NSZ_VLCAUS,2)
			oResponse['processes'][nIndexJSon]['atualizedCause']     := ROUND((cAlias)->NSZ_VACAUS,2)
			oResponse['processes'][nIndexJSon]['incidente']          := JConvUTF8((cAlias)->NSZ_CPRORI)
			oResponse['processes'][nIndexJSon]['filialIncidente']    := JConvUTF8((cAlias)->NSZ_FPRORI)
			oResponse['processes'][nIndexJSon]['statusAnd']          := JConvUTF8((cAlias)->NUQ_ANDAUT)
			oResponse['processes'][nIndexJSon]['prognostico']        := JConvUTF8((cAlias)->NSZ_DPROGN)
			
			If cSaldoNT2 == "1"//valor do saldo das garantias
				oResponse['processes'][nIndexJSon]['balanceguarantees'] := ROUND(JUR98G('1',cCodProc),2)
				oResponse['processes'][nIndexJSon]['balanceExpenses']   := ROUND(JSumDesp(cCodProc),2)
			EndIf

			// Pasta Fluig
			oResponse['processes'][nIndexJSon]['folderFluig'] := {}
			if lgtAnexos
				aAdd(oResponse['processes'][nIndexJSon]['folderFluig'],JPrcAnxFlg((cAlias)->NSZ_CCLIEN, ;
				                                                              (cAlias)->NSZ_LCLIEN, ;
				                                                              (cAlias)->NSZ_NUMCAS, ;
				                                                              (cAlias)->NZ7_LINK, ;
				                                                              cCajuri))
			EndIf

			// Area
			oResponse['processes'][nIndexJSon]['area'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['area'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['area'])['code']        := JConvUTF8((cAlias)->NSZ_CAREAJ)
			aTail(oResponse['processes'][nIndexJSon]['area'])['description'] := JConvUTF8((cAlias)->NRB_DESC)

			// Caso
			oResponse['processes'][nIndexJSon]['matter'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['matter'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['matter'])['code']        := JConvUTF8((cAlias)->NSZ_NUMCAS)
			aTail(oResponse['processes'][nIndexJSon]['matter'])['description'] := JConvUTF8((cAlias)->NVE_TITULO)

			// Status do Processo
			cNszSituac := JConvUTF8((cAlias)->NSZ_SITUAC)
			oResponse['processes'][nIndexJSon]['status'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['status'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['status'])['code'] := cNszSituac

			If (cNszSituac == '1')
				aTail(oResponse['processes'][nIndexJSon]['status'])['description'] := JConvUTF8(STR0005) // Em andamento
			Else
				aTail(oResponse['processes'][nIndexJSon]['status'])['description'] := JConvUTF8(STR0006) // Encerrado
			EndIf

			// Participantes do Processo
			// Responsável
			oResponse['processes'][nIndexJSon]['staff'] := {}
			Aadd(oResponse['processes'][nIndexJSon]['staff'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['staff'])['position'] := JConvUTF8(STR0007)  // Responsável
			aTail(oResponse['processes'][nIndexJSon]['staff'])['name']     := JConvUTF8((cAlias)->RD0_NOMERESP)
			aTail(oResponse['processes'][nIndexJSon]['staff'])['initials'] := JConvUTF8((cAlias)->RD0_SIGLARESP)

			// Advogado
			Aadd(oResponse['processes'][nIndexJSon]['staff'], JsonObject():New())
			aTail(oResponse['processes'][nIndexJSon]['staff'])['position'] := JConvUTF8(STR0008)  // Advogado
			aTail(oResponse['processes'][nIndexJSon]['staff'])['name']     := JConvUTF8((cAlias)->RD0_NOMEADVO)
			aTail(oResponse['processes'][nIndexJSon]['staff'])['initials'] := JConvUTF8((cAlias)->RD0_SIGLAADVO)

			// Autor/Reu
			aNT9 := JWsLpGtNt9(cCajuri,0)
			For nCount := 1 to Len(aNT9)
				If (JConvUTF8(aNT9[nCount][4])) == '1' // É principal?
					If (JConvUTF8(aNT9[nCount][11])) == '1' // Polo Ativo
						oResponse['processes'][nIndexJSon]['author'] := JConvUTF8(aNT9[nCount][5])
					Elseif (JConvUTF8(aNT9[nCount][11])) == '2' // Polo Passivo
						oResponse['processes'][nIndexJSon]['reu'] := JConvUTF8(aNT9[nCount][5])
					Endif
				Endif
			Next

			// Envolvidos - Parte contraria
			oResponse['processes'][nIndexJSon]['oppositeParty'] := getPartCont(cCajuri)

			// Instância
			aNuq := JWsLpGtNuq(cCajuri,.F.) // Todas as instâncias

			oResponse['processes'][nIndexJSon]['instance'] := {}

			if !Empty(aNuq)
				nCount := 0

				For nCount := 1 to Len(aNuq)
					Aadd(oResponse['processes'][nIndexJSon]['instance'], JsonObject():New())
					cInstan    := JConvUTF8(aNuq[nCount][1])
					cNuqInstan := JConvUTF8(aNuq[nCount][3])

					aTail(oResponse['processes'][nIndexJSon]['instance'])['id']             := cInstan
					aTail(oResponse['processes'][nIndexJSon]['instance'])['instaAtual']     := JConvUTF8(aNuq[nCount][2])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['numInstance']    := JConvUTF8(aNuq[nCount][3])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['displayName']    := JConvUTF8(JGetInsDes(cNuqInstan))
					aTail(oResponse['processes'][nIndexJSon]['instance'])['processNumber']  := JConvUTF8(aNuq[nCount][4])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['natureCode']     := JConvUTF8(aNuq[nCount][5])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['nature']         := JConvUTF8(aNuq[nCount][6])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['cityCode']       := JConvUTF8(aNuq[nCount][7])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['city']           := JConvUTF8(aNuq[nCount][8])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['distribution']   := JConvUTF8(aNuq[nCount][9])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['local']          := JConvUTF8(aNuq[nCount][10])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['districtCourt']  := JConvUTF8(aNuq[nCount][11])
					aTail(oResponse['processes'][nIndexJSon]['instance'])['branch']         := JConvUTF8(aNuq[nCount][12])

				Next
			EndIf

			// Encerramento
			aNszEnc := JWsLpGtEnc(cCajuri)
			oResponse['processes'][nIndexJSon]['closure'] := {}
			If !Empty(aNszEnc)
				For nCount := 1 to Len(aNszEnc)
					Aadd(oResponse['processes'][nIndexJSon]['closure'], JsonObject():New())
					aTail(oResponse['processes'][nIndexJSon]['closure'])['type'] 	     := JConvUTF8(aNszEnc[nCount][3])
					aTail(oResponse['processes'][nIndexJSon]['closure'])['description'] := JConvUTF8(aNszEnc[nCount][4])
					aTail(oResponse['processes'][nIndexJSon]['closure'])['date']        := JConvUTF8(aNszEnc[nCount][5])
					aTail(oResponse['processes'][nIndexJSon]['closure'])['finalValue']  := aNszEnc[nCount][6]
					aTail(oResponse['processes'][nIndexJSon]['closure'])['veredict']    := JConvUTF8(aNszEnc[nCount][7])
				Next
			EndIf
		Elseif (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
		Endif

		(cAlias)->(DbSkip())
	End

	(cAlias)->(dbCloseArea())
	// Verifica se há uma proxima pagina
	If (lHasNext)
		oResponse['hasNext'] := "true"
	Else
		oResponse['hasNext'] := "false"
	EndIf

	oResponse['length'] := nQtdReg

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListDoc
listagem dos anexos

@author SIGAJURI
@since 24/07/2019
@param codFil      - Filial
@param cCodProc    - Código do processo
@param nomeEnt     - Entidade a ser pesquisado o anexo (NTA / NSZ/ NT2...)
@param codEntidade - Código da entidade
@param cCodDoc     - Codigo do documento para pesquisa de Doc especifica
@param cSearchKey  - palavra a ser pesquisada no Nome do documento
					  (NUM_DOC) e Extensao do arquivo (NUM_EXTEN)
@param subPasta	   - Subpasta do documento

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/<filial>/<cajuri>/docs/<nomeEnt>?searchkey=<texto>
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/<filial>/<cajuri>/docs/<nomeEnt>?codEntidade=<000001>
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/<filial>/<cajuri>/docs/<nomeEnt>?codEntidade=<000001>&searchkey=<texto>

/*/
//-------------------------------------------------------------------
WSMETHOD GET ListDoc PATHPARAM codFil, codProc, nomeEnt WSRECEIVE codEntidade, codDoc, searchKey, subPasta WSREST JURLEGALPROCESS
Local lRet := .T.
Local oResponse := nil
Local cCodFil     := Self:codFil
Local cCodProc    := Self:codProc
Local cNomeEntid  := Self:nomeEnt
Local cCodEnt     := Self:codEntidade
Local cCodDoc     := Self:codDoc
Local cSearchKey  := Self:searchKey

	MigraLogo(cCodProc)

	If (lRet := GetDocs(@oResponse, cCodFil, cCodProc, cNomeEntid, cCodEnt, cCodDoc, cSearchKey, self:subPasta))
		Self:SetContentType("application/json")

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET attachments
listagem dos anexos

@author SIGAJURI
@since 24/07/2019
@param nomeEnt     - Entidade a ser pesquisado o anexo (NTA / NSZ/ NT2...)
@param codEntidade - Código da entidade
@param cSearchKey  - palavra a ser pesquisada no Nome do documento
					  (NUM_DOC) e Extensao do arquivo (NUM_EXTEN)
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/docs/<nomeEnt>?codEntidade=<000001>
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/docs/<nomeEnt>?searchKey=<texto>

/*/
//-------------------------------------------------------------------
WSMETHOD GET attachments PATHPARAM nomeEnt WSRECEIVE codEntidade, searchKey WSREST JURLEGALPROCESS
Local lRet := .T.
Local oResponse := nil
Local cNomeEntid  := Self:nomeEnt
Local cCodEnt     := Self:codEntidade
Local cSearchKey  := Self:searchKey
	
	If (lRet := GetDocs(@oResponse,,,cNomeEntid,cCodEnt,,cSearchKey))
		Self:SetContentType("application/json")

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} |GetDocs|
Listagem dos documentos, podendo trazer todos anexos que tenham vinculo
com o processo ou de entidades expecificas

@since 03/08/2021
@param oResponse   - Json de resposta
@param cCodFil     - Código da filial
@param cCodProc    - Código do processo
@param cNomeEntid  - Entidade a ser pesquisado o anexo (NTA / NSZ/ NT2...) 
@param cCodEnt     - Codigo da entidade para pesquisa de Doc especifica
@param cCodDoc     - Codigo do documento para pesquisa de Doc especifica
@param cSearchKey  - palavra a ser pesquisada no Nome do documento
					  (NUM_DOC) e Extensao do arquivo (NUM_EXTEN)
@param cSubPasta   - Subpasta do arquivo
/*/
//-------------------------------------------------------------------
Static Function GetDocs(oResponse, cCodFil, cCodProc, cNomeEntid, cCodEnt, cCodDoc, cSearchKey, cSubPasta)
Local aDocs       := {}
local aEntidades  := {'NSZ','NT2','NT3','NT4','NTA','NSY','O0S', 'O1A','O0N','O1B','O1D'}
Local nI          := 0
Local nX          := 0
Local nIndexJSon  := 0
Local nQtdReg     := 0
Local cParam      := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
Local cTpAssJur   := ''
Local lRet        := .T.
Local lVldRest    := .T.

Default oResponse   := Nil
Default cCodFil     := ""
Default cCodProc    := ""
Default cNomeEntid  := ""
Default cCodEnt     := ""
Default cCodDoc     := ""
Default cSearchKey  := ""

	If !Empty(cCodProc)
		cTpAssJur := JurGetDados("NSZ", 1, cCodFil+cCodProc, "NSZ_TIPOAS")
		lVldRest := JVldRestri(cTpAssJur, "'03'" /*Anexos*/, 2 /*Visualizar*/)
	Endif
	
	If lVldRest
		oResponse := JsonObject():New()
		oResponse['operation'] := "ReturnDocs"
		
		oResponse['attachments'] := {}

		If !Empty(cNomeEntid) .And. cNomeEntid != "NSZ"
			aEntidades := {cNomeEntid}
		EndIf
		For nI := 1 to Len(aEntidades)
			If ( !Empty(cCodProc) .and. cNomeEntid == aEntidades[nI])

				If aEntidades[nI] == "NSY"
							cCodEnt := cCodEnt + cCodProc
				ElseIf aEntidades[nI] $ "NT2 | NT3 | O0S"
							cCodEnt := cCodProc + cCodEnt
				EndIf

			EndIf

			aDocs := {}
			If FWAliasInDic(aEntidades[nI])
				aDocs := listDocs(aEntidades[nI], cCodDoc, cCodEnt,cCodProc,cSearchKey, cSubPasta)
			EndIf

			If !Empty(aDocs)

				for nX:=1 to Len(aDocs)
					nQtdReg++
					nIndexJSon++
					Aadd(oResponse['attachments'], JsonObject():New())

					If cParam <> "3"
						oResponse['attachments'][nIndexJSon]['nameDocument'] := JConvUTF8(aDocs[nX][1])
					Else
						oResponse['attachments'][nIndexJSon]['nameDocument'] := JConvUTF8(aDocs[nX][8])
					EndIf
					oResponse['attachments'][nIndexJSon]['number']       := JConvUTF8(aDocs[nX][2])
					oResponse['attachments'][nIndexJSon]['codeEntity']   := JConvUTF8(aDocs[nX][3])
					oResponse['attachments'][nIndexJSon]['extension']    := JConvUTF8(aDocs[nX][4])
					oResponse['attachments'][nIndexJSon]['nameEntity']   := JConvUTF8(aDocs[nX][5])
					oResponse['attachments'][nIndexJSon]['codeDocument'] := JConvUTF8(aDocs[nX][6])
					oResponse['attachments'][nIndexJSon]['entity']       := JConvUTF8(aDocs[nX][7])
					oResponse['attachments'][nIndexJSon]['dateInsert']   := JConvUTF8(aDocs[nX][9])
				next nX
			EndIf
		Next nI
		oResponse['length'] := nQtdReg

		lRet := .T.


	Else
		lRet := .F.
		ConOut(STR0072)  // Sem permissão para GET em Anexos
		SetRestFault(403, STR0073) // 2: Acesso negado.

	EndIf

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} |listDocs|
Listagem de documentos, podendo trazer todos anexos que tenham vinculo
com o processo ou de entidades expecificas

@author SIGAJURI
@since 24/07/2019
@param cEntidade   - Entidade a ser pesquisado o anexo (NTA / NSZ/ NT2...)
@param cCodDoc     - Codigo do documento para pesquisa de Doc especifica
@param cCodEnti    - Codigo da entidade para pesquisa de Doc especifica
@param cCodProc    - Código do processo,
@param cSearchKey  - palavra a ser pesquisada no Nome do documento
					  (NUM_DOC) e Extensao do arquivo (NUM_EXTEN)
@param cSubPasta    - Subpasta do arquivo
/*/
//-------------------------------------------------------------------
Static Function listDocs(cEntidade, cCodDoc, cCodEnti, cCodProc, cSearchKey, cSubPasta)
	Local cQuery     := ""
	Local cQrySel    := ""
	Local cQryFrm    := ""
	Local cQryWhr    := ""
	Local cIdxEnt    := ""
	Local cEntDom    := "NSZ"
	Local cIdxDom    := Replace(AllTrim(FwX2Unico(cEntDom)),'+','||')
	Local cAlias     := GetNextAlias()
	Local cBanco     := Upper(TcGetDb())
	Local aDocs      := {}
	Local cExists    := ""
	Local cWhere     := ""
	local lNvCmpNUM  := .F.
	Local cDtInclNUM := ""
	Local aAreaNUM   := NUM->(GetArea())
	Local cPasta     := ""

	Default cEntidade  := ""
	Default cCodDoc    := ""
	Default cCodEnti   := ""
	Default cSearchKey := ""
	Default cSubPasta  := ""

	//Coluna de data de inclusão, se tiver o campo no dicionario
	DBSelectArea("NUM")
	lNvCmpNUM := (NUM->(FieldPos('NUM_DTINCL')) > 0)
	NUM->( DBCloseArea() )

	cQrySel := " SELECT NUM_DOC, "
	cQrySel +=        " NUM_NUMERO,"
	cQrySel +=        " NUM_COD,"
	cQrySel +=        " NUM_CENTID,"
	cQrySel +=        " NUM_EXTEN,"
	cQrySel +=        " NUM_ENTIDA,"
	cQrySel +=        " NUM_DESC,"
	cQrySel +=        " NUM_SUBPAS"
	
	If lNvCmpNUM
		cQrySel +=        ", NUM_DTINCL"
	EndIf

	If !Empty(cEntidade)

		cQryFrm := ' FROM ' + RetSqlName(cEntDom) + ' ' + cEntDom
		
		If cEntidade == 'O0N'
			cQryFrm += " INNER JOIN " + RetSqlName('O0M') + " O0M ON "
			cQryFrm +=     "(O0M.O0M_FILIAL = " + cEntDom + "_FILIAL) "
			cQryFrm +=     "AND (O0M.O0M_CAJURI = " + cEntDom + "_COD) "
			cQryFrm +=     "AND (O0M.D_E_L_E_T_ = ' ')"
			cQryFrm += " INNER JOIN " + RetSqlName('O0N') + " O0N ON "
			cQryFrm +=     "(O0N.O0N_FILIAL = O0M.O0M_FILIAL) "
			cQryFrm +=     "AND (O0N.O0N_CSLDOC = O0M.O0M_COD) "
			cQryFrm +=     "AND (O0N.D_E_L_E_T_ = ' ')"

		ElseIf cEntidade != cEntDom //Se a entidade for diferente da NSZ é feito um INNER JOIN
			cQryFrm += " INNER JOIN " + RetSqlName(cEntidade) + " " + cEntidade + " ON "
			cQryFrm +=      "(" + cEntDom + "_COD = " + cEntidade + "_CAJURI)"
			cQryFrm +=      " AND (" + cEntDom + "_FILIAL = " + cEntidade + "_FILIAL)"
			cQryFrm +=      " AND (" + cEntidade + ".D_E_L_E_T_ = ' ')"

		EndIf

		cIdxEnt := Replace(AllTrim(FwX2Unico(cEntidade)),'+','||')

		If cBanco == "POSTGRES"
			If JurHasClas()
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(CONCAT(NUM.NUM_FILENT , NUM.NUM_CENTID)) = RTRIM(CONCAT(" + replace(cIdxEnt,"||",",") + ") )"
			Else
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(NUM.NUM_CENTID) = RTRIM(CONCAT(" + replace(cIdxEnt,"||",",") + ") )"
			EndIf

			If !Empty(cCodEnti)
				cQryWhr := " WHERE RTRIM(CONCAT(" + cIdxEnt + ")) = RTRIM('" + xFilial(cEntidade) + cCodEnti + "')"
			Else
				cQryWhr := " WHERE " + cIdxDom + " = '" + xFilial(cEntDom) + cCodProc + "'"
			EndIf

		Else
			If JurHasClas()
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(NUM.NUM_FILENT || NUM.NUM_CENTID) = RTRIM(" + cIdxEnt + ")"
			Else
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(NUM.NUM_CENTID) = RTRIM(" + cIdxEnt + " )"
			EndIf

			If !Empty(cCodEnti)
				cQryWhr := " WHERE " + cIdxEnt + " = '" + xFilial(cEntidade) + cCodEnti + "'"
			Else
				cQryWhr := " WHERE " + cIdxDom + " = '" + xFilial(cEntDom) + cCodProc + "'"
			EndIf
		EndIf

		cQryWhr +=   " AND " + cEntDom + ".D_E_L_E_T_ = ' ' "

		If !Empty(cCodDoc)
			cQryWhr := " AND NUM.NUM_CENTID = '" + cCodDoc + "'"
		endif

		cQryWhr +=   " AND NUM.D_E_L_E_T_ = ' '"
		cQryWhr +=   " AND NUM.NUM_ENTIDA = '" + cEntidade + "'"
	Else
		cQryFrm := " FROM " + RetSqlName('NUM') + " NUM"

		cQryWhr := " WHERE (NUM.D_E_L_E_T_ = ' ') "

		If !Empty(cCodDoc)
			cQryWhr := " AND NUM.NUM_CENTID = '" + cCodDoc + "'"
		endif
	EndIf
	//Consulta pelo nome do documento e extensao
	If !Empty(cSearchKey)

		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cWhere    := " AND " + JurFormat("NUM_DOC", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   := " AND( " + SUBSTR(JurGtExist(RetSqlName("NUM"), cWhere, cEntDom + "_FILIAL"),5)
		cQryWhr += cExists

		cWhere    := " AND " + JurFormat("NUM_EXTEN", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   := " OR " + SUBSTR(JurGtExist(RetSqlName("NUM"), cWhere, cEntDom + "_FILIAL"),5)
		cQryWhr += cExists + " ) "

		cQryWhr  += VerRestricao()

	EndIf

	If (!Empty(cSubPasta))
		cQryWhr += " AND NUM.NUM_SUBPAS LIKE '%" + cSubPasta + "%'"
	EndIf
	cQuery := cQrySel + cQryFrm + cQryWhr
	cQuery += " ORDER BY NUM.R_E_C_N_O_"

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While !(cAlias)->(Eof())
		If lNvCmpNUM
			cDtInclNUM := (cAlias)->NUM_DTINCL
		EndIf

		cPasta := JurX2Nome( (cAlias)->NUM_ENTIDA )

		If !Empty( (cAlias)->NUM_SUBPAS )
			cPasta += " / " + SubStr(AllTrim((cAlias)->NUM_SUBPAS), 5)
		EndIf

		aAdd( aDocs, { (cAlias)->NUM_DOC;
			,(cAlias)->NUM_NUMERO;
			,(cAlias)->NUM_CENTID;
			,(cAlias)->NUM_EXTEN;
			,cPasta;
			,(cAlias)->NUM_COD;
			,(cAlias)->NUM_ENTIDA;
			,(cAlias)->NUM_DESC;
			,cDtInclNUM })

		(cAlias)->( dbSkip() )
	End
	(cAlias)->(dbCloseArea())

	RestArea(aAreaNUM)

return aDocs
//-------------------------------------------------------------------
/*/{Protheus.doc} WSgetAnexo
Função responsável por identificar qual anexo está sendo utilizado para instanciar a classe

@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade
@param cCodProc     - Codigo do processo

@author SIGAJURI
@since 24/07/2019

/*/
//-------------------------------------------------------------------
Function WSgetAnexo(cEntidade, cCodEnt,cCodProc, cSubPasta)
Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
Local oAnexo  := Nil
Local nIndice := 1

Default cEntidade := ""
Default cCodEnt   := ""
Default cCodProc  := ""
Default cSubPasta := ""

	If cEntidade $ 'NT3|O0S' //indice correspondente a FILIAL + COD no caso de despesa é o 2
		nIndice := 2
	EndIf

	Do Case
	Case cParam == '1'
		oAnexo := TJurAnxWork():New("WorkSite", cEntidade, xFilial(cEntidade), cCodEnt, nIndice,cCodProc) //"WorkSite"
	Case (cParam == '2') .Or. (cSubPasta == 'NSZ_Logomarca')
		oAnexo := TJurAnxBase():NewTHFInterface(cEntidade, cCodEnt, cCodProc) //"Base de Conhecimento"
	Case cParam == '3'
		oAnexo := TJurAnxFluig():New("Documentos em Destaque - Fluig", cEntidade, xFilial(cEntidade), cCodEnt, nIndice, .F., cCodProc ) //"Documentos em Destaque - Fluig"
	EndCase


return oAnexo


//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE DeleteDoc
Deleta documentos anexados.

@since 17/07/2019
@param codFil      - Filial
@param codDoc     - Codigo do documento para pesquisa de Doc especifica
@param nomeEnt     - Alias da entidade
@param codEntidade - Codigo da entidade
@param codProc     - Código do processo
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/

/*/
//-------------------------------------------------------------------
WSMETHOD DELETE DeleteDoc PATHPARAM codFil, codDoc, nomeEnt, codEntidade, codProc WSREST JURLEGALPROCESS
	Local cCodFil    := Self:codFil
	Local cCodDoc    := Self:codDoc
	Local oResponse  := Nil
	Local lRet       := .T.
	Local aCodNUM    := StrToArray( cCodDoc, ',' )
	Local nI         := 0
	Local nIndexJSon := 0
	Local cEntidade  := Self:nomeEnt
	Local cCodEnt    := Self:codEntidade
	Local cNameDoc   := ""
	Local cCodProc   := Self:codProc
	Local cTpAssJur  := ""

	cTpAssJur := JurGetDados("NSZ", 1, cCodFil+cCodProc, "NSZ_TIPOAS")
	If JVldRestri(cTpAssJur, "'03'" /*Anexos*/, 5 /*Excluir*/)

		oResponse  := JsonObject():New()
		oResponse['operation'] := "DeleteDocs"
		Self:SetContentType("application/json")
		oResponse['attachments'] := {}

		for nI := 1 to Len(aCodNUM)
			cNameDoc := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_DESC"))
			lRet := deleteDocs(aCodNUM[nI], cEntidade, cCodEnt, cCodProc)

			nIndexJSon++
			Aadd(oResponse['attachments'], JsonObject():New())

			If lRet
				oResponse['attachments'][nIndexJSon]['isDelete']    := .T.
				oResponse['attachments'][nIndexJSon]['codDocument'] := aCodNUM[nI]
				oResponse['attachments'][nIndexJSon]['nameDocument'] := JConvUTF8(cNameDoc)
			EndIf
		Next nI

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		lRet := .F.
		SetRestFault(403, STR0074) // 5: Acesso negado
		ConOut(STR0072)  // Sem permissão para GET em Anexos

	EndIf

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} listDocs
Função responsável por chamar a função da classe de anexo para deletar os documentos

@author SIGAJURI
@since 24/07/2019
@param cCodDoc     - Codigo do documento para pesquisa de Doc especifica
@param entidade    - Alias da entidade
@param codEntidade - Codigo da entidade
/*/
//-------------------------------------------------------------------
Static Function deleteDocs(cCodDoc, cEntidade, cCodEnt,codProc)
	Local lRet    := .F.
	Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
	Local oAnexo  := WSgetAnexo(cEntidade, cCodEnt,codProc)

	Do Case
	Case cParam == '2' //Base de Conhecimento
		lRet :=  oAnexo:DeleteNUM(cCodDoc)
	Case cParam == '3' //Fluig
		lRet :=  oAnexo:Excluir(cCodDoc)
	EndCase

	FwFreeObj(oAnexo)
	oAnexo := Nil


return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSDownload
Realiza a transmissão do documento

@author SIGAJURI
@since 07/10/2020
@param oWs - Objeto do WS
@param cPathDown - caminho do arquivo a ser transferido

/*/
//-------------------------------------------------------------------
Function JWSDownload(oWs, cPathArq,isMingle)
Local lRet      := .T.
Local cNomeArq  := ""
Local cBuffer   := ""
Local nHandle   := 0
Local nBytes    := 0

Default cPathArq := "''"
Default isMingle := .F.


	If File(cPathArq)
		cNomeArq := SubStr(cPathArq,Rat("/",cPathArq)+1)
		cNomeArq := SubStr(cNomeArq,Rat("\",cNomeArq)+1)

		oWs:SetContentType("Application/octet-stream")
		oWs:SetHeader("Content-Disposition",'attachment; filename="'+cNomeArq+'"')
		nHandle := FOPEN(cPathArq)  // Grava o ID do arquivo

		If nHandle > -1
			While (nBytes := FREAD(nHandle, @cBuffer, 530286)) > 0      // Lê os bytes
				If isMingle
					oWs:SetResponse(encode64(cBuffer))
				Else
					oWs:SetResponse(cBuffer)
				Endif
			EndDo

			FCLOSE(nHandle)
			lRet := .T.
		Else
			conout(STR0023) //"Erro ao ler o arquivo"
			SetRestFault(500, JConvUTF8(STR0023)) //"Erro ao ler o arquivo"
		EndIf

	Else
		lRet := .F.
		conout(STR0024) //"Arquivo não existe."
		SetRestFault(404, JConvUTF8(STR0024)) //"Arquivo não existe."
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DownloadFile
Efetua o download do anexo selecionado

@author SIGAJURI
@since 29/07/2019
@param pathArq     - caminho do arquivo
@param codDoc      - Codigo do documento
@param codEntidade - Codigo da entidade
@param nomeEnt     - Alias da entidade

@example GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/downloadFile?pathArq=/thf/download/arquivo.txt
@example GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/downloadFile?codDoc=0000000004&nomeEnt=NTA&codEntidade=00000001

/*/
//-------------------------------------------------------------------
WSMETHOD GET DownloadFile WSRECEIVE pathArq, codDoc, codEntidade, nomeEnt, subPasta WSREST JURLEGALPROCESS
Local oResponse   := nil
Local oAnexo      := nil
Local lRet        := .T.
Local cTpAnexo    := ""
Local cPathArq    := Self:pathArq
Local cCodDoc     := Self:codDoc
Local cEntidade   := Self:nomeEnt
Local cCodEnt     := Self:codEntidade
Local cPathDown   := "\thf\download\"
Local cNomArq     := ""
Local cFileUrl    := ""
Local cNumero     := ""
Local nCodError   := 404
Local cMsgError   := STR0024 //"Arquivo não existe"
Local cDESCNUM    := ""
Local isMingle    := ValType(Self:GetHeader("x-mingle-set")) <> "U"
Local cSubpasta   := Iif( Empty(Self:subPasta) , "", Self:subPasta)

Default cPathArq  := ""
Default cCodDoc   := ""
Default cEntidade := ""
Default cCodEnt   := ""

	// Caso não tenha enviado o caminho do arquivo por queryParam
	If Empty(cPathArq)

		cTpAnexo := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
		oAnexo   := WSgetAnexo(cEntidade,cCodEnt, /*cCodProc*/, cSubpasta)

		cNumero  := AllTrim( JURGETDADOS("NUM", 1, xFilial("NUM") + cCodDoc, "NUM_NUMERO") )
		cDESCNUM := AllTrim( JURGETDADOS("NUM", 1, xFilial("NUM") + cCodDoc, "NUM_DESC") )
		
		If !Empty(cDESCNUM)
			cNomArq := AllTrim(cDESCNUM)
		Else
			cNomArq := AllTrim( JURGETDADOS("NUM", 1, xFilial("NUM") + cCodDoc, "NUM_DOC") ) + AllTrim( JURGETDADOS("NUM", 1, xFilial("NUM") + cCodDoc, "NUM_EXTEN") )
		Endif

		IF (cTpAnexo == '2') .Or. (cSubpasta == 'NSZ_Logomarca') //Base de Conhecimento
			// Verifica se a pasta de download está criada, caso não, cria a pasta
			If CreatePathDown(@cPathDown)
				
				oAnexo:lSalvaTemp := .F.
				If lRet := oAnexo:Exportar("",cPathDown,cNumero,cNomArq)
					cPathArq := cPathDown+cNomArq
				Endif
			Else
				lRet := .F.
				nCodError := 500
				cMsgError := STR0051 + cValToChar(FError())// Não foi possível criar a pasta /thf. Erro:
			Endif
		ElseIf cTpAnexo == '3' // Fluig
			cFileUrl := oAnexo:Abrir(.F.,cNumero)
			lRet     := !Empty(cFileUrl)
		Else
			lRet := .F.
		EndIf

	Endif

	If lRet
		// Caso base de conhecimento, manda o arquivo
		If (cTpAnexo <> '3' .and. !Empty(cPathArq)) .Or. (cSubpasta == 'NSZ_Logomarca')
			lRet := JWSDownload(Self, cPathArq,isMingle)
		//Quando fluig, manda o json com a url do arquivo
		ElseIf cTpAnexo == '3'
			Self:SetContentType("application/json")

			oResponse := JsonObject():New()
			oResponse['operation'] := "DownloadFiles"
			oResponse['namefile']  := JConvUTF8(cNomArq)
			oResponse['fileUrl']   := JConvUTF8(cFileUrl)

			Self:SetResponse(oResponse:toJson())
			oResponse:fromJson("{}")
			oResponse := NIL
		Endif
	Else
		SetRestFault(nCodError, JConvUTF8(cMsgError) )
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadBase(cArq)
Efetua o download do arquivo

@author SIGAJURI
@since 29/07/2019
@param cArq       - Caminho do arquivo

/*/
//-------------------------------------------------------------------

Function DownloadBase(cArq)

	Local cBuffer := ""
	Local nHandle
	Local nBytes := 0
	Local lRet := .F.
	Local cFilecontent := ""

	If "Linux" $ GetSrvInfo()[2]
		cArq := StrTran(cArq,"\","/")
	Endif

	If File(cArq)
		nHandle := FOPEN(cArq)  // Grava o ID do arquivo

		If nHandle > -1
			//Le os bytes do arquivo que será enviado.
			While (nBytes := FREAD(nHandle, @cBuffer, 524288)) > 0      // Lê os bytes
				cFileContent += cBuffer
			EndDo

			FCLOSE(nHandle)
			lRet := .T.
		Else
			conout(STR0023) //"Erro ao ler o arquivo"
			SetRestFault(500, STR0024) //"Arquivo não existe."
		EndIf
	Else
		conout(STR0024) //"Arquivo não existe."
		SetRestFault(404, STR0024) //"Arquivo não existe."
	EndIf

Return cFileContent
//-------------------------------------------------------------------
/*/{Protheus.doc} POST UploadFile
Efetua o upload dos anexos

@author SIGAJURI
@since 16/08/2019
@param

@example [Sem Opcional] POST -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/anexo

/*/
//-------------------------------------------------------------------

WSMETHOD POST UploadFile WSREST JURLEGALPROCESS
Local oRequest    := JSonObject():New()
Local oResponse   :=  Nil
Local cCodFil     := ""
Local cCajuri     := ""
Local cNomeEntid  := ""
Local cCodEnt     := ""
Local cArquivo    := recebeFile(Self:GetContent(),HTTPHeader("content-type"),@oRequest)
Local cTpAssJur   := ""
Local aResp       := {}
Local lRet        := .T.
Local cSubPasta   := ""
	
	If(VALTYPE( oRequest['entidade'])) == "U"
		lRet := .F.
		SetRestFault(400, STR0023) // "Erro ao ler o arquivo"
	Else

		cNomeEntid := oRequest['entidade']
		cCodFil    := oRequest['filial']
		cCajuri   := oRequest['cajuri']
		cCodEnt   := oRequest['codEntidade']
		cSubPasta  := Iif(VALTYPE( oRequest['subPasta']) == "U", "", oRequest['subPasta'])


		Do case
			Case cNomeEntid == "NT2"
				cCodEnt := cCajuri + cCodEnt
			Case cNomeEntid == "NT3"
				cCodEnt := cCajuri + cCodEnt
			Case cNomeEntid == "NSY"
				cCodEnt := cCodEnt + cCajuri
			Case cNomeEntid == "O0S"
				cCodEnt := cCajuri + cCodEnt
		End Case

		cTpAssJur := JurGetDados("NSZ", 1, cCodFil+cCajuri, "NSZ_TIPOAS")
		
		If JVldRestri(cTpAssJur, "'03'" /*Anexos*/, 3 /*Incluir*/)

			aResp := J026Anexar(cNomeEntid, xFilial(cNomeEntid), cCodEnt, cCajuri, cArquivo,/*lIntPFS*/ ,cSubPasta)
			oResponse := JsonObject():New()
			oResponse['lAnexo'] := aResp[1]
			lRet := aResp[1]
			
			If lRet
				Self:SetResponse(oResponse:toJson())
			Else
				SetRestFault(400, EncodeUtf8(aResp[2]))
			EndIf

			oResponse:fromJson("{}")
			oResponse := NIL
		Else
			lRet := .F.
			ConOut(STR0075) // Sem permissão para POST em Anexos
			SetRestFault(403, STR0076) // 3: Acesso negado
		EndIf
	EndIf

	//Limpando as Variavéis para limpar os espaços de memória do processamento
	cFile       := ""
    cBody       := ""
    cData       := ""
    cHeader     := ""
    cTempHeader := ""
    cTempData   := ""
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrpAprovNT2
Grupo de Aprovação da Garantia

@author SIGAJURI
@since 29/07/2019
/*/
//-------------------------------------------------------------------
	WSMETHOD GET GrpAprovNT2 WSREST JURLEGALPROCESS
	Local oResponse  := JsonObject():New()
	Local cQuery     := ""
	Local cAlias     := ""
	Local nIndexJSon := 0

	cQuery := " SELECT FRP_FILIAL, FRP_COD, RD0_CODIGO,RD0_NOME, FRP_LIMMIN, FRP_LIMMAX "
	cQuery +=   " FROM " + RetSqlName("FRP") + " FRP LEFT JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=     " ON FRP_USER = RD0_USER "
	cQuery +=  " WHERE FRP.D_E_L_E_T_ = ' '"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['groupApprover'] := {}

	While !(cAlias)->(Eof())
		nIndexJSon++
		Aadd(oResponse['groupApprover'], JsonObject():New())
		oResponse['groupApprover'][nIndexJSon]['filial']   := (cAlias)->FRP_FILIAL
		oResponse['groupApprover'][nIndexJSon]['id']       := (cAlias)->FRP_COD
		oResponse['groupApprover'][nIndexJSon]['codResp']  := (cAlias)->RD0_CODIGO
		oResponse['groupApprover'][nIndexJSon]['approver'] := (cAlias)->RD0_NOME
		oResponse['groupApprover'][nIndexJSon]['minLimit'] := (cAlias)->FRP_LIMMIN
		oResponse['groupApprover'][nIndexJSon]['maxLimit'] := (cAlias)->FRP_LIMMAX
		(cAlias)->( dbSkip() )
	End

	(cAlias)->(dbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TabGenerica
Busca de Registro na tabela genérica (SX5)

@author willian.kazahaya
@since 27/08/2019
/*/
//-------------------------------------------------------------------
	WSMethod GET TabGenerica PATHPARAM codTabela WSRECEIVE searchKey, chaveTab WSREST JURLEGALPROCESS
	Local oResponse  := JsonObject():New()
	Local cQuery     := ""
	Local cAlias     := ""
	Local cCodTab    := Self:codTabela
	Local cSearchKey := Self:searchKey
	Local cChaveTab  := Self:chaveTab
	Local nIndexJSon := 0

	cQuery := JWGetDadosX5(cCodTab, cChaveTab, cSearchKey)

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['result'] := {}

	While !(cAlias)->(Eof())
		nIndexJSon++
		Aadd(oResponse['result'], JsonObject():New())
		oResponse['result'][nIndexJSon]['filial']    := (cAlias)->X5_FILIAL
		oResponse['result'][nIndexJSon]['tabela']    := (cAlias)->X5_TABELA
		oResponse['result'][nIndexJSon]['chave']     := (cAlias)->X5_CHAVE
		oResponse['result'][nIndexJSon]['descricao'] := JConvUTF8((cAlias)->X5_DESCRI)
		oResponse['result'][nIndexJSon]['descrispa'] := JConvUTF8((cAlias)->X5_DESCSPA)
		oResponse['result'][nIndexJSon]['descrieng'] := JConvUTF8((cAlias)->X5_DESCENG)
		(cAlias)->( dbSkip() )
	End

	(cAlias)->(dbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SysParam
Busca de Parâmetros

@param codParam   - Código do parâmetro
@param tipoAssjur - Tipo do assunto jurídico

@since 27/08/2019
/*/
//-------------------------------------------------------------------
WSMethod GET SysParam PATHPARAM codParam WSRECEIVE tipoAssjur WSREST JURLEGALPROCESS
	Local oResponse  := JsonObject():New()
	Local cCodParam  := AllTrim(Self:codParam)
	Local cTpAJ      := Self:tipoAssjur

	If Len(cFilant) < 8
		cFilant := PadR(cFilAnt,8)
	EndIf

	oResponse['sysParam'] := JsonObject():New()

	oResponse['sysParam']['name']  := cCodParam
	oResponse['sysParam']['value'] := GetParam(cCodParam, cTpAJ)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParam()
Obtém o conteúdo do parâmetro

@param cParam - Nome do parâmetro
@param cTpAJ  - Tipo do assunto jurídico

@return xConteudo - Conteúdo do prâmetro pesquisado

@since 27/08/2019
/*/
//-------------------------------------------------------------------
Static Function GetParam(cParam, cTpAJ)
Local xConteudo := Nil

Default cTpAJ := ""

	xConteudo := Iif(Empty(cTpAJ), SuperGetMv(cParam), JGetParTpa(cTpAJ, cParam, "2"))

Return xConteudo


//-------------------------------------------------------------------
/*/{Protheus.doc} Favorite
Consulta se o processo foi favoritado

@return .T.

@since 04/09/2019

@example [Sem Opcional] GET -> http://localhost:12173/rest/JURLEGALPROCESS/favorite
/*/
//-------------------------------------------------------------------
	WSMETHOD GET Favorite WSRECEIVE url WSREST JURLEGALPROCESS

	Local oResponse := JSonObject():New()
	Local cCajuri   := ""
	Local cFilPro   := ""
	Local cQuery    := ""
	Local lFavorito := .F.
	Local cAlias    := GetNextAlias()
	Local aAux      := {}

	aAux := StrToArray(Self:url, '/')
	cFilPro   := aAux[2]
	cCajuri   := aAux[3]

	cFilPro := PADR(cFilPro, FWSizeFilial(), " ")

	cQuery := " SELECT 1 FROM " + RetSqlName('O0V')
	cQuery += " WHERE O0V_CAJURI = '" + cCajuri + "' "
	cQuery += " AND O0V_FILCAJ = '" + cFilPro + "'"
	cQuery += " AND O0V_USER = '" + __CUSERID + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If !(cAlias)->(Eof())
		lFavorito := .T.
	EndIf
	(cAlias)->(dbCloseArea())

	oResponse['isFavorite'] := lFavorito

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Favorites
Inclui/ Exclui registros na tabela de favoritos

@return lRet - inclusão/ exclusão realizadas ou não

@since 04/09/2019

@example [Sem Opcional] POST -> http://localhost:12173/rest/JURLEGALPROCESS/favorite
/*/
//-------------------------------------------------------------------

	WSMETHOD POST Favorite WSREST JURLEGALPROCESS
	Local aArea      := GetArea()
	Local aAreaO0V   := O0V->( GetArea() )
	Local lRet       := .T.
	Local oRequest   := JSonObject():New()
	Local oResponse  := JsonObject():New()
	Local cBody      := Self:GetContent()
	Local cCajuri    := ""
	Local cUserId    := ""
	Local cFilPro    := ""
	Local lFavorito  := nil
	Local oModel     := nil
	Local aAux      := {}

	oRequest:fromJson(cBody)
	lFavorito := oRequest['isFavorite']

	aAux := StrToArray(oRequest['url'], '/')
	cFilPro   := aAux[2]
	cCajuri   := aAux[3]

	cFilPro := PADR(cFilPro, FWSizeFilial(), " ")

	cUserId   := oRequest['params']['userId']

	oModel   := FWLOADMODEL("JURA269")
	If lFavorito
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetValue('O0VMASTER','O0V_FILCAJ',cFilPro)
		oModel:SetValue('O0VMASTER','O0V_CAJURI',cCajuri)
		oModel:SetValue('O0VMASTER','O0V_USER',cUserId)

		If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
			lRetorno := .F.
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		dbSelectArea("O0V")
		O0V->( dbSetOrder( 1 ) )	//O0V_FILCAJ, O0V_CAJURI, O0V_USER
		If O0V->( dbSeek( cFilPro + cCajuri + cUserId) )
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			oModel:Activate()
			If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
				lRetorno := .F.
			EndIf

			oModel:DeActivate()
			oModel:Destroy()
		EndIf
		O0V->(dbCloseArea())
	EndIf


	If lRet
		oResponse['isFavorite'] := lFavorito
		Self:SetResponse(oResponse:toJson())
	EndIf
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aAreaO0V)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSumDesp(cCajuri)
Soma os valores das despesas

@return nRet - Valor Sumarizado

@since 06/09/2019
/*/
//-------------------------------------------------------------------

Static Function JSumDesp(cCajuri)
	Local nRet    := 0
	Local cQuery  := ""
	Local cQrySel := ""
	Local cQryFrm := ""
	Local cQryWhr := ""
	Local cAlias  := GetNextAlias()

	cQrySel := " SELECT SUM(NT3_VALOR) VALOR "
	cQryFrm := " FROM " + RetSqlName("NT3")
	cQryWhr := " WHERE NT3_CAJURI = '" + cCajuri + "'"
	cQryWhr += " AND NT3_FILIAL = '" + xFilial("NT3") + "' "
	cQryWhr += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If (cAlias)->(!Eof())
		nRet := (cAlias)->(VALOR)
	EndIf
	(cAlias)->(DbCloseArea())
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListFields
Listagem de campos para Pesquisa Avançada

Retorna um array com as seguintes informações:
	table- Nome da tabela
	field- Nome do campo
	title- Título do campo
	type- Tipo do campo (N- Numérico; D- Data; C- Caractere; M-Memo; Combo; F3 e MULTI- F3 Múltiplo )
	f3func- Função utilizada no F3 do Campo
	comboOptions- Opções do combo

@since 04/09/19

@param tpPesq    - Informa o tipo de pesquisa para busca dos campos
@param searchKey - Palavra chave que será pesquisada nos campos existêntes no ambiente
@param tabela    - Tabela de campo que deseja filtrar

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/fields

/*/
//-------------------------------------------------------------------
WSMETHOD GET ListFields WSRECEIVE searchKey, tpFilter, tabela , pageSize WSREST JURLEGALPROCESS
Local cSearchKey := Self:searchKey
Local aArea      := GetArea()
Local cAliasNVH  := GetNextAlias()
Local oResponse  := JsonObject():New()
Local aAux       := {}
Local cQuery     := ""
Local nIndexJSon := 0
Local nI         := 0
Local cTipoPesq  := "'1'"
local cTabelas   := Self:tabela
local aTabelas   := {}
Local lLimitSize := !Empty(Self:pageSize)

Default cTabelas  := ''

	If !Empty(Self:tpFilter)
		cTipoPesq := Self:tpFilter
	EndIf

	If !Empty(cTabelas)
		aTabelas := STRToArray(cTabelas, ",")
		cTabelas := ''
		
		For nI := 1 To Len(aTabelas)
			cTabelas += "'"+ RetSqlName(aTabelas[nI]) + "',"
		next nI

		If !Empty(cTabelas)
			cTabelas := Left(cTabelas,Len(cTabelas)-1)
		EndIf
	EndIf

	// Traz informações básicas dos campos
	cQuery := "SELECT DISTINCT NVH_TABELA, NVH_CAMPO, NVH_DESC, NVH_CHAVE, NVH_LABEL, NVH_COD "
	cQuery +=  " FROM " + RetSqlName("NVH")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND NVH_FILIAL = '" + xFilial("NVH") + "' AND NVH_TPPESQ IN(" + cTipoPesq + ") "
	If !Empty(cTabelas)
		cQuery += " AND NVH_TABELA IN("+ cTabelas +") "
	EndIf

	If !Empty(cSearchKey)
		cQuery += "AND ("+JModRNormFil('{"fields":["NVH_DESC"],"searchKey":"'+cSearchKey+'"}')
		cQuery += " OR ( LOWER(NVH_CAMPO) = LOWER('" + cSearchKey + "') ))"
	EndIf

	cQuery += " ORDER BY 1,3 "
	cQuery := ChangeQuery(cQuery, .F.)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNVH, .F., .F. )

	oResponse['result'] := {}

	//Monta o Json de Retorno
	While !(cAliasNVH)->(Eof()) .and. (!lLimitSize .or. nIndexJSon < Self:pageSize)
		nIndexJSon++
		Aadd(oResponse['result'], JsonObject():New())
		oResponse['result'][nIndexJSon]['table'] := AllTrim((cAliasNVH)->NVH_TABELA)
		oResponse['result'][nIndexJSon]['field'] := AllTrim((cAliasNVH)->NVH_CAMPO)
		oResponse['result'][nIndexJSon]['title'] := JurEncUTF8(AllTrim((cAliasNVH)->NVH_DESC))
		oResponse['result'][nIndexJSon]['codigo'] := JurEncUTF8(AllTrim((cAliasNVH)->NVH_COD))

		If (!Empty(GetSx3Cache((cAliasNVH)->NVH_CAMPO,"X3_F3")) .And. !Empty((cAliasNVH)->NVH_CHAVE) .And. !Empty((cAliasNVH)->NVH_LABEL))
			oResponse['result'][nIndexJSon]['type'] := "F3"
			oResponse['result'][nIndexJSon]['f3fields'] := AllTrim((cAliasNVH)->NVH_CHAVE) + "-" + AllTrim((cAliasNVH)->NVH_LABEL)
		ElseIf !Empty(GetSx3Cache((cAliasNVH)->NVH_CAMPO,"X3_CBOX"))
			oResponse['result'][nIndexJSon]['type'] := "COMBO"

			aAux := StrTokArr(JurEncUTF8(AllTrim(GetSx3Cache((cAliasNVH)->NVH_CAMPO,"X3_CBOX"))),";")

			// Traz os dados para o combo
			For nI := 1 To Len(aAux)
				aAux[nI] := StrTokArr(aAux[nI],"=")
			Next

			oResponse['result'][nIndexJSon]['comboOptions'] := aAux
		Else
			oResponse['result'][nIndexJSon]['type'] := AllTrim(GetSx3Cache((cAliasNVH)->NVH_CAMPO,"X3_TIPO"))
		EndIf

		aAux := {}

		(cAliasNVH)->( dbSkip() )
	End

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	(cAliasNVH)->(dbCloseArea())
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetListF3
Listagem de Dados para campos F3

Retorna um array com as seguintes informações:
	fildid- Código do ítem
	filddesc- Descrição do ítem

@since 04/09/19

@param cCampo - Descrição do campo para busca de ítens

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/f3list/NSP_COD-NSP_DESC

/*/
//-------------------------------------------------------------------
	WSMETHOD GET GetListF3 PATHPARAM campof3 WSRECEIVE searchKey, searhKeyRet WSREST JURLEGALPROCESS
	Local aArea        := GetArea()
	Local cAlias       := GetNextAlias()
	Local oResponse    := JsonObject():New()
	Local cCampo       := Self:campof3
	Local aExtras      := {"",""}
	Local cSearchKey   := Self:searchKey
	Local cSearhKeyRet := Self:searhKeyRet
	Local cTabela      := ""
	Local cQuery       := ""
	Local cQrySel      := ""
	Local cQryFrm      := ""
	Local cQryWhr      := ""

	Local cChave     := SubStr(cCampo,1,At("-",cCampo)-1)
	Local cLabel     := SubStr(cCampo,At("-",cCampo)+1,Len(cCampo))
	Local nCount     := 0
	Local nI         := 0
	Local aFldChave  := {}

	cTabela := PadL(SubStr(cCampo,1,At("_",cCampo)-1),3,"S")
	oResponse['f3Options'] := {}

	If (cChave == "NVE_NUMCAS")
		aFldChave := {"NVE_CCLIEN", "NVE_LCLIEN", "NVE_NUMCAS"}
	Else
		aFldChave := {cChave}
	EndIf

	If (cTabela != "SSS")
		cQrySel := "SELECT DISTINCT "

		For nI := 1 to Len(aFldChave)
			cQrySel += aFldChave[nI] + ","
		Next

		cQrySel +=  cLabel
		cQryFrm := " FROM " + RetSqlName(cTabela) + " "  + cTabela
		cQryWhr := " WHERE D_E_L_E_T_ = ' ' "

		If !Empty(cSearchKey)
			cQryWhr += " AND " + JurClearStr(cLabel, .T., .T. , .T., .T.) 
			cQryWhr += " Like '%" + JurClearStr(cSearchKey, .T., .T.,.F., .T.)  + "%' "
		EndIf

		If !Empty(cSearhKeyRet)
			cQryWhr += " AND " + JurClearStr(cChave, .T., .T. , .T., .T.) 
			cQryWhr += " Like '%" + JurClearStr(cSearhKeyRet, .T., .T.,.F., .T.)  + "%' "
		EndIf

		aExtras := ExtraFilt(cChave, cTabela)

		// From adicional
		If !Empty(aExtras[1])
			cQryFrm += aExtras[1]
		EndIf

		// Where adicional
		If !Empty(aExtras[2])
			cQryWhr += aExtras[2]
		EndIf

		cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr, .F.)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While !(cAlias)->(Eof()) .And. nCount <= 20
			nCount++

			Aadd(oResponse['f3Options'], JsonObject():New())

			cValChave := ""
			For nI := 1 to Len(aFldChave)
				cValChave += AllTrim(&("(cAlias)->" + aFldChave[nI]))
			Next

			oResponse['f3Options'][nCount]['value'] := cValChave
			oResponse['f3Options'][nCount]['label'] := JurEncUTF8(AllTrim(&("(cAlias)->"+cLabel)))

			(cAlias)->( dbSkip() )
		End
		(cAlias)->(dbCloseArea())
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST leInicial
Recebe uma inicial em pdf via upload, faz o tratamento e devolve o Json
com as informações obtidos.

@author SIGAJURI
@since 16/08/2019
@param

@example [Sem Opcional] POST -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/inicial

/*/
//-------------------------------------------------------------------
	WSMETHOD POST leInicial WSREST JURLEGALPROCESS
	Local cArquivo  := ""
	Local oJson       := JSonObject():New()
	Local lret        := .T.
	Local cLimite     := SubStr(Self:GetContent(),At("testeInicial",Self:GetContent()) +14 )
	Local nTamBusca   := AT("}", SubStr(Self:GetContent(),At("testeInicial",Self:GetContent()) +14 ) ) - 1
	Local cTeste      := SUBSTR(cLimite, 1, nTamBusca)
	Local lTeste      := IIF( cTeste == "true", .T., .F.)

	Self:SetContentType("application/json")

	If len(cFilant) < 8
		cFilant := PadR(cFilAnt,8)
	EndIf

	cArquivo := recebeFile(Self:GetContent(), HTTPHeader("content-type"))

	if !Empty(cArquivo)
		oJson := J268JSON(cArquivo, lTeste)
		oJson['data'][1]['inicialPDF'] := JConvUTF8( cArquivo ) 
		Self:SetResponse(oJson:toJson())
		oJson:fromJson("{}")
		oJson := NIL
	else
		lret := .F.
	Endif

Return lret


//-------------------------------------------------------------------
/*/{Protheus.doc} recebeFile(cBody,cContent, oData)
Faz o recebimento do arquivo enviado via download. usa o conteúdo do body
da requisição e o conteúdo do header enviado via cContent.
A variável oData recebe o objeto Json que será preenchido caso tenham
informações adicionais no body.

@author SIGAJURI
@since 29/07/2019
@param cBody       - Body da requisição
@param cContent    - Conteúdo do header Content-Type
@param oData    - Objeto Json que deve receber o conteúdo adicional do body.

/*/
//-------------------------------------------------------------------
Static Function recebeFile(cBody,cContent, oData)
Local nTamArquivo := 0
Local nHDestino   := 0
Local cLimite     := SubStr(cContent, At("boundary=", cContent) + 9)
Local cFileName   := ""
Local cFile       := "" //conteúdo do arquivo
Local cData       := "" //conteúdo extra
Local cArquivo    := ""
Local cSpool      := ""
Local nFatBody    := ""
Local cHeader     := ""
Local cTempHeader := ""
Local cTempData   := ""

Default oData  := Nil

	nFatBody  := At('Content-Type',cBody)
	cFileName := SubStr(cBody,1,nFatBody)
	cFileName := SubStr(cFileName,At('filename="',cFileName)+10, At('"',SubStr(cFileName,At('filename="',cFileName)+10))-1)
	cFileName := decodeUTF8(AllTrim(cFileName))

	// Tratamento para S.O Linux
	cSpool := Iif("Linux" $ GetSrvInfo()[2], "/spool/", "\spool\")

	cArquivo    := cSpool + cFileName
	cHeader     := SubStr(cBody, nFatBody + 12)
	cTempHeader := SubStr(cHeader, At(Chr(10), cHeader) + 3)
	cFile       := SubStr(cTempHeader, 1, At(cLimite,cTempHeader) - 5)

	nTamArquivo := Len(cFile)
	
	If oData != NIL
		cTempData := SubStr(cBody, At('Content-Disposition: form-data; name="data"', cBody)+47)
		cTempData := SubStr(cTempData,1,At("}",cTempData))
		oData:fromJson(cTempData)
	EndIf

	nHDestino   := FCREATE(cArquivo)
	nBytesSalvo := FWRITE(nHDestino, cFile,nTamArquivo)
	FCLOSE(nHDestino)

	//Limpando as Variavéis para limpar os espaços de memória do processamento
	cFile       := ""
	cBody       := ""
	cData       := ""
	cHeader     := ""
	cTempHeader := ""
	cTempData   := ""
	cFileName   := ""
	cLimite     := ""

Return cArquivo

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtraFilt(cField, cTabela)
Gera o filtro extra para o select

@Param cField - Campo
@Param cTabela - Tabela

@return [1] Clausula From extra
		[2] Clausula Where Extra

@author SIGAJURI
@since 27/09/2019
/*/
//-------------------------------------------------------------------
Static Function ExtraFilt(cField, cTabela)
	Local cQryWhrExt := ""
	Local cQryFrmExt := ""
	Default cTabela := ""

	Do case
	Case cField == "RD0_SIGLA"
		cQryWhrExt := " AND RD0_TPJUR = '1' "
	End Case

Return {cQryFrmExt, cQryWhrExt}

//-------------------------------------------------------------------
/*/{Protheus.doc} listVara
retona a vara vinculada ao foro

@param cCodForo   - código do foro
@return aVara     [1] Filial da Vara
		          [2] Cód tribunal (localização 3º. nível)
		          [3] Descrição do tribunal (localização 3º. nível)
		          [4] Código do Foro (localização 2º. nível)

@author SIGAJURI
@since 27/08/19

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/foro/00001

/*/
//-------------------------------------------------------------------
static Function listVara(cCodForo, cSearchKey, cSrcVara)
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	Local aVara  := {}

	Default cSearchKey := ''
	Default cSrcVara   := ''

	cQuery := "SELECT NQE_FILIAL, NQE_COD, NQE_DESC, NQE_CLOC2N FROM "+ RetSqlName("NQE")+ " NQE "
	cQuery += "WHERE NQE.NQE_CLOC2N = '" + cCodForo + "'"
	cQuery +=        " AND NQE.NQE_FILIAL = '"+xFilial("NQE") + "' AND NQE.D_E_L_E_T_ = ' '"

	If !Empty(cSearchKey)
		cQuery +=    " AND Upper(NQE_DESC) LIKE  '%" + Upper(cSearchKey) + "%'"
	EndIf

	If !Empty(cSrcVara)
		cQuery +=    " AND Upper(NQE_COD) = '" + Upper(cSrcVara) + "'"
	EndIf

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While !(cAlias)->(Eof())
		aAdd( aVara, { (cAlias)->NQE_FILIAL,(cAlias)->NQE_COD,(cAlias)->NQE_DESC, (cAlias)->NQE_CLOC2N} )
		(cAlias)->( dbSkip() )
	End
	(cAlias)->(dbCloseArea())

return aVara

//-------------------------------------------------------------------
/*/{Protheus.doc} GET LtFuncionarios
Lista de Funcionarios - GPEA010

@since 27/08/2019
@version 1.0

@param page      - Numero da página
@param pageSize  - Quantidade de itens na página
@param nomeFunc  - palavra a ser pesquisada no Nome do documento
@param searchKey - Código do funcionário

@example  GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/funcionarios
/*/
//-------------------------------------------------------------------
	WSMETHOD GET LtFuncionarios WSRECEIVE page, pageSize, searchKey, nomeFunc WSREST JURLEGALPROCESS
	Local oResponse  := Nil
	Local nPage      := Self:page
	Local nPageSize  := Self:pageSize
	Local cSearchKey := Self:searchKey
	Local cNomeFunc  := Self:nomeFunc

	Self:SetContentType("application/json")

	oResponse := JWsFuncion(nPage, nPageSize, cSearchKey, cNomeFunc )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWsFuncion(nPage, nPageSize, cSearchKey, cNomeFunc)
Busca os Funcionarios - SRA

@since 27/08/2019
@version 1.0

@param page       - Numero da página
@param pageSize   - Quantidade de itens na página
@param cSearchKey - palavra a ser pesquisada no código de matrícula do funcionário.
@param cNomeFunc  - palavra a ser pesquisada no Nome do funcionário.
/*/
//-------------------------------------------------------------------
Function JWsFuncion(nPage, nPageSize, cSearchKey, cNomeFunc)
	Local oResponse  := JSonObject():New()
	Local cAliasSRA  := GetNextAlias()
	Local aArea 	 := GetArea()
	Local nIndexJSon := 0
	Local nQtdReg    := 0
	Local cQuery     := ""

	Default nPage      := 1
	Default nPageSize  := 10
	Default cSearchKey := ""
	Default cNomeFunc  := ""

	cQuery :=  " SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_CIC, RA_CARGO, RA_ADMISSA, RA_DEMISSA, RA_CC "
	cQuery +=  " FROM " + RetSqlName("SRA") + " SRA "
	cQuery +=  " WHERE SRA.D_E_L_E_T_ = ' ' "

	If !Empty(cSearchKey)
		cQuery += " AND RA_FILIAL || RA_MAT = '" + cSearchKey + "' "
	EndIf

	If!Empty(cNomeFunc)
		cQuery += " AND UPPER(RA_NOMECMP) LIKE '%" + Upper(cNomeFunc) + "%'"
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasSRA, .T., .F. )

	oResponse['funcionarios'] := {}

	nQtdRegIni := ((nPage-1) * nPageSize)

	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While !(cAliasSRA)->(Eof())

		nQtdReg++

		// Verifica se o registro está no range da pagina
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)

			nIndexJSon++
			Aadd(oResponse['funcionarios'], JsonObject():New())

			oResponse['funcionarios'][nIndexJSon]['filial']      := EncodeUTF8((cAliasSRA)->RA_FILIAL)
			oResponse['funcionarios'][nIndexJSon]['matricula']   := EncodeUTF8((cAliasSRA)->RA_MAT)
			oResponse['funcionarios'][nIndexJSon]['nome']        := JConvUTF8((cAliasSRA)->RA_NOMECMP)
			oResponse['funcionarios'][nIndexJSon]['cpf']         := JConvUTF8((cAliasSRA)->RA_CIC)
			oResponse['funcionarios'][nIndexJSon]['cargo']       := (cAliasSRA)->RA_CARGO
			oResponse['funcionarios'][nIndexJSon]['dtAdmissao']  := (cAliasSRA)->RA_ADMISSA
			oResponse['funcionarios'][nIndexJSon]['dtDemissao']  := (cAliasSRA)->RA_DEMISSA
			oResponse['funcionarios'][nIndexJSon]['centroCusto'] := (cAliasSRA)->RA_CC
		EndIf

		(cAliasSRA)->( dbSkip())
	End

	(cAliasSRA)->( DbCloseArea() )
	RestArea(aArea)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET - DtRecebidas
Lista de Distribuições recebidas - JURA219

@since 06/09/2019
@version 1.0

@param page - Numero da página
@param pageSize - Quantidade de itens na página
@param cSearchKey  - palavra a ser pesquisada no Nome do documento

@example  GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/funcionarios
/*/
//-------------------------------------------------------------------
	WSMETHOD GET DtRecebidas PATHPARAM tipoDistr WSRECEIVE page, pageSize, searchKey WSREST JURLEGALPROCESS
	Local oResponse  := Nil
	Local nPage      := Self:page
	Local nPageSize  := Self:pageSize
	Local cSearchKey := Self:searchKey
	Local tipoDistr  := Self:tipoDistr

	Self:SetContentType("application/json")

	oResponse := JSeekPrcss(tipoDistr, nPage, nPageSize, cSearchKey )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET - J219Distr
Busca informações de uma determinada Distribuição com status Recebida
(JURA219)

@since 06/09/2019
@version 1.0

@param page - Numero da página
@param pageSize - Quantidade de itens na página
@param cSearchKey  - palavra a ser pesquisada no Nome do documento

@example  GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/funcionarios
/*/
//-------------------------------------------------------------------
	WSMETHOD GET J219Distr PATHPARAM codDistr WSRECEIVE page, pageSize, searchKey WSREST JURLEGALPROCESS
	Local oResponse  := Nil
	Local cCodDstr   := Self:codDistr

	Self:SetContentType("application/json")

	oResponse := JDistReceb( cCodDstr )[1]

	Self:SetResponse("["+oResponse:toJson()+"]")
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JSeekPrcss(tipoDistr,nPage, nPageSize, cSearchKey)
Busca todas as Distribuições com status 1 - Recebida

@param tipoDistr - Tipo de Distribuição
@param nPage - Numero da página
@param nPageSize - Quantidade de itens na página
@param cSearchKey  - palavra a ser pesquisada no Nome do documento

@since 	06/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSeekPrcss(tipoDistr,nPage, nPageSize, cSearchKey)

	Local oResponse  := JSonObject():New()
	Local oDadosPro  := JsonObject():New()
	Local cAliasNZZ  := GetNextAlias()
	Local aArea 	 := GetArea()
	Local cQuery     := ""
	Local xConteudo  := ""
	Local nQtdReg    := 0
	Local nIndexJSon := 0

	Default tipoDistr  := '1'
	Default nPage      := 1
	Default nPageSize  := 10
	Default cSearchKey := ""

	oResponse['data'] := {}
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['distribuicoes'] := {}

	cQuery :=  " SELECT NZZ_FILIAL, "
	cQuery +=         " NZZ_COD, "
	cQuery +=         " NZZ_AUTOR AS ATIVO, "
	cQuery +=         " NZZ_REU AS PASSIVO, "
	cQuery +=         " NZZ_TRIBUN AS TRIBUNAL, "
	cQuery +=         " NZZ_NUMPRO "
	cQuery +=  " FROM " + RetSqlName("NZZ") + " NZZ "
	cQuery +=  " WHERE NZZ_FILIAL = '" + xFilial("NZZ") + "' "
	cQuery +=         " AND NZZ_STATUS = '" + tipoDistr + "' "
	If !Empty(cSearchKey)
		cQuery +=     " AND (" + JurFormat("NZZ_NUMPRO", .F.,.T.) + " LIKE '%" + StrTran( JurLmpCpo( cSearchKey, .T.,.T.) , "#", "") + "%' "
		cQuery +=           " OR " + JurFormat("NZZ_TRIBUN", .F.,.T.) + " LIKE '%" + lower(cSearchKey) + "%' "
		cQuery +=           " OR " + JurFormat("NZZ_AUTOR", .F.,.T.) + " LIKE '%" + lower(cSearchKey) + "%' "
		cQuery +=           " OR " + JurFormat("NZZ_REU", .F.,.T.) + " LIKE '%" + lower(cSearchKey) + "%') "
	EndIf
	cQuery +=         " AND NZZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasNZZ, .T., .F. )

	nQtdRegIni := ((nPage-1) * nPageSize)

	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While !(cAliasNZZ)->(Eof())
		nQtdReg++

		// Verifica se o registro está no range da pagina
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)

			//-- Numero do Processo
			xConteudo := (cAliasNZZ)->NZZ_NUMPRO
			xConteudo := StrTran(xConteudo, "-", "")
			xConteudo := StrTran(xConteudo, ".", "")
			xConteudo := JurEncUTF8(Alltrim(xConteudo))

			nIndexJSon++
			//-- Json com todas as Distribuições com status "Recebida"
			oDadosPro['codigo']     := (cAliasNZZ)->NZZ_COD
			oDadosPro['descricao']  := JConvUTF8(Alltrim((cAliasNZZ)->ATIVO) + " / " +  Alltrim((cAliasNZZ)->PASSIVO) + " / " + xConteudo  + " / "  +  Alltrim((cAliasNZZ)->TRIBUNAL))
			oDadosPro['NZZ_NUMPRO'] := xConteudo

			aAdd(oResponse['data'][1]['distribuicoes'], oDadosPro )
			oDadosPro := JsonObject():New()
		EndIf

		(cAliasNZZ)->( dbSkip() )
	End

	(cAliasNZZ)->( DbCloseArea() )
	RestArea(aArea)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET SrchForo
Busca os foros de acordo com a comarca de origem

@since 10/09/19
@param codComarca   - Codigo da Comarca

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/comarca/00001/foros
/*/
//-------------------------------------------------------------------
	WSMETHOD GET SrchForo PATHPARAM codComarca WSRECEIVE searchKey, buscaInfo WSREST JURLEGALPROCESS
	Local cAliasFor  := GetNextAlias()
	Local aArea      := GetArea()
	Local cQuery     := ''
	Local nIndexJSon := 0
	Local cComarca   := Self:codComarca
	Local cSrcForo   := Self:buscaInfo
	Local cSearchKey := Self:searchKey
	Local oResponse  := JsonObject():New()

	cQuery := " SELECT NQC_COD, "
	cQuery +=        " NQC_DESC "
	cQuery += " FROM " + RetSqlName("NQC") + " NQC "
	cQuery += " WHERE NQC.NQC_FILIAL = '" + xFilial("NQC") + "' "
	cQuery +=        " AND NQC.NQC_CCOMAR = '" + cComarca + "' "
	cQuery +=        " AND NQC.D_E_L_E_T_ = ' ' "

	If !Empty(cSearchKey)
		cQuery +=    " AND Upper(NQC_DESC) LIKE '%" + Upper(cSearchKey) + "%' "
	EndIf

	If !Empty(cSrcForo)
		cQuery +=    " AND Upper(NQC_COD) = '" + cSrcForo +  "' "
	EndIf

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasFor, .F., .F. )


	Self:SetContentType("application/json")
	oResponse['foro'] := {}

	While !(cAliasFor)->(Eof())
		nIndexJSon++

		Aadd(oResponse['foro'], JsonObject():New())

		oResponse['foro'][nIndexJSon]['value'] := (cAliasFor)->NQC_COD
		oResponse['foro'][nIndexJSon]['label'] := JConvUTF8( ALLTRIM( (cAliasFor)->NQC_DESC ) )

		(cAliasFor)->( dbSkip() )
	End

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	(cAliasFor)->( DbCloseArea() )
	RestArea(aArea)

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET SrchVara
Busca as varas de acordo com o Foro de origem

@param codComarca   - Codigo da Comarca
@param codForo   - Codigo do Foro

@since 10/09/19

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/foro/00001/varas
/*/
//-------------------------------------------------------------------
	WSMETHOD GET SrchVara PATHPARAM codComarca,codForo WSRECEIVE searchKey, buscaInfo WSREST JURLEGALPROCESS
	Local aVara      := {}
	Local nIndexJSon := 0
	Local nX         := 0
	Local cSrcVara   := Self:buscaInfo
	Local cCodForo   := Self:codForo
	Local cSearchKey := Self:searchKey
	Local oResponse  := JsonObject():New()

	aVara := listVara( cCodForo, cSearchKey, cSrcVara )

	Self:SetContentType("application/json")
	oResponse['vara'] := {}

	For nX := 1 To Len(aVara)
		nIndexJSon++

		Aadd(oResponse['vara'], JsonObject():New())

		oResponse['vara'][nIndexJSon]['value'] := JConvUTF8( ALLTRIM(aVara[nX][2]) )
		oResponse['vara'][nIndexJSon]['label'] := JConvUTF8( ALLTRIM(aVara[nX][3]) )
	Next Nx

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter
Executa a pesquisa avançada de processos

@param correcao - Informa se sofrerá correção de valores ou não
@return lRet - .T.

@since 12/09/2019

@example [Sem Opcional] POST -> http://localhost:12173/rest/JURLEGALPROCESS/SetFilter
@param Body - {	"filters": [{"label":"Situacao: Em andamento","value":"1","field":"NSZ_SITUAC","type":"COMBO","condition":"000000131","$id":"35a5527d-28ab-4f86-95ba-65182fc74772"}], 
				"count": 1, 
				"page": 1, 
				"pageSize": 20, 
				"target": "NTA"}
/*/
//-------------------------------------------------------------------

WSMETHOD POST SetFilter WSRECEIVE correcao WSREST JURLEGALPROCESS
Local cTmp       := ""
Local aArea      := GetArea()
Local nPage      := 0
Local nPageSize  := 0
Local aSQL       := {}
Local oRequest   := JSonObject():New()
Local oResponse  := JSonObject():New()
Local cBody      := Self:GetContent()
Local cQuery     := ""
Local cQueryAuto := ""
Local nTotal, nI := 0
Local cCampo     := ""
Local xValor     := ""
Local cTipo      := ""
Local cCondicao  := ""
Local nIndexJSon := 0
Local lRetAspas  := .T.
Local lHasNext   := .F.
Local cDtIni     := ""
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local nQtdReg    := 0
Local lExporta   := .F.
Local nQtdExport := 0
Local lNoFilter  := .F.
Local lFirstCmp  := .F.
Local cNxtCampo  := ""
Local lRepete    := .F.
Local cTarget    := "processes"
Local cCodPart   := ""
Local cSigla     := ''
Local lCorrige   := Self:correcao == 'true'
Local oRegFila   := JSonObject():New()
Local cThread    := ""
Local cUser      := __cUserID
Local nInsertNQ3 := 0
Local lAutRec    := InfoSX2('NQ3','X2_AUTREC') == '1'
Local cAssuntos  := ""
Local lPDF       := .F.
Local aSearchKey := {}
Local lDeepLegal := .F.
Local lOnlyQtd   := .F.
Local cUnidades  := ""
Local lDicDeepL  := .F.
Local lRestFault := .F.
Local lRet       := .T.
Local aFilUsr    := IIF( VALTYPE(Self:GetHeader("listFiliais")) <> "U", { Self:GetHeader("listFiliais"), "," }, JURFILUSR( __CUSERID, "NSZ" ) )

	// Verifica se o campo de id da carteira Deep Legal existe no dicionário
	If Select("NUH") > 0
		lDicDeepL := (NUH->(FieldPos('NUH_IDEEPL')) > 0) .And. (NUQ->(FieldPos('NUQ_DEEPL')) > 0)
	Else
		DBSelectArea("NUH")
			lDicDeepL := (NUH->(FieldPos('NUH_IDEEPL')) > 0) .And. (NUQ->(FieldPos('NUQ_DEEPL')) > 0)
		NUH->( DBCloseArea() )
	EndIf

	oRegFila['listProcess'] := {}
	oRegFila['cUserId']     := cUser
	oRegFila['count']       := 0

	oRequest:fromJson(cBody)
	nTotal     := oRequest['count']
	nPage      := oRequest['page']
	nPageSize  := oRequest['pageSize']
	lExporta   := oRequest['export'] == "true"
	lDeepLegal := oRequest['isDeepLegal'] == "true"
	lOnlyQtd   := oRequest['isOnlyQtd'] == "true"

	If ! Empty(oRequest['target'])
		cTarget := oRequest['target']
	EndIf

	// -- Tratamento para Deep Legal ao enviar todos
	If lDeepLegal
		lNoFilter  := oRequest['isNoFilter']
		lRestFault := !lDicDeepL
	EndIf

	//-- Tratamento para exportação - Relatório de Pesquisa Avançada
	If lExporta
		nQtdExport := oRequest['expCount']
		lNoFilter  := oRequest['isNoFilter']
		lPDF  := !Empty(oRequest['codRel'])	
	EndIf

	If lRestFault
		lRet := .F.
		SetRestFault(404, STR0082) // "Atualização de dicionário de dados necessária."
	Else
		If nTotal > 0 .Or. lNoFilter
			//trata os dados de requisição
			For nI := 1 To nTotal
				lRetAspas := .T.

				cCampo    := oRequest['filters'][nI]['field']
				cNxtCampo := Iif(nI < nTotal, oRequest['filters'][nI+1]['field'], "")
				cTipo     := oRequest['filters'][nI]['type']
				xValor    := oRequest['filters'][nI]['value']
				cCondicao := oRequest['filters'][nI]['condition'] //código da NVH
				cCondicao := AllTrim(JurGetDados("NVH", 1, xFilial("NVH") + AllTrim(cCondicao), "NVH_WHERE")) //localiza o NVH_WHERE

				lRepete := cCampo == cNxtCampo
				If lRepete .And. !lFirstCmp
					cCondicao := StrTran(cCondicao, "AND", "AND (", 1, 1 )
					lFirstCmp := .T.
				ElseIf lRepete .And. lFirstCmp
					cCondicao := StrTran(cCondicao, "AND", "OR ", 1, 1 )
				ElseIf !lRepete .And. lFirstCmp
					cCondicao := StrTran(cCondicao, "AND", "OR ", 1, 1 )
					cCondicao += " ) "
					lFirstCmp := .F.
				EndIf

				//processa o valor entre ## e coloca o valor a ser pesquisado na condição
				cDado := SubStr(cCondicao, At("#", cCondicao),(RAt("#", cCondicao)-At("#", cCondicao))+1)
				If (cCampo == "NSZ_NUMCAS")
					cCondicao := StrTran(cCondicao, "NSZ_NUMCAS", "NSZ_CCLIEN || NSZ001.NSZ_LCLIEN || NSZ001.NSZ_NUMCAS")
				ElseIf (cCampo == "searchKey")
					aAdd(aSearchKey, xValor )
					loop
				Else
					If cDado == "#DADO_LIKE#"
						xValor := DecodeUTF8( xValor )
						lRetAspas := .F.
					ElseIf cTipo == "D"
						If !Empty(xValor[1])
							//De: Altera a condição para >= e adiciona ao array do WHERE a data inicial
							cCondicao := StrTran(cCondicao, SubStr(cCondicao, At(cCampo, cCondicao)+len(cCampo), At(cDado, cCondicao)), " >= "+cDado)
							cDtIni    := StrTran(cCondicao, cDado,; //localiza conteúdo entre os ##
							FormataVal(StrTran(xValor[1],"-", ""), cTipo, lRetAspas)) //formata o conteúdo a ser pesquisado, de acordo com o tipo

							aAdd(aSQL,{cCampo, cDtIni})
						EndIf

						If !Empty(xValor[2])
							//Até: Altera a condição para <= e segue o fluxo
							cCondicao := StrTran(cCondicao, SubStr(cCondicao, At(cCampo, cCondicao)+len(cCampo), At(cDado, cCondicao)), " <= "+cDado)
							xValor := StrTran(xValor[2],"-", "")
						EndIf
					ElseIf cTipo == "C"
						xValor := DecodeUTF8(xValor)
					EndIf

					If cCampo $ "NTE_CPART | NTE_SIGLA "
						cCodPart += ", '" + Alltrim(xValor) + "' "
					EndIf
				EndIf

				cCondicao := StrTran(cCondicao, cDado, FormataVal(xValor, cTipo, lRetAspas)) //formata o conteúdo a ser pesquisado, de acordo com o tipo
				aAdd(aSQL,{cCampo, cCondicao})
			Next

			nQtdRegIni := ((nPage-1) * nPageSize)

			// Define o range para inclusão no JSON
			nQtdRegFim := (nPage * nPageSize)
			nQtdReg    := 0

			//-- Tratamento para exportação - Relatório de Pesquisa Avançada
			If lExporta
				nQtdRegIni := 1
				nQtdRegFim := oRequest['count']
				nQtdReg    := 0
			EndIf
			
			cThread := Iif(cTarget == 'deeplegal', '', GetCodSecao(cUser, SubStr(AllTrim(Str(ThreadId())),1,4)))

			// Consulta com filtro
			If (!lNoFilter .And. !lExporta) .Or. (!lAutRec .And. lExporta) .Or. lDeepLegal

				cQuery := MontaQryFilter(oRequest, cUser, cThread, cTarget, aSQL, cCodPart,.f.,.f., aSearchKey, lOnlyQtd, aFilUsr)

				If lOnlyQtd
					cQuery := " SELECT count(1) QTD FROM (" + cQuery + ") QTD"
				EndIf

				cTmp   := GetNextAlias()
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .F. )
				oResponse[cTarget] := {}

				While (cTmp)->(!Eof())
					If !lOnlyQtd
						nQtdReg++

						If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim) .And. !lExporta

							nIndexJSon++
							Aadd(oResponse[cTarget], JsonObject():New())

							If cTarget == 'deeplegal'
								If (cTmp)->NSZ_NUMPRO != ''
									oResponse[cTarget][nIndexJSon]['numero_processo']        := Transform((cTmp)->NSZ_NUMPRO, '@R 9999999-99.9999.9.99.9999')
								Else 
									oResponse[cTarget][nIndexJSon]['numero_processo']        := (cTmp)->NSZ_NUMPRO
								EndIf 
								oResponse[cTarget][nIndexJSon]['cajuriFilial']               := (cTmp)->NSZ_FILIAL
								oResponse[cTarget][nIndexJSon]['cajuri']                     := (cTmp)->NSZ_COD
								//Informações para montar a carteira 
								oResponse[cTarget][nIndexJSon]['unidade']                    := JsonObject():New()
								oResponse[cTarget][nIndexJSon]['unidade']['codigo']          := (cTmp)->NUH_COD
								oResponse[cTarget][nIndexJSon]['unidade']['loja']            := (cTmp)->NUH_LOJA
								oResponse[cTarget][nIndexJSon]['unidade']['filial']          := (cTmp)->NUH_FILIAL
								oResponse[cTarget][nIndexJSon]['unidade']['deeplegal_id']    := (cTmp)->NUH_IDEEPL
								oResponse[cTarget][nIndexJSon]['unidade']['nome']            := JConvUTF8(AllTrim((cTmp)->A1_NOME))
								
								oResponse[cTarget][nIndexJSon]['assunto_juridico']           := JsonObject():New()
								oResponse[cTarget][nIndexJSon]['assunto_juridico']['codigo'] := (cTmp)->NYB_COD
								oResponse[cTarget][nIndexJSon]['assunto_juridico']['filial'] := (cTmp)->NYB_FILIAL

								oResponse[cTarget][nIndexJSon]['area_juridica']              := JsonObject():New()
								oResponse[cTarget][nIndexJSon]['area_juridica']['codigo']    := (cTmp)->NRB_COD
								oResponse[cTarget][nIndexJSon]['area_juridica']['filial']    := (cTmp)->NRB_FILIAL
							Else
								oResponse[cTarget][nIndexJSon]['processFilial']                  := (cTmp)->NSZ_FILIAL
								oResponse[cTarget][nIndexJSon]['processId']                      := (cTmp)->NSZ_COD
								oResponse[cTarget][nIndexJSon]['processStatus']                  := (cTmp)->NSZ_SITUAC
								oResponse[cTarget][nIndexJSon]['processTipoAssunto']             := (cTmp)->NSZ_TIPOAS
								oResponse[cTarget][nIndexJSon]['caseTitle']                      := JConvUTF8((cTmp)->NVE_TITULO)
								
								If cTarget == 'processes'
									//Resultado de nip
									oResponse[cTarget][nIndexJSon]['dataNotif']                      := (cTmp)->NSZ_DTCERT
									oResponse[cTarget][nIndexJSon]['demanda']                        := JConvUTF8((cTmp)->NSZ_IDENTI)
									oResponse[cTarget][nIndexJSon]['natureza']                       := JConvUTF8((cTmp)->NSZ_OBJSOC)
									oResponse[cTarget][nIndexJSon]['statusANS']                      := JConvUTF8((cTmp)->NSZ_ULTCON)
									oResponse[cTarget][nIndexJSon]['protocolo']                      := JConvUTF8((cTmp)->NSZ_NIRE)
									oResponse[cTarget][nIndexJSon]['beneficiario']                   := JConvUTF8((cTmp)->NT9_NOME)
									
									oResponse[cTarget][nIndexJSon]['provisionDate']          := (cTmp)->NSZ_DTPROV
									oResponse[cTarget][nIndexJSon]['provisionAmount']        := (cTmp)->NSZ_VLPROV
									oResponse[cTarget][nIndexJSon]['prognostic']             := JConvUTF8((cTmp)->NQ7_DESC)

								ElseIf cTarget == 'tasks'
									cSigla := ArrTokStr(JRespNTE((cTmp)->NSZ_FILIAL, (cTmp)->NTA_COD, 'RD0_SIGLA'), " / ")

									oResponse[cTarget][nIndexJSon]['taskId']                 := JConvUTF8((cTmp)->NTA_COD)
									oResponse[cTarget][nIndexJSon]['taskType']               := JConvUTF8((cTmp)->NTA_CTIPO)
									oResponse[cTarget][nIndexJSon]['taskTypeDesc']           := JConvUTF8((cTmp)->NQS_DESC)
									oResponse[cTarget][nIndexJSon]['taskDate']               := (cTmp)->NTA_DTFLWP
									oResponse[cTarget][nIndexJSon]['taskStatus']             := JConvUTF8((cTmp)->NTA_CRESUL)
									oResponse[cTarget][nIndexJSon]['taskStatusDesc']         := JConvUTF8((cTmp)->NQN_DESC)
									oResponse[cTarget][nIndexJSon]['taskRepresentative']     := JConvUTF8((cTmp)->NTA_CPREPO)
									oResponse[cTarget][nIndexJSon]['taskRepresentativeName'] := JConvUTF8((cTmp)->NQM_DESC)
									oResponse[cTarget][nIndexJSon]['taskOwner']              := JConvUTF8(cSigla)
									oResponse[cTarget][nIndexJSon]['taskHour']               := IIf( !Empty((cTmp)->NTA_HORA),;
																									Transform((cTmp)->NTA_HORA, "@R 99:99"),;
																									'' )
								EndIf
							EndIf
						ElseIf (nQtdReg == nQtdRegFim + 1)
							lHasNext := .T.
						EndIf
							
						If cTarget == 'processes' .And. lExporta
							//Preenche os dados para fila de impressão por RecLock
							Aadd(oRegFila['listProcess'], JsonObject():New())
							aTail(oRegFila['listProcess'])['ProcessFilial'] := (cTmp)->NSZ_FILIAL
							aTail(oRegFila['listProcess'])['ProcessId']     := (cTmp)->NSZ_COD
							oRegFila['count'] := oRegFila['count']+1
						EndIf

						If cTarget == 'deeplegal' .And. ;
						(cTmp)->NUH_IDEEPL == 0 .And. ;
						!( (cTmp)->NUH_FILIAL+(cTmp)->NUH_COD+(cTmp)->NUH_LOJA $ cUnidades )
							If !Empty(cUnidades)
								cUnidades += ","
							EndIf
							cUnidades += (cTmp)->NUH_FILIAL+(cTmp)->NUH_COD+(cTmp)->NUH_LOJA
						EndIf

						If !( (cTmp)->NSZ_TIPOAS $ cAssuntos )
							If !Empty(cAssuntos)
								cAssuntos += ","
							EndIf
							cAssuntos += (cTmp)->NSZ_TIPOAS
						EndIf
					Else
						nQtdReg := (cTmp)->QTD
					EndIf
					(cTmp)->(DbSkip())
				EndDo
				
				(cTmp)->( dbcloseArea() )
				oResponse['length'] := nQtdReg
			EndIf

			// Adiciona registro na fila de impressão e gera a lista de índices para atualização
			If cTarget == 'processes' .And.  lExporta
				
				If lAutRec
					// INSERT NQ3
					If lPDF
						cAssuntos := buscaAssuntos(MontaQryFilter(oRequest, cUser, cThread, cTarget, aSQL, cCodPart, lAutRec, .T., aSearchKey,,aFilUsr))
					EndIf

					cQueryAuto := MontaQryFilter(oRequest, cUser, cThread, cTarget, aSQL, cCodPart, lAutRec,.F., aSearchKey,,aFilUsr)
					nInsertNQ3 := JLPInsertNQ3(xFilial("NQ3"), cUser, cThread, cQueryAuto)
					If nInsertNQ3 > 0 
						If lCorrige  .And. ;
						!Empty(SuperGetMV('MV_JINDUSR', , "")) .And. ;
						!Empty(SuperGetMV('MV_JINDPSW', , ""))
							// Busca os indices utilizados nos processos filtrados
							oResponse['listIndice'] := getUltAtuInd(, cThread, lAutRec)
						EndIf
					Else 
						nInsertNQ3 := 0
					EndIf
					oResponse['length'] := nInsertNQ3
				Else 
					// RecLock NQ3
					If Len(oRegFila['listProcess']) > 0
						
						SetRegFila(oRegFila, cThread)
						If lCorrige .And. ;
						!Empty(SuperGetMV('MV_JINDUSR', , "")) .And. ;
						!Empty(SuperGetMV('MV_JINDPSW', , ""))
							// Busca os indices utilizados nos processos filtrados
							oResponse['listIndice'] := getUltAtuInd(oRegFila, cThread)
						EndIf
					EndIf
				EndIf
			EndIf

			// Verifica se há uma proxima pagina
			oResponse['hasNext'] := lHasNext

		EndIf
		oResponse['query'] := Iif( Empty(cQuery) , JConvUTF8(cQueryAuto), JConvUTF8(cQuery) )
		oResponse['thread'] := cThread
		oResponse['assuntos'] := cAssuntos

		If cTarget == 'deeplegal'
			oResponse['unidades'] := cUnidades
		EndIf

		Self:SetResponse(oResponse:toJson())
	EndIf
	oResponse:fromJson("{}")
	oResponse := NIL
	RestArea( aArea )

	aSize(aFilUsr, 0)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodSecao
Verifica se já existe registro na NQ3 com a thread corrente e retorna 
um código de seção ainda não utilizada

@param cUser      Código do usuário
@param cSecToVld  Número da thread a ser validada

@since 25/06/2021

@return cRet código de seção
/*/
//-------------------------------------------------------------------
Static Function GetCodSecao(cUser, cSecToVld)
Local aArea    := GetArea()
Local cRet     := ""
Local cQry     := ""
Local cAlias   := GetNextAlias()
Local aAlfa    := {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J",;
                   "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",;
                   "U", "V", "X", "Z", "W", "Y"}
Local nPosAlfa := 0

	cRet := cSecToVld

	cQry := " SELECT DISTINCT 1 FROM " + RetSqlName("NQ3") + " NQ3 "
	cQry += " WHERE NQ3.NQ3_CUSER  = '" + cUser + "' "  
	cQry +=   " AND NQ3.NQ3_FILIAL = '" + xFilial("NQ3") + "' "
	cQry +=   " AND NQ3.NQ3_SECAO  = '" + cRet + "' "
	cQry +=   " AND NQ3.D_E_L_E_T_ = ' ' "

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), cAlias, .F., .F. )

	If !(cAlias)->(Eof())

		nPosAlfa := aScan(aAlfa,{|x| x == SubStr(cRet,-1,1) })

		cRet := SubStr(cRet,1,3) + aAlfa[nPosAlfa + 1]
		cRet := GetCodSecao(cUser, cRet)
	EndIf
	
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaQryFilter
Constroi a query de filtro dos processos

@param oRequest   Corpo da requisição
@param cUser      Código do usuário
@param cThread    Número da Thread (4 digitos)
@param cTarget    Tipo do Assunto Juridico
@param aSQL       Array de campos 
@param cCodPart   Código do participante
@param lAutRec    Indica se é inclusão via query
@param lAssJur    Define se irá buscar o tipo de assunto juridico
@param aSearchKey palavra chave a ser pesquisada
@param lOnlyQtd  Define se retorna somente a quantidade de registros
@param aFilUsr    Filiais que o usuário tem acesso

@return cQryRet - Query para filtro

@since 28/06/2021
/*/
//-------------------------------------------------------------------
Static Function MontaQryFilter(oRequest, cUser, cThread, cTarget, aSQL, cCodPart, lAutRec, lAssJur, aSearchKey, lOnlyQtd, aFilUsr)

Local cTpAsCfg   := ""
Local cTpAssunto := ""
Local cFiltExtr  := ""
Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cNSZName   := Alltrim(RetSqlName("NSZ"))
Local cQryRet    := ""
Local cTabelas   := ""


Default lAutRec  := .F.
Default lAssJur  := .F.
Default lOnlyQtd := .F.

	cTpAssunto := oRequest['tpAssunto']
	cFiltExtr  := oRequest['filtroExtra']
	cTpAsCfg := J293CfgQry('1')

	If lAutRec
		cQrySelect := " SELECT DISTINCT '"+ xFilial('NQ3') +"' FILNQ3, "
		If lAssJur
			cQrySelect += " NSZ001.NSZ_TIPOAS NSZ_TIPOAS "
		Else
			cQrySelect += " NSZ001.NSZ_COD NSZ_COD, "
			cQrySelect += " '"+ cUser +"' USUARIO, "
			cQrySelect += " '"+ cThread +"' SECAO, "
			cQrySelect += " NSZ001.NSZ_FILIAL NSZ_FILIAL "
		EndIf
	Else
		//Pesquisa de processos
		cQrySelect := JSelectFilt(cTarget, lOnlyQtd)
	EndIf

	cQryFrom   := JFromFilter(aSQL, cTarget, cNSZName, cTpAssunto, cCodPart, !Empty(cTpAsCfg), lOnlyQtd,@cTabelas)
	cQryWhere  := JWhereFilter(aSQL, cTarget, cNSZName, cTpAssunto, cFiltExtr, '', aSearchKey,cTabelas, aFilUsr)
	cQryRet    := JUnionFilt(aSQL, cTarget, cNSZName, cTpAssunto, cFiltExtr,;
							cQrySelect, cQryFrom, cQryWhere, cTpAsCfg, lAssJur, lOnlyQtd, aSearchKey, cTabelas, aFilUsr)

	cQryRet := ChangeQuery(cQryRet)
	cQryRet := StrTran(cQryRet,",' '",",''")

Return cQryRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCondicao(aSQL, cNSZName, lTask)
Constroi a clausula WHERE

@param aSQL       - aSQL[1] Campo a ser filtrado
                  - aSQL[2] Clausula WHERE
@param cNSZName   - xFilial("NSZ")
@param lTask      - Indica se vem de tarefas

@return cCondicao - Clausula WHERE com todas as condições concatenadas

@since 12/09/2019
/*/
//-------------------------------------------------------------------
Static Function GetCondicao(aSQL, cNSZName, lTask, cTabelas)
	Local nI        := 0
	Local nC        := 0
	Local nPos      := 0
	Local cCondicao := ""
	Local cCond     := ""
	Local cTab      := ""
	Local aSqlAux   := {}
	
	For nI := 1 to len(aSQL)
		cTab := SubStr(aSQL[nI][1],1,At("_",aSQL[nI][1])-1)
		If !(cTab $ cTabelas)
			If (nPos := aScan(aSQLAux, {|x| x[1] == cTab})) == 0
				aAdd(aSqlAux, {cTab,aSQL[nI][2]})
			Else
				aSqlAux[nPos][2] += ' '+ aSQL[nI][2]
			Endif
			
		ElseIf !("EXISTS" $ aSQL[nI][2])
			aFiltro  := STRToArray(aSQL[nI][2], ".")
			aTrocApe := STRToArray(aFiltro[2], "_")

			For nC := 1 to Len(aFiltro)
				If nC == 1
					cCond := substr(aFiltro[1],1, at(substr(aFiltro[1],-6),aFiltro[1])-1) + aTrocApe[1] + "001"
				Else
					cCond += "." + aFiltro[nC]
				EndIf
			Next nC

			cCondicao += cCond  + " "
		Else
			If !(aSQL[nI][1] $ "NTE_CPART | NTE_SIGLA " .And. lTask)
				cCondicao += JurGtExist(RetSqlName(SubStr(aSQL[nI][1],1,At("_",aSQL[nI][1])-1)) ,aSQL[nI][2]) + " "
			EndIf
		EndIf
	Next

	
	for nI := 1 to len(aSqlAux)
		cCondicao += JurGtExist(RetSqlName(aSqlAux[nI][1]) ,aSqlAux[nI][2]) + " "
	Next

Return cCondicao

//-------------------------------------------------------------------
/*/{Protheus.doc} FormataVal(xValor, cTipo, lRetAspas)
Formata a condição da clausula WHERE de acordo com o tipo do campo

@param xValor     - Conteúdo a ser formatado
@param cTipo      - Tipo do conteúdo (D - data, N - valor, C - caracter,
	                                  M - Memo, COMBO - combo, F3 - consulta padrão)
@param lRetAspas   - Retorna Aspas?
					.T. - adiciona aspas,
					.F. não adiciona aspas
@return cRet - xValor formatado

@since 12/09/2019
/*/
//-------------------------------------------------------------------
Static Function FormataVal(xValor, cTipo, lRetAspas)
	Local cRet := ""

	Do case
	Case cTipo == 'D'
		If ValType(xValor) == "D"
			cRet := CHR(39)+AllTrim(DToS(xValor))+CHR(39)
		Else
			cRet := CHR(39)+AllTrim(xValor)+CHR(39)
		EndIf
	Case cTipo == 'N'
		cRet := AllTrim(STR(xValor))
	Case cTipo == 'C' .Or. cTipo == 'M' .Or. cTipo == 'COMBO' .Or. cTipo == 'F3'
		If lRetAspas
			cRet := CHR(39)+IIf(!Empty(xValor),AllTrim(xValor),xValor)+CHR(39)
		Else
			cRet := IIf(!Empty(xValor),AllTrim(xValor),xValor)
		EndIf
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryInner(aSQL, cNSZName)
Função utilizada para montar a parte do FROM da consulta SQL de acordo
com os campos escolhidos e a tabela padrão informada.
Uso Geral.

@Param  	aSQL
@Param  	cNSZName Tabela padrão, Ex. NSZ, NT4, NTA, NT2 e NT3
@Param  	aManual  Tabelas obrigatórias que devem ser incluídas.
@Return 	cRet Consulta SQL completa.


@since 10/11/13
@version 1.0
	/*/
//-------------------------------------------------------------------
Static Function JQryInner(aSQL, cNSZName)
	Local aSx9       := {}
	Local aTmpTab1   := {}
	Local aTmpTab2   := {}
	local aManual    := {}
	Local aTrocApe   := {}
	Local aFiltro    := {}
	Local cLeft      := ""
	Local cTmp       := ""
	Local nCtr       := 0

	If !("EXISTS" $ aSQL[2])

		aFiltro  := STRToArray(aSQL[2], ".")
		If Len(aFiltro) > 1
			/*
			aManual[1][1] == "NSZ"
			aManual[1][2] == "NSZ001"
			aManual[1][3] == "Nome tabela de Relacionamento da NSZ (Exemplo: "NUQ", "NT9","NSY")"
			aManual[1][4] == "Nome tabela de relacionamento da NSZ + apelido (Exemplo: "NUQ001","NT9001",NSY001)"
			aManual[1][5] == "Obtem o filtro a ser adicionado no Left Join e troca o nome da tabela pelo apelido"
			*/

			aTrocApe := STRToArray(aFiltro[2], "_")

			aAdd(aManual,{"NSZ", "NSZ001", aTrocApe[1], aTrocApe[1] + "001"})

			aSx9 := JURSX9(aManual[1][1],aManual[1][3])

			If  (Len(aSx9) > 0)

				//valida tabela
				cTmpTabela  := Alltrim( RetSqlName(aManual[1][3]) )
				cTmpApelido := AllTrim( aManual[1][4] )

				If (At(cTmpTabela + " " + cTmpApelido,cLeft) == 0 .And. cTmpTabela != cNSZName)//valida a tabela
					aTmpTab1 := STRToArray(aSX9[1][1], '+')
					aTmpTab2 := STRToArray(aSX9[1][2], '+')

					//não é a primeira ocorrência, assim, será preciso adicionar a tabela no sql
					cLeft += " LEFT JOIN "+cTmpTabela+" "+cTmpApelido+" ON " + CRLF
					cLeft += " ("

					For nCtr := 1 to Len(aTmpTab1)
						//Determina o apelido que deve ser usado. A função IIF valida se a tabela é do tipo SA1, onde o nome do campo é A1_ por exemplo
						If IIf(At('_',Left(aTmpTab1[1],3))>0,'S'+Left(aTmpTab1[nCtr],2),Left(aTmpTab1[nCtr],3)) == aManual[1][3]
							cApTab1 := aManual[1][4]
							cApTab2 := aManual[1][2]
						Else
							cApTab1 := aManual[1][2]
							cApTab2 := aManual[1][4]
						Endif

						cLeft += IIF(Left(AllTrim(aTmpTab1[nCtr]),3)==cNSZName,AllTrim(aTmpTab1[nCtr]),cApTab1 + "." + AllTrim(aTmpTab1[nCtr])) + ;
							" = " + IIF(Left(AllTrim(aTmpTab2[nCtr]),3)==cNSZName,AllTrim(aTmpTab2[nCtr]),cApTab2 + "." + AllTrim(aTmpTab2[nCtr])) + " AND "
					Next nCtr

					cLeft := Left(cLeft,Len(cLeft)-5) + CRLF
					cLeft += " AND "+ cTmpApelido +".D_E_L_E_T_ = ' ' " + CRLF

					//-- Relacionamento a partir da exclusividade das tabelas.
					cTmp += " AND " + JQryFilial(aManual[1][1], aManual[1][3], aManual[1][2], aManual[1][4]) //-- cTabPai, cTabFilha, cApPai, cApFilha
					cTmp += " )" + CRLF

					cLeft += cTmp
					cTmp := ''
				EndIf
			EndIf
		EndIf
	EndIf
Return cLeft

//-------------------------------------------------------------------
/*/{Protheus.doc} POST RltPesq
Recebe os dados filtrados na Pesquisa Avançada e gera a exportação - Relatório em Excel

@Return	 .T. - Lógico
@since 27/09/2019
@example [Sem Opcional] POST -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/exportPesquisa
Body: {
		"count":1,
		 "listProcess":[{"ProcessFilial":"D MG 01 ", "ProcessId":"0000000122"}],
		"modeloExp": '0005',
		"background": true
	}
/*/
//-------------------------------------------------------------------
WSMETHOD POST RltPesq WSRECEIVE correcao WSREST JURLEGALPROCESS
Local lRet        := .T.
Local oResponse   := JsonObject():New()
Local oRequest    := JsonObject():New()
Local cBody       := Self:GetContent()
Local lCorrige    := Self:correcao == 'true'
Local lO17        := .F.
Local oJsonRel    := nil
Local aTables     := JURRELASX9('NSZ', .F.)
Local aCorrecao   := {}
Local lXlsx       := .F.
Local cQuery      := ""
Local cNomeArq    := ""
Local cSO         := GetSrvInfo()[2]

	lXlsx := __FWLibVersion() >= '20201009' .And. ;
			 GetRpoRelease() >= '12.1.023' .And. ;
			 PrinterVersion():fromServer() >= '2.1.0'

	oRequest:FromJson(cBody)

	oRequest['cEmpAnt']      := cEmpAnt
	oRequest['cFilAnt']      := cFilAnt
	oRequest['cUserId']      := __CUSERID

	//Busca os campos que irão compor o relatório e preenche o oResponse['aCampos']
	GetCpsRlt(oRequest)

	cNomeArq := AllTrim(StrTran(oRequest['nomeModelo'],'"','')) + '_' 
	cNomeArq += JurTimeStamp(1) + "_exportacao_" + oRequest['cUserId']
	oRequest['cNomeArq'] := JNomeArqSO( cNomeArq, cSO )

	If lXlsx
		oRequest['cNomeArq'] += ".xlsx"
	Else
		oRequest['cNomeArq'] += ".xls"
	EndIf

	// Tratamento para caminho das pastas para diferentes S.O.
	oRequest['cPathSpool'] := JRepDirSO( "\spool\", cSO )
	oRequest['cPathDown']  := JRepDirSO( "\thf\download\", cSO )
	oRequest['cPathArq'] := oRequest['cPathSpool'] + oRequest['cNomeArq']

	If VALTYPE(oRequest['modeloExp']) <> "C"
		oRequest['modeloExp'] := ""
	EndIf

	/*
	 * Verifica se existe a tabela de notificação, 
	 * caso exista, compara com o conteudo da propriedade background, 
	 * caso não, ignora o conteudo da propriedade e define que será em primeiro plano
	*/
	If FWAliasInDic('O12')
		If VALTYPE(oRequest['background']) <> 'L'
			oRequest['background'] := .T.
		EndIf
	Else
		oRequest['background'] := .F.
	EndIf

	Self:SetContentType("application/json")

	If oRequest['count'] > 0

		If lCorrige
			cQuery += " SELECT NQ3_CAJURI, NQ3_FILORI "
			cQuery += " FROM " + RetSqlName("NQ3")
			cQuery += " WHERE NQ3_SECAO = '" + oRequest["thread"] + "' "
			cQuery +=   " AND NQ3_CUSER = '" + __cUserID + "' "

			aCorrecao := JurSQL(cQuery, '*')
		EndIf

		If !oRequest['background']
			//-- Monta Json para o Download
			oResponse['operation'] := "DownloadFile"

			JLPExpRel(oRequest:toJson(),aCorrecao, aTables, lCorrige)

			If File(oRequest['cPathArq'])
				oResponse['export'] := {}
				Aadd(oResponse['export'], JsonObject():New())

				oResponse['export'][1]['namefile'] := JConvUTF8(oRequest['cNomeArq'])
				oResponse['export'][1]['fileurl']  := ""
				oResponse['export'][1]['filedata'] := encode64(DownloadBase(oRequest['cPathArq']))
			Else
				lRet := .F.
			EndIf
		Else
			oResponse['operation'] := "Notification"
			oResponse['message']   := JConvUTF8(STR0055) //"O arquivo será gerado em segundo plano. Quando finalizado, será enviado uma notificação para realizar o download."
			If (lO17 := FWAliasInDic('O17'))
				oJsonRel := J288JsonRel()
				oJsonRel['O17_FILE']   := oRequest['cNomeArq']
				oJsonRel['O17_URLREQ'] := Substr(Self:GetPath(), At('JURLEGALPROCESS',Self:GetPath()))
				oJsonRel['O17_BODY']   := oRequest:toJson() // cBody
				J288GestRel(oJsonRel)
			EndIf

			STARTJOB("JLPExpRel", GetEnvServer(), .F., oRequest:toJson(), ;
					aCorrecao, aTables, lCorrige, Iif(lO17, oJsonRel:toJson(),'') )

		EndIf

	EndIf

	If lRet
		Self:SetResponse(oResponse:toJson())
	Else
		SetRestFault(400,EncodeUTF8(STR0024))//"Arquivo não existe."
	EndIf
	oResponse:fromJson("{}")
	oResponse := NIL

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} JLPExpRel
Função responsavel pela geração do relatório em excel, podendo ser chamada via job

@param cRequest  - string contendo o Json contendo os dados da requisição para ser gerado o excel
@param aCorrecao - Lista dos processos para serem corrigidos
@param aTables   - Lista de tabelas
@param lCorrige  - Verifica se deve corrigir os valores
@param cJsonRel  - String contendo json da gestão de relatórios (O17)
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Function JLPExpRel(cRequest, aCorrecao, aTables, lCorrige, cJsonRel)
Local lRet       := .T.
Local oRequest   := JsonObject():New()
Local cFile2Down := ""
Local lO17       := .F.
Local oJsonRel   := nil
Local cPathArq   := ""
Local cNomeArq   := ""
Local aListInd   := {}
Local nX         := 0

Default aCorrecao := {}
Default aTables   := {}
Default lCorrige  := .F.
Default cJsonRel  := ''

	oRequest:FromJson(cRequest)

	//Caso chamado via StartJob, inicializa o ambiente
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

	oRequest['cIdThredExec'] := "JLPExpRel" + __CUSERID + StrZero(Randomize(1,9999),4)

	// Trava a execução atual
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
					oJsonRel['O17_DESC'] := STR0078 //"Atualizando valores dos indíces"
					oJsonRel['O17_MAX']  := Len(aListInd)
					oJsonRel['O17_MIN']  := 0
					oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN']*100/oJsonRel['O17_MAX'],0)
					J288GestRel(oJsonRel)
				EndIf
				For nX := 1 to len(aListInd)

					JA216AtuAut(aListInd[nX])
					If lO17
						oJsonRel['O17_MIN']  := oJsonRel['O17_MIN']+1
						oJsonRel['O17_PERC'] := Round(oJsonRel['O17_MIN']*100/oJsonRel['O17_MAX'],0)
						J288GestRel(oJsonRel)
					EndIf
				Next nX
			EndIf

			If lO17
				oJsonRel['O17_DESC']   := STR0069 // "Aplicando correção monetária"
				J288GestRel(oJsonRel)
			Endif
			JURA002( aCorrecao, aTables,.T. ,,,,.F. ,,,, oJsonRel)
		EndIf
		

		//-- Chama a Exportação passando a estrutura dos campos
		J108ExpPer(;
			1                      ,;
			oRequest["aCampos"]    ,;
			oRequest["modeloExp"]  ,;
			oRequest["lGar"]       ,;
			oRequest["lSoma"]      ,;
			""                     ,;
			{}                     ,;
			.T.                    ,;
			oRequest["aEspec"]     ,;
			0                      ,;
			oRequest["cPathArq"]   ,;
			.T.                    ,;
			nil                    ,;
			nil                    ,;
			lCorrige               ,;
			oJsonRel               ,;
			oRequest['thread'])

		// Deleta os registros da NQ3
		DelRegFila(oRequest['cUserId'], oRequest['thread'])

		//Caso chamado via StartJob, Finaliza o ambiente
		If oRequest['background']

			lRet := CreatePathDown(oRequest['cPathDown'])

			/*
			* Caso encontrado o arquivo, moverá para a pasta do \thf\download
			* e enviará a notificação para realizar o donwload do arquivo
			* Caso não encontrado, enviará uma notificação informando que não foi possivel gerar o arquivo
			*/
			cPathArq := oRequest["cPathArq"]
			If lRet .and. File(cPathArq)
				
				cNomeArq := oRequest["cNomeArq"]
				cFile2Down  := oRequest['cPathDown']+cNomeArq

				If __COPYFILE( cPathArq , cFile2Down )
					// Cria um registro na tabela O12 - do tipo de Download
					JA280Notify(I18n(STR0056,{oRequest['nomeModelo'],DtoC(dDataBase),Time()}), oRequest['cUserId'], "download"   , '3', "RltPesq", cFile2Down)//'O relatório#1 ficou pronto, clique para fazer o download #2 às #3'
					If lO17
						// Finaliza o arquivo com sucesso na gestão de download
						oJsonRel['O17_DESC']    := STR0070// "Arquivo pronto para download"
						oJsonRel['O17_URLDWN']  := cFile2Down
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
				JA280Notify(I18n(STR0057,{oRequest['nomeModelo']}) , oRequest['cUserId'], "exclamation", '1', "RltPesq")//"Falha na geração do relatório#1"
				If lO17
					// Finaliza o arquivo com erro na gestão de download
					oJsonRel['O17_STATUS'] := "1" // Erro
					J288GestRel(oJsonRel)
				Endif
			Endif

			RpcClearEnv() // Reseta o ambiente
		Endif

		UnLockByName(oRequest["cIdThredExec"], .T., .T.)
	EndIf

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
/*/{Protheus.doc} GetCpsRlt
Função responsavel pela busca dos campos, conforme o modelo passado

@param oRequest - objeto Json contendo os dados da requisição
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Static Function GetCpsRlt(oRequest)
	Local aCampos    := {}

	oRequest['nomeModelo'] := "MODELO_PADRAO"
	oRequest["aEspec"]     := {}

	//-- Inclusão dos campos que serão apresentados no relatório
	If !Empty(oRequest['modeloExp'])

		oRequest['nomeModelo'] := ' "'+Alltrim(Posicione('NQ5',1,xFilial('NQ5')+oRequest['modeloExp'],"NQ5_DESC"))+'"'
		aCampos                := JA108AtCps( , oRequest['modeloExp'])
		//Preenche a variavel aEspec para geração do relatório.
		aEval( aCampos, { |aX| J108FESPE(oRequest["aEspec"],aX,,,aCampos) } )

		//-- Tratamento para apresentar A SOMATORIA DE VALORES
		If VALTYPE(oRequest['lSoma']) <> "L"
			oRequest['lSoma'] := .T.
		EndIf
		//--Tratamento para apresentar as colunas totalizadoras dos valores de garantias
		oRequest['lGar']  := ( aScan(aCampos, { |x| Len(x) > 2 .And. (x[3] == 'NT2_VALOR' .OR. x[3] == 'NT2_VLRATU') }) ) > 0

	ElseIf (oRequest['tpAssunto'] == "006") // Relatório padrão de contratos
		aAdd(aCampos, {'Área Solicitante',     '  -  ( Área Jurídica ) ',      'NRB_DESC',   'NSZ', 'NRB', 'NSZ001', 'NRB001', '03', 'C', "NRB001.NRB_COD = NSZ001.NSZ_CAREAJ",                  'NSZ_DAREAJ', .F., '', ''})
		aAdd(aCampos, {'Solicitante',          '  -  ( Assuntos Juridicos ) ', 'NSZ_SOLICI', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', 'AI', 'C', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Tipo de Contrato',     '  -  ( Tipo de Contrato ) ',   'NY0_DESC',   'NSZ', 'NY0', 'NSZ001', 'NY0001', 'AO', 'C', "",                                                    'NSZ_DESCON', .F., '', ''})
		aAdd(aCampos, {'Contratante',          '  -  ( Pólo Ativo ) ',         'NT9_NOME',   'NT9', 'NT9', 'NT9001', 'NT9001', '16', 'C', "NT9001.NT9_TIPOEN = '1' AND NT9001.NT9_PRINCI = '1'", '',           .F., '', ''})
		aAdd(aCampos, {'Contratada',           '  -  ( Pólo Passivo ) ',       'NT9_NOME',   'NT9', 'NT9', 'NT9002', 'NT9002', '16', 'C', "NT9002.NT9_TIPOEN = '2' AND NT9002.NT9_PRINCI = '1'", '',           .F., '', ''})
		aAdd(aCampos, {'Número do contrato',   '  -  ( Assuntos Juridicos ) ', 'NSZ_NUMCON', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', 'BE', 'C', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Objeto do contrato',   '  -  ( Assuntos Juridicos ) ', 'NSZ_DETALH', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '52', 'M', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Valor do contrato',    '  -  ( Assuntos Juridicos ) ', 'NSZ_VLCONT', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', 'CZ', 'N', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Início da vigência',   '  -  ( Assuntos Juridicos ) ', 'NSZ_DTINVI', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '95', 'D', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Fim da vigência',      '  -  ( Assuntos Juridicos ) ', 'NSZ_DTTMVI', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '96', 'D', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Data de inclusão',     '  -  ( Assuntos Juridicos ) ', 'NSZ_DTINCL', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '12', 'D', "",                                                    '',           .F., '', ''})

		If !oRequest['isRelVencimentos']
			aAdd(aCampos, {'Situacao',             '  -  ( Assuntos Juridicos ) ', 'NSZ_SITUAC', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '55', 'C', "",                                                    '',           .F., '', '1=Em andamento;2=Encerrado'})
			aAdd(aCampos, {'Data de Encerramento', '  -  ( Assuntos Juridicos ) ', 'NSZ_DTENCE', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '59', 'D', "",                                                    '',           .F., '', ''})
		EndIf

		oRequest['lSoma'] := .T.

	Else // Relatório padrão de processos
		aAdd(aCampos, {'Núm Processo',              '  -  ( Instancias do Processo ) ',  'NUQ_NUMPRO', 'NUQ', 'NUQ', 'NUQ001', 'NUQ001', '08', 'C', "NUQ001.NUQ_INSATU = '1'",                            'NUQ_NUMPRO',  .F., '', ''})
		aAdd(aCampos, {'Autor',                     '  -  ( Pólo Ativo ) ',              'NT9_NOME',   'NT9', 'NT9', 'NT9001', 'NT9001', '16', 'C', "NT9001.NT9_TIPOEN = '1' AND NT9001.NT9_PRINCI = '1'", '',           .F., '', ''})
		aAdd(aCampos, {'Réu',                       '  -  ( Pólo Passivo ) ',            'NT9_NOME',   'NT9', 'NT9', 'NT9002', 'NT9002', '16', 'C', "NT9002.NT9_TIPOEN = '2' AND NT9002.NT9_PRINCI = '1'", '',           .F., '', ''})
		aAdd(aCampos, {'Desc. do Correspondente',   '  -  ( Fornecedores ) ',            'A2_NOME',    'NUQ', 'SA2', 'NUQ001', 'SA2001', '04', 'C', "",                                                    'NUQ_DCORRE', .F., '', ''})
		aAdd(aCampos, {'Prognóstico',               '  -  ( Prognóstico) ',              'NQ7_DESC',   'NSZ', 'NQ7', 'NSZ001', 'NQ7001', '03', 'C', "NQ7001.NQ7_COD = NSZ001.NSZ_CPROGN",                  'NSZ_DPROGN', .F., '', ''})
		aAdd(aCampos, {'Data de Inclusão',          '  -  ( Assuntos Juridicos ) ',      'NSZ_DTINCL', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '12', 'D', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Valor Da Causa',            '  -  ( Assuntos Juridicos ) ',      'NSZ_VLCAUS', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '73', 'N', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Valor Envolv',              '  -  ( Assuntos Juridicos ) ',      'NSZ_VLENVO', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '78', 'N', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Valor Provisão',            '  -  ( Assuntos Juridicos ) ',      'NSZ_VLPROV', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', 'C6', 'N', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Situacao',                  '  -  ( Assuntos Juridicos ) ',      'NSZ_SITUAC', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '55', 'C', "",                                                    '',           .F., '', '1=Em andamento;2=Encerrado'})
		aAdd(aCampos, {'Data de Encerramento',      '  -  ( Assuntos Juridicos ) ',      'NSZ_DTENCE', 'NSZ', 'NSZ', 'NSZ001', 'NSZ001', '59', 'D', "",                                                    '',           .F., '', ''})
		aAdd(aCampos, {'Comarca ',                  '  -  ( Comarca ) ',                 'NQ6_DESC',   'NUQ', 'NQ6', 'NUQ001', 'NQ6001', '17', 'C', "NUQ001.NUQ_INSATU = '1'",                             'NUQ_DCOMAR', .F., '', ''})
		aAdd(aCampos, {'Foro / Tribunal ',          '  -  ( Foro / Tribunal )  ',        'NQC_DESC',   'NUQ', 'NQC', 'NUQ001', 'NQC001', '19', 'C', "NUQ001.NUQ_INSATU = '1'",                             'NUQ_DLOC2N', .F., '', ''})
		aAdd(aCampos, {'Vara / Camara ',            '  -  ( Vara / Camara ) ',           'NQE_DESC',   'NUQ', 'NQE', 'NUQ001', 'NQE001', '21', 'C', "NUQ001.NUQ_INSATU = '1'",                             'NUQ_DLOC3N', .F., '', ''})

		oRequest['lSoma'] := .T.
	EndIf

	oRequest['aCampos'] := aCampos

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetRegFila
Função responsavel para informar a fila de processos

@param oRequest - objeto Json contendo os dados da requisição
@param cThread  - número da thread utilizada na fila de impressão

@since 27/07/2020
/*/
//-----------------------------------------------------------------
Static Function SetRegFila(oRequest, cThread)
	Local nTotal     := oRequest['count']
	Local cFilCajuri := ""
	Local cCajuri    := ""
	Local nX         := 0

	Default cThread := SubStr(AllTrim(Str(ThreadId())),1,4)

	oRequest['cThread'] := cThread

	dbSelectArea("NQ3")
	dbSelectArea("NSZ")

	NQ3->( dbSetOrder( 1 ) )
	NSZ->( dbSetOrder( 1 ) )

	For nX := 1 To nTotal
		cFilCajuri := oRequest['listProcess'][nX]["ProcessFilial"]
		cCajuri    := oRequest['listProcess'][nX]["ProcessId"]

		// SetOrder da fila de impressão e assunto jurídico

		// Inclusão do Assunto Jurídico na Fila de Impressão
		If NSZ->(dbSeek(cFilCajuri + cCajuri)) ; // Verifica se o processo existe
			.AND. !NQ3->(dbSeek(xFilial("NQ3") + cFilCajuri + cCajuri + oRequest['cUserId'] + oRequest['cThread'])) //se o registro ja não esta presente naquela seção

			If RecLock('NQ3',.T. )
				NQ3->NQ3_FILIAL := xFilial("NQ3")
				NQ3->NQ3_CAJURI := cCajuri
				NQ3->NQ3_CUSER  := oRequest['cUserId']
				NQ3->NQ3_SECAO  := oRequest['cThread']
				NQ3->NQ3_FILORI := cFilCajuri
				NQ3-> (MsUnlock())
			EndIf
		EndIf
	Next nX

	NQ3->(dbCloseArea())
	NSZ->(dbCloseArea())

Return

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

	cQuery += "DELETE FROM "+RetSqlName("NQ3")+" "
	cQuery += "WHERE NQ3_FILIAL='"+xFilial("NQ3")+"' AND "
	cQuery += "NQ3_CUSER='"+cUser+"' AND "
	cQuery += "NQ3_SECAO='"+cThread+"' "

	lRet := TcSqlExec(cQuery) < 0

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT UpdateDistr
Atualiza o status da distribuição, grava o código do processo criado
e fazer a baixa dos documentos

@since 04/10/2019
@param codDistr   - Codigo da distribuição
@param codProc    - Codigo do processo

@example [Sem Opcional] PUT -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/distr/cod/0000000002/proc/0000000289
/*/
//-------------------------------------------------------------------
	WSMETHOD PUT UpdateDistr PATHPARAM codDistr, codProc WSREST JURLEGALPROCESS

	Local lRet       := .T.
	Local cCodNZZ    := Self:codDistr
	Local cCajuri    := Self:codProc
	Local cLinks     := ""
	Local cErros     := ""
	Local oResponse  := JsonObject():New()

	cLinks := AtuDistr(cCajuri, cCodNZZ)

	If !Empty(cLinks)
		//Reaiza a baixa documentos da distribuição anexando os mesmos ao processo
		cErros := BaixaArqs(cCodNZZ, cLinks, cCajuri)
		Conout(cErros)
		oResponse['doc'] := .T.
	Else
		oResponse['doc'] := .F.
	EndIf

	oResponse['messages'] := JConvUTF8(cErros)
	Self:SetContentType("application/json")

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return lRet

/*/{Protheus.doc} BaixaArqs(cCodDis, cLinks, cCajuri)
Baixa os arquivos relacionados a Distribuição

@param cCodDis    - Código da distribuição
@param cLinks     - Conteúdo do campo NZZ_LINK
@param cCajuri    - Código do processo
@return cErros    - Enventuais erros da baixa

@since 	 04/10/2019
/*/
Static Function BaixaArqs(cCodDis, cLinks, cCajuri)

	Local cUser     := AllTrim( SuperGetMv("MV_JDISUSR", .T., "") )	//Usuário teste distribuicao	aeseletropaulo
	Local cPwd      := AllTrim( SuperGetMv("MV_JDISPWD", .T., "") ) //Senha teste:  jkl_&mx%v@2018	aeseletropaulo
	Local oRest     := Nil
	Local aHeader   := {}
	Local aArquivos := {}
	Local nArq      := 0
	Local nQtdArqs  := 0
	Local cPath     := ""
	Local cNomeArq  := ""
	Local cDownload := ""
	Local nHandle   := ""
	Local lErro     := .F.
	Local cErros    := ""
	Local cTemp     := MsDocPath() + "\distribuições\"

	If !Empty(cUser)
		aHeader   := {"Authorization: Basic " + Encode64(cUser + ":" + cPwd)}
	EndIf

	If !Empty(cLinks)
		//Quando há mais de um link, faz a separação deles quebrando nos pipes de divisão
		aArquivos := StrTokArr( AllTrim(cLinks), "|")
		nQtdArqs  := Len(aArquivos)

		If nQtdArqs > 0
			//Não é necessario passar o host porque o SetPath tera o caminha absoluto
			oRest := FWRest():New("")
			ProcRegua(nQtdArqs)
		EndIf

		For nArq:=1 To nQtdArqs

			Conout( I18n(STR0042, {cValToChar(nArq) + "/" + cValToChar(nQtdArqs), cCodDis}) )		//"Baixando arquivos #1 - Distribuição: #2"

			lErro	 := .F.
			cPath 	 := AllTrim( aArquivos[nArq] )
			cNomeArq := AllTrim( SubStr(cPath, Rat("/", cPath) + 1) )

			cPath    := substr(cpath, 1, Rat("/", cPath))
			cPath    += FWURIEncode(cNomeArq)

			//Verifica se já existe o arquivos
			If !J26aExiNum("NSZ", xFilial("NSZ"), cCajuri, cNomeArq)

				oRest:SetPath(cPath)

				If oRest:Get(aHeader)

					//Download do arquivo
					cDownload := oRest:GetResult()

					//Verifica se diretorio temporario existe
					If !JurMkDir(cTemp)
						lErro := .T.
					EndIf

					//Grava arquivo no servidor
					If !lErro .And. ( nHandle := FCreate(cTemp + cNomeArq, FC_NORMAL) ) < 0
						lErro := .T.
					EndIf

					If !lErro
						If FWrite(nHandle, cDownload) < Len(cDownload)
							lErro := .T.
						EndIf

						If !lErro .And. !FClose(nHandle)
							lErro := .T.
						EndIf
					EndIf

					If lErro
						cErros += " - " + J026aErrAr( FError() ) + " - " + cPath + CRLF
					Else

						//Anexa documento ao processo
						aRetAnx := J026Anexar("NSZ", xFilial("NSZ"), cCajuri, cCajuri, cTemp + cNomeArq)

						If aRetAnx[1]
							FErase(cTemp + cNomeArq)
						Else
							cErros += " - " + aRetAnx[2] + " - " + cPath + CRLF
						EndIf
					EndIf

				Else

					cErros += " - " + oRest:GetLastError() + " - " + cPath + CRLF
				Endif

			EndIf

		Next nArq

		If !Empty(cErros)
			cErros := STR0043 + cCodDis + CRLF + cErros + CRLF		//"Distribuição: "
		EndIf
	EndIf

	FwFreeObj(oRest)

Return cErros

//-------------------------------------------------------------------
/*/{Protheus.doc} GET EmpresaLogada
Pesquisa busca a empresa logada

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/empresaLogada
/*/
//-------------------------------------------------------------------
	WSMETHOD GET EmpresaLogada WSREST JURLEGALPROCESS
	Local oResponse := JsonObject():New()

	Self:SetContentType("application/json")
	oResponse['codEmp'] := cEmpAnt
	oResponse['filLog'] := cFilAnt

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} FilUserList
Busca todas as filiais que o usuário tem acesso.

@since 11/10/2019
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/listFiliaisUser
/*/
//-----------------------------------------------------------------
	WSMETHOD GET FilUserList WSRECEIVE codFil WSREST JURLEGALPROCESS
	Local cCodFil    := Self:codFil
	Local oResponse  := JsonObject():New()
	Local cCodUser   := __CUSERID
	Local nI         := 0
	Local aFilJuri   := {}
	Local nQtdReg    := 0

	oResponse['User'] := {}

	If Empty(cCodFil)
		//Busca de Filiais
		aFilJuri := JURFILUSR( cCodUser, "NSZ" )

		//-- Guarda cada filial que o usuário tem acesso - Trata a string para pegar somente a filial
		If Len(aFilJuri) > 2
			For nI := 1 To Len(aFilJuri[3])
				Aadd(oResponse['User'], JsonObject():New())

				oResponse['User'][nI]['value'] := aFilJuri[3][nI]

				If Empty(aFilJuri[3][nI])
					oResponse['User'][nI]['label'] := ""
				Else
					oResponse['User'][nI]['label'] := JConvUTF8( FWFilialName( , aFilJuri[3][nI] ) )
				EndIf

				nQtdReg := nQtdReg + 1

			Next nX
		EndIf
	Else
		Aadd(oResponse['User'], JsonObject():New())
		oResponse['User'][1]['value'] := cCodFil
		oResponse['User'][1]['label'] := JConvUTF8( FWFilialName( , cCodFil ) )

		nQtdReg := nQtdReg + 1
	EndIf

	oResponse['assJurAccess'] := JConvUTF8( JurTpAsJr(__CUSERID) )
	oResponse['length'] := nQtdReg

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} TpAssuntoJur
 Busca os assuntos juridicos vinculados ao usuario, e que tenham instancia (NUQ)

@since 26/11/2019
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/listTpAssuntoJur
/*/
//-----------------------------------------------------------------
	WSMETHOD GET TpAssuntoJur WSREST JURLEGALPROCESS
	Local oResponse    := JsonObject():New()
	Local nI           := 0
	Local aTpAssunto   := {}
	Local nQtdReg      := 0

	oResponse['TpAssJur'] := {}

	aTpAssunto := JLPTpAsIns()

	For nI := 1 To Len(aTpAssunto)
		Aadd(oResponse['TpAssJur'], JsonObject():New())

		oResponse['TpAssJur'][nI]['value'] := aTpAssunto[nI][1]

		If Empty(aTpAssunto[nI][2])
			oResponse['TpAssJur'][nI]['label'] := ""
		Else
			oResponse['TpAssJur'][nI]['label'] := JConvUTF8( aTpAssunto[nI][2] )
		EndIf

		nQtdReg := nQtdReg + 1

	Next nX


	oResponse['length'] := nQtdReg


	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JLPTpAsIns()
Retornar assuntos juridicos  relacionadas a tabela de instancia
Uso Geral
@return	aTipoAss	- {'001', 'contencioso'}
@since 	26/11/2019
@version 1.0
/*/
//------------------------------------------------------------------
Function JLPTpAsIns()
	Local aTipoAss := {}
	Local aArea    := GetArea()
	Local cQuery   := ''
	Local cAlias   := GetNextAlias()

	cQuery := " SELECT NYB.NYB_COD COD, NYB.NYB_DESC DESCR"
	cQuery += " FROM " + RetSqlName("NYB") + " NYB "
	cQuery +=      " JOIN " + RetSqlName("NYC") + " NYC "
	cQuery +=        " ON( NYC_CTPASJ = NYB_COD )"
	cQuery += " WHERE NYB.NYB_COD IN (" + JurTpAsJr(__CUSERID) + ")"
	cQuery +=       " AND NYC_TABELA = 'NUQ'"
	cQuery +=       " AND NYC.NYC_FILIAL = '" + xFilial("NYC") + "'"
	cQuery +=       " AND NYB.NYB_FILIAL = '" + xFilial("NYB") + "'"
	cQuery +=       " AND NYB.D_E_L_E_T_ = ' '"
	cQuery +=       " AND NYC.D_E_L_E_T_ = ' '"


	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

	While !(cAlias)->( EOF())
		aadd(atipoAss, {(cAlias)->COD, (cAlias)->DESCR})
		(cAlias)->(DbSkip())
	End

	(cAlias)->(dbCloseArea())

	RestArea(aArea)

return aTipoAss

//-------------------------------------------------------------------
/*/{Protheus.doc} GET Historico
Busca o histórico de alterações na tabela de Historico Alteraçoes Processo (O0X)
ou no Embedded Audit Trail

@param codProc   - Código da Filial + Processo
@param dataIni   - Data Inicial a ser filtrada
@param dataFinal - Data Final a ser filtrada
@param usuario   - Código dos Usuários a serem filtrados
@param campo     - Campos Monitorados a serem filtrados

@since 25/11/19

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/process/0000000001/historico
/*/
//-------------------------------------------------------------------
	WSMETHOD GET Historico PATHPARAM codProc WSRECEIVE dataIni, dataFinal, usuario, campo, searchKey WSREST JURLEGALPROCESS

	Local aArea      := GetArea()
	Local cAlias     := GetNextAlias()
	Local cAlisUsr   := GetNextAlias()
	Local nIndexJSon := 0
	Local cCajuri    := Self:codProc
	Local aTabela    := { 'NSZ', 'NSZ' }
	Local cTabLog    := ""
	Local cFilterLog := ""
	Local oResponse  := JsonObject():New()
	Local cAliasLog  := ""
	Local cQuery     := ""
	Local cQryUsr    := ""
	Local cDtIni     := ""
	Local cDtFinal   := ""
	Local cUsuarios  := ""
	Local cCampo     := ""
	Local cColUSER   := ""
	Local cColUSERID := ""
	Local lAudTrail  := .F.
	Local lEncerrado := .F.
	Local cSearchKey := Self:searchKey
	Local nUsuario   := 0
	Local nR         := 0
	Local nO         := 0
	Local cOrdem     := ""
	Local lO0XInDic  := FWAliasInDic("O0X") //Verifica se existe a tabela O0X no Dicionário (Proteção)
	Local cTipoBanco := UPPER(TcGetDb())
	Local aDadosNUV  := {}
	Local aDadosNTC  := {}
	Local lCposNTC   := .F.
	Local lCposNUV   := .F.

	//-- Verifica se os campos existem no dicionário
	If Select("NTC") > 0
		lCposNTC := (NTC->(FieldPos('NTC_USERID')) > 0);
			.AND. (NTC->(FieldPos('NTC_DATA')) > 0);
			.AND. (NTC->(FieldPos('NTC_HORA')) > 0);
			.AND. (NTC->(FieldPos('NTC_USER')) > 0)
	Else
		DBSelectArea("NTC")
		lCposNTC := (NTC->(FieldPos('NTC_USERID')) > 0);
			.AND. (NTC->(FieldPos('NTC_DATA')) > 0);
			.AND. (NTC->(FieldPos('NTC_HORA')) > 0);
			.AND. (NTC->(FieldPos('NTC_USER')) > 0)
		NTC->( DBCloseArea() )
	EndIf

	If Select("NUV") > 0
		lCposNUV := NUV->(FieldPos('NUV_HRALT')) > 0
	Else
		DBSelectArea("NUV")
		lCposNUV := NUV->(FieldPos('NUV_HRALT')) > 0
		NUV->( DBCloseArea() )
	EndIf

	//-- Histórico de Alterações de Processos - Se tem Audit Trail Configurado ou se possui a tabela de log O0X
	If (Findfunction('TCObject')  .AND. TCObject( RetSqlName("NSZ") + "_TTAT_LOG"))
		lAudTrail := .T.
	EndIf

	//Se os parâmetros não forem passados, retorna se existe ou não as tabelas do Embedded Audit Trail
	If Self:usuario == Nil
		oResponse['log'] := lAudTrail

		// Busca lista de usuários para preencher o multeselect da consulta de histórico de alterações.
		if lO0XInDic .AND. !lAudTrail
			Self:SetContentType("application/json")
			oResponse['listusr'] := {}

			cColUSERID := "O0X_USERID"
			cColUSER   := "O0X_USER"
			cQryUsr    := " SELECT        O0X_USERID, O0X_USER "
			cQryUsr    += " FROM " + RetSqlName("O0X") + " "
			cQryUsr    += " WHERE (O0X_KEY = '" + Self:codProc + "') AND (D_E_L_E_T_ = ' ') "
			cQryUsr    += " GROUP BY O0X_USERID, O0X_USER"

			cQryUsr := ChangeQuery(cQryUsr)
			cQryUsr := StrTran(cQryUsr,",' '",",''")
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryUsr), cAlisUsr, .F., .F. )

			While !(cAlisUsr)->(Eof())
				nIndexJSon++
				Aadd(oResponse['listusr'], JsonObject():New())
				oResponse['listusr'][nIndexJSon]['userid'] := (cAlisUsr)->(&(cColUSERID))
				oResponse['listusr'][nIndexJSon]['user']   := (cAlisUsr)->(&(cColUSER))
				(cAlisUsr)->(DbSkip())
			End
			(cAlisUsr)->( DbCloseArea() )
		EndIf

	Else
		cDtIni       := StrTran(Self:dataIni,"-","")
		cDtFinal     := StrTran(Self:dataFinal,"-","")
		cUsuarios    := Self:usuario
		cCampo       := Self:campo

		aUsuario := STRTOKARR( cUsuarios, ',' )
		cUsuarios:=''

		oResponse['log'] := {}

		for nUsuario := 1 to LEN(aUsuario)
			if nUsuario > 1
				cUsuarios += ",'"+ aUsuario[nUsuario] + "'"
			else
				cUsuarios += "'"+ aUsuario[nUsuario] + "'"
			endif
		next

		If lAudTrail
			cTabLog := RetSqlName("NSZ") + "_TTAT_LOG"
		ElseIf  lO0XInDic //Verifica se existe a tabela O0X no Dicionário
			cTabLog := "O0X"
		EndIf

		If !Empty( cTabLog )
			Self:SetContentType("application/json")

			//-- Embedded Audit Trail - API de consulta
			If lAudTrail

				cFilterLog := " TMP_UNQ = '" + cCajuri + "' AND OPERATI = 'U'  "
				If cTipoBanco == "MSSQL"
					If !Empty(cDtIni)
						cFilterLog += " AND CONVERT(VARCHAR , TMP_DTIME , 112) >= CONVERT(VARCHAR , '"+ cDtIni +"' , 121) "
					EndIf
					If !Empty(cDtFinal)
						cFilterLog += " AND CONVERT(VARCHAR , TMP_DTIME , 112) <= CONVERT(VARCHAR , '"+ cDtFinal +"' , 121) "
					EndIf
				Else
					If !Empty(cDtIni)
						cFilterLog += " AND TO_CHAR( TMP_DTIME , 'YYYYMMDD') >= '"+ cDtIni +"' "
					EndIf
					If !Empty(cDtFinal)
						cFilterLog += " AND TO_CHAR( TMP_DTIME , 'YYYYMMDD') <= '"+ cDtFinal +"' "
					EndIf
				EndIf
				If !Empty(cUsuarios)
					cFilterLog += " AND TMP_USER IN (" + cUsuarios + ")"
				EndIf
				If !Empty(cCampo)
					cFilterLog += " AND TMP_FIELD = '"+ cCampo +"' "
				EndIf
				If !Empty(cSearchKey)
					cFilterLog += " AND TMP_FIELD LIKE '%"+ cSearchKey +"%' "
				EndIf
				cOrdem := "TMP_DTIME DESC"
				cAliasLog := FwATTViewLog( aTabela, cFilterLog, cOrdem )

				If !Empty( cAliasLog )
					( cAliasLog )->( DbGotop() )
					While !( cAliasLog )->( Eof() )
						Aadd(oResponse['log'], JsonObject():New())
						aTail(oResponse['log'])['user']      := AllTrim(( cAliasLog )->TMP_USER)
						aTail(oResponse['log'])['date']      := StrTran(substr(AllTrim(( cAliasLog )->TMP_DTIME),1,10),'-','')
						aTail(oResponse['log'])['time']      := Substr(AllTrim(( cAliasLog )->TMP_DTIME), 12, 8)
						aTail(oResponse['log'])['field']     := AllTrim(( cAliasLog )->TMP_FIELD)
						aTail(oResponse['log'])['fieldName'] := JConvUTF8(GetSx3Cache(AllTrim(( cAliasLog )->TMP_FIELD),"X3_TITULO"))
						aTail(oResponse['log'])['oldData']   := AllTrim(( cAliasLog )->TMP_COLD)
						aTail(oResponse['log'])['newData']   := AllTrim(( cAliasLog )->TMP_CNEW)
						aTail(oResponse['log'])['tipo']      := '1'
						( cAliasLog )->(DbSkip())
					EndDo
				EndIf

				//-- Fechando alias da API de consulta ao Embedded Audit Trail
				FwATTDropLog(cAliasLog)

				//-- Tabela O0X
			Else
				cQuery := " SELECT O0X_CODIGO, O0X_USER, O0X_DATA, O0X_HORA FROM " + RetSqlName('O0X')
				cQuery += " WHERE O0X_KEY = '" + cCajuri + "'"
				If !Empty(cDtIni)
					cQuery += " AND O0X_DATA >= '"+ cDtIni +"' "
				EndIf
				If !Empty(cDtFinal)
					cQuery += " AND O0X_DATA <= '"+ cDtFinal +"' "
				EndIf
				If !Empty(cUsuarios)
					cQuery += " AND O0X_USER IN ("+ cUsuarios +") "
				EndIf
				cQuery += " ORDER BY O0X_DATA DESC, O0X_HORA DESC, O0X_USER DESC"

				cQuery := ChangeQuery(cQuery)
				cQuery := StrTran(cQuery,",' '",",''")
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

				While !(cAlias)->(Eof())
					nIndexJSon++
					Aadd(oResponse['log'], JsonObject():New())
					oResponse['log'][nIndexJSon]['user']      := (cAlias)->O0X_USER
					oResponse['log'][nIndexJSon]['date']      := (cAlias)->O0X_DATA
					oResponse['log'][nIndexJSon]['time']      := (cAlias)->O0X_HORA
					(cAlias)->(DbSkip())
				End

				(cAlias)->( DbCloseArea() )
			EndIf


		EndIf

		//-- Busca dados de histórico de justificativas alterações caso o processo esteja encerrado
		aDadosNUV  := JSituacProc( cCajuri )
		lEncerrado := aDadosNUV[1]

		If lEncerrado .AND. Len(aDadosNUV[2]) > 0
			For nR := 1 To Len(aDadosNUV[2])
				Aadd(oResponse['log'], JsonObject():New())
				aTail(oResponse['log'])['user']        := ADADOSNUV[2][nR][1]
				aTail(oResponse['log'])['date']        := DTOS(ADADOSNUV[2][nR][2])
				aTail(oResponse['log'])['description'] := JConvUTF8(ADADOSNUV[2][nR][3])
				aTail(oResponse['log'])['time']        := ADADOSNUV[2][nR][4]
				aTail(oResponse['log'])['tipo']        := '2'
			Next nR
		EndIf

		//-- Busca dados de histórico de alteração de correspondentes
		aDadosNTC := JAltCorre( cCajuri )

		If Len(aDadosNTC) > 0
			For nO := 1 To Len(aDadosNTC)
				Aadd(oResponse['log'], JsonObject():New())
				aTail(oResponse['log'])['user']        := aDadosNTC[nO][1]
				aTail(oResponse['log'])['date']        := DTOS(aDadosNTC[nO][2])
				aTail(oResponse['log'])['description'] := JConvUTF8(aDadosNTC[nO][3])
				aTail(oResponse['log'])['time']        := aDadosNTC[nO][4]
				aTail(oResponse['log'])['tipo']        := '3'
			Next nO
		EndIf

		//-- Ordena os registros por data e hora
		If lCposNTC .AND. lCposNUV
			asort(oresponse["log"],,,{ |x,y| x["date"] + x["time"] > y["date"] + y["time"] })
		EndIf

	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

	aSize(aDadosNUV, 0)
	aSize(aDadosNTC, 0)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST VldCNJ
Faz a validação do número do processo (CNJ)
e retorna o cadastro De/Para de Comarcas

@return aDadosVal
		aDadosVal[1] - UF do De/Para
		aDadosVal[2] - Comarca do De/Para
		aDadosVal[3] - Foro do De/Para
		aDadosVal[4] - Vara do De/Para
		aDadosVal[5] - CNJ Valido?
		aDadosVal[6] - Mensagem CNJ inválido
		aDadosVal[7] - CNJ número verificador inválido, continuar?

@since  29/11/2019

@example [Sem Opcional] POST -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/validNumPro
/*/
//-------------------------------------------------------------------
	WSMETHOD POST VldCNJ WSREST JURLEGALPROCESS

	Local oResponse   := JsonObject():New()
	Local oRequest    := JsonObject():New()
	Local cBody       := Self:GetContent()
	Local cNumPro     := ""
	Local cNatureza   := ""
	Local cTpAssunto  := ""
	Local aDadosVal   := {}


	FWJsonDeserialize(cBody,@oRequest)

	cNumPro    := oRequest['numPro']
	cNumPro := StrTran(cNumPro, "-", "")
	cNumPro := StrTran(cNumPro, ".", "")

	cNatureza  := oRequest['natureza']
	cTpAssunto := oRequest['tpAssunto']

	//Validação de CNJ e dados do De/Para
	aDadosVal := JU183VNPRO( cNumPro, cNatureza, cTpAssunto )

	Self:SetContentType("application/json")

	oResponse['uf']       := aDadosVal[1]
	oResponse['comarca']  := aDadosVal[2]
	oResponse['foro']     := aDadosVal[3]
	oResponse['vara']     := aDadosVal[4]
	oResponse['valid']    := aDadosVal[5]
	oResponse['message']  := aDadosVal[6]
	oResponse['continue'] := aDadosVal[7]

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
 /*/{Protheus.doc} getPartCont
	Função responsável por trazer a parte contrária do processo

	@param cCajuri codigo do assunto juridico a ser pesquisado
	@return cPartCont - Parte contrária
	@since 07/01/2020
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getPartCont(cCajuri)
	Local cPartCont   := ""
	Local nCount      := 0
	Local cAutorPrinc := ""
	Local cReuPrinc   := ""
	Local cEntAutor   := ""
	Local cEntReu     := ""
	Local aNT9        := JWsLpGtNt9(cCajuri)

	If !Empty(aNT9)
		//passa por todos os envolvidos do processo para pegar o autor e o réu e sua entidade
		For nCount := 1 to Len(aNT9)
			If (JConvUTF8(aNT9[nCount][4])) == '1' //é principal ?
				If JConvUTF8(aNT9[nCount][11]) == '1'//Polo ativo - Autor?
					cAutorPrinc := aNT9[nCount][5]
					cEntAutor   := aNT9[nCount][3]
				ElseIf JConvUTF8(aNT9[nCount][11]) == '2'//Polo passivo - Reu?
					cReuPrinc := aNT9[nCount][5]
					cEntReu   := aNT9[nCount][3]
				EndIf
			EndIf
		Next
	EndIf

	If cEntAutor == "SA1"
		cPartCont := cReuPrinc
	ElseIf cEntReu == "SA1"
		cPartCont := cAutorPrinc
	else
		cPartCont := "-"
	EndIf

Return JConvUTF8(cPartCont)

//-----------------------------------------------------------------
/*/{Protheus.doc} StatusSolic
Consulta o follow-up por tipo de aprovação e resultado a partir do código do workflow do fluig.

@since 14/01/2020
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/solicitation/170
/*/
//-----------------------------------------------------------------
	WSMETHOD GET StatusSolic PATHPARAM codWf WSREST JURLEGALPROCESS
	Local oResponse := JsonObject():New()
	Local cCodWf    := Self:codWf

	oResponse['status'] := J94FTarFw(xFilial("O0W"), cCodWf, "6", "4")

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET ExportPDF
Exporta o resumo do processo em PDF

@param codProc   - Código do Processo
@param codFil    - Filial do processo 
@param tipoAssjur - tipo do assunto juridico do processo, utilizado ao realizar a geração do relatório

@since 15/01/20

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/exportpdf/0000000001?codFil='01'&tipoAssjur=001
/*/
//-------------------------------------------------------------------
	WSMETHOD GET ExportPDF PATHPARAM codProc WSRECEIVE codFil, tipoAssjur WSREST JURLEGALPROCESS
	Local aArea     := GetArea()
	Local aAreaNSZ  := NSZ->( GetArea() )
	Local aAreaNQ3  := NQ3->( GetArea() )
	Local cThread   := SubStr(AllTrim(Str(ThreadId())),1,4)
	Local cCajuri   := AllTrim(Self:codProc)
	Local cUser     := __CUSERID
	Local cFilPro   := Self:codFil
	Local cCfgRel   := AllTrim(JurGetDados("NQR", 2, xFilial("NQR") + "JURR095", "NQR_COD")) //NQR_FILIAL+ NQR_NOMRPT //configuração de relatório padrao de assunto juridico
	Local cParams   := cUser + ";" + cThread + ";S;T;N;0;N;01/01/1900;31/12/2050;S;S;" + cFilPro + ";N;;"
	Local cCaminho  := "\spool\"
	Local cNomerel  := JurTimeStamp(1) + "_relatorioprocesso_" + cCajuri + "_" + cUser
	Local oResponse := JsonObject():New()
	Local cTipoAss  := Self:tipoAssjur
	Local aPictures := {}

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cCaminho := StrTran(cCaminho,"\","/")
	Endif

	// SetOrder da fila de impressão e assunto jurídico
	dbSelectArea("NSZ")

	NSZ ->(DBSetOrder(1))//NSZ_FILIAL + NSZ_COD
	// Inclusão do Assunto Jurídico na Fila de Impressão
	If NSZ->(dbSeek(cFilPro + cCajuri))
		dbSelectArea("NQ3")
		NQ3->( dbSetOrder( 1 ) )//NQ3_FILIAL + NQ3_FILORI + NQ3_CAJURI + NQ3_CUSER + NQ3_SECAO
		If !NQ3->(dbSeek(xFilial("NQ3")+ cFilPro + cCajuri + cUser + cThread)) // Verifica se o processo existe E se o registro ja não esta presente naquela seção
			If RecLock('NQ3',.T. )
				NQ3->NQ3_FILIAL := xFilial("NQ3")
				NQ3->NQ3_CAJURI := cCajuri
				NQ3->NQ3_CUSER  := cUser
				NQ3->NQ3_SECAO  := cThread
				NQ3->NQ3_FILORI := cFilPro
				NQ3-> (MsUnlock())
			EndIf
		EndIf
		NQ3->(dbCloseArea())
	EndIf
	NSZ->(dbCloseArea())

	RestArea(aAreaNQ3)
	RestArea(aAreaNSZ)
	RestArea(aArea)

	//Chama a função para gerar o relatório
	If cTipoAss == '008'
		JURRel095S(cUser, cThread, "", .F. , cNomerel, cCaminho)
	ElseIf cTipoAss == '011'
		aPictures := TmpPicture( cUser, cThread, 1 )
		JURR095M(cUser, cThread, cCaminho, cNomerel)
		aPictures := TmpPicture( cUser, cThread, 2 )
	Else
		JURRel095(cTipoAss, cUser, cThread, cParams, cCfgRel, .F. , cNomerel, cCaminho)
	EndIf

	// Deleta os registros da NQ3
	DelRegFila(cUser, cThread)

	//-- Monta Json para o Download
	Self:SetContentType("application/json")
	oResponse['operation'] := "ExportProcess"
	oResponse['export']    := {}
	Aadd(oResponse['export'], JsonObject():New())

	oResponse['export'][1]['namefile'] := JConvUTF8(cNomerel + ".pdf")
	oResponse['export'][1]['filedata'] := encode64(DownloadBase(cCaminho + cNomerel + ".pdf"))

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listFavorite
Lista os favoritos do processo.

@param page       - Numero da pagina
@param pageSize   - quantidade de registros que será apresentada
@param tipoAssjur - tipo do assunto juridico do processo, utilizado ao realizar a geração do relatório

@since 15/01/20

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/listFavorite?tipoAssjur=001
/*/
//-------------------------------------------------------------------
WSMETHOD GET listFavorite WSRECEIVE page, pageSize, tipoAssjur WSREST JURLEGALPROCESS
Local oResponse    := JSonObject():New()
Local cAlias       := GetNextAlias()
Local cQuery       := ''
Local cDesc        := ''
Local cAssProd     := ''
Local nIndexJSon   := 0
Local nQtdReg      := 0
Local nQtdRegIni   := 0
Local nQtdRegFim   := 0
Local aRet         := {}
Local cTipoAss     := Self:tipoAssjur
Local nPage        := Self:page
Local nPageSize    := Self:pageSize

Default nPage      := 1
Default nPageSize  := 10

	nQtdRegIni := ((nPage-1) * nPageSize)+1
	nQtdRegFim := (nPage * nPageSize)

	cTipoAss := "'" + cTipoAss + "'"

	If cTipoAss == "'001'"
		cTipoAss := "'001','002','003','004'"
	EndIf

	cTipoAss := WsJGetTpAss(cTipoAss)
	cAssProd := cfgTLegal()

	If !Empty(cTipoAss) .AND. !Empty(cAssProd)
		cTipoAss += "," + cAssProd
	Else
		cTipoAss += cAssProd
	EndIf

	cQuery := QryFavoritos(cTipoAss, nQtdRegIni,nQtdRegFim, .F.)
	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse['listFavorite'] := {}

	while (cAlias)->(!Eof())
		aRet := J269QryFav( (cAlias)->FILCAJ, (cAlias)->CAJURI )
		cDesc := ''
		nQtdReg++
		nIndexJSon++

		If ('005' $ cTipoAss)
			If !Empty(aRet[5])
				cDesc += AllTrim( aRet[5] ) // Tipo
			Else
				cDesc += STR0062 //"Tipo Não definido"
			Endif

			cDesc +=  " / " + cValToChar(Val(aRet[2])) //Cajuri

			If !(Empty(aRet[6]))
				cDesc += " / " + cValToChar(Val(AllTrim( aRet[6] ) ) ) // Código Fluig
			EndIf
		ElseIf ('008' $ cTipoAss .AND. Len(aRet) > 6)
			cDesc := aRet[7]
		ElseIf ('011' $ cTipoAss .AND. Len(aRet) > 7)
			cDesc := aRet[7];
				+ if( !Empty( aRet[8]), " - " + aRet[8],'' );
				+ if( !Empty( aRet[9]), " - " + aRet[9],'' )
		Else
			cDesc   := AllTrim(aRet[3]) +" x "+ AllTrim(aRet[4])
		EndIf

		Aadd(oResponse['listFavorite'], JsonObject():New())

		oResponse['listFavorite'][nIndexJSon]['pk']           := Encode64((cAlias)->(FILIAL + FILCAJ + CAJURI) + __cUserID)
		oResponse['listFavorite'][nIndexJSon]['filial']       := (cAlias)->FILCAJ
		oResponse['listFavorite'][nIndexJSon]['cajuri']       := JConvUTF8((cAlias)->CAJURI)
		oResponse['listFavorite'][nIndexJSon]['partes']       := JConvUTF8(cDesc)
		oResponse['listFavorite'][nIndexJSon]['fav']          := "favorito"
		(cAlias)->(DbSkip())
	endDo
	(cAlias)->(dbCloseArea())


	cAlias := GetNextAlias()
	cQuery := QryFavoritos(cTipoAss,,, .T.)
	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse['length']  := (cAlias)->TOTAL
	oResponse['hasNext'] := (cAlias)->TOTAL > nQtdRegFim

	(cAlias)->(dbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET QryFavoritos
Retorna uma query referente aos favoritos do processo.

@param cTipoAss   - Tipo de Assunto
@param nQtdRegIni - Registro inicial para busca
@param nQtdRegFim - Registro final para busca
@param lCount     - Se irá apenas para contar ou não

@return cQuery
@since 09/09/20
/*/
//-------------------------------------------------------------------
Static Function QryFavoritos(cTipoAss, nQtdRegIni,nQtdRegFim, lCount)
	Local cQuery := ""

	If !lCount
		cQuery += " SELECT "
		cQuery += "     FILIAL, FILCAJ, CAJURI "
		cQuery += " FROM ( "
	Endif

	cQuery += "     SELECT "

	If !lCount
		cQuery += "         O0V.O0V_FILIAL FILIAL, "
		cQuery += "         O0V.O0V_FILCAJ FILCAJ, "
		cQuery += "         O0V.O0V_CAJURI CAJURI, "
		cQuery += "         DENSE_RANK() OVER ( ORDER BY O0V.R_E_C_N_O_ ) RANK "
	Else
		cQuery += "         Count(O0V.O0V_CAJURI) TOTAL"
	Endif

	cQuery += "     FROM "+ RetSqlName('O0V') + " O0V  "
	cQuery += "         Inner JOIN "+ RetSqlName('NSZ') + " NSZ  ON "
	cQuery += "             (NSZ.NSZ_FILIAL = O0V.O0V_FILCAJ  AND NSZ.NSZ_COD = O0V.O0V_CAJURI "
	cQuery += "             and NSZ.NSZ_TIPOAS IN (" + cTipoAss + " ) "
	cQuery += "             AND NSZ.D_E_L_E_T_ = ' ' ) "
	cQuery += "     WHERE "
	cQuery += "         O0V.O0V_USER = '" + __cUserID + "' "
	cQuery += "         AND O0V.D_E_L_E_T_ = ' ' "

	If !lCount
		cQuery += "     ) TMP "
		cQuery += " WHERE "
		cQuery += "     RANK Between "+cValToChar(nQtdRegIni)+" and "+cValToChar(nQtdRegFim)+" "
	Endif

return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JSituacProc
Verifica se o processo esta encerrado e busca dados na tabela de
historico de alterações de processo encerrado (NUV)

@param  cChaveProc - Chave do processo ( Filial + Cajuri )
@return lEncerrado - boolean -  Indica se o processo esta encerrado
		aDadosNUV  - Array
		aDadosNUV[1] -  Usuário       - Nome do usuário que realizou a alteração 
		aDadosNUV[2] -  Data          - Data em que foi realizada a alteração
		aDadosNUV[3] -  Justificativa - justificativa da alteração
		aDadosNUV[4] -  Hora          - Hora em que foi realizada a alteração

@since 28/05/2020
/*/
//-------------------------------------------------------------------
Static Function JSituacProc( cChaveProc )

	Local aAreaNUV   := GetArea()
	Local cQueryNUV  := ""
	Local cAliasNUV  := ""
	Local aDadosNUV  := {}
	Local lCpoHora   := .F.
	Local lEncerrado := .F.

	//-- Verifica se o campo NUV_HRALT existe no dicionário
	If Select("NUV") > 0
		lCpoHora := NUV->(FieldPos('NUV_HRALT')) > 0
	Else
		DBSelectArea("NUV")
		lCpoHora := NUV->(FieldPos('NUV_HRALT')) > 0
		NUV->( DBCloseArea() )
	EndIf

	//--Verifica se o processo esta encerrado
	DbSelectArea("NSZ")
	NSZ->(DbSetOrder(1)) // NSZ_FILIAL+NSZ_COD

	If NSZ->(Dbseek( cChaveProc ))
		lEncerrado := IIF( NSZ->NSZ_SITUAC == '2', .T., .F. )


	EndIf
	NSZ->(DbCloseArea())

	//-- Se o processo estiver encerra busca dados na NUV
	If lEncerrado

		cAliasNUV := GetNextAlias()

		cQueryNUV := " SELECT R_E_C_N_O_ RECNONUV "

		cQueryNUV += " FROM " + RetSqlName("NUV") + " NUV "
		cQueryNUV += " WHERE NUV_FILIAL || NUV_CAJURI ='" + cChaveProc + "' "
		cQueryNUV += " AND NUV.D_E_L_E_T_ = ' ' "

		cQueryNUV := ChangeQuery(cQueryNUV)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryNUV), cAliasNUV, .F., .T.)

		DbSelectArea("NUV")
		NUV->( dbSetOrder( 1 ) ) // NUV_FILIAL+NUV_COD
		NUV->( DbGoTop() )

		While (cAliasNUV)->(!Eof())
			NUV->( DbGoTo( (cAliasNUV)->RECNONUV ) )
			aAdd( aDadosNUV, { NUV->NUV_USUALT, NUV->NUV_DTALT, ALLTRIM( NUV->NUV_JUSTIF ), IIF( lCpoHora, ALLTRIM(NUV->NUV_HRALT), "" ) } )
			(cAliasNUV)->(DbSkip())
		End

		NUV->(DbCloseArea())
		(cAliasNUV)->(DbCloseArea())
	EndIf

	RestArea(aAreaNUV)

Return { lEncerrado , aDadosNUV }

//-------------------------------------------------------------------
/*/{Protheus.doc} JAltCorre
Busca dados na tabela de historico de alterações correspondente (NTC)

@param  cChaveProc - Chave do processo ( Filial + Cajuri )
@return aDadosNTC - Array
		aDadosNTC[1] - Usuário - Nome do usuário que realizou a alteração
		aDadosNTC[2] - Data    - Data em que foi realizada a alteração
		aDadosNTC[3] - Data    - Motivo da alteração
		aDadosNTC[4] - Hora    - Hora em que foi realizada a alteração
@since 28/05/2020
/*/
//-------------------------------------------------------------------
Static Function JAltCorre( cChaveProc )

	Local aAreaNTC   := GetArea()
	Local cQueryNTC  := ""
	Local cAliasNTC  := ""
	Local aDadosNTC  := {}
	Local lNewCpos   := .F.

	//-- Verifica se os campos existem no dicionário
	If Select("NTC") > 0
		lNewCpos := (NTC->(FieldPos('NTC_USERID')) > 0);
			.AND. (NTC->(FieldPos('NTC_DATA')) > 0);
			.AND. (NTC->(FieldPos('NTC_HORA')) > 0);
			.AND. (NTC->(FieldPos('NTC_USER')) > 0)
	Else
		DBSelectArea("NTC")
		lNewCpos := (NTC->(FieldPos('NTC_USERID')) > 0);
			.AND. (NTC->(FieldPos('NTC_DATA')) > 0);
			.AND. (NTC->(FieldPos('NTC_HORA')) > 0);
			.AND. (NTC->(FieldPos('NTC_USER')) > 0)
		NTC->( DBCloseArea() )
	EndIf

	//-- Busca dados do histórico de alteração de correspondente - NTC
	cAliasNTC := GetNextAlias()

	cQueryNTC := " SELECT R_E_C_N_O_ RECNONTC "
	cQueryNTC += " FROM " + RetSqlName("NTC") + " NTC "
	cQueryNTC += " WHERE NTC_FILIAL || NTC_CAJURI ='" + cChaveProc + "' "
	cQueryNTC += " AND NTC.D_E_L_E_T_ = ' ' "

	cQueryNTC := ChangeQuery(cQueryNTC)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryNTC), cAliasNTC, .F., .T.)

	DbSelectArea("NTC")
	NTC->( dbSetOrder( 1 ) ) // NTC_FILIAL+NTC_COD
	NTC->( DbGoTop() )

	While (cAliasNTC)->(!Eof())
		NTC->( DbGoTo( (cAliasNTC)->RECNONTC ) )

		If lNewCpos
			aAdd( aDadosNTC, { NTC->NTC_USER, NTC->NTC_DATA, ALLTRIM( NTC->NTC_MOTIVO ), ALLTRIM(NTC_HORA) } )
		EndIf
		(cAliasNTC)->(DbSkip())
	End

	NTC->(DbCloseArea())
	(cAliasNTC)->(DbCloseArea())
	RestArea(aAreaNTC)

Return aDadosNTC

//-----------------------------------------------------------------
/*/{Protheus.doc} getSequencial
Busca o proximo sequencial disponivel na tabela SA1

@since 28/05/20
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/getSequencial
/*/
//-----------------------------------------------------------------
	WSMETHOD GET getSequencial WSRECEIVE searchKey WSREST JURLEGALPROCESS
	Local oResponse := JsonObject():New()
	Local aRet := getSequencial(self:searchKey)

	oResponse['sequencial'] := aRet[1]
	oResponse['loja'] := aRet[2]

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getSequencial
Busca o sequencial da tabela.
@param cTabela - tabela para buscar o próximo código

@since 28/05/20

/*/
//-------------------------------------------------------------------
static function getSequencial(cTabela)
Local aArea       := GetArea()
Local cAlias      := GetNextAlias()
Local cQuery      := ''
local lEncontrou  := .F.
local nTamanho    := 0
Local aRet        := {'',''}

Default cTabela := 'SA1'

	nTamanho := FWTamSX3(substr(cTabela,2,2)+"_COD")[1]
	aRet[1]  := StrZero(1,nTamanho)
	aRet[2]  := StrZero(1,FWTamSX3(substr(cTabela,2,2)+"_LOJA")[1])

	// Pega o Recno do próximo registro
	cQuery := "SELECT (MAX(R_E_C_N_O_)+1) SEQUENCIAL FROM " + RetSqlName(cTabela)
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
		If (cAlias)->(!Eof())
			aRet[1] := 	StrZero(((cAlias)->SEQUENCIAL) +1, nTamanho)
		EndIf
	(cAlias)->(DbCloseArea())

	//Valida se já existe registro com esta chave
	dbSelectArea(cTabela)
		(cTabela)->( dbSetOrder( 1 ) ) // FILIAL + COD + LOJA
	
		While !lEncontrou
			If (cTabela)->( dbSeek( xFilial(cTabela) + aRet[1] + aRet[2]) )
				aRet[1] := StrZero(Val(aRet[1]) +1, nTamanho)
			else
				lEncontrou := .T.
			EndIf
		End
	(cTabela)->(dbCloseArea())

	RestArea(aArea)

return aRet


//-----------------------------------------------------------------
/*/{Protheus.doc} GetSeqNXY
Busca o proximo sequencial disponivel na tabela NXY.

@param codProc - Código do processo
@since 08/06/2020
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/getSeqNXY/0000000001
/*/
//-----------------------------------------------------------------
WSMETHOD GET SeqNXY PATHPARAM codProc WSREST JURLEGALPROCESS
	Local oResponse := JsonObject():New()
	Local cCodProc   := self:codProc

	oResponse['seq'] := GetSeqNXY(cCodProc)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GetSeqNXY
Busca o sequencial da tabela NXY.

@param codProc - Código do processo
@return - cSeqnxy - String com o codigo sequencial (NXY_COD)
@since 08/06/20
/*/
//-------------------------------------------------------------------
Static function GetSeqNXY(cCodProc)
Local aArea      := GetArea()
Local cTabela    := 'NXY'
Local lEncontrou := .F.
Local cFilReg    := xFilial('NXY')
Local nTamanho   := FWTamSX3("NXY_COD")[1]
Local cSeqnxy    := StrZero(1, nTamanho)

	DbSelectArea(cTabela)
	NXY->( dbSetOrder( 2 ) ) // NXY_FILIAL+NXY_COD+NXY_CAJURI

	While !lEncontrou
		If NXY->( dbSeek( cFilReg + cSeqnxy + cCodProc ) )
			cSeqnxy := StrZero(Val(cSeqnxy) +1, nTamanho)
		Else
			lEncontrou := .T.
		EndIf
	End
	NXY->(DbCloseArea())

	RestArea(aArea)

return cSeqnxy

//-------------------------------------------------------------------
/*/{Protheus.doc} distribuicoes
Efetua o tembamento em lote das distribuições

@return result - 'Processando' Indica que o tombamento será executado em segundo plano

@since 10/08/2020

@example POST -> http://localhost:12173/rest/JURLEGALPROCESS/distribuicoes
Body ->:  {
 	"distribuicoes": [
 		["pk do registro", "número do processo"],
 		["yyyyyy", "5002949-03.2018.8.13.0693"],
 		["zzzzzz", "5002949-03.2018.8.13.0693"]
 	],
 	"modelo": [
 		["Campo", "Tipo", "Valor", "Modelo"],
 		["NSZ_HCITAC", "C", "2", "NSZMASTER"],
 		["NT9_ENTIDA", "C", "SA1", "NT9DETAIL"],
 		["NT9_CODENT", "C", "JLT00101", "NT9DETAIL"],
 		["NT9_DENTID", "C", "Clientes", "NT9DETAIL"],
 		["NT9_TIPOCL", "C", "1", "NT9DETAIL"],
 		["NT9_TIPOEN", "C", "2", "NT9DETAIL"],
 		["NT9_CTPENV", "C", "02", "NT9DETAIL"],
 		["NT9_DTPENV", "C", "REU", "NT9DETAIL"],
 		["NT9_CEMPCL", "C", "JLT001", "NT9DETAIL"],
 		["NT9_LOJACL", "C", "01", "NT9DETAIL"],
 		["NT9_NOME", "C", "LEGALTASK 001", "NT9DETAIL"],
 		["NT9_TIPOP", "C", "1", "NT9DETAIL"],
 		["NT9_RESP", "C", "1", "NT9DETAIL"],
 		["NT9_ENDECL", "C", "LEGALTASK", "NT9DETAIL"],
 		["NT9_ESTADO", "C", "SP", "NT9DETAIL"],
 		["NUQ_INSATU", "C", "1", "NUQDETAIL"],
 		["NUQ_CNATUR", "C", "001", "NUQDETAIL"]
 	]
 }
/*/
//-------------------------------------------------------------------
	WSMETHOD POST distribuicoes WSREST JURLEGALPROCESS
	Local oRequest   := JsonObject():New()
	Local oResponse  := JsonObject():New()
	Local cBody      := Self:GetContent()
	Local aDistri    := {}
	Local aModelo    := {}
	Local aTread     := {}
	Local nThread    := 0
	Local nReg       := 0
	Local nQtd       := 0
	Local cAssunto   := ""
	Local cTpAudi    := ""
	Local cRespAudi  := ""
	Local lVincula   := .F.
	Local cFilOrigem := ""
	Local cCodProcOri:= ""

	oRequest:fromJson(cBody)
	
	cAssunto    := oRequest['tipoAssunto']
	cTpAudi     := oRequest['tipoAudiencia']
	cRespAudi   := oRequest['respAudiencia']
	aDistri     := oRequest['distribuicoes']
	aModelo     := oRequest['detModelo']
	lVincula    := oRequest['isVinculo']
	cFilOrigem  := oRequest['filialAssuntoOrigem']
	cCodProcOri := oRequest['codAssuntoOrigem']

	For nReg := 1 To len(aDistri)

		Importando(Decode64(aDistri[nReg][1]))

		nQtd ++
		Aadd(aTread, aDistri[nReg])

		// Abre até 4 Treads
		If (nQtd >= len(aDistri) / 4) .Or. (nReg == len(aDistri) )

			nThread ++
			STARTJOB("ImpDistr", GetEnvServer(), .F., ;
				aModelo, aTread, __CUSERID, cEmpAnt, cFilAnt, nThread, cAssunto, cTpAudi, cRespAudi, lVincula, cFilOrigem, cCodProcOri)

			aTread := {}
			nQtd := 0
		EndIf
	Next nReg

	oResponse['result'] := 'Processando'
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpDistr( aModelo, aDistr)
Importa a tista de distribuições

@param aModelo    - Array com a relação de campos e valores do template de processo
@param aDistr     - Código do processo
@param cUsuario   - Código do usuário que fez a requisição
@param cEmpLog    - Código da empresa logada
@param cFilLog    - Código da filial logada
@param nThread      - número da thread 
@param cTpAssunto - 

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Function ImpDistr( aModelo, aDistr, cUsuario, cEmpLog, cFilLog, nThread, cTpAssunto, cTpAudi, cRespAudi, lVincula, cFilOrigem, cCodProcOri )
	Local oModelJ95   := Nil
	Local oDadosNZZ   := Nil
	Local aCFV        := {}
	Local aMsg        := {}
	Local aLinks      := {}
	Local cLinks      := ''
	Local cNumPro     := ''
	Local cCajuri     := ''
	Local cCobjet     := ''
	Local cCareaj     := ''
	Local cTpAss      := ''
	Local nDistrib    := 0
	Local nI          := 0
	Local lSucesso    := .F.

	public cTipoAsJ   := cTpAssunto
	public c162TipoAs := cTpAssunto

	Default lVincula   := .F.
	Default cFilOrigem := ''
	Default cCodProcOri:= ''

	// Inicializa o ambiente
	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(cEmpLog, cFilLog, , , 'JURI_' + Str(nThread)) // Abre o ambiente
	__CUSERID := cUsuario

	//Instancia o modelo
	oModelJ95  := FWLoadModel("JURA095")
	oModelJ95:SetOperation(MODEL_OPERATION_INSERT)

	// Varre o array de distribuições
	For nDistrib  := 1 To Len(aDistr)

		Importando(Decode64(aDistr[nDistrib][1]))

		lSucesso  := .F.
		cNumPro   := StrTran(aDistr[nDistrib][2], '-')
		cNumPro   := AllTrim(StrTran(cNumPro, '.'))

		// Busca dados complementares do processo
		oDadosNZZ := JsonObject():New()
		oDadosNZZ := JDistReceb(aDistr[nDistrib][2],.F.)

		oDadosNZZ[1]['NUQ_TLOC3N'] := Decode64((oDadosNZZ[1]['NUQ_TLOC3N']))

		oModelJ95:Activate()

		// Popula NSZ
		SetModVal('NSZMASTER',aModelo,oDadosNZZ, oModelJ95)

		// Popula NUQ
		oModelJ95:LoadValue('NUQDETAIL', 'NUQ_INSTAN', '1')
		oModelJ95:LoadValue('NUQDETAIL', 'NUQ_INSATU', '1')
		oModelJ95:LoadValue('NUQDETAIL', 'NUQ_NUMPRO', cNumPro)
		SetModVal('NUQDETAIL',aModelo,oDadosNZZ, oModelJ95)

		// Popula NT9
		SetModVal('NT9DETAIL',aModelo,oDadosNZZ, oModelJ95)

		// Valida preenchimento de Data, Moeda e Valor
		If ( Empty( oModelJ95:GetValue('NSZMASTER', 'NSZ_DTCAUS') ) .Or. ;
				Empty( oModelJ95:GetValue('NSZMASTER', 'NSZ_CMOCAU') ) .Or. ;
				Empty( oModelJ95:GetValue('NSZMASTER', 'NSZ_VLCAUS') ) )

			oModelJ95:LoadValue('NSZMASTER', 'NSZ_DTCAUS', SToD(''))
			oModelJ95:LoadValue('NSZMASTER', 'NSZ_CMOCAU', '')
			oModelJ95:LoadValue('NSZMASTER', 'NSZ_VLCAUS', 0)
		EndIf

		// Valida preenchimento de Comarca, Foro e Vara
		If ( Empty( oModelJ95:GetValue('NUQDETAIL', 'NUQ_CCOMAR') ) .Or. ;
				Empty( oModelJ95:GetValue('NUQDETAIL', 'NUQ_CLOC2N') ) )

			aCFV := GetCFV(aDistr[nDistrib])
			If Len(aCFV) > 0
				oModelJ95:LoadValue('NUQDETAIL', 'NUQ_INSTAN', GetInst(aCFV[2]))
				oModelJ95:LoadValue('NUQDETAIL', 'NUQ_CCOMAR', aCFV[1])
				oModelJ95:LoadValue('NUQDETAIL', 'NUQ_CLOC2N', aCFV[2])
				oModelJ95:LoadValue('NUQDETAIL', 'NUQ_CLOC3N', aCFV[3])
			EndIf
		EndIf

		//Valida Jura095
		If ( oModelJ95:VldData() )
			cCajuri := oModelJ95:GetValue('NSZMASTER', 'NSZ_COD')

			cCobjet:= oModelJ95:GetValue("NSZMASTER","NSZ_COBJET")
			cCareaj:= oModelJ95:GetValue("NSZMASTER","NSZ_CAREAJ")
			cTpAss := oModelJ95:GetValue("NSZMASTER","NSZ_TIPOAS")

			If Empty(cRespAudi)
				cRespAudi   := oModelJ95:GetValue('NSZMASTER', 'NSZ_SIGLA1')
			EndIf

			If( oModelJ95:CommitData() )
				lSucesso := .T.
			EndIf
		Else
			aMsg := oModelJ95:GetModel():GetErrormessage()

			For nI := 1 To Len (aMsg)
				Conout(aMsg[nI])
			Next nI
		EndIf

		oModelJ95:Deactivate()

		// Atualiza NZZ
		cLinks := AtuDistr(cCajuri, oDadosNZZ[1]['NZZ_COD'], lSucesso, aMsg)
		If !(Empty(cLinks))
			Aadd(aLinks, {oDadosNZZ[1]['NZZ_COD'], cLinks, cCajuri})
		EndIf

		If (lSucesso)
			//Grava incidente
			if lVincula .And. !Empty(cCodProcOri)
				If Empty(cFilOrigem)
					cFilOrigem := xFilial('NSZ')
				EndIf
				If NSZ->(dbSeek(cFilOrigem + cCajuri)) // Valida se o Incidente já foi cadastrado 
					If lIncdtTOK(cCodProcOri, cCajuri) // Valida se o Vínculo pode ser efetuado
						RecLock('NSZ', .F.)
						NSZ->NSZ_FPRORI := cFilOrigem
						NSZ->NSZ_CPRORI := cCodProcOri
						NSZ->( dbCommit() )
						NSZ->( MsUnlock() )
					Endif
				EndIf
			EndIf
			//Grava Audiência
			If ( !Empty(oDadosNZZ[1]['NZZ_DTAUDI']) )

				If !(Empty(cTpAudi))
					GravaAud(cCajuri, cTpAudi, cRespAudi, oDadosNZZ[1]['NZZ_DTAUDI'] , oDadosNZZ[1]['NZZ_HRAUDI'] )
				Else
					// Grava fups automáticos
					JAINCFWAUT('3', cCajuri, cCobjet, cCareaj, cTpAss, oDadosNZZ[1]['NZZ_DTAUDI'] , oDadosNZZ[1]['NZZ_HRAUDI'])
				EndIf
			EndIf
		EndIf

		FreeObj(oDadosNZZ)

	Next nDistrib

	oModelJ95:Destroy()

	// Baixa os documentos
	For nI := 1 To Len(aLinks)
		BaixaArqs(aLinks[nI][1], aLinks[nI][2], aLinks[nI][3])
	Next nI

Return .T.

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetModVal(cModel,aModel,oDadosNZZ, oModelJ95)
Seta os valores do modelo

@param cModel    - Nome do Modelo
@param aModel    - Array com a relação de campos e valores do template de processo
@param oDadosNZZ - Objeto com os dados do processo
@param oModelJ95 - Modelo da Jura095 

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function SetModVal(cModel,aModel,oDadosNZZ, oModelJ95)
	Local aStruct    := {}
	Local xValue     := Nil
	Local cType      := ''
	Local nModel     := 0
	Local nReg       := 0
	Local nField     := 0
	Local nI         := 0
	Local nTamanho   := 0


	//Busca a estrutura
	If (cModel = 'NSZMASTER')
		nModel   := 1
		aStruct  := FWFormStruct( 2, 'NSZ', { | cCampo | getSx3Cache(cCampo, 'X3_VISUAL') != 'V' } ):aFields
	ElseIf (cModel = 'NUQDETAIL')
		nModel   := 2
		aStruct  := FWFormStruct( 2, 'NUQ', { | cCampo | getSx3Cache(cCampo, 'X3_VISUAL') != 'V' } ):aFields
	ElseIf (cModel = 'NT9DETAIL')
		nModel   := 3
		aStruct  := FWFormStruct( 2, 'NT9', { | cCampo | getSx3Cache(cCampo, 'X3_VISUAL') != 'V' } ):aFields
	EndIf

	If (cModel == 'NT9DETAIL')
		// Carrega a unidade como Polo Passivo Principal
		cCodCli  := Padr(GetValue( aModel, 'NSZ_CCLIEN', .T. ),FWTamSX3('A1_COD')[1])
		codLoja  := Padr(GetValue( aModel, 'NSZ_LCLIEN', .T. ),FWTamSX3('A1_LOJA')[1])
		aUnidade := GetUnidade(cCodCli, codLoja)

		If Len(aUnidade) > 0
			oModelJ95:LoadValue(cModel, "NT9_ENTIDA", "SA1")
			oModelJ95:SetValue(cModel, "NT9_CODENT", cCodCli + codLoja)
			oModelJ95:SetValue(cModel, "NT9_CGC"   , aUnidade[2])
			oModelJ95:SetValue(cModel, "NT9_PRINCI", "1")
			oModelJ95:SetValue(cModel, "NT9_TIPOEN", "2")
			oModelJ95:SetValue(cModel, "NT9_CTPENV", J219GetNQA({"reu"},"2"))
			nI := 1
		EndIf

		//Carrega demais envolvidos
		For nReg := 1 To len(oDadosNZZ[1]['Envolvidos'])
			nI++

			If nI > 1
				If oModelJ95:GetModel(cModel):AddLine() < nI
					Exit
				EndIf
			EndIf

			oModelJ95:LoadValue(cModel, "NT9_ENTIDA", oDadosNZZ[1]['Envolvidos'][nReg]["NT9_ENTIDA"])
			oModelJ95:LoadValue(cModel,  "NT9_CODENT", oDadosNZZ[1]['Envolvidos'][nReg]["NT9_CODENT"])
			oModelJ95:SetValue(cModel,  "NT9_CGC"   , oDadosNZZ[1]['Envolvidos'][nReg]["NT9_CGC"])
			//Valida Preenchimento TipoPessoa
			If(len(alltrim(oModelJ95:GetValue(cModel,'NT9_CGC'))) > 11)
				oModelJ95:LoadValue(cModel, 'NT9_TIPOP', '2')
			Else
				oModelJ95:LoadValue(cModel, 'NT9_TIPOP', '1')
			EndIf

			oModelJ95:SetValue(cModel,  "NT9_PRINCI", oDadosNZZ[1]['Envolvidos'][nReg]["NT9_PRINCI"])

			// Controla o Principal envolvido
			If ( oDadosNZZ[1]['Envolvidos'][nReg]["NT9_TIPOEN"] = "2" .And. Len(aUnidade) > 0)
				oModelJ95:SetValue(cModel, "NT9_PRINCI", '2')
			EndIf

			oModelJ95:SetValue(cModel, "NT9_TIPOEN", oDadosNZZ[1]['Envolvidos'][nReg]["NT9_TIPOEN"])
			oModelJ95:SetValue(cModel, "NT9_CTPENV", oDadosNZZ[1]['Envolvidos'][nReg]["NT9_CTPENV"])
			nTamanho := GetSx3Cache('NT9_NOME',"X3_TAMANHO")
			oModelJ95:LoadValue(cModel, "NT9_NOME", DecodeUTF8(SubStr(oDadosNZZ[1]['Envolvidos'][nReg]["NT9_NOMEEN"],1,nTamanho)))

		Next nReg
	Else
		//Carrega Detalhe do Processo
		For nField := 1 To Len(aStruct)

			//Seta valor do Modelo
			xValue := GetValue( aModel, aStruct[nField][1], .T. )

			If (Empty(xValue))
				//Seta valor da NZZ
				xValue := oDadosNZZ[1][aStruct[nField][1]]
			EndIf

			If !(Empty(xValue))
				cType := AllTrim( GetSx3Cache(aStruct[nField][1],"X3_TIPO") )
				//Corrige a tipagem
				If cType = 'N'
					xValue := Val(CValToChar(xValue))
				ElseIf  cType = 'D'
					xValue := SToD(strtran(CValToChar(xValue),'-',''))
				ElseIf  cType = 'L'
					xValue := AllTrim(xValue) = 'T'
				EndIf

				If ( oModelJ95:CanSetValue(cModel,aStruct[nField][1]) )
					oModelJ95:LoadValue(cModel, aStruct[nField][1], xValue)
				EndIf

				// Seta data do valor da causa
				If( 'NUQ_DTDIST' == aStruct[nField][1] ) .And. Empty(oModelJ95:GetValue('NSZMASTER', 'NSZ_DTCAUS'))
					If ( oModelJ95:CanSetValue('NSZMASTER', 'NSZ_DTCAUS') )
						oModelJ95:LoadValue('NSZMASTER', 'NSZ_DTCAUS', xValue)
					EndIf
				EndIf

				// Seta Participante
				If ('NSZ_SIGLA' = SubStr(aStruct[nField][1],1,9) )
					SetCPart(xValue, aStruct[nField][1], oModelJ95)
				EndIf
			EndIf
		Next nField
	EndIf

Return .T.

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetValue(aModelo, cCampo, lModelo)
Buscao  valor do campo em um array de modelo

@param aModelo  - Array contendo os dados dos campos
@param cCampo   - Nome do campo procurado
@param lModelo  - Indica se é um array de modelos ou de campos da NZZ

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function GetValue(aModelo, cCampo, lModelo)
	Local nPos := 0
	Local xRet := Nil

	nPos := aScan(aModelo,{|x| x[1] == cCampo})

	If nPos > 0
		If(lModelo)
			xRet := aModelo[nPos][3]
		Else
			xRet := aModelo[nPos][2]
		EndIf

		If (!Empty(xRet) .And. ValType(xRet) $ 'C | M' )
			xRet := decodeUTF8(xRet)
		EndIf
	EndIf

Return xRet

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCFV(aDadosDist)
Buscao  Comarca, Foro e Vara dado o número do processo

@param aDadosDist - Array de informações da distribuição

@return aCFV    -  Retorana array com três posições sendo:
					1= Código Comarca
					2= Código Foro
					3= Código Vara

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Function GetCFV(aDadosDist)
Local aArea     := GetArea()
Local cJustica  := ''
Local cTribunal := ''
Local cOrigem   := ''
Local cMascara  := ''
Local cComarca  := ''
Local cForo     := ''
Local cVara     := ''
Local cUf       := ''
Local cNumPro   := aDadosDist[2]
Local aCFV      := {}

	If ( Len(cNumPro) >= 20 )
		// Limpa o nº processo
		cNumPro:= StrTran(cNumPro, '-')
		cNumPro:= Alltrim( StrTran(cNumPro, '.') )

		cJustica  := SubStr(cNumPro, 14, 1)
		cTribunal := SubStr(cNumPro, 15, 2)
		cOrigem   := SubStr(cNumPro, 17, 4)

		cMascara := cJustica + '.' + cTribunal + '.' + cOrigem

		dbSelectArea("O00") // Máscara CNJ
		O00->(dbSetOrder(1)) // O00_FILIAL+O00_MASCAR+O00_CCOMAR+O00_CLOC2N+O00_CLOC3N

		If O00->(dbSeek( xFilial("O00") + cMascara ) )
			cComarca := O00->O00_DCOMAR
			cForo    := O00->O00_DLOC2N
			cVara    := O00->O00_DLOC3N
			cUf      := O00->O00_UF
		Else
			cComarca := DecodeUTF8( AllTrim(aDadosDist[3]) )
			cForo    := DecodeUTF8( AllTrim(aDadosDist[4]) )
			cVara    := DecodeUTF8( AllTrim(aDadosDist[5]) )
			cUf      := DecodeUTF8( AllTrim(aDadosDist[6]) )
		EndIf

		aCFV := JComForVar({;
					cComarca,;
					cUf     ,;
					cForo   ,;
					cVara    ;
				})
	EndIf

	RestArea(aArea)

Return aCFV

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetInst(cForo)
Busca a instância dado o código do foro

@param cForo    - Código do Foro

@return cInstan -  retorna qual a instância.

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function GetInst(cForo)
	Local cInstan := ''
	Local aArea   := GetArea()

	dbSelectArea("NQC") // Foro / Tribunal
	NQC->(dbSetOrder(1)) // NQC_FILIAL+NQC_COD

	If NQC->(dbSeek( xFilial("NQC") + cForo) )
		cInstan := NQC->NQC_INSTAN
	Endif

	If Empty(cInstan)
		cInstan := '1'
	EndIf
	RestArea(aArea)

Return cInstan

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaAud(cCajuri, cTipo, cPart, cDtAudi , cHora )
Cria o Fup de audiência

@param cCajuri - Código do processo
@param cTipo   - Código do tipo de FUP
@param cPart   - Sigla do participante responsável
@param cDtAudi - Data da audiência
@param cHora   - Hora da audiência

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function GravaAud(cCajuri, cTipo, cPart, cDtAudi , cHora )
	Local oModelJ106 := FWLoadModel("JURA106")
	Default cHora    := ""

	oModelJ106:SetOperation(MODEL_OPERATION_INSERT)
	oModelJ106:Activate()

	oModelJ106:LoadValue("NTAMASTER", "NTA_CAJURI", cCajuri)
	oModelJ106:LoadValue("NTAMASTER", "NTA_CTIPO", cTipo)
	oModelJ106:LoadValue("NTAMASTER", "NTA_DTFLWP", SToD(cDtAudi))
	oModelJ106:LoadValue("NTAMASTER", "NTA_HORA", SubStr(cHora, 1,2) + SubStr(cHora, 4,2))
	oModelJ106:GetModel("NTEDETAIL"):SetValue("NTE_SIGLA", cPart)

	If ( oModelJ106:VldData() )
		oModelJ106:CommitData()
	EndIf

	oModelJ106:Destroy()

Return .T.

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuDistr(cCajuri, cCodNZZ, lSucesso, aMsg)
Atualiza o Status de uma distribuição

@param cCajuri  - Código do processo gerado à partir da distribuição
@param cCodNZZ  - Código da dsitribuição
@param lSucesso - Indica se a infortação foi efetuada ou houve erro
@param aMsg     - Array com a mensagem de erro da importação

@return cLinks  -  String contendo link dos documentos para download.

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function AtuDistr(cCajuri, cCodNZZ, lSucesso, aMsg)
	Local aArea      := GetArea()
	Local aAreaNZZ   := NZZ->( GetArea() )
	Local cLinks     := ""
	Local cMsg       := ""
	Local cNumPro    := ""
	Default lSucesso := .T.
	Default aMsg     := {}

	DbSelectArea("NZZ")
	NZZ->(DbSetOrder(1)) //NZZ_FILIAL+NZZ_COD

	cCodNZZ := xFilial("NZZ") + cCodNZZ

	If dbSeek(cCodNZZ)

		cNumPro := NZZ->NZZ_NUMPRO

		RecLock("NZZ", .F.)
		If (lSucesso)
			//Atualiza o status da distribuição e atribui o código do processo
			NZZ->NZZ_STATUS := "2"
			NZZ->NZZ_CAJURI := cCajuri
			cLinks:= NZZ->NZZ_LINK

			If(NZZ->(FieldPos('NZZ_ERRO')) > 0)
				NZZ->NZZ_ERRO := ""
			EndIf
		Else
			cMsg := SubStr("Erro: " + aMsg[6] , 1, 250)
			NZZ->NZZ_STATUS := "1"

			If(NZZ->(FieldPos('NZZ_ERRO')) > 0)
				NZZ->NZZ_ERRO := cMsg
			EndIf

		EndIf
		NZZ->( MsUnLock() )
	EndIf

	NZZ->(DbCloseArea())

	If(lSucesso)
		cMsg := (STR0060 + cNumPro + STR0061) //"A Distribuição de número "  + cNumPro +  " foi importada com sucesso!"
		JA280Notify(cMsg, , , '2', "ImpDistr", 'processo/'+Encode64(xFilial('NSZ'))+"/"+Encode64(cCajuri) )
	Else
		cMsg := (STR0059 + cNumPro) // "Falha na importação da distribuição: "
		JA280Notify(cMsg, , 'minus-circle', '2', "ImpDistr", 'Distribuicao/detalhe/'+Encode64(cCodNZZ) )
	EndIf

	RestArea(aAreaNZZ)
	RestArea(aArea)

Return cLinks

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetUnidade(cCodCli, codLoja)
Busca dados da unidade

@param cCodCli  - Código do Cliente
@param codLoja  - Código da Loja

@return aRet, Retorna um array com 3 posições, sendo:
			 1= Nome do Cliente, 
			 2= CPF/CNPJ
			 3= Tipo de Pessoa (1=Física; 2=Jurídica)

@since 	 10/08/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function GetUnidade(cCodCli, codLoja)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local aRet   := {}

	cCodCli := Padr(cValToChar(cCodCli),FWTamSX3('A1_COD')[1])
	codLoja := Padr(cValToChar(codLoja),FWTamSX3('A1_LOJA')[1])

	cQuery := "SELECT A1_NOME, A1_CGC FROM " + RetSqlName('SA1')
	cQuery += " WHERE A1_FILIAL = " + "'" + xFilial('SA1') + "' AND A1_COD = '" + cCodCli + "' AND A1_LOJA = '"+codLoja+"'"
	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	If (cAlias)->(!Eof())
		Aadd(aRet, (cAlias)->A1_NOME)
		Aadd(aRet, (cAlias)->A1_CGC)
		Aadd(aRet, Iif( Len((cAlias)->A1_CGC) > 11  , '2', '1' ) )
	EndIf
	(cAlias)->( DbCloseArea() )

Return aRet

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Importando(cCodNZZ)
Atualiza o status da distribuição para 5= importando
@Param cCodNZZ - código da distribuição

@version 1.0
/*/
//----------------------------------------------------------------------------------------------------
Static Function Importando(cCodNZZ)
	Local aArea := GetArea()

	DbSelectArea("NZZ")
	NZZ->(DbSetOrder(1)) //NZZ_FILIAL+NZZ_COD

	If dbSeek(cCodNZZ)

		RecLock("NZZ", .F.)
			NZZ->NZZ_STATUS := "5"
			
			If(NZZ->(FieldPos('NZZ_ERRO')) > 0)
				NZZ->NZZ_ERRO := CValToChar( Val( FWTimeStamp(4) ) + 600 )
			EndIf
		NZZ->( MsUnLock() )
	EndIf

	NZZ->(DbCloseArea())

	RestArea(aArea)

Return .T.

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetCPart( cSigla, cField, oModel)
Seta o código do participante

@Param cSigla - Sigla do Participante
@Param cField - Campo (Sigla1, sigla2 o sigla3)
@Param oModel - Modelo da Jura095

@version 1.0
/*/
//----------------------------------------------------------------------------------------------------
Static Function SetCPart( cSigla, cField, oModel)
	Local cPart := ''
	Local cSql  := ''
	Local aSql  := {}

	cSql := "SELECT RD0_CODIGO FROM " + RetSqlName('RD0')
	cSql += " WHERE RD0_TPJUR = '1' AND RD0_MSBLQL = '2' AND D_E_L_E_T_ = ' '"
	cSql += " AND RD0_FILIAL = '" + xFilial('RD0') + "'"
	cSql += " AND RD0_SIGLA = '"+ cSigla +"'"
	cSql += " ORDER BY RD0_CODIGO DESC "
	aSql := JURSQL(cSql,"*")

	If Len(aSql) > 0
		cPart := aSql[1][1]
	EndIf

	// Seta Participante
	cField := StrTran( cField,'NSZ_SIGLA', 'NSZ_CPART' )

	oModel:LoadValue('NSZMASTER', cField, cPart)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GET getRotinas
Exporta o resumo do processo em PDF
 
@param tipoAssjur - tipo do assunto juridico

@since /01/21
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/getRotinas?tipoAssjur=001
/*/
//-------------------------------------------------------------------
WSMETHOD GET getRotinas WSRECEIVE tipoAssjur WSREST JURLEGALPROCESS
Local cTipoAs    := Self:tipoAssjur
Local lTitNuz    := IIF(SUPERGETMV("MV_JEXPPTA", .T. , "2")=="1",.T.,.F.)
Local oResponse  := JSonObject():New()
Local nIndexJSon := 0
Local aTabelas   := {}

	If !Empty(cTipoAs) 
		aTabelas := JA108Tabs(cTipoAs,lTitNuz)
	EndIf

	Self:SetContentType("application/json")

	oResponse['listRotinas']:= {}

	For nIndexJSon := 1 To Len(aTabelas)
	
		Aadd(oResponse['listRotinas'], JsonObject():New())

		oResponse['listRotinas'][nIndexJSon]['tabela']  := JConvUTF8(StrTran(aTabelas[nIndexJSon][1], '=', '' ))
		oResponse['listRotinas'][nIndexJSon]['apelido'] := JConvUTF8(AllTrim( aTabelas[nIndexJSon][2] ))

	Next nIndexJSon
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GET getCamposExp
Busca os campos da exportação de acordo com a tabela/rotina

@param tabela     - Tabela que será usada para buscar os campo
@param tipoAssjur - tipo do assunto juridico
@param isNew      - Indica se é inclusão
@param codModelo  - Código do modelo
@param searchKey  - string digitada pelo usuário para busca de campo

@since 30/12/2020
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS//getCamposExp/000001?tipoAssjur=001&isNew=false&codModelo=0008
/*/
//-------------------------------------------------------------------

WSMETHOD GET getCamposExp PATHPARAM tabela WSRECEIVE tipoAssjur, isNew, codModelo, searchKey WSREST JURLEGALPROCESS
Local aArea      := GetArea()
Local aAreaNQ0   := NQ0->( GetArea() )
Local aAreaNQ2   := NQ2->( GetArea() )
Local oResponse  := JSonObject():New()
Local cNQ2Cod    := ""
Local cTipoCfg   := ""
Local nIndexJSon := 0
Local nI         := 0
Local nY         := 0
Local nCount2    := 0
Local nCt        := 0
Local nPosIni    := 0 
Local nPosFim    := 0
Local aLista     := {}
Local aTab       := {}
Local aCamps     := {}
Local aFormulas  := {}
Local aCposConfg := {}
Local cTabela    := Self:tabela
Local cTipoAs    := Self:tipoAssjur
Local lIsNew     := Self:isNew
Local cCodModelo := Self:codModelo
Local cSearchKey := Self:searchKey

	Self:SetContentType("application/json")

	oResponse['listCampos']     := {}
	oResponse['camposDoModelo'] := {}

	If !Empty(cTabela) .AND. !Empty(cTipoAs)

		NQ0->(DBSetOrder(1)) // NQ0_FILIAL + NQ0_COD

		If NQ0->(DBSeek(xFILIAL('NQ0') + cTabela))

			nCt := 0

			NQ2->( dbSetOrder( 2 ) )  // NQ2_FILIAL + NQ2_TABELA
			NQ2->( dbSeek( xFilial( 'NQ2' ) + NQ0->NQ0_TABELA) )

			While !NQ2->( EOF() ) .AND. xFilial( 'NQ2' ) + NQ0->NQ0_TABELA  == NQ2->NQ2_FILIAL + NQ2->NQ2_TABELA
				If NQ0->NQ0_APELID == NQ2->NQ2_APELID
					nCt := nCt + 1

					cNQ2Cod := NQ2->NQ2_COD
				Endif
				NQ2->( dbSkip() )
			End

			aCamps := JA108Camps( NQ0->NQ0_TABELA, NQ0->NQ0_APELID, nCt > 0 , cTipoAs, cNQ2Cod )

			aTab      := aCamps[1]
			aFormulas := aCamps[2]

			// Copia o conteudo do Array aTab para o array aLista (Campos)
			For nI:= 1 to Len(aTab)

				if Empty(cSearchKey) .Or. (UPPER(JurLmpCpo(cSearchKey, .F., .F.)) $ UPPER(JurLmpCpo(aTab[nI][1] + aTab[nI][2],.F., .F.)))
					aAdd(aLista,{ aTab[nI][3],;   // Campo
									Alltrim(aTab[nI][1]) +  aTab[nI][2],; // Descrição
									aTab[nI][4],;  // Tabela nivel 1
									aTab[nI][6],;  // Apelido da tabela nivel 1
									aTab[nI][5],;  // Tabela nivel 2
									aTab[nI][7],;  // Apelido da tabela nivel 2
									Alltrim(aTab[nI][10]),;  // Filtro
									Alltrim(aTab[nI][1]),;   // Desc Campo
									Alltrim(aTab[nI][11]),;   // campoT
									If(Len(aTab[nI]) >= 15, aTab[nI][15], 0);   // nPriUni
								})
				EndIf
			Next

			// Copia o conteudo do Array aFormulas para o array aLista (Formulas)
			For nI:= 1 to Len(aFormulas)
				if Empty(cSearchKey) .Or. (UPPER(JurLmpCpo(cSearchKey, .F., .F.)) $ UPPER(JurLmpCpo(aFormulas[nI][1] + aFormulas[nI][2],.F., .F.)))
					aAdd(aLista,aFormulas[nI])
				EndIf
			Next
		EndIf


		If Len(aLista) > 0 // Busca todos os campos disponíveis para serem incluidos no modelo
			For nIndexJSon := 1 To Len(aLista)
				Aadd(oResponse['listCampos'], JsonObject():New())
				//Campo
				If (Len (aLista[nIndexJSon]) > 5)
					oResponse['listCampos'][nIndexJSon]['isFormula']     := .F.
					oResponse['listCampos'][nIndexJSon]['campo']         := JConvUTF8(AllTrim( aLista[nIndexJSon][01] ))
					oResponse['listCampos'][nIndexJSon]['descricao']     := JConvUTF8(AllTrim( aLista[nIndexJSon][02] ))
					oResponse['listCampos'][nIndexJSon]['tabelaNivel1']  := JConvUTF8(AllTrim( aLista[nIndexJSon][03] ))
					oResponse['listCampos'][nIndexJSon]['apelidoNivel1'] := JConvUTF8(AllTrim( aLista[nIndexJSon][04] ))
					oResponse['listCampos'][nIndexJSon]['tabelaNivel2']  := JConvUTF8(AllTrim( aLista[nIndexJSon][05] ))
					oResponse['listCampos'][nIndexJSon]['apelidoNivel2'] := JConvUTF8(AllTrim( aLista[nIndexJSon][06] ))
					oResponse['listCampos'][nIndexJSon]['filtro']        := JConvUTF8(AllTrim( aLista[nIndexJSon][07] ))
					oResponse['listCampos'][nIndexJSon]['descCampo']     := JConvUTF8(AllTrim( aLista[nIndexJSon][08] ))
					oResponse['listCampos'][nIndexJSon]['campoT']        := JConvUTF8(AllTrim( aLista[nIndexJSon][09] ))
					oResponse['listCampos'][nIndexJSon]['agrupamento']   := aLista[nIndexJSon][10]
				//Formula
				Else
					nPosIni := At('(', aLista[nIndexJSon][2] ) + 1
					nPosFim := At(')', aFormulas[1][2]) - nPosIni
					oResponse['listCampos'][nIndexJSon]['isFormula']     := .T.
					oResponse['listCampos'][nIndexJSon]['campo']         := JConvUTF8(AllTrim( Substr(aLista[nIndexJSon][2], nPosIni, nPosFim )))
					oResponse['listCampos'][nIndexJSon]['descricao']     := JConvUTF8(AllTrim( aLista[nIndexJSon][1] ) + AllTrim( aLista[nIndexJSon][2] ))
					oResponse['listCampos'][nIndexJSon]['tabelaNivel2']  := JConvUTF8(AllTrim( aLista[nIndexJSon][5] ))
					oResponse['listCampos'][nIndexJSon]['apelidoNivel1'] := JConvUTF8(AllTrim( aLista[nIndexJSon][4] ))
					oResponse['listCampos'][nIndexJSon]['filtro']        := JConvUTF8(AllTrim( aLista[nIndexJSon][3] ))
					oResponse['listCampos'][nIndexJSon]['descCampo']     := JConvUTF8(AllTrim( aLista[nIndexJSon][1] ))
					oResponse['listCampos'][nIndexJSon]['campoT']        := ""
					oResponse['listCampos'][nIndexJSon]['agrupamento']   := 0
				EndIf
			Next nIndexJSon
		EndIf
	EndIf

	If !lIsNew .AND. !Empty(cCodModelo)
		cTipoCfg := JurGetDados('NQ5', 1 , xFilial('NQ5') + cCodModelo , 'NQ5_TIPO')

		aCposConfg := JA108AtCps(, cCodModelo )

		For nY := 1 To Len(aCposConfg)
			nCount2++
			Aadd(oResponse['camposDoModelo'], JsonObject():New())
		
			
			// Valida se é formula
			If Len(aCposConfg[nY]) > 5
				oResponse['camposDoModelo'][nCount2]['isFormula']     := .F.
				oResponse['camposDoModelo'][nCount2]['campo']         := JConvUTF8(AllTrim( aCposConfg[nY][3] ))
				oResponse['camposDoModelo'][nCount2]['descCampo']     := JConvUTF8(AllTrim( aCposConfg[nY][1] ))
				oResponse['camposDoModelo'][nCount2]['descricao']     := JConvUTF8(AllTrim( aCposConfg[nY][1]) + ' ' + AllTrim( aCposConfg[nY][2] ) )
				oResponse['camposDoModelo'][nCount2]['tabelaNivel1']  := JConvUTF8(AllTrim( aCposConfg[nY][4] ))
				oResponse['camposDoModelo'][nCount2]['apelidoNivel1'] := JConvUTF8(AllTrim( aCposConfg[nY][6] ))
				oResponse['camposDoModelo'][nCount2]['tabelaNivel2']  := JConvUTF8(AllTrim( aCposConfg[nY][5] ))
				oResponse['camposDoModelo'][nCount2]['apelidoNivel2'] := JConvUTF8(AllTrim( aCposConfg[nY][7] ))
				oResponse['camposDoModelo'][nCount2]['filtro']        := JConvUTF8(AllTrim( aCposConfg[nY][10] ))
				oResponse['camposDoModelo'][nCount2]['campoT']        := JConvUTF8(AllTrim( aCposConfg[nY][11] ))
				oResponse['camposDoModelo'][nCount2]['agrupamento']   := If( Len(aCposConfg[nY]) >= 15, aCposConfg[nY][15], 0 )
				
				
			Else
				nPosIni := At('(', aCposConfg[nCount2][2] ) + 1
				nPosFim := At(')', aCposConfg[nCount2][2]) - nPosIni
				oResponse['camposDoModelo'][nCount2]['isFormula']     := .T.
				oResponse['camposDoModelo'][nCount2]['campo']         := JConvUTF8(AllTrim( Substr(aCposConfg[nY][2], nPosIni, nPosFim )))
				oResponse['camposDoModelo'][nCount2]['descricao']     := JConvUTF8(AllTrim( aCposConfg[nY][1] ) + AllTrim( aCposConfg[nY][2] ))
				oResponse['camposDoModelo'][nCount2]['tabelaNivel2']  := JConvUTF8(AllTrim( aCposConfg[nY][5] ))
				oResponse['camposDoModelo'][nCount2]['apelidoNivel1'] := JConvUTF8(AllTrim( aCposConfg[nY][4] ))
				oResponse['camposDoModelo'][nCount2]['filtro']        := JConvUTF8(AllTrim( aCposConfg[nY][3] ))
				oResponse['camposDoModelo'][nCount2]['descCampo']     := JConvUTF8(AllTrim( aCposConfg[nY][1] ))
				oResponse['camposDoModelo'][nCount2]['campoT']        := ""
				oResponse['camposDoModelo'][nCount2]['agrupamento']   := 0

			EndIf
		Next nY
	EndIf

	oResponse['cTipoCfg'] = cTipoCfg
	oResponse['camposDoModeloQtd'] = nCount2
	oResponse['listCamposQtd'] = nIndexJSon - 1

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aAreaNQ0)
	RestArea(aAreaNQ2)
	RestArea(aArea)

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST ModExpUpd
Método responsável pela alteração de um modelo de exportação personalizada

@param body - Json com os dados do modelo e dos campos que serão alterados
@return .T.

@since 06/01/2021
@example [Sem Opcional] GET -> http://localhost:12173/rest/JURLEGALPROCESS/updtModExp
	body - {
			"modelo": "0042",
			"tpAssJur": "001",
			"campos": [
				{
				"value": "NSZ_CCLIEN",
				"label": "Código do cliente -  ( Assuntos Juridicos )",
				"descCampo": "Código do cliente",
				"filtro": "",
				"tabela1nvl": "NSZ",
				"tabela2nv2": "NSZ",
				"apelido1nvl": "NSZ001",
				"apelido2nv2": "NSZ001",
				"campoT": "",
				"agrupamento": ""
				}
			],
			"tipoCfg": "1",
			"user": "000000"
		}
/*/
//-------------------------------------------------------------------
WSMETHOD POST ModExpUpd WSREST JURLEGALPROCESS

Local oResponse  := JsonObject():New()
Local oRequest   := JsonObject():New()
Local cBody      := Self:GetContent()
Local cCodModelo := ""
Local cTpAssJur  := ""
Local cTipo      := ""
Local cUser      := ""
Local cMsgErro   := ""
Local aRet       := {}

	oResponse['data'] := .F.
	oRequest:FromJson(cBody)
	cCodModelo = oRequest['modelo']
	cTpAssJur  = oRequest['tpAssJur']
	cTipo      = oRequest['tipoCfg']
	cUser      = oRequest['user']

	If Len(oRequest['campos'] ) > 0
		aRet := MExpUpdate(cCodModelo, cTpAssJur, oRequest['campos'], cTipo, cUser)

		// Valida se ocorreram erros
		If aRet[1]
			oResponse['data'] := aRet[1]
		Else
			cMsgErro := aRet[2]
		EndIf
	EndIf
	
	oResponse['msgErro'] := JConvUTF8(cMsgErro)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET PesquisaRapida
Pesquisa rápida de processos

@param pageSize   - Quantidade de registro por pagina
@param cSearchKey - palavra a ser pesquisada no Nome do Envolvido
					(NT9_NOME) e Número do Processo (NUQ_NUMPRO)

@since 15/07/2019

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/pesquisaRapida
/*/
//-------------------------------------------------------------------
WSMETHOD GET PesquisaRapida WSRECEIVE searchKey, pageSize WSREST JURLEGALPROCESS
Local oResponse  := Nil
Local cSearchKey := Self:searchKey
Local nPageSize  := Self:pageSize
Local cTpAsCfg   := J293CfgQry('1')
Local cTpAsPref  := ""

	Self:SetContentType("application/json")
	oResponse := JWSPsqRpH(cSearchKey, nPageSize, cTpAsCfg, cTpAsPref)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSPsqRpH
Listagem de Processos para a barra de Pesquisa Rápida da home TotvsLegal

@param cSearchKey - palavra a ser pesquisada no Nome do Envolvido
					(NT9_NOME) e Número do Processo (NUQ_NUMPRO)
@param nPageSize  - Quantidade de itens na página
@param cTpAsCfg   - Tipo de assunto jurídico configurado no produto
@param cTpAsPref  - Tipo de assunto jurídico da preferência do usuário

@since 12/05/2021
/*/
//-------------------------------------------------------------------
Static Function JWSPsqRpH(cSearchKey,nPageSize, cTpAsCfg, cTpAsPref)
Local cQrySelect   := ""
Local cQryFrom     := ""
Local cQryWhere    := ""
Local cQryOrder    := ""
Local cQuery       := ""
Local oResponse    := JsonObject():New()
Local aSQLRest     := Ja162RstUs(,,,.T.)
Local cTpAJ        := JWsLpGtNyb()
Local cAlias       := GetNextAlias()
Local nIndexJSon   := 0
Local cExists      := ''
Local cWhere       := ''
Local aFilUsr      := JURFILUSR( __CUSERID, "NSZ" )
Local nPage        := 1
Local cAssJurGrp   := ""
Local bFiliais     := .F.
Local aNT9         := {}
Local nCount       := 0
Local cWhrTpAsJ    := ""
Local cDescAss     := ""

Default cSearchKey := ""
Default nPageSize  := 10
Default cTpAsCfg   := ""
Default cTpAsPref  := ""

	cQrySelect := " SELECT DISTINCT NSZ.NSZ_COD    NSZ_COD, "
	cQrySelect +=                 " NVE.NVE_TITULO NVE_TITULO, "
	cQrySelect +=                 " NSZ.NSZ_FILIAL FILIAL,"
	cQrySelect +=                 " NQU.NQU_DESC   TIPOACAO,"
	cQrySelect +=                 " NSZ.NSZ_TIPOAS NSZ_TIPOAS "

	cQryFrom   :=   " FROM " + RetSqlName('NSZ') + " NSZ "
	cQryFrom   +=   " LEFT  JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom   +=     " ON  (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
	cQryFrom   +=    " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=    " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=    " AND (NVE.NVE_FILIAL = '" + xFilial("NVE") + "') "
	cQryFrom   +=    " AND (NVE.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NUQ') + " NUQ "
	cQryFrom   +=     " ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrom   +=    " AND NUQ.NUQ_INSATU = '1' "
	cQryFrom   +=    " AND NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrom   +=    " AND NUQ.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=  " LEFT JOIN " + RetSqlName('NQU') + " NQU "
	cQryFrom   +=         " ON ( NQU.NQU_COD = NUQ.NUQ_CTIPAC ) "
	cQryFrom   +=        " AND ( NQU.NQU_FILIAL =  '" + xFilial("NQU") + "' ) "
	cQryFrom   +=        " AND ( NQU.D_E_L_E_T_ = ' ' ) 

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
		If "," $ FORMATIN(aFilUsr[1],aFilUsr[2])
			bFiliais := .T.
		EndIf
	Else
		cQryWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	// Verifica os assuntos jurídico que usuário possui acesso
	cAssJurGrp := JurTpAsJr(__CUSERID,,,.T.)
	cWhrTpAsJ  := " AND NSZ.NSZ_TIPOAS IN (" + cAssJurGrp + ") "
	cQryWhere  += cWhrTpAsJ

	cQryWhere += " AND NSZ.D_E_L_E_T_ = ' ' "
	cQryWhere += " AND ( ( NUQ.NUQ_COD <> ' ' "
	
	If !Empty(cTpAsPref)
		cQryWhere += " AND NSZ.NSZ_TIPOAS IN " + FORMATIN(cTpAsPref, ',')
	EndIf

	If !Empty(cTpAsCfg)
		cQryWhere += ") OR NSZ.NSZ_TIPOAS IN " + FORMATIN(cTpAsCfg, ',')
	Else
		cQryWhere += " ) "
	EndIf

	cQryWhere += " ) "

	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))
		cWhere    := " AND " + JurFormat("NT9_NOME", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=     " AND (" + SUBSTR(JurGtExist(RetSqlName("NT9"), cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
		cWhere    :=     " AND " + JurFormat("NUQ_NUMPRO", .F.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=      " OR " + SUBSTR(JurGtExist(RetSqlName("NUQ"), cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists + " OR NSZ.NSZ_COD  Like '%" + cSearchKey + "%' )"
	EndIf

	cQryWhere  += VerRestricao()

	If !Empty(aSQLRest)
		cQryWhere += " AND (" + Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ) + ")"
	EndIf

	cQryOrder := " ORDER BY NSZ.NSZ_COD "

	cQuery := cQrySelect + cQryFrom + cQryWhere + cQryOrder

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['processes'] := {}
	oResponse['userName']  := UsrRetName(__CUSERID)
	oResponse['hasMoreBranch']  := bFiliais

	// Define o range para inclusão no JSON
	nQtdRegIni := ((nPage-1) * nPageSize)
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While (cAlias)->(!Eof())
		nQtdReg++

		// Assunto Juridico
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndexJSon++

			cDescAss := JurGetDados('NYB', 1, xFilial('NYB') + (cAlias)->NSZ_TIPOAS, 'NYB_DESC' ) // 1 = NYB_FILIAL + NYB_COD

			Aadd(oResponse['processes'], JsonObject():New())
			oResponse['processes'][nIndexJSon]['processCompany'] := cEmpAnt
			oResponse['processes'][nIndexJSon]['processBranch']  := (cAlias)->FILIAL
			oResponse['processes'][nIndexJSon]['processId']      := (cAlias)->NSZ_COD
			oResponse['processes'][nIndexJSon]['description']    := JConvUTF8((cAlias)->NVE_TITULO )
			oResponse['processes'][nIndexJSon]['assJur']         := JConvUTF8((cAlias)->NSZ_TIPOAS )
			oResponse['processes'][nIndexJSon]['descAss']        := JConvUTF8(cDescAss )
			oResponse['processes'][nIndexJSon]['tipoAcao']       := JConvUTF8((cAlias)->TIPOACAO )
			oResponse['processes'][nIndexJSon]['numProcesso']    := ""

			// Autor/Reu
			aNT9 := JWsLpGtNt9((cAlias)->NSZ_COD,0)
			For nCount := 1 to Len(aNT9)
				If (aNT9[nCount][4]) == '1' // É principal?
					If (aNT9[nCount][11]) == '1' // Polo Ativo
						oResponse['processes'][nIndexJSon]['author'] := JConvUTF8(aNT9[nCount][5])
					Elseif (aNT9[nCount][11]) == '2' // Polo Passivo
						oResponse['processes'][nIndexJSon]['reu'] := JConvUTF8(aNT9[nCount][5])
					Endif
				Endif
			Next

			oResponse['length'] := nQtdReg
		Endif

		(cAlias)->(DbSkip())
	End

	(cAlias)->( DbCloseArea() )

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} MExpUpdate
Realiza a alteração de campos de um modelo de exportação personalizada

@param  cCodModelo - Código do modelo de exportação
@param  cTpAssJur  - Tipo de Assunto Jurídico
@param  aCampos    - Campos a serem gravados
@param  cTipo      - Tipo de Config (1-Pessoal/2-Pública)
@param  cUser      - Usuário Logado
@return aRetorno   - Array
        aRetorno[1] - .T./.F. - Indica se alteração foi realizada com sucesso
		aRetorno[2] - Mensagem de Erro

@since 06/01/2021
/*/
//-------------------------------------------------------------------
Function MExpUpdate(cCodModelo, cTpAssJur, aCampos, cTipo, cUser)
Local aArea    := GetArea()
Local aAreaNQ5 := NQ5->(GetArea())
Local aAreaNQ8 := NQ8->(GetArea())
Local cUserCfg := Posicione('NQ5', 1, xFilial('NQ5') + cCodModelo, 'NQ5_USER')
Local nI       := 0
Local cMsgErro := ""
Local lOk      := .F.
Local aRetorno := {}

If !Empty( cCodModelo ) .And. Len( aCampos ) > 0

	If cUser <> cUserCfg
		cMsgErro := STR0066 + cUserCfg + " - " + UsrRetName(cUserCfg) //Configurações publicas apenas o autor pode alterar ou excluir. Autor: 000000 - Administrador
	Else
		If NQ5->(FieldPos('NQ5_CTPASJ')) > 0

			NQ5->( dbSetOrder( 1 ) ) // NQ5_FILIAL + NQ5_COD
			If NQ5->( dbSeek( xFilial('NQ5') + cCodModelo ) )

				While !NQ5->( EOF() ) .AND. NQ5->(NQ5_FILIAL + NQ5_COD) == xFilial( 'NQ5' ) + cCodModelo
					NQ5->(Reclock( 'NQ5', .F. ))
					NQ5->NQ5_CTPASJ := cTpAssJur
					NQ5->NQ5_TIPO   := cTipo
					NQ5->(MsUnlock())
					NQ5->( dbSkip() )
				End

				If __lSX8
						ConFirmSX8()
						lOk := .T.
				EndIf

				NQ8->( dbSetOrder( 1 ) ) // NQ8_FILIAL + NQ8_CCONFG
				NQ8->( dbSeek( xFilial('NQ8') + cCodModelo ) )

				While !NQ8->( EOF() ) .AND. NQ8->(NQ8_FILIAL + NQ8_CCONFG) == xFilial( 'NQ8' ) + cCodModelo
					NQ8->(Reclock( 'NQ8', .F. ))
					NQ8->(dbDelete())
					NQ8->(MsUnlock())
					If NQ8->(Deleted())
						lOk := .T.
					Else
						lOk := .F.
						cMsgErro := STR0067 // Não foi possível atualizar o Modelo.
						Exit
					EndIf
					NQ8->( dbSkip() )
				End
			Else
				cMsgErro := STR0068// Modelo não encontrado.
				lOk := .F.
			EndIf
		Endif

		If lOk
			For nI:= 1 to Len(aCampos)
				NQ8->(RecLock('NQ8', .T.))
					NQ8->NQ8_FILIAL := xFilial('NQ8')
					NQ8->NQ8_CCONFG := cCodModelo
					NQ8->NQ8_ORDEM  := StrZero(nI,4)

					//Verifica se é uma formula
					If (!aCampos[nI]['isFormula']) 
						aCampos[nI]['descCampo'] := DecodeUTF8(aCampos[nI]['descCampo'])

						If !Empty(AllTrim(aCampos[nI]['campoT']))
							NQ8->NQ8_CAMPOT := AllTrim(aCampos[nI]['campoT'])
							If !Empty(aCampos[nI]['descCampo'])
								NQ8->NQ8_TITCAM := aCampos[nI]['descCampo']
							EndIf
						Else
							NQ8->NQ8_TITCAM := aCampos[nI]['descCampo']
						EndIf

						NQ8->NQ8_CAMPO  := DecodeUTF8( AllTrim(aCampos[nI]['value']))
						NQ8->NQ8_TAB1NV := AllTrim(aCampos[nI]['tabela1nvl'])
						NQ8->NQ8_TAB2NV := AllTrim(aCampos[nI]['tabela2nv2'])
						NQ8->NQ8_APE1NV := AllTrim(aCampos[nI]['apelido1nvl'])
						NQ8->NQ8_APE2NV := AllTrim(aCampos[nI]['apelido2nv2'])
						NQ8->NQ8_FILTRO := AllTrim(aCampos[nI]['filtro'])

						If NQ8->(FieldPos( 'NQ8_PRIULT' )) > 0 .and. ValType(aCampos[nI]['agrupamento']) <> "U"
							NQ8->NQ8_PRIULT := aCampos[nI]['agrupamento']
						EndIf
						
					Else
						If !Empty(AllTrim(aCampos[nI]['label']))
							NQ8->NQ8_CAMPO  := AllTrim(aCampos[nI]['value']       ) //Campos
							NQ8->NQ8_TITCAM := AllTrim(aCampos[nI]['descCampo']   ) //Descrição
							NQ8->NQ8_APE1NV := AllTrim(aCampos[nI]['apelido1nvl'] ) //Apelido
							NQ8->NQ8_TAB2NV := AllTrim(aCampos[nI]['tabela2nv2']  ) //Alias
							NQ8->NQ8_FILTRO := AllTrim(aCampos[nI]['filtro']      ) //Parametros
						EndIf
					EndIf

				NQ8->(MsUnlock())
			Next

			If __lSX8
				ConFirmSX8()
			EndIf
		EndIf
	EndIf
EndIf

aAdd(aRetorno, lOk)
aAdd(aRetorno, cMsgErro)

RestArea(aAreaNQ8)
RestArea(aAreaNQ5)
RestArea(aArea)

aSize(aCampos, 0)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} CajuriOriInc
Obtém os incidentes 

@param  cFililOri   - Filial do assunto jurídico
@param  cCajuriOri  - Código do assunto jurídico
@param  aRet        - Array de cajuri pais (por referência)
		              aRet[1] - Filial do assunto jurídico pai
		              aRet[2] - Código do assunto jurídico pai

@return aRet   -  Array de cajuri pai
        aRet[1] - Filial do assunto jurídico pai
		aRet[2] - Código do assunto jurídico pai

@since 04/02/2021
/*/
//-------------------------------------------------------------------
Static Function CajuriOriInc(cFililOri, cCajuriOri, aRet)
Local aSQL := {}
Local cSQL := ""

	cSQL := "SELECT NSZ_FPRORI, NSZ_CPRORI FROM " + RetSqlname("NSZ") 
	cSQL += " WHERE NSZ_COD = '"+cCajuriOri+"' "
	cSQL += " AND NSZ_FILIAL = '"+cFililOri+"' "
	cSQL += " AND D_E_L_E_T_ = ' ' "
	cSQL := ChangeQuery(cSQL)

	aSQL := JurSQL(cSQL, "*")

	If !Empty(aSQL[1][2])
		aAdd(aRet, {aSQL[1][1], aSQL[1][2]})
		CajuriOriInc(aSQL[1][1], aSQL[1][2], @aRet)
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSelectFilt(cTarget)
Monta select da pesquisa avançada

@param  cTarget:  Indica se é process ou tasks
@param  lOnlyQtd: Define se retorna somente a quantidade de registros

@since 04/02/2021
/*/
//-------------------------------------------------------------------
Static Function JSelectFilt(cTarget, lOnlyQtd)
Local cSelect := " SELECT DISTINCT "

Default cTarget  := 'processes'
Default lOnlyQtd := .F.

	cSelect += " NSZ001.NSZ_FILIAL NSZ_FILIAL, "
	cSelect += " NSZ001.NSZ_COD    NSZ_COD, "
	cSelect += " NSZ001.NSZ_SITUAC NSZ_SITUAC, "
	cSelect += " NSZ001.NSZ_TIPOAS NSZ_TIPOAS, "
	cSelect += " NVE.NVE_TITULO    NVE_TITULO "

	If !lOnlyQtd
		If cTarget == "processes"
			cSelect += " ,NSZ001.NSZ_VLPROV  NSZ_VLPROV, "
			cSelect += " NSZ001.NSZ_DTPROV   NSZ_DTPROV, "
			cSelect += " NQ7.NQ7_DESC        NQ7_DESC, "
			cSelect += " NSZ001.NSZ_DTCERT   NSZ_DTCERT, "
			cSelect += " NSZ001.NSZ_IDENTI   NSZ_IDENTI, "
			cSelect += " NSZ001.NSZ_OBJSOC   NSZ_OBJSOC, "
			cSelect += " NSZ001.NSZ_ULTCON   NSZ_ULTCON, "
			cSelect += " NSZ001.NSZ_NIRE     NSZ_NIRE, "
			cSelect += " NT9.NT9_NOME        NT9_NOME "
		ElseIf cTarget == 'tasks'
			cSelect += " ,NTA001.NTA_COD    NTA_COD, "
			cSelect += " NTA001.NTA_CTIPO  NTA_CTIPO, "
			cSelect += " NQS.NQS_DESC      NQS_DESC, "
			cSelect += " NTA001.NTA_DTFLWP NTA_DTFLWP, "
			cSelect += " NTA001.NTA_HORA   NTA_HORA, "
			cSelect += " NTA001.NTA_CRESUL NTA_CRESUL, "
			cSelect += " NQN.NQN_DESC      NQN_DESC, "
			cSelect += " RD0001.RD0_NOME   RD0_NOME, "
			cSelect += " NTA001.NTA_CPREPO NTA_CPREPO, "
			cSelect += " NQM.NQM_DESC      NQM_DESC "
		ElseIf cTarget == 'deeplegal'
			cSelect += " ,NSZ001.NSZ_NUMPRO NSZ_NUMPRO, "
			cSelect += " NUH.NUH_IDEEPL NUH_IDEEPL, "
			cSelect += " NUH.NUH_COD NUH_COD, "
			cSelect += " NUH.NUH_LOJA NUH_LOJA, "
			cSelect += " NUH.NUH_FILIAL NUH_FILIAL, "
			cSelect += " SA1.A1_NOME A1_NOME, "
			cSelect += " NYB.NYB_FILIAL NYB_FILIAL, "
			cSelect += " NYB.NYB_COD NYB_COD, "
			cSelect += " NRB.NRB_COD NRB_COD, "
			cSelect += " NRB.NRB_FILIAL NRB_FILIAL "
		EndIf
	EndIf

Return cSelect

//-------------------------------------------------------------------
/*/{Protheus.doc} JFromFilter(aSQL, cTarget, cNSZName, cTpAssunto, cCodPart, lCfgProd)
Monta from da pesquisa avançada

@param  aSQL:       Array de condições para montar o join
@param  cTarget:    Indica se é process ou tasks
@param  cNSZName:   Apelido da tabela de dados
@param  cTpAssunto: Tipo de assunto jurídico
@param  cCodPart:   Indica se é process ou tasks
@param  lCfgProd:   Indica se vem da configuração do produto

@since 12/05/2021
/*/
//-------------------------------------------------------------------
static Function JFromFilter(aSQL, cTarget, cNSZName, cTpAssunto, cCodPart, lCfgProd, isOnlyQtd,cTabelas)
Local cFrom   := ''
Local nI      := 1
Local aTabela := {}
Local cTabExc := 'NTA|NTE|RD0|NT4' //Tabelas em excessão 

Default cTarget    := 'processes'
Default cNSZName   := Alltrim(RetSqlName("NSZ"))
Default cTpAssunto := ''
Default cCodPart   := ''
Default lCfgProd   := .F.
Default isOnlyQtd  := .F.
Default cTabelas   := ""

cTabelas := 'NSZ|NVE|NQ7|NT9' //Tabelas em excessão 

	cFrom := " FROM " + cNSZName + " NSZ001 "
	cFrom += " LEFT JOIN " + RetSqlName('NVE') + " NVE"
	cFrom +=        " ON ( NVE.NVE_NUMCAS = NSZ001.NSZ_NUMCAS "
	cFrom +=             " AND NVE.NVE_CCLIEN = NSZ001.NSZ_CCLIEN "
	cFrom +=             " AND NVE.NVE_LCLIEN = NSZ001.NSZ_LCLIEN "
	cFrom +=             " AND NVE.NVE_FILIAL = " + Iif(Empty(xFilial("NVE")), "'" + xFilial("NVE") + "'",'NSZ001.NSZ_FILIAL')  + " "
	cFrom +=             " AND NVE.D_E_L_E_T_ = ' ') "
	cFrom += " LEFT JOIN " + RetSqlName('NQ7') + " NQ7 "
	cFrom +=        " ON ( NQ7.NQ7_COD = NSZ001.NSZ_CPROGN  "
	cFrom +=             " AND NQ7.NQ7_FILIAL = '" + xFilial("NQ7") + "' "
	cFrom +=             " AND NQ7.D_E_L_E_T_ = ' ') "

	If (Empty(cTpAssunto) .And. !lCfgProd) .Or. cTarget == 'deeplegal'
		cFrom += " LEFT JOIN " + RetSqlName('NUQ') + " NUQ001 "
		cFrom +=   " ON ( NUQ001.NUQ_CAJURI = NSZ001.NSZ_COD "
		cFrom +=        " AND NUQ001.NUQ_FILIAL = NSZ001.NSZ_FILIAL "
		cFrom +=        " AND NUQ001.D_E_L_E_T_ = ' ' ) "

		cTabExc += '|NUQ'
		cTabelas+= '|NUQ'
	EndIf

	cFrom += " LEFT JOIN " + RetSqlName('NT9') + " NT9 "
	cFrom +=   " ON ( NT9.NT9_CAJURI = NSZ001.NSZ_COD "
	cFrom +=        " AND NT9.NT9_FILIAL = NSZ001.NSZ_FILIAL "
	cFrom +=        " AND NT9.NT9_PRINCI = '1' "
	cFrom +=        " AND NT9.NT9_TIPOEN = '1'"
	cFrom +=        " AND NT9.D_E_L_E_T_ = ' ' ) "

	If cTarget == 'deeplegal'
		cFrom += " JOIN " + RetSqlName('NQ1') + " NQ1 "
		cFrom += " ON ( NQ1_VALCNJ = '1' "
		cFrom += "      AND NUQ_CNATUR = NQ1_COD ) "
		cTabelas+="|NQ1"
	EndIf

	If cTarget == 'tasks'
		
		cFrom +=  " JOIN " + RetSqlName('NTA') + " NTA001 "
		cFrom +=   " ON ( NTA001.NTA_CAJURI = NSZ001.NSZ_COD "
		cFrom +=        " AND NTA001.NTA_FILIAL = NSZ001.NSZ_FILIAL "
		cFrom +=        " AND NTA001.D_E_L_E_T_ = ' ' ) "
		cFrom += " JOIN " + RetSqlName('NTE') + " NTE001 "
			cFrom +=   " ON ( NTE001.NTE_CAJURI = NTA001.NTA_CAJURI "
		cFrom +=        " AND NTE001.NTE_FILIAL = NTA001.NTA_FILIAL "
		cFrom +=        " AND NTE001.NTE_CFLWP = NTA001.NTA_COD "
		cFrom +=        " AND NTE001.D_E_L_E_T_ = ' ' )"
		cFrom += " JOIN " + RetSqlName('RD0') + " RD0001 "
		cFrom +=   " ON ( RD0001.RD0_CODIGO = NTE001.NTE_CPART "
		cFrom +=        " AND RD0001.D_E_L_E_T_ = ' ' "
		cFrom +=        " AND RD0001.RD0_FILIAL = '" + xFilial("RD0") + "'"

		cFrom += " AND  RD0001.RD0_CODIGO = ("
		cFrom +=               " SELECT  MIN(A.NTE_CPART)"
		cFrom +=                 " FROM " + RetSqlName('NTE') + " A"
		cFrom +=                " WHERE A.NTE_CFLWP = NTA001.NTA_COD "
		cFrom +=                  " AND A.NTE_FILIAL = NTA001.NTA_FILIAL "
		cFrom +=                  " AND A.NTE_CAJURI = NTA001.NTA_CAJURI "
		cFrom +=                  " AND A.D_E_L_E_T_ = ' '"

		If !Empty(cCodPart)
			cFrom +=              " AND A.NTE_CPART IN ("
			cFrom +=                   " SELECT RD0_CODIGO"
			cFrom +=                     " FROM " + RetSqlName('RD0') + " RD0002"
			cFrom +=                    " WHERE RD0002.RD0_SIGLA IN (" + Alltrim(Substr(cCodPart, 3)) + "))"
		EndIf

		cFrom += "))"

		cFrom += " LEFT JOIN " + RetSqlName('NQS') + " NQS "
		cFrom +=   " ON (NQS.NQS_COD = NTA001.NTA_CTIPO "
		cFrom +=        " AND NQS.NQS_FILIAL = '" + xFilial("NQS") + "'"
		cFrom +=        " AND NQS.D_E_L_E_T_ = ' ') "
		cFrom += " LEFT JOIN " + RetSqlName('NQN') + " NQN "
		cFrom +=   " ON (NQN.NQN_COD = NTA001.NTA_CRESUL ""
		cFrom +=       " AND NQN.NQN_FILIAL = '" + xFilial("NQN") + "'"
		cFrom +=       " AND NQN.D_E_L_E_T_ = ' ') "
		cFrom += " LEFT JOIN " + RetSqlName('NQM') + " NQM "
		cFrom +=   " ON (NQM.NQM_COD = NTA001.NTA_CPREPO "
		cFrom +=        " AND NQM.NQM_FILIAL = '" + xFilial("NQM") + "'"
		cFrom +=        " AND NQM.D_E_L_E_T_ = ' ')"

		cTabelas+="|NTA|NTE|RD0|NQS|NQN|NQM"
	EndIF

	For nI := 1 to Len(aSQL)
		If !(subStr(aSQL[nI][1],1,3) $ cTabExc)
			cTabelas+="|"+subStr(aSQL[nI][1],1,3)
			If nI > 1
				aTabela  := STRToArray(aSQL[nI][1], "_")

				If !(aTabela[1] + "001" $ cFrom)
					cFrom += JQryInner(aSQL[nI], Alltrim(cNSZName))
				EndIf
			Else
				cFrom += JQryInner(aSQL[nI], Alltrim(cNSZName))
			EndIf
		EndIf
	Next

	If cTarget == 'deeplegal' .AND. !isOnlyQtd
		cTabelas+="|NUH|SA1|NRB|NYB"
		cFrom += ' LEFT JOIN ' + RetSqlName('NUH') + ' NUH '
		cFrom += 	" ON ( NUH_FILIAL = '" + xFilial("NUH") + "'"
		cFrom +=	      " AND NSZ001.NSZ_CCLIEN = NUH.NUH_COD "
		cFrom += 	      " AND NSZ001.NSZ_LCLIEN = NUH.NUH_LOJA "
		cFrom += 	      " AND NUH.D_E_L_E_T_ = ' ' ) "

		cFrom += " JOIN " + RetSqlName('SA1') +  " SA1 "
		cFrom +=    " ON ( SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cFrom +=          " AND NUH.NUH_COD = SA1.A1_COD "	 
		cFrom +=          " AND NUH.NUH_LOJA = SA1.A1_LOJA "
		cFrom +=          " AND SA1.D_E_L_E_T_ = ' ' ) "

		cFrom += " LEFT JOIN " + RetSqlName('NRB') + " NRB "
		cFrom +=    " ON ( NRB.NRB_COD = NSZ001.NSZ_CAREAJ ) "

		cFrom += " LEFT JOIN " + RetSqlName('NYB') + " NYB "
		cFrom +=    " ON ( NYB.NYB_COD = NSZ001.NSZ_TIPOAS )"

	EndIf

Return cFrom

//-------------------------------------------------------------------
/*/{Protheus.doc} getUltAtuInd
Obtém os indices utilizados nos processos 

@param  oRegFila - lista de Json contendo os processos filtrados
@param  cThread  - Número da thread da fila de impressão
@param  lAutRec  - Indica se a inclusão na fila de impressão é via query

@return aRet   -  Array de indices em formato Json

@since 04/02/2021
/*/
//-------------------------------------------------------------------
Static Function getUltAtuInd(oRegFila, cThread, lAutRec)
Local aRet      := {}
Local cAlias    := GetNextAlias()
Local cSQL      := ""
Local cCodNw7   := ""

Default lAutRec := .F.

	cSQL := " SELECT DISTINCT NW5_COD, NW5_DESC, NW5_TIPO, NW7_COD, NW7_DESC, NZW_DATA "
	cSQL += " FROM " + RetSqlName('NW5') + " NW5 "
	cSQL +=      " LEFT JOIN ( SELECT NZW_CINDIC, "
	cSQL +=                         " MAX(NZW_DATA) NZW_DATA "
	cSQL +=                  " FROM " + RetSqlName('NZW') + " NZW "
	cSQL +=                  " WHERE NZW_FILIAL = '"+xFilial('NZW')+"' "
	cSQL +=                        " AND NZW.D_E_L_E_T_ = ' ' "
	cSQL +=                  " GROUP BY NZW_CINDIC ) TNZW "
	cSQL +=            " ON TNZW.NZW_CINDIC = NW5.NW5_COD "
	cSQL +=    " INNER JOIN " + RetSqlName('NW7') + " NW7 "
	cSQL +=             "ON NW7_FILIAL = '"+xFilial('NW7')+"' "
	cSQL +=               " AND NW7_FORMUL LIKE '%,_' || NW5_COD || '_,%' "
	cSQL +=               " AND NW7.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE "
	cSQL +=     " NW5.NW5_FILIAL = '"+xFilial('NW5')+"'"
	cSQL +=     " AND NW5.D_E_L_E_T_ = ' '"
	

	If lAutRec .Or. Len(oRegFila['listProcess']) > 0
		cCodNw7 := aToC(getCmpsFCor(cThread),",")
		cSQL +=     " AND NW7_COD IN "+FORMATIN(cCodNw7,',')+ " "
	Endif
	cSQL += " AND NZW_DATA < '" + DTOS(Date()) + "' " 
	cSQL += " ORDER BY NZW_DATA "

	cSQL := ChangeQuery(cSQL)

	cSQL := StrTran(cSQL,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cSQL), cAlias, .F., .F. )

	While (cAlias)->(!Eof())
		aAdd(aRet,JsonObject():New())
		aTail(aRet)["codIndice"]   := JConvUTF8((cAlias)->NW5_COD	)
		aTail(aRet)["descIndice"]  := JConvUTF8((cAlias)->NW5_DESC	)
		aTail(aRet)["typeIndice"]  := JConvUTF8((cAlias)->NW5_TIPO	)
		aTail(aRet)["codFormula"]  := JConvUTF8((cAlias)->NW7_COD	)
		aTail(aRet)["descFormula"] := JConvUTF8((cAlias)->NW7_DESC	)
		aTail(aRet)["lastDateUpd"] := JConvUTF8((cAlias)->NZW_DATA	)

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getCmpsFCor
Busca nas tabelas cadastradas na NW8 as formas de correção na tabela NSZ e nas tabelas filhas

@param  cThread - Thread que está a fila de impressão
@return aCodigos -  array de codigos de forma de correção dos registros filtrados

@since 04/02/2021
/*/
//-------------------------------------------------------------------
Static Function getCmpsFCor(cThread)
Local cAlias     := GetNextAlias()
Local aTabelas   := JURRELASX9('NSZ', .F.)
Local aCamposNW8 := JA002NW8(aTabelas)
Local cQuery     := ''
Local nY         := 0
Local aCampoCorr := {}
Local aCodigos   := {}

for nY := 1 to len(aCamposNW8)
	aCampoCorr := JURSX9(aCamposNW8[nY][1], 'NW7')

	If !Empty( aCampoCorr )

		cQuery := "SELECT DISTINCT "+AllTrim(aCamposNW8[nY][9])+" CORRECAO "

		cQuery += " FROM "+RetSqlName(aCamposNW8[nY][1])+ " " + aCamposNW8[nY][1]
		cQuery += " INNER JOIN " + RetSqlName('NQ3') + " NQ3  ON "
		cQuery +=      "NQ3.NQ3_FILIAL = '" + xFilial("NQ3") + "' "
		cQuery +=      "AND NQ3.NQ3_CUSER  = '" + __CUSERID + "' "
		cQuery +=      "AND NQ3.NQ3_SECAO  = '" + cThread+ "' "
		cQuery +=      "AND NQ3.D_E_L_E_T_ = ' ' "

		If PrefixoCpo(aCamposNW8[nY][1]) == 'NSZ'
			cQuery += " AND NQ3_FILORI = NSZ_FILIAL"
			cQuery += " AND NQ3_CAJURI = NSZ_COD"
			
		Else
			cQuery += " AND NQ3_FILORI = "+PrefixoCpo(aCamposNW8[nY][1])+"_FILIAL"
			cQuery += " AND NQ3_CAJURI = "+PrefixoCpo(aCamposNW8[nY][1])+"_CAJURI"
		EndIf

		cQuery += " WHERE "
		cQuery +=  AllTrim(aCamposNW8[nY][9])+ If(TamSx3(aCamposNW8[nY][9])[3] <> 'N'," != '' ", " > 0 " ) 
		cQuery += " AND "+PrefixoCpo(aCamposNW8[nY][1])+".D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		cQuery := StrTran(cQuery,",' '",",''")

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While (cAlias)->(!Eof())
			If aScan(aCodigos,{|x| x == (cAlias)->CORRECAO}) == 0
				aAdd(aCodigos, (cAlias)->CORRECAO)
			EndIf
			(cAlias)->(DbSkip())
		EndDo

		(cAlias)->(DbCloseArea())
	EndIf
Next nY

return aCodigos

//-------------------------------------------------------------------
/*/{Protheus.doc} JWhereFilter(aSQL, cTarget, cNSZName, cTpAssunto, cFilter, cTpAsCfg, aSearchKey)
Monta where da pesquisa avançada

@param  aSQL:       Array de condições para montar o join
@param  cTarget:    Indica se é process ou tasks
@param  cNSZName:   Apelido da tabela de dados
@param  cTpAssunto: Tipo de assunto jurídico
@param  cFilter:    Filter para ser atribuido no where da query
@param  cTpAsCfg:   Tipo de assuntos que constam na configuração do produto
@param aSearchKey   palavra chave a ser pesquisada
@param cTabelas     Tabelas que já existem no from separadas por '|'
@param aFilUsr      Filiais que o usuário tem acesso

@since 12/05/2021
/*/
//-------------------------------------------------------------------
static Function JWhereFilter(aSQL, cTarget, cNSZName, cTpAssunto, cFilter, cTpAsCfg, aSearchKey, cTabelas, aFilUsr)

Local aSQLRestri := Ja162RstUs(,,,.T.)
Local cWhere     := ''
Local cAssJurGrp := ''
Local cSearchKey := ''
Local cExists    := ''
Local lBenefic   := .F.
Local n1         := 0

Default cTarget    := 'processes'
Default cNSZName   := Alltrim(RetSqlName("NSZ"))
Default cTpAssunto := ''
Default cFilter    := ''
Default cTpAssCfg  := ''
Default cTpAssCfg  := ''
Default aSearchKey := {}
Default cTabelas   := ''

	// Filtar Filiais que o usuário possui acesso
	If VerSenha(114) .or. VerSenha(115)
		cWhere := " WHERE NSZ001.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cWhere := " WHERE NSZ001.NSZ_FILIAL = '" + xFilial("NSZ") + "'"
	Endif

	cAssJurGrp := JurTpAsJr(__CUSERID)
	If cAssJurGrp <> "'00'"
		cWhere += " AND NSZ001.NSZ_TIPOAS IN (" + vldStrSql(cAssJurGrp) + ") "
	EndIf

	cWhere  +=   " AND NSZ001.D_E_L_E_T_ = ' ' "

	If !Empty(cTpAssunto)
		cWhere += " AND NSZ001.NSZ_TIPOAS IN (" + vldStrSql(cTpAssunto) + ") "
	EndIf

	If !Empty(cFilter)
		cWhere += " AND NSZ001." + cFilter
	EndIf
	
	cWhere += VerRestricao(,,cAssJurGrp)

	If Len(aSQL) > 0 //adiciona as condições da pesquisa avançada
		cWhere += GetCondicao(aSQL, Alltrim(cNSZName), cTarget == 'tasks', cTabelas)
	EndIf

	If !Empty(aSQLRestri) //adiciona as restrições de usuário
		cWhere += " AND ("+Ja162SQLRt(aSQLRestri, , , , , , , , , )+")"
	EndIF
	
	If !Empty(cTpAsCfg)
		cWhere += " AND NSZ001.NSZ_TIPOAS IN " + FORMATIN(cTpAsCfg, ',')
	EndIf

	If Len(aSearchKey) > 0
		
		// Proteção referente DJURDEP-9435 -  (NIP) CRIAÇÃO DO ASSUNTO JURÍDICO
		DbSelectArea("NT9") 
			lBenefic := ColumnPos("NT9_CODBEN") > 0 
		NT9->(DbCloseArea())

		For n1 := 1 To Len(aSearchKey)
			cSearchKey := DecodeUTF8(aSearchKey[n1])
			cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))
			cWhere += " AND ("
			//Cajuri
			cExists   := " AND " + JurFormat("NSZ_COD", .F.,.F.) + " LIKE '%" + cSearchKey + "%'"
			cExists   :=  + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"),5)
			cWhere += cExists

			// Nr processo
			cExists   := " AND " + JurFormat("NUQ_NUMPRO", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
			cExists   := " OR " + SUBSTR(JurGtExist(RetSqlName("NUQ"), cExists, "NSZ001.NSZ_FILIAL"),5)
			cWhere += cExists

			//Número do demanda
			cExists   :=  " AND " + JurFormat("NSZ_IDENTI", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
			cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"),5)
			cWhere += cExists
			
			//Nome do beneficiário
			cExists   :=  " AND " + JurFormat("NT9_NOME", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
			cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NT9"), cExists, "NSZ001.NSZ_FILIAL"),5)
			cWhere += cExists

			//Código do beneficiário
			If lBenefic
				cExists   :=  " AND " + JurFormat("NT9_CODBEN", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
				cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NT9"), cExists, "NSZ001.NSZ_FILIAL"),5)
				cWhere += cExists
			EndIf
			
			//Número do protocolo
			cExists   :=  " AND " + JurFormat("NSZ_NIRE", .F.,.T.) + " LIKE '%" + cSearchKey + "%'"
			cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ001.NSZ_FILIAL"),5)
			cWhere += cExists

			cWhere += " )"
		Next n1 
	Endif

	If cTarget == 'deeplegal' 
		cWhere += " AND NUQ001.NUQ_DEEPL <> 'T' "
		cWhere += " AND NUQ001.NUQ_INSATU = '1' "
	EndIf

Return cWhere


//-------------------------------------------------------------------
/*/{Protheus.doc} JUnionFilt(aSQL, cTarget, cNSZName, cTpAssunto, cFilter,;
						   cSelect, cFrom, cWhere, cTpAsCfg, lAssJur, lOnlyQtd)
Monta union da pesquisa avançada

@param  aSQL:       Array de condições para montar o join
@param  cTarget:    Indica se é process ou tasks
@param  cNSZName:   Apelido da tabela de dados
@param  cTpAssunto: Tipo de assunto jurídico
@param  cFilter:    Filter para ser atribuido no where da query
@param  cSelect:    Select da query A
@param  cFrom:      From da query A
@param  cWhere:     Where da query A
@param  cTpAsCfg:   Tipo de assuntos que constam na configuração do produto
@param  lAssJur:    Define se irá buscar o tipo de assunto juridico
@param  lOnlyQtd:   Define se retorna somente a quantidade de registros
@param  cTabelas    Tabelas a serem consideradas nos filtros
@param  aFilUsr     Filiais que o usuário tem acesso

@since 12/05/2021
/*/
//-------------------------------------------------------------------

Static Function JUnionFilt(aSQL, cTarget, cNSZName, cTpAssunto, cFilter,;
						   cSelect, cFrom, cWhere, cTpAsCfg, lAssJur, lOnlyQtd,aSearchKey,cTabelas, aFilUsr)
Local cQuery     := ''
Local cOrderBy   := ''
Local cGroupBy   := ''

Default cTarget  := 'process'
Default lAssJur  := .F.
Default lOnlyQtd := .F.

	If !Empty(cTpAsCfg)
		cGroupBy := ' GROUP BY NSZ001.NSZ_FILIAL, '
		cGroupBy +=          'NSZ001.NSZ_COD, '
		cGroupBy +=          'NSZ001.NSZ_SITUAC, '
		cGroupBy +=          ' NSZ001.NSZ_TIPOAS, '
		cGroupBy +=          'NVE.NVE_TITULO, '

		If cTarget == 'tasks'
			cGroupBy += 'NTA001.NTA_DTFLWP, '
			cGroupBy += 'NTA001.NTA_CRESUL, '
			cGroupBy += 'NTA001.NTA_CPREPO, '
			cGroupBy += 'NTA001.NTA_CTIPO, '
			cGroupBy += 'NTA001.NTA_HORA, '
			cGroupBy += 'RD0001.RD0_NOME, '
			cGroupBy += 'NTA001.NTA_COD, '
			cGroupBy += 'NQS.NQS_DESC, '
			cGroupBy += 'NQN.NQN_DESC, '
			cGroupBy += 'NQM.NQM_DESC '
		ElseIf cTarget == 'deeplegal' .And. !lOnlyQtd
			cGroupBy += 'NSZ001.NSZ_NUMPRO, '
			cGroupBy += " NUH.NUH_IDEEPL, "
			cGroupBy += " NUH.NUH_COD, "
			cGroupBy += " NUH.NUH_LOJA, "
			cGroupBy += " NUH.NUH_FILIAL, "
			cGroupBy += " SA1.A1_NOME, "
			cGroupBy += " NYB.NYB_FILIAL, "
			cGroupBy += " NYB.NYB_COD, "
			cGroupBy += " NRB.NRB_COD, "
			cGroupBy += " NRB.NRB_FILIAL "
		Else
			cGroupBy += 'NSZ001.NSZ_VLPROV, '
			cGroupBy += 'NSZ001.NSZ_DTPROV, '
			cGroupBy += 'NQ7.NQ7_DESC, '
			cGroupBy += 'NSZ001.NSZ_DTCERT, '
			cGroupBy += 'NSZ001.NSZ_IDENTI, '
			cGroupBy += 'NSZ001.NSZ_OBJSOC, '
			cGroupBy += 'NSZ001.NSZ_ULTCON, '
			cGroupBy += 'NSZ001.NSZ_NIRE, '
			cGroupBy += 'NT9.NT9_NOME '
		EndIf

		cQuery := 'SELECT * FROM ( '
		cQuery += cSelect + cFrom + cWhere + cGroupBy
		cQuery += ' UNION '

		cWhere := JWhereFilter(aSQL, cTarget, cNSZName, cTpAssunto, cFilter, cTpAsCfg, aSearchKey,cTabelas,aFilUsr)

		cQuery +=  cSelect + cFrom + cWhere + cGroupBy
		cQuery += ') cFilter '

		If !lOnlyQtd
			cOrderBy := " ORDER BY cFilter.NSZ_FILIAL, cFilter.NSZ_COD "
		EndIf

		If cTarget == 'tasks'
			cOrderBy += ", cFilter.NTA_COD "
		EndIf
		
		If !lAssJur
			cQuery += cOrderBy
		EndIf
	ElseIf lAssJur
		cQuery := cSelect + cFrom + cWhere
	Else
		If !lOnlyQtd
			cOrderBy := " ORDER BY NSZ001.NSZ_FILIAL, NSZ001.NSZ_COD "
		EndIf

		If cTarget == 'tasks'
			cOrderBy += ", NTA001.NTA_COD "
		EndIf

		cQuery := cSelect + cFrom + cWhere + cOrderBy
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} cfgTLegal
Busca os assuntos jurídicos da configuração global do TOTVS Legal

@return cReturn - String - Códigos de assuntos configurados
@since 14/05/2021
/*/
//-------------------------------------------------------------------
Static Function cfgTLegal()
Local nI        := 0
Local cRetorno  := ""
Local cConfig   := J293CfgQry('1')
Local aAssuntos := StrToArray(cConfig, ",")

	For nI := 1 To Len(aAssuntos)
		If !Empty(cRetorno)
			cRetorno += ","
			cRetorno += "'" + aAssuntos[nI] + "'"
		Else
			cRetorno += "'" + aAssuntos[nI] + "'"
		EndIf
	Next nI

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JLPInsertNQ3
Realiza o INSERT via query na tabela de fila de impressão

@param codComarca   - Codigo da Comarca
@param codForo   - Codigo do Foro

@param cFilNQ3    Código filial NQ3
@param cUser      Código usuário logado
@param cThread    Identificador da Seção
@param cQryFilter Query do filtro pesquisa avançada

@since 25/06/2021
/*/
//-------------------------------------------------------------------
Function JLPInsertNQ3(cFilNQ3, cUser, cThread, cQryFilter)
Local aArea     := GetArea()
Local cSqlFila  := ""
Local nRet      := 0
Local cAlQry    := ""
Local cSQL      := ""
Local cTpAsCfg  := ""

	cSqlFila := " INSERT INTO " + RetSqlName("NQ3") + "(NQ3_FILIAL, NQ3_CAJURI, NQ3_CUSER, NQ3_SECAO, NQ3_FILORI, D_E_L_E_T_ ) "
	cSqlFila += " SELECT DISTINCT '" + cFilNQ3 + "', "
	cSqlFila +=        " NSZ_COD, "
	cSqlFila +=        " '" + cUser + "', "
	cSqlFila +=        " '" + cThread + "', "
	cSqlFila +=        " NSZ_FILIAL, "
	cSqlFila +=        " ' ' D_E_L_E_T_ "
	cSqlFila += " " + right(cQryFilter,1+len(cQryFilter)-at("FROM",cQryFilter))


	cSqlFila := Left(cSqlFila,At("ORDER BY",cSqlFila)-1)

	cTpAsCfg := J293CfgQry('1')
	cSqlFila += Iif(Empty(cTpAsCfg), " AND " , " WHERE ")
	cSqlFila += " NOT EXISTS ( "
	cSqlFila +=   " SELECT 1 FROM " + RetSqlName("NQ3")
	cSqlFila +=    " WHERE NQ3_CAJURI = NSZ_COD "
	cSqlFila +=      " AND NQ3_CUSER = '" + cUser + "' "
	cSqlFila +=      " AND NQ3_SECAO = '" + cThread + "' "
	cSqlFila +=      " AND NQ3_FILORI = NSZ_FILIAL "
	cSqlFila +=      " AND D_E_L_E_T_ = ' ' "
	cSqlFila += " )" 
	
	nRet := tcSQLExec(cSqlFila)

	If nRet < 0	
		JurMsgErro(STR0080) //"Erro ao incluir os registros na fila de impressão"
	Else 		
		cAlQry := GetNextAlias()

		cSQL := "SELECT COUNT(NQ3_CAJURI) CAJURI" +;
					" FROM " + RetSqlName('NQ3') + ' NQ3 '   +;
				" WHERE NQ3_CUSER  = '" + cUser + "' "    +;
					" AND NQ3_FILIAL = '" + cFilNQ3 + "' "  +;
					" AND NQ3_SECAO  = '" + cThread + "' "  +;
					" AND NQ3.D_E_L_E_T_ = ' ' "
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlQry, .T., .F.)
			If (cAlQry)->(!Eof())
				nRet := (cAlQry)->CAJURI
			EndIf
		(cAlQry)->( DbCloseArea() )
	EndIf

RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaAssuntos
Busca assuntos juridicos

@param cQuery - Query com os dados
@return cAssuntos - Assuntos jurídicos

@since 09/08/2021
/*/
//-------------------------------------------------------------------
Static Function buscaAssuntos(cQuery)
Local aArea     := GetArea()
Local cAlias    := GetNextAlias()
Local cAssuntos := ""

	If !Empty(cQuery)

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
			While !(cAlias)->(EOF())
				If !( (cAlias)->NSZ_TIPOAS $ cAssuntos )
					If !Empty(cAssuntos)
						cAssuntos += ","
					EndIf
					cAssuntos += (cAlias)->NSZ_TIPOAS
				EndIf

				(cAlias)->(DbSkip())
			End
		(cAlias)->(dbCloseArea())
	EndIf

	RestArea(aArea)

Return cAssuntos

//-------------------------------------------------------------------
/*/{Protheus.doc} vldStrSql
Trata string para sql

@param cValor, string a ser testada

@return cValor, string, string entre aspas

@since 02/09/2021
/*/
//-------------------------------------------------------------------
Static Function vldStrSql(cValor)
	cValor = CValToChar(cValor)
	If AT("'", cValor) != 1
			cValor = "'" + cValor + "'"
	EndIf
Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLPQtdReg
Retorna a quantidade de registros

@param cFromWhere - Condições e filtros para a query
@return nTotal - Quantidade de registros filtrados

@since 16/09/2021
/*/
//-------------------------------------------------------------------
Function WSLPQtdReg( cFromWhere )

Local aArea  := GetArea()
Local cAlias := GetNextAlias()
Local cQuery := " SELECT COUNT(1) TOTAL" + cFromWhere
Local nTotal := 0

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If !(cAlias)->(EOF())
		nTotal := (cAlias)->TOTAL
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} GET provision
Listagem de provisões de Processos

@param page        - Numero da página
@param pageSize    - Quantidade de itens na página
@param cSearchKey  - Código do processo (cajuri)
@param cTpAssJur   - Qual é o tipo de assunto jurídico que deseja filtrar?
@param listFiliais - Indica quais filiais o usuário trabalha

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURLEGALPROCESS/provision

/*/
//-------------------------------------------------------------------
WSMETHOD GET provision WSRECEIVE page, pageSize, searchKey, tipoAssjur, listFiliais WSREST JURLEGALPROCESS
Local oResponse   := Nil
Local nPage       := Self:page
Local nPageSize   := Self:pageSize
Local cSearchKey  := Self:searchKey
Local cTpAssJur   := Self:tipoAssjur
Local cListFil    := Self:listFiliais

	Self:SetContentType("application/json")

	oResponse := getProvision(cSearchKey,cTpAssJur,nPage,nPageSize,cListFil)
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getProvision
Retorna as provisões do processo

@param cSearchKey  - Código do processo (cajuri)
@param cTpAssJur   - Qual é o tipo de assunto jurídico que deseja filtrar?
@param nPage       - Numero da página
@param nPageSize   - Quantidade de itens na página
@param cListFil    - Indica quais filiais o usuário trabalha

@return json contendo a lista de provisões
/*/
//-------------------------------------------------------------------
Static Function getProvision(cSearchKey,cTpAssJur,nPage,nPageSize,cListFil)
Local oResponse    := JsonObject():New()
Local cQrySelect   := ""
Local cQryFrom     := ""
Local cQryWhere    := ""
Local cQryOrder    := ""
Local cQuery       := ""
Local aSQLRest     := Ja162RstUs(,,,.T.)
Local cAlias       := GetNextAlias()
Local cQry         := ""
Local cExists      := ""
Local cWhere       := ""
Local cNSZName     := Alltrim(RetSqlName("NSZ"))
Local aFilUsr      := {}
Local cAssJurGrp   := JurTpAsJr(__CUSERID)
Local cCfgTLegal   := J293CfgQry('1', 'true')
Local nQtdRegIni   := 0
Local nQtdRegFim   := 0
Local nQtdReg      := 0
Local nIndexJSon   := 0
Local lHasNext     := .F.

Default cSearchKey  := ""
Default cTpAssJur   := ""
Default nPage       := 1
Default nPageSize   := 10
Default cListFil    := ''

	// -- Processos com NUQ
	cQrySelect :=  " SELECT NSZ.NSZ_FILIAL NSZ_FILIAL "
	cQrySelect +=       " ,NSZ.NSZ_COD    NSZ_COD "
	cQrySelect +=       " ,NVE.NVE_TITULO NVE_TITULO "
	//-- Valores
	cQrySelect +=       " ,(CASE WHEN NSZ.NSZ_VAPROV = 0 "
	cQrySelect +=                " THEN NSZ.NSZ_VLPROV "
	cQrySelect +=                " ELSE NSZ.NSZ_VAPROV END "
	cQrySelect +=        "  ) VALOR "

	cQryFrom   := " FROM " + cNSZName + " NSZ "
	
	cQryFrom   += " INNER JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom   +=    " ON (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
	cQryFrom   +=    " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
	cQryFrom   +=    " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
	cQryFrom   +=    " AND (NVE.NVE_FILIAL = '" + xFilial("NVE") + "') "
	cQryFrom   +=    " AND (NVE.D_E_L_E_T_ = ' ') "
	cQryFrom   += " JOIN "+ RetSqlName('NUQ') + " NUQ "
	cQryFrom   +=    " ON (NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
	cQryFrom   +=    " AND NUQ.NUQ_INSATU  = '1' "
	cQryFrom   +=    " AND NUQ.NUQ_FILIAL  = NSZ.NSZ_FILIAL "
	cQryFrom   +=    " AND NUQ.D_E_L_E_T_ = ' ' ) "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )

		If !Empty(cListFil)
			aFilUsr := {cListFil,','}
		Else
			aFilUsr := JURFILUSR( __CUSERID, "NSZ" )
		Endif

		cQryWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQryWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cQryWhere += " AND NSZ.D_E_L_E_T_ = ' ' "
	cQryWhere += " AND NSZ.NSZ_SITUAC = '1' "
	cQryWhere += " AND NSZ.NSZ_TIPOAS IN (" + cAssJurGrp + ") " // Permissões do grupo do usuário

	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cWhere    :=  " AND " + JurFormat("NT9_NOME", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " AND (" + SUBSTR(JurGtExist(RetSqlName("NT9"), cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists

		cWhere    :=  " AND " + JurFormat("NUQ_NUMPRO", .F.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NUQ"), cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists

		cWhere    :=  " AND " + JurFormat("NSZ_DETALH", .T.,.T.) + " Like '%" + cSearchKey + "%')"
		cExists   :=  " OR " + SUBSTR(JurGtExist(cNSZName, cWhere, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
	EndIf

	// -- Preferencias de usuário
	If !Empty(cTpAssJur)
		cWhere += " AND NSZ.NSZ_TIPOAS IN " + FormatIn(cTpAssJur, ",") 
	Endif

	cQryWhere  += VerRestricao(,, cAssJurGrp)

	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest)+")"
	EndIf

	// -- Processos sem NUQ (filho de procurações)
	If !Empty(cCfgTLegal)
		cQry += " UNION ALL "

		cQry +=  " SELECT NSZ.NSZ_FILIAL NSZ_FILIAL "
		cQry +=       " ,NSZ.NSZ_COD    NSZ_COD "
		cQry +=       " ,NVE.NVE_TITULO NVE_TITULO "
		cQry +=       " ,(CASE WHEN NSZ.NSZ_VAPROV = 0 "
		cQry +=                " THEN NSZ.NSZ_VLPROV "
		cQry +=                " ELSE NSZ.NSZ_VAPROV END "
		cQry +=        "  ) VALOR "

		cQry += " FROM " + cNSZName + " NSZ "

		cQry +=    " INNER JOIN " + RetSqlName('NVE') + " NVE "
		cQry +=       " ON (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
		cQry +=       " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
		cQry +=       " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
		cQry +=       " AND (NVE.NVE_FILIAL = '" + xFilial("NVE") + "') "
		cQry +=       " AND (NVE.D_E_L_E_T_ = ' ') "

		cQry += cQryWhere

		cQry +=  " AND NSZ.NSZ_TIPOAS IN " + FormatIn(cCfgTLegal, ",") // -- Configuração do produto

		cQry += " AND NOT EXISTS ( "
		cQry +=             " SELECT 1 FROM " + RetSqlName("NUQ") + " NUQ "
		cQry +=             " WHERE "
		cQry +=                 " NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL "
		cQry +=                 " AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
		cQry +=                 " AND NUQ.D_E_L_E_T_ = ' ' "
		cQry +=             " ) "

	EndIf

	//Define a ordenação da query
	cQryOrder := " ORDER BY VALOR DESC"

	cQuery := ChangeQuery(cQrySelect + cQryFrom + cQryWhere + cQry + cQryOrder)

	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['processes'] := {}

	nQtdRegIni   := ((nPage-1) * nPageSize)
	nQtdRegFim   := (nPage * nPageSize)
	nQtdReg      := 0

	While (cAlias)->(!Eof()) .AND. nIndexJSon <= nPageSize

		nQtdReg++
		// Verifica se o registro está no range da pagina
		if (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndexJSon++

			Aadd(oResponse['processes'], JsonObject():New())
			aTail(oResponse['processes'])['processBranch']      := (cAlias)->NSZ_FILIAL
			aTail(oResponse['processes'])['processId']          := (cAlias)->NSZ_COD
			aTail(oResponse['processes'])['caso']               := JConvUTF8((cAlias)->NVE_TITULO)
			aTail(oResponse['processes'])['atualizedprovision'] := ROUND((cAlias)->VALOR,2)
			
		Elseif (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
			Exit
		Endif

		(cAlias)->(DbSkip())

	End

	// Verifica se há uma proxima pagina
	oResponse['hasNext'] := If(lHasNext, "true" ,"false")

	(cAlias)->( DbCloseArea() )

RETURN oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} MigraLogo
Migra a logomarca para a subpasta em anexos

@param cCajuri  - Código do processo (cajuri)

/*/
//-------------------------------------------------------------------
Static Function  MigraLogo(cCajuri)
Local cLogo  := JurGetDados("NSZ",1,xFilial("NSZ") + cCajuri, "NSZ_BITMAP")
Local cSpool := Iif("Linux" $ GetSrvInfo()[2],"/spool/","\spool\")
Local cFile  :=  cCajuri + "_" + AllTrim(cLogo)
Local cQuery := ""
Local cAlias := ""

	// Verifica se tem Logomarca para migrar
	If !Empty(cLogo)
		cAlias := GetNextAlias()

		cQuery += " SELECT COUNT('1') LOGOMARCA "
		cQuery +=   " FROM " + RetSqlName("NUM") +"  NUM "
		cQuery +=  " WHERE NUM_SUBPAS = 'NSZ_Logomarca' "
		cQuery +=    " AND D_E_L_E_T_ = ' ' "
		cQuery +=    " AND NUM_FILENT = '" + xFilial('NSZ') + "' "
		cQuery +=    " AND NUM_CENTID = '" + cCajuri + "' "
		cQuery +=    " AND NUM_DESC LIKE '" + cFile + "%' "

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
		// Verifica se já foi migrada
		If ( (cAlias)->LOGOMARCA == 0 ) .And. RepExtract( cLogo, cSpool + cFile )

			If File( cSpool + cFile + ".bmp")
				cFile += ".bmp"
			Else
				cFile += ".jpg"
			EndIf

			J026Anexar("NSZ", xFilial("NSZ"), cCajuri, cCajuri, cSpool + cFile,/*lIntPFS*/ ,"NSZ_Logomarca")
			// Apaga o arquivo da Spool
			FErase(cSpool + cFile)

		EndIf
		(cAlias)->( dbCloseArea() )
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TmpPicture
Gera imagem temporária para o relatório

@param 	cUser      - Usuário logado
		cThread    - Código da thread 
		nOperation - Operação (1=Cria; 2=Exclui)

/*/
//-------------------------------------------------------------------
Static Function TmpPicture( cUser, cThread, nOperation )
Local lRet 	 	:= .T.
Local aArea 	:= GetArea()
Local aAreaNSZ	:= NSZ->( GetArea() )
Local aAreaNQ3	:= NQ3->( GetArea() )
Local cTmpAlias	:= GetNextAlias()
Local cTmpDir	:= "\spool\" + cUser + cThread + "\""
Local aFiles	:= {}
Local nI	 	:= 0
Local cSQL		:= ""
Local cCajuri   := ""
Local cNomeArq  := ""

Default nOperation := 1 //1=cria Imagens - 2=Apaga Imagens
	
	cTmpDir := Iif("Linux" $ GetSrvInfo()[2],StrTran(cTmpDir, "\", "/" ), cTmpDir)

	If nOperation == 1 //Cria dados

		/* Gera o diretorio */
		lRet :=  ( MakeDir(cTmpDir) == 0 )

		If lRet

			cSQL := " SELECT "
			cSQL +=        " NUM_COD, " 
			cSQL +=        " NUM_ENTIDA, "
			cSQL +=        " NUM_CENTID, "
			cSQL +=        " NUM_NUMERO, "
			cSQL +=        " NUM_DOC, "
			cSQL +=        " NUM_EXTEN"
			cSQL +=   " FROM " + RetSqlName('NUM')+ " NUM"
			cSQL += " INNER JOIN " + RetSqlName('NQ3')+ " NQ3"
			cSQL +=  "	ON (NQ3_CUSER = '" + cUser + "'"
			cSQL +=  "	AND NQ3_SECAO = '" + cThread + "'"
			cSQL +=  "	AND NQ3_FILORI = NUM_FILENT"
			cSQL +=  "	AND NUM_CENTID = NQ3_CAJURI)"
			cSQL += " WHERE NUM.D_E_L_E_T_ = ' '"
			cSQL += " AND NQ3.D_E_L_E_T_ = ' '"
			cSQL += " AND NUM_SUBPAS = 'NSZ_Logomarca'"
			cSQL += " AND NUM_FILENT = '" + xFilial('NSZ') + "' "
			cSQL += "ORDER BY NUM.R_E_C_N_O_ DESC "

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cTmpAlias, .T., .F.)

			(cTmpAlias)->( dbGoTop() )

			If (cTmpAlias)->( !Eof() )
					cCajuri := AllTrim( (cTmpAlias)->NUM_CENTID )
					cNomeArq := AllTrim( (cTmpAlias)->NUM_DOC ) + AllTrim( (cTmpAlias)->NUM_EXTEN )
					oAnexo := WSgetAnexo('NSZ', cCajuri, /*cCodProc*/, 'NSZ_Logomarca' )
					oAnexo:Exportar("",cTmpDir, AllTrim((cTmpAlias)->NUM_NUMERO), cNomeArq)

					fRename(cTmpDir + cNomeArq , cTmpDir + cCajuri + AllTrim( (cTmpAlias)->NUM_EXTEN ) )
			EndIf

			(cTmpAlias)->( dbCloseArea() )
		Else
			// "Não foi possivel criar o diretório temporário em: "
			JurMsgErro( STR0048 + cTmpDir )
		EndIf
	Endif

	If nOperation == 2 //Apaga o diretorio temp.

		aFiles := Directory( cTmpDir  + "\*.*")

		For nI := 1 To Len( aFiles )
			lRet := ( FErase( cTmpDir  + "\" + aFiles[nI][1] ) == 0 )
		Next nI

		if lRet
			DirRemove( cTmpDir )
		EndIF
	Endif

	NQ3->( RestArea( aAreaNQ3 ) )
	NSZ->( RestArea( aAreaNSZ ) )
	RestArea( aArea )

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} GET ExpJurr100
Exporta os andamentos de um processo

@param codProc   - Código do Processo

@since 17/08/2022

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURLEGALPROCESS/exportJurr100/0000000001
/*/
//-------------------------------------------------------------------
WSMETHOD GET ExpJurr100 PATHPARAM codProc WSREST JURLEGALPROCESS
	Local cCajuri   := AllTrim(Self:codProc)
	Local cUser     := __CUSERID
	Local cCaminho  := "\spool\"
	Local cNomerel  := JurTimeStamp(1) + "_relatoriodeandamento_" + cCajuri + "_" + cUser
	Local oResponse := JsonObject():New()

	// Tratamento para S.O Linux
	cCaminho := JRepDirSO( cCaminho)

	JURR100(cCajuri, .F., cNomerel, cCaminho )

	//-- Monta Json para o Download
	Self:SetContentType("application/json")
	oResponse['operation'] := "ExportAndamento"
	oResponse['export']    := {}
	Aadd(oResponse['export'], JsonObject():New())

	oResponse['export'][1]['namefile'] := JConvUTF8(cNomerel + ".pdf")
	oResponse['export'][1]['filedata'] := encode64(DownloadBase(cCaminho + cNomerel + ".pdf"))

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.
