#INCLUDE "HSPAHP02.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HSPAHp02 ณ Autor ณ Rogerio Machado Tabosaณ data ณ 12/09/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Solicitacao de Autorizacao                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHP02()         

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons := {}

Private nOpcAut   
Private cTipLoc     := ""    
Private cCodigo := "0" // Codigo da SOlicitacao 
Private cCodPla := "0"
Private cCodCon := "0"
Private oGetPac := nil
Private oGetProc  := nil
Private oGetSol := nil
Private oGetMat := nil
Private oGetOpm := nil
Private aHeadPac := {}, aColsPac := {}
Private aHeadGnx := {}, aColsGnx := {}
Private aHeadGE2 := {}, aColsGE2 := {}
Private aHGE2OPM := {}, aCGE2OPM := {}
Private aHeadGE3 := {}, aColsGE3 := {}
Private aCpoGcy  := {"GCY_REGATE","GCY_NOME","GCY_DATATE","GCY_HORATE","GCY_CODLOC","GCY_NOMLOC", "GCZ_CODCON", "GA9_NOME"}  
Private aJoinGcy := {{" JOIN " + RetSqlName("GCZ") + " GCZ", "GCZ_CODCON", "GCZ.GCZ_REGATE=GCY.GCY_REGATE ", "GCZ_CODCON"},;
					  {" JOIN " + RetSqlName("GA9") + " GA9", "GA9_NOME", "GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON", "GA9_NOME"}}
Private aCpoGmj  := {"GMJ_CODAGE","GMJ_NOMPAC","GMJ_DATAGE","GMJ_HORAGE","GMJ_CODLOC","GCS_NOMLOC", "GMJ_CODCON"} 
Private aJoinGmj := {{" JOIN " + RetSqlName("GCS") + " GCS", "GCS.GCS_NOMLOC", "GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GMJ.GMJ_CODLOC", "GCS_NOMLOC"}}
Private aCpoGnx  := {"GNX_CODSOL","GNX_DATINC","GNX_HORINC","GNX_DATSOL","GNX_HORSOL","GNX_CODUSU"}
Private aCpoGe3  := {"GE3_DATSOL","GE3_HORSOL","GE3_QTDSOL","GE3_CODDES","GE3_DDESPE","GE3_DATAUT","GE3_HORAUT","GE3_QTDAUT","GE3_VALAUT","GE3_NROAUT","GE3_SENAUT","GE3_RESAUT","GE3_MNAUTO","GE3_SEQDES"}
Private aCpoGe2  := {"GE2_DATSOL","GE2_HORSOL","GE2_QTDSOL","GE2_CODDES","GE2_DDESPE","GE2_DATAUT","GE2_HORAUT","GE2_QTDAUT","GE2_VALAUT","GE2_NROAUT","GE2_SENAUT","GE2_RESAUT","GE2_MNAUTO","GE2_SEQDES"}

Private cCadastro  	:= OemToAnsi(STR0001) //"Solicitacao de Autorizacao"  
Private oCalend	 
Private Inclui 		:= .F. 
Private nGmjCodSol,	nGmjCodAge, nGmjCodCon, nGcyRegAte, nGcyCodCon, nGnxCodSol, nProcStatus, nMMStatus, nOPMStatus  := 0
Private nProcSeqDes, nMMSeqDes, nOPMSeqDes, nProcCheck, nMMCheck, nOPMCheck, nProcNrAuto, nMMNrAuto, nOPMNrAuto := 0
Private cGcsTipLoc := "0/1/2/4/6" // Variavel utilizada pelo fonte HSPFFSXB para listar os setores do tipo
Private aLegGnx := 	{{"GNX_STATUS == '0'", "BR_VERDE"},{"GNX_STATUS == '1'", "BR_AMARELO"},;
                  	{"GNX_STATUS == '2'", "BR_AZUL"},{"GNX_STATUS == '3'", "BR_VERMELHO"},{"GNX_STATUS == '4'", "BR_PRETO"},{"GNX_STATUS == '5'", "BR_LARANJA"}}
Private aLegGe2 := 	{{"GE2_STATUS == '0'", "BR_VERDE"},{"GE2_STATUS == '1'", "BR_AMARELO"},;
                  	{"GE2_STATUS == '2'", "BR_AZUL"},{"GE2_STATUS == '3'", "BR_VERMELHO"},{"GE2_STATUS == '4'", "BR_PRETO"},{"GE2_STATUS == '5'", "BR_LARANJA"}}                  
Private aLegGe3 := 	{{"GE3_STATUS == '0'", "BR_VERDE"},{"GE3_STATUS == '1'", "BR_AMARELO"},;
                  	{"GE3_STATUS == '2'", "BR_AZUL"},{"GE3_STATUS == '3'", "BR_VERMELHO"},{"GE3_STATUS == '4'", "BR_PRETO"},{"GE3_STATUS == '5'", "BR_LARANJA"}}                  
Private cLoc
Private cConv
Private lExDicCAOnli 	:= Hs_ExisDic({{"C","GA9_CAONLI"}},.F.) 
Private lOnline			:= .F.
Private nGDOpc			:= GD_UPDATE + GD_DELETE
Private lAtuProc		:= .F.
Private lAtuMM			:= .F.
Private lAtuOPM			:= .F.


If !Hs_ExisDic({{"T","GNX"}},.F.)
	Hs_MsgInf("Para a execu็ใo desta rotina ้ necessแrio a execu็ใo do compatibilizar GH147276.",STR0006,STR0007)
	Return
EndIf         
 
If !Pergunte("HSPP02",.T.)
	return
endif

If Empty(mv_par01) 			
	HS_MSGINF(STR0005,STR0006,STR0007)//"Nenhum setor foi selecionado!" # "Aten็ใo" # s"Validacao Controle de Solicita็๕es"			
	Return
End

cLoc	:= mv_par01
cConv   := mv_par02

If !Empty(cConv) .AND. lExDicCAOnli 
	If HS_IniPadr("GA9", 1, Alltrim(cConv), "GA9_CAONLI",, .F.) == "1"
		lOnline := .T. 
		nGDOpc 	:= 0
	EndIf			               
ElseIf !lExDicCAOnli
	lOnline := .T.	
EndIf

cTipLoc := HS_INIPADR("GCS", 1, mv_par01, "GCS_TIPLOC",, .F.)
                      

 aSize := MsAdvSize() 
 aObjs := {{100, 050, .T., .T.,.T.}, ;
           {100, 050, .T., .T., .T.}} 
 aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObj := MsObjSize(aInfo, aObjs, .T.)
 aObjs := {{100, 065, .T., .T.},;
           {100, 035, .T., .T.}} 

 aInfo := {aPObj[1, 2], aPObj[1, 1], aPObj[1, 4], aPObj[1, 3], 0, 0}
 aPEnc := MsObjSize(aInfo, aObjs, .T.)    
    
 aObjs := {{100, 50, .T., .T.}, ;
           {100, 50, .T., .T.}}     	

 aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
 aPAux := MsObjSize(aInfo, aObjs, .T.,.T.) 
 
 aObjs := {{13, 100, .T., .T.}, ;
           {87, 100, .T., .T.}}     	

 aInfo := {aPEnc[1, 2], aPEnc[1, 1], aPEnc[1, 4], aPEnc[1, 3], 0, 0}
 aPPac := MsObjSize(aInfo, aObjs, .T.,.T.) 
 
 
DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
 
	oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4]) //Itens da solicitacao
	oPanel1:Align := CONTROL_ALIGN_BOTTOM 
	
	oPanel2 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oDlgAut,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtros e Pacientes
	oPanel2:Align := CONTROL_ALIGN_LEFT
	
	oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtro
	oPanel6:Align := CONTROL_ALIGN_TOP
	
	oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // Pacientes
	oPanel7:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanel3 := tPanel():New(aPAux[1, 1], aPAux[1, 2],, oDlgAut,,,,,, aPAux[1, 3], aPAux[1, 4])// Calendario e Solicitacoes
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel4 := tPanel():New(aPAux[1, 1], aPAux[1, 2],, oPanel3,,,,,, aPAux[1, 3], aPAux[1, 4])//Calendario
	oPanel4:Align := CONTROL_ALIGN_TOP
	oPanel5 := tPanel():New(aPAux[2, 1], aPAux[2, 2],, oPanel3,,,,,, aPAux[2, 3], aPAux[2, 4])//Solicitacoes
	oPanel5:Align := CONTROL_ALIGN_ALLCLIENT   
	                                           
	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS STR0002, STR0003, STR0004
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT 
	
	oCalend := MsCalend():New(02, 02, oPanel4)
	oCalend :ALIGN := CONTROL_ALIGN_ALLCLIENT   
	oCalend:bChangeMes := {|| FS_DesmCal(oCalend:dDiaAtu),FS_PAINTCAL(cTipLoc),FS_AtuGetD(1,cTipLoc,DTOS(oCalend:dDiaAtu)),oCalend:Refresh()}
	oCalend:bChange := {|| FS_AtuGetD(1,cTipLoc,DTOS(oCalend:dDiaAtu))}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o Calendario                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FS_PAINTCAL(cTipLoc) 
	
	If cTipLoc <> "6"
		If !Empty(cConv)
			HS_BDados("GCY", @aHeadPac, @aColsPac,, 8,, " GCZ.GCZ_NRSEQG=(SELECT MAX(GCZ1.GCZ_NRSEQG) FROM " + RetSqlName("GCZ") + " GCZ1 WHERE GCZ1.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ1.D_E_L_E_T_ <> '*' AND GCZ1.GCZ_REGATE = GCY->GCY_REGATE)  AND EXISTS(SELECT 1 FROM " + RetSqlName("GCZ") + " GCZ2 WHERE GCZ2.GCZ_REGATE = GCY->GCY_REGATE AND GCZ2.GCZ_CODCON = '" + cConv + "' AND GCZ2.GCZ_FILIAL='" + xFilial("GCZ") + "' ) AND EXISTS (SELECT 1 FROM " + RetSqlName("GNX") + " GNX WHERE GNX.GNX_REGATE = GCY->GCY_REGATE AND GNX.GNX_DATINC='" + DTOS(oCalend:dDiaAtu) + "' AND GNX.D_E_L_E_T_ <> '*' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "')",,,"/",,,,,,.T.,,,,,, aCpoGcy, aJoinGcy)
			nGcyRegAte := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_REGATE"})
			nGcyCodCon := aScan(aHeadPac, {|aVet| aVet[2] == "GCZ_CODCON"})			
		Else
			HS_BDados("GCY", @aHeadPac, @aColsPac,, 8,, " GCZ.GCZ_NRSEQG=(SELECT MAX(GCZ1.GCZ_NRSEQG) FROM " + RetSqlName("GCZ") + " GCZ1 WHERE GCZ1.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ1.D_E_L_E_T_ <> '*' AND GCZ1.GCZ_REGATE = GCY->GCY_REGATE)  AND EXISTS (SELECT 1 FROM " + RetSqlName("GNX") + " GNX WHERE GNX.GNX_REGATE = GCY->GCY_REGATE AND GNX.GNX_DATINC='" + DTOS(oCalend:dDiaAtu) + "' AND GNX.D_E_L_E_T_ <> '*' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "')",,,"/",,,,,,.T.,,,,,, aCpoGcy, aJoinGcy)
			nGcyRegAte := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_REGATE"})
			nGcyCodCon := aScan(aHeadPac, {|aVet| aVet[2] == "GCZ_CODCON"})						
		Endif
	Else
		HS_BDados("GMJ", @aHeadPac, @aColsPac,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GNX") + " GNX WHERE GNX.GNX_CODAGE = GMJ->GMJ_CODAGE AND GMJ->GMJ_CODAGE <> '"+Space(TamSx3("GMJ_CODAGE")[1])+ "' AND GNX_REGATE = '"+Space(TamSx3("GCY_REGATE")[1])+ "'  AND GNX.GNX_DATINC='" + DTOS(oCalend:dDiaAtu) + "' AND GNX.D_E_L_E_T_ <> '*' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "')",,,"/",,,,,,.T.,,,,,, aCpoGmj,aJoinGmj)
		nGmjCodAge := aScan(aHeadPac, {|aVet| aVet[2] == "GMJ_CODAGE"})
		nGmjCodCon := aScan(aHeadPac, {|aVet| aVet[2] == "GMJ_CODCON"})		
	End If
	
	oGetPac:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadPac, aColsPac)
	oGetPac:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 
	oGetPac:bChange       := {|| FS_AtuSol(cTipLoc,"")} 
	
	FS_AtuSol(cTipLoc,"") 
	
	//Fitros dos Dados
	HS_GDPesqu( , , oGetPac, oPanel6, 001,.T.)
	
	oGetSol := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel5, aHeadGnx, aColsGnx)
	oGetSol:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetSol:bChange       := {|| FS_AtuSol(cTipLoc,"",oGetSol:nAt)}
	oGetSol:oBrowse:BlDblClick := {|| FS_DbClik(oGetSol,.T.)}  
	
	FS_AtuSol(cTipLoc,"",oGetSol:nAt)
	
	oGetProc := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[1], aHeadGE3, aColsGE3)
	oGetProc:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
	oGetProc:cFieldOk		:= "HS_LNOKGD(1)"
	oGetProc:oBrowse:BlDblClick := {|| FS_DbClik(oGetProc,.F.)}  
    oGetProc:oBrowse:bDelete    := {|| Iif(FS_VDelItem(oGetProc, Len(aHeadGE3) + 1,"Proc") ,{oGetProc:DelLine(),oGetProc:oBrowse:Refresh()},Nil)}

	oGetMat := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[2], aHeadGE2, aColsGE2)
	oGetMat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT           
	oGetMat:cFieldOk		:= "HS_LNOKGD(2)"
	oGetMat:oBrowse:BlDblClick := {|| FS_DbClik(oGetMat,.F.)}  
	
	oGetOpm := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[3], aHGE2OPM, aCGE2OPM)
	oGetOpm:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT         
	oGetOpm:cFieldOk		:= "HS_LNOKGD(3)"	
	oGetOpm:oBrowse:BlDblClick := {|| FS_DbClik(oGetOpm,.F.)}  
                          
	nProcSeqDes := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_SEQDES"})
	nMMSeqDes	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_SEQDES"})
	nOPMSeqDes	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_SEQDES"})

	nProcQtdSol := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_QTDSOL"})
	nMMQtdSol	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_QTDSOL"})
	nOPMQtdSol	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_QTDSOL"})	
	
	nProcDatSol := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_DATSOL"})
	nMMDatSol	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_DATSOL"})
	nOPMDatSol	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_DATSOL"})	

	nProcDatAut := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_DATAUT"})
	nMMDatAut	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_DATAUT"})
	nOPMDatAut	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_DATAUT"})
	
	nProcHorSol := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_HORSOL"})
	nMMHorSol	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_HORSOL"})
	nOPMHorSol	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_HORSOL"})	
	
	nProcNrAuto := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_NROAUT"})
	nMMNrAuto	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_NROAUT"})
	nOPMNrAuto	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_NROAUT"})

	nProcMNAuto := aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_MNAUTO"})
	nMMMNAuto	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_MNAUTO"})
	nOPMMNAuto	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_MNAUTO"}) 
	
	nProcSnhAut	:= aScan(aHeadGE3, {|aVet| aVet[2] == "GE3_SENAUT"})
	nMMSnhAut	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_SENAUT"})
	nOPMSnhAut	:= aScan(aHeadGE2, {|aVet| aVet[2] == "GE2_SENAUT"})		
	
	
	aAdd(aButtons, {"S4WB010N", {|| Hs_ImpSInt(,cCodigo)}, STR0008, STR0009})  //"Imprime Guia Solicitacao"  "Imp. Solicitacao"	
	If lOnline
		aAdd(aButtons, {"AUTOM", {|| HS_TissOnl(cCodigo,cCodCon)}, STR0010, STR0011}) //"Solicitacao Online de Autoriza็ใo"   "Tiss Online"
	ElseIf Empty(cConv)
		aAdd(aButtons, {"AUTOM", {|| HS_TissOnl(cCodigo,cCodCon)}, STR0010, STR0011}) //"Solicitacao Online de Autoriza็ใo"   "Tiss Online"	
		If lExDicCAOnli
			aAdd(aButtons,	{"S4WB001N", {|| FS_SALVAR(,.T.,)}, STR0013,STR0013})  //"Confirmar"
			aAdd(aButtons, {"UPDERROR", {|| FS_NOTAUT()}, STR0014, STR0014})  //"Nใo autorizado"
		EndIf
	Else		
		If lExDicCAOnli
			aAdd(aButtons,	{"S4WB001N", {|| FS_SALVAR(,.T.,)}, STR0013, STR0013})
			aAdd(aButtons, {"UPDERROR", {|| FS_NOTAUT()}, STR0014, STR0014})  //"Imprime Guia Solicitacao"  "Imp. Solicitacao"					
		EndIf
	EndIf	
	aAdd(aButtons, {"SAM", {|| HS_LEGP02()}, STR0015, STR0015}) //"Legenda"
	
	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcAut := 0},,aButtons) 
                                                        
If nOpcAut == 1
	FS_SALVAR(.T.,,)
EndIf
                                                     
Return(.T.)  


Static Function FS_VDelItem(oGD, nDel, cGD)
Local lRet	:= .T.

If !oGD:aCols[oGD:nAt,nDel]
	lRet := MsgYesNo(STR0016, STR0006) // "Deseja excluir o item selecionado?" "Aten็ใo"
	If lRet
		If cGD == "Proc"
			lAtuProc 	:= .T.
		ElseIf cGD == "MM"		
			lAtuMM 		:= .F.
		ElseIf cGD == "OP"
			lAtuOPM		:= .F.
		EndIf
	EndIf
EndIf

Return lRet

Function HS_LNOKGD(nValid)
Default nValid	:= 1

If nValid == 1
	lAtuProc := .T.
EndIf
If nValid == 2
	lAtuMM := .T.
EndIf
If nValid == 3
	lAtuOPM := .T.
EndIf

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtuGetDบ Autor ณ ROGERIO TABOSA     บ Data ณ 16/09/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da GMJ ou GCY        บฑฑ
ฑฑบ          ณ          de acordo com a data escolhida                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParame    ณ	cChave:  chave para pesquisa							  บฑฑ
ฑฑบ			 ณ	nOrd:		 	ordem para pesquisa						  บฑฑ
ฑฑบ			 ณ	cFiltro: Filtro						   					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Controle de Autorizacoes               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Static Function FS_AtuGetD( nOrd, cTipLoc, cFiltro )

 Local lRet := .T.
 
 aHGMJ := {}
 aCGMJ := {}
 nUGMJ := 0 

 aHeadPac := {}
 aColsPac := {}

If cTipLoc <> "6"
	If !Empty(cConv)
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCZ.GCZ_NRSEQG=(SELECT MAX(GCZ1.GCZ_NRSEQG) FROM " + RetSqlName("GCZ") + " GCZ1 WHERE GCZ1.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ1.D_E_L_E_T_ <> '*' AND GCZ1.GCZ_REGATE = GCY->GCY_REGATE)  AND  EXISTS(SELECT 1 FROM " + RetSqlName("GCZ") + " GCZ2 WHERE GCZ2.GCZ_REGATE = GCY->GCY_REGATE AND GCZ2.GCZ_CODCON = '" + cConv + "' AND GCZ2.GCZ_FILIAL='" + xFilial("GCZ") + "' ) AND EXISTS (SELECT 1 FROM " + RetSqlName("GNX") + " GNX WHERE GNX.GNX_REGATE = GCY->GCY_REGATE AND GNX.GNX_DATINC='" + DTOS(oCalend:dDiaAtu) + "' AND GNX.D_E_L_E_T_ <> '*' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "')",,,"/",,,,,,.T.,,,,,, aCpoGcy, aJoinGcy)
		nGcyRegAte := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_REGATE"})
		nGcyCodCon := aScan(aHeadPac, {|aVet| aVet[2] == "GCZ_CODCON"})
	Else
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 8,, " GCZ.GCZ_NRSEQG=(SELECT MAX(GCZ1.GCZ_NRSEQG) FROM " + RetSqlName("GCZ") + " GCZ1 WHERE GCZ1.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ1.D_E_L_E_T_ <> '*' AND GCZ1.GCZ_REGATE = GCY->GCY_REGATE)  AND EXISTS (SELECT 1 FROM " + RetSqlName("GNX") + " GNX WHERE GNX.GNX_REGATE = GCY->GCY_REGATE AND GNX.GNX_DATINC='" + DTOS(oCalend:dDiaAtu) + "' AND GNX.D_E_L_E_T_ <> '*' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "')",,,"/",,,,,,.T.,,,,,, aCpoGcy, aJoinGcy)
		nGcyRegAte := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_REGATE"})
		nGcyCodCon := aScan(aHeadPac, {|aVet| aVet[2] == "GCZ_CODCON"})		
	EndIf
Else
	HS_BDados("GMJ", @aHeadPac, @aColsPac,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GNX") + " GNX WHERE GNX.GNX_CODAGE = GMJ->GMJ_CODAGE AND GMJ->GMJ_CODAGE <> '"+Space(TamSx3("GMJ_CODAGE")[1])+ "' AND GNX.GNX_REGATE = '"+Space(TamSx3("GCY_REGATE")[1])+ "' AND GNX.GNX_DATINC='" + cFiltro + "' AND GNX.D_E_L_E_T_ <> '*' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "')",,,"/",,,,,,.T.,,,,,, aCpoGmj,aJoinGmj)
	nGmjCodAge := aScan(aHeadPac, {|aVet| aVet[2] == "GMJ_CODAGE"})
	nGmjCodCon := aScan(aHeadPac, {|aVet| aVet[2] == "GMJ_CODCON"})
EndIf


 
 oGetPac:SetArray(aColsPac)
 oGetPac:oBrowse:Refresh()
 
 FS_AtuSol(cTipLoc,"") 
 
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_PaintCaบAutor  ณRogerio Tabosa      บ Data ณ  17/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a pintura dos dias do calendario                บฑฑ
ฑฑบ          ณque tiverem solicitacoes pendentes                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_PaintCa(cTipLoc)
//Local nCor1   := 0
//Local nCor2   := 0   
Local dDiaSol := Ctod("")
Local dIni    := Substr(DTOS(oCalend:dDiaAtu),1,6) + "01"
Local dFinal  := LastDay(oCalend:dDiaAtu)
Local cSql    := "" 
Local aArea   := GetArea()

//Seleciona os dias com solicitacoes pendentes        
If cTipLoc <> "6"
 cSql += " SELECT	GNX.GNX_DATINC "
 cSql += " FROM	" + RetSqlName("GNX") + " GNX "
 cSql += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_REGATE = GNX.GNX_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSql += " WHERE GNX.GNX_STATUS='0' AND GNX.GNX_DATINC BETWEEN '" + dIni + "' AND '" + DTOS(dFinal) +  "'"
 cSql += " AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "' AND GNX.D_E_L_E_T_ <> '*' " 
Else
 cSql += " SELECT	GNX.GNX_DATINC "
 cSql += " FROM	" + RetSqlName("GNX") + " GNX "
 cSql += " WHERE GNX.GNX_STATUS='0' AND GNX.GNX_REGATE='" + Space(TamSX3("GCY_REGATE")[1]) + "' AND GNX.GNX_DATINC BETWEEN '" + dIni + "' AND '" + DTOS(dFinal) +  "'"
 cSql += " AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "' AND GNX.D_E_L_E_T_ <> '*' " 
End IF

cSql :=  ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRY" 
DbSelectArea("QRY")
   
dbGotop()          
    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Controla a pintura do Calendario																													ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                
While QRY->(!EOF())
 dDiaSol := STOD(QRY->GNX_DATINC)
 	oCalend:AddRestri(Day(dDiaSol),CLR_RED,CLR_RED) 
   dbSkip()
EndDo     

oCalend:Refresh()

QRY->(DbCloseArea())
RestArea(aArea)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_DesmCalบAutor  ณRogerio Tabosa      บ Data ณ  18/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDesmarca e limpa a selecao dos dias do calendario           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DesmCal(dDataAtu)
 Local dLimpaSele := FirstDay(dDataAtu)

 	While CMonth(dLimpaSele) == CMonth(dDataAtu)
 		oCalend:addRestri(day(dLimpaSele), CLR_BLACK, CLR_WHITE)
 		dLimpaSele  := dLimpaSele + 1
 	EndDo  
 	oCalend:Refresh()

Return(NIL)

Static Function FS_NOTAUT()
Local cDescr	:= Space(100)
Local cAlias	:= ""
Local cStatGnx	:= ""
Local nGE,nCols	:= 0
Local nPosSt	:= 0
Local lOkMotivo	:= .F.
Local nSeqDes	:= 0
Local nMNAuto	:= 0
Local lGrvMot	:= .F.	// para verifica็ใo da existencia de itens marcados nos aCols
Local lFound	:= .F.
Local aCAux		:= {}
Local aGE		:= {{"GE3","oGetProc",nProcSeqDes, nProcMNAuto},;
					{"GE2","oGetMat",nMMSeqDes, nMMMNAuto},;
					{"GE2","oGetOpm",nOPMSeqDes, nOpmMNAuto}}	

If lOnline
	HS_MSGINF(STR0017 ,STR0006, STR0007)  //"Funcionalidade indisponivel para comunica็ใo Online!"
	Return
EndIf

For	nGE := 1 To Len(aGE)
	aCAux := &(aGE[nGE,2] + ":aCols")
	For nCols := 1 To Len(aCAux)
		If aCAux[nCols, 2] == "LBTIK" .AND. !Empty(aCAux[nCols, aGE[nGE,3]])			
			lGrvMot := .T.
			Exit
		EndIf
	Next nCols
	If lGrvMot
		Exit
	EndIf
Next nGE

If lGrvMot
	DEFINE MSDIALOG oDlgM FROM	30,100 TO 170,510 TITLE STR0018 PIXEL //"Motivo da Nใo autoriza็ใo"

  		@ 008, 004 TO 040, 200 Label STR0019 OF oDlgM PIXEL //"Motivo"
  		@ 18, 10 MSGET oDescr VAR cDescr SIZE 180, 10 VALID .T. OF oDlgM PIXEL

		DEFINE SBUTTON FROM 55,160 TYPE 1 ACTION (lOkMotivo := .T.,IIf(lOkMotivo,oDlgM:End(),)) ENABLE OF oDlgM
	ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cDescr)),.F.,.T.) 
Else
	HS_MSGINF(STR0020 ,STR0006, STR0007) //"Selecione um item!"
	Return
EndIf

If !Empty(cDescr) .AND. lOkMotivo
	For	nGE := 1 To Len(aGE)
		aCAux 	:= &(aGE[nGE,2] + ":aCols") 
		cAlias  := aGE[nGE,1] 
		nSeqDes	:= aGE[nGE,3]
		nMNAuto	:= aGE[nGE,4]
		For nCols := 1 To Len(aCAux)
			If aCAux[nCols, 2] == "LBTIK" .AND. !Empty(aCAux[nCols, nSeqDes])
				DbSelectArea(cAlias)
				DbSetOrder(1)
				lFound := DbSeek(xFilial(cAlias) + aCAux[nCols, nSeqDes])
				If lFound
					RecLock(cAlias, .F.)                                       
						&(cAlias + "->" + cAlias + "_MNAUTO") := cDescr 
						&(cAlias + "->" + cAlias + "_STATUS") := "3" 
					MsUnlock()
					&(aGE[nGE,2] + ":aCols[" + Str(nCols) + ",1]") := "BR_VERMELHO"						
					&(aGE[nGE,2] + ":aCols[" + Str(nCols) + "," + Str(nMNAuto) + "]") := cDescr
				EndIf
			EndIf
		Next nCols
	Next nGE 
Else
	Return(Nil)
EndIf   

FS_STAGNX()

If nOpcAut <> 1
	HS_MSGINF(STR0021,STR0006, STR0007) //"Atualiza็ใo salva com sucesso!"
EndIf

Return()

// Altera Status da Solicitacao (GNX) conforme atualiza็ใo dos itens
Static Function FS_STAGNX()                                                           
Local aStatus	:= {}
Local cStatGNX	:= ""
Local aCAux		:= {}
Local nI, nJ	:= 0
Local nSeqDes	:= 0
Local aGE		:= {{"GE3","oGetProc",nProcSeqDes, nProcMNAuto},;
					{"GE2","oGetMat",nMMSeqDes, nMMMNAuto},;
					{"GE2","oGetOpm",nOPMSeqDes, nOpmMNAuto}}	

For nI := 1 to Len(aGE)
		aCAux 	:= &(aGE[nI,2] + ":aCols") 
		nSeqDes	:= aGE[nI,3]
		For nJ := 1 To Len(aCAux)
			If aCAux[nJ, 2] == "LBTIK" .AND. !Empty(aCAux[nJ, nSeqDes])
	        	AADD(aStatus,aCAux[nJ, 1])
	  		EndIf
	  	Next nJ
Next nI					


If (nPosSt := aScan(aStatus, {|aVet| aVet == "BR_VERDE"})) > 0
	cStatGNX := "0"
ElseIf (nPosSt := aScan(aStatus, {|aVet| aVet == "BR_AMARELO"})) > 0
	cStatGNX := "1"
ElseIf (nPosSt := aScan(aStatus, {|aVet| aVet == "BR_AZUL"})) > 0
	cStatGNX := "2"
ElseIf (nPosSt := aScan(aStatus, {|aVet| aVet == "BR_VERMELHO"})) > 0
	cStatGNX := "3"	
EndIf

If !Empty(cStatGNX)
	DbSelectArea("GNX")
	DbSetOrder(1)
	If DbSeek(xFilial("GNX") + cCodigo)
		RecLock("GNX" , .F.)
		GNX->GNX_STATUS := cStatGNX
		MsUnlock()
		oGetSol:aCols[oGetSol:nAt, 1] := IIf(cStatGNX == "0","BR_VERDE",IIf(cStatGNX == "1","BR_AMARELO",IIf(cStatGNX == "2","BR_AZUL","BR_VERMELHO")))
	EndIf
EndIf

Return

// Chamada do Botใo Salvar
Static Function FS_SALVAR(lOk, lConf, lChange)
Local lSelIte1 	:= .F.
Local lSelIte2 	:= .F.
Local lSelIte3 	:= .F. 
Local aMsg		:= {}
Local nPosMsg	:= 0
Default lOk 	:= .F.
Default lConf   := .F.
Default lChange := .F.

If lOnline
	HS_MSGINF(STR0017 ,STR0006, STR0007) //"Funcionalidade indisponivel para comunica็ใo Online!"
	Return
EndIf

If lAtuProc .OR. lConf
	AADD(aMsg,FS_SLVAUT("GE3", oGetProc:aCols, oGetProc:aHeader, nProcSeqDes, nProcNrAuto, lOk, lConf, lChange, nProcMNAuto, nProcSnhAut ))
EndIf
If lAtuMM .OR. lConf	
	AADD(aMsg,FS_SLVAUT("GE2", oGetMat:aCols, oGetMat:aHeader, nMMSeqDes, nMMNrAuto, lOk, lConf, lChange, nMMMNAuto, nMMSnhAut))
EndIf
If lAtuOPM .OR. lConf
	AADD(aMsg,FS_SLVAUT("GE2", oGetOPM:aCols, oGetOPM:aHeader, nOPMSeqDes, nOPMNrAuto, lOk, lConf, lChange, nOpmMNAuto, nOPMSnhAut))
EndIf

If (nPosMsg := aScan(aMsg, { |aVet| aVet[1] == .T.})) == 0 .AND. !lOk
	HS_MSGINF(STR0020 ,STR0006, STR0007) 	    //"Selecione um item!"
ElseIf (nPosMsg := aScan(aMsg, { |aVet| aVet[2] == .T.})) > 0 .AND. !lOk
	HS_MSGINF(STR0021 ,STR0006, STR0007) 	 //"Atualiza็ใo salva com sucesso!"   
EndIf
		
lAtuProc 	:= .F.
lAtuMM 		:= .F.
lAtuOPM		:= .F.

Return

// Grava altera็๕es
Static Function FS_SLVAUT(cAlias, aCAtu, AHAtu, nSeqDes, nNroAuto, lOk, lConf, lChange,nMNAuto, nSnhAut)//, nStatus)

Local lFound
Local aArea		:= GetArea()
Local i 		:= 0 
Local lAtuGeral := .T. // Variavel para controlar se o usuario selecionar todas ou nenhuma para realizar a atualiza็ใo de todos os procedimentos
Local cStatGNX	:= "" 
Local cStatAtu	:= ""
Local cSnhAtu	:= ""
Local cSnhOld	:= ""
Local cNrSeqG	:= ""
Local nPosSt	:= 0
Local nUGE		:= Len(aHAtu) + 1
Local aReturn	:= {.F.,.F.}
Default lOk 	:= .F.
Default lConf   := .F.
Default lChange := .F.

If lOnline
	Return({.T.,.F.})
EndIf

For i := 1 To Len(aCAtu)
	If !aCAtu[i, nUGE]
		If IIf(lConf,aCAtu[i, 2] == "LBTIK",.T.) .AND. !Empty(aCAtu[i, nSeqDes])
			aReturn[1]	:= .T. 
			cStatAtu := IIf(aCAtu[i, 1] == "BR_VERDE","0",IIf(aCAtu[i, 1]=="BR_AMARELO","1",IIf(aCAtu[i, 1]=="BR_VERMELHO","3","2")))
			cSnhAtu	:= IIf(!Empty(aCAtu[i , nSnhAut]),aCAtu[i , nSnhAut],cSnhAtu)
			DbSelectArea(cAlias)
			DbSetOrder(1)
			lFound := DbSeek(xFilial(cAlias) + aCAtu[i, nSeqDes])
			If lFound
				cSnhOld	:= IIf(!Empty(&(cAlias + "->" + cAlias + "_SENAUT")),&(cAlias + "->" + cAlias + "_SENAUT"),cSnhOld)
				cNrSeqG := &(cAlias + "->" + cAlias + "_NRSEQG")
				RecLock(cAlias, .F.)                                       
				HS_GRVCPO(cAlias, aCAtu, AHAtu, i) 
				If Empty(aCAtu[i, nMNAuto])
					If !Empty(aCAtu[i, nNroAuto])
						&(cAlias + "->" + cAlias + "_STATUS") := "2" 
						aCAtu[i, 1] := "BR_AZUL"
					Else
						If lConf                                             
							&(cAlias + "->" + cAlias + "_STATUS") := "1"
							aCAtu[i, 1] := "BR_AMARELO"
						Else
							&(cAlias + "->" + cAlias + "_STATUS") := cStatAtu
							aCAtu[i, 1] := IIf(cStatAtu == "0","BR_VERDE",IIf(cStatAtu == "1","BR_AMARELO",IIf(cStatAtu == "3","BR_VERMELHO","BR_AZUL")))
						EndIf
					EndIf
				EndIf
				MsUnlock()
			EndIf
		EndIf
	Else //Deleta item
		DbSelectArea(cAlias)
		DbSetOrder(1)
		If DbSeek(xFilial(cAlias) + aCAtu[i, nSeqDes])
			RecLock(cAlias, .F., .F.)
				DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		EndIf
	EndIf
Next i

If aReturn[1]  //Se houve altera็๕es salvas

	If (nPosSt := aScan(aCAtu, {|aVet| aVet[1] == "BR_VERDE"})) > 0
		cStatGNX := "0"
	ElseIf (nPosSt := aScan(aCAtu, {|aVet| aVet[1] == "BR_AMARELO"})) > 0
		cStatGNX := "1"
	ElseIf (nPosSt := aScan(aCAtu, {|aVet| aVet[1] == "BR_AZUL"})) > 0
		cStatGNX := "2"
	ElseIf (nPosSt := aScan(aCAtu, {|aVet| aVet[1] == "BR_VERMELHO"})) > 0
		cStatGNX := "3"	
	EndIf
		
	If !Empty(cStatGNX)
		DbSelectArea("GNX")
		DbSetOrder(1)
		If DbSeek(xFilial("GNX") + cCodigo)
			RecLock("GNX" , .F.)
			GNX->GNX_STATUS := cStatGNX
			MsUnlock()
			oGetSol:aCols[oGetSol:nAt, 1] := IIf(cStatGNX == "0","BR_VERDE",IIf(cStatGNX == "1","BR_AMARELO",IIf(cStatGNX == "2","BR_AZUL","BR_VERMELHO")))
		EndIf
	EndIf
	
	If !Empty(cSnhAtu) .AND. !Empty(cNrSeqG) // Grava็ใo da senha de autoriza็ใo na Guia
		DbSelectArea("GCZ")
		DbSetOrder(1)						
		If DbSeek(xFilial("GCZ") + cNrSeqG)
			If Empty(GCZ->GCZ_NRSEN1)
				RecLock("GCZ" , .F.)
				GCZ->GCZ_NRSEN1 := cSnhAtu
				MsUnlock()
			ElseIf !Empty(GCZ->GCZ_NRSEN1) .AND. Alltrim(GCZ->GCZ_NRSEN1) == Alltrim(cSnhOld)
				RecLock("GCZ" , .F.)
				GCZ->GCZ_NRSEN1 := cSnhAtu
				MsUnlock()                
			ElseIf !Empty(GCZ->GCZ_NRSEN1)
			    If Empty(GCZ->GCZ_NRSEN2)
				    RecLock("GCZ" , .F.)
					GCZ->GCZ_NRSEN1 := cSnhAtu
					MsUnlock()
				ElseIf !Empty(GCZ->GCZ_NRSEN2) .AND. Alltrim(GCZ->GCZ_NRSEN2) == Alltrim(cSnhOld)
					RecLock("GCZ" , .F.)
					GCZ->GCZ_NRSEN1 := cSnhAtu
					MsUnlock()                
				ElseIf !Empty(GCZ->GCZ_NRSEN2)								
				    If Empty(GCZ->GCZ_NRSEN3)
					    RecLock("GCZ" , .F.)
						GCZ->GCZ_NRSEN1 := cSnhAtu
						MsUnlock()
					ElseIf !Empty(GCZ->GCZ_NRSEN3) .AND. Alltrim(GCZ->GCZ_NRSEN3) == Alltrim(cSnhOld)
						RecLock("GCZ" , .F.)
						GCZ->GCZ_NRSEN1 := cSnhAtu
						MsUnlock()
					EndIf                					
				EndIf
			EndIf
		EndIf
	EndIf
	
If  cAlias=="GE2"
	FS_AltGB(aCAtu,GNX->GNX_CODAGE)
Endif	
		
	If !lOk
		aReturn[2] := .T. 
	EndIf
EndIf

RestArea(aArea)
Return(aReturn)


// ATUALIZA GETDADOS DE SOLICITACOES E ITENS
Static Function FS_AtuSol(cTipLoc,cFiltro,nAt) 
Local cCodCnv	:= "" 
Local aCposVis	:= {"_DATSOL","_HORSOL","_QTDSOL","_CODDES","_DDESPE","_SEQDES"}
Local aTabela	:= {{"GE2","aHeadGE2"},{"GE3","aHeadGE3"},{"GE2","aHGE2OPM"}}
Local i,j,nPos	:= 0

Default nAt := 0

If lAtuProc .OR. lAtuMM .OR. lAtuOPM
	If MsgYesNo(STR0022  + Alltrim(cCodigo) + " ? ", STR0006) //"Deseja gravar o atendimento com a data retroativa?"###"Aten็ใo"	
		FS_SALVAR(,,.T.)
	Else
		lAtuProc 	:= .F.
		lAtuMM 		:= .F.
		lAtuOPM		:= .F.
	EndIf 
EndIf

If nAt == 0
 nAt := 1 
 aHeadGnx := {} 
 aColsGnx := {}
 If cTipLoc == "6"
  		HS_BDados("GNX", @aHeadGnx, @aColsGnx,, 1,, "GNX->GNX_CODAGE = '" + IIF(Empty(aColsPac[oGetPac:nAt, nGmjCodAge]),"0000000",aColsPac[oGetPac:nAt, nGmjCodAge]) + "' AND GNX->GNX_DATINC = '" + DTOS(oCalend:dDiaAtu) + "'",,"GNX_STATUS","/",,,,{"GNX_IDMARC"},{"'LBNO'"},.T.,aLegGnx,,,,,aCpoGnx)
		nGnxCodSol := aScan(aHeadGnx, {|aVet| aVet[2] == "GNX_CODSOL"})
 Else 
		HS_BDados("GNX", @aHeadGnx, @aColsGnx,, 1,, "GNX->GNX_REGATE = '" + IIf(Empty(aColsPac[oGetPac:nAt, nGcyRegAte]),"0000000",aColsPac[oGetPac:nAt, nGcyRegAte]) + "' AND GNX->GNX_DATINC = '" + DTOS(oCalend:dDiaAtu) + "'",,"GNX_STATUS","/",,,,{"GNX_IDMARC"},{"'LBNO'"},.T.,aLegGnx,,,,,aCpoGnx)
  		nGnxCodSol := aScan(aHeadGnx, {|aVet| aVet[2] == "GNX_CODSOL"})
 End if
 If oGetSol <> nil
  oGetSol:SetArray(aColsGnx)
  oGetSol:Refresh()       
 End If
End If
 aColsGE3 := {}
 aColsGE2 := {}
 aCGE2OPM := {} 
 aHeadGE2 := {} 
 aHeadGE3 := {}   
 aHGE2OPM := {}   

 HS_BDados("GE2", @aHeadGE2, @aColsGE2,, 1,, "GE2->GE2_CODSOL <> '" + Space(TamSX3("GE2_CODSOL")[1]) + "' AND GE2->GE2_CODSOL = '" + aColsGnx[nAt, nGnxCodSol] + "' AND GE2->D_E_L_E_T_ <> '*' ",,"GE2_STATUS","/",,,,{"GE2_IDMARC"},{"'LBNO'"},.T.,aLegGe2,,,,,aCpoGe2)
 HS_BDados("GE3", @aHeadGE3, @aColsGE3,, 1,, "GE3->GE3_CODSOL <> '" + Space(TamSX3("GE3_CODSOL")[1]) + "' AND GE3->GE3_CODSOL = '" + aColsGnx[nAt, nGnxCodSol] + "' AND GE3->D_E_L_E_T_ <> '*'",,"GE3_STATUS","/",,,,{"GE3_IDMARC"},{"'LBNO'"},.T.,aLegGe3,,,,,aCpoGe3)
 HS_BDados("GE2", @aHGE2OPM, @aCGE2OPM,, 1,, "GE2->GE2_CODSOL <> '" + Space(TamSX3("GE2_CODSOL")[1]) + "' AND GE2->GE2_CODSOL = '" + aColsGnx[nAt, nGnxCodSol] + "' AND GE2->D_E_L_E_T_ <> '*' AND EXISTS (SELECT 1 FROM " + RetSqlName("GBI") + " GBI WHERE GBI.GBI_PRODUT = GE2->GE2_CODDES AND GBI.GBI_CITISS='11' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "')",,"GE2_STATUS","/",,,,{"GE2_IDMARC"},{"'LBNO'"},.T.,aLegGe2,,,,,aCpoGe2)//OPM

For i := 1 to Len(aTabela)
	For j := 1 to Len(aCposVis)
		If (nPos := ASCAN(&(aTabela[i,2]),{|aVet| aVet[2] ==  aTabela[i,1] + aCposVis[j]})) > 0
			&(aTabela[i,2] + "[" + Str(nPos) + ",14]") := "V"
		EndIf	
	Next j
Next i

 cCodigo := aColsGnx[nAt, nGnxCodSol]
 cCodPla := HS_IniPadr("GNX", 1, cCodigo, "GNX_CODPLA",,.F.)  
 cCodCon := HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON",,.F.) 

If oGetProc <> Nil	
	If HS_IniPadr("GA9", 1, Alltrim(cCodCon), "GA9_CAONLI",, .F.) == "1"
		lOnline := .T.
		nGDOpc 	:= 0
		oGetProc:lUpdate := .F.		
		oGetMat:lUpdate := .F.		
		oGetOpm:lUpdate := .F.						
	Else
		lOnline := .F.
		nGDOpc 	:= GD_UPDATE + GD_DELETE 
		oGetProc:lUpdate := .T.
		oGetMat:lUpdate := .T.
		oGetOpm:lUpdate := .T.				
	EndIf
	oGetProc:SetArray(aColsGE3)
	oGetProc:Refresh()
	
	oGetMat:SetArray(aColsGE2)
	oGetMat:Refresh()
	
	oGetOpm:SetArray(aCGE2OPM)
	oGetOpm:Refresh()
End If


Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DbClik บAutor  ณRogerio Tabosa      บ Data ณ 22/09/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item do Grid               บฑฑ
ฑฑบ          ณE marcar os itens do Grid dos itens de acordo               บฑฑ
ฑฑบ          ณcom o parametro lMarkAll                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DbClik(oGet,lMarkAll)
Local i     := 0   
Local j     := 0
Local aObjs := {oGetProc,oGetMat,oGetOpm}
Local cTik	:= ""
Default lMarkAll := .F.

If ValType(oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]) == "C"
	If oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos] $ "LBTIK/LBNO"
  		oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos] := IIF(oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos] == "LBTIK", "LBNO", "LBTIK")
  		cTik := oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]
 	Else
 		lMarkAll := .F.
 		oGet:EDITCELL( oGet:OBROWSE, oGet:oBrowse:nAt, oGet:oBrowse:nColPos )
 	EndIf
Else
  oGet:EDITCELL( oGet:OBROWSE, oGet:oBrowse:nAt, oGet:oBrowse:nColPos )
EndIf 
  
 If lMarkAll 
   For i := 1 to Len(aObjs)
    For j := 1 to Len(aObjs[i]:aCols)
     If aObjs[i]:aCols[j, 2] $ "LBTIK/LBNO"
	     aObjs[i]:aCols[j, 2] := cTik//IIF(aObjs[i]:aCols[j, 2] == "LBTIK", "LBNO", "LBTIK")
	     aObjs[i]:Refresh()
	    EndIf 
    Next j
   Next i
  Endif
 
Return(Nil)

Function HS_LEGP02()
Local aLegenda := {{"BR_VERDE"   , "Pendente" }, ;  
                   {"BR_AMARELO", "Aguardando Autoriza็ใo"}, ;  
                   {"BR_AZUL"   , "Autorizada"},; 
                   {"BR_VERMELHO"  , "Nใo Autorizada"},;
                   {"BR_PRETO"  , "Cancelado"},;
                   {"BR_LARANJA"  , "Particular"}} 

BrwLegenda(STR0001, STR0015, aLegenda) //"Controle de Solicita็๕es"###"Legenda"
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GRVGNX บAutor  ณRogerio Tabosa      บ Data ณ 24/09/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGravacao dos dados das solicitacoes de autorizacao na GNX   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_GRVGNX(cRegGer,cNomPac,cCodUsu,cCodAge,cRegAte,cCodPla,cCarInt,cTipInt,cRegInt,cDiaSol,cIndCli,dDtpAdm,dDatAdm,aHProc,aCProc,aHMat,aCMat,cCodCrm,cCodCid,cTdTiss,cCodSAux)
Local lAchou  := .F.
Local cCodSol := ""

Default cCodSAux := ""

cCodSol := cCodSAux

If Empty(aCProc) .And. Empty(aCMat)
	Return(nil)
End If
                    
Begin Transaction 	 
DbSelectArea("GNX") 
	
If !Empty(cCodAge)
	DbSetOrder(2)
	lAchou := DbSeek(xFilial("GNX") + cCodAge)   
Elseif !Empty(cRegAte)
	DbSetOrder(3)                        
	lAchou := DbSeek(xFilial("GNX") + cRegAte + DTOS(dDataBase)) 
Endif

 RecLock("GNX", !lAchou)
  GNX->GNX_FILIAL  := xFilial("GNX")
  If !lAchou
  	GNX->GNX_CODSOL  := cCodSol := GetSXEnum("GNX","GNX_CODSOL",, 1)
  	GNX->GNX_DATINC  := dDataBase
  	GNX->GNX_HORINC  := TIME()
  	GNX->GNX_CODUSU  := cCodUsu
  	GNX->GNX_CODAGE  := cCodAge
  	GNX->GNX_REGATE  := cRegAte
	GNX->GNX_STATUS  := "0" 
  Else
  	cCodSol := GNX->GNX_CODSOL
  End If 
  GNX->GNX_REGGER  := cRegGer 
  GNX->GNX_CODPLA  := cCodPla
  GNX->GNX_NOMPAC  := cNomPac
  GNX->GNX_CARINT  := cCarInt
  GNX->GNX_TIPINT  := cTipInt  
  GNX->GNX_REGINT  := cRegInt  
  GNX->GNX_DIASOL  := IIf(!Empty(cDiaSol),Val(cDiaSol),0)    
  GNX->GNX_INDCLI  := cIndCli
  GNX->GNX_DTPADM  := dDtpAdm  
  GNX->GNX_CODCRM  := cCodCrm
  GNX->GNX_CODPAT  := cCodCid
  GNX->GNX_TDTISS  := cTdTiss
 MsUnLock()	   

If !Empty(cCodSol)
	FS_GrvGE("GE2",aHMat,aCMat,cCodSol)
	FS_GrvGE("GE3",aHProc,aCProc,cCodSol)
EndIf
 
While __lSx8
	ConfirmSx8() 
End

End Transaction
Return(cCodSol)

Static Function FS_GrvGE(cAlias,aHeader,aCols,cCodSol)
Local i       := 0 
Local nPosI   := 0
Local nPos    := 0
Local lAItens := .F.
	    
For i := 1 To Len(aCols)
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	DbSelectArea(cAlias)
	DbSetOrder(1)
	If (nPosI := ASCAN(aHeader,{|aVet| aVet[2]== cAlias+"_SEQDES"}))>0
		lAItens := DbSeek(xFilial(cAlias) + aCols[i,nPosI])
	EndIf
	RecLock(cAlias, !lAItens)
	While SX3->X3_ARQUIVO == cAlias
		If SX3->X3_CONTEXT <> "V"
			If SX3->X3_CAMPO == cAlias+"_CODSOL"
				&(cAlias+"->" + SX3->X3_CAMPO) := cCodSol
			ElseIf (nPos := ASCAN(aHeader,{|aVet| aVet[2]== SX3->X3_CAMPO}))>0
				&(cAlias+"->" + SX3->X3_CAMPO) := aCols[i,nPos]
			Else
				&(cAlias+"->" + SX3->X3_CAMPO) := &(SX3->X3_RELACAO)
			Endif
		Endif
		SX3->(DbSkip())
	End
	MsUnLock()
Next i	 


Return(Nil)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TissOnlบAutor  ณRogerio Tabosa      บ Data ณ 30/09/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณSolicitacao Online de autorizacao Via WebServices           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ       	
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_TissOnl(cCodSol,cCodCon)

Local cNomArq    := ""
Local aArea 	  := GetArea()
Local cCodLayOut := ""
Local cUrlCon    := ""
Local cMsg		  := "" 

Private lAuto    := .T.

If !lOnline
	HS_MsgInf(STR0023,STR0006, STR0007) //"O conv๊nio do paciente estแ parametrizado para Controle Off-line!"###"Aten็ใo"###
	Return(Nil)
EndIf

DbSelectArea("GNX")
DbSetOrder(1)
If DbSeek(xFilial("GNX") + cCodSol) 
 	If GNX->GNX_STATUS $ "2/3/4/5" 
    	HS_MsgInf(STR0024,STR0006, STR0007) //"A Solicita็ใo jแ foi processada"###"Aten็ใo"###
    	Return(Nil)
	EndIf
Else
	HS_MsgInf(STR0025,STR0006, STR0007) //"Solicita็ใo nใo encontrada!"###"Aten็ใo"###
	Return(Nil)
EndIf 

If GA9->(FieldPos("GA9_LAYSOL")) > 0
	cCodLayOut := HS_IniPadr("GA9", 1, cCodCon, "GA9_LAYSOL",,.F.)                                                                      
	cUrlCon    := HS_IniPadr("GA9", 1, cCodCon, "GA9_URLWSE",,.F.)
  
	If !Empty(cCodLayOut)
		DbSelectArea("GG2")
		DbSetOrder(1)
		DbSeek(xFilial("GG2") + cCodLayOut)
		FS_PosSx1("XMLSOL    01",cCodSol)
		FS_PosSx1("XMLSOL    02",cCodCon)      
		Pergunte("XMLSOL",.F.)
		If Type("MV_PAR01") <> "U" .AND. Type("MV_PAR02") <> "U" .AND. MV_PAR01 <> cCodSol
			MV_PAR01 := cCodSol
			MV_PAR02 := cCodCon
		EndIf
		cNomArq := HS_PEDIExp("GG2", GG2->(Recno()), 6)
	Else    
		HS_MsgInf(STR0012,STR0006, STR0007) //"0   Layout nใo encontrado!"###"Aten็ใo"###"Remessa"
		RestArea(aArea)
		Return(.F.)
	EndIf  
EndIf
RestArea(aArea) 
 
If !Empty(cNomArq) .And. !Empty(cUrlCon)
	Processa({|| cMsg :=  HS_SENDXML(Alltrim(cUrlCon),Alltrim(cNomArq),cCodSol)})             
	Hs_msgInf(cMsg,STR0006,STR0001) //"Aten็ใo"
EndIf
Fs_AtuSol(cTipLoc,"") 

Return(Nil) 


Static Function FS_PosSx1(cChave, xConteudo)
Local nForSx1 := 0
 
DbSelectArea("SX1")
DbSetOrder(1) // X1_GRUPO + X1_ORDEM           
If DbSeek(cChave)
	If Type("xConteudo") == "A"
		For nForSx1 := 1 To Len(xConteudo)
			RecLock("SX1", .F.)
			&(xConteudo[nForSx1][1]) := xConteudo[nForSx1][2]
			MsUnLock()
		Next
	EndIf
EndIf

Return(Nil)	 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldP02 บ Autor ณ Rogerio Tabosa     บ Data ณ  14/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ  Valida os campos                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldP02()
Local lRet		:= .T.
Local cCampo	:= ReadVar()

If "_QTDAUT" $ cCampo
	If "GE3" $ cCampo .AND. Type("oGetProc") <> "U"
		If &(cCampo) > oGetProc:aCols[oGetProc:nAt, nProcQtdSol]
			HS_MsgInf(STR0026,STR0006, STR0007) //"A Quantidade informada ้ maior que a solicitada!"###"Aten็ใo"###
			lRet := .F.
		EndIf
	ElseIf "GE2" $ cCampo .AND. Type("oGetMat") <> "U"
	   	If &(cCampo) > oGetMat:aCols[oGetMat:nAt, nMMQtdSol]
			HS_MsgInf(STR0026,STR0006, STR0007) //"A data/hora nใo pode ser anterior a de solicita็ใo!"###"Aten็ใo"###
			lRet := .F.
		EndIf
	EndIf
EndIf

If "_DATAUT" $ cCampo
	If "GE3" $ cCampo .AND. Type("oGetProc") <> "U"
		If &(cCampo) < oGetProc:aCols[oGetProc:nAt, nProcDatSol]
			HS_MsgInf(STR0027,STR0006, STR0007) //"A data/hora nใo pode ser anterior a de solicita็ใo!"###"Aten็ใo"###
			lRet := .F.
		EndIf
	ElseIf "GE2" $ cCampo .AND. Type("oGetMat") <> "U"
		If &(cCampo) < oGetMat:aCols[oGetMat:nAt, nMMDatSol]
			HS_MsgInf(STR0027,STR0006, STR0007) //"A data/hora nใo pode ser anterior a de solicita็ใo!"###"Aten็ใo"###
			lRet := .F.
		EndIf
	EndIf		
EndIf 


If "_HORAUT" $ cCampo
	If "GE3" $ cCampo .AND. Type("oGetProc") <> "U"
		If &(cCampo) < oGetProc:aCols[oGetProc:nAt, nProcHorSol] .AND.  oGetProc:aCols[oGetProc:nAt, nProcDatSol] == oGetProc:aCols[oGetProc:nAt, nProcDatAut]
			HS_MsgInf(STR0027,STR0006, STR0007) //"A data/hora nใo pode ser anterior a de solicita็ใo!"###"Aten็ใo"###
			lRet := .F.
		EndIf
	EndIf
	If "GE2" $ cCampo .AND. Type("oGetMat") <> "U"
		If &(cCampo) < oGetMat:aCols[oGetMat:nAt, nMMHorSol] .AND.  oGetMat:aCols[oGetMat:nAt, nMMDatSol] == oGetMat:aCols[oGetMat:nAt, nMMDatAut]
			HS_MsgInf(STR0027,STR0006, STR0007) //"A data/hora nใo pode ser anterior a de solicita็ใo!"###"Aten็ใo"###
			lRet := .F.
		EndIf
	EndIf
	
EndIf


Return(lRet)   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VSTAUT บAutor  ณRogerio Tabosa      บ Data ณ  14/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para verificar o status da autoriza็ใo do procedimentบฑฑ
ฑฑบ          ณou Mat/Med (Controle de Autoriza็๕es)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VSTAUT(cSeqDes, cAlias)
Local aArea		:= GetArea()
Local cStatus 	:= ""
Local cSql		:= ""
Local lExDicSt 	:= Hs_ExisDic({{"C","GE3_STATUS"}},.F.) 

If lExDicSt
	cSql := " SELECT " + cAlias + "_STATUS FROM " + RetsqlName(cAlias) + " " + cAlias 
	cSql += " WHERE " + cAlias + "_NSEQGD = '" + cSeqDes + "' "
	cSql += " AND " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += " AND " + cAlias + ".D_E_L_E_T_ <> '*' "    
	
	cSql :=  ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "TMPST" 
	
	If !TMPST->(Eof())
		cStatus := &("TMPST->" + cAlias + "_STATUS")
	EndIf
	
	TMPST->(DbCloseArea())	
EndIf
RestArea(aArea)
Return(cStatus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AltGB  บAutor  ณGiuvany Ribeiro     บ Data ณ  12/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a Quantidade Autorizada de Materiais Especiais     บฑฑ
ฑฑบ          ณna Reserva Cirurgica                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_AltGB(aCols,cCodAge)
Local nCols:=0
Local nIndice:=0

 DbSelectArea("SIX")
 DbSetOrder(1)
 DbSeek("GEB")
 
 While SIX->(!Eof()) .And. SIX->INDICE == "GEB"
	nIndice++
 	dbSkip()
 Enddo

 DbSelectArea("GEB") 
 Iif (nIndice >2 , DbSetOrder(2),DbSetOrder(nIndice))
	For nCols := 1 To Len(aCols)
		If  DbSeek(xFilial("GEB") + cCodAge + aCols[nCols,6])
			RecLock("GEB", .F.)
			GEB->GEB_QTDAUT:= aCols[nCols,10]  
			MsUnlock()
		Endif
	Next nCols

Return(nil)

