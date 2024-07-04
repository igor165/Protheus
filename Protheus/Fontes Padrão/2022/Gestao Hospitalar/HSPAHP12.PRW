#INCLUDE "HSPAHP12.ch"
#include "protheus.ch"
#include "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHP12 บ Autor ณGilson da Silva     บ Data ณ  05/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Geracao de Contas para o Faturamento                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHP12()
 Local aVParam  := {}
 Local aCposMB  := {}
 Local lExNRGGLO:= .T.		//HS_ExisDic({{"C", "GCZ_NRGGLO"}}, .F.)
 Local aCores	:= {{"GCZ->GCZ_STATUS == '0'",	"BR_BRANCO"  }, ; //0=Controle de Contas
					{"GCZ->GCZ_STATUS == '1' " + IIf(lExNRGGLO, " .AND. !EMPTY(GCZ->GCZ_NRGGLO)", ""),IIf(lExNRGGLO,	"BR_PINK","BR_VERDE")   },;//8=Reapresenta SUS
                    {"GCZ->GCZ_STATUS == '1'",	"BR_VERDE"	 }, ; //1=Faturamento
	 				{"GCZ->GCZ_STATUS == '2'",	"BR_AMARELO" }, ; //2=Faturado
		 			{"GCZ->GCZ_STATUS == '3'",	"BR_VERMELHO"}, ; //3=Lote Atribuido
		 			{"GCZ->GCZ_STATUS == '4'",	"BR_MARROM"  }, ; //4-Gerado Faturas
		 			{"GCZ->GCZ_STATUS == '5'",	"BR_AZUL"    }, ; //5=Associado Extr.Conv.
		 			{"GCZ->GCZ_STATUS == '6'",	"BR_PRETO"   }, ; //6=Liquidado
		 			{"GCZ->GCZ_STATUS == '7'",	"BR_CINZA"   },; ////7=Quitado
		 			{"GCZ->GCZ_STATUS == '9'",	"BR_LARANJA" }}//Repasse Particular
		 			//{"GCZ->GCZ_STATUS == '1' .AND. !EMPTY(GCZ->GCZ_NRGGLO)",	"BR_PINK"   }}   //8=Reapresenta SUS

 Private oMB
 Private bKeyF12 := SetKey(VK_F12, {|| HS_FILHP12()})
 Private bKeyF4  := SetKey(VK_F4 , {|| HS_MarkF4()})
 Private __aMarkBrow := {}
 Private __cFilLote  := ""
 Private cPerg        := PADR("HSP12A", Len(SX1->X1_GRUPO))
 Private lMarkALL	:= .T.

 Private cCadastro  := OemToAnsi(STR0001) //"Filtro"
 Private cTitulo    := OemToAnsi(STR0002) //"Geracao de Contas para o Faturamento"
 Private cFilGuia   := ""
 Private cCodConv   := ""
 Private cPlaIni    := ""
 Private cPlaFin    := ""
 Private cGuiaIni   := ""
 Private cGuiaFin   := ""
 Private cGuiaSeqI  := ""
 Private cGuiaSeqF  := ""
 Private cCodLoc    := ""
 Private dDtAteIni  := Ctod("  /  /  ")
 Private dDtAteFin  := Ctod("  /  /  ")
 Private nTpAtend   := 0
 Private cTpGuia    := ""
 Private nStatus    := 0
 Private nNroGuias  := 0
 Private dDtLimite  := Ctod("  /  /  ")
 Private cFilP12    := ""
 Private cLocCont   := AllTrim(GetMv("MV_LOCCONT"))
 Private cGATCodCon := ""  //Utilizada na funcao de filtro da GAT (HS_FilLote)
 Private cGP0CodCon := ""

 Private aRotina    := MenuDef()

 Private cMV_AteSus := GetMv("MV_ATESUS",, "N")
 Private __cCodBPA  := ""
 Private __cCodPAC  := ""
 Private __cCodAIH  := ""

 Private cMarca := GetMark()
 Private cLocReab := GetMv("MV_LOCREAB",,"")

 Private cRetSxb := ""
 Private cRetCrm := ""

 
	// Verifica se o parametro MV_ATESUS esta setado para SIM, ou seja, o Hospital atende o Plano SUS
 If cMV_AteSus == "S"
  aVParam := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
  If !HS_VMVSUS(@aVParam)
	  Return(Nil)
	 Else
   __cCodBPA  := aVparam[2][2]
   __cCodPAC  := aVparam[3][2]
   __cCodAIH  := aVparam[4][2]
  EndIf
	EndIf

 If !Pergunte(cPerg,.T.)
	 Return()
 EndIf

 cFilGuia  := mv_par01
 cCodConv  := mv_par02
 cPlaIni   := mv_par03
 cPlaFin   := mv_par04
 cGuiaIni  := mv_par05
 cGuiaFin  := mv_par06
 cGuiaSeqI := mv_par07
 cGuiaSeqF := mv_par08
 cCodLoc   := mv_par09
 dDtAteIni := mv_par10
 dDtAteFin := mv_par11
 nTpAtend  := mv_par12
 cTpGuia   := mv_par13
 nStatus   := mv_par14
 nNroGuias := IIF(Type("mv_par15") <> "U", mv_par15, 0)

 If Empty(cCodConv)  //Obrigatorio informar o convenio
 	MSGSTOP(STR0010, STR0011) //"Codigo do Convenio nao foi informado"###"corretamente, favor, informa-lo ! "
 	Return(.F.)
 EndIf

 FS_Filtro()  //Monta o filtro

 aAdd(aCposMB, { "GCZ_IDMARC",, "", "@BMP" })
 aAdd(aCposMB, { HS_CfgSx3("GCZ_NRSEQG")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_NRSEQG")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_NRSEQG")[SX3->(FieldPos("X3_PICTURE"))] })
 aAdd(aCposMB, { HS_CfgSx3("GCZ_NRLOTE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_NRLOTE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_NRLOTE")[SX3->(FieldPos("X3_PICTURE"))] })
 aAdd(aCposMB, { HS_CfgSx3("GCZ_FILFAT")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_FILFAT")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_FILFAT")[SX3->(FieldPos("X3_PICTURE"))] })
 aAdd(aCposMB, { HS_CfgSx3("GCZ_REGATE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_REGATE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_REGATE")[SX3->(FieldPos("X3_PICTURE"))] })
 aAdd(aCposMB, { HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_PICTURE"))] })

 DbSelectArea("SX3")
 DbSetOrder(1) //X3_ARQUIVO + X3_ORDEM
 DbSeek("GCZ")
 While !Eof() .And. SX3->X3_ARQUIVO == "GCZ"
  If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. SX3->X3_CONTEXT <> "V" .And. ;
     aScan(aCposMB, {| aVet | SX3->X3_CAMPO == aVet[1]}) == 0
   aAdd(aCposMB, { SX3->X3_CAMPO,, SX3->X3_TITULO, SX3->X3_PICTURE })
  EndIf

  DbSkip()
 End

 DBSelectArea("GCZ")
 DBSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS

 HS_MMarkB(@__aMarkBrow, cFilP12, .F., nNroGuias)
 HS_MarkGCZ(__aMarkBrow)
 GCZ->(DbClearFil())
 MarkBrowse("GCZ", "GCZ_IDMARC",, aCposMB, .F., cMarca,"BRHSPAHA80(.F.,cFilP12)"/*"HS_MMarkB(@__aMarkBrow, cFilP12, .T., nNroGuias)"*/,,,,, {|| oMB := GetMarkBrow(), oMB:bMark := {|| HS_BMark(@__aMarkBrow)} }, cFilP12, .T., aCores)

 HS_MMarkB(@__aMarkBrow, "", .T.)
 DbClearFilter()
 SetKey(VK_F12, bKeyF12)
 SetKey(VK_F4 , bKeyF4 )
Return(nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_HP12Rev(nOrdemGcz, cChaveGcz, cWhileGcz, lRevaLote)
Local nItemRev := 0, nOpcRev := 0, oDlgRev
Local oDatIni, dDatIni := dDataBase, oDatFin, dDatFin := dDataBase
Local oPlaOld, cPlaOld := Space(Len(GCM->GCM_CODPLA)), oNPlaOld, cNPlaOld := Space(20)
Local oPlaNew, cPlaNew := Space(Len(GCM->GCM_CODPLA)), oNPlaNew, cNPlaNew := Space(20)
Local oRevMat, lRevMat := .T., oRevMed, lRevMed := .T., oRevRes, lRevRes := .T.
Local oRevTxS, lRevTxS := .T.
Local oRevTax, lRevTax := .T., oRevDia, lRevDia := .T., oRevPro, lRevPro := .T.
Local oUltPrc, lUltPrc := .F., lRedFil := .F.
Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}, aPGDs := {}

Default nOrdemGcz := 1
Default lRevaLote := .F.

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf




DEFINE MSDIALOG oDlgRev TITLE STR0082 From aSize[ 7 ], 000 To 310,420	Of oMainWnd Pixel //"Op็๕es para revaloriza็ใo"
@ aPobjs[1,1] + 5 /*017*/, 005 Say STR0083 Of oDlgRev Pixel //"Data Inicial"
@ aPobjs[1,1] + 3/*015*/, 035 MSGet oDatIni Var dDatIni Picture "@D" Of oDlgRev Pixel

@ aPobjs[1,1] + 5/*017*/, 085 Say STR0084 Of oDlgRev Pixel //"Data Final"
@ aPobjs[1,1] + 3/*015*/, 115 MSGet oDatFin Var dDatFin Picture "@D" Of oDlgRev Pixel

@ aPobjs[1,1] + 18 /*030*/, 005 CheckBox oRevMat Var lRevMat Prompt STR0025 Size 50, 10 Of oDlgRev PIXEL //"Materiais"
@ aPobjs[1,1] + 18 /*030*/, 065 CheckBox oRevMed Var lRevMed Prompt STR0026 Size 50, 10 Of oDlgRev PIXEL //"Medicamentos"
@ aPobjs[1,1] + 18 /*030*/, 125 CheckBox oRevRes Var lRevRes Prompt STR0085 Size 50, 10 Of oDlgRev PIXEL //"Res/Frigobar"

@ aPobjs[1,1] + 33 /*045*/, 005 CheckBox oRevTax Var lRevTax Prompt STR0086 Size 50, 10 Of oDlgRev PIXEL //"Taxas"
@ aPobjs[1,1] + 33 /*045*/, 065 CheckBox oRevDia Var lRevDia Prompt STR0087 Size 50, 10 Of oDlgRev PIXEL //"Diarias"
@ aPobjs[1,1] + 33 /*045*/, 125 CheckBox oRevPro Var lRevPro Prompt STR0028 Size 50, 10 Of oDlgRev PIXEL //"Procedimentos"
@ aPobjs[1,1] + 48  /*060*/, 005 CheckBox oRevTxS Var lRevTxS Prompt STR0222 Size 50, 10 Of oDlgRev PIXEL //"Taxa de Servi็o"

@ aPobjs[1,1] + 63 /*075*/, 005 CheckBox oUltPrc Var lUltPrc Prompt STR0164 Size 150, 10 Of oDlgRev PIXEL //"Considera data base para calculo da vig๊ncia"

@ aPobjs[1,1] + 78 /*090*/, 005 CheckBox oUltPrc Var lRedFil Prompt STR0193 Size 150, 10 Of oDlgRev PIXEL  //"Redefine Filial de Faturamento"

@ aPobjs[1,1] + 95 /*107*/, 005 Say STR0088 Of oDlgRev Pixel //"Troca plano"
@ aPobjs[1,1] + 93 /*105*/, 035 MSGet oPlaOld  Var cPlaOld  Valid FS_VldPla(cPlaOld, oNPlaOld, @cNPlaOld) F3 "GCM" Picture "@!" Of oDlgRev Pixel
@ aPobjs[1,1] + 93 /*105*/, 075 MSGet oNPlaOld Var cNPlaOld When .F. Picture "@!" Of oDlgRev Pixel

@ aPobjs[1,1] + 110 /*122*/, 005 Say STR0089 Of oDlgRev Pixel //"Por"
@ aPobjs[1,1] + 108 /*120*/, 035 MSGet oPlaNew  Var cPlaNew  Valid FS_VldPla(cPlaNew, oNPlaNew, @cNPlaNew) F3 "GCM" Picture "@!" Of oDlgRev Pixel
@ aPobjs[1,1] + 108 /*120*/, 075 MSGet oNPlaNew Var cNPlaNew When .F. Picture "@!" Of oDlgRev Pixel

ACTIVATE MSDIALOG oDlgRev CENTERED ON INIT EnchoiceBar(oDlgRev, {|| nOpcRev := 1, oDlgRev:End()}, ;
{|| nOpcRev := 0, oDlgRev:End()})

If nOpcRev == 1
	Processa({|| FS_HP12Rev(IIF(!lRevaLote, @__aMarkBrow, {}), nOrdemGcz, cChaveGcz, cWhileGcz, lRevaLote, dDatIni, dDatFin, cPlaOld, cPlaNew, lRevMat, lRevMed, lRevRes, lRevTax, lRevDia, lRevPro, lRevTxS, lUltPrc, lRedFil)})
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_HP12Rev(aMBrow, nOrdemGcz, cChaveGcz, cWhileGcz, lRevaLote, dDatIni, dDatFin, cPlaOld, cPlaNew, lRevMat, lRevMed, lRevRes, lRevTax, lRevDia, lRevPro, lRevTxS, lUltPrc, lRedFil)
Local cMsgRev := "", aArea := GetArea(), nGuiaAtu := 0, nGuiaTot := 0

If lRevaLote // Revaloriza็ใo por lote

	DbSelectArea("GAT")
	DbSetOrder(1) //GAT_FILIAL+GAT_NUMLOT
	DbSeek(xFilial("GAT") + cChaveGcz)

	DBSelectArea("GCZ")
	DbSetOrder(nOrdemGcz)
	DBSeek(xFilial("GCZ") + cChaveGcz)

	ProcRegua(GAT->GAT_ITENS)

	While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. &(cWhileGcz)

		nGuiaAtu++

		IncProc(STR0121 + GCZ->GCZ_NRSEQG + "][" + StrZero(nGuiaAtu, 6) + "/" + StrZero(GAT->GAT_ITENS, 6) + "]") //"Reval. guia ["

		If GCZ->GCZ_STATUS <> "3"

			cMsgRev += STR0014 + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + STR0122 + Chr(10) //"NRSEQG - "###"  NRGUIA - " //" Somente guias com status 3 podem ser revalorizadas"

			DBSkip()
			Loop

		ElseIf GCZ->GCZ_CANCEL == "1"
			cMsgRev += STR0014 + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + STR0092 + Chr(10) //"NRSEQG - "###"  NRGUIA - "###" estแ cancelada e nใo pode ser utilizada"###"Aten็ใo"

			DBSkip()
			Loop

		ElseIf FS_VERPCT(GCZ->GCZ_NRSEQG)
			cMsgRev += STR0014 + " " + GCZ->GCZ_NRSEQG +  STR0108 + GCZ->GCZ_NRGUIA + STR0192 + Chr(10)  //"NRSEQG - " ## " foi faturada por pacote e nใo pode ser revalorizada."

			DBSkip()
			Loop

		EndIf

		Begin Transaction
		If (lRedFil .Or. !Empty(cPlaNew))		//Hs_ExisDic({{"C", "GCZ_FILFAT"}}) .And. 
			RecLock("GCZ", .F.)
			GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
			MsUnLock()
		EndIf
		HS_RevCnt(GCZ->GCZ_NRSEQG, dDatIni, dDatFin, cPlaOld, cPlaNew, lRevMat, lRevMed, lRevRes, lRevTax, lRevDia, lRevPro, lRevTxS, lUltPrc, @cMsgRev)
		End Transaction

		If Alias() <> "GCZ"
			DBSelectArea("GCZ")
		EndIf

		If nOrdemGcz <> IndexOrd()
			DbSetOrder(nOrdemGcz)
		EndIf

		DBSkip()
	End

Else //Revaloriza็ใo por guias marcadas
	nGuiaTot := Len(aMBrow)

	ProcRegua(nGuiaTot)

	For nGuiaAtu := 1 To nGuiaTot

		If Alias() <> "GCZ"
			DBSelectArea("GCZ")
		EndIf

		If nOrdemGcz <> IndexOrd()
			DbSetOrder(nOrdemGcz)
		EndIf

		DBSeek(xFilial("GCZ") + aMBrow[nGuiaAtu][1])

		IncProc(STR0121 + GCZ->GCZ_NRSEQG + "][" + StrZero(nGuiaAtu, 6) + "/" + StrZero(nGuiaTot, 6) + "]") //"Reval. guia ["

		If GCZ->GCZ_CANCEL == "1"
			cMsgRev += STR0014 + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + STR0092 + Chr(10) //"NRSEQG - "###"  NRGUIA - "###" estแ cancelada e nใo pode ser utilizada"
		ElseIf HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == "1" .And. GCZ_STATUS == "2" .And. !Empty(GCZ->GCZ_NUMORC)
			cMsgRev += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0067 + STR0068 + GCZ->GCZ_NUMORC + Chr(10) //"NRSEQG - "###"Esta guia jแ possui or็amento gerado."###"Or็amento No. "
		ElseIf GCZ->GCZ_STATUS == "3" // Nao executa para a rotina de manuten็ใo de lotes
			cMsgRev += STR0014 + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + " " + STR0107 + Chr(10) //"NRSEQG - "###"  NRGUIA - "###"Esta guia nใo pode ser alterada por jแ estar atrelada a um lote"
		ElseIf GCZ->GCZ_STATUS >= "4"
			cMsgRev += STR0014 + " " + GCZ->GCZ_NRSEQG + STR0165 + Chr(10) //"NRSEQG - " //" ja possui fatura gerada"
		ElseIf GCZ->GCZ_STATUS >= "9"
			cMsgRev += STR0014 + " " + GCZ->GCZ_NRSEQG + " jแ foi utilizada para repasse particular" + Chr(10) //"NRSEQG - " //" ja possui fatura gerada"
		ElseIf FS_VERPCT(GCZ->GCZ_NRSEQG)
			cMsgRev += STR0014 + " " + GCZ->GCZ_NRSEQG + STR0192 + Chr(10)  //"NRSEQG - " ## " foi faturada por pacote e nใo pode ser revalorizada."
		Else
			Begin Transaction
			If (lRedFil .Or. !Empty(cPlaNew))		//Hs_ExisDic({{"C", "GCZ_FILFAT"}}) .And. 
				RecLock("GCZ", .F.)
				GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
				MsUnLock()
			EndIf
			HS_RevCnt(GCZ->GCZ_NRSEQG, dDatIni, dDatFin, cPlaOld, cPlaNew, lRevMat, lRevMed, lRevRes, lRevTax, lRevDia, lRevPro, lRevTxS, lUltPrc, @cMsgRev)
			End Transaction
		EndIf

	Next

EndIf

If !Empty(cMsgRev)
	HS_MsgInf(cMsgRev, STR0016, STR0123) //"Revaloriza็ใo de contas"
EndIf

RestArea(aArea)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldPla(cCodPla, oNomPla, cNomPla)
Local lRet := .T., aArea := GetArea()

If !Empty(cCodPla)
	DbSelectArea("GCM")
	DbSetOrder(2) //GCM_FILIAL+GCM_CODPLA
	If (lRet := DbSeek(xFilial("GCM") + cCodPla))
		cNomPla := GCM->GCM_DESPLA
	Else
		cNomPla := PadR(STR0090, 20) //"Plano invalido"
	EndIf

	oNomPla:Refresh()
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_HP12PARณ Autor ณGilson da Silva        ณ Data ณ04/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ GERA FATURAMENTO PARCIAL                            		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01 - Alias do Arquivo                             	  ณฑฑ
ฑฑณ          ณ ExpN02 - Nr. do registro                              	  ณฑฑ
ฑฑณ          ณ ExpN03 - Opcao Selecionada (Gerar Fatura ou Excluir)		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12 				                      			  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12PAR(cAlias, nReg, nOpc)   //Parcial
Local cPerg1   := PADR("HSP12B", LEN(SX1->X1_GRUPO))
Local aHeadInt := {}, aColsInt  := {}
Local nOpcA    := 1
Local nGDOpc   := GD_INSERT + GD_UPDATE + GD_DELETE
Local lRet     := .F., lPacote := .F.

Private oDlgInt, oInterc
Private n_CodProI := 0, n_DatIniI := 0, n_DatFinI := 0, n_HorIniI := 0, n_HorFinI := 0, n_CodLocI := 0
Private aDespGD5  := {}, aDespGD6 := {}, aDespGD7 := {}

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

If GCZ->GCZ_STATUS == '9'
	MsgInfo("Esta guia nใo pode ser alterada pois foi utilizada para repasse particular",STR0016) //###"Aten็ใo"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.T.)
EndIf


If GCZ->GCZ_STATUS == '3'
	MsgInfo(STR0107,STR0016) //"Esta guia nใo pode ser alterada por jแ estar atrelada a um lote"###"Aten็ใo"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.T.)
EndIf

If GCZ->GCZ_CANCEL == "1"
	MsgStop(STR0014 + '  ' + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + '  ' + STR0092,STR0016) //"NRSEQG - "###"  NRGUIA - "###" estแ cancelada e nใo pode ser utilizada"###"Aten็ใo"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.F.)
EndIf

If GCZ->GCZ_STATUS == "2"
	MSGSTOP(STR0015) //###"Existe Guia Marcada que ja foi faturada, nao sera possivel fatura-la, Atencao!!!"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.F.)
EndIf

If GCZ->GCZ_STATUS >= "4"
	MSGSTOP(STR0014 + " " + GCZ->GCZ_NRSEQG + STR0165) //"NRSEQG - " //" ja possui fatura gerada"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.F.)
EndIf

If !MsgYesNo(STR0098 + CHR(10) + STR0238, STR0016) //"Confirma Gerar Faturamento Parcial?  "###"Ap๓s a finaliza็ใo da gera็ใo parcial, o faturamento dessa guias nใo poderใo mais ser excluํdos"###"Aten็ใo"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.F.)
EndIf

If !Pergunte(cPerg1,.T.)
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.F.)
EndIf

dDtLimite := mv_par01

If (lPacote := mv_par02 == 2) //Sim

	cGP0CodCon := GCZ->GCZ_CODCON

	//Posiciona GCY
	DbSelectArea("GCY")
	DBSetOrder(1) //GCY_FILIAL+GCY_REGATE
	DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

	//Header da Aba Intercorrencia
	aAdd(aHeadInt,{STR0124,"HSPCODPROI","@!", TamSx3("GA7_CODPRO")[1],0, "HS_VldPct(oInterc,, .F.)",,"C","GP0001" ,"R",,,,"A"})  //"Pacote    "
	aAdd(aHeadInt,{STR0125,"HSPDESPROI","@!", 40,0,,,"C",         ,"R",,,,"V"}) //"Descricao "
	aAdd(aHeadInt,{STR0126,"HSPDATINII","@!",  8,0, "HS_VldDat(dDtLimite)",,"D",         ,"R",,"CTOD('  /  /  ')",,"A"}) //"Dt Inicial"
	aAdd(aHeadInt,{STR0180,"HSPHORINII","99:99",  5,0, "HS_VldHora(M->HSPHORINII)",,"C",         ,"R",,,,"A"})  //"Hora Inicial"
	aAdd(aHeadInt,{STR0127,"HSPDATFINI","@!",  8,0, "HS_VldDat(dDtLimite)",,"D",         ,"R",,"CTOD('  /  /  ')",,"A"}) //"Dt Final  "
	aAdd(aHeadInt,{STR0181,"HSPHORFINI","99:99",  5,0, "HS_VldHora(M->HSPHORFINI)",,"C",         ,"R",,,,"A"})  //"Hora Final"
	aAdd(aHeadInt,{STR0046,"HSPCODLOCI","@!",  2,0, "HS_SeekRet('GCS','M->HSPCODLOCI',1,.f.,'HSPNOMLOCI','GCS_NOMLOC',,,.T.)",,"C","GCS"    ,"R",,,,"A"})  //"Setor"
	aAdd(aHeadInt,{STR0182,"HSPNOMLOCI","@!", 30,0,,,"C",         ,"R",,,,"V"})  //"Descri็ใo"

	n_CodProI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCODPROI"})
	n_DatIniI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPDATINII"})
	n_HorIniI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPHORINII"})
	n_DatFinI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPDATFINI"})
	n_HorFinI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPHORFINI"})
	n_CodLocI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCODLOCI"})

	aSize := MsAdvSize(.T.)
	aObjects := {}

	AAdd( aObjects, { 100, 100, .T., .T. })

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )

	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo := { aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 0, 0 }
	aPGDs := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlgInt TITLE OemtoAnsi(STR0224) FROM  07,0 to 35, 100 OF oMainWnd //"Gerar Faturamento Parcial com Pacote"

	oInterc := MsNewGetDados():New(aPGDs[1,1], aPGDs[1,2], aPGDs[1,3], aPGDs[1,4], nGDOpc,,,,,,99999,,,, oDlgInt , aHeadInt, aColsInt)
	oInterc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgInt CENTERED ON INIT EnChoiceBar(oDlgInt, {|| nOpcA := 1, IIf(FS_CpoObrI(oInterc:aCols), oDlgInt:End(), nOpcA := 0)}, ;
	{|| nOpcA := 0, oDlgInt:End()} )

EndIf

If nOpcA == 1
	Begin Transaction
	Processa({|| FS_GerPar(IIF(lPacote, oInterc:aCols, {}))})
	End Transaction
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_HP12PCTณ Autor ณDaniel Peixoto         ณ Data ณ25/01/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ GERA FATURAMENTO PARA PACOTES                          	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01 - Alias do Arquivo                             	  ณฑฑ
ฑฑณ          ณ ExpN02 - Nr. do registro                              	  ณฑฑ
ฑฑณ          ณ ExpN03 - Opcao Selecionada                             	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso  	 ณ HSPAHP12 		                         				  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12PCT(cAlias,nReg,nOpc)   //Pacote
Local aAreaOld  := GetArea()
Local oEncGcz, oEncGa9
Local aCpoGCZ   :={}
Local aCpoGA9   :={}
Local cAlias1   := "GA9"
Local nReg1     := 0
Local cOriDes   := "1" //Procedimento
Local nOpcA     := 0
Local nGDOpc    := GD_INSERT + GD_UPDATE + GD_DELETE
Local lRet      := .F.
Local nGuiaAtu  := 0
Local cCodPro   := ""
Local oDlgPct
Local oFolEnc, oFolGet

Local aHeadPct  := {}, aColsPct  := {}
Local aHeadInt  := {}, aColsInt  := {}

Private n_CodPro  := 0, n_DatIni  := 0, n_DatFin  := 0, n_CodCrm  := 0, n_NomCrm := 0
Private n_CodProI := 0, n_DatIniI := 0, n_DatFinI := 0, n_HorIniI := 0, n_HorFinI := 0, n_CodLocI := 0, n_CntAbeI := 0
Private cCODCRM  := ""
Private dDATINI  := CTOD("  /  /  ")
Private dDATFIN  := CTOD("  /  /  ")
Private nGuiaTot := Len(__aMarkBrow)
Private cMsgErro := ""
Private cMsgOK   := ""

Private oPct, oInterc
Private nVlrPct := 0
Private aRetGAC :={.F.,0,""}

SetKey(VK_F12, bKeyF12)
SetKey(VK_F4 , bKeyF4 )

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	RestArea(aAreaOld)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

If nGuiaTot == 0
	HS_MsgInf(STR0178, STR0016, STR0133) //"Nenhuma guia selecionada"###"Aten็ใo###""Faturamento de pacote"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(Nil)
EndIf

For nGuiaAtu := 1 To nGuiaTot

	If Alias() <> "GCZ"
		DBSelectArea("GCZ")
	EndIf

	If IndexOrd() <> 1
		DBSetOrder(1)
	EndIf

	DBSeek(xFilial("GCZ") + __aMarkBrow[nGuiaAtu][1])

	If GCZ->GCZ_CANCEL == "1"
		MsgStop(STR0014 + "  " + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + '  ' + STR0092,STR0016) //"NRSEQG - "###"  NRGUIA - "###" estแ cancelada e nใo pode ser utilizada"###"Aten็ใo"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(.f.)
	EndIf

	If cLocCont <> "0" .And. GCZ->GCZ_STATUS == "0"
		MsgStop(STR0100)//"Esta Guia encontra-se no Controle de Localizacao de Contas, Verifique!!!"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(.F.)
	EndIf

	If GCZ->GCZ_STATUS == "2"
		MSGSTOP(STR0015) //"Existe Guia Marcada que ja foi faturada, nao sera possivel fatura-la, Atencao!!!"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(.F.)
	EndIf

	If GCZ->GCZ_STATUS == "3"
		MsgInfo(STR0107,STR0016) //"Esta guia nใo pode ser alterada por jแ estar atrelada a um lote"###"Aten็ใo"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(.t.)
	EndIf

	If GCZ->GCZ_STATUS >= "4"
		MSGSTOP(STR0014 + " " + GCZ->GCZ_NRSEQG + STR0165) //"NRSEQG - "###" ja possui fatura gerada"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(.F.)
	EndIf

	HS_ExluiDes(GCZ->GCZ_NRSEQG)
	FS_ExluiPct(GCZ->GCZ_NRSEQG)

	//Posiciona GCY
	DbSelectArea("GCY")
	DBSetOrder(1) //GCY_FILIAL+GCY_REGATE
	DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

	If nGuiaTot == 1
		cGP0CodCon := GCZ->GCZ_CODCON

		aCpoGCZ  :={}
		DbSelectArea("SX3")
		DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
		DbSeek("GCZ")
		While !Eof() .And. (x3_arquivo == "GCZ")
			If cNivel >= SX3->X3_NIVEL .And. alltrim(x3_campo) $ "GCZ_NRSEQG/GCZ_REGATE/GCZ_NOME/GCZ_CODPLA/GCZ_DESPLA"
				AADD(aCpoGCZ, x3_campo)
			Endif
			wVar := "M->" + SX3->X3_CAMPO
			&wVar:= IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GCZ->(FieldGet(FieldPos(SX3->X3_CAMPO))))
			dbSkip()
		End

		aCpoGA9 :={}
		DbSelectArea("GA9")
		DbSetOrder(1)  //GA9_FILIAL+GA9_CODCON
		If DbSeek(xFilial("GA9") + GCZ->GCZ_CODCON)
			nReg1 := Recno()
			DbSelectArea("SX3")
			DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
			DbSeek("GA9")
			While !Eof() .And. (x3_arquivo == "GA9")
				If cNivel >= SX3->X3_NIVEL .And. alltrim(x3_campo) $ "GA9_CODCON/GA9_NOME"
					AADD(aCpoGA9, x3_campo)
				Endif
				wVar := "M->" + SX3->X3_CAMPO
				&wVar:= IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GA9->(FieldGet(FieldPos(SX3->X3_CAMPO))))
				dbSkip()
			End
		EndIf
	EndIf

	If nGuiaAtu == 1 //so mostra na primeira vez
		//Header da Aba Pacote
		aAdd(aHeadPct,{STR0124,"HSP_CODPRO","@!",  TamSx3("GA7_CODPRO")[1],0, "HS_VldPct(oInterc, IIF(nGuiaTot == 1, .T., .F.))",,"C","GP0001" ,"R",,,,"A"})  //"Pacote    "
		aAdd(aHeadPct,{STR0125,"HSP_DESPRO","@!", 50,0,,,"C",         ,"R",,,,"V"}) //"Descricao "
		aAdd(aHeadPct,{STR0126,"HSP_DATINI","@!",  8,0, "IIF(nGuiaTot == 1, HS_VldDat(), .T.)",,"D",         ,"R",,"IIF(nGuiaTot == 1, GCZ->GCZ_DATATE, CTOD('  /  /  '))",,"A"}) //"Dt Inicial"
		aAdd(aHeadPct,{STR0127,"HSP_DATFIN","@!",  8,0, "IIF(nGuiaTot == 1, HS_VldDat(), .T.)",,"D",         ,"R",,"IIF(nGuiaTot == 1, IIF(EMPTY(GCY->GCY_DATALT), DDATABASE, GCY->GCY_DATALT), CTOD('  /  /  '))",,"A"}) //"Dt Final  "
		aAdd(aHeadPct,{STR0128,"HSP_CODCRM","@!",  TamSx3("GBJ_CRM")[1],0, "HS_VldCRM()",,"C","MED"    ,"R",,"GetMv('MV_CRMPADH')",,"A"}) //"CRM       "
		aAdd(aHeadPct,{STR0129,"HSP_NOMCRM","@!", 30,0,,,"C",         ,"R",,"HS_IniPadr('SRA', 11, GetMv('MV_CRMPADH'), 'RA_NOME')",,"V"}) //"Nome      "

		n_CodPro := aScan(aHeadPct, { | aVet | aVet[2] == "HSP_CODPRO"})
		n_DatIni := aScan(aHeadPct, { | aVet | aVet[2] == "HSP_DATINI"})
		n_DatFin := aScan(aHeadPct, { | aVet | aVet[2] == "HSP_DATFIN"})
		n_CodCrm := aScan(aHeadPct, { | aVet | aVet[2] == "HSP_CODCRM"})
		n_NomCrm := aScan(aHeadPct, { | aVet | aVet[2] == "HSP_NOMCRM"})

		//Header da Aba Intercorrencia
		aAdd(aHeadInt,{STR0179,"HSPCNTABEI","@!",  1,0,"HS_VldPct(oInterc)",,"C",         ,"R","0=Nao;1=Sim","1",,"A"})  //"Conta Aberta"
		aAdd(aHeadInt,{STR0124,"HSPCODPROI","@!", TamSx3("GA7_CODPRO")[1],0, "HS_VldPct(oInterc, IIF(nGuiaTot == 1, .T., .F.))",,"C","GP0001" ,"R",,,,"A"})  //"Pacote    "
		aAdd(aHeadInt,{STR0125,"HSPDESPROI","@!", 50,0,,,"C",         ,"R",,,,"V"}) //"Descricao "
		aAdd(aHeadInt,{STR0126,"HSPDATINII","@!",  8,0, "IIF(nGuiaTot == 1, HS_VldDat(), .T.)",,"D",         ,"R",,"CTOD('  /  /  ')",,"A"}) //"Dt Inicial"
		aAdd(aHeadInt,{STR0180,"HSPHORINII","99:99",  5,0, "HS_VldHora(M->HSPHORINII)",,"C",         ,"R",,,,"A"})  //"Hora Inicial"
		aAdd(aHeadInt,{STR0127,"HSPDATFINI","@!",  8,0, "IIF(nGuiaTot == 1, HS_VldDat(), .T.)",,"D",         ,"R",,"CTOD('  /  /  ')",,"A"}) //"Dt Final  "
		aAdd(aHeadInt,{STR0181,"HSPHORFINI","99:99",  5,0, "HS_VldHora(M->HSPHORFINI)",,"C",         ,"R",,,,"A"})  //"Hora Final"
		aAdd(aHeadInt,{STR0046,"HSPCODLOCI","@!",  2,0, "HS_SeekRet('GCS','M->HSPCODLOCI',1,.f.,'HSPNOMLOCI','GCS_NOMLOC',,,.T.)",,"C","GCS"    ,"R",,,,"A"})  //"Setor"
		aAdd(aHeadInt,{STR0182,"HSPNOMLOCI","@!", 30,0,,,"C",         ,"R",,,,"V"})  //"Descri็ใo"

		n_CntAbeI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCNTABEI"})
		n_CodProI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCODPROI"})
		n_DatIniI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPDATINII"})
		n_HorIniI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPHORINII"})
		n_DatFinI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPDATFINI"})
		n_HorFinI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPHORFINI"})
		n_CodLocI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCODLOCI"})

		aSize := MsAdvSize(.T.)

		aObjects := {}
  		AAdd( aObjects, { 100, 100, .T., .T., .T. } )

  		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  		aPObjs := MsObjSize( aInfo, aObjects )

		aObjects := {}
		nNroTela := IIF(nGuiaTot == 1, 2, 1)
		If nGuiaTot == 1
			AAdd( aObjects, { 100, 045, .T., .T., .T. })
			AAdd( aObjects, { 100, 055, .T., .T. })
		Else
			AAdd( aObjects, { 100, 100, .T., .T. })
		EndIf

		aInfo := { aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 0, 0 }
		aPGDs := MsObjSize( aInfo, aObjects, .T. )

		DEFINE MSDIALOG oDlgPct TITLE OemtoAnsi(STR0020) FROM  aSize[7],0 TO aSize[6], aSize[5] Of oMainWnd PIXEL // "Gera Faturamento Por Pacote"
		If nGuiaTot == 1
			@ aPGDs[1,1], aPGDs[1,2] FOLDER oFolEnc SIZE aPGDs[1,3], aPGDs[1,4] Pixel OF oDlgPct Prompts STR0070, STR0071 //"Dados da Guia"###"Dados do Convenio"
			oFolEnc:Align := CONTROL_ALIGN_TOP

			// Dados da Guia
			oEncGcz := MsMGet():New(cAlias,nReg,2,,,,aCpoGCZ,aPObjs[1],,,,,,oFolEnc:aDialogs[1],,,,,.T.)
			oEncGcz:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			// Dados do Convenio
			oEncGa9 := MsMGet():New(cAlias1,nReg1,2,,,,aCpoGA9,aPObjs[1],,,,,,oFolEnc:aDialogs[2],,,,,.T.)
			oEncGA9:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf
		@ aPGDs[nNroTela,1], aPGDs[nNroTela,2] FOLDER oFolGet SIZE aPGDs[nNroTela,3], aPGDs[nNroTela,4] Pixel OF oDlgPct Prompts STR0007, STR0183 //"Pacote"###"Intercorr๊ncia"
		oFolGet:Align := CONTROL_ALIGN_ALLCLIENT

		oPct := MsNewGetDados():New(aPGDs[1,1], aPGDs[1,2], aPGDs[1,3], aPGDs[1,4], nGDOpc,,,,,,99999,,,, oFolGet:aDialogs[1] , aHeadPct, aColsPct )
		oPct:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		oInterc := MsNewGetDados():New(aPGDs[1,1], aPGDs[1,2], aPGDs[1,3], aPGDs[1,4], nGDOpc,,,,,,99999,,,, oFolGet:aDialogs[2] , aHeadInt, aColsInt )
		oInterc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgPct CENTERED ON INIT EnChoiceBar(oDlgPct, {|| nOpcA := 1, IIf(FS_CpoObrP(oPct:aCols) .And. FS_CpoObrI(oInterc:aCols, .T.) .And. FS_CrmPct(oPct:aCols), oDlgPct:End(), nOpcA := 0)}, ;
		{|| nOpcA := 0, oDlgPct:End()} )


		If nOpcA == 0 // Opqera็ใo cancelada
			SetKey(VK_F12, {|| HS_FILHP12()})
			SetKey(VK_F4 , {|| HS_MarkF4()})
			UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
			HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
			Return(Nil)
		EndIf

		lRet := MsgYesNo(STR0094, STR0016) //"Confirma Gerar Contas para o Faturamento?"###"Aten็ใo"
	EndIf

	If lRet
		Begin Transaction
		If Len(oPct:aCols) > 0
			Processa({|| FS_GrvPct()})
		EndIf
		End Transaction
	EndIf

Next

HS_MsgInf(IIF(!EMPTY(cMsgOK), STR0132, STR0174) + CHR(10) +; //"Faturamento terminado com sucesso"###"Faturamento nใo realizado"
cMsgOK + IIF(!EMPTY(cMsgOK), CHR(10), "") +;
cMsgErro, STR0016, STR0133) //"Aten็ใo###""Faturamento de pacote"

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aAreaOld)

SetKey(VK_F12, {|| HS_FILHP12()})
SetKey(VK_F4 , {|| HS_MarkF4()})

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_HP12Fat   ณ Autor ณGilson da Silva        ณ Data ณ26/02/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Grava nas tabelas GE5/GE6/GE7                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                                       		 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12 		                       						 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12Fat(cNrSeqG, lGerRepA)
Local nFieldGb  	 := 0
Local aArea     	 := GetArea()
Local cMsgErro  	 := ""
Local aProcessa 	 := {}
Local nGuiaAtu  	 := 0
Local nGuiaTot   	:= IIF(Type("__aMarkBrow") <> "U", Len(__aMarkBrow), 1)
Local aPar								:= {}
Local lAteSUS		:= .F. //Indica se o Modulo atende ao SUS.
Local cGe7SeqDes		:= ""
Local cRegSol := "", cRegAlt := "", cMsgDesp := ""
Local lExcDesp := IIf(GetMv("MV_EXCDFAT",,"S") == "N", .F., .T.)
Local lFatASUS := SuperGetMV("MV_FATASUS",, .F.)
Local aProcApac := {}
Local aFatSes	:= {}
Default lGerRepA := .F.

If !IsInCallStack("HS_GerCaix")//FunName() <> "HSPM24AA" //Chamada da rotina de gera็ใo de Caixa atrav้s do ambulatorio
	If !lGerRepA .and. !(HS_VldBrowse(oMb))
		Return(Nil)
	EndIf
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

/* Valida ATENDIMENTO SUS*/
If (lAteSUS := (GetMV("MV_ATESUS", , "N") == "S"))
	aPar 				:= {{"MV_PCONSUS",""},{"MV_PSUSBPA",""},{"MV_PSUSPAC",""},{"MV_PSUSAIH",""}}
	If !HS_VMVSUS(@aPar)
	    UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	    HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return()
	EndIf
EndIf

If lFatASUS .AND. Type("__aMarkBrow") <> "U"
	aFatSes := FS_VFTASUS(@__aMarkBrow, nGuiaTot, aPar[2, 2])
	nGuiaTot := Len(__aMarkBrow)
EndIf


If cNrSeqG == Nil

	If ! MsgYesNo(STR0094, STR0016) //"Confirma Gerar Contas para o Faturamento?  "###"Aten็ใo"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(nil)
	EndIf

	ProcRegua(nGuiaTot * 3)

EndIf

For nGuiaAtu := 1 To IIf(cNrSeqG == Nil, nGuiaTot, 1)

	If Alias() <> "GCZ"
		DBSelectArea("GCZ")
	EndIf

	If IndexOrd() <> 1
		DBSetOrder(1)
	EndIf

	DBSeek(xFilial("GCZ") + IIf(cNrSeqG == Nil, __aMarkBrow[nGuiaAtu][1], cNrSeqG))

	DbselectArea("GCY")
	DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
	DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

	DBSelectArea("GCZ")

	If !Hs_VlPdEx(GCZ->GCZ_REGATE, cNrSeqG # Nil)
		If cNrSeqG == nil
			cMsgErro +=  STR0235+GCZ->GCZ_REGATE+STR0236 + chr(10) //"Atendimento - "###" - Hแ exames laudados que nใo foram liberados. Verifique"
		EndIF
	EndIf

	If GCZ->GCZ_CANCEL == "1"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0092 + chr(10) //"NRSEQG - "###" estแ cancelada e nใo pode ser utilizada"
	ElseIf cNrSeqG == Nil .And. cLocCont <> "0" .And. GCZ->GCZ_STATUS == "0"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0100 + Chr(10) //"NRSEQG - "###" encontra-se no Controle de Localizacao de Contas, Verifique!!!"
	//ElseIf cLocCont == "0" .And. (GCY->GCY_ATENDI == "0" .And. Empty(GCY->GCY_DATALT)) .And. (IIf(HS_ExisDic( {{"C","GCZ_NRGGLO"}} , .F. ),Empty(GCZ->GCZ_NRGGLO),.T.))
	ElseIf cLocCont == "0" .And. (GCY->GCY_ATENDI == "0" .And. iIf(lGerRepA, .T., Empty(GCY->GCY_DATALT))) .And. Empty(GCZ->GCZ_NRGGLO) 
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0217 + Chr(10) //"NRSEQG - "###" petence a um atendimento de Interna็ใo que nใo possui alta."
	ElseIf GCZ->GCZ_STATUS == "2"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0015 + chr(10) //"NRSEQG - "###" ja foi faturada, nao sera possivel fatura-la"
	ElseIf GCZ->GCZ_STATUS == "3"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0107 + chr(10) //"NRSEQG - "###"nใo pode ser alterada por jแ estar atrelada a um lote"
	ElseIf GCZ->GCZ_STATUS == "9"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " jแ foi utilizada para repasse particular"  + chr(10) //"NRSEQG - "###
	ElseIf GCZ->GCZ_STATUS >= "4"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0167 + chr(10) //"NRSEQG - "###"ja tem fatura gerada"
		//Numero da Autoriza็ใo
	ElseIf GCY->GCY_ATENDI == "0" .And. !HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == "1"  .And. !(GCZ->GCZ_CODPLA $ __cCodBPA + "/" + __cCodPAC + "/" + __cCodAIH) .And. (Empty(GCZ->GCZ_NRGUIA) .Or. Empty(GCZ->GCZ_NRSEN1) .Or. iIf(lGerRepA, .T., Empty(GCY->GCY_CIDALT)))
		If Empty(GCZ->GCZ_NRGUIA)
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0250 + chr(10) //"NRSEQG - "###"Guia nใo faturada. Numero da autoriza็ใo nใo estแ preenchido na guia."
		EndIf

		If Empty(GCZ->GCZ_NRSEN1)
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0252 + chr(10)
		EndIf

		If iIf(lGerRepA, .T., Empty(GCY->GCY_CIDALT))
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0251 + chr(10) //"NRSEQG - "###"Guia nใo faturada. Preencha o campo 'CID ALT.' "
		EndIf
	ElseIf lFatASUS .AND. !FS_VSESPOS(GCZ->GCZ_REGATE, aFatSes, GCZ->GCZ_NRSEQG)  .AND. GCZ->GCZ_CODPLA $ aPar[2, 2]
		cMsgErro += "Existem atendimentos/agendamentos futuros para essa terapia!" + " " + GCZ->GCZ_NRSEQG + " " + "Guia nใo faturada. ษ Necessแrio terminar as sess๕es para realizar o faturamento!" + chr(10) //"NRSEQG - "###"Guia nใo faturada. Preencha o campo 'CID ALT.' "
	Else
		If !(HS_VldTran(@cRegSol, @cRegAlt, @cMsgDesp, lGerRepA, .T.))
			Loop
		EndIf

		// Se o Hospital atende SUS e essa guia eh do SUS
		If lAteSus .And. (GCZ->GCZ_CODPLA $ aPar[2, 2] .Or. GCZ->GCZ_CODPLA $ aPar[3, 2] .Or. GCZ->GCZ_CODPLA $ aPar[4, 2])
				If !HS_VerGSUS(@cMsgErro)//Faz Verificacoes referentes ao codigo proprio
					Loop
				EndIf
		EndIf

		aProcessa := HS_P12SEL("P") //Verifica se existe alguma despesa de Mat/Med - Tax/Dia - Procedto zerada referente a esta Guia.

			If !(lAteSus .And. GCZ->GCZ_CODPLA $ __cCodPAC)
				HS_FatConv(GCZ->GCZ_NRSEQG)
			EndIf

		Begin Transaction

		If aProcessa[1] .And. aProcessa[2] .And. aProcessa[3] .And. aProcessa[5][1] .And. aProcessa[5][2] .And. aProcessa[5][3] .Or.;
			(GCZ->GCZ_CODPLA $ __cCodBPA + "/" + __cCodPAC + "/" + __cCodAIH) //Nใo valida para o SUS

			If GCZ->GCZ_CODPLA $ __cCodAIH
				HS_FATAIH(GCZ->GCZ_NRSEQG)
			EndIf

			// Gerando Registros no Arquivo de Faturamento (Mat/Med)
			IncProc(STR0030 + " - " + GCZ->GCZ_NRSEQG) // "Transferindo Mat/Med, Guia"

			If !(GCZ->GCZ_CODPLA $ __cCodPAC) .And. GCZ->GCZ_CODPLA # __cCodAIH //Se for APAC nใo haverแ GE para Mat/Med e Tax/Dia
				DbSelectArea("GD5")
				DBSetOrder(2) //GD5_FILIAL+GD5_NRSEQG+DTOS(GD5_DATDES)
				DbSeek(xFilial("GD5") + GCZ->GCZ_NRSEQG)

				While !eof() .and. GD5->GD5_FILIAL + GD5->GD5_NRSEQG == xFilial("GD5") + GCZ->GCZ_NRSEQG

					If Empty(GD5->GD5_SEQGE5) .Or. lExcDesp
						DbSelectArea("GE5")
						M->GE5_SEQDES := HS_VSxeNum("GE5", "M->GE5_SEQDES", 1)

						RecLock("GE5",.T.)
						For nFieldGb := 1 To GD5->(FCount())
							If !(GD5->(FieldName(nFieldGb)) $ "GD5_FILIAL/GD5_SEQDES/GD5_LOGARQ") .And. ValType("GE5->GE5" + SubStr(GD5->(FieldName(nFieldGb)), 4)) # "U"
								&("GE5->GE5" + SubStr(GD5->(FieldName(nFieldGb)), 4)) := GD5->(&(FieldName(nFieldGb)))
							EndIf
						Next

						GE5->GE5_FILIAL := xFilial("GE5")
						GE5->GE5_SEQDES := M->GE5_SEQDES
						GE5->GE5_LOGARQ := HS_LogArq()
						MsUnlock()

						DbSelectArea("GD5")

						RecLock("GD5", .F.)
						GD5->GD5_SEQGE5 := M->GE5_SEQDES
						MsUnLock()
					EndIf

					DbSkip()
				Enddo

				// Gerando Registros no Arquivo de Faturamento (Taxas/Diarias)
				IncProc(STR0031 + " - " + GCZ->GCZ_NRSEQG) //"Transferindo Taxas / Diarias, Guia"

				DbSelectArea("GD6")
				DBSetOrder(2) //GD6_FILIAL+GD6_NRSEQG+DTOS(GD6_DATDES)
				DbSeek(xFilial("GD6") + GCZ->GCZ_NRSEQG)

				While !eof() .and. GD6->GD6_FILIAL + GD6->GD6_NRSEQG == xFilial("GD6") + GCZ->GCZ_NRSEQG

					If Empty(GD6->GD6_SEQGE6)	.Or. lExcDesp
						DbSelectArea("GE6")
						M->GE6_SEQDES := HS_VSxeNum("GE6", "M->GE6_SEQDES", 1)

						RecLock("GE6",.T.)
						For nFieldGb := 1 To GD6->(FCount())
							If !(GD6->(FieldName(nFieldGb)) $ "GD6_FILIAL/GD6_SEQDES/GD6_LOGARQ") .And. ValType("GE6->GE6" + SubStr(GD6->(FieldName(nFieldGb)), 4)) # "U"
								&("GE6->GE6" + SubStr(GD6->(FieldName(nFieldGb)), 4)) := GD6->(&(FieldName(nFieldGb)))
							EndIf
						Next

						GE6->GE6_FILIAL := xFilial("GE6")
						GE6->GE6_SEQDES := M->GE6_SEQDES
						GE6->GE6_LOGARQ := HS_LogArq()
						MsUnlock()

						DbSelectArea("GD6")

						RecLock("GD6", .F.)
						GD6->GD6_SEQGE6 := M->GE6_SEQDES
						MsUnLock()
					EndIf

					DbSkip()
				Enddo
			EndIF

			// Gerando Registros no Arquivo de Faturamento (Procedimento/Honorarios)
			IncProc(STR0032 + " - " + GCZ->GCZ_NRSEQG) //"Transferindo Procedimentos, Guia"

			DbSelectArea("GD7")
			DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES
			DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG)

			While !eof() .and. GD7->GD7_FILIAL + GD7->GD7_NRSEQG == xFilial("GD7") + GCZ->GCZ_NRSEQG


					If (!GD7->GD7_ITEFAT .and. Empty(GD7->GD7_SEQGE7)) .Or.( Empty(GD7->GD7_SEQGE7).Or. lExcDesp)			// HS_ExisDic({{"C", "GD7_ITEFAT"}}, .F.) .and. 
						If !(GCZ->GCZ_CODPLA $ __cCodPAC) .Or. aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}) == 0
							cGe7SeqDes := HS_VSxeNum("GE7", "M->GE7_SEQDES", 1)
						Else
							cGe7SeqDes := aProcApac[aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}), 2]
						EndIf

						DbSelectArea("GD7")
						RecLock("GD7", .F.)
						GD7->GD7_SEQGE7 := cGe7SeqDes
						/* Grava os Relacionamentos UNICOS */
						FS_GravREL(lAteSUS, "GD7", GD7->GD7_CODDES, aPar) // Par(..., Procedimento)
						MsUnLock()

						If !(GCZ->GCZ_CODPLA $ __cCodPAC) .Or. aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}) == 0
							aAdd(aProcApac, {GD7->GD7_CODDES, cGe7SeqDes})
							DbSelectArea("GE7")
							M->GE7_SEQDES := cGe7SeqDes

							RecLock("GE7",.T.)
							For nFieldGb := 1 To GD7->(FCount())
								// Para otimiza็ใo na versใo 12, verificado que a fun็ใo Type estแ detonando o processando
								// Foi removida a condi็ใo da fun็ใo Type e colocado os campos da GD7 que nใo existam na GE7 na string abaixo 
								If !(GD7->(FieldName(nFieldGb)) $ "GD7_FILIAL/GD7_SEQDES/GD7_SPRINC/GD7_LOGARQ/GD7_FATPAR/GD7_SLAUDO/GD7_CRMLAU/GD7_NMELAU/GD7_SEQGE7/GD7_NUMORC/GD7_ITEORC/GD7_ITEFAT") 
									&("GE7->GE7" + SubStr(GD7->(FieldName(nFieldGb)), 4)) := GD7->(&(FieldName(nFieldGb)))
								EndIf
							Next
							If !Empty(GD7->GD7_SPRINC)
								If GD7->GD7_SPRINC == GD7->GD7_SEQDES
									GE7->GE7_SPRINC := M->GE7_SEQDES
								Else
									GE7->GE7_SPRINC := FS_SEQGE7(GD7->GD7_SPRINC)
								EndIf
							Else
								GE7->GE7_SPRINC := ""
							EndIf

							GE7->GE7_FILIAL := xFilial("GE7")
							GE7->GE7_SEQDES := M->GE7_SEQDES
							GE7->GE7_CODCON := GCZ->GCZ_CODCON
							GE7->GE7_LOGARQ := HS_LogArq()
							MsUnlock()
						EndIf
					EndIf

				DbSelectArea("GD7")
				DbSkip()
			Enddo

			DbSelectArea("GCZ")
			RecLock("GCZ",.F.)
			GCZ->GCZ_STATUS := "2"
			GCZ->GCZ_DATSTA := dDataBase
			GCZ->GCZ_DTGERA := DDATABASE
			GCZ->GCZ_HRGERA := TIME()
			GCZ->GCZ_USGERA := cUserName
			MsUnlock()
		Else
			cMsgErro += STR0014 + ' ' + GCZ->GCZ_NRSEQG + chr(10)//"NRSEQG - "

			If !aProcessa[1]
				cMsgErro += STR0113 + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med Com o Valor Zerado"
			EndIf

			If !aProcessa[2]
				cMsgErro += STR0114 + chr(10)//"Guia Nใo Faturada, existe despesa de Tax/Dia Com o Valor Zerado"
			EndIf

			If !aProcessa[3]
				cMsgErro += STR0115 + chr(10)//"Guia Nใo Faturada, existe despesa de Procedto Com o Valor Zerado"
			EndIf

			If !aProcessa[5][1]
				cMsgErro += STR0219 + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med com o Valor menor que o Desconto"
			EndIf

			If !aProcessa[5][2]
				cMsgErro += STR0220 + chr(10)//"Guia Nใo Faturada, existem despesas de Tax/Dia com o Valor menor que o Desconto"
			EndIf

			If !aProcessa[5][3]
				cMsgErro += STR0221 + chr(10)//"Guia Nใo Faturada, existem despesas de Procedto com o Valor menor que o Desconto"
			EndIf

		EndIf

		End Transaction

	EndIf

Next

// O Processamento abaixo sera executado apenas quando for a rotina 'Gerar' //
If cNrSeqG == Nil
	If !Empty(cMsgErro)
		HS_MsgInf(cMsgErro, STR0016, STR0063) //"Aten็ใo"###"Gera Faturamento"
		If lFatASUS .AND. !Empty(aFatSes)
			HS_MMarkB(@__aMarkBrow, cFilP12, .T.) // Desmarca guias
		EndIf
	EndIf
	If !Empty(cRegSol)
		HS_MsgInf(cRegSol, STR0016, STR0063) //"Aten็ใo"###"Gera Faturamento"
	EndIf
	If !Empty(cRegAlt)
		HS_MsgInf(cRegAlt, STR0016, STR0063) //"Aten็ใo"###"Gera Faturamento"
	EndIf
	If !Empty(cMsgDesp)
		HS_MsgInf(cMsgDesp, STR0016, STR0063) //"Aten็ใo"###"Gera Faturamento"
	EndIf
EndIf
cMsgErro += IIF(Empty(cRegSol),"", chr(13) + cRegSol)
cMsgErro += IIF(Empty(cRegAlt),"", chr(13) + cRegAlt)
cMsgErro += IIF(Empty(cMsgDesp),"", chr(13) + cMsgDesp)

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aArea)

Return(cMsgErro)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VerGSUSบAutor  ณLuiz Pereira S. Jr. บ Data ณ  18/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica na guia se hแ alguma despesa cujo c๓digo proprio   บฑฑ
ฑฑบ          ณnao existe no cadastro de procedimentos do SUS somente para บฑฑ
ฑฑบ          ณas guias do SUS.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VerGSUS(cMsgErro)

Local aArea := GetArea()
Local cSql  := ""
Local lRet  := .T.
Local aVetPro := {}
Local cDiaria := GetMv("MV_DIARUTI", , "")
Local nDiaria := 0
Local lPAIH	:= GCZ->GCZ_CODPLA==GetMv("MV_PSUSAIH")
Local cMedPadr := GetMv('MV_CRMPADH')
Local nDiaM := 0
Local nDias := 0
Local nDiaTot := 0
Local lVlCnsPac := SuperGetMV("MV_VLCNPAC",, .F.)

Private lVldCns := FindFunction("Hs_VldCns") // Verifica se a funcao Hs_VldCns esta no repositorio

DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY")+GCZ->GCZ_REGATE)

cSql := "SELECT GD7.GD7_CODDES, GD7.GD7_DATDES, GD7.GD7_CODCRM, GD7.GD7_CODATO, GD7.GD7_QTDDES, GBJ.GBJ_CODCNS, GBJ.GBJ_ESPEC1, GBJ.GBJ_ESPEC2, GBJ.GBJ_ESPEC3, GA7.GA7_QTDMAX ,GA7.GA7_PERMAN  "
cSql += "FROM " + RetSqlName("GD7") + " GD7 "
cSql +=   " JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND "
cSql +=   "            GBJ.GBJ_CRM    = GD7.GD7_CODCRM "
cSql +=   " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND "
cSql +=   "            GA7.GA7_CODPRO = GD7.GD7_CODDES "
cSql += "WHERE GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.GD7_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' AND GD7.GD7_CODDES NOT LIKE '0702%' AND GD7.GD7_CODDES NOT LIKE '080101%'"

cSql := ChangeQuery(cSql)
TcQuery cSql New Alias "TMPDES"

DbSelectArea("TMPDES")
DbGotop()

nDiaTot := 0
While !TMPDES->(Eof())

	If GCZ->GCZ_CODPLA $__cCodAIH .And. Substr(TMPDES->GD7_CODDES,1,6)='080201'
       nDias  := DateDiffDay (IIF(Empty(GCZ->GCZ_DCPARI), GCZ->GCZ_DATATE, GCZ->GCZ_DCPARI),IIF(Empty(GCY->GCY_DATALT), GCZ->GCZ_DCPARF, GCY->GCY_DATALT) )

       nDiaTot+= TMPDES->GD7_QTDDES

        nDiaM := Val(Substr(Dtos(LastDay(stod(TMPDES->GD7_DATDES))),7,2))
        If nDiaTot > nDiaM .Or. TMPDES->GD7_QTDDES > nDias+1
        	lRet := .F.
   			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0239 + " [" + TMPDES->GD7_CODDES + "] " + STR0240 + " [" + AllTrim(Str(Iif(nDiaTot > nDiaM,nDiaM, nDias+1))) + "]. " + chr(10) //"NRSEQG - "###"Guia nใo faturada. Quantidade mแxima do procedimento"###"ultrapassou"
 		EndIf
 			TMPDES->(DbSkip())
	 		Loop
 	ElseIf TMPDES->GA7_QTDMAX <> 9999 .And. (aScan(aVetPro, TMPDES->GD7_CODDES) == 0)//Quantidade Mแxima de Procedimentos Permitida

		aAdd(aVetPro, TMPDES->GD7_CODDES) //Adiciona no array pra nao verficar mais que uma vez o mesmo c๓digo de procedimento

		cSql := "SELECT GD7.GD7_FILIAL, GD7.GD7_CODDES, GD7.GD7_CODATO, SUM(GD7.GD7_QTDDES) TOTAL "
		cSql += "FROM " + RetSqlName("GD7") + " GD7 "
		cSql += "WHERE GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "'  AND GD7.GD7_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' "
        cSql +=  "AND  GD7.GD7_CODDES = '" + TMPDES->GD7_CODDES + "' "
		cSql += "GROUP BY GD7.GD7_FILIAL, GD7.GD7_CODDES, GD7.GD7_CODATO  "

		cSql := ChangeQuery(cSql)
		TcQuery cSql New Alias "TMPQTD"

		DbSelectArea("TMPQTD")

		If TMPQTD->TOTAL > TMPDES->GA7_QTDMAX .And. !(GCZ->GCZ_CODPLA $ __cCodPac)// Se a Query trouxe algum resultado ้ porque ultrapassou a quantidade maxima
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0239 + " [" + TMPDES->GD7_CODDES + "] " + STR0240 + " [" + AllTrim(Str(TMPDES->GA7_QTDMAX)) + "]. " + chr(10) //"NRSEQG - "###"Guia nใo faturada. Quantidade mแxima do procedimento"###"ultrapassou"
		EndIf

		TMPQTD->(DbCloseArea())

	EndIf

	//Modalidade
	cSql := "SELECT GK5.GK5_FILIAL, GK5.GK5_CODMOD "
	cSql += "   FROM " + RetSqlName("GK5") + " GK5 "
	cSql += "   JOIN " + RetSqlName("GLT") + " GLT ON GLT.D_E_L_E_T_ <> '*' AND GLT.GLT_FILIAL = '" + xFilial("GLT") + "' "
	cSql += "    AND GLT.GLT_CODTPG = '" + GCZ->GCZ_CODTPG + "' AND GLT.GLT_CODMOD = GK5.GK5_CODMOD "
	cSql += "WHERE GK5.D_E_L_E_T_ <> '*' AND GK5.GK5_FILIAL = '" + xFilial("GK5") + "' AND GK5.GK5_CODPRO = '" + TMPDES->GD7_CODDES + "'"

	cSql := ChangeQuery(cSql)
	TcQuery cSql New Alias "TMPMOD"

	DbSelectArea("TMPMOD")
	DbGotop()

	If TMPMOD->(Eof())
		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0241 + " [" + TMPMOD->GK5_CODMOD + "] " + STR0242 + " [" + TMPDES->GD7_CODDES + "]. " + chr(10) //"NRSEQG - "###""Guia nใo faturada. Modalidade do atendimento"###" incompatํvel com o procedimento"
	EndIf

	TMPMOD->(DbCloseArea())

    DbSelectArea("GHD")
    DbSetOrder(1)
    If DbSeek(xFilial("GHD") + TMPDES->GD7_CODDES) // Se houver itens na GHD para o procedimento deve ser validado pois ha restricao de CBO
		cSql := "SELECT GHD_FILIAL "
		cSql += "FROM " + RetSqlName("GHD") + " GHD "
		cSql += "WHERE GHD.GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.D_E_L_E_T_ <> '*' AND GHD.GHD_CODPRO = '" + TMPDES->GD7_CODDES + "' AND "
		cSql += "     (GHD.GHD_CODCBO IN (SELECT GFR.GFR_CBOSUS "
		cSql += "                         FROM " + RetSqlName("GFR") + " GFR "
		cSql += "                         JOIN " + RetSqlName("GFP") + " GFP ON GFP.GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP.D_E_L_E_T_ <> '*' AND "
		cSql += "                                  GFP.GFP_CODESP = GFR.GFR_CDESPE AND GFP.GFP_CODCRM = '" + TMPDES->GD7_CODCRM + "' "
		cSql += "                         WHERE GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*') OR "
		cSql += "      GHD.GHD_CODCBO IN (SELECT GFR.GFR_CBOSUS "
		cSql += "                         FROM " + RetSqlName("GFR") + " GFR "
		cSql += "                         JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' AND "
		cSql += "                              GBJ.GBJ_CRM = '" + TMPDES->GD7_CODCRM + "' AND "
		cSql += "                             (GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE OR GBJ.GBJ_ESPEC2 = GFR.GFR_CDESPE OR GBJ.GBJ_ESPEC3 = GFR.GFR_CDESPE) "
		cSql += "                         WHERE GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*')) "

		cSql := ChangeQuery(cSql)
		TcQuery cSql New Alias "TMPCBO"

		DbSelectArea("TMPCBO")
		DbGotop()

	    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ Verifica se o ato corresponde ao anestesista                             ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    DbSelectArea("GMC")
	    DbSetOrder(1)//GMC_FILIAL+GMC_CODATO+GMC_IDEATI
	    If GMC->(MsSeek(xFilial("GMC")+TMPDES->GD7_CODATO)) .And. GMC->GMC_TIPATM == "5"

	         cSql := " SELECT GFR.GFR_CBOSUS "
	         cSqL += " FROM " + RetSqlName("GFR") + " GFR "
             cSqL += " JOIN "+RetSqlName("GBJ")+" GBJ ON GBJ.GBJ_FILIAL = '"+xFilial("GBJ")+"' "
             cSql += " AND GBJ.D_E_L_E_T_ <> '*' "
             cSql += " AND GBJ.GBJ_CRM = '"+TMPDES->GD7_CODCRM+"' "
             cSql += " AND (GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE "
             cSql += " OR GBJ.GBJ_ESPEC2 = GFR.GFR_CDESPE "
             cSql += " OR GBJ.GBJ_ESPEC3 = GFR.GFR_CDESPE) "
             cSql += " AND GFR_CBOSUS = '"+GetNewPar("MV_HSPCBAN","")+"' "

             cSql := ChangeQuery(cSql)
	       	 TcQuery cSql New Alias "TMPANE"

		     DbSelectArea("TMPANE")
		     DbGotop()

		     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Verifica se o CBOS do Profissional contempla o CBOS do procedimento      ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		     cSql := " SELECT GHD_FILIAL "
		     cSql += " FROM " + RetSqlName("GHD")
             cSql += " WHERE GHD_CODPRO = '"+TMPDES->GD7_CODDES+"' "
             cSql += " AND GHD_CODCBO IN ( "
             cSql += "    SELECT GFR.GFR_CBOSUS "
             cSql += "    FROM "+RetSqlName("GFR")+" GFR "
             cSql += "    JOIN "+RetSqlName("GBJ")+" GBJ ON GBJ.GBJ_FILIAL = '"+xFilial("GBJ")+"' "
             cSql += "    AND GBJ.D_E_L_E_T_ <> '*' "
             cSql += "    AND GBJ.GBJ_CRM = '"+TMPDES->GD7_CODCRM+"' "
             cSql += "    AND (GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE "
             cSql += "    OR GBJ.GBJ_ESPEC2 = GFR.GFR_CDESPE "
             cSql += "    OR GBJ.GBJ_ESPEC3 = GFR.GFR_CDESPE) "
             cSql += " WHERE GFR.GFR_FILIAL = '  ' AND GFR.D_E_L_E_T_ <> '*')"

             cSql := ChangeQuery(cSql)
	       	 TcQuery cSql New Alias "TMPANE2"

		     DbSelectArea("TMPANE2")
		     DbGotop()

		     If TMPANE->(Eof()) .And. TMPANE2->(Eof())
			    lRet := .F.
			    cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0246 + STR0247 + " [" + TMPDES->GD7_CODDES + "] " + chr(10) //"NRSEQG - "###"Guia nใo faturada. CBO"###"do profissional ้ incompatํvel com o procedimento"
		     EndIf

		     TMPANE->(DbCloseArea())
		     TMPANE2->(DbCloseArea())

        Else
	        //Valida็ใo do CBO
		    If TMPCBO->(Eof())
			    lRet := .F.
			    cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0246 + STR0247 + " [" + TMPDES->GD7_CODDES + "] " + chr(10) //"NRSEQG - "###"Guia nใo faturada. CBO"###"do profissional ้ incompatํvel com o procedimento"
		    EndIf
	    EndIf

		TMPCBO->(DbCloseArea())
	EndIf

If !lPAIH.or.TMPDES->GD7_CODDES==GCZ->GCZ_CODDES
	//Valida CID
	DbSelectArea("GHH")
	DbSetOrder(1)//GHH_FILIAL+GHH_CODPRO+GHH_CODCID
	If DbSeek(xFilial("GHH") + TMPDES->GD7_CODDES)
		If Empty(GCY->GCY_CIDINT)
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0243 + chr(10) //"NRSEQG - "###"Guia nใo faturada. Preencha o campo 'CID Atend.' no atendimento."
		ElseIf !DbSeek(xFilial("GHH") + TMPDES->GD7_CODDES + GCY->GCY_CIDINT)
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0244 + " [" + GCY->GCY_CIDINT + "] " + STR0245 + " [" + TMPDES->GD7_CODDES + "]. " + chr(10) //"NRSEQG - "###"Guia nใo faturada. CID"###"informada ้ imcompatํvel com o procedimento"
		EndIf
	   	If !Empty(GCY->GCY_DATALT)
		   	If Empty(GCY->GCY_CIDALT)
		    	lRet := .F.
		    	cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0256 + chr(10) //"NRSEQG - "###"Guia nใo faturada. Preencha o campo 'CID Alta' no atendimento."
		   	ElseIf !DbSeek(xFilial("GHH") + TMPDES->GD7_CODDES + GCY->GCY_CIDALT)
		    	lRet := .F.
		    	cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0244 + " [" + GCY->GCY_CIDALT + "] " + STR0245 + " [" + TMPDES->GD7_CODDES + "]. " + chr(10) //"NRSEQG - "###"Guia nใo faturada. CID"###"informada ้ imcompatํvel com o procedimento"
		   	EndIf
		EndIf
	EndIf
EndIf

DbSelectArea("GK6")
DbSetOrder(1) //GK6_FILIAL+GK6_CODPRO+GK6_CODINR
If DbSeek(xFilial("GK6") + TMPDES->GD7_CODDES + "02") //Valor "chumbado" porque at้ o momento o SUS nใo sugeriu uma parametriza็ใo
	If Empty(TMPDES->GBJ_CODCNS)
		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0248 + " [" + TMPDES->GD7_CODCRM + "] " + STR0249 + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"nใo estแ preenchido no cadastro de profissionais."
	ElseIF lVldCns
		If !Hs_VldCns(TMPDES->GBJ_CODCNS)
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0248 + " [" + TMPDES->GD7_CODCRM + "] " + " invแlido" + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"Invแlido"
		EndIf
	EndIf

//Numero da Autoriza็ใo
If Empty(GCZ->GCZ_NRGUIA)
	lRet := .F.
	cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0250 + chr(10) //"NRSEQG - "###"Guia nใo faturada. Numero da autoriza็ใo nใo estแ preenchido na guia."
EndIf

  EndIf
	If GCZ->GCZ_CODPLA $__cCodAIH
   		//CNES do Medico
   		If Empty(TMPDES->GBJ_CODCNS)
	    	lRet := .F.
	    	cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0248 + " [" + TMPDES->GD7_CODCRM + "] " + STR0249 + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNES do profissional"###"nใo estแ preenchido no cadastro de profissionais."
	   	EndIf
	EndIf
  TMPDES->(DbSkip())
 End
If !TMPDES->(Eof())
	lRet := .F.
	cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0216 + chr(10) //"NRSEQG - "###"Guia Nใo Faturada, c๓digo proดprio de procedimento nใo encontrado no cadastro de procedimentos do SUS"
EndIf

TMPDES->(DbCloseArea())
 If GCZ->GCZ_CODPLA $__cCodAIH
    If lVlCnsPac
 	cGbhCodCns := Hs_IniPadr("GBH",1,GCZ->GCZ_REGGER,"GBH_NUMCNS",,.F.)
 	cGd4CodCns := Hs_IniPadr("GD4",1,GCZ->GCZ_REGGER + GCZ->GCZ_CODPLA,"GD4_MATRIC",,.F.)

	IF !Hs_VldCns(Alltrim(cGbhCodCns)) .OR. !Hs_VldCns(Alltrim(cGd4CodCns))
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. CNS do paciente [" + GCZ->GCZ_REGGER + "] " + "invแlido" + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido"
 	EndIf
	EndIf
	If Empty(Iif(GCZ->(FieldPos("GCZ_NUMAIH")) > 0,GCZ->GCZ_NUMAIH,""))
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0255 + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo Num AIH."
	Else
		//Verifica se o Num de Aih ja foi digitado para outro paciente
		cSql := "SELECT GCZ.GCZ_FILIAL, COUNT(GCZ.GCZ_NUMAIH) TOTAIH "
		cSql += "FROM " + RetSqlName("GCZ") + " GCZ  "
		cSql += "WHERE GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NUMAIH = '" + GCZ->GCZ_NUMAIH + "' "
	    cSql += "AND GCZ.GCZ_REGATE <> '" + GCZ->GCZ_REGATE + "' "
	    cSql += "GROUP BY GCZ.GCZ_FILIAL "

		cSql := ChangeQuery(cSql)
		TcQuery cSql New Alias "TMPAIH"

		DbSelectArea("TMPAIH")
		DbGotop()

		If !TMPAIH->(Eof())
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nใo faturada. Num AIH informado ja foi atribuido a outro paciente." + chr(10) // "NRSEQG - "###"Guia nใo faturada. Num AIH atribuido a outro paciente."
	   	EndIf

	   	TMPAIH->(DbCloseArea())

		If !Empty(Iif(GCZ->(FieldPos("GCZ_AIHPOS")) > 0,GCZ->GCZ_AIHPOS,"")) .And. GCZ->GCZ_NUMAIH == GCZ->GCZ_AIHPOS
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nใo faturada. Num AIH igual ao Num de AIH Posterior." + chr(10) // "NRSEQG - "###"Guia nใo faturada. Num AIH igual ao Num de AIH Posterior."
		EndIf

		If !Empty(Iif(GCZ->(FieldPos("GCZ_AIHANT")) > 0,GCZ->GCZ_AIHANT,"")) .And. GCZ->GCZ_NUMAIH == GCZ->GCZ_AIHANT
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nใo faturada.Num AIH igual ao Num de AIH Anterior." + chr(10) // "NRSEQG - "###"Guia nใo faturada. Num AIH igual ao Num de AIH Anterior."
		EndIf

		If !Empty(Iif(GCZ->(FieldPos("GCZ_AIHANT")) > 0,GCZ->GCZ_AIHANT,"")) .And. !Empty(Iif(GCZ->(FieldPos("GCZ_AIHPOS")) > 0,GCZ->GCZ_AIHPOS,"")) .And. GCZ->GCZ_AIHPOS == GCZ->GCZ_AIHANT
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nใo faturada. Num AIH Posterior igual ao Num de AIH Anterior." + chr(10) // "NRSEQG - "###"Guia nใo faturada. Num AIH igual ao Num de AIH Anterior."
		EndIf

	EndIf
	If Empty(Iif(GCZ->(FieldPos("GCZ_TIPAIH")) > 0,GCZ->GCZ_TIPAIH,""))
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0257 + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo Tp Atend AIH."
   	EndIf

	If Empty(Iif(GCZ->(FieldPos("GCZ_MDPROC")) > 0,GCZ->GCZ_MDPROC,""))
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0258 + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo Mud. Proc."
   	EndIf

   	If Empty(Iif(GCZ->(FieldPos("GCZ_CRMAUT")) > 0,GCZ->GCZ_CRMAUT,""))
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nao faturada. Preencha o Medico Autorizador do Atendimento" + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo Num AIH."
	EndIf

	If Empty(GCZ->GCZ_DATAUT)
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nao faturada. Informe a Data de Autorizacao do Atendimento" + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo Num AIH."
	EndIf
   	If Empty(GCZ->GCZ_CODCRM)
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0260 + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo CRM Solicit. do atendimento"
   	EndIf

	If GCY->GCY_ACITRA == "1" .And. Empty(Iif(GCY->(FieldPos("GCY_CNASUS")) > 0,GCY->GCY_CNASUS,"")) .And. Empty(GCY->GCY_CODEMP)
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + "Guia nao faturada. Informe Todos os Dados da Aba Acidente de Trabalho" + chr(10) // "NRSEQG - "###"Guia nใo faturada. Preencha o campo Num AIH."
	EndIf

 	If GCY->GCY_ACITRA == "1" .And. Empty(Hs_IniPadr("GBH",1,GCZ->GCZ_REGGER,"GBH_PROFIS",,.F.))
  		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. Cod Profis do paciente [" + GCZ->GCZ_REGGER + "] " + "nao preenchido" + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido"
 	EndIf

  	DbSelectArea("GLZ")
	DbSetOrder(1)//GLZ_FILIAL+GLZ_CODPRO+GLZ_CODDET
	If DbSeek(xFilial("GLZ") + GCZ->GCZ_CODDES + '004') // VERIFICO O CODIGO 004 POIS ESTE CODIGO CARACTERIZA COMO PERMANECIA A MAIOR
		DbSelectArea("GA7")
  		DbSetOrder(1)
 		DbSeek(xFilial("GA7") + GCZ->GCZ_CODDES)
 		If GA7->GA7_PERMAN > 0
 			nQtdPerm := GA7->GA7_PERMAN * 2
 			If GA7->GA7_PERMAN <> 99
 				cDiaria := "'" + cDiaria + "'"
 				cDiaria := StrTran(cDiaria," ","")
 				cDiaria := StrTran(cDiaria,"/","','")
 				cDiaria := StrTran(cDiaria,"\","','")

 				cSql := "SELECT GD7.GD7_FILIAL,GD7.GD7_CODLOC,SUM(GD7.GD7_QTDDES) TOTAL "
		   		cSql += "FROM " + RetSqlName("GD7") + " GD7 "
		   		cSql += "LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_FILIAL = '" + xFilial("GMC") + "' "
				cSql += "AND GMC.GMC_CODATO = GD7.GD7_CODATO "
				cSql += "WHERE GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "'  AND GD7.GD7_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' "
   				cSql +=  "AND (GD7.GD7_CODATO = '  ' OR GMC.GMC_TIPATM = '0') AND GD7.GD7_CODDES LIKE '080201%' AND GD7.GD7_CODDES NOT IN (" + cDiaria + ")"
				cSql += "GROUP BY GD7.GD7_FILIAL,GD7.GD7_CODLOC "

				cSql := ChangeQuery(cSql)
				TcQuery cSql New Alias "TMPDIA"

				DbSelectArea("TMPDIA")

				If !TMPDIA->(Eof())
					nDiaria := TMPDIA->TOTAL  -  nQtdPerm
					If nDiaria >0
						DbSelectArea("GD7")
  						DBSetOrder(7) //GD7_FILIAL+GD7_NRSEQG+GD7_CODDES+DTOS(GD7_DATDES)+GD7_HORDES
				    	DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG + '0802010199')

				    	If GD7 ->(Eof())
						    	aRValDes := HS_RValPr('0802010199', GCZ->GCZ_CODPLA, TMPDIA->GD7_CODLOC, Iif(Empty(GCY->GCY_HORALT),Time(),GCY->GCY_HORALT) , IIf(GCY->GCY_ATENDI == "2", "1", "0"), cMedPadr,, {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE}, .F., Iif(Empty(GCY->GCY_DATALT),dDataBase,GCY->GCY_DATALT) )
					    		If !aRValDes[1] == 0
		 		   					lRet := .F.
									cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + aRValDes[5] + " [0802010199]" + " invแlido" + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"Invแlido"
                                EndIf
                        EndIf
                     EndIf
                EndIf
                TMPDIA->(DbCloseArea())
            EndIf
         EndIF
    EndIf
 EndIf

lRet := IIF(!Fs_VldApac(@cMsgErro),.F.,lRet)

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ Validacoes especificas do Apac                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12 - APAC                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fs_VldApac(cMsgErro)
Local lRet := .T.
Local aArea := getArea()
Local cGbhCodCns := ""//Hs_IniPadr("GBH",1,GCZ->GCZ_REGGER,"GBH_CODCNS",,.F.)
Local cGk7Solici := ""
Private cMedRes := "", dDatSoc := CtoD("")
Private cMedAut := "", dDatAut := CtoD("")

If !(GCZ->GCZ_CODPLA $ __cCodPAC)
	RestArea(aArea)
	Return(lRet)
EndIf

cGbhCodCns := Hs_IniPadr("GBH",1,GCZ->GCZ_REGGER,"GBH_NUMCNS",,.F.)

If lVldCns
	If !Hs_VldCns(cGbhCodCns)
		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. CNS do paciente [" + GCZ->GCZ_REGGER + "] " + "invแlido" + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido"
	EndIf
EndIf

If !Empty(cGk7Solici := Hs_SolApac(GCZ->GCZ_REGATE,"GK7_SOLICI",{{'cMedRes', 'GK7_CRMRES'},{'dDatSoc', 'GK7_DATSOC'},;
																																																																   {'cMedAut', 'GK7_CRMAUT'}, {'dDatAut', 'GK7_DTAUTO'}}))
	If Empty(dDatSoc)
		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. Data da Solicita็ใo da APAC [" + cGk7Solici + "] " + " nใo estแ preenchido no cadastro de solicita็๕es APAC." + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido"
	EndIf

	If Empty(dDatAut)
		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. Data da Autoriza็ใo da APAC [" + cGk7Solici + "] " + " nใo estแ preenchido no cadastro de solicita็๕es APAC." + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido"
	EndIf

	DbSelectArea("GBJ")
	DbSetOrder(1) //GBJ_FILIAL+GBJ_CRM
	If DbSeek(xFilial("GBJ")+cMedRes)
		If lVldCns
			If !Hs_VldCns(GBJ->GBJ_CODCNS)
				lRet := .F.
				cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + "Guia nใo faturada. CNS do profissional [" + GBJ->GBJ_CRM + "] " + "responsแvel pelo paciente na Solicita็ใo de APAC ้ invแlido." + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido."
			EndIf
		EndIf

		If Empty(GBJ->GBJ_CIC)
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. CPF do profissional [" + GBJ->GBJ_CRM + "] " +"responsแvel pelo paciente na Solicita็ใo de APAC "+ STR0249 + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNES do profissional"###"nใo estแ preenchido no cadastro de profissionais."
		EndIf

	EndIf

	If DbSeek(xFilial("GBJ")+cMedAut)
		If lVldCns
			If !Hs_VldCns(GBJ->GBJ_CODCNS)
				lRet := .F.
				cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. CNS do profissional [" + GBJ->GBJ_CRM + "] " + " autorizador na Solicita็ใo de APAC ้ invแlido." + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNS do profissional"###"invแlido."
			EndIf
		EndIf

		If Empty(GBJ->GBJ_CIC)
			lRet := .F.
			cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. CPF do profissional [" + GBJ->GBJ_CRM + "] " +"autorizador na Solicita็ใo de APAC "+ STR0249 + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNES do profissional"###"nใo estแ preenchido no cadastro de profissionais."
		EndIf
	EndIf

	//Nใo faturas se houver sess๕es pendentes
	If !Hs_VldSess(GCZ->GCZ_REGATE," GM8_DATAGE <= '"+DtoS(dDtLimite)+"' ")
		lRet := .F.
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. Atendimento  [" + GCZ->GCZ_REGATE + "] " +"possui sess๕es agendadas que nใo foram realizadas at้ a data." + chr(10) //"NRSEQG - "###"Guia nใo faturada. CNES do profissional"###"nใo estแ preenchido no cadastro de profissionais."
	EndIf
Else
	lRet := .F.
	cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " Guia nใo faturada. Solicita็ใo de Apac nใo encontrada." + chr(10)
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_FatAIH    ณ Autor ณSueli C. Santos        ณ Data ณ13.04.2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Grava nas tabelas GE5/GE6/GE7                           		 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                                       		 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HS_FatAIH    							                 	 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_FatAIH(cNrSeqG)
 Local aArea     	 := GetArea()
 Local cMsgErro  	 := ""
 Local nI := 0 ,nX := 0
 Local aPar			 := {}
 Local lAteSUS		 := .F. //Indica se o Modulo atende ao SUS.
 Local nTotPts :=0, nTPtPrc := 0
 Local nVlrPto := 0, nVlProc := 0 , nVlAnest := 0, nVlProf := 0
 Local aRatAih   := {}
 Local cCodAnt   := ""
 Local cDiaria := GetMv("MV_DIARUTI", , "")
 Local nDiaria := 0
 Local cMedPadr := GetMv('MV_CRMPADH')
 Local aRValDes := {}

 Default cNrSeqG := ""
 /* Valida ATENDIMENTO SUS*/
 If (lAteSUS := (GetMV("MV_ATESUS", , "N") == "S"))
 	aPar 	:= {{"MV_PCONSUS",""},{"MV_PSUSBPA",""},{"MV_PSUSPAC",""},{"MV_PSUSAIH",""}}
 	If !HS_VMVSUS(@aPar)
 		Return()
 	EndIf
 EndIf


 	If Alias() <> "GCZ"
   		DBSelectArea("GCZ")
  	EndIf

 	If IndexOrd() <> 1
   		DBSetOrder(1)
  	EndIf

  	DBSeek(xFilial("GCZ") + cNrSeqG)

  	DbselectArea("GCY")
  	DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
  	DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

  	DBSelectArea("GCZ")


	If !(lAteSUS .And. GCY->GCY_ATENDI == "0" .And. GCZ->GCZ_CODPLA $ __cCodAIH)
		Return(nil)
	EndIf

 		DbSelectArea("GD7")
 		DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES
 		DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG)

 		cCodAnt := ""
 	 	While !eof() .and. GD7->GD7_FILIAL + GD7->GD7_NRSEQG == xFilial("GD7") + GCZ->GCZ_NRSEQG

 			If !Empty(GD7->GD7_CODATO)
 			   	DbSelectArea("GA7")
  				DbSetOrder(1)
  				If DbSeek(xFilial("GA7") + GD7->GD7_CODDES)
	  				While !GA7->(Eof()) .And. xFilial("GA7") == GA7->GA7_FILIAL .And. GA7->GA7_CODPRO == GD7->GD7_CODDES
	 		        	DbSelectArea("GMV")
	     				DbSetOrder(1)

	     		   		If DbSeek(xFilial("GMV") + GA7->GA7_CODSUS)
	     		   			DbSelectArea("GMC")
			     			DbSetOrder(1)
			     			If DbSeek(xFilial("GMC") + GD7->GD7_CODATO)
								If  cCodAnt <> GD7->GD7_CODDES
		     						nTPtPrc := Iif(GMC->GMC_TIPATM  == '0' .Or. GMC->GMC_TIPATM == '5',Iif(GMC->GMC_TIPATM  == '5',0,GMV->GMV_QTDPTS), GMV->GMV_QTDPTS * GD7->GD7_COEFAM)
			     				Else
			     					nTPtPrc += Iif(GMC->GMC_TIPATM  == '0' .Or. GMC->GMC_TIPATM  == '5',Iif(GMC->GMC_TIPATM == '5',0,GMV->GMV_QTDPTS), GMV->GMV_QTDPTS * GD7->GD7_COEFAM)
			     				EndIf

							    aAdd(aRatAih,{GD7->GD7_SEQDES,GD7->GD7_CODDES, GD7->GD7_CODCRM, GMC->GMC_TIPATM, GMV->GMV_QTDPTS,GD7->GD7_COEFAM, GMV->GMV_VLSRVP, GMV->GMV_VLSRVP *0.3 })
							    cCodAnt := GD7->GD7_CODDES
							 EndIf
			   	 		EndIf
	 			 	GA7->(dbSkip())
	 			  	Enddo
 			  	EndIf

  	 		EndIf

   	 		GD7->(dbSkip())
   	 	Enddo

   	  	If len(aRatAih)>0
   	 		     For nI :=1 To Len(aRatAih)
   	 		       	nVlProc += Iif(aRatAih [nI][4] == '0',aRatAih [nI][5],0)
   	 		       	nVlProf += Iif(aRatAih [nI][4] == '0',aRatAih [nI][7],0)
   	 		       	nVlAnest+= Iif(aRatAih [nI][4] == '5',aRatAih [nI][8],0)
   	 		     Next

	   	 		 nVlrPto := nVlProf - nVlAnest

	   	 		  For nX :=1 To Len(aRatAih)
	   	 		 	If aRatAih [nX][4] <> '5'
	   	 		   		nTotPts += Iif(aRatAih [nX][4] == '0',nVlProc, nVlProc * aRatAih [nX][6])
	   	 		   	EndIf
	   	 		 Next

	   	 		 nVlrPto := nVlrPto / nTotPts

	   	 		 For nX :=1 To Len(aRatAih)
	   	 		 	If aRatAih [nX][4] <> '5'
	   	 		 		aRatAih [nX][5] := Iif(aRatAih [nX][4] == '0',nVlProc, nVlProc * aRatAih [nX][6])
	   	 		   		aRatAih [nX][8] := aRatAih [nX][5] * nVlrPto
	   	 		   	EndIf
	   	 		 Next

				For nI :=1 To Len(aRatAih)
					DbselectArea("GD7")
	   	 	  	 	DBSetOrder(1) //GD7_FILIAL+GD7_SEQDES
	 				DbSeek(xFilial("GD7") + aRatAih[nI][1])
	   	 	   	  		RecLock ("GD7", .F.)
		   	 				GD7->GD7_VALREP := aRatAih[nI][8]
			   	 			GD7->GD7_VALREB := aRatAih[nI][8]
			   	 			GD7->GD7_VALDES := aRatAih[nI][8]
			   	 			GD7->GD7_VCUSOP := Iif(aRatAih [nI][4] == '0',GD7->GD7_VCUSOP,0)
			   	 			GD7->GD7_QTDCHP := Iif(aRatAih [nI][4] == '0',GD7->GD7_QTDCHP,0)
		   	 			MsUnlock ()
	   	 		Next nI
	 		EndIf

        DbSelectArea("GLZ")
  		DbSetOrder(1)//GLZ_FILIAL+GLZ_CODPRO+GLZ_CODDET
		If DbSeek(xFilial("GLZ") + GCZ->GCZ_CODDES + '004') // VERIFICO O CODIGO 004 POIS ESTE CODIGO CARACTERIZA COMO PERMANECIA A MAIOR
	   		DbSelectArea("GA7")
  			DbSetOrder(1)
 			DbSeek(xFilial("GA7") + GCZ->GCZ_CODDES)
 			If GA7->GA7_PERMAN > 0
 				nQtdPerm := GA7->GA7_PERMAN * 2
 				If GA7->GA7_PERMAN <> 99
 					cDiaria := "'" + cDiaria + "'"
 					cDiaria := StrTran(cDiaria," ","")
 					cDiaria := StrTran(cDiaria,"/","','")
 					cDiaria := StrTran(cDiaria,"\","','")

 					cSql := "SELECT GD7.GD7_FILIAL,GD7.GD7_CODLOC,SUM(GD7.GD7_QTDDES) TOTAL "
			   		cSql += "FROM " + RetSqlName("GD7") + " GD7 "
			   		cSql += "LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_FILIAL = '" + xFilial("GMC") + "' "
					cSql += "AND GMC.GMC_CODATO = GD7.GD7_CODATO "
					cSql += "WHERE GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "'  AND GD7.GD7_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' "
   					cSql += "AND (GD7.GD7_CODATO = '  ' OR GMC.GMC_TIPATM = '0') AND GD7.GD7_CODDES LIKE '080201%' AND GD7.GD7_CODDES NOT IN (" + cDiaria + ")"
					cSql += "GROUP BY GD7.GD7_FILIAL,GD7.GD7_CODLOC "

					cSql := ChangeQuery(cSql)
					TcQuery cSql New Alias "TMPDIA"

					DbSelectArea("TMPDIA")

					If !TMPDIA->(Eof())
						nDiaria := TMPDIA->TOTAL  -  nQtdPerm
						If nDiaria >0
							DbSelectArea("GD7")
  							DBSetOrder(7) //GD7_FILIAL+GD7_NRSEQG+GD7_CODDES+DTOS(GD7_DATDES)+GD7_HORDES
					    	DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG + '0802010199')

					    	If GD7->(Eof())
						    	aRValDes := HS_RValPr('0802010199', GCZ->GCZ_CODPLA, TMPDIA->GD7_CODLOC, Iif(Empty(GCY->GCY_HORALT),Time(),GCY->GCY_HORALT) , IIf(GCY->GCY_ATENDI == "2", "1", "0"), cMedPadr,, {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE}, .F., Iif(Empty(GCY->GCY_DATALT),dDataBase,GCY->GCY_DATALT) )
					    		If aRValDes[1] == 0
		 		   					M->GD7_SEQDES := HS_VSxeNum("GD7", "M->GD7_SEQDES", 1)
		 		   					ConfirmSx8()

					    			Reclock("GD7",.T.)
					    			GD7->GD7_FILIAL := xFilial("GD7")
					    			GD7->GD7_CODLOC := TMPDIA->GD7_CODLOC
					    			GD7->GD7_DATDES := Iif(Empty(GCY->GCY_DATALT),dDataBase,GCY->GCY_DATALT)
					    			GD7->GD7_HORDES := Iif(Empty(GCY->GCY_HORALT),Time(),GCY->GCY_HORALT)
					    			GD7->GD7_QTDDES := nDiaria
					    			GD7->GD7_CODDES := '0802010199'
					    			GD7->GD7_COEDES := 1
					    			GD7->GD7_COEFAM := aRValDes[02][01][02]
								    GD7->GD7_VALDES := aRValDes[02][01][01]
								    GD7->GD7_VFILME := aRValDes[02][03]
								    GD7->GD7_VCUSOP := aRValDes[02][02]
								    GD7->GD7_PCUDES := aRValDes[03]
								    GD7->GD7_URGDES := aRValDes[02][14]
								    GD7->GD7_GLODES := IIf(aRValDes[04][01], "2", "0")
								    GD7->GD7_COECHP := aRValDes[02][10]
							        GD7->GD7_QTDCHP := aRValDes[2][11]
							        GD7->GD7_CODCRM := cMedPadr
							        GD7->GD7_CODESP := aRValDes[07]
							        GD7->GD7_PGTMED := aRValDes[9][1]
							        GD7->GD7_COECHM := aRValDes[9][aRValDes[11]]
							        GD7->GD7_REPAMB := aRValDes[9][aRValDes[10]]
							        GD7->GD7_CODPRE := aRValDes[14]
							        GD7->GD7_CODPRT := aRValDes[2][15]
							        GD7->GD7_DESPRT := aRValDes[2][18]
					    			GD7->GD7_NRSEQG := GCZ->GCZ_NRSEQG
					    		 	GD7->GD7_VALREP := nDiaria * aRValDes[9][14]
       								GD7->GD7_SEQDES := M->GD7_SEQDES
       								GD7->GD7_NRSEQG := GCZ->GCZ_NRSEQG
       								GD7->GD7_ORIDES := "0"
       								GD7->GD7_REGATE := GCY->GCY_REGATE
       								GD7->GD7_FATPAR := aRValDes[4][2]
							       	GD7->GD7_SLAUDO := "0"
							     	GD7->GD7_LOGARQ := HS_LogArq()
							     	GD7->GD7_DOPLER := "0"
							       	GD7->GD7_VLRCOS := aRValDes[2][24]
							       	GD7->GD7_DATFIM :=Iif(Empty(GCY->GCY_DATALT),dDataBase,GCY->GCY_DATALT)
							       	GD7->GD7_HORFIM := Iif(Empty(GCY->GCY_HORALT),Time(),GCY->GCY_HORALT)
							       	GD7->GD7_TABELA := aRValDes[2][20]
									MsUnLock()
								Endif
							EndIf
			   			EndIf
   					EndIf

				TMPDIA->(DbCloseArea())

 			EndIf
        EndIf
    EndIf

 RestArea(aArea)
Return(cMsgErro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    |HS_FatConv   ณ Autor ณSueli C. Santos        ณ Data ณ13.04.2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Grava nas tabelas GE5/GE6/GE7                           		 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                                       		 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HS_FatAIH    							                 	 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function HS_FatConv (cNrSeqG)
 Local aArea     	 := GetArea()
 Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")
 Local lFatConv := GetMv("MV_FATSES", , 0)  == 0  // 0 - Sessoes Agendamento ; 1 - Sessoes Atendidas
 Local nSessoes := 0
 Local cCodPro := ""

If (lAteSUS .And. GCZ->GCZ_CODPLA $ __cCodPAC)
	Return(nil)
EndIf

DbselectArea("GKB")
DbSetOrder(2)
DbSeek(xFilial("GKB") + GCZ->GCZ_REGGER)

If !GKB->(Eof())
	DbselectArea("GM8")
	DbSetOrder(13)
	DbSeek(xFilial("GM8") + GKB->GKB_SEQAGE)

	While  !GM8->(Eof()) .And. GM8->GM8_SEQAGE == GKB->GKB_SEQAGE

		If lFatConv
			If GM8->GM8_STATUS == '1'
				cCodPro := GM8->GM8_CODPRO
				nSessoes := nSessoes +1
			ElseIf !Empty(GM8->GM8_MOTIVO) 		//.AND. HS_ExisDic({{"C", "GM7_AVISO"}}, .F.) // Caso esteja cancelado e o aviso de cancelamento seja posterior a 24 horas sera cobrado
				If HS_INIPADR("GM7", 1, GM8->GM8_MOTIVO, "GM7_AVISO",, .F.) == "1"
					nSessoes := nSessoes +1
				EndIf
			EndIf
		EndIf

		GM8->(dbSkip())
	End

	If lFatConv
	 	DbSelectArea("GD7")
	 	DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES
	 	DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG)

	 	 	If !eof() .and. GD7->GD7_FILIAL + GD7->GD7_NRSEQG + GD7->GD7_CODDES == xFilial("GD7") + GCZ->GCZ_NRSEQG + cCodPro
				RecLock ("GD7", .F.)
			   		GD7->GD7_QTDDES := nSessoes + 1
			   	MsUnlock ()
		   	EndIf
	EndIf
EndIf


 RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_EXCFAT ณ Autor ณGilson da Silva        ณ Data ณ26/02/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Exclui das tabelas GE5/GE6/GE7                      		  ณฑฑ
ฑฑณAlteracoesณ Daniel Peixoto   Excluir tabelas GG5/GG6/GG7 qdo pacote	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpA01 - Vetor com as Guias que serao Excluidas            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                              			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso   		 ณ HSPAHP12          				                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_EXCFAT()
Local aArea := GetArea()
Local cMsgErro := ""
Local nGuiaAtu := 0
Local nGuiaTot := Len(__aMarkBrow)
Local lExcDesp := IIf(GetMv("MV_EXCDFAT",,"S") == "N", .F., .T.)

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

If ! MsgYesNo(STR0095, STR0016) //"Confirma a Exclusao das Contas do Faturamento?  "###"Aten็ใo"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(nil)
EndIf

ProcRegua(nGuiaTot * 3)

For nGuiaAtu := 1 To nGuiaTot

	If Alias() <> "GCZ"
		DbSelectArea("GCZ")
	EndIf

	If IndexOrd() <> 1
		DbSetOrder(1)
	EndIf

	DbSeek(xFilial("GCZ") + __aMarkBrow[nGuiaAtu][1])

	If GCZ->GCZ_CANCEL == "1"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0092 + chr(10) //"NRSEQG - "###" estแ cancelada e nใo pode ser utilizada"
	ElseIf GCZ->GCZ_STATUS == '3'
		cMsgErro += STR0014 + ' ' + GCZ->GCZ_NRSEQG + ' ' + STR0107 + chr(10)//"NRSEQG - "###"nใo pode ser alterada por jแ estar atrelada a um lote"
	ElseIf GCZ->GCZ_STATUS <> "2"
		cMsgErro += STR0014 + ' ' + GCZ->GCZ_NRSEQG + ' ' + STR0097  + chr(10)//"NRSEQG - "###" nao encontra-se no Faturamento, nao sera possivel exclui-la"
	ElseIf GCZ->GCZ_STATUS == '9'
		cMsgErro += STR0014 + ' ' + GCZ->GCZ_NRSEQG + ' ' + "nใo pode ser alterada pois jแ foi utilizada para repasse particular" + chr(10)//"NRSEQG - "###
	ElseIf HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == "1" .And. !Empty(GCZ->GCZ_NUMORC)
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0168 + Chr(10) //"NRSEQG - " //"Para que seja possํvel a exclusใo de um faturamento particular, al้m da exclusใo da NF pelo Controle de Caixa, sใo necessแrias tamb้m a exclusใo do or็amento e do pedido. "
	ElseIf HS_CountTB("GCZ", "GCZ_REGATE = '" + GCZ->GCZ_REGATE + "' AND GCZ_CTAPAR > 1 ")  > 0
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0237  + chr(10)//"NRSEQG - " //" faturada parcialmente, nao sera possivel exclui-la."
	Else
		// Apagando Registros no Arquivo de Faturamento (Procedimento/Honorarios) e suas respectivas despesas G5 e G6 quando e um Pacote
		IncProc(STR0035 + " - " + GCZ->GCZ_NRSEQG) // "Excluindo Procedimentos, Guia"

		Begin Transaction

		//Limpa as despesas que nao sao de Pacotes
		If lExcDesp
			HS_ExluiDes(GCZ->GCZ_NRSEQG)
			FS_ExluiPct(GCZ->GCZ_NRSEQG)
		EndIf

		//Atualiza Status e Data do Status Na Tabela de Guias
		DbSelectArea("GCZ")
		RecLock("GCZ",.F.)
		GCZ->GCZ_STATUS := "1"
		GCZ->GCZ_DATSTA := dDataBase
		GCZ->GCZ_DTGERA := CToD(" ")
		GCZ->GCZ_HRGERA := Space(Len(GCZ->GCZ_HRGERA))
		GCZ->GCZ_USGERA := Space(Len(GCZ->GCZ_USGERA))
		MsUnlock()

		End Transaction

	EndIf

Next

If !Empty(cMsgErro)
	HS_MsgInf(cMsgErro, STR0016, STR0130) //"Aten็ใo"###"Exclui Faturamento"
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณFS_GerPar ณ Autor ณGilson da Silva        ณ Data ณ03/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Grava nas tabelas GE5/GE6/GE7   Faturamento Parcial    		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                              					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                            														  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	   	 ณ HSPAHP12	                                               	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerPar(aColsInt)
Local aArea := GetArea(), nFieldGb := 0, nCont := 0, nRep := 0, nFaturadas := 0, cNRSeqG := ""
Local aGD5SeqDes := {}, aGD6SeqDes := {}, aGD7SeqDes := {}, aProcessa := {}, cMsgErro := ""
Local aGD7Replica	:= {}
Local aPar := {}, aInterc := {}
Local lAteSUS					:= .F. //Indica se o Modulo atende ao SUS.
Local cGe7SeqDes		:= ""
Local aProcApac  := {}

Private dDATINI  := CTOD("  /  /  ")
Private dDATFIN  := CTOD("  /  /  ")
Private cSeqPct  := 0

/* Valida ATENDIMENTO SUS*/
If (lAteSUS := (GetMV("MV_ATESUS", , "N") == "S"))
	aPar := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
	If !HS_VMVSUS(@aPar)
		Return()
	EndIf

	If (GCZ->GCZ_CODPLA $ aPar[2, 2] .Or. GCZ->GCZ_CODPLA $ aPar[3, 2] .Or. GCZ->GCZ_CODPLA $ aPar[4, 2])
			If !HS_VerGSUS(@cMsgErro)//Faz Verificacoes referentes ao codigo proprio
				HS_MsgInf(cMsgErro, STR0016, STR0131) //"Aten็ใo"###"Faturamento Parcial"
				Return(nil)
		EndIf
	EndIf

	If GCZ->GCZ_CODPLA $ aPar[4, 2] // AIH Conta Parcial
		If Empty(GCZ->GCZ_TPALTA)
			HS_MsgInf(STR0263, STR0016, STR0131) //"Para fechamento parcial de Guias com plano referente ao SUS AIH, ้ necessแrio o preenchimento do campo Tipo da Alta da Guia (GCZ_TPALTA)!""Aten็ใo"###"Faturamento Parcial"
			Return(nil)
		EndIf
	EndIf

EndIf

//Posiciona GBJ
GBJ->(dbSetOrder(1))
GBJ->(dbSeek(xFilial("GBJ") + GCZ->GCZ_CODCRM))

//POSICIONA TABELA DE CONVENIOS
GA9->(DBSetOrder(1))
GA9->(DbSeek(xFilial("GA9")+GCZ->GCZ_CODCON))

aProcessa := HS_P12SEL("P")//Verifica se existe alguma despesa de Mat/Med - Tax/Dia - Procedto zerada referente a esta Guia.

If aProcessa[1] .And. aProcessa[2] .And. aProcessa[3] .And. aProcessa[5][1] .And. aProcessa[5][2] .And. aProcessa[5][3] .Or.;
	(GCZ->GCZ_CODPLA $ __cCodBPA + "/" + __cCodPAC + "/" + __cCodAIH) //Nใo valida para o SUS

	If GCZ->GCZ_CODPLA $ __cCodAIH
		HS_FATAIH(GCZ->GCZ_NRSEQG)
	EndIf
	If Len(aColsInt) > 0 .And. !EMPTY(aColsInt[1, n_CodProI])
		HS_ExluiDes(GCZ->GCZ_NRSEQG)
		FS_ExluiPct(GCZ->GCZ_NRSEQG)

		//Tratamento do pacote nas despesas dos intervalos de intercorrencia
		For nCont := 1 To Len(aColsInt)
			aInterc := FS_RInterc(aColsInt, aColsInt[nCont, n_CodProI])
			dDatIni := aInterc[nCont, 2]
			dDatFin := aInterc[nCont, 4]

			FS_FatInt(aInterc, GCY->GCY_CODCRM)
			nFaturadas ++
		Next
	EndIf

	If !(GCZ->GCZ_CODPLA $ __cCodPAC) //Se for APAC nใo haverแ GE para Mat/Med e Tax/Dia
		// Gerando Registros no Arquivo de Faturamento (Mat/Med)
		DbSelectArea("GD5")
		DBSetOrder(2) //GD5_FILIAL+GD5_NRSEQG+DTOS(GD5_DATDES)
		DbSeek(xFilial("GD5") + GCZ->GCZ_NRSEQG)
		While !eof() .and. GD5->GD5_FILIAL + GD5->GD5_NRSEQG == xFilial("GD5") + GCZ->GCZ_NRSEQG

			If !EMPTY(GD5->GD5_SEQGE5) //Ja foi faturada por pacote - Intercorrencia
				nFaturadas ++
				DbSkip()
				Loop
			EndIf

			IncProc(STR0030 + " - " + GCZ->GCZ_NRSEQG)  //"Transferindo Mat/Med, Guia"

			If HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == '1' .And. GD5->GD5_FATPAR == '0'
				DbSkip()
				Loop
			EndIf

			If GD5->GD5_DATDES > dDtLimite  //Criar Vetor Com o Nr Seq. da Despesa
				AADD(aGD5SeqDes,GD5->GD5_SEQDES)
				DbSkip()
				Loop
			EndIf

			DbSelectArea("GE5")
			M->GE5_SEQDES := HS_VSxeNum("GE5", "M->GE5_SEQDES", 1)

			RecLock("GE5",.T.)
			For nFieldGb := 1 To GD5->(FCount())
				If !(GD5->(FieldName(nFieldGb)) $ "GD5_FILIAL/GD5_SEQDES/GD5_LOGARQ") .And. ValType("GE5->GE5" + SubStr(GD5->(FieldName(nFieldGb)), 4)) # "U"
					&("GE5->GE5" + SubStr(GD5->(FieldName(nFieldGb)), 4)) := GD5->(&(FieldName(nFieldGb)))
				EndIf
			Next

			GE5->GE5_FILIAL := xFilial("GE5")
			GE5->GE5_SEQDES := M->GE5_SEQDES
			GE5->GE5_LOGARQ := HS_LogArq()
			MsUnlock()

			DbSelectArea("GD5")
			RecLock("GD5", .F.)
			GD5->GD5_SEQGE5 := M->GE5_SEQDES
			MsUnLock()

			DbSelectArea("GD5")
			DBSetOrder(2) //GD5_FILIAL+GD5_NRSEQG+DTOS(GD5_DATDES)

			nFaturadas ++
			DbSkip()
		End

		// Gerando Registros no Arquivo de Faturamento (Taxas/Diarias)
		DbSelectArea("GD6")
		DBSetOrder(2) //GD6_FILIAL+GD6_NRSEQG+DTOS(GD6_DATDES)
		DbSeek(xFilial("GD6") + GCZ->GCZ_NRSEQG)
		While !eof() .and. GD6->GD6_FILIAL + GD6->GD6_NRSEQG == xFilial("GD6") + GCZ->GCZ_NRSEQG

			If !EMPTY(GD6->GD6_SEQGE6) //Ja foi faturada por pacote - Intercorrencia
				nFaturadas ++
				DbSkip()
				Loop
			EndIf

			IncProc(STR0031 + " - " + GCZ->GCZ_NRSEQG) //"Transferindo Taxas / Diarias, Guia"

			If HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == '1' .And. GD6->GD6_FATPAR == '0'
				DbSkip()
				Loop
			EndIf

			If GD6->GD6_DATDES > dDtLimite  //Criar Vetor Com o Nr Seq. da Despesa.
				AADD(aGD6SeqDes,GD6->GD6_SEQDES)
				DbSkip()
				Loop
			EndIf

			DbSelectArea("GE6")
			M->GE6_SEQDES := HS_VSxeNum("GE6", "M->GE6_SEQDES", 1)

			RecLock("GE6",.T.)
			For nFieldGb := 1 To GD6->(FCount())
				If !(GD6->(FieldName(nFieldGb)) $ "GD6_FILIAL/GD6_SEQDES/GD6_LOGARQ") .And. ValType("GE6->GE6" + SubStr(GD6->(FieldName(nFieldGb)), 4)) # "U"
					&("GE6->GE6" + SubStr(GD6->(FieldName(nFieldGb)), 4)) := GD6->(&(FieldName(nFieldGb)))
				EndIf
			Next

			GE6->GE6_FILIAL := xFilial("GE6")
			GE6->GE6_SEQDES := M->GE6_SEQDES
			GE6->GE6_LOGARQ := HS_LogArq()
			MsUnlock()

			DbSelectArea("GD6")
			RecLock("GD6", .F.)
			GD6->GD6_SEQGE6 := M->GE6_SEQDES
			MsUnLock()

			DbSelectArea("GD6")
			DBSetOrder(2) // GD6_FILIAL+GD6_NRSEQG+DTOS(GD6_DATDES)

			nFaturadas ++
			DbSkip()
		End
	EndIF

	// Gerando Registros no Arquivo de Faturamento (Procedimento/Honorarios)
	DbSelectArea("GD7")
	DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES
	DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG)
	While !eof() .and. GD7->GD7_FILIAL + GD7->GD7_NRSEQG == xFilial("GD7") + GCZ->GCZ_NRSEQG

		If !EMPTY(GD7->GD7_SEQGE7) //Ja foi faturada por pacote - Intercorrencia
			nFaturadas ++
			DbSkip()
			Loop
		EndIf

		IncProc(STR0032 + " - " + GCZ->GCZ_NRSEQG) //"Transferindo Procedimentos, Guia"

		If HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == '1' .And. GD7->GD7_FATPAR == '0'
			DbSkip()
			Loop
		EndIf

		If GD7->GD7_DATDES > dDtLimite  //Criar Vetor Com o Nr Seq. da Despesa.
			AADD(aGD7SeqDes,GD7->GD7_SEQDES)
			DbSkip()
			Loop
		ElseIf GD7->GD7_REPPAR == "1" // IIf(HS_ExisDic( {{"C","GD7_REPPAR"}} , .F. ),GD7->GD7_REPPAR == "1",.F.) Replica para a proxima conta
			AADD(aGD7Replica,GD7->GD7_SEQDES)
		EndIf
		//cGe7SeqDes := HS_VSxeNum("GE7", "M->GE7_SEQDES", 1)

		If !(GCZ->GCZ_CODPLA $ __cCodPAC) .Or. aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}) == 0//IIF(!Empty(aProcApac),aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}) == 0,.T.)
			cGe7SeqDes := HS_VSxeNum("GE7", "M->GE7_SEQDES", 1)
		Else
			cGe7SeqDes := aProcApac[aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}), 2]
		EndIf

		DbSelectArea("GD7")
		RecLock("GD7", .F.)
		GD7->GD7_SEQGE7 := cGe7SeqDes
		/* Grava os Relacionamentos UNICOS */
		FS_GravREL(lAteSUS, "GD7", GD7->GD7_CODDES, aPar) // Par(..., Procedimento)
		MsUnLock()

		If !(GCZ->GCZ_CODPLA $ __cCodPAC) .Or. aScan(aProcApac, {|aVet| aVet[1] ==  GD7->GD7_CODDES}) == 0
			aAdd(aProcApac, {GD7->GD7_CODDES, cGe7SeqDes})

			DbSelectArea("GE7")
			M->GE7_SEQDES := cGe7SeqDes

			RecLock("GE7",.T.)
			For nFieldGb := 1 To GD7->(FCount())
				If !(GD7->(FieldName(nFieldGb)) $ "GD7_FILIAL/GE7_SEQDES/GD7_LOGARQ") .And. ValType("GE7->GE7" + SubStr(GD7->(FieldName(nFieldGb)), 4)) # "U"
					&("GE7->GE7" + SubStr(GD7->(FieldName(nFieldGb)), 4)) := GD7->(&(FieldName(nFieldGb)))
				EndIf
			Next

			GE7->GE7_FILIAL := xFilial("GE7")
			GE7->GE7_CODCON := GCZ->GCZ_CODCON
			GE7->GE7_CODPRE := HS_RPreMed(GE7->GE7_CODCRM, GE7->GE7_CODLOC)
			GE7->GE7_SEQDES := M->GE7_SEQDES
			GE7->GE7_LOGARQ := HS_LogArq()
			MsUnlock()
		EndIf
		DbSelectArea("GD7")
		DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES

		nFaturadas ++
		DbSkip()
	End

	If nFaturadas > 0
		RecLock("GCZ", .F.)    //ATUALIZA STATUS E DATA DO STATUS NA GUIA QUE ESTA SENDO FATURADA
		GCZ->GCZ_STATUS := "2"
		GCZ->GCZ_DATSTA := dDataBase
		GCZ->GCZ_DCPARF := dDtLimite //GCZ->GCZ_DATSTA
		MsUnlock()

		cNRSeqG := FS_GERGUIA()

		DbSelectArea("GD5")
		DBSetOrder(1) //GD5_FILIAL+GD5_SEQDES
		For nCont := 1  To Len(aGD5SeqDes)
			If DbSeek(xFilial("GD5") + aGD5SeqDes[nCont])
				RecLock("GD5",.F.)   // Regrava o Nr da Nova Guia para as Despesas com a Data Limite Superior a Informada.
				GD5->GD5_NRSEQG := cNRSEQG
				MsUnlock()
			EndIf

		Next

		DbSelectArea("GD6")
		DBSetOrder(1) //GD6_FILIAL+GD6_SEQDES
		For nCont := 1  To Len(aGD6SeqDes)
			If DbSeek(xFilial("GD6") + aGD6SeqDes[nCont])
				RecLock("GD6",.F.)   // Regrava o Nr da Nova Guia para as Despesas com a Data Limite Superior a Informada.
				GD6->GD6_NRSEQG := cNRSEQG
				MsUnlock()
			EndIf
		Next

		DbSelectArea("GD7")
		DBSetOrder(1) //GD7_FILIAL+GD7_SEQDES
		For nCont := 1  To Len(aGD7SeqDes)
			If DbSeek(xFilial("GD7") + aGD7SeqDes[nCont])
				RecLock("GD7",.F.)   // Regrava o Nr da Nova Guia para as Despesas com a Data Limite Superior a Informada.
				GD7->GD7_NRSEQG := cNRSEQG
				MsUnlock()
			EndIf
		Next

		If Len(aGD7Replica) > 0
			For nRep := 1 to Len(aGD7Replica)
				DbSelectArea("GD7")
				DBSetOrder(1) //GD7_FILIAL+GD7_SEQDES
				If DbSeek(xFilial("GD7") + aGD7Replica[nRep])
					RegToMemory("GD7", .F.)

					M->GD7_NRSEQG := cNRSEQG
					M->GD7_SEQDES := HS_VSxeNum("GD7", "M->GD7_SEQDES", 1)

					RecLock("GD7",.T.)
						For nFieldGb := 1 To GD7->(FCount())
							&("GD7->GD7" + SubStr(GD7->(FieldName(nFieldGb)), 4)) := M->(&(FieldName(nFieldGb)))
						Next
						GD7->GD7_FILIAL := xFilial("GE7")
						GD7->GD7_DATDES := dDataBase
						GD7->GD7_HORDES := Time()
						GD7->GD7_SEQGE7 := SPACE(TamSx3("GD7_SEQGE7")[1])
						GD7->GD7_LOGARQ := HS_LogArq()
					MsUnlock()
				EndIf
			Next
		EndIf
		HS_MsgInf(STR0225, STR0016, STR0131) //"Faturamento Parcial terminado com sucesso."
		If FindFunction("HS_PRPENEN")
			HS_PRPENEN(GCZ->GCZ_REGATE)  // Verifica medicamentos nใo administrados e nใo devolvidos
		EndIf
	Else
		MsgAlert(STR0093) //"Nao encontrou Despesa para Faturar"
	EndIf
Else
	cMsgErro += STR0014 + ' ' + GCZ->GCZ_NRSEQG + chr(10)//"NRSEQG - "###"  NRGUIA - "
	If !aProcessa[1]
		cMsgErro += STR0113  + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med Com o Valor Zerado"
	EndIf

	If !aProcessa[2]
		cMsgErro += STR0114  + chr(10)//"Guia Nใo Faturada, existe despesa de Tax/Dia Com o Valor Zerado"
	EndIf

	If !aProcessa[3]
		cMsgErro += STR0115  + chr(10)//"Guia Nใo Faturada, existe despesa de Procedto Com o Valor Zerado"
	EndIf

	If !aProcessa[5][1]
		cMsgErro += STR0219 + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med com o Valor menor que o Desconto"
	EndIf

	If !aProcessa[5][2]
		cMsgErro += STR0220 + chr(10)//"Guia Nใo Faturada, existem despesas de Tax/Dia com o Valor menor que o Desconto"
	EndIf

	If !aProcessa[5][3]
		cMsgErro += STR0221 + chr(10)//"Guia Nใo Faturada, existem despesas de Procedto com o Valor menor que o Desconto"
	EndIf

	HS_MsgInf(cMsgErro, STR0016, STR0131) //"Aten็ใo"###"Faturamento Parcial"
EndIf


 RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณFS_GERGUIAณ Autor ณGilson da Silva        ณ Data ณ03/03/2005     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณGera Nova Guia para as Despesas que nao foram Gerado Faturamento ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ NENHUM	                   						                     				       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ NIL		                                           									       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso 	    ณHSPAHP12                                   													 				    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GERGUIA()
 Local aArea   := GetArea()

 RegToMemory("GCZ", .F.)

 M->GCZ_NRSEQG := HS_VSxeNum("GCZ", "M->GCZ_NRSEQG", 1)

 If GCZ->GCZ_CANCEL == "1"
 	MsgStop(STR0014 + '  ' + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + '  ' + STR0092,STR0016) //"NRSEQG - "###"  NRGUIA - "###" estแ cancelada e nใo pode ser utilizada"###"Aten็ใo"
 	Return(nil)
 EndIf

 DbSelectArea("GCZ")
 RecLock("GCZ", .T.)
  HS_GrvCpo("GCZ")
  GCZ->GCZ_NRSEQG := M->GCZ_NRSEQG
  GCZ->GCZ_CTAPAR := GCZ->GCZ_CTAPAR + 1
  GCZ->GCZ_DCPARI := IIF(M->GCZ_DCPARF == dDataBase, M->GCZ_DCPARF, M->GCZ_DCPARF + 1)
  GCZ->GCZ_DCPARF := CTOD(" / / ")
  GCZ->GCZ_STATUS := "0"
  GCZ->GCZ_DATSTA := dDataBase
  GCZ->GCZ_LOGARQ := HS_LOGARQ()
 		GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
   GCZ->GCZ_FILATE := cFilAnt
  //Controla tipo de APAC
  If GCZ->GCZ_CODPLA $ __cCodPac .And. GCZ->GCZ_TPAPAC == "1"
   GCZ->GCZ_TPAPAC := "2"
  EndIf
 MsUnLock()

 RestArea(aArea)
Return(M->GCZ_NRSEQG)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ FS_FILTROณ Autor ณGilson da Silva        ณ Data ณ25/02/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Monta o Filtro para a Tabela GCZ  			               					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ EXPC1 = Filtro                                  									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Filtro                                       												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12 				                                           	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Filtro()

 cFilP12 := ""
 cFilP12 := "GCZ_FILIAL = '" + xFilial("GCZ") + "' AND D_E_L_E_T_ <> '*'"
 cFilP12 := cFilP12 + " And GCZ_CODCON = '" + cCodConv + "'"

 cGATCodCon  := cCodConv

 If !Empty(cPlaIni)
 	cFilP12 := cFilP12 + " And GCZ_CODPLA >= '" + cPlaIni + "'"
 EndIf

 If !Empty(cPlaFin)
 	cFilP12 := cFilP12 + " And GCZ_CODPLA <= '" + cPlaFin + "'"
 EndIf

 If !Empty(cGuiaIni)
 	cFilP12 := cFilP12 + " And GCZ_NRGUIA >= '" + cGuiaIni + "'"
 EndIf

 If !Empty(cGuiaFin)
 	cFilP12 := cFilP12 + " And GCZ_NRGUIA <= '" + cGuiaFin + "'"
 EndIf

 If !Empty(cGuiaSeqI)
 	cFilP12 := cFilP12 + " And GCZ_NRSEQG >= '" + cGuiaSeqI + "'"
 EndIf

 If !Empty(cGuiaSeqF)
 	cFilP12 := cFilP12 + " And GCZ_NRSEQG <= '" + cGuiaSeqF + "'"
 EndIf

 If !Empty(cTpGuia)
 	cFilP12 := cFilP12 + " And GCZ_CODTPG = '" + cTpGuia + "'"
 EndIf

 cFilP12 += " And GCZ_CANCEL <> '1'"

 If !EMpty(dDtAteIni)
  cFilP12 += " AND GCZ_DATATE >= '" + Dtos(dDtAteIni) + "'"
 EndIf

 If !EMpty(dDtAteFin)
  cFilP12 += " AND GCZ_DATATE <= '" + Dtos(dDtAteFin) + "'"
 EndIf

 If !Empty(cCodLoc)
 	cFilP12 += " AND GCZ_LOCATE = '" + cCodLoc + "'"
 EndIf

 If !Empty(cFilGuia)
 	cFilP12 += " AND GCZ_FILFAT = '" + cFilGuia + "'"
 EndIf

 If  nTpAtend == 1 // Hospitalar, nao respeita o Controle de Localizacao de Contas, visualiza todas as guias com status 0, 1, 2 e 3.
  cFilP12 += " AND GCZ_ATENDI = '0'" + IIf(nStatus <> 3, " And GCZ_STATUS IN " + IIf(nStatus == 1, "('0', '1', '2', '3')", "('4', '5', '6', '7')"), "")
 ElseIf nTpAtend == 2 // Ambulatorio/Pre Atendimento
  If cLocCont <> "0" //Ambulatorio/Pre Atendimento com Controle de Localizacao de Contas, visualiza somente as guias com status 1 e 2.
  	cFilP12 += " AND GCZ_ATENDI IN ('1', '2')" + IIf(nStatus <> 3, " And GCZ_STATUS IN " + IIf(nStatus == 1, "('1', '2', '3')", "('4', '5', '6', '7')"), " And GCZ_STATUS <> '0'")
  Else //Nao Tem Controle de Localizacao de Contas qdo Ambulatorial ou Pre Atendimento, visualiza todas as guias com status 0, 1 e 2.
 	 cFilP12 += " AND GCZ_ATENDI IN ('1', '2')" + IIf(nStatus <> 3, " And GCZ_STATUS IN " + IIf(nStatus == 1, "('0', '1', '2', '3')", "('4', '5', '6', '7')"), "")
 	EndIf
 ElseIf nTpAtend == 3 // Ambos, Hospitalar e Ambulatorial.
  If cLocCont <> "0" //Tem Controle de Localizacao de Contas, visualiza somente as guias com status 1 e 2.
  	cFilP12 += " AND ((GCZ_ATENDI = '0'" + IIf(nStatus <> 3, " And GCZ_STATUS IN " + IIf(nStatus == 1, "('0', '1', '2', '3')", "('4', '5', '6', '7')"), "") + ")" + ;
  	           " OR (GCZ_ATENDI <> '0'" + IIf(nStatus <> 3, " And GCZ_STATUS IN " + IIf(nStatus == 1, "('1', '2', '3')", "('4', '5', '6', '7')"), " And GCZ_STATUS <> '0'") + "))"
  Else //Nao Tem Controle de Localizacao de Contas, visualiza todas as guias com status 0, 1 e 2.
 	 cFilP12 += IIf(nStatus <> 3, " And GCZ_STATUS IN " + IIf(nStatus == 1, "('0', '1', '2', '3')", "('4', '5', '6', '7')"), "")
 	EndIf
 EndIf

 __cFilLote  := "GAT->GAT_NRFATU == '" + Space(Len(GAT->GAT_NRFATU)) + "' .AND. GAT->GAT_CODCON == '" + cCodConv + "'"
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณFS_GrvPct ณ Autor ณDaniel Peixoto         ณ Data ณ25/01/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Grava nas tabelas GE5/GE6/GE7                          		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                                     					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12                       											              	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvPct()
Local nCont := 0, nItens := 0
Local aProcessa   := {}, aArea := GetArea()
Local aIntCAb     := {}, aInterc := {}, aIntercPct := {}
Local nContTab    := 0, nContInt := 0, nContDia := 0
Local aDespGD     := {{"GD5", "GD5->GD5", "GE5", "0/1"}, {"GD6", "GD6->GD6", "GE6", "2"}, {"GD7", "GD7->GD7", "GE7", "3"}}
Local nQtdDia     := 0, nQtdDiaInt  := 0

Private aDespGD5  := {}, aDespGD6 := {}, aDespGD7 := {}
Private cSeqPct   := 0
Private cSqPtGE	  := ""
Private cCdAtGe   := ""

 //grava na Conta Aberta(GE) as despesas fora do intervalo passado no pacotes
 aIntCAb := FS_RIntCAb()
 For nContInt := 1 To LEN(aIntCAb)
  For nContTab := 1 To 3
   For nContDia := 0 to aIntCAb[nContInt, 2] - aIntCAb[nContInt, 1]
    DbSelectArea(aDespGD[nContTab, 1])
    DBSetOrder(2) //2/NRSEQG + DATDES
    If DbSeek(xFilial(aDespGD[nContTab, 1]) + GCZ->GCZ_NRSEQG + DTOS(aIntCAb[nContInt, 1] + nContDia))
     While !EOF() .And. &(aDespGD[nContTab, 2] + "_FILIAL") == xFilial(aDespGD[nContTab, 1]) .And. &(aDespGD[nContTab, 2] + "_NRSEQG") == GCZ->GCZ_NRSEQG ;
           .And. &(aDespGD[nContTab, 2] + "_DATDES") == aIntCAb[nContInt, 1] + nContDia
      FS_GrvGEGG("","GE", aDespGD[nContTab, 1], aDespGD[nContTab, 3], aDespGD[nContTab, 4], {0,&(aDespGD[nContTab, 2] + "_QTDDES")})//grava o Procedimento
      DBSkip()
     EndDo
    EndIf
   Next
  Next
 Next

 For nItens := 1 to LEN(oPct:aCols)

  If !oPct:aCols[nItens, Len(oPct:aCols[nItens])]
  cCodPro := oPct:aCols[nItens, n_CodPro]
  cCodCrm := IIF(!EMPTY(oPct:aCols[nItens, n_CodCrm]), oPct:aCols[nItens, n_CodCrm], GCY->GCY_CODCRM)
  dDatIni := oPct:aCols[nItens, n_DatIni]
  dDatFin := oPct:aCols[nItens, n_DatFin]

  If EMPTY(cCodPro)
   Loop
  EndIf

  If dDatIni > GCY->GCY_DATALT .Or. dDatFin < GCY->GCY_DATATE //Periodo do pacote fora do intervalo do atendimento do paciente
		 Loop
		EndIf

		//Posiciona GA7 do Pacote
  DbSelectArea("GA7")
	 DbSetOrder(1) //GA7_FILIAL+GA7_CODPRO
  DbSeek(xFilial("GA7") + cCodPro)

  dDatIni := IIF(dDatini < GCY->GCY_DATATE, GCY->GCY_DATATE, dDatIni)
  dDatFin := IIF(dDatFin > GCY->GCY_DATALT, GCY->GCY_DATALT, dDatFin)

	 //Grava em Conta Aberta as despesas dos intervalos de intercorrencia(campo Conta Aberta = SIM)
   aInterc := FS_RInterc(oInterc:aCols, cCodPro, "1")
  For nContInt := 1 To LEN(aInterc)
   For nContTab := 1 To 3
    For nContDia := 0 to aInterc[nContInt, 4] - aInterc[nContInt, 2]
     DbSelectArea(aDespGD[nContTab, 1])
     DBSetOrder(2) //2/NRSEQG + DATDES
     If DbSeek(xFilial(aDespGD[nContTab, 1]) + GCZ->GCZ_NRSEQG + DTOS(aInterc[nContInt, 2] + nContDia))
      While !EOF() .And. &(aDespGD[nContTab, 2] + "_FILIAL") == xFilial(aDespGD[nContTab, 1]) .And. &(aDespGD[nContTab, 2] + "_NRSEQG") == GCZ->GCZ_NRSEQG ;
            .And. &(aDespGD[nContTab, 2] + "_DATDES") == aInterc[nContInt, 2] + nContDia
       If IIF(nContDia == 0, &(aDespGD[nContTab, 2] + "_HORDES") >= aInterc[nContInt, 3], .T.) ;
          .And. IIF(nContDia == aInterc[nContInt, 4] - aInterc[nContInt, 2], &(aDespGD[nContTab, 2] + "_HORDES") <= aInterc[nContInt, 5], .T.) ;
          .And. &(aDespGD[nContTab, 2] + "_CODLOC") == aInterc[nContInt, 6]
        FS_GrvGEGG(aInterc[nContInt, 1], "GE", aDespGD[nContTab, 1], aDespGD[nContTab, 3], aDespGD[nContTab, 4], {0,&(aDespGD[nContTab, 2] + "_QTDDES")})//grava o Procedimento
       EndIf
       DBSkip()
      EndDo
     EndIf
    Next
   Next
  Next

  //Tratamento do pacote nas despesas dos intervalos de intercorrencia onde o campo Conta Aberta = NAO
  aIntercPct := FS_RInterc(oInterc:aCols, , "0")
  FS_FatInt(aIntercPct, cCodCrm)

  //Posiciona GP0 - Pacote x Convenio da Aba [Pacote]
  DbSelectArea("GP0")
  DbSetOrder(1) //GP0_FILIAL+GP0_CODPRO+GP0_CODCON
  DbSeek(xFilial("GP0") + cCodPro + GCZ->GCZ_CODCON)
	 nQtdDia := IIF(GP0->GP0_FATDIA == "1", dDatFin - dDatIni + 1, 1)

  aProcessa := HS_P12SEL("P") //Verifica se existe alguma despesa de Mat/Med - Tax/Dia - Procedto zerada referente a esta Guia.
   If aProcessa[1] .And. aProcessa[2] .And. aProcessa[3] .And. aProcessa[5][1] .And. aProcessa[5][2] .And. aProcessa[5][3]

  	// Gerando Registro no Arquivo de Faturamento (Procedimentos/Pacotes-GE7)
	 	For nCont := 1 to nQtdDia
  		//Gera o procedimento GE7 do Pacote
  		FS_GrvGE7P(cCodPro, cCodCrm, dDatIni)

    // Gerando Registros no Arquivo de Faturamento (Taxas-GE6,GG6)
    FS_GrvDes(cCodPro, nQtdDia, "2") //TAX
  		// Gerando Registros no Arquivo de Faturamento (Materiais/Medicamentos-GE5,GG5)
    FS_GrvDes(cCodPro, nQtdDia, "0/1") //MAT/MED
    // Gerando Registros no Arquivo de Faturamento (Procedimentos-GE7,GG7)
    FS_GrvDes(cCodPro, nQtdDia, "3") //PRO

    dDatIni ++
 	 Next

 	 DbSelectArea("GE7")
 	 DbSetOrder(1)
 	 If DbSeek(xFilial("GE7") + cSqPtGE)
 	 	RecLock("GE7",.F.)
 	 		If !Empty(cCdAtGe)
 	 			GE7->GE7_CODATO := cCdAtGe
 	 		EndIf
 	 	MsUnLock()
 	 EndIf

 	 DbSelectArea("GCZ")
 	 RecLock("GCZ",.F.)
 	  GCZ->GCZ_STATUS := "2"
 	  GCZ->GCZ_DATSTA := dDataBase
   	GCZ->GCZ_HRGERA := TIME()
   	GCZ->GCZ_USGERA := cUserName
 	 MsUnlock()

	  cMsgOK += IIF(EMPTY(cMsgOK), STR0175 + CHR(10) , ", ") + GCZ->GCZ_NRSEQG //"Guias faturadas com sucesso: "

  Else
  	cMsgErro += IIF(EMPTY(cMsgErro), STR0176 + CHR(10), "")  //"Guias nใo faturadas: "

  	If !aProcessa[1]
  		cMsgErro += GCZ->GCZ_NRSEQG + " - " + STR0113  + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med Com o Valor Zerado"
  	EndIf

  	If !aProcessa[2]
  		cMsgErro += GCZ->GCZ_NRSEQG + " - " + STR0114  + chr(10)//"Guia Nใo Faturada, existe despesa de Tax/Dia Com o Valor Zerado"
  	EndIf

  	If !aProcessa[3]
  		cMsgErro += GCZ->GCZ_NRSEQG + " - " + STR0115  + chr(10)//"Guia Nใo Faturada, existe despesa de Procedto Com o Valor Zerado"
  	EndIf

    If !aProcessa[5][1]
   		cMsgErro += STR0219 + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med com o Valor menor que o Desconto"
   	EndIf

   	If !aProcessa[5][2]
   		cMsgErro += STR0220 + chr(10)//"Guia Nใo Faturada, existem despesas de Tax/Dia com o Valor menor que o Desconto"
   	EndIf

    If !aProcessa[5][3]
	   	cMsgErro += STR0221 + chr(10)//"Guia Nใo Faturada, existem despesas de Procedto com o Valor menor que o Desconto"
	   EndIf

  EndIf

  EndIf

 Next

 RestArea(aArea)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvDes บAutor  ณDaniel Peixoto      บ Data ณ  27/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava as despesas nas GE5(Faturados em Aberto)             บฑฑ
ฑฑบ          ณ                       GE6(Faturados em Pacote)             บฑฑ
ฑฑบ          ณ                       GE7(Faturados em Pacote)             บฑฑ
ฑฑบ          ณ                       GG5(Faturados do Pacote)             บฑฑ
ฑฑบ          ณ                       GG6(Faturados do Pacote)             บฑฑ
ฑฑบ          ณ                       GG7(Faturados do Pacote)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvDes(cCodPro, nQtdDia, cTipDes, aDespesas)
Local aAreaOld  := GetArea()
Local nCont     := 0
Local cCodDes   := ""
Local cCodGPP   := ""
Local aRetQtd   := {}
Local cAliasGD  := IIf(cTipDes == "0/1", "GD5", IIF(cTipDes == "2", "GD6", "GD7"))
Local cPArqGD   := cAliasGD + "->" + PrefixoCpo(cAliasGD)
Local cAliasGE  := IIf(cTipDes == "0/1", "GE5", IIF(cTipDes == "2", "GE6", "GE7"))
Local cAliasGG  := IIf(cTipDes == "0/1", "GG5", IIF(cTipDes == "2", "GG6", "GG7"))

Private aDespLanc  := {}
Private nQtdTotDes := 0
Private nQtdCob    := 0
Private aVetJaFat  := {}
Private aItensGPP  := {}
Private lJaAtuQtd  := .F.

Private nQtdAux		:= 0
Private nQtdAuxD	:= 0
Private lcAnest		:= .F.
Private nAuxTot		:= 0
Private nContAx		:= 0

Default aDespesas := {}

If Len(aDespesas) == 0
	DbSelectArea(cAliasGD)
	DBSetOrder(2)//2/NRSEQG + DATDES
	DbSeek(xFilial(cAliasGD) + GCZ->GCZ_NRSEQG )
	While !EOF() .And. &(cPArqGD + "_FILIAL") == xFilial(cAliasGD) .And. &(cPArqGD + "_NRSEQG") == GCZ->GCZ_NRSEQG
		If EMPTY(&(cPArqGD + "_SEQ"+cAliasGE)) .And. &(cPArqGD + "_DATDES") >= dDatIni .And. &(cPArqGD + "_DATDES") <= dDatFin ;
			.And. IIF(EMPTY(&(cPArqGD + "_CODPCT")), .T., IIF(cTipDes $ "2/3", FS_ProPrin(&(cPArqGD + "_CODPCT"), &(cPArqGD + "_CODDES")), .F.))
			If nQtdDia > 1 .And. &(cPArqGD + "_DATDES") <> dDatIni //DIARIO
				DbSelectArea(cAliasGD)
				DBSkip()
				Loop
			EndIf
			AADD(aDespLanc, {&(	cPArqGD + "_CODDES"),; //1 - CODDES
								&(cPArqGD + "_QTDDES"),; //2 - QTDDES
								HS_CValDes(cAliasGD, &(cPArqGD + "_SEQDES"),,,.T.),; //3 - VALDES
								&(cPArqGD + "_DATDES"),; //4 - DATDES
								&(cPArqGD + "_SEQDES"),; //5 - SEQDES
								&(cPArqGD + "_CODPCT"),; //6 - CODPCT
								IIF(cTipDes == "3", &(cPArqGD + "_CODATO"), ""),; //7 - CODATO
								&(cPArqGD + "_CODLOC"),; //8 - CODLOC
								IIF(cTipDes == "2", IIF(FS_DespDia(&(cPArqGD + "_CODDES")), "7", "2"), "")}) // 9 - TIPDES
		EndIf
		DBSkip()
	EndDo
Else
	aDespLanc := aClone(aDespesas)
EndIf
If nQtdDia == 1 // Fat por Periodo
	If cTipDes == "2" //Diarias - ordena as diarias primeiro
		aSort(aDespLanc,,,{|x,y| x[9] + x[1] + DTOS(x[4]) + Transform(x[3], "@E 999,999.99") >  y[9] + y[1] + DTOS(y[4]) + Transform(y[3], "@E 999,999.99") })
//	Else //VALOR
//		aSort(aDespLanc,,,{|x,y| x[1] + DTOS(x[4]) + Transform(x[3], "@E 999,999.99") < y[1] + DTOS(y[4]) + Transform(y[3], "@E 999,999.99")})
	EndIf
EndIf
For nCont := 1 To Len(aDespLanc)
	If cCodDes <> aDespLanc[nCont, 1]
		cCodDes    := aDespLanc[nCont, 1]
		nQtdTotDes := FS_TotDesL("GD", aDespLanc, cCodDes ) //total lancada no periodo
		lJaAtuQtd  := .F.
	EndIf
	If nQtdDia > 1 .And. aDespLanc[nCont, 1] == aDespLanc[IIF(nCont > 1, nCont-1, 1), 1] .And. ;
		aDespLanc[nCont, 4] <> aDespLanc[IIF(nCont > 1, nCont-1, 1), 4] //Diario e a Data Despesa Mudou
		lJaAtuQtd := .F.
	EndIf
	aRetQtd := FS_QtdFat(	cCodPro,; //Codigo do Pacote
							IIF(cTipDes == "0/1", FS_MatMed(aDespLanc[nCont, 1]), cTipDes),;//Tipo Despesa
							aDespLanc[nCont, 1],; //CODDES
							aDespLanc[nCont, 2],; //QTDDES
							aDespLanc[nCont, 3],; //VALDES
							aDespLanc[nCont, 4],; //DATDES
							aDespLanc[nCont, 5],; //SEQDES
							aDespLanc[nCont, 6],; //CODPCT - procedimento padrao
							aDespLanc[nCont, 7],; //CODATO
							aDespLanc[nCont, 8])  //CODLOC

	DbSelectArea(cAliasGD)
	DBSetOrder(1)//1/SEQDES
	If DbSeek(xFilial(cAliasGD) + aDespLanc[nCont, 5])

		DbSelectArea("GA1")
		DBSetOrder(1) //GA1_FILIAL+GA1_CODPCT
		DbSeek(xFilial("GA1") + aDespLanc[nCont, 6])

		If aScan(aItensGPP,{|x| x[2] == GA1->GA1_CODPRO}) == 0 .Or. aScan(aItensGPP,{|x| x[2] == GA1->GA1_CODTXD}) == 0 //Se o Prod. Princ. nao esta em Grupo Proced.
	    	If aRetQtd[2] > 0  //grava excecoes do pacote GE
	    		FS_GrvGEGG(cCodPro, "GE", cAliasGD, cAliasGE, cTipDes, aRetQtd)
				//Despesas tipo DIARIAS lan็adas em conta aberta - Todas despesas(Mat/Med, Tax/Dia e Proc.) do Dia e Setor na conta Aberta
				If cTipDes == "2" .And. FS_DespDia(aDespLanc[nCont, 1])
					FS_LanDspD(GCZ->GCZ_NRSEQG, aDespLanc[nCont, 5], aDespLanc[nCont, 4], aDespLanc[nCont, 8])
				EndIf
			EndIf
			If aRetQtd[1] > 0 //grava despesas inclusas no pacote GG
				FS_GrvGEGG(cCodPro, "GG", cAliasGD, cAliasGG, cTipDes, aRetQtd)
			EndIf
		EndIf
	EndIf
Next

/*****Trata Itens dos Grupos de Procedimento*****/
If cTipDes == "3" .And. Len(aItensGPP) > 0
	FS_FatGrpP(cCodPro, cTipDes)
EndIf

RestArea(aAreaOld)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_QtdFat บAutor  ณDaniel Peixoto      บ Data ณ  27/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula as despesas inclusao no pacote                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRet     - 0 - Qtd despesa inclusa no pacote               ณฑฑ
ฑฑณ          ณ            1 - Qtd despesa excedida no pacote              ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_QtdFat(cCodPro, cTipo, cCodDes, nQtdDes, nValDes, dDatDes, cSeqDes, cCodPct, cCodAto)
Local aAreaOld   := GetArea()
Local cCodGrp    := ""
Local aRet       := {0, 0} //1- Qtd inclusa pacote  //2- Qtd excedida
Local cAliasItem := IIf(cTipo == "0", "GP7", IIF(cTipo == "1", "GP5", IIF(cTipo == "2", "GP3", "GP1")))
Local cPArqItem  := cAliasItem + "->" + PrefixoCpo(cAliasItem)
Local cCpoQtd    := IIf(cTipo == "0", "_QTDMAT", IIF(cTipo == "1", "_QTDMED", IIF(cTipo == "2", "_QTDTXD", "_QTDPRO")))
Local cAliasGrp  := IIf(cTipo == "0", "GP8", IIF(cTipo == "1", "GP6", IIF(cTipo == "2", "GP4", "GP2")))
Local cPArqGrp   := cAliasGrp + "->" + PrefixoCpo(cAliasGrp)
Local cAliasCodG := IIf(cTipo $ "0/1", "SB1", IIF(cTipo == "2", "GAA", "GA7"))
Local cPArqCodG  := cAliasCodG + "->" + PrefixoCpo(cAliasCodG)
Local cCpoCodG   := IIf(cTipo $ "0/1", "_GRUPO", IIF(cTipo == "2", "_CODCTD", "_CODGPP"))
Local nValMaxDes := IIf(cTipo == "0", GP0->GP0_VALMAT, IIF(cTipo == "1", GP0->GP0_VALMED, IIF(cTipo == "2", GP0->GP0_VALTXD, GP0->GP0_VALPRO)) )
Local nValMaxGrD := 0
Local nPos       := 0
Local cExcPct    := "1"
Local nDiasPerm := 0
Local nAux		 := 0
Local cTipAtm	 := ""
Local nDesp		 := 0

If GMC->(Posicione("GMC",1,xFilial("GMC")+cCodAto,"GMC_TIPATM")) $ "1/2/3/4"
	nContAx ++
EndIf

If GMC->(Posicione("GMC",1,xFilial("GMC")+cCodAto,"GMC_TIPATM")) == "0"
	cCdAtGe := cCodAto
EndIf

//Posiciona GP0 - Pacote x Convenio
DbSelectArea("GP0")
DbSetOrder(1) //GP0_FILIAL+GP0_CODPRO+GP0_CODCON
DbSeek(xFilial("GP0") + cCodPro + GCZ->GCZ_CODCON)
If GP0->(FieldPos("GP0_DIAPER")) > 0
	nDiasPerm := GP0->GP0_DIAPER
EndIf
If GP0->(FieldPos("GP0_EXCPCT")) > 0
	cExcPct := GP0->GP0_EXCPCT
EndIf

//***************   Regra da Permanencia *******************************//
If nDiasPerm > 0 .And. dDatDes > dDatIni + nDiasPerm
	aRet[2] := nQtdDes    //Excede Tudo
	Return(aRet)
EndIf

//***************   Regra da Anestesia *******************************//
If cTipo == "3" .And. GP0->GP0_ANESTE == "0" .And. !EMPTY(cCodAto) .And. ;
	HS_RAtoMed(1, cCodAto + "1", .T.)[3] == "5" //Anestesista
	aRet[2] := nQtdDes    //Excede Tudo
	Return(aRet)
EndIf

//***************   Regra do Valor  *******************************//
If nValDes > nValMaxDes .And. nValMaxDes > 0 .And. !FS_ProPLan(GCZ->GCZ_NRSEQG, cCodPct)
	aRet[2] := nQtdDes    //Excedeu Tudo
	Return(aRet)
EndIf

//***************   Regra do Item *******************************//
DbSelectArea(cAliasItem)
DbSetOrder(2)//2/CODPRO+CODCON+CODITEM
If DbSeek(xFilial(cAliasItem) + GP0->GP0_CODPRO + GP0->GP0_CODCON + cCodDes) .And. !FS_ProPLan(GCZ->GCZ_NRSEQG, cCodPct) //So aplica regra do pacote se nao tem o proced principal lancado
	If !lJaAtuQtd
		DbSelectArea("GA8")
		DbSetOrder(1)// GA8_FILIAL + GA8_CODPRO + GA8_TABPRO + DTOS(GA8_DATVIG)
		If DbSeek (xFilial("GA8") + GP0->GP0_CODPRO)
			nQtdCob := 1 					//Sempre contara 1 para o medico cirurgiao
			nQtdCob += GA8->GA8_QTDAUX		// Soma a quantidade de auxiliares
			nAuxTot	:= nQtdAux := GA8->GA8_QTDAUX

			For nAux := 1 to Len(aDespLanc)
				DbSelectArea("GMC")
				DbSetOrder(1)
				If DbSeek(xFilial("GMC") + aDespLanc[nAux][7])
					If GMC->GMC_TIPATM $ "1/2/3/4"
						nQtdAuxD ++
					EndIf
				EndIf
			Next nAux

			If GP0->GP0_ANESTE == '1'		// Soma o anestesista apenas se o pacote cobrir
				If !Empty(GA8->GA8_CODPAN)	// Verifica se o porte anestesista esta preenchido
					nQtdCob++				// Preenche mais 1 do anestesista
					lcAnest := .T.
				EndIf
			EndIf
		EndIf
		nQtdCob := nQtdCob * &(cPArqItem + cCpoQtd)		// Multiplica pela quantidade de pacotes lancados
		lJaAtuQtd := .T.
	EndIf
	If nQtdTotDes > nQtdCob //Excedeu
		If nQtdCob > 0 .AND. nContAx <= nAuxTot//Gera GE e GG
			cTipAtm := GMC->(Posicione("GMC",1,xFilial("GMC")+cCodAto,"GMC_TIPATM"))
			If cTipAtm = "0"
				aRet[1] := nQtdCob
				aRet[2] := nQtdDes - &(cPArqItem + cCpoQtd)
				nQtdCob -= 1
			ElseIf cTipAtm = "5" .AND. lcAnest
				aRet[1] := nQtdCob
				aRet[2] := nQtdDes - &(cPArqItem + cCpoQtd)
				nQtdCob -= 1
			Else
				If nQtdAux <= nQtdAuxD
					aRet[1] 	:= nQtdCob
					aRet[2] 	:= nQtdDes - &(cPArqItem + cCpoQtd)
					nQtdCob 	-= 1
					nQtdAuxD 	-= 1
					nQtdAux		-= 1
				Else
 					If nQtdAuxD == 1
						aRet[1] 	:= nQtdCob
						aRet[2] 	:= Iif((nQtdAux - 1) == 1, nQtdDes - 2, nQtdDes - nQtdAux)
						nQtdCob 	-= 1
						nQtdAuxD 	-= 1
						nQtdAux		-= 1
					Else
						nValAr 		:= Round(nQtdAux/nQtdAuxD,0)
						aRet[1] 	:= nQtdCob
						aRet[2] 	:= IIf (nQtdDes > nValAr,nQtdDes - nValAr,nQtdDes - 1)  //Iif((nQtdAux - 1) == 1, nQtdDes - 2, nQtdDes - 1)
						nQtdCob 	:= IIf (nQtdCob > nValAr,nQtdCob - nValAr,nQtdCob - 1)// 1
						nQtdAuxD 	-= 1
						nQtdAux		:= IIf (nQtdAux > nValAr,nQtdAux - nValAr,nQtdAux - 1)//1
					EndIf
				EndIf
			EndIf
		Else //Gera GE
			aRet[2] := nQtdDes//Iif(nContAx > nAuxTot, nQtdDes, 0)
		EndIf
	Else //Cobre
		If nContAx > nAuxTot
			aRet[2] := nQtdDes
		Else
			aRet[1] := nQtdDes
		EndIf
	EndIf
Else //********************* Regra do Grupo ***************************/
	DbSelectArea(cAliasCodG)
	DbSetOrder(1)
	DbSeek(xFilial(cAliasCodG) + cCodDes)
	cCodGrp := &(cPArqCodG + cCpoCodG)

	DbSelectArea(cAliasGrp)
	DbSetOrder(2)//2/CODPRO+CODCON+CODGRP
	If !DbSeek(xFilial(cAliasGrp) + GP0->GP0_CODPRO + GP0->GP0_CODCON + cCodGrp)
		If FS_ProPLan(GCZ->GCZ_NRSEQG, cCodPct) //Faz parte de um Proc. Pad e seu Proced. Princ. Pad. esta Lancado
			DbSelectArea("GA1")
			DBSetOrder(1) //GA1_FILIAL+GA1_CODPCT
			If aScan(aItensGPP,{|x| x[2] == GA1->GA1_CODPRO}) == 0 //Se o Prod. Princ. nao esta no Vetor Grupo Proced.
				AADD(aItensGPP, {cCodGrp, GA1->GA1_CODPRO, nQtdDes, nValDes, dDatDes, cSeqDes, 999, cCodPct})
			EndIf
		Else
			aRet[IIF(cExcPct == "0", 2, 1)] := nQtdDes //Se Exc. Pacote = Nao ->Excede Tudo, Senao ->Cobre Tudo
		EndIf
	Else //Achou o Grupo na Excecao
		nValMaxGrD := IIf(cTipo == "0", GP8->GP8_VALMAT, IIF(cTipo == "1", GP6->GP6_VALMED, IIF(cTipo == "2", GP4->GP4_VALTXD, GP2->GP2_VALPRO)) )
		If nValDes > nValMaxGrD .And. nValMaxGrD > 0 //Regra do valor no Grp
			aRet[2] := nQtdDes //Excedeu Tudo
			Return(aRet)
		EndIf

		If cTipo == "3" //proced.
			If GP2->(FieldPos("GP2_QTDPRO")) > 0 //Grp Proced.
				If FS_ProPLan(GCZ->GCZ_NRSEQG, cCodPct) .And. FS_ProPrin(cCodPct, cCodDes) //Faz parte de um Proc. Pad e seu Proc. Princ. esta Lancado .AND. eh o Principal
					AADD(aItensGPP, {cCodGrp, cCodDes, nQtdDes, nValDes, dDatDes, cSeqDes, &(cPArqGrp + "_QTDPRO"), cCodPct})
				Else //Nao faz parte de um Proc. Pad ou sua despesa Principal nao esta lancada
					AADD(aItensGPP, {cCodGrp, cCodDes, nQtdDes, nValDes, dDatDes, cSeqDes, &(cPArqGrp + "_QTDPRO"), ""})
				EndIf
			EndIf
		ElseIf EMPTY(cCodPct) //Nao pertence a Proc. Padrao
			aRet[IIF(cExcPct == "1", 2, 1)] := nQtdDes //Se Exc. Pacote = Sim ->Excede Tudo, Senao ->Cobre Tudo
		EndIf
	EndIf
EndIf

RestArea(aAreaold)
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_HP12RcPบAutor  ณ ALESSANDRO FREIRE  บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o or็amento no SL1,SL2 e SL4 para contas particulares บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_HP12RcP() // Receb. Conta Particular

Local	aArea	  := GetArea()
Local cMsgErro  := "", cMsgEFat := ""
Local nGuiaAtu  := 0
Local nGuiaTot  := Len(__aMarkBrow)
Local lHspVldCX := .T.
Local lPEVLDCX  := ExistBlock("HSPVLDCX")
If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

If ! MsgYesNo(STR0101, STR0016) //"Confirma Gerar o Recebimento de Conta Particular?  "###"Aten็ใo"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(nil)
EndIf

ProcRegua(nGuiaTot)

For nGuiaAtu := 1 To nGuiaTot

	If Alias() <> "GCZ"
		DBSelectArea("GCZ")
	EndIf

	If IndexOrd() <> 1
		DbSetOrder(1)
	EndIf

	DBSeek(xFilial("GCZ") + __aMarkBrow[nGuiaAtu][1])

	IncProc(STR0134 + GCZ->GCZ_NRSEQG + "][" + StrZero(nGuiaAtu, 6) + "/" + StrZero(nGuiaTot, 6) + "]") //"Faturando ["

	If !Empty(GCZ->GCZ_NUMORC)
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0067 + STR0068 + GCZ->GCZ_NUMORC + Chr(10) //"NRSEQG - "###"Esta guia jแ possui or็amento gerado."###"Or็amento No. "
	ElseIf cLocCont <> "0" .And. GCZ->GCZ_STATUS == "0"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0100 + Chr(10) //"NRSEQG - "###" encontra-se no Controle de Localizacao de Contas, Verifique!!!"
	ElseIf GCZ->GCZ_CANCEL == "1"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0092 + Chr(10) //"NRSEQG - "###" estแ cancelada e nใo pode ser utilizada"
	ElseIf HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") <> "1"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0069 + " " + STR0039 + " " + GCZ->GCZ_CODPLA + Chr(10) //"NRSEQG - "###"Este plano nใo ้ particular. Nใo serแ possํvel gerar um or็amento."###"Plano"
	ElseIf GCZ->GCZ_STATUS > "2"
		cMsgErro += STR0014 + " " + GCZ->GCZ_NRSEQG + " " + STR0015 + Chr(10) //"NRSEQG - "###" ja foi faturada, nao sera possivel fatura-la"
	Else
		lHspVldCX := .T. //Reinicializa padrao .T. para gerar o orcamento
	    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ Ponto de entrada para indicar se ira continuar o processo                ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        If lPEVLDCX
            lHspVldCX := ExecBlock( "HSPVLDCX",.F.,.F., {GCZ->GCZ_REGATE} )
        EndIf

        If lHspVldCX
		    Begin Transaction

		    cMsgEFat := ""

		    // Gera faturamento da guia
		    If GCZ->GCZ_STATUS < "2"
			    If !Empty(cMsgEFat := Hs_Hp12Fat(GCZ->GCZ_NRSEQG))
				    cMsgErro += cMsgEFat
			    EndIf
		    EndIf

		    // gera o orcamento no SL1, SL2 e SL4, caso nใo haja nenhuma inconsistencia geracao do faturamento da guia //
		    If Empty(cMsgEFat)
			    HS_IntLoja(GCZ->GCZ_NRSEQG, GCZ->GCZ_REGGER)
		    EndIf

		    End Transaction
		EndIf
	EndIf

Next

If !Empty(cMsgErro)
	HS_MsgInf(cMsgErro, STR0016, STR0135) //"Aten็ใo"###"Faturamento particular"
Else
	HS_MMarkB(@__aMarkBrow, cFilP12, .T.) // Desmarca guias
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aArea)
Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณHS_HP12DESณ Autor ณGilson da Silva        ณ Data ณ16/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ LANCAMENTO DAS DESPESAS                             					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01 - Alias do Arquivo       								                	  ณฑฑ
ฑฑณ          ณ ExpN02 - Nr. do registro                        									  ณฑฑ
ฑฑณ          ณ ExpN03 - Opcao Selecionada (Gerar Fatura ou Excluir)	   	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSPAHP12 	              						                          	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12DES(cAlias,nReg,nOpc)   //DESPESAS
Local aArea	:= GetArea()
Local cMovest := GETMV("MV_AUDMEST")

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If Empty(cMovest)
	MsgInfo(STR0143, STR0142) //"Por favor, preencha o parametro MV_AUDMEST para validacao do estoque"###"Atencao"
	Return(Nil)
EndIf

DbSelectArea("GCY")
DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
If !dbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
	MsgInfo(STR0073 ,STR0074)//"Nใo hแ registro de atendimento para esta guia. Chame o suporte."###"Inconsistencia"
Else
	HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, IIf(GCZ->GCZ_STATUS < "2", "P", "F"), 7, GCY->GCY_CODLOC, GCZ->GCZ_NRSEQG}) // 7-Guias
EndIf

RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	 ณHS_HP12AIHณ Autor ณSueli C. Santos        ณ Data ณ17/12/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ LANCAMENTO DAS DESPESAS De AIH         					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01 - Alias do Arquivo                            	  ณฑฑ
ฑฑณ          ณ ExpN02 - Nr. do registro                 				  ณฑฑ
ฑฑณ          ณ ExpN03 - Opcao Selecionada (Gerar Fatura ou Excluir)	   	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12 	              						       	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12AIH(cAlias,nReg,nOpc)   //AIH
Local aArea	:= GetArea()
Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

DbSelectArea("GCY")
DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
If !dbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
		MsgInfo(STR0073 ,STR0074)//"Nใo hแ registro de atendimento para esta guia. Chame o suporte."###"Inconsistencia"
Else
	If lAteSUS .And. GCY->GCY_ATENDI == "0" .And. (GCZ->GCZ_CODPLA $ __cCodAIH)
		HSPAIHAI({GCY->GCY_ATENDI, GCY->GCY_REGATE, IIf(GCZ->GCZ_STATUS < "2", "P", "F"), 7, GCY->GCY_CODLOC, GCZ->GCZ_NRSEQG}) // 7-Guias
	Else
		MsgInfo(STR0254 ,STR0074)
	EndIf
EndIf

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_HP12EXTณ Autor ณGilson da Silva        ณ Data ณ17/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ EXTRATO                                             					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01 - Alias do Arquivo                       									  ณฑฑ
ฑฑณ          ณ ExpN02 - Nr. do registro                        									  ณฑฑ
ฑฑณ          ณ ExpN03 - Opcao Selecionada (Gerar Fatura ou Excluir)	   	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSPAHP12 											                                    	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12EXT(cAlias,nReg,nOpc)   //EXTRATO
 Local aArea	:= GetArea()
 Local cStatus := Iif(GCZ->GCZ_STATUS == "2", "F", "P") //"F" = Vai P/conta Faturamento "GE5/GE6/GE7"
                                                       //"P" = Vai p/conta do paciente "GD5/GD6/GD7"
 If !(HS_VldBrowse(oMb))
	Return(Nil)
 EndIf

 DbSelectArea("GCY")
 DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
 If !dbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
 	MsgInfo(STR0073 ,STR0074)//"Nใo hแ registro de atendimento para esta guia. Chame o suporte."###"Inconsistencia"
 Else
 	HS_EXTM24C(GCY->GCY_REGGER, cStatus, nOpc)
 EndIf

 RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณHS_HP12FGD5 บAutor  ณGilson da Silva     บ Data ณ  22/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณComplementa o Filtro da Tabela GD5 para diferenciar           บฑฑ
ฑฑบ          ณas despesas de Materiais das despesas de Medicamentos.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpc1 =Indica o Tipo de Material 0=Materiais 1=Medicamentos   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_HP12FGD5(cTipo)
 Local aArea   := GetArea()
 Local lRet    := .F.

 // Posiciona na tabela complementar de produtos "GBI".
 DbSelectArea("GBI")
 DbSetOrder(1)       //GBI_FILIAL+GBI_PRODUT
 #IFDEF TOP
  DbSeek(xFilial("GBI")+ TMPGD5->GD5_CODDES)
 #ELSE
  DbSeek(xFilial("GBI")+ GD5->GD5_CODDES)
 #ENDIF
 lRet := .F.
 If cTipo == "1"  .And. GBI->GBI_TIPO <> "1"
 	lRet := .T.
 ElseIf cTipo == "0" .And. GBI->GBI_TIPO == "1"
  lRet := .T.
 EndIf

 RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณHS_BMark    บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_BMark(aMBrow)
Local nPGuia := 0

IF IsMark("GCZ_IDMARC", ThisMark(), ThisInv())
	aAdd(aMBrow, {GCZ->GCZ_NRSEQG, GCZ->GCZ_REGATE, &(indexkey()), GCZ->GCZ_FILATE})
ElseIf (nPGuia := aScan(aMBrow, {| aVet | aVet[1] == GCZ->GCZ_NRSEQG})) > 0
	aDel(aMBrow, nPGuia)
	aSize(aMBrow, Len(aMBrow) - 1)
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ HS_MMarkB  บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MMarkB(aMBrow, cCondSql, lDesmarca, nNroGuias)
Local cSql		:= ""
Local aArea		:= GetArea()
Local nCont		:= 1
Local nI
Local aMTodos	:= {}
Local cCondSqx	:=''

Default cCondSql  := PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial("GCZ") + "' AND D_E_L_E_T_ <> '*'"
Default lDesmarca := ThisInv()

If Type("oMB") <> "U"  .And.  Type("oMB:OBROWSE") <> "U" .And. Type("oMB:OBROWSE:OFWFILTER") <> "U" .And. Valtype("oMB:OBROWSE:OFWFILTER:AFILTER") == "A"
	For nI := 2 to len(oMB:OBROWSE:OFWFILTER:AFILTER)
		If oMB:OBROWSE:OFWFILTER:AFILTER[nI,6]
		cCondSqx += " AND " + STRTRAN(Alltrim(oMB:OBROWSE:OFWFILTER:AFILTER[nI][1]),"GCZ->","")+" "
		cCondSqx := Upper(cCondSqx)
		cCondSqx := STRTRAN(cCondSqx,'!EMPTY(GCZ_NRGGLO)',"GCZ_NRGGLO<>''")
		cCondSqx := STRTRAN(cCondSqx,'OU',"OR")
		Endif
	Next
EndIf

cCondSql:=cCondSql+cCondSqx

If (lDesmarca .AND. IsInCallStack("HEADERCLICK"))
	cCondSql += " AND GCZ_IDMARC = '" + ThisMark() + "'"
ElseIf (lDesmarca .AND. Empty(cCondSql))
	cCondSql += " GCZ_IDMARC = '" + ThisMark() + "'"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso o campo GCZ_IDMARC estiver  marcado, entใo oณ
//ณsistema irแ desmarcar os registros.              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type("cMarca") == 'U'
    cMarca := GetMark()
EndIf

If GCZ->GCZ_IDMARC == cMarca
	lDesmarca := .T.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInclusใo da Chamada  do Evento   ณ
//ณPara diferenciar entre a chamada ณ
//ณDa MarkBrowser e da Tecla F12    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If IsInCallStack("HEADERCLICK") //Ao alterar a fun็ใo do bloco de codigo da chamada da MarkBrowse Altera-la aqui
	lMarkALL 	:= !lMarkALL
	lDesmarca 	:= lMarkALL
	nNroGuias	:= Nil
EndIf

CursorWait()

If !lDesmarca
	NewMark()
EndIf

If nNroGuias == Nil
	SetInvert(!lDesmarca)
EndIf
aMBrow := {}

cSql := "SELECT GCZ_NRSEQG, GCZ_REGATE, GCZ_FILATE FROM " + RetSqlName("GCZ") + " WHERE " + PLSParSQL(cCondSql)
cSql += " ORDER BY " + SqlOrder(GCZ->(IndexKey()))

TCQUERY cSql NEW ALIAS "QRYMRK"

While !Eof()
	If !lDesmarca
		If IIF(nNroGuias == Nil, .T., nCont <= nNroGuias)
			aAdd(aMBrow, {QRYMRK->GCZ_NRSEQG, QRYMRK->GCZ_REGATE,, QRYMRK->GCZ_FILATE})
			GCZ->(DbSetOrder(1))
			If GCZ->(DbSeek(xFilial("GCZ")+QRYMRK->GCZ_NRSEQG))
				If IsMark("GCZ_IDMARC",GetMark(), .T.)
					RecLock("GCZ",.F.)
					Replace GCZ->GCZ_IDMARC	With cMarca
					MsUnLock( GCZ->( RECNO() ) )
				EndIf
			EndIf
		EndIf
		nCont ++
	Else //Desmarca
		aAdd(aMTodos, {QRYMRK->GCZ_NRSEQG, QRYMRK->GCZ_REGATE,, QRYMRK->GCZ_FILATE})
		GCZ->(DbSetOrder(1))
		If GCZ->(DbSeek(xFilial("GCZ")+QRYMRK->GCZ_NRSEQG))
			If !Empty(GCZ->GCZ_IDMARC)
				RecLock("GCZ",.F.)
				Replace GCZ->GCZ_IDMARC	With "  "
				MsUnLock( GCZ->( RECNO() ) )
			EndIf
		EndIf
	EndIf
	DBSelectArea("QRYMRK")
	DBSkip()
Enddo

QRYMRK->(DbCloseArea())
GCZ->(DbGotop())

CursorArrow()

RestArea(aArea)
Return(aMTodos)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao  	 ณHS_FILHP12ณ Autor ณGilson da Silva        ณ Data ณ25/02/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Chama o  Grupo de perguntas "HSP80A"                		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                         	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ                                                 			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ HSPAHP12 			                      		       	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_FILHP12()
//Local oObjMBrw := GetMarkBrow()

HS_MMarkB(@__aMarkBrow, cFilP12, .T.)

If !Pergunte(cPerg,.T.)
	Return()
EndIf

cFilGuia  := mv_par01
cCodConv  := mv_par02
cPlaIni   := mv_par03
cPlaFin   := mv_par04
cGuiaIni  := mv_par05
cGuiaFin  := mv_par06
cGuiaSeqI := mv_par07
cGuiaSeqF := mv_par08
cCodLoc   := mv_par09
dDtAteIni := mv_par10
dDtAteFin := mv_par11
nTpAtend  := mv_par12
cTpGuia   := mv_par13
nStatus   := mv_par14
nNroGuias := mv_par15

FS_Filtro()


//oMb:oBrowse:ResetLen()
//GCZ->(DbClearFilter())
SetMBTopFilter("GCZ",cFilP12,,.T.)
//oMb:oBrowse:GoTop()
//dbSelectArea("GCZ")
//GCZ->(dbGoTop())
//oMb:oBrowse:Refresh()

If nNroGuias > 0
	HS_MarkF4(.F., nNroGuias)
EndIf
oMb:Refresh(.T.)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_P12LOTEบAutor  ณAlessandro Freire   บ Data ณ  07/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_P12LOTE()

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

HSPAHA51()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณMARCELO JOSE        บ Data ณ  20/05/05   บฑฑ
ฑฑบAlteracao ณ          บ       ณAntonio Carlos Damacบ Data ณ  15/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ(RELACIONA PENDENCIAS DA GUIA)                              บฑฑ
ฑฑบAlteracao ณMotivo da Pend๋ncia nใo pode ficar em branco ao press <ok>  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_HP12PEN(cAliasP12, nRegP12, nOpcP12)
Local nOpcA    := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
Local nCntFor  := 1 , aCpoEnc := {	"GCZ_DATATE","GCZ_NOME","GCZ_CODTPG", "GCZ_DESTPG", "GCZ_CODPLA","GCZ_DESPLA", "GCZ_NRGUIA" }
Local aSize    := {},  aObjects := {},  aInfo, aPObjs

Private aTela  := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGEZ	 := {}, aHGEZ   := {}, nUGEZ := 0, nLGEZ := 0, oGEZ

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

RegToMemory("GCZ", .F.)

HS_BDados("GEZ", @aHGEZ, @aCGEZ, @nUGEZ, 1, M->GCZ_NRSEQG, "'" + M->GCZ_NRSEQG + "' == GEZ->GEZ_NRSEQG" )
nGEZ_CodPen := aScan(aHGEZ, {| aVet | aVet[2] == "GEZ_CODPEN"})
nGEZ_DesPen := aScan(aHGEZ, {| aVet | aVet[2] == "GEZ_DESPEN"})

DbSelectArea("GCZ")

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[ 7 ], 000 To aSize[ 6 ]/*340*/, aSize[ 5 ]/*640*/	PIXEL of oMainWnd
EnChoice("GCZ", nRegP12, nOpcP12,,,,aCpoEnc, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] },, 3,,,,,, .F.,,,.T.)
oGEZ := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,,,,,,,,,, oDlg, aHGEZ, aCGEZ)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
{ || Iif ( ( nOpcA := FS_Verifica() ) == 1, oDlg:End(), )},;
{ || nOpcA := 0, oDlg:End() } )

If nOpcA == 1
	Begin Transaction
	FS_GrvP12()
	End Transaction
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Verifica()
Local nRet := 0

If oGEZ:TudoOk() .And. Obrigatorio(aGets, aTela) .And. !VAZIO(oGEZ:aCols[1,1])
	nRet := 1
ElseIf VAZIO(oGEZ:aCols[1,1])
	HS_MsgInf(STR0151,STR0016,STR0152) //"Motivo da Pend๋ncia nใo pode ficar em branco"###"Aten็ใo"###"Relacionar Pend๋ncias na Guia"
Endif

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvP12()
Local   nItem 				:= 0
Local   cAliasOld := Alias(), lAchou := .F.

For nItem := 1 To Len(oGEZ:aCols)
	DbSelectArea("GEZ")
	DbSetOrder(1) //GEZ_FILIAL+GEZ_NRSEQG+GEZ_CODPEN
	lAchou := DbSeek(xFilial("GEZ") + M->GCZ_NRSEQG + oGEZ:aCols[nItem, nGEZ_CodPen])
	If oGEZ:aCols[nItem, Len(oGEZ:aCols[nItem])] .And. lAchou /* exclusao */
		RecLock("GEZ", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("GEZ")
	Else
		RecLock("GEZ", !lAchou)
		HS_GRVCPO("GEZ", oGEZ:aCols, oGEZ:aHeader, nItem)
		GEZ->GEZ_FILIAL := xFilial("GEZ")
		GEZ->GEZ_NRSEQG := M->GCZ_NRSEQG
		GEZ->GEZ_LOGARQ := HS_LogArq()
		MsUnlock()
	EndIf
Next

DbSelectArea(cAliasOld)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldP12()
Local lRet := .F., cGENomLoc := ""

If ReadVar() $ "M->GD5_CODLOC/M->GD6_CODLOC/M->GD7_CODLOC/M->GE5_CODLOC/M->GE6_CODLOC/M->GE7_CODLOC" // Validacao do setor

	If     SubStr(ReadVar(), 4, 3) $ "GD5/GE5"
		cGENomLoc := "oGDMM:aCols[oGDMM:nAt, nMMNomLoc]"
	ElseIf SubStr(ReadVar(), 4, 3) $ "GD6/GE6"
		cGENomLoc := "oGDTD:aCols[oGDTD:nAt, nTDNomLoc]"
	ElseIf SubStr(ReadVar(), 4, 3) $ "GD7/GE7"
		cGENomLoc := "oGDPR:aCols[oGDPR:nAt, nPRNomLoc]"
	EndIf

	If !(lRet := !Empty(&(ReadVar())))
		MsgInfo(STR0177, STR0016) // "Aten็ใo"###"O codigo do setor ้ obrigatorio"
	ElseIf !(lRet := HS_SeekRet("GCS","'" + &(ReadVar()) + "'", 1, .F., cGENomLoc, "GCS_NOMLOC"))
		MsgInfo(STR0136, STR0016) // "Aten็ใo"###"Setor nใo encontrado"
	ElseIf lRet := HS_VldCSet(&(ReadVar()), Nil, cGcsTipLoc, HS_RDescrB("GCY_ATENDI", GCY->GCY_ATENDI))
		HS_DefVar("GCS", 1, &(ReadVar()), {{"cGcsCodLoc", "GCS->GCS_CODLOC"}, ;
		{"cGcsCodCCu", "GCS->GCS_CODCCU"}, ;
		{"cGcsArmSet", "GCS->GCS_ARMSET"}, ;
		{"cGcsArmFar", "GCS->GCS_ARMFAR"}})
	EndIf

EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_P12SEL บAutor  ณ Jos้ Orfeu        บ Data ณ  20/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Verifica se as guias possuem despesas sem valoriza็ใo e ouบฑฑ
ฑฑบ          ณ  guias sem despesas.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_P12SEL(cModo)
Local cSql := ""
Local nQtdDesp := 0
Local aQtdDesp := {0, 0, 0}
Local aRetDesp := {.T., .T., .T.}
Local aArea    := GetArea()
Local aAlias   := IIf(cModo == "P", {"GD5", "GD6", "GD7"}, {"GE5","GE6","GE7"})
Local nFAlias  := 0
Local cADesp   := ""
Local cPDesp   := ""
Local cFili    := ""
Local aRetDsc  := {.T., .T., .T.}

For nFAlias := 1 To Len(aAlias)

	cADesp := aAlias[nFAlias]
	cPDesp := aAlias[nFAlias] + "." + aAlias[nFAlias]

	cFili  := IIF(EMPTY(xFilial(cADesp)), "", GCZ->GCZ_FILATE)

	// Verifica se existe despesas de mat/med, taxas e diarias ou procedimentos na guia
	cSql := "SELECT Count(*) nDespesas "
	cSql += "FROM " + RetSQLName(cADesp) + " " + cADesp + " "
	cSql += "WHERE " + cPDesp + "_FILIAL = '" + cFili + "' AND " + cADesp + ".D_E_L_E_T_ <> '*' AND " + cPDesp + "_NRSEQG = '" + GCZ->GCZ_NRSEQG + "'"
	TCQUERY cSQL NEW ALIAS "QRYCNT"
	DbSelectArea("QRYCNT")

	aQtdDesp[nFAlias] := QRYCNT->nDespesas
	nQtdDesp          += QRYCNT->nDespesas

	DbCloseArea()

	If aQtdDesp[nFAlias] > 0

		// Verifica se existe despesas de mat/med, taxas e diarias ou procedimentos sem valoriza็ao
		cSql := "SELECT Count(*) nDespesas "
		cSql += "FROM " + RetSQLName(cADesp) + " " + cADesp + " "
		cSql += "WHERE " + cPDesp + "_FILIAL = '" + cFili + "' AND " + cADesp + ".D_E_L_E_T_ <> '*' AND " + cPDesp + "_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' AND "
		cSql += " " + HS_FValDes(cADesp) + " = 0 "
		TCQUERY cSQL NEW ALIAS "QRYCNT"
		DbSelectArea("QRYCNT")

		aRetDesp[nFAlias] := QRYCNT->nDespesas == 0

		DbCloseArea()

		If aRetDesp[nFAlias]		//HS_ExisDic({{"C", cADesp + "_DESVAL"}}, .F.) .And. 

			// Verifica se existe despesas de mat/med, taxas e diarias ou procedimentos com valor unitario maior que o desconto
			cSql := "SELECT Count(*) nDespesas "
			cSql += "FROM " + RetSQLName(cADesp) + " " + cADesp + " "
			cSql += "WHERE " + cPDesp + "_FILIAL = '" + cFili + "' AND " + cADesp + ".D_E_L_E_T_ <> '*' AND " + cPDesp + "_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' AND "
			cSql += HS_FVALDES(cADesp,,,,.F.) + " < "  + cPDesp + "_DESVAL "
			TCQUERY cSQL NEW ALIAS "QRYCNT"
			DbSelectArea("QRYCNT")

			aRetDsc[nFAlias] := QRYCNT->nDespesas == 0

			DbCloseArea()

		EndIf

	EndIf

Next

RestArea(aArea)
Return({aRetDesp[1], aRetDesp[2], aRetDesp[3], nQtdDesp, aRetDsc})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DOCSFAT บAutor  ณGilson da Silva    บ Data ณ  20/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara as guias selecionadas para a impressao dos relato- บฑฑ
ฑฑบ          ณ rios da capa da fatura (HSPAHRD3) e/ou descritiva da fatu- บฑฑ
ฑฑบ          ณ ra (HSPAHRC6).                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_DocsFat(nOpc)
Local aArea := GetArea()

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If nOpc == 1 .or. nOpc == 3
	HSPAHRD3("HSPAHP12", __aMarkBrow)
Endif

If nOpc == 2 .or. nOpc == 3
	HSPAHRC6("HSPAHP12", __aMarkBrow)
EndIf

If nOpc == 4
	GDN->(dbSetOrder(1))
	If GDN->(DbSeek(xFilial("GDN") + GCZ->GCZ_LOCATE))
		HSPAHP44(.F., GCZ->GCZ_LOCATE,{{"GCY", 1, GCZ->GCZ_REGATE}, {"GBH", 1, GCY->GCY_REGGER}})
	EndIf
EndIf

If nOpc == 5
	HSPAHR15("HSPAHP12", __aMarkBrow)
EndIf
RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_LEGHP12ณ Autor ณGilson da Silva        ณ Data ณ25/02/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Define as Legendas utilizadas no Gera Fatura        	  		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ NENHUM			                                         	        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ NIL				                                           	        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12                                          		   		  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_LEGHP12()
Local aLegenda := {{"BR_BRANCO"  , OemToAnsi(STR0169)}, ; //"Controle de Contas"
                   {"BR_VERDE"   , OemToAnsi(STR0061)}, ; //"Conferencia"
                   {"BR_AMARELO" , OemToAnsi(STR0062)}, ; //"Gerado Faturamento"
                   {"BR_VERMELHO", OemToAnsi(STR0116)}, ; //"Lote Atribuido"
                   {"BR_MARROM"  , OemToAnsi(STR0170)}, ; //"Gerado Faturas"
                   {"BR_AZUL"    , OemToAnsi(STR0171)}, ; //"Associado Extr.Conv."
                   {"BR_PRETO"   , OemToAnsi(STR0172)}, ; //"Liquidado"
                   {"BR_CINZA"   , OemToAnsi("Quitado")}, ; //"Liquidado"
                   {"BR_PINK"   , OemToAnsi("Reapresent. SUS")},;
                   {"BR_LARANJA"   , OemToAnsi("Repasse Particular")}}

BrwLegenda(cCadastro, STR0063, aLegenda) //"Gera Faturamento"
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ HS_GrvDAtG บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ Grava campos das guias GCZ buscando do atendimento GCY       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12 - APAC                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_GrvDAtG()

If MsgYesNo(STR0137) //"Confirma processamento"
	Processa({|| FS_GrvDAtG() })
EndIf

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvDAtG()

DbSelectArea("GCZ")
DbSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
DbSeek(xFilial("GCZ"))

ProcRegua(RecCount())

While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ")

	IncProc("DATATE,ATENDI,LOCATE,CANCEL Guia " + GCZ->GCZ_NRSEQG)

	DbSelectArea("GCY")
	DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
	If DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

		RecLock("GCZ", .F.)
		GCZ->GCZ_DATATE := GCY->GCY_DATATE
		GCZ->GCZ_ATENDI := GCY->GCY_ATENDI
		GCZ->GCZ_LOCATE := GCY->GCY_LOCATE
		GCZ->GCZ_CANCEL := IIf(GCY->GCY_TPALTA == "99", "1", "0")
		MsUnLock()

	EndIf

	DbSelectArea("GCZ")
	DbSkip()
End

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_RenDesp()

 If MsgYesNo(STR0137) //"Confirma processamento"
  Processa({|| FS_RenDesp() })
 EndIf

Return(NIl)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_RenDesp()
 Local cSeqDes := "", nTSeqDes := 0, nRecCount := 0
 Local aAlias := {"GE5", "GE6", "GD7", "GE7"}, nFAlias := 0
 Local cDesSeqDes := "", cDesFilial := ""
 Local cSqlCnt := "", lContinua := .T., nUpdTran := 0

 For nFAlias := 1 To Len(aAlias)

  cSqlCnt := "SELECT COUNT(*) NRCOUNT FROM " + RetSqlName(aAlias[nFALias]) + " WHERE D_E_L_E_T_ <> '*' AND " + aAlias[nFALias] + "_FILIAL = '" + xFilial(aAlias[nFALias]) + "'"
  TCQuery cSqlCnt New Alias "RCNT"
  DbSelectArea("RCNT")

  nRecCount := RCNT->NRCOUNT

  DbCloseArea()

  DbSelectArea(aAlias[nFAlias])
  DbSetOrder(3)
  DbSeek(xFilial(aAlias[nFAlias]))

  ProcRegua(nRecCount)

  cDesSeqDes := aAlias[nFAlias] + "->" + aAlias[nFAlias] + "_SEQDES"
  cDesFilial := aAlias[nFAlias] + "->" + aAlias[nFAlias] + "_FILIAL"

  nTSeqDes := Len(&(cDesSeqDes))
  cSeqDes  := Replicate("0", nTSeqDes)

  lContinua := .T.

  While lContinua

   Begin Transaction

    nUpdTran := 0

    While (lContinua := (!Eof() .And. &(cDesFilial) == xFilial(aAlias[nFAlias]))) .And. nUpdTran <= 1024

     nUpdTran++

     cSeqDes := Soma1(cSeqDes, nTSeqDes)

     IncProc(STR0138 + aAlias[nFAlias] + "][" + cSeqDes + "][" + StrZero(nRecCount, 8) + "]") //"Renumerando ["

     RecLock(aAlias[nFAlias], .F.)
      &(cDesSeqDes) := cSeqDes
     MsUnLock()

     DbSkip()
    End

   End Transaction

  End
 Next

 HS_MsgInf(STR0139, STR0016, STR0140) //"Delete os registros controladores da numeracao automatica dos arquivos GE5, GE6, GE7 e GD7 dos arquivos SXE e SXF"###"Aten็ใo"###"Renumeracao finalizada"

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_GSGE2GD()

 If MsgYesNo(STR0137) //"Confirma processamento"
  Processa({|| FS_GSGE2GD() })
 EndIf

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GSGE2GD()
 Local cSqlCnt := "", lContinua := .T., nUpdTran := 0
 Local nFAlias := 0, nRecCount := 0, nRecAtu := 0, nLenSeqFat := 0, cFilialFat := ""
 Local aAlias := {{"GD5", "GE5", "GE5->GE5_REGATE + GE5->GE5_NRSEQG + GE5->GE5_CODDES + Space(Len(GD5->GD5_SEQGE5))"                  , "GD5->GD5_SEQGE5", "GE5->GE5_SEQDES"}, ;
                  {"GD6", "GE6", "GE6->GE6_REGATE + GE6->GE6_NRSEQG + GE6->GE6_CODDES + Space(Len(GD6->GD6_SEQGE6))"                  , "GD6->GD6_SEQGE6", "GE6->GE6_SEQDES"}, ;
                  {"GD7", "GE7", "GE7->GE7_REGATE + GE7->GE7_NRSEQG + GE7->GE7_CODDES + GE7->GE7_CODATO + Space(Len(GD7->GD7_SEQGE7))", "GD7->GD7_SEQGE7", "GE7->GE7_SEQDES"}}

 For nFAlias := 1 To Len(aAlias)

  cSqlCnt := "SELECT COUNT(*) NRCOUNT FROM " + RetSqlName(aAlias[nFAlias][2]) + " WHERE D_E_L_E_T_ <> '*' AND " + aAlias[nFAlias][2] + "_FILIAL = '" + xFilial(aAlias[nFAlias][2]) + "'"
  TCQuery cSqlCnt New Alias "RCNT"
  DbSelectArea("RCNT")

  nRecCount := RCNT->NRCOUNT

  DbCloseArea()

  DbSelectArea(aAlias[nFAlias][1])
  DbSetOrder(3)

  nLenSeqFat := Len(&(aAlias[nFAlias][4]))

  DbSelectArea(aAlias[nFAlias][2])
  DbSetOrder(1)
  DbSeek(xFilial(aAlias[nFAlias][2]))

  ProcRegua(nRecCount)

  cFilialFat := aAlias[nFAlias][2] + "->" + aAlias[nFAlias][2] + "_FILIAL"

  lContinua := .T.
  nRecAtu   := 0

  While lContinua

   Begin Transaction

    nUpdTran  := 0
    While (lContinua := (!Eof() .And. &(cFilialFat) == xFilial(aAlias[nFAlias][2]))) .And. nUpdTran <= 1024

     nRecAtu++

     IncProc(STR0158 + aAlias[nFAlias][1] + "][" + StrZero(nRecAtu, 8) + "][" + StrZero(nRecCount, 8) + "]") //"Gravando ["

     DbSelectArea(aAlias[nFAlias][1])
     If DbSeek(xFilial(aAlias[nFAlias][1]) + &(aAlias[nFAlias][3]) + Space(nLenSeqFat))
      nUpdTran++

      RecLock(aAlias[nFAlias][1], .F.)
       &(aAlias[nFAlias][4]) := &(aAlias[nFAlias][5])
      MsUnLock()
     EndIf

     DbSelectArea(aAlias[nFAlias][2])
     DbSkip()
    End

   End Transaction

  End

 Next
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MatMed(cCodDes)
Local aAreaOld := GetArea()
Local cTipo := ""

 DbSelectArea("GBI")
 DBSetOrder(1) //GBI_FILIAL+GBI_PRODUT
 DbSeek(xFilial("GBI") + cCodDes)
 cTipo := GBI->GBI_TIPO

RestArea(aAreaOld)

Return(cTipo)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TotDesLบAutor  ณDaniel Peixoto      บ Data ณ  24/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a qtd total da despesa lancada no periodo           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_TotDesL(cTipoMat, aMatDesp, cCodigo)
Local nTotDesLan := 0
Local nCont      := 0

 For nCont := 1 To Len(aMatDesp)
  If aMatDesp[nCont, 1] == cCodigo .And. IIF(cTipoMat == "GD", EMPTY(aMatDesp[nCont, 6]), .T.)// nao conta os que pertencem a Proced Padr.
   nTotDesLan += aMatDesp[nCont, IIF(cTipoMat == "GPP", 3, 2)]
  EndIf
 Next

Return(nTotDesLan)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGEGGบAutor  ณDaniel Peixoto      บ Data ณ  11/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de gravacao das despesas lancadas nos arquivos       บฑฑ
ฑฑบ          ณGE - Conta Aberta ou GG - coberto pelo pacote               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvGEGG(cCodPro, cTab, cAliasGD, cAliasGEGG, cTipDes, aRetQtd)
Local aAreaOld  := GetArea()
Local cPArqGD   := cAliasGD + "->" + PrefixoCpo(cAliasGD)
Local cPArqGEGG := cAliasGEGG + "->" + PrefixoCpo(cAliasGEGG)
Local cAliasGE  := STRTRAN(cAliasGD, "D", "E")
Local cCposNao  := cAliasGD+"_FILIAL/"+cAliasGD+"_SEQDES/"+cAliasGD+"_LOGARQ/"+cAliasGD+"_FATPAR/"+cAliasGD+"_CODPCO"
Local nFieldGd  := 0
Local aRValDes  := {}
Local nCount 	  := 0

 cCposNao += IIf(cTipDes == "0/1", "/GD5_SOLICI/GD5_ITESOL/GD5_QTDVOL/GD5_SEQGE5", ;
             IIF(cTipDes == "2"  , "/GD6_SEQGE6", ;
                                   "/GD7_SEQGE7/GD7_SLAUDO/GD7_CRMLAU/GD7_NMELAU/GD7_DESREG/GD7_FACDES/GD7_NUMORC/GD7_ITEORC/GD7_ITEFAT") )

 If EMPTY(&(cPArqGD + "_SEQ"+cAliasGE))
  DbSelectArea(cAliasGEGG)
  &("M->"+cAliasGEGG+ "_SEQDES") := HS_VSxeNum(cAliasGEGG, "M->"+cAliasGEGG+"_SEQDES", IIF(cTab == "GE", 1, 2))
  ConfirmSx8()
 	RecLock(cAliasGEGG,.T.)
   nCount := &(cAliasGD + "->(FCount())")
   For nFieldGd := 1 To nCount
   	If !( &(cAliasGD + "->(FieldName("+ALLTRIM(STR(nFieldGd))+"))") $ cCposNao)
   		&(cPArqGEGG + SubStr(&(cAliasGD + "->(FieldName("+ALLTRIM(STR(nFieldGd))+"))"), 4)) := &(cAliasGD + "->&(FieldName("+ALLTRIM(STR(nFieldGd))+"))")
   	EndIf
   Next

 	 &(cPArqGEGG + "_FILIAL") := xFilial(cAliasGEGG)
   &(cPArqGEGG + "_SEQDES") := &("M->"+cAliasGEGG+"_SEQDES")
   If cTab == "GG"
    &(cPArqGEGG + "_SEQGE7") := cSeqPct
   EndIf
   If cAliasGD == "GD7"
    &(cPArqGEGG + "_CODCON") := GCZ->GCZ_CODCON
   EndIf
  	&(cPArqGEGG + "_CODPCO") := cCodPro
 	 &(cPArqGEGG + "_QTDDES") := aRetQtd[IIF(cTab == "GE", 2, 1)]
  	&(cPArqGEGG + "_LOGARQ") := HS_LogArq()
 	MsUnlock()

  //Grava nos GDs a SEQDES dos GEs/GGs qdo s๓ tiver GE ou GG e se tiver as duas grava s๓ na GG(depois de gravar as GEs)
  If aRetQtd[1] == 0 .Or. aRetQtd[2] == 0 .Or. (aRetQtd[1] > 0 .And. aRetQtd[2] > 0 .And. cTab == "GG")
   DbSelectArea(cAliasGD)
   RecLock(cAliasGD, .F.)
    &(cPArqGD + "_SEQ"+cAliasGE) := IIF(cTab == "GE", &("M->"+cAliasGEGG+"_SEQDES"), cSeqPct)
    &(cPArqGD + "_CODPCO")       := cCodPro
   MsUnLock()
  EndIf
 EndIf

 RestArea(aAreaOld)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvProPบAutor  ณDaniel Peixoto      บ Data ณ  26/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava todas despesas lan็adas na guia  pertencentes ao proc.บฑฑ
ฑฑบ          ณPadrao passado no parametro, menos o Proc. principal        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvProP(cCodPro, cTipTab, cNrSeqG, cCodPct, cSeqPrinc, aQtdPrPri)
Local aAreaOld  := GetArea()
Local aVetAlias := {{"GD5", "GE5","GG5", "0/1", "0"}, {"GD6", "GE6", "GG6", "2", "2"}, {"GD7", "GE7", "GG7", "3", "1"}}
Local aVetPArq  := {{"GD5->GD5"}, {"GD6->GD6"}, {"GD7->GD7"}}
Local aRetQtd   := {0, 0}
Local nCont     := 0

 For nCont := 1 To 3
 	DbSelectArea(aVetAlias[nCont, 1])
  DBSetOrder(2)//2/NRSEQG
  If DbSeek(xFilial(aVetAlias[nCont, 1]) + cNrSeqG)
   While !EOF() .And. &(aVetPArq[nCont,1] + "_FILIAL") == xFilial(aVetAlias[nCont, 1]) .And. &(aVetPArq[nCont,1] + "_NRSEQG") == cNrSeqG
    If &(aVetPArq[nCont,1] + "_CODPCT") == cCodPct .And. &(aVetPArq[nCont,1] + "_SEQDES") <> cSeqPrinc //Grava todos itens do pacote menos o pricipal que ja foi gravado
     aRetQtd[1] := IIF(cTipTab == "GE", 999, FS_QtdProP("GG", cCodPct, &(aVetPArq[nCont,1] + "_CODDES"), aVetAlias[nCont, 5], &(aVetPArq[nCont,1] + "_QTDDES"), aQtdPrPri)) //inclusas no pacote
     aRetQtd[2] := IIF(cTipTab == "GE", FS_QtdProP("GE", cCodPct, &(aVetPArq[nCont,1] + "_CODDES"), aVetAlias[nCont, 5], &(aVetPArq[nCont,1] + "_QTDDES"), aQtdPrPri), 999) //excedidas
    	FS_GrvGEGG(cCodPro, cTipTab, aVetAlias[nCont, 1], aVetAlias[nCont, IIF(cTipTab == "GE", 2, 3)], aVetAlias[nCont, 4], aRetQtd)
    EndIf
    DbSelectArea(aVetAlias[nCont, 1])
    DBSkip()
   EndDo
  EndIf
 Next

 RestArea(aAreaOld)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ProPLanบAutor  ณDaniel Peixoto      บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se existe o procediemnto/taxa principal do          บฑฑ
ฑฑบ          ณProcedimento Padrao lan็ado na guia                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC01 - Numero Sequencial da Guia                  					  ณฑฑ
ฑฑณ          ณ ExpC02 - Codigo do Procedimento Padrao       		        		  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ProPLan(cNrSeqG, cCodPct)
Local aAreaOld := GetArea()
Local nCont    := 0
Local lRet     := .F.
Local aVetAlias:= {{"GD6","GD6->GD6","GA1->GA1_CODTXD"}, {"GD7","GD7->GD7","GA1->GA1_CODPRO"}}

Default cCodPct := ""

 If !EMPTY(cCodPct)
  For nCont := 1 To 2
   DbSelectArea("GA1")
   DBSetOrder(1) //GA1_FILIAL+GA1_CODPCT
   If DbSeek(xFilial("GA1") + cCodPct)
    DbSelectArea(aVetAlias[nCont, 1])
    DBSetOrder(2)//2/NRSEQG
    If DbSeek(xFilial(aVetAlias[nCont, 1]) + cNrSeqG)
     While !EOF() .And. &(aVetAlias[nCont, 2] + "_FILIAL") == xFilial(aVetAlias[nCont, 1]) .And. &(aVetAlias[nCont, 2] + "_NRSEQG") == cNrSeqG
      If &(aVetAlias[nCont, 2] + "_CODPCT") == cCodPct .And. &(aVetAlias[nCont, 2] + "_CODDES") == &(aVetAlias[nCont, 3])
       RestArea(aAreaOld)
       Return(.T.)
      EndIf
      DBSkip()
     EndDo
    EndIf
   EndIf
  Next
 EndIf

 RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CpoObrP(aColsPct)
Local nCont := 0

For nCont := 1 to Len(aColsPct)
 If !aColsPct[nCont, Len(aColsPct[nCont])]
 If EMPTY(aColsPct[nCont, n_CodPro]) .Or. EMPTY(aColsPct[nCont, n_DatIni]) .Or. ;
    EMPTY(aColsPct[nCont, n_DatFin])
  HS_MsgInf(STR0184,STR0142, STR0161) //"Campo obrigat๓rio em branco, Aba [Pacote]"###"Atencao"###"Faturamento por Pacote"
  Return(.F.)
 EndIf
 EndIf
Next

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CpoObrI(aColsInt, lMsgAba)
Local nCont := 0

Default lMsgAba := .F.

For nCont := 1 to Len(aColsInt)
 If !aColsInt[nCont, Len(aColsInt[nCont])]
 If !EMPTY(aColsInt[nCont, n_CodProI]) .And. (EMPTY(aColsInt[nCont, n_DatIniI]) .Or. ;
    EMPTY(aColsInt[nCont, n_HorIniI]) .Or. EMPTY(aColsInt[nCont, n_DatFinI]) .Or. ;
    EMPTY(aColsInt[nCont, n_HorFinI]) .Or. EMPTY(aColsInt[nCont, n_CodLocI]))
   HS_MsgInf(STR0185 + IIF(lMsgAba, STR0226, ""), STR0142, STR0161) //"Campo obrigat๓rio em branco"###"Atencao"###"Faturamento por Pacote" //", Aba [Intercorr๊ncia]"
  Return(.F.)
 EndIf
 EndIf
Next

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CrmPct(aColsPct)
 Local aAreaOld := GetArea()
 Local nCont    := 0

 For nCont := 1 to Len(aColsPct)
  If !aColsPct[nCont, Len(aColsPct[nCont])]
  If !EMPTY(aColsPct[nCont, n_CodCrm]) .And. EMPTY(HS_IniPadR("SRA", 11, aColsPct[nCont, n_CodCrm], "RA_CODIGO",, .F.))
   HS_MsgInf(STR0191, STR0016, STR0161) //"CRM do m้dico nใo encontrado"###"Aten็ใo"###"Faturamento por Pacote"
   Return(.F.)
  EndIf
  EndIf
 Next

 RestArea(aAreaOld)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบFuncao    บHS_HP12Traบ Autor บ Cibele Peria       บ Data บ 24/02/2006  บฑฑ
ฑฑฬออออออออออฮออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDescricao บ Rotina de transferencia de despesas entre guias de um mes- บฑฑ
ฑฑบ          บ mo atendimento.                                            บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12Tra()
Local aArea := GetArea()
Local oDlgTra
Local oDatIni, oDatFin
Local dDatIni:= dDataBase, dDatFin := dDataBase
Local oTraMat, lTraMat := .T.
Local oTraMed, lTraMed := .T.
Local oTraRes, lTraRes := .T.
Local oTraTax, lTraTax := .T.
Local oTraDia, lTraDia := .T.
Local oTraPro, lTraPro := .T.
Local oTraIten, lTraIten := .F.
Local oNrSeqG, cNrSeqG_Pa := Space(Len(GCZ->GCZ_NRSEQG))
Local nOpcTra := 0
Local cNrSeqG_De := GCZ->GCZ_NRSEQG
Local cCodPla_De := GCZ->GCZ_CODPLA
Local cCodTpg_De := GCZ->GCZ_CODTPG
Local cCodPla_Pa := ""
Local cCodTpg_Pa := ""
Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}

Private cGCZRegAte := GCZ->GCZ_REGATE  //Variavel utilizada na funcao HS_FilGCZ (Filtro da consulta padrao GCZ)

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
EndIf

If !(GCZ->GCZ_STATUS $ "0/1")
	HS_MsgInf(STR0145, STR0016, STR0111) //"Esta guia ja foi faturada e nao pode ser alterada"###"Aten็ใo"###"Transferencia de despesas entre guias"
	RestArea(aArea)
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(.F.)
Endif

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlgTra TITLE STR0111 From aSize[ 7 ], 000 To aSize[ 6 ]/2, aSize[ 5 ]/2	Of oMainWnd Pixel //"Transferencia de despesas entre guias de mesmo atendimento"
@ aPObjs[1,1]+5 /*017*/, 005 Say STR0083 Of oDlgTra Pixel //"Data Inicial"
@ aPObjs[1,1]+3 /*015*/, 035 MSGet oDatIni Var dDatIni Picture "@D" Of oDlgTra Pixel

@  aPObjs[1,1]+5 /*017*/, 085 Say STR0084 Of oDlgTra Pixel //"Data Final"
@  aPObjs[1,1]+3 /*015*/, 115 MSGet oDatFin Var dDatFin Picture "@D" Of oDlgTra Pixel

@  aPObjs[1,1]+28 /*040*/, 005 CheckBox oTraMat Var lTraMat Prompt STR0025 Size 50, 10 Of oDlgTra PIXEL //"Materiais"
@  aPObjs[1,1]+28 /*040*/, 065 CheckBox oTraMed Var lTraMed Prompt STR0026 Size 50, 10 Of oDlgTra PIXEL //"Medicamentos"
@  aPObjs[1,1]+28 /*040*/, 125 CheckBox oTraRes Var lTraRes Prompt STR0085 Size 50, 10 Of oDlgTra PIXEL //"Res/Frigobar"

@ aPObjs[1,1]+43 /*055*/, 005 CheckBox oTraTax Var lTraTax Prompt STR0086 Size 50, 10 Of oDlgTra PIXEL //"Taxas"
@ aPObjs[1,1]+43 /*055*/, 065 CheckBox oTraDia Var lTraDia Prompt STR0087 Size 50, 10 Of oDlgTra PIXEL //"Diarias"
@ aPObjs[1,1]+43 /*055*/, 125 CheckBox oTraPro Var lTraPro Prompt STR0028 Size 50, 10 Of oDlgTra PIXEL //"Procedimentos"

@ aPObjs[1,1]+58 /*070*/, 005 CheckBox oTraIten Var lTraIten Prompt STR0262 Size 50, 10 Of oDlgTra PIXEL //"Itens"
@ aPObjs[1,1]+75 /*084*/, 005 Say STR0090 Of oDlgTra Pixel //"Para guia ?"

DbSelectArea("SXB")
DbSetOrder(1)
If SXB->(DbSeek("GCZ002"))
	@ aPObjs[1,1]+74 /*086*/, 035 MSGet oNrSeqG  Var cNrSeqG_Pa F3 "GCZ002" Picture "@!" Of oDlgTra Pixel
Else
	@ aPObjs[1,1]+74 /*086*/, 035 MSGet oNrSeqG  Var cNrSeqG_Pa F3 "GCZ001" Picture "@!" Of oDlgTra Pixel
Endif

ACTIVATE MSDIALOG oDlgTra CENTERED ON INIT EnchoiceBar(oDlgTra, {|| nOpcTra := 1, IIf(HS_P12VTra(cNrSeqG_De, cNrSeqG_Pa, @cCodPla_Pa, @cCodTpg_Pa), oDlgTra:End(), nOpcTra := 9)}, ;
{|| nOpcTra := 0, oDlgTra:End()})

If nOpcTra == 1
	HS_P12ATra(cNrSeqG_De, cNrSeqG_Pa, cCodPla_De, cCodPla_Pa, cCodTpg_De, cCodTpg_Pa, dDatIni, dDatFin, lTraMat, lTraMed, lTraRes, lTraTax, lTraDia, lTraPro,lTraIten)
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบFuncao    บHS_P12VTraบ Autor บ Cibele Peria       บ Data บ 24/02/2006  บฑฑ
ฑฑฬออออออออออฮออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDescricao บ Validacao das guias informadas na transferencia            บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_P12VTra(cNrSeqG_De, cNrSeqG_Pa, cCodPla_Pa, cCodTpg_Pa)
 Local aArea := GetArea()

 If Empty(cNrSeqG_Pa)
  HS_MsgInf(STR0146, STR0016, STR0111) //"Por favor, informe o codigo da guia de destino"###"Aten็ใo"###"Transferencia de despesas entre guias"
  Return(.F.)
 Endif

 If cNrSeqG_De == cNrSeqG_Pa
  HS_MsgInf(STR0150, STR0016, STR0111) //"O codigo da guia de destino informado e o mesmo do da guia de origem"###"Aten็ใo"###"Transferencia de despesas entre guias"
  Return(.F.)
 Endif

 DbSelectArea("GCZ")
 DbSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
 If !DbSeek(xFilial("GCZ") + cNrSeqG_Pa)
  HS_MsgInf(STR0144, STR0016, STR0111) //"Guia nao encontrada"###"Aten็ใo"###"Transferencia de despesas entre guias"
  RestArea(aArea)
  Return(.F.)
 Endif

 If !(GCZ->GCZ_STATUS $ "0/1")
  HS_MsgInf(STR0145, STR0016, STR0111) //"Esta guia ja foi faturada e nao pode ser alterada"###"Aten็ใo"###"Transferencia de despesas entre guias"
  RestArea(aArea)
  Return(.F.)
 Endif

 If GCZ->GCZ_REGATE <> cGCZRegAte
  HS_MsgInf(STR0147 + cGCZRegAte, STR0016, STR0111) //"A guia de destino informada nao e do atendimento "###"Aten็ใo"###"Transferencia de despesas entre guias"
  RestArea(aArea)
  Return(.F.)
 Endif

 cCodPla_Pa := GCZ->GCZ_CODPLA
 cCodTpg_Pa := GCZ->GCZ_CODTPG

 RestArea(aArea)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_TrfGuia(cAlias, cSqlDesp, cNrSeqG_Pa, cCodPla_Pa, cCodTpG_Pa, lVldPla, lVldTpg)
 Local cAliasOld := Alias()
 Local lTrfGuia  := .F.
 Local cMsgTrfG  := ""
 Local lVCodTpg  := .F.
 Local lVCodPla  := .F.
 Local aRValDes  := {}

 cSqlDesp := ChangeQuery(cSqlDesp)

 TCQUERY cSqlDesp NEW ALIAS "GDTMP"

 TCSetField("GDTMP", PrefixoCpo(cAlias) + "_DATDES", "D", 8, 0)

 DbSelectArea("GDTMP")
 DbGoTop()
 While !Eof()
  If lVldTpg .Or. lVldPla
   If     cAlias == "GD5"
    lVCodTpg := IIf(lVldTpg, HS_SeekRet("GCU", "'" + cCodTpg_Pa + "'", 1, .F.,,,,, .T.) .And. GCU->GCU_MATMED == "1", .T.) // Verifica se a guia permite lancamento de Mat/Med
    lVCodPla := IIf(lVldPla, (aRValDes := HS_RValMM(cCodPla_Pa, GDTMP->GD5_CODDES,, .F., GDTMP->GD5_DATDES))[1] == 0, .T.)
   ElseIf cAlias == "GD6"
    lVCodTpg := IIf(lVldTpg, HS_SeekRet("GCU", "'" + cCodTpg_Pa + "'", 1, .F.,,,,, .T.) .And. GCU->GCU_TAXDIA == "1", .T.) // Verifica se a guia permite lancamento de Taxa/Diaria
    lVCodPla := IIf(lVldPla, (aRValDes := HS_RValTD(GDTMP->GD6_CODDES, cCodPla_Pa, GDTMP->GD6_CODLOC, .F., GDTMP->GD6_DATDES, .T.))[1] == 0, .T.)
   ElseIf cAlias == "GD7"
    lVCodTpg := IIf(lVldTpg, HS_SeekRet("GCX", "'" + cCodTpg_Pa + GDTMP->GD7_CODDES + "'", 1, .F.,,,,, .T.), .T.) // Verifica se o procedimento ้ permitido no tipo de guia
    lVCodPla := IIf(lVldPla, (aRValDes := HS_RValPr(GDTMP->GD7_CODDES, cCodPla_Pa, GDTMP->GD7_CODLOC, GDTMP->GD7_HORDES, "2",,,, .F., GDTMP->GD7_DATDES))[1] == 0, .T.)
   EndIf
   lTrfGuia := lVCodTpg .And. lVCodPla
  Else
   lTrfGuia := .T.
  EndIf

  If lTrfGuia
   DbSelectArea(cAlias)
   DbGoTo(GDTMP->R_E_C_N_O_)
   RecLock(cAlias, .F.)
    FieldPut(FieldPos(PrefixoCpo(cAlias) + "_NRSEQG"), cNrSeqG_Pa)
   MsUnLock()
  Else
   If !lVCodTpg
    If     cAlias == "GD5"
     cMsgTrfG += STR0194 + GDTMP->GD5_CODDES + STR0195 + cCodTpg_Pa + "]" + Chr(10) //"O Mat/Med      ["###"] nใo ้ permitido no tipo de guia ["
    ElseIf cAlias == "GD6"
     cMsgTrfG += STR0196 + GDTMP->GD6_CODDES + STR0197 + cCodTpg_Pa + "]" + Chr(10) //"A Taxa/Diaria  ["###"] nใo ้ permitida no tipo de guia ["
    ElseIf cAlias == "GD7"
     cMsgTrfG += STR0198 + GDTMP->GD7_CODDES + STR0195 + cCodTpg_Pa + "]" + Chr(10) //"O procedimento ["###"] nใo ้ permitido no tipo de guia ["
    EndIf
   EndIf

   If !lVCodPla
    cMsgTrfG += aRValDes[5]
   EndIf
  EndIf

  DbSelectArea("GDTMP")
  DbSkip()
 End

 DbSelectArea("GDTMP")
 DbCloseArea()

 DbSelectArea(cAliasOld)
Return(cMsgTrfG)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบFuncao    บHS_P12ATraบ Autor บ Cibele Peria       บ Data บ 24/02/2006  บฑฑ
ฑฑฬออออออออออฮออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDescricao บ Atualizacao da transferencia                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_P12ATra(cNrSeqG_De, cNrSeqG_Pa, cCodPla_De, cCodPla_Pa, cCodTpg_De, cCodTpG_Pa, dDatIni, dDatFin, lTraMat, lTraMed, lTraRes, lTraTax, lTraDia, lTraPro,lTraIten)
 Local aArea    := GetArea()
 Local cTipo    := ""
 Local cSqlDesp := ""
 Local lRevalor := cCodPla_De <> cCodPla_Pa
 Local lVldTpg  := cCodTpg_De <> cCodTpg_Pa
 Local cMsgTrfG := ""
 Local nOpcTraI :=0

 Private cMarcaT := GetMark()

 If lTraIten ==.T.
 nOpcTraI:=HS_TranIte(cNrSeqG_De,dDatIni,dDatFin)
 lTraMat:=.T.
 lTraMed:=.T.
 lTraRes:=.T.
 lTraTax:=.T.
 lTraDia:=.T.
 lTraPro:=.T.

 	If  nOpcTraI==0
		 Return()
 	Endif

 Endif

 Begin Transaction

  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ  Transferencia das despesas de Material, Medicamento e Rest/Frigobar (GD5)  ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  If lTraMat .Or. lTraMed .Or. lTraRes
   cTipo := IIf(lTraMat, "0", "")
   cTipo += IIf(lTraMed, "1", "")
   cTipo += IIf(lTraRes, "2", "")

   cTipo := HS_InSql(cTipo)

   cSqlDesp := "SELECT GD5.GD5_CODDES, GD5.GD5_DATDES, GD5.R_E_C_N_O_, GBI.GBI_TIPO "
   cSqlDesp += "FROM " + RetSqlName("GD5") + " GD5 "
   cSqlDesp += "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = GD5.GD5_CODDES AND GBI_TIPO IN (" + cTipo + ") "
   cSqlDesp += "WHERE GD5.GD5_FILIAL = '" + xFilial("GD5") + "' AND GD5.D_E_L_E_T_ <> '*' AND "
   cSqlDesp +=       "GD5.GD5_NRSEQG = '" + cNrSeqG_De + "' AND GD5.GD5_DATDES BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFin) + "'"

   If lTraIten ==.T.
   cSqlDesp +=		 "  AND GD5.GD5_IDMARC = '" + cMarcaT + "'"
   Endif
   // STR0149 foi excluida
   MsgRun(STR0199,, {|| cMsgTrfG += HS_TrfGuia("GD5", cSqlDesp, cNrSeqG_Pa, cCodPla_Pa, cCodTpG_Pa, lRevalor, lVldTpg)}) //"Aguarde, transferindo materiais e medicamentos"
  EndIf

  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ  Transferencia das despesas de Taxas e diarias (GD6)                        ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  If lTraTax .Or. lTraDia
   cTipo := IIf(lTraTax, "2", "")
   cTipo += IIf(lTraDia, "7", "")

   cTipo := HS_InSql(cTipo)

   cSqlDesp := "SELECT GD6.GD6_CODDES, GD6.GD6_DATDES, GD6.GD6_CODLOC, GD6.R_E_C_N_O_, GAA.GAA_TIPDES "
   cSqlDesp += "FROM " + RetSqlName("GD6") + " GD6 "
   cSqlDesp += "JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GD6.GD6_CODDES AND GAA_TIPDES IN (" + cTipo + ") "
   cSqlDesp += "WHERE GD6.GD6_FILIAL = '" + xFilial("GD6") + "' AND GD6.D_E_L_E_T_ <> '*' AND "
   cSqlDesp +=       "GD6.GD6_NRSEQG = '" + cNrSeqG_De + "' AND GD6.GD6_DATDES BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFin) + "'"

   If lTraIten ==.T.
   cSqlDesp +=		 "  AND GD6.GD6_IDMARC = '" + cMarcaT + "'"
   Endif
   MsgRun(STR0200,, {|| cMsgTrfG += HS_TrfGuia("GD6", cSqlDesp, cNrSeqG_Pa, cCodPla_Pa, cCodTpG_Pa, lRevalor, lVldTpg)}) //"Aguarde, transferindo taxas e diarias"
  Endif

  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ  Transferencia das despesas de procedimentos (GD7)                          ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  If lTraPro
   cSqlDesp := "SELECT GD7.GD7_CODDES, GD7.GD7_DATDES, GD7.GD7_CODLOC, GD7.GD7_HORDES, GD7.R_E_C_N_O_ "
   cSqlDesp += "FROM " + RetSqlName("GD7") + " GD7 "
   cSqlDesp += "WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' AND "
   cSqlDesp +=       "GD7.GD7_NRSEQG = '" + cNrSeqG_De + "' AND GD7.GD7_DATDES BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFin) + "'"
   If lTraIten ==.T.
   cSqlDesp +=		 "  AND GD7.GD7_IDMARC = '" + cMarcaT + "'"
   Endif

   MsgRun(STR0201,, {|| cMsgTrfG += HS_TrfGuia("GD7", cSqlDesp, cNrSeqG_Pa, cCodPla_Pa, cCodTpG_Pa, lRevalor, lVldTpg)}) //"Aguarde, transferindo procedimentos"
  Endif

  If lRevalor
   MsgRun(STR0202,, {|| HS_RevCnt(cNrSeqG_Pa, dDatIni, dDatFin, cCodPla_De, cCodPla_Pa, lTraMat, lTraMed, lTraRes, lTraTax, lTraDia, lTraPro, .T., .F., @cMsgTrfG)}) //"Aguarde, revalorizando despesas"
  EndIf

 End Transaction

 If !Empty(cMsgTrfG)
  HS_MsgInf(cMsgTrfG, STR0016, STR0203) //"Aten็ใo"###"Despesas nใo transferidas"
 EndIf

 RestArea(aArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ExluiDes(cNrSeqg)
 Local cAliasOld := Alias()
 Local aDespGe := {{"GE5", 2}, {"GE6", 2}, {"GE7", 2}, {"GG5", 3}, {"GG6", 3}, {"GG7", 3}}
 Local nForGe := 0

 For nForGe := 1 To Len(aDespGe)
  DbSelectArea(aDespGe[nForGe, 1])
  DbSetOrder(aDespGe[nForGe, 2])
  While DbSeek(xFilial(aDespGe[nForGe, 1]) + cNrSeqG)
   RecLock(aDespGe[nForGe, 1], .F., .F.)
    DBDelete()
   MsUnLock()
   WriteSx2(aDespGe[nForGe, 1])

   DbSkip()
  End
 Next

 DbSelectArea(cAliasOld)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ExluiPct(cNrSeqG)
 Local cAliasOld := Alias()
 Local aDespGd := {{"GD5", 2, "GD5->GD5_", "GE5"}, ;
                   {"GD6", 2, "GD6->GD6_", "GE6"}, ;
                   {"GD7", 2, "GD7->GD7_", "GE7"}}
 Local nForGd := 0

 For nForGd := 1 To Len(aDespGd)
  DbSelectArea(aDespGd[nForGd, 1])
  DbSetOrder(aDespGd[nForGd, 2])
  If DbSeek(xFilial(aDespGd[nForGd, 1]) + cNrSeqG)
   While !Eof() .And. &(aDespGd[nForGd, 3] + "FILIAL") == xFilial(aDespGd[nForGd, 1]) .And. &(aDespGd[nForGd, 3] + "NRSEQG") == cNrSeqG

   RecLock(aDespGd[nForGd, 1], .F.)
    &(aDespGd[nForGd, 3] + "SEQ" + aDespGd[nForGd, 4]) := Space(Len(GD5->GD5_SEQGE5))
    &(aDespGd[nForGd, 3] + "CODPCO")                    := Space(Len(GD5->GD5_CODPCO))
   MsUnLock()

    DbSelectArea(aDespGd[nForGd, 1])
   DbSkip()
   EndDo
  EndIf
 Next
 DbSelectArea(cAliasOld)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GravRELบAutor  ณEduardo Alves       บ Data ณ  05/16/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta fun็ใo ้ utilizada no Programa de Gerar o 			          บฑฑ
ฑฑบ          ณFaturamento e Gera็ใo Parcial do Faturamento, para gravar   บฑฑ
ฑฑบ          ณos Relacionamento UNICOS.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HS_HP12fat(), FS_GerPar()                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

lAteSUS := .T. - Atende SUS / .F. - Nใo Atende SUS
cAlias		:= GD7 ou GE7
cCodDES	:= Codigo do Procedimento
aPar				:= Vetor contendos os dados do SUS (HS_VMVSUS)

*/
Static Function FS_GravREL(lAteSUS, cAlias, cCodDES, aPar)

Local aVetINI 	:= {}
Local cPref 			:= cAlias + "->" + PrefixoCpo(cAlias)
Local cCodFEta := ""

/* Grava Relacionamentos Unicos na GE7 */
If lAteSUS
	cCodFEta := HS_FEtaria(&(cPref + "_REGATE"))
	aVetINI  := HS_IniPSUS(cCodDES, cCodFEta) // Parametros(Procedimento)
	If GCZ->GCZ_CODPLA == aPar[2][2]
 	If Empty(&(cPref + "_CDGATE"))
 		&(cPref + "_CDGATE") := aVetINI[2][1] // Grupo de Atendimento
 	EndIf
 	If	Empty(&(cPref + "_CDTATE"))
 		&(cPref + "_CDTATE") := aVetINI[3][1] // Tipo de Atendimento
 	EndIf

	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldPct บAutor  ณDaniel Peixoto      บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do codigo do pacote                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldPct(oObjInt, lVldConv, lVldAbaPac)
 Local lRet  := .T.
 Local aArea := GetArea()

 Default lVldConv   := .T.
 Default lVldAbaPac := .T.

 If ReadVar() == "M->HSP_CODPRO"
  If !(lRet := HS_SeekRet("GA7", "M->HSP_CODPRO", 1, .f., "HSP_DESPRO", "GA7_DESC",,, .T.))
   HS_MsgInf(STR0160, STR0016, STR0161) //"Pacote nใo encontrado"###"Aten็ใo"###"Faturamento por Pacote"
  ElseIf lVldConv .And. EMPTY(HS_IniPadr("GP0", 1, M->HSP_CODPRO + GCZ->GCZ_CODCON, "GP0_CODPRO",, .F.))
   HS_MsgInf(STR0162 + GCZ->GCZ_CODCON + STR0163, STR0016, STR0161) //"Pacote nใo encontrado no convenio ["###"] utilizado na guia"###"Aten็ใo"###"Faturamento por Pacote"
   lRet := .F.
  Else
   lRet := HS_VldISPr(M->HSP_CODPRO , GCY->GCY_DTNASC, GCY->GCY_SEXO)
  EndIf

 ElseIf ReadVar() == "M->HSPCODPROI" //Valida os pacotes na intercorrencia
  If !(lRet := HS_SeekRet("GA7", "M->HSPCODPROI", 1, .f., "HSPDESPROI","GA7_DESC",,, .T.))
   HS_MsgInf(STR0160, STR0016, STR0161) //"Pacote nใo encontrado"###"Aten็ใo"###"Faturamento por Pacote"
  ElseIf lVldConv .And. EMPTY(HS_IniPadr("GP0", 1, M->HSPCODPROI + GCZ->GCZ_CODCON, "GP0_CODPRO",, .F.))
   HS_MsgInf(STR0162 + GCZ->GCZ_CODCON + STR0163, STR0016, STR0161) //"Pacote nใo encontrado no convenio ["###"] utilizado na guia"###"Aten็ใo"###"Faturamento por Pacote"
   lRet := .F.
  ElseIf lVldAbaPac //Valida a Aba de Pacotes Normais
   If oObjInt:aCols[oObjInt:oBrowse:nAt , n_CntAbeI] == "1"
   If aScan(oPct:aCols, {| aVet | aVet[n_CodPro] == M->HSPCODPROI}) == 0
    HS_MsgInf(STR0186 + CHR(10) + STR0187, STR0016, STR0161) //"Pacote nใo cadastrado na Aba [Pacote]."###"Para faturamento em conta aberta o pacote deverแ ser informado na aba [Pacote]"###"Aten็ใo"###"Faturamento por Pacote"
    lRet := .F.
   EndIf
  ElseIf aScan(oPct:aCols, {| aVet | aVet[n_CodPro] == M->HSPCODPROI}) > 0
   HS_MsgInf(STR0188, STR0016, STR0161) //"Pacote jแ cadastrado na Aba [Pacote]"###"Aten็ใo"###"Faturamento por Pacote"
   lRet := .F.
   EndIf
  Else
   lRet := HS_VldISPr(M->HSPCODPROI , GCY->GCY_DTNASC, GCY->GCY_SEXO)
  EndIf

 ElseIf ReadVar() == "M->HSPCNTABEI"
  If !EMPTY(oObjInt:aCols[oObjInt:oBrowse:nAt , n_CodProI])
   If M->HSPCNTABEI == "1"
    If aScan(oPct:aCols, {| aVet | aVet[n_CodPro] == oObjInt:aCols[oObjInt:oBrowse:nAt , n_CodProI]}) == 0
     HS_MsgInf(STR0186 + CHR(10) + STR0187, STR0016, STR0161) //"Pacote nใo cadastrado na Aba [Pacote]."###"Para faturamento em conta aberta o pacote deverแ ser informado na aba [Pacote]"###"Aten็ใo"###"Faturamento por Pacote"
     lRet := .F.
    EndIf
   ElseIf aScan(oPct:aCols, {| aVet | aVet[n_CodPro] == oObjInt:aCols[oObjInt:oBrowse:nAt , n_CodProI]}) > 0
    HS_MsgInf(STR0188, STR0016, STR0161) //"Pacote jแ cadastrado na Aba [Pacote]"###"Aten็ใo"###"Faturamento por Pacote"
    lRet := .F.
   EndIf
  EndIf

 EndIf
 RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldDat บAutor  ณDaniel Peixoto      บ Data ณ  16/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao das datas informadas nos pacotes e intercorrenciasบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldDat(dDatLim)
 Local lRet := .T.

 Default dDatLim := CTOD("")

 If ReadVar() $ "M->HSP_DATINI/M->HSPDATINII"
  If &(ReadVar()) < GCY->GCY_DATATE
   HS_MsgInf(STR0189, STR0016, STR0161) //"Data invแlida. Menor que a data do atendimento"###"Aten็ใo"###"Faturamento por Pacote"
   lRet := .F.
  ElseIf EMPTY(dDatLim)
   If !Empty(GCY->GCY_DATALT)
   	If &(ReadVar()) > GCY->GCY_DATALT
   		HS_MsgInf(STR0190, STR0016, STR0161) //"Data invแlida. Maior que a data da alta"###"Aten็ใo"###"Faturamento por Pacote"
   		lRet := .F.
  	EndIf
   EndIf
  ElseIf !EMPTY(dDatLim) .And. &(ReadVar()) > dDatLim
   HS_MsgInf(STR0227, STR0016, STR0161) //"Aten็ใo"###"Faturamento por Pacote" //"Data invแlida. Maior que a data limite."
   lRet := .F.
  EndIf

 ElseIf ReadVar() $ "M->HSP_DATFIN/M->HSPDATFINI"
  If !Empty(GCY->GCY_DATALT)
  	If &(ReadVar()) > GCY->GCY_DATALT
   		HS_MsgInf(STR0190, STR0016, STR0161) //"Data invแlida. Maior que a data da alta"###"Aten็ใo"###"Faturamento por Pacote"
   		lRet := .F.
	EndIf
  ElseIf EMPTY(dDatLim)
   If &(ReadVar()) < GCY->GCY_DATATE
   HS_MsgInf(STR0189, STR0016, STR0161) //"Data invแlida. Menor que a data do atendimento"###"Aten็ใo"###"Faturamento por Pacote"
   lRet := .F.
  EndIf
  ElseIf !EMPTY(dDatLim) .And. &(ReadVar()) > dDatLim
   HS_MsgInf(STR0227, STR0016, STR0161) //"Aten็ใo"###"Faturamento por Pacote" //"Data invแlida. Maior que a data limite."
   lRet := .F.
  EndIf

 EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RIntCAbบAutor  ณDaniel Peixoto      บ Data ณ  01/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna um array com os intervalos existentes entre os      บฑฑ
ฑฑบ          ณperiodos informados pelos pacotes                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_RIntCAb()
 Local aRet    := {}, nForACols := 0
 Local dDatIni := GCY->GCY_DATATE

 For nForACols := 1 To LEN(oPct:aCols)
  If !oPct:aCols[nForACols, Len(oPct:aCols[nForACols])] .And. !EMPTY(oPct:aCols[nForACols, n_CodPro])
   If oPct:aCols[nForACols, n_DatIni] > dDatIni
    aADD(aRet, {dDatIni, oPct:aCols[nForACols, n_DatIni] - 1})
    dDatIni := oPct:aCols[nForACols, n_DatFin] + 1
   Else
    dDatIni := oPct:aCols[nForACols, n_DatFin] + 1
   EndIf
  EndIf
	Next
	If GCY->GCY_DATALT > dDatIni
 	aADD(aRet, {dDatIni, GCY->GCY_DATALT})
	EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_QtdProPบAutor  ณDaniel Peixoto      บ Data ณ  01/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que retorna a quantidade proporcional dos itens      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_QtdProP(cTipo, cCodPct, cCodDes, cOriDes, nQtdGDLanc, aQtdPrinc)
Local aAreaOld  := GetArea()
Local nQtd := 0 , nQtdProP := 0;

 DbSelectArea("GA1")
 DBSetOrder(1) //GA1_FILIAL+GA1_CODPCT
 DbSeek(xFilial("GA1") + cCodPct)

 DbSelectArea("GA2")
 DBSetOrder(1) //GA2_FILIAL+GA2_CODPCT+GA2_CODCPC+GA2_ORIPAC
 If DbSeek(xFilial("GA2") + GA1->GA1_CODPCT)
  While !EOF() .And. xFilial("GA2") == GA2->GA2_FILIAL .And. GA2->GA2_CODPCT == GA1->GA1_CODPCT
   If GA2->GA2_CODCPC == PadR(AllTrim(GA1->GA1_CODPRO), Len(GA2->GA2_CODCPC)) .Or. ;
      GA2->GA2_CODCPC == PadR(AllTrim(GA1->GA1_CODTXD), Len(GA2->GA2_CODCPC))  //Proc./Tax. Principal
    nQtdProP := GA2->GA2_QTDAPL
    Exit
   EndIf
   DbSkip()
  EndDo
  If DbSeek(xFilial("GA2") + GA1->GA1_CODPCT + PadR(AllTrim(cCodDes), Len(GA2->GA2_CODCPC)) + cOriDes)
   nQtd := IIF(cTipo == "GG", aQtdPrinc[1], aQtdPrinc[2]) * IIF(nQtdProP > GA2->GA2_QTDAPL, GA2->GA2_QTDAPL, GA2->GA2_QTDAPL / nQtdProP)
  EndIf
 EndIf

RestArea(aAreaOld)

Return(nQtd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ProPrinบAutor  ณDaniel Peixoto      บ Data ณ  20/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se a despesa ้ um procediemnto/taxa principal do    บฑฑ
ฑฑบ          ณProcedimento Padrao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC01 - Codigo do Procedimento Padrao      	    				      ณฑฑ
ฑฑณ          ณ ExpC02 - Codigo da Despesa                   				       	  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ProPrin(cCodPct, cCodDes)
Local aAreaOld  := GetArea()
Local lRet := .F.

 DbSelectArea("GA1")
 DBSetOrder(1) //GA1_FILIAL+GA1_CODPCT
 If DbSeek(xFilial("GA1") + cCodPct) .And. (GA1->GA1_CODPRO == cCodDes .Or. GA1->GA1_CODTXD == cCodDes)  //Proc./Tax. Principal
  lRet := .T.
 EndIf

 RestArea(aAreaOld)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LanDspDบAutor  ณDaniel Peixoto      บ Data ณ  20/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLan็a todas as despesas (Mat/Med,tax/Dia e proc.) em conta  บฑฑ
ฑฑบ          ณaberta do mesmo dia e no mesmo setor da despesa passada no  บฑฑ
ฑฑบ          ณparametro                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LanDspD(cNrSeqG, cSeqDes, dDatDes, cCodLoc)
Local aAreaOld  := GetArea()
Local nCont     := 0
Local aVetAlias := {{"GD5", "GD5->GD5", "GE5", "0/1"}, {"GD6", "GD6->GD6", "GE6", "2"}, {"GD7", "GD7->GD7", "GE7", "3"}}

 For nCont := 1 To 3
  DbSelectArea(aVetAlias[nCont, 1])
  DBSetOrder(2)//2/NRSEQG + DATDES
  If DbSeek(xFilial(aVetAlias[nCont, 1]) + cNrSeqG)
   While !EOF() .And. &(aVetAlias[nCont, 2] + "_FILIAL") == xFilial(aVetAlias[nCont, 1]) .And. &(aVetAlias[nCont, 2] + "_NRSEQG") == cNrSeqG
    If &(aVetAlias[nCont, 2] + "_SEQDES") <> cSeqDes .And. &(aVetAlias[nCont, 2] + "_DATDES") == dDatDes .And. &(aVetAlias[nCont, 2] + "_CODLOC") == cCodLoc ;
       .And. EMPTY(&(aVetAlias[nCont, 2] + "_CODPCT"))
     FS_GrvGEGG("", "GE", aVetAlias[nCont, 1], aVetAlias[nCont, 3], aVetAlias[nCont, 4], {0,&(aVetAlias[nCont, 2] + "_QTDDES")})
    EndIf
    DBSkip()
   EndDo
  EndIf
 Next

 RestArea(aAreaOld)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DespDiaบAutor  ณDaniel Peixoto      บ Data ณ  10/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que retorna se a despesa ้ uma Diแria                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DespDia(cCodTaxDia)
Local aAreaOld := GetArea()
Local lRet     := .F.

 DbSelectArea("GAA")
 DBSetOrder(1) // GAA_FILIAL+GAA_CODTXD
 If DbSeek(xFilial("GAA") + cCodTaxDia) .And. GAA->GAA_TIPDES == "7"
  lRet := .T.
 EndIf

 RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RIntercบAutor  ณDaniel Peixoto      บ Data ณ  08/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna um array com as intercorrencias do pacote passado   บฑฑ
ฑฑบ          ณno parametro                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_RInterc(aCols, cCodPro, cCntAberta)
 Local aRet    := {}, nForACols := 0

 Default cCodPro := ""

 For nForACols := 1 To LEN(aCols)
  If !aCols[nForACols, Len(aCols[nForACols])]
   If IIF(!EMPTY(cCodPro), aCols[nForACols, n_CODPROI] == cCodPro, .T.) .And. IIF(!EMPTY(cCntAberta), aCols[nForACols, n_CntAbeI] == cCntAberta, .T.)
    aADD(aRet, {aCols[nForACols, n_CodProI], ;
    												aCols[nForACols, n_DatIniI], aCols[nForACols, n_HorIniI], ;
                aCols[nForACols, n_DatFinI], aCols[nForACols, n_HorFinI], ;
                aCols[nForACols, n_CodLocI]})
  EndIf
  EndIf
	Next

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FatGrpPบAutor  ณDaniel Peixoto      บ Data ณ  13/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFatura os itens relacionados a Grupos de procedimentos      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FatGrpP(cCodPro, cTipDes)
 Local aAreaOld  := GetArea()
 Local nCont     := 0
 Local cCodGPP   := ""
 Local aRetQtd   := {}
 Local cAliasGD  := IIf(cTipDes == "0/1", "GD5", IIF(cTipDes == "2", "GD6", "GD7"))
 Local cPArqGD   := cAliasGD + "->" + PrefixoCpo(cAliasGD)
 Local cAliasGE  := IIf(cTipDes == "0/1", "GE5", IIF(cTipDes == "2", "GE6", "GE7"))
 Local cAliasGG  := IIf(cTipDes == "0/1", "GG5", IIF(cTipDes == "2", "GG6", "GG7"))


 aSort(aItensGPP,,,{|x,y| x[1] + Transform(x[4], "@E 999,999.99") < y[1] + Transform(y[4], "@E 999,999.99")})
 For nCont := 1 To Len(aItensGPP)
  If cCodGPP <> aItensGPP[nCont, 1]
   cCodGPP    := aItensGPP[nCont, 1]
   nQtdCob    := aItensGPP[nCont, 7]
   nQtdTotDes := FS_TotDesL("GPP", aItensGPP, cCodGPP)//qtd total despesa lancadas no Grupo
  EndIf

  aRetQtd := {0, 0}
  If nQtdTotDes > nQtdCob //Excedeu
   If nQtdCob >= aItensGPP[nCont, 3] //Gera GG
    aRetQtd[1] := aItensGPP[nCont, 3]
    nQtdCob -= aItensGPP[nCont, 3]
   ElseIf nQtdCob > 0 //Gera GE e GG
    aRetQtd[1] := nQtdCob
    aRetQtd[2] := aItensGPP[nCont, 3] - nQtdCob
    nQtdCob := 0
   Else //Gera GE
    aRetQtd[2] := aItensGPP[nCont, 3]
   EndIf
  Else //Cobre
   aRetQtd[1] := nQtdTotDes
  EndIf
  DbSelectArea("GD7")
  DBSetOrder(1) //GD7_FILIAL+GD7_SEQDES
  DbSeek(xFilial("GD7") + aItensGPP[nCont, 6])
  If aRetQtd[2] > 0 //grava excecoes do pacote GE
 	 FS_GrvGEGG(cCodPro, "GE", cAliasGD, cAliasGE, cTipDes, aRetQtd)//grava o Procedimento Princ.
   If !EMPTY(aItensGPP[nCont, 8]) //Esta em Proced Pad.
  	 FS_GrvProP(cCodPro, "GE", GCZ->GCZ_NRSEQG, GD7->GD7_CODPCT, aItensGPP[nCont, 6], aRetQtd) //grava Todos Itens do proced. padrao na GE
   EndIf
  EndIf
  If aRetQtd[1] > 0 //grava despesas inclusas no pacote GG
  	FS_GrvGEGG(cCodPro, "GG", cAliasGD, cAliasGG, cTipDes, aRetQtd)//grava o Procedimento Princ.
  	If !EMPTY(aItensGPP[nCont, 8]) //Esta em Proced Pad.
  	 FS_GrvProP(cCodPro, "GG", GCZ->GCZ_NRSEQG, GD7->GD7_CODPCT, aItensGPP[nCont, 6], aRetQtd) //grava Todos Itens do proced. padrao na GG
   EndIf
  EndIf
 Next

RestArea(aAreaOld)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGE7PบAutor  ณDaniel Peixoto      บ Data ณ  14/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que grava na GE7 o procedimento do tipo pacote que   บฑฑ
ฑฑบ          ณesta sendo faturado                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvGE7P(cCodPro, cCodCrm, dDatIni)
Local aAreaOld  := GetArea()
Local aRValDes  := {}
Local cHorDes   := GCY->GCY_HORATE

aRValDes := HS_RValPr(cCodPro, GCZ->GCZ_CODPLA, GCY->GCY_LOCATE, cHorDes, "2", cCodCrm, , {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE},, dDATINI )
DbSelectArea("GE7")
M->GE7_SEQDES	:= HS_VSxeNum("GE7", "M->GE7_SEQDES", 1)

If Type("cSqPtGE") <> "U"
	cSqPtGE	:= M->GE7_SEQDES
EndIf

RecLock("GE7",.T.)
	GE7->GE7_FILIAL := xFilial("GE7")
	GE7->GE7_CODLOC := GCY->GCY_LOCATE
	GE7->GE7_DATDES := dDATINI
	GE7->GE7_HORDES := cHorDes
	GE7->GE7_QTDDES := 1
	GE7->GE7_CODDES := cCodPro
	GE7->GE7_CODCRM := cCODCRM
	GE7->GE7_COEFAM := aRValDes[2][1][2]
	GE7->GE7_VALDES := aRValDes[2][1][1]
	GE7->GE7_VFILME := aRValDes[2][3]
	GE7->GE7_VCUSOP := aRValDes[2][2]
	GE7->GE7_PCUDES := aRValDes[3]
	GE7->GE7_URGDES := aRValDes[2][14]
	GE7->GE7_GLODES := IIf(aRValDes[4][1], "2", "0")
	GE7->GE7_COECHP := aRValDes[2][10]
	GE7->GE7_COEDES := 1
	GE7->GE7_QTDCHP := aRValDes[2][11]
 	GE7->GE7_CODESP := GA7->GA7_CODESP
 	GE7->GE7_PGTMED := aRValDes[9][1]
 	GE7->GE7_COECHM := aRValDes[9][aRValDes[11]]
 	GE7->GE7_REPAMB := aRValDes[9][aRValDes[10]]
 	If HS_IniPadr("GA7", 1, cCodPro, "GA7_DOPLER",, .F.) == "0"
 		GE7->GE7_DOPLER := "0"
 	EndIf

 	If cMV_AteSus == "S" // Se atende SUS
		If GCZ->GCZ_CODPLA == __cCodBPA // Se atende SUS e o tipo de plano eh BPA
    		GE7->GE7_CDGATE := aRValDes[15][2][1]
    		GE7->GE7_CDTATE := aRValDes[15][3][1]
   		EndIf
	EndIf

 	GE7->GE7_VALREP := GE7->GE7_QTDDES * aRValDes[9][14]
 	GE7->GE7_CODCON := GCZ->GCZ_CODCON
 	GE7->GE7_CODPRE := HS_RPreMed(cCODCRM, GCY->GCY_LOCATE)
 	GE7->GE7_SEQDES := M->GE7_SEQDES
 	GE7->GE7_NRSEQG := GCZ->GCZ_NRSEQG
 	GE7->GE7_REGATE := GCZ->GCZ_REGATE
 	GE7->GE7_ORIDES := "0"
 	GE7->GE7_CODPRT := aRValDes[2][15]
 	GE7->GE7_DESPRT := aRValDes[2][18]
 	GE7->GE7_LOGARQ := HS_LogArq()
 	GE7->GE7_TABELA := aRValDes[2][20]
MsUnlock()

cSeqPct := GE7->GE7_SEQDES

RestArea(aAreaOld)

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldCRM()
 Local aAreaold := GetArea()
 Local lRet := .T.

  If !EMPTY(M->HSP_CODCRM) .And. !(lRet := HS_SeekRet("SRA","M->HSP_CODCRM",11,.f.,"HSP_NOMCRM","RA_NOME",,,.T.))
   HS_MsgInf(STR0191, STR0016, STR0161) //"CRM do m้dico nใo encontrado"###"Aten็ใo"###"Faturamento por Pacote"
  ElseIf EMPTY(M->HSP_CODCRM)
   oPct:aCols[oPct:oBrowse:nAt , n_NomCrm] := SPACE(30)
  EndIf

RestArea(aAreaOld)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MarkGCZบAutor  ณDaniel Peixoto      บ Data ณ  04/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a marca็ใo no campo IDMARC para que a markbrowse traga บฑฑ
ฑฑบ          ณ selecionados                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HS_MarkGCZ(aMark, lF4)
Local nCont := 0

Default lF4 := .F.

 For nCont := 1 To Len(aMark)
  DBSelectArea("GCZ")
  DBSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
  If DbSeek(xFilial("GCZ") + aMark[nCont, 1])
   RecLock("GCZ", .F.)
    GCZ->GCZ_IDMARC := IIF(lF4, ThisMark(), cMarca)
   MsunLock()
  EndIf

 Next

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MarkF4(lPergunte, nNroGuias)
Local nCont  := 0
local aMTodos:= {}, aMDesm := {}
Default nNroGuias := 0
Default lPergunte := .T.

If lPergunte
	If !Pergunte("HSP12D", .T.)
		Return()
	EndIf
	nNroGuias := MV_PAR01
EndIf


aMTodos := HS_MMarkB(@__aMarkBrow, cFilP12, .T., nNroGuias)
HS_MMarkB(@__aMarkBrow, cFilP12, , nNroGuias)
If nNroGuias == 0 //marca todos
	__aMarkBrow := aClone(aMTodos)
Else //deixa marcado apenas o nro desejado
	For nCont := 1 To Len(aMTodos)
		If (nPos := aScan(__aMarkBrow, {| aVet | aVet[1] == aMTodos[nCont, 1]}) ) > 0
			aAdd(aMDesm, {aMTodos[nCont, 1]})
		EndIf
	Next
	HS_MarkGCZ(aMDesm, .T.) //Desmarca o restante
EndIf
oMb:Refresh(.T.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SEQGE7 บAutor  ณMario Arizono       บ Data ณ  30/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona o sequencial do procedimento principal e retorna บฑฑ
ฑฑบ          ณ para gravacao do campo Sprinc na GE7.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_SEQGE7(cSPrinc)
 Local cSeqGe7 := ""
 Local cSql    := ""
 Local aArea   := GetArea()

 cSQL  := "SELECT GD7_SEQGE7 SEQGE7 "
 cSQL  += "FROM " + RetSQLName("GD7") + " "
 cSQL  += "WHERE GD7_FILIAL = '" + xFilial("GD7") + "' AND D_E_L_E_T_ <> '*' AND "
 cSQL  += "GD7_SEQDES = '" + cSPrinc + "' "

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 If !Eof()
  cSeqGe7 := QRY->SEQGE7
 Endif

 DbCloseArea()
 RestArea(aArea)

Return(cSeqGe7)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VERPCT บAutor  ณMario Arizono       บ Data ณ  02/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe despesa na guia selecionada faturada porบฑฑ
ฑฑบ          ณ pacote.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VERPCT(cNrSeqG)
 Local cSql    := ""
 Local aArea   := GetArea()
 Local lRetPct := .F.

 cSQL  := "SELECT GE5.GE5_CODDES CODDES "
 cSQL  += "FROM " + RetSQLName("GE5") + " GE5 "
 cSQL  += "WHERE GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' AND "
 cSQL  += "GE5.GE5_NRSEQG = '" + cNrSeqG + "' AND GE5.GE5_CODPCO <> '' "
 cSQL  += "UNION ALL "
 cSQL  += "SELECT GE6.GE6_CODDES CODDES "
 cSQL  += "FROM " + RetSQLName("GE6") + " GE6 "
 cSQL  += "WHERE GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' AND "
 cSQL  += "GE6.GE6_NRSEQG = '" + cNrSeqG + "' AND GE6.GE6_CODPCO <> '' "
 cSQL  += "UNION ALL "
 cSQL  += "SELECT GE7.GE7_CODDES CODDES "
 cSQL  += "FROM " + RetSQLName("GE7") + " GE7 "
 cSQL  += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL  += "WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' AND "
 cSQL  += "GE7.GE7_NRSEQG = '" + cNrSeqG + "' AND (GE7.GE7_CODPCO <> '' OR GA7.GA7_TIPPRO ='9') "

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 If !Eof()
  lRetPct := .T.
 Endif

 DbCloseArea()
 RestArea(aArea)

Return(lRetPct)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldFilF()
Local lRet     := .T.
Local aSM0     := SM0->(GetArea())
Local cFilAces := ""
Local nForFil  := 0


If !EMPTY(cFilGuia)
	DbSelectArea("SM0")
	DbSetOrder(1) // M0_CODIGO + M0_FILIAL
	If !(lRet := DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + 	cFilGuia))
		HS_MsgInf(STR0204, STR0016, STR0205) //"A filial informada nใo existe."###"Aten็ใo"###"Valida็ใo da filial"
	EndIf

	PswOrder(1)
	PswSeek(__CUSERID, .T.)
	For nForFil := 1 To Len(PSWRET(2)[1][6])
		cFilAces += SUBSTR(PSWRET(2)[1][6][nForFil], 3, FWSizeFilial()) + IIF(nForFil < Len(PSWRET(2)[1][6]), "/", "")
	Next

	If lRet .And. At("@", cFilAces) == 0
		If !(lRet := IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL) $ cFilAces)
			HS_MsgInf(STR0206, STR0016, STR0205) //"Usuแrio sem acesso a essa filial"###"Aten็ใo"###"Valida็ใo da filial"
		EndIf
	EndIf

	If lRet .And. cFilGuia <> cFilAnt
		If !Empty(xFilial("GA9")) .Or. !Empty(xFilial("GCM"))
			HS_MsgInf(STR0207, STR0016, STR0205) //"Nใo ้ possํvel informar uma filial diferente da atual sem que as tabelas de Conv๊nio e Plano sejam compartilhadas"###"Aten็ใo"###"Valida็ใo da filial"
			lRet := .F.
		EndIf
	EndIf

EndIf

RestArea(aSM0)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 10/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotAdic := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao       ADMIN			               ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local aRot1	:= {{STR0004, "HS_HP12FAT()", 0, 2}, ; //"Gerar"
					{STR0223, "HS_HP12FAP()", 0, 2}, ; //"Gerar com Pacote"
					{STR0005, "HS_EXCFAT"   , 0, 2}, ; //"Excluir"
					{STR0006, "HS_HP12PAR"  , 0, 2}, ; //"Parcial"
					{STR0008, "HS_HP12RcP"  , 0, 2}, ; //"Receb.Particular"
					{STR0081, "HS_HP12REV()", 0, 2}, ; //"Revalorizar"
					{STR0007, "HS_HP12PCT"  , 0, 2}, ; //"Pacote"
					{STR0037, "HS_HP12TRA"  , 0, 2}, ; //"Transferir"
					{STR0109, "HS_HP12PEN"  , 0, 2}}   //"Pendencias"

 Local aRot2	:= {{STR0103,"HS_P12LOTE"	, 0, 1},; //"Cadastro"
					{STR0104,"HS_M50Atri()"	, 0, 2},; //"Atribuir Lote"
					{STR0105,"HS_M50Reti()"	, 0, 2}}  //"Retirar Lote"

 Local aRot3	:= {{STR0117,"HS_DocsFat(1)", 0, 2},; //"Capa Fatura"
					{STR0118,"HS_DocsFat(2)", 0, 2},; //"Descritivo"
					{STR0055,"HS_DocsFat(3)", 0, 2},; //"Capa/Descritivo"
					{STR0120,"HS_DocsFat(4)", 0, 2},; //"Fichas"
					{STR0173,"HS_DocsFat(5)", 0, 2},; //"Conta Previa"
					{STR0208,"HS_ImpTISS(__aMarkBrow, 1)", 0, 2}}

 Local aRotRel	:=	{}			//"Ambos"

 Local aRotina	:=	{{STR0003, "AxPesqui"  , 0, 1, 0, nil},; //"Pesquisar"
                     {STR0099, aRot1       , 0, 2, 0, nil},; //"Faturamento"
                     {STR0072, "HS_HP12DES", 0, 2, 0, nil},; //"Despesa"
                     {STR0075, "HS_HP12EXT", 0, 2, 0, nil},; //"Extrato"
                     {STR0009, "HS_LEGHP12", 0, 1, 0, nil},; //"Legenda"
                     {STR0106, aRot2       , 0, 2, 0, nil},; //"Lote"
                     {STR0119, aRot3       , 0, 2, 0, nil},;//"Doctos"
                     {STR0253, "HS_HP12AIH", 0, 2, 0, nil},;//"Desp AIH"
                     {"Ctrl Sol Apac", "HS_P12CtrS", 0, 2, 0, nil}}

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Ponto de entrada - Adiciona rotinas ao aRotina       ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If ExistBlock("HSP12ROT")
 	aRotAdic := ExecBlock("HSP12ROT", .F., .F.)
	 If ValType(aRotAdic) == "A"
	 	AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	 EndIf
 EndIf

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ImpTISSบAutor  ณPatricia Queiroz    บ Data ณ  12/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprimi as guias selecionadas.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TISS                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ImpTISS(aMarkBrow, nOpcTISS)

Local aArea   := GetArea()
Local nForMB  := 0
Local cNrSeqG := ""

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf

For nForMB := 1 To Len(aMarkBrow)
	If !Empty(cNrSeqG)
		cNrSeqG += "/"
	EndIf
	cNrSeqG += aMarkBrow[nForMB][1]
Next

If !Empty(cNrSeqG)
	HS_MntTISS("P12",, cNrSeqG,,, aMarkBrow)
Else
	HS_MsgInf(STR0212, STR0016, STR0213) //"Nใo hแ guias selecionadas."###"Aten็ใo"###"Valida็ใo Guia TISS"
	Return(Nil)
EndIf

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FatInt บAutor  ณDaniel Peixoto      บ Data ณ  03/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento do pacote nas despesas dos intervalos de         บฑฑ
ฑฑบ          ณintercorrencia                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FatInt(aColsInt, cCodCRM)
Local aAreaOld    := GetArea()
Local nContTab    := 0, nContInt := 0, nContDia := 0
Local aDespGD     := {{"GD5", "GD5->GD5", "GE5", "0/1"}, {"GD6", "GD6->GD6", "GE6", "2"}, {"GD7", "GD7->GD7", "GE7", "3"}}
Local nQtdDiaInt  := 0

 For nContInt := 1 To LEN(aColsInt)
  //Posiciona GP0 - Pacote x Convenio da Aba [Intercorrencia]
  DbSelectArea("GP0")
  DbSetOrder(1) //GP0_FILIAL+GP0_CODPRO+GP0_CODCON
  DbSeek(xFilial("GP0") + aColsInt[nContInt, 1] + GCZ->GCZ_CODCON)
  nQtdDiaInt := IIF(GP0->GP0_FATDIA == "1", aColsInt[nContInt, 4] - aColsInt[nContInt, 2] + 1, 1)
  For nContDia := 0 to aColsInt[nContInt, 4] - aColsInt[nContInt, 2]
   For nContTab := 1 To 3
    DbSelectArea(aDespGD[nContTab, 1])
    DBSetOrder(2) //2/NRSEQG + DATDES
    If DbSeek(xFilial(aDespGD[nContTab, 1]) + GCZ->GCZ_NRSEQG + DTOS(aColsInt[nContInt, 2] + nContDia))
     While !EOF() .And. &(aDespGD[nContTab, 2] + "_FILIAL") == xFilial(aDespGD[nContTab, 1]) .And. &(aDespGD[nContTab, 2] + "_NRSEQG") == GCZ->GCZ_NRSEQG ;
           .And. &(aDespGD[nContTab, 2] + "_DATDES") == aColsInt[nContInt, 2] + nContDia
      If EMPTY(&(aDespGD[nContTab, 2] + "_SEQ"+aDespGD[nContTab, 3])) .And. IIF(nContDia == 0, &(aDespGD[nContTab, 2] + "_HORDES") >= aColsInt[nContInt, 3], .T.) ;
         .And. IIF(nContDia == aColsInt[nContInt, 4] - aColsInt[nContInt, 2], &(aDespGD[nContTab, 2] + "_HORDES") <= aColsInt[nContInt, 5], .T.) ;
         .And. &(aDespGD[nContTab, 2] + "_CODLOC") == aColsInt[nContInt, 6]
       AADD(&("aDesp" + aDespGD[nContTab, 1]), {&(aDespGD[nContTab, 2] + "_CODDES"),; //1 - CODDES
                                                 &(aDespGD[nContTab, 2] + "_QTDDES"),; //2 - QTDDES
                                                 HS_CValDes(aDespGD[nContTab, 1], &(aDespGD[nContTab, 2] + "_SEQDES"),,,.T.),; //3 - VALDES
                                                 &(aDespGD[nContTab, 2] + "_DATDES"),; //4 - DATDES
                                                 &(aDespGD[nContTab, 2] + "_SEQDES"),; //5 - SEQDES
                                                 &(aDespGD[nContTab, 2] + "_CODPCT"),; //6 - CODPCT
                                                 IIF(aDespGD[nContTab, 4] == "3", &(aDespGD[nContTab, 2] + "_CODATO"), ""),; //7 - CODATO
                                                 &(aDespGD[nContTab, 2] + "_CODLOC"),; //8 - CODLOC
                                                 IIF(aDespGD[nContTab, 4] == "2", IIF(FS_DespDia(&(aDespGD[nContTab, 2] + "_CODDES")), "7", "2"), "")}) // 9 - TIPDES
      EndIf
      DBSkip()
     EndDo
    EndIf
   Next
   If nQtdDiaInt > 1 //Diario
    //Grava o Pacote e as despesas nas GEs/GGs de acordo com o pacote informado para cada dia
 	  FS_GrvGE7P(aColsInt[nContInt, 1], cCodCrm, aColsInt[nContInt, 2] + nContDia)
    If Len(aDespGD6) > 0
     FS_GrvDes(aColsInt[nContInt, 1], nQtdDiaInt, "2", aDespGD6)
    EndIf
    If Len(aDespGD5) > 0
     FS_GrvDes(aColsInt[nContInt, 1], nQtdDiaInt, "0/1", aDespGD5)
    EndIf
    If Len(aDespGD7) > 0
     FS_GrvDes(aColsInt[nContInt, 1], nQtdDiaInt, "3", aDespGD7)
    EndIf
    aDespGD5 := {}
    aDespGD6 := {}
    aDespGD7 := {}
   EndIf
  Next
  If nQtdDiaInt == 1
   //Grava o Pacote e as despesas nas GEs/GGs de acordo com o pacote informado para o periodo
   FS_GrvGE7P(aColsInt[nContInt, 1], cCodCrm, aColsInt[nContInt, 2])
   If Len(aDespGD6) > 0
    FS_GrvDes(aColsInt[nContInt, 1], nQtdDiaInt, "2", aDespGD6)
   EndIf
   If Len(aDespGD5) > 0
    FS_GrvDes(aColsInt[nContInt, 1], nQtdDiaInt, "0/1", aDespGD5)
   EndIf
   If Len(aDespGD7) > 0
    FS_GrvDes(aColsInt[nContInt, 1], nQtdDiaInt, "3", aDespGD7)
   EndIf
   aDespGD5 := {}
   aDespGD6 := {}
   aDespGD7 := {}
  EndIf
 Next

 RestArea(aAreaOld)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_HP12FAPณ Autor ณDaniel Peixoto         ณ Data ณ10/12/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ GERA FATURAMENTO COM PACOTE                         		     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	     ณ HSPAHP12 				                      							                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HP12FAP(cAlias, nReg, nOpc)
 Local aHeadInt := {}, aColsInt  := {}
 Local nOpcA    := 1
 Local nGDOpc   := GD_INSERT + GD_UPDATE + GD_DELETE

 Private oDlgInt, oInterc
 Private n_CodProI := 0, n_DatIniI := 0, n_DatFinI := 0, n_HorIniI := 0, n_HorFinI := 0, n_CodLocI := 0
 Private aDespGD5  := {}, aDespGD6 := {}, aDespGD7 := {}

 If !(HS_VldBrowse(oMb))
	Return(Nil)
 EndIf

 If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	Return(Nil)
 Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)
 EndIf

 If GCZ->GCZ_STATUS == '3'
 	MsgInfo(STR0107,STR0016) //"Esta guia nใo pode ser alterada por jแ estar atrelada a um lote"###"Aten็ใo"
 	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
 	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
 	Return(.T.)
 EndIf

 If GCZ->GCZ_CANCEL == "1"
  MsgStop(STR0014 + '  ' + GCZ->GCZ_NRSEQG + STR0108 + GCZ->GCZ_NRGUIA + '  ' + STR0092,STR0016) //"NRSEQG - "###"  NRGUIA - "###" estแ cancelada e nใo pode ser utilizada"###"Aten็ใo"
 	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
 	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
 	Return(.F.)
 EndIf

 If GCZ->GCZ_STATUS == "2"
 	MSGSTOP(STR0015) //###"Existe Guia Marcada que ja foi faturada, nao sera possivel fatura-la, Atencao!!!"
 	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
 	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
 	Return(.F.)
 EndIf

 If GCZ->GCZ_STATUS >= "4"
    MSGSTOP(STR0014 + " " + GCZ->GCZ_NRSEQG + STR0165) //"NRSEQG - " //" ja possui fatura gerada"
    UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
    HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
    Return(.F.)
 EndIf

 If !MsgYesNo(STR0228, STR0016) //"Aten็ใo" //"Confirma Gerar Faturamento com Pacote?"
 	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
 	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
 	Return(.F.)
 EndIf

 cGP0CodCon := GCZ->GCZ_CODCON

 //Posiciona GCY
 DbSelectArea("GCY")
 DBSetOrder(1) //GCY_FILIAL+GCY_REGATE
 DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

 //Header da Aba Intercorrencia
 aAdd(aHeadInt,{STR0124,"HSPCODPROI","@!", TamSx3("GA7_CODPRO")[1],0, "HS_VldPct(oInterc,, .F.)",,"C","GP0001" ,"R",,,,"A"})  //"Pacote    "
 aAdd(aHeadInt,{STR0125,"HSPDESPROI","@!", 40,0,,,"C",         ,"R",,,,"V"}) //"Descricao "
 aAdd(aHeadInt,{STR0126,"HSPDATINII","@!",  8,0, "HS_VldDat()",,"D",         ,"R",,"CTOD('  /  /  ')",,"A"}) //"Dt Inicial"
 aAdd(aHeadInt,{STR0180,"HSPHORINII","99:99",  5,0, "HS_VldHora(M->HSPHORINII)",,"C",         ,"R",,,,"A"})  //"Hora Inicial"
 aAdd(aHeadInt,{STR0127,"HSPDATFINI","@!",  8,0, "HS_VldDat()",,"D",         ,"R",,"CTOD('  /  /  ')",,"A"}) //"Dt Final  "
 aAdd(aHeadInt,{STR0181,"HSPHORFINI","99:99",  5,0, "HS_VldHora(M->HSPHORFINI)",,"C",         ,"R",,,,"A"})  //"Hora Final"
 aAdd(aHeadInt,{STR0046,"HSPCODLOCI","@!",  2,0, "HS_SeekRet('GCS','M->HSPCODLOCI',1,.f.,'HSPNOMLOCI','GCS_NOMLOC',,,.T.)",,"C","GCS"    ,"R",,,,"A"})  //"Setor"
 aAdd(aHeadInt,{STR0182,"HSPNOMLOCI","@!", 30,0,,,"C",         ,"R",,,,"V"})  //"Descri็ใo"

 n_CodProI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCODPROI"})
 n_DatIniI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPDATINII"})
 n_HorIniI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPHORINII"})
 n_DatFinI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPDATFINI"})
 n_HorFinI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPHORFINI"})
 n_CodLocI := aScan(aHeadInt, { | aVet | aVet[2] == "HSPCODLOCI"})

 aSize := MsAdvSize(.T.)
 aObjects := {}

 AAdd( aObjects, { 100, 100, .T., .T. })

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo := { aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlgInt TITLE OemtoAnsi(STR0229) FROM  aSize[ 7 ]/*07*/,0 to aSize[ 6 ]/2/*35*/, aSize[ 5 ]/2/*100*/ PIXEL OF oMainWnd  //"Gerar Faturamento com Pacote"

  oInterc := MsNewGetDados():New(aPGDs[1,1], aPGDs[1,2], aPGDs[1,3], aPGDs[1,4], nGDOpc,,,,,,99999,,,, oDlgInt , aHeadInt, aColsInt)
  oInterc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlgInt CENTERED ON INIT EnChoiceBar(oDlgInt, {|| nOpcA := 1, IIf(FS_CpoObrI(oInterc:aCols), oDlgInt:End(), nOpcA := 0)}, ;
                                                                 {|| nOpcA := 0, oDlgInt:End()} )

 If nOpcA == 1
  Begin Transaction
   Processa({|| FS_GerFatP(oInterc:aCols) })
  End Transaction
 EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณFS_GerFatPณ Autor ณDaniel Peixoto         ณ Data ณ10/12/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Grava nas tabelas GE5/GE6/GE7   Faturamento com Pacote 		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso	   	 ณ HSPAHP12	                                               	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerFatP(aColsInt)
 Local aArea      := GetArea(), nFieldGb := 0, nCont := 0
 Local aProcessa := {}, cMsgErro := ""
 Local aPar       := {}, aInterc := {}
 Local lAteSUS				:= .F. //Indica se o Modulo atende ao SUS.
 Local cGe7SeqDes	:= ""

 Private dDATINI  := CTOD("  /  /  ")
 Private dDATFIN  := CTOD("  /  /  ")
 Private cSeqPct  := 0

 /* Valida ATENDIMENTO SUS*/
 If (lAteSUS := (GetMV("MV_ATESUS", , "N") == "S"))
 	aPar := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
 	If !HS_VMVSUS(@aPar)
 		Return()
 	EndIf
 EndIf

 aProcessa := HS_P12SEL("P")//Verifica se existe alguma despesa de Mat/Med - Tax/Dia - Procedto zerada referente a esta Guia.

 If aProcessa[1] .And. aProcessa[2] .And. aProcessa[3] .And. aProcessa[5][1] .And. aProcessa[5][2] .And. aProcessa[5][3]

	 If Len(aColsInt) > 0 .And. !EMPTY(aColsInt[1, n_CodProI])
 	 HS_ExluiDes(GCZ->GCZ_NRSEQG)
   FS_ExluiPct(GCZ->GCZ_NRSEQG)

  	//Tratamento do pacote nas despesas dos intervalos de intercorrencia
  	For nCont := 1 To Len(aColsInt)
   	aInterc := FS_RInterc(aColsInt, aColsInt[nCont, n_CodProI])
   	dDatIni := aInterc[nCont, 2]
    dDatFin := aInterc[nCont, 4]

   	FS_FatInt(aInterc, GCY->GCY_CODCRM)
   Next
  EndIf

 	// Gerando Registros no Arquivo de Faturamento (Mat/Med)
 	DbSelectArea("GD5")
 	DBSetOrder(2) //GD5_FILIAL+GD5_NRSEQG+DTOS(GD5_DATDES)
 	DbSeek(xFilial("GD5") + GCZ->GCZ_NRSEQG)
 	While !eof() .and. GD5->GD5_FILIAL + GD5->GD5_NRSEQG == xFilial("GD5") + GCZ->GCZ_NRSEQG

 		If !EMPTY(GD5->GD5_SEQGE5) //Ja foi faturada por pacote - Intercorrencia
 		 DbSkip()
 		 Loop
 		EndIf

 		IncProc(STR0230 + " - " + GCZ->GCZ_NRSEQG)   //"Gerando Mat/Med, Guia"

 		If HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == '1' .And. GD5->GD5_FATPAR == '0'
	 		DbSkip()
	 		Loop
	 	EndIf

		 DbSelectArea("GE5")
		 M->GE5_SEQDES := HS_VSxeNum("GE5", "M->GE5_SEQDES", 1)

		 RecLock("GE5",.T.)
		  For nFieldGb := 1 To GD5->(FCount())
			  If !(GD5->(FieldName(nFieldGb)) $ "GD5_FILIAL/GD5_SEQDES/GD5_LOGARQ") .And. ValType("GE5->GE5" + SubStr(GD5->(FieldName(nFieldGb)), 4)) # "U"
				  &("GE5->GE5" + SubStr(GD5->(FieldName(nFieldGb)), 4)) := GD5->(&(FieldName(nFieldGb)))
			  EndIf
		  Next

		  GE5->GE5_FILIAL := xFilial("GE5")
		  GE5->GE5_SEQDES := M->GE5_SEQDES
		  GE5->GE5_LOGARQ := HS_LogArq()
		 MsUnlock()

		 DbSelectArea("GD5")
			RecLock("GD5", .F.)
			 GD5->GD5_SEQGE5 := M->GE5_SEQDES
			MsUnLock()

		 DbSelectArea("GD5")
		 DBSetOrder(2) //GD5_FILIAL+GD5_NRSEQG+DTOS(GD5_DATDES)
		 DbSkip()
	 End

	 // Gerando Registros no Arquivo de Faturamento (Taxas/Diarias)
	 DbSelectArea("GD6")
	 DBSetOrder(2) //GD6_FILIAL+GD6_NRSEQG+DTOS(GD6_DATDES)
	 DbSeek(xFilial("GD6") + GCZ->GCZ_NRSEQG)
	 While !eof() .and. GD6->GD6_FILIAL + GD6->GD6_NRSEQG == xFilial("GD6") + GCZ->GCZ_NRSEQG

		 If !EMPTY(GD6->GD6_SEQGE6) //Ja foi faturada por pacote - Intercorrencia
 		 DbSkip()
 		 Loop
 		EndIf

		 IncProc(STR0231 + " - " + GCZ->GCZ_NRSEQG)  //"Gerando Taxas / Diarias, Guia"

		 If HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == '1' .And. GD6->GD6_FATPAR == '0'
			 DbSkip()
			 Loop
		 EndIf

		 DbSelectArea("GE6")
		 M->GE6_SEQDES := HS_VSxeNum("GE6", "M->GE6_SEQDES", 1)

		 RecLock("GE6",.T.)
		  For nFieldGb := 1 To GD6->(FCount())
			  If !(GD6->(FieldName(nFieldGb)) $ "GD6_FILIAL/GD6_SEQDES/GD6_LOGARQ") .And. ValType("GE6->GE6" + SubStr(GD6->(FieldName(nFieldGb)), 4)) # "U"
			  	&("GE6->GE6" + SubStr(GD6->(FieldName(nFieldGb)), 4)) := GD6->(&(FieldName(nFieldGb)))
			  EndIf
		  Next

		  GE6->GE6_FILIAL := xFilial("GE6")
		  GE6->GE6_SEQDES := M->GE6_SEQDES
		  GE6->GE6_LOGARQ := HS_LogArq()
		 MsUnlock()

		 DbSelectArea("GD6")
			RecLock("GD6", .F.)
			 GD6->GD6_SEQGE6 := M->GE6_SEQDES
			MsUnLock()

		 DbSelectArea("GD6")
		 DBSetOrder(2) // GD6_FILIAL+GD6_NRSEQG+DTOS(GD6_DATDES)
		 DbSkip()
	 End

	 // Gerando Registros no Arquivo de Faturamento (Procedimento/Honorarios)
	 DbSelectArea("GD7")
	 DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES
	 DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG)
	 While !eof() .and. GD7->GD7_FILIAL + GD7->GD7_NRSEQG == xFilial("GD7") + GCZ->GCZ_NRSEQG

		 If !EMPTY(GD7->GD7_SEQGE7) //Ja foi faturada por pacote - Intercorrencia
 		 DbSkip()
		 	Loop
 		EndIf

		 IncProc(STR0232 + " - " + GCZ->GCZ_NRSEQG)  //"Gerando Procedimentos, Guia"

		 If HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") == '1' .And. GD7->GD7_FATPAR == '0'
		 	DbSkip()
		 	Loop
		 EndIf

			cGe7SeqDes := HS_VSxeNum("GE7", "M->GE7_SEQDES", 1)

		 DbSelectArea("GD7")
			RecLock("GD7", .F.)
			 GD7->GD7_SEQGE7 := cGe7SeqDes
			 /* Grava os Relacionamentos UNICOS */
			 FS_GravREL(lAteSUS, "GD7", GD7->GD7_CODDES, aPar) // Par(..., Procedimento)
			MsUnLock()

		 DbSelectArea("GE7")
		 M->GE7_SEQDES := cGe7SeqDes

		 RecLock("GE7",.T.)
		  For nFieldGb := 1 To GD7->(FCount())
			  If !(GD7->(FieldName(nFieldGb)) $ "GD7_FILIAL/GE7_SEQDES/GD7_LOGARQ") .And. ValType("GE7->GE7" + SubStr(GD7->(FieldName(nFieldGb)), 4)) # "U"
			  	&("GE7->GE7" + SubStr(GD7->(FieldName(nFieldGb)), 4)) := GD7->(&(FieldName(nFieldGb)))
			  EndIf
		  Next

		  GE7->GE7_FILIAL := xFilial("GE7")
		  GE7->GE7_CODCON := GCZ->GCZ_CODCON
		  GE7->GE7_CODPRE := HS_RPreMed(GE7->GE7_CODCRM, GE7->GE7_CODLOC)
		  GE7->GE7_SEQDES := M->GE7_SEQDES
		  GE7->GE7_LOGARQ := HS_LogArq()
		 MsUnlock()

		 DbSelectArea("GD7")
		 DBSetOrder(2) //GD7_FILIAL+GD7_NRSEQG+DTOS(GD7_DATDES)+GD7_HORDES
		 DbSkip()
	 End

  //ATUALIZA STATUS E DATA DO STATUS NA GUIA QUE ESTA SENDO FATURADA
 	RecLock("GCZ", .F.)
  	GCZ->GCZ_STATUS := "2"
  	GCZ->GCZ_DATSTA := dDataBase
   GCZ->GCZ_DCPARF := dDataBase
  	GCZ->GCZ_HRGERA := TIME()
  	GCZ->GCZ_USGERA := cUserName
  MsUnlock()

  HS_MsgInf(STR0233, STR0016, STR0131) //"Faturamento com Pacote terminado com sucesso."

 Else
 	cMsgErro += STR0014 + ' ' + GCZ->GCZ_NRSEQG + chr(10)//"NRSEQG - "###"  NRGUIA - "
 	If !aProcessa[1]
 		cMsgErro += STR0113  + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med Com o Valor Zerado"
 	EndIf

 	If !aProcessa[2]
		 cMsgErro += STR0114  + chr(10)//"Guia Nใo Faturada, existe despesa de Tax/Dia Com o Valor Zerado"
	 EndIf

	 If !aProcessa[3]
	 	cMsgErro += STR0115  + chr(10)//"Guia Nใo Faturada, existe despesa de Procedto Com o Valor Zerado"
	 EndIf

	 If !aProcessa[5][1]
 		cMsgErro += STR0219 + chr(10)//"Guia Nใo Faturada, existem despesas de Mat/Med com o Valor menor que o Desconto"
 	EndIf

 	If !aProcessa[5][2]
 		cMsgErro += STR0220 + chr(10)//"Guia Nใo Faturada, existem despesas de Tax/Dia com o Valor menor que o Desconto"
 	EndIf

  If !aProcessa[5][3]
	 	cMsgErro += STR0221 + chr(10)//"Guia Nใo Faturada, existem despesas de Procedto com o Valor menor que o Desconto"
	 EndIf

	 HS_MsgInf(cMsgErro, STR0016, STR0234) //"Aten็ใo" //"Faturamento com Pacote"
 EndIf

 RestArea(aArea)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_P12CtrS(cAlias, nReg, nOpc)
 Local aArea   := GetArea()
 //Local cNrGuia := GCZ->GCZ_NRSEQG
 Local cRegAte := GCZ->GCZ_REGATE
 Local cSql    := ""

 Private aRotina :=	{{"Pesquisar" ,"AxPesqui" , 0, 1, 0, nil},;
                     {"Visualizar","HS_M12ROT", 0, 2, 0, nil},;
                     {"Solicitar","HS_M12ROT", 0, 3, 0, nil},;
                     {"Alterar"  ,"HS_M12ROT", 0, 4, 0, nil}}

 If !(HS_VldBrowse(oMb))
	Return(Nil)
 EndIf

 If !(GCZ->GCZ_LOCATE $ cLocReab)
  Hs_MsgInf("Setor selecionado nใo ้ de 'Reabilita็ใo'.","Aten็ใo","Controle Sess๕es")
  Return(Nil)
 EndIf

	cSql += " SELECT GK7_SOLICI "
	cSql += "   FROM "+RetSqlName("GK7")+" GK7 "
	cSql += "   JOIN "+RetSqlName("GM8")+" GM8 "
	cSql += "     ON GM8_REGATE = '"+cRegAte+"' AND GM8_AGDPRC = GM8_CODAGE "
	cSql += "    AND GM8_SEQAGE = GM8_AGDPRC AND GM8_CODAGE = GK7_SEQAGE "
	cSql += "    AND GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' "
	cSql += "  WHERE GK7_FILIAL = '"+xFilial("GK7")+"' AND GK7.D_E_L_E_T_ <> '*' "

	TcQuery cSql New Alias "TMPSOLI"

	If TMPSOLI->(Eof())
  TMPSOLI->(DbCloseArea())
	 Return(nil)
 EndIf

 DbSelectArea("GK7")
 DbSetOrder(1)
 DbSeek(xFilial("GK7")+TMPSOLI->GK7_SOLICI)

 TMPSOLI->(DbCloseArea())

 Hs_M12ROT("GK7", GK7->(RECNO()), 4)

 RestArea(aArea)
Return(nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TranIteบAutor  ณSaude               บ Data ณ  08/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta janela para Transferencias dos Itens da Guia          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function HS_TranIte(cSeqGuia,dDatIni,dDatFin)

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {}
Local aButtons := {}

Private nOpcAut
Private oGetProc  := nil
Private oGetSol := nil
Private oGetMat := nil
Private oGetOpm := nil
Private aHeadGD7 := {}, aColsGD7 := {}
Private aHeadGD6 := {}, aColsGD6 := {}
Private aHeadGD5 := {}, aColsGD5 := {}
Private cCadastro  	:= OemToAnsi(STR0001)
Private Inclui 		:= .F.
Private nProcSeqDes, nMMSeqDes, nOPMSeqDes, nProcCheck, nMMCheck, nOPMCheck, nProcNrAuto, nMMNrAuto, nOPMNrAuto := 0
Private nGDOpc			:= 0
Private aJoinD6			:={}
Private aJoin    		:={}
Private lCbTra      := .F.

 aSize := MsAdvSize(.T.)
 aObjs := {{100, 050, .T., .T.,.T.}, ;
           {100, 050, .T., .T., .T.}}
 aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObj := MsObjSize(aInfo, aObjs, .T.)
 aObjs := {{100, 065, .T., .T.},;
           {100, 035, .T., .T.}}

 aInfo := {aPObj[1, 2], aPObj[1, 1], aPObj[1, 4], aPObj[1, 3], 0, 0}
 aPEnc := MsObjSize(aInfo, aObjs, .T.)

 aObjs := {{100, 50, .T., .T.}, ;
           {100, 50, .T., .T.}}

 aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
 aPAux := MsObjSize(aInfo, aObjs, .T.,.T.)

 aObjs := {{13, 100, .T., .T.}, ;
           {87, 100, .T., .T.}}

 aInfo := {aPEnc[1, 2], aPEnc[1, 1], aPEnc[1, 4], aPEnc[1, 3], 0, 0}
 aPPac := MsObjSize(aInfo, aObjs, .T.,.T.)


DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL

  	oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4])
  	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
  	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3],aSize[5]   OF oPanel1 PIXEL PROMPTS STR0028,STR0025+"\"+STR0026, STR0086+"\"+STR0087
  	oFolder:Align := CONTROL_ALIGN_ALLCLIENT



  	cFiltro := "GD5->GD5_DATDES >= '" + DTOS(dDatIni) + "' AND GD5->GD5_DATDES <= '" + DTOS(dDatFin) + "' AND "
  	cFiltro += "GD5->GD5_NRSEQG  = '"+ cSeqGuia + "'"
  	aAdd(aJoin, {     " JOIN " + RetSqlName("GBI") + " GBI"   , "" , "GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = GD5.GD5_CODDES AND GBI_TIPO IN ('0','1','2') "     , ""})
  	cLstCpo    := "GD5_CODDES/GD5_DDESPE/GD5_QTDDES/GD5_SEQDES"
  	HS_BDados("GD5", @aHeadGD5, @aColsGD5,          , 1, ,cFiltro                                                                                                                                             ,,            ,cLstCpo ,,,,{"GD5_IDMARC"},{"'LBNO'"},.T.,       ,,,,,       , aJoin,,"GD5_CODDES" )


  	cFiltroD7 := "GD7->GD7_DATDES >= '" + DTOS(dDatIni) + "' AND GD7->GD7_DATDES <= '" + DTOS(dDatFin) + "' AND "
  	cFiltroD7 += "GD7->GD7_NRSEQG  = '"+ cSeqGuia + "'"
  	cLstCpoD7    := "GD7_CODDES/GD7_DDESPE/GD7_QTDDES/GD7_SEQDES"
  	HS_BDados("GD7", @aHeadGD7, @aColsGD7,          , 1, ,cFiltroD7                                                                                                                                             ,,             ,cLstCpoD7 ,,,,{"GD7_IDMARC"},{"'LBNO'"},.T.,       ,,,,,       ,      ,,"GD7_CODDES" )



  	cFiltroD6 := "GD6->GD6_DATDES >= '" + DTOS(dDatIni) + "' AND GD6->GD6_DATDES <= '" + DTOS(dDatFin) + "' AND "
  	cFiltroD6 += "GD6->GD6_NRSEQG  = '"+ cSeqGuia + "'"
  	aAdd(aJoinD6, {     " JOIN " + RetSqlName("GAA") + " GAA"   , "" , "GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GD6.GD6_CODDES AND GAA_TIPDES IN ('2','7') "     , ""})
  	cLstCpoD6    := "GD6_CODDES/GD6_DESTXC/GD6_QTDDES/GD6_SEQDES"
  	HS_BDados("GD6", @aHeadGD6, @aColsGD6,          , 1, ,cFiltroD6                                                                                                                                             ,,             ,cLstCpoD6 ,,,,{"GD6_IDMARC"},{"'LBNO'"},.T.,       ,,,,,       , aJoinD6,,"GD6_CODDES" )


   	oGetProc := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[1], aHeadGD7, aColsGD7)
	oGetProc:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
  	oGetProc:oBrowse:BlDblClick := {|| FS_DbClikI(oGetProc,.F.)}
  	oGetProc:Refresh()



  	oGetMat := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[2], aHeadGD5, aColsGD5)
  	oGetMat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  	oGetMat:oBrowse:BlDblClick := {|| FS_DbClikI(oGetMat,.F.)}
	oGetMat:Refresh()


  	oGetOpm := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[3], aHeadGD6, aColsGD6)
  	oGetOpm:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  	oGetOpm:oBrowse:BlDblClick := {|| FS_DbClikI(oGetOpm,.F.)}
    oGetOpm:Refresh()

	nProcSeqDes := aScan(aHeadGD7, {|aVet| aVet[2] == "GD7_SEQDES"})
	nMMSeqDes	:= aScan(aHeadGD5, {|aVet| aVet[2] == "GD5_SEQDES"})
	nOPMSeqDes	:= aScan(aHeadGD7, {|aVet| aVet[2] == "GD6_SEQDES"})

	nProcQtdSol := aScan(aHeadGD7, {|aVet| aVet[2] == "GD7_DESPRO"})
	nMMQtdSol	:= aScan(aHeadGD5, {|aVet| aVet[2] == "GD5_DESPRO"})
	nOPMQtdSol	:= aScan(aHeadGD7, {|aVet| aVet[2] == "GD6_DESTXC"})

	nProcDatSol := aScan(aHeadGD7, {|aVet| aVet[2] == "GD7_DATDES"})
	nMMDatSol	:= aScan(aHeadGD5, {|aVet| aVet[2] == "GD5_DATDES"})
	nOPMDatSol	:= aScan(aHeadGD7, {|aVet| aVet[2] == "GD6_DATDES"})

	Aadd(aButtons	, {"edit_ocean", {||FS_MarcIt(Iif(oFolder:nOption == 1,oGetProc:aCols,Iif(oFolder:nOption == 2,oGetMat:aCols,oGetOpm:aCols)),oGetOpm:aCols)}, STR0261})  //"Todos"

 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| nOpcAut := 0, oDlgAut:End()},,aButtons)

 If nOpcAut == 1
	FS_TransIt(oGetProc:aCols,"GD7")
	FS_TransIt(oGetMat:aCols, "GD5")
	FS_TransIt(oGetOpm:aCols, "GD6")
 EndIf


Return(nOpcAut)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DbClikIบAutor  ณSaude               บ Data ณ 05/08/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item do Grid               บฑฑ
ฑฑบ          ณE marcar os itens do Grid dos itens                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DbClikI(oGet,lMarkAll)
Local i     := 0
Local j     := 0
Local aObjs := {oGetProc,oGetMat,oGetOpm}
Local cTik	:= ""


Default lMarkAll := .F.

If ValType(oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]) == "C"
	If oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos] $ "LBTIK/LBNO"
  		oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos] := IIF(oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos] == "LBTIK", "LBNO", "LBTIK")
  		cTik := oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]
 	Else
 		lMarkAll := .F.
 		oGet:EDITCELL( oGet:OBROWSE, oGet:oBrowse:nAt, oGet:oBrowse:nColPos )
 	EndIf
Else
  oGet:EDITCELL( oGet:OBROWSE, oGet:oBrowse:nAt, oGet:oBrowse:nColPos )
EndIf

 If lMarkAll
   For i := 1 to Len(aObjs)
    For j := 1 to Len(aObjs[i]:aCols)
     If aObjs[i]:aCols[j, 1] $ "LBTIK/LBNO"
	     aObjs[i]:aCols[j, 1] := cTik
	     aObjs[i]:Refresh()
	    EndIf
    Next j
   Next i
  Endif

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TransItบAutor  ณSaude               บ Data ณ  08/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transferencia dos Itens da Guia para                       บฑฑ
ฑฑบ          ณ outra Guia                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FS_TransIt(aColsGD5,cAlias)
 Local aArea := GetArea()
 Local nPos  := 0
 Local cSeek
 DbSelectArea(cAlias)
 DbSetOrder(1)

 For nPos := 1 to len(aColsGD5)
  	If aColsGD5[nPos,1] == "LBTIK"
  		If cAlias <>"GD6"
  			cSeek := DbSeek(xFilial(cAlias) + aColsGD5[nPos,5])
  		Else
  			cSeek := DbSeek(xFilial(cAlias) + aColsGD5[nPos,4])
  		Endif

  		If cseek
  			RecLock(cAlias,.F.)
  			&(cAlias + "->" + cAlias + "_IDMARC") := cMarcaT
  			MsUnLock()
  		EndIf

 	Endif
 Next Pos

 RestArea(aArea)
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MarcIt บ Autor ณ Darcio Ribeiro    บ Data ณ  06/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca todos os Procedimentos no browse            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MarcIt(aCols)
Local cVal		:= ""
Local nForaCols := 0
Local lMar		:= .F.

If aCols[1,1] == "LBNO"
	lMar := .T.
EndIf

cVal := IIF(lMar, "LBTIK", "LBNO")

For nForACols := 1 to len(aCols)
	aCols[nForACols,1] := cVal
Next nForACols

If oFolder:nOption == 1
	oGetProc:oBrowse:Refresh()
ElseIf oFolder:nOption == 2
	oGetMat:oBrowse:Refresh()
Else
	oGetOpm:oBrowse:Refresh()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VFTASUS(aGuias, nTot, cCodBpa)
Local 	aArea 	:= GetArea()
Local   nI,nPos	:= 0
Local 	aAux	:= {}
Local 	cSql 	:= ""

For nI := 1 To Len(aGuias)
	DBSelectArea("GCZ")
	DBSetOrder(1)
	If DBSeek(xFilial("GCZ") +  aGuias[nI][1]) .AND. GCZ->GCZ_CODPLA $ cCodBpa
		cSql := "SELECT GM8_SEQAGE, GM8_AGDPRC, GM8_REGATE, GM8_STATUS, GM8_DATAGE, GCZ_NRSEQG, GCZ_FILATE, GM8_CODPRO, GM8_CODAGE "
		cSql += "FROM " + RetSqlName("GM8") + " GM8 "
		cSql += "LEFT JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ_REGATE = GM8_REGATE "
		cSql += " AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' "
		cSql += "WHERE GM8_SEQAGE IN (SELECT GM8_SEQAGE FROM " + RetSqlName("GM8") + " GM82 WHERE GM82.GM8_REGATE = '" + GCZ->GCZ_REGATE + "' "
		cSql += "AND GM82.D_E_L_E_T_ <> '*' AND GM82.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM82.GM8_NUMSES > 1 ) "
		cSql += " AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_ORICAN = ' ' AND GM8_NSQFAT = '      ' "
		cSql += " ORDER BY GM8.GM8_SEQAGE "

		cSql := ChangeQuery(cSql)
		TcQuery cSql New Alias "TMPSES"
		DbSelectArea("TMPSES")
		If !Eof()
			While !Eof() //          1             2                     3                    4                  5                6                   7                     8                     9                   10
				If (IIf(Len(aAux) > 0,aScan(aAux, {| aVet | aVet[10] == TMPSES->GM8_CODAGE}) == 0,.T.)) // Caso seja selecionado duas guias da mesma sessao nao inserir duplicado
					AADD(aAux , {GCZ->GCZ_REGATE, TMPSES->GCZ_NRSEQG,TMPSES->GM8_SEQAGE,TMPSES->GM8_AGDPRC, TMPSES->GM8_REGATE, TMPSES->GM8_STATUS, TMPSES->GM8_DATAGE, TMPSES->GCZ_FILATE , TMPSES->GM8_CODPRO, TMPSES->GM8_CODAGE})
				EndIf
				DbSkip()
			End
		EndIf
		DbSelectArea("TMPSES")
		DbCloseArea()
	EndIf
Next nI

If Len(aAux) > 0
	If MsgYesNo("Existem outras sess๕es pertencentes ao atendimento de terapias, deseja faturแ-las?", "Aten็ใo")
		 For nI := 1 To Len(aAux)
		 	If aScan(aGuias, {| aVet | aAux[nI,5] == aVet[2]}) == 0  .AND. !Empty(aAux[nI,2])
		 		AADD(aGuias, {aAux[nI,2],aAux[nI,5], xFilial("GCZ") + aAux[nI,2],aAux[nI,8] })
		 	EndIf
		 Next nI
	EndIf
EndIf


RestArea(aArea)
Return(aAux)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFUNCAO    ณ            บ Autor ณ Microsiga Protheus                      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPAHP12                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VSESPOS(cRegAte, aFatSes, cNrSqeG)
Local 	aArea 	:= GetArea()
Local lRet 		:= .T.
Local nPos,nI  	:= 0
Local cSeqAge	:= ""
Local nQtdProc	:= 0

nPos := aScan(aFatSes, {| aVet | cRegAte == aVet[5]})
If nPos > 0
	cSeqAge := aFatSes[nPos,3]
	cCodPro	:= aFatSes[nPos,9]
	For nI := 1 To Len(aFatSes)
		If aFatSes[nI, 3] == cSeqAge
			If STod(aFatSes[nI, 7]) > dDataBase  .AND. aFatSes[nI, 6] == "1"
				lRet := .F.
				Exit
			ElseIf aFatSes[nI, 6] == "1"
				DbSelectArea("GM8") //GM8_NSQFAT
				DbSetOrder(1)
				If DbSeek(xFilial("GM8") + aFatSes[nI, 10])
					If Empty(GM8->GM8_NSQFAT)
						RecLock("GM8", .F.)
							 GM8->GM8_NSQFAT := cNrSqeG
						MsUnLock()
						nQtdProc ++
					EndIf
				EndIf
			   //	nQtdProc ++
			EndIf
		EndIf
	Next nI
	If nQtdProc > 0
		DbSelectArea("GD7")
		DbSetOrder(7)
		If DbSeek(xFilial("GD7") + cNrSqeG + cCodPro)
			RecLock ("GD7", .F.)
				GD7->GD7_QTDDES := nQtdProc + 1
			MsUnlock ()
		EndIf
	EndIf
EndIf
//CTod("01" + Substr(dtoc(GCZ->GCZ_DATATE),3,8)) >= CtoD('01/'+ GAT->GAT_DTAPRE)

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_STAGCZ บ Autor ณ Rogerio Tabosa     บ Data ณ  09/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao utilizada para tratar a descricao do campo combo.   บฑฑ
ฑฑบ          ณ Status da GCZ(X3_CBOX)                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar 								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_STAGCZ()

Local cDescri := ""

cDescri := "0=Controle de Contas;1=Faturamento;2=Faturado;3=Lote Atribuido;4=Gerado Faturas;5=Associado Extr.Conv.;"
cDescri += "6=Liquidado;7=Quitado;8=Reapresent. SUS"

Return(cDescri)
