#INCLUDE "PROTHEUS.CH"  

#DEFINE SYNCSTATE_STOPPED	1
#DEFINE SYNCSTATE_SYNCING	2
#DEFINE SYNCSTATE_ERROR		3
#DEFINE SYNCSTATE_SYNCED		4

//--------------------------------------------------
/*/{Protheus.doc} GetSyncState()
Busta status
@param cSemaphore 

@author Vendas CRM
@since 04/06/2013
/*/
//-------------------------------------------------
Function GetSyncState(cSemaphore)
	Local aSyncState	:= {}

	GetGlbVars(cSemaphore  + "_SyncState", aSyncState)
	aSyncState := If(ValType(aSyncState) != "A", GetDefaultSyncState(), aSyncState) 	
Return aSyncState

Function GetDefaultSyncState()
Return { SYNCSTATE_STOPPED, "" , Date(), Time() }

Function SetSyncOptions(cSemaphore, cCallback, nInterval, aOptions)
	PutGlbVars(cSemaphore  + "_SyncOptions", { cCallback, nInterval, aOptions } )
Return


//-------------------------------------------------
/*/{Protheus.doc} CreateSyncSession()
Cria sessao para o semafaro determinado
@param cSemaphore 

@author Vendas CRM
@since 04/06/2013
/*/
//-------------------------------------------------
Function CreateSyncSession(cSemaphore)	
	Local oGlobalLocker			:= LJCGlobalLocker():New()
	Local aSyncState				:= GetDefaultSyncState()
	Local aActiveSyncProcesses	:= {}
	Local nActiveSyncProcesses	:= 0
	
	If oGlobalLocker:WaitGetLock(cSemaphore + "_Sessions", 3)	
		GetGlbVars(cSemaphore + "_Sessions", aActiveSyncProcesses)
		aActiveSyncProcesses := If(ValType(aActiveSyncProcesses) != "A", {}, aActiveSyncProcesses) 				
		nActiveSyncProcesses := Len(aActiveSyncProcesses)
		
		If nActiveSyncProcesses == 0
			PutGlbValue(cSemaphore  + "_RequestStop", "false")			
			PutGlbVars(cSemaphore  + "_SyncState", aSyncState)
			PutGlbVars(cSemaphore  + "_Sessions", {})			
			StartJob("SyncThread", GetEnvServer(), .F., cSemaphore)
		EndIf	
				
		aAdd(aActiveSyncProcesses, ThreadID())
				
		PutGlbVars(cSemaphore + "_Sessions", aActiveSyncProcesses)
		
		oGlobalLocker:ReleaseLock(cSemaphore + "_Sessions")
	EndIf	
Return 


//-------------------------------------------------
/*/{Protheus.doc} CheckConnectedSessions()
Checa se existem conexoes abertas para o semaforo
@param cSemaphore 
@return lRet
@author Vendas CRM
@since 04/06/2013
/*/
//-------------------------------------------------
Function CheckConnectedSessions(cSemaphore)
	Local oGlobalLocker			:= LJCGlobalLocker():New()
	Local aActiveSyncProcesses	:= {}
	Local aProcessesToDelete		:= {}
	Local lRet						:= .T.
	Local nCount					:= 0
	Local aThreads				:= {}
	
	aThreads := GetUserInfoArray()
	
	If oGlobalLocker:WaitGetLock(cSemaphore + "_Sessions", 3)
		GetGlbVars(cSemaphore + "_Sessions", aActiveSyncProcesses)
		aActiveSyncProcesses := If(ValType(aActiveSyncProcesses) != "A", {}, aActiveSyncProcesses)				
		
		If Len(aProcessesToDelete) > 0
			For nCount := 1 To Len(aProcessesToDelete)
				aActiveSyncProcesses := aDel(aActiveSyncProcesses, aProcessesToDelete[nCount])			
			Next
						
			aActiveSyncProcesses := aSize(aActiveSyncProcesses, Len(aActiveSyncProcesses) - Len(aProcessesToDelete))
						
			PutGlbVars(cSemaphore + "_Sessions", aActiveSyncProcesses)
		EndIf
		
		lRet := Len(aActiveSyncProcesses) != 0
	
		oGlobalLocker:ReleaseLock(cSemaphore + "_Sessions")
	EndIf	
Return lRet


//-------------------------------------------------
/*/{Protheus.doc} EndSyncSession()
Encerra uma sessao 
@param cSemaphore 

@author Vendas CRM
@since 04/06/2013
/*/
//-------------------------------------------------
Function EndSyncSession(cSemaphore)
	Local oGlobalLocker	:= LJCGlobalLocker():New()
	Local aActiveSyncProcesses	:= {}
	Local nActiveSyncProcesses	:= 0
	Local nPos						:= 0
	
	If oGlobalLocker:WaitGetLock(cSemaphore + "_Sessions", 3)	
		GetGlbVars(cSemaphore + "_Sessions", aActiveSyncProcesses)
		aActiveSyncProcesses := If(ValType(aActiveSyncProcesses) != "A", {}, aActiveSyncProcesses) 						
		
		nPos := aScan(aActiveSyncProcesses, {|x| x == ThreadID()})
		If nPos > 0
			aActiveSyncProcesses := aDel(aActiveSyncProcesses, nPos)
			aActiveSyncProcesses := aSize(aActiveSyncProcesses, Len(aActiveSyncProcesses)-1)
			nActiveSyncProcesses := Len(aActiveSyncProcesses)
		
			If nActiveSyncProcesses == 0			
				PutGlbValue(cSemaphore  + "_RequestStop", "true")
			EndIf						
			
			PutGlbVars(cSemaphore + "_Sessions", aActiveSyncProcesses)
					 
		EndIf								
		oGlobalLocker:ReleaseLock(cSemaphore + "_Sessions")
	EndIf
	
	IpcGo(cSemaphore)
	
Return

//-------------------------------------------------
/*/{Protheus.doc} SyncThread()
Chama o processamento da funcao configurada para a sessao
@param cSemaphore 

@author Vendas CRM
@since 04/06/2013
/*/
//-------------------------------------------------
Function SyncThread(cSemaphore)
	Local bErrorBlock			:= {||}	
	Local lUnmanagedError	:= .F.	
	Local aRet					:= { .F., "" }
	Local aSyncOptions		:= 	{ Nil, 180000, {}}
	Local bCodeBlock			:= {||}			
	Local lKillThread			:= .F.

	cSemaphore := AllTrim(cSemaphore)

	While !KillApp() .And. GetGlbValue(cSemaphore  + "_RequestStop") == "false" .And. CheckConnectedSessions(cSemaphore)
		PutGlbVars(cSemaphore  + "_SyncState", { SYNCSTATE_SYNCING, "" , Date(), Time()})		
				
		bErrorBlock	:= ErrorBlock( {|oErr| lUnmanagedError := .T., PutGlbVars(cSemaphore  + "_SyncState", { SYNCSTATE_ERROR, "ERRROBLOCK - " + oErr:ErrorStack + oErr:ErrorEnv, Date(), Time() })})
		
		GetGlbVars(cSemaphore  + "_SyncOptions", aSyncOptions)
		aSyncOptions := If( ValType(aSyncOptions) != "A", { Nil, 180000, {}} , aSyncOptions)
		
		If ValType(aSyncOptions[1]) == "C"						
			bCodeBlock := MontaBlock("{|aOpt| " + aSyncOptions[1] + "(aOpt) }")
			aRet := Eval(bCodeBlock,aSyncOptions[3])
		EndIf
		
		ErrorBlock(bErrorBlock)

		If !lUnmanagedError
			If aRet[1]		
				If aRet[2] == 'STOPED'
					PutGlbVars(cSemaphore  + "_SyncState", { SYNCSTATE_STOPPED, "" , Date(), Time()})				
				Else
					PutGlbVars(cSemaphore  + "_SyncState", { SYNCSTATE_SYNCED, aRet[2], Date(), Time() })
				EndIf
			Else
				PutGlbVars(cSemaphore  + "_SyncState", { SYNCSTATE_ERROR, aRet[2], Date(), Time()  })
			EndIf
		Else 
			lUnmanagedError := .F.
		EndIf

		lKillThread := IPCWaitEx(cSemaphore,aSyncOptions[2]) 	
		
		If lKillThread
			Exit
		EndIf
		
	End
	
	PutGlbVars(cSemaphore  + "_SyncState", { SYNCSTATE_STOPPED, "" , Date(), Time()})	
Return

