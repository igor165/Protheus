#INCLUDE "HSPAHM11.ch"
#INCLUDE "MSMGADD.CH"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM11  บAutor  ณMario Arizono       บ Data ณ  07/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณ Funcao para controle das atividades por turno.             ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHM11(cAliasM11, nRegM11, nOpcM11, cTpNasc, cRegate, cRegger, cCodLoc)
	Local aArea   := GetArea()
 Local oDlgM11, nOpcDlg	:= 0
 Local aMntperg := {}
 local oGDGnu, aHGnu := {}, aCGnu := {}, nUGnu := 0, cCondGnu	:= ""
 Local lInclui := .F.
 Local aSize := {}, aObjects := {}, aInfo := {}, aPPanel := {}, aPInfo := {}, aPGets := {}
 Local aButtons := {}
 Local oFolder, oPanelLef, oPanelRig
 
 Local cAcesso := ""
 Local aRMntQues
 
 Local cCond :=""
 Local cCDQues := GETMV("MV_QPLANTA",, "")
 
	Private aTelaPer := {}, aGetsPer := {}
	Private aTelaHis := {}, aGetsHis := {}
 
 Private __cMa7Aces := "G"
 Private aCodUsr := {}
 
 Default cTpNasc  := ""
   
	cAcesso := __cMa7Aces
	
 If !HS_ExisDic({{"T","GNU"}})
  Return(Nil)
 Endif   
 
	  /* Verificar autorizacao de acesso para o medico */
	If !(aCodUsr := HS_VldDAnm(,.F.))[1]
	 Return(Nil)
	EndIf
		
	//Apresenta todos os bot๕es	         
	
 Aadd(aButtons, {"OK",       {|| IIF(FS_VldBot(.T., aCodUsr[2], "0", aMntPerg[2], cAcesso, cCdQues, cRegate, cRegger, oGDGnu, cCodLoc), oDlgM11:End(), Nil) }, STR0001, STR0001}) //"Admissใo"###"Admissใo"
 Aadd(aButtons, {"DESTINOS", {|| IIF(FS_VldBot(   , aCodUsr[2], "1", aMntPerg[2], cAcesso, cCdQues, cRegate, cRegger, oGDGnu, cCodLoc),  oDlgM11:End(), Nil) }, STR0002, STR0003})  //"Transfer๊ncia"###"Transf."
	
	 	
 If Empty(cCdQues)
		cCond :="GFS.GFS_FILIAL = '" + xFilial("GFS") + "' AND GFS.D_E_L_E_T_ <> '*' "
		cCond +="					AND (GFS_CODCRM = '"+aCodUsr[2]+"' OR GFS_CODCRM = '') "
		cCond +="					AND (GFS_TIPPRO = '"+HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_TIPPRO",, .F.)+"' OR GFS_TIPPRO = '') "
   
  If Hs_ExisDic({{"C","GFS_CODLOC"}},.F.)
 		cCond +="					AND (GFS_CODLOC = '"+ cCodLoc +"' OR GFS_CODLOC = '') "
		EndIF
			
	 cCdQues := (aRMntQues := HS_MntQues(cCond))[1]
 EndIf 

		 	
	If Empty(cCdQues)
	 If !Empty(aRMntQues) .And. !aRMntQues[2]
		HS_MsgInf(STR0004,STR0005, STR0006) //"Nenhum questionแrio foi encontrado para os parโmetros (m้dico, especialidade e tipo de profissional) informados."###"Aten็ใo"###"Valida็ใo questionแrio para plantใo"
		EndIf
	 Return(Nil)
	EndIf
	
	If !HS_VldQues(cCDQues, cAcesso)
  HS_MsgInf(STR0007 + cCDQues + "]", STR0005, STR0008)  //"Nใo foi encontrado nenhuma pergunta para o questionแrio ["###"Aten็ใo"###"Valida็ใo Questionแrio"
  RestArea(aArea)
  
  Return(Nil) 
 EndIf
	
  
	cCondGnu := "GNU->GNU_REGGER = '" + GCY->GCY_REGGER + "' "
	
 HS_BDados("GNU", @aHGnu, @aCGnu, @nUGnu, 1,, cCondGnu,, ,,,,,,,,,,,,,,,,)
 nGnuCdTurn := aScan(aHGnu, {| aVet | aVet[2] == "GNU_CDTURN"})
 nGnuCdQues := aScan(aHGnu, {| aVet | aVet[2] == "GNU_CDQUES"})
 nGnuRegAte := aScan(aHGnu, {| aVet | aVet[2] == "GNU_REGATE"})
 nGnuStaTur := aScan(aHGnu, {| aVet | aVet[2] == "GNU_STATUR"})
 nGnuUsuari := aScan(aHGnu, {| aVet | aVet[2] == "GNU_USUARI"})
 
 aSize 			:= MsAdvSize(.T.)
 
 aObjects := {}
 aAdd( aObjects, { 050, 100, .T., .T.} )
 aAdd( aObjects, { 050, 100, .T., .T.} )
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPPanel := MsObjSize( aInfo, aObjects, .T. , .T.)
 
 aObjects := {}	
 aAdd( aObjects, { 100, 100, .T., .T.} )	
 
 aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
	aPGets := MsObjSize( aInfo, aObjects, .T., .T.) 
 
 
 aObjects := {}	
 aAdd( aObjects, { 100, 040, .T., .T., .T.} )
	aAdd( aObjects, { 100, 060, .T., .T., .T.} )
 
 aInfo  := { aPPanel[2, 1], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], 0, 0 }
	aPInfo := MsObjSize( aInfo, aObjects, .T.)
    
	 
 DEFINE MSDIALOG oDlgM11 TITLE OemToAnsi(STR0009) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Atividades por Turno"
  
  /* Panels para manipula็ใo do tamanho da Tela */
  
  oPanelLef	:=	tPanel():New(aPPanel[1, 1], aPPanel[1, 2],, oDlgM11,,,,,, aPPanel[1, 3], aPPanel[1, 4])
  oPanelLef:Align := CONTROL_ALIGN_ALLCLIENT     
  
  oPanelRig	:=	tPanel():New(aPPanel[2, 1], aPPanel[2, 2],, oDlgM11,,,,,, aPPanel[2, 3], aPPanel[2, 4])
  oPanelRig:Align := CONTROL_ALIGN_RIGHT
  
  oPanelGet	:=	tPanel():New(aPInfo[1, 1], aPInfo[1, 2],, oPanelRig,,,,,, aPInfo[1, 3], aPInfo[1, 4])
  oPanelGet:Align := CONTROL_ALIGN_TOP
   
  oPanelResp:=	tPanel():New(aPInfo[2, 1], aPInfo[2, 2],, oPanelRig,,,,,, aPInfo[2, 3], aPInfo[2, 4])
  oPanelResp:Align := CONTROL_ALIGN_ALLCLIENT
 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPanel: oPanelLef	- Questinarios																																																																																																																																					ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	 aMntperg := HS_MntPerg(cCDQues, oPanelLef,, aPGets[1], nOpcM11 == 2, "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .T., cAcesso)
 	If Len(oEncPer:aEntryCtrls) > 0
 	 oEncPer:aEntryCtrls[1]:SetFocus()
 	EndIf
 	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPanel: oPanelTop	- oPInfo[2] Turnos   																																																																																																																																								ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  
  oGDGnu := MsNewGetDados():New(aPInfo[1, 1], aPInfo[1, 2], aPInfo[1, 3], aPInfo[1, 4], 0,,,,,,,,,, oPanelGet, aHGnu, aCGnu)
  oGDGnu:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGDGnu:oBrowse:bChange := {|| HS_BusResp("GNV", {{"GNV->GNV_CDTURN", oGDGnu:aCols[oGDGnu:nAt, nGnuCDTurn]}, {"GNV->GNV_CDQUES", oGDGnu:aCols[oGDGnu:nAt, nGnuCDQues]}}, "HIS"), ;
                                 HS_MntPerg(oGDGnu:aCols[oGDGnu:nAt, nGnuCDQues], oPanelResp,, aPInfo[2], .T., "HIS", "oEncHis",, "aTelaHis", CONTROL_ALIGN_ALLCLIENT, .F., "G"/*cAcesso*/)}
 
  oGDGnu:oBrowse:BlDblClick := {|| IIF(oGDGnu:aCols[oGDGnu:nAt, nGnuStaTur] == "1" .And. cUserName == oGDGnu:aCols[oGDGnu:nAt, nGnuUsuari] .And. oGDGnu:nAt == len(oGDGnu:aCols), FS_Dblclick(oGDGnu:aCols[oGDGnu:nAt, nGnuCDTurn], oGDGnu:aCols[oGDGnu:nAt, nGnuCDQues] ), NIL)}
                   
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPanel: oPanelRig	- Historico dos Turnos   																																																																																																																										ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
 	oDlgM11:bStart := { || oGDGnu:Refresh()}  	                
		 
 ACTIVATE MSDIALOG oDlgM11 ON INIT EnchoiceBar (oDlgM11,	{|| nOpcDlg := 1, Iif(nOpcM11 != 4, IIf(HS_ObrgPer(aMntPerg[3], aMntPerg[2]), oDlgM11:End(), nOpcDlg := 0), oDlgM11:End())},;
                                                									{|| nOpcDlg := 0, oDlgM11:End()},, aButtons)

  
 RestArea(aArea)
Return(Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldBot บAutor  ณ Mario Arizono      บ Data ณ  08/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que Valida Admissao e transferencia.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VldBot(lAdmiss, cCodCrm, cSituac, aCposGrv, cAcesso, cCdQues, cRegate, cRegger, oObj, cCodLoc)
 Local lRet := .T.
 Local aRet := {}
 Local cUsuLog := ""
 
 Default lAdmiss := .F.
 
 If lAdmiss .And. (len(oObj:aCols) > 1 .Or. !Empty(oObj:aCols[1, nGnuCDTurn]))  
  HS_MsgInf(STR0010, STR0005, STR0011)  //"Jแ existe registro com status de admissใo. Verifique!"###"Aten็ใo"###"Valida็ใo Admissใo"
  lRet := .F.
 ElseIf !lAdmiss .And. (len(oObj:aCols) == 1 .And. Empty(oObj:aCols[1, nGnuCDTurn]))  
  HS_MsgInf(STR0012, STR0005, STR0013)  //"Nใo existe registro para realiza็ใo da transfer๊ncia."###"Aten็ใo"###"Valida็ใo transfer๊ncia"
  lRet := .F.
 Endif
 
 If !lAdmiss  .And. lRet
  aRet := FS_VldSen(oObj:aCols[len(oObj:aCols), nGnuUsuari], cCodLoc)
  lRet := aRet[1]
 Endif
  
 If lRet 
  cUsuLog := IIF(!Empty(aRet), aRet[2], IIF(Empty(oObj:aCols[len(oObj:aCols), nGnuUsuari]), cUserName, oObj:aCols[len(oObj:aCols), nGnuUsuari]))
  FS_GrvM11(.T., cCodCrm, cSituac, aCposGrv, cAcesso, cCdQues, cRegate, cRegger, cUsuLog)
 Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvM11  บAutor  ณ Mario Arizono     บ Data ณ  08/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que grava  Anamnese.                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvM11(lInclui, cCodCrm, cSituac, aCposGrv, cAcesso, cCdQues, cRegate, cRegger, cUsuLog)
 Local aArea := GetArea()

	Default lInclui := .F.
	                        
	Begin Transaction	
  /* Grava GNU */
 	If lInclui
   M->GNU_CDTURN := HS_VSxeNum("GNU", "M->GNU_CDTURN", 1)
   ConfirmSx8()
 	 
 	 DbSelectArea("GNU")
 	 DbSetOrder(1)
 		RecLock("GNU", .T.)
 
 			GNU->GNU_FILIAL	:= xFilial("GNU")
 			GNU->GNU_REGATE	:= cRegate
 			GNU->GNU_CDTURN	:= M->GNU_CDTURN
 			GNU->GNU_STATUR	:= cSituac
 			GNU->GNU_REGGER	:= cRegger
	 		GNU->GNU_CODCRM	:= cCodCrm
		 	GNU->GNU_CDQUES	:= cCdQues 
   	GNU->GNU_USUARI := cUsuLog
   	GNU->GNU_DATCON := Date()
		 	GNU->GNU_HORCON := Time()
   
		 MsUnlock()
	 
	 EndIf
	
	// Grava Repositorio de Respostas do Prontuแrio
	 HS_GrvResp("GNV", {{"GNV->GNV_CDTURN", GNU->GNU_CDTURN}, {"GNV->GNV_CDQUES", GNU->GNU_CDQUES}}, aCposGrv)	
	 
	End Transaction
	RestArea(aArea)
Return(Nil)


Static Function FS_Dblclick(cCdTurn, cCdQuest)
 Local aObjects := {}, aInfo := {}, aPObj := {}, aMntTela := {}
 Local oDlgTra 
 Local nOpcA := 0
 Private oEncTra,  aTelaTra := {}

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )
 
 
 DEFINE MSDIALOG oDlgTra TITLE STR0014 From 09, 00 to 40, 100 of oMainWnd  //"Altera Transfer๊ncia"
  
  oPanTra	:=	tPanel():New(aPObj[1, 1], aPObj[1, 2],,,,,,,, aPObj[1, 3], aPObj[1, 4])
  
  HS_BusResp("GNV", {{"GNV->GNV_CDTURN", cCdTurn}, {"GNV->GNV_CDQUES", cCdQuest}}, "HIS")
  aMntTela := HS_MntPerg(cCdQuest, oPantra,, aPObj[1], .F., "HIS", "oEncTra",, "aTelaTra", CONTROL_ALIGN_ALLCLIENT, .F., "G")

  	 
	ACTIVATE MSDIALOG oDlgTra CENTERED ON INIT EnchoiceBar(oDlgTra, 	{|| nOpcA := 1, oDlgTra:End()}, ;
																																																																		{|| nOpcA := 0, oDlgTra:End()})

 If nOpcA == 1
  HS_GrvResp("GNV", {{"GNV->GNV_CDTURN", cCdTurn}, {"GNV->GNV_CDQUES", cCdQuest}}, aMntTela[2])
 Endif
  
oEncHis:Refresh()
Return()              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldSen บAutor  ณ Mario Arizono      บ Data ณ  10/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que valida usuario.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


//Funcaoque monta a tela para validacao do usuario responsavel pela autorizacao transferencia turno
Static Function FS_VldSen(cUsuLog, cCodLoc)

Local cSenha := Space(6), cUsu := space(15)
Local lRet   := .F.

DEFINE MSDIALOG oDlgS TITLE OemToAnsi(STR0015) From 3, 0 To 09, 44 Of oMainWnd  //"Valida็ใo Usuแrio"
 
@ 15, 010 SAY OemToAnsi(STR0016) OF oDlgS PIXEL COLOR CLR_BLUE  //"Usuario:"
@ 15, 035 MSGET OUsuario VAR cUsu SIZE 060, 4 OF oDlgS PIXEL COLOR CLR_BLACK
@ 30, 010 SAY OemToAnsi(STR0017) OF oDlgS PIXEL COLOR CLR_BLUE // //"Senha:"
@ 30, 035 MSGET OSenha VAR cSenha SIZE 040, 4 PASSWORD OF oDlgS PIXEL COLOR CLR_BLACK
ACTIVATE MSDIALOG oDlgS ON INIT EnchoiceBar(oDlgS, {|| IIF(lRet := FS_Verific(@cUsu, cSenha, cUsuLog, cCodLoc), oDlgS:End(), Nil)}, {||lRet := .F., oDlgS:End()}) CENTER
 
Return({lRet, cUsu})

Static Function FS_Verific(cUsu, cSenha, cUsuLog, cCodLoc)

Local lRet     := .T.
 
If Empty(cUsu)  
 PswOrder(3)
 If PswSeek(cSenha, .T.)
  cUsu := SUBSTR(pswret(1)[1, 2], 1, Len(cUsuLog))
 
  If HS_CountTB("GM1", "GM1_CODLOC  = '" + cCodLoc + "' AND GM1_CODUSU = '" + cUsu + "' ")  == 0 .Or. cUsu == cUsuLog
   HS_MsgInf(STR0018, STR0005, STR0019) //"Usuแrio Invแlido"###"Aten็ใo"###"Valida็ใo usuแrio/senha"
   lRet := .F.
  Endif
 Else
  HS_MsgInf(STR0020, STR0005, STR0019) //"Senha Invแlida."###"Aten็ใo"###"Valida็ใo usuแrio/senha"
  lRet := .F.
 EndIf 
Else
 PswOrder(2)
 If PswSeek(cUsu, .T.) .And. (HS_CountTB("GM1", "GM1_CODLOC  = '" + cCodLoc + "' AND GM1_CODUSU = '" + cUsu + "' ") > 0) .And. cUsu <> cUsuLog
  If !PswName(cSenha)
   HS_MsgInf(STR0020, STR0005, STR0019) //"Senha Invแlida."###"Aten็ใo"###"Valida็ใo usuแrio/senha"
   lRet := .F.
  EndIf
 Else
  HS_MsgInf(STR0018, STR0005, STR0019) //"Usuแrio invแlido"###"Aten็ใo"###"Valida็ใo usuแrio/senha"
  lRet := .F.
 EndIf 
EndIf 

 
Return(lRet)
