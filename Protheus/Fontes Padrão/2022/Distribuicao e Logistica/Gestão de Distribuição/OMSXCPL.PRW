#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "OMSXCPL.CH"
#include 'fileio.ch'

//Fonte responsável por agrupar as funções de envio de dados para o cockpit logístico...
#DEFINE CPL_SERVICE 1
#DEFINE CPL_INSERT 2
#DEFINE CPL_UPDATE 3
#DEFINE CPL_DELETE 4
#DEFINE CPL_XMLINS 5
#DEFINE CPL_TABELA 6

#DEFINE CPL_CAIXA 0
#DEFINE CPL_TUBO 1
#DEFINE CPL_BOBINA 2
#DEFINE CPL_LIQUIDO 3
#DEFINE CPL_INDEFINIDO 4

//Interno
Static _lFunTime := .F.// FindFunction("TimeGlbValue")

//Acessíveis externamente

//Lista de Unidades federativas reconhecidas até o momento
Static _aUfs := {"AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO"}
Static _cUfs := "AC,AL,AM,AP,BA,CE,DF,ES,GO,MA,MG,MS,MT,PA,PB,PE,PI,PR,RJ,RN,RO,RR,RS,SC,SE,SP,TO"

Static _aOMSXData
/*/{Protheus.doc} GetOmsxData
	Responsável por recupar um conteúdo de uma chave. Acessa o array estatico _aOMSXData,
	depende dos dados adicionados pela AddOmsxData. Neste formato, não há necessidade de declara variável estática ou uma classe.
	Returna nulo quando não encontra
@author siegklenes.beulke
@since 06/09/2016
@version 1.0
@param cChave, characters, Chave de pesquisa, se não informado, retorna o array inteiro
@example
(examples)
@see (links_or_references)
/*/
Function GetOmsxData(cChave)
Local xRet := Nil
Local nPos

	OsLogCPL("OMSXCPL -> GetOmsxData -> Inicio do metodo. Conteudo do parametro cChave: " + cValToChar(cChave),"INFO")

	If Empty(cChave)
		If Type("_aOMSXData") == "A"
			xRet := aClone(_aOMSXData)
		Else
			xRet := _aOMSXData
		EndIf
	Else
		If !Empty(_aOMSXData)
			nPos := aScan(_aOMSXData,{|x| x[1] == cChave})
			If nPos > 0
				xRet := _aOMSXData[nPos][2]
			EndIf
		EndIf
	EndIf

	OsLogCPL("OMSXCPL -> GetOmsxData -> Final do metodo. Conteudo do Return xRet: " + cValToChar(xRet),"INFO")

Return xRet
/*/{Protheus.doc} AddOmsxData
	Responsável por adicionar/atribuir dados no array estático.
@author siegklenes.beulke
@since 06/09/2016
@version 1.0
@param cChave, characters, Chave de relacionamento, utilizado pela GetOmsxData
@param xData, Qualquer, conteúdo a ser adicionado ou substituido
@example
(examples)
@see (links_or_references)
/*/
Function AddOmsxData(cChave,xData)
Local nPos

	OsLogCPL("OMSXCPL -> AddOmsxData -> Inicio do metodo. Conteudo do parametro cChave: " + ;
			 cValToChar(cChave) + " e parametro xData: " + cValToChar(xData),"INFO")

	If ValType(_aOMSXData) != "A"
		_aOMSXData := {}
	EndIf

	nPos := aScan(_aOMSXData,{|x| x[1] == cChave})
	If nPos > 0
		_aOMSXData[nPos][2] := xData
	Else
		aAdd(_aOMSXData, {cChave,xData} )
		nPos := Len(_aOMSXData)
	EndIf

	OsLogCPL("OMSXCPL -> AddOmsxData -> Final do metodo. Conteudo do Return xRet: " + cValToChar(nPos),"INFO")

Return nPos
/*/{Protheus.doc} ClrOmsxData
	Responsável por limpar o array estático.
@author siegklenes.beulke
@since 06/09/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function ClrOmsxData()
	If Type("_aOMSXData") == "A"
		aSize(_aOMSXData,0)
	Else
		_aOMSXData := Nil
	EndIf
Return
/*/{Protheus.doc} SetOmsxData
	Utilizado quando já possúi um array no formato {{"cChave",xConteudo}[,{"cChave",xConteudo}...]}}
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aArray, array, Array que irá substituir o array estático _aOMSXData
@example
(examples)
@see (links_or_references)
/*/
Function SetOmsxData(aArray)
	_aOMSXData := aClone(aArray)
Return

/*/{Protheus.doc} lTestouCon
	Variáveis de teste de conexão, uso de envio batch
	_lTestouCon, Indica se já houve teste de conexão
	_lConectou , Indica se já está conectado
	OMSXGETCON() Retorna se está conectado após teste de conexão
	OMSXCLRCON() Seta a limpeza da variável, para que numa próxima execução possa retestar a conexão
@author siegklenes.beulke
@since 06/09/2016
@example
(examples)
@see (links_or_references)
/*/
Static _lTestouCon := .F.
Static _lConectado := .F.

Function OMSXGETCON()
Return _lConectado

Function OMSXCLRCON()
	If !_lConectado
		_lTestouCon := .F.
	EndIf
Return

/*/{Protheus.doc} lRegFalha
	Variáveis de registro de falha, para indicar para a função que envia os dados que deve indicar a classe que grava registro de falha
	para não utilizar a tabela tradicional e realizar o tratamento internamente.
	_lRegFalha, Indica se deve registrar na tabela DJW o registro de falha.
	OMSXSETFAL(lFalha) seta se deverá gravar o registro de falha(.T.) na DJW ou não.
@author siegklenes.beulke
@since 06/09/2016
@example
(examples)
@see (links_or_references)
/*/
Static _lRegFalha := .T.

Function OMSXSETFAL(lFalha)
	_lRegFalha := lFalha
Return

/*/{Protheus.doc} OMSXJOBCAD
	Cadastra o consumo e a função passada cFunc como Job e reinicia job parados a determinado tempo.
	O Job consulta uma lista de pendências, consome e atualiza a lista.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cTabela, characters, Alias de tabela quando um registro ou array no formato {{"TAB",nRecno}[,{"TAB",nRecno}...]}
@param nOperacao, numeric, Operação a ser realizada (Inserção, atualização, exclusão)
@param cFunc, characters, Nome da Função que será chamada na execução do Job
@example
(examples)
@see (links_or_references)
/*/
Function OMSXJOBCAD(cTabela,nOperacao,cFunc)
	Local cJobs
	Local aJobs
	Local nX
	Local aThreads      := GetUserInfoArray()
	Local cEnvServer    := GetEnvServer()
	Local cComputerName := GetComputerName()

	Default cFunc := "OMSXDOJOB"

	OsLogCPL("OMSXCPL -> OMSXJOBCAD -> Inicio do metodo. Conteudo do parametro cTabela: " + cValToChar(cTabela) + ;
			" e parametro nOperacao: " + cValToChar(nOperacao) + ;
			" e parametro cFunc: " + cValToChar(cFunc),"INFO")

	While GetGlbValue(cEnvServer + CEMPANT + cFunc + "LOCK") == "T"
		SLEEP(66)
		If OMSXTEMPO( cEnvServer + CEMPANT + cFunc + "LOCK") > 10
			OMSXCLRGLB(cEnvServer + CEMPANT + cFunc + "LOCK")
			Exit
		EndIf
	EndDo

	OMSXPUTGLB(cEnvServer + CEMPANT  + cFunc + "LOCK","T")
	
	cJobs := GetGlbValue(cEnvServer + CEMPANT  + cFunc ) + ""

	OsLogCPL("OMSXCPL -> OMSXJOBCAD -> Conteudo da variavel cJobs antes de converter para array: " + cValToChar(cJobs), "INFO")

	If cJobs == Nil
		cJobs := ""
	EndIf
	aJobs := StrTokArr(cJobs,"}")
	If Len(aJobs) == 1 .And. Empty(aJobs[1])
		If ValType(cTabela) == "C"
			aJobs[1] := cTabela + "|" + cValToChar(nOperacao) + "|" + cValToChar((cTabela)->(RecNo())) + "|" + CFILANT
		Else
			aJobs[1] := cTabela[1][1] + "|" + cValToChar(nOperacao) + "|" + cValToChar(cTabela[1][2]) + "|" + CFILANT
			For nX := 2 To Len(cTabela)
				aAdd(aJobs,cTabela[nX][1] + "|" + cValToChar(nOperacao) + "|" + cValToChar(cTabela[nX][2]) + "|" + CFILANT )
			Next nX
		EndIf
	Else
		If ValType(cTabela) == "C"
			aAdd(aJobs,cTabela + "|" + cValToChar(nOperacao) + "|" + cValToChar((cTabela)->(RecNo())) + "|" + CFILANT )
		Else
			For nX := 1 To Len(cTabela)
				aAdd(aJobs,cTabela[nX][1] + "|" + cValToChar(nOperacao) + "|" + cValToChar(cTabela[nX][2]) + "|" + CFILANT )
			Next nX
		EndIf
	EndIf

	cJobs := ""

	For nX := 1 To Len(aJobs)
		If !Empty(aJobs[nX])
			cJobs += aJobs[nX] + '}'
		EndIf
	Next nX

	OsLogCPL("OMSXCPL -> OMSXJOBCAD -> Conteudo da variavel cJobs reconvertida para array: " + cValToChar(cJobs), "INFO")

	OMSXPUTGLB(cEnvServer + CEMPANT + cFunc , cJobs)
	OMSXPUTGLB(cEnvServer + CEMPANT + cFunc + "LOCK","F")

	nX := aScan(aThreads,{|x| x[2] == cComputerName .And. x[5] == cFunc .And. x[6] == cEnvServer})

	OsLogCPL("OMSXCPL -> OMSXJOBCAD -> Antes do IF para StartJob.","INFO")

	If nX == 0 .Or. OMSXTEMPO( cEnvServer + CEMPANT  + cFunc + "STARTED") == -1

		OsLogCPL("OMSXCPL -> OMSXJOBCAD -> IF validado com sucesso.","INFO")

		If OMSXTEMPO( cEnvServer + CEMPANT  + cFunc + "STARTED") > 900
			If !Empty(GetGlbValue(cEnvServer + CEMPANT  + cFunc + "STARTED"))
				aThread := StrTokArr(GetGlbValue(cEnvServer + CEMPANT  + cFunc + "STARTED"),"][")
				If !Empty(aThread) .And. Len(aThread) >= 4
					KillUser ( aThread[1], aThread[2], aThread[3], aThread[4] )
				EndIf
			EndIf
			OMSXCLRGLB( cEnvServer + CEMPANT  + cFunc + "STARTED")
		EndIf


		OsLogCPL("OMSXCPL -> OMSXJOBCAD -> Vai executar StartJob com cFunc: " + cValToChar(cFunc) + ;
			" e cEnvServer: " + cValToChar(cEnvServer) + ;
			" e CEMPANT: " + cValToChar(CEMPANT) + ;
			" e CFILANT: " + cValToChar(CFILANT) + ;
			" e cComputerName: " + cValToChar(cComputerName),"INFO")

		StartJob(cFunc ,cEnvServer, .F., CEMPANT, CFILANT, cEnvServer, cComputerName)
	EndIf

	OsLogCPL("OMSXCPL -> OMSXJOBCAD -> Final do metodo.","INFO")

Return
/*/{Protheus.doc} JobStarted
	Indica que o Job Iniciou
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cFunc, characters, Nome do Job
@param cEant, characters, Empresa do Job
@param cEServer, characters, Servidor do ambiente
@param cCName, characters, Nome do computador
@example
(examples)
@see (links_or_references)
/*/
Static Function JobStarted(cFunc,cEant,cEServer,cCName)
	Local aThreads

	OsLogCPL("OMSXCPL -> JobStarted -> Inicio do Metodo. Conteudo do parametro cFunc: " + cValToChar(cFunc) + ;
		" e parametro cEant: " + cValToChar(cEant) + ;
		" e parametro cEServer: " + cValToChar(cEServer) + ;
		" e parametro cCName: " + cValToChar(cCName),"INFO")

	aThreads := GetUserInfoArray()

	OsLogCPL("OMSXCPL -> JobStarted -> Conteudo da variavel aThreads: " + VarInfo("Array aThreads:",aThreads),"INFO")

	nX := aScan(aThreads,{|x| x[2] == cCName .And. x[5] == cFunc .And. x[6] == cEServer})
	OMSXPUTGLB(cEServer + cEant  + cFunc + "STARTED",aThreads[nX][1] + "][" + aThreads[nX][2] + "][" + cValToChar(aThreads[nX][3]) + "][" + aThreads[nX][4] + "][" )
	aSize(aThreads,0)

	OsLogCPL("OMSXCPL -> JobStarted -> Final metodo JobStarted.","INFO")

Return
/*/{Protheus.doc} VerifyJobs
	Recupera os afazeres do Job. Se alguma outra thread está atualizando/consumindo, aguarda o termino
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cFunc, characters, Nome do Job
@param cEant, characters, Empresa do Job
@param cEServer, characters, Servidor do ambiente
@example
(examples)
@see (links_or_references)
/*/
Static Function VerifyJobs(cFunc,cEant,cEServer)
	Local cJobs

	While GetGlbValue(cEServer + cEant  + cFunc + "LOCK") == "T"
		SLEEP(250)
		If OMSXTEMPO( cEServer + cEant  + cFunc + "LOCK") > 10
			OMSXCLRGLB(cEServer + cEant  + cFunc + "LOCK")
			Exit
		EndIf
	EndDo

	OMSXPUTGLB(cEServer + cEant  + cFunc + "LOCK","T")
	cJobs := GetGlbValue(cEServer + cEant  + cFunc)
Return cJobs
/*/{Protheus.doc} SetJobWorking
	Indica o status de Working do Job
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cFunc, characters, Nome do Job
@param cEant, characters, Empresa do Job
@param cEServer, characters, Servidor do ambiente
@param lWork, logical, Indica se irá iniciar seu afazeres ou se terminou seus afazeres
@param cInfo, characters, Variável "STARTED" Salva. o objetivo é atualizar a ultima iteração com a variável, quando lwork == .F.
@example
(examples)
@see (links_or_references)
/*/
Static Function SetJobWorking(cFunc,cEant,cEServer,lWork,cInfo)
	If lWork
		cInfo := GetGlbValue(cEServer + cEant  + cFunc + "STARTED")
		//OMSXCLRGLB( cEServer + cEant  + cFunc + "STARTED")
	Else
		OMSXPUTGLB(cEServer + cEant + cFunc + "STARTED",cInfo)
	EndIf
Return cInfo


//CEMPANT, CFILANT, cEnvServer, cComputerName
/*/{Protheus.doc} OMSXDOJOB
	Job responsável por envio assincrono de dados de cadastro
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cPar1, characters, CEMPANT
@param cPar2, characters, CFILANT
@param cPar3, characters, cEnvServer
@param cPar4, characters, cComputerName
@example
(examples)
@see (links_or_references)
/*/
Function OMSXDOJOB(cPar1,cPar2,cPar3,cPar4)
	Local cJobs
	Local aJobs
	Local aJob
	Local cTabela,nOperacao,nRecNo
	Local aReg
	Local nX
	Local cInfo
	Local cFunc := "OMSXDOJOB"
	Local nCount := 0

	OsLogCPL("OMSXCPL -> OMSXDOJOB -> Inicio do metodo. Conteudo do parametro cPar1: " + cValToChar(cPar1) + ;
			" e parametro cPar2: " + cValToChar(cPar2) + ;
			" e parametro cPar3: " + cValToChar(cPar3)+ ;
			" e parametro cPar4: " + cValToChar(cPar4),"INFO")

	If TMSWSInit({cPar1,cPar2},cFunc)
		JobStarted(cFunc,cPar1,cPar3,cPar4)
		While .T.
			cJobs := VerifyJobs(cFunc,cPar1,cPar3)
			cInfo := SetJobWorking(cFunc,cPar1,cPar3,.T.)
			If !EmptY(cJobs)

				aJobs := StrTokArr(cJobs,"}")
				aReg  := StrTokArr(aJobs[Len(aJobs)],"|")
				cTabela := aReg[1]
				nOperacao := Val(aReg[2])
				nRecNo := Val(aReg[3])
				CFILANT := aReg[4]
				aDel(aJobs,Len(aJobs))
				cJobs := ""

				For nX := 1 To Len(aJobs)

					If aJobs[nX] != Nil
						aJob := StrTokArr(aJobs[nX],"|")
						If aJob[1] != aReg[1] .Or. aJob[2] != aReg[2] .Or. aJob[3] != aReg[3] .Or. aJob[4] != aReg[4]
							cJobs += aJobs[nX] + '}'
						EndIf
					EndIf
				Next nX

				aSize(aReg,0)

				OMSXPUTGLB(cPar3 + cPar1  + cFunc ,cJobs)
				OMSXPUTGLB(cPar3 + cPar1  + cFunc + "LOCK","F")

				dbSelectArea(cTabela)
				(cTabela)->(dbGoTo(nRecNo))
				If !OMSXCPLENVIA(cTabela,nOperacao) .And. !OMSXGETCON()
					OMSXCLRCON()
				EndIf

				If !Empty(cJobs)
					Loop
				EndIf
			Else
				OMSXPUTGLB(cPar3 + cPar1 + cFunc + "LOCK","F")
			EndIf
			SetJobWorking(cFunc,cPar1,cPar3,.F.,cInfo)
			nCount := nCount + 1
			If nCount >= 5
				Exit
			EndIf
			Sleep(500)
		EndDo
	EndIf

	OsLogCPL("OMSXCPL -> OMSXDOJOB -> Final metodo OMSXDOJOB.","INFO")
Return

/*/{Protheus.doc} TMSXDOJOB
	Job responsável por gerar viagem no TMS e liberar viagem no Cockpit Logístico
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cPar1, characters, CEMPANT
@param cPar2, characters, CFILANT
@param cPar3, characters, cEnvServer
@param cPar4, characters, cComputerName
@example
(examples)
@see (links_or_references)
/*/

Function TMSXDOJOB(cPar1,cPar2,cPar3,cPar4)
	Local cJobs
	Local aJobs
	Local aJob
	Local cTabela,nOperacao,nRecNo
	Local aReg
	Local nX
	Local cInfo
	Local cFunc := "TMSXDOJOB"

	OsLogCPL("OMSXCPL -> TMSXDOJOB -> Inicio do metodo. Conteudo do parametro cPar1: " + cValToChar(cPar1) + ;
		" e parametro cPar2: " + cValToChar(cPar2) + ;
		" e parametro cPar3: " + cValToChar(cPar3)+ ;
		" e parametro cPar4: " + cValToChar(cPar4),"INFO")

	If TMSWSInit({cPar1,cPar2},cFunc)
		JobStarted(cFunc,cPar1,cPar3,cPar4)
		While .T.
			cJobs := VerifyJobs(cFunc,cPar1,cPar3)
			cInfo := SetJobWorking(cFunc,cPar1,cPar3,.T.)
			If !EmptY(cJobs)

				aJobs := StrTokArr(cJobs,"}")
				aReg  := StrTokArr(aJobs[Len(aJobs)],"|")
				cTabela := aReg[1]
				nOperacao := Val(aReg[2])
				nRecNo := Val(aReg[3])
				CFILANT := aReg[4]
				aDel(aJobs,Len(aJobs))
				cJobs := ""

				For nX := 1 To Len(aJobs)

					If aJobs[nX] != Nil
						aJob := StrTokArr(aJobs[nX],"|")
						If aJob[1] != aReg[1] .Or. aJob[2] != aReg[2] .Or. aJob[3] != aReg[3] .Or. aJob[4] != aReg[4]
							cJobs += aJobs[nX] + '}'
						EndIf
					EndIf
				Next nX

				aSize(aReg,0)
				OMSXPUTGLB(cPar3 + cPar1  + cFunc ,cJobs)
				OMSXPUTGLB(cPar3 + cPar1  + cFunc + "LOCK","F")

				dbSelectArea(cTabela)
				(cTabela)->(dbGoTo(nRecNo))
				INCLUI := .F.
				ALTERA := .T.
				If !OMSXGETCON()
					OMSXCLRCON()
				EndIf
				If !Empty(cJobs)
					Loop
				EndIf
			Else
				OMSXPUTGLB(cPar3 + cPar1 + cFunc + "LOCK","F")
			EndIf
			SetJobWorking(cFunc,cPar1,cPar3,.F.,cInfo)
			Sleep(500)
		EndDo
	EndIf
	OsLogCPL("OMSXCPL -> TMSXDOJOB -> Final metodo TMSXDOJOB.","INFO")

Return

/*/{Protheus.doc} TMSXDOCAN
	Job responsável por cancelar documentos de viagem sendo canceladas pelo cockpit.
	Possui caracteristica de execução atrasada, que seria o aguardo do cancelamente da viagem concluir no Cockpit Logístico.
	Caso não consiga desatualizar o documento, adiciona para o reenvio no final da fila
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cPar1, characters, CEMPANT
@param cPar2, characters, CFILANT
@param cPar3, characters, cEnvServer
@param cPar4, characters, cComputerName
@example
(examples)
@see (links_or_references)
/*/
Function TMSXDOCAN(cPar1,cPar2,cPar3,cPar4)
	Local cJobs
	Local aJobs
	Local aJob
	Local cTabela,nOperacao,nRecNo
	Local aReg
	Local nX
	Local cInfo
	Local cFunc := "TMSXDOCAN"

	OsLogCPL("OMSXCPL -> TMSXDOCAN -> Inicio do metodo. Conteudo do parametro cPar1: " + cValToChar(cPar1) + ;
	" e parametro cPar2: " + cValToChar(cPar2) + ;
	" e parametro cPar3: " + cValToChar(cPar3)+ ;
	" e parametro cPar4: " + cValToChar(cPar4),"INFO")

	If TMSWSInit({cPar1,cPar2},cFunc)
		JobStarted(cFunc,cPar1,cPar3,cPar4)
		While .T.
			Sleep(900)
			cJobs := VerifyJobs(cFunc,cPar1,cPar3)
			cInfo := SetJobWorking(cFunc,cPar1,cPar3,.T.)
			While !EmptY(cJobs)

				aJobs := StrTokArr(cJobs,"}")
				aReg  := StrTokArr(aJobs[Len(aJobs)],"|")
				cTabela := aReg[1]
				nOperacao := Val(aReg[2])
				nRecNo := Val(aReg[3])
				CFILANT := aReg[4]
				aDel(aJobs,Len(aJobs))
				cJobs := ""

				For nX := 1 To Len(aJobs)

					If aJobs[nX] != Nil
						aJob := StrTokArr(aJobs[nX],"|")
						If aJob[1] != aReg[1] .Or. aJob[2] != aReg[2] .Or. aJob[3] != aReg[3] .Or. aJob[4] != aReg[4]
							cJobs += aJobs[nX] + '}'
						EndIf
					EndIf
				Next nX

				OMSXPUTGLB(cPar3 + cPar1  + cFunc ,cJobs)
				OMSXPUTGLB(cPar3 + cPar1  + cFunc + "LOCK","F")

				dbSelectArea(cTabela)
				(cTabela)->(dbGoTo(nRecNo))
				If !OMSXCPLENVIA(cTabela,nOperacao)
					cJobs := VerifyJobs(cFunc,cPar1,cPar3)
					cInfo := SetJobWorking(cFunc,cPar1,cPar3,.T.)
					If !(aReg[1] + "|" + aReg[2] + "|" + aReg[3] + "|" + aReg[4] $ cJobs)
						cJobs += aReg[1] + "|" + aReg[2] + "|" + aReg[3] + "|" + aReg[4] + "}"
					EndIf
					OMSXPUTGLB(cPar3 + cPar1  + cFunc ,cJobs)
					OMSXPUTGLB(cPar3 + cPar1  + cFunc + "LOCK","F")
				EndIf
				If !OMSXGETCON()
					OMSXCLRCON()
				EndIf

				aSize(aReg,0)

			EndDo

			OMSXPUTGLB(cPar3 + cPar1 + cFunc + "LOCK","F")
			SetJobWorking(cFunc,cPar1,cPar3,.F.,cInfo)
			Sleep(500)
		EndDo
	EndIf

	OsLogCPL("OMSXCPL -> TMSXDOCAN -> Final metodo TMSXDOCAN.","INFO")
Return

Function OMGETTOKEN(lMErro,cFalha)
	Local cUsr
	Local cPsw
	Local cUrlAuth := SuperGetMv("MV_CPLUAUT",.F.,"")
	Local cToken   := AllTrim(GetMv("MV_TOKCPL",.F.,""))
	Local cDataHr  :=  GetMv("MV_DTTOK",.F.,"")
	Local dData	   := Date()	
	Local cHora
	Local nTempoPar := GetMv("MV_EXPTOK",.F.,"")
	Local nTempo
	Local nHoras
	Local nMinutos
	Local nSegundos
	Local aDataHora := StrTokArr(cDataHr,"-")
	Default lMErro := .T. 
	Default cFalha := ""

	OsLogCPL("OMSXCPL -> OMGETTOKEN -> Inicio do metodo. Conteudo do parametro lMErro: " + cValToChar(lMErro) + ;
			" e parametro cFalha: " + cValToChar(cFalha),"INFO")

	If Empty(cUrlAuth)
		Return ""
	EndIf

	If !Empty(aDataHora) .And. Len(aDataHora) == 2

		If nTempoPar >= 24
			nTempo := (Mod(nTempoPar,24))
		EndIf

		//Validação de Data e Hora de Validade do Token
		If dData <> CTOD(aDataHora[1])
			cToken := "" //Expirou token 
		Else
			cHora := TIME()
			nHoras    := Val(SubStr(cHora,1,2))
			nMinutos  := Val(SubStr(cHora,4,2))
			nSegundos := Val(SubStr(cHora,7,2))
			nTempo := nHoras*3600 + nMinutos*60 + nSegundos

			cHora := aDataHora[2]
			nHoras    := Val(SubStr(cHora,1,2))
			nMinutos  := Val(SubStr(cHora,4,2))
			nSegundos := Val(SubStr(cHora,7,2))

			If ABS( (nTempo - (nHoras*3600 + nMinutos*60 + nSegundos)) / 3600 ) >= nTempoPar
				cToken := "" //Expirou o token
			EndIf
		EndIf
	Else
		aDataHora := {}
	EndIf

	If Empty(cToken) .Or. Empty(aDataHora)
		cUsr := StrTran(SuperGetMv("MV_USRCPL",.F.,"")," ","")
		cPsw := AllTrim(SuperGetMv("MV_PSWCPL",.F.,""))
	EndIf

	If !Empty(cUsr) .And. !Empty(cPsw)
		cToken := OMCPLBuscaToken(cUrlAuth,cUsr,cPsw,lMErro,@cFalha)
		PutMv("MV_TOKCPL",cToken)
		PutMv("MV_DTTOK",DTOC(DATE()) + '-' + TIME())
	EndIf

	OsLogCPL("OMSXCPL -> OMGETTOKEN -> Final metodo OMGETTOKEN. Return do Token cToken: " + cValToChar(cToken),"INFO")

Return cToken

Function OMCPLBuscaToken(cUrlAuth,cUsr,cPsw,lMErro,cFalha)
	Local cToken
	Local cXMLPostRet
	Local cSoapSend
	Local XMLHeadRet
	Local aHeadOut
	Local lRet := .T.
	Default lMErro := .T.
	Default cFalha := ""

	OsLogCPL("OMSXCPL -> OMCPLBuscaToken -> Inicio do metodo. Conteudo do parametro lMErro: " + cValToChar(lMErro) + ;
			" e parametro cFalha: " + cValToChar(cFalha),"INFO")
	
	aHeadOut  := {'Content-Type: text/xml;charset=utf-8','SOAPAction: ""','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
	XMLHeadRet:= ""

	cSoapSend := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:aut="http://www.neolog.com.br/cpl/gateway/authentication/">'
	cSoapSend += '<soapenv:Header/>'
	cSoapSend += '<soapenv:Body>'
	cSoapSend += '<aut:credentials>'
	cSoapSend += '<username>' + cUsr + '</username>'
	cSoapSend += '<password>' + cPsw + '</password>'
	cSoapSend += '</aut:credentials>'
	cSoapSend += '</soapenv:Body>'
	cSoapSend += '</soapenv:Envelope>'

	cXMLPostRet := HTTPSPost(AllTrim(cUrlAuth), "", "", "", "", cSoapSend, 30, aHeadOut, @XMLHeadRet)

	If Empty(cXMLPostRet)
		cFalha := STR0018
		lRet := .F. 
	EndIf
	If lRet 
		oXmlSoap := XmlParser ( cXMLPostRet, "", "", "")
		If Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS3_AUTHENTICATIONTOKEN") == "O"
			oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS3_AUTHENTICATIONTOKEN
		ElseIf Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_AUTHENTICATIONTOKEN") == "O"
			oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_AUTHENTICATIONTOKEN
		ElseIf Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_AUTHENTICATIONTOKEN") == "O"
			oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_AUTHENTICATIONTOKEN
		ElseIf Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_AUTHENTICATIONTOKEN") == "O"
			oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_AUTHENTICATIONTOKEN
		Else
			cFalha := STR0018
			lRet := .F. 
		EndIf
	EndIf

	If lRet 
		If Type("oToken:_SUCCESSFUL") == "O"
			If UPPER(oToken:_SUCCESSFUL:TEXT) == "TRUE"
				cToken := oToken:_TOKEN:TEXT
			Else
				cFalha := STR0018
				lRet := .F. 
			EndIf
		Else
			cFalha := STR0018
			lRet := .F. 
		EndIf 
	EndIf
	If !lRet
		cToken := ""	
		If lMErro
			MsgAlert(cFalha)
		EndIf
	EndIf

	OsLogCPL("OMSXCPL -> OMCPLBuscaToken -> Final metodo OMCPLBuscaToken. Return do Token cToken: " + cValToChar(cToken),"INFO")

Return cToken

Function CPLENVBATCH(cTabela,nOperacao)
Return OMSXCPLENVIA(cTabela,nOperacao)
/*/{Protheus.doc} OMSXCPLENVIA
	Responsável por enviar o registro para o CPL. Necessita do registro posicionado.
	Ignora requisições não suportadas;
	Configura o cliente de WebService
	Registra falha de conexão/transmissão;
	Registra xml enviado em caso de debug ativo;

@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cTabela, characters, Alias da Tabela
@param nOperacao, numeric, Operação de dados a ser executada
@param lConectado, logical, se não deve testar a conexão (uso CPLENVBATCH)
@param lBatch, logical, descricao, se foi executado pelo CPLENVBATCH
@param cSeqInt, characters, sequência de integração do pedido
@param oTabTemp, object, tabela temporária que contém os registros
@param cFalha, characters, variável para o retorno da falha ocorrida
@param cQuebraId, characters, id da quebra do Cockpit
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPLENVIA(cTabela,nOperacao,cSeqInt,oTabTemp,cFalha,cQuebraId,lMErro)
Local lEnviou   := .F.
Local aAreaTmp  := {}
Local oWsCpl    := Nil
Local aConfig   := {}
Local oData     := Nil
Local aList     := {}
Local nX        := 0
Local cOperacao := ""
Local lOMSCPL02 := ExistBlock("OMSCPL02")
Local lRetPe02 	:=.T.
Default cSeqInt   := ""
Default cFalha    := ""
Default oTabTemp  := Nil
Default lMErro    := .T.

	OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Inicio do metodo.","INFO")

	BEGIN WSMETHOD
		// Valida se a mensagem possui operação de exclusão
		If nOperacao == MODEL_OPERATION_DELETE
			aList := OMSXCPLLIST()
			nX := aScan(aList,{|x| cTabela $ x[CPL_TABELA]})
			If nX > 0
				cOperacao := aList[nX][CPL_DELETE]
			EndIf
			// Se não existir a operação de delete, não faz nada
			If Empty(cOperacao)
				Return .T.
			EndIf
		EndIf

		// Valida se uma operação é suportada pela integração
		If !( (nOperacao == MODEL_OPERATION_INSERT) .Or.;
				(nOperacao == MODEL_OPERATION_UPDATE) .Or.;
				(nOperacao == MODEL_OPERATION_DELETE) )
			MsgInfo(STR0009) // "Modo de operação não suportado"
			Return .F.
		EndIf

		// Valida se a integração com o CPL está ativa
		If IntegSusp(cTabela,nOperacao)
			OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Integracao suspensa.","INFO")
			Return .F.
		EndIf

		//ponto para controlar se deve ou não continuar com a integração
		If lOMSCPL02
			lRetPe02 := ExecBlock( "OMSCPL02", .F., .F., {cTabela,nOperacao})
			If !lRetPe02
				OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Condicao do ponto de entrada OMSCPL02 retornou FALSE.","INFO")
				Return .F.
			EndIf
		EndIf

		// Verifica se consegue estabelecer uma conexão com o CPL
		Private _MV_CPLURL := SuperGetMv("MV_CPLURL",.F.,"")
		If !_lTestouCon
			Private cRetCPLWST := ""
			_lConectado := OMSXCPLWST(_MV_CPLURL,.F.,,,,lMErro,@cFalha)
			If !_lConectado
				OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Conexao nao estabelecida.","INFO")

				oData := OMSXCPL3CLS():New()

				oData:lDjw := _lRegFalha

				oData:ACAO := If(nOperacao == MODEL_OPERATION_DELETE,'2','1')

				If IsBlind()
					oData:USRREG := "ENVBATCH POR JOB"
				EndIf

				If (cTabela)->(IndexOrd()) != 1
					aAreaTmp := (cTabela)->(GetArea())
					(cTabela)->(dbSetOrder(1))
				EndIf

				oData:TABELA := cTabela
				oData:CHAVE  := (cTabela)->(&((cTabela)->(IndexKey())))

				If !Empty(aAreaTmp)
					RestArea(aAreaTmp)
				EndIf

				oData:RECTAB := (cTabela)->(RecNo())

				OMSXCPL3REG(oData,cRetCPLWST)
				FreeObj(oData)
				
				cFalha :=  OmsFmtMsg(STR0026,{{"[VAR01]",_MV_CPLURL}}); //CPLERR01 - Não foi possível se comunicar com o endereço de webservice [VAR01].
				+ cFalha + STR0027 //" Para obter mais informações, consulte o help (F1) da rotina. "

				// Se não conseguiu uma conexão retorna falso
				Return .F.
			Else
				_lTestouCon := .T.
				OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Conexao estabelecida.","INFO")
			EndIf
		EndIf

		Private _MV_CPLCAT := SuperGetMv("MV_CPLCAT",.F.,"2")
		Private _MV_CPLIDS := StrTrim(SuperGetMv("MV_CPLIDS",.F.,"PROTHEUS"),30)
		Private _MV_CPLTP1 := StrTrim(SuperGetMv("MV_CPLTP1",.F.,""),30)
		Private _MV_CPLTP2 := StrTrim(SuperGetMv("MV_CPLTP2",.F.,""),30)
		Private _MV_CPLTP3 := StrTrim(SuperGetMv("MV_CPLTP3",.F.,""),30)
		Private _MV_CPLINV := SuperGetMv("MV_CPLINV",.F.,"")
		Private _MV_CPLREG := StrTrim(SuperGetMv("MV_CPLREG",.F.,""),30)
		Private _MV_CPLEMB := StrTrim(SuperGetMv("MV_CPLEMB",.F.,""),255)
		Private _MV_CPLENT := SuperGetMv("MV_CPLENT",.F.,"2")

		oWsCpl := OMSXCPLWS():New()
		oWsCpl:SetUrl(_MV_CPLURL)
		oWsCpl:SetTabela(cTabela)

		Do Case

			Case cTabela == "DUT"
				// Consultar OMSXCPL01.PRW
				aConfig := OMSXCPLLIST()[2]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				TMSXADDDUT(oWsCpl)

			Case cTabela == "SB1"
				aConfig := OMSXCPLLIST()[3]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDSB1(oWsCpl,nOperacao)

			Case cTabela == "SB5"
				aConfig := OMSXCPLLIST()[3]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDSB5(oWsCpl,nOperacao)

			Case cTabela == "SA1"
				aConfig := OMSXCPLLIST()[4]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDSA1(oWsCpl)

			Case cTabela == "SA2"
				If !Empty(SA2->A2_TRANSP) .Or. !Empty(SA2->A2_RNTRC) .Or. (SA2->A2_PAGGFE == "1")
					aConfig := OMSXCPLLIST()[5]
					WsCplConf(oWsCpl, aConfig, nOperacao)
					OMSXSA2CAR(oWsCpl)
				Else
					aConfig := OMSXCPLLIST()[4]
					WsCplConf(oWsCpl, aConfig, nOperacao)
					OMSXSA2LOC(oWsCpl)
				Endif

			Case cTabela == "SA4"
				aConfig := OMSXCPLLIST()[5]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDSA4(oWsCpl) // Adiciona a string soap da transportadora posicionado

			Case cTabela == "DUL"
				aConfig := OMSXCPLLIST()[4]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDDUL(oWsCpl) // Adiciona a string soap do solicitante posicionado

			Case cTabela == "DUE"
				aConfig := OMSXCPLLIST()[4]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDDUE(oWsCpl) // Adiciona a string soap do solicitante posicionado

			Case cTabela == "SM0"
				aConfig := OMSXCPLLIST()[4]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDSM0(oWsCpl)

			Case cTabela == "DUD"
				aConfig := OMSXCPLLIST()[6]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				TMSXADDDUD(oWsCpl, nOperacao)

			Case cTabela == "SC5"
				aConfig := OMSXCPLLIST()[6]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXADDSC5(oWsCpl,nOperacao,cSeqInt,oTabTemp,cQuebraId) // Adiciona a string soap os dados do pedido posicionado
			Case cTabela == "DJZ"
				aConfig := OMSXCPLLIST()[7]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				TMSXLIBDJZ(oWsCpl) // Adiciona a string soap os dados da viagem posicionada

			Case cTabela == "DK0"
				aConfig := OMSXCPLLIST()[7]
				WsCplConf(oWsCpl, aConfig, nOperacao)
				OMSXLIBDK0(oWsCpl) // Adiciona a string soap os dados da viagem posicionada

			Otherwise
				MsgInfo(STR0015 + cTabela + STR0016) // "Tabela " ## " não implementada"
				Return .F.
		EndCase

        oWsCpl:SetMErroTk(lMErro)

		OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Tentativa de envio.","INFO")

		oWsCpl:lSucesso := oWsCpl:Envia()

		OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Resultado do envio: " + Iif(oWsCpl:lSucesso, "true", "false"),"INFO")

		If (cTabela)->(IndexOrd()) != 1
			aAreaTmp := (cTabela)->(GetArea())
			(cTabela)->(dbSetOrder(1))
		EndIf

		If !Empty(aAreaTmp)
			RestArea(aAreaTmp)
		EndIf

		aAreaTmp := {}

		If !(lEnviou := oWsCpl:lSucesso)
			cFalha := oWsCpl:cMsgRet
			OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> cFalha: "+cFalha,"INFO")
		EndIf
	END WSMETHOD

	OsLogCPL("OMSXCPL -> OMSXCPLENVIA -> Final do metodo.","INFO")

Return lEnviou

/*/{Protheus.doc} OMSXADDSB1
Adiciona o xml de um produto posicionado 'SB1' para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
@param nOperacao, numeric, Operação de dados a ser executada
/*/
Static Function OMSXADDSB1(oWsCpl,nOperacao)
Local cCodFil      := OMSXGETFIL("SB1")
Local nAltura      := Nil
Local nLargura     := Nil
Local nComprimento := Nil
Local nDimPadrao   := 0.001
Local nFatorKG     := 1
Local nPeso        := 0
Local lIntPrd2UM   := (SuperGetMv("MV_CPLUMIT",.F.,"1") == "2") // Indica a UM do produto a ser considerada na integração com o CPL

	OsLogCPL("OMSXCPL -> OMSXADDSB1 -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<product>")
	oWsCpl:AddSoap("<products>")
	oWsCpl:AddSoap("<product>")

	oWsCpl:AddSoap(RegionSourceId())
	oWsCpl:AddSoap(ShipperId())
	// Importante manter a mesma regra do envio de pedidos de venda
	oWsCpl:AddSoap(WSSoapValue("identifier", StrTrim(RTrim(SB1->B1_COD) + cCodFil,30), StrTrim(RTrim(SB1->B1_COD) + cCodFil,30) , "string", .F. , .F., 0 , NIL, .F.)   )
	If nOperacao != MODEL_OPERATION_DELETE
		SB5->(DbSetOrder(1))
		If SB5->(dbSeek(xFilial("SB5") + SB1->B1_COD))
			nAltura      := Iif( SB5->B5_ALTURLC == 0, Nil, SB5->B5_ALTURLC )
			nLargura     := Iif( SB5->B5_LARGLC == 0, Nil, SB5->B5_LARGLC)
			nComprimento := Iif( SB5->B5_COMPRLC == 0, Nil, SB5->B5_COMPRLC )
		EndIf
		oWsCpl:AddSoap(WSSoapValue("description", SB1->B1_DESC, SB1->B1_DESC , "string", .F. , .F., 0 , NIL, .F.)                        )
		oWsCpl:AddSoap(WSSoapValue("height", nDimPadrao , nAltura, "double", .F. , .F., 0 , NIL, .F.)                                    )
		oWsCpl:AddSoap(WSSoapValue("length", nDimPadrao, nComprimento,  "double", .F. , .F., 0 , NIL, .F.)                               )
		oWsCpl:AddSoap(WSSoapValue("width", nDimPadrao, nLargura , "double", .F. , .F., 0 , NIL, .F.)                                    )

		If !Empty(SB1->B1_GRUPO) .And. _MV_CPLCAT == "1"
			oWsCpl:AddSoap(WSSoapValue("productCategoryId", SB1->B1_GRUPO, SB1->B1_GRUPO , "string", .F. , .F., 0 , NIL, .F.))
		EndIf

		oWsCpl:AddSoap(WSSoapValue("shape", CPL_CAIXA, CPL_CAIXA , "int", .F. , .F., 0 , NIL, .F.))
		
		//Verifica se possuí fator de conversão para KG
		If TableInDic("DK2", .F.)
			DK2->(DbSetOrder(1))
			If DK2->(DbSeek(xFilial('DK2')+SB1->B1_UM))
				nFatorKG := DK2->DK2_PESOKG
			EndIf
		EndIf
		
		nPeso := IIf(SuperGetMv("MV_PESOCAR",.F.,"L") == "L",SB1->B1_PESO,SB1->B1_PESBRU)
		
		// Se estiver parametrizado para considerar a 2a UM e tiver preenchido fator de conversão
		If lIntPrd2UM .And. SB1->B1_CONV > 0
			// Deve calcular o peso com base na segunda UM do produto, já que o CPL só recebe uma única UM
			If SB1->B1_TIPCONV == "D"
				nPeso := nPeso * nFatorKG * SB1->B1_CONV
			Else
				nPeso := (nPeso * nFatorKG) / SB1->B1_CONV
			EndIf
		Else
			nPeso := nPeso * nFatorKG
		EndIf

		oWsCpl:AddSoap(WSSoapValue("weight", nDimPadrao, IIf(Empty(nPeso),Nil,nPeso) , "double", .F. , .F., 0 , NIL, .F.))
	EndIf

	oWsCpl:AddSoap("</product>")
	oWsCpl:AddSoap("</products>")
	oWsCpl:AddSoap("</product>")

	OsLogCPL("OMSXCPL -> OMSXADDSB1 -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXADDSB5
Adiciona o xml de um produto posicionado 'SB5' para enviar ao CPL
@author Squad OMS
@since  04/02/2019
@param  oWsCpl, object, Cliente de webservice compativel
@param  nOperacao, numeric, Operação de dados a ser executada
/*/
Static Function OMSXADDSB5(oWsCpl,nOperacao)

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+SB5->B5_COD))
		OMSXADDSB1(oWsCpl,nOperacao)
	EndIf

Return

/*/{Protheus.doc} OMSXADDSM0
Adiciona o xml de uma filial posicionada 'SM0' para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Static Function OMSXADDSM0(oWsCpl)
Local cCodFil   := ""
Local cCodLocal := ""
Local aEndEnt   := {}

	OsLogCPL("OMSXCPL -> OMSXADDSM0 -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<localities>")
	oWsCpl:AddSoap("<locality>")
	oWsCpl:AddSoap(RegionSourceId())

	If Empty(OsCplEmpDef())
		cCodFil := SM0->M0_CODIGO+"-"+PadR(SM0->M0_CODFIL,FwSizeFilial())
	Else
		cCodFil := PadR(SM0->M0_CODFIL,FwSizeFilial())
	EndIf
	cCodLocal := "FIL-" + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("name", SM0->M0_FILIAL, SM0->M0_FILIAL , "string", .F. , .F., 0 , NIL, .F.)                                   )
	oWsCpl:AddSoap(WSSoapValue("description", SM0->M0_NOMECOM, SM0->M0_NOMECOM , "string", .F. , .F., 0 , NIL, .F.)                          )

	cCodLocal := CodPais(SM0->M0_ESTENT)
	oWsCpl:AddSoap(WSSoapValue("addressCountryAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                                          )
	cCodLocal := CodEstado(SM0->M0_ESTENT)
	oWsCpl:AddSoap(WSSoapValue("addressStateAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                    )
	oWsCpl:AddSoap(WSSoapValue("addressCity", StrTrim(SM0->M0_CIDENT,50), StrTrim(SM0->M0_CIDENT,50) , "string", .F. , .F., 0 , NIL, .F.)        )
	oWsCpl:AddSoap(WSSoapValue("addressDistrict", StrTrim(SM0->M0_BAIRENT,50), StrTrim(SM0->M0_BAIRENT,50) , "string", .F. , .F., 0 , NIL, .F.)  )
	aEndEnt := LjFiGetEnd(SM0->M0_ENDENT, SM0->M0_ESTENT, .T.)
	oWsCpl:AddSoap(WSSoapValue("addressStreet", StrTrim(aEndEnt[1],200), StrTrim(aEndEnt[1],200), "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressNumber", StrTrim(aEndEnt[3],30), StrTrim(aEndEnt[3],30) , "string", .F. , .F., 0 , NIL, .F.)      )
	oWsCpl:AddSoap(WSSoapValue("addressComplement", StrTrim(SM0->M0_COMPENT,30), StrTrim(SM0->M0_COMPENT,30) , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressZipCode", SM0->M0_CEPENT, SM0->M0_CEPENT , "string", .F. , .F., 0 , NIL, .F.)                         )

	oWsCpl:AddSoap(WSSoapValue("logisticRoleId", 1, 1 , "int", .F. , .F., 0 , NIL, .F.))//Ambos

	oWsCpl:AddSoap("</locality>")
	oWsCpl:AddSoap("</localities>")

	OsLogCPL("OMSXCPL -> OMSXADDSM0 -> Final do metodo.","INFO")
Return

/*/{Protheus.doc} OMSXADDSA1
Adiciona o xml de um cliente posicionado 'SA1' para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Static Function OMSXADDSA1(oWsCpl)
Local cCodFil   := OMSXGETFIL("SA1")
Local nROTCEP   := SuperGetMv("MV_ROTCEP",.F.,"1")
Local cCodLocal := ""
Local aEndEnt   := {}
Local lCompEnt  := ColumnPos("A1_COMPENT") > 0

	OsLogCPL("OMSXCPL -> OMSXADDSA1 -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<localities>")
	oWsCpl:AddSoap("<locality>")
	oWsCpl:AddSoap(RegionSourceId())

	cCodLocal := "CLI-" + RTrim(SA1->A1_COD) + "-" + RTrim(SA1->A1_LOJA) + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("name", Transform(SA1->A1_NREDUZ,"@!"), Transform(SA1->A1_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.)                             )
	oWsCpl:AddSoap(WSSoapValue("description", Transform(SA1->A1_NOME,"@!"), Transform(SA1->A1_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.)                          )

	If nROTCEP == "2" .Or. nROTCEP == "3"

		cCodLocal := CodPaisCli(SA1->A1_PAIS)
		oWsCpl:AddSoap(WSSoapValue("addressCountryAcronym", cCodLocal,  cCodLocal , "string", .F. , .F., 0 , NIL, .F.))
		cCodLocal := CodEstado(SA1->A1_ESTE)
		oWsCpl:AddSoap(WSSoapValue("addressStateAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))
		cCodLocal := Trim(Posicione('CC2',1,xFilial('CC2')+SA1->A1_ESTE+SA1->A1_CODMUNE,'CC2_MUN'))
		oWsCpl:AddSoap(WSSoapValue("addressCity", Transform(cCodLocal,"@!"), Transform(cCodLocal,"@!") , "string", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("addressDistrict", StrTrim(SA1->A1_BAIRROE,50), StrTrim(SA1->A1_BAIRROE,50) , "string", .F. , .F., 0 , NIL, .F.))
		aEndEnt := LjFiGetEnd(SA1->A1_ENDENT, SA1->A1_EST, .T.)
		oWsCpl:AddSoap(WSSoapValue("addressStreet", StrTrim(aEndEnt[1],200),StrTrim(aEndEnt[1],200) , "string", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("addressNumber", StrTrim(aEndEnt[3],30), StrTrim(aEndEnt[3],30) , "string", .F. , .F., 0 , NIL, .F.))
		If lCompEnt
			oWsCpl:AddSoap(WSSoapValue("addressComplement", StrTrim(SA1->A1_COMPENT,30), StrTrim(SA1->A1_COMPENT,30) , "string", .F. , .F., 0 , NIL, .F.))
		EndIf
		oWsCpl:AddSoap(WSSoapValue("addressZipCode", SA1->A1_CEPE, SA1->A1_CEPE , "string", .F. , .F., 0 , NIL, .F.))

	Else

		cCodLocal := CodPaisCli(SA1->A1_PAIS)
		oWsCpl:AddSoap(WSSoapValue("addressCountryAcronym", cCodLocal,  cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                                          )
		cCodLocal := CodEstado(SA1->A1_EST)
		oWsCpl:AddSoap(WSSoapValue("addressStateAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                    )
		cCodLocal := Trim(Posicione('CC2',1,xFilial('CC2')+SA1->A1_EST+SA1->A1_COD_MUN,'CC2_MUN'))
		oWsCpl:AddSoap(WSSoapValue("addressCity", Transform(cCodLocal,"@!"), Transform(cCodLocal,"@!") , "string", .F. , .F., 0 , NIL, .F.)              )
		oWsCpl:AddSoap(WSSoapValue("addressDistrict", StrTrim(SA1->A1_BAIRRO,50), StrTrim(SA1->A1_BAIRRO,50) , "string", .F. , .F., 0 , NIL, .F.)    )
		aEndEnt := LjFiGetEnd(SA1->A1_END, SA1->A1_EST, .T.)
		oWsCpl:AddSoap(WSSoapValue("addressStreet", StrTrim(aEndEnt[1],200), StrTrim(aEndEnt[1],200) , "string", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("addressNumber", StrTrim(aEndEnt[3],30), StrTrim(aEndEnt[3],30) , "string", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("addressComplement", StrTrim(SA1->A1_COMPLEM,30), StrTrim(SA1->A1_COMPLEM,30) , "string", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("addressZipCode", SA1->A1_CEP, SA1->A1_CEP , "string", .F. , .F., 0 , NIL, .F.)                         )

	EndIf

	oWsCpl:AddSoap(WSSoapValue("logisticRoleId", 2, 2 , "int", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap("</locality>")
	oWsCpl:AddSoap("</localities>")

	OsLogCPL("OMSXCPL -> OMSXADDSA1 -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXSA2LOC
Adiciona o xml de um fornecedor posicionado 'SA2' como se fosse uma localidade para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Static Function OMSXSA2LOC(oWsCpl)
Local cCodFil   := OMSXGETFIL("SA2")
Local cCodLocal := ""
Local aEndEnt   := {}

	OsLogCPL("OMSXCPL -> OMSXSA2LOC -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<localities>")
	oWsCpl:AddSoap("<locality>")
	oWsCpl:AddSoap(RegionSourceId())

	cCodLocal := "FOR-" + RTrim(SA2->A2_COD) + "-" + RTrim(SA2->A2_LOJA) + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier",        cCodLocal, cCodLocal, "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("name",              Transform(SA2->A2_NREDUZ,"@!"), Transform(SA2->A2_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("description",       Transform(SA2->A2_NOME,"@!"), Transform(SA2->A2_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.))

	cCodLocal := CodPaisCli(SA2->A2_PAIS)
	oWsCpl:AddSoap(WSSoapValue("addressCountryAcronym", cCodLocal, cCodLocal, "string", .F. , .F., 0 , NIL, .F.))
	cCodLocal := CodEstado(SA2->A2_EST)
	oWsCpl:AddSoap(WSSoapValue("addressStateAcronym",   cCodLocal, cCodLocal, "string", .F. , .F., 0 , NIL, .F.))
	// Não pega o município do cadastro, pois este só possui 15 caracteres
	cCodLocal := Trim(Posicione('CC2',1,xFilial('CC2')+SA2->A2_EST+SA2->A2_COD_MUN,'CC2_MUN'))
	oWsCpl:AddSoap(WSSoapValue("addressCity",       Transform(cCodLocal,"@!"), Transform(cCodLocal,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressDistrict",   Transform(SA2->A2_BAIRRO,"@!"), Transform(SA2->A2_BAIRRO,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	aEndEnt := LjFiGetEnd( SA2->A2_END, SA2->A2_EST, .T. )
	oWsCpl:AddSoap(WSSoapValue("addressStreet",     StrTrim(aEndEnt[1],200), StrTrim(aEndEnt[1],200), "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressNumber",     StrTrim(aEndEnt[3],30), StrTrim(aEndEnt[3],30), "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressComplement", Transform(SA2->A2_COMPLEM,"@!"), Transform(SA2->A2_COMPLEM,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressZipCode",    Transform(SA2->A2_CEP,"@!"), Transform(SA2->A2_CEP,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	
	oWsCpl:AddSoap(WSSoapValue("logisticRoleId",        "2", "2" , "string", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap("</locality>")
	oWsCpl:AddSoap("</localities>")

	OsLogCPL("OMSXCPL -> OMSXSA2LOC -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXSA2CAR
Adiciona o xml de um fornecedor posicionado 'SA2' como se fosse uma transportadora para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Static Function OMSXSA2CAR(oWsCpl)
Local cCodFil   := OMSXGETFIL("SA2")
Local cCodLocal := ""

	OsLogCPL("OMSXCPL -> OMSXSA2CAR -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<carriers>")
	oWsCpl:AddSoap("<carrier>")
	oWsCpl:AddSoap(RegionSourceId())

	cCodLocal := RTrim(SA2->A2_COD) + '-' + RTrim(SA2->A2_LOJA) + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier"    , cCodLocal, cCodLocal, "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("name"          , Transform(SA2->A2_NREDUZ,"@!"), Transform(SA2->A2_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("description"   , Transform(SA2->A2_NOME,"@!"), Transform(SA2->A2_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("email"         , SA2->A2_EMAIL, SA2->A2_EMAIL , "string", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap("</carrier>")
	oWsCpl:AddSoap("</carriers>")

	OsLogCPL("OMSXCPL -> OMSXSA2CAR -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXADDSA4
Adiciona o xml de uma transportadora posicionada 'SA4' para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Static Function OMSXADDSA4(oWsCpl)
Local cCodFil   := OMSXGETFIL("SA4")
Local cCodLocal := ""

	OsLogCPL("OMSXCPL -> OMSXADDSA4 -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<carriers>")
	oWsCpl:AddSoap("<carrier>")
	oWsCpl:AddSoap(RegionSourceId())

	cCodLocal := RTrim(SA4->A4_COD) + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier",  cCodLocal, cCodLocal, "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("name",        Transform(SA4->A4_NOME,"@!"), Transform(SA4->A4_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("description", Transform(SA4->A4_NREDUZ,"@!"), Transform(SA4->A4_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("email",       SA4->A4_EMAIL, SA4->A4_EMAIL, "string", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap("</carrier>")
	oWsCpl:AddSoap("</carriers>")

	OsLogCPL("OMSXCPL -> OMSXADDSA4 -> Final do metodo.","INFO")
	
Return

/*/{Protheus.doc} OMSXADDSC5
Adiciona o xml de um pedido de venda posicionado 'SC5'
@author jackson.werka
@since 10/04/2018
@param oWsCpl, object, Cliente de webservice compativel
@param nOperacao, numeric, Operação de dados a ser executada
@param cQuebraId, characters, id da quebra do Cockpit
/*/
Static Function OMSXADDSC5(oWsCpl,nOperacao,cSeqInt,oTabTemp,cQuebraId)
Local cIdentify  := ""
Local cShipperId := ""
Local cCodFil    := ""
Local cPriority  := ""
Local dDtCreate  := ""
Local cModal     := ""
Local cInvolucro := ""
Local cOrigem    := ""
Local cIncoterm  := ""
Local cDestino   := ""
Local dPick      := ""
Local dEndDeli   := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local lColDatEmb := SC6->( FieldPos( "C6_DATAEMB" ) ) > 0
Local cCpoPeso   := IIf(SuperGetMv("MV_PESOCAR",.F.,"L") == "L","B1_PESO","B1_PESBRU")
Local aTamSX3    := {}
Local cProdId    := ""
Local cSource    := ""
Local nQtdInt    := 0
Local nQde       := 0
Local nQdeLib    := 0
Local nPrice     := 0
Local nPeso      := 0
Local nAltura    := 0
Local nLargura   := 0
Local nComprim   := 0
Local nFatorKG   := 1
Local lIntPed2UM := (SuperGetMv("MV_CPLUMIT",.F.,"1") == "2") // Indica a UM do produto a ser considerada na integração com o CPL
Local lQtdLib    := MV_PAR22 == 1
Local lDtEmisPed := (SuperGetMv("MV_CPLDTPD",.F.,"1") == "2") // Indica se deve ser enviada a data de emissão do Pedido. Caso Falso, será enviada a data corrente.
Local cCodLocal  := ""
Local aEndEnt    := {}

	OsLogCPL("OMSXCPL -> OMSXADDSC5 -> Inicio do metodo.","INFO")

	oWsCpl:cIniMetodo := "<ord:" + oWsCpl:cMetodo + " xmlns:ord='http://www.neolog.com.br/cpl/acquisition/order/'" +;
	" xmlns:att='http://www.neolog.com.br/cpl/acquisition/attribute/'"              +;
	" xmlns:clas='http://www.neolog.com.br/cpl/acquisition/classification/'"        +;
	" xmlns:del='http://www.neolog.com.br/cpl/acquisition/deliveryUnit/'"           +;
	" xmlns:ord1='http://www.neolog.com.br/cpl/acquisition/orderItemDu/'"           +;
	" xmlns:ord2='http://www.neolog.com.br/cpl/acquisition/orderitem/'"             +;
	" xmlns:ord3='http://www.neolog.com.br/cpl/acquisition/orderItem/'>"

	oWsCpl:cFimMetodo := "</ord:" + oWsCpl:cMetodo + ">"

	oWsCpl:AddSoap("<ord:orderList>")
	oWsCpl:AddSoap("<ord:orders>")
	oWsCpl:AddSoap("<ord:order>")

	cCodFil    := OMSXGETFIL("SC5",.F.)
	If !Empty(cSeqInt)
		cIdentify  := RTrim(cCodFil)+ "-" + RTrim(cSeqInt) + "-" + RTrim(SC5->C5_NUM)
	Else
		cIdentify  := RTrim(cCodFil)+ "-" + RTrim(SC5->C5_NUM)
	EndIf
	
	//Adiciona informação da quebra no identificador do pedido
	If !Empty(cQuebraId)
		cIdentify += "-"+ RTrim(cQuebraId)
	EndIf
	
	cShipperId := _MV_CPLEMB

	oWsCpl:AddSoap(RegionSourceId("ord:"))
	oWsCpl:AddSoap(WSSoapValue("ord:identifier",        cIdentify,     cIdentify,   "string",   .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("ord:shipperId",        cShipperId,    cShipperId,   "string",   .F. , .F., 0 , NIL, .F.))

	If nOperacao != MODEL_OPERATION_DELETE

		cPriority  := "0"
		cModal     := "1"
		cInvolucro := _MV_CPLIDS
		cCodFil    := OMSXGETFIL("SM0",.F.)
		cOrigem    := "FIL-" + RTrim(cCodFil)
		dDtCreate  := Iif(lDtEmisPed,FWTimeStamp(5, SC5->C5_EMISSAO, "00:00:00"),FWTimeStamp( 5, DATE() , TIME()  ))

		If Empty(SC5->C5_TPFRETE)
			cIncoterm := "1"
		ElseIf SC5->C5_TPFRETE == "C"
			cIncoterm := "1"
		Else
			cIncoterm := "0"
		EndIf

		If !Empty(SC5->C5_REDESP)
			cCodFil  := OMSXGETFIL("SA4")
			cDestino := "RED-" + RTrim(SC5->C5_REDESP)+ RTrim(cCodFil)
		Else
			If SC5->C5_TIPO == 'B' .Or. SC5->C5_TIPO == 'D'
				cCodFil  := OMSXGETFIL("SA2")
				cDestino := "FOR-" + RTrim(SC5->C5_CLIENT)+ "-" + RTrim(SC5->C5_LOJAENT) + RTrim(cCodFil)
			Else
				cCodFil  := OMSXGETFIL("SA1")
				cDestino := "CLI-" + RTrim(SC5->C5_CLIENT)+ "-" + RTrim(SC5->C5_LOJAENT) + RTrim(cCodFil)
			EndIf
		EndIf

		cQuery := "SELECT SC6.C6_ITEM,"
		cQuery +=       " SC6.C6_PRODUTO,"
		cQuery +=       " SC6.C6_ENTREG,"
		If lColDatEmb
			cQuery +=   " SC6.C6_DATAEMB,"
		EndIf
		cQuery +=       " SC6.C6_PRCVEN,"
		If nOperacao == MODEL_OPERATION_INSERT
			cQuery +=       " TMP.C6_QTDINT,"
		EndIf
		cQuery +=       " SB1."+cCpoPeso+","
		cQuery +=       " SB1.B1_UM,"
		cQuery +=       " SB1.B1_CONV,"
		cQuery +=       " SB1.B1_TIPCONV,"
		cQuery +=       " SB5.B5_ALTURLC,"
		cQuery +=       " SB5.B5_LARGLC,"
		cQuery +=       " SB5.B5_COMPRLC,"
		cQuery +=       " SB5.B5_TIPUNIT"
		If nOperacao == MODEL_OPERATION_INSERT
			cQuery +=  " FROM " + oTabTemp:GetRealName() + " TMP"
		Else
			cQuery +=  " FROM " + RetSqlName("SC6") + " TMP"
		EndIf
		//Realiza associação novamente com a SC6 para garantir que os dados estão atualizados
		cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6"
		cQuery +=    " ON SC6.C6_FILIAL  = TMP.C6_FILIAL"
		cQuery +=   " AND SC6.C6_NUM     = TMP.C6_NUM"
		cQuery +=   " AND SC6.C6_ITEM    = TMP.C6_ITEM"
		cQuery +=   " AND SC6.C6_PRODUTO = TMP.C6_PRODUTO"
		cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
		If lQtdLib
			cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9"
		Else
			cQuery += " LEFT JOIN " + RetSqlName("SC9") + " SC9"
		EndIf
		cQuery +=    " ON SC9.C9_FILIAL  = '"+xFilial("SC9")+"'"
		cQuery +=   " AND SC9.C9_PEDIDO  = SC6.C6_NUM"
		cQuery +=   " AND SC9.C9_ITEM    = SC6.C6_ITEM"
		cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cQuery +=    " ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"
		cQuery +=   " AND SB1.B1_COD     = SC6.C6_PRODUTO"
		cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN " + RetSqlName("SB5") + " SB5 " // Não é obrigatório ter complemento do produto
		cQuery +=    " ON SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
		cQuery +=   " AND SB5.B5_COD     = SB1.B1_COD"
		cQuery +=   " AND SB5.D_E_L_E_T_ = ' '"
		cQuery += " WHERE TMP.C6_FILIAL  = '"+SC5->C5_FILIAL+"'"
		cQuery +=   " AND TMP.C6_NUM     = '"+SC5->C5_NUM+"'"
		If nOperacao == MODEL_OPERATION_INSERT
			cQuery += " AND TMP.C6_QTDINT > 0"
		EndIf
		cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY SC6.C6_ITEM,"
		cQuery +=          " SC6.C6_PRODUTO,"
		cQuery +=          " SC6.C6_ENTREG,"
		If lColDatEmb
			cQuery +=      " SC6.C6_DATAEMB,"
		EndIf
		cQuery +=          " SC6.C6_PRCVEN,"
		If nOperacao == MODEL_OPERATION_INSERT
			cQuery +=          " TMP.C6_QTDINT,"
		EndIf
		cQuery +=          " SB1."+cCpoPeso+","
		cQuery +=          " SB1.B1_UM,"
		cQuery +=          " SB1.B1_CONV,"
		cQuery +=          " SB1.B1_TIPCONV,"
		cQuery +=          " SB5.B5_ALTURLC,"
		cQuery +=          " SB5.B5_LARGLC,"
		cQuery +=          " SB5.B5_COMPRLC,"
		cQuery +=          " SB5.B5_TIPUNIT"
		cQuery := ChangeQuery( cQuery )
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )

		OsLogCPL("OMSXCPL -> OMSXADDSC5 -> Conteudo da query cQuery: " + cValToChar(cQuery),"INFO")

		TCSetField(cAliasQry,'C6_ENTREG', 'D',8,0)
		If lColDatEmb
			TCSetField(cAliasQry,'C6_DATAEMB','D',8,0)
		EndIf
		aTamSX3 := TamSx3("DK3_QTDINT" );TCSetField(cAliasQry,'C6_QTDINT' ,'N',aTamSX3[1],aTamSX3[2])
		aTamSX3 := TamSx3(cCpoPeso);     TCSetField(cAliasQry,cCpoPeso    ,'N',aTamSX3[1],aTamSX3[2])
		aTamSX3 := TamSx3("B1_CONV"   ); TCSetField(cAliasQry,'B1_CONV'   ,'N',aTamSX3[1],aTamSX3[2])
		aTamSX3 := TamSx3("B5_ALTURLC"); TCSetField(cAliasQry,'B5_ALTURLC','N',aTamSX3[1],aTamSX3[2])
		aTamSX3 := TamSx3("B5_LARGLC" ); TCSetField(cAliasQry,'B5_LARGLC' ,'N',aTamSX3[1],aTamSX3[2])
		aTamSX3 := TamSx3("B5_COMPRLC"); TCSetField(cAliasQry,'B5_COMPRLC','N',aTamSX3[1],aTamSX3[2])

		If !Empty(SC5->C5_FECENT)
			dEndDeli := FWTimeStamp( 5, SC5->C5_FECENT , "23:59:59" )
		ElseIf !Empty((cAliasQry)->C6_ENTREG)
			dEndDeli := FWTimeStamp( 5, (cAliasQry)->C6_ENTREG , "23:59:59" )
		Else
			dEndDeli := FWTimeStamp( 5, DATE() , "23:59:59" )			
		EndIf

		If lColDatEmb .And. !Empty((cAliasQry)->C6_DATAEMB)
			dPick := FWTimeStamp( 5, (cAliasQry)->C6_DATAEMB , "00:01:00" )
		Else
			dPick := FWTimeStamp( 5, DATE() , "00:01:00" )
		EndIf

		oWsCpl:AddSoap(WSSoapValue("ord:code",                  cIdentify,  cIdentify,  "string",   .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:deliveryEnd",            dEndDeli,   dEndDeli,  "dateTime", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:erpCreationDt",          dDtCreate,  dDtCreate, "dateTime", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:incoterm",               cIncoterm,  cIncoterm, "string",   .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:modal",                  cModal,     cModal,    "string",   .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:integrationDataSource",  cInvolucro, cInvolucro,"string",   .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:orderTypeSourceId",      Nil,        Nil,       "string",   .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:destinationId",          cDestino,   cDestino,  "string",   .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:pickupStart",            dPick,      dPick,     "dateTime", .F. , .F., 0 , NIL, .F.))
		oWsCpl:AddSoap(WSSoapValue("ord:priority",               cPriority,  cPriority, "string",   .F. , .F., 0 , NIL, .F.))


		//Este bloco de informações deve ser enviado somente quando o Pedido possuir Redespacho informado.
		If !Empty(SC5->C5_REDESP)
			SA4->(DbSetOrder(1))
			If SA4->(DbSeek(xFilial('SA4')+SC5->C5_REDESP))
				cCodLocal := CodPaisCli(StrTrim(SA4->A4_CODPAIS,3))
				oWsCpl:AddSoap(WSSoapValue("ord:addressCountryAcronym", cCodLocal,  cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                                          )
				cCodLocal := CodEstado(SA4->A4_EST)
				oWsCpl:AddSoap(WSSoapValue("ord:addressStateAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                    )
				cCodLocal := Trim(Posicione('CC2',1,xFilial('CC2')+SA4->A4_EST+SA4->A4_COD_MUN,'CC2_MUN'))
				oWsCpl:AddSoap(WSSoapValue("ord:addressCity", Transform(cCodLocal,"@!"), Transform(cCodLocal,"@!") , "string", .F. , .F., 0 , NIL, .F.)              )
				oWsCpl:AddSoap(WSSoapValue("ord:addressDistrict", StrTrim(SA4->A4_BAIRRO,50), StrTrim(SA4->A4_BAIRRO,50) , "string", .F. , .F., 0 , NIL, .F.)    )
				aEndEnt := LjFiGetEnd(SA4->A4_END, SA4->A4_EST, .T.)
				oWsCpl:AddSoap(WSSoapValue("ord:addressStreet", StrTrim(aEndEnt[1],200), StrTrim(aEndEnt[1],200) , "string", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord:addressNumber", StrTrim(aEndEnt[3],30), StrTrim(aEndEnt[3],30) , "string", .F. , .F., 0 , NIL, .F.))
				If !Empty(SA4->A4_COMPLEM)
					oWsCpl:AddSoap(WSSoapValue("ord:addressComplement", StrTrim(SA4->A4_COMPLEM,30), StrTrim(SA4->A4_COMPLEM,30) , "string", .F. , .F., 0 , NIL, .F.))
				EndIf
				oWsCpl:AddSoap(WSSoapValue("ord:addressZipCode", SA4->A4_CEP, SA4->A4_CEP , "string", .F. , .F., 0 , NIL, .F.)                         )		
			EndIf
		EndIF	

		(cAliasQry)->(dbGoTop())

		If !(cAliasQry)->(Eof())
			cCodFil := OMSXGETFIL("SB1")
			oWsCpl:AddSoap("<ord:items>")
			oWsCpl:AddSoap("<ord2:orderItems>")
			While !(cAliasQry)->(Eof())
				If nOperacao == MODEL_OPERATION_UPDATE
					//Busca quantidade de integração do modelo de dados de alteração
					nQtdInt := OmsCplQAlt(cSeqInt,(cAliasQry)->C6_ITEM,(cAliasQry)->C6_PRODUTO,cQuebraId)
					If nQtdInt <= 0
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
				Else
					nQtdInt := (cAliasQry)->C6_QTDINT
				EndIf				// Importante manter a mesma regra do envio de cadastro de produtos
				cProdId  := StrTrim(RTrim((cAliasQry)->C6_PRODUTO) + cCodFil,30)
				
				cSource := cIdentify+"-"+ (cAliasQry)->C6_ITEM
				
				//Verifica se possuí fator de conversão para KG
				nFatorKG := 1
				If TableInDic("DK2", .F.)
					DK2->(DbSetOrder(1))
					If DK2->(DbSeek(xFilial('DK2')+(cAliasQry)->B1_UM))
						nFatorKG := DK2->DK2_PESOKG
					EndIf
				EndIf
				
				// Se estiver parametrizado para considerar a 2a UM e tiver preenchido fator de conversão
				If lIntPed2UM .And. (cAliasQry)->B1_CONV > 0 
					nQde    := ConvUm((cAliasQry)->C6_PRODUTO,nQtdInt,0,2)
					nQdeLib := ConvUm((cAliasQry)->C6_PRODUTO,nQtdInt,0,2)
					// Deve calcular o peso com base na segunda UM do produto, já que o CPL só recebe uma única UM
					If (cAliasQry)->B1_TIPCONV == "D"
						nPeso := ((cAliasQry)->(FieldGet(FieldPos(cCpoPeso))) * nFatorKG) * (cAliasQry)->B1_CONV
					Else
						nPeso := ((cAliasQry)->(FieldGet(FieldPos(cCpoPeso))) * nFatorKG) / (cAliasQry)->B1_CONV
					EndIf
				Else
					nQde    := nQtdInt
					nQdeLib := nQtdInt
					nPeso   := (cAliasQry)->(FieldGet(FieldPos(cCpoPeso))) * nFatorKG
				EndIf
				nPrice   := nQtdInt * (cAliasQry)->C6_PRCVEN
				nAltura  := (cAliasQry)->B5_ALTURLC
				nLargura := (cAliasQry)->B5_LARGLC
				nComprim := (cAliasQry)->B5_COMPRLC
				
				//Tratamento específico para produtos controlados a granel.
				If !Empty((cAliasQry)->B5_TIPUNIT ) .And. (cAliasQry)->B5_TIPUNIT == "0"
					nPeso := nPeso * nQde
					nQde := 1
					nQdeLib := 1
				EndIf

				oWsCpl:AddSoap("<ord3:orderItem>")
				oWsCpl:AddSoap(WSSoapValue("ord3:orderId",                  cIdentify,      cIdentify,                          "string",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:originId",                 cOrigem,        cOrigem,                            "string",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:sourceId",                 cSource,        cSource,                            "string",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:productId",                cProdId,        cProdId,                            "string",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:quantity",                 nQde,           nQde,                               "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:quantityInShipmentUnits",  nQdeLib,        nQdeLib,                            "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:shipmentUnitWrapperCode",  _MV_CPLINV,     _MV_CPLINV,                         "string",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:price",                    0.01,           Iif(Empty(nPrice),Nil,nPrice),      "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:weight",                   0.001,          Iif(Empty(nPeso),Nil,nPeso),        "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:height",                   0.001,          Iif(Empty(nAltura),Nil,nAltura),    "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:width",                    0.001,          Iif(Empty(nLargura),Nil,nLargura),  "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:length",                   0.001,          Iif(Empty(nComprim),Nil,nComprim),  "double",   .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap("</ord3:orderItem>")
				(cAliasQry)->(dbSkip())
			EndDo
			oWsCpl:AddSoap("</ord2:orderItems>")
			oWsCpl:AddSoap("</ord:items>")
		EndIf
		(cAliasQry)->(dbclosearea())
	EndIf
	oWsCpl:AddSoap("</ord:order>")
	oWsCpl:AddSoap("</ord:orders>")
	oWsCpl:AddSoap("</ord:orderList>")

	OsLogCPL("OMSXCPL -> OMSXADDSC5 -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXLIBDK0
Adiciona o xml de uma viagem posicionada 'DK0' para efetuar a liberação no CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Static Function OMSXLIBDK0(oWsCpl)
Local aAreaAnt   := GetArea()
Local cAliasDK1  := ""
Local cQuery     := ""
Local cPedido    := ""
Local cItemPed   := ""
Local cOrdItId   := ""
Local cOrdId     := ""
Local cViagemId  := DK0->DK0_VIAGID
Local nTamItem   := TamSX3("C6_ITEM")[1]
Local nPosPed    := 0
Local nLenGrpCmp := 0
Local nTamSeqInt := TamSx3("DK3_SEQUEN")[1]
Local nTamPedido := TamSx3("C6_NUM")[1]
Local lColQuebId := (DK1->( ColumnPos( "DK1_QUEBID" ) ) > 0)
Local cSpaceQueb := Iif(lColQuebId, Space(TamSx3("DK1_QUEBID")[1]), " ")

	OsLogCPL("OMSXCPL -> OMSXLIBDK0 -> Inicio do metodo.","INFO")

	If Empty(OsCplEmpDef()) .And. !OsHasEmpFil()
		nLenGrpCmp := Len(FWGrpCompany())
	EndIf
	
	nPosPed    := nLenGrpCmp + Len(RTrim(xFilial("SC5"))) + nTamSeqInt + nTamPedido //Calcula a posição do pedido na string
	
	oWsCpl:cIniMetodo := "<unb:" + oWsCpl:cMetodo + ' xmlns:unb="http://www.neolog.com.br/cpl/acquisition/unblockRelTrip/" '+;
	'xmlns:erp="http://www.neolog.com.br/cpl/acquisition/eRPMessageResponse/" '+;
	'xmlns:ord="http://www.neolog.com.br/cpl/acquisition/orderBreakRemovalRequest/" '+;
	'xmlns:ord1="http://www.neolog.com.br/cpl/acquisition/orderBreakId/" '+;
	'xmlns:ord2="http://www.neolog.com.br/cpl/acquisition/orderBreakResponse/" '+;
	'xmlns:trip="http://www.neolog.com.br/cpl/acquisition/tripReleaseResponse/" '+;
	'xmlns:trip1="http://www.neolog.com.br/cpl/acquisition/tripLoadsSourceId/">'

	oWsCpl:cFimMetodo := "</unb:" + oWsCpl:cMetodo + ">"

	oWsCpl:AddSoap("<unb:unblockReleasedTrips>")
	oWsCpl:AddSoap("<unb:unblockReleasedTrips>")
	oWsCpl:AddSoap("<unb:unblockReleasedTrip>")

	oWsCpl:AddSoap(WSSoapValue("unb:identifier", DK0->DK0_CPLMSG, DK0->DK0_CPLMSG , "int", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(RegionSourceId("unb:"))

	If lColQuebId

		cAliasDK1 := GetNextAlias()
		BeginSql Alias cAliasDK1
			SELECT DK1.DK1_REGID,
				   DK1.DK1_ORITID,
				   DK1.DK1_PEDROT,
				   DK1.DK1_QUEBID
			  FROM %Table:DK1% DK1
			 WHERE DK1.DK1_FILIAL = %xFilial:DK1% 
			   AND DK1.DK1_VIAGID = %Exp:cViagemId%
			   AND DK1.DK1_QUEBID <> %Exp:cSpaceQueb%
			   AND DK1.%NotDel%
		EndSql

		OsLogCPL("OMSXCPL -> OMSXLIBDK0 -> Query da DK1-1: " + cValToChar(GetLastQuery()[2]),"INFO")
		
		If (cAliasDK1)->(!Eof())
			oWsCpl:AddSoap("<unb:orderBreakResponses>")
			oWsCpl:AddSoap("<ord2:orderBreakResponses>")
			
			While (cAliasDK1)->(!EoF())
				cPedido  := SubStr( (cAliasDK1)->DK1_ORITID , 1 , nPosPed+2 )
				cItemPed := Right(RTrim((cAliasDK1)->DK1_ORITID), nTamItem)
				cOrdId   := Rtrim(cPedido + "-" + (cAliasDK1)->DK1_QUEBID) // Concatena o id do pedido com a informação da quebra
				cOrdItId := cOrdId + "-" + cItemPed // Concatena o id do item do pedido com a informação da quebra

				oWsCpl:AddSoap("<ord2:orderBreakResponse>")

				oWsCpl:AddSoap(WSSoapValue("ord2:breakId", RTrim((cAliasDK1)->DK1_QUEBID), RTrim((cAliasDK1)->DK1_QUEBID), "string", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord2:orderId", cOrdId, cOrdId, "string", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord2:orderItemId", cOrdItId, cOrdItId, "string", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord2:regionSourceId", RTrim((cAliasDK1)->DK1_REGID), RTrim((cAliasDK1)->DK1_REGID), "string", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord2:status", "1", "1", "string", .F. , .F., 0 , NIL, .F.))

				oWsCpl:AddSoap("</ord2:orderBreakResponse>")
				
				(cAliasDK1)->(DbSkip())
			EndDo
			oWsCpl:AddSoap("</ord2:orderBreakResponses>")
			oWsCpl:AddSoap("</unb:orderBreakResponses>")
		EndIf
		(cAliasDK1)->(DbCloseArea())
	EndIf

	oWsCpl:AddSoap("<unb:tripReleaseResponses>")
	oWsCpl:AddSoap("<trip:tripReleaseResponseList>")
	
	cAliasDK1 := GetNextAlias()
	BeginSql Alias cAliasDK1
		SELECT DK1.DK1_REGID,
			   DK1.DK1_ORITID,
			   DK1.DK1_PEDROT
		  FROM %Table:DK1% DK1
		 WHERE DK1.DK1_FILIAL = %xFilial:DK1%
		   AND DK1.DK1_VIAGID = %Exp:cViagemId%
		   AND DK1.%NotDel%
	EndSql

	OsLogCPL("OMSXCPL -> OMSXLIBDK0 -> Query da DK1-2: " + cValToChar(GetLastQuery()[2]),"INFO")

	If (cAliasDK1)->(!Eof())
		oWsCpl:AddSoap("<trip:tripReleaseResponses>")

		While (cAliasDK1)->(!Eof())

			oWsCpl:AddSoap("<trip:tripReleaseResponse>")

			oWsCpl:AddSoap(WSSoapValue("trip:itemId", (cAliasDK1)->DK1_ORITID, (cAliasDK1)->DK1_ORITID, "string", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(WSSoapValue("trip:orderSourceId", (cAliasDK1)->DK1_PEDROT, (cAliasDK1)->DK1_PEDROT, "string", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(WSSoapValue("trip:regionSourceId", RTrim((cAliasDK1)->DK1_REGID), RTrim((cAliasDK1)->DK1_REGID), "string", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(WSSoapValue("trip:status", 1, 1 , "int", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(WSSoapValue("trip:tripCode", RTrim(DK0->DK0_VIAGID), RTrim(DK0->DK0_VIAGID) , "string", .F. , .F., 0 , NIL, .F.))

			oWsCpl:AddSoap("</trip:tripReleaseResponse>")
			
			(cAliasDK1)->(dbSkip())
		EndDo
		oWsCpl:AddSoap("</trip:tripReleaseResponses>")
	EndIf
	(cAliasDK1)->(dbCloseArea())

	oWsCpl:AddSoap("</trip:tripReleaseResponseList>")
	oWsCpl:AddSoap("</unb:tripReleaseResponses>")
	oWsCpl:AddSoap("</unb:unblockReleasedTrip>")
	oWsCpl:AddSoap("</unb:unblockReleasedTrips>")
	oWsCpl:AddSoap("</unb:unblockReleasedTrips>")

	OsLogCPL("OMSXCPL -> OMSXLIBDK0 -> Final do Metodo. XML Gerado para envio.","INFO")

	RestArea(aAreaAnt)
Return

/*/{Protheus.doc} RegionSourceId
	Retona a tag de regional
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cPrx, characters, predixo usado no xml
@example
(examples)
@see (links_or_references)
/*/
Static Function RegionSourceId(cPrx)
Default cPrx := ""
Return WSSoapValue(cPrx + "regionSourceId", _MV_CPLREG, _MV_CPLREG, "string", .F. , .F., 0 , NIL, .F.)
/*/{Protheus.doc} ShipperId
	Retona a tag de embarcador
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cPrx, characters, predixo usado no xml
@example
(examples)
@see (links_or_references)
/*/
Static Function ShipperId(cPrx)
Default cPrx := ""
Return WSSoapValue(cPrx + "shipperId", _MV_CPLEMB, _MV_CPLEMB , "string", .F. , .F., 0 , NIL, .F.)
/*/{Protheus.doc} CodPais
	Retorna a sigla de um país conforme a uf Passada
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cEstado, characters
@example
(examples)
@see (links_or_references)
/*/
Static Function CodPais(cEstado)
	Local cEst := UPPER(cEstado)
	Local cRet := IIf ( Empty(cEst) .Or. aScan(_aUfs,{|x| x == cEst}) == 0 , "EX", "BR" )
Return cRet
/*/{Protheus.doc} CodPaisCli
	Retorna a sigla de um país conforme a uf passada consultando na tabela de paises para um clientes
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cEstado, characters
@example
(examples)
@see (links_or_references)
/*/
Static Function CodPaisCli(cPais)
Local aAreaAnt := GetArea()
Local cRet
	If Empty(cPais) .Or. cPais == '105'
		cRet := 'BR'
	Else
		cRet := StrTrim(Posicione('SYA',1,xFilial('SYA')+cPais,'YA_SIGLA'),2)
		RestArea(aAreaAnt)
	EndIf
Return cRet
/*/{Protheus.doc} CodEstado
	Retorna "EX" quando o estado não pertence a uma unidade federativa da república federativa do Brasil
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cEstado, characters
@example
(examples)
@see (links_or_references)
/*/
Static Function CodEstado(cEstado)
	Local cEst := UPPER(cEstado)
	Local cRet := IIf ( Empty(cEst) .Or. aScan(_aUfs,{|x| x == cEst}) == 0 , "EX", cEstado )
Return cRet

/*/{Protheus.doc} OMSXCPLEST
	Retorna o código do estado conforme integração
@author siegklenes.beulke
@since 16/03/2016
@version 1.0
@param $cEstado, $Char, $UF do registro
@return cRet, EX se estado for do exterior, senão, cEstado
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPLEST(cEstado)
Return CodEstado(cEstado)

/*/{Protheus.doc} OMSXCPLGUf
	 Retorna as UF presentes neste PRW
@author siegklenes.beulke
@since 16/03/2016
@version 1.0
@return _aUfs, Retorna as UF presentes neste PRW
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPLGUf(cTipo)
	Default cTipo := "A"
	If cTipo == "C"
		Return  _cUfs
	Else
		Return  _aUfs
	EndIf
Return

/*/{Protheus.doc} StrTrim
	Realiza o corte da string no tamanho desejado.
	Aplica RTrim.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cStr, characters, descricao
@param nTam, numeric, descricao
@example
(examples)
@see (links_or_references)
/*/
Function StrTrim(cStr,nTam)
	cStr := cValtoChar(cStr)
	If !Empty(nTam) .And. Len(cStr) > nTam
		cStr := SubStr(cStr,1,nTam)
	EndIf
	If cStr != Nil
		cStr := RTrim(cStr)
	EndIf
Return cStr

// Repassa para a nova chamada de função
Function OMSXGRVLOG(cTipo,cConteudo,cNome,cNome2)
Return OMSXGRVXML(cTipo,cConteudo,cNome,cNome2)

/*/{Protheus.doc} OMSXGRVXML
	Realiza a gravação de um arquivo XML na pasta de LOG parametrizada na integração com a NEOLOG.
	O nome do arquivo sempre será precedido pela Data/Hora no formato AAAAMMDDHHMMSS
	A pasta principal é a configurada no INI na seção [NEOLOG] em DebugPath
@author Jackson Patrick Werka
@since  17/07/2018
@param cTipo, characters, Sub pasta, que indica o processo do xml
@param cConteudo, characters, Conteúdo do xml a ser gravado
@param cNome, characters, Nome do arquivo. Geralmente referencia a tabela do processo no Protheus
@param cNome2, characters, Complemento do nome do arquivo. Geralmente referencia a PK da tabela do processo no Protheus
/*/
Function OMSXGRVXML(cTipo,cConteudo,cNome,cNome2)
Local cPastaFinal := ""
Local cArquivo    := ""
Local cMessage    := ""
Local cBarra      := Iif(IsSrvUnix(),"/","\")

	OsLogCPL("OMSXCPL -> OMSXGRVXML -> Inicio do metodo.","INFO")

	If !OsIsCplDbg()
		Return .T.
	EndIf

	cPastaFinal := OsCplDbgDir() + cBarra + cTipo
	If OMSXCRIFOL(cPastaFinal,cBarra)
		cArquivo := cPastaFinal + cBarra + DtoS(Date()) + StrTran(Time(),":") + "_" + StrTran(cNome," ") + Iif(!Empty(cNome2),"_"+StrTran(cNome2," "),"") + ".xml"
		If Empty(cArquivo) 
			cMessage := STR0021 + CRLF  // Não foi possível gravar o arquivo pasta para gravação inválida.
			FWLogMsg("WARN", "", "BusinessObject", "OMSXCPL", "", "", cMessage, 0, 0)
			OsLogCPL("OMSXCPL -> OMSXGRVXML -> Mensagem 1." + cValToChar(cMessage),"WARN")
		ElseIf Empty(cConteudo)
			cMessage := STR0022 + CRLF  // Não foi possível gravar o arquivo o conteúdo retornado pelo CPL é invalido.
			FWLogMsg("WARN", "", "BusinessObject", "OMSXCPL", "", "", cMessage, 0, 0)
			OsLogCPL("OMSXCPL -> OMSXGRVXML -> Mensagem 2." + cValToChar(cMessage),"WARN")
		Else
			MemoWrite(cArquivo, @cConteudo)
			If Ferror() != 0
				cMessage := STR0023 + cArquivo + "." + CRLF + STR0024 + cValToChar(FError()) // Não foi possível gravar o arquivo   ## Erro 
				FWLogMsg("WARN", "", "BusinessObject", "OMSXCPL", "", "", cMessage, 0, 0)
				OsLogCPL("OMSXCPL -> OMSXGRVXML -> Mensagem 3." + cValToChar(cMessage),"WARN")
			EndIf
		EndIf
	Else
		cMessage := STR0025 + cPastaFinal + "." + CRLF + STR0024 + cValToChar(FError()) // Não foi possível criar a pasta  ## Erro 
		FWLogMsg("WARN", "", "BusinessObject", "OMSXCPL", "", "", cMessage, 0, 0)
		OsLogCPL("OMSXCPL -> OMSXGRVXML -> Mensagem 4." + cValToChar(cMessage),"WARN")
	EndIf

	OsLogCPL("OMSXCPL -> OMSXGRVXML -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXCRIFOL
	Realiza a criação de uma pasta. Necessita do caminho completo.
	Cria toda a hierarquia de pastas necessárias
@author siegklenes.beulke
@since 06/09/2016
@param cPasta, characters, Caminho completo da pasta a ser criada
@param cBarra, characters, Barra utilizada pelo sistema operacional
/*/
Function OMSXCRIFOL(cPasta,cBarra)
Local lAbsolute
Local cPastaT := ""
Local aPasta
Local nY
Local nRet := 0
Local lSrvUnix := IsSrvUnix()

Default cBarra := Iif(lSrvUnix,"/","\")

	OsLogCPL("OMSXCPL -> OMSXCRIFOL -> Inicio do metodo.","INFO")

	lAbsolute := IIf(Substr(LTrim(cPasta),1,1) == cBarra, .F., .T.)
	OsLogCPL("OMSXCPL -> OMSXCRIFOL -> Conteudo da variavel lAbsolute:." +iIf(lAbsolute, ".TRUE.","FALSE"),"INFO")
	OsLogCPL("OMSXCPL -> OMSXCRIFOL -> Conteudo da variavel cPasta:." + TRIM(cPasta),"INFO")

	If !ExistDir(cPasta)
		aPasta := StrTokArr2(cPasta,cBarra)
		For nY := 1 To Len(aPasta)
			If !Empty(aPasta[nY])
				If lSrvUnix .Or. !lAbsolute
					cPastaT += cBarra + aPasta[nY]
				Else
					cPastaT += aPasta[nY] + cBarra
				EndIf
				OsLogCPL("OMSXCPL -> OMSXCRIFOL -> Conteudo da variavel cPastaT:" + cPastaT,"INFO")
				If !ExistDir(cPastaT)
					nRet := MakeDir(cPastaT)
					OsLogCPL("OMSXCPL -> OMSXCRIFOL -> Conteudo da variavel nRet:" + cValToChar(nRet),"INFO")
					If nRet != 0
						Exit
					EndIf
				EndIF
			EndIf
		Next nY
	EndIf

	OsLogCPL("OMSXCPL -> OMSXCRIFOL -> Final do metodo.","INFO")

Return nRet == 0

//Limpeza de variáveis estáticas críticas
Function OMSXCLRCH()
	_lTestouCon := .F.
Return

//Integração suspensa
Static Function IntegSusp(cTabela,nOperacao)
Local oData    := Nil
Local aAreaTmp := {}

	// Registra a integração para ser executada novamente em outro momento
	If SuperGetMv("MV_CPLSTP",.F.,"2") == "1"
		If IsBlind()
			oData := OMSXCPL3CLS():New()

			oData:ACAO := If(nOperacao == MODEL_OPERATION_DELETE ,'2','1')

			If (cTabela)->(IndexOrd()) != 1
				aAreaTmp := (cTabela)->(GetArea())
				(cTabela)->(dbSetOrder(1))
			EndIf

			oData:TABELA := cTabela
			oData:CHAVE  := (cTabela)->(&((cTabela)->(IndexKey())))

			If !Empty(aAreaTmp)
				RestArea(aAreaTmp)
			EndIf

			oData:RECTAB := (cTabela)->(RecNo())
			oData:MSGREG := STR0017 // "Integração suspensa."
			oData:USRREG := "ENVIO POR JOB"

			OMSXCPL4REG(oData)
			aSize(aAreaTmp,0)
			FreeObj(oData)
		EndIf

		Return .T.
	EndIf

Return .F.

Static Function WsCplConf(oWsCpl, aConfig, nOperacao)
	oWsCpl:SetServico(aConfig[CPL_SERVICE])
	oWsCpl:SetXmlNameSpace(aConfig[CPL_XMLINS])
	oWsCpl:SetOperacao(nOperacao)
	If nOperacao == MODEL_OPERATION_INSERT
		oWsCpl:SetMetodo(aConfig[CPL_INSERT])
	ElseIf nOperacao == MODEL_OPERATION_UPDATE
		oWsCpl:SetMetodo(aConfig[CPL_UPDATE])
	ElseIf nOperacao == MODEL_OPERATION_DELETE
		oWsCpl:SetMetodo(aConfig[CPL_DELETE])
	Else
		oWsCpl:SetMetodo(aConfig[CPL_INSERT])
	EndIf

Return 

/*/{Protheus.doc} OMSXGETFIL
	Retorna filial para uso em códigos de relacionamento.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cTabela, characters, Alias da tabela
@example
(examples)
@see (links_or_references)
/*/
Function OMSXGETFIL(cTabela,lHifen)
Local cRet := ""
Default lHifen := .T.

	If cTabela == "SM0"
		If Empty(OsCplEmpDef())
			cRet := FWGrpCompany() + '-' + cFilAnt
		Else
			cRet := cFilAnt
		EndIf
	Else
		If Empty(OsCplEmpDef()) .And. !OsHasEmpFil()
			cRet := FWGrpCompany() + xFilial(cTabela)
		Else
			cRet := xFilial(cTabela)
		EndIf
	EndIf
	If !Empty(cRet) .And. lHifen
		cRet := '-' + cRet
	EndIf
Return cRet

//Funções de proteção da timeglbValue
Function OMSXTEMPO(cvarGlb)
	Local cHora
	Local nHoras
	Local nMins
	Local nSegs

	If _lFunTime
		Return TimeGlbValue(cvarGlb)
	Else
		cHora := GetGlbValue(cvarGlb + "TEMPO")
		If Empty(cHora)
			Return -1
		Else
			nHoras := Val(Substr(TIME(),1,2)) - Val(Substr(cHora,1,2))
			nMins := Val(Substr(TIME(),4,2)) - Val(Substr(cHora,4,2))
			nSegs := Val(Substr(TIME(),7,2)) - Val(Substr(cHora,7,2))

			If nHoras < 0
				nHoras += 24
			EndIf

			If nMins < 0
				nMins += 60
			Endif

			If nSegs < 0
				nSegs += 60
			EndIf

			Return nHoras*3600 + nMins*60 + nSegs
		EndIf
	EndIf
Return

Function OMSXSETTEMPO(cvarGlb)

	OsLogCPL("OMSXCPL -> OMSXSETTEMPO -> Conteudo do parametro cvarGlb: " + cValToChar(cvarGlb),"INFO")

	If !_lFunTime
		PutGlbValue(cvarGlb + "TEMPO", TIME())
	EndIf
Return

Function OMSXCLRGLB(cvarGlb)

	OsLogCPL("OMSXCPL -> OMSXCLRGLB -> Conteudo do parametro cvarGlb: " + cValToChar(cvarGlb),"INFO")

	If !_lFunTime
		ClearGlbValue(cvarGlb + "TEMPO")
	EndIf
	ClearGlbValue(cvarGlb)
Return

Function OMSXPUTGLB(cvarGlb,xVal)

	OsLogCPL("OMSXCPL -> OMSXPUTGLB -> Conteudo do parametro cvarGlb: " + cValToChar(cvarGlb) + ;
			" e parametro xVal: " + cValToChar(xVal),"INFO")

	OMSXSETTEMPO(cvarGlb)
	PutGlbValue(cvarGlb,xVal)
Return

/*/{Protheus.doc} OMSXCPLINT
Trata integração dos cadastros OMS x CPL
@author amanda.vieira
@since 12/04/2018
@version 1.0
@param cTabela, character, alias da tabela que será integrada
/*/
Function OMSXCPLINT(cTabela)
Local lRet       := .T.
	If !(SuperGetMv("MV_CPLINT",.F.,"2") == "1")
		Return .T.
	EndIf
	If cTabela == "SA2" .And. SuperGetMv("MV_CPLFOR",.F.,"2") == "1"
		OMSXJOBCAD(cTabela,4)
	ElseIf cTabela $ "SB1|SB5" .And. SuperGetMv("MV_CPLPRO",.F.,"2") == "1"
		OMSXJOBCAD(cTabela,4)
	EndIf
Return lRet

//=============================================================================
// FUNCIONALIDADES MODULO TMS
//=============================================================================
/*/{Protheus.doc} TMSXADDDUT
Adiciona o xml de um tipo de veículo posicionado 'DUT' para enviar ao CPL
@author jackson.werka
@since 28/05/2018
@param oWsCpl, object, Cliente de webservice compativel
/*/
Function TMSXADDDUT(oWsCpl)
Local cCodFil := OMSXGETFIL("DUT")

	OsLogCPL("OMSXCPL -> TMSXADDDUT -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<vehicles>")
	oWsCpl:AddSoap("<vehicles>")
	oWsCpl:AddSoap("<vehicle>")

	//WSSoapValue Cria a tag/conteúdo
	oWsCpl:AddSoap(RegionSourceId())
	oWsCpl:AddSoap(WSSoapValue("identifier", RTrim(DUT->DUT_TIPVEI) + RTrim(cCodFil), RTrim(DUT->DUT_TIPVEI)  + RTrim(cCodFil), "string", .F. , .F., 0 , NIL, .F.) )
	oWsCpl:AddSoap(WSSoapValue("name", ALLTRIM(DUT->DUT_DESCRI), ALLTRIM(DUT->DUT_DESCRI) , "string", .F. , .F., 0 , NIL, .F.)       )
	oWsCpl:AddSoap(WSSoapValue("description", ALLTRIM(DUT->DUT_DESCRI), ALLTRIM(DUT->DUT_DESCRI) , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("priority", 0, 0 , "int", .F. , .F., 0 , NIL, .F.) )
	oWsCpl:AddSoap(WSSoapValue("similarity", 0, 0 , "int", .F. , .F., 0 , NIL, .F.) )

	oWsCpl:AddSoap("</vehicle>")
	oWsCpl:AddSoap("</vehicles>")
	oWsCpl:AddSoap("</vehicles>")

	OsLogCPL("OMSXCPL -> TMSXADDDUT -> Final do metodo.","INFO")

Return

/*/{Protheus.doc} OMSXADDDUL
	Adiciona o xml de um endereço de  solicitante posicionado 'DUL'
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param oWsCpl, object, Cliente de webservice compativel
@example
(examples)
@see (links_or_references)
/*/
Function OMSXADDDUL(oWsCpl)
	Local cCodLocal
	Local xfSA1 := xFilial("SA1")
	Local cCodFil := OMSXGETFIL("DUL")
	Local cCdCli := DUL->DUL_CODCLI
	Local cLjCli := DUL->DUL_LOJCLI
	Local cTel   := DUL->DUL_TEL
	Local cDDD   := DUL->DUL_DDD
	Local cQry	:= GetSlct("SA1")
	Local cSA1

	OsLogCPL("OMSXCPL -> OMSXADDDUL -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<localities>")
	oWsCpl:AddSoap("<locality>")

	oWsCpl:AddSoap(WSSoapValue("addressCity", StrTrim(DUL->DUL_MUN,50), StrTrim(DUL->DUL_MUN,50) , "string", .F. , .F., 0 , NIL, .F.)          )

	cCodLocal := CodPais(DUL->DUL_EST)
	oWsCpl:AddSoap(WSSoapValue("addressCountryAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                                        )

	oWsCpl:AddSoap(WSSoapValue("addressDistrict", StrTrim(DUL->DUL_BAIRRO,50), StrTrim(DUL->DUL_BAIRRO,50) , "string", .F. , .F., 0 , NIL, .F.))

	cCodLocal := LjFiGetEnd(DUL->DUL_END, DUL->DUL_EST, .T.)
	oWsCpl:AddSoap(WSSoapValue("addressNumber", StrTrim(cCodLocal[3],30), StrTrim(cCodLocal[3],30) , "string", .F. , .F., 0 , NIL, .F.)  )

	cCodLocal := CodEstado(DUL->DUL_EST)
	oWsCpl:AddSoap(WSSoapValue("addressStateAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                    )

	oWsCpl:AddSoap(WSSoapValue("addressStreet", StrTrim(DUL->DUL_END,200), StrTrim(DUL->DUL_END,200) , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressZipCode", ALLTRIM(DUL->DUL_CEP), ALLTRIM(DUL->DUL_CEP) , "string", .F. , .F., 0 , NIL, .F.)                         )
	oWsCpl:AddSoap(WSSoapValue("logisticRoleId", 2, 2 , "int", .F. , .F., 0 , NIL, .F.)                                                )//Ambos

	If SA1->A1_COD == cCdCli .And.  SA1->A1_LOJA == cLjCli .And. SA1->A1_FILIAL == xfSA1
		oWsCpl:AddSoap(WSSoapValue("description", Transform(SA1->A1_NOME,"@!"), Transform(SA1->A1_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.)                          )
		oWsCpl:AddSoap(WSSoapValue("name", Transform(SA1->A1_NREDUZ,"@!"), Transform(SA1->A1_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.)                             )
	Else
		cSA1 := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQry + " AND " + GetFiltro({"A1_FILIAL","A1_COD","A1_LOJA"},{xfSA1,cCdCli,cLjCli})), cSA1, .T., .T. )
		If !(cSA1)->(Eof()) .And. !Empty((cSA1)->A1_COD)
			oWsCpl:AddSoap(WSSoapValue("description", Transform((cSA1)->A1_NOME,"@!"), Transform((cSA1)->A1_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.)                          )
			oWsCpl:AddSoap(WSSoapValue("name", Transform((cSA1)->A1_NREDUZ,"@!"), Transform((cSA1)->A1_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.)                             )
		Else
			(cSA1)->(dbCloseArea())
			dbUseArea( .T., "TOPCONN", TCGenQry(,,cQry + " AND " + GetFiltro({"A1_FILIAL","A1_TEL","A1_DDD"},{xfSA1,cTel,cDDD})), cSA1, .T., .T. )
			If !(cSA1)->(Eof()) .And. !Empty((cSA1)->A1_COD)
				oWsCpl:AddSoap(WSSoapValue("description", Transform((cSA1)->A1_NOME,"@!"), Transform((cSA1)->A1_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.)                          )
				oWsCpl:AddSoap(WSSoapValue("name", Transform((cSA1)->A1_NREDUZ,"@!"), Transform((cSA1)->A1_NREDUZ,"@!") , "string", .F. , .F., 0 , NIL, .F.)                             )
			Else
				oWsCpl:AddSoap(WSSoapValue("description", Transform(cTel + cDDD,"@!"), Transform(cTel + cDDD,"@!") , "string", .F. , .F., 0 , NIL, .F.)                          )
				oWsCpl:AddSoap(WSSoapValue("name", Transform(cTel + cDDD,"@!"), Transform(cTel + cDDD,"@!") , "string", .F. , .F., 0 , NIL, .F.)                             )
			EndIf
		EndIf
		(cSA1)->(dbCloseArea())
	EndIf
	dbSelectArea("DUL")
	oWsCpl:AddSoap(RegionSourceId())
	cCodLocal := "SOL-" + RTrim(cDDD) + '-' + RTrim(cTel) + '-' + RTrim(DUL->DUL_SEQEND) + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap("</locality>")
	oWsCpl:AddSoap("</localities>")

	OsLogCPL("OMSXCPL -> OMSXADDDUL -> Final do metodo.","INFO")

Return
/*/{Protheus.doc} OMSXADDDUE
	Adiciona o xml de um solicitante posicionado 'DUE'
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param oWsCpl, object, Cliente de webservice compativel
@example
(examples)
@see (links_or_references)
/*/
Function OMSXADDDUE(oWsCpl)
	Local cCodLocal
	Local cCodFil := OMSXGETFIL("DUE")

	OsLogCPL("OMSXCPL -> OMSXADDDUE -> Inicio do metodo.","INFO")

	oWsCpl:AddSoap("<localities>")
	oWsCpl:AddSoap("<locality>")

	oWsCpl:AddSoap(WSSoapValue("addressCity", StrTrim(DUE->DUE_MUN,50), StrTrim(DUE->DUE_MUN,50) , "string", .F. , .F., 0 , NIL, .F.)          )

	cCodLocal := CodPais(DUE->DUE_EST)
	oWsCpl:AddSoap(WSSoapValue("addressCountryAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                                        )

	oWsCpl:AddSoap(WSSoapValue("addressDistrict", StrTrim(DUE->DUE_BAIRRO,50), StrTrim(DUE->DUE_BAIRRO,50) , "string", .F. , .F., 0 , NIL, .F.))

	cCodLocal := LjFiGetEnd(DUE->DUE_END, DUE->DUE_EST, .T.)
	oWsCpl:AddSoap(WSSoapValue("addressNumber", StrTrim(cCodLocal[3],30), StrTrim(cCodLocal[3],30) , "string", .F. , .F., 0 , NIL, .F.)  )

	cCodLocal := CodEstado(DUE->DUE_EST)
	oWsCpl:AddSoap(WSSoapValue("addressStateAcronym", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.)                    )

	oWsCpl:AddSoap(WSSoapValue("addressStreet", StrTrim(DUE->DUE_END,200), StrTrim(DUE->DUE_END,200) , "string", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(WSSoapValue("addressZipCode", ALLTRIM(DUE->DUE_CEP), ALLTRIM(DUE->DUE_CEP) , "string", .F. , .F., 0 , NIL, .F.)                         )
	oWsCpl:AddSoap(WSSoapValue("logisticRoleId", 2, 2 , "int", .F. , .F., 0 , NIL, .F.)                                                )//Ambos

	oWsCpl:AddSoap(WSSoapValue("description", Transform(DUE->DUE_NOME,"@!"), Transform(DUE->DUE_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.)                          )
	oWsCpl:AddSoap(WSSoapValue("name", Transform(DUE->DUE_NOME,"@!"), Transform(DUE->DUE_NOME,"@!") , "string", .F. , .F., 0 , NIL, .F.)                             )

	oWsCpl:AddSoap(RegionSourceId())
	cCodLocal := "SOL-" + RTrim(DUE->DUE_DDD) + '-' + RTrim(DUE->DUE_TEL) + RTrim(cCodFil)
	oWsCpl:AddSoap(WSSoapValue("identifier", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap("</locality>")
	oWsCpl:AddSoap("</localities>")

	OsLogCPL("OMSXCPL -> OMSXADDDUE -> Final do metodo.","INFO")

Return

Function TMSXADDDUD(oWsCpl, nOperacao)
Local cFilBkp    := cFilAnt
Local cDudRecno  := ""
Local cCodRel    := ""
Local cCodFlOri  := ""
Local cCodLocal  := ""
Local cCodFlAtu  := ""
Local cCodTms    := ""
Local cAlsql     := ""
Local cCodSol    := ""
Local cCodFil    := ""
Local cDudTipTra := ""
Local dDataIni
Local dDataFim
Local cHoraIni
Local cHoraFim
Local cFilSB1    := OMSXGETFIL("SB1")

	OsLogCPL("OMSXCPL -> TMSXADDDUD -> Inicio do metodo.","INFO")

	If FWModeAccess("DT6")=="E"
		cFilAnt := DT6->DT6_FILIAL
	EndIf

	oWsCpl:cIniMetodo := "<ord:" + oWsCpl:cMetodo + " xmlns:ord='http://www.neolog.com.br/cpl/acquisition/order/'" +;
					" xmlns:att='http://www.neolog.com.br/cpl/acquisition/attribute/'"              +;
					" xmlns:clas='http://www.neolog.com.br/cpl/acquisition/classification/'"        +;
					" xmlns:del='http://www.neolog.com.br/cpl/acquisition/deliveryUnit/'"           +;
					" xmlns:ord1='http://www.neolog.com.br/cpl/acquisition/orderItemDu/'"           +;
					" xmlns:ord2='http://www.neolog.com.br/cpl/acquisition/orderitem/'"             +;
					" xmlns:ord3='http://www.neolog.com.br/cpl/acquisition/orderItem/'>"

	oWsCpl:cFimMetodo := "</ord:" + oWsCpl:cMetodo + ">"

	oWsCpl:AddSoap("<ord:orderList>")
	oWsCpl:AddSoap("<ord:orders>")
	oWsCpl:AddSoap("<ord:order>")

	oWsCpl:AddSoap(RegionSourceId("ord:"))

	cDudRecno := cValToChar(DUD->(RecNo()))

	cCodRel := cDudRecno + '-' + _MV_CPLIDS
	oWsCpl:AddSoap(WSSoapValue("ord:identifier", cCodRel, cCodRel , "string", .F. , .F., 0 , NIL, .F.))

	oWsCpl:AddSoap(ShipperId("ord:"))

	If nOperacao != MODEL_OPERATION_DELETE

		cCodFlOri := DUD->DUD_FILORI
		cCodLocal := RTrim(DT6->DT6_FILDOC) + '-' + RTrim(DT6->DT6_DOC) + '-' + RTrim(DT6->DT6_SERIE) + '-' + RTrim(cCodFlOri)
		oWsCpl:AddSoap(WSSoapValue("ord:code", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))

		cCodTms := DUD->DUD_SERTMS
		cCodFlAtu := DUD->DUD_FILATU

		If cCodTms == '1'
			If Empty(DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO))
				cAlsql := OMSXGetDum({xFilial("DUM"),DT6->DT6_FILORI,DT6->DT6_DOC})
			Else
				cAlsql := OMSXGetDum({xFilial("DUM"),DT6->DT6_FILDCO,DT6->DT6_DOCDCO})
			EndIf
		Else
			If Empty(DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO))
				cAlsql := OMSXGetDtc({DT6->DT6_FILIAL,DT6->DT6_DOC   ,DT6->DT6_SERIE ,DT6->DT6_FILDOC})
			Else
				cAlsql := OMSXGetDtc({DT6->DT6_FILIAL,DT6->DT6_DOCDCO,DT6->DT6_SERDCO,DT6->DT6_FILDCO})
			EndIf
		EndIf
		dbSelectarea(oWsCpl:cTabela)
		dDataIni := GetOmsxData("dDataIni")
		dDataFim := GetOmsxData("dDataFim")
		cHoraIni := GetOmsxData("cHoraIni")
		cHoraFim := GetOmsxData("cHoraFim")
		cDudTipTra := DUD->DUD_TIPTRA

		If Empty(dDataIni)
			dDataIni := Date()
		EndIf

		If Empty(dDataFim)
			dDataFim := Date()
		EndIf

		If Empty(cHoraIni)
			cHoraIni := Time()
		EndIf

		If Empty(cHoraFim)
			cHoraFim := "23:59:59"
		EndIf

		cCodLocal := FWTimeStamp( 5, dDataFim , cHoraIni  )
		oWsCpl:AddSoap(WSSoapValue("ord:deliveryEnd", cCodLocal, cCodLocal , "dateTime", .F. , .F., 0 , NIL, .F.))

		cCodLocal := FWTimeStamp( 5, dDataIni , cHoraIni  )
		oWsCpl:AddSoap(WSSoapValue("ord:deliveryStart", cCodLocal, cCodLocal , "dateTime", .F. , .F., 0 , NIL, .F.))

		cCodLocal := FWTimeStamp( 5, DATE() , TIME()  )
		oWsCpl:AddSoap(WSSoapValue("ord:erpCreationDt", cCodLocal, cCodLocal , "dateTime", .F. , .F., 0 , NIL, .F.))

		oWsCpl:AddSoap(WSSoapValue("ord:incoterm", "1", "1" , "string", .F. , .F., 0 , NIL, .F.))

		If cDudTipTra == '3' //Aquaviário/fluvial
			cDudTipTra := 2
		ElseIf cDudTipTra == '2'
			cDudTipTra := 4
		ElseIf cDudTipTra == '1' .Or. cDudTipTra == '4'
			cDudTipTra := 1
		EndIf

		oWsCpl:AddSoap(WSSoapValue("ord:modal", cDudTipTra, cDudTipTra , "int", .F. , .F., 0 , NIL, .F.))

		oWsCpl:AddSoap(WSSoapValue("ord:integrationDataSource", _MV_CPLIDS, _MV_CPLIDS , "string", .F. , .F., 0 , NIL, .F.))

		If cCodTms == "1" //Coleta
			cCodLocal := _MV_CPLTP1
		ElseIf cCodTms == "2" //Transporte
			cCodLocal := _MV_CPLTP2
		ElseIf cCodTms == "3" //Entrega
			cCodLocal := _MV_CPLTP3
		EndIf

		If Empty(cCodLocal)
			cCodLocal := Nil
		EndIf

		oWsCpl:AddSoap(WSSoapValue("ord:orderTypeSourceId", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))

		(cAlsql)->(dbGoTop())
		If cCodTms == '1'
			cCodLocal := 'FIL-' + RTrim(DT6->DT6_FILORI)

			cCodSol := GetOmsxData("DT5_SEQEND")
			If Empty(cCodSol)
				cCodFil := OMSXGETFIL("DUE")
				cCodSol := "SOL-" + RTrim(GetOmsxData("DT5_DDD")) + '-' + RTrim(GetOmsxData("DT5_TEL")) + RTrim(cCodFil)
			Else
				cCodFil := OMSXGETFIL("DUL")
				cCodSol := "SOL-" + RTrim(GetOmsxData("DT5_DDD")) + '-' + RTrim(GetOmsxData("DT5_TEL")) + '-' + RTrim(cCodSol) + RTrim(cCodFil)
			EndIf

		ElseIf cCodTms == '2' .And. (_MV_CPLENT == "2" .Or. Empty(_MV_CPLENT))
			cCodLocal := 'FIL-' + RTrim(DT6->DT6_FILDES)
			cCodSol := ""
		Else
			cCodSol := ""
			If Empty((cAlsql)->SQEDES)
				cCodFil := OMSXGETFIL("SA1")
				cCodLocal := 'CLI-' + RTrim(DT6->DT6_CLIDES) + '-' + RTrim(DT6->DT6_LOJDES) + RTrim(cCodFil)
			Else
				If DUL->(IndexOrd()) != 2
					DUL->(dbSetOrder(2))
				EndIf
				DUL->(DbSeek(xFilial('DUL')+ (cAlsql)->CLIDES + (cAlsql)->LOJDES + (cAlsql)->SQEDES))
				cCodFil := OMSXGETFIL("DUL")
				cCodLocal := 'SOL-' + RTrim(DUL->DUL_DDD) + '-' + RTrim(DUL->DUL_TEL) + '-' + RTrim(DUL->DUL_SEQEND) + RTrim(cCodFil)
			EndIf
		EndIf
		dbSelectArea(oWsCpl:cTabela)
		oWsCpl:AddSoap(WSSoapValue("ord:destinationId", cCodLocal, cCodLocal, "string", .F. , .F., 0 , NIL, .F.))

		cCodLocal := FWTimeStamp( 5, DATE() , TIME()  )
		oWsCpl:AddSoap(WSSoapValue("ord:pickupStart", cCodLocal, cCodLocal, "dateTime", .F. , .F., 0 , NIL, .F.))

		oWsCpl:AddSoap(WSSoapValue("ord:priority", 0, 0, "int", .F. , .F., 0 , NIL, .F.))

		If !(cAlsql)->(Eof())
			oWsCpl:AddSoap("<ord:items>")
			oWsCpl:AddSoap("<ord2:orderItems>")
			While !(cAlsql)->(Eof())
				oWsCpl:AddSoap("<ord3:orderItem>")

				oWsCpl:AddSoap(WSSoapValue("ord3:orderId", cCodRel, cCodRel , "string", .F. , .F., 0 , NIL, .F.))

				If cCodTms $ '2;3'
					cCodLocal := "FIL-" + RTrim(cCodFlAtu)
				Else
					cCodLocal := cCodSol
					/*If Empty(cCodLocal)
						cCodLocal := "CLI-" + RTrim(DT6->DT6_CLIREM) + "-" + RTrim(DT6->DT6_LOJREM)
					EndIf*/
				EndIf

				oWsCpl:AddSoap(WSSoapValue("ord3:originId", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))

				oWsCpl:AddSoap(WSSoapValue("ord3:price", 0.01, Iif(Empty((cAlsql)->VALOR) .Or. (cAlsql)->VALOR == 0 ,Nil,(cAlsql)->VALOR) , "double", .F. , .F., 0 , NIL, .F.))

				cCodLocal := StrTrim((cAlsql)->CODPRO + cFilSB1,30)
				oWsCpl:AddSoap(WSSoapValue("ord3:productId", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))


				If Empty((cAlsql)->QTDVOL) .Or. (cAlsql)->QTDVOL == 0
					nQtdVol := 1
				Else
					nQtdVol := (cAlsql)->QTDVOL
				EndIf

				oWsCpl:AddSoap(WSSoapValue("ord3:quantity", nQtdVol, nQtdVol , "double", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:quantityInShipmentUnits", nQtdVol, nQtdVol , "double", .F. , .F., 0 , NIL, .F.))

				oWsCpl:AddSoap(WSSoapValue("ord3:shipmentUnitWrapperCode", _MV_CPLINV, _MV_CPLINV , "string", .F. , .F., 0 , NIL, .F.))

				cCodLocal := cDudRecno + '-' + RTrim((cAlsql)->R_E_C_N_O_) + '-' +  _MV_CPLIDS

				If Len(cCodLocal) > 30
					cCodLocal := cDudRecno + '-' + RTrim((cAlsql)->R_E_C_N_O_)
				EndIf

				oWsCpl:AddSoap(WSSoapValue("ord3:sourceId", cCodLocal, cCodLocal , "string", .F. , .F., 0 , NIL, .F.))

				oWsCpl:AddSoap(WSSoapValue("ord3:weight", 0.01, Iif(Empty((cAlsql)->PESO),Nil,(cAlsql)->PESO/nQtdVol) , "double", .F. , .F., 0 , NIL, .F.))
//							If lTemDte
				oWsCpl:AddSoap(WSSoapValue("ord3:height", nDimPadrao, Iif(Empty((cAlsql)->ALTURA),Nil,(cAlsql)->ALTURA) , "double", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:width", nDimPadrao, Iif(Empty((cAlsql)->LARGUR),Nil,(cAlsql)->LARGUR) , "double", .F. , .F., 0 , NIL, .F.))
				oWsCpl:AddSoap(WSSoapValue("ord3:length", nDimPadrao, Iif(Empty((cAlsql)->COMPRI),Nil,(cAlsql)->COMPRI) , "double", .F. , .F., 0 , NIL, .F.))
//							EndIf


				oWsCpl:AddSoap("</ord3:orderItem>")
				(cAlsql)->(dbSkip())
			EndDo
			oWsCpl:AddSoap("</ord2:orderItems>")
			oWsCpl:AddSoap("</ord:items>")
		EndIf
		(cAlsql)->(dbclosearea())
	EndIf
	oWsCpl:AddSoap("</ord:order>")
	oWsCpl:AddSoap("</ord:orders>")
	oWsCpl:AddSoap("</ord:orderList>")

	ClrOmsxData()
	cFilAnt := cFilBkp

	OsLogCPL("OMSXCPL -> TMSXADDDUD -> Final do metodo.","INFO")

Return

Function TMSXLIBDJZ(oWsCpl)
Local aAreaAnt  := GetArea()
Local cAliasQry := ""
Local cQuery    := ""

	OsLogCPL("OMSXCPL -> TMSXLIBDJZ -> Inicio do metodo.","INFO")

	oWsCpl:cIniMetodo := "<unb:" + oWsCpl:cMetodo + ' xmlns:unb="http://www.neolog.com.br/cpl/acquisition/unblockRelTrip/" '+;
							'xmlns:erp="http://www.neolog.com.br/cpl/acquisition/eRPMessageResponse/" '+;
							'xmlns:ord="http://www.neolog.com.br/cpl/acquisition/orderBreakRemovalRequest/" '+;
							'xmlns:ord1="http://www.neolog.com.br/cpl/acquisition/orderBreakId/" '+;
							'xmlns:ord2="http://www.neolog.com.br/cpl/acquisition/orderBreakResponse/" '+;
							'xmlns:trip="http://www.neolog.com.br/cpl/acquisition/tripReleaseResponse/" '+;
							'xmlns:trip1="http://www.neolog.com.br/cpl/acquisition/tripLoadsSourceId/">'

	oWsCpl:cFimMetodo := "</unb:" + oWsCpl:cMetodo + ">"

	oWsCpl:AddSoap("<unb:unblockReleasedTrips>")
	oWsCpl:AddSoap("<unb:unblockReleasedTrips>")
	oWsCpl:AddSoap("<unb:unblockReleasedTrip>")

	oWsCpl:AddSoap(WSSoapValue("unb:identifier", DJZ->DJZ_CPLMSG, DJZ->DJZ_CPLMSG , "int", .F. , .F., 0 , NIL, .F.))
	oWsCpl:AddSoap(RegionSourceId("unb:"))

	oWsCpl:AddSoap("<unb:tripReleaseResponses>")
	oWsCpl:AddSoap("<trip:tripReleaseResponseList>")

	cQuery := "SELECT DJY_ORITID, DJY_ORSRID"
	cQuery +=  " FROM "+RetSqlName("DJY")
	cQuery += " WHERE DJY_FILIAL = '"+xFilial("DJY")+"'"
	cQuery +=   " AND DJY_RGSRID = '"+DJZ->DJZ_RGSRID+"'"
	cQuery +=   " AND DJY_VIAGID = '"+DJZ->DJZ_VIAGID+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )

	OsLogCPL("OMSXCPL -> TMSXLIBDJZ -> Conteudo da query DJY: " + cValToChar(cQuery),"INFO")

	If (cAliasQry)->(!Eof())
		oWsCpl:AddSoap("<trip:tripReleaseResponses>")

		While (cAliasQry)->(!Eof())

			oWsCpl:AddSoap("<trip:tripReleaseResponse>")

			oWsCpl:AddSoap(WSSoapValue("trip:itemId", RTrim((cAliasQry)->DJY_ORITID), RTrim((cAliasQry)->DJY_ORITID) , "string", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(WSSoapValue("trip:orderSourceId", RTrim((cAliasQry)->DJY_ORSRID), RTrim((cAliasQry)->DJY_ORSRID) , "string", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(RegionSourceId("trip:"))
			oWsCpl:AddSoap(WSSoapValue("trip:status", 1, 1 , "int", .F. , .F., 0 , NIL, .F.))
			oWsCpl:AddSoap(WSSoapValue("trip:tripCode", RTrim(DJZ->DJZ_VIAGID), RTrim(DJZ->DJZ_VIAGID) , "string", .F. , .F., 0 , NIL, .F.))

			oWsCpl:AddSoap("</trip:tripReleaseResponse>")

			(cAliasQry)->(dbSkip())
		EndDo
		oWsCpl:AddSoap("</trip:tripReleaseResponses>")
	EndIf
	(cAliasQry)->(dbCloseArea())

	oWsCpl:AddSoap("</trip:tripReleaseResponseList>")
	oWsCpl:AddSoap("</unb:tripReleaseResponses>")
	oWsCpl:AddSoap("</unb:unblockReleasedTrip>")
	oWsCpl:AddSoap("</unb:unblockReleasedTrips>")
	oWsCpl:AddSoap("</unb:unblockReleasedTrips>")

	RestArea(aAreaAnt)

	OsLogCPL("OMSXCPL -> TMSXLIBDJZ -> Final do metodo.","INFO")
Return

/*/{Protheus.doc} GetSlct
	Retorna um select Genérico
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cTabela, characters, Alias de tabela
@param lWhere, logical, Se deve adicionar clausula where padrão.
@example
(examples)
@see (links_or_references)
/*/
Static Function GetSlct(cTabela,lWhere)
	Default lWhere := .T.
Return "SELECT * FROM "  + RetSqlName(cTabela) + " " + cTabela + IIf(lWhere," WHERE " + cTabela + ".D_E_L_E_T_ = '' ",'')
/*/{Protheus.doc} GetFiltro
	Converte um array de campos e valores para ser utilizado em query. O comparador lógico adicionado é sempre 'and'
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aCampos, array, Array de uma dimensão com os campos
@param aFiltro, array, Array de uma dimensão com os valores
@example
(examples)
@see (links_or_references)
/*/
Static Function GetFiltro(aCampos,aFiltro)
	Local cFiltro := ""
	Local nX
	Local cCont
	For nX := 1 To Len(aCampos)
		If !Empty(cFiltro)
			cFiltro += " AND "
		EndIf
		If ValType("aFiltro[nX]") == "C"
			cCont := "'" + cValToChar(aFiltro[nX]) + "'"
		ElseIf ValType("aFiltro[nX]") == "D"
			cCont := "'" + DTOS(aFiltro[nX]) + "'"
		Else
			cCont := cValToChar(aFiltro[nX])
		EndIf
		cFiltro += aCampos[nX] + " = " + cCont + " "
	Next nX
Return cFiltro
/*/{Protheus.doc} OMSXGetDum
	Retorna os dados dos itens relacionados a uma coleta
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aChave, array, Array de identificação do documento
@example
(examples)
@see (links_or_references)
/*/
Function OMSXGetDum(aChave)
	Local cAl := GetNextAlias()
	Local cQuery := ""
	Local aStru := DUM->(dbStruct())
	Local nI
	Local nT := len(aStru)

	OsLogCPL("OMSXCPL -> OMSXGetDum -> Inicio do metodo.","INFO")

	cQuery += "SELECT DISTINCT '' SQEDES, '' CLIDES, '' LOJDES, DUM.DUM_VALMER VALOR, DUM.DUM_CODPRO CODPRO, COALESCE('DTE' + CAST(DTE.R_E_C_N_O_ AS VARCHAR),'DUM' + CAST(DUM.R_E_C_N_O_ AS VARCHAR)) R_E_C_N_O_, DUM.DUM_PESO PESO, "
	cQuery += " COALESCE(DTE.DTE_QTDVOL, DUM.DUM_QTDVOL)     QTDVOL,"
	cQuery += " COALESCE(DTE.DTE_ALTURA,SB5.B5_ALTURA,0.001) ALTURA,"
	cQuery += " COALESCE(DTE.DTE_LARGUR,SB5.B5_LARG,0.001)   LARGUR,"
	cQuery += " COALESCE(DTE.DTE_COMPRI,SB5.B5_COMPR,0.001)  COMPRI "
	cQuery += " FROM " + RetSqlName("DUM") + " DUM "
	cQuery += " LEFT JOIN " + RetSqlName("DTE") + " DTE "
	cQuery += " ON DTE_FILIAL = '" + xFilial('DTE') + "' "
	cQuery += "      AND DTE.DTE_FILORI = DUM.DUM_FILORI"
	cQuery += "      AND DTE.DTE_NUMSOL = DUM.DUM_NUMSOL"
	cQuery += "      AND DTE.DTE_ITESOL = DUM.DUM_ITEM "
	cQuery += "      AND DTE.D_E_L_E_T_ = ''            "
	cQuery += " LEFT JOIN " + RetSqlName("SB5") + " SB5 "
	cQuery += " ON SB5.B5_FILIAL = '" + xFilial('SB5') + "' "
	cQuery += "      AND SB5.B5_COD = DUM.DUM_CODPRO "
	cQuery += "      AND SB5.D_E_L_E_T_ = ''            "
	cQuery += " WHERE DUM.D_E_L_E_T_ = ''  "
	cQuery += " AND " + GetFiltro({"DUM.DUM_FILIAL","DUM.DUM_FILORI","DUM.DUM_NUMSOL"},aChave)
	cQuery += " AND DUM.DUM_CODPRO <> '' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAl, .T., .T. )

	OsLogCPL("OMSXCPL -> OMSXGetDum -> Conteudo da query DUM+DTE+SB5: " + cValToChar(cQuery),"INFO")

	For nI := 1 to nT
		If ( aStru[nI][2] $ 'D') .And. (cAl)->(FieldPos(aStru[ni,1])) > 0
			TCSetField(cAl,aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next nI

	OsLogCPL("OMSXCPL -> OMSXGetDum -> Final do metodo.","INFO")

Return cAl
/*/{Protheus.doc} OMSXGetDtc
	Retorna os dados dos itens relacionados a um transporte ou entrega
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aChave, array, Array de identificação do documento
@example
(examples)
@see (links_or_references)
/*/
Function OMSXGetDtc(aChave)
	Local cAl := GetNextAlias()
	Local cQuery := ""
	Local aStru := DTC->(dbStruct())
	Local nI
	Local nT := len(aStru)

	OsLogCPL("OMSXCPL -> OMSXGetDtc -> Inicio do metodo.","INFO")

	cQuery += "SELECT DISTINCT DTC.DTC_SQEDES SQEDES, DTC.DTC_CLIDES CLIDES, DTC.DTC_LOJDES LOJDES, DTC.DTC_VALOR VALOR, DTC.DTC_CODPRO CODPRO, COALESCE('DTE' + CAST(DTE.R_E_C_N_O_ AS VARCHAR),'DTC' + CAST(DTC.R_E_C_N_O_ AS VARCHAR)) R_E_C_N_O_, DTC.DTC_PESO PESO, DTE.DTE_NUMNFC,"
	cQuery += " COALESCE(DTE.DTE_QTDVOL,DTC.DTC_QTDVOL) QTDVOL,"
	cQuery += " COALESCE(DTE.DTE_ALTURA,SB5.B5_ALTURA,0.001) ALTURA,"
	cQuery += " COALESCE(DTE.DTE_LARGUR,SB5.B5_LARG,0.001) LARGUR,"
	cQuery += " COALESCE(DTE.DTE_COMPRI,SB5.B5_COMPR,0.001) COMPRI "
	cQuery += " FROM " + RetSqlName("DTC") + " DTC "
	cQuery += " LEFT JOIN " + RetSqlName("DTE") + " DTE "
	cQuery += " ON DTE_FILIAL = '" + xFilial('DTE') + "' "
	cQuery += "      AND DTE.DTE_FILORI = DTC.DTC_FILORI"
	cQuery += "      AND DTE.DTE_NUMNFC = DTC.DTC_NUMNFC"
	cQuery += "      AND DTE.DTE_SERNFC = DTC.DTC_SERNFC"
	cQuery += "      AND DTE.DTE_CLIREM = DTC.DTC_CLIREM"
	cQuery += "      AND DTE.DTE_LOJREM = DTC.DTC_LOJREM"
	cQuery += "      AND DTE.DTE_CODPRO = DTC.DTC_CODPRO"
	cQuery += "      AND DTE.D_E_L_E_T_ = ''            "
	cQuery += " LEFT JOIN " + RetSqlName("SB5") + " SB5 "
	cQuery += " ON SB5.B5_FILIAL = '" + xFilial('SB5') + "' "
	cQuery += "      AND SB5.B5_COD = DTC.DTC_CODPRO"
	cQuery += "      AND SB5.D_E_L_E_T_ = ''            "
	cQuery += " WHERE DTC.D_E_L_E_T_ = ''  "
	cQuery += " AND " + GetFiltro({"DTC.DTC_FILIAL","DTC.DTC_DOC","DTC.DTC_SERIE","DTC.DTC_FILDOC"},aChave)
	cQuery += " AND DTC.DTC_CODPRO <> '' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAl, .T., .T. )

	OsLogCPL("OMSXCPL -> OMSXGetDtc -> Conteudo da query DUM+DTE+SB5: " + cValToChar(cQuery),"INFO")

	For nI := 1 to nT
		If ( aStru[nI][2] $ 'D') .And. (cAl)->(FieldPos(aStru[ni,1])) > 0
			TCSetField(cAl,aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next nI

	OsLogCPL("OMSXCPL -> OMSXGetDtc -> Final do metodo.","INFO")

Return cAl
/*/{Protheus.doc} OmsPedCPL
Verifica se pedido está integrado com o CPL
@author amanda.vieira
@since 06/12/2018
@version 1.0
/*/
Function OmsPedCPL(cFilPed,cPedido)
Local lRet := .F.
Local lIntrot  := SC6->(ColumnPos("C6_INTROT")) > 0
Local lIntCpl := SuperGetMv("MV_CPLINT",.F.,"2") == "1" //Indica se o sistema integra com o Planejamento CPL 

    If !lIntCpl .OR. !lIntrot
       lRet := .T.
    ELSE    
    	SC6->(DbSetOrder(1))
    	If SC6->(DbSeek(cFilPed+cPedido))
    		lRet := (SC6->C6_INTROT == "1" .Or. SC6->C6_INTROT == "4")
    	EndIf
    EndIf
Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} OsLogCPL()
Efetua gravação de log.

@author Squad OMS
@since 18/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function OsLogCPL(cMessage, cType)
Local cInfoData   := ""
Local oFileReader := ""
Local cLineAux    := ""
Local cStrAux     := ""
Local cNomeArq    := "OmsCPL.log"
Local lGlbOMSVl   := .F.
Local oFileLog    := Nil
Local cTipLog     := GetGlbValue("GLB_OMSTIP")
Default cType     := "INFO"
Default cMessage  := ""

if !Empty(GetGlbValue("GLB_OMSLOG"))
	lGlbOMSVl := &(GetGlbValue("GLB_OMSLOG"))
	If lGlbOMSVl
		If Upper(cTipLog) == 'CONSOLE'
			LogMsg( "OMSXCPL",0, 0,1, cValToChar(TIME()), cType, cMessage )
		Else
			If oFileLog == Nil
				oFileLog := FWFileWriter():New(cNomeArq,.F.)
			EndIf

			//Busca os dados já existentes no arquivo, caso ele exista.
			If oFileLog:Exists()
				oFileReader := FWFileReader():New(cNomeArq)
				if (oFileReader:Open())
					While (oFileReader:hasLine())
						cLineAux := oFileReader:GetLine(.T.)
						If !Empty(cLineAux)
							cStrAux += cLineAux
						EndIf
					EndDo
					oFileReader:Close()
				EndIF       
			Else
				oFileLog:Create()
			EndIf
			
			If !Empty(cStrAux)
				oFileLog:Open(FO_WRITE+FO_SHARED)
				oFileLog:Write(cStrAux)
			EndIf

			cInfoData := "["+cType+"] "
			cInfoData += "[THREAD " + cValToChar(ThreadId()) + "] "
			cInfoData += "["+ DtoC(Date()) + " " + Time() +"] "
			cMessage := cInfoData + cMessage + CRLF
			oFileLog:Write(cMessage)
			oFileLog:Close()
		EndIf
	EndIf
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OmCPLIns
Função Criada para grava a data dos fontes envolvidos na integração com A NEOLOG no LOGOMSCPL
@author Murilo Brandão
@version P12
@Since	24/03/2021
@version 1.0
/*/
//-----------------------------------------------------------

Function OmCPLIns()
local aFontes := {'OMSXWS.PRW','OMSXCPL.PRW','OMSXCPL1.PRW','OMSXCPL2.PRW','OMSXCPL3.PRW','OMSXCPL4.PRW','OMSXCPL6.PRW','OMSXCPL6A.PRW','OMSXCPL6B.PRW','OMSXCPL7.PRW','OMSXCPLA.PRW','OMSXCPLB.PRW','OMSXCPLWS.PRW',"TMSXWS.PRW"}
local aInfo := {}
local nX := 1

	for nX := 1 to Len(aFontes)
		aInfo := GetApoInfo(aFontes[nX])
		OsLogCPL("Versão Fonte " + cValToChar(Trim(aFontes[nX])) + ":" + cValToChar(aInfo[4]) + " " + "Hora" + ":" + cValToChar(aInfo[5]),"INFO")
	next nX

return nil
