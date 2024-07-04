#Include "Protheus.ch"
#Include "VEIVM080.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM080 ³ Autor ³  Manoel               ³ Data ³ 16/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula Comissoes de Veiculos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM080

If MsgYesNo(STR0001)//Tem certeza que deseja iniciar o Processo de Recalculo de Comissoes de Veiculos
   Processa( {|| FS_RecCom() })
Endif 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_RECCOM³ Autor ³  Manoel               ³ Data ³ 16/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula Comissoes de Veiculos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RECCOM()

Private cTipAva  := "1"   //Veiculos
Private cCpoDiv  := "    1"

cPerg := "RECCOM"
ValidPerg(cPerg)

If !pergunte(cPerg,.t.)
	Return
Endif

If Empty(Mv_Par01) .and. !empty(Mv_Par02)
/*
	dbSelectArea("VV0")
	dbSetOrder(2)
	DbSeek(xFilial("VV0")+"0"+Dtos(Mv_Par02),.t.)
//	cWhen := 'Dtos(VV0->VV0_DATMOV) <= Dtos(Mv_Par03)'
	cWhen := '.t.'
	nTot := RecCount()
*/
	dbSelectArea("VV0")
	cWhen := 'Dtos(VV0->VV0_DATMOV) <= Dtos(Mv_Par03)'
	nTot := RecCount()
	cIndex := CriaTrab(nil,.f.)
	cKey   := "VV0_FILIAL+DtoS(VV0_DATMOV)"
	dbSelectArea("VV0")
	IndRegua("VV0",cIndex,cKey,,"",OemToAnsi(STR0002))  //Selecionando Registros...
	nIndexVV0 := RetIndex("VV0")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndexVV0+1)
	DbSeek(xFilial("VV0")+Dtos(Mv_Par02),.t.)
Else
	dbSelectArea("VVA")
	dbSetOrder(2)
	DbSeek(xFilial("VVA")+Mv_Par01)
	cChassi := Mv_Par01
	dbSelectArea("VV0")
	dbSetOrder(1)
	DbSeek(xFilial("VV0")+VVA->VVA_NUMTRA)
	cWhen := 'VV0->VV0_NUMTRA == VVA->VVA_NUMTRA .and. VV0->VV0_OPEMOV $ "0.7.3" .and. VVA->VVA_CHASSI == cChassi'
	nTot := 1
	cNumTra := VVA->VVA_NUMTRA
Endif

ProcRegua(nTot)

While !eof() .and. VV0->VV0_FILIAL == xFilial("VV0") .and. &cWhen

 	IncProc()

   If VV0->VV0_OPEMOV == "3"
		If !Empty(Mv_Par01)
			DbSelectArea("VVA")
			dbSkip()
			If Alltrim(VVA->VVA_CHASSI) == Alltrim(MV_Par01)
				dbSelectArea("VV0")
				dbSetOrder(1)
				DbSeek(xFilial("VV0")+VVA->VVA_NUMTRA)
			Else
				dbSelectArea("VV0")
		      DbSkip()
			Endif
	      Loop
		Else
			dbSelectArea("VV0")
	      DbSkip()
	      Loop
		Endif
   Endif
   
   If VV0->VV0_SITNFI != "1"
		dbSelectArea("VV0")
		dbSetOrder(1)
      DbSkip()
		dbSelectArea("VVA")
		dbSetOrder(2)
      DbSkip()
      Loop
   Endif
  	
	If Empty(Mv_Par01) .and. !empty(Mv_Par02)
		dbSelectArea("VV0")
		dbSetOrder(nIndexVV0+1)
//		dbSetOrder(2)
	Else
		dbSelectArea("VVA")
		dbSetOrder(2)
		dbSelectArea("VV0")
		dbSetOrder(1)
	Endif

	If Empty(Mv_Par01) .and. !empty(Mv_Par02)
	   If VV0->VV0_DATMOV > Mv_Par03 .or. VV0->VV0_DATMOV < Mv_Par02
			DbSkip()
			Loop
	   Endif
//		if !(VV0->VV0_OPEMOV == "0" .and. VV0->VV0_SITNFI == "1")
		if !((VV0->VV0_OPEMOV == "0" .and. VV0->VV0_SITNFI == "1").or.VV0->VV0_OPEMOV == "7")
			DbSkip()
			Loop
		Endif
		dbSelectArea("VVA")
		dbSetOrder(1)
		If !DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
			dbSelectArea("VV0")
			DbSkip()
			Loop
		Endif
	Endif

	dbSelectArea("VV1")
	dbSetOrder(1)
	DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
	
   M->VVA_COMVDE := VVA->VVA_COMVDE
   M->VVA_COMGER := VVA->VVA_COMGER   
   // Estes dois campos serao usados temporariamente para gravacao da comissao do encarregado e comissao de quem indicou   
   M->VVA_COMPAT := VVA->VVA_COMPAT // Comissao Encarregado
   M->VVA_VALIRF := VVA->VVA_VALIRF // Comissao de Quem Indicou
   //
   
   If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
      ExecBlock("FS_COMVEI",.f.,.f.)
      RecLock("VVA",.f.)
		VVA->VVA_COMVDE := M->VVA_COMVDE
		VVA->VVA_COMGER := M->VVA_COMGER
		VVA->VVA_VALIRF := M->VVA_VALIRF
		VVA->VVA_CMFVDE := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMVDE}} )
		VVA->VVA_CMFGER := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMGER}} )
	   VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_VALIRF-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT
		VVA->VVA_LMFLQ2 := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_LUCLQ2}} )
   	MsUnlock()
	Endif
   If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
      ExecBlock("FS_COMVEI",.f.,.f.)
      RecLock("VVA",.f.)
		VVA->VVA_COMGER := M->VVA_COMGER
		VVA->VVA_COMPAT := M->VVA_COMPAT
	   VVA->VVA_VALIRF := M->VVA_VALIRF // Comissao de Quem Indicou
   	MsUnlock()
	Endif

		
	DbSelectArea("VV0")
	If Empty(Mv_Par01) .and. !empty(Mv_Par02)
		dbSetOrder(nIndexVV0+1)
//		dbSetOrder(2)
   Else
		DbSelectArea("VVA")
		dbSkip()
		If Alltrim(VVA->VVA_CHASSI) != Alltrim(MV_Par01)
			dbSkip(-1)
		Else
			dbSelectArea("VV0")
			dbSetOrder(1)
			DbSeek(xFilial("VV0")+VVA->VVA_NUMTRA)
			Loop
		Endif
	Endif
	DbSelectArea("VV0")
	
	dbSkip()
	
Enddo

MsgInfo("Recalculo Finalizado com sucesso")

If Empty(Mv_Par01) .and. !empty(Mv_Par02)
	dbSelectArea("VV0")
	#IFNDEF TOP
		RetIndex()
		dbSetOrder(1)
		If File(cIndex+OrdBagExt())
			fErase(cIndex+OrdBagExt())
		Endif
	#Else
		Set Filter to	
	#ENDIF
Endif

Return


// aHelpPor := {}
// aHelpSpa := {}
// aHelpEng := {}
// AADD(aHelpPor,"Informe o Chassi do Veiculo.		 ")
// AADD(aHelpSpa,"Informe o Chassi do Veiculo.		 ")
// AADD(aHelpEng,"Informe o Chassi do Veiculo.		 ")
// AADD(aPergs,{"Chassi do Veiculo   ","Chassi do Veiculo   ","Chassi do Veiculo   ","mv_ch1","C",25,0,0,"G","FG_SEEK('VV1','MV_PAR01',2,.F.) .or. Empty(Mv_Par01)","Mv_Par01","",;
// "","","","","","","","","","","","","","","","","","","","","","","","VV1","","S","","",aHelpPor,aHelpEng,aHelpSpa})
// 
// aHelpPor := {}
// aHelpSpa := {}
// aHelpEng := {}
// AADD(aHelpPor,"Informe a data inicial ao recalc. ")
// AADD(aHelpSpa,"Informe a data inicial ao recalc. ")
// AADD(aHelpEng,"Informe a data inicial ao recalc. ")
// AADD(aPergs,{"Data Inicial        ","Data Inicial        ","Data Inicial        ","mv_ch2","D",8,0,0,"G","","Mv_Par02","",;
// "","","","","","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})
// 
// aHelpPor := {}
// aHelpSpa := {}
// aHelpEng := {}
// AADD(aHelpPor,"Informe a data final ao recalculo.")
// AADD(aHelpSpa,"Informe a data final ao recalculo.")
// AADD(aHelpEng,"Informe a data final ao recalculo.")
// AADD(aPergs,{"Data Final          ","Data Final          ","Data Final          ","mv_ch3","D",8,0,0,"G","","Mv_Par03","",;
// "","","","","","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})

