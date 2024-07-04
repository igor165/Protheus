// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 12     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICM560.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VEICM560 | Autor ³  Ronaldo A. Ferreira  ³ Data ³ 09/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Informacoes Adicionais sobre o Cliente CEV                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM560(cCodCli,cLojCli)
Local cFiltro     := ""
Local lCEVOUT     := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Local lNewVend    := ( VCF->(FieldPos("VCF_VENVEU")) > 0 ) // Possui campos novos Vendedores
Default cCodCli   := ""
Default cLojCli   := ""
Private aCampos   := {}
Private cAlias    := "VCF"
Private nReg      := 1
Private nOpc      := 1
Private aRotina   := MenuDef()
Private cCadastro := (STR0001)

If !Empty(cCodCli)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLojCli)))
	cFiltro  := " VCF_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND VCF_LOJCLI='"+cLojCli+"' ","")
EndIf

VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If lCEVOUT
	If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	    if !Empty(cFiltro)
		    cFiltro += " AND "
		Endif
		If lNewVend // Novos Vendedores
			cFiltro += " (VCF_VENSRV='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENPEC='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENVEI='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENVEU='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENPNE='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENOUT='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "(VCF_VENSRV=' ' AND VCF_VENPEC=' ' AND VCF_VENVEI=' ' AND VCF_VENVEU=' ' AND VCF_VENPNE=' ' AND VCF_VENOUT=' '))"
		Else
			cFiltro += " (VCF_VENSRV='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENPEC='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "VCF_VENVEI='"+VAI->VAI_CODVEN+"' OR "
			cFiltro += "(VCF_VENSRV=' ' AND VCF_VENPEC=' ' AND VCF_VENVEI=' '))"
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VCF",,,,,,,,,,,,,,cFiltro)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEICM560VAL| Autor ³ Andre Luis Almeida  ³ Data ³ 12/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 1 - Verifica se o Cliente ja existe no VCF                ³±±
±±³          ³ 2 - Grava Receita Bruta Mes / Mil Atual                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM560VAL(nT)
Local lRet := .f.
Local cRecBru := ""
If nT == 1 // Verifica se o Cliente ja existe no VCF
	DbSelectArea("VCF")
	DbSetOrder(1)
	If !DbSeek( xFilial("VCF") + M->VCF_CODCLI + M->VCF_LOJCLI )
		lRet := .t.
	Else
		MsgAlert(STR0007,STR0008)
	EndIf
ElseIf nT == 2 // Grava Receita Bruta Mes / Mil Atual
	lRet := .t.
	cRecBru := left(M->VCF_RECVIS+space(75),75)
	If Transform(dDataBase,"@D") # left(cRecBru,8)
		M->VCF_RECVIS := Transform(dDataBase,"@D")+str(M->VCF_RECBRU,7)+left(cRecBru,60)
	Else
		M->VCF_RECVIS := Transform(dDataBase,"@D")+str(M->VCF_RECBRU,7)+right(cRecBru,60)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM560A1 | Autor ³ Andre Luis Almeida  ³ Data ³ 25/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama Cadastro de Clientes (SA1) - Visualizar/Alterar    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM560A1(nTp)
Local lALTSA1    := ( VAI->(FieldPos("VAI_ALTSA1")) > 0 )
Private cVA      := " "
Private aRotAuto := Nil
Default nTp      := 1
If nTp == 1
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+VCF->VCF_CODCLI+VCF->VCF_LOJCLI)
Else
	If Empty(M->VCF_CODCLI+M->VCF_LOJCLI)
		Return()
	EndIf
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+M->VCF_CODCLI+M->VCF_LOJCLI)
EndIf
cAlias := "SA1"
nReg := SA1->(RecNo())
If lALTSA1 .and. FGX_USERVL( xFilial("VAI"),__cUserID, "VAI_ALTSA1", "==" ,"1") // Usuario pode Alterar o SA1 (Cliente)
	DEFINE MSDIALOG oDlg TITLE STR0022 From 5,08 to 10,45 of oMainWnd
	@ 006,012 SAY SA1->A1_NOME SIZE 300,08 OF oDlg  PIXEL COLOR CLR_BLUE
	@ 020,012 BUTTON oVis PROMPT (STR0023) OF oDlg SIZE 55,10 PIXEL ACTION (cVA:="V",oDlg:End())
	@ 020,080 BUTTON oAtu PROMPT (STR0024) OF oDlg SIZE 55,10 PIXEL ACTION (cVA:="A",oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTER
Else
	cVA:="V"
EndIf
If cVA $ "VA"
	DbSelectArea("SX3")
	dbgotop()
	dbseek("SA102")
	aCampos := {}
	do While !eof() .and. x3_arquivo == "SA1"
		if X3USO(x3_usado) .And. cNivel>=x3_nivel //.And. x3_campo $ [VGA_NUMOSV/VGA_NUMNFI/VGA_SERIEN/VGA_CHASSI/VGA_CODGAR/VGA_DESGAR/VGA_DESMAR/VGA_CODCLI/VGA_NOMCLI/VGA_ABEGAR/VGA_DATFEC]
			aadd(aCampos,x3_campo)
		endif
		dbskip()
	Enddo
	If cVA == "V" // Visualizar SA1
		cCadastro := (STR0022)+" - "+STR0023
		nOpc := 2
		AxVisual(cAlias,nReg,nOpc,aCampos)
	ElseIf cVA == "A" // Alterar SA1
		cCadastro := (STR0022)+" - "+STR0024
		nOpc := 4
		A030Altera(cAlias,nReg,nOpc,aCampos)
	EndIf
	cCadastro := (STR0001)
EndIf
cAlias := "VCF"
nReg := 0
nOpc := 0
DbSelectArea("VCF")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM560X| Autor ³ Andre Luis Almeida   ³ Data ³ 25/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza 1-Vendedor 2-Periodicidade (Veic/Pecas/Servicos) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM560X(nTp)
Local cTitTela  := ""
Local lCEVOUT   := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Local lClassC   := ( VCF->(FieldPos("VCF_CLAPEC")) > 0 ) // Classificacao do Cliente
Local lNewVend  := ( VCF->(FieldPos("VCF_VENVEU")) > 0 ) // Possui campos novos Vendedores
Local aTipAtu   := ({STR0011,STR0012})
Local aTpVend   := ({STR0014,STR0015,STR0013})
Local aTpClas   := ({STR0014,STR0015,STR0013})
Local cTpVend   := STR0013
Local cTpClas   := STR0013
Local aClassC   := {STR0037,"","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
Private cTipAtu := STR0011
Private cCEPIni := space(8)
Private cCEPFin := space(8)
Private lCEP    := .t.
Private cCdVend := space(6)
Private cClassC := STR0037
Private nDiaPer := 0
Private lOk     := .f.
//
If lNewVend
	aTpClas := ({STR0014,STR0015,STR0013,STR0042,STR0043,STR0044})
	aTpVend := ({STR0014,STR0015,STR0013,STR0042,STR0043,STR0044})
EndIf
//
If nTp == 1 // Vendedor
	cTitTela := STR0010
	If lCEVOUT
		VAI->(DbSetOrder(4))
		VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
		If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
			MsgStop(STR0025,STR0008) // Usuario sem permissao para alterar o vendedor. / Atencao
			Return()
		EndIf
	EndIf
ElseIf nTp == 2 // Periodicidade
	If VCF->(FieldPos("VCF_CLAPEC")) <= 0 
		MsgAlert(STR0040,STR0008) // Opcao nao disponivel. / Atencao
		Return()
	EndIf
	cTitTela := STR0020
EndIf
DEFINE MSDIALOG oDlg TITLE cTitTela From 05,08 to 19,45 of oMainWnd
@ 009,010 SAY STR0017 SIZE 60,10 OF oDlg  PIXEL COLOR CLR_BLUE
@ 008,062 MSCOMBOBOX oTipAtu VAR cTipAtu ITEMS aTipAtu VALID FS_VCM560("TIPATU") SIZE 76,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 021,010 SAY STR0018 SIZE 60,10 OF oDlg  PIXEL COLOR CLR_BLUE
@ 020,062 MSGET oCEPIni VAR cCEPIni PICTURE "@R 99999-999" SIZE 20,8 OF oDlg PIXEL COLOR CLR_BLUE when lCEP
@ 033,010 SAY STR0019 SIZE 60,10 OF oDlg  PIXEL COLOR CLR_BLUE
@ 032,062 MSGET oCEPFin VAR cCEPFin PICTURE "@R 99999-999" SIZE 20,8 VALID ( cCEPIni <= cCEPFin ) OF oDlg PIXEL COLOR CLR_BLUE when lCEP
@ 045,010 SAY STR0036 SIZE 60,10 OF oDlg PIXEL COLOR CLR_BLUE
@ 044,062 MSCOMBOBOX oClassC VAR cClassC ITEMS aClassC VALID FS_VCM560("CLASSC") SIZE 28,08 OF oDlg PIXEL COLOR CLR_BLUE when ( lCEP .and. lClassC )
@ 044,090 MSCOMBOBOX oTpClas VAR cTpClas ITEMS aTpClas SIZE 48,08 OF oDlg PIXEL COLOR CLR_BLUE when ( lCEP .and. lClassC )
oTpClas:lVisible := .f.
@ 053,000 SAY repl("_",200) SIZE 400,10 OF oDlg  PIXEL COLOR CLR_RED
If nTp == 1 // Vendedor
	@ 066,010 SAY STR0021 SIZE 60,10 OF oDlg  PIXEL COLOR CLR_BLUE
	@ 065,055 MSGET oCdVend VAR cCdVend PICTURE "@!" F3 "SA3" VALID FS_VCM560("CDVEND") SIZE 35,8 OF oDlg PIXEL COLOR CLR_BLUE
ElseIf nTp == 2 // Periodicidade
	@ 066,010 SAY STR0038 SIZE 60,10 OF oDlg  PIXEL COLOR CLR_BLUE
	@ 065,060 MSGET oDiaPer VAR nDiaPer PICTURE "@E 999" VALID Positivo() SIZE 30,8 OF oDlg PIXEL COLOR CLR_BLUE
EndIf
@ 065,090 MSCOMBOBOX oTpVend VAR cTpVend ITEMS aTpVend SIZE 48,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 074,000 SAY repl("_",200) SIZE 400,10 OF oDlg  PIXEL COLOR CLR_RED
DEFINE SBUTTON FROM 087,36 TYPE 1 ACTION (lOk:=.t.,oDlg:End()) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 087,87 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg CENTER
If lOk
	If cTipAtu == STR0011  // Todos Clientes
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") )
		While !Eof() .and. SA1->A1_FILIAL == xFilial("SA1")
			If cCEPIni <= SA1->A1_CEP .and. cCEPFin >= SA1->A1_CEP
				DbSelectArea("VCF")
				DbSetOrder(1)
				If !DbSeek( xFilial("VCF") + SA1->A1_COD + SA1->A1_LOJA )
					If cClassC == STR0037
						DbSelectArea("VCF")
						RecLock("VCF",.t.)
						VCF->VCF_FILIAL := xFilial("VCF")
						VCF->VCF_CODCLI := SA1->A1_COD
						VCF->VCF_LOJCLI := SA1->A1_LOJA
						Do Case
							Case cTpVend == STR0013 // Veic.Novos
								If nTp == 1 // Vendedor
									VCF->VCF_VENVEI := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPER := nDiaPer
								EndIf
							Case cTpVend == STR0042 // Veic.Usados
								If nTp == 1 // Vendedor
									VCF->VCF_VENVEU := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAVEU := nDiaPer
								EndIf
							Case cTpVend == STR0014 // Pecas
								If nTp == 1 // Vendedor
									VCF->VCF_VENPEC := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPEP := nDiaPer
								EndIf
							Case cTpVend == STR0015 // Servicos
								If nTp == 1 // Vendedor
									VCF->VCF_VENSRV := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPES := nDiaPer
								EndIf
							Case cTpVend == STR0043 // Pneus
								If nTp == 1 // Vendedor
									VCF->VCF_VENPNE := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPNE := nDiaPer
								EndIf
							Case cTpVend == STR0044 // Outros
								If nTp == 1 // Vendedor
									VCF->VCF_VENOUT := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAOUT := nDiaPer
								EndIf
						EndCase
						if VCF->(fieldpos('VCF_DATALT')) > 0
							VCF->VCF_DATALT := fgx_TimeStamp()
							VCF->VCF_DATINC := VCF->VCF_DATALT
						endif
						if VCF->(fieldpos('VCF_UUID')) > 0
							VCF->VCF_UUID   := FwUUIDV4(.t.)
						endif
						MsUnLock()
					EndIf
				Else
					If cClassC == STR0037 .or. ;
						( cTpClas == STR0013 .and. cClassC == VCF->VCF_CLAVEI ) .or. ;
						( cTpClas == STR0042 .and. cClassC == VCF->VCF_CLAVEU ) .or. ;
						( cTpClas == STR0014 .and. cClassC == VCF->VCF_CLAPEC ) .or. ;
						( cTpClas == STR0015 .and. cClassC == VCF->VCF_CLASRV ) .or. ;
						( cTpClas == STR0043 .and. cClassC == VCF->VCF_CLAPNE ) .or. ;
						( cTpClas == STR0044 .and. cClassC == VCF->VCF_CLAOUT )
						DbSelectArea("VCF")
						RecLock("VCF",.f.)
						Do Case
							Case cTpVend == STR0013 // Veic.Novos
								If nTp == 1 // Vendedor
									VCF->VCF_VENVEI := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPER := nDiaPer
								EndIf
							Case cTpVend == STR0042 // Veic.Usados
								If nTp == 1 // Vendedor
									VCF->VCF_VENVEU := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAVEU := nDiaPer
								EndIf
							Case cTpVend == STR0014 // Pecas
								If nTp == 1 // Vendedor
									VCF->VCF_VENPEC := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPEP := nDiaPer
								EndIf
							Case cTpVend == STR0015 // Servicos
								If nTp == 1 // Vendedor
									VCF->VCF_VENSRV := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPES := nDiaPer
								EndIf
							Case cTpVend == STR0043 // Pneus
								If nTp == 1 // Vendedor
									VCF->VCF_VENPNE := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAPNE := nDiaPer
								EndIf
							Case cTpVend == STR0044 // Outros
								If nTp == 1 // Vendedor
									VCF->VCF_VENOUT := cCdVend
								ElseIf nTp == 2 // Periodicidade
									VCF->VCF_DIAOUT := nDiaPer
								EndIf
						EndCase
						if VCF->(fieldpos('VCF_DATALT')) > 0
							VCF->VCF_DATALT := fgx_TimeStamp()
						endif
						if VCF->(fieldpos('VCF_UUID')) > 0 .and. empty(VCF->VCF_UUID)
							VCF->VCF_UUID := FWUUIDV4(.t.)
						endif
						MsUnLock()
					EndIf
				EndIf
			EndIf
			DbSelectArea("SA1")
			DbSkip()
		EndDo
	Else  // Cliente Selecionado
		DbSelectArea("VCF")
		DbSetOrder(1)
		DbSeek( xFilial("VCF") + VCF->VCF_CODCLI + VCF->VCF_LOJCLI )
		RecLock("VCF",.f.)
		Do Case
			Case cTpVend == STR0013 // Veic.Novos
				If nTp == 1 // Vendedor
					VCF->VCF_VENVEI := cCdVend
				ElseIf nTp == 2 // Periodicidade
					VCF->VCF_DIAPER := nDiaPer
				EndIf
			Case cTpVend == STR0042 // Veic.Usados
				If nTp == 1 // Vendedor
					VCF->VCF_VENVEU := cCdVend
				ElseIf nTp == 2 // Periodicidade
					VCF->VCF_DIAVEU := nDiaPer
				EndIf
			Case cTpVend == STR0014 // Pecas
				If nTp == 1 // Vendedor
					VCF->VCF_VENPEC := cCdVend
				ElseIf nTp == 2 // Periodicidade
					VCF->VCF_DIAPEP := nDiaPer
				EndIf
			Case cTpVend == STR0015 // Servicos
				If nTp == 1 // Vendedor
					VCF->VCF_VENSRV := cCdVend
				ElseIf nTp == 2 // Periodicidade
					VCF->VCF_DIAPES := nDiaPer
				EndIf
			Case cTpVend == STR0043 // Pneus
				If nTp == 1 // Vendedor
					VCF->VCF_VENPNE := cCdVend
				ElseIf nTp == 2 // Periodicidade
					VCF->VCF_DIAPNE := nDiaPer
				EndIf
			Case cTpVend == STR0044 // Outros
				If nTp == 1 // Vendedor
					VCF->VCF_VENOUT := cCdVend
				ElseIf nTp == 2 // Periodicidade
					VCF->VCF_DIAOUT := nDiaPer
				EndIf
		EndCase
		if VCF->(fieldpos('VCF_DATALT')) > 0
			VCF->VCF_DATALT := fgx_TimeStamp()
		endif
		if VCF->(fieldpos('VCF_UUID')) > 0 .and. empty(VCF->VCF_UUID)
			VCF->VCF_UUID := FWUUIDV4(.t.)
		endif
		// alteração
		MsUnLock()
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VCM560| Autor ³ Ronaldo              ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacoes                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VCM560(cTipo)
Local lRet := .f.
If cTipo == "TIPATU"
	lRet := .t.
	If cTipAtu == STR0011  // Todos Clientes
		lCEP := .t.
		cCEPIni := space(8)
		cCEPFin := space(8)
	Else  // Cliente Selecionado
		lCEP := .f.
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + VCF->VCF_CODCLI + VCF->VCF_LOJCLI )
		cCEPIni := SA1->A1_CEP
		cCEPFin := SA1->A1_CEP
		cClassC := STR0037
	EndIf
	FS_VCM560("CLASSC")
ElseIf cTipo == "CDVEND"
	If Empty(cCdVend)
		lRet := .t.
	Else
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek( xFilial("SA3") + cCdVend )
			lRet := .t.
		EndIf
	EndIf
ElseIf cTipo == "CLASSC"
	lRet := .t.
	If cClassC == STR0037 // Todos
		oTpClas:lVisible := .f.
	Else // Classificacao selecionada
		oTpClas:lVisible := .t.
		oTpClas:SetFocus()
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  | Autor ³ Ronaldo              ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ MenuDef ( monta aRotina )                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}
aRotina := { {STR0002,"AxPesqui"   , 0 , 1},;	// Pesquisar
			{STR0003,"VEICM560VIS" , 0 , 2},;	// Visualizar
			{STR0004,"VEICM560INC" , 0 , 3},;	// Incluir
			{STR0005,"VEICM560ALT" , 0 , 4},;	// Alterar
			{STR0009,"VEICM560X(1)", 0 , 6},;	// Atualiza Vendedor
			{STR0039,"VEICM560X(2)", 0 , 6},;	// Atualiza Periodicidade
			{STR0016,"VCM560A1()"  , 0 , 4},;	// Chama Cadastro de Clientes (SA1) - Visualizar/Alterar
			{STR0026,"VM560PESQ()" , 0 , 1},;	// Pesquisa Avancada.
			{STR0006,"AXDELETA"    , 0 , 5}}	// Excluir

If (ExistBlock("VCM560MD")) // Ponto de Entrada para adicionar opções no Menu
	aRotina := ExecBlock("VCM560MD", .f., .f., {aRotina})
EndIf
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VM560PESQ | Autor ³ Rafael Goncalves     ³ Data ³ 19/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Avancada                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM560PESQ()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0
Local cNomeCli := SPACE(80)
Local cNivImp  := SPACE(LEN(VCF->VCF_NIVIMP))
Local cCodSeg  := SPACE(LEN(VCF->VCF_CODSEG))
Local lVerOutros := .t.
Private cCodVen  := SPACE(LEN(SA3->A3_COD))
Private cNomeVen := SPACE(LEN(SA3->A3_NOME))
Private aLevAdic := {}
aadd(aLevAdic,{"","","","","","",""})

VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If ( VAI->(FieldPos("VAI_CEVOUT")) > 0 )
	If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
		cCodVen    := VAI->VAI_CODVEN
		lVerOutros := .f.
	EndIf
EndIf

DbSelectArea("VCF")
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 44 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oPesqAdic TITLE STR0026 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL  //Pesquisa Avancada
//Objeto 01 cabecalho
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL STR0034 OF oPesqAdic PIXEL  //Filtro

@ aPosObj[1,1]+9,aPosObj[1,2]+4 SAY oNomCli VAR STR0027 SIZE 50,08 OF oPesqAdic PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+7,aPosObj[1,2]+50 MSGET oNomeCli VAR cNomeCli PICTURE "@!" SIZE 150,08 OF oPesqAdic PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+21,aPosObj[1,2]+4 SAY oVend VAR STR0028 SIZE 50,08 OF oPesqAdic PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+19,aPosObj[1,2]+50 MSGET oCodVen VAR cCodVen F3 "SA31" VALID(vazio() .or. FG_SEEK("SA3","cCodVen",1,.f.,"cNomeVen","A3_NOME")) SIZE 35,08 OF oPesqAdic PIXEL COLOR CLR_BLACK WHEN lVerOutros
@ aPosObj[1,1]+21,aPosObj[1,2]+95 SAY oNomVen VAR STR0029 SIZE 50,08 OF oPesqAdic PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+19,aPosObj[1,2]+141 MSGET oNomeVen VAR cNomeVen PICTURE "@!" SIZE 150,08 OF oPesqAdic PIXEL COLOR CLR_BLACK WHEN .f.

@ aPosObj[1,1]+33,aPosObj[1,2]+4 SAY oNiv VAR STR0030 SIZE 50,08 OF oPesqAdic PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+31,aPosObj[1,2]+50 MSGET oNivImp VAR cNivImp PICTURE "@!" SIZE 25,08 OF oPesqAdic PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+33,aPosObj[1,2]+127 SAY oCodSe VAR STR0031 SIZE 50,08 OF oPesqAdic PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+31,aPosObj[1,2]+173 MSGET oCodSeg VAR cCodSeg SIZE 25,08 OF oPesqAdic PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+10,aPosObj[1,4]-52 BUTTON oFintra PROMPT (STR0032) OF oPesqAdic SIZE 45,10 PIXEL ACTION FS_LEVANTA(cNomeCli,cCodVen,cNivImp,cCodSeg) //FILTRAR
@ aPosObj[1,1]+28,aPosObj[1,4]-52 BUTTON oSair PROMPT (STR0033) OF oPesqAdic SIZE 45,10 PIXEL ACTION oPesqAdic:End() // SAIR

@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLstAdic FIELDS HEADER STR0035,STR0027,STR0028,STR0029,STR0030,STR0031; //
COLSIZES 25,80,25,80,40,40 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oPesqAdic PIXEL ON DBLCLICK (Iif(!Empty(aLevAdic[oLstAdic:nAt,7]),VCF->(DbGoto(aLevAdic[oLstAdic:nAt,7])),.t.),oPesqAdic:End())
oLstAdic:SetArray(aLevAdic)
oLstAdic:bLine := { || {	aLevAdic[oLstAdic:nAt,1],;
aLevAdic[oLstAdic:nAt,2],;
aLevAdic[oLstAdic:nAt,3],;
aLevAdic[oLstAdic:nAt,4],;
aLevAdic[oLstAdic:nAt,5],;
aLevAdic[oLstAdic:nAt,6]}}
ACTIVATE MSDIALOG oPesqAdic

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVANTA| Autor ³ Rafael Goncalves     ³ Data ³ 19/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Informacoes da Pesquisa Avancada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(cNomeCli,cCodVen,cNivImp,cCodSeg)
Local lNewVend   := ( VCF->(FieldPos("VCF_VENVEU")) > 0 ) // Possui campos novos Vendedores
Local cQuery     := ""
Local cQAlias    := "SQLVSOP"
Local cFilSlv    := cFilAnt
Local cA3_COD    := ""
Local cA3_NOM    := ""
Local cAux       := ""
default cNomeCli := ""
default cCodVen  := ""
default cNivImp  := ""
default cCodSeg  := ""
aLevAdic:= {}
cQuery := "SELECT SA1.A1_NOME , VCF.VCF_CODCLI , VCF.VCF_LOJCLI , "
cQuery += "VCF.VCF_VENSRV , VCF.VCF_VENPEC , VCF.VCF_VENVEI , "
If lNewVend
	cQuery += "VCF.VCF_VENVEU , VCF.VCF_VENPNE , VCF.VCF_VENOUT , "
EndIf
cQuery += "VCF.VCF_NIVIMP , VCF.VCF_CODSEG , VCF.R_E_C_N_O_ AS RECVCF "
cQuery += "FROM "+RetSqlName("VCF")+" VCF "
cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON (VCF.VCF_CODCLI=SA1.A1_COD AND VCF.VCF_LOJCLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' ') WHERE "
if !Empty(cNomeCli) //Nome Cliente
	cQuery += "SA1.A1_NOME LIKE '" +Alltrim(cNomeCli)+ "%' AND "
EndIf
If !Empty(cNivImp)//Codigo Vendedor
	cQuery += "VCF.VCF_NIVIMP='"+cNivImp+"' AND "
EndIf
If !Empty(cCodSeg)//Codigo Vendedor
	cQuery += "VCF.VCF_CODSEG='"+cCodSeg+"' AND "
EndIf
cQuery += "VCF.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	lOk := .f.
	cAux := Alltrim(( cQAlias )->( VCF_VENSRV ))+" "+Alltrim(( cQAlias )->( VCF_VENPEC ))+" "+Alltrim(( cQAlias )->( VCF_VENVEI ))
	If lNewVend
		cAux += " "+Alltrim(( cQAlias )->( VCF_VENVEU ))+" "+Alltrim(( cQAlias )->( VCF_VENPNE ))+" "+Alltrim(( cQAlias )->( VCF_VENOUT ))
	EndIf
	If Empty(Alltrim(cAux))
		lOk := .t.
	Else
		If !Empty(cCodVen) //Codigo Vendedor
			If cCodVen $ cAux
				lOk := .t.
			EndIf
		Else
			lOk := .t.
		EndIf
	EndIf
	If lOk
		If !Empty(cCodVen) //Codigo Vendedor
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek(xFilial("SA3")+cCodVen)
			cA3_COD := SA3->A3_COD
			cA3_NOM := SA3->A3_NOME
		Else
			cA3_COD := ""
			cA3_NOM := ""
			If len(Alltrim(cAux)) == 6
				DbSelectArea("SA3")
				DbSetOrder(1)
				DbSeek(xFilial("SA3")+Alltrim(cAux))
				cA3_COD := SA3->A3_COD
				cA3_NOM := SA3->A3_NOME
			ElseIf len(Alltrim(cAux)) > 6
				cA3_NOM := Alltrim(cAux)
			EndIf
		EndIf
 		aadd(aLevAdic,{	( cQAlias )->( VCF_CODCLI )+" - "+( cQAlias )->( VCF_LOJCLI ) ,;
					( cQAlias )->( A1_NOME ),;
					cA3_COD ,;
					cA3_NOM ,;
					( cQAlias )->( VCF_NIVIMP ),;
					( cQAlias )->( VCF_CODSEG ),;
					( cQAlias )->( RECVCF )})
	EndIf
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
DbSelectArea("VCF")
If len(aLevAdic) <= 0
	aadd(aLevAdic,{"","","","","","",""})
EndIf
oLstAdic:SetArray(aLevAdic)
oLstAdic:bLine := { || {	aLevAdic[oLstAdic:nAt,1],;
aLevAdic[oLstAdic:nAt,2],;
aLevAdic[oLstAdic:nAt,3],;
aLevAdic[oLstAdic:nAt,4],;
aLevAdic[oLstAdic:nAt,5],;
aLevAdic[oLstAdic:nAt,6]}}
cFilAnt := cFilSlv
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEICM560INC| Autor ³ Ronaldo             ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inclui VCF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM560INC()
Local aButtons := {} 
Private nOpcInc := 3
aButtons := { {"BMPUSER",{|| VCM560A1(2) },STR0016} } //Cadastro do Cliente 
AXINCLUI("VCF",VCF->(RECNO()),3,,,,"VM560VDA(nOpcInc)",,,aButtons)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEICM560ALT| Autor ³ Ronaldo             ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera VCF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM560ALT()
Local aButtons := {}
Private nOpcAlt := 4
aButtons := { {"BMPUSER",{|| VCM560A1(2) },STR0016} } //Cadastro do Cliente
AXALTERA("VCF",VCF->(RECNO()),4,,,,,"VM560VDA(nOpcAlt)",,,aButtons)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEICM560VIS| Autor ³ Ronaldo             ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza VCF                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM560VIS()
Local aButtons := {}
aButtons := { {"BMPUSER",{|| VCM560A1(2) },STR0016} } //Cadastro do Cliente
AXVISUAL("VCF",VCF->(RECNO()),2,,,,,aButtons)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VM560VDA   | Autor ³ Thiago              ³ Data ³ 30/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao.			                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM560VDA(nOpc)  
Local lRetorno := .t.
If M->VCF_CONDIC == "2" // Desqualificada
	If Empty(M->VCF_JUSTIF)
		MsgStop(STR0041,STR0008) // Necessario informar a Justificativa quando a Condição for Desqualificada! / Atencao
		lRetorno := .f.
	EndIf
EndIf
If lRetorno .and. ExistBlock("CM560TOK")
	lRetorno := ExecBlock("CM560TOK",.f.,.f.,{nOpc})
EndIf
if VCF->(fieldpos("VCF_DATALT")) > 0
	M->VCF_DATALT := fgx_TimeStamp()
	if empty(M->VCF_DATINC)
		M->VCF_DATINC := M->VCF_DATALT
	endif
endif
if VCF->(fieldpos('VCF_UUID')) > 0 .and. empty(M->VCF_UUID)
	M->VCF_UUID := FWUUIDV4(.t.)
endif
Return lRetorno
