// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#Include "fileio.ch"
#Include "OFIOC200.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC200 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Frota do Cliente                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC200
Private aFrota  := {}
Private nTotal  := 0
Private cCodCli := space(TamSX3("A1_COD")[1])
Private cLojCli := space(TamSX3("A1_LOJA")[1])
Private cNomCli := space(TamSX3("A1_NOME")[1])
Private cDesCli := space(250)
Private cTitulo := STR0001
Private lA1_IBGE:= If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Aadd(aFrota,{ "" , "" , "" , "" , "" , "" , "" , "" } )
Processa( {|| FS_OFIOC200() } )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OFIOC200³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Frota do Cliente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OFIOC200()
DEFINE MSDIALOG oFrota FROM 000,000 TO 025,078 TITLE cTitulo OF oMainWnd
@ 005,005 SAY STR0002 SIZE 20,08 OF oFrota PIXEL COLOR CLR_BLUE
@ 003,025 MSGET oCodCli VAR cCodCli PICTURE PesqPict("SA1","A1_COD") VALID FS_VALCLI("CLI") F3 "SA1" SIZE 20,08 OF oFrota PIXEL COLOR CLR_HBLUE
@ 003,059 MSGET oLojCli VAR cLojCli PICTURE PesqPict("SA1","A1_LOJA") VALID FS_VALCLI("LOJ") SIZE 10,08 OF oFrota PIXEL COLOR CLR_HBLUE
@ 006,090 SAY cNomCli SIZE 250,08 OF oFrota PIXEL COLOR CLR_BLUE
@ 014,090 SAY cDesCli SIZE 250,08 OF oFrota PIXEL COLOR CLR_BLUE
@ 015,010 BUTTON oAtualizar  PROMPT OemToAnsi(STR0003) OF oFrota SIZE 65,10 PIXEL  ACTION Processa( {|| FS_PESQUISA() } )
@ 027,003 LISTBOX oLbxFrota FIELDS HEADER OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009) COLSIZES 65,65,50,30,30,30 SIZE 303,144 OF oFrota PIXEL
oLbxFrota:SetArray(aFrota)
oLbxFrota:bLine := { || {aFrota[oLbxFrota:nAt,1],;
aFrota[oLbxFrota:nAt,2],;
aFrota[oLbxFrota:nAt,3],;
aFrota[oLbxFrota:nAt,4],;
aFrota[oLbxFrota:nAt,5],;
aFrota[oLbxFrota:nAt,6]}}
@ 001,088 TO 024,307 LABEL "" OF oFrota PIXEL  // caixa
@ 177,008 SAY (STR0010+str(nTotal,9)+STR0011) SIZE 180,08 OF oFrota PIXEL COLOR CLR_BLUE
@ 172,003 TO 187,230 LABEL "" OF oFrota PIXEL  // caixa
DEFINE SBUTTON FROM 175,238 TYPE 15 ACTION (FS_FICHA(aFrota[oLbxFrota:nAt,1],aFrota[oLbxFrota:nAt,2],aFrota[oLbxFrota:nAt,8])) ENABLE OF oFrota
DEFINE SBUTTON FROM 175,272 TYPE 1 ACTION oFrota:End() ENABLE OF oFrota
ACTIVATE MSDIALOG oFrota CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALCLI  ³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALCLI(cTipo)
lRet    := .t.
cNomCli := space(TamSX3("A1_NOME")[1])
cDesCli := space(250)
aFrota  := {}
nTotal  := 0
Aadd(aFrota,{ "" , "" , "" , "" , "" , "" , "" , "" } )
oLbxFrota:SetArray(aFrota)
oLbxFrota:bLine := { || {aFrota[oLbxFrota:nAt,1],;
aFrota[oLbxFrota:nAt,2],;
aFrota[oLbxFrota:nAt,3],;
aFrota[oLbxFrota:nAt,4],;
aFrota[oLbxFrota:nAt,5],;
aFrota[oLbxFrota:nAt,6]}}
oLbxFrota:Refresh()
DbSelectArea("SA1")
DbSetOrder(1)
if Empty( cCodCli + cLojCli)
	return .t.
endif
If DbSeek( xFilial("SA1") + cCodCli + cLojCli )
	cNomCli := SA1->A1_NOME
	cDesCli := If(Len(Alltrim(SA1->A1_CGC))>12,STR0012,STR0013)+Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")) +" "+ STR0014
	If lA1_IBGE
		DbSelectArea("VAM")
		DbSetOrder(1)
		DbSeek(xFilial("VAM")+SA1->A1_IBGE)
		cDesCli += " ("+ Alltrim(VAM->VAM_DDD) +") "+If(Substr(SA1->A1_TEL,3,1)==" ",Substr(SA1->A1_TEL,3,12),SA1->A1_TEL)
	Else
		cDesCli += " "+SA1->A1_TEL
	EndIf
Else
	If cTipo == "LOJ"
		MsgAlert(STR0016,STR0015)
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQUISA³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Botao pesquisar                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQUISA()
aFrota := {}
nTotal := 0
DbSelectArea("VV1")
DbSetOrder(5)
If DbSeek( xFilial("VV1") + cCodCli + cLojCli )
	While !Eof() .and. VV1->VV1_FILIAL == xFilial("VV1") .and. VV1->VV1_PROATU+VV1->VV1_LJPATU == cCodCli+cLojCli
		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
		DbSelectArea("VVB")
		DbSetOrder(1)
		DbSeek( xFilial("VVB") + VV2->VV2_CATVEI )
		aAdd(aFrota,{VV1->VV1_CHASSI,VV1->VV1_CODMAR+" "+left(VV2->VV2_DESMOD,30),VVB->VVB_DESCRI,Transform(VV1->VV1_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI"))),Transform(VV1->VV1_FABMOD,"@R 9999/9999"),Transform(VV1->VV1_PRIREV,"@D"),VV1->VV1_CHAINT,VV1->VV1_MODVEI})
		nTotal++
		DbSelectArea("VV1")
		DbSkip()
	EndDo
	If nTotal == 0
		Aadd(aFrota,{ "" , "" , "" , "" , "" , "" , "" , ""} )
	Else
		aSort(aFrota,1,,{|x,y| x[3]+x[2]+x[1] < y[3]+y[2]+y[1] })
	EndIf
	oLbxFrota:SetArray(aFrota)
	oLbxFrota:bLine := { || {aFrota[oLbxFrota:nAt,1],;
	aFrota[oLbxFrota:nAt,2],;
	aFrota[oLbxFrota:nAt,3],;
	aFrota[oLbxFrota:nAt,4],;
	aFrota[oLbxFrota:nAt,5],;
	aFrota[oLbxFrota:nAt,6]}}
	oLbxFrota:Refresh()
Else
	aadd(aFrota,{"","","","","","","",""})
	MsgAlert(STR0017,STR0018)
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FICHA   ³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Historico de passagens                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FICHA(cChaInt,cMarMod,cModVei) // Chama: OFIOR150 - Historico de passagens
Local cPerg := "OFR150"+Space(len(SX1->X1_GRUPO)-6)
DbSelectArea("SX1")
DbSetOrder(1)
if DbSeek(cPerg+"03")
	RecLock("SX1",.f.)
	X1_CNT01 := "  /  /  " // Data Inicial
	MsUnlock()
endif
if DbSeek(cPerg+"04")
	RecLock("SX1",.f.)
	X1_CNT01 := Transform(dDataBase,"@D") // Data Final
	MsUnlock()
endif
if DbSeek(cPerg+"05")
	RecLock("SX1",.f.)
	X1_CNT01 := cCodCli // Codigo do Cliente
	MsUnlock()
endif
if DbSeek(cPerg+"06")
	RecLock("SX1",.f.)
	X1_CNT01 := cLojCli // Loja do Cliente
	MsUnlock()
endif
if DbSeek(cPerg+"07")
	RecLock("SX1",.f.)
	X1_CNT01 := left(cMarMod,3) // Marca
	MsUnlock()
endif
if DbSeek(cPerg+"08")
	RecLock("SX1",.f.)
	X1_CNT01 := cModVei // substr(cMarMod,5,30) // Modelo
	MsUnlock()
endif
if DbSeek(cPerg+"09")
	RecLock("SX1",.f.)
	X1_CNT01 := cChaInt // Chassi Interno Veiculo
	MsUnlock()
endif
if DbSeek(cPerg+"10")
	RecLock("SX1",.f.)
	X1_PRESEL := 1   // Mostra Valor de Pecas
	MsUnlock()
endif
if DbSeek(cPerg+"11")
	RecLock("SX1",.f.)
	X1_PRESEL := 1   // Mostra Valor de Servicos
	MsUnlock()
endif
if DbSeek(cPerg+"12")
	RecLock("SX1",.f.)
	X1_PRESEL := 1   // Mostra Observacao da OS
	MsUnlock()
endif
Pergunte(cPerg,.f.)
OFIOR150()
Return
