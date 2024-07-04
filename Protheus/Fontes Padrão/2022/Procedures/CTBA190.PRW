#INCLUDE "CTBA190.CH"
#INCLUDE "PROTHEUS.CH"
#Include "FWLIBVERSION.CH"

#DEFINE MAXPASSO 12
#DEFINE D_PRELAN		"9"
#DEFINE DEF_DB_ORACLE               "ORACLE"
#DEFINE DEF_DB_MSSQL                "MSSQL"
#DEFINE DEF_DB_MSSQL7               "MSSQL7"
#DEFINE DEF_DB_POSTGRES             "POSTGRES"
#DEFINE DEF_DB_DB2                  "DB2"
#DEFINE DEF_DB_INFORMIX             "INFORMIX"
#DEFINE DEF_DB_MYSQL                "MYSQL"
#DEFINE DEF_DB_SYBASE               "SYBASE"


STATIC dDTLPAnt		:= CTOD("  /  /  ")					///DATA DA APURACAO DE LUCROS E PERDAS ANTERIOR
STATIC lFWCodFil	:= FindFunction("FWCodFil")
Static oConjCubos
Static lCtbIsCube := FindFunction("CtbIsCube")
Static _oCTBA1901
Static lCT190PRO
Static lEntidad05	:= .F.

//Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"

//-------------------------------------------------------------------
/*{Protheus.doc} CTBA190
Reprocessamento de saldo contábeis 

@author Alvaro Camillo Neto

@param lDireto 	Flag para processamento sem tela. 
@param dDataIni 	Data Inicial
@param dDataFim	Data Final                                            
@param cFilDe 	Filial De                       
@param cFilAte 	Filial Ate			           
@param cTpSald 	Tipo de Saldo 
@param lMoedaEsp 	Define se é moeda especifica                       
@param cMoeda 	Moeda	
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBA190(lDireto,dDataIni,dDataFim,cFilDe,cFilAte,cTpSald,lMoedaEsp,cMoeda,lAtu330)
	Local lRet := .F.
	Local nStart		:= 0

	DEFAULT lDireto := .F.
	Default lAtu330 := .F.
	
	//Iniciar telemetria - Tempo médio
	If __lMetric
		nStart := Seconds()
	EndIf

	lRet := CTBA190Exec(lDireto,dDataIni,dDataFim,cFilDe,cFilAte,cTpSald,lMoedaEsp,cMoeda,lAtu330)
	lRet := IIf(Empty(lRet), .F., .T.)
	
	If ExistBlock("CT190FIM")
		ExecBlock("CT190FIM", .F., .F., { IsBlind(), lRet } )
	EndIf

	//Gerar metrica FWMetrics - Tempo médio
	If __lMetric
		CTB190Metrics("01" /*cEvent*/, nStart, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
	EndIf

	If funName() == "CTBA190" .And. lRet .And. !IsBlind()
		MsgInfo( STR0055 )  //"Reprocessamento de saldos efetuado com sucesso!"
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA190Exec³ Autor ³ Daniel Fonsecea Lira ³ Data ³ 19.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Essa rotina é a antiga CTBA190 foi alterada para que possa ³±±
±±³          ³ incluir um ponto de entrada após o seu termino.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±           
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA190Exec(lDireto,dDataIni,dDataFim,cFilDe,cFilAte,cTpSald,lMoedaEsp,cMoeda,lAtu330)
Local aSays		:={}
Local aButtons	:={}
Local cFilBack	:= cFilAnt
Local nOpca 	:= 0
Local nReg
Local oProcess
Local cQuery    := ""
Local nFKinUse  := 0
Local lAtSldBase	:= Iif(SuperGetMV("MV_ATUSAL")== "S",.T.,.F.)
Local aCtbMoeda   := {}
Local nInicio
Local nFinal
Local nTpSldA := 1
Local aTpSld  := {}
Local cTpSldA := "1"
Local nx
Local lDelFisico	:= GetNewPar('MV_CTB190D',.T.)
Local lJobs	 		:= IsCtbJob()
Local lContinua		:=	.T.
Local lTenta		:=	.T.
Local l330Log		:= FindFunction('M330PrcLog')
Local aSM0			:= AdmAbreSM0()
Local cCTB020       := IIF(FindFunction("GetSPName"), GetSPName("CTB020","01"), "CTB020")
Local cCTB001       := IIF(FindFunction("GetSPName"), GetSPName("CTB001","02"), "CTB001")
Local bRegua := {|x|x:SetRegua1(0),x:SetRegua1(0),x:SetRegua2(0),x:SetRegua2(0) }
Local lExclusivo	:= If(FindFunction("ADMTabExc"), ADMTabExc("CT2"), !Empty(xFilial("CT2"))) //Analisa se a tabela esta exclusiva
Local cFilProc		:= ""
Local bProc
Local cFilX	:= cFilAnt
Local nPosSld 		:= 0 
Local lRet   := .F.
Local lOlhaMvPar := !IsInCallStack( "Ct220Proc" )
Local lPrcSemReg := IsInCallStack( "CTB281PROC" ) .OR. IsInCallStack( "CTBA211" ) .OR. IsInCallStack( "CTBA215" )
Local lRecalculo := lDireto .And. (IsInCallStack( "MATA330" ) .Or. IsInCallStack( "MATA331" ))
Local lAutomato    := IsBlind() 
Local cFilLock	   := ""
Local cMsgError  := ""
Local cMensagem  := ""

Local lIsSchedule	:= FwIsInCallStack("FWBOSCHDEXECUTE")

Private cCadastro 	:= STR0001  //"Reprocessamento"
Private aResult  	:= {}
Private lCusto		:= CtbMovSaldo("CTT")
Private lItem		:= CtbMovSaldo("CTD")
Private lCLVL		:= CtbMovSaldo("CTH")
Private cMoedaEsp
Private cOperacao
Private cPaisLoc	:= GetMv("MV_PAISLOC")

Private aMvPar		:= {}

DEFAULT dDataIni 	:= FirstDay(dDataBase)
DEFAULT dDataFim 	:= LastDay(dDataBase)
DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cTpSald		:= "*"
DEFAULT lMoedaEsp	:= .F.
DEFAULT cMoeda		:= "01"

If ( !AMIIn(34,33) )		// Acesso somente pelo SIGACTB
	Return lRet
EndIf

lEntidad05   := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7")) // Manejo de entidad 05

If lEntidad05
	// Asegurar que las tablas de saldos de entidad 05 estén creadas
	If FWAliasInDic("QL6") .And. FWAliasInDic("QL7")
		dbSelecTArea("QL6")
		dbSelecTArea("QL7")
		dbSelectArea("CT2")
	Else
		MsgInfo(STR0053,STR0040) //"Antes debe crear las tablas de saldos contables de la entidad 05 (QL6 y QL7) a través del configurador de Protheus."
		// Atualiza o log de processamento com o erro
		ProcLogAtu(STR0040,STR0053)
		Return lRet
	EndIf
EndIf

cQuery := "SELECT count(*) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" + SM0->M0_CODIGO + "'"
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'INTEGR', .F., .T.)
nFKInUse := INTEGR->TOTAL
INTEGR->( dbCloseArea() )


// Inicializa o log de processamento
If !lDireto
	ProcLogIni( aButtons )
Endif

If lCT190PRO == NIL
	lCT190PRO:= ExistBlock("CT190PRO")
EndIf 

If lMoedaEsp					// Moeda especifica
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")

		// Atualiza o log de processamento com o erro		
		ProcLogAtu("ERRO","NOMOEDA",Ap5GetHelp("NOMOEDA"))
		
		Return lRet
	EndIf
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

If !lDireto
	// Variaveis utilizadas para parametros                         
	// mv_par01  Reprocessa a partir? Da Data / Ultimo Fechamento?
	// mv_par02  Data Inicial                                     
	// mv_par03  Data Final                                       
	// mv_par04  Filial De?                                       
	// mv_par05  Filial Ate?                                      
	// mv_par06  Tipo de Saldo? Via F3 - SLD                      
	// mv_par07  Moedas? Todas / Especifica                       
	// mv_par08  Qual Moeda?                                      
	
	If lIsSchedule 
		// Capturar MV_PAR do SCHEDULE, após passar pelo Pergunte() os mv_par são sobrepostos
		// pelos mv_par em memoria
		Ct190MVSchd(1) // Ao passar conteúdo 1 CT190MvSchd vai guardar o conteúdo de mv_par
	EndIf 

	Pergunte("CTB190",.F.)
	
	If IsBlind()
		If !lJobs .Or. LockByName("CTBA192_"+cEmpAnt)

			// Atualizar mv_par com o conteúdo do array aMvPar quando a chamada é via Schedule
			// porque após passar pelo Pergunte() os mv_par são sobrepostos
			// pelo conteúdo de mv_par em memoria

			If lIsSchedule 
				Ct190MVSchd(2) // Ao passar conteúdo 2 CT190MvSchd atualizar o conteúdo de mv_par guardado na primeira chamada da função
			EndIf 
			//Aguarda Finalizacao de JOBS
			If !lJobs .Or.	Wait4Jobs(.F.)
				ProcLogAtu("INICIO")
				If ExistProc(cCTB020,VerIDProc2()) 
					lCusto   := CtbMovSaldo("CTT")
					lItem		:= CtbMovSaldo("CTD")
					lCLVL		:= CtbMovSaldo("CTH")
					If lOlhaMvPar
						cFilDe   := mv_par04
						cFilAte  := mv_par05
						dDataIni := mv_par02
						dDataFim := mv_par03
						cTpSald  := mv_par06
					EndIf
					cOperacao:= '1'
					lReproc  := '1'
					If lMoedaEsp
						cMoedaEsp := '1'
						cMoeda := cMoeda
					Else
						cMoedaEsp := '0'
						cMoeda := '00'
					EndIf
					If cTpSald == "*"   // todos os tipos de saldos
						aTpSld  := CtbRetaSLD()
						For nTpSldA := 1 to Len(aTpSld)
							cTpSldA := aTpSld[nTpSldA]
							
                  	If cTpSldA != '0'
							BatchProcess( 	cCadastro, 	STR0002 + Chr(13) + Chr(10) +;
														STR0003 + Chr(13) + Chr(10) +;
														STR0004 + Chr(13) + Chr(10) +;
														STR0005, "CTB190",;
											{||aResult := TCSPEXEC( xProcedures(cCTB020),;
											Iif(lCusto,'1','0'),;
											Iif(lItem,'1','0'), Iif(lClVl,'1','0'),;
											cFilDe,cFilAte,;
											Dtos(dDataIni),Dtos(dDataFim),;
											cMoedaEsp,cMoeda,;
											cTpSldA,StrZero(Getmv("MV_SOMA"),1),;
											lReproc,If(nFKInUse > 0,'1','0'),;
											If(lDelFisico,'1','0'),;
											cEmpAnt,;
											cFilAnt)})
								
								If Empty(aResult) .or. aResult[1] = "0"
									ConOutR("###"+STR0025 + TCSQLError(),.T.,"CTBA190") //'Erro na chamada do processo - Reproc Contabil'
				     			Endif
				    EndIf
			    		Next
			    	Else  // tipo de saldo específico      
						BatchProcess( 	cCadastro, 	STR0002 + Chr(13) + Chr(10) +;
														STR0003 + Chr(13) + Chr(10) +;
														STR0004 + Chr(13) + Chr(10) +;
														STR0005, "CTB190",;
											{||aResult := TCSPEXEC( xProcedures(cCTB020),;
											Iif(lCusto,'1','0'),;
											Iif(lItem,'1','0'), Iif(lClVl,'1','0'),;
											cFilDe,cFilAte,;
											Dtos(dDataIni),Dtos(dDataFim),;
											cMoedaEsp,cMoeda,;
											cTpSald,StrZero(Getmv("MV_SOMA"),1),;
											lReproc,If(nFKInUse > 0,'1','0'),;
											If(lDelFisico,'1','0'),;
											cEmpAnt,;
											cFilAnt ) } )
						
						if Empty(aResult) .or. aResult[1] = "0"
							ConOutR("###"+STR0025 + TCSQLError(),.T.,"CTBA190") //'Erro na chamada do processo - Reproc Contabil'
		    			EndIf
		    			If lCT190PRO
		    				ExecBlock("CT190PRO", .F., .F., { aResult[1] } )
		    			EndIf
		    			
			    	EndIf
		    	Else // Sem procedure
		    		If lOlhaMvPar
						BatchProcess( 	cCadastro, 	STR0002 + Chr(13) + Chr(10) +;
															STR0003 + Chr(13) + Chr(10) +;
															STR0004 + Chr(13) + Chr(10) +;
															STR0005, "CTB190",;
												{ || Ctb190Proc(,mv_par02, mv_par03,;
												mv_par04, mv_par05, mv_par06, .F., mv_par07, cFilAnt) },;
												{ || .F. })
					Else
						BatchProcess( 	cCadastro, 	STR0002 + Chr(13) + Chr(10) +;
															STR0003 + Chr(13) + Chr(10) +;
															STR0004 + Chr(13) + Chr(10) +;
															STR0005, "CTB190",;
												{ || Ctb190Proc(,dDataIni, dDataFim,;
												cFilDe, cFilAte, cTpSald, .F., cMoeda, cFilAnt) },;
												{ || .F. })
					EndIf 
								
		    	Endif
				If IsCtbJob()
					UnLockByName("CTBA192_"+cEmpAnt+cFilAnt)
					DbSelectArea("CVO")
					CTBJobsStart()
				Endif

				If lAtu330 .AND. l330Log
					M330PrcLog("FIM")
				Else
					ProcLogAtu("FIM")
				EndIf

			EndIf
		Else
			ProcLogAtu( STR0040, STR0041 )
			Return .F.
		EndIf
		
		If lJobs  //se lJob verdadeiro fez lockbyname entao tem que liberar 
			UnLockByName("CTBA192_"+cEmpAnt)
		EndIf
		Return .T.
	EndIf
	
	//If !(ExistProc(cCTB020,VerIDProc2())) .OR. !(ExistProc(cCTB001,VerIDProc()))
	//	MsgInfo("A rotina está sem procedure instalada"  + Chr(13) + Chr(10) + "isso pode degradar a performance" + Chr(13) + Chr(10) + "Necessário instalar os processos 01 e 02")
	//EndIf

	AADD(aSays,STR0002 )	// "Este programa tem como objetivo recalcular os saldos de um determinado periodo."
	AADD(aSays,STR0003 )	// "Devera ser utilizado caso haja necessidade de se recalcular os saldos das entidades contabeis.
	AADD(aSays,STR0004 )	// "O Reprocessamento podera ser efetuado a partir"
	AADD(aSays,STR0005 )	// "de uma data informada.
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CTB190",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CTBOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons,, 220, 560 )
	
	If mv_par01 == 2
		MsgYesNo(STR0047,STR0048) //"Reprocessa a partir do último fechamento -> Opção Não disponível temporariamente!"##"ATENÇÃO"
		
		Return lRet
	EndIf
	
	If Empty(mv_par02) .Or. Empty(mv_par03)
		Help(" ",1,"CTB190DATA")
		Return lRet
	EndIf
	
	If nOpca == 1 .and. !VlDtCal(mv_par02,mv_par03,mv_par07,mv_par08)		/// VALIDA O STATUS DO(S) CALENDÁRIOS PARA O PROCESSAMENTO
		Return lRet
	Endif
	
	dDataIni	:= mv_par02
	dDataFim	:= mv_par03
	cFilde		:= mv_par04
	cFilAte		:= mv_par05
	cTpSald		:= mv_par06
	lMoedaEsp	:= Iif(mv_par07 == 1, .F., .T.)
	cMoeda		:= mv_par08
Else
	nOpca := 1
EndIf

cFilLock := IIF(lExclusivo .And. (cFilde == cFilAte),cEmpAnt+cFilde,cEmpAnt) 

lContinua	:=	.T.
lTenta		:=	.T.

If lJobs .And. !(cTpSald == '0') 

	If LockByName("CTBA192_"+cFilLock) 
		lContinua	:=	.F.
		While lTenta .And. !lContinua
			Processa({|| lContinua := Wait4Jobs(.T.,cFilde,cFilAte) }, STR0033 )
			If !lContinua
				If lAtu330 .AND. l330Log
					M330PrcLog ("ERRO", STR0034 )
				Else
					ProcLogAtu( "ERRO", STR0034 )
				EndIf
				If Aviso( STR0035, STR0036 + CRLF + STR0037, { STR0038, STR0039 } ) == 1
					lTenta	:=	.T.
				Else
					lTenta	:=	.F.
				Endif
			Else
				exit		
			Endif
		Enddo
	Else
		lContinua	:=	.F.
		If lAtu330 .AND. l330Log
			M330PrcLog( STR0040, STR0041  )
		Else
			ProcLogAtu( STR0040, STR0041 )
		EndIf
		Aviso( STR0042, STR0041, { STR0043 } )
	EndIf
Endif

If lContinua .And. nOpca == 1
	If oConjCubos == NIL .and. lCtbIsCube .and. CtbIsCube()
		oConjCubos := Ctb_Load_Cubes()
	EndIf
	
	If cTpSald == "*"
		aTpSld  := CtbRetaSLD()
	EndIf
	
	nPosSld := ASCAN(aTpSld,"9")
	
	If nPosSld > 0
		aDel(aTpSld,nPosSld) 
		ASIZE(aTpSld,len(aTpSld)-1)
	Endif
	
	If FindFunction("CT215LPANT")
		dDTLPAnt		:= Ct215LPAnt(dDataIni,cTpSald,lMoedaEsp,cMoeda)
	Else
		dDTLPAnt		:= dDataIni
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!lRecalculo .and. !lAtu330)  
		ProcLogAtu("INICIO")
	EndIf

	//// FUNÇÃO PARA ATUALIZAR O CONTROLE DE LOCK DA ATUALIZAÇÃO DE SALDOS
	If !CT190ATUMV(dDataFim)
		If !IsBlind()
			//// SE NÃO CONSEGUIR O LOCK DO PARÂMETRO AVISA EM TELA E ABORTA.
			If MsgYesNo(STR0013+STR0029,STR0014)	///"Há um reprocessamento em execução ! " + CHR ( 10 ) + "Tente novamente depois, ou verifique" + CHR ( 10 ) + "se há usuário reprocessando."#"Finaliza o processo ?"#"Atenção, reprocessamento em uso..."
				Return
			Else
				If !IsCtbJob()
					MsgAlert(STR0051)				
				Endif
				CT190LIBMV()
				Return lRet
			EndIf
		Else
			CT190LIBMV()
			Return lRet
		EndIf
	Endif
	
	dbSelectArea("CT2")
	If !lExclusivo		/// SE FOR BASE COMPARTILHADA
		cFilDe 	:= Space(TAMSX3("CT2_FILIAL")[1]) /// ASSUME INTERVALO DE FILIAIS
		cFilAte := Replicate("Z", TAMSX3("CT2_FILIAL")[1])	/// OCORRIA FALHA COM CHAMADA DA PROCEDURE
	EndIf
	
	If FindFunction("CTBSERIALI")
		If !CTBSerialI("CTBPROC","OFF",cFilDe,cFilAte)
			CT190LIBMV()				
			Return lRet
		Endif
	EndIf
	If Empty(cTpSald) .or. cTpSald =="9"		// Caso nao informar o tipo de saldo
		Help(" ",1,"CT2_TPSALD")
		
		// Atualiza o log de processamento com o erro
		
		ProcLogAtu("ERRO","CT2_TPSALD",Ap5GetHelp("CT2_TPSALD"))
		CT190LIBMV()			
		Return lRet
	EndIf
	
	dbSelectArea("SM0")
	nReg := Recno()
	
	If cTpSald $ "0,*"	// Reprocessamento de Saldos Orcamentos - Rotina Especifica
		If TCGetDB() != "INFORMIX" .And. ExistProc(cCTB001,VerIDProc()) // Procedure não executada no informix
			lCusto		:= CtbMovSaldo("CTT")
			lItem		:= CtbMovSaldo("CTD")
			lCLVL		:= CtbMovSaldo("CTH")
			If lMoedaEsp
				cMoedaEsp := '1'
				cMoeda := cMoeda
			Else
				cMoedaEsp := '0'
				cMoeda := '00'
			EndIf
			cOperacao := '1'
			bProc := {||aResult := TCSPEXEC( xProcedures(cCTB001),;
				Iif(lCusto,'1','0'),Iif(lItem,'1','0'),;
				Iif(lClVl,'1','0'), cFilDe,cFilAte,;
				Dtos(dDataIni),;
				Dtos(dDataFim),cMoedaEsp,;
				cMoeda,cOperacao,If(nFKInUse > 0,'1','0'),;
				If(lDelFisico,'1','0'))}
			
			If !lDireto
				MsgRun(STR0007+STR0008,STR0001,bProc)
			Else
				Eval(bProc)
			EndIf
			
			If Empty(aResult) .or. aResult[1] = "0"
				cMsgError := TCSQLError()
				cMensagem := I18N(STR0054,{"CTB001","02"}) // "Procedure #1[CTB001]# Processo #2[02]#"
				A190Alert(STR0025,cMensagem,cMsgError) //'Erro na chamada do processo - Reproc Contabil'
			Else
				For nx := nInicio to nFinal
					If GetCV7Date(cTpSald,StrZero(nx,2,0)) < dDataIni
						dDataIni := GetCV7Date(cTpSald,StrZero(nx,2,0))+1
					EndIf
					PutCV7Date(cTpSald,StrZero(nx,2,0),dDataFim)
				Next nx
			Endif
		Else
			oProcess := MsNewProcess():New({|lEnd|Ctb390Rep(oProcess,cFilDe,cFilAte,dDataIni,dDataFim)},"","",.F.)
			oProcess:Activate()
		End
		lRet := .T.
	Endif
	
	If cTpSald <> "0"
		If ExistProc(cCTB020,VerIDProc2())
			lCusto		:= CtbMovSaldo("CTT")
			lItem		:= CtbMovSaldo("CTD")
			lCLVL		:= CtbMovSaldo("CTH")
			SM0->(MsSeek(cEmpAnt+cFilDe,.T.))
			If (IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )) <= cFilAte .and. SM0->M0_CODIGO == cEmpAnt
				cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				
				lReproc := '1'
				If lMoedaEsp
					cMoedaEsp := '1'
					cMoeda := cMoeda
				Else
					cMoedaEsp := '0'
					cMoeda := '00'
				EndIf
				
				If cTpSald <> "*"
					If lJobs 
						DeleteCQA(cFilDe,cFilAte,dDataIni,dDataFim,cTpSald,cMoeda)
					Endif
					
					bProc := {||aResult := TCSPEXEC( xProcedures(cCTB020),;
						Iif(lCusto,'1','0'),;
						Iif(lItem,'1','0'), Iif(lClVl,'1','0'),;
						cFilDe,cFilAte,;
						Dtos(dDataIni),Dtos(dDataFim),;
						cMoedaEsp,cMoeda,;
						cTpSald,StrZero(Getmv("MV_SOMA"),1),;
						lReproc,If(nFKInUse > 0,'1','0'),;
						If(lDelFisico,'1','0'),;
						cEmpAnt,;
						cFilAnt)}
					
					If !lDireto
						MsgRun(STR0007+STR0008,STR0001,bProc)
					Else
						Eval(bProc)
					Endif
					
					If Empty(aResult) .or. aResult[1] = "0"
						cMsgError := TCSQLError()
						cMensagem := I18N(STR0054,{"CTB020","01"}) // "Procedure #1[CTB020]# Processo #2[01]#"
						A190Alert(STR0025,cMensagem,cMsgError) //'Erro na chamada do processo - Reproc Contabil'
					Else
						SM0->(MsSeek(cEmpAnt+cFilDe,.T.))
						
						While !SM0->(Eof()) .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte .and. SM0->M0_CODIGO == cEmpAnt
							cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
							
							For nx := nInicio to nFinal
								If GetCV7Date(cTpSald,StrZero(nx,2,0)) < dDataIni
									dDataIni := GetCV7Date(cTpSald,StrZero(nx,2,0))+1
								EndIf
								PutCV7Date(cTpSald,StrZero(nx,2,0),dDataFim)
							Next nx
							lRet := .T.
							dbSelectArea("SM0")
							dbSkip()
						
						Enddo
					Endif
				Else
					
					For nTpSldA := 1 to Len(aTpSld)
						cTpSldA := aTpSld[nTpSldA]
						
						If cTpSldA == "0" // Saldo Orçado já foi calculado
							Loop
						EndIf
							
						If lJobs 
							DeleteCQA(cFilDe,cFilAte,dDataIni,dDataFim,cTpSald,cMoeda)
						EndIf
						
						bProc := {||aResult := TCSPEXEC( xProcedures(cCTB020),;
							Iif(lCusto,'1','0'),;
							Iif(lItem,'1','0'), Iif(lClVl,'1','0'),;
							cFilDe,cFilAte,;
							Dtos(dDataIni),Dtos(dDataFim),;
							cMoedaEsp,cMoeda,;
							cTpSldA,StrZero(Getmv("MV_SOMA"),1),;
							lReproc,If(nFKInUse > 0,'1','0'),;
							If(lDelFisico,'1','0'),;
							cEmpAnt,;
							cFilAnt )}
						
						If !lDireto
							MsgRun(STR0007+STR0008,STR0001,bProc)
						Else
							Eval(bProc)
						EndIf
						
						If Empty(aResult) .or. aResult[1] = "0"
							cMsgError := TCSQLError()
							cMensagem := I18N(STR0054,{"CTB020","01"}) // "Procedure #1[CTB020]# Processo #2[01]#"
							A190Alert(STR0025,cMensagem,cMsgError) //'Erro na chamada do processo - Reproc Contabil'
							nTpSldA := Len(aTpSld)+1
							Exit
						Else
							For nx := nInicio to nFinal
								If GetCV7Date(cTpSald,StrZero(nx,2,0)) < dDataIni
									dDataIni := GetCV7Date(cTpSald,StrZero(nx,2,0))+1
								EndIf
								PutCV7Date(cTpSald,StrZero(nx,2,0),dDataFim)
							Next nx
						Endif
					Next
					
				EndIf
			Endif
		Else
			SM0->(MsSeek(cEmpAnt+cFilDe,.T.))
			cFilComp := ""
			While !SM0->(Eof()) .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte .and. SM0->M0_CODIGO == cEmpAnt
				cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				
				If xFilial("CT2") == cFilComp 
					SM0->(dbSkip())
					Loop
				Else
					cFilComp := xFilial("CT2")
				EndIf
								
				If cTpSald <> "*"
					If lJobs
						DeleteCQA(cFilAnt,cFilAnt,dDataIni,dDataFim,cTpSald,cMoeda)
					Endif
					
					If !lDireto
						oProcess := MsNewProcess():New({|lEnd| Ctb190Proc(oProcess,dDataIni,;
							dDataFim,cFilAnt, cFilAnt,cTpSald,lMoedaEsp,cMoeda,cFilAnt)},"","",.F.)
						oProcess:Activate()
					Else
						Ctb190Proc(oProcess,dDataIni,dDataFim,cFilAnt, cFilAnt,cTpSald,lMoedaEsp,cMoeda,cFilAnt)
					Endif
					
				Else
					For nTpSldA := 1 to Len(aTpSld)
						cTpSldA := aTpSld[nTpSldA]
						If cTpSldA == "0" // Saldo Orçado já foi calculado
							Loop
						EndIf
						If lJobs
							DeleteCQA(cFilDe,cFilAte,dDataIni,dDataFim,cTpSldA,cMoeda)
						Endif
						
						If !lDireto
							oProcess := MsNewProcess():New({|lEnd| Ctb190Proc(oProcess,dDataIni,;
								dDataFim,cFilAnt, cFilAnt,cTpSldA,lMoedaEsp,cMoeda,cFilAnt)},"","",.F.)
							oProcess:Activate()
						Else
							//Ctb190Proc(oProcess,dDataIni,dDataFim,cFilAnt, cFilAnt,cTpSldA,lMoedaEsp,cMoeda,cFilAnt)
							MsNewProcess():New({|lEnd| Ctb190Proc(oProcess,dDataIni,;
								dDataFim,cFilAnt, cFilAnt,cTpSldA,lMoedaEsp,cMoeda,cFilAnt)},"","",.F.)
						Endif
					Next
				EndIf
				
				If !lExclusivo//Se o arquivo e' compartilhado, so devera ser lido apenas uma vez!!
					Exit
				Endif
				
				dbSelectArea("SM0")
				dbSkip()
			Enddo
			//reprocessamento dos cubos
			If lCtbIsCube .And. CtbIsCube()
				If cTpSald <> "*"
					bProc := {|| Ctb_RprCub(oConjCubos,aSM0,dDataIni,dDataFim,cTpSald,cFilDe,cFilAte,!lMoedaEsp,cMoeda)}
					If !lDireto
						MsgRun(STR0049,STR0050,bProc)//"Processando Cubos Contábeis"##"Cubo Contábil"
					Else
						Eval(bProc)
					EndIf
				Else
					For nTpSldA := 1 to Len(aTpSld)
						cTpSldA := aTpSld[nTpSldA]
						If cTpSldA == "0" // Saldo Orçado já foi calculado
							Loop
						EndIf
						bProc := {|| Ctb_RprCub(oConjCubos,aSM0,dDataIni,dDataFim,cTpSldA,cFilDe,cFilAte,!lMoedaEsp,cMoeda)}
						If !lDireto
							MsgRun(STR0049,STR0050,bProc)//"Processando Cubos Contábeis"##"Cubo Contábil"
						Else
							Eval(bProc)
						EndIf
					Next
				EndIf
			Endif
			lRet := .T.
		Endif
	Endif
	
	dbSelectArea("SM0")
	dbGoto(nReg)
	dbSelectArea("CT1")
	cFilAnt := cFilBack
	
	CT190LIBMV()
	
	// Atualiza o log de processamento   
	If lRecalculo .AND. l330Log
		oJourneyLog:llimpaSub := .F.
		oJourneyLog:cSubProc := 'MA330PROCESS'	
		M330PrcLog("FIM", , , ,cFilDe)
	Else
		ProcLogAtu("FIM")
	EndIf

	If FindFunction("CTBSERIALI")
		CTBSerialF("CTBPROC","OFF")
	EndIf
Endif

cFilAnt := cFilX

If lJobs .And. !(cTpSald == '0')
	UnLockByName("CTBA192_"+cFilLock)
EndIf

dbSelectArea("CT2")
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb190Proc
Reprocessamento - recalcula os saldos das Entidades Contabeis de acordo com os lancamentos contabeis 

@author Alvaro Camillo Neto

@param lDireto 	Flag para processamento sem tela. 
@param dDataIni 	Data Inicial
@param dDataFim	Data Final                                            
@param cFilDe 	Filial De                       
@param cFilAte 	Filial Ate			           
@param cTpSald 	Tipo de Saldo 
@param lMoedaEsp 	Define se é moeda especifica                       
@param cMoeda 	Moeda	
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ctb190Proc(oObj,dDataIni,dDataFim,cFilDe,cFilAte,cTpSald,lMoedaEsp,cMoeda,cFilX)

Local lFim := .F.

Default oObj				:= Nil
Default dDataIni			:= STOD("")
Default dDataFim			:= STOD("") 
Default cFilDe			:= ""  
Default cFilAte			:= ""
Default cTpSald			:= ""
Default lMoedaEsp			:= .F. 
Default cMoeda			:= "" 
Default cFilX				:= cFilAnt 

//
dDataIni := FirstDay(dDataIni)
dDataFim := LastDay(dDataFim)

While !lFim			
	lFim := xCtb190Proc(oObj,dDataIni,dDataFim,cFilDe,cFilAte,cTpSald,lMoedaEsp,cMoeda,cFilX)
	IF !lFim .and. !IsBlind()
		lFim := !MsgYesNo(STR0031)
		If lFim .And. Type('TITULO') # "U" .and. Titulo <> Nil
			If !("Rascunho"$Titulo)
				Titulo := alltrim(TITULO)+" - "+STR0032
			EndIf
		EndIf		   
	Endif
End  
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} xCtb190Proc
Reprocessamento - recalcula os saldos das Entidades Contabeis de acordo com os lancamentos contabeis 

@author Alvaro Camillo Neto

@param lDireto 	Flag para processamento sem tela. 
@param dDataIni 	Data Inicial
@param dDataFim	Data Final                                            
@param cFilDe 	Filial De                       
@param cFilAte 	Filial Ate			           
@param cTpSald 	Tipo de Saldo 
@param lMoedaEsp 	Define se é moeda especifica                       
@param cMoeda 	Moeda	
@param cFilX		cFilial
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function xCtb190Proc(oObj,dDataIni,dDataFim,cFilDe,cFilAte,cTpSald,lMoedaEsp,cMoeda,cFilX)
	
Local aCtbMoeda := {}
Local nInicio
Local nFinal
Local lCusto
Local lItem
Local lCLVL
Local nx := 0
Local lRet := .t.
Local lAtSldBase	:= Iif(SuperGetMV("MV_ATUSAL")== "S",.T.,.F.) 
Local nMin			:= 0
Local nMax			:= 0

lCusto		:= CtbMovSaldo("CTT")
lItem		:= CtbMovSaldo("CTD")
lCLVL		:= CtbMovSaldo("CTH")
	
If lMoedaEsp					// Moeda especifica
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")

		// Atualiza o log de processamento com o erro 
		ProcLogAtu("ERRO","NOMOEDA",Ap5GetHelp("NOMOEDA"))

		Return
	EndIf                  
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

For nx := nInicio to nFinal
	If GetCV7Date(cTpSald,StrZero(nx,2,0)) < dDataIni 
		dDataIni := GetCV7Date(cTpSald,StrZero(nx,2,0))+1
	EndIf
	PutCV7Date(cTpSald,StrZero(nx,2,0),dDataFim)
Next nx	

// Zera Saldos das Conta Contabeis
CtbZeraTod("CQ0",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.f.,,oObj)
	
// Zera Saldos de Centro de Custo
If lCusto
	// Tratamento para filiais compartilhadas			
	CtbZeraTod("CQ2",lMoedaEsp,cMOeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.f.,,oObj)
EndIf
	
// Zera Saldos de Item Contabil
If lItem
	// Tratamento para filiais compartilhadas
	CtbZeraTod("CQ4",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.f.,,oObj)
EndIf
	
// Zera Saldos de Classe de Valor
If lCLVL
	// Tratamento para filiais compartilhadas
	CtbZeraTod("CQ6",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.f.,,oObj)
EndIf

// Zera Saldos de Entidad 05
If lEntidad05
	// Tratamento para filiais compartilhadas
	CtbZeraTod("QL6",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.f.,,oObj)
EndIf

// Zera Saldos por Entidade
If lCLVL .Or. lItem .Or. lCusto .Or. lEntidad05
	// Tratamento para filiais compartilhadas
	CtbZeraTod("CQ8",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.f.,,oObj)
EndIf
	
// Zera Saldos dos Documentos
CtbZeraTod("CTC",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,1,.F.,.T.,oObj)
                                                       
//Rotina que chama a atualizacao de Saldos Basicos
Ct190SlBse(nInicio,nFinal,lClvl,lItem,lCusto,cTpSald,lMoedaEsp,cFilDe,cFilAte,dDataIni,dDataFim,oObj,nMin,nMax)

//Reprocessa totais por documento => atualiza CTC
Ctb190Doc(nInicio,nFinal,cFilDe,cFilAte,cTpSald,dDataIni,dDataFim,oObj)

//Atualiza os flags de conta ponte.
//CtbFlgPon(nInicio,nFinal,cFilDe,cFilAte,cTpSald,dDataIni,dDataFim,oObj)

If !lAtSldBase
   lRet := .T.
	For nx := nInicio to nFinal
		If GetCV7Date(cTpSald,StrZero(nx,2,0)) < dDataFim
			lRet := .F.
		EndIf
	Next nx
EndIf	
	
Return lRet
	
//-------------------------------------------------------------------
/*{Protheus.doc} CtbZeraTod
Redireciona para a rotina que zera as tabelas de saldo, dependendo da tabela escolhida

@author Alvaro Camillo Neto

@param cAlias 	Alias do Arquivo 
@param lMoedaEsp 	Define se eh moeda especifica
@param cMoeda		Moeda                           
@param cTpSald 	Tipo de Saldo                  
@param cFilDe 	Filial De                       
@param cFilAte 	Filial Ate			           
@param dDataIni 	Data Inicio                       
@param dDataFim 	Data Fim	
@param nOrder 	Ordem do Arquivo                     
@param lSoAlguns Define se grava todos os campos   
@param lLote 		Define se eh arquivo de lotes         
@param oObj 		Objeto utilizado no Processamento      


@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CtbZeraTod(cAlias,lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
Local aArea := GetArea()

If cAlias == "CT7" .Or. cAlias == "CQ0" .Or. cAlias == "CQ1"
	xCtbZera("CQ0",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
	xCtbZera("CQ1",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
ElseIf cAlias == "CT3" .Or. cAlias == "CQ2" .Or. cAlias == "CQ3"
	xCtbZera("CQ2",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
	xCtbZera("CQ3",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
ElseIf cAlias == "CT4" .Or. cAlias == "CQ4" .Or. cAlias == "CQ5"
	xCtbZera("CQ4",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
	xCtbZera("CQ5",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
ElseIf cAlias == "CTI" .Or. cAlias == "CQ6" .Or. cAlias == "CQ7"
	xCtbZera("CQ6",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
	xCtbZera("CQ7",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
ElseIf cAlias == "CTU" .Or. cAlias == "CQ8" .Or. cAlias == "CQ9"
	xCtbZera("CQ8",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
	xCtbZera("CQ9",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
ElseIf lEntidad05 .And. cAlias == "CV0" .Or. cAlias == "QL6" .Or. cAlias == "QL7"
	xCtbZera("QL6",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
	xCtbZera("QL7",lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
Else
	xCtbZera(cAlias,lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
EndIf	

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} xCtbZera
Zera os arquivos a serem posteriormente reprocessados 

@author Alvaro Camillo Neto

@param cAlias 	Alias do Arquivo 
@param lMoedaEsp 	Define se eh moeda especifica
@param cMoeda		Moeda                           
@param cTpSald 	Tipo de Saldo                  
@param cFilDe 	Filial De                       
@param cFilAte 	Filial Ate			           
@param dDataIni 	Data Inicio                       
@param dDataFim 	Data Fim	
@param nOrder 	Ordem do Arquivo                     
@param lSoAlguns Define se grava todos os campos   
@param lLote 		Define se eh arquivo de lotes         
@param oObj 		Objeto utilizado no Processamento      


@version P12
@since   20/02/2014
@return  Nil
@obs	 

*/
//-------------------------------------------------------------------

Static Function xCtbZera(cAlias,lMoedaEsp,cMoeda,cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,nOrder,lSoAlguns,lLote,oObj)
Local aSaveArea := GetArea()
Local lDelFisico	:=	GetNewPar('MV_CTB190D',.T.) 
Local cCond		:= ""	
Local cQuery	:= ""	
Local cZeraTudo	:= ""
Local cSqldel   := ""	
Local nDel		:= iif( TCGetDB() == "INFORMIX", 1024, 4096 )
Local lSai		:= .F.

lLote := Iif(lLote == Nil,.F.,lLote)

If ValType(oObj) == "O"
	oObj:SetRegua1(MAXPASSO)
EndIf


If lDelFisico
	&( cAlias )->( dbCloseArea() )
	dbSelectArea(cAlias) 
	
	cInicial := cAlias + "_"
	
	cZeraTudo := "cZeraTudo"
	
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName(cAlias)+ " ARQ "
	cQuery += "WHERE "
	
	If XFilial(cAlias,cFilDe) == XFilial(cAlias,cFilAte)
		cQuery += "ARQ."+cInicial+ "FILIAL = '"+XFilial(cAlias,cFilDe)+"' AND "
	Else
		cQuery += "ARQ."+cInicial+ "FILIAL BETWEEN '"+XFilial(cAlias,cFilDe)+"' AND '"+XFilial(cAlias,cFilAte)+"' AND "
	EndIf
	
	If dDataIni == dDataFim
		cQuery += "ARQ."+cInicial+"DATA = '"+DTOS(dDataIni)+"' AND "
	Else
		cQuery += "ARQ."+cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
	EndIf
	
	cQuery += "ARQ."+cInicial+"TPSALD='"+cTpSald+"'"
	
	If lMoedaEsp //Se for Moeda Especifica
		cQuery += " AND ARQ."+cInicial+ "MOEDA ='" + cMoeda+"'"
	EndIf
	
	cQuery += " ORDER BY RECNO"
	cQuery := Changequery(cQuery)
	
	If ( Select ( "cZeraTudo" ) > 0 )
		dbSelectArea ( "cZeraTudo" )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cZeraTudo,.T.,.F.)	
	
	If X3Usado("CTC_DOCHIS") .And. cAlias == "CTC" .And. X3Usado("CT5_DOCHIS") .And. CTC->(RecCount()) > 0
		lSoAlguns := .T.
	Endif
	
	If lSoAlguns		// Grava campos especificos
		cQuery := "UPDATE "
		cQuery += RetSqlName(cAlias)+" "
		cQuery += "SET "+ cAlias + "_DEBITO =  0 ,"
		cQuery += cAlias + "_CREDIT = 0 "
	Else
		cQuery := "DELETE FROM "
		cQuery += RetSqlName(cAlias) + " "
	Endif
	
	cQuery += "WHERE "
	If cFilDe == cFilAte
		cQuery += cInicial+ "FILIAL = '"+XFilial(cAlias,cFilDe)+"' "
	Else
		cQuery += cInicial+ "FILIAL BETWEEN '"+XFilial(cAlias,cFilDe)+"' AND '"+XFilial(cAlias,cFilAte)+"' "
	EndIf
	
	If dDataIni == dDataFim
		cQuery += " AND "+cInicial+"DATA = '"+DTOS(dDataIni)+"' "
	Else
		cQuery += " AND "+cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	EndIf
	If lMoedaEsp //Se for Moeda Especifica
		cQuery += " AND "+cInicial+ "MOEDA ='" + cMoeda +"' "
	EndIf
	
	If ! lSoAlguns		// Grava campos especificos
		cQuery += "AND "+cInicial+"TPSALD='"+cTpSald+"' "
	Endif
	
	lSai := .F.		
	  	While cZeraTudo->(!Eof()) .And. !lSai  
	
			nMin := (cZeraTudo)->RECNO
			
			cZeraTudo->(DbSkip(nDel))
		
		If cZeraTudo->(Eof())
			cChave := "AND R_E_C_N_O_>="+Str(nMin,10,0)
			lSai := .T.
		Else
			nMax := (cZeraTudo)->RECNO
			cChave := "AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		EndIf
		
		if TcSqlExec( cQuery + cChave ) <> 0
			UserException( STR0022 + RetSqlName(cAlias) ;
				+ CRLF + STR0023 + CRLF + TCSqlError() )
		endif
			cZeraTudo->(DbSkip())
		If ValType(oObj) == "O"
			oObj:IncRegua1(STR0012+ " - " + cAlias )//Zerando arquivos de Saldos...
		EndIf
	EndDo
	
	
	If cAlias = "CTC" .And. X3USADO("CTC_DOCHIS") .And. cPaisLoc = "EQU" // deleta se não existe no ct2 O SALDO por Documento.
		
		cQuery := "SELECT CTC_FILIAL, CTC_DATA, CTC_LOTE, CTC_SBLOTE, CTC_DOC, CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, "
		cQuery += " CT2_DOC FROM "
		cQuery += RetSqlName(cAlias) + " CTC ," + RetSqlName("CT2") + " CT2 "
		
		cQuery += "WHERE "
		If cFilDe == cFilAte
			cQuery += cInicial+ "FILIAL = '"+XFilial(cAlias,cFilDe)+"' "
		Else
			cQuery += cInicial+ "FILIAL BETWEEN '"+XFilial(cAlias,cFilDe)+"' AND '"+XFilial(cAlias,cFilAte)+"' "
		EndIf
		
		If dDataIni == dDataFim
			cQuery += " AND "+cInicial+"DATA = '"+DTOS(dDataIni)+"' "
		Else
			cQuery += " AND "+cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
		EndIf
		If lMoedaEsp //Se for Moeda Especifica
			cQuery += " AND "+cInicial+ "MOEDA ='" + cMoeda +"' "
		EndIf
		
		cQuery += " AND NOT EXISTS ( "
		cQuery += "SELECT CT2_FILIAL, CT2_LOTE, CT2_SBLOTE, CT2_DOC "
		cQuery += "FROM "+RetSqlName("CT2")+" CT2, " + RetSqlName("CTC")+" CTC "
		cQuery += "WHERE CT2.CT2_FILIAL = '"+xFilial("CT2")+"' AND "
		cQuery += " CT2.CT2_LOTE = CTC_LOTE AND "
		cQuery += " CT2.CT2_SBLOTE = CTC_SBLOTE AND "
		cQuery += " CT2.CT2_DOC = CTC_DOC )"
		
		If Select("cSqlDel") > 0
			dBSelectArea( "cSqlDel" )
			dBCloseArea()
		Endif
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cSqlDel",.T.,.F.)
		
		Do While !cSqlDel->(Eof())
			RecLock("cSqlDel", .F.)
			DbDelete()
			MsUnlock()
			SqlDel->(Dbskip())
		Enddo
		
	Endif
	
	// A tabela eh fechada para restaurar o buffer da aplicacao
	dbSelectArea(cAlias)
	dbCloseArea()
	ChkFile(cAlias)		// Abrir como compartilhado para permitir acesso de outros usuarios
	
	If ( Select ( "cZeraTudo" ) > 0 )
		dbSelectArea ( "cZeraTudo" )
		dbCloseArea ()
	Endif
Else
	//Se for CodeBase ou AS/400
	cInicial := cAlias + "->" + cAlias + "_"
	
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
	DbSeek(xFilial()+Dtos(dDataIni),.T.)
	While !Eof() .And. &(cInicial+"FILIAL") == xFilial() .And. ;
			&(cInicial+"DATA") <= dDataFim
		
		If lMoedaEsp						// Moeda Especifica
			If &(cInicial+"MOEDA") != cMoeda
				dbSkip()
				Loop
			EndIf
		EndIf
		If cTpSald <> D_PRELAN				// Tipo do Saldo
			If &(cInicial+"TPSALD") != cTpSald
				dbSkip()
				Loop
			EndIf
		EndIf
		
		RecLock(cAlias)
		If !lSoAlguns				// Grava todos os campos
			DbDelete()
		Else
			If !lSoAlguns				// Grava todos os campos
				&(cInicial+"ANTDEB")	:= 0
				&(cInicial+"ANTCRD")	:= 0
				&(cInicial+"ATUDEB")	:= 0
				&(cInicial+"ATUCRD")	:= 0
			EndIf
			&(cInicial+"DEBITO")	:= 0
			&(cInicial+"CREDIT")	:= 0
		Endif
		
		MsUnlock()
		dbSkip()
		If ValType(oObj) == "O"
			oObj:IncRegua1(STR0012+ " - " + cAlias )//Zerando arquivos de Saldos...
		EndIf
	EndDo
	
Endif
  

RestArea(aSaveArea)


Return


//-------------------------------------------------------------------
/*{Protheus.doc} Ct190CrTrb
Cria Arquivo de Trabalho para Gravar os movimentos.    

@author Alvaro Camillo Neto

@param nInicio 	Moeda Inicial 
@param nFinal 	Moeda Final
  
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct190CrTrb(nInicio,nFinal)
	
Local aCampos		:=  {}
Local cNomeArq		:= ""
Local aTamValor		:= ""	

Local cChave		:= ""
Local cArqInd		:= ""

aTamValor := TamSX3("CT2_VALOR")
	
aCampos := {{"FILIAL","C",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ),0},;
			{"DDATA","D",8,0},;
			{"CONTA","C",Len(CriaVar("CT1_CONTA")),0},;
			{"CUSTO","C",Len(CriaVar("CTT_CUSTO")),0},;
			{"ITEM","C",Len(CriaVar("CTD_ITEM")),0},;
			{"CLVL","C",Len(CriaVar("CTH_CLVL")),0},;             
			{"MOEDA","C",Len(CriaVar("CT2_MOEDLC")),0},;				
			{"DEBITO","N",aTamValor[1],aTamValor[2]},;				
			{"CREDITO","N",aTamValor[1],aTamValor[2]},;				
			{"DTLP","D",8,0},;                         				
			{"IDENT","C",3,0}}
	
If lEntidad05
	aAdd( aCampos , {"ENT05","C",Len(CriaVar("QL6_ENT05")),0} )
EndIf

If ( Select ( "TMP" ) <> 0 )
   dbSelectArea ( "TMP" )
   dbCloseArea ()
End
	
If _oCTBA1901 <> Nil
	_oCTBA1901:Delete()
	_oCTBA1901 := Nil
Endif

_oCTBA1901 := FWTemporaryTable():New( "TMP" )  
_oCTBA1901:SetFields(aCampos) 
If !lEntidad05
	_oCTBA1901:AddIndex("1", {"FILIAL","IDENT","CONTA","CUSTO","ITEM","CLVL","MOEDA","DDATA","DTLP"}) 
Else
	_oCTBA1901:AddIndex("1", {"FILIAL","IDENT","CONTA","CUSTO","ITEM","CLVL","ENT05","MOEDA","DDATA","DTLP"})
EndIf
//------------------
//Criação da tabela temporaria
//------------------
_oCTBA1901:Create()  
	
dbSelectArea("TMP")
dbSetOrder(1)	
	
Return cNomeArq
	
//-------------------------------------------------------------------
/*{Protheus.doc} Ct190GrTrb
Grava Arquivo de Trabalho para Gravar os movimentos.   

@author Alvaro Camillo Neto

@param cAlias		Alias
@param nInicio 	Moeda Inicial 
@param nFinal 	Moeda Final
@param cSpacCC	Variável vazia com o tamanho do centro de custo
@param cSpacIT	Variável vazia com o tamanho do item contábil
@param cSpacCL   	Variável vazia com o tamanho da classe de valor
  
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ct190GrTrb(cAlias,nInicio,nFinal,cSpacCC,cSpacIT,cSpacCL,cSpacE5)
	
Local cChave	:= ""
Local aSaveArea := GetArea()

DEFAULT cSpacCC := Space(Len(CUSTO))
DEFAULT cSpacIT := Space(Len(ITEM))
DEFAULT cSpacCL := Space(Len(CLVL))

If !lEntidad05
	If cAlias == 'CTI' .Or. cAlias == 'CTH' 
		cAlias := 'CTH' 
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+ITEM+CLVL+MOEDA+DTOS(cAtualiza->CT2_DATA)+DTOS(CT2_DTLP))	
	ElseIf cAlias == 'CT4' .Or. cAlias == 'CTD'
		cAlias := 'CTD' 
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+ITEM+cSpacCL+MOEDA+DTOS(CT2_DATA)+DTOS(CT2_DTLP))
	ElseIf cAlias == 'CT3' .Or. cAlias == 'CTT'  
		cAlias := 'CTT'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+cSpacIT+cSpacCL+MOEDA+DTOS(CT2_DATA)+DTOS(CT2_DTLP))
	ElseIf cAlias == 'CT7' .Or. cAlias == 'CT1' 
		cAlias := 'CT1'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+cSpacCC+cSpacIT+cSpacCL+MOEDA+DTOS(CT2_DATA)+DTOS(CT2_DTLP))
	Endif   
Else
	DEFAULT cSpacE5 := Space(Len(ENT05))

	If cAlias $ "CV0/QL6/QL7"
		cAlias := 'QL6'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+ITEM+CLVL+ENT05+MOEDA+DTOS(cAtualiza->CT2_DATA)+DTOS(CT2_DTLP))
	ElseIf cAlias == 'CTI' .Or. cAlias == 'CTH'
		cAlias := 'CTH'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+ITEM+CLVL+cSpacE5+MOEDA+DTOS(cAtualiza->CT2_DATA)+DTOS(CT2_DTLP))
	ElseIf cAlias == 'CT4' .Or. cAlias == 'CTD'
		cAlias := 'CTD'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+ITEM+cSpacCL+cSpacE5+MOEDA+DTOS(CT2_DATA)+DTOS(CT2_DTLP))
	ElseIf cAlias == 'CT3' .Or. cAlias == 'CTT'
		cAlias := 'CTT'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+CUSTO+cSpacIT+cSpacCL+cSpacE5+MOEDA+DTOS(CT2_DATA)+DTOS(CT2_DTLP))
	ElseIf cAlias == 'CT7' .Or. cAlias == 'CT1'
		cAlias := 'CT1'
		cChave	:= cAtualiza->(FILIAL+cAlias+CONTA+cSpacCC+cSpacIT+cSpacCL+cSpacE5+MOEDA+DTOS(CT2_DATA)+DTOS(CT2_DTLP))
	Endif
EndIf

dbSelectArea("TMP")   
If !lEntidad05 .And. cChave <> TMP->(FILIAL+IDENT+CONTA+CUSTO+ITEM+CLVL+MOEDA+DTOS(DDATA)+DTOS(DTLP))
	/// SE O RESULTADO DA QUERY (CT2) REFERE-SE A OUTRO GRUPO DE ENTIDADES
	dbSetOrder(1)
	If !dbSeek(cChave,.F.)
		Reclock("TMP",.T.)
		TMP->FILIAL			:= 	cAtualiza->FILIAL
		TMP->DDATA			:= 	cAtualiza->CT2_DATA
		
		If cAlias $ 'CTH'
			TMP->CLVL	:= cAtualiza->CLVL
		EndIf
		
		If cAlias $ 'CTH/CTD'
			TMP->ITEM	:= 	cAtualiza->ITEM
		EndIf
		
		If cAlias $ 'CTH/CTD/CTT'
			TMP->CUSTO 	:= 	cAtualiza->CUSTO
		Endif
		
		TMP->CONTA		:= 	cAtualiza->CONTA
		TMP->DTLP		:=	cAtualiza->CT2_DTLP 
		TMP->IDENT		:= 	cAlias
		TMP->MOEDA		:=  cAtualiza->MOEDA	
	Else
		Reclock("TMP",.F.)	
	Endif
ElseIf lEntidad05 .And. cChave <> TMP->(FILIAL+IDENT+CONTA+CUSTO+ITEM+CLVL+ENT05+MOEDA+DTOS(DDATA)+DTOS(DTLP))
	/// SE O RESULTADO DA QUERY (CT2) REFERE-SE A OUTRO GRUPO DE ENTIDADES
	dbSetOrder(1)
	If !dbSeek(cChave,.F.)
		Reclock("TMP",.T.)
		TMP->FILIAL			:= 	cAtualiza->FILIAL
		TMP->DDATA			:= 	cAtualiza->CT2_DATA

		If cAlias $ 'QL6'
			TMP->ENT05	:= cAtualiza->ENT05
		EndIf
		
		If cAlias $ 'CTH/QL6'
			TMP->CLVL	:= cAtualiza->CLVL
		EndIf
		
		If cAlias $ 'CTH/CTD/QL6'
			TMP->ITEM	:= 	cAtualiza->ITEM
		EndIf
		
		If cAlias $ 'CTH/CTD/CTT/QL6'
			TMP->CUSTO 	:= 	cAtualiza->CUSTO
		Endif
		
		TMP->CONTA		:= 	cAtualiza->CONTA
		TMP->DTLP		:=	cAtualiza->CT2_DTLP 
		TMP->IDENT		:= 	cAlias
		TMP->MOEDA		:=  cAtualiza->MOEDA	
	Else
		Reclock("TMP",.F.)	
	Endif
Else	/// SE O RESULTADO DA QUERY (CT2) REFERE-SE AO MESMO GRUPO DE ENTIDADES (APENAS D/C DIFERENTE)
	Reclock("TMP",.F.)	
EndIf

If cAtualiza->TIPO  == '1'	//Se for debito
	TMP->DEBITO		+= cAtualiza->VALOR
ElseIf cAtualiza->TIPO  == '2'//Se for credito
	TMP->CREDITO  	+= cAtualiza->VALOR
Endif
MsUnlock()	                             
RestArea(aSaveArea)
	
Return
	
//-------------------------------------------------------------------
/*{Protheus.doc} Ct190GrSld
Varre o arquivo temporario para gravar os saldos.

@author Alvaro Camillo Neto

@param nInicio	Moeda Inicial   
@param nFinal  	Moeda Final                             
@param cTpSald 	Tipo de Saldo            	                        
@param lMoedaEsp 	Defina se eh moeda especifica                       
@param cFilDe 	Filial De                                           
@param cFilAte 	Filial Ate                                          
@param oObj		Objeto utilizado na regua de Processamento                                           
                
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct190GrSld(nInicio,nFinal,cTpSald,lMoedaEsp,cFilDe,cFilAte,oObj,dDataIni,dDataFim,lCusto,lItem,lClVl)					

Local lObj			:= oObj <> Nil
Local lRedStorn  	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn

If lObj
	oObj:SetRegua2(TMP->(LastRec()))
Endif	

aSldAnt := {{0,0}}

//Percorre arquivo temporario para gravar os saldos 
dbSelectArea("TMP")
dbSetOrder(1)
dbGotop()

While TMP->(!Eof())    	                        		     

	If lRedStorn                                                                               
		If TMP->DEBITO <> 0 .Or. TMP->CREDITO <> 0
			Ct190Grava(cTpSald)	//Grava saldos 
		EndIf
	Else
		If TMP->DEBITO > 0 .Or. TMP->CREDITO > 0
			Ct190Grava(cTpSald)	//Grava saldos 
		EndIf
	EndIf
	
	TMP->(dbSkip())
	If lObj
		oObj:IncRegua2(STR0008)//Atualizando saldos... 
	Endif
EndDo
If lCusto .Or. lItem  .Or. lClVl .Or. lEntidad05
	Ctb190CQ8(cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,lCusto,lItem,lClVl)
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ct190Grava
Prepara a gravação dos saldos nas tabelas

@author Alvaro Camillo Neto

@param cTpSald	Tipo de Saldo    
          	                                      
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ct190Grava(cTpSald)
	
Local cArqBase	:= ""
Local dDiaMes		:= STOD("")
Local dDia			:= STOD("")
Local aSaveArea	:= GetArea() 
Local cChaveMes	:= "" 
Local cChaveDia	:= "" 
Local cLp			:= ""
Local cCodigo		:= ""
Local lAtuEnt		:= .F.

cArqBase 	:= TMP->IDENT
dDiaMes	:= LastDay(TMP->DDATA)
dDia		:= TMP->DDATA

If !Empty(TMP->DTLP)
	cLp := "Z"
Else
	cLp := "N"
EndIf

If cArqBase == "CT1"
	cChaveMes  	:= TMP->(FILIAL+DTOS(dDiaMes)+CONTA+MOEDA+cTpSald+cLp)
	cChaveDia  	:= TMP->(FILIAL+DTOS(dDia)   +CONTA+MOEDA+cTpSald+cLp)
ElseIf cArqBase == "CTT"
	cChaveMes  	:= TMP->(FILIAL+DTOS(dDiaMes)+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cChaveDia  	:= TMP->(FILIAL+DTOS(dDia)   +CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cCodigo		:= TMP->CUSTO
	lAtuEnt 		:= .T.
ElseIf cArqBase == "CTD"
	cChaveMes  	:= TMP->(FILIAL+DTOS(dDiaMes)+ITEM+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cChaveDia  	:= TMP->(FILIAL+DTOS(dDia)   +ITEM+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cCodigo		:= TMP->ITEM
	lAtuEnt 		:= .T.
ElseIf cArqBase == "CTH"
	cChaveMes  	:= TMP->(FILIAL+DTOS(dDiaMes)  +CLVL+ITEM+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cChaveDia  	:= TMP->(FILIAL+DTOS(dDia)     +CLVL+ITEM+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cCodigo		:= TMP->CLVL
	lAtuEnt 		:= .T.
ElseIf lEntidad05 .And. cArqBase $ "CV0/QL6/QL7"
	cArqBase := "QL6"
	cChaveMes  	:= TMP->(FILIAL+DTOS(dDiaMes)  +ENT05+CLVL+ITEM+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cChaveDia  	:= TMP->(FILIAL+DTOS(dDia)     +ENT05+CLVL+ITEM+CUSTO+CONTA+MOEDA+cTpSald+cLp)
	cCodigo		:= TMP->ENT05
	lAtuEnt 		:= .T.
EndIf

xCt190Grv(cArqBase,cChaveMes,cChaveDia,cTpSald,cLp)

//Se a data de apuracao de lucros/perdas nao estiver vazia, significa
//que esse lancamento eh um lancamento de zeramento. 
//Chama a rotina de atualizacao de Flag de Lucros/Perdas, para atualizar
//os saldos com data anterior a esses lancamentos.
If !Empty(TMP->DTLP)   // BUSCAR DATA ANTERIOR DE APURACAO DE ZERAMENTO  e dDTLPAnt
	dDTLPAnt := CT190UltZera( TMP->DTLP, cTpsald, TMP->MOEDA, @cLp)
	If !Empty(dDTLPAnt) .and. (cLp == "S") /* Só flag com 'S' e DTLP preenchido se existir Zeramento anterior.*/ 
		Ct190FlgLP(TMP->FILIAL, TMP->IDENT, TMP->CONTA, TMP->CUSTO, TMP->ITEM, TMP->CLVL, dDTLPAnt,cTpsald,TMP->DTLP, TMP->MOEDA)
		cLp := ' '
	ElseIf lEntidad05
		Ct190FlgLP(TMP->FILIAL, TMP->IDENT, TMP->CONTA, TMP->CUSTO, TMP->ITEM, TMP->CLVL, dDTLPAnt,cTpsald,TMP->DTLP, TMP->MOEDA , , , TMP->ENT05)
	EndIf
EndIf

RestArea(aSaveArea)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} xCt190Grv
Grava os saldos nas tabelas

@author Alvaro Camillo Neto

@param cArqBase	Arquivo de Base para atualização 
( CT1 = Conta, CTT = Centro de Custo, CTD = Item Contábil , CTH = Classe de Valor , CTU = Entidade )   
@param cChaveMes	Chave para buscar o saldo mensal
@param cChaveDia	Chave para buscar o saldo diário           	                                      

                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function xCt190Grv(cArqBase,cChaveMes,cChaveDia,cTpSald,cLp)

Local aArq			:= Array(2)
Local dDiaMes		:= STOD("")
Local dDia			:= STOD("")
Local nX			:= 0
Local aSaveArea	:= GetArea() 
Local cArquivo	:= "" 
Local cChave		:= "" // Chave Utilizada para encontrar o saldo mensal

Local dData		:= STOD("")   
Local lNovo		:= .F.

dDiaMes	:= LastDay(TMP->DDATA)
dDia		:= TMP->DDATA

If cArqBase == "CT1"
	aArq[1]		:= "CQ0"
	aArq[2] 		:= "CQ1"
ElseIf cArqBase == "CTT"
	aArq[1] 		:= "CQ2"
	aArq[2] 		:= "CQ3"
ElseIf cArqBase == "CTD"
	aArq[1] 		:= "CQ4"
	aArq[2] 		:= "CQ5"
ElseIf cArqBase == "CTH"
	aArq[1] 		:= "CQ6"
	aArq[2] 		:= "CQ7"
ElseIf lEntidad05 .And. cArqBase $ "CV0/QL6/QL7"
	cArqBase := "QL6"
	aArq[1] 		:= "QL6"
	aArq[2] 		:= "QL7"
EndIf
		
For nX := 1 to 2
	cArquivo := aArq[nX]
	dbSelectArea(cArquivo)
	(cArquivo)->(dbSetOrder(1))
	
	If nX == 1 // Saldo Mensal
		dData := dDiaMes
		cChave:= cChaveMes
	Else // Saldo Diário
		dData := dDia
		cChave:= cChaveDia
	EndIf
	
	If (cArquivo)->(MsSeek(cChave))
		lNovo := .F.
	Else
		lNovo := .T.
	EndIf
	
	RecLock(cArquivo,lNovo)
	
	&(cArquivo+"->"+cArquivo+"_FILIAL")		:= TMP->FILIAL
	&(cArquivo+"->"+cArquivo+"_MOEDA")			:= TMP->MOEDA
	&(cArquivo+"->"+cArquivo+"_TPSALD")		:= cTpSald
	
	&(cArquivo+"->"+cArquivo+"_DATA")			:= dData
	&(cArquivo+"->"+cArquivo+"_STATUS")		:= '1'
	&(cArquivo+"->"+cArquivo+"_LP")				:= cLp
	

	&(cArquivo+"->"+cArquivo+"_CONTA")			:= TMP->CONTA
	If cArqBase== 'CTH'
		&(cArquivo+"->"+cArquivo+"_CLVL")		:= TMP->CLVL
		&(cArquivo+"->"+cArquivo+"_ITEM")		:= TMP->ITEM
		&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= TMP->CUSTO
	ElseIf cArqBase== 'CTD'
		&(cArquivo+"->"+cArquivo+"_ITEM")		:= TMP->ITEM
		&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= TMP->CUSTO
	ElseIf cArqBase == 'CTT'
		&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= TMP->CUSTO
	ElseIf lEntidad05 .And. cArqBase == 'QL6'
		&(cArquivo+"->"+cArquivo+"_ENT05")		:= TMP->ENT05
		&(cArquivo+"->"+cArquivo+"_CLVL")		:= TMP->CLVL
		&(cArquivo+"->"+cArquivo+"_ITEM")		:= TMP->ITEM
		&(cArquivo+"->"+cArquivo+"_CCUSTO")		:= TMP->CUSTO
	EndIf

	
	If !Empty(TMP->DTLP)
		&(cArquivo+"->"+cArquivo+"_DTLP")		:= TMP->DTLP
	EndIf
	
	If lNovo
		&(cArquivo+"->"+cArquivo+"_DEBITO")	:= TMP->DEBITO
		&(cArquivo+"->"+cArquivo+"_CREDIT")	:= TMP->CREDITO
	Else
		&(cArquivo+"->"+cArquivo+"_DEBITO")	+= TMP->DEBITO
		&(cArquivo+"->"+cArquivo+"_CREDIT")	+= TMP->CREDITO
	EndIf
	
	MsUnlock()
	
Next nX


RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb190Doc
Reprocessamento - refaz os arquivos de saldo por documento

@author Alvaro Camillo Neto

@param nInicio	Moeda Inicial   
@param nFinal  	Moeda Final  
@param cFilDe 	Filial De                                           
@param cFilAte 	Filial Ate                             
@param cTpSald 	Tipo de Saldo            	                        
@param dDataIni 	Data Inicial
@param dDataFim 	Data Final                                        
@param oObj		Objeto utilizado na regua de Processamento                                           
                
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctb190Doc(nInicio,nFinal,cFilDe,cFilAte,cTpSald,dDataIni,dDataFim,oObj)
	
Local cQuery		:= ""
Local cRepDoc	 	:= ""
Local aStru			:= {}
Local cChave
Local nMvSoma		:= Getmv("MV_SOMA") //Determina se o lancam. tipo 3 ira ser somado 1 ou 2 vezes
Local ni
Local lObj			:= ValType(oObj) == "O"
Local lUsaDOCHIS 	:= X3USADO("CTC_DOCHIS") .And. X3USADO("CT5_DOCHIS")

        	
cRepDoc:= "cRepDoc"
cQuery := "SELECT CT2_DC TIPO, CT2_FILIAL FILIAL,CT2_DATA, CT2_LOTE LOTE, CT2_SBLOTE SBLOTE, CT2_DOC DOC, "
cQuery += "CT2_MOEDLC MOEDA, SUM(CT2_VALOR) VALOR, CT2_LP LP, CT2_SEQLAN SEQ "
cQuery += "FROM "+RetSqlName("CT2")+" CT2 "

If cFilDe == cFilAte
	cQuery += "WHERE CT2.CT2_FILIAL = '"+XFilial("CT2",cFilDe)+"' AND "
Else
	cQuery += "WHERE CT2.CT2_FILIAL BETWEEN '"+XFilial("CT2",cFilDe)+"' AND '"+XFilial("CT2",cFilAte)+"' AND "
EndIf

If dDataIni == dDataFim
	cQuery += "CT2.CT2_DATA = '"+DTOS(dDataIni)+"' AND "	/// ALTERADA ORDEM P/ ATENDER INDICE 1
Else
	cQuery += "CT2.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "	/// ALTERADA ORDEM P/ ATENDER INDICE 1
EndIf
cQuery += "CT2.CT2_TPSALD='"+cTpSald+"' AND "

If nInicio == nFinal
	cQuery += "CT2.CT2_MOEDLC = '"+StrZero(nInicio,2)+"' AND "
Else
	cQuery += "CT2.CT2_MOEDLC BETWEEN '"+StrZero(nInicio,2)+"' AND '"+StrZero(nFinal,2)+"' AND "
EndIf

cQuery += " D_E_L_E_T_= ' ' "
cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC,CT2_DC, CT2_MOEDLC, CT2_LP, CT2_SEQLAN"
cQuery += " ORDER BY "
If Upper(TCGetDb()) == "INFORMIX"
	cQuery += "2,3,4,5,6,1,7"
Else
	cQuery += "CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC,CT2_DC, CT2_MOEDLC, CT2_LP, CT2_SEQLAN"
EndIf
cQuery := Changequery(cQuery)

dbSelectArea("CT2")
dbCloseArea()

If ( Select ( "cRepDoc" ) <> 0 )
	dbSelectArea ( "cRepDoc" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cRepDoc,.T.,.F.)

aStru := CT2->(dbStruct())
For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		Do Case
		Case Subs(aStru[ni,1],1,9) == "CT2_VALOR"
			TCSetField(cRepDoc,"VALOR", aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Case Subs(aStru[ni,1],1,8) == "CT2_DATA" .And. Subs(aStru[ni,1],1,10) <> "CT2_DATATX"
			TCSetField(cRepDoc, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		EndCase
	Endif
Next ni


dbSelectArea(cRepDoc)
cChave	:= ""
//Gravacao do saldo por documento
While !Eof()
	//So ira gravar saldo por documento para a moeda do lancamento
	dbSelectArea("CTC")
	dbSetOrder(1)
	If !MsSeek(cRepDoc->FILIAL+Dtos(cRepDoc->CT2_DATA)+cRepDoc->LOTE+cRepDoc->SBLOTE+cRepDoc->DOC+cRepDoc->MOEDA+cTpsald)
		Reclock("CTC",.T.)
		CTC->CTC_FILIAL 	:= cRepDoc->FILIAL
		CTC->CTC_MOEDA		:= cRepDoc->MOEDA
		CTC->CTC_TPSALD		:= cTpsald
		CTC->CTC_DATA		:= cRepDoc->CT2_DATA
		CTC->CTC_LOTE		:= cRepDoc->LOTE
		CTC->CTC_SBLOTE		:= cRepDoc->SBLOTE
		CTC->CTC_DOC		:= cRepDoc->DOC
		CTC->CTC_STATUS	:= '1'
		If cRepDoc->TIPO $ '1/3'
			CTC->CTC_DEBITO	:= cRepDoc->VALOR
		EndIf
		If cRepDoc->TIPO $ '2/3'
			CTC->CTC_CREDIT	:= cRepDoc->VALOR
		EndIf
		If cRepDoc->TIPO == '3'
			If nMvSoma == 1
				CTC->CTC_DIG := cRepDoc->VALOR
			ElseIf nMvSoma == 2
				CTC->CTC_DIG := 2*(cRepDoc->VALOR)
			EndIf
		Else
			CTC->CTC_DIG := cRepDoc->VALOR
		EndIf
		
		If cPaisLoc $ "EQU|ARG" .And. lUsaDOCHIS
			CTC->CTC_DOCHIS := Posicione("CT5", 1, xFilial("CT5") + cRepDoc->LP + cRepDoc->SEQ, "CT5_DOCHIS")
		Endif
		
		MsUnlock()
	Else
		Reclock("CTC",.F.)
		If cRepDoc->TIPO $ '1/3'
			CTC->CTC_DEBITO	+= cRepDoc->VALOR
		EndIf
		If cRepDoc->TIPO $ '2/3'
			CTC->CTC_CREDIT	+= cRepDoc->VALOR
		EndIf
		If cRepDoc->TIPO  == '3'
			If nMvSoma == 1
				CTC->CTC_DIG += cRepDoc->VALOR
			ElseIf nMvSoma == 2
				CTC->CTC_DIG += 2*(cRepDoc->VALOR)
			EndIf
		Else
			CTC->CTC_DIG += cRepDoc->VALOR
		EndIf
		
		If cPaisLoc $ "EQU|ARG" .And. lUsaDOCHIS
			
			If Empty(CTC->CTC_DOCHIS)
				CTC->CTC_DOCHIS := Posicione("CT5", 1, xFilial("CT5") + cRepDoc->LP + cRepDoc->SEQ , "CT5_DOCHIS")
			Endif
			
		Endif
		
		MsUnlock()
	Endif
	
	dbSelectArea(cRepDoc)
	cChave := cRepDoc->FILIAL+Dtos(cRepDoc->CT2_DATA)+cRepDoc->LOTE+cRepDoc->SBLOTE+cRepDoc->DOC+cRepDoc->MOEDA+cTpsald
	dbSkip()
	If lObj
		oObj:IncRegua2(STR0011)//Atualizando saldos por documento...
	Endif
EndDo

If ( Select ( "cRepDoc" ) <> 0 )
	dbSelectArea ( "cRepDoc" )
	dbCloseArea ()
Endif

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ct190SlBse
Chama as rotinas de atualizacao de Saldos Basicos.

@author Alvaro Camillo Neto

@param nInicio	Moeda Inicial   
@param nFinal  	Moeda Final     
@param lClvl 	 	Indica se utiliza Classe de Valor                   
@param lItem	 	Indica se utiliza Item                              
@param lCusto	 	Indica se utiliza c.Custo	                        
@param cTpSald 	Tipo de Saldo            	                        
@param lMoedaEsp 	Defina se eh moeda especifica                       
@param cFilDe 	Filial De                                           
@param cFilAte 	Filial Ate                                          
@param dDataIni 	Data Inicial                                        
@param dDataFim 	Data Final                                                           
@param oObj		Objeto utilizado na regua de Processamento          
@param nMin		Numero do menor Recno                               
@param nMax		Numero do maior Recno                               
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Ct190SlBse(nInicio,nFinal,lClvl,lItem,lCusto,cTpSald,lMoedaEsp,cFilDe,cFilAte,dDataIni,dDataFim,oObj,nMin,nMax)        

Local aSaveArea	:= GetArea()
Local cArqTrb	:= ""
Local lObj		:= ValType(oObj) == "O"

If lObj
	oObj:IncRegua1(STR0028)//"Totalizando Lançamentos... CT2"
EndIf

//Cria arquivo de Trabalho
Ct190CrTrb(nInicio,nFinal)
	
//Monta query do CT2 a partir do CT2
Ct190Query(cFilDe,cFilAte,dDataIni,dDataFim,nInicio,nFinal,cTpSald,lCusto,lItem,lClVl)

If lObj
	oObj:IncRegua1(STR0009)//"Atualizando Arq. de Trabalho... "
EndIf

//Atualiza arquivo de trabalho	    
Ct190AtTrb(nInicio,nFinal,lCusto,lItem,lClVl,oObj)

If lObj
	oObj:IncRegua1(STR0027)//"Atualizando Saldos..."
EndIf

//Grava os saldos nos arquivos de saldos
Ct190GrSld(nInicio,nFinal,cTpSald,lMoedaEsp,cFilDe,cFilAte,oObj,dDataIni,dDataFim,lCusto,lItem,lClVl)					

If Select("TMP") != 0
	dbSelectArea("TMP")
	dbCloseArea()
EndIf

//Deleta tabela temporaria criada no banco de dados através da classe FwTemporaryTable
If _oCTBA1901 <> Nil
	_oCTBA1901:Delete()
	_oCTBA1901 := Nil
Endif

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ct190Query
Monta as querys a partir do CT2.

@author Alvaro Camillo Neto

@param cFilDe 	Filial De                                           
@param cFilAte 	Filial Ate 
@param dDataIni 	Data Inicial                                        
@param dDataFim 	Data Final   
@param nInicio	Moeda Inicial   
@param nFinal  	Moeda Final  
@param cTpSald 	Tipo de Saldo 
@param lCusto	 	Indica se utiliza c.Custo	                     
@param lItem	 	Indica se utiliza Item                              
@param lClvl 	 	Indica se utiliza Classe de Valor                                	                        
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct190Query(cFilDe,cFilAte,dDataIni,dDataFim,nInicio,nFinal,cTpSald,lCusto,lItem,lClVl)

Local cCond			:= ""
Local aStru			:= ""
Local cAtualiza		:= ""
Local cQuery		:= ""
Local ni

cCond	:=	" (CT2.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"') AND "

//Query com os lancamentos
cAtualiza := "cAtualiza"
If TCGetDb() == "POSTGRES"
	cQuery := "SELECT CHAR(1) '1' TIPO, CT2_FILIAL FILIAL, CT2_DATA, CT2_DEBITO CONTA, "
Else
	cQuery := "SELECT '1' TIPO, CT2_FILIAL FILIAL, CT2_DATA, CT2_DEBITO CONTA, "
EndIF
cQuery += "CT2_CCD CUSTO, CT2_ITEMD ITEM, CT2_CLVLDB CLVL, CT2_MOEDLC MOEDA, CT2_DTLP, SUM(CT2_VALOR) VALOR "
If lEntidad05
	cQuery += ", CT2_EC05DB ENT05 "
EndIf
cQuery += " FROM "+RetSqlName("CT2")+" CT2 "
If cFilDe == cFilAte
	cQuery += "WHERE CT2.CT2_FILIAL = '"+XFilial("CT2",cFilDe)+"' AND "
Else
	cQuery += "WHERE CT2.CT2_FILIAL BETWEEN '"+XFilial("CT2",cFilDe)+"' AND '"+XFilial("CT2",cFilAte)+"' AND "
EndIf
cQuery += "(CT2.CT2_DC = '1' OR CT2.CT2_DC = '3') AND "
cQuery += cCond
cQuery += "CT2.CT2_TPSALD='"+cTpSald+"' AND "
If nInicio == nFinal
	cQuery += "CT2.CT2_MOEDLC = '"+StrZero(nInicio,2)+"' AND "
Else
	cQuery += "CT2.CT2_MOEDLC BETWEEN '"+StrZero(nInicio,2)+"' AND '"+StrZero(nFinal,2)+"' AND "
EndIf
cQuery += " D_E_L_E_T_= ' ' "
If !lEntidad05
	cQuery += " GROUP BY CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_MOEDLC, CT2_DATA, CT2_DTLP"
Else
	cQuery += " GROUP BY CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_EC05DB, CT2_MOEDLC, CT2_DATA, CT2_DTLP"
EndIf
cQuery += " UNION "
If TCGetDb() == "POSTGRES"
	cQuery += "SELECT CHAR(1) '2' TIPO, CT2_FILIAL FILIAL, CT2_DATA, CT2_CREDIT CONTA, "
Else
	cQuery += "SELECT '2' TIPO, CT2_FILIAL FILIAL, CT2_DATA, CT2_CREDIT CONTA, "
EndIf
cQuery += "CT2_CCC CUSTO, CT2_ITEMC ITEM, CT2_CLVLCR CLVL, CT2_MOEDLC MOEDA, CT2_DTLP, SUM(CT2_VALOR) VALOR "
If lEntidad05
	cQuery += ", CT2_EC05CR ENT05 "
EndIf
cQuery += " FROM "+RetSqlName("CT2")+" CT2 "
If cFilDe == cFilAte
	cQuery += "WHERE CT2.CT2_FILIAL = '"+XFilial("CT2",cFilDe)+"' AND "
Else
	cQuery += "WHERE CT2.CT2_FILIAL BETWEEN '"+XFilial("CT2",cFilDe)+"' AND '"+XFilial("CT2",cFilAte)+"' AND "
EndIf
cQuery += "(CT2.CT2_DC = '2' OR CT2.CT2_DC = '3') AND "
cQuery += cCond
cQuery += "CT2.CT2_TPSALD='"+cTpSald+"' AND "
If nInicio == nFinal
	cQuery += "CT2.CT2_MOEDLC = '"+StrZero(nInicio,2)+"' AND "
Else
	cQuery += "CT2.CT2_MOEDLC BETWEEN '"+StrZero(nInicio,2)+"' AND '"+StrZero(nFinal,2)+"' AND "
EndIf
cQuery += " D_E_L_E_T_= ' ' "
If !lEntidad05
	cQuery += " GROUP BY CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_MOEDLC, CT2_DATA, CT2_DTLP"
Else
	cQuery += " GROUP BY CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_EC05CR, CT2_MOEDLC, CT2_DATA, CT2_DTLP"
EndIf
cQuery += " ORDER BY "
If Upper(alltrim (TCGetDb())) $ "INFORMIX/OPENEDGE"
	//cQuery += "2,3,4,5,6,7"
	If cFilDe <> cFilAte
		cQuery += "2,"
	EndIf
	cQuery += "1,4,5,6,7"
	If lEntidad05
		cQuery += ",11"
	EndIf
	If dDataIni <> dDataFim
		cQuery += ",3"
	EndIf
Else
	//cQuery += "FILIAL, CONTA, CUSTO, ITEM, CLVL"
	If cFilDe <> cFilAte
		cQuery += "FILIAL,"
	EndIf
	cQuery += "CONTA, CUSTO, ITEM, CLVL, TIPO"
	If lEntidad05
		cQuery += ", ENT05"
	EndIf
	If dDataIni <> dDataFim
		cQuery += ",CT2_DATA"
	EndIf
EndIf
cQuery := Changequery(cQuery)

dbSelectArea("CT2")
dbCloseArea()

If ( Select ( "cAtualiza" ) <> 0 )
	dbSelectArea ( "cAtualiza" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAtualiza,.T.,.F.)

aStru := CT2->(dbStruct())

For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		If Subs(aStru[ni,1],1,9) == "CT2_VALOR"
			TCSetField(cAtualiza,"VALOR", aStru[ni,2],aStru[ni,3],aStru[ni,4])
		ElseIf Subs(aStru[ni,1],1,8) == "CT2_DATA" .And. Subs(aStru[ni,1],1,10) <> "CT2_DATATX"
			TCSetField(cAtualiza, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		ElseIf Subs(aStru[ni,1],1,8) == "CT2_DTLP"
			TCSetField(cAtualiza, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		EndIf
	EndIF
Next ni

		
Return		


//-------------------------------------------------------------------
/*{Protheus.doc} Ct190AtTRb
Varre query do CT2,para chamar rotina de Grav. do TRB.

@author Alvaro Camillo Neto

@param nInicio	Moeda Inicial   
@param nFinal  	Moeda Final     
@param lClvl 	 	Indica se utiliza Classe de Valor                   
@param lItem	 	Indica se utiliza Item                              
@param lCusto	 	Indica se utiliza c.Custo	                                  
@param oObj		Objeto utilizado na regua de Processamento          
                              
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ct190AtTrb(nInicio,nFinal,lCusto,lItem,lClVl,oObj)

Local cSpacCC 	:= ""
Local cSpacIT 	:= ""
Local cSpacCL 	:= ""
Local cSpacE5 	:= ""
Local lObj 		:= ValType(oObj) == "O"
Local lEntidade	:= .F.
Local nQtdReg	:= 0

If lObj
	oObj:SetRegua2(cAtualiza->(LastRec()))
Endif

dbSelectArea("TMP")
dbSetOrder(1)

cSpacCC := Space(Len(TMP->CUSTO))
cSpacIT := Space(Len(TMP->ITEM))
cSpacCL := Space(Len(TMP->CLVL))

If lEntidad05
	cSpacE5 := Space(Len(TMP->ENT05))
EndIf

dbSelectArea("cAtualiza")
cAtualiza->(dbGoTop())
//Gravacao do arquivo temporario ref. os saldos de conta, item, c.custo e cl. valor

While cAtualiza->(!Eof())
	
	nQtdReg ++
	//Guarda os movimentos por Data/Conta/C.custo/Item/Cl.Valor/Entidad 05
	If lEntidad05 .And. !Empty(cAtualiza->ENT05)
		Ct190GrTrb("QL6",nInicio,nFinal,cSpacCC,cSpacIT,cSpacCL,cSpacE5)
		lEntidade	:= .T.
	EndIf

	//Guarda os movimentos por Data/Conta/C.custo/Item/Cl.Valor
	If lClVl .And. !Empty(cAtualiza->CLVL)			
		Ct190GrTrb("CTH",nInicio,nFinal,cSpacCC,cSpacIT,cSpacCL)
		lEntidade	:= .T.
	EndIf
			
	//Guarda os movimentos por Data/Conta/C.custo/Item
	If lItem .And. !Empty(cAtualiza->ITEM)			
		Ct190GrTrb("CTD",nInicio,nFinal,cSpacCC,cSpacIT,cSpacCL)
		lEntidade	:= .T.
	Endif
			
	//Guarda os movimentos por Data/Conta/CC
	If lCusto .And. !Empty(cAtualiza->CUSTO)			
		Ct190GrTrb("CTT",nInicio,nFinal,cSpacCC,cSpacIT,cSpacCL)
		lEntidade	:= .T.
	EndIf
		
	//Guarda os movimentos por Data/Conta
	Ct190GrTrb("CT1",nInicio,nFinal,cSpacCC,cSpacIT,cSpacCL)    			
			
	dbSelectArea("cAtualiza")			
	dbSkip()
	If lObj
		oObj:IncRegua2(STR0009) //"Atualizando arq. de trabalho..."
	Endif
EndDo

//Metrica - Qtd Registros
If __lMetric
	//Chamar metrica passando nQtdReg e sem nStart pra capturar apenas a qtd de registros
	CTB190Metrics("02" /*cEvent*/, /* nStart */, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, nQtdReg /* nQtdReg */)
EndIf	


If ( Select ( "cAtualiza" ) <> 0 )
	dbSelectArea ( "cAtualiza" )
	dbCloseArea ()
Endif
		
Return


//-------------------------------------------------------------------
/*{Protheus.doc} Ct190FlgLP
Atualiza os flags dos saldos ref. lucros/perdas.	

@author Alvaro Camillo Neto

@param cFilX		Filial de processamento   
@param cAlias		Arquivo de Base para atualização 
( CT1 = Conta, CTT = Centro de Custo, CTD = Item Contábil , CTH = Classe de Valor , CTU = Entidade )  
@param cConta		Conta Contábil   
@param cCusto		Centro de Custo  
@param cItem		Item Contábil   
@param cClvl		Classe de valor   
@param dDtILP		Data de lucros e perdas   
@param cTpsald	Tipo de saldo   
@param dDtLP		Data de lucros e perdas  
@param cIdent		Identificador para tabela de entidade   
@param cFlgCnt	Flag   
       	                                      
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ct190FlgLP(cFilX, cAlias, cConta, cCusto, cItem, cClvl, dDtILP,;
						  cTpsald, dDtLP, cMoeda,cIdent,cFlgCnt, cEnt05)

Local aSaveArea	:= GetArea()
Local cChave		:= ""
Local bCond		:= {||.F.}
Local lDtILP		:= .F.
Local lCleanLP	:= .F.
Local dEmpty		:= CTOD('  /  /  ')
Local lDelFisico	:= GetNewPar('MV_CTB190D',.T.) 
Local cCond		:= ""
Local cQuery		:= ""              	
Local cRegs		:= ""	
Local nCountReg	:= 0	
Local nMin			:= ""
Local nMax			:= ""
Local nDel			:= iif( TCGetDB() == "INFORMIX", 1024, 4096 )
Local lSai			:= .F.
Local nX			:= 0
Local aArq			:= Array(2)
Local cArq			:= ""

DEFAULT dDtILP := CTOD('  /  /  ')
DEFAULT cFlgCnt	:= "S"			/// SE ENVIADO CONTEUDO EM BRANCO É PARA LIMPAR OS FLAGS
DEFAULT cEnt05 := ""			// Entidad 05

If cAlias == 'CT7' .Or. cAlias == 'CT1'
	aArq[1]		:= "CQ0"
	aArq[2] 		:= "CQ1"
ElseIf cAlias == 'CT3' .Or. cAlias == 'CTT'
	aArq[1] 		:= "CQ2"
	aArq[2] 		:= "CQ3"
ElseIf cAlias == 'CT4' .Or. cAlias == 'CTD'
	aArq[1] 		:= "CQ4"
	aArq[2] 		:= "CQ5"
ElseIf cAlias == 'CTI' .Or. cAlias == 'CTH'
	aArq[1] 		:= "CQ6"
	aArq[2] 		:= "CQ7"
ElseIf cAlias == "CTU"
	aArq[1] 		:= "CQ8"
	aArq[2] 		:= "CQ9"
ElseIf lEntidad05 .And. cAlias $ "CV0/QL6/QL7"
	cAlias := "QL6"
	aArq[1] 		:= "QL6"
	aArq[2] 		:= "QL7"
EndIf

If !Empty(dDTILP) .and. ValType(dDTILP) == "D"
	lDTILP := .T.
EndIf

If Empty(cFlgCNT) .or. cFlgCNT == "N"
	lCleanLP := .T.
	cFlgCNT := "N"
EndIf

If Empty(cFilX) .or. ValType(cFilX) == "U"
	cFilX := xFilial("CT2")
EndIf
cIdent	:= Iif(cIdent == Nil,"",cIdent)

For nX := 1 to 2
	
	cArq := aArq[nX] 
	
	If cAlias == 'CT7' .Or. cAlias == 'CT1'
		cCond	:=	" "+cArq+"_CONTA = '"+ cConta + "' AND "
	ElseIf cAlias == 'CT3' .Or. cAlias == 'CTT'
		cCond	:=	" "+cArq+"_CONTA = '"+ cConta + "' AND "
		cCond	+=	" "+cArq+"_CCUSTO = '"+ cCusto + "' AND "
	ElseIf cAlias == 'CT4' .Or. cAlias == 'CTD'
		cCond	:= " "+cArq+"_CONTA = '" + cConta + "' AND "
		cCond 	+= " "+cArq+"_CCUSTO = '" + cCusto + "' AND "
		cCond 	+= " "+cArq+"_ITEM = '" + cItem + "' AND "
	ElseIf cAlias == 'CTI' .Or. cAlias == 'CTH'
		cCond	:= " "+cArq+"_CONTA = '" + cConta + "' AND "
		cCond	+= " "+cArq+"_CCUSTO = '" + cCusto + "' AND "
		cCond 	+= " "+cArq+"_ITEM = '" + cItem + "' AND "
		cCond	+= " "+cArq+"_CLVL = '" + cClVl + "' AND "
	ElseIf cAlias == 'CTU'
		If cIdent == 'CTD'
			cCond	:= " "+cArq+"_IDENT = 'CTD' AND "
			cCond	+= " "+cArq+"_CODIGO = '" + cItem + "' AND "
		ElseIf cIdent == 'CTH'
			cCond	:= " "+cArq+"_IDENT = 'CTH' AND "
			cCond	+= " "+cArq+"_CODIGO = '" + cClVl + "' AND "
		ElseIf cIdent == 'CTT'
			cCond	:= " "+cArq+"_IDENT = 'CTT' AND "
			cCond	+= " "+cArq+"_CODIGO = '" + cCusto + "' AND "
		ElseIf lEntidad05 .And. cIdent $ "CV0/QL6/QL7"
			cCond	:= " "+cArq+"_IDENT = 'CV0' AND "
			cCond	+= " "+cArq+"_CODIGO = '" + Left(cEnt05,Len(CQ8->CQ8_CODIGO)) + "' AND "
		EndIf
	ElseIf lEntidad05 .And. cAlias == 'QL6' .Or. cAlias == 'QL7'
		cCond	:= " "+cArq+"_CONTA = '" + cConta + "' AND "
		cCond	+= " "+cArq+"_CCUSTO = '" + cCusto + "' AND "
		cCond 	+= " "+cArq+"_ITEM = '" + cItem + "' AND "
		cCond	+= " "+cArq+"_CLVL = '" + cClVl + "' AND "
		cCond	+= " "+cArq+"_ENT05 = '" + Left(cEnt05,Len(QL6->QL6_ENT05)) + "' AND "
	EndIf

	If lCleanLP .And. lDelFisico // .And. cAlias $ "CTU/CTV/CTW/CTX/CTY" // Se for Estorno de Apuracao e Saldos Compostos
		cQuery	 := "DELETE FROM "+RetSqlName(cArq)

		cQuery  += " WHERE "+cArq+"_FILIAL = '"+cFilX+"' AND "		
		cQuery	+= cCond
		cQuery	+= cArq + "_MOEDA = '"+cMoeda+"' AND "
		cQuery	+= cArq + "_TPSALD ='"+cTpSald+"' AND " 

		If lDtILP
			cQuery += cArq+"_DATA > '"+ DTOS(dDtILP)+ "' AND "
		EndIf
	
		cQuery += cArq + "_DATA <= '" + DTOS(dDtLP) + "' AND "
		cQuery	+= cArq + "_LP = 'Z' AND "				
		cQuery	+= cArq + "_DTLP = '" + DTOS(dDTLP) + "' AND "
		cQuery	+= "D_E_L_E_T_ = ' ' " 

		If TcSqlExec( cQuery ) <> 0
			UserException( STR0024 + RetSqlName(cArq) + CRLF + STR0023 + CRLF + TCSqlError() )
		Endif
			
		TcRefresh( RetSqlName( cArq ) )
	Endif

	cRegs 	:= "cRegs"
	cQuery	:= "SELECT R_E_C_N_O_ RECNO "
	cQuery  += " FROM "+RetSqlName(cArq)+" "
	cQuery  += "WHERE "+cArq+"_FILIAL = '"+cFilX+"' AND "
	cQuery	+= cCond
	cQuery	+= cArq+"_MOEDA = '"+cMoeda+"' AND "
	cQuery	+= cArq+"_TPSALD ='"+cTpSald+"' AND "
	If lDtILP
		cQuery += cArq+"_DATA > '"+ DTOS(dDtILP)+ "' AND "
	EndIf
	cQuery 	+= cArq+"_DATA <= '"+ DTOS(dDtLP)+ "' AND "
	If lCleanLP		/// SE FOR ESTORNO DE APURACAO.
		cQuery	+= cArq+"_LP = 'S' AND "
		cQuery	+= cArq+"_DTLP = '"+DTOS(dDTLP)+"' AND "
	Else
		cQuery	+= cArq+"_LP IN ('N',' ') AND "
	EndIf
	cQuery	+= " D_E_L_E_T_= ' ' "
	cQuery	+= "ORDER BY RECNO"
	cQuery	:= ChangEquery(cQuery)
	
	If ( Select ( "cRegs" ) <> 0 )
		dbSelectArea ( "cRegs" )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cRegs,.T.,.F.)
	
	cQuery 	:= "UPDATE "
	cQuery 	+= RetSqlName(cArq)+" " 
	cQuery 	+= "SET "
	If lCleanLP		/// SE FOR ESTORNO DE APURACAO.
		cQuery 	+= cArq+"_LP = 'N', "+cArq+"_DTLP = ' ' "
	Else
		cQuery 	+= cArq+"_LP = 'S', "+cArq+"_DTLP = '"+ Dtos(dDtLP)+ "' "
	EndIf
	
	cQuery  += " WHERE "+cArq+"_FILIAL = '"+cFilX+"' AND "
	cQuery	+= cCond
	cQuery	+= cArq+"_MOEDA = '"+cMoeda+"' AND "
	cQuery	+= cArq+"_TPSALD ='"+cTpSald+"' AND "
	If lDtILP
		cQuery += cArq+"_DATA > '"+ DTOS(dDtILP)+ "' AND "
	EndIf
	cQuery 	+= cArq+"_DATA <= '"+ DTOS(dDtLP)+ "' AND "
	If lCleanLP		/// SE FOR ESTORNO DE APURACAO.
		cQuery	+= cArq+"_LP <> 'Z' AND "
		cQuery	+= cArq+"_DTLP = '"+DTOS(dDTLP)+"' AND "
	Else
		cQuery	+= cArq+"_LP IN ('N',' ') AND "
	EndIf
	
	cQuery	+= " D_E_L_E_T_= ' ' "
	
	lSai := .F.
	
	While cRegs->(!Eof()) .And. !lSai
		
		nMin := (cRegs)->RECNO
		
		cRegs->(DbSkip(nDel))
		
		If cRegs->(Eof())
			cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)
			lSai := .T.
		Else
			nMax := (cRegs)->RECNO
			cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		EndIf
		
		if TcSqlExec( cQuery + cChave ) <> 0
			UserException( STR0024 + RetSqlName(cArq)+ CRLF + STR0023 + CRLF + TCSqlError() )
		endif
		cRegs->(DbSkip())  //AVANCA 1 PARA PROXIMO REGISTRO
		
	EndDo
	
	TcRefresh( RetSqlName( cArq ) )

	If ( Select ( "cRegs" ) <> 0 )
		dbSelectArea ( "cRegs" )
		dbCloseArea ()
	Endif
	
Next nX


RestArea(aSaveArea)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtbFlgCTZ 
Chama rotina de atualizacao de flags para as contas zeradas
com conta ponte.

@author Simone Mie Sato

@param nInicio	Moeda Inicial   
@param nFinal  	Moeda Final     
                           
   
@version P12
@since   28/11/2002
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CtbFlgCTZ(cMoeda,cAlias)

Local aSaveArea	:= GetArea()
Local nRegCTZ		:= 0
Local cFilX		:= ""

If cAlias == "CT7"
	cAlias		:= "CT1"
ElseIf cAlias == "CT3"
	cAlias		:= "CTT"
ElseIf cAlias == "CT4"
	cAlias		:= "CTD"
ElseIf cAlias == "CTI"
	cAlias		:= "CTH"
EndIf

If cAlias == "CT1"
	cFilX 		:= xFilial("CQ0")
ElseIf cAlias == "CTT"
	cFilX 		:= xFilial("CQ2")
ElseIf cAlias == "CTD"
	cFilX 		:= xFilial("CQ4")
ElseIf cAlias == "CTH"
	cFilX 		:= xFilial("CQ6")
ElseIf cAlias == "CTU"
	cFilX 		:= xFilial("CQ8")
EndIf


//Considerando que ja esteja posicionado no CTZ
dbSelectArea("CTZ")
dbSetOrder(1)       
nRegCTZ	:= Recno()
While !Eof() .And. CTZ->CTZ_FILIAL == xFilial() .And. Dtos(CT2->CT2_DATA) == Dtos(CTZ->CTZ_DATA) .And. ;
	CTZ->CTZ_LOTE == CT2->CT2_LOTE .And. CTZ->CTZ_SBLOTE == CT2->CT2_SBLOTE .And. CTZ->CTZ_DOC == CT2->CT2_DOC .And.;
	CTZ->CTZ_TPSALD == CT2->CT2_TPSALD .And. CTZ->CTZ_EMPORI == CT2->CT2_EMPORI .And. CTZ->CTZ_FILORI == CT2->CT2_FILORI .And. ;
	CTZ->CTZ_MOEDLC == cMoeda .And. CTZ->CTZ_LINHA == CT2->CT2_LINHA

	Ct190FlgLP(cFilX,cAlias, CTZ->CTZ_CONTA,CTZ->CTZ_CUSTO,CTZ->CTZ_ITEM,CTZ->CTZ_CLVL,dDTLPAnt,CTZ->CTZ_TPSALD,CT2->CT2_DTLP,cMoeda)						

	dbSkip()
End	                  
dbGoto(nRegCTZ)
RestArea(aSaveArea)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtbFlgPon
Atualiza os flags das contas zeradas com conta ponte. 

@author Alvaro Camillo Neto

@param nInicio  Moeda Inicial                                       
@param nFinal   Moeda Final                                         
@param cFilDe   Filial De                                           
@param cFilAte  Filial Ate                                          
@param cTpSald  Tipo de Sald                                        
@param dDataIni Data Inicial                                        
@param dDataFim Data Final                                          
@param oObj     Objeto utilizado na regua de Processamento           
       	                                      
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CtbFlgPon(nInicio,nFinal,cFilDe,cFilAte,cTpSald,dDataIni,dDataFim,oObj)
	
Local cQuery		:= ""
Local cFlgPon  		:= ""
Local aStru			:= {}
Local ni
Local lObj			:= oObj <> Nil

//Considerando que ja esteja posicionado no CTZ
dbSelectArea("CTZ")
CTZ->(dbSetOrder(1))   

cFlgPon:= "cFlgPon"
cQuery := "SELECT CTZ_FILIAL, CTZ_DATA, CTZ_MOEDLC, CTZ_CONTA, CTZ_CUSTO, CTZ_ITEM, CTZ_CLVL "
cQuery += "FROM "+RetSqlName("CTZ")+" CTZ "

If cFilDe == cFilAte
	cQuery += "WHERE CTZ.CTZ_FILIAL = '"+XFilial("CTZ",cFilDe)+"' AND "
Else
	cQuery += "WHERE CTZ.CTZ_FILIAL BETWEEN '"+XFilial("CTZ",cFilDe)+"' AND '"+XFilial("CTZ",cFilAte)+"' AND "
EndIf

If dDataIni == dDataFim
	cQuery += "CTZ.CTZ_DATA = '"+DTOS(dDataIni)+"' AND "	/// ALTERADA ORDEM P/ ATENDER INDICE
Else
	cQuery += "CTZ.CTZ_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "	/// ALTERADA ORDEM P/ ATENDER INDICE
EndIf
cQuery += "CTZ.CTZ_TPSALD='"+cTpSald+"' AND "

If nInicio == nFinal
	cQuery += "CTZ.CTZ_MOEDLC = '"+StrZero(nInicio,2)+"' AND "
Else
	cQuery += "CTZ.CTZ_MOEDLC BETWEEN '"+StrZero(nInicio,2)+"' AND '"+StrZero(nFinal,2)+"' AND "
EndIf

cQuery += " D_E_L_E_T_= ' ' "
cQuery += " ORDER BY "
If TCGetDb() == "INFORMIX"
	cQuery += "1,2,3,7,6,5,4"
Else
	cQuery += "CTZ_FILIAL, CTZ_DATA, CTZ_MOEDLC, CTZ_CLVL, CTZ_ITEM , CTZ_CUSTO, CTZ_CONTA"
EndIf

cQuery := Changequery(cQuery)

CTZ->( dbCloseArea() )
dbSelectArea("CTZ")

If ( Select ( "cFlgPon" ) <> 0 )
	dbSelectArea ( "cFlgPon" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cFlgPon,.T.,.F.)

aStru := CTZ->(dbStruct())

For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		If Subs(aStru[ni,1],1,8) == "CTZ_DATA"
			TCSetField(cFlgPon, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		EndIf
	Endif
Next ni

dbSelectArea(cFlgPon)
While !Eof()
	Ct190FlgLP(xFilial("CQ0"),"CT1", cFlgPon->CTZ_CONTA,,,, cFlgPon->CTZ_DATA,cTpSald,dDTLPAnt,cFlgPon->CTZ_MOEDLC)
	
	If !Empty(cFlgPon->CTZ_CUSTO)
		Ct190FlgLP(xFilial("CQ2"),"CTT", cFlgPon->CTZ_CONTA,cFlgPon->CTZ_CUSTO,,,dDTLPAnt,cTpSald,cFlgPon->CTZ_DATA,cFlgPon->CTZ_MOEDLC)
		Ct190FlgLP(xFilial("CQ8"),"CTU", cFlgPon->CTZ_CONTA,cFlgPon->CTZ_CUSTO,,,dDTLPAnt,cTpSald,cFlgPon->CTZ_DATA,cFlgPon->CTZ_MOEDLC,"CTT")
	EndIf
	
	If !Empty(cFlgPon->CTZ_ITEM)
		Ct190FlgLP(xFilial("CQ4"),"CTD", cFlgPon->CTZ_CONTA,cFlgPon->CTZ_CUSTO,cFlgPon->CTZ_ITEM,,dDTLPAnt,cTpSald,cFlgPon->CTZ_DATA,cFlgPon->CTZ_MOEDLC)
		Ct190FlgLP(xFilial("CQ8"),"CTU", cFlgPon->CTZ_CONTA,cFlgPon->CTZ_CUSTO,cFlgPon->CTZ_ITEM,,dDTLPAnt,cTpSald,cFlgPon->CTZ_DATA,cFlgPon->CTZ_MOEDLC,"CTD")
	EndIf
	
	If !Empty(cFlgPon->CTZ_CLVL)
		Ct190FlgLP(xFilial("CQ6"),"CTH", cFlgPon->CTZ_CONTA,cFlgPon->CTZ_CUSTO,cFlgPon->CTZ_ITEM,cFlgPon->CTZ_CLVL,dDTLPAnt,cTpSald,cFlgPon->CTZ_DATA,cFlgPon->CTZ_MOEDLC)
		Ct190FlgLP(xFilial("CQ8"),"CTU", cFlgPon->CTZ_CONTA,cFlgPon->CTZ_CUSTO,cFlgPon->CTZ_ITEM,cFlgPon->CTZ_CLVL,dDTLPAnt,cTpSald,cFlgPon->CTZ_DATA,cFlgPon->CTZ_MOEDLC,"CTH")
	EndIf
	
	dbSelectArea(cFlgPon)
	dbSkip()
	If lObj
		oObj:IncRegua2(STR0006)//Atualizando Flags de Saldos
	Endif
EndDo

If ( Select ( "cFlgPon" ) <> 0 )
	dbSelectArea ( "cFlgPon" )
	dbCloseArea ()
Endif


Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT190ATUMV
Controle de Reprocessamento Exclusivo
Efetua o Lock do Parâmentro para o Controle Exclusivo

@author Marcos S. Lobo

@param dDt2Lock  Data de Lock                                    
                         
@version P12
@since   30/05/2003 
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CT190ATUMV(dDt2Lock)

Local cNamePar	:= "MV_CTBLOCK"
Local lOk		:= .F.				//// RETORNA .T. SE CONSEGUIU RESERVAR O REGISTRO, .F. SE O REGISTRO JÁ ESTÁ EM USO
Local cSX6Fil	:= xFilial("CT2")
Local cChvLock  := ""
Local lLockOk   := .F.

If !GetNewPar("MV_CTBLCKU",.T.)
	Return(.T.)
Endif

cChvLock := cEmpAnt + cSX6Fil + cNamePar
lLockOk  := LockByName(cChvLock,.F.,.F.) 
	 
/// SE Conseguiu lock
If lLockOk     
	lOk := .T.
Else
	lOk := .F. 		/// SE JÁ ESTIVER RESERVADO (RETORNA .F. POIS NÃO PODE EXECUTAR)
Endif

Return(lOk)

//-------------------------------------------------------------------
/*{Protheus.doc} CT190LIBMV
Controle de Reprocessamento Exclusivo 
Efetua o Lock do Parâmentro para o Controle Exclusivo

@author Marcos S. Lobo

@version P12
@since   30/05/2003 
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CT190LIBMV()
                   
Local cNamePar	:= "MV_CTBLOCK"
Local cSX6Fil	:= xFilial("CT2")
Local cChvLock  := ""

If !GetNewPar("MV_CTBLCKU",.T.)
	Return
Endif

cChvLock := cEmpAnt + cSX6Fil + cNamePar
UnLockByName(cChvLock,.F.,.F.)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT190CHKMV
Checa o parâmetro de Reserva do Reprocessamento
Se o registros estiver alocado, há reprocessamento em uso
e não deve ser permitida a confirmação de lançamento	

@author Marcos S. Lobo

@param dDtLan  		Data de lançamento                                  
@param lRefreshDB  	Flag para indicar se realiza o refresh da getdb                                  
@param oGetDB		  	Objeto GetDB                                 
                         
@version P12
@since   30/05/2003 
@return  lOk Status da Operação
@obs	 
*/
//-------------------------------------------------------------------               

Function CT190CHKMV(dDtLan,lRefreshDB,oGetDB)

Local aArea := GetArea()

Local cNamePar	:= "MV_CTBLOCK"
Local lOk		:= .T.
Local cSX6Fil	:= xFilial("CT2")
Local cChvLock  := ""
Local lLockOk   := .F.

DEFAULT dDtLan     := dDataBase
DEFAULT lRefreshDB := .F.

If !GetNewPar("MV_CTBLCKU",.T.)
	Return(.T.)
Endif

cChvLock := cEmpAnt + cSX6Fil + cNamePar
lLockOk  := LockByName(cChvLock,.F.,.F.) 

//Se nao conseguiu lockar retorna false para nao executar a rotina
If ! lLockOk  
	MsgInfo(STR0015,STR0014)
	If lRefreshDB .and. oGetDB <> Nil
		oGetDB:Refresh()
	Endif
	lOk := .F.
Else
	UnLockByName(cChvLock,.F.,.F.)
Endif

RestArea(aArea)

Return(lOk)


//-------------------------------------------------------------------
/*{Protheus.doc} VerIDProc
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB001                                            

@author Marcelo Pimentel 

                         
@version P12
@since   24.07.2007
@return  IdProc
@obs	 
*/
//-------------------------------------------------------------------   
         
Static Function VerIDProc()
Return '012'

//-------------------------------------------------------------------
/*{Protheus.doc} VerIDProc2
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB020                                            

@author Marcelo Pimentel 
                       
@version P12
@since   24.07.2007
@return  IdProc
@obs	 
*/
//-------------------------------------------------------------------  
         
Static Function VerIDProc2()
Return '012'


//-------------------------------------------------------------------
/*{Protheus.doc} Wait4Jobs
Aguarda pelo processamento do saldo via job                                 

@author Totvs

@param lProc Flag para indicar se tem tela                          

@version P12
@since   24.07.2007
@return  IdProc
@obs	 
*/
//-------------------------------------------------------------------  
         
Static Function Wait4Jobs(lProc,cFilde,cFilAte)
	Local lContinua	:=	.F.
	Local nVezes		:=	 0
	Local lExclusivo	:= If(FindFunction("ADMTabExc"), ADMTabExc("CT2"), !Empty(xFilial("CT2"))) //Analisa se a tabela esta exclusiva	
	
	DEFAULT cFilde  := mv_par04
	DEFAULT cFilAte := mv_par05

	If lProc
		ProcRegua(300)                
	EndIf

	While nVezes <= 300
		nVezes++    
		If 	LockByName("CTBA192_"+IIF(lProc .And. lExclusivo .And. (cFilde == cFilAte),cEmpAnt+cFilde,cEmpAnt)) .And. ;
			LockByName("JOB_CTB_SALDO2_"+ IIF(lProc .And. lExclusivo .And. (cFilde == cFilAte),cEmpAnt+cFilde,cEmpAnt) )
			lContinua	:=	.T.
			Exit
		EndIf		

		If nVezes == 1 
			ProcLogAtu( STR0046, STR0046 ) // "Aguardando 5 segundos finalizacion de  JOBs de actualziación on-line..."
			Conout( STR0046 )
		EndIf

		Sleep( 10 )

		If lProc
			IncProc()
		EndIf
	End
Return lContinua

//-------------------------------------------------------------------
/*{Protheus.doc} DeleteCQA
Exclui os registros tabela CQA saldo via job                                  

@author Totvs

@version P12
@since   24.07.2007

@obs	 
*/
//-------------------------------------------------------------------  
Static Function DeleteCQA(cFilDe,cFilAte,dDataIni,dDataFim,cTpSald,cMoeda)
Local aSaveArea := GetArea()
Local cQuery	:= ""
Local cZeraTudo	:= ""
Local nDel		:= iif( TCGetDB() == "INFORMIX", 1024, 4096 )
Local lSai		:= .F.
Local cAlias	:= "CQA"

cInicial := cAlias + "_"

cZeraTudo := "cZeraTudo"

cQuery := "SELECT R_E_C_N_O_ RECNO "
cQuery += "FROM "+RetSqlName(cAlias)
cQuery += " WHERE "
cQuery += cInicial+ "FILIAL BETWEEN '"+XFilial(cAlias,cFilDe)+"' AND '"+XFilial(cAlias,cFilAte)+"' AND "

If dDataIni == dDataFim
	cQuery += cInicial+"DATA = '"+DTOS(dDataIni)+"' AND "
Else
	cQuery += cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
EndIf

cQuery += cInicial+"TPSALD = '"+cTpSald+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "
If !Empty(cMoeda) .and. cMoeda != "00" //Se for Moeda Especifica
	cQuery += " AND "+cInicial+"MOEDLC ='" + cMoeda + "'"
EndIf

cQuery += " ORDER BY RECNO"
cQuery := Changequery(cQuery)

If ( Select ( "cZeraTudo" ) > 0 )
	dbSelectArea ( "cZeraTudo" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cZeraTudo,.T.,.F.)

dbSelectArea(cAlias)

If  cZeraTudo->(!Eof())
	cQuery := " DELETE FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "+cInicial+ "FILIAL BETWEEN '"+XFilial(cAlias,cFilDe)+"' AND '"+XFilial(cAlias,cFilAte)+"' AND "
	
	If dDataIni == dDataFim
		cQuery += cInicial+"DATA = '"+DTOS(dDataIni)+"' AND "
	Else
		cQuery += cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
	EndIf
	
	cQuery += cInicial + "TPSALD = '"+cTpSald+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	If !Empty(cMoeda) .and. cMoeda != '00' //Se for Moeda Especifica
		cQuery += " AND "+cInicial+"MOEDLC ='" + cMoeda + "'"
	EndIf
	
	
	lSai := .F.
	
	While !lSai
		
		nMin := (cZeraTudo)->RECNO
		cZeraTudo->(DbSkip(nDel))
		
		If cZeraTudo->(Eof())
			cChave := ""
			lSai := .T.
		Else
			nMax := (cZeraTudo)->RECNO
			cChave := "AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		EndIf
		
		If TcSqlExec( cQuery + cChave ) <> 0
			UserException( STR0022 + RetSqlName(cAlias) + CRLF + STR0023 + CRLF + TCSqlError() )
		Endif
	EndDo
EndIf
// A tabela eh fechada para restaurar o buffer da aplicacao
dbSelectArea(cAlias)
dbCloseArea()
ChkFile(cAlias)		// Abrir como compartilhado para permitir acesso de outros usuarios

If ( Select ( "cZeraTudo" ) > 0 )
	dbSelectArea ( "cZeraTudo" )
	dbCloseArea ()
Endif

RestArea(aSaveArea)


Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb190CQ8
Gra                                 

@author Totvs

@version P12
@since   24.07.2007

@obs	 
*/
//-------------------------------------------------------------------  
Static Function Ctb190CQ8(cTpSald,cFilDe,cFilAte,dDataIni,dDataFim,lCusto,lItem,lClVl)
Local aArea  := GetArea()
Local cQuery := ""
Local cTab   := GetNextAlias()
Local aTamCT2:= TamSX3("CT2_VALOR")

If lCusto
	cIdent := "CTT"
	cQuery := ""
	cQuery += " Select CQ3_FILIAL FILIAL , CQ3_CCUSTO CODIGO , CQ3_MOEDA MOEDA, CQ3_DATA DATASL, CQ3_DTLP DATALP,CQ3_LP LP , SUM(CQ3_DEBITO) DEBITO ,SUM(CQ3_CREDIT) CREDITO " +CRLF
	cQuery += "  From "+ RetSqlName("CQ3") +CRLF
	cQuery += " Where CQ3_FILIAL between '"+xFilial("CQ3",cFilDe)+"' and '"+xFilial("CQ3",cFilAte)+"' " +CRLF
	cQuery += "   and CQ3_TPSALD = '"+cTpSald+"' " +CRLF
	cQuery += "   and (CQ3_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
	cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
	cQuery += " Group By CQ3_FILIAL, CQ3_CCUSTO , CQ3_MOEDA, CQ3_DATA, CQ3_DTLP,CQ3_LP " +CRLF
	cQuery  += " order by 1,2,3,4,5,6 " +CRLF
	cQuery := Changequery(cQuery)
	
	If ( Select ( cTab ) > 0 )
		dbSelectArea ( cTab )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)
	
	
	
	TCSetField(cTab,"DATASL", "D",8,0)
	TCSetField(cTab,"DATALP", "D",8,0)
	TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
	TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])
	
	While (cTab)->(!EOF())
		Padr(CODIGO,10)
		PadR(CODIGO,TamSX3("CQ8_CODIGO")[1])
		cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+PadR(CODIGO,TamSX3("CQ8_CODIGO")[1])+MOEDA+cTpSald+LP)
		cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+PadR(CODIGO,TamSX3("CQ9_CODIGO")[1])+MOEDA+cTpSald+LP)
		xCt190CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)
						
		(cTab)->(dbSkip())
	EndDo
	
EndIf

If lItem
	cIdent := "CTD"
	cQuery := ""
	cQuery += " Select CQ5_FILIAL FILIAL , CQ5_ITEM CODIGO , CQ5_MOEDA MOEDA, CQ5_DATA DATASL, CQ5_DTLP DATALP,CQ5_LP LP , SUM(CQ5_DEBITO) DEBITO ,SUM(CQ5_CREDIT) CREDITO " +CRLF
	cQuery += "  From "+ RetSqlName("CQ5") +CRLF
	cQuery += " Where CQ5_FILIAL between '"+xFilial("CQ5",cFilDe)+"' and '"+xFilial("CQ5",cFilAte)+"' " +CRLF
	cQuery += "   and CQ5_TPSALD = '"+cTpSald+"' " +CRLF
	cQuery += "   and (CQ5_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
	cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
	cQuery += " Group By CQ5_FILIAL, CQ5_ITEM , CQ5_MOEDA, CQ5_DATA, CQ5_DTLP,CQ5_LP " +CRLF
	cQuery  += " order by 1,2,3,4,5,6 " +CRLF
	cQuery := Changequery(cQuery)
	
	If ( Select ( cTab ) > 0 )
		dbSelectArea ( cTab )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)
	
	
	
	TCSetField(cTab,"DATASL", "D",8,0)
	TCSetField(cTab,"DATALP", "D",8,0)
	TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
	TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])
	
	While (cTab)->(!EOF())
		cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+PadR(CODIGO,TamSX3("CQ8_CODIGO")[1])+MOEDA+cTpSald+LP)
		cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+PadR(CODIGO,TamSX3("CQ9_CODIGO")[1])+MOEDA+cTpSald+LP)
		
		xCt190CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)
						
		(cTab)->(dbSkip())
	EndDo
	
EndIf

If lClVl
	cIdent := "CTH"
	cQuery := ""
	cQuery += " Select CQ7_FILIAL FILIAL , CQ7_CLVL CODIGO , CQ7_MOEDA MOEDA, CQ7_DATA DATASL, CQ7_DTLP DATALP,CQ7_LP LP , SUM(CQ7_DEBITO) DEBITO ,SUM(CQ7_CREDIT) CREDITO " +CRLF
	cQuery += "  From "+ RetSqlName("CQ7") +CRLF
	cQuery += " Where CQ7_FILIAL between '"+xFilial("CQ7",cFilDe)+"' and '"+xFilial("CQ7",cFilAte)+"' " +CRLF
	cQuery += "   and CQ7_TPSALD = '"+cTpSald+"' " +CRLF
	cQuery += "   and (CQ7_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
	cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
	cQuery += " Group By CQ7_FILIAL, CQ7_CLVL , CQ7_MOEDA, CQ7_DATA, CQ7_DTLP,CQ7_LP " +CRLF
	cQuery  += " order by 1,2,3,4,5,6 " +CRLF
	cQuery := Changequery(cQuery)
	
	If ( Select ( cTab ) > 0 )
		dbSelectArea ( cTab )
		dbCloseArea ()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)
	
	
	
	TCSetField(cTab,"DATASL", "D",8,0)
	TCSetField(cTab,"DATALP", "D",8,0)
	TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
	TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])
	
	While (cTab)->(!EOF())
		cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+PadR(CODIGO,TamSX3("CQ8_CODIGO")[1])+MOEDA+cTpSald+LP)
		cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+PadR(CODIGO,TamSX3("CQ9_CODIGO")[1])+MOEDA+cTpSald+LP)
		
		xCt190CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)
						
		(cTab)->(dbSkip())
	EndDo
	
EndIf
	
If lEntidad05
	cIdent := "CV0"
	cQuery := ""
	cQuery += " Select QL7_FILIAL FILIAL, QL7_ENT05 CODIGO, QL7_MOEDA MOEDA, QL7_DATA DATASL, QL7_DTLP DATALP, QL7_LP LP, SUM(QL7_DEBITO) DEBITO, SUM(QL7_CREDIT) CREDITO " +CRLF
	cQuery += "  From "+ RetSqlName("QL7") +CRLF
	cQuery += " Where QL7_FILIAL between '"+xFilial("QL7",cFilDe)+"' and '"+xFilial("QL7",cFilAte)+"' " +CRLF
	cQuery += "   and QL7_TPSALD = '"+cTpSald+"' " +CRLF
	cQuery += "   and (QL7_DATA between '"+DTOS(dDataIni)+"' and '"+DTOS(dDataFim)+"') " +CRLF
	cQuery += "   and D_E_L_E_T_= ' ' " +CRLF
	cQuery += " Group By QL7_FILIAL, QL7_ENT05, QL7_MOEDA, QL7_DATA, QL7_DTLP, QL7_LP " +CRLF
	cQuery  += " order by 1,2,3,4,5,6 " +CRLF
	cQuery := Changequery(cQuery)

	If ( Select ( cTab ) > 0 )
		dbSelectArea ( cTab )
		dbCloseArea ()
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)

	TCSetField(cTab,"DATASL", "D",8,0)
	TCSetField(cTab,"DATALP", "D",8,0)
	TCSetField(cTab,"DEBITO", "N",aTamCT2[1],aTamCT2[2])
	TCSetField(cTab,"CREDITO", "N",aTamCT2[1],aTamCT2[2])

	While (cTab)->(!EOF())
		cChvEntMes  	:= (cTab)->(FILIAL+DTOS(LastDay(DATASL))+cIdent+PadR(CODIGO,TamSX3("CQ8_CODIGO")[1])+MOEDA+cTpSald+LP)
		cChvEntDia  	:= (cTab)->(FILIAL+DTOS(DATASL)+cIdent+PadR(CODIGO,TamSX3("CQ9_CODIGO")[1])+MOEDA+cTpSald+LP)

		xCt190CQ8(cChvEntMes,cChvEntDia,cIdent,(cTab)->CODIGO,cTpSald,(cTab)->LP,(cTab)->DEBITO,(cTab)->CREDITO,(cTab)->DATASL,(cTab)->FILIAL,(cTab)->MOEDA,(cTab)->LP,(cTab)->DATALP)

		(cTab)->(dbSkip())
	EndDo

EndIf

If ( Select ( cTab ) > 0 )
	dbSelectArea ( cTab )
	dbCloseArea ()
Endif	

RestArea(aArea)
Return



//-------------------------------------------------------------------
/*{Protheus.doc} xCt190CQ8
Grava os saldos nas tabelas

@author Alvaro Camillo Neto

@param cArqBase	Arquivo de Base para atualização 
( CT1 = Conta, CTT = Centro de Custo, CTD = Item Contábil , CTH = Classe de Valor , CTU = Entidade )   
@param cChaveMes	Chave para buscar o saldo mensal
@param cChaveDia	Chave para buscar o saldo diário           	                                      
@param cIdent		Tabela identificadore para saldo por entidade
@param cCodigo	Código da entidade para saldo por entidade 
                         
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function xCt190CQ8(cChaveMes,cChaveDia,cIdent,cCodigo,cTpSald,cLp,nDebito,nCredito,dDataSl,cFilSl,cMoeda,cLp,dDataLP)

Local aArq			:= Array(2)
Local dDiaMes		:= STOD("")
Local dDia			:= STOD("")
Local nX			:= 0
Local aSaveArea	:= GetArea() 
Local cArquivo	:= "" 
Local cChave		:= "" // Chave Utilizada para encontrar o saldo mensal

Local dData		:= STOD("")   
Local lNovo		:= .F.

Default cIdent  := ""
Default cCodigo := ""

dDiaMes	:= LastDay(dDataSl)
dDia		:= dDataSl

aArq[1] 		:= "CQ8"
aArq[2] 		:= "CQ9"

		
For nX := 1 to 2
	cArquivo := aArq[nX]
	dbSelectArea(cArquivo)
	(cArquivo)->(dbSetOrder(1))
	
	If nX == 1 // Saldo Mensal
		dData := dDiaMes
		cChave:= cChaveMes
	Else // Saldo Diário
		dData := dDia
		cChave:= cChaveDia
	EndIf
	
	If (cArquivo)->(MsSeek(cChave))
		lNovo := .F.
	Else
		lNovo := .T.
	EndIf
	
	RecLock(cArquivo,lNovo)
	
	&(cArquivo+"->"+cArquivo+"_FILIAL")		:= cFilSl
	&(cArquivo+"->"+cArquivo+"_MOEDA")			:= cMoeda
	&(cArquivo+"->"+cArquivo+"_TPSALD")		:= cTpSald
	
	&(cArquivo+"->"+cArquivo+"_DATA")			:= dData
	&(cArquivo+"->"+cArquivo+"_STATUS")		:= '1'
	&(cArquivo+"->"+cArquivo+"_LP")				:= cLp
	
	&(cArquivo+"->"+cArquivo+"_IDENT")			:= cIdent
	&(cArquivo+"->"+cArquivo+"_CODIGO")		:= cCodigo

	&(cArquivo+"->"+cArquivo+"_DTLP")			:= dDataLP

	
	If lNovo
		&(cArquivo+"->"+cArquivo+"_DEBITO")	:= nDebito
		&(cArquivo+"->"+cArquivo+"_CREDIT")	:= nCredito
	Else
		&(cArquivo+"->"+cArquivo+"_DEBITO")	+= nDebito
		&(cArquivo+"->"+cArquivo+"_CREDIT")	+= nCredito
	EndIf
	
	MsUnlock()
	
Next nX

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT190UltZera - Retorna a ultima data de Zeramento - Procura na CW0
@param dDataLP  - Data de Zeramento
@param cTpSaldo - Tipode de Saldo
@param cMoeda   - Moeda da Apuracao
                         
@version P12
@return  dData
*/
Static Function CT190UltZera(dDataLP, cTpSaldo, cMoeda, cLP )
Local dDtZeraAnt := CTOD("  /  /  ")																								
Local cQryAp     := ""
Local cQryApAnt  := ""
Local cDataAnt   := ""
Local cDtZera    := GetNextAlias()
Local cDtZeraAnt := GetNextAlias()
Local cLpAnt     := " "

Default cLP      := "N"
/* -----------------------------------------------------------------------------------------------------
	20150131011P - Mesmo com duas AP Ponte no mesmo dias, grava UMA CW0
	20150131011Z - Idem 
	Gravar 'S' em datas anteriores somente quando for apuracao de zeramento
	1 - Verificar se dDataLP recebida é Apur de Zeramento, se sim, executa os próximos passos abaixo
		2 - Busca no CW0 - a maior data de apuração de ZERAMENTO anterior a dDataLP recebida
			2.a - Se não achar, gravo 'S' em todos até o início do exercicio
			2.b - Se achar, gravo 'S' do ZERA/O ANTERIOR+1 até dDataLP
	---------------------------------------------------------------------------------------------------- 
	cQuery:="  Select @cCW0_DESC01Aux1 = @IN_DATALP||@IN_MOEDA||@IN_TPSALDO||'Z'  -  "20150531011Z"
	1 - Verificar se @IN_DATALP é Apur de Zeramento, se sim, executa os próximos passos abaixo
	----------------------------------------------------------------------------------------------------- */
cQry:="Select  CW0_DESC01 DTZERA "
cQry+="  From "+ RetSqlName("CW0") + " " + CRLF
cQry+=" Where CW0_FILIAL = '"+xFilial("CW0")+"'"
cQry+="   and CW0_TABELA = 'LP' "
cQry+="   and CW0_CHAVE  = '"+cEmpAnt+cFilAnt+"'"
cQry+="   AND CW0_DESC01 = '"+Dtos(dDataLP)+cMoeda+cTpSaldo+"Z"+"'"
cQry+="   and D_E_L_E_T_ = ' ' "+CRLF

cQry := Changequery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cDtZera,.T.,.F.)

If (cDtZera)->(!EOF()) .and.  (Subs((cDtZera)->(DTZERA),12,1) == "Z")
	//Existe zeramento nesta data recebida, Buscar pelo zeramento anterior 
 	//cDataAnt := Subs((cDtZera)->(DTAZERA),1,8)

	cQryAnt:=" Select MAX(CW0_DESC01) DTZERAANT "
	cQryAnt+="  From "+ RetSqlName("CW0") + " " + CRLF
	cQryAnt+=" WHERE CW0_FILIAL  = '"+xFilial("CW0")+"' "
	cQryAnt+="	 and CW0_TABELA  = 'LP' "
	cQryAnt+="	 and CW0_CHAVE   = '"+cEmpAnt+cFilAnt+"'"                           //@IN_EMPANT||@IN_FILANT
	cQryAnt+="	 and CW0_DESC01  < '"+(cDtZera)->(DTZERA)+"'"                      //@cCW0_DESC01Aux1
	cQryAnt+="	 and SUBSTRING (CW0_DESC01, 9, 04) = '"+cMoeda+cTpSaldo+"Z"+"'"     //@IN_MOEDA||@IN_TPSALDO||'Z'
	cQryAnt+="	 and D_E_L_E_T_ = ' ' " + CRLF
	cQryAnt := Changequery(cQryAnt)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAnt),cDtZeraAnt,.T.,.F.)

	If (cDtZeraAnt)->(!EOF()) .and. !Empty((cDtZeraAnt)->(DTZERAANT))
		 cLpAnt := Subs((cDtZeraAnt)->(DTZERAANT),12,1)
		 If cLpAnt  == "Z"
		 	dDtZeraAnt := STOD(Subs((cDtZeraAnt)->(DTZERAANT),1 ,8 ))   //DaySum(dDataZerAnt,1)
			cLp        := "S"
		 End
	Else
	    /* Se NÃO achar zeramento anterior, grava 'S' até o primeiro dia do exercício corrente */
		dDtZeraAnt := STOD(Subs(Dtos(dDataLp),1, 4)+"0101")
		cLp        := "S"
	End
	(cDtZeraAnt)->(dbCloseArea())
End
(cDtZera)->(dbCloseArea())

Return(dDtZeraAnt)


// /*/{Protheus.doc} CTB190Metrics
	
// 	CTB190Metrics - Função utilizada para metricas no CTBR400

// 	@type  Static Function
// 	@author user
// 	@since date
// 	@version version
// 	@param param, param_type, param_descr
// 	@return return, return_type, return_description
// 	@example
// 	(examples)
// 	@see (links_or_references)
// 	/*/
Static Function CTB190Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local nFim := 0

Local cIdMetric  := ""
Local nValue := 0
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local cTotal := ""

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a versão da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo médio

		
		If cSubEvent == '001' .Or. cSubEvent == '002' // 001 = R4 - 002 = R3
			
			cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCCTBA190",cFunBkp)
			SetFunName(cFunMet)

			nFim := Seconds() - nStart // Capturar tempo final | Diferença com o tempo inicial
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_reprocessamento-de-saldos-tempo_seconds"
			cValue := cValToChar("1") //na função SetMetric espera parametro do tipo caractere	
			dDateSend := LastDay( Date() ) 
			nLapTime := nFim

			// Metrica
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cValue, dDateSend, nLapTime)

		EndIf

	//Evento 02 - Metrica de quantidade total
	ElseIf cEvent == "02" .And. nQtdReg > 0 

		If cSubEvent == '001'

			cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCCTBA190",cFunBkp)
			SetFunName(cFunMet)

			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			cSubRoutine := Alltrim(cSubRoutine)			
			cIdMetric  := "contabilidade-gerencial-protheus_reprocessamento-de-saldos-qtd_total"
			cTotal := cValToChar(nQtdReg) //cTotal na função SetMetric espera parametro do tipo caractere						
			dDateSend := LastDay( Date() )
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cTotal, dDateSend)
		EndIf
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 

/*/{Protheus.doc} Ct190MVSchd(nOpc)

	Função para capturar os parâmetros do reprocessamento quando chamado via Schedule

	@type  Static Function
	@author caio
	@since 25/06/2021
	@version 12.1.33
	@param nOpc - 
		nOpc = 1 - Capturar o mvpar antes de passar pelo Pergunte()
		nOpc = 2 - Atribuir o conteúdo de aMVPar aos o mv_parxx após de passar pelo Pergunte()
/*/
Static Function Ct190MVSchd(nOpc)

Local nX		:= 0

Default nOpc 	:= 0

If nOpc == 1
	
	For nX := 1 To 8
 		aAdd( aMvPar, &( "mv_par" + StrZero( nX, 2, 0 ) ) )
	Next nX

ElseIf nOpc == 2

	If Len(aMVPar) > 0

		For nX := 1 To 8
			&( "mv_par" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
		Next nX

	EndIf

	aMvPar := {} 

EndIf

Return

/*  Novo Processo Procedure - Processo 01 - Reprocessamento Contábil
/{Protheus.doc} EngPos01Compile
Funcao executada depois da compilacao da procedure (Pos-Compile)
@type function
@version 1.0
@author Squad Control
@since 08/11/
@param cProcesso, character, Codigo do processo
@param cEmpresa, character, Codigo da empresa
@param cProcName, character, Nome da stored procedure
@param cLocalDB, character, Nome do Banco de Dados
@param cBuffer, character, Codigo original da procedure (corpo da procedure)
@param cError, character, Passada por referencia, deve conter a mensagem de erro caso ocorra
@return logical, .T. caso tudo ok
/*/
// Processo 01 - REPROCESSAMENTO CONTÃ?BIL
Function EngPos01Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)

	Do Case

		Case cLocalDB == DEF_DB_INFORMIX

			If cProcName $ "CTB211"
				cBuffer := StrTran(cBuffer, "GROUP BY CT2_FILIAL , SUBSTR ( CT2_DATA , 1 , 6 )", "GROUP BY CT2_FILIAL , 2")
			EndIf

			If cProcName $ "CTB021/CTB230/CTB232"
				cBuffer := StrTran(cBuffer, "GROUP BY CQ1_FILIAL , CQ1_CONTA , CQ1_MOEDA , SUBSTR ( CQ1_DATA , 1 , 6 )", "GROUP BY CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, 4")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ3_FILIAL , CQ3_CONTA , CQ3_CCUSTO , CQ3_MOEDA , SUBSTR ( CQ3_DATA , 1 , 6 )", "GROUP BY CQ3_FILIAL, CQ3_CONTA ,CQ3_CCUSTO, CQ3_MOEDA, 5")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ5_FILIAL , CQ5_CONTA , CQ5_CCUSTO , CQ5_ITEM , CQ5_MOEDA , SUBSTR ( CQ5_DATA , 1 , 6 ), CQ5_DTLP , CQ5_LP", "GROUP BY 1, 2 ,3, 4 , 5, 6,7,8")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ7_FILIAL , CQ7_CONTA , CQ7_CCUSTO , CQ7_ITEM , CQ7_CLVL , CQ7_MOEDA , SUBSTR ( CQ7_DATA , 1 , 6 ), CQ7_DTLP , CQ7_LP", "GROUP BY 1, 2, 3, 4, 5, 6, 7,8,9")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ9_FILIAL , CQ9_IDENT , CQ9_CODIGO , CQ9_MOEDA , SUBSTR ( CQ9_DATA , 1 , 6 )", "GROUP BY CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, 5")
			EndIf

			If cProcName == "CTB209"
				cBuffer := StrTran(cBuffer, "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , SUBSTR ( CVX_DATA , 1 , 6 )", "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , 5")
			EndIf

		Case cLocalDB == DEF_DB_POSTGRES
		
			If cProcName $ "CTB211"
				cBuffer := StrTran(cBuffer, "GROUP BY CT2_FILIAL , SUBSTR ( CT2_DATA , 1 , 6 )", "GROUP BY CT2_FILIAL , 2")
			EndIf

			If cProcName $ "CTB021/CTB230/CTB232"
				cBuffer := StrTran(cBuffer, "GROUP BY CQ1_FILIAL , CQ1_CONTA , CQ1_MOEDA , SUBSTR ( CQ1_DATA , 1 , 6 )", "GROUP BY CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, 4")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ3_FILIAL , CQ3_CONTA , CQ3_CCUSTO , CQ3_MOEDA , SUBSTR ( CQ3_DATA , 1 , 6 )", "GROUP BY CQ3_FILIAL, CQ3_CONTA ,CQ3_CCUSTO, CQ3_MOEDA, 5")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ5_FILIAL , CQ5_ITEM , CQ5_CCUSTO , CQ5_CONTA , CQ5_MOEDA , SUBSTR ( CQ5_DATA , 1 , 6 )", "GROUP BY CQ5_FILIAL, CQ5_ITEM ,CQ5_CCUSTO, CQ5_CONTA , CQ5_MOEDA, 6")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ7_FILIAL , CQ7_CLVL , CQ7_ITEM , CQ7_CCUSTO , CQ7_CONTA , CQ7_MOEDA , SUBSTR ( CQ7_DATA , 1 , 6 )", "GROUP BY CQ7_FILIAL, CQ7_CLVL, CQ7_ITEM, CQ7_CCUSTO, CQ7_CONTA, CQ7_MOEDA, 7")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ9_FILIAL , CQ9_IDENT , CQ9_CODIGO , CQ9_MOEDA , SUBSTR ( CQ9_DATA , 1 , 6 )", "GROUP BY CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, 5")
			EndIf
			
			If cProcName == "CTB209"
				cBuffer := StrTran(cBuffer, "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , SUBSTR ( CVX_DATA , 1 , 6 )", "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , 5")
			EndIf
			/*----------------------------------------------------------------------------------------------
		 	  Efetua tratamento para o POSTGRES substitui somente se a declaracao da variavel fim_CUR ocorreu
		 	----------------------------------------------------------------------------------------------*/
			If At("fim_CUR INTEGER default 0;",cBuffer) >0
				cBuffer	:= StrTran( cBuffer, 'vfim_CUR  := 0 ;', 'fim_CUR  := 0 ;' )
			EndIf
		Case cLocalDB == DEF_DB_DB2 .or. cLocalDB == DEF_DB_MYSQL
			/*------------------------------------------------
			 Efetua tratamento para o DB2 / MySQL
			------------------------------------------------*/
			cBuffer	:= StrTran( cBuffer, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
			cBuffer	:= StrTran( cBuffer, "IF fim_CUR <> 1 THEN", "IF fim_CUR = 1 THEN")
		
	EndCase

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} A190Legacy
Função de controle para validar a versão do fonte para o projeto Acompanha Custos - SIGAEST

@type Function
@author Squad Entradas 
@version P12
@since   01/02/2022
@return  Numeric	 
*/
//-------------------------------------------------------------------

Function A190Legacy() 

Return getLegacy()

//-------------------------------------------------------------------
/*/{Protheus.doc} A190Alert
	Abre uma janela com a mensagem de erro
	@type  Function
	@since 09/12/2021
	@version 1.0
	@param cMsg1, caracter, primeira mensagem
	@param cMsg2, caracter, segunda mensagem
	@param cError, caracter, mensagem de erro vindo do dbaccess
	/*/
//-------------------------------------------------------------------
Static Function A190Alert(cMsg1, cMsg2, cError)
Local cTexto
Local cTitulo
Local oDlg
Local oFont
Local oMemo
Local lFinish

default cMsg1 := ""
default cMsg2 := ""

If !IsBlind()

	cTitulo := "Erro na chamada de procedimento armazenado do banco de dados"

	cTexto := cError

	lFinish := .F.

	__cFileLog := MemoWrite(Criatrab(, .F.) + ".log", cTexto)

	DEFINE FONT oFont NAME "Courier New" SIZE 8, 15
	DEFINE MSDIALOG oDlg TITLE cTitulo  From 3,0 to 340,427 PIXEL
	@ 05,05 SAY OemToAnsi(cMsg1) SIZE 150, 10 OF oDlg PIXEL
	@ 15,05 SAY OemToAnsi(cMsg2) SIZE 150, 10 OF oDlg PIXEL
	@ 25,05 SAY OemToAnsi("Retorno de falha do banco de dados:") SIZE 150, 10 OF oDlg PIXEL
	@ 35,05 GET oMemo  VAR cTexto MEMO SIZE 200,110 OF oDlg PIXEL READONLY
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	TButton():New( 153,150 , "Finalizar", oDlg,{||(oDlg:end(),lFinish:= .T.)} ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTER

	If lFinish
		Quit
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS01Signature
Processo 01 - REPROCESSAMENTO CONTÃ?BIL
Funções executadas durante a exibição de informações detalhadas 
do processo na interface de gestão de procedures.
Faz a execução de funções STATIC proprietárias das rotinas donas 
dos processos.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
Function EngSPS01Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := STATICCALL(CTBA190,VERIDPROC2)

Return cAssinatura

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS02Signature
Processo 02 - REPROCESSAMENTO DE ORÃ‡AMENTOS
Funções executadas durante a exibição de informações detalhadas 
do processo na interface de gestão de procedures.
Faz a execução de funções STATIC proprietárias das rotinas donas 
dos processos.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
Function EngSPS02Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := STATICCALL(CTBA190,VERIDPROC)

Return cAssinatura
