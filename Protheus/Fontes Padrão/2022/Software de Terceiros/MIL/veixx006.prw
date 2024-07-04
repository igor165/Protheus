// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX006.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX006 º Autor ³ Andre Luis Almeida º Data ³  07/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula Data de Entrega do Veiculo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc   (2-Visualizar/4-Alterar/3-Incluir)                  º±±
±±º          ³ aEntrVei (Vetor de Parametros/Retorno)                     º±±
±±º			 ³	 aEntrVei[01] = Numero do Atendimento                     º±±
±±º			 ³	 aEntrVei[02] = Chassi Interno (CHAINT)                   º±±
±±º			 ³	 aEntrVei[03] = Marca do Veiculo                          º±±
±±º			 ³	 aEntrVei[04] = Modelo do Veiculo                         º±±
±±º			 ³	 aEntrVei[05] = Data de Entrega sugerida pelo Sistema     º±±
±±º			 ³	 aEntrVei[06] = Data de Entrega prevista pelo Usuario     º±±
±±º			 ³	 aEntrVei[07] = Observacao MEMO                           º±±
±±º			 ³	 aEntrVei[08] = RECNO do VVA                              º±±
±±º			 ³	 aEntrVei[09] = Hora de Entrega prevista pelo Usuario     º±±
±±º			 ³	 aEntrVei[10] = Filial de Entrega prevista pelo Usuario   º±±
±±º			 ³	 aEntrVei[11] = Box de Entrega prevista pelo Usuario      º±±
±±º			 ³	 aEntrVei[12] = Usuario de Entrega prevista pelo Usuario  º±±
±±º			 ³	 aEntrVei[13] = Segmento do Modelo                        º±±
±±º          ³ lTela ( Mostra Tela das Datas de Entrega / Observacao )    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX006(nOpc,aEntrVei,lTela)
//
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam   := 0
//
Local cSQLAlias := "SQLVDH"
Local cQuery    := ""
Local lOk       := .t.
Local dDtESug   := dDataBase
Local dDtEPrv   := ctod("")
Local cFiEPrv   := ""
Local nDias     := 0
Local lFazLev   := .f.
Local nRecnoVVA := 0
Local aFilTot   := {}
Private oOkTik  := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik  := LoadBitmap( GetResources() , "LBNO" )
Private cFilTot := ""
Private dDtIni  := dDataBase
Private dDtFin  := dDataBase
Private nHrIni  := 23
Private nHrFin  := 0
Private aPrvVei := {}
If len(aEntrVei) > 7
    nRecnoVVA := aEntrVei[08]
EndIf
If !Empty(aEntrVei[02])
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+aEntrVei[02]))
	aEntrVei[03]     := VV1->VV1_CODMAR
	aEntrVei[04]     := VV1->VV1_MODVEI
	aEntrVei[13]     := VV1->VV1_SEGMOD
EndIf
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If lTela .and. !Empty(aEntrVei[06]) // Mostra tela e ja existe data de previsao de entrega
		If MsgYesNo(STR0003,STR0002) // Deseja recalcular a Data de Sugestao de Entrega? / Atencao
			lFazLev  := .t.
		Else
			dDtESug  := aEntrVei[05]
			dDtEPrv  := aEntrVei[06]
			cFiEPrv  := aEntrVei[10]
		EndIf
	Else
		lFazLev      := .t.
		aEntrVei[05] := dDtESug
   		aEntrVei[06] := dDtEPrv
   		aEntrVei[10] := cFiEPrv
	EndIf
EndIf
If lFazLev
	VE4->(DbSetOrder(1))
	If VE4->(DbSeek(xFilial("VE4")+aEntrVei[03]))
		If VE4->VE4_QTDENT > 0
			nDias := 0
			ni    := 0
			While .t.
				nDias++
				If dow(dDtESug+nDias) <> 7 .and. dow(dDtESug+nDias) <> 1 // Dias Uteis, desprezar Sabado e Domingo
					ni++
					If ni >= VE4->VE4_QTDENT
						Exit
					EndIf
				EndIf
			EndDo
			dDtESug += nDias
		EndIf
	EndIf

	If FGX_VV2(aEntrVei[03], aEntrVei[04], aEntrVei[13])
	
		If VV2->VV2_QTDENT > 0
			nDias := 0
			ni    := 0
			While .t.
				nDias++
				If dow(dDtESug+nDias) <> 7 .and. dow(dDtESug+nDias) <> 1 // Dias Uteis, desprezar Sabado e Domingo
					ni++
					If ni >= VV2->VV2_QTDENT
						Exit
					EndIf
				EndIf
			EndDo
			dDtESug += nDias
		EndIf
	EndIf
	If !Empty(aEntrVei[01]) .and. !Empty(aEntrVei[02])
		If ExistBlock("PVM011DTENT")
			dDtESug := ExecBlock("PVM011DTENT",.f.,.f.,{aEntrVei[01],aEntrVei[02],dDtESug})
		EndIf
	EndIf
	aEntrVei[05] := dDtESug // Data de Sugestao de Entrega
	If Empty(aEntrVei[06])
		aEntrVei[06] := aEntrVei[05] // Data de Previsao de Entrega
		aEntrVei[10] := xFilial("VV9")
	EndIf
	dDtEPrv := aEntrVei[06]
	cFiEPrv := aEntrVei[10]
EndIf
//
If aEntrVei[05] < dDataBase
	dDtIni := dDtFin := dDataBase
Else
	dDtIni := dDtFin := aEntrVei[05]
EndIf
//
If !Empty(aEntrVei[01])
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek( xFilial("VV9") + aEntrVei[01] )
EndIf
If nRecnoVVA <= 0
	DbSelectArea("VVA")
	DbSetOrder(1)
	DbSeek( xFilial("VVA") + aEntrVei[01] + IIf(!Empty(aEntrVei[02]),VV1->VV1_CHASSI,"") )
	nRecnoVVA := VVA->(RecNo())
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+VVA->VVA_CHAINT))
Else
	DbSelectArea("VVA")
	DbGoTo(nRecnoVVA)
EndIf
If lTela
	lOk := .f.
	If nRecnoVVA > 0
		FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
		//
		ni := FM_SQL("SELECT MIN(VDH.VDH_HP1INI) FROM "+RetSQLName("VDH")+" VDH WHERE VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND ( VDH.VDH_HP1INI<>0 OR VDH.VDH_HP1FIN<>0 ) AND VDH.D_E_L_E_T_=' ' ")
		If ni < nHrIni
			nHrIni := ni
		EndIf
		ni := FM_SQL("SELECT MIN(VDH.VDH_HP2INI) FROM "+RetSQLName("VDH")+" VDH WHERE VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND ( VDH.VDH_HP2INI<>0 OR VDH.VDH_HP2FIN<>0 ) AND VDH.D_E_L_E_T_=' ' ")
		If ni < nHrIni
			nHrIni := ni
		EndIf
		nHrFin := nHrIni
		ni := FM_SQL("SELECT MAX(VDH.VDH_HP1FIN) FROM "+RetSQLName("VDH")+" VDH WHERE VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND ( VDH.VDH_HP1INI<>0 OR VDH.VDH_HP1FIN<>0 ) AND VDH.D_E_L_E_T_=' ' ")
		If ni > nHrFin
			nHrFin := ni
		EndIf
		ni := FM_SQL("SELECT MAX(VDH.VDH_HP2FIN) FROM "+RetSQLName("VDH")+" VDH WHERE VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND ( VDH.VDH_HP2INI<>0 OR VDH.VDH_HP2FIN<>0 ) AND VDH.D_E_L_E_T_=' ' ")
		If ni > nHrFin
			nHrFin := ni
		EndIf
		//
		cQuery := "SELECT DISTINCT VDH.VDH_FILBOX , VDH.VDH_CODBOX FROM "+RetSQLName("VDH")+" VDH "
		cQuery += "WHERE VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND VDH.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY VDH.VDH_FILBOX , VDH.VDH_CODBOX"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->(Eof())
			If (cSQLAlias)->( VDH_FILBOX ) <> cFilTot
				cFilTot := (cSQLAlias)->( VDH_FILBOX )
				aadd(aFilTot,"")
				aadd(aFilTot,(cSQLAlias)->( VDH_FILBOX )+"="+STR0004+" "+(cSQLAlias)->( VDH_FILBOX ))
			EndIf
			aadd(aFilTot,(cSQLAlias)->( VDH_FILBOX )+(cSQLAlias)->( VDH_CODBOX )+"="+STR0005+" "+(cSQLAlias)->( VDH_CODBOX ))
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		cFilTot := ""
		//
		FS_LEVANT(nOpc,aEntrVei,.f.)
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 0, 25 , .T. , .F. } ) // cabecalho
		AAdd( aObjects, { 0, 00 , .T. , .T. } ) // listbox

		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPos  := MsObjSize (aInfo, aObjects,.F.)
		DEFINE MSDIALOG oPrvDtVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (STR0001+" - "+(Alltrim(VV1->VV1_CODMAR)+" - "+Alltrim(VV2->VV2_DESMOD))+" - "+VV1->VV1_CHASSI) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Previsao de Entrega
		oPrvDtVeic:lEscClose := .F.

		@ aPos[2,1],aPos[2,2]+002 LISTBOX oLstPrvVei FIELDS HEADER " ",STR0004,STR0005,STR0006,STR0007,STR0008,STR0018 COLSIZES ;
		10,50,30,100,80,25,100 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oPrvDtVeic PIXEL ON DBLCLICK FS_DBLCLIC(nOpc)
		oLstPrvVei:SetArray(aPrvVei)
		oLstPrvVei:bLine := { || { IIf(aPrvVei[oLstPrvVei:nAt,01],oOkTik,oNoTik) ,;
								aPrvVei[oLstPrvVei:nAt,02] ,;
								aPrvVei[oLstPrvVei:nAt,03] ,;
								aPrvVei[oLstPrvVei:nAt,04]+" - "+aPrvVei[oLstPrvVei:nAt,07] ,;
								Transform(aPrvVei[oLstPrvVei:nAt,05],"@D")+" ( "+FG_CDOW(aPrvVei[oLstPrvVei:nAt,05])+" )" ,;
								strzero(aPrvVei[oLstPrvVei:nAt,06],2)+"h" ,;
								aPrvVei[oLstPrvVei:nAt,09] }}

		@ aPos[1,1]+000,aPos[1,2]+003 SAY STR0009 SIZE 50,8 OF oPrvDtVeic PIXEL COLOR CLR_BLUE // Dt.Sugerida
		@ aPos[1,1]+009,aPos[1,2]+003 MSGET oDtESug VAR dDtESug PICTURE "@D" SIZE 40,08 OF oPrvDtVeic PIXEL COLOR CLR_BLACK WHEN .f.

		@ aPos[1,1]+000,aPos[1,2]+048 SAY STR0004+" / "+STR0005 SIZE 50,8 OF oPrvDtVeic PIXEL COLOR CLR_BLUE // Filial / Box
		@ aPos[1,1]+009,aPos[1,2]+048 MSCOMBOBOX oFilTot VAR cFilTot SIZE 160,08 COLOR CLR_BLACK ITEMS aFilTot OF oPrvDtVeic PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 )

		@ aPos[1,1]+000,aPos[1,2]+213 SAY STR0010 SIZE 50,8 OF oPrvDtVeic PIXEL COLOR CLR_BLUE // Periodo
		@ aPos[1,1]+009,aPos[1,2]+213 MSGET oDtIni VAR dDtIni VALID ( dDtIni >= dDataBase ) PICTURE "@D" SIZE 40,08 OF oPrvDtVeic PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 )
		@ aPos[1,1]+010,aPos[1,2]+256 SAY STR0011 SIZE 50,8 OF oPrvDtVeic PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+009,aPos[1,2]+263 MSGET oDtFin VAR dDtFin VALID ( dDtFin >= dDtIni ) PICTURE "@D" SIZE 40,08 OF oPrvDtVeic PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 )

		@ aPos[1,1]+000,aPos[1,2]+308 SAY STR0014 SIZE 50,8 OF oPrvDtVeic PIXEL COLOR CLR_BLUE // Horario
		@ aPos[1,1]+009,aPos[1,2]+308 MSGET oHrIni VAR nHrIni VALID ( nHrIni >= 0 .and. nHrIni <= 23 ) PICTURE "@E 99" SIZE 13,08 OF oPrvDtVeic PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 )
		@ aPos[1,1]+010,aPos[1,2]+324 SAY STR0011 SIZE 50,8 OF oPrvDtVeic PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+009,aPos[1,2]+331 MSGET oHrFin VAR nHrFin VALID ( nHrFin >= nHrIni .and. nHrFin <= 23 ) PICTURE "@E 99" SIZE 13,08 OF oPrvDtVeic PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 )

		@ aPos[1,1]+008,aPos[1,2]+349 BUTTON oFiltrar PROMPT STR0012 OF oPrvDtVeic SIZE 30,11 PIXEL ACTION FS_LEVANT(nOpc,aEntrVei,.t.) WHEN ( nOpc == 3 .or. nOpc == 4 ) // Filtrar

		ACTIVATE MSDIALOG oPrvDtVeic ON INIT EnchoiceBar(oPrvDtVeic,{|| IIf(FS_OKTELA(nOpc,aEntrVei,nRecnoVVA),oPrvDtVeic:End(),.t.) },{|| oPrvDtVeic:End() } ) CENTER
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DBLCLICº Autor ³ Andre Luis Almeida º Data ³ 08/03/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Duplo Click no ListBox                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DBLCLIC(nOpc)
Local lSel := .t. // Selecionar
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If !Empty(aPrvVei[oLstPrvVei:nAt,05])
		If aPrvVei[oLstPrvVei:nAt,01] // Selecionado
			lSel := .f. // Tirar Selecao
		EndIf
		aEval( aPrvVei , { |x| x[1] := .f. } )
		aPrvVei[oLstPrvVei:nAt,01] := lSel
		oLstPrvVei:Refresh()
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_OKTELAº Autor ³ Andre Luis Almeida º Data ³ 05/03/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ OK da tela                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OKTELA(nOpc,aEntrVei,nRecnoVVA)
Local lSel      := .f.
Local lRet      := .t.
Local cQuery    := ""
Local ni        := 0
Local cObserv   := ""
Local nTamObs   := VVA->(TamSx3("VVA_OBSENT")[1])
Local nCont     := 0
Local lEmBranco := .t.
If nOpc == 3 .or. nOpc == 4
	DbSelectArea("VVA")
	lRet := .f.
	For ni := 1 to len(aPrvVei)
		If aPrvVei[ni,01]
			lSel := .t.
			While Empty(cObserv)
				cObserv := FM_OBSMEM(STR0001,VVA->VVA_ENTMEM,"VVA_ENTMEM","VVA_OBSENT",.t.) // Previsao de Entrega - Observacao
				If !Empty(cObserv)
					lEmBranco := .t.
					For nCont := 1 to MLCount(cObserv,nTamObs)
						If !Empty(MemoLine(cObserv,nTamObs,nCont))
							lEmBranco := .f.
							Exit
						EndIf
					Next
					If lEmBranco
						cObserv := ""
					EndIf
				EndIf
			EndDo
			// Verificar se horario esta sendo utilizado para a entrega de outro veiculo //
			cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA WHERE "
			cQuery += "VVA.VVA_FIEPRV='"+aPrvVei[ni,02]+"' AND "
			cQuery += "VVA.VVA_BOEPRV='"+aPrvVei[ni,03]+"' AND "
			cQuery += "VVA.VVA_USEPRV='"+aPrvVei[ni,04]+"' AND "
			cQuery += "VVA.VVA_DTEPRV='"+dtos(aPrvVei[ni,05])+"' AND "
			cQuery += "VVA.VVA_HREPRV="+Alltrim(str(aPrvVei[ni,06]))+" AND "
			cQuery += "VVA.R_E_C_N_O_<>"+Alltrim(str(nRecnoVVA))+" AND "
			cQuery += "VVA.D_E_L_E_T_=' '"
			If FM_SQL(cQuery) > 0
				MsgStop(STR0013,STR0002) // Horario nao esta mais disponivel! Favor selecionar outro horario. / Atencao
				FS_LEVANT(nOpc,aEntrVei,.t.)
				Exit
			Else
				aEntrVei[06] := aPrvVei[ni,05] // Data 
				aEntrVei[07] := cObserv        // Observacao MEMO
				aEntrVei[08] := nRecnoVVA      // RecNo VVA
				aEntrVei[09] := aPrvVei[ni,06] // Hora
				aEntrVei[10] := aPrvVei[ni,02] // Filial Box
				aEntrVei[11] := aPrvVei[ni,03] // Box
				aEntrVei[12] := aPrvVei[ni,04] // Responsavel
				VX006GRV(nOpc,aEntrVei[01],aEntrVei[05],aEntrVei[06],ctod(""),aEntrVei[07],aEntrVei[08],aEntrVei[09],aEntrVei[10],aEntrVei[11],aEntrVei[12]) // Gravar Campos de Entrega e Memo (Observacao)
				lRet := .t.
				Exit
			EndIf
		EndIf
	Next
	If !lSel // Nenhuma Filial/Box selecionada - Limpar campos
		aEntrVei[07] := ""             // Observacao MEMO
		aEntrVei[08] := nRecnoVVA      // RecNo VVA
		aEntrVei[09] := 0              // Hora
		aEntrVei[10] := ""             // Filial Box
		aEntrVei[11] := ""             // Box
		aEntrVei[12] := ""             // Responsavel
		VX006GRV(nOpc,aEntrVei[01],aEntrVei[05],aEntrVei[06],ctod(""),aEntrVei[07],aEntrVei[08],aEntrVei[09],aEntrVei[10],aEntrVei[11],aEntrVei[12]) // Gravar Campos de Entrega e Memo (Observacao)
		lRet := .t.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_LEVANTº Autor ³ Andre Luis Almeida º Data ³  19/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Levanta dias disponiveis para Entrega                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nOpc,aEntrVei,lRefresh)
Local cSQLAlias := "SQLVDH"
Local cSQLAux   := "SQLAUX"
Local cQuery    := ""
Local nQtdDias  := 0
Local cObs      := ""
Local ni        := 0
Local nj        := 0
Local nTFilBox  := VDH->(TamSX3("VDH_FILBOX")[1])
Local nTCodBox  := VDH->(TamSX3("VDH_CODBOX")[1])
Local cHoras    := ""
Local nHrAux    := 0
Local dDtAux    := ctod("")
Local cTpDia    := ""
Local lOk       := .t.
aPrvVei := {}
//
If !Empty(aEntrVei[11]) // Ja possui Entrega agendada
	
	If nOpc <> 3 .and. nOpc <> 4
		cObs := STR0015 // Entrega prevista
		If VV9->VV9_STATUS == "F" // Ja esta poscionado no VV9 - Atendimento
			If !Empty(VVA->VVA_DTEREA) // Ja esta posicionado no VVA - Veiculo
				cObs := STR0017 + Transform(VVA->VVA_DTEREA,"@D")+" "+Transform(VVA->VVA_HORREA,"@R 99:99")+"h " // Veiculo entregue
				cObs += VVA->VVA_USUREA+" - "+FM_SQL("SELECT VAI.VAI_NOMTEC FROM "+RetSQLName("VAI")+" VAI WHERE VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR='"+VVA->VVA_USUREA+"' AND VAI.D_E_L_E_T_=' ' ")
			Else
				cObs := STR0016 // Aguardando entrega
			EndIf
		EndIf
	EndIf
	aadd(aPrvVei,{ .t. , aEntrVei[10] , aEntrVei[11] , aEntrVei[12] , aEntrVei[06] , aEntrVei[09] , left( FM_SQL("SELECT VAI.VAI_NOMTEC FROM "+RetSQLName("VAI")+" VAI WHERE VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR='"+aEntrVei[12]+"' AND VAI.D_E_L_E_T_=' '" ) , 15 ) , "0" , cObs })

EndIf
If nOpc == 3 .or. nOpc == 4
	cQuery := "SELECT VDH.* , COALESCE(VAI.VAI_NOMTEC, ' ') VAI_NOMTEC FROM "+RetSQLName("VDH")+" VDH "
	cQuery += "LEFT JOIN "+RetSQLName("VAI")+" VAI ON VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR=VDH.VDH_USUBOX AND VAI_CODUSR <> ' ' AND VAI.D_E_L_E_T_=' ' "
	cQuery += "WHERE VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND "
	If !Empty(cFilTot)
		cQuery += "VDH.VDH_FILBOX='"+left(cFilTot,nTFilBox)+"' AND "
		If len(cFilTot) <> nTFilBox
			cQuery += "VDH.VDH_CODBOX='"+substr(cFilTot,nTFilBox+1,nTCodBox)+"' AND "
		EndIf
	EndIf
	cQuery += "VDH.D_E_L_E_T_=' ' ORDER BY VDH.VDH_FILBOX , VDH.VDH_CODBOX , VDH.VDH_USUBOX "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		nQtdDias := ( dDtFin - dDtIni ) + 1
		For nj := 1 to nQtdDias
			cHoras := ""
			dDtAux := ( dDtIni + nj ) - 1
			cQuery := "SELECT VVA.VVA_HREPRV FROM "+RetSQLName("VVA")+" VVA WHERE "
			cQuery += "VVA.VVA_FIEPRV='"+(cSQLAlias)->( VDH_FILBOX )+"' AND "
			cQuery += "VVA.VVA_BOEPRV='"+(cSQLAlias)->( VDH_CODBOX )+"' AND "
			cQuery += "VVA.VVA_USEPRV='"+(cSQLAlias)->( VDH_USUBOX )+"' AND "
			cQuery += "VVA.VVA_DTEPRV='"+dtos(dDtAux)+"' AND "
			cQuery += "VVA.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux , .F. , .T. )
			While !(cSQLAux)->(Eof())
		   		cHoras += strzero((cSQLAux)->( VVA_HREPRV ),2) + "/"
				(cSQLAux)->(dbSkip())
			EndDo
			(cSQLAux)->(dbCloseArea())		
			cTpDia := substr((cSQLAlias)->( VDH_DIACON),dow(dDtAux),1)
			For ni := 1 to 24
				nHrAux := ni - 1
				If nHrIni > nHrAux .or. nHrFin < nHrAux
					Loop
				EndIf
				If dDataBase == dDtAux
					If nHrAux < val(left(Time(),2))
						Loop
					EndIf
				EndIf
				If !( strzero(nHrAux,2) $ cHoras )
					If aEntrVei[06] <> dDtAux .or. aEntrVei[09] <> nHrAux .or. aEntrVei[10] <> (cSQLAlias)->( VDH_FILBOX ) .or. aEntrVei[11] <> (cSQLAlias)->( VDH_CODBOX ) .or. aEntrVei[12] <> (cSQLAlias)->( VDH_USUBOX )
						lOk := .f.
						If cTpDia == "1" .or. cTpDia == "3"
							If (cSQLAlias)->( VDH_HP1INI ) <> 0 .or. (cSQLAlias)->( VDH_HP1FIN ) <> 0
						    	If (cSQLAlias)->( VDH_HP1INI ) <= nHrAux .and. (cSQLAlias)->( VDH_HP1FIN ) >= nHrAux
					    			lOk := .t.
						    	EndIf
					    	EndIf
					 	EndIf
						If cTpDia == "2" .or. cTpDia == "3"
							If (cSQLAlias)->( VDH_HP2INI ) <> 0 .or. (cSQLAlias)->( VDH_HP2FIN ) <> 0
					    		If (cSQLAlias)->( VDH_HP2INI ) <= nHrAux .and. (cSQLAlias)->( VDH_HP2FIN ) >= nHrAux
					    			lOk := .t.
								EndIf
							EndIf
				    	EndIf
				    	If lOk
							aadd(aPrvVei,{ .f. , (cSQLAlias)->( VDH_FILBOX ) , (cSQLAlias)->( VDH_CODBOX ) , (cSQLAlias)->( VDH_USUBOX ) , dDtAux , nHrAux , left( (cSQLAlias)->( VAI_NOMTEC ) , 15 ) , "1" , "" })
				    	EndIf
			    	EndIf
			    EndIf
			Next
		Next
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
EndIf
If len(aPrvVei) <= 0
	aadd(aPrvVei,{ .f. , "" , "" , "" , ctod("") , 0 , "" , "0" , "" })
Else
	Asort(aPrvVei,,,{|x,y| x[8]+dtos(x[5])+strzero(x[6],2)+x[2]+x[3]+x[4] < y[8]+dtos(y[5])+strzero(y[6],2)+y[2]+y[3]+y[4] })
EndIf
If lRefresh
	oLstPrvVei:nAt := 1
	oLstPrvVei:SetArray(aPrvVei)
	oLstPrvVei:bLine := { || { IIf(aPrvVei[oLstPrvVei:nAt,01],oOkTik,oNoTik) ,;
								aPrvVei[oLstPrvVei:nAt,02] ,;
								aPrvVei[oLstPrvVei:nAt,03] ,;
								aPrvVei[oLstPrvVei:nAt,04]+" - "+aPrvVei[oLstPrvVei:nAt,07] ,;
								Transform(aPrvVei[oLstPrvVei:nAt,05],"@D")+" ( "+FG_CDOW(aPrvVei[oLstPrvVei:nAt,05])+" )" ,;
								strzero(aPrvVei[oLstPrvVei:nAt,06],2)+"h" ,;
								aPrvVei[oLstPrvVei:nAt,09] }}
	oLstPrvVei:Refresh()
	oLstPrvVei:SetFocus()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX006GRV º Autor ³ Andre Luis Almeida º Data ³  19/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao da Data de Entrega do Veiculo                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc   (3-Incluir/4-Alterar/5-Excluir)                     º±±
±±º          ³ cNumAte( Numero do Atendimento )                           º±±
±±º          ³ dDtSug ( Data Sugestao de Entrega )                        º±±
±±º          ³ dDtPrv ( Data Previsao de Entrega )                        º±±
±±º          ³ dDtRea ( Data Real de Entrega )                            º±±
±±º          ³ cMemo  ( Memo referente a Entrega )                        º±±
±±º          ³ nRecnoVVA ( Recno do VVA )                                 º±±
±±º          ³ nHrPrv ( Hora Previsao de Entrega )                        º±±
±±º          ³ cFiPrv ( Filial Previsao de Entrega )                      º±±
±±º          ³ cBoPrv ( Box Previsao de Entrega )                         º±±
±±º          ³ cUsPrv ( Usuario Previsao de Entrega )                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX006GRV(nOpc,cNumAte,dDtSug,dDtPrv,dDtRea,cMemo,nRecnoVVA,nHrPrv,cFiPrv,cBoPrv,cUsPrv)
Default dDtSug    := ctod("")
Default dDtPrv    := ctod("")
Default dDtRea    := ctod("")
Default cMemo     := ""
Default nRecnoVVA := 0
Default nHrPrv    := 0
Default cFiPrv    := ""
Default cBoPrv    := ""
Default cUsPrv    := ""
If nOpc == 3 .or. nOpc == 4 .or. nOpc == 5 // Incluir ou Alterar ou Excluir
	M->VVA_DTESUG := dDtSug // Preenche/Apaga Data de Entrega sugerida pelo sistema
	M->VVA_DTEPRV := dDtPrv // Preenche/Apaga Data de Entrega prevista pelo usuario (vendedor)
	M->VVA_DTEREA := dDtRea // Preenche/Apaga Data Real de Entrega
	M->VVA_HREPRV := nHrPrv // Preenche/Apaga Hora de Entrega prevista pelo usuario (vendedor)
	M->VVA_FIEPRV := cFiPrv // Preenche/Apaga Filial de Entrega prevista pelo usuario (vendedor)
	M->VVA_BOEPRV := cBoPrv // Preenche/Apaga Box de Entrega prevista pelo usuario (vendedor)
	M->VVA_USEPRV := cUsPrv // Preenche/Apaga Usuario de Entrega prevista pelo usuario (vendedor)
	If nRecnoVVA > 0
		DbSelectarea("VVA")
		DbGoTo(nRecnoVVA)
		RecLock("VVA",.f.)
			VVA->VVA_DTESUG := dDtSug // Preenche/Apaga Data de Entrega sugerida pelo sistema
			VVA->VVA_DTEPRV := dDtPrv // Preenche/Apaga Data de Entrega prevista pelo usuario (vendedor)
			VVA->VVA_DTEREA := dDtRea // Preenche/Apaga Data Real de Entrega
			VVA->VVA_HREPRV := nHrPrv // Preenche/Apaga Hora de Entrega prevista pelo usuario (vendedor)
			VVA->VVA_FIEPRV := cFiPrv // Preenche/Apaga Filial de Entrega prevista pelo usuario (vendedor)
			VVA->VVA_BOEPRV := cBoPrv // Preenche/Apaga Box de Entrega prevista pelo usuario (vendedor)
			VVA->VVA_USEPRV := cUsPrv // Preenche/Apaga Usuario de Entrega prevista pelo usuario (vendedor)
			MSMM(VVA->VVA_ENTMEM,TamSx3("VVA_OBSENT")[1],,cMemo,1,,,"VVA","VVA_ENTMEM") // Preenche/Apaga Observacao
		MsUnlock()
	EndIf
	If IsInCallStack("VEIXX002")
		VX002ACOLS("VVA_DTESUG")
		VX002ACOLS("VVA_DTEPRV")
		VX002ACOLS("VVA_DTEREA")
		VX002ACOLS("VVA_HREPRV")
		VX002ACOLS("VVA_FIEPRV")
		VX002ACOLS("VVA_BOEPRV")
		VX002ACOLS("VVA_USEPRV")
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VXX006FD º Autor ³ Andre Luis Almeida º Data ³  04/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faturamento Direto - Previsao de Faturamento/Entrega       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc (2-Visualizar/3-Incluir/4-Alterar/5-Excluir)          º±±
±±º          ³ aVVA ( Vetor com os VVAs do Faturamento Direto )           º±±
±±º          ³ nLin ( Linha do vetor do VVA )                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Faturamento Direto                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX006FD(nOpc,aVVA,nLin)
Local aRet      := {}
Local aParambox := {}
Local clAlt     := IIf(nOpc==3.or.nOpc==4,".t.",".f.")
//////////////
// Parambox //
//////////////
AADD(aParambox,{1,STR0019+" - "+STR0007,aVVA[nLin,13],"@D","","",clAlt, 50,.f.}) // Data Faturamento
AADD(aParambox,{1,STR0020+" - "+STR0007,aVVA[nLin,14],"@D","","",clAlt, 50,.f.}) // Data Entrega
AADD(aParambox,{1,STR0020+" - "+STR0008,aVVA[nLin,15],"@E 99","MV_PAR03>=0.and.MV_PAR03<=23","",clAlt, 20,.f.}) // Hora Entrega
AADD(aParambox,{1,STR0020+" - "+STR0004,aVVA[nLin,16],"@!","","SM0_01",clAlt, 80,.f.}) // Filial Entrega
AADD(aParambox,{1,STR0020+" - "+STR0005,aVVA[nLin,17],"@!","","",clAlt, 20,.f.}) // Box Entrega
AADD(aParambox,{1,STR0020+" - "+STR0006,aVVA[nLin,18],"@!","","USR",clAlt, 40,.f.}) // Usuario Entrega
If ParamBox(aParambox,STR0021,@aRet,,,,,,,,.f.) // Previsao
	aVVA[nLin,13] := aRet[1] // Data Faturamento
	aVVA[nLin,14] := aRet[2] // Data Entrega
	aVVA[nLin,15] := aRet[3] // Data Entrega
	aVVA[nLin,16] := aRet[4] // Filial Entrega
	aVVA[nLin,17] := aRet[5] // Box Entrega
	aVVA[nLin,18] := aRet[6] // Usuario Entrega
EndIf
Return(aVVA)

