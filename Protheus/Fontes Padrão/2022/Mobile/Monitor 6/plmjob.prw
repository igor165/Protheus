#include "protheus.ch"
#INCLUDE "FILEIO.CH"

//#define JOBDRIVER "DBFCDX"
#define JOBDRIVER "DBFCDX"
#define DBFEXT ".DBF"
#DEFINE  LOGMODE
Static __cLastEmp := "@@"
Static __cUserDir
Static __cRootPath
Static __nRecLock
Static __cAlias
Static __nInterval

Function HHJob( )
Local cTime := ""
Local cTAtual
Local cDate
Local nC, lEnd
Local cNextHH := ""
Local ni, nHDL, nWork, aTimes,NF
Local cHandHeldDir := GetcDir()
Local cFileLock := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2)
Local nSys := 1
nWork := Val(GetSrvProfString("HandHeldWorks","3"))
DEFAULT __nInterval := VAL(GetSrvProfString("HHThreadTimer","3000"))

ErrorBlock({|e| HHError(e)})

Set Deleted On

ConOut("Iniciando PALMJOB... ("+Time()+") em " + GetEnvServer())
PTInternal(1,"Lancador de Palm Jobs por vendedor...")

FCreate("\SEMAFORO\"+ cFileLock + ".LCK")

Private PUALIAS := POpenUser()
Private PSALIAS := POpenServ()
Private PCALIAS := POpenCond()
Private PTALIAS := POpenTime()
Private PLALIAS := POpenLog()
Private PFALIAS := POpenTabl()
Private cJobAlias := PUALIAS+"#"+PSALIAS+"#"+PTALIAS+"#"+PLALIAS+"#"+PFALIAS

//controle de aviso de execucao em job
PInJob(.T.)

CriaPublica()

//carrega arquivo com lista de servicos (PALM.SVC)
//Verifica se existe algum usuario bloqueado

DbSelectArea(PUALIAS)
dbSetOrder(1)
dbGotop()

//atualiza arquivo de controle de tempo
While ( !Eof() )
	
	DbSelectArea(PTALIAS)
	DbSetOrder(1)
	If !DbSeek((PUALIAS)->P_SERIE)
		RecLock(PTALIAS,.T.)
		(PTALIAS)->P_SERIE := (PUALIAS)->P_SERIE
		(PTALIAS)->P_TIME := ""
		(PTALIAS)->P_RANGE := PRetRange((PUALIAS)->P_FREQ,(PUALIAS)->P_FTIPO)
	EndIf

	//campo P_TIME sera usado no controle por min ou hr e nele
	//e gravado a proxima data + o proximo horario de atualizacao
	
	MsUnlock()
	DbCommit()
	
	DbSelectArea(PUALIAS)
	DbSkip()
End

//a cada minuto verifica-se todos as linhas da tabela de controle de tempo
//e executa os servicos dos usuarios com horario ultrapassado

While !KillApp()

	If File(PGetDir()+"PSTOP.JOB")
		ConOut("Parando PALMJOB...")
		Exit
	EndIf
	
	cDate := Dtos(Date())
	cTAtual := cDate+Time()
	
	If ( Subs(cTAtual,1,13) <> Subs(cTime,1,13) )
		cTime := cTAtual
		DbSelectArea(PTALIAS)
		// Posiciona no Proximo Handheld a rodar o JOB
		DbGoTop()     
		aTimes := {}
		While !Eof() .and. !KillAPP()
		  AADD(aTimes,{P_TIME,Recno()})
		  dbSkip()
		End
		aSORT(aTimes,,,{|x,y| x[1]<y[1]})
		For nF := 1 to Len(aTimes)
		   (PTALIAS)->(dbGoto(aTimes[nF,2]))
			DbSelectArea(PUALIAS)
			DbSetOrder(1)
			If ( DbSeek((PTALIAS)->P_SERIE) )
				If Dtos(Date())+Time()  >= (PTALIAS)->P_TIME	
					//IF (PUALIAS)->(MsRLock())
					If (Empty((PUALIAS)->P_LOCK) .Or. (PUALIAS)->P_LOCK = "J") // .And. ((PUALIAS)->P_LOCK <> "B")
					    IF !(PUALIAS)->(MsRLock() )
					        Loop
					    Endif                 
					    IF (PUALIAS)->P_LOCK == "J"
					       (PUALIAS)->(MSRUnlock() )
					       Sleep(60000)
						   IF !MsRLock() 
					        Loop
					       Endif
					    Endif
												    
                        // Inicio de execucao em thread
                        // Agora para cada usuario sera estartado uma thread
						lEnd := .f.
						While !KillAPP() .and. !lEnd                                   
							For ni:= 1 to nWork
						 		nHdl := MSFCREATE("\SEMAFORO\" + cFileLock + "WK" +StrZero(ni,3,0)+".LCK")
//								ConOut("\SEMAFORO\WK"+StrZero(ni,3,0)+".LCK" + " - " + Str(nHdl,4,0))
								If nHdl >= 0
									//RecLock(PUALIAS,.F.)
									(PUALIAS)->P_LOCK := "J"   // Utiliza Lock Fisico, pq o Lock do registro 
			//						MsUnlock()  				//	se perde qdo o HTTP:JOB cai por TimeOut  
									(PUALIAS)->(MSRUnlock())
									ConOut("PALMJOB: "+Trim(P_USER)+" - "+Subs(cTime,9))
                            		FClose(nHdl)
									StartJob("PExecServ",GetEnvServer(),.F.,P_SERIE, ni)
									Sleep(__nInterval)
									nERR := 0                                       
									lEnd := .t.
									Exit
								Endif                                
        				 	Next
        				 	If !lEnd
	        				 	Sleep(20000)   //Todas as WORKs estao ocupadas, tentar mais tarde
							EndIf
                        End
                        // Fim de execucao em thread
						// PExecServ(P_SERIE)   //Por isso por startjob
					Endif
				EndIf
			EndIf
		Next nF                           
	EndIf       
	nC := 0
	While !KillApp() .and. nC < 60
	   Sleep(1000)
	   nC++
	End
End

(PLALIAS)->(MsUnlockAll())
DbCommitAll()
DbCloseAll()

PInJob(.F.)

Return .T.

Function PExecServ(cSerie, ni)
Local i
Local nx := 1
Local cSvAlias := Alias()
Local nServ
Local aAlias
Local aField
Local aPalm
Local aInd, aR
Local aDir := {}
Local aArquivos := {}
Local cDir := ""
//Local cLogSiga := __cLogSiga
Local cEnv := GetEnvServer()
Local cHandHeldDir := GetcDir()
Local cFileLock := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2)
Local nHdl := MSFCREATE("\SEMAFORO\" + cFileLock + "WK" + StrZero(ni,3,0)+".LCK") //MSFCREATE("\SEMAFORO\"+StrZero(ni,3,0)+".LCK")
Local cTime := ""
Local lRPCOpened := .f.
Local nSys
Local nOnlyDay := Val(GetSrvProfString("HandHeldDay","1"))

PTInternal(1,"Job do dispositivo "+cSerie+" iniciado")
ErrorBlock({|e| HHError(e, cSerie)})

//carrega arquivo com lista de servicos (PALM.SVC)
Private aPTipos

GravaPLLog(cSerie + Space(20 - Len(cSerie)) + " - Inicio =" + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))

IF nHdl < 0
	ConOut(FError())
	GravaPlLog((cSerie + Space(20 - Len(cSerie)) + " - Erro do Semaforo =" + Str(FError(),3,0) + " - " + Time() + Chr(13) + Chr(10)))
	dbCloseAll()
	UserException("Erro de Criacao de Semaforo")
Endif

DEFAULT cSerie := ""
// EXECUCAO EM THREAD
// ABRIR AS TABELAS AGORA PORQUE CADA SERVICO ESTA EM UMA THREAD
Private PUALIAS := POpenUser()
Private PSALIAS := POpenServ()
Private PCALIAS := POpenCond()
Private PTALIAS := POpenTime()
Private PLALIAS := POpenLog()
Private cJobAlias := PUALIAS+"#"+PSALIAS+"#"+PTALIAS+"#"+PLALIAS

// TABELAS ABERTAS PARA ESTA THREAD

cSerie := Trim(cSerie)
If nOnlyDay = 3
	cTime := DtoS(Date())+Time()
EndIf
//retorna diretorio de trabalho do usuario
DbSelectArea(PUALIAS)
DbSetOrder(1)
DbSeek(cSerie)
/// Exclui a base
If (PUALIAS)->P_DELDATA = "T"
	cDir := cHandHeldDir + "P" + AllTrim((PUALIAS)->P_DIR) + "\"
	ConOut("PALMJOB: Apagando base em " + cDir + "NEW\ - " + cSerie + " - " + Time())
	aDir := Directory(cDir + "\NEW\*.*")
	For ni := 1 To Len(aDir)
		FErase(cDir+"NEW\" + aDir[ni, 1])
	Next

	ConOut("PALMJOB: Apagando base em " + cDir + "DIFS\ - " + cSerie + " - " + Time())
	aDir := Directory(cDir + "\DIFS\*.*")
	For ni := 1 To Len(aDir)
		FErase(cDir+"DIFS\" + aDir[ni, 1])
	Next

	ConOut("PALMJOB: Apagando base em " + cDir + "ATUAL\ - " + cSerie + " - " + Time())
	aDir := Directory(cDir + "\ATUAL\*.*")
	For ni := 1 To Len(aDir)
		FErase(cDir+"ATUAL\" + aDir[ni, 1])
	Next
EndIf

GravaPLLog(cSerie + (PUALIAS)->(P_CODVEND) + " - " + Space(20 - Len(cSerie)) + " - Inicio =" + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
__cUserDir := PGetDir()+"P"+Trim((PUALIAS)->P_DIR)+"\"
//RecLock(PUALIAS,.f.)
nSys := If(!Empty((PUALIAS)->P_SISTEMA),Val((PUALIAS)->P_SISTEMA),1)
aPTipos := PReadSVC(,nSys)
(PUALIAS)->(MsRLock())
IF P_LOCK != "J"
   dbCloseAll()
   UserException("Erro na Flag P_LOCK")
Endif
             
DbSelectArea(PSALIAS)
DbSetOrder(1)
DbSeek(cSerie)
ConOut("PALMJOB: Inicio - " + cSerie + " - " + DtoC(Date()) +  " - " + Time())
While ( !Eof() .And. Trim((PSALIAS)->P_SERIE) == cSerie)

	PSetError(.F.)
	
	PAddLog(cSerie,(PSALIAS)->P_ID)
		
	//verifica se servico existe
//	nServ := PExistServ((PSALIAS)->P_TIPO)
	nServ := Ascan(aPTipos,{|x| x[2] == Trim((PSALIAS)->P_TIPO)})
	If ( nServ <> 0 )
	
		//retorna alias e nome fisico usado pelo servico
		aAlias := PExeTable(nServ)
		aPalm := PExeArq(nServ)
		aInd := PExeInd(nServ)

		If ( !PSetError() )
			//executar prepare env
			__RPCCALLED := .F.
			IF __cLastEmp != Subs((PSALIAS)->P_EMPFI,1,2) 
			    IF __cLastEmp != "@@"
					For i := 1 to 512
						DbSelectArea(i)  
						If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
							DbCloseArea()
						Endif
					Next
			    	RpcClearEnv(.f.)
				Endif	             
				lRPCOpened := .t.
				RpcSetType ( 3 )
				RpcSetEnv(Subs((PSALIAS)->P_EMPFI,1,2),Subs((PSALIAS)->P_EMPFI,3,2),,,cEnv,,aAlias)
				__cLastEmp := Subs((PSALIAS)->P_EMPFI,1,2)
            Else
                For ni:= 1 to Len(aAlias)
                  IF Select(aAlias[ni]) == 0
                     ChkFIle(aAlias[ni]) 
                  Endif
                Next  
				cFilAnt :=  Subs((PSALIAS)->P_EMPFI,3,2)
            Endif
			//executa servico
			PExeServ(nServ)
				
			If !PSetError()
			
				//verifica se a classe e download
				If ( (PSALIAS)->P_CLASSE == "2" )
					
					//abre tabelas do diretorio NEW
					POpenNew(aPalm,aInd)

					If ( !PSetError() )
						//abre tabelas do diretorio ATUAL
						POpenAtual(aPalm,aInd)

						If ( !PSetError() )
							
							//atualiza diretorio DIFS
							PCreateDifs(aPalm,aInd)
						EndIf
					EndIf
					If ( !PSetError() )
						PUpdLog(,"Servico "+Trim((PSALIAS)->P_TIPO)+" executado com sucesso"  + " - " + Time())
					EndIf
				Else
					PUpdLog(,"Servico "+Trim((PSALIAS)->P_TIPO)+" executado com sucesso")
				EndIf
			EndIf
				
			// Reinicializa variavel de Lig de Transacao (USERLGA/USERLGI)
//			__cLogSiga := cLogSiga
		Else
			PUpdLog(,"Servico "+Trim((PSALIAS)->P_TIPO)+" indefinido")
		EndIf
	EndIf
	DbSelectArea(PSALIAS)
	DbSkip()
End

If Empty(cTime)
	cTime := DtoS(Date())+Time()
EndIf
DbSelectArea(PTALIAS)
(PTALIAS)->(dbSeek(cSerie))
(PTALIAS)->(MSRLOCK())
(PTALIAS)->P_TIME := PSumTime(cTime,(PTALIAS)->P_RANGE)
(PTALIAS)->(MsrUnlock())
(PUALIAS)->(MSRLock())
(PUALIAS)->P_LOCK := Space(1)   // Utiliza Lock Fisico, pq o Lock do registro 
(PUALIAS)->P_DELDATA := Space(1)   // Exclui Base
(PUALIAS)->(MsRUnlock())  			      	//	se perde qdo o HTTP:JOB cai por TimeOut
DbCommitAll()

ConOut("PALMJOB: Fim - " + cSerie + " - " + DtoC(Date()) +  " - " + Time())

IF lRPCOpened
	For i := 1 to 512
		DbSelectArea(i)  
		If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
			DbCloseArea()
		Endif
	Next
   	RpcClearEnv(.f.)
Else
    ConOut("Nao existe servico cadastrado para "+(PUALIAS)->P_USER)
Endif

			
// Gera o Script
CountADV()
McsScript(__cUserDir)

__cUserDir := NIL

FClose(nHdl)

GravaPlLog(cSerie + Space(20 - Len(cSerie)) + " - Fim    = " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
dbCloseAll()
Return

Function POpenNew(aPalm,aInd)
Local i
Local cFile
Local cIndex
Local cNewDir := __cUserDir+"NEW\"
Local cSvAlias := Alias()
Local cDriver := GetLocalDBF()

For i := 1 To Len(aPalm)
	aPalm[i] := AllTrim(aPalm[i])
	If Len(aPalm[i]) > 8
		cFile := cNewDir+aPalm[i]
		PUpdLog(,"Nome do arquivo inválido (8 caracteres) - "+cFile)
		PSetError(.T.)
		Exit
	Else
		cFile := cNewDir+aPalm[i]
    	Ferase(cFile+".CDX")
		If MsFile(cFile+DBFEXT,,cDriver)
			If MsOpEndbf(.T.,cDriver,cFile+DBFEXT,aPalm[i]+"NW",.T.,.F.,.F.,.F.)
				DbSelectArea(aPalm[i]+"NW")
				DbClearInd()
				If ( i <= Len(aInd) )
					cIndex := aPalm[i]+"1"
					INDEX ON &(aInd[i]) TAG &cIndex TO &cFile
					//INDEX ON &(aInd[i]) TAG &cIndex TO &(cFile+".CDX")
				Else
					PUpdLog(,"Erro na configuracao do servico - Indice da tabela "+aPalm[i])
					PSetError(.T.)
					Exit
				EndIf
			Else
				PUpdLog(,"Erro de abertura - "+cFile)
				PSetError(.T.)
				Exit
			EndIf
		Else
			PUpdLog(,"Tabela nao existe - "+cFile)
			ConOut("Tabela nao existe - "+cFile)
			PSetError(.T.)
			Exit
		EndIf
	EndIf
Next

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return

Function POpenAtual(aPalm,aInd)
Local i,j
Local cSvAlias := Alias()
Local cFile
Local cAtualDir := __cUserDir+"ATUAL\"
Local cIndex
Local aStru
Local cDriver := GetLocalDBF()

For i := 1 To Len(aPalm)
	aPalm[i] := AllTrim(aPalm[i])
	If Len(aPalm[i]) > 8
		PUpdLog(,"Nome do arquivo inválido (8 caracteres) - "+cFile)
		PSetError(.T.)
		Exit
	Else
		cFile := cAtualDir+aPalm[i]
		Ferase(cFile+".CDX")
		If MsFile(cFile+DBFEXT,,cDriver)
			If MsOpEndbf(.T.,cDriver,cFile+DBFEXT,aPalm[i]+"AT",.F.,.F.,.F.,.F.)
				DbSelectArea(aPalm[i]+"AT")
				DbClearInd()               
                			
				If ( i <= Len(aInd) )
					cIndex := aPalm[i]+"1"
					//INDEX ON &(aInd[i]) TAG &cIndex TO &cFile
					INDEX ON &(aInd[i]) TAG &cIndex TO &(cFile+".CDX")
				Else
					PUpdLog(,"Erro na configuracao do servico - Indice da tabela "+aPalm[i])
					PSetError(.T.)
					Exit
				EndIf
			Else
				PUpdLog(,"Erro de abertura - "+cFile)
				PSetError(.T.)
				Exit
			EndIf
		Else
			DbSelectArea(aPalm[i]+"NW")
			aStru := DbStruct()
			MsCreate(cFile,aStru,cDriver)
			i--
		EndIf
	EndIf
Next

DbSelectArea(cSvAlias)
Return

Function PCreateDifs(aPalm,aInd)
Local i,j
Local cSvAlias := Alias()
Local cChave
Local aDifStru
Local cFile
Local lDif
Local cDifsDir := __cUserDir+"DIFS\"
Local cNewAlias
Local cAtuAlias
Local cNewKey
Local cAtuKey
Local aAlias := {}
Local aTransmit := {0,0,0} //{INTR_I, INTR_A, INTR_E}
Local cDriver := GetLocalDBF()

For i := 1 To Len(aPalm)
	cChave := aInd[i]
	cNewAlias := aPalm[i]+"NW"
	cAtuAlias := aPalm[i]+"AT"
	lDif := .F.
	
	DbSelectArea(cNewAlias)
	//cria arquivo de diferencas
	cFile := cDifsDir+aPalm[i]
	Ferase(cFile+DBFEXT)
	aDifStru := DbStruct()
	Aadd(aDifStru,{"INTR","C",1,0})
	MsCreate(cFile+DBFEXT,aDifStru,cDriver)
	
	If MsOpenDbf(.T.,cDriver,cFile+DBFEXT,"DIFS",.T.,.F.,.F.,.F.)

		//primeiro varre base oficial p/ procurar diferencas
		DbSelectArea(cNewAlias)
		DbSetOrder(1)
		DbGoTop()
		DbSelectArea(cAtuAlias)
		DbSetOrder(1)
		DbGoTop()

		AAdd( aAlias, { cNewAlias ,aPalm[i] } )
	
		HHJobTbl( aAlias ) 
		While !(cNewAlias)->(Eof()) .Or. !(cAtuAlias)->(Eof())
			DbSelectArea(cNewAlias)
			If Eof()
				cNewKey := Chr(255)
			Else
				cNewKey := &cChave
			Endif
			
			DbSelectArea(cAtuAlias)
			If Eof()
				cAtuKey := Chr(255)
			Else
				cAtuKey := &cChave
			Endif
			                      
			If cNewKey == cAtuKey 
				lDif := .f.
				For j := 1 To Len(aDifStru)-1
					lDif := (cNewAlias)->(FieldGet(j)) <> (cAtuAlias)->(FieldGet((cAtuAlias)->(FieldPos(aDifStru[j][1]))))
					If lDif
						Exit
					EndIf
				Next
				If lDif
					DbSelectArea("DIFS")
					RecLock("DIFS",.T.)
					For j := 1 To Len(aDifStru)-1
						FieldPut(j,(cNewAlias)->(FieldGet(j)))
					Next
					DIFS->INTR := "A"
					MsUnlock()
					aTransmit[2] := aTransmit[2] + 1
				EndIf
				(cNewAlias)->(DbSkip())
				(cAtuAlias)->(DbSkip())
			Elseif (cNewKey > cAtuKey .And. !(cAtuAlias)->(Eof())) .Or. (cNewAlias)->(Eof())	//Deletar do Atual
				DbSelectArea("DIFS")
				RecLock("DIFS",.T.)
				For j := 1 To Len(aDifStru)-1
					FieldPut(j,(cAtuAlias)->(FieldGet((cAtuAlias)->(FieldPos(aDifStru[j][1])))))
				Next
				DIFS->INTR := "E"
				MsUnlock()
				aTransmit[3] := aTransmit[3] + 1
				(cAtuAlias)->(DbSkip())
			Else
				DbSelectArea("DIFS")
				RecLock("DIFS",.T.)
				For j := 1 To Len(aDifStru)-1
					FieldPut(j,(cNewAlias)->(FieldGet(j)))
				Next
				DIFS->INTR := "I"
				MsUnlock()
				aTransmit[1] := aTransmit[1] + 1
				(cNewAlias)->(DbSkip())
			Endif						
		End
		DbCommitAll()
		PUpdTransmit(cDifsDir, aPalm[i], "DIFS", aTransmit) // Atualiza o arquivo de Transmissao
		aTransmit := {0,0,0}
		DbSelectArea("DIFS")
		DbCloseArea()
	Else
		PUpdLog(,"Erro de abertura - "+cFile)
		PSetError(.T.)
		Exit
	EndIf
Next

DbSelectArea(cSvAlias)
Return

Function PalmCreate(aStru,cArquivo,cAlias,lGeneric,cGDir)
Local nTry := 3
Local nX   := 1
Local lOk  := .F.                                 
Local cHandHeldDir
Local cSerie := Trim(PALMUSER->P_SERIE)
Local __cServAlias := POpenServ()
Local cDriver := GetLocalDBF()
DEFAULT lGeneric := .f.
             
MakeDir(__cUserDir)
MakeDir(__cUserDir+"\NEW\")
MakeDir(__cUserDir+"\ATUAL\")
MakeDir(__cUserDir+"\DIFS\")

//__cUserDir := "\handheld\p000001\"
IF !lgeneric 
	cArquivo := __cUserDir+"NEW\"+cArquivo
Else                                                              
	cHandHeldDir := GetcDir()
	cHandHeldDir += cGDir
	cArquivo := cHandheldDir+cArquivo
Endif
lOk := MsCreate(cArquivo+DBFEXT,aStru,cDriver)
If !lOk
	// Tenta criar o arquivo
	While !lOk .And. nX <= nTry
		lOk := MsCreate(cArquivo+DBFEXT,aStru,cDriver)
		nX++
	EndDo
	PAddLog(cSerie,(__cServAlias)->P_ID)
	If !lOk
		PUpdLog(,"Arquivo " + cArquivo + DBFEXT + " nao foi criado." + " - " + Time())
	Else
		PUpdLog(,"Arquivo " + cArquivo + DBFEXT + " criado. " + Str(nX,1,0) + " - " + Time())
	EndIf
EndIf
MsOpEndbf(.T.,cDriver,cArquivo+DBFEXT,cAlias,.T.,.F.,.F.,.F.)
Return

Function PalmDir(cSerie)
Local cRet
Local PUALIAS

If cSerie == NIL
	cRet := __cUserDir
Else
	PUALIAS := POpenUser()
	DbSelectArea(PUALIAS)
	DbSetOrder(1)
	If DbSeek(cSerie)
		cRet := PGetDir()+"P"+AllTrim((PUALIAS)->P_DIR)+"\"
	Else
		cRet := "-1"
	EndIf
EndIf
Return cRet

Function PRootPath()

If __cRootPath == NIL
	__cRootPath := Trim(GetSrvProfString("RootPath",""))
	If Subs(__cRootPath,Len(__cRootPath),1) == "\"
		__cRootPath := Subs(__cRootPath,1,Len(__cRootPath)-1)
	EndIf
EndIf
Return __cRootPath

Function PDif2Atu(cSerie,cFile,cKey)
Local i, nPos
Local cSvAlias := Alias()
Local nRet := 0
Local PUALIAS := POpenUser()
Local cAtuDir
Local cDifDir                      
Local cChave                                 
Local lSeek
Local nHandle := 0
Local lLog := .F.
Local lOpen := .F.
Local nTimes := 1
Local cFlag := ""
Local nRecDifs := 0
Local nRecAtu := 0
Local cDriver := GetLocalDBF()
Private __RpcSxNoOpen := .T.

DEFAULT cSerie := ""
DEFAULT cFile := ""
//RpcSetEnv("","")

cFile := AllTrim(cFile)

DbSelectArea(PUALIAS)
DbSetOrder(1)
If DbSeek(cSerie)
	cAtuDir := PGetDir()+"P"+AllTrim((PUALIAS)->P_DIR)+"\ATUAL\"
	cDifDir := PGetDir()+"P"+AllTrim((PUALIAS)->P_DIR)+"\DIFS\"
	If File(cAtuDir+cFile+DBFEXT)
		If File(cDifDir+cFile+DBFEXT)
			If MsOpEndbf(.T.,cDriver,cAtuDir+cFile+DBFEXT,"ATUAL",.F.,.F.,.F.,.F.) //abre exclusivo
				DbSelectArea("ATUAL")
				DbClearInd()
				Ferase(cAtuDir+cFile+".IDX")
				INDEX ON &(cKey) to &(cAtuDir+cFile+".IDX")
				//IndRegua("ATUAL",cAtuDir+cFile,cKey,,,,.F.)
				/******************************** 
				INTR = 7 ou N - Registro Enviado
				INTR = 8 - Registro Atualizado
				INTR = 9 - Registro Apagado
				*********************************/
//				If MsOpEndbf(.T.,JOBDRIVER,cDifDir+cFile,"DIFS",.T.,.F.,.F.,.F.)
				lOpen := MsOpEndbf(.T.,cDriver,cDifDir+cFile+DBFEXT,"DIFS",.F.,.F.,.F.,.F.)
				While !lOpen .And. nTimes <= 2
					Sleep(1000)
					lOpen := MsOpEndbf(.T.,cDriver,cDifDir+cFile+DBFEXT,"DIFS",.F.,.F.,.F.,.F.) // Abre Exclusivo
					nTimes++
				EndDo
				If MsOpEndbf(.T.,cDriver,cDifDir+cFile+DBFEXT,"DIFS",.F.,.F.,.F.,.F.) // Abre Exclusivo
					DbSelectArea("DIFS")
					DbClearInd()
					Ferase(cDifDir+cFile+".IDX")
					INDEX ON &(cKey) to &(cDifDir+cFile+".IDX")
					//IndRegua("DIFS",cDifDir+cFile,cKey,,,,.F.)
					DbGoTop()
					If !Eof()
						lLog := .T.
					EndIf
					If lLog
						nHandle := If(!File(cDifDir + AllTrim((PUALIAS)->P_DIR) + ".LOG"),FCreate(cDifDir + AllTrim((PUALIAS)->P_DIR) + ".LOG"),FOpen(cDifDir + AllTrim((PUALIAS)->P_DIR) + ".LOG",FO_EXCLUSIVE+FO_READWRITE))
						FSeek(nHandle, 0, 2)
						FWrite(nHandle, "Inicio DIFS -> ATUAL - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
						FWrite(nHandle, "DIFS = " + Str(DIFS->(RecCount()),4,0) + " - ATUAL = " + Str(ATUAL->(RecCount()),4,0) + Chr(13) + Chr(10))
					EndIf
					While !Eof()				
		    			cChave := &(cKey)
		    			If lLog
			    			FWrite(nHandle, Space(5) + cFile + " - " + cChave + " - " + DIFS->INTR + Chr(13) + Chr(10))
			    		EndIf
						DbSelectArea("ATUAL")
						If DIFS->INTR $ "89"
							If (lSeek := dbSeek(cChave))
								MSRLock(Recno())
							EndIf
						ElseIf DIFS->INTR == "7" .Or. DIFS->INTR == "N"
							If (lSeek := dbSeek(cChave))
								MSRLock(Recno())
								//RecLock("ATUAL",.F.)
							Else
								dbAppend(.f.)
								//RecLock("ATUAL",.T.)
								lSeek := .t.
							EndIf							
						Endif
						If lSeek
							If DIFS->INTR == "9"
								dbDelete()
							Else
								For i := 1 To ATUAL->(FCount())
									nPos := DIFS->(FieldPos(ATUAL->(Field(i))))
									If nPos > 0
										ATUAL->(FieldPut(i,DIFS->(FieldGet(nPos))))
									EndIf
								Next
							Endif
							MsRUnlock(Recno())
							If DIFS->INTR $ "IAE"
								cFlag := DIFS->INTR
							EndIf
							dbSelectArea("DIFS")
							MsRLock(Recno())
							//RecLock("DIFS",.F.)
							DIFS->(dbDelete())
							//DIFS->INTR := "0"
							MsRUnlock(Recno())
							lSeek := .F.
						EndIf
						DbSelectArea("DIFS")
						DbSkip()				
					End
					DbCommitAll()
					// Apaga os Registros Transmitidos
					nRecDifs := DIFS->(RecCount())
					DbSelectArea("DIFS")
					Pack				
					DbCloseArea()
				Else
					//arquivo de diferenca nao existe
					nRet := -3
				EndIf
				DbSelectArea("ATUAL")
				Pack
				nRecAtu := ATUAL->(RecCount())
				DbCloseArea()
				If lLog
					FWrite(nHandle, "DIFS = " + Str(nRecDifs,5,0) + " - ATUAL = " + Str(nRecAtu,5,0) + Chr(13) + Chr(10))
					FWrite(nHandle, "Fim DIFS -> ATUAL - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
					FWrite(nHandle, Replicate("-", 50) + Chr(13) + Chr(10))
					FClose(nHandle)
					lLog := .F.
				EndIf
				
			Else
				//arquivo atual nao existe
				nRet := -2
			EndIf
		Else
			//arquivo de diferenca nao existe
			nRet := -3
		EndIf
	Else
		//arquivo atual nao existe
		nRet := -2
	EndIf	
Else
	//usuario nao encontrado
	nRet := -1
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return Str(nRet)



Function PDif2AtuImp(cSerie,cFile,cKey)
Local i, nPos
Local cSvAlias := Alias()
Local nRet := 0
Local PUALIAS := POpenUser()
Local cAtuDir
Local cDifDir                      
Local cChave                                 
Local lSeek
Local nHandle := 0
Local lLog := .F.
Local lOpen := .F.
Local nTimes := 1
Local cFlag := ""
Local cDriver := GetLocalDBF()
//Local nReg := 0 // Lorenfer
Private __RpcSxNoOpen := .T.

DEFAULT cSerie := ""
DEFAULT cFile := ""
//RpcSetEnv("","")

cFile := AllTrim(cFile)

DbSelectArea(PUALIAS)
DbSetOrder(1)
If DbSeek(cSerie)
	cAtuDir := PGetDir()+"P"+AllTrim((PUALIAS)->P_DIR)+"\ATUAL\"
	cDifDir := PGetDir()+"P"+AllTrim((PUALIAS)->P_DIR)+"\DIFS\"
	If File(cAtuDir+cFile+DBFEXT)
		If File(cDifDir+cFile+DBFEXT)
			If MsOpEndbf(.T.,cDriver,cAtuDir+cFile+DBFEXT,"ATUAL",.F.,.F.,.F.,.F.) //abre exclusivo
				DbSelectArea("ATUAL")
				DbClearInd()
				Ferase(cAtuDir+cFile+".IDX")
				INDEX ON &(cKey) to &(cAtuDir+cFile+".IDX")
				//IndRegua("ATUAL",cAtuDir+cFile,cKey,,,,.F.)
				/******************************** 
				INTR = 7 ou N - Registro Enviado
				*********************************/
				lOpen := MsOpEndbf(.T.,cDriver,cDifDir+cFile+DBFEXT,"DIFS",.F.,.F.,.F.,.F.)
				While !lOpen .And. nTimes <= 2
					Sleep(1000)
					lOpen := MsOpEndbf(.T.,cDriver,cDifDir+cFile+DBFEXT,"DIFS",.F.,.F.,.F.,.F.) // Abre Exclusivo
					nTimes++
				EndDo
				If MsOpEndbf(.T.,cDriver,cDifDir+cFile+DBFEXT,"DIFS",.F.,.F.,.F.,.F.) // Abre Exclusivo
					DbSelectArea("DIFS")
					DbClearInd()
					Ferase(cDifDir+cFile+".IDX")
					INDEX ON &(cKey) to &(cDifDir+cFile+".IDX")
					//IndRegua("DIFS",cDifDir+cFile,cKey,,,,.F.)
					DbGoTop()
					If !Eof()
						lLog := .T.
					EndIf
					If lLog
						nHandle := If(!File(cDifDir + AllTrim((PUALIAS)->P_DIR) + ".LOG"),FCreate(cDifDir + AllTrim((PUALIAS)->P_DIR) + ".LOG"),FOpen(cDifDir + AllTrim((PUALIAS)->P_DIR) + ".LOG",FO_EXCLUSIVE+FO_READWRITE))
						FSeek(nHandle, 0, 2)
						FWrite(nHandle, "Inicio DIFS -> ATUAL - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
						FWrite(nHandle, "DIFS = " + Str(DIFS->(RecCount()),4,0) + " - ATUAL = " + Str(ATUAL->(RecCount()),4,0) + Chr(13) + Chr(10))
					EndIf
					While !Eof()				
		    			cChave := &(cKey)
		    			If lLog
			    			FWrite(nHandle, Space(5) + cFile + " - " + cChave + " - " + DIFS->INTR + Chr(13) + Chr(10))
			    		EndIf
						DbSelectArea("ATUAL")
						If DIFS->INTR == "N"
							If (lSeek := dbSeek(cChave))
								MSRLock(Recno())
								//RecLock("ATUAL",.F.)
							Else
								dbAppend(.F.)
								//RecLock("ATUAL",.T.)
								lSeek := .T.
							EndIf							
						Endif
						If lSeek
							For i := 1 To ATUAL->(FCount())
								nPos := DIFS->(FieldPos(ATUAL->(Field(i))))
								If nPos > 0
									ATUAL->(FieldPut(i,DIFS->(FieldGet(nPos))))
								EndIf
							Next
							MsRUnlock(Recno())
							dbSelectArea("DIFS")
							MsRLock(Recno())
							//RecLock("DIFS",.F.)
							DIFS->(dbDelete())
							//DIFS->INTR := "0"
							MsRUnlock(Recno())
							lSeek := .F.					
						Endif
						DbSelectArea("DIFS")
						DbSkip()				
					End
					DbCommitAll()
				EndIf			
				// Apaga os Registros Transmitidos
				If lLog
					FWrite(nHandle, "DIFS = " + Str(DIFS->(RecCount()),4,0) + " - ATUAL = " + Str(ATUAL->(RecCount()),4,0) + Chr(13) + Chr(10))
				EndIf
				DbSelectArea("DIFS")
				Pack				
				DbCloseArea()
				If lLog
					If !Empty(cFlag)
						FWrite(nHandle, "cFlag ------------> " + cFlag + " - Existem Flags Inalterados na Pasta DIFS apos o sincronismo - "  + Chr(13) + Chr(10))
					EndIf
					FWrite(nHandle, "Fim DIFS -> ATUAL - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
					FWrite(nHandle, Replicate("-", 50) + Chr(13) + Chr(10))
					FClose(nHandle)
					lLog := .F.
				EndIf
				DbSelectArea("ATUAL")
				Pack
				DbCloseArea()
			Else
				//arquivo de diferenca nao nao aberto
				nRet := -3
			EndIf
		Else
			//arquivo de diferenca nao existe
			nRet := -3
		EndIf
	Else
		//arquivo atual nao existe
		nRet := -2
	EndIf
Else
	//usuario nao encontrado
	nRet := -1
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return Str(nRet)


Function PalmLock(cSerie)
Local cRet := "-1",i                              

If __cAlias == Nil
	__cAlias := POpenUSER()
Endif
If (__cAlias)->(dbSeek(cSerie))
	__nRecLock := (__cAlias)->(Recno())
	If Empty((__cAlias)->P_LOCK) .Or. (__cAlias)->P_LOCK == "H" 
		For i := 1 to 10
	    	If (__cAlias)->(MsRLock())
	       		If (__cAlias)->P_LOCK != "J" .And. (__cAlias)->P_LOCK != "P"  // Inclusao do Flag de Process
					(__cAlias)->P_LOCK := "H" 
					cRet := "0"
			 	Endif
				// Utiliza Lock Fisico, pq o Lock do registro e perdido no fim da thread
				(__cAlias)->(MsRUnlock())
				Return cRet
			EndIf
			Sleep(i * 100)
	    Next
	Else
		cRet := "-2"
	EndIf
EndIf
Return cRet

Function PalmUnlock(cSerie)
Local cRet := "-1",i
If __cAlias == Nil
	__cAlias := POpenUSER()
Endif
If cSerie != Nil
	If (__cAlias)->(dbSeek(cSerie))	
	    for i := 1 to 10
			if (__cAlias)->(MsRLock())
				(__cAlias)->P_LOCK := Space(1)  // Utiliza Lock Fisico, pq o Lock do registro e perido no fim da Thread
				(__cAlias)->(MsRUnlock())
				(__cAlias)->(dbCloseArea())
				__nRecLock := Nil
				__cAlias := Nil
				cRet := "0"
				return cRet
			endif
			sleep(i * 100)
		next
	EndIf
Else
	If __nRecLock != Nil
		(__cAlias)->(dbgoto(__nRecLock))
		for i := 1 to 10
			if (__cAlias)->(MsRLock())
				(__cAlias)->P_LOCK := Space(1)  // Utiliza Lock Fisico, pq o Lock do registro 
				MsUnlock()  					 //	se perde qdo o HTTP:JOB cai por TimeOut				
				(__cAlias)->(dbCloseArea())
				__nRecLock := Nil
				__cAlias := Nil
				cRet := "0"
				return cRet
			endif
			sleep(i * 100)
		next
	Endif
Endif
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PalmIsOk ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o Status das Lincesas de uso do Handheld           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Main Function PJob()
StartJob("Palmjob",GetEnvServer(),.F.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PICheck  ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o Status do Usuario Palm.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSerie: Numero de serie do Handheld                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PICheck(cSerie)

Local cRet
__cAlias := POpenUSER()
dbSelectArea( __cAlias )
If (__cAlias)->(dbSeek(cSerie))
	Count To nReg For (__cAlias)->(!Deleted())
	cRet := Str(nReg,10,0)
//	cRet := Str((__cAlias)->(Recno()),10,0)
Else
    cRet := "-3"
EndIf
//(__cAlias)->(dbCloseArea())
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PIOpen   ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o Status do Usuario Palm.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSerie: Numero de serie do Handheld                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PIOpen(cSerie)
Local cRet        := "-1"
Local cRetPOpen   := "-1"
Local cRetPICheck := "-1"
Local nReg        := 0
Local nPos := 0
Set Deleted On

nPos := At("|", cSerie)
If nPos != 0
	cSerie := Subs(cSerie, 1, nPos-1)
EndIf

GravaPLLog(cSerie + Space(20 - Len(cSerie)) + " - Iniciando   PIOPEN[1] = " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
PTInternal(1,"Iniciando PIOPEN " + cSerie)
// Checa a quantidade Usuarios cadastrados
__cAlias := POpenUSER()
dbSelectarea( __cAlias )
If (__cAlias)->(dbSeek(cSerie))
	Count To nReg For (__cAlias)->(!Deleted() )
	cRetPICheck := Str(nReg,10,0)
//	cRet := Str((__cAlias)->(Recno()),10,0)
Else
    cRetPICheck := "-3"
EndIf

// Checa o Lock do Usuario e Retorna ID do Diretorio
cRetPIOpen := PalmLock(cSerie)
If cRetPIOpen = "0"
    PTInternal(1,"Autenticacao do Palm "+cSerie+" OK")
	//cPath := PRootPath()
	cPath := PalmDir(cSerie)
	cRetPIOpen  := StrTran(Right(cPath,7),"\")
Else
    PTInternal(1,"Autenticacao do Palm "+cSerie+" Recusada")
EndIf

cRet := cRetPIOpen + "|" + cRetPICheck
ConOut("PIOPEN -> " + cRet)
//cRet := cRetPIOpen // Alterado por Fabio Garbin - Utilizado para o MCS 3.0.1 (06/08/2002)
PTInternal(1,"Finalizando PIOPEN "+cSerie)
GravaPLLog(cSerie + Space(20 - Len(cSerie)) + " - Finalizando PIOPEN[2] = " + DtoC(Date()) + " - " + cRet + " - " + Time() + Chr(13) + Chr(10))
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PIClose  ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a atualizacao dos Arquivos do diretorio ATUAL.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSerie: Numero de serie do Handheld                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PIClose(cSerie, cErr)

Local cRet         := "-1"
Local __cServAlias := POpenServ()
Local __cServUser  := POpenUser()
Local cPath        := ""
Local cConFile     := ""
//Local aPalm        := {}
//Local aInd         := {}
//Local nServ        := 0
Local nHdl         := 0
Local nPos       := 0
//Local i

DEFAULT __nInterval := VAL(GetSrvProfString("HHThreadTimer","3000"))
DEFAULT cErr := "ENDOK"

Set Deleted On

nPos := At("|", cSerie)
If nPos != 0
	cSerie := Subs(cSerie, 1, nPos-1)
EndIf

GravaPLLog(cSerie + Space(20 - Len(cSerie)) + " - Iniciando   PICLOSE[1] = " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))

(__cServUser)->(dbSeek(cSerie))
cPath    := GetcDir() + "P" + AllTrim((__cServUser)->P_DIR) + "\DIFS\"
cConFile := "P" + AllTrim((__cServUser)->P_DIR) + ".LCK"  // Arquivo que indica transacao Bloqueada

dbSelectArea(__cServAlias)
dbSetOrder(1)
If dbSeek(cSerie) .And. !File(cPath+cConFile) .And. (__cServUser)->P_LOCK = "H"
	nHdl := MSFCREATE("\SEMAFORO\"+ cSerie +".LCK")
	If (__cServUser)->(MsRLock())
		(__cServUser)->P_LOCK := "P"
		(__cServUser)->(MSRUnlock() )
	EndIf
	If nHdl >= 0
		FClose(nHdl)
		StartJob("PUpdData",GetEnvServer(),.F.,cSerie, cErr)
		Sleep(__nInterval)
		cRet := "0"
	Else
		cRet := "-1"
	EndIf
Else
	cRet := "-1"
	ConOut("PALMJOB: Atualizacao ignorada, conexao nao finalizada para " + cSerie + " - " + Time())
	If (__cServUser)->P_LOCK = "J"
		ConOut("PALMJOB: Arquivos do usuario " + cSerie +"estao sendo atualizados pela retaguarda, tente mais tarde. - " + Time())
	ElseIf (__cServUser)->P_LOCK = "P"
		ConOut("PALMJOB: Arquivos do usuario " + cSerie +"estao processados pela retaguarda, tente mais tarde. - " + Time())
	EndIf
	If !Found()
	    Conout("PALMJOB: Verifique se ha servicos cadastrados para " + cSerie)
	EndIf
	If File(cPath+cConFile)
    	Conout( "PALMJOB: Usuario " + cSerie + " em processo de sincronismo.")
 	EndIf
EndIf
GravaPLLog(cSerie + Space(20 - Len(cSerie)) + " - Finalizando PICLOSE[2] = " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
dbCloseAll()
Return cRet

Function PUpdData(cSerie, cErr)
Local __cServAlias := POpenServ()
Local __cServUser  := POpenUser()
Local aPalm        := {}
Local aInd         := {}
Local nServ        := 0
Local i            := 0
Local nHdl         := MSFCREATE("\SEMAFORO\"+ cSerie +".LCK")

Set Deleted On

(__cServUser)->(dbSeek(cSerie))

If nHdl < 0
	ConOut(FError())
	GravaPlLog((cSerie + " - " + (__cServUser)->(P_CODVEND) + " - " + Space(20 - Len(cSerie)) + " - Erro do Semaforo (PICLOSE)=" + Str(FError(),3,0) + " - " + Time() + Chr(13) + Chr(10)))
	dbCloseAll()
	UserException("Erro de Criacao de Semaforo")
Endif
GravaPLLog(cSerie + " - " + (__cServUser)->(P_CODVEND) + " - " + Space(20 - Len(cSerie)) + " - Iniciando Atualizacao = " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))

PTInternal(1,"Diferenca para Atual do Dispositivo "+cSerie)
ConOut("PALMJOB: Atualizacao iniciada para " + cSerie + " - " + Time())
dbSelectArea(__cServAlias)
dbSetOrder(1)
(__cServAlias)->(dbSeek(cSerie))
While !(__cServAlias)->(Eof()) .And. cSerie = AllTrim((__cServAlias)->P_SERIE)
	nServ := PExistServ((__cServAlias)->P_TIPO) // Verifica se o Servico existe
	If ( nServ <> 0 )
		//retorna nome fisico  e indices usado pelo servico
		aPalm := PExeArq(nServ)
		aInd  := PExeInd(nServ)
		For i := 1 To Len(aPalm)
			If cErr = "ENDOK"
				PDif2Atu(cSerie,aPalm[i],aInd[i])
			Else
				If (__cServAlias)->P_SERIE = "1"
					PDif2AtuImp(cSerie,aPalm[i],aInd[i])
				EndIf
			EndIf
		Next
	Endif
	dbSelectArea(__cServAlias)
	dbSkip()
EndDo
ConOut("PALMJOB: Atualizacao finalizada para " + cSerie + " - " + Time())
PImport(cSerie, __cServAlias)
GravaPLLog(cSerie + " - " + (__cServUser)->(P_CODVEND) + " - " + Space(20 - Len(cSerie)) + " - Finalizando Atualizacao = " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
cRet := PalmUnlock(cSerie)
FClose(nHdl)
dbCloseAll()
FErase("\SEMAFORO\"+ cSerie +".LCK")
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PImport  ³ Autor ³ Fabio Garbin          ³ Data ³ 15/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa os servicos de Importacao.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSerie: Numero de serie do Handheld                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PImport(cSerie, __cServAlias)
Local aAlias     := {}
Local nServ      := 0
Local cEnv       := GetEnvServer()
Local PLALIAS    := POpenLog()
Local cJobAlias  := __cServAlias+"#"+PLALIAS+"#PALMUSER"
Local __cLastEmp := "@@"
Local i
Local ni:= 1
Local cRet
Local aPTipos
Local lRPCOpened := .f.

dbSelectArea(__cServAlias)
dbSetOrder(1)
If dbSeek(cSerie)
	cDifDir := PGetDir()+"P"+AllTrim(PALMUSER->P_DIR)+"\DIFS\"
    PTInternal(1,"Importacao iniciada para o Dispositivo " + cSerie)
	ConOut("PALMJOB: Importacao iniciada para " + cSerie + " - " + Time())

	aPTipos := PReadSVC(,Val(PALMUSER->P_SISTEMA))	

	While !Eof() .And. cSerie = AllTrim((__cServAlias)->P_SERIE)
		If (__cServAlias)->(P_CLASSE) = "2"
 			(__cServAlias)->(dbSkip())
 			Loop
 		EndIf
		PSetError(.F.)
	
		PAddLog(cSerie,(__cServAlias)->P_ID)

  		nServ := Ascan(aPTipos,{|x| x[2] == Trim((__cServAlias)->P_TIPO)}) // Verifica se o Servico existe

		If ( nServ <> 0 )
			aAlias := PExeTable(nServ)
			aPalm  := PExeArq(nServ)
			aInd   := PExeInd(nServ)
		
			//executar prepare env
			__RPCCALLED := .F.
			If __cLastEmp != Subs((__cServAlias)->P_EMPFI,1,2) 
			    If __cLastEmp != "@@"
					For i := 1 to 512
						DbSelectArea(i)  
						If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
							DbCloseArea()
						Endif
					Next
			    	RpcClearEnv(.F.)
				Endif	             
				lRPCOpened := .t.
				RpcSetType ( 3 )
				RpcSetEnv(Subs((__cServAlias)->P_EMPFI,1,2),Subs((__cServAlias)->P_EMPFI,3,2),,,cEnv,,aAlias)
				__cLastEmp := Subs((__cServAlias)->P_EMPFI,1,2)
            Else
            	For ni:= 1 to Len(aAlias)
             		If Select(aAlias[ni]) == 0
		                ChkFile(aAlias[ni])
            		EndIf
                Next  
				cFilAnt :=  Subs((__cServAlias)->P_EMPFI,3,2)
            Endif
  		EndIf
  		
		PExeServ(nServ)
			
		dbSelectArea(__cServAlias)
		dbSkip()
	EndDo
EndIf
IF lRPCOpened
	For i := 1 to 512
		DbSelectArea(i)  
		If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
			DbCloseArea()
		Endif
	Next
   	RpcClearEnv(.f.)
Else
    ConOut("Nao existe servico cadastrado para "+PALMUSER->P_USER)
Endif
ConOut("PALMJOB: Importacao finalizada" + " para " + cSerie + " - " + Time())
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PChkFile ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica a existencia dos Arquivos do diretorio ATUAL.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPath: Caminho onde os arquivos devem estar                ³±±
±±³          ³ aArq : Array com o(s) nome(s) do(s) arquivos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PChkFile(cPath, aArq)
Local lRet   := .T.
Local nTry   := 3
Local nClose := 0
Local cMsg   := ""
Local nI := 1
Local i := 1
Local cDriver := GetLocalDBF()
For i := 1 To Len(aArq)
	cChave := aArq[i,3]
	cArq := aArq[i,1]
	If (File(cPath + aArq[i,1] + DBFEXT))
		dbUseArea(.T.,cDriver,cPath+aArq[i,1]+DBFEXT,aArq[i,2],.F.)
		If Select(aArq[i,2]) == 0
			For nI := 1 To nTry
				Sleep(1000)
				dbUseArea(.T.,cDriver,cPath+aArq[i,1]+DBFEXT,aArq[i,2],.F.)
				If Select(aArq[i,2]) != 0
					lRet := .T.
					Exit
				Else
					cMsg   := "PALMJOB: Arquivo " + aArq[i,1]+DBFEXT + " nao pode ser aberto."
					lRet   := .F.
					nClose := i
				EndIf
			Next nI
		EndIf
		If lRet
			DbClearInd()
			IndRegua(aArq[i,2],cPath+aArq[i,1],cChave,,,,.F.)
		EndIf
	Else
		cMsg   := "PALMJOB: Arquivo nao Encontrado " + aArq[i,1]
		lRet   := .F.
		nClose := i
		Exit		
	EndIf
Next
If !lRet
	// Se houver problema de abertura, fecha arquivos que ja foram abertos
	For i := 1 To nClose - 1
		If Select(aArq[i,2]) != 0
			(aArq[i,2])->(dbCloseArea())
		EndIf
	Next
	ConOut(cMsg)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PalmJob  ³ Autor ³ Fabio Garbin          ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que verifica e inicia o HHJOB                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PalmJob( )
Local cHandHeldDir := GetcDir()
Local cFileLock := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2) + ".LCK"
Local aJobs := {{"HHJOB",cFileLock,"I"}}
Local ni, lStart, nCount , nHdl
PTInternal(1,"Monitor de Palm Jobs Ativado....")

SET DELETED ON

While ( ! KillApp() )
	For nI:=1  To Len(aJobs)
		lStart := .F.
		
		If aJobs[ni,3] == 'I'
			lStart :=.T.
		Else
			If ( (nHdl := FOpen('\SEMAFORO\'+aJobs[ni,2], 0)) >= 0 )
				lStart := .T.
				FClose(nHdl)
		   EndIf
		EndIf

		If lStart
//			ConOut( 'Iniciando o Job ' + aJobs[ni,1] + ' ' + Time())
			StartJob( aJobs[ni,1], GetEnvServer(), .F. )
			aJobs [nI][3] := 'x'
		EndIf 
	Next
 
	nCount := 0
	 
	While ( !KillApp() .and. nCount < 12 )
		Sleep(10000)  
		nCount++
	End
End
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHError  ³ Autor ³ Fabio Garbin          ³ Data ³ 05/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de tratamento de Erros do PALMJOB                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HHJOB                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HHError(e, cSerie)
//Local cSerie  := ""
Local cFile   := GetcDir() + AllTrim(cSerie) + ".LOG"
Local nHandle := If(!File(cFile),FCreate(cFile),FOpen(cFile))
Local ni      := 2
Local cAlias  := POpenUser()
FSeek(nHandle, 0, 2)

dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(cSerie)
	If nHandle > 0
		FWrite(nHandle, DtoC(MsDate()) + " - " + Time() + Chr(13) + Chr(10))
		FWrite(nHandle, "Handheld          = " + AllTrim(cSerie) + " - " + PALMUSER->P_USER + Chr(13) + Chr(10))
		FWrite(nHandle, "Vendedor          = " + PALMUSER->P_CODVEND + Chr(13) + Chr(10))
		FWrite(nHandle, "Diretorio         = " + PalmDir(cSerie) + Chr(13) + Chr(10))
		FWrite(nHandle, "Erro Numero       = " + Str(e:genCode,5,0) + Chr(13) + Chr(10))
		FWrite(nHandle, "Descricao do Erro = " + e:description + Chr(13) + Chr(10))
		FWrite(nHandle, "" + Chr(13) + Chr(10))
		FWrite(nHandle, "Procedimentos Chamados:" + Chr(13) + Chr(10))
	Else		
		ConOut(AllTrim(cSerie) + " - " + PALMUSER->P_USER)
		ConOut(PALMUSER->P_CODVEND)
		ConOut(PALMUSER->P_DIR)
		ConOut(Str(e:genCode,5,0))
		ConOut(e:description)
	EndIf
	While ( !Empty(ProcName(ni)) )
		If nHandle <> 0
			FWrite(nHandle, "Called from: " + Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni)))+")" + Chr(13) + Chr(10))
		Else
			ConOut("Called from: " + Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni)))+")")
		EndIf
		ni++
	End
	FWrite(nHandle, "" + Chr(13) + Chr(10))
	FWrite(nHandle, Replicate("-", 80) + Chr(13) + Chr(10))
/*	
	RecLock("PALMUSER",.F.)
	PALMUSER->P_LOCK = "B"
	PALMUSER->(MsUnlock())
*/
EndIf
FClose(nHandle)
Return "DEFAULTERRORPROC"

Function GravaPlLog(cMsg)

#IFDEF LOGMODE
Local nHdl := -1 , nERR := 0, cDir := GetcDir()

While nHDL < 0
  nHdl := FOpen(cDir+"LOGPALM.TXT",FO_EXCLUSIVE+FO_READWRITE)
  IF nHdl < 0               
  	 IF !File(cDir+"LOGPALM.TXT")
  	     nHdl := FCREATE(cDir+"LOGPALM.TXT")
  	 Endif
  	 IF nHdl < 0
     	nERR++
     	IF nERR > 500
        	USEREXCEPTION("NAO CONSEGUI O LOG")
     	Endif
     	Sleep(100)
     	Loop
  	  Endif
  Endif
  Exit
End     
IF nERR > 10
   cMsg += "- Perdi "+StrZero(nERR/10,6,0)+ " Segundos para a abertura"
Endif
FSEEK(nHdl,0,2)
FWRITE(nHdl,cMsg)

FClose(nHdl) 
#ENDIF
Return Nil


Function GetcDir()                
Local cDir
cDir := GetGlbvalue("__HANDHELDDIR")
IF Empty(cDir)
   cDir := GetSrvProfString("HANDHELDDIR","\HANDHELD\")
   PutGlbValue("__HANDHELDDIR", cDir)
Endif                               
Return cDir


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PAcertaSX3³ Autor ³ Fabio Garbin         ³ Data ³ 25/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Acerta o Array de Estrutura com os valores do SX3          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aStru : Array com a estrutura do arquivo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PAcertaSx3(aStru)
Local aTam
Local nI := 1
dbSelectArea("SX3")
dbSetOrder(2)

For ni := 1 To Len(aStru)
	If dbSeek(aStru[ni,1])
		If AllTrim(aStru[ni,1]) == AllTrim(SX3->X3_CAMPO)
			aTam := TamSx3(aStru[ni,1])
			aStru[ni,3] := aTam[1]
			aStru[ni,4] := aTam[2]
		EndIf
	EndIf
Next ni

Return