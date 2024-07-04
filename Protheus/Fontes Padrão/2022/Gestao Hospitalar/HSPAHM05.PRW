#INCLUDE "HSPAHM05.ch"
#include "protheus.CH"                                                                                         
#include "TopConn.ch"

Function HSPAHM05()
Local aCores := {	{"GAI->GAI_FLGATE == '0' .And. GAI->GAI_URGENC == '0'", 'BR_VERDE'		},;
					{"GAI->GAI_FLGATE == '1'                             ", 'BR_AMARELO'	},;
					{"GAI->GAI_FLGATE == '2'                             ", 'BR_VERMELHO'	},;
					{"GAI->GAI_FLGATE == '3'                             ", 'BR_MARRON'		},;
					{"GAI->GAI_FLGATE == '4'                             ", 'BR_CINZA'		},;
					{"GAI->GAI_FLGATE == '0' .And. GAI->GAI_URGENC == '1'", 'BR_PRETO'		} }
Local aCores2	:= {}
Local n			:= 0
Private cCadastro := STR0001 //"Atendimento de solicita็oes Mat/Med"

Private aRotina := MenuDef()

Private cFilM05     := "", lFilGM1 := .T. //Utilizada para filtro e consistencia de SETOR/USUARIO
Private cGcsTipLoc  := ""
Private cG1RTipo    := "014"
Private cCodLoc_Far := ""
Private cCodArmFar  := ""
Private dDatSol_De  := ""
Private dDatSol_Ate := ""
Private __cCtrEst   := ""
Private lOrigemM05  := .T.
Private lVldSet     := .F.
Private __lMovest   := .T.
Private cPlanoPart := ""
Private cNrseqg    := ""
Private cGcsCodLoc := ""

If ExistBlock("HSPM05LEG")
	aCores2 := ExecBlock("HSPM05LEG", .F., .F., {aCores[1][2], aCores[2][2], aCores[3][2], aCores[4][2], aCores[5][2], aCores[6][2]})
	For n := 1 to Len(aCores2)
		aCores[n][2] := aCores2[n]
	Next n
EndIf

DbSelectArea("GAI")
DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI

If FS_FilM05("HSPM5B", .F.)
	cCodArmFar := HS_IniPadr("GCS", 1, cCodLoc_Far, "GCS_ARMSET",, .F.)
	SetKey(VK_F12, {|| FS_FilM05("HSPM5B", .T.) })
	mBrowse(06, 01, 22, 75, "GAI",,,,,, aCores,,,,,,,,cFilM05)
Endif

SetKey(VK_F12)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_AteM05 บAutor  ณMicrosiga           บ Data ณ  11/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para realizar o atendimento das solicitacoes  บฑฑ
ฑฑบ          ณa farmacia.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_AteM05(cAliasM05, nRegM05, nOpcM05)
Local bKeyF4, bKeyF5
Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local lVldDic:= HS_EXISDIC({{"C", "GAI_BARKIT"}},.F.)
Local aCpos := {}, aCposAlt := IIF(nOpcM05 == 6, {"GCY_QATEND", "GCY_CBMATM", "GCY_INDCBL", "GCY_CBLOTE"},{"GAI_USUDIS", "GAI_USUCON", "GAI_QATEND", "GAI_CBMATM", "GAI_INDCBL", "GAI_CBLOTE", IIF(nOpcM05 == 4 .And. lVldDic, "GAI_BARKIT", Nil)})
Local oDlgM05, nOpcDlg := 0, aHGaj := {}, aCGaj := {}, cCpoNao := "", aCpoIni := {}
Local cGbdNumDev := "", nGDOpc := IIf(nOpcM05 == 3, GD_UPDATE+GD_DELETE, IIF(nOpcM05 == 5 .Or. nOpcM05 == 6, GD_UPDATE, 0))
Local aMLocksSb2 := {}, aMLocksSb8 := {}, cCodPMov := "", nItens := 0  /* aMLocksSb3 := {},*/
Local cSolici    := ""      
Local cBloqUsr   := ""
Local j			 := 0
Local lMVLocUs	 := GetNewPar("MV_HSCOLOC",.T.) // Indica se serแ considerado o controle de lock de registros na rotina de Atend. Solicita็ใo(HSPAHM05).
Local cMvTpIndic := SuperGetMV("MV_TPINDIC",,"1")

Private __dDtVal :=""
Private oEnchoice
Private cAlias := IIF(nOpcM05 == 6, "GCY", "GAI")
Private aTela := {}, aGets := {}, cPerg1 := "HSPM05"
Private nUGaj := 0, oGDGaj, oGDMM, aMatClone := {}, aPosGaj := {}
Private dHSDataLD := dDataBase
Private nGajIteSol := 0, nGajQAtend := 0, nGajQtdSol := 0, nGajProSol := 0, nGajDesPro := 0, nGajQtdAte := 0
Private nGajCodJus := 0, nGajJustif := 0, nGajCodKit := 0, nGajDesKit := 0, nGajLoteFo := 0, nGajLoteCt := 0
Private nGajNumLot := 0, nGajDtVali := 0, nGajProAlt := 0, nGajDPrAlt := 0, nGajQDevol := 0, nGajQtdDev := 0
Private nGajCbMatm := 0, nGajCodCrm := 0, nGajDesCrm:=0,nGajItePre := 0, nGajCodPct := 0
Private aHMM := {}, aCMM := {}, nUMM := 0
Private nMMCodDes  := 0, nMMQtdDes  := 0, nMMQDevol := 0, nMMSeqDes := 0, nMMIteSol := 0, nMMProAlt := 0
Private nMMNumLot := 0, nMMLoteCt := 0, nMMDtVali := 0, nMMSolici := 0, nMMDatDes := 0, nMMHordes := 0 
Private cLctCodLoc := Space(Len(GCS->GCS_CODLOC))
Private aKitVirt  := {}, __aVldSld := {}
Private nHdlPrv 			// Endereco do arquivo de contra prova dos lanctos cont.
Private lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
Private cLoteEst 			// Numero do lote para lancamentos do estoque
Private nTotal := 0 	// Total dos lancamentos contabeis
Private cArquivo		// Nome do arquivo contra prova
Private aIAtend := {}                          
Private lMV_ProdAlt := GetMV("MV_PRODALT")
Private __fVMatMed  := "HS_M05VMM(M->GAJ_PROSOL, " + AllTrim(Str(nOpcM05)) + ")"     
Private __cProAlt   := ""
Private __aProMov   := "HS_M05VPRO(IIF('"+ AllTrim(Str(nOpcM05))+ "' <> '6', M->GAI_CBMATM, M->GCY_CBMATM)," + AllTrim(Str(nOpcM05)) + ")"
Private cCusMed := GetMv("MV_CUSMED"), aRegSD3  := {}      
Private lItePre:= HS_ExisDic({{"C", "GAJ_ITEPRE"}}, .F.) 

Private FHS_M05    := CriaVar(cAlias+"_QATEND")
Private __MMQtdDe  := FHS_M05 

Private __nOpcM05 := aRotina[nOpcM05, 4]
 
Private __cFCBLote := "HS_M24Lote(SB8->B8_PRODUTO, SB8->B8_SALDO, M->"+cAlias+"_QATEND)"

Private __cLOTEFO := Space(Len(GAJ->GAJ_LOTEFO))
Private __cLOTECT := Space(Len(GAJ->GAJ_LOTECT))
Private __cNUMLOT := Space(Len(GAJ->GAJ_NUMLOT))
Private __dDTVALI := CriaVar("GAJ_DTVALI")
Private __lCBLote := .T.
Private __aRLote  := {	{"__cNUMLOT", "SB8->B8_NUMLOTE"}, ;
                       	{"__cLOTEFO", "SB8->B8_LOTEFOR"}, ;
                        {"__cLOTECT", "SB8->B8_LOTECTL"}, ;
                        {"__dDTVALI", "SB8->B8_DTVALID"}}
                     

Private __aRProSel := {	{"oGDGaj:aCols[oGDGaj:nAt, nGajNumLot]", "Space(Len(SB8->B8_NUMLOTE))"}, ;
                        {"oGDGaj:aCols[oGDGaj:nAt, nGajLoteFo]", "Space(Len(SB8->B8_LOTEFOR))"}, ;
                        {"oGDGaj:aCols[oGDGaj:nAt, nGajLoteCt]", "Space(Len(SB8->B8_LOTECTL))"}, ;
                        {"oGDGaj:aCols[oGDGaj:nAt, nGajDtVali]", "CToD('')"                   }, ;
                        {"oGDGaj:aCols[oGDGaj:nAt, nGajProAlt]", "GBI->GBI_PRODUT"            }, ;
                        {"oGDGaj:aCols[oGDGaj:nAt, nGajDPrAlt]", "HS_IniPadr('SB1', 1, GBI->GBI_PRODUT, 'B1_DESC',,.F.)"}}
 
Private dDatMov := ctod("  /  /  ")
Private cHorMov := ""
Private __nOpcFar := nOpcM05 
Private __cReservGAV := ""  
Private __cRequis := ""
Private cSetor := "" 
Private dDatSolGrv
 
AjustaSXB()
 
If ExistBlock("HM05VLD")
	If ExecBlock("HM05VLD",.F.,.F.,{cAliasM05, nRegM05, nOpcM05}) == .F.
		Return Nil
	Endif
Endif   
 
If !HS_VldPar(StrTran(aRotina[nOpcM05, 1], "&", ""))
	Return()
Endif 

If     nOpcM05 == 4 .And. (GAI->GAI_FLGATE == "2" .OR. GAI->GAI_FLGATE == "3") // Atendimento de solicita็ใo // Atendimento total
	HS_MsgInf(STR0009, STR0008, STR0001) //"A solicita็ใo selecionada foi totalmente atendida"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"  
	Return(Nil)   
ElseIf     nOpcM05 == 4 .And. GAI->GAI_FLGATE == "4" // Atendimento Encerrado
	HS_MsgInf(STR0044, STR0008, STR0001) //"A solicitacao selecionada esta encerrada e nao pode ser atendida"###"Atencao"###//"Atendimento de solicita็oes Mat/Med" 
	Return(Nil)
ElseIf lMVLocUs .And. (nOpcM05 == 3 .Or. nOpcM05 == 4) .And. !LockByName(xFilial("GAI") + GAI->GAI_SOLICI , .T., .T., .F.) //Trava  a Solicita็๕a ou Atendimento
	If ExistBlock("HSPVerFiCo")
		cBloqUsr := HSPVerFiCo("GAI",xFilial("GAI") + GAI->GAI_SOLICI ,.F.) 
		If !EMPTY(cBloqUsr) // Se retornar vazio nใo encontrou usuแrio de bloqueio
			HS_MsgInf(STR0102+" - "+cBloqUsr, STR0008, STR0001) //""Esta solicita็ใo encontra-se bloqueado por outro usuแrio. "###"Aten็ใo"###"Valida็ใo do sexo do paciente"
			Return(Nil)
		EndIf
	Else
		HS_MsgInf(STR0102, STR0008, STR0001) //""Esta solicita็ใo encontra-se bloqueado por outro usuแrio. "###"Aten็ใo"###"Valida็ใo do sexo do paciente"
		Return(Nil)
	EndIf   
ElseIf nOpcM05 == 5 .And. GAI->GAI_FLGATE == "0" // Devolu็ใo de itens atendidos // Nใo atendida
	HS_MsgInf(STR0010, STR0008, STR0001) //"A solicita็ใo selecionada nใo foi atendida"###"Atencao"###//"Atendimento de solicita็oes Mat/Med" 
	Return(Nil)                      
ElseIf nOpcM05 == 5 .And. GAI->GAI_REQUIS <> "1" // Devolu็ใo de itens atendidos // Paciente
	HS_MsgInf(STR0011 + STR0012, STR0008, STR0001) //"Somente as solicita็๕es requisitadas"###"para paciente podem ser devolvidas"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"  
	Return(Nil)                      
ElseIf nOpcM05 == 5
	DbSelectArea("GD5")
	DbSetOrder(4) // GD5_FILIAL + GD5_SOLICI + GD5_ITESOL
	If !DbSeek(xFilial("GD5") + GAI->GAI_SOLICI)
		HS_MsgInf(STR0013 + STR0014, STR0008,STR0001) //"Nใo foi encontrada nenhuma despesa "###"para ser devolvida nesta solicita็ใo"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"   
		DbSelectArea("GAI")
		DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI   
		Return(Nil)
	EndIf
EndIf 

If ExistBlock("HSPGerFiCo") .And. lMVLocUs .And. (nOpcM05 == 3 .Or. nOpcM05 == 4) // Solicitacao ou Atendimento
	HSPGerFiCo("GAI",xFilial("GAI") + GAI->GAI_SOLICI)
EndIf
 
If nOpcM05 # 6 
	DbSelectArea("GAI")
	DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI
	If GAI->GAI_REQUIS == "0"
		DbSelectArea("GCY")
		DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
		DbSeek(xFilial("GCY") + GAI->GAI_REGATE)
		DbSelectArea("GAI")
		DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI 
		If GCY->GCY_TPALTA == "99"
			HS_MsgInf(STR0015, STR0008, StrTran(aRotina[nOpcM05, 1], "&", "")) //"Atendimento ja foi cancelado"###"Aten็ใo"
			If nOpcM05 == 4
				UnLockByName(xFilial("GAI") + GAI->GAI_SOLICI , .T., .T., .F.)
			Endif
			Return(.T.)
		EndIf 
	EndIf   
Else //nOpcM05 == 6  Dev. por Atend.
	If !Pergunte("HSPM5A",.T.)
		If nOpcM05 == 4
			UnLockByName(xFilial("GAI") + GAI->GAI_SOLICI , .T., .T., .F.)
		Endif
		Return(Nil)
	EndIf
	DbSelectArea("GCY")
	DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
	DbSeek(xFilial("GCY") + MV_PAR01)
	If GCY->GCY_TPALTA == "99"
		HS_MsgInf(STR0015, STR0008, StrTran(aRotina[nOpcM05, 1], "&", "")) //"Atendimento ja foi cancelado"###"Aten็ใo"
		If nOpcM05 == 4
			UnLockByName(xFilial("GAI") + GAI->GAI_SOLICI , .T., .T., .F.)
		Endif
		Return(.T.)
	EndIf 
	cSetor := MV_PAR04
EndIf 

If nOpcM05 # 5 .And. nOpcM05 # 6
	bKeyF4 := SetKey(VK_F4, {|| HS_SelLote(oGDGaj:aCols[oGDGaj:nAt, IIf(lMV_ProdAlt .And. !Empty(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt]), nGajProAlt, nGajProSol)], M->GAI_ALMORI, oGDGaj:aCols[oGDGaj:nAt, nGajQAtend])})
	bKeyF5 := SetKey(VK_F5, {|| HS_SelPAlt(oGDGaj:aCols[oGDGaj:nAt, nGajProSol])})
EndIf
If Existblock("HM05CPOS")
	aCposUsu:=Execblock("HM05CPOS",.F.,.F.,{nOpcM05})
	If Valtype(aCposUsu)=='A'
		For j:=1 to len(aCposUsu)	
			AADD(aCposAlt,aCposUsu[J])
		Next			
	Endif
Endif	
DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM                              
DbSeek(cAlias)
While !Eof() .And. SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .Or. (aScan(aCposAlt, SX3->X3_CAMPO) > 0)
		If SX3->X3_CAMPO <> "GAI_URGENC" //so mostrado no Posto/solicitacao
			aAdd(aCpos, SX3->X3_CAMPO)
		EndIf 
	EndIf 
  
	If aRotina[nOpcM05, 4] == 3                                                                  
		&("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
	Else             
		If nOpcM05 == 6
			&("M->" + SX3->X3_CAMPO) := IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GCY->(FieldGet(GCY->(FieldPos(SX3->X3_CAMPO)))))
		Else
			&("M->" + SX3->X3_CAMPO) := IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GAI->(FieldGet(GAI->(FieldPos(SX3->X3_CAMPO)))))
		EndIf 
	EndIf 
    
	If SX3->X3_CAMPO $ "GAI_INDCBL/GCY_INDCBL"
		&("M->" + SX3->X3_CAMPO) := cMvTpIndic
	EndIf
  
	DbSkip()
End

If nOpcM05 == 5 .Or. nOpcM05 == 6 // Devolucao por solic. ou atend.
	cCpoNao := "GD5_CODBAR"
	aCpoIni := IIF(nOpcM05 == 6, {"GD5_SOLICI","GD5_SEQDES", "GD5_ITESOL", "GD5_QDEVOL"},{"GD5_SEQDES", "GD5_ITESOL", "GD5_QDEVOL"})
	cCond   := IIF(nOpcM05 == 6, "GD5->GD5_REGATE == '" + MV_PAR01 + "' .And. GD5->GD5_DATDES >= '" + DTOS(MV_PAR02) + "' .And. GD5->GD5_DATDES <= '" + DTOS(MV_PAR03) + "' .And. GD5->GD5_CODLOC = '" + cSetor + "' " ,;
                                "GD5->GD5_SOLICI == '" + M->GAI_SOLICI + "'")
	HS_BDados("GD5", @aHMM, @aCMM, @nUMM, 4, IIF(nOpcM05 == 6, MV_PAR01, M->GAI_SOLICI), cCond,,,,, cCpoNao,,,,,,,,,, aCpoIni)
  
	nMMDatDes := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_DATDES"})
	nMMHorDes := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_HORDES"})  
	nMMCodDes := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_CODDES"})
	nMMQtdDes := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_QTDDES"})
	nMMQDevol := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_QDEVOL"})
	nMMSeqDes := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_SEQDES"})
	nMMIteSol := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_ITESOL"})
	nMMProAlt := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_PROALT"})
	nMMNumLot := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_NUMLOT"})
	nMMLoteCt := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_LOTECT"})
	nMMDtVali := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_DTVALI"})
	nMMSolici := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GD5_SOLICI"})
Else
	HS_BDados("GAJ", @aHGaj, @aCGaj, @nUGaj, 1, M->GAI_SOLICI, "GAJ->GAJ_SOLICI == '" + M->GAI_SOLICI + "'")

	nGajIteSol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_ITESOL"})
	nGajQAtend := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_QATEND"})
	nGajQDevol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_QDEVOL"})
	nGAJQtdSol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_QTDSOL"})
	nGAJProSol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_PROSOL"})
	nGajDesPro := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DESPRO"})
	nGajCbMatm := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CBMATM"})
	nGajQtdAte := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_QTDATE"})
	nGajQtdDev := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_QTDDEV"})
	nGajCodJus := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CODJUS"})
	nGajJustif := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_JUSTIF"})
	nGajCodKit := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CODKIT"})
	nGajDesKit := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DESKIT"})
	nGajLoteFo := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_LOTEFO"})
	nGajLoteCt := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_LOTECT"})
	nGajNumLot := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_NUMLOT"})
	nGajDtVali := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DTVALI"})
	nGajProAlt := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_PROALT"})
	nGajDPrAlt := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DPRALT"})
	nGajCodCrm := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CODCRM"})  
	nGajDesCrm := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_NOMMED"})
	nGajCodPct := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CODPCT"})
	If lItePre
		nGajItePre := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_ITEPRE"})  
	Endif

	If aRotina[nOpcM05, 4] == 3
		aCGaj[1, nGajIteSol] := Soma1(aCGaj[1, nGajIteSol], Len(aCGaj[1, nGajIteSol]))
	EndIf 
EndIf 

aMatClone  := aClone(aCGaj) 

aSize := MsAdvSize(.T.)
aObjects := {}	
AAdd( aObjects, { 100, 040, .T., .T. } )	
AAdd( aObjects, { 100, 060, .T., .T. } )	
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
  
DEFINE MSDIALOG oDlgM05 TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  
	oEnchoice:= MsMGet():New(cAlias, RecNo()/*nRegM05*/, nOpcM05,,,, aCpos, aPObjs[1], IIf(aRotina[nOpcM05, 4] == 3, Nil, aCposAlt), 2)
	oEnchoice:oBox:align := CONTROL_ALIGN_TOP
  
	If nOpcM05 == 5 .Or. nOpcM05 == 6 // Devolucoes
		oGDMM := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,,,{"GD5_QDEVOL"},, Len(aCMM),,,,, aHMM, aCMM)
		oGDMM:oBrowse:align := CONTROL_ALIGN_ALLCLIENT                                   
   
	Else
		oGDGaj := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,, "+GAJ_ITESOL",IIF(nOpcM05==3, {"GAJ_QTDSOL"}, "") ,, 99999,,,,, aHGaj, aCGaj)
		oGDGaj:oBrowse:align := CONTROL_ALIGN_ALLCLIENT                                   
		If nOpcM05 == 4
			FS_VERTOT(oGDGaJ)
		Endif
	EndIf 
ACTIVATE MSDIALOG oDlgM05 ON INIT (FS_ATUREQ(nOpcM05),; // Solicitar e Atender
                                    EnchoiceBar(oDlgM05, {|| nOpcDlg := 1,IIF(ExistBlock("HM05TOK"),ExecBlock("HM05TOK", .F.,.F.,{cAliasM05, nRegM05, nOpcM05}) ,.T.) .AND. IIf( IIF( nOpcM05 == 5 .Or. nOpcM05 == 6,FS_VLDDEV(),(Obrigatorio(aGets, aTela) .And. oGDGaj:TudoOk() .And. FS_VerGuia() .And. HS_ValSet(oGDGaj, .T., nOpcM05) .And. Fs_VldSald(oGDGaj, nOpcM05))), oDlgM05:End(), nOpcDlg := 0)}, ;
                                                         {|| nOpcDlg := 0, oDlgM05:End()}))
 
If nOpcM05 <> 2 // Visualizar
	If     nOpcDlg == 0
		While __lSx8
			RollBackSxe()
		End
	ElseIf nOpcDlg == 1
		If nOpcM05 == 5 .Or. nOpcM05 == 6 
 
			If nOpcM05 == 5
				aSort(oGDMM:aCols,,, {| X, Y| X[nMMCodDes]  + X[nMMLoteCt] + X[nMMNumLot] + DToS(X[nMMDtVali]) ;
                                  < Y[nMMCodDes]  + Y[nMMLoteCt] + Y[nMMNumLot] + DToS(X[nMMDtVali]) })
			Else
				aSort(oGDMM:aCols,,, {| X, Y| X[nMMSolici] + X[nMMCodDes]  + X[nMMLoteCt] + X[nMMNumLot] + DToS(X[nMMDtVali]) ;
                                  < Y[nMMSolici] + Y[nMMCodDes]  + Y[nMMLoteCt] + Y[nMMNumLot] + DToS(X[nMMDtVali]) })
			Endif
    
			For nItens := 1 To Len(oGDMM:aCols)
				If nOpcM05 == 6 .And. cSolici <> oGDMM:aCols[nItens, nMMSolici]
					DbSelectArea("GAI")
					DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI 
					DbSeek(xFilial("GAI") + oGDMM:aCols[nItens, nMMSolici])
					cSolici := oGDMM:aCols[nItens, nMMSolici]
				EndIf
     
				If Rastro(oGDMM:aCols[nItens, nMMCodDes])
					If aScan(aMLocksSb8, oGDMM:aCols[nItens, nMMCodDes] + GAI->GAI_ALMORI + DToS(oGDMM:aCols[nItens, nMMDtVali]) + oGDMM:aCols[nItens, nMMLoteCt] + oGDMM:aCols[nItens, nMMNumLot]) == 0    
						aAdd(aMLocksSb8, oGDMM:aCols[nItens, nMMCodDes] + GAI->GAI_ALMORI + DToS(oGDMM:aCols[nItens, nMMDtVali]) + oGDMM:aCols[nItens, nMMLoteCt] + oGDMM:aCols[nItens, nMMNumLot])
					EndIf   
     
				ElseIf aScan(aMLocksSb2, oGDMM:aCols[nItens, nMMCodDes] + GAI->GAI_ALMORI) == 0
					aAdd(aMLocksSb2, oGDMM:aCols[nItens, nMMCodDes] + GAI->GAI_ALMORI)
				EndIf
     
				//Retirado para Nao Bloquear a SB3
				/*If aScan(aMLocksSb3, oGDMM:aCols[nItens, nMMCodDes]) == 0 
				aAdd(aMLocksSb3, oGDMM:aCols[nItens, nMMCodDes])
				EndIf  */
   
			Next

		Else                                                        
			aSort(oGDGaj:aCols,,, {| X, Y| X[nGajProSol] < Y[nGajProSol]})
    
			For nItens := 1 To Len(oGDGaj:aCols)
				cCodPMov := PadR(AllTrim(oGDGaj:aCols[nItens, IIf(lMV_ProdAlt .And. !Empty(oGDGaj:aCols[nItens, nGajProAlt]), nGajProAlt, nGajProSol)]), Len(SB1->B1_COD))
     
				If Rastro(cCodPMov)
					If aScan(aMLocksSb8, cCodPMov + GAI->GAI_ALMORI + DToS(oGDGaj:aCols[nItens, nGajDtVali]) + oGDGaj:aCols[nItens, nGajLoteCt] + oGDGaj:aCols[nItens, nGajNumLot]) == 0    
						aAdd(aMLocksSb8, cCodPMov + GAI->GAI_ALMORI + DToS(oGDGaj:aCols[nItens, nGajDtVali]) + oGDGaj:aCols[nItens, nGajLoteCt] + oGDGaj:aCols[nItens, nGajNumLot])
					EndIf   
     
				ElseIf aScan(aMLocksSb2, cCodPMov + GAI->GAI_ALMORI) == 0
					aAdd(aMLocksSb2, cCodPMov + GAI->GAI_ALMORI)
				EndIf
     
				//Retirado para Nao Bloquear a SB3
				/*If aScan(aMLocksSb3, cCodPMov) == 0
				aAdd(aMLocksSb3, cCodPMov)
				EndIf  */
			Next
		EndIf
  
		If MultLock("SB2", aMLocksSb2, 1) .And. MultLock("SB8", aMLocksSb8, 1) ///*.And. MultLock("SB3", aMLocksSb3, 1)*/ nao bloquear SB3
     
			If dDataBase <> Date()
				If MsgYesNo(STR0099, STR0008)
					dDatSolGrv := dDataBase
				Else
					dDatSolGrv := Date()
				EndIf  
			Else              
				If Type("M->GAI_DATSOL") <> "U"             
					dDatSolGrv := M->GAI_DATSOL
				EndIf    
			EndIf    
			Begin Transaction
   
				If nOpcM05 == 5 .Or. nOpcM05 == 6 // Devolucao
					cGbdNumDev := FS_DevM05(nOpcM05)
				Else
					FS_GrvM05(nOpcM05, aCGaj)
				EndIf          
    
			End Transaction 
     
			While __lSx8
				ConfirmSx8()
			End  
   
			If nOpcM05 == 5 .Or. nOpcM05 == 6 // Devolucao
				HSPAHR04(cGbdNumDev,cCodLoc_Far)
			Else  
				HSPAHR03(GAI->GAI_SOLICI,"","",cCodLoc_Far, aIAtend,cPlanoPart,cNrseqg)
				If ExistBlock("HSPHRAP03")
					Execblock("HSPHRAP03", .F., .F., {GAI->GAI_SOLICI})
				EndIf
			EndIf 
   
		EndIf 
	Endif
	If lMVLocUs .And. (nOpcM05 == 3 .Or. nOpcM05 == 4) // Solicitacao ou Atendimento
		UnLockByName(xFilial("GAI") + GAI->GAI_SOLICI , .T., .T., .F.)
		If ExistBlock("HSPDelFiCo")
			HSPDelFiCo("GAI",xFilial("GAI") + GAI->GAI_SOLICI)
		EndIf
	EndIf  
EndIf

DbSelectArea("GAI")
DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI 

SetKey(VK_F4, bKeyF4)
SetKey(VK_F5, bKeyF5)

Return(Nil)

Function HS_VldM05()
Local lRet    := .T., lVldGuia := .T.
Local cRegate := ""
Local aRetCon := {}
Local aArea    := GetArea()

If ReadVar() == "M->GAI_QATEND"
	lRet := HS_VQtdMM(M->GAI_QATEND)
	
ElseIf ReadVar() == "M->GCY_QATEND"
	lRet := HS_VQtdMM(M->GCY_QATEND)
	
ElseIf ReadVar() == "M->GAJ_CODJUS"
	If !Empty(M->GAJ_CODJUS) .And. !(lRet := HS_SeekRet("SX5", "'JV'+M->GAJ_CODJUS", 1, .F., "GAJ_JUSTIF", "X5_DESCRI"))
		HS_MsgInf(STR0017, STR0008, STR0001) //"Justificativa nao encontrada"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
	EndIf
	
ElseIf ReadVar() == "M->GD5_QDEVOL"
	dDatMov := dDatabase
	cHorMov := Time()
	cRegate := IIF(Type("M->GAI_REGATE") <> "U", M->GAI_REGATE, M->GCY_REGATE)
	
	aRetCon := HS_ConMed(cRegate, "", oGDMM:aCols[oGDMM:nAt, nMMSeqDes])
	
	DbSelectArea("GCZ")
	DbSetOrder(2) // GCZ_FILIAL + GCZ_REGATE + GCZ_STATUS + GCZ_NRSEQG
	lVldGuia := IIF(FunName() <> "HSPAHP12", HS_CountTB("GCZ", "GCZ_REGATE  = '" + cRegate + "' AND GCZ_STATUS IN " + IIf(Type("lOrigemM05")=="U","('0')","('0','1')") + " ")  > 0 ,.T.)
	
	If lVldGuia
		If !EMPTY(aRetCon[5])  //Tipo Alta
			If aRetCon[6] == "N" //Parametros LMMALTA/DEVALTA
				HS_MsgInf(STR0066, STR0008, STR0071) //"O atendimento jแ estแ em alta"##"Atencao"##"Dev. Despesa"
				lRet:=.F.
			Else
				dDatMov := aRetCon[3] //data da alta
				cHorMov := aRetCon[4] //hora alta
			Endif
		Endif
	Else
		HS_MsgInf(STR0069, STR0008, STR0070)//"Nใo existe nenhuma guia em aberto para este atendimento"##"Atencao"##"Inconsist๊ncia do status da guia"
		lRet := .F.
	Endif
	
	If lRet
		If !(lRet := !(dDatMov <  oGDMM:aCols[oGDMM:nAt, nMMDatDes] .Or. (dDatMov == oGDMM:aCols[oGDMM:nAt, nMMDatDes] .And. cHorMov < oGDMM:aCols[oGDMM:nAt, nMMHorDes])))
			HS_MsgInf(STR0073, STR0008, STR0061) //"A data da devolu็ใo nใo pode ser anterior a data do atendimento"###"Aten็ใo"###"Inconsist๊ncia de data/ hora"
		ElseIf !(lRet := !(dDatMov > dDataBase .Or. (dDatMov == dDataBase .And. cHorMov > Time())))
			HS_MsgInf(STR0072, STR0008, STR0061) //"A data da devolu็ใo nใo pode ser posterior a data corrente"###"Aten็ใo"###"Inconsist๊ncia de data/ hora"
		ElseIf !Empty(aRetCon[7]) .AND. !(lRet := !(!(dDatMov > aRetCon[7]))) //data ult. fech. estoque
			HS_MsgInf(STR0075, STR0008, STR0068) //"A Data da devolu็ใo ้ menor ou igual ao ๚ltimo fechamento de estoque, nใo serแ possํvel efetuar o lan็amento."###"###"Atencao"
		ElseIf (lRet := HS_VQtdMM(M->GD5_QDEVOL, .F., oGDMM:aCols[oGDMM:nAt, nMMCodDes]))
			If !(lRet := !(M->GD5_QDEVOL > oGDMM:aCols[oGDMM:nAt, nMMQtdDes]))
				HS_MsgInf(STR0018, STR0008, STR0071) //##"Quantidade informada maior que a quantidade lan็ada"###"Atencao"###"Dev. Despesa"
			ElseIf !Empty(aRetCon[11]) .And. (oGDMM:aCols[oGDMM:nAt, nMMQtdDes] - HS_VLCONFI(aRetCon[11],, oGDMM:aCols[oGDMM:nAt, nMMSeqDes],,.T.)[2] < M->GD5_QDEVOL)
				HS_MsgInf(STR0091, STR0008, STR0077) //"Quantidade solicitada nใo pode ser devolvida. Verifique as confirma็๕es de devolu็ใo em aberto para esta despesa."##"Atencao"##"Devolu็ใo mat/med"
				lRet := .F.
			Else
				If Type("nMMStaReg") # "U" .And. nMMStaReg > 0
					HS_GDAtrib(oGDMM, {{nMMStaReg, "BR_AMARELO", "BR_VERDE"}})
				EndIf
				If M->GD5_QDEVOL == 0
					oGDMM:aCols[oGDMM:nAt, Len(oGDMM:aHeader) + 1] := .F.
				ElseIf M->GD5_QDEVOL == oGDMM:aCols[oGDMM:nAt, nMMQtdDes]
					oGDMM:aCols[oGDMM:nAt, Len(oGDMM:aHeader) + 1] := .T.        //Deleta Linha
				EndIf
				oGDMM:oBrowse:Refresh()
			EndIf
		EndIf
	Endif
EndIf
RestArea(aArea)
Return(lRet)

Function HS_M05VMM(cProSol, nOpcM05, nQtdKit, lBarKit)
 Local cProEst := IIf(Empty(__cProAlt), cProSol, __cProAlt)
 Local cProVld := IIF(nOpcM05 <> 6, M->GAI_CBMATM, M->GCY_CBMATM)
 Local cAlmOri := IIF(nOpcM05 <> 6, M->GAI_ALMORI, HS_IniPadr("GCS", 1, cSetor, "GCS_ARMFAR",, .F.))
 Local nPosGD  := 0, nForACols := 0, nQtdJaDev := 0, nItens := 1, nPosAten := 0
 Local lNovLin := (GETMV("MV_NLINFAR",,"0") == "1")
 Local lLote   := .T.
 Local nQtdAte := 0
 Local nIndSB8 := 2
 Local nIndSB1 := 5 //B1_CODBAR
 Local nQtdVld := 0
 Local aConEst := {}, aValDat := {}
 Local cMessage := ""
 
 Local lReti    := .F. 
 Default nQtdKit := 0
 Default lBarKit := .F.
 
 If Empty(cProVld)  .And. !lBarKit //nao utilizou o campo GAI_CBMATM
 	If Hs_ExisDic({{"C","GAI_INDCBL"}}) .And. Type("M->GAI_INDCBL") <> "U" 
   		nIndSB8 := VAL(M->GAI_INDCBL)
  	ElseIf Hs_ExisDic({{"C","GCY_INDCBL"}}) .And. Type("M->GCY_INDCBL") <> "U" 
   		nIndSB8 := VAL(M->GCY_INDCBL)
  	EndIf 
  	
  	If nIndSB8=6
		 __cLoteFo :=aVetDados[1][2]
		 __cLoteCt :=aVetDados[1][3]
		 __cNumLot :=aVetDados[1][1]
		 __dDtVali:= STOD(aVetDados[1][4])						
		  lReti    := .F.  
	EndIf  
  
  	If  lReti = .T. 
  		If !HS_SeekRet("SB8", "'" + (HS_RCBLote(AllTrim(IIF(nOpcM05 <> 6, M->GAI_CBLOTE, M->GCY_CBLOTE)), cAlmOri, nIndSB8)) + "'", IIF(nIndSB8 == 5, 1, nIndSB8), .F.) .and.!(lRet)
  			HS_MsgInf(STR0092, STR0008,STR0093)//"Lote nใo encontrado"##"Atencao"##"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
  			Return(.F.)
  		Endif 
  	Else
  		If nIndSB8=6	 
  			DbSelectArea("SB1")
			DbSetOrder(1) // B1_FILIAL + B1_COD 
  			DbSeek(xFilial("SB1") + cProEst)
  			cProVld := SB1->B1_COD
  			nIndSB1 := 1
 		Else
			cProVld := SB8->B8_PRODUTO
 			nIndSB1 := 1 //B1_COD
 		endif
	  
 	EndIf
 EndIf 
 
 cProVld := IIf(lBarKit, cProsol, cProVld)

 M->GAJ_PROALT := __cProAlt
                  
 //Valida็ใo do codigo barras digitado
 If !HS_SeekRet("SB1", "'" + cProVld + "'", nIndSB1, .F.)
		If HS_SeekRet("GAP", "'" + cProVld + "'", 1, .F.)
			If !HS_SeekRet("SB1", "GAP->GAP_CODIGO", 1, .F.)
				HS_MsgInf(STR0087, STR0088, STR0089) //"Produto cadastrado no c๓digo de barras secundario nใo existe no cadastro"###"Aten็ใo"###"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
				Return(.F.)
			EndIf
		Else
			HS_MsgInf(STR0090, STR0088, STR0089) //"Produto nใo encontrado com este c๓digo de barras"###"Aten็ใo"###"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
			Return(.F.)
		Endif
	Endif

	cProVld := SB1->B1_COD
 
 aConEst := HS_CONEST(SB1->B1_COD, __cCtrEst)
  
 lLote   := (IIF(__cRequis == "2", .T., aConEst[1])) .And. Rastro(SB1->B1_COD)

 If nOpcM05 == 3 // 3-Solicita็ใo
  If lLote
   nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + aVet[nGajNumLot] + DToS(aVet[nGajDtVali]) == cProSol + __cLoteFo + __cLoteCt + __cNumLot + DToS(__dDtVali)})
  Else 
   nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol]   == cProSol .and. Empty(aVet[ nGajCodKit])})
  Endif 
  nPosGD := IIf(nPosGD == 0, aScan(oGDGaj:aCols, {| aVet | Empty(aVet[nGajProSol])}), nPosGD)

  If HS_VldM04(IIf(Empty(M->GAJ_PROALT), "M->GAJ_PROSOL", "M->GAJ_PROALT"))
   If !HS_M04Kit(cProEst, M->GAI_QATEND, .T., M->GAI_ALMORI, __cRequis) .And. IIf(aConEst[1] .Or. __cRequis $ "2/3" , HS_M05VSld(cProEst, M->GAI_ALMORI, FS_QTDVAL(cProsol, nPosGD, lLote, lNovLin),__cLoteFo, __cLoteCt, __cNumLot, __dDtVali), .T.)
    If nPosGD == 0 .Or. (!Empty(oGDGaj:aCols[nPosGD, nGajProsol]) .And. lNovLin)
     oGDGaj:AddLine(.T.,.F.)
     oGDGaj:lNewLine := .F.
     nPosGD := Len(oGDGaj:aCols)
    EndIf 

    If Empty(oGDGaj:aCols[nPosGD, nGajProSol])
     oGDGaj:aCols[nPosGD, nGajQtdSol] := 0
     oGDGaj:aCols[nPosGD, nGajLoteFo] := IIf(lLote, __cLOTEFO, Space(len(GAJ->GAJ_LOTEFO)))
     oGDGaj:aCols[nPosGD, nGajLoteCt] := IIf(lLote, __cLOTECT, Space(len(GAJ->GAJ_LOTECT)))
     oGDGaj:aCols[nPosGD, nGajNumLot] := IIf(lLote, __cNUMLOT, Space(len(GAJ->GAJ_NUMLOT)))
     oGDGaj:aCols[nPosGD, nGajDtVali] := IIf(lLote, __dDTVALI, CriaVar("GAJ_DTVALI"))
    Endif
    If oGDGaj:aCols[nPosGD, nUGAJ+1]
     oGDGaj:aCols[nPosGD, nUGAJ+1]    := .F.
     oGDGaj:aCols[nPosGD, nGajQAtend] := 0
     oGDGaj:aCols[nPosGD, nGajQtdSol] := 0 
     oGDGaj:aCols[nPosGD, nGajQtdAte] := 0
    Endif 
    oGDGaj:aCols[nPosGD, nGajQAtend] += M->GAI_QATEND
    oGDGaj:aCols[nPosGD, nGajQtdSol] += M->GAI_QATEND
    oGDGaj:aCols[nPosGD, nGajProSol] := M->GAJ_PROSOL
    oGDGaj:aCols[nPosGD, nGajDesPro] := Posicione("SB1", 1, xFilial("SB1") + M->GAJ_PROSOL, "B1_DESC")
    oGDGaj:aCols[nPosGD, nGajQtdAte] += M->GAI_QATEND
    oGDGaj:aCols[nPosGD, nGajCbMatm] := Posicione("SB1", 1, xFilial("SB1") + M->GAJ_PROSOL, "B1_CODBAR")
    If GetMV("MV_ATCRMD") == "S"
    oGDGaj:aCols[nPosGD, nGajCodCrm] := M->GAI_CRMPRE
    oGDGaj:aCols[nPosGD, nGajDesCrm] :=Posicione('SRA', 11, xFilial("SB1") + M->GAI_CRMPRE, 'RA_NOME')                               
    Endif

    oGDGaj:aCols[nPosGD, nGajProAlt] := IIf(Empty(M->GAJ_PROALT), Space(Len(SB1->B1_COD)), M->GAJ_PROALT)
    oGDGaj:aCols[nPosGD, nGajDPrAlt] := IIf(Empty(M->GAJ_PROALT), Space(Len(SB1->B1_DESC)), HS_INIPADR("SB1",1, M->GAJ_PROALT, "B1_DESC",,.F.))

   Endif 
   dDatMov := M->GAI_DATSOL
   cHorMov := M->GAI_HORSOL
   M->GAI_CBMATM := Space(len(M->GAI_CBMATM))
   M->GAI_CBLOTE := Space(len(M->GAI_CBLOTE))
   M->GAI_QATEND := CriaVar("GAI_QATEND")  
   __MMQtdDe   := M->GAI_QATEND 
   __cLOTEFO   := Space(Len(GAJ->GAJ_LOTEFO))
   __cLOTECT   := Space(Len(GAJ->GAJ_LOTECT))
   __cNUMLOT   := Space(Len(GAJ->GAJ_NUMLOT))
   __dDTVALI   := CriaVar("GAJ_DTVALI") 
   __cProAlt   := Space(Len(GAJ->GAJ_PROALT))

   oEnchoice:Refresh()
   oGDGaj:oBrowse:Refresh()
  EndIf                 
 
 ElseIf nOpcM05 == 4 // 4-Atendimento de solicita็ใo
  If lLote
   nPosGD := FS_VldLote(cProVld)
  ElseIf (nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProAlt] == PADR(cProVld, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt])) .And. aVet[nGajQtdSol] > aVet[nGajQtdAte] .And. !aVet[nUGaj + 1]})) == 0   
   nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] == PADR(cProVld, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProSol])) .And. aVet[nGajQtdSol] > aVet[nGajQtdAte] .And. Empty(aVet[nGajProalt]) .And. !aVet[nUGaj + 1]})
  Endif 
  
  nQtdAte := IIf(lBarKit, nQtdKit, M->GAI_QATEND)
  
   If Empty(GAJ->GAJ_PROALT)
 	cProEst:=cProVld  
  	M->GAJ_PROALT:=Space(Len(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt]))  	
   Endif
  If !lBarKit .And. nPosGd > 0
   nPosAten := aScan(__aVldSld, {| aVet | aVet[1] + aVet[2] + aVet[3] + aVet[4] + aVet[5]  == cProEst + __cLoteFo + __cLoteCt + __cNumLot + DToS(__dDtVali)})
   nQtdVld  := IIF(nPosAten > 0, __aVldSld[nPosAten, 6] + nQtdAte, oGDGaj:aCols[nPosGD, nGajQAtend] + nQtdAte)
  Endif
  If nPosGD == 0 
   HS_MsgInf(STR0019, STR0008, STR0001) //"###"Produto nao encontrado na solicita็ao"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"   
  ElseIf IIf(!lBarKit, nQtdAte > (oGDGaj:aCols[nPosGD, nGajQtdSol] - oGDGaj:aCols[nPosGD, nGajQtdAte]), .F.)
   HS_MsgInf(STR0020, STR0008, STR0001) //"###"Quantida informada e maior que a quantidade solicitada"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"   
 	ElseIf IIf(!lBarKit, HS_ValDat(nOpcM05,M->GAI_REGATE,,,,STR0079, cProVld)[1] .AND. HS_M05VSld(cProEst, M->GAI_ALMORI, nQtdVld, __cLoteFo, __cLoteCt, __cNumLot, __dDtVali), .T.)
 	 
  If !lBarkit 
   If nPosAten == 0 
    AAdd(__aVldSld,{cProEst, __cLoteFo, __cLoteCt, __cNumLot, DToS(__dDtVali), oGDGaj:aCols[nPosGD, nGajQAtend] + nQtdAte})
   Else 
    __aVldSld[nPosAten, 6] += nQtdAte
   Endif    
  Endif
   
   oGDGaj:aCols[nPosGD, nGajQAtend] += nQtdAte
   oGDGaj:aCols[nPosGD, nGajQtdAte] += nQtdAte
    
   If IIF(!lBarKit, HS_SLotBlq(cProEst, cAlmOri, __cLOTECT, __cNUMLOT, SB8->B8_SALDO, oGDGaj:aCols[nPosGD, nGajQtdAte]), .F.)
 		 HS_MsgInf(STR0094, STR0008,STR0095 ) //"Lote com bloqueio de saldo (SDD)"##"Atencao"##"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
 		 Return(.F.)
   EndIf

   If oGDGaj:aCols[nPosGD, nGajQtdAte] == oGDGaj:aCols[nPosGD, nGajQtdSol]
    oGDGaj:aCols[nPosGD, nUGaj + 1] := .T.
   EndIf
   
   If Empty(oGDGaj:aCols[nPosGD, nGajLoteFo]) .Or. Empty(oGDGaj:aCols[nPosGD, nGajLoteCt]) .Or. Empty(oGDGaj:aCols[nPosGD, nGajNumLot])
    oGDGaj:aCols[nPosGD, nGajLoteFo] := __cLOTEFO
    oGDGaj:aCols[nPosGD, nGajLoteCt] := __cLOTECT
    oGDGaj:aCols[nPosGD, nGajNumLot] := __cNUMLOT
    oGDGaj:aCols[nPosGD, nGajDtVali] := __dDTVALI
   Endif
   
   If !lBarKit .and. Empty(oGDGaj:aCols[nPosGD, nGajProAlt])   
      oGDGaj:aCols[nPosGD, nGajProAlt] := IIf(Empty(M->GAJ_PROALT), SB1->B1_COD, M->GAJ_PROALT)
      oGDGaj:aCols[nPosGD, nGajDPrAlt] := IIf(Empty(M->GAJ_PROALT), SB1->B1_DESC, HS_INIPADR("SB1",1, M->GAJ_PROALT, "B1_DESC",,.F.))
   
 	   If oGDGaj:aCols[nPosGD, nGajProSol] == oGDGaj:aCols[nPosGD, nGajProAlt]
          oGDGaj:aCols[nPosGD, nGajProAlt] :=Space(Len(SB1->B1_COD))
          oGDGaj:aCols[nPosGD, nGajDPrAlt] :=Space(Len(SB1->B1_DESC))
       EndIf
   Endif
   
   M->GAI_CBMATM := Space(len(M->GAI_CBMATM))
   M->GAI_CBLOTE := Space(len(M->GAI_CBLOTE))
   M->GAI_QATEND := CriaVar("GAI_QATEND")     
   __cLOTEFO   := Space(Len(GAJ->GAJ_LOTEFO))
   __cLOTECT   := Space(Len(GAJ->GAJ_LOTECT))
   __cNUMLOT   := Space(Len(GAJ->GAJ_NUMLOT))
   __dDTVALI   := CriaVar("GAJ_DTVALI")       
                                       
   oGDGaj:oBrowse:nAt := nPosGD
   oGDGaj:oBrowse:Refresh()
  
  EndIf

 ElseIf nOpcM05 == 5 // Devolucao por Solic.
  If __lCBLote
   If (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMProalt] + aVet[nMMLoteCt]+ aVet[nMMNumLot] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMProalt])) + __cLoteCT + __cNumLot .And. !aVet[nUMM + 1] })) == 0 
    If (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMCodDes] + aVet[nMMLoteCt]+ aVet[nMMNumLot] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMCodDes])) + __cLoteCT + __cNumLot .And. Empty(aVet[nMMProalt]) .And. !aVet[nUMM + 1] })) == 0 
     HS_MsgInf(STR0046, STR0008,STR0001) //"Atencao"###"Lote nao encontrado na solicitacao"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"    
    Endif
   Endif
  ElseIf (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMProalt] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMProalt])) .And. !aVet[nUMM + 1]})) == 0
   If (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMCodDes] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMCodDes])) .And. Empty(aVet[nMMProalt]) .And. !aVet[nUMM + 1]})) == 0
    HS_MsgInf(STR0019, STR0008,STR0001) //"###"Produto nao encontrado na solicita็ao"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
   Endif
  Endif
  
  If nPosGD > 0 .AND. (HS_ValDat(nOpcM05,M->GAI_REGATE,oGDMM:aCols[nPosGD, nMMDatDes],oGDMM:aCols[nPosGD, nMMHordes],oGDMM:aCols[nPosGD, nMMSeqDes], STR0078, cProVld, M->GAI_QATEND, oGDMM:aCols[nPosGD, nMMQDevol])[1])
   If M->GAI_QATEND > (oGDMM:aCols[nPosGD, nMMQtdDes] - oGDMM:aCols[nPosGD, nMMQDevol])
    HS_MsgInf(STR0021, STR0008, STR0001) //"###"Quantida informada e maior que a quantidade atendida"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
   Else
    oGDMM:aCols[nPosGD, nMMQDevol] += M->GAI_QATEND
   Endif
    
   If oGDMM:aCols[nPosGD, nMMQtdDes] == oGDMM:aCols[nPosGD, nMMQDevol]
    oGDMM:aCols[nPosGD, Len(oGDMM:aHeader) + 1] := .T.
   EndIf
   
   M->GAI_CBMATM := Space(len(M->GAI_CBMATM))
   M->GAI_CBLOTE := Space(len(M->GAI_CBLOTE))
                                             
   oGDMM:oBrowse:nAt := nPosGD
   oGDMM:oBrowse:Refresh()
  EndIf
 ElseIf nOpcM05 == 6 // Devolucao por Atend.
  If __lCBLote
   If (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMProalt] + aVet[nMMLoteCt]+ aVet[nMMNumLot] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMProalt])) + __cLoteCT + __cNumLot .And. !aVet[nUMM + 1] })) == 0 
    If (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMCodDes] + aVet[nMMLoteCt]+ aVet[nMMNumLot] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMCodDes])) + __cLoteCT + __cNumLot .And. Empty(aVet[nMMProalt]) .And. !aVet[nUMM + 1] })) == 0 
     HS_MsgInf(STR0046, STR0008,STR0001) //"###"Lote nao encontrado na solicitacao"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
    Endif
   Endif
  ElseIf (nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMProalt] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMProalt])) .And. !aVet[nUMM + 1]})) == 0
   If(nPosGD := aScan(oGDMM:aCols, {| aVet | aVet[nMMCodDes] == PADR(cProVld, Len(oGDMM:aCols[oGDMM:nAt, nMMCodDes])) .And. Empty(aVet[nMMProalt]) .And. !aVet[nUMM + 1]})) == 0
    HS_MsgInf(STR0019, STR0008, STR0001) //"###"Produto nao encontrado na solicita็ao"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
   Endif
  Endif

  If nPosGD > 0
   If M->GCY_QATEND > FS_TotQDev(cProSol, lLote, oGDMM:aCols[nPosGD, nMMLoteCt], oGDMM:aCols[nPosGD, nMMNumLot], oGDMM:aCols[nPosGD, nMMDtVali], __cProAlt)
    HS_MsgInf(STR0021, STR0008, STR0001) //"Atencao"###"Quantida informada e maior que a quantidade atendida"
   Else
    While nQtdJaDev < M->GCY_QATEND .And. nItens <= Len(oGDMM:aCols)
     
     If __lCBLote
          If !(!oGDMM:aCols[nItens, nUMM+1] .And. oGDMM:aCols[nItens, nMMLoteCt] == SB8->B8_LOTECTL ;
                                                        .And. oGDMM:aCols[nItens, nMMNumLot] == SB8->B8_NUMLOTE ;
                                                        .And. oGDMM:aCols[nItens, nMMDtVali] == SB8->B8_DTVALID)

 		 		nItens ++
 		 		Loop 
 		  Endif 


 	ElseIf !oGDMM:aCols[nItens, nUMM+1] .And. oGDMM:aCols[nItens, nMMCodDes] <> cProSol .Or. oGDMM:aCols[nItens, nMMProalt] <> __cProAlt  
 		 	 nItens ++
 		 	 Loop
   Endif 		 
     
     aValDat := HS_ValDat(nOpcM05,M->GCY_REGATE, oGDMM:aCols[nItens, nMMDatDes], oGDMM:aCols[nItens, nMMHordes], oGDMM:aCols[nItens, nMMSeqDes], STR0078, cProVld, IIF((M->GCY_QATEND - 	nQtdJaDev) > oGDMM:aCols[nItens, nMMQtdDes] - oGDMM:aCols[nItens, nMMQDevol], oGDMM:aCols[nItens, nMMQtdDes] - oGDMM:aCols[nItens, nMMQDevol], (M->GCY_QATEND - nQtdJaDev )), oGDMM:aCols[nItens, nMMQDevol], .F.)
          
     If  aValDat[1]
      If oGDMM:aCols[nItens, nMMQtdDes] > oGDMM:aCols[nItens, nMMQDevol]
			 	 	If oGDMM:aCols[nItens, nMMQtdDes] - oGDMM:aCols[nItens, nMMQDevol] > M->GCY_QATEND - nQtdJaDev
 		 	 		oGDMM:aCols[nItens, nMMQDevol] += M->GCY_QATEND - nQtdJaDev
			 	 		nQtdJaDev += M->GCY_QATEND - nQtdJaDev
			 	 	Else
 		 	 		nQtdJaDev += oGDMM:aCols[nItens, nMMQtdDes] - oGDMM:aCols[nItens, nMMQDevol] 
			 	 		oGDMM:aCols[nItens, nMMQDevol] += oGDMM:aCols[nItens, nMMQtdDes] - oGDMM:aCols[nItens, nMMQDevol] 
			 	 	EndIf	
		     If oGDMM:aCols[nItens, nMMQtdDes] == oGDMM:aCols[nItens, nMMQDevol]
        oGDMM:aCols[nItens, Len(oGDMM:aHeader) + 1] := .T.
       EndIf
			 	 EndIf
			 	Else
			 	 cMessage += STR0096 + ALLTRIM(oGDMM:aCols[nItens, nMMSeqDes]) + STR0097 + aValDat[2] + IIF(nItens < Len(oGDMM:aCols), CHR(13) + CHR(10), "")    //"Sequencial de despesa ["##"] apresentou a seguinte inconsist๊ncia: "
			 	Endif 
			 	 nItens ++
			 EndDo	
     
    If !Empty(cMessage)
     HS_MsgInf(cMessage, STR0008, STR0077) //"Aten็ใo"##"Devolu็ใo mat/med" 
    Endif
    M->GCY_CBMATM := Space(len(M->GCY_CBMATM))
    M->GCY_CBLOTE := Space(len(M->GCY_CBLOTE))
                                             
    oGDMM:oBrowse:nAt := nItens - 1
    oGDMM:oBrowse:Refresh()
   
   Endif
  EndIf
 
 EndIf
 
Return(.F.)

Function HS_M05VSld(cProSol, cAlmOri, nQAtend, cLoteFo, cLoteCt, cNumLot, dDtVali, lMosMsg)
 Local lRet := .T., aArea := GetArea()
 Local cEstNeg := GETMV("MV_ESTNEG")
 Default lMosMsg := .T. 
  
 If Empty(cLoteFo) .And. Empty(cLoteCt) .And. Empty(cNumLot) .AND. cEstNeg <> "S"
  DbSelectArea("SB2")
  DbSetOrder(1)   //B2_FILIAL + B2_COD + B2_LOCAL
  If     !(lRet := DbSeek(xFilial("SB2") + cProSol + cAlmOri))
   If lMosMsg
    HS_MsgInf(STR0022 + AllTrim(cProSol) + STR0023 + cAlmOri + "] (SB2)", STR0008, STR0001) //"###"Item ["###" ] nao possui saldo cadastrado para o armazem ["###"Atencao"###//"Atendimento de solicita็oes Mat/Med"   
   Endif
  ElseIf !(lRet := ((SB2->B2_QATU-SB2->B2_QACLASS-SB2->B2_RESERVA-SB2->B2_QTNP) >= IIf(M->GAI_REQUIS == "1" .OR. (SB1->B1_CONV == 0) , nQAtend, ConvUm(cProSol, nQAtend, 0, 2))))
   If lMosMsg
    HS_MsgInf(STR0022 + AllTrim(cProSol) + STR0024 + cAlmOri + "] (SB2)", STR0008,STR0001) //"###"Item ["###" ] nao possui saldo suficiente no armazem ["###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
   Endif 
  EndIf

 ElseIf Rastro(cProsol) .AND. cEstNeg <> "S" 
  DbSelectArea("SB8")
  DbSetOrder(1) // B8_FILIAL + B8_PRODUTO + B8_LOCAL + DTOS(B8_DTVALID) + B8_LOTECTL + B8_NUMLOTE 
  If     !(lRet := DbSeek(xFilial("SB8") + cProSol + cAlmOri + DToS(dDtVali) + cLoteCt + cNumLot))
   If lMosMsg
    HS_MsgInf(STR0022 + AllTrim(cProSol) + STR0023 + cAlmOri + "] (SB8)", STR0008, STR0001) //"###"Item ["###" ] nao possui saldo cadastrado para o armazem ["###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
   Endif
  ElseIf !(lRet := (SB8->B8_SALDO - SB8->B8_EMPENHO >= IIf(M->GAI_REQUIS == "1" .OR. (SB1->B1_CONV == 0), nQAtend, ConvUm(cProSol, nQAtend, 0, 2))))
   If lMosMsg
    HS_MsgInf(STR0022 + AllTrim(cProSol) + STR0024 + cAlmOri + "] (SB8)", STR0008, STR0001) //"###"Item ["###" ] nao possui saldo suficiente no armazem ["###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
   Endif
  EndIf   
   
 Endif           
 
 RestArea(aArea)
Return(lRet)
                                    
Function FS_GrvM05(nOpcM05, aCols)
Local nTQtdAte	:= 0, nTQtdSol := 0, nPosKit := 0, nQtSegUM := 0, nPosGaj := 0
Local cCodPMov	:= "", cDPrPMov := "", nItens := 0, nIteAuto := 0
Local lMovEst	:= .F.
Local lAchouKit := .F.
Local aCabAuto 	:= {}, aIteAuto := {}
Local lRet		:=.F.
Local lErro		:= .F.
Local lDel		:= .T.
Local lAtSolPA	:= GetNewPar("MV_ATSOLPA",.F.)
Local lPeHSREGSD3 := ExistBlock("HSREGSD3")

DbSelectArea("GCS")
DbSetOrder(1) // GCS_FILIAL + GCS_CODLOC
DbSeek(xFilial("GCS") + M->GAI_CODLOC)

DbSelectArea("GAI")
DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI
If aRotina[nOpcM05, 4] == 3
	M->GAI_SOLICI := HS_VSxeNum("GAI", "M->GAI_SOLICI", 1)
	ConfirmSx8()
	
	RecLock("GAI", .T.)
	HS_GrvCpo("GAI")
	GAI->GAI_DATSOL := dDatSolGrv
	GAI->GAI_HORSOL := Time()
	GAI->GAI_FILIAL := xFilial("GAI")
	GAI->GAI_FLGATE := ""
	GAI->GAI_LOGARQ := HS_LogArq()
	MsUnLock()
EndIf

For nItens := 1 To Len(oGDGaj:aCols)
	cCodPMov := PadR(AllTrim(oGDGaj:aCols[nItens, IIf(lMV_ProdAlt .And. !Empty(oGDGaj:aCols[nItens, nGajProAlt]), nGajProAlt, nGajProSol)]), Len(SB1->B1_COD))
	cDPrPMov := oGDGaj:aCols[nItens, IIf(lMV_ProdAlt .And. !Empty(oGDGaj:aCols[nItens, nGajProAlt]), nGajDPrAlt, nGajDesPro)]
	If oGDGaj:aCols[nItens, nGajQAtend] > 0 .AND. IIf(nOpcM05 == 3, !oGDGaj:aCols[nItens, nUGAJ+1], .T.) .And. Ascan(__aVldSld,{ |x| x[1] == cCodPMov}) == 0
		
		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL + B1_COD
		DbSeek(xFilial("SB1") + cCodPMov)
		
		
		
		If M->GAI_REQUIS == "3" // Transferencia entre armazens
			lMovEst := a260Processa(cCodPMov, M->GAI_ALMORI, oGDGaj:aCols[nItens, nGajQAtend], M->GAI_SOLICI, dDataBase, IIF(  SB1->B1_CONV == 0,oGDGaj:aCols[nItens, nGajQAtend],ConvUm(cCodPMov, oGDGaj:aCols[nItens, nGajQAtend], 0, 2)), ;
			oGDGaj:aCols[nItens, nGajNumLot], oGDGaj:aCols[nItens, nGajLoteCt], oGDGaj:aCols[nItens, nGajDtVali], SB1->B1_SERIE, SB1->B1_LOCPAD, ;
			cCodPMov, M->GAI_ALMSOL, SB1->B1_LOCPAD, .F.,,, "MATA260")
			
			If lMovest
				HS_GRVGAJ(nItens,,,"")
			Endif
			
		Else
			
			If (M->GAI_REQUIS == "1" .And. HS_CONEST(SB1->B1_COD, M->GAI_CODLOC)[1]) .Or. M->GAI_REQUIS == "2"
				
				nQtSegUM := ConvUm(cCodPMov, oGDGaj:aCols[nItens, nGajQAtend], 0, 2)
				
				aAdd(aPosGaj, {nItens})
				
				nIteAuto := len(aIteAuto) + 1
				
				aAdd(aIteAuto, {{"D3_COD"    , SB1->B1_COD, NIL},{"D3_UM"     , SB1->B1_UM , NIL}, {"D3_QUANT"  , oGDGaj:aCols[nItens, nGajQAtend]  , NIL},;
				{"D3_LOCAL"  , M->GAI_ALMORI    , NIL}, {"D3_USUARIO", cUserName   , NIL}})
				
				
				If lPeHSREGSD3
 					cREGATEN := ExecBlock("HSREGSD3", .F., .F., {M->GAI_REGATE, M->GAI_REQUIS	})
 					aAdd(aIteAuto[nIteAuto], {"D3_REGATEN"    , cREGATEN , Nil})
		   	   	Else
		   			If !Empty(M->GAI_REGATE)
						aAdd(aIteAuto[nIteAuto], {"D3_REGATEN"    , M->GAI_REGATE , Nil})
					Endif
				EndIf
				
				If !Empty(SB1->B1_SEGUM) .And. nQtSegUM > 0
					aAdd(aIteAuto[nIteAuto], {"D3_SEGUM"  , SB1->B1_SEGUM, NIL})
					aAdd(aIteAuto[nIteAuto], {"D3_QTSEGUM", nQtSegUM     , NIL})
				EndIf
				
				If Rastro(cCodPMov)
					aAdd(aIteAuto[nIteAuto], {"D3_NUMLOTE", oGDGaj:aCols[nItens, nGajNumLot], NIL})
					aAdd(aIteAuto[nIteAuto], {"D3_LOTECTL", oGDGaj:aCols[nItens, nGajLoteCt], NIL})
					aAdd(aIteAuto[nIteAuto], {"D3_DTVALID", oGDGaj:aCols[nItens, nGajDtVali], NIL})
				EndIf
				
			ElseIf M->GAI_REQUIS == "1"
				FS_GrvMM("", "", nItens)
			EndIf
		Endif
	Else
		If oGDGaj:aCols[nItens, nGajQAtend] == 0 .And. !Empty(oGDGaj:aCols[nItens, nGajNumLote])
			If (nPosItem := aScan(aCols, {| aVet | aVet[nGajIteSol]  == oGDGaj:aCols[nItens, nGajIteSol] })) > 0
				If aCols[nPosItem, nGajQtdSol] <> oGDGaj:aCols[nItens, nGajQtdSol]
					
					DbSelectArea("GAJ")
					DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
					DbSeek(xFilial("GAJ") + M->GAI_SOLICI + oGDGaj:aCols[nItens, nGajIteSol])
					RecLock("GAJ", .F.)
					GAJ->GAJ_QTDSOL := oGDGaj:aCols[nItens, nGajQtdSol]
					MsUnlock()
				Endif
			Endif
		Endif
	EndIf
	
	nTQtdAte += oGDGaj:aCols[nItens, nGajQtdAte]
	nTQtdSol += oGDGaj:aCols[nItens, nGajQtdSol]
Next

If !Empty(aIteAuto)
	aAdd(aCabAuto,{"D3_TM"       , IIF(M->GAI_REQUIS == "2", GetMV("MV_TPMADM"), GetMv("MV_TPMVSA"))									, Nil})
	aAdd(aCabAuto,{"D3_CC"       , GCS->GCS_CODCCU																						, Nil})
	aAdd(aCabAuto,{"D3_EMISSAO"  , IIF(M->GAI_REQUIS == "2", dDataBase, IIF(M->GAI_REQUIS == "1" .And. lAtSolPA, dDataBase, dDatMov))	, Nil})
	
	HS_MovEst(,,,,,,,,,,,,,M->GAI_REGATE, aCabAuto, aIteAuto, @lErro)
	
Endif

If !Empty(aKitVirt)
	DbSelectArea("GHI")
	DbSetOrder(1) // GHI_FILIAL + GHI_SEQKIT
	For nPosKit := 1 to len(aKitVirt)
		DbSeek(xFilial("GHI")+ aKitVirt[nPosKit, 1])
		RecLock("GHI", .F.)
		GHI->GHI_SOLICI := aKitVirt[nPosKit, 2]
		MsUnLock()
	Next nPosKit
Endif

If !lErro
	DbSelectArea("GAI")
	DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI
	If DbSeek(xFilial("GAI") + M->GAI_SOLICI)
		RecLock("GAI", .F.)
		If nTQtdAte == 0
			GAI->GAI_FLGATE := "0" // Nใo Atendida
		ElseIf nTQtdAte > 0 .And. nTQtdAte < nTQtdSol //.and. !lRet
			GAI->GAI_FLGATE := "1" // Atendimento parcial
		Else
			GAI->GAI_FLGATE := "2" // Atendimento total
		EndIf
		
		If GAI->GAI_FLGATE < "2"
			If Pergunte(cPerg1,.T.) .And. MV_PAR01 == 2
				If GAI->GAI_FLGATE == "1"
					GAI->GAI_FLGATE := "3" // Atendimento pacial fechado
				ElseIf GAI->GAI_FLGATE == "0"
					GAI->GAI_FLGATE := "4" // Atendimento Encerrado
				Endif
				GAI->GAI_CODENC := MV_PAR02
			EndIf
		EndIf
		MsUnLock()
	EndIf
EndIf

If M->GAI_FLGATE =='1'
	FS_ItSol(oGDGaj)
Endif   

If lErro
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifico se existe item da solicitacao, pois se existir a solicitacaoณ
	//ณeh proveniente de um atendimento, e se nao existir a solicitacao foi ณ
	//ณfeita direto na farmacia.                                            ณ
	//ณQuando a mesma eh feita direta na farmacia, pode ser excluida, caso  ณ
	//ณcontrario permanecera em aberto.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("GAJ")
	DbSetOrder(1)
	If DbSeek(xFilial("GAJ") + M->GAI_SOLICI)
		lDel := .F.
	EndIf
	DbSelectArea("GAI")
	DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI
	If DbSeek(xFilial("GAI") + M->GAI_SOLICI) .And. lDel
		RecLock("GAI", .F.)
		GAI->( DbDelete() ) 
		MsUnLock()
	EndIf
EndIf

Return(.T.)

Static Function FS_GrvMM(cD3NumSeq, cD3Doc, nItens, lDelete)
Local aArea    := GetArea()
Local aRValDes := {}
Local aRValTD  := {}
Local nPresc   := 0
Local cGa9TipCon:=""
Local cConpart:=""
Local cRegate:=""
local cPlnPartic := GETMV("MV_PLANPAR")

DbSelectArea("GCZ")
DbSetOrder(9) // GCZ_FILIAL + GCZ_STATUS + GCZ_REGATE + GCZ_CODCON + GCZ_CODPLA
DbSeek(xFilial("GCZ") + "0" + M->GAI_REGATE) // Procura primeira guia em aberto.

DbSelectArea("GCY")
DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
DbSeek(xFilial("GCY") + M->GAI_REGATE)

cRegate:=M->GAI_REGATE
aRValDes := HS_RValMM(GCZ->GCZ_CODPLA, oGDGaj:aCols[nItens, nGajProSol],,, dDatMov,, IIF(nGajCodCrm > 0, oGDGaj:aCols[nItens, nGajCodCrm], ""), M->GAI_CODLOC, cHorMov,{GCY->GCY_ATENDI, GCY->GCY_CARATE})
cGa9TipCon := HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") // 1-Particular

cConpart:=HS_IniPadr("GCM", 2, cPlnPartic, "GCM_CODCON",, .F.)

If cGa9TipCon == "0" .And. aRValDes[4][1] .And. aRValDes[4][2] == "1"
	If GCZ->(!DbSeek(xFilial("GCZ") + "0" + M->GAI_REGATE + cConpart + cPlnPartic)  )
		HS_GrvPart(cRegate,cConpart)
		cPlanoPart:=cPlnPartic
		cNrseqg:=GCZ->GCZ_NRSEQG
	Else
		cPlanoPart:=cPlnPartic
		cNrseqg:=GCZ->GCZ_NRSEQG
	Endif
	
EndIf

DbSelectArea("GD5")
DbSetOrder(1) // GD5_FILIAL + GD5_SEQDES

M->GD5_SEQDES := HS_VSxeNum("GD5", "M->GD5_SEQDES", 1)
ConfirmSx8()

RecLock("GD5", .T.)
GD5->GD5_FILIAL := xFilial("GD5")
GD5->GD5_CODLOC := M->GAI_CODLOC
GD5->GD5_DATDES := dDatMov
GD5->GD5_HORDES := cHorMov
GD5->GD5_QTDDES := oGDGaj:aCols[nItens, nGajQAtend]
GD5->GD5_CODDES := oGDGaj:aCols[nItens, nGajProSol]
GD5->GD5_VALDES := aRValDes[2]
GD5->GD5_PCUDES := aRValDes[3]
GD5->GD5_LOTEFO := oGDGaj:aCols[nItens, nGajLoteFo]
GD5->GD5_LOTECT := oGDGaj:aCols[nItens, nGajLoteCt]
GD5->GD5_NUMLOT := oGDGaj:aCols[nItens, nGajNumLot]
GD5->GD5_DTVALI := oGDGaj:aCols[nItens, nGajDTVali]
GD5->GD5_PERTRO := "0"
GD5->GD5_PROALT := oGDGaj:aCols[nItens, nGajProAlt]
GD5->GD5_GLODES := IIf(aRValDes[4][1], "2", "0")
GD5->GD5_CODKIT := oGDGaj:aCols[nItens, nGajCodKit]
GD5->GD5_SEQDES := M->GD5_SEQDES
GD5->GD5_NRSEQG := GCZ->GCZ_NRSEQG
GD5->GD5_NUMSEQ := cD3NumSeq
GD5->GD5_SD3DOC := cD3Doc
GD5->GD5_REGATE := M->GAI_REGATE
GD5->GD5_SOLICI := M->GAI_SOLICI
GD5->GD5_ITESOL := oGDGaj:aCols[nItens, nGajIteSol]
GD5->GD5_FATPAR := aRValDes[4][2]
GD5->GD5_CODPRO := aRValDes[9]
GD5->GD5_DESPRO := aRValDes[10]
GD5->GD5_TABELA := aRValDes[11]
GD5->GD5_LOGARQ := HS_LogArq()
If HS_ExisDic({{"C", "GAJ_CODPCT"}}, .F.)
	GD5->GD5_CODPCT := oGDGaj:aCols[nItens, nGajCodPct]
Endif
If HS_ExisDic({{"C", "GD5_CODCRM"}}, .F.)
	If GetMV("MV_ATCRMD") == "S"
		GD5->GD5_CODCRM := oGDGaj:aCols[nItens, nGajCodCrm]
	Endif
	GD5->GD5_VALREP := oGDGaj:aCols[nItens, nGajQAtend] * aRValDes[13][05]
	GD5->GD5_VALREB := GD5->GD5_VALREP
	GD5->GD5_PGTMED := aRValDes[13][01]
	GD5->GD5_REPAMB := aRValDes[13][aRValDes[15]]
EndIf
MsUnLock()

If HS_ExisDic({{"C", "GHX_STAENF"}}, .F.)
	DbSelectArea("GHX")
	DbSetOrder(3)
	If DbSeek(xFilial("GHX")+ M->GAI_SOLICI + oGDGaj:aCols[nItens, nGajProSol] + IIF(lItePre .And. !Empty(oGDGaj:aCols[nItens, nGajItePre]), oGDGaj:aCols[nItens, nGajItePre], oGDGaj:aCols[nItens, nGajIteSol]))
		RecLock("GHX", .F.)
		GHX->GHX_STAENF := IIF(lDelete .And. IIF(lItePre .And. Ascan(oGDGaj:aCols,{|aVet| aVet[nGajItePre] = oGDGaj:aCols[nItens, nGajItePre] .And. !aVet[nUGaj + 1] }) > 0,.F.,.T.), "2", "4")
		MsUnLock()
		
		DbSelectArea("GNR")
		DbSetOrder(1)
		If DbSeek(xFilial("GNR") + GHX->GHX_REGATE + GHX->GHX_SEQPRE + GHX->GHX_ITEMBR + GHX->GHX_CDMEDI)
			While xFilial("GNR") == GNR->GNR_FILIAL .And. GNR->GNR_PRODUT == GHX->GHX_CDMEDI .And. nPresc < oGDGaj:aCols[nItens, nGajQAtend]
				If GNR->GNR_STATUS <> "2"
					RecLock("GNR", .F.)
					If !Empty(GNR->GNR_HORPRE)
						GNR->GNR_STATUS := "2"
						GNR->GNR_SEQDES := M->GD5_SEQDES
					Else
						GNR->GNR_QTDATE += oGDGaj:aCols[nItens, nGajQAtend]
					Endif
					MsUnLock()
					nPresc++
				Endif
				DbSkip()
			End
		Endif
	Endif
Endif
If !Empty(oGDGaj:aCols[nItens, nGajCodKit]) //Se tiver Kit
	DbSelectArea("GAF")
	DbSetOrder(1) // GAF_FILIAL + GAF_CODKIT + GAF_ALMORI
	DbSeek(xFilial("GAF") + oGDGaj:aCols[nItens, nGajCodKit])
	If GAF->GAF_CCOKIT == oGDGaj:aCols[nItens, nGajProSol]
		DbSelectArea("GFC")
		DbSetOrder(1) // GFC_FILIAL + GFC_CODKIT + GFC_CODLOC + GFC_CCOKIT
		DbSeek(xFilial("GFC") + GAF->GAF_CODKIT + M->GAI_CODLOC)
		While !Eof() .and. GFC->GFC_FILIAL == xFilial("GFC") .and. GFC->GFC_CODKIT == GAF->GAF_CODKIT .and. GFC->GFC_CODLOC == M->GAI_CODLOC
			
			aRValTD := HS_RValTD(GFC->GFC_CCOKIT, GCZ->GCZ_CODPLA, M->GAI_CODLOC,, dDatMov)
			
			M->GD6_SEQDES := HS_VSxeNum("GD6", "M->GD6_SEQDES", 1)
			ConfirmSx8()
			
			DbSelectArea("GD6")
			DbSetOrder(1) // GD6_FILIAL + GD6_SEQDES
			RecLock("GD6", .T.)
			GD6->GD6_FILIAL := xFilial("GD6")
			GD6->GD6_CODLOC := M->GAI_CODLOC
			GD6->GD6_DATDES := dDatMov
			GD6->GD6_HORDES := cHorMov
			GD6->GD6_QTDDES := GFC->GFC_QTDKIT
			GD6->GD6_CODDES := GFC->GFC_CCOKIT
			GD6->GD6_VALDES := aRValTD[2]
			GD6->GD6_PCUDES := aRValTD[3]
			GD6->GD6_GLODES := IIf(aRValTD[4][1], "2", "0")
			GD6->GD6_CODKIT := oGDGaj:aCols[nItens, nGajCodKit]
			GD6->GD6_SEQDES := M->GD6_SEQDES
			GD6->GD6_NRSEQG := GCZ->GCZ_NRSEQG
			GD6->GD6_REGATE := M->GAI_REGATE
			GD6->GD6_FATPAR := aRValTD[4][2]
			GD6->GD6_CODTXC := aRValTD[7]
			GD6->GD6_DESTXC := aRValTD[8]
			GD6->GD6_TABELA := aRValTD[9]
			GD6->GD6_LOGARQ := HS_LogArq()
			MsUnLock()
			DbSelectArea("GFC")
			DbSkip()
		End
		
	Endif
Endif

RestArea(aArea)
Return(Nil)

Static Function FS_DevM05(nOpcM05)
 Local nForMM := 0, nIteDev := 1, cCodPMov := "", cAliasOld := Alias()
 Local lAchouGd5 := .T.

 cSetor := IIF(nOpcM05 == 6, cSetor, GAI->GAI_CODLOC)
 DbselectArea("GBD")
 DbSetOrder(1) // GBD_FILIAL + GBD_NUMDEV     
 
 M->GBD_NUMDEV := HS_VSxeNum("GBD", "M->GBD_NUMDEV", 1)
 ConfirmSx8()
  
 RecLock("GBD", .T.)
  GBD->GBD_FILIAL := xFilial("GBD")
  GBD->GBD_NUMDEV := M->GBD_NUMDEV
  GBD->GBD_REGATE := IIF(nOpcM05 == 6, M->GCY_REGATE, GAI->GAI_REGATE)
  GBD->GBD_CODLOC := cSetor
 	if Hs_ExisDic({{"C","GBD_ALMORI"}},.F.) 
	  GBD->GBD_ALMORI := IIf(nOpcM05 == 6,HS_IniPadr("GCS", 1, cSetor, "GCS_ARMFAR",, .F.), M->GAI_ALMORI)
	 Endif
  GBD->GBD_DATDEV := dDatMov
  GBD->GBD_FLGDEV := "2"
  GBD->GBD_LOGARQ := HS_LogArq()                                                                        
 MsUnLock()


 For nForMM := 1 To Len(oGDMM:aCols)  
  If oGDMM:aCols[nForMM, nMMQDevol] > 0
  DbSelectArea("GD5")
  DbSetOrder(1)//GD5_FILIAL + GD5_SEQDES
  lAchouGd5 := DbSeek(xFilial("GD5") + oGDMM:aCols[nForMM, nMMSeqDes])    
  DbSelectArea("SD3")
  DbSetOrder(4)  //D3_FILIAL + D3_NUMSEQ + D3_CHAVE + D3_COD
  Dbseek(xFilial("SD3")+GD5->GD5_NUMSEQ)
   cCodPMov := PadR(AllTrim(oGDMM:aCols[nForMM, IIf(lMV_ProdAlt .And. !Empty(oGDMM:aCols[nForMM, nMMProAlt]), nMMProAlt, nMMCodDes)]), Len(SB1->B1_COD))
   
   If HS_CONEST(cCodPMov, cSetor)[1]
    aMovest := HS_MovEst("E", cCodPMov, oGDMM:aCols[nForMM, nMMQDevol], SD3->D3_LOCAL, cUserName, SD3->D3_CC,, oGDMM:aCols[nForMM, nMMNumLot], oGDMM:aCols[nForMM, nMMLoteCt], oGDMM:aCols[nForMM, nMMDtVali],,,,GBD->GBD_REGATE)
   Else 
    aMovest := {.T.}
   Endif
    If aMovEst[1]
     If lAchouGd5  
  	   RecLock("GD5", .F., .F.)
       If oGDMM:aCols[nForMM, nMMQDevol] == GD5->GD5_QTDDES
        DbDelete()
      	Else
        GD5->GD5_QTDDES -= oGDMM:aCols[nForMM, nMMQDevol]        
       EndIf
  	   MsUnlock()
     EndIf                                                               
   
	DbSelectArea("GAJ")
	DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
	If nMMSolici > 0
		If DbSeek(xFilial("GAJ") + oGDMM:aCols[nForMM, nMMSolici] + oGDMM:aCols[nForMM, nMMIteSol])
			RecLock("GAJ", .F.)
			GAJ->GAJ_QTDDEV += oGDMM:aCols[nForMM, nMMQDevol]
			MsUnLock()
		Endif
	Else
		If DbSeek(xFilial("GAJ") + GAI->GAI_SOLICI + oGDMM:aCols[nForMM, nMMIteSol])
			RecLock("GAJ", .F.)
			GAJ->GAJ_QTDDEV += oGDMM:aCols[nForMM, nMMQDevol]
			MsUnLock()
		Endif
	Endif
   
     DbSelectArea("GBE")
     DbSetOrder(1) // GBE_FILIAL+GBE_NUMDEV+GBE_ITEDEV 
     RecLock("GBE", .T.)
      GBE->GBE_FILIAL := xFilial("GBE")
     GBE->GBE_NUMDEV := M->GBD_NUMDEV
     GBE->GBE_ITEDEV := StrZero(nIteDev++, Len(GBE->GBE_ITEDEV))
     GBE->GBE_SOLICI := GAI->GAI_SOLICI
     GBE->GBE_ITESOL := oGDMM:aCols[nForMM, nMMIteSol]
     GBE->GBE_DATSOL := dDatMov  
     GBE->GBE_PRODEV := cCodPMov
     GBE->GBE_QTDADV := oGDMM:aCols[nForMM, nMMQDevol]
     GBE->GBE_QTDDEV := oGDMM:aCols[nForMM, nMMQDevol]
     GBE->GBE_SEQDES := GD5->GD5_SEQDES
     GBE->GBE_LOGDEV := HS_LogArq()
     GBE->GBE_LOGARQ := HS_LogArq()
    MsUnlock()
    HS_GrvGnr(GBE->GBE_SEQDES , GBE->GBE_SOLICI, GBE->GBE_ITESOL, GBE->GBE_PRODEV, GBE->GBE_QTDADV)
    EndIf      
   Endif
 Next
 
 DbSelectArea(cAliasOld)
Return(M->GBD_NUMDEV)

Function HS_LegM05()
Local aCores2 := {}

If ExistBlock("HSPM05LEG")
	aCores2 := ExecBlock("HSPM05LEG", .F., .F., {"BR_VERDE", "BR_AMARELO", "BR_VERMELHO", "BR_MARRON", "BR_CINZA", "BR_PRETO"})
	BrwLegenda(cCadastro, STR0007, {	{aCores2[1]		, STR0025},; //"Legenda"###"Nใo atendida"
										{aCores2[2]		, STR0026},; //"Atendimento parcial"
										{aCores2[3]		, STR0027},; //"Atendimento Total"
										{aCores2[4]		, STR0034},; //"Atendimento Parcial Fechado"
										{aCores2[5]		, STR0043},; //"Atendimento Encerrado"
										{aCores2[6]		, STR0037}}) //"Urgente"
Else
	BrwLegenda(cCadastro, STR0007, {	{"BR_VERDE"		, STR0025},; //"Legenda"###"Nใo atendida"
										{"BR_AMARELO"	, STR0026},; //"Atendimento parcial"
										{"BR_VERMELHO"	, STR0027},; //"Atendimento Total"
										{"BR_MARRON"	, STR0034},; //"Atendimento Parcial Fechado"
										{"BR_CINZA"		, STR0043},; //"Atendimento Encerrado"
										{"BR_PRETO"		, STR0037}}) //"Urgente"
EndIf
                                 
Return(.T.)

Static Function FS_VerGuia()
Local cAliasOld := Alias()
Local lRet := .T.
If M->GAI_REQUIS == "1"
	DbSelectArea("GCZ")
	DbSetOrder(9) // GCZ_FILIAL + GCZ_STATUS + GCZ_REGATE + GCZ_CODCON + GCZ_CODPLA
	If !(lRet := DbSeek(xFilial("GCZ") + "0" + M->GAI_REGATE)) // Procura primeira guia em aberto.
		HS_MsgInf(STR0028, STR0008, STR0001) //"Nใo foi encontrada nenhuma guia em aberto para confirmar o atendimento da solicita็ใo"###"###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
	EndIf
	DbSelectArea(cAliasOld)
EndIf
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      ATIVA FILTRO DO BROWSE                                             ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_ValP1()
Local lRet := .T.

If MV_PAR01 == 2 //Finaliza
	If Empty(MV_PAR02)
		lRet := .F.
		HS_MsgInf(STR0035, STR0008, STR0001) //"Se Finaliza Solicitacao o Motivo e Obrigatorio..."###"Atencao"###//"Atendimento de solicita็oes Mat/Med"
	ElseIf EMPTY(HS_IniPadR("GF2", 1, MV_PAR02, "GF2_CODENC"))
		lRet := .F.
		HS_MsgInf(STR0098, STR0088, STR0001) //"Motivo de encerramento invแlido."###"Aten็ใo"###"Atendimento de solicita็oes Mat/Med"
	EndIf
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      ATIVA FILTRO DO BROWSE                                             ฑฑ
ฑฑ      AUTHOR: MARCELO JOSE 06/09/2005                                    ฑฑ
ฑฑ      Alterado : Cibele Peria 13/09/2005                                 ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_FilM05(cPerg, lSetFilter)
Local lRet        := .F.
Local oObjMBrw    := GetObjBrow()
Local cCodLoc_Sol := ""
Private lFarmacia := .T. // Identifica a origem da consulta padrใo para ser tratado em HS_FilGcs()

//Fun็ใo para limpar as perguntas
HS_PosSX1({{cPerg, "01", Nil}, {cPerg, "02", Nil}})

If (lRet := Pergunte(cPerg))
	cGcsCodLoc  := mv_par01
	cCodLoc_Far := mv_par01
	cCodLoc_Sol := mv_par02
	dDatSol_De  := mv_par03
	dDatSol_Ate := mv_par04
	
	cFilM05 := "GAI_FILIAL = '" + xFilial("GAI") + "'"
	
	DbSelectArea("GCS")
	DbSetOrder(1) // GCS_FILIAL + GCS_CODLOC
	DbSeek(xFilial("GCS") + cCodLoc_Far)
	
	If !Empty(GCS->GCS_ARMSET)
		cFilM05 += " AND GAI_ALMORI = '" + GCS->GCS_ARMSET + "'"
	Endif
	
	If !Empty(cCodLoc_Sol)
		cFilM05 += " AND GAI_CODLOC = '" + cCodLoc_Sol + "'"
	Endif
	cFilM05 += " AND GAI_DATSOL BETWEEN '" + DTOS(dDatSol_De) + "' AND '" + DTOS(dDatSol_Ate) + "'"
	
	If lSetFilter
		SetMBTopFilter("GAI", cFilM05)
		oObjMBrw:GoTop()
		oObjMBrw:Refresh()
	EndIf
EndIf
DbSelectArea("GAI")
    
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      Valida as perguntas do grupo HSPM5B                                ฑฑ
ฑฑ      AUTHOR: Cibele Peria - 21/09/05                                    ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_VHSPM5B(nPar)
Local cCodLoc := IIF(nPar==1, mv_par01, mv_par02)
Local lRet    := .T.

If nPar == 1 .and. Empty(cCodLoc)
	HS_MsgInf(STR0029,STR0008,STR0057 ) //"Por favor, informe o codigo do setor."###"Atencao" //"Valida็ใo de perguntas"
	lRet := .F.
	
ElseIf !Empty(cCodLoc)
	DbSelectArea("GCS")
	DbSetORder(1) // GCS_FILIAL + GCS_CODLOC
	If !DbSeek(xFilial("GCS") + cCodLoc)
		HS_MsgInf(STR0030,STR0008,STR0057) //"Setor nao cadastrado"###"Atencao" //"Valida็ใo de perguntas"
		lRet := .F.
		
	ElseIf nPar == 1 .and. GCS->GCS_TIPLOC <> "A" //Diferente de setor do tipo FARMACIA
		HS_MsgInf(STR0031,STR0008,STR0057) //"Setor invalido. Informe um setor do tipo 'Farmacia'."###"Atencao" //"Valida็ใo de perguntas"
		mv_par01 = "  " // limpa o campo
		lRet := .F.
		
	ElseIf nPar == 2 .and. GCS->GCS_TIPLOC == "A"
		HS_MsgInf(STR0032,STR0008,STR0057) //"Tipo do setor invalido (Farmacia).""###"Atencao" //"Valida็ใo de perguntas"
		mv_par02 = "  " // limpa o campo
		lRet := .F.
		
	Endif
Endif

Return(lRet)

/************************************************************************************************************/
Function HS_RelM05() 

HSPAHR03(GAI->GAI_SOLICI,,,cCodLoc_Far)
If ExistBlock("HSPHRAP03")
	Execblock("HSPHRAP03", .F., .F., {GAI->GAI_SOLICI})
EndIf

Return            

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHฟ
//ณFuncao que fara a chamada da Rotina de Fichas de atendimentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHู
Function HS_FicM05() 

HSPAHP44(.F., cCodLoc_Far)

Return                                                          

Function HS_GrvNPac()
                
If MsgyesNo(STR0038) //"Confirma processamento"
	Processa({|| FS_GrvNPac()})
EndIf

Return(Nil)

Static Function FS_GrvNPac()

/* Grava o nome do paciente na GAI */
DBSelectArea("GAI")
DBSetOrder(1) // GAI_FILIAL + GAI_SOLICI
DBSeek(xFilial("GAI"))

ProcRegua(GAI->(RecCount()))

While !Eof() .And. GAI->GAI_FILIAL == xFilial("GAI")
	
	IncProc(STR0039 + GAI->GAI_REGATE + "]") //"Grv. nome do paciente na GAI ["
	
	If !Empty(GAI->GAI_REGATE)
		
		RecLock("GAI", .F.)
		GAI->GAI_NOMPAC := HS_IniPadr("GCY", 1, GAI->GAI_REGATE, "GCY_NOME",, .F.)
		MsUnLock()
		
	EndIf
	
	DBSkip()
End

/* Grava o nome do paciente na GCZ */
DBSelectArea("GCZ")
DBSetOrder(1) // GCZ_FILIAL + GCZ_NRSEQG + GCZ_STATUS
DBSeek(xFilial("GCZ"))

ProcRegua(GCZ->(RecCount()))
While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ")
	
	IncProc(STR0042 + GCZ->GCZ_REGGER + "]")  //"Grv. nome do paciente na GCZ ["
	
	If Empty(GCZ->GCZ_NOME)
		RecLock("GCZ", .F.)
		GCZ->GCZ_NOME := HS_IniPadr("GBH", 1, GCZ->GCZ_REGGER, "GBH_NOME",, .F.)
		MsUnLock()
	Endif
	
	DBSkip()
End
Return(Nil)

Function HS_ProAlt(cCodProSol)
Local aAreaOld := GetArea()
Local cCodProAlt := ""

DbSelectArea("GBI")
DbSetorder(1) // GBI_FILIAL + GBI_PRODUT
DbSeek(xFilial("GBI") + PadR(AllTrim(cCodProSol), Len(GBI->GBI_PRODUT)))
If !EMPTY(GBI->GBI_FARMAC)
	DbSelectArea("GA0")
	DbSetorder(1)// GA0_FILIAL + GA0_CODFAR
	DbSeek(xFilial("GA0") + GBI->GBI_FARMAC)
	If !EMPTY(GA0->GA0_PROPAD)
		cCodProAlt := GA0->GA0_PROPAD
	EndIf
EndIf

RestArea(aAreaOld)

Return(cCodProAlt)

Static Function FS_TotQDev(cProSol, lLote, cLoteCt, cNumLot, dDtVali, cProAlt)
Local nItens := 0, nQtdTot := 0

For nItens := 1 to Len(oGDMM:aCols)
	
	If lLote
		If !(oGDMM:aCols[nItens, nMMCodDes] == cProSol .And. ;
			oGDMM:aCols[nItens, nMMLoteCt] == cLoteCt .And. ;
			oGDMM:aCols[nItens, nMMNumLot] == cNumLot .And. ;
			oGDMM:aCols[nItens, nMMDtVali] == dDtVali .And. !oGDMM:aCols[nItens, nUMM +1])
			Loop
		Endif
	ElseIf oGDMM:aCols[nItens, nMMCodDes] <> cProSol .Or. oGDMM:aCols[nItens, nMMProalt] <> cProAlt
		Loop
	Endif
	If !oGDMM:aCols[nItens, nUMM +1]
		nQtdTot += oGDMM:aCols[nItens, nMMQtdDes] - oGDMM:aCols[nItens, nMMQDevol]
	Endif
Next

Return(nQtdTot)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | HS_TraM05บ Autor ณ Mario Arizono      บ Data ณ15/02/06     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Transferencia de Produtos entre farmacias                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_TraM05(cAliasM05, nRegM05, nOpcM05)
 Local cChave    := ""
 Local cCond     := ""
 Local cLstCpo   := ""
 Local cElimina  := ""
 Local cDespesas := ""
 Local aCampos   := {}
 Local cSQL      := ""     
 Local aSize     := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Private oCodSet, oDesSet, oCodAlm, oDesAlm
 Private cCodTra     := ""
 Private cNomTra     := ""
 Private cCodAlm     := ""
 Private cDesAlm     := ""
 Private lCbTra      := .F.
 Private aHeader     := {}
 Private aCols       := {}
 Private nUPro       := 0
 Private aRecNo      := {}
 Private oGAI
 

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Montar o aHeader das despesas         ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 aCampos := {"GAI_IDMARC","GAI_SOLICI", "GAI_REQUIS", "GAI_REGATE", "GCY_NOME", "GAI_CODLOC", "GCS_NOMLOC",;
             "GAI_ALMORI","GAI_DSALMO"}   
 aHeader := FS_GerHead(aCampos, aHeader)
 nUDes   := len(aCampos)

 cSQL  := "SELECT GAI_FLGATE, GAI_IDMARC, GAI_SOLICI, GAI_REQUIS, GAI_REGATE, GAI_CODLOC, GAI_ALMORI, GAI_ALMSOL, "
 cSQL  += " GAI_URGENC, GAI_NOMPAC, GAI.R_E_C_N_O_, GCS_NOMLOC, SX5.X5_DESCRI DESCRI"
 cSQL  += " FROM " + RetSQLName("GAI") + " GAI"
 cSQL  += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GAI.GAI_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL  += " JOIN " + RetSQLName("SX5")+ "  SX5 ON SX5.X5_TABELA = 'AL' AND SX5.X5_CHAVE = GAI.GAI_ALMORI AND SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ <> '*' "
 cSQL  += " WHERE GAI.GAI_FILIAL = '" + xFilial("GAI") + "' AND GAI.D_E_L_E_T_ <> '*'"
 cSQL  += " AND GAI.GAI_FLGATE IN ('0','1') " 
 cSQL  += " AND GAI.GAI_DATSOL BETWEEN '" + DTOS(dDatSol_De) + "' AND '" + DTOS(dDatSol_Ate) + "' " 
 cSQL  += " AND GAI.GAI_ALMORI IN (SELECT GCS_ARMSET FROM " + RetSQLName ("GCS")+ " GCS"
 cSQL  += " WHERE GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
 cSQL  += " AND GCS.GCS_CODLOC = '" + cCodLoc_Far + "')"
 cSQL  += " ORDER BY GAI_SOLICI "
 
 TCQUERY cSQL NEW ALIAS "QRY"  
 
 DbSelectArea("QRY")
 DbGoTop()

 While !Eof()
 
  aAdd(aCols, {"LBNO", QRY->GAI_SOLICI, QRY->GAI_REQUIS, QRY->GAI_REGATE,QRY->GAI_NOMPAC, QRY->GAI_CODLOC,;
  QRY->GCS_NOMLOC, QRY->GAI_ALMORI, QRY->DESCRI, QRY->GAI_FLGATE, QRY->GAI_ALMSOL, QRY->GAI_URGENC})
  aAdd(aRecNo, QRY->R_E_C_N_O_)

  DbSkip()
 End
 
 If len(aCols) == 0
  HS_MsgInf(STR0047,STR0008,STR0048)//"Nao existem registros para serem mostrados"###"Atencao"###"Transferencia entre farmacias"  
  DbSelectArea("QRY")
  DbCloseArea()
  Return()
 Endif
 cGCSTipLoc := "A"
 cCodTra := Space(LEN(QRY->GAI_CODLOC))
 cNomTra := Space(LEN(QRY->GCS_NOMLOC))
 cCodAlm := Space(LEN(QRY->GAI_ALMORI))
 cDesAlm := Space(50) 
 nOpcA := 0    
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 020, .T., .T. } )	                            
 AAdd( aObjects, { 100, 080, .T., .T. } )	
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 
 DEFINE MSDIALOG oDlgG TITLE OemToAnsi(STR0048) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL of oMainWnd //"Transferencia entre farmacias"  

  @ 25,250 CheckBox oCbG Var lCbTra Prompt STR0049 SIZE 50, 10 OF oDlgG PIXEL On Click (FS_MarcT(lCbTra)) //"Marca Todos"
  
  @ 20,004 SAY OemToAnsi(STR0050) OF oDlgG PIXEL COLOR CLR_BLUE   //"Setor Transf."
  
  @ 20,044 MSGET oCodSet VAR cCodTra PICTURE "@!" F3 "GCS" VALID FS_VLDTRA() SIZE 25,9  OF oDlgG PIXEL COLOR CLR_BLACK                                            
  @ 20,085 MSGET oDesSet VAR cNomTra PICTURE "@!" SIZE 120,9 OF oDlgG PIXEL COLOR CLR_BLACK WHEN .F.   
  
  @ 35,004 SAY OemToAnsi(STR0051) OF oDlgG PIXEL COLOR CLR_BLUE  //"Almox. Transf."
  
  @ 35,044 MSGET oCodAlm VAR cCodAlm PICTURE "@!" SIZE 18,9  OF oDlgG PIXEL COLOR CLR_BLACK WHEN .F.                                           
  @ 35,085 MSGET oDesAlm VAR cDesAlm PICTURE "@!" SIZE 120,9 OF oDlgG PIXEL COLOR CLR_BLACK WHEN .F. 
  oGAI := MsGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nOpcM05, , ,"",.F.,"GAI_IDMARC",,,len(aCols))
  
  oGAI:oBrowse:align := CONTROL_ALIGN_BOTTOM 
  oGAI:oBrowse:BlDblClick := {|| FS_Marc(oGAI:oBrowse:nAt)}   
  
   
 ACTIVATE MSDIALOG oDlgG CENTERED ON INIT EnchoiceBar(oDlgG, {|| nOpcA := 1,;
 																																																												IIF(FS_TUDOOK(), oDlgG:End(),nOpcA := 0)},;
 																																																											 {|| nOpcA := 0, oDlgG:End()})

 DbSelectArea("QRY")
 DbCloseArea()

 If nOpcA == 1
  FS_GerTra()
 Endif
 nOpcA := 0  
  
Return()
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GerHead  บ Autor ณ Mario Arizono      บ Data ณ 15/02/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function FS_GerHead(aCampos, aHeader)
 Local nForCampos := 0
       
                       
 DbSelectArea("SX3")
 DbSetOrder(2) // X3_CAMPO 

 For nForCampos := 1 to len(aCampos)
   DbSeek(aCampos[nForCampos])
   aAdd(aHeader, { IIF (aCampos[nForCampos]<> "GAI_IDMARC",TRIM(X3Titulo())," ")	, ;
                   SX3->X3_CAMPO   	, ;
                   SX3->X3_PICTURE 	, ;
                   SX3->X3_TAMANHO 	, ;
                   SX3->X3_DECIMAL 	, ;
                   SX3->X3_VALID   	, ;
                   SX3->X3_USADO   	, ;
          		       SX3->X3_TIPO    	, ;
                   SX3->X3_F3      	, ;
          		       SX3->X3_CONTEXT 	, ;
                   SX3->X3_CBOX    	, ;
   		              SX3->X3_RELACAO 	, ;
                   SX3->X3_WHEN    	, ;
                   SX3->X3_VISUAL  	, ;
                   SX3->X3_VLDUSER 	, ;
                   SX3->X3_PICTVAR 	, ;
                   X3Obrigat(SX3->X3_CAMPO) })
                
 Next nForCampos

Return(aHeader)    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MarcT บ Autor ณ Mario Arizono      บ Data ณ  15/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca todas as solicitacoes no browse             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MarcT(lMar)
 Local cVal := IIF(lMar, "LBTIK", "LBNO"), nForaCols := 0

 For nForACols := 1 to len(aCols)
  aCols[nForACols,1] := cVal
 Next
  
 oGAI:oBrowse:Refresh()   

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_Marc  บ Autor ณ Mario Arizono      บ Data ณ  15/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca solicitacoes                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Marc(nMar)
                         
 IF aCols[nMar,1]== "LBNO"
  aCols[nMar,1]:= "LBTIK"
 Else
  aCols[nMar,1]:= "LBNO"
 Endif     
  
 oGAI:oBrowse:Refresh()

Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GerTraบ Autor ณ Mario Arizono      บ Data ณ  15/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza Transferencia de produtos                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
      
Static Function FS_GerTra()
 Local nFor     := 0 , nGaj := 0
 Local oObjMBrw := GetObjBrow()
 Local aColGaj  := {}
   
 DbSelectArea("GAI") 
 DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI     
    
 For nFor := 1 to len(aCols)
  If aCols[nFor,1] == "LBTIK"
   Dbseek(xFilial("GAI")+aCols[nFor,2])
   Begin Transaction
    If aCols[nFor,10] <> "0"
     RecLock("GAI",.F.)
      GAI->GAI_FLGATE := "2"
  		 MsUnlock()
  		 
  		 DbSelectArea("GAJ") 
     DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
  		 Dbseek(xFilial("GAJ")+aCols[nFor,2])
  		 While GAJ->GAJ_SOLICI == aCols[nFor,2]  
  		  AADD(aColGaj,{GAJ->GAJ_SOLICI,GAJ->GAJ_QTDDEV, GAJ->GAJ_PROSOL, GAJ->GAJ_QTDSOL, GAJ->GAJ_QTDATE,;
      GAJ->GAJ_PROALT, GAJ->GAJ_CODJUS, GAJ->GAJ_CODKIT, GAJ->GAJ_LOTEFO, GAJ->GAJ_LOTECT, GAJ->GAJ_NUMLOT,;
      GAJ->GAJ_DTVALI, GAJ->GAJ_ITESOL})
  	
  		  DbSkip()
  		 EndDo
  		 DbSelectArea("GAI") 
     M->GAI_SOLICI := HS_VSxeNum("GAI", "M->GAI_SOLICI", 1)
     ConfirmSx8()
     RecLock("GAI",.T.)
      GAI->GAI_FILIAL := xFilial("GAI")
  		 	GAI->GAI_SOLICI := M->GAI_SOLICI
  			 GAI->GAI_ALMORI := cCodAlm
  			 GAI->GAI_REQUIS := aCols[nFor,3] 
  			 GAI->GAI_ALMSOL := aCols[nFor,11]
  			 GAI->GAI_REGATE := aCols[nFor,4]
  			 GAI->GAI_NOMPAC := aCols[nFor,5]
  			 GAI->GAI_CODLOC := aCols[nFor,6]
  			 GAI->GAI_DATSOL := dDataBase
  		 	GAI->GAI_HORSOL := Time()
  			 GAI->GAI_FLGATE := "0"
  			 GAI->GAI_URGENC := aCols[nFor,11]     
  			 GAI->GAI_CDLOCT := cCodLoc_Far
      GAI->GAI_ALMORT := aCols[nFor,8]
  			 GAI->GAI_LOGARQ := HS_LogArq()
 		  MsUnLock() 
      
     DbSelectArea("GAJ") 
     DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL   
     For nGaj := 1 to len(aColGaj)                      
      Dbseek(xFilial("GAJ")+aColGaj[nGaj,1]+aColGaj[nGaj,13])   
      If acolGaj[nGaj,5] == 0
       Reclock("GAJ",.F.)
        GAJ->GAJ_SOLICI := M->GAI_SOLICI
        GAJ->GAJ_ITESOL := StrZero(nGaj, Len(GAJ->GAJ_ITESOL)) 
       MsUnlock()
      Else
       If acolGaj[nGaj,4] > acolGaj[nGaj,5]
        Reclock("GAJ",.F.)
         GAJ->GAJ_QTDSOL := acolGaj[nGaj,5]
        MsUnlock()
                 
        RecLock("GAJ",.T.)
         GAJ->GAJ_FILIAL := xFilial("GAJ")
   					 GAJ->GAJ_SOLICI := M->GAI_SOLICI
   					 GAJ->GAJ_ITESOL := StrZero(nGaj, Len(GAJ->GAJ_ITESOL)) 
  					  GAJ->GAJ_PROSOL := acolGaj[nGaj,3]
   					 GAJ->GAJ_QTDSOL := acolGaj[nGaj,4] - acolGaj[nGaj,5]
         GAJ->GAJ_CODJUS := acolGaj[nGaj,7]
   					 GAJ->GAJ_CODKIT := acolGaj[nGaj,8]
   					 GAJ->GAJ_LOTEFO := acolGaj[nGaj,9]
   			 	 GAJ->GAJ_LOTECT := acolGaj[nGaj,10]
   					 GAJ->GAJ_NUMLOT := acolGaj[nGaj,11]
   					 GAJ->GAJ_DTVALI := acolGaj[nGaj,12]
   					 GAJ->GAJ_PROALT := acolGaj[nGaj,6]
   					 GAJ->GAJ_QTDDEV := acolGaj[nGaj,2]   
   					 GAJ->GAJ_LOGARQ := HS_LogArq()
        MsUnlock()                         
       Endif
      Endif 
     Next nGaj      	
    Else 
     RecLock("GAI", .F.)
      GAI->GAI_ALMORI := cCodAlm
      GAI->GAI_CDLOCT := cCodLoc_Far
      GAI->GAI_ALMORT := aCols[nFor,8]
      GAI->GAI_LOGTRA := HS_LogArq()
     MsUnlock()
    Endif
   
   End Transaction
  Endif 
  aColGaj := {} 
  DbSelectArea("GAI") 
 Next nFor
  
  
  SetMBTopFilter("GAI", cFilM05)
  oObjMBrw:GoTop()
  oObjMBrw:Refresh()
Return()                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VLDTRAบ Autor ณ Mario Arizono      บ Data ณ  16/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida setor de transferencia                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                                       
Static Function FS_VLDTRA()
 Local lRet := .T.
 Local aArea:= GetArea()
  
 DbSelectArea("GCS")
 DbSetORder(1) // GCS_FILIAL + GCS_CODLOC 
 If !DbSeek(xFilial("GCS") + cCodTra)
  HS_MsgInf(STR0030, STR0008, STR0058) //"Setor nao cadastrado"###"Atencao" //"Valida setor de transferencia"
  lRet := .F.   
 ElseIf GCS->GCS_TIPLOC <> "A" //Diferente de setor do tipo FARMACIA
  HS_MsgInf(STR0031, STR0008,STR0058)//"Setor invalido. Informe um setor do tipo 'Farmacia'."###"Atencao" //"Valida setor de transferencia"
  lRet := .F.
 Else
  If cCodLoc_Far <> cCodTra
   HS_SeekRet("GCS","cCodTra",1,.F.,{"cNomTra","cCodAlm"},{"GCS_NOMLOC","GCS_ARMSET"})
   If !HS_SeekRet("SX5","'AL'+cCodAlm",1,.F.,"cDesAlm","X5_DESCRI") 
    HS_MsgInf(STR0052, STR0008, STR0058) //"Amoxarifado nao encontrado para este setor"###"Atencao"  //"Valida setor de transferencia"
    lRet := .F.
   Endif 
  Else
   HS_MsgInf(STR0053, STR0008, STR0058) //"Transferencia nao permitida pois setor escolhido e igual ao setor atual"###Atencao //"Valida setor de transferencia"
   lRet := .F.
  Endif
 Endif
  If !lRet
   cNomtra := Space(len(cNomTra))
   cCodAlm := Space(len(cCodAlm))
   cDesAlm := Space(len(cDesAlm))  
   oCodAlm:Refresh()
   oDesalm:Refresh()
   oDesSet:Refresh()
  Endif 
  RestArea(aArea)  
Return(lRet)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TudoOK บ Autor ณ Mario Arizono      บ Data ณ  17/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verificacao de validade da confirmacao                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_TudoOK()
 Local lRet := .T., nForaCols := 1, nPos := 0

 nPos := aScan(aCols, {| aVet | aVet[1] == "LBTIK"})
 If len(aCols) <> 0
  If nPos == 0 .AND. !Empty(cCodTra) 
   HS_MsgInfo(STR0054, STR0008, STR0059)  //"Nenhuma solicitacao selecionada"###"Atencao" //"Verificacao de validade da confirmacao"
   lRet := .F.
  ElseIf nPos <> 0 .AND. Empty(cCodTra)
   HS_MsgInfo(STR0055, STR0008, STR0059)  //"Selecione um setor para transferencia"###"Atencao" //"Verificacao de validade da confirmacao"
   lRet := .F.
  ElseIf nPos == 0 .AND. Empty(cCodTra)
   HS_MsgInfo(STR0056, STR0008,STR0059)  //"Nenhuma solicitacao e setor selecionado"###"Atencao" //"Verificacao de validade da confirmacao"
   lRet := .F.
  Endif
 Endif 
   
Return(lRet)   
           
Function HS_ValDat(nOpcM05,cRegate, dDatAte, cHorAte,cSeqDes, cMsg, cCodPro, nQtdAten, nQtdDevol, lMessage)
 
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aRetCon	:= {}
Local cMsgCab	:= "", cMsgInf := ""
Local lAtSolPA	:= GetNewPar("MV_ATSOLPA",.F.)
Default lMessage := .T.
If IIF(Type("M->GAI_REQUIS") <> "U", M->GAI_REQUIS == "1", .T.)
	
	dDatMov := dDatabase
	cHorMov := Time()
	
	aRetCon := HS_CONMED(cRegate, IIF(Type("M->GAI_RESERV") <> "U", M->GAI_RESERV, ""), cSeqDes)
	
	If nOpcM05 == 4
		If aRetCon[8] == "2"  //Tipo de atendimento
			If lAtSolPA
				dDatMov := DdataBase 			//Data atendimento
				cHorMov := SubStr(TIME(),1,5)	//Hora atendimento
			Else
				dDatMov := aRetCon[1] //Data atendimento
				cHorMov := aRetCon[2] //Hora atendimento
			EndIf
		Endif
		dDatAte := aRetCon[1] //Data atendimento
		cHorAte := aRetCon[2] //Hora atendimento
	Endif
	
	
	If HS_CountTB("GCZ", "GCZ_REGATE  = '" + cRegate + "' AND GCZ_STATUS IN " + IIf(nOpcM05 == 4,"('0')","('0','1')") + " ")  > 0
		If !EMPTY(aRetCon[5])//Tipo Alta
			If aRetCon[6] == "N" //Parametros MV_LMMALTA/DEVALTA
				cMsgCab := STR0001 //"Atendimento de solicita็oes Mat/Med"
				cMsgInf := STR0066//"O atendimento jแ estแ em alta"
				lRet:=.F.
			Else
				If aRetCon[8] <> "2"
					dDatMov := aRetCon[3] // Data Alta
					cHorMov := aRetCon[4] // Hora Alta
				Else
					If nOpcM05 <> 4
						dDatMov := aRetCon[3] // Data Alta
						cHorMov := aRetCon[4] // Hora Alta
					Endif
				Endif
			Endif
		Endif
		
		If !(lRet := !(dDatMov < dDatAte .Or. (dDatMov == dDatAte .And. cHorMov < cHorAte)))
			cMsgCab := STR0061 //"Inconsist๊ncia de data/ hora"
			cMsgInf := cMsg + STR0064 //"nใo pode ser anterior a data do atendimento"
		ElseIf !(lRet := !(dDatMov > dDataBase .Or. (dDatMov == dDataBase .And. cHorMov > Time())))
			cMsgCab := STR0061 //"Inconsist๊ncia de data/ hora"
			cMsgInf := cMsg + STR0062 //" nใo pode ser posterior a data corrente"
		ElseIf !Empty(aRetCon[7]) .AND. !(lRet := !(!(dDatMov > aRetCon[7])))
			cMsgCab := STR0068 //"Data Fechamento"
			cMsgInf := cMsg + STR0067//" ้ menor ou igual ao ๚ltimo fechamento de estoque, nใo serแ possํvel efetuar o lan็amento."
		ElseIf !Empty(aRetCon[3]) .And. !(lRet := !(dDatMov > aRetCon[3] .Or. (dDatMov == aRetCon[3] .And. cHorMov > aRetCon[4])))
			cMsgCab := STR0061 //"Atendimento de solicita็oes Mat/Med"
			cMsgInf := cMsg + STR0065//"Inconsist๊ncia de data/ hora"
		ElseIf nOpcM05 <> 4
			If !Empty(aRetCon[11]) // Nr. Solicitacao
				If aRetCon[10] - HS_VLCONFI(aRetCon[11],, cSeqDes,,.T.)[2] < nQtdAten + nQtdDevol  // Quantidade GD5 ## Nr.Solicitacao
					cMsgCab := STR0077//"Devolu็ใo mat/med"
					cMsgInf := STR0091//"Quantidade solicitada nใo pode ser devolvida. Verifique as confirma็๕es de devolu็ใo em aberto para esta despesa."
					lRet := .F.
				Endif
			Endif
		Endif
	Else
		cMsgCab := STR0070 //"Inconsist๊ncia do status da guia"
		cMsgInf := STR0069//"Nใo existe nenhuma guia em aberto para este atendimento"
		lRet := .F.
	Endif
EndIf

If !lRet .And. lMessage
	HS_MsgInf(cMsgInf, STR0008, cMsgCab )  //"Aten็ใo"
Endif

RestArea(aArea)
Return({lRet, cMsgInf})  

  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldDev บ Autor ณ Mario Arizono      บ Data ณ  30/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao quando nenhum item for devolvido.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldDev(aDev)
 Local lRet := .T.
 Local nPos := 0
 
 nPos := Ascan(oGDMM:aCols,{|aVet| aVet[nMMQdevol] > 0})
 If nPos == 0   
  HS_MsgInf( STR0076, STR0008, STR0077) //"Nenhum item foi devolvido!"##"Atencao"##"Devolu็ใo mat/med"
  lRet := .F.
 Endif  
   
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M05VPROบ Autor ณ Mario Arizono      บ Data ณ  05/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica no acols dos itens se o produto digitado, e o     บฑฑ
ฑฑบ          ณ produto principal ou alternativo, para validacao do estoqueบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M05VPRO(cCodBar, nOpcM05)
 
 Local nPosGD  := 0
 Local aArea   := GetArea()
 Local cProMov := "" 
 Local cProAlt := "", cProPri := ""
 Local aMovPro := {}
 Local nProsol := IIf (StrZero(nOpcM05,2) $ ("05/06"), nMMCodDes, nGajProsol)
 Local nProAlt := IIf (StrZero(nOpcM05,2) $ ("05/06"), nMMProalt, nGajProalt)
 Local oMov    := IIf (StrZero(nOpcM05,2) $ ("05/06"), oGDMM, oGDGaj)
 Local nUMov   := IIf (StrZero(nOpcM05,2) $ ("05/06"), nUMM, nUGaj)
 If!HS_SeekRet("SB1", "'" + cCodBar + "'", 5, .F.)
		If HS_SeekRet("GAP", "'" + cCodBar + "'", 1, .F.)
   HS_SeekRet("SB1", "GAP->GAP_CODIGO", 1, .F.)
  Endif
 Endif
 cProMov := SB1->B1_COD
 If nOpcM05 <> 3
  If (nPosGD := aScan(oMov:aCols, {| aVet | aVet[nProAlt] == cProMov .And. !aVet[nUMov + 1]})) > 0 .Or. ;
     (nPosGD := aScan(oMov:aCols, {| aVet | aVet[nProSol] == cProMov .And. !aVet[nUMov + 1]})) > 0
   cProPri :=  oMov:aCols[nPosGD, nProsol]
   cProAlt :=  oMov:aCols[nPosGD, nProAlt]     
  Endif     
 Else
  If !Empty(cProalt := HS_PROALT(cProMov))
   AADD(aMovPro,{cProMov, cProAlt})
  Endif 
 Endif 
 If nPosGD <> 0
  AADD(aMovPro,{cProPri, cProAlt})
 Endif
 RestArea(aArea)  
Return(aMovPro)                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldLoteบ Autor ณ Mario Arizono      บ Data ณ  10/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se o produto podera ser atendido por outro lote     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  	                          	                                         

Static Function FS_VldLote(cCodPro)
Local aArea  := GetArea()
Local nPosGD := 0, nResto := 0, nPosIni := 0
Local cProsol:= "", cDProsol := "", cCbMatm := "", cItePri :="",cProdAlt:="",cDescAlt:="",cCrm:="",cDesCrm:=""

	If (nPosIni :=  aScan(oGDGaj:aCols, {| aVet | aVet[nGajProAlt] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + aVet[nGajNumLot] + DToS(aVet[nGajDtVali]) == PADR(cCodPro, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt])) + __cLoteFo + __cLoteCt + __cNumLot + DToS(__dDtVali) .And. aVet[nGajQAtend] > 0 .And. !aVet[nUGaj + 1]})) == 0
		If (nPosIni :=  aScan(oGDGaj:aCols, {| aVet | aVet[nGajProAlt] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + aVet[nGajNumLot] == PADR(cCodPro, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt])) + Space(Len(GAJ->GAJ_LOTEFO) + Len(GAJ->GAJ_LOTECT) + Len(GAJ->GAJ_NUMLOT)) .And. !aVet[nUGaj + 1] })) == 0
			If (nPosIni :=  aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + aVet[nGajNumLot] + DToS(aVet[nGajDtVali]) == PADR(cCodPro, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProSol])) + __cLoteFo + __cLoteCt + __cNumLot + DToS(__dDtVali) .And. aVet[nGajQAtend] > 0 .And. Empty(aVet[nGajProalt]) .And. !aVet[nUGaj + 1] })) == 0 
				nPosIni := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + aVet[nGajNumLot] == PADR(cCodPro, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProSol])) + Space(Len(GAJ->GAJ_LOTEFO) + Len(GAJ->GAJ_LOTECT) + Len(GAJ->GAJ_NUMLOT)) .And. !aVet[nUGaj + 1] .And. Empty(aVet[nGajProalt])})
			Endif
		EndIf 
	Endif
  
	If nPosIni == 0  
		If (nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProAlt] == PADR(cCodPro, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt])) .And. !aVet[nUGaj + 1] .And. aVet[nGajQtdSol] > aVet[nGajQtdAte]})) == 0
			nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] == PADR(cCodPro, Len(oGDGaj:aCols[oGDGaj:nAt, nGajProSol])) .And. !aVet[nUGaj + 1] .And. aVet[nGajQtdSol] > aVet[nGajQtdAte] .And. Empty(aVet[nGajProalt])})
		Endif
	Endif 
 
	If nPosGD <> 0 
		nResto  := oGdGaj:aCols[nPosGD,nGAJQtdSol] - oGdGaj:aCols[nPosGD,nGAJQtdAte]
		cProsol := oGdGaj:aCols[nPosGD,nGAJProSol]
		cDProsol:= oGdGaj:aCols[nPosGD,nGajDesPro]
		cCbMatM := oGdGaj:aCols[nPosGD,nGajCbMatm]
		cProdAlt:= oGDGaj:aCols[nPosGD, nGajProAlt]
		cDescAlt:= oGDGaj:aCols[nPosGD, nGajDPrAlt]
		cCrm    := oGDGaj:aCols[nPosGD, nGajCodCrm]
		cDesCrm := oGDGaj:aCols[nPosGD, nGajDesCrm]  

		If lItePre
			cItePri := oGdGaj:aCols[nPosGD,nGajItePre]
		Endif   
  
		oGdGaj:aCols[nPosGD,nGAJQtdSol] := oGdGaj:aCols[nPosGD,nGAJQtdAte]      
  
		If  !Empty(oGdGaj:aCols[nPosGD,nGAJQAtend])
			oGDGaj:aCols[nPosGD, nUGaj + 1] := .T.
		Endif		
	
  
	oGDGaj:AddLine(.T.,.F.)
	oGDGaj:lNewLine := .F.
    nPosGD := Len(oGDGaj:aCols)            
  
	oGDGaj:aCols[nPosGD, nGajQtdSol] := nResto
	oGDGaj:aCols[nPosGD, nGajProSol] := cProsol
	oGDGaj:aCols[nPosGD, nGajDesPro] := cDProsol
	oGDGaj:aCols[nPosGD, nGajCbMatm] := cCbMatM
	oGDGaj:aCols[nPosGD, nGajProAlt]:= cProdAlt
	oGDGaj:aCols[nPosGD, nGajDPrAlt]:= cDescAlt
	oGDGaj:aCols[nPosGD, nGajCodCrm]:= cCrm    
	oGDGaj:aCols[nPosGD, nGajDesCrm]:= cDesCrm 
		If !Empty(cItePri)
			oGdGaj:aCols[nPosGD,nGajItePre] := cItePri
		Endif
	oGdGaj:oBrowse:Refresh()
	Endif

RestArea(aArea)
Return(IIF(nPosIni == 0, nPosGd, nPosIni))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VERTOT บ Autor ณ Mario Arizono      บ Data ณ  02/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica itens da solicitacao que estao totalmente atendi  บฑฑ
ฑฑบ          ณdos e marca.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  	                   

Static Function FS_VERTOT(oGaj)
 Local nPosGaj := 0
  
 For nPosGaj := 1 to len(oGaj:aCols)
   If oGaj:aCols[nPosGaj, nGajQtdAte] == oGaj:aCols[nPosGaj,nGajQtdSol]
    oGaj:aCols[nPosGaj, nUGaj + 1] := .T.
   EndIf
 Next nPosGaj    
 
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_BARKIT บ Autor ณ Mario Arizono      บ Data ณ  27/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o codigo de barras do kit digitado.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Function HS_BarKit()   
 Local aArea   := GetArea() 
 Local lVldkit := .T.
 Local cSql    := ""
 Local nPosCpo := 0
 Local lRetVld := .T.
 
 cSQL := "SELECT GHJ.GHJ_CCOKIT, GHJ.GHJ_QTDKIT, GHJ.GHJ_ALMORI, GHJ.GHJ_LOTEFO, GHJ.GHJ_LOTECT, GHJ.GHJ_NUMLOT,"
 cSQL += "GHJ.GHJ_DTVALI, GHI.GHI_SEQKIT "
 cSQL += " FROM " + RetSQLName("GHJ") + " GHJ"                                   
 cSQL += " JOIN " + RetSQLName("GHI") + " GHI ON GHI.GHI_SEQKIT = GHJ.GHJ_SEQKIT AND GHI.GHI_FILIAL = '" + xFilial("GHI") + "' AND GHI.D_E_L_E_T_ <> '*'" 
 cSQL += " WHERE"
 cSQL += "     GHJ.GHJ_FILIAL = '" + xFilial("GHJ") + "' AND GHJ.D_E_L_E_T_ <> '*' "   
 cSQL += " AND GHI.GHI_BARKIT = '" + M->GAI_BARKIT + "' AND GHJ.GHJ_ALMORI = '" + M->GAI_ALMORI + "' AND GHI.GHI_SOLICI = '" + SPACE(LEN(GHI->GHI_SOLICI)) + "' "
 cSQL += " ORDER BY GHJ_FILIAL, GHJ_ITEMBR "
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 
 If Eof()
  Hs_MsgInf(STR0080, STR0008, STR0081) //"Nใo existe kit virtual com este c๓digo de barras."##"Atencao"##"Valida็ใo do kit virtual"
  DbCloseArea()
  lVldKit := .F.
 Else
  If Ascan(aKitVirt,{|x|x[1] == QRY->GHI_SEQKIT}) > 0
   Hs_MsgInf(STR0082, STR0008, STR0081)//"Kit jแ foi totalmente atendido nesta solicita็ใo e nใo poderแ ser usado."##"Atencao"##"Valida็ใo kit virtual"
   lVldKit := .F.
  Endif 
 Endif
 While !Eof() .And. lVldKit
  If 	Rastro(QRY->GHJ_CCOKIT)
   nPosCpo := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProAlt] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + ;
                    aVet[nGajNumLot] + Dtos(aVet[nGajDtVali]) == QRY->GHJ_CCOKIT + QRY->GHJ_LOTEFO + QRY->GHJ_LOTECT + QRY->GHJ_NUMLOT + ;
                    QRY->GHJ_DTVALI .And. !aVet[nUGaj + 1] .And. (aVet[nGAJQtdSol] - aVet[nGAJQtdAte]) >= QRY->GHJ_QTDKIT})
   If nPosCpo == 0
    nPosCpo := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + ;
                    aVet[nGajNumLot] + DToS(aVet[nGajDtVali]) == QRY->GHJ_CCOKIT + QRY->GHJ_LOTEFO + QRY->GHJ_LOTECT + QRY->GHJ_NUMLOT +;
                    QRY->GHJ_DTVALI .And. !aVet[nUGaj + 1] .And. (aVet[nGAJQtdSol] - aVet[nGAJQtdAte]) >= QRY->GHJ_QTDKIT})
   Endif   
  Endif 
  If nPosCpo == 0 
   nPosCpo := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProAlt] == QRY->GHJ_CCOKIT .And. (aVet[nGajQtdSol] - aVet[nGajQtdAte]) >= QRY->GHJ_QTDKIT .And. !aVet[nUGaj + 1]})   
   If nPosCpo == 0
    nPosCpo := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] == QRY->GHJ_CCOKIT .And. (aVet[nGajQtdSol] - aVet[nGajQtdAte]) >= QRY->GHJ_QTDKIT .And. !aVet[nUGaj + 1]})
   Endif
  Endif 
  
  If HS_SeekRet("SB1", "QRY->GHJ_CCOKIT", 1, .F.)
     
   If !(lVldKit := (IIF(__cRequis <> "2", HS_CONEST(SB1->B1_COD, __cCtrEst)[1], .T.)))
    Hs_MsgInf(STR0083 + SB1->B1_COD + STR0084, STR0008, STR0081)//"Item [ "##" ] nใo pode movimentar estoque, verifique cadastro de produto."##"Atencao"##"Valida็ใo do kit Virtual"
    Exit
   ElseIf nPosCpo == 0
    Hs_MsgInf(STR0085, STR0008, STR0081) //"Itens da solicita็ใo nใo podem ser atendidos pelo Kit Virtual."##"Atencao"##"Valida็ใo do kit Virtual"
    lVldKit := .F.   
    Exit
   ElseIf !(lVldKit := (HS_ValDat(4, M->GAI_REGATE,,,,STR0079, SB1->B1_COD)[1]) .AND. HS_M05VSld(SB1->B1_COD , M->GAI_ALMORI, oGDGaj:aCols[nPosCpo, nGajQAtend] + QRY->GHJ_QTDKIT, QRY->GHJ_LOTEFO, QRY->GHJ_LOTECT, QRY->GHJ_NUMLOT, Stod(QRY->GHJ_DTVALI)))
    Exit 
   ElseIf BlqInvent(SB1->B1_COD, M->GAI_ALMORI) 
    Hs_MsgInf(STR0083 + SB1->B1_COD + STR0086, STR0008, STR0081) //"Item [ "##" ] estแ sendo inventariado e nใo pode movimentar estoque."##"Atencao"##"Valida็ใo do kit virtual"
    lVldKit := .F.
    Exit
   Endif
  Endif 
  nPosCpo := 0
  DbSkip()
 
 End  
 
 If lVldKit 
  DbSelectArea("QRY")
  DbGoTop()
  While !Eof()
   If Rastro(QRY->GHJ_CCOKIT)
    __cLOTEFO   := QRY->GHJ_LOTEFO
    __cLOTECT   := QRY->GHJ_LOTECT
    __cNUMLOT   := QRY->GHJ_NUMLOT
    __dDTVALI   := Stod(QRY->GHJ_DTVALI)
   Endif
   
    HS_M05VMM(QRY->GHJ_CCOKIT, 4, QRY->GHJ_QTDKIT, .T.)
    
    If Ascan(aKitVirt,{|x|x[1] == QRY->GHI_SEQKIT}) == 0
     AADD(aKitVirt, {QRY->GHI_SEQKIT, M->GAI_SOLICI})
    Endif              
    
    M->GAI_BARKIT := SPACE(LEN(M->GAI_BARKIT))
   DbSelectArea("QRY")
   DbSkip() 
  End 
 Endif   
 DbCloseArea()
 RestArea(aArea)
Return(lVldKit)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CposGAIบ Autor ณ Patricia Queiroz   บ Data ณ  05/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Altera as variaveis de memoria dos campos GAI_DATSOL E     บฑฑ
ฑฑบ          ณ GAI_HORSOL, para gravar a data atual, caso ocorra a virada บฑฑ
ฑฑบ          ณ de um dia para outro.                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function HS_CposGAI()

 Local nForGAI  := 0, nForVet := 0
 Local aCposGAI := {{"GAI_DATSOL", "GAI_HORSOL"}}

 If GCY->GCY_ATENDI <> "2"
  For nForGAI := 1 To Len(aCposGAI)
   For nForVet := 1 To 2
    If !Empty(&("M->" + aCposGAI[nForGAI, nForVet]))
     &("M->" + aCposGAI[nForGAI, nForVet]) := IIF(nForVet == 1, dDataBase, Time())
    EndIf 
   Next
  Next
  
  If FunName() == "HSPAHM05"
   oEnchoice:Refresh()
   dDatMov := M->GAI_DATSOL
   cHorMov := M->GAI_HORSOL
  ElseIf FunName() $ "HSPAHM04/HSPAHM30"
   oEnGAI:Refresh()
  EndIf
 EndIf  
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},; //1 "Pesquisar"
                     {OemToAnsi(STR0003), "HS_AteM05", 0, 2, 0, nil},; //2 "Visualizar"
                   	 {OemToAnsi(STR0004), "HS_AteM05", 0, 3, 0, nil},; //3 "Solicitar"
                   	 {OemToAnsi(STR0005), "HS_AteM05", 0, 4, 0, nil},; //4 "Atender"
                   	 {OemToAnsi(STR0040), "HS_AteM05", 0, 4, 0, nil},; //5 "Dev. por Solic."
                   	 {OemToAnsi(STR0041), "HS_AteM05", 0, 4, 0, nil},; //6 "Dev. por Atend."  
                   	 {OemToAnsi(STR0045), "HS_TraM05", 0, 4, 0, nil},; //7 "Transferencia"
             	     {OemtoAnsi(STR0036), "HS_RelM05", 0, 3, 0, nil},; //8 "Reimpressao"
              	     {OemtoAnsi(STR0033), "HS_FicM05", 0, 3, 0, nil},; //9 "Docs/Relat."
             	     {OemtoAnsi(STR0007), "HS_LegM05", 0, 1, 0, nil}}  //10 "Legenda" 
Return(aRotina)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GRVGAJ บ Autor ณ Mario Arizono      บ Data ณ  09/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao responsavel para gravacao dos itens da tabela GAJ.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/       

Function HS_GRVGAJ(nPosGaj, nPosSD3, cD3NumSeq, cD3Doc)

 Local aArea := GetArea()
 Local lAchouGaj  := .F.
 Local lMvR03CImp := UPPER(GETMV("MV_R03CIMP",,"N")) 
 Local nPosItem   := IIF(ValType(nPosGaj) <> "U", nPosGaj, aPosGaj[nPosSD3, 1]) 
  
 DbSelectArea("GAJ")
 DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
 lAchouGaj := DbSeek(xFilial("GAJ") + M->GAI_SOLICI + oGDGaj:aCols[nPosItem, nGajIteSol])
       
 RecLock("GAJ", !lAchouGaj)
  HS_GRVCPO("GAJ", oGDGaj:aCols, oGDGaj:aHeader, nPosItem)
  GAJ->GAJ_LOGATE := HS_LogArq() 
  If !lAchouGaj
   GAJ->GAJ_FILIAL := xFilial("GAJ")
   GAJ->GAJ_SOLICI := M->GAI_SOLICI
   GAJ->GAJ_LOGARQ := HS_LogArq()
  EndIf 
 MsUnlock() 
 
 If M->GAI_REQUIS == "1"
  FS_GrvMM(cD3NumSeq, cD3Doc, nPosItem, oGDGaj:aCols[nPosItem, nUGAJ+1])
 Endif
 
 If lMvR03Cimp == "S"
  AADD(aIAtend, {oGDGaj:aCols[nPosItem, nGajIteSol], oGDGaj:aCols[nPosItem, nGajQAtend],cD3Doc})  
 Endif
  
 RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHs_ConMed บ Autor ณ Mario Arizono      บ Data ณ  25/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que retorna vetor com conteudo para validacao no    บฑฑ
ฑฑบ          ณ lancamento de mat/med.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณparametrosณ  cRegate - Registro de atendimento.                        ณฑฑ
ฑฑณ          ณ  cReserv - Reservado que indica se e Rn ou nao.            ณฑฑ
ฑฑณ          ณ  cSeqDes - Sequencial da despesa quando for devolucao.     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณRetorno   ณ {aRetCon}                                                  ณฑฑ
ฑฑณ          ณ            1 - Data de Atendimento                         ณฑฑ
ฑฑณ          ณ            2 - Hora de Atendimento                         ณฑฑ
ฑฑณ          ณ            3 - Data da Alta                                ณฑฑ
ฑฑณ          ณ            4 - Hora da Alta                                ณฑฑ
ฑฑณ          ณ            5 - Tipo da Alta                                ณฑฑ
ฑฑณ          ณ            6 - Conteudo parametro para permitir solicitar/dณฑฑ
ฑฑณ          ณ                evolver com alta.                           ณฑฑ
ฑฑณ          ณ            7 - Data ultimo fechamento do mes.              ณฑฑ
ฑฑณ          ณ            8 - Tipo de atendimento                         ณฑฑ  
ฑฑณ          ณ            9 - Nr. Seq. Guia                               ณฑฑ     
ฑฑณ          ณ            10- Quantidade                                  ณฑฑ  
ฑฑณ          ณ            11- Nr. Solicitacao                             ณฑฑ 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/       

Function HS_ConMed(cRegate, cReserv, cSeqDes)

 Local aArea := GetArea()
 Local cMovAlta := IIf(!Empty(cSeqDes), GetNewPar("MV_DEVALTA","S"),AllTrim(GetMv("MV_LMMALTA")))
 Local dMvUlmes := GETMV("MV_ULMES") 
 Local aRetCon  := { CTOD("  /  /  "), "", CTOD("  /  /  "), "", "", "", CTOD("  /  /  "), "", "", 0, ""} 
 Local cSolici  := ""
 
 Default cRegate := ""
 Default cReserv := ""
 Default cSeqDes := "" 
  
  DbSelectArea("GCY")
  DbSetOrder(1)// GCY_FILIAL + GCY_REGATE 
  DbSeek(xFilial("GCY")+ cRegate)
   
  aRetCon[1] := GCY->GCY_DATATE
  aRetCon[2] := GCY->GCY_HORATE 
  aRetCon[6] := cMovAlta
  aRetCon[7] := dMvUlmes        
  aRetCon[8] := GCY->GCY_ATENDI
 
  If !Empty(cSeqDes)  
      cSolici  := HS_INIPADR("GD5", 1, cSeqDes, "GD5_SOLICI",,.F.)
      cReserv  := HS_INIPADR("GAI", 1, cSolici, "GAI_RESERV",,.F.)
   aRetCon[9]  := GD5->GD5_NRSEQG
   aRetCon[10] := GD5->GD5_QTDDES 
   aRetCon[11] := cSolici
  Endif 
  If !Empty(cReserv)
   aRetCon[3] := HS_INIPADR("GB2", 1, cRegate + cReserv,"GB2_DATALT",,.F.)
   aRetCon[4] := GB2->GB2_HORALT
   aRetCon[5] := GB2->GB2_TPALTA
  Else 
   aRetCon[3] := GCY->GCY_DATALT
   aRetCon[4] := GCY->GCY_HORALT
   aRetCon[5] := GCY->GCY_TPALTA
  Endif
  
 RestArea(aArea)
Return(aRetCon)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_QTDVAL บ Autor ณ Mario Arizono      บ Data ณ  09/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a quantidade que sera validada pelo estoque.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/       

Function FS_QTDVAL(cProsol, nPosGD, lLote, lNovLin)
 Local nQtdVal := 0 
 Local nPos    := 0
 Local nInicio := 1
    
 If !lNovLin
  nQtdVal := IIf(nPosGD > 0 .And. !Empty(oGDGaj:aCols[nPosGD, nGajProSol]), oGDGaj:aCols[nPosGD, nGajQAtend], 0) + M->GAI_QATEND
 Else

  WHILE (nPos := IIF(lLote, aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] + aVet[nGajLoteFo] + aVet[nGajLoteCt] + aVet[nGajNumLot] + DToS(aVet[nGajDtVali]) == cProSol + __cLoteFo + __cLoteCt + __cNumLot + DToS(__dDtVali)}, nInicio),;
         aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] == cProSol}, nInicio))) > 0 
  
   nQtdVal += oGDGaj:aCols[nPos, nGajQAtend]
  
   nInicio := nPos + 1
  
  EndDo
 
  nQtdVal += M->GAI_QATEND
 Endif                                                             
 
Return(nQtdVal)             

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUREQ  บ Autor ณ MARIO ARIZONO      บ Data ณ  29/05/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que preenche variavel com conteudo do campo          บฑฑ
ฑฑบ          ณGAI_REQUIS                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

FUNCTION FS_ATUREQ(nOpcM05)
 
 If STRZERO(nOpcM05, 2) $ "03/04" 
  __cRequis := M->GAI_REQUIS 
 Endif
 __cCtrEst := &("M->" + cAlias + "_CODLOC")
Return() 


/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFs_VldSald บ Autor ณ MARIO ARIZONO      บ Data ณ  29/08/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validar produtos sem saldo.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/ 
 
Static Function Fs_VldSald(oGaj, nOpcM05)
 Local lRet := .T., lVldSld := .T.
 Local nPos := 0
 Local cProMov := "", cMsg := ""
 
 __aVldSld := {}
 For nPos := 1 To Len(oGaj:aCols)
  If oGaj:aCols[nPos, nGajQAtend] > 0 .AND. IIf(nOpcM05 == 3, !oGaj:aCols[nPos, nUGAJ+1], .T.) 
   cProMov := PadR(AllTrim(oGaj:aCols[nPos, IIf(lMV_ProdAlt .And. !Empty(oGaj:aCols[nPos, nGajProAlt]), nGajProAlt, nGajProSol)]), Len(SB1->B1_COD))
       			     
   DbSelectArea("SB1")
   DbSetOrder(1) // B1_FILIAL + B1_COD 
   DbSeek(xFilial("SB1") + cProMov)			   

   lVldSld := IIf (HS_CONEST(SB1->B1_COD, M->GAI_CODLOC)[1], HS_M05VSld(cProMov, M->GAI_ALMORI, oGaj:aCols[nPos, nGajQAtend], oGaj:aCols[nPos, nGajLoteFo],  oGaj:aCols[nPos, nGajLoteCt],  oGaj:aCols[nPos, nGajNumLot], oGaj:aCols[nPos, nGajDtVali], .F.), .T.)   
    
   If !lVldSld 
    cMsg +=  IIF(!Empty(cMsg), ", " + Alltrim(cProMov), Alltrim(cProMov)) 
    Aadd(__aVldSld,{cProMov})
   Endif
  Endif
 Next nPos
 
 If !Empty(cMsg)
  Hs_MsgInf(STR0100 + cMsg + STR0101, STR0008, STR0001) //"Produto(s) ["##"] sem saldo em estoque."##"Aten็ใo"##"Valida็ใo mat/med"
 Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSXB บAutor  ณMicrosiga           บ Data ณ  04/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para ajutar a consulta padrao GCY, para arru- บฑฑ
ฑฑบ          ณmar a pesquisa por nome.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSXB()
Local aArea := GetArea()

DbSelectArea("SXB")
DbSetOrder(1)
If SXB->(DbSeek("GCY   202"))

	If SXB->XB_COLUNA <> "07"
		RecLock("SXB", .F.)
			Replace SXB->XB_COLUNA With "07"
		MsUnLock()
	EndIf

EndIf

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM05  บAutor  ณMicrosiga           บ Data ณ  04/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Guia Particular no Atendimento de Mat/Med             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function HS_GrvPart(cRegate,cConpart)
Local lRet := .T.
   DbSelectArea("GCY")
   DbSetOrder(1)
   DbSeek(xFilial("GCY") + cRegate)
   RegToMemory("GCY",.F.)
   HS_IGuiaP(cRegate, GCY->GCY_REGGER,  "0", GCY->GCY_ATENDI, GCY->GCY_DATATE, GCY->GCY_LOCATE)				   			 						
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ItSol  บ Autor ณ Saude              บ Data ณ  15/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica itens Atendidos da solicitacao com a Quantidade   บฑฑ
ฑฑบ          ณSolicitada para  Fechar a Solicita็ใo                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  	                   

Static Function FS_ItSol(oGaj)
Local nIten := 0

   
		For nIten := 1 To Len(oGDGaj:aCols)
 
			DbSelectArea("GAJ")
			DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
			If DbSeek(xFilial("GAJ") + M->GAI_SOLICI + oGDGaj:aCols[nIten, nGajIteSol])       
				If GAJ->GAJ_QTDSOL <> oGDGaj:aCols[nIten, nGajQtdSol]
 				    RecLock("GAJ", .F.)
				  	GAJ->GAJ_QTDSOL := oGDGaj:aCols[nIten, nGajQtdSol] 
				 	MsUnlock() 

				Endif 								
		
			Endif        
		Next

Return(nil)     