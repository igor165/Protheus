// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 7    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Ofipa900.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIPA900 ³ Autor ³  Andre                ³ Data ³ 26/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sub. de Itens por Importacao do Arquivo GLASS (SCANIA)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPA900(cPreMar,nOpcx)

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0003)    //Substituicao de Pecas //"Substituicao de Itens"
Private lAuto := .f.
Private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)

nOpcx := If( nOpcx # NIL, nOpcx, 3 )

If cPreMar # NIL
	lAuto := .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lAuto
	
	DbSelectArea("VI9")
	PA900IMP(cPreMar)
	
Else
	
	mBrowse( 6, 1,22,75,"VI9")
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PA900IMP ³ Autor ³  Andre                ³ Data ³ 26/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Importacao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA900IMP(cPreMar)

Local nCntFor := 0
if ( lAuto .Or. MsgYesNo(STR0004,STR0005) ) //"Confirma Importacao?"###"Atencao!"
	
	bCampo := {|x| Field(x)}
	
	PRIVATE oFonte   := TFont():New( "Arial", 8, 14 )
	PRIVATE oOk      := LoadBitmap( GetResources(), "LBOK" )
	PRIVATE oNo      := LoadBitmap( GetResources(), "LBNO" )
	nOpca   := 0
	
	DbSelectArea("VI9")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
	
	wVE9_CODMAR := SPACE(03)
	wVE9_DESMAR := SPACE(30)
	
	If lAuto
		
		wVE9_CODMAR	:= cPreMar
		nOpca       := 1
		
	Else
		
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM  02,04 TO 08,54 OF oMainWnd //"Marca"
		
		@  02, 04 SAY   STR0006 SIZE  25,06 OF oDlg PIXEL FONT oFonte //"Marca"
		@  02, 30 MSGET wVE9_CODMAR PICTURE "@!" F3 "VE1" VALID FS_DESMAR() SIZE  26,04 OF oDlg PIXEL
		@  02, 70 MSGET wVE9_DESMAR SIZE 125,04 OF oDlg PIXEL When .f.
		
		DEFINE SBUTTON FROM 30,127 TYPE 1 ACTION (nOpca := 1,oDlg:End());
		ENABLE OF oDlg
		DEFINE SBUTTON FROM 30,161 TYPE 2 ACTION (nOpca := 2,oDlg:End());
		ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTER
		
	EndIf
	
	if nOpca == 1
		
		lMsErroAuto := .f.
		lMsHelpAuto := .t.
		
		DbSelectArea("SB1")
		cIndex  := CriaTrab(nil,.f.)
		cChave  := "B1_FILIAL+B1_CODITE"
		cCond   := Nil
		IndRegua("SB1",cIndex,cChave,,cCond,STR0010) //Criando Ordem para o Arquivo de Produtos
		nIndex := RetIndex("SB1")+1
		#IFNDEF TOP
			DbSetIndex(cIndex+ordBagExt())
		#ENDIF
		
		VEA->(dbCloseArea())
		if ChkFile("VEA",.T.)
			DbSelectArea("VEA")
			Zap
			VEA->(DbCloseArea())
		Endif
		
		ChkFile("VEA",.F.)
		
		Begin Transaction
		
		DbSelectArea("VI9")
		DbGotop()
		wAchou := DbSeek(xFiliaL("VI9")+wVE9_CODMAR+" 4")
		wIteAnt := " "
		wIteNov := " "
		aMovto1 := {}
		
		Do While !EOF() .And. VI9->VI9_FILIAL+VI9->VI9_CODMAR+VI9->VI9_TIPREG == xFilial("VI9")+wVE9_CODMAR+" 4"   //Substituicao de Item
			
			wGruite := Space(03)
			wIten1  := VI9->VI9_CODITE
			wIten2  := VI9->VI9_ITESUB
			wQtdde  := VI9->VI9_QTDADE
			dDatFim := VI9->VI9_DTAFIM
			
			DbSelectArea("SB1")
			DbSetOrder(nIndex)
			DbSeek(xFilial("SB1")+wIten1)
			
			Do While !EOF() .and. B1_CODITE == wIten1
				wGruite := SB1->B1_GRUPO
				DbSelectArea("SBM")
				DbSetOrder(1)
				if DbSeek(xFilial("SBM")+wGruite)
					if BM_PROORI == "1"  //Se for Original [OK]
						
						// Inicio Integracao
						
						DbSelectArea("VO3")
						DbSetOrder(2)
						DbSeek(xFilial("VO3")+wGruite+wIten1)
						DbSelectArea("VO2")
						DbSetOrder(2)
						DbSeek(xFilial("VO2")+VO3->VO3_NOSNUM)
						DbSelectArea("VO1")
						DbSeek(xFilial("VO1")+VO2->VO2_NUMOSV)
						DbSelectArea("VE9")
						If VO1->VO1_STATUS == "A"
							MsgInfo(STR0008,STR0009) //"Item esta requisitado em uma OS aberta..."###"Antencao!"
							DbSelectArea("SB1")
							DbSkip()
							Exit
						EndIf
						
						if wIten1 # wIteAnt .And. wQtdde > 0
							
							DbSelectArea("SB1")
							DbSetOrder(7)
							if DbSeek(xFilial("SB1")+wGruite+wIten1)
								aMovto1 := {{"D3_TM"		,GetMv("MV_SAIDA")	,NIL},;
								{ "D3_COD"		,SB1->B1_COD		,NIL},;
								{ "D3_UM"		,SB1->B1_UM			,NIL},;
								{ "D3_QUANT"	,wQtdde				,NIL},;
								{ "D3_LOCAL"	,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),NIL},;
								{ "D3_EMISSAO"	,dDataBase			,NIL}}
								DbSetOrder(1)
								MSExecAuto({|x| MATA240(x)},aMovto1)
								DbSelectArea("SB1")
								DbSetOrder(7)
								
								If lMsErroAuto
									DisarmTransaction()
									Break
								EndIf
								
							Endif
							
							wIteAnt := wIten1
							
						Endif
						
						if wIten1 # wIteNov .And. wQtdde > 0
							
							DbSelectArea("SB1")
							DbSetOrder(7)
							if DbSeek(xFilial("SB1")+wGruite+wIten2)
								aMovto1 := {{"D3_TM"		,GetMv("MV_ENTRADA"),NIL},;
								{ "D3_COD"		,SB1->B1_COD		 ,NIL},;
								{ "D3_UM"		,SB1->B1_UM			 ,NIL},;
								{ "D3_QUANT"	,wQtdde				 ,NIL},;
								{ "D3_LOCAL"	,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ,NIL},;
								{ "D3_EMISSAO"	,dDataBase			 ,NIL}}
								DbSetOrder(1)
								MSExecAuto({|x| MATA240(x)},aMovto1)
								DbSelectArea("SB1")
								DbSetOrder(7)
								
								If lMsErroAuto
									DisarmTransaction()
									Break
								EndIf
								
							Endif
							
							wIteNov := wIten2
							
						Endif
						
						// Fim Integracao
						
						DbSelectArea("VEA")
						DbSetOrder(1)
						if !DbSeek(xFilial("VEA")+VI9->VI9_CODITE)
							DbSetOrder(2)
							if !DbSeek(xFilial("VEA")+VI9->VI9_ITESUB)
								wSubst  := FS_NROSUB()
								RecLock("VEA",.t.)
								VEA->VEA_FILIAL := xFilial("VEA")
								VEA->VEA_NROSUB := wSubst
								VEA->VEA_GRUITE := wGruite
								VEA->VEA_ITEANT := wIten1
								VEA->VEA_ITENOV := wIten2
								VEA->VEA_QTDADE := wQtdde
								VEA->VEA_DATFIM := dDatFim
								MsUnlock()
							Else
								wNroSub := VEA_NROSUB
								RecLock("VEA",.t.)
								VEA->VEA_FILIAL := xFilial("VEA")
								VEA->VEA_NROSUB := wNroSub
								VEA->VEA_GRUITE := wGruite
								VEA->VEA_ITEANT := wIten1
								VEA->VEA_ITENOV := wIten2
								VEA->VEA_QTDADE := wQtdde
								VEA->VEA_DATFIM := dDatFim
								MsUnlock()
							Endif
						Else
							wNroSub := VEA_NROSUB
							RecLock("VEA",.t.)
							VEA->VEA_FILIAL := xFilial("VEA")
							VEA->VEA_NROSUB := wNroSub
							VEA->VEA_GRUITE := wGruite
							VEA->VEA_ITEANT := wIten1
							VEA->VEA_ITENOV := wIten2
							VEA->VEA_QTDADE := wQtdde
							VEA->VEA_DATFIM := dDatFim
							MsUnlock()
						Endif
						
						Exit
						
					Endif
				Else
					Exit
				Endif
				
				DbSelectArea("SB1")
				DbSkip()
			Enddo
			
			DbSelectArea("VI9")
			RecLock("VI9",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VI9")
			
			DbSkip()
			
		Enddo
		
		DbSelectArea("VE9")
		nNro := StrZero(reccount()+1,TamSX3("VE9_NROSEQ")[1])
		
		DbSelectArea("VEA")
		DbGotop()
		Do while !EOF()
			
			DbSelectArea("VE9")
			DbSetOrder(3)
			if !DbSeek(xFilial("VE9")+VEA->VEA_ITEANT)
				
				DbSelectArea("SB1")
				DbSetOrder(nIndex)
				if DbSeek(xFilial("SB1")+VEA->VEA_ITEANT)
					RecLock("SB1",.f.)
					SB1->B1_DATASUB := dDataBase
					MsUnlock()
				Endif
				
				DbSelectArea("VE9")
				nNro := StrZero(val(nNro)+1,TamSX3("VE9_NROSEQ")[1])
				RecLock("VE9",.t.)
				VE9->VE9_FILIAL := xFilial("VE9")
				VE9->VE9_NROSEQ := nNro
				VE9->VE9_NROSUB := VEA->VEA_NROSUB
				if lGruNov
					VE9->VE9_GRUNOV := SB1->B1_GRUPO
				endif
				VE9->VE9_GRUITE := SB1->B1_GRUPO
				VE9->VE9_ITEANT := VEA->VEA_ITEANT
				VE9->VE9_ITENOV := VEA->VEA_ITENOV
				VE9->VE9_QTDADE := VEA->VEA_QTDADE
				VE9->VE9_DATSUB := dDataBase
				VE9->VE9_DATFIM := VEA->VEA_DATFIM
				MsUnlock()
				
				DbSelectArea("SB1")
				/*		         DbSetOrder(9)
				
				if DbSeek(xFilial("SB1")+VE9->VE9_ITEANT)
				RecLock("SB1",.f.)
				SB1->B1_DATASUB := dDataBase
				MsUnlock()
				Endif
				*/
			Endif
			
			DbSelectArea("VEA")
			DbSkip()
			
		Enddo
		
		End Transaction
		
		DbSelectArea("SB1")
		Set Filter to
		RetIndex("SB1")
		
	Endif
	
Endif

If lMsErroAuto
	MostraErro()
EndIf

Return .t.


////////////////////
Function FS_NROSUB()
Local i := 0
nRetSub := 0
For i:=1 to 9999999999
	DbSelectArea("VE9")
	DbSetOrder(2)
	DbGotop()
	if !Dbseek(xFilial("VE9")+StrZero(i,10))
		DbSelectArea("VEA")
		wRec := recno()
		DbSetOrder(3)
		DbGotop()
		if !Dbseek(xFilial("VEA")+StrZero(i,10))
			nRetSub := StrZero(i,10)
			DbGoto(wRec)
			Exit
		Endif
	Endif
Next
DbSetOrder(1)

Return(nRetSub)


////////////////////
Function FS_DESMAR()

if Empty(wVE9_CODMAR)
	Return .f.
Endif

if !FG_VALIDA(Nil,"VE1T1wVE9_CODMAR*","wVE9_DESMAR := VE1->VE1_DESMAR")
	Return .f.
Endif

Return .t.

Static Function MenuDef()
Local aRotina := { { STR0001   ,"axPesqui", 0 , 1},;   && Pesquisar //"Pesquisar"
                   {STR0002 ,"PA900IMP" , 0 , 5}}    && Importar //"Importar"
Return aRotina
