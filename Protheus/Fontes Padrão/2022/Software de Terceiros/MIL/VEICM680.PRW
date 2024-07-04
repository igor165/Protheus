// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 31     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICM680.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM680 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Oportunidade de Negocios                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM680(_cCodCli,_cLojCli,_cCdPros,_cLjPros,_lInclui,_cCodCEV)
Local aCliAux     := {}
Local nRecVDL     := 0
Local cNome       := ""
Private cCadastro := STR0001 // Oportunidade de Negocios
Private aRotina   := MenuDef()
Private nUsado    := 0
Private lVDM_OPCFAB := ( VDM->(FieldPos("VDM_OPCFAB")) > 0 )
//
Private aRelNOVOS := {} // Vetor utilizado para relacionar no momento da Gravacao os Interesses NOVOS com a Agenda CEV
//
Private aRecInter     := {}
Private cTipInter     := ""
Private oBrwVDM
//
Private lIncVDL       := .t.
//
/////////////////////////
Default _cCodCli      := ""
Default _cLojCli      := ""
Default _cCdPros      := ""
Default _cLjPros      := ""
Default _lInclui      := .f. // quando é chamado do VEICM500 e VEICM510 deve sempre incluir (.t.), mesmo se não houver Oportunidade
Default _cCodCEV      := ""
/////////////////////////
DbSelectArea("VDL")
If Empty(_cCodCli+_cLojCli+_cCdPros+_cLjPros) // SEM Cliente e SEM Prospect
	//
	FS_F7(.t.)
	//
	cAlias := "VDM"
	DbSelectArea("VDM")
	oBrwVDM:= FWMBrowse():New()
	oBrwVDM:SetAlias('VDM')
	oBrwVDM:SetDescription(STR0070) // Oportunidades/Interesses
	If !VCM680BrwAct(oBrwVDM,.t.,.t.)
		Return
	EndIf
	oBrwVDM:DisableDetails()
	oBrwVDM:Activate()
	//
	FS_F7(.f.)
	//
Else
	nOpc    := 2
	Inclui  := .f.
	Altera  := .f.	
	If !Empty(_cCodCli+_cLojCli) // Cliente
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))
		cNome   := SA1->A1_NOME 
		if GetNewPar("MV_MIL0069","0") == "0"
			nRecVDL := FM_SQL("SELECT VDL.R_E_C_N_O_ AS RECVDL FROM "+RetSqlName("VDL")+" VDL WHERE VDL.VDL_FILIAL='"+xFilial("VDL")+"' AND VDL.VDL_CODCLI='"+_cCodCli+"' AND VDL.VDL_LOJCLI='"+_cLojCli+"' AND VDL.D_E_L_E_T_=' '")
		Else          
			nRecVDL := 0
		Endif	
		If nRecVDL <= 0
			VCF->(DbSetOrder(1))
			VCF->(DbSeek(xFilial("VCF")+_cCodCli+_cLojCli))
			//
			DbSelectArea("VDL")
			RecLock("VDL",.t.)
				VDL->VDL_FILIAL := xFilial("VDL")
				VDL->VDL_CODOPO := GetSXENum("VDL","VDL_CODOPO")
				ConfirmSX8()
				VDL->VDL_CODCLI := _cCodCli
				VDL->VDL_LOJCLI := _cLojCli
				VDL->VDL_NOMCLI := SA1->A1_NOME
				VDL->VDL_DDDCLI := SA1->A1_DDD
				VDL->VDL_TELCLI := SA1->A1_TEL
				VDL->VDL_EMACLI := SA1->A1_EMAIL
				VDL->VDL_NIVIMP := VCF->VCF_NIVIMP
				if VDL->(fieldpos('VDL_DATINC')) > 0
					VDL->VDL_DATINC := FGX_Timestamp()
				endif
				if VDL->(fieldpos("VDL_UUID")) > 0
					VDL->VDL_UUID := FWUUIDV4(.t.)
				endif
			MsUnLock()
			nRecVDL := VDL->(RecNo())
		EndIf
	ElseIf !Empty(_cCdPros+_cLjPros) // Prospect
		SUS->(DbSetOrder(1))
		SUS->(DbSeek(xFilial("SUS")+_cCdPros+_cLjPros))
		cNome   := SUS->US_NOME
		if GetNewPar("MV_MIL0069","0") == "0"
			nRecVDL := FM_SQL("SELECT VDL.R_E_C_N_O_ AS RECVDL FROM "+RetSqlName("VDL")+" VDL WHERE VDL.VDL_FILIAL='"+xFilial("VDL")+"' AND VDL.VDL_CDPROS='"+_cCdPros+"' AND VDL.VDL_LJPROS='"+_cLjPros+"' AND VDL.D_E_L_E_T_=' '")
		Else
			nRecVDL := 0		
		Endif	
		If nRecVDL <= 0
			//
			DbSelectArea("VDL")
			RecLock("VDL",.t.)
				VDL->VDL_FILIAL := xFilial("VDL")
				VDL->VDL_CODOPO := GetSXENum("VDL","VDL_CODOPO")
				ConfirmSX8()
				VDL->VDL_CDPROS := _cCdPros
				VDL->VDL_LJPROS := _cLjPros
				VDL->VDL_NOMCLI := SUS->US_NOME
				VDL->VDL_DDDCLI := SUS->US_DDD
				if VDL->(FieldPos("VDL_UUID")) > 0
					VDL->VDL_UUID   := FwUUIDV4(.t.)
				endif
				VDL->VDL_TELCLI := SUS->US_TEL
				VDL->VDL_EMACLI := SUS->US_EMAIL
				if VDL->(fieldpos('VDL_DATINC')) > 0
					VDL->VDL_DATINC := FGX_Timestamp()
				endif
			MsUnLock()
			nRecVDL := VDL->(RecNo())
		EndIf
	EndIf
	VDL->(DbGoTo(nRecVDL))
	nOpc    := 4
	Altera  := .t.
	//
	aCliAux := {_cCodCli,_cLojCli,cNome,nOpc,nRecVDL,_cCdPros,_cLjPros}
	//
	VCM680("VDL",nRecVDL,nOpc,aCliAux,_lInclui,_cCodCEV)
	//
EndIf
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_F7    ³ Autor ³ Andre Luis Almeida    ³ Data ³ 17/03/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita o F7 ( Funil das Oportunidades )                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_F7(lHabilita)
If !IsInCallStack('OFIA120') // NAO for Oportunidades Agrupadas
	If lHabilita
		SetKey(VK_F7,{|| VCC680FUNIL() })
	Else
		SetKey(VK_F7, Nil )
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de Cadastro das Oportunidades de Negocios             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680(cAlias, nReg, nOpc, aAux, _lInclui, _cCodCEV)
Local aObjects  := {}, aPos := {}, aInfo := {}
Local aSizeHalf := MsAdvSize(.t.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local bCampo := { |nCPO| Field(nCPO) }, nCntFor := 0, _ni := 0
Local cTitulo, cAliasEnchoice, cAliasGetD, cLinOk, cFieldOk
Local nPosAcesso := 0
Local aAuxAcesso := {}
Local nVDMFILATE := 0
Local nVDMNUMATE := 0
Local nVDMITETRA := 0
Local nVDMSTAATE := 0
Local oFont1     := TFont():New(,9, 18,, .F.,,,,,,,,,,,)
Local lOkTela    := .f.
Local lFoundVDM  := .f.

Private cMotivo    := "000011" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
Private cFilCodMar := "" // Variavel uilizada no SXB do VV2SQL
Private aDelMotiv  := {}

Private aNewBot   := {}
Private nLenaCols := 0
Private aCols := {}, aHeader := {}, aCpoEnchoice := {}
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private aLimpaVDM := {}
Default aAux := {}
Default _lInclui := .f. // quando é chamado do VEICM500 e VEICM510 deve sempre incluir (.t.), mesmo se não houver Oportunidade
Default _cCodCEV := ""
//
If nOpc <> 3 .and. cAlias == "VDM"
	VDL->(MsSeek(VDM->VDM_FILIAL+VDM->VDM_CODOPO)) // Posicionar no Registro VDL (pai)
EndIf
//
FS_F7(.f.)
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcE := nOpc // 2-Visualizar / 3-Incluir / 4-Alterar
nOpcG := nOpc // 2-Visualizar / 3-Incluir / 4-Alterar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VDL", .T.)

aCpoEnchoice :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VDL")

While !Eof() .And. (x3_arquivo == "VDL")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel
		AADD(aCpoEnchoice, x3_campo)
		&("M->" + x3_campo) := CriaVar(x3_campo)
	EndIf
	dbSkip()
EndDo

If !(Inclui)
	DbSelectArea("VDL")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
	Next
EndIf

If len(aAux) > 0
	dbSelectArea("VDL")
	If aAux[5] > 0
		dbGoto(aAux[5])
		nOpcE := 2 // 2-Visualizar / 3-Incluir / 4-Alterar
	EndIf
EndIf

If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	If !lIncVDL // Se não incluir VDL deixar os campos com when .f.
		nOpcE := 2 // 2-Visualizar 
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := 0

dbSelectArea("SX3")
dbSeek("VDM")

aHeader := {}
aAlter  := {}
aRepl   := {}

While !Eof() .And. (x3_arquivo == "VDM")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(x3_campo $ "VDM_CODOPO/VDM_QTDINT/")
		nUsado := nUsado + 1
		aAdd(aHeader, { TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao })
		&("M->" + x3_campo) := CriaVar(x3_campo)

		If SX3->X3_VISUAL <> "V"
			Aadd(aAlter, SX3->X3_CAMPO)
		EndIf

		If ( SX3->X3_VISUAL <> "V" ) .Or. (SX3->X3_VISUAL == "V" .And.;
			!(x3_campo $ "VDM_CODOPO/VDM_CODINT/VDM_FILATE/VDM_NUMATE/VDM_ITETRA/VDM_STAATE/"))
			Aadd(aRepl, SX3->X3_CAMPO)
		EndIf
	EndIf

	dbSkip()
EndDo

dbSelectArea("VDM")
ADHeadRec("VDM", aHeader)

nUsado := Len(aHeader)

VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
If VAI->VAI_VABAON == "0"
	MsgStop(STR0054, STR0029) // Usuario sem permissao! / Atencao
	FS_F7(.t.)
	Return()
EndIf

aCols := {}

dbSelectArea("VDM")
dbSetOrder(1)

If dbSeek(xFilial("VDM") + M->VDL_CODOPO)
	lFoundVDM := .t.

	// Apenas rotinas VEICM500 e VEICM510 devem sempre carregar o aCols
	// Caso o aCols esteja em branco pela permissão para Visualização
	// Deve Incluir uma linha vazia
	If _lInclui
		OM680Acols(nOpc) // Carrega aCols com os Interesses de determinada Oportunidade
	EndIf
EndIf

If nOpc == 3 .Or. !lFoundVDM .Or. (_lInclui .And. Len(aCols) == 0)
	aCols := {Array(nUsado + 1)}
	aCols[1,nUsado + 1] := .F.	
	For _ni := 1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VDM"
		Else
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		EndIf
	Next
ElseIf !_lInclui // Demais rotinas e menu. Pode ter a aCols em branco.
	OM680Acols(nOpc) // Carrega aCols com os Interesses de determinada Oportunidade
EndIf

If Len(aCols) > 0
	If len(aLimpaVDM) > 0
		// Fator de reducao 80%
		For nCntFor := 1 to Len(aSizeHalf)
			aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.80)
		Next

		aInfo := { aSizeHalf[1], aSizeHalf[2],aSizeHalf[3] ,aSizeHalf[4], 3, 3 } // Tamanho total da tela

		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 0, 15, .T., .f. } ) // Problema
		AAdd( aObjects, { 0,  0, .T., .T. } ) // Interesses
		AAdd( aObjects, { 0, 15, .T., .f. } ) // Pergunta
		aPos := MsObjSize( aInfo, aObjects )

		lOkTela := .f.

		DEFINE MSDIALOG oVEICM680 TITLE STR0001 FROM aSizeHalf[7], 0 TO aSizeHalf[6], aSizeHalf[5] OF oMainWnd PIXEL // Oportunidade de Negocios

		@ aPos[1,1] + 003, aPos[1,2] + 003 SAY (STR0055) FONT oFont1 OF oVEICM680 PIXEL COLOR CLR_RED // Os Interesses abaixo estao relacionados a Itens excluidos no Atendimento 

		@ aPos[2,1], aPos[2,2] LISTBOX oLboxVDM FIELDS HEADER;
			STR0022, ; // Marca
			STR0023, ; // Modelo
			STR0024, ; // Cor
			STR0056, ; // Filial
			STR0057, ; // Atendimento
			STR0058, ; // Item
			STR0059 ;  // Status
			COLSIZES 25, 110, 70, 50, 40, 35, 50 SIZE aPos[2,4], aPos[2,3] - aPos[2,1] OF oVEICM680 PIXEL
			oLboxVDM:SetArray(aLimpaVDM)
			oLboxVDM:bLine := { || { aLimpaVDM[oLboxVDM:nAt,03],;
			aLimpaVDM[oLboxVDM:nAt,04],;
			aLimpaVDM[oLboxVDM:nAt,05],;
			aLimpaVDM[oLboxVDM:nAt,06],;
			aLimpaVDM[oLboxVDM:nAt,07],;
			aLimpaVDM[oLboxVDM:nAt,08],;
			aLimpaVDM[oLboxVDM:nAt,09]}}

		@ aPos[3,1] + 002, aPos[3,2] + 003 SAY (STR0060) FONT oFont1 OF oVEICM680 PIXEL COLOR CLR_RED // Deseja limpar os relacionamentos para utilizar os Interesses futuramente?

		ACTIVATE MSDIALOG oVEICM680 CENTER ON INIT (EnchoiceBar(oVEICM680, {|| lOkTela := .t., oVEICM680:End()}, {|| oVEICM680:End()},,))

		If lOkTela // Limpar relacionamento do VDM -> Sim
			For _ni := 1 to len(aLimpaVDM)
				DbSelectArea("VDM")
				DbGoTo(aLimpaVDM[_ni,1])

				RecLock("VDM", .f.)
				VDM->VDM_FILATE := ""
				VDM->VDM_NUMATE := ""
				If nVDMITETRA > 0
					VDM->VDM_ITETRA := ""
				EndIf
				if VDM->(fieldpos('VDM_DATALT')) > 0
					VDM->VDM_DATALT := FGX_Timestamp()
				endif
				MsUnLock()

				aCols[aLimpaVDM[_ni,2],nVDMFILATE] := M->VDM_FILATE := ""
				aCols[aLimpaVDM[_ni,2],nVDMNUMATE] := M->VDM_NUMATE := ""
				aCols[aLimpaVDM[_ni,2],nVDMSTAATE] := M->VDM_STAATE := ""

				If nVDMITETRA > 0
					aCols[aLimpaVDM[_ni,2],nVDMITETRA] := M->VDM_ITETRA := ""
				EndIf
			Next
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       := STR0001 // Oportunidade de Negocios
	cAliasEnchoice:= "VDL"
	cAliasGetD    := "VDM"
	cLinOk        := "FG_OBRIGAT()"
	cFieldOk      := "FG_MEMVAR().and.VCM680FOK()"
	//
	If (nOpcE == 3 .Or. nOpcE == 2) .And. len(aAux) > 0
		M->VDL_CODCLI := aAux[1] // Codigo Cliente
		M->VDL_LOJCLI := aAux[2] // Loja Cliente
		M->VDL_NOMCLI := aAux[3] // Nome
		M->VDL_CDPROS := aAux[6] // Codigo Prospect
		M->VDL_LJPROS := aAux[7] // Loja Prospect

		If !Empty(M->VDL_CODCLI + M->VDL_LOJCLI) // Cliente
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1") + M->VDL_CODCLI + M->VDL_LOJCLI))
				M->VDL_NOMCLI := SA1->A1_NOME
				If Empty(M->VDL_DDDCLI)
					M->VDL_DDDCLI := SA1->A1_DDD
				EndIf

				If Empty(M->VDL_TELCLI)
					M->VDL_TELCLI := SA1->A1_TEL
				EndIf

				If Empty(M->VDL_EMACLI)
					M->VDL_EMACLI := SA1->A1_EMAIL
				EndIf

				If Empty(M->VDL_NIVIMP)
					VCF->(dbSetOrder(1))
					If VCF->(dbSeek(xFilial("VCF") + M->VDL_CODCLI + M->VDL_LOJCLI))
						M->VDL_NIVIMP := VCF->VCF_NIVIMP
					EndIf
				EndIf
			EndIf
		ElseIf !Empty(M->VDL_CDPROS + M->VDL_LJPROS) // Prospect
			SUS->(dbSetOrder(1))
			If SUS->(dbSeek(xFilial("SUS") + M->VDL_CDPROS + M->VDL_LJPROS))
				M->VDL_NOMCLI := SUS->US_NOME
				If Empty(M->VDL_DDDCLI)
					M->VDL_DDDCLI := SUS->US_DDD
				EndIf

				If Empty(M->VDL_TELCLI)
					M->VDL_TELCLI := SUS->US_TEL
				EndIf

				If Empty(M->VDL_EMACLI)
					M->VDL_EMACLI := SUS->US_EMAIL
				EndIf
			EndIf
		EndIf
	EndIf

	If nOpcE > 0
		//
		VCM680Fx(nOpc,.T.)
		//
		If nOpc == 3 .or. nOpc == 4
			aAdd(aNewBot, {"PMSUSER", {|| VCM680Fx(nOpc, .F.), VCM680PROS(), VCM680Fx(nOpc, .T.)}, (STR0047)}) // Converter Prospect em Cliente
			aAdd(aNewBot, {"PCO_COINC", {|| VCM680Fx(nOpc, .F.), VCM680REPL(nOpc), VCM680Fx(nOpc, .T.)}, (STR0051 + " <F4>")}) // Replicar
			If Empty(_cCodCEV) // Se nao executado pelo CEV - pode gerar Agenda CEV
				aAdd(aNewBot, {"E5", {|| VCM680Fx(nOpc, .F.), VCM680041_GerarAgendaCEV({ 0 , M->VDM_CODVEN , M->VDL_CODCLI , M->VDL_LOJCLI , M->VDL_CDPROS , M->VDL_LJPROS , M->VDM_FILIAL , M->VDM_CODINT , M->VDM_CODMAR , M->VDM_MODVEI , M->VDM_UUID }) , VCM680Fx(nOpc, .T.)}, (STR0094)}) // Gerar Agenda CEV
			EndIf
		EndIf
		If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? 
			aAdd(aNewBot, {"PARAMETROS", {|| VCM680Fx(nOpc, .F.), VCM680061_SelecaoPacote(nOpc), VCM680Fx(nOpc, .T.)}, (STR0104 + " <F6>")}) // Pacote de Configuração
		EndIf
		aAdd(aNewBot, {"BMPVISUAL", {|| VCM680Fx(nOpc, .F.), VCM680VATE(), VCM680Fx(nOpc, .T.)}, (STR0041)}) // Visual.Atendimento
		aAdd(aNewBot, {"BANCOCON" , {|| VCM6800016_BancoDeConhecimento()},                       (STR0089)}) // Banco de Conhecimento
		If (ExistBlock("VCM680BOT")) // Ponto de Entrada para adicionar opções no Menu
			aNewBot := ExecBlock("VCM680BOT", .f., .f., {aNewBot})
		EndIf

		FM_Mod3(cTitulo, cAliasEnchoice, cAliasGetD, @aCpoEnchoice,, @aHeader, @aCols, cFieldOk, cLinOk;
			,,, nOpcE, nOpcG,, oMainWnd, @oAuxDlg, @oAuxEnchoice, @oAuxGetDados,,,,,,,, 40, aAlter)

		oAuxGetDados:oBrowse:bChange := {|| FG_MEMVAR(oAuxGetDados:aHeader, oAuxGetDados:aCols, oAuxGetDados:nAt), VCM680CHANGE()}
		oAuxGetDados:oBrowse:bDelete := {|| VCM680Fx(nOpc, .F.), VCM680DEL(), VCM680Fx(nOpc, .T.)}

		/////////////////////////////////////////////////////////////
		// Verificar se o usuario tem permissao para cadastrar SA1 //
		/////////////////////////////////////////////////////////////
		aAuxAcesso := FMX_LEVXNU(, "MATA030")
		nPosAcesso := aScan(aAuxAcesso, { |x| x[1] == "MATA030" })

		If nPosAcesso > 0 .And. SubStr(aAuxAcesso[nPosAcesso,2], 3, 1) == "x" // 3 = Inluir
			// Alterar F3 do campo "VDL_CODCLI" para possibilitar usuario cadastrar novo Cliente //
			oAuxEnchoice:oBox:Cargo[aScan(aCpoEnchoice, {|x| x == "VDL_CODCLI"})]:CF3 := "SA1" // SXB com o INCLUIR do SA1
		EndIf
		/////////////////////////////////////////////////////////////
		ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg, {|| IIF(VCM680Fx(nOpc, .F.) .And. VCM680TOK(nOpc);
			.And. VCM680GRV(nOpcG,.f.,"",_cCodCEV) .And. VCM680Fx(nOpc, .T.), oAuxDlg:End(), .f.) }, {|| oAuxDlg:End()},, aNewBot)
		//
		VCM680Fx(nOpc,.F.)
		//
		If Type("aRecInter") == "U"
			aRecInter := {}
		EndIf

		If len(aRecInter) > 0
			If cTipInter == "1"
				VXA018OPORT(aRecInter) // Abrir Atendimento com os Interesses desejados
			ElseIf cTipInter == "2"
				VXA030OPORT(aRecInter) // Abrir Faturamento Direto com os Interesses desejados
			EndIf

			aRecInter := {} // Limpar vetor para nao chamar novamente
		EndIf
		//
	Endif
	//
Else
	//
	MsgStop(STR0065,STR0029) // "Não existem Interesses relacionados ao código de vendedor do usuário logado!" / Atencao
	//
Endif
//
FS_F7(.t.)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680C  ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/06/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelamento da Oportunidade / Interesses                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680C(cAlias, nReg, nOpc)
Local aObjects  := {}, aPos := {}, aInfo := {}
Local aSizeHalf := MsAdvSize(.t.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local bCampo     := { |nCPO| Field(nCPO) }, nCntFor := 0
Local lAllInt    := .f.
Local nRecVDL    := 0
Local nRecVDM    := 0
Local cQuery     := ""
Local cQAlias    := "SQLVDM"
Local aMotCanc   := {}
Local aIntCanc   := {}
Local cCor       := "0"
Local lVDMSEGMOD := ( VDM->(FieldPos("VDM_SEGMOD")) > 0 )
Private oCor0    := LoadBitmap( GetResources() , "LBNO" )		// Disponivel para Selecao
Private oCor1    := LoadBitmap( GetResources() , "LBTIK" )		// Selecionado
Private oCor2    := LoadBitmap( GetResources() , "AVGOIC1" )	// Interesse com Atendimento relacionado
Private oCor3    := LoadBitmap( GetResources() , "LbOK" )		// Interesse ja Cancelado
//
VDL->(MsSeek(VDM->VDM_FILIAL+VDM->VDM_CODOPO)) // Posicionar no Registro VDL (pai)
nRecVDL := VDL->(RecNo())
nRecVDM := VDM->(RecNo())
//
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
//
FS_F7(.f.)
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VDL", .T.)
//
aCpoEnchoice :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VDL")
While !Eof() .And. (x3_arquivo == "VDL")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel
		AADD(aCpoEnchoice, x3_campo)
		&("M->" + x3_campo) := CriaVar(x3_campo)
	EndIf
	dbSkip()
EndDo
DbSelectArea("VDL")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
Next
//
cQuery := "SELECT VDM.VDM_MOTCAN , "
cQuery += "       VDM.VDM_NUMATE , "
cQuery += "       VDM.VDM_CAMPOP , "
cQuery += "       VDM.VDM_CODMAR , "
cQuery += "       VDM.VDM_MODVEI , VV2.VV2_DESMOD , "
cQuery += "       VDM.VDM_DATINT , "
cQuery += "       VDM.VDM_CODFAS , VDK.VDK_DESFAS , "
cQuery += "       VDM.VDM_CODVEN , SA3.A3_NOME , "
cQuery += "       VDM.R_E_C_N_O_ AS RECVDM "
cQuery += "FROM " + RetSqlName( "VDM" ) + " VDM "
If lVDMSEGMOD
	cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VDM.VDM_CODMAR AND VV2.VV2_MODVEI=VDM.VDM_MODVEI AND VV2.VV2_SEGMOD=VDM.VDM_SEGMOD AND VV2.D_E_L_E_T_=' ' "
Else
	cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VDM.VDM_CODMAR AND VV2.VV2_MODVEI=VDM.VDM_MODVEI AND VV2.D_E_L_E_T_=' ' "
EndIf
cQuery += "LEFT JOIN "+RetSqlName("VDK")+" VDK ON VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_CODFAS=VDM.VDM_CODFAS AND VDK.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON SA3.A3_FILIAL='"+xFilial("SA3")+"'  AND SA3.A3_COD=VDM.VDM_CODVEN     AND SA3.D_E_L_E_T_=' ' "
cQuery += "WHERE VDM.VDM_FILIAL = '" + xFilial("VDM") + "'"
cQuery += "  AND VDM.VDM_CODOPO = '" + VDL->VDL_CODOPO + "'"
If VAI->VAI_VABAON == "0" // Nao Mostrar / Levantar
	cQuery += "  AND VDM.VDM_CODVEN = 'NAO_LEVANTAR' "
ElseIf VAI->VAI_VABAON == "1" // Vendedor em branco ou Somente o Vendedor Logado
	cQuery += "  AND ( VDM.VDM_CODVEN = ' ' OR VDM.VDM_CODVEN = '"+VAI->VAI_CODVEN+"' ) "
EndIf
cQuery += "  AND VDM.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
Do While !( cQAlias )->( Eof() )
	cCor := "0"
	If !Empty(( cQAlias )->( VDM_MOTCAN ))
		cCor := "3"
	ElseIf !Empty(( cQAlias )->( VDM_NUMATE ))
		cCor := "2"
	Else
		If nRecVDM == ( cQAlias )->( RECVDM )
			cCor := "1"
		EndIf
	EndIf
	aAdd(aIntCanc,{	cCor ,;
					( cQAlias )->( VDM_CAMPOP ) ,;
					( cQAlias )->( VDM_CODMAR ) ,;
					Alltrim(( cQAlias )->( VDM_MODVEI )) +" - " + ( cQAlias )->( VV2_DESMOD ) ,;
					stod(( cQAlias )->( VDM_DATINT )) ,;
					( cQAlias )->( VDM_CODFAS ) +" - "+ ( cQAlias )->( VDK_DESFAS ) ,;
					( cQAlias )->( VDM_CODVEN ) +" - "+ ( cQAlias )->( A3_NOME ) ,;
					( cQAlias )->( RECVDM )  ,;
					nRecVDL  })
	( cQAlias )->(dbSkip())
Enddo
( cQAlias )->( dbCloseArea() )
dbSelectArea("VDM")
If len(aIntCanc) == 0
	aAdd(aIntCanc,{ "0" , "" , "" , "" , ctod() , "" , "" , 0 })
EndIf
//
aInfo := { aSizeHalf[1], aSizeHalf[2],aSizeHalf[3] ,aSizeHalf[4], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 100, .T., .f. } ) // Enchoice VDL
AAdd( aObjects, { 0,  08, .T., .f. } ) // Motivo Geral
AAdd( aObjects, { 0,   0, .T., .T. } ) // Selecionar os Interesses
aPos := MsObjSize( aInfo, aObjects )
//
DEFINE MSDIALOG oVEICM680 TITLE (STR0001+" - "+STR0071) FROM aSizeHalf[7], 0 TO aSizeHalf[6], aSizeHalf[5] OF oMainWnd PIXEL // Oportunidade de Negocios / Cancelar

oEnchVDL := MSMGet():New( "VDL", VDL->(RecNo()) , 2 ,;
	/* aCRA */, /* cLetra */, /* cTexto */, aCpoEnchoice, { aPos[1,1] , aPos[1,2] , aPos[1,3] , aPos[1,4] } , {} , 3 ,;
	/* nColMens */, /* cMensagem */, /*cTudoOk*/, oVEICM680, .f., .t., .t. /* lColumn */ ,;
	"", .f. /* lNoFolder */, .f.)

@ aPos[2,1],aPos[2,2] SAY STR0072 SIZE 200,10 OF oVEICM680 PIXEL COLOR CLR_BLUE // Selecione todos os Interesses que se deseja Cancelar

@ aPos[2,1],aPos[2,4]-358 BITMAP oxNO   RESOURCE "LBNO" OF oVEICM680 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[2,1],aPos[2,4]-350 SAY STR0073 SIZE 100,8 OF oVEICM680 PIXEL COLOR CLR_BLUE // Não Selecionado
@ aPos[2,1],aPos[2,4]-285 BITMAP oxTIK  RESOURCE "LBTIK" OF oVEICM680 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[2,1],aPos[2,4]-277 SAY STR0074 SIZE 100,8 OF oVEICM680 PIXEL COLOR CLR_BLUE // Selecionado para Cancelamento
@ aPos[2,1],aPos[2,4]-175 BITMAP oxCANC RESOURCE "LbOK" OF oVEICM680 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[2,1],aPos[2,4]-167 SAY STR0075 SIZE 100,8 OF oVEICM680 PIXEL COLOR CLR_BLUE // Interesse já Cancelado
@ aPos[2,1],aPos[2,4]-088 BITMAP oxATEN RESOURCE "AVGOIC1" OF oVEICM680 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[2,1],aPos[2,4]-080 SAY STR0076 SIZE 100,8 OF oVEICM680 PIXEL COLOR CLR_BLUE // Interesse com Atendimento

// LISTBOX Interesses
oLbIntCanc := TWBrowse():New( aPos[3,1] , aPos[3,2] , aPos[3,4] , aPos[3,3]-aPos[3,1],,,,oVEICM680,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
oLbIntCanc:addColumn( TCColumn():New( ""       , { || &("oCor"+aIntCanc[oLbIntCanc:nAt,01]) }     ,,,, "LEFT" ,  08 ,.T.,.F.,,,,.F.,) ) // selecionar
oLbIntCanc:addColumn( TCColumn():new( RetTitle("VDM_CAMPOP") , { || aIntCanc[oLbIntCanc:nAt,02] } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) )
oLbIntCanc:addColumn( TCColumn():new( RetTitle("VDM_CODMAR") , { || aIntCanc[oLbIntCanc:nAt,03] } ,,,, "LEFT" ,  30 ,.F.,.F.,,,,.F.,) )
oLbIntCanc:addColumn( TCColumn():new( RetTitle("VDM_MODVEI") , { || aIntCanc[oLbIntCanc:nAt,04] } ,,,, "LEFT" , 120 ,.F.,.F.,,,,.F.,) )
oLbIntCanc:addColumn( TCColumn():new( RetTitle("VDM_DATINT") , { || Transform(aIntCanc[oLbIntCanc:nAt,05],"@D") } ,,,, "LEFT" ,  45 ,.F.,.F.,,,,.F.,) )
oLbIntCanc:addColumn( TCColumn():new( RetTitle("VDM_CODFAS") , { || aIntCanc[oLbIntCanc:nAt,06] } ,,,, "LEFT" , 120 ,.F.,.F.,,,,.F.,) )
oLbIntCanc:addColumn( TCColumn():new( RetTitle("VDM_CODVEN") , { || aIntCanc[oLbIntCanc:nAt,07] } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) )
oLbIntCanc:nAt := 1
oLbIntCanc:setArray( aIntCanc )
oLbIntCanc:bLDblClick   := { || FS_TIKCanc(@aIntCanc) }
oLbIntCanc:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lAllInt := !lAllInt , aEval(aIntCanc,{|x| x[1] := IIf(x[1]$"01".and.x[8]>0,IIf(lAllInt,"1","0"),x[1]) }) , oLbIntCanc:Refresh() ) , .t. ) , }

ACTIVATE MSDIALOG oVEICM680 CENTER ON INIT (EnchoiceBar(oVEICM680, {|| IIf( FS_MOTCAN(aIntCanc,@aMotCanc) , oVEICM680:End() , .t. ) }, {|| oVEICM680:End()},,))
//
 // Filtro da consulta do motivo de Cancelamentos ( 000011 = Oportunidade )
If len(aMotCanc) > 0
	VCM680043_GravaCancelamento(aMotCanc, aIntCanc)
EndIf
//
FS_F7(.t.)
//
Return

Function VCM680043_GravaCancelamento(aMotCanc, aIntCanc)
	Local nCntFor := 0
	Local lVCM680GH  := ExistBlock("VCM680GH")
	Local aCpos      := {}
	Local aVldCpos   := {}
	Local lVDN_CODOPO := ( VDN->(FieldPos("VDN_CODOPO")) > 0 )
	Local nX         := 0


	If lVCM680GH // Campos do VDM a serem gravados nos Historicos
		aCpos := ExecBlock("VCM680GH",.f.,.f.) // Retorno do PE "VCM680GH" deve ser um Vetor ( aCpos )
		// aCpos[1] = Campos do VDM a serem gravados nos Historicos das Fases do Interesse
		// aCpos[2] = Campos do VDM a serem gravados nos Historicos das Fases de Financiamento
		If ValType(aCpos) <> "A"
			aCpos := {,}
		EndIf
		aVldCpos := aClone(aCpos)
		aCpos := {{},{}}
		If len(aVldCpos) >= 1
			For nX := 1 to len(aVldCpos[1])
				If VDM->(FieldPos(aVldCpos[1,nX])) > 0
					aAdd(aCpos[1],aVldCpos[1,nX])
				EndIf
			Next
		EndIf
	EndIf

	Begin Transaction

	For nCntFor := 1 to len(aIntCanc)
	
		If aIntCanc[nCntFor,1] == "1" // Selecionado para Cancelamento

			DbSelectArea("VDM")
			DbGoTo( aIntCanc[nCntFor,8] )
			RecLock("VDM",.f.)
				VDM->VDM_MOTCAN := aMotCanc[1]
				if VDM->(fieldpos('VDM_DATALT')) > 0
					VDM->VDM_DATALT := FGX_Timestamp()
				endif
			MsUnLock()

			///////////////////////////////////
			// Gravar Motivo de Cancelamento //
			///////////////////////////////////
			OFA210VDT("000011",aMotCanc[1],"6",VDM->VDM_FILIAL,VDM->VDM_CODINT,aMotCanc[4])

			DbSelectArea("VDL")
			DbGoTo( aIntCanc[nCntFor,9] )

			DbSelectArea("VDN")
			RecLock("VDN",.t.)
			VDN->VDN_FILIAL := xFilial("VDN")
			VDN->VDN_CODHIS := GetSXENum("VDN","VDN_CODHIS")
			VDN->VDN_TIPHIS := "1"
			If lVDN_CODOPO
				VDN->VDN_CODOPO := VDM->VDM_CODOPO
			EndIf

			if VDL->(fieldpos('VDL_DATINC')) > 0
				VDL->VDL_DATINC := FGX_Timestamp()
			endif
			VDN->VDN_CODINT := VDM->VDM_CODINT
			VDN->VDN_CODFAS := VDM->VDM_CODFAS
			VDN->VDN_CODCLI := VDL->VDL_CODCLI
			VDN->VDN_LOJCLI := VDL->VDL_LOJCLI
			VDN->VDN_NOMCLI := VDL->VDL_NOMCLI
			VDN->VDN_CDPROS := VDL->VDL_CDPROS
			VDN->VDN_LJPROS := VDL->VDL_LJPROS
			VDN->VDN_MOTCAN := VDM->VDM_MOTCAN
			VDN->VDN_CODVEN := VDM->VDM_CODVEN
			VDN->VDN_VLRMON := VDM->VDM_VLRMON
			VDN->VDN_VLROFE := VDM->VDM_VLROFE
			VDN->VDN_VLRCLI := VDM->VDM_VLRCLI
			VDN->VDN_VLRVDA := VDM->VDM_VLRVDA
			VDN->VDN_DATVDA := VDM->VDM_DATVDA
			VDN->VDN_VLRCOM := VDM->VDM_VLRCOM
			VDN->VDN_QTDUSA := VDM->VDM_QTDUSA
			VDN->VDN_VLRUSA := VDM->VDM_VLRUSA
			VDN->VDN_DECVDA := VDM->VDM_DECVDA
			VDN->VDN_DATHIS := dDataBase
			VDN->VDN_HORHIS := val(substr(Time(),1,2)+substr(Time(),4,2))
			VDN->VDN_USUHIS := __cUserId
			VDN->VDN_OBSERV := STR0077 // Cancelamento
			If lVCM680GH // Campos do VDM a serem gravados nos Historicos das Fases do Interesse
				If len(aCpos) > 0 .and. len(aCpos[1]) > 0
					For nX := 1 to len(aCpos[1])
						&("VDN->VDN_"+substr(aCpos[1,nX],5)) := &("VDM->"+aCpos[1,nX]) 
					Next
				EndIf
			EndIf
			MsUnlock()
			ConfirmSX8()
			//
		EndIf
	Next

	End Transaction

Return

/*/{Protheus.doc} FS_TIKCanc
Tik para selecao do Interesse na Tela de Cancelamento

@author Andre
@since 12/06/2018

@type function
/*/
Static Function FS_TIKCanc(aIntCanc)
If aIntCanc[oLbIntCanc:nAt,8] > 0 // Com RECNO()
	Do Case
		Case aIntCanc[oLbIntCanc:nAt,1] == "0"
			aIntCanc[oLbIntCanc:nAt,1] := "1" // Selecionar
		Case aIntCanc[oLbIntCanc:nAt,1] == "1"
			aIntCanc[oLbIntCanc:nAt,1] := "0" // Tirar Selecao
		Case aIntCanc[oLbIntCanc:nAt,1] == "2"
			MsgAlert(STR0078,STR0029) // Impossivel selecionar este Interesse, pois o mesmo já possui Atendimento vinculado. / Atencao
		Case aIntCanc[oLbIntCanc:nAt,1] == "3"
			MsgAlert(STR0079,STR0029) // Impossivel selecionar este Interesse, pois o mesmo já esta Cancelado. / Atencao
	EndCase
EndIf
Return

/*/{Protheus.doc} FS_MOTCAN
Escolha do Motivo do Cancelamento para todos os Interesses selecionados

@author Andre
@since 12/06/2018

@type function
/*/
Static Function FS_MOTCAN(aIntCanc,aMotCanc)
Local lRet := .f.
Local lOk  := .f.
Local ni   := 0
For ni := 1 to len(aIntCanc)
	If aIntCanc[ni,1] == "1"
		lOk := .t.
		Exit
	EndIf
Next
If lOk
	aMotCanc := OFA210MOT("000011","6","","",.f.)
	If len(aMotCanc) > 0
		lRet := .t.
	EndIf
Else
	MsgAlert(STR0080,STR0029) // Favor selecionar um ou mais Interesses para o Cancelamento. / Atencao
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680Fx ³ Autor ³  Andre Luis Almeida        ³ Data ³ 01/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seta teclas F4/F6 ( replicar linha aCols / selecao pacote )     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680Fx(nOpc,lFx)
If lFx 
	If ( nOpc == 3 .or. nOpc == 4 )
		SetKey(VK_F4,{|| VCM680REPL(nOpc) })
	EndIf
 	If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? 
		SetKey(VK_F6,{|| VCM680061_SelecaoPacote(nOpc) })
	EndIf
Else
	If ( nOpc == 3 .or. nOpc == 4 )
		SetKey(VK_F4, Nil )
	EndIf
	If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? 
		SetKey(VK_F6, Nil )
	EndIf
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680Fx ³ Autor ³  Andre Luis Almeida        ³ Data ³ 01/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seta tecla F4 (replicar linha aCols)                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680REPL(nOpc)
Local aRet      := {}
Local aParamBox := {}
Local ni        := 0
Local nX        := 0
Local nLinha    := 0
VCM680Fx(nOpc,.F.)
AADD(aParamBox,{1,STR0052,1,"@R 999","MV_PAR01>0","",".T.",50,.f.}) // Qtd. a Replicar
If ParamBox(aParamBox,STR0051+" <F4>",@aRet,,,,,,,,.f.) // Replicar
	For ni := 1 to aRet[1]
		AADD(oAuxGetDados:aCols,Array(len(aHeader)+1))
		nLinha := len(oAuxGetDados:aCols)
		For nX := 1 to len(aHeader)
			If ascan(aRepl,aHeader[nX,2]) > 0 // Somente os campos que podem ser replicados
				oAuxGetDados:aCols[nLinha,nX] := oAuxGetDados:aCols[oAuxGetDados:nAt,nX]
			Else
				&& verifica se e a coluna de controle do walk-thru
				If IsHeadRec(aHeader[nX,2])
					oAuxGetDados:aCols[nLinha,nX] := 0
				ElseIf IsHeadAlias(aHeader[nX,2])
					oAuxGetDados:aCols[nLinha,nX] := "VDM"
				Else
					oAuxGetDados:aCols[nLinha,nX] := CriaVar(aHeader[nX,2])
				EndIf
			EndIf
			&("M->"+aHeader[nX,2]) := oAuxGetDados:aCols[nLinha,nX]
		Next		
		oAuxGetDados:aCols[nLinha,len(aHeader)+1] := .F.
	Next
	oAuxGetDados:Refresh()
EndIf
VCM680Fx(nOpc,.T.)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM680PROS³ Autor ³  Andre Luis Almeida        ³ Data ³ 25/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Converter Prospect em Cliente                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680PROS()
If FGX_SUSSA1(M->VDL_CDPROS,M->VDL_LJPROS,.f.,.t.)
	M->VDL_CODCLI := SUS->US_CODCLI
	M->VDL_LOJCLI := SUS->US_LOJACLI
	M->VDL_CDPROS := space(TamSX3("VDL_CDPROS")[1])
	M->VDL_LJPROS := space(TamSX3("VDL_LJPROS")[1])
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680TOK³ Autor ³ Andre Luis Almeida    ³ Data ³ 16/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tudo Ok janela                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680TOK(nOpc)
Local lRet        := .t.
Local ni          := 0
Local nj          := 0
Local lVDK_OBRCLI := ( VDK->(FieldPos("VDK_OBRCLI")) > 0 )   
Local nRecSA1     := 0
if nOpc == 3 .or. nOpc == 4
	If !Empty(M->VDL_CODCLI+M->VDL_LOJCLI) // Cliente
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1")+M->VDL_CODCLI+M->VDL_LOJCLI))
			MsgStop(STR0031+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0008+": "+M->VDL_CODCLI+CHR(13)+CHR(10)+STR0009+": "+M->VDL_LOJCLI,STR0029) // Cliente informado nao encontrado no cadastro de clientes! / Codigo / Loja / Atencao
			lRet := .f.
		EndIf
	ElseIf !Empty(M->VDL_CDPROS+M->VDL_LJPROS) // Prospect
		SUS->(dbSetOrder(1))
		If !SUS->(dbSeek(xFilial("SUS")+M->VDL_CDPROS+M->VDL_LJPROS))
			MsgStop(STR0044+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0008+": "+M->VDL_CDPROS+CHR(13)+CHR(10)+STR0009+": "+M->VDL_LJPROS,STR0029) // Prospect informado nao encontrado no cadastro de prospects! / Codigo / Loja / Atencao
			lRet := .f.
		Else
			If !Empty(SUS->US_CODCLI+SUS->US_LOJACLI) // Verificar se ja existe o Cliente SA1
				MsgInfo(STR0049,STR0029) // Este Prospect já foi convertido para Cliente! / Atencao
				M->VDL_CODCLI := SUS->US_CODCLI
				M->VDL_LOJCLI := SUS->US_LOJACLI
				nRecSA1 := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VDL_CODCLI+"' AND A1_LOJA='"+M->VDL_LOJCLI+"' AND D_E_L_E_T_=' '")
				If nRecSA1 > 0 // Existe Cliente
					DbSelectArea("SA1")
					DbGoTo(nRecSA1)
					M->VDL_NOMCLI := SA1->A1_NOME
					M->VDL_DDDCLI := SA1->A1_DDD
					M->VDL_TELCLI := SA1->A1_TEL
					M->VDL_EMACLI := SA1->A1_EMAIL
				EndIf
				M->VDL_CDPROS := space(TamSX3("VDL_CDPROS")[1])
				M->VDL_LJPROS := space(TamSX3("VDL_LJPROS")[1])
			EndIf
		EndIf
	Else
//		MsgStop(STR0045,STR0029) // Necessario selecionar um Cliente ou Prospect! / Atencao
//		lRet := .f.
	EndIf
	If lRet
		For ni := 1 to Len(aCpoEnchoice) // Verifica campos obrigatorios
			If X3Obrigat(aCpoEnchoice[ni]) .and. Empty(&("M->"+aCpoEnchoice[ni]))
				Help(" ",1,"OBRIGAT",,RetTitle(aCpoEnchoice[ni])+space(50),3,0 )
				lRet := .f.
				Exit
			EndIf
		Next
	EndIf
	If lRet
		VDK->(DbSetOrder(1))
		For ni := 1 to len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[ni,Len(oAuxGetDados:aCols[ni])]
				If lVDK_OBRCLI .and. Empty(M->VDL_CODCLI+M->VDL_LOJCLI)
					If VDK->(MsSeek(xFilial("VDK")+oAuxGetDados:aCols[ni,FG_POSVAR("VDM_CODFAS")])) .and. VDK->VDK_OBRCLI == "1" // Cliente eh obrigatorio
						If MsgYesNo(STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0018+": "+oAuxGetDados:aCols[ni,FG_POSVAR("VDM_CODFAS")]+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0048,STR0029) // Os dados do cliente (Codigo Cliente / Loja) sao necessarios para a proxima fase da oportunidade! / Fase / Deseja converter o Prospect em Cliente? / Atencao
							VCM680PROS() // Converter Prospect em Cliente
						Else
							lRet := .f.
							Exit
						EndIf
					EndIf
				EndIf	
				For nj := 1 to len(aHeader)
					If X3Obrigat(aHeader[nj,2]) .and. Empty(oAuxGetDados:aCols[ni,FG_POSVAR(aHeader[nj,2])])
						Help(" ",1,"OBRIGAT",,RetTitle(aHeader[nj,2])+space(50),3,0 )
						lRet := .f.
						Exit
					EndIf
				Next
				If !lRet
					Exit
				EndIf
			EndIf
		Next
	EndIf    
	if lRet .and. ExistBlock("VCM680OK")
		lRet := ExecBlock("VCM680OK",.f.,.f.)
    Endif
Endif	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680FOK³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ FieldOk                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680FOK(cRVar)
Local lRet    := .t.
Local nRecSUS := 0
Local nRecSA1 := 0
Local lVDMSEGMOD := ( VDM->(FieldPos("VDM_SEGMOD")) > 0 )
Local lVDMCODPAC := ( VDM->(FieldPos("VDM_CODPAC")) > 0 )
Local lVDMBASCOD := ( VDM->(FieldPos("VDM_BASCOD")) > 0 )
Default cRVar := ReadVar()
Do Case
	Case cRVar == "M->VDL_CODCLI" .or. cRVar == "M->VDL_LOJCLI"
		If !Empty(M->VDL_CODCLI+M->VDL_LOJCLI)
			M->VDL_CDPROS := space(TamSX3("VDL_CDPROS")[1])
			M->VDL_LJPROS := space(TamSX3("VDL_LJPROS")[1])
			nRecSA1 := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VDL_CODCLI+"'"+IIf(!Empty(M->VDL_LOJCLI)," AND A1_LOJA='"+M->VDL_LOJCLI+"' ","")+" AND D_E_L_E_T_=' '")
			If nRecSA1 > 0 // Existe Cliente
				DbSelectArea("SA1")
				DbGoTo(nRecSA1)
				M->VDL_LOJCLI := padr(SA1->A1_LOJA ,TamSX3("VDL_LOJCLI")[1])
				M->VDL_NOMCLI := padr(SA1->A1_NOME ,TamSX3("VDL_NOMCLI")[1])
				M->VDL_DDDCLI := padr(SA1->A1_DDD  ,TamSX3("VDL_DDDCLI")[1])
				M->VDL_TELCLI := padr(SA1->A1_TEL  ,TamSX3("VDL_TELCLI")[1])
				M->VDL_EMACLI := padr(SA1->A1_EMAIL,TamSX3("VDL_EMACLI")[1])
			EndIf
		EndIf
	Case cRVar == "M->VDL_CDPROS" .or. cRVar == "M->VDL_LJPROS"
		If !Empty(M->VDL_CDPROS+M->VDL_LJPROS)
			M->VDL_CODCLI := space(TamSX3("VDL_CODCLI")[1])
			M->VDL_LOJCLI := space(TamSX3("VDL_LOJCLI")[1])
			nRecSUS := FM_SQL("SELECT R_E_C_N_O_ AS RECSUS FROM "+RetSQLName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+M->VDL_CDPROS+"'"+IIf(!Empty(M->VDL_LJPROS)," AND US_LOJA='"+M->VDL_LJPROS+"' ","")+" AND D_E_L_E_T_=' '")
			If nRecSUS > 0 // Existe Prospect
				DbSelectArea("SUS")
				DbGoTo(nRecSUS)
				M->VDL_LJPROS := padr(SUS->US_LOJA ,TamSX3("VDL_LOJCLI")[1])
				M->VDL_NOMCLI := padr(SUS->US_NOME ,TamSX3("VDL_NOMCLI")[1])
				M->VDL_DDDCLI := padr(SUS->US_DDD  ,TamSX3("VDL_DDDCLI")[1])
				M->VDL_TELCLI := padr(SUS->US_TEL  ,TamSX3("VDL_TELCLI")[1])
				M->VDL_EMACLI := padr(SUS->US_EMAIL,TamSX3("VDL_EMACLI")[1])
				If !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
					MsgInfo(STR0049,STR0029) // Este Prospect já foi convertido para Cliente! / Atencao
					M->VDL_CODCLI := SUS->US_CODCLI
					M->VDL_LOJCLI := SUS->US_LOJACLI
					nRecSA1 := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VDL_CODCLI+"' AND A1_LOJA='"+M->VDL_LOJCLI+"' AND D_E_L_E_T_=' '")
					If nRecSA1 > 0 // Existe Cliente
						DbSelectArea("SA1")
						DbGoTo(nRecSA1)
						M->VDL_NOMCLI := padr(SA1->A1_NOME ,TamSX3("VDL_NOMCLI")[1])
						M->VDL_DDDCLI := padr(SA1->A1_DDD  ,TamSX3("VDL_DDDCLI")[1])
						M->VDL_TELCLI := padr(SA1->A1_TEL  ,TamSX3("VDL_TELCLI")[1])
						M->VDL_EMACLI := padr(SA1->A1_EMAIL,TamSX3("VDL_EMACLI")[1])
					EndIf
					M->VDL_CDPROS := space(TamSX3("VDL_CDPROS")[1])
					M->VDL_LJPROS := space(TamSX3("VDL_LJPROS")[1])
				EndIf
			EndIf
		EndIf
	Case cRVar == "M->VDL_NOMCLI"
		If !Empty(M->VDL_CODCLI+M->VDL_LOJCLI)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA1") + M->VDL_CODCLI + M->VDL_LOJCLI ) .or. "["+SA1->A1_NOME+"]" <> "["+M->VDL_NOMCLI+"]"
				M->VDL_CODCLI := space(TamSX3("VDL_CODCLI")[1])
				M->VDL_LOJCLI := space(TamSX3("VDL_LOJCLI")[1])
				M->VDL_DDDCLI := space(TamSX3("VDL_DDDCLI")[1])
				M->VDL_TELCLI := space(TamSX3("VDL_TELCLI")[1])
				M->VDL_EMACLI := space(TamSX3("VDL_EMACLI")[1])
			EndIf
		ElseIf !Empty(M->VDL_CDPROS+M->VDL_LJPROS)
			DbSelectArea("SUS")
			DbSetOrder(1)
			If !DbSeek( xFilial("SUS") + M->VDL_CDPROS + M->VDL_LJPROS ) .or. "["+SUS->US_NOME+"]" <> "["+M->VDL_NOMCLI+"]"
				M->VDL_CDPROS := space(TamSX3("VDL_CODCLI")[1])
				M->VDL_LJPROS := space(TamSX3("VDL_LOJCLI")[1])
				M->VDL_DDDCLI := space(TamSX3("VDL_DDDCLI")[1])
				M->VDL_TELCLI := space(TamSX3("VDL_TELCLI")[1])
				M->VDL_EMACLI := space(TamSX3("VDL_EMACLI")[1])
			EndIf
		EndIf
	Case cRVar == "M->VDM_DATINT"
		M->VDM_DATLIM := M->VDM_DATINT
	Case cRVar == "M->VDM_CODMAR"
		cFilCodMar := M->VDM_CODMAR
		M->VDM_MODVEI := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_MODVEI")] := space(TamSX3("VDM_MODVEI")[1])
		M->VDM_CORVEI := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_CORVEI")] := space(TamSX3("VDM_CORVEI")[1])
		If lVDMSEGMOD
			M->VDM_SEGMOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_SEGMOD")] := space(GetSX3Cache("VDM_SEGMOD","X3_TAMANHO"))
		EndIf
		If lVDMCODPAC
			M->VDM_CODPAC := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_CODPAC")] := space(GetSX3Cache("VDM_CODPAC","X3_TAMANHO"))
		EndIf
		If lVDMBASCOD
			M->VDM_BASCOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_BASCOD")] := space(GetSX3Cache("VDM_BASCOD","X3_TAMANHO"))
		EndIf
	Case cRVar == "M->VDM_MODVEI"
		If lVDMSEGMOD
			M->VDM_SEGMOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_SEGMOD")] := space(GetSX3Cache("VDM_SEGMOD","X3_TAMANHO"))
		EndIf
		If lVDMCODPAC
			M->VDM_CODPAC := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_CODPAC")] := space(GetSX3Cache("VDM_CODPAC","X3_TAMANHO"))
		EndIf
		If lVDMBASCOD
			M->VDM_BASCOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_BASCOD")] := space(GetSX3Cache("VDM_BASCOD","X3_TAMANHO"))
		EndIf
	Case cRVar == "M->VDM_SEGMOD"
		If lVDMCODPAC
			M->VDM_CODPAC := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_CODPAC")] := space(GetSX3Cache("VDM_CODPAC","X3_TAMANHO"))
		EndIf
		If lVDMBASCOD 
			M->VDM_BASCOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_BASCOD")] := space(GetSX3Cache("VDM_BASCOD","X3_TAMANHO"))
		EndIf
EndCase
If ExistBlock("VCM680COK")
	lRet := ExecBlock("VCM680COK",.f.,.f.,{cRVar})
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680GRV³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680GRV(nOpc,lFaseAuto,cFaseAuto,_cCodCEV)
Local lVDN_CODOPO := ( VDN->(ColumnPos("VDN_CODOPO")) > 0 )
Local lVDM_UUID   := ( VDM->(ColumnPos("VDM_UUID")) > 0 )
Local cAuxCodC  := ""
Local cAuxLojC  := ""
Local cAuxNomC  := ""
Local cAuxCdPC  := ""
Local cAuxLjPC  := ""
local cAuxTmp   := ""
Local ix1       := 0
Local ix2       := 0
Local nX        := 0
Local lVCM680GH := ExistBlock("VCM680GH")
Local aCpos     := {}
Local aVldCpos  := {}
local lNewSync   := .f.
Private lMsHelpAuto := .t., lMsFinalAuto := .f.
Default lFaseAuto := .f.
Default cFaseAuto := ""
Default _cCodCEV  := ""

If lVCM680GH // Campos do VDM a serem gravados nos Historicos
	aCpos := ExecBlock("VCM680GH",.f.,.f.) // Retorno do PE "VCM680GH" deve ser um Vetor ( aCpos )
	// aCpos[1] = Campos do VDM a serem gravados nos Historicos das Fases do Interesse
	// aCpos[2] = Campos do VDM a serem gravados nos Historicos das Fases de Financiamento
	If ValType(aCpos) <> "A"
		aCpos := {,}
	EndIf
	aVldCpos := aClone(aCpos)
	aCpos := {{},{}}
	If len(aVldCpos) >= 1
		For nX := 1 to len(aVldCpos[1])
			If VDM->(FieldPos(aVldCpos[1,nX])) > 0
				aAdd(aCpos[1],aVldCpos[1,nX])
			EndIf
		Next
	EndIf
	If len(aVldCpos) >= 2
		For nX := 1 to len(aVldCpos[2])
			If VDM->(FieldPos(aVldCpos[2,nX])) > 0
				aAdd(aCpos[2],aVldCpos[2,nX])
			EndIf
		Next
	EndIf
EndIf

aRecInter := {} // Limpar vetor

Inclui := .f.
Altera := .f.
If nOpc == 3
	Inclui := .t.
ElseIf nOpc == 4
	Altera := .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc != 2
	
	Begin Transaction
	
	If lFaseAuto // Trocar automaticamente a Fase do Interesse

		DbSelectArea("VDM")
		RecLock("VDM",.f.)
			VDM->VDM_CODFAS := cFaseAuto // Nova Fase
			if VDM->(fieldpos('VDM_DATALT')) > 0
				VDM->VDM_DATALT := FGX_Timestamp()
			endif
		MsUnLock()

		conout("Fase alterada automaticamente para atendimento")
		dbGoto(VDM->(recno())) // transacao, buscadndo dados atuais
		//if lVDM_UUID .and. FindClass("VEInteresseApi")
		//	oIntApi := VEInteresseApi():New()
		//	oIntApi:Sync(VDM->VDM_UUID, lNewSync /** criando ? */, .f.) // envia alteracao ou criacao
		//endif

		// Gravar Historico
		DbSelectArea("VDN")
		RecLock("VDN",.t.)
		VDN->VDN_FILIAL := xFilial("VDN")
		VDN->VDN_CODHIS := GetSXENum("VDN","VDN_CODHIS")
		VDN->VDN_TIPHIS := "1"
		If lVDN_CODOPO
			VDN->VDN_CODOPO := VDM->VDM_CODOPO
		EndIf
		VDN->VDN_CODINT := VDM->VDM_CODINT
		VDN->VDN_CODFAS := VDM->VDM_CODFAS
		VDN->VDN_CODCLI := VDL->VDL_CODCLI
		VDN->VDN_LOJCLI := VDL->VDL_LOJCLI
		VDN->VDN_NOMCLI := VDL->VDL_NOMCLI
		VDN->VDN_CDPROS := VDL->VDL_CDPROS
		VDN->VDN_LJPROS := VDL->VDL_LJPROS
		VDN->VDN_MOTCAN := VDM->VDM_MOTCAN
		VDN->VDN_CODVEN := VDM->VDM_CODVEN
		VDN->VDN_VLRMON := VDM->VDM_VLRMON
		VDN->VDN_VLROFE := VDM->VDM_VLROFE
		VDN->VDN_VLRCLI := VDM->VDM_VLRCLI
		VDN->VDN_VLRVDA := VDM->VDM_VLRVDA
		VDN->VDN_DATVDA := VDM->VDM_DATVDA
		VDN->VDN_VLRCOM := VDM->VDM_VLRCOM
		VDN->VDN_QTDUSA := VDM->VDM_QTDUSA
		VDN->VDN_VLRUSA := VDM->VDM_VLRUSA
		VDN->VDN_DECVDA := VDM->VDM_DECVDA
		VDN->VDN_VLRNEG := VDM->VDM_VLRNEG
		VDN->VDN_TMPNEG := VDL->VDL_TMPNEG
		VDN->VDN_DATHIS := dDataBase
		VDN->VDN_HORHIS := val(substr(Time(),1,2)+substr(Time(),4,2))
		VDN->VDN_USUHIS := __cUserId
		VDN->VDN_OBSERV := STR0087 // Fase Automática - Mudança de Status do Atendimento
		if VDN->(fieldpos('VDN_DATINC')) > 0
			VDN->VDN_DATINC := FGX_Timestamp()
		endif
		if VDN->(fieldpos("VDN_UUID")) > 0
			VDN->VDN_UUID   := FwUUIDV4(.t.)
		endif
		If lVCM680GH // Campos do VDM a serem gravados nos Historicos das Fases do Interesse
			If len(aCpos) > 0 .and. len(aCpos[1]) > 0
				For nX := 1 to len(aCpos[1])
					&("VDN->VDN_"+substr(aCpos[1,nX],5)) := &("VDM->"+aCpos[1,nX]) 
				Next
			EndIf
		EndIf
		MsUnlock()
		ConfirmSX8()
	
	Else

		If Empty(M->VDL_CODOPO)
			M->VDL_CODOPO := GetSXENum("VDL","VDL_CODOPO")
			ConfirmSX8()
		EndIf
		dbSelectArea("VDL")
		dbSetOrder(1)
		dbSeek(xFilial("VDL")+M->VDL_CODOPO)
		If Altera
			cAuxCodC := VDL->VDL_CODCLI
			cAuxLojC := VDL->VDL_LOJCLI
			cAuxNomC := VDL->VDL_NOMCLI
			cAuxCdPC := VDL->VDL_CDPROS
			cAuxLjPC := VDL->VDL_LJPROS
			cAuxTmp  := VDL->VDL_TMPNEG
		EndIf
		If Inclui .or. Altera
			RecLock("VDL",!Found())
			FG_GRAVAR("VDL")
			MsUnlock()
		EndIf
		
		For ix1 := 1 to len(oAuxGetDados:aCols)
			If Empty(oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODINT")])
				oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODINT")] := M->VDM_CODINT := GetSXENum("VDM","VDM_CODINT")
				ConfirmSX8()
			EndIf
			dbselectArea("VDM")
			dbSetOrder(1)
			dbseek(xFilial("VDM")+M->VDL_CODOPO+oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODINT")])
			If (Inclui .or. Altera)
				//
				If Found()
					lCriaH1 := .f.
					lCriaH2 := .f.
					If !Empty(oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_OBSERV")]) .or. ;
						VDM->VDM_CODFAS <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODFAS")] .or. ;
						VDM->VDM_MOTCAN <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_MOTCAN")] .or. ;
						VDM->VDM_CODVEN <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODVEN")] .or. ;
						VDM->VDM_VLRMON <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLRMON")] .or. ;
						VDM->VDM_VLROFE <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLROFE")] .or. ;
						VDM->VDM_VLRCLI <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLRCLI")] .or. ;
						VDM->VDM_VLRVDA <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLRVDA")] .or. ;
						VDM->VDM_DATVDA <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_DATVDA")] .or. ;
						VDM->VDM_VLRCOM <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLRCOM")] .or. ;
						VDM->VDM_QTDUSA <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_QTDUSA")] .or. ;
						VDM->VDM_VLRUSA <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLRUSA")] .or. ;
						VDM->VDM_DECVDA <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_DECVDA")] .or. ;
						VDM->VDM_VLRNEG <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_VLRNEG")] .or. ;
						cAuxCodC <> VDL->VDL_CODCLI .or. ;
						cAuxLojC <> VDL->VDL_LOJCLI .or. ;
						cAuxNomC <> VDL->VDL_NOMCLI .or. ;
						cAuxCdPC <> VDL->VDL_CDPROS .or. ;
						cAuxLjPC <> VDL->VDL_LJPROS .or. ;
						cAuxTmp  <> VDL->VDL_TMPNEG
						lCriaH1 := .t.
					ElseIf lVCM680GH // Campos do VDM a serem gravados nos Historicos das Fases do Interesse
						If len(aCpos) > 0 .and. len(aCpos[1]) > 0
							For nX := 1 to len(aCpos[1])
								If &("VDM->"+aCpos[1,nX]) <> oAuxGetDados:aCols[ix1,FG_POSVAR(aCpos[1,nX])]
									lCriaH1 := .t.
									Exit
								EndIf
							Next
						EndIf
					EndIf
					If VDM->VDM_FASFIN <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_FASFIN")] .or. ;
						VDM->VDM_CCLIBC+VDM->VDM_LCLIBC <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CCLIBC")]+oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_LCLIBC")] .or. ;
						VDM->VDM_CODBCO <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODBCO")] .or. ;
						VDM->VDM_NOMBCO <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_NOMBCO")] .or. ;
						VDM->VDM_CODAGE <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_CODAGE")] .or. ;
						VDM->VDM_NOMGER <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_NOMGER")] .or. ;
						VDM->VDM_NROTEL <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_NROTEL")] .or. ;
						VDM->VDM_NOMCID <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_NOMCID")] .or. ;
						VDM->VDM_LINCRE <> oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_LINCRE")]
						lCriaH2 := .t.
					ElseIf lVCM680GH // Campos do VDM a serem gravados nos Historicos das Fases de Financiamento
						If len(aCpos) > 0 .and. len(aCpos[2]) > 0
							For nX := 1 to len(aCpos[2])
								If &("VDM->"+aCpos[2,nX]) <> oAuxGetDados:aCols[ix1,FG_POSVAR(aCpos[2,nX])]
									lCriaH2 := .t.
									Exit
								EndIf
							Next
						EndIf
					EndIf
				Else
					lCriaH1 := .t.
					lCriaH2 := .t.
				EndIf
				//
				lNewSync := !Found()
				//
				RecLock("VDM",lNewSync)
				FG_GRAVAR("VDM",oAuxGetDados:aCols,aHeader,ix1)
				VDM->VDM_FILIAL := xFilial("VDM")
				VDM->VDM_CODOPO := M->VDL_CODOPO
				VDM->VDM_QTDINT := 1 // Qtde fixa 1
				if VDM->(fieldpos('VDM_DATINC')) > 0
					VDM->VDM_DATALT := FGX_Timestamp()
					if empty(VDM->VDM_DATINC)
						VDM->VDM_DATINC := VDM->VDM_DATALT
					endif
				endif
				if lVDM_UUID .and. lNewSync
					VDM->VDM_UUID := FwUUIDV4(.t.)
				endif
				MsUnlock()

				dbGoto(VDM->(recno())) // transacao, buscadndo dados atuais
				If lVDM_UUID 
					//If FindClass("VEInteresseApi")
					//	oIntApi := VEInteresseApi():New()
					//	oIntApi:Sync(VDM->VDM_UUID, lNewSync /** criando ? */, .f.) // envia alteracao ou criacao
					//EndIf
					If lNewSync 
						If ExistFunc("VA1700011_Grava_Relacionamento")
							If !Empty(_cCodCEV) // Executado pelo CEV - Cria registro na tabela de Relacionamento: 1 = VC1 x VDM
								VA1700011_Grava_Relacionamento( "1" , xFilial("VC1") , _cCodCEV , VDM->VDM_FILIAL , VDM->VDM_UUID )
							Else // Nao executado pelo CEV - verificar novos relacionamentos realizados dentro do VEICM680
								ix2 := aScan(aRelNOVOS,{|x| x[4] == VDM->VDM_UUID })
								If ix2 > 0
									VA1700011_Grava_Relacionamento( "1" , aRelNOVOS[ix2,1] , aRelNOVOS[ix2,2] , aRelNOVOS[ix2,3] , aRelNOVOS[ix2,4] )
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				//
				///////////////////////////////////
				// Abrir Atendimento automatico  //
				///////////////////////////////////
				If oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_ABRATE")] $ "1/2" // 1=Atendimento / 2=Fat.Direto
					aAdd(aRecInter,VDM->(RecNo()))
					cTipInter := oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_ABRATE")]
				EndIf
				///////////////////////////////////
				// Gravar Motivo de Cancelamento //
				///////////////////////////////////
				If !Empty(VDM->VDM_MOTCAN)
					For ix2 := 1 to len(aDelMotiv)
						If aDelMotiv[ix2,1] == ix1 // Posicao na aCols
							OFA210VDT("000011",aDelMotiv[ix2,2,1],"6",VDM->VDM_FILIAL,VDM->VDM_CODINT,aDelMotiv[ix2,2,4])
						EndIf
					Next
				EndIf
				//
				If lCriaH1
					DbSelectArea("VDN")
					RecLock("VDN",.t.)
					VDN->VDN_FILIAL := xFilial("VDN")
					VDN->VDN_CODHIS := GetSXENum("VDN","VDN_CODHIS")
					VDN->VDN_TIPHIS := "1"
					If lVDN_CODOPO
						VDN->VDN_CODOPO := VDM->VDM_CODOPO
					EndIf
					VDN->VDN_CODINT := VDM->VDM_CODINT
					VDN->VDN_CODFAS := VDM->VDM_CODFAS
					VDN->VDN_CODCLI := VDL->VDL_CODCLI
					VDN->VDN_LOJCLI := VDL->VDL_LOJCLI
					VDN->VDN_NOMCLI := VDL->VDL_NOMCLI
					VDN->VDN_CDPROS := VDL->VDL_CDPROS
					VDN->VDN_LJPROS := VDL->VDL_LJPROS
					VDN->VDN_MOTCAN := VDM->VDM_MOTCAN
					VDN->VDN_CODVEN := VDM->VDM_CODVEN
					VDN->VDN_VLRMON := VDM->VDM_VLRMON
					VDN->VDN_VLROFE := VDM->VDM_VLROFE
					VDN->VDN_VLRCLI := VDM->VDM_VLRCLI
					VDN->VDN_VLRVDA := VDM->VDM_VLRVDA
					VDN->VDN_DATVDA := VDM->VDM_DATVDA
					VDN->VDN_VLRCOM := VDM->VDM_VLRCOM
					VDN->VDN_QTDUSA := VDM->VDM_QTDUSA
					VDN->VDN_VLRUSA := VDM->VDM_VLRUSA
					VDN->VDN_DECVDA := VDM->VDM_DECVDA
					VDN->VDN_VLRNEG := VDM->VDM_VLRNEG
					VDN->VDN_TMPNEG := VDL->VDL_TMPNEG
					VDN->VDN_DATHIS := IIf(!Empty(M->VDM_DTFASO),M->VDM_DTFASO,dDataBase)
					VDN->VDN_HORHIS := IIf(!Empty(M->VDM_HRFASO),M->VDM_HRFASO,val(substr(Time(),1,2)+substr(Time(),4,2)))
					VDN->VDN_USUHIS := __cUserId
					VDN->VDN_OBSERV := oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_OBSERV")] // Campo virtual digitado na aCols
					if VDN->(fieldpos('VDN_DATINC')) > 0
						VDN->VDN_DATINC := FGX_Timestamp()
						VDN->VDN_DATALT := VDN->VDN_DATINC
					endif
					if VDN->(FieldPos("VDN_UUID")) > 0
						VDN->VDN_UUID   := FwUUIDV4(.t.)
					endif
					If lVCM680GH // Campos do VDM a serem gravados nos Historicos das Fases do Interesse
						If len(aCpos) > 0 .and. len(aCpos[1]) > 0
							For nX := 1 to len(aCpos[1])
								&("VDN->VDN_"+substr(aCpos[1,nX],5)) := &("VDM->"+aCpos[1,nX]) 
							Next
						EndIf
					EndIf
					MsUnlock()
					ConfirmSX8()
				EndIf
				If lCriaH2
					DbSelectArea("VDN")
					RecLock("VDN",.t.)
					VDN->VDN_FILIAL := xFilial("VDN")
					VDN->VDN_CODHIS := GetSXENum("VDN","VDN_CODHIS")
					VDN->VDN_TIPHIS  := "2"
					If lVDN_CODOPO
						VDN->VDN_CODOPO := VDM->VDM_CODOPO
					EndIf
					VDN->VDN_CODINT := VDM->VDM_CODINT 
					VDN->VDN_FASFIN := VDM->VDM_FASFIN  
					VDN->VDN_CCLIBC := VDM->VDM_CCLIBC
					VDN->VDN_LCLIBC := VDM->VDM_LCLIBC
					VDN->VDN_CODBCO := VDM->VDM_CODBCO
					VDN->VDN_NOMBCO := VDM->VDM_NOMBCO  
					VDN->VDN_CODAGE := VDM->VDM_CODAGE  
					VDN->VDN_CONCOR := VDM->VDM_CONCOR  
					VDN->VDN_NOMGER := VDM->VDM_NOMGER  
					VDN->VDN_NROTEL := VDM->VDM_NROTEL  
					VDN->VDN_NOMCID := VDM->VDM_NOMCID  
					VDN->VDN_LINCRE := VDM->VDM_LINCRE  
					VDN->VDN_DATHIS := IIf(!Empty(M->VDM_DTFASF),M->VDM_DTFASF,dDataBase)
					VDN->VDN_HORHIS := IIf(!Empty(M->VDM_HRFASF),M->VDM_HRFASF,val(substr(Time(),1,2)+substr(Time(),4,2)))
					VDN->VDN_USUHIS := __cUserId
					VDN->VDN_OBSERV := oAuxGetDados:aCols[ix1,FG_POSVAR("VDM_OBSERV")] // Campo virtual digitado na aCols
					if VDN->(fieldpos('VDN_DATINC')) > 0
						VDN->VDN_DATINC := FGX_Timestamp()
						VDN->VDN_DATALT := VDN->VDN_DATINC
					endif
					if VDN->(FieldPos("VDN_UUID")) > 0
						VDN->VDN_UUID   := FwUUIDV4(.t.)
					endif
					If lVCM680GH // Campos do VDM a serem gravados nos Historicos das Fases de Financiamento
						If len(aCpos) > 0 .and. len(aCpos[2]) > 0
							For nX := 1 to len(aCpos[2])
								&("VDN->VDN_"+substr(aCpos[2,nX],5)) := &("VDM->"+aCpos[2,nX]) 
							Next
						EndIf
					EndIf
					MsUnlock()
					ConfirmSX8()
				EndIf
				//
			EndIf
		Next
	
	EndIf

	If ExistBlock("VCM680DGR") // Ponto de Entrada após gravação dos campos da VDM e VDN
		ExecBlock("VCM680DGR", .f., .f.)
	EndIf

	End Transaction

	lMsHelpAuto := .f.

Endif

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VCM680DELº Autor ³ Andre Luis Almeida º Data ³  16/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Delete - necessario informar motivo e exclui da aCols      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680DEL()
Local cMotCan    := space(6)
Local nPos       := 0
Local aMotCancel := {}
If !Empty(M->VDM_FILATE+M->VDM_NUMATE)
	MsgStop(STR0032,STR0029) // Impossivel Excluir o registro. Interesse ja relacionado no Atendimento! / Atencao
	Return()
EndIf
If !Empty(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_MOTCAN")])
	MsgStop(STR0090,STR0029) // Impossivel Excluir o registro. Interesse já Cancelado! / Atencao
	Return()
EndIf
nPos := aScan(aDelMotiv,{|x| x[1] == oAuxGetDados:nAt })
If nPos <= 0
	aAdd(aDelMotiv,{oAuxGetDados:nAt,{}})
	nPos := len(aDelMotiv)
EndIf
If !oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
	aMotCancel := OFA210MOT("000011","6","","",.f.) // Filtro da consulta do motivo de Cancelamentos ( 000011 = Oportunidade )
	If len(aMotCancel) <= 0
		aDelMotiv[nPos,2] := {}
	Else
		cMotCan := aMotCancel[1]
		aDelMotiv[nPos,2] := aClone(aMotCancel)
	EndIf
EndIf
oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := !Empty(cMotCan)
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_MOTCAN")] := M->VDM_MOTCAN := cMotCan
oAuxGetDados:oBrowse:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  º Autor ³ Andre Luis Almeida º Data ³  15/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MenuDef monta aRotina                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"axPesqui", 0 , 1 },; 	// Pesquisar
					{ STR0003 ,"VCM680021_Executar('V')" , 0 , 2 },;	// Visualizar
					{ STR0004 ,"VCM680021_Executar('I')" , 0 , 3 },;	// Incluir
					{ STR0005 ,"VCM680021_Executar('A')" , 0 , 4 },;	// Alterar
					{ STR0071 ,"VCM680C"  , 0 , 5 },;	// Cancelar
					{ STR0094 ,"VCM680041_GerarAgendaCEV()" , 0 , 2 },;	// Gerar Agenda CEV
					{ STR0095 ,"VCM680051_RelacionarAgendaCEV()" , 0 , 2 },;	// Relacionar Agenda CEV
					{ STR0081+IIf(!IsInCallStack('OFIA120')," <F7>","") ,"VCC680FUNIL()", 0 , 1 },;	// Funil Interesses <F7>
					{ STR0089 ,"MsDocument", 0 , 4}} // Banco de Conhecimento

If (ExistBlock("VCM680MD")) // Ponto de Entrada para adicionar opções no Menu
	aRotina := ExecBlock("VCM680MD", .f., .f., {aRotina})
EndIf
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM680CLI³ Autor ³  Thiago               ³ Data ³ 16/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cliente                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680CLI(nTp)
//variaveis controle de janela
Local aObjects   := {} , aInfo := {}
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aRet       := {"","","",0,0,"",""}
Local nCntTam    := 0
Local i          := 0
Local nOpcao     := 0
Private cCodC    := space(TamSX3("A1_COD")[1])
Private cLojC    := space(TamSX3("A1_LOJA")[1])
Private cCdPC    := space(TamSX3("US_COD")[1])
Private cLjPC    := space(TamSX3("US_LOJA")[1])
Private cNomC    := space(TamSX3("A1_NOME")[1])
Private cFonC    := space(TamSX3("A1_TEL")[1])
Private cEmaC    := space(TamSX3("A1_EMAIL")[1])
Private cCPFC    := space(TamSX3("A1_CGC")[1])
Private aCliente := {{.f.,"","","","","","",0,"",""}}
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private lBotAlt  := .f.
//
aObjects := {}
AAdd( aObjects, { 000, 050 , .T. , .F. } )//cabecalho
AAdd( aObjects, { 000, 000 , .T. , .T. } )//listbox
AAdd( aObjects, { 000, 010 , .T. , .F. } )//Botoes
// Fator de reducao de 80%
for nCntTam := 1 to Len(aSizeAut)
	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
next
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)
DEFINE MSDIALOG oDlgCli FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0006 OF oMainWnd PIXEL // Pesquisa Cliente
oDlgCli:lEscClose := .F.
@ aPos[1,1],aPos[1,2]+002 TO aPos[1,3],aPos[1,4] LABEL "" OF oDlgCli PIXEL
@ aPos[1,1]+004,aPos[1,2]+005 SAY STR0008 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // Codigo
@ aPos[1,1]+004,aPos[1,2]+035 MSGET oCodC VAR cCodC PICTURE "@!" F3 "SA1" SIZE 50,08 OF oDlgCli PIXEL COLOR CLR_HBLUE WHEN Empty(cCdPC)
@ aPos[1,1]+004,aPos[1,2]+200 SAY STR0009 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // Loja
@ aPos[1,1]+004,aPos[1,2]+230 MSGET oLojC VAR cLojC PICTURE "@!" SIZE 30,08 OF oDlgCli PIXEL COLOR CLR_HBLUE WHEN Empty(cCdPC)
@ aPos[1,1]+015,aPos[1,2]+005 SAY STR0046 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // Prospect
@ aPos[1,1]+015,aPos[1,2]+035 MSGET oCdPC VAR cCdPC PICTURE "@!" F3 "SUS" SIZE 50,08 OF oDlgCli PIXEL COLOR CLR_HBLUE WHEN Empty(cCodC)
@ aPos[1,1]+015,aPos[1,2]+200 SAY STR0009 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // Loja
@ aPos[1,1]+015,aPos[1,2]+230 MSGET oLjPC VAR cLjPC PICTURE "@!" SIZE 30,08 OF oDlgCli PIXEL COLOR CLR_HBLUE WHEN Empty(cCodC)
@ aPos[1,1]+026,aPos[1,2]+005 SAY STR0010 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // Nome
@ aPos[1,1]+026,aPos[1,2]+035 MSGET oNomC VAR cNomC PICTURE "@!" SIZE 120,08 OF oDlgCli PIXEL COLOR CLR_HBLUE
@ aPos[1,1]+026,aPos[1,2]+200 SAY STR0011 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // CNPJ/CPF
@ aPos[1,1]+026,aPos[1,2]+230 MSGET oCPFC VAR cCPFC PICTURE "@!" SIZE 80,08 OF oDlgCli PIXEL COLOR CLR_HBLUE
@ aPos[1,1]+037,aPos[1,2]+005 SAY STR0012 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // E-mail
@ aPos[1,1]+037,aPos[1,2]+035 MSGET oEmaC VAR cEmaC PICTURE "" SIZE 120,08 OF oDlgCli PIXEL COLOR CLR_HBLUE
@ aPos[1,1]+037,aPos[1,2]+200 SAY STR0013 SIZE 60,20 OF oDlgCli PIXEL COLOR CLR_BLUE // Telefone
@ aPos[1,1]+037,aPos[1,2]+230 MSGET oFonC VAR cFonC PICTURE "@!" SIZE 80,08 OF oDlgCli PIXEL COLOR CLR_HBLUE
@ aPos[1,1]+015,aPos[1,4]-070 BUTTON oFiltro PROMPT STR0014 OF oDlgCli SIZE 65,10 PIXEL  ACTION FS_CliFiltro(nTp) // <<< FILTRAR >>>
@ aPos[2,1]+001,aPos[2,2]+002 LISTBOX oLbx1 FIELDS HEADER "",STR0008,STR0009,STR0046,STR0009,STR0010,STR0011 COLSIZES 10,35,15,35,15,200,80 SIZE aPos[2,4]-aPos[2,2], aPos[2,3]-aPos[2,1]-5 OF oDlgCli PIXEL ON DBLCLICK (FS_CliTIK(oLbx1:nAt,nTp))
oLbx1:SetArray(aCliente)
oLbx1:bLine := { || {  IIf(aCliente[oLbx1:nAt,01],oTik,oNo),aCliente[oLbx1:nAt,02],aCliente[oLbx1:nAt,03],aCliente[oLbx1:nAt,09],aCliente[oLbx1:nAt,10],aCliente[oLbx1:nAt,04],aCliente[oLbx1:nAt,07]}}
If nTp == 1 // Inclusao / Alteracao
	@ aPos[3,1],((aPos[3,4]/2)-100) BUTTON oBotAlt PROMPT STR0005 OF oDlgCli SIZE 50,10 PIXEL ACTION ( nOpcao := 4 , oDlgCli:End() ) WHEN ( lBotAlt ) // Alterar
	@ aPos[3,1],((aPos[3,4]/2)-025) BUTTON oBotInc PROMPT STR0004 OF oDlgCli SIZE 50,10 PIXEL ACTION ( nOpcao := 3 , oDlgCli:End() ) // Incluir
	@ aPos[3,1],((aPos[3,4]/2)+050) BUTTON oBotSai PROMPT STR0015 OF oDlgCli SIZE 50,10 PIXEL ACTION ( nOpcao := 0 , oDlgCli:End() ) // Sair
ElseIf nTp == 2 // Consulta apenas
	@ aPos[3,1],((aPos[3,4]/2)-075) BUTTON oBotOk  PROMPT STR0016 OF oDlgCli SIZE 50,10 PIXEL ACTION ( nOpcao := 3 , oDlgCli:End() ) // OK
	@ aPos[3,1],((aPos[3,4]/2)+025) BUTTON oBotSai PROMPT STR0015 OF oDlgCli SIZE 50,10 PIXEL ACTION ( nOpcao := 0 , oDlgCli:End() ) // Sair
EndIf
ACTIVATE MSDIALOG oDlgCli CENTER
if nOpcao <> 0
	For i := 1 to Len(aCliente)
		if aCliente[i,1]
			aRet := { aCliente[i,2] , aCliente[i,3] , aCliente[i,4] , nOpcao , aCliente[i,8] , aCliente[i,9] , aCliente[i,10] }
			Exit
		Endif
	Next
	If nOpcao == 3 .and. Empty(aRet[3])
		aRet := { cCodC , cLojC , cNomC , nOpcao , 0 , cCdPC , cLjPC }
	EndIf
Endif
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CliFiltro³ Autor ³ Thiago					 ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro do cliente.		                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CliFiltro(nTp)
Local cAliasVDL := "SQLVDL"
Local cAliasSA1 := "SQLSA1"
Local cAliasSUS := "SQLSUS"
aCliente := {}
if !Empty(cCodC) .or. !Empty(cCdPC) .or. !Empty(cNomC) .or. !Empty(cFonC) .or. !Empty(cEmaC)
	If Empty(cCPFC)
		cQuery := "SELECT VDL.R_E_C_N_O_ RECVDL , VDL.VDL_CODCLI , VDL.VDL_LOJCLI , VDL.VDL_CDPROS , VDL.VDL_LJPROS , VDL.VDL_NOMCLI , VDL.VDL_TELCLI , VDL.VDL_EMACLI , SA1.A1_CGC , SUS.US_CGC "
		cQuery += "FROM " + RetSqlName( "VDL" ) + " VDL "
		cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON (SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VDL.VDL_CODCLI AND SA1.A1_LOJA=VDL.VDL_LOJCLI AND VDL.D_E_L_E_T_=' ') "
		cQuery += "LEFT JOIN "+RetSqlName("SUS")+" SUS ON (SUS.US_FILIAL='"+xFilial("SUS")+"' AND SUS.US_COD=VDL.VDL_CDPROS AND SUS.US_LOJA=VDL.VDL_LJPROS AND VDL.D_E_L_E_T_=' ') "
		cQuery += "WHERE VDL.VDL_FILIAL='"+ xFilial("VDL")+ "' AND "
		if !Empty(cCodC)
			cQuery += "VDL.VDL_CODCLI = '"+cCodC+"' AND "
		Endif
		if !Empty(cLojC)
			cQuery += "VDL.VDL_LOJCLI = '"+cLojC+"' AND "
		Endif		
		if !Empty(cCdPC)
			cQuery += "VDL.VDL_CDPROS = '"+cCdPC+"' AND "
		Endif
		if !Empty(cLjPC)
			cQuery += "VDL.VDL_LJPROS = '"+cLjPC+"' AND "
		Endif
		if !Empty(cNomC)
			cQuery += "VDL.VDL_NOMCLI LIKE '%"+Alltrim(cNomC)+"%' AND "
		Endif
		if !Empty(cFonC)
			cQuery += "VDL.VDL_TELCLI LIKE '%"+Alltrim(cFonC)+"%' AND "
		Endif
		if !Empty(cEmaC)
			cQuery += "UPPER(VDL.VDL_EMACLI) LIKE '%"+UPPER(Alltrim(cEmaC))+"%' AND "
		Endif
		cQuery += "VDL.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVDL, .T., .T. )
		If !( cAliasVDL )->( Eof() )
			Aadd(aCliente,{.f.,( cAliasVDL )->VDL_CODCLI,( cAliasVDL )->VDL_LOJCLI,( cAliasVDL )->VDL_NOMCLI,( cAliasVDL )->VDL_TELCLI,( cAliasVDL )->VDL_EMACLI,IIf(!Empty(( cAliasVDL )->A1_CGC),( cAliasVDL )->A1_CGC,( cAliasVDL )->US_CGC),( cAliasVDL )->RECVDL,( cAliasVDL )->VDL_CDPROS,( cAliasVDL )->VDL_LJPROS})
		EndIf
		( cAliasVDL )->( dbCloseArea() )
	Endif
	If nTp == 1
		If !Empty(cCodC+cLojC+cNomC+cCPFC+cFonC+cEmaC)
			cQuery := "SELECT SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,SA1.A1_TEL,SA1.A1_EMAIL,SA1.A1_CGC "
			cQuery += "FROM " + RetSqlName( "SA1" ) + " SA1 "
			cQuery += "WHERE SA1.A1_FILIAL='"+ xFilial("SA1")+ "' AND "
			if !Empty(cCodC)
				cQuery += "SA1.A1_COD = '"+cCodC+"' AND "
			Endif
			if !Empty(cLojC)
				cQuery += "SA1.A1_LOJA = '"+cLojC+"' AND "
			Endif
			if !Empty(cNomC)
				cQuery += "SA1.A1_NOME LIKE '%"+Alltrim(cNomC)+"%' AND "
			Endif
			if !Empty(cCPFC)
				cQuery += "SA1.A1_CGC LIKE '%"+Alltrim(cCPFC)+"%' AND "
			Endif
			if !Empty(cFonC)
				cQuery += "SA1.A1_TEL LIKE '%"+Alltrim(cFonC)+"%' AND "
			Endif
			if !Empty(cEmaC)
				cQuery += "UPPER(SA1.A1_EMAIL) LIKE '%"+UPPER(Alltrim(cEmaC))+"%' AND "
			Endif
			cQuery += "SA1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA1, .T., .T. )
			Do While !( cAliasSA1 )->( Eof() )
				nPos := aScan(aCliente,{|x| x[2]+x[3] == ( cAliasSA1 )->A1_COD+( cAliasSA1 )->A1_LOJA })
				if nPos == 0
					Aadd(aCliente,{.f.,( cAliasSA1 )->A1_COD,( cAliasSA1 )->A1_LOJA,( cAliasSA1 )->A1_NOME,( cAliasSA1 )->A1_TEL,( cAliasSA1 )->A1_EMAIL,( cAliasSA1 )->A1_CGC,0,space(TamSX3("VDL_CDPROS")[1]),space(TamSX3("VDL_LJPROS")[1])})
				Endif
				dbSelectArea(cAliasSA1)
				( cAliasSA1 )->(dbSkip())
			Enddo
			( cAliasSA1 )->( dbCloseArea() )
		EndIf
		If !Empty(cCdPC+cLjPC+cNomC+cCPFC+cFonC+cEmaC)
			cQuery := "SELECT SUS.US_COD,SUS.US_LOJA,SUS.US_NOME,SUS.US_TEL,SUS.US_EMAIL,SUS.US_CGC "
			cQuery += "FROM " + RetSqlName( "SUS" ) + " SUS "
			cQuery += "WHERE SUS.US_FILIAL='"+ xFilial("SUS")+ "' AND "
			if !Empty(cCdPC)
				cQuery += "SUS.US_COD = '"+cCdPC+"' AND "
			Endif
			if !Empty(cLjPC)
				cQuery += "SUS.US_LOJA = '"+cLjPC+"' AND "
			Endif
			if !Empty(cNomC)
				cQuery += "SUS.US_NOME LIKE '%"+Alltrim(cNomC)+"%' AND "
			Endif
			if !Empty(cCPFC)
				cQuery += "SUS.US_CGC LIKE '%"+Alltrim(cCPFC)+"%' AND "
			Endif
			if !Empty(cFonC)
				cQuery += "SUS.US_TEL LIKE '%"+Alltrim(cFonC)+"%' AND "
			Endif
			if !Empty(cEmaC)
				cQuery += "UPPER(SUS.US_EMAIL) LIKE '%"+UPPER(Alltrim(cEmaC))+"%' AND "
			Endif
			cQuery += "SUS.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSUS, .T., .T. )
			Do While !( cAliasSUS )->( Eof() )
				nPos := aScan(aCliente,{|x| x[9]+x[10] == ( cAliasSUS )->US_COD+( cAliasSUS )->US_LOJA })
				if nPos == 0
					Aadd(aCliente,{.f.,space(TamSX3("VDL_CODCLI")[1]),space(TamSX3("VDL_LOJCLI")[1]),( cAliasSUS )->US_NOME,( cAliasSUS )->US_TEL,( cAliasSUS )->US_EMAIL,( cAliasSUS )->US_CGC,0,( cAliasSUS )->US_COD,( cAliasSUS )->US_LOJA})
				Endif
				dbSelectArea(cAliasSUS)
				( cAliasSUS )->(dbSkip())
			Enddo
			( cAliasSUS )->( dbCloseArea() )
		EndIf
	Endif
Endif
if Len(aCliente) <= 0
	aCliente := {{.f.,"","","","","","",0,"",""}}
Endif
oLbx1:SetArray(aCliente)
oLbx1:bLine := { || {  IIf(aCliente[oLbx1:nAt,01],oTik,oNo),aCliente[oLbx1:nAt,02],aCliente[oLbx1:nAt,03],aCliente[oLbx1:nAt,09],aCliente[oLbx1:nAt,10],aCliente[oLbx1:nAt,04],aCliente[oLbx1:nAt,07]}}
oLbx1:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_CliTIK  ³ Autor ³ Thiago					 ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tik no ListBox do Cliente                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CliTIK(nLin,nTp)
Local i := 0
For i := 1 to Len(aCliente)
	If i <> nLin
		aCliente[i,1] := .f.
	EndIf
Next
If nTp == 1 // Inclusao / Alteracao
	lBotAlt := .f.
EndIf
If !Empty(aCliente[nLin,4])
	aCliente[nLin,1] := !aCliente[nLin,1]
	If nTp == 1 .and. aCliente[nLin,1] .and. aCliente[nLin,8] > 0 // Alteracao do VDL/VDM
		lBotAlt := .t.
	EndIf
EndIf
If nTp == 1 // Inclusao / Alteracao
	oBotAlt:Refresh()
	oBotAlt:SetFocus()
EndIf
oLbx1:Refresh()
oLbx1:SetFocus()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VCM680I    ³ Autor ³ Andre Luis Almeida       ³ Data ³ 18/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cliente ( Inclui / Altera )                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680I()
Local aAux := {}
Local nReg := 0
Local nOpc := 3
If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	If !lIncVDL
		nOpc := 4
		aAux := { VDL->VDL_CODCLI , VDL->VDL_LOJCLI , VDL->VDL_NOMCLI , nOpc , VDL->(RecNo()) , VDL->VDL_CDPROS , VDL->VDL_LJPROS }
	EndIf
Else
	aAux := VCM680CLI(1)
	nOpc := aAux[4] // nOpc
EndIf
Inclui := .f.
Altera := .f.
If nOpc == 3
	Inclui := .t.
ElseIf nOpc == 4
	Altera := .t.
	VDL->(DbGoto(aAux[5]))
	nReg := aAux[5]
EndIf
//
FS_F7(.f.)
//
VCM680("VDL",nReg,nOpc,aAux)
//
FS_F7(.t.)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VCM680CHANGE³ Autor ³ Andre Luis Almeida       ³ Data ³ 14/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Change no aCols                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680CHANGE()
cFilCodMar := M->VDM_CODMAR
If Empty(M->VDM_CODFAS)
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_DESFAS")] := M->VDM_DESFAS := ""
EndIf
If Empty(M->VDM_TIPMID)
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_DESMID")] := M->VDM_DESMID := ""
EndIf
oAuxGetDados:oBrowse:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VM680MDVE   ³ Autor ³ Thiago			         ³ Data ³ 06/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descricao do modelo do veiculo.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM680MDVE()  
Return(.t.)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VM680COR    ³ Autor ³ Thiago			         ³ Data ³ 06/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descricao da cor do veiculo.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM680COR()  
VVC->(dbSetOrder(1))
VVC->(dbSeek(xFilial("VVC")+M->VDM_CODMAR+M->VDM_CORVEI))
M->VDM_DESCOR := VVC->VVC_DESCRI
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_DESCOR")] := VVC->VVC_DESCRI
oAuxGetDados:oBrowse:Refresh()
Return(.t.)	
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VM680VEND   ³ Autor ³ Thiago			         ³ Data ³ 06/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nome do vendedor. 			                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM680VEND()
Local lRet := .t.
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
If !Empty(M->VDM_CODVEN)
	SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3")+M->VDM_CODVEN))
	If VAI->VAI_VABAON == "0" .or. ( VAI->VAI_VABAON == "1" .and. M->VDM_CODVEN <> VAI->VAI_CODVEN ) // 0=Oportunidade nao permitida ou 1=Somente do Vendedor
		oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
		MsgStop(STR0054,STR0029) // Usuario sem permissao! / Atencao
		lRet := .f.
	Else
		oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_NOMVEN")] := M->VDM_NOMVEN := SA3->A3_NOME
	EndIf
Else
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_NOMVEN")] := M->VDM_NOMVEN := ""
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
EndIf
oAuxGetDados:oBrowse:Refresh()
Return(lRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VM680FASE   ³ Autor ³ Thiago			         ³ Data ³ 06/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descricao da fase. 			                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM680FASE()                                        	
VDK->(dbSetOrder(1))
VDK->(dbSeek(xFilial("VDK")+M->VDM_CODFAS))
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_DESFAS")] := M->VDM_DESFAS := VDK->VDK_DESFAS
If VDK->VDK_FIMFAS <> "1" // Nao eh Fase Final - Nao pode abrir Atendimento automticamente
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
EndIf
oAuxGetDados:oBrowse:Refresh()
Return(.t.)	
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VM680MID    ³ Autor ³ Thiago		             ³ Data ³ 06/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descricao da midia. 			                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM680MID()
VX5->(dbSetOrder(1))
VX5->(dbSeek(xFilial("VX5")+"027"+M->VDM_TIPMID))
M->VDM_DESMID := VX5->VX5_DESCRI
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_DESMID")] := VX5->VX5_DESCRI
oAuxGetDados:oBrowse:Refresh()
Return(.t.)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VCM680WHEN ³ Autor ³ Andre Luis Almeida       ³ Data ³ 30/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ WHEN dos campos (VDM)		                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680WHEN(nTp)
Local lRet        := .f.
Local cMV_MIL0040 := GetNewPar("MV_MIL0040","") // Fases finais de Financiamento que nao podem sofrer mais alteracoes
If nTp == 1
	VAI->(DbSetOrder(4))
	VAI->(DbSeek(xFilial("VAI")+__cUserID))
	If VAI->VAI_VABAON == "2" .or. ( VAI->VAI_VABAON == "1" .and. M->VDM_CODVEN == VAI->VAI_CODVEN ) // 2=Qualquer vendedor ou 1=Somente do Vendedor
		VDK->(DbSetOrder(1))
		If VDK->(DbSeek(xFilial("VDK")+M->VDM_CODFAS))
			///////////////////////////////////////////////////////////////////
			// Fase Final - Pode Mudar para abrir Atendimento automticamente //
			///////////////////////////////////////////////////////////////////
			If VDK->VDK_FIMFAS == "1" .and. Empty(M->VDM_NUMATE)
				lRet := .t.
			EndIf
		EndIf
	EndIf
ElseIf nTp == 2
	lRet := .t.
	If !Empty(M->VDM_CODINT)
		VDM->(DbSetOrder(2))
		If VDM->(DbSeek(xFilial("VDM")+M->VDM_CODINT))
			If !Empty(VDM->VDM_FASFIN) .and. Alltrim(VDM->VDM_FASFIN) $ cMV_MIL0040
				lRet := .f.
			EndIf
		EndIf
		VDM->(DbSetOrder(1))
	EndIf	
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VCM680VLD  ³ Autor ³ Andre Luis Almeida       ³ Data ³ 25/08/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VALID dos campos (VDM)		                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680VLD()
Local lVDK_ATIVO  := ( VDK->(FieldPos("VDK_ATIVO"))  > 0 )
Local lVDK_SEQUEN := ( VDK->(FieldPos("VDK_SEQUEN")) > 0 )
Local lVDK_AUTFAS := ( VDK->(FieldPos("VDK_AUTFAS")) > 0 )
Local lVDK_TIPFAS := ( VDK->(FieldPos("VDK_TIPFAS")) > 0 )
Local lRet        := .t.
Local cVDK_SEQUEN := ""
//
Local nPosOld     := 0
Local nPosNew     := 0
Local aEtapas     := {}
//
Do Case
	Case ReadVar() == "M->VDM_CODFAS"
		aEtapas := VCM680031_LevantaFasesPorSequenciaEtapa("1") // Levanta as Fases por Sequencia de Etapas - Fases de Veiculos/Maquinas

		If !Empty(M->VDM_CODINT)
			VDM->(DbSetOrder(2))
			If VDM->(DbSeek(xFilial("VDM")+M->VDM_CODINT))
				If !Empty(VDM->VDM_CODFAS)
					VDK->(DbSetOrder(1))
					If VDK->(DbSeek(xFilial("VDK")+VDM->VDM_CODFAS)) 
						nPosOld := aScan(aEtapas, { |x| VDM->VDM_CODFAS $ x[2] }) // Pega a posicao da ETAPA com a Fase gravada no Interesse
						If VDK->VDK_FIMFAS == "1" // Fase Final
							lRet := .f.
							If !Empty(M->VDM_CODFAS)
								VDK->(DbSetOrder(1))
								If VDK->(DbSeek(xFilial("VDK")+M->VDM_CODFAS)) .and. VDK->VDK_FIMFAS == "1" // Somente retornar .T. se a fase digitada for final tambem
									lRet := .t.
								EndIf
							EndIf
							If !lRet
								MsgStop(STR0042,STR0029) // Impossivel alterar a Fase do interesse. A Fase digitada não é uma Fase Final! / Atencao
							EndIf
						EndIf
					EndIf
					If lVDK_SEQUEN .and. lRet
						VDK->(DbSetOrder(1))
						If VDK->(DbSeek(xFilial("VDK")+VDM->VDM_CODFAS)) .and. !Empty(VDK->VDK_SEQUEN)
							lRet := .f.
							cVDK_SEQUEN := VDK->VDK_SEQUEN
							VDK->(DbSetOrder(1))
							If VDK->(DbSeek(xFilial("VDK")+M->VDM_CODFAS)) .and. VDK->VDK_SEQUEN >= cVDK_SEQUEN // Somente SEQUENCIA maior ou igual a SEQUENCIA da Fase anterior
								lRet := .t.
							EndIf
							If !lRet
								MsgStop(STR0053,STR0029) // Impossivel alterar a Fase do interesse. Verifique a sequencia da Fase! / Atencao
							EndIf
						EndIf
					EndIf
				EndIf
				If lRet .and. !Empty(M->VDM_CODFAS)
					VDK->(DbSetOrder(1))
					If VDK->(DbSeek(xFilial("VDK")+M->VDM_CODFAS))
						If VDK->VDK_FIMFAS <> "1" // Caso nao seja Fase Final, limpar para abrir Atendimento
							oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
						EndIf
					Else
						lRet := .f.
					EndIf
				EndIf
			EndIf
			VDM->(DbSetOrder(1))
		Else
			If !Empty(M->VDM_CODFAS)
				VDK->(DbSetOrder(1))
				If VDK->(DbSeek(xFilial("VDK")+M->VDM_CODFAS))
					If VDK->VDK_FIMFAS <> "1" // Caso nao seja Fase Final, limpar para abrir Atendimento
						oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
					EndIf
				EndIf
			Else
				lRet := .f.
			EndIf
		EndIf
		If lRet
			VDK->(DbSetOrder(1))
			If VDK->(DbSeek(xFilial("VDK")+M->VDM_CODFAS)) .and. !Empty(M->VDM_CODFAS)
				nPosNew := aScan(aEtapas, { |x| M->VDM_CODFAS $ x[2] }) // Pega a posicao da ETAPA com a Fase selecionada pela usuario
				If lVDK_AUTFAS .and. VDK->VDK_AUTFAS == "1"
					MsgStop(STR0088,STR0029) // Esta Fase do Interesse é automática. Impossível utilizar! / Atencao
					lRet := .f.
				EndIf
				If lRet .and. lVDK_TIPFAS .and. !( VDK->VDK_TIPFAS $ " /1" )
					MsgStop(STR0091,STR0029) // Fase do Interesse não esta relacionada a Veículos/Máquinas. Impossível continuar! / Atencao
					lRet := .f.
				EndIf
				If lRet
					If !lVDK_ATIVO .or. VDK->VDK_ATIVO <> "0"
						oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_DESFAS")] := M->VDM_DESFAS := VDK->VDK_DESFAS
					Else
						MsgStop(STR0050,STR0029) // Fase do Interesse não esta ativa. Impossível continuar! / Atencao
						lRet := .f.
					EndIf
				EndIf
				If lRet
					If nPosOld == 0 // NAO tinha Fase selecionada
						If nPosNew > 0 // AGORA selecionou Fase - a NOVA Fase necessariamente deve ser da 1ª ETAPA
							If nPosNew <> 1
								MsgStop(STR0092,STR0029) // Fase do Interesse deve ser da 1ª Etapa do Funil. Impossível continuar! / Atencao
								lRet := .f.
							EndIf
						EndIf
					Else
						If nPosNew > 0 // Selecionou Fase - a NOVA Fase necessariamente deve ter a mesma ou a próxima ETAPA
							If ( nPosNew - nPosOld ) > 1 // Verifica se esta pulando mais de uma Etapa
								MsgStop(STR0093,STR0029) // Fase do Interesse deve ser da mesma ou da próxima Etapa do Funil. Impossível continuar! / Atencao
								lRet := .f.
							EndIf
						Else // AGORA deixou a Fase em Branco ( nao pode mais )
							MsgStop(STR0053,STR0029) // Impossivel alterar a Fase do interesse. Verifique a sequencia da Fase! / Atencao
							lRet := .f.
						EndIf
					EndIf
				EndIf
			EndIf
			If lRet .And. M->VDM_CODFAS <> oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_CODFAS")]
				// Retorna data e hora atuais
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_DTFASO")] := dDataBase
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_HRFASO")] := val(substr(Time(), 1, 2) + substr(Time(), 4, 2))
			EndIf
		EndIf

	Case ReadVar() == "M->VDM_DTFASO"
		If Empty(M->VDM_DTFASO)
			// Se o Código da Fase da Oportunidade foi informado não pode haver Data em branco
			If !Empty(M->VDM_CODFAS)
				lRet := .f.
			EndIf
		Else
			// Verificação de Data informada maior que a atual
			If M->VDM_DTFASO > ddatabase
				lRet := .f.
			EndIf
		EndIf

	Case ReadVar() == "M->VDM_HRFASO"
		If Empty(M->VDM_HRFASO)
			// Se o Código da Fase da Oportunidade foi informado não pode haver Hora em branco
			If !Empty(M->VDM_CODFAS)
				lRet := .f.
			EndIf
		EndIf

	Case ReadVar() == "M->VDM_FASFIN"
		If !Empty(M->VDM_FASFIN) .And. M->VDM_FASFIN <> oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_FASFIN")]
			DbSelectArea("VX5")
			DbSetOrder(1)
			If !DbSeek(xFilial("VX5") + "031" + M->VDM_FASFIN)
				MsgStop(STR0096, STR0029) // Código inválido! / Atencao
				lRet:= .f.
			Else
				// Retornar Nome da Fase do Financiamento
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_NOMFIN")] := VX5->VX5_DESCRI
			
				// Retorna data e hora atuais
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_DTFASF")] := dDataBase
				oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_HRFASF")] := val(substr(Time(), 1, 2) + substr(Time(), 4, 2))
			EndIf
		EndIf

	Case ReadVar() == "M->VDM_DTFASF"
		If Empty(M->VDM_DTFASF)
			// Se o Código da Fase do Financiamento foi informado não pode haver Data em branco
			If !Empty(M->VDM_FASFIN)
				lRet := .f.
			EndIf
		Else
			// Verificação de Data informada maior que a atual
			If M->VDM_DTFASF > ddatabase
				lRet := .f.
			EndIf
		EndIf

	Case ReadVar() == "M->VDM_HRFASF"
		If Empty(M->VDM_HRFASF)
			// Se o Código da Fase do Financiamento foi informado não pode haver Hora em branco
			If !Empty(M->VDM_FASFIN)
				lRet := .f.
			EndIf
		EndIf
EndCase
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VCM680VATE ³ Autor ³ Andre Luis Almeida       ³ Data ³ 01/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza Atendimento (VV9)	                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680VATE()
If !Empty(M->VDM_NUMATE)
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek(M->VDM_FILATE+M->VDM_NUMATE)
		VEIXX002(NIL,NIL,NIL,2,) // Visualizar
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VCM680TPA  ³ Autor ³ Andre Luis Almeida       ³ Data ³ 10/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Tipo de Atendimento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM680TPA(cTpAtend)
Local lRet := .t.
Local ni   := 0
If !Empty(cTpAtend) .and. cTpAtend <> "0"
	For ni := 1 to len(oAuxGetDados:aCols)
		If oAuxGetDados:nAt <> ni
			If oAuxGetDados:aCols[ni,FG_POSVAR("VDM_ABRATE")] == "1" .and. cTpAtend == "2"
				MsgStop(STR0043,STR0029) // Impossivel abrir Atendimento e Faturamento Direto ao mesmo tempo! / Atencao
				lRet := .f.
				Exit
			ElseIf oAuxGetDados:aCols[ni,FG_POSVAR("VDM_ABRATE")] == "2" .and. cTpAtend == "1"
				MsgStop(STR0043,STR0029) // Impossivel abrir Atendimento e Faturamento Direto ao mesmo tempo! / Atencao
				lRet := .f.
				Exit
			EndIf
		EndIf
	Next
EndIf
If !lRet
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_ABRATE")] := M->VDM_ABRATE := "0" // 0=Nao
EndIf
Return(lRet)

/*/{Protheus.doc} OM680Acols
Carrega aCols com os Interesses de determinada Oportunidade

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function OM680Acols(nOpcFunc)

Local nVDMFILATE := FG_POSVAR("VDM_FILATE")
Local nVDMNUMATE := FG_POSVAR("VDM_NUMATE")
Local nVDMITETRA := FG_POSVAR("VDM_ITETRA")
Local nVDMSTAATE := FG_POSVAR("VDM_STAATE")
Local nVDMCODMAR := FG_POSVAR("VDM_CODMAR")
Local nVDMMODVEI := FG_POSVAR("VDM_MODVEI")
Local nVDMCORVEI := FG_POSVAR("VDM_CORVEI")
Local nVDMMOTCAN := FG_POSVAR("VDM_MOTCAN")
Local cTipFat    := ""
Local _ni        := 0
Default nOpcFunc := 2

dbSelectArea("VDM")
dbSetOrder(1)
dbSeek(xFilial("VDM") + M->VDL_CODOPO)

While !eof() .And. VDM->VDM_FILIAL == xFilial("VDM") .And. VDM->VDM_CODOPO == M->VDL_CODOPO
	// Permissão para Visualização (Vazio ou 2 = TODOS / 1 e do próprio Vendedor)
	If Empty(VDM->VDM_CODVEN) .Or. VAI->VAI_VABAON == "2" .Or. (VAI->VAI_VABAON == "1" .And. VDM->VDM_CODVEN == VAI->VAI_CODVEN)
		AADD(aCols, Array(nUsado + 1))

		For _ni := 1 to nUsado
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VDM->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VDM"
			Else
				aCols[Len(aCols),_ni] := IIf(aHeader[_ni,10] # "V", FieldGet(FieldPos(aHeader[_ni,2])), CriaVar(aHeader[_ni,2]))
			EndIf
		Next

		aCols[Len(aCols),nUsado + 1] := .F.
		If !Empty(aCols[Len(aCols),nVDMMOTCAN])
			aCols[Len(aCols),nUsado + 1] := .T.
		EndIf

		If !Empty(aCols[Len(aCols),nVDMNUMATE])
			VV9->(DbSetOrder(1))
			If VV9->(DbSeek(aCols[Len(aCols),nVDMFILATE] + aCols[Len(aCols),nVDMNUMATE]))
				cTipFat := FM_SQL("SELECT VV0_TIPFAT FROM " + RetSqlName("VV0") + " WHERE VV0_FILIAL = '" + VV9->VV9_FILIAL +;
					"' AND VV0_NUMTRA = '" + VV9->VV9_NUMATE + "' AND D_E_L_E_T_=' '")
				If cTipFat <> "2"
					cTipFat := "1"
				EndIf
				aCols[Len(aCols),nVDMSTAATE] := M->VDM_STAATE := Alltrim(X3CBOXDESC("VDM_ABRATE",cTipFat))+" - "+Alltrim(X3CBOXDESC("VV9_STATUS",VV9->VV9_STATUS))
				If !(strzero(nOpcFunc,1) $ "125") .and. nVDMITETRA > 0
					If FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSqlName("VVA")+" WHERE VVA_FILIAL='"+VV9->VV9_FILIAL+"' AND VVA_NUMTRA='"+VV9->VV9_NUMATE+"' AND VVA_ITETRA='"+aCols[Len(aCols),nVDMITETRA]+"' AND D_E_L_E_T_<>' '") > 0 // Verifica VVA deletado
						VV2->(dbSetOrder(1))
						VV2->(dbSeek(xFilial("VV2") + aCols[Len(aCols),nVDMCODMAR] + aCols[Len(aCols),nVDMMODVEI]))

						VVC->(dbSetOrder(1))
						VVC->(dbSeek(xFilial("VVC") + aCols[Len(aCols),nVDMCODMAR] + aCols[Len(aCols),nVDMCORVEI]))

						aAdd(aLimpaVDM, {VDM->(RecNo()),                                                ;
										len(aCols),                                                     ;
										aCols[Len(aCols),nVDMCODMAR],                                   ;
										Alltrim(aCols[Len(aCols),nVDMMODVEI]) + " - " + VV2->VV2_DESMOD,;
										Alltrim(aCols[Len(aCols),nVDMCORVEI]) + " - " + VVC->VVC_DESCRI,;
										VV9->VV9_FILIAL,                                                ;
										VV9->VV9_NUMATE,                                                ;
										aCols[Len(aCols),nVDMITETRA],                                   ;
										aCols[Len(aCols),nVDMSTAATE]})
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	dbSkip()
EndDo

nLenaCols := Len(aCols)

Return

/*/{Protheus.doc} VCM680BrwAct
Montagem do Browse ( Filtros / Legenda / Graficos )

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Function VCM680BrwAct(oBrwVDM,lCamposVDL,lGraficos)
Local aColunasVDL  := {}
Local aCamposVDL   := {}
Local oTableAtt    := Nil 
Local cQuery       := ""
Local cQAlias      := "SQLVDK"
Local cFiltro      := ""
Local ni           := 0
Local aCores       := {}
Local lVDK_ATIVO   := ( VDK->(FieldPos("VDK_ATIVO" )) > 0 )
Local lVDK_CORFAS  := ( VDK->(FieldPos("VDK_CORFAS")) > 0 )
Local lVDK_TIPFAS  := ( VDK->(FieldPos("VDK_TIPFAS")) > 0 )
Default lCamposVDL := .t.
Default lGraficos  := .t.
//
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
If VAI->VAI_VABAON == "0"
	MsgStop(STR0054, STR0029) // Usuario sem permissao! / Atencao
	Return .f.
ElseIf VAI->VAI_VABAON == "1"
	cFiltro := "Empty(VDM_CODVEN) .or. VDM_CODVEN == '"+VAI->VAI_CODVEN+"'"
EndIf
If !Empty(cFiltro)
	oBrwVDM:AddFilter(VAI->VAI_NOMTEC,cFiltro,.t.,.t.,) // Filtro PADRAO - nao deixa desmarcar
Endif
//
// Filtros - Ativos / Não Cancelados / Cancelados
oBrwVDM:AddFilter(STR0082,"DTOS(VDM_DATLIM)>='"+dtos(dDataBase)+"'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // INTERESSES ATIVOS ( DENTRO DA DATA LIMITE )
oBrwVDM:AddFilter(STR0083,"EMPTY(VDM_MOTCAN)",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // INTERESSES NÃO CANCELADOS
oBrwVDM:AddFilter(STR0084,"!EMPTY(VDM_MOTCAN)",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // INTERESSES CANCELADOS
//
If lVDK_CORFAS
	aAdd(aCores,{"BR_AMARELO" ,"",""})	// 1
	aAdd(aCores,{"BR_VERDE"   ,"",""})	// 2
	aAdd(aCores,{"BR_AZUL"    ,"",""})	// 3
	aAdd(aCores,{"BR_LARANJA" ,"",""})	// 4
	aAdd(aCores,{"BR_VERMELHO","",""})	// 5
	aAdd(aCores,{"BR_PINK"    ,"",""})	// 6
	aAdd(aCores,{"BR_PRETO"   ,"",""})	// 7
	aAdd(aCores,{"BR_MARROM"  ,"",""})	// 8 - FASES INATIVAS
	aAdd(aCores,{"BR_CINZA"   ,"",""})	// 9 - FASES SEM COR
	//
	cQuery := "SELECT VDK_ATIVO , VDK_CORFAS , VDK_CODFAS , VDK_DESFAS "
	cQuery += "  FROM "+RetSQLName("VDK")
	cQuery += " WHERE VDK_FILIAL='"+xFilial("VDK")+"'"
	If lVDK_TIPFAS
		cQuery += "   AND VDK_TIPFAS IN (' ','1')"
	EndIf
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	While !(cQAlias)->(Eof())
		If !lVDK_ATIVO .or. (cQAlias)->( VDK_ATIVO ) <> "0"
			If !Empty((cQAlias)->( VDK_CORFAS ))
				aCores[val((cQAlias)->( VDK_CORFAS )),2] += ","+(cQAlias)->( VDK_CODFAS )
				aCores[val((cQAlias)->( VDK_CORFAS )),3] := (cQAlias)->( VDK_DESFAS )
			Else
				aCores[9,2] += ","+(cQAlias)->( VDK_CODFAS )
				aCores[9,3] := (cQAlias)->( VDK_DESFAS )
			EndIf
		Else
			aCores[8,2] += ","+(cQAlias)->( VDK_CODFAS )
			aCores[8,3] := (cQAlias)->( VDK_DESFAS )
		EndIf
		(cQAlias)->(dbSkip())
	End
	(cQAlias)->(dbCloseArea())
	DbSelectArea("VDM")
	//
	oBrwVDM:AddLegend( "EMPTY(VDM_CODFAS)" , "BR_BRANCO" , STR0066 ) // INTERESSES SEM FASE INFORMADA
	For ni := 1 to 7
		If !Empty(aCores[ni,2])
			oBrwVDM:AddLegend( "VDM_CODFAS $ '"+aCores[ni,2]+"'" , aCores[ni,1]  , STR0067+" "+substr(aCores[ni,2],2)+" "+IIf(len(aCores[ni,2])<9,aCores[ni,3],"") ) // INTERESSES NA(S) FASE(S):
		EndIf
	Next
	If !Empty(aCores[8,2])
		oBrwVDM:AddLegend( "VDM_CODFAS $ '"+aCores[8,2]+"'" , aCores[8,1]  , STR0068+" "+substr(aCores[8,2],2)+" "+IIf(len(aCores[8,2])<10,aCores[8,3],"") ) // INTERESSES NA(S) FASE(S) INATIVA(S):
	EndIf
	If !Empty(aCores[9,2])
		oBrwVDM:AddLegend( "VDM_CODFAS $ '"+aCores[9,2]+"'" , aCores[9,1]  , STR0069+" "+substr(aCores[9,2],2)+" "+IIf(len(aCores[9,2])<10,aCores[9,3],"") ) // INTERESSES NA(S) FASE(S) SEM COR INFORMADA:
	EndIf
EndIf
//
If lCamposVDL
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VDL")
	While !Eof() .And. (x3_arquivo == "VDL")
		If X3USO(x3_usado) .and. x3_browse == "S" .and. !(Alltrim(x3_campo)+"," $ "VDL_CODOPO,") 
			If x3_context <> "V"
				AADD(aColunasVDL,{	x3_titulo,;
									&("{ || IIf(VDL->(MsSeek(VDM->VDM_FILIAL+VDM->VDM_CODOPO)),VDL->"+alltrim(x3_campo)+",'') }"),;
									x3_tipo,;
									Alltrim(x3_picture),;
									1,;
									x3_tamanho,;
									x3_decimal,;
									.f. })
			Else
				If !empty(x3_relacao)
					AADD(aColunasVDL,{	x3_titulo,;
									&("{ || IIf(VDL->(MsSeek(VDM->VDM_FILIAL+VDM->VDM_CODOPO)),"+alltrim(x3_relacao)+",'') }"),;
									x3_tipo,;
									Alltrim(x3_picture),;
									1,;
									x3_tamanho,;
									x3_decimal,;
									.f. })
				EndIf
			EndIf
			AADD(aCamposVDL, x3_campo )
		EndIf
		dbSkip()
	EndDo
	DbSelectArea("VDM")
	oBrwVDM:SetFields(aColunasVDL)
	oBrwVDM:ColumnsFields(aCamposVDL)
	oBrwVDM:SetAttach(.T.)
EndIf
If lGraficos
	oTableAtt := TableAttDef()
	oBrwVDM:SetViewsDefault( oTableAtt:aViews ) // Criar Visoes
	oBrwVDM:SetChartsDefault( oTableAtt:aCharts ) // Criar Graficos
	oBrwVDM:SetOpenChart( .T. )
EndIf
Return .t.

/*/{Protheus.doc} TableAttDef
Monta Graficos do Browse

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function TableAttDef()
//
Local oTableAtt := FWTableAtt():New() 
Local oSqlHlp   := DMS_SqlHelper():New()
//
//Gráficos
Local oGraFase := Nil // Grafico por Fases
Local oGraVend := Nil // Grafico por Vendedor 
Local oGraCamp := Nil // Grafico por Campanha
Local oGraMarc := Nil // Grafico por Marca
Local oGraMMod := Nil // Grafico por Marca + Modelo
Local oGraDInt := Nil // Grafico por Data de Interesse
Local oGraCanc := Nil // Grafico por Motivo de Cancelamento
//
// Grafico Por Fases
oGraFase := FWDSChart():New()
oGraFase:SetName(STR0018) // Fase
oGraFase:SetTitle(STR0018) // Fase
oGraFase:SetID("GrafFase") 
oGraFase:SetType("BARCOMPCHART")
oGraFase:SetSeries({{"VDM","VDM_CODFAS","COUNT"}})
oGraFase:SetCategory({{"VDM", "VDM_CODFAS"}})
oGraFase:SetPublic( .T. )
oGraFase:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraFase:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraFase) 

// Grafico Por Vendedor
oGraVend := FWDSChart():New()
oGraVend:SetName(STR0019) // Vendedor
oGraVend:SetTitle(STR0019) // Vendedor
oGraVend:SetID("GrafVend") 
oGraVend:SetType("BARCOMPCHART")
oGraVend:SetSeries({{"VDM","VDM_CODVEN","COUNT"}})
oGraVend:SetCategory({{"VDM", "VDM_CODVEN"}})
oGraVend:SetPublic( .T. )
oGraVend:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraVend:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraVend)

// Grafico Por Campanha
oGraCamp := FWDSChart():New()
oGraCamp:SetName(STR0017) // Campanha
oGraCamp:SetTitle(STR0017) // Campanha
oGraCamp:SetID("GrafCamp") 
oGraCamp:SetType("BARCOMPCHART")
oGraCamp:SetSeries({{"VDM","VDM_CAMPOP","COUNT"}})
oGraCamp:SetCategory({{"VDM", "VDM_CAMPOP"}})
oGraCamp:SetPublic( .T. )
oGraCamp:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraCamp:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraCamp)

// Grafico Por Marca
oGraMarc := FWDSChart():New()
oGraMarc:SetName(STR0022) // Marca
oGraMarc:SetTitle(STR0022) // Marca
oGraMarc:SetID("GrafMarc") 
oGraMarc:SetType("BARCOMPCHART")
oGraMarc:SetSeries({{"VDM","VDM_CODMAR","COUNT"}})
oGraMarc:SetCategory({{"VDM", "VDM_CODMAR"}})
oGraMarc:SetPublic( .T. )
oGraMarc:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraMarc:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraMarc)

// Grafico Por Marca + Modelo
oGraMMod := FWDSChart():New()
oGraMMod:SetName(STR0022+" + "+STR0023) // Marca + Modelo
oGraMMod:SetTitle(STR0022+" + "+STR0023) // Marca + Modelo
oGraMMod:SetID("GrafMMod") 
oGraMMod:SetType("BARCOMPCHART")
oGraMMod:SetSeries({{"VDM", oSqlHlp:Concat({"VDM_CODMAR","VDM_MODVEI"}),"COUNT"}})
oGraMMod:SetCategory({{"VDM", oSqlHlp:Concat({"VDM_CODMAR","VDM_MODVEI"}) }})
oGraMMod:SetPublic( .T. )
oGraMMod:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraMMod:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraMMod)

// Grafico Por Data de Interesse
oGraDInt := FWDSChart():New()
oGraDInt:SetName(STR0085) // Data do Interesse ( ANO MES )
oGraDInt:SetTitle(STR0085) // Data do Interesse ( ANO MES )
oGraDInt:SetID("GrafDInt")
oGraDInt:SetType("BARCOMPCHART")
oGraDInt:SetSeries({{"VDM", oSqlHlp:Concat({oSqlHlp:CompatFunc("SUBSTR")+"(VDM_DATINT,5,2)","'/'",oSqlHlp:CompatFunc("SUBSTR")+"(VDM_DATINT,1,4)"}),"COUNT"}})
oGraDInt:SetCategory({{"VDM", oSqlHlp:Concat({oSqlHlp:CompatFunc("SUBSTR")+"(VDM_DATINT,5,2)","'/'",oSqlHlp:CompatFunc("SUBSTR")+"(VDM_DATINT,1,4)"}) }})
oGraDInt:SetPublic( .T. )
oGraDInt:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraDInt:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraDInt)

// Grafico Por Motivo de Cancelamento
oGraCanc := FWDSChart():New()
oGraCanc:SetName(STR0086) // Motivo do Cancelamento
oGraCanc:SetTitle(STR0086) // Motivo do Cancelamento
oGraCanc:SetID("GrafCanc")
oGraCanc:SetType("BARCOMPCHART")
oGraCanc:SetSeries({{"VDM", "VDM_MOTCAN" ,"COUNT"}})
oGraCanc:SetCategory({{"VDM", "VDM_MOTCAN" }})
oGraCanc:SetPublic( .T. )
oGraCanc:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGraCanc:SetTitleAlign( CONTROL_ALIGN_CENTER ) 
oTableAtt:AddChart(oGraCanc)

Return (oTableAtt)

/*/{Protheus.doc} VCM680011_FaseAutomaticaInteresse
Altera/Grava automaticamente a Fase do Interesse conforme o Status do Atendimento

@author Andre
@since 24/10/2018
/*/
Function VCM680011_FaseAutomaticaInteresse( cFilAte , cNumAte , cStaAte )
Local cFaseAuto  := ""
Local cQuery     := ""
Local cQAlSQL    := "SQLAUX"
Local nTCodFas   := TamSX3("VDK_CODFAS")[1]
Local nAux       := 0
Local cVQL_DADOS := ""
Default cFilAte  := ""
Default cNumAte  := ""
Default cStaAte  := "X"
//
cQuery := "SELECT VQL_DADOS "
cQuery += "  FROM "+RetSqlName("VQL")
cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"'"
cQuery += "   AND VQL_AGROUP = 'DE->PARA'"
cQuery += "   AND VQL_TIPO   = 'ATEND->OPORT'"
cQuery += "   AND VQL_FILORI = '" + xFilial("VDK") + "'"
cQuery += "   AND D_E_L_E_T_=' '"
cVQL_DADOS := FM_SQL(cQuery)
nAux := at("/"+cStaAte+"=",cVQL_DADOS)
If nAux > 0
	cFaseAuto := substr(cVQL_DADOS,nAux+3,nTCodFas)
EndIf
If !Empty(cFaseAuto) .and. !Empty(cFilAte+cNumAte)
	cQuery := "SELECT R_E_C_N_O_ AS RECVDM "
	cQuery += "  FROM "+RetSQLName("VDM")
	cQuery += " WHERE VDM_FILIAL='"+xFilial("VDM")+"'"
	cQuery += "   AND VDM_FILATE='"+cFilAte+"'"
	cQuery += "   AND VDM_NUMATE='"+cNumAte+"'"
	cQuery += "   AND VDM_CODFAS<>'"+cFaseAuto+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		//
		DbSelectArea("VDM")
		DbGoTo( ( cQAlSQL )->( RECVDM ) )
		//
		VDL->(dbSetOrder(1))
		VDL->(dbSeek(xFilial("VDL")+VDM->VDM_CODOPO))
		//
		VCM680GRV(4,.t.,cFaseAuto)
		//
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VDM")
EndIf
Return

/*/{Protheus.doc} VCM6800016_BancoDeConhecimento
Chamada do Banco de Conhecimento para Interesses Oport. de Negócios

@author Fernando Vitor Cavani
@since 08/11/2018
@version undefined

@type function
/*/
Function VCM6800016_BancoDeConhecimento()
Local nRecNo := oAuxGetDados:aCols[oAuxGetDados:nAt, FG_POSVAR("VDM_REC_WT", "aHeader")]

If nRecNo > 0
	MsDocument("VDM", nRecNo, 4)
EndIf
Return

/*/{Protheus.doc} VCM680021_Executar
	Incluir com Veiculos

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Function VCM680021_Executar(cTp)
Private lIncVDL := .t.
If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	lIncVDL := .f.
EndIf
If cTp == "I"
	VCM680I() // Incluir
Else
	VCM680(Alias(), &(Alias()+"->(RecNo())") , IIf(cTp=='A',4,2) , {}, .f.) // Alterar/Visualizar
EndIf
If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	OA1200061_RefreshBrowse() // Refresh nos Browse's do OFIA120
EndIf
lIncVDL := .t.
Return

/*/{Protheus.doc} VCM680031_LevantaFasesPorSequenciaEtapa
	Levanta as possiveis Fases por Sequencia de Etapa do Funil

	@author Andre Luis Almeida
	@since 22/07/2019
/*/
Function VCM680031_LevantaFasesPorSequenciaEtapa(cTp)
Local cQuery  := ""
Local cQAlias := "SQLETAPAS"
Local nPosSeq := 0
Local aEtapas := {}
Local aArea   := GetArea()
cQuery := "SELECT DISTINCT VQT.VQT_SEQUEN , VDK.VDK_CODFAS "
cQuery += "  FROM " + RetSqlName("VDK") + " VDK "
cQuery += "  JOIN " + RetSqlName("VQT") + " VQT ON VQT.VQT_FILIAL='"+xFilial("VQT")+"' AND VQT.VQT_CODIGO=VDK.VDK_CODETA AND VQT.VQT_TIPETA='"+cTp+"' AND VQT.D_E_L_E_T_=' '"
cQuery += " WHERE VDK.VDK_FILIAL = '"+xFilial("VDK")+"'"
cQuery += "   AND VDK.VDK_TIPFAS = '"+cTp+"'"
cQuery += "   AND VDK.VDK_ATIVO <> '0'"
cQuery += "   AND VDK.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VQT.VQT_SEQUEN , VDK.VDK_CODFAS "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
While !(cQAlias)->(Eof())
 	// Tenta achar a Sequencia da Etapa
	nPosSeq := aScan(aEtapas, { |x| x[1] == (cQAlias)->( VQT_SEQUEN ) })
	If nPosSeq == 0
		aAdd(aEtapas,{ (cQAlias)->( VQT_SEQUEN ) , (cQAlias)->( VDK_CODFAS ) })
	Else
		aEtapas[nPosSeq,2] += "/"+(cQAlias)->( VDK_CODFAS ) // Codigo da Fase
	EndIf
	(cQAlias)->(dbSkip())
End
(cQAlias)->(dbCloseArea())
RestArea( aArea )
Return aEtapas

/*/{Protheus.doc} VCM680041_GerarAgendaCEV
	Gerar Agenda CEV

	@author Andre Luis Almeida
	@since 13/05/2020
/*/
Function VCM680041_GerarAgendaCEV(aVetPar)
Local cCodVC1     := ""
Local cVAI_TPAGDF := Space(GeTSX3Cache("VC1_TIPAGE","X3_TAMANHO"))
Local aRet        := {}
Local aParamBox   := {}
Default aVetPar   := { VDM->(RecNo()) , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" }
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
If VAI->(ColumnPos("VAI_TPAGDF")) > 0
	cVAI_TPAGDF := VAI->VAI_TPAGDF
EndIf
DbSelectArea("VDM")
If aVetPar[01] > 0 // RecNo VDM
	DbGoTo(aVetPar[1])
	DbSelectArea("VDL")
	DbSetOrder(1)
	DbSeek( VDM->VDM_FILIAL + VDM->VDM_CODOPO )
	aVetPar[02] := VDM->VDM_CODVEN // Vendedor
	aVetPar[03] := VDL->VDL_CODCLI // Codigo do Cliente
	aVetPar[04] := VDL->VDL_LOJCLI // Loja do Cliente
	aVetPar[05] := VDL->VDL_CDPROS // Codigo do Prospect
	aVetPar[06] := VDL->VDL_LJPROS // Loja do Prospect
	aVetPar[07] := VDM->VDM_FILIAL // Filial VDM
	aVetPar[08] := VDM->VDM_CODINT // Codigo do Interesse
	aVetPar[09] := VDM->VDM_CODMAR // Marca
	aVetPar[10] := VDM->VDM_MODVEI // Modelo
	aVetPar[11] := VDM->VDM_UUID   // UUID do VDM (para relacionar com VC1)
EndIf
If Empty(aVetPar[02])
	aVetPar[02] := VAI->VAI_CODVEN // Se nao passou Vendedor - preencher com o do usuario logado
EndIf
AADD(aParamBox,{1,RetTitle("VC1_TIPAGE"),cVAI_TPAGDF,"@!",'FG_Seek("VC5","MV_PAR01",1)',"VC5",".T.",50,.T.}) // Tipo de Agenda
AADD(aParamBox,{1,RetTitle("VC1_DATAGE"),ctod(""),"@D","MV_PAR02>=dDataBase","",".T.",50,.T.}) // Data da Agenda
AADD(aParamBox,{1,RetTitle("VC1_CODVEN"),aVetPar[02],"@!",'FG_Seek("SA3","MV_PAR03",1)',"SA3",".T.",50,.T.}) // Vendedor
If !Empty(aVetPar[03]+aVetPar[04]) // Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+aVetPar[03]+aVetPar[04]))
	AADD(aParamBox,{1,STR0097,aVetPar[03]+"-"+aVetPar[04]+" "+left(SA1->A1_NOME,25),"@!",".f.","",".f.",120,.t.}) // Cliente
Else // Prospect
	SUS->(DbSetOrder(1))
	SUS->(DbSeek(xFilial("SUS")+aVetPar[05]+aVetPar[06]))
	AADD(aParamBox,{1,STR0098,aVetPar[05]+"-"+aVetPar[06]+" "+left(SUS->US_NOME,25),"@!",".f.","",".f.",120,.t.}) // Prospect
EndIf
AADD(aParamBox,{11,STR0099,"","","",.t.}) // Objetivo
If !Empty(aVetPar[11])
	aAdd(aParamBox,{5,STR0100+IIf(!Empty(aVetPar[08]),aVetPar[08],STR0101)+" - "+aVetPar[09]+" "+Alltrim(aVetPar[10]),.t.,130,"",.F.}) // Relaciona com o Interesse: / NOVO
EndIf
If ParamBox(aParamBox,STR0094,@aRet,,,,,,,,.f.) // Gerar Agenda CEV
	DbSelectArea("VC1")
	cCodVC1 := FS_AGENDA(aRet[1],aRet[2],aRet[3],aVetPar[03],aVetPar[04],,,,aRet[5],aVetPar[05],aVetPar[06])
	If !Empty(cCodVC1) // Gerou VC1
		If !Empty(aVetPar[11]) .and. aRet[6] .and. ExistFunc("VA1700011_Grava_Relacionamento")
			If !Empty(aVetPar[08]) // Se ja existe VDM, ja faz o relacionamento no momento que gera a Agenda
				VA1700011_Grava_Relacionamento( "1" , xFilial("VC1") , cCodVC1 , aVetPar[07] , aVetPar[11] )
			Else // Caso seja um VDM novo, fazer o relacionamento somente na funcao de gravacao
				aAdd(aRelNOVOS,{ xFilial("VC1") , cCodVC1 , aVetPar[07] , aVetPar[11] }) // Novos Interesses, fazer relacionamento na Gravacao
			EndIf'
		EndIf
	EndIf
EndIf
DbSelectArea("VDM")
Return

/*/{Protheus.doc} VCM680051_RelacionarAgendaCEV
	Relacionar Agenda CEV

	@author Andre Luis Almeida
	@since 18/05/2020
/*/
Function VCM680051_RelacionarAgendaCEV()
Local lOkTela := .f.
Local aSize   := FWGetDialogSize( oMainWnd )
Local nCntFor := 0
Local aVetRel := {}
Local cQuery  := ""
Local cQAlias := "SQLVC1"
Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
//
nOpc := 2
//
DbSelectArea("VDM")
DbSelectArea("VDL")
DbSetOrder(1)
DbSeek( VDM->VDM_FILIAL + VDM->VDM_CODOPO )
//
cQuery := "SELECT VC1.VC1_TIPAGE , VC1.VC1_CODVEN ,"
cQuery += "       VC1.VC1_DATAGE , VC1.VC1_DATVIS ,"
cQuery += "       VC1.VC1_FILIAL , VC1.VC1_CODIGO ,"
cQuery += "       SA3.A3_NOME ,"
cQuery += "       VCS.R_E_C_N_O_ AS RECVCS "
cQuery += "  FROM "+RetSQLName("VC1")+" VC1"
cQuery += "  LEFT JOIN "+RetSQLName("SA3")+" SA3 ON SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VC1.VC1_CODVEN AND SA3.D_E_L_E_T_=' '"
cQuery += "  LEFT JOIN "+RetSQLName("VCS")+" VCS ON VCS.VCS_FILIAL='"+xFilial("VCS")+"' AND VCS.VCS_TIPO='1' AND VCS.VCS_FILPRI=VC1.VC1_FILIAL AND VCS.VCS_CODPRI=VC1.VC1_CODIGO AND VCS.VCS_FILREL='"+VDM->VDM_FILIAL+"' AND VCS.VCS_CODREL='"+VDM->VDM_UUID+"' AND VCS.D_E_L_E_T_=' '"
cQuery += " WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"'"
cQuery += "   AND VC1.VC1_CODCLI='"+VDL->VDL_CODCLI+"'"
cQuery += "   AND VC1.VC1_LOJA='"+VDL->VDL_LOJCLI+"'"
cQuery += "   AND VC1.VC1_CDPROS='"+VDL->VDL_CDPROS+"'"
cQuery += "   AND VC1.VC1_LJPROS='"+VDL->VDL_LJPROS+"'"
cQuery += "   AND VC1.D_E_L_E_T_=' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
While !( cQAlias )->( Eof() )
	aadd(aVetRel,{	( ( cQAlias )->( RECVCS ) > 0 ) ,; // Deixa desmarcar e marcar
					( cQAlias )->( VC1_TIPAGE ) ,;
					stod(( cQAlias )->( VC1_DATAGE )) ,;
					stod(( cQAlias )->( VC1_DATVIS )) ,;
					( cQAlias )->( VC1_CODVEN )+" "+( cQAlias )->( A3_NOME ) ,;
					( cQAlias )->( VC1_FILIAL ) ,;
					( cQAlias )->( VC1_CODIGO ) ,;
					( cQAlias )->( RECVCS ) })
	( cQAlias )->( dbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

If len(aVetRel) == 0
	MsgStop(STR0102,STR0029) // Não existem Agendas do Cliente para fazer o relacionamento. / Atencao
	Return
EndIf

DbSelectArea("VDM")
RegToMemory("VDM",.f.)

oVCM510REL := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4],STR0103, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Relacionamendo de Agenda CEV

oWorkArea := FWUIWorkArea():New( oVCM510REL )
oWorkArea:CreateHorizontalBox( "LINE01", 50 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "PRINCIPAL" } )
oWorkArea:CreateHorizontalBox( "LINE02", 40 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "RELACIONADOS" } )
oWorkArea:Activate()

oEnchVC1 := MSMGet():New( "VDM", VDM->(RecNo()) , nOpc ,;
		/* aCRA */, /* cLetra */, /* cTexto */, /*aCampos*/, {0,0,aSize[3]-50,0}, , 3,;
		/* nColMens */, /* cMensagem */, ".t." , oWorkarea:GetPanel("PRINCIPAL") , .f., .t., .t. /* lColumn */ ,;
		"", .t. /* lNoFolder */, .f.)
oEnchVC1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oLbRel := TWBrowse():New(0,0,50,50,,,,oWorkarea:GetPanel("RELACIONADOS") ,,,,,{ || aVetRel[oLbRel:nAt,01] := !aVetRel[oLbRel:nAt,01] },,,,,,,.F.,,.T.,,.F.,,,)
oLbRel:addColumn( TCColumn():New( "", { || IIf(aVetRel[oLbRel:nAt,01],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_TIPAGE") , { || aVetRel[oLbRel:nAt,02] } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_DATAGE") , { || Transform(aVetRel[oLbRel:nAt,03],"@D") } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_DATVIS") , { || Transform(aVetRel[oLbRel:nAt,04],"@D") } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_CODVEN") , { || aVetRel[oLbRel:nAt,05] } ,,,, "LEFT" , 99 ,.F.,.F.,,,,.F.,) )
oLbRel:Align := CONTROL_ALIGN_ALLCLIENT
oLbRel:nAT := 1
oLbRel:SetArray(aVetRel)

ACTIVATE MSDIALOG oVCM510REL ON INIT (EnchoiceBar(oVCM510REL,{|| ( lOkTela := .t. , oVCM510REL:End() ) },{ || oVCM510REL:End()},,))
//
If lOkTela
	For nCntFor := 1 to len(aVetRel)
		Do Case
			Case aVetRel[nCntFor,1] .and. aVetRel[nCntFor,8] == 0 // Selecionou um Registro que nao tinha relacionamento
				VA1700011_Grava_Relacionamento( "1" , aVetRel[nCntFor,6] , aVetRel[nCntFor,7] , VDM->VDM_FILIAL , VDM->VDM_UUID ) // Relacionar
			Case !aVetRel[nCntFor,1] .and. aVetRel[nCntFor,8] > 0 // Retirou um Registro que estava relacionado
				DbSelectArea("VCS")
				DbGoTo(aVetRel[nCntFor,8])
				RecLock("VCS", .F., .T.)
					dbdelete() // Apagar Relacionamento
				MsUnlock()
		EndCase
	Next
EndIf
//
Return

/*/{Protheus.doc} VCM680061_SelecaoPacote
	Selecionar/Visualizar Pacote referente ao Interesse

	@author Andre Luis Almeida
	@since 08/07/2021
/*/
Function VCM680061_SelecaoPacote(nOpc)
Local lVDMSEGMOD := ( VDM->(FieldPos("VDM_SEGMOD")) > 0 )
Local lVDMCODPAC := ( VDM->(FieldPos("VDM_CODPAC")) > 0 )
Local lVDMBASCOD := ( VDM->(FieldPos("VDM_BASCOD")) > 0 )
Local aRetVA242  := {}
Local nOpcAviso  := 0
Local cDesPac    := ""
If lVDMSEGMOD .and. lVDMCODPAC .and. lVDMBASCOD
	VCM680Fx(nOpc,.F.)
	If nOpc == 3 .or. nOpc == 4
		If !Empty(M->VDM_CODPAC) // Possui Pacote relacionado
			If !Empty(M->VDM_NUMATE) // Possui Atendimento criado
				nOpcAviso := 2 // Visualizar Pacote
			ElseIf !Empty(M->VDM_CODMAR+M->VDM_MODVEI) // Marca/Modelo informado
				cDesPac := Alltrim(FM_SQL("SELECT VN0_DESPAC FROM "+RetSqlName("VN0")+" WHERE VN0_FILIAL='"+xFilial("VN0")+"' AND VN0_CODIGO='"+M->VDM_CODPAC+"' AND D_E_L_E_T_=' '"))
				nOpcAviso := AVISO(STR0104,; // Pacote de Configuração
									STR0105+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Existe um Pacote de Configuração informado para este Interesse.
									M->VDM_CODMAR+" "+M->VDM_MODVEI+" "+M->VDM_SEGMOD+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
									Alltrim(RetTitle("VDM_CODPAC"))+": "+M->VDM_CODPAC+" - "+cDesPac+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
									Alltrim(RetTitle("VDM_BASCOD"))+": "+M->VDM_BASCOD+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
									STR0106,; // Deseja Visualizar ou Alterar o Pacote?
									{ STR0005 , STR0003 , STR0107 }, 3) // Alterar / Visualizar / Fechar
			EndIf
		ElseIf !Empty(M->VDM_CODMAR+M->VDM_MODVEI) // Marca/Modelo informado
			If Empty(M->VDM_NUMATE) // Não possui Atendimento criado
				nOpcAviso := 1 // Incluir Pacote
			EndIf
		EndIf
	Else
		If !Empty(M->VDM_CODPAC) // Possui Pacote relacionado
			nOpcAviso := 2 // Visualizar Pacote
		EndIf
	EndIf
	If nOpcAviso == 1 // Incluir ou Alterar Pacote
		aRetVA242 := VEIA242( M->VDM_CODMAR , M->VDM_MODVEI , M->VDM_SEGMOD , "" , .t. )
		If len(aRetVA242) > 0 .and. !Empty(aRetVA242[1]) // Selecionou um Pacote
			M->VDM_CODPAC := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_CODPAC")] := aRetVA242[1] // Código do Pacote
			M->VDM_BASCOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_BASCOD")] := aRetVA242[2] // Base Code
			M->VDM_VLRNEG := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_VLRNEG")] := aRetVA242[3] // Valor
		Else
			M->VDM_CODPAC := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_CODPAC")] := space(TamSX3("VDM_CODPAC")[1])
			M->VDM_BASCOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDM_BASCOD")] := space(TamSX3("VDM_BASCOD")[1])
		EndIf
	ElseIf nOpcAviso == 2 // Visualizar Pacote
		 VEIC140( M->VDM_CODPAC ) // Visualizar Pacote
	EndIf	
	VCM680Fx(nOpc,.T.)
EndIf
Return