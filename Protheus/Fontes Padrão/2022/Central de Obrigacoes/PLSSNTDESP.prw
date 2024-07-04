#include 'totvs.ch'
#DEFINE ARQUIVO_LOG "sintetiza_despesa_sip.log"
#DEFINE MV_PLCENDB	GetNewPar("MV_PLCENDB",.F.)
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSNTDESP

Funcao criada para Sintetizar as Despesas na tabela XML_SIP(B3M) via schedule

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSNTDESP(cChvCom,lSint)
	PRIVATE __cError := ""
	PRIVATE __cCallStk := ""
	Default cChvCom := ""
	Default lSint	:= .T.

	SintetizaDespesas(cChvCom,lSint)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SintetizaDespesas

Funcao de sintetização de despesas no NIO

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SintetizaDespesas(cChvComp,lSint)
	Local nArquivo		:= 0 //handle do arquivo/semaforo
	Local nRegPro		:= 0 //Contador de registros processados
	Local nRegSnt		:= 0 //Contador de registros sintetizados
	Local aArea			:= GetArea()
	Local cTriRec		:= ""
	Local nThread		:= 0
	Local nQuinzena		:= 1
	Local nRegSel		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local lMV_PLCENDB	:= MV_PLCENDB
	Default cChvComp	:= AllTrim(MV_PAR01)
	Default lSint		:= .T.//.T. Sintetiza .F. Limpa tabela

	cRegAns := SubStr(cChvComp,1,6)
	cCodObr := SubStr(cChvComp,7,3)
	cAno := SubStr(cChvComp,10,4)
	cComp := SubStr(cChvComp,14,3)
	cTriRec := cAno+SubStr(cComp,2,2)

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE

		PodeSintetizar(cTrirec)

		PlsAtuMonitor("PLSSNTDESP")
		PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Inicio SintetizaDespesas",ARQUIVO_LOG)

		//abrir semaforo
		nArquivo := Semaforo('A',0, cChvComp)

		//Se abriu o semaforo
		If nArquivo > 0
			B3M->(DbSetOrder(2)) //B3J_FILIAL+B3J_CODOPE+B3J_CODIGO
			PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Buscando dados de despesas para sintetizar. " ,ARQUIVO_LOG)

			If CarregaDespesas(cCodObr,cRegAns,cAno,cComp)
				cTriRec := TRBSNT->B3L_TRIREC
				cNomJob := CENNOMJOB(nThread,nQuinzena,"SNTDESSIP",.F.)[1]
				cDesJob := CENNOMJOB(nThread,nQuinzena,"SNTDESSIP",.F.)[2]

				PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Encontrou dados. " ,ARQUIVO_LOG)
				cDatExe := DTOS(dDataBase)
				cHorExe	:= Time()
				aJOBs := aJOBs := {"PLSIPDES(11)S","PLSIPDES(11)I","PLSIPDES(21)S","PLSIPDES(21)I","PLSIPDES(31)S","PLSIPDES(31)I","PLSIPACU(00)","PLSIPACU(10)","PLSIPACU(20)","PLSIPREE(10)","PLSIPREE(20)","PLSIPREE(30)","PLSIPEXP(10)","PLSIPEXP(20)","PLSIPEXP(30)","PLSIPEXP(40)","PLSIPEXP(50)","PLSIPEXP(60)"}
				CENMANTB3V(cRegANS,cCodObr,cAno,cComp,cTrirec,"1",cNomJob,cDesJob,,cDatExe,cHorExe,JOB_AGUARD,aJOBs,lMV_PLCENDB)

				LimpaB3M(TRBSNT->B3L_CODOPE, TRBSNT->B3L_TRIREC)

				If lSint//Quando for .F. so quero limpar a b3m

					While !TRBSNT->(Eof())
						nRegPro++

						cItem 	:= IIf(Empty(TRBSNT->B3L_CLAINT),TRBSNT->B3L_CLAAMB,TRBSNT->B3L_CLAINT)
						cTipCon := TRBSNT->B3L_FORCON
						cSeg 	:= AjustaSeg(cItem)
						cEstado := TRBSNT->B3L_UF
						cTriRec := TRBSNT->B3L_TRIREC
						cTriOco := TRBSNT->B3L_TRIOCO
						nQtdEve := TRBSNT->QTD
						nQtdDesp := TRBSNT->VALOR

						If lMV_PLCENDB
							PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Vai gravar. "  ,ARQUIVO_LOG)
						EndIf

						PLSAtuB3M(cRegAns,cTipCon,cSeg,cEstado,cItem,cTriRec,cTriOco,nQtdEve,nQtdDesp)

						nRegSnt++

						If nRegPro % 100 == 0 .Or. nRegPro == 1

							PlsAtuMonitor("PLSSNTDESP("+ALLTRIM(STR(nRegPro))+"): " + cRegAns+cTipCon+cSeg+cEstado+cItem+cTriRec)

							cObs := AllTrim(Str(nRegPro)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
							CENMANTB3V(cRegANS,cCodObr,cAno,cComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)

							// If lMV_PLCENDB
							cStr := "Processou " + Alltrim(Str(nRegSnt)) + " registros "
							PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Status parcial. " + cStr ,ARQUIVO_LOG)
							// Endif

						EndIf//If nRegPro % 500 == 0

						If lMV_PLCENDB
							PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Gravou. "  ,ARQUIVO_LOG)
						EndIf

						TRBSNT->(DbSkip())

					EndDo

				EndIf//lSint

				cObs := cNomJob + " concluído!"
				CENMANTB3V(cRegANS,cCodObr,cAno,cComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

				TRBSNT->(DbCloseArea())
				PLSBENESNT(cChvComp,"1")

			Else
				PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Sem dados de despesa para sintetizar. =) ",ARQUIVO_LOG)
			EndIf

		Else
			PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Não foi possível abrir o arquivo do semáforo. Outra sintetização já pode estar sendo executada." ,ARQUIVO_LOG)
		EndIf

		//Fecha semaforo
		nArquivo := Semaforo('F',nArquivo,cCodObr+cRegAns+cAno+cComp)

		MsUnlockAll()

		RestArea(aArea)

		cStr := " Processou " + Alltrim(Str(nRegSnt)) + " registros "

		PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + cStr ,ARQUIVO_LOG)
		PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Fim SintetizaDespesas. " ,ARQUIVO_LOG)

		RECOVER
		disarmTransaction()

	END SEQUENCE
	ErrorBlock(bBlock)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaDespesas

Funcao criada para capturar os erros ocorridos em tempo de execução

@param cRegAns		Numero de registro da operadora na ANS
@param cTipCon		Tipo de contratacao do plano
@param cSeg			Segmentacao do plano
@param cEstado		Estado do beneficiario
@param cItem		Item assistencial
@param cTriRec		Trimestre de reconhecimento
@param cTriOco		Trimestre de ocorrencia
@param nQtdEve		Quantidade realizada do evento
@param nQtdDesp		Valor total das despesas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaDespesas(cCodObr, cRegAns, cAno, cComp)

	Local lTemInfo := .F.
	Local cSql := ""
	Local cTriRec := cAno + SubStr(cComp,2,2)

	PlsAtuMonitor("Carregando despesas para sintetizar")

	cSql += " SELECT B3L_CODOPE, B3L_TRIREC, B3L_TRIOCO, B3L_UF, B3L_FORCON, B3L_CLAAMB, B3L_CLAINT "
	cSql += " ,SUM(B3L_QTDEVE) QTD ,SUM(B3L_VLREVE) VALOR "
	cSql += " FROM " + RetSqlName("B3L") + " B3L "
	cSql += " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
	cSql += "     AND B3L_MATRIC = B3L_EVEDES "
	cSql += "     AND B3L_CODOBR = '" + cCodObr + "' "
	cSql += "     AND B3L_CODOPE = '" + cRegAns + "' "
	cSql += "     AND B3L_ANOCMP = '" + cAno + "' "
	cSql += "     AND B3L_CDCOMP = '" + cComp + "' "
	cSql += "     AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY B3L_CODOPE, B3L_TRIREC, B3L_TRIOCO, B3L_UF,B3L_FORCON, B3L_CLAAMB, B3L_CLAINT "
	cSql += " ORDER BY B3L_CODOPE, B3L_TRIREC, B3L_TRIOCO, B3L_UF,B3L_FORCON, B3L_CLAAMB, B3L_CLAINT "

	cSql := ChangeQuery(cSql)
	PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " " + cSql,ARQUIVO_LOG)
	PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Query inicio",ARQUIVO_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBSNT",.F.,.T.)
	PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Query termino",ARQUIVO_LOG)

	lTemInfo := !TRBSNT->(Eof())

Return lTemInfo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSAtuB3M

Funcao criada para capturar os erros ocorridos em tempo de execução

@param cRegAns		Numero de registro da operadora na ANS
@param cTipCon		Tipo de contratacao do plano
@param cSeg			Segmentacao do plano
@param cEstado		Estado do beneficiario
@param cItem		Item assistencial
@param cTriRec		Trimestre de reconhecimento
@param cTriOco		Trimestre de ocorrencia
@param nQtdEve		Quantidade realizada do evento
@param nQtdDesp		Valor total das despesas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
FUNCTION PLSAtuB3M(cRegAns,cTipCon,cSeg,cEstado,cItem,;
		cTriRec,cTriOco,nQtdEve,nQtdDesp)
	Local aArea	:= GetArea()

	//Verifico se já foi feita alguma sintetização deste item
	lInclui := !ExistB3M(cRegAns,cTriRec,cTriOco,cEstado,cTipCon,cItem,cSeg)

	RecLock("B3M",lInclui)

	B3M->B3M_FILIAL	:= xFilial("B3M")
	B3M->B3M_CODOPE	:= cRegAns
	B3M->B3M_SAZONA	:= "3"
	B3M->B3M_FORCON	:= cTipCon
	B3M->B3M_SEGMEN	:= cSeg
	B3M->B3M_UF		:= cEstado
	B3M->B3M_ITEM	:= cItem
	B3M->B3M_TRIREC	:= cTriRec
	B3M->B3M_TRIOCO	:= cTriOco
	B3M->B3M_QTDEVE	:= nQtdEve
	B3M->B3M_VLRTOT	:= nQtdDesp

	B3M->(MsUnlock())

	RestArea(aArea)

Return

Static Function ExistB3M(cRegAns,cTriRec,cTriOco,cEstado,cTipCon,cItem,cSeg)
	Local cSql 		:= ""
	Local lRetorno	:= .F.

	cSql := " SELECT R_E_C_N_O_ REC "
	cSql += " FROM " + RetSqlName("B3M") + " "
	cSql += " WHERE B3M_FILIAL='" + xFilial("B3M") + "' "
	cSql += "     AND B3M_CODOPE = '" + cRegAns + "' "
	cSql += "     AND B3M_SAZONA = '3' "
	cSql += "     AND B3M_TRIREC = '" + cTriRec + "' "
	cSql += "     AND B3M_TRIOCO = '" + cTriOco + "' "
	cSql += "     AND B3M_UF	 = '" + cEstado + "' "
	cSql += "     AND B3M_FORCON = '" + cTipCon + "' "
	cSql += "     AND B3M_ITEM	 = '" + cItem + "' "
	cSql += "     AND B3M_SEGMEN = '" + cSeg + "' "
	cSql += "     AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3M",.F.,.T.)

	If !TRBB3M->(Eof())
		lRetorno := .T.
		B3M->(dbGoto(TRBB3M->REC))
	EndIf
	TRBB3M->(dbCloseArea())

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro as variáveis __cError e __cCallStk sao private e precisam ser criadas
na rotina que ira ter o controle SEQUENCE que chama esta funcao

@param e		Referencia ao erro
@param nThread	Numero da thread em execucao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChecErro(e)

	__cError := e:Description
	__cCallStk := e:ErrorStack

	PlsLogFil(CENDTHRL("I") + " Erro durante a sintetização. Erro: " + __cError + " CallStack: " + __cCallStk ,ARQUIVO_LOG)

	BREAK

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo		Handle do arquivo no disco
@param cComp		Codigo do compromisso

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo,cComp)
	Local cArquivo		:= 'sintet_desp_sip_'+ cComp +'.smf'
	Default nArquivo	:= 0
	Default cOpcao		:= 'A'

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo

			nArquivo := FOPEN(cArquivo,2)
			if nArquivo = -1
				nArquivo := FCreate(cArquivo,0)
			EndIf

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo

			If FClose(nArquivo)
				nArquivo := 0
			EndIf

	EndCase

Return nArquivo
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

	aParam := { "P",;
		"SIPSDE",;
		,;
		aOrdem,;
		""}
Return aParam
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsAtuMonitor

Funcao criada para atualizar mensagem de observacao no servidor

@param nQtdeReg		Quantidade de registros processados
@param cMsg			Mensagem informativa

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlsAtuMonitor(cMsg)
	Default cMsg		:= ""

	PtInternal(1,AllTrim(cMsg))

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaB3M

Funcao criada para limpar a sintetizacao

@param cRegAns		Numero de registro na ANS
@param cTriRec		Trimestre de reconhecimento

@author timoteo.bega
@since 27/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaB3M(cRegAns,cTriRec)
	Local cSql			:= ""
	Local nRet			:= 0
	Default cRegAns	:= ""
	Default cTriRec	:= ""

	cSql := "DELETE FROM " + RetSqlName("B3M") + " WHERE B3M_FILIAL='"+xFilial("B3M")+"' AND B3M_CODOPE='"+cRegAns+"' AND B3M_TRIREC='"+cTriRec+"' "
	PlsLogFil("[" + cTrirec + "]" + CENDTHRL("I") + " Limpando dados sintetizados. " + cSql ,ARQUIVO_LOG)
	nRet := TCSQLEXEC(cSql)
	If nRet >= 0
		If SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		EndIf
	Else
		PlsLogFil("[" + cTrirec + "]" + CENDTHRL("E") + " " + TCSQLError(),ARQ_LOG_DES)
	Endif

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PodeSintetizar

Funcao criada para fazer aguardar o termino da carga da B3Q para B3L e liberar o job PLSIPTOT

@author timoteo.bega
@since 11/05/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PodeSintetizar(cTrirec)
	Local aInfo		:= GetUserInfoArray()
	Local nTempo	:= 0
	Local lContinua := .F.

	While !lContinua

		If aScan(aInfo,{ |x| AllTrim(x[5]) == "PLJSIPTOT" }) == 0
			lContinua := .T.
		Else
			nTempo += 60000
			Sleep(60000)//Aguardo 1 minuto
			cMsg := "[" + cTrirec + "]" + CENDTHRL("I") + "Aguardando a " + AllTrim(Str(nTempo/60000)) + " minuto(s) para sintetizar "
			PtInternal(1,cMsg)
			PlsLogFil(cMsg,ARQUIVO_LOG)
			aInfo	:= GetUserInfoArray()
		EndIf

	EndDo

Return
