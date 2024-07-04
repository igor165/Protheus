// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "OFIOM270.CH"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM270 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 19/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Escala de Produtivos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM270(cParam01)
Local lProd        := .t.
Local nPosAcesso   := 0
Local lAcesso      := .F.
Private cProd      := space(6)
Private dDtIn      := dDataBase+1
Private dDtFi      := dDataBase+31
Private cPDom      := space(6)
Private cPSeg      := space(6)
Private cPTer      := space(6)
Private cPQua      := space(6)
Private cPQui      := space(6)
Private cPSex      := space(6)
Private cPSab      := space(6)
Private cPFer      := space(6)
Private cPAux      := space(6)
Private cNome      := space(50)
Private cVaiFil    := ""
Private cFilPro    := Space(TamSx3("VOE_FILPRO")[1])
Private aFeriados  := {}

Default cParam01 := cProd
cProd := cParam01
if !Empty(cProd)
	lProd := .f.
	if ! FS_VPROD(0)
		return
	endif
endif

If MPUserHasAccess("OFIOA380",,,.F.)
	lAcesso := .T.
EndIf

DEFINE MSDIALOG oDlg1 FROM 000,000 TO 017,060 TITLE STR0001 OF oMainWnd
@ 007,006 SAY STR0002 SIZE 35,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 006,030 MSGET oProd VAR cProd PICTURE "!!!!!!" F3 "A1C" VALID FS_VPROD(1) SIZE 20,08 OF oDlg1 PIXEL COLOR CLR_HBLUE WHEN lProd
@ 007,063 SAY cNome SIZE 300,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 007,160 SAY RetTitle("VOE_FILPRO") SIZE 35,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 006,190 MSGET oFilPro VAR cFilPro PICTURE "@!" VALID (Vazio() .or. ExistCpo("SM0",cEmpAnt+cFilPro)) F3 "SM0_01" SIZE 20,08 OF oDlg1 PIXEL COLOR CLR_HBLUE WHEN lProd
@ 025,006 SAY STR0003 SIZE 32,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 024,030 MSGET oDtIn VAR dDtIn PICTURE "@D" VALID FS_VDATA(1) SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 025,087 SAY STR0004 SIZE 10,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 024,093 MSGET oDtIn VAR dDtFi PICTURE "@D" VALID FS_VDATA(2) SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 041,006 SAY STR0005 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 040,030 MSGET oPDom VAR cPDom PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPDom) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 041,069 SAY STR0006 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 052,030 MSGET oPSeg VAR cPSeg PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPSeg) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 053,069 SAY STR0007 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 064,030 MSGET oPTer VAR cPTer PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPTer) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 065,069 SAY STR0008 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 076,030 MSGET oPQua VAR cPQua PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPQua) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 077,069 SAY STR0009 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 088,030 MSGET oPQui VAR cPQui PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPQui) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 089,069 SAY STR0010 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 100,030 MSGET oPSex VAR cPSex PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPSex) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 101,069 SAY STR0011 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 112,030 MSGET oPSab VAR cPSab PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPSab) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 113,069 SAY STR0012 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 041,137 SAY STR0013 SIZE 45,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 052,135 MSGET oPFer VAR cPFer PICTURE "!!!!!!" F3 "VOH" VALID FS_VESCA(cPFer) SIZE 01,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
@ 085,125 BUTTON oEsca PROMPT OemToAnsi(STR0014) OF oDlg1 SIZE 55,10 PIXEL  ACTION ( Processa( {|| FS_ESCALAR() } ) , oProd:SetFocus() )
@ 081,123 TO 097,182 LABEL "" OF oDlg1 PIXEL // Caixa Botao ESCALAR
@ 105,125 BUTTON oSair PROMPT OemToAnsi(STR0015) OF oDlg1 SIZE 55,10 PIXEL  ACTION (oDlg1:End())
@ 040,160 BUTTON oCadFer PROMPT OemToAnsi("...") OF oDlg1 SIZE 09,10 PIXEL  ACTION ( OFIOA380() , oPFer:SetFocus() ) WHEN lAcesso
@ 101,123 TO 117,182 LABEL "" OF oDlg1 PIXEL // Caixa Botao Sair
@ 002,003 TO 019,238 LABEL "" OF oDlg1 PIXEL // Caixa Produtivo
@ 020,003 TO 126,238 LABEL "" OF oDlg1 PIXEL // Caixa Escalas
// Ponto de Entrada para Inserção de campos na Tela
If ExistBlock("OM270TEL")
	ExecBlock("OM270TEL",.f.,.f.)
EndIf
ACTIVATE MSDIALOG oDlg1 CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VPROD ³ Autor ³  Andre Luis Almeida   ³ Data ³ 19/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao no produto.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VPROD(nTip)
Local lRet := .t.
Default nTip := 1
dDtIn := dDataBase+1
dDtFi := dDataBase+31
If !Empty(cProd)
	DbSelectArea("VAI")
	DbSetOrder(1)
	If	DbSeek( xFilial("VAI") + cProd )
		If VAI->VAI_FUNPRO == "1"
			cNome   := VAI->VAI_NOMTEC
			cVaiFil := VAI->VAI_FILPRO
			DbSelectArea("VOE")
			DbSetOrder(1)
			DbSeek( xFilial("VOE") + cProd + dtos(dDataBase+370) , .t. )
			If !BOf()
				DbSelectArea("VOE")
				DbSkip(-1)
			EndIf
			If cProd == VOE->VOE_CODPRO
				If dDtIn <= VOE->VOE_DATESC
					dDtIn := VOE->VOE_DATESC+1
					dDtFi := VOE->VOE_DATESC+31
				Else
					dDtIn := dDataBase+1
					dDtFi := dDataBase+31
				EndIf
			Else
				dDtIn := dDataBase+1
				dDtFi := dDataBase+31
			EndIf
		Else
			cNome := space(50)
			MsgAlert(STR0017+cProd+STR0018,STR0016)
			lRet := .f.
		EndIf
	Else
		cNome := space(50)
		MsgAlert(STR0019,STR0016)
		lRet := .f.
	EndIf
EndIf
if nTip != 0
	oDlg1:Refresh()
endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VDATA ³ Autor ³  Andre Luis Almeida   ³ Data ³ 19/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao na data.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VDATA(nTipo)
Local lRet := .t.
If Empty(dDtIn) .and. nTipo == 1
	MsgAlert(STR0020,STR0016)
	lRet := .f.
ElseIf Empty(dDtFi) .and. nTipo == 2
	MsgAlert(STR0021,STR0016)
	lRet := .f.
Else
	If nTipo == 1 // Data Inicial
		If	dDtIn <= dDataBase
			MsgAlert(STR0022+Transform(dDataBase+1,"@D")+"...",STR0016)
			lRet := .f.
		Else
			DbSelectArea("VOE")
			DbSetOrder(1)
			DbSeek( xFilial("VOE") + cProd + dtos(dDataBase+366) , .t. )
			If !BOf()
				DbSelectArea("VOE")
				DbSkip(-1)
			EndIf
			If cProd == VOE->VOE_CODPRO
				If dDtIn <= VOE->VOE_DATESC
					MsgAlert(STR0023+cProd+STR0024+Transform(VOE->VOE_DATESC,"@D")+"...",STR0016)
					lRet := .f.
				Else
					cPAux := VOE->VOE_CODPER
				EndIf
			EndIf
		EndIf
	Else // Data Final
		If dDtFi > (dDataBase+365)
			MsgAlert(STR0025,STR0016)
			lRet := .f.
		ElseIf dDtFi < dDtIn
			MsgAlert(STR0026,STR0016)
			lRet := .f.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VESCA ³ Autor ³  Andre Luis Almeida   ³ Data ³ 19/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao no campo escala.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VESCA(cEscala)
Local lRet := .t.
Local lVOH_MSBLQL := VOH->(FieldPos("VOH_MSBLQL")) > 0

If !Empty(cEscala)
	DbSelectArea("VOH")
	DbSetOrder(1)
	If	!DbSeek( xFilial("VOH") + cEscala )
		MsgAlert(STR0027,STR0016)
		lRet := .f.
	Else
		// Período Bloqueado
		If lVOH_MSBLQL
			If OFA0800016_PeriodoBloqueado(cEscala)
				lRet := .f. // A mensagem já é exibida dentro da função OFA0800016_PeriodoBloqueado()
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ESCALAR³ Autor ³ Andre Luis Almeida   ³ Data ³ 19/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Botao escala.			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ESCALAR()
Local ni
Local nDias := ( ( dDtFi - dDtIn ) + 1 )
Local nDia := ni := 0
Local cCPer := ""
Local lGrava := .f.

DbSelectArea("VAI")
DbSetOrder(1)
DbSeek( xFilial("VAI") + cProd )
If !Empty(VAI->VAI_DATDEM) .and. dDtFi > VAI->VAI_DATDEM
	MsgInfo(STR0031+DtoC(VAI->VAI_DATDEM),STR0016)
ElseIf !Empty(cProd)
	// Montagem dos Feriados
	aFeriados := OM0270016_MontagemDosFeriados()

	For ni := 1 to nDias
		lGrava := .f.
		If FS_VERFERIADO(dDtIn+(ni-1)) // Feriados
			If !Empty(cPFer)
				lGrava := .t.
				cCPer := cPFer
			EndIf
		Else // Dia Normal
			nDia := Dow(dDtIn+(ni-1))
			Do Case
				Case nDia == 1 // Domingo
					If !Empty(cPDom)
						lGrava := .t.
						cCPer := cPDom
					EndIf
				Case nDia == 2 // Segunda-Feira
					If !Empty(cPSeg)
						lGrava := .t.
						cCPer := cPSeg
					EndIf
				Case nDia == 3 // Terca-Feira
					If !Empty(cPTer)
						lGrava := .t.
						cCPer := cPTer
					EndIf
				Case nDia == 4 // Quarta-Feira
					If !Empty(cPQua)
						lGrava := .t.
						cCPer := cPQua
					EndIf
				Case nDia == 5 // Quinta-Feira
					If !Empty(cPQui)
						lGrava := .t.
						cCPer := cPQui
					EndIf
				Case nDia == 6 // Sexta-Feira
					If !Empty(cPSex)
						lGrava := .t.
						cCPer := cPSex
					EndIf
				Case nDia == 7 // Sabado
					If !Empty(cPSab)
						lGrava := .t.
						cCPer := cPSab
					EndIf
			EndCase
		EndIf
		If lGrava .and. cPAux # cCPer
			cPAux := cCPer
			DbSelectArea("VOE")
			RecLock("VOE",.t.)
			VOE->VOE_FILIAL := xFilial("VOE")
			VOE->VOE_CODPRO := cProd
			VOE->VOE_DATESC := dDtIn+(ni-1)
			VOE->VOE_CODPER := cCPer
			VOE->VOE_FILPRO := cFilPro
			// Insere Campos para gravação na tabela VOE (Escala de Produtivos)
			If ExistBlock("OM270GRV")
				ExecBlock("OM270GRV",.f.,.f.)
			EndIf
			MsUnlock()
		EndIf
	Next
	MsgAlert(STR0028+cProd+STR0029,STR0016)
Else
	MsgAlert(STR0030,STR0016)
EndIf
cProd := cPDom := cPSeg := cPTer := cPQua := cPQui := cPSex := cPSab := cPFer := cPAux := space(6)
cNome := space(50)
dDtIn := dDataBase+1
dDtFi := dDataBase+31
oDlg1:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERFERIADO³ Autor ³ Andre Luis Almeida  ³ Data ³ 19/08/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para verificar os feriados.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERFERIADO(dDataVer)
Local lRet := .f.

If AScan(aFeriados, { |x| x == StrZero(Day(dDataVer), 2) + "/" + StrZero(Month(dDataVer), 2);
	.Or. x == StrZero(Day(dDataVer), 2) + "/" + StrZero(Month(dDataVer), 2) + "/" + StrZero(Val(Right(Dtoc(dDataVer), 2)), 2) }) > 0
	lRet := .t.
EndIf
Return(lRet)

/*/{Protheus.doc} OM0270016_MontagemDosFeriados
Função para retorno de todos os Feriados (Nacionais, Estaduais e Municipais)
@author Fernando Vitor Cavani
@since 18/05/2020
@version 1.0
@return aRet - Vetor - Vetor completo dos feriados cadastrados
@param
@type function
/*/
Static Function OM0270016_MontagemDosFeriados()
Local cSql      := ""
Local cAliasSX5 := "TSX5"
Local cData     := ""
Local aRet      := {}

cSQL := "SELECT X5_DESCRI "
cSQL += "FROM " + RetSQLName("SX5") + " "
cSQL += "WHERE X5_FILIAL IN('" + xFilial("SX5") + "', '" + Iif(!Empty(cFilPro), cFilPro, cVaiFil) + "') "
cSQL += "  AND X5_TABELA = '63' "
cSQL += "  AND D_E_L_E_T_ = ' '"
dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), cAliasSX5, .T., .T.)

While !(cAliasSX5)->(Eof())
	If Empty(Alltrim(Substr((cAliasSX5)->(X5_DESCRI), 7, 2))) .Or.;
		((Substr((cAliasSX5)->(X5_DESCRI), 7, 2) >= StrZero(Val(Right(Dtoc(dDtIn), 2)), 2)) .And. (Substr((cAliasSX5)->(X5_DESCRI), 7, 2) <= StrZero(Val(Right(Dtoc(dDtFi), 2)), 2)))
			aadd(aRet, Alltrim(Left((cAliasSX5)->(X5_DESCRI), 8)))
	EndIf

	(cAliasSX5)->(dbSkip())
EndDo

(cAliasSX5)->(dbCloseArea())
DbSelectArea("SX5")
Return aRet