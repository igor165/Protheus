#include 'totvs.ch'
#include 'FWMVCDEF.CH'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQ_LOG_DES		"job_eventodespesa.log"
#DEFINE DESP_SEM_RE		"despesas_sem_resumo.log"
#DEFINE EXP_ARQ_LOG		"job_benef_expostos.log"
#DEFINE DEBUG_EXP		"debug_expostos.log"
#DEFINE EXP_SEM_COB		"benef_exp_sem_cobertura.log"
#DEFINE BANCO			Alltrim(Upper(TCGetDb()))
#DEFINE NAT_CODIGO 		1
#DEFINE NAT_DIAS 		2
#DEFINE NAT_DATCAR		3
#DEFINE NAT_IDADE		4
#DEFINE NAT_IDADE2		5
#DEFINE NAT_SEXO		6
#DEFINE NAT_NIVEL		7
#DEFINE NAT_CODSUP		8
#DEFINE TERAPIAS		"'20104243','20104251','20104278','20104286','20104294','20104308','20104430','30909031','30909139','30909147','31303269','31303293','40401014','41203070','41203089','41203097'"//TODO Levar essa configuracao para a terminologia TUSS
#DEFINE MV_PLCENDB		GetNewPar("MV_PLCENDB",.F.)
#DEFINE MV_STATISS		GetNewPar("MV_STATISS",.F.)
#DEFINE nMV_QTANSIP		GetNewPar("MV_QTANSIP",0)//Quantidade de anos para olhar no historico
#DEFINE cMV_DTCOSIP		GetNewPar("MV_DTCOSIP","")//Data de corte para nao olha no historico
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

#DEFINE PROCEDIME	01
#DEFINE ISCONSULT	02
#DEFINE CLASIPSER	03
#DEFINE CLASIPESP	04
#DEFINE CLASIPINT	05
#DEFINE QTDEREAL	06
#DEFINE DATAPROC	07
#DEFINE TIPOPROC	08
#DEFINE VLRDESP		09
#DEFINE TRIMOCOR	10
#DEFINE GRUPOINT	11
#DEFINE REGIMEINT	12
#DEFINE CHVGUIGRV	13
#DEFINE __MATRIC	14
#DEFINE __UF		15
#DEFINE __CID		16
#DEFINE __IDADE		17
#DEFINE __DATINT	18
#DEFINE __HORAINT	19
#DEFINE DATALTA		20
#DEFINE HORAALTA	21
#DEFINE TRIMRECO	22
#DEFINE QTDNASVIV	23
#DEFINE __DENTE		24
#DEFINE CHVGUIINT	25
#DEFINE CHVRESUMO	26
#DEFINE CLASHDESC   27
#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02/13"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"

#DEFINE TP_PROCEDIM "0"
#DEFINE TP_MATERIAL "1"
#DEFINE TP_MEDICAME "2"
#DEFINE TP_TAXAS 	"3"
#DEFINE TP_DIARIAS 	"4"
#DEFINE TP_ORTESE 	"5"
#DEFINE TP_PACOTE 	"6"
#DEFINE TP_GASES 	"7"
#DEFINE TP_ALUGUEIS "8"
#DEFINE TP_OUTROS 	"9"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCARDESP

Funcao criada para carregar os eventos x despesas referente ao SIP para a central de obrigacoes (B3L)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCARDESP()
	Local aSay    	:= {}
	Local aButton 	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importacao de Eventos x Despesas - SIP'
	Local cDesc1	:= 'Esta rotina fará a importação de eventos x despesas referente ao SIP para o '
	Local cDesc2	:= 'núcleo de informações e obrigações.'
	Local cDesc3	:= ""
	Local lOk		:= .T.
	Local cDataRef	:= "" //Data informada pelo usuaio
	Local cTipData	:= "" //1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cTipProc	:= "" //Tipo de processamento 1=Evento x Desp;2=Calc ben exp;3=Ambos
	Local cLocDigIgn:= "" //Tipo de processamento 1=Evento x Desp;2=Calc ben exp;3=Ambos
	Local lGerRepas	:= .F. //Indica se gera T. ou nao .F. para beneficiario de reciprocidade
	Local oObj      := FWSX1Util():New()
	Local aPergunte :={}
	Local lPergNew     := .F.

	oObj:AddGroup("PLSCARDESN")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSCARDESN")

	If len(apergunte) > 1
		lPergNew:=len(apergunte[2]) > 0
	endif

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 1, Iif (!lPergNew,Pergunte('PLSCARDESP',.T.,Titulo,.F.),Pergunte('PLSCARDESN',.T.,Titulo,.F.)) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton, , 200, 450 )

	If MV_PLCENDB
		MsgInfo("Parametro MV_PLCENDB definido como .T. Somente um JOB sera iniciado")
	EndIf

	If nOpc == 2

		If lPergNew .And. Valtype(mv_par01) == "D"
			lPergNew:=.F. //está usando o novo pergunte, mas não atualizou os JOBS no configurador.
		endif

		cDataRef	:= IIF (!lPergNew,DTOS(mv_par01),"")
		cTipData	:= iif (!lPergNew,AllTrim(Str(mv_par02)),AllTrim(Str(mv_par01)))
		cRegANS		:= iif (!lPergNew,mv_par03,mv_par02)
		cTipProc	:= iif (!lPergNew,AllTrim(mv_par04),AllTrim(mv_par03))
		lGerRepas	:= iif (!lPergNew,mv_par05 == 1,IIF(Valtype(mv_par04) == "N",mv_par04 == 1,.F.))
		cLocDigIgn	:= RetLocIgn()

		If !Empty(cDataRef) .Or. !Empty(cTipData) .Or. !Empty(cRegANS) .Or. !Empty(cTipProc)
			Processa( { || lOk := PLSJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn) },'Aguarde','Processando...',.F.)
		Else
			MsgInfo("Para confirmar o processamento informe todos os parâmetros.","TOTVS")
			Pergunte('PLSCARDESP',.T.,Titulo,.F.)
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', CENDTHRL("E") + " PLSJOBSIP NAO FOI INICIADO!" , 0, 0, {})
		EndIf

	EndIf
	FreeObj(oObj)
	oObj := Nil

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se todas perguntas foram respondidas

@return lRet	Verdadeiro (.T.) se todas as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta(lPergNew)
	Local lRet	     := .T.
	Local cMsg	     := ""
	Default lPergNew := .F.

	If Empty(mv_par01)
		lRet := .F.
		IIF (!lPergNew,cMsg += "Qual a data de referencia ?" + CRLF,cMsg += "Considerar a data de ?" + CRLF)
	EndIf

	If Empty(mv_par02)
		lRet := .F.
		IIF (!lPergNew,cMsg += "Considerar a data de ?" + CRLF,cMsg += "Qual a operadora padrao ?" + CRLF)
	EndIf

	If Empty(mv_par03)
		lRet := .F.
		IIF (!lPergNew,cMsg += "Qual a operadora padrao ?" + CRLF,cMsg += "Tipo de processamento ?" + CRLF)
	EndIf

	If Empty(mv_par04)
		lRet := .F.
		cMsg += "Tipo de processamento ?" + CRLF
	EndIf

	If Empty(mv_par05) .And. !lPergNew
		lRet := .F.
		cMsg += "Gerar para benef. de reciprocidade ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSJOBSIP

Funcao criada para disparar os JOBs de importacao de dados para as tabelas do SIP na Central de Obrigacoes
JOB PLSIPDES - job de eventos x despesas (SADT e GHI)
JOB PLSIPACU - job de alto custo
JOB PLSIPREE - job de reembolso
JOB PLSIPEXP - job de beneficiarios expostos
JOB PLSSIPTOT- job de totalizacao

@param cDataRef	Data de referencia para limite da pesquisa
@param cTipData	Tipo de data 1=Digitacao; 2=Pagamento; 3=Procedimento
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProc	Tipo de processamento: 1-Despesa, 2-Alto custo
@param lGerRepas	Indica se ira (.T.) importar registros referentes a beneficiarios de reciprocidade
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn,lPriCom,lAuto)
	Local nFor			:= 0
	Local nTo			:= 3
	Local nQuinzena		:= 1
	Local nThread		:= 0
	Local lContinua		:= .T. //Indica se deve .T. ou nao .F. continuar
	Local lDadosHist	:= !(nMV_QTANSIP == 0)//Indica se .T. vou olhar dados historicos ou nao .F.
	Local lQryInter		:= .F. //Query de SADT BD5 .F. ou internacao BE4 .T.
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cCodComp		:= ""
	Local lMV_PLCENDB	:= MV_PLCENDB
	Default cDataRef	:= DTOS(dDataBase)
	Default cTipData	:= '1'
	Default cRegANS		:= '000000'
	Default cTipProc	:= '1,2,3,4'
	Default lGerRepas	:= .F.
	Default cLocDigIgn	:= ""
	Default lPriCom     := .f.
	Default lAuto       := .F.

	cTriRec := DataTrimestre(cDataRef)
	PlsLogFil("[" + cTrirec + "]PLSJOBSIP:" + CENDTHRL("I") + " Inicio criação dos jobs PLSJOBSIP ",ARQ_LOG_DES)
	If lMV_PLCENDB
		nTo := 1
	EndIf
	//Processamento de SADT+Internacao
	If lContinua .And. '1' $ cTipProc

		For nFor := 1 TO nTo //Um job para cada mes do trimestre

			nThread := nFor
			nQuinzena := 1
			lQryInter := .F.

			If !lAuto
				PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)//JOB para guias BD5
				Sleep(2000)
			Else
				PLSIPDES(cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)//para guias BD5

			Endif
			If cTipData == "3" //Procediento
				nQuinzena := 2
			Else //Digitacao,Procedimento
				lQryInter := .T.
			EndIf
			If !lAuto
				PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)
				Sleep(2000)
			Else
				PLSIPDES(cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)

			Endif
		Next nFor

		If lDadosHist
			If !lPriCom
				lDadosHist:=.F.
			Endif
		Endif

		If lDadosHist
			lQryInter := .F.
			nQuinzena := 1
			nThread := 1
			PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
			StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,lDadosHist,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)
			Sleep(2000)
		EndIf

	EndIf

	//Processamento de Guias de Capitação
	If lContinua .And. '1' $ cTipProc .And. cTipData $ "2/4" .And. !lAuto

		For nFor := 1 TO nTo //Um job para cada mes do trimestre

			nThread := nFor
			nQuinzena := 1
			lQryInter := .F.

			PlsLogFil("[" + cTrirec + "]TRBCAP " + NomeJob(lQryInter,.F.) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
			StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F.,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,.T.,"TRBCAP")
			Sleep(2000)

			lQryInter := .T.

			PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
			StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,.T.,"TRBCAP")
			Sleep(2000)

		Next nFor

	EndIf
	//Processamento de de alto custo
	If lContinua .And. '2' $ cTipProc
		StartJob("PLSIPACU",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn)
		Sleep(2000)
	EndIf

	//Processamento de reembolso
	If lContinua .And. '3' $  cTipProc

		If cTipData $ "1,3"//Digitacao,Procedimento

			For nFor := 1 TO nTo //Um job para cada mes do trimestre

				PlsLogFil("[" + cTrirec + "] PLSIPREE " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nFor)) + AllTrim(Str(1)) + "):"+ CENDTHRL("I") +" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPREE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,nFor)
				Sleep(2000)

			Next nFor

		ElseIf cTipData $ "2/4"//Pagamento ou Data do Pagamento

			PlsLogFil("[" + cTrirec + "] PLSIPREE " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(0)) + AllTrim(Str(1)) + "):"+ CENDTHRL("I") +" StartJob",ARQ_LOG_DES)
			StartJob("PLSIPREE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,0)
			Sleep(2000)

		EndIf

	EndIf

	//Processamento de beneficiarios expostos
	If lContinua .And. '4' $ cTipProc

		cTriRec := DataTrimestre(cDataRef)

		If LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,"",@cCodComp,cRegANS)

			PlsAtuMonitor("Limpeza de expostos")
			PlsLogFil("[" + cTrirec + "] PLSIPEXP"+CENDTHRL("I")+" Limpeza - Inicio",ARQ_LOG_DES)
			LimpaExpostos(cRegANS,cCodObri,cAnoComp,cCodComp)
			PlsLogFil("[" + cTrirec + "] PLSIPEXP"+CENDTHRL("I")+" Limpeza - Termino",ARQ_LOG_DES)

		EndIf

		aBenef := ListaBenef(cDataRef)
		nLen := IIf(lMV_PLCENDB,1, Len(aBenef))
		For nFor := 1 TO nLen//Um Job para cada range de recnos BA1
			PlsLogFil("[" + cTrirec + "] PLSIPEXP (" + AllTrim(Str(nFor)) + "):"+CENDTHRL("I")+" StartJob - Inicio",ARQ_LOG_DES)
			StartJob("PLSIPEXP",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,aBenef[nFor],nFor,cLocDigIgn)
			PlsLogFil("[" + cTrirec + "] PLSIPEXP (" + AllTrim(Str(nFor)) + "):"+CENDTHRL("I")+" StartJob - Termino",ARQ_LOG_DES)
			Sleep(2000)
		Next nFor

	EndIf

	//Job de finalizacao - migra os dados de despesas  da B3Q para B3L totalizando os itens
	If lContinua .And. '5' $  cTipProc

		cTriRec := DataTrimestre(cDataRef)

		If LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,"",@cCodComp,cRegANS)
			CENDELTOT(cRegANS,cCodObri,cAnoComp,cCodComp)
		EndIf
		If !lAuto
			StartJob("PLSSIPTOT",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cRegANS,cDataRef,.F.)
		Else
			PLSSIPTOT(cEmpAnt,cFilAnt,cRegANS,cDataRef,.F.)
		Endif

	EndIf

	PlsLogFil("[" + cTrirec + "]PLSJOBSIP:"+ CENDTHRL("I") + " Jobs criados PLSJOBSIP",ARQ_LOG_DES)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENDELTOT

Funcao criada para deletar os totais antigos

@author everton.mateus
@since 10/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function CENDELTOT(cCodOpe,cCodObri,cAnoComp,cCodComp,cItem,cTrioco,cUF)
	Local cSql := ""
	Local nRet := 0
	Local cTrim := cAnoComp + SubStr(cCodComp,2,2)
	Default cItem		:= ""
	Default cTrioco	:= ""
	Default cUF	:= ""

	PlsLogFil("["+cTrim+"]CENDELTOT" + CENDTHRL("I") + "Inicio",ARQ_LOG_DES)
	PlsAtuMonitor("Limpando despesas " + cAnoComp +"-"+ cCodComp)

	cSql := " DELETE FROM " + RetSqlName('B3L')
	cSql += " WHERE "
	cSql += "	B3L_FILIAL = '" + xFilial('B3L') + "' "
	cSql += "	AND B3L_CODOPE = '" + cCodOpe + "' "
	cSql += "	AND B3L_CODOBR = '" + cCodObri + "' "
	cSql += "	AND B3L_ANOCMP = '" + cAnoComp + "' "
	cSql += "	AND B3L_CDCOMP = '" + cCodComp + "' "
	cSql += "	AND B3L_EVEDES = B3L_MATRIC "
	If !Empty(cItem)
		cSql += "	AND B3L_CLAINT = '" + cItem + "' "
		cSql += "	AND B3L_TRIOCO = '" + cTrioco + "' "
		cSql += "	AND B3L_UF = '" + cUF + "' "
	EndIf
	PlsLogFil("["+cTrim+"]CENDELTOT" + CENDTHRL("I") + " Limpa totalizadores: " + cSql,ARQ_LOG_DES)

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0
		If SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		EndIf
	Else
		PlsLogFil("["+cTrim+"]CENDELTOT"+ CENDTHRL("E") + " - " + TCSQLError(),ARQ_LOG_DES)
	Endif

	PlsLogFil("["+cTrim+"]CENDELTOT" + CENDTHRL("I") + " Termino",ARQ_LOG_DES)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPDES

Funcao criada para carregar eventos x despesas na tabela temporaria do SIP - B3Q

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
@param nThread		Numero da thread
@param nQuinzena	Indica se 1 - primeira ou 2 - segunda quinzena do mes a ser processada
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPDES(cEmp,cFil,lDadosHist,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,lJob,lCapit,cAlias)
	Local lRetorno		:= .T.
	Local lPacote		:= .F.
	Local lProSemCla	:= .F.//.T. - procedimento tem classificacao; .F. - procedimento NAO tem classificacao
	Local lIncDesp		:= .F.
	Local cChaveGuia	:= ""
	Local cChaveProd	:= ""
	Local cMatric		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cGuiInt		:= ""
	Local cChvRes		:= ""
	Local cClaHDesc     := ""
	Local cChvGuiGrv	:= ""
	Local nRecnoBD7		:= 0
	Local nQtdRegPro	:= 0 //Quantidade de registros processados
	Local nQtdRegLid	:= 0 //Quantidade de registros lidos
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local aProSemCla	:= {}
	Local aClasEspe		:= {}
	Local aProduto		:= {}
	Local aForSeg		:= {}
	Local nPulaRepa		:= 0
	Local nPulaProd		:= 0
	Local nPulaEstor	:= 0
	Local nPulaSolic	:= 0
	Local nSemClass		:= 0
	Local nPacote		:= 0
	Local nRegSel		:= 0
	Local nQtdPacote	:= 0 //Quantidade de registros procesados pelo pacote
	Local nIdade		:= 0 //Idade do beneficiario
	Local nTerminal		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cMotivo 		:= ""
	Local cCabLog		:= ""
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.
	Local lVincIntVld	:= .F.
	Local cAliUsa       := "BE4"
	Local cSerBr8       := ""
	Local aAreaBR8      := {}
	Local lDtPag        := .F.
	Private lB3Q_EVDRES	:= .F.//B3Q->(FieldPos("B3Q_EVDRES")) > 0
	Private lB3L_EVDRES	:= .F.//B3L->(FieldPos("B3L_EVDRES")) > 0
	Private lB3Q_CLASSH := .F.//B3Q->(fieldpos("B3Q_CLASSH")) > 0
	Default lDadosHist	:= .F.
	Default nThread		:= 0
	Default nQuinzena	:= 1
	Default cLocDigIgn	:= ""
	Default lQryInter	:= .F.
	Default lJob	    := .T.
	Default cAlias	 	:= 'TRBDES'
	Default lCapit      := .F.

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	PlsAtuMonitor(cAlias+" " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")")

	lB3Q_EVDRES	:= B3Q->(FieldPos("B3Q_EVDRES")) > 0
	lB3L_EVDRES	:= B3L->(FieldPos("B3L_EVDRES")) > 0
	lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0
	If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
		PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
		lRetorno := .F.
	EndIf

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	If lRetorno .And. Empty(cLocDigIgn)
		cLocDigIgn := RetLocIgn()
	EndIf

	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,nQuinzena,"PLSIPDES") } )
	BEGIN SEQUENCE

		Inicializa()

		lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},nQuinzena,.T.,cLocDigIgn,lQryInter,"",lDadosHist)
		nRegSel := (cAlias)->Total
		CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		(cAlias)->(dbCloseArea())

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},nQuinzena,.F.,cLocDigIgn,lQryInter,cChvGuiGrv,lDadosHist)
			If lRetorno

				aClasEspe := IniciaEspecialidade()
				aProduto := IniciaProduto()

				While !(cAlias)->(Eof())

					cTxt := ""
					cMotivo := ""
					lProSemCla := .T.
					lIncDesp := .F.
					nQtdRegLid++
					nTerminal++
					LimpaArray(@aClasEven)
					nRecnoBD7	:= (cAlias)->RECNOBD7
					cChaveGuia	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
					lPacote		:= (cAlias)->BR8_TPPROC == TP_PACOTE
					lPacote     :=.F.
					If lQryInter
						cGuiInt := AllTrim((cAlias)->BE4_GUIINT)
					Else
						cGuiInt := AllTrim((cAlias)->BD5_GUIINT)

						If !Empty(cGuiInt)
							cAliUsa:="BD5"
						endIf

					EndIf

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						PlsAtuMonitor("PLSSIPDES " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "): " + AllTrim(Str(nQtdRegPro)) + " processados de " + AllTrim(Str(nQtdRegLid)) + " lidos. Total de Selecionados " + AllTrim(Str(nRegSel)) )
						PlsLogFil(cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nQtdRegPro)) + " processados de " + AllTrim(Str(nQtdRegLid)) + " lidos. Total de Selecionados " + AllTrim(Str(nRegSel)) ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nQtdRegLid)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					/*		ALGUNS DESCARTES JA FACO AQUI		*/

					If !lGerRepas .And. PulaRepasse(cAlias,@cChaveGuia)//Despreza usuario de grupo empresa de reciprocidade
						nPulaRepa++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Usuario pertence a contrato de reciprocidade"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias) //Vou pegar o produto na familia ou beneficiario

					If PulaProduto(cAlias,cChaveProd,aProduto)//Despreza produto nao informado a ANS
						nPulaProd++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					If  (cAlias)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON + "," + G_RES_INTER .And. PulaEstorno(cAlias,@cChaveGuia)//Despreza guias de consulta e servico estornadas
						nPulaEstor++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Guia estornada"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					If (cAlias)->BD7_TIPGUI == G_SOL_INTER
						nPulaSolic++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Guia de solicitacao de internacao"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						ProximaGuia(cAlias,cChaveGuia)
						Loop

					EndIf

					iF cTipData == "4"
						lDtPag := .T.
					EndIf

					lVincIntVld := (cAlias)->BD7_TIPGUI $ G_SADT_ODON + ',' + G_HONORARIO + ',' + G_RES_INTER .AND. !Empty(cGuiInt) .AND. RetDadInt(cGuiInt,cChaveGuia,(cAlias)->BD7_TIPGUI,,,lMV_STATISS,cAliUsa,lDtPag)[1]

					/*		VOU CHAMAR AS CLASSIFICACOES		*/
					//Para procedimentos sem classificacao como mat/med por exemplo eu somo o valor e atribuo ao evento principal
					If !lPacote .And. Empty((cAlias)->BR8_TPCONS) .And. Empty((cAlias)->BR8_CLASIP) .And. Empty((cAlias)->BR8_CLASP2);
							.AND. ( (cAlias)->BD7_TIPGUI $ G_SADT_ODON .And. !( (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS ) );
							.AND. ( Empty(cGuiInt) .OR. lVincIntVld )

						cCodPro := AllTrim((cAlias)->BD7_CODPAD) + AllTrim((cAlias)->BD7_CODPRO)
						lConsulta := PlsIsCon((cAlias)->BD7_CODPAD,(cAlias)->BD7_CODPRO)
						cDataProc := Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
						cTipoProc := (cAlias)->BR8_TPPROC
						nVlrDesp := (cAlias)->BD7_VLRPAG
						cTrimOcor := DataTrimestre(cDataProc,"3")
						cChvGuiGrv := (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
						cMatric := (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
						cUF     := BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE),(cAlias)->(BD7_CODOPE+BD7_CODLOC+BD7_LOCAL))
						nIdade := Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))
						dDatInt := CTOD("")
						dDatAlta := CTOD("")
						cHoraAlta := ""
						cTrimReco := DataTrimestre(DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit),"3")
						nQtdNasViv := 0
						cDente := ""
						cGuiInt := ""
						cClaHDesc := ""
						lIncDesp := .T.

						aClasEven := {/*1*/cCodPro,/*2*/lConsulta,/*3 cClaSIPSer*/"",/*4 cClaSIPEsp*/"",/*5 cClaSIPInt*/"",/*6 nQtdeReal*/0,/*7*/cDataProc,/*8*/cTipoProc,/*9*/nVlrDesp,/*10*/cTrimOcor,;
							/*11 cGrupoInt*/"",/*12 cRegimeInt*/"",/*13*/cChvGuiGrv,/*14*/cMatric,/*15*/cUF,/*16 cCID*/"",/*17*/nIdade,/*18*/dDatInt,/*19 cHoraInt*/"",/*20*/dDatAlta,;
							/*21*/cHoraAlta,/*22*/cTrimReco,/*23*/nQtdNasViv,/*24*/cDente,/*25*/cGuiInt,/*26*/cChvRes,/*27*/cClaHDesc}

						aAdd(aProSemCla,{cRegANS,cCodObri,cAnoComp,cCodComp,cChvGuiGrv,cMatric,(cAlias)->BD7_VLRPAG,aClone(aClasEven)})
						(cAlias)->(dbSkip())
						nSemClass++
						lProSemCla	:= .F.
						lIncDesp	:= .F.

					ElseIf lPacote .And. !lMV_STATISS//Pacote

						cChvGuiGrv := (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
						nQtdPacote := TrataPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,{}/*aBenef*/,nQuinzena,.F./*lCount*/,cLocDigIgn,lQryInter,cChvGuiGrv,lMV_STATISS)//TODO VALIDAR ANTES DE LIBERAR
						nQtdRegPro += nQtdPacote//Isso pode fazer com que os processados sejam mais do que os lidos
						nPacote++
						lIncDesp	:= .F.

					ElseIf (cAlias)->BD7_TIPGUI == G_CONSULTA .OR.; //guias de consulta
							((cAlias)->BD7_TIPGUI $ G_SADT_ODON .And. Empty(cGuiInt)) //guias de sadt sem vinculo com internacao

						lIncDesp := .T.
						aClasEven := ClassSADT(cAlias,cChaveGuia,cTipData,.f.,@nIdade,@aClasEspe,cDataRef,lMV_STATISS,lCapit)

					ElseIf lVincIntVld .And. ((cAlias)->BD7_TIPGUI $ G_SADT_ODON .OR.;//guias de sadt com vinculo com internacao
							(cAlias)->BD7_TIPGUI == G_RES_INTER .OR.; //guias de resumo de internacao
							(cAlias)->BD7_TIPGUI == G_HONORARIO ) //guias de honorario individual


						lIncDesp := .T.
						aClasEven := ClassInternacao(cAlias,cChaveGuia,cTipData,.f.,@nIdade,@aClasEspe,cDataRef,lMV_STATISS,lCapit)

					Else
						cTxt := ""
						cMotivo := ""
						If !Empty(cGuiInt)
							cMotivo := "Chave de solicitacao de internacao nao encontrada"
						Else
							cMotivo := "Chave de solicitacao de internacao nao informada"
							cGuiInt := "nao informada"
						EndIf
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + cMotivo
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						ProximaGuia(cAlias,cChaveGuia)
						lIncDesp := .F.
						Loop

					EndIf

					/*		GRAVACAO DO EVENTO X DESPESA		*/
					If lIncDesp

						cSerBr8:= ""
						BR8->(DbSetOrder(1))
						aAreaBR8   := BR8->(GetArea())

						If BR8->(msSeek(xFilial("BR8")+AllTrim(aClasEven[PROCEDIME])))
							cSerBr8:= Alltrim(BR8->BR8_CLASIP)
						EndIf

						/*		IMPLEMENTACAO DE EXCECOES		*/
						If (AllTrim(aClasEven[PROCEDIME]) == '40601137' .Or. AllTrim(SubStr(aClasEven[PROCEDIME],3)) == '40601137') .Or.  "C3" $ cSerBr8
							If ( nIdade >= 25 .And. nIdade <= 59 )
								aClasEven[CLASIPSER] := 'C3'
								aClasEven[CLASIPESP] := 'C3'
								aClasEven[CLASIPINT] := 'C3'
							Else
								aClasEven[CLASIPSER] := 'C'
								aClasEven[CLASIPESP] := 'C'
								aClasEven[CLASIPINT] := 'C'
							EndIf
						Endif

						If AllTrim(SubStr(aClasEven[PROCEDIME],3)) $ '40808033,40808041,40808173'  .Or.  "C10" $ cSerBr8
							If  nIdade >= 50 .And. nIdade <= 69
								aClasEven[CLASIPSER] := 'C101'
								aClasEven[CLASIPESP] := 'C101'
								aClasEven[CLASIPINT] := 'C101'
							Else
								aClasEven[CLASIPSER] := 'C10'
								aClasEven[CLASIPESP] := 'C10'
								aClasEven[CLASIPINT] := 'C10'
							EndIf
						EndIf

						If AllTrim(aClasEven[PROCEDIME]) $ '40303136,40303250' .Or. AllTrim(SubStr(aClasEven[PROCEDIME],3)) $ '40303136,40303250' .Or. "C14" $ cSerBr8
							If ( nIdade >= 50 .And. nIdade <= 69 )
								aClasEven[CLASIPSER] := 'C14'
								aClasEven[CLASIPESP] := 'C14'
								aClasEven[CLASIPINT] := 'C14'
							else
								aClasEven[CLASIPSER] := 'C'
								aClasEven[CLASIPESP] := 'C'
								aClasEven[CLASIPINT] := 'C'
							endIf
						EndIf

						RestArea(aAreaBR8)

						If TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven,@aForSeg,lProSemCla,lCapit)

							nQtdRegPro++

						Endif

					EndIf

					/*		EVENTO PRINCIPAL RECEBE DEMAIS VALORES		*/
					If SubStr(cChaveGuia,1,Len(cChaveGuia)-3) <> (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)//Se mudei de guia

						If Len(aProSemCla) > 0 //Tenho eventos da guia sem classificacao

							AtuPrinc(aProSemCla,@nQtdRegPro,cCabLog,lCapit)//Atribuo os valores sem classificacao ao evento principal

						EndIf

					EndIf

					/*		PROXIMO EVENTO X DESPESA		*/
					If nRecnoBD7 == (cAlias)->RECNOBD7
						(cAlias)->(dbSkip())

					EndIf

				EndDo //!(cAlias)->(Eof())

			EndIf //CarregaDados()
		EndIf
		//Caso o ultimo registro tenha sido um evento sem classificacao
		If Len(aProSemCla) > 0

			AtuPrinc(aProSemCla,@nQtdRegPro,cCabLog)

		EndIf

		LimpaArray(@aProSemCla)

		/*cStr :=  CRLF + "Pulou " + Alltrim(Str(nPulaRepa)) + " reciprocidade " + CRLF + ;
			"Pulou " + Alltrim(Str(nPulaProd)) + " produtos " + CRLF +;
			"Pulou " +  Alltrim(Str(nPulaEstor)) + " estornos " + CRLF +;
			"Pulou " +  Alltrim(Str(nPulaSolic)) + " solicitações " + CRLF +;
			"Total de Itens sem classificação " +  Alltrim(Str(nSemClass)) + " " + CRLF +;
			"Total de Processados " +  Alltrim(Str(nQtdRegPro)) + " " + CRLF +;
			"Total de Lidos " +  Alltrim(Str(nQtdRegLid)) + " " + CRLF +;
			"Total de Selecionados " +  Alltrim(Str(nRegSel)) + " " + CRLF +;
				"Total de Pacotes " +  Alltrim(Str(nPacote)) + " " + CRLF*/

		//PlsLogFil(cCabLog + CENDTHRL("I") + " Resultado " + cStr,ARQ_LOG_DES)

	END SEQUENCE
	ErrorBlock(bBlock)

	If lRetorno .And. Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	PlsLogFil(cCabLog + CENDTHRL("I") + " Termino " ,ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno
//--------------------------------------------------------------------------------------------------
		/*/{Protheus.doc} PLSIPACU

		Funcao criada para carregar despesa de alto custo na tabela temporaria do SIP - B3Q

		@param cEmp			Empresa do sistema
		@param cFil			Filial do sistema
		@param cDataRef	Data de referencia
		@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
		@param cRegANS		Numero de registro da operadora na ANS
		@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
		@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

		@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

		@author timoteo.bega
		@since 26/01/2016
		/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPACU(cEmp,cFil,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn)
	Local lRetorno		:= .T.
	Local cChaveGuia	:= ""
	Local cChaveProd	:= ""
	Local cMatric		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= 'TRBACU'
	Local nRecnoBD7		:= 0
	Local nTerminal		:= 0
	Local nIncluidos	:= 0
	Local nRegSel		:= 0
	Local nThread		:= 0
	Local nQuinzena		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cCabLog		:= ""
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local aClasEspe		:= {}
	Local aProduto		:= {}
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.
	Private lB3Q_EVDRES	:= .F.
	Private lB3L_EVDRES	:= .F.
	Private lB3Q_CLASSH := .f. //B3Q->(fieldpos("B3Q_CLASSH")) > 0

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')
	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob() + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	PlsAtuMonitor("PLSIPACU: importando alto custo" )

	lB3Q_EVDRES	:= B3Q->(FieldPos("B3Q_EVDRES")) > 0
	lB3L_EVDRES	:= B3L->(FieldPos("B3L_EVDRES")) > 0
	lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0

	If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
		PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
		lRetorno := .F.
	EndIf

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	If Empty(cLocDigIgn)
		cLocDigIgn := RetLocIgn()
	EndIf

	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,nQuinzena,"PLSIPACU") } )
	BEGIN SEQUENCE

		aClasEspe := IniciaEspecialidade()
		aProduto := IniciaProduto()

		lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,0,{},1,.T.,cLocDigIgn)
		nRegSel := (cAlias)->Total
		CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		(cAlias)->(dbCloseArea())

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,0,{},1,.F.,cLocDigIgn)
			If lRetorno

				While !(cAlias)->(Eof())

					nRecnoBD7	:= (cAlias)->RECNOBD7
					cChaveGuia	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						cTxt := cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nIncluidos)) + " registros incluídos. Total de Selecionados " + AllTrim(Str(nRegSel))
						PlsAtuMonitor(cTxt)
						PlsLogFil( cTxt ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nTerminal)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

		/*		ALGUNS DESCARTES JA FACO AQUI		*/
		If !lGerRepas .And. PulaRepasse(cAlias,@cChaveGuia)//Despreza usuario de grupo empresa de reciprocidade

			cTxt := "Alto Custo;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Usuario pertence a contrato de reciprocidade"
			CenWrLogJb(cTriRec,cTxt,,cNomJob)
			Loop

		EndIf

		cChaveProd := PegaProduto(cAlias) //Vou pegar o produto na familia ou beneficiario

		If PulaProduto(cAlias,cChaveProd,@aProduto)//Despreza produto nao informado a ANS

			cTxt := "Alto Custo;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Produto/Plano nao deve ser informado a ANS"
			CenWrLogJb(cTriRec,cTxt,,cNomJob)
			Loop

		EndIf

		If PulaEstorno(cAlias,@cChaveGuia)//Despreza guias de consulta e servico estornadas

			cTxt := "Alto Custo;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Guia estornada"
			CenWrLogJb(cTriRec,cTxt,,cNomJob)
			Loop

		EndIf

		/*		VOU CHAMAR AS CLASSIFICACOES		*/

		If (cAlias)->BD7_TIPGUI == G_SOL_INTER

			ProximaGuia(cAlias,cChaveGuia)
			Loop

		ElseIf (cAlias)->BD7_TIPGUI $ G_RES_INTER + ',' + G_HONORARIO .OR. !Empty((cAlias)->BD5_GUIINT)

			aClasEven := ClassInternacao(cAlias,cChaveGuia,cTipData,.f.,/*@nIdade*/,@aClasEspe,cDataRef,lMV_STATISS)

		ElseIf (cAlias)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON

			aClasEven := ClassSADT(cAlias,cChaveGuia,cTipData,.f.,/*@nIdade*/,@aClasEspe,cDataRef,lMV_STATISS)

		Else

			ProximaGuia(cAlias,cChaveGuia)
			Loop

		EndIf

		/*		GRAVACAO DO EVENTO X DESPESA		*/
		If LocalizaCompromisso(aClasEven[TRIMOCOR],@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS) .And.;
				!ExisteDespesa(cRegANS,cCodObri,cAnoComp,cCodComp,cChaveGuia,cMatric,cAlias,"",aClasEven,,,,"",aClasEven[__UF])

			If TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven)
				nIncluidos++
			EndIf

		EndIf

		/*		PROXIMO EVENTO X DESPESA ALTO CUSTO		*/
		If nRecnoBD7 == (cAlias)->RECNOBD7

			(cAlias)->(dbSkip())

		EndIf
		nTerminal++

		EndDo //!(cAlias)->(Eof())

		EndIf //CarregaDados()
		EndIf

	END SEQUENCE
	ErrorBlock(bBlock)

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	PlsLogFil(cCabLog + CENDTHRL("I") +" Termino ",ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPREE

Funcao criada para carregar reembolsos na tabela temporaria do SIP - B3Q

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPREE(cEmp,cFil,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,nThread)
	Local lRetorno		:= .T.
	Local cChaveGuia	:= ""
	Local cChaveProd	:= ""
	Local cMatric		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= 'TRBREE'
	Local nRecnoBD7		:= 0
	Local nTerminal		:= 0
	Local nIncluidos	:= 0
	Local nQuinzena		:= 0
	Local nRegSel		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cCabLog		:= ""
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local aClasEspe		:= {}
	Local aProduto		:= {}
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.
	Private lB3Q_EVDRES	:= .f.//B3Q->(FieldPos("B3Q_EVDRES")) > 0
	Private lB3L_EVDRES	:= .f.//B3L->(FieldPos("B3L_EVDRES")) > 0
	Private lB3Q_CLASSH := .f. //B3Q->(fieldpos("B3Q_CLASSH")) > 0
	Default nThread		:= 1

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')
	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob() + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"

	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	aClasEspe := IniciaEspecialidade()
	aProduto := IniciaProduto()

	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	PlsAtuMonitor("PLSIPREE [" + AllTrim(Str(nThread)) + "] importando reembolso" )

	If Empty(cLocDigIgn)
		cLocDigIgn := RetLocIgn()
	EndIf

	lB3Q_EVDRES	:= B3Q->(FieldPos("B3Q_EVDRES")) > 0
	lB3L_EVDRES	:= B3L->(FieldPos("B3L_EVDRES")) > 0
	lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0
	If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
		PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
		lRetorno := .F.
	EndIf

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,nQuinzena,"PLSIPREE") } )
	BEGIN SEQUENCE

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},0,.T.,cLocDigIgn,.F.)
			nRegSel := (cAlias)->Total
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
			(cAlias)->(dbCloseArea())
		EndIf

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},0,.F.,cLocDigIgn,.F.)
			If lRetorno

				While !(cAlias)->(Eof())

					nRecnoBD7	:= (cAlias)->RECNOBD7
					cChaveGuia	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
					nTerminal++
					/*		ALGUNS DESCARTES JA FACO AQUI		*/

					If !lGerRepas .And. PulaRepasse(cAlias,@cChaveGuia)//Despreza usuario de grupo empresa de reciprocidade

						cTxt := "Reembolso;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Usuario pertence a contrato de reciprocidade"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias) //Vou pegar o produto na familia ou beneficiario

					If PulaProduto(cAlias,cChaveProd,aProduto)//Despreza produto nao informado a ANS

						cTxt := "Reembolso;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					/*		VOU CHAMAR A CLASSIFICACAO		*/

					If (cAlias)->BD7_TIPGUI == G_REEMBOLSO

						aClasEven := ClassSADT(cAlias,cChaveGuia,cTipData,.f.,/*@nIdade*/,/*@aClasEspe*/,cDataRef,lMV_STATISS)

					Else

						cTxt := "Reembolso;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Tentativa de processar despesa que nao e reembolso"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						ProximaGuia(cAlias,cChaveGuia)
						Loop

					EndIf

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						cTxt := cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nIncluidos)) + " registros incluídos. Total de Selecionados " + AllTrim(Str(nRegSel))
						PlsAtuMonitor(cTxt)
						PlsLogFil( cTxt ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nTerminal)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					/*		GRAVACAO DO REEMBOLSO		*/
					If TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven)
						nIncluidos++
					EndIf

					/*		PROXIMO REEMBOLSO		*/
					If nRecnoBD7 == (cAlias)->RECNOBD7
						(cAlias)->(dbSkip())
					EndIf

				EndDo //!(cAlias)->(Eof())

			EndIf //CarregaDados()

		EndIf //lRetorno

	END SEQUENCE
	ErrorBlock(bBlock)

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	PlsLogFil( cCabLog + CENDTHRL("I") + " Termino ",ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPEXP

Funcao criada para carregar beneficiarios expostos na tabela temporaria do SIP - B3Q

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
@param aBenef		Informacoes do beneficiario
@param nThread		Numero da thread
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPEXP(cEmp,cFil,cDataRef,cTipData,cRegANS,lGerRepas,aBenef,nThread,cLocDigIgn,lJob)
	Local lRetorno		:= .T.
	Local lAtenOdon		:= .F.
	Local lPodeBR8		:= .F.
	Local cSexo			:= ""
	Local cCodSeg		:= ""
	Local cAlias		:= "TRBEXP"
	Local cChaveProd	:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cDatCar		:= ""
	Local cForCon		:= ""
	Local cDataBlo		:= ""
	Local cMatBen		:= ""
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cCabLog		:= ""
	Local aNatSaude		:= {}
	Local aNatSaBkp		:= {}
	Local nIdade		:= 0
	Local nTerminal		:= 0
	Local nIncluidos	:= 0
	Local nQuinzena		:= 0
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.

	Private aBAN		:= {}
	Private aBDL		:= {}
	Default nThread		:= 0
	Default aBenef		:= {}
	Default lJob		:= .T.

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob() + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	PlsAtuMonitor("PLSIPEXP(" + AllTrim(Str(nThread)) + ") beneficiarios expostos" )
	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,0,"PLSIPEXP") } )
	BEGIN SEQUENCE

		If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
			PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
			lRetorno := .F.
		EndIf

		cDatExe := DTOS(dDataBase)
		cHorExe	:= Time()
		CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

		aNatSaude := PegaNatSaude()//carrego as naturezas de saude no formato {Codigo,0, / / ,Idade Ini,Idade Fin,Sexo,Nivel}
		If Len(aNatSaude) == 0
			PlsLogFil(cCabLog + CENDTHRL("W") + " Nao foram encontradas as naturezas de saúde na tabela BF0",ARQ_LOG_DES)
		EndIf
		aNatSaBkp := aClone(aNatSaude)

		Inicializa()

		If lRetorno .And. CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,0,.T.)
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,0,.T.)
			nRegSel := (cAlias)->Total
			PlsLogFil(cCabLog + CENDTHRL("I") + " Total de registros encontrados: " + AllTrim(Str((cAlias)->Total)),ARQ_LOG_DES)
			(cAlias)->(dbCloseArea())
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		EndIf

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef)
			If lRetorno

				aBAN := BANInicia()
				aBDL := BDLInicia()

				While !(cAlias)->(Eof())//Beneficiarios

					nTerminal++
					cMatBen := (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

					If !lGerRepas .And. (cAlias)->BG9_REPASS == '1'
						(cAlias)->(dbSkip())
						Loop
					EndIf

					If (cAlias)->BA1_DATINC > cDataRef//Ignora beneficiario incluidos apos o periodo

						cTxt := "Expostos;" + cMatBen + ";;; Beneficiario desconsiderado por inclusao depois de " + cDataRef
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						(cAlias)->(dbSkip())
						Loop

					EndIf

					If  BenefBloqueio(cAlias,cDataRef,@cDataBlo)//Ignora beneficiario bloqueados no periodo

						cTxt := "Expostos;" + cMatBen + ";;; Beneficiario bloqueado em " + cDataBlo
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						(cAlias)->(dbSkip())
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias,@lPodeBR8,@cCodSeg,@lAtenOdon,@cForCon)//Vou pegar o produto na familia ou beneficiario, segmentacao, forma de contratacao e se atende odonto

					If PulaProduto(cAlias,cChaveProd)//Despreza produto nao informado a ANS

						cTxt := "Expostos;" + cMatBen + ";;; Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						(cAlias)->(dbSkip())
						Loop

					EndIf

					aNatSaude := {}
					aNatSaude := aClone(aNatSaBkp)
					dDatNas := STOD((cAlias)->BA1_DATNAS)
					nIdade	:= Calc_Idade(dDataBase,dDatNas)
					cSexo	:= (cAlias)->BA1_SEXO
					cDatCar	:= (cAlias)->BA1_DATCAR

					PlCenCarCob(cAlias,(cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),(cAlias)->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),cChaveProd,cDatCar,;
						@nIncluidos,lAtenOdon,aNatSaude,lPodeBR8,(cAlias)->BA1_CODINT,cDataRef,cRegANS,cCodObri,cAnoComp,cCodComp,.T.,cSexo,dDatNas,cCodSeg,cForCon,STOD(cDataBlo))

					(cAlias)->(dbSkip())

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						cTxt := cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nIncluidos)) + " registros incluídos. Total de Selecionados " + AllTrim(Str(nRegSel))
						PlsAtuMonitor(cTxt)
						PlsLogFil( cTxt ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nTerminal)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					cDataBlo := ""
				EndDo //!(cAlias)->(Eof()) - Beneficiarios

			EndIf //CarregaDados()
		EndIf
	END SEQUENCE
	ErrorBlock(bBlock)

	PlsLogFil(cCabLog + CENDTHRL("I") + " Termino ",ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro as variáveis __cError e __cCallStk sao private e precisam ser criadas
na rotina que ira ter o controle SEQUENCE que chama esta funcao

@param e			Referencia ao erro
@param nThread	Numero da thread em execucao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChecErro(e,nThread,nQuinzena,cDesc)
	Local cMsg			:= CENDTHRL("E")
	Default nThread 	:= 0
	Default nQuinzena	:= 0
	Default cDesc		:= ""

	PlsLogFil(e:Description + chr(13) + e:ErrorStack,ARQ_LOG_DES)

	If !Empty(cDesc)
		cMsg += cDesc
	EndIf

	If nThread > 0 .Or. nQuinzena > 0

		cMsg += " ("

		If nThread > 0
			cMsg += AllTrim(Str(nThread))
		EndIf

		If nQuinzena > 0
			cMsg += AllTrim(Str(nQuinzena))
		EndIf

		cMsg += ") " + Chr(13)

	EndIf

	If !Empty(e:Description)
		cMsg += "Descrição" + e:Description + Chr(13)
	EndIf

	cMsg += "Callstack: " + e:ErrorStack

	PlsLogFil(cMsg,ARQ_LOG_DES)

	BREAK

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClassSADT

Funcao criada para classificar os eventos de guias de consulta e SADT

@param cAlias		Area de trabalho corrente
@param cChaveGuia	Chave da guia no PLS
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param lPacote		Indica com Verdadeiro (.T.) se estiver classificando pacote

@return aRetorno	Matriz com as informacoes para o SIP do evento classificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ClassSADT(cAlias,cChaveGuia,cTipData,lPacote,nIdade,aClasEspe,cDataRef,lMV_STATISS,lCapit)
	Local lConsulta		:= .F.
	Local lPacInter		:= .F.
	Local cCodEspMed	:= ""
	Local cCodProc		:= ""
	Local cClaSIPSer	:= ""
	Local cClaSIPEsp	:= ""
	Local cClaSIPInt	:= ""
	Local cClaHDesc     := ""
	Local cTrimOcor		:= ""
	Local cTipoProc		:= ""
	Local cTrimReco		:= ""
	Local cDataProc		:= ""
	//Deixar gravar NC para UF gera a crítica: Em uma mesma forma de contratação e segmentação, quando existir um quadro nacional, ele deve ser único, não podendo existir outros
	//quadros para mesma segmentação, contratação e data de ocorrência
	Local cUF			:= "ZZ"
	Local cCID			:= ""
	Local cHoraInt		:= ""
	Local cHoraAlta		:= ""
	Local cGrupoInt		:= ""
	Local cRegimeInt	:= ""
	Local cChvGuiGrv	:= ""
	Local cGuiInt		:= ""
	Local cChvRes		:= ""
	Local cDente		:= ""
	Local cPadInt		:= ""
	Local dDatInt		:= STOD("")
	Local dDatAlta		:= STOD("")
	Local dDatPro		:= Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
	Local cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
	Local nVlrDesp		:= 0
	Local nQtdeReal		:= 0
	Local nQtdNasViv	:= 0
	Local aRetorno		:= {}
	Local aPacInter		:= {}
	Default aClasEspe	:= {}
	Default cAlias		:= 'TRBDES'
	Default cChaveGuia	:= ""
	Default cTipData	:= '1'
	Default lPacote		:= .F.
	Default nIdade		:= 0
	Default cDataRef	:= dDatPro
	Default lMV_STATISS	:= MV_STATISS
	Default lCapit      := .F.

	lPacote:=.F.

	If cAlias == "TRBPCT" .And. lPacote
		cCodProc	:= AllTrim((cAlias)->(BLE_CPADOC+BLE_CODOPC))
		lConsulta	:= (cAlias)->BD7_TIPGUI == G_CONSULTA .Or. PlsIsCon((cAlias)->BLE_CPADOC,(cAlias)->BLE_CODOPC)
	Else
		cCodProc	:= AllTrim((cAlias)->(BD7_CODPAD+BD7_CODPRO))
		lConsulta	:= (cAlias)->BD7_TIPGUI == G_CONSULTA .Or. PlsIsCon((cAlias)->BD7_CODPAD,(cAlias)->BD7_CODPRO)
	EndIf

	cClaSIPSer	:= (cAlias)->BR8_CLASIP
	//Tratamento de procedimentos relacionados
	If (!Empty((cAlias)->(BD6_PROREL)) .And. (cAlias)->(BR8_TPPROC) == TP_PROCEDIM) .Or. lPacote

		If BR8->(msSeek(xFilial("BR8")+Iif(lPacote,(cAlias)->(BD7_CODPRO+BD7_CODPAD),(cAlias)->(BD6_PROREL)))) .And. !Empty(BR8->BR8_CLASIP)
			cClaSIPSer := BR8->BR8_CLASIP
		EndIf

	EndIf
	If !Empty((cAlias)->(BD7_CODESP))
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD7_CODESP)
	Else
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD6_CODESP)
	EndIf

	If lConsulta .And. (cAlias)->BR8_TPCONS == '1' //1=Ambulatorial; 2= Pronto Socorro
		cClaSIPEsp := ClassificaEspecialidade(cCodEspMed,@aClasEspe)
	EndIf

	If lPacote
		cClaSIPInt	:= BR8->BR8_CLASP2
	Else
		cClaSIPInt	:= (cAlias)->BR8_CLASP2
	EndIf

	if alltrim(cClaSIPSer) $ "hH" .or. alltrim(cClaSIPInt) $ "hH" .or. alltrim(cClaSIPEsp) $ "hH"
		cClaHDesc := "Este procedimento teve a classificação H, devido a parametrização em seu sistema de gestão."
	endif

	If nMV_QTANSIP > 0 .Or. (cAlias)->BD7_TIPGUI == G_REEMBOLSO .Or. lCapit
		cTrimReco := DataTrimestre(cDataRef)
	Else
		cTrimReco	:= DataTrimestre(DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit),"3")//O trimestre de reconhecimento refere-se ao trimestre dentro do qual a operadora reconheceu a prestação de serviços 1-digitacao, 2-procedimento e 3-pagamento
	EndIf
	cTrimOcor	:= DataTrimestre(dDatPro,"3")//O trimestre de ocorrência refere-se ao trimestre dentro do qual ocorreu a prestação dos serviços
	cDataProc   := dDatPro
	cTipoProc 	:= Iif(!lPacote,(cAlias)->BR8_TPPROC,BR8->BR8_TPPROC)
	nQtdeReal	:= (cAlias)->BD6_QTDPRO
	cUF         := BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE),(cAlias)->(BD7_CODOPE+BD7_CODLOC+BD7_LOCAL))
	cCID		:= (cAlias)->BD6_CID
	cChvGuiGrv	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)

	If lConsulta
		cGuiInt	:= ""
	Else
		cGuiInt := (cAlias)->BD5_GUIINT
		If !Empty(cGuiInt)
			aDadInt := RetDadInt( cGuiInt,cChvGuiGrv,(cAlias)->BD7_TIPGUI,cTipData,cTrimReco,lMV_STATISS)

			If aDadInt[1]

				lPacInter	:= .T.
				cGuiInt		:= aDadInt[2]//Chave da solicitação de internação - BE4_SOLINT = BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
				cGrupoInt	:= aDadInt[3]//Grupo de Internação
				cRegimeInt	:= aDadInt[4]//Regime de Internação
				cHoraInt	:= aDadInt[5]//Hora de Internação
				cHoraAlta	:= aDadInt[6]//Hora de Alta
				dDatInt		:= aDadInt[7]//Data de Internação
				dDatAlta	:= aDadInt[8]//Data de Alta
				nQtdNasViv	:= aDadInt[9]+aDadInt[10]//Nascido Vivo+Nascido Prematuro
				cPadInt		:= aDadInt[12]//Tipo de acomodação
				cChvRes		:= aDadInt[13]//Chave do resumo de internacao

				If !Empty(dDatInt)
					cTrimOcor := DataTrimestre(dDatInt,"3")
				EndIf

			Else

				lPacInter	:= .F.
				cGuiInt		:= ""
				cGrupoInt	:= ""
				cRegimeInt	:= ""
				cHoraInt	:= ""
				cHoraAlta	:= ""
				dDatInt		:= STOD("")
				dDatAlta	:= STOD("")
				nQtdNasViv	:= 0
				cPadInt		:= ""
				cChvRes		:= ""
				cClaSIPInt	:= "H"
				cClaSIPSer	:= "H"
				cClaSIPEsp	:= "H"
				cClaHDesc   := "Guia de SADT sem os dados da guia de internação vinculada." //TODO

			EndIf
		EndIf

	EndIf

	LimpaArray(@aPacInter)

	If !lPacInter .OR. !Empty(cGuiInt) .OR. (cAlias)->BD7_TIPGUI == G_REEMBOLSO
		//Item B - excessao - Procedimentos de vasectomia (item E) realizados em ambulatorio em paciente nao internado devem ser classificados em B - Outros atendimentos ambulatoriais
		If Alltrim((cAlias)->BD7_CODPRO) == '31205046'
			cClaSIPSer := 'B'
			cClaSIPEsp := 'B'
			cClaSIPInt := 'B'
		EndIf
	EndIf

	If AllTrim(cClaSIPSer) $ "I33,I4,I5,I6,I7,I8,I9" .Or. AllTrim(cClaSIPInt) $ "I33,I4,I5,I6,I7,I8,I9"
		cDente	:=  BuscaDente((cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV))
	EndIf

	//Para procedimentos de consulta a classificacao vem da especialidade medica
	If lConsulta .And. !Empty(cClaSIPEsp)
		cClaSIPSer := cClaSIPEsp
	EndIf

	//Se um exame do item C foi feito dentro de uma terapia ele deve ser considerado no item D - Terapia
	//1-Material, 2-Medicamento, 3-Taxa e 9-Outros tambem acompanham a terapia
	If ( SubStr(cClaSIPSer,1,1) == "C" .Or. ( Empty(cClaSIPSer) .And. (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS ) ) ;
		.And. ExisteTerapia(cChaveGuia,cAlias,lMV_STATISS)
	If (cAlias)->BD7_TIPGUI <> G_REEMBOLSO
		nQtdeReal := 0
	EndIf
	cClaSIPSer := "D"
	EndIf

	//Materiais, Medicamentos, Taxas e Outros serao classificados como outros atendimentos ambulatoriais
	If Empty(cClaSIPSer) .And. (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS
		cClaExm := ExisteExame(cChaveGuia,lMV_STATISS)
		If !Empty(cClaExm)
			cClaSIPSer := cClaExm
			nQtdeReal := 0
		EndIf
	EndIf

	nIdade := Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))

	While !(cAlias)->(Eof()) .And. (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) ==  cChaveGuia

		If cAlias == "TRBPCT" .And. lPacote
			nVlrDesp += (cAlias)->BLE_VALFIX
		Else
			nVlrDesp += (cAlias)->BD7_VLRPAG
		EndIf

		(cAlias)->(dbSkip())
	EndDo

	If (cAlias)->BD7_TIPGUI == G_REEMBOLSO
		IF EMPTY(cClaSIPSer) .OR. EMPTY(cClaSIPInt)
			IF lPacInter
				cClaSIPSer := 'H'
				cClaSIPEsp := 'H'
				cClaSIPInt := 'H'
				cClaHDesc := "Guia de reembolso" //TODO
			ENDIF
		ENDIF
	ENDIF

	//Só vou contar frequência de guias que fiz algum pagamento
	If nVlrDesp == 0 .And. !lCapit
		nQtdeReal := 0
	EndIf

	aRetorno := {/*1*/cCodProc,/*2*/lConsulta,/*3*/cClaSIPSer,/*4*/cClaSIPEsp,/*5*/cClaSIPInt,/*6*/nQtdeReal,/*7*/cDataProc,/*8*/cTipoProc,/*9*/nVlrDesp,/*10*/cTrimOcor,;
		/*11*/cGrupoInt,/*12*/cRegimeInt,/*13*/cChvGuiGrv,/*14*/cMatric,/*15*/cUF,/*16*/cCID,/*17*/nIdade,/*18*/dDatInt,/*19*/cHoraInt,/*20*/dDatAlta,;
		/*21*/cHoraAlta,/*22*/cTrimReco,/*23*/nQtdNasViv,/*24*/cDente,/*25*/cGuiInt,/*26*/cChvRes,/*27*/cClaHDesc}

Return aRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClassInternacao

Funcao criada para classificar os eventos de guias de internacao

@param cAlias		Area de trabalho corrente
@param cChaveGuia	Chave da guia no PLS
@param cTipData		1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param lPacote		Indica com Verdadeiro (.T.) se estiver classificando pacote

@return aRetorno	Matriz com as informacoes para o SIP do evento classificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ClassInternacao(cAlias,cChaveGuia,cTipData,lPacote,nIdade,aClasEspe,cDataRef,lMV_STATISS,lCapit)
	Local lConsulta		:= .F.
	Local cCodEspMed	:= ""
	Local cCodProc		:= ""
	Local cClaSIPSer	:= ""
	Local cClaSIPEsp	:= ""
	Local cClaSIPInt	:= ""
	Local cClaHDesc     := ""
	Local cDataProc		:= ""
	Local cTipoProc		:= ""
	Local cTrimReco		:= ""
	Local cTrimOcor		:= ""
	Local cGrupoInt		:= ""
	Local cRegimeInt	:= ""
	Local cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
	Local cUF			:= "ZZ"
	Local cCID			:= ""
	Local cChvGuiGrv	:= ""
	Local cDente		:= ""
	Local nVlrDesp		:= 0
	Local nQtdeReal		:= 0
	Local nQtdNasViv	:= 0
	Local cHoraInt		:= ""
	Local cHoraAlta		:= ""
	Local cGuiInt		:= ""
	Local cChvRes		:= ""
	Local cPadInt		:= ""
	Local dDatInt		:= STOD("")
	Local dDatAlta		:= STOD("")
	Local dDatPro		:= Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
	Local aRetorno		:= {}
	Local aClaIteE		:= {}
	Local lPacInter		:= .F.
	Local cAliUsa       := "BE4"
	Default aClasEspe	:= {}
	Default cAlias		:= 'TRBDES'
	Default cChaveGuia	:= ""
	Default cTipData	:= '1'
	Default lPacote		:= .F.
	Default nIdade		:= 0
	Default cDataRef	:= dDatPro
	Default lMV_STATISS	:= MV_STATISS
	Default lCapit      := .f.

	IniciaE1(@aClaIteE)

	lPacote:=.F.

	If cAlias == "TRBPCT" .And. lPacote
		cCodProc	:= AllTrim((cAlias)->(BLE_CPADOC+BLE_CODOPC))
	Else
		cCodProc	:= AllTrim((cAlias)->(BD7_CODPAD+BD7_CODPRO))
	EndIf

	If !lPacote
		cClaSIPSer	:= Iif(!Empty((cAlias)->BR8_CLASP2),(cAlias)->BR8_CLASP2,(cAlias)->BR8_CLASIP)
	Else
		cClaSIPSer	:= IIf(!Empty(BR8->BR8_CLASP2),BR8->BR8_CLASP2,BR8->BR8_CLASIP)
	EndIf
	//Tratamento de procedimentos relacionados
	If (!Empty((cAlias)->(BD6_PROREL)) .And. (cAlias)->(BR8_TPPROC) == TP_PROCEDIM) .Or. lPacote

		If BR8->(msSeek(xFilial("BR8")+Iif( lPacote, (cAlias)->(BD7_CODPRO+BD7_CODPAD) , (cAlias)->(BD6_PROREL) )))
			cClaSIPSer := IIf(!Empty(BR8->BR8_CLASP2),BR8->BR8_CLASP2,BR8->BR8_CLASIP)
		EndIf

	EndIf
	If !Empty((cAlias)->(BD7_CODESP))
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD7_CODESP)
	Else
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD6_CODESP)
	EndIf

	If (cAlias)->BR8_TPCONS == '1'
		cClaSIPEsp := ClassificaEspecialidade(cCodEspMed,@aClasEspe)
	EndIf

	If !lPacote
		cClaSIPInt	:= (cAlias)->BR8_CLASP2
	Else
		cClaSIPInt	:= BR8->BR8_CLASP2
	EndIf

	if alltrim(cClaSIPSer) $ "hH" .or. alltrim(cClaSIPInt) $ "hH" .or. alltrim(cClaSIPEsp) $ "hH"
		cClaHDesc := "Este procedimento teve a classificação H, devido a parametrização em seu sistema de gestão."
	endif

	If nMV_QTANSIP > 0 .Or. lCapit
		cTrimReco := DataTrimestre(cDataRef)
	Else
		cTrimReco	:= DataTrimestre(DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit),"3")//O trimestre de reconhecimento refere-se ao trimestre dentro do qual a operadora reconheceu a prestação de serviços 1-digitacao, 2-procedimento e 3-pagamento
	EndIf
	cTrimOcor	:= DataTrimestre(dDatPro,"3")//O trimestre de ocorrÃªncia refere-se ao trimestre dentro do qual ocorreu a prestaÃ§Ã£o dos serviÃ§os
	cDataProc	:= dDatPro
	cTipoProc 	:= (cAlias)->(BR8_TPPROC)
	nQtdeReal	:= (cAlias)->BD6_QTDPRO
	cUF         := BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE))
	cCID		:= PegaCIDInt((cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SITUAC+BD7_FASE))
	cChvGuiGrv	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)

	//Se for guia de resumo
	If (cAlias)->BD7_TIPGUI == G_RES_INTER
		cGuiInt := (cAlias)->BE4_GUIINT
	Else
		cGuiInt := (cAlias)->BD5_GUIINT
		If !Empty(cGuiInt)
			cAliUsa:="BD5"
		EndIf
	EndIf

	If !Empty(cGuiInt)

		aDadInt := RetDadInt(cGuiInt,cChvGuiGrv,(cAlias)->BD7_TIPGUI,cTipData,cTrimReco,lMV_STATISS,cAliUsa)

		If aDadInt[1]

			lPacInter	:= .T.
			cGuiInt		:= aDadInt[2]//Chave da solicitação de internação - BE4_GUIINT
			cGrupoInt	:= aDadInt[3]//Grupo de Internação
			cRegimeInt	:= aDadInt[4]//Regime de Internação
			cHoraInt	:= aDadInt[5]//Hora de Internação
			cHoraAlta	:= aDadInt[6]//Hora de Alta
			dDatInt		:= STOD(aDadInt[7])//Data de Internação
			dDatAlta	:= STOD(aDadInt[8])//Data de Alta
			nQtdNasViv	:= aDadInt[9]+aDadInt[10]//Nascido Vivo+Nascido Prematuro
			cPadInt		:= aDadInt[12]//Tipo de acomodação
			cChvRes		:= aDadInt[13]//Chave do resumo

			If !Empty(dDatInt)
				cTrimOcor := DataTrimestre(DTOS(dDatInt),"3")
			EndIf

		Else//Nao conseguiu encontrar o resumo de internacao

			lPacInter	:= .F.
			cGuiInt		:= ""
			cGrupoInt	:= ""
			cRegimeInt	:= ""
			cHoraInt	:= ""
			cHoraAlta	:= ""
			dDatInt		:= STOD("")
			dDatAlta	:= STOD("")
			nQtdNasViv	:= 0
			cPadInt		:= ""
			cChvRes		:= ""
			cClaSIPInt	:= "H"
			cClaSIPSer	:= "H"
			cClaSIPEsp	:= "H"
			cClaHDesc   := "Guia de resumo de internação não encontrada." //TODO

		EndIf

	EndIf

	//Para procedimentos de consulta a classificacao vem da especialidade medica
	If !Empty(cClaSIPEsp)
		cClaSIPSer := cClaSIPEsp
	EndIf

	nIdade := Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))

	//Materiais, Medicamentos, Taxas e Outros serao classificados como outros atendimentos ambulatoriais
	If (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS
	nQtdeReal := 0
	EndIf

	//Classificacao ITEM E
	If lPacInter
		cCdPrc := AllTrim(SubStr(cCodProc,3))
		cItemE := "E1"+AllTrim(cGrupoInt)+AllTrim(cRegimeInt)//Estou montando o grupo / tipo de internacao
		If AllTrim(cGrupoInt) == "4" //1=Clinica;2=Cirurgica;3=Obstetrica;4=Pediatrica;5=Psiquiatrica
			cClaSIPInt := ClsItemE14(cCID,cPadInt,cHoraInt,cHoraAlta,dDatInt,dDatAlta,STOD((cAlias)->BA1_DATNAS),nIdade)
		Else
			cClaSIPInt := ClasItemE(aClaIteE,cItemE,cCdPrc,cClaSIPInt,nIdade)
		EndIf
		LimpaArray(@aClaIteE)

		cClaSIPInt := AllTrim(cClaSIPInt)
		cClaSIPSer := AllTrim(cClaSIPSer)

		If cGrupoInt <> "4"
			//Parto
			If cClaSIPInt $ "E131,E132,E133"
				cClaSIPSer := cClaSIPInt
			ElseIf cClaSIPSer $ "E131,E132,E133"
				cClaSIPInt := cClaSIPSer
			EndIf
		Else
			cClaSIPSer := cClaSIPInt
		EndIf

		If cClaSIPInt == "E11XX"
			cClaSIPInt := SUbstr(AllTrim(cClaSIPInt),1,3)
			cClaSIPSer := SUbstr(AllTrim(cClaSIPInt),1,3)
		EndIf

	EndIf

	//Se tenho motivo de bloqueio , o valor de pagamento deve estar na guia de honorario
	//Encontrar o valor de pagamento da guia que nao tem bd7_blopag=1 mas tem bd7_motblo <> de vazio
	If !lPacote .And. (cAlias)->BD7_BLOPAG <> "1" .And. !Empty((cAlias)->BD7_MOTBLO)

		If nVlrDesp <= 0
			nVlrDesp := (cAlias)->BD7_VLRPAG
		EndIf

	Else

		While !(cAlias)->(Eof()) .And. (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) ==  cChaveGuia

			If cAlias == "TRBPCT" .And. lPacote
				nVlrDesp += (cAlias)->BLE_VALFIX
			Else
				nVlrDesp += (cAlias)->BD7_VLRPAG
			EndIf

			(cAlias)->(dbSkip())
		EndDo

	EndIf

	//Só vou contar frequência de guias que fiz algum pagamento
	If nVlrDesp == 0 .And. !lCapit
		nQtdeReal := 0
	EndIf

	aRetorno := {/*1*/cCodProc,/*2*/lConsulta,/*3*/cClaSIPSer,/*4*/cClaSIPEsp,/*5*/cClaSIPInt,/*6*/nQtdeReal,/*7*/cDataProc,/*8*/cTipoProc,/*9*/nVlrDesp,/*10*/cTrimOcor,;
		/*11*/cGrupoInt,/*12*/cRegimeInt,/*13*/cChvGuiGrv,/*14*/cMatric,/*15*/cUF,/*16*/cCID,/*17*/nIdade,/*18*/dDatInt,/*19*/cHoraInt,/*20*/dDatAlta,;
		/*21*/cHoraAlta,/*22*/cTrimReco,/*23*/nQtdNasViv,/*24*/cDente,/*25*/cGuiInt,/*26*/cChvRes,/*27*/cClaHDesc}

Return aRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaDados

Funcao cria a area de trabalho TRBXXX com as informacoes de todos os beneficarios (BA1) ou despesa (BD7,...)

@param cAlias		Nome da area de trabalho a ser criada
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param nThread		Numero da thread / job sendo executada
@param aBenef		Matriz com o range de recnos a ser utilizado em cada consulta
@param nQuinzena	Indica se 1 - primeira ou 2 - segunda quinzena do mes a ser processada
@param lCount		Incica se ira .T. ou nao .F. retornar a quantidade de registros a serem processados
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Indica se foi .T. ou nao .F. encontrado registros para a consulta

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv,lDadosHist)
	Local cSql			:= ""
	Local cCount		:= ""
	Local cSelect		:= ""
	Local lRetorno		:= .F.
	Local cDataIni		:= ""
	Local cDataFin		:= ""
	Local cCompIni		:= ""
	Local cCabLog		:= ""
	Local cLisReps		:= GetNewPar("MV_PLSGEIN ","0050")
	Local cOpePadr		:= PlsIntPad()
	Local cTriRec		:= ""
	Local lMV_STATISS	:= MV_STATISS
	Local cDb           := Alltrim(Upper(TcGetDb()) )
	Default cAlias		:= ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cTipData	:= '1'
	Default cRegANS		:= '000000'
	Default nThread		:= 0
	Default nQuinzena	:= 1
	Default aBenef		:= {}
	Default lCount		:= .F.
	Default cLocDigIgn	:= ""
	Default lQryInter	:= .F.
	Default cChvGuiGrv	:= ""//Quando eu tenho a chave da guia grava e porque vou tratar pacote e quero so os itens do pacote
	Default lDadosHist	:= .F.

	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio Carrega despesas",ARQ_LOG_DES)
	If lCount

		cSelect += " SELECT Count(1) Total "
		cCount	:= "[CONTA REGISTROS]"

	Else

		cSelect += "SELECT BD7_NUMLOT, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_VLRPAG, BD7_CODRDA, BD7_CODPAD, BD7_CODPRO, BD7_DATPRO, BD7_SEQUEN,BD7_REGPRE,BD7_CDPFPR,BD7_ESTPRE, "
		cSelect += "BD7_CODLOC, BD7_LOCAL, BD7_BLOPAG, BD7_MOTBLO, BD7_TIPGUI, BD7_LIBERA, BD7_CODESP, BD7_FASE, BD7_SITUAC, BD7_RECSIP, BD7_DTPAGT, BD7_DTDIGI, BD7.R_E_C_N_O_ RECNOBD7, BD6_DTDIGI, BD6_TABDES, BD6_CID, BD6_QTDPRO, "
		cSelect += "BD6_DATPRO, BD6_CODOPE, BD6_PROREL, BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BD6_CODESP, BR8_CLASP2, BR8_CLASIP, "
		cSelect += "BR8_TPPROC, BR8_TPCONS, '" + cRegANS + "' BA0_SUSEP, '" + SubStr(cOpePadr,1,1) + "' BA0_CODIDE, '" + SubStr(cOpePadr,2,3) + "' BA0_CODINT, BA1_CODPLA, BA1_VERSAO, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, "
		cSelect += "BA1_DIGITO, BA1_DATNAS, BA3_CODPLA, BA3_VERSAO, "

		If !Empty(cChvGuiGrv)
			cSelect += " BLE_VALFIX, BLE_CPADOC, BLE_CODOPC, "
		EndIf

	EndIf

	If cAlias $ "TRBDES,TRBPCT"

		If !lCount

			If lQryInter
				cSelect += " BE4_GUIINT, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT "
			Else
				cSelect += " BD5_GUIINT "
			EndIf

			If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
				cSelect += ", BCI_DTHRLB "
			EndIf

		EndIf

		cSql := cSelect + "FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif

		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, "
		cSql += " " + RetSqlName("BR8") + " BR8, "
		If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
			cSql += " " + RetSqlName("BCI") + " BCI, "
		EndIf
		If lQryInter
			cSql += RetSqlName("BE4") + " BE4 "
		Else
			cSql += RetSqlName("BD5") + " BD5 "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += ", " + RetSqlName("BLE") + " BLE "
		EndIf

		cSql += "WHERE "
		If lQryInter
			cSql += " BE4_FILIAL = '" + xFilial("BE4") + "' "
		Else
			cSql += " BD5_FILIAL = '" + xFilial("BD5") + "' "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += "AND BLE_FILIAL = '" + xFilial("BLE") + "' "
		EndIf

		cSql += " AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' "
		If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
			cSql += " AND BCI_FILIAL = '" + xFilial("BCI") + "' "
		EndIf

		If lQryInter
			cSql += " AND BE4_CODOPE = BD6_CODOPE AND BE4_CODLDP = BD6_CODLDP "
			cSql += " AND BE4_CODPEG = BD6_CODPEG AND BE4_NUMERO = BD6_NUMERO "
			If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
				cSql += " AND BE4_CODOPE = BCI_CODOPE AND BE4_CODLDP = BCI_CODLDP AND BE4_CODPEG = BCI_CODPEG "
			EndIf
		Else
			cSql += " AND BD5_CODOPE = BD6_CODOPE AND BD5_CODLDP = BD6_CODLDP "
			cSql += " AND BD5_CODPEG = BD6_CODPEG AND BD5_NUMERO = BD6_NUMERO "
			If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
				cSql += " AND BD5_CODOPE = BCI_CODOPE AND BD5_CODLDP = BCI_CODLDP AND BD5_CODPEG = BCI_CODPEG "
			EndIf
		EndIf

		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP "
		cSql += " AND BD7_CODPEG = BD6_CODPEG AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		If !lQryInter
			cSql += " AND BD5_OPEUSR = BA3_CODINT AND BD5_CODEMP = BA3_CODEMP AND BD5_MATRIC = BA3_MATRIC "
		Else
			cSql += " AND BE4_OPEUSR = BA3_CODINT AND BE4_CODEMP = BA3_CODEMP AND BE4_MATRIC = BA3_MATRIC "
		EndIf
		cSql += " AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "
		cSql += " AND BD7_CODOPE = '" + cOpePadr + "' "
		cSql += " AND BD7_LIBERA <>'1' AND BD7_FASE = '" + GetNewPar("MV_PLFSSIP","4") + "' "
		cSql += " AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
		cSql += " AND BD7_CODEMP NOT IN ('" + StrTran(cLisReps,",","','") + "') "

		If !Empty(cLocDigIgn)//Locais de digiticao a serem ignorados
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += " AND BR8_CODPAD = BLE_CODPAD AND BR8_CODPSA = BLE_CODPRO "
			cSql += " AND BD7_CODOPE = '" + SubStr(cChvGuiGrv,1,4) + "' "
			cSql += " AND BD7_CODLDP = '" + SubStr(cChvGuiGrv,5,4) + "' "
			cSql += " AND BD7_CODPEG = '" + SubStr(cChvGuiGrv,9,8) + "' "
			cSql += " AND BD7_NUMERO = '" + SubStr(cChvGuiGrv,17,8) + "' "
		EndIf

		If lDadosHist
			//Dados historicos so busca despesas vinculadas a internacao
			//Guias de servico ou honorario que nos trimestre anteriores a operadora ainda nao tinha recebido o resumo
			If lQryInter
				cSql += "AND BE4_GUIINT <> ' ' "
			Else
				cSql += "AND BD5_GUIINT <> ' ' "
			EndIf

		EndIf

		cSql += "AND BD7_RECSIP = ' ' "

		Do case

			case cTipData == '1'//Data de digitacao

				If lMV_STATISS
					AtualizaDatas(@cDataIni,@cDataFin,cDataRef,Iif(nThread==0,1,nThread))
					If lDadosHist
						cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
						cSql += " AND BCI_DTHRLB <> ' ' AND SUBSTRING(BCI_DTHRLB,1,8) >= '" + cDataCor + "' AND SUBSTRING(BCI_DTHRLB,1,8) < '" + cDataIni + "' "
					Else
						cSql += " AND BCI_DTHRLB <> ' ' AND SUBSTRING(BCI_DTHRLB,1,8) BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
					EndIf
				Else
					AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
					If lDadosHist
						cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
						cSql += "AND BD7_DTDIGI >= '" + cDataCor + "' AND BD7_DTDIGI < '" + cDataIni + "' "
					Else
						cSql += "AND BD7_DTDIGI BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
					EndIf
				EndIf

			case cTipData == '2'//Lote de pagamento

				AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
				If lDadosHist
					cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
					cCompIni := SubStr(cDataCor,1,6) + "0000"
					cCompFin := SubStr(cDataIni,1,6) + "0000"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_NUMLOT >= '" + cCompIni + "' AND BD7_NUMLOT < '" + cCompFin + "' "
				Else
					cCompIni := SubStr(cDataFin,1,6) + "0000"
					cCompFin := SubStr(cDataFin,1,6) + "9999"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_NUMLOT BETWEEN '" + cCompIni + "' AND '" + cCompFin + "' "
				EndIf

			case cTipData == '3'//Procedimento

				AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
				If lDadosHist
					cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
					cSql += "AND BD7_DATPRO >= '" + cDataCor + "' AND BD7_DATPRO <'" + cDataIni + "' "
				Else
					cSql += "AND BD7_DATPRO BETWEEN '" + Iif(nQuinzena == 1,cDataIni,SubStr(cDataIni,1,6)+'16') + "' AND '" + Iif(nQuinzena == 1,SubStr(cDataFin,1,6)+'15',cDataFin) + "' "
				EndIf

			OtherWise //4-Data do Pagamento

				AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
				If lDadosHist
					cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
					cCompIni := SubStr(cDataCor,1,6) + "00"
					cCompFin := SubStr(cDataIni,1,6) + "00"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_DTPAGT >= '" + cCompIni + "' AND BD7_DTPAGT < '" + cCompFin + "' "
				Else
					cCompIni := SubStr(cDataFin,1,6) + "00"
					cCompFin := SubStr(cDataFin,1,6) + "99"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_DTPAGT BETWEEN '" + cCompIni + "' AND '" + cCompFin + "' "
				EndIf

		EndCase//cTipData == '1'

		cSql += " AND BA1_INFANS = '1' "

		If !lQryInter
			cSql += "AND BD5.D_E_L_E_T_ = ' ' "
		Else
			cSql += "AND BE4.D_E_L_E_T_ = ' ' "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += "AND BLE.D_E_L_E_T_ = ' ' "
		EndIf

		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' "
		cSql += " AND BA3.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' ' "
		If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
			cSql += " AND BCI.D_E_L_E_T_ = ' ' "
		EndIf
		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias $ "TRBCAP"

		If !lCount

			If lQryInter
				cSelect += " BE4_GUIINT, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT "
			Else
				cSelect += " BD5_GUIINT "
			EndIf

		EndIf

		cSql := cSelect + "FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif

		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, "
		cSql += " " + RetSqlName("BR8") + " BR8, "

		If lQryInter
			cSql += RetSqlName("BE4") + " BE4 "
		Else
			cSql += RetSqlName("BD5") + " BD5 "
		EndIf

		cSql += "WHERE "
		If lQryInter
			cSql += " BE4_FILIAL = '" + xFilial("BE4") + "' "
		Else
			cSql += " BD5_FILIAL = '" + xFilial("BD5") + "' "
		EndIf

		cSql += " AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' "

		If lQryInter
			cSql += " AND BE4_CODOPE = BD6_CODOPE AND BE4_CODLDP = BD6_CODLDP "
			cSql += " AND BE4_CODPEG = BD6_CODPEG AND BE4_NUMERO = BD6_NUMERO "
		Else
			cSql += " AND BD5_CODOPE = BD6_CODOPE AND BD5_CODLDP = BD6_CODLDP "
			cSql += " AND BD5_CODPEG = BD6_CODPEG AND BD5_NUMERO = BD6_NUMERO "
		EndIf

		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP "
		cSql += " AND BD7_CODPEG = BD6_CODPEG AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		If !lQryInter
			cSql += " AND BD5_OPEUSR = BA3_CODINT AND BD5_CODEMP = BA3_CODEMP AND BD5_MATRIC = BA3_MATRIC "
		Else
			cSql += " AND BE4_OPEUSR = BA3_CODINT AND BE4_CODEMP = BA3_CODEMP AND BE4_MATRIC = BA3_MATRIC "
		EndIf
		cSql += " AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "
		cSql += " AND BD7_CODOPE = '" + cOpePadr + "' "
		cSql += " AND BD7_LIBERA <>'1' "
		cSql += " AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
		cSql += " AND BD7_CODEMP NOT IN ('" + StrTran(cLisReps,",","','") + "') "

		If !Empty(cLocDigIgn)//Locais de digiticao a serem ignorados
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		cSql += "AND BD7_RECSIP = ' ' "

		AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
		cCompIni := SubStr(cDataFin,1,6) + "00"
		cCompFin := SubStr(cDataFin,1,6) + "99"
		cSql += "AND BD6_TABDES = 'B8O' AND BD7_DTDIGI BETWEEN '" + cCompIni + "' AND '" + cCompFin + "' "

		cSql += " AND BA1_INFANS = '1' "

		If !lQryInter
			cSql += "AND BD5.D_E_L_E_T_ = ' ' "
		Else
			cSql += "AND BE4.D_E_L_E_T_ = ' ' "
		EndIf

		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' "
		cSql += " AND BA3.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' ' "

		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias == "TRBREE"

		If !lCount

			cSelect += " ' ' BD5_GUIINT "

			If lMV_STATISS
				cSelect += ", B44_DTLBFN "
			EndIf

		EndIf

		cSql := cSelect + " FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, "
		cSql += " " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif
		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, "
		cSql += " " + RetSqlName("BR8") + " BR8, "
		cSql += " " + RetSqlName("B44") + " B44 "

		If !lMV_STATISS
			cSql += ", " + RetSqlName("SE1") + " SE1 "
		EndIf

		cSql += "WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSql += " AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' "
		cSql += " AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' "
		cSql += " AND B44_FILIAL = '" + xFilial("B44") + "' "

		If !lMV_STATISS
			cSql += " AND E1_FILIAL = '" +	xFilial("SE1") + "' "
		EndIf

		cSql += " AND BD7_RECSIP = ' ' "
		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP AND BD7_CODPEG = BD6_CODPEG "
		cSql += " AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
		cSql += " AND B44_OPEUSR = BD6_CODOPE AND B44_CODLDP = BD6_CODLDP AND B44_CODPEG = BD6_CODPEG "
		cSql += " AND B44_NUMGUI = BD6_NUMERO "
		If !lMV_STATISS
			cSql += "AND E1_PREFIXO = B44_PREFIX AND E1_NUM = B44_NUM "
		EndIf
		cSql += "AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "
		cSql += "AND BD7_LIBERA <>'1' AND BD7_FASE = '" + GetNewPar("MV_PLFSSIP","4") + "' "
		cSql += "AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
		If !Empty(cLocDigIgn)
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)

		Do case

			case cTipData == '1'

				If lMV_STATISS
					cSql += " AND B44_DTLBFN BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
				Else
					cSql += "AND BD6_DTDIGI BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
				EndIf

			case (cTipData == '2' .Or. cTipData == '4') .And. !lMV_STATISS

				cDataIni := DataTrimestre(cDataRef,"1")
				cDataFin := DataTrimestre(cDataRef,"2")
				cSql += "AND E1_EMIS1 BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "

			OtherWise

				cSql += "AND BD7_DATPRO BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "

		EndCase

		cSql += " AND BA1_INFANS = '1' "
		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' "
		cSql += " AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' ' "
		cSql += " AND B44.D_E_L_E_T_ = ' ' "
		If !lMV_STATISS
			cSql += "AND SE1.D_E_L_E_T_ = ' ' "
		EndIf

		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias == "TRBACU"

		If !lCount
			cSelect += " B19_GUIA, BD5_GUIINT "
		EndIf

		cSql := cSelect + " "
		cSql += " FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BD5") + " BD5, "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "

		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif

		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, " + RetSqlName("BR8") + " BR8, " + RetSqlName("B19") + " B19, "
		cSql += " " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF1") + " SF1 "

		cSql += " WHERE "

		cSql += " BD5_FILIAL = '" + xFilial("BD5") + "' "
		cSql += " AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' AND B19_FILIAL = '" + xFilial("B19") + "' "
		cSql += " AND D1_FILIAL = '" + xFilial("SD1") + "' AND F1_FILIAL = '" + xFilial("SF1") + "' "

		cSql += " AND BD5_CODOPE = BD6_CODOPE AND BD5_CODLDP = BD6_CODLDP "
		cSql += " AND BD5_CODPEG = BD6_CODPEG AND BD5_NUMERO = BD6_NUMERO "
		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP AND BD7_CODPEG = BD6_CODPEG "
		cSql += " AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
		cSql += " AND BD7_CODOPE = SUBSTRING(B19_GUIA, 1, 4) AND BD7_CODLDP = SUBSTRING(B19_GUIA, 5, 4) "
		cSql += " AND BD7_CODPEG = SUBSTRING(B19_GUIA, 9, 8) AND BD7_NUMERO = SUBSTRING(B19_GUIA, 17, 8) "
		cSql += " AND BD7_ORIMOV = SUBSTRING(B19_GUIA, 25, 1) AND BD7_SEQUEN = SUBSTRING(B19_GUIA, 26, 3) "
		cSql += " AND BD5_OPEUSR = BA3_CODINT AND BD5_CODEMP = BA3_CODEMP AND BD5_MATRIC = BA3_MATRIC "
		cSql += " AND D1_DOC = B19_DOC AND D1_SERIE = B19_SERIE AND D1_FORNECE = B19_FORNEC AND D1_LOJA = B19_LOJA "
		cSql += " AND D1_ITEM = B19_ITEM AND D1_COD = B19_COD "
		cSql += " AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND F1_LOJA = D1_LOJA "
		cSql += " AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "

		If !Empty(cLocDigIgn)
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		Do case
			case cTipData == '1'
				cSql += "AND BD6_DTDIGI BETWEEN '" + DataTrimestre(cDataRef,"1") + "' AND '" + DataTrimestre(cDataRef,"2") + "' "
			case cTipData == '2' .Or. cTipData == '4'
				cSql += "AND D1_DTDIGIT BETWEEN '" + DataTrimestre(cDataRef,"1") + "' AND '" + DataTrimestre(cDataRef,"2") + "' "
			OtherWise
				cSql += "AND BD7_DATPRO BETWEEN '" + DataTrimestre(cDataRef,"1") + "' AND '" + DataTrimestre(cDataRef,"2") + "' "
		EndCase

		cSql += " AND BA1_INFANS = '1' "
		cSql += " AND BD7_RECSIP = ' ' "
		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' "
		cSql += " AND BR8.D_E_L_E_T_ = ' ' AND B19.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' AND SF1.D_E_L_E_T_ = ' ' "
		cSql += "AND BD5.D_E_L_E_T_ = ' ' "

		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias == "TRBEXP"

		cDatBlo := DataTrimestre(cDataRef,"1")

		If lCount
			cSql := cSelect
		Else
			cSql := " SELECT "
			cSql += " '" + SubStr(cOpePadr,1,1) + "' BA0_CODIDE, '" + SubStr(cOpePadr,2,3) + "' BA0_CODINT, "
			cSql += " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DATCAR, BA1_DATINC, BA1_DATNAS, "
			cSql += " BA1_DATBLO, BA1_SEXO, BA1_NOMUSR, BA3_CODPLA, BA3_VERSAO, BA1_CODPLA, BA1_VERSAO, "
			cSql += " BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_DIGITO, BG9_TIPO, BG9_REPASS "

		EndIf

		cSql += " FROM "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif
		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, " + RetSqlName("BG9") + " BG9 "
		cSql += " WHERE "
		cSql += " BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BG9_FILIAL = '" + xFilial("BG9") + "' "
		cSql += " AND BA1_CODINT = '" + cOpePadr + "' AND BA1_OPEORI = '" + cOpePadr + "' "
		cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
		cSql += " AND BA1_CODINT = BG9_CODINT AND BA1_CODEMP = BG9_CODIGO "
		If Len(aBenef) > 0
			cSql += " AND BA1.R_E_C_N_O_ BETWEEN " + Alltrim(Str(aBenef[1])) + " AND " + Alltrim(Str(aBenef[2])) + " "
		EndIf
		cSql += " AND ( BA1_DATBLO = ' ' OR BA1_DATBLO >= '" + cDatBlo + "' ) "
		cSql += " AND BA1_DATINC <= '" + DataTrimestre(cDataRef,"2") + "' "
		cSql += " AND BA1_INFANS = '1' "
		cSql += " AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' AND BG9.D_E_L_E_T_ = ' ' "

	Endif

	cSql := ChangeQuery(cSql)

	If cAlias != "TRBPCT"
		PlsLogFil(cCabLog + CENDTHRL("I") + " " + cSql,ARQ_LOG_DES)
	EndIf

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql), cAlias,.F.,.T.)
	If cAlias != "TRBPCT"
		PlsLogFil(cCabLog + CENDTHRL("I") + " " + cCount + " Fim da query" ,ARQ_LOG_DES)
	EndIf

	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "[" + Time() + "] Termino Carregadados" , 0, 0, {})

	PlsLogFil(cCabLog + CENDTHRL("I") + " Termino carregadados.",ARQ_LOG_DES)
	If Empty(cAlias) .Or. (cAlias)->(Eof()) .Or. (lCount .And. (cAlias)->Total == 0 )
		lRetorno := .F.
		PlsLogFil(cCabLog + CENDTHRL("I") + " Nao encontrou dados.",ARQ_LOG_DES)
	Else
		lRetorno := .T.
		PlsLogFil(cCabLog + CENDTHRL("I") + " Encontrou dados.",ARQ_LOG_DES)
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmpIncDesp

Funcao criada para incluir despesas na tabela temporaria B3Q da Central de Obrigacoes

@param cRegANS		Numero de registro da operadora na ANS
@param cCodObri	Chave da obrigacao
@param cAnoComp	Ano do compromisso
@param cCodComp	Chave do compromisso
@param aClasEven	Informacoes do evento classificado a ser incluido

@return lRetorno	Indica Verdadeiro (.T.) se inclui o registro ou Falso (.F.) para erro

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven,aForSeg,lProSemCla,lCapit)
	Local lRetorno		:= .T. //Indica se incluiu .T. ou nao .F. a despesa
	Local cForCon		:= "" //Forma de contratacao do plano
	Local cSegmen		:= "" //Segmentacao do plano
	Local cUF			:= Upper(aClasEven[__UF])
	Local nForSeg		:= 0
	Default cCodObri	:= "" //Chave da obrigacao
	Default cAnoComp	:= "" //Ano do compromisso
	Default cCodComp	:= "" //Codigo do compromisso
	Default cRegANS	    := '00000'
	Default aForSeg	    := {}
	Default lProSemCla	:= Empty(aClasEven[CLASIPSER]) .And. Empty(aClasEven[CLASIPINT])
	Default lCapit      := .F.

	If !Empty(aClasEven[__MATRIC]) //Vou recuperar forma de contratacao e segmentacao do plano do beneficiario

		If B3K->(B3K_FILIAL+B3K_CODOPE+B3K_MATRIC) == xFilial("B3K")+cRegANS+aClasEven[__MATRIC] ;
				.OR. B3K->(msSeek(xFilial("B3K")+cRegANS+aClasEven[__MATRIC]))//B3K_FILIAL||B3K_CODOPE||B3K_MATRIC

			nForSeg := aScan(aForSeg,{ |x| x[1] == cRegANS+B3K->B3K_CODPRO })

			If nForSeg > 0
				cForCon := aForSeg[nForSeg,2]
				cSegmen := aForSeg[nForSeg,3]
			EndIf

			If nForSeg == 0 .And. B3J->(msSeek(xFilial("B3J")+cRegANS+B3K->B3K_CODPRO))
				cForCon := B3J->B3J_FORCON
				cSegmen := B3J->B3J_SEGMEN
				aAdd(aForSeg,{cRegANS+B3K->B3K_CODPRO,cForCon,cSegmen})
			EndIf

			If cUF == "ZZ"
				BA0->(DbSetOrder(5))
				If BA0->(dbSeek(xFilial("BA0")+B3K->B3K_CODOPE))
					cEstado:= BA0->BA0_EST
				EndIf
			EndIf

		EndIf

	EndIf
	cSegmen := AjustaSeg(IIf(Empty(alltrim(aClasEven[CLASIPSER])),aClasEven[CLASIPINT],aClasEven[CLASIPSER]),cSegmen)
	/*PlsLogFil(CENDTHRL("I") + "chave guia;" + aClasEven[CHVGUIGRV] + ";Internação;" + aClasEven[CHVGUIINT] + ";Matricula;" + aClasEven[__MATRIC] +;
				";trimestre ocorrencia;" + aClasEven[TRIMOCOR] + ";trimestre reconhecimento;" + aClasEven[TRIMRECO] + ";procedimento;"+aClasEven[PROCEDIME],ARQ_LOG_DES)
			*/RecLock("B3Q",.T.)
	B3Q->B3Q_FILIAL := xFilial('B3Q')
	B3Q->B3Q_CODOPE := cRegANS
	B3Q->B3Q_CODOBR := cCodObri
	B3Q->B3Q_ANOCMP := cAnoComp
	B3Q->B3Q_CDCOMP := cCodComp
	B3Q->B3Q_MATRIC := aClasEven[__MATRIC]
	B3Q->B3Q_EVEDES := aClasEven[CHVGUIGRV]
	B3Q->B3Q_EVDEIN := aClasEven[CHVGUIINT]
	B3Q->B3Q_UF		:= Upper(aClasEven[__UF])
	B3Q->B3Q_TRIREC := aClasEven[TRIMRECO]
	B3Q->B3Q_TRIOCO := aClasEven[TRIMOCOR]
	B3Q->B3Q_CDTPTB := Left(aClasEven[PROCEDIME],2)
	B3Q->B3Q_CODEVE := Right(aClasEven[PROCEDIME],Len(aClasEven[PROCEDIME])-2)
	B3Q->B3Q_DATEVE := STOD(aClasEven[DATAPROC])
	B3Q->B3Q_QTDEVE := aClasEven[QTDEREAL]
	B3Q->B3Q_VLREVE := aClasEven[VLRDESP]
	B3Q->B3Q_CLAAMB := aClasEven[CLASIPSER]
	B3Q->B3Q_CLAINT := aClasEven[CLASIPINT]
	B3Q->B3Q_GRPINT := aClasEven[GRUPOINT]
	B3Q->B3Q_REGINT := aClasEven[REGIMEINT]
	B3Q->B3Q_CID	:= Upper(aClasEven[__CID])
	B3Q->B3Q_DATINT := Iif( ValType(aClasEven[__DATINT]) == "D", aClasEven[__DATINT], STOD("") )
	B3Q->B3Q_HORINT := aClasEven[__HORAINT]
	B3Q->B3Q_DATALT := Iif( ValType(aClasEven[DATALTA]) == "D", aClasEven[DATALTA], STOD("") )
	B3Q->B3Q_HORALT := aClasEven[HORAALTA]
	B3Q->B3Q_NASVIV := aClasEven[QTDNASVIV]
	B3Q->B3Q_DENREG := aClasEven[__DENTE]
	B3Q->B3Q_FORCON := cForCon
	B3Q->B3Q_SEGMEN := cSegmen
	B3Q->B3Q_STATUS := Iif(lProSemCla,'1','Z')
	If lB3Q_EVDRES
		B3Q->B3Q_EVDRES := aClasEven[CHVRESUMO]
	EndIf
	If lB3Q_CLASSH
		B3Q->B3Q_CLASSH := aClasEven[CLASHDESC]
	Endif
	B3Q->(msUnLock())

	MarcaBD7(aClasEven[CHVGUIGRV],aClasEven[TRIMRECO],lCapit)

Return lRetorno

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} AjustaSeg

	Funcao criada para realizar o ajuste da segmentacao da despesa que esta sendo processada

	@param cItem	Item do SIP que esta sendo procesado
	@param cSegmen	Codigo da Segmentacao encontrado

	@return cSeg	Novo codigo de segmentacao ajustado

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function AjustaSeg(cItem,cSegmen)
	Local cSeg := ""
	Local  lMV_PLQDOBS := GetNewPar("MV_PLQDOBS",.T.)
	Default cSegmen := "1"
	//Ajusta a Segmentação
	If cItem $ 'E13,E131,E132'
		cSeg := '3' //3=Hospitalar obstetrico
	ElseIf cItem >= 'A' .AND. cItem <= 'A999' .OR. ;
			cItem >= 'B' .AND. cItem <= 'B999' .OR. ;
			cItem >= 'C' .AND. cItem <= 'C999' .OR. ;
			cItem >= 'D' .AND. cItem <= 'D999' .OR. ;
			cItem >= 'H' .AND. cItem <= 'H999'
		cSeg := '1' //1=Ambulatorial
	ElseIf cItem >= 'E' .AND. cItem <= 'E999' .OR. ;
			cItem >= 'F' .AND. cItem <= 'F999' .OR. ;
			cItem >= 'G' .AND. cItem <= 'G999'
		If lMV_PLQDOBS
			cSeg := '3' //3=Hospitalar obstetrico
		Else
			cSeg := '2' //2=Hospitalar
		EndIf
	ElseIf cItem >= 'I' .AND. cItem <= 'I999'
		cSeg := '4' //4=Odontologico
	Else
		cSeg := cSegmen
	EndIf

Return cSeg
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExisteDespesa

	Funcao criada para verificar se ja existe a despesa / carencia cadastrada na central de obrigacaoes

	@param cRegANS		Numero de registro da operadora  na ANS
	@param cCodObri	Chave da obrigacao
	@param cAnoComp	Ano do compromisso
	@param cCodComp	Chave do compromisso
	@param cChaveGuia	Chave da guia
	@param cMatric		Matricula do beneficiario
	@param cAlias		Area de trabalho corrente
	@param cItem		Codigo do item assistencial
	@param aClasEven	Matria com informacoes do evento classificado
	@param nRecB3L		Numero do recno encontrado na tabela B3L
	@param cForCon		Forma de contratacao do plano
	@param cSegmen 	Segmentacao do plano
	@param cDatEve		Data de realizacao do evento

	@return lRetorno	Indica Verdadeiro (.T.) se encontrou registro ou Falso (.F.) caso nao encontre

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteDespesa(cRegANS,cCodObri,cAnoComp,cCodComp,cChaveGuia,cMatric,cAlias,cItem,aClasEven,nRecB3L,cForCon,cSegmen,cDatEve,cUF,cEvDeIn)
	Local lRetorno		:= .F.
	Local cSql			:= ""
	Default cRegANS		:= ""
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default cChaveGuia	:= ""
	Default cMatric		:= ""
	Default cItem		:= ""
	Default aClasEven	:= array(26)
	Default nRecB3L		:= 0
	Default cForCon		:= ""
	Default cSegmen		:= ""
	Default cDatEve		:= ""
	Default cUF			:= "ZZ"
	Default cEvDeIn		:= ""

	If cAlias != "TRBEXP"

		cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B3L") + " "
		If BANCO == "MSSQL7"
			cSql += "WITH (NOLOCK) "
		EndIf
		cSql += "WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
		cSql += "AND B3L_CODOPE = '" + cRegANS + "' "
		cSql += "AND B3L_CODOBR = '" + cCodObri + "' "
		cSql += "AND B3L_ANOCMP = '" + cAnoComp + "' "
		cSql += "AND B3L_CDCOMP = '" + cCodComp + "' "
		cSql += "AND B3L_EVEDES = '" + cChaveGuia + "' "
		cSql += "AND B3L_MATRIC = '" + cMatric + "' "
		If Empty(cItem)//Item
			cSql += "AND B3L_CDTPTB = '" + SubStr(aClasEven[PROCEDIME],1,2) + "' "
			cSql += "AND B3L_CODEVE = '" + SubStr(aClasEven[PROCEDIME],3,Len(aClasEven[PROCEDIME])) + "' "
			cSql += "AND B3L_CLAAMB = '" + aClasEven[CLASIPSER] + "' "
			cSql += "AND B3L_CLAINT = '" + aClasEven[CLASIPINT] + "' "
			cSql += "AND B3L_UF = '" + cUF + "' "//UF so tem aqui mesmo pois nao coube na chave unica
		Else//Totalizador
			cSql += "AND B3L_CDTPTB = ' ' "
			cSql += "AND B3L_CODEVE = ' ' "
			cSql += "AND B3L_CLAAMB = '" + cItem + "' "
			cSql += "AND B3L_CLAINT = '" + cItem + "' "
		EndIf
		If !Empty(cForCon)
			cSql += "AND B3L_FORCON = '" + cForCon + "' "
		Else
			cSql += "AND B3L_FORCON = ' ' "
		EndIf
		If !Empty(cSegmen)
			cSql += "AND B3L_SEGMEN = '" + cSegmen + "' "
		Else
			cSql += "AND B3L_SEGMEN = ' ' "
		EndIf
		If !Empty(cDatEve)
			cSql += "AND B3L_DATEVE = '" + cDatEve + "' "
		Else
			cSql += "AND B3L_DATEVE = ' ' "
		EndIf
		cSql += "AND D_E_L_E_T_ = ' ' "

	Else
	//B3O_FILIAL+B3O_CODOPE+B3O_CDOBRI+B3O_ANO+B3O_CDCOMP+B3O_MATRIC+B3O_ITEM
		cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B3O") + " "
		If BANCO == "MSSQL7"
			cSql += "WITH (NOLOCK) "
		EndIf
		cSql += "WHERE B3O_FILIAL = '" + xFilial("B3O") + "' "
		If !Empty(cRegANS)
			cSql += "AND B3O_CODOPE = '" + cRegANS + "' "
		EndIf
		If !Empty(cCodObri)
			cSql += "AND B3O_CDOBRI = '" + cCodObri + "' "
		EndIf
		If !Empty(cAnoComp)
			cSql += "AND B3O_ANO = '" + cAnoComp + "' "
		EndIf
		If !Empty(cCodComp)
			cSql += "AND B3O_CDCOMP = '" + cCodComp + "' "
		EndIf
		If !Empty(cMatric)
			cSql += "AND B3O_MATRIC = '" + cMatric + "' "
		EndIf
		If !Empty(cItem)
			cSql += "AND B3O_ITEM = '" + cItem + "' "
		EndIf
		cSql += "AND D_E_L_E_T_ = ' ' "

	EndIf

	cSql := ChangeQuery(cSql)
	cSql := InsereNoLock(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBEXI",.F.,.T.)

	If !TRBEXI->(Eof())
		lRetorno := .T.
		nRecB3L := TRBEXI->R_E_C_N_O_
	EndIf

	TRBEXI->(dbCloseArea())

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} LocalizaCompromisso

	Funcao criada para alimetar as variaveis referente a chave do compromisso se este for encontrado

	@param cDataReal	Data de realizacao ou database
	@param cCodObri	Chave do obrigacao
	@param cAnoComp	Ano do compromisso
	@param cSazComp	Chave da sazonalidade
	@param cCodComp	Codigo do compromisso
	@param cRegANS		Numero de registro da operadora na ANS

	@return lRetorno	Retorna Verdadeiro (.T.) se localizou ou Falso (.F.) caso nao encontre

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function LocalizaCompromisso(cDataReal,cCodObri,cAnoComp,cSazComp,cCodComp,cRegANS)
	Local lRetorno		:= .T.
	Default cDataReal:= DTOS(dDataBase)
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cSazComp	:= ""
	Default cCodComp	:= ""
	Default cRegANS	:= '000000'

	B3A->(dbSetOrder(2))//B3A_FILIAL + B3A_CODOPE + B3A_TIPO
	If B3A->(msSeek(xFilial("B3A")+cRegANS+'1')) .And. B3A->B3A_ATIVO = '1'
		cCodObri := B3A->B3A_CODIGO
		cSazComp := B3A->B3A_SZNLDD
	Else
		lRetorno := .F.
	EndIf
	B3D->(dbSetOrder(1))//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO
	If lRetorno .And. B3D->(msSeek(xFilial('B3D')+cRegANS+cCodObri+Left(cDataReal,4)+"0"+Right(cDataReal,2)))
		cAnoComp := B3D->B3D_ANO
		cCodComp := B3D->B3D_CODIGO
	Else
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ProximaGuia

	Funcao criada para movimentar a area de trabalho para a proxima guia a ser processada

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave da guia posicionada (BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ProximaGuia(cAlias,cChaveGuia)
	Default cChaveGuia	:= ""

	While (cAlias)->(!Eof()) .And. cChaveGuia == (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
		(cAlias)->(dbSkip())
	End

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} DataReconhece

	Funcao criada para retornar a data de ocorrencia do procedimento

	@param cAlias		Area de trabalho ou tabela que esta sendo movimentada
	@param cTipData		Tipo de data que sera retornada como data de ocorrencia

	@return cDatReco	Data de reconhecimento identificada

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit)
	Local cDatReco		:= ""
	Default cAlias	:= 'TRBDES'
	Default cTipData	:= '1'
	Default lMV_STATISS	:= MV_STATISS
	Default lCapit      := .f.

	If lCapit
		cDatReco := (cAlias)->BD7_DTDIGI
	Else
		If cTipData == '2' //2-Pagamento
			cDatReco := SubStr((cAlias)->BD7_NUMLOT,1,6) + "01"
		ElseIf cTipData == '3' //3-Procedimento
			cDatReco := (cAlias)->BD7_DATPRO
		ElseIf cTipData == '4' //4- Data de Pagamento
			cDatReco := SubStr((cAlias)->BD7_DTPAGT,1,6) + "01"
		Else //1-Digitacao
			If lMV_STATISS
				cDatReco := AllTrim(DataReconPeg(cAlias,lMV_STATISS))
				If Len(cDatReco) < 6
					cDatReco := (cAlias)->BD6_DTDIGI
				EndIf
			Else
				cDatReco := (cAlias)->BD6_DTDIGI
			EndIf
		EndIf
	EndIf

Return cDatReco
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} DataTrimestre

	Funcao criada para transformar a data em trimestre valido para o SIP

	@param cData	Data (AAAAMMDD) que sera transformata em trimestre (AAAAMM) ou AAAAMMDD inicial ou final do trimestre
	@param nOpc		Tipo de retorno
	1 - monto o retorno da data AAAAMMDD inicial
	2 - monto o retorno da data AAAAMMDD final
	3 - default - monto o retorno do trimestre AAAAMM

	@return cTrimestre	Retorno o trimestre identificado

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function DataTrimestre(cData,cOpc)
	Local nTrimestre	:= 1
	Local nAscan		:= 0
	Local cTrimestre	:= ""
	Local aPeriodos	:= {}
	Default cData		:= DTOS(dDataBase)
	Default cOpc		:= ""// "" - AAAADD, "1" - AAAAMMDD inicial, "2" - AAAAMMDD final

	aAdd(aPeriodos,{"01","02","03"})
	aAdd(aPeriodos,{"04","05","06"})
	aAdd(aPeriodos,{"07","08","09"})
	aAdd(aPeriodos,{"10","11","12"})

	//Identifico o trimestre que pertence a data
	nAscan := Ascan( aPeriodos,{|x| x[1] == Substr(cData,5,2) .Or. x[2] == Substr(cData,5,2) .Or. x[3] == Substr(cData,5,2)})
	If nAscan > 0//Devo proteger nTrimestre de receber zero
		nTrimestre := nAscan
	EndIf

	If cOpc == "1"//monto o retorno da data AAAAMMDD inicial

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,1]
		cTrimestre += "01"

	ElseIf cOpc == "2"//monto o retorno da data AAAAMMDD final

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,3]
		If nTrimestre == 1
			If SubStr(cTrimestre,5,2) == "02"
				If Val(SubStr(cTrimestre,1,4)) % 4 == 0
					cTrimestre += "29"
				Else
					cTrimestre += "28"
				EndIf
			Else
				cTrimestre += "31"
			EndIf
		Else
			If SubStr(cTrimestre,5,2) $ "04,06,09,10"
				cTrimestre += "30"
			Else
				cTrimestre += "31"
			EndIf
		EndIf

	Else//monto o retorno do trimestre AAAAMM
		cTrimestre := Substr(cData,1,4)+PADL(Alltrim(Str(nTrimestre)),2,"0")
	EndIf

Return cTrimestre

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PegaProduto

	Funcao criado para retornar a chave do produto do beneficiario

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param lPodeBR		Indica que deverá as regras estabelecidas na tabela padrão deverão ser consideradas para este produto
	@param cCodSeg		Codigo da segmentacao do produto
	@param lAtenOdon	Indica se o produto permite .T. ou nao .F. atendimento odontologico
	@param cForCon		Forma de contratacao do produto / plano

	@return cChaveProd	Chave do produto do beneficiario operadora+codigo+versao

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PegaProduto(cAlias,lPodeBR8,cCodSeg,lAtenOdon,cForCon)
	Local cChaveProd	:= ""
	Default cCodSeg	:= "1"
	Default cForCon	:= "1"
	Default lPodeBR8	:= .F.
	Default lAtenOdon:= .F.

	If !Empty((cAlias)->(BA3_CODPLA+BA3_VERSAO))
		cChaveProd := (cAlias)->(BA0_CODIDE+BA0_CODINT+BA3_CODPLA+BA3_VERSAO)
	Else
		cChaveProd := (cAlias)->(BA0_CODIDE+BA0_CODINT+BA1_CODPLA+BA1_VERSAO)
	EndIf

	If cAlias == "TRBEXP"

		If BI3->(msSeek(xFilial("BI3")+cChaveProd))

			lPodeBR8	:= BI3->BI3_TODOS == "1"

			If BI6->(msSeek(xFilial("BI6")+BI3->BI3_CODSEG))
				lAtenOdon	:= BI6->BI6_ODONTO == "1"
				cCodSeg		:= BI6->BI6_SEGSIP
			EndIf

			If BII->(msSeek(xFilial("BII")+BI3->BI3_TIPCON))
				cForCon := BII->BII_TIPPLA
			EndIf

		EndIf

	EndIf

Return cChaveProd
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaRepasse

	Funcao criada para descartar / pular beneficiarios pertencentes a contrato de reciprocidade

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave da guia posicionada (BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

	@return lRetorno	Indica se pulou .T. ou nao .F. o grupo empresa considerado como reciprocidade

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PulaRepasse(cAlias,cChave)
	Local lRetorno	:= .F.
	Default cAlias	:= ""
	Default cChave	:= ""

	If !Empty(cAlias) .And. !Empty(cChave) .And. ;
		( ;
			BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) == xFilial("BG9")+(cAlias)->(BA0_CODIDE+BA0_CODINT+BA1_CODEMP) ;
			.OR. BG9->(msSeek(xFilial("BG9")+(cAlias)->(BA0_CODIDE+BA0_CODINT+BA1_CODEMP) )) ;
		) .And. BG9->BG9_REPASS == '1'

		If cAlias != "TRBEXP"//Proxima guia somente quando nao estiver contando beneficiarios expostos
			ProximaGuia(cAlias,@cChave)
		EndIf
		lRetorno := .T.

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaEstorno

	Funcao criara para descartar / pular as despesas estornadas que nao devem ser consideradas=

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave da guia posicionada (BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

	@return lRetorno	Indica se pulou .T. ou nao .F. despesa

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PulaEstorno(cAliEst,cChaveGuia)
	Local lRetorno			:= .F.
	Default cAliEst		:= ""
	Default cChaveGuia	:= ""

	//Despreza guias de consulta e servico estornadas | Esta do Indice 1 da BD5
	If !Empty(cAliEst) .And. !Empty(cChaveGuia) .And. ExisteEstorno(cChaveGuia)

		ProximaGuia(cAliEst,cChaveGuia)
		lRetorno := .T.

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaProduto

	Funcao criara para descartar / pular os produtos que nao sao informados para ANS

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave do produto que sera testado

	@return lRetorno	Indica se pulou .T. ou nao .F. produto

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PulaProduto(cAliPrd,cChaveProd,aProduto)
	Local lRetorno			:= .F.
	Local nProduto			:= 0
	Default cAliPrd		:= ""
	Default cChaveProd	:= ""
	Default aProduto		:= {}

	nProduto := aScan(aProduto,{|x| x[1] == cChaveProd})

	If nProduto == 0 .And. !Empty(cAliPrd) .And. InformaProduto(cChaveProd,aProduto)

		If cAliPrd != 'TRBEXP'
			ProximaGuia(cAliPrd,cChaveProd)
		EndIf
		lRetorno := .T.

	Else

		If nProduto > 0 .And. cAliPrd != 'TRBEXP' .And. aProduto[nProduto,1] == '0'
			ProximaGuia(cAliPrd,cChaveProd)
			lRetorno := .T.
		EndIf

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PegaNatSaude

	Funcao criada para retornar a matriz de natureza de saude BF0

	@param cClasip	opicional - quando informado retorna apenas os itens pertencetees ao grupo cClaSip

	@return aNatSaude	Matriz de natureza de saude
	@description
	[1] - BF0_CODIGO	-	codigo da naturea de saude
	[2] - 0				-	zero
	[3] - data vazia	-	data vazia
	[4] - BF0_IDADE1	-	idade de
	[5] - BF0_IDADE2	-	idade ate
	[6] - BF0_SEXO		-	sexo
	[7] - BF0_NIVEL	-	1-grupo; 2-subgrupo; 3-item
	[7] - BF0_CODSUP	-	1-grupo; 2-subgrupo; 3-item

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PegaNatSaude()
	Local aNatSaude	:= {}
	Local cSql			:= ""

	BF0->(dbSetOrder(3))//BF0_FILIAL+BF0_GRUGEN+BF0_CODSUP+BF0_CODIGO

	cSql := "SELECT BF0_CODSUP, BF0_CODIGO, BF0_NIVEL, BF0_IDADE1, BF0_IDADE2, BF0_SEXO "
	cSql += "FROM " + RetSqlName("BF0") + " BF0 "
	cSql += "WHERE BF0_FILIAL = '" + xFilial("BF0") + "' AND BF0_GRUGEN = '" + GetNewPar("MV_PLGRSIP","0001") + "' AND BF0_BENEF = '1' AND SUBSTRING(BF0_CODSUP,1,1) <> 'F' "
	cSql += "AND BF0.D_E_L_E_T_ = ' '  "
	cSql += "ORDER BY BF0_CODIGO"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBF0",.F.,.T.)
	// PlsLogFil("query natsaude"+ CENDTHRL("I") + cSql,DEBUG_EXP)

	While !TRBBF0->(Eof())

		If BF0->(msSeek(xFilial("BF0")+GetNewPar("MV_PLGRSIP","0001")+TRBBF0->BF0_CODIGO))

			While !BF0->(Eof()) .And. BF0->BF0_CODSUP == TRBBF0->BF0_CODIGO

				If aScan(aNatSaude,{|x| x[1] == BF0->BF0_CODIGO}) == 0

					aAdd(aNatSaude,{BF0->BF0_CODIGO,0,CTOD("19990101"),BF0->BF0_IDADE1, BF0->BF0_IDADE2,BF0->BF0_SEXO, BF0->BF0_NIVEL,TRBBF0->BF0_CODSUP})
					// PlsLogFil(TRBBF0->BF0_NIVEL + " aAdd(aNatSaude,{"+ BF0->BF0_CODIGO+",0,01/01/1999,"+AllTrim(Str(BF0->BF0_IDADE1))+","+AllTrim(Str(BF0->BF0_IDADE2))+","+BF0->BF0_SEXO+","+BF0->BF0_NIVEL+","+TRBBF0->BF0_CODSUP+"}) " ,DEBUG_EXP)
				EndIf

				BF0->(DbSkip())

			EndDo

		EndIf//BF0->(msSeek(xFilial("BF0")+GetNewPar("MV_PLGRSIP","0001")+TRBBF0->BF0_CODIGO))

		If aScan(aNatSaude,{|x| x[1] == TRBBF0->BF0_CODIGO}) == 0

			aAdd(aNatSaude,{TRBBF0->BF0_CODIGO,0,CTOD("19990101"),TRBBF0->BF0_IDADE1, TRBBF0->BF0_IDADE2, TRBBF0->BF0_SEXO, TRBBF0->BF0_NIVEL,TRBBF0->BF0_CODSUP})
			// PlsLogFil(TRBBF0->BF0_NIVEL + " aAdd(aNatSaude,{"+ BF0->BF0_CODIGO+",0,01/01/1999,"+AllTrim(Str(BF0->BF0_IDADE1))+","+AllTrim(Str(BF0->BF0_IDADE2))+","+BF0->BF0_SEXO+","+BF0->BF0_NIVEL+","+TRBBF0->BF0_CODSUP+"}) " ,DEBUG_EXP)
		EndIf

		TRBBF0->(dbSkip())

	EndDo

	If Len(aNatSaude) > 0
		aSort(aNatSaude,,,{|x,y| x[1] < y[1]})
	EndIf

	BF0->(dbCloseArea())
	TRBBF0->(dbCloseArea())

Return aNatSaude
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} BenefBloqueio

	Funcao criada para verificar se o beneficiario esta bloqueado no periodo do envio do SIP

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cDataRef	Data de referencia
	@param cDataBlo	Data de bloqueio do beneficiario

	@return lRetorno	Indica se o beneficiario estava .T. ou nao .F. bloqueado no periodo

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefBloqueio(cAlias,cDataRef,cDataBlo)
	Local lRetorno	:= .F.
	Local lBlqANS	:= .F.
	Local cSql		:= ""
	Local cDataIni	:= DataTrimestre(cDataRef)+"00"
	Local cDataFin	:= Left(cDataIni,4)+Soma1(SubStr(cDataIni,5,2),2)+"99"

	cDataBlo	:= (cAlias)->BA1_DATBLO

	cSql := "SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ "
	cSql += "FROM " + RetSqlName("BCA") +" BCA "
	cSql += "WHERE BCA_FILIAL = '"+ xFilial("BCA") +"' AND BCA_MATRIC = '" + (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) + "' AND BCA_TIPREG = '" + (cAlias)->BA1_TIPREG + "' "
	cSql += "AND BCA_DATA >= '" + cDataIni + "' AND BCA_DATA <= '" + cDataFin + "' AND BCA_TIPO = '0' AND BCA.D_E_L_E_T_ = ' '  "
	cSql += "ORDER BY BCA_DATA, R_E_C_N_O_"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBCA",.F.,.T.)

	While !TRBBCA->(Eof())

		lBlqANS := .F.

		Do Case

		Case TRBBCA->BCA_NIVBLQ == "U" // Nivel de Usuario

			If  BG3->(msSeek(xFilial("BG3")+TRBBCA->BCA_MOTBLO))
				If  !Empty(BG3->BG3_BLQANS)
					lBlqANS := .T.
				EndIf
			EndIf

		Case TRBBCA->BCA_NIVBLQ == "F" // Nivel de Familia

			If  BG1->(MsSeek(xFilial("BG1")+TRBBCA->BCA_MOTBLO))
				If  !Empty(BG1->BG1_BLQANS)
					lBlqANS := .T.
				EndIf
			EndIf

		Case TRBBCA->BCA_NIVBLQ == "S" // Nivel de Sub-Contrato

			If  BQU->(MsSeek(xFilial("BQU")+TRBBCA->BCA_MOTBLO))
				If  !Empty(BQU->BQU_BLQANS)
					lBlqANS := .T.
				EndIf
			EndIf

		EndCase

		If  lBlqANS
			cDataBlo := TRBBCA->BCA_DATA
		EndIf

		TRBBCA->(dbSkip())

	EndDo

	TRBBCA->(dbCloseArea())

	If !Empty(cDataBlo) .And. cDataBlo < cDataIni
		lRetorno := .T.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CarregaCarencia

	Funcao criada para carregar informacoes de carencia do beneficiario

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cMatric		Matricula do beneficiario
	@param cContrato	Chave completa do contrato do beneficiario
	@param cProduto	Chave completa do produto do beneficiario

	@return lRetorno	Indica se foi .T. ou nao .F. encontrado carencia para o beneficiario no PLS

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaCarencia(cAlias,cMatUsu,cContrato,cProduto)
	Local lRetorno	:= .F.
	Local cSql		:= ""
	Local cOpeUsr	:= SubStr(cMatUsu,1,4)
	Local cCodEmp	:= SubStr(cMatUsu,5,4)
	Local cMatric	:= SubStr(cMatUsu,9,6)
	Local cTipReg	:= SubStr(cMatUsu,15,2)
	Local cNumCon	:= SubStr(cContrato,5,12)
	Local cVerCon	:= SubStr(cContrato,17,3)
	Local cSubCon	:= SubStr(cContrato,20,9)
	Local cVerSub	:= SubStr(cContrato,29,3)
	Local cCodPro	:= SubStr(cProduto,5,4)
	Local cVerPro	:= SubStr(cProduto,9,3)
	Local lPodeBR8  := .F.

	BI3->(dbSetOrder(1))
	If BI3->(msSeek(xFilial("BI3")+cProduto))
		lPodeBR8	:= BI3->BI3_TODOS == "1"
	EndIf

	If lPodeBR8 //considera tabela padrão?

		//Consulta para obter os dados de cobertura/carencia, otimizado para o Exposto.
		cSql := " SELECT BR8_CODPAD, MAX(BR8_CODPSA) BR8_CODPSA, BR8_CLASIP, BR8_CLASP2, '' BG8_CODGRU, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,  BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " '' BFE_CODGRU, ''BFE_DATCAR, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " '' BFC_CODGRU, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " '' BT7_CARENC, '' BT7_UNCAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " '' BRV_CODGRU, '' BG8_CARENC, '' BG8_UNCAR, '' BG8_CLACAR, '' BG8_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "

		cSql += " FROM " + RetSqlName("BR8") + " BR8 "

		//COBERTURA NO USUARIO - CLasse de carência no beneficiário
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFO") + " BFO "
		cSql += " ON BFO_FILIAL = '" + xFilial("BFO") + "' "
		cSql += " AND BFO_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFO_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFO_MATRIC = '"+cMatric+"' "
		cSql += " AND BFO_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFO_CLACAR = BR8_CLACAR "
		cSql += " AND BFO.D_E_L_E_T_ = ' '  "

		//COBERTURA NO USUARIO - PROCEDIMENTOS EXCLUSIVOS PARA O BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFG") + " BFG "
		cSql += " ON BFG_FILIAL = '" + xFilial("BFG") + "' "
		cSql += " AND BFG_CODPAD = BR8_CODPAD "
		cSql += " AND BFG_CODPSA = BR8_CODPSA "
		cSql += " AND BFG_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFG_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFG_MATRIC = '"+cMatric+"' "
		cSql += " AND BFG_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFG.D_E_L_E_T_ = ' '  "

		//COBERTURA FAMILIA - EXCLUSIVOS DE PROCEDIMENTOS NA FAMILIA...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFD") + " BFD "
		cSql += " ON BFD_FILIAL = '" + xFilial("BFD") + "' "
		cSql += " AND BFD_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFD_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFD_MATRIC = '" + cMatric + "' "
		cSql += " AND BFD_CODPAD = BR8_CODPAD "
		cSql += " AND BFD_CODPSA = BR8_CODPSA "
		cSql += " AND BFD.D_E_L_E_T_ = ' '  "

		//OBTEM PROCEDIMENTOS PARAMETRIZADOS EXCLUSIVOS NO CONTRATO/SUBCONTRATO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BT8") + " BT8 "
		cSql += " ON BT8_FILIAL = '" + xFilial("BT8") + "' "
		cSql += " AND BT8_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BT8_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BT8_NUMCON = '" + cNumCon + "' "
		cSql += " AND BT8_VERCON = '" + cVerCon + "' "
		cSql += " AND BT8_SUBCON = '" + cSubCon + "' "
		cSql += " AND BT8_VERSUB = '" + cVerSub + "' "
		cSql += " AND BT8_CODPRO = '" + cCodPro + "' "
		cSql += " AND BT8_VERPRO = '" + cVerPro + "' "
		cSql += " AND BT8_CODPAD = BR8_CODPAD "
		cSql += " AND BT8_CODPSA = BR8_CODPSA "
		cSql += " AND BT8.D_E_L_E_T_ = ' '  "

		cSql += " LEFT OUTER JOIN " + RetSqlName("BA6") + " BA6 "
		cSql += " ON BA6_FILIAL = '" + xFilial("BA6") + "' "
		cSql += " AND BA6_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BA6_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BA6_NUMCON = '" + cNumCon + "' "
		cSql += " AND BA6_VERCON = '" + cVerCon + "' "
		cSql += " AND BA6_SUBCON = '" + cSubCon + "' "
		cSql += " AND BA6_VERSUB = '" + cVerSub + "' "
		cSql += " AND BA6_CODPRO = '" + cCodPro + "' "
		cSql += " AND BA6_VERPRO = '" + cVerPro + "' "
		cSql += " AND BA6_CLACAR = BR8_CLACAR "
		cSql += " AND BA6.D_E_L_E_T_ = ' '  "

		//OBTEM CARENCIAS POR PROCEDIMENTO NO PRODUTO DO BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BB2") + " BB2 "
		cSql += " ON BB2_FILIAL = '" + xFilial("BB2") + "' "
		cSql += " AND BB2_CODIGO = '" + cOpeUsr + cCodPro + "' " //OPERADORA E PRODUTO
		cSql += " AND BB2_VERSAO = '" + cVerPro + "' "
		cSql += " AND BB2_CODPAD = BR8_CODPAD "
		cSql += " AND BB2_CODPSA = BR8_CODPSA "
		cSql += " AND BB2_BENUTL = '1' " //SOMENTE OS ATIVOS
		cSql += " AND BB2.D_E_L_E_T_ = ' '  "

		//LEMBRETE CASO O PRODUTO SEJA CONSIDERA PADRAO = SIM, DEVE-SE PEGAR TAMBEM COMO COBERTURA/CARENCIA OS DADOS DA BR8
		cSql += " WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
		cSql += " AND (BR8_CLASIP <> ' ' OR BR8_CLASP2 <> ' ') "
		cSql += " AND BR8_BENUTL = '1' "

		//CASO SEJA PARAMETRIZADO SOMENTE COM PROCEDIMENTOS, HABILITAR O PARAMETRO ABAIXO (MAIOR DESEMPENHO).
		If GetNewPar("MV_PLFCSOP","0") == "1"
			cSql += " AND BR8_TPPROC = '"+TP_PROCEDIM+"' "
		EndIf

		//CAMPO CRIADO PARA CONFIGURAR SE CONSIDERA OU NAO NO CALCULO DE BENEF EXPOSTOS
		cSql += " AND BR8_FCAREN = '1' "
		cSql += " AND BR8.D_E_L_E_T_ = ' '  "
		//GROUP BY PARA REDUZIR CLASSIFICACOES REPETIDAS
		cSql += " GROUP BY BR8_CODPAD, BR8_CLASIP, BR8_CLASP2, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
    	cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
	    cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
	    cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "

	else

		//Consulta para obter os dados de cobertura/carencia, otimizado para o Exposto.
		cSql := " SELECT BR8_CODPAD, MAX(BR8_CODPSA) BR8_CODPSA, BR8_CLASIP, BR8_CLASP2, BG8_CODGRU, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,  BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " BFE_CODGRU, BFE_DATCAR, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " BFC_CODGRU, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " BT7_CARENC, BT7_UNCAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " BRV_CODGRU,BG8_CARENC, BG8_UNCAR, BG8_CLACAR, BG8_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "

		cSql += " FROM " + RetSqlName("BR8") + " BR8 "
		//LIGAR DIRETAMENTE NO PROCEDIMENTO PARA OBTER OS GRUPOS DE COBERTURA DE CADA UM...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BG8") + " BG8 "
		cSql += " ON BG8_FILIAL = '" + xFilial("BG8") + "' "
		cSql += " AND BG8_CODPAD = BR8_CODPAD "
		cSql += " AND BG8_CODPSA = BR8_CODPSA "
		cSql += " AND BG8.D_E_L_E_T_ = ' '  "


		//COBERTURA NO USUARIO - CLasse de carência no beneficiário
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFO") + " BFO "
		cSql += " ON BFO_FILIAL = '" + xFilial("BFO") + "' "
		cSql += " AND BFO_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFO_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFO_MATRIC = '"+cMatric+"' "
		cSql += " AND BFO_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFO_CLACAR = BR8_CLACAR "
		cSql += " AND BFO.D_E_L_E_T_ = ' '  "

		//COBERTURA NO USUARIO - PROCEDIMENTOS EXCLUSIVOS PARA O BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFG") + " BFG "
		cSql += " ON BFG_FILIAL = '" + xFilial("BFG") + "' "
		cSql += " AND BFG_CODPAD = BR8_CODPAD "
		cSql += " AND BFG_CODPSA = BR8_CODPSA "
		cSql += " AND BFG_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFG_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFG_MATRIC = '"+cMatric+"' "
		cSql += " AND BFG_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFG.D_E_L_E_T_ = ' '  "

		//GRUPO DE COBERTURA NO USUARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFE") + " BFE "
		cSql += " ON BFE_FILIAL = '" + xFilial("BFE") + "' "
		cSql += " AND BFE_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFE_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFE_MATRIC = '" + cMatric + "' "
		cSql += " AND BFE_TIPREG = '" + cTipReg + "' "
		cSql += " AND BFE_CODGRU = BG8_CODGRU "
		cSql += " AND BFE.D_E_L_E_T_ = ' '  "

		//COBERTURA FAMILIA - EXCLUSIVOS DE PROCEDIMENTOS NA FAMILIA...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFD") + " BFD "
		cSql += " ON BFD_FILIAL = '" + xFilial("BFD") + "' "
		cSql += " AND BFD_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFD_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFD_MATRIC = '" + cMatric + "' "
		cSql += " AND BFD_CODPAD = BR8_CODPAD "
		cSql += " AND BFD_CODPSA = BR8_CODPSA "
		cSql += " AND BFD.D_E_L_E_T_ = ' '  "

		//GRUPOS DE COBERTURA CONTIDOS NA FAMILIA...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFC") + " BFC "
		cSql += " ON BFC_FILIAL = '" + xFilial("BFC") + "' "
		cSql += " AND BFC_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFC_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFC_MATRIC = '" + cMatric + "' "
		cSql += " AND BFC_CODGRU = BG8_CODGRU "
		cSql += " AND BFC.D_E_L_E_T_ = ' '  "

		//OBTEM PROCEDIMENTOS PARAMETRIZADOS EXCLUSIVOS NO CONTRATO/SUBCONTRATO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BT8") + " BT8 "
		cSql += " ON BT8_FILIAL = '" + xFilial("BT8") + "' "
		cSql += " AND BT8_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BT8_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BT8_NUMCON = '" + cNumCon + "' "
		cSql += " AND BT8_VERCON = '" + cVerCon + "' "
		cSql += " AND BT8_SUBCON = '" + cSubCon + "' "
		cSql += " AND BT8_VERSUB = '" + cVerSub + "' "
		cSql += " AND BT8_CODPRO = '" + cCodPro + "' "
		cSql += " AND BT8_VERPRO = '" + cVerPro + "' "
		cSql += " AND BT8_CODPAD = BR8_CODPAD "
		cSql += " AND BT8_CODPSA = BR8_CODPSA "
		cSql += " AND BT8.D_E_L_E_T_ = ' '  "

		cSql += " LEFT OUTER JOIN " + RetSqlName("BA6") + " BA6 "
		cSql += " ON BA6_FILIAL = '" + xFilial("BA6") + "' "
		cSql += " AND BA6_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BA6_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BA6_NUMCON = '" + cNumCon + "' "
		cSql += " AND BA6_VERCON = '" + cVerCon + "' "
		cSql += " AND BA6_SUBCON = '" + cSubCon + "' "
		cSql += " AND BA6_VERSUB = '" + cVerSub + "' "
		cSql += " AND BA6_CODPRO = '" + cCodPro + "' "
		cSql += " AND BA6_VERPRO = '" + cVerPro + "' "
		cSql += " AND BA6_CLACAR = BR8_CLACAR "
		cSql += " AND BA6.D_E_L_E_T_ = ' '  "

		//OBTEM GRUPOS DE COBERTURA EXCLUSIVOS DO CONTRATO/SUBCONTRATO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BT7") + " BT7 "
		cSql += " ON BT7_FILIAL = '" + xFilial("BT7") + "' "
		cSql += " AND BT7_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BT7_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BT7_NUMCON = '" + cNumCon + "' "
		cSql += " AND BT7_VERCON = '" + cVerCon + "' "
		cSql += " AND BT7_SUBCON = '" + cSubCon + "' "
		cSql += " AND BT7_VERSUB = '" + cVerSub + "' "
		cSql += " AND BT7_CODPRO = '" + cCodPro + "' "
		cSql += " AND BT7_VERPRO = '" + cVerPro + "' "
		cSql += " AND BT7_CODGRU = BG8_CODGRU "
		cSql += " AND BT7.D_E_L_E_T_ = ' '  "

		//OBTEM CARENCIAS POR PROCEDIMENTO NO PRODUTO DO BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BB2") + " BB2 "
		cSql += " ON BB2_FILIAL = '" + xFilial("BB2") + "' "
		cSql += " AND BB2_CODIGO = '" + cOpeUsr + cCodPro + "' " //OPERADORA E PRODUTO
		cSql += " AND BB2_VERSAO = '" + cVerPro + "' "
		cSql += " AND BB2_CODPAD = BR8_CODPAD "
		cSql += " AND BB2_CODPSA = BR8_CODPSA "
		cSql += " AND BB2_BENUTL = '1' " //SOMENTE OS ATIVOS
		cSql += " AND BB2.D_E_L_E_T_ = ' '  "

		//GRUPOS DE COBERTURA DO PRODUTO DO BENEFICIARIO...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BRV") + " BRV "
		cSql += " ON BRV_FILIAL = '" + xFilial("BRV") + "' "
		cSql += " AND BRV_CODPLA = '" + cOpeUsr + cCodPro + "' " //OPERADORA + PRODUTO
		cSql += " AND BRV_VERSAO = '" + cVerPro + "' "
		cSql += " AND BRV_CODGRU = BG8_CODGRU "
		cSql += " AND BRV.D_E_L_E_T_ = ' '  "

		//LEMBRETE CASO O PRODUTO SEJA CONSIDERA PADRAO = SIM, DEVE-SE PEGAR TAMBEM COMO COBERTURA/CARENCIA OS DADOS DA BR8
		cSql += " WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
		cSql += " AND (BR8_CLASIP <> ' ' OR BR8_CLASP2 <> ' ') "
		cSql += " AND BR8_BENUTL = '1' "

		//CASO SEJA PARAMETRIZADO SOMENTE COM PROCEDIMENTOS, HABILITAR O PARAMETRO ABAIXO (MAIOR DESEMPENHO).
		If GetNewPar("MV_PLFCSOP","0") == "1"
			cSql += " AND BR8_TPPROC = '"+TP_PROCEDIM+"' "
		EndIf

		//CAMPO CRIADO PARA CONFIGURAR SE CONSIDERA OU NAO NO CALCULO DE BENEF EXPOSTOS
		cSql += " AND BR8_FCAREN = '1' "
		cSql += " AND BR8.D_E_L_E_T_ = ' '  "
		//GROUP BY PARA REDUZIR CLASSIFICACOES REPETIDAS
		cSql += " GROUP BY BR8_CODPAD, BR8_CLASIP, BR8_CLASP2, BG8_CODGRU, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " BFE_CODGRU, BFE_DATCAR, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " BFC_CODGRU, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " BT7_CARENC, BT7_UNCAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " BRV_CODGRU,BG8_CARENC, BG8_UNCAR, BG8_CLACAR, BG8_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "
	Endif

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCAR",.F.,.T.)

	//PlsLogFil("query CarregaCarencia"+ CENDTHRL("I") + cSql,DEBUG_EXP)

	If TRBCAR->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PLSNioInCo

	Funcao criada para alimentar a tabela de carencia x beneficiario B3O

	@param cRegANS		Numero de registro da operadora na ANS
	@param cMatric		Matricula do beneficiario na operadora
	@param cItem		Codigo do item assistencial
	@param nDiasCob	Quantidade de dias coberto
	@param cCodObri	Chave da obrigacao
	@param cCodComp	Chave do compromisso
	@param cAno			Ano do compromisso
	@param nOpe			Codigo da operacao 3-Inclui ou 4-Altera

	@return lRetorno	Indica se .T. inclui ou nao .F. carencia para o beneficiario

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PLSNioInCo(cRegANS,cMatric,cItem,nDiasCob,cCodObri,cCodComp,cAno,nOpe)
	Local lRetorno		:= .T.
	Default cRegANS		:= ""
	Default cMatric		:= ""
	Default cItem		:= ""
	Default cCodObri	:= ""
	Default cCodComp	:= ""
	Default cAno		:= ""
	Default nDiasCob	:= 0
	Default nOpe		:= MODEL_OPERATION_INSERT

	RecLock("B3O",.T.)
	B3O->B3O_FILIAL := xFilial('B3O')
	B3O->B3O_CODOPE := cRegANS
	B3O->B3O_MATRIC := cMatric
	B3O->B3O_ITEM := cItem
	B3O->B3O_DIACOB := nDiasCob
	B3O->B3O_CDOBRI := cCodObri
	B3O->B3O_CDCOMP := cCodComp
	B3O->B3O_ANO := cAno
	B3O->(msUnLock())

Return lRetorno

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} SomaExpTot

	Funcao criada para somar o total de dias dos beneficiarios expostos

	@param aExpTot		Matriz com [1] classificacao, [2] dias coberto, [3] tipo de plano, [4] segmentacao, [5] matricula
	@param cClaSip		Classificacao do SIP
	@param nDiasCob	Quantidade de dias coberto
	@param cTpPlan		Tipo de plano / forma de contratacao
	@param cCodSeg		Segmentacao do plano
	@param cMatric		Matricula do beneficiario

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function SomaExpTot(aExpTot,cClaSip,nDiasCob,cTpPlan,cCodSeg,cMatric)
	Local nPos := 0

	nPos := aScan(aExpTot,{|x| x[1]+x[3]+x[4]+x[5] == cClaSip+cTpPlan+cCodSeg+cMatric})

	If nPos > 0
		aExpTot[nPos,2] += nDiasCob
	Else
		aAdd(aExpTot,{cClaSip,nDiasCob,cTpPlan,cCodSeg,cMatric})
	EndIf

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PlsAtuMonitor

	Funcao criada para atualizar mensagem de observacao no servidor

	@param nQtdeReg		Quantidade de registros processados
	@param cMsg			Mensagem informativa

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PlsAtuMonitor(cMsg)
	Default cMsg		:= ""

	PtInternal(1,AllTrim(cMsg))

Return Nil
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ListaBenef

	Funcao criada para criar os ranges de beneficiarios a serem processados em cada job de expostos

	@param cDataRef		Data de inicio do periodo a ser apurado

	@return aBenef		Matriz com os 6 (seis) ranges de beneficiarios

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ListaBenef(cDataRef)
	Local aBenef 	:= {}
	Local cSql		:= ""
	Local cWhere	:= ""//" AND BA1_CODINT = '0001' AND BA1_CODEMP = '0001' AND BA1_MATRIC = '009681' AND BA1_TIPREG = '00' AND BA1_DIGITO = '3' "
	Local nProcAux	:= 0
	Local nJ		:= 0
    Local cDb       := Alltrim(Upper(TCGetDb()))

	cSql := "SELECT "
	cSql += " COUNT(1) QTDE "
	cSql += " FROM "
	cSql += " " + RetSqlName("BA1") + " BA1 "
	cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
	cSql += "     BT5_FILIAL = BA1_FILIAL "
	cSql += "     AND BT5_CODINT = BA1_CODINT "
	cSql += "     AND BT5_CODIGO = BA1_CODEMP "
	cSql += "     AND BT5_NUMCON = BA1_CONEMP "
	cSql += "     AND BT5_VERSAO = BA1_VERCON "
	cSql += "     AND BT5_INFANS = '1' "
	cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
	cSql += "     BQC_FILIAL = BT5_FILIAL "
	if cDb $ "ORACLE/POSTGRES"
		cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
	Else
		cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
	Endif
	cSql += "     AND BQC_NUMCON = BT5_NUMCON "
	cSql += "     AND BQC_VERCON = BT5_VERSAO "
	cSql += "     AND BQC_SUBCON = BA1_SUBCON "
	cSql += "     AND BQC_VERSUB = BA1_VERSUB "
	cSql += "     AND BQC_INFANS = '1' "
	cSql += "     AND BQC.D_E_L_E_T_ = ' ' "
	cWhere += " WHERE "
	cWhere += " BA1_FILIAL = '" + xFilial("BA1") + "' "
	cWhere += " AND BA1_INFANS = '1' "
	cWhere += " AND (BA1_DATBLO = '"+ Space(8) +"' OR BA1_DATBLO >= '" + DataTrimestre(cDataRef) + "') "
	cWhere += " AND BA1.D_E_L_E_T_ = ' '  "
	cSql += cWhere

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TEMP",.F.,.T.)

	If !TEMP->(Eof())
		nQtd := TEMP->QTDE
		TEMP->(dbCloseArea())

		cSql := " SELECT BA1.R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif
		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ' "
		cSql += cWhere
		cSql += " ORDER BY BA1.R_E_C_N_O_ "
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TEMP",.F.,.T.)

		If !TEMP->(Eof())

			nQtdRng := nQtd / 6
			If nQtdRng > int(nQtdRng)
				nQtdRng := Int(nQtdRng) + 1
			EndIf

			nProc := 1
			nVolta := 1
			While !TEMP->(Eof()) .AND. nVolta <= 6

				aAdd(aBenef,{})

				//Guardo o primeiro Recno do range
				TEMP->(DbGoto(nProc))
				aAdd(aBenef[nVolta],TEMP->RECNO)
				//Guardo o ultimo rencno do range

				nProcAux := nProc //Somo a qtd de itens que haverá no range
				nProc += nQtdRng - 1 //Somo a qtd de itens que haverá no range
				//Por ser uma query, não consigo dar um DbGoto, então vou avançando até o registro que eu quero
				For nJ := nProcAux to nProc
					If TEMP->(Eof())
						Exit
					Else
						nRecnoAux := TEMP->RECNO
						TEMP->(dbSkip())
					EndIf

				Next nJ

				aAdd(aBenef[nVolta],nRecnoAux)

				nProc++
				nVolta++

			EndDo

		EndIf
	EndIf

	TEMP->(dbCloseArea())

Return aBenef
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PegaCIDInt

	Funcao criada para retornar o CID informado na guia de internacao

	@param cChvGuia		Chave da guia //(cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SITUAC+BD7_FASE)

	@return cCID		Codigo do CID encontrado

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PegaCIDInt(cChvGuia)
	Local cCID			:= ""
	Default cChvGuia	:= ""
	If !Empty(cChvGuia)
		cCID := RetornaCID(cChvGuia)
	EndIf
Return AllTrim(cCID)

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} BuscaDente

	Funcao criada para retorna em qual dente foi realizado o evento do grupo I

	@param cChaveGuia	(cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

	@return cDente		Identificacao do dente

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function BuscaDente(cChaveGuia)
	Local cSql				:= ""
	Local cDente			:= ""
	Default cChaveGuia	:= ""

	cSql := "SELECT BE2_DENREG FROM " + RetSqlName("BE2") + " BE2, " + RetSqlName("BEA") + " BEA "
	cSql += "WHERE BE2_FILIAL = '" + xFilial("BE2") + "' AND BE2_FILIAL = '" + xFilial("BE2") + "' AND BE2_OPEMOV = BEA_OPEMOV AND BE2_ANOAUT = BEA_ANOAUT AND BE2_MESAUT = BEA_MESAUT AND BE2_NUMAUT = BEA_NUMAUT "
	cSql += "AND BEA_OPEMOV = '" + SubStr(cChaveGuia,1,4) + "' AND BEA_CODLDP = '" + SubStr(cChaveGuia,5,4) + "' AND BEA_CODPEG = '" + SubStr(cChaveGuia,9,8) + "' AND BEA_NUMGUI = '" + SubStr(cChaveGuia,17,8) + "' "
	cSql += "AND BEA_ORIMOV = '" + SubStr(cChaveGuia,25,1) + "' AND BE2.D_E_L_E_T_ = ' '  AND BEA.D_E_L_E_T_ = ' '  "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"DENT",.F.,.T.)

	If !DENT->(Eof())
		cDente := DENT->BE2_DENREG
	EndIf

	DENT->(dbCloseArea())

Return cDente
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} AtuPrinc

	Funcao criada para atualizar o evento principal da guia com os valores de eventos sem classificacao

	@param aProSemCla	Matriz com informacoes dos procedimentos nao classificados

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function AtuPrinc(aProSemCla,nQtdRegPro,cCabLog,lCapit)
	Local cSql			:= ""
	Local aGuia			:= {}
	Local nFor			:= 0
	Local nVlrEve		:= 0
	Default aProSemCla	:= {}
	Default nQtdRegPro	:= 0
	Default cCabLog	    := " "
	Default lCapit      := .F.

	//B3L_FILIAL+B3L_CODOPE+B3L_CODOBR+B3L_ANOCMP+[B3L_CDCOMP]+B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)
	//Vou filtrar a guia para montrar a matriz aGuia
	cSql := " SELECT R_E_C_N_O_ RECNO, B3Q_CLAAMB, B3Q_CLAINT, B3Q_GRPINT, B3Q_REGINT "
	cSql += " FROM " + RetSqlName("B3Q") + " "
	If BANCO == "MSSQL7"
		cSql += " WITH (NOLOCK) "
	EndIf
	cSql += " WHERE B3Q_FILIAL = '" + xFilial("B3Q") + "' "
	cSql += " 	AND B3Q_CODOPE = '" + aProSemCla[1,1] + "' "
	cSql += " 	AND B3Q_CODOBR = '" + aProSemCla[1,2] + "' "
	cSql += " 	AND B3Q_ANOCMP = '" + aProSemCla[1,3] + "' "
	cSql += " 	AND B3Q_CDCOMP = '" + aProSemCla[1,4] + "' "
	cSql += " 	AND B3Q_EVEDES = '" + aProSemCla[1,5] + "' "
	cSql += " 	AND B3Q_MATRIC = '" + aProSemCla[1,6] + "' "
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	cSql := InsereNoLock(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TPRI",.F.,.T.)

	If !TPRI->(Eof())

		While !TPRI->(Eof())

			If Empty(TPRI->B3Q_GRPINT) .And. Empty(TPRI->B3Q_REGINT) //Nao tem como ser internacao
				aAdd(aGuia,{Iif(!Empty(TPRI->B3Q_CLAAMB),TPRI->B3Q_CLAAMB,TPRI->B3Q_CLAINT),TPRI->RECNO})
			Else
				aAdd(aGuia,{Iif(!Empty(TPRI->B3Q_CLAINT),TPRI->B3Q_CLAINT,TPRI->B3Q_CLAAMB),TPRI->RECNO})
			EndIf

			TPRI->(dbSkip())

		EndDo

		//Ordeno pelas classificacoes encontradas na guia
		aSort(aGuia,,,{ |x,y| x[1] > y[1]})

		For nFor := 1 TO Len(aProSemCla)

			nVlrEve += aProSemCla[nFor,7]//somo todos os valores dos itens sem classificacao

		Next nFor

		B3Q->(dbGoTo(aGuia[1,2]))//Posiciono no primeiro/principal item da guia
		B3Q->(RecLock("B3Q",.F.))
		B3Q->B3Q_VLREVE	+= nVlrEve//acrescento o valor somado ao item principal
		B3Q->B3Q_STATUS := '1'
		B3Q->(msUnLock())
		MarcaBD7(B3Q->B3Q_EVEDES,B3Q->B3Q_TRIREC,lCapit)

	Else

		For nFor := 1 TO Len(aProSemCla)

			If TmpIncDesp(aProSemCla[1,1],aProSemCla[1,2],aProSemCla[1,3],aProSemCla[1,4],aProSemCla[nFor,8],,,lCapit)
				nQtdRegPro++
			Else
				PlsLogFil(cCabLog + CENDTHRL("W") + " Despesa não integrada [" + aProSemCla[1,5] + "]",ARQ_LOG_DES)
			EndIf

		Next nFor

	EndIf

	LimpaArray(aProSemCla)
	TPRI->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PlCenCarCob

	Funcao que encapsula o carregamento de coberturas

	@description
	Sera utilizado aqui e nas funcoese do PLS que alteram o cadastro de beneficiarios

	@param cAlias		Area de trabalho corrente
	@param cMatUsu		Matricula do beneficiario na operadora
	@param cContrato	Chave completa do contrato para beneficiarios nao PF
	@param cProduto		Chave completa do produto
	@param cDatCarBen	Data de carencia encontrada para o beneficiario
	@param nIncluidos	Quantidade de registros incluidos
	@param lAtenOdon	Indicase se o produto atende .T. oun nao .F. odonto
	@param aNatSaude	Matriz de natureza de saude carregadas da tabela BF0
	@param lPodeBR8		Indica se o produto permite considerar cobertura na tabela padrao
	@param cCodIntBen	Codigo da operadora do beneficiario - BA1_CODINT
	@param cDataRef		Data de referencia do processamento do trimestre
	@param cRegANS		Numero de registro da operadora na ANS
	@param cCodObri		Codigo da obrigacao encontrada
	@param cAnoComp		Ano da competencia
	@param cCodComp		Codigo da competencia
	@param lImport		Indica se e .T. ou nao .F. importacao de uma carga inicial
	@param cSexo		Sexo do beneficiario
	@param dDatNas		Data de nascimento do beneficiario
	@param cCodSeg		Codigo da segmentacao do produto
	@param cForCon		Forma de contratacao do produto
	@param dDataBlo		Data de bloqueio do beneficiario

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PlCenCarCob(cAlias,cMatUsu,cContrato,cProduto,cDatCarBen,nIncluidos,lAtenOdon,aNatSaude,lPodeBR8,cCodIntBen,;
		cDataRef,cRegANS,cCodObri,cAnoComp,cCodComp,lImport,cSexo,dDatNas,cCodSeg,cForCon,dDataBlo)

	Local cClaSIP		:= ""
	Local cDatCar		:= ""
	Local cUnCar		:= ""
	Local cClaCar 		:= ""
	Local nCarenc		:= 0
	Local nPosCar		:= 0
	Local nFor			:= 0
	Local lTemCob		:= .F.
	Local lIdade		:= .F.
	Local lSexo			:= .F.
	Local dDtIniTri		:= STOD(DataTrimestre(cDataRef,"1"))
	Local dDtFinTri		:= STOD(DataTrimestre(cDataRef,"2"))
	Local aSomaTotal	:= {}
	Local aDadCob		:= {}
	Local aNatSauBkp	:= {}
	Local lMV_PLCENDB	:= MV_PLCENDB
	Local aNatSaIte		:= {}
	Local nPosIte		:= 0
	Local lAchou        := .F.

	Default lAtenOdon	:= .F.
	Default lPodeBR8	:= .F.
	Default aNatSaude	:= {}
	Default cRegANS		:= '000000'
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default lImport		:= .T.
	Default dDataBlo	:= StoD("")

	cDatCar	:= cDatCarBen
	nIdade	:= Calc_Idade(dDataBase,dDatNas)

	If Len(aNatSaude) == 0
		aNatSaude := PegaNatSaude()//carrego as naturezas de saude no formato {Codigo,0, / / ,Idade Ini,Idade Fin,Sexo,Nivel}
	EndIf
	aNatSauBkp := aClone(aNatSaude)
	//Vou criar a area de trabalho TRBCAR com as carencias do beneficiario se houver
	If CarregaCarencia(cAlias,cMatUsu,cContrato,cProduto)

		While !TRBCAR->(Eof())

			cClaSIP		:= Iif(TRBCAR->BR8_REGATD <> '2', TRBCAR->BR8_CLASIP, TRBCAR->BR8_CLASP2)
			nPosCar		:= aScan(aNatSaude,{|x| x[1] == cClaSIP})
			//PlsLogFil("Procurando cobertura para o procedimento " + TRBCAR->(BR8_CODPAD+BR8_CODPSA) + CENDTHRL("I"),DEBUG_EXP)
			If (Left(cClaSIP,1) == "I" .And. !lAtenOdon) .Or. nPosCar <= 0//Devo despresar itens I que o produto nao atende odonto ou se nao encontrou a classificacao no aNatSaude
				TRBCAR->(dbSkip())
				Loop
			EndIf

			//Caso a classificacao seja subgrupo, deve-se verificar se o item sera mais adequado por tratar-se de idade e sexo...
			If nPosCar > 0
				If aNatSaude[nPosCar,NAT_NIVEL] == '2'//Nivel - 1=Grupo;2=Subgrupo;3=Item

					aNatSaIte	:= NatSaudeItem(aNatSaude,cClaSIP)
					nPosIte		:= aScan(aNatSaIte,{|x| x[1] == cClaSIP})

					If nPosIte > 0

						lIdade	:= (aNatSaude[nPosIte,NAT_IDADE]+aNatSaude[nPosIte,NAT_IDADE2] == 0) .Or. (nIdade >= aNatSaude[nPosIte,NAT_IDADE] .And. nIdade <= aNatSaude[nPosIte,NAT_IDADE2])
						lSexo	:= Empty(cSexo) .Or. (cSexo == aNatSaIte[nPosIte,6])

						If lIdade .And. lSexo//Atualizao cClaSIP e nPosCar se achei um item que trata sexo e idade
							cClaSIP	:= aNatSaIte[nPosIte,NAT_CODIGO]
							aNatSaude[nPosCar,NAT_DATCAR] := STOD("19990101")
							nPosCar	:= nPosIte
						EndIf

					Else

						lIdade	:= (aNatSaude[nPosCar,NAT_IDADE]+aNatSaude[nPosCar,NAT_IDADE2] == 0) .Or. (nIdade >= aNatSaude[nPosCar,NAT_IDADE] .And. nIdade <= aNatSaude[nPosCar,NAT_IDADE2])
						lSexo	:= Empty(aNatSaude[nPosCar,NAT_SEXO]) .Or. (cSexo == aNatSaude[nPosCar,NAT_SEXO])

						If !lIdade .Or. !lSexo
							aNatSaude[nPosCar,NAT_DATCAR] := STOD("")
							//PlsLogFil("Nao tem cobertura para o item. Regra de idade e sexo " + cClaSIP + CENDTHRL("I"),DEBUG_EXP)
							nPosCar := 0
						EndIf

					EndIf

				Else

					lIdade	:= (aNatSaude[nPosCar,NAT_IDADE]+aNatSaude[nPosCar,NAT_IDADE2] == 0) .Or. (nIdade >= aNatSaude[nPosCar,NAT_IDADE] .And. nIdade <= aNatSaude[nPosCar,NAT_IDADE2])
					lSexo	:= Empty(aNatSaude[nPosCar,NAT_SEXO]) .Or. (cSexo == aNatSaude[nPosCar,NAT_SEXO])

					If !lIdade .Or. !lSexo
						aNatSaude[nPosCar,NAT_DATCAR] := STOD("")
						//PlsLogFil("Nao tem cobertura para o item. Regra de idade e sexo 2" + cClaSIP + CENDTHRL("I"),DEBUG_EXP)
						nPosCar := 0
					EndIf

				EndIf
			Else
				//PlsLogFil("Nao tem cobertura para o item " + cClaSIP + CENDTHRL("I"),DEBUG_EXP)
			EndIf

			If nPosCar == 0
				lTemCob		:= .F.
				cDatCar	:= cDatCarBen
				nCarenc		:= 0
				cUnCar		:= ""
				cClaCar		:= ""
			Else

				nCarenc := 0
				cUnCar  := ""
				cClaCar := ""
				lAchou  := .F.
				lTemCob	:= .F.

				If !Empty(TRBCAR->BFO_UNICAR) .And. !Empty(TRBCAR->BFO_CLACAR) .And. !Empty(TRBCAR->BFO_DATCAR)
					nCarenc := TRBCAR->BFO_CARENC
					cUnCar  := TRBCAR->BFO_UNICAR
					cClaCar := TRBCAR->BFO_CLACAR
					lAchou  := .T.
					lTemCob	:= .T.
				EndIf

				Do Case
				//Se encontrar parametrizacao para o procedimento, tem cobertura e ve a carencia...
				Case TRBCAR->BFD_BENUTL == "1" .And. !lTemCob
					If !Empty(TRBCAR->BFD_UNCAR) .Or. !Empty(TRBCAR->BFD_CLACAR)
						nCarenc := TRBCAR->BFD_CARENC
						cUnCar  := TRBCAR->BFD_UNCAR
						cClaCar := TRBCAR->BFD_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BFD",DEBUG_EXP)
					Else
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBFD",DEBUG_EXP)
					EndIf
					lTemCob	:= .T.
					//Se encontrar o grupo de cobertura na familia, tem cobertura.
				Case !Empty(TRBCAR->BFC_CODGRU) .And. !lTemCob
					lTemCob := .T.
					//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BFC",DEBUG_EXP)
					//Se encontrar o procedimentos no contrato/sub, tem cobertura...
				Case TRBCAR->BT8_BENUTL == "1" .And. !lTemCob
					If !Empty(TRBCAR->BT8_UNCAR) .Or. !Empty(TRBCAR->BT8_CLACAR)
						nCarenc := TRBCAR->BT8_CARENC
						cUnCar  := TRBCAR->BT8_UNCAR
						cClaCar := TRBCAR->BT8_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BT8",DEBUG_EXP)
					Else
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBT8",DEBUG_EXP)
					EndIf
					lTemCob	:= .T.
					//Se encontrar o grupo de cobertura no contrato/sub, tem cobertura...

				Case !lTemCob .And. (!Empty(TRBCAR->BA6_UNICAR) .Or. !Empty(TRBCAR->BA6_CLACAR))
					nCarenc := TRBCAR->BA6_CARENC
					cUnCar  := TRBCAR->BA6_UNICAR
					cClaCar := TRBCAR->BA6_CLACAR

					lTemCob	:= .T.
					lAchou  := .T.

				Case !Empty(TRBCAR->BT7_UNCAR) .And. !lTemCob
					nCarenc := TRBCAR->BT7_CARENC
					cUnCar  := TRBCAR->BT7_UNCAR
					lTemCob	:= .T.
					lAchou  := .T.

					//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BT7",DEBUG_EXP)
					//Se encontrar parametrizacao diretamente no produto do usuario, tem cobertura e ve a carencia...
				Case TRBCAR->BB2_BENUTL == "1" .And. !lTemCob

					If !Empty(TRBCAR->BB2_UNCAR) .Or. !Empty(TRBCAR->BB2_CLACAR)
						nCarenc := TRBCAR->BB2_CARENC
						cUnCar  := TRBCAR->BB2_UNCAR
						cClaCar := TRBCAR->BB2_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BB2",DEBUG_EXP)
					Else
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBB2",DEBUG_EXP)
					EndIf
					lTemCob	:= .T.

					//Se encontrar o grupo de cobertura no produto, tem cobertura.
				Case TRBCAR->BG8_BENUTL == "1" .And. !lTemCob
					If !Empty(TRBCAR->BG8_UNCAR) .Or. !Empty(TRBCAR->BG8_CLACAR)//TODO aqui talvez seja And pois esta vindo UNCAR vazio
						nCarenc := TRBCAR->BG8_CARENC
						cUnCar  := TRBCAR->BG8_UNCAR
						cClaCar := TRBCAR->BG8_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BG8",DEBUG_EXP)
					Else
						//If !Empty(TRBCAR->BRV_CODGRU)
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBG8",DEBUG_EXP)
						//Else
						//nCarenc := 0
						//cUnCar  := "2"
						//cClaCar := ""
						//EndIf
					EndIf
					lTemCob	:= .T.

					//Se encontrar o grupo de cobertura no produto, tem cobertura.
				Case (!Empty(TRBCAR->BR8_UNCAR) .Or. !Empty(TRBCAR->BR8_CLACAR)) .And. lPodeBR8  .And. !lTemCob
					nCarenc := TRBCAR->BR8_CARENC
					cUnCar  := TRBCAR->BR8_UNCAR
					cClaCar := TRBCAR->BR8_CLACAR
					//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BR8",DEBUG_EXP)
					lTemCob	:= .T.

				EndCase

				//Caso tenha cobertura, calcular os dias em carencia...
				If lTemCob
					//PlsLogFil("Tem cobertura, vai calcular os dias " + CENDTHRL("I"),DEBUG_EXP)
					//Se encontrar o grupo de cobertura no usuario, tem cobertura.
					If !Empty(TRBCAR->BFE_CODGRU) .And. !Empty(TRBCAR->BFE_DATCAR) .And. !lAchou
						cDatCar := TRBCAR->BFE_DATCAR
					Endif
					If !lAchou .And. (Empty(cUnCar) .Or. (! Empty(cClaCar) .And. lPodeBR8))
						//classe de carencia dentro do protudo
						nFor := aScan(aBAN,{|x| x[1] == cProduto+cClaCar})
						If nFor > 0
							nCarenc := aBAN[nFor,2]
							cUnCar := aBAN[nFor,3]
						Else//classe de carencia
							nFor := aScan(aBDL,{|x| x[1] == cCodIntBen+cClaCar})
							If nFor > 0
								nCarenc := aBDL[nFor,2]
								cUnCar := aBDL[nFor,3]
							Else
								nCarenc := 0
								cUnCar := "2"
							EndIf
						EndIf
					EndIf

					If cUnCar $ "2,3,4" // Dias,Meses,Anos
						nDiasAux := PLSCarDias(nCarenc,cUnCar) // Calcula em dias
					Else
						nDiasAux := 1
					EndIf

					If Empty(aNatSaude[nPosCar,NAT_DATCAR])
						aNatSaude[nPosCar,NAT_DIAS] := nDiasAux
						aNatSaude[nPosCar,NAT_DATCAR] := STOD(cDatCar)
					Else
						If STOD(cDatCar)+nDiasAux > aNatSaude[nPosCar,NAT_DATCAR]+aNatSaude[nPosCar,NAT_DIAS]
							aNatSaude[nPosCar,NAT_DIAS] := nDiasAux
							aNatSaude[nPosCar,NAT_DATCAR] := STOD(cDatCar)
						EndIf
					EndIf

				Else
					If lMV_PLCENDB
						PlsLogFil(cClaSIP + ";" + cMatUsu,DEBUG_EXP)
					EndIf
				EndIf//If lTemCob

			EndIf

			TRBCAR->(dbSkip())

		EndDo//!TRBCAR->(Eof())

		For nFor := 1 To Len(aNatSaude)

			nDiasCob	:= 0//Quantidade de dias que usuario esta coberto
			if dDataBlo >= dDtIniTri .AND. dDataBlo < dDtFinTri
				dDtFinTri := dDataBlo
			Else
				dDtFinTri := dDtFinTri
			EndIf
			nDiasPer	:= dDtFinTri - dDtIniTri + 1 //Quantidade de dias do periodo / trimestre
			If !Empty(aNatSaude[nFor,NAT_DATCAR]) //Data de carencia
				If aNatSaude[nFor,NAT_DATCAR] <= STOD(cDataRef) //A data e inferior a data de referencia
					nDiasCob := dDtFinTri-(aNatSaude[nFor,NAT_DATCAR]+aNatSaude[nFor,NAT_DIAS])//Data final do trimestre - data de carencia mais quantidade de dias
				Else
					nDiasCob := nDiasPer//Como a data de carencia e posterior a data de referencia o beneficiario esta coberto durante todo o periodo
				EndIf
				If nDiasCob > nDiasPer
					nDiasCob := (dDtFinTri-dDtIniTri) + 1
				EndIf
				nDiasCob := Iif(nDiasCob > 0,nDiasCob, 0)
				SomaExpTot(@aSomaTotal,aNatSaude[nFor,NAT_CODIGO],nDiasCob,cForCon,cCodSeg,cMatUsu)
			EndIf

		Next nFor
	Else
		//PlsLogFil("Nao encontrou config de cobertura " + CENDTHRL("I"),DEBUG_EXP)
	EndIf//If CarregaCarencia()

	TRBCAR->(dbCloseArea())

	For nFor := 1 To Len(aSomaTotal)

		cItem	:= aSomaTotal[nFor,1]
		nQtdBen	:= aSomaTotal[nFor,2]
		cForCon	:= aSomaTotal[nFor,3]
		cCodSeg	:= aSomaTotal[nFor,4]
		cMatric	:= aSomaTotal[nFor,5]

		If lImport
			If !ExisteDespesa(cRegANS,cCodObri,cAnoComp,cCodComp,"",cMatric,"TRBEXP",cItem,{})
				If PLSNioInCo(cRegANS,cMatric,cItem,nQtdBen,cCodObri,cCodComp,SubStr(cTriRec,1,4),MODEL_OPERATION_INSERT)
					nIncluidos++
				Else
					PlsLogFil("PLSIPEXP" + CENDTHRL("W") + " nao foi possivel incluir carencia para: " + cMatric,ARQ_LOG_DES)
				EndIf
			EndIf
		Else
			aAdd(aDadCob,{cRegANS,cMatric,cItem,nQtdBen})
		EndIf

	Next nFor

	LimpaArray(@aSomaTotal)
	aNatSaude := aClone(aNatSauBkp)

Return aDadCob
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} TrataPacote

	Funcao criada para abrir os pacotes e chamar as funcoes de classificacao

	@param cAliPct		Alias de trabalho corrente
	@param cRegANS		Numero de registro da operadora na ANS
	@param cChaveGuia	Chave da guia
	@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento
	@param nQtdRegPro	Quantidade de registros processados a ser atualizado
	@param cCodObri	Chave da obrigacao
	@param cAnoComp	Ano do compromisso
	@param cCodComp 	Chave do compromisso

	@return VarRetorno Descriacao do retorno

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function TrataPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv,lMV_STATISS)
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local nQtdPacote	:= 0
	Local cDataProc		:= Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
	Local nIdade 		:= Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))
	Local cAliPct		:= "TRBPCT"
	Local cChaveGuia	:= ""
	Local lIncDesp		:= .F.
	Default cAlias		:= "TRBDES"
	Default cDataRef	:= ""
	Default cTipData	:= "1"
	Default cRegANS		:= ""
	Default nThread		:= 0
	Default aBenef		:= {}
	Default nQuinzena	:= {}
	Default lCount		:= .F.
	Default cLocDigIgn	:= ""
	Default lQryInter	:= .F.
	Default	cChvGuiGrv	:= ""
	Default	lMV_STATISS	:= MV_STATISS

	If !Empty(cChvGuiGrv)
		If CarregaPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv)

			cChaveGuia := (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
			aClasEspe := IniciaEspecialidade()

			While !TRBPCT->(Eof())

				If (cAliPct)->BD7_TIPGUI $ G_RES_INTER + ',' + G_HONORARIO .OR. !Empty((cAliPct)->BD5_GUIINT)

					lIncDesp := .T.
					aClasEven := ClassInternacao(cAliPct,cChaveGuia,cTipData,.T.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

				ElseIf (cAliPct)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON

					lIncDesp := .T.
					aClasEven := ClassSADT(cAliPct,cChaveGuia,cTipData,.T.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

				EndIf

				If lIncDesp

					If TmpIncDesp(cRegANS,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,aClasEven)

						nQtdPacote++

					EndIf

				Else
					cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Despesa de pacote sem classificacao"
					CenWrLogJb(cTriRec,cTxt,,CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[1])
				EndIf

				TRBPCT->(dbSkip())

			EndDo

		Else
			If (cAlias)->BD7_TIPGUI $ G_RES_INTER + ',' + G_HONORARIO .OR. !Empty((cAlias)->BD5_GUIINT)

				lIncDesp := .T.
				aClasEven := ClassInternacao(cAlias,cChvGuiGrv,cTipData,.F.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

			ElseIf (cAlias)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON

				lIncDesp := .T.
				aClasEven := ClassSADT(cAlias,cChvGuiGrv,cTipData,.F.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

			EndIf
			If lIncDesp
				If TmpIncDesp(cRegANS,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,aClasEven)
					nQtdPacote++
				EndIf
			Else
				cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Despesa sem item de pacote cadastrado e Tipo de guia invalido"
				CenWrLogJb(cTriRec,cTxt,,CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[1])
			EndIf

		EndIf
		TRBPCT->(dbCloseArea())
	EndIf

Return nQtdPacote
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CarregaPacote

	Funcao criada para carregar os dados do pacote aberto

	@param cAlias		Area de trabalho corrente
	@param cRegANS		Numero de registro da operadora na ANS

	@return lRetorno	Retorna .T. se encontrou dados senao retorna .F.

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv)
	Local lRetorno 	:= .F.

	lRetorno := CarregaDados("TRBPCT",cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv)

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} MesPorThread

	Funcao criada para atualizar os parametros de data inicial e final da quinzena a ser utilizado na query

	@param pDataIni	Data inicial a ser atualizada
	@param pDataFin	Data final a ser atualizada
	@param pDataRef	Data de referencia a ser utilizada para encontrar as datas anteriores
	@param pThread	Thread que esta sendo executada

	@author timoteo.bega
	@since 07/06/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaDatas(pDataIni,pDataFin,pDataRef,pThread)
	Default pDataIni	:= DTOS(dDataBase)
	Default pDataFin	:= DTOS(dDataBase)
	Default pDataRef	:= DTOS(dDataBase)
	Default pThread		:= 1

	If pThread == 0

		If SubStr(pDataRef,5,2) $ "01,04,07,10"
			pThread := 1
		ElseIf SubStr(pDataRef,5,2) $ "02,05,08,11"
			pThread := 2
		Else
			pThread := 3
		EndIf

	EndIf

	If SubStr(pDataRef,5,2) $ "01,02,03"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "0101"
			pDataFin := SubStr(pDataRef,1,4) + "0131"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "0201"
			If Val(SubStr(pDataRef,1,4)) % 4 == 0//29
				pDataFin := SubStr(pDataRef,1,4) + "0229"
			Else
				pDataFin := SubStr(pDataRef,1,4) + "0228"
			EndIf
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "0301"
			pDataFin := SubStr(pDataRef,1,4) + "0331"
		EndIf
	ElseIf SubStr(pDataRef,5,2) $ "04,05,06"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "0401"
			pDataFin := SubStr(pDataRef,1,4) + "0430"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "0501"
			pDataFin := SubStr(pDataRef,1,4) + "0531"
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "0601"
			pDataFin := SubStr(pDataRef,1,4) + "0630"
		EndIf
	ElseIf SubStr(pDataRef,5,2) $ "07,08,09"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "0701"
			pDataFin := SubStr(pDataRef,1,4) + "0731"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "0801"
			pDataFin := SubStr(pDataRef,1,4) + "0831"
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "0901"
			pDataFin := SubStr(pDataRef,1,4) + "0930"
		EndIf
	ElseIf SubStr(pDataRef,5,2) $ "10,11,12"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "1001"
			pDataFin := SubStr(pDataRef,1,4) + "1031"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "1101"
			pDataFin := SubStr(pDataRef,1,4) + "1130"
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "1201"
			pDataFin := SubStr(pDataRef,1,4) + "1231"
		EndIf
	EndIf

Return

Static Function Inicializa()

//Inicio - Tabelas utilizadas durante o processamento
	dbSelectArea("BG9")
	BG9->(dbSetOrder(1))
	dbSelectArea("BG3")
	BG3->(dbSetOrder(1))
	dbSelectArea("BG1")
	BG1->(dbSetOrder(1))
	dbSelectArea("BQU")
	BQU->(dbSetOrder(1))
	dbSelectArea("BI3")
	BI3->(dbSetOrder(1))
	dbSelectArea("BI6")
	BI6->(dbSetOrder(1))
	dbSelectArea("BII")
	BII->(dbSetOrder(1))
	dbSelectArea("BE4")
	BE4->(dbSetOrder(1))//1 - BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	dbSelectArea("BD5")
	BD5->(dbSetOrder(1))
	dbSelectArea("BR8")
	BR8->(dbSetorder(3))
	dbSelectArea("BAQ")
	BAQ->(dbSetOrder(1))//BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
	dbSelectArea("B3K")
	B3K->(dbSetOrder(1))
	dbSelectArea("B3J")//Produtos /Planos
	B3J->(dbSetOrder(1))//B3K_FILIAL||B3K_CODOPE||B3K_MATRIC
	dbSelectArea("B3L")

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} SchedDef

	Funcao criada para definir o pergunte do schedule

	@return aParam		Parametros para a pergunta do schedule

	@author TOTVS PLS Team
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}
	Local oObj      := FWSX1Util():New()
	Local aPergunte :={}
	Local lPergNew     := .F.

	oObj:AddGroup("PLSCARDESN")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSCARDESN")

	If len(apergunte) > 1
		lPergNew:=len(apergunte[2]) > 0
	endif

	IIF(!lPergNew,aParam := { "P","PLSCARDESP",,aOrdem,""},aParam := { "P","PLSCARDESN",,aOrdem,""})

    FreeObj(oObj)
    oObj := Nil

Return aParam
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaBenCober

	Funcao criada para desprezar beneficiarios ja encontrados na tabela de coberturas

	@param cAlias		Nome da area de trabalho corrente
	@param cRegANS		Numero de registro da operadora na ANS

	@return lRetorno	Retorna .T. se encontrou dados senao retorna .F.

	@author TOTVS PLS Team
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PulaBenCober(cAlias,cRegANS)
	Local lRetorno	:= .T.
	Local cSql		:= ""
	Default cAlias	:= ""
	Default cRegANS	:= ""

	If Empty(cAlias) .Or. Empty(cRegANS)
		lRetorno := .F.
	EndIf

	If lRetorno

		cSql := "SELECT B3O_MATRIC FROM " + RetSqlName("B3O") + " WHERE B3O_FILIAL = '" + xFilial("B3O") + "' AND B3O_CODOPE = '" + cRegANS + "' AND B3O_MATRIC = '" + (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) + "' AND D_E_L_E_T_=' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"CORBEN",.F.,.T.)

		If !CORBEN->(Eof())

			While (cAlias)->(!Eof()) .And. AllTrim((cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)) == AllTrim(CORBEN->B3O_MATRIC)
				(cAlias)->(dbSkip())
			EndDo

		EndIf

		CORBEN->(dbCloseArea())

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} MarcaBD7

	Funcao criada para marcar com '999999' ou desmarcar com vazio os registros BD7 importados para a central

	@return cChaveGuia	Chave da guia: BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN
	@return cMarca			Marca a ser grava no campo BD7_RECSIP

	@author timoteob.bega
	@since 05/07/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function MarcaBD7(cChaveGuia,cMarca,lCapit)
	Local cUpdate		:= ""
	Local nRet			:= ""
	Default cChaveGuia	:= ""
	Default cMarca		:= ""
	Default lCapit      := .f.

	If !Empty(cChaveGuia)

	BEGIN TRANSACTION

		cUpdate := "UPDATE " + RetSqlName("BD7") + " SET BD7_RECSIP = '" + cMarca + "' WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
		cUpdate += "AND BD7_CODOPE = '" + SubStr(cChaveGuia,1,4) + "' "
		cUpdate += "AND BD7_CODLDP = '" + SubStr(cChaveGuia,5,4) + "' "
		cUpdate += "AND BD7_CODPEG = '" + SubStr(cChaveGuia,9,8) + "' "
		cUpdate += "AND BD7_NUMERO = '" + SubStr(cChaveGuia,17,8) + "' "
		cUpdate += "AND BD7_ORIMOV = '" + SubStr(cChaveGuia,25,1) + "' "
		cUpdate += "AND BD7_LIBERA <> '1' "
		cUpdate += "AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "

		If !lCapit
			cUpdate += "AND BD7_FASE = '" + GetNewPar("MV_PLFSSIP","4") + "' "
		EndIf

		cUpdate += "AND D_E_L_E_T_ = ' '"
		nRet := TcSQLExec(cUpdate)
        If nRet < 0
            PlsLogFil(CENDTHRL("E") + " MarcaBD7 - " + TCSQLError(),ARQ_LOG_DES)
        Else
			TcSQLExec("COMMIT")
            //PlsLogFil(CENDTHRL("I") + " Marcou a BD7 - " + cUpdate,ARQ_LOG_DES)
		EndIf

	END TRANSACTION

	EndIf

Return


//Chamadas de funcoes para retirar os warnings de compilacao
PulaBenCober("","")
SchedDef()

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExisteTerapia

	Funcao criada para retornar se existe algum procedimento de terapia na guia

	@param	cChaveGuia	Chave da guia para buscar o procedimento

	@return	lRetorno		Retorna .T. quando existir algum exame do item C acompanhando uma terapia

	@author timoteob.bega
	@since 06/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteTerapia(cChaveGuia,cAlias,lMV_STATISS)
	Local cSql		:= ""
	Local cCodOpe	:= SubStr(cChaveGuia,1,4)
	Local cCodLdp	:= SubStr(cChaveGuia,5,4)
	Local cCodPeg	:= SubStr(cChaveGuia,9,8)
	Local cNumero	:= SubStr(cChaveGuia,17,8)
	Local cOrimov	:= SubStr(cChaveGuia,25,1)
	Local lRetorno	:= .F.
	Local cAliSql	:= GetNextAlias()
	Default cAlias	:= ""
	Default lMV_STATISS	:= MV_STATISS


	If !Empty(cAlias) .And. SubStr((cAlias)->BR8_CLASIP,1,1) == 'D'
		lRetorno := .T.
	EndIf

	cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("BD6") + " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
	If !Empty(cCodOpe)
		cSql += "AND BD6_CODOPE = '" + cCodOpe + "' "
	EndIf
	If !Empty(cCodLdp)
		cSql += "AND BD6_CODLDP = '" + cCodLdp + "' "
	EndIf
	If !Empty(cCodPeg)
		cSql += "AND BD6_CODPEG = '" + cCodPeg + "' "
	EndIf
	If !Empty(cNumero)
		cSql += "AND BD6_NUMERO = '" + cNumero + "' "
	EndIf
	If !Empty(cOrimov)
		cSql += "AND BD6_ORIMOV = '" + cOrimov + "' "
	EndIf
	cSql += "AND BD6_CODPRO IN (" + TERAPIAS + ") "
	cSql += "AND BD6_FASE = '4' AND BD6_LIBERA <> '1'  AND BD6_SITUAC = '1' "

	cSql += "AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliSql,.F.,.T.)

	If !(cAliSql)->(Eof()) .Or. lRetorno
		lRetorno := .T.
	EndIf

	(cAliSql)->(dbCloseArea())

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExisteExame

	Funcao criada para retornar se existe algum procedimento de EXAME na guia

	@param	cChaveGuia	Chave da guia para buscar o procedimento

	@return	cClaExm		Classificacao de exame encontrada na guia

	@author timoteob.bega
	@since 19/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteExame(cChaveGuia,lMV_STATISS)
	Local cSql		:= ""
	Local cCodOpe	:= SubStr(cChaveGuia,1,4)
	Local cCodLdp	:= SubStr(cChaveGuia,5,4)
	Local cCodPeg	:= SubStr(cChaveGuia,9,8)
	Local cNumero	:= SubStr(cChaveGuia,17,8)
	Local cOrimov	:= SubStr(cChaveGuia,25,1)
	Local cClaExm := ""
	Local cAliSql	:= GetNextAlias()
	Default lMV_STATISS := MV_STATISS

	cSql := "SELECT MAX(BR8_CLASIP) BR8_CLASIP FROM " + RetSqlName("BD6") + " BD6, " + RetSqlName("BR8") + " BR8 "
	cSql += "WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BR8_FILIAL = '" + xFilial("BR8") + "' "
	cSql += "AND BD6_CODPAD = BR8_CODPAD AND BR8_CODPSA = BD6_CODPRO "
	If !Empty(cCodOpe)
		cSql += "AND BD6_CODOPE = '" + cCodOpe + "' "
	EndIf
	If !Empty(cCodLdp)
		cSql += "AND BD6_CODLDP = '" + cCodLdp + "' "
	EndIf
	If !Empty(cCodPeg)
		cSql += "AND BD6_CODPEG = '" + cCodPeg + "' "
	EndIf
	If !Empty(cNumero)
		cSql += "AND BD6_NUMERO = '" + cNumero + "' "
	EndIf
	If !Empty(cOrimov)
		cSql += "AND BD6_ORIMOV = '" + cOrimov + "' "
	EndIf
	cSql += "AND BD6_FASE = '4' AND BD6_LIBERA <> '1'  AND BD6_SITUAC = '1' "

	cSql += "AND BR8_CLASIP BETWEEN 'C' AND 'C999' "
	cSql += "AND BD6.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliSql,.F.,.T.)

	If !(cAliSql)->(Eof())
		cClaExm := (cAliSql)->BR8_CLASIP
	EndIf

	(cAliSql)->(dbCloseArea())

Return cClaExm
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} IniciaE1

	Funcao inicializa a matriz de eventos e classificacoes para os itens E11 ate E15
	Regras definidas baseadas na planilha da ANS de de-para SIP x TUSS de 20/06/2016

	@param	aClaIteE	Matriz a ser atualizada com os procedimentos e suas respectivas classificacoes

	@author timoteob.bega
	@since 31/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaE1(aClaIteE)
	Default aClaIteE := {}

	aAdd(aClaIteE,{"E11",{}})
	aAdd(aClaIteE,{"E121",{"31002218","31002390"}})//Cirurgia Bariatrica
	aAdd(aClaIteE,{"E122",{"31304010","31304052"}})//Laqueadura Tubaria
	aAdd(aClaIteE,{"E123",{"31205046","31205070"}})//Vasectomia
	aAdd(aClaIteE,{"E124",{"30725127","30725135","30725160","30725100","30725119","30725194","30724058","30724066","30724074","30724082"}})//Fratura de femur > 60 anos
	aAdd(aClaIteE,{"E125",{"30724279","30726255","30717159"}})//Revisao de artroplastia
	aAdd(aClaIteE,{"E126",{"30904021","30904161",}})//Implante de CDI
	aAdd(aClaIteE,{"E127",{"30904145","30904137","30904099","30904080","30904102","30904064","30904153","30904110","30904129"}})//Implantacao de marcapasso
	aAdd(aClaIteE,{"E131",{"31309127"}})//Parto normal
	aAdd(aClaIteE,{"E132",{"31309054","31309208"}})//Parto cesareo
	aAdd(aClaIteE,{"E14",{}})
	aAdd(aClaIteE,{"E15",{}})

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ClasItemE

	Funcao criada para retornar a classificacoes dos itens E11 ate E15

	@param	aClaIteE	Matriz com os procedimentos e suas respectivas classificacoes
	@param	cItemE		Item que sera classificado
	@param	cCdPrc		Codigo do procedimento
	@param	cClaSIPInt	Classificacao de internacao e retorno da funcao

	@return	cClaSIPInt	Classificacao de internacao e retorno da funcao

	@author timoteob.bega
	@since 31/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ClasItemE(aClaIteE,cItemE,cCdPrc,cClaSIPInt,nIdade)
	Local nPosIte		:= 0
	Local nFor			:= 0
	Default aClaIteE	:= {}
	Default cItemE		:= ""
	Default cCdPrc		:= ""
	Default cClaSIPInt	:= ""
	Default nIdade		:= 0

	For nFor := 1 TO Len(aClaIteE)

		nPosIte := aScan(aClaIteE[nFor,2],{|x| x == cCdPrc})

		If nPosIte > 0
			cClaSIPInt := aClaIteE[nFor,1]
			Exit
		EndIf

	Next nFor

	If Empty(cClaSIPInt) .Or. Alltrim(cClaSIPInt) == "E141"
		If Alltrim(cClaSIPInt) == "E141"
			cClaSIPInt := "E11XX"
		Else
			cClaSIPInt := SubStr(cItemE,1,3)
		EndIf
	EndIf

	If cClaSIPInt == "E124" .And. nIdade < 60
		cClaSIPInt := "E12"
	EndIf

Return cClaSIPInt
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} LimpaArray

	Funcao criada para limpar array

	@param	aTemp	Array a ser limpo

	@author timoteob.bega
	@since 09/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaArray(aTemp)
	Local nForArr	:= 0

	If Len(aTemp) > 0

		For nForArr := 1 TO Len(aTemp)
			aDel(aTemp,nForArr)
		Next nForArr

		ASize(aTemp,0)
		aTemp := {}

	EndIf

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} InsereNoLock

	Funcao criada para inserir clausula na query de consulta

	@param	cSql	Query a ser atualizada

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function InsereNoLock(cSql)
	Default cSql := ""

	cSql := StrTran(cSql,"WITH"," WITH (NOLOCK) ")

Return cSql
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ClassificaEspecialidade

	Funcao criada para classificar a especialidade baseada na matriz de especialidade

	@param	cCodEspMed	Chave da especialidade
	@param	aClasEspe	Matriz de especialidade

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ClassificaEspecialidade(cCodEspMed,aClasEspe)
	Local nEspe				:= 0
	Local cClaSIPEsp		:= ""
	Default cCodEspMed	:= ""
	Default aClasEspe	:= {}

	nEspe := aScan(aClasEspe,{|x| x[1] == cCodEspMed})

	If nEspe == 0 .And. BAQ->(msSeek(xFilial("BAQ")+cCodEspMed)) .And. !Empty(BAQ->BAQ_ESPSP2)
		cClaSIPEsp := BAQ->BAQ_ESPSP2
		aAdd(aClasEspe,{BAQ->(BAQ_CODINT+BAQ_CODESP),BAQ->BAQ_ESPSP2})
	ElseIf  nEspe > 0
		cClaSIPEsp := aClasEspe[nEspe,2]
	Else
		cClaSIPEsp := ""
	EndIf

Return cClaSIPEsp
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} IniciaEspecialidade

	Funcao criada para inserir a especialidade na matriz de especialidade para classificacao de consultas

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaEspecialidade()
	Local aClasEspe	:= {}
	Local cSql			:= "SELECT BAQ_CODINT, BAQ_CODESP, BAQ_ESPSP2 FROM " + RetSqlName("BAQ") + " WHERE BAQ_FILIAL = '" + xFilial("BAQ") + "' AND BAQ_CODINT = '" + PlsIntPad() + "' AND BAQ_ESPSP2 <> ' ' AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBAQ",.F.,.T.)

	While !TBAQ->(Eof())

		aAdd(aClasEspe,{TBAQ->(BAQ_CODINT+BAQ_CODESP),TBAQ->BAQ_ESPSP2})
		TBAQ->(dbSkip())

	EndDo

	TBAQ->(dbCloseArea())

Return aClasEspe
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} IniciaProduto

	Funcao criada para inserir o produto na matriz de produtos para descartes de produtos nao informados a ANS

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaProduto()
	Local aProduto		:= {}
	Local cSql			:= "SELECT BI3_CODINT, BI3_CODIGO, BI3_VERSAO, BI3_INFANS FROM " + RetSqlName("BI3") + " WHERE BI3_FILIAL = '" + xFilial("BI3") + "' AND BI3_CODINT = '" + PlsIntPad() + "' AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBI3",.F.,.T.)

	While !TBI3->(Eof())

		aAdd(aProduto,{TBI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO),TBI3->BI3_INFANS})
		TBI3->(dbSkip())

	EndDo

	TBI3->(dbCloseArea())

Return aProduto

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} DataReconPeg

	Funcao criada para retornar a data de reconhecimento da despesa quando MV_STATISS = .T.

	@author timoteob.bega
	@since 22/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function DataReconPeg(cAlias,lMV_STATISS)
	Local cDatReco		:= ""
	Default cAlias	:= ""
	Default lMV_STATISS	:= MV_STATISS

	If lMV_STATISS .And. cAlias == 'TRBREE' .And. !Empty((cAlias)->B44_DTLBFN)
		cDatReco := (cAlias)->B44_DTLBFN
	Else

		BCI->(dbSetOrder(14))
		If (cAlias)->BD7_TIPGUI <> G_REEMBOLSO .And. BCI->(dbSeek(xFilial("BCI")+(cAlias)->BD7_CODPEG))
			cDatReco := SubStr(BCI->BCI_DTHRLB,1,8)
		Else
			cDatReco := Iif( !Empty((cAlias)->BD6_DTDIGI) , (cAlias)->BD6_DTDIGI , (cAlias)->BD7_DATPRO )
		EndIf

	EndIf

Return cDatReco

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} RetDadInt

	Funcao criada para retorna a chave de internação da despesa

	@param	cChvPsq	Chave da internacao proveniente de BD5_GUIINT de SADT, BE4_GUIINT de Resumo com vinculo, BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT de Resumo sem vinculo

	@author timoteob.bega
	@since 11/05/2018
	/*/
//--------------------------------------------------------------------------------------------------
Static Function RetDadInt(cGuiInt,cChaveGuia,cTipGui,cTipData,cTriRec,lMV_STATISS,cAliUsa,lDtPag)
	Local aDadInt		:= {.F.,"","","","","",STOD(""),STOD(""),0,0,"","",""}
	Local cSql			:= ""
	Local cNAlias		:= GetNextAlias()
	Local cFilBE4		:= xFilial("BE4")
	Default cGuiInt		:= ""//BE4_CODOPE, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO
	Default cChaveGuia	:= ""
	Default cTipGui		:= ""
	Default cTipData	:= ""
	Default cTriRec		:= ""
	Default lMV_STATISS	:= MV_STATISS
	Default cAliUsa     := "BE4"
	Default lDtPag      := .F.

	If cTipData == "4"
		lDtPag:= .T.
	EndIF

	If cAliUsa <> "BD5"
		cSql := " SELECT "
		cSql += " BE4_GRPINT, BE4_REGINT, BE4_HORPRO, BE4_HRALTA, BE4_DATPRO, BE4_DTALTA, "
		cSql += " BE4_NASVIV, BE4_NASVPR, BE4_PADINT, BE4_GUIINT, BE4_CODOPE, BE4_CODLDP, "
		cSql += " BE4_CODPEG, BE4_NUMERO, BE4_NUMLOT, BE4_DTPAGT "
		If lMV_STATISS
			cSql += " , BCI_DTHRLB "
		EndIf
		cSql += " FROM " + RetSqlName("BE4") + " BE4 "
		If lMV_STATISS
			cSql += " , " + RetSqlName("BCI") + " BCI "
		EndIf
		cSql += " WHERE "
		cSql += " BE4_FILIAL='" + cFilBE4 + "' "
		If lMV_STATISS
			cSql += " AND BCI_FILIAL='" + xFilial("BCI") + "'  "
			cSql += " AND BE4_FILIAL = BCI_FILIAL "
			cSql += " AND BE4_CODOPE = BCI_CODOPE "
			cSql += " AND BE4_CODLDP = BCI_CODLDP "
			cSql += " AND BE4_CODPEG = BCI_CODPEG "
			cSql += " AND BCI_DTHRLB <> ' ' "
		Else
			cSql += " AND BE4_NUMLOT <> ' ' "
		EndIf
		cSql += " AND BE4_GUIINT='" + cGuiInt + "' AND BE4_TIPGUI='05' AND BE4.D_E_L_E_T_=' ' "
		If lMV_STATISS
			cSql += " AND BCI.D_E_L_E_T_=' ' "
			cSql += " ORDER BY BCI_DTHRLB "
		Else
			If !lDtPag
				cSql += " ORDER BY BE4_NUMLOT "
			Else
				cSql += " ORDER BY BE4_DTPAGT "
			EndIf
		EndIf

	Else
		cSql := " SELECT "
		cSql += " BD5_DATPRO, BD5_GUIINT, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO "
		cSql += " FROM " + RetSqlName("BD5") + " BD5 WHERE "
		cSql += " BD5_FILIAL='" + cFilBE4 + "' "
		cSql += " AND BD5_GUIINT= '" + cGuiInt + "' "
		cSql += " AND BD5_TIPGUI ='02' AND BD5_NUMLOT <> ' ' AND D_E_L_E_T_=' ' "

		IF !lDtPag
			cSql += " ORDER BY BD5_NUMLOT "
		Else
			cSql += " ORDER BY BD5_DTPAGT "
		EndIf

	Endif

	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	If !(cNAlias)->(Eof())
		If Empty(cTipData) .Or. ConsFreqInter(cNAlias,cTipData,cTriRec,lMV_STATISS,cAliUsa)//Considera frequencia de internacao ?
			SetDadInt(aDadInt,cNAlias,cAliUsa)
		EndIf
	Else

		If !Empty(cTriRec)//Resumo de Internacao nao encontrado para a despesa pela
			cMsg := CENDTHRL("W")  + "Tipo de Guia; " + cTipGui + "; Chave Despesa; " + cChaveGuia + "; Sol. Internacao; " + cGuiInt
			PlsLogFil(cMsg,DESP_SEM_RE)
			//PlsLogFil(CENDTHRL("I") + " " + cSql,DESP_SEM_RE)
		EndIf

	EndIf

	(cNAlias)->(dbCloseArea())

Return aDadInt
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} SetDadInt

	Funcao criada para preencher a matriz de internação da despesa

	@param	aDatInt	matriz a receber os dados da internação
	@param	cChvPsq	Chave da internacao proveniente de BD5_GUIINT de SADT, BE4_GUIINT de Resumo com vinculo, BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT de Resumo sem vinculo

	@author timoteob.bega
	@since 11/05/2018
	/*/
//--------------------------------------------------------------------------------------------------
Static Function SetDadInt(aDadInt,cAliTr,cAliUsa)
	Local aAreaBE4  := nil
	Default cAliUsa := "BE4"

	If cAliUsa == "BE4"
		aDadInt[1] := .T.
		aDadInt[2] := AllTrim((cAliTr)->BE4_GUIINT)//Chave da solicitação de internação - BE4_GUIINT
		aDadInt[3] := Iif( !Empty((cAliTr)->BE4_GRPINT),(cAliTr)->BE4_GRPINT,"1")//Grupo de Internação - default 1
		aDadInt[4] := Iif( !Empty((cAliTr)->BE4_REGINT),(cAliTr)->BE4_REGINT,"1")//Regime de Internação - default 1
		aDadInt[5] := (cAliTr)->BE4_HORPRO//Hora de Internação
		aDadInt[6] := (cAliTr)->BE4_HRALTA//Hora de Alta
		aDadInt[7] := (cAliTr)->BE4_DATPRO//Data de Internação
		aDadInt[8] := (cAliTr)->BE4_DTALTA//Data de Alta
		aDadInt[9] := (cAliTr)->BE4_NASVIV//Nascido Vivo
		aDadInt[10] := (cAliTr)->BE4_NASVPR//Nascido Prematuro
		aDadInt[11] := AllTrim((cAliTr)->BE4_GUIINT)//Chave da solicitação de internação - BE4_GUIINT
		aDadInt[12] := (cAliTr)->BE4_PADINT//Tipo de acomodação
		aDadInt[13]	:= (cAliTr)->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)//Chave do resumo de internacao
	Else
		aAreaBE4  := BE4->(GetArea())
		BE4->(DBSetOrder(1))
		If BE4->(dbSeek(xFilial("BE4")+(cAliTr)->BD5_GUIINT))
			aDadInt[1]  := .T.
			aDadInt[2]  := AllTrim((cAliTr)->BD5_GUIINT)//Chave da solicitação de internação - BD5_GUIINT
			aDadInt[3]  := Iif( !Empty(BE4->BE4_GRPINT),BE4->BE4_GRPINT,"1")//Grupo de Internação - default 1
			aDadInt[4]  := Iif( !Empty(BE4->BE4_REGINT),BE4->BE4_REGINT,"1")//Regime de Internação - default 1
			aDadInt[5]  := BE4->BE4_HORPRO//Hora de Internação
			aDadInt[6]  := BE4->BE4_HRALTA//Hora de Alta
			aDadInt[7]  := DTOS(BE4->BE4_DATPRO)//Data de Internação
			aDadInt[8]  := DTOS(BE4->BE4_DTALTA)//Data de Alta
			aDadInt[9]  := BE4->BE4_NASVIV//Nascido Vivo
			aDadInt[10] := BE4->BE4_NASVPR//Nascido Prematuro
			aDadInt[11] := AllTrim((cAliTr)->BD5_GUIINT)
			aDadInt[12] := BE4->BE4_PADINT//Tipo de acomodação
			aDadInt[13]	:= (cAliTr)->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)
		EndIF
		RestArea( aAreaBE4 )
	EndIf

Return aDadInt

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} RetLocIgn

	Retorna a lista de locais de atendimento que a operadora deseja ignorar na integração PLS x Central

	@author timoteo.bega
	@since 10/05/2018
	/*/
//--------------------------------------------------------------------------------------------------
Function RetLocIgn()
	Local cLocais	:= ""
	Local cLista	:= GetNewPar("MV_LLDPIGN","")

	If !Empty(cLista)
		cLocais := "('"
		cLocais += StrTran(cLista,",","','")
		cLocais += "')"
	EndIf

Return cLocais


Static Function ClsItemE14(cCID,cPadInt,cHoraInt,cHoraAlta,dDatInt,dDatAlta,dNasc,nIdade)
	Local cClaItem		:= "E14"
	//Local aCID142		:= {"P250","P251","P252","P253","P258","P260","P261","P268","P269","P271","P278","P279","P298","P2999","P398","P399","P780","P781","P968","P969","Z876"}
	Local aGrp16		:= {{'P00', 'P04'},{'P05', 'P08'},{'P10', 'P15'},{'P20', 'P29'},{'P35', 'P39'},{'P50', 'P61'},{'P70', 'P74'},{'P75', 'P78'},{'P80', 'P83'},{'P90', 'P96'}}
	Local lUtiNeoNatal	:= cPadInt == "53" //53-UTI NEONATAL
	Local cGrpCID		:= SubStr(cCID,1,2)
	Default cCID		:= ""
	Default cPadInt		:= ""
	Default cHoraInt    := ""
	Default cHoraAlta   := ""
	Default dDatInt     := STOD("")
	Default dDatAlta    := STOD("")
	Default dNasc       := STOD("")
	Default nIdade      := 0

	If nIdade <=5 .And. ( (cGrpCID >= "J00" .And. cGrpCID <= "J22") .Or. (cGrpCID $ "J45,J46")  .Or. (cCID >= "J00" .And. cCID <= "J22"))
		cClaItem := "E141"
	EndIf

	If lUtiNeoNatal .Or. aScan(aGrp16,{ |x| x[1] >= AllTrim(cGrpCID) .AND. x[2] <= AllTrim(cGrpCID) }) > 0
		cClaItem := "E142"

		If !Empty(dNasc) .And. !Empty(dDatAlta) .And. !Empty(dDatInt) .And. !Empty(cHoraAlta) .And. !Empty(cHoraInt)

			If (dDatInt - dNasc) <= 6
				If (dDatAlta - dDatInt) < 2
					cClaItem := "E1421"
				ElseIf (dDatAlta - dDatInt) = 2
					iF Val(SUbstr(cHoraAlta,1,4)) <= Val(Substr(cHoraInt,1,4))
						cClaItem := "E1421"
					EndIf
				Endif
			EndIf
		EndIf
	EndIf

Return cClaItem

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ConsFreqInter

	Essa funcao verifica se o resumo de internacao encontrado e reconhecido em outro trimestre, caso tenha
	reconhecimento em outro trimestre, vou enviar somente a despesa e nao envio a frequencia da internacao

	@author timoteo.bega
	@since 28/08/2018
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ConsFreqInter(cNAlias,cTipData,cTriRec,lMV_STATISS,cAliUsa)
	Local lRet			:= .T.//A principio vou considerar a frequencia, se eu conseguir identificar tri de reconhecimento diferente desconsidero
	Local cSql			:= ""
	Local cAliInt		:= GetNextAlias()
	Default cNAlias		:= ""
	Default cTipData	:= ""
	Default cTriRec		:= ""
	Default lMV_STATISS	:= MV_STATISS
	Default cAliUsa     := "BE4"

	If !Empty(cNAlias) .And. !Empty(cTriRec)

		If cTipData = "1"//data de digitacao

			If lMV_STATISS
				cSql := "SELECT SUBSTRING(BCI_DTHRLB,1,8) DATA FROM " + RetSqlName("BCI") + " WHERE BCI_FILIAL = '" + xFilial("BCI") + "' AND BCI_CODPEG = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODPEG,(cNAlias)->BD5_CODPEG) + "' AND D_E_L_E_T_ = ' '"
			Else
				cSql := "SELECT MAX(BD7_DTDIGI) DATA FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODOPE,(cNAlias)->BD5_CODOPE) + "' AND BD7_CODLDP = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODLDP,(cNAlias)->BD5_CODLDP) + "' AND BD7_CODPEG = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODPEG,(cNAlias)->BD5_CODPEG) + "' AND BD7_NUMERO = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_NUMERO,(cNAlias)->BD5_NUMERO) + "' AND D_E_L_E_T_ = ' '"
			EndIf

		ElseIf cTipData = "2"//data de pagamento
			cSql := "SELECT MAX(SUBSTRING(BD7_NUMLOT,1,6)) DATA FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODOPE,(cNAlias)->BD5_CODOPE) + "' AND BD7_CODLDP = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODLDP,(cNAlias)->BD5_CODLDP) + "' AND BD7_CODPEG = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODPEG,(cNAlias)->BD5_CODPEG) + "' AND BD7_NUMERO = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_NUMERO,(cNAlias)->BD5_NUMERO) + "' AND D_E_L_E_T_ = ' '"
		ElseIf cTipData = "3"//data do procedimento
			cSql := "SELECT MAX(BD6_DATPRO) DATA FROM " + RetSqlName("BD6") + " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BD6_CODOPE = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODOPE,(cNAlias)->BD5_CODOPE) + "' AND BD6_CODLDP = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODLDP,(cNAlias)->BD5_CODLDP) + "' AND BD6_CODPEG = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODPEG,(cNAlias)->BD5_CODPEG) + "' AND BD6_NUMERO = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_NUMERO,(cNAlias)->BD5_NUMERO) + "' AND D_E_L_E_T_ = ' '"
		Else
			cSql := "SELECT MAX(SUBSTRING(BD7_DTPAGT,1,6)) DATA FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODOPE,(cNAlias)->BD5_CODOPE) + "' AND BD7_CODLDP = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODLDP,(cNAlias)->BD5_CODLDP) + "' AND BD7_CODPEG = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_CODPEG,(cNAlias)->BD5_CODPEG) + "' AND BD7_NUMERO = '" + IIF(cAliUsa=="BE4",(cNAlias)->BE4_NUMERO,(cNAlias)->BD5_NUMERO) + "' AND D_E_L_E_T_ = ' '"
		Endif

		If CENCRIAALI(cSql,cAliInt)
			cData := (cAliInt)->DATA + Iif(cTipData $ "2/4","01","")
			cTriAux := SubStr(DataTrimestre(cData,"3"),1,6)
			If cTriAux <> cTriRec
				lRet := .F.
			EndIf
		EndIf

		(cAliInt)->(dbCloseArea())

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CENCRIAALI

	Funcao criada para criar e abrir uma area de trabalho baseada em consulta ao BD

	@param cConsulta		Consulta a ser executada
	@param cNomeArea		Nome do alias a ser criado

	@return lRetorno		Indica se a area foi criada ou nao

	@author timoteo.bega
	@since 14/09/2017
	/*/
//--------------------------------------------------------------------------------------------------
Function CENCRIAALI(cConsulta,cNomeArea)
Local lRetorno			:= .F.
Default cConsulta	:= ""
Default cNomeArea	:= ""

If !Empty(cConsulta) .And. !Empty(cNomeArea)

	cConsulta := ChangeQuery(cConsulta)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cNomeArea,.F.,.T.)

	If !(cNomeArea)->(Eof())
		lRetorno := .T.
	EndIf

EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} NomeJob

	Funcao criada para retornar o nome do job para o log

	@author timoteo.bega
	@since
	/*/
//--------------------------------------------------------------------------------------------------
Static Function NomeJob(lQryInter,lDadosHist)
	Local cNome := ""
	Default lQryInter	:= .F.
	Default lDadosHist	:= .F.

	If lDadosHist
		cNome += "HIS "
	EndIf

	If lQryInter
		cNome += "BE4"
	Else
		cNome += "BD5"
	EndIf

Return cNome

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CENDTHRL

	Funcao criada para retornar date e hora para log

	@author timoteo.bega
	@since
	/*/
//--------------------------------------------------------------------------------------------------
Function CENDTHRL(cTp)
	Local cMsg := "[" + DTOS(Date()) + " " + Time() + "]"
	Default cTp	:= "I"

	If cTp == "E"
		cMsg += "[ERRO]"
	ElseIf cTp == "W"
		cMsg += "[WARN]"
	Else
		cMsg += "[INFO]"
	EndIf

Return cMsg

Static Function RetornaCID(cChaveGuia)
	Local cCID	:= ""

	cCID := BE4RetornaCID(cChaveGuia)

	If Empty(cCID)

		cCID := BA9RetornaCID(cChaveGuia)

	EndIf

Return cCID

Static Function BE4RetornaCID(cChaveGuia)
	Local cCID		:= ""
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()

	cConsulta := RetQueryCID("1",cChaveGuia)

	If CENCRIAALI(cConsulta,cNomeArea)

		cCID := (cNomeArea)->CID

	EndIf

	(cNomeArea)->(dbCloseArea())

Return cCID

Static Function BA9RetornaCID(cChaveGuia)
	Local cCID		:= ""
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()

	cConsulta := RetQueryCID("2",cChaveGuia)

	If CENCRIAALI(cConsulta,cNomeArea)

		cCID := (cNomeArea)->CID

		If !Empty(cCID)

			cCID := GetCIDBA9(cCID)

		EndIf

	EndIf

	(cNomeArea)->(dbCloseArea())

Return cCID

Static Function RetQueryCID(cTp,cChaveGuia)
	Local cConsulta	:= ""
	Local cCampo	:= ""
	Local cWhere	:= ""
	Default cTp		:= "1"

	cCodOpe := SubStr(cChaveGuia,1,4)
	cCodLdp := SubStr(cChaveGuia,5,4)
	cCodPeg := SubStr(cChaveGuia,9,8)
	cNumero := SubStr(cChaveGuia,17,8)
	cSituac := SubStr(cChaveGuia,25,1)
	cFase := SubStr(cChaveGuia,26,1)

	If cTp == "1"

		cCampo	:= " BE4_CID "
		cWhere	:= " AND BE4_CIDREA=' ' "

	Else

		cCampo := " BE4_CIDREA "
		cWhere	:= " AND BE4_CIDREA<>' ' "

	EndIf

	cConsulta := "SELECT " + cCampo + " CID FROM " + RetSqlName("BE4") + " WHERE BE4_FILIAL='" + xFilial("BE4") + "' AND BE4_CODOPE='" + cCodOpe + "' AND BE4_CODLDP='" + cCodldp + "' AND BE4_CODPEG='" + cCodPeg + "' AND BE4_NUMERO='" + cNumero + "' "
	cConsulta += " AND BE4_SITUAC='" + cSituac + "' AND BE4_FASE='" + cFase + "' " + cWhere + " AND D_E_L_E_T_=' '"

Return cConsulta

Static Function GetCIDBA9(cCID)
	Local cConsulta		:= ""
	Local cNomeArea		:= GetNextAlias()
	Default cCID		:= ""

	cConsulta := "SELECT BA9_CODDOE FROM " + RetSqlName("BA9") + " WHERE BA9_FILIAL='" + xFilial("BA9") + "' AND BA9_CODDOE='" + cCID + "' AND D_E_L_E_T_=' '"

	If CENCRIAALI(cConsulta,cNomeArea)

		cCID := AllTrim((cNomeArea)->BA9_CODDOE)

	EndIf

	(cNomeArea)->(dbCloseArea())

Return cCID

Static Function ExisteEstorno(cChaveGuia)
	Local cConsulta	:= ""
	Local lRetorno	:= .F.
	Local cCodOpe	:= SubStr(cChaveGuia,1,4)
	Local cCodLdp	:= SubStr(cChaveGuia,5,4)
	Local cCodPeg	:= SubStr(cChaveGuia,9,8)
	Local cNumero	:= SubStr(cChaveGuia,17,8)
	Local cOrimov	:= SubStr(cChaveGuia,25,1)
	Local cNomeArea	:= GetNextAlias()

	cConsulta := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("BD5") + " WHERE BD5_FILIAL='" + xFilial("BD5") + "' "
	If !Empty(cCodOpe)
		cConsulta += "AND BD5_CODOPE = '" + cCodOpe + "' "
	EndIf
	If !Empty(cCodLdp)
		cConsulta += "AND BD5_CODLDP = '" + cCodLdp + "' "
	EndIf
	If !Empty(cCodPeg)
		cConsulta += "AND BD5_CODPEG = '" + cCodPeg + "' "
	EndIf
	If !Empty(cNumero)
		cConsulta += "AND BD5_NUMERO = '" + cNumero + "' "
	EndIf
	If !Empty(cOrimov)
		cConsulta += "AND BD5_ORIMOV = '" + cOrimov + "' "
	Endif

	cConsulta += " AND BD5_GUESTO='1' AND D_E_L_E_T_=' ' "

	If CENCRIAALI(cConsulta,cNomeArea)
		lRetorno := .T.
	EndIf

	(cNomeArea)->(dbCloseArea())

Return lRetorno

Static Function InformaProduto(cChaveProd,aProduto)
	Local lRetorno	:= .F.
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()
	Default aProduto:= {}

	cCodInt := Substr(cChaveProd,1,4)
	cCodigo := Substr(cChaveProd,5,4)
	cVersao := Substr(cChaveProd,9,3)

	cConsulta := "SELECT R_E_C_N_O_ REC,BI3_INFANS FROM " + RetSqlName("BI3") + " WHERE BI3_FILIAL='" + xFilial("BI3") + "' AND BI3_CODINT='" + cCodInt + "' AND BI3_CODIGO='" + cCodigo + "' AND BI3_VERSAO='" + cVersao + "' AND BI3_INFANS='0' AND D_E_L_E_T_=' '"

	If CENCRIAALI(cConsulta,cNomeArea)

		lRetorno := .T.
		aAdd(aProduto,{cChaveProd,(cNomeArea)->BI3_INFANS})

	EndIf

	(cNomeArea)->(dbCloseArea())

Return lRetorno

Static Function BANInicia()
	Local aBAN	:= {}
	Local cConsulta	:= "SELECT BAN_CODIGO, BAN_VERSAO, BAN_CLACAR, BAN_QTDCAR, BAN_UNCAR FROM " + RetSqlName("BAN") + " WHERE BAN_FILIAL='" + xFilial("BAN") + "' AND D_E_L_E_T_=' '"
	Local cNomeArea	:= GetNextAlias()

	If CENCRIAALI(cConsulta,cNomeArea)

		While !(cNomeArea)->(Eof())

			aAdd(aBAN,{ (cNomeArea)->(BAN_CODIGO+BAN_VERSAO+BAN_CLACAR), (cNomeArea)->BAN_QTDCAR, (cNomeArea)->BAN_UNCAR })
			(cNomeArea)->(DbSkip())

		EndDo

	EndIf

	(cNomeArea)->(dbCloseArea())

Return aBAN

Static Function BDLInicia()
	Local aBDL	:= {}
	Local cConsulta	:= "SELECT BDL_CODINT, BDL_CODIGO, BDL_CARENC, BDL_UNCAR FROM " + RetSqlName("BDL") + " WHERE BDL_FILIAL='" + xFilial("BDL") + "' AND D_E_L_E_T_=' '"
	Local cNomeArea	:= GetNextAlias()

	If CENCRIAALI(cConsulta,cNomeArea)

	While !(cNomeArea)->(Eof())

		aAdd(aBDL,{ (cNomeArea)->(+BDL_CODINT+BDL_CODIGO), (cNomeArea)->BDL_CARENC, (cNomeArea)->BDL_UNCAR })
		(cNomeArea)->(DbSkip())

	EndDo

	EndIf

	(cNomeArea)->(dbCloseArea())

Return aBDL

Static Function NatSaudeItem(aNatSaude,cClaSIP)
	Local aRet			:= {}
	Local nFor			:= 0
	Default	aNatSaude	:= {}
	Default cClaSip		:= ""

	If !Empty(cClaSIP) .And. Len(aNatSaude) > 0

		For nFor := 1 TO Len(aNatSaude)

			If aNatSaude[nFor,7] == '3' .And. aNatSaude[nFor,8] == cClaSIP .And. ( (aNatSaude[nFor,4]+aNatSaude[nFor,5] > 0) .Or. !Empty(aNatSaude[nFor,6]) )

				aAdd(aRet,{aNatSaude[nFor,1],aNatSaude[nFor,2],aNatSaude[nFor,3],aNatSaude[nFor,4],aNatSaude[nFor,5],aNatSaude[nFor,6],aNatSaude[nFor,7],aNatSaude[nFor,8]})

			EndIf

		Next nFor

	EndIf

Return aRet

Static Function LimpaExpostos(cCodOpe,cCodObr,cAno,cCdComp)
	Local cSql		:= ""
	Local nRet		:= 0
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAno	:= ""
	Default cCdComp	:= ""

	BEGIN TRANSACTION

	cSql := "DELETE FROM " + RetSqlName("B3O") + " WHERE B3O_FILIAL='" + xFilial("B3O") + "' AND B3O_CODOPE='" + cCodOpe + "' AND B3O_CDOBRI='" + cCodObr + "' AND B3O_ANO='" + cAno + "' AND B3O_CDCOMP='" + cCdComp + "' AND D_E_L_E_T_=' ' "
	nRet := TCSQLEXEC(cSql)
	If nRet >= 0
		TCSQLEXEC("COMMIT")
	Else
		PlsLogFil("LimpaExpostos" + CENDTHRL("E") + " " + cSql,ARQ_LOG_DES)
	EndIf

	END TRANSACTION

Return


Function BscPrfExe(cRegPre,cCdPfPr,cCodRda,cUF,cCodLoc)
	Local cValPes   :={}
	Default cRegPre :=""
	Default cCdPfPr :=""
	Default cCodRda :=""
	Default cUF     :=""
	Default cCodLoc :=""


	If !Empty(cCodRda)      //BD7_CODRDA
		cValPes:=cCodRda
	ElseIf !Empty(cRegPre)  //BD7_REGPRE
		cValPes:=cRegPre
	ElseIf !Empty(cCdPfPr)  //BD7_CDPFPR
		cValPes:=cCdPfPr
	EndIf

	If !Empty(cValPes)
		BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
		If BAU->(DbSeek(xFilial("BAU")+cValPes))
			cUf:=BAU->BAU_EST
			BB8->(DbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
			If !Empty(cCodLoc) .And. BB8->(DbSeek(xFilial("BB8")+cValPes+cCodLoc))
				If !Empty(BB8->BB8_EST)
					cUf:=BB8->BB8_EST
				EndIf
			EndIf
		Endif
	EndIf

	If Empty(cUf)
		cUf:="ZZ"
	Endif

return cUF
