// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 20     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX014.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXX014 ³ Autor ³ Rafael Goncalves      ³ Data ³ 25/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bonus do Veiculo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX014(cAtend,cCodMar,cGruMod,cModVei,nOpc,lTela,cEstVei,nRecVVA,lSoSelect)
//variaveis controle de janela
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam   := 0
Local cChaint   := ""
Local aBonVei   := {}
Local nOpcao    := 1
Local ni        := 0
Local lAltGrv   := .t.
Local _ni       := 0                               
Local nTotFab   := 0 // valor total Fabrica
Local nTotReg   := 0 // valor total Regional
Local nTotCon   := 0 // valor total Concessionaria 
Local nRecVZS   := 0
Local cQuery    := ""
Local cAliasVZS := "SQLVZS"
Local cVeiculo  := ""
Local lBonusVeic:= .f.
Local lVZS_ITETRA := ( VZS->(FieldPos("VZS_ITETRA")) > 0 )
Local lVZS_FILATE := ( VZS->(FieldPos("VZS_FILATE")) > 0 )
Local dDatRef   := dDataBase
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private cBonusVeic := "2"
Default cCodMar := SPACE(LEN(VV1->VV1_CODMAR))
Default cModVei := SPACE(LEN(VV1->VV1_MODVEI))
Default cGruMod := SPACE(LEN(VV2->VV2_GRUMOD))
Default lTela   := .t.
Default cEstVei := "0"
Default nRecVVA := 0
Default lSoSelect := .f.
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
If lSoSelect // Somente seleciona independente do usuario
	cBonusVeic := "1" // Somente Seleciona
	lBonusVeic := .t.
Else
	If VAI->(FieldPos("VAI_BONUSV")) > 0
		If VAI->VAI_BONUSV $ "1/3/4" // Bonus ( 1=Seleciona / 3=Altera valor para menor / 4=Altera para qualquer valor )
			cBonusVeic := VAI->VAI_BONUSV
			lBonusVeic := .t.
		EndIf
	Else
		If VAI->VAI_TIPTEC <= "3"  // 1=Diretor;2=Gerente;3=Supervisor
			cBonusVeic := "4" // Bonus ( 4=Altera para qualquer valor )
			lBonusVeic := .t.
		EndIf
	EndIf
EndIf
DbSelectArea("VVA")
DbSetOrder(1)
If nRecVVA > 0
	DbGoTo(nRecVVA)
Else
	DbSeek(xFilial("VVA")+cAtend)
EndIf

nTotFab := VVA->VVA_BONFAB // valor total Bonus Fabrica
nTotReg := VVA->VVA_BONREG // valor total Bonus Regional
nTotCon := VVA->VVA_BONCON // valor total Bonus Concessionaria

//////////////////////////////////////////////////////////////////////////
// PE para manipulacao da Data de Referencia para levantamento do Bonus //
//////////////////////////////////////////////////////////////////////////
If ExistBlock("VXX14DTBN")
	dDatRef := ExecBlock("VXX14DTBN",.f.,.f.)			
Endif

///////////////////////////////////
//   BONUS DE VENDA DO VEICULO   //
///////////////////////////////////
FGX_BONVEI(VVA->VVA_CHAINT,cCodMar,cModVei,,,,cEstVei,cGruMod,dDataBase,VVA->VVA_NUMTRA,@aBonVei,IIf(lVZS_ITETRA,VVA->VVA_ITETRA,""),"1",dDatRef,VVA->VVA_FILIAL,.f.)
///////////////////////////////////

If lTela
	nOpcao := 0
	If !Empty(VVA->VVA_CHAINT)
		VV1->(DbSetOrder(1))
		VV1->(DbSeek( xFilial("VV1") + VVA->VVA_CHAINT ))
		cVeiculo += Alltrim(VV1->VV1_CHASSI) + " - "
		cCodMar  := VV1->VV1_CODMAR
		cModVei  := VV1->VV1_MODVEI
	EndIf
	VV2->(DbSetOrder(1))
	VV2->(DbSeek( xFilial("VV2") + cCodMar + cModVei ))
	cVeiculo += Alltrim(cCodMar) + " " + Alltrim(VV2->VV2_DESMOD)
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 0, 0 , .T. , .T. } )  	//list box
	// Fator de reducao de 0.8
	For nCntTam := 1 to Len(aSizeAut)
		aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
	Next
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos  := MsObjSize (aInfo, aObjects,.F.)
	DEFINE MSDIALOG oBonVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (STR0001+": "+cVeiculo) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Selecione o Bonus do Veiculo
	oBonVeic:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] LISTBOX oLstVei FIELDS HEADER " ",STR0002,STR0003,STR0004,STR0005,STR0006 COLSIZES ; // Bonus / Bonus Vigente / Bonus Utilizado / Tipo do Bonus / Vigencia do Bonus
	10,60,50,50,50,100 SIZE aPos[1,4],aPos[1,3]-(aPos[1,1]+003) OF oBonVeic PIXEL ON DBLCLICK IIf(lBonusVeic,FS_TIK(@aBonVei,oLstVei:Nat,nOpc),.t.)
	oLstVei:SetArray(aBonVei)
	oLstVei:bLine := { || { IIf( aBonVei[oLstVei:nAt,01]=="1" .or. aBonVei[oLstVei:nAt,01]=="2" ,oOk,oNo),;
							aBonVei[oLstVei:nAt,02]+" "+aBonVei[oLstVei:nAt,05],;
							FG_AlinVlrs(Transform(aBonVei[oLstVei:nAt,03],"@E 999,999,999.99")) ,;
							FG_AlinVlrs(Transform(aBonVei[oLstVei:nAt,06],"@E 999,999,999.99")) ,;
							X3CBOXDESC("VZQ_TIPBON",aBonVei[oLstVei:nAt,04]) ,;
							aBonVei[oLstVei:nAt,07] }}
	ACTIVATE MSDIALOG oBonVeic ON INIT EnchoiceBar(oBonVeic,{|| nOpcao:=1,oBonVeic:End() , .f. },{|| oBonVeic:End() } ) CENTER
EndIf
If nOpcao == 1
	If ( nOpc == 3 .or. nOpc == 4 ) // Inclusao/Alteracao
		nTotFab := 0
		nTotReg := 0
		nTotCon := 0
		DbSelectArea("VZS")
		For ni := 1 to Len(aBonVei)
			If aBonVei[ni,1] <> "0" // SE TIVER SELECIONADO OU FOR OBRIGATORIO
				If aBonVei[ni,4] == "1" // Fabrica
					nTotFab += IIf(aBonVei[ni,6]>0,aBonVei[ni,6],aBonVei[ni,3])
				ElseIf aBonVei[ni,4] == "2" // Regional
					nTotReg += IIf(aBonVei[ni,6]>0,aBonVei[ni,6],aBonVei[ni,3])
				ElseIf aBonVei[ni,4] == "3" // Concessionaria
					nTotCon += IIf(aBonVei[ni,6]>0,aBonVei[ni,6],aBonVei[ni,3])
				EndIf
			EndIf

			cQuery := "SELECT VZS.R_E_C_N_O_ AS RECVZS FROM "+RetSqlName("VZS")+" VZS WHERE "
			cQuery += "VZS.VZS_FILIAL='"+xFilial("VZS")+"' AND VZS.VZS_CODBON='"+aBonVei[ni,2]+"' AND "
			If lVZS_FILATE
				cQuery += "VZS.VZS_FILATE='"+VVA->VVA_FILIAL+"' AND "
			EndIf
			cQuery += "VZS.VZS_NUMATE='"+VVA->VVA_NUMTRA+"' AND "
			If lVZS_ITETRA
				cQuery += "VZS.VZS_ITETRA='"+VVA->VVA_ITETRA+"' AND "
			EndIf
			cQuery += "VZS.D_E_L_E_T_ = ' ' "

			nRecVZS := FM_SQL(cQuery)
			if nRecVZS == 0
				// Registro antigos
				cQuery := "SELECT VZS.R_E_C_N_O_ AS RECVZS FROM "+RetSqlName("VZS")+" VZS WHERE "
				cQuery += "VZS.VZS_FILIAL='"+xFilial("VZS")+"' AND VZS.VZS_CODBON='"+aBonVei[ni,2]+"' AND "
				cQuery += "VZS.VZS_NUMATE='"+VVA->VVA_NUMTRA+"' AND "
				If lVZS_FILATE
					cQuery += "VZS.VZS_FILATE=' ' AND "
				EndIf
				If lVZS_ITETRA
					cQuery += "VZS.VZS_ITETRA='"+VVA->VVA_ITETRA+"' AND "
				EndIf
				cQuery += "VZS.D_E_L_E_T_ = ' ' "
        	
				nRecVZS := FM_SQL(cQuery)
			Endif
			If nRecVZS > 0 // Existe registro no VZS
				DbSelectArea("VZS")
				DbGoTo(nRecVZS)
				lAltGrv := .f.
			Else // Nao existe VZS
				DbSelectArea("VZS")
				lAltGrv := .t.
			EndIf
			If aBonVei[ni,1] <> "0" //SE TIVER SELECIONADO OU FOR OBRIGATORIO GRAVA
				RecLock("VZS", lAltGrv )
				VZS->VZS_FILIAL := xFilial("VZS")
				VZS->VZS_CODBON := aBonVei[ni,2]
				If lVZS_FILATE
					VZS->VZS_FILATE := VVA->VVA_FILIAL
				EndIf
				VZS->VZS_NUMATE := VVA->VVA_NUMTRA
				If lVZS_ITETRA
					VZS->VZS_ITETRA := VVA->VVA_ITETRA
				EndIf
				VZS->VZS_VALBON := IIf(aBonVei[ni,6]>0,aBonVei[ni,6],aBonVei[ni,3])
				MsUnLock()
			ElseIf !lAltGrv
				RecLock("VZS",.F.,.T.)
				dbdelete()
				MsUnlock()
			EndIf
			///////////////////////////////////////////////////////////////////////////////////
			// Deleta registros gravados anteriormente e que estão fora do novo levantamento // 
			///////////////////////////////////////////////////////////////////////////////////

			cQuery := "SELECT VZS.R_E_C_N_O_ AS RECVZS , VZS.VZS_CODBON FROM "+RetSqlName("VZS")+" VZS WHERE "
			cQuery += "VZS.VZS_FILIAL='"+xFilial("VZS")+"' AND "
			If lVZS_FILATE
				cQuery += "VZS.VZS_FILATE='"+VVA->VVA_FILIAL+"' AND "
			EndIf
			cQuery += "VZS.VZS_NUMATE='"+VVA->VVA_NUMTRA+"' AND "
			If lVZS_ITETRA
				cQuery += "VZS.VZS_ITETRA='"+VVA->VVA_ITETRA+"' AND "
			EndIf
			cQuery += "VZS.D_E_L_E_T_ = ' ' "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVZS , .F., .T. )

			if (cAliasVZS)->( RECVZS ) == 0 
				// Registro antigos
				(cAliasVZS)->(DbCloseArea())
				cQuery := "SELECT VZS.R_E_C_N_O_ AS RECVZS , VZS.VZS_CODBON FROM "+RetSqlName("VZS")+" VZS WHERE "
				cQuery += "VZS.VZS_FILIAL='"+xFilial("VZS")+"' AND "
				cQuery += "VZS.VZS_NUMATE='"+VVA->VVA_NUMTRA+"' AND "
				If lVZS_FILATE
					cQuery += "VZS.VZS_FILATE=' ' AND " 
				EndIf
				If lVZS_ITETRA
					cQuery += "VZS.VZS_ITETRA='"+VVA->VVA_ITETRA+"' AND "
				EndIf
				cQuery += "VZS.D_E_L_E_T_ = ' ' "
        	
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVZS , .F., .T. )
			Endif
			
			While !(cAliasVZS)->( Eof() )
				If aScan(aBonVei,{|x| AllTrim(x[2])==Alltrim((cAliasVZS)->( VZS_CODBON ))}) == 0
					DbSelectArea("VZS")
					DbGoTo( (cAliasVZS)->( RECVZS ) )                  
					RecLock("VZS",.F.,.T.)
					dbdelete()
					MsUnlock()
				Endif			
				(cAliasVZS)->(DbSkip())
			Enddo
			(cAliasVZS)->(DbCloseArea())
			//
		Next
		M->VVA_BONFAB := nTotFab
		M->VVA_BONREG := nTotReg
		M->VVA_BONCON := nTotCon
		//altera valor VVA
		DbSelectArea("VVA")
		DbSetOrder(1)
		If nRecVVA > 0
			DbGoTo(nRecVVA)
			RecLock("VVA", .f. )
			VVA->VVA_BONFAB := nTotFab
			VVA->VVA_BONREG := nTotReg
			VVA->VVA_BONCON := nTotCon
			MsUnLock()
		Else
			If DbSeek(xFilial("VVA")+cAtend)
				RecLock("VVA", .f. )
				VVA->VVA_BONFAB := nTotFab
				VVA->VVA_BONREG := nTotReg
				VVA->VVA_BONCON := nTotCon
				MsUnLock()
			EndIf
		EndIf
		If FindFunction("VX002ACOLS") .and. FM_PILHA("VEIXX002")
			VX002ACOLS("VVA_BONFAB")
			VX002ACOLS("VVA_BONREG")
			VX002ACOLS("VVA_BONCON")
		EndIf
	EndIf
EndIf

Return(nTotFab+nTotReg+nTotCon)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK   ³ Autor ³ Rafael Goncalves      ³ Data ³ 25/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona / Altera Valor do bonus desejado                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(aBonVei,nLinha,nOpc)
Local aRet      := {}
Local aParamBox := {}
Private nVlrOri := 0
If nOpc == 3 .or. nOpc == 4  // Incluir ou Alterar
	If len(aBonVei) > 1 .or. !Empty(aBonVei[1,2])
		If aBonVei[nLinha,1]<>"1"
			If aBonVei[nLinha,1] == "2"
				aBonVei[nLinha,1] := "0"
			ElseIf aBonVei[nLinha,1] == "0"
				aBonVei[nLinha,1] := "2"
			EndIf
			If aBonVei[nLinha,1] <> "0" // Diferente de NAO selecionado -> deixa alterar o Valor do Bonus
				If aBonVei[nLinha,6] <= 0
					aBonVei[nLinha,6] := aBonVei[nLinha,3]
				EndIf
				If cBonusVeic <> "1" // Diferente de somente Seleciona
					If cBonusVeic == "3" // Bonus - 3=Altera o valor para menor
						nVlrOri := aBonVei[nLinha,3]
						AADD(aParamBox,{1,STR0002,aBonVei[nLinha,6],"@E 999,999,999.99","MV_PAR01>0.and.MV_PAR01<=nVlrOri","",".T.",50,.t.}) // Bonus
					ElseIf cBonusVeic == "4" // Bonus - 4=Altera para qualquer valor
						AADD(aParamBox,{1,STR0002,aBonVei[nLinha,6],"@E 999,999,999.99","MV_PAR01>0","",".T.",50,.t.}) // Bonus
					EndIf
					If ParamBox(aParamBox,STR0002,@aRet,,,,,,,,.f.) // Bonus
						aBonVei[nLinha,6] := aRet[01] // Valor do Bonus
					EndIf
				EndIf
			EndIf
		EndIf
		oLstVei:Refresh()
	EndIf
EndIf
Return()