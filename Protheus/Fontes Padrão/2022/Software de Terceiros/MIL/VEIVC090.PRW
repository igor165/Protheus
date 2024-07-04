// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 7      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "VEIVC090.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC090 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 13/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Veiculos do Cliente (VV1/VVA)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC090(cPCodCli,cPLojCli,lMsgCli)
#IFDEF TOP
//
Local aObjects := {} , aPosObj := {} , aInfo := {} //aPosObjApon := {} ,
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
//
Private aVV1Cli  := {} 	// VV1 Veiculos do Cliente
Private nVV1     := 0  	// Qtde VV1
Private aVVACli  := {} 	// VVA Veiculos do Cliente
Private nVVA     := 0  	// Qtde VVA
Private cVeiCCli := ""
Private cVeiLCli := ""
Default cPCodCli := ""
Default cPLojCli := ""
Default lMsgCli  := .f.
//
aObjects := {}
AAdd( aObjects, { 05, 14, .T. , .F. } )   		//Label Superior
AAdd( aObjects, { 05, 20, .T. , .T. } )   		//Label Superior
AAdd( aObjects, { 05, 20, .T. , .T. } )   		//Label Superior

// Fator de reducao de 0.8
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
next
	
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

If !Empty(cPCodCli)
	cVeiCCli := cPCodCli
	cVeiLCli := cPLojCli
Else
	If lMsgCli
		MsgStop(STR0011,STR0010) // Favor informar o Codido e Loja do Cliente! , Atencao
		Return()
	EndIf
	If !Pergunte("VVC090")
		Return()
	EndIf
	cVeiCCli := MV_PAR01
	cVeiLCli := MV_PAR02
EndIf
FS_VEIVC090()
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + cVeiCCli + cVeiLCli )

DEFINE MSDIALOG oVeiCli FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE (STR0003+": "+cVeiCCli+"-"+cVeiLCli+" "+left(SA1->A1_NOME,40)) OF oMainWnd PIXEL  // Cliente
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-55 LABEL "" OF oVeiCli PIXEL
	
@ aPosObj[1,1]+004,aPosObj[1,2]+006 SAY left(cVeiCCli+"-"+cVeiLCli+" "+SA1->A1_NOME,50) SIZE 300,08 OF oVeiCli PIXEL COLOR CLR_BLUE
	
@ aPosObj[2,1],aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL (" "+STR0001+":   "+Alltrim(Transform(nVV1,"@E 999,999,999"))+" "+STR0002+" ") OF oVeiCli PIXEL // Veiculo(s) do Cliente / veiculo(s)
@ aPosObj[2,1]+009,aPosObj[2,2]+003 LISTBOX oLbVV1Cli FIELDS HEADER OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008) COLSIZES 20,80,35,45,60 SIZE aPosObj[2,4]-aPosObj[2,2]-6,aPosObj[2,3]-aPosObj[2,1]-11 OF oVeiCli PIXEL // Marca / Modelo / Fab/Mod / Cor / Chassi
oLbVV1Cli:SetArray(aVV1Cli)
oLbVV1Cli:bLine := { || {	aVV1Cli[oLbVV1Cli:nAt,1] ,;
							aVV1Cli[oLbVV1Cli:nAt,2] ,;
							aVV1Cli[oLbVV1Cli:nAt,3] ,;
							aVV1Cli[oLbVV1Cli:nAt,4] ,;
							aVV1Cli[oLbVV1Cli:nAt,5] }}

@ aPosObj[3,1],aPosObj[3,2] TO aPosObj[3,3],aPosObj[3,4] LABEL (" "+STR0012+":   "+Alltrim(Transform(nVVA,"@E 999,999,999"))+" "+STR0002+" ") OF oVeiCli PIXEL // Veiculo(s) vendido(s) para o Cliente / veiculo(s)
@ aPosObj[3,1]+009,aPosObj[3,2]+003 LISTBOX oLbVVACli FIELDS HEADER OemToAnsi(STR0013),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008) COLSIZES 60,20,80,35,45,60 SIZE aPosObj[3,4]-aPosObj[3,2]-6,aPosObj[3,3]-aPosObj[3,1]-11 OF oVeiCli PIXEL // Filial / Marca / Modelo / Fab/Mod / Cor / Chassi
oLbVVACli:SetArray(aVVACli)
oLbVVACli:bLine := { || {	aVVACli[oLbVVACli:nAt,6] ,;
							aVVACli[oLbVVACli:nAt,1] ,;
							aVVACli[oLbVVACli:nAt,2] ,;
							aVVACli[oLbVVACli:nAt,3] ,;
							aVVACli[oLbVVACli:nAt,4] ,;
							aVVACli[oLbVVACli:nAt,5] }}
@ aPosObj[1,1]+003,aPosObj[1,4]-50 BUTTON oVeiCliSair PROMPT STR0009 OF oVeiCli SIZE 46,10 PIXEL ACTION oVeiCli:End() // <<<  S A I R  >>>
ACTIVATE MSDIALOG oVeiCli CENTER
#ENDIF
Return()

#IFDEF TOP
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VEIVC090³ Autor ³ Andre Luis Almeida   ³ Data ³ 13/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento dos Veiculos do Cliente                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEIVC090()
Local cQuery  := ""
Local cQAlVV1 := "SQLVV1" // VV1
Local cQAlVVA := "SQLVVA" // VVA
//
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
//
If !Empty(Alltrim(cVeiCCli+cVeiLCli))             

	if TYPE("aSelFil") == "U" 
		aSelFil := aClone(aSM0)
	Endif 


	For nCont := 1 to Len(aSelFil)

		cFilAnt := aSelFil[nCont]

		cQuery := "SELECT DISTINCT VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_FABMOD , VVC.VVC_DESCRI FROM "
		cQuery += RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 , "+RetSqlName("VVC")+" VVC WHERE "
		cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_PROATU='"+cVeiCCli+"' AND VV1.VV1_LJPATU='"+cVeiLCli+"' AND VV1.D_E_L_E_T_=' ' AND "
		cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' AND "
		cQuery += "VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )
		Do While !( cQAlVV1 )->( Eof() )
			If aScan(aVV1Cli,{|x| x[5] == ( cQAlVV1 )->( VV1_CHASSI ) }) <= 0 // Verifica se ja existe o Veiculo no vetor
				Aadd(aVV1Cli,{ ( cQAlVV1 )->( VV1_CODMAR ) , ( cQAlVV1 )->( VV2_DESMOD ) , Transform(( cQAlVV1 )->( VV1_FABMOD ),"@R 9999/9999") , left(( cQAlVV1 )->( VVC_DESCRI ),15) , ( cQAlVV1 )->( VV1_CHASSI ) })
			EndIf
			( cQAlVV1 )->( DbSkip() )
		EndDo
		( cQAlVV1 )->( dbCloseArea() )
		cQuery := "SELECT DISTINCT VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_FABMOD , VVC.VVC_DESCRI , VV0.VV0_FILIAL FROM "
		cQuery += RetSqlName("VV9")+" VV9 , "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA , "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 , "+RetSqlName("VVC")+" VVC WHERE "
		cQuery += "VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_CODCLI='"+cVeiCCli+"' AND VV9.VV9_LOJA='"+cVeiLCli+"' AND "
		cQuery += "VV9.VV9_STATUS IN ('F','T') AND " // Atendimentos Finalizados
		cQuery += "VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.VV0_OPEMOV='0' AND VV0.D_E_L_E_T_=' ' AND "
		cQuery += "VV0.VV0_SITNFI='1' AND " // Nota Fiscal Valida
		cQuery += "VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' AND "
		cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI=VVA.VVA_CHASSI AND VV1.D_E_L_E_T_=' ' AND "
		cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' AND "
		cQuery += "VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVA, .F., .T. )
		Do While !( cQAlVVA )->( Eof() )
			Aadd(aVVACli,{ ( cQAlVVA )->( VV1_CODMAR ) , ( cQAlVVA )->( VV2_DESMOD ) , Transform(( cQAlVVA )->( VV1_FABMOD ),"@R 9999/9999") , left(( cQAlVVA )->( VVC_DESCRI ),15) , ( cQAlVVA )->( VV1_CHASSI ) , cFilAnt })
			( cQAlVVA )->( DbSkip() )
		EndDo
		( cQAlVVA )->( dbCloseArea() )
	
	Next

	cFilAnt := cBkpFilAnt

EndIf
If len(aVV1Cli) > 0
	aSort(aVV1Cli,1,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
	nVV1 := len(aVV1Cli)
Else
	Aadd(aVV1Cli,{ "" , "" , "" , "" , "" })
EndIf
If len(aVVACli) > 0
	aSort(aVVACli,1,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
	nVVA := len(aVVACli)
Else
	Aadd(aVVACli,{ "" , "" , "" , "" , "" , "" })
EndIf
Return()
#ENDIF