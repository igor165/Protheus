#INCLUDE 'PROTHEUS.CH'

#DEFINE IDLETIME	20

STATIC __lConOutR	:= FindFunction( "CONOUTR" )
STATIC lDebug		:=	.F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSLDJOB ºAutor  ³Microsiga           º Data ³  xx/xx/xx   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTBSLDJOB2(aParams)

Local cEmpresa	:=	aParams[1]
Local cFilProc	:=	aParams[2]
Local lManual	:=	If(Len(aParams) >= 4, aParams[4], .F.)
Local lContinua	:=	.T.
Local nSecs			:=	Seconds()
Local nCiclo		:=		0
Local nMovs			:= 	0
Local l192			:=		.F.
Local aSM0
Local nContFil		:= 0 

If GETSRVPROFSTRING( "SuspendJobCTB" , "2"  ) <> "1" 

	If !lManual
		RpcSetType( 3 )
		RpcSetEnv( cEmpresa, cFilProc,,,'CTB' )	
	Endif

	DbSelectArea("CT7")
	DbSelectArea("CT4")
	DbSelectArea("CT3")
	DbSelectArea("CTI")		   

	If LockByName("JOB_CTB_SALDO2_"+cEmpresa) 
		aSM0	:= AdmAbreSM0()
		nCiclo	:=	0

		While lContinua .And. !KillApp()
			//Verificar se foi enviado comando para suspender o JOb do CTB
			If !CTBA192IsOn(cEmpresa) 
				DbSelectArea("CVO")   
				DbSetORder(1)
				nCiclo++

				TConout("CTBSLDJOB2_"+cEmpresa+"-Recomecando : "+Alltrim(Str(nCiclo)) )

				nMovs	:=	0
				For nContFil := 1 to Len(aSM0)
					If KillApp()
						Exit
					EndIf
					
					If aSM0[nContFil][SM0_GRPEMP] != cEmpresa 
						Loop
					EndIf
					
					DbSelectArea("CVO")
					If DbSeek(xFilial("CVO",aSM0[nContFil][SM0_CODFIL]))
						TConout("CTBSLDJOB2_"+cEmpresa+"-Chamando procedure filial "+aSM0[nContFil][SM0_CODFIL])
					 	nSecs		:=	Seconds()
				  		nSecsIni	:=	Seconds()

						BEGIN Transaction	

						DbSelectArea("CVO")                
					 	aResult := TCSPEXEC( xProcedures('CTB150A'), xFilial("CVO",aSM0[nContFil][SM0_CODFIL]))
						TCSPEXEC("COMMIT")
		   				If Empty(aResult).Or. aResult[1] = '0'    
		   			  		If Empty(aResult)
								TConout("CTBSLDJOB2_"+cEmpresa+"-Erro na chamada do processo - Gravacao de Saldos - CTB150:"+TCSQLERROR())
							Else
								TConout("CTBSLDJOB2_"+cEmpresa+"-ROLLBACK chamada do processo - Gravacao de Saldos - CTB150:"+TCSQLERROR())						
							Endif
							DISARMTRANSACTION()
						Else
							nSecsFim	:=	Seconds()
							//Se passou da meianoite
							If nSecsFim < nSecs
								nSecsFim	:=	nSecsFim + (60*60*24)
							Endif	
							nTimeProc:=	nSecsFim	- nSecsIni
							TCONOUT("CTBSLDJOB2_"+cEmpresa+"-Procedure executada em  "+StrZero(nTimeProc,6,2)+" Segundos.")		
						Endif
						End Transaction
					Else
						TConout("CTBSLDJOB2_"+cEmpresa+"-Sem pendencias para a filial "+ aSM0[nContFil][SM0_CODFIL])
					Endif				
				Next nContFil                                                                             

		  		nSecsAtu	:=	Seconds()

				//Se passou da meianoite
				If nSecsAtu < nSecs
					nSecsAtu	:=	nSecsAtu + (60*60*24)
				Endif	
				nTime			:=	nSecsAtu	- nSecs
				DbSelectArea('CVO' )  
				DbGoTop()
				lContinua	:= !EOF()

				If !lContinua .And.	nTime <= 60*IDLETIME //menos de meia hora
					lContinua	:=	.T.       
				Endif	

				Sleep(5000)
			Else
				l192	:=	.T.			 
				Exit
			Endif	
		Enddo

		If l192	
			TConout("CTBSLDJOB2_"+cEmpresa+"-Finalizando JOB para iniciar o reprocessmamento de saldos CTBA192.")
		ElseIf !KillApp()
			TConout("CTBSLDJOB2_"+cEmpresa+"-Finalizando JOB depois de "+StrZero(IDLETIME,2)+" minutos sem atualizacoes na fila.")
		Else
			TConout("CTBSLDJOB2_"+cEmpresa+"-Thread interrompida pelo administrador.")
		Endif
	Else
		TConout("CTBSLDJOB2_"+cEmpresa+"-Nao foi possivel fazer o LOCKBYNAME.")	
	Endif
	FreeUsedCodes()
Else
	TConout("CTBSLDJOB2_"+cEmpresa+"-Job suspenso (chave SuspendJobCTB do server) .")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSLDJOB ºAutor  ³Microsiga           º Data ³  xx/xx/xx   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function TConout(cMsg,lLog)
DEFAULT lLog	:=	.T.

cMsg	:="["+Dtoc(Date())+" "+Time()+"] "+cMsg

Conout( cMsg )

If lDebug .And. lLog
	Conout( cMsg)
Endif

PtInternal(1,cMsg)

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSLDJOB ºAutor  ³Microsiga           º Data ³  xx/xx/xx   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA192IsOn(cEmpresa,lPrende)
Local nIDJob	:=	1
Local nJobs		:=	GetNewPar( 'MV_CTB192J' , 5 )
Local nX		:=	0
Local lRet	:=	.F.                   

DEFAULT lPrende := .F.

lRet	:=	!LockByName('CTBA192_'+cEmpresa)

If !lRet                                                    
	For nIDJob := 1 To nJobs
		If !LockByName('CTBA192_'+StrZero(nIdJob,2)+"_"+cEmpresa)
			lRet	:=	.T.
			Exit
		Endif
	Next     
Endif

For nX := 1 To nIdJob - 1 
	UnLockByName('CTBA192_'+StrZero(nX,2)+"_"+cEmpresa)
Next	

//Solta no fim para evitar que entre outra
If !lPrende
	UnLockByName('CTBA192_'+cEmpresa)		
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSLDJOB ºAutor  ³Microsiga           º Data ³  xx/xx/xx   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA192Off(cEmpresa)

UnLockByName('CTBA192_'+cEmpresa)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= .T.
Local lFWCodFilSM0 	:= .T.

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0


