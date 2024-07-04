#INCLUDE "TMSA880.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

#DEFINE PREFIXOTIT	1
#DEFINE NUMTIT		2
#DEFINE PARCELATIT	3
#DEFINE TIPOTIT		4

//--ELEMENTOS: VETOR aRecno
#DEFINE FILDOCCTRC	1
#DEFINE DOCCTRC		2
#DEFINE SERIECTRC	3
#DEFINE RECNODOC	5
#DEFINE LINOK		6

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa880   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa de Documentos (Ctrc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa880()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION TMSA880()

Local cTmsERP     := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := STR0001 //"Baixa de Documentos"

If cTmsERP == '1' //-- ERP Datasul
	//-- Quando ha integracao, nao permite a execucao desta rotina
	Help(" ", 1, "TMSA88008") //-- "Esta funcionalidade nao esta habilitada quando ha integracao com o ERP Datasul (MV_TMSERP = '1')."
	return
EndIf

MBrowse( 6, 1,22,75,"DT6",,,,,,Tmsa880Leg())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa880Vis³ Autor ³ Claudio D. de Souza   ³ Data ³ 15/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza Docto, com opcao de vizualizar fatura            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa880Vis(cAlias,nReg,nOpc)
Local aBut      := {}
Local aArea     := GetArea()
Local aAreaSE1  := SE1->(GetArea())
Local aAreaSA1  := SA1->(GetArea())

AAdd( aBut, {"PRECO", {|| TMSA880View(nOpc)}, STR0010 , STR0007} ) //"Visualiza Fatura

AxVisual(cAlias,nReg,nOpc,,,,, aBut)

RestArea(aArea)
RestArea(aAreaSE1)
RestArea(aAreaSA1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA880View³ Autor ³V.Raspa               ³ Data ³ 15.Dez.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a Fatura                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSA880View(nOpc)
Local cQuery    := ''
Local cAliasQry := ''
Local cAliasOld := Alias()

If !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO))
	cQuery := "SELECT SE1.R_E_C_N_O_ SE1Recno"
	cQuery += "FROM " + RetSQLTab("SE1")
	cQuery += "WHERE SE1.E1_FILIAL  = '" + xFilial("SE1") + "' AND "
	cQuery += "      SE1.E1_PREFIXO = '" + DT6->DT6_PREFIX + "' AND "
	cQuery += "      SE1.E1_NUM     = '" + DT6->DT6_NUM + "' AND "
	cQuery += "      SE1.E1_TIPO    = '" + DT6->DT6_TIPO + "' AND "
	cQuery += "      SE1.D_E_L_E_T_ = ' '"

	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If !(cAliasQry)->(Eof())
		SE1->(DbSetOrder(1))
		SE1->(DbGoTo((cAliasQry)->SE1Recno))
	
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

		DbSelectArea("SE1")
		
		TMSA850Vis("SE1", "", nOpc)	
	
	Else
		Aviso(STR0006,STR0007, {STR0008}) //"Atencao"###"Fatura nao encontrada"###"Ok"
	
	EndIf
	(cAliasQry)->(DbCloseArea())
Else
	Aviso(STR0006,STR0009, {STR0008}) //"Atencao"###"Docto. nao faturado!"###"Ok"
EndIf

DbSelectArea(cAliasOld)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa880Bai³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa de documentos TMS                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa880Bai(cAlias,nReg,nOpc)

Local aAreaSF2    := SF2->(GetArea())
Local cBanco      := Space(TamSx3("E1_PORTADO")[1])
Local cAgencia    := Space(TamSx3("E1_AGEDEP")[1])
Local cConta      := Space(TamSx3("E1_CONTA")[1])
Local dDtCredito  := dDataBase
Local aMotBx      := ReadMotBx()
Local nPosTipDoc  := 0
Local nPosNat     := 0
Local nPosValRec  := 0
Local nPosCliDev  := 0
Local nPosLojDev  := 0
Local nPosJuros   := 0
Local nPosDesc    := 0
Local nPosAcresc  := 0
Local nPosDecresc := 0
Local nPosModSpb  := 0
Local nPosFilDeb  := 0
Local nPosObs     := 0
Local nPosFilDoc  := 0
Local nPosDoc     := 0
Local nPosSerie   := 0
Local nPosTipo    := 0
Local nPosValFat  := 0
Local nX          := 0
Local nAscan      := 0
Local cFatura     := ''
Local cPrefixo    := ''
Local cMVPrefixo  := SuperGetMv("MV_1DUPREF")
Local nOpcA       := 0
Local cMotBx      := ""
Local cModSpb     := "1=TED;2=CIP;3=COMP"
Local cTipoParc   := ""
Local aColsBx     := {}
Local aHeadBx     := {}
Local cLoteTms    := CriaVar("E5_LOTE")
Local aBaixa      := {}
Local lRet        := .T.
Local oBold
Local oDlg
Local aFldDT6	  := {}
Local aFlds		  := {}

Private oTotRec
Private nTotRec     := 0
Private nTotCred    := 0
Private aRecnos     := {}
Private aBaiPar     := {}
Private dBaixa      := dDataBase
Private nJuros      := 0 // Usada em Fa070Juros
Private cLoteFin    := Space (4 )
Private cNatTms     := CriaVar("E1_NATUREZ")
Private lMsErroAuto := .F.

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

aEval(aMotBx, {|e| cMotBx += Left(e,3) + "=" + SubStr(e,7,10) +";" } )

aFldDT6 := ApBuildHeader("DT6")
Aadd( aFlds, { STR0036											, "_SI_TIPDOC"	, ""			 		, 1						, 0					, ""						, USADO, "C"			,""		, "V", STR0037		, "1"				, "" } ) //"Tipo Docto."###"1=Conhecimento;2=Fatura"
Aadd( aFlds, { , "DT6_FILDOC", , , , "", , , "", "V", , , "" } ) //'"Fil.Doc/Prefixo"'
Aadd( aFlds, { , "DT6_DOC", , , , "T880ValDoc(__oGetDad)", , , "", "V", , , "" } ) //'"Docto/Num. Tit."'
Aadd( aFlds, { , "DT6_SERIE", , , , "T880ValSer(__oGetDad)", , , "", "V", , , "" } ) //'"Serie/Parcela"'
Aadd( aFlds, { FWX3Titulo("E1_TIPO"), "_SI_TIPOTIT", GetSx3Cache("E1_TIPO", "X3_PICTURE"), TamSX3("E1_TIPO")[1], TamSX3("E1_TIPO")[2], "T880ValTipo(__oGetDad)", USADO, GetSx3Cache("E1_TIPO", "X3_TIPO"), "05", "V", GetSx3Cache("E1_TIPO", "X3_CBOX"), GetSx3Cache("E1_TIPO", "X3_RELACAO"), "" } )
Aadd( aFlds, { , "DT6_FILDEB", , , , "T880ValTipo(__oGetDad)", , ,"", "V", , , "" } )
Aadd( aFlds, { STR0038											, "_SI_NOMCLI"	, "@!"					, 30					, 0					, ""						, USADO, "C"			,""		, "V", ""			, ""				, "" } ) //"Cliente"
Aadd( aFlds, { STR0039											, "_SI_VALFAT"	, "@E 999,999,999.99"	, 15					, 2					, ""						, USADO, "N"			,""		, "V", ""			, ""				, "" } ) //"Valor do Docto"
Aadd( aFlds, { STR0040											, "_SI_VALAJU"	, "@E 999,999,999.99"	, 15					, 2					, "T880ValAju(__oGetDad)"	, USADO, "N"			,""		, "V", ""			, ""				, "" } ) //"Ajuste"
Aadd( aFlds, { STR0041											, "_SI_ABATIM"	, "@E 999,999,999.99"	, 15					, 2					, ""						, USADO, "N"			,""		, "V", ""			, ""				, "" } ) //"Abatimentos"
Aadd( aFlds, { STR0042											, "_SI_VALDESC"	, "@E 999,999,999.99"	, 15					, 2					, "T880ValDesc(__oGetDad)"	, USADO, "N"			,""		, "V", ""			, ""				, "" } ) //"Desconto"
Aadd( aFlds, { STR0043											, "_SI_VALJUR"	, "@E 999,999,999.99"	, 15					, 2					, "T880ValJur(__oGetDad)"	, USADO, "N"			,""		, "V", ""			, ""				, "" } ) //"Juros"
Aadd( aFlds, { , "DT6_ACRESC", , , , "", , ,"", "V", , , "" } )
Aadd( aFlds, { , "DT6_DECRES", , , , "", , ,"", "V", , , "" } )
Aadd( aFlds, { STR0044											, "_SI_VALREC"	, "@E 999,999,999.99"	, 15					, 2					, ""						, USADO, "N"			,""		, "V", ""			, ""				, "" } ) //"Valor Recebido"
Aadd( aFlds, { STR0045											, "_SI_MOTBX"	, ""					, 3						, 0					, ""						, USADO, "C"			,""		, "V", cMotBx		, ""				, "" } ) //"Mot. Baixa"
Aadd( aFlds, { STR0046											, "_SI_NATUR"	, "@!"					, 10					, 0					, ""						, USADO, "C"			,"SED"	, "V", ""			, ""				, "" } ) //"Natureza"
Aadd( aFlds, { STR0028											, "_SI_MODSPB"	, ""					, 10					, 0					, ""						, USADO, "C"			,""		, "V", cModSpb		, ""				, "" } ) //"Modalidade SPB"
Aadd( aFlds, { STR0027											, "_SI_OBS"		, "@!"					, 50					, 0					, ""						, USADO, "C"			,""		, "V", ""			, ""				, "" } ) //"Obs."
Aadd( aFlds, { , "DT6_CLIDEV", , , , "", , ,"", "V", , , "" } )
Aadd( aFlds, { , "DT6_LOJDEV", , , , "", , ,"", "V", , , "" } )

For nX := 1 To Len(aFlds)
	If (nPos := aScan(aFldDT6, {|x| AllTrim(x[2]) == aFlds[nX][2]})) > 0
		aAdd(aHeadBx, {FWX3Titulo(aFldDT6[nPos][2]), aFldDT6[nPos][2], aFldDT6[nPos][3], aFldDT6[nPos][4], aFldDT6[nPos][5], aFlds[nX][6], aFldDT6[nPos][7], aFldDT6[nPos][8], aFlds[nX][9], "V", aFlds[nX][11], aFlds[nX][12], aFlds[nX][13]})
	Else
		aAdd(aHeadBx, aFlds[nX])
	EndIf
Next

aSize(aFlds, 0)
aFlds := Nil

aSize(aFldDT6, 0)
aFldDT6 := Nil

aColsBx := {}

// Campos a serem editados na GetDados
aCposEdit := {	"_SI_TIPDOC"	, "DT6_FILDOC"	, "DT6_DOC",;
				"DT6_SERIE"		, "_SI_VALAJU"	,"_SI_VALDESC",;
				"_SI_VALJUR"	, "_SI_MOTBX"	, "_SI_NATUR",;
				"_SI_MODSPB"	, "_SI_OBS"		, "_SI_TIPOTIT"  }

DEFINE MSDIALOG oDlg TITLE STR0026 From 0,0 To 37,124 OF oMainWnd //"Baixa de Doctos"

	@ 035, 007 SAY STR0011 PIXEL OF oDlg //"Banco"
	@ 035, 045 MSGET cBanco SIZE 20, 9 F3 "SA6" PIXEL OF oDlg

	@ 035, 085 SAY STR0012 PIXEL OF oDlg //"Agencia"
	@ 035, 125 MSGET cAgencia SIZE 40, 9 PIXEL OF oDlg

	@ 035, 180 SAY STR0013 PIXEL OF oDlg //"Conta"
	@ 035, 205 MSGET cConta SIZE 50, 9 PIXEL OF oDlg VALID ExistCpo("SA6",cBanco+cAgencia+cConta)

	@ 050, 007 SAY STR0014 PIXEL OF oDlg //"Data da Baixa"
	@ 050, 045 MSGET dBaixa	SIZE 40, 9 PIXEL OF oDlg

	@ 065, 007 SAY STR0015 PIXEL OF oDlg //"Data do crédito"
	@ 065, 045 MSGET dDtCredito SIZE 40, 9 PIXEL OF oDlg

	@ 080, 007 SAY STR0016 PIXEL OF oDlg //"Total do crédito"
	@ 080, 045 MSGET nTotCred PICTURE "@E 999,999,999.99" VALID Positivo() PIXEL OF oDlg

	@ 080, 125 SAY STR0017 PIXEL OF oDlg //"Natureza"
	@ 080, 160 MSGET cNatTms F3 "SED" PIXEL OF oDlg VALID ExistCpo("SED",M->cNatTms) PICTURE "@!"

	@ 080, 225 SAY STR0018 PIXEL OF oDlg //"Lote"
	@ 080, 260 MSGET cLoteTms PIXEL OF oDlg VALID NaoVazio(cLoteTms) .And. T880ChkLote("R", cLoteTms) WHEN Empty(cLoteTms)

	oGet := MsNewGetDados():New(95,2,250,490,GD_INSERT+GD_UPDATE+GD_DELETE,{ || T880LinOk(cBanco, cAgencia, cConta, dBaixa, dDtCredito, cNatTms, cLoteTms ) }, { || T880TudOk(cBanco, cAgencia, cConta, dBaixa, dDtCredito, cNatTms, cLoteTms, .F.) },/*inicpos*/,aCposEdit,/*freeze*/,99999,/*fieldok*/,/*superdel*/,/*delok*/ { || Tms880Del() } ,oDlg,aHeadBx,aColsBx)

	@ 263, 005 SAY STR0019 OF ODlg PIXEL FONT oBold //"Total Recebido"
	@ 263, 090 MSGET oTotRec VAR nTotRec SIZE 60, 9 OF oDlg PIXEL PICTURE "@E 999,999,999.99" WHEN .F. FONT oBold

	__oGetDad := oGet // Private utilizada nas rotinas de validacao

ACTIVATE MSDIALOG oDlg ;
			ON INIT EnchoiceBar(oDlg,;
								{|| aColsBx := aClone(oGet:aCols), If(oGet:TudoOk(), (nOpca:=1,oDlg:End()), Nil ) },;
								{|| aColsBx := aClone(oGet:aCols), nOpca:=0,If(MsgYesNo(STR0020), oDlg:End(),If(Empty(aColsBx[1][1]),oDlg:End(),Nil))}) CENTER //"Deseja realmente desistir da baixa?"

If nOpca == 1
	nPosTipDoc	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_TIPDOC" } )
	nPosNat		:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_NATUR" } )
	nPosMotBx	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_MOTBX" } )
	nPosValRec	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
	nPosJuros	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_VALJUR" } )
	nPosDesc	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_VALDESC" } )
	nPosObs		:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_OBS" } )
	nPosModSpb	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_MODSPB" } )
	nPosAcresc	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
	nPosDecresc	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
	nPosLojDev	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_LOJDEV" } )
	nPosCliDev	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_CLIDEV" } )
	nPosLojDev	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_LOJDEV" } )
	nPosFilDeb	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_FILDEB" } )
	nPosFilDoc 	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
	nPosDoc		:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_DOC" } )
	nPosSerie	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
	nPosTipo	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_TIPOTIT" } )
	nPosValFat	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
	cLoteFin 	:= cLoteTms
	
	nLen := Len(aColsBx)
	lRet := .T.
	
	Begin Transaction
		// Processa todas os doctos. a serem baixados
		For nX := 1 To nLen
			// Se a linha nao estiver deletada	
			If ValType(aColsBx[nX][Len(aHeadBx)+1]) != "L" .Or. !aColsBx[nX][Len(aHeadBx)+1]
				If aColsBx[nX][nPosTipDoc] == "1" // Baixa de Conhecimento
					nAscan := aScan(aRecnos, {|e| e[FILDOCCTRC]+e[DOCCTRC]+e[SERIECTRC] == aColsBx[nX][nPosFildoc]+aColsBx[nX][nPosDoc]+aColsBx[nX][nPosSerie] .And. e[LINOK] } )
					// Localiza o Ctrc na matriz de recnos para efetuar a baixa no arquivo original
					If nAscan > 0
						// Posiciona no registro do ctrc para baixa-lo
						DT6->(MsGoto(aRecnos[nAscan][RECNODOC]))

						SF2->(DbSetOrder(2)) //-- F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
						SF2->(MsSeek(xFilial("SF2")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+PadR(DT6->DT6_DOC,Len(DT6->DT6_DOC))+DT6->DT6_SERIE))

						//Valida se ocorrera troca do Tipo de Titulo a Receber
						//conforme configuração do parametro MV_TMSTIPT
						cTipoParc := fTmsTpTit(MVNOTAFIS)

						If Reclock("DT6", .F.)
							//-- Obtem o numero da fatura a partir do numero do ctrc
							cFatura  := DT6->DT6_DOC
							cPrefixo := &(cMVPrefixo)
							// Gera titulo da fatura
							FA280GrFat(aColsBx[nX][nPosCliDev],aColsBx[nX][nPosLojDev],"","",cFatura,cPrefixo,"",cTipoParc,dBaixa,aColsBx[nX][nPosNat],cBanco,aColsBx[nX][nPosValFat],xMoeda(aColsBx[nX][nPosValFat],1,1),0,1,0,,,,,,,"TMSA880",aColsBx[nX][nPosFilDeb], "2", .T., aColsBx[nX][nPosAcresc], aColsBx[nX][nPosDecresc] )
							// Atualiza DT6, gravando os campos inerentes a fatura
							REPLACE	DT6->DT6_PREFIX			WITH cPrefixo,;
										DT6->DT6_NUM		WITH cFatura,;
										DT6->DT6_TIPO		WITH cTipoParc,;
										DT6->DT6_ACRESC		WITH aColsBx[nX][nPosAcresc],;
										DT6->DT6_DECRESC	WITH aColsBx[nX][nPosDecresc],;
										DT6->DT6_BAIXA 		WITH dBAixa
							MsUnlock()

							aBaixa := {}

							AADD(aBaixa , {"E1_PREFIXO"		, SE1->E1_PREFIXO			, NIL})
							AADD(aBaixa , {"E1_NUM"			, SE1->E1_NUM				, NIL})
							AADD(aBaixa , {"E1_PARCELA"		, SE1->E1_PARCELA			, NIL})
							AADD(aBaixa , {"E1_TIPO"		, SE1->E1_TIPO				, NIL})
							AADD(aBaixa , {"AUTMOTBX"		, aColsBx[nX][nPosMotBx]	, Nil})
							AADD(aBaixa , {"AUTBANCO"		, cBanco					, Nil})
							AADD(aBaixa , {"AUTAGENCIA"		, cAgencia					, Nil})
							AADD(aBaixa , {"AUTCONTA"		, cConta					, Nil})
							AADD(aBaixa , {"AUTDTBAIXA"		, dBaixa					, Nil})
							AADD(aBaixa , {"AUTDTCREDITO"	, dDtCredito				, Nil})
							AADD(aBaixa , {"AUTHIST"		, aColsBx[nX][nPosObs]		, Nil})

							AADD(aBaixa , {"AUTDESCONT"		, aColsBx[nX][nPosDesc]		, Nil})
							AADD(aBaixa , {"AUTDECRESC"		, aColsBx[nX][nPosDecresc]	, Nil})
							AADD(aBaixa , {"AUTACRESC"		, aColsBx[nX][nPosAcresc]	, Nil})
							AADD(aBaixa , {"AUTMULTA"		, 0							, Nil})
							AADD(aBaixa , {"AUTJUROS"		, aColsBx[nX][nPosJuros]	, Nil})
							AADD(aBaixa , {"AUTVALREC"		, aColsBx[nX][nPosValRec]	, Nil})

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Executa a Baixa do Titulo                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MSExecAuto({|x, y| Fina070(x, y )}, aBaixa, 3)
							If lMsErroAuto
								DisarmTransaction()
								MOSTRAERRO()
								lRet:= .F.
								Exit
							Endif
						Else
							DisarmTransaction()
							lRet:= .F.
							Exit
						Endif
					Endif
				Else
					nAscan := aScan(aRecnos, {|e| e[PREFIXOTIT]+e[NUMTIT]+e[PARCELATIT]+e[TIPOTIT] == aColsBx[nX][nPosFildoc]+aColsBx[nX][nPosDoc]+aColsBx[nX][nPosSerie]+aColsBx[nX][nPosTipo] .And. e[LINOK] } )
					// Localiza o Ctrc na matriz de recnos para efetuar a baixa no arquivo original
					If nAscan > 0
						// Posiciona no registro do titulo da fatura para baixa-la
						SE1->(MsGoto(aRecnos[nAscan][RECNODOC]))
						aBaixa := {}

						AADD(aBaixa , {"E1_PREFIXO"		, SE1->E1_PREFIXO			, NIL})
						AADD(aBaixa , {"E1_NUM"			, SE1->E1_NUM				, NIL})
						AADD(aBaixa , {"E1_PARCELA"		, SE1->E1_PARCELA			, NIL})
						AADD(aBaixa , {"E1_TIPO"		, SE1->E1_TIPO				, NIL})
						AADD(aBaixa , {"AUTMOTBX"		, aColsBx[nX][nPosMotBx]	, Nil})
						AADD(aBaixa , {"AUTBANCO"		, cBanco					, Nil})
						AADD(aBaixa , {"AUTAGENCIA"		, cAgencia					, Nil})
						AADD(aBaixa , {"AUTCONTA"		, cConta					, Nil})
						AADD(aBaixa , {"AUTDTBAIXA"		, dBaixa					, Nil})
						AADD(aBaixa , {"AUTDTCREDITO"	, dDtCredito				, Nil})
						AADD(aBaixa , {"AUTHIST"		, aColsBx[nX][nPosObs]		, Nil})

						AADD(aBaixa , {"AUTDESCONT"		, aColsBx[nX][nPosDesc]		, Nil})
						AADD(aBaixa , {"AUTDECRESC"		, aColsBx[nX][nPosDecresc]	, Nil})
						AADD(aBaixa , {"AUTACRESC"		, aColsBx[nX][nPosAcresc]	, Nil})
						AADD(aBaixa , {"AUTMULTA"		, 0							, Nil})
						AADD(aBaixa , {"AUTJUROS"		, aColsBx[nX][nPosJuros]	, Nil})
						AADD(aBaixa , {"AUTVALREC"		, aColsBx[nX][nPosValRec]	, Nil})
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa a Baixa do Titulo                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						MSExecAuto({|x, y| Fina070(x, y)}, aBaixa, 3)
						If lMsErroAuto
							DisarmTransaction()
							MOSTRAERRO()
							lRet:= .F.
							Exit
						Endif
					Endif
				Endif
			Endif
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera saldo bancario totalizador                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. (nTotRec > 0 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registro totalizador da movimentacao bancaria ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Reclock( "SE5" , .T. )
				SE5->E5_FILIAL		:= xFilial("SE5")
				SE5->E5_BANCO		:= cBanco
				SE5->E5_AGENCIA		:= cAgencia
				SE5->E5_CONTA		:= cConta
				SE5->E5_VALOR		:= nTotRec
				SE5->E5_RECPAG		:= "R"
				SE5->E5_LOTE		:= cLoteTms
				SE5->E5_HISTOR		:= STR0021 + cLoteTms	//"BAIXA DE TITULOS P/LOTE "
				SE5->E5_DTDIGIT		:= dDtCredito
				SE5->E5_DATA		:= dDtCredito
				SE5->E5_NATUREZ		:= cNatTms
				SE5->E5_TIPODOC		:= "BL"					// Baixa por Lote
				SE5->E5_DTDISPO		:= dDtCredito
				If SpbinUse()
					// Se houver retencao ModSpb = Comp, caso contrario, STR
					SE5->E5_MODSPB := IIF(SE5->E5_DTDISPO > dDataBase,"3","1")
				Endif
				SE5->(MsUnlock())
				If __lSX8
					ConfirmSX8()
				Endif
				AtuSalBco( cBanco, cAgencia, cConta, dDtCredito, nTotRec, "+" )
			Else
				DisarmTransaction()
			Endif
		EndIf
	End Transaction
	DbCommitall()
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif

RestArea(aAreaSF2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880Valser   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 22/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a serie para pesquisa do ctrc a ser Baixado              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880ValSer(oGet)
Local nAscan
Local nDif
Local nPosFilDoc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc		:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local nPosSerie		:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
Local nPosCliDev	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_CLIDEV" } )
Local nPosLojDev	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_LOJDEV" } )
Local nPosFilDeb	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDEB" } )
Local nPosDecresc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
Local nPosAcresc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
Local nPosValRec 	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
Local nPosValFat	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
Local nPosNomCli	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_NOMCLI" } )
Local nPosTipDoc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPDOC" } )
Local lRet			:= .F.
Local cVar			:= ReadVar()
Local cAliasOld		:= Alias()
Local lTM880VLD		:= ExistBlock('TM880VLD')
Local lRetPE		:= .F.

If !GdDeleted() .And. aCols[n][nPosTipDoc] == "1" // Baixa de Conhecimento
	// Pesquisa CTRC para baixa-lo
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+Pad(aCols[n][nPosFilDoc],Len(DT6->DT6_FILDOC))+aCols[n][nPosDoc]+Pad(&cVar,Len(DT6->DT6_SERIE))))
		// Nao permite Baixar Ctrc que tenha solicitacao de transferencias em aberto.
		If DT6->(FieldPos("DT6_NUMSOL")) > 0 .And. !Empty(DT6->DT6_NUMSOL)
			Help(" ",1,"TMSA88006") //"Ctrc possui solicitacao de transferencia em aberto. Baixa nao permitida
		Else
			// Se o docto. ja foi faturado, avisa e nao permite a inclusao
			If Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO))
				nAscan := aScan(aRecnos, {|e| e[FILDOCCTRC]+e[DOCCTRC]+e[SERIECTRC] == aCols[n][nPosFildoc]+aCols[n][nPosDoc]+&cVar .And. e[LINOK]} )
				If nAScan > 0
					Help(" ",1,"TMSA88007") //"Documento ja informado!"
					lRet:= .F.
				Else
					lRet := .T.
					If lTM880VLD
						lRetPE :=  ExecBlock("TM880VLD",.F.,.F.,{DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE})
						If ValType(lRetPE) == "L"
							lRet:= lRETPE
						EndIf
					EndIf

					If lRet
						SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIDEV+DT6_LOJDEV)))

						// Atualiza o valor a faturar e o valor do frete
						aCols[n][nPosNomCli]	:= SA1->A1_NREDUZ
						aCols[n][nPosCliDev]	:= DT6->DT6_CLIDEV
						aCols[n][nPosLojDev]	:= DT6->DT6_LOJDEV
						aCols[n][nPosFilDeb]	:= DT6->DT6_FILDEB
						aCols[n][nPosValFat]	:= DT6->DT6_VALTOT
						aCols[n][nPosDecresc]	:= DT6->DT6_DECRES
						aCols[n][nPosAcresc] 	:= DT6->DT6_ACRESC
						aBaiPar := {0,0,0,0,0}
						nTotRec -= aCols[n][nPosValRec]
						aCols[n][nPosValRec]	:= DT6->DT6_VALTOT + DT6->DT6_ACRESC - DT6->DT6_DECRES
						nTotRec += aCols[n][nPosValRec]
						oTotRec:Refresh()
						If ValType(oGet) == "O"
							oGet:Refresh()
						Endif
						// Localiza o Ctrc na matriz de Recnos
						nAscan := aScan(aRecnos, {|e| e[FILDOCCTRC]+e[DOCCTRC]+e[SERIECTRC] == aCols[n][nPosFildoc]+aCols[n][nPosDoc]+&cVar .And. e[LINOK] } )
						If nAScan = 0
							Aadd(aRecnos, { aCols[n][nPosFilDoc],aCols[n][nPosDoc],&cVar,"",DT6->(Recno()), .T.} )
						Endif
					EndIf
				EndIf
			Else
				If MsgYesNo(STR0022,STR0006) //"Ctrc foi faturado! Baixe a fatura gerada por ele. Deseja visualizar a fatura?"###"Atenção"
					SaveInter()
					TMSA880View(2)
					RestInter()
				EndIf
			EndIf
		EndIf
	Else
		Help(" ",1,"TMSA88002") //"Ctrc não encontrado!"
	Endif
Else
	lRet := .T. // A validacao da fatura ocorrera na digitacao do tipo do titulo
Endif

	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880ValTipo  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 22/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o tipo para pesquisa do titulo a ser Baixado             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880ValTipo(oGet)
Local nAscan      := 0
Local nDif        := 0
Local nPosFilDoc  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc     := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local nPosSerie   := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
Local nPosCliDev  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_CLIDEV" } )
Local nPosLojDev  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_LOJDEV" } )
Local nPosFilDeb  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDEB" } )
Local nPosTipo    := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPOTIT" } )
Local nPosValRec  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
Local nPosValFat  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
Local nPosNomCli  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_NOMCLI" } )
Local nPosTipDoc  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPDOC" } )
Local nPosNatur   := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_NATUR" } )
Local nPosAbatim  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_ABATIM" } )
Local nPosDecresc := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
Local nPosAcresc  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
Local nPosDesc    := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALDESC" } )
Local nPosJuros   := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALJUR" } )
Local lRet        := .F.
Local cVar        := ReadVar()

If !GdDeleted() .And. aCols[n][nPosTipDoc] == "2"
	// Pesquisa Fatura para baixa-la
	If SE1->(MsSeek(xFilial("SE1")+Pad(aCols[n][nPosFilDoc],Len(SE1->E1_PREFIXO))+aCols[n][nPosDoc]+Pad(aCols[n][nPosSerie],Len(SE1->E1_PARCELA))+&cVar))
		// Se a Fatura nao foi baixada, autoriza a inclusao para baixa
		If !Empty(SE1->E1_SALDO)
			nAscan := aScan(aRecnos, {|e| e[PREFIXOTIT]+e[NUMTIT]+e[PARCELATIT]+e[TIPOTIT] == aCols[n][nPosFildoc]+aCols[n][nPosDoc]+aCols[n][nPosSerie]+&cVar .And. e[LINOK]} )
			If nAScan > 0
				Help(" ",1,"TMSA88007") //"Documento ja informado!"
				lRet:= .F.
			Else
				SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
				lRet := .T.
				// Atualiza o valor a faturar e o valor do frete
				aCols[n][nPosNomCli]	:= SA1->A1_NREDUZ
				aCols[n][nPosCliDev]	:= SE1->E1_CLIENTE
				aCols[n][nPosLojDev]	:= SE1->E1_LOJA
				aCols[n][nPosFilDeb]	:= SE1->E1_FILDEB
				aCols[n][nPosValFat]	:= SE1->E1_VALOR
				aCols[n][nPosDecresc]	:= SE1->E1_DECRESC
				aCols[n][nPosNatur]		:= SE1->E1_NATUREZ

				// Calcula Desconto.
				aCols[n][nPosDesc]		:= FaDescFin("SE1",dBaixa,aCols[n][nPosValFat],SE1->E1_MOEDA)

				// Soma abatimentos
				aCols[n][nPosAbatim]	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dBaixa)

				// Calcula os juros
				fa070Juros(1)
				aCols[n][nPosJuros]		:= nJuros

				// Calcula valor recebido
				aBaiPar := Baixas (cNatTms,aCols[n][nPosFilDoc],aCols[n][nPosDoc],Pad(aCols[n][nPosSerie],Len(SE1->E1_PARCELA)),SE1->E1_TIPO,,"R",SE1->E1_CLIENTE,,SE1->E1_LOJA)
				nTotRec -= aCols[n][nPosValRec]
				aCols[n][nPosValRec] := (aCols[n][nPosValFat] + aCols[n][nPosAcresc] - aCols[n][nPosDecresc] + aCols[n][nPosJuros] - aCols[n][nPosDesc] - aCols[n][nPosAbatim] - aBaiPar[5])
				nTotRec += aCols[n][nPosValRec]
				oTotRec:Refresh()

				If ValType(oGet) == "O"
					oGet:Refresh()
				Endif
				// Localiza a Fatura na matriz de Recnos
				nAscan := aScan(aRecnos, {|e| e[PREFIXOTIT]+e[NUMTIT]+e[PARCELATIT]+e[TIPOTIT] == aCols[n][nPosFildoc]+aCols[n][nPosDoc]+aCols[n][nPosSerie]+&cVar .And. e[LINOK] } )
				If nAScan = 0
					Aadd(aRecnos, { aCols[n][nPosFilDoc],aCols[n][nPosDoc],aCols[n][nPosSerie],&cVar,SE1->(Recno()), .T.} )
				Endif
			EndIf
		Else
			// Se a Fatura ja foi baixada, avisa e nao permite a inclusao
			Help(" ",1,"TMSA88003") //"Fatura ja baixada"
		Endif
	Else
		Help(" ",1,"TMSA88004") //"Fatura não encontrada"
	Endif
Else
	Help(" ",1,"TMSA88005") //"Se deseja baixar uma Fatura, altere o tipo de documento! Não é preciso informar o tipo para baixa de Ctrc."
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880ValAju      ³ Autor ³ Claudio D. de Souza   ³ Data ³ 16/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor recebido, apos ser informado o valor do ajuste     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880ValAju(oGet)
Local nPosValFat  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
Local nPosValRec  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
Local nPosAcresc  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
Local nPosDecresc := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
Local nPosJuros   := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALJUR" } )
Local nPosDesc    := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALDESC" } )
Local nPosAbatim  := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_ABATIM" } )

If ! GdDeleted()
	aCols[n][nPosAcresc] := 0
	aCols[n][nPosDecresc] := 0
	// Diferença positiva, gera acrescimo
	nDif := &(ReadVar())
	If nDif > 0
		aCols[n][nPosAcresc]	:= aCols[n][nPosAcresc] + Abs(nDif)
	Else
		// Senao, gera decrescimo
		aCols[n][nPosDecresc]	:= aCols[n][nPosDecresc] + Abs(nDif)
	Endif	
	
	// Calcula valor recebido
	nTotRec -= aCols[n][nPosValRec]
	aCols[n][nPosValRec] := (aCols[n][nPosValFat] + aCols[n][nPosAcresc] - aCols[n][nPosDecresc] + aCols[n][nPosJuros] - aCols[n][nPosDesc] - aCols[n][nPosAbatim] - aBaiPar[5])
	nTotRec += aCols[n][nPosValRec]
	oTotRec:Refresh()
	
	If ValType(oGet) == "O"
		oGet:Refresh()
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880ValDesc     ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor recebido, apos ser informado o valor do desconto   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880ValDesc(oGet)

Local nPosValFat	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
Local nPosValRec	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
Local nPosAcresc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
Local nPosDecresc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
Local nPosJuros  	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALJUR" } )
Local nPosDesc		:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALDESC" } )
Local nPosAbatim 	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_ABATIM" } )
Local nDesc

If ! GdDeleted()
	// Diferença positiva, gera acrescimo
	nDesc := &(ReadVar())
	If ExistBlock("TM880DES")
		aCols[n][nPosDesc]	:= nDesc
		If ValType( uRet := ExecBlock("TM880DES",.F.,.F.,{aCols}) ) == "N"
			aCols[n][nPosDesc] :=  uRet
		Else
			aCols[n][nPosDesc] := nDesc
		EndIf
		&(ReadVar()) := aCols[n][nPosDesc]
		nDesc := &(ReadVar())
	Endif

	// Calcula valor recebido
	nTotRec -= aCols[n][nPosValRec]
	aCols[n][nPosValRec] := (aCols[n][nPosValFat] + aCols[n][nPosAcresc] - aCols[n][nPosDecresc] + aCols[n][nPosJuros] - nDesc - aCols[n][nPosAbatim] - If( !(Type("aBaiPar[5]") == "U"), aBaiPar[5], 0) )
	nTotRec += aCols[n][nPosValRec]
	oTotRec:Refresh()

	If ValType(oGet) == "O"
		oGet:Refresh()
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880ValJur      ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor recebido, apos ser informado o valor dos juros     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880ValJur(oGet)

Local nPosValFat	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALFAT" } )
Local nPosValRec	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
Local nPosAcresc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_ACRESC" } )
Local nPosDecresc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DECRES" } )
Local nPosJuros		:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALJUR" } )
Local nPosDesc		:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALDESC" } )
Local nPosAbatim	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_ABATIM" } )
Local nJuros

If ! GdDeleted()
	// Diferença positiva, gera acrescimo
	nJuros := &(ReadVar())
	
	// Calcula valor recebido
	nTotRec -= aCols[n][nPosValRec]
	aCols[n][nPosValRec] := (aCols[n][nPosValFat] + aCols[n][nPosAcresc] - aCols[n][nPosDecresc] + nJuros - aCols[n][nPosDesc] - aCols[n][nPosAbatim] - aBaiPar[5])
	nTotRec += aCols[n][nPosValRec]
	oTotRec:Refresh()
	
	If ValType(oGet) == "O"
		oGet:Refresh()
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880ValDoc   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 22/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o Documento							                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880ValDoc(oGet)
Local nPosDoc     := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local lRet        := .T.

If ! GdDeleted() .And. !Empty(aCols[n][nPosDoc])
	If aCols[n][nPosDoc] <> &(ReadVar())
		lRet:= .F.
	EndIf
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880LinOk       ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a linha da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros da Rotina:                                              ³±±
±±³          ³ 1. Banco,                                                         ³±±
±±³          ³ 2. Agencia,                                                       ³±±
±±³          ³ 3. Conta Corrente,                                                ³±±
±±³          ³ 4. Data da Baixa,                                                 ³±±
±±³          ³ 5. Data do Credito,                                               ³±±
±±³          ³ 6. Natureza,                                                      ³±±
±±³          ³ 7. Lote TMS.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880LinOk(cBanco, cAgencia, cConta, dBaixa, dDtCredito, cNatTms, cLoteTms )
Local lRet   := .T.
Local lRetPE := .T.

lRet := GDCheckKey( { '_SI_TIPDOC', 'DT6_FILDOC', 'DT6_DOC', 'DT6_SERIE', 'E1_TIPO' }, 4 )

If lRet
	lRet := T880TudOk(cBanco, cAgencia, cConta, dBaixa, dDtCredito, cNatTms, cLoteTms, .T. )
EndIf

If lRet
	If ExistBlock("TM880LOK")
		lRetPE := ExecBlock("TM880LOK", .F., .F.)
		If ValType(lRetPE) == "L"
			lRet := lRETPE
		EndIf
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880TudOk       ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida todos os campos da tela de baixa                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros da Rotina:                                              ³±±
±±³          ³ 1. Banco,                                                         ³±±
±±³          ³ 2. Agencia,                                                       ³±±
±±³          ³ 3. Conta Corrente,                                                ³±±
±±³          ³ 4. Data da Baixa,                                                 ³±±
±±³          ³ 5. Data do Credito,                                               ³±±
±±³          ³ 6. Natureza,                                                      ³±±
±±³          ³ 7. Lote TMS,                                                      ³±±
±±³          ³ 8. lChLinOk - Se executado pela LinhaOk.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880TudOk(cBanco, cAgencia, cConta, dBaixa, dDtCredito, cNatTms, cLoteTms, lChLinOk)

Local lRet 			:= .T.
Local nPosNat		:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_NATUR" } )
Local nPosMotBx		:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_MOTBX" } )
Local nPosModSpb	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_MODSPB" } )
Local nPosFilDeb	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDEB" } )
Local nPosFilDoc 	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc		:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local nPosSerie		:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
Local nPosTipo		:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPOTIT" } )
Local nPosTipDoc	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPDOC" } )

// Valida os campos que nao podem ficar em branco
lRet := lRet .And. T880NaoVazio(cBanco,STR0011)		//"Banco"
lRet := lRet .And. T880NaoVazio(cAgencia,STR0012)	//"Agencia"
lRet := lRet .And. T880NaoVazio(cConta,STR0013)		//"Conta"
lRet := lRet .And. T880NaoVazio(dBaixa,STR0014)		//"Data da Baixa"
lRet := lRet .And. T880NaoVazio(dDtCredito,STR0015)	//"Data do Credito"
lRet := lRet .And. T880NaoVazio(cNatTms,STR0017)	//"Natureza"
lRet := lRet .And. T880NaoVazio(cLoteTms,STR0018) .And. T880ChkLote("R", cLoteTms) //"Lote"

// Se a linha nao estiver excluida, valida os campos
If !GdDeleted()
	
	If lRet 
		If aCols[n][nPosTipDoc] = "1" // Valida Conhecimento
			// Valida os campos que nao podem ficar em branco para o conhecimento
			lRet := lRet .And. T880NaoVazio(aCols[n][nPosFilDoc], aHeader[nPosFilDoc][1])
			lRet := lRet .And. T880NaoVazio(aCols[n][nPosDoc], aHeader[nPosDoc][1])
			lRet := lRet .And. T880NaoVazio(aCols[n][nPosSerie], aHeader[nPosSerie][1])
		Else
			// Valida os campos que nao podem ficar em branco para fatura
			lRet := lRet .And. T880NaoVazio(aCols[n][nPosDoc],aHeader[nPosDoc][1])
			lRet := lRet .And. T880NaoVazio(aCols[n][nPosTipo],aHeader[nPosTipo][1])
			lRet := lRet .And. T880NaoVazio(aCols[n][nPosMotBx],aHeader[nPosMotBx][1])
		Endif	
	Endif	
	
	// Valida os campos que nao podem ficar em branco para ambos (ctrc e faturas)
	lRet := lRet .And. T880NaoVazio(aCols[n][nPosMotBx],aHeader[nPosMotBx][1])
	lRet := lRet .And. T880NaoVazio(aCols[n][nPosNat],aHeader[nPosNat][1])
	lRet := lRet .And. T880NaoVazio(aCols[n][nPosModSpb],aHeader[nPosModSpb][1])
	lRet := lRet .And. T880NaoVazio(aCols[n][nPosFilDeb],aHeader[nPosFilDeb][1])

Endif

// Se validou todos os campos, nao foi uma chamada a partir da linhaok, verifica se o total recebido confere com o total
// do credito
If lRet .And. !lChLinOk .And. Transform(nTotRec, "@E 999,999,999,999.99" ) != Transform(nTotCred, "@E 999,999,999,999.99" )
	lRet := .F.
	Aviso(STR0029,STR0030 + Chr(13)+ Chr(13)+; //"Problema na baixa de documentos"###"Total recebido nao confere com total do crédito"
			STR0016 + " : " + Transform(nTotCred, "@E 999,999,999,999.99") + Chr(13) +; //"Total do crédito : "
			STR0019 + " : " + Transform(nTotRec , "@E 999,999,999,999.99") + Chr(13), {STR0008}) //"Total recebido	: "###"Ok"
Endif

If lRet
	If ExistBlock("TM880TOK")
		lRetPE := ExecBlock("TM880TOK", .F., .F., {cBanco, cAgencia, cConta, dBaixa, dDtCredito, cNatTms, cLoteTms, nTotCred, nTotRec})
		If ValType(lRetPE) == "L"
			lRet := lRETPE
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880GrvBx       ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a baixa do titulo gerado pelo documento de transporte       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T880GrvBx(dBaixa, aColsBx, nX, nPosValRec, nPosJuros, nPosDesc, nPosAcresc, nPosDecresc)

Local lRet := .F.

If RecLock("SE1",.F.)
	lRet := .T.
	SE1->E1_BAIXA		:= dBaixa
	SE1->E1_VALLIQ		:= aColsBx[nX][nPosValRec]
	SE1->E1_SALDO		:= 0
	SE1->E1_MOVIMEN		:= dBaixa
	SE1->E1_STATUS		:= Iif(SE1->E1_SALDO>0.01,"A","B")
	SE1->E1_JUROS		:= aColsBx[nX][nPosJuros] + aColsBx[nX][nPosAcresc]
	SE1->E1_DESCONT		:= aColsBx[nX][nPosDesc] + aColsBx[nX][nPosDecresc]
	SE1->(MsUnlock())
Endif
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa850Leg  ³ Autor ³ Claudio D. de Souza ³ Data ³ 23.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA880                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmsa880Leg(nReg)

Local aLegenda := { 	{"BR_VERDE"		, STR0034 },; //"Docto. não faturado"
						{"BR_AZUL"		, STR0035 } } //"Docto. faturado"
Local uRetorno := .T.
   
If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { 'Empty(DT6_PREFIX+DT6_NUM+DT6_TIPO)', aLegenda[1][1] } )
	Aadd(uRetorno, {'!Empty(DT6_PREFIX+DT6_NUM+DT6_TIPO)', aLegenda[2][1] } )
Else
	BrwLegenda(cCadastro,STR0005, aLegenda) //"Legenda"
Endif

Return uRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880NaoVazio    ³ Autor ³ Claudio D. de Souza   ³ Data ³ 23/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida um campo da tela de baixa e exibe Help informando qual campo³±±
±±³          ³esta em branco                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function T880NaoVazio(xVar, cText)

Local lRet := .T.

If Empty(xVar)
	lRet := .F.
	Help(1," ","NVAZIO",,cText,4,0) //"Este campo deve ser informado"
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T880ChkLot³ Autor ³ Claudio D. de Souza   | Data ³ 23/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se um lote ja existe                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ T880ChkLote(cRecPag, cLote)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRecPag e cLote                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function T880ChkLote(cRecPag,cLote)

Local cAlias:=ALIAS(),lRet:=.T.

dbSelectArea("SE5")
dbSetOrder(5)
If SE5->(MsSeek(xFilial("SE5")+cLote))
	While SE5->(!Eof()) .And. SE5->E5_LOTE == cLote .And. SE5->E5_FILIAL == xFilial("SE5")
		If SE5->E5_RECPAG == cRecPag
			Help("",1,"LOTEEXIST") //"Ja digitado baixas por lote com este numero de Lote"
			lRet:=.F.
			Exit
		Endif
		SE5->(dbSkip())
	Enddo
Endif
dbSetOrder(1)
dbSelectArea(cAlias)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tms880Del ³ Autor ³                       | Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para verificar o evento de exclusao de linhas na     ³±±
±±³          ³MsGetDados                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tms880Del()
Local nPosValRec := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_VALREC" } )
Local nPosTipDoc := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPDOC" } )
Local nPosFilDoc := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc    := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local nPosSerie  := aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
Local nPosTipo   := aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_TIPOTIT" } )
Local nPos       := 0
Local nCount     := 0
Local lExclui    := !GdDeleted()

If !GdDeleted()
	// A linha estava ativa e esta deletando...
	nTotRec -= aCols[n][nPosValRec]
Else
	// A linha estava deletada e esta ativando...
	nTotRec += aCols[n][nPosValRec]
Endif

//--Indica no vetor aRecnos a linha
//--que foi removida:
If aCols[n][nPosTipDoc] == "1" // Baixa de CTRC
	nPos := AScan(aRecnos, {|e| e[FILDOCCTRC]+e[DOCCTRC]+e[SERIECTRC] == aCols[n,nPosFildoc]+aCols[n,nPosDoc]+aCols[n,nPosSerie]})
ElseIf aCols[n][nPosTipDoc] == "2" // Baixa de Fatura
	nPos := AScan(aRecnos, {|e| e[PREFIXOTIT]+e[NUMTIT]+e[PARCELATIT]+e[TIPOTIT] == aCols[n,nPosFildoc]+aCols[n,nPosDoc]+aCols[n,nPosSerie]+aCols[n,nPosTipo] } )
EndIf

If nPos > 0
	aRecnos[nPos][LINOK] := !lExclui
EndIf

oTotRec:Refresh()

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fTmsTpTit ³ Autor ³Igor Franzoi		    ³ Data ³ 05/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Tipo do Titulo (E1_TIPO) com base no parametro      ³±±
±±³          ³MV_TMSTIPT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fTmsTpTit() 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA880													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fTmsTpTit(cTipoParc)

Local nPosIni     := 0
Local nTamIni     := 0
Local cMvTMSTip   := SuperGetMV("MV_TMSTIPT",.F.,"")

DEFAULT	cTipoParc := ''

If !Empty(cMvTMSTip)
	If (nPosIni := At(AllTrim(cTipoParc)+"=",cMvTmsTip)) <> 0
		nPosIni += Len(AllTrim(cTipoParc)+"=")
		If (nTamIni := At(";",Substr(cMvTMSTip,nPosIni)) - 1) <= 0
			nTamIni := Len(Alltrim(Substr(cMvTMSTip,nPosIni))) + 1
		EndIf
		cTipoParc := PadR(Substr(cMvTMSTip,nPosIni,nTamIni),TamSX3("E1_TIPO")[1])
	EndIf
EndIf

Return cTipoParc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Private aRotina := {	{STR0002, "AxPesqui",	0, 1,0,.F.},;	//"Pesquisar"
						{STR0003, "Tmsa880Vis",	0, 2,0,NIL},;	//"Visualizar"
						{STR0004, "Tmsa880Bai",	0, 4,0,NIL},;	//"Baixar"
						{STR0005, "Tmsa880Leg",	0, 6,0,.F.} }	//"Legenda"

If ExistBlock("TM880MNU")
	ExecBlock("TM880MNU",.F.,.F.)
EndIf

Return(aRotina)
