#Include "Protheus.ch"
#Include "OFIOA400.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA400 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza OS (KM/Dt.Hr.Abertura/Motorista/Nr.Orcamto/Obs.OS)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA400   

Private nNumOS     := Space(8)
Private nKmAtual   := 0
Private nKmCorreta := 0
Private cChassi    := Space(25)  
Private dDtAtual   := ctod("  /  /  ")
Private nHrAtual   := 0
Private dDtCorreta := ctod("  /  /  ")
Private nHrCorreta := 0  
Private dDtAnterior:= ctod("  /  /  ")
Private nHrAnterior:= 0
Private dDtPosterior:= date()+1
Private nHrPosterior:= 9999
Private cMtAtual   := space(6)
Private cMtCorreto := space(6)
Private cOrcAtual  := space(8)
Private cOrcCorreto:= space(8)
Private nKmAnt     := 1
Private nKmPos     := 9999999999
Private cOSAnt     := "00000000"
Private cOSPos     := "ZZZZZZZZ"
Private cObserv    := ""
Private aMemos		 := {}
Private nOpca      := 0         
Private cNome      := space(50)

DEFINE MSDIALOG oDlgOS TITLE STR0001 From 7,25 to 31,90 of oMainWnd

@ 016,012 SAY STR0002 OF oDlgOS SIZE 45,10 PIXEL COLOR CLR_BLACK
@ 015,045 MSGET oNumOS VAR nNumOS PICTURE "@!" VALID FS_VAL_NUMOS() F3 "VO1" SIZE 25,4 OF oDlgOS PIXEL COLOR CLR_BLACK
@ 034,012 SAY STR0003 OF oDlgOS SIZE 36,20 PIXEL COLOR CLR_BLACK
@ 033,045 MSGET oChassi VAR cChassi PICTURE "@!" VALID FS_VAL_CHASS() F3 "VV1" SIZE 100,4 OF oDlgOS PIXEL COLOR CLR_BLACK
@ 005,005 TO 053,253 LABEL "" OF oDlgOS PIXEL  //caixa 1
@ 016,085 SAY cNome OF oDlgOS SIZE 120,15 PIXEL COLOR CLR_BLACK
@ 015,200 BUTTON oObsOS PROMPT OemToAnsi(STR0004) OF oDlgOS SIZE 45,10 PIXEL ACTION FS_ATU_MEMO()

@ 062,012 SAY STR0006 OF oDlgOS SIZE 40,20 PIXEL COLOR CLR_BLACK
@ 069,012 SAY STR0005 OF oDlgOS SIZE 40,20 PIXEL COLOR CLR_BLACK
@ 076,012 SAY STR0007 OF oDlgOS SIZE 40,20 PIXEL COLOR CLR_BLACK
@ 062,045 SAY If(nKmAnt>1,Transform(nKmAnt,"@E 9999,999,999"),space(15)) OF oDlgOS SIZE 110,20 PIXEL COLOR CLR_BLACK
@ 069,045 SAY If(nKmAtual>1,Transform(nKmAtual,"@E 9999,999,999"),space(15)) OF oDlgOS SIZE 110,20 PIXEL COLOR CLR_BLACK
@ 076,045 SAY If(nKmPos<9999999999,Transform(nKmPos,"@E 9999,999,999"),space(15)) OF oDlgOS SIZE 110,20 PIXEL COLOR CLR_BLACK
@ 069,105 SAY STR0008 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 068,150 MSGET oKmCorreta VAR nKmCorreta PICTURE "@E 9999999999" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK
DEFINE SBUTTON FROM 066,215 TYPE 1 ACTION ( FS_ATUAL_KM() , nKmAnt:=1 , nKmPos:=9999999999 , nKmAtual:=nKmCorreta , nKmCorreta:=0 , oNumOS:SetFocus()) ENABLE OF oDlgOS PIXEL
@ 058,005 TO 084,253 LABEL STR0011 OF oDlgOS PIXEL  //caixa 1

@ 100,012 SAY STR0005 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 094,045 MSGET oDtAtual VAR dDtAtual PICTURE "@D" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK when .f.
@ 104,045 MSGET oHrAtual VAR nHrAtual PICTURE "@R 99:99" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK when .f.
@ 100,105 SAY STR0009 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 094,150 MSGET oDtCorreta VAR dDtCorreta PICTURE "@D" VALID FS_VAL_DTC()  SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK
@ 104,150 MSGET oHrCorreta VAR nHrCorreta PICTURE "@R 99:99" VALID FS_VAL_HRC()  SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK
DEFINE SBUTTON FROM 097,215 TYPE 1 ACTION ( FS_ATUAL_DTHR() , dDtAtual:=dDtCorreta , nHrAtual:=nHrCorreta , dDtCorreta:=ctod("  /  /  ") , nHrCorreta:=0 , oNumOS:SetFocus()) ENABLE OF oDlgOS PIXEL
@ 089,005 TO 115,253 LABEL STR0010 OF oDlgOS PIXEL  //caixa 1

@ 131,012 SAY STR0005 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 130,043 MSGET oMtAtual VAR cMtAtual PICTURE "@!!!!!!" F3 "VOG" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK when .f.
@ 131,105 SAY STR0009 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 130,150 MSGET oMtCorreto VAR cMtCorreto PICTURE "@!!!!!!" VALID FS_VAL_MT() F3 "VOG" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK
DEFINE SBUTTON FROM 128,215 TYPE 1 ACTION ( FS_ATUAL_MT() , cMtAtual:=cMtCorreto , cMtCorreto:=space(6) , oNumOS:SetFocus()) ENABLE OF oDlgOS PIXEL
@ 120,005 TO 146,253 LABEL STR0013 OF oDlgOS PIXEL  //caixa 1

@ 162,012 SAY STR0005 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 161,043 MSGET oOrcAtual VAR cOrcAtual PICTURE "99999999" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK when .f.
@ 162,105 SAY STR0009 OF oDlgOS SIZE 100,20 PIXEL COLOR CLR_BLACK
@ 161,150 MSGET oOrcCorreto VAR cOrcCorreto PICTURE "99999999" SIZE 50,4 OF oDlgOS PIXEL COLOR CLR_BLACK
DEFINE SBUTTON FROM 159,215 TYPE 1 ACTION ( FS_ATUAL_ORC() , cOrcAtual:=cOrcCorreto , cOrcCorreto:=space(8) , oNumOS:SetFocus()) ENABLE OF oDlgOS PIXEL
@ 151,005 TO 177,253 LABEL STR0012 OF oDlgOS PIXEL  //caixa 1

@ 031,200 BUTTON oSair PROMPT OemToAnsi(STR0019) OF oDlgOS SIZE 45,10 PIXEL ACTION (oDlgOS:End())

DEFINE SBUTTON FROM 031,145 TYPE 14 ACTION Processa({ || FS_OSVEI() }) ENABLE OF oDlgOS PIXEL

ACTIVATE MSDIALOG oDlgOS CENTER 

Return                       


/////////////////////
Static Function FS_VAL_NUMOS()
	nNumOS := strzero(val(nNumOS),8)
	dDtAnterior:= ctod("  /  /  ")
	nHrAnterior:= 0
	dDtAtual   := ctod("  /  /  ")
	nHrAtual   := 0
	dDtPosterior:= date()+1
	nHrPosterior:= 9999 
	nKmAtual   := 0
	cMtAtual   := space(6)
	nKmAnt     := 1
	nKmPos     := 9999999999
	cOSAnt     := "00000000"
	cOSPos     := "ZZZZZZZZ"
	DbSelectArea("VO1")
	DbSetOrder(1)
	If	!DbSeek(xFilial("VO1")+nNumOS)
//	   aviso("OS. nao Existe...","Atencao!")                  
//   	Aviso("Atencao!","OS. nao Existe. Impossivel continuar.",{"Continuar"},2)	

//		Return(.f.)
	Else  
  		DbSelectArea("SA1")
	   DbSetOrder(1)
   	DbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
   	cNome := SA1->A1_NOME
	  	nKmAtual := VO1->VO1_KILOME
		cMtAtual := VO1->VO1_CODMOT  
		dDtAtual := VO1->VO1_DATABE
		nHrAtual := VO1->VO1_HORABE
	   cOrcAtual := VO1->VO1_NUMORC
		Inclui := .f.
		aMemos := {{"VO1_OBSMEM","VO1_OBSERV"}}
		cObserv := E_MSMM(VO1->VO1_OBSMEM,77)
		M->VO1_OBSERV := cObserv 
	EndIf
Return(.t.)
  

////////////////////// 
Static Function FS_VAL_CHASS()
	Local nReg  := 0
	DbSelectArea("VO1")
	DbSetOrder(1)
	If DbSeek(xFilial("VO1")+nNumOS)
		If cChassi # VO1->VO1_CHASSI  
//	   	MsgInfo(STR0021,STR0018)   
//			Return(.f.)
		Else
			If FS_OS_TPKM(nNumOS)
				//Valida se pode alterar
				DbSelectArea("VO1")
				DbSetOrder(8)
				If DbSeek(xFilial("VO1")+cChassi)
		  			While !Eof() .and. xFilial("VO1") == VO1->VO1_FILIAL .and. VO1->VO1_CHASSI == cChassi
					   If VO1->VO1_NUMOSV == nNumOS
						   nReg := VO1->(Recno())  
					   Else
							If VO1->VO1_STATUS # "C"
								If FS_OS_TPKM(VO1->VO1_NUMOSV)
									If VO1->VO1_NUMOSV < nNumOS .and. VO1->VO1_NUMOSV > cOSAnt
										nKmAnt := VO1->VO1_KILOME
										cOSAnt := VO1->VO1_NUMOSV
									ElseIf VO1->VO1_NUMOSV > nNumOS .and. VO1->VO1_NUMOSV < cOSPos
										nKmPos := VO1->VO1_KILOME
										cOSPos := VO1->VO1_NUMOSV
									EndIf
								EndIf
							EndIf 
						EndIf 
						DbSelectArea("VO1")
						DbSkip()
					EndDo	
					DbSelectArea("VO1")
		   		DbGoto(nReg)
				EndIf
			EndIf
		EndIf
	EndIf
Return(.t.)
	

////////////////////
Static Function FS_ATUAL_KM()
	DbSelectArea("VO1")
	DbSetOrder(1)
	If	!DbSeek(xFilial("VO1")+nNumOS)
	   	Aviso(STR0034,STR0035,{STR0036},2) //Atencao!","OS. nao Existe. Impossivel continuar. # 	Continuar
		Return(.f.)
	Else
		If cChassi # VO1->VO1_CHASSI  
    	  	Aviso(STR0034,STR0037,{STR0036},2)//Atencao!","Chassi nao pertence a OS. Impossivel continuar. # Continuar	
//		   	Aviso(STR0034,"Chassi nao pertence a OS. informada...","Impossivel continuar.",{STR0036},2)	
	//	   	MsgInfo("Chasis no pertenece a OS. informada...",STR0018)   
			Return(.f.)
		Else

			If FS_OS_TPKM(nNumOS)
		  		If nKmCorreta < nKmAnt
		  	  		MsgInfo(STR0022+"("+cOSAnt+")"+STR0024+STR(nKmAnt,8),STR0018)
		  		   Return(.f.)
			   EndIf
		  		If nKmCorreta > nKmPos
		  			MsgInfo(STR0023+"("+cOSPos+")"+STR0024+STR(nKmPos,8),STR0018)
		  	   	Return(.f.)
		  	  	EndIf
		   	//Altera a KM atual
		  		DbSelectArea("VFB")
		  		DbSetOrder(9)
		  		If dbSeek(xFilial("VFB")+VO1->VO1_CHAINT)
			      While !Eof() .and. xFilial("VFB") == VFB->VFB_FILIAL .and. VFB->VFB_CHAINT == VO1->VO1_CHAINT
				      If VO1->VO1_NUMOSV == VFB->VFB_NUMOSV
		  			      RecLock("VFB", .f.)
		  	  			   	VFB->VFB_KILOME := nKmCorreta
		     		   	MsUnlock()
		     		   EndIf
						DbSelectArea("VFB")
		  	      	DbSkip()
		  	   	EndDo
		   	EndIf
				DbSelectArea("VO1")
		  		RecLock("VO1", .f.)
				   VO1->VO1_KILOME := nKmCorreta
		  		MsUnlock()
				nOpca:=1
			Else
				MsgInfo(STR0025,STR0018)
				Return(.f.)
			EndIf
         Endif
   Endif
Return(.t.)


////////////////////
Static Function FS_OS_TPKM(cOS) 
Local lRet := .t.
	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek( xFilial("VO2") + cOS )
	While !Eof() .and. xFilial("VO2") == VO2->VO2_FILIAL .and. VO2->VO2_NUMOSV == cOS .and. lRet
		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
		While !Eof() .and. xFilial("VO4") == VO4->VO4_FILIAL .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM .and. lRet
			DbSelectArea("VOI")
			DbSetOrder(1)
			DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
			If VOI->VOI_TPOKLM == "1"
				lRet := .f.
			EndIf
			DbSelectArea("VO4")
			DbSkip()
		EndDo	
		DbSelectArea("VO2")
		DbSkip()
	EndDo	
Return(lRet)


////////////////////
Static Function FS_VAL_DTC()
	If !Empty(dDtCorreta)
		dbSelectArea("VO1")
		dbSetOrder(1)
		DbSeek( xFilial("VO1") + nNumOS )
		If !(Bof())
			DbSkip(-1)
			If !(Bof())
				dDtAnterior:= VO1->VO1_DATABE
				nHrAnterior:= VO1->VO1_HORABE
				If VO1->VO1_DATABE > dDtCorreta
	   		   MsgInfo(STR0026,STR0018)
	      		oDtCorreta:SetFocus()
					Return(.f.)
				EndIf
			EndIf
			Dbskip()
			If !(Eof())
				Dbskip()
				If !(Eof())
					dDtPosterior:= VO1->VO1_DATABE
					nHrPosterior:= VO1->VO1_HORABE
					If VO1->VO1_DATABE < dDtCorreta
						MsgInfo(STR0027,STR0018)
			   	   oDtCorreta:SetFocus()
						Return(.f.)
					EndIf	
				EndIf
				Dbskip(-1)
			EndIf
		EndIf
	Else
		oChassi:SetFocus()
	EndIf	           
Return(.t.)


////////////////////
Static Function FS_VAL_HRC()
	DbSelectArea("VO1")
	DbSetOrder(1)
	If	!DbSeek(xFilial("VO1")+nNumOS)
	   	Aviso(STR0034,STR0035,{STR0036},2)//Atencao!","OS. nao Existe. Impossivel continuar. # Continuar	
		Return(.f.)
   Else
		If cChassi # VO1->VO1_CHASSI  
		  	Aviso(STR0034,STR0037,{STR0036},2)//Atencao!","Chassi nao pertence a OS. Impossivel continuar.  # Continuar	
	//	   	MsgInfo("Chasis no pertenece a OS. informada...",STR0018)   
			Return(.f.)
		Else
			FS_VAL_DTC()
			If !( ( substr(strzero(nHrCorreta,4),1,2) <= "23" ) .and. ( substr(strzero(nHrCorreta,4),3,2) <= "59" ) )
			   nHrCorreta:=0
			   MsgInfo(STR0028,STR0018)
				Return(.f.)
			EndIf
			If dDtAnterior == dDtCorreta
				If nHrAnterior > nHrCorreta
		  			MsgInfo(STR0028,STR0018)   
					Return(.f.)
				EndIf
			EndIf
			If dDtPosterior == dDtCorreta
				If nHrPosterior < nHrCorreta
		  			MsgInfo(STR0028,STR0018)   
					Return(.f.)
				EndIf
			EndIf
		Endif	
    Endif
Return(.t.) 


////////////////////
Static Function FS_VAL_MT()
	If !Empty(cMtCorreto)
		DbSelectArea("VOG")
		DbSetOrder(1)
		If !DbSeek(xFilial("VOG")+cMtCorreto)
  			MsgInfo(STR0030,STR0018)   
			Return(.f.)
		EndIf
   EndIf
Return(.t.)


////////////////////
Static Function FS_ATUAL_MT()
DbSelectArea("VO1")
DbSetOrder(1)
If	!DbSeek(xFilial("VO1")+nNumOS)
  	Aviso(STR0034,STR0035,{STR0036},2)//Atencao!","OS. nao Existe. Impossivel continuar. # Continuar
	Return(.f.)
Else      
	If cChassi # VO1->VO1_CHASSI  
	  	Aviso(STR0034,STR0037,{STR0036},2)//Atencao!","Chassi nao pertence a OS. Impossivel continuar. # Continuar	
//	   	Aviso("Atencao!","Chassi nao pertence a OS. informada...","Impossivel continuar.",{"Continuar"},2)	
		Return(.f.)
	Else
                           

		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek(xFilial("VO1")+nNumOS)
			DbSelectArea("VOG")
			DbSetOrder(1)
			If !DbSeek(xFilial("VOG")+cMtCorreto)
	  			MsgInfo(STR0030,STR0018)
				Return(.f.)
			Else
		   	//Altera Motorista
		   	RecLock("VO1", .f.)
				   VO1->VO1_CODMOT := cMtCorreto
	  			MsUnlock()
				nOpca:=1
			Endif
		Endif
	Endif
Endif	
Return(.t.)


////////////////////
Static Function FS_ATUAL_ORC()      

DbSelectArea("VO1")
DbSetOrder(1)
If	!DbSeek(xFilial("VO1")+nNumOS)
  	Aviso(STR0034,STR0035,{STR0036},2)//	Atencao!","OS. nao Existe. Impossivel continuar. # Continuar
	Return(.f.)
Else               
	If cChassi # VO1->VO1_CHASSI  
	  	Aviso(STR0034,STR0037,{STR0036},2)//Atencao!","Chassi nao pertence a OS. Impossivel continuar. # Continuar	
//	   	MsgInfo("Chasis no pertenece a OS. informada...",STR0018)   
		Return(.f.)
	Else
                           

		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek(xFilial("VO1")+nNumOS)
	   	//Altera Nro do Orcamento
	   	RecLock("VO1", .f.)
			   VO1->VO1_NUMORC := cOrcCorreto
			MsUnlock()
			nOpca:=1
		Endif
	Endif
Endif
Return(.t.)


////////////////////
Static Function FS_ATUAL_DTHR()  

DbSelectArea("VO1")
DbSetOrder(1)
If	!DbSeek(xFilial("VO1")+nNumOS)
  	Aviso(STR0034,STR0035,{STR0036},2) // Atencao!","OS. nao Existe. Impossivel continuar. # Continuar	
	Return(.f.)
Else      
	If cChassi # VO1->VO1_CHASSI  
	  	Aviso(STR0034,STR0037,{STR0036},2)	// Atencao!","Chassi nao pertence a OS. Impossivel continuar. # Continuar
//	   	MsgInfo("Chasis no pertenece a OS. informada...",STR0018)   
		Return(.f.)
	Else

		If !Empty(dDtCorreta)
			If FS_VAL_CHASS()
				If FS_VAL_HRC()
					DbSelectArea("VO1")
					DbSetOrder(1)
					If DbSeek(xFilial("VO1") + nNumOS )
					   //Altera a Data/Hora de Abertura da OS
				   	RecLock("VO1", .f.)
					   VO1->VO1_DATABE := dDtCorreta
					   VO1->VO1_HORABE := nHrCorreta
					   MsUnlock()
						nOpca:=1
					EndIf
				EndIf
			EndIf
		Else
			MsgInfo(STR0029,STR0018)
		EndIf	
	Endif
Endif	
Return(.t.)


////////////////////
Static Function FS_ATU_MEMO()                 
	nOpObs := 0
	DEFINE MSDIALOG oDlgObs TITLE STR0032 FROM  02,04 TO 14,56 OF oMainWnd //"Observacoes do Veiculo"
	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (nOpObs:=1,oDlgObs:End()) ENABLE OF oDlgObs
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlgObs:End()) ENABLE OF oDlgObs
	@ 01,011 GET oObserv VAR cObserv OF oDlgObs MEMO SIZE 182,67 PIXEL
	oObserv:SetFocus()
	ACTIVATE MSDIALOG oDlgObs CENTER
	If nOpObs == 1
		DbSelectArea("VO1")
   	RecLock("VO1",.F.)
		MSMM(,TamSx3("VO1_OBSERV")[1],,cObserv,1,,,"VO1","VO1_OBSMEM")
		MsUnlock()
	EndIf
Return(.t.)


////////////////////
Static Function FS_OSVEI()   
	Local aOSVEI := {} 
	DbSelectArea("VO1")
	DbSetOrder(8)
	DbSeek(xFilial("VO1")+cChassi)
	ProcRegua(RecCount())
	While !Eof() .and. xFilial("VO1") == VO1->VO1_FILIAL .and. VO1->VO1_CHASSI == cChassi
		IncProc( OemToAnsi( STR0033 + cChassi ) )
		If VO1->VO1_STATUS # "C"
			Aadd(aOSVEI,{ VO1->VO1_NUMOSV , Transform(VO1->VO1_KILOME,"@E 999,999,999,999") , Transform(VO1->VO1_DATABE,"@D") ,  Transform(VO1->VO1_HORABE,"@R 99:99") } )
		EndIf
		DbSelectArea("VO1")
		DbSkip()
	EndDo	
	If Len(aOSVEI) > 0 
		aSort(aOSVEI,1,,{|x,y| x[1] < y[1] })
		DEFINE MSDIALOG oDlg2 FROM 000,000 TO 018,035 TITLE ( STR0031 + cChassi ) OF oMainWnd
		@ 003,003 LISTBOX oLbx2 FIELDS HEADER OemToAnsi(STR0014),OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017) COLSIZES 25,35,25,22 SIZE 133,110 OF oDlg2 PIXEL 
		DEFINE SBUTTON FROM 119,106 TYPE 2 ACTION ( oDlg2:End()) ENABLE OF oDlg2 PIXEL
		oLbx2:SetArray(aOSVEI)
		oLbx2:bLine := { || {aOSVEI[oLbx2:nAt,1],;
   	                     aOSVEI[oLbx2:nAt,2],;
   	                     aOSVEI[oLbx2:nAt,3],;
                  	      aOSVEI[oLbx2:nAt,4]}}
		ACTIVATE MSDIALOG oDlg2 CENTER
	EndIf   
Return(.t.)
