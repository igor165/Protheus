// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 15     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOA330.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA330 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza Verba por Veiculo (CHAINT/CLIENTE)  *** VAK ***   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA330()
Local ni         := 0
Local cDepart    := ""
Local lChamaNovo := .f.
Local lVAI_NIVVER:= ( VAI->(FieldPos("VAI_NIVVER")) > 0 )
Local aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
Private overde   := LoadBitmap( GetResources(), "BR_verde" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private oazul    := LoadBitmap( GetResources(), "BR_azul" )
Private opreto   := LoadBitmap( GetResources(), "BR_preto")
Private aVerbas  := {{ctod(""),0,0," "," ",.f.,"","",0}}
Private cFilSM0  := ( aSM0[2] +" - "+ Alltrim(aSM0[6]) +" "+ Alltrim(aSM0[5]) )
Private cCodCli  := space(6)	// Codigo do Cliente
Private cLojCli  := space(2)	// Loja do Cliente
Private cDesCli  := space(200)	// CPF/CNPJ / Fone / Cidade
Private cChaInt  := space(6)	// Chassi Interno do Veiculo
Private cChave   := space(25)	// Chave para acessar o Veiculo no VV1
Private cNomVei  := cDesVei := space(200)	// Marca / Modelo / Placa / Fab/Mod / Cor
Private cCInter  := space(100)	// Chassi Interno
Private cProVei  := space(6)	// Prop. Atual Veiculo
Private cLojVei  := space(2)	// Loja Prop. Atual Veiculo
Private dDatLib  := dDataBase	// Data da Liberacao
Private nVlrPec  := nVlrSrv := 0	// Vlr de Pecas e Servicos Nova Liberacao de Verba
Private nLibPec  := nLibSrv := nLibTot := 0	// Vlr Liberado de Pecas/Servicos/Total
Private nUtiPec  := nUtiSrv := nUtiTot := 0	// Vlr Utilizado de Pecas/Servicos/Total
Private nSalPec  := nSalSrv := nSalTot := 0	// Vlr Saldo Verba de Pecas/Servicos/Total
Private cNivUsu  := "0"			// Nivel do Usuario/Verba
Private cNomUsu  := " "			// Nome do Usuario/Verba
Private nMaxPec  := 0				// Vlr. max. permitido de Pecas pelo nivel do usuario
Private nMaxSrv  := 0				// Vlr. max. permitido de Srvcs pelo nivel do usuario
Private lCli     := .f.			// Cliente Valido ?
Private lVei     := .f.			// Veiculo Valido ?
Private nPerPec  := 100			//	Percentual Pecas (Acordo/Contrato/Normal)
Private nPerSrv  := 100			// Percentual Servicos (Acordo/Contrato/Normal)
Private dDatVal  := dDataBase+30	// Data de Validade da Verba
Private dDatAco  := dDataBase+30	// Data do Final do Acordo
Private cNroORC  := space(8)
Private cDepSol  := space(3)
Private lIncVAK  := .t.
Private nRecVAK  := 0
Private aSolVAK  := {}
Private cSolic1  := ""
Private cSolic2  := ""
Private cLogNiv  := ""
Private aDepart  := {}
Private cDSol    := ""

DbSelectArea("VAI")
DbSetOrder(4)
If DbSeek( xFilial("VAI") + __CUSERID )
	If lVAI_NIVVER
		If !Empty(VAI->VAI_NIVVER)
			cNomUsu := VAI->VAI_NOMUSU
			If Alltrim(VAI->VAI_NIVVER) == "*"
				DbSelectArea("VAP")
				DbSetOrder(1)
				DbSeek(xFilial("VAP"))
				While !Eof() .and. xFilial("VAP") == VAP->VAP_FILIAL
					aadd(aDepart,{VAP->VAP_CODDEP,VAP->VAP_VLPEC3,VAP->VAP_VLSRV3,100,"3"})
					DbSelectArea("VAP")
					DbSkip()
				EndDo
			Else
				For ni := 1 to 20
					cDepart := right(left(VAI->VAI_NIVVER,(ni*5)-1),4)
					If !Empty(cDepart)
						DbSelectArea("VAP")
						DbSetOrder(1)
						If DbSeek(xFilial("VAP")+right(cDepart,3))
							nVlrPec := IIf(left(cDepart,1)#"0",&("VAP_VLPEC"+left(cDepart,1)),0)
							nVlrSrv := IIf(left(cDepart,1)#"0",&("VAP_VLSRV"+left(cDepart,1)),0)
							aadd(aDepart,{VAP->VAP_CODDEP,nVlrPec,nVlrSrv,IIf(left(cDepart,1)=="0",0,100),left(cDepart,1)})
						EndIf
					Else
						Exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf
EndIf

nVlrPec := nVlrSrv := 0
DbSelectArea("VAK")
DbSetOrder(2)
DbSeek( xFilial("VAK") + "0" ) // Verba Solicitada
While !Eof() .and. xFilial("VAK") == VAK->VAK_FILIAL .and. VAK->VAK_SOLLIB == "0"
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + VAK->VAK_CODCLI + VAK->VAK_LOJCLI )
	cAux1 := VAK->VAK_CODCLI+"-"+VAK->VAK_LOJCLI+" "+Alltrim(SA1->A1_NOME)
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek( xFilial("VV1") + VAK->VAK_CHAINT )
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
	DbSelectArea("VV2")
	DbSetOrder(1)
	DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
	DbSelectArea("VVC")
	DbSetOrder(1)
	DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
	cNUMOSV := FM_SQL("SELECT VS1.VS1_NUMOSV FROM "+RetSQLName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMORC='"+VAK->VAK_NUMORC+"' AND VS1.D_E_L_E_T_=' '")
	aadd(aSolVAK,{VAK->VAK_DATLIB,VAK->VAK_NUMORC,VAK->VAK_SOLPEC,VAK->VAK_SOLSER,VAK->VAK_SOLLOG,VAK->(Recno()),VV1->VV1_CHASSI,VV1->VV1_PROATU+"-"+VV1->VV1_LJPATU+" "+Alltrim(SA1->A1_NOME),VV1->VV1_CODMAR+" "+Alltrim(VV2->VV2_DESMOD),Transform(VV1->VV1_FABMOD,"@R 9999/9999"),Alltrim(VVC->VVC_DESCRI),Transform(VV1->VV1_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI"))),cAux1,VAK->VAK_CORNV1,VAK->VAK_CORNV2,VAK->VAK_CORNV3,VAK->VAK_DEPSOL,VAK->VAK_LOGNV1,VAK->VAK_LOGNV2,VAK->VAK_LOGNV3,cNUMOSV})
	DbSelectArea("VAK")
	DbSkip()
EndDo
If len(aSolVAK) == 0
	aadd(aSolVAK,{ctod("")," ",0,0," ",0," ","","","","","","","0","0","0","","","","",""})
	lIncVAK := .t.
EndIf
aSort(aSolVAK,1,,{|x,y| dtos(x[1])+x[2] > dtos(y[1])+y[2] })
DEFINE MSDIALOG oSolVAK FROM 000,000 TO 029,088 TITLE STR0054 OF oMainWnd
@ 003,003 SAY Alltrim(cNomUsu) SIZE 300,08 OF oSolVAK PIXEL COLOR CLR_BLUE
@ 002,285 BUTTON oSair PROMPT (STR0021) OF oSolVAK SIZE 48,10 PIXEL ACTION (oSolVAK:End())
@ 002,157 BUTTON oVOrc PROMPT (STR0075) OF oSolVAK SIZE 55,10 PIXEL ACTION FS_VERORC(aSolVAK[oSolVAKLx:nAt,2])
@ 002,220 BUTTON oExcl PROMPT (STR0063) OF oSolVAK SIZE 57,10 PIXEL ACTION IIf(FS_DELVERBA("1",oSolVAKLx:nAt),(lChamaNovo:=.t.,oSolVAK:End()),.t.)
@ 013,003 LISTBOX oSolVAKLx FIELDS HEADER "1","2","3",STR0055,STR0056,STR0079,STR0080,STR0044,STR0045,STR0062 COLSIZES 10,10,10,30,55,35,35,43,43,66 SIZE 342,150 OF oSolVAK PIXEL ON CHANGE(FS_SOLDESC(oSolVAKLx:nAt),oSolVAK:Refresh()) ON DBLCLICK IIf(aSolVAK[oSolVAKLx:nAt,6]#0,(FS_SOLICITA(aSolVAK[oSolVAKLx:nAt,6]),lChamaNovo:=.t.,oSolVAK:End()),oSolVAK:End())
oSolVAKLx:SetArray(aSolVAK)
oSolVAKLx:bLine := { || {IIf(aSolVAK[oSolVAKLx:nAt,14]=="1",oazul,IIf(aSolVAK[oSolVAKLx:nAt,14]=="2",overde,opreto)),;
IIf(aSolVAK[oSolVAKLx:nAt,15]=="1",oazul,IIf(aSolVAK[oSolVAKLx:nAt,15]=="2",overde,opreto)),;
IIf(aSolVAK[oSolVAKLx:nAt,16]=="1",oazul,IIf(aSolVAK[oSolVAKLx:nAt,16]=="2",overde,opreto)),;
Transform(aSolVAK[oSolVAKLx:nAt,1],"@D"),;
aSolVAK[oSolVAKLx:nAt,17]+" - "+left(aSolVAK[oSolVAKLx:nAt,5],19),;
aSolVAK[oSolVAKLx:nAt,2],;
aSolVAK[oSolVAKLx:nAt,21],;
Transform(aSolVAK[oSolVAKLx:nAt,3],"@E 999999,999.99"),;
Transform(aSolVAK[oSolVAKLx:nAt,4],"@E 999999,999.99"),;
aSolVAK[oSolVAKLx:nAt,7]}}
@ 165,005 SAY oSolic1 VAR cSolic1 SIZE 400,10 OF oSolVAK PIXEL COLOR CLR_BLUE
@ 175,005 SAY oSolic2 VAR cSolic2 SIZE 400,10 OF oSolVAK PIXEL COLOR CLR_BLUE
@ 160,003 TO 185,344 LABEL "" OF oSolVAK PIXEL

@ 195,005 SAY oLogNiv VAR cLogNiv SIZE 400,10 OF oSolVAK PIXEL COLOR CLR_BLACK
@ 187,003 TO 205,344 LABEL STR0070 OF oSolVAK PIXEL

@ 209,005 BITMAP OXpret RESOURCE "BR_preto" OF oSolVAK PIXEL NOBORDER SIZE 10,10 when .f.
@ 209,014 SAY STR0069 SIZE 095,10 OF oSolVAK PIXEL COLOR CLR_BLUE
@ 209,107 BITMAP OXazul RESOURCE "BR_azul" OF oSolVAK PIXEL NOBORDER SIZE 10,10 when .f.
@ 209,116 SAY STR0070 SIZE 085,10 OF oSolVAK PIXEL COLOR CLR_BLUE
@ 209,200 BITMAP OXverd RESOURCE "BR_verde" OF oSolVAK PIXEL NOBORDER SIZE 10,10 when .f.
@ 209,209 SAY STR0071 SIZE 075,10 OF oSolVAK PIXEL COLOR CLR_BLUE
@ 208,285 BUTTON oVer PROMPT OemToAnsi(STR0016) OF oSolVAK SIZE 48,10 PIXEL ACTION Processa( {|| FS_VVERBA(oSolVAKLx:nAt) } )

ACTIVATE MSDIALOG oSolVAK CENTER
If lChamaNovo
	OFIOA330()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VAL_CHA³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Chassi do Veiculo.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_CHA()
Local lRet := .t.
Local nKm  := 0
cNomVei := cDesVei := space(200)
cCInter := space(100)
cChaInt := space(6)
If FG_SEEK("VV1","cChave",2,.f.) .and. cChave == VAK->VAK_CHAINT
	cChaInt := VV1->VV1_CHAINT
ElseIf FG_SEEK("VV1","cChave",6,.f.)
	cChaInt := VV1->VV1_CHAINT
ElseIf FG_SEEK("VV1","cChave",9,.f.)
	cChaInt := VV1->VV1_CHAINT
ElseIf FG_SEEK("VV1","cChave",1,.f.)
	cChaInt := VV1->VV1_CHAINT
EndIf
dDatVal := dDataBase+30
dDatAco := dDataBase+30
lVei    := .f.
If !Empty(cChaInt)
	lRet := .f.
	DbSelectArea("VV1")
	DbSetOrder(1)
	If DbSeek( xFilial("VV1") + cChaInt )
		lRet := .t.
		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
		DbSelectArea("VVC")
		DbSetOrder(1)
		DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
		cNomVei := VV1->VV1_CODMAR +" "+ Alltrim(VV2->VV2_DESMOD) +STR0039 + VV1->VV1_CHASSI
		cDesVei := STR0035+ Transform(VV1->VV1_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI"))) + IIf(!Empty(VV1->VV1_CODFRO),STR0036+VV1->VV1_CODFRO,"") +STR0037+ Transform(VV1->VV1_FABMOD,"@R 9999/9999") +STR0038+ Alltrim(VVC->VVC_DESCRI)
		nKm := FG_UltKil( VV1->VV1_CHAINT )
		If nKm > 0
			cDesVei += "  "+STR0081+":"+Transform(nKm,"@E 999,999,999") // KM
		EndIf
		cChaInt := VV1->VV1_CHAINT
		cCInter := STR0034 + cChaInt
		lVei    := .t.
	Else
		MsgStop(STR0027,STR0025)
	EndIf
EndIf
FS_CAD_VER()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VAL_LIB³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Liberacao de Verba: Data/Vlr.Peca/Vlr.Servico.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_LIB(cTip,nOrigPec,nOrigSrv)
Local lRet := .f.
If cTip == "PEC"
	If nVlrPec >= 0
		If nMaxPec >= nVlrPec
			If nOrigPec >= nVlrPec // Valor Solicitado maior ou igual ao valor a liberar
				lRet := .t.
			Else
				MsgStop(STR0073,STR0025) // Valor de Peca digitado e' maior que o valor solicitado!
			EndIf
		Else
			MsgStop(STR0029+Alltrim(cNomUsu)+" !",STR0025)
		EndIf
	EndIf
ElseIf cTip == "SRV"
	If nVlrSrv >= 0
		If nMaxSrv >= nVlrSrv
			If nOrigSrv >= nVlrSrv // Valor Solicitado maior ou igual ao valor a liberar
				lRet := .t.
			Else
				MsgStop(STR0074,STR0025) // Valor de Servico digitado e' maior que o valor solicitado!
			EndIf
		Else
			MsgStop(STR0030+Alltrim(cNomUsu)+" !",STR0025)
		EndIf
	EndIf
ElseIf cTip == "DTV"
	If ( dDatVal >= dDatLib ) .and. (dDatVal <= dDatAco .or. cNivUsu == "3")
		lRet := .t.
	Else
		MsgStop(STR0031,STR0025)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CAD_LIB³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Liberacao de Verba: VAK. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CAD_LIB()
Local nSPec := 0
Local nSSrv := 0
Local cSDat := dDataBase
Local cSLog := ""
Local cSDep := ""
Local cCNv1 := "0"
Local cCNv2 := "0"
Local cCNv3 := "0"
Local cLNv1 := ""
Local cLNv2 := ""
Local cLNv3 := ""
Local lRet := .f.
If FS_VAL_LIB("DTV",,)
	If ( ( nVlrPec + nVlrSrv ) > 0 )
		lRet := .t.
		DbSelectArea("VAK")
		If !lIncVAK
			DbGoto(nRecVAK)
			nSPec := VAK->VAK_SOLPEC
			nSSrv := VAK->VAK_SOLSER
			cSDat := VAK->VAK_DATLIB
			cSLog := VAK->VAK_SOLLOG
			cSDep := VAK->VAK_DEPSOL
			cCNv1 := VAK->VAK_CORNV1
			cCNv2 := VAK->VAK_CORNV2
			cCNv3 := VAK->VAK_CORNV3
			cLNv1 := VAK->VAK_LOGNV1
			cLNv2 := VAK->VAK_LOGNV2
			cLNv3 := VAK->VAK_LOGNV3
			If ( nSPec  >  nVlrPec ) .or. ( nSSrv > nVlrSrv )
				RecLock("VAK",.t.)
				VAK->VAK_FILIAL := xFilial("VAK")
				VAK->VAK_CODCLI := cCodCli
				VAK->VAK_LOJCLI := cLojCli
				VAK->VAK_CHAINT := cChaInt
				VAK->VAK_DATLIB := cSDat
				VAK->VAK_NUMORC := cNroORC
				VAK->VAK_DEPSOL := cSDep
				VAK->VAK_SOLPEC := IIf(nSPec-nVlrPec>0,nSPec-nVlrPec,0)
				VAK->VAK_SOLSER := IIf(nSSrv-nVlrSrv>0,nSSrv-nVlrSrv,0)
				VAK->VAK_SOLLOG := cSLog
				VAK->VAK_SOLLIB := "0" // Verba Solicitada
				VAK->VAK_CORNV1 := IIf(cNivUsu=="1","2",cCNv1)
				VAK->VAK_CORNV2 := IIf(cNivUsu=="2","2",cCNv2)
				VAK->VAK_CORNV3 := IIf(cNivUsu=="3","2",cCNv3)
				VAK->VAK_LOGNV1 := IIf(!Empty(cLNv1),cLNv1,IIf(cNivUsu=="1",cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5),cLNv1))
				VAK->VAK_LOGNV2 := IIf(!Empty(cLNv2),cLNv2,IIf(cNivUsu=="2",cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5),cLNv2))
				VAK->VAK_LOGNV3 := IIf(!Empty(cLNv3),cLNv3,IIf(cNivUsu=="3",cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5),cLNv3))
				MsUnLock()
				DbGoto(nRecVAK)
			Else
				DbSelectArea("VS1")
				DbSetOrder(1)
				If DbSeek(xFilial("VS1")+cNroORC)
					RecLock("VS1",.f.)
					VS1->VS1_STATUS := "L" // Orcamento Liberado para Exportacao para a OS
					MsUnLock()
					If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
						OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0083 ) // Grava Data/Hora na Mudança de Status do Orçamento / Orcamento Liberado para Exportacao para a OS
					EndIf
				EndIf
				DbSelectArea("VAK")
			EndIf
		EndIf
		cCNv1 := VAK->VAK_CORNV1
		cCNv2 := VAK->VAK_CORNV2
		cCNv3 := VAK->VAK_CORNV3
		cLNv1 := VAK->VAK_LOGNV1
		cLNv2 := VAK->VAK_LOGNV2
		cLNv3 := VAK->VAK_LOGNV3
		RecLock("VAK",lIncVAK)
		VAK->VAK_FILIAL := xFilial("VAK")
		VAK->VAK_CODCLI := cCodCli
		VAK->VAK_LOJCLI := cLojCli
		VAK->VAK_CHAINT := cChaInt
		VAK->VAK_DATLIB := dDatLib
		VAK->VAK_DATVAL := dDatVal
		VAK->VAK_VERPEC := nVlrPec
		VAK->VAK_VERSER := nVlrSrv
		VAK->VAK_NUMORC := cNroORC
		VAK->VAK_DEPSOL := cDepSol
		VAK->VAK_LOGLIB := cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
		VAK->VAK_SOLLIB := "1" // Verba Liberada
		VAK->VAK_CORNV1 := IIf(cNivUsu=="1","2",cCNv1)
		VAK->VAK_CORNV2 := IIf(cNivUsu=="2","2",cCNv2)
		VAK->VAK_CORNV3 := IIf(cNivUsu=="3","2",cCNv3)
		VAK->VAK_LOGNV1 := IIf(!Empty(cLNv1),cLNv1,IIf(cNivUsu=="1",cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5),cLNv1))
		VAK->VAK_LOGNV2 := IIf(!Empty(cLNv2),cLNv2,IIf(cNivUsu=="2",cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5),cLNv2))
		VAK->VAK_LOGNV3 := IIf(!Empty(cLNv3),cLNv3,IIf(cNivUsu=="3",cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5),cLNv3))
		MsUnLock()
		FS_CAD_VER()
		lIncVAK := .t.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CAD_VER³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra na Tela as Verbas cadastradas no VAK.  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CAD_VER()
Local	cDatLib := IIf(Month(dDatLib)==1,strzero(Year(dDatLib)-1,4)+"12",strzero(Year(dDatLib),4)+strzero(Month(dDatLib)-1,2))+"01"
Local aRet    := {}
Local ni      := 0
Local nMesVer := str(Year(dDataBase))+"/"+str(Month(dDataBase))
Local nMesOld := str(Year(dDataBase))+"/"+str(Month(dDataBase)-1)
Local cNUMOSV := ""
If Month(dDataBase) == 1
	nMesOld := str(Year(dDataBase)-1)+"/12"
EndIf
nLibPec := nLibSrv := nLibTot := 0
nUtiPec := nUtiSrv := nUtiTot := 0
nSalPec := nSalSrv := nSalTot := 0
nVlrPec := nVlrSrv := 0
cNroORC := space(8)
cDepSol := space(3)
dDatLib := dDataBase
aVerbas := {}
DbSelectArea("VAK")
DbSetOrder(1)
If dbSeek(xFilial("VAK")+ cCodCli + cLojCli + cChaInt )
	While !Eof() .and. xFilial("VAK") == VAK->VAK_FILIAL .and. ( cCodCli+cLojCli == VAK->VAK_CODCLI+VAK->VAK_LOJCLI ) .and. cChaInt == VAK->VAK_CHAINT
		If ( ( VAK->VAK_VERPEC + VAK->VAK_VERSER ) == 0 )
			DbSelectArea("VAK")
			DbSkip()
			Loop
		EndIf
		cNUMOSV := FM_SQL("SELECT VS1.VS1_NUMOSV FROM "+RetSQLName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMORC='"+VAK->VAK_NUMORC+"' AND VS1.D_E_L_E_T_=' '")
		aadd(aVerbas,{VAK->VAK_DATLIB,VAK->VAK_VERPEC,VAK->VAK_VERSER,VAK->VAK_DEPSOL+" "+VAK->VAK_LOGLIB+STR0042," "+Transform(VAK->VAK_DATLIB,"@D")+" - "+Transform(VAK->VAK_DATVAL,"@D"),.f.,VAK->VAK_NUMORC,cNUMOSV,VAK->(RECNO())})
		If dDataBase <= VAK->VAK_DATVAL
			aVerbas[len(aVerbas),6] := .t.
			If ( cNivUsu $ "123" ) .and. ( cNivUsu == left(VAK->VAK_LOGLIB,1) ) .and. ( str(Year(VAK->VAK_DATLIB))+"/"+str(Month(VAK->VAK_DATLIB)) == nMesVer ) .and. VAK->VAK_DEPSOL == cDSol
				nMaxPec -= VAK->VAK_VERPEC
				nMaxSrv -= VAK->VAK_VERSER
				If nMaxPec < 0
					nMaxPec := 0
				EndIf
				If nMaxSrv < 0
					nMaxSrv := 0
				EndIf
			EndIf
			nLibPec += VAK->VAK_VERPEC
			nLibSrv += VAK->VAK_VERSER
			nLibTot := ( nLibPec + nLibSrv )
		EndIf
		DbSelectArea("VAK")
		DbSkip()
	EndDo
EndIf
aRet := FG_CHKVERBA(cCodCli+cLojCli,cChaInt)
nSalPec := aRet[1]
nSalSrv := aRet[2]
nSalTot := ( nSalPec + nSalSrv )
nUtiPec := ( nLibPec - nSalPec )
nUtiSrv := ( nLibSrv - nSalSrv )
nUtiTot := ( nLibTot - nSalTot )
If Len(aVerbas) == 0
	aVerbas := {{ctod(""),0,0," "," ",.f.,"","",0}}
Else
	aSort(aVerbas,1,,{|x,y| x[7]+dtos(x[1])+x[4] > y[7]+dtos(y[1])+y[4] })
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VER_OS³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra OS's (Pecas/Servicos) - Verbas Utilizadas.    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VER_OS(cTipo)
Local nTp    := 0
Local aOS    := {}
Local aAux   := {}
Local ni     := 0
Local nValor := 0
Local nNumOS := 0
Local aCodSer:= {}
Local aVerVEC:= {}
Local cTipoOS:= IIf(cTipo=="S",STR0051,STR0052)
Local nMesTot:= 0
Local nMesPec:= 0
Local nMesSrv:= 0
Local nPecSrv:= 0
Local nMesVer:= str(Year(dDataBase))+"/"+str(Month(dDataBase))
Local nMesOld:= str(Year(dDataBase))+"/"+str(Month(dDataBase)-1)
If Month(dDataBase) == 1
	nMesOld := str(Year(dDataBase)-1)+"/12"
EndIf
DbSelectArea("VO1")
DbSetOrder(4)
If DbSeek(xFilial("VO1")+cChaInt)
	ProcRegua( RecCount() )
	While !Eof() .and. VO1->VO1_FILIAL == xFilial("VO1") .and. VO1->VO1_CHAINT == cChaInt
		IncProc( STR0047 +" ("+cTipoOS+") - "+ STR0080+": "+VO1->VO1_NUMOSV )
		aadd(aOS,{ " -"+VO1->VO1_NUMOSV , 0 , 0 , 0 , val(VO1->VO1_NUMOSV) , " " , " " })
		nNumOS := len(aOS)
		aVerVEC := {}
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)
		While !Eof() .and. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV
			If (str(Year(VO2->VO2_DATREQ))+"/"+str(Month(VO2->VO2_DATREQ)) == nMesVer) .or. (str(Year(VO2->VO2_DATREQ))+"/"+str(Month(VO2->VO2_DATREQ)) == nMesOld)
				If VO2->VO2_TIPREQ == "P"
					DbSelectArea("VO3")
					DbSetOrder(6)
					DbSeek(xFilial("VO3")+cCodCli+cLojCli+VO2->VO2_NOSNUM)
					While !Eof() .and. VO3->VO3_FILIAL == xFilial("VO3") .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM .and. VO3->VO3_FATPAR+VO3->VO3_LOJA == cCodCli+cLojCli
						If cTipo == "A"
							nPecSrv := Ascan(aOS,{|x| x[1]+strzero(x[5],10)+x[6] == "      "+left(Alltrim(STR0044),1)+" - "+Alltrim(VO3->VO3_GRUITE+" "+VO3->VO3_CODITE)+strzero(aOS[nNumOS,5],10)+"P"+VO3->VO3_GRUITE+VO3->VO3_CODITE })
							If nPecSrv == 0
								DbSelectArea("SB1")
								DbSetOrder(7)
								DbSeek( xFilial("SB1") + VO3->VO3_GRUITE + VO3->VO3_CODITE )
								aadd(aOS,{ "      "+left(Alltrim(STR0044),1)+" - "+Alltrim(VO3->VO3_GRUITE+" "+VO3->VO3_CODITE) , 0 , 0 , 0 , aOS[nNumOS,5] , "P"+VO3->VO3_GRUITE+VO3->VO3_CODITE , SB1->B1_DESC })
								nPecSrv := len(aOS)
							EndIf
						EndIf
						DbSelectArea("VOI")
						DbSetOrder(1)
						If DbSeek(xFilial("VOI")+VO3->VO3_TIPTEM) .and. Empty(VO3->VO3_DATCAN)
							DbSelectArea("VEC")
							DbSetOrder(5)
							If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
								If VO2->VO2_DEVOLU == "1"
									If Ascan(aVerVEC,{|x| x[1]+x[2] == VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE }) == 0
										aadd(aVerVEC,{ VO1->VO1_NUMOSV + VO3->VO3_TIPTEM , VO3->VO3_GRUITE + VO3->VO3_CODITE })
										nValor := VEC->VEC_VALVDA
										aOS[nNumOS,4] += nValor
										aOS[nNumOS,2] += nValor
										If cTipo == "A"
											aOS[nPecSrv,4] += nValor
											aOS[nPecSrv,2] += nValor
										EndIf
										nMesTot += nValor
										nMesPec += nValor
									EndIf
								EndIf
							Else
								If Empty(VO3->VO3_DATFEC)
									If VOI->VOI_VLPCAC == "1"
										nValor := (VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
									Else
										nValor := (FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)*VO3->VO3_QTDREQ)
									EndIf
									If VO2->VO2_DEVOLU == "1"
										aOS[nNumOS,4] += nValor
										aOS[nNumOS,2] += nValor
										If cTipo == "A"
											aOS[nPecSrv,4] += nValor
											aOS[nPecSrv,2] += nValor
										EndIf
										nMesTot += nValor
										nMesPec += nValor
									Else
										aOS[nNumOS,4] -= nValor
										aOS[nNumOS,2] -= nValor
										If cTipo == "A"
											aOS[nPecSrv,4] -= nValor
											aOS[nPecSrv,2] -= nValor
										EndIf
										nMesTot -= nValor
										nMesPec -= nValor
									EndIf
								EndIf
							EndIf
						EndIf
						DbSelectArea("VO3")
						DbSkip()
					EndDo
				Else
					DbSelectArea("VO4")
					DbSetOrder(5)
					DbSeek(xFilial("VO4")+cCodCli+cLojCli+VO2->VO2_NOSNUM)
					While !Eof() .and. VO4->VO4_FILIAL == xFilial("VO4") .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM .and. VO4->VO4_FATPAR+VO4->VO4_LOJA == cCodCli+cLojCli
						If cTipo == "A"
							nPecSrv := Ascan(aOS,{|x| x[1]+strzero(x[5],10)+x[6] == "      "+left(Alltrim(STR0045),1)+" - "+Alltrim(VO4->VO4_GRUSER+" "+VO4->VO4_CODSER)+strzero(aOS[nNumOS,5],10)+"S"+VO4->VO4_GRUSER+VO4->VO4_CODSER })
							If nPecSrv == 0
								DbSelectArea("VO6")
								DbSetOrder(2)
								DbSeek(xFilial("VO6")+VO1->VO1_CODMAR+VO4->VO4_CODSER)
								aadd(aOS,{ "      "+left(Alltrim(STR0045),1)+" - "+Alltrim(VO4->VO4_GRUSER+" "+VO4->VO4_CODSER) , 0 , 0 , 0 , aOS[nNumOS,5] , "S"+VO4->VO4_GRUSER+VO4->VO4_CODSER , VO6->VO6_DESSER })
								nPecSrv := len(aOS)
							EndIf
						EndIf
						nValor := 0
						DbSelectArea("VOI")
						DbSetOrder(1)
						If DbSeek(xFilial("VOI")+VO4->VO4_TIPTEM) .and. Empty(VO4->VO4_DATCAN)
							If VOI->VOI_SITTPO == "3"
								if !Empty(VO4->VO4_DATFEC) .or. !Empty(VO4->VO4_DATCAN)
									nValor := VO4->VO4_VALINT
								Else
									if VOK->VOK_INCTEM == "3"
										aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER+"T" )
										If aCodSer[6]  && se nao foi somado soma
											nValor := (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR) // Valor Srv Interno
										Endif
									Else
										aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER+"T" )
										If aCodSer[6]  && se nao foi somado soma
											nValor := (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR) // Valor Srv Interno
										Endif
									Endif
								Endif
							Else
								nValor := FG_CALVLSER( aCodSer , VO2->VO2_NUMOSV + VO4->VO4_NOSNUM + VO4->VO4_CODSER , "F" )[1]
							EndIf
							aOS[nNumOS,4] += nValor
							aOS[nNumOS,3] += nValor
							If cTipo == "A"
								aOS[nPecSrv,4] += nValor
								aOS[nPecSrv,3] += nValor
							EndIf
							nMesTot += nValor
							nMesSrv += nValor
						Else
							If VOI->VOI_SITTPO == "3"
								nValor := FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
							Else
								nValor := FG_CALVLSER( aCodSer , VO2->VO2_NUMOSV + VO4->VO4_NOSNUM + VO4->VO4_CODSER )[1]
							EndIf
							aOS[nNumOS,4] += nValor
							aOS[nNumOS,3] += nValor
							If cTipo == "A"
								aOS[nPecSrv,4] += nValor
								aOS[nPecSrv,3] += nValor
							EndIf
							nMesTot += nValor
							nMesSrv += nValor
						EndIf
						DbSelectArea("VO4")
						DbSkip()
					EndDo
				EndIf
			EndIf
			DbSelectArea("VO2")
			DbSkip()
		EndDo
		DbSelectArea("VO1")
		DbSkip()
	EndDo
EndIf
aAux := {}
For ni := 1 to len(aOS)
	If aOS[ni,4] > 0
		aadd(aAux,{aOS[ni,1],aOS[ni,2],aOS[ni,3],aOS[ni,4],aOS[ni,5],aOS[ni,6],aOS[ni,7]})
	EndIf
Next
aOS := {}
aOS := aClone(aAux)
If len(aOS) == 0
	aadd(aOS,{ " " , 0 , 0 , 0 , 0 , " " , " " })
EndIf
aSort(aOS,1,,{|x,y| strzero(x[5],10)+x[6] < strzero(y[5],10)+y[6] })
DEFINE MSDIALOG oOSVerb FROM 000,000 TO 029,080 TITLE (STR0047+" ("+cTipoOS+") - "+STR0041+" - "+cCInter) OF oMainWnd
@ 010,265 BUTTON oSair PROMPT OemToAnsi(STR0021) OF oOSVerb SIZE 48,10 PIXEL ACTION (oOSVerb:End())
@ 006,003 SAY cNomVei SIZE 300,08 OF oOSVerb PIXEL COLOR CLR_BLUE
If cTipo == "S" // Sintetico
	@ 010,220 BUTTON oVEROSA PROMPT (STR0052) OF oOSVerb SIZE 40,10 PIXEL ACTION (nTp:=1,oOSVerb:End())
Else // Analitico
	@ 010,220 BUTTON oVEROSS PROMPT (STR0051) OF oOSVerb SIZE 40,10 PIXEL ACTION (nTp:=2,oOSVerb:End())
EndIf
@ 000,265 BUTTON oVERMES PROMPT (STR0048) OF oOSVerb SIZE 48,10 PIXEL ACTION (nTp:=3,oOSVerb:End())
@ 020,003 LISTBOX oOSVerbLx FIELDS HEADER STR0043,STR0044+Transform(nMesPec,"@E 9999,999,999,999.99"),STR0045+Transform(nMesSrv,"@E 9999,999,999,999.99"),STR0046+Transform(nMesTot,"@E 9999,999,999,999.99") COLSIZES 120,60,60,60 SIZE 311,195 OF oOSVerb PIXEL
oOSVerbLx:SetArray(aOS)
oOSVerbLx:bLine := { || {aOS[oOSVerbLx:nAt,1]+" "+aOS[oOSVerbLx:nAt,7],;
IIf(left(aOS[oOSVerbLx:nAt,1],3)=="   ".and.aOS[oOSVerbLx:nAt,2]==0," ",Transform(aOS[oOSVerbLx:nAt,2],"@E 9999,999,999,999.99")),;
IIf(left(aOS[oOSVerbLx:nAt,1],3)=="   ".and.aOS[oOSVerbLx:nAt,3]==0," ",Transform(aOS[oOSVerbLx:nAt,3],"@E 9999,999,999,999.99")),;
Transform(aOS[oOSVerbLx:nAt,4],"@E 9999,999,999,999.99")}}
ACTIVATE MSDIALOG oOSVerb CENTER
If nTp == 1
	Processa( {|| FS_VER_OS("A") } )
ElseIf nTp == 2
	Processa( {|| FS_VER_OS("S") } )
ElseIf nTp == 3
	Processa( {|| FS_VER_MES("R") } )
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VER_MES³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra Ultimos 12 Meses (Pecas/Servicos).		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VER_MES(cTipo)
Local nTp    := 0
Local aMes   := {}
Local nMes   := 0
Local cMes   := ""
Local aAux   := {}
Local ni     := 0
Local nj     := 0
Local nValor := 0
Local nOS    := 0
Local nPecSrv:= 0
Local aCodSer:= {}
Local dDtIni := ctod("01/"+strzero(month(dDataBase),2)+"/"+substr(strzero(Year(dDataBase)-1,4),3,2))
Local dDtFin := dDataBase
Local nMesTot:= 0
Local nMesPec:= 0
Local nMesSrv:= 0
Local cTipoOS:= IIf(cTipo=="R",STR0050,IIf(cTipo=="S",STR0051,STR0052))
Local aVerVEC := {}
For ni := 1 to 13
	If (month(dDataBase)-1+ni) > 12
		nj := 1
		cMes := strzero(month(dDataBase)-13+ni,2)
	Else
		cMes := strzero(month(dDataBase)-1+ni,2)
	EndIf
	aadd(aMes,{ cMes+" / "+strzero(Year(dDataBase)-1+nj,4) , 0 , 0 , 0 , ni , "X" , " " })
Next
DbSelectArea("VO1")
DbSetOrder(4)
If DbSeek(xFilial("VO1")+cChaInt)
	ProcRegua( RecCount() )
	While !Eof() .and. VO1->VO1_FILIAL == xFilial("VO1") .and. VO1->VO1_CHAINT == cChaInt
		IncProc( STR0048 +" ("+cTipoOS+") - "+ STR0080+": "+VO1->VO1_NUMOSV )
		aVerVEC := {}
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)
		While !Eof() .and. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV
			If VO2->VO2_DATREQ >= dDtIni .and. VO2->VO2_DATREQ <= dDtFin
				nMes := Ascan(aMes,{|x| x[1] == strzero(month(VO2->VO2_DATREQ),2)+" / "+strzero(Year(VO2->VO2_DATREQ),4) })
				If nMes > 0
					If cTipo # "R"
						nOS := Ascan(aMes,{|x| x[1]+strzero(x[5],5) == " -"+VO1->VO1_NUMOSV+strzero(aMes[nMes,5],5) })
						If nOS == 0
							aadd(aMes,{ " -"+VO1->VO1_NUMOSV , 0 , 0 , 0 , aMes[nMes,5] , strzero(9999999999-val(VO1->VO1_NUMOSV),10)+"XXXXX" , " " })
							nOS := len(aMes)
						EndIf
					EndIf
					If VO2->VO2_TIPREQ == "P"
						DbSelectArea("VO3")
						DbSetOrder(6)
						DbSeek(xFilial("VO3")+cCodCli+cLojCli+VO2->VO2_NOSNUM)
						While !Eof() .and. VO3->VO3_FILIAL == xFilial("VO3") .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM .and. VO3->VO3_FATPAR+VO3->VO3_LOJA == cCodCli+cLojCli
							If Empty(VO3->VO3_DATCAN)
								If cTipo == "A"
									nPecSrv := Ascan(aMes,{|x| x[1]+strzero(x[5],5)+left(x[6],10) == "      "+left(Alltrim(STR0044),1)+" - "+Alltrim(VO3->VO3_GRUITE+" "+VO3->VO3_CODITE)+strzero(aMes[nMes,5],5)+strzero(9999999999-val(VO1->VO1_NUMOSV),10) })
									If nPecSrv == 0
										DbSelectArea("SB1")
										DbSetOrder(7)
										DbSeek( xFilial("SB1") + VO3->VO3_GRUITE + VO3->VO3_CODITE )
										aadd(aMes,{ "      "+left(Alltrim(STR0044),1)+" - "+Alltrim(VO3->VO3_GRUITE+" "+VO3->VO3_CODITE) , 0 , 0 , 0 , aMes[nMes,5] , strzero(9999999999-val(VO1->VO1_NUMOSV),10)+"X"+VO3->VO3_GRUITE+VO3->VO3_CODITE , SB1->B1_DESC })
										nPecSrv := len(aMes)
									EndIf
								EndIf
								DbSelectArea("VEC")
								DbSetOrder(5)
								If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
									If VO2->VO2_DEVOLU == "1"
										If Ascan(aVerVEC,{|x| x[1]+x[2] == VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE }) == 0
											aadd(aVerVEC,{ VO1->VO1_NUMOSV + VO3->VO3_TIPTEM , VO3->VO3_GRUITE + VO3->VO3_CODITE })
											nValor := VEC->VEC_VALVDA
											aMes[nMes,4] += nValor
											aMes[nMes,2] += nValor
											If cTipo # "R"
												aMes[nOS,4] += nValor
												aMes[nOS,2] += nValor
												If cTipo == "A"
													aMes[nPecSrv,4] += nValor
													aMes[nPecSrv,2] += nValor
												EndIf
											EndIf
											nMesTot += nValor
											nMesPec += nValor
										EndIf
									EndIf
								Else
									If Empty(VO3->VO3_DATFEC)
										If VOI->VOI_VLPCAC == "1"
											nValor := (VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
										Else
											nValor := (FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)*VO3->VO3_QTDREQ)
										EndIf
										If VO2->VO2_DEVOLU == "1"
											aMes[nMes,4] += nValor
											aMes[nMes,2] += nValor
											If cTipo # "R"
												aMes[nOS,4] += nValor
												aMes[nOS,2] += nValor
												If cTipo == "A"
													aMes[nPecSrv,4] += nValor
													aMes[nPecSrv,2] += nValor
												EndIf
											EndIf
											nMesTot += nValor
											nMesPec += nValor
										Else
											aMes[nMes,4] -= nValor
											aMes[nMes,2] -= nValor
											If cTipo # "R"
												aMes[nOS,4] -= nValor
												aMes[nOS,2] -= nValor
												If cTipo == "A"
													aMes[nPecSrv,4] -= nValor
													aMes[nPecSrv,2] -= nValor
												EndIf
											EndIf
											nMesTot -= nValor
											nMesPec -= nValor
										EndIf
									EndIf
								EndIf
							EndIf
							DbSelectArea("VO3")
							DbSkip()
						EndDo
					Else
						DbSelectArea("VO4")
						DbSetOrder(5)
						DbSeek(xFilial("VO4")+cCodCli+cLojCli+VO2->VO2_NOSNUM)
						While !Eof() .and. VO4->VO4_FILIAL == xFilial("VO4") .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM .and. VO4->VO4_FATPAR+VO4->VO4_LOJA == cCodCli+cLojCli
							If cTipo == "A"
								nPecSrv := Ascan(aMes,{|x| x[1]+strzero(x[5],5)+left(x[6],10) == "      "+left(Alltrim(STR0045),1)+" - "+Alltrim(VO4->VO4_GRUSER+" "+VO4->VO4_CODSER)+strzero(aMes[nMes,5],5)+strzero(9999999999-val(VO1->VO1_NUMOSV),10) })
								If nPecSrv == 0
									DbSelectArea("VO6")
									DbSetOrder(2)
									DbSeek(xFilial("VO6")+VO1->VO1_CODMAR+VO4->VO4_CODSER)
									aadd(aMes,{ "      "+left(Alltrim(STR0045),1)+" - "+Alltrim(VO4->VO4_GRUSER+" "+VO4->VO4_CODSER) , 0 , 0 , 0 , aMes[nMes,5] , strzero(9999999999-val(VO1->VO1_NUMOSV),10)+"S"+VO4->VO4_GRUSER+VO4->VO4_CODSER , VO6->VO6_DESSER })
									nPecSrv := len(aMes)
								EndIf
							EndIf
							nValor := 0
							DbSelectArea("VOI")
							DbSetOrder(1)
							If DbSeek(xFilial("VOI")+VO4->VO4_TIPTEM) .and. Empty(VO4->VO4_DATCAN)
								If VOI->VOI_SITTPO == "3"
									If !Empty(VO4->VO4_DATFEC) .or. !Empty(VO4->VO4_DATCAN)
										nValor := VO4->VO4_VALINT
									Else
										If VOK->VOK_INCTEM == "3"
											aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER+"T" )
											If aCodSer[6]  && se nao foi somado soma
												nValor := (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR) // Valor Srv Interno
											EndIf
										Else
											aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER+"T" )
											If aCodSer[6]  && se nao foi somado soma
												nValor := (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR) // Valor Srv Interno
											EndIf
										EndIf
									EndIf
								Else
									nValor := FG_CALVLSER( aCodSer , VO2->VO2_NUMOSV + VO4->VO4_NOSNUM + VO4->VO4_CODSER , "F" )[1]
								EndIf
								aMes[nMes,4] += nValor
								aMes[nMes,3] += nValor
								If cTipo # "R"
									aMes[nOS,4] += nValor
									aMes[nOS,3] += nValor
									If cTipo == "A"
										aMes[nPecSrv,4] += nValor
										aMes[nPecSrv,3] += nValor
									EndIf
								EndIf
								nMesTot += nValor
								nMesSrv += nValor
							Else
								If VOI->VOI_SITTPO == "3"
									nValor := FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
								Else
									nValor := FG_CALVLSER( aCodSer , VO2->VO2_NUMOSV + VO4->VO4_NOSNUM + VO4->VO4_CODSER )[1]
								EndIf
								aMes[nMes,4] += nValor
								aMes[nMes,3] += nValor
								If cTipo # "R"
									aMes[nOS,4] += nValor
									aMes[nOS,3] += nValor
									If cTipo == "A"
										aMes[nPecSrv,4] += nValor
										aMes[nPecSrv,3] += nValor
									EndIf
								EndIf
								nMesTot += nValor
								nMesSrv += nValor
							EndIf
							DbSelectArea("VO4")
							DbSkip()
						EndDo
					EndIf
				EndIf
			EndIf
			DbSelectArea("VO2")
			DbSkip()
		EndDo
		DbSelectArea("VO1")
		DbSkip()
	EndDo
EndIf
If cTipo # "R"
	aAux := {}
	For ni := 1 to len(aMes)
		If aMes[ni,6]=="X" .or. aMes[ni,4] > 0
			aadd(aAux,{aMes[ni,1],aMes[ni,2],aMes[ni,3],aMes[ni,4],aMes[ni,5],aMes[ni,6],aMes[ni,7]})
		EndIf
	Next
	aMes := {}
	aMes := aClone(aAux)
EndIf
If len(aMes) == 0
	aadd(aMes,{ " " , 0 , 0 , 0 , 0 , " " , " " })
EndIf
aSort(aMes,1,,{|x,y| strzero(x[5],5)+x[6] > strzero(y[5],5)+y[6] })
DEFINE MSDIALOG oMesVerb FROM 000,000 TO 029,080 TITLE (STR0048+" ("+cTipoOS+") - "+STR0041+" - "+cCInter) OF oMainWnd
@ 010,265 BUTTON oSair PROMPT OemToAnsi(STR0021) OF oMesVerb SIZE 48,10 PIXEL ACTION (oMesVerb:End())
If cTipo == "R" // Resumido
	@ 000,220 BUTTON oVEROSS PROMPT (STR0051) OF oMesVerb SIZE 40,10 PIXEL ACTION (nTp:=1,oMesVerb:End())
	@ 010,220 BUTTON oVEROSA PROMPT (STR0052) OF oMesVerb SIZE 40,10 PIXEL ACTION (nTp:=2,oMesVerb:End())
ElseIf cTipo == "S" // Sintetico
	@ 000,220 BUTTON oVEROSR PROMPT (STR0050) OF oMesVerb SIZE 40,10 PIXEL ACTION (nTp:=3,oMesVerb:End())
	@ 010,220 BUTTON oVEROSA PROMPT (STR0052) OF oMesVerb SIZE 40,10 PIXEL ACTION (nTp:=2,oMesVerb:End())
Else // Analitico
	@ 000,220 BUTTON oVEROSR PROMPT (STR0050) OF oMesVerb SIZE 40,10 PIXEL ACTION (nTp:=3,oMesVerb:End())
	@ 010,220 BUTTON oVEROSS PROMPT (STR0051) OF oMesVerb SIZE 40,10 PIXEL ACTION (nTp:=1,oMesVerb:End())
EndIf
@ 000,265 BUTTON oVEROS PROMPT (STR0047) OF oMesVerb SIZE 48,10 PIXEL ACTION (nTp:=4,oMesVerb:End())
@ 006,003 SAY cNomVei SIZE 300,08 OF oMesVerb PIXEL COLOR CLR_BLUE
@ 020,003 LISTBOX oMesVerbLx FIELDS HEADER STR0049+IIf(cTipo#"R"," -"+STR0043,""),STR0044+Transform(nMesPec,"@E 9999,999,999,999.99"),STR0045+Transform(nMesSrv,"@E 9999,999,999,999.99"),STR0046+Transform(nMesTot,"@E 9999,999,999,999.99") COLSIZES 120,60,60,60 SIZE 311,195 OF oMesVerb PIXEL
oMesVerbLx:SetArray(aMes)
oMesVerbLx:bLine := { || {aMes[oMesVerbLx:nAt,1]+" "+aMes[oMesVerbLx:nAt,7],;
IIf(left(aMes[oMesVerbLx:nAt,1],3)=="   ".and.aMes[oMesVerbLx:nAt,2]==0," ",Transform(aMes[oMesVerbLx:nAt,2],"@E 9999,999,999,999.99")),;
IIf(left(aMes[oMesVerbLx:nAt,1],3)=="   ".and.aMes[oMesVerbLx:nAt,3]==0," ",Transform(aMes[oMesVerbLx:nAt,3],"@E 9999,999,999,999.99")),;
Transform(aMes[oMesVerbLx:nAt,4],"@E 9999,999,999,999.99")}}
ACTIVATE MSDIALOG oMesVerb CENTER
If nTp == 1
	Processa( {|| FS_VER_MES("S") } )
ElseIf nTp == 2
	Processa( {|| FS_VER_MES("A") } )
ElseIf nTp == 3
	Processa( {|| FS_VER_MES("R") } )
ElseIf nTp == 4
	Processa( {|| FS_VER_OS("S") } )
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_SOLICITA³ Autor ³ Andre Luis Almeida   ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verbas Solicitadas VAK (Pecas/Servicos) == 0.	    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SOLICITA(nReg)
Local nOrigPec := 0
Local nOrigSrv := 0
Local nPos   := 0
Local cAux1  := ""
Local cAux2  := ""
Local nAux1  := 0
Local nAux2  := 0
Local OXverd
Local OXpret
Local OXazul
If nReg > 0
	lCli    := .f.
	nRecVAK := nReg
	DbSelectArea("VAK")
	DbGoto(nRecVAK)  
 	DbSelectArea("VS1")
	DbSetOrder(1)  
	if DbSeek(xFilial("VS1")+VAK->VAK_NUMORC)
	   if VS1->VS1_DATVAL < dDataBase
	      MsgStop(STR0078)
	      Return(.f.)
	   Endif
	Endif
	nPerPec := 0
	nPerSrv := 0
	nPos :=  Ascan(aDepart,{|x| x[1] == VAK->VAK_DEPSOL })
	If nPos > 0
		cNivUsu := aDepart[nPos,5]
		nMaxPec := aDepart[nPos,2]
		nMaxSrv := aDepart[nPos,3]
		nPerPec := aDepart[nPos,4]
		nPerSrv := aDepart[nPos,4]
	EndIf
	nMaxPec := ( nMaxPec * ( nPerPec / 100 ) )
	nMaxSrv := ( nMaxSrv * ( nPerSrv / 100 ) )
	cCodCli := VAK->VAK_CODCLI
	cLojCli := VAK->VAK_LOJCLI
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek( xFilial("SA1") + cCodCli + cLojCli )
		lCli := .t.
	EndIf
	cDesCli := cCodCli +"-"+ cLojCli +" "+left(SA1->A1_NOME,30)
	If cNivUsu == "1"
		If VAK->VAK_CORNV1 $ " 0"
			DbSelectArea("VAK")
			RecLock("VAK",.f.)
			VAK->VAK_CORNV1 := "1" // Azul
			VAK->VAK_LOGNV1 := cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
			MsUnLock()
		ElseIf VAK->VAK_CORNV1 == "1"
			If (cNivUsu+" "+left(cNomUsu,13)) == left(VAK->VAK_LOGNV1,15)
				DbSelectArea("VAK")
				RecLock("VAK",.f.)
				VAK->VAK_CORNV1 := "0" // Preto
				VAK->VAK_LOGNV1 := ""
				MsUnLock()
			EndIf
		EndIf
	ElseIf cNivUsu == "2"
		If VAK->VAK_CORNV2 $ " 0"
			DbSelectArea("VAK")
			RecLock("VAK",.f.)
			VAK->VAK_CORNV2 := "1" // Azul
			VAK->VAK_LOGNV2 := cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
			MsUnLock()
		ElseIf VAK->VAK_CORNV2 == "1"
			If (cNivUsu+" "+left(cNomUsu,13)) == left(VAK->VAK_LOGNV2,15)
				DbSelectArea("VAK")
				RecLock("VAK",.f.)
				VAK->VAK_CORNV2 := "0" // Preto
				VAK->VAK_LOGNV2 := ""
				MsUnLock()
			EndIf
		EndIf
	ElseIf cNivUsu == "3"
		If VAK->VAK_CORNV3 $ " 0"
			DbSelectArea("VAK")
			RecLock("VAK",.f.)
			VAK->VAK_CORNV3 := "1" // Azul
			VAK->VAK_LOGNV3 := cNivUsu+" "+left(cNomUsu,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
			MsUnLock()
		ElseIf VAK->VAK_CORNV3 == "1"
			If (cNivUsu+" "+left(cNomUsu,13)) == left(VAK->VAK_LOGNV3,15)
				DbSelectArea("VAK")
				RecLock("VAK",.f.)
				VAK->VAK_CORNV3 := "0" // Preto
				VAK->VAK_LOGNV3 := ""
				MsUnLock()
			EndIf
		EndIf
	EndIf
	cChave  := left(VAK->VAK_CHAINT+space(25),25)
	cAux1   := VAK->VAK_NUMORC
	cDSol   := cAux2   := VAK->VAK_DEPSOL
	nAux1   := VAK->VAK_SOLPEC
	nAux2   := VAK->VAK_SOLSER
	FS_VAL_CHA()
	cNroORC := cAux1
	cDepSol := cAux2
	nVlrPec := nAux1
	nVlrSrv := nAux2
	lIncVAK := .f.
	nOrigPec := nVlrPec
	nOrigSrv := nVlrSrv
	
	aSort(aVerbas,1,,{|x,y| ctod(Left(Alltrim(x[5]),8)) > ctod(Left(Alltrim(y[5]),8)) })
	DEFINE MSDIALOG oVerb FROM 000,000 TO 029,088 TITLE (STR0001+cFilSM0) OF oMainWnd
	// Cliente //
	@ 008,007 SAY ( STR0002+" "+cDesCli ) SIZE 400,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 001,003 TO 018,344 LABEL STR0040 OF oVerb PIXEL // Caixa Cliente
	// Veiculo //
	@ 034,007 SAY cCInter SIZE 150,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 025,007 SAY cNomVei SIZE 350,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 034,080 SAY cDesVei SIZE 350,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 018,003 TO 043,344 LABEL STR0041 OF oVerb PIXEL // Caixa Veiculo
	// Saldo Maximo para Liberacao pelo Usuario (Nivel) //
	@ 197,005 SAY FG_AlinVlrs(STR0005+Transform(nMaxPec,"@E 9999,999,999,999.99"),"E") SIZE 95,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 205,005 SAY FG_AlinVlrs(STR0006+Transform(nMaxSrv,"@E 9999,999,999,999.99"),"E") SIZE 95,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 189,003 TO 216,085 LABEL (STR0004+Alltrim(" "+cDepSol+" "+cNivUsu)) OF oVerb PIXEL // Caixa Saldo pelo Usuario (Nivel)
	// Nova Liberacao de Verba //
	@ 195,093 SAY STR0007 SIZE 100,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 202,092 MSGET oDatLib VAR dDatLib PICTURE "@D" SIZE 39,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 195,132 SAY STR0008 SIZE 100,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 202,130 MSGET oDatVal VAR dDatVal PICTURE "@D" VALID FS_VAL_LIB("DTV",,) SIZE 39,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN ( cNivUsu # "0" )
	@ 195,175 SAY STR0009 SIZE 90,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 202,168 MSGET oVlrPec VAR nVlrPec PICTURE "@E 999999,999,999.99" VALID FS_VAL_LIB("PEC",nOrigPec,nOrigSrv) SIZE 56,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN ( lCli .and. lVei .and. ( cNivUsu # "0" ) )
	@ 195,227 SAY STR0010 SIZE 100,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 202,223 MSGET oVlrSrv VAR nVlrSrv PICTURE "@E 999999,999,999.99" VALID FS_VAL_LIB("SRV",nOrigPec,nOrigSrv) SIZE 56,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN ( lCli .and. lVei .and. ( cNivUsu # "0" ) )
	@ 195,282 SAY STR0043 SIZE 100,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 202,278 MSGET oNroORC VAR cNroORC PICTURE "99999999" SIZE 32,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 202,318 BUTTON oLib PROMPT OemToAnsi(STR0053) OF oVerb SIZE 12,10 PIXEL ACTION IIf(FS_VAL_LIB("PEC",nOrigPec,nOrigSrv).and.FS_VAL_LIB("SRV",nOrigPec,nOrigSrv),(FS_CAD_LIB(),oVerb:End()),.f.) WHEN ( !Empty(cNroORC) .and. lCli .and. lVei .and. ( cNivUsu # "0" ) )
	@ 189,088 TO 216,344 LABEL STR0011 OF oVerb PIXEL // Caixa Nova Liberacao
	// Lista Verba Liberada //
	@ 046,003 LISTBOX oVerbLx FIELDS HEADER STR0012,STR0013,STR0014,STR0079,STR0080,"",STR0015 COLSIZES 60,60,60,30,30,10,58 SIZE 342,108 OF oVerb PIXEL ON CHANGE FS_HABILITA(aVerbas[oVerbLx:nAt,8])
	oVerbLx:SetArray(aVerbas)
	oVerbLx:bLine := { || {	aVerbas[oVerbLx:nAt,5],;
	FG_AlinVlrs(Transform(aVerbas[oVerbLx:nAt,2],"@E 9999,999,999,999.99")),;
	FG_AlinVlrs(Transform(aVerbas[oVerbLx:nAt,3],"@E 9999,999,999,999.99")),;
	aVerbas[oVerbLx:nAt,7],;
	aVerbas[oVerbLx:nAt,8],;
	IIf(aVerbas[oVerbLx:nAt,6],overde,overmelho),;
	aVerbas[oVerbLx:nAt,4]}}
	// Total Verba Liberada //
	@ 156,007 BITMAP oxVerde RESOURCE "BR_verde" OF oVerb NOBORDER SIZE 10,10 PIXEL
	@ 156,020 SAY STR0016 SIZE 130,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 154,072 MSGET oLibPec VAR nLibPec PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 154,135 MSGET oLibSrv VAR nLibSrv PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 156,210 SAY STR0017 SIZE 130,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 154,257 MSGET oLibTot VAR nLibTot PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	// Total Verba Utilizada //
	@ 165,005 BUTTON oVer PROMPT OemToAnsi("...") OF oVerb SIZE 11,10 PIXEL ACTION ( Processa( {|| FS_VER_OS("S") } ),oVerbLx:SetFocus()) WHEN (!Empty(cCodCli+cLojCli).and.!Empty(cChaInt))
	@ 166,020 SAY STR0018 SIZE 130,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 164,072 MSGET oUtiPec VAR nUtiPec PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 164,135 MSGET oUtiSrv VAR nUtiSrv PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 166,210 SAY STR0019 SIZE 130,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 164,257 MSGET oUtiTot VAR nUtiTot PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	// Total Saldo da Verba //
	@ 176,020 SAY STR0020 SIZE 130,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 174,072 MSGET oSalPec VAR If(nSalPec>0,nSalPec,0) PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 174,135 MSGET oSalSrv VAR If(nSalSrv>0,nSalSrv,0) PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	@ 176,210 SAY STR0020 SIZE 130,08 OF oVerb PIXEL COLOR CLR_BLUE
	@ 174,257 MSGET oSalTot VAR If(nSalTot>0,nSalTot,0) PICTURE "@E 9999,999,999,999.99" SIZE 61,08 OF oVerb PIXEL COLOR CLR_HBLUE WHEN .f.
	// Caixa Totais //
	@ 140,003 TO 188,344 LABEL "" OF oVerb PIXEL // Caixa Totais
	// Botoes - Visualiza Orcamento / Excluir Verba / Sair //
	@ 006,157 BUTTON oVOrc PROMPT (STR0075) OF oVerb SIZE 55,10 PIXEL ACTION FS_VERORC(aVerbas[oVerbLx:nAt,7]) WHEN !Empty(aVerbas[oVerbLx:nAt,7])
	@ 006,220 BUTTON oExcl PROMPT (STR0063) OF oVerb SIZE 57,10 PIXEL ACTION (FS_DELVERBA("2",aVerbas[oVerbLx:nAt,9]),oVerb:End()) WHEN Empty(aVerbas[oVerbLx:nAt,8])
	@ 006,285 BUTTON oSair PROMPT OemToAnsi(STR0021) OF oVerb SIZE 48,10 PIXEL ACTION (oVerb:End())
	ACTIVATE MSDIALOG oVerb CENTER	
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_SOLDESC³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra PLACA/MARCA/MODELO/PROPRIET... nas Liberacoes.   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SOLDESC(nP)
Local nKm := 0
cSolic1 := ""
cSolic2 := ""
cLogNiv := ""
If !Empty(aSolVAK[nP,7])
	cSolic1 := ( STR0061+": "+aSolVAK[nP,12]+"   "+STR0058+": "+aSolVAK[nP,9]+"   "+STR0059+": "+aSolVAK[nP,10]+"   "+STR0060+": "+Alltrim(aSolVAK[nP,11]) )
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek( xFilial("VV1") + aSolVAK[nP,7] )
	nKm := FG_UltKil( VV1->VV1_CHAINT )
	If nKm > 0
		cSolic1 += "   "+STR0081+":"+Transform(nKm,"@E 999,999,999") // KM
	EndIf
	cSolic2 := ( STR0057+": "+aSolVAK[nP,8]+"    "+STR0040+": "+aSolVAK[nP,13] )
	cLogNiv := Alltrim(aSolVAK[nP,18]+"             "+aSolVAK[nP,19]+"             "+aSolVAK[nP,20])
EndIf
oSolic1:Refresh()
oSolic2:Refresh()
oLogNiv:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DELVERBA³ Autor ³ Andre Luis Almeida   ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Deleta Verbas Solicitadas VAK (Pecas/Servicos) == 0.   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DELVERBA(cTp,ni)
Local cQAlVAK := "SQLVAK"
Local cQuery  := ""
Local lRet    := .f.
Local cConf   := ""
Local lConf   := .f.
Local nPos    := 0
Local nReg    := ni
If cTp == "1"
	nReg := aSolVAK[ni,6]
	If nReg > 0
		lRet := .t.
		If aSolVAK[ni,16] $ "1/2"
			cConf := "3"
		ElseIf aSolVAK[ni,15] $ "1/2"
			cConf := "2"
		ElseIf aSolVAK[ni,14] $ "1/2"
			cConf := "1"
		EndIf
		If !Empty(cConf)
			nPos :=  Ascan(aDepart,{|x| x[1] == aSolVAK[ni,17] })
			If nPos > 0
				If aDepart[nPos,5] >= cConf
					DbSelectArea("VS1")
					DbSetOrder(1)
					DbSeek(xFilial("VS1")+aSolVAK[ni,2])
					If !(VS1->VS1_STATUS $ "0/P") // Diferente de Aberto ou Pendente Liberacao de Verba
						MsgStop(STR0076,STR0077)
						Return(.f.)
					EndIf
					If MsgYesNo(Alltrim(cNomUsu)+" - "+STR0064,STR0025)
						DbSelectArea("VS1")
						RecLock("VS1",.f.)
						VS1->VS1_STATUS := "0"
						MsUnLock()
						If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
							OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , "" ) // Grava Data/Hora na Mudança de Status do Orçamento
						EndIf
						DbSelectArea("VV1")
						DbSetOrder(2)
						DbSeek( xFilial("VV1") + aSolVAK[ni,7] )
						cQuery := "SELECT VAK.R_E_C_N_O_ AS RECVAK FROM "+RetSqlName("VAK")+" VAK WHERE VAK.VAK_FILIAL='"+xFilial("VAK")+"' AND "
						cQuery += "VAK.VAK_CODCLI='"+substr(aSolVAK[ni,13],1,6)+"' AND VAK.VAK_LOJCLI='"+substr(aSolVAK[ni,13],8,2)+"' AND "
						cQuery += "VAK.VAK_CHAINT='"+VV1->VV1_CHAINT+"' AND VAK.VAK_DEPSOL='"+aSolVAK[ni,17]+"' AND VAK.VAK_NUMORC='"+aSolVAK[ni,2]+"' AND VAK.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAK, .F., .T. )
						Do While !( cQAlVAK )->( Eof() )
							DbSelectArea("VAK")
							DbGoTo(( cQAlVAK )->( RECVAK ))
							RecLock("VAK",.f.,.t.)
							DbDelete()
							MsUnLock()
							WriteSX2("VAK")
							( cQAlVAK )->( DbSkip() )
						EndDo
						( cQAlVAK )->( dbCloseArea() )
						DbSelectArea("VAK")
					EndIf
				EndIf
			EndIf
		Else
			DbSelectArea("VAK")
			DbGoto(nReg)
			DbSelectArea("VS1")
			DbSetOrder(1)
			DbSeek(xFilial("VS1")+VAK->VAK_NUMORC)
			If !(VS1->VS1_STATUS $ "0/P") // Diferente de Pendente Liberacao
				MsgStop(STR0076,STR0077)
				Return(.f.)
			EndIf
			If MsgYesNo(Alltrim(cNomUsu)+" - "+STR0064,STR0025)
				DbSelectArea("VS1")
				RecLock("VS1",.f.)
				VS1->VS1_STATUS := "0"
				MsUnLock()
				If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
					OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , "" ) // Grava Data/Hora na Mudança de Status do Orçamento
				EndIf
				DbSelectArea("VAK")
				RecLock("VAK",.f.,.t.)
				DbDelete()
				MsUnLock()
				WriteSX2("VAK")
			EndIf
		EndIf
	EndIf
Else
	If nReg > 0
		DbSelectArea("VAK")
		DbGoto(nReg)
		RecLock("VAK",.f.,.t.)
		DbDelete()
		MsUnLock()
		WriteSX2("VAK")
	EndIf
EndIf
If ExistBlock("OA330DEL")
	ExecBlock("OA330DEL",.f.,.f.,{ cTp , nReg , ni })
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VVERBA³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verbas Solicitadas VAK (Pecas/Servicos) == 0.   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VVERBA(ni)
Local cQAlVAK := "SQLVAK"
Local cQuery  := ""
Local aVVerba := {}
Local cNUMOSV := ""
If aSolVAK[ni,14]=="2" .or. aSolVAK[ni,15]=="2" .or. aSolVAK[ni,16]=="2"
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek( xFilial("VV1") + aSolVAK[ni,7] )
	cQuery := "SELECT VAK.R_E_C_N_O_ AS RECVAK , VAK.* FROM "+RetSqlName("VAK")+" VAK WHERE VAK.VAK_FILIAL='"+xFilial("VAK")+"' AND "
	cQuery += "VAK.VAK_CODCLI='"+substr(aSolVAK[ni,13],1,6)+"' AND VAK.VAK_LOJCLI='"+substr(aSolVAK[ni,13],8,2)+"' AND "
	cQuery += "VAK.VAK_CHAINT='"+VV1->VV1_CHAINT+"' AND VAK.VAK_DEPSOL='"+aSolVAK[ni,17]+"' AND VAK.VAK_NUMORC='"+aSolVAK[ni,2]+"' AND "
	cQuery += "( VAK.VAK_CORNV1='2' OR VAK.VAK_CORNV2='2' OR VAK.VAK_CORNV3='2' ) AND VAK.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAK, .F., .T. )
	ProcRegua( RecCount() )
	Do While !( cQAlVAK )->( Eof() )
		IncProc( STR0054 + " - " + Alltrim(STR0043)+": "+( cQAlVAK )->( VAK_NUMORC ) )
		cNUMOSV := FM_SQL("SELECT VS1.VS1_NUMOSV FROM "+RetSQLName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMORC='"+( cQAlVAK )->( VAK_NUMORC )+"' AND VS1.D_E_L_E_T_=' '")
		aadd(aVVerba,{stod(( cQAlVAK )->( VAK_DATLIB )),( cQAlVAK )->( VAK_SOLLOG ),( cQAlVAK )->( VAK_SOLPEC ),( cQAlVAK )->( VAK_SOLSER ),( cQAlVAK )->( VAK_LOGLIB ),( cQAlVAK )->( VAK_VERPEC ),( cQAlVAK )->( VAK_VERSER ),( cQAlVAK )->( RECVAK ),( cQAlVAK )->( VAK_NUMORC ),cNUMOSV})
		( cQAlVAK )->( DbSkip() )
	EndDo
	( cQAlVAK )->( dbCloseArea() )
	DbSelectArea("VAK")
	If len(aVVerba) == 0
		aadd(aVVerba,{ctod(""),"",0,0,"",0,0,1,"",""})
	EndIf
	aSort(aVVerba,1,,{|x,y| x[8] < y[8] })
	DEFINE MSDIALOG oVVerba FROM 000,000 TO 029,080 TITLE (STR0016+STR0043+" "+aSolVAK[ni,2]+" - "+aSolVAK[ni,17]) OF oMainWnd
	@ 003,003 SAY aSolVAK[ni,13] SIZE 400,08 OF oVVerba PIXEL COLOR CLR_BLUE
	@ 002,137 BUTTON oVOrc PROMPT OemToAnsi(STR0075) OF oVVerba SIZE 55,10 PIXEL ACTION FS_VERORC(aVVerba[oVVerbaLx:nAt,9])
	@ 002,265 BUTTON oSair PROMPT OemToAnsi(STR0021) OF oVVerba SIZE 48,10 PIXEL ACTION (oVVerba:End())
	@ 013,003 LISTBOX oVVerbaLx FIELDS HEADER "1","2","3",STR0055,STR0056,STR0044,STR0045,STR0016,STR0044,STR0045,STR0079,STR0080 COLSIZES 10,10,10,27,47,27,27,47,27,27,38,38 SIZE 311,203 OF oVVerba PIXEL
	oVVerbaLx:SetArray(aVVerba)
	oVVerbaLx:bLine := { || {IIf(left(aVVerba[oVVerbaLx:nAt,5],1)=="1",overde,opreto),;
	IIf(left(aVVerba[oVVerbaLx:nAt,5],1)=="2",overde,opreto),;
	IIf(left(aVVerba[oVVerbaLx:nAt,5],1)=="3",overde,opreto),;
	Transform(aVVerba[oVVerbaLx:nAt,1],"@D"),;
	aVVerba[oVVerbaLx:nAt,2],;
	Transform(aVVerba[oVVerbaLx:nAt,3],"@E 99999,999.99"),;
	Transform(aVVerba[oVVerbaLx:nAt,4],"@E 99999,999.99"),;
	aVVerba[oVVerbaLx:nAt,5],;
	Transform(aVVerba[oVVerbaLx:nAt,6],"@E 99999,999.99"),;
	Transform(aVVerba[oVVerbaLx:nAt,7],"@E 99999,999.99"),;
	aVVerba[oVVerbaLx:nAt,9],;
	aVVerba[oVVerbaLx:nAt,10]}}
	
	ACTIVATE MSDIALOG oVVerba CENTER
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VERORC³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verbas Solicitadas.							   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERORC(cNumOrc)
If !Empty(cNumOrc)
	DbSelectArea("VS1")
	DbSetOrder(1)
	If DbSeek(xFilial("VS1")+cNumOrc)
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FG_CHKVERBA³ Autor ³ Andre Luis Almeida   ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica Verbas.								   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_CHKVERBA(clienteloja, chaint, cDepto)
Local aCodSer := {}
Local aAreaVO1:= {}
Local aAreaVO2:= {}
Local aAreaVO3:= {}
Local aAreaVO4:= {}
Local aAreaVEC:= {}
Local aRetorno:= {}
Local aVerVEC := {}
Local nVerbaP := 0
Local nVerbaS := 0
Local nTotRqP := 0
Local nTotRqS := 0
Local nMesVer := str(Year(dDatabase))+"/"+str(Month(dDatabase))
Local nMesOld := str(Year(dDatabase))+"/"+str(Month(dDatabase)-1)
if Month(dDatabase) = 1
	nMesOld := str(Year(dDatabase)-1)+"/12"
Endif

dbSelectArea("VO1")
aAreaVO1 := sGetArea(aAreaVO1 , Alias())
dbSetOrder(4)

dbSelectArea("VO2")
aAreaVO2 := sGetArea(aAreaVO2 , Alias())
dbSetOrder(1)

dbSelectArea("VO3")
aAreaVO3 := sGetArea(aAreaVO3 , Alias())
dbSetOrder(1)

dbSelectArea("VO4")
aAreaVO4 := sGetArea(aAreaVO4 , Alias())
dbSetOrder(1)

dbSelectArea("VEC")
aAreaVEC := sGetArea(aAreaVEC , Alias())
dbSetOrder(5)

dbSelectArea("VOI")
dbSetOrder(1)

dbSelectArea("VV1")
dbSetOrder(1)
if dbSeek(xFilial("VV1")+chaint)
	
	dbSelectArea("VAK")
	dbSetOrder(1)
	if dbSeek(xFilial("VAK")+clienteloja+chaint)
		while !Eof() .and. xFilial("VAK") == VAK_FILIAL .and. clienteloja == VAK_CODCLI+VAK_LOJCLI .and. VV1->VV1_CHAINT == VAK_CHAINT
			if dDataBase <= VAK_DATVAL
				if !Empty(cDepto)
					if VAK_DEPSOL == cDepto
						nVerbaP += VAK_VERPEC
						nVerbaS += VAK_VERSER
					Endif
				Else
					nVerbaP += VAK_VERPEC
					nVerbaS += VAK_VERSER
				Endif
			Endif
			dbSkip()
		Enddo
	Endif
	
	//Checa as pecas e servicos requisitados
	
	dbSelectArea("VO1")
	dbSeek(xFilial("VO1")+VV1->VV1_CHAINT)
	
	if Found() //.and. (nVerbaP+nVerbaS > 0)
		while !Eof() .and. VO1_CHAINT = chaint .and. iif(Empty(cDepto),.t.,VO1_DEPTV == cDepto)
			aVerVEC := {}
			dbSelectArea("VO2")
			dbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)
			while !Eof() .and. VO2_NUMOSV = VO1->VO1_NUMOSV
				if (str(Year(VO2_DATREQ))+"/"+str(Month(VO2_DATREQ)) == nMesVer) .or. (str(Year(VO2_DATREQ))+"/"+str(Month(VO2_DATREQ)) == nMesOld)
					if iIf(Empty(cDepto),.t.,VO1_DEPTV == cDepto)
						if VO2->VO2_TIPREQ = "P"
							dbSelectArea("VO3")
							dbSeek(xFilial("VO3")+VO2->VO2_NOSNUM)
							while !Eof() .and. VO3_FILIAL == xFilial("VO3") .and. VO3_NOSNUM == VO2->VO2_NOSNUM .and. VO3_FATPAR+VO3_LOJA == clienteloja
								dbSelectArea("VOI")
								if dbSeek(xFilial("VOI")+VO3->VO3_TIPTEM) .and. Empty(VO3->VO3_DATCAN)
									DbSelectArea("VEC")
									If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
										If VO2->VO2_DEVOLU == "1"
											If Ascan(aVerVEC,{|x| x[1]+x[2] == VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE }) == 0
												aadd(aVerVEC,{ VO1->VO1_NUMOSV + VO3->VO3_TIPTEM , VO3->VO3_GRUITE + VO3->VO3_CODITE })
												nTotRqP += VEC->VEC_VALVDA
											EndIf
										EndIf
									Else
										If Empty(VO3->VO3_DATFEC)
											if VO2->VO2_DEVOLU = "1"
												If VOI->VOI_VLPCAC == "1"
													nTotRqP += (VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
												Else
													nTotRqP += (FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)*VO3->VO3_QTDREQ)
												EndIf
											else
												If VOI->VOI_VLPCAC == "1"
													nTotRqP -= (VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
												Else
													nTotRqP -= (FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)*VO3->VO3_QTDREQ)
												EndIf
											Endif
										EndIf
									EndIf
								Endif
								dbSelectArea("VO3")
								dbSkip()
							Enddo
						Else
							dbSelectArea("VO4")
							dbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
							while !Eof() .and. VO4_FILIAL = xFilial("VO4") .and. VO4_NOSNUM = VO2->VO2_NOSNUM .and. VO4_FATPAR+VO4_LOJA == clienteloja
								dbSelectArea("VOI")
								if dbSeek(xFilial("VOI")+VO4->VO4_TIPTEM) .and. Empty(VO4->VO4_DATCAN)
									if VOI->VOI_SITTPO = "3"
										//thiago
										if !Empty(VO4->VO4_DATFEC) .or. !Empty(VO4->VO4_DATCAN)
											nTotRqS += VO4->VO4_VALINT
										Else
											if VOK->VOK_INCTEM == "3"
												aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER+"T" )
												If aCodSer[6]  && se nao foi somado soma
													nTotRqS := (VO4->VO4_TEMTRA / 100) * VO4->VO4_VALHOR && Valor Srv Interno    // Trabalhado
												Endif
											Else
												aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER+"T" )
												If aCodSer[6]  && se nao foi somado soma
													nTotRqS += (VO4->VO4_TEMPAD / 100) * VO4->VO4_VALHOR && Valor Srv Interno    // Fabrica + Conc + Informado
												Endif
											Endif
										Endif
									Else
										nTotRqS += FG_CALVLSER( aCodSer , VO2->VO2_NUMOSV + VO4->VO4_NOSNUM + VO4->VO4_CODSER , "F" )[1]
									Endif
								Else
									if VOI->VOI_SITTPO = "3"
										nTotRqS +=  FG_VALHOR(VO4->VO4_TIPTEM,dDataBase)
									Else
										nTotRqS += FG_CALVLSER( aCodSer , VO2->VO2_NUMOSV + VO4->VO4_NOSNUM + VO4->VO4_CODSER )[1]
									Endif
								Endif
								dbSelectArea("VO4")
								dbSkip()
							Enddo
						Endif
					Endif
				Endif
				dbSelectArea("VO2")
				dbSkip()
			Enddo
			dbSelectArea("VO1")
			dbskip()
		Enddo
	Endif
Endif

//aadd(aRetorno,(nVerbaP-nTotRqP))
aadd(aRetorno,(nVerbaP))
aadd(aRetorno,(nVerbaS-nTotRqS))

sRestArea(aAreaVO1)
sRestArea(aAreaVO2)
sRestArea(aAreaVO3)
sRestArea(aAreaVO4)
sRestArea(aAreaVEC)

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFIOA330_CAD³ Autor ³ Andre Luis Almeida  ³ Data ³ 20/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Solicitacao de Verba para a OS.		   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA330_CAD(cCliPec,cLojPec,nPec,cCliSrv,cLojSrv,nSrv,cCha,cNORC,cDEP)
Local lRet := .f.
Local aSol := {}
Local cSol := ""
Local cNiv := "0"
Local nPos := 0
Local lVAI_NIVVER := ( VAI->(FieldPos("VAI_NIVVER")) > 0 )
Local cNomPec := ""
Local cNomSrv := ""
Default nPec := 0
Default nSrv := 0
DbSelectArea("VAK")
DbSetOrder(2)
DbSeek( xFilial("VAK") + "0" )
While !Eof() .and. xFilial("VAK") == VAK->VAK_FILIAL .and. VAK->VAK_SOLLIB == "0"
	If VAK->VAK_NUMORC == cNORC
		aadd(aSol,{VAK->VAK_DATLIB,VAK->VAK_DEPSOL+" "+left(VAK->VAK_SOLLOG,15),VAK->VAK_SOLPEC,VAK->VAK_SOLSER})
		cSol := STR0068
	EndIf
	DbSelectArea("VAK")
	DbSkip()
EndDo
If len(aSol) == 0
	aadd(aSol,{ctod("  /  /  ")," ",0,0})
EndIf
aSort(aSol,1,,{|x,y| dtos(x[1])+x[2] > dtos(y[1])+y[2] })
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek( xFilial("VAI") + __CUSERID )
If lVAI_NIVVER .and. !Empty(VAI->VAI_NIVVER)
	nPos := At(cDEP,VAI->VAI_NIVVER)
	If nPos > 0
		nPos--
		cNiv := substr(VAI->VAI_NIVVER,nPos,1)
	EndIf
EndIf
If !Empty( cCliPec + cLojPec )
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + cCliPec + cLojPec )
	cNomPec := STR0002+" "+cCliPec+"-"+cLojPec+" "+Alltrim(SA1->A1_NOME)
EndIf
If !Empty( cCliSrv + cLojSrv )
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + cCliSrv + cLojSrv )
	cNomSrv := STR0002+" "+cCliSrv+"-"+cLojSrv+" "+Alltrim(SA1->A1_NOME)
EndIf
DbSelectArea("VV1")
DbSetOrder(1)
DbSeek( xFilial("VV1") + cCha )
DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
DbSelectArea("VVC")
DbSetOrder(1)
DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
DEFINE MSDIALOG oCadSol FROM 000,000 TO 025,060 TITLE (Alltrim(VAI->VAI_NOMUSU)+" - "+STR0065+" "+cNORC) OF oMainWnd

@ 002,004 TO 032,233 LABEL (" "+Alltrim(STR0066)+" ") OF oCadSol PIXEL // Caixa - Veiculo
@ 008,007 SAY (cCha+" - "+Alltrim(VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD)) SIZE 350,08 OF oCadSol PIXEL COLOR CLR_BLUE
@ 016,007 SAY (STR0035+Transform(VV1->VV1_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI")))+STR0037+Transform(VV1->VV1_FABMOD,"@R 9999/9999")) SIZE 350,08 OF oCadSol PIXEL COLOR CLR_BLUE
@ 024,007 SAY (Alltrim(STR0038+VVC->VVC_DESCRI)+STR0039+VV1->VV1_CHASSI) SIZE 350,08 OF oCadSol PIXEL COLOR CLR_BLUE

@ 033,004 TO 052,233 LABEL (" "+Alltrim(STR0044)+" ") OF oCadSol PIXEL // Caixa - Pecas
@ 041,007 SAY cNomPec SIZE 350,08 OF oCadSol PIXEL COLOR CLR_BLUE
@ 039,163 MSGET oPec VAR nPec PICTURE "@E 99,999,999,999.99" VALID (nPec >= 0) SIZE 65,08 OF oCadSol PIXEL COLOR CLR_HBLUE when .f.

@ 053,004 TO 072,233 LABEL (" "+Alltrim(STR0045)+" ") OF oCadSol PIXEL // Caixa - Servicos
@ 061,007 SAY cNomSrv SIZE 350,08 OF oCadSol PIXEL COLOR CLR_BLUE
@ 059,163 MSGET oSrv VAR nSrv PICTURE "@E 99,999,999,999.99" VALID (nSrv >= 0) SIZE 65,08 OF oCadSol PIXEL COLOR CLR_HBLUE when .f.

DEFINE SBUTTON FROM 076,165 TYPE 1 ACTION (lRet:=.t.,oCadSol:End()) ENABLE OF oCadSol WHEN ( ( nPec + nSrv ) > 0 )
DEFINE SBUTTON FROM 076,200 TYPE 2 ACTION (oCadSol:End()) ENABLE OF oCadSol
@ 074,004 SAY cSol SIZE 300,08 OF oCadSol PIXEL COLOR CLR_HRED
@ 082,004 SAY STR0072 SIZE 250,08 OF oCadSol PIXEL COLOR CLR_BLUE // Solicitacoes em Aberto
@ 090,004 LISTBOX oSolLx FIELDS HEADER STR0055,STR0056,STR0044,STR0045 COLSIZES 40,70,50,50 SIZE 230,95 OF oCadSol PIXEL
oSolLx:SetArray(aSol)
oSolLx:bLine := { || {Transform(aSol[oSolLx:nAt,1],"@D"),;
aSol[oSolLx:nAt,2],;
Transform(aSol[oSolLx:nAt,3],"@E 9999,999,999,999.99"),;
Transform(aSol[oSolLx:nAt,4],"@E 9999,999,999,999.99")}}
ACTIVATE MSDIALOG oCadSol CENTER
If lRet
	If ( ( nPec + nSrv ) > 0 )
		DbSelectArea("VAK")
		If (cCliPec + cLojPec) == (cCliSrv + cLojSrv)
			RecLock("VAK",.t.)
			VAK->VAK_FILIAL := xFilial("VAK")
			VAK->VAK_CODCLI := cCliPec
			VAK->VAK_LOJCLI := cLojPec
			VAK->VAK_CHAINT := cCha
			VAK->VAK_DATLIB := dDataBase
			VAK->VAK_NUMORC := cNORC
			VAK->VAK_DEPSOL := cDEP
			VAK->VAK_SOLPEC := nPec
			VAK->VAK_SOLSER := nSrv
			VAK->VAK_SOLLOG := cNiv+" "+left(VAI->VAI_NOMUSU,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
			VAK->VAK_SOLLIB := "0" // Verba Solicitada
			VAK->VAK_CORNV1 := "0" // Preto
			VAK->VAK_CORNV2 := "0" // Preto
			VAK->VAK_CORNV3 := "0" // Preto
			VAK->VAK_LOGNV1 := ""
			VAK->VAK_LOGNV2 := ""
			VAK->VAK_LOGNV3 := ""
			MsUnLock()
		Else
			If nPec > 0
				RecLock("VAK",.t.)
				VAK->VAK_FILIAL := xFilial("VAK")
				VAK->VAK_CODCLI := cCliPec
				VAK->VAK_LOJCLI := cLojPec
				VAK->VAK_CHAINT := cCha
				VAK->VAK_DATLIB := dDataBase
				VAK->VAK_NUMORC := cNORC
				VAK->VAK_DEPSOL := cDEP
				VAK->VAK_SOLPEC := nPec
				VAK->VAK_SOLSER := 0
				VAK->VAK_SOLLOG := cNiv+" "+left(VAI->VAI_NOMUSU,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
				VAK->VAK_SOLLIB := "0" // Verba Solicitada
				VAK->VAK_CORNV1 := "0" // Preto
				VAK->VAK_CORNV2 := "0" // Preto
				VAK->VAK_CORNV3 := "0" // Preto
				VAK->VAK_LOGNV1 := ""
				VAK->VAK_LOGNV2 := ""
				VAK->VAK_LOGNV3 := ""
				MsUnLock()
			EndIf
			If nSrv > 0
				RecLock("VAK",.t.)
				VAK->VAK_FILIAL := xFilial("VAK")
				VAK->VAK_CODCLI := cCliSrv
				VAK->VAK_LOJCLI := cLojSrv
				VAK->VAK_CHAINT := cCha
				VAK->VAK_DATLIB := dDataBase
				VAK->VAK_NUMORC := cNORC
				VAK->VAK_DEPSOL := cDEP
				VAK->VAK_SOLPEC := 0
				VAK->VAK_SOLSER := nSrv
				VAK->VAK_SOLLOG := cNiv+" "+left(VAI->VAI_NOMUSU,13)+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)
				VAK->VAK_SOLLIB := "0" // Verba Solicitada
				VAK->VAK_CORNV1 := "0" // Preto
				VAK->VAK_CORNV2 := "0" // Preto
				VAK->VAK_CORNV3 := "0" // Preto
				VAK->VAK_LOGNV1 := ""
				VAK->VAK_LOGNV2 := ""
				VAK->VAK_LOGNV3 := ""
				MsUnLock()
			EndIf
		EndIf
		MsgInfo(Alltrim(VAI->VAI_NOMUSU)+" - "+STR0067,STR0025)
		DbSelectArea("VS1")
		DbSetOrder(1)
		If DbSeek(xFilial("VS1")+cNORC)
			RecLock("VS1",.f.)
			VS1->VS1_STATUS := "P" // Pendente para Exportacao do Orcamento para a OS
			MsUnLock()
			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0082 ) // Grava Data/Hora na Mudança de Status do Orçamento / Pendente para Exportacao do Orcamento para a OS
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_HABILITA ³ Autor ³ Thiago              ³ Data ³ 15/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita botao.								   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_HABILITA(cNumOsv)

if Empty(cNumOsv)
	oExcl:Enable()
Else
	oExcl:Disable()
Endif	

oExcl:Refresh()

Return(.t.)
