#INCLUDE "HSPAHA80.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA80  บ Autor ณ Robson Ramiro Oliv.บ Data ณ  24/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Controle para localizacao de contas (Atendimentos)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA80()

Local aCposMB := {}
Local bKeyF12 := SetKey(VK_F12, {|| HS_FILHA80(.F., .T.)})

Private __aMarkBrow := {} // Usado na funcao de marca็ใo e desmarca็ao da MarkBrowse
Private lFilGm1     := .T. // Nao retirar essa variavel, esta sendo utilizada para validar o setor na funcao HS_VLDCSET no fonte HSPFUNCA.PRW, ESTA SENDO CHAMADA DO X1_VALID DO GRUPO DE PERGUNTAS HSP80A, 1a pergunta.

Private aCores := {{"GCZ->GCZ_STATUS == '0'", 'BR_VERDE'   },;
                   {"GCZ->GCZ_STATUS == '1'",	'BR_VERMELHO'}}

Private aRotina, cCadastro
Private cPerg1		:= "HSP80A"
Private cCodConv	:= ""
Private cCodPla		:= ""
Private cGuiaIni	:= ""
Private cCodLoc		:= ""
Private cGcyAtendi	:= ""
Private dDtAteIni	:= Ctod("  /  /  ")
Private dDtAteFin	:= Ctod("  /  /  ")
Private nTpAtend	:= 0
Private nTpGuia		:= 0
Private dDtLimite	:= Ctod("  /  /  ")
Private nStatus		:= 0
Private cFilA80		:= ""
Private cMarca		:= GetMark()
Private oMB
Private lMarkALL	:= .T.

aRotina := {{OemtoAnsi(STR0001), "axPesqui"                        , 0, 1},;	//"Pesquisar"
            {OemToAnsi(STR0002), "axVisual('GCZ',GCZ->(Recno()),2)", 0, 2},;	//"Visualizar"
            {OemToAnsi(STR0003), "HS_A80Roti(1)"                   , 0, 2},;	//"Ctrl. Contas"
            {OemToAnsi(STR0004), "HS_A80Roti(2)"                   , 0, 2},;	//"Ctrl. Faturamento" 
            {OemtoAnsi(STR0092), "HS_HA80GUI"                      , 0, 2},;	//"Alterar" 
            {OemtoAnsi(STR0093), "HS_HA80GUI"                      , 0, 2},;	//"Guias" 
            {OemToAnsi(STR0040), "HS_A80Roti(3)"                   , 0, 2},;	//"Impressao"
            {OemtoAnsi(STR0005), "HS_A80Lege"                      , 0,	1}}		//"Legenda"

cCadastro := STR0006 //"Controle de Localiza็ใo de Contas"

If !Pergunte(cPerg1,.T.)
	Return()
EndIf

cCodLoc   := mv_par01
cCodConv  := mv_par02
cCodPla   := mv_par03
cGuiaIni  := mv_par04
cGuiaFin  := mv_par05
dDtAteIni := mv_par06
dDtAteFin := mv_par07
nTpAtend  := mv_par08
nTpGuia   := mv_par09
nStatus   := mv_par10

FS_Filtro(.F.)  //Monta o filtro

aAdd(aCposMB, { "GCZ_IDMARC",, "", "" })
aAdd(aCposMB, { HS_CfgSx3("GCZ_REGATE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_REGATE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_REGATE")[SX3->(FieldPos("X3_PICTURE"))] })
aAdd(aCposMB, { HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_PICTURE"))] })


DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
DbSeek("GCZ")
While !Eof() .And. SX3->X3_ARQUIVO == "GCZ"
	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. SX3->X3_CONTEXT <> "V" .And. ;
		aScan(aCposMB, {| aVet | SX3->X3_CAMPO == aVet[1]}) == 0
		aAdd(aCposMB, { SX3->X3_CAMPO,, SX3->X3_TITULO, SX3->X3_PICTURE })
	EndIf
	
	DbSkip()
End

dbSelectArea("GCZ")
dbSetOrder(1) //GCZ_FILIAL + GCZ_NRSEQG + GCZ_STATUS 

MarkBrowse("GCZ","GCZ_IDMARC",,aCposMB,.F.,cMarca,"BRHSPAHA80(.F.,cFilA80)",,,,,{|| oMB := GetMarkBrow(), oMB:bMark := {|| Fs_GetMark()}, oMB:bAllMark := {|| BRHSPAHA80(.T.,cFilA80)} }, cFilA80, .T., aCores)

SetKey(VK_F12, bKeyF12)
Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A80Rotiบ Autor ณ                    บ Data ณ  23/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para montagem do browse de sele็ใo de contas        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A80Roti(nOpc)
Local oDlg
Local nOpcA	    		:= 0
Local nFor		    		:= 0
Local	cGB3_NRPROT	:= Space(Len(GB3->GB3_NRPROT))
Local aArea							:= GetArea()
Local cUserRec				:= Space(15)
Local nCont       := 0
Local cNrProt     := 0
Local cRegAlt     := ""
Local cRegSol     := ""
Local nGuiaAtu    := 0
Local nGuiaTot    := Len(__aMarkBrow)
Local cMsgDesp    := ""

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

If nOpc == 3 // Impressao
	If ! MsgYesNo(STR0078, STR0010) //"Confirma Relatorio ?"###"Aten็ใo"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)   
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE) 
		Return(nil)
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("") From 00, 00 to 08, 80 of oMainWnd
	
	@ 040, 010 Say OemToAnsi(STR0037) OF oDlg PIXEL COLOR CLR_RED //"Nro. Protocolo"
	@ 040, 060 MSGet o01 var cGB3_NRPROT Valid FS_VldNC(cGB3_NRPROT) F3 "GB3" OF oDlg PIXEL COLOR CLR_BLACK
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, oDlg:End()}, {|| nOpcA := 0, oDlg:End()})
	
	If nOpcA == 1
		If GB3->GB3_TIPTRF == "0"
			RlTransf(cGB3_NRPROT, STR0008, STR0004) //"Ctrl. Contas"###"Ctrl. Faturamento"
		Else
			RlTransf(cGB3_NRPROT, STR0004, STR0008) //"Ctrl. Faturamento"###"Ctrl. Contas"
		Endif
	Endif
Else
	If ! MsgYesNo(STR0079, STR0010) //"Confirma Transferencia de Contas ?"###"Aten็ใo"
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.) 
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE) 
		Return(nil)
	EndIf
	
	ProcRegua(nGuiaTot)
	
	Begin Transaction
	
	DbSelectArea("GB3")
	M->GB3_NRPROT := HS_VSxeNum("GB3", "M->GB3_NRPROT", 1)
	ConfirmSx8()
	
	For nGuiaAtu := 1 To nGuiaTot
		
		If Alias() <> "GCZ"
			DBSelectArea("GCZ")
		EndIf
		
		If IndexOrd() <> 1
			DBSetOrder(1)
		EndIf
		
		DBSeek(xFilial("GCZ") + __aMarkBrow[nGuiaAtu][1])
		
		IncProc(STR0086 + GCZ->GCZ_NRSEQG + "]") //"Aguarde, transferindo guia ["
		
		If GCZ->GCZ_REGATE <> GCY->GCY_REGATE
			DbSelectArea("GCY")
			DbSetOrder(1) //GCY_FILIAL + GCY_REGATE
			DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
			cGcyAtendi := GCY->GCY_ATENDI
		EndIf
		
		If !((nOpc == 1 .And. GCZ->GCZ_STATUS == "0") .Or. ; //Ctrl Contas
			(nOpc == 2 .And. GCZ->GCZ_STATUS == "1"))
			Loop
		ElseIf	 nOpc == 1
			If !(HS_VldTran(@cRegSol, @cRegAlt, @cMsgDesp))
				Loop
			EndIf
		Endif
		
		DbSelectArea("GCZ")
		RecLock("GCZ", .F.)
		GCZ->GCZ_STATUS := Iif(nOpc == 1, "1", "0")
		GCZ->GCZ_DATSTA := dDataBase
		GCZ->GCZ_NRPROT := M->GB3_NRPROT
		GCZ->GCZ_LOGARQ := HS_LOGARQ()
		MsUnlock()
		
		HS_VlTxSer('GD6', GCZ->GCZ_NRSEQG)
		
		nCont++
		
	Next
	
	If nCont > 0
		DbSelectArea("GB3")
		RecLock("GB3", .T.)
		GB3->GB3_FILIAL	:= xFilial("GB3")
		GB3->GB3_NRPROT	:= M->GB3_NRPROT
		GB3->GB3_DATPRO	:= dDataBase
		GB3->GB3_USEREN	:= cUserName
		GB3->GB3_USERRE	:= cUserRec
		GB3->GB3_TIPTRF := IIf(nOpc == 1, "0", "1")
		GB3->GB3_LOGARQ	:= HS_LOGARQ()
		MsUnLock()
		
	EndIf
	DbSelectArea("GCZ")
	
	End Transaction
	
	If !Empty(cRegSol)
		HS_MsgInf(cRegSol, STR0010, STR0085) //"Os atendimentos ["###"] nใo podem ser enviados para o faturamento porque possuem solicita็๕es de materiais e medicamentos em aberto"###"Atencao"
	EndIf
	If !Empty(cRegAlt)
		HS_MsgInf(cRegAlt, STR0010,STR0085) //"Os atendimentos ["###"] nao podem ser enviado para o faturamento porque nao tiveram alta"###"Atencao"
	EndIf
	If !Empty(cMsgDesp)
		HS_MsgInf(cMsgDesp, "Aten็ใo", "Valida็ใo de guia")
	EndIf
	
	HS_MMarkB(@__aMarkBrow, cFilA80, .T.) // Desmarca Guias
	
	If nCont > 0
		If nOpc == 1
			RlTransf(GB3->GB3_NRPROT, STR0008, STR0004) //"Ctrl. Contas"###"Ctrl. Faturamento"
		Elseif nOpc == 2
			RlTransf(GB3->GB3_NRPROT, STR0004, STR0008) //"Ctrl. Faturamento"###"Ctrl. Contas"
		Endif
	EndIf
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE) 

RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A80Lege บ Autor ณ Rogerio Faro      บ Data ณ  24/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para exibi็ใo das Legendas                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A80Lege()

BrwLegenda(cCadastro, STR0005, {	{'BR_VERDE'   ,	STR0008},;		//"Legenda"###"Controle de Contas"
									{'BR_VERMELHO',	STR0004}})		//"Ctrl. Faturamento"
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RlTransf บ Autor ณ Rogerio Faro       บ Data ณ  24/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina par impressใo do Relatorio de transfer๊ncia         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function RlTransf(cGB3_NRPROT, aTit1, aTit2)
Local cDesc1         := STR0019 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0020 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0021 //"Transferencia de Contas"
Local cPict          := ""
Local titulo         := STR0022 + aTit1 + STR0023 + aTit2 + STR0038 + cGB3_NRPROT //"Tranferencia do "###" para o "###" Nro. Protocolo "
//         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//Nome                                           Registro  Data      Hora   Tp. Atend                Medico                          Plano                             Tp. Guia                          Nro Guia               Sequencia

Local nLin           := 80
Local Cabec1         := STR0024 //"Nome                                           Registro  Data      Hora    Tp. Atend           Medico                       Plano                           Tp. Guia                        Nro Guia          Sequencia"
Local Cabec2         := ""      
Local imprime        :=  .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "G"
Private nomeprog     := "HSPAHA80"
Private nTipo        := 15
Private aReturn      := { STR0025, 1, STR0026, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHA80"
Private cString      := "GCZ"
Private cPerg        := "HSPA80"

If !Pergunte(cPerg,.T.)
	Return
Endif

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,cGB3_NRPROT) },Titulo)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ ROGERIO FARO       บ Data ณ  25/09/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,cGB3_NRPROT)
Local nOrdem
Local I,P
Local aRegAte := {}
Local cCodCon := ""

SetRegua(RecCount())

If MV_PAR03==1
	Cabec2:=STR0082
EndIf

DbSelectArea("GCZ")
DbSetOrder(7) //GCZ_FILIAL + GCZ_NRPROT
DbSeek(xFilial("GCZ") + cGB3_NRPROT)

Do While !Eof() .and. xFilial("GCZ") == GCZ->GCZ_FILIAL .and. cGB3_NRPROT == GCZ->GCZ_NRPROT
	GCY->(DbSetOrder(1))
	GCY->(DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE))
	
	If GCZ->GCZ_CANCEL == '1'
		dbSkip()
		Loop
	EndIf
	
	aAdd(aRegAte, {GCZ->GCZ_CODCON, GCY->GCY_NOME, GCZ->GCZ_REGATE, GCY->GCY_DATATE, GCY->GCY_HORATE, GCY->GCY_ATENDI, GCY->GCY_CODCRM, GCZ->GCZ_CODPLA, GCZ->GCZ_CODTPG, GCZ->GCZ_NRGUIA, GCZ->GCZ_NRSEQG})
	
	DbSelectArea("GCZ")
	
	DbSkip()
End

If MV_PAR02 == 1
	aSort(aRegAte,,,{|x,y| x[1]+X[3] < y[1]+Y[3]})
Elseif MV_PAR02 == 2
	aSort(aRegAte,,,{|x,y| x[1]+X[2] < y[1]+Y[2]})
Elseif MV_PAR02 == 3
	aSort(aRegAte,,,{|x,y| x[3]+X[2] < y[3]+Y[2]})
Elseif MV_PAR02 == 4
	aSort(aRegAte,,,{|x,y| x[2] < y[2]})
Elseif MV_PAR02 == 5
	aSort(aRegAte,,,{|x,y| x[1]+X[8] < y[1]+Y[8]})
Endif

For P := 1 to MV_PAR01
	I := 1
	
	For I := 1 to Len(aRegate)
		
		If lAbortPrint
			@nLin,00 PSAY STR0027 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		
		If I == 1
			nLin := nLin + 1
			@nLin,00 PSAY STR0047 + AllTrim(Str(Len(aRegAte))) //"Total de atendimentos do protocolo : "
			nLin := nLin + 2
		EndIf
		
		IF MV_PAR02 == 1  .OR. MV_PAR02 == 2
			if cCodCon <> aRegAte[I,1]
				nLin := nLin + 1
				@nLin,00 PSAY aRegAte[I,1] + "-" + POSICIONE("GA9",1, XFILIAL("GA9") + aRegAte[I,1], "GA9_NOME")
				nLin := nLin + 1
			Endif
		ENDIF
		
		@nLin,00 PSAY aRegAte[I,2]
		@nLin,47 PSAY aRegAte[I,3]
		@nLin,56 PSAY aRegAte[I,4]
		@nLin,68 PSAY aRegAte[I,5]
		@nLin,75 PSAY HS_RDescrB("GCY_ATENDI", aRegAte[I,6])
		@nLin,98 PSAY HS_INIPADR("SRA",  11, aRegAte[I,7], "RA_NOME",, .F.)
		@nLin,128 PSAY Substr (HS_INIPADR("GCM", 2 , aRegAte[I,8], "GCM_DESPLA",, .F. ),1,28)
		@nLin,156 PSAY Substr (HS_INIPADR("GCU", 1 , aRegAte[I,9] , "GCU_DESTPG",, .F. ), 1, 28)
		@nLin,184 PSAY aRegAte[I,10]
		@nLin,208 PSAY aRegAte[I,11]
		
		If MV_PAR03==1
			
			nlin++
			
			DbSelectArea("GD7")
			DbSetOrder(3)  //GD7_FILIAL+GD7_REGATE+GD7_NRSEQG+GD7_CODDES+GD7_CODATO+GD7_SEQGE7
			DbSeek(xFilial("GD7") + aRegAte[I,3] + aRegAte[I,11])
			
			Do While !Eof() .and. xFilial("GD7") == xFilial("GCZ") .and. GD7->GD7_REGATE == aRegAte[I,3] .And.  GD7_NRSEQG== aRegAte[I,11]
				
				@nLin, 10 PSAY GD7->GD7_CODDES
				@nLin, 25 PSAY HS_INIPADR("GA7", 1 , GD7->GD7_CODDES , "GA7_DESC",, .F. )
				@nLin, 80 PSAY TRANSFORM(GD7->GD7_QTDDES,"@E 99,999.9999")
				nlin++
				
				If nLin > 55
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif
				
				DbSkip()
			End
		EndIf
		
		IIf(nLin>=9,nLin+=2,nil)
		
		IF MV_PAR02 == 1 .OR. MV_PAR02 == 2
			cCodCon := aRegAte[I,1]
		ENDIF
		
	Next
	
	nLin := 80
	@058,40 PSAY "_____________________________________"
	nLin := nLin + 1
	@059,40 PSAY STR0035 //"      Assinatura do Responsavel"
Next

SET DEVICE TO SCREEN

If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldNC  บ Autor ณ                    บ Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida protocolo                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldNC(cGB3_NRPROT)
Local lRet

DbSelectArea("GB3")
DbSetOrder(1) //GB3_FILIAL + GB3_NRPROT
If !(DbSeek(xFilial("GB3") + cGB3_NRPROT))
	HS_MsgInf(STR0039, STR0010,STR0087) //"Protocolo nใo encontrado"###"Atencao"###"Protocolo"
	lRet := .F.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณ FS_FILTROณ Autor ณGilson da Silva        ณ Data ณ03/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Monta o Filtro para a Tabela GCZ                									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ EXPC1 = Filtro                                  									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Filtro                                     														  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSPAHP12 											                                    	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Filtro(lDesativa)

cFilA80 := "GCZ_FILIAL = '" + xFilial("GCZ")+"' AND D_E_L_E_T_ <> '*' "

If !lDesativa
	If !Empty(cCodConv)
		cFilA80 := cFilA80 + " And GCZ_CODCON = '" + cCodConv + "'"
	EndIf
	
	If !Empty(cCodPla)
		cFilA80 := cFilA80 + " And GCZ_CODPLA = '" + cCodPla + "'"
	EndIf
	
	If !Empty(cGuiaIni)
		cFilA80 := cFilA80 + " And GCZ_NRSEQG >= '" + cGuiaIni + "'"
	EndIf
	
	If !Empty(cGuiaFin)
		cFilA80 := cFilA80 + " And GCZ_NRSEQG <= '" + cGuiaFin + "'"
	EndIf
	
	cFilA80 += " And GCZ_CANCEL <> '1'"
	
	If !Empty(nTpGuia)
		cFilA80 := cFilA80 + " And GCZ_CODTPG = '" + nTpGuia + "'"
	EndIf
	
	If  nStatus == 1 // Localizacao de Contas, visualiza todas as guias com status 0
		cFilA80 += " AND GCZ_STATUS = '0' "
	ElseIf nStatus == 2 // Faturamento
		cFilA80 += " AND GCZ_STATUS = '1' "
	ElseIf nStatus == 3 // AMBOS
		cFilA80 += " AND GCZ_STATUS IN ('0', '1') "
	EndIf
	
	cFilA80 += " AND GCZ_DATATE BETWEEN '" + Dtos(dDtAteIni) + "' AND '" + Dtos(dDtAteFin) + "'"
	
	If !Empty(cCodLoc)
		cFilA80 += " AND GCZ_LOCATE = '" + cCodLoc + "'"
	EndIf
	
	If  nTpAtend == 1 // Hospitalar, nao respeita o Controle de Localizacao de Contas, visualiza todas as guias com status 0, 1 e 2.
		cFilA80 += " AND GCZ_ATENDI = '0' "
	ElseIf nTpAtend == 2 // Ambulatorio/Pre Atendimento
		cFilA80 += " AND GCZ_ATENDI IN ('1', '2') "
	EndIf
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณHS_FILHA80ณ Autor ณGilson da Silva        ณ Data ณ25/02/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Chama o  Grupo de perguntas "HSP80A"                					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSPAHA80 											                                    	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_FILHA80(lDesativa, lPergunta)
//Local oObjMBrw := GetMarkBrow()

HS_MMarkB(@__aMarkBrow, cFilA80, .T.)

If Pergunte(cPerg1, lPergunta) .Or. !lPergunta
	cCodLoc   := mv_par01
	cCodConv  := mv_par02
	cCodPla   := mv_par03
	cGuiaIni  := mv_par04
	cGuiaFin  := mv_par05
	dDtAteIni := mv_par06
	dDtAteFin := mv_par07
	nTpAtend  := mv_par08
	nTpGuia   := mv_par09
	nStatus   := mv_par10
	
	FS_Filtro(lDesativa)
	
	oMB:oBrowse:ResetLen()
	GCZ->(DbClearFilter())
	SetMBTopFilter("GCZ",cFilA80,,.T.)
	oMB:oBrowse:GoTop()   
	dbSelectArea("GCZ")
	GCZ->(dbGoTop())
	oMB:oBrowse:Refresh()
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CtlDespบ Autor ณ Patricia Queiroz  บ Data ณ  21/08/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para preenchimento do campo Cod. Serv/Pri.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HS_A80Roti(1)                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                         
Function HS_CtlDesp(cSeqGuia)
Local aArea   := GetArea()
Local lRet    := .T., lMsg := .F.
Local cSql    := ""
Local cBlqPro := ""

If !EMPTY(GCZ->GCZ_CODDES) .OR. !HS_ExisDic( {{"C","GA9_BLQPRO"}} , .F. )
	RestArea(aArea)
	Return({lRet, lMsg})
EndIf

cBlqPro := HS_IniPadr("GA9", 1, GCZ->GCZ_CODCON, "GA9_BLQPRO") // o campo GA9_BLQPRO determina se emitirแ a mensagem e interromperแ o processamento ou se seguirแ

cSql := "SELECT GD7.GD7_NRSEQG, GD7.GD7_CODDES, GD7.GD7_VALDES, GD7.GD7_CODPRT "
cSql += "FROM " + RetSqlName("GD7") + " GD7 "
cSql += "WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_NRSEQG = '" + cSeqGuia + "' "
cSql += "ORDER BY GD7.GD7_VALDES DESC"

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRYGD7"

DbSelectArea("QRYGD7")
DbGoTop()

If !Eof()
	RecLock("GCZ", .F.)
	GCZ->GCZ_CODDES := QRYGD7->GD7_CODDES
	GCZ->GCZ_CODPRT := QRYGD7->GD7_CODPRT
	MsUnLock()
Else
	lMsg := .T.
	If cBlqPro == "1"
		lRet := .F.
	EndIf
EndIf

DbSelectArea("QRYGD7")
DbCloseArea()
RestArea(aArea)

Return({lRet, lMsg})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณHS_HA80GUIณ Autor ณ MARCELO JOSE          ณ Data ณ25/09/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ CHAMA NO HSPAHM24 A ALTERACAO DO ATENDIMENTO OU GUIAS				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01 - Alias do Arquivo       								                	  ณฑฑ
ฑฑณ          ณ ExpN02 - Nr. do registro                        									  ณฑฑ
ฑฑณ          ณ ExpN03 - Opcao Selecionada (Gerar Fatura ou Excluir)	   	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ GESTAO HOSPITALAR       						                          	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_HA80GUI(cAlias,nReg,nOpc)   //DESPESAS
Local aArea	:= GetArea()
Local cMovest := GETMV("MV_AUDMEST")

If !(HS_VldBrowse(oMb))
	Return(Nil)
EndIf
If nOpc == 6
	If Empty(cMovest)
		HS_MsgInf(STR0094, STR0010, STR0095)  //"Por favor, preencha o parametro MV_AUDMEST para validacao do estoque"###"Atencao"###"Despesas"
		Return(Nil)
	EndIf
EndIf

DbSelectArea("GCY")
DbSetOrder(1) //GCY_FILIAL + GCY_REGATE
If !dbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
	HS_MsgInf(STR0096, STR0010, STR0006) //"Nใo hแ registro de atendimento para esta guia. Chame o suporte."###"Aten็ใo"###"Controle de Localiza็ใo de Contas"
Else
	HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "P", IIF( nOpc == 6 , 7, 4 ) , GCY->GCY_CODLOC, GCZ->GCZ_NRSEQG}) // 7-Guias
EndIf

RestArea(aArea)
Return(Nil)

Function HS_VldTran(cRegSol, cRegAlt, cMsgDesp , lGerRepA)
Local aArea := GetArea()
Local lRet := .T.
Local cTpAltAM    := GETMV("MV_TPALTAM")
Local cTpAltPA    := GETMV("MV_TPALTPA")
Local aCtlDesp    := {}
Local lA80        := FunName() == "HSPAHA80"

Default lGerRepA := .F.

If Alias() <> "GCZ"
	DBSelectArea("GCZ")
EndIf

If HS_CountTB("GAI", "GAI_REGATE = '" + GCZ->GCZ_REGATE + "' AND GAI_FLGATE IN ('0', '1')") > 0
	cRegSol += STR0080 + " [" +GCZ->GCZ_REGATE	 + IIF(lA80, STR0088, STR0098) + chr(13)  + chr(10) //"O Atendimento "###"] nใo pode ser transferida pois possui solicita็๕es de materiais e medicamentos em aberto"###"] nใo pode ser faturada pois possui solicita็๕es de materiais e medicamentos em aberto"
	return(.F.)
Else
	
	aCtlDesp := HS_CtlDesp(GCZ->GCZ_NRSEQG)
	If aCtlDesp[2] .And. !aCtlDesp[1]
		cMsgDesp += STR0089 + " [" + GCZ->GCZ_NRSEQG + STR0090 + STR0091 + Chr(10)//"O c๓digo do servi็o principal para a guia ["###"] nใo estแ preenchido."###" Nใo ้ possํvel efetuar a transfer๊ncia."
	ElseIf aCtlDesp[2]
		cMsgDesp += STR0089 + " [" + GCZ->GCZ_NRSEQG + STR0090 + Chr(10)//"O c๓digo do servi็o principal para a guia ["###"] nใo estแ preenchido."
	EndIf
	
	If !aCtlDesp[1] .And. lA80                    // se for (.F.) nao executa a transferencia mas nao impede o processamento de
		return(.F.)                                  // outras guias ja selecionadas
	EndIf                                         // Bloqueia somente se for na localiza็ใo de contas(HSPAHA80)
	
	If GCZ->GCZ_ATENDI == "0" .AND. iIf(lGerRepA, .T., Empty(GCY->GCY_TPALTA))
		cRegAlt += STR0080 + " [" + GCZ->GCZ_REGATE + IIF(lA80, STR0081, STR0097)  + chr(13) //"O Atendimento "###"] nใo pode ser enviada para o faturamento porque nao teve alta"###"] nใo pode ser faturada porque nao teve alta"
		return(.F.)
	ElseIf  GCY->GCY_ATENDI $ "12" .AND. iIf(lGerRepA, .T., EMPTY(GCY->GCY_DATALT)) .AND. iIf(lGerRepA, .T., EMPTY(GCY->GCY_HORALT)) .AND. iIf(lGerRepA, .T., EMPTY(GCY->GCY_TPALTA))
		If !lGerRepA .AND. (Empty(cTpAltAM)  .AND. GCY->GCY_ATENDI = "1") .Or. (Empty(cTpAltPA)  .AND. GCY->GCY_ATENDI = "2")
			cRegAlt += STR0080 + " [" + GCZ->GCZ_REGATE + IIF(lA80, STR0081, STR0097) + chr(13)  //"O Atendimento "###"] nใo pode ser enviada para o faturamento porque nao teve alta"###"] nใo pode ser faturada porque nao teve alta"
			return(.F.)
		Else
			If GCY->GCY_ATENDI = "1" .and. !lGerRepA //Ambulatorio - da Alta
				RecLock("GCY", .F.)
				GCY->GCY_DATALT := GCY->GCY_DATATE
				GCY->GCY_HORALT := GCY->GCY_HORATE
				GCY->GCY_TPALTA := cTpAltAM
				MsUnlock()
			Else	//Pronto Atend.
				If !EMPTY(GCY->GCY_QUAINT) .AND. !EMPTY(GCY->GCY_LEIINT) // Da Alta , Saida e Libera Leito
					HS_GrvMovH(GCY->GCY_REGATE, GCY->GCY_CODLOC, GCY->GCY_QUAINT, GCY->GCY_LEIINT, "1", GCY->GCY_DATATE, GCY->GCY_HORATE, cTpAltPA)
					HS_GrvMovH(GCY->GCY_REGATE, GCY->GCY_CODLOC, GCY->GCY_QUAINT, GCY->GCY_LEIINT, "2", GCY->GCY_DATATE, GCY->GCY_HORATE)
					HS_GrvMovH("", GCY->GCY_CODLOC, GCY->GCY_QUAINT, GCY->GCY_LEIINT, "5", GCY->GCY_DATATE, GCY->GCY_HORATE)
				Else
					if !lGerRepA
						RecLock("GCY", .F.)
						GCY->GCY_DATALT := GCY->GCY_DATATE
						GCY->GCY_HORALT := GCY->GCY_HORATE
						GCY->GCY_TPALTA := cTpAltPA
						MsUnlock()
					endif
				EndIf
			EndIf
		EndIf
	Endif
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณHS_VlTxSerณ Autor ณ HEIMDALL CASTRO       ณ Data ณ04/10/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Calcula os valores das TAXAS DE SERVICO para MAT/MED e 		  ณฑฑ
ฑฑณ          ณ TAX/DIA                                              				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ GESTAO HOSPITALAR       						                          	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VlTxSer(cAlias, cNRSEQG)
Local aArea     := GetArea()
Local cTaxServ  := PADR(GetMV("MV_TXSERV"), Len(GD6->GD6_CODDES))
Local cSql      := ""
Local nValTot   := 0
Local aDadoGuia := {}, aRValTD   := {}
Local cAliasG5  := IIf(cAlias == 'GD6', 'GD5', 'GE5')
Local cPrefG5   := IIf(cAlias == 'GD6', 'GD5.GD5', 'GE5.GE5')
Local cPrefG6   := IIf(cAlias == 'GD6', 'GD6.GD6', 'GE6.GE6')
Local nOrdem    := IIF(cAlias == 'GD6', 5, 2)  //GD6_FILIAL + GD6_NRSEQG + GD6_CODDES + DTOS(GD6_DATDES)  //GE6_FILIAL + GE6_NRSEQG + GE6_CODDES
Local lDespExec := .F.
Local cCodLoc   := "", cCodDes := ""

cSql := "SELECT " + cPrefG6 + "_CODDES CODDES, " + cPrefG6 + "_DATDES DATDES "
cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + "                 
cSql += "WHERE " + cPrefG6 + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' "
cSql += "AND " + cPrefG6 + "_NRSEQG = '" + cNRSEQG + "' AND " + cPrefG6 + "_CODDES = '" + cTaxServ + "' " 

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRYDESP"

DbSelectArea("QRYDESP")
DbGoTop()

// verifica exce็ใo para a taxa do parametro, e se a despesa for igual a taxa do parametro utiliza a data de vigencia da despesa, senใo utiliza dDataBase
lDespExec := FS_ExcTxS(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, cTaxServ, GCZ->GCZ_NRSEQG, IIf(EOF(), dDataBase, STOD(QRYDESP->DATDES)), 'TXD')

If (!lDespExec)
	
	If !Empty(cTaxServ)
		cSql := ""
		cSql := " SELECT 'G5' TABELA, GCZ.GCZ_REGATE REGATE, " + cPrefG5 + "_CODLOC CODLOC, " + cPrefG5 + "_DATDES, " + cPrefG5 + "_SEQDES SEQDES, GCZ.GCZ_NRSEQG NRSEQG, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_CODPLA CODPLA, GCZ.GCZ_ATENDI ATENDI, "
		cSql += "	" + cPrefG5 + "_CODDES CODDES, " + cPrefG5 + "_QTDDES QUANT, " + cPrefG5 + "_VALDES VALOR, " + cPrefG5 + "_DATDES DATDES, GC1.GC1_DATVIG DATVIG, "
		cSql += " CASE GCZ.GCZ_ATENDI WHEN '0' THEN GC1.GC1_VRTSMI "
		cSql += " ELSE CASE GCZ.GCZ_ATENDI WHEN '1' THEN GC1.GC1_VRTSMA "
		cSql += " ELSE CASE GCZ.GCZ_ATENDI WHEN '2' THEN GC1.GC1_VRTSMA END END END TAXA "
		cSql += " FROM " + RetSqlName("GCZ") + " GCZ JOIN " + RetSqlName(cAliasG5) + " " + cAliasG5 + " ON " + cPrefG5 + "_NRSEQG = GCZ.GCZ_NRSEQG AND " + cAliasG5 + ".D_E_L_E_T_ <> '*' AND " + cPrefG5 + "_FILIAL = '" + xFilial(cAliasG5) + "' "
		cSql += "	JOIN " + RetSqlName("GC1") + " GC1 ON GC1.GC1_CODPLA = GCZ.GCZ_CODPLA AND GC1.D_E_L_E_T_ <> '*' AND GC1.GC1_FILIAL = '" + xFilial(cAliasG5) + "' "
		cSql += " WHERE GCZ.GCZ_NRSEQG = '" + cNRSEQG + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GC1.GC1_DATVIG = (SELECT MAX (GC1.GC1_DATVIG) FROM " + RetSqlName("GC1") + " GC1 "
		cSql += " WHERE GC1.GC1_DATVIG <= GCZ.GCZ_DATATE AND GCZ.GCZ_CODPLA = GC1.GC1_CODPLA ) "
		cSql += " UNION "
		cSql += " SELECT 'G6' TABELA, GCZ.GCZ_REGATE REGATE, " + cPrefG6 + "_CODLOC CODLOC, " + cPrefG6 + "_DATDES, " + cPrefG6 + "_SEQDES SEQDES, GCZ.GCZ_NRSEQG NRSEQG, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_CODPLA CODPLA, GCZ.GCZ_ATENDI ATENDI, "
		cSql	+= " " + cPrefG6 + "_CODDES CODDES, " + cPrefG6 + "_QTDDES QUANT, " + cPrefG6 + "_VALDES VALOR, " + cPrefG6 + "_DATDES DATDES, GC1.GC1_DATVIG DATVIG, "
		cSql += " CASE GCZ.GCZ_ATENDI WHEN '0' THEN GC1.GC1_VRTSDI "
		cSql += " ELSE CASE GCZ.GCZ_ATENDI WHEN '1' THEN GC1.GC1_VRTSDA "
		cSql += " ELSE CASE GCZ.GCZ_ATENDI WHEN '2' THEN GC1.GC1_VRTSDA END END END TAXA "
		cSql += " FROM " + RetSqlName("GCZ") + " GCZ JOIN " + RetSqlName(cAlias) + " " + cAlias + " ON " + cPrefG6 + "_NRSEQG = GCZ.GCZ_NRSEQG AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPrefG6 + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "	JOIN " + RetSqlName("GC1") + " GC1 ON GC1.GC1_CODPLA = GCZ.GCZ_CODPLA AND GC1.D_E_L_E_T_ <> '*' AND GC1.GC1_FILIAL = '" + xFilial("GC1") + "' "
		cSql += " WHERE GCZ.GCZ_NRSEQG = '" + cNRSEQG + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GC1.GC1_DATVIG = (SELECT MAX (GC1.GC1_DATVIG) FROM " + RetSqlName("GC1") + " GC1 "
		cSql += " WHERE GC1.GC1_DATVIG <= GCZ.GCZ_DATATE AND GCZ.GCZ_CODPLA = GC1.GC1_CODPLA ) "
		
		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "QRYCALC"
		
		DbSelectArea("QRYCALC")
		DbGoTop()
		
		While !EOF() //verifica se a despesa estแ em exce็ใo
			IIF(QRYCALC->TABELA == 'G5', lDespExec := FS_ExcTxS(QRYCALC->CODCON, QRYCALC->CODPLA, QRYCALC->CODDES, QRYCALC->NRSEQG, STOD(QRYCALC->DATDES), 'MAT'), lDespExec := FS_ExcTxS(QRYCALC->CODCON, QRYCALC->CODPLA, QRYCALC->CODDES, QRYCALC->NRSEQG, STOD(QRYCALC->DATDES), 'TXD'))
			If !lDespExec .And. !Empty(QRYCALC->TAXA) .And. QRYCALC->CODDES <> cTaxServ // se a despesa nใo estiver em exce็ใo e o percentual da taxa nao estiver vazio, calcula o valor da taxa/servico
				nValTot += ((QRYCALC->QUANT * QRYCALC->VALOR) * QRYCALC->TAXA) / 100
			EndIf
			cCodLoc := QRYCALC->CODLOC
			DbSkip()
		EndDo
		
		If nValTot > 0
			cPrefG6 := StrTran(cPrefG6, ".", "->")
			DbSelectArea(cAlias)
			DbSetOrder(nOrdem)
			
			If DbSeek(xFilial(cAlias) + cNrSeqG + cTaxServ) //verifica se existe algum dado para ser inserido na tabela de Tax/Dia
				RecLock(cAlias, .F.)
				&(cPrefG6 + "_QTDDES") := 1
				&(cPrefG6 + "_VALDES") := nValTot
				MsUnLock()
			ElseIf (aRValTD := HS_RValTD(cTaxServ, GCZ->GCZ_CODPLA, cCodLoc, .F., dDataBase))[1] == 0
				RecLock(cAlias, .T.)
				&(cPrefG6 + "_FILIAL") := xFilial(cAlias)
				&(cPrefG6 + "_SEQDES") := HS_VSXENUM(cAlias, "M->" + cAlias + "_SEQDES", 1) //GD6_FILIAL + GD6_SEQDES //GE6_FILIAL + GE6_SEQDES
				&(cPrefG6 + "_CODLOC") := cCodLoc
				&(cPrefG6 + "_DATDES") := dDataBase
				&(cPrefG6 + "_HORDES") := Time()
				&(cPrefG6 + "_QTDDES") := 1
				&(cPrefG6 + "_CODDES") := cTaxServ
				&(cPrefG6 + "_VALDES") := nValTot
				&(cPrefG6 + "_PCUDES") := aRValTD[3]
				&(cPrefG6 + "_GLODES") := IIf(aRValTD[4][1], "2", "0")
				&(cPrefG6 + "_CODKIT") := ''
				&(cPrefG6 + "_NRSEQG") := cNrSeqG
				&(cPrefG6 + "_REGATE") := GCZ->GCZ_REGATE
				&(cPrefG6 + "_FATPAR") := aRValTD[4][2]
				&(cPrefG6 + "_CODTXC") := aRValTD[7]
				&(cPrefG6 + "_DESTXC") := aRValTD[8]
				&(cPrefG6 + "_TABELA") := aRValTD[9]
				&(cPrefG6 + "_LOGARQ") := HS_LogArq()
				MsUnLock()
			Else
				HS_MsgInf(STR0099, STR0010, STR0100) //"Nใo foi possํvel lan็ar a despesa de taxa/diแria. Hแ irregularidades na configura็ใo da taxa/diแria."###"Aten็ใo"###"Valida็ใo de Taxa de Servi็o"
			EndIf
		EndIf
		
		DbSelectArea("QRYCALC")
		DbCloseArea()
		
	EndIf
EndIf

DbSelectArea("QRYDESP")
DbCloseArea()

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณHS_ExcTxS ณ Autor ณ HEIMDALL CASTRO       ณ Data ณ04/10/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Verifica se as despesas estao em excecao               		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                 								                	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ GESTAO HOSPITALAR       						                          	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ExcTxS(cCodCon, cCodPla, cCodDes, cNRSEQG, dDatVig, cOriDes)
Local aArea := GetArea()
Local lResp := .F.

If !Empty(cCodDes)
	If cOriDes == 'MAT'  // Mat/Med
		cCodDes := PadR(cCodDes, Len(SB1->B1_COD))
	ElseIf cOriDes == 'TXD' // Taxas / Diarias
		cCodDes := PadR(cCodDes, Len(GAA->GAA_CODTXD))
	EndIf
EndIf

If cOriDes == 'MAT' // quando a despesa for do tipo material
	
	If FS_VigExc(cCodCon, cCodPla, 'A', PADR(cCodDes, Len(GA4->GA4_CODDES)), dDatVig)[1] == .T.
		lResp := .T.
	Else
		DbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
		If DbSeek(XFilial("SB1") + cCodDes)
			cCodDes := SB1->B1_GRUPO
			If FS_VigExc(cCodCon, cCodPla, 'B', PADR(cCodDes, Len(GA4->GA4_CODDES)), dDatVig)[1] == .T.
				lResp := .T.
			EndIf
		EndIf
	EndIf
	
ElseIf cOriDes == 'TXD' //quando a despesa for do tipo taxa/diaria
	
	If FS_VigExc(cCodCon, cCodPla, 'C', PADR(cCodDes, Len(GA4->GA4_CODDES)), dDatVig)[1] == .T.
		lResp := .T.
	Else
		DbSelectArea("GAA")
		DbSetOrder(1) //GAA_FILIAL+GAA_CODTXD
		DbSeek(xFilial("GAA") + cCodDes)
		cCodDes := GAA->GAA_CODCTD
		DbSelectArea("SX5")
		DbSetOrder(1) //X5_FILIAL+X5_TABELA+X5_CHAVE
		If DbSeek(xFilial("SX5") + 'CT' + cCodDes)
			cCodDes := SX5->X5_CHAVE
			If FS_VigExc(cCodCon, cCodPla, 'D', PADR(cCodDes, Len(GA4->GA4_CODDES)), dDatVig)[1] == .T.
				lResp := .T.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(lResp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_GetMarkบAutor  ณDarcio R. Sporl     บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para verificar se ha dados no borwse, caso    บฑฑ
ฑฑบ          ณnao haja, o sistema executara o filtro novamente.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fs_GetMark()

If (HS_VldBrowse(oMb))
	HS_BMark(@__aMarkBrow)
Else
	oMB:oBrowse:ResetLen()
	GCZ->(DbClearFilter())
	SetMBTopFilter("GCZ",cFilA80,,.T.)
	oMB:oBrowse:GoTop()   
	dbSelectArea("GCZ")
	GCZ->(dbGoTop())
	oMB:oBrowse:Refresh()
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRHSPAHA80บAutor  ณTOTVS S/A           บ Data ณ  24/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para marcar/desmarcar itens do browse da GCZ  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function BRHSPAHA80(lDesmarca,cFiltroGCZ)
Local cFilMkBr    := ""
Local aAreaMBrw   := GetArea()
Default lDesmarca := .F. //Na inicializacao da tela desmarca tudo
Default cFiltroGCZ:= ""

cFilMkBr := "SELECT GCZ_NRSEQG, GCZ_REGATE, GCZ_FILATE,GCZ_IDMARC FROM " + RetSqlName("GCZ") + " WHERE " + cFiltroGCZ
cFilMkBr += " ORDER BY " + SqlOrder(GCZ->(IndexKey()))

TCQUERY cFilMkBr NEW ALIAS "QRYMRK"

While !QRYMRK->(Eof())

	GCZ->(dbSetOrder(1))
	If GCZ->(MsSeek(xFilial("GCZ")+QRYMRK->GCZ_NRSEQG))

		GCZ->(RecLock("GCZ",.F.))
		GCZ->GCZ_IDMARC := Iif(GCZ->GCZ_IDMARC == cMarca .Or. lDesmarca,Space(2),cMarca)
		GCZ->(msUnlock())
		aAdd(__aMarkBrow, {QRYMRK->GCZ_NRSEQG, QRYMRK->GCZ_REGATE,, QRYMRK->GCZ_FILATE})

	EndIf
	
	QRYMRK->(dbSkip())

EndDo

QRYMRK->(dbCloseArea())
oMB:oBrowse:GoTop()
RestArea(aAreaMBrw)
lMarkALL := !lMarkALL

Return