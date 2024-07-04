// ษออออออออหออออออออป
// บ Versao บ 20     บ
// ศออออออออสออออออออผ

Static aAbaTmp    := {.t., .t., .t.}
Static aPerIniFin := {}

#Include "OFIOC140.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOC140  บAutor  ณFabio               บ Data ณ  05/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMapa da Oficina                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC140
Private aVerPad := {}

Processa({|| FS_STATUSBOX() })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_STATUSBบAutor  ณFabio               บ Data ณ  10/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela com os Box e Produtivos                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_STATUSBOX()
Local aObjects  := {}, aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Local cResource, aPeriodo := {}
Local nHora := 0, nSecao := 0, nLinha := 0, nColuna := 0, nAltura := 0, nLargura := 0
Local oBmpBox, oBmpTecnico, ni := 0, nTecla := 0
Local oVerde, oAmarelo, oVermelho, oPVerde, oPAmarelo, oPVermelho, oNomPro

Local cSQLVOD := "SQLVOD"
Local cSQLSX5 := "SQLSX5"
Local cQuery  := ""
Local cCodSec := ""
Local cTabSX5 := ""

Private oScroll1, oScroll2, aProdutivos := {}, aProdut2 := {}, oTecnico
Private cFocuBox := "", cFocuPri := "", aVarOnLine := {}, nTamVON := VON->(RecCount()), nTamVAI := VAI->(RecCount())
Private cTitulo := STR0001 //"Mapa da Oficina"
Private lFechaStatus := If(Type("lFechaStatus") == "U", .f., lFechaStatus)
Private aVetor := {{ "", "", "", "" }}

Private aBotEnc := {}
Private cProdut := ""

AADD(aBotEnc, {"responsa", {|| OFIOC090()}, STR0051}) // Movimento do Produtivo

Aadd( aVarOnLine , {} )   && Box
Aadd( aVarOnLine , {} )   && Produtivo
Aadd( aVarOnLine , {} )   && Prisma

ProcRegua( VON->(RecCount()) )

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ], aSizeHalf[ 3 ], aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd(aObjects, { 0, 100, .T., .T. }) // Folders

aPos := MsObjSize(aInfo, aObjects)

&& Monta tela com os box
DEFINE MSDIALOG oDlgStatus TITLE cTitulo From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] of oMainWnd PIXEL

@ aPos[1,1],aPos[1,2] FOLDER oFolder SIZE aPos[1,4] - 2,aPos[1,3] - aPos[1,1] + 3 OF oDlgStatus PROMPTS "&" + STR0024, "&" + STR0004, "&" + STR0015 PIXEL // Box da oficina / Mecanicos / Prisma
oFolder:bChange := {|| FS_BARRA()}

&& Abas do Folder
FG_INIFOLDER("oFolder", 2)

@ 001,1 SCROLLBOX oScroll1 VERTICAL SIZE 182,310 OF oFolder:aDialogs[1] BORDER PIXEL
oScroll1:Align := CONTROL_ALIGN_ALLCLIENT

oTPane1BOTTOM := TPanel():New(0, 0, "", oFolder:aDialogs[1], NIL, .T., .F., NIL, NIL, 0, 15, .T., .F.)
oTPane1BOTTOM:Align := CONTROL_ALIGN_BOTTOM

oTPane2BOTTOM := TPanel():New(0, 0, "", oFolder:aDialogs[2], NIL, .T., .F., NIL, NIL, 0, 15, .T., .F.)
oTPane2BOTTOM:Align := CONTROL_ALIGN_BOTTOM

oTPane3BOTTOM := TPanel():New(0, 0, "", oFolder:aDialogs[3], NIL, .T., .F., NIL, NIL, 0, 15, .T., .F.)
oTPane3BOTTOM:Align := CONTROL_ALIGN_BOTTOM

// Folder 1 //
cQuery := "SELECT VOD.VOD_CODSEC, VOD.VOD_DESSEC, "
cQuery += "       VON.VON_NUMBOX, VOF.VOF_SITBOX "
cQuery += "FROM " + RetSqlName("VOD") + " VOD "
cQuery += "INNER JOIN " + RetSqlName("VON") + " VON ON VON.VON_FILIAL = '" + xFilial("VON") + "' AND VON.VON_CODSEC = VOD.VOD_CODSEC AND VON.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("VOF") + " VOF ON VOF.VOF_FILIAL = '" + xFilial("VOF") + "' AND VOF.VOF_NUMBOX = VON.VON_NUMBOX AND VOF.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VOD.VOD_FILIAL = '" + xFilial("VOD") + "' AND VOD.D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVOD, .F., .T.)

aAbaTmp[1] := .f.
nSecao     := 4

While !(cSQLVOD)->(Eof())
	If cCodSec <> (cSQLVOD)->(VOD_CODSEC)
		nLinha   := nSecao + 6
		nColuna  := 2
		nAltura  := nLinha + 25
		nLargura := nColuna
	EndIf

	aAbaTmp[1] := .t.

	If (cSQLVOD)->(VOF_SITBOX) == "O"
		cResource := "VERMELHO"
	ElseIf (cSQLVOD)->(VOF_SITBOX) == "P"
		cResource := "AMARELO"
	Else
		cResource := "VERDE"
	EndIf

	If nColuna >= (aPos[1,4] - 70)
		nColuna  := 2
		nLargura := nColuna
		nLinha   := nAltura + 1
		nAltura  := nLinha + 25
	EndIf

	nColuna := nLargura + 3
	nLargura:= nColuna + 24

	&("oCor" + Alltrim((cSQLVOD)->(VON_NUMBOX))) := NIL
	&("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX))) := NIL

	@ nLinha + 1, nColuna to nAltura + 1, nLargura OF oScroll1 PIXEL
	@ nLinha + 3, nColuna + 6 REPOSITORY &("oCor" + Alltrim((cSQLVOD)->(VON_NUMBOX))) NOBORDER SIZE 10,10 OF oScroll1 PIXEL
	&("oCor" + Alltrim((cSQLVOD)->(VON_NUMBOX))):LoadBmp(cResource)

	@ nLinha + 13, nColuna + 2 BUTTON &("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX))) PROMPT (cSQLVOD)->(VON_NUMBOX) OF oScroll1 SIZE 20,11 PIXEL ACTION FS_BOXPRISMA()
	&("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":cReadVar := '" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + "'")
	&("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":bGotFocus := {|| cFocuBox := '" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + "'}" )

	If !((cSQLVOD)->(VOF_SITBOX) $ "O/P")
		&("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":Disable()")
	Else
		Aadd(aVarOnLine[1], { Alltrim((cSQLVOD)->(VON_NUMBOX)), (cSQLVOD)->(VON_NUMBOX), (Len(aVarOnLine) == 0) })
	EndIf

	IncProc(OemToAnsi(STR0048)) // Levantando situacao do Box

	@ nSecao,001 TO nAltura + 5, aPos[1,4] - 17 LABEL Alltrim((cSQLVOD)->(VOD_DESSEC)) OF oScroll1 PIXEL

	nSecao := nAltura + 8

	cCodSec := (cSQLVOD)->(VOD_CODSEC)

	(cSQLVOD)->(dbSkip())
EndDo

(cSQLVOD)->(dbCloseArea())

DbSelectArea("VOD")

// Folder 2 //
oBBranco   := LoadBitmap(GetResources(), "FOLDER9")
oBVerde    := LoadBitmap(GetResources(), "BR_VERDE")
oBVermelho := LoadBitmap(GetResources(), "BR_VERMELHO")
oBAmarelo  := LoadBitmap(GetResources(), "BR_AMARELO")
oBAzul     := LoadBitmap(GetResources(), "BR_AZUL")

@ 001,001 LISTBOX oLbProdut FIELDS HEADER  OemToAnsi(""),                                                                                  ;
	OemToAnsi(STR0056),                                                                                                                    ; // Produtivo
	OemToAnsi(STR0044),                                                                                                                    ; // Nome
	OemToAnsi(STR0057)                                                                                                                     ; // Pausa do Servi็o
	COLSIZES 30,40,150,40 SIZE (aPos[1,4] - 6) / 2,100 OF oFolder:aDialogs[2]                                                              ;
	ON CHANGE FS_DESABILI(aProdutivos[oLbProdut:nAt, 4], aProdutivos[oLbProdut:nAt, 2])                                                    ;
	ON DBLCLICK (If(aProdutivos[oLbProdut:nAt, 1] == "P", .F., (oTimeStatus:lActive := .F., FS_PERINIFIN(aProdutivo[oLbProdut:nAt, 2]),    ;
		FG_TEMPTRA(aProdutivo[oLbProdut:nAt, 2], aPerIniFin[1], aPerIniFin[2], aPerIniFin[3], aPerIniFin[4]), oTimeStatus:lActive := .t.)));
	Font TFont():New("System", 08, 15) PIXEL

oLbProdut:Align := CONTROL_ALIGN_LEFT
oLbProdut:bGotFocus := {|| FS_DESABILI(aProdutivos[oLbProdut:nAt, 4], aProdutivos[oLbProdut:nAt, 2]), oLbProdut:Refresh() }
Aadd(aProdutivos, { " ", " ", " ", " " })

oLbProdut:SetArray(aProdutivos)
oLbProdut:bLine := { || { If(Empty(aProdutivos[oLbProdut:nAt, 1]), oBBranco, If(aProdutivos[oLbProdut:nAt, 1] == "T", oBVerde, If(aProdutivos[oLbProdut:nAt, 1] == "E", oBVermelho,;
	If(aProdutivos[oLbProdut:nAt, 1] == "A", oBAzul, oBAmarelo)))), aProdutivos[oLbProdut:nAt, 2], aProdutivos[oLbProdut:nAt, 3], aProdutivos[oLbProdut:nAt, 4] } }

@ 001,001 LISTBOX oLbProdut2 FIELDS HEADER  OemToAnsi(""),                                                                                ;
	OemToAnsi(STR0056),                                                                                                                   ; // Produtivo
	OemToAnsi(STR0044),                                                                                                                   ; // Nome
	OemToAnsi(STR0057)                                                                                                                    ; // Pausa do Servi็o
	COLSIZES 30,40,150,40 SIZE (aPos[1,4] - 6) / 2, 100 OF oFolder:aDialogs[2]                                                            ;
	ON CHANGE FS_DESABILI(aProdut2[oLbProdut2:nAt, 4], aProdut2[oLbProdut2:nAt, 2])                                                       ;
	ON DBLCLICK (If(aProdut2[oLbProdut2:nAt, 1] == "P", .F., (oTimeStatus:lActive := .F., FS_PERINIFIN(aProdut2[oLbProdut2:nAt, 2]),      ;
		FG_TEMPTRA(aProdut2[oLbProdut2:nAt, 2], aPerIniFin[1], aPerIniFin[2], aPerIniFin[3], aPerIniFin[4]), oTimeStatus:lActive := .t.)));
	Font TFont():New("System", 08, 15) PIXEL

oLbProdut2:Align := CONTROL_ALIGN_RIGHT
oLbProdut2:bGotFocus := {|| FS_DESABILI(aProdut2[oLbProdut2:nAt, 4], aProdut2[oLbProdut2:nAt, 2]), oLbProdut2:Refresh() }
Aadd(aProdut2, { " ", " ", " ", " " })

oLbProdut2:SetArray(aProdut2)
oLbProdut2:bLine := { || { If(Empty(aProdut2[oLbProdut2:nAt, 1]), oBBranco, If(aProdut2[oLbProdut2:nAt, 1] == "T", oBVerde, If(aProdut2[oLbProdut2:nAt, 1] == "E", oBVermelho,;
	If(aProdut2[oLbProdut2:nAt, 1] == "A", oBAzul, oBAmarelo)))), aProdut2[oLbProdut2:nAt, 2], aProdut2[oLbProdut2:nAt, 3], aProdut2[oLbProdut2:nAt, 4]} }

&& Prisma
@ 001,1 SCROLLBOX oScroll2 VERTICAL SIZE 182,310 OF oFolder:aDialogs[3] BORDER PIXEL
oScroll2:Align := CONTROL_ALIGN_ALLCLIENT

// Folder 3 //
cQuery := "SELECT SX5.X5_TABELA , SX5.X5_DESCRI , VSN.VSN_CODCOR, "
cQuery += "       VSN.VSN_PRISMA, VOF.VOF_SITBOX "
cQuery += "FROM " + RetSqlName("SX5") + " SX5 "
cQuery += "INNER JOIN " + RetSqlName("VSN") + " VSN ON VSN.VSN_FILIAL = '" + xFilial("VSN") + "' AND VSN.VSN_CODCOR = SX5.X5_CHAVE AND VSN.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("VOF") + " VOF ON VOF.VOF_FILIAL = '" + xFilial("VOF") + "' AND VOF.VOF_CODCOR = VSN.VSN_CODCOR "
cQuery += "  AND VOF.VOF_PRISMA = VSN.VSN_PRISMA AND VOF.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SX5.X5_TABELA = 'CR' AND SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLSX5, .F., .T.)

aAbaTmp[3] := .f.
nSecao     := 4

While !(cSQLSX5)->(Eof())
	If cTabSX5 <> (cSQLSX5)->(X5_TABELA)
		nLinha   := nSecao + 6
		nColuna  := 2
		nAltura  := nLinha + 25
		nLargura := nColuna
	EndIf

	aAbaTmp[3] := .t.

	If (cSQLSX5)->(VOF_SITBOX) == "O"
		cResource := "VERMELHO"
	ElseIf (cSQLSX5)->(VOF_SITBOX) == "P"
		cResource := "AMARELO"
	Else
		cResource := "VERDE"
	EndIf

	If nColuna >= (aPos[1,4] - 70)
		nColuna  := 2
		nLargura := nColuna
		nLinha   := nAltura + 1
		nAltura  := nLinha + 25
	EndIf

	nColuna := nLargura + 3
	nLargura:= nColuna + 24

	&("oCor" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA))) := NIL
	&("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA))) := NIL

	@ nLinha + 1, nColuna to nAltura + 1, nLargura OF oScroll2 PIXEL
	@ nLinha + 3, nColuna + 6 REPOSITORY &("oCor" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA))) NOBORDER SIZE 10,10 OF oScroll2 PIXEL
	&("oCor" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA))):LoadBmp(cResource)

	@ nLinha + 13, nColuna + 2 BUTTON &("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA))) PROMPT (cSQLSX5)->(VSN_PRISMA) OF oScroll2 SIZE 20,11 PIXEL ACTION FS_BOXPRISMA()
	&("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":cReadVar := '" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + "'")
	&("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":bGotFocus := {|| cFocuBox := '" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + "'}" )

	If !((cSQLSX5)->(VOF_SITBOX) $ "O/P")
		&("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":Disable()")
	Else
		Aadd(aVarOnLine[3], { Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)), (cSQLSX5)->(VSN_CODCOR) + (cSQLSX5)->(VSN_PRISMA), (Len(aVarOnLine) == 0) })
	EndIf

	IncProc(OemToAnsi(STR0013)) // Levantando situacao do Prisma

	@ nSecao,001 TO nAltura + 5, aPos[1,4] - 17 LABEL Alltrim((cSQLSX5)->(X5_DESCRI)) OF oScroll1 PIXEL

	nSecao := nAltura + 8

	cTabSX5 := (cSQLSX5)->(X5_TABELA)

	(cSQLSX5)->(dbSkip())
EndDo

(cSQLSX5)->(dbCloseArea())

DbSelectArea("SX5")

// Folder 1 //
@ 02,010 REPOSITORY oVermelho NOBORDER SIZE 10, 10 OF oTPane1BOTTOM PIXEL
oVermelho:LoadBmp("VERMELHO")

@ 03,025 SAY STR0030 OF oTPane1BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Ocupado
@ 02,120 REPOSITORY oAmarelo NOBORDER SIZE 10, 10 OF oTPane1BOTTOM PIXEL
oAmarelo:LoadBmp("AMARELO")

@ 03,135 SAY STR0031 OF oTPane1BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Ocupado e Parado
@ 02,220 REPOSITORY oVerde NOBORDER SIZE 10, 10 OF oTPane1BOTTOM PIXEL
oVerde:LoadBmp("VERDE")

@ 03,235 SAY STR0032 OF oTPane1BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Vazio

// Folder 2 //
@ 03,010 BITMAP oPVerde RESOURCE "BR_VERDE" NOBORDER SIZE 10, 10 OF oTPane2BOTTOM PIXEL
@ 03,020 SAY STR0033 OF oTPane2BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Dentro do Periodo

@ 03,085 BITMAP oPAmarelo RESOURCE "BR_AMARELO" NOBORDER SIZE 10, 10 OF oTPane2BOTTOM PIXEL
@ 03,095 SAY STR0034 OF oTPane2BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Parado

@ 03,160 BITMAP oPVermelho RESOURCE "BR_VERMELHO" NOBORDER SIZE 10, 10 OF oTPane2BOTTOM PIXEL
@ 03,170 SAY STR0035 OF oTPane2BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Tempo Estourado

@ 03,235 BITMAP oPAzul RESOURCE "BR_AZUL" NOBORDER SIZE 10, 10 OF oTPane2BOTTOM PIXEL

@ 03,245 SAY STR0049+Alltrim(Str(GetNewPar("MV_MINATME",15)))+STR0050 OF oTPane2BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // A estourar em:  / Min.

@ 03,335 BUTTON oBtPausa PROMPT STR0058 OF oTPane2BOTTOM SIZE 45,10 PIXEL ACTION (FS_PAUSA()) // Visualizar pausas

// Folder 3 //
@ 02,010 REPOSITORY oVermelho NOBORDER SIZE 10, 10 OF oTPane3BOTTOM PIXEL
oVermelho:LoadBmp("VERMELHO")

@ 03,025 SAY STR0030 OF oTPane3BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Ocupado
@ 02,120 REPOSITORY oAmarelo  NOBORDER SIZE 10, 10 OF oTPane3BOTTOM PIXEL
oAmarelo:LoadBmp("AMARELO")

@ 03,135 SAY STR0031 OF oTPane3BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Ocupado e Parado
@ 02,220 REPOSITORY oVerde NOBORDER SIZE 10, 10 OF oTPane3BOTTOM PIXEL
oVerde:LoadBmp("VERDE")

@ 03,235 SAY STR0032 OF oTPane3BOTTOM SIZE 70,08 PIXEL COLOR CLR_BLACK // Vazio

DEFINE TIMER oTimeStatus INTERVAL (GETMV("MV_TEMPBOX") * 1000) ACTION FS_MDABAOC140() OF oDlgStatus
oTimeStatus:lActive := .t.

If Type("oTime2") # "U"
	DEFINE TIMER oTime2Fec INTERVAL 50000 ACTION FS_FECHAPERAUT() OF oDlgStatus
	oTime2Fec:lActive := .t.
EndIf

ACTIVATE MSDIALOG oDlgStatus ON INIT EnchoiceBar(oDlgStatus, {|| nTecla := 1, oDlgStatus:End()}, {|| nTecla := 1, oDlgStatus:End()},, aBotEnc)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_BARRA  บAutor  ณFabio               บ Data ณ  08/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Barra de rolagem                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_BARRA()
Processa({|| FS_ALTSTATUS( )})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTSTATบAutor  ณFabio               บ Data ณ  05/05/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Box                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ALTSTATUS( )
Local cResource, nHora := 0, aPeriodo := {}
Local aSrvMec   := {}, nPSrvMec := 0
Local nTmp      := 0
Local nHorRest  := 0
Local nCntFor   := 0
Local aSM0      := {}
Local cAliasVO4 := "SQLVO4"
Local lProFil   := VAI->(FieldPos("VAI_PROFIL")) > 0

Local cSQLVOD := "SQLVOD"
Local cSQLVAI := "SQLVAI"
Local cSQLSX5 := "SQLSX5"
Local cQuery  := ""
Local cCodSec := ""
Local cTabSX5 := ""
Local nTemPad := 0

If nTamVON # VON->(RecCount()) .Or. nTamVAI # VAI->(RecCount())
	OFIOC140()
EndIf

//oTime2Status:lActive := .F.
oTimeStatus:lActive  := .F.
//oTime1Status:lActive := .F.

aSM0 := FWArrFilAtu(cEmpAnt, cFilAnt) // Filial Origem (Filial logada)

If oFolder:nOption == 1
	&& Atualiza Box
	ProcRegua(Len(aVarOnLine[1]))

	cQuery := "SELECT VON.VON_NUMBOX, VOF.VOF_SITBOX "
	cQuery += "FROM " + RetSqlName("VOD") + " VOD "
	cQuery += "INNER JOIN " + RetSqlName("VON") + " VON ON VON.VON_FILIAL = '" + xFilial("VON") + "' AND VON.VON_CODSEC = VOD.VOD_CODSEC AND VON.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("VOF") + " VOF ON VOF.VOF_FILIAL = '" + xFilial("VOF") + "' AND VOF.VOF_NUMBOX = VON.VON_NUMBOX AND VOF.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VOD.VOD_FILIAL = '" + xFilial("VOD") + "' AND VOD.D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVOD, .F., .T.)

	aAbaTmp[1]    := .f.
	aVarOnLine[1] := {}

	While !(cSQLVOD)->(Eof())
		aAbaTmp[1] := .t.

		If (cSQLVOD)->(VOF_SITBOX) == "O"
			cResource := "VERMELHO"
		ElseIf (cSQLVOD)->(VOF_SITBOX) == "P"
			cResource := "AMARELO"
		Else
			cResource := "VERDE"
		EndIf

		&("oCor" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":LoadBmp('" + cResource + "')")
		&("oCor" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":Refresh()")

		If !((cSQLVOD)->(VOF_SITBOX) $ "O/P")
			&("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":Disable()")
		Else
			&("oObs" + Alltrim((cSQLVOD)->(VON_NUMBOX)) + ":Enable()")
			Aadd(aVarOnLine[1], { Alltrim((cSQLVOD)->(VON_NUMBOX)), (cSQLVOD)->(VON_NUMBOX), (Len(aVarOnLine) == 0) })
		EndIf

		IncProc(OemToAnsi(STR0048 )) // Levantando situacao do Box

		(cSQLVOD)->(dbSkip())
	EndDo

	(cSQLVOD)->(dbCloseArea())

	DbSelectArea("VOD")

	If Type("oObs" + cFocuBox) # "U"
		&("oObs" + cFocuBox + ":SetFocus()")
	EndIf

	oTimeStatus:lActive  := .t.
	//oTime1Status:lActive := .t.
ElseIf oFolder:nOption == 2
	&& Atualiza Mecanicos
	ProcRegua(VAI->(RecCount()))

	cQuery := "SELECT VAI.VAI_CODTEC, VAI.VAI_NOMTEC "
	cQuery += "FROM " + RetSqlName("VAI") + " VAI "
	cQuery += "WHERE VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_FUNPRO = '1' "
	cQuery += "  AND (VAI.VAI_DATDEM IS NULL OR VAI.VAI_DATDEM = ' ' OR VAI.VAI_DATDEM > '" + DToS(Date()) + "') "
	cQuery += "  AND ( "

	If lProFil
		cQuery += "  (VAI.VAI_PROFIL = '1') OR (VAI.VAI_PROFIL IS NULL OR VAI.VAI_PROFIL = ' ' OR VAI.VAI_PROFIL = '0') AND "
	EndIf

	cQuery += "      (VAI.VAI_FILPRO IS NULL OR VAI.VAI_FILPRO = ' ' OR VAI.VAI_FILPRO = '" + aSM0[2] + "')) "
	cQuery += "  AND VAI.D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVAI, .F., .T.)

	aAbaTmp[2]  := .f.
	aProdutivos := {}
	aProdut2    := {}

	While !(cSQLVAI)->(Eof())
		aAbaTmp[2] := .t.

		nHora := Val(Substr(time(), 1, 2) + Substr(time(), 4, 2))
		//         aPeriodo := FG_TEMPTRA(VAI->VAI_CODTEC,Date(),0,Date(),nHora,"A",.f.,"O/E")
		aPeriodo := FG_TEMPTRA((cSQLVAI)->(VAI_CODTEC), Date(), 0, Date(), nHora, "A", .f.)

		FS_PERINIFIN((cSQLVAI)->(VAI_CODTEC))

		aPeriodo := FG_TEMPTRA((cSQLVAI)->(VAI_CODTEC), aPerIniFin[1], aPerIniFin[2], aPerIniFin[3], aPerIniFin[4], "A", .f.)

		If !(aPeriodo[Len(aPeriodo), 5] $ "F/A/ ")
			aSrvMec := {}
			cStatus := aPeriodo[Len(aPeriodo), 5]

			For nTmp := 1 To Len(aPeriodo)
				&& Levanta tempo estourado
				If aPeriodo[nTmp, 5] $ "O/E" .Or. (!Empty(aPeriodo[nTmp, 1]) .And. Empty(aPeriodo[nTmp, 3]))
					If Len(aSrvMec) == 0 .Or. ((nPSrvMec := Ascan(aSrvMec, {|x| x[1] + x[2] == aPeriodo[nTmp, 7] + aPeriodo[nTmp, 8]})) == 0)
						cQuery := "SELECT VO4.VO4_TEMPAD "
						cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
						cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NUMOSV = '" + aPeriodo[nTmp, 7] + "' "
						cQuery += "  AND VO4.VO4_CODSER = '" + aPeriodo[nTmp, 8] + "' AND VO4.D_E_L_E_T_ = ' ' "
						nTemPad := FM_SQL(cQuery)

						Aadd(aSrvMec, { aPeriodo[nTmp, 7], aPeriodo[nTmp, 8], nTemPad, 0 })

						nPSrvMec := Len(aSrvMec)
					EndIf

					If (!Empty(aPeriodo[nTmp, 1]) .And. Empty(aPeriodo[nTmp, 3]))
						//							aSrvMec[nPSrvMec,4] += aPeriodo[nTmp,11]
						aSrvMec[nPSrvMec, 4] += aPeriodo[nTmp, 12]
					Else
						aSrvMec[nPSrvMec, 4] += aPeriodo[nTmp, 6]
					EndIf

					&& Checa se o mecanico esta com tempo ocupado
					If (!Empty(aPeriodo[nTmp, 1]) .And. Empty(aPeriodo[nTmp, 3]))
						If !Empty(aSrvMec[nPSrvMec, 3]) .And. aSrvMec[nPSrvMec, 4] > aSrvMec[nPSrvMec, 3]
							cStatus := "X"
						Else
							nHorRest := (aSrvMec[nPSrvMec, 3] - aSrvMec[nPSrvMec, 4]) // tempo padrao/tempo corrido
							If nHorRest < GetNewPar("MV_MINATME", 15) // parametro par informar quantidade de minutos para aviso atraso mecanico
								cStatus := "A" // altera status para atrasar.
							Else
								cStatus := "O" // dentro do periodo
							EndIf
						EndIf

						Exit
					EndIf
				EndIf
			Next

			Aadd(aProdutivos, Array(4))

			If cStatus $ "X"
				aProdutivos[Len(aProdutivos), 1] := "E" // Tempo estourado
			ElseIf cStatus $ "O/E"
				aProdutivos[Len(aProdutivos), 1] := "T" // Tempo dentro do periodo
			ElseIf cStatus $ "A"
				aProdutivos[Len(aProdutivos), 1] := "A" // Status informa que mecanico pode atrasar
			Else
				aProdutivos[Len(aProdutivos), 1] := "P" // Parado
			EndIf

			aProdutivos[Len(aProdutivos), 2] := (cSQLVAI)->(VAI_CODTEC)
			aProdutivos[Len(aProdutivos), 3] := (cSQLVAI)->(VAI_NOMTEC)

			cQuery := "SELECT VO4.VO4_MPAUSA, VO4.VO4_DATFIN, VO4.VO4_HORFIN "
			cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
			cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_CODPRO = '" + (cSQLVAI)->(VAI_CODTEC) + "' AND VO4.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY VO4.VO4_DATFIN DESC, VO4.VO4_HORFIN DESC "
			dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO4, .F., .T.)

			If (cAliasVO4)->(Eof())
				aProdutivos[Len(aProdutivos), 4] := STR0065 // Nใo
			ElseIf Empty((cAliasVO4)->(VO4_DATFIN)) .Or. Empty((cAliasVO4)->(VO4_MPAUSA))
				aProdutivos[Len(aProdutivos), 4] := STR0065 // Nใo
			Else
				aProdutivos[Len(aProdutivos), 4] := STR0064 // Sim
			EndIf

			(cAliasVO4)->(dbCloseArea())

			DbSelectArea("VO4")
		EndIf

		IncProc(OemToAnsi(STR0014)) // Levantando situacao do Produtivo

		(cSQLVAI)->(dbSkip())
	EndDo

	(cSQLVAI)->(dbCloseArea())

	DbSelectArea("VAI")

	nIni := Round(Len(aProdutivos) / 2,0) + 1
	nFim := Len(aProdutivos)

	For nCntFor := nIni to nFim
		aAdd(aProdut2, aProdutivos[nIni])
		aDel(aProdutivos, nIni)
		aSize(aProdutivos, Len(aProdutivos) - 1)
	Next

	If Len(aProdut2) == 0
		Aadd(aProdut2, { " ", " ", " ", " " })
	EndIf

	If Len(aProdutivos) == 0
		Aadd(aProdutivos, { " ", " ", " ", " " })
	EndIf

	oLbProdut:SetArray(aProdutivos)
	oLbProdut:bLine := { || { If(Empty(aProdutivos[oLbProdut:nAt, 1]), oBBranco, If(aProdutivos[oLbProdut:nAt, 1] == "T", oBVerde, If(aProdutivos[oLbProdut:nAt, 1] == "E", oBVermelho,;
		If(aProdutivos[oLbProdut:nAt, 1] == "A", oBAzul, oBAmarelo)))), aProdutivos[oLbProdut:nAt, 2], aProdutivos[oLbProdut:nAt, 3], aProdutivos[oLbProdut:nAt, 4] } }

	oLbProdut2:SetArray(aProdut2)
	oLbProdut2:bLine := { || { If(Empty(aProdut2[oLbProdut2:nAt, 1]), oBBranco, If(aProdut2[oLbProdut2:nAt, 1] == "T", oBVerde, If(aProdut2[oLbProdut2:nAt, 1] == "E", oBVermelho,;
		If(aProdut2[oLbProdut2:nAt, 1] == "A", oBAzul, oBAmarelo)))), aProdut2[oLbProdut2:nAt, 2], aProdut2[oLbProdut2:nAt, 3], aProdut2[oLbProdut2:nAt, 4] } }

	//   oTime2Status:lActive := .t.
	If Len(aProdutivos) > 0
		FS_DESABILI(aProdutivos[oLbProdut:nAt, 1])
	EndIf

	oTimeStatus:lActive  := .t.
	oLbProdut2:Refresh()
	oLbProdut:SetFocus()
	oLbProdut:Refresh()
Else
	&& Atualiza Box
	ProcRegua(Len(aVarOnLine[3]))

	cQuery := "SELECT SX5.X5_TABELA , SX5.X5_DESCRI , VSN.VSN_CODCOR, "
	cQuery += "       VSN.VSN_PRISMA, VOF.VOF_SITBOX "
	cQuery += "FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += "INNER JOIN " + RetSqlName("VSN") + " VSN ON VSN.VSN_FILIAL = '" + xFilial("VSN") + "' AND VSN.VSN_CODCOR = SX5.X5_CHAVE AND VSN.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("VOF") + " VOF ON VOF.VOF_FILIAL = '" + xFilial("VOF") + "' AND VOF.VOF_CODCOR = VSN.VSN_CODCOR "
	cQuery += "  AND VOF.VOF_PRISMA = VSN.VSN_PRISMA AND VOF.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SX5.X5_TABELA = 'CR' AND SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLSX5, .F., .T.)

	aAbaTmp[3]    := .f.
	aVarOnLine[3] := {}

	While !(cSQLSX5)->(Eof())
		aAbaTmp[3] := .t.

		If (cSQLSX5)->(VOF_SITBOX) == "O"
			cResource := "VERMELHO"
		ElseIf (cSQLSX5)->(VOF_SITBOX) == "P"
			cResource := "AMARELO"
		Else
			cResource := "VERDE"
		EndIf

		&("oCor" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":LoadBmp('" + cResource + "')")
		&("oCor" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":Refresh()")

		If !((cSQLSX5)->(VOF_SITBOX) $ "O/P")
			&("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":Disable()")
		Else
			&("oObs" + Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)) + ":Enable()")
			Aadd(aVarOnLine[3], { Alltrim((cSQLSX5)->(VSN_CODCOR)) + Alltrim((cSQLSX5)->(VSN_PRISMA)), (cSQLSX5)->(VSN_CODCOR) + (cSQLSX5)->(VSN_PRISMA), (Len(aVarOnLine) == 0) })
		EndIf

		IncProc(OemToAnsi(STR0013)) // Levantando situacao do Prisma

		(cSQLSX5)->(dbSkip())
	EndDo

	(cSQLSX5)->(dbCloseArea())

	DbSelectArea("SX5")

	If Type("oObs" + cFocuPri) # "U"
		&("oObs" + cFocuPri + ":SetFocus()")
	EndIf

	oTimeStatus:lActive  := .t.
	//oTime1Status:lActive := .t.
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_BOXPRISบAutor  ณFabio               บ Data ณ  05/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra Box Individual                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_BOXPRISMA(lAutomatic)
Local nPosVar   := 0, nPosReg := 0, nTempoTra := 0, cQuebra,ni := 0
Local oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO" )
Local cBoxPrisma, cCorPrisma, lLocalPrisma := .f., nTecla := 0

Local cSQLVO1 := "SQLVO1"
Local cQuery  := ""

Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Private aCpoEnchoice := {}
Private aServicos    := {}

cBoxPrisma := ReadVar()

If Empty(cBoxPrisma)
	// Folder 1 //
	If oFolder:nOption == 1
		cBoxPrisma := cFocuBox
	EndIf

	// Folder 3 //
	If oFolder:nOption == 3
		cBoxPrisma := cFocuPri
	EndIf
EndIf

cCorPrisma := cBoxPrisma
lAutomatic := If(lAutomatic # NIL, lAutomatic, .f.)

If !lAutomatic
	oTimeStatus:lActive  := .F.
EndIf
//oTime1Status:lActive := .F.

If Len(aVarOnLine[oFolder:nOption]) == 0
	Return(".t.")
EndIf

// Folder 1 //
If oFolder:nOption == 1
	If lAutomatic
		nPosVar := Ascan(aVarOnLine[1], { |x| x[1] == cBoxPrisma }) + 1
		If nPosVar > Len(aVarOnLine[1])
			nPosVar := 1
		EndIf

		cBoxPrisma := aVarOnLine[1, nPosVar, 2]
	EndIf

	DbSelectArea("VOF")
	DbSetOrder(1)
	If !DbSeek(xFilial("VOF") + cBoxPrisma) .Or. VOF->VOF_SITBOX == "D"
		Help("  ", 1, "BOXDISPONI")
		Return
	EndIf
EndIf

// Folder 3 //
If oFolder:nOption == 3
	nPosVar := Ascan(aVarOnLine[3], { |x| x[1] == cBoxPrisma })

	If lAutomatic
		nPosVar += 1
	EndIf

	If nPosVar <= 0 .Or. nPosVar > Len(aVarOnLine[3])
		nPosVar := 1
	EndIf

	cCorPrisma := aVarOnLine[3, nPosVar, 2]
	cBoxPrisma := aVarOnLine[3, nPosVar, 1]

	DbSelectArea("VOF")
	DbSetOrder(3)
	DbSeek(xFilial("VOF") + cCorPrisma)
EndIf

// Box da Oficina //
cQuery := "SELECT VO1.VO1_CODCOR, VO1.VO1_PRISMA, VO4.VO4_CODCOR, VO4.VO4_PRISMA, VO4.VO4_TIPTEM, VO4.VO4_CODSER, VO4.VO4_CODPRO, VO4.VO4_SERINT, "
cQuery += "       VO4.VO4_TEMPAD, VO4.VO4_DATINI, VO4.VO4_DATFIN, VO4.VO4_TEMTRA, VO4.VO4_HORINI, VO6.VO6_DESSER, VAI.VAI_NOMTEC "
cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
cQuery += "INNER JOIN " + RetSqlName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV "
cQuery += "  AND VO4.VO4_DATDIS = ' ' AND VO4.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("VO6") + " VO6 ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "' AND VO6.VO6_SERINT = VO4.VO4_SERINT AND VO6.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = VO4.VO4_CODPRO AND VAI.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK.VOK_TIPSER = VO4.VO4_TIPSER "
cQuery += "  AND VOK.VOK_INCMOB IN('1','3','4') AND VOK.D_E_L_E_T_ = ' ' " // 1-Mao-de-Obra / 3-Valor livre c/Base na Tabela / 4-Retorno de Servico
cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_STATUS = 'A' "
cQuery += "  AND VO1.VO1_NUMOSV = '" + VOF->VOF_NUMOSV + "' AND VO1.D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO1, .F., .T.)

cQuebra := ""

If !(cSQLVO1)->(Eof()) .And. (cSQLVO1)->(VO1_CODCOR) + (cSQLVO1)->(VO1_PRISMA) == cBoxPrisma
	lLocalPrisma := .t.
EndIf

While !(cSQLVO1)->(Eof())
	If (oFolder:nOption == 1 .Or. lLocalPrisma .Or. (cSQLVO1)->(VO4_CODCOR) + (cSQLVO1)->(VO4_PRISMA) == cCorPrisma)
		If (cSQLVO1)->(VO4_TIPTEM) + (cSQLVO1)->(VO4_CODSER) # cQuebra .Or. (Len(aServicos) # 0 .And.;
			Ascan(aServicos, {|x| x[1] + x[3] == (cSQLVO1)->(VO4_CODSER) + (cSQLVO1)->(VO4_CODPRO) }) == 0)

			Aadd(aServicos, { (cSQLVO1)->(VO4_CODSER), (cSQLVO1)->(VO6_DESSER),;
				(cSQLVO1)->(VO4_CODPRO), (cSQLVO1)->(VAI_NOMTEC), 0, 0, 0, (cSQLVO1)->(VO4_TEMPAD), .F. })

			cQuebra := (cSQLVO1)->(VO4_TIPTEM) + (cSQLVO1)->(VO4_CODSER)
		EndIf

		If !Empty((cSQLVO1)->(VO4_CODPRO)) .And. !Empty((cSQLVO1)->(VO4_DATINI))
			nPosReg   := Ascan(aServicos, {|x| x[1] == (cSQLVO1)->(VO4_CODSER) })
			nTempoTra := 0

			If !Empty((cSQLVO1)->(VO4_DATINI)) .And. !Empty((cSQLVO1)->(VO4_DATFIN))
				nTempoTra := (cSQLVO1)->(VO4_TEMTRA)
			Else
				nHora := Val(Substr(time(), 1, 2) + Substr(time(), 4, 2))

				////////////////////////////////////////////////////////////////////
				// RETIRADA A CHAMADA DA FUNCAO FG_TEMPTRA    // MOTIVO: LENTIDAO //
				// VOLTAR CHAMADA QUANDO FOR REFEITA A FUNCAO // ANDRE  /  RUBENS //
				////////////////////////////////////////////////////////////////////
				/*
				nTempoTra := FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,Date(),nHora,"N",.f.,"O/E")
				*/
				If !(aServicos[nPosReg, 9])
					aServicos[nPosReg, 9] := .t.
				EndIf
			EndIf

			nTempoTra := nTempoTra + aServicos[nPosReg, 5]

			Do While nPosReg > 0 .And. nPosReg <= Len(aServicos) .And. aServicos[nPosReg, 1] == (cSQLVO1)->(VO4_CODSER)
				aServicos[nPosReg, 5] := nTempoTra
				aServicos[nPosReg, 6] := (cSQLVO1)->(VO4_TEMPAD)

				If aServicos[nPosReg, 5] > aServicos[nPosReg, 6]
					aServicos[nPosReg, 7] := aServicos[nPosReg, 5] - aServicos[nPosReg, 6]
				EndIf

				nPosReg++
			EndDo
		EndIf
	EndIf

	(cSQLVO1)->(dbSkip())
EndDo

(cSQLVO1)->(dbCloseArea())

DbSelectArea("VO1")
DbSetOrder(2)
DbSeek(xFilial("VO1") + "A" + VOF->VOF_NUMOSV)

If Len(aServicos) == 0
	Aadd(aServicos, { " ", " ", " ", " ", 0, 0, 0, 0, .F. })
EndIf

aObjects := {}
AAdd(aObjects, { 000, 100, .T., .F. }) // VO1
AAdd(aObjects, { 000, 100, .T., .T. }) // ListBox
AAdd(aObjects, { 000, 021, .T., .F. }) // Legenda

aInfo := {aSizeHalf[1], aSizeHalf[2], aSizeHalf[3], aSizeHalf[4], 2, 2}
aPos  := MsObjSize (aInfo, aObjects, .F.)

Inclui := .f.
Altera := .f.
Visual := .t.

VV1->(DbSetOrder(1))
VV1->(DbSeek(xFilial("VV1") + VO1->VO1_CHAINT))
DbSelectArea("VO1")

DbSelectArea("SX3")
DbSetOrder(1)

dbseek("VO1")
While !Eof() .and. (X3_arquivo == "VO1")
	If X3USO(x3_usado) .and. cNivel >= x3_nivel;
		.and. !( Alltrim(x3_campo) $ "VO1_DATSAI/VO1_HORSAI/VO1_STATUS/VO1_TEMGAR/VO1_TEMLIB/VO1_MECREQ/VO1_TIPSOL/VO1_SITGAR/VO1_OBSMEM/VO1_CODMAR/VO1_EXPGAR/VO1_MOTIVO/VO1_DESMOT/VO1_TEMFEC/VO1_TEMCAN" )
		aadd(aCpoEnchoice, x3_campo)
		&("M->" + Alltrim(x3_campo)) := CriaVar(x3_campo)
	EndIf

	dbskip()
Enddo

DEFINE MSDIALOG oDlgBox FROM aSizeHalf[7],000 TO aSizeHalf[6],aSizeHalf[5] TITLE cTitulo + " - " + STR0024 + " - " + cCorPrisma OF oMainWnd PIXEL // Box da oficina

oEnchVO1 := MSMGet():New("VO1", 0, 2,                                                                                           ;
	/*aCRA*/, /*cLetra*/, /*cTexto*/, aCpoEnchoice, {aPos[1,1], aPos[1,2], aPos[1,3], aPos[1,4]}, aCpoEnchoice, 3 /* nModelo*/ ,;
	/*nColMens*/, /*cMensagem*/, /*cTudoOk*/, oDlgBox, .f. /*lF3*/, .f. /*lMemoria*/, .f. /*lColumn*/,                          ;
	""/*caTela*/, .t. /*lNoFolder */, .f. /*lProperty */)
@ aPos[2,1],aPos[2,2] TO aPos[2,3],aPos[2,4] LABEL STR0045 OF oDlgBox PIXEL // Servicos

@ aPos[2,1] + 07,aPos[2,2] + 01 LISTBOX oLbServicos FIELDS HEADER OemToAnsi(""),;
	OemToAnsi(STR0022),                                                         ; // Servico
	OemToAnsi(STR0023),                                                         ; // Descricao
	OemToAnsi(STR0005),                                                         ; // Levantando situacao do Box
	OemToAnsi(STR0015),                                                         ; // Prisma
	OemToAnsi(STR0052),                                                         ; // Tp Pad
	OemToAnsi(STR0027)                                                          ; // Tp Estourado
	COLSIZES 10,40,60,30,60,30,30 SIZE aPos[2,4] - 4,aPos[2,3] - aPos[1,3] - 10 OF oDlgBox PIXEL

oLbServicos:SetArray(aServicos)
oLbServicos:bLine := { || { If(aServicos[oLbServicos:nAt, 9], If(!Empty(aServicos[oLbServicos:nAt, 7]), oVermelho, oVerde), oAmarelo),;
	aServicos[oLbServicos:nAt, 1],                                                                                                    ;
	aServicos[oLbServicos:nAt, 2],                                                                                                    ;
	aServicos[oLbServicos:nAt, 3],                                                                                                    ;
	aServicos[oLbServicos:nAt, 4],                                                                                                    ;
	Transform(aServicos[oLbServicos:nAt, 8], "@R 99:99"),                                                                             ;
	Transform(aServicos[oLbServicos:nAt, 7], "@R 999:99") }}

@ aPos[3,1] + 1,005 BITMAP oVVerde RESOURCE "BR_VERDE" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1] + 1,015 SAY STR0053 OF oDlgBox SIZE 52,08 PIXEL // Em andamento

@ aPos[3,1] + 1,065 BITMAP oVAmarelo RESOURCE "BR_AMARELO" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1] + 1,075 SAY STR0054 OF oDlgBox SIZE 52,08 PIXEL // Parado

@ aPos[3,1] + 1,125 BITMAP oVVermelho RESOURCE "BR_VERMELHO" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1] + 1,135 SAY STR0055 OF oDlgBox SIZE 52,08 PIXEL // Estourado

If lAutomatic
	DEFINE TIMER oTime1Box INTERVAL (GETMV("MV_TEMPBOX") * 100) ACTION oDlgBox:End() OF oDlgBox
	oTime1Box:lActive := .t.
EndIf

ACTIVATE MSDIALOG oDlgBox ON INIT EnchoiceBar(oDlgBox, {|| nTecla := 1, oDlgBox:End()}, {|| nTecla := 1, oDlgBox:End()})
If !lAutomatic
	oTimeStatus:lActive  := .T.
EndIf
//oTime1Status:lActive := .T.

If lAutomatic .And. lFechaStatus .And. nTecla == 1
	oDlgStatus:End()
EndIf
Return("oObs" + cBoxPrisma + ":SetFocus()")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MDABAOCบAutor  ณFabio               บ Data ณ  09/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณContrala mudanca de aba automatico                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_MDABAOC140()
Local nOptOld := oFolder:nOption

/*
If oFolder:nOption == 1
If aAbaTmp[2]
oFolder:nOption := 2
ElseIf aAbaTmp[3]
oFolder:nOption := 3
EndIf
ElseIf oFolder:nOption == 2
If aAbaTmp[3]
oFolder:nOption := 3
ElseIf aAbaTmp[1]
oFolder:nOption := 1
EndIf
ElseIf oFolder:nOption == 3
If aAbaTmp[1]
oFolder:nOption := 1
ElseIf aAbaTmp[2]
oFolder:nOption := 2
EndIf
EndIf
*/
If nOptOld == oFolder:nOption
	Processa({|| FS_ALTSTATUS( )})
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PERINIFบAutor  ณFabio               บ Data ณ  12/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLevanta periodo inicial e final                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PERINIFIN(cCodTec)
Local cSQLVO4_1 := "SQLVO4_1"
Local cSQLVO4_2 := "SQLVO4_2"
Local cQuery    := ""

aPerIniFin := {}

&& Levanta periodo do ultimo servico trabalhado
Aadd(aPerIniFin, Date())
Aadd(aPerIniFin, FS_TTHR(Val(Substr(time(), 1, 2) + Substr(time(), 4, 2)), 0))
Aadd(aPerIniFin, Date())
Aadd(aPerIniFin, FS_TTHR(Val(Substr(time(), 1, 2) + Substr(time(), 4, 2)), 1))

// Retorna data e hora final do ๚ltimo Servi็o trabalhado
cQuery := "SELECT VO4.VO4_DATFIN, VO4.VO4_HORFIN, VO4.VO4_CODSER, VO4.VO4_NOSNUM "
cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_CODPRO = '" + cCodTec + "' "
cQuery += "  AND (VO4.VO4_DATINI >= '" + DToS(Date() - 30) + "' AND VO4.VO4_DATINI <= '" + DToS(Date()) + "') "
cQuery += "  AND (VO4.VO4_DATINI IS NOT NULL OR VO4.VO4_DATINI <> ' ') "
cQuery += "  AND ((VO4.VO4_DATFIN IS NOT NULL OR VO4.VO4_DATFIN <> ' ') OR (VO4.VO4_DATDIS IS NOT NULL OR VO4.VO4_DATDIS <> ' ') "
cQuery += "    OR (VO4.VO4_DATFEC IS NOT NULL OR VO4.VO4_DATFEC <> ' ') OR (VO4.VO4_DATCAN IS NOT NULL OR VO4.VO4_DATCAN <> ' ')) "
cQuery += "  AND VO4.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY VO4.R_E_C_N_O_ DESC "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO4_1, .F., .T.)

If !(cSQLVO4_1)->(Eof())
	aPerIniFin[3] := SToD((cSQLVO4_1)->(VO4_DATFIN))
	aPerIniFin[4] := FS_TTHR((cSQLVO4_1)->(VO4_HORFIN), 1)

	If Empty((cSQLVO4_1)->(VO4_DATFIN))
		aPerIniFin[3] := Date()
		aPerIniFin[4] := Val(Substr(time(), 1, 2) + Substr(time(), 4, 2))
	EndIf

	// Retorna data e hora inicial do ๚ltimo Servi็o trabalhado
	cQuery := "SELECT VO4.VO4_DATINI, VO4.VO4_HORINI "
	cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
	cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_CODPRO = '" + cCodTec + "' "
	cQuery += "  AND VO4.VO4_DATINI >= '" + DToS(Date() - 30) + "' AND VO4.VO4_CODSER = '" + (cSQLVO4_1)->(VO4_CODSER) + "' "
	cQuery += "  AND VO4.VO4_NOSNUM = '" + (cSQLVO4_1)->(VO4_NOSNUM) + "' AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VO4.R_E_C_N_O_ ASC "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO4_2, .F., .T.)

	If !(cSQLVO4_2)->(Eof())
		aPerIniFin[1] := SToD((cSQLVO4_2)->(VO4_DATINI))
		aPerIniFin[2] := FS_TTHR((cSQLVO4_2)->(VO4_HORINI), -1)
	EndIf

	(cSQLVO4_2)->(dbCloseArea())
EndIf

(cSQLVO4_1)->(dbCloseArea())

DbSelectArea("VO4")
Return(aPerIniFin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TTHR   บAutor  ณFabio               บ Data ณ  09/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transforma em hora centezimal para soma.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TTHR(nHr, nNroSoma)
&& Transforma em hora centezimal para soma
nNroSoma := (nNroSoma / 0.6)

nHr := Val(Substr(StrZero(nHr, 4), 1, 2) + StrZero(Val(Substr(StrZero(nHr, 4), 3, 2)) / 0.6, 2)) + nNroSoma

&& Transforma em hora normal novamente
nHr := Val(Substr(StrZero(nHr, 4), 1, 2) + StrZero(Val(Substr(StrZero(nHr, 4), 3, 2)) * 0.6, 2))
Return(nHr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PAUSA บAutor  ณThiago               บ Data ณ  15/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pausa do servico.						                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PAUSA()
Local cAliasVO4 := "SQLVO4"
Local cQuery    := ""

cQuery := "SELECT VO4.VO4_NUMOSV, VO4.VO4_DATFIN, VO4.VO4_HORFIN, VO4.VO4_MPAUSA, VS0.VS0_DESMOT "
cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
cQuery += "INNER JOIN " + RetSQLName("VS0") + " VS0 ON VS0.VS0_FILIAL = '" + xFilial("VS0") + "' "
cQuery += "  AND VS0.VS0_TIPASS = '000006' AND VS0.VS0_CODMOT = VO4.VO4_MPAUSA AND VS0.D_E_L_E_T_=' ' "
cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_CODPRO = '" + cProdut + "' "
cQuery += "  AND VO4.VO4_MPAUSA <> '      ' AND VO4.D_E_L_E_T_=' ' "
cQuery += "ORDER BY VO4.VO4_DATFIN DESC, VO4.VO4_HORFIN DESC "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasVO4, .T., .T.)

aVetor := {{ "", "", "", "" }}

Do While !(cAliasVO4)->(Eof())
	If Len(aVetor) == 1 .and. Empty(aVetor[1, 1])
		aVetor := {}
	EndIf
	Aadd(aVetor, { (cAliasVO4)->(VO4_NUMOSV), SToD((cAliasVO4)->(VO4_DATFIN)), (cAliasVO4)->(VO4_HORFIN), (cAliasVO4)->(VS0_DESMOT) })

	dbSelectArea(cAliasVO4)

	(cAliasVO4)->(dbSkip())
EndDo

(cAliasVO4)->(dbCloseArea())

DEFINE MSDIALOG oDlg2 TITLE OemtoAnsi(STR0059) FROM  01,20 TO 27,126 OF oMainWnd // Pausas do produtivo

@ 01,.1 LISTBOX oLbox2 FIELDS HEADER OemToAnsi(STR0060),;
	OemToAnsi(STR0061),                                 ;
	OemtoAnsi(STR0062),                                 ;
	OemToAnsi(STR0063)                                  ;
	COLSIZES 50,50,50,200 SIZE 420,170 OF Odlg2 PIXEL // Nro.O.S. / Data Final / Hora Final / Motivo

oLbox2:SetArray(aVetor)
oLbox2:bLine := { || { aVetor[oLbox2:nAt, 01],    ;
	Transform(aVetor[oLbox2:nAt, 02], "@D"),      ;
	Transform(aVetor[oLbox2:nAt, 03], "@E 99:99"),;
	aVetor[oLbox2:nAt, 04]}}

DEFINE SBUTTON FROM 175,330 TYPE 2 ACTION (nOpca := 0, oDlg2:End()) ENABLE OF oDlg2

ACTIVATE MSDIALOG oDlg2 CENTER
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DESABILIบ Autor ณ Thiago บ			    Data ณ  14/05/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ DESABILITA BOTAO.							              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DESABILI(cProdutivo, cCodPro)
If(cProdutivo == STR0064) // Sim
	oBtPausa:lVisible := .t.
Else
	oBtPausa:lVisible := .f.
EndIf

cProdut := cCodPro
Return()