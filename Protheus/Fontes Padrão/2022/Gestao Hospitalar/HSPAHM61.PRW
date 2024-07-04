#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "HSPAHM61.CH"
#include "dbtree.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPAHM61 ³ Autor ³ Rogerio Tabosa		³ data ³ 03/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta ficha de tratamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gestao Hospitalar                            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 					
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 
Function HSPAHM61(cCodCli, cRegGer)

Local nL				:= 0
Local cSql 			:= "" 
Local aButtons		:= {}
Local nOpcA 			:= 0, nGDOpc := 0
Local aOrcs			:= {}
Local oGDGfu, aHGfu 	:= {}, aCGfu := {}, nUGfu := 0, cCondGfu	:= ""
Local aHeadGM8   		:= {}, aColsGM8 := {}, nUGM8 := 0
Local aLegGM8    		:= {}                                                 
//Inserindo campos para exibicao de agendamentos cancelados
Local aCpoGM8  := {	"GM8_DATAGE" ,"GM8_HORAGE" ,"GM8_CODCRM" ,"GM8_NOMCRM" ,"GM8_REGGER" ,"GM8_NOMPAC","GM8_DATCAD",;
	            	"GM8_HORCAD" ,"GM8_CODUSU" ,"GM8_CODLOC" ,"GM8_LOCDES" ,"GM8_CODDIS" ,"GM8_DESDIS","GM8_CODREC",;
	            	"GM8_CODSAL" ,"GM8_NOMSAL" ,"GM8_USRFOR" ,"GM8_MTVCLI" ,"GM8_DSMCLI" ,"GCY_DINIPE","GCY_HINIPE",;
				    "GM9_REGGER" ,"GM9_NOMPAC" ,"GM9_DATCAN" ,"GM9_HORCAN" ,"GM9_USUCAN" ,"GM9_CODCAN","GM7_DESCAN"}
local aJoinGM9   		:= {}
Local nGM8CodLoc 		:= 0
Local nGM8LocDes 		:= 0
local aNewGM8    		:= {}
Local nTam				:= 15

//Declaração das privates
Private cCadastro		:= STR0001 //"Consulta Ficha de tratamento"
Private aTelaHis 		:= {}, aGetsHis := {}
Private lItem    		:= .F.     
Private cPromIte 		:= ""
Private cCargIte 		:= ""
Private cResoIte 		:= ""

//Declaração das Default
Default cCodCli 		:= SA1->A1_COD
Default cRegGer 		:= GBH->GBH_REGGER

aJoinGM9 := {{" LEFT JOIN " + RetSqlName("GM9") + " GM9", "GM9_DATCAN", "GM9.GM9_FILIAL = '" + xFilial("GM9") + "' AND GM9.D_E_L_E_T_ <> '*' AND GM8.GM8_CODAGE = GM9.GM9_CODAGE AND GM9.D_E_L_E_T_ <> '*' AND GM9.GM9_FILIAL = '" + xFilial("GM9") + "' " + IIf(!Empty(cRegGer)," AND GM9_REGGER = '" + cRegGer + "'", ""), "GM9_DATCAN"}}
//Inserindo campos par aexibicao de agendamentos cancelados
AADD(aJoinGM9 , {"", "GM9_HORCAN", "", "GM9_HORCAN"}) 
AADD(aJoinGM9 , {"", "GM9_USUCAN", "", "GM9_USUCAN"}) 
AADD(aJoinGM9 , {"", "GM9_CODCAN", "", "GM9_CODCAN"}) 
AADD(aJoinGM9 , {"", "GM9_NOMPAC", "", "GM9_NOMPAC"})
AADD(aJoinGM9 , {"", "GM9_REGGER", "", "GM9_REGGER"})
AADD(aJoinGM9 , {" LEFT JOIN " + RetSqlName("GM7") + " GM7", "GM7_DESCAN", "GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' AND GM9.GM9_CODCAN = GM7.GM7_CODCAN ", "GM7_DESCAN"}) 
Inclui := .F.
//0=liberado;1=Ocupado;2=Bloqueado;3=Atendido;4=Ocupado/Bloqueado;5=Confirmado;6=Retorno
Aadd(aLegGM8,{"GM8_STATUS == '0' .AND. empty(GM9_DATCAN)", 			"BR_VERDE"   }) //"Livre"
Aadd(aLegGM8,{"GM8_STATUS == '1'",									"BR_VERMELHO"}) //"Agenda Ocupada"
Aadd(aLegGM8,{"GM8_STATUS == '6'", 									"BR_PRETO"   }) //"Encaixe Ocupado"
Aadd(aLegGM8,{"GM8_STATUS == '2'",									"BR_AMARELO" }) //"Bloqueado"
Aadd(aLegGM8,{"GM8_STATUS == '3'", 									"BR_PINK"    }) //"Atendido"
Aadd(aLegGM8,{"GM8_STATUS == '4'", 									"BR_AZUL"    }) //"Ocupado/Bloqueado"
Aadd(aLegGM8,{"GM8_STATUS == '5'", 									"BR_LARANJA" }) //Confirmado //"Confirmado"
Aadd(aLegGM8,{"GM8_STATUS == '1' .AND. GM8_DATAGE < dDataBase ", 	"BR_VIOLETA" }) //Confirmado //"Confirmado"
Aadd(aLegGM8,{"GM8_STATUS == '0' .AND. !empty(GM9_DATCAN)", 		"BR_CINZA"   }) //"Cancelado"

oTFont := TFont():New('Arial',,-14,.T.)
oTFont:Bold := .T.

oTFont2 := TFont():New('Arial',,-12,.T.)
oTFont2:Bold := .T.

aSize	:= MsAdvSize(.T.)

aObjects := {}

aAdd( aObjects, { 045, 100, .T., .T.} )
aAdd( aObjects, { 055, 100, .T., .T.} )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.,.T.)

aObjects := {}

aAdd( aObjects, { 100, 100, .T., .T.,.T.} )
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0,  0 }
aPInfo := MsObjSize( aInfo, aObjects, .T.,.T.)

DEFINE MSDIALOG oDlgM61 TITLE OemToAnsi(STR0001 + " - " + STR0088 + cRegGer + " / " + STR0089 + Posicione("GBH",1,xFilial("GBH") + cRegGer, "GBH_NOME")) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Consulta Ficha de tratamento" ### "Prontuário : " ### "Paciente : " 

HS_PlnTree(cCodCli, oDlgM61, aPInfo[1], , .T.,cRegGer)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Historico de Consultas Agendadas				                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nColFim := (aPInfo[1, 4]*2) + ((aPInfo[1, 4]*2) * 0.10) // Dobro da primeira mais 10%

@aPInfo[1, 1]+15+nTam,aPInfo[1, 4] + 5  SAY oSay10 PROMPT OemToAnsi(STR0002) SIZE 150,017 OF oDlgM61 PIXEL COLOR CLR_BLUE FONT oTFont //"Historico de Consultas Agendadas"

HS_BDados("GM8" , @aHeadGM8, @aColsGM8, @nUGM8  , 1   , /*lFilial*/, " GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.GM8_STATUS IN ('0','1','3','4','5','6') " +; 
			" AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' AND (GM8.GM8_REGGER = '" + cRegGer + "' OR GM9.GM9_REGGER = '" + cRegGer + "')  " ,/*lStatus*/,"GM8_STATUS",;
			/*cLstCpo*/,/*cElimina*/,/*cCpoNao*/,/*cStaReg*/,/*cCpoMar*/,/*cMarDef*/,.F.   ,aLegGM8,/*lEliSql*/,.T.,/*cCposGrpBy*/,/*cGroupBy*/, aCpoGM8 , aJoinGM9,;
		   /*aCposCalc*/,"GM8_DATAGE DESC, GM8_HORAGE DESC",/*aCposVis*/,/* aCposAlt*/,/* cCpoFilial*/, /*aCposFim*/,/* lGetMemo*/) 
		  
aNewGM8  := FS_ajuOrdM61(aHeadGM8,{"GM8"},"GM8_STATUS",aColsGM8)
aHeadGM8 := aNewGM8[1] 
aColsGM8 := aNewGM8[2] 


nGM8NomPac := aScan(aHeadGM8, {| aVet | aVet[2] == "GM8_NOMPAC"})
nGM9NomPac := aScan(aHeadGM8, {| aVet | aVet[2] == "GM9_NOMPAC"})
nGM8RegGer := aScan(aHeadGM8, {| aVet | aVet[2] == "GM8_REGGER"})
nGM9RegGer := aScan(aHeadGM8, {| aVet | aVet[2] == "GM9_REGGER"})
nGM8NomCrm := aScan(aHeadGM8, {| aVet | aVet[2] == "GM8_NOMCRM"})
nGM8CodCrm := aScan(aHeadGM8, {| aVet | aVet[2] == "GM8_CODCRM"})
nGM8CodLoc := aScan(aHeadGM8, {| aVet | aVet[2] == "GM8_CODLOC"})
nGM8LocDes := aScan(aHeadGM8, {| aVet | aVet[2] == "GM8_LOCDES"})

For nL := 1 To Len(aColsGM8) 
	If Empty(aColsGM8[nL,nGM8NomPac]) .AND. !Empty(aColsGM8[nL,nGM9NomPac])
		aColsGM8[nL,nGM8RegGer] := aColsGM8[nL,nGM9RegGer] 		
		aColsGM8[nL,nGM8NomPac] := aColsGM8[nL,nGM9NomPac] 				
	EndIf	                      
	If Empty(aColsGM8[nL,nGM8NomCrm]) .AND. !Empty(aColsGM8[nL,nGM8CodCrm])
		aColsGM8[nL,nGM8NomCrm] := Posicione("SRA",11,xFilial("SRA")+aColsGM8[nL,nGM8CodCrm],"RA_NOME")
	EndIf
	
	If Empty(aColsGM8[nL,nGM8LocDes]) .AND. !Empty(aColsGM8[nL,nGM8CodLoc])
		aColsGM8[nL,nGM8LocDes] := Posicione("GCS",1,xFilial("GCS")+aColsGM8[nL,nGM8CodLoc],"GCS_NOMLOC")
	EndIf	
Next nL   

oGDGM8 := MsNewGetDados():New(aPInfo[1, 1]+25+nTam, aPInfo[1, 4] + 5, aPInfo[1, 3]/4+6, nColFim,0,,,,,,,,,, oDlgM61, aHeadGM8, aColsGM8)    // 000 000 300 500
oGDGM8:oBrowse:BlDblClick := {|| HSM61AGELEG() }


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Historico de Anamnese e Observações do Profissional                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelAnm := tPanel():New(aPInfo[1, 3]/2 + 5 , aPInfo[1, 4] + 5,, oDlgM61,,,,,, aPInfo[1, 3], (aPInfo[1, 3]/2)-7)// Pacientes
@aPInfo[1, 3]/4 +6,aPInfo[1, 4] + 5  SAY oSay10 PROMPT OemToAnsi(STR0003) SIZE 150,012 OF oDlgM61 PIXEL COLOR CLR_BLUE FONT oTFont //"Historico do Profissional"

cCondGfu := "GFU->GFU_REGGER = '" + cRegGer + "' " //"' AND GFU->GFU_STANAM = '1' "

HS_BDados("GFU" , @aHGfu , @aCGfu  , @nUGfu     , 1   ,/*lFilial*/, cCondGfu,/*lStatus*/,/*cCpoLeg*/,;
          /*cLstCpo*/,/*cElimina*/ ,/*cCpoNao*/ ,/*cStaReg*/    ,/*cCpoMar*/,/*cMarDef*/,/*lLstCpo*/,;
          /*aLeg*/   ,/*lEliSql*/  ,/*lOrderBy*/,/*cCposGrpBy*/ ,/*cGroupBy*/,/*aCposIni*/,/*aJoin*/,;
          /*aCposCalc*/, "GFU_DATCON DESC, GFU_HORCON DESC",/*aCposVis*/,/* aCposAlt*/,/* cCpoFilial*/, /*aCposFim*/,/* lGetMemo*/)

nGfuCdAnam := aScan(aHGfu, {| aVet | aVet[2] == "GFU_CDANAM"})
nGfuCdQues := aScan(aHGfu, {| aVet | aVet[2] == "GFU_CDQUES"})
nGfuRegAte := aScan(aHGfu, {| aVet | aVet[2] == "GFU_REGATE"})
nGfuRegGer := aScan(aHGfu, {| aVet | aVet[2] == "GFU_REGGER"})

oGDGfu := MsNewGetDados():New(aPInfo[1, 3]/4 +15, aPInfo[1, 4] + 5, aPInfo[1, 3]/2, nColFim, 0,,,,,,,,,, oDlgM61, aHGfu, aCGfu)

If !Empty(oGDGfu:aCols[1, nGfuCDQues])
	oGDGfu:oBrowse:bChange := {|| HS_BusResp("GFK", {{"GFK->GFK_CDANAM", oGDGfu:aCols[oGDGfu:nAt, nGfuCDAnam]}, {"GFK->GFK_CDQUES", oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues]}}, "HIS"), ;
	HS_MntPerg(oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues], oPanelAnm,, {aPInfo[1, 3]/2 + 5,aPInfo[1, 4] + 5,aPInfo[1, 3], nColFim}, .T., "HIS", "oEncHis",, "aTelaHis", CONTROL_ALIGN_LEFT, .F., "G")}
EndIf

Aadd(aButtons	, {"edit_ocean", {||HSPGBHBco(cRegGer)}, STR0004}) //"Banco de Conhecimentos"

If GetNewPar("MV_HSPCERD","0") == "1"
	Aadd(aButtons	, {"edit_ocean", {||HSCerDigOP(oGDGfu)}, STR0102}) //"Certificado Digital"
EndIf

ACTIVATE MSDIALOG oDlgM61 ON INIT EnchoiceBar (	oDlgM61,	{|| nOpcA := 1, oDlgM61:End()},;
																	{|| nOpcA := 0, oDlgM61:End() },,aButtons)
Return

Static Function FS_STATREE(cCargo, oDlgM61)
Local aControl 	:= oDlgM61:aControls
Local nX		:= 0

If "PROC" == SubStr(cCargo, 1, 4)
	
	oAma:lVisible 	:= .F.
	oBlue:lVisible 	:= .F.
	oBlue2:lVisible 	:= .T.
	oBlack:lVisible 	:= .T.
	oViol:lVisible 	:= .F.
	oWhit:lVisible 	:= .F.
	oLaranja:lVisible	:= .T.
	
	For nX := 1 To Len(aControl)
		If ( ValType(aControl[nX])=="O")
			If ( ValType(aControl[nX]:Cargo)=="C")
				Do Case
					Case ( aControl[nX]:Cargo == "AMA")
						aControl[nX]:SetText("")
					Case ( aControl[nX]:Cargo == "RED")
						aControl[nX]:SetText("Pendente")
					Case ( aControl[nX]:Cargo == "BLUE")
						aControl[nX]:SetText("")
					Case ( aControl[nX]:Cargo == "AZUL2")
						aControl[nX]:SetText("Em Atendimento")					
					Case ( aControl[nX]:Cargo == "GREEN")
						aControl[nX]:SetText("Atendido")
					Case ( aControl[nX]:Cargo == "BLACK")
						aControl[nX]:SetText("Cancelado")
					Case ( aControl[nX]:Cargo == "VIOL")
						aControl[nX]:SetText("")
					Case ( aControl[nX]:Cargo == "WHIT")
						aControl[nX]:SetText("")
					Case ( aControl[nX]:Cargo == "LARA")
						aControl[nX]:SetText("Agendado")	
				EndCase
			EndIf
		EndIf
	Next nX
	
Else
	
	For nX := 1 To Len(aControl)
		If ( ValType(aControl[nX])=="O")
			If ( ValType(aControl[nX]:Cargo)=="C")
				Do Case
					Case ( aControl[nX]:Cargo == "AMA")
						aControl[nX]:SetText("Pendente")
					Case ( aControl[nX]:Cargo == "RED")
						aControl[nX]:SetText("Pend.Financ.")
					Case ( aControl[nX]:Cargo == "BLUE")
						aControl[nX]:SetText("Aprovado")
					Case ( aControl[nX]:Cargo == "GREEN")
						aControl[nX]:SetText("Liberado")
					Case ( aControl[nX]:Cargo == "BLACK")
						aControl[nX]:SetText("Cancelado")
					Case ( aControl[nX]:Cargo == "VIOL")
						aControl[nX]:SetText("Em tratamento")
					Case ( aControl[nX]:Cargo == "WHIT")
						aControl[nX]:SetText("Finalizado")
					Case ( aControl[nX]:Cargo == "LARA")
						aControl[nX]:SetText("")	
					Case ( aControl[nX]:Cargo == "AZUL2")
						aControl[nX]:SetText("")	
				EndCase
			EndIf
		EndIf
	Next nX
	
	oAma:lVisible    	:= .T.
	oBlue:lVisible   	:= .T.
	oBlue2:lVisible  	:= .F.
	oBlack:lVisible  	:= .T.
	oViol:lVisible   	:= .T.
	oWhit:lVisible   	:= .T.
	oLaranja:lVisible	:= .F.
EndIf

oAma:Refresh()
oBlue:Refresh()
oBlack:Refresh()
oViol:Refresh()
oWhit:Refresh()
oLaranja:Refresh()
oBlue2:Refresh()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPM61AU ³ Autor ³ Rogerio Tabosa		³ data ³ 06/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Auditoria Financeira Clinica                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gestao Hospitalar                            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM61AU(cCodCli)

Local cSql 		:= ""
Local nOpcA 	:= 0, nGDOpc := 0
Local aOrcs		:= {}
LOCAL aGTJadd	:= {}
LOCAL nI 		:= 0
Local bKeyF12 	:= SetKey(VK_F12, {|| Fs_AtuaItem()})
Local aButtons	:= {}

Private aLegGT9 		:= 	{{"GT9_STATUS == '0'", "BR_AMARELO"		},;
							 {"GT9_STATUS == '1'", "BR_VERMELHO"	},;
							 {"GT9_STATUS == '2'", "BR_AZUL"		},;
							 {"GT9_STATUS == '3'", "BR_VERDE"		},;
							 {"GT9_STATUS == '4'", "BR_PRETO"		},;
							 {"GT9_STATUS == '5'", "BR_VIOLETA"		},;
							 {"GT9_STATUS == '6'", "BR_BRANCO"		}}
Private cCondGT9		:= ""						
Private aHeadGT9Or 		:= {}, aColsGT9Or := {}
Private aLegGTJ 		:= {{"GTJ_STATUS == '0'", "BR_AMARELO"		},;
           	   			 	{"GTJ_STATUS == '1'", "BR_VERDE"		},;
           				 	{"GTJ_STATUS == '2'", "BR_PRETO"		},;
           				 	{"GTJ_STATUS == '3'", "BR_LARANJA"		},;
           				 	{"GTJ_STATUS == '4'", "BR_VIOLETA"		},;           				     
           				 	{"GTJ_STATUS == '5'", "BR_VERMELHO"		}}
Private aHeadSCK 		:= {}, aColsSCK := {} 
Private aCpoGt9 		:= {"GT9_NUMFAT" ,"GT9_NUMLOJ" ,"GT9_CLIENT" ,"GT9_NOMCLI" ,"GT9_DTEMIS" ,"GT9_USUORC" ,"GT9_VIGINI" ,"GT9_VIGFIN",;
	                        "GT9_REGGER" ,"GT9_NOMPAC" ,"GT9_MTVAGE" ,"GT9_DESMTV" ,"GT9_USRFOR" ,"GT9_COBRAN" ,"GT9_CODSOL" ,"GT9_NRCONT","GT9_COBRAN"}
Private aCpoSck  		:= {"GTJ_PRIORI" ,"GTJ_PRODUT" ,"GTJ_DESPRO" ,"GTJ_NUMTIT" ,"B1_PRV1"    ,"CK_QTDVEN"  ,"CK_PRCVEN"  ,"CK_VALOR"  ,"CK_DESCONT",;
						    "CK_VALDESC" ,"GTJ_MTVAGE" ,"GTJ_DESMTV" ,"GTJ_USRFOR" ,"CK_PRUNIT"  ,"CK_OBS"     ,"CK_COMIS1"  ,"CK_DT1VEN" ,"GTJ_ITEM", "CK_ITEM"}
Private lCposGTJ  		:= GTJ->(FieldPos("GTJ_PREFIX")) > 0 .And.  GTJ->(FieldPos("GTJ_TIPO")) > 0 .And.  GTJ->(FieldPos("GTJ_PARCEL")) > 0 .And.  GTJ->(FieldPos("GTJ_FORNEC")) > 0 .And. GTJ->(FieldPos("GTJ_LOJA")) > 0

If lCposGTJ
	aAdd(aCpoSck,"GTJ_PREFIX")
	aAdd(aCpoSck,"GTJ_TIPO"  )
	aAdd(aCpoSck,"GTJ_PARCEL")
	aAdd(aCpoSck,"GTJ_FORNEC")
	aAdd(aCpoSck,"GTJ_LOJA"  )
EndIf

Private aJoinSck 		:= {{" LEFT JOIN " + RetSqlName("SCK") + " SCK ", "SCK.CK_QTDVEN", "SCK.CK_FILIAL = '" + xFilial("SCK") + "' AND SCK.D_E_L_E_T_ <> '*' AND GTJ.GTJ_NUMORC = SCK.CK_NUM AND GTJ.GTJ_ITEM = SCK.CK_ITEM ", "CK_QTDVEN"}}
Private cOrdeSck 		:= "GTJ_PRIORI" 
Private cCadastro		:= STR0005 //"Auditoria Financeira" 
Private cCndPg			:= Space(Len(SE4->E4_CODIGO))
Private cNatureza		:= Space(Len(SED->ED_CODIGO))		
Private nCKVALOR		:= 0
Private nPosStaReg		:= 0
Private nGTJPrefix 		:= 0
Private nGTJNumTit		:= 0
Private nGTJParcel 		:= 0
Private nGTJTipo   		:= 0
Private nGTJLoja   		:= 0
Private nGTJFornec 		:= 0
Private cRegGer 		:= ""
Private aCpOrcAlt		:= {"GT9_VIGINI", "GT9_VIGFIN"}
Private oGetOrcIte

Define  FONT oFont  NAME "Arial,12," BOLD  
Define  FONT oFontT NAME "Arial,14," BOLD  

If Empty(cCodCli)
	If Pergunte("HSPM61", .T.) 	
		DbSelectArea("GBH")
		DbSetOrder(1)
		If !Empty(MV_PAR01) .And. DbSeek(xFilial("GBH") + MV_PAR01)
			Default cCodCli	:= GBH->GBH_CODCLI
					 cRegGer 	:= GBH->GBH_CODPAC
		Else
			Default cCodCli	:= ""
					 cRegGer 	:= ""
		Endif
	Else
		Return()
	EndIf     
EndIf    

AADD(aJoinSck , {" LEFT JOIN " + RetSqlName("SB1") + " SB1 ", "SB1.B1_PRV1", "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GTJ.GTJ_PRODUT", "B1_PRV1"})
AADD(aJoinSck , {"", "B1_TIPO"		, "" , "B1_TIPO"	}) 
AADD(aJoinSck , {"", "CK_PRCVEN"	, "" , "CK_PRCVEN"	}) 
AADD(aJoinSck , {"", "CK_VALOR"		, "" , "CK_VALOR"	})
AADD(aJoinSck , {"", "CK_DESCONT"	, "" , "CK_DESCONT"	}) 
AADD(aJoinSck , {"", "CK_VALDESC"	, "" , "CK_VALDESC"	})
AADD(aJoinSck , {"", "CK_VALDESC"	, "" , "CK_VALDESC"	}) 
AADD(aJoinSck , {"", "CK_PRUNIT"	, "" , "CK_PRUNIT"	})
AADD(aJoinSck , {"", "CK_OBS"		, "" , "CK_OBS"		}) 
AADD(aJoinSck , {"", "CK_COMIS1"	, "" , "CK_COMIS1"	})
AADD(aJoinSck , {"", "CK_DT1VEN"	, "" , "CK_DT1VEN"	}) 
AADD(aJoinSck , {"", "CK_ITEM"		, "" , "CK_ITEM"	}) 

//Ponto de Entrada para Inserir campos na GTJ e os valores dos campos customizados da SCK 
If ExistBlock("HM61ADDGTJ") 
      aGTJadd := ExecBlock("HM61ADDGTJ", .F., .F.)
      For nI := 1 To Len(aGTJadd)
      
            AADD(aCpoSck,aGTJadd[nI])
            
            If Substr(aGTJadd[nI],0,2)== 'CK' 
                  AADD(aJoinSck,{"",aGTJadd[nI],"",aGTJadd[nI]})
            Endif
      Next nI
EndIf

Inclui := .F.

aSize	:= MsAdvSize(.T.)

aObjects := {}

aAdd( aObjects, { 100, 035, .T., .T.} )
aAdd( aObjects, { 100, 010, .T., .T.} )
aAdd( aObjects, { 100, 035, .T., .T.} )
aAdd( aObjects, { 100, 020, .T., .T.} )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.,.F.)

aObjects := {}

aAdd( aObjects, { 100, 100, .T., .T.,.T.} )
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0,  0 }
aPGT9  := MsObjSize( aInfo, aObjects, .T.)

aAdd( aObjects, { 100, 100, .T., .T.,.T.} )
aInfo  := { aPPanel[2, 2], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], 0,  0 }
aPSCK  := MsObjSize( aInfo, aObjects, .T.)

aAdd( aObjects, { 100, 100, .T., .T.,.T.} )
aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0,  0 }
aPSTAT := MsObjSize( aInfo, aObjects, .T.)

If Empty(cCodCli)
	cCondGT9 := " GT9_STATUS IN('1','2','3','5') "
Else  
	cCondGT9 := " GT9.GT9_CLIENT = '" + cCodCli + "' "
EndIf 

DEFINE MSDIALOG oDlgAU TITLE OemToAnsi(cCadastro) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd

	HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, cCondGT9,,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,, aCpoGt9,,,"GT9_NUMFAT DESC")
	nGt9NumFat := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_NUMFAT"})
	nGt9NumLoj := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_NUMLOJ"})
	nGt9DtEmis := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_DTEMIS"})
	nGt9Status := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_STATUS"})
	nGt9NumCli := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_CLIENT"}) 
	nGt9RegGer := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_REGGER"}) 
	nGt9Cobran := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_COBRAN"}) 	
	
	//================================================================¿
	//³ Grid dos Orcamentos do Faturamento							 ³
	//================================================================Ù
	@ aPPanel[1, 1]+02,aPPanel[1, 2]+05 SAY oSay PROMPT OemToAnsi(STR0006) SIZE 060,009 OF oDlgAU PIXEL COLOR CLR_HRED FONT oFontT //"Orçamentos: "
	
	oGetOrc:= MsNewGetDados():New(aPPanel[1, 1]+10, aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], GD_UPDATE,,,,aCpOrcAlt,,,,,, oDlgAU, aHeadGT9Or, aColsGT9Or)
	oGetOrc:oBrowse:bGotFocus := {|| FS_ATUITEM(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]) , FS_ORCTotal(oDlgAU, oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat])}
	oGetOrc:oBrowse:bChange   := {|| FS_ATUITEM(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]), FS_ORCTotal(oDlgAU, oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat])}
	oGetOrc:cFieldOk          := "HS_M61AVIG(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat])"			
	
	HS_BDados("GTJ" , @aHeadSCK, @aColsSCK,, 1, , " GTJ.GTJ_NUMORC = '" + oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat] + "' ",,"GTJ_STATUS","/",,,,{"GTJ_IDMARC"},{"'LBNO'"},.T.,aLegGTJ,,.T.,,,aCpoSck  ,aJoinSck,,cOrdeSck)	
	
	nPosMark   		:= Ascan(aHeadSCK,{|x|AllTrim(x[2])== "GTJ_IDMARC"})
	nSckProdut 		:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_PRODUTO"})
	nCKVALDESC		:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_VALDESC"})
	nCKQTDVEN 		:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_QTDVEN "})        
	nCKPRCVEN 		:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_PRCVEN "})
	nCKPRUNIT 		:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_PRUNIT "})
	nCKVALOR 		:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_VALOR  "})
	nPosStaReg 		:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_STATUS"})
	nGTJItem		:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_ITEM  "})
	nGTJNumTit		:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_NUMTIT"})
	If lCposGTJ
		nGTJPrefix	:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_PREFIX"})
		nGTJParcel	:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_PARCEL"})
		nGTJTipo	:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_TIPO  "})
		nGTJLoja	:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_LOJA  "})
		nGTJFornec	:= aScan(aHeadSCK, {|aVet| aVet[2] == "GTJ_FORNEC"})
	EndIf 
	nB1Prv1			:= aScan(aHeadSCK, {|aVet| aVet[2] == "B1_PRV1   "}) 	
	nCKItem			:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_ITEM   "}) 	
	
	//================================================================¿
	//³ Grid dos Itens Orcamentos do Faturamento					 ³
	//================================================================Ù
	@ aPPanel[3, 1],aPPanel[3, 2]+05 SAY oSay PROMPT OemToAnsi(STR0007) SIZE 060,009 OF oDlgAU PIXEL COLOR CLR_HRED FONT oFontT  //"Itens do tratamento: "
	oGetOrcIte:= MsNewGetDados():New(aPPanel[3, 1]+7, aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0,,,,,,,,,, oDlgAU, aHeadSCK, aColsSCK)
	oGetOrcIte:oBrowse:BlDblClick := {|| FS_DbClik(nPosStaReg)}	
	
	//================================================================¿
	//³ Impressão dos totais na tela								 ³
	//================================================================Ù
	nCols 	:= (aPPanel[2, 4] / 8)
	nColAux := (nCols - (nCols * 0.85))
	nSayCol	:= 100
	@ aPPanel[2, 1]+05,    nColAux SAY oSay PROMPT OemToAnsi(STR0008) SIZE 060,009 OF oDlgAU PIXEL COLOR CLR_HBLUE FONT oFont //"Total do Or‡amento "
	@ aPPanel[2, 1]+05,120+nColAux SAY oSay PROMPT OemToAnsi(STR0009) SIZE 060,009 OF oDlgAU PIXEL COLOR CLR_HBLUE FONT oFont//"Descontos "
	@ aPPanel[2, 1]+05,180+nColAux SAY oSay PROMPT OemToAnsi("=")	  SIZE 060,009 OF oDlgAU PIXEL COLOR CLR_HBLUE FONT oFont//"="
	@ aPPanel[2, 1]+05, 60+nColAux SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",16) OF oDlgAU  PIXEL COLOR CLR_HBLUE FONT oFont
	oSay:Cargo := STR0010  //"Valor"
	@ aPPanel[2, 1]+05,150+nColAux SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",14) OF oDlgAU PIXEL COLOR CLR_HBLUE FONT oFont
	oSay:Cargo := STR0011  //"Desconto"
	@ aPPanel[2, 1]+05,210+nColAux SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",16) OF oDlgAU PIXEL COLOR CLR_HBLUE FONT oFont
	oSay:Cargo := STR0012  //"Total"
	
	//================================================================¿
	//³ Legendas do Orçamento										 ³
	//================================================================Ù
	nRow	:= (aPPanel[2, 1] + aPPanel[3, 1])/2
	
	@ nRow, nColAux BitMap NAME "BR_AMARELO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0013 Of  oDlgAU PIXEL //"Orc. Pendente"
	                 
	nColAux := nCols 
	@ nRow, nColAux BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0014 Of  oDlgAU PIXEL // "Pend. Financ."

	nColAux := nCols * 2	
	@ nRow, nColAux BitMap NAME "BR_AZUL" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux +10 Say STR0015 Of  oDlgAU PIXEL //"Aprovado"

	nColAux := nCols * 3	
	@ nRow, nColAux BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux +10 Say STR0016 Of  oDlgAU PIXEL // "Liberado"

	nColAux := nCols * 4	
	@ nRow, nColAux BitMap NAME "BR_PRETO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0017 Of  oDlgAU PIXEL // "Cancelado"

	nColAux := nCols * 5	
	@ nRow, nColAux BitMap NAME "BR_VIOLETA" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0018 Of  oDlgAU PIXEL // "Em tratamento"

	nColAux := nCols * 6
	@ nRow, nColAux BitMap NAME "BR_BRANCO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0019 Of  oDlgAU PIXEL // "Finalizado"
	
	nColAux := nCols * 7
	oBtnCan := tButton():New(@nRow, nColAux, "Canc. Tratamento", oDlgAU, {|| FS_CANORC(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat], oGetOrc:aCols[oGetOrc:nAt, nGt9NumLoj])}, 050, 012,,,, .T.)   
	
	//================================================================¿
	//³ Legendas dos Itens 0=Pendente;1=Realizado;2=Cancelado;3=Agendado;4="Em tratamento";5="Proc. Repetido"; 
	//================================================================Ù
	nCols 	:= (((aPPanel[2, 4] / 4)*2)/6)
	nColAux := (nCols - (nCols * 0.85))

	nRow	:= ((aPPanel[4, 1] + aPPanel[4, 3])/2)-((aPPanel[4, 3] - aPPanel[4, 1])* 0.30)
	
	@ nRow, nColAux BitMap NAME "BR_AMARELO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0020 Of  oDlgAU PIXEL //"Pendente"
	                 
	nColAux := nCols 
	@ nRow, nColAux BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux + 10 Say STR0021 Of  oDlgAU PIXEL // "Realizado"

	nColAux := nCols * 2	
	@ nRow, nColAux BitMap NAME "BR_PRETO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux +10 Say STR0017 Of  oDlgAU PIXEL //"Cancelado"

	nColAux := nCols * 3	
	@ nRow, nColAux BitMap NAME "BR_LARANJA" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux +10 Say STR0022 Of  oDlgAU PIXEL // "Agendado"
	
	nColAux := nCols * 4	
	@ nRow, nColAux BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux +10 Say STR0092 Of  oDlgAU PIXEL // "Proc. Repetido"
	
	nColAux := nCols * 5
	@ nRow, nColAux BitMap NAME "BR_VIOLETA" SIZE 8, 8 NOBORDER Of  oDlgAU PIXEL
	@ nRow, nColAux +10 Say STR0093 Of  oDlgAU PIXEL // "Em atendimento"
	
	nColAux := nColAux + 70	
	@ nRow + 2, nColAux Say STR0023  Of oDlgAU Pixel COLOR CLR_BLUE    //"Cond. Pag"
	@ nRow, nColAux + 30 MsGet oCndPg VAR cCndPg Size 50, 009 F3 "SE4   " OF oDlgAU Pixel COLOR CLR_BLACK     
	
	//nColAux := nColAux + 80	
	@ nRow + 20, nColAux Say STR0024  Of oDlgAU Pixel COLOR CLR_BLUE    //"Natureza"
	@ nRow + 18, nColAux + 30 MsGet oCpoNature VAR cNatureza Size 50, 009 F3 "SED" OF oDlgAU Pixel COLOR CLR_BLACK   
	
	oBtnGer := tButton():New(@nRow, nColAux + 90, STR0025, oDlgAU, {|| FS_GERACNT(cCndPg, cNatureza, oGetOrc:aCols[oGetOrc:nAt, nGt9NumCli], oGetOrcIte:aCols, oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat], nGTJItem)}, 050, 012,,,, .T.)   //"Gera Fatura"
	If lCposGTJ	
		oBtnGer := tButton():New(@nRow + 20, nColAux + 90, STR0095, oDlgAU, {|| FS_ExcFat()}, 050, 012,,,, .T.)   //"Exclui Fatura"
	EndIf
 
	Aadd(aButtons , {"edit_ocean", {||fs_perfCli(1 , IIf(!Empty(cRegGer),cRegGer,oGetOrc:aCols[oGetOrc:nAt, nGt9RegGer]))}, STR0026}) //"Perfil Financeiro"
	Aadd(aButtons , {"edit_ocean", {||fs_perfCli(3 , IIf(!Empty(cRegGer),cRegGer,oGetOrc:aCols[oGetOrc:nAt, nGt9RegGer]))}, STR0027}) //"Ficha de Tratamento"
	Aadd(aButtons , {"edit_ocean", {||Fs_AtuaItem()}, "Filtrar Paciente"}) //"Filtrar Paciente"

ACTIVATE MSDIALOG oDlgAU ON INIT EnchoiceBar (	oDlgAU,	{|| nOpcA := 1,oDlgAU:End()},;
														         	{|| nOpcA := 0,oDlgAU:End()},,aButtons)
SetKey(VK_F12, bKeyF12)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ORCTotal ³ Autor ³Saude                ³ Data ³ 27.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totalizacao do orcamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ORCTotal(oDlgPE, cNOrc)
Local aArea   	:= GetArea()
Local nTotVal 	:= 0
Local nTotDesc	:= 0
Local nPerDesc  := 0
Local nX  		:= 0
Local nL		:= 0
Local aControl	

aControl := oDlgPE:aControls

DbSelectArea("SCJ")
DbSetOrder(1)
If Empty(cNOrc) .OR. !DbSeek(xFilial("SCJ") + cNOrc)
	Return()
EndIf
RegToMemory("SCJ", .F.)

nPerDesc  := M->CJ_DESC4
//=======================================================¿
//³Soma o os valores e os descontos, mostrando-os na tela³
//=======================================================Ù
For nL := 1 To Len(oGetOrcIte:aCols)
	nTotVal  += oGetOrcIte:aCols[nL,nCKVALOR]
	If (oGetOrcIte:aCols[nL,nCKPRUNIT] > oGetOrcIte:aCols[nL,nCKPRCVEN] )
		nTotDesc += A410Arred((oGetOrcIte:aCols[nL,nCKPRUNIT] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR") - A410Arred((oGetOrcIte:aCols[nL,nCKPRCVEN] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR")
	Else
		nTotDesc += oGetOrcIte:aCols[nL,nCKVALDESC]
	EndIf
	
Next nL
nTotDesc += M->CJ_DESCONT
nTotVal  -= M->CJ_DESCONT
nTotDesc += A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
nTotVal  -= A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")

//================================================================¿
//³Soma as variaveis da Enchoice                                  ³
//================================================================?
nTotVal += M->CJ_FRETE
nTotVal += M->CJ_SEGURO
nTotVal += M->CJ_DESPESA
nTotVal += M->CJ_FRETAUT

//================================================================¿
//³Joga os totais na tela para o objeto correspondente            ³
//================================================================?
For nX := 1 To Len(aControl)
	If ( ValType(aControl[nX])=="O")
		If ( ValType(aControl[nX]:Cargo)=="C")
			Do Case
				Case ( aControl[nX]:Cargo $ STR0012) //"Total"
					aControl[nX]:SetText(nTotVal)
				Case ( aControl[nX]:Cargo $ STR0011) //"Desconto"
					aControl[nX]:SetText(nTotDesc)
				Case ( aControl[nX]:Cargo $ STR0010) //"Valor"
					aControl[nX]:SetText(nTotVal+nTotDesc)
			EndCase
		EndIf
	EndIf
Next nX

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUITEM ºAutor  ³Saude               º Data ³  27/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a atualização dos itens do orçamento no GRID 		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUITEM(cNumFat )
Local aArea 		:= GetArea()

aColssck := {}
HS_BDados("GTJ" , @aHeadSCK, @aColsSCK,, 1, , " GTJ.GTJ_NUMORC = '" + cNumFat + "' ",,"GTJ_STATUS","/",,,,{"GTJ_IDMARC"},{"'LBNO'"},.T.,aLegGTJ,,.T.,,,aCpoSck  ,aJoinSck,,cOrdeSck)	
oGetOrcIte:setArray(aColsSck)
oGetOrcIte:oBrowse:refresh()

RestArea(aArea)
Return

Function HS_PlnTree(cCodCli, oDlgTree, aPInfo, cCondSql, lDbClick, cRegGer)
Local aArea 	:= GetArea()
Local oTFont 	:= TFont():New('Arial',,-14,.T.)
Local cAlias   	:= Alias()
Local oTreeOrc 	:= Nil, oSay
Local oSay10   	:= Nil
Local cSql     	:= ""
Local lCriou	:= .F.
Local cOrcAtu	:= Space(Len(GT9->GT9_NUMFAT))
Local lFecha	:= .F.
Local cEspAtu	:= Space(Len(GA7->GA7_CODESP))
Local aRetNode 	:= {}, nCurNodeId := 0
Local lExDenReg := Hs_ExisDic({{"C","GTJ_DENREG"}},.F.)
Local cTpPrSb1 	:= SuperGetMV("MV_TPPRSB1",, "")
Local aLegGT9 	:= 	{{"GT9_STATUS == '0'", "BR_AMARELO" }, ;
					 {"GT9_STATUS == '1'", "BR_VERMELHO"}, ;
					 {"GT9_STATUS == '2'", "BR_AZUL"    }, ;
					 {"GT9_STATUS == '3'", "BR_VERDE"   }, ;
					 {"GT9_STATUS == '4'", "BR_PRETO"   }, ;
					 {"GT9_STATUS == '5'", "BR_VIOLETA" }, ;
					 {"GT9_STATUS == '6'", "BR_BRANCO"  }} 
					
 Local lProcPai  := Hs_ExisDic({{"C", "GTJ_PROPAI"}}, .F.)
 Local cProcPai  := Space(Len(GA7->GA7_CODPRO))
 Local cSessao   := ""
 Local lExProPai := .F.
 Local cDescPai	 := ""
 
 local lFat := lEsp := lTrat := .F.    

 
 Default lDbClick	:= .F.	
 Default cRegGer	:= ""

_SetOwnerPrvt("oAma"    , Nil)
_SetOwnerPrvt("oRed"    , Nil)
_SetOwnerPrvt("oBlue"   , Nil)
_SetOwnerPrvt("oGreen"  , Nil)
_SetOwnerPrvt("oBlack"  , Nil)
_SetOwnerPrvt("oViol"   , Nil)
_SetOwnerPrvt("oWhit"   , Nil)
_SetOwnerPrvt("oLaranja", Nil)
_SetOwnerPrvt("oBlue2"  , Nil)

oTFont:Bold := .T.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os status do orçamento no loja e no faturamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
HS_STATORC(, cCodCli, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta DbTree do plano de tratamento				                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPInfo[2] + 30, aPInfo[2] + 05 SAY oSay10 PROMPT OemToAnsi(STR0027) SIZE 100, 012 OF oDlgTree PIXEL COLOR CLR_BLUE FONT oTFont
 DEFINE DBTREE oTreeOrc FROM aPInfo[1] + 40, aPInfo[2] + 5 TO aPInfo[3] - 20, aPInfo[4] CARGO OF oDlgTree Pixel

cSql := "SELECT GT9.GT9_NUMFAT,GA7.GA7_CODESP, " + if(lProcPai, cSql += " GTJ.GTJ_PROPAI, GTJ.GTJ_SESSAO,","") + " GTJ.GTJ_PRODUT, GTJ.GTJ_PRIORI,GTJ.GTJ_STATUS,GTJ.GTJ_ITEM, " + IIf(lExDenReg, " GTJ.GTJ_DENREG, GTJ.GTJ_FADENT, GTJ.GTJ_DTEXEC,"," '' AS GTJ_DENREG,'' AS GTJ_FADENT, '' AS GTJ_DTEXEC,")  + "GTJ.GTJ_GERSOL, SCK.CK_QTDVEN, GT9.GT9_VIGINI, GT9.GT9_VIGFIN, GT9.GT9_DTEMIS, GT9.GT9_STATUS "
cSql += " FROM " + RetSqlName("GT9") + " GT9 "                               	
cSql += " JOIN " + RetSqlName("GTJ") + " GTJ "
cSql += " ON GT9.GT9_NUMFAT = GTJ.GTJ_NUMORC AND GTJ.D_E_L_E_T_ <> '*' AND GTJ.GTJ_STATUS <> '5' AND GTJ.GTJ_FILIAL = '" +  xFilial("GTJ") + "'"
cSql += " LEFT JOIN " + retSqlName("SCK") + " SCK "
cSql += " ON SCK.D_E_L_E_T_ <> '*' AND SCK.CK_FILIAL = '" + xFilial("SCK") + "' AND SCK.CK_NUM = GT9.GT9_NUMFAT AND SCK.CK_ITEM = GTJ.GTJ_ITEM AND SCK.CK_PRODUTO = GTJ.GTJ_PRODUT"
cSql += " JOIN " + retSqlName("GA7") + " GA7"
cSql += " ON GTJ.GTJ_PRODUT = GA7.GA7_CODPRO AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" +  xFilial("GA7") + "'"
cSql += " WHERE GT9.D_E_L_E_T_ <> '*' AND GT9_FILIAL = '" + xFilial("GT9") + "'"
cSql += IIf(!Empty(cCondSql), " AND " + cCondSql + "", "")

If HS_EXISDIC({{"C", "GT9_REGGER"}},.F.) .AND. !Empty(cRegGer)	 	
	 cSql += " AND ( GT9.GT9_REGGER = '" + cRegGer + "')" 
Else
	cSql += " AND GT9_CLIENT = '" + cCodCli + "'"	 
EndIf

if lProcPai
	cSql += " ORDER BY GT9.GT9_NUMFAT, GA7.GA7_CODESP,  GTJ.GTJ_PROPAI, GTJ.GTJ_PRIORI, GTJ.GTJ_ITEM   "	
else
	cSql += " ORDER BY GT9.GT9_NUMFAT, GTJ.GTJ_PRIORI "
endif

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRYORC"

cEspAtu	:= Space(Len(QRYORC->GA7_CODESP)) 	
DbSelectArea("QRYORC")
While !QRYORC->(Eof())
	lCriou := .T.
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + PadR(QRYORC->GTJ_PRODUT, TamSx3("B1_COD")[1]))
	
	If SB1->B1_TIPO == cTpPrSb1
		DbSelectArea("GA7")
		DbSetOrder(1)
		If !DbSeek(xFilial("GA7") + PADR(QRYORC->GTJ_PRODUT, TamSx3("GA7_CODPRO")[1]))
			QRYORC->(DbSkip())
			Loop
		EndIf
	EndIf
	
	DbSelectArea("GFR")
	DbSetOrder(1)
	DbSeek(xFilial("GFR") + GA7->GA7_CODESP)
	
	If QRYORC->GT9_NUMFAT <> cOrcAtu
		If !Empty(cOrcAtu)
			DBENDTREE oTreeOrc // Finaliza orçamento
			lFat := .F.
			
			if lEsp
				DBENDTREE oTreeOrc // Finaliza especialidade
				lEsp := .F.
			endif
			if lTrat
				DBENDTREE oTreeOrc // Finaliza especialidade
				lTrat := .F.
			endif
			lFecha		:= .T.
		EndIf
		DBADDTREE oTreeOrc PROMPT PADR(STR0029 + QRYORC->GT9_NUMFAT + " - " + STR0028 + ": " + DTOC(STOD(QRYORC->GT9_DTEMIS)), 150) RESOURCE aLegGT9[Val(QRYORC->GT9_STATUS)+1,2] CARGO STR0030 + PadR(QRYORC->GT9_NUMFAT, 150) //"Orçamento: " ### "Data" ### "Orc: "
		
		lFat := .T.
		lEsp := .F.
		lTrat:= .F.
		nCurNodeId++
	EndIf
	If Alltrim(QRYORC->GA7_CODESP) <> cEspAtu
		If !Empty(cEspAtu) .AND. lEsp
			DBENDTREE oTreeOrc // Finaliza especialidade
			lEsp := .F.
			if lTrat
				DBENDTREE oTreeOrc
				lTrat := .F.
			endif
		EndIf
		DBADDTREE oTreeOrc PROMPT PADR(Alltrim(GFR->GFR_DSESPE),150) RESOURCE "DEPENDENTES" CARGO PadR(Alltrim(GFR->GFR_DSESPE), 150)
		lEsp := .T.
		nCurNodeId++
	elseif lFat .and. !lEsp //Se mudou de orcamento mas a especialidade eh a mesma que a anterior 
		DBADDTREE oTreeOrc PROMPT PADR(Alltrim(GFR->GFR_DSESPE),150) RESOURCE "DEPENDENTES" CARGO PadR(Alltrim(GFR->GFR_DSESPE), 150)
		lEsp := .T.
		nCurNodeId++		
	EndIf
	if !empty(Alltrim(QRYORC->GTJ_PROPAI))  .and. Alltrim(QRYORC->GTJ_PROPAI) <> cProcPai // Nome do tratamento
		if lTrat
			DBENDTREE oTreeOrc // Finaliza tratamento
			lTrat := .F.
		endif
		cDescPai := HS_IniPadr("SB1", 1, PadR(QRYORC->GTJ_PROPAI, TamSx3("B1_COD")[1]), "B1_DESC",, .F.)
 		DBADDTREE oTreeOrc PROMPT PADR(Alltrim(cDescPai),150) RESOURCE "DEPENDENTES" CARGO PADR(Alltrim(cDescPai),150)
 		lTrat := .T.
		nCurNodeId++ 		
	EndIf
	
	Inclui := .F.
	cDentFace := IIf(lExDenReg, IIf(!Empty(QRYORC->GTJ_DENREG), " | " + Alltrim(QRYORC->GTJ_DENREG) + " " + Alltrim(HS_INIPADR('B04',1,QRYORC->GTJ_DENREG,'B04_DESCRI')),""), "")
	cDentFace += IIf(lExDenReg, IIf(!Empty(QRYORC->GTJ_DENREG), " - " + Alltrim(QRYORC->GTJ_FADENT) + " " + Alltrim(HS_INIPADR('B09',1,QRYORC->GTJ_FADENT,'B09_FACDES')),""), "")
	Inclui := .T.

	//DBADDITEM oTreeOrc PROMPT PADR(Alltrim(QRYORC->GTJ_PRIORI) + " - " + Alltrim(QRYORC->GTJ_PRODUT) + " - " + Alltrim(IIf(SB1->B1_TIPO == cTpPrSb1, GA7->GA7_DESC, SB1->B1_DESC)) + cDentFace +  IIf(!Empty(QRYORC->GTJ_DTEXEC), " - " + STR0031 + DTOC(STOD(QRYORC->GTJ_DTEXEC)),""),150) RESOURCE IIF(QRYORC->GTJ_STATUS == '0',"BR_VERMELHO",IIf(QRYORC->GTJ_STATUS == '3',"BR_LARANJA",IIf(QRYORC->GTJ_STATUS == '1',"BR_VERDE",iIf(QRYORC->GTJ_STATUS == '4',"BR_AZUL","BR_PRETO")))) CARGO PadR(IIf(SB1->B1_TIPO == cTpPrSb1, "PROC", "MATM") + " ["  + QRYORC->GTJ_PRIORI + "][" + QRYORC->GTJ_PRODUT + "][" + QRYORC->GT9_NUMFAT + "][" + QRYORC->GTJ_ITEM + "]", 150) //"Atendido em: "
	DBADDITEM oTreeOrc PROMPT cPromIte:= PADR(Alltrim(QRYORC->GTJ_PRIORI) + " - " + Alltrim(QRYORC->GTJ_PRODUT) + " - " + Alltrim(IIf(SB1->B1_TIPO == cTpPrSb1, GA7->GA7_DESC, SB1->B1_DESC)) + cDentFace +  IIf(!Empty(QRYORC->GTJ_DTEXEC), " - " + STR0031 + DTOC(STOD(QRYORC->GTJ_DTEXEC)),""),150) RESOURCE cResoIte :=IIF(QRYORC->GTJ_STATUS == '0',"BR_VERMELHO",IIf(QRYORC->GTJ_STATUS == '3',"BR_LARANJA",IIf(QRYORC->GTJ_STATUS == '1',"BR_VERDE",iIf(QRYORC->GTJ_STATUS == '4',"BR_AZUL","BR_PRETO")))) CARGO cCargIte:=PadR(IIf(SB1->B1_TIPO == cTpPrSb1, "PROC", "MATM") + " ["  + QRYORC->GTJ_PRIORI + "][" + QRYORC->GTJ_PRODUT + "][" + QRYORC->GT9_NUMFAT + "][" + QRYORC->GTJ_ITEM + "]", 150) //"Atendido em: "
	nCurNodeId++
	aAdd(aRetNode, {StrZero(nCurNodeId, Len(oTreeOrc:CurrentNodeId)), QRYORC->GT9_NUMFAT, GFR->GFR_CDESPE, QRYORC->GTJ_PRIORI, QRYORC->GTJ_PRODUT, QRYORC->GTJ_STATUS, IIf(SB1->B1_TIPO == cTpPrSb1, GA7->GA7_DESC, SB1->B1_DESC), QRYORC->GTJ_ITEM, QRYORC->GTJ_GERSOL, QRYORC->CK_QTDVEN, QRYORC->GT9_VIGINI, QRYORC->GT9_VIGFIN, QRYORC->GT9_STATUS })
	
 	cOrcAtu := QRYORC->GT9_NUMFAT
	cEspAtu := Alltrim(QRYORC->GA7_CODESP) 	
 	cProcPai:= Alltrim(QRYORC->GTJ_PROPAI)
 	cSessao:= Alltrim(QRYORC->GTJ_SESSAO)
 	lFecha	 := .F.
	QRYORC->(DbSkip())
End   

If lCriou
	DBENDTREE oTreeOrc
EndIf
oTreeOrc:bChange   := {|| FS_STATREE(oTreeOrc:GetCargo(), oDlgTree)}
If lDbClick
	//oTreeOrc:BLDblClick := {|| FS_EXBINFO(oTreeOrc:GetCargo())}
	//oTreeOrc:BLDblClick := {|| FS_vItemFat(@oTreeOrc),FS_EXBINFO(oTreeOrc:GetCargo(), lItem)}
	oTreeOrc:BLDblClick := {|| FS_vItemFat(@oTreeOrc,substr(oTreeOrc:GetCargo(),47,TamSx3("GTJ_NUMORC")[1]),substr(oTreeOrc:GetCargo(),55,TamSx3("GTJ_ITEM")[1]),substr(oTreeOrc:GetCargo(),15,TamSx3("B1_COD")[1])),FS_EXBINFO(oTreeOrc:GetCargo(), lItem)}
EndIf

DbSelectArea("QRYORC")
DbCloseArea()

//================================================================¿
//³ Legendas do Orçamento										 ³
//================================================================Ù
@ aPInfo[3]-20, 005 BitMap oAma RESOURCE "BR_AMARELO" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-20, 015 Say oSay PROMPT STR0020 Of  oDlgTree PIXEL //"Pendente"
oSay:Cargo := "AMA"

@ aPInfo[3]-20, 055 BitMap oBlue RESOURCE "BR_AZUL" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-20, 065 Say oSay PROMPT STR0015 Of  oDlgTree PIXEL //"Aprovado"
oSay:Cargo := "BLUE"

@ aPInfo[3]-20, 105 BitMap oViol RESOURCE "BR_VIOLETA" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-20, 115 Say oSay PROMPT STR0018 Of  oDlgTree PIXEL // "Em tratamento"
oSay:Cargo := "VIOL"

@ aPInfo[3]-20, 155 BitMap oWhit RESOURCE "BR_BRANCO" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-20, 165 Say oSay PROMPT STR0019  Of  oDlgTree PIXEL // "Finalizado"
oSay:Cargo := "WHIT"


@ aPInfo[3]-10, 005 BitMap oBlack RESOURCE "BR_PRETO" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-10, 015 Say oSay PROMPT STR0017 Of  oDlgTree PIXEL // "Cancelado"
oSay:Cargo := "BLACK"

@ aPInfo[3]-10, 055 BitMap oRed RESOURCE  "BR_VERMELHO" SIZE 8, 8 NOBORDER Of oDlgTree PIXEL
@ aPInfo[3]-10, 065 Say oSay PROMPT STR0014 Of  oDlgTree PIXEL // "Pend. Financ."
oSay:Cargo := "RED"

@ aPInfo[3]-10, 105 BitMap oGreen RESOURCE "BR_VERDE" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-10, 115 Say oSay PROMPT STR0016 Of  oDlgTree PIXEL // "Liberado"
oSay:Cargo := "GREEN"

@ aPInfo[3]-10, 155 BitMap oLaranja RESOURCE "BR_LARANJA" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-10, 165 Say oSay PROMPT "              " Of oDlgTree PIXEL // 
oSay:Cargo := "LARA"
oLaranja:lVisible := .F.

//linhas novas - status "Em Atendimento"
@ aPInfo[3]-10, 205 BitMap oBlue2 RESOURCE "BR_AZUL" SIZE 8, 8 NOBORDER Of  oDlgTree PIXEL
@ aPInfo[3]-10, 215 Say oSay PROMPT "              " Of oDlgTree PIXEL // 
oSay:Cargo := "AZUL2"
oBlue2:lVisible := .F.
DBSelectArea(cAlias)
RestArea(aArea)
Return({oTreeOrc, aRetNode})


//static function FS_vItemFat(OTreeGTJ)
static function FS_vItemFat(OTreeGTJ, cGtjNumOrc, cGtjNumIte,cGtjB1Cod)
Local aArea   		:= getArea()
Local cCodPro, cDesProc, cOrc, cPri, cMotivo, cUser, cDatInc, cOrigem,cHorInc := ""
local lCancel 		:= .F.
Local aCodUsr 		:= {}
Local aCoduserAut 	:= {}

if empty(cGtjNumOrc)
	return
endif

DbSelectArea("GTJ")
DbSetOrder(1)
//If DbSeek(xFilial("GTJ") + substr(OTreeGTJ:GetCargo(),47,TamSx3("GTJ_NUMORC")[1]) + substr(OTreeGTJ:GetCargo(),55,TamSx3("GTJ_ITEM")[1]) )
If DbSeek(xFilial("GTJ") + cGtjNumOrc + cGtjNumIte )
	if GTJ->GTJ_STATUS == "2"
		lCancel := .T.	
	endif
	lItem := .T.     
	cCodPro := GTJ->GTJ_PRODUT
	cDesProc:= HS_IniPadr("SB1", 1, GTJ->GTJ_PRODUT, "B1_DESC",, .F.)
	cOrc    := GTJ->GTJ_NUMORC
	cPri    := GTJ->GTJ_PRIORI
	//cMotivo := GTJ->GTJ_MTVAGE
	cMotivo := HS_IniPadr("GT7", 1, GTJ->GTJ_MTVAGE, "GT7_DESMTV",, .F.)
	cUser   := GTJ->GTJ_USRFOR
	cDatInc := dToS(GTJ->GTJ_DATFOR)
	cHorInc := GTJ->GTJ_HORFOR
	//Origem
	DbSelectArea("GT7")
	DbSetOrder(1)
	if DbSeek(xFilial("GT7") + GTJ->GTJ_MTVAGE)
		cOrigem := hs_gDesCbx("GT7_ORIMTV",GT7->GT7_ORIMTV)
	endif
	
	If Empty(cMotivo)
		//Nao permite manipulacao dos procedimentos se o usuario nao for profissional da saude cadastrado
		aCodUsr := PswRet(1)
		If !(FS_VldProf(aCodUsr[1,2])[1])
			Return()
		else
			fs_opPlnTrat(cGtjB1Cod, cGtjNumOrc, cGtjNumIte, @OTreeGTJ)
		EndIf
		Return()
	EndIf	
	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )
	
	
	DEFINE MSDIALOG oDlgGtj TITLE STR0032 + allTrim(cCodPro) + " - " + cDesProc From 120, 000 To 230 , 750 Of oMainWnd Pixel //"Procedimento: "
	
	@ 010, 010 Say STR0033  Of oDlgGtj Pixel COLOR CLR_BLUE //"Num Orc"
	@ 020, 010 MsGet oOrc VAR cOrc Size 40, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oOrc:Disable()
	
	@ 010, 050 Say STR0034 Of oDlgGtj Pixel COLOR CLR_BLUE //"Prioridade"
	@ 020, 050 MsGet oPri VAR cPri Size 40, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oPri:Disable()
	
	@ 010, 090 Say STR0035  Of oDlgGtj Pixel COLOR CLR_BLUE //"Origem"
	@ 020, 090 MsGet oOri VAR cOrigem Size 40, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oOri:Disable()

	
	@ 010, 130 Say STR0036  Of oDlgGtj Pixel COLOR CLR_BLUE //"Motivo"
	@ 020, 130 MsGet oMot VAR cMotivo Size 80, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oMot:Disable()
	
	@ 010, 210 Say STR0037  Of oDlgGtj Pixel COLOR CLR_BLUE //"Usuario"
	@ 020, 210 MsGet oUsr VAR cUser Size 80, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oUsr:Disable()
	
	@ 010, 290 Say STR0038  Of oDlgGtj Pixel COLOR CLR_BLUE //"Dat. Inclusão"
	@ 020, 290 MsGet oDatInc VAR cDatInc Size 40, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oDatInc:Disable()
	
	@ 010, 330 Say STR0039 Of oDlgGtj Pixel COLOR CLR_BLUE //"Hora Inclusão"
	@ 020, 330 MsGet oHorInc VAR cHorInc Size 40, 009 OF oDlgGtj Pixel COLOR CLR_BLACK
	oHorInc:Disable()
	
	oBtnGtj := tButton():New(@40, 165, "OK", oDlgGtj, {|| oDlgGtj:End()}, 050, 012,,,, .T.)    //"Confirma
	
	ACTIVATE MSDIALOG oDlgGtj CENTERED
	if !lCancel
		fs_opPlnTrat(cGtjB1Cod, cGtjNumOrc, cGtjNumIte, @OTreeGTJ)
	endif
endif

RestArea(aArea)
return


Static function FS_GERACNT(cCndPag, cNatureza, cCodCli, aCIte, cNumOrc, nItem)
Local aArea := getArea()
//Local cHspSeri  := GetMV("MV_HSPSERI")
Local cPrefCrh  := GetMV("MV_PREFCRH")  
Local nValTot	:= 0
Local nFor		:= 0    
Local cTitGer	:= ""
Local cHist		:= Space(50)
Local cCodFor	:= ""

If oGetOrc:aCols[oGetOrc:nAt, nGt9Cobran] == "0" //Convenio
	MsgStop(STR0094, STR0041)//"O tipo de cobrança para este orçamento é convênio, não é possivel gerar Conta a Pagar!" ### "Atenção"	
	Return("")
EndIf

For nFor := 1 to Len(aCIte)
	If aCIte[nFor,nPosMark] == "LBTIK"
		nValTot += iiF(aCIte[nFor,nCKVALOR] == 0 .AND. Empty(aCIte[nFor,nCKItem]), aCIte[nFor,nB1Prv1], aCIte[nFor,nCKVALOR])
	EndIf
Next nFor

If nValTot == 0   
	MsgStop(STR0040, STR0041)//"Informe ao menos um item com valor!" ### "Atenção"
	return("")
EndIf

if empty(cCndPag)
	MsgStop(STR0090 + " (" + STR0042 + ").", STR0041) //"Informe o campo 'Cond. Pag' (Condição de Pagamento)." ### "Atenção"
	Return()
else
	DbSelectArea("SE4")
	DbSetOrder(1)                                                                  
	If !DbSeek(xFilial("SE4") + PadR(cCndPag, Len(SE4->E4_CODIGO)))
		MsgStop(STR0042 + cCndPag + STR0043, STR0041) //"Condição de Pagamento " ### " não encontrada" ### "Atenção"
		Return()
	EndIf  
endif

if empty(cNatureza)
	MsgStop(STR0091, STR0041) //"Informe o campo 'Natureza'." ### "Atenção"
	Return()
else
	DbSelectArea("SED")
	DbSetOrder(1)
	If !DbSeek(xFilial("SED") + PadR(cNatureza, Len(SED->ED_CODIGO)))
		MsgStop(STR0024 + " " + cNatureza + STR0043, STR0041) //"Natureza" ### " não encontrada" ### "Atenção"
		Return()
	EndIf 
endif

DbSelectArea("GBH")
DbSetOrder(7)
If !DbSeek(xFilial("GBH") + cCodCli)
	MsgStop(STR0044, STR0041) //"Paciente não encontrado, no vinculo com o cliente!" ### "Atenção"
	Return()
ElseIf Empty(GBH->GBH_CODFOR)
	cCodFor := HS_GFornPac(GBH->GBH_CODPAC, GBH->GBH_CODCLI)  
	If !Empty(cCodFor)
		Reclock("GBH",.F.)
			GBH->GBH_CODFOR := cCodFor 
		MsUnlock()
	EndIF
EndIf

FS_Hist( @cHist )                

cTitGer := HS_GerTitPg(cHist, cPrefCrh, cCndPag, GBH->GBH_CODFOR, GBH->GBH_LOJA, nValTot, cNatureza,cNumOrc, nItem)

If !Empty(cTitGer)
	For nFor := 1 to Len(aCIte)
		If aCIte[nFor,nPosMark] == "LBTIK"
			DbSelectArea("GTJ")
			DbGoTop()
			DbSetOrder(1)
			If DbSeek(xFilial("GTJ") + cNumOrc + aCIte[nFor,nItem])
				oGetOrcIte:aCols[nFor,nGTJNumTit] := cTitGer
				If lCposGTJ
					oGetOrcIte:aCols[nFor,nGTJPrefix] := ""
					oGetOrcIte:aCols[nFor,nGTJTipo] := ""
					oGetOrcIte:aCols[nFor,nGTJParcel] := ""
					oGetOrcIte:aCols[nFor,nGTJLoja] := ""
					oGetOrcIte:aCols[nFor,nGTJFornec] := ""
				EndIf 
				oGetOrcIte:aCols[nFor,nPosMark] := "LBNO"          
				RecLock("GTJ", .F.)
					GTJ->GTJ_NUMTIT := cTitGer
				MsUnlock()
			EndIf
		EndIf
	Next nFor 
	oGetOrcIte:Refresh()
EndIf

RestArea(aArea)
Return   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_HISTIT ºAutor  ³Alessandro Freire   º Data ³  04/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre dialog para que seja possivel alterar o historico      º±±
±±º          ³do titulo                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Hist( cHistorico )
 Local oDlg,oSay1,oGetHist,oSBtn3

 DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0046) FROM  00, 00 TO 00, 00 OF oMainWnd  //"Digite o historico do título a ser gerado no financeiro"
 oDlg:nLeft 		:= 0
 oDlg:nTop 			:= 0
 oDlg:nWidth 		:= 388
 oDlg:nHeight 		:= 105

 @ 0,0 SAY oSay1 VAR STR0046 //"Digite o historico do título a ser gerado no financeiro"
 oSay1:nLeft 		:= 6
 oSay1:nTop 		:= 8
 oSay1:nWidth 		:= 261
 oSay1:nHeight 		:= 17
 oSay1:lTransparent := .T.

 @ 0,0 MSGET oGetHist VAR cHistorico
 oGetHist:nLeft 	:= 6
 oGetHist:nTop 		:= 28
 oGetHist:nWidth 	:= 370
 oGetHist:nHeight 	:= 21

 oSBtn3 := SBUTTON():Create(oDlg)
 oSBtn3:cName 		:= "oSBtn3"
 oSBtn3:cCaption 	:= "OK"
 oSBtn3:nLeft 		:= 324
 oSBtn3:nTop 		:= 53
 oSBtn3:nWidth 		:= 52
 oSBtn3:nHeight 	:= 22
 oSBtn3:lShowHint 	:= .F.
 oSBtn3:lReadOnly 	:= .F.
 oSBtn3:Align 		:= 0
 oSBtn3:lVisibleControl := .T.
 oSBtn3:nType 		:= 1
 oSBtn3:bAction 	:= {|| oDlg:End() }

 ACTIVATE DIALOG oDlg CENTERED

Return(NIL)


Static Function FS_DbClik(nPosStaReg)
/*
If oGetOrcIte:aCols[oGetOrcIte:nAt, oGetOrcIte:oBrowse:ColPos] $ "LBTIK/LBNO"
	If(oGetOrcIte:aCols[oGetOrcIte:nAt, oGetOrcIte:oBrowse:ColPos] == "LBTIK")
		oGetOrcIte:aCols[oGetOrcIte:nAt, oGetOrcIte:oBrowse:ColPos] := "LBNO"
*/
If oGetOrcIte:aCols[oGetOrcIte:nAt, nPosMark] $ "LBTIK/LBNO"
	If(oGetOrcIte:aCols[oGetOrcIte:nAt, nPosMark] == "LBTIK")
		oGetOrcIte:aCols[oGetOrcIte:nAt, nPosMark] := "LBNO"
	Else
		If oGetOrcIte:aCols[oGetOrcIte:nAt, nPosStaReg] == "BR_PRETO"
			If oGetOrc:aCols[oGetOrc:nAt, nGt9Cobran] == "0" //Convenio
				MsgStop(STR0094, STR0041)//"O tipo de cobrança para este orçamento é convênio, não é possivel gerar Conta a Pagar!" ### "Atenção"	
				Return("")
			EndIf
			If !Empty(oGetOrcIte:aCols[oGetOrcIte:nAt, nGTJNumTit])
				MsgStop(STR0047, STR0041) //"Titulo já gerado para este item!" ### "Atenção"
			ElseIf Empty(oGetOrc:aCols[oGetOrc:nAt, nGt9NumLoj])
				MsgStop("Item selecionado não foi pago, não é possivel seleciona-lo!", STR0041) //"Titulo já gerado para este item!" ### "Atenção"			
			ElseIf !Empty(oGetOrc:aCols[oGetOrc:nAt, nGt9NumLoj]) .AND. FS_VERSTLOJ(oGetOrc:aCols[oGetOrc:nAt, nGt9NumLoj]) <> "BR_VERMELHO"
				MsgStop("Item selecionado não foi pago, não é possivel seleciona-lo!", STR0041) //"Titulo já gerado para este item!" ### "Atenção"						
			Else
				//oGetOrcIte:aCols[oGetOrcIte:nAt, oGetOrcIte:oBrowse:ColPos] := "LBTIK"			
				oGetOrcIte:aCols[oGetOrcIte:nAt, nPosMark] := "LBTIK"
			EndIf
		Else
			MsgStop(STR0048, STR0041)  //"Somente itens cancelados podem ser selecionados!" ### "Atenção"
		EndIf
	EndIf
	oGetOrcIte:Refresh()
EndIf
Return(Nil)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HS_M61AVIG ³ Autor ³ Saude     			³ Data ³ 08/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GRAVA VIGENCIA ATUALIZADA DO TRATAMENTO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M61AVIG(cNumOrc)
Local aArea := GetArea() 
Local cCpoAlt := Alltrim(SubStr(ReadVar(),4,10))

If !Hs_ExisDic({{"C","GT9_VIGINI"}},.F.)	
	Return(.T.)
EndIf

Inclui := .T.

DbSelectArea("GT9")
DbSetOrder(1)
If DbSeek(xFilial("GT9") + cNumOrc)
	If &("GT9->" + cCpoAlt) <> &("M->" + cCpoAlt) //.OR. GT9->GT9_VIGFIN <> M->GT9_VIGFIN
		RecLock("GT9", .F.)
			&("GT9->" + cCpoAlt) := &("M->" + cCpoAlt)
		MsUnlock()
	EndIf
EndIf 

Inclui := .F.

RestArea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_EXBINFO ³ Autor ³ Saude     			³ Data ³ 29/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe informações no dupo clique da tree                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_EXBINFO(cCargo, lItem)
Local aArea 	:= GetArea() 
Local cNumOrc   := ""

If "Orc:" $ cCargo .and. !lItem
	cNumOrc := Alltrim(Substr(Alltrim(cCargo),5,Len(Alltrim(cCargo))) )
	MATA415({},{},3)
	l415Auto := .F. 
	DbSelectArea("SCJ")
	DbSetOrder(1)
	If DbSeek(xFilial("SCJ") + cNumOrc)
		//A415Altera("SCJ",SCJ->(Recno()),2)
		A415Visual("SCJ",SCJ->(Recno()),1)
	EndIf
EndIf

RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAHMLEG ³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no Agendamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAHM29LEG()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSM61AGELEG()
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE"   ,OemToAnsi(STR0049)}) //"Livre"  
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0050)}) //"Agenda Ocupada"
Aadd(aLegenda,{"BR_PRETO"   ,OemToAnsi(STR0051)}) //"Encaixe Ocupado"
Aadd(aLegenda,{"BR_AMARELO" ,OemToAnsi(STR0052)}) //"Bloqueado"
Aadd(aLegenda,{"BR_PINK"    ,OemToAnsi(STR0053)}) //"Atendido"
Aadd(aLegenda,{"BR_AZUL"    ,OemToAnsi(STR0054 + "/" + STR0052)}) //"Ocupado/Bloqueado"
Aadd(aLegenda,{"BR_LARANJA" ,OemToAnsi(STR0055)}) //"Confirmado"
Aadd(aLegenda,{"BR_VIOLETA" ,OemToAnsi(STR0056)}) //"Não compareceu"
Aadd(aLegenda,{"BR_CINZA"   ,OemToAnsi(STR0057)}) //"Agendamento Cancelado"

BrwLegenda(cCadastro,STR0058,aLegenda)  //"Agendamento"

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_opPlnTrat     ³Autor³Saude               ³Data³11/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exibe a tela de opcoes para manipulacao de itens do plano de³±±
±±³          ³tratamento                                                  ³±±
±±³          ³VALIDO SOMENTE PARA AGENDAMENTO ATRAVES DA SOLICITACAO APAC ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_opPlnTrat()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
        
static function fs_opPlnTrat(cProced, cOrcam, cItem, OTreeGTJ)
Local aArea       := getArea()
Local oBtnOk
Local oBtnCanc
Local oRadioPlTr
Local nRadioPlTr  := 1
Local aOpcPlnTrt  := {}
Local lOrcFin     := .F.
local aCrmM54     := {}
local cCrmLogM54  := ""
local lHspahm54   := .F. 
Static oDlgFicTrat                   
      
//Verifica se o usuario acessou pelo agenda e se tem acesso como profissional
if funName() == "HSPAHM54"
	lHspahm54 := .T. 
	aCrmM54   := FS_VldProf(PswRet(1)[1,2])  
	if !(aCrmM54[1])
		return nil
	else
		cCrmLogM54 := aCrmM54[2] 			
	endif
endif

dbSelectArea("GT9")
dbSetOrder(1)
//Localiza o orcamento
if dbSeek(xFilial("GT9") + cOrcam  )
	//Verifica se o orcamento foi finalizado
	if GT9->GT9_STATUS == "6"
		lOrcFin := .T.
		dbSelectArea("GBJ")
		dbSetOrder(1)
		If dbSeek(xFilial("GBJ") + iIf( lHspahm54 , cCrmLogM54, cCrmLog) ) .AND. HS_ExisDic({{"C", "GBJ_VISPLT"}},.F.) //CCrmLog obtido no M57 ao abrir o prontuario eletronico
			//Se o profissional NAO pode manipular orcamento finalizado, nao exibe tela de opcoes
			if !(GBJ->GBJ_VISPLT == "1")
				restArea(aArea)
				return
			endif
		else
			restArea(aArea)
			return
		endif
	//se nao esta liberado/em tratamento/finalizado nao permite manipulacao
	elseif GT9->GT9_STATUS $ "0124" //0=Orc. Pendente;1=Pend. Financ.;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
		HS_MSGINF(STR0080 + " (" +;
		hs_gDesCbx("GT9_STATUS", GT9->GT9_STATUS) + ") " + STR0081,STR0041, STR0067	)//"Não é possível manipular o procedimento pois o status atual do orçamento (XXXXXX) não permite alteração!","Atenção", "Validação Atualização Plano de Tratamento"
		restArea(aArea)
		return nil
	endif  

	//Monta a tela para exibicao
	DEFINE MSDIALOG oDlgFicTrat TITLE STR0059 FROM 000, 000  TO 130, 200 COLORS 0, 16777215 PIXEL //"Selecione a opção : "
	//Se o orcamento foi finalizado
	if lOrcFin
		@ 004, 025 RADIO oRadioPlTr VAR nRadioPlTr ITEMS STR0060 SIZE 050, 031 OF oDlgFicTrat COLOR 0, 16777215 PIXEL //"Repetir"	
	else
		@ 004, 025 RADIO oRadioPlTr VAR nRadioPlTr ITEMS STR0060 , STR0061 , STR0062 SIZE 050, 031 OF oDlgFicTrat COLOR 0, 16777215 PIXEL //"Repetir" ### "Finalizar" ### "Excluir" ### "Grava Histórico"
	endif
	
    @ 047, 005 BUTTON oBtnOk   PROMPT STR0063 SIZE 037, 012 OF oDlgFicTrat ACTION {|| oDlgFicTrat:End(),fs_opcPlnTrat(nRadioPlTr,cProced, cOrcam, cItem, @OTreeGTJ)} PIXEL //"Confirmar"
    @ 047, 058 BUTTON oBtnCanc PROMPT STR0064 SIZE 037, 012 OF oDlgFicTrat ACTION {|| oDlgFicTrat:End()} PIXEL //"Cancelar"

	ACTIVATE MSDIALOG oDlgFicTrat CENTERED
	
endif

restArea(aArea)
return(NIL)		

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_opcPlnTrat    ³Autor³Saude               ³Data³27/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica a opcao selecionada (nOpcao) na funcao fs_opPlnTrat³±±
±±³          ³e executa as acoes correspondentes para o procedimento      ³±±
±±³          ³selecionado na Tree                                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_opcPlnTrat(nOpcao)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ nOpcao - Indica o a acao que deve ser executada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

static function fs_opcPlnTrat(nOpcao, cProc, cOrc, cItem, OTreeGTJ)
local aArea      := getArea()
local cNomCampo  := ""
local aCposGtj   := {}
local aCposVlr   := {}
local nQtdRep    := 0
local cNumItem   := ""
local nPriori    := 0
local nQtdItem   := 0
local nI         := 0
local nJ         := 0
local nL         := 0
local cNumOrc    := cOrc
local cProced    := cProc
local cCodItem   := cItem
local lExisProPai:= .F.
local cCodProPai := ""
local cMsg       := ""
local aTrat      := {}
local nItensRep  := 0
local nMvQtdRep  := 0
local lTratFin   := .F.
local cPrompt    := ""
local cPriori    := ""
local cCargo     := ""
local cNewCargo  := ""
local aDelTree   := {}        
local cSb1Tipo   := ""
Local cTpPrSb1   := SuperGetMV("MV_TPPRSB1",, "")
Local cResource  := ""
Local nResource  := 0
//Deve ser copia das demais aLegGT9
Local aLegGT9 := 	{{"GT9_STATUS == '0'", "BR_AMARELO" }, ;
					 {"GT9_STATUS == '1'", "BR_VERMELHO"}, ;
					 {"GT9_STATUS == '2'", "BR_AZUL"    }, ;
					 {"GT9_STATUS == '3'", "BR_VERDE"   }, ;
					 {"GT9_STATUS == '4'", "BR_PRETO"   }, ;
					 {"GT9_STATUS == '5'", "BR_VIOLETA" }, ;
					 {"GT9_STATUS == '6'", "BR_BRANCO"  }} 
nMvQtdRep    := SuperGetMV("MV_QTDREP", NIL, 0)

if nOpcao == 1 //Repetir Procedimento
	if Hs_ExisDic({{"C", "GT9_QTDREP"}}, .F.)
		DbSelectArea("GT9")
		DbSetOrder(1)
		If DbSeek(xFilial("GT9") + cNumOrc )
			nQtdRep := GT9->GT9_QTDREP
			//Verifica a quantidade de repticoes ja realizadas para o orcamento selecionado
			if nQtdRep >= nMvQtdRep
            	HS_MSGINF(STR0065 + " (" + GT9->GT9_NUMFAT + ") " + STR0066 + " (" + cValToChar(nMvQtdRep) + ") !",STR0041, STR0067)//"Não foi possível repetir o procedimento selecionado pois o orçamento correspondente" ### "já atingiu a quantidade máxima de repetições por plano de tratamento / orçamento" ### "Atenção", "Validação Atualização Plano de Tratamento"
			else			
				DbSelectArea("GTJ")
				DbSetOrder(1)
				If DbSeek(xFilial("GTJ") + cNumOrc + cCodItem )
					//Verifica o profissional executante
					if Hs_ExisDic({{"C","GTJ_CRMEXE"}},.F.)
						cCrmExec := GTJ->GTJ_CRMEXE
					endif
				
				    //Verifica se o o procedimento selecionado foi realizado
					if GTJ->GTJ_STATUS == "1"
                        //Verifica se o procedimento selecionado faz parte de um tratamento e se deseja repetir
                        //somente o item selecionado ou todos os itens ja realizados do tratamento
						if !empty(GTJ->GTJ_PROPAI)
							if msgYesNo(STR0068," ") //"O procedimento selecionado faz parte de um tratamento, deseja repetir os demais procedimentos já realizados desse tratamento?"
								lExisProPai := .T.
								cCodProPai  := GTJ->GTJ_PROPAI 
							endif
						endif 
						
						//Incrementa a quantidade de repeticoes na GT9
						RecLock("GT9", .F.)
						GT9->GT9_QTDREP := ( nQtdRep + 1 )
						MsUnlock()
						
					 	//Varre a tabela até o ultimo item do orçamento para  obter numero do novo item (cNumItem) e prioridade (nPriori)
					 	DbSelectArea("GTJ")
						GTJ->(dbGoTop())
						DbSetOrder(1)
						DbSeek(xFilial("GTJ") + cNumOrc)
						while GTJ->GTJ_FILIAL + GTJ->GTJ_NUMORC == xFilial("GTJ") + cNumOrc
							cNumItem := GTJ->GTJ_ITEM
							if val(GTJ->GTJ_PRIORI) > nPriori
								nPriori := val(GTJ->GTJ_PRIORI)
							endif
							GTJ->(dbSkip())	
						end
						cNumItem := strZero((val(cNumItem)+1),TamSx3("GTJ_ITEM")[1])
						cPriori  := strZero( nPriori + 10 ,TamSx3("GTJ_PRIORI")[1])
						
					 	//Verifica todos os campos da tabela para repetir o item
						aCposGtj := hs_gCpoSx3("GTJ")
						
						if lExisProPai
							//Verifica quais itens do mesmo tratamento serao repetidos e os adiciona ao vetor aTrat
							DbSelectArea("GTJ")
							GTJ->(dbGoTop())
							DbSetOrder(1)
							DbSeek(xFilial("GTJ") + cNumOrc)
							while GTJ->GTJ_FILIAL + GTJ->GTJ_NUMORC  == xFilial("GTJ") + cNumOrc
							 	//Se faz parte do mesmo tratamento e ja foi realizado
								if GTJ->GTJ_PROPAI == cCodProPai .and. GTJ->GTJ_STATUS == "1" //Realizado
									//Adiciona o procedimento do tratamento que será repetido ao vetor
									aAdd(aTrat, {GTJ->GTJ_FILIAL, GTJ->GTJ_NUMORC, GTJ->GTJ_ITEM, GTJ->GTJ_PRIORI } )
								endif  
								GTJ->(dbSkip())	
							end
							
							//se o vetor dos procedimentos que serao repetidos nao estiver vazio
							if !empty(aTrat)
								aSort(aTrat,,,{|x,y| x[4]  < y[4]})
								nItensRep := len(aTrat)
								if nItensRep > 1
									cMsg += STR0069 + ": "	 + chr(10) + chr(13) + chr(10) + chr(13) //"Os procedimentos"
								else
									cMsg += STR0070 + " " //"O procedimento"
								endif
								for nI := 1 to nItensRep
									//Verifica se a prioridade é igual à anterior
									if nI > 1
										if aTrat[nI,4] > aTrat[nI-1,4]
											cPriori  := strZero( val(cPriori) + 10 ,TamSx3("GTJ_PRIORI")[1])
										endif
									endif
									DbSelectArea("GTJ")
									GTJ->(dbGoTop())
									DbSetOrder(1)
									DbSeek(aTrat[nI,1] + aTrat[nI,2] + aTrat[nI,3]) //Filial + Orcamento + Item
									
									//Preenche vetor com campos e valores para cada campo
									for nJ:= 1 to len(aCposGtj)
										aAdd(aCposVlr,{aCposGtj[nJ], &("GTJ->" + aCposGtj[nJ]) } ) 
								 	next nJ
								 	
							 	
								 	//Atualiza o status do item atual para "Proc Repetido"
									RecLock("GTJ", .F.)
									GTJ->GTJ_STATUS := "5" //aLegGTJ - "Proc Repetido" / HSPAHM57LEG()
									MsUnlock()   
									
									//Localizando item na tree que será substituido
									if OTreeGTJ:TreeSeek(PadR("PROC" + " ["  + GTJ->GTJ_PRIORI + "][" + GTJ->GTJ_PRODUT + "][" + GTJ->GTJ_NUMORC + "][" + GTJ->GTJ_ITEM + "]", 150)) .OR. ;
										OTreeGTJ:TreeSeek(PadR("MATM" + " ["  + GTJ->GTJ_PRIORI + "][" + GTJ->GTJ_PRODUT + "][" + GTJ->GTJ_NUMORC + "][" + GTJ->GTJ_ITEM + "]", 150)) 
									   
										//Obtendo prompt e cargo do item atual da arvore
										cPrompt := OTreeGTJ:getPrompt()
										cCargo  := OTreeGTJ:getCargo()
										
										//Incluindo item na arvore com cargo e prompt alterados 
										dbSelectArea("SB1")
										if DbSeek(xFilial("SB1") + cProc )//Posiciona no registro
											cSb1Tipo := SB1->B1_TIPO
										endif
										dbCloseArea()
										
										cNewCargo := PadR(IIf(cSb1Tipo == cTpPrSb1, "PROC", "MATM") + " ["  + cPriori + "][" + GTJ->GTJ_PRODUT + "][" + GTJ->GTJ_NUMORC + "][" + strZero((val(cNumItem)),TamSx3("GTJ_ITEM")[1]) + "]", len(cCargo))
										
										OTreeGTJ:AddItem(cPriori + substr(cPrompt,TamSx3("GTJ_PRIORI")[1]+1,len(cPrompt)), cNewCargo, "BR_VERMELHO", "BR_VERMELHO", , , 1 )
										//Incluindo cargo do item a ser excluido no array para posterior exclusao
										aAdd(aDelTree,{cCargo})

									endif
									
									//Inclui novo registro
								 	RecLock("GTJ", .T.)
								 	for nL:= 1 to len(aCposVlr)
								 		cNomCampo := allTrim(aCposVlr[nL,1])
								 		if cNomCampo == "GTJ_PRIORI"
											&("GTJ->" + cNomCampo) := cPriori
								 		elseif cNomCampo == "GTJ_ITEM"
											&("GTJ->" + cNomCampo) := strZero((val(cNumItem)),TamSx3("GTJ_ITEM")[1])
											cNumItem := strZero((val(cNumItem)+1),TamSx3("GTJ_ITEM")[1])
										elseif cNomCampo == "GTJ_STATUS"
											&("GTJ->" + cNomCampo) := "0" //Pendente
										elseif cNomCampo == "GTJ_CRMANT" .and. !empty(cCrmExec)
											&("GTJ->" + cNomCampo) := cCrmExec
										else
											&("GTJ->" + cNomCampo) := aCposVlr[nL,2]
											if cNomCampo == "GTJ_PRODUT"
												cGtjProdut := aCposVlr[nL,2]
											endif
											if cNomCampo == "GTJ_NUMORC"
												cGtjNumOrc := aCposVlr[nL,2]
											endif
										endif
								 	next nL 
								 	MsUnlock()
								 	
								 	//Se houver mais de um procedimento a ser repetido
									if nItensRep > 1
										cMsg += "'" + allTrim(cGtjProdut) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1') + cGtjProdut,'B1_DESC')) + ")" +  chr(10) + chr(13) + ;
									   			 STR0071 + "         : " + GTJ->GTJ_ITEM + chr(10) + chr(13) + ;
									   			 STR0072 + ": " + GTJ->GTJ_PRIORI  + chr(10) + chr(13) //"Item" ### "Prioridade"
									endif
								
									//Limpa o vetor de dados
									aCposVlr := {}
								next nI

								if nItensRep > 1
									cMsg += chr(10) + chr(13) + STR0073 //"foram repetidos."
								else
									cMsg += "'" + allTrim(cGtjProdut) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cGtjProdut,'B1_DESC')) + ") " + STR0074 + chr(10) + chr(13) + ;
										STR0071 + "         : " + GTJ->GTJ_ITEM + chr(10) + chr(13) + ;
										STR0072 + ": " + GTJ->GTJ_PRIORI +  chr(10) + chr(13) + chr(10) + chr(13)//"foi repetido!" ### "Item" ### "Prioridade"
								endif
							endif                       

						else
							DbSelectArea("GTJ")	
							GTJ->(dbGoTop())
							DbSetOrder(1)
							DbSeek(xFilial("GTJ") + cNumOrc + cCodItem )//Posiciona no registro
					
							//Preenche vetor com campos e valores para cada campo
							for nI:= 1 to len(aCposGtj)
								aAdd(aCposVlr,{aCposGtj[nI], &("GTJ->" + aCposGtj[nI]) } ) 
						 	next nI                                                     
						 	
						 	//Ajusta o status do procedimento para "5" (Repetido) na GTJ
						 	RecLock("GTJ", .F.)
							GTJ->GTJ_STATUS := "5" //aLegGTJ - "Proc Repetido" / HSPAHM57LEG()
							MsUnlock()
							                   
							cPriori  := strZero( nPriori + 10 ,TamSx3("GTJ_PRIORI")[1])
							
							
							//Localizando item na tree que será substituido
							if OTreeGTJ:TreeSeek(PadR("PROC" + " ["  + GTJ->GTJ_PRIORI + "][" + GTJ->GTJ_PRODUT + "][" + GTJ->GTJ_NUMORC + "][" + GTJ->GTJ_ITEM + "]", 150)) .OR. ;
								OTreeGTJ:TreeSeek(PadR("MATM" + " ["  + GTJ->GTJ_PRIORI + "][" + GTJ->GTJ_PRODUT + "][" + GTJ->GTJ_NUMORC + "][" + GTJ->GTJ_ITEM + "]", 150)) 
							   
								//Obtendo prompt e cargo do item atual da arvore
								cPrompt := OTreeGTJ:getPrompt()
								cCargo  := OTreeGTJ:getCargo()
								
								//Incluindo item na arvore com cargo e prompt alterados 
								dbSelectArea("SB1")
								if DbSeek(xFilial("SB1") + cProc )//Posiciona no registro
									cSb1Tipo := SB1->B1_TIPO
								endif
								dbCloseArea()
								
								cNewCargo := PadR(IIf(cSb1Tipo == cTpPrSb1, "PROC", "MATM") + " ["  + cPriori + "][" + GTJ->GTJ_PRODUT + "][" + GTJ->GTJ_NUMORC + "][" + strZero((val(cNumItem)),TamSx3("GTJ_ITEM")[1]) + "]", len(cCargo))
								
								OTreeGTJ:AddItem(cPriori + substr(cPrompt,TamSx3("GTJ_PRIORI")[1]+1,len(cPrompt)), cNewCargo, "BR_VERMELHO", "BR_VERMELHO", , , 1 )
								//Incluindo cargo do item a ser excluido no array para posterior exclusao
								aAdd(aDelTree,{cCargo})

							endif
							
							//Inclui novo registro
						 	RecLock("GTJ", .T.)
						 	for nI:= 1 to len(aCposVlr)
						 		cNomCampo := allTrim(aCposVlr[nI,1])
						 		if cNomCampo == "GTJ_PRIORI"
									&("GTJ->" + cNomCampo) := cPriori
						 		elseif cNomCampo == "GTJ_ITEM"
									&("GTJ->" + cNomCampo) := strZero((val(cNumItem)),TamSx3("GTJ_ITEM")[1])
								elseif cNomCampo == "GTJ_STATUS"
									&("GTJ->" + cNomCampo) := "0" //Pendente
								else
									&("GTJ->" + cNomCampo) := aCposVlr[nI,2]
								endif
						 	next nI
						 	if Hs_ExisDic({{"C","GTJ_ITEREP"}},.F.)
								GTJ->GTJ_ITEREP := .T.
							endif
						 	MsUnlock()
						 	cMsg := STR0070 + " '" + allTrim(cProced) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cProced,'B1_DESC')) + ") " + STR0074 + chr(10) + chr(13) +chr(10) + chr(13) + ;
								STR0071 + "         : " + GTJ->GTJ_ITEM + chr(10) + chr(13) +;
								STR0072 + ": " + GTJ->GTJ_PRIORI //"O procedimento" ### "foi repetido!" ### "Item" ### "Prioridade"
						endif
						
						//Excluindo itens da arvore que foram repetidos
						for nI := 1 to len(aDelTree)
							if OTreeGTJ:TreeSeek(aDelTree[nI,1])
								OTreeGTJ:DelItem()
							endif
						next nI
						
						OTreeGTJ:PTRefresh()
						HS_MSGINF(cMsg, STR0041, STR0067)
					else
						HS_MSGINF(STR0079,STR0041, STR0067)//"Só é possível repetir procedimentos que já foram realizados!","Atenção", "Validação Atualização Plano de Tratamento"
						return
					endif 
				endif
			endif
		endif	                         
	else
		HS_MSGINF(STR0075,STR0041, STR0067)//"Para repetir o procedimento selecionado, execute o compatibilizador U_UPDGH030.","Atenção", "Validação Atualização Plano de Tratamento"
		return
	endif

elseif nOpcao == 2 //Finaliza procedimento
	DbSelectArea("GTJ")
	DbSetOrder(1)
	//Localiza o item, atualiza seu status e executa resfresh na tela   
	If DbSeek(xFilial("GTJ") + cNumOrc + cCodItem )
		if GTJ->GTJ_STATUS $ "034" // "0" = Pendente / "3" = Agendado / "4" = Em atendimento
			RecLock("GTJ", .F.)
			GTJ->GTJ_STATUS := "1"
			if Hs_ExisDic({{"C","GTJ_CRMEXE"}},.F.)
				GTJ->GTJ_CRMEXE := cCrmLog
			endif
			MsUnlock()
			//Atualiza os status da GT9
			lTratFin := fs_AtuStaGT9(GTJ->GTJ_NUMORC)
			
			//Gera valor de repasse para o profissional
			if SuperGetMV("MV_GERREPA", NIL, .F.)
				hs_gerRepAuto(GCY->GCY_REGATE, cProced, cNumOrc, cCodItem, cCrmLog, GTJ->GTJ_DENREG, GTJ->GTJ_FADENT, GTJ->GTJ_ITEREP, GTJ->GTJ_CRMANT)
			endif	
			
			HS_MSGINF(STR0070 + " '" + allTrim(cProced) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cProced,'B1_DESC')) + ") " + STR0087, STR0041, STR0067)//"O procedimento" ### "foi finalizado!" ### "Atenção" ### "Validação Atualização Plano de Tratamento"

			//Atualiza o status do item finalizado na tree
			OTreeGTJ:ChangeBmp("BR_VERDE","BR_VERDE","BR_VERDE","BR_VERDE",OTreeGTJ:getCargo())
		else
			HS_MSGINF(STR0076,STR0041, STR0067	)//"Não foi possível finalizar o procedimento pois o status atual não permite alteração!","Atenção", "Validação Atualização Plano de Tratamento"
			return
		endif
	endif
   
	OTreeGTJ:PTRefresh()
elseif nOpcao == 3 //Exclui procedimento
	FS_CANITPL(cOrc, cItem)
	DbSelectArea("GTJ")
	DbSetOrder(1)
	//Localiza o item, atualiza seu status e executa resfresh na tela   
	If DbSeek(xFilial("GTJ") + cOrc + cItem )
		if GTJ->GTJ_STATUS == "2"
			HS_MSGINF(STR0070 + " '" + allTrim(GTJ->GTJ_PRODUT) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+GTJ->GTJ_PRODUT,'B1_DESC')) + ") " + STR0078, STR0041, STR0067)//"O procedimento" ### "foi finalizado!"
			//Atualiza o status do item finalizado na tree
			OTreeGTJ:ChangeBmp("BR_PRETO","BR_PRETO",,,OTreeGTJ:getCargo())
		else
			HS_MSGINF(STR0076,STR0041, STR0067	)//"Não foi possível finalizar o procedimento pois o status atual não permite alteração!","Atenção", "Validação Atualização Plano de Tratamento"
			return
		endif
	endif  
endif
 
lTratFin := fs_AtuStaGT9(GTJ->GTJ_NUMORC)
//Atualiza o status do orçamento na tree               
if OTreeGTJ:TreeSeek(STR0030 + PadR(cNumOrc, 150)) 
	if lTratFin
		//Tratamento finalizado - Status="Finalizado"
		cResource := "BR_BRANCO"
	else
		//Verifica status na GT9
		DbSelectArea("GT9")
		DbSetOrder(1)
		If DbSeek(xFilial("GT9") + cNumOrc )//aLegGT9
			//0=Orc. Pendente;1=Pend. Financ.;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
			nResource := aScan(aLegGT9, {|aVet| GT9->GT9_STATUS $ aVet[1] })
			if nResource > 0
				cResource := aLegGT9[nResource,2] 
            endif
		endif
	endif    	
endif		

//Ajusta a cor
if OTreeGTJ:TreeSeek(STR0030 + PadR(cNumOrc, 150)) 
	OTreeGTJ:ChangeBmp(cResource,cResource,,,OTreeGTJ:getCargo())	
endif
//Atualiza
OTreeGTJ:PTRefresh()
	
restArea(aArea)
return            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldProfºAutor  ³Saude               º Data ³  22/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o usuario logado esta no cadastro de profissio  º±±
±±º          ³nais e com o codigode conselho (CRM,CRO,etc) preenchido     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   ³ FS_VldProf(cCodUsr)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cCodUsr - usuario logado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Function FS_VldProf(cCodUsr)
 Local aArea      := getArea()
 Local lRet       := .T.
 Local cRet       := ""
 Local cCrm       := ""
       
 Default cCodUsr  := ""

 If Type("__cCrmPls") # "U" .AND. !Empty(__cCrmPls)//Integração PLS E GH 
 	cRet := __cCrmPls
 Else
 	if !empty(cCodUsr)
	 	PswOrder(2) // indice por ID
		PswSeek(cCodUsr, .T.)  // Pesquisa o ID no cadastro de usuario
 	else 
 		PswOrder(1) // indice por ID
		PswSeek(__CUSERID, .T.)  // Pesquisa o ID no cadastro de usuario
	endif
    
 	dbSelectArea("SRA")
 	dbSetOrder(1)   
 	if dbSeek(xFilial("SRA") + SubStr(PSWRET(1)[1,22], Len(PSWRET(1)[1,22]) - TamSx3("RA_MAT")[1] + 1,TamSx3("RA_MAT")[1]) )
 		cRet := SRA->RA_CODIGO
 	endif
 	dbCloseArea()

 EndIf

 dbSelectArea("GBJ")
 dbSetOrder(1)  
 
 if empty(cRet)
 	lRet := .F.
 	HS_MsgInf(STR0082, STR0041, STR0083) // "Usuário não está liberado para acesso ao módulo."###"Atenção"###"Validação de usuário."
 elseIf dbSeek(xFilial("GBJ") + cRet)
 	if  empty(GBJ->GBJ_CRM)
	 	lRet := .F.
 		HS_MsgInf(STR0084 + chr(10) + chr(13) +; 
 		STR0085, STR0041, STR0083) //"Código do profissional no conselho não informado" ### "Ajuste o cadastro do profissional para que a manipulação dos procedimentos seja permitida." ###"Atenção"###"Validação de usuário."
 	else
 		cCrm := GBJ->GBJ_CRM
 	endif
 else
 	lRet := .F.
 	HS_MsgInf(STR0086, STR0041, STR0083) // "Usuário não está cadastrado como profissional, não pode manipular os procedimentos do tratamento."###"Atenção"###"Validação de usuário."
 Endif

 If lRet 
  	lTipMed := (GBJ->GBJ_TIPPRO $ "0/1/2") 
 EndIf

dbCloseArea()
restArea(aArea)
Return({lRet,cCrm})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ajuOrdM61ºAutor  ³Saude             º Data ³  22/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reordena o array com os campos que serao exibidos com base  º±±
±±º          ³na ordem em X3_ORDEM                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ FS_ajuOrdM61(aCpos)                                        ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºArgumentos³ aCpos  - array com os campos a serem exibidos na GetDados  ³±±
±±º          ³ aAlias - alias que serao considerados na reordenacao       º±±
±±º          ³ cCampoIni - Campo inicial que nao tera a ordem alterada    º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ array reordenado                                           ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Function FS_ajuOrdM61(aCpos, aAlias, cCampoIni, aDadoAcols)
Local aArea 	:= getArea()
Local aOrdenaH	:= {}
Local aRetHeader:= {}
Local aRetDados := {}
Local cAlsAtu	:= ""
Local nI		:= 0
Local nJ        := 0
Local nAlias    := 0
Local nLinhas   := 0
Local nColunas  := 0
Default aAlias	:= {}
 
//Ordena Header e preenche com os dados respectivos da coluna de acordo com aCols
For nI := 1 To Len(aCpos) + 1
	if nI > Len(aCpos)
		//Coluna adicional de aCols
		AADD( aOrdenaH, { {}, "ZZ", "ZZZZZZZZZZ", fs_dColAcols(Len(aCpos) + 1, aDadoAcols)})
	else
		dbSelectArea("SX3")
		DbGoTop()
		dbSetOrder(2)
		SX3->(MsSeek(aCpos[nI,2]))
		nAlias := aScan(aAlias, {|aVet| aVet == SubStr(aCpos[nI,2],1,(at("_",aCpos[nI,2])-1))})
		//Campo que deve aparecer SEMPRE no inicio (Ex: status)
		if  nAlias > 0 .and. aCpos[nI,2] == cCampoIni 
			AADD( aOrdenaH, {aCpos[nI], "00", "$" + aCpos[nI,2], fs_dColAcols(nI, aDadoAcols)})	
		elseif nAlias > 0 //Campo que deve ser ordenado
			AADD( aOrdenaH, {aCpos[nI], SX3->X3_ORDEM, aCpos[nI,2], fs_dColAcols(nI, aDadoAcols)})
		else //campo da tabela que nao foi selecionado para ordenacao
			AADD( aOrdenaH, {aCpos[nI], strZero(nI,2), aCpos[nI,2], fs_dColAcols(nI, aDadoAcols)})
		endif
	endif
Next nI

//Ordena o Header
aSort(aOrdenaH,,,{|x,y| x[2] + X[3]  < y[2] + Y[3]})	
For nI := 1 To Len(aOrdenaH)
	AADD(aRetHeader, aOrdenaH[nI,1]) 
Next nI

nLinhas  := len(aOrdenaH[1,4])
nColunas := len(aRetHeader)
aRetDados := array(nLinhas,nColunas)

//Reordenando colunas do aCols
for nI := 1  to nLinhas
	for nJ := 1 to nColunas
		aRetDados[nI,nJ] := aOrdenaH[nJ,4][nI,1]
	next nJ
next nI

aRetHeader := {}
//Refaz Header sem os dados da coluna
For nI := 1 To Len(aOrdenaH)-1
	AADD(aRetHeader, aOrdenaH[nI,1]) 
Next nI

RestArea(aArea)
Return({aRetHeader,aRetDados})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_dColAcolsºAutor  ³Saude             º Data ³  24/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os dados da coluna de aCols para a coluna definida  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ function fs_dColAcols(nColuna, aArrDados)                  ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºArgumentos³ nColuna  - Posicao da coluna que se deseja obter os dados  ³±±
±±º          ³ aArrDados- aCols que contem os dados                       º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ array                                                      ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
STATIC function fs_dColAcols(nColuna, aArrDados)
local aTemp := {}
local nI    := 0

for nI := 1 to len(aArrDados)
	aAdd(aTemp,{aArrDados[nI,nColuna]})
next nI

return aTemp
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CANORC ºAutor  ³ Saude             º Data ³  10/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada de  Cancelamento de orçamento do faturamento        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_CANORC(cOrcFat, cOrcLoj)
Local aArea 	:= GetArea()
Local nRecno	:= 0
Local aOrca		:={}
Local lExcOK	

Private aRotina := {		{STR0001,"AxPesqui"  	, 0 , 1, 0,.F.},; 	//"Pesquisar"
							{STR0002,"A415Visual"	, 0 , 2, 0,NIL},;	//"Visualizar"
							{STR0003,"A415Inclui"	, 0 , 3, 0,NIL},; 	//"Incluir"
							{STR0004,"A415Altera"	, 0 , 4, 0,NIL},; 	//"Alterar"
							{STR0005,"A415Exclui"	, 0 , 5, 0,NIL}}	//"Exclui"

If oApp:lMDI  // verifica a propriedade do objeto verdadeiro se MDI
	MsgStop("O cancelamento do tratamento na interface SIGAMDI não é permitido", STR0041) 
	Return()
EndIf

If !MsgYesNo("Deseja realmente cancelar o orçamento/tratamento e seus itens?",STR0041)
	Return()
EndIf

aCodUsr := HS_VldDAnm(.F.,.F.)

DbSelectArea("SCJ")
DbSetOrder(1)
If Empty(cOrcFat) .OR. !DbSeek(xFilial("SCJ") + cOrcFat)
	Return()
EndIf
nRecno := Recno()

If oGetOrc:aCols[oGetOrc:nAt,nGt9Status] == "BR_AMARELO"
	
	MATA415({},{},3) //Chamada da rotina automatica para criação das variaveis necessárias e execução dos Ajustas
	
	While __lSx8
		RollBackSxe()
	End
	
	DbSelectArea("SCJ")
	DbGoTo(nRecno)
	A415Cancel("SCJ",nRecno,4)
	
	While __lSx8
		RollBackSxe()
	End
	
	DbSelectArea("GTJ")
	DbSetOrder(1)
	DbSeek(xFilial("GTJ") + cOrcFat)
	While !Eof() .And. GTJ->GTJ_FILIAL == xFilial("GTJ") .And. GTJ->GTJ_NUMORC == cOrcFat
		If GTJ->GTJ_STATUS <> "1"
			RecLock("GTJ", .F.)
			GTJ->GTJ_STATUS	:= "2"
			MsUnlock()
		Endif
		DbSkip()
	End   
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusão do orçamento cabeçalho			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/	
	DbSelectArea("GT9")
	DbSetOrder(1)
	If DbSeek(xFilial("GT9") + cOrcFat)
		RecLock("GT9", .F.)
		GT9->GT9_STATUS	:= "4"		
		MsUnlock()
	EndIf	

Elseif oGetOrc:aCols[oGetOrc:NaT,nGt9Status] $ "BR_VERDE/BR_AZUL"
	
	If !aCodUsr[1] .Or. GBJ->GBJ_SOLAUT == '1'
		aOrca:=FS_VerOrc()
		lOrcLib:=aOrca[1]
		If !lOrcLib
			Return()
		Else
			__cCdJustGT9 := aOrca[2]
			__cCdUsrFGT9 := aOrca[3]
		Endif
	Else
		__cCdJustGT9 := HS_Justif()
		__cCdUsrFGT9 := __CUSERID
	Endif
		

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusão dos itens da Nota Fiscal no LOJA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/ 
	If !Empty(cOrcLoj)
		DbSelectArea("SL1")
		DbSetOrder(1)
		DbSeek(xFilial("SL1") + cOrcLoj)
		lExcOk := Lj140Exc("SL1", SL1->(RECNO()), 2)
		If ValType(lExcOk) == "U"
			lExcOK := .F.
		ElseIf ValType(lExcOk) == "N"
			lExcOK := IIF(lExcOk == 1, .T., .F.)
		Else //Logico
			lExcOK := lExcOk
		EndIf 
		If !lExcOK
			MsgStop("Erro na exclusão da Nota!", STR0041)
			Return()
		EndIf 
	EndIf	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusão dos itens no Plano de Tratamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/	
	DbSelectArea("GTJ")
	DbSetOrder(1)
	DbSeek(xFilial("GTJ") + cOrcFat)
	While !Eof() .And. GTJ->GTJ_FILIAL == xFilial("GTJ") .And. GTJ->GTJ_NUMORC == cOrcFat
		If GTJ->GTJ_STATUS <> "1"
			RecLock("GTJ", .F.)
			GTJ->GTJ_STATUS	:= "2"
			MsUnlock()
		Endif
		DbSkip()
	End   
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusão do orçamento cabeçalho			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/	
	DbSelectArea("GT9")
	DbSetOrder(1)
	If DbSeek(xFilial("GT9") + cOrcFat)
		RecLock("GT9", .F.)
		GT9->GT9_STATUS	:= "4"
		GT9->GT9_MTVAGE := __cCdJustGT9
		GT9->GT9_USRFOR := __cCdUsrFGT9
		MsUnlock()         
		__cCdJustGT9 	:= ""
		__cCdUsrFGT9	:= ""
	EndIf

Endif
aColsGT9Or := {}
HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, cCondGT9,,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,, aCpoGt9,,,"GT9_NUMFAT DESC")
oGetOrc:SetArray(aColsGT9Or)
oGetOrc:oBrowse:Refresh()

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_VerOrc ³ Autor ³ Saude     			³ Data ³ 06/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificação se existe Orcamento Liberado e chama tela Senha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VerOrc()
Local lRet		:=.F.
Local aUsuario	:={}
Local cSuperio 	:=""
Local cCodigo	:= ""

aUsuario:=HS_RetSup()
If aUsuario[1]==.T.
	cSuperio:=aUsuario[2]
	cCodigo:=HS_Justif()
	If !Empty(cCodigo)
		lRet:=.T.
	Else
		lRet:=.F.
	Endif
Else
	lRet:=.F.
Endif

Return({lRet,cCodigo,cSuperio})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VERSTLOJºAutor  ³Saude              º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define o Status do orçamento no loja de acordo com a regra º±±
±±º          ³ do                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERSTLOJ(cNum)
Local aArea		:= GetArea()
Local lLjPedVe	:= SuperGetMV("MV_LJPEDVE", NIL, .F.) //Verifica se utiliza emissao de Pedidos de Venda
Local lPosPed	:= .F.
Local cRet		:= ""

dbSelectArea("SM0")
dbGotop()

DbSelectArea("SL1")                                                           
DbSetOrder(1)
If !DbSeek(xFilial("SL1") +cNum)
	Return("")
EndIf

lPosPed := SL1->(FieldPos("L1_PEDRES")) > 0 .AND. SLQ->(FieldPos("LQ_PEDRES")) > 0	//Verifica se os campos L1_PEDRES e LQ_PEDRES estao criados

IF !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE) .AND. AllTrim(SL1->L1_STATUS) == "T"
	cRet := "BR_BRANCO"			//"Transação TEF desfeita"
EndIf
If !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE) .AND. SL1->L1_STATUS <> "D" .AND. SL1->L1_STATUS <> "F"
	cRet := "BR_VERMELHO"		//"Vendas efetuadas"
EndIf
If Empty(SL1->L1_DOC) .AND. Empty(SL1->L1_RESERVA) .AND. dDataBase<=SL1->L1_DTLIM .AND. SL1->L1_STATUS <> "D" .AND. IIf(SL1->(FieldPos("L1_STORC")) >0, SL1->L1_STORC <> "C", .T.)
	cRet := "BR_VERDE"			//"Orçamentos em aberto"
EndIf
If lLjPedVe .AND. lPosPed
	If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D" .AND. Empty(SL1->L1_PEDRES)
		cRet := "BR_AMARELO"	//"Orcamentos com reservas"
	EndIf
	If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D" .AND. !Empty(SL1->L1_PEDRES)
		cRet := "BR_LARANJA"	//"Orcamentos com Pedidos de Venda"
	EndIf
Else
	If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D"
		cRet := "BR_AMARELO"	//"Orcamentos com reservas"
	EndIf
EndIf

If Empty(SL1->L1_DOC) .AND.  Empty(SL1->L1_RESERVA) .AND. dDataBase>SL1->L1_DTLIM  .AND. SL1->L1_STATUS<>"D" .AND. IIf(SL1->(FieldPos("L1_STORC")) > 0 , SL1->L1_STORC <> "C" , .T.)
	cRet := "BR_PRETO"			//"Orcamentos em aberto vencidos"
EndIf
If Empty(SL1->L1_DOC) .AND. SL1->L1_TIPO=="P"       .AND. !Empty(SL1->L1_DOCPED)   .AND. SL1->L1_STATUS<>"D"
	cRet := "BR_AZUL"			//"Pedidos encerrados"
EndIf
If SL1->L1_STATUS="D"
	cRet := "BR_MARROM"			//"Devoluções pendentes"
EndIf
If LjNfPafEcf(SM0->M0_CGC)
	If Empty(SL1->L1_DOC) .AND. SL1->(FieldPos("L1_STORC")) > 0 .AND. SL1->L1_STORC == "C"
		cRet := "BR_PINK"		//"Orçamentos Cancelados"
	EndIf
Else
	If Empty(SL1->L1_DOC) .AND. LjAnalisaLeg(6)[1] .AND. SL1->(FieldPos("L1_STORC")) > 0 .AND. SL1->L1_STORC == "C"
		cRet := "BR_PINK"			//"Orçamentos Cancelados"
	EndIf
EndIf	
If SL1->(FieldPos("L1_NUMFRT")) > 0
	If SL1->L1_STATUS = "F" .AND. SL1->L1_SITUA = "FR" .AND. !Empty(SL1->L1_NUMFRT)
		cRet := "BR_CINZA"		//"Orcamnetos pagos no FrontLoja"
	EndIf
	If (!Empty(SL1->L1_DOC) .OR. !Empty(SL1->L1_DOCPED)) .AND. SL1->L1_STATUS = "F" .AND. Empty(SL1->L1_NUMFRT) .AND. !Empty(SL1->L1_NUMORIG)
		cRet := "BR_AZUL"			//"Pedidos encerrados"
	EndIf
EndIf

RestArea(aArea)
Return(cRet)
 
Static Function FS_ExcFat()
Local nPosMark := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_IDMARC"})
Local nPosNTit := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_NUMTIT"})
Local nForIte  := 0
Local lTemTit  := .F.//Indica se o registro da GTJ possui titulo associado
Local aTitulo  := {/*Prefix*/,/*NumTit*/,/*Parcel*/,/*Tipo*/,/*Fornec*/,/*Loja*/,}

For nForIte := 1 To Len(oGetOrcIte:aCols)
	
	If oGetOrcIte:NAT == nForIte .And. !Empty(oGetOrcIte:aCols[nForIte,nPosNTit]) 
		lTemTit := .T.
		nPos := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_PREFIX"})
		aTitulo[1] := oGetOrcIte:aCols[nForIte,nPos]
		nPos := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_NUMTIT"})
		aTitulo[2] := oGetOrcIte:aCols[nForIte,nPos]
		nPos := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_PARCEL"})
		aTitulo[3] := oGetOrcIte:aCols[nForIte,nPos]
		nPos := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_TIPO"})
		aTitulo[4] := oGetOrcIte:aCols[nForIte,nPos]
		nPos := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_FORNEC"})
		aTitulo[5] := oGetOrcIte:aCols[nForIte,nPos]
		nPos := Ascan(oGetOrcIte:aHeader,{|x| AllTrim(x[2]) == "GTJ_LOJA"})
		aTitulo[6] := oGetOrcIte:aCols[nForIte,nPos]
	EndIf

Next nForIte

If lTemTit

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If SE2->(msSeek(xFilial("SE2")+aTitulo[1]+aTitulo[2]+aTitulo[3]+aTitulo[4]+aTitulo[5]+aTitulo[6]))

		If !Empty(SE2->E2_BAIXA)
			HS_MsgInf(STR0098,STR0041,STR0096)//"Título já sofreu movimentação e não poderá ser excluído."
			Return
		EndIf
		
		If !MsgYesNo(STR0099 + chr(10) + chr(13) + SE2->E2_PREFIXO +"-"+SE2->E2_NUM+"-"+SE2->E2_TIPO, STR0041) //"Confirma exclusão do título ? XXX-999999999-99"###"Atenção"
			Return
		EndIf
		
		//vou limpar a GTJ
		dbSelectArea("GTJ")
		GTJ->(dbSetOrder(2))
		If GTJ->(msSeek(xFilial("GTJ")+aTitulo[1]+aTitulo[2]+aTitulo[3]+aTitulo[4]+aTitulo[5]+aTitulo[6]))
			While !GTJ->(Eof()) .And. GTJ->(GTJ_FILIAL+GTJ_PREFIX+GTJ_NUMTIT+GTJ_PARCEL+GTJ_TIPO+GTJ_FORNEC+GTJ_LOJA) == xFilial("GTJ")+aTitulo[1]+aTitulo[2]+aTitulo[3]+aTitulo[4]+aTitulo[5]+aTitulo[6]
				GTJ->(RecLock("GTJ"),.F.)
				GTJ->GTJ_PREFIX := ""
				GTJ->GTJ_NUMTIT  := ""
				GTJ->GTJ_PARCEL := ""
				GTJ->GTJ_TIPO   := ""
				GTJ->GTJ_FORNEC := ""
				GTJ->GTJ_LOJA   := ""
				GTJ->(msUnLock())
				GTJ->(dbSkip())
			EndDo 
		EndIf
		
		//Exclusao do titulo
		SE2->(RecLock("SE2",.F.))
		SE2->(dbDelete())
		SE2->(msUnLock())
		HS_MsgInf(STR0100,STR0041,STR0096)//Titulo: XXX-999999999-9#Atencao#Exclusao de Titulo
		FS_ATUITEM(GTJ->GTJ_NUMORC)
		FS_ORCTotal(oDlgAU,GTJ->GTJ_NUMORC)
	Else
		HS_MsgInf(STR0101,STR0041,STR0096)//"Não foi possível localizar a fatura relacionada!" XXX-999999999-9#Atencao#Exclusao de Titulo
	EndIf
Else
	HS_MsgInf(STR0097,STR0041,STR0096)//"Nenhum item de orçamento selecionado com título relacionado!"#Atencao#"Exclusão de Fatura"
EndIf

Return

/*/{Protheus.doc} Fs_AtuaItem
Função para atualização do Grid da tela de auditoria financeira
@author HSP
@since 28/07/2016
@version P12.1.05
/*/
Static Function Fs_AtuaItem(cCodCli) 

//Limpando as variaveis para não paresentar nenhum paciente na tela 
aColsGT9Or	:={}
aColsSCK 	:={}

If Pergunte("HSPM61", .T.) 	

 	DbSelectArea("GBH")
	DbSetOrder(1)
	
	If !Empty(MV_PAR01) .And. DbSeek(xFilial("GBH") + MV_PAR01)  
		Default	cCodCli	:= GBH->GBH_CODCLI
				cRegGer := GBH->GBH_CODPAC
	Else
		Default	cCodCli	:= ""
				cRegGer := ""
	Endif
	
Else
	Return()
EndIf     
 
If Empty(cCodCli)
	cCondGT9 := " GT9_STATUS IN('1','2','3','5') "
Else  
	cCondGT9 := " GT9.GT9_CLIENT = '" + cCodCli + "' "
EndIf

HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, cCondGT9,,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,, aCpoGt9,,,"GT9_NUMFAT DESC")
oGetOrc:setArray(aColsGT9Or)
oGetOrc:oBrowse:refresh()

HS_BDados("GTJ" , @aHeadSCK, @aColsSCK,, 1, , " GTJ.GTJ_NUMORC = '" + oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat] + "' ",,"GTJ_STATUS","/",,,,{"GTJ_IDMARC"},{"'LBNO'"},.T.,aLegGTJ,,.T.,,,aCpoSck  ,aJoinSck,,cOrdeSck)
oGetOrcIte:setArray(aColsSck)
oGetOrcIte:oBrowse:refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSCerDigOP º Autor ³ Saude            º Data ³ 20/01/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Habilita opcoes de consulta e alteracao do certificado     º±±
±±º          ³ digital                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HSCerDigOP(oGDGfu)    
Local nPosCDANAM := Ascan(oGDGfu:aHeader,{|x|x[2] == "GFU_CDANAM"})
Local aAreaGFU := GFU->(GetArea())
Local cCertDig := ""
Local cArqPDF  := ""
Local oDlg


DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 

If GFU->(DbSeek(xFilial("GFU")+oGDGfu:aCols[oGDGfu:nAt][nPosCDANAM]))  

    cCertDig := E_MSMM(GFU->GFU_ASSDIG)
    cArqPDF  := GFU->GFU_ARQCER
	DEFINE MSDIALOG oDlg TITLE STR0103 FROM 008.0,010.3 TO 034.4,90 //"Assinatura Digital"
   
	@ 010,005 SAY oSay PROMPT STR0104  SIZE 100,010 OF oDlg PIXEL COLOR CLR_RED //"Arquivo PDF"
	@ 020,005 MSGET cArqPDF  PICTURE "@" SIZE 80, 7 PIXEL OF oDlg 
    
	@ 040,005 SAY oSay PROMPT STR0103  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Assinatura Digital"
	@ 050,005 GET oMsg VAR cCertDig MEMO SIZE 310,120 PIXEL OF oDlg 
   
	@ 180,156 BUTTON STR0105  SIZE 36,13 PIXEL ACTION HSCDAcao(1,oDlg,@cArqPDF,@cCertDig) //"&Assinar"
	@ 180,194 BUTTON STR0106  SIZE 36,13 PIXEL ACTION HSCDAcao(2) //"&Validar Cert."
	@ 180,232 BUTTON STR0107  SIZE 36,13 PIXEL ACTION HSCDAcao(3,oDlg,@cArqPDF,@cCertDig) //"Visualizar &PDF"
	@ 180,270 BUTTON STR0108  SIZE 36,13 PIXEL ACTION oDlg:End() //"&Cancelar"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa dialogo....                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg CENTERED 
EndIf

RestArea(aAreaGFU)

Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSCDAcao   º Autor ³ Saude            º Data ³ 20/01/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa acoes da opcao de Certificado Digital              º±±
±±º          ³ digital                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HSCDAcao(nOpc,oDlg,cArqPDF,cCertDig) 
Local cPathServer := ""
Local cPathLocal  := ""
Local aRetPath    := {}

Do Case  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a assinatura do certificado digital	                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case nOpc == 1
		If GFU->GFU_STAASS == "1"
			MsgInfo(STR0109) //"A anamnese selecionada já foi assinada digitalmente."
		Else
			HSPRQUES("GFK","GFK_CDANAM",/*cValChv*/,/*cCdQues*/,GFU->GFU_REGATE,/*cAssinatura*/,GFU->GFU_CODCRM,/*cCodloc*/,.T.,GFU->GFU_CDANAM)
	   	    cCertDig := E_MSMM(GFU->GFU_ASSDIG)
   			cArqPDF  := GFU->GFU_ARQCER
			oDlg:Refresh()
		EndIf    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida via webservice se uma assinatura ja realizada e valida            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case nOpc == 2   
		If GFU->GFU_STAASS == "1"  
			HSCertDig("3")
		Else
			MsgInfo(STR0110) //"A anamnese selecionada não foi assinada digitalmente."
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo PDF                           		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Case nOpc == 3 	 
		If GFU->GFU_STAASS == "1"   
			cPathServer := PLSMUDSIS(Alltrim(GFU->GFU_DIRCER)+'\'+cArqPDF)  
			aRetPath := fDirPdfHSP(Alltrim(GFU->GFU_CODCRM),"A")
			If aRetPath[1]
				cPathLocal := aRetPath[2]  
				If CpyS2T(cPathServer,cPathLocal,.T.)
					ShellExecute("Open", cPathLocal+cArqPDF, " /k dir", GetTempPath(), 1 )         
				EndIf	
			Else
            	MsgInfo(aRetPath[2])
			EndIf
		Else
			MsgInfo(STR0110) //"A anamnese selecionada não foi assinada digitalmente."
		EndIf	
EndCase
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fDirPdfHSP º Autor ³ Saude            º Data ³ 21/01/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria diretorios locais para gravacao de PDFs               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fDirPdfHSP(cCodCRM,cTipo)
Local aDir    := {}
Local nCont   := 0 
Local cDir    := "" 
Local lRet    := .T.              
Default cTipo := "A"

Aadd(aDir,"totvsprinter")	
Aadd(aDir,"certificados")	
If cTipo == "A"
	Aadd(aDir,"anamnese")
Else
	Aadd(aDir,"prescricao")
EndIf	
Aadd(aDir,cCodCRM)    

If MakeDir(GetTempPath()) == 3	    
	MsgInfo(STR0111+GetTempPath()) //"Não foi possivel criar o diretorio " 
	lRet := .F.
Else 
	cDir := GetTempPath()
	For nCont := 1 to len(aDir)
		If MakeDir(cDir+aDir[nCont]) == 3
			lRet := .F.
			cDir := STR0111+cDir+aDir[nCont] //"Não foi possivel criar o diretorio " 
			Exit
        EndIf
		cDir += aDir[nCont]+"\"
	Next
EndIf

Return({lRet,cDir})
