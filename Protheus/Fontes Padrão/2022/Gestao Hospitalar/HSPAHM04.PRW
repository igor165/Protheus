#INCLUDE "HSPAHM04.ch"
#include "protheus.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAHM04  ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ SOLICITACAO DE MAT/MED                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPAHM04()

Local bKeyF12   := SetKey(VK_F12, {|| FS_FilM04(.T.) } )
Local aCores := {{"GAI->GAI_FLGATE == '0'", 'BR_VERDE'   }, ;	    
                 {"GAI->GAI_FLGATE == '1'", 'BR_AMARELO' }, ;
                 {"GAI->GAI_FLGATE == '2'", 'BR_VERMELHO'}, ;
                 {"GAI->GAI_FLGATE == '4'", 'BR_CINZA'   }}

Private cCadastro   := STR0001 //"Solicitação de Materiais e Medicamentos"
Private cFilM04     := ""
Private cPerg       := "HSPM04"
Private cSetPerg    := "  "
Private lFilGm1     := .T.  /* SELECIONA FUNCIONARIO QUE PODE ENTRAR NO SETOR */
Private cGcsTipLoc  := "38" /* SELECIONA SETOR DE ENFERMAGEM E CIRURGICO      */
Private cGcyAtendi  := "0"
Private cGcsCodLoc  := ""
Private aRotina := MenuDef()
If !HS_Vldpar()
	Return(nil)
EndIf 
DbSelectArea("GAI")
If FS_FilM04(.F.) 
	mBrowse(06, 01, 22, 75, "GAI",,,,,, aCores,,,,,,,,cFilM04)
Endif 

Return(Nil)
/******************************************************************************************************************/
Function HS_LegM04()
 BrwLegenda(cCadastro, STR0007, {{"BR_VERDE"   , STR0018}, ; //"Legenda"###"Não atendida"
                                 {"BR_AMARELO" , STR0019}, ; //"Atendimento parcial"
                               	 {"BR_VERMELHO", STR0020}, ;  //"Atendimento Total"     
                               	 {"BR_CINZA", STR0021}}) // "Atendimento Encerrado"
Return(.T.)
/******************************************************************************************************************/
Function HS_MntM04(cAliasM04, nRegM04, nOpcM04)
Local cConSol 	:= IIF(Type("cNumSol") # "U", cNumSol, "")
Local cOpc    	:= ""
Local nGDOpc  	:= 0
Local nOpcDlg 	:= 0
Local cSetor  	:= ""
Local aSize 	:= {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local aCpos 	:= {}, aCposAlt := IIF(nOpcM04 == 3 .OR. nOpcM04 == 4, {"GAI_QATEND","GAI_CBMATM"},{})
Local aButtons 	:= {}
Local lLMMALTA	:= iif(getnewpar("MV_LMMALTA","N") == "S",.t.,.f.)
Private aHGaj 	:= {}, aCGaj := {}, oEnGai, cCpoNao := "", aMatClone := {}
Private aTela 	:= {}, aGets := {}, oGDGaj, nUGaj := 0

Private nGajProSol := 0, nGajDesPro := 0, nGajQtdSol := 0, nGajPerTro := 0, nGajLoteFo := 0, nGajLoteCt := 0
Private nGajNumLot := 0, nGajDtVali := 0, nGajPctKit := 0, nGajProAlt := 0, nGajDPrAlt := 0, nGajCodKit := 0
Private nGajDesKit := 0, nGajCbMatM := 0
Private __cReservGAV := ""
Private dDatSolGrv
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine aRotina quando for posto de enfermagem pois em alguns casos,    ³     
//³ o sistema estava redefinindo o aRotina indevidamente apos a solicitacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FunName() == "HSPAHM30"
    aRotina := Hs_RotHM30()
EndIf

cOpc := IIF(!Empty(cConSol) .And. FunName() == "HSPAHM30",StrZero(nOpcM04, 2),StrZero(aRotina[nOpcM04, 4], 2))  
nGDOpc  := IIf(cOpc $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)

If FunName() $ "HSPM24PA" .Or. FunName() $ "HSPM24AA"
	nOpcM04	:= 3
	nGDOpc	:= 3
	cOpc	:= "03"
EndIf

If     cOpc == "04" .And. GAI->GAI_FLGATE <> "0"
	HS_MsgInf(STR0009 + Chr(13) + Chr(10) + ; //"A solicitação selecionada não pode ser alterada "
	STR0010 + IIf(GAI->GAI_FLGATE == "1", STR0011, STR0012), STR0008, STR0001) //"porque já foi atendida "###"parcialmente"###"totalmente"###"Atenção"###"Solicitação de Materiais e Medicamentos"
	Return(Nil)
ElseIf cOpc == "05" .And. GAI->GAI_FLGATE <> "0"
	HS_MsgInf(STR0013 + Chr(13) + Chr(10) + ; //"A solicitação selecionada não pode ser exluída "
	STR0010 + IIf(GAI->GAI_FLGATE == "1", STR0011, STR0012), STR0008, STR0001) //"porque já foi atendida "###"parcialmente"###"totalmente"###"Atenção"###"Solicitação de Materiais e Medicamentos"
	
	Return(Nil)
EndIf

RegToMemory("GAI", IIf(cOpc == "03", .T., .F.))

If !Empty(cConSol) .And. Inclui .And. cOpc == "03"
	Inclui := .F.
Endif
cCpoNao := "GAJ_QATEND/GAJ_QTDATE/GAJ_QDEVOL/GAJ_QTDDEV/GAJ_CODJUS/GAJ_JUSTIF/GAJ_LOTEFO/GAJ_LOTECT/GAJ_NUMLOT/GAJ_DTVALI/GAJ_ITEPRE"

HS_BDados("GAJ", @aHGaj, @aCGaj, @nUGaj, 1, M->GAI_SOLICI, IIf(cOpc == "03" .And. Empty(cConSol), Nil, "GAJ->GAJ_SOLICI == '" + IIF(Empty(cConSol),M->GAI_SOLICI, cConSol) + "'"),,,,, cCpoNao)

nGajIteSol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_ITESOL"})
nGAJProSol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_PROSOL"})
nGajDesPro := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DESPRO"})
nGajCbMatm := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CBMATM"})
nGAJQtdSol := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_QTDSOL"})
nGAJCodKit := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_CODKIT"})
nGAJDesKit := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DESKIT"})
nGajProAlt := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_PROALT"})
nGajDPrAlt := aScan(aHGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_DPRALT"})


If cOpc == "03"  .And. Empty(cConSol)
	aCGaj[1, nGajIteSol] := Soma1(aCGaj[1, nGajIteSol], Len(aCGaj[1, nGajIteSol]))
ElseIf !Empty(cConSol)
	If Empty(aCGaj[1, nGajIteSol])
		aCGaj[1, nGajIteSol] := Soma1(aCGaj[1, nGajIteSol], Len(aCGaj[1, nGajIteSol]))
	Endif
EndIf

If FunName() $ "HSPM24AA/HSPM24PA/HSPAHM30" .And. Empty(cConSol) .Or. !Empty(cConSol) .And. cOpc == "03"
	If FunName() == "HSPAHM30"
		DbSelectArea("GCY")
		DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
		DbSeek(xFilial("GCY") + GAV->GAV_REGATE)
	EndIf
	If !EMPTY(GCY->GCY_TPALTA) .and. !lLMMALTA
		HS_MsgInf(STR0048, STR0008, STR0001) //"Atendimento com alta. Não é possível solicitar materiais e medicamentos."###"Atenção"###"Solicitação de Materiais e Medicamentos"
		Return(Nil)
	EndIf
	M->GAI_REGATE := GCY->GCY_REGATE
	HS_SeekRet("GCY", "M->GAI_REGATE", 1, .F., {"GAI_NOMPAC", "GAI_CODLOC"}, {"GCY_NOME", "GCY_CODLOC"})
	
	If FunName() == "HSPAHM30" .And. GAV->GAV_RESERV $ "012345" //Bercario
		M->GAI_NOMPAC := GAV->GAV_NOME
		M->GAI_CODLOC := GAV->GAV_CODLOC
		If GAI->(FieldPos("GAI_QUARTO")) > 0
			M->GAI_QUARTO := GAV->GAV_QUARTO
			M->GAI_LEITO  := GAV->GAV_LEITO
		Endif
		If HS_EXISDIC({{"C", "GAI_RESERV"}}, .F.)
			M->GAI_RESERV := GAV->GAV_RESERV
		Endif
	Else
		If GAI->(FieldPos("GAI_QUARTO")) > 0
			M->GAI_QUARTO := GCY->GCY_QUAINT
			M->GAI_LEITO  := GCY->GCY_LEIINT
		Endif
	Endif
	
	HS_SeekRet("GCS", "M->GAI_CODLOC", 1, .F., {"M->GAI_NOMLOC", "M->GAI_ALMORI", "M->GAI_ALMSOL"}, {"GCS_NOMLOC", HS_ArmFarS(.F.), "GCS_ARMSET"})
	M->GAI_DSALMO := HS_IniPadr("SX5", 1, "AL" + M->GAI_ALMORI, "X5_DESCRI",, .F.)
	M->GAI_DSASOL := HS_IniPadr("SX5", 1, "AL" + M->GAI_ALMSOL, "X5_DESCRI",, .F.)
	If M->GAI_DATSOL == GCY->GCY_DATALT .And. M->GAI_HORSOL > GCY->GCY_HORALT
		M->GAI_HORSOL := GCY->GCY_HORALT
	Else
		M->GAI_HORSOL := Time()
	EndIf
	If !Empty(cConSol)
		M->GAI_URGENC := HS_IniPadr("GAI", 1, cConSol, "GAI_URGENC",, .F.)
	Endif
	If HS_ExisDic({{"C","GAI_CRMPRE"}} , .F.)
		If !Empty(cConSol)
			M->GAI_CRMPRE := POSICIONE("GAI",1,XFILIAL("GAI")+cConSol,"GAI_CRMPRE")
			M->GAI_CRMDES := POSICIONE('SRA',11,XFILIAL('SRA')+M->GAI_CRMPRE,'RA_NOME')
		Endif
	EndIf
EndIf

DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
DbSeek("GAI")
While !Eof() .And. SX3->X3_ARQUIVO == "GAI"
	If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .Or. (aScan(aCposAlt, SX3->X3_CAMPO) > 0)
		aAdd(aCpos, SX3->X3_CAMPO)
	EndIf
	
	DbSkip()
End
aMatClone := aClone(aCGaj)

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

If FunName() $ "HSPM24PA" .Or. FunName() $ "HSPM24AA"
	nOpcM04	:= 3
	nGDOpc	:= 3
EndIf

If ExistBlock("HSM04ENC")

	aButAux := ExecBlock("HSM04ENC", .F., .F.,Nil)
	AEval(aButAux, {|x|AAdd(aButtons,x)})
	
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
oEnGai := MsMGet():New("GAI", nRegM04, nOpcM04,,,, aCpos, aPObjs[1], , 2)
If FunName() $ "HSPM24AA/HSPM24PA/HSPAHM30" 
	oEnGai:aEntryCtrls[aScan(oEnGai:aGets, {|x| "GAI_REQUIS" $ x}) ]:lReadOnly := .T.
	oEnGai:aEntryCtrls[aScan(oEnGai:aGets, {|x| "GAI_REGATE" $ x}) ]:lReadOnly := .T.
	If !Empty(cConSol)
		oEnGai:aEntryCtrls[aScan(oEnGai:aGets, {|x| "GAI_URGENC" $ x}) ]:lReadOnly := .T.
	Endif
EndIf

oEnGai:oBox:align := CONTROL_ALIGN_TOP

oGDGaj := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,, "+GAJ_ITESOL",,, 99999,,,,, aHGaj, aCGaj)
oGDGaj:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(IIf(ExistBlock("HSPM04OK"),Execblock("HSPM04OK",.f.,.f.),.T.) .And. Obrigatorio(aGets, aTela) .And. oGDGaj:TudoOk() .And. HS_ValSet(oGDGaj), oDlg:End(), nOpcDlg := 0)}, ;
{|| nOpcDlg := 0, oDlg:End()},,@aButtons))

If nOpcDlg == 0
	While __lSx8
		RollBackSxe()
	End
Else
	
	If dDataBase <> Date()
		If MsgYesNo(STR0067, STR0008)
			dDatSolGrv := dDataBase
		Else
			dDatSolGrv := Date()
		EndIf
	Else
		dDatSolGrv := M->GAI_DATSOL
	EndIf
	
	Begin Transaction
	FS_GrvM04(cOpc, aHGaj, oGDGaj, nUGaj)
	End Transaction
	
	While __lSx8
		ConfirmSx8()
	End
	
	If ExistBlock("HSGCFM04")
		Execblock("HSGCFM04", .F., .F.,Nil)
	Endif
	
	If cOpc $ "03/04"
		// Programa que Imprime Solicitacao
		HSPAHR03(GAI->GAI_SOLICI,"","",Posicione("SX1", 1, "HSPR0302", "X1_PRESEL"))
		If ExistBlock("HSPHRAP03")
			Execblock("HSPHRAP03", .F., .F., {GAI->GAI_SOLICI})
		EndIf
	Endif
EndIf
Return(Nil)

/******************************************************************************************************************/
Function HS_GFRequi(cGaiRequis, cCpo)
 Local lRet := .T.
 If     cGaiRequis == "1"
  If cCpo $ "GAI_ALMORI/GAI_ALMSOL/GAI_ALMORI" .Or. (cCpo == "GAI_CODLOC" .And. FunName() <> "HSPAHM05")
   lRet := .F.
  EndIf 
 ElseIf cGaiRequis == "2" // Consulmo Próprio
  If cCpo $ "GAI_REGATE/GAI_ALMORI/GAI_ALMSOL/GAI_ALMORI"
   lRet := .F.
  EndIf 
 ElseIf cGaiRequis == "3" // Transferencia                                             
  If cCpo $ "GAI_REGATE/GAI_CODLOC/GAI_ALMORI"
   lRet := .F.
  EndIf 
 EndIf                                   
Return(lRet)




/******************************************************************************************************************/
Static Function FS_GrvM04(cOpc, aHGaj, oGDGaj, nUGaj)
Local nForItens	:= 0, lFoundGai := .F., lFoundGaj := .F.
Local cMV_ATCRMD := GetMV("MV_ATCRMD") 
If cOpc <> "02"
	Begin Transaction
	DbSelectArea("GAI")
	DbSetOrder(1) // GAI_FILIAL + GAI_SOLICI
	If cOpc == "03" // Incluisão
		M->GAI_SOLICI := HS_VSxeNum("GAI", "M->GAI_SOLICI", 1)
	Else
		lFoundGai := DbSeek(xFilial("GAI") + M->GAI_SOLICI)
	EndIf
   
	If cOpc <> "05"
		RecLock("GAI", !lFoundGai)
		HS_GRVCPO("GAI")  
		GAI->GAI_DATSOL := dDatSolGrv
		GAI->GAI_HORSOL := Time()
		GAI->GAI_FILIAL := xFilial("GAI")
		GAI->GAI_FLGATE := "0"
		GAI->GAI_LOGARQ := HS_LogArq()
		MsUnLock()
		For nForItens := 1 To Len(oGDGaj:aCols)
			If !oGDGaj:aCols[nForItens, nUGaj + 1]
				DbSelectArea("GAJ")
				DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
				lFoundGaj := DbSeek(xFilial("GAJ") + M->GAI_SOLICI + oGDGaj:aCols[nForItens, nGajIteSol])
				RecLock("GAJ", !lFoundGaj)
				HS_GRVCPO("GAJ", oGDGaj:aCols, aHGaj, nForItens)
				GAJ->GAJ_FILIAL := xFilial("GAJ")
				GAJ->GAJ_SOLICI := M->GAI_SOLICI
				GAJ->GAJ_LOGARQ := HS_LogArq()
				If cMV_ATCRMD == "S"
					If HS_ExisDic({{"C","GAI_CRMPRE"}} , .F.)
						If Empty( M->GAI_CRMPRE ) 
							GAJ->GAJ_CODCRM := POSICIONE("GCY",1,XFILIAL("GCY")+M->GAI_REGATE,"GCY_CODCRM")
						Else
							GAJ->GAJ_CODCRM := M->GAI_CRMPRE	
						EndIf
					EndIf  
				Endif
  			  			
				MsUnlock()
			Else
				DbSelectArea("GAJ")
				DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
					If DbSeek(xFilial("GAJ") + M->GAI_SOLICI + oGDGaj:aCols[nForItens, nGajIteSol])
						RecLock("GAJ", .F.)
						DbDelete()
						MsUnlock()
						WriteSx2("GAJ")
					Endif	
			Endif
		Next
	Else 
		If lFoundGai
			RecLock("GAI", .F.)
			DbDelete()
			MsUnLock() 
			WriteSx2("GAI")
		EndIf 

		For nForItens := 1 To Len(oGDGaj:aCols)
			DbSelectArea("GAJ")
			DbSetOrder(1) // GAJ_FILIAL + GAJ_SOLICI + GAJ_ITESOL
			If DbSeek(xFilial("GAJ") + M->GAI_SOLICI + oGDGaj:aCols[nForItens, nGajIteSol])
				RecLock("GAJ", .F.)
				DbDelete()
				MsUnlock()
				WriteSx2("GAJ")
			Endif
		Next
	EndIf 
	End Transaction
EndIf
 
DbSelectArea("GAI")
Return(Nil)            


/******************************************************************************************************************/
Function HS_VldM04(cM04RVar, nPos)
Local lRet := .T.
Local bClean := {|| M->GAI_REGATE := Space(6), M->GAI_NOMPAC := Space(40), M->GAI_CODLOC := Space(2), M->GAI_NOMLOC := Space(30), oGDGaj:aCols := {}, oGDGaj:aCols := aClone(aMatClone), oGDGaj:oBrowse:Refresh() }
Local aArea      := GetArea()
Local aConest    := {}, aRetCon := {}
If cM04RVar == Nil
	cM04RVar := ReadVar()
EndIf

If cM04RVar == "M->GAI_REGATE"
	If !(lRet := !Empty(M->GAI_REGATE))
		HS_MsgInf(STR0014, STR0008, STR0001) //"O registro de atendimento é obrigatório."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	ElseIf IIF(!Empty(__cReservGAV), !(lRet := HS_SeekRet("GAV", "M->GAI_REGATE + __cReservGAV", 2, .F., {"GAI_NOMPAC", "GAI_CODLOC","GAI_QUARTO", "GAI_LEITO"}, {"GAV_NOME", "GAV_CODLOC","GAV_QUARTO", "GAV_LEITO"})),;
		!(lRet := HS_SeekRet("GCY", "M->GAI_REGATE", 1, .F., {"GAI_NOMPAC", "GAI_CODLOC"}, {"GCY_NOME", "GCY_CODLOC"})))
		HS_MsgInf(STR0015, STR0008, STR0001) //"Registro de atendimento não encontrado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	ElseIf !(lRet := HS_SeekRet("GCS", "M->GAI_CODLOC", 1, .F., {"M->GAI_NOMLOC", "M->GAI_ALMORI", "M->GAI_ALMSOL"}, {"GCS_NOMLOC", HS_ArmFarS(.F.), "GCS_ARMSET"}))
		HS_MsgInf(STR0024, STR0008, STR0001) //"Setor não encontrado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	ElseIf !(lRet := IIf(FunName() == "HSPAHM04", cSetPerg == M->GAI_CODLOC, .T.))
		HS_MsgInf(STR0025, STR0008, STR0001) //"Setor do Atendimento diferente do setor inicial."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	Else
		M->GAI_RESERV := __cReservGAV
		__cReservGAV := ""
		
		M->GAI_DATSOL := dDatabase
		M->GAI_HORSOL := Time()
		
		aRetCon := aRetCon := HS_ConMed(M->GAI_REGATE, M->GAI_RESERV)
		
		If aRetCon[8]  == "2" //Tipo de atendimento
			M->GAI_DATSOL := aRetCon[1] //Data atendimento
			M->GAI_HORSOL := aRetCon[2] //Hora atendimento
		Endif
		
		
		If !(lRet := !(M->GAI_DATSOL > dDataBase .Or. (M->GAI_DATSOL == dDataBase .And. M->GAI_HORSOL > Substr(Time(), 1, 50))))
			HS_MsgInf(STR0043, STR0042, STR0001) //"Solicitação não pode ser gerada com data posterior a data base."###"Verifique"###"Solicitação de Materiais e Medicamentos"
		ElseIf !(lRet := !(M->GAI_DATSOL < aRetCon[1] .Or. (M->GAI_DATSOL == aRetCon[1] .And. M->GAI_HORSOL < aRetCon[2])))
			HS_MsgInf(STR0044, STR0042, STR0001) //"Solicitação não pode ser gerada com data anterior a data do atendimento."### data da movimentação da solicitação não pode ser anterior a data do atendimento"###"Verifique"###"Solicitação de Materiais e Medicamentos"
		ElseIf !(lRet := !(aRetCon[5] == "99")) //Tipo alta
			HS_MsgInf(STR0022, STR0008, STR0001) //"Atendimento cancelado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
		ElseIf !Empty(aRetCon[3]) .And. !(lRet := !(Alltrim(aRetCon[6]) == "N") )  //Data alta ## Parametro alta
			HS_MsgInf(STR0023, STR0008, STR0001) //"Este atendimento já teve alta."###"Atenção"###"Solicitaçao de ~Materiais e Medicamentos"
		ElseIf !Empty(aRetCon[3]) .And. Alltrim(aRetCon[6]) == "S"//Data alta ## Parametro alta
			If FunName()== "HSPAHM05"
				If aRetCon[8] <> "2"
					M->GAI_DATSOL := aRetCon[3] //Data alta
					M->GAI_HORSOL := aRetCon[4] //Hora alta
				Endif
			Else
				If M->GAI_DATSOL == aRetCon[3] .And. M->GAI_HORSOL > aRetCon[4]
					M->GAI_HORSOL := aRetCon[4]
				Endif
				If !(lRet := !(M->GAI_DATSOL >  aRetCon[3] .Or. (M->GAI_DATSOL ==  aRetCon[3] .And. M->GAI_HORSOL > aRetCon[4])))
					HS_MsgInf(STR0045, STR0042, STR0001) //"Solicitação não pode ser gerada com data posterior a data da alta."###"Verifique"###"Verifique"
				Endif
			Endif
		Endif
		If FunName()== "HSPAHM05" .AND. lRet
			DbSelectArea("GCZ")
			DbSetOrder(2) // GCZ_FILIAL + GCZ_REGATE + GCZ_STATUS + GCZ_NRSEQG
			If !(lRet := DbSeek(xFilial("GCZ")+ M->GAI_REGATE + "0"))
				HS_MsgInf(STR0046, STR0042, STR0001) //"Não existe nenhuma guia em aberto para este atendimento."###"Verifique"###"Solicitação de Materiais e Medicamentos"
			ElseIf !(lRet:= !Empty(aRetCon[7]) .AND. (M->GAI_DATSOL > aRetCon[7])) // Ult. Fec. Est.
				HS_MsgInf(STR0047, STR0042, STR0001) //"A Data do lançamento é menor ou igual ao último fechamento de estoque, não será possível efetuar o lançamento."###"Verifique"###"Solicitação de Materiais e Medicamentos"
			Endif
		Endif
	Endif
	
	If lRet
		If !(IIf(FunName() $ "HSPAHM04/HSPM24AA/HSPM24PA/HSPAHM30", .T., cCodArmFar == M->GAI_ALMORI))
			HS_MsgInf(STR0026, STR0008, STR0001) //"Armazém do atendimento diferente do armazém da farmácia."###"Atenção"###"Solicitação de Materiais e Medicamentos"
			M->GAI_CODLOC := Space(Len(M->GAI_CODLOC))
			M->GAI_NOMLOC := Space(Len(M->GAI_NOMLOC))
			M->GAI_ALMORI := Space(Len(M->GAI_ALMORI))
			M->GAI_ALMSOL := Space(Len(M->GAI_ALMORI))
		Else
			M->GAI_DSALMO := HS_IniPadr("SX5", 1, "AL" + M->GAI_ALMORI, "X5_DESCRI",, .F.)
			M->GAI_DSASOL := HS_IniPadr("SX5", 1, "AL" + M->GAI_ALMSOL, "X5_DESCRI",, .F.)
		Endif
		
	Else
		M->GAI_DATSOL := CToD("")
		M->GAI_HORSOL := Space(Len(M->GAI_HORSOL))
	Endif
	
	// CONTROLE DO MEDICO DA PRESCRICAO
	If HS_ExisDic({{"C","GAI_CRMPRE"}} , .F.)
		M->GAI_CRMPRE := POSICIONE("GCY",1,XFILIAL("GCY")+M->GAI_REGATE,"GCY_CODCRM")
		M->GAI_CRMDES := POSICIONE('SRA',11,XFILIAL('SRA')+M->GAI_CRMPRE,'RA_NOME')
	EndIf
	
ElseIf cM04RVar == "M->GAI_ALMORI" /* valida armazem de origem */
	If !(lRet := HS_SeekRet("SX5","'AL'+M->GAI_ALMORI", 1, .F., "M->GAI_DSALMO", "X5_DESCRI"))
		HS_MsgInf(STR0027, STR0008, STR0001)  //"Almoxarifado de Origem não encontrado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	Endif
	
ElseIf cM04RVar == "M->GAI_ALMSOL" /* valida armazem solicitante*/
	If !(lRet := HS_SeekRet("SX5","'AL'+M->GAI_ALMSOL", 1, .F., "M->GAI_DSASOL", "X5_DESCRI"))
		HS_MsgInf(STR0028, STR0008, STR0001) //"Almoxarifado de Destino não encontrado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	ElseIf FunName() == "HSPAHM05" .And. M->GAI_REQUIS == "3" .And. M->GAI_ALMORI == M->GAI_ALMSOL
		lRet := .F.
		HS_MsgInf(STR0029, STR0008, STR0001)  //"Almoxarifado de Destino inválido."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	Endif
	
ElseIf cM04RVar == "M->GAI_CODLOC" /* valida setor */
	If !(lRet := HS_SeekRet("GCS", "M->GAI_CODLOC", 1, .F., {"M->GAI_NOMLOC", "M->GAI_ALMORI", "M->GAI_ALMSOL"}, {"GCS_NOMLOC", HS_ArmFarS(.F.), "GCS_ARMSET"}))
		HS_MsgInf(STR0030, STR0008, STR0001) //"Setor de atendimento não encontrado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
		Return(.F.)
	Endif
	If FunName() == "HSPAHM05" .And. M->GAI_REQUIS == "1" //Paciente
		If M->GAI_ALMORI <> cCodArmFar
			M->GAI_ALMORI := Space(len(GAI->GAI_ALMORI))
			M->GAI_ALMSOL := Space(len(GAI->GAI_ALMSOL))
			HS_MsgInf(STR0031, STR0008, STR0001) //"Armazém do setor selecionado diferente do armazém da farmácia."###"Atenção"###"Solicitação de Materiais e Medicamentos"
			Return(.F.)
		EndIf
	Endif
	M->GAI_DSALMO := Posicione("SX5", 1, xFilial("SX5")+"AL"+M->GAI_ALMORI, "X5_DESCRI")
	M->GAI_DSASOL := Posicione("SX5", 1, xFilial("SX5")+"AL"+M->GAI_ALMSOL, "X5_DESCRI")
	
ElseIf cM04RVar == "M->GAI_REQUIS" /*zera getdados e nome regger do paciente se muda o combur REQUISITA PARA*/
	lRet := PERTENCE("123")
	If MsgYesNo(STR0032, STR0008) //"Ao se alterar o destino da requisição, todos os dados já informados serão perdidos. Confirma? "###"Atenção"
		Eval( bclean )
		If M->GAI_REQUIS == "3"
			M->GAI_CODLOC := IIf(FunName() == "HSPAHM04", cGCSCodLoc, cCodLoc_Far)
			HS_SeekRet("GCS", "M->GAI_CODLOC", 1, .F., {"M->GAI_NOMLOC", "M->GAI_ALMORI"}, {"GCS_NOMLOC", "GCS_ARMSET"})
			M->GAI_DSALMO := Posicione("SX5", 1, xFilial("SX5")+"AL"+M->GAI_ALMORI, "X5_DESCRI")
		Endif
	EndIf
	If Type("__cRequis") # "U"
		__cRequis := M->GAI_REQUIS
	Endif
ElseIf cM04RVar == "M->GAJ_QTDSOL" /* valida quantidade solicitada */
	If (lRet := HS_VQtdMM(M->GAJ_QTDSOL,, oGDGaj:aCols[oGDGaj:nAt, nGajProSol]))
		If FunName() == "HSPAHM05" .And. (lRet := HS_M05VSld(oGDGaj:aCols[oGDGaj:nAt, nGajProSol], M->GAI_ALMORI, ;
			M->GAJ_QTDSOL, oGDGaj:aCols[oGDGaj:nAt, nGajLoteFo], ;
			oGDGaj:aCols[oGDGaj:nAt, nGajLoteCt], oGDGaj:aCols[oGDGaj:nAt, nGajNumLot], ;
			oGDGaj:aCols[oGDGaj:nAt, nGajDtVali]))
			oGDGaj:aCols[oGDGaj:nAt, nGajQAtend] := M->GAJ_QTDSOL
			oGDGaj:aCols[oGDGaj:nAt, nGajQtdAte] := M->GAJ_QTDSOL
		Endif
	Endif
	
ElseIf cM04RVar == "M->GAJ_PROSOL"
	If !(lRet := !Empty(M->GAJ_PROSOL))
		HS_MsgInf(STR0016, STR0008, STR0001 ) //"O código do mat/med é obrigatório."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	ElseIf !( lRet := HS_SeekRet("SB1", "M->GAJ_PROSOL", 1, .F., IIf(nPos == Nil, {"GAJ_DESPRO","GAJ_CBMATM"}, {"oGDGaj:aCols["+STR(nPos)+", nGajDesPro]","oGDGaj:aCols["+STR(nPos)+", nGajCbMatM]"}), {"B1_DESC","B1_CODBAR"}) )
		HS_MsgInf(STR0017, STR0008, STR0001) //"Mat/Med não encontrado."###"Atenção"###"Solicitação de Materiais e Medicamentos"
	ElseIf !(lRet := HS_VQtdMM(IIF(FunName() $ "HSPAHM04/HSPM24AA/HSPM24PA/HSPAHM30", oGDGaj:aCols[oGDGaj:nAt, nGajQtdSol], M->GAI_QATEND),, M->GAJ_PROSOL))
	ElseIf FunName() $ "HSPAHM04/HSPM24AA/HSPM24PA/HSPAHM30"
		cCodProalt := HS_PROALT(M->GAJ_PROSOL)
		If M->GAI_REQUIS <> "2"
			aConest := HS_CONEST(IIF(!Empty(cCodProalt), cCodProalt, M->GAJ_PROSOL), M->GAI_CODLOC)
			
			If !aConest[1]
				Hs_MsgInf(STR0055 + IIF(!aConest[3], IIF(!Empty(cCodProalt), STR0060 + "[" + ALLTRIM(cCodProalt)+"]",;
				STR0059+ "[" + ALLTRIM(M->GAJ_PROSOL)+"]"),STR0061 + "[" + ALLTRIM(M->GAI_CODLOC)+ "]") + STR0058,STR0008,STR0056)//"Não é possivel selecionar esse item para a solicitação de Materiais e Medicamentos, pois o "##" produto alternativo "##" produto principal "##"setor"##" " está definido em seu cadastro para não movimentar estoque.""
				lRet := .F.
			Endif
		Endif
		If lRet .And. !(HS_M04Kit(M->GAJ_PROSOL, oGDGaj:aCols[IIf(nPos == Nil, oGDGaj:nAt, nPos), nGajQtdSol], , , M->GAI_REQUIS))
			If !Empty(cCodProalt)
				oGDGaj:aCols[IIf(nPos == Nil, oGDGaj:nAt, nPos), nGajProAlt] := cCodProalt
				oGDGaj:aCols[IIf(nPos == Nil, oGDGaj:nAt, nPos), nGajDPrAlt] := HS_INIPADR("SB1",1, cCodProalt, "B1_DESC",,.F.)
			ElseIf Empty(cCodProalt) .AND. !EMPTY(oGDGaj:aCols[oGDGaj:nAt, nGajProAlt])
				oGDGaj:aCols[IIf(nPos == Nil, oGDGaj:nAt, nPos), nGajProAlt] := Space(Len(SB1->B1_COD))
				oGDGaj:aCols[IIf(nPos == Nil, oGDGaj:nAt, nPos), nGajDPrAlt] := Space(Len(SB1->B1_DESC))
			Endif
		Endif
	EndIf
ElseIf cM04RVar == "M->GAJ_PROALT"
	lRet := HS_VQtdMM(oGDGaj:aCols[oGDGaj:nAt, nGajQtdSol],, M->GAJ_PROALT)
	
ElseIf cM04RVar == "M->GAI_CRMPRE"    // CONTROLE DO MEDICO DA PRESCRICAO
	DbSelectArea("SRA")
	DbSetOrder(11)
	If !DbSeek(xFilial("SRA")+ M->GAI_CRMPRE )
		HS_MsgInf(STR0065, STR0008, STR0001)//"Codigo do Medico invalido."##"Atencao"##"Solicitação de Materiais e Medicamentos"
		lRet := .F.
	Else
		M->GAI_CRMDES := SRA->RA_NOME
	EndIf
	If lRet
		If !Empty(M->GAI_FLGATE)
			If M->GAI_FLGATE != "0"
				HS_MsgInf(STR0066,  STR0008, STR0001)//"Alteracao invalida, a Requisicao pode estar ja parcialmente atendida, totalmente atendida ou encerrada."##"Atencao"##"Solicitação de Materiais e Medicamentos"
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
EndIf
If cM04RVar == "M->GAJ_PROALT" .or. cM04RVar == "M->GAJ_PROSOL"
	DbSelectArea("GBI")
	DbSetorder(1) // GBI_FILIAL + GBI_PRODUT
	DbSeek(xFilial("GBI") + SB1->B1_COD)
	If GBI->GBI_PRODES == '0'
		HS_MsgInf(STR0069, STR0008, STR0001 )
		lRet:=.F.
	Endif
Endif
If FunName() == "HSPAHM05"
	IF Type("__cCtrEst") <> "U"
		__cCtrEst := M->GAI_CODLOC
	Endif
Endif
RestArea(aArea)
Return(lRet)

                  
/******************************************************************************************************************/
Function HS_M04Kit(cProSol, nQtdSol, lVldSaldo, cLocal, cRequis)
 Local aKit    := {}, nFKit := 0, nPKit := 0, aArea := GetArea()
 Local lRetSld := .T.
 Local cProalt := ""
 Local lRastro := .F.
 Default lVldSaldo := .F.
 
 aKit := HS_RKitMMP(cProSol)[1]
 
 For nFKit := 1 To Len(aKit)
 
   nPKit := aScan(oGDGaj:aCols, {| aVet | !aVet[nUGaj + 1] .And. aVet[nGajProSol] == PadR(aKit[nFKit, 1] , Len(GAJ->GAJ_PROSOL) )  })
   nPkit := HS_VERKIT( PadR(aKit[nFKit, 3] , Len(GAJ->GAJ_CODKIT) ) , PadR(aKit[nFKit, 1] , Len(GAJ->GAJ_PROSOL) ) )
  nPKit := IIf(nPKit == 0, aScan(oGDGaj:aCols, {| aVet | !aVet[nUGaj + 1] .And. Empty(aVet[nGajProSol])}), nPKit)
  
  If lVldSaldo //Atenção ao alterar, pois quando eh posto nao valida saldo, com isso existem validacoes abaixo que so sao executadas da farmacia
   If (HS_CONEST(aKit[nFKit, 1], M->GAI_CODLOC)[1]) .Or.  cRequis == "2"
    If (lRastro := Rastro(aKit[nFKit, 1]))
     If !(lRetSld := HS_SelLote(aKit[nFKit, 1], cLocal, ((nQtdSol * aKit[nFKit, 2]) + IIF(nPKit == 0, 0, oGDGaj:aCols[nPKit, nGajQAtend])), .T.))
      HS_MsgInf(STR0033 + aKit[nFKit, 1] + STR0034, STR0008, STR0001) //"O item ["###"] do Kit não possui saldo suficiente no armazém."###"Atenção"###"Solicitação de Materiais e Medicamentos"
      Loop
     EndIf
   
    ElseIf !(lRetSld := HS_M05VSld(aKit[nFKit, 1], cLocal, ((nQtdSol * aKit[nFKit, 2]) + IIf(nPKit == 0, 0, oGDGaj:aCols[nPKit, nGajQAtend])) ))
     Loop
    EndIf
   EndIf 
  EndIf

  If nPKit == 0
   oGDGaj:AddLine(.F., .F.)
   oGDGaj:lNewLine := .F.
   nPKit := Len(oGDGaj:aCols)
  EndIf
  
  If !Empty(oGDGaj:aCols[nPKit, nGajProSol])
   oGDGaj:aCols[nPKit, nGajQtdSol] += (nQtdSol * aKit[nFKit, 2])
  Else
   oGDGaj:aCols[nPKit, nGajQtdSol] := (nQtdSol * aKit[nFKit, 2])
  EndIf           
  
  If FunName() == "HSPAHM05"
   oGDGaj:aCols[nPKit, nGajQAtend] := oGDGaj:aCols[nPKit, nGajQtdSol]
   oGDGaj:aCols[nPKit, nGajQtdAte] := oGDGaj:aCols[nPKit, nGajQtdSol]
   oGDGaj:aCols[nPKit, nGajLoteFo] := IIf(lRastro, __cLOTEFO, Space(len(GAJ->GAJ_LOTEFO)))
   oGDGaj:aCols[nPKit, nGajLoteCt] := IIf(lRastro, __cLOTECT, Space(len(GAJ->GAJ_LOTECT)))
   oGDGaj:aCols[nPKit, nGajNumLot] := IIf(lRastro, __cNUMLOT, Space(len(GAJ->GAJ_NUMLOT)))
   oGDGaj:aCols[nPKit, nGajDtVali] := IIf(lRastro, __dDTVALI, CriaVar("GAJ_DTVALI"))
  EndIf
  __cLOTEFO  := Space(Len(GAJ->GAJ_LOTEFO))
  __cLOTECT  := Space(Len(GAJ->GAJ_LOTECT))
  __cNUMLOT  := Space(Len(GAJ->GAJ_NUMLOT))
  __dDTVALI  := CriaVar("GAJ_DTVALI") 
                
  DbSelectArea("SB1")
  DbSetOrder(1) // B1_FILIAL + B1_COD
  DbSeek(xFilial("SB1") + PadR(aKit[nFKit, 1], Len(GAJ->GAJ_PROSOL)))
  oGDGaj:aCols[nPKit, nGajProSol] := PadR(aKit[nFKit, 1], Len(GAJ->GAJ_PROSOL))
  oGDGaj:aCols[nPKit, nGajDesPro] := SB1->B1_DESC
  oGDGaj:aCols[nPKit, nGajCodKit] := aKit[nFKit, 3]
  oGDGaj:aCols[nPKit, nGajDesKit] := aKit[nFKit, 4]
  oGDGaj:aCols[nPKit, nGajCBMatM] := SB1->B1_CODBAR
  
  cProalt := HS_PROALT(PadR(aKit[nFKit, 1], Len(GAJ->GAJ_PROSOL))) 
  If !Empty(cProalt)
   oGDGaj:aCols[nPKit, nGajProAlt] := cProalt
   oGDGaj:aCols[nPKit, nGajDPrAlt] := HS_INIPADR("SB1",1, cProalt, "B1_DESC",,.F.)
  Endif
 Next
 
 oGDGaj:oBrowse:Refresh()
 RestArea(aArea)
Return(Len(aKit) > 0)



/*****************************************************************************************************************/
Function HS_ValSet(oGAJ, lVldPar, nOpc)

 Local lRet      := .T.           
 Local nCont     := 0, nQtdAtend := 0
 Local nFor      := 0 
 Local dMvUltmes := GETMV("MV_ULMES")
 Local lMvProalt := GETMV("MV_PRODALT")
 Local lIntGh    := GETMV("MV_INTGH",,".F.")
 Local aArea     := GetArea()
 Local cItePri   := "", cIteAlt := "", cBlqPri := "", cBlqAlt := ""
 
 Default lVldPar := .F.
 
 If Empty(M->GAI_REGATE) .And. M->GAI_REQUIS == "1" 
  HS_MsgInf(STR0035, STR0008, STR0001)  //"Registro de Atendimento obrigatório."###"Atenção"###"Solicitação de Materiais e Medicamentos"
  lRet := .F.
 ElseIf Empty(M->GAI_CODLOC) .And. M->GAI_REQUIS $ "1/2"
  HS_MsgInf(STR0036, STR0008, STR0001)  //"Setor é obrigatório."###"Atenção"###"Solicitação de Materiais e Medicamentos"
  lRet := .F.
 ElseIf Empty(M->GAI_ALMORI) .And. M->GAI_REQUIS $ "1/2/3"
  HS_MsgInf(STR0037, STR0008, STR0001)  //"Almoxarifado de Origem obrigatório."###"Atenção"###"Solicitação de Materiais e Medicamentos"
  lRet := .F.
  ElseIf (aScan(oGAJ:aCols, {| aVet | !aVet[nUGaj + 1] .And. !Empty(aVet[nGajProSol])}) == 0)  .And. IIF(ValType( nOpc )<> "U", nOpc == 3, .T.)
   HS_MsgInf(STR0068,STR0008,STR0038) //"Solicitação não possui itens lançados. Por favor verifique."##"Atencao."##"Solicitação de Mat/Med"
   lRet := .F.
 Endif
 
 If lRet
  For nFor := 1 To Len(oGAJ:aCols) 
   If lVldPar
    nQtdAtend += oGAJ:aCols[nFor, nGajQAtend]
   Endif
   If !Empty(oGAJ:aCols[nFor, nGAJProSol]) .And. !oGAJ:aCols[nFor, nUGAJ+1]
    cBlqPri := HS_INIPADR("SB1", 1, oGAJ:aCols[nFor, nGAJProSol], "B1_MSBLQL",,.F.) 
    If !Empty(oGAJ:aCols[nFor, nGAJProAlt])
     cBlqAlt :=HS_INIPADR("SB1", 1, oGAJ:aCols[nFor, nGAJProAlt], "B1_MSBLQL",,.F.) 
    Endif
    If lMvProalt
     If cBlqAlt == "1"
      cIteAlt += IIF(Empty(cIteAlt), ALLTRIM(oGAJ:aCols[nFor, nGAJProAlt]), "/" + ALLTRIM(oGAJ:aCols[nFor, nGAJProAlt])) 
      nCont++
     Else 
      If cBlqPri == "1"
       cItePri += IIF(Empty(cItePri), ALLTRIM(oGAJ:aCols[nFor, nGAJProSol]), "/" + ALLTRIM(oGAJ:aCols[nFor, nGAJProSol])) 
       nCont++
      Endif 
     Endif
    Else
     If cBlqPri == "1"
      cItePri += IIF(Empty(cItePri), ALLTRIM(oGAJ:aCols[nFor, nGAJProSol]), "/" + ALLTRIM(oGAJ:aCols[nFor, nGAJProSol])) 
      nCont++
     Endif 
    EndIf
    cBlqPri := ""
    cBlqAlt := ""
   Endif
  Next 
  
  If !(lRet := !(nCont > 0))
   If !Empty(cItePri) .And. !Empty(cIteAlt)
    HS_MsgInf(STR0049 + cItePri + STR0050 + cIteAlt + STR0051, STR0008, STR0001) //"Produto(s) principal(s) ["###"] e produto(s) alternativo(s) ["###"] bloqueado(s) no estoque."###"Atenção"###"Solicitação de Materiais e Medicamentos"   
   ElseIf !Empty(cItePri) .And. Empty(cIteAlt)
    HS_MsgInf(STR0049 + cItePri + STR0051, STR0008, STR0001) //"Produto(s) principal(s) ["###"] bloqueado(s) no estoque."###"Atenção"###"Solicitação de Materiais e Medicamentos"   
   ElseIf Empty(cItePri) .And. !Empty(cIteAlt)
     HS_MsgInf( STR0052 + cIteAlt + STR0051, STR0008, STR0001) //"Produto(s) alternativo(s) ["###"] bloqueado(s) no estoque."###"Atenção"###"Solicitação de Materiais e Medicamentos"   
   Endif
  ElseIf !(lRet:= !Empty(dMvUltmes) .And. (M->GAI_DATSOL > dMvUltmes)) 
   HS_MsgInf(STR0047, STR0008, STR0001) //"A Data do lançamento da despesa é menor ou igual ao último fechamento de estoque, não será possível efetuar o lançamento."###"Atenção"###"Solicitação de Materiais e Medicamentos"  
	If FunName() == "HSPAHM05"
		lRet := .T.
	EndIf
  ElseIf lVldPar .And. nQtdAtend > 0
   If !lIntGh .And. M->GAI_REQUIS $ "1/2" 
    HS_MsgInf(STR0057, STR0008, STR0001)  //"Movimentação não pode ser atendida pois parâmetro 'MV_INTGH' está com conteúdo vazio ou igual a 'F=não' para não integrar com estoque."
    lRet := .F.
   Endif
  EndIf  
 Endif
 
RestArea(aArea)
 
Return(lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      FILTRO DA TECLA F12                                                ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_FilM04(lSetFilter)
 Local oObjMBrw     := ""
 Local lRet         := .T.
 
 Default lSetFilter := .T.
 
 oObjMBrw           := IIf(lSetFilter, GetObjBrow(), Nil) 

 If (lRet := Pergunte(cPerg,.T.))
  cSetPerg := MV_PAR01
  cGcsCodLoc := MV_PAR01
 
  cFilM04 := "GAI_FILIAL = '" + xFilial("GAI") + "' "
  cFilM04 += "AND GAI_CODLOC = '" + cSetPerg + "' "
 Endif

 If lSetFilter .And. lRet
  SetMBTopFilter("GAI", cFilM04)
  oObjMBrw:GoTop()
  oObjMBrw:Refresh()
 EndIf
Return(lRet)                           

Function HS_ArmFarS(lRetVal)
 Local lRet := .T.
           
 If !(lRet := Empty(GCS->GCS_ARMFA2))
  lRet := (Empty(GCS->GCS_HORINI) .Or. SubStr(Time(), 1, 5) >= GCS->GCS_HORINI) .And. ;
          (Empty(GCS->GCS_HORFIN) .Or. SubStr(Time(), 1, 5) <= GCS->GCS_HORFIN)
 EndIf 

Return(IIf(lRet, IIf(lRetVal, GCS->GCS_ARMFAR, "GCS_ARMFAR"), IIf(lRetVal, GCS->GCS_ARMFA2, "GCS_ARMFA2")))



Function HS_VldPar(cRotina)
Local lRet  := .T.
Local aArea := GetArea()
Local aMV   := {"MV_TPMADM", "MV_TPMVSA", "MV_TPMVEN", "MV_TMESSAI", "MV_TMESENT", "MV_TMEESAI", "MV_TMEEENT"}
Local nMV   := 0
Local cCont := ""  //Conteudo do parametro
Local lContInvE := .F., lContInvS := .F.
Local aGetMV := {AllTrim(GetMv("MV_TPMADM")),AllTrim(GetMv("MV_TPMVSA")),AllTrim(GetMv("MV_TPMVEN")),AllTrim(GetMv("MV_TMESSAI")),AllTrim(GetMv("MV_TMESENT")),AllTrim(GetMv("MV_TMEESAI")),AllTrim(GetMv("MV_TMEEENT"))}
Default cRotina := STR0038 //"Solicitações de Mat/Med"

DbSelectArea("SF5")
DbSetOrder(1) // F5_FILIAL + F5_CODIGO
SF5->(DbClearFilter())
For nMV := 1 to Len(aGetMV)
	If (Empty(cCont := aGetMV[nMV])) .Or. !DbSeek(xFilial("SF5") + cCont)
		lRet := .F.
		Exit
	ElseIf StrZero(nMV, 2) $ "01/02/04/06" .And. ( VAL(cCont) <= 500 .Or. VAL(cCont) >= 999 ) //Saida
		lRet      := .F.
		lContInvS := .T.
		Exit
	ElseIf StrZero(nMV, 2) $ "03/05/07" .And. VAL(cCont) >= 499 //Entrada
		lRet      := .F.
		lContInvE := .T.
		Exit
	EndIf
Next nMV

If !lRet
	HS_MsgInf(STR0039 + IIf(Empty(cCont), STR0040, STR0041	)	+ aMV[nMV] + ; //"Tipo de movimentação"###" não cadastrado no parâmetro "###" inválido no parâmetro "
	CHR(10) + IIF(lContInvE, STR0053, IIF(lContInvS, STR0054, "")), ;  //"Conteúdo do parâmetro deve ser menor que 499 "###"Conteúdo do parâmetro deve ser maior que 500 e menor que 999"
	STR0042, cRotina) //"Verifique!"
Endif

RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0003), "HS_MntM04", 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), "HS_MntM04", 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), "HS_MntM04", 0, 4, 0, nil},; //"Alterar"
                     {OemToAnsi(STR0006), "HS_MntM04", 0, 5, 0, nil},; //"Excluir"
                     {OemtoAnsi(STR0007), "HS_LegM04", 0, 1, 0, nil}}   //"Legenda"
Return(aRotina)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_INIM04 ³ Autor ³ MARCELO JOSE          ³ Data ³ 06/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ SOLICITACAO DE MAT/MED                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION HS_INIM04(cCampIni)
 Local cRet := ""                  
 
 If cCampIni == "GAI_CRMPRE"
                                          
  If FUNNAME() == "HSPAHM30"
   cRet := POSICIONE("GCY",1,XFILIAL("GCY")+GAV->GAV_REGATE,"GCY_CODCRM")
  ElseIf FUNNAME() == "HSPAHM04"
   // If Altera
    If !Empty(M->GAI_REGATE)
     cRet := POSICIONE('GCY',1,XFILIAL('GCY')+M->GAI_REGATE,'GCY_CODCRM')
    EndIf 
   // EndIf 
  EndIf 
  
 ElseIf cCampIni == "GAI_CRMDES"  
 
  If !EMPTY(M->GAI_CRMPRE)
   cRet := POSICIONE('SRA',11,XFILIAL('SRA')+M->GAI_CRMPRE,'RA_NOME')
  EndIf 
  
 EndIf
 
RETURN(cRet)
Function HS_VldCBMM()       
                       
Local cProVld := ''
Local nPosGD  := 0
Local cCodBar := M->GAI_CBMATM
Local lSoma   := .F.

 //Validação do codigo barras digitado
 If !HS_SeekRet("SB1", "'" + cCodBar + "'", 5, .F.)
		If HS_SeekRet("GAP", "'" + cCodBar + "'", 1, .F.)
			If !HS_SeekRet("SB1", "GAP->GAP_CODIGO", 1, .F.)
				HS_MsgInf(STR0062, STR0008, STR0063) //"Produto cadastrado no código de barras secundario não existe no cadastro"###"Atenção"###"Validação do código de barras dos materiais e medicamentos"
				Return(.F.)
			EndIf
		Else
			HS_MsgInf(STR0064, STR0063) //"Produto não encontrado com este código de barras"###"Validação do código de barras dos materiais e medicamentos"
			Return(.F.)
		Endif
	Endif

	cProVld := SB1->B1_COD
 
 DbSelectArea("SB1")
 DbSetOrder(1) // B1_FILIAL + B1_COD 
 DbSeek(xFilial("SB1") + cProVld)
 
 If (nPosGD := aScan(oGDGaj:aCols, {| aVet | aVet[nGajProSol] == cProVld})) == 0
  nPosGD := IIf(nPosGD == 0, aScan(oGDGaj:aCols, {| aVet | Empty(aVet[nGajProSol])}), nPosGD)
 Else
  oGDGaj:aCols[nPosGD, nGajQtdSol] := oGDGaj:aCols[nPosGD, nGajQtdSol] + M->GAI_QATEND 
  lSoma := .T.
 Endif               	

 If nPosGD == 0
  oGDGaj:AddLine(.T.,.F.)
  oGDGaj:lNewLine := .F.
  lSoma := .F.
  nPosGD := Len(oGDGaj:aCols)             
 EndIf

 M->GAJ_QTDSOL := oGDGaj:aCols[nPosGD, nGajQtdSol] + M->GAI_QATEND
 M->GAJ_PROSOL := cProVld                         

 If HS_VldM04("M->GAJ_PROSOL", nPosGD) .AND. HS_VldM04("M->GAJ_QTDSOL", nPosGD)

   If !lSoma                                                                           
    oGDGaj:aCols[nPosGD, nGajQtdSol] := M->GAI_QATEND 
    oGDGaj:aCols[nPosGD, nGajProSol] := cProVld
   EndIf
  
   lSoma := .F.
   oGDGaj:Refresh()

   M->GAI_CBMATM := Space(len(M->GAI_CBMATM))

 EndIf
                              
 oEnGAI:aEntryCtrls[aScan(oEnGAI:aGets, {|X| "GAI_CBMATM" $ X})]:SetFocus()
       
Return(Nil)
                                                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VERKIT  ºAutor  ³Microsiga         º Data ³  08/24/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função para Verificar os Kits Lançados na  Grid           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function HS_VERKIT(cKit,cprodut) 

Local  nCont:=0
Local  nKitG:=0 

For nCont := 1 To Len(oGDGaj:aCols) 
  nKitG := aScan(oGDGaj:aCols, {| aVet |   aVet[nGajCodKit] == cKit .and. aVet[nGajProSol] == cprodut })
Next

Return(nKitG)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  Validacao do campo GAI_CBMATM                                          ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HS_VLGAICB

Local lRet 		:= .T.
Local dUlMes 	:= GETMV("MV_ULMES")

If	!Empty(dUlMes) 

	If Type("M->GAI_DATSOL") <> "U"
	
		If M->GAI_DATSOL <= dUlMes
		
			HS_MsgInf(STR0047, STR0008, STR0001) //"A Data do lançamento da despesa é menor ou igual ao último fechamento de estoque, não será possível efetuar o lançamento."###"Atenção"###"Solicitação de Materiais e Medicamentos"  
			
			lRet := .F.
		
		EndIf
		
	EndIf

EndIf

If lRet

	If Type('cCodLoc_Far')<>'U' 

		If ! HS_VCODBAR(M->GAI_CBMATM, 'GAJ_PROSOL',,.F., CCODLOC_FAR, .F.)
			lRet := .F.
		EndIf

	Else
	
		If ! HS_VLDCBMM()
			lRet := .F.
		EndIf

	EndIf

EndIf

Return lRet