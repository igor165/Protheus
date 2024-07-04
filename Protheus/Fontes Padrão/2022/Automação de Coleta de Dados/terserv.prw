#include "PROTHEUS.CH" 
#INCLUDE "TCBROWSE.CH"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥DescriáÖo ≥ PLANO DE MELHORIA CONTINUA                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ITEM PMC  ≥ Responsavel              ≥ Data         |BOPS:		      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥      01  ≥                          ≥              |                  ≥±±
±±≥      02  ≥Erike Yuri da Silva       ≥25/01/2006    |00000091435       ≥±±
±±≥      03  ≥                          ≥              |                  ≥±±
±±≥      04  ≥                          ≥              |                  ≥±±
±±≥      05  ≥                          ≥              |                  ≥±±
±±≥      06  ≥                          ≥              |                  ≥±±
±±≥      07  ≥                          ≥              |                  ≥±±
±±≥      08  ≥                          ≥              |                  ≥±±
±±≥      09  ≥                          ≥              |                  ≥±±
±±≥      10  ≥Erike Yuri da Silva       ≥25/01/2006    |00000091435       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
STATIC aEstado    := Array(32)
STATIC aParametro := Array(32)
STATIC aTeclado   := Array(32)
STATIC aLin       := Array(32)
STATIC aCol       := Array(32)
STATIC aLinha1    := Array(32)
STATIC aLinha2    := Array(32)
STATIC aPicture   := Array(32)
STATIC aPosPic    := Array(32)
STATIC aWaitKbd   := Array(32)
STATIC aPPrinter  := Array(32)
STATIC aSPrinter  := Array(32)
STATIC aTerImp    := Array(32)
STATIC aTipImp    := Array(32)
STATIC aVelImp    := Array(32)
STATIC aImpLib    := Array(32)
STATIC aBufferSimu:= Array(32)
STATIC aBuffer    := Array(32)
STATIC aBufferP   := Array(32)
STATIC aBufferS   := Array(32)
STATIC aStatusAnt := Array(32)
STATIC oConsole
STATIC cConsole:=""


STATIC nTerminal   := 0
STATIC cComutadora :="00"
STATIC nQtdTer
STATIC cPorta
STATIC cIP
STATIC nTimeOut
STATIC cIniFile
STATIC lConfig     := .F.
STATIC nHDll       := -1  // handle da DLL caso seja pela comutadora paralela
STATIC oObj
STATIC oTimer

Function TerServ(xComutadora)
If xComutadora==NIL
	xComutadora:="00"
	If ! MsgGet2("Gerenciador de Microterminais","Comutadora",@xComutadora,,, "99" )
		Return .f.
	EndIf
EndIf	
FErase("MT"+xComutadora+".FIM")
While .t.
	If GetBuild() < "7.00.040513P"
		WinExec("mp8rmt.exe -D -M -P=TERSERVX -Q -E="+GetEnvServer()+" -A="+xComutadora)
	Else
		WinExec("mp8rmt.exe -D -M -P=TERSERVX -Q=C -E="+GetEnvServer()+" -A="+xComutadora)
	EndIf	
	While ! FILE("MT"+xComutadora+".LCK") // espera a criacao do semaforo
		Sleep(100)
	End
	While ! File("MT"+xComutadora+".FIM") .and. FErase("MT"+xComutadora+".LCK") == -1
		// espera o programa sair normalmente ou qdo o remote cair por algum motivo
		Sleep(100)	
	End	
	If File("MT"+xComutadora+".FIM")
		exit
	EndIf
End
FErase("MT"+xComutadora+".FIM")
Return .t.


MAIN Function TerServX(xComutadora,lJob)
DEFAULT lJob:= .f.
If ! lJob
	If xComutadora==NIL
		xComutadora:="00"
		If ! MsgGet2("Gerenciador de Microterminais","Comutadora",@xComutadora,,, "99" )
			Return .f.
		EndIf
	EndIf
	nHdl := MSFCREATE("MT"+xComutadora+".LCK")
	IF nHdl >= 0
		ServicoDLL(xComutadora)
		Fclose(nHdl)
	EndIf
Else
	cComutadora:=xComutadora
	StartJob("TerCtrl",GetEnvServer(),.F.,cComutadora)
EndIf
Return

Static Function ServicoDLL(xComutadora)
PUBLIC oMainWnd
PUBLIC lLeft := .F.

RPCSetType(3)
RpcSetEnv ("99","01", , ,'ACD', , , , , .F., .F. )
SetsDefault()
DEFINE WINDOW oMainWnd FROM 0,0 TO 5, 30  TITLE  "Gerenciador de Microterminais ("+xComutadora+")"  NOMAXIMIZE
oMainWnd:oFont := AdvFont
oMainWnd:nClrText := 0
oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
oMainWnd:lEscClose := .F.

@ 0,0 GET oConsole  VAR cConsole MEMO SIZE 238,65 OF oMainWnd
oConsole:lReadOnly := .T.
DEFINE TIMER oTimer INTERVAL 1000 ACTION TerCtrl(xComutadora) OF oMainWnd
ACTIVATE WINDOW oMainWnd  valid (FErase("TERGER"+cComutadora+".ATV"),.f.)  ON INIT  (oTimer:Activate())
__cInternet:=NIL
MemoWrit("MT"+xComutadora+".SAI","FIM")
Final("Termino normal")
Return

Static Function Console(cConteudo)
conout(cConteudo)
If oConsole<>NIL
	If len(cConsole) > 2048
		cConsole :=""
	EndIf
	cConsole:=Time()+" "+cConteudo+chr(13)+chr(10)+cConsole
	oConsole:Refresh()
EndIf
Return

Function TerCtrl(xComutadora)
Local nI := 0
Local xPorta := Alltrim(GetPvProfString( "SETUP","Portalpt" , "LPT1", "TERGER"+xComutadora+".INI" ))
Local xIP    := Alltrim(GetPvProfString( "SETUP","TcpIp" , "", "TERGER"+xComutadora+".INI" ))
Local lLPT:= Empty(xIP)
Local nResp
Local __Status

If oTimer<>NIL
	oTimer:DeActivate()
EndIf
PtInternal(1,"Gerenciador de Microterminais ("+xComutadora+")")
cPorta :=xPorta
cIP    :=xIP
If lLPT
	nHDll := ExecInDLLOpen("TerGer.DLL")
	If nHDLL == -1
		Alert("Falha ao carregar a DLL 'TERGER.DLL'. Ela deve estar junto as DLLs da Wilbor-Gradual")
		__cInternet:=NIL
		memowrit("MT"+xComutadora+".FIM","FIM")
		Final("Erro DLL")
		Return
	EndIf
	Console("Ativado o gerenciador de Microterminais conexao Paralela")
Else
	oObj := tSocketClient():New()

	If Val(cPorta) ==0
		console("Porta de comunicao invalida")
		If oConsole<>NIL
			__cInternet:=NIL
			memowrit("MT"+xComutadora+".FIM","FIM")
			Final("Erro de comunicacao")
		EndIf
		Return
	EndIf
	// Connect - Porta ( Numerico ) - Endereco ( IP ) - Timeout ( Numerico )
	// nResp := oObj:Connect(Val(cPorta), cIP, 0 )  // Zero - OK
	nResp := oObj:Connect(Val(cPorta), cIP, 1000 )  // Zero - OK
	If nResp <> 0
		Console( "Erro de Conexao "  )
		If oConsole<>NIL
			__cInternet:=NIL
			memowrit("MT"+xComutadora+".FIM","FIM")
			Final("Erro de comunicacao")
		EndIf
		Return
	EndIf
	Console("Ativado o gerenciador de Microterminais conexao TCPIP")
EndIf

cComutadora := xComutadora
TerIsVarGbl(.t.)
For nI := 1 to 32
	aBufferSimu[nI] := ""
	If ! File("TERGER"+xComutadora+".ATV")
		aEstado[nI]   := 1
	Else
		If ! Empty(LoadMEM(xComutadora+StrZero(nI-1,2),4)) // picture
			aEstado[nI]   := 7
		Else
			aEstado[nI]   := 1
		EndIf
	EndIf
	aLinha1[nI]   := Space(20)
	aLinha2[nI]   := Space(20)
	If ! File("TERGER"+xComutadora+".ATV")
		aTeclado[nI]  := ""
		aPicture[nI]  := ""
		aLin[nI]      := 0
		aCol[nI]      := 0
		aPosPic[nI]   := 1
	Else
		aLin[nI]      := LoadMEM(xComutadora+StrZero(nI-1,2),1)
		aCol[nI]      := LoadMEM(xComutadora+StrZero(nI-1,2),2)
		aPosPic[nI]   := LoadMEM(xComutadora+StrZero(nI-1,2),3)   	
		aPicture[nI]  := LoadMEM(xComutadora+StrZero(nI-1,2),4)
		aTeclado[nI]  := LoadMEM(xComutadora+StrZero(nI-1,2),5)
	EndIf	
	aWaitKbd[nI]  := .f.
	aPPrinter[nI] := ""
	aSPrinter[nI] := ""
	aTerImp[nI]   := 0
	aTipImp[nI]   := ""
	aVelImp[nI]   := 3
	aImpLib[nI]   := .T.
	aBuffer[nI]   :=""
	aBufferP[nI]  :=""
	aBufferS[nI]  :=""
	aStatusAnt[ni]:=0	
Next

CargaIni()
If ! File("TERGER"+xComutadora+".ATV")
	MemoWrite("TERGER"+cComutadora+".ATV","TESTE")
EndIf	

While !KillApp()
	If oConsole<>NIL
		oMainWnd:cCaption := "Gerenciador de Microterminais ("+cComutadora+") "+time()
	EndIf
	If ! File("TERGER"+cComutadora+".ATV")
		Exit
	EndIf
	If oConsole<>NIL
		ProcessMessage()
	EndIf
	Trata()
	sleep(50)
EndDo
For nI := 1 to nQtdTer
	__Status      	:=Val(Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),03,		1))   //2
	If __Status == 2 .or. __Status == 4
		GeraFim(nI,.t.)
		GravaCol(nI,"Status","1")
		Console("Desativado Microterminal "+Strzero(nI-1,2))
	EndIf
Next
FErase("TERGER"+cComutadora+".ATV")
console("Desativado o gerenciador de Microterminais ")
If lLPT
	If nHDLL <> -1
		ExecInDLLClose(nHDll)
	EndIf
Else
	oObj:CloseConnection()
EndIf
If oConsole<>NIL
	__cInternet:=NIL
	memowrit("MT"+xComutadora+".FIM","FIM")
	Final("Termino Normal")
EndIf
Return

Static Function CargaIni()
Local cEstTer
Local cConteudo
Local nI
Compatibiliza()
cIniFile := "TERGER"+cComutadora+".INI"
nQtdTer  := Val(GetPvProfString( "SETUP", "QTDTER" , "32", cIniFile ))
cPorta   := Alltrim(GetPvProfString( "SETUP","Portalpt" , "LPT1", cIniFile ))
nTimeOut := Val(GetPvProfString( "SETUP", "Timeout" , "130", cIniFile ))
cIP      := Alltrim(GetPvProfString( "SETUP","TcpIP" , "", cIniFile ))

PutGlbValue(Left(cIniFile,8),StrZero(nQtdTer,2)+Left(cPorta,4)+Padr(cIP,20)+Strzero(nTimeOut,5))

// 12 3456 78901234567890123456 78901
// QT PORT IP                   Timeout
// campo			pos	tamanho
// Qtde		01	2
// Porta	   03	4
//	IP			07	20
//	TimeOut	27	5
// nQtdTer := Val(Subs(GetGlbValue(Left(cIniFile,8)),1,2))
// cPorta  := Subs(GetGlbValue(Left(cIniFile,8)),3,4)
// cIP     := Alltrim(Subs(GetGlbValue(Left(cIniFile,8)),7,20))
// nTimeOut:= Val(Subs(GetGlbValue(Left(cIniFile,8)),27,5))

For nI := 1 to nQtdTer
	cEstTer := "TER"+StrZero(nI-1,2)
	cConteudo :=""
	cConteudo := StrZero(val(GetPvProfString( cEstTer, "Terminal"	, StrZero(nI-1,2)	, cIniFile )),2)
	If ! File("TERGER"+cComutadora+".ATV")
		cConteudo +=             GetPvProfString( cEstTer, "Status"		, "0"            	, cIniFile )
	Else
		cConteudo +=             GetPvProfString( cEstTer, "Status"		, "1"            	, cIniFile )
	EndIf
	cConteudo += StrZero(Val(GetPvProfString( cEstTer, "Paralela" 	, StrZero(nI-1,2)	, cIniFile )),2)
	cConteudo += StrZero(Val(GetPvProfString( cEstTer, "Serial" 	, StrZero(nI-1,2)	, cIniFile )),2)

	If ! File("TERGER"+cComutadora+".ATV")
		cConteudo += Padr(       GetPvProfString( cEstTer, "Rotina" 	, "" 	           	, cIniFile ),20)
	ELSE
		cConteudo += Padr( "x",20)         	
	EndIf
	cConteudo +=             GetPvProfString( cEstTer, "Empresa" 	, "99"           	, cIniFile )
	cConteudo +=             GetPvProfString( cEstTer, "Filial" 	, "01"           	, cIniFile )
	cConteudo += Padr(       GetPvProfString( cEstTer, "Parametros", ""           	, cIniFile ),20)
	cConteudo +=             GetPvProfString( cEstTer, "Simula" 	, "0"           	, cIniFile )
	cConteudo += Padr(       GetPvProfString( cEstTer, "Modulo" 	, ""           	, cIniFile ),3)
	cConteudo +=             GetPvProfString( cEstTer, "Modelo" 	, "MT44"        	, cIniFile )
	PutGlbValue("INI"+cComutadora+StrZero(nI-1,2),cConteudo)

	// 12 3 45 67 89012345678901234567 89 01 23456789012345678901 2 345 6789
	// TE S PA SE ROTINA               EM FI PARAMETROS           S MOD MODE
	// campo			pos	tamanho
	// Terminal 	01 	2
	// Status      03		1
	// Paralela    04		2
	// Serial		06		2
	// Rotina 		08		20
	//	Empresa		28		2
	// Filial 		30		2
	// Parametros	32		20
	// Simula 		52   	1
	// Modulo		53		3
	// Modelo		56		4

Next
Return .t.


Static Function Trata()
Local nI
Local cResult
Local nL1,nC1
Local nL2,nC2
Local cTela
Local __Terminal
Local __Status
Local __Paralela
Local __Serial	
Local __Rotina
Local __Empresa
Local __Filial
Local __Parametros
Local __Simula 	
Local __Modulo		
Local __Modelo		

If ! Empty(cIP)
	TerReceive()
EndIf	
For nI := 1 to nQtdTer
	nTerminal := nI-1
	__Status      	:=Val(Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),03,		1))   //2
	__Paralela    	:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),04,		2)       //3
	__Serial			:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),06,		2)       //4
	__Rotina 		:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),08,		20)      //5

	GFlushprn()
	GFlushcom()

	If __Status == 1 .and. !Empty(__Rotina)
		__Terminal 		:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),01,		2)  		//1
		__Empresa		:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),28,		2)       //6
		__Filial 		:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),30,		2)       //7
		__Parametros	:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),32,		20)      //8
		__Simula 		:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),52,   	1)       //9
		__Modulo			:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),53,		3)       //10
		__Modelo			:=Subs(GetGlbValue("INI"+cComutadora+StrZero(nI-1,2)),56,		4)       //11
		console("Ativado o terminal "+Strzero(nI-1,2))
		TerInicio("TER"+cComutadora+StrZero(nTerminal,2))
		GravaCol(ni,"Status","2")
		aStatusAnt[nI]:=2
		__Status := 2
		StartJob("TERJOB",GetEnvServer(),.F.,__Empresa,__Filial,cComutadora,__Terminal,AllTrim(__Rotina),__Modulo,__Parametros,__Modelo)
	EndIf


	If __Status == 0 .and. aStatusAnt[nI]<>0  // 0- desabilitado pelo termanu
		GeraFim(nI)
		console("Desabilitado o terminal "+Strzero(nI-1,2))
		aStatusAnt[nI]:=0
		Loop
	EndIf

	If Str(__Status,1) $ "0-1-4"
		Loop
	EndIf
	cTela :=GetGlbValue("MON"+cComutadora+StrZero(nTerminal,2))
	If ! Empty(cTela)
		PutGlbValue("MON"+cComutadora+StrZero(nTerminal,2),aLinha1[nI]+chr(13)+chr(10)+aLinha2[nI])
	EndIf
	If aEstado[nI] == 1    // Leitura de solicitacoes
		cResult := TerRet(cComutadora+StrZero(nTerminal,2))
		If SubStr(cResult,1,1) == "E"
			aEstado[nI] := Val(SubStr(cResult,2,2))
			aParametro[nI] := SubStr(cResult,4)
		Else
			Loop
		EndIf
	EndIf
	If aEstado[nI] == 3    // Funcao Limpa Tela
		GClear()
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 4    // Posiciona o Cursor
		GPosCursor(Val(SubStr(aParametro[nI],1,2)),Val(SubStr(aParametro[nI],3,2)))
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 5    // Display
		GDisplay(aParametro[nI])
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 6    // Carrega picture
		GGet(aParametro[nI])
		SalvaMEM(cComutadora+StrZero(nTerminal,2),aLin[nTerminal+1],aCol[nTerminal+1],aTeclado[nTerminal+1],aPicture[nTerminal+1],aPosPic[nTerminal+1])
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 7    // GET
		If GTrataTecla()
			TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
			aEstado[nI] := 1
		EndIf
		SalvaMEM(cComutadora+StrZero(nTerminal,2),aLin[nTerminal+1],aCol[nTerminal+1],aTeclado[nTerminal+1],aPicture[nTerminal+1],aPosPic[nTerminal+1])
		Loop
	ElseIf aEstado[nI] == 8    // Inkey
		aTeclado[nI]:=Chr(GPedeTecla())
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 9    // Setup
		If Empty(SubStr(aParametro[nTerminal+1],1,2))
			If SubStr(aParametro[nTerminal+1],3,1) == "P"
				aTerImp[nTerminal+1] := Val(__Paralela)+1
			Else
				aTerImp[nTerminal+1] := Val(__Serial)+1
			EndIf
		Else
			aTerImp[nTerminal+1] := Val(SubStr(aParametro[nTerminal+1],1,2))
		EndIf
		aTipImp[nTerminal+1] := SubStr(aParametro[nTerminal+1],3,1)
		If aImpLib[aTerImp[nTerminal+1]]
			If !Empty(SubStr(aParametro[nTerminal+1],4,2))
				aVelImp[aTerImp[nTerminal+1]] := Val(SubStr(aParametro[nTerminal+1],4,2))
			EndIf
			aImpLib[aTerImp[nTerminal+1]] := .F.
			TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
			aEstado[nI] := 1
		EndIf
		Loop
	ElseIf aEstado[nI] == 10    // TerPrint
		If !Empty(aTipImp[nTerminal+1]) .and. (aTerImp[nTerminal+1] > 0)
			If aTipImp[nTerminal+1] == "P"
				If Empty(aPPrinter[aTerImp[nTerminal+1]])
					aPPrinter[aTerImp[nTerminal+1]] += aParametro[nTerminal+1]
					TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
					aEstado[nI] := 1
				EndIf
			Else
				If Empty(aSPrinter[aTerImp[nTerminal+1]])
					aSPrinter[aTerImp[nTerminal+1]] += aParametro[nTerminal+1]
					TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
					aEstado[nI] := 1
				EndIf
			EndIf
		EndIf
		Loop
	ElseIf aEstado[nI] == 11    // TerPEnd()
		aImpLib[aTerImp[nTerminal+1]] := .T.
		aTerImp[nTerminal+1] := 0
		aTipImp[nTerminal+1] := ""
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 12    // Finalizando
		__Status := 4
		GravaCol(ni,"Status","4")
		GeraFim(nI)
		aEstado[nI]  := 1
		Loop
	ElseIf aEstado[nI] == 13    // Beep
		GBeep()
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 14    // SaveScreen
		nL1 := Val(SubStr(aParametro[nI] ,1,1))
		nC1  := Val(SubStr(aParametro[nI],2,2))
		nL2 := Val(SubStr(aParametro[nI] ,4,1))
		nC2  := Val(SubStr(aParametro[nI],5,2))
		aTeclado[nI] := ""
		If nL1 == 0
			aTeclado[nI] += SubStr(aLinha1[nI],nC1,nC2-nC1+1)
		EndIf
		If nL2 == 1
			aTeclado[nI] += SubStr(aLinha2[nI],nC1,nC2-nC1+1)
		EndIf
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	ElseIf aEstado[nI] == 15    // Carrega Get
		ValueGet(aParametro[nI])
		TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
		aEstado[nI] := 1
		Loop
	EndIf
Next
Return


Static Function GravaCol(ni,cColuna,uconteudo)
Local cString := GetGlbValue("INI"+cComutadora+StrZero(nI-1,2))
cString := Stuff(cString,3,1,uConteudo)
PutGlbValue("INI"+cComutadora+StrZero(nI-1,2),cString)
Return

Static Function GeraFim(nTerm,lAbort)
DEFAULT lAbort := .T.
If lAbort
	TerAbort("TER"+cComutadora+StrZero(nTerm-1,2)+".FIM")
	Acesso(StrZero(nTerm-1,2)+"L")
	Acesso(StrZero(nTerm-1,2)+"L")
	Acesso(StrZero(nTerm-1,2)+"C000")
	Acesso(StrZero(nTerm-1,2)+"D"+Padc("MICROSIGA SOFTWARE S/A",40))
	Acesso(StrZero(nTerm-1,2)+"C100")
	Acesso(StrZero(nTerm-1,2)+"D"+Padc("MICROTERMINAL FINALIZADO",40)) //
	aLinha1[nTerm] := PadC("MICROSIGA SOFTWARE S/A",40)
	aLinha2[nTerm] := PadC("MICROTERMINAL FINALIZADO",40) //
	Sleep(500)
Else
	TerAbort("TER"+cComutadora+StrZero(nTerm-1,2)+".AGU")
EndIf
Return


Static Function GFlushPrn()
Local cAux := ""
Local nX := 0
Local nY := 0
Local cComando

If aVelImp[nTerminal+1] == 0
	aVelImp[nTerminal+1] := 3
EndIf
cComando := If(Empty(cIP),"I","P")
nX := 1
While nX <= Len(aPPrinter[nTerminal+1]) .and. nX <= (aVelImp[nTerminal+1]*25) //(aVelImp[nTerminal+1]*40)
	cAux := SubStr(aPPrinter[nTerminal+1],nX,1)
	If Acesso(StrZero(nTerminal,2)+cComando+cAux,,"P")==1
		nY := 0
		nX++
	Else
		nY++
	EndIf
	If nY > 3
		Exit
	EndIf
EndDo
aPPrinter[nTerminal+1] := SubStr(aPPrinter[nTerminal+1],nX)
Return


Static Function GFlushCom()
Local cAux := ""
Local nX := 0
Local nY := 0
Local cComando
If aVelImp[nTerminal+1] == 0
	aVelImp[nTerminal+1] := 3
EndIf
cComando := If(Empty(cIP),"R","S")

nX := 1
While nX <= Len(aSPrinter[nTerminal+1]) .and. nX <= (aVelImp[nTerminal+1]*25)
	cAux := SubStr(aSPrinter[nTerminal+1],nX,1)
	If Acesso(StrZero(nTerminal,2)+cComando+cAux,,"S")==1
		nY := 0
		nX++
	Else
		nY++
	EndIf
	If nY > 3
		Exit
	EndIf
EndDo
aSPrinter[nTerminal+1] := SubStr(aSPrinter[nTerminal+1],nX)
Return

Static Function GClear()
Acesso(StrZero(nTerminal,2)+"L")
//Acesso(StrZero(nTerminal,2)+"L")
aLinha1[nTerminal+1] := Space(40)
aLinha2[nTerminal+1] := Space(40)
aLin[nTerminal+1]    := 0
aCol[nTerminal+1]    := 0
Return

Static Function GPosCursor(nLin,nCol)
Acesso(StrZero(nTerminal,2)+"C"+Str(nLin,1)+StrZero(nCol,2))
aLin[nTerminal+1]    := nLin
aCol[nTerminal+1]    := nCol+1
Return

Static Function GDisplay(cStr)
Local cLinha1,cLinha2
Local nCol
Local cStrAnt
cLinha1 := aLinha1[nTerminal+1]
cLinha2 := aLinha2[nTerminal+1]
nCol    := aCol[nTerminal+1]
cStrAnt := cStr
Acesso(StrZero(nTerminal,2)+"D"+cStr)
If cStr == Chr(08)
	cStr := " "
	nCol := If(nCol#0,nCol-1,nCol)
EndIf
If aLin[nTerminal+1] == 0
	aLinha1[nTerminal+1] := Stuff(cLinha1,nCol,Len(cStr),cStr)
EndIf
If aLin[nTerminal+1] == 1
	aLinha2[nTerminal+1] := Stuff(cLinha2,nCol,Len(cStr),cStr)
EndIf
If cStrAnt == Chr(08)   // se for backspace
	aCol[nTerminal+1] -= 1
Else
	aCol[nTerminal+1] += Len(cStr)
EndIf
Return

Static Function GBeep(nVezes)
Local cComando := If(Empty(cIP),"A","G")
Local cAtiva   := If(Empty(cIP),Chr(15),Chr(15))
Local cDesativa:= If(Empty(cIP),Chr(0),Chr(12))
Acesso(StrZero(nTerminal,2)+cComando+cAtiva)
Sleep(100)
Acesso(StrZero(nTerminal,2)+cComando+cDesativa)
Return

Static Function GPedeTecla()
Local nTecla := 0
nTecla := Acesso(StrZero(nTerminal,2),3)
Return nTecla

Static Function GGet(cPicture)
If !aWaitKbd[nTerminal+1]
	aWaitKbd[nTerminal+1] := .f.
	aPosPic[nTerminal+1]  := 1
	aPicture[nTerminal+1] := cPicture
EndIf
Return

Static Function ValueGet(cValor)
If !aWaitKbd[nTerminal+1]
	aWaitKbd[nTerminal+1] := .t.
	aTeclado[nTerminal+1] := cValor
EndIf
Return

Static Function Acesso(cStr,nTipo,cImpressao)
Local cPar
Local nTerm := Val(SubStr(cStr,1,2))
Local uRet  :=0
Local cTemp
Local cComando
Local cRestcodigo
Local nPos
Local nT
Local nRetSend:= 0
Local nVezesT:=0
DEFAULT nTipo := 2
DEFAULT cImpressao:= ""
If Empty(cIP)
	cStr := If(nTipo==2,chr(254)+cStr,cStr)
	If !lConfig
		cPar := SubStr(cPorta,4,1)+StrZero(nTimeOut,5)
		uRet:= ExeDLLRun2(nHDll, 1, cPar )
		If uRet == 5
			Console("Falha na configuracao da LPT1, favor verificar infra-estrutura")
			Return uRet
		EndIf
		lConfig := .T.
	EndIf

	If nTipo==3
		cStr:=Padr(cStr,22)
		nTipo := 4
	EndIf

	uRet:= ExeDLLRun2(nHDll, nTipo,@cStr)
	If uRet == 5
		Console("Terger.dll nao compativel, favor atualizar DLL")
	EndIf
	If nTipo == 4
		uRet:=asc(left(cStr,1))
		For nT:= 2 to len(cStr)
			If subs(cStr,nT,1) == chr(0)
				cStr:= Stuff(cStr,nT,1," ")
			EndIf
		Next
		If ! Empty(Alltrim(Subs(cStr,2)))
			nPos := At(chr(13),cStr)
			If nPos > 0
				aBuffer[nTerm+1] += Alltrim(Subs(cStr,2,nPos-1))
			Else
				aBuffer[nTerm+1] += Alltrim(Subs(cStr,2))
			EndIf
		EndIf
	EndIf
	If uRet == -1
		Console("problema no envio de dados para DLL")
	EndIf
Else
	cComando := Subs(cStr,3,1)
	cRestcodigo := subs(cStr,4)
	cStr := cComando+strzero(nTerm,2)+cRestCodigo
	cStr := chr(2)+cStr+chr(3)
	If !  oObj:IsConnected()
		Console( "TerServ - Problema de conexao TCPIP" )
		return 0
	EndIf
	If nTipo == 2
		nRetSend := oObj:Send( cStr )
		If cImpressao $ "PS"
			nVezesT := 0
			while .T.
				TerReceive(2000)
				If cImpressao =="P"
					cTemp:= Left(aBufferP[nTerm+1],1)
					If cTemp=="" .and. nVezesT++ < 11
						Loop
					EndIf
					If nVezesT >=10
						Conout('TerServ - Estouro de tentativas da leitura do retorno da impressao paralela')  		   	
					EndIf
					uRet := val(cTemp)
					aBufferP[nTerm+1] := Subs(aBufferP[nTerm+1],2)
				ElseIf cImpressao =="S"	
					cTemp:= Left(aBufferS[nTerm+1],1)
					If cTemp=="" .and. nVezesT++ < 11
						Loop
					EndIf
					If nVezesT >=10
						Conout('TerServ - Estouro de tentativas da leitura do retorno da impressao serial')  		   	
					EndIf   		   	
					uRet := val(cTemp)
					aBufferS[nTerm+1] := Subs(aBufferS[nTerm+1],2)
				EndIf
				exit
			Enddo
		EndIf
	ElseIf nTipo == 3
		cTemp:= Left(aBuffer[nTerm+1],1)
		uRet := asc(cTemp)
		aBuffer[nTerm+1] := Subs(aBuffer[nTerm+1],2)
	EndIf
EndIf
Return uRet



Static Function TerReceive(nTOut)
Local uTemp:=""
DEFAULT nTOut:=0
oObj:Receive( @uTemp, nTOut )
TerAtuBuffer(uTemp)
Return


Static Function TerAtuBuffer(cRet)
Local nTermAux
While ! Empty(cRet)
	If subs(cRet,2,1)<>chr(27) //retorno de teclado
		nTermAux := Val(subs(cRet,2,2))+1
		aBuffer[nTermAux] +=subs(cRet,4,1)
		cRet := subs(cRet,6)
	ElseIf subs(cRet,2,1)==chr(27)// retorno de impressao
		nTermAux := Val(subs(cRet,3,2))+1
		If subs(cRet,5,1)==chr(2) .or. subs(cRet,5,1)=="" // impressora nao respondeu
			aBufferP[nTermAux] +="0"
			cRet := subs(cRet,5)
		ElseIf subs(cRet,6,1)=="P"
			aBufferP[nTermAux] +="1"
			cRet := subs(cRet,8)
		ElseIf subs(cRet,6,1)=="S"
			aBufferS[nTermAux] +="1"
			cRet := subs(cRet,8)			
		EndIf
	EndIf
End
Return NIL

Static Function GTrataTecla()
Local cPic,cTecla,nTamanho
Local lRet := .F.
Local nPosPonto
Local nDec
Local nCol,nLin
Local cParteBuffer:=""
Local nPos
Local nTamPic
While .t.
	cPic := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1],1)
	If ! Empty(aBuffer[nTerminal+1]) .and. len(aBuffer[nTerminal+1])> 0 .and. cPic$"XA"
		nTamPic := len(aPicture[nTerminal+1])
		If Right(aPicture[nTerminal+1],1)=="@"
			nTamPic--
		EndIf
		nPos := At(chr(13),aBuffer[nTerminal+1])
		If nPos > 0
			cParteBuffer:=Left(aBuffer[nTerminal+1],nPos-1)
			aBuffer[nTerminal+1]:=Subs(aBuffer[nTerminal+1],nPos+1)
		Else	
			cParteBuffer:=Left(aBuffer[nTerminal+1],nTamPic-aPosPic[nTerminal+1]-1)
			aBuffer[nTerminal+1]:= Subs(aBuffer[nTerminal+1],len(cParteBuffer)+1)
		EndIf

		aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],len(cParteBuffer),cParteBuffer)
		aPosPic[nTerminal+1]+=len(cParteBuffer)
		GDisplay(cParteBuffer)
		cPic     := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1],1)
		If cPic == "@"
			aBuffer[nTerminal+1]:=""
			Return .f.
		ElseIf nPos > 0
			aWaitKbd[nTerminal+1] := .F.
			Return .T.
		ElseIf cPic ==""
			aWaitKbd[nTerminal+1] := .F.
			Return .T.
		EndIf
	EndIf
	cTecla := Chr(GPedeTecla())

	If cTecla == Chr(0) .or. cTecla == "*"
		Return .F.
	ElseIf cTecla =="."
		If cPic=="9" .and. At(".",aPicture[nTerminal+1]) ==0
			Return .f.
		EndIf	
	ElseIf cTecla == Chr(13)  // enter
		aWaitKbd[nTerminal+1] := .F.
		Return .T.
	ElseIf cTecla == Chr(127) // DEL (no microterminal consideramos esta tecla como o ESC)
		aTeclado[nTerminal+1] := Chr(127)
		aWaitKbd[nTerminal+1] := .F.
		Return .T.
	ElseIf cTecla == Chr(08) // backspace
		If aPosPic[nTerminal+1] > 1
			cPic := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1]-1,1)
			If cPic $ "/.-"
				nCol := aCol[nTerminal+1]-1
				nLin := aLin[nTerminal+1]
				GPosCursor(nLin,nCol-1)
				aPosPic[nTerminal+1]--
			EndIf
			aPosPic[nTerminal+1]--
			aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1," ")
			GDisplay(Chr(08))
		EndIf
		Return .F.
	ElseIf cPic == "@"
		Return .F.
	EndIf
	nPosPonto := At(".",aPicture[nTerminal+1])
	nDec :=0
	If nPosPonto >0
		nDec:= Len(aPicture[nTerminal+1])-nPosPonto
	EndIf
	If cPic == "X"
		aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)
		aPosPic[nTerminal+1]++
		GDisplay(cTecla)
	ElseIf cPic == "9"
		If cTecla $ "0123456789."
			If cTecla == "." .and. nDec >0
				nCol := aCol[nTerminal+1]-1
				nLin := aLin[nTerminal+1]
				aTeclado[nTerminal+1]:= Padl(Alltrim(Left(aTeclado[nTerminal+1],nPosPonto-1)),nPosPonto-1)+Subs(aTeclado[nTerminal+1],nPosPonto)
				GPosCursor(nLin,nCol-aPosPic[nTerminal+1]+1)
				GDisplay(aTeclado[nTerminal+1])
				GPosCursor(nLin,nCol+(nPosPonto-aPosPic[nTerminal+1])+1)
				aPosPic[nTerminal+1]+=nPosPonto-aPosPic[nTerminal+1]+1
			Else
				If aPosPic[nTerminal+1] == 1
					If nDec > 0
						aTeclado[nTerminal+1] := Stuff(Space(len(aPicture[nTerminal+1])),nPosPonto,1,".")
					Else
						aTeclado[nTerminal+1] := Space(len(aPicture[nTerminal+1]))
					EndIF
					nCol := aCol[nTerminal+1]-1
					nLin := aLin[nTerminal+1]
					GDisplay(aTeclado[nTerminal+1])
					GPosCursor(nLin,nCol)
					aTeclado[nTerminal+1] := cTecla+Subs(aTeclado[nTerminal+1],2)
				Else
					aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)
				EndIf
				aPosPic[nTerminal+1]++
				GDisplay(cTecla)
			EndIf
		EndIf
	ElseIf cPic == "A"
		If Upper(cTecla) >= "A" .and. Upper(cTecla) <= "Z"
			aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)	
			aPosPic[nTerminal+1]++
			GDisplay(cTecla)
		EndIf
	ElseIf cPic == "*"
		aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)	
		aPosPic[nTerminal+1]++
		GDisplay("*")
	EndIf
	nTamanho := Len(aPicture[nTerminal+1])
	If "@" $ aPicture[nTerminal+1]
		nTamanho--
	EndIf
	cPic     := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1],1)
	If cPic == "@"
		Return .f.
	ElseIf cPic ==""
		aWaitKbd[nTerminal+1] := .F.
		Return .T.
	ElseIf cPic $ "/.-"
		cTecla := cPic
		aPosPic[nTerminal+1]++
		GDisplay(cTecla)
		Return .F.
	Else
		Return .F.
	EndIf
EndDo
Return lRet

Static Function MsgGet2( cTitle, cText, uVar, cIcoFile, bValidGet, cPict )
Local oDlg
Local lOk	:= .f.
Local oGet
DEFAULT uVar	  := ""
DEFAULT cText	  := ""
DEFAULT cTitle   := "Atencao"
DEFAULT bValidGet:= {||.T.}
DEFAULT cIcoFile := "WATCH"
DEFAULT cPict	  := ""
DEFINE MSDIALOG oDlg FROM 10, 20 TO 18, 49.5 TITLE cTitle //OF GetWndDefault()
@ 1, 5 SAY cText OF oDlg SIZE 30, 20
@ 2, 6 MSGET oGet VAR uVar SIZE 15, 10 OF oDlg PICTURE cPict
oGet:bGotFocus := {|| oGet:SetPos(0)}
oGet:Set3dLook()
oGet:bValid := bValidGet
@ 0.5, 1 ICON RESOURCE cIcoFile OF oDlg
@ 4, 5 BUTTON "&Ok" OF oDlg SIZE 35, 12 	ACTION If(len(Alltrim(uVar))#2,(alert("Comutadora invalida"),.f.),( oDlg:End(), lOk := .T. ))
@ 4, 15 BUTTON "&Cancela" OF oDlg SIZE 35, 12 ACTION ( oDlg:End(), lOk := .F. ) CANCEL
ACTIVATE MSDIALOG oDlg CENTERED
Return lOk



Static Function Compatibiliza()
Local cIniFile := "TERGER"+cComutadora+".INI"
Local cIniAnt  := "TERMINAL.INI"
Local uAux
Local nVersao
Local cEstTer
Local cEstTerAnt
Local nI

nVersao     := Val(GetPvProfString( "SETUP", "Versao" , "1", cIniAnt ))
If nVersao == 1
	uAux      := PadR(GetPvProfString( "SETUP", "Portalpt" , "LPT1", cIniAnt ),4)
	WritePPros( "SETUP", "Portalpt" , uAux, cIniFile )

	uAux     := GetPvProfString( "SETUP", "QTDTER" , "0", cIniAnt )
	WritePPros( "SETUP", "QTDTER" , uAux, cIniFile )

	uAux     := GetPvProfString( "SETUP", "Timeout" , "130", cIniAnt )
	WritePPros( "SETUP", "Timeout" , uAux, cIniFile )

	WritePPros( "SETUP", "Versao" , "2", cIniAnt )
	WritePPros( "SETUP", "Versao",  "2",cIniFile)

	For nI := 1 to 32
		cEstTer := "TER"+StrZero(nI-1,2)
		cEstTerAnt := "TER"+cComutadora+StrZero(nI-1,2)
		uAux := GetPvProfString( cEstTerAnt, "Terminal"	, StrZero(nI-1,2)	, cIniAnt )
		WritePPros( cEstTer, "Terminal" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Status"		, "0"            	   , cIniAnt )
		uAux := If(Upper(AllTrim(uAux))=="DESABILITADO","0","1")
		WritePPros( cEstTer, "Status" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Serial"		, StrZero(nI-1,2)	, cIniAnt )
		WritePPros( cEstTer, "Serial" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Paralela"	, StrZero(nI-1,2)	, cIniAnt )
		WritePPros( cEstTer, "Paralela" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Rotina"		, ""						, cIniAnt )
		WritePPros( cEstTer, "Rotina" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Empresa"		, "99"					, cIniAnt )
		WritePPros( cEstTer, "Empresa" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Filial"   	, "01"					, cIniAnt )
		WritePPros( cEstTer, "Filial" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Parametros"	, ""						, cIniAnt )
		WritePPros( cEstTer, "Parametros" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Simula"    	, "0"	  				   , cIniAnt )
		uAux := If(Upper(AllTrim(uAux))=="SIM","1","0")
		WritePPros( cEstTer, "Simula" , uAux, cIniFile )
		uAux := GetPvProfString( cEstTerAnt, "Modulo"   	, ""   					, cIniAnt )
		WritePPros( cEstTer, "Modulo" , uAux, cIniFile )
	Next
EndIf

Return

Static Function  SalvaMEM(cMT,nLin,nCol,cBuffer,cPicture,nPosPic)
Local cConteudo := ""
cConteudo += Str(nLin,1)
cConteudo += Str(nCol,2)
cConteudo += Str(nPosPic,2)
cConteudo += Padr(cPicture,40)
cConteudo += cBuffer
PutGlbValue("MEM"+cMT,cConteudo)
Return

Static Function  LoadMEM(cMT,nPos)
Local cConteudo := GetGlbValue("MEM"+cMT)
Local aVetor :=array(5)
//        1         2         3         4        5         6        7         8
//1234567890123456789012345678901234567890123456789012345678901234678901234567890
//112121234567890123456789012345678901234567890
aVetor[1] := Val(Subs(cConteudo,1,1))        // 1-nlin
aVetor[2] := Val(Subs(cConteudo,2,2))        // 2-ncol
aVetor[3] := Val(Subs(cConteudo,4,2))        // 3-pospicture
aVetor[4] := Alltrim(Subs(cConteudo, 6,40))  // 4-cpicture
aVetor[5] := Alltrim(Subs(cConteudo,46))     // 5-cbuffer
Return aVetor[nPos]
