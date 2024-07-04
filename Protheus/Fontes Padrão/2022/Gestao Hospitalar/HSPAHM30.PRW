#INCLUDE "HSPAHM30.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM30  บ Autor ณ MARCELO JOSE       บ Data ณ  13/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ POSTO DE ENFERMAGEM                                        บฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM30()
Local bKeyF12       := SetKey(VK_F12, {|| FS_FilM30(.T.) } )
Private cFilM30     := ""
Private cPerg1      := "HSPM30"
Private cPerg2      := "HSPTRA"
Private cSetPerg    := "  "
Private lFilGm1     := .T.  /* SELECIONA FUNCIONARIO QUE PODE ENTRAR NO SETOR */
Private cGcsTipLoc  := "38" /* SELECIONA SETOR DE ENFERMAGEM E CIRURGICO      */
Private cGcsCodLoc  := ""
Private cNumSol     := ""
PRIVATE cGcyAtendi  := "0"
Private __cLOTECT   := Space(Len(GD5->GD5_LOTECT))
Private __cNUMLOT   := Space(Len(GD5->GD5_NUMLOT))
Private __cProAlt   := ""
Private __aProMov   := "HS_M30PROA(M->GD5_CODBAR)"
Private aCodUsr     := HS_VldDAnm(.F.)
Private __Reserv    := ""
Private cCadastro   := STR0001 //"MOVIMENTACAO DO POSTO DE ENFERMAGEM"
Private cGczCodPla  := ""
Private aRotRel     := {	{OemtoAnsi(STR0050),"HS_RELM30"  , 0, 2},; //"Docs/Relat."
							{OemtoAnsi(STR0133), 'HSPRQUES("GFK", "GFK_CDANAM", "","",GAV->GAV_REGATE,,,GAV->GAV_CODLOC)', 0, 2}} //"Anamnese
Private aRotina     := {	{OemtoAnsi(STR0002),"axPesqui"   , 0, 1},; //"Pesquisar"
							{OemtoAnsi(STR0003),"HS_M30ALT('GAV', GAV->(RecNo()), 2)", 0, 4},; //"Alta"  nOpc 4
							{OemtoAnsi(STR0004),"HS_M30SAI"  , 0, 3},; //"Saida"
							{OemtoAnsi(STR0005),"HS_M30LIB"  , 0, 3},; //"Libera Leito"
							{OemtoAnsi(STR0006),"HS_M30TRA"  , 0, 3},; //"Transferencia"
							{OemtoAnsi(STR0045),"HS_M30DES"  , 0, 4},;  //"Despesas" nOpc 4
							{OemtoAnsi(STR0009),"HS_M30CAL"  , 0, 3},; //"Cancela Alta"
							{OemtoAnsi(STR0010),"HS_M30CSA"  , 0, 3},; //"Cancela Saida"
							{OemtoAnsi(STR0043),"HSPAHM33"   , 0, 4},; //"Dieta do Paciente" nOpc 4
							{OemtoAnsi(STR0053),"HS_RNaM30"  , 0, 2},; //"RN"
							{OemtoAnsi(STR0055),"HS_PESMED"  , 0, 1},; //"Profissional"
							{OemtoAnsi(STR0068),"HS_MntM04('GAI', 0, 12)", 0, 3},; //"Sol. Mat/Med"
							{OemtoAnsi(STR0069),"HS_PESQSOL"  , 0, 2},; //"Cons. Solicita็ใo"
							{OemtoAnsi(STR0070),"HS_DEVSOL"  , 0, 2},; //"Dev. Solicita็ใo"
							{OemtoAnsi(STR0102), "HS_TriM30", 0, 4}, ;  //"Evolu็ใo" nOpc 4
							{OemtoAnsi(STR0050), aRotRel, 0, 2}, ;  //"Relatorios"
							{OemtoAnsi(STR0011),"HS_LegPos()", 0, 1},; //"Legenda"
							{OemtoAnsi(STR0110),"HSPAHM08(GAV->GAV_REGATE, GAV->GAV_RESERV, GAV->GAV_CODLOC)", 0, 4},; //"Pedido de Exames" nOpc 4
							{OemtoAnsi(STR0111),"HS_PRESCR", 0, 4},; //"Prescr. M้dica" nOpc 4
							{OemtoAnsi(STR0123),"HSPAHM10(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_RESERV, GAV->GAV_NOME, GAV->GAV_QUARTO, GAV->GAV_LEITO)", 0, 4},;//"Enfermagem" nOpc 4
							{OemtoAnsi(STR0127),"HS_AtriAnt", 0, 4},; //"Antecedentes" nOpc 4
							{OemtoAnsi(STR0128),"HS_ChmM11", 0, 4}} //"Plant. Enfer."  nOpc 4

Private cDelFunc    := ".T." /* Validacao para a exclusao. Pode-se utilizar ExecBlock */

aCor   := {	{"GAV->GAV_STATUS == '0' .Or. GAV->GAV_STATUS == ' ' " , "BR_VERDE"   },;
			{"GAV->GAV_STATUS == '2'"                              , "BR_AMARELO"},;
			{"GAV->GAV_STATUS == '1'"                              , "BR_MARROM"  },;
			{"GAV->GAV_STATUS == '3'"                              , "BR_BRANCO"  },;
			{"GAV->GAV_STATUS == '4'"                              , "BR_PRETO"   },;
			{"GAV->GAV_STATUS == '5'"                              , "BR_CINZA"  }}

HS_ATXBGCS()

DbSelectArea("GAV")
DbSetOrder(1)
If FS_FilM30(.F.)
	mBrowse(6, 1, 22, 75, "GAV",,,,,, aCor,,,,,,,, cFilM30)
Endif

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ Legenda da movimentacao                                                 ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_LegPos()
BrwLegenda(cCadastro, STR0011, {{"BR_VERDE"   , STR0012}   ,; //"LEGENDA"###"Leito Livre"
{"BR_AMARELO", STR0013} ,; //"Com Alta"
{"BR_BRANCO"  , STR0014} ,; //"Higieniza็ใo"
{"BR_PRETO"   , STR0015} ,; //"Interditado"
{"BR_CINZA"   , STR0016} ,; //"Uso Reservado"
{"BR_MARROM"  , STR0017}})  //"Ocupado"

Return(.T.)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      MOVIMENTACAO DE ALTA                                               ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30ALT(cAlias, nReg, nOpc, aCposBrw, lAuto, cRegAte, lVldLeito)
Local oDlgAlt
Local lOk 	     := .F., lVldRn := .T.
Local aArea    := GetArea()
Local nOpcA    := 0
Local lIntegr := GetMv("MV_HSPPLS")
Local aCposGcy := {"GCY_DATALT","GCY_HORALT","GCY_TPALTA","GCY_DESALT","GCY_CIDALT","GCY_DESCID","GCY_CIDCMP","GCY_DESCMP",;
"GCY_CDESTI", "GCY_DDESTI","GCY_CRMALT","GCY_MEDALT","GCY_OBSALT","GCY_OBTDOC","GCY_OBIMUL"}

Local lRN      := (GAV->GAV_RESERV $ '012345')

Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")
Local lAlta := .F.
Local cRdaGBJ	:= ""
Local aProcPls	:= {}
Local cSqlDes	:= ""
Local dDatPro	:= dDataBase
Local cFilPls 	:= PADR(GetNewPar("MV_FILIPLS", "  "),FWSizeFilial())	// Pega a filial de trabalho do PLS


Default lAuto     := .F.
Default cRegAte   := ""
Default lVldLeito := .T.
Private aTela := {}, aGets := {}
Private oEncGcy
Private cCodProSus := ""

If !HS_ExisDic({{"C", "GCY_OBIMUL"}})
	Return(Nil)
EndIf

If !LockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
EndIf


If !lAuto .Or. Empty(cRegAte)
	If GAV->GAV_STATUS != "1"
		If GAV->GAV_STATUS == "2"
			HS_MsgInf(STR0018,STR0019,STR0058) //"Paciente ja Esta de Alta...Operacao Cancelada."###"Atencao" //"MOVIMENTACAO DE ALTA"
		Else
			HS_MsgInf(STR0020,STR0019,STR0058) //"Movimentacao de Alta Invalida...Operacao Cancelada."###"Atencao" //"MOVIMENTACAO DE ALTA"
		EndIf
		UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
		Return(Nil)
	Endif
EndIf

DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + IIf(!lAuto .Or. Empty(cRegAte), GAV->GAV_REGATE, cRegAte))

If GCY->GCY_TPALTA == "99"
	HS_MsgInf(STR0054,STR0019,STR0058) //"Paciente nao pode receber alta pois o atendimento foi cancelado"###"Atencao" //"MOVIMENTACAO DE ALTA"
	UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
	Return(Nil)
EndIf

If !Hs_VlPdEx(IIf(!lAuto .Or. Empty(cRegAte), GAV->GAV_REGATE, cRegAte), .T.)
	UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
	Return(Nil)
EndIf

DbSelectArea("GFU")
DbSetOrder(2) // GFU_FILIAL + GFU_REGATE + GFU_CODCRM + GFU_TPANAM + GFU_STANAM
DbSeek(xFilial("GFU") + IIf(!lAuto .Or. Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
While GFU->(!Eof()) .And. GFU->GFU_REGATE == IIf(!lAuto .Or. Empty(cRegAte), GAV->GAV_REGATE, cRegAte)
	If GFU->GFU_STANAM == "0"
		HS_MsgInf(STR0112,STR0019,STR0058)  //"Paciente nใo pode receber alta pois hแ anamneses sem confirma็ใo."###"Atencao" //"MOVIMENTACAO DE ALTA"
		UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
		Return(Nil)
	EndIf
	DbSkip()
Enddo

DbSelectArea("GAI")
DbSetOrder (2)
DbSeek (xFilial("GAI")+GCY->GCY_REGATE)

While !EOF() .AND. GAI->GAI_FILIAL == xFilial("GCY") .AND. GAI->GAI_REGATE == GCY->GCY_REGATE
	If GAI->GAI_FLGATE $ '01'
		lVldRn := IIF(HS_ExisDic({{"C","GAI_RESERV"}} , .F.) .And. GAV->GAV_RESERV $ "0/1/2/3/4/5",GAI->GAI_RESERV == GAV->GAV_RESERV, .T.)
		If lVldRn
			HS_MsgInf(STR0052,STR0019,STR0058) // "Paciente nao pode receber alta pois possui solicitacoes em aberto" ,###"Atencao" //"MOVIMENTACAO DE ALTA"
			UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
			HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
			Return(Nil)
		Endif
	Endif
	Dbskip()
End

If HS_CountTB("GHV", "GHV_REGATE  = '" + GAV->GAV_REGATE + "' AND GHV_STATUS = '1' " + IIF(!Empty(GAV->GAV_RESERV) .And. GAV->GAV_RESERV $ "012345"," AND GHV_RESERV  = '" + GAV->GAV_RESERV + "'", "") )  > 0
	HS_MsgInf(STR0113,STR0019,STR0058) //"Paciente possui prescri็๕es m้dicas em aberto"###"Atencao" //"MOVIMENTACAO DE ALTA"
	UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
	Return(nil)
Endif

If HS_EXISDIC({{"T", "GNY"}},.F.)
	If HS_CountTB("GNY", "GNY_REGATE  = '" + GAV->GAV_REGATE + "' AND GNY_STATUS = '1' "  )  > 0
		HS_MsgInf(STR0129,STR0019,STR0058)       //"Paciente possui equipamentos em aberto"###"Atencao" //"MOVIMENTACAO DE ALTA"
	Endif
Endif

If HS_EXISDIC({{"C", "GM8_AGDPRC"}},.F.)
	If !Hs_VldSess(GCY->GCY_REGATE)
		DBSelectArea("GCZ")
		DBSetOrder(11)
		DBSeek(xFilial("GCZ") + GCY->GCY_REGGER)

		If lAtesus .And. GCZ->GCZ_CODPLA == __cCodPAC
			HS_MsgInf("Atendimento possui sess๕es agendadas que nใo foram realizadas",STR0019,STR0058)       //"Paciente possui prescri็๕es m้dicas em aberto"###"Atencao" //"MOVIMENTACAO DE ALTA"
			UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
			HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
			Return(nil)
		Else
			If ! (MsgYesNo("Atendimento possui sess๕es agendadas que nใo foram realizadas.                          Deseja continuar ?" ,STR0019)) //"Paciente possui prescri็๕es m้dicas em aberto"###"Atencao" //"MOVIMENTACAO DE ALTA"
				UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
				HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
				Return(nil)
			EndIf
		EndIf
	EndIf
EndIf

If lAteSus
	DBSelectArea("GCZ")
	DBSetOrder(2)
	If DBSeek(xFilial("GCZ") + GCY->GCY_REGATE)
		If GCZ->GCZ_CODCON == GetMV("MV_PCONSUS",,"") .AND. HS_CountTB("GD7", "GD7_NRSEQG  = '" + GCZ->GCZ_NRSEQG + "' ")  == 1
			DbSelectArea("GD7")
			DbSetorder(2)
			If DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG) .AND. HS_CountTB("GHH", "GHH_CODPRO  = '" + GD7->GD7_CODDES + "' ")  > 0
				cCodProSus := GD7->GD7_CODDES
			EndIf
		EndIf
	EndIf
EndIf

If (GCY->GCY_ATENDI == "0")
	aAdd(aCposGcy,"GCY_GESTAC")
	aAdd(aCposGcy,"GCY_TRAMAT")
	aAdd(aCposGcy,"GCY_COMPUE")
	aAdd(aCposGcy,"GCY_OBIMUL")
	aAdd(aCposGcy,"GCY_CIDCO1")
	aAdd(aCposGcy,"GCY_DESCC1")
	aAdd(aCposGcy,"GCY_CIDCO2")
	aAdd(aCposGcy,"GCY_DESCC2")
EndIf

RegToMemory("GCY",(nOpc == 3))
M->GCY_DATALT := DDATABASE
M->GCY_HORALT := TIME()
M->GCY_CRMALT := GCY->GCY_CODCRM
M->GCY_MEDALT := Posicione("SRA",11,xFilial("SRA")+M->GCY_CRMALT,"RA_NOME")

DbSelectArea("GB2")
DbSetOrder(2)		// Filial + RegAte
If DbSeek(xFilial("GB2") + M->GCY_REGATE)		// Verifica se tem recem-nascido e se o mesmo esta com o numero de documento preenchido
	While GB2->(!Eof()) .AND. GB2->GB2_FILIAL == xFilial("GB2") .AND. GB2->GB2_REGATE == M->GCY_REGATE
		If Empty(GB2->GB2_NRODEC)
			HS_MsgInf(STR0130,STR0019,STR0058)       //"Preencher o n๚mero da declara็ใo do rec้m-nascido."###"Atencao" //"MOVIMENTACAO DE ALTA"
			UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
			HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))
			Return(Nil)
		EndIf
		GB2->(DbSkip())
	End
EndIf

If cGcyAtendi <> "3"
	aSize := MsAdvSize(.T.)
	aObjects := {}

	AAdd( aObjects, {100, 100, .T., .T.,.T.})

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlgAlt TITLE Alltrim(GAV->GAV_NOME) FROM 100,000 TO 600,650 OF oMainWnd PIXEL
	oEncGcy := MsMGet():New("GCY", nReg, nOpc,,,, aCposGcy, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},, 2,,,, oDlgAlt)
	oEncGcy :oBox:align:= CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlgAlt CENTERED ON INIT {IIF(nOpc == 2 ,ChkNewDay(@oDlgAlt, .F., "HS_CposM30", .T.), Nil), ;
	EnchoiceBar(oDlgAlt, {||nOpcA:=1,IIF(Obrigatorio(aGets,aTela).AND. FS_VldAlta(lVldLeito, lRN),;
	oDlgAlt:End(),nOpcA:=0)},;
	{||oDlgAlt:End() } )}
	If nOpcA == 1
		If cGcyAtendi $ "14" .AND. lIntegr//Odontologia   - GERAR CONTAS MษDICAS
			DbSelectArea("GCZ")
			DbSetOrder(2)
			DbSeek(xFilial("GCZ") + M->GCY_REGATE)

			DbSelectArea("GA9")
			DbSetOrder(1)
			DbSeek(xFilial("GA9") + GCZ->GCZ_CODCON)

			DbSelectArea("GCM")
			DbSetOrder(2)
			DbSeek(xFilial("GCM") + GCZ->GCZ_CODPLA)

			DbSelectArea("GD4")
			DbSetOrder(1)
			DbSeek(xFilial("GD4") + M->GCY_REGGER + GCZ->GCZ_CODPLA)

			DbSelectArea("GBJ")
			DbSetOrder(1)
			DbSeek(xFilial("GBJ") + M->GCY_CODCRM)

			DbSelectArea("GCS")
			DbSetOrder(1)
			DbSeek(xFilial("GCS") + M->GCY_CODLOC)

			cRdaGBJ := GBJ->GBJ_RDAPLS
			cRdaLoc := GBJ->GBJ_RDALOC
			cRdaEsp := GBJ->GBJ_RDAESP

			cSqlDes := " SELECT GA7_TIPPRO, GA7_TABPLS, GA7_PROPLS, GD7_CODDES, GD7_QTDDES, GD7_DATDES, GA7_CODESP, GD7_DENREG, GD7_FADENT, GD7_SEQDES "
			cSqlDes += " FROM " + RetSqlName("GD7") + " GD7 "
			cSqlDes += " JOIN " + RetSqlName("GA7") + " GA7 ON GD7_CODDES = GA7_CODPRO "
			cSqlDes += " AND GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
			cSqlDes += " AND GA7_PROPLS <> '" + SPACE(TamSx3("GA7_PROPLS")[1]) + "'"
			cSqlDes += " AND GA7_TABPLS <> '" + SPACE(TamSx3("GA7_TABPLS")[1]) + "'"
			cSqlDes += " WHERE  GD7.GD7_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' "
			cSqlDes += " AND GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_STAPLS <> '1' "

			cSqlDes := ChangeQuery(cSqlDes)
			TCQuery cSqlDes New Alias "TMPGD7"

			DbSelectArea("TMPGD7")
			If !Eof()
				cCodEsp	:= TMPGD7->GA7_CODESP
				dDatPro := STOD(TMPGD7->GD7_DATDES)
				While !Eof()
					AADD(aProcPls,{TMPGD7->GA7_TABPLS,TMPGD7->GA7_PROPLS,TMPGD7->GD7_QTDDES, TMPGD7->GD7_DENREG , TMPGD7->GD7_FADENT, TMPGD7->GD7_SEQDES, TMPGD7->GA7_TIPPRO})
					DbSkip()
				EndDo
			EndIf
			DbSelectArea("TMPGD7")
			DbCloseArea()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Ponto de entrada que possibilita manipular os itens que sera gerados na conta do PLSณ
			//ณ caso seja retornado vazio nใo sera gerado.												ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ExistBlock("HSM30GCNT")
			    aProcPls := Execblock("HSM30GCNT", .F., .F.,{GCZ->GCZ_NRSEQG, aProcPls})
			EndIf
			If GCS->GCS_TIPLOC == "J" .AND. GA9->GA9_REDPRO == "1" .AND. ((GA9->GA9_CTAMED == "1" .AND. GCM->GCM_CTAMED <> "0") .OR. GCM->GCM_CTAMED == "1") .AND. Len(aProcPls) > 0
				//GERAR CONTAS MษDICAS NO PLS
				HS_VldPLS(	GD4->GD4_MATRIC, M->GCY_NOME, M->GCY_DTNASC, GCZ->GCZ_CODPLA, "", 0, dDatPro, "  :  ",;
				M->GCY_CIDALT,  cRdaEsp,;
				HS_IniPadR("GBJ", 1, GCZ->GCZ_CODCRM, "GBJ_RDAPLS",, .F.),;
				cRdaGBJ	, aProcPls, cRdaGBJ,"99",.F.)

			EndIf
		EndIf
	EndIf
Else
	FS_VldAlta(lVldLeito, lRN)
EndIf

UnLockByName("ExecM24" + IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte),.T.,.T.,.F.)
HSPDelFiCo("ExecM24",IIf(Empty(cRegAte), GAV->GAV_REGATE, cRegAte))

RestArea(aArea)
Return(Nil)

Function Hs_VldSess(cRegAte, cCondicao)
Local lRet  := .F.
Local aArea := GetArea()
Local cCond := ""

Default cCondicao := ""

cCond += " 				GM8_SEQAGE = (SELECT GM8_SEQAGE "
cCond += "     																FROM "+RetSqlName("GM8")+" "
cCond += "			                 WHERE GM8_REGATE = '"+cRegAte+"' "
cCond += "				                  AND GM8_CODAGE = GM8_SEQAGE "
cCond += "					                 AND GM8_FILIAL = '"+xFilial("GM8")+"' "
cCond += "					                 AND GM8_FILAGE = '"+xFilial("GCY")+"' "
cCond += "				                  AND D_E_L_E_T_ <> '*') "
cCond += " AND GM8_CODAGE = GM8_AGDPRC AND GM8_STATUS IN ('1','4','5') "
cCond += " AND GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' "
cCond += IIF(Empty(cCondicao),""," AND "+cCondicao)

lRet := Hs_CountTb("GM8",cCond) == 0

RestArea(aArea)
Return(lRet)

Function Hs_VlDtSes(dDatRef)
Local lRet  := .F.
Local aArea := GetArea()
Local cCond := ""//" GK7_DTINVL > '"+DtoS(M->GCY_DATALT)+"' "
Local aJoin := {{"GM8",{"GM8_CODAGE","GM8_REGATE"},{"'GM8_SEQAGE'","'"+GCY->GCY_REGATE+"'"},.F.}}

Default dDatRef := M->GCY_DATALT

cCond := " GK7_DTINVL > '"+DtoS(dDatRef)+"' "

lRet := Hs_CountTb("GK7",cCond, aJoin) == 0

RestArea(aArea)
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ FUNCAO VALIDA LEITO E DATA DE ALTA X DATA DE ATENDIMENTO                ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_VldAlta(lVldLeito, lRN)
Local   lRet := .T., cPar := AllTrim(GetMv("MV_TPALTA"))
Default lRN  := .F.

If cGcyAtendi <> "3"
	If Empty(M->GCY_TPALTA)
		HS_MsgInf(STR0051,STR0019,STR0059)  //"Por favor, informe o tipo da alta"//###"Atencao" //"VALIDA LEITO"
		Return(.F.)
	EndIf
EndIf

If M->GCY_DATALT < GCY->GCY_DATATE .or. (M->GCY_DATALT == GCY->GCY_DATATE .and. M->GCY_HORALT < GCY->GCY_HORATE)
	HS_MsgInf(STR0066, STR0019,STR0067)  //"A data da alta nใo pode ser retroativa เ data de atendimento"//###"Atencao" // "Valida็ใo de Alta"
	Return(.F.)
EndIf

If HS_ExisDic({{"C", "GCY_CLISEC"}}, .F.)
	If M->GCY_DATALT < GCY->GCY_DTCLIS
		HS_MsgInf(STR0130, STR0019,STR0067)  //"Data da Alta nใo pode ser anterior a data da Clinica Secundaria do paciente, favor alterar a data da Clinica Secundแria atrav้s do posto de enfermagem para antes da data da alta desejada!"//###"Atencao" // "Valida็ใo de Alta"
		Return(.F.)
	EndIf
EndIf
If !(M->GCY_TPALTA $ cPar ) .and. Empty(M->GCY_DATSAI)
	If HS_CountTB("GD5",	"(GD5_REGATE = '" + M->GCY_REGATE + "' AND GD5_DATDES > '" + DTOS(M->GCY_DATALT) + "' OR GD5_REGATE = '" + M->GCY_REGATE + "' AND GD5_DATDES = '" + DTOS(M->GCY_DATALT) + "' AND GD5_HORDES > '" + SUBSTR(M->GCY_HORALT,1,len(GD5->GD5_HORDES)) + "')") > 0
		HS_MsgInf(STR0109, STR0019,STR0067)  //A data/hora da alta nใo pode ser menor do que a(s) despesa(s) mat/med lan็ada(s) para o paciente."//###"Atencao" // "Valida็ใo de Alta"
		Return(.F.)
	Endif
Endif

If M->GCY_TPALTA $ cPar /* alta por obito */
	If Empty(M->GCY_OBTDOC)
		HS_MsgInf(STR0060, STR0019,STR0059) //###"Atencao"   //"Para o Tipo de Alta Obito o Campo No. Doc Obito tem que ser preenchido obrigatoriamente..."###"VALIDA LEITO"
		Return(.F.)
	EndIf
EndIf

If cGcyAtendi == "0"
	If Empty(M->GCY_GESTAC) .Or. Empty(M->GCY_TRAMAT) .Or. Empty(M->GCY_COMPUE)
		HS_MsgInf(STR0107,STR0019,STR0067)  //"Por favor, preencha os campos obrigat๓rios: 'Atendimento gestacao', 'Transtornos Maternos' e 'Complicacoes puerperal'."###"Aten็ใo"###"Valida็ใo de Alta"
		Return(.F.)
	EndIf
EndIf

If HS_EXISDIC({{"T", "GK7"}},.F.)
	If !Hs_VlDtSes()
		HS_MsgInf("Data da alta nใo pode ser anterior ao Inicio de Validade da APAC",STR0019,STR0067)  //###"Aten็ใo"###"Valida็ใo de Alta"
		Return(.F.)
	EndIf
EndIf

// Verifica se as despesas fixas foram lan็adas
If M->GCY_DATALT == GCY->GCY_DATATE
	FS_VDSPFIX(GCY->GCY_REGATE)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada para definir a continuidade do processo de alta         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("HSVALALT")
    lRet := Execblock("HSVALALT", .F., .F.,{GCY->GCY_REGATE})
EndIf


If lRet
	Begin Transaction

	DbSelectArea("GCY")
	DbSetOrder(1)
	RecLock("GCY", .F.)
	GCY->GCY_OBTDOC := M->GCY_OBTDOC
	If !lRN
		GCY->GCY_CDESTI := M->GCY_CDESTI
		GCY->GCY_CRMALT := M->GCY_CRMALT
	EndIf
	MsUnLock()

	If ExistBlock("HSCUSGCY")
		Execblock("HSCUSGCY", .F., .F.)
	EndIf

	If lVldLeito
		lRet := HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "1", M->GCY_DATALT, M->GCY_HORALT, M->GCY_TPALTA, M->GCY_CIDALT, M->GCY_CIDCMP,,,lRN, GAV->GAV_RESERV,,M->GCY_CIDCO1, M->GCY_CIDCO2, M->GCY_OBSALT)
		If M->GCY_ATENDI == "2" //Pronto Atendimento - Da Saida e Libera Leito
			lRet := HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "2", M->GCY_DATALT, M->GCY_HORALT,,,,,,lRN, GAV->GAV_RESERV)
			lRet := HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "3", M->GCY_DATALT, M->GCY_HORALT,,,,,,lRN, GAV->GAV_RESERV)
			lRet := HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "4", M->GCY_DATALT, M->GCY_HORALT,,,,,,lRN, GAV->GAV_RESERV)
			lRet := HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "5", M->GCY_DATALT, M->GCY_HORALT,,,,,,lRN, GAV->GAV_RESERV)
		EndIf
	Else
		HS_GrvAlta(M->GCY_REGATE, M->GCY_TPALTA, M->GCY_DATALT, M->GCY_HORALT, M->GCY_CIDALT, M->GCY_CIDCMP,,,M->GCY_CIDCO1, M->GCY_CIDCO2, M->GCY_OBSALT)
	EndIf

	DbSelectArea("GCZ")
	DbSetOrder(2)
	DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)
	While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == GCY->GCY_REGATE
		If GCZ->GCZ_STATUS == "0" .And. Empty(GCZ->GCZ_DCPARF)
			RecLock("GCZ", .F.)
			GCZ->GCZ_DCPARF := M->GCY_DATALT
			MsUnLock()
		Endif
		DbSkip()
	End

	If lRet .And. Type("__cFExAlta") <> "U"  //Funcao Extra da Alta
		lRet := &(__cFExAlta)
	Endif

	End Transaction
EndIf


Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ LANCAMENTO DAS DESPESAS                                                 ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30DES()
Local aAreaOld := GetArea()

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

DbSelectArea("GCY")
DbSetOrder(1)
If !dbSeek(xFilial("GCY") + GAV->GAV_REGATE)
	HS_MsgInf(STR0046,STR0047,STR0061)  //"Nใo hแ registro de atendimento para esta guia. Chame o suporte."###"Inconsist๊ncia" //"Lancamento das Despesas"
Else
	HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "P", 7, GAV->GAV_CODLOC, ""})
EndIf

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

RestArea(aAreaOld)
Return(nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      MOVIMENTACAO DE SAIDA                                              ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30SAI(cAlias,nReg,nOpc)

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

IF GAV->GAV_STATUS != "2"
	HS_MsgInf(STR0021,STR0019,STR0062) //"Opcao invalida...Operacao cancelada."###"Atencao" //"MOVIMENTACAO DE SAIDA"
	UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
	Return(Nil)
ENDIF

If GAV->GAV_RESERV$"012345"
	HS_MsgInf(STR0044,STR0019,STR0062) //"Operacao nao permitida para Recem Nascido !",###"Atencao" //"MOVIMENTACAO DE SAIDA"
	UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
	Return Nil
Endif

If !HS_EXISDIC({{"T", "GNY"}},.F.)
Else
	If HS_CountTB("GNY", "GNY_REGATE  = '" + GAV->GAV_REGATE + "' AND GNY_STATUS = '1' "  )  > 0
		HS_MsgInf(STR0129,STR0019,STR0062)       //"Paciente possui equipamentos em aberto"###"Atencao" //"MOVIMENTACAO DE SAIDA"
		UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
		Return(Nil)
	Endif
Endif

If APMSGYESNO(STR0022+Alltrim(GAV->GAV_NOME)) //"Confirma a Saida do Paciente "
	Begin Transaction
	HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "2", dDataBase, Time())
	End Transaction

Endif

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      CANCELAMENTO DA ALTA                                               ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30CAL(cAlias,nReg,nOpc)
Local cArqOld

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

IF GAV->GAV_STATUS <> "2"
	HS_MsgInf(STR0023,STR0019,STR0063) //"Leito Impossibilitado ...Operacao cancelada."###"Atencao" //"CANCELAMENTO DA ALTA"
	UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

	Return(Nil)
ENDIF

IF APMSGYESNO(STR0024+Alltrim(GAV->GAV_NOME)) //"Confirma o Cancelamento da Alta ? "
	Begin Transaction
	cArqOld := Alias()
	DbSelectArea("GCY")
	DbSetOrder(1)
	If DbSeek(xFilial("GCY") + GAV->GAV_REGATE )
		RecLock("GCY", .F.)
		GCY->GCY_CDESTI := SPACE(TamSx3("GCY_CDESTI")[1])
		GCY->GCY_CRMALT := SPACE(TamSx3("GCY_CRMALT")[1])
		GCY->GCY_OBTDOC := SPACE(TamSx3("GCY_OBTDOC")[1])
		MsUnLock()
	EndIf
	DbSelectArea(cArqOld)
	HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "6", dDataBase, Time(), "", "", "", .F., .F.)
	End Transaction

EndIf

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      CANCELAMENTO DA SAIDA                                              ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30CSA(Alias,nReg,nOpc)

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

IF GAV->GAV_STATUS <> "3" .Or. Empty(GAV->GAV_REGATE)
	HS_MsgInf(STR0023,STR0019,STR0064) //"Leito Impossibilitado ...Operacao cancelada."###"Atencao" //"CANCELAMENTO DA SAIDA"
	UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
	Return(Nil)
ENDIF

IF APMSGYESNO(STR0025+Alltrim(GAV->GAV_NOME)) //"Confirma o Cancelamento da Saida ? "
	Begin Transaction
	HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "7", dDataBase, Time(),,,, .F., .F.)
	End Transaction

EndIf

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      LIBERACAO DO LEITO                                                 ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30LIB(cAlias,nReg,nOpc)
Local lRN := (GAV->GAV_RESERV$"012345")
Local cQuart:=SPACE(TAMSX3("GAV_QUARTO")[1])
Local cLeito:=SPACE(TAMSX3("GAV_LEITO")[1])

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

If funname() == "HSPAHM30"
	IF GAV->GAV_STATUS == "0" .Or. GAV->GAV_STATUS == "1" .Or. GAV->GAV_STATUS == "2" .Or. GAV->GAV_STATUS == "4" .Or. GAV->GAV_STATUS == "5"
		IF GAV->GAV_STATUS == "0" .OR. GAV->GAV_STATUS == " "
			HS_MsgInf(STR0026,STR0019,STR0065) //"Leito JA Esta Liberado..."###"Atencao" //"LIBERACAO DO LEITO"
		ElseIf GAV->GAV_STATUS == "4"
			HS_MsgInf(STR0027,STR0019,STR0065) //"Leito Esta Interditado...Operacao cancelada."###"Atencao" //"LIBERACAO DO LEITO"
		Else
			HS_MsgInf(STR0029,STR0019,STR0065) //"Leito impossibilitado de Liberacao ...Operacao cancelada."###"Atencao" //"LIBERACAO DO LEITO"
		EndIf
		UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
		Return(Nil)
	ENDIF

	IF APMSGYESNO(STR0030) //"Confirma a Liberacao do Leito ?"

		Begin Transaction

		HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "3", dDataBase, Time(),,,,,, lRN, GAV->GAV_RESERV)
		HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "4", dDataBase, Time(),,,,,, lRN, GAV->GAV_RESERV)
		HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "5", dDataBase, Time(),,,,,, lRN, GAV->GAV_RESERV)

		FS_DesMod(GAV->GAV_CODLOC, GAV->GAV_QUARTO,GAV->GAV_MODELO)//desfaz as modificacoes de leitos
		End Transaction

		If HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.)///parametro configurado no cadastro de setor lista de espera
			DbSelectArea("GCS")
			DbSetOrder(1)
			Dbseek(xFilial("GCS")+GAV->GAV_CODLOC)  //GCS_FILIAL+GCS_CODLOC
			If GCS->GCS_LSTESP =="1"    // Verifica se o Setor Exibirแ a Lista de Espera do Paciente
				DbSelectArea("GT6")
				GT6->(DbSetOrder(1))
				If 	GT6->(DbSeek(xFilial("GT6") + GAV->GAV_CODLOC+ GAV->GAV_QUARTO+GAV->GAV_LEITO)) //Busca de Paciente por Setor + Quarto + Leito
					cQuart :=GAV->GAV_QUARTO
					cLeito:=GAV->GAV_LEITO
				Else
					IF GT6->(DbSeek(xFilial("GT6") + GAV->GAV_CODLOC+ GAV->GAV_QUARTO)) //Busca de Paciente por Setor + Quarto
						If GAV->GAV_LEITO == GT6->GT6_LEITO .or. Empty(GT6->GT6_LEITO) //Verificando se O Leito a ser Liberado ้ Igual ao Que estแ em Espera
							cQuart :=GT6->GT6_QUARTO
							cLeito :=GT6->GT6_LEITO
						Endif
					Else
						If GT6->(DbSeek(xFilial("GT6") + GAV->GAV_CODLOC)) //Busca de Paciente por Setor
							If GAV->GAV_QUARTO == GT6->GT6_QUARTO .or. Empty(GT6->GT6_QUARTO) // Verificando se O Quarto a ser Liberado ้ Igual ao Que estแ em Espera
								cQuart :=GT6->GT6_QUARTO
								cLeito :=GT6->GT6_LEITO
							Endif
						Endif
					Endif
				Endif

				If HS_CountTB("GT6", "GT6_CODLOC = '" + GAV->GAV_CODLOC + "'  and GT6_QUARTO = '" + cQuart + "' and  GT6_LEITO = '" + cLeito + "'  ") > 0
					HS_ExbLsE(GAV->GAV_CODLOC,cQuart,cLeito,nOpc ) ///lista de espera
					UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
					HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
					Return(NIL)
				Endif
		Endif
		Endif





	EndIf
Else
	Begin Transaction

	HS_GrvMovH(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "3", dDataBase, Time(),,,,,, lRN, GAV->GAV_RESERV)
	HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "4", dDataBase, Time(),,,,,, lRN, GAV->GAV_RESERV)
	HS_GrvMovH("", GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "5", dDataBase, Time(),,,,,, lRN, GAV->GAV_RESERV)

	FS_DesMod(GAV->GAV_CODLOC, GAV->GAV_QUARTO,GAV->GAV_MODELO)//desfaz as modificacoes de leitos
	End Transaction

Endif

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      TRANSFERENCIA DE LEITO                                             ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_M30TRA(cAlias,nReg,nOpc)
Local lCenCir  := .F.
Local aArea      := GetArea()
Local lList    := .F.
Local cUsuBloq := ""
Local cCodGAV  := ""
Private cRegger:=""
Private cStatusGAV	:= "0" // Leitos vagos
Private cOldQuarto := "", cOldSetor := "", cOldLeito  := "", cOldRegAte := ""
Private cNomepac   :=""

cCodGAV := GAV->GAV_REGATE

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

If FunName() <> "HSPAHM30"
	If HS_M24CCEs(GCY->GCY_CODLOC) == 'B'
		DbSelectArea("GAV")
		DbSetOrder(1)
		DbSeek(xFilial("GAV")+GCY->GCY_CODLOC+GCY->GCY_QUAINT+GCY->GCY_LEIINT)  //GAV_FILIAL+GAV_CODLOC+GAV_QUARTO+GAV_LEITO
	Else
		HS_MsgInf(STR0057, STR0019, STR0049) //"Paciente so pode ser transferido se setor for do tipo espera"###"Atencao" //"TRANSFERENCIA DE LEITO"
		UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
        HSPDelFiCo("ExecM24",cCodGAV)
		Return(Nil)
	Endif

Endif


If (GAV->GAV_DATATE > dDataBase ) .Or.( (GAV->GAV_DATATE == dDataBase ).And.(GAV->GAV_HORATE > Time()))
	HS_MsgInf(STR0132, STR0019,STR0049)  //"A data/hora  de Transferencia nใo pode ser retroativa เ data/hora  de atendimento"//###"Atencao"
	UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
    HSPDelFiCo("ExecM24",cCodGAV)
	Return(Nil)
Endif

IF GAV->GAV_STATUS != "1"
	IF GAV->GAV_STATUS == "0" .OR. GAV->GAV_STATUS == " "
		HS_MsgInf(STR0031,STR0019,STR0049) //"Leito Esta Vago...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
	ElseIf GAV->GAV_STATUS == "4"
		HS_MsgInf(STR0027,STR0019,STR0049) //"Leito Esta Interditado...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
	ElseIf GAV->GAV_STATUS == "5"
		HS_MsgInf(STR0028,STR0019,STR0049)  //"Leito Esta Reservado...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
	ElseIf GAV->GAV_STATUS == "2"
		HS_MsgInf(STR0032,STR0019,STR0049) //"Leito Esta de Alta...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
	Else
		HS_MsgInf(STR0033,STR0019,STR0049) //"Leito impossibilitado de Transferencia...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
	EndIf

	UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
    HSPDelFiCo("ExecM24",cCodGAV)
	Return(Nil)
Endif

cOldQuarto := GAV->GAV_QUARTO
cOldSetor  := GAV->GAV_CODLOC
cOldLeito  := GAV->GAV_LEITO
cOldRegAte := GAV->GAV_REGATE

If GAV->GAV_RESERV $ "012345"
	//HS_MsgInf(STR0044, STR0019, STR0049) //"Operacao nao permitida para Recem Nascido !" //"TRANSFERENCIA DE LEITO"
	Begin Transaction
	If !Fs_TranRn(cOldRegAte,cOldQuarto,cOldSetor,cOldLeito,GAV->GAV_TIPO,GAV->GAV_RESERV)
		DisarmTransaction()
	EndIf
	End Transaction
	UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
    HSPDelFiCo("ExecM24",cCodGAV)
	Return(Nil)
Endif

//Posiciona no grupo de perguntas e zera o conteudo inicial das mesmas

HS_PosSX1({{"HSPTRA", "01", Nil}, {"HSPTRA", "02", Nil}, {"HSPTRA", "03", Nil}})

If !Pergunte("HSPTRA",.T.)
    UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
    HSPDelFiCo("ExecM24",cCodGAV)
	return(NIL)
EndIf

If HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.)///lista de espera
	lList:=HS_TranLst(MV_PAR01,MV_PAR02,MV_PAR03,nOpc) // Verifica se existe paciente em Espera para o Leito Informado
Endif

If !lList
If  APMSGYESNO(STR0034+ iif(!Empty(cNomepac) ," Paciente da Lista Espera:  "+cNomepac,""))  /*INICIA TRANSFERENCIA*/ //"Confirma a Transferencia de Leito ?"
	DbSelectArea("GAV")
	DbSetOrder(1)
	If !DbSeek(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03 )
		HS_MsgInf(STR0105,STR0019,STR0049) //"Novo Leito Impossibilitado de Transferencia...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
		RestArea(aArea)
		UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
        HSPDelFiCo("ExecM24",cCodGAV)
		Return(Nil)
	ElseIf GAV->GAV_STATUS != "0"
		HS_MsgInf(STR0035,STR0019,STR0049) //"Novo Leito Impossibilitado de Transferencia...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
		RestArea(aArea)
		UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
        HSPDelFiCo("ExecM24",cCodGAV)
		Return(Nil)
	ElseIf !LockByName(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03, .T., .T., .F.)
   		cUsuBloq := HSPVerFiCo("GAV",xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03,.F.)
		HS_MsgInf(STR0108+" - "+cUsuBloq, STR0019, STR0049) //"Este leito estแ bloqueado por outro usuแrio"###"Atencao"###"TRANSFERENCIA DE LEITO"
		RestArea(aArea)
		UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
		HSPDelFiCo("ExecM24",cCodGAV)
		Return(Nil)
	Else
	    HSPGerFiCo("GAV",xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03)
	EndIf

	Begin Transaction

	RecLock("GAV", .F.)
	GAV->GAV_REGATE := cOldRegAte
	MsUnLock()

	If GAV->GAV_TIPO == "2"
		lCenCir := .T. /* leito de centro cirurgico */
	Endif

	DbSelectArea("GAV")
	DbSetOrder(1)
	If DbSeek(xFilial("GAV") + cOldSetor + cOldQuarto + cOldLeito )
		IF lCenCir /*SE O NOVO LEITO FOR NO CENTRO CIRURGICO*/
			RecLock("GAV", .F.)
			GAV->GAV_RESERV := "Y"
			GAV->GAV_OBSERV := STR0048 //"LEITO OCUPADO"
			GAV->GAV_STATUS := "5"
				cRegger:= GAV->GAV_REGGER
			MsUnlock()
		Else /*se o novo leito nao for o centro cirurgico */
				cRegger:= GAV->GAV_REGGER
			HS_GrvMovH(cOldRegAte, cOldSetor, cOldQuarto, cOldLeito,  "8", dDataBase, Time() ) /*TRANSFERENCIA*/
			If funname() <> "HSPAHM30"
				HS_M30LIB(cAlias,nReg,nOpc)
			Endif
			//HS_GrvMovH(cOldRegAte, cOldSetor, cOldQuarto, cOldLeito,  "2", dDataBase, Time() ) /*SAIDA      */
		EndIf  /* se leito eh centro cirurgico*/
	EndIf

	HS_GrvMovH(cOldRegAte, MV_PAR01, MV_PAR02, MV_PAR03, "0", dDataBase, Time() ) /*INTERNACAO NO NOVO LEITO*/
	End Transaction

	UnLockByName(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03, .T., .T., .F.)
	HSPDelFiCo("GAV",xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03)
EndIf /*yesno*/
Endif
UnLockByName("ExecM24" + cCodGAV,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",cCodGAV)

If HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.)
	If HS_CountTB("GT6", "GT6_REGGER = '" + cRegger + "' ") > 0  // Verifica se o paciente estแ na lista de espera se sim Realiza a Exclusใo do Mesmo
		HS_ExclEs(cRegger)
	Endif
Endif

RestArea(aArea)
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      FILTRO DA TECLA F12                                                ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_FilM30(lSetFilter)
Local oObjMBrw     := ""
Local lRet         := .T.

Default lSetFilter := .T.

oObjMBrw           := IIf(lSetFilter, GetObjBrow(), Nil)

If (lRet := Pergunte(cPerg1,.T.))
	cSetPerg := mv_par01

	cFilM30 := "GAV_FILIAL = '" + xFilial("GAV") + "' "
	cFilM30 += "AND GAV_CODLOC = '" + cSetPerg + "' "
	cFilM30 += "AND GAV_STATUS IN ('1', '2', '3', '5')"
Endif

If lSetFilter .And. lRet
	oObjMBrw:ResetLen()
	GAV->(DbClearFilter())
	SetMBTopFilter("GAV",cFilM30,,.T.)
	oObjMBrw:GoTop()
	dbSelectArea("GAV")
	GAV->(dbGoTop())
	oObjMBrw:Refresh()
EndIf
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      CHAMA ROTINA PARA IMPRIMIR AS FICHAS DE ATENDIMENTO                ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_RelM30(cAlias, nReg, nOpc)
GDN->(dbSetOrder(1))
If GDN->(DbSeek(xFilial("GDN") + GAV->GAV_CODLOC))
	HSPAHP44(.F.,GAV->GAV_CODLOC,{{"GCY", 1, GAV->GAV_REGATE}} )
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RNaM30 บ Autor ณ Cibele Peria       บ Data ณ  20/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Chama cadastro de RN para o atendimento                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_RNaM30(cAlias, nReg, nOpc)
Local aArea := GetArea()

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf


DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

HS_RNaM24("GCY", RecNo(), nOpc)

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

RestArea(aArea)
Return()

Static Function FS_DesMod(cSetor, cQuarto, cModelo)
Local aAreaOld := GetArea()

DbSelectArea("GFM")
DbSetOrder(2)//CODLOC + QUARTO
If DbSeek(xFilial("GFM") + cSetor + cQuarto)
	While !EOF() .And. GFM->GFM_FILIAL == xFilial("GFM") .And. GFM->GFM_CODLOC == cSetor .And. ;
		GFM->GFM_QUARTO == cQuarto
		DbSelectArea("GFL")
		DbSetOrder(1) //CODREG
		If DbSeek(xFilial("GFL") + GFM->GFM_CODREG) .And. GFL->GFL_TPDEST == cModelo //busca a regra que tem o tipo destino = modelo do quarto q foi liberado
			If GFL->GFL_DESAUT == "1" //SIM
				HS_A19MOD(cSetor, GFL->GFL_CODREG, cQuarto, .T.)
				Exit
			EndIf
		EndIf

		DbSelectArea("GFM")
		DBSkip()
	EndDo
EndIf

RestArea(aAreaOld)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PESMED บ Autor | MARIO ARIZONO      บ Data |  17/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para pesquisa por profissionais.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

FUNCTION HS_PESMED()
Local oSRA, oDlg
Local nOpcA := 0


aSize := MsAdvSize(.T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0056)From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Profissionais"

oSRA := HS_MBrow(oDlg, "SRA", {aSize[7], 001, aSize[3], aSize[4]-22},,,,,,,,,,.T.,,)
oSRA:BlDblClick := {|| HS_MntA24("SRA", SRA->(Recno()), 1)}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1,;
oDlg:End()}, ;
{|| nOpcA := 0, oDlg:End()})

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CposM30บAutor  ณDaniel Peixoto      บ Data ณ  25/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina utilizada para atualizar em tempo de execucao camposบฑฑ
ฑฑบ          ณ de data e hora quando houver virada de dia.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_CposM30()
Local aCposGCY := {"GCY_DATALT", "GCY_HORALT"}
Local nCont    := 0, nPos := 0

If GETNEWPAR("MV_HSPRFDH","1")== "1"
	For nCont := 1 to 2
		If EMPTY(&("M->GCY_TPALTA")) .And. !EMPTY(&("M->" + aCposGCY[nCont]))
			&("M->" + aCposGCY[nCont]) := IIF(nCont == 1, DDATABASE, Time())
		EndIf
	Next
	oEncGcy:Refresh()
EndIf
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PESQSOLบAutor  ณMario Arizono       บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta mat/med solicitados de acordo com os parametros.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION HS_PESQSOL(cAlias,nReg,nOpc)

Local   aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local  nGDOpc := 0, oDlgPesq, nOpcDlg := 0, nGAICodSol := 0
Local aColGAI := {}, aHeaGAI := {}, nUGAI := 0, oGAI
Local aColGAJ := {}, aHeaGAJ := {},  nUGAJ := 0, oGAJ
Local oRegger, cRegGer := SPACE(LEN(GAV->GAV_REGGER))
Local oDesPac, cDesPac := SPACE(LEN(GAV->GAV_NOME))
Local oLeito, cLeito := SPACE(LEN(GAV->GAV_LEITO))
Local oDatIni, dIniSol := CTOD("  /  /  ")
Local oDatFim, dFimSol := CTOD("  /  /  ")
Local oCabec
Local cPerg   := "HSM30A"
Local dDatIni := CTOD("  /  /  "), dDatFim := CTOD("  /  /  ")
Local bFS_Copiar	:= {||IIF(nIteGai <> 0,FS_Copiar(oGAI:aCols[oGAI:nAt,nGAICodSol],oGAI, aColGai, aHeaGai, nUGai, dDatIni, dDatFim),Nil)} // Facilitador para copiar solicitacoes
Local bFS_Excluir	:= {||IIF(nIteGai <> 0, FS_Excluir(oGAI:aCols[oGAI:nAt,nGAICodSol],oGAI, aColGai, aHeaGai, nUGai, oGAJ, aColGaj, aHeaGaj, nUGaj, dDatIni, dDatFim, nGAICodSol),Nil)} // Facilitador para excluir solicitacoes
Local bFS_Editar	:= {||IIF(nIteGai <> 0, FS_Editar(oGAI:aCols[oGAI:nAt,nGAICodSol],oGAJ, aColGaj, aHeaGaj, nUGaj),Nil)} // Facilitador para editar solicitacoes
Local aButtons := {}

Private nIteGai := 0

DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(cPerg)
	If (lRet := Pergunte(cPerg,.T.))
		dDatIni := MV_PAR01
		dDatFim := MV_PAR02
	Else
		Return(Nil)
	Endif

	cRegGer := GAV->GAV_REGGER
	cDesPac := GAV->GAV_NOME
	cLeito  := GAV->GAV_LEITO
	dIniSol := dDatIni
	dFimSol := dDatFim

	Aadd(aButtons	, {'S4WB005N',{||Eval(bFS_Copiar)},STR0071,STR0072})  //"Copiar Solicita็ใo"###"Copiar Sol."
	Aadd(aButtons	, {'EXCLUIR',{||Eval(bFS_Excluir)},STR0073,STR0074}) //"Exclui Solicita็ใo"###"Excluir"
	Aadd(aButtons	, {'EDIT',{||Eval(bFS_Editar)},STR0075,STR0076}) //"Edita Solicita็ใo"###"Editar"

	cFiltro := "GAI->GAI_DATSOL >= '" + DTOS(dDatIni) + "' AND GAI->GAI_DATSOL <= '" + DTOS(dDatFim) + "' AND "
	cFiltro += "GAI->GAI_REGATE = '"+ GAV->GAV_REGATE + "' AND GAI->GAI_CODLOC = '"+ GAV->GAV_CODLOC + "'"

	nIteGai := HS_BDados("GAI", @aHeaGAI, @aColGAI, @nUGAI, 1, ,cFiltro )

	If nIteGai == 0
		HS_MsgInf(STR0077, STR0019, STR0078) //"Nenhum item selecionado com os parโmetros informados."###"Valida็ใo dos itens da solicita็ใo"
		Return()
	Endif

	nGAICodSol := aScan(aHeaGAI, {|aVet| AllTrim(aVet[2]) == "GAI_SOLICI"})

	nIteGaj := HS_BDados("GAJ", @aHeaGAJ, @aColGAJ, @nUGAJ, 1,, "GAJ->GAJ_SOLICI == '"+ aColGAI[1 ,nGAICodSol] + "'",,,,,,,,,,,,,,,,,,,)


	aSize := MsAdvSize(.T.)
	aObjects := {}

	AAdd( aObjects, { 100, 020, .T., .T.,.T. } )
	AAdd( aObjects, { 100, 040, .T., .T. } )
	AAdd( aObjects, { 100, 040, .T., .T. } )

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlgPesq TITLE STR0079 From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel //"Consulta itens da solicitacao" //"Consulta itens da solicita็ใo"

	oCabec	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgPesq,,,,,, aPObjs[1, 3], aPObjs[1, 4])
	oCabec:Align := CONTROL_ALIGN_TOP

	@ 010, 003 Say OemToAnsi(STR0080) Size 040, 009 OF oCabec PIXEL COLOR CLR_BLUE //"Prontuario"
	@ 009, 035 MSGet oRegger var cRegger Size 040, 009 OF oCabec PICTURE "@!" PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 010, 130 Say OemToAnsi(STR0081) Size 040, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Descri็ใo"
	@ 009, 160 MSGet oDesPac var cDesPac Size 100, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 010, 310 Say OemToAnsi(STR0042) Size 020, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Leito"
	@ 009, 328 MSGet oLeito var cLeito Size 040, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 030, 003 Say OemToAnsi(STR0082) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Data Inicial"
	@ 029, 035 MSGet oDatIni var dIniSol Size 040, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 030, 130 Say OemToAnsi(STR0083) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Data Final"
	@ 029, 160 MSGet oDatFim var dFimSol Size 040, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	oGAI := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],nGDOpc,,,,,,,,,,, aHeaGAI, aColGAI)
	oGAI:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT
	oGAI:oBrowse:bchange:={||FS_AtuGaj(oGAI:aCols[oGAI:nAt,nGAICodSol], oGaj, aHeaGAJ, aColGAJ, nUGAJ )}

	oGAJ := MsNewGetDados():New(aPObjs[3, 1], aPObjs[3, 2], aPObjs[3, 3], aPObjs[3, 4],nGDOpc ,,,,,,,,,,, aHeaGAJ, aColGAJ)
	oGAJ :oBrowse:align := CONTROL_ALIGN_BOTTOM


	ACTIVATE MSDIALOG oDlgPesq ON INIT EnchoiceBar(oDlgPesq,{||nOpcDlg := 1	, oDlgPesq:End()},	{||nOpcDlg := 0, oDlgPesq:End()},,aButtons)
	cNumSol := ""
Endif
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUGAJ  บ Autor ณ MARIO ARIZONO      บ Data ณ  30/11/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que atualiza os dados mostrados na getdados dos itensบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_ATUGAJ(cCodSol, oGAJ,aHeaGAJ, aColGAJ, nUGAJ )
Local nGajIteSol := 0, nIteGaj := 0

aHeaGAJ := {}
aColGAJ := {}
nUGAJ   := 0

nIteGaj := HS_BDados("GAJ", @aHeaGAJ, @aColGAJ, @nUGAJ, 1,, "GAJ->GAJ_SOLICI == '" + cCodSol + "' ",,,,,,,,,,,,,,,,,,,)

nGajIteSol := aScan(aHeaGaj, {|aVet| AllTrim(aVet[2]) == "GAJ_ITESOL"})

If nIteGaj == 0
	aColGaj[1, nGajIteSol] := Soma1(aColGaj[1, nGajIteSol], Len(aColGaj[1, nGajIteSol]))
Endif

oGAJ:ACols:=aClone(aColGAJ)
oGAJ:oBrowse:Refresh()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_COPIAR  บ Autor ณ MARIO ARIZONO      บ Data ณ  30/11/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que Copia os itens mostrados na tela gerando uma     บฑฑ
ฑฑบ          ณnova solicitacao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_COPIAR(cCodSol,oGAI, aColGai, aHeaGai, nUGai, dDatIni, dDatFim)
Local    aArea := GetArea()
Local  cFiltro := ""
Private Inclui := .T.

cNumSol := cCodSol
DbSelectArea("GAV")
HS_MntM04("GAI", 0, 3)

aHeaGAI := {}
aColGAI := {}
nUGai   := 0

cFiltro := "GAI->GAI_DATSOL >= '" + DTOS(dDatIni) + "' AND GAI->GAI_DATSOL <= '" + DTOS(dDatFim) + "' AND "
cFiltro += "GAI->GAI_REGATE = '"+ GAV->GAV_REGATE + "' AND GAI->GAI_CODLOC = '"+ GAV->GAV_CODLOC + "'"
nIteGai := HS_BDados("GAI", @aHeaGAI, @aColGAI, @nUGAI, 1, , cFiltro)
oGAI:ACols:=aClone(aColGAI)
oGAI:oBrowse:Refresh()
RestArea(aArea)
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_COPIAR  บ Autor ณ MARIO ARIZONO      บ Data ณ  30/11/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que Copia os itens mostrados na tela gerando uma     บฑฑ
ฑฑบ          ณnova solicitacao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_EXCLUIR(cCodSol, oGAI, aColGai, aHeaGai, nUGai, oGAJ, aColGaj, aHeaGaj, nUGaj, dDatIni, dDatFim, nCodSol)
Local    aArea := GetArea()
Local  nRegM30 := 0
Local  cFiltro := ""

cNumSol := cCodSol
DbSelectArea("GAI")
DbSetOrder(1)
DbSeek(xFilial("GAI") + cNumSol)
nRegM30 := GAI->(RECNO())
DbSelectArea("GAV")
HS_MntM04("GAI", nRegM30, 5)

aHeaGAI := {}
aColGAI := {}
nUGAI   := 0

cFiltro := "GAI->GAI_DATSOL >= '" + DTOS(dDatIni) + "' AND GAI->GAI_DATSOL <= '" + DTOS(dDatFim) + "' AND "
cFiltro += "GAI->GAI_REGATE = '"+ GAV->GAV_REGATE + "' AND GAI->GAI_CODLOC = '"+ GAV->GAV_CODLOC + "'"
DbSelectArea("GAI")
nIteGai := HS_BDados("GAI", @aHeaGAI, @aColGAI, @nUGAI, 1, , cFiltro)
oGAI:ACols:=aClone(aColGAI)
oGAI:oBrowse:Refresh()

FS_ATUGAJ(oGAI:aCols[oGAI:nAt,nCodSol], oGAJ,aHeaGAJ, aColGAJ, nUGAJ)
RestArea(aArea)
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_COPIAR  บ Autor ณ MARIO ARIZONO      บ Data ณ  30/11/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que Copia os itens mostrados na tela gerando uma     บฑฑ
ฑฑบ          ณnova solicitacao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_EDITAR(cCodSol, oGAJ, aColGaj, aHeaGaj, nUGaj)
Local    aArea := GetArea()
Local  nRegM30 := 0

cNumSol := cCodSol
DbSelectArea("GAI")
DbSetOrder(1)
DbSeek(xFilial("GAI") + cNumSol)
nRegM30 := GAI->(RECNO())
DbSelectArea("GAV")

HS_MntM04("GAI", nRegM30, 4)

FS_ATUGAJ(cCodSol, oGAJ,aHeaGAJ, aColGAJ, nUGAJ)
RestArea(aArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DEVSOL บAutor  ณMario Arizono       บ Data ณ  05/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera confirmacao de devolucao para mat/med.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION HS_DEVSOL(cAlias,nReg,nOpc)

Local   aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local  nGDOpc  := 0, oDlgDev, nOpcDlg := 0
Local aCGD5Ori := {}, aHGD5Ori := {}, nUGD5Ori := 0
Local aCGD5Fim := {}, aHGD5Fim := {}, nUGD5Fim := 0, oGD5Fim
Local oRegger, cRegGer   := SPACE(LEN(GAV->GAV_REGGER))
Local oDesPac, cDesPac   := SPACE(LEN(GAV->GAV_NOME))
Local oLeito,  cLeito    := SPACE(LEN(GAV->GAV_LEITO))
Local oDatIDev, dDatIDev := CTOD("  /  /  ")
Local oDatFDev, dDatFDev := CTOD("  /  /  ")
Local oHorIDev, cHorIDev := SPACE(LEN(GD5->GD5_HORDES))
Local oHorFDev, cHorFDev := SPACE(LEN(GD5->GD5_HORDES))
Local oCodBar,  cCodBar  := Criavar("GD5_CODBAR")
Local oQuant,   nQuant   := Criavar("GD5_QTDDES")
Local oIndLot,  cIndLot  := SPACE(1)
Local oBarLot,  cBarLot  := IIf((TamSx3("GD5_CODDES")[1])<=15, SPACE(39), SPACE(54))
Local oCabec
Local cPerg   := "HSM30B" , cAlta := ""
Local cLstcpo := ""
Local aJoin   := {}
Local dDatIni := CTOD("  /  /  "), dDatFim := CTOD("  /  /  ")
Local cHorIni := "", cHorFim := ""
Local nPosGD5 := 0, nPosOri := 0
Local aRetDev := {}, aRetConf := {}, aIteLot := {"1=Produto+Data Validad+Lote+Sub-Lote", "2=Sub-Lote+Lote+Produto+Data Validad",;
"3=Produto+Lote+Sub-Lote+Data Validad", "4=Lote Fornec+Produto", "5=Produto+Data Validad+Lote","6=Sub-Lote"}
Local cDevAlta := GetNewPar("MV_DEVALTA", "S")

Private nOriCodDes  := 0, nOriTotQtd := 0, nOriSolici := 0, nOriLoteCt := 0, nOriNumLot := 0, nOriIteSol := 0
Private nOriSeqDes  := 0, nOriDtVali := 0, nOriLoteFo := 0, nOriDDespe := 0, nOriDPralt := 0, nOriCodBar := 0
Private nFimCodDes  := 0, nFimTotRec := 0, nFimTotDev := 0, nFimLoteCt := 0, nFimNumLot := 0, nFimProAlt := 0
Private nFimLoteFo  := 0, nFimDtVali := 0, nFimTotCon := 0, nFimDDespe := 0, nFimDPralt := 0, nFimCodBar := 0
Private cLctCodLoc  := ""
Private lMV_ProdAlt := GetMV("MV_PRODALT")

cAlta := HS_INIPADR("GCY",1,GAV->GAV_REGATE,"GCY_TPALTA",,.F.)

If !EMPTY(cAlta) .and. cDevAlta == "N"
	HS_MsgInf(STR0084,STR0019, STR0085) //"Atendimento com alta. Impossํvel devolver materiais e medicamentos "###"Valida็ใo dos itens da devolucao"
	Return(Nil)
EndIf

If !HS_VldPar(StrTran(aRotina[nOpc, 1], "&", ""))
	Return()
Endif

DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(cPerg)
	If (lRet := Pergunte(cPerg,.T.))
		dDatIni := MV_PAR01
		dDatFim := MV_PAR02
		cHorIni := MV_PAR03
		cHorFim := MV_PAR04
	Else
		Return(Nil)
	Endif

	cRegGer  := GAV->GAV_REGGER
	cDesPac  := GAV->GAV_NOME
	cLeito   := GAV->GAV_LEITO
	dDatIDev := dDatIni
	dDatFDev := dDatFim
	cHorIDev := cHorIni
	cHorFDev := cHorFim

	cFiltro := "GD5->GD5_DATDES >= '" + DTOS(dDatIDev) + "' AND GD5->GD5_DATDES <= '" + DTOS(dDatFDev) + "' AND "
	cFiltro += "GD5->GD5_HORDES >= '"+ cHorIDev + "' AND GD5->GD5_HORDES <= '"+ cHorFDev + "' AND "
	cFiltro += "GD5->GD5_REGATE = '"+ GAV->GAV_REGATE + "' AND GD5->GD5_CODLOC = '"+ GAV->GAV_CODLOC + "'"

	aAdd(aJoin, {     " JOIN " + RetSqlName("GCZ") + " GCZ"   , "" , "GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GD5.GD5_NRSEQG AND GCZ.GCZ_STATUS = '0'"     , ""})
	aAdd(aJoin, {     " JOIN " + RetSqlName("SB1") + " SB1"   , "SB1.B1_CODBAR" , "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GD5.GD5_CODDES "     , "GD5_CODBAR"})

	cLstCpo    := "GD5_CODBAR/GD5_CODDES/GD5_DDESPE/GD5_PROALT/GD5_DPRALT/GD5_QTDDES/GD5_LOTEFO/GD5_LOTECT/GD5_NUMLOT/GD5_SOLICI/GD5_ITESOL/GD5_SEQDES/GD5_DTVALI"

	HS_BDados("GD5", @aHGD5Ori, @aCGD5Ori, @nUGD5Ori, 1, ,cFiltro,,,cLstCpo,,,,,,.T.,,,,,,, aJoin,,"GD5_CODDES" )

	nOriCodBar := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_CODBAR"})
	nOriCodDes := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_CODDES"})
	nOriDDespe := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_DDESPE"})
	nOriProAlt := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_PROALT"})
	nOriDPralt := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_DPRALT"})
	nOriTotQtd := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_QTDDES"})
	nOriLoteCt := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_LOTECT"})
	nOriNumLot := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_NUMLOT"})
	nOriSolici := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_SOLICI"})
	nOriIteSol := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_ITESOL"})
	nOriSeqDes := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_SEQDES"})
	nOriLoteFo := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_LOTEFO"})
	nOriDtVali := aScan(aHGD5Ori, {|aVet| AllTrim(aVet[2]) == "GD5_DTVALI"})


	aHGD5Fim := FS_GerHead({"GD5_CODBAR", "GD5_CODDES", "GD5_DDESPE", , ;
	{ STR0086,"GD5_TOTREC" , "@E 99,999.9999", 11, 4, ".F." ,"" ,"N", "xxx", "V","" , "" },;
	{ STR0103,"GD5_TOTCON" , "@E 99,999.9999", 11, 4, ".F." ,"" ,"N", "xxx", "V","" , "" },;
	{ STR0087,"GD5_TOTDEV" , "@E 99,999.9999", 11, 4, ".F." ,"" ,"N", "xxx", "V","" , "" },;
	"GD5_PROALT", "GD5_DPRALT", "GD5_LOTEFO", "GD5_LOTECT", "GD5_NUMLOT", "GD5_DTVALI"})

	nFimCodBar := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_CODBAR"})
	nFimCodDes := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_CODDES"})
	nFimDDespe := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_DDESPE"})
	nFimProAlt := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_PROALT"})
	nFimDPralt := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_DPRALT"})
	nFimTotRec := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_TOTREC"})
	nFimLoteCt := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_LOTECT"})
	nFimNumLot := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_NUMLOT"})
	nFimLoteFo := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_LOTEFO"})
	nFimDtVali := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_DTVALI"})
	nFimTotCon := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_TOTCON"})
	nFimTotDev := aScan(aHGD5Fim, {|aVet| AllTrim(aVet[2]) == "GD5_TOTDEV"})

	For nPosGD5 := 1 to len(aCGD5Ori)
		If (nPosOri := aScan(aCGD5Fim, {| aVet | aVet[nFimCodBar]  + aVet[nFimCodDes] + aVet[nFimProAlt]+ aVet[nFimLoteFo] + aVet[nFimLoteCt] + aVet[nFimNumLot] + Dtos(aVet[nFimDtVali]) == aCGD5Ori[nPosGD5, nOriCodBar] + aCGD5Ori[nPosGD5, nOriCodDes] +  aCGD5Ori[nPosGD5, nOriProAlt] + aCGD5Ori[nPosGD5, nOriLoteFo] + aCGD5Ori[nPosGD5, nOriLoteCt] + aCGD5Ori[nPosGD5, nOriNumLot] + Dtos(aCGD5Ori[nPosGD5, nOriDtVali]) })) == 0

			aRetConf := HS_VLCONFI(aCGD5Ori[nPosGD5, nOriSolici],, aCGD5Ori[nPosGD5, nOriSeqDes],, .T.)

			aAdd(aCGD5Fim, {aCGD5Ori[nPosGD5, nOriCodBar],;
			aCGD5Ori[nPosGD5, nOriCodDes],;
			aCGD5Ori[nPosGD5, nOriDDespe],;
			aCGD5Ori[nPosGD5, nOriTotQtd],;
			aRetConf[2],;
			0,;
			aCGD5Ori[nPosGD5, nOriProalt],;
			aCGD5Ori[nPosGD5, nOriDPralt],;
			aCGD5Ori[nPosGD5, nOriLoteFo],;
			aCGD5Ori[nPosGD5, nOriLoteCt],;
			aCGD5Ori[nPosGD5, nOriNumLot],;
			aCGD5Ori[nPosGD5, nOriDtVali],;
			IIF(aRetConf[2] == aCGD5Ori[nPosGD5, nOriTotQtd], .T., .F.)})
		Else
			aCGD5Fim[nPosOri, nFimTotRec] += aCGD5Ori[nPosGD5, nOriTotQtd]
			aRetConf := HS_VLCONFI(aCGD5Ori[nPosGD5, nOriSolici],, aCGD5Ori[nPosGD5, nOriSeqDes],, .T.)
			aCGD5Fim[nPosOri, nFimTotCon] += aRetConf[2]

			If aCGD5Fim[nPosOri, nFimTotCon] == aCGD5Fim[nPosOri, nFimTotRec]
				aCGD5Fim[nPosOri, len(aCGD5Fim[nPosOri])] := .T.
			Else
				aCGD5Fim[nPosOri, len(aCGD5Fim[nPosOri])] := .F.
			Endif

		Endif

	Next nPosGD5

	If Empty(aCGD5Fim)
		HS_MsgInf(STR0077, STR0019, STR0085) //"Nenhum item selecionado com os parโmetros informados."###"Valida็ใo dos itens da devolucao"
		Return()
	Endif

	ASort(aCGD5Fim,,,{|x,y| X[2] + X[7] + X[8] <  Y[2] + Y[7] + Y[8] })

	aSize := MsAdvSize(.T.)
	aObjects := {}

	AAdd( aObjects, { 100, 030, .T., .T.,.T. } )
	AAdd( aObjects, { 100, 070, .T., .T. } )

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlgDev TITLE STR0088 From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel //"Consulta itens da solicitacao" //"Devolu็ใo dos itens da solicita็ใo"

	oCabec	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgDev,,,,,, aPObjs[1, 3], aPObjs[1, 4])
	oCabec:Align := CONTROL_ALIGN_TOP

	cIndLot:= SuperGetMV("MV_TPINDIC",,"1")

	@ 010, 003 Say OemToAnsi(STR0080) Size 040, 009 OF oCabec PIXEL COLOR CLR_BLUE //"Prontuario"
	@ 009, 035 MSGet oRegger var cRegger Size 040, 009 OF oCabec PICTURE "@!" PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 010, 130 Say OemToAnsi(STR0081) Size 040, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Descri็ใo"
	@ 009, 160 MSGet oDesPac var cDesPac Size 100, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 010, 310 Say OemToAnsi(STR0042) Size 020, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Leito"
	@ 009, 328 MSGet oLeito var cLeito Size 040, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 030, 003 Say OemToAnsi(STR0082) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Data Inicial"
	@ 029, 035 MSGet oDatIDev var dDatIDev Size 040, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 030, 130 Say OemToAnsi(STR0083) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Data Final"
	@ 029, 160 MSGet oDatFDev var dDatFDev Size 040, 009 OF oCabec PIXEL COLOR CLR_BLACK  WHEN .F.

	@ 030, 298 Say OemToAnsi(STR0089) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"Quantidade"
	@ 029, 328 MSGet oQuant var nQuant Size 040, 009 OF oCabec PICTURE "@E 999,999.9999" VALID HS_VQtdMM(nQuant)PIXEL COLOR CLR_BLACK

	@ 050, 003 Say OemToAnsi(STR0090) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE    //"CB Produto"
	@ 049, 035 MSGet oCodBar var cCodBar Size 050, 009 OF oCabec VALID FS_VLDDEV(@cCodBar, @nQuant, @oCodBar, @oQuant, oGD5Fim, GAV->GAV_CODLOC, VAL(cIndLot), .T.) PIXEL COLOR CLR_BLACK

	@ 050, 124 Say OemToAnsi(STR0124) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE  //"Pesq. CB Lote"
	@ 049, 160 MSCOMBOBOX oIndLot VAR cIndLot  ITEMS aIteLot SIZE 110,09 PIXEL OF oCabec PIXEL COLOR CLR_BLUE


	@ 050, 298 Say OemToAnsi(STR0125) Size 050, 009 OF oCabec PIXEL COLOR CLR_BLUE   //"CB Lote"
	@ 049, 328 MSGet oBarLot var cBarLot Size 130, 009 OF oCabec VALID FS_VLDDEV(@cBarLot, @nQuant, @oBarLot, @oQuant, oGD5Fim, GAV->GAV_CODLOC, VAL(cIndLot)) PIXEL COLOR CLR_BLACK

	oGD5Fim := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],nGDOpc,,,,,,,,,,, aHGD5Fim, aCGD5Fim)
	oGD5Fim :oBrowse:align:= CONTROL_ALIGN_ALLCLIENT


	ACTIVATE MSDIALOG oDlgDev ON INIT EnchoiceBar(oDlgDev,{||nOpcDlg := 1	, oDlgDev:End()},	{||nOpcDlg := 0, oDlgDev:End()},,)


	If  nOpcDlg == 0
		While __lSx8
			RollBackSxe()
		End
	ElseIf nOpcDlg == 1
		Begin Transaction
		aRetDev    := FS_GRVDEV(GAV->GAV_CODLOC, GAV->GAV_REGATE, oGD5Fim:aCols, aCGD5Ori)
		If !Empty(aRetDev[1])
			HSPAHR04(aRetDev[1], aRetDev[2]) //NumDev, CodLocFar
		EndIf
		End Transaction

		While __lSx8
			ConfirmSx8()
		End
	Endif


Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDDEV บAutor  ณMario Arizono       บ Data ณ  06/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida devolucao de mat/med.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VLDDEV(cCodBar, nQuant, oCodBar, oQuant, oGD5Fim, cCodLoc, nIndSB8, lBarPro)
Local aArea := GetArea()
Local cCodDes := ""
Local nPosGD := 0, nTotDev := 0
Local cAlmOri := HS_IniPadr("GCS", 1, cCodLoc, "GCS_ARMFAR",, .F.)
Local aVetDados:={}
Default lBarPro := .F.

If !Empty(cCodBar)
	If lBarPro
		If !HS_SeekRet("SB1", "'" + cCodBar + "'", 5, .F.)
			If HS_SeekRet("GAP", "'" + cCodBar + "'", 1, .F.)
				If !HS_SeekRet("SB1", "GAP->GAP_CODIGO", 1, .F.)
					HS_MsgInf(STR0091, STR0019, STR0092) //"Produto cadastrado no c๓digo de barras secundario nใo existe no cadastro",###"Atencao" //"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
					RestArea(aArea)
					Return(.F.)
				EndIf
			Else
				HS_MsgInf(STR0121, STR0019, STR0122) //"Produto nใo encontrado com este c๓digo de barras"###"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
				RestArea(aArea)
				Return(.F.)
			EndIf
		EndIf
	Else

		If nIndSB8==6
			aVetDados:=	HS_Ind6(cCodBar)
			If Empty(aVetDados)
				HS_MsgInf(STR0126, STR0019,STR0122)//"Lote nใo encontrado."##"Atencao"##"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
				RestArea(aArea)
				Return(.F.)
			Endif

			If !HS_SeekRet("SB1", "'" + aVetDados[1][6] + "'", 1, .F.)
				HS_MsgInf(STR0093, STR0019, STR0092) //"Produto nใo encontrado nos itens da devolu็ใo"###"Valida็ใo dos itens da devolu็ใo"
				RestArea(aArea)
				Return(.F.)
			EndIf
			cCodDes   := aVetDados[1][6]
			__cLOTECT := aVetDados[1][3]
			__cNUMLOT := aVetDados[1][1]
		Else
			If !HS_SeekRet("SB8", "'" + (HS_RCBLote(AllTrim(cCodBar), cAlmOri, nIndSB8)) + "'", IIF(nIndSB8 == 5, 1, nIndSB8), .F.)
				HS_MsgInf(STR0126, STR0019,STR0122)//"Lote nใo encontrado."##"Atencao"##"Valida็ใo do c๓digo de barras dos materiais e medicamentos"
				Return(.F.)
			Else
				cCodDes   := SB8->B8_PRODUTO
				__cLOTECT := SB8->B8_LOTECTL
				__cNUMLOT := SB8->B8_NUMLOTE
			EndIf
		Endif
	Endif

	If Empty(cCodDes)
		cCodDes := SB1->B1_COD
	Endif


	If FS_DatDev(cCodDes, cCodLoc)
		If Rastro(cCodDes)
			If lBarPro
				FS_SelLote(cCodDes, oGD5Fim)
			Endif
		Else
			If aScan(oGD5Fim:aCols, {| aVet | aVet[nFimProAlt] == PADR(cCodDes, Len(oGD5Fim:aCols[oGD5Fim:nAt, nFimProAlt])) .And. !aVet[len(aVet)]}) <> 0
				nPosGD := FS_MNTALTE(cCodDes, oGD5Fim)
			Endif
		Endif

		If Rastro(cCodDes)
			If (nPosGD := aScan(oGD5Fim:aCols, {| aVet | aVet[nFimProAlt] + aVet[nFimLoteCt] + aVet[nFimNumLot] == PADR(cCodDes, Len(oGD5Fim:aCols[oGD5Fim:nAt, nFimProAlt])) + __cLoteCT + __cNumLot .And. !aVet[len(aVet)]})) == 0
				If (nPosGD := aScan(oGD5Fim:aCols, {| aVet | aVet[nFimCodDes] + aVet[nFimLoteCt] + aVet[nFimNumLot] == PADR(cCodDes, Len(oGD5Fim:aCols[oGD5Fim:nAt, nFimCodDes])) + __cLoteCT + __cNumLot .And. Empty(aVet[nFimProAlt]) .And. !aVet[len(aVet)]})) == 0
					HS_MsgInf(STR0093, STR0019, STR0092) //"Produto nใo encontrado nos itens da devolu็ใo"###"Valida็ใo dos itens da devolu็ใo"
				Endif
			EndIf
		Else
			If nPosGD == 0
				If (nPosGD := aScan(oGD5Fim:aCols, {| aVet | aVet[nFimProAlt] == PADR(cCodDes, Len(oGD5Fim:aCols[oGD5Fim:nAt, nFimProAlt])) .And. !aVet[len(aVet)]})) == 0
					If (nPosGD := aScan(oGD5Fim:aCols, {| aVet | aVet[nFimCodDes] == PADR(cCodDes, Len(oGD5Fim:aCols[oGD5Fim:nAt, nFimCodDes])) .And. Empty(aVet[nFimProAlt]) .And. !aVet[len(aVet)] })) == 0
						HS_MsgInf(STR0093, STR0019, STR0092) //"Produto nใo encontrado nos itens da devolu็ใo"###"Valida็ใo dos itens da devolu็ใo"
					Endif
				EndIf
			Endif
		Endif

		If nPosGD > 0
			nTotDev := oGD5Fim:aCols[nPosGD, nFimTotDev] + nQuant
			If nTotDev > oGD5Fim:aCols[nPosGD, nFimTotRec] - oGD5Fim:aCols[nPosGD, nFimTotCon]
				HS_MsgInf(STR0094, STR0019, STR0092) //"Quantidade a devolver maior que a quantidade recebida."###"Valida็ใo dos itens da devolu็ใo"
			Else
				oGD5Fim:aCols[nPosGD, nFimTotDev] := nTotDev
				If oGD5Fim:aCols[nPosGD, nFimTotRec] == oGD5Fim:aCols[nPosGD, nFimTotDev]
					oGD5Fim:aCols[nPosGD, Len(oGD5Fim:aCols[nPosGD])] := .T.
				EndIf
				oGD5Fim:oBrowse:Refresh()
			Endif
		Endif

		cCodBar := IIF(lBarPro, Criavar("GD5_CODBAR"), IIf((TamSx3("GD5_CODDES")[1])<=15, SPACE(39), SPACE(54)))
		nQuant  := CriaVar("GD5_QTDDES")
		oCodBar:Refresh()
		oQuant:Refresh()
		oCodBar:SetFocus()
	Endif
Endif
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVDEV บAutor  ณMario Arizono       บ Data ณ  07/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava devolucao de mat/med.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRVDEV(cCodLoc, cRegate, aColsFim, aColsOri )
Local aArea   := GetArea()
Local nForDev := 0, nIteDev := 0, nTotDev := 0
Local nItens  := 0, nCabec  := 0, nCont   := 0
Local lAchouDev := .T.
Local aConEst := {}, aMovest := {}, aVldSet := {}, aRetConf := {}
Local aColSet := {}, aColFar := {}, aCItens := {}
Local cAlmori := "", cCCusto := "", cArmfar := ""

Local cGbdNumDev := ""
Local cCodPMov := ""

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

DbSelectArea("GCS")
DbSetOrder(1)
DbSeek(xFilial("GCS") + cCodLoc)
cAlmori    := GCS->GCS_ARMSET
cCCusto    := GCS->GCS_CODCCU
cArmfar    := HS_ArmFarS(.T.)

For nForDev := 1 To Len(aColsFim)
	If aColsFim[nForDev,nFimTotDev]== 0
		Loop
	Endif

	For nIteDev := 1 to len(aColsOri)

		If aColsOri[nIteDev, nOriCodDes] <> aColsFim[nForDev,nFimCodDes]
			Loop
		Else
			If Rastro(aColsOri[nIteDev, nOriCodDes])
				If aColsOri[nIteDev, nOriLoteCt]<> aColsFim[nForDev, nFimLoteCt] .Or. aColsOri[nIteDev, nOriNumLot]<> aColsFim[nForDev, nFimNumLot]
					Loop
				Endif
			Endif

			If aColsFim[nForDev,nFimTotDev] > nTotDev
				cCodPMov := PadR(AllTrim(aColsOri[nIteDev, IIf(lMV_ProdAlt .And. !Empty(aColsOri[nIteDev, nOriProAlt]), nOriProAlt, nOriCodDes)]), Len(SB1->B1_COD))
				If Empty(aColsOri[nIteDev, nOriSolici])
					aAdd(aColSet, {cCodPMov, ;
					aColsOri[nIteDev, nOriLoteCt], ;
					aColsOri[nIteDev, nOriNumLot], ;
					IIF(aColsFim[nForDev,nFimTotDev] - nTotDev >= aColsOri[nIteDev, nOriTotQtd], aColsOri[nIteDev, nOriTotQtd], aColsFim[nForDev,nFimTotDev]- nTotDev), ;
					IIF(aColsFim[nForDev,nFimTotDev] - nTotDev >= aColsOri[nIteDev, nOriTotQtd], aColsOri[nIteDev, nOriTotQtd], aColsFim[nForDev,nFimTotDev]- nTotDev), ;
					"", ;
					"", ;
					aColsOri[nIteDev, nOriSeqDes], ;
					aColsOri[nIteDev, nOriDtVali]})
					nTotDev += aColSet[len(aColSet), 4]
				Else
					aRetConf := HS_VLCONFI(aColsOri[nIteDev, nOriSolici], cCodPMov, aColsOri[nIteDev, nOriSeqDes],IIF(aColsFim[nForDev,nFimTotDev]- nTotDev >= aColsOri[nIteDev, nOriTotQtd],;
					aColsOri[nIteDev, nOriTotQtd],aColsFim[nForDev,nFimTotDev]- nTotDev) )
					If aRetConf[1]
						aAdd(aColFar, {cCodPMov, ;
						"", ;
						"", ;
						aRetConf[2], ;
						0, ;
						aColsOri[nIteDev, nOriSolici], ;
						aColsOri[nIteDev, nOriIteSol], ;
						aColsOri[nIteDev, nOriSeqDes], ;
						CTOD("  /  /  ")})
						nTotDev += aColFar[len(aColFar), 4]
					Endif
				Endif
			Endif
		Endif
	Next nIteDev
	nTotDev := 0
Next nForDev

If !Empty(aColSet) .Or. !Empty(aColFar)
	aCItens := {aColSet,aColFar}
Endif

For nCabec := 1 to Len(aCItens)
	If Len(aCItens[nCabec]) > 0

		nCont := 1

		DbselectArea("GBD")
		DbSetOrder(1)

		M->GBD_NUMDEV := HS_VSxeNum("GBD", "M->GBD_NUMDEV", 1)
		ConfirmSx8()

		RecLock("GBD", .T.)
		GBD->GBD_FILIAL := xFilial("GBD")
		GBD->GBD_NUMDEV := M->GBD_NUMDEV
		cGbdNumDev      := M->GBD_NUMDEV
		GBD->GBD_REGATE := cRegate
		GBD->GBD_CODLOC := cCodLoc
		if Hs_ExisDic({{"C","GBD_ALMORI"}},.F.)
			GBD->GBD_ALMORI := cArmfar
		Endif
		GBD->GBD_DATDEV := dDataBase
		GBD->GBD_FLGDEV := IIf(nCabec == 1, "2", "0")
		GBD->GBD_LOGARQ := HS_LogArq()
		MsUnLock()

		For nItens := 1 To Len(aCItens[nCabec])
			DbSelectArea("GBE")
			DbSetOrder(1)
			RecLock("GBE", .T.)
			GBE->GBE_FILIAL := xFilial("GBE")
			GBE->GBE_NUMDEV := M->GBD_NUMDEV
			GBE->GBE_ITEDEV := StrZero(nCont++, Len(GBE->GBE_ITEDEV))
			GBE->GBE_SOLICI := aCItens[nCabec][nItens][6]
			GBE->GBE_ITESOL := aCItens[nCabec][nItens][7]
			GBE->GBE_DATSOL := dDataBase
			GBE->GBE_PRODEV := aCItens[nCabec][nItens][1]
			GBE->GBE_QTDADV := aCItens[nCabec][nItens][4]
			GBE->GBE_QTDDEV := IIf(nCabec == 1, aCItens[nCabec][nItens][5], 0)
			GBE->GBE_SEQDES := aCItens[nCabec][nItens][8]
			GBE->GBE_LOGDEV := HS_LogArq()
			GBE->GBE_LOGARQ := HS_LogArq()
			MsUnlock()

			HS_GrvGnr(GBE->GBE_SEQDES , GBE->GBE_SOLICI, GBE->GBE_ITESOL, GBE->GBE_PRODEV, GBE->GBE_QTDADV)

			If nCabec == 1
				If aVldSet := aConEst := (HS_CONEST(aCItens[nCabec][nItens][1], cCodLoc))[1]

					aMovest:= HS_MovEst("E", aCItens[nCabec][nItens][1], aCItens[nCabec][nItens][5], cAlmori, cUserName, cCCusto,, ;
					aCItens[nCabec][nItens][3],  aCItens[nCabec][nItens][2], ;
					aCItens[nCabec][nItens][9],,, dDataBase, cRegate)
				Else
					aMovest := {.T.}
				Endif

				If aMovest[1]
					lAchouDev := !Empty(HS_INIPADR("GD5", 1, aCItens[nCabec][nItens][8],"GD5_SEQDES",,.F.))
					If lAchouDev
						RecLock("GD5", .F., .F.)
						If aCItens[nCabec][nItens][5] == GD5->GD5_QTDDES
							DbDelete()
						Else
							GD5->GD5_QTDDES -= aCItens[nCabec][nItens][5]
						EndIf
						MsUnlock()
					EndIf
				Endif
			Endif
		Next Itens
	EndIf
Next nCabec

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

RestArea(aArea)
Return({cGbdNumDev, cCodLoc})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DATDEV บAutor  ณMario Arizono       บ Data ณ  07/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida datas para devolucao.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DatDev(cCodDes, cCodLoc)
Local dMvUlmes := GETMV("MV_ULMES")
Local cDevAlta := GetNewPar("MV_DEVALTA", "S")
Local lRet     := .T.
Local aArea    := GetArea()
Local dDatMov := dDatabase
Local cHorMov := Time()

DbSelectArea("GCY")

If !(lRet := !(dDatMov < GCY->GCY_DATATE .Or. (dDatMov == GCY->GCY_DATATE .And. cHorMov < GCY->GCY_HORATE)))
	HS_MsgInf(STR0095, STR0019, STR0096) //"Devolu็ใo nใo pode ser gerada com data anterior a data do atendimento"###"Valida็ใo de data de devolu็ใo"
ElseIf cDevAlta == "N" .And. !Empty(GCY->GCY_DATALT) .And. !(lRet := !(dDatMov > GCY->GCY_DATALT .Or. (dDatMov == GCY->GCY_DATALT .And. cHorMov > GCY->GCY_HORALT)))
	HS_MsgInf(STR0099, STR0100, STR0096) //"Devolu็ใo nใo pode ser gerada com data posterior a data da alta"###"Aten็ใo"###"Valida็ใo de data de devolu็ใo"
ElseIf !Empty(dMvUlmes) .AND. !(lRet := !(!(dDatMov > dMvUlmes)))
	HS_MsgInf(STR0097, STR0019, STR0096) //"Devolu็ใo nใo pode ser gerada com data menor ou igual ao ๚ltimo fechamento de estoque"###"Valida็ใo de data de devolu็ใo"
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SELLOTEบ Autor ณ Mario Arizono      บ Data ณ 12/12/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SelLote(cCodPMov, oLote)
Local aArea := GetArea()
Local cLstCpo := "", cFiltro := ""
Local aHeader := {}, aCols := {}
Local nPos    := 0
Local oDlg, oDev
Local nNUMLOTE := 0
Local nLOTECTL := 0

For nPos := 1 to len(oLote:aCols)
	If ( (oLote:aCols[nPos, nFimCodDes] == cCodPMov .And. Empty(oLote:aCols[nPos, nFimProAlt])) .Or. oLote:aCols[nPos, nFimProAlt] == cCodPMov ) .And. ;
		!Empty(oLote:aCols[nPos, nFimLoteCt]) .And. !(oLote:aCols[nPos, len(oLote:aCols[nPos])])
		aAdd(aCols, {oLote:aCols[nPos, nFimCodDes], oLote:aCols[nPos, nFimLoteCt], oLote:aCols[nPos, nFimNumLot],.F.})
	Endif
Next nPos

If Len(aCols) > 0
	aHeader := FS_GerHead({"GD5_CODDES", "GD5_LOTECT", "GD5_NUMLOT"})

	nLOTECTL := aScan(aHeader, {| aVet | aVet[2] == "GD5_LOTECT"})
	nNUMLOTE := aScan(aHeader, {| aVet | aVet[2] == "GD5_NUMLOT"})

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )
	nPosSB8 := 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi (STR0098) From 000, 000 To 500, 700 Of oMainWnd PIXEL //"Consulta Lotes"
	oDev := MsNewGetDados():New(aPObj[1, 1], aPObj[1, 2], aPObj[1, 3], aPObj[1, 4], 0,,,,,,,,,, oDlg, aHeader, aCols)
	oDev:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oDev:oBrowse:BlDblClick := {|| __cLOTECT := oDev:aCols[oDev:oBrowse:nAt, nLoteCtl] , __cNUMLOT := oDev:aCols[oDev:oBrowse:nAt, nNumLote], oDlg:End()}
	ACTIVATE MSDIALOG oDlg CENTERED

EndIf

RestArea(aArea)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GerHeadบ Autor ณ Mario Arizono      บ Data ณ 12/12/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerHead(aCampos)
Local aArea      := GetArea()
Local nForCampos := 0
Local aHeader    := {}

DbSelectArea("SX3")
DbSetOrder(2)

For nForCampos := 1 to len(aCampos)
	If (ValType(aCampos[nForCampos]) == "C")
		DbSeek(aCampos[nForCampos])
		aAdd(aHeader, { TRIM(X3Titulo())	, ;
		SX3->X3_CAMPO   	, ;
		SX3->X3_PICTURE 	, ;
		SX3->X3_TAMANHO 	, ;
		SX3->X3_DECIMAL 	, ;
		SX3->X3_VALID   	, ;
		SX3->X3_USADO   	, ;
		SX3->X3_TIPO    	, ;
		SX3->X3_F3      	, ;
		SX3->X3_CONTEXT 	, ;
		SX3->X3_CBOX    	, ;
		SX3->X3_RELACAO 	, ;
		SX3->X3_WHEN    	, ;
		SX3->X3_VISUAL  	, ;
		SX3->X3_VLDUSER 	, ;
		SX3->X3_PICTVAR 	, ;
		X3Obrigat(SX3->X3_CAMPO) })
	ElseIf (ValType(aCampos[nForCampos]) == "A")
		aAdd(aHeader, {TRIM(aCampos[nForCampos][1]),;
		aCampos[nForCampos][2]	,;
		aCampos[nForCampos][3]	,;
		aCampos[nForCampos][4]	,;
		aCampos[nForCampos][5]	,;
		aCampos[nForCampos][6]	,;
		aCampos[nForCampos][7]	,;
		aCampos[nForCampos][8]	,;
		aCampos[nForCampos][9]	,;
		aCampos[nForCampos][10],;
		aCampos[nForCampos][11],;
		aCampos[nForCampos][12]})
	EndIf

Next nForCampos
RestArea(aArea)
Return(aHeader)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLCONFIบ Autor ณ Mario Arizono      บ Data ณ 15/01/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se a devolucao ja possui alguma confirmacao de      บฑฑ
ฑฑบ          ณ devolucao.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VLCONFI(Solici, CodPro, SeqDes, nQtdDev, lPesqIni)
Local aArea := GetArea()
Local lRet  := .T.
Local cSql  := ""
Local nReg  := 0, nRet := 0, nQtdGD5 := 0

Default lPesqIni := .F.

cSql := "SELECT SUM(GBE.GBE_QTDADV - GBE.GBE_QTDDEV) AS SOMA"
cSql += " FROM " + RetSQLName("GBE") + " GBE "
cSql += " JOIN " + RetSqlName("GBD") + " GBD ON GBD.GBD_FILIAL = '" + xFilial("GBD") + "' AND GBD.D_E_L_E_T_ <> '*' AND GBD.GBD_NUMDEV = GBE.GBE_NUMDEV "
cSql += " WHERE GBE.GBE_FILIAL = '" + xFilial("GBE") + "' AND GBE.D_E_L_E_T_ <> '*'AND "
If !lPesqIni
	cSql += " GBE.GBE_SOLICI = '" + Solici + "' AND GBE.GBE_PRODEV = '" + CodPro + "' AND GBE.GBE_SEQDES = '"+ SeqDes + "' AND "
Else
	cSql += " GBE.GBE_SOLICI = '" + Solici + "' AND  GBE.GBE_SEQDES = '"+ SeqDes + "' AND "
Endif
cSql += " GBD.GBD_FLGDEV <> '2' "
TCQUERY cSql NEW ALIAS "QRY"
nReg:= QRY->SOMA
dbCloseArea()

If !lPesqIni
	DbSelectArea("GD5")
	DbSetOrder(1)
	If DbSeek(xFilial("GD5") + SeqDes)
		If GD5->GD5_QTDDES <= nReg
			lRet := .F.
		Else
			nQtdGD5 := GD5->GD5_QTDDES - nReg
			If nQtdDev > nQtdGD5
				nRet:= nQtdGD5
			Else
				nRet := nQtdDev
			Endif
		Endif
	Endif
Else
	nRet := nReg
Endif
RestArea(aArea)
Return({lRet, nRet})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M30PROAบ Autor ณ Daniel Peixoto     บ Data ณ  16/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se o produto digitado possui produto alternativo  บฑฑ
ฑฑบ          ณ e lan็a na GD5                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Farmacia)                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M30PROA(cCodBar)
Local aArea   := GetArea()
Local cProAlt := ""
Local aMovPro := {}

If !Empty(cProAlt := HS_PROALT(cCodBar))
	oGDMM:aCols[oGDMM:oBrowse:nAt, nMMProAlt] := cProAlt
	oGDMM:aCols[oGDMM:oBrowse:nAt, nMMDPrAlt] := HS_IniPadR("SB1", 1, cProAlt, "B1_DESC",, .F.)
	AADD(aMovPro,{cCodBar, cProAlt})
EndIf

RestArea(aArea)
Return(aMovPro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MNTALTEบ Autor ณ Mario Arizono      บ Data ณ 09/04/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta tela para escolha de qual alternativo     บฑฑ
ฑฑบ          ณ sera devolvido                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MNTALTE(cCodPMov, oGd5Alt)
Local aArea := GetArea()
Local aHeader := {}, aCols := {}
Local nPos    := 0, nPosProd := 0
Local oDlg, oProalt
Local nCODDES := 0
Local nPROALT := 0

For nPos := 1 to len(oGd5Alt:aCols)
	If (!Empty(oGd5Alt:aCols[nPos, nFimProalt]) .And. oGd5Alt:aCols[nPos, nFimProAlt] == cCodPMov .And. !(oGd5Alt:aCols[nPos, len(oGd5Alt:aCols[nPos])]))
		aAdd(aCols, {oGd5Alt:aCols[nPos, nFimCodDes], oGd5Alt:aCols[nPos, nFimDDespe], oGd5Alt:aCols[nPos, nFimProalt], oGd5Alt:aCols[nPos, nFimDPralt], .F.})
	Endif
Next nPos

If Len(aCols) > 1
	aHeader := FS_GerHead({"GD5_CODDES", "GD5_DDESPE", "GD5_PROALT", "GD5_DPRALT"})

	nCODDES := aScan(aHeader, {| aVet | aVet[2] == "GD5_CODDES"})
	nPROALT := aScan(aHeader, {| aVet | aVet[2] == "GD5_PROALT"})

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE OemToAnsi (STR0101) From 000, 000 To 500, 700 Of oMainWnd PIXEL  //"Consulta Produto Alternativo"
	oProalt := MsNewGetDados():New(aPObj[1, 1], aPObj[1, 2], aPObj[1, 3], aPObj[1, 4], 0,,,,,,,,,, oDlg, aHeader, aCols)
	oProalt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oProalt:oBrowse:BlDblClick := {|| nPosProd := aScan(oGd5Alt:aCols, {| aVet | aVet[nFimProAlt] + aVet[nFimCodDes] == oProalt:aCols[oProalt:nAt, nProalt] +  oProalt:aCols[oProalt:nAt, nCodDes] .And. !aVet[len(aVet)]}), oDlg:End()}
	ACTIVATE MSDIALOG oDlg CENTERED

EndIf

RestArea(aArea)

Return(nPosProd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TriM30 บAutor  ณDaniel Peixoto      บ Data ณ  21/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEvolu็ใo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_TriM30(cAliasM30, nRegM30, nOpcM30)
Local aArea := GetArea()

Private __cMa7Aces := "E" // Elabora็ใo
Private nQtdAnm    := 0   // Quantidade de historico de anamnese
Private nVisAnm    := 0   // 0=Visualiza anamnese de outro profissional
Private cLocCon    := ""  //GCY->GCY_CODLOC
Private lFilExcl   := HS_ExisDic({{"C", "GBJ_PROEXC"}},.F.)
Private lVerFil	 := HS_ExisDic({{"C", "GBJ_VIFILI"}},.F.)
__Reserv := GAV->GAV_RESERV

DBSelectArea("GCY")
DbSetOrder(1)//REGATE
DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

cLocCon    := GCY->GCY_CODLOC

If Len(aCodUsr) > 2
	If aCodUsr[3]
		__cMa7Aces := "C"
	EndIf
EndIf

If Empty(aCodUsr[2])
	aCodUsr[1] := .T.
	aCodUsr[2] := IIf(Empty(GCY->GCY_CRMANM), GCY->GCY_CODCRM, GCY->GCY_CRMANM)
	If Len(aCodUsr) > 2
		aCodUsr[3]:= .F.
	EndIf
EndIf

HS_MntMA7("GCY", GCY->(RecNo()), Iif(GAV->GAV_RESERV == "Y", 2,3), ,Iif(GAV->GAV_RESERV == "Y", "",GAV->GAV_RESERV))

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TranRN บAutor  ณBruno S. P. Santos  บ Data ณ  26/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTransferencia RN                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TranRN(cOldRegAte,cOldQuarto, cOldSetor, cOldLeito, cOldTipo, cReserv)
Local aArea   := GetArea()
Local lRet    := .F.
Local dDatHis := dDataBase
Local cHorHis := Time()
Local cCCUSRN := PadR(GetMv("MV_CCUSRN"), Len(GAV->GAV_CODLOC))	// Setor (CC) Padrใo para Interna็ใo dos Rec้m-Nascidos
Local cQUARRN := PadR(GetMv("MV_QUARRN"), Len(GAV->GAV_QUARTO))	// Quarto Padrใo para Interna็ใo dos Rec้m-Nascidos
Local lAchou  := .F.

cGcsTipLoc :=  '3'

If(cOldTipo == '0')
	If !Pergunte("HSPTRA")
		return(lRet)
	EndIf
EndIf

DbSelectArea("GAV")
DbSetOrder(1)
If !DbSeek(xFilial("GAV") + MV_PAR01 + MV_PAR02 + MV_PAR03)
	HS_MsgInf(STR0119 + "[" + MV_PAR01 + " - " + MV_PAR02 + " - " + MV_PAR03 + "]" + STR0117, STR0100, STR0118)  //"Leito "###" nใo encontrado"###"Aten็ใo"###"Movimenta็ใo de Hotelaria"
	Return(lRet)
ElseIf GAV->GAV_STATUS <> "0"
	HS_MsgInf(STR0119 + "[" + MV_PAR01 + " - " + MV_PAR02 + " - " + MV_PAR03 + "]" + STR0120, STR0100, STR0118)  //"Leito "###" nใo encontra-se vago"###"Aten็ใo"###"Movimenta็ใo de Hotelaria"
	Return(lRet)
EndIf

If !APMSGYESNO(Iif(cOldTipo == '0',STR0034,STR0114)) //"Confirma a Transferencia de Leito ?"###"Confirma o retorno do RN para o ber็แrio?"
	return(lRet)
EndIf

/*Desalocando Leito de Origem*/
HS_GrvMovH(cOldRegAte, cOldSetor, cOldQuarto, cOldLeito,  "8", dDatHis, cHorHis,,,,,,,cReserv,.F.)

DbSelectArea("GB2")
DbSetOrder(1)
DbSeek(xFilial("GB2") + cOldRegAte + cReserv)
RecLock("GB2", .F.)
GB2->GB2_UTINEO = Iif(cOldTipo == '0',"1","0")
MsUnLock()

If (cOldTipo == '0')
	If FS_VlUtiRn(MV_PAR01,MV_PAR02,MV_PAR03)
		/*Liberando Ber็แrio*/
		HS_GrvMovH("", cOldSetor, cOldQuarto, cOldLeito, "3", dDatHis, cHorHis,,,,,,, cReserv,.F.)
		HS_GrvMovH("", cOldSetor, cOldQuarto, cOldLeito, "4", dDatHis, cHorHis,,,,,,, cReserv,.F.)
		HS_GrvMovH("", cOldSetor, cOldQuarto, cOldLeito, "5", dDatHis, cHorHis,,,,,,, cReserv,.F.)

		/*Alocando Leito UTI*/
		HS_GrvMovH(cOldRegAte, MV_PAR01, MV_PAR02, MV_PAR03, "0", dDatHis, cHorHis,,,,,,,cReserv,.F.)
		lRet := .T.
	EndIf
Else
	DbSelectArea("GAV")
	DbSetOrder(1)
	DbSeek(xFilial("GAV") + cCCUSRN + IIf(!Empty(cQuarRN), cQuarRN, ""))
	Do While !Eof() .and. xFilial("GAV") == GAV->GAV_FILIAL .and. GAV->GAV_CODLOC == cCCUSRN .and. Iif(!Empty(cQuarRN), GAV->GAV_QUARTO == cQuarRN, .T.)

		If Empty(GAV->GAV_REGATE)
			lAchou := .T.
			Exit
		EndIf

		DbSkip()
	Enddo
	If !lAchou
		MsgStop(STR0008) //"Nao foi possivel encontrar leito vago para o recem nascido!"
		lRet := .F.
	Else
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY") + cOldRegAte)

		HS_GrvMovH(GB2->GB2_REGATE, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, "0", dDatHis, cHorHis,,,,,,,cReserv,.F.)
		lRet := .T.
	EndIf
EndIf
cGcsTipLoc :=  '38'
RestArea(aArea)
Return(lRet)


Static Function FS_VlUtiRn(cSetor, cQuarto, cLeito)
Local lRet  := .T.
Local aArea := GetArea()

DbSelectArea("GAV")
DbSetOrder(1)
If DbSeek(xFilial("GAV") + cSetor + IIf(!Empty(cQuarto), cQuarto, "") + IIf(!Empty(cLeito), cLeito, ""))
	If(GAV->GAV_TIPO # "4").Or.(GAV->GAV_MODELO # "6")
		Hs_MsgInf(STR0106,STR0019,STR0059)
		lRet := .F.
	EndIf
Else
	Hs_MsgInf(STR0105,STR0019,STR0059)
	lRet := .F.
EndIf

restArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PRESCR บAutor  ณMario Arizono       บ Data ณ  10/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณChamada prescricao.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_PRESCR(cAliasM30, nRegM30, nOpcM30)
Local aArea := GetArea()

Private aRotina   := {	{""  ,"", 0 , 4},;      //"Prescrever"
{ "" ,"", 0 , 2},;      //"Consultar"
{ "" ,"", 0 , 4},; 		//"Paciente"
{ "" ,"", 0 , 3}} 		//"Impressใo"

If !LockByName("ExecPresc" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecPresc",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecPresc",GAV->GAV_REGATE)
EndIf

If aCodusr[1]
	DBSelectArea("GCY")
	DbSetOrder(1)//REGATE
	DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

	cLocCon    := GCY->GCY_CODLOC

	DBSelectArea("GCY")
	DbSetOrder(1)//REGATE
	DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

	HS_MntAbq("GCY", GCY->(RecNo()), 1, , GAV->GAV_RESERV)
Else
	HS_MsgInf(STR0115, STR0019, STR0116)//"Usuแrio sem permissใo para acesso เ prescri็ใo m้dica."##"Aten็ใo"##"Valida็ใo Usuแrio"
Endif

UnLockByName("ExecPresc" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecPresc",GAV->GAV_REGATE)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ATRIANTบAutor  ณMario Arizono       บ Data ณ  03/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTela antecedentes                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ATRIANT(cAlias,nReg,nOpc)
Local aArea := GetArea()
Private nVisAnm    := 1

If !LockByName("ExecAnt" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecAnt",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecAnt",GAV->GAV_REGATE)
EndIf

DBSelectArea("GCY")
DbSetOrder(1)//REGATE
DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

If Empty(aCodUsr[2])
	aCodUsr[1] := .T.
	aCodUsr[2] := IIf(Empty(GCY->GCY_CRMANM), GCY->GCY_CODCRM, GCY->GCY_CRMANM)
	If Len(aCodUsr) > 2
		aCodUsr[3]:= .F.
	EndIf
EndIf


HS_AntMA7("GCY", GCY->(Recno()), nOpc)

UnLockByName("ExecAnt" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecAnt",GAV->GAV_REGATE)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ChmM11 บAutor  ณMario Arizono       บ Data ณ  07/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณControle turno                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ChmM11(cAliasM30, nRegM30, nOpcM30)
Local aArea := GetArea()

If !LockByName("ExecPlEnf" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecPlEnf",GAV->GAV_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecPlEnf",GAV->GAV_REGATE)
EndIf

DBSelectArea("GCY")
DbSetOrder(1)//REGATE
DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

HSPAHM11("GCY", GCY->(RecNo()), nOpcM30, GAV->GAV_RESERV, GCY->GCY_REGATE, GCY->GCY_REGGER, GCY->GCY_CODLOC)

UnLockByName("ExecPlEnf" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecPlEnf",GAV->GAV_REGATE)

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_VDSPFIX ณ Autor ณ Rogerio Tabosa        ณ Data ณ31.08.2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณVerifica as despesas a ser lan็adas na GD6                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNil                                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                              ณฑฑ
ฑฑณ          ณ												                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_VDSPFIX(cRegAte)
Local aArea 	:= GetArea()
Local cSql 		:= ""
Local cHorDes	:= ""
Local lPassa    := .F.

cHorDes := Time()

DbSelectArea("GCZ")
DbSetOrder(2)
DbSeek(xFilial("GCZ") + cRegAte)

cSql += "SELECT GB5_CODTXD,GB5_QTDTXD,GB5_REGATE FROM " + RetSqlName("GB5") + " "
cSql += " WHERE GB5_FILIAL = '" + xFilial("GB5") + "' AND D_E_L_E_T_ <> '*' "
cSql += " AND GB5_REGATE = '" + cRegAte + "' "
cSql += " AND GB5_DATINI = (SELECT MAX(GB5_DATINI) FROM " + RetSqlName("GB5") + " "
cSql += " WHERE GB5_REGATE = '" + cRegAte + "' "
cSql += " AND GB5_DATINI <= '" + Dtos(dDataBase) + "' AND D_E_L_E_T_ <> '*' ) "
cSql := ChangeQuery(cSql)
TCQuery cSql New Alias "TMPGB5"

While !TMPGB5->(Eof())
	DbSelectArea("GD6")
	DbSetOrder(5)//3/NRSEQG + CODTXD + DATDES
	If !DbSeek(xFilial("GD6") + GCZ->GCZ_NRSEQG + TMPGB5->GB5_CODTXD + DTOS(DDATABASE)) //Nao foi lancada no dia
		If !lPassa
			If !MsgYesNo(STR0131,STR0019) //"Existem despesas fixas que nใo foram lan็adas, deseja lan็a-las?"
				TMPGB5->(DbCloseArea())
				Return(Nil)
			EndIf
			lPassa := .T.
		EndIf
		FS_GrvGD6(, cHorDes)
	EndIf
	TMPGB5->(DbSkip())
EndDo

TMPGB5->(DbCloseArea())

RestArea(aArea)
Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_GrvGD6  ณ Autor ณ Daniel Peixoto        ณ Data ณ24.03.2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณRotina de gravacao das desp. fixas do GB5 para o GD6          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNil                                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpN1: Numero de despesas fixas                               ณฑฑ
ฑฑณ          ณExpC2: Horario de lancamento da despesa fixa                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGD6(nDespFix, cHorDes)
Local aRValTD 	:= {}
Local nCont   	:= 0
Local dDatDes 	:= IIF(GCY->GCY_ATENDI <> "2", DDATABASE, GCY->GCY_DATATE)
Default nDespFix := 1


For nCont := 1 to nDespFix
	If (aRValTD := HS_RValTD(TMPGB5->GB5_CODTXD, GCZ->GCZ_CODPLA, GCY->GCY_CODLOC,.F., dDatDes))[1] == 0 //nao ocorreu erro
		DbSelectArea("GD6")
		M->GD6_SEQDES := HS_VSxeNum("GD6", "M->GD6_SEQDES", 1)
		ConfirmSx8()
		RecLock("GD6",.T.)
		GD6->GD6_FILIAL := xFilial("GD6")
		GD6->GD6_CODLOC := GCY->GCY_CODLOC
		GD6->GD6_DATDES := dDatDes
		GD6->GD6_HORDES := IIF(GCY->GCY_ATENDI <> "2", cHorDes, GCY->GCY_HORATE)
		GD6->GD6_QTDDES := TMPGB5->GB5_QTDTXD
		GD6->GD6_CODDES := TMPGB5->GB5_CODTXD
		GD6->GD6_VALDES := aRValTD[2]
		GD6->GD6_PCUDES := aRValTD[3]
		GD6->GD6_GLODES := IIf(aRValTD[4][1], "2", "0")
		GD6->GD6_SEQDES := M->GD6_SEQDES
		GD6->GD6_NRSEQG := GCZ->GCZ_NRSEQG
		GD6->GD6_REGATE := TMPGB5->GB5_REGATE
		GD6->GD6_FATPAR := aRValTD[4][2]
		GD6->GD6_CODTXC := aRValTD[7]
		GD6->GD6_DESTXC := aRValTD[8]
		GD6->GD6_LOGARQ := HS_LogArq()
		MsUnlock()
	Else
		cErros += aRValTD[5] + CHR(13) + CHR(10)
	EndIf
Next

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_Ind6       บAutor  ณSAUDE           บ Data ณ  17/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc็ใo para trazer Informa็๕es MAT/Med Pelo Indice         บฑฑ
ฑฑบ          ณSEIS da Tabela SB8                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function HS_Ind6(cLote)
Local cSql := ""
Local aArea := GetArea()
Local aVetDados:={}
cSql :="SELECT * FROM  " + RetSQLName("SB8") + " SB8 WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' "
cSql +=" AND B8_NUMLOTE='"+cLote+"'
cSql := ChangeQuery(cSql)
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()
aVetDados:={}

While !Eof()
	AADD(aVetDados, {QRY->B8_NUMLOTE, ;
	QRY->B8_LOTEFOR, ;
	QRY->B8_LOTECTL, ;
	QRY->B8_DTVALID, ;
	QRY->B8_FILIAL, ;
	QRY->B8_PRODUTO, ;
	QRY->B8_SALDO})
	DbSkip()
EndDo

QRY->(dbCloseArea())


RestArea(aArea)
Return(aVetDados)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHSPFILFAC ณ Autor ณ Sa๚de			        ณ Data ณ 29.09.10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Filtro de Pesquisa para face do dente	   			      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPFILFAC()
LOCAL cRet := "@#.T.@#"

If Type("cProPls") == "C" .AND. Type("cTabPls")  == "C" .AND. Type("M->GD7_DENREG")  == "C"
	cRet := "@#BYL_FILIAL == '"+xFilial("BYL")+"' .AND. BYL_CODPSA == '"+cProPls+"' .AND. BYL_CODPAD == '"+cTabPls+"' .AND. BYL_CODIGO == '"+M->GD7_DENREG+"' @#"
Endif

Return cRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHSPFILREG ณ Autor ณ Saude			        ณ Data ณ 29.09.10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Filtro de pesquisa Dente Regiao			   			      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPFILREG()
LOCAL cRet := "@#.T.@#"

If Type("cProPls") == "C" .AND. Type("cTabPls")  == "C" .AND. Type("M->GD7_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+cProPls+"' .AND. B05_CODPAD == '"+cTabPls+"'@#"
Endif

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TranLstบAutor  ณMicrosiga           บ Data ณ  12/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta fun็a๕ realizarแ a transferencia de Pacientes CC para  บฑฑ
ฑฑบ          ณo Leito de Espera                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_TranLst(cSetor,cQuarto,cLeito,nOpc)
Local aArea := GetArea()
Local cQuarEsp:=""
Local cLeitEsp:=""
Local lRet:=.F.
Local cSQL:=""
Private aRegEsp:={}

DbSelectArea("GCS")
DbSetOrder(1)
Dbseek(xFilial("GCS")+cSetor)  //GCS_FILIAL+GCS_CODLOC
If GCS->GCS_LSTESP =="1"
	DbSelectArea("GT6")
	GT6->(DbSetOrder(1))
	If 	GT6->(DbSeek(xFilial("GT6") + cSetor+ cQuarto+cLeito))
		cQuarEsp :=cQuarto
		cLeitEsp  :=cLeito
	Else
		IF GT6->(DbSeek(xFilial("GT6") + cSetor+ cQuarto))
			If cLeito == GT6->GT6_LEITO .or. Empty(GT6_LEITO)
				cQuarEsp :=GT6->GT6_QUARTO
				cLeitEsp :=GT6->GT6_LEITO
			Endif
		Else
			If GT6->(DbSeek(xFilial("GT6") + cSetor))
				If  cQuarto == GT6->GT6_QUARTO .or. Empty(GT6_QUARTO)
					cQuarEsp :=GT6->GT6_QUARTO
					cLeitEsp :=GT6->GT6_LEITO
				Endif
			Endif
		Endif
	Endif

	If HS_CountTB("GT6", "GT6_CODLOC = '" + cSetor + "'  and GT6_QUARTO = '" + cQuarEsp + "' and  GT6_LEITO = '" + cLeitEsp + "'  ") > 0  //Busca os pacientes que estใo na lista de espera
		aRegEsp:=HS_ExbLsE(cSetor,cQuarEsp,cLeitEsp,nOpc) ///lista de espera  retorna os pacientes que estใo na Lista de Espera
		If !Empty(aRegEsp)
			DbSelectArea("GAV")
			GAV->(DbSetOrder(5))
			If GAV->(DbSeek(xFilial("GAV")+aRegEsp[1]))  //FILIAL REGGER*/   Verifica se o paciente da Lista estแ Internado
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPesquisa realizado para Caso de Rescem Nascidos        ณ
				//ณOnde o Recem nascido possui o Mesmo Regger e Regate da ณ
				//ณMae an GAV. este filtro ้ utilizado para pegar somente |
				//ณo Leito\Quarto\ da Mae.                                ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				If Select("QrGAV") > 0
					QrGAV->(DbCloseArea())
					Return(.F.)
				Endif
				cSQL:= "SELECT GAV_REGATE,GAV_STATUS,GAV_CODLOC,GAV_QUARTO,GAV_LEITO,R_E_C_N_O_ RECNO  FROM  "
				cSQL+= RetSQlName("GAV")+ " WHERE  "
				cSQL+= "  GAV_FILIAL = '" + xFilial("GAV") + "' AND  "
				cSQL+= "  GAV_REGGER = '"+aRegEsp[1]+"' AND "
				cSQL+= "  D_E_L_E_T_ = ' '  AND   GAV_RESERV  NOT IN ( '0', '1', '2', '3', '4', '5')    "
				cSQL += " AND GAV_LEITO <> '" + Space(Len(GAV->GAV_LEITO )) + "' "
				cSQL  := ChangeQuery(cSql)
				TCQUERY cSQL NEW ALIAS "QrGAV"
				DbSelectArea("QrGAV")
				DbGoTop()
				If EMPTY(QrGAV->GAV_LEITO)
					HS_MsgInf(STR0139,STR0019,STR0049) //""Transferencia impossibilitada Paciente no Centro Cirurgico ""###"Atencao" //"TRANSFERENCIA DE LEITO"                                                                                                                                                                                                                                                                                                                                                                                                                                                       "
					Return(lRet)
				Endif
				If !EMPTY(QrGAV->GAV_REGATE)
					IF QrGAV->GAV_STATUS != "1"
						IF QrGAV->GAV_STATUS == "0" .OR. QrGAV->GAV_STATUS == " "
							HS_MsgInf(STR0031,STR0019,STR0049) //"Leito Esta Vago...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
							lRet:=.T.
						ElseIf QrGAV->GAV_STATUS == "4"
							HS_MsgInf(STR0027,STR0019,STR0049) //"Leito Esta Interditado...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
							lRet:=.T.
						ElseIf QrGAV->GAV_STATUS == "5"
							HS_MsgInf(STR0028,STR0019,STR0049)  //"Leito Esta Reservado...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
							lRet:=.T.
						ElseIf QrGAV->GAV_STATUS == "2"
							HS_MsgInf(STR0032,STR0019,STR0049) //"Leito Esta de Alta...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
							lRet:=.T.
						Else
							HS_MsgInf(STR0033,STR0019,STR0049) //"Leito impossibilitado de Transferencia...Operacao cancelada."###"Atencao" //"TRANSFERENCIA DE LEITO"
							lRet:=.T.
						EndIf
						Return(lRet)
					Endif
					cOldRegAte :=QrGAV->GAV_REGATE
					cOldQuarto := QrGAV->GAV_QUARTO
					cOldSetor  := QrGAV->GAV_CODLOC
					cOldLeito  := QrGAV->GAV_LEITO
					cNomepac   := aRegEsp[2]
					lRet:=.F.
					If Select("QrGAV") > 0
						QrGAV->(DbCloseArea())
					Endif
				Else
					lRet:=.T.
				Endif
				If Select("QrGAV") > 0
					QrGAV->(DbCloseArea())
				Endif
			Else

				HS_MsgInf(STR0137 +alltrim(aRegEsp[2])+STR0138,STR0019,STR0049)
				lRet:=.T.

			Endif
		Endif
	Endif
Endif


RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHs_RotHM30บAutor  ณ Microsiga          บ Data ณ  02/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRetorna o aRotina do Posto de Enfermagem                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Hs_RotHM30
Local aRotina     := {	{OemtoAnsi(STR0002),"axPesqui"   , 0, 1},; //"Pesquisar"
						{OemtoAnsi(STR0003),"HS_M30ALT('GAV', GAV->(RecNo()), 2)", 0, 4},; //"Alta"
						{OemtoAnsi(STR0004),"HS_M30SAI"  , 0, 3},; //"Saida"
						{OemtoAnsi(STR0005),"HS_M30LIB"  , 0, 3},; //"Libera Leito"
						{OemtoAnsi(STR0006),"HS_M30TRA"  , 0, 3},; //"Transferencia"
						{OemtoAnsi(STR0045),"HS_M30DES"  , 0, 4},;  //"Despesas"
						{OemtoAnsi(STR0009),"HS_M30CAL"  , 0, 3},; //"Cancela Alta"
						{OemtoAnsi(STR0010),"HS_M30CSA"  , 0, 3},; //"Cancela Saida"
						{OemtoAnsi(STR0043),"HSPAHM33"   , 0, 4},; //"Dieta do Paciente"
						{OemtoAnsi(STR0053),"HS_RNaM30"  , 0, 2},; //"RN"
						{OemtoAnsi(STR0055),"HS_PESMED"  , 0, 1},; //"Profissional"
						{OemtoAnsi(STR0068),"HS_MntM04('GAI', 0, 12)", 0, 3},; //"Sol. Mat/Med"
						{OemtoAnsi(STR0069),"HS_PESQSOL"  , 0, 2},; //"Cons. Solicita็ใo"
						{OemtoAnsi(STR0070),"HS_DEVSOL"  , 0, 2},; //"Dev. Solicita็ใo"
						{OemtoAnsi(STR0102), "HS_TriM30", 0, 4}, ;  //"Evolu็ใo"
						{OemtoAnsi(STR0050), aRotRel, 0, 2}, ;  //"Relatorios"
						{OemtoAnsi(STR0011),"HS_LegPos()", 0, 1},; //"Legenda"
						{OemtoAnsi(STR0110),"HSPAHM08(GAV->GAV_REGATE, GAV->GAV_RESERV, GAV->GAV_CODLOC)", 0, 4},; //"Pedido de Exames"
						{OemtoAnsi(STR0111),"HS_PRESCR", 0, 4},; //"Prescr. M้dica"
						{OemtoAnsi(STR0123),"HSPAHM10(GAV->GAV_REGATE, GAV->GAV_CODLOC, GAV->GAV_RESERV, GAV->GAV_NOME, GAV->GAV_QUARTO, GAV->GAV_LEITO)", 0, 4},;//"Enfermagem"
						{OemtoAnsi(STR0127),"HS_AtriAnt", 0, 4},; //"Antecedentes"
						{OemtoAnsi(STR0128),"HS_ChmM11", 0, 4}} //"Plant. Enfer."
Return(aRotina)
