#include "topconn.ch"
#include "protheus.ch"
#include "HSM54002.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54Fin  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSM54Fin()
Local cAlias   := Alias()
Local lRet     := .T.
Local nMaxTit  := IIf(FunName() == "HSPAHM54", SuperGetMV("MV_MAXAGE",, 0), SuperGetMV("MV_MAXATE",, 0))
Local nMaxDia  := SuperGetMV("MV_MAXDIA",, 0)
Local aVldPFin := {}
Local cReadVar := IIF(Type("__ReadVar") <> "U".And. !Empty(__ReadVar), __ReadVar, "") //Guarda o conteudo do ReadVar porque o SetFocus limpa essa variavel
Local oDlgTree := Nil
Local nAction  := 0
Local aTreePln := {} 
Local aButtons := {}
Local lPendFin := .F.
Local lHspm24aa:= .F.
local lCritDRF         := Hs_ExisDic({{"C","GTL_CODDEN"}},.F.) .and. Hs_ExisDic({{"C","GTL_DESDEN"}},.F.) .and. ;
							Hs_ExisDic({{"C","GTL_CODFAC"}},.F.) .and. Hs_ExisDic({{"C","GTL_DESFAC"}},.F.)

Private cGa7Urgenc 	:= ""
Private cProcUrg	  := ""


If IIf(FunName() == "HSPAHM54", ReadVar() $ "M->GM8_REGGER/M->GM8_NOMPAC", .T.)
	HS_STATORC(, GBH->GBH_CODCLI, .F.)  // Atualiza status do or็amento/ tratamento do paciente
	If Type("cProcDoPln") # "U"
		cProcDoPln := ""
	EndIf
	
	If FunName() == "HSPM24AA" .And. GA9->GA9_CODCON <> GM8->GM8_CODCON
		//HS_SeekRet("GA9", "GM8->GM8_CODCON", 1, .F.) 
		If !IsInCallStack("HS_AgeM24") 
		    HS_SeekRet("GA9", iIf(empty(GM8->GM8_CODCON),"GD4->GD4_CODCON","GM8->GM8_CODCON"), 1, .F.) 		
		Else
		    HS_SeekRet("GA9", "GD4->GD4_CODCON", 1, .F.) 		
		EndIf    
	EndIf
	
	// M->GM8_DESPLA preenchida identifica que as valida็๕es anteriores ocorreram com sucesso, pois caso tenha ocorrido
	// falha na consist๊ncia dos dados estaria vazia.
	// GA9->TIPCON = 1 identifica plano particular e somente nesse caso sera validado os pagamentos do paciente.
	If IIf(FunName() == "HSPAHM54", !Empty(M->GM8_DESPLA), .T.) .And. GA9->GA9_TIPCON == "1" // 1-Particular
		//If IIf(FunName() == "HSPAHM54", M->GM8_REGGER, GM8->GM8_REGGER) <> GBH->GBH_CODPAC
		If IIf(FunName() == "HSPAHM54", M->GM8_REGGER, IIf(FunName() == "HSPM24AA", iIf(type("M->GM8_REGGER") # "U", M->GM8_REGGER, GCY->GCY_REGGER), GM8->GM8_REGGER)) <> GBH->GBH_CODPAC
				HS_SeekRet("GBH", 'IIf(FunName() == "HSPAHM54", M->GM8_REGGER, IIf(FunName() == "HSPM24AA", M->GCY_REGGER, GM8->GM8_REGGER))', 1, .F.)
		EndIf
		
		// Verifica se existem titulos em aberto para o paciente selecionado
		If ((aVldPFin := HS_VLDPFIN(GBH->GBH_CODCLI, GBH->GBH_LOJA))[1] > nMaxTit)
			lPendFin := .T.
			//Verifica a quantidade de dias apos o vencimento da ultima fatura
			if FunName() == "HSPM24AA"
				lHspm24aa := .T.
				//Se a quantidade de titulos vencidos eh igual a quantidade maxima permitida + 1
				if aVldPFin[1] == nMaxTit + 1
					//se a data de vencimento do ultimo titulo vencido nao for maior que a tolerancia de dias permitidos
					if !(dDataBase > SToD(aVldPFin[2]) + nMaxDia)
						lPendFin := .F.
					endif
				endif
			endif
			//Se ha pendencia financeira e se para atendimento a pendencia ainda permite atendimento
			if lPendFin
				lRet := HSMsgVFin(aVldPFin)
				//Se foi chamado pela tela de atendimento e esta inadimplente, nao permite atendimento
				if lHspm24aa
					If !Empty(cReadVar)
						__ReadVar := cReadVar
					EndIf                    
					DbSelectArea(cAlias)
					return lRet					
				endif
			endif    

			lRet := HSVldSup(lRet,lHspm24aa)
			
		EndIf
		
	EndIf
	
	If lRet .And. IIf(FunName() == "HSPAHM54" .Or. IsInCallStack("HS_AgeM24"), FSPlaTrat(GBH->GBH_CODCLI, GBH->GBH_CODPAC), .F.)
	 	If HS_EXISDIC({{"C", "GA7_URGENC"}},.F.)	 	
			cGa7Urgenc := "1" //Lista somente procedimento de urgencia
		EndIf
		DEFINE MSDIALOG oDlgTree TITLE OemToAnsi(STR0008) From 0, 0 To 400, 500	PIXEL Of oMainWnd //"Ficha de Tratamento"
		
		aTreePln := HS_PlnTree(GBH->GBH_CODCLI, oDlgTree, {oDlgTree:nTop, oDlgTree:nLeft, (oDlgTree:nBottom / 2) - 15, (oDlgTree:nRight / 2) - 07}, "GT9.GT9_STATUS IN ('3', '5')",,GBH->GBH_CODPAC)
		aTreePln[1]:BLDblClick := {|| IIf(M54SelProc(aTreePln[1]:GetCargo(), aTreePln[1]:CurrentNodeId, aTreePln[2]), (nAction := 1, oDlgTree:End()), (nAction := 0, .F.))}		
		aAdd(aButtons,  {"S4WB001N", {|| IIf(!Empty(cProcUrg := FS_URGENCIA()), (M54SelProc("PROC", 0, {}, cProcUrg), (nAction := 1,oDlgTree:End())),Nil)}, STR0009,STR0009}) // "Urgencia" ### "Urgencia"
		
//		ACTIVATE MSDIALOG oDlgTree ON INIT EnchoiceBar(oDlgTree,	{|| IIf(M54SelProc(aTreePln[1]:GetCargo(), aTreePln[1]:CurrentNodeId, aTreePln[2]), (nAction := 1, oDlgTree:End()), (nAction := 0, .F.)), oDlgTree:End()},;
		ACTIVATE MSDIALOG oDlgTree ON INIT EnchoiceBar(oDlgTree,	{|| IIf(M54SelProc(aTreePln[1]:GetCargo(), aTreePln[1]:CurrentNodeId, aTreePln[2]), (nAction := 1, oDlgTree:End()), (nAction := 0, .F.)), /*oDlgTree:End()*/},;
																	{|| nAction := 0, oDlgTree:End()},,aButtons)
//																	{|| nAction := 0, oDlgTree:End()},,aButtons)
		cGa7Urgenc := ""
		lRet := nAction == 1
		If lRet
			If Type("cProcDoPln") # "U"
				cProcDoPln := M->GM8_CODPRO //Variavel do M54 para identificar que o procedimento deve vir do plano de tratamento
				M->GM8_NUMORC
				if lCritDRF
					cNumOrc       := M->GM8_NUMORC
					cIteOrc       := M->GM8_ITEORC
					cCodDenPln    := Posicione("GTJ", 1, xFilial("GTK") + M->GM8_NUMORC + M->GM8_ITEORC, "GTJ_DENREG")
					cCodFacPln    := Posicione("GTJ", 1, xFilial("GTK") + M->GM8_NUMORC + M->GM8_ITEORC, "GTJ_FADENT")
				endif
			EndIf  
		Else       
			If Type("cProcDoPln") # "U"
				cProcDoPln := ""
			EndIf
		EndIf
	Else
		If Type("lProcDoPln") # "U"
			cProcDoPln := ""
		EndIf
	EndIf
	
EndIf

If !Empty(cReadVar)
	__ReadVar := cReadVar
EndIf

DbSelectArea(cAlias)
Return(lRet)
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM54CanAg  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M54CanAg(aParam)
Local cAliasO := ""
Local nMaxTit := 0
Local nMaxDia := 0
Local nNumAnt := 0
Local cMCAuto := ""
Local cRegGer := "@@@@@@"
Local lCanAgd := .F.
Local cSql    := "" 
 
Private cCodEmpM54 := aParam[1]
Private cCodFilM54 := aParam[2]
 
RPCSetType(3) //nใo consome licen็a. 
PREPARE ENVIRONMENT EMPRESA cCodEmpM54 FILIAL cCodFilM54 TABLES "GM8","GM9","SE1","GBH","SA1", cAliasO
	cAliasO := Alias()
	nMaxTit := SuperGetMV("MV_MAXATE",, 0)
	nMaxDia := SuperGetMV("MV_MAXDIA",, 0)
	nNumAnt := SuperGetMV("MV_NUMANT",, 0)
	cMCAuto := SuperGetMV("MV_MCAUTO",, "")
 
	If Empty(cMCAuto) .Or. !HS_SeekRet("GM7", "'" + cMCAuto + "'", 1, .F.)
		Return(Nil)
	EndIf

	// Seleciona todas as agendas com status 1-agendado e 5-agendado confirmado
	// do dia em que o sistema esta logado + a quantidade de dias de antecedencia 
	// configurado no parametro MV_NUMANT
	cSql := ChangeQuery("SELECT GM8.GM8_CODAGE, GM8.GM8_DATAGE, GM8.GM8_REGGER " + ;
                     "FROM " + RetSqlName("GM8") + " GM8 " + ;
                     "WHERE GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_STATUS IN ('1', '5') AND " + ;
                           "GM8.GM8_REGGER <> '" + Space(Len(GM8->GM8_REGGER)) + "' AND " + ;
                           "GM8.GM8_DATAGE = '" + DToS(dDataBase + nNumAnt) + "' " + ;
                     "ORDER BY GM8.GM8_FILIAL, GM8.GM8_REGGER")
 
	TCQuery cSql New Alias "GM8SCH"
 
	While !Eof()
 		If cRegGer <> GM8SCH->GM8_REGGER .And. HS_SeekRet("GBH", 'GM8SCH->GM8_REGGER', 1, .F.)
    		cRegGer := GM8SCH->GM8_REGGER
   
			lCanAgd := ((aVldPFin := HS_VLDPFIN(GBH->GBH_CODCLI, GBH->GBH_LOJA))[1] > nMaxTit) .And. SToD(GM8SCH->GM8_DATAGE) > (SToD(aVldPFin[2]) + nMaxDia)
   
		EndIf
  
		If lCanAgd
  
			M54CAgd(GM8SCH->GM8_CODAGE, cMCAuto)
   
		EndIf
  
		DbSelectArea("GM8SCH")
		DbSkip()
	End
 
	GM8SCH->(DbCloseArea())
 
	DbSelectArea(cAliasO)

RESET ENVIRONMENT
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM54CAgd   บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function M54CAgd(cGm8CodAge, cGm8Motivo, cSeq)
 Local cAliasOld  := Alias()
 Local lBloqueia  := .F.
 Local cGm8OriCan := ""
 Local nCont      := 0
 Local aCpoEnc    := {}
 Local aCpoUsu    := HS_CposUsu(@aCpoEnc, "GM8")
 Default cSeq     := ""

	DbSelectArea("GM8")
	DbSetOrder(1)
	DbSeek(xFilial("GM8") + cGm8CodAge)
		
	DbSelectArea("GM7")
	DbSetOrder(1) // GM7_FILIAL + GM7_CODCAN
	DbSeek(xFilial("GM7") + cGm8Motivo)
	
	lBloqueia  := GM7->GM7_IDEBLO == "1" //1-Sim
	cGm8OriCan := GM7->GM7_ORICAN
		
	FS_DelGo4(GM8->GM8_CODAGE)
	FS_DelGeb(GM8->GM8_CODAGE)
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Disponibiliza ou Bloqueia o Horario Cancelado e grava o His- ณ
	//ณ torico do Cancelamento.                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Cancelamento
	If GM9->(FieldPos("GM9_SEQREG")) > 0 //Checar se existe campo para release 4  (cancelar)
		M->GM9_SEQREG   := HS_VSxeNum("GM9", "M->GM9_SEQREG", 4)
		ConfirmSX8()
	EndIf
			
	RecLock("GM9",.T.)
		GM9->GM9_FILIAL := xFilial("GM9")
		GM9->GM9_FILAGE := GM8->GM8_FILAGE
		GM9->GM9_CODPLA := GM8->GM8_CODPLA
		GM9->GM9_SQCATP := GM8->GM8_SQCATP
		GM9->GM9_CODCRM := GM8->GM8_CODCRM
		GM9->GM9_CODLOC := GM8->GM8_CODLOC
		GM9->GM9_CODDIS := GM8->GM8_CODDIS
		GM9->GM9_REGGER := GM8->GM8_REGGER
		GM9->GM9_MATRIC := GM8->GM8_MATRIC
		GM9->GM9_CODAGE := GM8->GM8_CODAGE
		GM9->GM9_NOMPAC := GM8->GM8_NOMPAC
		GM9->GM9_TELPAC := GM8->GM8_TELPAC
		GM9->GM9_CODPRO := GM8->GM8_CODPRO
		GM9->GM9_DATAGE := GM8->GM8_DATAGE
		GM9->GM9_HORAGE := GM8->GM8_HORAGE
		GM9->GM9_DATCAD := GM8->GM8_DATCAD
		GM9->GM9_HORCAD := GM8->GM8_HORCAD
		GM9->GM9_USUCAD := GM8->GM8_CODUSU
		GM9->GM9_CODCAN := cGm8Motivo
		GM9->GM9_DATCAN := dDataBase
		GM9->GM9_HORCAN := SubStr(Time(),1,5)
		GM9->GM9_USUCAN := SubStr(cUsuario,7,15)
		GM9->GM9_DESCFM := GM8->GM8_DESCFM
		GM9->GM9_DATCFM := GM8->GM8_DATCFM
		GM9->GM9_HORCFM := GM8->GM8_HORCFM
		GM9->GM9_USUCFM := GM8->GM8_USUCFM
		GM9->GM9_LOCAGE := GM8->GM8_LOCAGE
		GM9->GM9_CODSAL := GM8->GM8_CODSAL
			
		If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
			GM9->GM9_SEQREG := M->GM9_SEQREG
		EndIf
	MsUnLock()
			
	If GM9->(FieldPos("GM9_SEQREG")) > 0
		//ConOut("Aten็ใo -- Hist๓rico do Cancelamento -- Registro Sequencial Nr: " + GM9->GM9_SEQREG)
		cSeq := STR0021+ GM9->GM9_SEQREG //" Hist๓rico do Cancelamento -- Registro Sequencial Nr: "
	Endif
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Disponibiliza o Horario ou Encaixe para novas marcacoes ou   ณ
	//ณ bloqueia os mesmos.                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("GM8",.F.)
		If lBloqueia
			GM8->GM8_STATUS := "2"        //Bloqueado
			GM8->GM8_ORICAN := cGm8OriCan //Grava o Tipo de Cancelamento somente no Bloqueio
			GM8->GM8_SQCATP := " "
			
		Else
			If GM8->GM8_TIPAGE == "1" //Encaixe
				GM8->GM8_HORAGE := "  :  "
			EndIf
			
			GM8->GM8_STATUS := IIf(GM8->GM8_STATUS == "4", "2", "0")
			GM8->GM8_DATCAD := Ctod("")
			GM8->GM8_HORCAD := " "
			GM8->GM8_DESCFM := " "
			GM8->GM8_DATCFM := Ctod("")
			GM8->GM8_HORCFM := " "
			GM8->GM8_USUCFM := " "
		EndIf                 
		
		GM8->GM8_REGGER := " "
		GM8->GM8_MATRIC := " "
		GM8->GM8_NOMPAC := " "
		GM8->GM8_TELPAC := " "
		GM8->GM8_CODPLA := " "
		GM8->GM8_CODCON := " "
		GM8->GM8_CODPRO := " "
		GM8->GM8_OBSERV := " "
		GM8->GM8_CODUSU := " "
		GM8->GM8_LOCAGE := " "
		GM8->GM8_ORICAN := " "
			
		For nCont:= 1 To Len(aCpoUsu)
			If ValType("M->" + aCpoUsu[nCont]) != "U"
				If ValType(&("M->" + aCpoUsu[nCont]))=="C"
					GM8->&(aCpoUsu[nCont]) := " "
				ElseIf ValType(&("M->" + aCpoUsu[nCont]))=="N"
					GM8->&(aCpoUsu[nCont]) := 0
				ElseIf ValType(&("M->" + aCpoUsu[nCont]))=="D"
					GM8->&(aCpoUsu[nCont]) := CTOD("  /  /  ")
				ElseIf ValType(&("M->" + aCpoUsu[nCont]))== "L"
					GM8->&(aCpoUsu[nCont]) := .F.
				EndIf
			EndIf
		Next
		
		GM8->GM8_LOGARQ := HS_LogArq()
	MsUnLock()
	
	DbSelectArea(cAliasOld)
Return(NIL)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_DelGo4 บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_DelGo4(cCodAge)
 Local aArea  	:= GetArea()
 Local lAchou	:= .F.
 
 DbSelectArea("GO4")
	DbSetOrder(1)
	While (lAchou := DbSeek(xFilial("GO4") + cCodAge))
		RecLock("GO4", !lAchou)
	 	DbDelete()
		MsUnLock()
	End 
	
	RestArea(aArea)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54002  บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fs_DelGeb(cCodAge, nOpc)
 Local aArea   := GetArea()
 Local lAchou	:= .F.

 DbSelectArea("GEB")
 DbSetOrder(1)
 While (lAchou:= DbSeek(xFilial("GEB") + cCodAge))
	 RecLock("GEB", !lAchou)
	 	DbDelete()
	 MsUnLock()
	End

 RestArea(aArea)
Return(Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSVldUser บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSVldUser(cMsgErro, cTitulo, cRotina, aGetsMtv, cAliasMtv, nRecMtv)
 Local lRet := .F., oDlgPsw, oTexto, oBtnOk, oBtnCa, oEncMtv
 Local oUsrVld, cUsrVld := Space(25)
 Local oPswVld, cPswVld := Space(25)
 Local cReadVar := IIF(Type("__ReadVar") <> "U".And. !Empty(__ReadVar), __ReadVar, "") //Guarda o conteudo do ReadVar porque o SetFocus limpa essa variavel
 
 Private aGets := {}
 Private aTela := {}
 
 aAdd(aGetsMtv, "NOUSER")

 DEFINE MSDIALOG oDlgPsw FROM	62,100 TO 420,510 TITLE OemToAnsi(cTitulo) PIXEL
  
  @ 003, 004 TO 027, 200 LABEL "Help" OF oDlgPsw PIXEL
  @ 010, 008 MSGET OemToAnsi(cRotina) WHEN .F. SIZE 188, 010 OF oDlgPsw PIXEL
  
  @ 030, 004 TO 070, 200 OF oDlgPsw PIXEL
  @ 036, 008 GET oTexto VAR OemToAnsi(cMsgErro) MEMO READONLY /*NO VSCROLL*/ SIZE 188, 030 OF oDlgPsw PIXEL
                                         
  @ 073, 004 TO 105, 200 OF oDlgPsw PIXEL
  @ 078, 010 SAY OemToAnsi(STR0010) OF oDlgPsw PIXEL COLOR CLR_BLUE // "Usuario:"
  @ 076, 035 MSGET oUsrVld VAR cUsrVld SIZE 060, 4 OF oDlgPsw PIXEL COLOR CLR_BLACK
  
  @ 093, 010 SAY OemToAnsi(STR0011)   OF oDlgPsw PIXEL COLOR CLR_BLUE // "Senha:"
  @ 091, 035 MSGET oPswVld VAR cPswVld SIZE 040, 4 PASSWORD OF oDlgPsw PIXEL COLOR CLR_BLACK
  
  oEncMtv := MsMGet():New(cAliasMtv, nRecMtv, 5,,,, aGetsMtv, {108, 004, 160, 200}, aGetsMtv, 3,,,, oDlgPsw)
  
  oBtnOk := tButton():New(165, 004, STR0012, oDlgPsw, {|| IIf(lRet := Obrigatorio(aGets, aTela) .And. FS_VldUser(cGcsCodLoc, cUsrVld, cPswVld), oDlgPsw:End(), .F.)},,,,,,.T.) //"Confirma"
  oBtnCa := tButton():New(165, 084, STR0013, oDlgPsw, {|| lRet := .F., oDlgPsw:End()},,,,,,.T.) // "Cancela"
  
  oBtnOk:SetFocus()
 
 ACTIVATE MSDIALOG oDlgPsw CENTERED

 If !Empty(cReadVar)
  __ReadVar := cReadVar
 EndIf
 
Return({lRet, IIf(lRet, cUsrVld, "")}) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldUserบAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VldUser(cCodLoc, cUsuVld, cPswVld)
 Local lRet    := .T.
 Local cUsuAut := ""

 DbSelectArea("GM1")
 DbSetOrder(1) // GM1_FILIAL + GM1_CODLOC + GM1_CODUSU
 DbSeek(xFilial("GM1") + cCodLoc)
 While !Eof() .And. xFilial("GM1") == GM1->GM1_FILIAL .And. GM1->GM1_CODLOC == cCodLoc
 	If GM1->GM1_AUTORI == "1"
 		cUsuAut += IIF(!Empty(cUsuAut), "/", "") + Upper(AllTrim(GM1->GM1_CODUSU))
 	EndIf
 	
 	DbSkip()
 End
  
 PswOrder(2)
 
 If     !(lRet := Upper(AllTrim(cUsuVld)) $ cUsuAut)
  HS_MsgInf(STR0014, STR0006, STR0015) // "O usuแrio informado nใo possui autoriza็ใo." ### "Aten็ใo" ### "Valida็ใo de Usuแrio"
 ElseIf !(lRet := PswSeek(cUsuVld, .T.))
  HS_MsgInf(STR0016, STR0006, STR0015) // "Usuแrio nใo cadastrado" ### "Aten็ใo" ### "Valida็ใo de Usuแrio"
  
 ElseIf !(lRet := PswName(cPswVld))
  HS_MsgInf(STR0017, STR0006, STR0018) //"Senha Invแlida." ### "Aten็ใo" ### "Valida็ใo de Senha"
  
 EndIf 
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54002  บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FSPlaTrat(cCodCli, cRegGer)
Local lRet   := .F.
Local cAlias := Alias()
Local cSql   := ""    

Default cRegGer := ""

cSql := "SELECT Count(*) nQtdOrc " + ;
		"FROM " + RetSqlName("GT9") + " GT9 " + ;
		"WHERE GT9.D_E_L_E_T_ <> '*' AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "' AND " + ;
		" GT9.GT9_STATUS IN ( '3', '5')"

If HS_EXISDIC({{"C", "GT9_REGGER"}},.F.) .AND. !Empty(cRegGer)	 	
	 //cSql += " AND ( GT9.GT9_REGGER = '" + cRegGer + "' OR GT9.GT9_REGGER = '" + SPACE(LEN(GBH->GBH_CODPAC))  + "' )"
	 cSql += " AND ( GT9.GT9_REGGER = '" + cRegGer + "')"
Else

	cSql += " AND GT9.GT9_CLIENT = '" + cCodCli + "'"
EndIf	 

cSql := ChangeQuery(cSql)

TCQuery cSql New Alias "GT9STA"

lRet := GT9STA->nQtdOrc > 0

GT9STA->(DBCloseArea())

DbSelectArea(cAlias)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_URGENCIAบAutor  ณ Rogerio Tabosa    บ Data ณ  05/01/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe tela para atribuir o procedimento de urgencia         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_URGENCIA()
Local cComent := Space(TamSx3("GA7_DESC")[1]) 
Local cProdut := Space(TamSx3("GA7_CODPRO")[1]) 
 
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlgUrg TITLE "Procedimento de Urgencia" From 120, 000 To 244 , 550 Of oMainWnd Pixel   

@ 010, 010 Say STR0019  Of oDlgUrg Pixel COLOR CLR_BLUE //"Procedimento"
@ 020, 010 MsGet oProd VAR cProdut Size 40, 009 VALID FS_VLDOBS(cProdut,@cComent) F3 "GA7" OF oDlgUrg Pixel COLOR CLR_BLACK

@ 010, 055 Say STR0020  Of oDlgUrg Pixel COLOR CLR_BLUE //"Descri็ใo"
@ 020, 055 MsGet oSol VAR cComent Size 205, 009 OF oDlgUrg Pixel COLOR CLR_BLACK  
oSol:Disable()

oBtnOk := tButton():New(@ 35, 115, STR0012, oDlgUrg, {|| Iif(!Empty(cProdut),oDlgUrg:End(),Nil)}, 050, 012,,,, .T.)    //"Confirma"

ACTIVATE MSDIALOG oDlgUrg CENTERED 

Return(cProdut) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDOBS บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// Valida existencia do Procedimento/Produto
Static Function FS_VLDOBS(cProdut, cDescri)
Local aArea := GetArea()
Local lRet := .F.
DbSelectArea("GA7")
DbSetOrder(1)
If DbSeek(xFilial("SB1") + PadR(AllTrim(cProdut), Len(GA7->GA7_CODPRO)))
	If GA7->GA7_URGENC == "1"
		lRet 	:= .T. 
		cDescri := GA7->GA7_DESC
		//oSol:Refesh()
		cGbjCodEsp := GA7->GA7_CODESP		
	Else
		lRet := .F.	
	EndIf
EndIf
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSMsgVFin	บAutor  ณMicrosiga           บ Data ณ  20/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta Mensagem de Valida็ใo Financeira                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP														  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSMsgVFin(aVldPFin)

HS_MsgInf(STR0001 + " (" + AllTrim(Str(aVldPFin[1])) + ") " + STR0002 + IIf(FunName() == "HSPAHM54", STR0003 + ".", STR0004 + ".") + Chr(13) + Chr(10) + STR0005, STR0006, STR0007)// "Paciente com" ### "fatura(s) em aberto, impossivel o " ### "agendamento" ### "atendimento" ### "Procurar a administra็ใo" ### "Aten็ใo" ### "Agendamento Ambulatorial"

Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSVldSup	บAutor  ณMicrosiga           บ Data ณ  21/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Autoriza็ใo do Superior e a Justificativa           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP														  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSVldSup(lRet, lHspm24aa)
Local cCodMtv 	:= ""
Local aRetSup 	:= {}

DEFAULT lRet 		:= .T.
DEFAULT lHspm24aa 	:= .F.

If !lHspm24aa .AND. (aRetSup := HS_RetSup())[1]
	cCodMtv := HS_Justif()
	If (lRet := !Empty(cCodMtv))
		
		If FunName() == "HSPAHM54"
			M->GM8_USRFOR := aRetSup[2]
			M->GM8_MTVCLI := cCodMtv
		Else
			M->GCY_ORIMTV := HS_IniPadr("GT7", 1, cCodMtv, "GT7_ORIMTV",, .F.)
			M->GCY_ATEMTV := cCodMtv
			M->GCY_USUMTV := aRetSup[2]
		EndIf
		
	EndIf
EndIf

Return(lRet)
