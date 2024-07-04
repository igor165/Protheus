// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 15     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "protheus.ch"
#Include "VEIVM060.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VEIVM060 ³ Autor ³ Andre Luis Almeida     ³ Data ³ 29/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ BLOQUEIO / DESBLOQUEIO de Veiculos VV1                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM060(cParChaint)
Local aObjects   := {}, aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Private aChassi  := {}
Private cChassi  := space(25)
Private cDesVei1 := space(200)
Private cDesVei2 := space(200)
Private cDesVei3 := space(200)
Private cMotivo  := space(100)
Private dDatVal  := ctod("")
Private nHorVal  := 2359
Private lFazBloq := .f.
Private lDesBloq := .f.
Private lVeiBloq := .f.
Private cChaInt  := space(tamsx3("VV1_CHAINT")[1])

Default cParChaint := cChaInt
cChaInt := cParChaint

aInfo := { aSizeHalf[1], aSizeHalf[2],aSizeHalf[3] ,aSizeHalf[4], 3, 3 } // Tamanho total da tela

aAdd( aObjects, { 0, 40, .T., .F. } ) // Topo
aAdd( aObjects, { 0,  0, .T., .T. } ) // ListBox

aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oBloqVei TITLE STR0001 From aSizeHalf[7], 0 TO aSizeHalf[6], aSizeHalf[5] of oMainWnd;
	PIXEL STYLE DS_MODALFRAME STATUS // Bloqueio/Desbloqueio de Veiculos

@ aPos[1,1], aPos[1,2] + 025 MSGET oChassi VAR cChaInt F3 "V17";
	VALID FS_VALCHASSI() PICTURE "@!" SIZE 90,8 OF oBloqVei PIXEL COLOR CLR_BLUE HASBUTTON

If !Empty(cParChaint)
	FS_VALCHASSI()
EndIf

DbSelectArea("VAI")
DbSetOrder(4)
DbSeek( xFilial("VAI") + __CUSERID )

If VAI->VAI_BLOQVE # "0"
	If VAI->VAI_BLOQVE $ "1/3"
		lFazBloq := .t.
	EndIf

	If VAI->VAI_BLOQVE $ "2/3"
		lDesBloq := .t.
	EndIf
EndIf

FS_VERCHASSI(0)

oBloqVei:lEscClose := .F.

// Veículo
@ aPos[1,1]     , aPos[1,2] + 003 SAY STR0002 SIZE 45,40 OF oBloqVei PIXEL COLOR CLR_BLUE // Veiculo
@ aPos[1,1] + 00, aPos[1,2] + 130 SAY cDesVei1 SIZE 250,08 OF oBloqVei PIXEL COLOR CLR_BLUE
@ aPos[1,1] + 09, aPos[1,2] + 130 SAY cDesVei2 SIZE 250,08 OF oBloqVei PIXEL COLOR CLR_BLUE
@ aPos[1,1] + 18, aPos[1,2] + 130 SAY cDesVei3 SIZE 250,08 OF oBloqVei PIXEL COLOR CLR_BLUE
// Fim Veículo

// Validade
@ aPos[1,1] + 14, aPos[1,2] + 003 SAY STR0003 SIZE 65,40 OF oBloqVei PIXEL COLOR CLR_BLUE // Validade

@ aPos[1,1] + 14, aPos[1,2] + 025 MSGET oDatVal VAR dDatVal PICTURE "@D";
	VALID( Empty(dDatVal) .or. ( dDatVal >= dDataBase ) ) SIZE 45,8 OF oBloqVei PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[1,1] + 14, aPos[1,2] + 075 MSGET oHorVal VAR nHorVal PICTURE "@R 99:99";
	VALID( nHorVal >= 0 .and. nHorVal <= 2359 ) SIZE 30,8 OF oBloqVei PIXEL COLOR CLR_BLUE

@ aPos[1,1] + 14, aPos[1,2] + 105 SAY STR0019 SIZE 65,40 OF oBloqVei PIXEL COLOR CLR_BLUE // hs
// Fim Validade

// Motivo
@ aPos[1,1] + 28, aPos[1,2] + 003 SAY STR0004 SIZE 65,40 OF oBloqVei PIXEL COLOR CLR_BLUE // Motivo
@ aPos[1,1] + 28, aPos[1,2] + 025 MSGET oMotivo VAR cMotivo PICTURE "@!" SIZE 250,8 OF oBloqVei PIXEL COLOR CLR_BLUE
// Fim Motivo

// Botões
@ aPos[1,1] + 28, aPos[1,4] - 115 BUTTON oFazBloq PROMPT (STR0005) OF oBloqVei SIZE 55,10; // BLOQUEAR
	PIXEL ACTION FS_BLOCHASSI("1") WHEN lFazBloq .and. !Empty(dDatVal) .and. !lVeiBloq .and. LEN(aChassi) > 0

@ aPos[1,1] + 28, aPos[1,4] - 055 BUTTON oDesBloq PROMPT (STR0006) OF oBloqVei SIZE 55,10; // DESBLOQUEAR
	PIXEL ACTION FS_BLOCHASSI("0") WHEN lDesBloq .and. !Empty(aChassi[oLbVeic:nAt,3])

@ aPos[1,1], aPos[1,4] - 055 BUTTON oSair PROMPT (STR0007) OF oBloqVei SIZE 55,10; // SAIR
	PIXEL ACTION ( oBloqVei:End() )
// Fim Botões

// Listagem
@ aPos[2,1], aPos[2,2] LISTBOX oLbVeic FIELDS HEADER STR0025, STR0008, STR0023, STR0024, STR0009, STR0003, STR0004; // Chassi Interno / Chassi / Modelo Veículo / "Ano Fab/Mod" / "Usuario/Data" / Validade / Motivo
	COLSIZES 50,65,45,130 SIZE aPos[2,4]-2,aPos[2,3]-46 OF oBloqVei PIXEL

oLbVeic:SetArray(aChassi)
oLbVeic:bLine := { || { aChassi[oLbVeic:nAt,8], aChassi[oLbVeic:nAt,1] , aChassi[oLbVeic:nAt,6],;
	aChassi[oLbVeic:nAt,7], aChassi[oLbVeic:nAt,2] , aChassi[oLbVeic:nAt,3] , aChassi[oLbVeic:nAt,4] }}
// Fim Listagem

ACTIVATE MSDIALOG oBloqVei
Return

Static Function FS_VERCHASSI(nTp)
Local cQuery  	:= ""
Local cQAlVB01 	:= "SQLVB01"
Local cQAlVB02	:= "SQLVB02"
Local cHs     	:= STR0019 //hs
Local cMsgBloq  := STR0021 //DESBLOQUEIO AUTOMATICO
Local cUsuario	:= " "
Local aAllUsers := FWSFALLUSERS(,{"USR_NOME"})
Local nPos		:= 0

aChassi := {}

cQuery := "SELECT DISTINCT VV1.VV1_CHAINT, "
cQuery += "       VB0.R_E_C_N_O_, VB0.VB0_DATVAL, VB0.VB0_HORVAL, VB0.VB0_USUBLO, "
cQuery += "       VB0.VB0_DATBLO, VB0.VB0_HORBLO, VB0.VB0_MOTBLO, "
cQuery += "       VV1.VV1_CHASSI, VV1_FABMOD, VV1_CODMAR, VV1_MODVEI, VV2_DESMOD "
cQuery += "FROM "       + RetSqlName("VB0") + " VB0 "
cQuery += "INNER JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL='" + xFilial("VV1") + "' "
cQuery += "  AND VV1.VV1_CHAINT = VB0.VB0_CHAINT AND VV1.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN " + RetSqlName("VV2") + " VV2 ON VV2.VV2_CODMAR = VV1.VV1_CODMAR "
cQuery += "AND VV2.VV2_MODVEI = VV1.VV1_MODVEI " 
cQuery += "AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD "
cQuery += "AND VV2.D_E_L_E_T_ = ' ' "
cQuery += "AND VV2.VV2_FILIAL = '"+xFilial("VV2")+"' "
cQuery += "WHERE VB0.VB0_FILIAL='" + xFilial("VB0") + "' AND VB0.VB0_DATDES='        ' AND VB0.D_E_L_E_T_=' ' "
cQuery += "AND (VB0_DATVAL > '"+DtoS(dDataBase)+"' "
cQuery += "		OR (VB0_DATVAL = '"+DtoS(dDataBase)+"' AND VB0_HORVAL < '"+left(time(), 2) + substr(time(), 4, 2)+"' )) "

dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cQAlVB01, .F., .T. )

Do While !( cQAlVB01 )->( Eof() )
	cUsuario := " "
	nPos   := aScan( aAllUsers, { |x| x[2] == ( cQAlVB01 )->( VB0_USUBLO ) })
	If nPos > 0
		cUsuario := aAllUsers[nPos,3]
	EndIf
	aAdd(aChassi, {                                               ;
		( cQAlVB01 )->( VV1_CHASSI ),                              ; // 01
		AllTrim(cUsuario) + " " +           ; // 02
		Transform(stod(( cQAlVB01 )->( VB0_DATBLO )) ,"@D") + " " +;
		Transform(( cQAlVB01 )->( VB0_HORBLO ), "@R 99:99") + " " +;
		cHs,                                                  ;       // hs
		Transform(stod(( cQAlVB01 )->( VB0_DATVAL )), "@D") + " " +; // 03
		Transform(( cQAlVB01 )->( VB0_HORVAL ), "@R 99:99") + " " +;
		cHs,                                                  ;       //hs
		( cQAlVB01 )->( VB0_MOTBLO ),                              ; // 04
		( cQAlVB01 )->( R_E_C_N_O_ ),                              ; // 05
		( cQAlVB01 )->( VV2_DESMOD ),                               ; // 06
		Transform(( cQAlVB01 )->( VV1_FABMOD ), "@R 9999/9999"),   ; // 07
		( cQAlVB01 )->( VV1_CHAINT )                               ; // 08
	})
	( cQAlVB01 )->( DbSkip() )
EndDo

( cQAlVB01 )->( dbCloseArea() )

cQuery := "SELECT VB0.R_E_C_N_O_ "
cQuery += "FROM "       + RetSqlName("VB0") + " VB0 "
cQuery += "INNER JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL='" + xFilial("VV1") + "' "
cQuery += "  AND VV1.VV1_CHAINT = VB0.VB0_CHAINT AND VV1.D_E_L_E_T_=' ' "
cQuery += "WHERE VB0.VB0_FILIAL='" + xFilial("VB0") + "' AND VB0.VB0_DATDES='        ' AND VB0.D_E_L_E_T_=' ' "
cQuery += "AND (VB0_DATVAL < '"+DtoS(dDataBase)+"' "
cQuery += "		OR (VB0_DATVAL = '"+DtoS(dDataBase)+"' AND VB0_HORVAL > '"+left(time(), 2) + substr(time(), 4, 2)+"' ))"

dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cQAlVB02, .F., .T. )
Do While !( cQAlVB02 )->( Eof() )	

	DbSelectArea("VB0")
	DbGoTo(( cQAlVB02 )->( R_E_C_N_O_ ))
	RecLock("VB0",.f.)
		VB0->VB0_DATDES := VB0->VB0_DATVAL
		VB0->VB0_HORDES := VB0->VB0_HORVAL
		VB0->VB0_USUDES := VB0->VB0_USUBLO
		VB0->VB0_MOTDES := UPPER(cMsgBloq) 
	MsUnlock()
	( cQAlVB02 )->( DbSkip() )
EndDo

( cQAlVB02 )->( dbCloseArea() )

If len(aChassi) > 0
	aSort(aChassi, 1,, {|x, y| x[8] < y[8] })
Else
	aAdd(aChassi, {"", "", "", "", "", "", 0, ""})
EndIf

If nTp > 0
	oLbVeic:nAt := 1

	oLbVeic:SetArray(aChassi)
	oLbVeic:bLine := { || { aChassi[oLbVeic:nAt,8], aChassi[oLbVeic:nAt,1], aChassi[oLbVeic:nAt,6],;
		aChassi[oLbVeic:nAt,7], aChassi[oLbVeic:nAt,2], aChassi[oLbVeic:nAt,3], aChassi[oLbVeic:nAt,4] }}

	oLbVeic:SetFocus()
	oLbVeic:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VALCHASSI³ Autor ³ Andre Luis Almeida   ³ Data ³ 29/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Valida Chassi                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALCHASSI()
Local nPos := 0
Local lRet := .f.
Local aRet := {}

cDesVei1 := cDesVei2 := cDesVei3 := space(200)

If !Empty(cChaInt)
	DbSelectArea("VV1")
	DbSetOrder(1)

	If DbSeek(xFilial("VV1") + cChaInt)
		cChassi := VV1->VV1_CHASSI

		lRet := FG_POSVEI("cChassi",)
		If lRet
			If VV1->VV1_SITVEI <> "1"
				If ( VV1->VV1_GRASEV <> "6" .or. ( VV1->VV1_GRASEV == "6" .and. VV1->VV1_SITVEI == "0" ) )
					DbSelectArea("VV2")
					DbSetOrder(1)
					DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

					DbSelectArea("VVC")
					DbSetOrder(1)
					DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )

					cChassi  := VV1->VV1_CHASSI
					cDesVei1 := STR0011 + Alltrim(VV1->VV1_CODMAR) + " " + Alltrim(VV2->VV2_DESMOD) // Marca/Modelo:

					cDesVei2 := STR0012 + Transform(VV1->VV1_PLAVEI, VV1->(x3Picture("VV1_PLAVEI"))) + " " +; // Placa:
						STR0013 + Transform(VV1->VV1_FABMOD, "@R 9999/9999") // Fab/Mod:

					cDesVei3 := STR0014 + Alltrim(VVC->VVC_DESCRI) // Cor:

					lVeiBloq := .f.

					aRet := VM060VEIBLO(VV1->VV1_CHAINT, "B") // Verificar se o veiculo ja se encontra bloqueado
					If len(aRet) > 0
						lVeiBloq := .t.

						MsgAlert(STR0020 + " " + cChassi + " " + STR0025 + ": " + cChaInt, STR0010) // Veiculo ja esta Bloqueado! / Chassi Interno / Atencao

						nPos := aScan(aChassi, { |x| x[8] == VV1->VV1_CHAINT })
						If nPos > 0
							oLbVeic:nAt := nPos

							oLbVeic:Refresh()
							olBVeic:SetFocus()
						EndIf
					EndIf
				Else
					DbSelectArea("VV1")

					MsgAlert(STR0015 + " " + cChassi + " " + STR0025 + ": " + cChaInt, STR0010) // Veiculo Invalido! / Chassi Interno / Atencao

					cChassi  := space(25)
					lRet     := .t.

					oChassi:SetFocus()
				EndIf
			Else
				DbSelectArea("VV1")

				MsgAlert(STR0022 + " " + cChassi + " " + STR0025 + ": " + cChaInt, STR0010) // Impossível continuar. Veículo vendido! / Chassi Interno / Atencao

				cChassi  := space(25)
				lRet     := .t.

				oChassi:SetFocus()
			EndIf
		Else
			DbSelectArea("VV1")

			MsgAlert(STR0015 + " " + cChassi + " " + STR0025 + ": " + cChaInt, STR0010) // Veiculo Invalido! / Chassi Interno / Atencao

			cChassi  := space(25)
			lRet     := .t.

			oChassi:SetFocus()
		EndIf
	EndIf
Else
	lRet := .t.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_BLOCHASSI³ Autor ³ Andre Luis Almeida   ³ Data ³ 29/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Bloqueia / Desbloqueia Chassi                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BLOCHASSI(cTipo)
Local aParamBox := {} // ParamBox
Local aRet      := {}
Local cMotDes   := space(100)
Local nRecNoVB0 := 0
Local lRet      := .t.

If cTipo == "1"
	// Bloqueio
	If ExistBlock("PEVM060B")
		If !ExecBlock("PEVM060B", .f., .f.)
			Return(.f.)
		EndIf
	EndIf

	DbSelectArea("VV1")
	DbSetOrder(1)

	// Veículo
	If !DbSeek( xFilial("VV1") + cChaInt )
		lRet := .f.

		MsgAlert(STR0015 + " " + cChassi + " " + STR0025 + ": " + cChaInt, STR0010) // Veiculo Invalido! / Chassi Interno / Atencao

		oChassi:SetFocus()

		Return()
	Else
		cChassi := VV1->VV1_CHASSI
	EndIf

	// Validade
	If Empty(dDatVal)
		lRet := .f.

		MsgAlert(STR0016, STR0010) // Data de Validade Invalida ! / Atencao

		oDatVal:SetFocus()

		Return()
	EndIf

	// Motivo
	If Empty(cMotivo)
		lRet := .f.

		MsgAlert(STR0017, STR0010) // Motivo Invalido ! / Atencao

		oMotivo:SetFocus()

		Return()
	EndIf

	// Verificação de Bloqueio
	If lRet
		If VEIVM060_JaBloqueado(VV1->VV1_CHAINT)
			MsgAlert(STR0020, STR0010) // veículo já está bloqueado
		Else
			DbSelectArea("VB0")

			RecLock("VB0",.t.)

			VB0->VB0_FILIAL := xFilial("VB0")
			VB0->VB0_CHAINT := VV1->VV1_CHAINT
			VB0->VB0_DATBLO := dDataBase
			VB0->VB0_HORBLO := val(left(time(), 2) + substr(time(), 4, 2))
			VB0->VB0_USUBLO := __CUSERID
			VB0->VB0_MOTBLO := cMotivo
			VB0->VB0_DATVAL := dDatVal
			VB0->VB0_HORVAL := nHorVal

			MsUnlock()

			nRecNoVB0 := VB0->(RecNo())
		EndIf
	EndIf
Else
	// Desbloqueio
	If ExistBlock("PEVM060D")
		If !ExecBlock("PEVM060D", .f., .f.)
			Return(.f.)
		EndIf
	EndIf

	lRet := .f.

	aAdd(aParamBox, {1, STR0008, aChassi[oLbVeic:nAt,1], "@!S20", "", "", ".f.", 0, .f.}) // Chassi
	aAdd(aParamBox, {1, STR0025, aChassi[oLbVeic:nAt,8], "@!S20", "", "", ".f.", 0, .f.}) // Chassi Interno
	aAdd(aParamBox, {1, STR0004, cMotDes,                "@!S20", "", "", ""   , 0, .f.}) // Motivo

	If ParamBox(aParamBox, STR0018, @aRet,,,,,,,, .F.) // Deseja DESBLOQUEAR o VEICULO ?
		cMotDes := aRet[3] // Motivo Desbloqueio
		lRet    := .t.
	EndIf

	If lRet
		DbSelectArea("VB0")
		DbSetOrder(2)

		If DbSeek( xFilial('VB0') + aChassi[oLbVeic:nAt,8] + space(tamsx3('VB0_DATDES')[1]) )
			RecLock("VB0", .f.)

			VB0->VB0_DATDES := dDataBase
			VB0->VB0_HORDES := val(left(time(), 2) + substr(time(), 4, 2))
			VB0->VB0_USUDES := __CUSERID
			VB0->VB0_MOTDES := cMotDes

			MsUnlock()

			nRecNoVB0 := VB0->(RecNo())
		EndIf
	EndIf
EndIf

If lRet
	// Ponto de Entrada para verificações customizadas após Bloqueio/Desbloqueio realizado com sucesso
	If ExistBlock("VM060DPGR")
		ExecBlock("VM060DPGR", .f., .f., {cTipo, nRecNoVB0})
	EndIf

	FS_VERCHASSI(1)

	cChaInt  := space(tamsx3("VV1_CHAINT")[1])
	cChassi  := space(25)
	cDesVei1 := cDesVei2 := cDesVei3 := space(200)
	cMotivo  := space(100)
	dDatVal  := ctod("")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VM060VEIBLO³ Autor ³ Andre Luis Almeida    ³ Data ³ 06/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Veirifica se o Veiculo esta Bloqueado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ _cChaInt = Chassi Interno do Veiculo                        ³±±
±±³         ³ _cTp = Tp.Pesquisa - Veiculo tem? ("B"loqueio/"D"esbloqueio)³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno  ³ Vetor com o Registro do VB0 referente ao Bloqueio do Veiculo³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM060VEIBLO(_cChaInt, _cTp)
Local lOk     := .t.
Local aRet    := {}
Local cSAlias := Alias()
Local cQuery  := ""
Local cQAlVB0 := "SQLVB0"

Default _cTp  := ""

cQuery := "SELECT VB0.R_E_C_N_O_, VB0.VB0_DATVAL, VB0.VB0_HORVAL, VB0.VB0_USUBLO, "
cQuery += "       VB0.VB0_DATBLO, VB0.VB0_HORBLO, VB0.VB0_MOTBLO, VB0.VB0_DATDES "
cQuery += "FROM " + RetSqlName("VB0") +" VB0 "
cQuery += "WHERE VB0.VB0_FILIAL='" + xFilial("VB0") + "' AND VB0.VB0_CHAINT='" + _cChaInt + "' "

If !Empty(_cTp)
	cQuery += " AND VB0.VB0_DATDES" + IIf(_cTp == "B", "=", "<>") + "'        ' " // Bloqueado ou Desbloqueado
EndIf

cQuery += " AND VB0.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVB0, .F., .T. )

Do While !( cQAlVB0 )->( Eof() )
	lOk := .t.

	If Empty(( cQAlVB0 )->( VB0_DATDES ))
		If stod( ( cQAlVB0 )->( VB0_DATVAL ) ) < dDataBase
			lOk := .f.
		ElseIf stod( ( cQAlVB0 )->( VB0_DATVAL ) ) == dDataBase
			If ( cQAlVB0 )->( VB0_HORVAL ) < val(left(time(), 2) + substr(time(), 4, 2))
				lOk := .f.
			EndIf
		EndIf
	EndIf

	If lOk // Registro do Bloqueio //
		aAdd(aRet, {                                                  ;
			UsrRetName(( cQAlVB0 )->( VB0_USUBLO )) + " " +           ; // 01
			Transform(stod(( cQAlVB0 )->( VB0_DATBLO )), "@D") + " " +;
			Transform(( cQAlVB0 )->( VB0_HORBLO ), "@R 99:99") + " " +;
			STR0019,                                                  ;       // hs
			( cQAlVB0 )->( VB0_MOTBLO ),                              ; // 02
			Transform(stod(( cQAlVB0 )->( VB0_DATVAL )), "@D") + " " +; // 03
			Transform(( cQAlVB0 )->( VB0_HORVAL ), "@R 99:99") + " " +;
			STR0019,                                                  ;       // hs
			( cQAlVB0 )->( R_E_C_N_O_ )                               ; // 04
		})

		Exit
	Else // Desbloqueio Automatico //
		DbSelectArea("VB0")

		DbGoTo(( cQAlVB0 )->( R_E_C_N_O_ ))

		RecLock("VB0", .f.)

		VB0->VB0_DATDES := VB0->VB0_DATVAL
		VB0->VB0_HORDES := VB0->VB0_HORVAL
		VB0->VB0_USUDES := VB0->VB0_USUBLO
		VB0->VB0_MOTDES := UPPER(STR0021) // "DESBLOQUEIO AUTOMATICO"

		MsUnlock()
	EndIf

	( cQAlVB0 )->( DbSkip() )
EndDo

( cQAlVB0 )->( dbCloseArea() )

If !Empty(cSAlias)
	DbSelectArea(cSAlias)
EndIf
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VM060AUT  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 09/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Bloqueia / Desbloqueia Automaticamente                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ _cChaInt = Chassi Interno do Veiculo                        ³±±
±±³         ³ _cTp     = Tipo ("B"loqueio/"D"esbloqueio                   ³±±
±±³         ³ _cMotivo = Motivo (Bloqueio)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM060AUT(_cChaInt, _cTp, _cMotivo)
Local aRet       := {}

Default _cTp     := ""
Default _cMotivo := ""

If _cTp == "B"
	// Bloqueio Automatico
	DbSelectArea("VB0")

	RecLock("VB0", .t.)

	VB0->VB0_FILIAL := xFilial("VB0")
	VB0->VB0_CHAINT := _cChaInt
	VB0->VB0_DATBLO := dDataBase
	VB0->VB0_HORBLO := val(left(time(), 2) + substr(time(), 4, 2))
	VB0->VB0_USUBLO := __CUSERID
	VB0->VB0_MOTBLO := _cMotivo
	VB0->VB0_DATVAL := (dDataBase + 600)
	VB0->VB0_HORVAL := val(left(time(), 2) + substr(time(), 4, 2))

	MsUnlock()
ElseIf _cTp == "D"
	// Desbloqueio Automatico
	aRet := VM060VEIBLO(_cChaInt, "B") //Retorna o Registro do Bloqueio do Veiculo
	If len(aRet) > 0 // Existe Bloqueio
		DbSelectArea("VB0")

		DbGoTo(aRet[1,4]) // VB0->(RecNo())

		RecLock("VB0", .f.)

		VB0->VB0_DATDES := dDataBase
		VB0->VB0_HORDES := val(left(time(), 2) + substr(time(), 4, 2))
		VB0->VB0_USUDES := __CUSERID
		VB0->VB0_MOTDES := UPPER(STR0021) // "DESBLOQUEIO AUTOMATICO"

		MsUnlock()
	EndIf
EndIf
Return()

/*/{Protheus.doc} VEIVM060_JaBloqueado
	Verifica se o <br>veiculo já está bloqueado
	@author vinicius
	@since 25/05/2017
	@version undefined
	@param _cChaInt, string, codigo do veiculo
	@type function
/*/
Function VEIVM060_JaBloqueado(_cChaInt)
	cQuery := "SELECT COALESCE(count(*), 0) "
	cQuery += "From " + RetSqlName('VB0') + " "
	cQuery += "WHERE VB0_FILIAL = '" + xFilial('SB0') + "' "
	cQuery += "  AND VB0_CHAINT = '" + _cChaInt + "' "
	cQuery += "  AND D_E_L_E_T_ = ' ' "
	cQuery += "  AND VB0_DATDES = ' ' "
Return FM_SQL(cQuery) > 0
