#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE DnToThread   3      //Total de thread disponível para uso, por estação de trabalho

Function __JURTHREAD() // Function Dummy
	ApMsgInfo( 'JURTHREAD -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} JURTHREAD
Classa para controle de Thread na emissão de Pré-Fatura.

@author Bruno Ritter
@since 20/10/2016
@version 2.0
/*/
//-------------------------------------------------------------------
Class JURTHREAD

	Data cCodUser
	Data cFunction
	Data nToThread
	Data bLog
	Data lError
	Data aParams
	Data lThreadStar
	Data lAutomato
	Data cLockByName
	Data lLock

	Method New() Constructor
	Method SetParams(aStruct)
	Method GetParams()
	Method SetFunction(cFunction)
	Method GetFunction()
	Method SetToThread(nToThread)
	Method GetToThread()
	Method SetLog()
	Method StartThread()
	Method SetLAutomato()
	Method GetLAutomato()
	
	Method ThreadUp()
	Method ThreadDown()
	Method IsThreadUp()

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor da Classe JURTHREAD

@author Felipe Bonvicini Conti
@since 10/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JURTHREAD

	Self:lError        := .F.
	Self:aParams       := {}
	Self:cCodUser      := __cUserID
	Self:nToThread     := DnToThread
	Self:bLog          := {|| .F. }
	Self:lAutomato     := .F.
	Self:cLockByName := 'JURTHREAD'+ Self:cCodUser
	Self:lLock       := .T.
	
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLAutomato()
Método para setar se está sendo executado como teste automatizado

@author bruno.ritter
@since 02/03/2017
/*/
//-------------------------------------------------------------------
Method SetLAutomato(lAutomato) Class JURTHREAD
Local lRet := .T.

Default lAutomato := .F.

	If !Self:lError .And. ValType(lAutomato) == "L" .And. !Empty(lAutomato)
		Self:lAutomato := lAutomato
		lRet := lAutomato == Self:lAutomato
	Else
		lRet := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GetLAutomato()
Método para retornar se está sendo executado como teste automatizado

@author bruno.ritter
@since 02/03/2017
/*/
//-------------------------------------------------------------------
Method GetLAutomato() Class JURTHREAD
Return Self:lAutomato

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParams()
Método para setar os parâmetros a serem executados pela cFunction

@author Felipe Bonvicini Conti
@since 05/03/13
/*/
//-------------------------------------------------------------------
Method SetParams(aParams) Class JURTHREAD
Local nI   := 1
Local lRet := .T.

Default aParams := {}

	If !Self:lError .And. ValType(aParams) == "A" .And. !Empty(aParams)
		Self:aParams := AClone(aParams)
		lRet := Len(aParams) == Len(Self:aParams)
	Else
		lRet := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GetParams()
Método para retornar os parâmetros a serem executados pela cFunction

@author Felipe Bonvicini Conti
@since 05/03/13
/*/
//-------------------------------------------------------------------
Method GetParams() Class JURTHREAD
Return Self:aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFunction()
Método para setar o nome da function para ser executada na Thread

@author Felipe Bonvicini Conti
@since 09/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFunction(cFunction) Class JURTHREAD
Local lRet := .T.

	If !Self:lError .And. ValType(cFunction) == "C"
		Self:cFunction := cFunction
		lRet := Self:cFunction == cFunction
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFunction()
Método para retornar o nome da function de emissão de pré

@author Felipe Bonvicini Conti
@since 09/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFunction() Class JURTHREAD
Return Self:cFunction


//-------------------------------------------------------------------
/*/{Protheus.doc} SetToThread()
Método para setar o total de threads que podem ser abertas por estação de trabalho

@author Bruno Ritter
@since 17/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetToThread(nToThread) Class JURTHREAD
lRet := .T.

	If !Self:lError .And. ValType(nToThread) == "N" .And. nToThread > 0
		Self:nToThread := nToThread
		lRet := Self:nToThread == nToThread
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetToThread()
Método para retornar o total de threads de emissão de pré
Se a 'Data (nToThread)' estiver com um valor inválido, o método retorna o valor Padrão

@author Bruno Ritter
@since 17/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetToThread() Class JURTHREAD
Local nRet := Self:nToThread

	If ValType(Self:nToThread) <> "N" .OR. Self:nToThread < 1
		nRet := DnToThread
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLog()
Método para setar o bloco a ser rodado para verificar se irá utilizar o 

@author Felipe Bonvicini Conti
@since 18/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetLog(bValor) Class JURTHREAD
Local lRet := .T.

	Do Case
	Case ValType(bValor) == "B"
		Self:bLog := bValor
	Otherwise
		Self:bLog := {|| .F. }
		lRet := .F.
	End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StartThread()
Método para iniciar a thread para controle de emissão.

@author Bruno Ritter
@since 31/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method StartThread() Class JURTHREAD
Local lRet := .F.

Self:ThreadUp() //Inicia o controle de emissão

If !Self:lThreadStar .AND. !Empty(Self:GetFunction()) .AND. JurThreAbt("JURFILAIPC", 1) == 0
	StartJob( "JURFILAIPC", GetEnvServer(), .F.,;
	Self:GetFunction(), cEmpAnt, cFilAnt, Self:cCodUser, Eval(Self:bLog), Self:nToThread, Self:GetLAutomato())

	Self:lThreadStar := .T.
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilaIPC(cFunction, cEmpAux, cFilAux, cCodUser, lLog, nToThread, lAutomato)
Função para controlar a emissão de pré-fatura

@param cFunction  - Função que será executada.
@param cEmpAux    - Código da empresa para abrir o ambiente
@param cFilAux    - Código da filial para abrir o ambiente
@param cCodUser   - Código do usuário para abrir o ambiente e o controle de emissão
@param lLog       - Lógico se vai registrar log (opcional)
@param nToThread  - Máximo de thread que pode ser aberta para processar uma emissão de pré-fatura por usuário
@Param lAutomato  - Automatização de fonte

@author Bruno Ritter
@since 31/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURFILAIPC(cFunction, cEmpAux, cFilAux, cCodUser, lLog, nToThread, lAutomato)
Local nI         := 1
Local aParams    := {}
Local cText      := cFunction + ": " + cCodUser + ":"
Local cThread    := cValtochar(ThreadID())
Local lExit      := .F.
Local dInicio    := Date()
Local oFilaEx    := Nil
Local lOk        := .T.
Local lRet       := .F.

//Pode já existir threads abertas se a tela foi fechada e aberta em curto período de tempo, ou enquanto as threads estavam emitindo pré-faturas
Local nThreadAbt := JurThreAbt("JURIPC", nToThread)

Default lLog      := .F.
Default lAutomato := .F.

	PtInternal(1, cText + ' Open environment / ID: ' + cThread )
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RPCSetType(3) // Prepara o ambiente e não consome licença
		RPCSetEnv(cEmpAux,cFilAux, , , , "JurFilaIPC")
	EndIf
	__cUserID := cCodUser
	cText     := cFunction + ": " + AllTrim(JurUsrName(cCodUser)) + " (" + cCodUser + "):"
	PtInternal(1, cText + ' Starting / ID: ' + cThread )

	//Abrir a primeira thread de emissão.
	If (nThreadAbt == 0)
		StartJob( "JURIPC", GetEnvServer(), .F., cFunction, cEmpAux, cFilAux, cCodUser, lLog, aParams, lAutomato)
		nThreadAbt += 1
	EndIf
	
	oFilaEx := JurFilaExe():New( "JURA201", "1" )
	
	While  lOk .OR. (!lExit .AND. dInicio == Date())
		aParams := oFilaEx:GetNext()

		If(ValType(aParams) == "A" .AND. Len(aParams) > 1)
			Iif(aParams[2] > 0, lOk := .T., lOk := .F. )
		Else
			aParams := {{}, 0}
			lOk := .F.
		EndIf

		If( lOk )
			lRet := .F.

			While( !lRet .AND. dInicio == Date() .AND. !KillApp())
				If(IPCCount( "JFILAIPC" ) > 0)
					lRet := IPCGo( "JFILAIPC", aParams)

				ElseIf (nThreadAbt < nToThread)

					StartJob( "JURIPC", GetEnvServer(), .F., cFunction, cEmpAux, cFilAux, cCodUser, lLog, aParams, lAutomato)
					nThreadAbt += 1
					lRet:= .T.

				Else
					Sleep(1000)
				EndIf
			EndDo

		Else
			lExit := !oFilaEx:IsOpenWindow("JURA201" + cCodUser) //Verifica se a tela de emissão foi fechada.
			Iif(lExit, ,Sleep(2000) )
		EndIf
	EndDo

	PtInternal(1, cText + ' Finish / ID: ' + cThread  )
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RpcClearEnv() // Reseta o ambiente
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIPC()
Função para executar a emissão de pré-fatura conforme encaminhado pela função JurFilaIPC()

@param cFunction  - Função que será executada.
@param cEmpAux    - Código da empresa para abrir o ambiente
@param cFilAux    - Código da filial para abrir o ambiente
@param cCodUser   - Código do usuário para abrir o ambiente e o controle de emissão
@param lLog       - Lógico se vai registrar log (opcional)
@param aParamsIni - Retorno do JurFilaExe:GetNext() (opcional)
                    {aParam(OH1_PARAME), R_E_C_N_O_ (OH1)}

@author Bruno Ritter
@since 17/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURIPC(cFunction, cEmpAux, cFilAux, cCodUser, lLog, aParamsIni, lAutomato)
Local nI         := 1
Local aParams    := {{}, 0}
Local cText      := cFunction + ": " + cCodUser + ":"
Local cThread    := cValtochar(ThreadID())
Local lExit      := .F.
Local dInicio    := Date()
Local oFilaEx    := Nil
Local oThread    := Nil
Local lOk        := .T.

Default lLog       := .F.
Default aParamsIni := {}
Default lAutomato  := .F.

	PtInternal(1, cText + ' Open environment / ID: ' + cThread )
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RPCSetType(3)	// Prepara o ambiente e não consome licença
		RPCSetEnv(cEmpAux,cFilAux, , , , cFunction)
	EndIf
	__cUserID := cCodUser
	cText     := cFunction + ": " + AllTrim(JurUsrName(cCodUser)) + " (" + cCodUser + "):"
	PtInternal(1, cText + ' Starting / ID: ' + cThread )
	
	oThread := JurThread():New()
	oFilaEx := JurFilaExe():New( "JURA201", "1" )
	
	While  lOk .OR. (!lExit .AND. dInicio == Date())

		If (Len(aParamsIni) == 0)
			IPCWaitEx("JFILAIPC", 60000, @aParams)
			If(ValType(aParams) == "A" .AND. Len(aParams) > 1)
				Iif(aParams[2] > 0, lOk := .T., lOk := .F. )
			Else
				aParams := {{}, 0}
				lOk := .F.
			EndIf
		Else
			aParams := aClone(aParamsIni)
			aParamsIni := {}
		EndIf

		If( lOk )
			IIF(lLog, JurLogMsg("JurIPC: cFunction: "+cFunction +" / nRecno: " + cValToChar(aParams[2]) + " / ID: " + cThread), )
			Eval(&("{||"+cFunction+"( aParams, lAutomato )}"))
			aParams := {{}, 0}

		Else
			lExit := !oThread:IsThreadUp() .Or. !oFilaEx:IsOpenWindow("JURA201" + cCodUser) //Verifica se a tela de emissão foi fechada.
		EndIf
	EndDo

	If( JurThreAbt("JURIPC", 2) <= 1)
		oThread:ThreadDown() // Indica que foram finalizadas as emissões
	EndIf

	PtInternal(1, cText + ' Finish / ID: ' + cThread  )
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RpcClearEnv() // Reseta o ambiente
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurThreAbt()
Verifica a quantidade de threads abertas da Estação de trabalho executando [cFunction]

@param cFunction - Função a ser verificada
@param nMaxRet - Valor máx de retorno desejado

@return Retorna um lógico se existe uma thread ativa da cFunction

@author Bruno Ritter
@since 18/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurThreAbt(cFunction, nMaxThread)
Local nRet            := 0
Local aThread         := GetUserInfoArray()
Local cEnvServer      := GetEnvServer()
Local cComputerName   := GetComputerName()
Local nI              := 1
Local lMaxThread      := .F.

Default nMaxThread    := 0

lMaxThread := nMaxThread > 0

cFunction := Upper(cFunction)
	For nI := 1 To Len(aThread) //Controle de uso de Thread por Estação de trabalho / Server
		If    ( aThread[nI][2] == cComputerName ) ;
		.and. ( aThread[nI][5] == cFunction     ) ;
		.and. ( aThread[nI][6] == cEnvServer    )

			nRet += 1

			If(lMaxThread .AND. nRet == nMaxThread)
				Exit
			EndIf
		EndIf
	Next nI

Return nRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ThreadUp()
Método para ativar o controle de semaforo da tela (controle de abertura das Threads filhas)

@Return lRet .T. se conseguiu locar o semaforo

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ThreadUp() Class JURTHREAD

Self:lLock := LockByName(Self:cLockByName, .T., .F.)

Return (Self:lLock)


//-------------------------------------------------------------------
/*/{Protheus.doc} ThreadDown()
Método para desativar o controle de semaforo da tela (controle de fechamento das Threads filhas)

@Return Nil

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ThreadDown() Class JURTHREAD

UnlockByName(Self:cLockByName, .T., .F. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} IsThreadUp()
Método para verificar se a Thread Pai esta aberta

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method IsThreadUp() Class JURTHREAD

If Self:lLock .And. LockByName(Self:cLockByName, .T., .F.)
	Self:lLock := .F.
EndIf

Return (Self:lLock)


