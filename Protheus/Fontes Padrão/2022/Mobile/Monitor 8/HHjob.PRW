#INCLUDE "HHjob.ch"
#include "protheus.ch"
#include "Fileio.ch"

#define JOBDRIVER "DBFCDX"
#DEFINE  LOGMODE
#IFNDEF TOP
	#define RetSqlName RetDbfName
#ENDIF
Static __cLastEmp := "@@"
Static __cLastFil := "@@"
Static __cUserDir
Static __cRootPath
Static __nRecLock
Static __cAlias
Static __nInterval
Static __HHLog     := Val(GetSrvProfString("HHTriggerLog","0"))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHTrgJob  ³Autor  ³                    ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Chamada dos JOBS para o SFA                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHTrgJob( )
Local cTAtual
Local cDate
Local nC, lEnd
Local cNextHH := ""
Local nHDL, nWork, aTimes,nT
Local cHandHeldDir := GetHHDir()
Local cFileLock := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2)
Local aServGrp := {}
Local aHHGrp := {}
Local nSys := 1
Local nI := 1
Local nJ := 1
Local cSerie := ""

Set Deleted On
Set Date British

nWork := Val(GetSrvProfString("HandHeldWorks","1"))
DEFAULT __nInterval := VAL(GetSrvProfString("HHThreadTimer","5000"))

ErrorBlock({|e| HHErr(e)})

ConOut(STR0001+Time()+STR0002 + GetEnvServer()) //"Iniciando PALMJOB... ("###") em "
PTInternal(1,STR0003) // // // // //"Lancador de Palm Jobs por vendedor..."

Private PSYSALIAS := POpenSys()    // Arquivo de Sistemas
Private PUALIAS   := POpenHH()     // Arquivo de Usuários
Private PSALIAS   := POpenSrv()    // Arquivo de Servicos
Private PTALIAS   := HHOpenTime()  // Arquivo de Controle de Tempo
Private PGALIAS   := POpenGrp()    // Arquivo de Grupos
Private PTBLALIAS := POpenTbl()    // Arquivo de Tabelas
Private PLALIAS   := HHOpenLog()   // Arquivo de Log
Private PTRGALIAS := HHOpenTrg()   // Arquivo de Gatilhos
Private cJobAlias := PUALIAS+"#"+PSALIAS+"#"+PTALIAS+"#PALMUSER#HGS#HGU#HCADGRP#"+PLALIAS
Private aServ     := {}
Private cTime     := ""

// Reabre a Tabela HHTIME
(PTALIAS)->(dbCloseArea())
PTALIAS   := HHOpenTime()

//controle de aviso de execucao em job
HHInJob(.T.)

CriaPublica()

//carrega arquivo com lista de servicos
aServ := PGetServ()

//atualiza arquivo de controle de tempo, a partir do Proximo Handheld
DbSelectArea(PGALIAS)
DbSetOrder(1)
While ( !Eof() )
	
	//aServGrp := PGetServGrp((PGALIAS)->HHG_COD,@aServGrp)
	aHHGrp   := PGetHHGrp((PGALIAS)->HHG_COD,@aHHGrp)

	For nI := 1 To Len(aHHGrp)
		dbSelectArea(PTALIAS)
		dbSetOrder(1)
		If DbSeek((PGALIAS)->HHG_COD + aHHGrp[nI])
			RecLock(PTALIAS,.F.)
		Else
			RecLock(PTALIAS,.T.)
		EndIf
	
		//campo P_TIME sera usado no controle por min ou hr e nele
		//e gravado a proxima data + o proximo horario de atualizacao

		(PTALIAS)->HH_GRUPO := (PGALIAS)->HHG_COD
		(PTALIAS)->HH_SERIE := aHHGrp[nI]
//		(PTALIAS)->P_SRV   := aServGrp[nJ,1]
		//(PTALIAS)->HH_TIME  := ""
		(PTALIAS)->HH_RANGE := HHRetRange((PGALIAS)->HHG_FREQ,(PGALIAS)->HHG_TFREQ)
		
		MsUnlock()
   Next
	aServGrp := {}
	aHHGrp   := {}
	DbSelectArea(PGALIAS)
	DbSkip()
End

//a cada minuto verifica-se todos as linhas da tabela de controle de tempo
//e executa os servicos dos usuarios com horario ultrapassado

While !KillApp()

	If File(HHGetDir()+"PSTOP.JOB")
		ConOut(STR0004) // // // // //"Parando PALMJOB..."
		Exit
	EndIf
	
	cDate := Dtos(Date())
	cTAtual := cDate+Time()
	
	If ( Subs(cTAtual,1,13) <> Subs(cTime,1,13) )
		cTime := cTAtual
		DbSelectArea(PTALIAS)
		DbGoTop()
		aTimes := {}
		While !Eof() .and. !KillAPP()
		  AADD(aTimes,{HH_TIME,Recno()})
		  dbSkip()
		End
		aSORT(aTimes,,,{|x,y| x[1]<y[1]})
		For nT := 1 TO Len(aTimes)
			(PTALIAS)->(dbGoto(aTimes[nT,2]))
			DbSelectArea(PUALIAS)
			DbSetOrder(1)
			If ( DbSeek((PTALIAS)->HH_SERIE) )
				If cTime >= (PTALIAS)->HH_TIME
					HGU->(dbSetOrder(1))
					If HGU->(dbSeek((PTALIAS)->HH_GRUPO+(PTALIAS)->HH_SERIE))
						If (Empty((PUALIAS)->HHU_LOCK)) // Se usuario livre
							lEnd := .F.
						ElseIf (PUALIAS)->HHU_LOCK <> "H" .And. (PUALIAS)->HHU_LOCK <> "E"  // Se usuario diferente de livre, conectado (H) ou parcial (E)
							If GetSrvProfString("HHLAuto","0") == "1" // Controle automatico de liberacao de usuario
								Sleep(600000) // Aguarda 10 minutos para liberar
								If !(Empty((PUALIAS)->HHU_LOCK))
									ConOut(STR0060 + Alltrim((PUALIAS)->HHU_NOMUSR) + " - " + Dtoc(Date()) + " - " + Time()) // "PALMJOB: Efetuando liberação automatica do usuario "
									(PUALIAS)->(MsRLock())
									(PUALIAS)->HHU_LOCK := ""
									(PUALIAS)->(MSRUnlock())
								EndIf
								lEnd := .F.
							EndIf
						EndIf
						If !lEnd
							If !(PUALIAS)->(MsRLock())
								Sleep(2000)
								Loop
							EndIf
							/*
							If (PUALIAS)->HHU_LOCK == "J"
								(PUALIAS)->(MSRUnlock())
								Sleep(60000)
								If !MsRLock() 
									Loop
								Endif
							Endif
							*/
							lEnd := .F.
							While !KillAPP() .And. !lEnd
								For ni:= 1 to nWork
									nHdl := MSFCREATE("\SEMAFORO\" + cFileLock + "WK" + StrZero(ni,3,0) + ".LCK")
									
									If nHdl >= 0
										(PUALIAS)->HHU_LOCK := "J"		// Utiliza Lock Fisico, pq o Lock do registro 
										(PUALIAS)->(MSRUnlock())		// se perde qdo o HTTP:JOB cai por TimeOut
										ConOut("PALMJOB: "+Trim(HHU_NOMUSR)+" - "+Subs(cTime,9))
										FClose(nHdl)
										// Inicia Thread Com o Job
										// Parametros: Grupo, Numero de Serie, Thread
										StartJob("HHExecServ",GetEnvServer(),.F.,HGU->HGU_GRUPO, (PUALIAS)->HHU_SERIE, ni, .F.)
										Sleep(__nInterval)
										nERR := 0                                       
										lEnd := .T.
										Exit
									Endif                                
        				 		Next
        				 		If !lEnd
	        				 		Sleep(20000)   //Todas as WORKs estao ocupadas, tentar mais tarde
								EndIf
							End
						EndIf
					Endif
				EndIf
			EndIf
		Next nT
	EndIf
	nC := 0
	While !KillApp() .and. nC < 60
	   Sleep(1000)
	   nC++
	End
End

//(PLALIAS)->(MsUnlockAll())
DbCommitAll()
DbCloseAll()

HHInJob(.F.)
Return .T.
       
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PGetServ  ³Autor  ³                    ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna servicos Cadastrados                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PGetServ()
/*
*************************************************
* aServ  										*
* [1] -> Codigo do Servico 						*
* [2] -> Descricao do Servico					*
* [3] -> Funcao que cria o servico				*
* [4] -> Funcao que retorna alias usados		*
* [5] -> funcao que retorna o nome fisico das	*
*	     tabelas								*
* [6] -> funcao que retorna indices usados		*
* [7] -> Tipo - 1)AP6-Handheld; 2)Handheld-AP6	*
* [8] -> Execucao - 1)Individual; 2)Generico	*
* [9] -> utiliza codigo da empresa no nome do arquivo	*
*************************************************
*/
Local nRecno  := HHR->(Recno())
Local cTable  := ""
Local lTblGen := .F.

dbSelectArea("HHR")
dbSetOrder(1)
dbGoTop()
While HHR->(!Eof())
	dbSelectArea("HST")
	dbSetOrder(1)
	If dbSeek(HHR->HHR_COD)
		While !HST->(Eof()) .And. HHR->HHR_COD = HST->HST_CODSRV
			dbSelectArea("HHT")
			dbSetOrder(1)
			If dbSeek(HST->HST_CODTBL)
				cTable += AllTrim(HHT->HHT_ALIAS) + ","
				If HHT->HHT_GEN = "1" // Existe Tabela Generica neste Servico
					lTblGen := .T.
				EndIf
			EndIf
			HST->(dbSkip())
		End	
	EndIf

	cTable := Subs(cTable,1, Len(cTable)-1)
	// 					 1			2					3				4			5			6				7         8
	aAdd(aServ, {HHR->HHR_COD, HHR->HHR_DESCR, HHR->HHR_FUNCAO, HHR->HHR_ALIAS, cTable, HHR->HHR_TIPO, HHR->HHR_EXEC, lTblGen})
	cTable  := ""
	lTblGen := Nil
	HHR->(dbSkip())
EndDo
GoTo(nRecno)
Return aServ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PGetServGrp³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna servicos do grupo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PGetServGrp(cGrupo, aServGrp)
Local nRecno := HGS->(Recno())

dbSelectArea("HGS")
dbSetOrder(1)
dbSeek(cGrupo)
While cGrupo == HGS->HGS_GRUPO
	aAdd(aServGrp, {HGS->HGS_SRV, HGS->HGS_FREQ, HGS->HGS_TFREQ})
	dbSkip()
EndDo
GoTo(nRecno)

Return aServGrp

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PGetHHGrp  ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna handhelds do grupo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PGetHHGrp(cGrupo, aHHGrp)
Local nRecno := HGU->(Recno())

dbSelectArea("HGU")
dbSetOrder(1)
dbSeek(cGrupo)
While cGrupo == HGU->HGU_GRUPO
	aAdd(aHHGrp, HGU->HGU_SERIE)
	dbSkip()
EndDo
GoTo(nRecno)

Return aHHGrp

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PSec2Text  ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Converte segundos em hora                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHSec2Text(nTime,nStr)
Local nHour
Local nMinute
Local nSecond
Local cTime
Local nTemp

DEFAULT nTime := 0
DEFAULT nStr := 2

nTemp := Int(nTime/60)

nHour := Int(nTemp/60)

nMinute := nTemp - (nHour*60)

nSecond := nTime - ((nHour*3600)+(nMinute*60))

cTime := StrZero(nHour,nStr,0)+":"+StrZero(nMinute,2,0)+":"+StrZero(nSecond,2,0)

Return cTime

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHText2Sec ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Converte horas em segundos                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHText2Sec(cTime)
Local nHour
Local nMinute
Local nSecond
Local nTime

DEFAULT cTime := "00:00:00"

nHour := Val(Subs(cTime,1,2))

nMinute := Val(Subs(cTime,4,2))

nSecond := Val(Subs(cTime,7,2))

nTime := (nHour*3600)+(nMinute*60)+nSecond

Return nTime

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHRetRange ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna frequencia de execucao do JOB                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHRetRange(nFreq,cFTipo)

If ( cFTipo == "1" )
	cRet := HHSec2Text(nFreq*60)
ElseIf ( cFTipo == "2" )
	cRet := HHSec2Text(nFreq*3600)
ElseIf ( cFTipo == "3" )
	cRet := HHSec2Text(nFreq*86400)
EndIf
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHSumTime  ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Calcula horario da proxima execucao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHSumTime(cTime,cRange)
Local nOnlyDay
Local nTimesDay := 0
DEFAULT  nOnlyDay := Val(GetSrvProfString("HandHeldDay","1"))

If Select("SX6") = 0
	// Abre SX6 da Empresa relacionada ao grupo, o Ambiente nao esta montado
	dbUseArea(.T.,, "SX6" + Subs((PGALIAS)->HHG_EMPFIL,1,2) + "0", "SX6")
	DbSetIndex("SX6" + Subs((PGALIAS)->HHG_EMPFIL,1,2) + "0")
	If dbSeek(Space(2)+"MV_HHNTIME")
		nTimesDay := Val(SX6->X6_CONTEUD)
	Else
		nTimesDay := 1
	EndIf
	SX6->(dbCloseArea())
Else
	nTimesDay := GetMv("MV_HHNTIME",,1)
EndIf


//                1
//		 1234567890123456
//cTime: aaaammddhh:mm:ss                   	
//cRange: hh:mm:ss

dDate := Stod(Subs(cTime,1,8))

If nOnlyDay = 1 // Soma o intervalo 
	nHour := Val(Subs(cTime,9,2))+Val(Subs(cRange,1,2))
	nMinute := Val(Subs(cTime,12,2))+Val(Subs(cRange,4,2))
	nSecond := Val(Subs(cTime,15,2))+Val(Subs(cRange,7,2))
ElseIf nOnlyDay = 2  // ALtera apenas o dia
	nHour := Val(Subs((PTALIAS)->HH_TIME,9,2))
	nMinute := Val(Subs((PTALIAS)->HH_TIME,12,2))
	nSecond := Val(Subs((PTALIAS)->HH_TIME,15,2))
ElseIf nOnlyDay = 3 // Gera n Vezes ao dia
	ConOut(nTimesDay)
	nInter := 24 / nTimesDay
	nHour := Val(Subs((PTALIAS)->HH_TIME,9,2))+nInter
	nMinute := Val(Subs((PTALIAS)->HH_TIME,12,2))
	nSecond := Val(Subs((PTALIAS)->HH_TIME,15,2))
EndIf

nTemp   := Int(nSecond/60)
nMinute += nTemp
nSecond -= nTemp*60
nTemp   := Int(nMinute/60)
nHour   += nTemp
nMinute -= nTemp*60

//verifica se hora passou das 24 para reiniciar
If nOnlyDay = 1 .Or. nOnlyDay = 3
	If ( nHour >= 24 )
		nHour := (Int(nHour/24)-1) + (nHour - 24)
		dDate += 1
	EndIf
ElseIf nOnlyDay = 2
	dDate += 1
EndIf
cRet := Dtos(dDate)+StrZero(nHour,2,0)+":"+StrZero(nMinute,2,0)+":"+StrZero(nSecond,2,0)
Return cRet  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHExecserv ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Executa thread de usuario                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHExecServ(cGrupo, cSerie, ni, lMonitor, lUpdHHTime)
Local i
Local nServ
Local aAlias
Local cEnv			:= GetEnvServer()
Local cHandHeldDir	:= GetHHDir()
Local cFileLock		:= Subs(cHandHeldDir,2,Len(cHandHeldDir)-2)
Local nHdl			:= MSFCREATE("\SEMAFORO\" + cFileLock + "WK" + StrZero(ni,3,0)+".LCK") //MSFCREATE("\SEMAFORO\"+StrZero(ni,3,0)+".LCK")
Local nHdlCon		:= -1
Local cFileMCS		:= "MCSLOCK.LCK"
Local cTime 
Local lRecreate		:= .T.
Local lRPCOpened	:= .F.
Local lLockHHU		:= .F.
Local lExecuta 		:= .T.
Local lServGen		:= .T.
Local lAtuSrvGen	:= .F.
Local cDtSrGen		:= ""
Local cEmp			:= ""
Local cFil			:= ""
Local cMsg			:= ""
Local nLogRecno		:= 0
Local nTimes		:= 1
Local nCalcTime    	:= 0

Set Deleted On
Set Date British

PTInternal(1,STR0005 + cSerie + STR0006) //### //### //### //### //"Job do dispositivo "###" iniciado"
ErrorBlock({|e| HHErr(e, cGrupo, cSerie)})

If nHdl < 0
	cMsg := "PALMJOB: " + cSerie + Space(20 - Len(cSerie))
	cMsg += STR0007 + Str(FError(),3,0)  // // // // //" - Erro do Semaforo (HHEXECSERV) = "
	cMsg += " - " + Time() + Chr(13) + Chr(10)
	GravaHHLog(cMsg)
	dbCloseAll()
	UserException(STR0008) // // // // //"Erro de Criacao de Semaforo"
Endif

DEFAULT cSerie	    := ""
DEFAULT lMonitor   := .F.
DEFAULT lUpdHHTime := .T.

// EXECUCAO EM THREAD
// ABRIR AS TABELAS AGORA PORQUE CADA SERVICO ESTA EM UMA THREAD
Private PSYSALIAS := POpenSys() 
Private PUALIAS   := POpenHH()
Private PSALIAS   := POpenSrv()
Private PTALIAS   := HHOpenTime()
Private PTBLALIAS := POpenTbl()
//Private PLALIAS := POpenLog()
Private PGALIAS   := POpenGrp()
Private PTRGALIAS := HHOpenTrg()   // Arquivo de Gatilhos
Private cJobAlias := PUALIAS+"#"+PSALIAS+"#"+PTALIAS+"#HGS#HGU#HHG" //+"#"+PLALIAS
Private aServ := {}

cSerie := Trim(cSerie)

// Servicos Cadastrados
aServ := PGetServ()

//retorna diretorio de trabalho do usuario
DbSelectArea(PUALIAS)
DbSetOrder(1)
DbSeek(cSerie)

// Posiciona Grupo
If (PGALIAS)->(dbseek(cGrupo))
	cEmp := Subs((PGALIAS)->HHG_EMPFIL,1,2)
	cFil := Subs((PGALIAS)->HHG_EMPFIL,3,2)
	HHRstMobExp() // Reseta o controle de execucao de servicos genericos
Else
	ConOut(STR0009) // // // // //"PALMJOB: Grupo não encontrado."
EndIf

// Posiciona usuario do Grupo
HGU->(dbseek(cGrupo+cSerie))

// Monta diretorio do Usuario
__cUserDir := HHGetDir()+"P"+Trim(HGU->HGU_DIR)+"\"

// Verifica se usuario esta locado
If (PUALIAS)->HHU_LOCK != "J"
   dbCloseAll()
   UserException(STR0010) // // // // //"Erro na Flag HHU_LOCK"
Endif

// Atualiza HHTIME conforme parametro
If lUpdHHTime = .T.
		ConOut("PALMJOB: Atualizando HHTIME")
		DbSelectArea(PTALIAS)
		dbSetOrder(1)
		If dbSeek(cGrupo+cSerie)
			(PTALIAS)->(MSRLOCK())
			If Empty((PTALIAS)->HH_TIME)
				cTime := DtoS(Date())+Time()
			Else
				cTime := (PTALIAS)->HH_TIME
			EndIf
		
			(PTALIAS)->HH_TIME := HHSumTime(cTime, (PTALIAS)->HH_RANGE)
			(PTALIAS)->(MsrUnlock())
		EndIf                                           
Else
			ConOut("PALMJOB: HHTIME - NAO ATUALIZADA")
EndIf

cMsg := STR0011 + Trim(cGrupo) + STR0052 + Trim(HHU->HHU_NOMUSR) //### //### //### //###" - Handheld: " //"PALMJOB: Executando serviços para Grupo: "
cMsg += " - " + DtoC(Date()) + " - " 
cMsg += Time() + Chr(13) + Chr(10)
nCalcTime := PText2Sec(Time())
GravaHHLog(cMsg)
ConOut(cMsg)
HHSaveLog(cGrupo, cSerie, 2070, .T.,)

DbSelectArea("HGS")
DbSetOrder(3)
DbSeek(cGrupo)
While !HGS->(Eof()) .And. AllTrim(HGS->HGS_GRUPO) == AllTrim(cGrupo)
	HHSetError(.F.)
	lExecuta := .T.

	//	PAddLog(cSerie,(PSALIAS)->P_ID)
	//verifica se servico existe
	cServ := Trim(HGS->HGS_SRV)
	nServ := HHExistServ(cServ)

	// Posiciona Servico
	(PSALIAS)->(dbSetorder(1))
	(PSALIAS)->(dbseek(cServ))

	If ExistBlock("HHExeSrv")		
		lExecuta := ExecBlock("HHExeSrv",.F.,.F.)
	EndIf

	If (nServ <> 0 .And. lExecuta)

		//retorna alias e nome fisico usado pelo servico
		aAlias := HHExeTable(nServ)
		aPalm  := HHExeArq(nServ)

		If ( !HHSetError() )
			//Verifica se Empresa foi utilizada no servico anterior
			__RPCCALLED := .F.
			If __cLastEmp != cEmp .Or. __cLastFil != cFil
				If __cLastEmp != "@@" .Or. __cLastFil != "@@"
					For i := 1 to 512
						DbSelectArea(i)  
						If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
							DbCloseArea()
						Endif
					Next
			    	RpcClearEnv(.f.)
				EndIf
				// Cria ambiente
				lRPCOpened := .T.
				PTInternal(1,STR0012 + cSerie) // // // // //"Criando ambiente para "
				RpcSetType ( 3 )
				RpcSetEnv(cEmp,cFil,,,cEnv,,aAlias)
				__cLastEmp := cEmp
				__cLastFil := cFil
				If lRecreate
					HHRecreateUser(cGrupo, cSerie, .F.)
					lRecreate := .F.
				EndIf
			Else
		    	For ni:= 1 to Len(aAlias)
					If Select(aAlias[ni]) == 0
						ChkFile(aAlias[ni]) 
					Endif
				Next
				cFilAnt := cFil
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³- Verifica se esta sendo utilizado o servico generico separado dos demais (execucao 1 vez por dia) ³
			//³- Verifica se rotina foi executada pelo monitor, ou se alias esta no MV_HHGENEX, nesses casos deve ³
			//³  processar o servico generico independente do MV_HHSRGEN                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lMonitor .And. !Empty(cDtSrGen := GetMv("MV_HHSRGEN",,"")) .And. !(aServ[nServ,4] $ GetMv("MV_HHGENEX",,""))
				//Verifica se servico generico ja foi executado na data atual
				If cDtSrGen == DTOS(Date())
					lServGen 	:= .F.
				Else
					lServGen 	:= .T.
					lAtuSrvGen	:= .T.
					PutGlbVars("HHJOBPVAR",nil)
				EndIf
			EndIf
			
			// Verifica se o Servico com Tabela Generica pode ser executado
			If aServ[nServ, 8]
				If lServGen
					/// Cria o Semaforo
					nHdlCon := MSFCREATE("\SEMAFORO\" + cFileMCS)
					If nHdlCon >= 0	
						nTimes := 1
						While !CheckGen() .And. nTimes <= 10
							ConOut(STR0013 + Str(nTimes,2,0) + ").") // // // // //"PALMJOB:  Aguardando liberacao para executar servico generico("
							nTimes++
							Sleep(6000)
						EndDo
					EndIf
					// Caso o semaforo esteja sendo utilizado, existe um controle no servico para nao executar simultaneamente
				Else
					lExecuta := .F.
				EndIf
			EndIf
			
			//Executa Servico
			If lExecuta
				ConOut("PALMJOB: " + Space(1) + Trim(aServ[nServ,1]) + "-" + Trim(aServ[nServ,2]) + " - (" + ;
							Trim(HHU->HHU_NOMUSR) + ") - " + Time())
	
				PTInternal(1,STR0014 + Trim(aServ[nServ,1]) + "-" + Trim(aServ[nServ,2]) + " - " + cSerie) // // // // //"Executando "
	
				// Executa o Serviço
				HHExeServ(nServ)
		    		
				If !HHSetError()
					ConOut("PALMJOB: " + Space(1) + Trim(aServ[nServ,1]) + "-" + Trim(aServ[nServ,2]) +;
							 STR0015 + Trim(HHU->HHU_NOMUSR) + ") - " + Time()) // // // // //" executado com sucesso - ("
				Else
					ConOut("PALMJOB: " + Space(1) + Trim(aServ[nServ,1]) + "-" + Trim(aServ[nServ,2]) +;
							 STR0016 + Trim(HHU->HHU_NOMUSR) + ") - " + Time()) // // // // //" executado com erro - ("
				EndIf
	
				If aServ[nServ,6] == "2"
					If __HHLog >= 1
						GravaHHLog(Replicate("-", 50) + Chr(13) + Chr(10))
					EndIf
	  				//HHGenericUpd(HGU->HGU_CODBAS,, .T., nServ)
					PUpdHHCtr(HGU->HGU_CODBAS, AllTrim(aServ[nServ,5]), 0, .T.)
				EndIf
				HHAdvTbl( aPalm )
				//HHUpdTriggerOn((PGALIAS)->HHG_EMPFIL, aAlias)
				HHUpdTriggerOn(cEmp+cFil, aAlias)
				
				If nHdlCon >= 0
					FClose(nHdlCon)
					FErase("\SEMAFORO\" + cFileMCS)
				EndIf
			EndIf
		EndIf
	EndIf
	HGS->(DbSkip())
EndDo

If lAtuSrvGen
	ConOut(STR0061) // "PALMJOB: Controle de execução de servico generico diario habilitado"
	ConOut(STR0062 + Dtoc(Date()) + " - " + Time()) // "PALMJOB: Serviço generico executado - "
	dbSelectArea("SX6")
	GetMv("MV_HHSRGEN")
	Reclock("SX6",.F.)
	Replace X6_CONTEUDO With DTOS(Date())
	MsUnlock()
EndIf

cMsg := STR0017 + Trim(cGrupo) + STR0052 + Trim(HHU->HHU_NOMUSR) //### //### //### //###" - Handheld: " //"PALMJOB: Serviços executados com sucesso para "
cMsg += " - " + DtoC(Date()) + " - "    
cMsg += Time() + STR0018 + PSec2Text(PText2Sec(Time()) - nCalcTime) + Chr(13) + Chr(10) // // // // //" - Tempo Utilizado = "
GravaHHLog(cMsg)
ConOut(cMsg)
HHSaveLog(cGrupo, cSerie, 2070, .F.,)

// Gera o Script
HHScript(cGrupo, cSerie)

// Fecha todas as tabelas
For i := 1 to 512
	DbSelectArea(i)
	If !Empty(Alias()) .And. !(Alias()$cJobAlias)
		DbCloseArea()
	Endif
Next
/*
DbSelectArea(PTALIAS)
dbSetOrder(1)
If dbSeek(cGrupo+cSerie)
	(PTALIAS)->(MSRLOCK())
	If Empty((PTALIAS)->HH_TIME)
		cTime := DtoS(Date())+Time()
	Else
		cTime := (PTALIAS)->HH_TIME
	EndIf

	(PTALIAS)->HH_TIME := HHSumTime(cTime, (PTALIAS)->HH_RANGE)
	(PTALIAS)->(MsrUnlock())
EndIf
*/
lLockHHU := (PUALIAS)->(MSRLock())
nTimes := 1
While !lLockHHU .And. nTimes <= 3
	Sleep(500)
	lLockHHU := (PUALIAS)->(MSRLock())
	nTimes++	
EndDo

If lLockHHU
	(PUALIAS)->HHU_LOCK := Space(1)	   // Utiliza Lock Fisico, pq o Lock do registro 
	(PUALIAS)->(MsRUnlock()) 	      	//	se perde qdo o HTTP:JOB cai por TimeOut
Else
	ConOut(STR0019 + Trim(cGrupo) + STR0052 + Trim(HHU->HHU_NOMUSR)) //### //### //### //###" - Handheld: " //"PALMJOB: Falha na liberacao do usuario "
EndIf

DbCommitAll()

FClose(nHdl)
__cUserDir := NIL
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CheckGen   ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna se existe algum usuario conectado                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CheckGen()
Local nUser := 0
Local lLock := .F.
Local nRecAtu := (PUALIAS)->(Recno())
dbSelectArea(PUALIAS)
Count To nUser For (PUALIAS)->(!Deleted()) .And. (PUALIAS)->(HHU_LOCK = "H") // Indica que o usuario esta conectado
GoTo(nRecAtu)
If nUser = 0  // Sem usuários conectados
	lLock := .T.
EndIf
Return lLock

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CheckUsr   ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna se usuario esta conectado                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CheckUsr(cId,cCodEmp,cCodFil,cSerie)

Local cGrupo  := ""
Local aArea   := {}
Local aAreaHHU:= {}
Local aAreaHGU:= {}
Local aAreaHHG:= {}
Local lCon    := .F.

POpenGrp()
POpenHH()
aArea    := GetArea()
aAreaHHU := HHU->(GetArea())
aAreaHGU := HGU->(GetArea())
aAreaHHG := HHG->(GetArea())

dbSelectArea("HGU")
dbSetOrder(3)
If dbSeek(cId)
	While !Eof() .And. HGU->HGU_CODBAS == cID
	
		cGrupo := HGU->HGU_GRUPO		
		dbSelectArea("HHG")
		dbSetOrder(1)
		MsSeek(cGrupo)
		
		If HHG->HHG_EMPFIL == cCodEmp+cCodFil
			
			cSerie  := HGU->HGU_SERIE		
			dbSelectArea("HHU")
			dbSetOrder(1)
			If dbSeek(cSerie)
				If HHU->HHU_LOCK = "H"
					lCon := .T. // Usuario Conectado
				EndIf
			EndIf

		EndIf
		dbSelectArea("HGU")
		dbSkip()
	EndDo
EndIf
RestArea(aAreaHHU)
RestArea(aAreaHGU)
RestArea(aAreaHHG)
RestArea(aArea)
Return lCon


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHDir      ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna caminho do usuario                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHDir(cSerie)
Local cRet  := ""
Local nRet  := 0
Local nRecno:= 0
If cSerie == NIL
	cRet := __cUserDir
Else
	POpenGrp()
	DbSelectArea("HGU")
	DbSetOrder(2)
	If DbSeek(cSerie)
		nRecno := HGU->(Recno())
		While !HGU->(Eof()) .And. HGU->HGU_SERIE = cSerie
			HHG->(dbSeek(HGU->HGU_GRUPO))
			cRet += Subs(HHG->HHG_EMPFIL,1,2) + "|" + AllTrim(HGU->HGU_CODBAS) + "|" 
			HGU->(dbSkip())
			nRet++
		EndDo
		GoTo(nRecno)
	Else
		cRet := "-1"
	EndIf
EndIf
cRet := Str(nRet, 3, 0) + "|" + cRet
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHLock     ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Altera Status do Usuario                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHLock(cSerie,cCodLock)
Local cRet := "-1",i                              

DEFAULT cCodLock := "H"
If __cAlias == Nil
	__cAlias := POpenHH()
Endif
If (__cAlias)->(dbSeek(cSerie))
	__nRecLock := (__cAlias)->(Recno())
	If Empty((__cAlias)->HHU_LOCK) .Or. (__cAlias)->HHU_LOCK == "H" .Or. (__cAlias)->HHU_LOCK == "E"
		For i := 1 to 10
	    	If (__cAlias)->(MsRLock())
	       		If (__cAlias)->HHU_LOCK != "J" .And. (__cAlias)->HHU_LOCK != "P"  // Inclusao do Flag de Process
					(__cAlias)->HHU_LOCK := cCodLock
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
Else
	cRet := "-1"
Endif
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHUnlock   ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Altera Status do Usuario                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHUnlock(cSerie)
Local cRet := "-1",i
If __cAlias == Nil
	__cAlias := POpenHH()
Endif
If cSerie != Nil
	If (__cAlias)->(dbSeek(cSerie))	
	    for i := 1 to 10
			if (__cAlias)->(MsRLock())
				(__cAlias)->HHU_LOCK := Space(1)  // Utiliza Lock Fisico, pq o Lock do registro e perido no fim da Thread
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
				(__cAlias)->HHU_LOCK := Space(1)  // Utiliza Lock Fisico, pq o Lock do registro 
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


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHSaveLog  ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Registra log com operacao efetuada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHSaveLog(cGrupo, cSerie, nOper, lOper, cObs)
/*
### Operacoes
0001 - HHOPEN
0002 - HHCLOSE
0003 - Erro na Autenticacao do Usuario
0004 - Execucao de Servico Generico
1010 - Sucesso na Importação do Pedido
1011 - Erro na Importação do Pedido
1012 - Aviso na Importacao do pedido
1020 - Sucesso na Importação de Cliente (Inclusao)
1021 - Sucesso na Importação de Cliente (Alteracao)
1022 - Erro na Importação de Cliente
1030 - Sucesso na Importação de Contatos (Inclusao)
1031 - Sucesso na Importação de Contatos (Alteracao)
1032 - Erro na Importação de Contatos
1040 - Sucesso na Importação de Mensagem
1041 - Erro na Importação de Mensagem
1050 - Sucesso na Importação de Ocorrencias
1051 - Erro na Importação de Ocorrencia
2010 - Manutencao de Sistemas
2020 - Manutencao de Servicos
2030 - Manutencao de Usuarios
2040 - Manutencao de Tabelas
2050 - Manutencao de Grupos
2060 - Apaga base de usuario
2070 - Criacao da base do usuario
2080 - Alteração de Status do Usuario
2090 - Iniciado importações manualmente
0500 - RPC
*/
Local nSeq := 1
Local __cAliasLog := HHOpenLog()
Local lFound := .F.

If Empty(cGrupo)
	cGrupo := Space(6)
EndIf
// Verifica sequencia
dbSelectArea(__cAliasLog)
dbSetOrder(1)
// Verifica sequencia do Grupo
If dbSeek(cGrupo+cSerie)
	While !(__cAliasLog)->(Eof()) .And. (__cAliasLog)->HHL_GRUPO = cGrupo .And. (__cAliasLog)->HHL_SERIE = cSerie
		nSeq := Val((__cAliasLog)->HHL_SEQ)
		(__cAliasLog)->(dbSkip())
	EndDo
Else
	// Verifica sequencia do Numero de Serie
	dbSetOrder(2)
	dbSeek(cSerie)
	While !(__cAliasLog)->(Eof()) .And. (__cAliasLog)->HHL_SERIE = cSerie
		nSeq := Val((__cAliasLog)->HHL_SEQ)
		(__cAliasLog)->(dbSkip())
	EndDo
EndIf

If !lOper
	lFound := (__cAliasLog)->(dbSeek(cGrupo+cSerie+Space(20-Len(cSerie))+StrZero(nSeq, 4)))
EndIf

If lOper
	dbAppend()
Else
	If lFound
		MSRlock(Recno())
	Else
		Return Nil		
	EndIf
EndIf

(__cAliasLog)->HHL_GRUPO := cGrupo
(__cAliasLog)->HHL_SERIE := cSerie
(__cAliasLog)->HHL_SEQ := If(lOper, StrZero(nSeq+1, 4), StrZero(nSeq, 4))
(__cAliasLog)->HHL_DATA := Date() 
If lOper
	(__cAliasLog)->HHL_HORA1 := Time() 
	(__cAliasLog)->HHL_OPER1 := StrZero(nOper, 4)
Else
	(__cAliasLog)->HHL_HORA2 := Time() 
	(__cAliasLog)->HHL_OPER2 := StrZero(nOper, 4)
EndIf
(__cAliasLog)->HHL_OBS := cObs
(__cAliasLog)->(MSRUnlock())

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³InitJob    ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Inicia os JOBS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Main Function InitJob()
StartJob("HHCtrJob",GetEnvServer(),.F.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHOpen   ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
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
Function HHOpen(cSerie)
Local cRet        := "-1"
Local cRetHHOpen  := "-1"
Local cRetPICheck := "-1"
Local nReg        := 0
Local cGrupo 		:= ""
Local nPos 			:= 0
Local cParam 		:= cSerie
Local cScript 		:= ""
Local cFileMCS 	:= "MCSLOCK.LCK"
Local cMsg			:= ""
Set Deleted On

nPos := At("|", cParam)
If nPos != 0
	cSerie := Subs(cParam, 1, nPos-1)
	cGrupo := AllTrim(Subs(cParam, nPos+1))
EndIf

// Verifica se a conexao está bloqueada
If File("\SEMAFORO\" + cFileMCS)
	HHSaveLog(cGrupo, cSerie, 4, .T., STR0020)	 // // // // //"Executando Servico generico, conexao bloqueada."
	ConOut(STR0021) // // // // //"PALMJOB: Executando Servico generico, conexao bloqueada."
	cRet  := "-4"
	Return cRet
EndIf

If Select("HHG") = 0
	POpenGrp()
EndIf

dbSelectArea("HHG")
dbSetOrder(1)
If !dbSeek(cGrupo)
	HHSaveLog(cGrupo, cSerie, 3, .T., STR0022 + cGrupo + STR0023) //### //### //### //### //"Grupo "###" inválido."
	Return cRet
EndIf

If Select("HHU") = 0
	POpenHH()
EndIf

dbSelectArea("HHU")
dbSetOrder(1)
If !dbSeek(cSerie)
	HHSaveLog(cGrupo, cSerie, 3, .T., STR0024 + cSerie + STR0023) //### //### //### //### //"Numero de serie "###" inválido."
	Return cRet
EndIf

dbSelectArea("HGU")
dbSetOrder(1)
If dbSeek(cGrupo + Space(6- Len(cGrupo)) + cSerie )
	cScript := HGU->HGU_SCRIPT
EndIf
//Grava Log
HHSaveLog(cGrupo, cSerie, 1, .T.)

PTInternal(1,STR0025 + cSerie) // // // // //"Iniciando HHOPEN "

// Checa a quantidade Usuarios cadastrados
__cAlias := POpenHH()
dbSelectarea( __cAlias )
If (__cAlias)->(dbSeek(cSerie))
	Count To nReg For (__cAlias)->(!Deleted() )
	cRetPICheck := Str(nReg,10,0)
Else
    cRetPICheck := "-3"
EndIf

// Checa o Lock do Usuario e Retorna ID do Diretorio
cRetHHOpen := HHLock(cSerie)
If cRetHHOpen = "0"
    PTInternal(1,STR0026+cSerie+" OK") // // // // //"Autenticacao do handheld "
	cRetHHOpen  := HHDir(cSerie)
Else
    PTInternal(1,STR0026+cSerie+STR0027) //### //### //### //### //"Autenticacao do handheld "###" Recusada"
EndIf
cRet := cRetHHOpen + cRetPICheck + "|" + cScript
//ConOut(cRet)
PTInternal(1,STR0028+cSerie) // // // // //"Finalizando HHOPEN "
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHClose  ³ Autor ³ Fabio Garbin          ³ Data ³ 12/02/01 ³±±
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
Function HHClose(cParam)
Local cRet			 := ""
Local __cGrp       := ""
Local __cServAlias := ""
Local __cServUser  := ""
Local nPos 			 := 0
Local lErr 			 := .F.
Local cSerie 		 := ""
Local cGrupo 		 := ""
Local cMsg   		 := ""
Local cNome  		 := ""
Local lUserExist   := .F.

Set Deleted On

DEFAULT __nInterval := VAL(GetSrvProfString("HHThreadTimer","3000"))

nPos := At("|", cParam)
If nPos != 0
	// Serial do Usuario
	cSerie := Subs(cParam, 1, nPos-1)
	cParam := Subs(cParam, nPos+1, Len(cParam))
	
	// Grupo do Usuario
	nPos := At("|", cParam)
	If nPos != 0
		cGrupo := Subs(cParam, 1, nPos-1)
	EndIf

	// Status da Conexao
	lErr   := If("ENDOK" $ cParam, .F., .T. )
EndIf

__cGrp        := POpenGrp()
__cServAlias  := POpenSrv()
__cServUser   := POpenHH()

// Posiciona usuario
If (__cServUser)->(dbSeek(cSerie))
	lUserExist := (__cServUser)->(Found())
	cNome 	  := "|" + AllTrim((__cServUser)->HHU_NOMUSR)
	HGU->(dbSetOrder(1))
	If HGU->(dbSeek(cGrupo+cSerie))
		cNome   += "-" + HGU->HGU_CODBAS
	EndIf
EndIf

// Erro na Conexao
If lErr = .T.
	If lUserExist .And. ((__cServUser)->HHU_LOCK = "H" .Or. (__cServUser)->HHU_LOCK = "E")
		// Cria Semaforo da Thread 
		If (__cServUser)->(MsRLock())
			(__cServUser)->HHU_LOCK := "E"
			(__cServUser)->(MSRUnlock() )
		EndIf
		cMsg := STR0029 // // // // //"  Sincronismo não finalizado corretamente para "
	ElseIf (__cServUser)->HHU_LOCK = "B"
		cMsg := STR0030 // // // // //"  Usuario Bloqueado "
	ElseIf (__cServUser)->HHU_LOCK = "J"
		cMsg := STR0031 // // // // //"  Atualizacao de dados em andamento para "
	EndIf
	ConOut("PALMJOB:" + cMsg + cSerie + " - " + Time()) 
	HHSaveLog(cGrupo, cSerie, 2, .F., cMsg)
	cRet := "-1" + cNome
	Return cRet
Endif

// Conexao finalizada
// Verifica conexcao bloqueada: 
// - Existencia do Handheld no Cadastro (HCADHH)
// - Lock fisico de conexao (HHU_LOCK)
If lUserExist .And. ((__cServUser)->HHU_LOCK = "H" .Or. (__cServUser)->HHU_LOCK = "E")
	// Cria Semaforo da Thread 
	nHdl := MSFCREATE("\SEMAFORO\"+ cSerie +".LCK")
	If (__cServUser)->(MsRLock())
		(__cServUser)->HHU_LOCK := "P"
		(__cServUser)->(MSRUnlock() )
	EndIf
	If nHdl >= 0
		FClose(nHdl)
		StartJob("HHUpdData", GetEnvServer(), .F., cGrupo, cSerie)
		Sleep(__nInterval)
		cRet := "0"
	Else
		cRet := "-2"
	EndIf
EndIf

//Grava Log
HHSaveLog(cGrupo, cSerie, 2, .F.)
cRet += cNome
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHUpdData  ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Inicia os JOBS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHUpdData(cGrupo, cSerie)
Local nHdl           := MSFCREATE("\SEMAFORO\"+ cSerie +".LCK")
Local cMsg 				:= ""
Private __cSysAlias  := ""
Private __cTblAlias  := "" 
Private __cServAlias := POpenSrv()
Private __cServUser  := POpenHH()
Private __cServGrp   := POpenGrp()
Private aServ        := {}

Set Deleted On

__cSysAlias := POpenSys()
__cTblAlias := POpenTbl()                            

aServ := PGetServ()

// Posiciona Grupo
(__cServGrp)->(dbSetOrder(1))
(__cServGrp)->(dbSeek(cGrupo))

// Posiciona Usuario
(__cServUser)->(dbSetOrder(1))
(__cServUser)->(dbSeek(cSerie))

// Posiciona Servicos x Grupo
(__cServAlias)->(dbSetOrder(1))
(__cServAlias)->(dbSeek(cGrupo))

// Posiciona Usuario x Grupo
dbSelectArea("HGU")
dbSetOrder(2)
dbSeek(cSerie)
While !HGU->(Eof()) .And.  AllTrim(cSerie) = AllTrim(HGU->HGU_SERIE)

	// Posiciona Grupo
	(__cServGrp)->(dbSetOrder(1))
	(__cServGrp)->(dbSeek(HGU->HGU_GRUPO))

	If nHdl < 0
		cMsg := "PALMJOB: " + cSerie + Space(20 - Len(cSerie))
		cMsg += STR0032 + Str(FError(),3,0)  // // // // //" - Erro do Semaforo (HHCLOSE) = "
		cMsg += " - " + Time() + Chr(13) + Chr(10)
		GravaHHLog(cMsg)
		dbCloseAll()
		UserException(STR0033+ cSerie +".LCK - (" + HGU->HGU_CODBAS + ")" ) // // // // //"Erro de Criacao de Semaforo \SEMAFORO\"
	Endif

	PTInternal(1,STR0034 + HGU->HGU_GRUPO + "/" + cSerie) // // // // //"Iniciando importações do dispositivo "
	HHImport(HGU->HGU_GRUPO, cSerie)
	HGU->(dbSkip())
EndDo
cRet := HHUnlock(cSerie)
DbCloseAll()
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHImport ³ Autor ³ Fabio Garbin          ³ Data ³ 15/10/01 ³±±
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
Function HHImport(cGrupo, cSerie)
Local aAlias       := {}
Local nServ        := 0
Local cEnv         := GetEnvServer()
Local __cLastEmp   := "@@"
Local aServ        := {}
Local cGrpEmp      := ""
Local cGrpFil      := ""
Local ni           := 1
Local i            := 1
Local cRet         := ""
Local lRPCOpened   := .F.
Local cJobAlias    := __cServAlias + "#" + __cServUser + "#PALMUSER#" + __cServGrp + "#HGU#" + "#HGS#HHR#HST#HHT"

dbSelectArea("HGS")
dbSetOrder(1)
If dbSeek(cGrupo)
	// Posiciona Grupo
	(__cServGrp)->(dbSetOrder(1))
	If (__cServGrp)->(dbSeek(cGrupo))
		cGrpEmp := Subs((__cServGrp)->HHG_EMPFIL,1,2)
		cGrpFil := Subs((__cServGrp)->HHG_EMPFIL,3,2)
	Else
		ConOut(STR0035 + cGrupo + STR0036 + Time())	 //### //"PALMJOB: Grupo "### //""PALMJOB: Grupo "### //"""PALMJOB: Grupo "### //""""PALMJOB: Grupo "###" - não encontrado.- "
		Return Nil
	EndIf
	
	PTInternal(1,STR0037 + cGrupo + "/" + cSerie + " - " + cGrpEmp + "/" + cGrpFil ) // // // // //"Importacao iniciada para o Dispositivo "
	ConOut(STR0038 + cSerie + " - " + cGrpEmp + "/" + cGrpFil + " - " + Time()) // // // // //"PALMJOB: Importacao iniciada para "

	aServ := PGetServ()

	(__cServUser)->(dbSetorder(1))
	(__cServUser)->(dbSeek(cSerie))

	// Posiciona Grupo
	HHG->(dbSetorder(1))
	HHG->(dbSeek(cGrupo))
	While !HGS->(Eof()) .And. AllTrim(HGS->HGS_GRUPO) == AllTrim(cGrupo)
		dbSelectArea(__cServAlias)
		dbSetOrder(1)
		If dbSeek(HGS->HGS_SRV)
			If (__cServAlias)->(HHR_TIPO) = "2"
 				HGS->(dbSkip())
 				Loop
	 		EndIf
	 	EndIf
		HHSetError(.F.)
	
  	nServ := Ascan(aServ,{|x| x[1] == HGS->HGS_SRV}) // Verifica se o Servico existe
		If ( nServ <> 0 )
			aAlias := HHExeTable(nServ)
			aPalm  := HHExeArq(nServ)
			aInd   := HHExeInd(nServ)

			//executar prepare env
			__RPCCALLED := .F.
			If __cLastEmp != Subs((__cServGrp)->HHG_EMPFIL,1,2) 
				If __cLastEmp != "@@"
					For ni := 1 to 512
						dbSelectArea(i)  
						If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
							DbCloseArea()
						Endif
					Next
			   RpcClearEnv(.F.)
				Endif
				lRPCOpened := .T.
				RpcSetType ( 3 )
				If Empty(cGrpEmp) .Or. Empty(cGrpFil)	
					ConOut(STR0039 + cGrupo + ". - " + Time()) // //"PALMJOB: Empresa e/ou Filial não definida para o grupo " //""PALMJOB: Empresa e/ou Filial não definida para o grupo " //"""PALMJOB: Empresa e/ou Filial não definida para o grupo " //""""PALMJOB: Empresa e/ou Filial não definida para o grupo "
					Return Nil
				EndIf
				RpcSetEnv(cGrpEmp,cGrpFil,,,cEnv,,aAlias)
				__cLastEmp := Subs((__cServGrp)->HHG_EMPFIL,1,2)
				__cUserId := (__cServUser)->HHU_CODUSR				
			Else
				For ni:= 1 to Len(aAlias)
					If Select(aAlias[ni]) == 0
						ChkFile(aAlias[ni])
					EndIf
				Next  
				cFilAnt :=  Subs((__cServGrp)->HHG_EMPFIL,3,2)
			Endif
  	
			ConOut("PALMJOB: " + Space(1) + Trim(aServ[nServ,1]) + "-" + Trim(aServ[nServ,2]) + " - (" + ;
					Trim(HHU->HHU_NOMUSR) + ") - " + Time())
  		
			HHExeServ(nServ)
		EndIf
		HGS->(dbSkip())
	EndDo
EndIf
If lRPCOpened
	For i := 1 to 512
		dbSelectArea(i)  
		If (!Empty(Alias()) .And. !(Alias()$cJobAlias))
			DbCloseArea()
		Endif
	Next
   	RpcClearEnv(.f.)
Else
    ConOut(STR0040 + cGrupo) // // // // //"Grupo nao encontrado: "
EndIf
ConOut(STR0041  + cSerie + " - " + cGrpEmp + "/" + cGrpFil ) // // // // //"PALMJOB: Importacao finalizada para "
Return

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
Main Function HHCtrJob( )
Local cHandHeldDir := GetSrvProfString("HHTrgDir","\HHTRG\")
Local cFileLock := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2) + ".LCK"
Local aJobs := {{"HHTrgJob",cFileLock,"I"}}
Local ni, lStart, nCount , nHdl
PTInternal(1,STR0042) // // // // //"Controle do Job para Handhelds..."
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
±±³Fun‡ao    ³ HHErr  ³ Autor ³ Fabio Garbin          ³ Data ³ 05/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de tratamento de Erros do PALMJOB                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HHTrgJob                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HHErr(e, cGrupo, cSerie)
Local __cServUser := POpenHH()
//Local __cGrp      := POpenGrp()
//Local __cServGrp  := POpenGrp()
Local cHDir      := GetSrvProfString("HHTrgDir","\HHTRG\")
Local cFile       := ""
Local cTo         := ""
Local cId			  := ""
Local nHandle     := 0
Local ni          := 2
Local cMail := ""
Local lClose := .F.
Local cSubject := ""

DEFAULT cSerie := ""

MakeDir(cHDir + "\LOGS\")
If !Empty(cSerie)
	If Select("HGU") = 0
		POpenGrp()
		dbSelectarea("HGU")
		dbSetOrder(1)
		dbSeek(cGrupo + cSerie)
	EndIf
	cId := HGU->HGU_CODBAS
	cSubject := STR0043 + cSerie + STR0044 + cId + STR0045 + DtoC(Date()) //###### //###### //###### //###### //"Erro no Usuário "###" - Vendedor: "###". Usuário Bloqueado em "
	cFile    := cHDir + "\LOGS\" + AllTrim(cSerie) + ".LOG"
Else
	cFile    := cHDir + "\LOGS\" + "ADMIN.LOG"
EndIf

nHandle  := If(!File(cFile),FCreate(cFile),FOpen(cFile))

If Type("cEmpAnt") != "U" .And. !Empty(cEmpAnt)
	If Select("SX6") = 0
		dbUseArea(.T.,, "SX6" + cEmpAnt + "0", "SX6")
//		dbSetIndex("SX6" + cEmpAnt + "0")
		cTo := GetMv("MV_HHADMIN",, "")
		lClose := .T.
	EndIf
EndIf

dbSelectArea(__cServUser)
dbSetOrder(1)
If !Empty(cSerie) .And. (__cServUser)->(dbSeek(cSerie))
//	ConOut(nHandle)
	If nHandle > 0
		FWrite(nHandle, DtoC(MsDate()) + " - " + Time() + Chr(13) + Chr(10))
		FWrite(nHandle, STR0046 + AllTrim(cSerie) + " - " + HHU->HHU_NOMUSR + Chr(13) + Chr(10)) // // // // //"Handheld           = "
		FWrite(nHandle, STR0047 + cGrupo + Chr(13) + Chr(10)) // // // // //"Grupo              = "
		FWrite(nHandle, STR0048 + HGU->HGU_CODBAS + Chr(13) + Chr(10)) // // // // //"Vendedor          = "
		FWrite(nHandle, STR0049 + Str(e:genCode,5,0) + Chr(13) + Chr(10)) // // // // //"Erro Numero       = "
		FWrite(nHandle, STR0050 + e:description + Chr(13) + Chr(10)) // // // // //"Descricao do Erro = "
		FWrite(nHandle, "" + Chr(13) + Chr(10))
		FWrite(nHandle, STR0051 + Chr(13) + Chr(10)) // // // // //"Procedimentos Chamados:"
	Else		
		ConOut(STR0052 + AllTrim(cSerie) + " - " + HHU->HHU_NOMUSR) // // // // //"Handheld = "
		ConOut(STR0053 + cGrupo + Chr(13) + Chr(10)) // // // // //"Grupo = "
		ConOut(STR0054 + HGU->HGU_CODBAS) // // // // //"Vendedor = "
		ConOut(STR0055 + Str(e:genCode,5,0)) // // // // //"Erro Numero = "
		ConOut(STR0050 + e:description) // // // // //"Descricao do Erro = "
		ConOut(STR0051) // // // // //"Procedimentos Chamados:"
		ConOut(STR0056 + cFile)	 // // // // //"Arquivo de Log = "
	EndIf
	cMail += STR0052 + AllTrim(cSerie) + " - " + HHU->HHU_NOMUSR + Chr(13) + Chr(10) // // // // //"Handheld = "
	cMail += STR0053 + cGrupo + Chr(13) + Chr(10) // // // // //"Grupo = "
	cMail += STR0054 + HGU->HGU_CODBAS + Chr(13) + Chr(10) // // // // //"Vendedor = "
	cMail += STR0055 + Str(e:genCode,5,0) + Chr(13) + Chr(10) // // // // //"Erro Numero = "
	cMail += STR0050 + e:description + Chr(13) + Chr(10) // // // // //"Descricao do Erro = "
	cMail += STR0056 + cFile + Chr(13) + Chr(10)+ Chr(13) + Chr(10) // // // // //"Arquivo de Log = "
	cMail += STR0051 + Chr(13) + Chr(10) // // // // //"Procedimentos Chamados:"
EndIf	

// Grava chamadas de funcoes
While ( !Empty(ProcName(ni)) )
	If nHandle <> 0
		FWrite(nHandle, "Called from: " + Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni)))+")" + Chr(13) + Chr(10))
	Else
		ConOut("Called from: " + Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni)))+")")
	EndIf
	cMail += "Called from: " + Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni)))+")" + Chr(13) + Chr(10)
	ni++
End
FWrite(nHandle, "" + Chr(13) + Chr(10))
FWrite(nHandle, Replicate("-", 80) + Chr(13) + Chr(10))

If !Empty(cTo)
	HHSendMail({cTo},,, cSubject, cMail)
EndIf
	
(__cServUser)->(MSRLock())
(__cServUser)->HHU_LOCK := "B"
(__cServUser)->(MSRUnlock())

FClose(nHandle)
If lClose
	SX6->(dbCloseArea())
EndIf
Return "DEFAULTERRORPROC"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GetHHDir   ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Retorna diretorio configurada para salvar logs de servico   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GetHHDir()
Local cDir
cDir := GetGlbvalue("__HHTRGDIR")
IF Empty(cDir)
   cDir := GetSrvProfString("HHTrgDir","\HHTRG\")
   PutGlbValue("__HHTRGDIR", cDir)
Endif
Return cDir

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaHHLog³Autor  ³                    ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMsg: Mensagem a ser gravada no LOG                        ³±±
±±³          ³ lImp: Indica se deve gravar mensagem no LOG de importacao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Grava Log de servicos do SFA                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GravaHHLog(cMsg,lImp)

#IFDEF LOGMODE
Local nHdl := -1 , nERR := 0, cDir := GetHHDir() + "\LOGJOB\"
Local cArq := "LOG_"

DEFAULT lImp := .F.

If __HHLog >= 2 // Quebra por data+ID (\HHTRG\LOGJOB\20070101\...)
	cDir += DTOS(date()) + "\"
	MAKEDIR(cDir)
	If !HGU->(Eof())
		cId := HGU->HGU_CODBAS
		If !Empty(cId)
			cArq += cId
		EndIf
	EndIf
EndIf
If lImp
	cArq += "_IMP"
EndIf
cArq += ".TXT"

While nHDL < 0
	nHdl := FOpen(cDir+cArq,FO_EXCLUSIVE+FO_READWRITE)
	IF nHdl < 0
		IF !File(cDir+cArq)
			nHdl := FCREATE(cDir+cArq)
		Endif
		IF nHdl < 0
			nERR++
			IF nERR > 500
				//USEREXCEPTION("NAO FOI POSSIVEL OBTER ACESSO ECLUSIVO AO ARQUIVO LOGPALM.TXT")
				ConOut(STR0059 + cArq) // "NAO FOI POSSIVEL OBTER ACESSO EXCLUSIVO AO ARQUIVO "
			Endif
			Sleep(100)
			Loop
		Endif
	Endif
	Exit
End
IF nERR > 10
	cMsg += StrZero(nERR/10,6,0)+ " segundos gastos para a abertura"
Endif
FSEEK(nHdl,0,2)
FWRITE(nHdl,cMsg)
FClose(nHdl)
#ENDIF
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHInit     ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Inicia JOBS apos conexao de algum HandHeld                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHInit()
Local aPalm  := {}
Local aAlias := {}
Local nServ  := 0
Local cEnv   := GetEnvServer()
Private aServ := {}

// Abre tabelas Handheld
POpenSys() 
POpenHH()
POpenSrv()
HHOpenTime()
POpenTbl()
POpenGrp()
Set Deleted On

dbSelectArea("HHG")
dbSetOrder(1)
dbGoTop()
cGrupo := HHG->HHG_COD
cEmp := Subs(HHG->HHG_EMPFIL,1,2)
cFil := Subs(HHG->HHG_EMPFIL,3,2)
DbSelectArea("HGS")
DbSetOrder(3)
DbSeek(cGrupo)
While !HGS->(Eof()) .And. AllTrim(HGS->HGS_GRUPO) == AllTrim(cGrupo)
	cServ := Trim(HGS->HGS_SRV)	
	nServ := HHExistServ(cServ)
	If ( nServ <> 0 )
		//retorna nome fisico  e indices usado pelo servico
		aAlias := HHExeTable(nServ)
		aPalm  := HHExeArq(nServ)
	EndIf
	HGS->(dbSkip())
End

PTInternal(1,STR0057 + cEnv + " - " + cEmp + "/" + cFil) // // // // //"Iniciando Ambiente "
RpcSetType ( 3 )
RpcSetEnv(cEmp,cFil,,,cEnv,,aAlias)
PTInternal(1,STR0058) // // // // //"Aguardando Conexão..."
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHConnect  ³Autor  ³                   ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Conexao de algum HandHeld x MCS                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHConnect(cIP,cParam)
Local cRet  := "-1"
Local nPos  := 0
Local cFunc := ""

ConOut("HHConnect -> " + cParam)
PTInternal(1,STR0014 + cParam) // // // // //"Executando "
cRet := &(cParam)

nPos := At("(", cParam)
If nPos != 0
	cFunc := Subs(cParam,1,nPos-1)
EndIf
ConOut("HHConnect (" + cFunc + ") -> " + cRet)
PTInternal(1,STR0058) // // // // //"Aguardando Conexão..."
Return cRet + Chr(0)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HHUpdTriggerOn ³Autor  ³               ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Atualiza Triggers                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HHUpdTriggerOn(cEmpFil, aAlias, lActive)
Local cEmp  := Subs(cEmpFil,1,2)
Local cFil  := Subs(cEmpFil,3,2)
Local lLock := .F.
Local ni  := 0

DEFAULT lActive := .T.

If Empty(cEmpFil)
	Return Nil
EndIf

For ni := 1 To Len(aAlias)
	dbSelectArea("HHTRG")
	dbSetOrder(1)  /// Chave = Empresa + Filial + Alias
	If !dbSeek(cEmpFil + aAlias[ni])
		lLock := .T.
	Else
		lLock := .F.
	EndIf
	RecLock("HHTRG", lLock)
	HHTRG->HTR_EMP := cEmp
	HHTRG->HTR_FIL := cFil
	HHTRG->HTR_ALIAS := aAlias[ni]
	HHTRG->HTR_TABLE := RetSqlName(aAlias[ni])
	HHTRG->HTR_TRG := If(lActive, "X", Space(1))
	MsUnlock()
Next
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDbfNameºAutor  ³Rodrigo  A. Godinho º Data ³  02/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o nome fisico da tabela.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cAlias - alias da tabela.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³String com nome fisico da tabela.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³HHXAPI                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetDbfName(cAlias)
Local aArea		:=	GetArea()
Local aAreaSX2	:=	SX2->(GetArea())
Local cRet		:=	"" 

dbSelectArea("SX2")
SX2->(dbSetOrder(1))

If SX2->(dbSeek(cAlias))
	cRet := SX2->X2_ARQUIVO
EndIf

RestArea(aAreaSX2)
RestArea(aArea)
Return cRet
 
