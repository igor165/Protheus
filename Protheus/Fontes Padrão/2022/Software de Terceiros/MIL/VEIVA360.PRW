// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "VEIVA360.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ VEIVA360 ³ Autor ³ Thiago                ³ Data ³ 24/10/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Alteracao no código do chassi.				 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA360()
Private aRotina   := MenuDef()
Private aCampos   := {}      // CAMPOS QUE SERAO VISTOS NO BROWSE
Private cCadastro := STR0019 // "Veiculos"

dbSelectArea("VV1")

mBrowse(6, 1, 22, 75, "VV1",,,,,,)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VA360A  ³ Autor ³ Thiago ³ 							  Data ³ 22/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada da tela de Alteração do Chassi.		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA360A()
Local cChaAtu  := space(TamSx3("VV1_CHASSI")[1])
Local aObjects := {}, aPosObj := {}, aPosObjApon := {}, aInfo := {}
Local aSizeAut := MsAdvSize(.T.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cCodMar  := ""
Local cDesMar  := ""
Local cChassi  := ""
Local cModVei  := ""
Local cDesMod  := ""
Local cAnoFab  := 0
Local cAnoMod  := 0
Local cFabMod  := ""
Local cCor     := 0
Local cDesCor  := ""
Local cCliente := 0
Local cLoja    := 0
Local cNome    := ""
Local aMovVV1  := {}

cCodMar := VV1->VV1_CODMAR

dbSelectArea("VE1")
dbSetOrder(1)

dbSeek(xFilial("VE1") + VV1->VV1_CODMAR)

cDesMar := VE1->VE1_DESMAR
cChassi := VV1->VV1_CHASSI
cModVei := VV1->VV1_MODVEI

dbSelectArea("VV2")
dbSetOrder(1)

dbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI)

cDesMod := VV2->VV2_DESMOD
cAnoFab := substr(VV1->VV1_FABMOD, 1, 4)
cAnoMod := substr(VV1->VV1_FABMOD, 5, 4)
cFabMod := cAnoFab + "/" + cAnoMod
cCor    := VV1->VV1_CORVEI

dbSelectArea("VVC")
dbSetOrder(1)

dbSeek(xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI)

cDesCor  := VVC->VVC_DESCRI
cCliente := VV1->VV1_PROATU
cLoja    := VV1->VV1_LJPATU

dbSelectArea("SA1")
dbSetOrder(1)

dbSeek(xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU)

cNome    := SA1->A1_NOME
cChaAtu  := VV1->VV1_CHASSI
IF Empty(VV1->VV1_CHASSI)
	aMovVV1 := FGX_VEIMOVS((VV1->VV1_CHASSI), "SE",) // Retorna todas as movimentações do veículo (Entrada / Saída)
	If Len(aMovVV1) > 0
		If !MsgYesNo(STR0014, STR0015) // Exitem movimentações para este veículo, tem certeza que deseja alterar o código chassi? / Atenção
			Return(.f.)
		EndIf
	EndIf
EndIf
// Configura os tamanhos dos objetos
aObjects := {}
aAdd(aObjects, {0, 0, .T., .T.}) // TOTAL

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2}
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgCha TITLE STR0001 From aSizeAut[7], 000 to aSizeAut[6], aSizeAut[5] of oMainWnd PIXEL // Alteração do código do chassi

// Marca
@ aPosObj[1,1], aPosObj[1,2]       SAY STR0002 OF oDlgCha PIXEL COLOR CLR_BLUE // Marca:
@ aPosObj[1,1], aPosObj[1,2] + 040 MSGET oCodMar VAR cCodMar PICTURE "@!" SIZE 40,8 OF oDlgCha PIXEL When .f.
@ aPosObj[1,1], aPosObj[1,2] + 180 SAY STR0003 OF oDlgCha PIXEL COLOR CLR_BLUE // Descrição:
@ aPosObj[1,1], aPosObj[1,2] + 220 MSGET oDesMar VAR cDesMar PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.
// Fim Marca

// Chassi, Modelo, Ano Fab/Mod
@ aPosObj[1,1] + 012, aPosObj[1,2]       SAY STR0004 OF oDlgCha  PIXEL COLOR CLR_BLUE // Chassi:
@ aPosObj[1,1] + 012, aPosObj[1,2] + 040 MSGET oChassi VAR cChassi PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.

@ aPosObj[1,1] + 012, aPosObj[1,2] + 180 SAY STR0005 OF oDlgCha  PIXEL COLOR CLR_BLUE // Mod.Veículo:
@ aPosObj[1,1] + 012, aPosObj[1,2] + 220 MSGET oModVei VAR cModVei PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.

@ aPosObj[1,1] + 024, aPosObj[1,2]       SAY STR0006 OF oDlgCha PIXEL COLOR CLR_BLUE // Descr.Modelo:
@ aPosObj[1,1] + 024, aPosObj[1,2] + 040 MSGET oDesMod VAR cDesMod PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.

@ aPosObj[1,1] + 024, aPosObj[1,2] + 180 SAY STR0007 OF oDlgCha PIXEL COLOR CLR_BLUE // Ano Fab/Mod:
@ aPosObj[1,1] + 024, aPosObj[1,2] + 220 MSGET oFabMod VAR cFabMod PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.
// Fim Chassi, Modelo, Ano Fab/Mod

// Cor
@ aPosObj[1,1] + 036, aPosObj[1,2]       SAY STR0008 OF oDlgCha PIXEL COLOR CLR_BLUE // Cod:
@ aPosObj[1,1] + 036, aPosObj[1,2] + 040 MSGET oCor VAR cCor PICTURE "@!" SIZE 40,8 OF oDlgCha PIXEL When .f.
@ aPosObj[1,1] + 036, aPosObj[1,2] + 180 SAY STR0009 OF oDlgCha PIXEL COLOR CLR_BLUE // Descr.Cor:
@ aPosObj[1,1] + 036, aPosObj[1,2] + 220 MSGET oDesCor VAR cDesCor PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.
// Fim cor

// Cliente, Loja, Nome, Chassi atual
@ aPosObj[1,1] + 048, aPosObj[1,2]       SAY STR0010 OF oDlgCha PIXEL COLOR CLR_BLUE // Cliente:
@ aPosObj[1,1] + 048, aPosObj[1,2] + 040 MSGET oCliente VAR cCliente PICTURE "@!" SIZE 40,8 OF oDlgCha PIXEL When .f.

@ aPosObj[1,1] + 048, aPosObj[1,2] + 180 SAY STR0011 OF oDlgCha PIXEL COLOR CLR_BLUE // Loja:
@ aPosObj[1,1] + 048, aPosObj[1,2] + 220 MSGET oLoja VAR cLoja PICTURE "@!" SIZE 40,8 OF oDlgCha PIXEL When .f.

@ aPosObj[1,1] + 060, aPosObj[1,2]       SAY STR0012 OF oDlgCha PIXEL COLOR CLR_BLUE // Nome:
@ aPosObj[1,1] + 060, aPosObj[1,2] + 040 MSGET oNome VAR cNome PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL When .f.

@ aPosObj[1,1] + 060, aPosObj[1,2] + 180 SAY STR0013 OF oDlgCha PIXEL COLOR CLR_BLUE // Chassi atual:
@ aPosObj[1,1] + 060, aPosObj[1,2] + 220 MSGET oChaAtu VAR cChaAtu PICTURE "@!" SIZE 100,8 OF oDlgCha PIXEL
// Fim Cliente, Loja, Nome, Chassi atual

ACTIVATE MSDIALOG oDlgCha ON INIT EnchoiceBar(oDlgCha, {|| If(FS_ALTCHASSI(cChaAtu), oDlgCha:End(), .f.)}, {|| oDlgCha:End() }) CENTER
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ALTCHASSI ³ Autor ³ Thiago ³ 						  Data ³ 22/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao do Chassi.							                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTCHASSI(cChaAtu)
Local cGruVei    := GetMv("MV_GRUVEI") + space(4 - len(GetMv("MV_GRUVEI")))
Local i          := 0
Local aFilAtu    := FWArrFilAtu() // carrega os dados da Filial logada (Grupo de Empresa / Empresa / Filial)
Local aSM0       := FWAllFilial(aFilAtu[3], aFilAtu[4], aFilAtu[1], .f.) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Local nCont      := 0
Local cBkpFilAnt := cFilAnt // salvar cFilAnt
Local cArquivo   := ""
Local cChaAnt    := ""
Local cTabela    := ""
Local nPos       := 0
Local cTab       := ""
Local cCam       := ""
Local cQuery     := ""
Local cAlias     := ""
Local nRecSB1    := 0
Local aTabAlt := {}

/*
Alex - Desatualizados
cArquivo := "VAK/VAZ/VC3/VC4/VE6/VEO/VF4/VG8/VGA/VGB/VGE/VGH/VI1/VI5/VI6/VI7/VI8/VIE/VIJ/VIK/VIL/VIN/"
cArquivo += "VIP/VIV/VJ1/VJ2/VJ3/VMB/VO1/VO2/VO4/VO5/VON/VOU/VP1/VPI/VPO/VQ0/VQ2/VQ4/VRB/VS1/VST/VV0/"
cArquivo += "VV1/VVA/VVD/VVG/VZ5/VZB/VZK/VZQ/VZR/ZVZ/VQM/CD9/SC6/SD1/SD2/"
*/
// Alex - Dicionário da Base 12.1.33
cArquivo := "VAK/VAZ/VC3/VC4/VE6/VEO/VF4/VG8/VGA/VGB/VGE/VI1/VI5/VI6/VI7/VI8/VIE/VIJ/VIK/VIL/"
cArquivo += "VIN/VIP/VIV/VJ1/VJ2/VJ3/VMB/VO1/VO2/VO4/VO5/VON/VOU/VP1/VPI/VPO/VQ0/VQ2/VQ4/VQM/"
cArquivo += "VQX/VRB/VRK/VS1/VST/VV0/VV1/VVA/VVD/VVG/VZ5/VZB/VZK/VZR/CD9/SB1/SC6/SD1/SD2/"

/*
Alex - Desatualizados
cArqCha := "VAK/VC4/VE6/VF4/VG8/VGA/VGE/VJ1/VMB/VO1/VO5/VPO/VQ0/VS1/VV0/VV1/VVA/VVD/VVG/VQM/" -- desatualizado
*/
// Alex - Dicionário da Base 12.1.33
cArqCha := "VAK/VB0/VC4/VD0/VDF/VDV/VE6/VEI/VF3/VF4/VF9/VFB/VG8/VGA/VGC/VGE/VJ1/VMB/VMY/VO1/VO5/VOT/VPO/"
cArqCha += "VQ0/VQE/VQM/VRC/VRE/VRK/VS1/VSO/VV0/VV1/VV6/VVA/VVD/VVG/VVS/VVT/VVZ/

cArqCod := "CD9/SC6/SD1/SD2/"

If Empty(cChaAtu)
	MsgStop(STR0023) // Data/Hora
	Return(.f.)
EndIf

If ExistBlock("VE360TAB")
	aAdd( aTabAlt, cArquivo)
	aAdd( aTabAlt, cArqCha )
	aAdd( aTabAlt, cArqCod )
	aTabAlt := ExecBlock("VE360TAB",.f.,.f.,{aTabAlt})
	cArquivo := aTabAlt[1]
	cArqCha  := aTabAlt[2]
	cArqCod  := aTabAlt[3]
Endif

cChaAnt := VV1->VV1_CHASSI

If Empty(cChaAnt)
	FS_ALTCHAINT(cChaAtu,cArqCha,cArqCod)
	Return(.t.)
ENDIF

DbSelectArea("SX3")
DbSetOrder(2)

DbSelectArea("SX2")
DbSetOrder(1)

DbSeek("V")



/*While !EOF()
	cChave := FWX2Chave() // retorna o nome da tabela

	If Left(cChave,1) == "V"
		If SX3->(DbSeek(cChave + "_CHASSI"))
			cArquivo += cChave + "/"
		EndIf
	Else
		Exit
	EndIf

	DbSelectArea("SX2")

	dbSkip()
EndDo

cArquivo += "CD9/SC6/SD1/SD2/"
*/
BEGIN TRANSACTION

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	cTabela := cArquivo

	For i := 1 to Len(cArquivo)
		nPos := AT("/", cTabela)
		If nPos > 0
			nPos -= 1
		Else
			nPos := Len(cTabela)
		EndIf

		cTab := alltrim(Substr(cTabela, 1, nPos))
		cCam := cTab

		If Empty(cTab)
			Exit
		EndIf

		// Verificação de Alias existente
		If !(AliasInDic(cTab))
			cTabela := alltrim(substr(cTabela, nPos + 2, Len(cTabela)))

			Loop
		EndIf

		If left(cCam, 1) == "S"
			cCam := right(cCam, 2)
		EndIf

		If !Empty(cChaAtu)
			If &(cTab + "->(FieldPos(" + '"' + cCam + "_CHASSI" + '"' + "))") > 0
				cQuery := "SELECT " + cTab + ".R_E_C_N_O_ RECARQ "
				cQuery += "FROM "+ RetSqlName("" + cTab + "") + " " + cTab + " "
				cQuery += "WHERE " + cTab + "." + cCam + "_FILIAL = '" + xFilial("" + cTab + "") + "' "
				cQuery += "  AND " + cTab + "." + cCam + "_CHASSI = '" + cChaAnt + "' "
				cQuery += "  AND " + cTab + ".D_E_L_E_T_ =' '"

				cAlias := "SQL" + cTab

				dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

				Do While !(cAlias )->(Eof())
					dbselectArea("" + cTab + "")

					DbGoTo((cAlias)->RECARQ)

					RecLock("" + cTab + "", .f.)

					&(cTab + "->" + cCam + "_CHASSI") := cChaAtu

					If cTab == "VV1"
						VV1->VV1_LOGALT := STR0020 + cChaAnt + STR0021 + __cUserID + STR0022 + dtoc(dDatabase) + " " + time() // Chassi Anterior: / Usuário / Data/Hora
						VV1->VV1_CHARED := Right(AllTrim(cChaAtu), GetNewPar("MV_MIL0152",7))
					EndIf

					MsUnlock()

					(cAlias)->(DbSkip())
				EndDo

				(cAlias)->(dbCloseArea())
			EndIf
		EndIf

		cTabela := alltrim(substr(cTabela, nPos + 2, Len(cTabela)))
	Next

	cQuery := "SELECT SB1.R_E_C_N_O_ "
	cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE SB1.B1_FILIAL = '" + xFilial("SB1")  + "' AND SB1.B1_GRUPO  = '" + cGruVei + "' "
	cQuery += "  AND SB1.B1_CODITE = '" + VV1->VV1_CHAINT + "' AND SB1.D_E_L_E_T_=' '"

	nRecSB1 := FM_SQL(cQuery)
	If !Empty(nRecSB1)
		dbselectArea("SB1")

		DbGoTo(nRecSB1)

		RecLock("SB1", .f.)

		SB1->B1_DESC   := cChaAtu
		SB1->B1_CHASSI := cChaAtu

		MsUnlock()
	EndIf
Next

cFilAnt := cBkpFilAnt // voltar cFilAnt salvo anteriormente

END TRANSACTION

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ALTCHAINT ³ Autor ³ Jose Luis ³ 					  Data ³ 20/07/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao do Chassi.							                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTCHAINT(cChaAtu,cArqCha,cArqCod)
Local cGruVei    := GetMv("MV_GRUVEI") + space(4 - len(GetMv("MV_GRUVEI")))
Local i          := 0
Local ii         := 0
Local cChaAnt    := ""
Local cChaInt    := ""
Local cTabCha    := ""
Local cTabCod    := ""
Local nPos0      := 0
Local nPos1      := 0
Local cTab       := ""
Local cTab1      := ""
Local cCam       := ""
Local cCam1      := ""
Local cQuery     := ""
Local cQuery1    := ""
Local cAlias     := ""
Local cAlias1    := ""
Local nRecSB1    := 0
Default cArqCha   := ""
Default cArqCod   := ""

If Empty(cChaAtu)
	MsgStop(STR0023) // Data/Hora

	Return(.f.)
EndIf

cChaAnt := VV1->VV1_CHASSI
cChaInt := VV1->VV1_CHAINT

DbSelectArea("SX3")
DbSetOrder(2)

DbSelectArea("SX2")
DbSetOrder(1)

DbSeek("V")

cTabCha := cArqCha
cTabCod := cArqCod

BEGIN TRANSACTION

For i := 1 to Len(cArqCha)
	nPos0 := AT("/", cTabCha)
	If nPos0 > 0
		nPos0 -= 1
	Else
		nPos0 := Len(cTabCha)
	EndIf

	cTab := alltrim(Substr(cTabCha, 1, nPos0))
	cCam := cTab
	If Empty(cTab)
		Exit
	EndIf

	// Verificação de Alias existente
	If !(AliasInDic(cTab))
		cTabCha := alltrim(substr(cTabCha, nPos0 + 2, Len(cTabCha)))
		Loop
	EndIf

	If left(cCam, 1) == "S"
		cCam := right(cCam, 2)
	EndIf

	If !Empty(cChaAtu)
		If &(cTab + "->(FieldPos(" + '"' + cCam + "_CHASSI" + '"' + "))") > 0
			cQuery := "SELECT " + cTab + ".R_E_C_N_O_ RECARQ "
			cQuery += "FROM "+ RetSqlName("" + cTab + "") + " " + cTab + " "
			cQuery += "WHERE " + cTab + "." + cCam + "_FILIAL = '" + xFilial("" + cTab + "") + "' "
			cQuery += "  AND " + cTab + "." + cCam + "_CHAINT = '" + cChaInt + "' "
			cQuery += "  AND " + cTab + ".D_E_L_E_T_ =' '"
			cAlias := "SQL" + cTab

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

			Do While !(cAlias )->(Eof())
				dbselectArea("" + cTab + "")
				DbGoTo((cAlias)->RECARQ)
				RecLock("" + cTab + "", .f.)
				&(cTab + "->" + cCam + "_CHASSI") := cChaAtu

				If cTab == "VV1"
					VV1->VV1_LOGALT := STR0020 + cChaAnt + STR0021 + __cUserID + STR0022 + dtoc(dDatabase) + " " + time() // Chassi Anterior: / Usuário / Data/Hora
					VV1->VV1_CHARED := Right(AllTrim(cChaAtu), GetNewPar("MV_MIL0152",7))
				EndIf

				MsUnlock()

				(cAlias)->(DbSkip())

			EndDo

			(cAlias)->(dbCloseArea())

		EndIf
	EndIf

	cTabCha := alltrim(substr(cTabCha, nPos0 + 2, Len(cTabCha)))

Next

For ii := 1 to Len(cArqCod)
	nPos1 := AT("/", cTabCod)
	If nPos1 > 0
		nPos1 -= 1
	Else
		nPos1 := Len(cTabCod)
	EndIf

	cTab1 := alltrim(Substr(cTabCod, 1, nPos1))
	cCam1 := cTab1
	If Empty(cTab1)
		Exit
	EndIf

	// Verificação de Alias existente
	If !(AliasInDic(cTab1))
		cTabCha := alltrim(substr(cTabCod, nPos1 + 2, Len(cTabCod)))
		Loop
	EndIf

	If left(cCam1, 1) == "S"
		cCam1 := right(cCam1, 2)
	EndIf

	If !Empty(cChaAtu)
		If &(cTab1 + "->(FieldPos(" + '"' + cCam1 + "_CHASSI" + '"' + "))") > 0
			cQuery := "SELECT " + cTab1 + ".R_E_C_N_O_ RECARQ "
			cQuery += "FROM "+ RetSqlName("" + cTab1 + "") + " " + cTab1 + " "
			cQuery += "WHERE " + cTab1 + "." + cCam1 + "_FILIAL = '" + xFilial("" + cTab1 + "") + "' "
			IF cTab1 == "SC6"
				cQuery += "  AND " + cTab1 + "." + cCam1 + "_PRODUTO = '"+ cGruVei +"_"+ cChaInt + "' "
			ELSE
				cQuery += "  AND " + cTab1 + "." + cCam1 + "_COD = '"+ cGruVei +"_"+ cChaInt + "' "
			ENDIF
			cQuery += "  AND " + cTab1 + ".D_E_L_E_T_ =' '"
			cAlias := "SQL" + cTab1

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

			Do While !(cAlias )->(Eof())
				dbselectArea("" + cTab1 + "")
				DbGoTo((cAlias)->RECARQ)
				RecLock("" + cTab1 + "", .f.)
				&(cTab1 + "->" + cCam1 + "_CHASSI") := cChaAtu

				If cTab1 == "VV1"
					VV1->VV1_LOGALT := STR0020 + cChaAnt + STR0021 + __cUserID + STR0022 + dtoc(dDatabase) + " " + time() // Chassi Anterior: / Usuário / Data/Hora
					VV1->VV1_CHARED := Right(AllTrim(cChaAtu), GetNewPar("MV_MIL0152",7))
				EndIf

				MsUnlock()

				(cAlias)->(DbSkip())

			EndDo

			(cAlias)->(dbCloseArea())

		EndIf
	EndIf

	cTabCod := alltrim(substr(cTabCod, nPos1 + 2, Len(cTabCod)))

Next

cQuery := "SELECT SB1.R_E_C_N_O_ "
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "WHERE SB1.B1_FILIAL = '" + xFilial("SB1")  + "' AND SB1.B1_GRUPO  = '" + cGruVei + "' "
cQuery += "  AND SB1.B1_CODITE = '" + VV1->VV1_CHAINT + "' AND SB1.D_E_L_E_T_=' '"

nRecSB1 := FM_SQL(cQuery)

If !Empty(nRecSB1)
	dbselectArea("SB1")
	DbGoTo(nRecSB1)
	RecLock("SB1", .f.)
	SB1->B1_DESC   := cChaAtu
	SB1->B1_CHASSI := cChaAtu
	MsUnlock()
EndIf

END TRANSACTION

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Thiago ³ 							  Data ³ 22/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) 								                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
	{STR0016, "axPesqui", 0, 1},; // "Pesquisar"
	{STR0017, "VXA010V" , 0, 2},; // " Visualisar"
	{STR0018, "VA360A"  , 0, 4} ; // "Alterar"
}
Return aRotina