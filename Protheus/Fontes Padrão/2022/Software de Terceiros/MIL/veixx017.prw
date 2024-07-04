// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 09     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX017.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXX017 ³ Autor ³ Rafael Goncalves      ³ Data ³ 09/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Custo com venda de Veiculo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX017(cAtend,nOpc,lTela,nValTot,cChaInt,cIteTra)
//variaveis controle de janela 
Local aObjects  := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam   := 0
Local aCusVei   := {}
Local nOpcao    := 1
Local ni        := 0
Local lAltGrv   := .t.
Local nCusVda   := 0 // valor total default do Custo FIXO 
Local nRecVRC   := 0
Local cQuery    := ""
Local lVRC_CHAINT := ( VRC->(FieldPos("VRC_CHAINT")) > 0 )
Local lPosVVA   := .f.
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Default lTela   := .t.
Default nValTot := 0
Default cChaInt := ""
Default cIteTra := ""

cAtend := PadR(cAtend, GetSX3Cache("VRC_NUMATE","X3_TAMANHO"))

If !Empty(cChaInt)
	VV1->(DbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1")+cChaInt))

	If !Empty(cIteTra) .and. VVA->(FieldPos("VVA_ITETRA")) > 0

		dbSelectArea("VVA")
		dbSetOrder(4)
		If dbSeek(xFilial("VVA")+cAtend+cIteTra)
			lPosVVA := .t.
		EndIf
		
	Else
	
		dbSelectArea("VVA")
		dbSetOrder(1)
		If dbSeek(xFilial("VVA")+cAtend+VV1->VV1_CHASSI)
			lPosVVA := .t.
		EndIf

	EndIf

	If lTela
		If nValTot == 0
			nValTot := VVA->VVA_VALVDA
		EndIf
	EndIf
	nCusVda := VVA->VVA_CUSVDA // Custo FIXO 
	
	//////////////////////////////////
	//   CUSTO  FIXO  DO  VEICULO   //
	//////////////////////////////////
	FGX_CFXVEI(VVA->VVA_CHAINT,,,,,,,,dDataBase,nValTot,@aCusVei)
	//////////////////////////////////
	For ni:=1 to Len(aCusVei)
		If aCusVei[ni,1] //SE TIVER SELECIONADO 
			cQuery := "SELECT VRC.R_E_C_N_O_ AS RECVRC FROM "+RetSqlName("VRC")+" VRC WHERE "
			cQuery += "VRC.VRC_FILIAL='"+xFilial("VRC")+"' AND VRC.VRC_CODCUS='"+aCusVei[ni,2]+"' AND VRC.VRC_NUMATE='"+cAtend+"' AND "
			If lVRC_CHAINT
				cQuery += "VRC.VRC_CHAINT='"+cChaInt+"' AND "
			EndIf
			cQuery += "VRC.D_E_L_E_T_ <> ' ' "
			nRecVRC := FM_SQL(cQuery)
			If nRecVRC > 0 // Existe registro EXCLUIDO no VRC
				aCusVei[ni,1] := .f. // TIRAR SELECAO 
			EndIf
		Else // SE NAO TIVER SELECIONADO
			cQuery := "SELECT VRC.R_E_C_N_O_ AS RECVRC FROM "+RetSqlName("VRC")+" VRC WHERE "
			cQuery += "VRC.VRC_FILIAL='"+xFilial("VRC")+"' AND VRC.VRC_CODCUS='"+aCusVei[ni,2]+"' AND VRC.VRC_NUMATE='"+cAtend+"' AND "
			If lVRC_CHAINT
				cQuery += "VRC.VRC_CHAINT='"+cChaInt+"' AND "
			EndIf
			cQuery += "VRC.D_E_L_E_T_ = ' ' "
			nRecVRC := FM_SQL(cQuery)
			If nRecVRC > 0 // Existe registro VALIDO no VRC
				aCusVei[ni,1] := .t. // SELECIONAR  
			EndIf
		EndIf
	Next
	
	If lTela
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 0, 0 , .T. , .T. } )  	//list box
		// Fator de reducao de 0.8
		For nCntTam := 1 to Len(aSizeAut)
			aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
		Next
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPos  := MsObjSize (aInfo, aObjects,.F.)
		DEFINE MSDIALOG oCusVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (STR0001+": "+Alltrim(VV1->VV1_CHASSI)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Custo com Venda de Veiculo
		oCusVeic:lEscClose := .F.
		@ aPos[1,1]+002,aPos[1,2]+002 LISTBOX oLstVei FIELDS HEADER " ",STR0002,STR0003,STR0004 COLSIZES ; // Custo / Valor Custo / % Custo
		10,150,50,50 SIZE aPos[1,4]-002,aPos[1,3]-aPos[1,1]-008 OF oCusVeic PIXEL ON DBLCLICK (Iif(!Empty(aCusVei[oLstVei:nAt,02]),FS_TIK(@aCusVei,oLstVei:Nat,nOpc),.t.))
		oLstVei:SetArray(aCusVei)
		oLstVei:bLine := { || { IIf(aCusVei[oLstVei:nAt,01],oOk,oNo) , aCusVei[oLstVei:nAt,02]+" -  "+aCusVei[oLstVei:nAt,05], FG_AlinVlrs(Transform(aCusVei[oLstVei:nAt,03],"@E 999,999,999.99")) , FG_AlinVlrs(Transform(aCusVei[oLstVei:nAt,04],"@EZ 999.99%")) }}
		ACTIVATE MSDIALOG oCusVeic ON INIT EnchoiceBar(oCusVeic,{|| nOpcao:=1,oCusVeic:End() , .f. },{|| nOpcao:=0,oCusVeic:End() } ) CENTER
	EndIf
	If nOpcao == 1
		If ( nOpc == 3 .Or. nOpc == 4 ) //Inclusao/alteracao
			nCusVda := 0
			DbSelectArea("VRC")
			//grava arquivo VRC
			For ni:=1 to Len(aCusVei)
				If aCusVei[ni,1] //SE TIVER SELECIONADO 
					cQuery := "SELECT VRC.R_E_C_N_O_ AS RECVRC FROM "+RetSqlName("VRC")+" VRC WHERE "
					cQuery += "VRC.VRC_FILIAL='"+xFilial("VRC")+"' AND VRC.VRC_CODCUS='"+aCusVei[ni,2]+"' AND VRC.VRC_NUMATE='"+cAtend+"' AND "
					If lVRC_CHAINT
						cQuery += "VRC.VRC_CHAINT='"+cChaInt+"' AND "
					EndIf
					cQuery += "VRC.D_E_L_E_T_ <> ' ' "
					nRecVRC := FM_SQL(cQuery)
					If nRecVRC > 0 // Existe registro no VRC
						SET DELETED OFF
						DbSelectArea("VRC")
						DbGoTo(nRecVRC)
						RecLock("VRC", .f. )
						VRC->(DBRecall())
						MsUnLock()
						SET DELETED ON
					EndIf
				EndIf
				cQuery := "SELECT VRC.R_E_C_N_O_ AS RECVRC FROM "+RetSqlName("VRC")+" VRC WHERE "
				cQuery += "VRC.VRC_FILIAL='"+xFilial("VRC")+"' AND VRC.VRC_CODCUS='"+aCusVei[ni,2]+"' AND VRC.VRC_NUMATE='"+cAtend+"' AND "
				If lVRC_CHAINT
					cQuery += "VRC.VRC_CHAINT='"+cChaInt+"' AND "
				EndIf
				cQuery += "VRC.D_E_L_E_T_ = ' ' "
				nRecVRC := FM_SQL(cQuery)
				If nRecVRC > 0 // Existe registro no VRC
					DbSelectArea("VRC")
					DbGoTo(nRecVRC)
					lAltGrv := .f.
				Else // Nao existe VRC
					DbSelectArea("VRC")
					lAltGrv := .t.
				EndIf
				If aCusVei[ni,1] //SE TIVER SELECIONADO 
					RecLock("VRC", lAltGrv )
					VRC->VRC_FILIAL := xFilial("VRC")
					VRC->VRC_CODCUS := aCusVei[ni,2]
					VRC->VRC_NUMATE := cAtend
					If lVRC_CHAINT .and. lPosVVA
						VRC->VRC_CHAINT := VVA->VVA_CHAINT
					EndIf
					VRC->VRC_VALCUS := aCusVei[ni,3]
					VRC->VRC_PERCUS := aCusVei[ni,4]
				    MsUnlock()
				    If aCusVei[ni,3] > 0
				    	nCusVda += aCusVei[ni,3] 
				    ElseIf aCusVei[ni,4] > 0
			    		nCusVda += aCusVei[ni,4]*(nValTot/100)
				    EndIf 
				ElseIf !lAltGrv
					RecLock("VRC",.F.,.T.)
					dbdelete()
					MsUnlock()
				EndIf
			Next
			If lPosVVA // Posicionamento no VVA
				DbSelectArea("VVA")
				RecLock("VVA",.f.)
					VVA->VVA_CUSVDA := nCusVda
				MsUnlock()
			EndIf
		EndIf
	EndIf
EndIf
M->VVA_CUSVDA := nCusVda // Custo FIXO
If FindFunction("VX002ACOLS") .and. FM_PILHA("VEIXX002")
	VX002ACOLS("VVA_CUSVDA")
EndIf
Return(nCusVda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_TIK  ³ Autor ³ Rafael Goncalves      ³ Data ³ 09/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK - Seleciona o Custo desejado                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(aCusVei,nLinha,nOpc)
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIF
If FGX_USERVL( xFilial("VAI"),__cUserID, "VAI_MANCUS", "==" ,"1") // Usuario: 0-Nao Manipula custo do veiculo / 1- Manipula custo do veiculo
	aCusVei[nLinha,1] := !aCusVei[nLinha,1]
EndIf
Return()
