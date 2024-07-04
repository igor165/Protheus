#Include 'Protheus.ch'  
#INCLUDE "PCOA301.CH"

Static __lBlind  := IsBlind()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัอออออออออออออออออออออออออหออออัออออออออปฑฑ
ฑฑบPrograma  ณPCOA301       บAutorณJose Domingos Caldana Jr บDataณ22/05/13บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯอออออออออออออออออออออออออสออออฯออออออออนฑฑ
ฑฑบDesc.     ณ Reprocessamento de Saldos dos Cubos - MultiThreads         บฑฑ
ฑฑบ          ณ Rotina inicial com tela de parametros                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOA301(lAuto, aParametro)

Local nThread   	:= SuperGetMv("MV_PCOTHRD",.T.,2)
Local cFunction		:= "PCOA301"
Local cPerg			:= "PCA300"
Local cTitle		:= STR0026 //"Reprocessamento dos Saldos - (Multi-Threads)"
Local cMensagem1	:= STR0027 //" Este programa tem como objetivo reprocessar os saldos dos cubos de um "
Local cMensagem2	:= STR0028 //" determinado perํodo. Neste reprocessamento serใo utilizados at้ "
Local cMensagem3	:= STR0029 //" processos simultโneos. Para alterar a quantidade de processos simultโneos"
Local cMensagem4	:= STR0030 //" consulte o parโmetro MV_PCOTHRD. "

Local cDescription	:= cMensagem1+cMensagem2+AllTrim(STR(nThread))+cMensagem3+cMensagem4
Local oTProces
Local bProcess		:= { |oSelf| PCOA301EXE(oSelf) }
Local cChave
Local aConfig        := Array(6)

DEFAULT lAuto := .F.
DEFAULT aParametros := {}



DbSelectArea("AL1")
cChave := AllTrim(cEmpAnt)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")

If !LockByName("PCOA300"+cChave,.F.,.F.)
	Help(" ",1,"PCOA301US",,STR0031,1,0) //"Outro usuario estแ usando a rotina "
	Return
EndIf

If lAuto .And. Len(aParametros) > 0
	
	MV_PAR01 := aParametros[1]  //Cubo de
	MV_PAR02 := aParametros[2]  //Cubo Ate
	MV_PAR03 := aParametros[3]  //data de 
	MV_PAR04 := aParametros[4]  //data ate
	MV_PAR05 := aParametros[5]  //Considera todos os tipos de saldo 
	MV_PAR06 := aParametros[6]  //Tipo de saldo especifico
	
	__lBlind := .T.

	aConfig[1] := MV_PAR01
	aConfig[2] := MV_PAR02
	aConfig[3] := MV_PAR03
	aConfig[4] := MV_PAR04
	aConfig[5] := ( MV_PAR05 == 2 )
	aConfig[6] := IIF(MV_PAR05 == 2,"( '"+AllTrim(MV_PAR06)+"' )","")
		
	lRet := PCOA301EXE(,lAuto, aConfig)

Else

	If !__lBlind 
		oTProces := TNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg, /*aInfoCustom*/,/*[lPanelAux]*/,/*[nSizePanelAux]*/,/*[cDescriAux]*/,/*[lViewExecute]*/,.T./*[lOneMeter]*/)
	Else
	 	Eval(bProcess)
	EndIf
	
EndIf

UnLockByName("PCOA300"+cChave,.F.,.F.)

//ConoutR(STR0032+TIME()) //"VERIFICACAO SALDOS CUBOS-INICIO "
//A300ChkCub(MV_PAR01, MV_PAR02, .T.)
//ConoutR(STR0033+TIME()) //"VERIFICACAO SALDOS CUBOS-FINALIZADO "

ConoutR("[PCOA301]",.T., "PCOA301")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัอออออออออออออออออออออออออหออออัออออออออปฑฑ
ฑฑบPrograma  ณPCOA301EXE    บAutorณJose Domingos Caldana Jr บDataณ22/05/13บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯอออออออออออออออออออออออออสออออฯออออออออนฑฑ
ฑฑบDescriao ณReprocessamento de Saldos dos Cubos - MultiThreads          บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบParametrosณParametros do array a Rotina:                               บฑฑ
ฑฑบ          ณ1. Objeto da Tela para manipular barra de progressใo        บฑฑ
ฑฑบ          ณ2. Indica se a rotina foi chamada por outra, por isso nใo   บฑฑ
ฑฑบ          ณ   manipula barra de prograssใo                             บฑฑ
ฑฑบ          ณ3. Parametros de execu็ใo                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOA301EXE(oTProces,lAuto,aConfig)

Local nThread		:= SuperGetMv("MV_PCOTHRD",.T.,2)
Local nZ			:= 0
Local nX			:= 0
Local aTmpDim		:= {}
Local lRet			:= .T.
Local nQtdCub		:= 0
Local dDataIni		:= ctod("  /  /  ")
Local dDataFim		:= ctod("  /  /  ")
Local lExit			:= .F.
Local nKilled		:= 0
Local nHdl			:= 0
Local cMsgComp		:= ""
Local aNivelAux		:= {}
Local cChave		:= ""
Local cTpSld		:= ""
Local aDtProc       := {}
Local lPcoa310 		:= IsInCallStack("PCOA310")
Local cArquivo      := ""
Private oGrid		:= Nil

Default lAuto		:= .F.
Default aConfig		:= { , , , , , }

If nThread < 2 .Or. nThread > 10
	Help(" ",1,"PCOA301TRD",,STR0034,1,0) //"Quantidade de Thread nใo permitida."
	Return
EndIf 

If !lAuto
	aConfig[1] := MV_PAR01
	aConfig[2] := MV_PAR02
	aConfig[3] := MV_PAR03
	aConfig[4] := MV_PAR04
	aConfig[5] := ( MV_PAR05 == 2 )
	aConfig[6] := IIF(MV_PAR05 == 2,"( '"+AllTrim(MV_PAR06)+"' )","")
EndIf

//saldos diarios para reprocessamento
dDataIni := aConfig[3]
dDataFim := aConfig[4]

If dDataFim < dDataIni
	Help(" ",1,"PCOA301DTF",,STR0035,1,0) //"Data final invalida. Verifique!"
	Return
EndIf 

If dDataFim - dDataIni > 366
	Help(" ",1,"PCOA301ANO",,STR0036,1,0) //"Intervalo de datas superior ao periodo maximo permitido de  01 ano. Diminua o intervalo e execute novamente!"
	Return
EndIf 

If dDataFim - dDataIni < 30
	aAdd(aDtProc, {dDataIni, dDataFim})
Else
	//grava as datas no array aDtProc para processar de 15 em 15 dias 
	PcoRetPer(dDataIni, dDataFim, "2"/*cTipoPer*/, .F. /*lAcumul*/, @aDtProc)
EndIf

If Len(aDtProc) == 0 
	Help(" ",1,"PCOA301DTF",,STR0037,1,0) //"Data invalida. Verifique!"
	Return
EndIf

If Empty(cTpSld) .And. ! aConfig[5] 
	lTpSld := .T.  //todos os saldos
	cTpSld := ""
Else
	If aConfig[5] .And. !Empty(cTpSld) //tipo de saldo especifico 
		lTpSld := .F.
		cTpSald := aConfig[6]
	Else
		lTpSld := .T.  //todos os saldos
		cTpSld := ""
	EndIf
EndIf

If lRet

	If !MSFile("PCOTMP", ,__CRDD )
		P301CriTmp()					
	EndIf	
	
	If Select("PCOTMP")==0
		dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
	EndIf	
	
	cArquivo := CriaTrab(,.F.)
	
	aTmpDim := {}
	dbSelectArea("AL1")
	dbSeek(xFilial("AL1")+aConfig[1],.T.)
	While AL1->( ! Eof() .And. AL1_FILIAL+AL1_CONFIG <= xFilial("AL1")+aConfig[2] )
		AADD(aNivelAux, {AL1->AL1_CONFIG})
		AL1->(dbSkip())
	EndDo

	cChave 	:= AllTrim(cEmpAnt)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_") 
	nQtdCub	:= Len(aNivelAux)
	nThread	:= IIF(nThread > nQtdCub*Len(aDtProc), nQtdCub*Len(aDtProc), nThread) //Configura a quantidade de threads considerando a quantidade de cubos

	If UPPER(Alltrim(TcGetDB())) == 'DB2'  //trataamento para DB2
		nThread	:= 1  	//colocado apenas em DB2 1 pois com 2 dava erros que nao foram identificados
						//a vantagem em relacao ao pcoa300 pq ele quebra de 15 em 15 dias para processar 
	EndIf

	If !__lBlind  .And. !lAuto
		oTProces:SetRegua1(nQtdCub+1)
	EndIf

	nCount := 0
	Do While !LockByName("PCOA301_"+AllTrim(STR(SM0->(RECNO()))),.T.,.T.)
		PcoAvisoTm(STR0038 ,STR0039,{"Ok"},,; //" Aguardando abertura da Thread para Atualiza็ใo de Saldos."//"Aten็ใo"
						STR0040,,"PCOLOCK",5000) //"Reprocessamento em Uso"
		nCount++
		If nCount > 20
			Alert( STR0041 ) //"Abandonando processo de reprocessamento de Saldos. Atualizar Saldo dos Cubos Novamente."
			Return
		EndIf
	EndDo

	UnLockByName( "PCOA301_"+AllTrim(STR(SM0->(RECNO()))), .T., .T. )
	
	oGrid := FWIPCWait():New("PCOA301_"+AllTrim(STR(SM0->(RECNO()))),10000)
	oGrid:SetThreads(nThread)
	oGrid:SetEnvironment(cEmpAnt,cFilAnt)
	oGrid:Start("PCOA301SLD")
	Sleep(3000)  //Aguarda 3 seg para abertura da thread para nใo concorrer na cria็ใo das procedures.

	For nZ := 1 TO Len(aDtProc)
		If !lPcoa310 
			dDataIni := If(ValType(aDtProc[nZ,1]) == 'C', SToD(aDtProc[nZ,1]), aDtProc[nZ,1])
			dDataFim := If(ValType(aDtProc[nZ,2]) == 'C', SToD(aDtProc[nZ,2]), aDtProc[nZ,2])
		EndIf
		
		For nX := 1 TO nQtdCub
			If !__lBlind  .And. !lAuto
				oTProces:IncRegua1(STR0042) //"Iniciando reprocessamento de saldo..."
			EndIf
			
			cCubo   := aNivelAux[nX,1]
			lRet 	:= oGrid:Go(STR0043, {cCubo,dDataIni,dDataFim,cChave,lTpSld,cTpSld},cArquivo) //"Chamando reprocessamento de saldos"
			If !lRet
				Exit
			EndIf
			Sleep(3000) //Aguarda 3 seg para abertura da thread para nใo concorrer na cria็ใo das procedures.
		Next nX	
	Next nZ			

	If !__lBlind  .And. !lAuto
		oTProces:IncRegua1(STR0044) //"Aguardando reprocessamento de saldos..."
	EndIf

	Sleep(2500*nThread) //Aguarda todas as threads abrirem para tentar fechar

	While !lExit	
		nKilled := P301ChkThd("PCOA301",cArquivo)
			
		If nKilled == nQtdCub*Len(aDtProc)
			Exit
		EndIf
		Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram
	EndDo

	cMsgComp := P301MsgCom("PCOA301",cArquivo)
	
	P301DelTmp("PCOA301",cArquivo)
EndIf

// Fechamento das Threads
oGrid:Stop()        //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

oGrid:RemoveThread(.T.)

FreeObj(oGrid)
oGrid := nil

If !IsInCallStack("PCOA310")
	Aviso(IIf(lRet,STR0007,STR0008),cMsgComp, {"Ok"})	//"Problema no processamento."//"Processo finalizado com sucesso."
EndIf 	

ConoutR(IIf(!lRet,STR0045,STR0046)+CRLF+cMsgComp)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA301SLD บAutor  ณMicrosiga           บ Data ณ  04/25/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Rotina executado em MultiThread para reprocessamento       บฑฑ
ฑฑบ          ณ  os saldo do Cubo                                           บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA301SLD(cParm,aParam,cArquivo)

Local lRet 		:= .F.
Local cCubo		:= aParam[1]  
Local dDataIni	:= aParam[2] 
Local dDataFim	:= aParam[3]
Local cChave	:= aParam[4]
Local lTpSld	:= aParam[5]
Local cTpSld	:= aParam[6]
Local nHdl 
Local cStart	:= ""
Local cEnd      := ""
Local nRecPCO   := 0
DEFAULT cArquivo:= ""

If cCubo == NIL .OR. dDataIni == NIL .OR. dDataFim == NIL .OR. cChave == NIL .OR. cTpSld == NIL
	Return(lRet)
EndIf

If Select("PCOTMP")==0
	dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
EndIf
	
If LockByName("PCOA301_"+cChave+"_CB_"+cCubo+DTOS(dDataFim),.T.,.T.)
	cStart := DTOC(Date())+" "+Time()		
	
	PCOTMP->(RecLock("PCOTMP",.T.))
    	PCOTMP->CPOLOG := UPPER(STR0047)+cCubo+" "+STR0048+DTOC(dDataIni)+STR0049+DTOC(dDataFIm)
    	PCOTMP->ORIGEM := "PCOA301"
    	PCOTMP->ARQUIVO:= cArquivo
    	PCOTMP->STATUS := "0"	   
    PCOTMP->(MsUnLock())
    nRecPCO := PCOTMP->(Recno())
    	
	lRet := PCOA300(.T./*lAuto*/, {cCubo/*de*/, cCubo/*Ate*/, dDataIni, dDataFim, If(lTpSld,1,2) /*lTodosSados*/, cTpSld /*Tp Sld Especifico*/} ) 
		
	cEnd := DTOC(Date())+" "+Time()
	
	PCOTMP->(dbGoTo(nRecPCO))
	PCOTMP->(RecLock("PCOTMP",.F.))
    	If lRet		
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+CRLF+"STARTED ["+cStart+"] - END ["+cEnd+"] - OK"
		Else
	    	PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+CRLF+"STARTED ["+cStart+"] - END ["+cEnd+"] - FAILED"
	    EndIf	 
	    PCOTMP->STATUS := "1"
    PCOTMP->(MsUnLock())
    
	UnLockByName("PCOA301_"+cChave+"_CB_"+cCubo+DTOS(dDataFim),.T.,.T.)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณP301DelTmp บAutor  ณMicrosiga           บ Data ณ  07/08/18   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga arquivo temporแrio de log                              บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P301DelTmp(cOrigem,cArquivo)
Local cSQLExec := ""
DEFAULT cOrigem := ""
DEFAULT cArquivo:= ""

cSQLExec := "DELETE FROM PCOTMP WHERE ORIGEM = '"+PADR(cOrigem,10)+"' AND ARQUIVO = '"+PADR(cArquivo,20)+"' "
If TcSqlExec(cSQLExec) <> 0 
	If !lAuto
		UserException(TCSqlError())
	Else
		Conout(TCSqlError())
	EndIf
EndIf	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณP301CntThd บAutor  ณMicrosiga           บ Data ณ  07/08/18   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCheca se todos os registros jแ foram processados             บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P301ChkThd(cOrigem,cArquivo)
Local nRet   := 0
Local cQuery := ""
DEFAULT cOrigem := ""
DEFAULT cArquivo:= ""

cQuery := " SELECT COUNT(1) COUNT FROM PCOTMP WHERE ORIGEM = '"+PADR(cOrigem,10)+"' AND ARQUIVO = '"+PADR(cArquivo,20)+"' AND STATUS = '1' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_PCOTMP",.T.,.F.)

If !QRY_PCOTMP->(Eof())
	nRet := QRY_PCOTMP->COUNT
EndIf
QRY_PCOTMP->(dbCloseArea())

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณP301CriaTmpบAutor  ณMicrosiga           บ Data ณ  07/08/18   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo temporแrio                                      บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P301CriTmp()
Local aEstrut := {}

aAdd(aEstrut ,{"CPOLOG" ,"C",250,00})		
aAdd(aEstrut ,{"ORIGEM" ,"C",010,00})//Se alterar o tamanho deste campo, deverแ alterar tamb้m o PADR nas Fun็๕es: P301ChkThd, P301MsgCom e P301DelTmp
aAdd(aEstrut ,{"ARQUIVO","C",020,00})//Se alterar o tamanho deste campo, deverแ alterar tamb้m o PADR nas Fun็๕es: P301ChkThd, P301MsgCom e P301DelTmp
aAdd(aEstrut ,{"STATUS" ,"C",001,00})		
DBCreate("PCOTMP", aEstrut,__CRDD)
	
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณP301MsgCom บAutor  ณMicrosiga           บ Data ณ  07/08/18   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta string para exibi็ใo do log na tela                    บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P301MsgCom(cOrigem,cArquivo)
Local cRet   := ""
Local cQuery := ""
DEFAULT cOrigem := ""
DEFAULT cArquivo:= ""

cQuery := " SELECT CPOLOG FROM PCOTMP WHERE ORIGEM = '"+PADR(cOrigem,10)+"' AND ARQUIVO = '"+PADR(cArquivo,20)+"' AND STATUS = '1' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_MSGTMP",.T.,.F.)

While !QRY_MSGTMP->(Eof())
	cRet += AllTrim(QRY_MSGTMP->CPOLOG)+CRLF
	QRY_MSGTMP->(dbSkip())
EndDo
QRY_MSGTMP->(dbCloseArea())
 
Return cRet