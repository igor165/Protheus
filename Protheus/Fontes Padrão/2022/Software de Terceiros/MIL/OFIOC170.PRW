// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "OFIOC170.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC170 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 08/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta (BALC-Orcamento/OFIC-OS/VEIC-Atendimento) pela NF ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC170()
Private aOS     := {}
Private aRR     := {}
Private lRR     := .f.
Private lOFI    := .f.
Private cOS     := ""
Private nOk     := 0
Private cTipo   := ""
Private cNF     := space(9)
Private cSerie  := space(3)
Private cCabImp := ""
Private cPrefix := ""
Private cMsg1   := ""
Private cMsg2   := ""
Private cMsg3   := ""
Private cMsg4   := ""
Private cMsg5   := ""
Private cMsg6   := ""
Private cTipoNF := "T"
Processa( {|| FS_OFIOC170() } )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OFIOC170 ³ Autor ³ Andre Luis Almeida  ³Data ³ 08/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta (BALC-Orcamento/OFIC-OS/VEIC-Atendimento) pela NF ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OFIOC170()

Aadd(aOS,{ " " , " " , " " } )
DEFINE MSDIALOG oDlg1 FROM 000,000 TO 025,078 TITLE STR0031 OF oMainWnd

@ 005,003 SAY STR0032 SIZE 20,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 003,011 MSGET oNF VAR cNF PICTURE "@!" VALID FS_ZERAOS() F3 "SF2" SIZE 23,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 003,052 MSGET oSerie VAR cSerie PICTURE "@!" VALID FS_ZERAOS() SIZE 10,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 015,003 BUTTON oAtualizar  PROMPT OemToAnsi(STR0033) OF oDlg1 SIZE 70,10 PIXEL  ACTION Processa( {|| FS_VAL_CNFOS() } )
@ 027,003 LISTBOX oLbx1 FIELDS HEADER OemToAnsi(" "),OemToAnsi(" "),OemToAnsi(" ") COLSIZES 40,150,80 SIZE 303,144 OF oDlg1 PIXEL
// Vazio //
oLbx1:SetArray(aOS)
oLbx1:bLine := { || {aOS[oLbx1:nAt,1],;
aOS[oLbx1:nAt,2],;
aOS[oLbx1:nAt,3]}}
// Oficina //
@ 027,003 LISTBOX oLbx2 FIELDS HEADER OemToAnsi(STR0039),OemToAnsi(STR0040),OemToAnsi(STR0041) COLSIZES 40,150,80 SIZE 303,144 OF oDlg1 PIXEL
oLbx2:SetArray(aOS)
oLbx2:bLine := { || {aOS[oLbx2:nAt,1],;
aOS[oLbx2:nAt,2],;
aOS[oLbx2:nAt,3]}}
// Balcao //
@ 027,003 LISTBOX oLbx3 FIELDS HEADER OemToAnsi(STR0044),OemToAnsi(STR0045),OemToAnsi(STR0046) COLSIZES 40,150,80 SIZE 303,144 OF oDlg1 PIXEL
oLbx3:SetArray(aOS)
oLbx3:bLine := { || {aOS[oLbx3:nAt,1],;
aOS[oLbx3:nAt,2],;
aOS[oLbx3:nAt,3]}}
// Veiculos //
@ 027,003 LISTBOX oLbx4 FIELDS HEADER OemToAnsi(STR0049),OemToAnsi(STR0050),OemToAnsi(STR0051) COLSIZES 40,150,80 SIZE 303,144 OF oDlg1 PIXEL
oLbx4:SetArray(aOS)
oLbx4:bLine := { || {aOS[oLbx4:nAt,1],;
aOS[oLbx4:nAt,2],;
aOS[oLbx4:nAt,3]}}

oLbx2:lVisible := .f.
oLbx3:lVisible := .f.
oLbx4:lVisible := .f.

@ 177,009 SAY oMsg1 VAR cMsg1 SIZE 150,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 010,078 SAY oMsg2 VAR cMsg2 SIZE 250,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 005,078 SAY oMsg3 VAR cMsg3 SIZE 250,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 015,078 SAY oMsg4 VAR cMsg4 SIZE 250,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 173,078 SAY oMsg5 VAR cMsg5 SIZE 250,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 181,078 SAY oMsg6 VAR cMsg6 SIZE 250,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 001,075 TO 024,307 LABEL "" OF oDlg1 PIXEL  // caixa
@ 172,003 TO 187,061 LABEL "" OF oDlg1 PIXEL  // caixa

@ 175,165 BUTTON oConsultar PROMPT STR0082 OF oDlg1 SIZE 43,10 PIXEL ACTION FS_VISUAL()     //Consultar
@ 175,213 BUTTON oImprimir PROMPT STR0083 OF oDlg1 SIZE 43,10 PIXEL ACTION (oDlg1:End(),FS_IMP_OC170()) WHEN (cCabImp#"") //Imprimir
@ 175,261 BUTTON oSair PROMPT STR0084 OF oDlg1 SIZE 43,10 PIXEL ACTION oDlg1:End()  //<< SAIR >>
ACTIVATE MSDIALOG oDlg1 CENTER

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VISUAL   ³ Autor ³ Andre Luis Almeida  ³Data ³ 08/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza ³												   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VISUAL()
Local ni := 0
Local lNF := .f.
Local lOS := .f.
Local lRR := .f.
Do Case
	Case lOFI .and. lRR
		ni := Aviso(STR0085,STR0086+CHR(13)+CHR(10)+STR0087+CHR(13)+CHR(10)+STR0088,{"NF","OS","RR"}) //Visualizar ? # - NF # - Ordem de Servico # - RR
		If ni == 1
			lNF := .t.
		ElseIf ni == 2
			lOS := .t.
		ElseIf ni == 3
			lRR := .t.
		EndIf
	Case lOFI
		ni := Aviso(STR0085,STR0086+CHR(13)+CHR(10)+STR0087,{"NF","OS"}) //Visualizar ? # - NF # - Ordem de Servico
		If ni == 1
			lNF := .t.
		ElseIf ni == 2
			lOS := .t.
		EndIf
	Case lRR
		ni := Aviso(STR0085,STR0086+CHR(13)+CHR(10)+STR0088,{"NF","RR"}) //Visualizar ?  #  - NF # - RR
		If ni == 1
			lNF := .t.
		ElseIf ni == 2
			lRR := .t.
		EndIf
	OtherWise
		lNF := .t.
EndCase
Do Case
	Case lNF
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek( xFilial("SF2") + cNF + cSerie )
			ALTERA := .f.
			INCLUI := .f.
			ImpNotaPS(0,2,2)
		EndIf
	Case lOS
		FS_OC060(aOS[oLbx1:nAt,1])
	Case lRR
		FS_RROS(aOS[oLbx1:nAt,1])
EndCase
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ZERAOS   ³ Autor ³ Andre Luis Almeida  ³Data ³ 08/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa OS³												   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ZERAOS
cCabImp := ""
aOS  := {}
Aadd(aOS,{ " " , " " , " " } )
lRR  := .f.
lOFI := .f.
oLbx1:lVisible := .t.
oLbx2:lVisible := .f.
oLbx3:lVisible := .f.
oLbx4:lVisible := .f.
oLbx1:SetArray(aOS)
oLbx1:bLine := { || {aOS[oLbx1:nAt,1],;
aOS[oLbx1:nAt,2],;
aOS[oLbx1:nAt,3]}}
oLbx1:Refresh()
cMsg1 := space(23)
cMsg2 := space(250)
cMsg3 := space(250)
cMsg4 := space(250)
cMsg5 := space(250)
cMsg6 := space(250)
If !Empty(cNF)
	DbSelectArea("SF2")
	DbSetOrder(1)
	If !DbSeek( xFilial("SF2") + cNF + If(!Empty(cSerie),cSerie,SF2->F2_SERIE) )
		DbSeek( xFilial("SF2") + cNF )
	EndIf
	cSerie := SF2->F2_SERIE
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VAL_CNFOS ³ Autor ³ Andre Luis Almeida ³Data ³ 08/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida OS.³												   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_CNFOS()
Local lRet := .f.
Local cTip := "1"
lRR  := .f.
lOFI := .f.
DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek( xFilial("SF2") + cNF + cSerie )
	lRet  := .t.
	aOS := {}
	cPrefix := SF2->F2_PREFORI
	If cPrefix == GetNewPar("MV_PREFOFI","OFI")
		cTip := "2"
		lOFI := .t.
		cCabImp := STR0034
		cMsg1 := STR0035
		cMsg5 := STR0036+space(5)+STR0038+Transform(SF2->F2_VALBRUT-SF2->F2_BASEISS,"@E 9999,999.99")
		cMsg6 := STR0037+space(5)+STR0038+Transform(SF2->F2_BASEISS,"@E 9999,999.99")
		DbSelectArea("VOO")
		DbSetOrder(4)
		DbSeek( xFilial("VOO") + cNF + Alltrim(cSerie) )
		While !Eof() .and. (xFilial("VOO")+cNF+Alltrim(cSerie)) == (VOO->VOO_FILIAL+VOO->VOO_NUMNFI+Alltrim(VOO->VOO_SERNFI))
			DbSelectArea("VOI")
			DbSetOrder(1)
			DbSeek( xFilial("VOI") + VOO->VOO_TIPTEM )
			If VOI->VOI_SITTPO == "2" //Garantia
				lRR := .t.
			EndIf
			DbSelectArea("VO1")
			DbSetOrder(1)
			DbSeek( xFilial("VO1") + VOO->VOO_NUMOSV )
			DbSelectArea("VV1")
			DbSetOrder(1)
			DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
			Aadd(aOS,{ VOO->VOO_NUMOSV+"  -  "+VOO->VOO_TIPTEM+"  "+VV1->VV1_CODMAR , Transform(Alltrim(VO1->VO1_PLAVEI),VV1->(X3PICTURE("VV1_PLAVEI")))+"  /  "+Alltrim(VV1->VV1_CODMAR)+"  "+Alltrim(VV1->VV1_MODVEI)+"  "+Alltrim(VV2->VV2_DESMOD) , VV1->VV1_NUMMOT+"  /  "+Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+"  "+left(SA1->A1_NOME,30) } )
			DbSelectArea("VOO")
			DbSkip()
		EndDo
	ElseIf cPrefix == GetNewPar("MV_PREFBAL","BAL")
		cTip := "3"
		cCabImp := STR0042
		cMsg1 := STR0043
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )
		While !Eof() .and. (xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) == (SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SD2->D2_COD )
			Aadd(aOS,{ SB1->B1_GRUPO , Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC , Transform(SD2->D2_QUANT,"@E 9,999")+"   "+Transform(SD2->D2_TOTAL,"@E 999,999,999.99") } )
			DbSelectArea("SD2")
			DbSkip()
		EndDo
	ElseIf cPrefix == GetNewPar("MV_PREFVEI","VEI")
		cTip := "4"
		cCabImp := STR0047
		cMsg1 := STR0048
		DbSelectArea("VV0")
		DbSetOrder(4)
		DbSeek( xFilial("VV0") + SF2->F2_DOC + SF2->F2_SERIE )
		DbSelectArea("VV1")
		DbSetOrder(8)
		DbSeek( xFilial("VV1") + VV0->VV0_NUMTRA 	)
		DbSelectArea("VVC")
		DbSetOrder(1)
		DbSeek(xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
		Aadd(aOS,{ Transform(Alltrim(VV1->VV1_PLAVEI),VV1->(X3PICTURE("VV1_PLAVEI"))) , Alltrim(VV1->VV1_CHASSI)+"  /  "+Alltrim(VV1->VV1_CODMAR)+"  "+Alltrim(VV1->VV1_MODVEI)+"  "+Alltrim(VV2->VV2_DESMOD) , Transform(Alltrim(VV1->VV1_FABMOD),"@R 9999/9999") +" / "+VVC->VVC_DESCRI } )
	EndIf
	If	len(aOS) <= 0
		cCabImp := ""
		Aadd(aOS,{ " " , " " , " " } )
		lRR  := .f.
		lOFI := .f.
	EndIf
	oLbx1:lVisible := .f.
	oLbx2:lVisible := .f.
	oLbx3:lVisible := .f.
	oLbx4:lVisible := .f.
	Do Case
		Case cTip == "1"
			oLbx1:lVisible := .t.
			oLbx1:SetArray(aOS)
			oLbx1:bLine := { || {aOS[oLbx1:nAt,1],;
			aOS[oLbx1:nAt,2],;
			aOS[oLbx1:nAt,3]}}
			oLbx1:Refresh()
		Case cTip == "2"
			oLbx2:lVisible := .t.
			oLbx2:SetArray(aOS)
			oLbx2:bLine := { || {aOS[oLbx2:nAt,1],;
			aOS[oLbx2:nAt,2],;
			aOS[oLbx2:nAt,3]}}
			oLbx2:Refresh()
		Case cTip == "3"
			oLbx3:lVisible := .t.
			oLbx3:SetArray(aOS)
			oLbx3:bLine := { || {aOS[oLbx3:nAt,1],;
			aOS[oLbx3:nAt,2],;
			aOS[oLbx3:nAt,3]}}
			oLbx3:Refresh()
		Case cTip == "4"
			oLbx4:lVisible := .t.
			oLbx4:SetArray(aOS)
			oLbx4:bLine := { || {aOS[oLbx4:nAt,1],;
			aOS[oLbx4:nAt,2],;
			aOS[oLbx4:nAt,3]}}
			oLbx4:Refresh()
	EndCase
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
	DbSelectArea( "SE4" )
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SF2->F2_COND )
	cMsg2 := space(250)
	cMsg3 := (STR0052+left(SA1->A1_NOME+space(35),35)+If(Len(Alltrim(SA1->A1_CGC))>12,STR0053,STR0054)+Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")))
	cMsg4 := (STR0055+Alltrim(cPrefix)+STR0056+Transform(SF2->F2_EMISSAO,"@D")+STR0057+Transform(SF2->F2_VALBRUT,"@E 9999,999.99")+STR0058+SF2->F2_COND+"-"+SE4->E4_DESCRI)
Else
	cCabImp := ""
	lRR  := .f.
	lOFI := .f.
	cMsg1 := space(23)
	cMsg2 := left(STR0059+space(250),250)
	cMsg3 := space(250)
	cMsg4 := space(250)
	oLbx1:Refresh()
	oNF:SetFocus()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RROS ³  Autor ³  Andre Luis Almeida ³ Data ³  08/05/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida OS.³												   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RROS(cOS)
If left(cOS,1) == "="
	MsgAlert(STR0061,STR0060)
Else
	aRR := {}
	DbSelectArea( "VG8" )
	DbSetOrder(1)
	DbSeek( xFilial("VG8") + substr(cOS,20,3) + substr(cOS,1,8) )
	While !Eof() .and. (xFilial("VG8")+substr(cOS,20,3)+substr(cOS,1,8)) == (VG8->VG8_FILIAL+VG8->VG8_CODMAR+VG8->VG8_NUMOSV)
		If !Empty(VG8->VG8_NUMRRC)
			Aadd(aRR,{VG8->VG8_ANORRC+"  "+VG8->VG8_NUMRRC,Transform(VG8->VG8_DATTRA,"@D"),Transform(VG8->VG8_VALITE,"@E 999,999,999.99"),Transform(VG8->VG8_VALSER,"@E 999,999,999.99"),VG8->VG8_SITRRC+"  "+VG8->VG8_DESSIT,Transform(VG8->VG8_DATRET,"@D"),Transform(VG8->VG8_DATCRE,"@D"),Transform(VG8->VG8_ITEPGT,"@E 999,999,999.99"),Transform(VG8->VG8_SERPGT,"@E 999,999,999.99"),Transform(VG8->VG8_DATEST,"@D"),Transform(VG8->VG8_ITEEST,"@E 999,999,999.99"),Transform(VG8->VG8_SEREST,"@E 999,999,999.99")})
		EndIf
		DbSelectArea("VG8")
		DbSkip()
	EndDo
	If	len(aRR) # 0
		aSort(aRR,1,,{|x,y| x[1] > y[1] })
		DEFINE MSDIALOG oDlg2 FROM 000,000 TO 012,060 TITLE (STR0062+cOS) OF oMainWnd
		@ 003,003 LISTBOX oLbx2 FIELDS HEADER OemToAnsi(STR0063),OemToAnsi(STR0064),OemToAnsi(STR0065),OemToAnsi(STR0066),OemToAnsi(STR0067),OemToAnsi(STR0068),OemToAnsi(STR0069),OemToAnsi(STR0070),OemToAnsi(STR0071),OemToAnsi(STR0072),OemToAnsi(STR0073),OemToAnsi(STR0074) COLSIZES 45,30,45,45,80,30,30,45,45,30,45,45 SIZE 232,070 OF oDlg2 PIXEL
		oLbx2:SetArray(aRR)
		oLbx2:bLine := { || {aRR[oLbx2:nAt,1],;
		aRR[oLbx2:nAt,2],;
		aRR[oLbx2:nAt,3],;
		aRR[oLbx2:nAt,4],;
		aRR[oLbx2:nAt,5],;
		aRR[oLbx2:nAt,6],;
		aRR[oLbx2:nAt,7],;
		aRR[oLbx2:nAt,8],;
		aRR[oLbx2:nAt,9],;
		aRR[oLbx2:nAt,10],;
		aRR[oLbx2:nAt,11],;
		aRR[oLbx2:nAt,12]}}
		DEFINE SBUTTON FROM 077,199 TYPE 1 ACTION oDlg2:End() ENABLE OF oDlg2
		ACTIVATE MSDIALOG oDlg2 CENTER
	Else
		MsgAlert(STR0075+cOS,STR0060)
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OC060 ³  Autor ³  Andre Luis Almeida ³ Data ³ 08/05/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama consulta da OS.³									   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OC060(cOS)
Private aRotina := { { STR0002 ,"axPesqui", 0 , 1},;   && Pesquisar
{ STR0003 ,"OC060"   , 0 , 2}}    && Visualizar
Private cCadastro := OemToAnsi(STR0001)
Private cCampo, nOpc := 2 , inclui := .f.
If left(cOS,1) == "="
	MsgAlert(STR0076,STR0060)
Else
	cOS := left(cOS,8)
	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(xFilial("VO1") + cOS )
	OC060("VO1",Recno(),2)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IMP_OC170 ³ Autor ³ Andre Luis Almeida ³Data ³08/05/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao da O.S.³										   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMP_OC170()
Local cDesc1	 := ""
Local cDesc2	 := ""
Local cDesc3	 := ""
Local cAlias	 := "SA1"
Local ni        := 0
Private nLin 	 := 1
Private aReturn := { STR0077 , 1 , STR0078 , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= If(cPrefix#GetNewPar("MV_PREFOFI","OFI"),"P","M")           // P/M/G
Private Limite  := If(cPrefix#GetNewPar("MV_PREFOFI","OFI"),80,132)            // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := STR0079 + cNF + "-" + cSerie + " ( " + cPrefix + " )"
Private cNomProg:= "OFIOC170"
Private cNomeRel:= "OFIOC170"
Private nLastKey:= 0
Private cabec1  := cCabImp
Private cabec2  := ""
Private nCaracter:=If(cPrefix#GetNewPar("MV_PREFOFI","OFI"),18,15)
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "SA1"
Private Li      := If(cPrefix#GetNewPar("MV_PREFOFI","OFI"),80,132)
Private m_Pag   := 1
Private lAbortPrint := .f.
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
ProcRegua( Len(aOS) )
For ni:=1 to Len(aOS)
	IncProc( OemToAnsi( STR0079 + cNF + "-" + cSerie + " ( " + cPrefix + " )" ) )
	If nLin >= 62
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
	EndIf
	If cPrefix == GetNewPar("MV_PREFOFI","OFI")
		@ nLin++ , 00 psay left(aOS[ni,1],17)+left(aOS[ni,2]+space(57),57)+" "+left(aOS[ni,3]+space(57),57)
		DbSelectArea( "VG8" )
		DbSetOrder(1)
		If DbSeek( xFilial("VG8") + substr(aOS[ni,1],20,3) + substr(aOS[ni,1],1,8) )
			@ nLin++ , 04 psay STR0080
			While !Eof() .and. (xFilial("VG8")+substr(aOS[ni,1],20,3)+substr(aOS[ni,1],1,8)) == (VG8->VG8_FILIAL+VG8->VG8_CODMAR+VG8->VG8_NUMOSV)
				If !Empty(VG8->VG8_NUMRRC)
					If nLin >= 62
						nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
						@ nLin++ , 00 psay STR0081 + substr(aOS[ni,1],1,8)
						@ nLin++ , 04 psay STR0080
					EndIf
					@ nLin++ , 08 psay VG8->VG8_ANORRC+" "+VG8->VG8_NUMRRC+" "+Transform(VG8->VG8_DATTRA,"@D")+Transform(VG8->VG8_VALITE,"@E 999,999.99")+Transform(VG8->VG8_VALSER,"@E 999,999.99")+" "+VG8->VG8_SITRRC+" "+left(VG8->VG8_DESSIT,12)+" "+Transform(VG8->VG8_DATRET,"@D")+" "+Transform(VG8->VG8_DATCRE,"@D")+Transform(VG8->VG8_ITEPGT,"@E 999,999.99")+Transform(VG8->VG8_SERPGT,"@E 999,999.99")+" "+Transform(VG8->VG8_DATEST,"@D")+Transform(VG8->VG8_ITEEST,"@E 999,999.99")+Transform(VG8->VG8_SEREST,"@E 999,999.99")
				EndIf
				DbSelectArea("VG8")
				DbSkip()
			EndDo
		EndIf
		nLin++
	ElseIf cPrefix == GetNewPar("MV_PREFBAL","BAL")
		@ nLin++ , 00 psay aOS[ni,1]+" "+left(aOS[ni,2]+space(52),52)+" "+aOS[ni,3]
	ElseIf cPrefix == GetNewPar("MV_PREFVEI","VEI")
		@ nLin++ , 00 psay aOS[ni,1]+" "+left(aOS[ni,2]+space(50),50)+" "+left(aOS[ni,3],20)
	EndIf
Next
Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()
