#INCLUDE "EXTXDEF.CH"
#INCLUDE "TAFAINTJOB.CH"

#DEFINE MAX_OPROCESS	10

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtAIntJob     

	Processos de ExtAINTEG via JOB

    [TAFENV]								;Configurar as seguintes chaves no ambiente do TAF
	EXTAIntJob=1							;0=Desabilita a Execução de EXTAIntJob;
											;1=Habilita a execução de EXTAIntJob

	EXTAIntJobEmp=01						;Empresa(s)
											;1-1-Pode ser uma lista (separada por virgula):01,02,03,04,...
											;2-Pode ser individual: 01 ou 02 ou ... 04 ... NN

	EXTAIntJobEmpNN=01    					;Filiais onde NN corresponde ao Codigo da Empresa. Ex.:
											;EXTAIntJobEmp01=01,02,03,04,...
											;EXTAIntJobEmp02=01,02,03,04,...
											;EXTAIntJobEmp03=01,02,03,04,...
											;EXTAIntJobEmpNN=01,02,03,04,...

	EXTAIntJobOpc=0,1,2,3,4,5   			;Opções de Execução do EXTIntJOB.
											;1-Pode ser uma lista (separada por virgula): 0,1,2,3,4,5 ou;
											;2-Pode ser individual: 0 ou 1 ou 2 ou ... 5 

	EXTAIntJobDB=MSSQL  					;DBMS

	EXTAIntJobAlias=EXT 					;ALIAS

	EXTAIntJobProcess=2 					;0-Sem Interface com usuario (apenas msgs no console);
	                                        ;1-Mostra Barra de Processamento usando tNewProcess;
	                                        ;2-Mostra Barra de Processamento usando MsNewProcess;
	                                        ;3-Mostra apenas MsAguarde;

    EXTAIntJobCProgress1=-,\,|,/			;Define o conjunto de caracteres para animacao na Gauge1
    										;Podera, opcionalmente, carregar uma macro como por exemplo: &Chr(7)+","+Chr(8)

	EXTAIntJobTProgress1=,					;Define o caractere separador em EXTAIntJobCProgress1

	EXTAIntJobEProgress1=PROGRESS			;Define o Metodo para Execucao em EXTAIntJobCProgress1:
											;INCREMENT;
											;DECREMENT;
											;SHUTTLE;
											;JUNCTION;
											;DISJUNCTION;
											;UNION;
											;DISPERSION;
											;OCCULT
    EXTAIntJobCProgress2=1,2,3,4,5,6,7,8,9	;Define o conjunto de caracteres para animacao na Gauge2
    										;Podera, opcionalmente, carregar uma macro como por exemplo: &Chr(7)+","+Chr(8)

	EXTAIntJobTProgress2=,					;Define o caractere separador em EXTAIntJobCProgress2

	EXTAIntJobEProgress2=INCREMENT			;Define o Metodo para Execucao em EXTAIntJobCProgress2:
											;INCREMENT;
											;DECREMENT;
											;SHUTTLE;
											;JUNCTION;
											;DISJUNCTION;
											;UNION;
											;DISPERSION;
											;OCCULT
	
	@param: <void>

	@return: NIL
	
	@author Rodrigo dos Santos  
	
	@since 23/12/2013
	@version 1.0

/*/
//-------------------------------------------------------------------
Main Function ExtAIntJob()
	
	Local aEmps
	Local aFils
	
	Local cEmp
	Local cFil

	Local cPerg			:= NIL
	Local cProcFun		:= ProcName()
	Local cProcTit		:= "ExtAIntJob : Teste dos Processos de EXTAINTEG via JOB"
	Local cProcDes		:= "Este programa tem a finalidade de executar todos os procedimentos de EXTAINTEG via JOB"
	Local cProcess		:= GetSrvProfString("EXTAIntJobProcess","2")
	Local cSTimeOut		:= xExtSTimeOut("0")

	Local bonWInit
	Local bPrepEnv		:= {|lIsBlind|xExtRpcSetEnv(@cEmp,@cFil),SetBlind(@lIsBlind)}
	Local bProcess

	Local lViewExecute	:= .T.
	Local lOneMeter		:= .F.
	
	Local lCentury		:= __SetCentury("ON")
	
	Local nEmp
	Local nEmps

	Local oFont
	Local oProcess

	BEGIN SEQUENCE
    
		xExtMsgJob(cProcFun,EXT_MSGINTERNAL)

		IF .NOT.(Empty(ProcName(1)))
			//"Chamada de Procedimento Inválido."###"Esta rotina não pode ser executada a partir do menu"
			xExtMsgJob(OemToAnsi(STR0003+CRLF+STR0004),EXT_MSGALERT)
			BREAK
		EndIF

		IF .NOT.(GetSrvProfString("EXTAIntJob","0")=="1")
			BREAK
		EndIF

		aEmps	:= xExtStrToKArr(GetSrvProfString("EXTAIntJobEmp","ERROR"),",")
		
		cEmp	:= aEmps[1]
		IF (cEmp=="ERROR")
			//"Chave EXTAIntJobEmp não configurada corretamente no Arquivo "
			xExtMsgJob(STR0010+GetSrvIniName(),EXT_MSGALERT)	
			BREAK
		EndIF
		
		nEmps := Len(aEmps)
		aFils := Array(nEmps)
		For nEmp := 1 To nEmps
			aFils[nEmp] := xExtStrToKArr(GetSrvProfString("EXTAIntJobEmp"+aEmps[nEmp],"ERROR"),",")
		Next nEmp
		
		cFil	:= aFils[1][1]
		IF (cFil=="ERROR")
			//"Chave EXTAIntJobFil não configurada corretamente no Arquivo "
			xExtMsgJob(STR0011+GetSrvIniName(),EXT_MSGALERT)	
			BREAK
		EndIF

		//"Preparando Ambiente"###"Aguarde..."
		IF (cProcess=="0")
			SetBlind(.T.)
			Eval(bPrepEnv,.T.)
		Else
			SetBlind(.F.)
			MsAguarde(bPrepEnv,cProcFun+":["+STR0005+"]",STR0006)
		EndIF    

		IF (cProcess$"1|2")
			oFont := TFont():New("Lucida Console",NIL,12,NIL,.T.)
			IF (cProcess=="1") //tNewProcess()
				Private oMainWnd
				bProcess := {|oProcess|xExtProcRedefine(@oProcess,@oFont),IntJobExec(@oProcess,@cProcess,@oProcess:lEnd,@aEmps,@aFils)}
				bonWInit := {||oProcess:=tNewProcess():New(@cProcFun,@cProcTit,@bProcess,@cProcDes,@cPerg,NIL,NIL,NIL,NIL,@lViewExecute,@lOneMeter),oMainWnd:End()}
				DEFINE WINDOW oMainWnd FROM 000,000 TO 400,500 TITLE cProcTit
				ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT Eval(bonWInit)
			ElseIF (cProcess=="2") //MsNewProcess()
				bProcess := {|lEnd,oProcess|xExtProcRedefine(@oProcess,@oFont,0,350,350,.T.,.T.),IntJobExec(@oProcess,@cProcess,@lEnd,@aEmps,@aFils)}
				oProcess := MsNewProcess():New(bProcess,@cProcDes,@cProcTit,.T.)
				oProcess:Activate()
				IF .NOT.( oProcess:lEnd )
					oProcess:oDlg:End()
				EndIF
			EndIF
			//-------------------------------------------------------------------
			// Libera os Objetos da Memória
			IF (ValType(oProcess)=="O")
				oProcess := FreeObj(oProcess)
			EndIF	
		Else
			bProcess	:= {||IntJobExec(NIL,@cProcess,.F.,@aEmps,@aFils)}
			Eval(bProcess)
		EndIF

		RpcClearEnv()

	END SEQUENCE
	
	xExtSTimeOut(cSTimeOut)
	
	IF .NOT.( lCentury )
		__SetCentury("OFF")
	EndIF	

Return(NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} IntJobExec

	Executa os Processos de EXTAINTEG via JOB
	
	@param: 
	
	oProcess - Objeto do tipo tNewProcess ou MsProcess
	cProcess - Qual tipo de Processamento Executar:
				0-Sem Interface com usuario (apenas msgs no console);
	            1-Mostra Barra de Processamento usando tNewProcess;
	            2-Mostra Barra de Processamento usando MsNewProcess;
	            3-Mostra apenas MsAguarde;
	lEnd	 - Verifica o Encerramento pelo usuario (tNewProcess e MsNewProcess)
	aEmps    - Empresas a serem Processadas
	aFils    - Filiais a serem processadas
	
	@return: NIL
	
	@author Rodrigo dos Santos  
	
	@since 23/12/2013
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IntJobExec(oProcess,cProcess,lEnd,aEmps,aFils)

	Local aPar			:= Array(EXT_APARELEM)
	Local aExec

	Local bExec			:= {||oEXTTime:SetRemaining(1),EXTAInteg(@aPar),oEXTTime:Calcule()}
	Local bPrepEnv		:= {|lIsBlind|xExtRpcSetEnv(@cEmp,@cFil),SetBlind(@lIsBlind)} 
	
	Local cEmp
	Local cFil 
	
	Local cMsgE
	Local cExec
	Local cCProg1		:= AllTrim(GetSrvProfString("EXTAIntJobCProgress1","-,\,|,/"))
	Local cTProg1		:= AllTrim(GetSrvProfString("EXTAIntJobTProgress1",","))
	Local cEProg1		:= AllTrim(Upper(GetSrvProfString("EXTAIntJobEProgress1","PROGRESS")))
	Local cCProg2		:= AllTrim(GetSrvProfString("EXTAIntJobCProgress2","1,2,3,4,5,6,7,8,9"))
	Local cTProg2		:= AllTrim(GetSrvProfString("EXTAIntJobTProgress2",","))
	Local cEProg2		:= AllTrim(Upper(GetSrvProfString("EXTAIntJobEProgress2","INCREMENT")))
	Local cProcFun		:= ProcName()
	Local cIncRegua		:= ""
	Local coProcess		:= cEXT_NToS(MAX_OPROCESS)
	Local cFileControl	:= EXT_CIPCFILECONTROL
	
	Local cSRVIniName	:= GetSrvIniName()
	
	Local lContinue		:= .T.
	Local loProcess		:= (ValType(oProcess)=="O")
	Local lMsAguarde	:= (.NOT.(loProcess).and.(cProcess=="3"))
	Local lIsBlind		:= (.NOT.(loProcess) .and. .NOT.(lMsAguarde))
	Local lForceExit	:= .F.
	
	Local nOPC
	Local nOPCs
	
	Local nEmp
	Local nEmps			:= Len(aEmps)
	
	Local nFil
	Local nFils
	
	Local noProcess		:= MAX_OPROCESS
	Local noProcCnt		:= 0
	Local noProcTot		:= 0
	
	Local oRTime1
	Local oRTime2
	Local oEXTTime		:= xExtRemaining():New(0)
	Local oProgress1
	Local oProgress2
	
	BEGIN SEQUENCE
	
		xExtMsgJob(cProcFun,EXT_MSGINTERNAL)
		
		IF .NOT.(xExtFControl(@cFileControl))
			BREAK
		ENDIF
		
		IF (loProcess)
			oProcess:SetRegua1(noProcess)
			oProgress1	:= xExtProgress():New(cCProg1,cTProg1)
			oProgress2	:= xExtProgress():New(cCProg2,cTProg2)
			oRTime1		:= xExtRemaining():New(noProcess)
			oRTime2  	:= xExtRemaining():New(0)
		EndIF

		While (lContinue)
			lForceExit := ((GetSrvProfString("EXTAIntJob","0")=="0").or.xExtKillApp(@cFileControl))
			IF (lForceExit)
				lForceExit := ForceKillApp(cFileControl)
			EndIF			
			IF (lForceExit)
				lContinue := .F.
				IF (loProcess)
					lEnd := .T.
				EndIF
				BREAK
			EndIF
			IF (loProcess)
				IF (++noProcCnt>noProcess)
					noProcCnt := 1
					++noProcTot
				EndIF
				oProcess:SetRegua1(nEmps)
				oRTime1:SetRemaining(nEmps)
			EndIF
			For nEmp := 1 To nEmps
				cEmp	:= aEmps[nEmp]
				IF (loProcess)
					//"Final"###"Média"
					cIncRegua := "["+oProgress1:Eval(cEProg1)+"]["+cEXT_NToS(noProcTot)+"]["+cEXT_NToS(noProcCnt)+"/"+coProcess+"]"
					cIncRegua += " | "+STR0014+":["+DtoC(oRTime1:GetdEndTime())+"]["+oRTime1:GetcEndTime()+"]"
					cIncRegua += " | "+STR0015+":["+oRTime1:GetcMediumTime()+"]"
					oProcess:IncRegua1(cIncRegua)
					IF (lEnd)
						lContinue  := .F.
						lForceExit := ForceKillApp(cFileControl)
						BREAK
					EndIF
				EndIF
				aPar[EXT_APAREMP] := cEmp
				nFils := Len(aFils)
				For nFil := 1 To nFils
					cFil	:= aFils[nEmp][nFil]
					IF (cFil=="ERROR")
						//"Chave "###"não configurada corretamente no Arquivo "
						xExtMsgJob(STR0011+"EXTAIntJobEmp"+aEmps[nEmp]+STR0016+SRVIniName)
						Loop
					EndIF
					Eval(bPrepEnv,lIsBlind)
					aPar[EXT_APARFIL] := cFil
					cExec	:= GetSrvProfString("EXTAIntJobOpc","0,1,2,3,4,5")
					aExec	:= xExtStrToKArr(cExec,",")
					nOPCs	:= Len(aExec)
					IF (loProcess)
						oProcess:SetRegua2(nOPCs)
						oRTime2:SetRemaining(nOPCs)	
					EndIF
					For nOPC := 1 To nOPCs
						cExec	:= AllTrim(aExec[nOPC])
						aPar[EXT_APAROPC]	:= Val(cExec)
						aPar[EXT_APARDBMS]	:= GetSrvProfString("EXTAIntJobDB","ERROR")
						IF (aPar[EXT_APARDBMS]=="ERROR")
							//"Chave EXTAIntJobDB não configurada corretamente no Arquivo "
							xExtMsgJob(STR0012+cSRVIniName)	
							Loop
						EndIF
						aPar[EXT_APARALIAS] := GetSrvProfString("EXTAIntJobAlias","ERROR")
						IF (aPar[EXT_APARALIAS]=="ERROR")
							//"Chave EXTAIntJobAlias não configurada corretamente no Arquivo "
							xExtMsgJob(STR0013+cSRVIniName)	
							Loop
						EndIF
						cMsgE	   := OemToAnsi("EXTPROC["+cExec+"]["+cEmp+"/"+cFil+"]")
						lForceExit := ((GetSrvProfString("EXTAIntJob","0")=="0").or.xExtKillApp(@cFileControl))
						IF (lForceExit)
							lForceExit := ForceKillApp(cFileControl)
						EndIF
						IF (lForceExit)
							lContinue := .F.
							IF (loProcess)
								lEnd := .T.
							EndIF
							BREAK
						EndIF
						IF (loProcess)
							//"Final"###"Média"
							cIncRegua := "["+oProgress2:Eval(cEProg2)+"]"
							cIncRegua += cMsgE
							cIncRegua += " | "+STR0014+":["+DToC(oRTime2:GetdEndTime())+"]["+oRTime2:GetcEndTime()+"]"
							cIncRegua += " | "+STR0015+":["+oRTime2:GetcMediumTime()+"]"					
							oProcess:IncRegua2(cIncRegua)
							IF (lEnd)
								lContinue  := .F.
								lForceExit := ForceKillApp(cFileControl)
								BREAK
							EndIF
		                    //-------------------------------------------------------------------
		                    // Executa o Processamento
							Eval(bExec)
		                    //-------------------------------------------------------------------
		                    // Obtem o Tempo Médio de Processamento
		                    // "Tempo médio de Processamento: "
		                    cMsgE += "["+STR0017+oEXTTime:GetcMediumTime()+"]"
							//-------------------------------------------------------------------							
							// Envia o Tempo Médio de Processamento para o Console
							xExtMsgJob(cMsgE)
							//-------------------------------------------------------------------							
							// Quando tNewProcess()
							IF (cProcess=="1")
		                    	//-------------------------------------------------------------------
		                    	// Forco um PrepEnv pois um RPCClearEnv foi Executado
								Eval(bPrepEnv,lIsBlind) 
								//-------------------------------------------------------------------							
								// Salva o Tempo Médio de Processamento
								oProcess:SaveLog(cMsgE)
							EndIF
							SetBlind(lIsBlind)
						ElseIF (lMsAguarde)
							//-------------------------------------------------------------------
		                    // Executa o Processamento
							MsAguarde(bExec,cMsgE,"EXTPROC["+cExec+"]")
		                    //-------------------------------------------------------------------
		                    // Obtem o Tempo Médio de Processamento
		                    // "Tempo médio de Processamento: "
		                    cMsgE += "["+STR0017+oEXTTime:GetcMediumTime()+"]"
							//-------------------------------------------------------------------							
							// Envia o Tempo Médio de Processamento para o Console
							xExtMsgJob(cMsgE)
						Else
							Eval(bExec)
		                    //-------------------------------------------------------------------
		                    // Obtem o Tempo Médio de Processamento
		                    // "Tempo médio de Processamento: "
		                    cMsgE += "["+STR0017+oEXTTime:GetcMediumTime()+"]"
							//-------------------------------------------------------------------
							// Envia o Tempo Médio de Processamento para o Console
							xExtMsgJob(cMsgE)
						EndIF
						SetBlind(lIsBlind)
						IF (loProcess)
							oRTime2:Calcule()
						EndIF
					Next nOPC
					Sleep(EXT_NIPCSLEEP)
				Next nFil	
				Sleep(EXT_NIPCSLEEP)
				IF (loProcess)
					oRTime1:Calcule()
				EndIF
			Next nEmp	
			Sleep(EXT_NIPCSLEEP)
		End While

	END SEQUENCE

Return(NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBlind

	Seta modo Blind
	
	@param: lIsBlind - Define o Modo Blind a ser Setado: 
			.T. lBlind
			.F. .NOT.(lBlind)
	
	@return: NIL
	
	@author Rodrigo dos Santos  
	
	@since 23/12/2013
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetBlind(lIsBlind)
	DEFAULT lIsBlind := .F.
	IF ( lIsBlind )
		__cINTERNET		:= "AUTOMATICO"
	Else
		__cINTERNET		:= NIL
	EndIF		
	IF (Type("oApp")=="O")
		oApp:lIsBlind	:= lIsBlind
		oApp:cInternet	:= __cINTERNET
	EndIF
	__cBinder 			:= __cINTERNET
Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} ForceKillApp

	Force KillApp
	
	@param: cFileControl - Nome do Arquivo de Controle
	
	@return: lKillApp
	
	@author Rodrigo dos Santos  
	
	@since 23/12/2013
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ForceKillApp(cFileControl)
Return(xExtKillApp(@cFileControl,.T.))