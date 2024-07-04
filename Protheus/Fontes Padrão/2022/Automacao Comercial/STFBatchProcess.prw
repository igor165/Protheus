#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "STFBatchProcess.CH"

#DEFINE TABLE              1
#DEFINE UNIQUE_INDEX       2
#DEFINE STATUS_INDEX       3
#DEFINE STATUS_FIELD       4
#DEFINE ERROR_FIELD        5	// Optional
#DEFINE STATE_TOPROCESS    6
#DEFINE STATE_PROCESSING   7
#DEFINE STATE_PROCESSED    8
#DEFINE STATE_ERROR        9

//-------------------------------------------------------------------
/*{Protheus.doc} DefaultRecordBatchJob
Rotina principal da execucao do grvbatch

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFBatchProcess(cEmp, cFIl, cProcessFunction, nThreads, nLotSize, bQueryBuilder, bPriorityValue, nSecondsBetweenRetry, cTitle, cText, aTableInfo )
	Local cTemp	:= ""
	Local nCount	:= 1

	If Empty(bQueryBuilder)
		bQueryBuilder := {|| BuildQuery(cFil) }
	EndIf

	BatchRecordProcess("", cTitle, cText, aTableInfo, bQueryBuilder, cProcessFunction, nThreads, nLotSize, bPriorityValue, nSecondsBetweenRetry,cEmp,cFil)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} SchedDef
Usado para compatibilizar com o Schedule.

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
       // aReturn[1] - Tipo
       // aReturn[2] - Pergunte
       // aReturn[3] - Alias
       // aReturn[4] - Array de ordem
       // aReturn[5] - Titulo
Return { "P", "PARAMDEF" }

//-------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Monta a Query que sera executada para trazer os registros que serao processados.

@param   cFil - Filial onde a query sera executada.
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function BuildQuery(cFil)
	Local cQuery	:= ""

	Default cFil   := ""

	cQuery	:= "SELECT * "
	cQuery	+= "FROM " + RetSqlName("SL1") + " SL1 WHERE "
	cQuery	+= "L1_FILIAL = '"+cFil+"' "
	cQuery	+= "AND L1_STBATCH = '1' AND SL1.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY L1_NUM"
Return cQuery

//-------------------------------------------------------------------
/*{Protheus.doc} BatchRecordProcess
Realiza o semaforo para execucao da rotina.

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function BatchRecordProcess(cPerg, cTitle, cDescription, aTableInfo,;
 								bQueryBuilder, cProcessFunction, nThreads, nLotSize,;
 								bPriorityValue, nSecondsBetweenRetry,cEmp , cFil)
	Local oGrid					:= Nil
	Local lCanLockAll				:= .T.
	Local nActiveBatchProcesses	:= 0
	Local oSemaphore				:= FWThreadSemaphoreEx():New("BRProcess")
	Local oGlobalLocker			:= LJCGlobalLocker():New()
	Local nCount					:= 1

	Default nThreads				:= 2
	Default nLotSize				:= 10
	Default nSecondsBetweenRetry	:= 1

	#IFNDEF TOP
		UserException(STR0001) // "O processamento em batch só está disponível para utilização com o TOTVS DbAccess"
	#ENDIF

	oSemaphore:Activate()
	oSemaphore:Create()
	oSemaphore:Open()

	// Garante que não tem mais nenhuma thread em nenhum servidor (mesmo em balance) está rodando esse processamento.
	If oGlobalLocker:WaitGetLock("BatchRecordProcess_Main_Thread", 3)
		nActiveBatchProcesses := oSemaphore:DirtyRead("Counter")
		nActiveBatchProcesses := If( nActiveBatchProcesses == Nil, 0, Val(nActiveBatchProcesses))
		// Limpa todos os pedidos marcados como reservados (já que não há ninguem rodando)
		If nActiveBathProcesses == 0
			ResetRecordStatus(aTableInfo)
		EndIf
		oGlobalLocker:ReleaseLock("BatchRecordProcess_Main_Thread")
	EndIf

	If oGlobalLocker:WaitGetLock("BatchRecordProcess_Main_Thread", 3)
		nActiveBatchProcesses := oSemaphore:DirtyRead("Counter")
		nActiveBatchProcesses := If( nActiveBatchProcesses == Nil, 0, Val(nActiveBatchProcesses))
		oSemaphore:Write("Counter",  AllTrim(Str(nActiveBatchProcesses + 1)) )
		oGlobalLocker:ReleaseLock("BatchRecordProcess_Main_Thread")

		oGrid:= FWGridProcess():New("BRProcess", cTitle, cDescription,{|oGrid| RecordSelector(oGrid, aTableInfo, bQueryBuilder, cProcessFunction,nLotSize,	bPriorityValue, nSecondsBetweenRetry,cFil)},cPerg,"RecordLotProcessor")

		oGrid:SetMeters(4)
		oGrid:SetThreadGrid(nThreads)

		ConOut(I18N("Main thread '#1': "+STR0002,{AllTrim(Str(ThreadID()))})) // "Iniciando processamento em lote."
		oGrid:Activate()

		If oGrid:IsFinished()
			RESET ENVIRONMENT
			ConOut(I18N("Main thread '#1': "+STR0003,{AllTrim(Str(ThreadID()))})) // "Processamento em lote encerrado com sucesso."
			lThreadRunning := .F.
		Else
			If ValType(oGrid:oGrid) == "U"
				ConOut(I18N("Main thread '#1': "+STR0004,{AllTrim(Str(ThreadID()))})) // "Processamento em lote encerrado com erro desconhecido, possivelmente a rotina não foi executada pelo Schedule."
			Else
				ConOut(I18N("Main thread '#1': "+STR0005 + Chr(13) + Chr(10) + oGrid:oGrid:GetError() ,{AllTrim(Str(ThreadID()))})) // "Processamento em lote encerrado com erro."
			EndIf
		EndIf
	EndIf

	oSemaphore:Close()
Return

//-------------------------------------------------------------------
/*{Protheus.doc} ResetRecordStatus
Caso algum registro fique na pendencia de processamento por conta de qualquer eventualidade, seu status é resetado para que o mesmo possa ser processado.

@param   aTableInfo - Informacoes da tabela SL1.
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ResetRecordStatus(aTableInfo)
	Local cAlias	:= GetNextAlias()

	DbSelectArea("SL1")

	//Selecao de produtos vendidos via Pedido de venda
	cQuery	:= "SELECT " + aTableInfo[STATUS_FIELD] + "," + StrTran((aTableInfo[TABLE])->(IndexKey(aTableInfo[STATUS_INDEX])),"+",",") + " "
	cQuery	+= "FROM " + RetSqlName(aTableInfo[TABLE]) + " " + aTableInfo[TABLE] + " "
	cQuery	+= "WHERE " + aTableInfo[STATUS_FIELD] + " = '" + aTableInfo[STATE_PROCESSING] + "' AND " + aTableInfo[TABLE] + ".D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

	While (cAlias)->(!EOF())

		DbSelectArea(aTableInfo[TABLE])
		(aTableInfo[TABLE])->(DbSetOrder(aTableInfo[STATUS_INDEX]))
		If (aTableInfo[TABLE])->(DbSeek((cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[STATUS_INDEX]))))))
			RecLock(aTableInfo[TABLE], .F.)
			(aTableInfo[TABLE])->(FieldPut(FieldPos(aTableInfo[STATUS_FIELD]), aTableInfo[STATE_TOPROCESS]))
			(aTableInfo[TABLE])->(MsUnLock())
		EndIf

		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())
Return

//-------------------------------------------------------------------
/*{Protheus.doc} RecordLotProcessor
Recebe lotes de registros que serao processados, os ordena e os envia para processamento.

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function RecordLotProcessor(cProcessFunction, aTableInfo, aSelectedRecords,bPriorityValue,cFil)
	Local lResult	:= .F.
	Local nCount	:= 1

	DEFAULT bPriorityValue := Nil

	/*
	Se bPriorityValue estiver vazio, a ordenacao sera feita de acordo com a chave informada.
	Caso contrario, sera de acordo com o resultado de bPriorityValue.
	*/

	aSelectedRecords := IF(bPriorityValue == Nil,;
							 aSort( aSelectedRecords,,, {|x,y| x[1] < y[1]} ),;
							 aSort( aSelectedRecords,,, {|x,y| x[2] < y[2]} ))

	For nCount := 1 To Len(aSelectedRecords)
		RecordProcessor(cProcessFunction, aTableInfo, aSelectedRecords[nCount][1])
	Next nCount

Return lResult

//-------------------------------------------------------------------
/*{Protheus.doc} RecordSelector
Realiza a selecao dos registros que serao processados

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function RecordSelector(oGrid, aTableInfo, bQueryBuilder, cProcessFunction, nLotSize, bPriorityValue, nSecondsBetweenRetry,cFil)
	Local aSelectedRecords				:= {}
	Local nCount1							:= 1
	Local nCount2							:= 1
	Local lFirstEOF						:= .T.
	Local nProcessed						:= 0
	Local lRecordsFound					:= .T.
	Local cAlias							:= GetNextAlias()
	Local cQuery							:= ""
	Local nSecTotal						:= 0
	Local lGrvEstorn 						:= AliasInDic("MBZ") 	// Checa se a tabela MBZ e função de gravacao de estorno existem na base

	Default nLotSize						:= 10
	Default nSecondsBetweenRetry			:= 1000

	// Gera a query
	cQuery := ChangeQuery(Eval(bQueryBuilder))

	//--------------------------------------------------------
	// Laço principal, esse laço controla o ciclo de vida do seletor de registros, se for informado um nSecondsBetweenRetry igual -1,
	// não há ciclo de vida, ou seja, o seletor de registro ocorrerá somente uma vez. Se for informado qualquer valor diferente de -1
	// a cada avaliação será efetuado um intervalo igual à quantidade de segundos desejado
	//--------------------------------------------------------
	While !oGrid:lEnd

		//--------------------------------------------------------
		// Laço secundário de seleção de registro, nesse laço os registros são reservados e quando a quantidade definida pelo nLotSize
		// é atingida inicia a função de processamento de registro com o lote selecionado
		//--------------------------------------------------------
		While !oGrid:lEnd

			DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

			//--------------------------------------------------------
			// Navega pelos registros selecionados na query, e seleciona os registros marcados para processamento
			//--------------------------------------------------------
			nCount2 := 0
			lRecordsFound := .F.
			While (cAlias)->(!EOF())
				nCount2++

				DbSelectArea(aTableInfo[TABLE])
				ConOut(I18N("Main thread '#1': "+STR0006+" '#2'.", {AllTrim(Str(ThreadID())), (cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Analisando registro"

				// Primeira avaliação de registro candidato a reserva
				If (cAlias)->&(aTableInfo[STATUS_FIELD]) == aTableInfo[STATE_TOPROCESS]
					ConOut(I18N("Main thread '#1': "+STR0007+" '#2'.", {AllTrim(Str(ThreadID())),(cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Tentando reservar registro"
					lRecordsFound := .T.
					// Localiza o registro na sua tabela de origem

					(aTableInfo[TABLE])->(DbSetOrder(aTableInfo[UNIQUE_INDEX]))
					If (aTableInfo[TABLE])->(DbSeek((cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))))
						// Segunda avaliação de registro candidato a reserva
						If (aTableInfo[TABLE])->&(aTableInfo[STATUS_FIELD]) == aTableInfo[STATE_TOPROCESS]
							If (aTableInfo[TABLE])->(RLock())
								// Terceira e última confirmação (Para garantir que não houve alteração entre a última verificação e o lock)
								If (aTableInfo[TABLE])->&(aTableInfo[STATUS_FIELD]) == aTableInfo[STATE_TOPROCESS]
									ConOut(I18N("Main thread '#1': "+STR0008+" '#2' "+STR0009, {AllTrim(Str(ThreadID())), (cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Registro" ### "adicionado no lote." 
									(aTableInfo[TABLE])->(FieldPut(FieldPos(aTableInfo[STATUS_FIELD]), aTableInfo[STATE_PROCESSING]))
									AAdd(aSelectedRecords, { (aTableInfo[TABLE])->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX])))), If(bPriorityValue == NIL, 1, Eval(bPriorityValue)) })
								Else
									ConOut(I18N("Main thread '#1': "+STR0010+"'#2'.", {AllTrim(Str(ThreadID())), (cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Não reservado por reserva já efetuada "
								EndIf
								(aTableInfo[TABLE])->(MsUnLock())
							Else
								ConOut(I18N("Main thread '#1': "+STR0011+" '#2'.", {AllTrim(Str(ThreadID())), (cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Não reservado por impedimento de lock"
								Sleep(500)
							EndIf
						Else
							ConOut(I18N("Main thread '#1': "+STR0010+" '#2'.", {AllTrim(Str(ThreadID())), (cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Não reservado por reserva já efetuada "
						EndIf
					Else
						ConOut(I18N("Main thread '#1': "+STR0010+" '#2'.", {AllTrim(Str(ThreadID())), (cAlias)->(&((aTableInfo[TABLE])->(IndexKey(aTableInfo[UNIQUE_INDEX]))))})) // "Não reservado por reserva já efetuada "
					EndIf
				EndIf

				// Se já atingiu a quantidade necessária de registros reservados sai da seleção de pedido
				If nCount2 >= 	nLotSize
					Exit
				EndIf
				(cAlias)->(DbSkip())
			EndDo

			(cAlias)->(DbCloseArea())

			//--------------------------------------------------------
			// Se reservou pedidos suficientes ou se não há mais pedidos a serem reservados, inicia o processamento do lote acumulado.
			//--------------------------------------------------------
			If Len(aSelectedRecords) > 0
				ConOut(I18N("Main thread '#1': "+STR0012+"#2 "+STR0013+" #3 "+STR0014,;
				{AllTrim(Str(ThreadID())), AllTrim(Str(Len(aSelectedRecords))), AllTrim(Str(nLotSize))})) // "Iniciando processamento de lote de " ### "de no máximo" ### "registros."
				
				If !oGrid:CallExecute(cProcessFunction, aTableInfo, aSelectedRecords,bPriorityValue,cFil)
					oGrid:lEnd := .T.
				EndIf
				nProcessed += Len(aSelectedRecords)
				aSelectedRecords := {}
			EndIf

			If !lRecordsFound
				Exit
			EndIf
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄa¿
		//³Checa se a tabela MBZ e função de gravacao de estorno existem na base                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÙ
		If lGrvEstorn
			Lj601GrPDV()
		EndIf

		LJ1415LP(.T.)

		// Efetua uma pausa do selecionador de registro ou sai, se a variável estiver como -1 significa que essa rotina não deve ficar aguardando indefinidamente pedidos a serem processados.
		If nSecondsBetweenRetry == -1 //.OR. lMultFil
			ConOut(I18N("Main thread '#1': "+STR0015,{AllTrim(Str(ThreadID()))})) // "Não há mais registros a serem processados, saindo..."
			Exit
		Else
			ConOut(I18N("Main thread '#1': "+STR0016, {AllTrim(Str(ThreadID()))})) // "Aguardando novos registros."
			Sleep( nSecondsBetweenRetry*1000 )
		EndIf

		ConOut(I18N("Main thread '#1': "+STR0017+" #2 "+STR0018,{AllTrim(Str(ThreadID())),AllTrim(Str(nProcessed))})) // "Registros processados" ### "até o momento."

	EndDo
Return

//-------------------------------------------------------------------
/*{Protheus.doc} RecordProcessor
Realiza o processamento dos registros selecionados, fazendo a preparacao para a execucao da funcao STBGrvBatch

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function RecordProcessor(cProcessFunction, aTableInfo, cKey)
	Local bOldErrorBlock	:= Nil
	Local lError			:= .F.
	Local oOcurredError	:= Nil
	Local cLastBranch		:= cFilAnt
	Local cFilCont			:= ""
	Local cBoolean			:= ""

	ConOut(I18N("Child thread '#1': "+STR0019+" '#2' "+STR0020,{AllTrim(Str(ThreadID())), cKey})) // "Redirecionando registro" ### "para a função de processamento."
	DbSelectArea(aTableInfo[TABLE])
	(aTableInfo[TABLE])->(DbSetOrder(aTableInfo[UNIQUE_INDEX]))

	If (aTableInfo[TABLE])->(DbSeek(cKey))
		// Faz o que tem que fazer com o pedido
		If cProcessFunction != Nil
			// Configura a filial do registro corrente
			cFilCont := &(If(SubStr(aTableInfo[TABLE],1,1) == "S", SubStr(aTableInfo[TABLE],2,3), aTableInfo[TABLE]) + "_FILIAL")
			If	!Empty(cFilCont)
				cFilAnt := cFilCont
			EndIf

			bOldErrorBlock := ErrorBlock({|oError| (lError := .T., oOcurredError := oError) })
			lResult := &(cProcessFunction + "('" + aTableInfo[TABLE] + "', '.F.','" + cKey + "')")
			ErrorBlock(bOldErrorBlock)
			// Restaura a filial anterior
			cFilAnt := cLastBranch

			(aTableInfo[TABLE])->(DbSetOrder(aTableInfo[UNIQUE_INDEX]))
			ConOut(I18n("Child thread '#1': "+STR0021+" '#2', "+STR0022,{AllTrim(Str(ThreadID())), cKey})) // "Processamento externo realizado" ### "atualizando status do registro."
			If (aTableInfo[TABLE])->(DbSeek(cKey))
				RecLock(aTableInfo[TABLE], .F.)
				If lError
					ConOut(I18n("Child thread '#1': "+STR0023+" '#2'." + Chr(13) + Chr(10) + oOcurredError:ErrorStack,{AllTrim(Str(ThreadID())), cKey})) // "Houve erro durante o processamento do registro"
					(aTableInfo[TABLE])->(FieldPut(FieldPos(aTableInfo[STATUS_FIELD]), aTableInfo[STATE_ERROR]))
					If aTableInfo[ERROR_FIELD] != Nil
						(aTableInfo[TABLE])->(FieldPut(FieldPos(aTableInfo[ERROR_FIELD]), oOcurredError:ErrorStack))
					EndIf
				ElseIf lResult == Nil .Or. lResult
					ConOut(I18n("Child thread '#1': "+STR0024+" '#2'.",{AllTrim(Str(ThreadID())), cKey})) // "Não houve erro durante o processamento do registro"
					(aTableInfo[TABLE])->(FieldPut(FieldPos(aTableInfo[STATUS_FIELD]), aTableInfo[STATE_PROCESSED]))
				EndIf
				(aTableInfo[TABLE])->(MsUnLock())
			EndIf
		EndIf
	EndIf

Return