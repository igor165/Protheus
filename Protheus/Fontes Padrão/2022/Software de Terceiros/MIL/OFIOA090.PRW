// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "ofioa090.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOA090 ³ Autor ³  Andre/Emilton        ³ Data ³ 23/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ TIPOS DE TEMPO                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA090
Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0006) //"Tipos de Tempo"
Private cTipAva   := "234"
Private lVZFTipVei := .f.
Private cGruIte   := Space(TamSX3("BM_GRUPO")[1])
Private M->VG8_CODMAR := "" // Utilizado no Filtro da Consulta Padrao da VOX
Private cFiltroVX5 := "050" // Filtro tabela VX5 - 050 - Tipo de Atendimento

DbSelectArea("SX2")

// Controle para validar se o campo VZF_TIPVEI existe
lVZFTipVei := (VZF->(FieldPos("VZF_TIPVEI")) <> 0)

DbSelectArea("VOI")
mBrowse( 6, 1,22,75,"VOI")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OA090    ºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA090(cAlias, nReg, nOpc)
Local bCampo   := { |nCPO| Field(nCPO) }

Local nCntFor  := 0
Local _ni := 0

Local cTitulo, cAliasEnchoice, cAliasGetD, cTudOk, cFieldOk

Local nPosRecH := nPosRecG := nPosRecC := nPosRecT := nPosRecD := nUsado := nGetCria := nCntFolder := 0

Local aObjects := {}, aPosObj := {}, aInfo := {}, aSizeAut := MsAdvSize() // Variaveis para posicionamento de Tela

Private nPosRecV := 0
Private aTELA[0][0], aGETS[0], cLinOk
Private aCpoEnchoice  :={}
Private cGruFor := "04" // Filtro para o arquivo VEG - Formulas de Veiculos

Private aCols   := {}, aHeader      := {}, aColsHis    := {}, aHeaderHis  := {}, aColsGru    := {},;
	aHeaderGru  := {}, aColsCon     := {}, aHeaderCon  := {}, aColsTSrv   := {}, aHeaderTSrv := {},;
	aColsDepto  := {}, aHeaderDepto := {}, aColsVCli   := {}, aHeaderVCli := {}, aColsGSrv   := {},;
	aHeaderGSrv := {}, aColsTAte    := {}, aHeaderTAte := {}, aAlterHis   := {}, aAlterGru   := {},;
	aAlterCon   := {}, aAlterTSrv   := {}, aAlterGSrv  := {}, aAlterDepto := {}, aAlterVCli  := {},;
	aAlterTAte  := {}

Private nLenHis := nLenGru := nLenCon := nLenTSrv := nLenDepto := nLenVCli := nLenGSrv := nLenTAte := 0

Private aSetFIni := {}

Private lNewVOX := VOX->(FieldPos("VOX_CODGRU")) > 0

Private lVCP    := FWAliasInDic("VCP") .And. VCP->(FieldPos("VCP_TPATEN")) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VOI", .f.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VOI")

While !Eof() .And. (x3_arquivo == "VOI")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !X3_CAMPO $ "VOI_HORVIG"
		AADD(aCpoEnchoice, x3_campo)
	EndIf

	&("M->" + x3_campo) := CriaVar(x3_campo)

	dbSkip()
EndDo

If !(Inclui)
	DbSelectArea("VOI")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
	Next
	
	If VOI->(FieldPos("VOI_GRUITE")) <> 0
		cGruIte := M->VOI_GRUITE
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc >= 2 .And. nOpc <= 4
	nOpcE := nOpcG := nOpc
Else
	nOpcE := nOpcG := 5
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados Historico                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VOJ")

While !Eof() .And. (x3_arquivo == "VOJ")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VOJ_TIPTEM/VOJ_HORVIG])
		Aadd(aHeaderHis,                             ;
			{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,        ;
			x3_usado, x3_tipo, x3_f3, x3_context,    ;
			X3CBOX(), x3_relacao, ".T." })

		aAdd(aAlterHis, x3_campo)

		&("M->" + x3_campo) := CriaVar(x3_campo)
	EndIf

	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOJ")
ADHeadRec("VOJ", aHeaderHis)

// Posicao do registro
nPosRecH := Len(aHeaderHis)
// Fim Cria aHeader e aCols da GetDados Historico

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados Grupo de Pecas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VOV")

While !Eof() .And. (x3_arquivo == "VOV")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VOV_TIPTEM/VOV_DESTTE])
		Aadd(aHeaderGru,                             ;
			{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,        ;
			x3_usado, x3_tipo, x3_f3, x3_context,    ;
			X3CBOX(), x3_relacao, ".T." })

		aAdd(aAlterGru, x3_campo)

		&("M->" + x3_campo) := CriaVar(x3_campo)
	EndIf

	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOV")
ADHeadRec("VOV", aHeaderGru)

// Posicao do registro
nPosRecG := Len(aHeaderGru)
// Fim Cria aHeader e aCols da GetDados Grupo de Pecas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados Consultor                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VOW")

While !Eof() .And. (x3_arquivo == "VOW")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(x3_campo) $ [VOW_TIPTEM/VOW_DESCRI])
		Aadd(aHeaderCon,                             ;
			{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,        ;
			x3_usado, x3_tipo, x3_f3, x3_context,    ;
			X3CBOX(), x3_relacao, ".T." })

		aAdd(aAlterCon, x3_campo)

		&("M->" + x3_campo) := CriaVar(x3_campo)
	EndIf

	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOW")
ADHeadRec("VOW", aHeaderCon)

// Posicao do registro
nPosRecC := Len(aHeaderCon)
// Fim Cria aHeader e aCols da GetDados Consultor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados Tipo de Servico             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VOX")

While !Eof() .And. (x3_arquivo == "VOX")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(x3_campo) $ [VOX_TIPTEM/VOX_DESTTE])
		If (Alltrim(x3_campo) $ [VOX_TIPSER/VOX_DESTPS])
			Aadd(aHeaderTSrv,                            ;
				{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,        ;
				x3_usado, x3_tipo, x3_f3, x3_context,    ;
				X3CBOX(), x3_relacao, ".T." })
			
			aAdd(aAlterTSrv, x3_campo)
		ElseIf lNewVOX .And. Alltrim(x3_campo) $ [VOX_CODMAR/VOX_DESMAR/VOX_CODGRU/VOX_DESGRU]
			Aadd(aHeaderGSrv,                            ;
				{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,        ;
				x3_usado, x3_tipo, x3_f3, x3_context,    ;
				X3CBOX(), x3_relacao, ".T." })

			aAdd(aAlterGSrv, x3_campo)
		EndIf

		&("M->" + x3_campo) := CriaVar(x3_campo)
	Endif

	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOX")
ADHeadRec("VOX", aHeaderTSrv)

// Posicao do registro
nPosRecT := Len(aHeaderTSrv)

// Inclui coluna de registro atraves de funcao generica
If lNewVOX
	dbSelectArea("VOX")
	ADHeadRec("VOX", aHeaderGSrv)

	// Posicao do registro
	nPosRecT := Len(aHeaderGSrv)
EndIf
// Fim Cria aHeader e aCols da GetDados Tipo de Servico

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados Departamento Garantia       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VGD")

While !Eof() .And. (x3_arquivo == "VGD")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(x3_campo) $ [VGD_TIPTEM])
		Aadd(aHeaderDepto,                           ;
			{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,        ;
			x3_usado, x3_tipo, x3_f3, x3_context,    ;
			X3CBOX(), x3_relacao, ".T." })

		aAdd(aAlterDepto, x3_campo)
	EndIf

	&("M->" + x3_campo) := CriaVar(x3_campo)

	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VGD")
ADHeadRec("VGD", aHeaderDepto)

// Posicao do registro
nPosRecD := Len(aHeaderDepto)
// Fim Cria aHeader e aCols da GetDados Departamento Garantia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados valor da hora cliente       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VZF")

While !Eof() .And. (x3_arquivo == "VZF")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(x3_campo) $ [VZF_TIPTEM])
		Aadd(aHeaderVCli,                            ;
			{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,        ;
			x3_usado, x3_tipo, x3_f3, x3_context,    ;
			X3CBOX(), x3_relacao, ".T." })

		aAdd(aAlterVCli, x3_campo)
	EndIf

	&("M->" + x3_campo) := CriaVar(x3_campo)

	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VZF")
ADHeadRec("VZF", aHeaderVCli)

// Posicao do registro
nPosRecV := Len(aHeaderVCli)
// Fim Cria aHeader e aCols da GetDados valor da hora cliente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados Tipo Atendimento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VCP")

While !Eof() .And. (x3_arquivo == "VCP")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. !(Alltrim(x3_campo) $ [VCP_TIPTEM])
		If lVCP .And. Alltrim(x3_campo) $ [VCP_TPATEN/VCP_DSTTEN]
			Aadd(aHeaderTAte,                            ;
				{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,        ;
				x3_usado, x3_tipo, x3_f3, x3_context,    ;
				X3CBOX(), x3_relacao, ".T." })

			aAdd(aAlterTAte, x3_campo)
		EndIf

		&("M->" + x3_campo) := CriaVar(x3_campo)
	EndIf

	dbSkip()
EndDo
// Fim Cria aHeader e aCols da GetDados Tipo Atendimento

// Inclui coluna de registro atraves de funcao generica
If lVCP
	dbSelectArea("VCP")
	ADHeadRec("VCP",aHeaderTAte)
EndIf

aColsHis   := {}
aColsGru   := {}
aColsCon   := {}
aColsTSrv  := {}
aColsGSrv  := {}
aColsDepto := {}
aColsVCli  := {}
aColsTAte  := {}

// Historico
dbSelectArea("VOJ")
dbSetOrder(1)
dbSeek(xFilial("VOJ") + M->VOI_TIPTEM)

While !eof() .And. VOJ->VOJ_FILIAL == xFilial("VOJ") .And. VOJ->VOJ_TIPTEM == M->VOI_TIPTEM
	AADD(aColsHis, Array(Len(aHeaderHis) + 1))

	For _ni := 1 to Len(aHeaderHis)
		If IsHeadRec(aHeaderHis[_ni,2])
			aColsHis[Len(aColsHis),_ni] := VOJ->(RecNo())
		ElseIf IsHeadAlias(aHeaderHis[_ni,2])
			aColsHis[Len(aColsHis),_ni] := "VOJ"
		Else
			aColsHis[Len(aColsHis),_ni] := If(aHeaderHis[_ni,10] # "V",;
				FieldGet(FieldPos(aHeaderHis[_ni,2])), CriaVar(aHeaderHis[_ni,2]))
		EndIf
	Next

	aColsHis[Len(aColsHis),Len(aHeaderHis) + 1] := .F.

	dbSkip()
EndDo
// Fim Historico

// Grupo
dbSelectArea("VOV")
dbSetOrder(2)
dbSeek(xFilial("VOV") + M->VOI_TIPTEM)

While !eof() .And. VOV->VOV_FILIAL == xFilial("VOV") .And. VOV->VOV_TIPTEM == M->VOI_TIPTEM
	AADD(aColsGru, Array(Len(aHeaderGru) + 1))

	For _ni := 1 to Len(aHeaderGru)
		If IsHeadRec(aHeaderGru[_ni,2])
			aColsGru[Len(aColsGru),_ni] := VOV->(RecNo())
		ElseIf IsHeadAlias(aHeaderGru[_ni,2])
			aColsGru[Len(aColsGru),_ni] := "VOV"
		Else
			aColsGru[Len(aColsGru),_ni] := If(aHeaderGru[_ni,10] # "V",;
				FieldGet(FieldPos(aHeaderGru[_ni,2])), CriaVar(aHeaderGru[_ni,2]))
		EndIf
	Next

	aColsGru[Len(aColsGru),Len(aHeaderGru) + 1] := .F.

	dbSkip()
EndDo
// Fim Grupo

// Consultor
dbSelectArea("VOW")
dbSetOrder(2)
dbSeek(xFilial()+ M->VOI_TIPTEM)

While !eof() .And. VOW->VOW_FILIAL == xFilial("VOW") .And. VOW->VOW_TIPTEM == M->VOI_TIPTEM
	AADD(aColsCon, Array(Len(aHeaderCon) + 1))

	For _ni := 1 to Len(aHeaderCon)
		If IsHeadRec(aHeaderCon[_ni,2])
			aColsCon[Len(aColsCon),_ni] := VOW->(RecNo())
		ElseIf IsHeadAlias(aHeaderCon[_ni,2])
			aColsCon[Len(aColsCon),_ni] := "VOW"
		Else
			aColsCon[Len(aColsCon),_ni] := If(aHeaderCon[_ni,10] # "V",;
				FieldGet(FieldPos(aHeaderCon[_ni,2])), CriaVar(aHeaderCon[_ni,2]))
		EndIf
	Next

	aColsCon[Len(aColsCon),Len(aHeaderCon) + 1] := .F.

	dbSkip()
EndDo
// Fim Consultor

// Tipo de Servico
dbSelectArea("VOX")
dbSetOrder(2)
dbSeek(xFilial()+ M->VOI_TIPTEM)

While !eof() .And. VOX->VOX_FILIAL == xFilial("VOX") .And. VOX->VOX_TIPTEM == M->VOI_TIPTEM
	If VOX->(FieldPos("VOX_TIPREG")) > 0 .And. VOX->VOX_TIPREG <> "2"
		AADD(aColsTSrv, Array(Len(aHeaderTSrv) + 1))

		For _ni := 1 to Len(aHeaderTSrv)
			If IsHeadRec(aHeaderTSrv[_ni,2])
				aColsTSrv[Len(aColsTSrv),_ni] := VOX->(RecNo())
			ElseIf IsHeadAlias(aHeaderTSrv[_ni,2])
				aColsTSrv[Len(aColsTSrv),_ni] := "VOX"
			Else
				aColsTSrv[Len(aColsTSrv),_ni] := If(aHeaderTSrv[_ni,10] # "V",;
					FieldGet(FieldPos(aHeaderTSrv[_ni,2])), CriaVar(aHeaderTSrv[_ni,2]))
			EndIf
		Next

		aColsTSrv[Len(aColsTSrv),Len(aHeaderTSrv) + 1] := .F.
	EndIf

	dbSkip()
EndDo
// Fim Tipo de Servico

// Grupo de Servico
If lNewVOX
	dbSelectArea("VOX")
	dbSeek(xFilial()+ M->VOI_TIPTEM)

	While !eof() .And. VOX->VOX_FILIAL == xFilial("VOX") .And. VOX->VOX_TIPTEM == M->VOI_TIPTEM
		If VOX->(FieldPos("VOX_TIPREG")) > 0 .And. VOX->VOX_TIPREG == "2"
			AADD(aColsGSrv, Array(Len(aHeaderGSrv) + 1))

			For _ni := 1 to Len(aHeaderGSrv)
				If IsHeadRec(aHeaderGSrv[_ni,2])
					aColsGSrv[Len(aColsGSrv),_ni] := VOX->(RecNo())
				ElseIf IsHeadAlias(aHeaderGSrv[_ni,2])
					aColsGSrv[Len(aColsGSrv),_ni] := "VOX"
				Else
					aColsGSrv[Len(aColsGSrv),_ni] := If(aHeaderGSrv[_ni,10] # "V",;
						FieldGet(FieldPos(aHeaderGSrv[_ni,2])), CriaVar(aHeaderGSrv[_ni,2]))
				EndIf
			Next

			aColsGSrv[Len(aColsGSrv),Len(aHeaderGSrv) + 1] := .F.
		EndIf

		dbSkip()
	EndDo
EndIf
// Fim Grupo de Servico

// Departamento Garantia
dbSelectArea("VGD")
dbSetOrder(1)
dbSeek(xFilial()+ M->VOI_TIPTEM)

While !eof() .And. VGD->VGD_FILIAL == xFilial("VGD") .And. VGD->VGD_TIPTEM == M->VOI_TIPTEM
	AADD(aColsDepto, Array(Len(aHeaderDepto) + 1))

	For _ni := 1 to Len(aHeaderDepto)
		If IsHeadRec(aHeaderDepto[_ni,2])
			aColsDepto[Len(aColsDepto),_ni] := VGD->(RecNo())
		ElseIf IsHeadAlias(aHeaderDepto[_ni,2])
			aColsDepto[Len(aColsDepto),_ni] := "VGD"
		Else
			aColsDepto[Len(aColsDepto),_ni] := If(aHeaderDepto[_ni,10] # "V",;
				FieldGet(FieldPos(aHeaderDepto[_ni,2])), CriaVar(aHeaderDepto[_ni,2]))
		EndIf
	Next

	aColsDepto[Len(aColsDepto),Len(aHeaderDepto) + 1] := .F.

	dbSkip()
EndDo
// Fim Departamento Garantia

// Departamento valor por cliente
dbSelectArea("VZF")
dbSetOrder(1)
dbSeek(xFilial()+ M->VOI_TIPTEM)

While !eof() .And. VZF->VZF_FILIAL == xFilial("VZF") .And. VZF->VZF_TIPTEM == M->VOI_TIPTEM
	AADD(aColsVCli, Array(Len(aHeaderVCli) + 1))

	For _ni := 1 to Len(aHeaderVCli)
		If IsHeadRec(aHeaderVCli[_ni,2])
			aColsVCli[Len(aColsVCli),_ni] := VZF->(RecNo())
		ElseIf IsHeadAlias(aHeaderVCli[_ni,2])
			aColsVCli[Len(aColsVCli),_ni] := "VZF"
		Else
			aColsVCli[Len(aColsVCli),_ni] := If(aHeaderVCli[_ni,10] # "V",;
				FieldGet(FieldPos(aHeaderVCli[_ni,2])), CriaVar(aHeaderVCli[_ni,2]))
		EndIf
	Next

	aColsVCli[Len(aColsVCli),Len(aHeaderVCli) + 1] := .F.

	dbSkip()
EndDo
// Fim Departamento valor por cliente

// Tipo Atendimento
If lVCP
	dbSelectArea("VCP")
	dbSetOrder(1)
	dbSeek(xFilial()+ M->VOI_TIPTEM)

	While !eof() .And. VCP->VCP_FILIAL == xFilial("VCP") .And. VCP->VCP_TIPTEM == M->VOI_TIPTEM
		AADD(aColsTAte, Array(Len(aHeaderTAte) + 1))

		For _ni := 1 to Len(aHeaderTAte)
			If IsHeadRec(aHeaderTAte[_ni,2])
				aColsTAte[Len(aColsTAte),_ni] := VCP->(RecNo())
			ElseIf IsHeadAlias(aHeaderTAte[_ni,2])
				aColsTAte[Len(aColsTAte),_ni] := "VCP"
			Else
				aColsTAte[Len(aColsTAte),_ni] := If(aHeaderTAte[_ni,10] # "V",;
					FieldGet(FieldPos(aHeaderTAte[_ni,2])), CriaVar(aHeaderTAte[_ni,2]))
			EndIf
		Next

		aColsTAte[Len(aColsTAte),Len(aHeaderTAte) + 1] := .F.

		dbSkip()
	EndDo
EndIf
// Fim Tipo Atendimento

nLenHis  := Len(aColsHis)
nLenGru  := Len(aColsGru)
nLenCon  := Len(aColsCon)
nLenTSrv := Len(aColsTSrv)
nLenGSrv := Len(aColsGSrv)
nLenDepto:= Len(aColsDepto)
nLenVCli := Len(aColsVCli)
nLenTAte := Len(aColsTAte)

// Historico
If Len(aColsHis) == 0
	aColsHis := {Array(Len(aHeaderHis) + 1)}

	aColsHis[1,Len(aHeaderHis) + 1] := .F.

	For _ni := 1 to Len(aHeaderHis)
		If IsHeadRec(aHeaderHis[_ni,2])
			aColsHis[Len(aColsHis),_ni] := 0
		ElseIf IsHeadAlias(aHeaderHis[_ni,2])
			aColsHis[Len(aColsHis),_ni] := "VOJ"
		Else
			aColsHis[1,_ni] := CriaVar(aHeaderHis[_ni,2])
		EndIf
	Next
EndIf
// Fim Historico

// Grupo
If Len(aColsGru) == 0
	aColsGru := {Array(Len(aHeaderGru) + 1)}

	aColsGru[1,Len(aHeaderGru) + 1] := .F.

	For _ni := 1 to Len(aHeaderGru)
		If IsHeadRec(aHeaderGru[_ni,2])
			aColsGru[Len(aColsGru),_ni] := 0
		ElseIf IsHeadAlias(aHeaderGru[_ni,2])
			aColsGru[Len(aColsGru),_ni] := "VOV"
		Else
			aColsGru[1,_ni] := CriaVar(aHeaderGru[_ni,2])
		EndIf
	Next
EndIf
// Fim Grupo

// Consultor
If Len(aColsCon) == 0
	aColsCon := {Array(Len(aHeaderCon) + 1)}

	aColsCon[1,Len(aHeaderCon) + 1] := .F.

	For _ni := 1 to Len(aHeaderCon)
		If IsHeadRec(aHeaderCon[_ni,2])
			aColsCon[Len(aColsCon),_ni] := 0
		ElseIf IsHeadAlias(aHeaderCon[_ni,2])
			aColsCon[Len(aColsCon),_ni] := "VOW"
		Else
			aColsCon[1,_ni] := CriaVar(aHeaderCon[_ni,2])
		EndIf
	Next
EndIf
// Fim Consultor

// Tipo de Servico
If Len(aColsTSrv) == 0
	aColsTSrv := {Array(Len(aHeaderTSrv) + 1)}

	aColsTSrv[1,Len(aHeaderTSrv) + 1] := .F.

	For _ni := 1 to Len(aHeaderTSrv)
		If IsHeadRec(aHeaderTSrv[_ni,2])
			aColsTSrv[Len(aColsTSrv),_ni] := 0
		ElseIf IsHeadAlias(aHeaderTSrv[_ni,2])
			aColsTSrv[Len(aColsTSrv),_ni] := "VOX"
		Else
			aColsTSrv[1,_ni] := CriaVar(aHeaderTSrv[_ni,2])
		EndIf
	Next
EndIf
// Fim Tipo de Servico

// Grupo de Servico
If lNewVOX
	If Len(aColsGSrv) == 0
		aColsGSrv := {Array(Len(aHeaderGSrv) + 1)}

		aColsGSrv[1,Len(aHeaderGSrv) + 1] := .F.

		For _ni:=1 to Len(aHeaderGSrv)
			If IsHeadRec(aHeaderGSrv[_ni,2])
				aColsGSrv[Len(aColsGSrv),_ni] := 0
			ElseIf IsHeadAlias(aHeaderGSrv[_ni,2])
				aColsGSrv[Len(aColsGSrv),_ni] := "VOX"
			Else
				aColsGSrv[1,_ni] := CriaVar(aHeaderGSrv[_ni,2])
			EndIf
		Next
	EndIf
EndIf
// Fim Grupo de Servico

// Departamento Garantia
If Len(aColsDepto) == 0
	aColsDepto := {Array(Len(aHeaderDepto) + 1)}

	aColsDepto[1,Len(aHeaderDepto) + 1] := .F.

	For _ni := 1 to Len(aHeaderDepto)
		If IsHeadRec(aHeaderDepto[_ni,2])
			aColsDepto[Len(aColsDepto),_ni] := 0
		ElseIf IsHeadAlias(aHeaderDepto[_ni,2])
			aColsDepto[Len(aColsDepto),_ni] := "VGD"
		Else
			aColsDepto[1,_ni] := CriaVar(aHeaderDepto[_ni,2])
		EndIf
	Next
EndIf
// Fim Departamento Garantia

// Valor da hora por cliente
If Len(aColsVCli) == 0
	aColsVCli := {Array(Len(aHeaderVCli) + 1)}

	aColsVCli[1, Len(aHeaderVCli) + 1] := .F.

	For _ni := 1 to Len(aHeaderVCli)
		If IsHeadRec(aHeaderVCli[_ni,2])
			aColsVCli[Len(aColsVCli),_ni] := 0
		ElseIf IsHeadAlias(aHeaderVCli[_ni,2])
			aColsVCli[Len(aColsVCli),_ni] := "VZF"
		Else
			aColsVCli[1,_ni] := CriaVar(aHeaderVCli[_ni,2])
		EndIf
	Next
EndIf
// Fim Valor da hora por cliente

// Tipo Atendimento
If lVCP
	If Len(aColsTAte) == 0
		aColsTAte := {Array(Len(aHeaderTAte) + 1)}

		aColsTAte[1, Len(aHeaderTAte) + 1] := .F.

		For _ni := 1 to Len(aHeaderTAte)
			If IsHeadRec(aHeaderTAte[_ni,2])
				aColsTAte[Len(aColsTAte),_ni] := 0
			ElseIf IsHeadAlias(aHeaderTAte[_ni,2])
				aColsTAte[Len(aColsTAte),_ni] := "VCP"
			Else
				aColsTAte[1,_ni] := CriaVar(aHeaderTAte[_ni,2])
			EndIf
		Next
	EndIf
EndIf
// Fim Tipo Atendimento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo        := STR0006 // Tipos De Tempo
cAliasEnchoice := "VOI"
cAliasGetD     := "VOJ"
cLinOk         := "IIf(FS_VAL090(nOpcG),FG_OBRIGAT(),.f.)"
cTudOk         := "FS_SETOPTION()"
cFieldOk       := "OA090FIELDOK()"

DbSelectArea("VOI")

// Configura os tamanhos dos objetos
aObjects := {}

AAdd(aObjects, { 315, 050, .T., .T. }) // Enchoice
AAdd(aObjects, { 315, 050, .T., .T. }) // Folder

aInfo := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2 }

aPosObj := MsObjSize(aInfo, aObjects, .t.)

DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7], 000 TO aSizeAut[6], aSizeAut[5] of oMainWnd PIXEL

oGetMGet:= MsMGet():New(cAliasEnchoice, 0, nOpcE,,,, aCpoEnchoice, aPosObj[1],, 3,,, oDlg1,,, .T., .F.,)

SetEnch("")

oFolder := TFolder():New(aPosObj[2,1], aPosObj[2,2],       ;
	{STR0007, STR0008, STR0009, STR0010, STR0014, STR0015},; // Historico / Grupo de Pecas / Funcionario Permitido / Tipo de Servico / Departamento / Vl Hora por Tipo de Srvc./Cliente
	{STR0007, STR0008, STR0009, STR0010, STR0014, STR0015},; // Historico / Grupo de Pecas / Funcionario Permitido / Tipo de Servico / Departamento / Vl Hora por Tipo de Srvc./Cliente
	oDlg1,,,, .t.,, aPosObj[2,4], aPosObj[2,3] - aPosObj[2,1])

If lNewVOX
	oFolder:AddItem(STR0018 , .t.) // Grupo de Serviço
EndIf

If lVCP
	oFolder:AddItem(STR0019 , .t.) // Tipo de Atendimento
EndIf

nIncAlt := GD_INSERT + GD_UPDATE + GD_DELETE

		// Historico
		dbSelectArea("VOJ")

		nCntFolder += 1

		oGetHis := MsNewGetDados():New(01, 1, 70, 344,;
					nIncAlt,;
					cLinOk,;
					cTudOk,;
					"",;
					aAlterHis,;
					0,;
					999,;
					cFieldOk,;
					,;
					,;
					oFolder:aDialogs[nCntFolder],;
					aHeaderHis,;
					aColsHis)
		oGetHis:oBrowse:bChange := {||;
			n := oGetHis:nAt,;
			FG_AALTER("VOJ", nLenHis, oGetHis, oGetHis:aHeader)}

		oGetHis:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		// Fim Historico

		// Grupo
		dbSelectArea("VOV")

		nCntFolder += 1

		oGetGru := MsNewGetDados():New(01, 1, 70, 344,;
					nIncAlt,;
					cLinOk,;
					cTudOk,;
					"",;
					aAlterGru,;
					0,;
					999,;
					cFieldOk,;
					,;
					,;
					oFolder:aDialogs[nCntFolder],;
					aHeaderGru,;
					aColsGru)

		oGetGru:oBrowse:bChange := {||;
			n := oGetGru:nAt,;
			FG_AALTER("VOV", nLenGru, oGetGru, oGetGru:aHeader)}

		oGetGru:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		// Fim Grupo

		// Consultor
		dbSelectArea("VOW")

		nCntFolder += 1

		oGetCon := MsNewGetDados():New(01, 1, 70, 344,;
					nIncAlt,;
					cLinOk,;
					cTudOk,;
					"",;
					aAlterCon,;
					0,;
					999,;
					cFieldOk,;
					,;
					,;
					oFolder:aDialogs[nCntFolder],;
					aHeaderCon,;
					aColsCon)

		oGetCon:oBrowse:bChange := {||;
			n := oGetCon:nAt,;
			FS_LIMPCPO() .AND. FG_AALTER("VOW", nLenCon, oGetCon, oGetCon:aHeader)}

		oGetCon:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		// Fim Consultor

		// Tipo de Servico
		dbSelectArea("VOX")

		nCntFolder += 1

		oGetTSrv := MsNewGetDados():New(01, 1, 70, 344,;
					nIncAlt,;
					cLinOk,;
					cTudOk,;
					"",;
					aAlterTSrv,;
					0,;
					999,;
					cFieldOk,;
					,;
					,;
					oFolder:aDialogs[nCntFolder],;
					aHeaderTSrv,;
					aColsTSrv)

		oGetTSrv:oBrowse:bChange := {||;
			n := oGetTSrv:nAt,;
			FG_AALTER("VOX", nLenTSrv, oGetTSrv, oGetTSrv:aHeader)}

		oGetTSrv:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		// Fim Tipo de Servico

		// Departamento Garantia
		dbSelectArea("VGD")

		nCntFolder += 1

		oGetDepto := MsNewGetDados():New(01, 1, 70, 344,;
					nIncAlt,;
					cLinOk,;
					cTudOk,;
					"",;
					aAlterDepto,;
					0,;
					999,;
					cFieldOk,;
					,;
					,;
					oFolder:aDialogs[nCntFolder],;
					aHeaderDepto,;
					aColsDepto)

		oGetDepto:oBrowse:bChange := {||;
			n := oGetDepto:nAt,;
			FG_AALTER("VGD", nLenDepto, oGetDepto, oGetDepto:aHeader)}

		oGetDepto:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		// Fim Departamento Garantia

		// Departamento valor por cliente
		dbSelectArea("VZF")

		nCntFolder += 1

		oGetVCli := MsNewGetDados():New(01, 1, 70, 344,;
					nIncAlt,;
					cLinOk,;
					cTudOk,;
					"",;
					aAlterVCli,;
					0,;
					999,;
					cFieldOk,;
					,;
					,;
					oFolder:aDialogs[nCntFolder],;
					aHeaderVCli,;
					aColsVCli)

		oGetVCli:oBrowse:bChange := {|| ;
			n := oGetVCli:nAt,;
			FG_AALTER("VZF", nLenVCli, oGetVCli, oGetVCli:aHeader)}

		oGetVCli:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		// Fim Departamento valor por cliente

		// Grupo de Servico
		If lNewVOX
			dbSelectArea("VOX")

			nCntFolder += 1

			oGetGSrv := MsNewGetDados():New(01, 1, 70, 344,;
						nIncAlt,;
						cLinOk,;
						cTudOk,;
						"",;
						aAlterGSrv,;
						0,;
						999,;
						cFieldOk,;
						,;
						,;
						oFolder:aDialogs[nCntFolder],;
						aHeaderGSrv,;
						aColsGSrv)
			
			oGetGSrv:oBrowse:bChange := { ||;
				M->VG8_CODMAR := oGetGSrv:aCols[oGetGSrv:nAt, FG_POSVAR("VOX_CODMAR","aHeaderGSrv")],;
				n := oGetGSrv:nAt,;
				FG_AALTER("VOX", nLenGSrv, oGetGSrv, oGetGSrv:aHeader) }

			oGetGSrv:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		EndIf
		// Fim Grupo de Servico

		// Tipo Atendimento
		If lVCP
			dbSelectArea("VCP")

			nCntFolder += 1

			oGetTAte := MsNewGetDados():New(01, 1, 70, 344,;
						nIncAlt,;
						cLinOk,;
						cTudOk,;
						"",;
						aAlterTAte,;
						0,;
						999,;
						cFieldOk,;
						,;
						,;
						oFolder:aDialogs[nCntFolder],;
						aHeaderTAte,;
						aColsTAte)

			oGetTAte:oBrowse:bChange := {||;
				n := oGetTAte:nAt,;
				FG_AALTER("VCP", nLenTAte, oGetTAte, oGetTAte:aHeader)}

			oGetTAte:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf
		// Fim Tipo Atendimento

dbSelectArea("VOJ")

ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1, {|| If(obrigatorio(aGets, aTela) .And.;
	FS_SETOPTION() .And. FS_OA090GRA(nOpc), oDlg1:End(), .f.)}, {|| oDlg1:End() })/* , oFolder:nOption := aSetFIni[Len(aSetFIni),2] */)

DbSelectArea("VOI")
DbSetOrder(1)
DbSeek(xFilial() + M->VOI_TIPTEM)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SETOPTIºAutor  ³Valdir              º Data ³  17/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida mudanca de aba                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SETOPTION(nAba)

Local nColuna := 0
Default nAba := oFolder:nOption

FS_ATUHEADER(nAba)

// Verifica caso tenha sido digitado algum conteudo na linha se todo os campos obrigatorios foram informados
If !aCols[n,Len(aCols[n])] // só deve validar para linhas não deletadas
	For nColuna := 1 to Len(aHeader)
		If ! Empty(aCols[n,nColuna]) .and. ! ("_WT" $ aHeader[nColuna,2])
			If ! FG_OBRIGAT()
				Return(.f.)
			Else
				If nAba == 6 .and. Empty(aCols[n,FG_POSVAR("VZF_TIPSER")]) .and. Empty(aCols[n,FG_POSVAR("VZF_CODCLI")]) .and. ( ! lVZFTipVei .or. ( lVZFTipVei .and. Empty(aCols[n,FG_POSVAR("VZF_TIPVEI")]) ) )
					FMX_HELP("OA090ERR01",STR0020,STR0021 + CRLF + RetTitle("VZF_TIPSER") + " ou " + RetTitle("VZF_CODCLI") + IIf( lVZFTipVei , " ou " + RetTitle("VZF_TIPVEI"), "") )
					Return(.f.)
				EndIf
				Exit
			EndIf
		EndIf
	Next
Endif

IF !FS_VAL090(nOpcG)
	return(.f.)
EndIf

Return(.t.)

Static Function FS_ATUHEADER(nAba)

If oFolder:nOption == 1
	aHeader := oGetHis:aHeader
	aCols := oGetHis:aCols
	n := oGetHis:nAt
	
ElseIf oFolder:nOption == 2
	aHeader := oGetGru:aHeader
	aCols := oGetGru:aCols
	n := oGetGru:nAt
	
ElseIf oFolder:nOption == 3
	aHeader := oGetCon:aHeader
	aCols := oGetCon:aCols
	n := oGetCon:nAt
	
ElseIf oFolder:nOption == 4
	aHeader := oGetTSrv:aHeader
	aCols := oGetTSrv:aCols
	n := oGetTSrv:nAt
	
ElseIf oFolder:nOption == 5
	aHeader := oGetDepto:aHeader
	aCols := oGetDepto:aCols
	n := oGetDepto:nAt
	
ElseIf oFolder:nOption == 6
	aHeader := oGetVCli:aHeader
	aCols := oGetVCli:aCols
	n := oGetVCli:nAt

ElseIf oFolder:nOption == 7
	aHeader := oGetGSrv:aHeader
	aCols := oGetGSrv:aCols
	n := oGetGSrv:nAt

ElseIf oFolder:nOption == 8
	aHeader := oGetTAte:aHeader
	aCols := oGetTAte:aCols
	n := oGetTAte:nAt

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OA090GRºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava tipo de Tempo                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OA090GRA(nOpc)
Local lRetorno := .f.
Private lMsHelpAuto , lMsErroAuto ,lMsFinalAuto := .f.

If !FS_VALGRAOA090( nOpc , .t. )
	
	Return( .f. )
	
EndIf

lMsHelpAuto := .t.
lMsErroAuto := .f.

Begin Transaction

lRetorno := FS_VALGRAOA090( nOpc )

End Transaction

If !lRetorno
	MostraErro()
EndIf
lMsHelpAuto := .f.

// Ponto de Entrada para o usuário fazer gravações a mais relacionado ao tipo de tempo
If ExistBlock("OA090GRV")
	ExecBlock("OA090GRV",.f.,.f., {nOpc,VOI->(RecNo())})
EndIf


Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALGRAOA090ºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida gravacao                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALGRAOA090( nOpc , lValid )

Local lRet := .t. , i := 0 , aVetValid := {}
Private lMsHelpAuto

lValid := If( lValid == NIL , .f. , lValid )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
	
	If !FS_SETOPTION(oFolder:nOption)
		
		Return(.f.)
		
	EndIf
	
	If !lValid
		lMsHelpAuto := .t.
	EndIf
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek( xFilial() + M->VOI_TIPTEM )
	
	// Grava arquivo pai
	If nOpc == 3 .or. nOpc == 4
		
		If !lValid
			
			DbSelectArea("VOI")
			
			If !RecLock("VOI", !Found() )
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			FG_GRAVAR("VOI")
			MsUnlock()
			
		EndIf
		
	EndIf

	If !lValid
		// grava arquivo filho Historico
		For i:=1 to len(oGetHis:aCols)
			
			DbSelectArea("VOJ")
			DbSetOrder(1)
			DbSeek(xFilial("VOJ")+VOI->VOI_TIPTEM+dtos(oGetHis:aCols[I,FG_POSVAR("VOJ_DATVIG","aHeaderHis")]) )
			
			If (nOpc == 3 .or. nOpc == 4) .And. !oGetHis:aCols[i,len(oGetHis:aCols[i])] .and. !Empty(oGetHis:aCols[I,FG_POSVAR("VOJ_DATVIG","aHeaderHis")])
				
				dbSelectArea("VOJ")
				If !RecLock("VOJ", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VOJ",oGetHis:aCols,aHeaderHis,i)
				VOJ->VOJ_FILIAL := xFilial("VOJ")
				VOJ->VOJ_TIPTEM := M->VOI_TIPTEM
				MsUnlock()
				
				DbSelectArea("VOI")
				If !RecLock("VOI",.F.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				VOI->VOI_FILIAL := xFilial("VOI")
				VOI->VOI_DATVIG := oGetHis:aCols[I,FG_POSVAR("VOJ_DATVIG","aHeaderHis")]
				VOI->VOI_VALHOR := oGetHis:aCols[I,FG_POSVAR("VOJ_VALHOR","aHeaderHis")]
				MsUnlock()
				
			ElseIf Found() .and. nLenHis>=i
				
				// Deleta
				If !RecLock("VOJ",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VOJ")
				
			EndIf
			
		Next
		
		// grava arquivo filho Grupo
		For i:=1 to len(oGetGru:aCols)
			
			DbSelectArea("VOV")
			DbSetOrder(2)
			DbSeek( xFilial("VOV") + VOI->VOI_TIPTEM + oGetGru:aCols[i, FG_POSVAR("VOV_GRUITE","aHeaderGru") ])
			
			If (nOpc == 3 .or. nOpc == 4) .And. !oGetGru:aCols[i,len(oGetGru:aCols[i])] .and. !Empty(oGetGru:aCols[i, FG_POSVAR("VOV_GRUITE","aHeaderGru")])
				
				dbSelectArea("VOV")
				If !RecLock("VOV", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VOV",oGetGru:aCols,aHeaderGru,i)
				VOV->VOV_FILIAL := xFilial("VOV")
				VOV->VOV_TIPTEM := M->VOI_TIPTEM
				MsUnlock()
				
			ElseIf Found() .and. nLenGru>=i
				
				// Deleta
				If !RecLock("VOV",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VOV")
				
			EndIf
			
		Next
		
		// grava arquivo filho Consultor
		For i:=1 to len(oGetCon:aCols)
			
			DbSelectArea("VOW")
			DbSetOrder(2)
			DbSeek( xFilial("VOW") + VOI->VOI_TIPTEM + oGetCon:aCols[I,FG_POSVAR("VOW_CODPRO","aHeaderCon")]  )
			
			If (nOpc == 3 .or. nOpc == 4) .And. !oGetCon:aCols[i,len(oGetCon:aCols[i])] .and. !Empty(oGetCon:aCols[I,FG_POSVAR("VOW_CODPRO","aHeaderCon")])
				
				dbSelectArea("VOW")
				If !RecLock("VOW", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VOW",oGetCon:aCols,aHeaderCon,i)
				VOW->VOW_FILIAL := xFilial("VOW")
				VOW->VOW_TIPTEM := M->VOI_TIPTEM
				MsUnlock()
				
			ElseIf Found() .and. nLenCon>=i
				
				// Deleta
				If !RecLock("VOW",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VOW")
				
			EndIf
			
		Next
		
		// grava arquivo filho Tipo de Servico
		For i:=1 to len(oGetTSrv:aCols)
			
			DbSelectArea("VOX")
			DbSetOrder(2)
			DbSeek( xFilial("VOX") + VOI->VOI_TIPTEM + oGetTSrv:aCols[I,FG_POSVAR("VOX_TIPSER","aHeaderTSrv")]  )
			
			If (nOpc == 3 .or. nOpc == 4) .And. !oGetTSrv:aCols[i,len(oGetTSrv:aCols[i])] .and. !Empty(oGetTSrv:aCols[I,FG_POSVAR("VOX_TIPSER","aHeaderTSrv")])
				
				dbSelectArea("VOX")
				If !RecLock("VOX", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VOX",oGetTSrv:aCols,aHeaderTSrv,i)
				VOX->VOX_FILIAL := xFilial("VOX")
				VOX->VOX_TIPTEM := M->VOI_TIPTEM
				VOX->VOX_TIPREG := "1"
				MsUnlock()
				
			ElseIf Found() .and. nLenTSrv>=i
				
				// Deleta
				If !RecLock("VOX",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VOX")
				
			EndIf
			
		Next

		If lNewVOX
			// grava arquivo filho Grupo de Servico
			For i:=1 to len(oGetGSrv:aCols)
				
				DbSelectArea("VOX")
				DbSetOrder(3)
				DbSeek( xFilial("VOX") + VOI->VOI_TIPTEM + oGetGSrv:aCols[I,FG_POSVAR("VOX_CODMAR","aHeaderGSrv")] + oGetGSrv:aCols[I,FG_POSVAR("VOX_CODGRU","aHeaderGSrv")])
				
				If (nOpc == 3 .or. nOpc == 4) .And.;
					!oGetGSrv:aCols[i,len(oGetGSrv:aCols[i])] .and.;
					!Empty(oGetGSrv:aCols[I,FG_POSVAR("VOX_CODGRU","aHeaderGSrv")])

					dbSelectArea("VOX")
					If !RecLock("VOX", !Found() )
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
					
					FG_GRAVAR("VOX",oGetGSrv:aCols,aHeaderGSrv,i)
					VOX->VOX_FILIAL := xFilial("VOX")
					VOX->VOX_TIPTEM := M->VOI_TIPTEM
					VOX->VOX_TIPREG := "2"
					MsUnlock()
					
				ElseIf Found() .and. nLenGSrv>=i
					
					// Deleta
					If !RecLock("VOX",.F.,.T.)
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
					
					dbdelete()
					MsUnlock()
					WriteSx2("VOX")
					
				EndIf
				
			Next

		EndIf

		// grava arquivo filho Departamento
		For i:=1 to len(oGetDepto:aCols)
			
			DbSelectArea("VGD")
			DbSetOrder(1)
			DbSeek( xFilial("VGD") + VOI->VOI_TIPTEM + oGetDepto:aCols[I,FG_POSVAR("VGD_DEPGAR","aHeaderDepto")] + oGetDepto:aCols[I,FG_POSVAR("VGD_TIPOPE","aHeaderDepto")] )
			
			If (nOpc == 3 .or. nOpc == 4) .And. !oGetDepto:aCols[i,len(oGetDepto:aCols[i])]
				
				If Empty(oGetDepto:aCols[I,FG_POSVAR("VGD_DEPGAR","aHeaderDepto")]) .And.;
					Empty(oGetDepto:aCols[I,FG_POSVAR("VGD_TIPOPE","aHeaderDepto")])
					Loop
				EndIf

				dbSelectArea("VGD")
				If !RecLock("VGD", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VGD",oGetDepto:aCols,aHeaderDepto,i)
				VGD->VGD_FILIAL := xFilial("VGD")
				VGD->VGD_TIPTEM := M->VOI_TIPTEM
				MsUnlock()
				
			ElseIf Found() .and. nLenDepto>=i
				
				// Deleta
				If !RecLock("VGD",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VGD")
				
			EndIf
			
		Next

		// Grava arquivo de valor de hora por cliente/tipo de servico 
		If (nOpc == 3 .or. nOpc == 4)
		
			dbSelectArea("VZF")
			For i := 1 to Len(oGetVCli:aCols)
			
				// Registro foi deletado ...
				If oGetVCli:aCols[i,Len(oGetVCli:aCols[1])] .and. oGetVCli:aCols[i,nPosRecV] <> 0
					VZF->(dbGoTo(oGetVCli:aCols[i,nPosRecV]))
					If !RecLock("VZF",.F.,.T.)
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
					VZF->(dbdelete())
					VZF->(MsUnlock())
				EndIf
				//
				
				If !oGetVCli:aCols[i,Len(oGetVCli:aCols[i])]
				
					// Linha em Branco ...
					If Empty(oGetVCli:aCols[I,FG_POSVAR("VZF_TIPSER","aHeaderVCli")]) .AND. Empty(oGetVCli:aCols[I,FG_POSVAR("VZF_CODCLI","aHeaderVCli")]) .AND. ( ! lVZFTipVei .or. ( lVZFTipVei .and. Empty(oGetVCli:aCols[I,FG_POSVAR("VZF_TIPVEI","aHeaderVCli")]) ) )
						Loop
					EndIf
					//
					
					// Registro alterado ...
					If oGetVCli:aCols[i,nPosRecV] <> 0
						VZF->(dbGoTo(oGetVCli:aCols[i,nPosRecV]))
						If !RecLock("VZF",.F.,.T.)
							Help("  ",1,"REGNLOCK")
							lRet := .f.
							DisarmTransaction()
							Break
						EndIf
					// Registro Novo ...
					Else
						RecLock("VZF",.t.)
						VZF->VZF_FILIAL := xFilial("VZF")
						VZF->VZF_TIPTEM := M->VOI_TIPTEM
					EndIf
					//
					FG_GRAVAR("VZF",oGetVCli:aCols,aHeaderVCli,i)
				EndIf
				
			Next i
		EndIf

		// grava arquivo filho Tipo Atendimento
		If lVCP
			For i:=1 to len(oGetTAte:aCols)
				DbSelectArea("VCP")
				DbSetOrder(1)
				DbSeek( xFilial("VCP") + VOI->VOI_TIPTEM + oGetTAte:aCols[I,FG_POSVAR("VCP_TPATEN","aHeaderTAte")])

				If (nOpc == 3 .or. nOpc == 4) .And. !oGetTAte:aCols[i,len(oGetTAte:aCols[i])]
					If Empty(oGetTAte:aCols[I,FG_POSVAR("VCP_TPATEN","aHeaderTAte")])
						Loop
					EndIf

					dbSelectArea("VCP")
					If !RecLock("VCP", !Found() )
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf

					FG_GRAVAR("VCP",oGetTAte:aCols,aHeaderTAte,i)
					VCP->VCP_FILIAL := xFilial("VCP")
					VCP->VCP_TIPTEM := M->VOI_TIPTEM
					MsUnlock()
				ElseIf Found() .and. nLenTAte>=i
					// Deleta
					If !RecLock("VCP",.F.,.T.)
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf

					dbdelete()
					MsUnlock()
					WriteSx2("VCP")
				EndIf
			Next
		EndIf
	EndIf

	// exclui arquivo pai
	DbSelectArea("VOI")
	
	If !(nOpc == 3 .or. nOpc == 4) .And. Found()
		
		If lValid
			
			aVetValid := {}
			Aadd(aVetValid, { "VE4" , "VE4_TEMINT" , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VE6" , "VE6_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VEK" , "VEK_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VFB" , "VFB_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VO3" , 4 , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VO4" , 6 , VOI->VOI_TIPTEM  , NIL } )
			//         Aadd(aVetValid, { "VOV" , "VOV_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			//         Aadd(aVetValid, { "VOW" , "VOW_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			//         Aadd(aVetValid, { "VOX" , "VOX_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			//         Aadd(aVetValid, { "VCP" , "VCP_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VS1" , "VS1_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			Aadd(aVetValid, { "VSL" , "VSL_TIPTEM" , VOI->VOI_TIPTEM  , NIL } )
			
			If !FG_DELETA(aVetValid)
				Return .f.
			EndIf
			
		Else
			
			// Deleta
			If !RecLock("VOI",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VOI")
			
		EndIf
		
	EndIf
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_VAL090³ Autor ³  Fabio                ³ Data ³ 07/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FS_VAL090(nOpc)

Local nValLin:=0 , cArq:="" , cCpoChv:="", bChvAcols := ""

FG_MEMVAR()

If oFolder:nOption == 1
	cArq	 :="VOJ"
	cCpoChv  :="Dtos(M->VOJ_DATVIG)"
	bChvAcols:= {|| Dtos(aCols[nValLin,FG_POSVAR("VOJ_DATVIG")] ) }
	
ElseIf oFolder:nOption == 2
	cArq	 :="VOV"
	cCpoChv  :="M->VOV_GRUITE"
	bChvAcols:= {|| aCols[nValLin,FG_POSVAR("VOV_GRUITE")] }
	
ElseIf oFolder:nOption == 3
	cArq	 :="VOW"
	cCpoChv  :="M->VOW_CODPRO"
	bChvAcols:= {|| aCols[nValLin,FG_POSVAR("VOW_CODPRO")] }
	
ElseIf oFolder:nOption == 4
	cArq	 :="VOX"
	cCpoChv  :="M->VOX_TIPSER"
	bChvAcols:= {|| aCols[nValLin,FG_POSVAR("VOX_TIPSER")] }
	
ElseIf oFolder:nOption == 5
	cArq	 :="VGD"
	cCpoChv  :="M->VGD_DEPGAR+M->VGD_TIPOPE"
	bChvAcols:= {|| aCols[nValLin,FG_POSVAR("VGD_DEPGAR")]+aCols[nValLin,FG_POSVAR("VGD_TIPOPE")] }
	
ElseIf oFolder:nOption == 6
	If !lVZFTipVei
		cArq	 :="VZF"
		cCpoChv  :="DtoS(M->VZF_DATVIG)+M->VZF_TIPSER+M->VZF_CODCLI+M->VZF_LOJCLI"
		bChvAcols:= {|| DtoS(aCols[nValLin,FG_POSVAR("VZF_DATVIG")])+aCols[nValLin,FG_POSVAR("VZF_TIPSER")]+aCols[nValLin,FG_POSVAR("VZF_CODCLI")]+aCols[nValLin,FG_POSVAR("VZF_LOJCLI")] }
	Else 
		cArq	 :="VZF"
		cCpoChv  :="DtoS(M->VZF_DATVIG)+M->VZF_TIPSER+M->VZF_CODCLI+M->VZF_LOJCLI+M->VZF_TIPVEI"
		bChvAcols:= {|| DtoS(aCols[nValLin,FG_POSVAR("VZF_DATVIG")])+aCols[nValLin,FG_POSVAR("VZF_TIPSER")]+aCols[nValLin,FG_POSVAR("VZF_CODCLI")]+aCols[nValLin,FG_POSVAR("VZF_LOJCLI")]+aCols[nValLin,FG_POSVAR("VZF_TIPVEI")] }
	EndIF
		

ElseIf oFolder:nOption == 7
	cArq	 :="VOX"
	cCpoChv  :="M->VOX_CODMAR+M->VOX_CODGRU"
	bChvAcols:= {|| aCols[nValLin,FG_POSVAR("VOX_CODMAR")]+aCols[nValLin,FG_POSVAR("VOX_CODGRU")] }

ElseIf oFolder:nOption == 8
	cArq	 :="VCP"
	cCpoChv  :="M->VCP_TPATEN"
	bChvAcols:= {|| aCols[nValLin,FG_POSVAR("VCP_TPATEN")] }
EndIf

If !aCols[n,Len(aCols[n])]	
	
	If nOpc==3 .And. !ExistChav(cArq,M->VOI_TIPTEM+&(cCpoChv))
		
		Return(.f.)
		
	EndIf
	
	For nValLin:=1 to Len(aCols)
		
		If !aCols[nValLin,Len(aCols[nValLin])] .and. nValLin # n .And. Eval(bChvAcols) == &(cCpoChv)
			
			Help("  ",1,"EXISTCHAV")
			Return(.f.)
			
		EndIf
		
		If oFolder:nOption == 1 .and. nValLin < n .and. n > nLenHis .and. Dtos(M->VOJ_DATVIG) <= Dtos(aCols[nValLin,FG_POSVAR("VOJ_DATVIG")])
			
			Help("  ",1,"INFDATFUT")
			Return(.f.)
			
		EndIf

		If oFolder:nOption == 6 .and. nValLin > nLenVCli .and. aCols[nValLin,FG_POSVAR("VZF_DATVIG")] < (DDATABASE + 1)
			
			Help("  ",1,"INFDATFUT")
			Return(.f.)
			
		EndIf

		
	Next
	
EndIf

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TIPSEG ºAutor  ³Fabio               º Data ³  07/16/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida tempo de franquia                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TIPSEG( lMensagem )
Local aArea := {} , cSele := Alias()

Default lMensagem := .t.

aArea := sGetArea(aArea , Alias())

If lMensagem
	
	DbSelectArea("VOI")
	DbSetOrder(1)
	If !DbSeek( xFilial("VOI") + M->VOI_TIPFRA )
		
		Help("  ",1,"REGNOIS" )
		
		// Volta posicoes originais
		sRestArea(aArea)
		DbSelectArea(cSele)
		
		Return( .f. )
		
	EndIf
	
EndIf

If VOI->VOI_SEGURO # "2"
	
	// Volta posicoes originais
	sRestArea(aArea)
	DbSelectArea(cSele)
	
	Return( .f. )
	
EndIf

// Volta posicoes originais
sRestArea(aArea)
DbSelectArea(cSele)

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef		ºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu				                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0 , 1} ,;  		//Pesquisar
{ STR0002 ,"OA090", 0 , 2},; 	//Visualizar
{ STR0003 ,"OA090", 0 , 3},; 	//Incluir
{ STR0004 ,"OA090", 0 , 4} ,; 	//Alterar
{ STR0005 ,"OA090", 0 , 5} }  	//Excluir
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OA090VLDGR ³ Autor ³ Rubens Takahashi    ³ Data ³10/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para atualizar VAR utilizada na Consulta Padrao     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA090VLDGR()
cGruIte := M->VOI_GRUITE
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OA090PCLI ³ Autor ³ Thiago			    ³ Data ³25/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para posicinar no cliente.					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA090PCLI(cReadVar)

Default cReadVar := ReadVar()

SA1->(dbSetOrder(1))
SA1->(dbSetOrder(1))
Do Case
Case cReadVar == "M->VZF_CODCLI"
	If !SA1->(dbSeek(xFilial("SA1")+M->VZF_CODCLI))
		Return .f.
	EndIf
	aCols[n, FG_POSVAR("VZF_LOJCLI","aHeader")] := M->VZF_LOJCLI := Space(TamSX3("VZF_LOJCLI")[1])
	aCols[n, FG_POSVAR("VZF_NOMCLI","aHeader")] := M->VZF_NOMCLI := Space(TamSX3("VZF_NOMCLI")[1])
Case cReadVar == "M->VZF_LOJCLI"
	If !SA1->(dbSeek(xFilial("SA1")+M->VZF_CODCLI+M->VZF_LOJCLI))
		Return .f.
	EndIf
	aCols[n, FG_POSVAR("VZF_NOMCLI","aHeader")] := M->VZF_NOMCLI := SA1->A1_NOME
EndCase
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OA090FDEM ³ Autor ³ Thiago			    ³ Data ³25/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao de funcionario demitidos.					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA090FDEM()                                          
dbSelectArea("VAI")
dbSetOrder(1)
dbSeek(xFilial("VAI")+M->VOW_CODPRO)
if !Empty(VAI->VAI_DATDEM)
	MsgInfo(STR0016,STR0017) // Este funcionário foi demitido. Não será possível selecioná-lo. / Atenção
    Return(.f.)
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_LIMPCPO ³ Autor ³ Thiago			   		 ³ Data ³17/05/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpo descricao do acols quandadmino o codigo nao estiver preenchido.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMPCPO()

if Altera       
	if FG_POSVAR("VOW_CODPRO","aHeader") > 0
		if Empty(aCols[n,FG_POSVAR("VOW_CODPRO","aHeader")]) .and. !Empty(aCols[n,FG_POSVAR("VOW_NOMPRO","aHeader")])
			aCols[n,FG_POSVAR("VOW_NOMPRO","aHeader")] := ""
		Endif
	Endif		
	oGetCon:oBrowse:Refresh()
Endif
	
Return(.t.)


Function OA090FIELDOK(cReadVar)
	Default cReadVar := ReadVar()

	FG_MemVar()

	If cReadVar == "M->VOX_CODMAR"
		M->VG8_CODMAR := M->VOX_CODMAR
	Endif
Return .t.
