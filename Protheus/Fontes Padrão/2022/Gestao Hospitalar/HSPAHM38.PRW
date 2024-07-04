#Include "HSPAHM38.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHM38 บ Autor ณ Cibele Peria       บ Data ณ  12/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXTRATO DO CONVENIO                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM38()
Local bKeyF12 := SetKey(VK_F12, {|| HS_M38Fil() })
Local aCores  := {	{"GE0->GE0_STATUS == '1'", 'BR_VERDE'   }, ;
					{"GE0->GE0_STATUS == '2'", 'BR_AMARELO' }, ;
					{"GE0->GE0_STATUS == '3'", 'BR_VERMELHO'} }
Local lNfsTela	:= SuperGetMV("MV_NFSTELA", .F., .F.)
Local nTamSer	:= TamSX3("E1_SERIE")[1]
Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
Local nTamTot	:= nTamSer + nTamPre + 1

Private cCadastro	:= OemtoAnsi(STR0101) //"Extrato Convenio"
Private aRotina		:= MenuDef()
Private cGCZNrFatu	:= ""
Private cGCZStatus	:= ""
Private cGDMTipo	:= ""
Private cE1Prefixo	:= ""   // campos utilizados nas rotinas de filtro das consultas padroes.
Private cSE1Prefix	:= ""
Private cE1Cliente	:= ""
Private cE1Loja		:= ""
Private lE1Saldo	:= .F.
Private aGReap		:= {}
Private lFilFat		:= HS_ExisDic({{"I", "GCZ", 25}}, .F.) .And. HS_ExisDic({{"I", "GF5", 8}}, .F.)

cE1Prefixo := IIF(Len(GetMV("MV_HSPSERI")) >= Len(SE1->E1_SERIE), GetMV("MV_HSPSERI"), PadR(GetMV("MV_HSPSERI"), Len(SE1->E1_SERIE))) + "/" + IIF(Len(GetMV("MV_PREFCRH")) >= Len(SE1->E1_PREFIXO), GetMV("MV_PREFCRH"), PadR(GetMV("MV_PREFCRH"), Len(SE1->E1_PREFIXO)))
cSE1Prefix := IIF(Len(GetMV("MV_HSPSERI")) >= Len(SE1->E1_SERIE), GetMV("MV_HSPSERI"), PadR(GetMV("MV_HSPSERI"), Len(SE1->E1_SERIE))) + "/" + IIF(Len(GetMV("MV_PREFCRH")) >= Len(SE1->E1_PREFIXO), GetMV("MV_PREFCRH"), PadR(GetMV("MV_PREFCRH"), Len(SE1->E1_PREFIXO)))

If !lNfsTela
	If Len(cSE1Prefix) > nTamTot .AND. Len(cE1Prefixo) > nTamTot
		MsgStop('Informe apenas uma s้rie e um prefixo nos parโmetros MV_HSPSERI e MV_PREFCRH')
		Return()
	EndIf
EndIf

HS_DtvFilt("GE0")
mBrowse(06, 01, 22, 75, "GE0",,,,,, aCores)
HS_DtvFilt("GE0")
SetKey(VK_F12, bKeyF12)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_M38Alt บ Autor ณ Cibele Peria       บ Data ณ 15/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao da alteracao de um lancamento do ex-   บฑฑ
ฑฑบ          ณ trato.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Alt(cAlias, nReg, nOpc)

If GE0->GE0_STATUS == "3"
	HS_MsgInf(STR0013,STR0065,STR0014) //"Extrato Liquidado. Alteracao nao permitida!","Atencao","Extrato"
Else
	axAltera(cAlias, nReg, nOpc)
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_M38Exc บ Autor ณ Cibele Peria       บ Data ณ 15/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao da exclusao  de um lancamento do ex-   บฑฑ
ฑฑบ          ณ trato.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Exc(cAlias, nReg, nOpc)

If GE0->GE0_STATUS # "1"
	HS_MsgInf(STR0014 + IIF(GE0->GE0_STATUS == "2", STR0015, STR0016) + STR0017,STR0065,STR0014) //"Extrato "###"Conciliado"###"Liquidado"###". Exclusao nao permitida!","Atencao","Extrato"
ElseIf FS_ExtAss()
	HS_MsgInf(STR0014 + STR0018 + STR0017,STR0065,STR0014) //"Extrato "###"Associado"###"Exclusao nao permitida!"###"Atencao"###"Extrato"
Else
	axDeleta(cAlias, nReg, nOpc)
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_ExtAss บ Autor ณ Cibele Peria       บ Data ณ 15/07/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se o extrato ja foi associado a alguma conta ou   บฑฑ
ฑฑบ          ณ recurso.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ExtAss()
Local cAliasOld := Alias()
Local lRet := .T.

DbSelectArea("GCZ")
DbSetOrder(5)
DbSeek(xFilial("GCZ") + GE0->GE0_NUMEXT)
If Eof()
	DbSelectArea("GF0")
	DbSetOrder(3)
	DbSeek(xFilial("GF0") + GE0->GE0_NUMEXT)
	If Eof()
		lRet := .F.
	Endif
Endif

DbSelectArea(cAliasOld)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_M38Ass บ Autor ณ Cibele Peria       บ Data ณ 15/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Associacao de faturas/contas                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Ass(cAlias, nReg, nOpc)
Local cAliasOld := Alias()
Local nGDOpc := GD_UPDATE, nOpcA
Local cTitulo := ""
Local cPrefix := ""
Local cNrFatu := ""
Local cNrLote := ""
Local cRegGer	:= ""
Local nGera   := 0
Local cCond   := ""
Local nIndice := 0

Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPFol    := {}
Local aPObjs   := {}

Local aButtons := {}
Local bFS_Pesq:= "", bKeyF11
Local lNfsTela	:= SuperGetMV("MV_NFSTELA", .F., .F.)
Local cTamSer	:= TamSX3("E1_SERIE")[1]

Private nLenGCZA := 0
Private nLenGF0T := 0

Private aCGCZA := {}
Private aHGCZA := {}
Private nUGCZA := 0

Private aCGF0T := {}
Private aHGF0T := {}
Private nUGF0T := 0

Private nA_NrFatu := 0
Private nA_MarGCZ := 0
Private nA_NumRec := 0
Private nA_MarGF0 := 0
Private nA_NrSeqG := 0
Private lCBoxA    := .T.

Private oDlgA, oGCZA, oGF0A, oCBoxA, oNumExtA, oFolderA, oFolderB, oPPesq

Private aDetRec  := {}

Private __cFunPesq := ""

If !HS_ExisDic({{"C", "GF7_ORIDES"}})
	Return(Nil)
EndIf

If !HS_ExisDic({{"C", "GF7_CODCRM"}})
	Return(Nil)
EndIf

If !HS_ExisDic({{"C", "GF7_NOMMED"}})
	Return(Nil)
EndIf

If GE0->GE0_STATUS <> "1"
	HS_MsgInf(STR0019 + IIF(GE0->GE0_STATUS == "2", STR0015, STR0020) + STR0021,STR0065,STR0014) //"Este extrato encontra-se "###"conciliado"###"fechado"###"Associacao nao permitida"###"Atencao"###"Extrato"
	Return()
Endif

DbSelectArea("SE1")

cGCZStatus := "4"
cE1Prefixo := IIF(Len(GetMV("MV_HSPSERI")) >= Len(SE1->E1_SERIE), GetMV("MV_HSPSERI"), PadR(GetMV("MV_HSPSERI"), Len(SE1->E1_SERIE))) + "/" + IIF(Len(GetMV("MV_PREFCRH")) >= Len(SE1->E1_PREFIXO), GetMV("MV_PREFCRH"), PadR(GetMV("MV_PREFCRH"), Len(SE1->E1_PREFIXO)))
cSE1Prefix := IIF(Len(GetMV("MV_HSPSERI")) >= Len(SE1->E1_SERIE), GetMV("MV_HSPSERI"), PadR(GetMV("MV_HSPSERI"), Len(SE1->E1_SERIE))) + "/" + IIF(Len(GetMV("MV_PREFCRH")) >= Len(SE1->E1_PREFIXO), GetMV("MV_PREFCRH"), PadR(GetMV("MV_PREFCRH"), Len(SE1->E1_PREFIXO)))
cE1Cliente := HS_IniPadR("GA9", 1, GE0->GE0_CODCON, "GA9_CODCLI",, .F.)
cE1Loja    := HS_IniPadR("GA9", 1, GE0->GE0_CODCON, "GA9_LOJA",, .F.)
lE1Saldo   := .T.

If !Pergunte("HSM38A",.T.)
	Return()
EndIf

cPrefix := mv_par01
cNrFatu := mv_par02
cNrLote := mv_par03
cRegGer := mv_par04
nGera   := mv_par05

If (Empty(cPrefix) .and. !Empty(cNrFatu)) .or. (!Empty(cPrefix) .and. Empty(cNrFatu))
	HS_MsgInf(STR0114,STR0014,STR0065) //"Informe o prefixo e o tํtulo para sele็ใo"###"Atencao"###"Extrato"
	Return()
Endif

If Empty(cNrFatu) .and. Empty(cNrLote) .and. Empty(cRegGer) .and. Empty(cPrefix)
	HS_MsgInf(STR0022,STR0014,STR0065) //"Informe o n๚mero da guia, do lote ou o prontuแrio para sele็ใo"###"Atencao"###"Extrato"
	Return()
Endif

If (!Empty(cNrFatu) .and. (!Empty(cNrLote) .or. !Empty(cRegGer))) .or. ;
	(!Empty(cNrLote) .and. (!Empty(cNrFatu) .or. !Empty(cRegGer))) .or. ;
	(!Empty(cRegGer) .and. (!Empty(cNrLote) .or. !Empty(cNrFatu)))
	HS_MsgInf(STR0023,STR0065,STR0014) //"Informe um dos tr๊s parโmetros: Tํtulo, Lote ou prontuแrio."###"Aten็ใo"###"Extrato"
	Return()
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem dos dados das faturas das despesas - GCZ ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cCond := 	"GCZ->GCZ_FILFAT == '" + cFilAnt + "' .And. GCZ->GCZ_STATUS == '4' .and. GCZ->GCZ_CODCON == '" + GE0->GE0_CODCON + "'"
cCond += 	" .And. GCZ->GCZ_NRSEQG IN (SELECT GE7_NRSEQG NRSEQG " + ;
			"                           FROM " + RetSqlName("GE7") + " GE7 " + ;
			"	                          WHERE GE7->GE7_FILIAL == GCZ->GCZ_FILATE AND GE7.D_E_L_E_T_ <> '*' " + ;
			"                           .AND. GE7->GE7_PGTMED <> '0' .And. GE7->GE7_GLODES == '0' " + ;
			"                           UNION ALL " + ;
			"                           SELECT GE5_NRSEQG NRSEQG " + ;
			"                           FROM " + RetSqlName("GE5") + " GE5 " + ;
			"	                          WHERE GE5->GE5_FILIAL == GCZ->GCZ_FILATE AND GE5.D_E_L_E_T_ <> '*' "
If HS_ExisDic({{"C", "GE5_PGTMED"}}, .F.)
	cCond  +=	"                           .AND. GE5->GE5_PGTMED <> '0' .And. GE5->GE5_GLODES == '0' "
EndIf
cCond +=	"                           UNION ALL " + ;
			"                           SELECT GE6_NRSEQG NRSEQG " + ;
			"                           FROM " + RetSqlName("GE6") + " GE6 " + ;
			"	                          WHERE GE6->GE6_FILIAL == GCZ->GCZ_FILATE AND GE6.D_E_L_E_T_ <> '*' "
If HS_ExisDic({{"C", "GE6_PGTMED"}}, .F.)
	cCond  +=	"                           .AND. GE6->GE6_PGTMED <> '0' .And. GE6->GE6_GLODES == '0' "
EndIf
cCond +=	"                           )"

If !Empty(cNrFatu)
	cCond		+= " .and. GCZ->GCZ_NRFATU == '" + cNrFatu + "'"
ElseIf !Empty(cNrLote)
	cCond  += " .and. GCZ->GCZ_NRLOTE == '" + cNrLote + "'"
ElseIf !Empty(cRegGer)
	cCond  += " .and. GCZ->GCZ_REGGER == '" + cRegGer + "'"
Endif

// Somente monta as faturas se foi selecionado
If nGera == 1 .or. nGera == 3
	nLenGCZA  := HS_BDados("GCZ", @aHGCZA, @aCGCZA, @nUGCZA, 10, .F., cCond, , , "GCZ_FILATE/GCZ_NRSEQG/GCZ_NRFATU/GCZ_DATFAT/GCZ_HORFAT/GCZ_NRLOTE/GCZ_REGGER/GCZ_NOME  /GCZ_VLGUIA/GCZ_MATRIC/GCZ_NRGUIA", , , .F., "GCZ_IDMARC", "'LBTIK'", .T.,,,,,,,,,,,, "GCZ_FILATE")
	nA_NrFatu := aScan(aHGCZA, {| aVet | aVet[2] == "GCZ_NRFATU"})
	nA_NrSeqG := aScan(aHGCZA, {| aVet | aVet[2] == "GCZ_NRSEQG"})
	nA_MarGCZ := aScan(aHGCZA, {| aVet | aVet[2] == "GCZ_IDMARC"})
	nA_FilAte := aScan(aHGCZA, {| aVet | aVet[2] == "GCZ_FILATE"})
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem dos dados dos recursos - GF0             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// Somente monta os recursos se foi selecionado
If nGera == 2 .or. nGera == 3
	cCond  := "GF0->GF0_STATUS  == '1' .and. GF0->GF0_CODCON == '" + GE0->GE0_CODCON + "'"
	nLenGF0T  := HS_BDados("GF0", @aHGF0T, @aCGF0T, @nUGF0T, 2,, cCond, , , /*"GF0_NRSEQG/GF0_NUMREC/GF0_QTDDES/GF0_DATREC"*/, , , .F., "GF0_IDMARC", "'LBTIK'", .T.)
	nA_MarGF0 := aScan(aHGF0T, {| aVet | aVet[2] == "GF0_IDMARC"})
	nA_NumRec := aScan(aHGF0T, {| aVet | aVet[2] == "GF0_NUMREC"})
EndIf

If nLenGCZA == 0 .and. nGera == 1
	HS_MsgInf(STR0024,STR0065,STR0014) //"Nใo hแ faturas selecionadas para os parโmetros (Lote/Paciente) informados."###"Atencao"###"Extrato"
	Return()
Endif

If nLenGF0T == 0 .and. nGera == 2
	HS_MsgInf(STR0025,STR0065,STR0014) //"Nao hแ recursos selecionados para os parโmetros (Lote/Paciente) informados."###"Atencao"###"Extrato"
	Return()
Endif

If nlenGCZA == 0 .and. nLenGF0T == 0
	HS_MsgInf(STR0026,STR0065,STR0014) //"Nenhuma fatura ou recurso foi selecionado para os parโmetros (Lote/Paciente) informados."###"Atencao"###"Extrato"
	Return()
Endif

aSize    := MsAdvSize(.T.) // pega o tamanho total da tela
aObjects := {}
AAdd( aObjects, { 100, 010, .T., .T., .T. } )
AAdd( aObjects, { 100, 090, .T., .T., .T. } )

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T., .T. } ) // quantos objetos terao na tela 100% horizontal e 100% vertical
aInfo    := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 } // tamanho do objeto dentro da tela
aPFol    := MsObjSize(aInfo, aObjects, .T.) // retorna o tamanho que cada objeto ocupara na tela

aObjects := {}
AAdd( aObjects, { 100, 50, .T., .T., .T. } ) // posicao da getdados de recursos
AAdd( aObjects, { 100, 50, .T., .T., .T. } ) // posicao do folder secundario de recursos
aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPFol2 := MsObjSize(aInfo, aObjects, .T.)

cTitulo  := STR0014 + GE0->GE0_NUMEXT + " " + AllTrim(Posicione("GA9",1,xFilial("GA9")+GE0->GE0_CODCON, "GA9_NOME" )) //"Extrato "
nOpcA    := 0

DEFINE MSDIALOG oDlgA TITLE OemToAnsi(cTitulo) From aSize[7], 000 to aSize[6], aSize[5] Of oMainWnd Pixel

oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgA,,,,,, aPObjs[1, 3], aPObjs[1, 4])
oPPesq:Align := CONTROL_ALIGN_TOP

@ 007,270 CheckBox oCBoxA Var lCBoxA Prompt STR0027 SIZE 50, 10 OF oPPesq PIXEL ; //"Marca todos"
On Click (FS_MARCALL(IIF(oFolderA:nOption==1, "oGCZA", "oGF0A"), ;
IIF(oFolderA:nOption==1, nA_MarGCZ, nA_MarGF0),lCBoxA))

@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolderA SIZE aPObjs[2, 3], aPObjs[2, 4] OF oDlgA PIXEL PROMPTS STR0028, STR0029 //"Faturas"###"Recursos"
oFolderA:Align := CONTROL_ALIGN_ALLCLIENT
oFolderA:bChange := {|| FS_AltFold("A", "CBoxA", .F., oFolderA:nOption)}

If nLenGCZA == 0
	oFolderA:aDialogs[1]:lActive := .F.
	oFolderA:nOption := 2
Else
	oGCZA := MsNewGetDados():New(000, 000, 216, 335,0 /*nGDOpc*/, , , ,"GCZ_IDMARC", , Len(aCGCZA), , , , oFolderA:aDialogs[1], aHGCZA, aCGCZA)
	oGCZA:oBrowse:BlDblClick := {|| HS_MARCA("oGCZA", oGCZA:oBrowse:nAt, nA_MarGCZ) }
	oGCZA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	__cFunPesq := "HS_MARCA('oGCZA', oGCZA:oBrowse:nAt, nA_MarGCZ)"
	
	HS_GDPesqu( , , oGCZA, oPPesq, 005, .T.)
Endif

If nLenGF0T == 0
	oFolderA:aDialogs[2]:lActive := .F.
	oFolderA:nOption := 1
Else
	
	// carrega aheder e acols do GF5, 6 e 7
	aDetRec := FS_GETREC( aHGF0T, aCGF0T, "_NUMREC", "3")
	
	aHGF5   := aDetRec[1,1]
	aCGF5   := aDetRec[1,2]
	
	aHGF6   := aDetRec[1,4]
	aCGF6   := aDetRec[1,5]
	
	aHGF7   := aDetRec[1,7]
	aCGF7   := aDetRec[1,8]
	
	oGF0A := MsNewGetDados():New(aPfol2[1,1], aPfol2[1,2], aPfol2[1,4], aPfol2[1,3],0 /*nGDOpc*/, , , ,"GF0_IDMARC", , Len(aCGF0T), , , , oFolderA:aDialogs[2], aHGF0T, aCGF0T)
	oGF0A:oBrowse:BlDblClick := {|| HS_MARCA("oGF0A", oGF0A:oBrowse:nAt, nA_MarGF0) }
	oGF0A:bChange := {|| FS_ChgRec( oGF0A:oBrowse:nAt, @oGF5, @oGF6, @oGF7, @oFolderB, aDetRec ) }
	oGF0A:oBrowse:bGotFocus := {|| FS_ChgRec( oGF0A:oBrowse:nAt, @oGF5, @oGF6, @oGF7, @oFolderB, aDetRec ) }
	oGF0A:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ aPFol2[2, 1], aPFol2[2, 2] FOLDER oFolderB SIZE aPFol2[2, 3], aPFol2[2, 4] OF oFolderA:aDialogs[2] PIXEL PROMPTS STR0030, STR0031, STR0032 //"Mat/Med"###"Taxas"###"Procedimentos"
	oFolderB:Align := CONTROL_ALIGN_BOTTOM
	
	oGF5 := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[2,4]-20, aPfol2[2,3]-5, 0,,,,,,len(aCGF5),,,,oFolderB:aDialogs[1],aHGF5,aCGF5)
	oGF5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGF6 := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[2,4]-20, aPfol2[2,3]-5, 0,,,,,,len(aCGF6),,,,oFolderB:aDialogs[2],aHGF6,aCGF6)
	oGF6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGF7 := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[2,4]-20, aPfol2[2,3]-5, 0,,,,,,len(aCGF6),,,,oFolderB:aDialogs[3],aHGF7,aCGF7)
	oGF7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	__cFunPesq := "HS_MARCA('oGF0A', oGF0A:oBrowse:nAt, nA_MarGF0)"
	
	HS_GDPesqu( , , oGF0A, oPPesq, 005, .T.)
	
	oFolderA:nOption := 2
Endif

ACTIVATE MSDIALOG oDlgA ON INIT EnchoiceBar(oDlgA, {|| nOpcA := 1, oDlgA:End()}, {|| nOpcA := 0, oDlgA:End()},,aButtons)

If nOpcA == 1
	FS_Associar()
Endif

Return()
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_Marca บ Autor ณ Cibele Peria       บ Data ณ  17/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca fatura/recurso do browse                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ                               
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_Marca(cNomObj, nLin, nCol, lMark)
&(cNomObj):aCols[nLin, nCol] := IIF( &(cNomObj):aCols[nLin, nCol] == "LBNO","LBTIK","LBNO")
&(cNomObj):Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MARCALLบ Autor ณ Cibele Peria       บ Data ณ  17/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca todos as faturas do browse                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MarcAll(cNomObj, nPos, lMark)
Local cVal := IIF(lMark, "LBTIK", "LBNO"), nForAC := 0

For nForAC := 1 to len( &(cNomObj):aCols)
	&(cNomObj):aCols[nForAC,nPos] := cVal
Next
&(cNomObj):oBrowse:Refresh()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AltFoldบ Autor ณ Cibele Peria       บ Data ณ 21/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Desmarca o CBox de Marca Todos                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AltFold(cTipo, cCBox, lVal, nFolder)
Local oObj

&("l" + cCBox) := lVal
&("o" + cCBox):Refresh()

If nFolder == 1 .And. &("oGCZ" + cTipo) <> Nil
	oObj := &("oGCZ" + cTipo)
ElseIf nFolder == 2 .And. &("oGF0" + cTipo) <> Nil
	oObj := &("oGF0" + cTipo)
EndIf

If oObj <> Nil .And. cTipo == "A"  //Associar
	If nFolder == 1
		__cFunPesq := "HS_MARCA('oGCZA', oGCZA:oBrowse:nAt, nA_MarGCZ)"
	ElseIf nFolder == 2
		__cFunPesq := "HS_MARCA('oGF0A', oGF0A:oBrowse:nAt, nA_MarGF0)"
	EndIf
	HS_GDPesqu( , , oObj, oPPesq, 005, .T.)
EndIf
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Associaบ Autor ณ Cibele Peria       บ Data ณ  21/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Associa a(s) fatura(s) ao extrato do convenio              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Associar()
Local nForAC := 0, cAliasOld := Alias()
Local cFilAte := ""

Begin Transaction

If nLenGCZA > 0
	ProcRegua(len(oGCZA:aCols))
	For nForAC := 1 to len(oGCZA:aCols)
		If oGCZA:aCols[nForAC,nA_MarGCZ] == "LBTIK"
			IncProc(STR0033 + oGCZA:aCols[nForAC, nA_NrFatu] + STR0034) //"Associando fatura "###". Aguarde..."
			
			cFilAte := IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), oGCZA:aCols[nForAC,nA_FilAte])
			
			FS_AssDesp("GE5", oGCZA:aCols[nForAC,nA_NrSeqG], cFilAte)
			FS_AssDesp("GE6", oGCZA:aCols[nForAC,nA_NrSeqG], cFilAte)
			FS_AssDesp("GE7", oGCZA:aCols[nForAC,nA_NrSeqG], cFilAte)
			DbSelectArea("GCZ")
			DbSetOrder(1)
			If DbSeek(cFilAte + oGCZA:aCols[nForAC,nA_NrSeqG])
				RecLock("GCZ", .F.)
				GCZ->GCZ_STATUS := "5"  //Associado
				GCZ->GCZ_DATSTA := dDataBase
				GCZ->GCZ_NREXTC := GE0->GE0_NUMEXT
				GCZ->GCZ_LOGARQ := HS_LogArq()
				MsUnlock()
			EndIf
		Endif
	Next
Endif

If nLenGF0T > 0
	ProcRegua(len(oGF0A:aCols))
	For nForAC := 1 to len(oGF0A:aCols)
		If oGF0A:aCols[nForAC,nA_MarGF0] == "LBTIK"
			IncProc(STR0035 + oGF0A:aCols[nForAC, nA_NumRec] + STR0034) //"Associando recurso "###". Aguarde..."
			
			FS_AssRec("GF5", oGF0A:aCols[nForAC,nA_NumRec], 4)
			FS_AssRec("GF6", oGF0A:aCols[nForAC,nA_NumRec], 4)
			FS_AssRec("GF7", oGF0A:aCols[nForAC,nA_NumRec], 4)
			
			DbSelectArea("GF0")
			DbSetOrder(2)
			If DbSeek(xFilial("GF0") + "1" + GE0->GE0_CODCON + oGF0A:aCols[nForAC,nA_NumRec])
				RecLock("GF0", .F.)
				GF0->GF0_STATUS := "2"  //Associado
				GF0->GF0_NREXTC := GE0->GE0_NUMEXT
				GF0->GF0_LOGARQ := HS_LogArq()
				MsUnlock()
			EndIf
		Endif
	Next
Endif

End Transaction

DbSelectArea(cAliasOld)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AssDespบ Autor ณ Cibele Peria       บ Data ณ  21/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Associa despesas                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AssDesp(cAlias, cNrSeqG, cFilAte)
Local cAliasOld := Alias()
Local cPref     := cAlias + "->" + PrefixoCpo(cAlias)
Local cAliasGrv := STRTRAN(cAlias, "GE", "GF"), cPrefGrv := cAliasGrv + "->" + PrefixoCpo(cAliasGrv)
Local nCont     := 0, nNroGFs := 1
Local cFilGE    := IIF(Empty(xFilial(cAlias)), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte)

DbSelectArea(cAlias)
DbSetOrder(2)
DbSeek(cFilGE + cNrSeqG)
While !Eof() .and. &(cPref + "_FILIAL") == cFilGE .and. &(cPref + "_NRSEQG") == cNrSeqG
	
	If HS_ExisDic({{"C", cAlias + "_PGTMED"}}, .F.) .And. (&(cPref + "_PGTMED") == "0" .Or. &(cPref + "_GLODES") <> "0")
		DbSkip()
		Loop
	Endif
	
	RecLock(cAlias, .F.)
	&(cPref + "_STATUS") := "1"  //Associado
	&(cPref + "_DATSTA") := dDataBase
	&(cPref + "_HORSTA") := Time()
	&(cPref + "_NREXTC") := GE0->GE0_NUMEXT
	&(cPref + "_LOGARQ") := HS_LogArq()
	MsUnlock()
	
	If cAlias == "GE7" //Grava o Numero do Extrato nos Itens do Pacote(GG7)
		DbSelectArea("GA7")
		DbSetOrder(1)
		DbSeek(IIF(Empty(xFilial("GA7")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte) + GE7->GE7_CODDES)
		If GA7->GA7_TIPPRO == "9" //Pacote
			FS_AtuGG7("Assoc", GE7->GE7_SEQDES, GE0->GE0_NUMEXT, cFilAte)
		EndIf
		nNroGFs := IIf(&(cPref + "_VFILME") > 0, 2, 1)
	EndIf
	
	For nCont := 1 To nNroGFs //1-Normal 2-Filme
		DbSelectArea(cAliasGrv)
		RecLock(cAliasGrv, .T.)
		&(cPrefGrv + "_FILIAL") := xFilial(cAliasGrv)
		If cAlias == "GE7"
			&(cPrefGrv + "_CODCRM") := GE7->GE7_CODCRM
		EndIf
		&(cPrefGrv + "_NREXTC") := GE0->GE0_NUMEXT
		If cAlias == "GE7"
			&(cPrefGrv + "_ORIDES") := IIF(nCont == 1, "0", "3") //0=Normal 3=Filme
		EndIf
		&(cPrefGrv + "_NRSEQG") := &(cPref + "_NRSEQG")
		&(cPrefGrv + "_SEQDES") := &(cPref + "_SEQDES")
		&(cPrefGrv + "_CODDES") := &(cPref + "_CODDES")
		&(cPrefGrv + "_VALAPR") := IIF(nCont == 1, HS_CValDes(cAlias, &(cPref + "_SEQDES"),,,, .F.), &(cPref + "_VFILME") * &(cPref + "_QTDDES"))
		&(cPrefGrv + "_STATUS") := "1"   //Associado ao extrato
		&(cPrefGrv + "_DATSTA") := dDataBase
		&(cPrefGrv + "_HORSTA") := Time()
		&(cPrefGrv + "_SEQMOV") := "000001"
		&(cPrefGrv + "_ULTREG") := "2" //1=Nao 2=Sim (ultimo registro)
		&(cPrefGrv + "_CODCON") := GE0->GE0_CODCON
		&(cPrefGrv + "_LOGARQ") := HS_LogArq()
		If HS_ExisDic({{"C", PrefixoCpo(cAliasGrv)+"_FILATE"}}, .F.)
			&(cPrefGrv + "_FILATE") := cFilAte
		EndIf
		MsUnlock()
	Next
	
	DbSelectArea(cAlias)
	DbSkip()
EndDo

DbSelectArea(cAliasOld)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AssRec บ Autor ณ Cibele Peria       บ Data ณ  23/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Associa recursos ao extrato                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AssRec(cAlias, cNumRec, nIndice)
Local cAliasOld := Alias()
Local cPref     := cAlias + "->" + PrefixoCpo(cAlias)
Local aDespRec  := {}
Local nForRec   := 0, nRec := 0, nCampo := 0
Local aRecNo    := {}

DbSelectArea(cAlias)
DbSetOrder(nIndice)//_NUMREC
DbSeek(xFilial(cAlias) + cNumRec)
While !Eof() .and. &(cPref + "_FILIAL") == xFilial(cAlias) .and. &(cPref + "_NUMREC") == cNumRec
	nRec += 1
	aAdd(aRecNo, RecNo())
	aAdd(aDespRec, Array(FCount()))
	For nCampo := 1 To FCount()
		aDespRec[nRec, nCampo] := FieldGet(nCampo)
	Next nCampo
	DbSkip()
End

For nRec := 1 to len(aDespRec)
	RecLock(cAlias, .T.)
	For nCampo := 1 to len(aDespRec[nRec])
		FieldPut(nCampo, aDespRec[nRec, nCampo])
	Next nCampo
	&(cPref + "_VALPAG") := &(cPref + "_VALPAG") + &(cPref + "_VALREC")
	&(cPref + "_VALGLO") := &(cPref + "_VALGLO") - &(cPref + "_VALREC")
	&(cPref + "_VALREC") := 0
	&(cPref + "_VALPER") := 0
	&(cPref + "_NREXTC") := GE0->GE0_NUMEXT
	&(cPref + "_NRRECO") := &(cPref + "_NUMREC")
	&(cPref + "_NUMREC") := ""
	
	If HS_ExisDic({{"C", PrefixoCpo(cAlias)+"_VLRREC"}}, .F.)
		&(cPref + "_VLRREC") := 0
	EndIf
	
	If HS_ExisDic({{"C", PrefixoCpo(cAlias)+"_NREXTM"}}, .F.)
		&(cPref + "_NREXTM") := ""
	EndIf
	
	If &(cPref + "_STATUS") <> "6"
		&(cPref + "_STATUS") := "1"
	EndIf
	
	&(cPref + "_DATSTA") := dDataBase
	&(cPref + "_HORSTA") := Time()
	&(cPref + "_ULTREG") := "2" //Sim
	&(cPref + "_SEQMOV") := FS_SeqMov(&(cPref + "_SEQMOV"), +1)
	&(cPref + "_LOGARQ") := HS_LogArq()
	MsUnlock()
Next nRec

For nRec := 1 to len(aRecNo)
	DbGoto(aRecNo[nRec])
	RecLock(cAlias, .F.)
	If &(cPref + "_STATUS") <> "6"
		&(cPref + "_STATUS") := "7"
	EndIf
	&(cPref + "_DATSTA") := dDataBase
	&(cPref + "_HORSTA") := Time()
	&(cPref + "_ULTREG") := "1" //Nao
	&(cPref + "_LOGARQ") := HS_LogArq()
	MsUnlock()
Next nRec

DbSelectArea(cAliasOld)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_M38Des บ Autor ณ Cibele Peria       บ Data ณ 15/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Desassociacao de faturas e recursos                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Des(cAlias, nReg, nOpc)
Local cAliasOld := Alias(), nOpcA
Local cCond := "", nIndice := 0, nTitulo := "", cElimina := ""
Local aSize := {}, aObjects := {}, aInfo := {}, aPFol := {}
Private nLenGCZD := 0, nLenGF0D := 0
Private aCGCZD := {}, aHGCZD := {}, nUGCZD := 0
Private aCGF0D := {}, aHGF0D := {}, nUGF0D := 0
Private nD_NrFatu := 0, nD_MarGCZ := 0, nD_NrSeqG := 0
Private nD_NumRec := 0, nD_NrRecO := 0, nD_MarGF0 := 0
Private oDlgD, oGCZD, oGF0D, oCBoxD, lCBoxD := .T., oNumExtD, oFolderD

If !HS_ExisDic({{"C", "GF7_ORIDES"}})
	Return(Nil)
EndIf

If !HS_ExisDic({{"C", "GF7_CODCRM"}})
	Return(Nil)
EndIf

If !HS_ExisDic({{"C", "GF7_NOMMED"}})
	Return(Nil)
EndIf

IF GE0->GE0_STATUS <> "1"
	HS_MsgInf(STR0019 + IIF(GE0->GE0_STATUS == "2", STR0015, STR0020) + STR0036,STR0065,STR0038) //"Este extrato encontra-se "###"conciliado"###"fechado"###". Desassociacao nao permitida","Atencao","Desassociacao de FaTURA"
	Return()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem dos dados das faturas das despesas - GCZ ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cCond	   := "GCZ->GCZ_FILFAT == '" + cFilAnt + "' .And. GCZ->GCZ_STATUS == '5' .and. GCZ->GCZ_NREXTC == '" + GE0->GE0_NUMEXT + "'"
cElimina := "GCZ->GCZ_VALPAG <> 0 .or. GCZ->GCZ_VALGLO <> 0"

nLenGCZD  := HS_BDados("GCZ", @aHGCZD, @aCGCZD, @nUGCZD, 12, .F., cCond, , , "GCZ_FILATE/GCZ_NRSEQG/GCZ_NREXTC/GCZ_NRFATU/GCZ_DATFAT/GCZ_HORFAT/GCZ_NRLOTE/GCZ_REGGER/GCZ_NOME", cElimina, , .F., "GCZ_IDMARC", "'LBTIK'", .T.,,,,,,,,,,,, "GCZ_FILATE")
nD_NrSeqG := aScan(aHGCZD, {| aVet | aVet[2] == "GCZ_NRSEQG"})
nD_NrFatu := aScan(aHGCZD, {| aVet | aVet[2] == "GCZ_NRFATU"})
nD_NrExtC := aScan(aHGCZD, {| aVet | aVet[2] == "GCZ_NREXTC"})
nD_MarGCZ := aScan(aHGCZD, {| aVet | aVet[2] == "GCZ_IDMARC"})
nD_FilAte := aScan(aHGCZD, {| aVet | aVet[2] == "GCZ_FILATE"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem dos dados dos recursos - GF0             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cCond  := "GF0->GF0_STATUS  == '2' .and. GF0->GF0_NREXTC == '" + GE0->GE0_NUMEXT + "'"
cElimina := "GF0->GF0_VALREC <> 0 .Or. GF0->GF0_VALPER <> 0"
nLenGF0D  := HS_BDados("GF0", @aHGF0D, @aCGF0D, @nUGF0D, 3,, cCond, , , "GF0_NRSEQG/GCZ_NREXTC/GF0_NUMREC/GF0_QTDDES/GF0_DATREC", cElimina, , .F., "GF0_IDMARC", "'LBTIK'", .T.)
nD_MarGF0 := aScan(aHGF0D, {| aVet | aVet[2] == "GF0_IDMARC"})
nD_NumRec := aScan(aHGF0D, {| aVet | aVet[2] == "GF0_NUMREC"})

If nlenGCZD == 0 .and. nLenGF0D == 0
	HS_MsgInf(STR0037,STR0065,STR0038) //"Nenhuma fatura ou recurso foi associada ao extrato ou as mesmas ja foram detalhadas","Atencao","Desassociacao de FaTURA"
	Return()
Endif

aSize := MsAdvSize(.T.)

// Posicao do folder principal
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPFol := MsObjSize(aInfo, aObjects)

aObjects := {}
AAdd( aObjects, { 100, 50, .T., .T., .T. } ) // posicao da getdados de recursos
AAdd( aObjects, { 100, 50, .T., .T., .T. } ) // posicao do folder secundario de recursos
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPFol2 := MsObjSize(aInfo, aObjects)

cTitulo := STR0014 + GE0->GE0_NUMEXT + " " + AllTrim(Posicione("GA9",1,xFilial("GA9")+GE0->GE0_CODCON, "GA9_NOME" )) //"Extrato "
nOpcA := 0
DEFINE MSDIALOG oDlgD TITLE OemToAnsi(cTitulo) From aSize[7], 000 to aSize[6], aSize[5] Of oMainWnd Pixel

@ 018,010 CheckBox oCBoxD Var lCBoxD Prompt STR0027 SIZE 50, 10 OF oDlgD PIXEL ; //"Marca todos"
On Click (FS_MARCALL(IIF(oFolderD:nOption==1, "oGCZD", "oGF0D"), ;
IIF(oFolderD:nOption==1, nD_MarGCZ, nD_MarGF0), ;
lCBoxD))

@ aPFol[1, 1]+20, aPFol[1, 2] FOLDER oFolderD SIZE aPFol[1, 3], aPFol[1, 4] OF oDlgD PIXEL PROMPTS STR0028, STR0029 //"Faturas"###"Recursos"
oFolderD:bChange := {|| FS_AltFold("D", "CBoxD", .T., oFolderD:nOption)}
If nLenGCZD == 0
	oFolderD:aDialogs[1]:lActive := .F.
	oFolderD:nOption := 2
Else
	oGCZD := MsNewGetDados():New(000, 000, 216, 335, 0/*nOpc*/, , , ,"GCZ_IDMARC", , Len(aCGCZD), , , , oFolderD:aDialogs[1], aHGCZD, aCGCZD)
	oGCZD:oBrowse:BlDblClick := {|| HS_MARCA("oGCZD", oGCZD:oBrowse:nAt, nD_MarGCZ) }
	oGCZD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif

If nLenGF0D == 0
	oFolderD:aDialogs[2]:lActive := .F.
	oFolderD:nOption := 1
Else
	// carrega aheder e acols do GF5, 6 e 7
	aDetRec := FS_GETREC( aHGF0D, aCGF0D, "_NRRECO", "1" )
	
	aHGF5   := aDetRec[1,1]
	aCGF5   := aDetRec[1,2]
	
	aHGF6   := aDetRec[1,4]
	aCGF6   := aDetRec[1,5]
	
	aHGF7   := aDetRec[1,7]
	aCGF7   := aDetRec[1,8]
	
	oGF0D := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[1,4]-20, aPfol2[1,3]-5, 0/*nOpc*/, , , ,"GF0_IDMARC", , Len(aCGF0D), , , , oFolderD:aDialogs[2], aHGF0D, aCGF0D)
	oGF0D:oBrowse:BlDblClick := {|| HS_MARCA("oGF0D", oGF0D:oBrowse:nAt, nD_MarGF0) }
	oGF0D:bChange := {|| FS_ChgRec( oGF0D:oBrowse:nAt, @oGF5, @oGF6, @oGF7, @oFolderB, aDetRec ) }
	
	@ aPFol2[2, 1]-30, aPFol2[2, 2] FOLDER oFolderB SIZE aPFol2[2, 3], aPFol2[2, 4] OF oFolderD:aDialogs[2] PIXEL PROMPTS STR0030, STR0031, STR0032 //"Mat/Med"###"Taxas"###"Procedimentos"
	
	oGF5 := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[2,4]-20, aPfol2[2,3]-5, 0,,,,,,len(aCGF5),,,,oFolderB:aDialogs[1],aHGF5,aCGF5)
	
	oGF6 := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[2,4]-20, aPfol2[2,3]-5, 0,,,,,,len(aCGF6),,,,oFolderB:aDialogs[2],aHGF6,aCGF6)
	
	oGF7 := MsNewGetDados():New(aPfol2[1,1]-10, aPfol2[1,2], aPfol2[2,4]-20, aPfol2[2,3]-5, 0,,,,,,len(aCGF6),,,,oFolderB:aDialogs[3],aHGF7,aCGF7)
	
Endif


ACTIVATE MSDIALOG oDlgD CENTERED ON INIT EnchoiceBar(oDlgD, {|| nOpcA := 1, oDlgD:End()}, {|| nOpcA := 0, oDlgD:End()})

If nOpcA == 1
	FS_DesAssr()
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DesAssrบ Autor ณ Cibele Peria       บ Data ณ  21/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ DesAssocia a(s) fatura(s) ao extrato do convenio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DesAssr()
Local nForAC := 0, cAliasOld := Alias()
Local cFilAte := ""

Begin Transaction

If nLenGCZD > 0
	ProcRegua(len(oGCZD:aCols))
	For nForAC := 1 to len(oGCZD:aCols)
		If oGCZD:aCols[nForAC,nD_MarGCZ] == "LBTIK"
			IncProc(STR0038 + oGCZD:aCols[nForAC, nD_NrFatu] + STR0034) //"Desassociando fatura "###". Aguarde..."
			
			cFilAte := IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), oGCZD:aCols[nForAC,nD_FilAte])
			
			FS_DssDesp("GE5", oGCZD:aCols[nForAC, nD_NrSeqG], cFilAte)
			FS_DssDesp("GE6", oGCZD:aCols[nForAC, nD_NrSeqG], cFilAte)
			FS_DssDesp("GE7", oGCZD:aCols[nForAC, nD_NrSeqG], cFilAte)
			
			DbSelectArea("GCZ")
			DbSetOrder(5)
			If DbSeek(cFilAte + oGCZD:aCols[nForAC, nD_NrExtC] + oGCZD:aCols[nForAC, nD_NrSeqG])
				RecLock("GCZ", .F.)
				GCZ->GCZ_STATUS := "4"  //Aberto
				GCZ->GCZ_DATSTA := dDataBase
				GCZ->GCZ_NREXTC := Space(Len(GCZ->GCZ_NREXTC))
				GCZ->GCZ_LOGARQ := HS_LogArq()
				MsUnlock()
			EndIf
		Endif
	Next
Endif

If nLenGF0D > 0
	ProcRegua(len(oGF0D:aCols))
	For nForAC := 1 to len(oGF0D:aCols)
		If oGF0D:aCols[nForAC, nD_MarGF0] == "LBTIK"
			IncProc(STR0035 + oGF0D:aCols[nForAC, nD_NumRec] + STR0034) //"Associando recurso "###". Aguarde..."
			
			FS_DssRec("GF5", oGF0D:aCols[nForAC, nD_NumRec])
			FS_DssRec("GF6", oGF0D:aCols[nForAC, nD_NumRec])
			FS_DssRec("GF7", oGF0D:aCols[nForAC, nD_NumRec])
			
			DbSelectArea("GF0")
			DbSetOrder(2)
			If DbSeek(xFilial("GF0") + "2" + GE0->GE0_CODCON + oGF0D:aCols[nForAC, nD_NumRec])
				RecLock("GF0", .F.)
				GF0->GF0_STATUS := "1"  //Em Recurso
				GF0->GF0_NREXTC := Space(Len(GF0->GF0_NREXTC))
				GF0->GF0_LOGARQ := HS_LogArq()
				MsUnlock()
			EndIF
		Endif
	Next
Endif

End Transaction

DbSelectArea(cAliasOld)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DssDespบ Autor ณ Cibele Peria       บ Data ณ  21/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ DesAssocia despesas                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DssDesp(cAlias, cNrSeqG, cFilAte)
Local cAliasOld := Alias()
Local cPref     := cAlias + "->" + PrefixoCpo(cAlias)
Local cAliasDel := STRTRAN(cAlias, "GE", "GF"), cPrefDel := cAliasDel + "->" + PrefixoCpo(cAliasDel)
Local aDesp     := {}, nForDesp := 0
Local cFilGE    := IIF(Empty(xFilial(cAlias)), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte)

DbSelectArea(cAlias)
DbSetOrder(4)
While DbSeek(cFilGE + GE0->GE0_NUMEXT + cNrSeqG + "1")
	DbSelectArea(cAliasDel)
	DbSetOrder(1) //NREXTC + SEQDES + STATUS + ORIDES)
	While DbSeek(xFilial(cAliasDel) + GE0->GE0_NUMEXT + &(cPref + "_SEQDES") + "1" + IIF(cAlias == "GF7", &(cPref + "_ORIDES"), ""))
		RecLock(cAliasDel, .F., .T.)
		DBDelete()
		MsUnlock()
	End
	
	If cAlias == "GE7" //Zera o Numero do Extrato nos Itens do Pacote(GG7)
		DbSelectArea("GA7")
		DbSetOrder(1)
		DbSeek(IIF(Empty(xFilial("GA7")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte) + GE7->GE7_CODDES)
		If GA7->GA7_TIPPRO == "9" //Pacote
			FS_AtuGG7("Desas", GE7->GE7_SEQDES, GE0->GE0_NUMEXT, cFilAte)
		EndIf
	EndIf
	
	DbSelectArea(cAlias)
	RecLock(cAlias, .F.)
	&(cPref + "_STATUS") := " "
	&(cPref + "_DATSTA") := dDataBase
	&(cPref + "_HORSTA") := Time()
	&(cPref + "_NREXTC") := SPACE(LEN(cPref + "_NREXTC"))
	&(cPref + "_LOGARQ") := HS_LogArq()
	MsUnlock()
End

DbSelectArea(cAliasOld)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DssRec บ Autor ณ Cibele Peria       บ Data ณ  23/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Desassocia recursos do extrato                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DssRec(cAlias, cNumRec)
Local cAliasOld := Alias()
Local cPref     := cAlias + "->" + PrefixoCpo(cAlias)
Local aDespRec := {}, nForRec := 0

DbSelectArea(cAlias)
DbSetOrder(6)       //FILIAL+NREXTM+NRRECO
DbSeek(xFilial(cAlias) + GE0->GE0_NUMEXT + cNumRec)
While !Eof() .and. &(cPref + "_FILIAL") == xFilial(cAlias) .and. &(cPref + "_NREXTC") == GE0->GE0_NUMEXT .and. &(cPref + "_NRRECO") == cNumRec
	aAdd(aDespRec, {&(cPref + "_SEQDES"), &(cPref + "_STATUS"), IIF(cAlias == "GF7", &(cPref + "_ORIDES"), "")} )
	DbSkip()
End
If len(aDespRec) == 0
	DbSelectArea(cAliasOld)
	Return()
Endif

DbSelectArea(cAlias)
DbSetOrder(1) //NREXTC + SEQDES + STATUS + ORIDES
For nForRec := 1 to len(aDespRec)
	If DbSeek(xFilial(cAlias) + GE0->GE0_NUMEXT + aDespRec[nForRec, 1] + aDespRec[nForRec, 2] + IIF(cAlias == "GF7", aDespRec[nForRec, 3], ""))
		RecLock(cAlias, .F., .T.)
		DBDelete()
		MsUnlock()
	EndIf
Next

DbSelectArea(cAlias)
DbSetOrder(4) //FILIAL+NUMREC+STATUS
DbSeek(xFilial(cAlias) + cNumRec + "7")
While !Eof() .and. &(cPref + "_FILIAL") == xFilial(cAlias) .and. &(cPref + "_NUMREC") == cNumRec .and. &(cPref + "_STATUS") == "7"
	RecLock(cAlias, .F.)
	&(cPref + "_STATUS") := "3"
	&(cPref + "_DATSTA") := dDataBase
	&(cPref + "_HORSTA") := Time()
	&(cPref + "_ULTREG") := "2" //Sim
	&(cPref + "_LOGARQ") := HS_LogArq()
	MsUnLock()
	
	DbSelectArea(cAlias)
	DbSkip()
End

DbSelectArea(cAliasOld)
Return(.T.)

/* ======================================================================================================= */
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_M38Det บ Autor ณ Cibele Peria       บ Data ณ 15/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Detalhamento das despesas                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Det(cAlias, nReg, nOpc)
Local nOpcA := 0, nGDOpc := IIF(nOpc == 8 .And. (GE0->GE0_STATUS == '2' .Or. GE0->GE0_STATUS == '3'), 0, GD_UPDATE)
Local aButtons   := {}
Local bFS_Pagar  := "", bKeyF4
Local bFS_PagarT := "", bKeyF5
Local bFS_Glosar := "", bKeyF6
Local bFS_DetGrp := "", bKeyF7
Local nCont      := 0
Local lRet       := .T.

Local aSize      := {}, aObjects := {}, aInfo := {}, aPFol := {}
Local cSQL       := ""
Local nForT      := 0
Local cCond      := ""
Local aLegGCZ    := {{"TMPGCZ->GCZ_NREXTC == '" + GE0->GE0_NUMEXT + "'", "BR_AZUL"}, ; //Guias
{"TMPGCZ->GCZ_NREXTC <> '" + GE0->GE0_NUMEXT + "'", "BR_AMARELO" }} //Recurso
Local cCposGCZ   := "GCZ_FILATE/GCZ_NRSEQG/GCZ_NREXTC/GCZ_REGATE/GCZ_NOME  /GCZ_NRSEQG/GCZ_NRGUIA/GCZ_NRFATU/GCZ_DATFAT/GCZ_REGGER/GCZ_STATUS/" + ;
"GCZ_MATRIC/GCZ_VLGUIA/GCZ_VALPAG/GCZ_VALGLO/GCZ_VLPAGM/GCZ_VLGLOM/GCZ_VLPAGT/GCZ_VLGLOT/GCZ_VLPAGP/GCZ_VLGLOP/" + ;
"GCZ_VALREC/GCZ_VALPER/GCZ_VLRECM/GCZ_VLPERM/GCZ_VLRECT/GCZ_VLPERT/GCZ_VLRECP/GCZ_VLPERP/"

Local aOPesq:={}
Private aArqDesp := {"GF5", "GF6", "GF7"}
Private oGCZ, aCGCZ := {}, aHGCZ := {}, nUGCZ := 0, nLenGCZ := 0
Private oGF5, aCGF5 := {}, aHGF5 := {}, nUGF5 := 0, nLenGF5 := 0
Private oGF6, aCGF6 := {}, aHGF6 := {}, nUGF6 := 0, nLenGF6 := 0
Private oGF7, aCGF7 := {}, aHGF7 := {}, nUGF7 := 0, nLenGF7 := 0

Private oDlg, oCBox, lCBoxA := .F., oNumExt, oFolder, oPPesq , oPPesq1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ As Variaveix nG_, lG, cG... sao variaveis da guia posicionada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aG_Guias  := {}   //Contem as guias associadas ao extrato.
Private cG_NrSeqG := ""   //Vai conter o codigo da guia posicionada
Private cG_FilAte := ""   //Vai conter a filial atendimento da guia posicionada
Private lG_Guia   := .F.  //Indica se a guia eh de conta normal (.T.) ou de recurso (.F.)
Private lG_Tmp    := .F.  //Indica se as despesas da guia ja foram atualizadas nos arquivos temporarios

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis de posicionamento da Getdados da GCZ     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nCZ_NrSeqG := 0
Private nCZ_FilAte := 0
Private nCZ_ValPag := 0
Private nCZ_ValGlo := 0
Private nCZ_VlPagM := 0
Private nCZ_VlGloM := 0
Private nCZ_VlPagT := 0
Private nCZ_VlGloT := 0
Private nCZ_VlPagP := 0
Private nCZ_VlGloP := 0
Private nCZ_ValRec := 0
Private nCZ_ValPer := 0
Private nCZ_VlRecM := 0
Private nCZ_VlPerM := 0
Private nCZ_VlRecT := 0
Private nCZ_VlPerT := 0
Private nCZ_VlRecP := 0
Private nCZ_VlPerP := 0
Private nCZ_Status := 0
Private nCZ_NrExtC := 0
Private nCZ_VlGuia := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis de posicionamento das despesas           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nF5_SeqDes := 0, nF6_SeqDes := 0, nF7_SeqDes := 0
Private nF5_CodDes := 0, nF6_CodDes := 0, nF7_CodDes := 0
Private nF5_DDespe := 0, nF6_DDespe := 0, nF7_DDespe := 0
Private nF5_ValApr := 0, nF6_ValApr := 0, nF7_ValApr := 0
Private nF5_ValPag := 0, nF6_ValPag := 0, nF7_ValPag := 0
Private nF5_ValGlo := 0, nF6_ValGlo := 0, nF7_ValGlo := 0
Private nF5_ValRec := 0, nF6_ValRec := 0, nF7_ValRec := 0
Private nF5_ValPer := 0, nF6_ValPer := 0, nF7_ValPer := 0
Private nF5_CdMGlo := 0, nF6_CdMGlo := 0, nF7_CdMGlo := 0
Private nF5_DsMGlo := 0, nF6_DsMGlo := 0, nF7_DsMGLo := 0
Private nF5_CdJGlo := 0, nF6_CdJGlo := 0, nF7_CdJGlo := 0
Private nF5_DsJGlo := 0, nF6_DsJGlo := 0, nF7_DsJGlo := 0
Private nF5_ComJGl := 0, nF6_ComJGl := 0, nF7_ComJGl := 0
Private nF5_NrReco := 0, nF6_NrReco := 0, nF7_NrReco := 0
Private nF5_Status := 0, nF6_Status := 0, nF7_Status := 0
Private nF5_NrExtM := 0, nF6_NrExtM := 0, nF7_NrExtM := 0
Private nF5_QtDDet := 0, nF5_VlTDes := 0
Private nF6_QtDDet := 0, nF6_VlTDes := 0
Private nF7_QtDDet := 0, nF7_VlTDes := 0
Private nF7_OriDes := 0
Private nF7_CodCrm := 0
Private nF7_NomMed := 0

Private aHDes := {}
Private nPosFol_Ant := 0

Private aTabTmp    := {}

If !HS_ExisDic({{"C", "GF7_ORIDES"}})
	Return(Nil)
EndIf

If !HS_VldSX6({{"MV_GRPMATM", {"SB1", "B1_COD"}}}, .T.) .Or. !HS_VldSX6({{"MV_GRPTAXD", {"GAA", "GAA_CODTXD"}}}, .T.) .Or. ;
	!HS_VldSX6({{"MV_MGLOGRP", {"GDM", "GDM_CODIGO"}}}, .T.)
	Return(Nil)
EndIf

If !HS_ExisDic({{"I", "GF5", 9, "BOPS 153759 - 18/09/08"}})
	Return(Nil)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecao das guias relacionadas ao extrato         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cCond := FS_InicGui()) //Seleciona guias das despesas do extrato (guias e recursos) e atualiza aGuiasRet
	DbSelectArea("GF0REC")
	DbCloseArea()
	HS_MsgInf(STR0043,STR0065,STR0038) //"Nenhuma guia de despesa ou recurso foi associado ao extrato"
	Return()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem dos dados das guias do extrato - GCZ     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("GCZ")

nLenGCZ := HS_BDados("GCZ", @aHGCZ, @aCGCZ, @nUGCZ, 5, .F., cCond,, "GCZ_IDMARC", cCposGCZ,,,,,,.T., aLegGCZ,,,,,,,,,,, "GCZ_FILATE")

nCZ_FilAte := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_FILATE"})
nCZ_NrSeqG := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_NRSEQG"})
nCZ_ValPag := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VALPAG"})
nCZ_ValGlo := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VALGLO"})
nCZ_VlPagM := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLPAGM"})
nCZ_VlGloM := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLGLOM"})
nCZ_VlPagT := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLPAGT"})
nCZ_VlGloT := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLGLOT"})
nCZ_VlPagP := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLPAGP"})
nCZ_VlGloP := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLGLOP"})
nCZ_ValRec := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VALREC"})
nCZ_ValPer := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VALPER"})
nCZ_VlRecM := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLRECM"})
nCZ_VlPerM := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLPERM"})
nCZ_VlRecT := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLRECT"})
nCZ_VlPerT := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLPERT"})
nCZ_VlRecP := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLRECP"})
nCZ_VlPerP := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLPERP"})
nCZ_Status := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_STATUS"})
nCZ_NrExtC := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_NREXTC"})
nCZ_VlGuia := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_VLGUIA"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inclusao do botao para detalhar despesa como paga ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
bFS_Pagar  := {||FS_PagGlo(oGCZ:nAt, "P")}
bFS_PagarT := {||FS_PagarT(aArqDesp)}
bFS_Glosar := {||FS_PagGlo(oGCZ:nAt, "G")}
bFS_DetGrp := {||FS_DetGrp(oGCZ:nAt)}

Aadd(aButtons	, {'EDIT',{||Eval(bFS_Pagar)},STR0041}) //"Pagar Conta"
Aadd(aButtons	, {'AUTOM',{||Eval(bFS_PagarT)},STR0042}) //"Pagar Todos"
Aadd(aButtons	, {'PARAMETROS',{||Eval(bFS_Glosar)},STR0097	}) //"Glosar Conta"
Aadd(aButtons	, {'S4WB011N',{||Eval(bFS_DetGrp)}, "Det. Grupo"})

bKeyF4  :=  SetKey( VK_F4, { || Eval(bFS_Pagar)} )
bKeyF5  :=  SetKey( VK_F5, { || Eval(bFS_PagarT)} )
bKeyF6  :=  SetKey( VK_F6, { || Eval(bFS_Glosar)} )
bKeyF7  :=  SetKey( VK_F7, { || Eval(bFS_DetGrp)} )

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 010, .T., .T. } )
AAdd( aObjects, { 100, 045, .T., .T. } )
AAdd( aObjects, { 100, 045, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize(aInfo, aObjects, .T.)
cTitulo := STR0014 + GE0->GE0_NUMEXT + " " + AllTrim(Posicione("GA9",1,xFilial("GA9")+GE0->GE0_CODCON, "GA9_NOME" )) //"Extrato "

nOpcA     := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) From aSize[7], 000 to aSize[6], aSize[5]	Of oMainWnd Pixel
oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlg,,,,,, aPObjs[1, 3], aPObjs[1, 4])
oPPesq:Align := CONTROL_ALIGN_TOP



oGCZ := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3]-(aPObjs[2, 3] / 2.3), aPObjs[2, 4], nGDOpc, , , ,{"GCZ_VALPAG", "GCZ_VALGLO", "GCZ_VLPAGM", "GCZ_VLGLOM", "GCZ_VLPAGT", "GCZ_VLGLOT"}, , Len(aCGCZ), , , , oDlg, aHGCZ, aCGCZ)
oGCZ:bLinhaOK          := {|| HS_TOKDes()}
oGCZ:bChange           := {|| MsgRun(STR0115 + " [" + aG_Guias[oGCZ:oBrowse:nAt][1] + "]",, {|| FS_MntDesp(oGCZ:oBrowse:nAt)})} //"Carregando despesas da guia"
oGCZ:oBrowse:bGotFocus := {|| FS_MntDesp(oGCZ:oBrowse:nAt)}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Geracao dos dados das despesass                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FS_MntDesp(1, .T.)

@ aPObjs[3, 1], aPObjs[3, 2] FOLDER oFolder SIZE aPObjs[3, 3], aPObjs[3, 4]  OF oDlg PIXEL PROMPTS STR0044, STR0045, STR0032 //"Materiais/Medicamentos"###"Taxas/Diarias"###"Procedimentos"
oFolder:Align := CONTROL_ALIGN_BOTTOM

oPPesq1	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],,  oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4]- 86)
oPPesq1:Align := CONTROL_ALIGN_BOTTOM
oGF5 := MsNewGetDados():New(aPObjs[3, 1], aPObjs[3, 2], aPObjs[3, 3], aPObjs[3, 4], nGDOpc,,,,{"GF5_VALPAG", "GF5_VALGLO", "GF5_VALREC", "GF5_VALPER", "GF5_CDMGLO", "GF5_CDJGLO", "GF5_COMJGL"}, , len(aCGF5), , , , oFolder:aDialogs[1], aHGF5, aCGF5)
oGF5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGF5:bLinhaOK      := {|| HS_LOKDes(1) }
oGF5:oBrowse:bLostFocus := {|| HS_LOKDes(1,,, .T.) }
aAdd(aOPesq, {"oGF5", "01"})

oGF6 := MsNewGetDados():New(aPObjs[3, 1], aPObjs[3, 2], aPObjs[3, 3], aPObjs[3, 4], nGDOpc,,,,{"GF6_VALPAG", "GF6_VALGLO", "GF6_VALREC", "GF6_VALPER", "GF6_CDMGLO", "GF6_CDJGLO", "GF6_COMJGL"}, , len(aCGF6), , , , oFolder:aDialogs[2], aHGF6, aCGF6)
oGF6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGF6:bLinhaOK      := {|| HS_LOKDes(2) }
oGF6:oBrowse:bLostFocus := {|| HS_LOKDes(2,,, .T.) }
aAdd(aOPesq, {"oGF6", "02"})

oGF7 := MsNewGetDados():New(aPObjs[3, 1], aPObjs[3, 2], aPObjs[3, 3], aPObjs[3, 4], nGDOpc,,,,{"GF7_VALPAG", "GF7_VALGLO", "GF7_VALREC", "GF7_VALPER", "GF7_CDMGLO", "GF7_CDJGLO", "GF7_COMJGL"}, , len(aCGF7), , , , oFolder:aDialogs[3], aHGF7, aCGF7)
oGF7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGF7:bLinhaOK      := {|| HS_LOKDes(3) }
oGF7:oBrowse:bLostFocus := {|| HS_LOKDes(3,,, .T.) }
aAdd(aOPesq, {"oGF7", "03"})

FS_CarVarG(1)
oFolder:nOption := IIf(nLenGF5==0, IIf(nLenGF6==0, 3, 2), 1)
oFolder:Refresh()
FS_CarVarD(aArqDesp[oFolder:nOption])

nPosGui_Ant := oGCZ:nAt
nPosFol_Ant := oFolder:nOption

HS_GDPesqu( , , oGCZ, oPPesq, 005, .T.)

aSort(aOPesq,,, {| X, Y | X[2] < Y[2]})
oFolder:bChange:= {|| HS_GDPesqu(,, &(aOPesq[oFolder:nOption, 1]), oPPesq1, 005, .T.) }
HS_GDPesqu(,, &(aOPesq[oFolder:nOption, 1]), oPPesq1, 005, .T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(HS_TOKDes(), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()},,aButtons)

HS_DtvFilt("GCZ")
SetKey(VK_F4, bKeyF4)
SetKey(VK_F5, bKeyF5)
SetKey(VK_F6, bKeyF6)
SetKey(VK_F7, bKeyF7)

If nOpcA == 1
	Begin Transaction
	FS_Dtalhar()
	End Transaction
	FS_REAPSUS()
Endif


For nCont := 1 To Len(aTabTmp)
	DbSelectArea(aTabTmp[nCont, 1])
	DbCloseArea()
Next

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_InicGuiบ Autor ณ Cibele Peria       บ Data ณ 21/07/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona todas os codigos das guias (de fatura e de recur-บฑฑ
ฑฑบ          ณ so), relacionados ao extrato.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_InicGui(nPasso)
Local cAlias    := ""
Local cSQL      := ""
Local nForArq   := 0
Local cCond     := ""
Local aCampos   := {}
Local cTabRec   := ""
Local cAliasRec := "GF0REC"
Local cInd1     := ""
Local cPref     := ""
private oTempGF0

Default nPasso := 99

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria arquivo temporario dos recursos do extrato ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aCampos, {"NUMREC", "C", LEN(GF0->GF0_NUMREC), 0} )
aAdd(aCampos, {"VLRECU", "N", 10, 4} )
aAdd(aCampos, {"VALREC", "N", 10, 4} )
aAdd(aCampos, {"VALPER", "N", 10, 4} )
aAdd(aCampos, {"VLRECM", "N", 10, 4} )
aAdd(aCampos, {"VLPERM", "N", 10, 4} )
aAdd(aCampos, {"VLRECT", "N", 10, 4} )
aAdd(aCampos, {"VLPERT", "N", 10, 4} )
aAdd(aCampos, {"VLRECP", "N", 10, 4} )
aAdd(aCampos, {"VLPERP", "N", 10, 4} )
aAdd(aCampos, {"STATUS", "C", 10, 0} )
aAdd(aCampos, {"RECNO", "N", 9, 0} )

aAdd(aTabTmp, {cAliasRec, cTabRec, cInd1})

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempGF0 := FWTemporaryTable():New( cAliasRec )
oTempGF0:SetFields( aCampos )
oTempGF0:AddIndex( "INDREC",{ "NUMREC" } )

if( select( cAliasRec ) > 0 )
	( cAliasRec )->( dbCloseArea() )
endIf

oTempGF0:Create()

dbSelectArea( cAliasRec )
GF0REC->( dbSetorder( 1 ) )

cSQL := "SELECT GF0_NUMREC, GF0_VLRECU, GF0_VALREC, GF0_VALPER, GF0_VLRECM, GF0_VLPERM, "
cSQL += "GF0_VLRECT, GF0_VLPERT, GF0_VLRECP, GF0_VLPERP, GF0_STATUS, R_E_C_N_O_ AS GF0_RECNO "
cSQL += "FROM " + RetSQLName("GF0") + " "
cSQL += "WHERE GF0_FILIAL = '" + xFilial(cAlias) + "' AND D_E_L_E_T_ <> '*' "
cSQL += "AND GF0_NREXTC = '" + GE0->GE0_NUMEXT + "'"
TCQUERY cSQL NEW ALIAS "REC"
DbSelectArea("REC")
DbGoTop()
While !Eof()
	DbSelectArea("GF0REC")
	DbGoto(REC->GF0_RECNO)
	RecLock("GF0REC", .T.)
	GF0REC->NUMREC := REC->GF0_NUMREC
	GF0REC->VLRECU := REC->GF0_VLRECU
	GF0REC->VALREC := REC->GF0_VALREC
	GF0REC->VALPER := REC->GF0_VALPER
	GF0REC->VLRECM := REC->GF0_VLRECM
	GF0REC->VLPERM := REC->GF0_VLPERM
	GF0REC->VLRECT := REC->GF0_VLRECT
	GF0REC->VLPERT := REC->GF0_VLPERT
	GF0REC->VLRECP := REC->GF0_VLRECP
	GF0REC->VLPERP := REC->GF0_VLPERP
	GF0REC->STATUS := REC->GF0_STATUS
	GF0REC->RECNO  := REC->GF0_RECNO
	MsUnlock()
	
	DbSelectArea("REC")
	DbSkip()
End
DbSelectArea("REC")
DbCloseArea()

If nPasso < 2
	Return()
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Passo 2: Carrega as guias envolvidas (de guias normais e de recurso), envolvidas no extrato ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSQL  := "SELECT GCZ_NRSEQG NRSEQG, GCZ_NREXTC NREXTC, GCZ_FILATE FILATE " + ;
"FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.D_E_L_E_T_ <> '*' AND "

cCond := " GCZ.GCZ_FILFAT = '" + cFilAnt + "' AND ("
For nForArq := 1 to Len(aArqDesp)
	cAlias := aArqDesp[nForArq]
	cPref  := PrefixoCpo(cAlias)
	cCond  += IIF(nForArq > 1, " OR ", "")
	cCond  += "EXISTS (SELECT " + cPref + "_FILATE " + ;
	"         FROM " + RetSQLName(cAlias) + " " + cAlias + ;
	"         WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' " + ;
	"         AND " + cPref + "_NREXTC = '" + GE0->GE0_NUMEXT + "' AND " + cPref + "_FILATE = GCZ.GCZ_FILATE " + ;
	"         AND " + cPref + "_NRSEQG = GCZ.GCZ_NRSEQG) "
Next nForArq
cCond += ")"
cSQL  += cCond
cSQL  += " ORDER BY FILATE"
cSQL  := ChangeQuery(cSQL)

TCQUERY cSQL NEW ALIAS "GUI"
DbSelectArea("GUI")
DbGoTop()
If Eof()
	cCond := ""
Endif

While !Eof()
	If aScan(aG_Guias, {| aVet | aVet[1] == GUI->NRSEQG .And. aVet[6] == GUI->FILATE}) == 0
		aAdd(aG_Guias, {GUI->NRSEQG, ;                                  //1-Numero da guia
		IIF(GUI->NREXTC==GE0->GE0_NUMEXT, .T., .F.), ; //2-Indica se trata-se de uma guia ou de um recurso
		.F., ;                                         //3-Indice se ja gravou despesas da guia nos arquivos temporarios
		{0, 0, 0}, ;                                    //4-Vai conter os valores das despesas dos grupos, respctivamente GF5/6/7
		{0, 0, 0},;                                     //5-Vai conter a quantidade de despesas detalhadas por grupo
		GUI->FILATE})                                   //6-Filial atendimento da guia
		
	Endif
	
	DbSkip()
End

DbCloseArea()
Return(cCond)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_CriaTmpบ Autor ณ Cibele Peria       บ Data ณ 21/07/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processa as inicializacoes necessarias das despesas        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CriaTmp(cAlias)
Local aHDes     := {}
Local aCampos   := {}
Local nForAH    := 0
Local cAliasTmp := ""
Local cTabela   := ""
Local cInd1     := ""
Local oTempTable

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria arquivo temporario da despesa              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//aHeader[nForAH, 2]  -> X3_CAMPO
//aHeader[nForAH, 8]  -> X3_TIPO
//aHeader[nForAH, 4]  -> X3_TAMANHO
//aHeader[nForAH, 5]  -> X3_DECIMAL
//aHeader[nForAH, 10] -> X3_CONTEXTO

aHDes := aClone(&("aH"+cAlias))
aCampos   := {}
aAdd(aCampos, {"NRSEQG", "C", LEN(GCZ->GCZ_NRSEQG), 0} )
For nForAH := 1 to len(aHDes)
	aAdd(aCampos, {StrTran(aHDes[nForAH, 2], PrefixoCpo(cAlias) + "_", ""), ;
	aHDes[nForAH, 8], ;
	aHDes[nForAH, 4], ;
	aHDes[nForAH, 5]})
Next nForAH

cAliasTmp := cAlias + "TMP"

aAdd(aTabTmp, {cAliasTmp, cTabela, cInd1})

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTable := FWTemporaryTable():New( cAliasTmp )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex( "INDTMP",{ "FILATE","NRSEQG","SEQDES","CODDES",iif( cAlias == "GF7","ORIDES","") } )

if( select( cAliasTmp ) > 0 )
	( cAliasTmp )->( dbCloseArea() )
endIf

( cAliasTmp )->( dbSetOrder( 1 ) )

oTempTable:Create()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_CarVarGบ Autor ณ Cibele Peria       บ Data ณ 22/07/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega variaveis genericas da guia                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CarVarG(nGuia)
Local nPosGui := 0

//==> Ocorrencias do array aG_Guias:
//    1-Numero da guia
//    2-Indica se trata-se de uma guia ou de um recurso
//    3-Indice se ja gravou despesas da guia nos arquivos temporarios
//    4-Vai conter os valores das despesas dos grupos, respctivamente GF5/6/7 {0, 0, 0}
//    5-Vai conter a quantidade de despesas detalhadas por grupo {0, 0, 0}
//    6-Filial de Atendimento da Guia

cG_NrSeqG := IIF(Empty(nGuia), cG_NrSeqG, oGCZ:aCols[nGuia, nCZ_NRSEQG])
cG_FilAte := IIF(Empty(nGuia), cG_FilAte, oGCZ:aCols[nGuia, nCZ_FilAte])
nPosGui   := aScan(aG_Guias, {| aVet | aVet[1] == cG_NrSeqG .And. aVet[6] == cG_FilAte})

lG_Guia   := aG_Guias[nPosGui, 2]

lG_Tmp    := aG_Guias[nPosGui, 3]

nF5_VlTDes := aG_Guias[nPosGui, 4, 1]
nF6_VlTDes := aG_Guias[nPosGui, 4, 2]
nF7_VlTDes := aG_Guias[nPosGui, 4, 3]

nF5_QtDDet := aG_Guias[nPosGui, 5, 1]
nF6_QtDDet := aG_Guias[nPosGui, 5, 2]
nF7_QtDDet := aG_Guias[nPosGui, 5, 3]

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_CarVarDบ Autor ณ Cibele Peria       บ Data ณ 09/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega variaveis genericas da despesa selecionada         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CarVarD(cAlias, lDetGrp)
Local cPrefVar := "n" + Substr(cAlias, 2)

Default lDetGrp := .F.

cHeader := cAlias + IIF(lDetGrp, "DetG", "")

If cAlias == "GF7"
	&(cPrefVar + "_OriDes") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_ORIDES" })
EndIf
&(cPrefVar + "_SeqDes") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_SEQDES" })
&(cPrefVar + "_CodDes") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_CODDES" })
&(cPrefVar + "_DDespe") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_DDESPE" })
&(cPrefVar + "_ValApr") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_VALAPR" })
&(cPrefVar + "_ValPag") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_VALPAG" })
&(cPrefVar + "_ValGlo") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_VALGLO" })
&(cPrefVar + "_ValRec") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_VALREC" })
&(cPrefVar + "_ValPer") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_VALPER" })
&(cPrefVar + "_CdMGlo") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_CDMGLO" })
&(cPrefVar + "_DsMGlo") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_DSMGLO" })
&(cPrefVar + "_CdJGlo") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_CDJGLO" })
&(cPrefVar + "_DsJGlo") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_DSJGLO" })
&(cPrefVar + "_ComJGl") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_COMJGL" })
&(cPrefVar + "_Status") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_STATUS" })
If cAlias == "GF7"
	&(cPrefVar + "_CodCrm") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_CODCRM"})
	&(cPrefVar + "_NomMed") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_NOMMED"})
EndIf
&(cPrefVar + "_NrExtM") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_NREXTM" })
&(cPrefVar + "_NrReco") := aScan(&("aH" + cHeader), {| aVet | aVet[2] == cAlias + "_NRRECO" })

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_MntDespบ Autor ณ Cibele Peria       บ Data ณ 27/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta as Despesas da conta informada posicionada           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MntDesp(nGuia, lCriaTmp, lFac, lDetGrp)
Local aAreaOld := GetArea()
Local cAlias    := ""
Local nForArq   := 0
Local nPosGui   := 0
Local aHTmp     := {}
Local aCTmp     := {}
Local nUTmp     := 0
Local nFolAtiv  := 0
Local aFolAtiv	 := {}

Default lCriaTmp := .F.
Default lFac     := .F. //Botao de facilitadores
Default lDetGrp  := .F.

If lG_Tmp .and. !lFac
	FS_AtuTemp()
Endif

FS_CarVarG(nGuia)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza no arquivo temporario os valores VALPAG e VALGLO do browse ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nForArq := 1 to len(aArqDesp)
	
	cAlias  := aArqDesp[nForArq]
	nLen := FS_CarrDes(nGuia, cAlias, @aHTmp, @aCTmp, @nUTmp, lCriaTmp, lDetGrp)
	
	nPosGui   := aScan(aG_Guias, {| aVet | aVet[1] == cG_NrSeqG .And. aVet[6] == cG_FilAte})
	
	If oGF5 # Nil
		&("o"+cAlias):SetArray(aCTmp)
		&("o"+cAlias):oBrowse:Refresh()
		//	oFolder:aDialogs[nForArq]:lActive := IIf(nLen == 0, .F., .T.)
		AADD(aFolAtiv, {nForArq,IIf(nLen == 0, .F., .T.)})
	Endif
	
Next nForArq


If !aG_Guias[nPosGui, 3]
	aG_Guias[nPosGui, 3] := .T.
	aG_Guias[nPosGui, 4, 1] := nF5_VlTDes
	aG_Guias[nPosGui, 4, 2] := nF6_VlTDes
	aG_Guias[nPosGui, 4, 3] := nF7_VlTDes
	aG_Guias[nPosGui, 5, 1] := nF5_QtDDet
	aG_Guias[nPosGui, 5, 2] := nF6_QtDDet
	aG_Guias[nPosGui, 5, 3] := nF7_QtDDet
	lG_Tmp                   := .T.
Endif

If oGF5 # Nil
	oFolder:nOption := IIf(nLenGF5==0, IIf(nLenGF6==0, 3, 2), 1)
	oFolder:Refresh()
	FS_CarVarD(aArqDesp[oFolder:nOption])
Endif

If oGF5 # Nil  //ATIVACAO DO FOLDER APOS CARREGAR OS DADOS POIS QUANDO HAVIA APENAS UM PROCEDIMENTO PARA A GUIA DE BAIXO O GRID DE PROC ERA EXIBIDA EM BRANCO
	For nFolAtiv := 1 to Len(aFolAtiv)
		oFolder:nOption := IIf(nLenGF5==0, IIf(nLenGF6==0, 3, 2), 1)
		oFolder:aDialogs[aFolAtiv[nFolAtiv,1]]:lActive := aFolAtiv[nFolAtiv,2]
	Next nFolAtiv
	oFolder:Refresh()
EndIf

RestArea(aAreaOld)
Return()
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtuTempบ Autor ณ Cibele Peria       บ Data ณ 27/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza os dados digitados nos browses nos arquivos tmp   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AtuTemp()
Local cAlias
Local cAliasTmp
Local aCDes := {}
Local nForArq, nForDes, nPosGui
Local cPrefVar := ""

For nForArq := 1 to len(aArqDesp)
	
	cAlias := aArqDesp[nForArq]
	cPrefVar  := "n" + Substr(cAlias, 2)
	If &("nLen" + cAlias) == 0
		Loop
	Endif
	
	cAliasTmp := cAlias + "TMP"
	aCDes    := aClone(&("o"+cAlias):aCols)
	FS_CarVarD(cAlias)
	DbSelectArea(cAliasTmp)
	DbSetOrder(1)
	
	For nForDes := 1 to len(aCDes)
		If DbSeek(cG_FilAte + cG_NrSeqG + aCDes[nForDes, &(cPrefVar + "_SeqDes")] + aCDes[nForDes, &(cPrefVar + "_CodDes")] + IIF(nForArq == 3, aCDes[nForDes, &(cPrefVar + "_OriDes")], ""))
			
			If (cAliasTmp)->VALPAG # aCDes[nForDes, &(cPrefVar + "_ValPag")] .or. (cAliasTmp)->VALGLO # aCDes[nForDes, &(cPrefVar + "_ValGlo")] .or. ;
				(cAliasTmp)->VALREC # aCDes[nForDes, &(cPrefVar + "_ValRec")] .or. (cAliasTmp)->VALPER # aCDes[nForDes, &(cPrefVar + "_ValPer")] .or. ;
				(cAliasTmp)->CDMGLO # aCDes[nForDes, &(cPrefVar + "_CdMGlo")] .or. (cAliasTmp)->STATUS # acDes[nForDes, &(cPrefVar + "_Status")] .or. ;
				(cAliasTmp)->CDJGLO # aCDes[nForDes, &(cPrefVar + "_CdJGlo")] .or. (cAliasTmp)->COMJGL # Fs_RetMemo(cAlias, acDes[nForDes, &(cPrefVar + "_ComJGl")], cAlias+"_ComJGl")
				Reclock(cAliasTmp, .F.)
				(cAliasTmp)->VALPAG := aCDes[nForDes, &(cPrefVar + "_ValPag")]
				(cAliasTmp)->VALGLO := aCDes[nForDes, &(cPrefVar + "_ValGlo")]
				(cAliasTmp)->VALREC := aCDes[nForDes, &(cPrefVar + "_ValRec")]
				(cAliasTmp)->VALPER := aCDes[nForDes, &(cPrefVar + "_ValPer")]
				(cAliasTmp)->CDMGLO := aCDes[nForDes, &(cPrefVar + "_CdMGlo")]
				(cAliasTmp)->CDJGLO := aCDes[nForDes, &(cPrefVar + "_CdJGlo")]
				(cAliasTmp)->COMJGL := aCDes[nForDes, &(cPrefVar + "_ComJGl")]
				(cAliasTmp)->STATUS := aCDes[nForDes, &(cPrefVar + "_Status")]
				MsUnlock()
			EndIf
		EndIf
		
	Next nForDes
Next nForArq

nPosGui   := aScan(aG_Guias, {| aVet | aVet[1] == cG_NrSeqG .And. aVet[6] == cG_FilAte})
If !aG_Guias[nPosGui, 3]
	aG_Guias[nPosGui, 3] := .T. //Indica que a guia ja foi carregada uma vez e as despesas gravadas nos temporarios
Endif
aG_Guias[nPosGui, 4, 1] := nF5_VlTDes
aG_Guias[nPosGui, 4, 2] := nF6_VlTDes
aG_Guias[nPosGui, 4, 3] := nF7_VlTDes

aG_Guias[nPosGui, 5, 1] := nF5_QtDDet
aG_Guias[nPosGui, 5, 2] := nF6_QtDDet
aG_Guias[nPosGui, 5, 3] := nF7_QtDDet

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_CarrDesบ Autor ณ Cibele Peria       บ Data ณ 07/07/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega as despesas da conta, ainda nao carregada no ar -  บฑฑ
ฑฑบ          ณ quivo temporario                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CarrDes(nGuia, cAlias, aHTmp, aCTmp, nUTmp, lCriaTmp, lDetGrp)
Local cChave   := ""
Local cCond    := ""
Local nInd     := 0
Local cPref    := ""
Local nForAH   := 0
Local nForAC   := 0
Local nLen     := 0
Local cPrefVar := "n"+Substr(cAlias, 2)
Local nPosGui  := aScan(aG_Guias, {| aVet | aVet[1] == cG_NrSeqG .And. aVet[6] == cG_FilAte})
Local cCposDet := "/_FILATE/_ORIDES/_SEQDES/_CODDES/_DDESPE/_VALAPR/_VALPAG/_VALGLO/_NRRECO/_VALREC/_VALPER/_CDMGLO/_DSMGLO/_CDJGLO/_DSJGLO/_COMJGL/_STATUS/_NREXTM"
Local cCdMGlo	:= ""
Local cCdJGlo 	:= ""

If cAlias == "GF7"
	cCposDet += "/_CODCRM/_NOMMED"
EndIf

Default lCriaTmp := .F.

cPref   := cAlias + "->" + PrefixoCpo(cAlias)
aHTmp   := {}
aCTmp   := {}
nUTmp   := 0

nD_QtDDet := 0
nD_VlTDes := 0

If lG_Tmp .And. !lDetGrp //Se a guia ja foi carregada nos arquivos temporarios
	aHTmp  := aClone(&("aH"+cAlias))
	nUTmp  := &("nU"+cAlias)
	
	cChave := cG_FilAte + cG_NrSeqG
	cCond  := cAlias + "TMP->FILATE == '" + cG_FilAte + "' .And. " + cAlias + "TMP->NRSEQG == '" + cG_NrSeqG + "'"
	
	FS_CarVarD(cAlias)
	
	DbSelectArea(cAlias + "TMP")
	DbSetOrder(1)
	DbSeek(cChave)
	While !Eof() .and. &(cCond)
		
		nLen += 1
		
		aAdd(aCTmp, Array(len(aHTmp)+1))
		
		For nForAH := 1 to len(aHTmp)
			cCampo := PrefixoCpo(cAlias) + "TMP->" + StrTran(aHTmp[nForAH, 2], PrefixoCpo(cAlias) + "_", "")
			If aHTmp[nForAH, 2] =  PrefixoCpo(cAlias)+"_CDMGLO"
				aCTmp[len(aCTmp), nForAH] := &(cCampo)
				cCdMGlo := &(cCampo)
			ElseIf aHTmp[nForAH, 2] =  PrefixoCpo(cAlias)+"_DSMGLO"
				GDM->(DbSetOrder(1))
				GDM->(DbSeek(IIF(Empty(xFilial("GDM")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + cCdMGlo))
				aCTmp[len(aCTmp), nForAH] := GDM->GDM_DESC
			ElseIf aHTmp[nForAH, 2] =  PrefixoCpo(cAlias)+"_CDJGLO"
				aCTmp[len(aCTmp), nForAH] := &(cCampo)
				cCdJGlo := &(cCampo)
			ElseIf aHTmp[nForAH, 2] =  PrefixoCpo(cAlias)+"_DSJGLO"
				GG9->(DbSetOrder(1))
				GG9->(DbSeek(IIF(Empty(xFilial("GG9")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + cCdJGlo))
				aCTmp[len(aCTmp), nForAH] := GG9->GG9_DSJGLO
			Else
				aCTmp[len(aCTmp), nForAH] := &(cCampo)
			Endif
		Next nForAH
		aCTmp[len(aCTmp), len(aHTmp)+1] := .F.
		
		If cAlias == "GF5"
			nD_VlTDes := aG_Guias[nPosGui, 4, 1]
			nD_QtDDet := aG_Guias[nPosGui, 5, 1]
		ElseIf cAlias == "GF6"
			nD_VlTDes := aG_Guias[nPosGui, 4, 2]
			nD_QtDDet := aG_Guias[nPosGui, 5, 2]
		Else
			nD_VlTDes := aG_Guias[nPosGui, 4, 3]
			nD_QtDDet := aG_Guias[nPosGui, 5, 3]
		Endif
		
		DbSkip()
	End
	
	&("aC"   + cAlias) := aClone(aCTmp)
	&("aH"   + cAlias) := aClone(aHTmp)
	&("nU"   + cAlias) := nUTmp
	&("nLen" + cAlias) := nLen
	
Else
	aHTmp     := {}
	nUTmp     := 0
	
	cCond    := cPref + "_NREXTC == '" + GE0->GE0_NUMEXT + "' .and. " + cPref + "_NRSEQG == '" + cG_NrSeqG + "' .And. " + cPref + "_FILATE == '" + cG_FilAte + "' " +;
	" .and. " + cPref + "_STATUS <> '6' " //Glosa p/ Grupo
	
	DbSelectArea(cAlias)
	nLen := HS_BDados(cAlias, @aHTmp, @aCTmp, @nUTmp, 1, .F., cCond, , ,STRTRAN(cCposDet, "/_", "/" + PrefixoCpo(cAlias) + "_"), /*cElimina*/, , .F., , , .T.,,,,,,,,,,,, cAlias + "_FILATE")
	&("aC"   + cAlias) := aClone(aCTmp)
	&("aH"   + cAlias) := aClone(aHTmp)
	&("nU"   + cAlias) := nUTmp
	&("nLen" + cAlias) := nLen
	
	If lCriaTmp
		FS_CriaTmp(cAlias)
	Endif
	
	FS_CarVarD(cAlias)
	
	For nForAC := 1 to len(aCTmp)
		If Empty(aCTmp[nForAC, &(cPrefVar + "_CodDes")])
			Loop
		EndIf
		
		If lG_Guia
			nD_QtDDet += IIf(!EMPTY(aCTmp[nForAC, &(cPrefVar + "_SeqDes")]) .And. (aCTmp[nForAC, &(cPrefVar + "_ValPag")] # 0 .Or. aCTmp[nForAC, &(cPrefVar + "_ValGlo")] # 0), 1, 0)
			nD_VlTDes += aCTmp[nForAC, &(cPrefVar + "_ValApr")]
		Else
			nD_QtDDet += IIf(aCTmp[nForAC, &(cPrefVar + "_ValRec")] # 0 .Or. aCTmp[nForAC, &(cPrefVar + "_ValPer")] # 0, 1, 0)
			nD_VlTDes += aCTmp[nForAC, &(cPrefVar + "_ValGlo")]
		Endif
		
		DbSelectArea(cAlias+"TMP")
		RecLock(cAlias+"TMP", .T.)
		&(cAlias+"TMP->FILATE") := cG_FilAte
		&(cAlias+"TMP->NRSEQG") := cG_NrSeqG
		For nForAH := 1 to len(aHTmp)
			cCampo := SUBSTR(aHTmp[nForAH, 2], len(PrefixoCpo(cAlias))+2)
			If aHTmp[nForAH, 8] # "M"
				&(cAlias+"TMP->" + cCampo) := aCTmp[nForAC, nForAH]
			Else
				&(cAlias+"TMP->" + cCampo) := Fs_RetMemo(cAlias,  aCTmp[nForAC, nForAH], aHTmp[nForAH, 2])
				aCTmp[nForAC, nForAH]      := &(cAlias+"TMP->" + cCampo)
			EndIf
		Next nForAH
		MsUnlock()
		
	Next nForAC
Endif

&("n"+SUBSTR(cAlias, 2)+"_QtDDet") := nD_QtDDet
&("n"+SUBSTR(cAlias, 2)+"_VlTDes") := nD_VlTDes

Return(nLen)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_VldM38 บ Autor ณ Cibele Peria       บ Data ณ 25/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao dos campos dos itens das despesas      บฑฑ
ฑฑบ          ณ (GF5/ GF6/ GF7)                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldM38(lDetGrp)
Local cAliasOld := Alias()
Local nGuia     := oGCZ:nAt
Local cAlias    := ""
Local cPrefVar  := ""
Local cReadVar  := SUBSTR(ReadVar(), 8)
Local aHDes     := {}
Local nDes      := 0
Local nValor    := 0
Local lDet_Ant  := .F., lDet_Atu := .F.
Local nPosGui   := aScan(aG_Guias, {| aVet | aVet[1] == cG_NrSeqG .And. aVet[6] == cG_FilAte})
Local oObjDes

Default lDetGrp := .F.

cAlias   := SUBSTR(ReadVar(), 4, 3) + IIF(lDetGrp, "DetG", "")
oObjDes  := "o" + cAlias
nDes     := &(oObjDes):oBrowse:nAt
cPrefVar := "n" + Substr(cAlias, 2, 2)
aHDes    := aClone(&("aH" + cAlias))

FS_CarVarD(SubStr(cAlias, 1, 3), lDetGrp)

If !lDetGrp
	nD_QtDDet := &("n"+SUBSTR(cAlias, 2)+"_QtDDet")
	
	If GE0->GE0_STATUS == "2"
		HS_MsgInf(STR0100,STR0065,STR0102) //"Este extrato encontra-se conciliado. Detalhamento nao permitido!",Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	
	If &(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] $ "3"
		HS_MsgInf(STR0050,STR0065,STR0102) //"Esta despesa nao pode ser alterada pois ja se encontra em recurso","Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Consistencia do Codigo do Motivo de Glosa ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cReadVar == "CDMGLO"
	If lG_Guia
		nValor := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
	Else
		nValor := 	&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")]
	Endif
	If nValor == 0
		HS_MsgInf(IIF(lG_Guia, STR0048, STR0055)+STR0119,STR0065,STR0102) //"Nao houve glosa neste item de despesa."###"Nao houve perda neste item de despesa."###"Motivo de glosa nao permitido"###,"Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	DbSelectArea("GDM")
	DbSetOrder(1)
	If !DbSeek(IIF(Empty(xFilial("GDM")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + &(ReadVar()) )
		HS_MsgInf(STR0049,STR0065,STR0102) //"Codigo informado invalido ou nao cadastrado","Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	&(oObjDes):aCols[nDes, &(cPrefVar + "_DsMGlo")] := GDM->GDM_DESC
	If GDM->GDM_TIPO == "1"
		&(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] := "2"  //Disponivel para recurso
	Else
		&(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] := "4"  //Liquidado
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Consistencia do Codigo da Justificativa de Glosa ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cReadVar == "CDJGLO"
	If lG_Guia
		nValor := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
	Else
		nValor := 	&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")]
	Endif
	If nValor == 0
		HS_MsgInf(IIF(lG_Guia, STR0048, STR0055)+STR0120,STR0065,STR0102) //"Nao houve glosa neste item de despesa."###"Nao houve perda neste item de despesa."###"Justificativa de glosa nao permitido"###,"Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	DbSelectArea("GG9")
	DbSetOrder(1)
	If !DbSeek(IIF(Empty(xFilial("GG9")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + &(ReadVar()) )
		HS_MsgInf(STR0049,STR0065,STR0102) //"Codigo informado invalido ou nao cadastrado","Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	&(oObjDes):aCols[nDes, &(cPrefVar + "_DsJGlo")] := GG9->GG9_DSJGLO
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Consistencia do digitacao das guias - VALPAG e VALGLO ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cReadVar $ "VALPAG/VALGLO"
	If &(ReadVar()) < 0 .Or. IIF(cReadVar == "VALGLO", &(ReadVar()) > &(oObjDes):aCols[nDes, &(cPrefVar + "_ValApr")], .F.)
		HS_MsgInf(STR0051,STR0065,STR0102) //"Valor invalido","Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	
	If !lDetGrp .And. FS_VldTGru(nGuia, cAlias)[1]  //Verifica se ja houve totalizacao por total da conta ou por total do grupo de despesa
		HS_MsgInf(STR0052,STR0065,STR0102) //"Os valores recebimento/glosa para esta conta ja foram informados por totalizacao. Detalhamento nao permitido.","Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	
	If !lDetGrp
		lDet_Ant := IIF(&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] == 0 .and. &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] == 0, .F., .T.)
		&(oObjDes):aCols[nDes, &(cPrefVar + "_CdMGlo")] := Space(aHDes[&(cPrefVar + "_CdMGlo"), 4])
		&(oObjDes):aCols[nDes, &(cPrefVar + "_DsMGlo")] := Space(aHDes[&(cPrefVar + "_DsMGlo"), 4])
		&(oObjDes):aCols[nDes, &(cPrefVar + "_CdJGlo")] := Space(aHDes[&(cPrefVar + "_CdJGlo"), 4])
		&(oObjDes):aCols[nDes, &(cPrefVar + "_DsJGlo")] := Space(aHDes[&(cPrefVar + "_DsJGlo"), 4])
		&(oObjDes):aCols[nDes, &(cPrefVar + "_ComJGl")] := ""
	EndIf
	
	If &(ReadVar()) == 0
		nDifPag := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] * -1
		nDifGlo := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] * -1
		
	ElseIf cReadVar == "VALPAG"
		If &(ReadVar()) == &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] //Se nao houve alteracao
			Return(.T.)
		Endif
		
		If lDetGrp .And. &(ReadVar()) + FS_TotIten(cAlias, "_ValPag", &(oObjDes):oBrowse:nAt) > oGCZ:aCols[nGuia, IIF(cAlias == "GF5DetG", nCZ_VlPagM, nCZ_VlPagT)]
			HS_MsgInf(STR0130,STR0065,STR0102) //"Atencao" //"Validacao dos campos dos itens das despesas" //"Valor invแlido. O somat๓rio dos valores pagos nใo podem ser maior que o valor pago no grupo"
			Return(.F.)
		Endif
		
		nDifPag := &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")]
		nDifGlo := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValApr")] - &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
		If &(ReadVar()) > &(oObjDes):aCols[nDes, &(cPrefVar + "_ValApr")]
			nDifGlo := -&(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
		EndIf
		
	ElseIf cReadVar == "VALGLO"
		If &(ReadVar()) == &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
			Return(.T.)
		Endif
		
		If lDetGrp .And. &(ReadVar()) + FS_TotIten(cAlias, "_ValGlo", &(oObjDes):oBrowse:nAt) > oGCZ:aCols[nGuia, IIF(cAlias == "GF5DetG", nCZ_VlGloM, nCZ_VlGloT)]
			HS_MsgInf(STR0131,STR0065,STR0102) //"Atencao" //"Validacao dos campos dos itens das despesas" //"Valor invแlido. O somat๓rio dos valores glosados nใo podem ser maior que o valor glosado no grupo"
			Return(.F.)
		Endif
		
		nDifGlo := &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
		nDifPag := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValApr")] - &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")]
	Endif
	
	&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] + nDifPag
	&(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] + nDifGlo
	
	If !lDetGrp
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Tratamento do status do item da despesa ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] == 0 .and. &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] == 0
			&(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] := "1"  //Associado
		ElseIf &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] == 0
			&(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] := "5"  //Quitado
		Endif
		FS_AcumDes(nGuia, cAlias, nDifPag, nDifGlo)
		
		lDet_Atu := IIF(&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPag")] == 0 .and. &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] == 0, .F., .T.)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Consistencia do digitacao dos recursos - VALREC e VALPER ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cReadVar $ "VALREC"
	If &(ReadVar()) < 0 .Or. IIF(cReadVar == "VALPER", &(ReadVar()) > &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")], .F.)
		HS_MsgInf(STR0051,STR0065,STR0102) //"Valor invalido","Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	Endif
	
 	If &(M->cAlias + "_VALREC") == &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]	
		lDet_Ant := IIF(&(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")] == 0 .and. &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] == 0, .F., .T.)
 		&(oObjDes):aCols[nDes, &(cPrefVar + "_CdMGlo")] := Space(aHDes[&(cPrefVar + "_CdMGlo"), 4])
	 	&(oObjDes):aCols[nDes, &(cPrefVar + "_DsMGlo")] := Space(aHDes[&(cPrefVar + "_DsMGlo"), 4])
 		&(oObjDes):aCols[nDes, &(cPrefVar + "_CdJGlo")] := Space(aHDes[&(cPrefVar + "_CdJGlo"), 4])
	 	&(oObjDes):aCols[nDes, &(cPrefVar + "_DsJGlo")] := Space(aHDes[&(cPrefVar + "_DsJGlo"), 4])
		&(oObjDes):aCols[nDes, &(cPrefVar + "_ComJGl")] := ""
	EndIf
	
	If &(ReadVar()) == 0
		nDifPag := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")] * -1
		nDifGlo := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] * -1
		
	ElseIf cReadVar == "VALREC"
		If &(ReadVar()) == &(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")]
			Return(.T.)
		Endif
		nDifPag := &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")]
		nDifGlo := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] - &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")]
		If &(ReadVar()) > &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")]
			nDifGlo := -&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")]
		EndIf
		
		
	ElseIf cReadVar == "VALPER"
		If &(ReadVar()) == &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")]
			Return(.T.)
		Endif
		nDifGlo := &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")]
		nDifPag := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValGlo")] - &(ReadVar()) - &(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")]
	Endif
	
	&(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")] := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")] + nDifPag
	&(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] := &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] + nDifGlo
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Tratamento do status do item do recurso ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If &(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")] == 0 .and. &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] == 0
		&(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] := "1"  //Associado
	ElseIf &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] == 0
		&(oObjDes):aCols[nDes, &(cPrefVar + "_Status")] := "5"  //Quitado
	Endif
	FS_AcumDes(nGuia, cAlias, nDifPag, nDifGlo, &(oObjDes):aCols[nDes, &(cPrefVar + "_NrReco")])
	
	lDet_Atu := IIF(&(oObjDes):aCols[nDes, &(cPrefVar + "_ValRec")] == 0 .and. &(oObjDes):aCols[nDes, &(cPrefVar + "_ValPer")] == 0, .F., .T.)
	
Endif

If !lDetGrp
	If !lDet_Ant .and. lDet_Atu
		nD_QtDDet += 1
	ElseIf lDet_Ant .and. !lDet_Atu
		nD_QtDDet += -1
	Endif
	
	aG_Guias[nPosGui, 5, IIF(cAlias=="GF5", 1, IIF(cAlias=="GF6", 2, 3))] := nD_QtDDet
	&("n"+SUBSTR(cAlias, 2)+"_QtDDet") := nD_QtdDet
EndIf

&(oObjDes):oBrowse:Refresh()

DbSelectArea(cAliasOld)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_TOKDes บ Autor ณ Cibele Peria       บ Data ณ 25/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao das linhas das despesas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_TOKDes()
Local lRet    := .T.
Local cAlias  := ""
Local aCDes   := {}
Local nForArq := 0
Local nForDes := 0

For nForArq := 1 to len(aArqDesp)
	cAlias := aArqDesp[nForArq]
	aCDes  := aClone(&("o"+cAlias):aCols)
	
	For nForDes := 1 to len(aCDes)
		If !(lRet := HS_LOKDes(nForArq, nForDes, .F.))
			Exit
		Endif
	Next nForDes
	
	If !lRet
		If lG_Guia
			cMGlo := STR0056           //"Por favor, informe o motivo da glosa"
		Else
			cMGlo := STR0057           //"Por favor, informe o motivo da perda
		Endif
		cMGlo += STR0116 //" - Aba: "
		If nForArq == 1
			cMGlo += STR0044           //"Materiais/Medicamentos"
		ElseIf nForArq == 2
			cMGlo += STR0045           //"Taxas/Diarias"
		Else
			cMGlo += STR0032           //"Procedimentos"
		Endif
		cMGlo += STR0117 + aCDes[nForDes, &("n"+SUBSTR(cAlias,2)+"_SEQDES")] + ; //" - Seq.: "
		IIF(nForArq == 3, CHR(10) + STR0129 + HS_RDescrB("GF7_ORIDES", aCDes[nForDes, nF7_ORIDES]), "") //"Origem: "
		HS_MsgInf(cMGlo,STR0065,STR0103) //"Atencao" //"Validacao das linhas das despesas"
		Exit
	Endif
Next nForArq


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_LOKDes บ Autor ณ Cibele Peria       บ Data ณ 25/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da linha de despesa                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_LOKDes(nFolder, nPos, lMGlo, lTrava)
Local lRet     := .T.
Local cAlias   := aArqDesp[nFolder]
Local cPrefVar := "n" + Substr(cAlias, 2)
Local oObj     := &("o"+cAlias)

Default nPos   := oObj:oBrowse:nAt
Default lMGlo  := .T.
Default lTrava := .F.

If len(oObj:aCols) == 0
	Return(.T.)
Endif

If Empty(oObj:aCols[nPos, &(cPrefVar + "_CdMGlo")])
	If lG_Guia .and. oObj:aCols[nPos, &(cPrefVar + "_ValGlo")] > 0
		If lMGlo
			HS_MsgInf(STR0056,STR0065, STR0104) //"Por favor, informe o motivo da glosa","Atencao" //"Linha de despesa"
		Endif
		lRet := .F.
	ElseIf !lG_Guia .and. oObj:aCols[nPos, &(cPrefVar + "_ValPer")] > 0
		If lMGlo
			HS_MsgInf(STR0057,STR0065,STR0104) //"Por favor, informe o motivo da perda","Atencao" //"Linha de despesa"
		Endif
		lRet := .F.
	Endif
Endif

If !lRet .And. lTrava
	oObj:oBrowse:SetFocus()
	oFolder:nOption := nFolder
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_VlM381 บ Autor ณ Cibele Peria       บ Data ณ 25/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao dos campos da tabela GCZ                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VlM381()
Local cAliasOld := Alias()
Local nGuia     := oGCZ:nAt
Local lRet      := .T.
Local nFor      := 0
Local cAlias    := ""
Local cLetra    := ""
Local nDifPag   := 0, nDifGlo  := 0
Local nD_Pag    := 0, nD_Glo   := 0

IF GE0->GE0_STATUS == "2"
	HS_MsgInf(STR0100,STR0065,STR0105) //"Este extrato encontra-se conciliado. Detalhamento nao permitido!","Atencao" //"Validacao dos campos da tabela"
	Return(.F.)
Endif

nGuia      := oGCZ:nAt
If &(ReadVar()) < 0
	HS_MsgInf(STR0051,STR0065,STR0105) //"Valor invalido","Atencao" //"Validacao dos campos da tabela"
	Return(.F.)
Endif

If ReadVar() $ "M->GCZ_VALPAG/M->GCZ_VALGLO"
	
	If oGCZ:aCols[nGuia, nCZ_VlPagM] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlPagT] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlPagP] # 0 .or. ;
		oGCZ:aCols[nGuia, nCZ_VlGloM] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloT] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloP] # 0
		HS_MsgInf(STR0058,STR0065,STR0105) //"Esta conta ja foi detalhada ou os valores foram informados por totalizacao do grupo de despesa","Atencao" //"Validacao dos campos da tabela"
		Return(.F.)
	Endif
	
	If (ReadVar() == "M->GCZ_VALPAG" .and. 	(&(ReadVar()) == oGCZ:aCols[nGuia, nCZ_VlGuia] .or. (ReadVar() == "M->GCZ_VALGLO" .and. &(ReadVar()) == 0)))
		If !MsgYesNo(STR0059) //"O valor informado encerra a conta por quitacao. Confirma a atualizacao dos itens de despesa como quitados?"
			Return(.F.)
		Endif
	Endif
	
	If &(ReadVar()) == 0
		oGCZ:aCols[nGuia, nCZ_ValPag] := 0
		oGCZ:aCols[nGuia, nCZ_ValGlo] := 0
	ElseIf ReadVar() == "M->GCZ_VALPAG"
		oGCZ:aCols[nGuia, nCZ_ValPag] := M->GCZ_VALPAG
		oGCZ:aCols[nGuia, nCZ_ValGlo] := oGCZ:aCols[nGuia, nCZ_VlGuia] - M->GCZ_VALPAG
	Else
		oGCZ:aCols[nGuia, nCZ_ValGlo] := M->GCZ_VALGLO
		oGCZ:aCols[nGuia, nCZ_ValPag] := oGCZ:aCols[nGuia, nCZ_VlGuia] - M->GCZ_VALGLO
	Endif
	
	If oGCZ:aCols[nGuia, nCZ_ValPag] == oGCZ:aCols[nGuia, nCZ_VlGuia]
		MsgRun(STR0039,, {|| FS_PgGuia(nGuia) })   //"Atualizando conta(s) como paga(s). Aguarde..."
		If cAlias == "GF5"
			oGCZ:aCols[nGuia, nCZ_VlPagM] := nF5_VlTDes
			oGCZ:aCols[nGuia, nCZ_VlGloM] := 0
		ElseIf cAlias == "GF6"
			oGCZ:aCols[nGuia, nCZ_VlPagT] := nF6_VlTDes
			oGCZ:aCols[nGuia, nCZ_VlGloT] := 0
		ElseIf cAlias == "GF7"
			oGCZ:aCols[nGuia, nCZ_VlPagP] := nF7_VlTDes
			oGCZ:aCols[nGuia, nCZ_VlGloP] := 0
		Endif
		oGCZ:aCols[nGuia, nCZ_Status] := "7"  //Conta encerrada
	Else
		FS_CarVarD("GF5")
		FS_StaDes("GF5", IIF(oGCZ:aCols[nGuia, nCZ_ValPag] == 0 .and. oGCZ:aCols[nGuia, nCZ_ValGlo] == 0, "1", "6"))
		FS_CarVarD("GF6")
		FS_StaDes("GF6", IIF(oGCZ:aCols[nGuia, nCZ_ValPag] == 0 .and. oGCZ:aCols[nGuia, nCZ_ValGlo] == 0, "1", "6"))
		FS_CarVarD("GF7")
		FS_StaDes("GF7", IIF(oGCZ:aCols[nGuia, nCZ_ValPag] == 0 .and. oGCZ:aCols[nGuia, nCZ_ValGlo] == 0, "1", "6"))
	Endif
	
Else
	
	If oGCZ:aCols[nGuia, nCZ_VlPagM] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlPagT] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlPagP] == 0 .and. ;
		oGCZ:aCols[nGuia, nCZ_VlGloM] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlGloT] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlGloP] == 0 .and. ;
		(oGCZ:aCols[nGuia, nCZ_ValPag] # 0 .or. oGCZ:aCols[nGuia, nCZ_ValGlo] # 0)
		HS_MsgInf(STR0060,STR0065,STR0105) //"Os valores desta conta ja foram informados por totalizacao geral.","Atencao" //"Validacao dos campos da tabela"
		Return(.F.)
	Endif
	
	cLetra := SUBSTR(ReadVar(), len(ReadVar()))
	If cLetra == "M"      //Materiais e Medicamentos
		cAlias    := "GF5"
	ElseIf cLetra == "T"  //Taxas e Diarias
		cAlias    := "GF6"
	ElseIf cLetra == "P"  //Procedimentos e Honorarios
		cAlias    := "GF7"
	Endif
	nD_QtDDet := &("n"+SUBSTR(cAlias, 2)+"_QtDDet")
	nD_VlTDes := &("n"+SUBSTR(cAlias, 2)+"_VlTDes")
	
	If nD_QtDDet > 0
		HS_MsgInf(STR0061,STR0065,STR0105) //"Esta despesa ja foi detalhada!","Atencao" //"Validacao dos campos da tabela"
		Return(.F.)
	Endif
	
	If &(ReadVar()) > nD_VlTDes
		HS_MsgInf(STR0062,STR0065,STR0105) //"Valor informado maior que total das despesas","Atencao" //"Validacao dos campos da tabela"
		Return(.F.)
	Endif
	
	nD_Pag    := &("nCZ_VlPag"+cLetra)
	nD_Glo    := &("nCZ_VlGlo"+cLetra)
	If SUBSTR(ReadVar(), 8, 5) == "VLPAG"               //M->GCZ_VLPAGM
		nDifPag := &(ReadVar()) - oGCZ:aCols[nGuia, nD_Pag]
		If &(ReadVar()) == 0
			nDifGlo := oGCZ:aCols[nGuia, nD_Glo] * -1
			oGCZ:aCols[nGuia, nD_Glo] := 0
		Else
			nDifGlo := nD_VlTDes - &(ReadVar()) - oGCZ:aCols[nGuia, nD_Glo]
			oGCZ:aCols[nGuia, nD_Glo] := nD_VlTDes - &(ReadVar())
		Endif
		oGCZ:aCols[nGuia, nD_Pag] := &(ReadVar())
	Else
		nDifGlo := &(ReadVar()) - oGCZ:aCols[nGuia, nD_Glo]
		If &(ReadVar()) == 0
			nDifPag := oGCZ:aCols[nGuia, nD_Pag] * -1
			oGCZ:aCols[nGuia, nD_Pag] := 0
		Else
			nDifPag := nD_VlTDes - &(ReadVar()) - oGCZ:aCols[nGuia, nD_Pag]
			oGCZ:aCols[nGuia, nD_Pag] := nD_VlTDes - &(ReadVar())
		Endif
		oGCZ:aCols[nGuia, nD_Glo] := &(ReadVar())
	Endif
	
	oGCZ:aCols[nGuia, nCZ_ValPag] := oGCZ:aCols[nGuia, nCZ_VAlPag] + nDifPag
	oGCZ:aCols[nGuia, nCZ_ValGlo] := oGCZ:aCols[nGuia, nCZ_VAlGlo] + nDifGlo
	
	If oGCZ:aCols[nGuia, nD_Pag] == nD_VlTDes
		HS_MsgInf(STR0063,STR0065,STR0105) //"Este grupo de despesa foi totalmente pago. As despesas deste grupo serao quitadas.","Atencao" //"Validacao dos campos da tabela"
		FS_PgGuia(nGuia, {cAlias})
	Else
		FS_StaDes(cAlias, IIF(oGCZ:aCols[nGuia, nD_Pag] == 0 .and. oGCZ:aCols[nGuia, nD_Glo] == 0, "1", "6"))
	Endif
	
Endif

oGCZ:oBrowse:Refresh()
DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PgGuia บ Autor ณ Cibele Peria       บ Data ณ  09/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza valor pago das despesas da conta, todas as ainda  บฑฑ
ฑฑบ          ณ nao detalhadas, para totalmente pagas (Glosa = 0)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
 /*/
Static Function FS_PgGuia(nGuia, aArquivos, lFac, cPagGlo, cCdMGlo, cCdJGlo)
Local cAlias    := ""
Local nValPag   := 0
Local nValGlo   := 0
Local nForArq   := 0
Local nForPagar := 0
Local aCPag     := {}
Local cPrefVar  := ""

Default aArquivos := aClone(aArqDesp)
Default cPagGlo  := "P"
Default lFac   := .F.

If GE0->GE0_STATUS == "2"
	HS_MsgInf(STR0100,STR0065,STR0105) //"Este extrato encontra-se conciliado. Detalhamento nao permitido!","Atencao" //"Validacao dos campos da tabela"
	Return()
Endif

If !HS_LOKDes(oFolder:nOption)
	Return()
Endif

For nForArq := 1 to len(aArquivos)
	
	cAlias := aArquivos[nForArq]
	If Empty(cAlias)
		Loop
	Endif
	
	cPrefVar := "n"+Substr(cAlias, 2)
	aCPag := aClone(&("o"+cAlias):aCols)
	
	FS_CarVarD(cAlias)
	nValPag := 0
	nValGlo := 0
	
	If lG_Guia
		
		For nForPagar := 1 to len(aCPag)
			If aCPag[nForPagar, &(cPrefVar + "_ValPag")] == 0 .and. aCPag[nForPagar, &(cPrefVar + "_ValGlo")] == 0
				If cPagGlo == "P"
					aCPag[nForPagar, &(cPrefVar + "_ValPag")] := aCPag[nForPagar, &(cPrefVar + "_ValApr")]
					aCPag[nForPagar, &(cPrefVar + "_Status")] := "5" //Quitado
					nValPag += aCPag[nForPagar, &(cPrefVar + "_ValApr")]
				Else
					aCPag[nForPagar, &(cPrefVar + "_ValGlo")] := aCPag[nForPagar, &(cPrefVar + "_ValApr")]
					nValGlo += aCPag[nForPagar, &(cPrefVar + "_ValApr")]
					aCPag[nForPagar, &(cPrefVar + "_CdMGlo")] := cCdMGlo
					aCPag[nForPagar, &(cPrefVar + "_CdJGlo")] := cCdJGlo
					
					DbSelectArea("GDM")
					DbSetOrder(1)
					DbSeek(IIF(Empty(xFilial("GDM")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + cCdMGlo)
					aCPag[nForPagar, &(cPrefVar + "_DsMGlo")] := GDM->GDM_DESC
					If GDM->GDM_TIPO == "1"
						aCPag[nForPagar, &(cPrefVar + "_Status")] := "2"  //Disponivel para recurso
					Else
						aCPag[nForPagar, &(cPrefVar + "_Status")] := "4"  //Liquidado
					Endif
					
					DbSelectArea("GG9")
					DbSetOrder(1)
					DbSeek(IIF(Empty(xFilial("GG9")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + cCdJGlo)
					aCPag[nForPagar, &(cPrefVar + "_DsJGlo")] := GG9->GG9_DSJGLO
					
					
				Endif
				&("n"+SUBSTR(cAlias, 2)+"_QtDDet") += 1
				&("o"+cAlias):aCols := aClone(aCPag)
			Endif
		Next nForPagar
		If lFac
			FS_AcumDes(nGuia, cAlias, nValPag, nValGlo)
		Endif
		
	Else
		
		For nForPagar := 1 to len(aCPag)
			If aCPag[nForPagar, &(cPrefVar + "_ValRec")] == 0 .and. aCPag[nForPagar, &(cPrefVar + "_ValPer")] == 0
				If cPagGlo == "P"
					aCPag[nForPagar, &(cPrefVar + "_ValRec")] := aCPag[nForPagar, &(cPrefVar + "_ValGlo")]
					aCPag[nForPagar, &(cPrefVar + "_Status")] := "5"
					If lFac
						FS_AcumDes(nGuia, cAlias, aCPag[nForPagar, &(cPrefVar + "_ValGlo")], 0, aCPag[nForPagar, &(cPrefVar + "_NrReco")])
					Endif
					
				Else
					aCPag[nForPagar, &(cPrefVar + "_ValPer")] := aCPag[nForPagar, &(cPrefVar + "_ValGlo")]
					aCPag[nForPagar, &(cPrefVar + "_CdMGlo")] := cCdMGlo
					aCPag[nForPagar, &(cPrefVar + "_CdJGlo")] := cCdJGlo
					nValGlo += aCPag[nForPagar, &(cPrefVar + "_ValGlo")]
					
					DbSelectArea("GDM")
					DbSetOrder(1)
					DbSeek(IIF(Empty(xFilial("GDM")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + cCdMGlo)
					aCPag[nForPagar, &(cPrefVar + "_DsMGlo")] := GDM->GDM_DESC
					If GDM->GDM_TIPO == "1"
						aCPag[nForPagar, &(cPrefVar + "_Status")] := "2"  //Disponivel para recurso
					Else
						aCPag[nForPagar, &(cPrefVar + "_Status")] := "4"  //Liquidado
					Endif
					DbSelectArea("GG9")
					DbSetOrder(1)
					DbSeek(IIF(Empty(xFilial("GG9")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cG_FilAte) + cCdJGlo)
					aCPag[nForPagar, &(cPrefVar + "_DsJGlo")] := GG9->GG9_DSJGLO
					
					If lFac
						FS_AcumDes(nGuia, cAlias, 0, aCPag[nForPagar, &(cPrefVar + "_ValGlo")], aCPag[nForPagar, &(cPrefVar + "_NrReco")])
					Endif
					
				Endif
				&("n"+SUBSTR(cAlias, 2)+"_QtDDet") += 1
				&("o"+cAlias):aCols := aClone(aCPag)
			Endif
		Next nForPagar
		
	Endif
Next nForArq

oGCZ:oBrowse:Refresh()
oGF5:oBrowse:Refresh()
oGF6:oBrowse:Refresh()
oGF7:oBrowse:Refresh()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PAGART บ Autor ณ Cibele Peria       บ Data ณ  26/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza valor pago das despesas de todas as contas ainda  บฑฑ
ฑฑบ          ณ nao detalhadas, para totalmente pagas (Glosa = 0)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
 /*/
Static Function FS_PAGART(aArquivos)
Local nForGui   := 0
Local nForArq   := 0
Local cGuia     := 0
Local nPosGui   := 0
Local lG_Guia   := .F.

IF GE0->GE0_STATUS == "2"
	HS_MsgInf(STR0100,STR0065,STR0106) //"Este extrato encontra-se conciliado. Detalhamento nao permitido!"."Atencao" //"Atualiza valor pago das despesas"
	Return()
Endif

If !MsgYesNo(STR0068, STR0065) //"Confirma a atualizacao das despesas de todas as guias/recursos nao detalhadas como pagas?"###"Atencao"
	Return()
Endif

// Verifica se todas as GUIAS podem se pagas
For nForGui := 1 to len(oGCZ:aCols)
	cGuia   := oGCZ:aCols[nForGui, nCZ_NrSeqG]
	nPosGui   := aScan(aG_Guias, {| aVet | aVet[1] == cGuia})
	
	If !aG_Guias[nPosGui, 2]
		Loop
	Endif
	
	If FS_VldTGru(nForGui)[1]
		HS_MsgInf(STR0069 + cGuia + STR0070,STR0065,STR0106) //"Os valores recebimento/glosa da guia ("###") ja foram informados por totalizacao. Detalhamento nao permitido.","Atencao" //"Atualiza valor pago das despesas"
		Return()
	Endif
Next nForGui

//Pagamento de todas as contas.
MsgRun(STR0039,, {|| FS_PgTudo() }) //"Atualizando guia(s). Aguarde..."]
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PgTudo บ Autor ณ Cibele Peria       บ Data ณ  07/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualizacao do pagamento de todas as despesas de todas as  บฑฑ
ฑฑบ          ณ contas/recursos, ainda nao detalhados.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
 /*/
Static Function FS_PgTudo()
Local nGuia_Ant := oGCZ:nAt
Local nGuia     := 0
Local nForArq   := 0
Local aHTmp     := {}
Local aCTmp     := {}
Local nUTmp     := 0
Local cNrSeqG   := ""
Local cAlias    := ""
Local cPref     := ""
Local cAliasGE  := ""
Local cPrefGE   := ""
Local cFilAte   := ""
Local cFilGF    := ""

Local nGCZValPag := 0
Local nGCZVlPagM := 0
Local nGCZVlPagT := 0
Local nGCZVlPagP := 0
Local nGCZValRec := 0
Local nGCZVlRecM := 0
Local nGCZVlRecT := 0
Local nGCZVlRecP := 0
Local nQtDisc    := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza os temporarios, referente as despesas posicionadas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction
FS_Dtalhar()
For nForArq := 1 To Len(aTabTmp)
	DbSelectArea(aTabTmp[nForArq, 1])
	DbCloseArea()
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega todas as despesas da guia, ainda nao carregadas     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nGuia := 1 to Len(oGCZ:aCols)
	If !(oGCZ:aCols[nGuia, nCZ_Status] $ "5,7")
		Loop
	Endif
	
	cNrSeqG := oGCZ:aCols[nGuia, nCZ_NrSeqG]
	cFilAte := oGCZ:aCols[nGuia, nCZ_FilAte]
	
	nGCZValPag := 0
	nGCZVlPagM := 0
	nGCZVlPagT := 0
	nGCZVlPagP := 0
	nGCZValRec := 0
	nGCZVlRecM := 0
	nGCZVlRecT := 0
	nGCZVlRecP := 0
	
	For nForArq := 1 to Len(aArqDesp)
		cAlias    := aArqDesp[nForArq]
		cPref     := cAlias + "->" + PrefixoCpo(cAlias)
		cAliasGE := StrTran(cAlias, "GF", "GE")
		cPrefGE  := cAliasGE + "->" + PrefixoCpo(cAliasGE)
		cFilGF    := IIF(Empty(xFilial(cAlias)), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), IIf (xFilial(cAlias)<>cFilAte, GCZ->GCZ_FILFAT,cFilAte ))
		cFilGE    := IIF(Empty(xFilial(cAliasGE)),IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte)
		
		DbSelectArea(cAlias)
		DbSetOrder(3) //GF7_FILIAL + GF7_NREXTC + GF7_NRSEQG
		DbSeek(cFilGF + GE0->GE0_NUMEXT + cNrSeqG)
		While !Eof() .And. &(cPref + "_FILIAL") == cFilGF .And. &(cPref + "_NREXTC") == GE0->GE0_NUMEXT .And. &(cPref + "_NRSEQG") == cNrSeqG
			
			If &(cPref+"_STATUS") == "1"
				DbSelectArea(cAliasGE)
				DbSetOrder(1)
				DbSeek(cFilGE + &(	cPref+"_SEQDES"))
				
				If Empty(&(	cPref+"_NRRECO"))
					
					nGCZValPag += &(	cPref+"_VALAPR")
					If cAlias == "GF5"
						nGCZVlPagM += &(	cPref+"_VALAPR")
					ElseIf cAlias == "GF6"
						nGCZVlPagT += &(	cPref+"_VALAPR")
					ElseIf cAlias == "GF7"
						nGCZVlPagP += &(	cPref+"_VALAPR")
					Endif
					
					RecLock(cAlias, .F.)
					&(	cPref+"_VALPAG") := &(	cPref+"_VALAPR")
					&(	cPref+"_STATUS") := "5" //Quitado
					&(	cPref+"_DATSTA") := dDataBase
					&(	cPref+"_HORSTA") := Time()
					MsUnLock()
					
					RecLock(cAliasGE, .F.)
					If cAlias == "GF7" .And. &(	cPref+"_ORIDES") == "3" //Filme
						&(	cPrefGE+"_PAGFIL") += &(	cPref+"_VALAPR")
					Else
						&(	cPrefGE+"_VALPAG") += &(	cPref+"_VALAPR")
					EndIf
					&(	cPrefGE+"_STATUS") := "3" //Encerrado
					&(	cPrefGE+"_DATSTA") := dDataBase
					&(	cPrefGE+"_HORSTA") := Time()
					MsUnLock()
					
				Else
					
					nGCZValRec += &(	cPref+"_VALGLO")
					If cAlias == "GF5"
						nGCZVlRecM += &(	cPref+"_VALGLO")
					ElseIf cAlias == "GF6"
						nGCZVlRecT += &(	cPref+"_VALGLO")
					ElseIf cAlias == "GF7"
						nGCZVlRecP += &(	cPref+"_VALGLO")
					Endif
					
					DbSelectArea("GF0")
					DbSetOrder(3)
					DbSeek(xFilial("GF0") + GE0->GE0_NUMEXT + &(cPref+"_NRRECO")) //GF0_FILIAL + GF0_NREXTC + GF0_NUMREC
					Reclock("GF0", .F.)
					GF0->GF0_VALREC += &(	cPref+"_VALGLO")
					If cAlias == "GF5"
						GF0->GF0_VLRECM += &(	cPref+"_VALGLO")
					ElseIf cAlias == "GF6"
						GF0->GF0_VLRECT += &(	cPref+"_VALGLO")
					ElseIf cAlias == "GF7"
						GF0->GF0_VLRECP += &(	cPref+"_VALGLO")
					Endif
					GF0->GF0_STATUS := IIf(GF0->GF0_VALREC + GF0->GF0_VALPER == GF0->GF0_VLRECU, "3", "2")
					MsUnlock()
					
					RecLock(cAlias, .F.)
					&(	cPref+"_VALREC") += &(	cPref+"_VALGLO")
					&(	cPref+"_STATUS") := "5" //Quitado
					&(	cPref+"_DATSTA") := dDataBase
					&(	cPref+"_HORSTA") := Time()
					MsUnLock()
					
					RecLock(cAliasGE, .F.)
					If cAlias == "GF7" .And. &(	cPref+"_ORIDES") == "3" //Filme
						&(	cPrefGE+"_RECFIL") += &(	cPref+"_VALGLO")
					Else
						&(	cPrefGE+"_VALREC") += &(	cPref+"_VALGLO")
					EndIf
					&(	cPrefGE+"_STATUS") := "3" //Encerrado
					&(	cPrefGE+"_DATSTA") := dDataBase
					&(	cPrefGE+"_HORSTA") := Time()
					MsUnLock()
				Endif
				
			ElseIf !Empty(&(	cPref+"_CDMGLO"))
				If HS_IniPadR("GDM", 1, &(	cPref + "_CDMGLO"), "GDM_TIPO",, .F.,,  &(	cPref + "_FILATE")) == "1"
					nQtDisc += 1
				Endif
			Endif
			
			DbSelectArea(cAlias)
			DbSkip()
		End
		
	Next nForArq
	
	DbSelectArea("GCZ")
	DbSetOrder(1)
	DbSeek(IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte) + cNrSeqG)
	RecLock("GCZ", .F.)
	GCZ->GCZ_VALPAG += nGCZValPag
	GCZ->GCZ_VLPAGM += nGCZVlPagM
	GCZ->GCZ_VLPAGT += nGCZVlPagT
	GCZ->GCZ_VLPAGP += nGCZVlPagP
	GCZ->GCZ_VALREC += nGCZValRec
	GCZ->GCZ_VLRECM += nGCZVlRecM
	GCZ->GCZ_VLRECT += nGCZVlRecT
	GCZ->GCZ_VLRECP += nGCZVlRecP
	GCZ->GCZ_Status := IIf(nQtDisc == 0, "6", "7")
	MsUnLock()
	
	oGCZ:aCols[nGuia, nCZ_ValPag] := GCZ->GCZ_VALPAG
	oGCZ:aCols[nGuia, nCZ_VlPagM] := GCZ->GCZ_VLPAGM
	oGCZ:aCols[nGuia, nCZ_VlPagT] := GCZ->GCZ_VLPAGT
	oGCZ:aCols[nGuia, nCZ_VlPagP] := GCZ->GCZ_VLPAGP
	oGCZ:aCols[nGuia, nCZ_ValRec] := GCZ->GCZ_VALREC
	oGCZ:aCols[nGuia, nCZ_VlRecM] := GCZ->GCZ_VLRECM
	oGCZ:aCols[nGuia, nCZ_VlRecT] := GCZ->GCZ_VLRECT
	oGCZ:aCols[nGuia, nCZ_VlRecP] := GCZ->GCZ_VLRECP
	oGCZ:aCols[nGuia, nCZ_Status] := GCZ->GCZ_STATUS
	
Next nGuia

End Transaction

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Remonta a despesa original posicionada                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aTabTmp := {}
FS_InicGui(1) //Executar somente o passo 1 desta rotina
For nGuia := 1 to Len(aG_Guias)
	aG_Guias[nGuia][3] := .F.
	aG_Guias[nGuia][4] := {0, 0, 0}
	aG_Guias[nGuia][5] := {0, 0, 0}
Next nGuia
FS_MntDesp(nGuia_Ant, .T., .T.)
oGCZ:oBrowse:Refresh()
oGF5:oBrowse:Refresh()
oGF6:oBrowse:Refresh()
oGF7:oBrowse:Refresh()
Return()
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PagGlo บ Autor ณ Cibele Peria       บ Data ณ  22/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza valor glosado das despesas da guia, todas aquelas บฑฑ
ฑฑบ          ณ ainda nao detalhadas.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_PagGlo(nGuia, cTipo)
Local nIdGF5     	:= 0
Local nIdGF6     	:= 0
Local nIdGF7     	:= 0
Local cCdMGlo    	:= ""
Local cCdJGlo	  	:= ""
Local cPerg      	:= "HSM38"+cTipo
Local lCancelPer 	:= .T.
Local lValidaPer 	:= .F.
Local aArquivos		:= Array(3)
Local nForArq    	:= 0
Local nTamSx1		:= Len(SX1->X1_GRUPO)

If !HS_LOKDes(oFolder:nOption)
	Return()
Endif

IF GE0->GE0_STATUS == "2"
	HS_MsgInf(STR0100,STR0065,STR0107) //"Este extrato encontra-se conciliado. Detalhamento nao permitido!","Atencao" //"Atualiza valor glosado das despesas da guia"
	Return()
Endif

If cTipo == "G"
	cGDMTipo := "23" //fechada
EndIf
lCancelPer := !(Pergunte(cPerg,.T.))
While !lValidaPer
	If (lCancelPer)
		cGDMTipo := ""
		Exit
	Endif
	lValidaPer := HS_VlPFac(cTipo, nGuia)
End
If lCancelPer
	cGDMTipo := ""
	Return()
Endif

nIdGF5  := mv_par01
nIdGF6  := mv_par02
nIdGF7  := mv_par03
If cTipo == "G"
	cCdMGlo := mv_par04
	DbSelectArea("SX1")
	DbSetOrder(1)
	If DbSeek(Padr(cPerg, nTamSx1, "") + "05")
		cCdJGlo := mv_par05
	Else
		cCdJGlo := ""
	EndIf
Endif

If nIdGF5 == 1
	aArquivos[1] := "GF5"
Endif
If nIdGF6 == 1
	aArquivos[2] := "GF6"
Endif
If nIdGF7 == 1
	aArquivos[3] := "GF7"
Endif

For nForArq := 1 to len(aArquivos)
	
	cAlias := aArquivos[nForArq]
	If Empty(cAlias)
		Loop
	Endif
	
	If (lRet := FS_VldTGru(nGuia, cAlias)[1])
		HS_MsgInf(IIf(lG_Guia, STR0052, STR0066),STR0065,STR0107) //"Os valores recebimento/glosa para esta conta ja foram informados por totalizacao. Detalhamento nao permitido."###Os valores recuperado/perdido para este recurso ja foram informados por totalizacao. Detalhamento nao permitido.","Atencao" //"Atualiza valor glosado das despesas da guia"
		Return(.F.)
	Endif
	
Next nForArq

If !MsgYesNo(STR0095) //"Confirma a atualizacao das despesas nao detalhadas?"
	Return()
Endif

MsgRun(STR0039,, {|| FS_PGGuia(nGuia, aArquivos, .T., cTipo, cCdMGlo, cCdJGlo) }) //"Atualizando guia(s).Aguarde..."

cGDMTipo := ""
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DetGrp บ Autor ณ Daniel Peixoto     บ Data ณ  02/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDetalhamento das despesas do grupo                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DetGrp(nGuia)
Local nOpcA       := 0, nGDOpc := GD_UPDATE
Local aSize       := {}, aObjects := {}, aInfo := {}
Local cAlias      := "", cPref := ""
Local cCposDet    := "/_FILATE/_SEQDES/_CODDES/_DDESPE/_VALAPR/_VALPAG/_VALGLO/_STATUS"
Local cCond       := "GF5->GF5_NREXTC == '" + GE0->GE0_NUMEXT + "' .and. GF5->GF5_NRSEQG == '" + cG_NrSeqG + "' .And. GF5->GF5_FILATE == '" + cG_FilAte + "' " +;
" .and. GF5->GF5_STATUS == '6' " //Glosa p/ Grupo

Local oDlg, oFolder

Private oGF5DetG, oGF6DetG
Private aCGF5DetG := {}, aHGF5DetG := {}, nUGF5DetG := 0, nLenF5DetG := 0
Private aCGF6DetG := {}, aHGF6DetG := {}, nUGF6DetG := 0, nLenF6DetG := 0

If GE0->GE0_STATUS == "2"
	HS_MsgInf(STR0100,STR0065,STR0107) //"Este extrato encontra-se conciliado. Detalhamento nao permitido!","Atencao" //"Atualiza valor glosado das despesas da guia"
	Return(Nil)
Endif

If GE0->GE0_STATUS == "3"
	HS_MsgInf(STR0013,STR0065,STR0014) //"Extrato Liquidado. Alteracao nao permitida!","Atencao","Extrato"
	Return(Nil)
Endif

If lG_Guia .Or. !(FS_VldTGru(nGuia, "GF5", .T.)[1] .OR. FS_VldTGru(nGuia, "GF6", .T.)[1])
	HS_MsgInf(STR0132, STR0065, STR0133)  //"Op็ใo disponํvel apenas para Recurso que teve detalhamento por grupo."###"Valida็ใo do detalhamento do grupo"
	Return(.F.)
Endif

nLenF5DetG := HS_BDados("GF5", @aHGF5DetG, @aCGF5DetG, @nUGF5DetG, 3, .F., cCond, , ,STRTRAN(cCposDet, "/_", "/" + PrefixoCpo("GF5") + "_"), /*cElimina*/,,,,, .T.,,,,,,,,,,,, "GF5_FILATE")
aHGF5DetG[aScan(aHGF5DetG, {|aVet| aVet[2] == "GF5_VALPAG"}), 13] := ""
aHGF5DetG[aScan(aHGF5DetG, {|aVet| aVet[2] == "GF5_VALPAG"}),  6] := "HS_VldM38(.T.)"

aHGF5DetG[aScan(aHGF5DetG, {|aVet| aVet[2] == "GF5_VALGLO"}), 13] := ""
aHGF5DetG[aScan(aHGF5DetG, {|aVet| aVet[2] == "GF5_VALGLO"}),  6] := "HS_VldM38(.T.)"

cCond   := STRTRAN(cCond, "GF5", "GF6")
nLenF6DetG := HS_BDados("GF6", @aHGF6DetG, @aCGF6DetG, @nUGF6DetG, 3, .F., cCond, , ,STRTRAN(cCposDet, "/_", "/" + PrefixoCpo("GF6") + "_"), /*cElimina*/,,,,, .T.,,,,,,,,,,,, "GF6_FILATE")
aHGF6DetG[aScan(aHGF6DetG, {|aVet| aVet[2] == "GF6_VALPAG"}), 13] := ""
aHGF6DetG[aScan(aHGF6DetG, {|aVet| aVet[2] == "GF6_VALPAG"}),  6] := "HS_VldM38(.T.)"

aHGF6DetG[aScan(aHGF6DetG, {|aVet| aVet[2] == "GF6_VALGLO"}), 13] := ""
aHGF6DetG[aScan(aHGF6DetG, {|aVet| aVet[2] == "GF6_VALGLO"}),  6] := "HS_VldM38(.T.)"

If nLenF5DetG == 0 .And. nLenF6DetG == 0
	HS_MsgInf(STR0134, STR0065, STR0133)  //"Recurso jแ teve detalhamento das despesas do grupo."###"Valida็ใo do detalhamento do grupo"
	Return(.F.)
EndIf

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize(aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0135) From aSize[7], 200 to aSize[6] - 100, aSize[5] - 200	Of oMainWnd Pixel //"Detalhamento do Grupo"

@ aPObjs[1, 1], aPObjs[1, 2] FOLDER oFolder SIZE aPObjs[1, 3], aPObjs[1, 4]  OF oDlg PIXEL PROMPTS STR0044, STR0045 //"Materiais/Medicamentos"###"Taxas/Diarias"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

oGF5DetG := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,{"GF5_VALPAG", "GF5_VALGLO"}, , len(aCGF5DetG), , , , oFolder:aDialogs[1], aHGF5DetG, aCGF5DetG)
oGF5DetG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGF6DetG := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,{"GF6_VALPAG", "GF6_VALGLO"}, , len(aCGF6DetG), , , , oFolder:aDialogs[2], aHGF6DetG, aCGF6DetG)
oGF6DetG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oFolder:nOption := IIf(nLenF5DetG == 0, 2, 1)
oFolder:aDialogs[1]:lActive := nLenF5DetG > 0
oFolder:aDialogs[2]:lActive := nLenF6DetG > 0
oFolder:Refresh()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_VldOK(nGuia), oDlg:End(), NIL)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1
	Begin Transaction
	FS_AtuPGlo()
	
	FS_IncGFGr("GF5", oGCZ:aCols[nGuia, nCZ_NrSeqG], oGCZ:aCols[nGuia, nCZ_FilAte], {.F., 0, 0}, .T.)
	FS_IncGFGr("GF6", oGCZ:aCols[nGuia, nCZ_NrSeqG], oGCZ:aCols[nGuia, nCZ_FilAte], {.F., 0, 0}, .T.)
	
	FS_MntDesp(nGuia,,, .T.)
	End Transaction
Endif

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VlPFac บ Autor ณ Cibele Peria       บ Data ณ  23/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao das perguntas dos facilitadores de pagto e glosa บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VlPFac(cTipo, nGuia) //cTipo == "P", consiste Pagamento   cTipo == "G", consiste Glosa
Local lRet := .T., cAliasOld := Alias()

If mv_par01 == 2 .and. mv_par02 == 2 .and. mv_par03 == 2
	HS_MsgInf(STR0098,STR0065,STR0108) //"Informe pelo menos um grupo de despesas para se efetuar o processamento!","Atencao" //"Validacao das Perguntas dos facilitadores de pagto/glosa"
	lRet := .F.
	
ElseIf cTipo == "G"
	If Empty(mv_par04)
		HS_MsgInf(STR0056,STR0065,STR0108) //"Por favor, informe o motivo da glosa","Atencao" //"Validacao das Perguntas dos facilitadores de pagto/glosa"
		lRet := .F.
		
	Else
		DbSelectArea("GDM")
		DbSetOrder(1)
		If !DbSeek(IIF(Empty(xFilial("GDM")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), oGCZ:aCols[nGuia, nCZ_FILATE]) + mv_par04)
			HS_MsgInf(STR0049,STR0065,STR0108) //"Codigo informado invalido ou nao cadastrado","Atencao" //"Validacao das Perguntas dos facilitadores de pagto/glosa"
			lRet := .F.
		Endif
	Endif
Endif

DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AcumDesบ Autor ณ Cibele Peria       บ Data ณ  09/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Acumular despesa detalhada nos totais por grupo e geral    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AcumDes(nGuia, cAlias, nDifPag, nDifGlo, cNrReco, lFac)
Local lVldDesp := .T.

Default lFac := .F.

If lG_Guia
	
	oGCZ:aCols[nGuia, nCZ_ValPag] := oGCZ:aCols[nGuia, nCZ_VAlPag] + nDifPag
	oGCZ:aCols[nGuia, nCZ_ValGlo] := oGCZ:aCols[nGuia, nCZ_VAlGlo] + nDifGlo
	If cAlias == "GF5"
		oGCZ:aCols[nGuia, nCZ_VlPagM] := oGCZ:aCols[nGuia, nCZ_VlPagM] + nDifPag
		oGCZ:aCols[nGuia, nCZ_VlGloM] := oGCZ:aCols[nGuia, nCZ_VlGloM] + nDifGlo
	ElseIf cAlias == "GF6"
		oGCZ:aCols[nGuia, nCZ_VlPagT] := oGCZ:aCols[nGuia, nCZ_VlPagT] + nDifPag
		oGCZ:aCols[nGuia, nCZ_VlGloT] := oGCZ:aCols[nGuia, nCZ_VlGloT] + nDifGlo
	ElseIf cAlias == "GF7"
		oGCZ:aCols[nGuia, nCZ_VlPagP] := oGCZ:aCols[nGuia, nCZ_VlPagP] + nDifPag
		oGCZ:aCols[nGuia, nCZ_VlGloP] := oGCZ:aCols[nGuia, nCZ_VlGloP] + nDifGlo
	Endif
	
Else
	DbSelectArea("GF0REC")
	DbSetOrder(1)
	If (lVldDesp := DbSeek(cNrReco))
		Reclock("GF0REC", .F.)
		GF0REC->VALREC += nDifPag
		GF0REC->VALPER += nDifGlo
		If cAlias == "GF5"
			GF0REC->VLRECM += nDifPag
			GF0REC->VLPERM += nDifGlo
		ElseIf cAlias == "GF6"
			GF0REC->VLRECT += nDifPag
			GF0REC->VLPERT += nDifGlo
		ElseIf cAlias == "GF7"
			GF0REC->VLRECP += nDifPag
			GF0REC->VLPERP += nDifGlo
		Endif
		
		If GF0REC->VALREC + GF0REC->VALPER == GF0REC->VLRECU
			If GF0REC->STATUS <> "3"
				GF0REC->STATUS := "3"
			Endif
		ElseIf GF0REC->STATUS == "3"
			GF0REC->VALREC := "2"
		Endif
		MsUnlock()
		
		oGCZ:aCols[nGuia, nCZ_ValRec] := oGCZ:aCols[nGuia, nCZ_ValRec] + nDifPag
		oGCZ:aCols[nGuia, nCZ_ValPer] := oGCZ:aCols[nGuia, nCZ_ValPer] + nDifGlo
		If cAlias == "GF5"
			oGCZ:aCols[nGuia, nCZ_VlRecM] := oGCZ:aCols[nGuia, nCZ_VlRecM] + nDifPag
			oGCZ:aCols[nGuia, nCZ_VlPerM] := oGCZ:aCols[nGuia, nCZ_VlPerM] + nDifGlo
		ElseIf cAlias == "GF6"
			oGCZ:aCols[nGuia, nCZ_VlRecT] := oGCZ:aCols[nGuia, nCZ_VlRecT] + nDifPag
			oGCZ:aCols[nGuia, nCZ_VlPerT] := oGCZ:aCols[nGuia, nCZ_VlPerT] + nDifGlo
		ElseIf cAlias == "GF7"
			oGCZ:aCols[nGuia, nCZ_VlRecP] := oGCZ:aCols[nGuia, nCZ_VlRecP] + nDifPag
			oGCZ:aCols[nGuia, nCZ_VlPerP] := oGCZ:aCols[nGuia, nCZ_VlPerP] + nDifGlo
		Endif
	EndIf
Endif

If lG_Guia
	If oGCZ:aCols[nGuia, nCZ_ValPag] + oGCZ:aCols[nGuia, nCZ_ValGlo] == oGCZ:aCols[nGuia, nCZ_VlGuia]
		If !lFac .and. !oGCZ:aCols[nGuia, nCZ_Status] $ "6/7"
			HS_MsgInf(STR0072,STR0065,STR0109) //"Esta guia sera encerrada devido ao detalhamento de todos os itens de despesa.","Atencao" //"Acumular despesa detalhada nos totais"
		Endif
		If oGCZ:aCols[nGuia, nCZ_ValPag] == oGCZ:aCols[nGuia, nCZ_VlGuia]
			oGCZ:aCols[nGuia, nCZ_Status] := "7"
		ElseIf FS_QtGDis(nGuia) == 0 //Se todas as glosas foram motivo fechado, liquida o extrato
			oGCZ:aCols[nGuia, nCZ_Status] := "6"
		EndIf
	Else
		oGCZ:aCols[nGuia, nCZ_Status] := "5"
	Endif
	
ElseIf !lG_Guia .And. lVldDesp
	If oGCZ:aCols[nGuia, nCZ_ValRec] + oGCZ:aCols[nGuia, nCZ_ValPer] == oGCZ:aCols[nGuia, nCZ_ValGlo]
		If !lFac .and. !oGCZ:aCols[nGuia, nCZ_Status] $ "6/7"
			HS_MsgInf(STR0072,STR0065,STR0109) //"Esta guia sera encerrada devido ao detalhamento de todos os itens de despesa.","Atencao" //"Acumular despesa detalhada nos totais"
		Endif
		If oGCZ:aCols[nGuia, nCZ_ValRec] == oGCZ:aCols[nGuia, nCZ_ValGlo]
			oGCZ:aCols[nGuia, nCZ_Status] := "7"
		ElseIf FS_QtGDis(nGuia) == 0 //Se todas as glosas foram motivo fechado, liquida o extrato
			oGCZ:aCols[nGuia, nCZ_Status] := "6"
		EndIf
	Else
		oGCZ:aCols[nGuia, nCZ_Status] := "5"
	Endif
Endif

oGCZ:oBrowse:Refresh()

Return()
                     
Static Function FS_QtGDis(nGuia)
Local aAreaOld := GetArea()
Local nQtDisc  := 0
Local nForArq  := 0
Local nForCol  := 0
Local cAlias   := ""
Local aColsA   := {}
Local cPrefVar := ""

For nForArq := 1 to len(aArqDesp)
	cAlias   := aArqDesp[nForArq]
	cPrefVar := "n" + Substr(cAlias, 2)
	aColsA   := aClone(&("o"+cAlias):aCols)
	FS_CarVarD(cAlias)
	
	For nForCol := 1 to len(aColsA)
		If !Empty(aColsA[nForCol, &(cPrefVar + "_CdMGlo")])
			If HS_IniPadR("GDM", 1, aColsA[nForCol, &(cPrefVar + "_CdMGlo")], "GDM_TIPO",, .F.,, oGCZ:aCols[nGuia, nCZ_FILATE]) == "1"
				nQtDisc += 1
			Endif
		Endif
	Next nForCol
	
Next nForArq

RestArea(aAreaOld)

Return(nQtDisc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldTGruบ Autor ณ Cibele Peria       บ Data ณ  09/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se houve totalizacao geral ou por grupo           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldTGru(nGuia, cAlias, lDetGrp)
Local aRet := {.F., 0, 0}
Local lVerGF	:= .F.
Local nLDesp	:= 0

Default lDetGrp := .F.
Default cAlias  := ""


If "F5" $ cAlias .OR. "F6" $ cAlias
	For nLDesp := 1 to Len(oGF5:aCols)
		If (oGF5:aCols[nLDesp,nF5_ValPag] # 0 .OR. oGF5:aCols[nLDesp,nF5_ValGlo] # 0 .or. (oGCZ:aCols[nGuia, nCZ_VlPagM] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloM] # 0))
			lVerGF  := .T.
		EndIf
	Next nLDesp
	For nLDesp := 1 to Len(oGF6:aCols)
		If (oGF6:aCols[nLDesp,nF6_ValPag] # 0 .OR. oGF6:aCols[nLDesp,nF6_ValGlo] # 0 .or. (oGCZ:aCols[nGuia, nCZ_VlPagT] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloT] # 0))
			lVerGF  := .T.
		EndIf
	Next nLDesp
EndIf

If lG_Guia .Or. lDetGrp
	
	If nF5_QtDDet == 0 .and. nF6_QtDDet == 0 .and. nF7_QtDDet == 0 .and. ;
		oGCZ:aCols[nGuia, nCZ_VlPagM] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlGloM] == 0 .and. ;
		oGCZ:aCols[nGuia, nCZ_VlPagT] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlGloT] == 0 .and. ;
		oGCZ:aCols[nGuia, nCZ_VlPagP] == 0 .and. oGCZ:aCols[nGuia, nCZ_VlGloP] == 0 .and. ;
		(oGCZ:aCols[nGuia, nCZ_ValPag] # 0 .or. oGCZ:aCols[nGuia, nCZ_ValGlo] # 0)
		aRet := {.T., oGCZ:aCols[nGuia, nCZ_ValPag], oGCZ:aCols[nGuia, nCZ_ValGlo]}
	ElseIf cAlias == "GF5" .and. nF5_QtDDet == 0 .and. (oGCZ:aCols[nGuia, nCZ_VlPagM] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloM] # 0) .AND. !lVerGF
		aRet := {.T., oGCZ:aCols[nGuia, nCZ_VlPagM], oGCZ:aCols[nGuia, nCZ_VlGloM]}
	ElseIf	cAlias == "GF6" .and. nF6_QtDDet == 0 .and. (oGCZ:aCols[nGuia, nCZ_VlPagT] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloT] # 0) .AND. !lVerGF
		aRet := {.T., oGCZ:aCols[nGuia, nCZ_VlPagT], oGCZ:aCols[nGuia, nCZ_VlGloT]}
	ElseIf	cAlias == "GF7" .and. nF7_QtDDet == 0 .and. (oGCZ:aCols[nGuia, nCZ_VlPagP] # 0 .or. oGCZ:aCols[nGuia, nCZ_VlGloP] # 0)
		aRet := {.T., oGCZ:aCols[nGuia, nCZ_VlPagP], oGCZ:aCols[nGuia, nCZ_VlGloP]}
	Endif
	
Endif

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_StaDes บ Autor ณ Cibele Peria       บ Data ณ 14/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza todos os status de um grupo de despesa            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_StaDes(cAlias, cStatus)
Local nForAC   := 0
Local cObj     := "o"+cAlias
Local cPrefVar := "n"+Substr(cAlias, 2)

For nForAC := 1 to len(&(cObj):aCols)
	&(cObj):aCols[nForAC, &(cPrefVar + "_Status")] := cStatus
Next nForAC

&(cObj):oBrowse:Refresh()

Return()
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_Dtalharบ Autor ณ Cibele Peria       บ Data ณ 09/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualizar os aquivos GF5/6/7 a partir do detalhamento      บฑฑ
ฑฑบ          ณ efetuado nos arquivos temporarios                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Dtalhar()
Local cAliasOld := Alias()
Local nForArq   := 0
Local nForAC    := 0
Local nVlRGlo   := 0
Local nVlRRec   := 0
Local cNrSeqG   := "", cFilAte := ""

Private cAlias    := "", cPref    := "", cAliasTmp := "", nOrdGF := 0
Private cAliasOri := "", cPrefOri := ""

FS_AtuTemp()

DbSelectArea("GCZ")
DbSetOrder(1)
For nForAC := 1 to nLenGCZ
	If DbSeek(IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), oGCZ:aCols[nForAC, nCZ_FilAte]) + oGCZ:aCols[nForAC, nCZ_NrSeqG])
		AADD(aGReap, {oGCZ:aCols[nForAC, nCZ_NrSeqG], GCZ->GCZ_CODCON})
		RecLock("GCZ", .F.)
		If	GCZ->GCZ_VALPAG <> oGCZ:aCols[nForAC, nCZ_ValPag] .or. GCZ->GCZ_VALGLO <> oGCZ:aCols[nForAC, nCZ_ValGlo] .or. ;
			GCZ->GCZ_VLPAGM <> oGCZ:aCols[nForAC, nCZ_VlPagM] .or. GCZ->GCZ_VLGLOM <> oGCZ:aCols[nForAC, nCZ_VlGloM] .or. ;
			GCZ->GCZ_VLPAGT <> oGCZ:aCols[nForAC, nCZ_VlPagT] .or.	GCZ->GCZ_VLGLOT <> oGCZ:aCols[nForAC, nCZ_VlGloT] .or. ;
			GCZ->GCZ_VLPAGP <> oGCZ:aCols[nForAC, nCZ_VlPagP] .or.	GCZ->GCZ_VLGLOP <> oGCZ:aCols[nForAC, nCZ_VlGloP] .or. ;
			GCZ->GCZ_VALREC <> oGCZ:aCols[nForAC, nCZ_ValRec] .or.	GCZ->GCZ_VALPER <> oGCZ:aCols[nForAC, nCZ_ValPer] .or. ;
			GCZ->GCZ_VLRECM <> oGCZ:aCols[nForAC, nCZ_VlRecM] .or.	GCZ->GCZ_VLPERM <> oGCZ:aCols[nForAC, nCZ_VlPerM] .or. ;
			GCZ->GCZ_VLRECT <> oGCZ:aCols[nForAC, nCZ_VlRecT] .or.	GCZ->GCZ_VLPERT <> oGCZ:aCols[nForAC, nCZ_VlPerT] .or. ;
			GCZ->GCZ_VLRECP <> oGCZ:aCols[nForAC, nCZ_VlRecP] .or.	GCZ->GCZ_VLPERP <> oGCZ:aCols[nForAC, nCZ_VlPerP]
			GCZ->GCZ_VALPAG := oGCZ:aCols[nForAC, nCZ_ValPag]
			GCZ->GCZ_VALGLO := oGCZ:aCols[nForAC, nCZ_ValGlo]
			GCZ->GCZ_VLPAGM := oGCZ:aCols[nForAC, nCZ_VlPagM]
			GCZ->GCZ_VLGLOM := oGCZ:aCols[nForAC, nCZ_VlGloM]
			GCZ->GCZ_VLPAGT := oGCZ:aCols[nForAC, nCZ_VlPagT]
			GCZ->GCZ_VLGLOT := oGCZ:aCols[nForAC, nCZ_VlGloT]
			GCZ->GCZ_VLPAGP := oGCZ:aCols[nForAC, nCZ_VlPagP]
			GCZ->GCZ_VLGLOP := oGCZ:aCols[nForAC, nCZ_VlGloP]
			GCZ->GCZ_VALREC := oGCZ:aCols[nForAC, nCZ_ValRec]
			GCZ->GCZ_VALPER := oGCZ:aCols[nForAC, nCZ_ValPer]
			GCZ->GCZ_VLRECM := oGCZ:aCols[nForAC, nCZ_VlRecM]
			GCZ->GCZ_VLPERM := oGCZ:aCols[nForAC, nCZ_VlPerM]
			GCZ->GCZ_VLRECT := oGCZ:aCols[nForAC, nCZ_VlRecT]
			GCZ->GCZ_VLPERT := oGCZ:aCols[nForAC, nCZ_VlPerT]
			GCZ->GCZ_VLRECP := oGCZ:aCols[nForAC, nCZ_VlRecP]
			GCZ->GCZ_VLPERP := oGCZ:aCols[nForAC, nCZ_VlPerP]
			GCZ->GCZ_LOGARQ := HS_LogArq()
			GCZ->GCZ_DATSTA := dDataBase
		Endif
		If GCZ->GCZ_STATUS <> oGCZ:aCols[nForAC, nCZ_Status]
			GCZ->GCZ_STATUS := oGCZ:aCols[nForAC, nCZ_Status]
			GCZ->GCZ_LOGARQ := HS_LogArq()
			GCZ->GCZ_DATSTA := dDataBase
		Endif
		MsUnlock()
		
		//Tratamento da despesas gerada por Detalhamento no Grupo
		FS_IncGFGr("GF5", oGCZ:aCols[nForAC, nCZ_NrSeqG], oGCZ:aCols[nForAC, nCZ_FilAte], FS_VldTGru(nForAC, "GF5"))
		FS_IncGFGr("GF6", oGCZ:aCols[nForAC, nCZ_NrSeqG], oGCZ:aCols[nForAC, nCZ_FilAte], FS_VldTGru(nForAC, "GF6"))
	EndIf
Next nForAC

DbSelectArea("GF0REC")
DbSetOrder(1)
DbGoTop()
While !Eof()
	DbSelectArea("GF0")
	DbGoTo(GF0REC->RECNO)
	If	GF0->GF0_VALREC <> 	GF0REC->VALREC .or. GF0->GF0_VALPER <>GF0REC->VALPER .or. ;
		GF0->GF0_VLRECM <> GF0REC->VLRECM .or. GF0->GF0_VLPERM <> GF0REC->VLPERM .or. ;
		GF0->GF0_VLRECT <> GF0REC->VLRECT .or. GF0->GF0_VLPERT <> GF0REC->VLPERT .or. ;
		GF0->GF0_VLRECP <> GF0REC->VLRECP .or. GF0->GF0_VLPERP <> GF0REC->VLPERP
		RecLock("GF0", .F.)
		GF0->GF0_VALREC := 	GF0REC->VALREC
		GF0->GF0_VALPER := GF0REC->VALPER
		GF0->GF0_VLRECM := GF0REC->VLRECM
		GF0->GF0_VLPERM := GF0REC->VLPERM
		GF0->GF0_VLRECT := GF0REC->VLRECT
		GF0->GF0_VLPERT := GF0REC->VLPERT
		GF0->GF0_VLRECP := GF0REC->VLRECP
		GF0->GF0_VLPERP := GF0REC->VLPERP
		MsUnlock()
	Endif
	DbSelectArea("GF0REC")
	DbSkip()
End

For nForArq := 1 to len(aArqDesp)
	cAlias    := aArqDesp[nForArq]
	cPref     := cAlias + "->" + PrefixoCpo(cAlias)
	nOrdGF    := IIF(lFilFat , IIF(cAlias == "GF7", 9, 8), IIF(cAlias == "GF7", 8, 1))
	
	cAliasOri := STRTRAN(cAlias, "F", "E")
	cPrefOri  := cAliasOri + "->" + PrefixoCpo(cAliasOri)
	cAliasTmp := cAlias + "TMP"
	
	cNrSeqG := ""
	cFilAte := ""
	DbSelectArea(cAliasTmp)
	DbSetOrder(1)
	DbGoTop()
	While !Eof()
		If !Empty(&(cAliasTmp + "->SEQDES")) //Nao e por Grupo
			
			If &(cAliasTmp + "->FILATE") <> cFilAte .Or. &(cAliasTmp + "->NRSEQG") <> cNrSeqG
				cFilAte := &(cAliasTmp + "->FILATE")
				cNrSeqG := &(cAliasTmp + "->NRSEQG")
				lG_Guia := aG_Guias[aScan(aG_Guias, {| aVet | aVet[1] == cNrSeqG .And. aVet[6] == cFilAte}), 2]
			Endif
			
			cFilGF    := IIF(lFilFat, cFilAte, xFilial(cAlias))
			cFilGE    := IIF(lFilFat, cFilAte, xFilial(cAlias))
			
			DbSelectArea(cAlias)
			DbSetOrder(nOrdGF)
			If DbSeek(cFilGF + GE0->GE0_NUMEXT + &(cAliasTmp + "->SEQDES") + IIF(cAlias == "GF7", &(cAliasTmp + "->ORIDES"), "") )
				RecLock(cAlias, .F.)
				If lG_Guia
					&(cPref + "_VALPAG") := &(cAliasTmp + "->VALPAG")
					&(cPref + "_VALGLO") := &(cAliasTmp + "->VALGLO")
					If HS_ExisDic({{"C",PrefixoCpo(cAlias) + "_VLRGLO"}},.F.)
						nVlRGlo := FS_CalRepM(cAliasOri, &(cAliasTmp + "->VALGLO"), &(cAliasTmp + "->VALAPR"), &(cAliasTmp + "->SEQDES"), IIF(cAlias == "GF7",&(cAliasTmp + "->ORIDES"),""), cFilGE)
						&(cPref + "_VLRGLO") := nVlRGlo
					EndIF
				Else
					&(cPref + "_VALREC") := &(cAliasTmp + "->VALREC")
					&(cPref + "_VALPER") := &(cAliasTmp + "->VALPER")
					If HS_ExisDic({{"C",PrefixoCpo(cAlias) + "_VLRREC"}},.F.)
						nVlRRec := FS_CalRepM(cAliasOri, &(cAliasTmp + "->VALREC"), &(cAliasTmp + "->VALAPR"), &(cAliasTmp + "->SEQDES"), IIF(cAlias == "GF7",&(cAliasTmp + "->ORIDES"),""), cFilGE)
						&(cPref + "_VLRREC") := nVlRRec
					EndIf
				Endif
				&(cPref + "_CDMGLO") := &(cAliasTmp + "->CDMGLO")
				&(cPref + "_CDJGLO") := &(cAliasTmp + "->CDJGLO")
				&(cPref + "_COMJGL") := &(cAliasTmp + "->COMJGL")
				&(cPref + "_STATUS") := &(cAliasTmp + "->STATUS")
				&(cPref + "_DATSTA") := dDataBase
				&(cPref + "_HORSTA") := Time()
				MsUnlock()
			EndIf
			
			DbSelectArea(cAliasOri)
			DbSetOrder(1)
			If DbSeek(cFilGE + &(cAliasTmp + "->SEQDES"))
				RecLock(cAliasOri, .F.)
				If &("Empty("+cAliasTmp + "->NRRECO)")
					If cAliasOri == "GE7" .And.  &(	cPref+"_ORIDES") == "3" //Filme
						&(cPrefOri + "_PAGFIL") := &(cAliasTmp + "->VALPAG")
						&(cPrefOri + "_GLOFIL") := &(cAliasTmp + "->VALGLO")
						&(cPrefOri + "_VLRGLO") += nVlRGlo
					Else
						&(cPrefOri + "_VALPAG") := &(cAliasTmp + "->VALPAG")
						&(cPrefOri + "_VALGLO") := &(cAliasTmp + "->VALGLO")
						If HS_ExisDic({{"C",PrefixoCpo(cAliasOri) + "_VLRGLO"}},.F.)
							&(cPrefOri + "_VLRGLO") := nVlRGlo
						EndIf
					EndIf
				Else
					If cAliasOri == "GE7" .And. &(	cPref+"_ORIDES") == "3" //Filme
						&(cPrefOri + "_RECFIL") := &(cPrefOri + "_GLOFIL") - &(cAliasTmp + "->VALPER")
						&(cPrefOri + "_PERFIL") := &(cAliasTmp + "->VALPER")
						&(cPrefOri + "_VLRREC") += nVlRRec
					Else
						&(cPrefOri + "_VALREC") := &(cPrefOri + "_VALGLO") - &(cAliasTmp + "->VALPER")
						&(cPrefOri + "_VALPER") := &(cAliasTmp + "->VALPER")
						If HS_ExisDic({{"C",PrefixoCpo(cAliasOri) + "_VALREC"}},.F.)
							&(cPrefOri + "_VLRREC") := nVlRRec
						EndIf
					EndIf
				Endif
				If &(cAliasTmp + "->STATUS") == "4"       //Liquidado
					&(cPrefOri + "_STATUS") := "2"
				ElseIf &(cAliasTmp + "->STATUS") == "5"   //Quitado
					&(cPrefOri + "_STATUS") := "3"
				Else
					&(cPrefOri + "_STATUS") := "1"
				Endif
				&(cPrefOri + "_DATSTA") := dDataBase
				&(cPrefOri + "_HORSTA") := Time()
				MsUnlock()
			EndIf
			
		EndIf
		
		DbSelectArea(cAliasTmp)
		DbSkip()
	End
Next nForArq

DbSelectArea(cAliasOld)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_CalRepMบ Autor ณ Cibele Peria       บ Data ณ 05/05/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula o valor do repasse do medico, para o caso de pro-  บฑฑ
ฑฑบ          ณ cedimentos                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CalRepM(cAlias, nValGloRec, nValApr, nSeqDes, cOriDes, cFilGE)
Local aArea   := GetArea()
Local nVlrMed := 0, nValMed := 0
Local nPerc   := IIF(cOriDes == "3", 1, nValGloRec / nValApr)  //3=Filme -> Repasse 100%
Local cPref   := cAlias+"->"+cAlias

DbSelectArea(cAlias)
DbSetOrder(1) //FILIAL + SEQDES
DbSeek(cFilGE + nSeqDes)

If cOriDes == "3" //Filme e Recebe Repasse Filme
	nValMed := IIF(&(cPref + "_VLREPF") > 0, nValGloRec, 0)
Else
	If HS_ExisDic({{"C", cAlias + "_VALREP"}}, .F.)
		nValMed := &(cPref + "_VALREP") - IIF(cAlias == "GE7", &(cPref + "_VLREPF"), 0)
	EndIf
EndIf

If &(cPref+"_PGTMED") <> "0" //Direto
	nVlrMed := nValMed * nPerc
EndIf

RestArea(aArea)
Return(nVlrMed)

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_M38Conบ Autor ณ Cibele Peria       บ Data ณ 17/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Conciliar                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Con(cAlias, nReg, nOpc)
Local Alias   := Alias()
Local nTtConA := 0, nVlConA := 0, nVlGloA := 0
Local nOpcA   := 0, oDlgC
Local cFilGCZ := IIF(lFilFat, cFilAnt, xFilial("GCZ"))
Local cSql    := ""
Local lTab    := .F.
Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

If GE0->GE0_STATUS == "2"
	HS_MsgInf(STR0074,STR0065,STR0110) //"Este extrato ja esta conciliado","Atencao" //"Funcao Conciliar"
	Return()
ElseIf GE0->GE0_STATUS == "3"
	HS_MsgInf(STR0075,STR0065,STR0110) //"Este extrato esta encerrado","Atencao" //"Funcao Conciliar"
	Return()
ElseIf !FS_VlConci(GE0->GE0_NUMEXT)
	HS_MsgInf(STR0126, STR0065, STR0111)  //"Hแ despesas sem detalhar. A opera็ใo Conciliar nใo pode ser efetuada."###"Aten็ใo"###"Valida็ใo da rotina de concilia็ใo"
	Return(Nil)
Endif

DbSelectArea("GCZ")
DbSetOrder(IIF(lFilFat, 25, 5))
DbSeek(cFilGCZ + GE0->GE0_NUMEXT)
While !Eof() .and. GCZ->GCZ_NREXTC == GE0->GE0_NUMEXT
	nTtConA += 1
	nVlConA += GCZ->GCZ_VLGUIA
	nVlGloA += GCZ->GCZ_VALGLO
	DbSkip()
End

DbSelectArea("GF0")
DbSetOrder(3)
IF DbSeek(xFilial("GF0") + GE0->GE0_NUMEXT)
	lTab    := .T.
	While !Eof() .and. GF0->GF0_NREXTC == GE0->GE0_NUMEXT
		nVlConA += GF0->GF0_VALREC + GF0->GF0_VALPER
		nVlGloA += GF0->GF0_VALPER
		DbSkip()
	End
	
	aTabTmp := {}
	aG_Guias  := {}
	aArqDesp := {"GF5", "GF6", "GF7"}
	If !Empty(cCond := FS_InicGui(2))
		cSql  := "SELECT Count(GCZ_NRSEQG) NGUIA "
		cSql  += "FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.D_E_L_E_T_ <> '*' AND "
		cSql  += cCond
		cSql  := ChangeQuery(cSql)
		
		TCQuery cSql New Alias "QGU"
		DbSelectArea("QGU")
		While !Eof()
			nTtConA := nGuia
			DbSkip()
		End
		DbCloseArea()
	EndIf
Else
	lTab    := .F.
EndIf

DbSelectArea("GE0")
RecLock("GE0", .F.)
GE0->GE0_TTCONA := nTtConA
GE0->GE0_VLCONA := nVlConA
GE0->GE0_VLGLOA := nVlGloA
MsUnlock()

nOpcA := 0
DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0009) From aSize[ 7 ],000 to  aSize[ 6 ] / 2 , aSize[ 5 ] / 2  Of oMainWnd Pixel  //"Conciliar"

Enchoice(cAlias, nReg, 2,,,,, {aPObjs[1,1], aPObjs[1,2], aPObjs[1,3], aPObjs[1,4]},,,,,)

ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC, {|| nOpcA := 1, IIF(HS_VldConc(), oDlgC:End(), nOpcA := 0)}, ;
{|| nOpcA := 0, oDlgC:End()})

If nOpcA == 1
	DbSelectArea("GE0")
	RecLock("GE0", .F.)
	GE0->GE0_STATUS := "2"   //Conciliado
	MsUnlock()
	HS_MsgInf(STR0076,STR0065,STR0110) //"Extrato conciliado com sucesso!","Atencao" //"Funcao Conciliar"
Endif

If lTab
	DbSelectArea("GF0REC")
	DbCloseArea()
EndIf
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldConcบ Autor ณ Cibele Peria       บ Data ณ 17/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da rotina de conciliacao                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldConc()
Local lRet := .F.
Local lValRec	:= .F.
Local cValRec	:= ""

DbSelectArea("GF7")
DbSetOrder(1)
If DbSeek(xFilial("GF7") + GE0->GE0_NUMEXT)
	While GF7->(!Eof()) .AND. GF7->GF7_NREXTC == GE0->GE0_NUMEXT
		If !Empty(GF7->GF7_NRRECO)
			lValRec := .T.
			Exit
		EndIf
		GF7->(DbSkip())
	End
EndIf

If lValRec
	cValRec	:= "GE0->GE0_VLCONI < GE0->GE0_VLCONA"
	lValRec	:= .F.
Else
	cValRec	:= "GE0->GE0_VLCONI <> GE0->GE0_VLCONA"
EndIf

If GE0->GE0_TTCONI > 0 .and. GE0->GE0_TTCONI <> GE0->GE0_TTCONA
	HS_MsgInf(STR0077 + STR0078 + TRANSFORM(GE0->GE0_TTCONA, "@E 999,999") + ")",STR0065,STR0111) //"Extrato nao conciliado."###" Totais de contas divergentes (","Atencao" //"Validacao da rotina de conciliacao"
ElseIf &(cValRec)
	HS_MsgInf(STR0077 + STR0079 + TRANSFORM(GE0->GE0_VLCONA, "@E 9999,999.99") + ")",STR0065,STR0111) //"Extrato nao conciliado."###" Valores das contas divergentes (","Atencao" //"Validacao da rotina de conciliacao"
ElseIf GE0->GE0_VLGLOI <> GE0->GE0_VLGLOA
	HS_MsgInf(STR0077 + STR0080 + TRANSFORM(GE0->GE0_VLGLOA, "@E 9999,999.99") + ")",STR0065,STR0111) //"Extrato nao conciliado."###" Valores de glosa divergentes (","Atencao" //"Validacao da rotina de conciliacao"
Else
	lRet := .T.
Endif

Return(lRet)

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_M38Reaบ Autor ณ Cibele Peria       บ Data ณ 17/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Reabrir um extrato conciliado                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Abr(cAlias, nReg, nOpc)
Local Alias := Alias()
Local nOpcA := 0, oDlgR
Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

If GE0->GE0_STATUS == "1"
	HS_MsgInf(STR0081,STR0065,STR0112) //"Este extrato nao foi conciliado","Atencao" //"Reabrir um extrato conciliado"
	Return()
ElseIf GE0->GE0_STATUS == "3"
	HS_MsgInf(STR0075,STR0065,STR0112) //"Este extrato esta encerrado","Atencao" //"Reabrir um extrato conciliado"
	Return()
Endif

nOpcA := 0
DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0009) From aSize[ 7 ],000 to  aSize[ 6 ] / 2 , aSize[ 5 ]/2 of oMainWnd Pixel//"Conciliar"

Enchoice(cAlias, nReg, 2,,,,, {aPObjs[1,1], aPObjs[1,2], aPObjs[1,3], aPObjs[1,4]},,,,,)

ACTIVATE MSDIALOG oDlgR CENTERED ON INIT EnchoiceBar(oDlgR, {|| nOpcA := 1, oDlgR:End()}, ;
{|| nOpcA := 0, oDlgR:End()})

If nOpcA == 1
	DbSelectArea("GE0")
	RecLock("GE0", .F.)
	GE0->GE0_STATUS := "1"   //Nao conciliado
	MsUnlock()
	HS_MsgInf(STR0082,STR0065,STR0112) //"Extrato reaberto com sucesso!","Atencao" //"Reabrir um extrato conciliado"
Endif

Return()

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_M38Filบ Autor ณ Cibele Peria       บ Data ณ 07/04/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtro dos extratos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38Fil()
Local oBrwObj := GetObjBrow(), cStatus := ""

HS_DtvFilt("GE0")
DbSelectArea("GE0")
DbSetOrder(1)

If !Pergunte("HSM38B",.T.)
	Return()
EndIf
cStatus := TRANSFORM(mv_par01, "9")

If cStatus $ "1/2/3"
	HS_AtvFilt("GE0", "GE0->GE0_STATUS == '" + cStatus + "'")
Endif
DbSeek(xfilial("GE0"))

If oBrwObj # Nil
	oBrwObj:ResetLen()
	oBrwObj:Default()
	oBrwObj:Refresh()
EndIf
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38ConFบ Autor ณ Alessandro Freire  บ Data ณ 17/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Conciliacao Financeira                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38ConF(cAlias, nReg, nOpc)
Local aAreaOld   := GetArea()
Local nOpcA      := 0
Local oDlgC      := nil
Local nSaldoCR			:= 0, nSaldoRa := 0
Local nRecCR     := 0, nRecRA   := 0
Local aTitulo				:= {}
Local aCompensar := {}
Local cParc      := SPACE(TAMSX3("E1_PARCELA")[1])
Local aDespTit   := {}
Local nContTit   := 0, nContRA := 0
Local lRet       := .T., lNF := .F., lAchouRA := .F.
Local aRetVal    := {}
Local aJoin      := {}
Local aHSE1      := {}, aCSE1 := {}, nUSE1 := 0
Local aSize      := {}, aObjects   := {}, aInfo  := {}, aPObjs := {}
Local nApre      := 0 , nPago := 0, nGloD := 0, nGloF := 0, nAbatm := 0
Local nOrdGCZ    := IIF(lFilFat, 25,5)
Local cFilGCZ    := IIF(lFilFat, cFilAnt, xFilial("GCZ"))
Local cTipo      := "RA"
Local nBase      := 0
Local lNRecImp   := .T.
Local aCposVis   :={"E1_HIST" }

Private oSE1
Private nSE1OK   := 0, nSE1SALDO := 0, nSE1CLIENT := 0, nSE1LOJA := 0, nSE1PREFIX := 0, nSE1NUM := 0, nSE1PARCEL := 0, nSE1TIPO := 0
Private nValImp  := 0
Private aBases   := {}

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
If !HS_ExisDic({{"C", "GCZ_PRCTIT"}})
	Return(Nil)
EndIf

If GE0->GE0_STATUS == "1"
	HS_MsgInf(STR0083,STR0065,STR0113) //"Este extrato nใo foi conciliado" //"Conciliacao Financeira"
	Return(nil)
ElseIf GE0->GE0_STATUS == "3"
	HS_MsgInf(STR0084,STR0065,STR0113) //"Este extrato estแ encerrado" //"Conciliacao Financeira"
	Return(nil)
Endif

// Se os valores informados e associados nao estiverem iguais, nao pode executar a conciliacao financeira
If ! HS_VldConc()
	Return(.f.)
EndIf

DbSelectArea("GCZ")
DbSetOrder(IIF(lFilFat, 25, 5))
If DbSeek(cFilGCZ + GE0->GE0_NUMEXT)
	cParc := FS_RetUPrc(GCZ->GCZ_SERIE, GCZ->GCZ_NRFATU, GCZ->GCZ_TPNOTA)
	
	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If DbSeek(xFilial("SE1") + GCZ->GCZ_SERIE + GCZ->GCZ_NRFATU + PADR(cParc, Len(SE1->E1_PARCELA)) + GCZ->GCZ_TPNOTA)
		If SE1->E1_STATUS == 'B'
			HS_MsgInf(STR0149,STR0065,STR0113) //"Titulo Associado ja foi baixado para o Contas a Receber" //"Conciliacao Financeira"
			Return(.f.)
		EndIf
	EndIf
EndIf
nOpcA := 0
DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0087) From aSize[ 7 ],000 to  aSize[ 6 ] / 2 , aSize[ 5 ] / 2 of oMainWnd Pixel  //"Concilia็ใo Financeira"

RegToMemory(cAlias, .F.)
If	HS_ExisDic({{"C", "GE0_NATURE","BOPS 148151 - 19/06/08"}})
	M->GE0_NATURE := FS_RDadTit(M->GE0_NUMEXT)[1]
EndIf
Enchoice(cAlias, nReg, 4,,,,, {aPObjs[1,1], aPObjs[1,2], aPObjs[1,3], aPObjs[1,4]},,,,,)

ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC, {|| nOpcA := 1, oDlgC:End()}, ;
{|| nOpcA := 0, oDlgC:End()}  )

If nOpcA == 0
	Return(nil)
Else
	If ExistBlock("HSM38CNF")
		cTipo := ExecBlock("HSM38CNF", .F., .F.)
	EndIf
	
	AADD(aJoin, {" JOIN " + RetSqlName("GA9") + " GA9", "", "GA9.GA9_CODCLI = SE1.E1_CLIENTE AND GA9.GA9_LOJA = SE1.E1_LOJA AND GA9.GA9_CODCON = '" + GE0->GE0_CODCON + "' AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*'", ""})
	If HS_BDados("SE1", @aHSE1, @aCSE1, @nUSE1, 2,, "SE1->E1_TIPO = '" + cTipo + "' AND SE1->E1_SALDO > 0",,, "E1_CLIENTE/E1_NOMCLI /E1_LOJA   /E1_PREFIXO/E1_NUM    /E1_PARCELA/E1_TIPO   /E1_VALOR  /E1_SALDO  /E1_HIST   ",,,, "E1_OK", "'LBNO'", .T.,,,,,,, aJoin,,,aCposVis) == 0
		HS_MsgInf(STR0139 + cTipo + STR0140+ " " + STR0086,STR0065, STR0113) //"Nenhum tํtulo do tipo ["###"] foi encontrado para compensa็ใo do extrato."###"Extrato nใo conciliado"###"Atencao"###"Conciliacao Financeira"
		Return(Nil)
	EndIf
	nSE1OK     := aScan(aHSE1, {| aVet | aVet[2] == "E1_OK     "})
	nSE1SALDO  := aScan(aHSE1, {| aVet | aVet[2] == "E1_SALDO  "})
	nSE1CLIENT := aScan(aHSE1, {| aVet | aVet[2] == "E1_CLIENTE"})
	nSE1LOJA   := aScan(aHSE1, {| aVet | aVet[2] == "E1_LOJA   "})
	nSE1PREFIX := aScan(aHSE1, {| aVet | aVet[2] == "E1_PREFIXO"})
	nSE1NUM    := aScan(aHSE1, {| aVet | aVet[2] == "E1_NUM    "})
	nSE1PARCEL := aScan(aHSE1, {| aVet | aVet[2] == "E1_PARCELA"})
	nSE1TIPO   := aScan(aHSE1, {| aVet | aVet[2] == "E1_TIPO   "})
	
	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0121) From aSize[7], 000 to aSize[6], aSize[5] Of oMainWnd Pixel //Titulos para Compensa็ใo
	
	oSE1 := MsNewGetDados():New(aPObjs[1,1], aPObjs[1,2], aPObjs[1,3], aPObjs[1,4], 0,,,,,,99999,,,,oDlg, aHSE1, aCSE1)
	oSE1:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
	oSE1:oBrowse:BlDblClick := {|| HS_MARCA("oSE1", oSE1:oBrowse:nAt, nSE1OK) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_VldRA(@aDespTit, @lNRecImp), oDlg:End(), nOpcA := 0)},;
	{|| nOpcA := 0, oDlg:End()})
	
	If nOpcA == 0
		Return(Nil)
	EndIf
	
	Begin Transaction
	
	If	HS_ExisDic({{"C", "GE0_DESCON"}}, .F.)
		RecLock("GE0", .F.)
		GE0->GE0_DESCON := M->GE0_DESCON
		MsUnlock()
	EndIf
	
	If	HS_ExisDic({{"C", "GE0_ORECEI"}}, .F.)
		RecLock("GE0", .F.)
		GE0->GE0_ORECEI := M->GE0_ORECEI
		MsUnlock()
	EndIf
	
	If	HS_ExisDic({{"C", "GE0_NATURE","BOPS 148151 - 19/06/08"}})
		RecLock("GE0", .F.)
		GE0->GE0_NATURE := M->GE0_NATURE
		MsUnlock()
	EndIf
	
	For nContTit := 1 To Len(aDespTit)
		// Posiciona no Titulo principal
		cParc := IIF(!EMPTY(aDespTit[nContTit, 4]), aDespTit[nContTit, 4], FS_RetUPrc(aDespTit[nContTit, 1], aDespTit[nContTit, 2], aDespTit[nContTit, 3]))
		dbSelectArea("SE1")
		dbSetOrder(1)
		DbSeek(xFilial("SE1") + aDespTit[nContTit, 1] + aDespTit[nContTit, 2] + PADR(cParc, Len(SE1->E1_PARCELA)) + aDespTit[nContTit, 3])
		nRecCR   := SE1->(Recno())
		
		// Titulo com saldo zero nao faz nada
		// Vai para o proximo titulo sumarizado
		If SE1->E1_SALDO == 0
			Loop
		EndIf
		
		//Atribuicao das variaveis
		nApre := aDespTit[nContTit, 6][1]
		nPago := aDespTit[nContTit, 6][2]
		nGloD := aDespTit[nContTit, 6][3]
		nGloF := aDespTit[nContTit, 6][4]
		
		//Guarda dados do titulo principal
		aDadosTit := {	SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE,;
		SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO}
		
		//verifica se eh Titulo + Nota
		lNF := (SE1->E1_TIPO == PADR("NF", Len(SE1->E1_TIPO))) .Or. (SE1->E1_VALOR > nApre)
		
		If !lNF
			
			//Exclusao titulo principal
			If !(lRet := HS_MkTitCr(	SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE, ;
				SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, "HSPAHM38", 5))
				Loop
			EndIf
			
			nBase  := (M->GE0_VLCONI - M->GE0_VLGLOI)
			aBases := {nBase, nBase, nBase, nBase, nBase, nBase}
			//Gera titulo com dados do principal e com valor igual a Vl Tit Princ - Glosa Disc
			If !(lRet := HS_MkTitCr(	aDadosTit[1], aDadosTit[2], aDadosTit[3], aDadosTit[4], IIF(!EMPTY(GE0->GE0_NATURE), GE0->GE0_NATURE, aDadosTit[5]), ;
				aDadosTit[6], aDadosTit[7], aDadosTit[8] - nGloD, aDadosTit[9], aDadosTit[10], "HSPAHM38",, aDadosTit[11], "FA040Natur(aBases)") )
				Loop
			EndIf
			
			nRecCR   := SE1->(Recno())
			
			If nGloD > 0
				//Gera o novo titulo com o valor = Valor Titulo Principal - Valor Extrato + Glosas em discussao
				If !(lRet := HS_MkTitCr(	aDadosTit[1], aDadosTit[2], Soma1(aDadosTit[3], TAMSX3("E1_PARCELA")[1]), aDadosTit[4], GE0->GE0_NATURE, aDadosTit[6], ;
					aDadosTit[7], Round(aDadosTit[8] - nApre + nGloD, 2), aDadosTit[9], aDadosTit[10], "HSPAHM38",, aDadosTit[11]))
					Loop
				EndIf
			EndIf
			
			FS_AtuGCZ(GE0->GE0_NUMEXT, SE1->E1_PARCELA)
		EndIf
		
		DbSelectArea("SE1")
		
		//Se teve Glosa Fechada, gera titulo AB- com dados do principal e com valor igual a Glosa Fechado
		If nGloF > 0
			DbSetOrder(2) //Cliente+Loja+Num+Pref+Parc+Tipo
			If DbSeek(xFilial("SE1") +  aDadosTit[6] + aDadosTit[7] + aDadosTit[1] + aDadosTit[2] + aDadosTit[3] + "AB-")
				RecLock("SE1", .F.)
				SE1->E1_VALOR += nGloF
				SE1->E1_SALDO += nGloF
				nAbatm += SE1->E1_SALDO
				MsUnLock()
			ElseIf !(lRet := HS_MkTitCr(	aDadosTit[1], aDadosTit[2], aDadosTit[3], "AB-", GE0->GE0_NATURE, aDadosTit[6], ;
				aDadosTit[7], nGloF, aDadosTit[9], STR0088 + GCZ->GCZ_NREXTC, "HSPAHM38",, aDadosTit[11])) //"Glosa Extrato "
				Loop
			EndIf
		EndIf
		
		DbGoTo(nRecCR)
		
		While (nSaldoCR := SE1->E1_SALDO) > 0 .And. nPago > 0
			//Recno do Titulo Principal
			nRecCR   := SE1->(Recno())
			
			lAchouRA := .F.
			For nContRA := 1 To Len(oSE1:aCols)
				If oSE1:aCols[nContRA, nSE1OK] == "LBTIK"
					//	Posiciona na RA
					DbSelectArea("SE1")
					DbSetOrder(2)//CLIENTE + LOJA + PREFIXO + NUM + PARCELA + TIPO
					DbSeek(xFilial("SE1") + oSE1:aCols[nContRA, nSE1CLIENT] + oSE1:aCols[nContRA, nSE1LOJA] + oSE1:aCols[nContRA, nSE1PREFIX] + ;
					oSE1:aCols[nContRA, nSE1NUM] + oSE1:aCols[nContRA, nSE1PARCEL] + oSE1:aCols[nContRA, nSE1TIPO])
					If SE1->E1_SALDO > 0
						// Recno e Saldo da RA
						nRecRA   := SE1->(Recno())
						nSaldoRA := SE1->E1_SALDO
						lAchouRA := .T.
						Exit
					EndIf
				EndIf
			Next
			
			If !lAchouRA //Nao hแ mais RA com saldo. Vai para o proximo Titulo
				Exit
			EndIf
			
			// Se o saldo da RA for menor que o saldo do titulo principal
			// o valor a compensar deve ser o saldo da RA, caso contrario deve ser
			// o saldo do titulo principal
			nSaldoCR -= (nAbatm + IIF(lNF, nGloD, 0) + IIF(nValImp > 0 .and. lNRecImp, 0, nValImp))
			
			If nSaldoRA < nSaldoCR
				If nSaldoRA < nPago
					nSaldoCR := nSaldoRA
				Else
					nSaldoCR := nPago
				EndIf
			ElseIf nSaldoCR > nPago
				nSaldoCR :=  nPago
			EndIf
			
			nPago -= (nSaldoCR + IIF(nValImp > 0 .and. lNRecImp, 0, nValImp))
			
			// Vai para o tํtulo a ser compensado
			dbGoTo(nRecCR)
			
			/* Faz a compensacao do titulo (valor Pago) */
			aTitulo    := { nAbatm + nValImp, 0, 0, 0 }
			aCompensar := { { nRecRA, nSaldoCR, 0, Nil, Nil, Nil, Nil, Nil,Nil, Nil, Nil} }
			FaCmpCR(aTitulo, aCompensar, .F.,.F.)
			
			dbGoTo(nRecCR)
		EndDo
		
	Next
	
	If lRet
		dbSelectArea("GE0")
		RecLock("GE0", .F.)
		GE0->GE0_STATUS := "3"   //Encerrado
		MsUnlock()
		
		HS_MsgInf(STR0092,STR0065,STR0113) //"Extrato encerrado com sucesso!","ATENCAO" //"Conciliacao Financeira"
	Else
		HS_MsgInf(STR0118, STR0065,STR0087) //"Concilia็ใo Financeira cancelada!"###"Aten็ใo"###"Concilia็ใo Financeira"
	EndIf
	
	End Transaction
EndIf

RestArea(aAreaOld)

Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38CVirบ Autor ณ Cibele Peria       บ Data ณ 15/04/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz a inicializacao padrao do campo virtual GF7_NRFATU     บฑฑ
ฑฑบ          ณ com o conteudo da GCZ ou da GF0.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38CVir()
Local cNrFatu := ""
If Empty(GF7->GF7_NRRECO)
	cNrFatu := HS_IniPadR("GCZ", 1, GF7->GF7_NRSEQG, "GCZ_NRFATU",, .F.,, GF7->GF7_FILATE)
Else
	cNrFatu := Posicione("GF0", 1, xFilial("GF0")+GF7->GF7_NRRECO, "GF0_NRFATU")
Endif
Return(cNrFatu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38VlFrบ Autor ณ Cibele Peria       บ Data ณ 15/04/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacoes das perguntas                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M38VlF()
If !Empty(mv_par01)
	cGCZNrFatu := mv_par01
Endif
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_m38leg บAutor  ณ Alessandro Freire  บ Data ณ  27/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_m38Leg()
BrwLegenda(cCadastro, STR0012, {{'BR_VERDE'   , STR0086}, ; //"Legenda"###"Extrato nใo conciliado"
{'BR_AMARELO' , STR0093    }, ; //"Extrato conciliado"
{'BR_VERMELHO', STR0094}}) //"Extrato com concilia็ใo financeira"
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GETREC บAutor  ณAlessandro Freire   บ Data ณ  29/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecupera os detalhes de cada recurso da getdados e os grava บฑฑ
ฑฑบ          ณno array de retorno.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GETREC( aHeadRec, aColsRec, cCpoRec, cStatus )
Local nGF0_NUMREC := aScan( aHeadRec, {|x| x[2] == "GF0_NUMREC" } )
Local cNumRec     := ""
Local cCond       := ""

Local aHeadGF5 := {}
Local aColsGF5 := {}
Local nUGF5    := 0

Local aHeadGF6 := {}
Local aColsGF6 := {}
Local nUGF6    := 0

Local aHeadGF7 := {}
Local aColsGF7 := {}
Local nUGF7    := 0

Local nGf5     := 0
Local nGf6     := 0
Local nGf7     := 0

Local aDetalhe := {}
Local nLoop

Local cCposRec := "/_FILATE/_ORIDES/_SEQDES/_CODDES/_DDESPE/_VALAPR/_VALPAG/_VALGLO/_NRRECO/_VALREC/_VALPER/_CDMGLO/_DSMGLO/_CDJGLO/_DSJGLO/_COMJGL/_STATUS/_NREXTM"

For nLoop := 1 to Len( aColsRec )
	
	aHeadGF5 := {}
	aColsGF5 := {}
	nUGF5    := 0
	
	aHeadGF6 := {}
	aColsGF6 := {}
	nUGF6    := 0
	
	aHeadGF7 := {}
	aColsGF7 := {}
	nUGF7    := 0
	
	cNumRec  := aColsRec[nLoop, nGF0_NUMREC]
	
	cCond    := "GF5" + cCpoRec + " = '" + cNumRec + "' AND GF5_STATUS = '" + cStatus + "' "
	nGF5     := HS_BDados("GF5", @aHeadGF5, @aColsGF5, @nUGF5, 2,, cCond,,, STRTRAN(cCposRec, "/_", "/" + PrefixoCpo("GF5") + "_"),,,,,, .T.)
	
	cCond    := "GF6" + cCpoRec + " = '" + cNumRec + "' AND GF6_STATUS = '" + cStatus + "' "
	nGF6     := HS_BDados("GF6", @aHeadGF6, @aColsGF6, @nUGF6, 2,, cCond,,, STRTRAN(cCposRec, "/_", "/" + PrefixoCpo("GF6") + "_"),,,,,, .T.)
	
	cCond    := "GF7" + cCpoRec + " = '" + cNumRec + "' AND GF7_STATUS = '" + cStatus + "' "
	nGF7     := HS_BDados("GF7", @aHeadGF7, @aColsGF7, @nUGF7, 2,, cCond,,, STRTRAN(cCposRec, "/_", "/" + PrefixoCpo("GF7") + "_"),,,,,, .T.)
	
	AAdd(aDetalhe, { aHeadGF5, aColsGF5, nUGF5, ;
	aHeadGF6, aColsGF6, nUGF6, ;
	aHeadGF7, aColsGF7, nUGF7  } )
	
Next nLoop

Return( aDetalhe )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfs_chgrec บAutor  ณ Alessandro Freire  บ Data ณ  29/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza as getdados de detalhe dos recursos                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Associacao de recursos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ChgRec( nPos, oGF5, oGF6, oGF7, oFolder, aDetRec )

oGF5:SetArray(aDetRec[nPos,2])
oGF5:oBrowse:Refresh()
oFolder:aDialogs[1]:lActive := (aDetRec[nPos,3] > 0)

oGF6:SetArray(aDetRec[nPos,5])
oGF6:oBrowse:Refresh()
oFolder:aDialogs[2]:lActive := (aDetRec[nPos,6] > 0)

oGF7:SetArray(aDetRec[nPos,8])
oGF7:oBrowse:Refresh()
oFolder:aDialogs[3]:lActive := (aDetRec[nPos,9] > 0)

oFolder:Refresh()
SYSREFRESH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38ATE บAutor  ณAlessandro Freire   บ Data ณ  04/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o NUMERO DE ATENDIMENTO DA GUIA                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INICIALIZADOR PADRAO DAS TABELAS GF5,6 E 7                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M38ATE( cNrSeqG )
Local cAte := Posicione( "GCZ",1,xFilial("GCZ")+cNrSeqG, "GCZ_REGATE" )
Return( cAte )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38GUIAบAutor  ณAlessandro Freire   บ Data ณ  04/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o NUMERO DA GUIA DE ATENDIMENTO                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INICIALIZADOR PADRAO DAS TABELAS GF5,6 E 7                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M38GUIA( cNrSeqG )
Local cGuia := Posicione( "GCZ",1,xFilial("GCZ")+cNrSeqG, "GCZ_NRGUIA" )
Return( cGuia )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38PAC บAutor  ณAlessandro Freire   บ Data ณ  04/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o nome do paciente da GUIA                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INICIALIZADOR PADRAO DAS TABELAS GF5,6 E 7                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M38PAC( cNrSeqG, cFilAte )
Local cAte := Posicione( "GCZ",1,cFilAte+cNrSeqG, "GCZ_REGATE" )
Local cPac := Posicione( "GCY",1,xFilial("GCY")+cAte   , "GCY_NOME"   )

Return( cPac )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38DATEบAutor  ณAlessandro Freire   บ Data ณ  04/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a DATA DE ATENDIMENTO DA GUIA                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INICIALIZADOR PADRAO DAS TABELAS GF5,6 E 7                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M38DATE( cNrSeqG, cFilAte )
Local cAte  := Posicione( "GCZ",1,cFilAte+cNrSeqG, "GCZ_REGATE" )
Local cDAte := Posicione( "GCY",1,xFilial("GCY")+cAte   , "GCY_DATATE" )

Return( cDAte )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M38HATEบAutor  ณAlessandro Freire   บ Data ณ  04/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a HORA DE ATENDIMENTO DA GUIA                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INICIALIZADOR PADRAO DAS TABELAS GF5,6 E 7                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M38HATE( cNrSeqG, cFilAte )
Local cAte  := Posicione( "GCZ",1,cFilAte+cNrSeqG, "GCZ_REGATE" )
Local cHAte := Posicione( "GCY",1,xFilial("GCY")+cAte   , "GCY_HORATE" )

Return( cHAte )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SeqMov บ Autor ณ Cibele Peria       บ Data ณ 10/09/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta codigo sequencial da movimentacao                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SeqMov(cCodOld, nOper)
Return(STRZERO(VAL(cCodOld)+nOper, len(cCodOld)))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AtuGG7 บAutor  ณDaniel peixoto      บ Data ณ  11/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava/Limpa campo GG7_NUMEXT para itens do procedimento     บฑฑ
ฑฑบ          ณdo tipo pacote                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_AtuGG7(cTipo, cSeqGE7, cNumExt, cFilAte)
Local aAreaOld := GetArea()
Local cFilGG   := IIF(Empty(xFilial("GG7")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte)

DbSelectArea("GG7")
DbSetOrder(4)//SEQGE7
If DbSeek(cFilGG + cSeqGE7)
	While !Eof() .and. GG7->GG7_FILIAL == cFilGG .and. GG7->GG7_SEQGE7 == cSeqGE7
		RecLock("GG7", .F.)
		GG7->GG7_STATUS := IIF(cTipo == "Assoc", "1", " ")  //Associado ou Aberto
		GG7->GG7_DATSTA := dDataBase
		GG7->GG7_HORSTA := Time()
		GG7->GG7_NREXTC := IIF(cTipo == "Assoc", cNumExt, SPACE(LEN(GG7_NREXTC)) )
		GG7->GG7_LOGARQ := HS_LogArq()
		MsUnlock()
		DbSkip()
	EndDo
EndIf

RestArea(aAreaOld)

Return(Nil)

Static Function FS_RetUPrc(cPrefixo, cNum, cTipo)
Local aAreaOld := getArea()
Local c1Parc   := "", cSql := ""

cSql := "SELECT MAX(E1_PARCELA) PARCELA "
cSql += " FROM " + RetSqlName("SE1") + " SE1 "
cSql += " WHERE SE1.D_E_L_E_T_ <> '*' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
cSql += " AND SE1.E1_PREFIXO = '" + cPrefixo + "' "
cSql += " AND SE1.E1_NUM     = '" + cNum     + "' "
cSql += " AND SE1.E1_TIPO    = '" + cTipo    + "' "

cSql := ChangeQuery(cSql)

TCQuery cSql New Alias "QRY"
DbSelectArea("QRY")

c1Parc := PADR(QRY->PARCELA, TAMSX3("E1_PARCELA")[1])

DbCloseArea()

RestArea(aAreaOld)

Return(c1Parc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CalcDifบAutor  ณDaniel Peixoto      บ Data ณ  27/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o calculo dos valores pagos/recuperados - valores   บฑฑ
ฑฑบ          ณglosados/perdidos                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CalcDif(nTipo, cSerie, cFatura, cTpNota, cParc, cNrExtC, cChv, aRet)
Local nValApr   := 0, nValPag := 0, nValGloDsc := 0, nValGloFch := 0
Local aAliasGF  := {{"GF5", "GF5.GF5"}, {"GF6", "GF6.GF6"}, {"GF7", "GF7.GF7"}}
Local cCpoChv   := IIF(nTipo == 1, "_NRSEQG", "_NRRECO")
Local cCpoApr   := IIF(nTipo == 1, "_VALAPR", "_VALGLO")
Local cCpoPag   := IIF(nTipo == 1, "_VALPAG", "_VALREC")
Local cCpoGlo   := IIF(nTipo == 1, "_VALGLO", "_VALPER")
Local nForGF    := 0
Local aAreaOld  := GetArea()
Local cSerie1   := "", cFatura1 := "", cTpNota1 := "", cParc1 := "", cNrSeqG := ""

For nForGF := 1 To Len(aAliasGF)
	cQry := " SELECT  GDM.GDM_TIPO TIPGLO, "
	If nTipo == 1
		cQry += " SUM(" + aAliasGF[nForGF, 2] + cCpoApr + ") VALAPR, SUM(" + aAliasGF[nForGF, 2] + cCpoPag + ") VALPAG, "
		cQry += " SUM(" + aAliasGF[nForGF, 2] + cCpoGlo + ") VALGLO "
	Else //Recurso
		cQry += "GCZ.GCZ_NRSEQG NRSEQG, GCZ.GCZ_NRFATU NRFATU, GCZ.GCZ_SERIE SERIE, GCZ.GCZ_TPNOTA TPNOTA, GCZ.GCZ_PRCTIT PRCTIT, "
		cQry += aAliasGF[nForGF, 2] + cCpoApr + " VALAPR, " + aAliasGF[nForGF, 2] + cCpoPag + " VALPAG, "
		cQry += aAliasGF[nForGF, 2] + cCpoGlo + " VALGLO "
	EndIf
	cQry += " FROM " + RetSqlName(aAliasGF[nForGF, 1]) + " " + aAliasGF[nForGF, 1] + " "
	cQry += " LEFT JOIN " + RetSqlName("GDM") + " GDM ON GDM.GDM_CODIGO = " + aAliasGF[nForGF, 2] + "_CDMGLO AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
	cQry += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + aAliasGF[nForGF, 2] + "_NRSEQG AND GCZ.GCZ_NRFATU <> '" + SPACE(Len(GCZ->GCZ_NRFATU))+ "' AND GCZ.GCZ_FILFAT = '" + IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAnt) + "' AND GCZ.D_E_L_E_T_ <> '*' "
	If HS_ExisDic({{"C", aAliasGF[nForGF, 1] + "_FILATE "}}, .F.)
		cQry += " AND GCZ.GCZ_FILATE = " + aAliasGF[nForGF, 2] + "_FILATE "
	EndIf
	cQry += " WHERE " + aAliasGF[nForGF, 2] + "_FILIAL  = '" + xFilial(aAliasGF[nForGF, 1]) + "' AND " + aAliasGF[nForGF, 1] + ".D_E_L_E_T_ <> '*' "
	cQry += " AND " + aAliasGF[nForGF, 2] + "_NREXTC = '" + cNrExtC + "' "
	cQry += " AND " + aAliasGF[nForGF, 2] + "_STATUS <> '6' "
	cQry += " AND " + aAliasGF[nForGF, 2] + cCpoChv + " = '" + cChv + "' "
	If nTipo == 1
		cQry += " GROUP BY GDM.GDM_TIPO"
	EndIf
	
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.t.,"TOPCONN",TcGenQry(,,cQry),"TRBDIF",.f.,.f. )
	
	DBGotop()
	
	While !EOF()
		nValPag    := TRBDIF->VALPAG
		nValGloDsc := IIF(TRBDIF->TIPGLO == "1" , TRBDIF->VALGLO, 0)
		nValGloFch := IIF(TRBDIF->TIPGLO == "2" .OR. TRBDIF->TIPGLO == "3", TRBDIF->VALGLO, 0)
		nValApr    := TRBDIF->VALAPR
		
		cSerie1  := IIF(nTipo == 1, cSerie  , TRBDIF->SERIE)
		cFatura1 := IIF(nTipo == 1, cFatura , TRBDIF->NRFATU)
		cTpNota1 := IIF(nTipo == 1, cTpNota , TRBDIF->TPNOTA)
		cParc1   := IIF(nTipo == 1, cParc   , TRBDIF->PRCTIT)
		cNrSeqG  := IIF(nTipo == 1, cChv    , TRBDIF->NRSEQG)
		
		If (nPos := aScan(aRet, {| aVet | aVet[1] == cSerie1 .And. aVet[2] == cFatura1 .And. aVet[4] == cParc1})) == 0
			AADD(aRet, {cSerie1, ; //Prefixo
			cFatura1, ; //NumTit
			cTpNota1, ; //Tipo
			cParc1, ; //Parcela
			cNrSeqG, ; //Nr Seq Guia ou Nr Recurso
			{nValApr, nValPag, nValGloDsc, nValGloFch}} )//[1]Vls Apr [2]Pagos/Rec [3]Vls Glosa/Per Discussao [4]Vls Glosa/Per Fechado
		Else
			aRet[nPos, 6][1] += nValApr
			aRet[nPos, 6][2] += nValPag
			aRet[nPos, 6][3] += nValGloDsc
			aRet[nPos, 6][4] += nValGloFch
		EndIf
		
		DbSkip()
		
	EndDo
	
	dbCloseArea()
Next

RestArea(aAreaOld)
Return(Nil)

Static Function FS_VldRA(aDespTit, lNRecImp)
Local lRet     := .T.
Local nCont    := 0, nSaldoRA := 0, nForTab := 0, nForTit := 0, nContTit := 0
Local cGuiaRec := "", cParc := ""
Local aTabs    := {{"GCZ", "GCZ->GCZ", IIF(lFilFat, 25,5), "_NRSEQG"}, {"GF0", "GF0->GF0", 3, "_NUMREC"}}
Local cFilGCZ  := IIF(lFilFat, cFilAnt, xFilial("GCZ"))
Local nValDesc := IIF(HS_ExisDic({{"C", "GE0_DESCON"}}, .F.), M->GE0_DESCON, 0)
Local nValOutR := IIF(HS_ExisDic({{"C", "GE0_ORECEI"}}, .F.), M->GE0_ORECEI, 0)
Local cCodCli  := "", cCodLoja := ""

For nCont := 1 To Len(oSE1:aCols)
	If oSE1:aCols[nCont, nSE1OK] == "LBTIK"
		nSaldoRA += oSE1:aCols[nCont, nSE1SALDO]
		cCodCli  := oSE1:aCols[nCont, nSE1CLIENT]
		cCodLoja := oSE1:aCols[nCont, nSE1LOJA]
	EndIf
Next

DbSelectArea("SA1")
DbSetOrder(1) //Cod + Loja
DBSeek(xFilial("SA1") + cCodCli + cCodLoja)
lNRecImp := SA1->A1_RECISS != "1" //Nao Recolhe Impostos

nValImp := FS_RValImp(M->GE0_NUMEXT, (M->GE0_VLCONI - M->GE0_VLGLOI), M->GE0_NATURE)
If nSaldoRa < M->GE0_VLCONI - M->GE0_VLGLOI -  nValImp - nValDesc + nValOutR
	HS_MsgInf(STR0085 + " " + ; //"O saldo dos Titulos a serem compensados ้ menor que o valor informado no extrato."
	STR0086 + CHR(10) + ;
	"  " + Transform(M->GE0_VLCONI, "@E 999,999.99") + STR0141 + CHR(10) + ; //" Extrato"
	"- " + Transform(M->GE0_VLGLOI, "@E 999,999.99") + STR0142 + CHR(10) + ; //" Glosas"
	IIF(lNRecImp, "", "- " + Transform(nValImp , "@E 999,999.99") + STR0143 + CHR(10)) + ;          	  //" Impostos"
	"- " + Transform(nValDesc, "@E 999,999.99") + STR0144 + CHR(10) + ;          	  //" Descontos"
	"+ " + Transform(nValOutR, "@E 999,999.99") + STR0145 + CHR(10) + ;          	  //" Outras Rec"
	"> " + Transform(nSaldoRA, "@E 999,999.99") + STR0146 + CHR(10),;          	  //" Saldo Titulos a compensar"
	STR0065,STR0113) //"Extrato nใo conciliado","Atencao" //"Conciliacao Financeira"
	Return(.F.)
EndIf

For nForTab := 1 To 2
	DbSelectArea(aTabs[nForTab, 1])
	DbSetOrder(aTabs[nForTab, 3])
	DbSeek(IIF(nForTab == 1, cFilGCZ, xFilial(aTabs[nForTab, 1])) + GE0->GE0_NUMEXT)
	While !Eof() .and. &(aTabs[nForTab, 2] + "_NREXTC") == GE0->GE0_NUMEXT
		FS_CalcDif(nForTab, ;
		IIF(nForTab == 1, &(aTabs[nForTab, 2] + "_SERIE" ), Nil), ;
		IIF(nForTab == 1, &(aTabs[nForTab, 2] + "_NRFATU"), Nil), ;
		IIF(nForTab == 1, &(aTabs[nForTab, 2] + "_TPNOTA"), Nil), ;
		IIF(nForTab == 1, &(aTabs[nForTab, 2] + "_PRCTIT"), Nil), ;
		&(aTabs[nForTab, 2] + "_NREXTC"), ;
		&(aTabs[nForTab, 2] + aTabs[nForTab, 4]), ;
		@aDespTit)
		DBSkip()
	EndDo
Next

For nForTit := 1 To Len(aDespTit)
	cParc := IIF(!EMPTY(aDespTit[nForTit, 4]), aDespTit[nForTit, 4], FS_RetUPrc(aDespTit[nForTit, 1], aDespTit[nForTit, 2], aDespTit[nForTit, 3]))
	
	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If !DbSeek(xFilial("SE1") + aDespTit[nForTit, 1] + aDespTit[nForTit, 2] + PADR(cParc, Len(SE1->E1_PARCELA)) + aDespTit[nForTit, 3])
		cGuiaRec += aDespTit[nForTit, 5] + IIF(!Empty(cGuiaRec), "/", "")
		nContTit++
	EndIf
Next

If !(lRet := nContTit == 0)
	HS_MsgInf(STR0127 + cGuiaRec + "]", STR0065, STR0128)// "Nใo hแ tํtulo para a guia/recurso ["###"Aten็ใo"###"Valida็ใo de Tํtulos"
EndIf

Return(lRet)

Function HS_VldTit()
Local lRet := .T.

If ReadVar() = "MV_PAR01" //Prefixo
	If !Empty(MV_PAR01)
		DbSelectArea("SE1")
		DbSetOrder(2) //FILIAL + CLIENTE + LOJA + PREFIXO + NUM
		If !(lRet := AllTrim(MV_PAR01) $ cSE1Prefix)
			HS_MsgInf(STR0122 + cSE1Prefix + "]", STR0065, STR0123) //"Prefixo diferente dos permitidos no m๓dulo de Gestใo Hospitalar ["###"Aten็ใo"###"Associa็ใo da Fatura"
		ElseIf !(lRet := DbSeek(xFilial("SE1") + cE1Cliente + cE1Loja + MV_PAR01))
			HS_MsgInf(STR0124 + cE1Cliente + STR0125, STR0065, STR0123) //"Nใo foi encontrado tํtulo do cliente ["###" ] com o prefixo informado"###"Aten็ใo"###"Associa็ใo da Fatura"
		Else
			cE1Prefixo := AllTrim(MV_PAR01)
		EndIf
	Else
		cE1Prefixo := IIF(Len(GetMV("MV_HSPSERI")) >= Len(SE1->E1_SERIE), GetMV("MV_HSPSERI"), PadR(GetMV("MV_HSPSERI"), Len(SE1->E1_SERIE))) + "/" + IIF(Len(GetMV("MV_PREFCRH")) >= Len(SE1->E1_PREFIXO), GetMV("MV_PREFCRH"), PadR(GetMV("MV_PREFCRH"), Len(SE1->E1_PREFIXO)))
	EndIf
ElseIf ReadVar() = "MV_PAR02" //Num
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		DbSelectArea("SE1")
		DbSetOrder(2) //FILIAL + CLIENTE + LOJA + PREFIXO + NUM
		If !(lRet := DbSeek(xFilial("SE1") + cE1Cliente + cE1Loja + PadR(MV_PAR01,Len(SE1->E1_SERIE)) + MV_PAR02))
			HS_MsgInf(STR0124 + cE1Cliente + STR0125, STR0065, STR0123) //"Nใo foi encontrado tํtulo do cliente ["###" ] com o prefixo informado"###"Aten็ใo"###"Associa็ใo da Fatura"
		EndIf
	EndIf
	
EndIf

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
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"  , 0, 1, 0, nil},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "axVisual"  , 0, 2, 0, nil},; //"Visualizar"
                     {OemtoAnsi(STR0003), "axInclui"  , 0, 3, 0, nil},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_M38Alt" , 0, 4, 0, nil},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_M38Exc" , 0, 5, 0, nil},; //"Excluir"
                     {OemtoAnsi(STR0006), "HS_M38Ass" , 0, 4, 0, nil},; //"Associar"
                     {OemtoAnsi(STR0007), "HS_M38Des" , 0, 4, 0, nil},; //"Desassociar"
                     {OemtoAnsi(STR0008), "HS_M38Det" , 0, 4, 0, nil},; //"Detalhar"
                     {OemtoAnsi(STR0009), "HS_M38Con" , 0, 4, 0, nil},; //"Conciliar"
                     {OemtoAnsi(STR0010), "HS_M38ConF", 0, 4, 0, nil},; //"Conc.Financ"
                     {OemtoAnsi(STR0011), "HS_M38Abr" , 0, 4, 0, nil},; //"Reabrir"
                     {OemtoAnsi(STR0012), "HS_M38Leg" , 0, 3, 0, nil}}  //"Legenda"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VlConciบAutor  ณPatricia Queiroz    บ Data ณ  12/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se existe alguma despesa que nao foi detalhada, se  บฑฑ
ฑฑบ            houver nao efetua a conciliacao.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HS_M38Con                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                      
Static Function FS_VlConci(nNumExt)
Local aArea := GetArea()
Local lRet  := .T.

If HS_CountTB("GF5", "GF5_NREXTC = '" + nNumExt + "' AND GF5_STATUS = '1'") > 0
	lRet := .F.
ElseIf HS_CountTB("GF6", "GF6_NREXTC = '" + nNumExt + "' AND GF6_STATUS = '1'") > 0
	lRet := .F.
ElseIf HS_CountTB("GF7", "GF7_NREXTC = '" + nNumExt + "' AND GF7_STATUS = '1'") > 0
	lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AtuGCZ บAutor  ณDaniel Silva        บ Data ณ  11/28/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza็ใo nas guias da parcela do titulo utilizado        บฑฑ
ฑฑบ          ณna concilia็ใo financeira                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AtuGCZ(cNrExtC, cPrcTit)
Local aGCZ      := {}
Local aAliasGF  := {{"GF5", "GF5.GF5"}, {"GF6", "GF6.GF6"}, {"GF7", "GF7.GF7"}}
Local nForGF    := 0, nCont := 0
Local aAreaOld  := GetArea()
Local cQry      := ""

For nForGF := 1 To Len(aAliasGF)
	cQry += IIF(nForGF > 1, "UNION ", "") + " SELECT GCZ.R_E_C_N_O_ "
	cQry += " FROM " + RetSqlName(aAliasGF[nForGF, 1]) + " " + aAliasGF[nForGF, 1] + " "
	cQry += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + aAliasGF[nForGF, 2] + "_NRSEQG AND GCZ.GCZ_NRFATU <> '" + SPACE(Len(GCZ->GCZ_NRFATU))+ "' AND GCZ.GCZ_FILFAT = '" + IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAnt) + "' AND GCZ.D_E_L_E_T_ <> '*' "
	If HS_ExisDic({{"C", aAliasGF[nForGF, 1] + "_FILATE"}}, .F.)
		cQry += " AND GCZ.GCZ_FILATE = " + aAliasGF[nForGF, 2] + "_FILATE "
	EndIf
	cQry += " WHERE " + aAliasGF[nForGF, 2] + "_FILIAL  = '" + xFilial(aAliasGF[nForGF, 1]) + "' AND " + aAliasGF[nForGF, 1] + ".D_E_L_E_T_ <> '*' "
	cQry += " AND " + aAliasGF[nForGF, 2] + "_NREXTC = '" + cNrExtC + "' "
Next

cQry := ChangeQuery(cQry)

dbUseArea(.t.,"TOPCONN",TcGenQry(,,cQry),"TRBGCZ",.f.,.f. )

DBGotop()

While !EOF()
	AADD(aGCZ, TRBGCZ->R_E_C_N_O_ )
	
	DbSkip()
EndDo

dbCloseArea()

DbSelectArea("GCZ")

For nCont := 1 To Len(aGCZ)
	DBGoTo(aGCZ[nCont])
	
	RecLock("GCZ", .F.)
	GCZ->GCZ_PRCTIT := cPrcTit
	MsUnLock()
Next

RestArea(aAreaOld)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IncGFGrบAutor  ณDaniel Peixoto      บ Data ณ  26/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a Inclusao/Exclusao da despesa GF de acordo com a   บฑฑ
ฑฑบ          ณinformacao digita na guia(detalhamento por grupo)           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	FS_IncGFGr(cAlias, cNrSeqG, cFilAte, aRet, lDelTmp)
Local aAreaOld  := GetArea()
Local cPref     := cAlias + "->" + cAlias
Local cCodDes   := PADR(GetMV(IIF(cAlias == "GF5", "MV_GRPMATM", "MV_GRPTAXD")), LEN(GF6->GF6_CODDES))
Local cCdmGlo   := GetMV("MV_MGLOGRP")
Local lAchou    := .F.
Local cAliasTmp := cAlias + "Tmp"

Default lDelTmp := .F.

DBSelectArea(cAlias)
DBSetOrder(3) //NREXTC + NRSEQG + CODDES
lAchou := DBSeek(xFilial(cAlias) + GE0->GE0_NUMEXT + cNrSeqG + cCodDes)

If lAchou .And. aRet[2] == 0 .And. aRet[3] == 0 //Nao esta mais detalhado por grupo
	RecLock(cAlias, !lAchou)
	DBDelete()
	MsUnlock()
	If lDelTmp
		DbSelectArea(cAliasTmp)
		DbSetOrder(1) //FILATE+NRSEQG+SEQDES+CODDES
		If DbSeek(cFilAte + cNrSeqG + SPACE(Len(GF5->GF5_SEQDES)) + cCodDes)
			RecLock(cAliasTmp, !lAchou)
			DBDelete()
			MsUnlock()
		EndIf
	EndIf
	HS_StaGFs(cAlias, GE0->GE0_NUMEXT, cNrSeqG, {{"_STATUS", "1"}}, lDelTmp, "6") //Passa De det Grupo p/ Associado
	
ElseIf aRet[1] //Detalhamento por grupo
	RecLock(cAlias, !lAchou)
	&(cPref + "_FILIAL") := xFilial(cAlias)
	&(cPref + "_NREXTC") := GE0->GE0_NUMEXT
	&(cPref + "_NRSEQG") := cNrSeqG
	&(cPref + "_CODDES") := cCodDes
	&(cPref + "_VALAPR") := FS_TotIten(cAlias, "_ValApr")
	&(cPref + "_VALPAG") := aRet[2]
	&(cPref + "_VALGLO") := aRet[3]
	&(cPref + "_STATUS") := "2"   //Disponivel p/ Recurso
	&(cPref + "_DATSTA") := dDataBase
	&(cPref + "_HORSTA") := Time()
	&(cPref + "_SEQMOV") := "000001"
	&(cPref + "_ULTREG") := "2" //1=Nao 2=Sim (ultimo registro)
	&(cPref + "_CODCON") := GE0->GE0_CODCON
	&(cPref + "_LOGARQ") := HS_LogArq()
	If HS_ExisDic({{"C", PrefixoCpo(cAlias) + "_FILATE"}}, .F.)
		&(cPref + "_FILATE") := IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAte)
	EndIf
	&(cPref + "_CDMGLO") := cCdMGlo
	MsUnlock()
EndIf

RestArea(aAreaOld)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TotItenบAutor  ณDaniel Silva        บ Data ณ  02/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula total dos itens lan็ados no aCols daGFs             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TotIten(cAlias, cCpo, nAt)
Local nCont    := 0, nTotal := 0
Local aCols    := &("o" + cAlias):aCols
Local cPrefVar := "n" + Substr(cAlias, 2, 2)

Default nAt := 0

For nCont :=  1 To Len(aCols)
	If nAt <> 0 .And. nCont == nAt
		Loop
	EndIf
	nTotal += aCols[nCont, &(cPrefVar + cCpo)]
Next

Return(nTotal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_StaGFs บAutor  ณDaniel Silva        บ Data ณ  02/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera Status das GFs                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_StaGFs(cAlias, cNumExtC, cNrSeqG, aCpos, lDelTmp, cStatus)
Local aAreaOld := GetArea()
Local nCont    := 0
Local cPref    := cAlias + "->" + cAlias

Default lDelTmp := .F.
Default cStatus := ""

DBSelectArea(cAlias)
DBSetOrder(9) //NREXTC + NRSEQG + STATUS
If DBSeek(xFilial(cAlias) + cNumExtC + cNrSeqG + IIF(!Empty(cStatus), cStatus, ""))
	While !EOF() .And. &(cPref + "_FILIAL") == xFilial(cAlias) .And. &(cPref + "_NREXTC") == cNumExtC .And. &(cPref + "_NRSEQG") == cNrSeqG .And. ;
		IIF(!Empty(cStatus), &(cPref + "_STATUS") == cStatus, .T.)
		RecLock(cAlias, .F.)
		For nCont := 1 To Len(aCpos)
			&(cPref + aCpos[nCont, 1]) := aCpos[nCont, 2]
		Next
		MsUnlock()
		DbSkip()
	EndDo
EndIf

RestArea(aAreaOld)

Return(Nil)

Static Function FS_VldOK(nGuia)
Local lRet   := .T.
Local aAlias := {{"GF5DetG", nCZ_VlPagM}, {"GF6DetG", nCZ_VlPagT}}
Local nCont  := 0, nTotItens := 0

For nCont := 1 To Len(aAlias)
	nTotItens := FS_TotIten(aAlias[nCont, 1], "_ValPag")
	If nTotItens <> oGCZ:aCols[nGuia, aAlias[nCont, 2]]
		HS_MsgInf(STR0136 + IIF(nCont == 1, STR0044, STR0045) + "]." + CHR(10) +; //"Valor invแlido Aba ["###"Materiais/Medicamentos"###"Taxas/Diarias"
		STR0137 + TRANSFORM(nTotItens, "@E 9999,999.99") + STR0138 + ; //"O somat๓rio dos valores pagos ["###"] diferente do valor pago no grupo ["
		TRANSFORM(oGCZ:aCols[nGuia, aAlias[nCont, 2]], "@E 9999,999.99") + "]",STR0065,STR0102) //"Atencao" //"Validacao dos campos dos itens das despesas"
		Return(.F.)
	EndIf
	
Next

Return(lRet)

Static Function FS_AtuPGlo()
Local aAreaOld := GetArea()
Local aAlias   := {"GF5", "GF6"}
Local cALias   := "", cPref   := ""
Local cPrefVar := ""
Local nCont    := 0, nRegs := 0
Local oObj

For nCont := 1 To Len(aAlias)
	oObj     := &("o" + aAlias[nCont] + "DetG")
	cAlias   := aAlias[nCont]
	cPref    := cAlias + "->" + cAlias
	cPrefVar := "n" + Substr(cAlias, 2)
	
	For nRegs := 1 To Len(oObj:aCols)
		DBSelectArea(aAlias[nCont])
		DBSetOrder(1) //FILIAL + NREXTC + SEQDES
		If DBSeek(xFilial(cAlias) + GE0->GE0_NUMEXT + oObj:aCols[nRegs, &(cPrefVar + "_SeqDes")])
			RecLock(cAlias, .F.)
			&(cPref + "_ValPag") := oObj:aCols[nRegs, &(cPrefVar + "_ValPag")]
			&(cPref + "_ValGlo") := oObj:aCols[nRegs, &(cPrefVar + "_ValGlo")]
			MSUnLock()
		EndIf
	Next
Next

RestArea(aAreaOld)
Return(Nil)

Static Function Fs_RetMemo(cAlias, nRecNo, cCampo)
Local aArea  := getArea()
Local cRet   := ""

If ValType(nRecNo) == "N"
	&(cAlias+"->(DbGoTo("+AllTrim(Str(nRecNo))+"))")
	cRet := &(cAlias+"->"+cCampo)
Else
	cRet := nRecNo
EndIf

RestArea(aArea)

return(cRet)

Static Function FS_RDadTit(cNrExtC)
Local cNum      := SPACE(LEN(SE1->E1_NUM))
Local cNatureza := SPACE(LEN(SE1->E1_NATUREZ))
Local cTipo     := SPACE(LEN(SE1->E1_TIPO))
Local cPedido   := SPACE(LEN(SE1->E1_PEDIDO))
Local aAliasGF  := {{"GF5", "GF5.GF5"}, {"GF6", "GF6.GF6"}, {"GF7", "GF7.GF7"}}
Local nForGF    := 0
Local aAreaOld  := GetArea()
Local cQry      := ""

For nForGF := 1 To Len(aAliasGF)
	cQry += IIF(nForGF > 1, "UNION ", "") + " SELECT E1_NATUREZ, E1_TIPO, E1_PEDIDO, E1_NUM "
	cQry += " FROM " + RetSqlName(aAliasGF[nForGF, 1]) + " " + aAliasGF[nForGF, 1] + " "
	cQry += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + aAliasGF[nForGF, 2] + "_NRSEQG AND GCZ.GCZ_NRFATU <> '" + SPACE(Len(GCZ->GCZ_NRFATU))+ "' "
	cQry += "        AND GCZ.GCZ_FILFAT = '" + IIF(Empty(xFilial("GCZ")), IIF(FindFunction("FWSizeFilial"),space(FWSizeFilial()),"  "), cFilAnt) + "' AND GCZ.D_E_L_E_T_ <> '*' "
	If HS_ExisDic({{"C", aAliasGF[nForGF, 1] + "_FILATE"}}, .F.)
		cQry += " AND GCZ.GCZ_FILATE = " + aAliasGF[nForGF, 2] + "_FILATE "
	EndIf
	cQry += " JOIN " + RetSqlName("SE1") + " SE1 ON SE1.E1_PREFIXO = GCZ.GCZ_SERIE AND SE1.E1_NUM = GCZ.GCZ_NRFATU "
	cQry += "        AND SE1.E1_TIPO = GCZ.GCZ_TPNOTA AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' "
	cQry += " WHERE " + aAliasGF[nForGF, 2] + "_FILIAL  = '" + xFilial(aAliasGF[nForGF, 1]) + "' AND " + aAliasGF[nForGF, 1] + ".D_E_L_E_T_ <> '*' "
	cQry += " AND " + aAliasGF[nForGF, 2] + "_NREXTC = '" + cNrExtC + "' "
Next

cQry := ChangeQuery(cQry)

dbUseArea(.t.,"TOPCONN",TcGenQry(,,cQry),"TRB",.f.,.f. )

DBGotop()

If !EOF()
	cNatureza := TRB->E1_NATUREZ
	cTipo     := TRB->E1_TIPO
	cPedido   := TRB->E1_PEDIDO
	cNum						:= TRB->E1_NUM
EndIf

dbCloseArea()

RestArea(aAreaOld)

Return({cNatureza, cTipo, cPedido, cNum})

Function HS_VldNatu()
Local lRet := .T.

If FS_RDadTit(M->GE0_NUMEXT)[2] == PADR("NF", Len(SE1->E1_TIPO))
	HS_MsgInf(STR0147, STR0065, STR0148) //"Nใo ้ possivel alterar a natureza pois o Tํtulo gerado ้ do tipo NF"###"Aten็ใo"###"Valida็ใo Natureza"
	Return(.F.)
EndIf

dbSelectArea("SED")
dbSetOrder(1)
If !(lRet := DbSeek(xFilial("SED") + M->GE0_NATURE))
	Help(" ",1,"E1_NATUREZ")
EndIf

Return(lRet)

Function FS_RValImp(cNumExt, nValBase, cNatureza)
Local nValImp   := 0
Local cParc     := ""
Local cFilGCZ   := IIF(lFilFat, cFilAnt, xFilial("GCZ"))
Local aAreaOld  := GetArea()

//Variaveis para simular o valid do campo E1_NATUREZ - FA040Natur()
Private lF040Auto := .F.
Private lAltera 	:= .F.
Private nIndexSE1	:= ""
Private cIndexSE1	:= ""
PRIVATE aDadosRet := Array(6)
PRIVATE nVlRetPis	:= 0
PRIVATE nVlRetCof := 0
PRIVATE nVlRetCsl	:= 0
PRIVATE nVlRetIRF := 0
PRIVATE nVlOriCof := 0
PRIVATE nVlOriCsl	:= 0
PRIVATE nVlOriPis := 0

DbSelectArea("GCZ")
DbSetOrder(IIF(lFilFat, 25,5))
If DbSeek(cFilGCZ + cNumExt)
	cParc := FS_RetUPrc(GCZ->GCZ_SERIE, GCZ->GCZ_NRFATU, GCZ->GCZ_TPNOTA)
	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	DbSeek(xFilial("SE1") + GCZ->GCZ_SERIE + GCZ->GCZ_NRFATU + PADR(cParc, Len(SE1->E1_PARCELA)) + GCZ->GCZ_TPNOTA)
EndIf

RegToMemory("SE1", .F.)
M->E1_VALOR		:= nValBase
M->E1_NATUREZ := cNatureza

dbSelectArea("SED")
dbSetOrder(1)
DbSeek(xFilial("SED") + cNatureza)

FA040Natur()

//	nValImp := Round(M->E1_IRRF + M->E1_ISS	 + M->E1_INSS + M->E1_CSLL + M->E1_PIS + M->E1_COFINS, 2)
nValImp := Round(M->E1_IRRF + M->E1_ISS + M->E1_INSS + M->E1_CSLL + M->E1_PIS + M->E1_COFINS, GetMv("MV_RNDPREC"))

RestArea(aAreaOld)
Return(nValImp)

Static Function FS_REAPSUS()
Local aArea		:= GetArea()
Local nG		:= 0
Local cSql		:= ""
Local cCnvSUS  	:= GetMV("MV_PCONSUS",,"")

If !HS_ExisDic({{"C", "GCZ_NRGGLO"}}, .F.)
	Return(Nil)
EndIf

For nG := 1 To Len(aGReap)
	If aGReap[nG,2] == cCnvSUS .AND. HS_CountTB("GCZ", "GCZ_NRGGLO = '" + aGReap[nG,1] + "' ") == 0
		cSql := " SELECT 1 FROM " + RetSqlName("GF7") + " GF7"
		cSql += " JOIN " + RetSqlName("GDM") + " GDM ON GDM_CODIGO  =  GF7.GF7_CDMGLO AND GDM_TIPO = '3'"
		cSql += " AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
		cSql += " WHERE GF7_NRSEQG = '" + aGReap[nG,1] + "' "
		cSql += " AND GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.D_E_L_E_T_ <> '*' "
		
		TCQUERY ChangeQuery(cSQL) NEW ALIAS "TMPGF7"
		
		DbSelectArea("TMPGF7")
		If !Eof()
			FS_CRIAGUIA(aGReap[nG,1])
		Else
			cSql := " SELECT 1 FROM " + RetSqlName("GF5") + " GF5"
			cSql += " JOIN " + RetSqlName("GDM") + " GDM ON GDM_CODIGO  =  GF5.GF5_CDMGLO AND GDM_TIPO = '3'"
			cSql += " AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
			cSql += " WHERE GF5_NRSEQG = '" + aGReap[nG,1] + "' "
			cSql += " AND GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' "
			
			TCQUERY ChangeQuery(cSQL) NEW ALIAS "TMPGF5"
			
			DbSelectArea("TMPGF5")
			If !Eof()
				FS_CRIAGUIA(aGReap[nG,1])
			Else
				cSql := " SELECT 1 FROM " + RetSqlName("GF6") + " GF6"
				cSql += " JOIN " + RetSqlName("GDM") + " GDM ON GDM_CODIGO  =  GF6.GF6_CDMGLO AND GDM_TIPO = '3'"
				cSql += " AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
				cSql += " WHERE GF6_NRSEQG = '" + aGReap[nG,1] + "' "
				cSql += " AND GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.D_E_L_E_T_ <> '*' "
				
				TCQUERY ChangeQuery(cSQL) NEW ALIAS "TMPGF6"
				
				DbSelectArea("TMPGF6")
				If !Eof()
					FS_CRIAGUIA(aGReap[nG,1])
				EndIf
				DbSelectArea("TMPGF6")
				DbCloseArea()
			EndIf
			DbSelectArea("TMPGF5")
			DbCloseArea()
		EndIf
		DbSelectArea("TMPGF7")
		DbCloseArea()
	EndIf
Next nG

RestArea(aArea)
Return()

Static Function FS_CRIAGUIA(cNrSeqG)
Local aArea		:= GetArea()
Local bCampo	:=	{|nCpo| Field(nCpo)}
Local nCont		:= 0
Local cNovGuia	:= ""
Local aDespGE7	:= {}
Local aDespGE6	:= {}
Local aDespGE5	:= {}

DbSelectArea("GCZ")
DbSetOrder(1) // GD3_FILIAL + GD3_CODTAB + GD3_CODTXC + DTOS(GD3_DATVIG)
Begin Transaction
If DbSeek(xFilial("GCZ") + cNrSeqG)
	
	DbSelectArea("GCZ")
	RegToMemory("GCZ", .F.)
	
	RecLock("GCZ", .T.)
	
	M->GCZ_NRSEQG 	:= CriaVar("GCZ_NRSEQG")
	M->GCZ_NRSEQG 	:= HS_VSxeNum("GCZ", "M->GCZ_NRSEQG", 1)
	cNovGuia 		:= M->GCZ_NRSEQG
	For nCont := 1 To FCount()  // Copia dados do registro original
		If "FILIAL" $ Field(nCont)
			FieldPut(nCont, xFilial("GCZ"))
		Else
			FieldPut(nCont, M->&(Eval(bCampo, nCont)))
		EndIf
	Next nCont
	
	// Atribui novos valores
	GCZ->GCZ_NRGGLO := cNrSeqG
	GCZ->GCZ_NRLOTE := Space(TamSx3("GCZ_NRLOTE")[1])
	GCZ->GCZ_NREXTC := Space(TamSx3("GCZ_NREXTC")[1])
	GCZ->GCZ_STATUS := "1"
	GCZ->GCZ_VALPAG := 0
	GCZ->GCZ_VALGLO := 0
	GCZ->GCZ_VLPAGM := 0
	GCZ->GCZ_VLGLOM := 0
	GCZ->GCZ_VLPAGT := 0
	GCZ->GCZ_VLGLOT := 0
	GCZ->GCZ_VLPAGP := 0
	GCZ->GCZ_VLGLOP := 0
	GCZ->GCZ_VALREC := 0
	GCZ->GCZ_VALPER := 0
	GCZ->GCZ_VLRECM := 0
	GCZ->GCZ_VLPERM := 0
	GCZ->GCZ_VLRECT := 0
	GCZ->GCZ_VLPERT := 0
	GCZ->GCZ_VLRECP := 0
	GCZ->GCZ_VLPERP := 0
	MsUnLock()
EndIf

FS_REPDESP("GD7",cNrSeqG,cNovGuia)
FS_REPDESP("GD5",cNrSeqG,cNovGuia )
FS_REPDESP("GD6",cNrSeqG,cNovGuia)

End Transaction

RestArea(aArea)
Return()

Static Function FS_REPDESP(cAlias,cNrSeqG,cNovaGuia)
Local aArea		:= GetArea()
Local bCampo	:=	{|nCpo| Field(nCpo)}
Local cAliasTmp	:=  "TMP" + cAlias
Local aDesp		:= {}
Local nL		:= 0
Local nCont		:= 0


cSql := " SELECT " + cAlias + "_SEQDES FROM " + RetSqlName(cAlias) + " " + cAlias
cSql += " WHERE " + cAlias + "_NRSEQG = '" + cNrSeqG + "' "
cSql += " AND " + cAlias + "." + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' "

TCQUERY ChangeQuery(cSQL) NEW ALIAS "TMPDESP"

DbSelectArea("TMPDESP")
While !Eof()
	AADD(aDesp, &("TMPDESP->" + cAlias + "_SEQDES"))
	DbSkip()
End
DbSelectArea("TMPDESP")
DbCloseArea()

If Len(aDesp) > 0
	For nL := 1 To Len(aDesp)
		DbSelectArea(cAlias)
		DbSetOrder(1)
		If DbSeek(xFilial(cAlias) + aDesp[nL])
			
			DbSelectArea(cAlias)
			RegToMemory(cAlias, .F.)
			
			RecLock(cAlias, .T.)
			
			&("M->" + cAlias + "_SEQDES")	:= CriaVar(cAlias + "_SEQDES")
			&("M->" + cAlias + "_SEQDES") 	:= HS_VSxeNum(cAlias, "M->" + cAlias + "_SEQDES", 1)
			
			For nCont := 1 To FCount()  // Copia dados do registro original
				If "FILIAL" $ Field(nCont)
					FieldPut(nCont, xFilial(cAlias))
				Else
					FieldPut(nCont, M->&(Eval(bCampo, nCont)))
				EndIf
			Next nCont
			
			// Atribui novos valores
			&(cAlias + "->" + cAlias + "_NRSEQG") := cNovaGuia
			/*&(cAlias + "->" + cAlias + "_NREXTC") := Space(TamSx3("GE7_NREXTC")[1])
			&(cAlias + "->" + cAlias + "_VALPAG") := 0
			&(cAlias + "->" + cAlias + "_VALREC") := 0
			&(cAlias + "->" + cAlias + "_VALPER") := 0
			&(cAlias + "->" + cAlias + "_VALGLO") := 0
			&(cAlias + "->" + cAlias + "_VLRGLO") := 0
			&(cAlias + "->" + cAlias + "_VLRREC") := 0	*/
			MsUnLock()
		EndIf
	Next nL
EndIf


RestArea(aArea)
Return()
