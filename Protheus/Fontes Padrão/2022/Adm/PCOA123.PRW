#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOA123.CH"
#Define GRID_STEP 10000

Static __lBlind		:= IsBlind()

Function PCOA123(cPlanilha, cVerAtu, cVerNew, lSimulac, lRevisac, lAtlSld, nRecAK1)
Local nX
Local lRet 		:= .F.
Local cAliasTmp
Local cQuery 	:= ""
Local aRecGrid 	:= {}
Local nThread:= SuperGetMv("MV_PCOTHRD",.T.,10)
Local oGrid, oGrid2

Default cPlanilha   := AK1->AK1_CODIGO
Default cVerAtu   	:= AK1->AK1_VERSAO
Default cVerNew 	:= M->AKE_REVISA   
Default lSimulac 	:= .F.
Default lRevisac    := .T.
Default lAtlSld     := .T.
Default nRecAK1     := AK1->( Recno() )

//variaveis private para multi-thread
Private cPlanRev    := cPlanilha
Private cVersPlan   := cVerAtu
Private cNewVers 	:= cVerNew   
Private lSimu_ 		:= lSimulac 
Private lRevi_      := lRevisac

/* processo atual

			//PLANILHA VERSAO ATUAL VIGENTE ATE FINALIZACAO DA REVISAO
			PcoIniLan("000252")
			dbSelectArea("AK2")
			dbSetOrder(1)
			dbSeek(xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO)
			While !Eof() .And. xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO==AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO
			    //observacao: DEVE ESTAR NESTA SEQUENCIA (NAO MUDAR)
				PcoDetLan("000252","04","PCOA100")  							//GRAVAR SALDO HISTORICO PREVISTO PARA VERSAO
				PcoDetLan("000252","01","PCOA100", .T., "00025202;00025204")  	//DELETAR VERSAO ATUAL DA PLANILHA
				dbSelectArea("AK2")
				dbSkip()
			End
			PcoFinLan("000252")
            //PLANILHA VERSAO REVISADA TORNANDO-SE EM ATUAL
			PcoIniLan("000252")
			dbSelectArea("AK2")
			dbSetOrder(1)
			dbSeek(xFilial()+AK1->AK1_CODIGO+M->AKE_REVISA)
			While !Eof() .And. xFilial()+AK1->AK1_CODIGO+M->AKE_REVISA==AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO
			
				If ExistBlock("PCOA1202")
					ExecBlock("PCOA1202",.F.,.F.)
				EndIf   
				
			    //observacao: DEVE ESTAR NESTA SEQUENCIA (NAO MUDAR)
				PcoDetLan("000252","01","PCOA100")           					//GRAVANDO COMO ATUALIZACAO DA PLANILHA
				PcoDetLan("000252","02","PCOA100",.T., "00025201;00025204")    //DELETAR REVISAO PRESERVANDO ITEM ANTERIOR + HISTORICO
				dbSelectArea("AK2")
				dbSkip()
			End
			PcoFinLan("000252")

*/

If !MSFile("PCOTMP", ,__CRDD )
	P301CriTmp()					
EndIf	

If Select("PCOTMP")==0
	dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
EndIf	

//------------------PLANILHA VERSAO ATUAL VIGENTE ATE FINALIZACAO DA REVISAO------------------------//

cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT MIN(R_E_C_N_O_) MINRECNOAK, MAX(R_E_C_N_O_) MAXRECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cVersPlan +"' "
cQuery += "        AND D_E_L_E_T_= ' ' " 

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "MINRECNOAK", "N", 12, 0 )
TcSetField( cAliasTmp, "MAXRECNOAK", "N", 12, 0 )

If (cAliasTmp)->(!Eof())

	//DISTRIBUIR EM GRID
	aRecGrid := {}
	For nX := (cAliasTmp)->MINRECNOAK TO (cAliasTmp)->MAXRECNOAK STEP GRID_STEP
		If nX + GRID_STEP > (cAliasTmp)->MAXRECNOAK
			aAdd(aRecGrid, {nx, (cAliasTmp)->MAXRECNOAK } )  //ultimo elemento do array
		Else
			aAdd(aRecGrid, {nx, nX+GRID_STEP-1} )
		EndIf
	Next

	nThread := Min( Len(aRecGrid), nThread ) //Configura a quantidade de threads pelo menor parametro ou len(arecgrid)
	oGrid := FWIPCWait():New("_AK1"+cEmpAnt+StrZero(nRecAK1,9,0),10000)
	oGrid:SetThreads(nThread)
	oGrid:SetEnvironment(cEmpAnt,cFilAnt)
	oGrid:Start("PCORVFIN1")

	ConoutR(time()+STR0001) //" Atualizando saldo item 01 da planilha atual - TIRANDO..."
	//EXCLUIR SALDOS ITEM 01 DO PROC 000252 - PLANILHA - NORMALMENTE SALDO TIPO OR-CADO VIA PROCEDURE 
	P122lAtuCb( lAtlSld )
	P122AtuCubo(cPlanRev, cVersPlan, "01"/*cItemProc*/,"-"/*cSinal*/)

	ConoutR(time()+STR0002)//" EXCLUINDO VIA PROCEDURE item 01 da planilha atual ..."
	//EXCLUIR MOVIMENTOS ORCAMENTARIOS AKD RELATIVO A VERSAO ATUAL DA PLANILHA - item 01 da planilha
	P122CDELL(cPlanRev, cVersPlan, "01")

	lRet := A123RevPr1(oGrid,aRecGrid,nThread)
	
	If lRet
		ConoutR(time()+STR0003) //" Atualizando saldo item 04 da planilha atual -> historico - SOMANDO..."
		//ATUALIZAR SALDO HS-HISTORICO - Item 04 da revisao da planilha - gerado pela funcao PCORVFIN1
		P122AtuCubo(cPlanRev, cVersPlan, "04"/*cItemProc*/,"+"/*cSinal*/)
	EndIf
	
Else
	
	lRet := .F.

EndIf

(cAliasTmp)->( dbCloseArea())

//------------------PLANILHA VERSAO REVISADA (NOVA) ------------------------//
If lRet
	
	ConoutR(time()+STR0004) //" Atualizando saldo item 02 da planilha NOVA RV-REVISAO - TIRANDO..."
	//ATUALIZAR SALDO RV-REVISAO DA VERSAO NOVA DA PLANILHA - item 02 Iniciar Revisao da Planilha
	P122AtuCubo(cPlanRev, cNewVers, "02"/*cItemProc*/,"-"/*cSinal*/)

	ConoutR(time()+STR0005) //" EXCLUINDO VIA PROCEDURE item 02 da planilha NOVA RV-REVISAO ..."
	//EXCLUIR MOVIMENTOS ORCAMENTARIOS AKD RELATIVO A VERSAO NOVA DA PLANILHA - item 02 Iniciar Revisao da Planilha
	P122CDELL(cPlanRev, cNewVers, "02")

	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT MIN(R_E_C_N_O_) MINRECNOAK, MAX(R_E_C_N_O_) MAXRECNOAK FROM " + RetSqlName( "AK2" )
	cQuery += " WHERE "
	cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
	cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
	cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
	cQuery += "        AND D_E_L_E_T_= ' ' " 
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )
	
	TcSetField( cAliasTmp, "MINRECNOAK", "N", 12, 0 )
	TcSetField( cAliasTmp, "MAXRECNOAK", "N", 12, 0 )
	
	If (cAliasTmp)->(!Eof())
	
		//DISTRIBUIR EM GRID
		aRecGrid := {}
		For nX := (cAliasTmp)->MINRECNOAK TO (cAliasTmp)->MAXRECNOAK STEP GRID_STEP
			If nX + GRID_STEP > (cAliasTmp)->MAXRECNOAK
				aAdd(aRecGrid, {nx, (cAliasTmp)->MAXRECNOAK } )  //ultimo elemento do array
			Else
				aAdd(aRecGrid, {nx, nX+GRID_STEP-1} )
			EndIf
		Next
		oGrid2 := FWIPCWait():New("AK1_"+cEmpAnt+StrZero(nRecAK1,9,0),10000)
		oGrid2:SetThreads(nThread)
		oGrid2:SetEnvironment(cEmpAnt,cFilAnt)

		//Altera o programa que sera executado pelo metodo oGrid:Go()
		oGrid2:Start("PCORVFIN2")
	
		lRet := A123RevPr2(oGrid2,aRecGrid,nThread)
		
		If lRet
			ConoutR(time()+ STR0006)  //" Atualizando saldo item 01 da planilha NOVA transformado em ATUAL - SOMANDO..."
			//ATUALIZAR SALDO OR-ORCADO REF A VERSAO NOVA DA PLANILHA - item 01 - (TRANSFORMADA EM PLANILHA ATUAL)
			P122AtuCubo(cPlanRev, cNewVers, "01"/*cItemProc*/,"+"/*cSinal*/)
		EndIf
	
	EndIf
	
	(cAliasTmp)->( dbCloseArea())
EndIf

ConoutR("[END]->PCOA123: "+TIME(), .T., "PCOA123")
	
Return(lRet)
            		
//--------------------processo da planilha atual----------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A123RevPr1 ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara a execução da rotina em MultiThreads                º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A123RevPr1(oGrid,aRecGrid,nThread)
Local nRecIni
Local nRecFim

Local cFilAKE 	:= xFilial("AKE")
Local lExit 	:= .F.
Local nKilled
Local nHdl
Local cMsgComp	:= ""
Local nX
Local nZ
Local cArquivo := ""

cArquivo := CriaTrab(,.F.)

For nX := 1 To Len(aRecGrid)
	nRecIni := aRecGrid[nX,1]
	nRecFim := aRecGrid[nX,2]
	lRet := oGrid:Go(STR0007,{nRecIni, nRecFim, lSimu_, lRevi_, cPlanRev, cVersPlan, nX},cArquivo) //"Chamando escrituracao..."
	If !lRet
		Exit
	EndIf
	Sleep(5000)//Aguarda 5 seg para abertura da thread para não concorrer na criação das procedures.
Next

Sleep(2500*nThread)//Aguarda todas as threads abrirem para tentar fechar
    
While !lExit
	nKilled := P301ChkThd("PCOA123_1",cArquivo)

	If nKilled == Len(aRecGrid)
		Exit
	EndIf	
	Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram	
EndDo

cMsgComp := P301MsgCom("PCOA123_1",cArquivo)
P301DelTmp("PCOA123_1",cArquivo)

PcoAvisoTm(IIf(lRet,STR0008,STR0012),cMsgComp, {"Ok"},,,,,5000) //"Processo finalizado com sucesso.","Problema no processamento."

// Fechamento das Threads
oGrid:Stop()        //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

oGrid:RemoveThread(.T.)

FreeObj(oGrid)
oGrid := nil


Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCORVFIN1  ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina executado em MultiThread para chamara a funcao que  º±±
±±º          ³  ira executar PcoDetLan                                     º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCORVFIN1(cParm,aParam,cArquivo)
Local nRecIni 	:= aParam[1]
Local nRecFim 	:= aParam[2]
Local lSimulac 	:= aParam[3]
Local lRevisa 	:= aParam[4]
Local cPlanRev  := aParam[5]
Local cVersPlan := aParam[6]
Local nZ		:= aParam[7]
Local cFilAKE 	:= xFilial("AKE")
Local cStart	:= ""
Local cEnd      := ""
Local nRecPCO   := 0
DEFAULT cArquivo:= ""

If Select("PCOTMP")==0
	dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
EndIf

If LockByName("PCOA120FRV_"+cFilAKE+cPlanRev+cVersPlan+StrZero(nZ,10,0),.T.,.T.)
	cStart := DTOC(Date())+" "+Time()
	ConoutR( "PCOA120FRV -> "+AllTrim(Str(ThreadID()))+" STARTED ["+cStart+"] " ) 
	
	PCOTMP->(RecLock("PCOTMP",.T.))
    	PCOTMP->CPOLOG := " STARTED ["+cStart+"]"
    	PCOTMP->ORIGEM := "PCOA123_1"
    	PCOTMP->ARQUIVO:= cArquivo  
    	PCOTMP->STATUS := "0"	   
    PCOTMP->(MsUnLock())
    nRecPCO := PCOTMP->(Recno())
    
    //PROCESSAMENTO
	lRet := _Det_Lan1(nRecIni, nRecFim, lSimulac, lRevisa, cPlanRev, cVersPlan)
	
	cEnd := DTOC(Date())+" "+Time()
		
	PCOTMP->(dbGoTo(nRecPCO))
	PCOTMP->(RecLock("PCOTMP",.F.))
    	If lRet		
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+" - END ["+cEnd+"] - OK"
			ConoutR("PCOA120FRV -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  OK")
		Else
	    	PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+" - END ["+cEnd+"] - FAILED"
	    	ConoutR("PCOA120FRV -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  FAILED")
	    EndIf	 
	    PCOTMP->STATUS := "1"
    PCOTMP->(MsUnLock())
	
    UnLockByName("PCOA120FRV_"+cFilAKE+cPlanRev+cVersPlan+StrZero(nZ,10,0),.T.,.T.)
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_Det_Lan1   ºAutor  ³Microsiga         º Data ³  06/14/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a PcoDetLan para escriturar movimento gerado por      º±±
±±º          ³Finalizar Revisao - versao atual (distribuido)              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _Det_Lan1(nRecIni, nRecFim, lSimulac, lRevisao, cPlanRev, cVersPlan)
Local lRet := .F.
Local cQuery := " "
Local nCtdAK2 := 0
Local cAliasTmp

//select ak2 da versao atual onde vai deletar os movimentos e acertar saldo
cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK3 da nova versao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cVersPlan +"' "
cQuery += "        AND R_E_C_N_O_ BETWEEN  "+ Str(nRecIni,12,0) + " AND "+ Str(nRecFim,12,0)
cQuery += "        AND D_E_L_E_T_ = ' ' " 
cQuery += " ORDER BY R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
ConoutR(STR0009+Str(nRecIni,12,0)+STR0010+Str(nRecFim,12,0)+time()) //"inicio Recnos de:"," Ate: "
PcoIniLan("000252")

While (cAliasTmp)->(!Eof())
	nRecNew := (cAliasTmp)->(RECNOAK)
	AK2->(dbGoto(nRecNew))
	nCtdAK2++	
    //observacao: DEVE ESTAR NESTA SEQUENCIA (NAO MUDAR)
	PcoDetLan("000252","04","PCOA100",/*lDeleta*/, /*cProcDel*/, "1", .F. /*lAtuSld*/ )	//GRAVAR SALDO HISTORICO PREVISTO PARA VERSAO
//	PcoDetLan("000252","01","PCOA100", .T., "00025202;00025204")  		//DELETAR VERSAO ATUAL DA PLANILHA
	(cAliasTmp)->(dbSkip())
EndDo

PcoFinLan("000252",/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F./*lAtuSld*/)

(cAliasTmp)->(dbCloseArea() )

ConoutR(STR0011+Str(nRecIni,12,0)+STR0010+Str(nRecFim,12,0)+time()) //"Final Recnos de: "," Ate: "

lRet := ( (nRecFim-nRecIni+1) == nCtdAK2 )

Return(lRet)


//--------------------processo da planilha revisada----------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A123RevPr2 ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara a execução da rotina em MultiThreads                º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A123RevPr2(oGrid,aRecGrid,nThread)
Local nRecIni
Local nRecFim

Local cFilAKE 	:= xFilial("AKE")
Local lExit 	:= .F.
Local nKilled
Local nHdl
Local cMsgComp	:= ""
Local nX
Local nZ

cArquivo := CriaTrab(,.F.)

For nX := 1 To Len(aRecGrid)
	nRecIni := aRecGrid[nX,1]
	nRecFim := aRecGrid[nX,2]
	lRet := oGrid:Go(STR0007,{nRecIni, nRecFim, lSimu_, lRevi_, cPlanRev, cNewVers, nX},cArquivo)//"Chamando escrituracao..."
	If !lRet
		Exit
	EndIf

	Sleep(5000)//Aguarda 5 seg para abertura da thread para não concorrer na criação das procedures.

Next

Sleep(2500*nThread)//Aguarda todas as threads abrirem para tentar fechar
    
While !lExit
	nKilled := P301ChkThd("PCOA123_2",cArquivo)
	
	If nKilled == Len(aRecGrid)
		Exit
	EndIf
	IncProc()	
	Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram	
EndDo

cMsgComp := P301MsgCom("PCOA123_2",cArquivo)
P301DelTmp("PCOA123_2",cArquivo)

PcoAvisoTm(IIf(lRet,STR0008,STR0012),cMsgComp, {"Ok"},,,,,5000)//"Processo finalizado com sucesso.","Problema no processamento."

// Fechamento das Threads
oGrid:Stop()        //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

oGrid:RemoveThread(.T.)

FreeObj(oGrid)
oGrid := nil

Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCORVFIN2  ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina executado em MultiThread para chamara a funcao que  º±±
±±º          ³  ira executar PcoDetLan                                     º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCORVFIN2(cParm,aParam,cArquivo)
Local nRecIni 	:= aParam[1]
Local nRecFim 	:= aParam[2]
Local lSimulac 	:= aParam[3]
Local lRevisa 	:= aParam[4]
Local cPlanRev  := aParam[5]
Local cNewVers  := aParam[6]
Local nZ		:= aParam[7]
Local cFilAKE 	:= xFilial("AKE")
Local cStart	:= ""
Local cEnd      := ""
Local nRecPCO   := 0
DEFAULT cArquivo:= ""

If Select("PCOTMP")==0
	dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
EndIf 

If LockByName("PCOA120FRV_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0),.T.,.T.)

	cStart := DTOC(Date())+" "+Time()
	ConoutR( "PCOA120FRV -> "+AllTrim(Str(ThreadID()))+" STARTED ["+cStart+"] " ) 
	
	PCOTMP->(RecLock("PCOTMP",.T.))
    	PCOTMP->CPOLOG := "STARTED ["+cStart+"]"
    	PCOTMP->ORIGEM := "PCOA123_2"
    	PCOTMP->ARQUIVO:= cArquivo  
    	PCOTMP->STATUS := "0"	   
    PCOTMP->(MsUnLock())
    nRecPCO := PCOTMP->(Recno())
	
    //PROCESSAMENTO
	lRet := _Det_Lan2(nRecIni, nRecFim, lSimulac, lRevisa, cPlanRev, cNewVers)
	
	cEnd := DTOC(Date())+" "+Time()	
	
	PCOTMP->(dbGoTo(nRecPCO))
	PCOTMP->(RecLock("PCOTMP",.F.))
    	If lRet		
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+" - END ["+cEnd+"] - OK"
			ConoutR("PCOA120FRV -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  OK")
		Else
	    	PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+" - END ["+cEnd+"] - FAILED"
	    	ConoutR("PCOA120FRV -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  FAILED")
	    EndIf	 
	    PCOTMP->STATUS := "1"
    PCOTMP->(MsUnLock())
    
	UnLockByName("PCOA120FRV_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0),.T.,.T.)
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_Det_Lan2   ºAutor  ³Microsiga         º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a PcoDetLan para escriturar movimento gerado por      º±±
±±º          ³Finalizar Revisao-nova versao (distribuido)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _Det_Lan2(nRecIni, nRecFim, lSimulac, lRevisao, cPlanRev, cNewVers)
Local lRet := .F.
Local cQuery := " "
Local nCtdAK2 := 0
Local cAliasTmp

//select ak2 da versao nova
cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	         AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
cQuery += "        AND R_E_C_N_O_ BETWEEN  "+ Str(nRecIni,12,0) + " AND "+ Str(nRecFim,12,0)
cQuery += "        AND D_E_L_E_T_ = ' ' " 
cQuery += " ORDER BY R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
ConoutR(STR0009+Str(nRecIni,12,0)+STR0010+Str(nRecFim,12,0)+time())//"inicio Recnos de:"," Ate: "
PcoIniLan("000252")

While (cAliasTmp)->(!Eof())
	nRecNew := (cAliasTmp)->(RECNOAK)
	AK2->(dbGoto(nRecNew))
	nCtdAK2++	

	If ExistBlock("PCOA1202")
		ExecBlock("PCOA1202",.F.,.F.)
	EndIf   
	
    //observacao: DEVE ESTAR NESTA SEQUENCIA (NAO MUDAR)
	PcoDetLan("000252","01","PCOA100",/*lDeleta*/, /*cProcDel*/, "1", .F. /*lAtuSld*/)    	//GRAVANDO COMO ATUALIZACAO DA PLANILHA
//	PcoDetLan("000252","02","PCOA100",.T., "00025201;00025204")    			//DELETAR REVISAO PRESERVANDO ITEM ANTERIOR + HISTORICO
	(cAliasTmp)->(dbSkip())
EndDo

PcoFinLan("000252",/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F./*lAtuSld*/)

(cAliasTmp)->(dbCloseArea() )

ConoutR(STR0011+Str(nRecIni,12,0)+STR0010+Str(nRecFim,12,0)+time())//"Final Recnos de: "," Ate: "

lRet := ( (nRecFim-nRecIni+1) == nCtdAK2 )

Return(lRet)
