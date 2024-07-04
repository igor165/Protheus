#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'FILEIO.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
#define ARQUIVO_LOG	"monitor_jobs_central.log"
#define MV_PLCENDB	GetNewPar("MV_PLCENDB",.F.)
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
	#define BARRA "/"
#ELSE
	#define CRLF Chr(10)
	#define BARRA "\"
#ENDIF
#define ARQ_OCORREN Iif(lLinux,"/","\") + "sip" + Iif(lLinux,"/","\")  + "Ocorrencias_SIP_Despesas_"
#define ARQ_OCO_EXP Iif(lLinux,"/","\")  + "sip" + Iif(lLinux,"/","\")  + "Ocorrencias_SIP_Expostos_"
#define ARQ_OCO_REE Iif(lLinux,"/","\")  + "sip" + Iif(lLinux,"/","\")  + "Ocorrencias_SIP_Reembolso_"
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMONJOB

Visualizacao dos jobs de processamento do SIP

@author timoteo.bega
@since 05/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENMONJOB(cFiltro,lAuto)
	Local oBrowse	:= Nil
	//Métricas - FwMetrics
	Local lLibSupFw		:= FWLibVersion() >= "20200727"
	Local lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
	Local lHabMetric	:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
	Default lAuto   := .F.
	Default cFiltro := "B3V_FILIAL=xFilial('B3V') "+;
		".AND. B3V_CODOPE=B3D->B3D_CODOPE "+;
		".AND. B3V_CODOBR=B3D->B3D_CDOBRI "+;
		".AND. B3V_ANOCMP=B3D->B3D_ANO "+;
		".AND. B3V_CDCOMP=B3D->B3D_CODIGO "

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B3V')
	oBrowse:SetDescription("Monitor - Processamento")
	oBrowse:ForceQuitButton()
	oBrowse:setMenuDef("CENMONJOB")
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:AddLegend( "B3V_STATUS=='1'", "YELLOW"  , "Processando" )
	oBrowse:AddLegend( "B3V_STATUS=='2'", "BLUE"  , "Aguardando" )
	oBrowse:AddLegend( "B3V_STATUS=='3'", "GREEN"   , "Concluido" )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetProfileID( 'CENMONJOB' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Monitor de JOBs", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If lAuto
		return oBrowse
	EndIf
	oBrowse:Activate()

Return oBrowse

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}

	aAdd( aRotina, { "SIP - Baixar desp. nao imp."	               , 'CenCpLogJb()'	     , 0 , 1 , 0 , .T. } )
	aAdd( aRotina, { "Visualizar"			                       , 'VIEWDEF.CENMONJOB' , 0 , 2 , 0 , Nil } ) //Visualizar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMANTB3V

Manutencao do monitor de jobs da central

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENMANTB3V(cCodOpe,cCodObri,cAnoComp,cCodComp,cTrirec,cTipo,cNomJob,cDescr,cObs,cDatExe,cHorExe,cStatus,aJOBs,lMV_PLCENDB)
	Local lIncluir	:= .T.
	Local cIdThre	:= ""
	Local cNomeLog	:= ""
	Default cCodOpe	:= ""
	Default cCodObri:= ""
	Default cAnoComp:= ""
	Default cCodComp:= ""
	Default cTrirec	:= ""
	Default cTipo	:= "1"//1-SIP
	Default	cNomJob	:= ""
	Default cDescr	:= ""
	Default cObs	:= ""
	Default cDatExe	:= DTOS(dDataBase)
	Default cHorExe	:= Time()
	Default cStatus	:= ""
	Default aJOBs	:= {}
	Default lMV_PLCENDB := MV_PLCENDB

	If PLSALIASEXI("B3V") .And. !Empty(RetSqlName("B3V")) .And. !Empty(cCodOpe) .And. IIF(cTipo $ '4/5',.T.,!Empty(cTriRec)) .And. !Empty(cTipo) .And. !Empty(cNomJob)

		aInfo := CENINFTHRD(@cObs,@cIdThre,cNomJob)
		Semaforo(.F.,"B3VSIP")
		cUltAlt := DTOS(DATE()) + " " + Time()

		lIncluir := !B3VExiste(cCodOpe,cCodObri,cAnoComp,cCodComp,cTriRec,cTipo,cNomJob,cDatExe,cHorExe)

		RecLock("B3V",lIncluir)

		If lIncluir
			B3V->B3V_FILIAL	:= xFilial("B3V")
			B3V->B3V_CODOPE	:= cCodOpe
			B3V->B3V_CODOBR	:= cCodObri
			B3V->B3V_ANOCMP	:= cAnoComp
			B3V->B3V_CDCOMP	:= cCodComp
			B3V->B3V_TRIREC	:= cTriRec
			B3V->B3V_TIPO	:= cTipo
			B3V->B3V_NOMJOB	:= cNomJob
			B3V->B3V_DESCRI	:= cDescr
			B3V->B3V_TEMPEX	:= ElapTime(cHorExe,Time())
			B3V->B3V_OBSERV	:= cObs
			B3V->B3V_IDTHRE	:= cIdThre
			B3V->B3V_ULTALT	:= cUltAlt
			B3V->B3V_DATEXE	:= STOD(cDatExe)
			B3V->B3V_HOREXE	:= cHorExe
			B3V->B3V_STATUS	:= cStatus

			If "PLSIPREE" $ cNomJob .Or. "PLSIPDES" $ cNomJob .Or. "PLSIPEXP" $ cNomJob
				If "PLSIPREE" $ cNomJob
					cNomeLog := ARQ_OCO_REE + AllTrim(cTriRec) + ".csv"
				ElseIf "PLSIPEXP" $ cNomJob
					cNomeLog := ARQ_OCO_EXP + AllTrim(cTriRec) + ".csv"
				Else
					cNomeLog := ARQ_OCORREN + AllTrim(cTriRec) + ".csv"
				EndIf
				CriaLogSIP(cNomeLog)
			EndIf
		Else
			B3V->B3V_TEMPEX	:= ElapTime(B3V->B3V_HOREXE,Time())
			B3V->B3V_OBSERV	:= cObs
			B3V->B3V_ULTALT	:= cUltAlt
			B3V->B3V_STATUS	:= cStatus
		EndIf

		B3V->(msUnLock())

		If cStatus == JOB_CONCLU
			CENNEXTJOB(cCodOpe,cCodObri,cAnoComp,cCodComp,cTrirec,cTipo,aJOBs)
		EndIf
		expiraJobs()
		Semaforo(.T.,"B3VSIP")

		If lMV_PLCENDB
			PlsLogFil(CENDTHRL("I") + " Job " + AllTrim(cNomJob) + " opcao " + cStatus ,ARQUIVO_LOG)
		EndIf

	EndIf//If !Empty(cCodOpe) .And. !Empty(cTriRec) .And. !Empty(cTipo) .And. !Empty(cNomJob)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENNOMJOB

Retorna o nome e descriacao dos jobs da central

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENNOMJOB(nThread,nQuinzena,cNomeAlias,lQryInter,cMesOco)
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local   aJobs       := {}
	Local   nI          := 0
	Default nThread		:= 1
	Default nQuinzena	:= 1
	Default cNomeAlias	:= ""
	Default lQryInter	:= .F.
	Default cMesOco		:= ""

	cNomJob := "NAOIDENTI(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")"
	cDesJob := "Nao identificado (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")"

	aAdd( aJobs,{"TRBDES",;
		"PLSIPDES(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" + Iif(lQryInter,"I","S"),;
		"Carga de Eventos x Despesas (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" + Iif(lQryInter," Internacao "," Servico ");
		})
	aAdd( aJobs,{"TRBCAP",;
		"PLSIPCAP(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" + Iif(lQryInter,"I","S"),;
		"Carga de Despesas de Capitacao (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" + Iif(lQryInter," Internacao "," Servico ");
		})
	aAdd( aJobs,{"TRBREE",;
		"PLSIPREE(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ") ",;
		"Carga de Reembolsos (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")";
		})
	aAdd( aJobs,{"TRBACU",;
		"PLSIPACU(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ") ",;
		"Carga de Alto Custo (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")";
		})
	aAdd( aJobs,{"TRBEXP",;
		"PLSIPEXP(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ") " ,;
		"Carga de Benef. Expostos (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")";
		})
	aAdd( aJobs,{"TRBB3Q",;
		"PLB3QB3L(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ") " ,;
		"Limpa tabela temporaria (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" ;
		})
	aAdd( aJobs,{"TRBTOT",;
		"PLSIPTOT(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ") " ,;
		"Cria registros totalizadores (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" ;
		})
	aAdd( aJobs,{"TRBCLA",;
		"CLAITESIP(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" ,;
		"Classifica itens Fs";
		})
	aAdd( aJobs,{"CLA" + cMesOco,;
		cNomeAlias + "(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")",;
		"Classifica Eventos x Despesas de " + cMesOco;
		})
	aAdd( aJobs,{"SNTDESSIP",;
		cNomeAlias + "(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")",;
		"Sintetiza Despesas";
		})
	aAdd( aJobs,{"SNTBENSIP",;
		cNomeAlias + "(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" ,;
		"Sintetiza Beneficiarios";
		})
	aAdd( aJobs,{"VLD" + cMesOco,;
		cNomeAlias,;
		"Valida Eventos x Despesas " + cMesOco;
		})
	aAdd( aJobs,{"PLSVLDPRO",;
		cNomeAlias + "(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")" ,;
		"Valida produtos / planos";
		})
	aAdd( aJobs,{"B" + cMesOco,;
		cNomeAlias + "(" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")",;
		"Valida beneficiarios";
		})
	nI := aScan(aJobs, { |x| AllTrim(x[1]) == AllTrim(cNomeAlias)})
	cNomJob := Iif(nI>0,aJobs[nI][2],cNomJob)
	cDesJob := Iif(nI>0,aJobs[nI][3],cDesJob)

Return {cNomJob,cDesJob}

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENINFTHRD

Retorna informacoes da thread para alimentar a tabela de jobs

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENINFTHRD(cObs,cIdThre,cNomJob)
	Local aInfJobPrc:= GetUserInfoArray()
	Local nInfo		:= 0
	Local cNome		:= AllTrim(SubStr(cNomJob,1,Len(cNomJob)-5))
	Default cObs	:= ""
	Default cIdThre	:= ""
	Default cNomJob	:= ""

	cIdThre	:= AllTrim(Str(ThreadId()))//AllTrim(Str(aInfJobPrc[nInfo,3]))

	If Empty(cIdThre)
		nInfo := aScan(aInfJobPrc,{ |x| AllTrim(x[5]) == cNome })
	Else
		nInfo := aScan(aInfJobPrc,{ |x| AllTrim(x[3]) == cIdThre })
	EndIf

	If nInfo > 0
		If Empty(cObs)
			cObs	:= aInfJobPrc[nInfo,11]
		EndIf
	EndIf
	CENCLSARR(aInfJobPrc)

Return {cObs,cIdThre}

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B3VExiste

Verifica se ja existe um registro da B3V

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function B3VExiste(cCodOpe,cCodObri,cAnoComp,cCodComp,cTriRec,cTipo,cNomJob,cDatExe,cHorExe)
	Local lRetorno	:= .F.
	Local cSql		:= ""
	Local cNomeArea	:= GetNextAlias()
	Default cCodOpe	:= ""
	Default cCodObri:= ""
	Default cAnoComp:= ""
	Default cCodComp:= ""
	Default cTriRec	:= ""
	Default cTipo	:= ""
	Default cNomJob	:= ""
	Default cDatExe	:= ""
	Default cHorExe	:= ""

	If PLSALIASEXI("B3V") .And. !Empty(RetSqlName("B3V"))
		cSql := " SELECT R_E_C_N_O_ REC "
		cSql += " FROM " + RetSqlName("B3V") + " "
		cSql += " WHERE "
		cSql += " B3V_FILIAL='" + xFilial("B3V") + "' "
		cSql += " AND B3V_CODOPE='" + cCodOpe + "' "
		cSql += " AND B3V_CODOBR='" + cCodObri + "' "
		cSql += " AND B3V_ANOCMP='" + cAnoComp + "' "
		cSql += " AND B3V_CDCOMP='" + cCodComp + "' "
		cSql += " AND B3V_TRIREC='" + cTriRec + "' "
		cSql += " AND B3V_TIPO='" + cTipo + "' "
		cSql += " AND B3V_NOMJOB='" + cNomJob + "' "
		cSql += " AND B3V_DATEXE='" + cDatExe + "' "
		cSql += " AND B3V_HOREXE='" + cHorExe + "' "
		cSql += " AND D_E_L_E_T_=' '"
		If CENCRIAALI(cSql,cNomeArea)
			lRetorno := .T.
			B3V->(dbGoTo((cNomeArea)->REC))
		EndIf

		(cNomeArea)->(dbCloseArea())
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Implementacao de semaforo para gravacao da tabela B3V

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(lLibera,cNome)
	Local nTry	:= 0
	If lLibera
		UnlockByName(cNome, .T., .T.)
	Else
		While !LockByName(cNome, .T., .T.)
			Sleep(1000)
			PtInternal(1,"Tentando abrir o semaforo " + cNome)
			If nTry % 10 == 0
				PlsLogFil(CENDTHRL("W") + " Tentando abrir o semaforo " + cNome,ARQUIVO_LOG)
			EndIf
			nTry++
		EndDo
	EndIf
Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENCLSARR

Funcao para destruir um array completamente

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CENCLSARR(aTemp)
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
/*/{Protheus.doc} CenCpLogJb

Copia o arquivo de log de despesas nao classificadas do servidor

@author everton.mateus
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenCpLogJb()
	Local cArqSrv	:= ""
	Local cMsg	:= ""
	Local cOk	:= ""
	Local cErro	:= ""
	Local nFor		:= 1

	If B3A->B3A_TIPO == '1'

		cPathLocal := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
		For nFor := 1 TO 3

			If nFor == 1
				cArqSrv := ARQ_OCO_REE + AllTrim(B3D->B3D_ANO) + SubStr(B3D->B3D_CODIGO,2,2) + ".csv"
			ElseIf nFor == 2
				cArqSrv := ARQ_OCO_EXP + AllTrim(B3D->B3D_ANO) + SubStr(B3D->B3D_CODIGO,2,2) + ".csv"
			Else
				cArqSrv := ARQ_OCORREN + AllTrim(B3D->B3D_ANO) + SubStr(B3D->B3D_CODIGO,2,2) + ".csv"
			EndIf

			If File(cArqSrv)
				If !Empty(cPathLocal)
					If CpyS2T(cArqSrv,cPathLocal,.T.,.F.)
						cOk += "Arquivo " + cArqSrv + " gravado em " + cPathLocal + CRLF
					Else
						cErro += "Nao foi possivel copiar o arquivo " + cArqSrv + " do servidor." + CRLF
					EndIf
				EndIf
			Else
				cErro += "O arquivo " + cArqSrv + " nao foi encontrado no servidor."
			EndIf

		Next nFor
		cMsg := cOk + cErro
		MsgInfo(cMsg)

	else

		MSGALERT( "Opção só disponível para obrigação do tipo SIP", "Aviso" )

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaLogSIP

Esta funcao cria o arquivo de log por trimestre de reconhecimento para o SIP

@author timoteo.bega
@since 14/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaLogSIP(cNomeLog)
	Local nNomeLog	:= 0
	Default cNomeLog :=  ARQ_OCORREN + "000000.csv"

	ExcluiArquivo(cNomeLog)

	If !File(cNomeLog)

		nNomeLog := FCreate(cNomeLog,0,,.F.)
		If nNomeLog < 0
			PlsLogFil(CENDTHRL("E") + " Nao foi possivel criar o arquivo " + cNomeLog,ARQUIVO_LOG)
		Else
			FClose(nNomeLog)
			EscreveCabecalhoSIP(cNomeLog)
		EndIf

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscreveCabecalhoSIP

Esta funcao cria o arquivo de log por trimestre de reconhecimento para o SIP

@author timoteo.bega
@since 14/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function EscreveCabecalhoSIP(cArquivo)
	Local nArquivo		:= 0
	Local cCabecalho	:= ""
	Default cArquivo	:= ""

	If File(cArquivo)

		nArquivo := FOpen(cArquivo,FO_WRITE)
		If nArquivo > 0

			If "Expostos" $ cArquivo
				cCabecalho := "FONTE DADOS;MATRICULA;TIPO GUIA;SOL. INTERNACAO;MOTIVO" + CRLF
			Else
				cCabecalho := "FONTE DADOS;OPERADORA;LOCAL;PROTOCOLO;NUMERO;ORIGEM MOV.;SEQUENCIA;TIPO GUIA;SOL. INTERNACAO;MOTIVO" + CRLF
			EndIf
			FWrite(nArquivo,cCabecalho)
			FClose(nArquivo)

		Else
			PlsLogFil("Nao foi possivel abrir o arquivo " + cArquivo,ARQUIVO_LOG)
		EndIf

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENWRLOGJB

Escreve no arquivo de ocorrencias dos jobs do SIP

@author timoteo.bega
@since 15/01/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CENWRLOGJB(cTriRec,cTxt,nRecur,cNomJob)
	Local cArquivo	:= ""
	Local nArquivo	:= 0
	Local aTxt		:= {}
	Local lExposto	:= "PLSIPEXP" $ cNomJob
	Default cTriRec	:= ""
	Default cTxt	:= ""
	Default nRecur	:= 0
	Default	lExposto:= .F.

	If "PLSIPREE" $ cNomJob
		cArquivo := ARQ_OCO_REE + AllTrim(cTriRec) + ".csv"
	ElseIf lExposto
		cArquivo := ARQ_OCO_EXP + AllTrim(cTriRec) + ".csv"
	Else
		cArquivo := ARQ_OCORREN + AllTrim(cTriRec) + ".csv"
	EndIf

	If !Empty(cTriRec) .And. !Empty(cTxt)

		nArquivo := FOpen(cArquivo,FO_READWRITE+FO_SHARED)

		If nArquivo > 0

			If !lExposto
				aTxt := StrTokArr(cTxt,";")
				cTxt := aTxt[1] + ";"//Fonte de dados
				cTxt += SubStr(aTxt[2],1,4) + ";"//Operadora
				cTxt += SubStr(aTxt[2],5,4) + ";"//Local
				cTxt += SubStr(aTxt[2],9,8) + ";"//Protocolo
				cTxt += SubStr(aTxt[2],17,8) + ";"//Numero
				cTxt += SubStr(aTxt[2],25,1) + ";"//Origem Mov.
				cTxt += SubStr(aTxt[2],26,3) + ";"//Sequencia
				cTxt += aTxt[3] + ";"//Tipo de guia
				cTxt += Iif(Len(aTxt) >= 4,aTxt[4]," ") + ";"//Sol. Internacao
				cTxt += Iif(Len(aTxt) >= 5,aTxt[5]," ")//Motivo
			EndIf

			FSeek(nArquivo,0,2)
			FWrite(nArquivo,cTxt + CRLF)
			FClose(nArquivo)
			cTxt := ""

		Else

			If nRecur < 5
				nRecur++
				Sleep(1000)
				CENWRLOGJB(cTriRec,cTxt,nRecur,cNomJob)
				PlsLogFil(CENDTHRL("I") + " Tentativa " + AllTrim(Str(nRecur)) + " de abrir o arquivo " + cArquivo ,ARQUIVO_LOG)
			EndIf
		EndIf

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENNEXTJOB

Verifica se existe algum job em execucao antes de liberar para iniciar o proximo

@author timoteo.bega
@since 15/01/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CENNEXTJOB(cCodOpe,cCodObri,cAnoComp,cCodComp,cTrirec,cTipo,aJOBs,nMSeg)//B3V_FILIAL+B3V_CODOPE+B3V_CODOBR+B3V_ANOCMP+B3V_CDCOMP+B3V_TRIREC+B3V_TIPO+B3V_NOMJOB+DTOS(B3V_DATEXE)+B3V_HOREXE
	Local lRetorno		:= .T.
	Local cSql			:= ""
	Local cJOBs			:= ""
	Local cNomeArea		:= GetNextAlias()
	Local nFor			:= 0
	Local cDatExe		:= DTOS(DATE())
	Default cCodOpe		:= ""
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default cTrirec		:= ""
	Default cTipo		:= ""
	Default aJOBs		:= {}
	Default nMSeg		:= 900000//15 minuto

	If !Empty(RetSqlName("B3V")) .And. !Empty(cCodOpe) .And. Len(aJOBs) > 0

		For nFor := 1 TO Len(aJOBs)

			If nFor == 1
				cJOBs := "'"
			EndIf

			cJOBs += AllTrim(aJOBs[nFor])

			If nFor < Len(aJOBs)
				cJOBs += "','"
			EndIf

			If nFor == Len(aJOBs)
				cJOBs += "'"
			EndIf

		Next nFor

		cSql := "SELECT R_E_C_N_O_ REC "
		cSql += " FROM " + RetSqlName("B3V") + " "
		cSql += " WHERE B3V_FILIAL = '" + xFilial("B3V") + "' AND B3V_CODOPE = '" + cCodOpe + "' "
		cSql += " AND B3V_CODOBR = '" + cCodObri + "' AND B3V_ANOCMP = '" + cAnoComp + "' "
		cSql += " AND B3V_CDCOMP = '" + cCodComp + "' AND B3V_TRIREC = '" + cTriRec + "' "
		cSql += " AND B3V_TIPO = '" + cTipo + "' AND B3V_NOMJOB IN (" + cJOBs + ") "
		cSql += " AND B3V_DATEXE = '" + cDatExe + "' AND B3V_STATUS <> '3' AND D_E_L_E_T_ = ' '"//Verifica se algum job ainda nao finalizou

		If CENCRIAALI(cSql,cNomeArea)
			lRetorno := .F.
		EndIf

		(cNomeArea)->(dbCloseArea())

		If !lRetorno
			Sleep(nMSeg)
			CENNEXTJOB(cCodOpe,cCodObri,cAnoComp,cCodComp,cTrirec,cTipo,aJOBs,nMSeg)
		EndIf

	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiArquivo

Se o arquivo de ocorrencia tiver sido criado antes de hoje, apaga o arquivo pois esta em outro processametno

@author timoteo.bega
@since 30/01/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExcluiArquivo(cArquivo)
	Local aArquivo		:= {}
	Local cPathSrv		:= GetSrvProfString("rootpath","")
	Default cArquivo	:= ""

	aArquivo := Directory(cArquivo,,,,2)

	If Len(aArquivo) > 0 .And. aArquivo[Len(aArquivo),3] != Date()
		If FErase(cPathSrv+cArquivo,1) == -1
			PlsLogFil(CENDTHRL("W") + " Nao foi possivel apagar o arquivo " + cArquivo ,ARQUIVO_LOG)
		Else
			Sleep(2000)//Espero dois segundos pra excluir o arquivo
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMONETP

Funcao criada para retornar o valor do campo virtual B3V_ETAPAS no painel de monitoramento de jobs

@author timoteo.bega
@since 12/02/2019
/*/
//--------------------------------------------------------------------------------------------------
FUNCTION CENMONETP()
	Local cNomJob	:= ""
	Local cEtapa	:= ""
	Local cAux		:= ""

	cNomJob	:= AllTrim(B3V->B3V_NOMJOB)
	cAux := SubStr(cNomJob,1,8)

	If cAux == "PLSIPDES"
		cEtapa := "Carga de Despesa"
	EndIf

	If Empty(cEtapa) .And. cAux == "PLSIPREE"
		cEtapa := "Carga de Reembolso"
	EndIf

	If Empty(cEtapa) .And. cAux == "PLSIPEXP"
		cEtapa := "Carga de Exposto"
	EndIf

	If Empty(cEtapa) .And. cAux == "PLSIPTOT"
		cEtapa := "Classificacao"
	EndIf

	If Empty(cEtapa) .And. cAux == "PLB3QB3L"
		cEtapa := "Classificacao"
	EndIf

	If Empty(cEtapa) .And. cAux == "SNTBENSI"
		cEtapa := "Totalizacao"
	EndIf

	If Empty(cEtapa) .And. cAux == "SNTDESSI"
		cEtapa := "Totalizacao"
	EndIf

	If Empty(cEtapa) .And. cAux == "JbCalDme"
		cEtapa := "Validações DMED"
	EndIf
	If Empty(cEtapa) .And. cAux == "JobPrcDm"
		cEtapa := "Processamento DMED"
	EndIf

	If Empty(cEtapa)

		cAux := SubStr(cNomJob,1,3)

		If cAux == "CLA"
			cEtapa := "Classificacao"
		ElseIf cAux == "VLD"
			cEtapa := "Validacao"
		Else

			cAux := SubStr(cNomJob,1,1)

			If cAux == "B"
				cEtapa := "Validacao"
			Else
				cEtapa := "Nao identificada"
			EndIf

		EndIf

	EndIf

Return cEtapa

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} expiraJobs

Expira jobs que estï¿½o inativos por mais de 2 horas

@author everton.mateus
@since 18/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function expiraJobs()
	Local cUpdate		:= ""
	Local cData:= AjusDtH()
	Local nRet := 0

	cUpdate := "UPDATE " + RetSqlName("B3V") + " "
	cUpdate += " SET B3V_STATUS = '3' "
	cUpdate += " ,B3V_OBSERV = 'Finalizado por inatividade' "
	cUpdate += " WHERE "
	cUpdate += " B3V_FILIAL = '" + xFilial("BD7") + "' "
	If Alltrim(Upper(TCGetDb())) $ "MSSQL/MSSQL7"
		cUpdate += " AND DATEDIFF(MINUTE, B3V_ULTALT,GETDATE()) >= 120 "
	Else
		cUpdate += " AND B3V_ULTALT <= '" + cData + "'  "
	EndIf
	cUpdate += " AND B3V_STATUS <> '3' "
	cUpdate += " AND D_E_L_E_T_ = ' '"

	nRet := TcSQLExec(cUpdate)
	If nRet >= 0
		TCSQLEXEC("COMMIT")
	EndIf

Return

Static Function AjusDtH()
	Local aData := {Date(),Time()}
	Local cData := ""

	If Val(Substr(aData[2],1,2)) >= 2
		aData[2]:=DecTime(aData[2],2)
		aData[1]:=dtos(aData[1])

	elseif Val(Substr(aData[2],1,2)) == 0
		aData[2]:="22:"+SubSTR(aData[2],4,2)+SubSTR(aData[2],6,3)
		aData[1]:=dtos(daySub(aData[1], 1))

	elseif Val(Substr(aData[2],1,2)) == 1
		aData[2]:="23:"+SubSTR(aData[2],4,2)+SubSTR(aData[2],6,3)
		aData[1]:=dtos(daySub(aData[1], 1))
	Else

		aData[1]:=dtos(aData[1])
	EndIf

	cData := aData[1] + " " + aData[2]

Return cData
//TESTE

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author p.drivas
@since 23/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStrB3V	:= FwFormStruct(1,'B3V')
	Local oModel

	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMONJOB',,)

	// Adiciona os campos no Model - Tipo Enchoice
	oModel:AddFields( 'B3VMASTER', NIL, oStrB3V )

	// Definição das Descrições
	oModel:SetDescription( "Monitor JOBS" )
	oModel:GetModel( 'B3VMASTER' ):SetDescription( "Monitor JOBS" )
	oModel:SetPrimaryKey( {"B3V_FILIAL","B3V_CODOPE","B3V_NOMJOB","B3V_CODOBR,B3V_ANOCMP,B3V_CDCOMP"} )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: Cria a VIEW da Rotina.
@author p.drivas
@since 23/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMONJOB' )
	Local oStruB3V 	:= FWFormStruct( 2, 'B3V' )
	Local oView    	:= FWFormView():New()

	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_B3V'	,oStruB3V,'B3VMASTER')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',100)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_B3V','CABEC')

	//Habilitando título
	oView:EnableTitleView('VIEW_B3V','Monitor JOBS')

	oView:SetCloseOnOk({|| .T.})

Return oView
