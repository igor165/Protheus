#INCLUDE "ATFA460.CH"
#Include "PROTHEUS.CH"
#INCLUDE "FONT.CH"

STATIC lAf46Auto:= .F.
STATIC lAvpAtf2 := NIL
STATIC dUltDepr := CTOD("//")
STATIC cItem	:= ""
STATIC __cProcPrinc	:= "ATFA460"
Static lMultMoed := .T.
Static lBaixaATF := .F.

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
//AVP2
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ATFA460	³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 02.05.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de apropriacao do AVP de bens de provisao 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFA460()

Local aCores    := Af460Leg(.T.)
Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

Private cPerg	  := "AFA460"
Private cCadastro := STR0001	//"Apropriação de provisão - AVP"
Private aRotina   := MenuDef()

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := AFAvpAtf2(.T.)
Endif

dUltDepr := GetNewPar("MV_ULTDEPR", STOD("19800101"))

If !lDefTop
	Help("  ",1,"AFR460TOP",,STR0002 ,1,0)  //"Função disponível apenas para ambientes TopConnect"
	Return .T.
EndIf

//Verifica de o AVP esta implantado na base
If lAvpAtf2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey (VK_F12,{|a,b| AcessaPerg(cPerg,.T.)})

	Pergunte(cPerg,.F.)

	dbSelectArea("FNN")
	FNN->( dbSetOrder( 1 ) )

	mBrowse(,,,,"FNN",,,,,,aCores)

Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF460Inc  ºAutor  ³Microsiga           º Data ³  05/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina do menu da rotina ATFA460                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460Inc(cAlias,nReg,nOpc)
Local aArea := GetArea()

If Pergunte(cPerg,.T.)
	AF460Apur()
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF460Apur³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para apuracao de AVP de imobilizados			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF460Apur(lAutoApr,cGrpBem,cIdProcSN4,dInDepr,aAVPMan)

Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local nX			:= 0
Local cPerg			:= "AFA460"
Local aSelFil		:= {}
Local aArea			:= GetArea()
Local lRet        := .T.

DEFAULT lAutoApr := .F.
DEFAULT cGrpBem := ""
DEFAULT cIdProcSN4 := ""
DEFAULT dInDepr	  := GetMV("MV_ULTDEPR",.F., STOD("19800101")) + 1
DEFAULT aAVPMan := {}

If !lAutoApr

	Aadd(aSays,STR0003)	//"Este programa tem como objetivo permitir a constituição da provisão a partir"
	Aadd(aSays,STR0004)	//"dos movimentos de depreciação de ativos do tipo Orçamento. "
	Aadd(aSays," ")
	Aadd(aSays,STR0005)	//"Somente imobilizados cujo tipo de AVP seja igual a Parcela serão considerados "
	Aadd(aSays,STR0006)	//"para este processo. "
	Aadd(aSays,STR0007)	//"Esta rotina somente deverá ser executada na mesma database do último cálculo mensal. "
	Aadd(aSays,STR0008 + Dtoc(dUltDepr) )  //"Ultimo calculo em :"

	Aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. )}})
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( cCadastro, aSays, aButtons)
	Pergunte(cPerg,.F.)
Else
	nOpca := 1
	//Seto o grupo de bens para o ativo de provisao
	mv_par01 := cGrpBem
	//Seto para que nao seja apresentada a tela de selecao de filiais
	mv_par02 := 2
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                     ³
//³==========================================================³
//³ mv_par01 // Grupo de Bens                                ³
//³ mv_par02 // Seleciona Filiais                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1

	If mv_par02 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf
	Processa({|| lRet := AF460PApur(aSelFil,lAutoApr,cIdProcSN4,dInDepr,aAVPMan,mv_par01)})
Endif

Set Key VK_F12 To

RestArea(aArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF460PApur³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de processamento da apuracao AVP de imobilizados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aSelFil   = Array contendo as filiais a serem processadas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF460PApur(aSelFil,lAutoApr,cIdProcSN4,dInDepr,aAVPMan,cGrpBens)

Local cIdProc     := ""
Local cFilAtu     := cFilAnt
Local nSaveSx8Len := GetSx8Len()
Local lFNNCompart := Empty(xFilial("FNN"))
Local lRet        := .T.
Local nX          := 0

DEFAULT aSelFil     := {}
DEFAULT lAutoApr    := .F.
DEFAULT cIdProcSN4  := ""
DEFAULT dInDepr     := dUltDepr + 1
DEFAULT aAVPMan     := {}
DEFAULT cGrpBens    := ""

//Data da ultima depreciacao
IF Empty(dUltDepr)
	dUltDepr := GetNewPar("MV_ULTDEPR", STOD("19800101"))
Endif

//Verifica parametros contabilizacao
lRet := CTBINTRAN(1,.F.)

//Valida data do processamento
If lRet .and. !lAutoApr .and. dDatabase != dUltDepr
	Help(" ",1,"AF460DTDEPR",,STR0009 +CRLF+ STR0008 + Dtoc(dUltDepr),1,0)   //"Esta rotina somente deverá ser executada na mesma database do último cálculo mensal. "###"Ultimo calculo em :"
	lRet := .F.
Endif

//Valida o compartilhamento das tabelas envolvidas
If lRet .and. xFilial("SN4") != xFilial("FNN")
	Help(" ",1,"AF460SN4FNN",,STR0010+CRLF+STR0011,1,0) //"O compartilhamento de filial das tabelas SN4 (Movimentacoes do Ativo Fixo) e FNO (Apropriação de Provisão) devem ser iguais."###"Ajuste o compartilhamento da tabela FNO (Apropriação de Provisão) para que o processo possa ser realizado"
	lRet := .F.
Endif

If lRet .and. !lAutoApr .and. FNN->(MsSeek(xFilial("FNN")+DTOS(dDatabase)))
	While !FNN->(EOF()) .AND. FNN->FNN_FILIAL+DTOS(FNN->FNN_DTPROC) == xFilial("FNN")+DTOS(dDatabase)
		If FNN->FNN_STATUS == '1'
			Help(" ",1,"AF460JAPROC",,STR0012,1,0) //"Já existe processamento para esta data. Não são permitidos diversos processamentos para uma mesma data."
			lRet := .F.
			Exit
		Endif
		FNN->(DBSkip())
	Enddo
Endif


If lRet

	//Se for compartilhado ou o array estiver vazio
	//Processo apenas a filial corrente
	If lFNNCompart .or. Len(aSelFil) == 0
		aSelFil	:= {cFilAnt}
	Endif

	For nX := 1 to Len(aSelFil)

		cFilAnt	:= aSelFil[nX]

		//Seleciona dados para a filial atual
		aRecnos	:= AF460SelDados(cIdProcSN4)

		If Len(aRecnos) > 0

			//id do Movimento
			If !lAutoApr
				cIdProc	:= GetSxeNum('FNN','FNN_IDPROC','FNN_IDPROC'+cEmpAnt,2)
			Endif

			//Processa a constituicao de provisorios
			lRet := AF460CTPrv(aRecnos,cIdProc,lAutoApr,dInDepr,aAVPMan,cGrpBens)
		Else
			If Alltrim(FunName()) == "ATFA460"
				Help(" ",1,"RECNO")
				lRet := .F.
			EndIf
		Endif

	Next
Endif

// Confirma o cCODAVP
While (GetSx8Len() > nSaveSx8Len)
	ConfirmSX8()
Enddo


cFilaAnt := cFilAtu

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF460SelDados³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24.10.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecao dos dados para apuracao AVP de imobilizados  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF460SelDados(cIdProcSN4)

Local cQuery	:= ""
Local aRecnos	:= {}
Local aArea		:= GetArea()
Local lDefTop   := IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local cNextAlias	:= ""

DEFAULT cIdProcSN4 = ""

lBaixaATF	:= IsInCallStack("ATFA036")

If lDefTop

	//Selecao de bens constituidos para apuracao do AVP
	//- Bens com constituicao ativa e
	//- que nao possuam movimentos posteriores a data de processamento
	cQuery := "SELECT SN4.R_E_C_N_O_ RECSN4, N4_FILIAL, N4_CBASE, N4_ITEM FROM "+RetSQLTab("SN4")

	cQuery += "INNER JOIN " + RetSQLTab('SN1')
	cQuery += "  ON  SN4.N4_FILIAL = SN1.N1_FILIAL AND "
	cQuery += "      SN4.N4_CBASE  = SN1.N1_CBASE  AND "
	cQuery += "      SN4.N4_ITEM   = SN1.N1_ITEM       "

	cQuery += "INNER JOIN " + RetSQLTab('SN3')
	cQuery += "  ON  SN4.N4_FILIAL  = SN3.N3_FILIAL  AND "
	cQuery += "      SN4.N4_CBASE   = SN3.N3_CBASE   AND "
	cQuery += "      SN4.N4_ITEM    = SN3.N3_ITEM    AND "
	cQuery += "      SN4.N4_TIPO    = SN3.N3_TIPO    AND "
	cQuery += "      SN4.N4_SEQREAV = SN3.N3_SEQREAV AND "
	cQuery += "      SN4.N4_SEQ     = SN3.N3_SEQ         "

	cQuery += "WHERE "
	cQuery += " SN4.N4_FILIAL = '"+xFilial("SN4")+"' AND "
	If cPaisLoc == "RUS"
		cQuery += " SN4.N4_OCORR = '06' AND "
	Else
		cQuery += " SN4.N4_OCORR = '20' AND "
	EndIf
	cQuery += " SN4.N4_DATA = '"+DTOS(dDataBase)+"' AND "
	cQuery += " SN4.N4_TIPOCNT = '4' AND  "
	cQuery += " SN1.N1_STATUS NOT IN ('2','3') AND "
	cQuery += " SN1.N1_PATRIM IN ('O') AND "
	cQuery += " SN1.N1_TPAVP  = '2' AND "

	If lBaixaAtf
		cQuery += " SN3.N3_BAIXA <> '0' AND "
	Else
		cQuery += " SN3.N3_BAIXA = '0' AND "
	Endif

	If lIsRussia
		cQuery += " SN3.N3_OPER = '1' AND " // CAZARINI - 22.01.2017 - Asset Into Operation?
	Endif
	//Utilizado por rotinas externas (baixa ou inclusao de bem classificado como orcamento)
	If !Empty(cIdProcSN4)
		cQuery += " SN4.N4_IDMOV = '"+cIdProcSN4+"' AND "
	Endif

	cQuery += " SN1.D_E_L_E_T_ = ' ' AND "
	cQuery += " SN4.D_E_L_E_T_ = ' ' AND "
	cQuery += " SN3.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY N4_FILIAL, N4_CBASE, N4_ITEM "

	cQuery := ChangeQuery(cQuery)

	cNextAlias := GetNextAlias()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

	While !( (cNextAlias)->(Eof()) )

		aadd(aRecnos,(cNextAlias)->RECSN4)

		(cNextAlias)->(dbSkip())

	Enddo

	//Fecho o temporario
	(cNextAlias)->(dbCloseArea())

EndIf

dbSelectArea("FNN")

RestArea(aArea)

Return aRecnos


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AF460CTPrv ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a apuracao do AVP para a filial atual			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRecnos = Array contendo recnos das constituicoes ativas   ³±±
±±³          ³            a partir dos quais sera calculado o valor de    ³±±
±±³          ³            apuracao do AVP de imobilizados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460CTPrv(aRecnos,cIdProc,lAutoApr,dInDepr,aAVPMan,cGrpBens)

Local nX        := 0
Local lFirst    := .T.
Local lRet      := .T.
Local lLast     := .F.
Local lChange   := .F.
Local aCab      := {}
Local aItens    := {}
Local aDetalhe  := {}
Local cIdCV8    := ""
Local cProc     := __cProcPrinc + "INC"
Local cMensIni  := STR0013 //"Constituição de AVP por parcela de depreciação"
Local cBaixa    := '0'

//Controle de rotina automatica
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

Default aRecnos  := {}
Default cIdProc  := ""
Default lAutoApr := .F.
DEFAULT dInDepr  := dUltDepr + 1
Default aAVPMan  := {}
Default cGrpBens := ""

lBaixaATF	:= IsInCallStack("ATFA036")
If lBaixaATF
	cBaixa	:= '1'
Endif

dbSelectArea("SN4")
SN4->(dbSetOrder(1))

If !lAutoApr
	ProcLogIni( {},cProc,,@cIdCV8 )
	ProcLogAtu( "INICIO" , cMensIni,,,.T. )
Endif

Begin Transaction

	For nX := 1 to Len(aRecnos)
		//Posiciono tabela SN4 no registro de depreciacao
		dbSelectArea("SN4")
		SN4->(dbGoto(aRecnos[nX]))

		//Posiciono na Ficha do ativo
		SN1->(dbSetOrder(1))
		SN1->(MsSeek(xFilial("SN1")+SN4->(N4_CBASE+N4_ITEM)))

		SN3->(dbSetOrder(11))
		SN3->(MsSeek(xFilial("SN3")+SN4->(N4_CBASE+N4_ITEM+N4_TIPO+cBaixa+N4_TPSALDO+N4_SEQ+N4_SEQREAV)))

		//Guardo a chave do bem se for a primeira chamada para o bem
		If lFirst
			cChave    := xFilial("SN4")+SN4->(N4_CBASE+N4_ITEM)
			cIdPrcSN4 := SN4->N4_IDMOV
		Endif

		lChange := .F.
		lLast	:= (nX == Len(aRecnos))

		//Verifico se o bem atual eh diferente do que vinha sendo processado
		If xFilial("SN4")+SN4->(N4_CBASE+N4_ITEM) != cChave
			lChange := .T.
		Endif

		//Se mudou de bem, guardo o bem anterior no array de bens a serem incluidos
		If lChange
			//Efetua a inclusao, via rotina automatica do bem
			If AF460PUTORC(aCab,aItens,aDetalhe,cIdProc,cIdPrcSN4)
				lFirst	:= .T.
				aCab	:= {}
				aItens	:= {}
				//Dados do bem superior (PAI)
				cChave    := xFilial("SN4")+SN4->(N4_CBASE+N4_ITEM)
				cIdPrcSN4 := SN4->N4_IDMOV
			Else
				lRet := .F.
				Exit
			Endif
		Endif

		//Monta o Array para rotina automatica
		AF460Array(aCab, aItens,SN4->N4_CBASE,SN4->N4_ITEM,cGrpBens,lFirst,dInDepr,aAVPMan)
		lFirst := .F.

		//Se for o ultimo registro a ser processado
		//Efetua a inclusao, via rotina automatica do bem
		If lLast .and. !AF460PUTORC(aCab,aItens,aDetalhe,cIdProc,cIdPrcSN4)
			lRet := .F.
			Exit
		Endif

	Next

	If !lAutoApr
		If lRet
			//Grava FNN - Processamento de constituicao de AVP por parcela de depreciação (cabecalho)
			RecLock("FNN",.T.)

			FNN_FILIAL	:= xFilial("FNN")
			FNN_IDPROC	:= cIdProc
			FNN_DTPROC	:= dDataBase
			FNN_STATUS	:= "1"

			FNN->(MsUnlock())

			ProcLogAtu( "MENSAGEM",  STR0014 ,,,.T. )   //"Processo concluido sem ocorrências"
		EndIf
	Endif

	If !lRet
		ProcLogAtu( IIF(Empty(aDetalhe[2]),"MENSAGEM","ERRO"), aDetalhe[1] ,aDetalhe[2],,.F. )
	EndIf

End Transaction

If !lAutoApr
	ProcLogAtu( "FIM" ,,,,.T.)
	ProcLogView(cFilAnt,cProc,,cIdCV8)
Endif

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AF460PutOrc³ Autor ³ Mauricio Pequim Jr	³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a apuracao do AVP para a filial atual				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRecnos = Array contendo recnos das constituicoes ativas   ³±±
±±³          ³            a partir dos quais sera calculado o valor de    ³±±
±±³          ³            apuracao do AVP de imobilizados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460PUTORC(aCab,aItens,aDetalhe,cIdProc,cIdPrcSN4)

Local nPosBase	:= 0
Local nPosItem	:= 0
Local lRet	  	:= .T.
Local aArea		:= GetArea()
Local aAreaSN1	:= SN1->(GetArea())
Local aAreaSN3	:= SN3->(GetArea())

Default aCab := {}
Default aItens := {}
Default aDetalhe := {}
Default cIdProc := ""
Default cIdPrcSN4 := ""

If !(Empty(aCab)) .and. !(Empty(aItens))

	nPosBase := Ascan(aCab, {|x| Alltrim(x[1]) == "N1_BASESUP"})
	nPosItem := Ascan(aCab, {|x| Alltrim(x[1]) == "N1_ITEMSUP"})

	cCBaseSup := aCab[nPosBase][2]
	cItemSup  := aCab[nPosItem][2]


	//Geracao dos imobilizados (FILHOS)
	If AF460GerAT(aCab,aItens,aDetalhe,cCBaseSup,cItemSup)
		//Grava FNO - Processamento de constituicao de AVP por parcela de depreciação (detalhe)
		RecLock("FNO",.T.)

		FNO_FILIAL	:= xFilial("FNO")
		FNO_IDPROC	:= cIdProc
		FNO_DTPROC	:= dDataBase
		FNO_STATUS	:= "1"
		FNO_CBASE	:= SN1->N1_CBASE
		FNO_ITEM	:= SN1->N1_ITEM
		FNO_BASESP	:= cCBaseSup
		FNO_ITEMSP	:= cItemSup
		FNO_IDMVAF	:= cIdPrcSN4

		FNO->(MsUnlock())
	Else
		lRet := .F.
	Endif
Else
	lRet := .F.
Endif

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF460ArrayºAutor  ³Alvaro Camillo Neto º Data ³  25/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que realiza a gravação das fichas do ativo do        º±±
±±º          ³processo                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460Array(aCab, aItens,cCBaseSup,cItemSup,cGrpBens,lFirst,dInDepr,aAVPMan)

Local lRet		:= .T.
Local aItensAux	:= {}
Local aParam	:= {}
Local cMoedaATF	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local aArea		:= GetArea()
Local dDataBkp	:= dDataBase
Local aLog		:= {}
Local aEtapa	:= {}
Local nX	:= 0
Local nY		:= 0
Local __nQuantas:= If(lMultMoed,AtfMoedas(),5)	// Controle de multiplas moedas
Local cPatrim   := "N"
Local aGrupo    := {}
Local aCampoExc := {}

dDataPrc := SN4->N4_DATA

DEFAULT aCab := {}
DEFAULT aItens := {}
DEFAULT cCBaseSup := ""
DEFAULT cItemSup := ""
DEFAULT cGrpBens := ""
DEFAULT lFirst := .T.
DEFAULT dInDepr	:= dUltDepr + 1
Default aAVPMan := {}

If lFirst

	cItem := ATFXProxIt(cFilAnt,SN4->N4_CBASE)

	AAdd(aCab,{"N1_CBASE"  	, cCBaseSup			,NIL})
	AAdd(aCab,{"N1_ITEM"   	, cItem				,NIL})
	AAdd(aCab,{"N1_AQUISIC"	, ddatabase			,NIL})
	AAdd(aCab,{"N1_DESCRIC"	, SN1->N1_DESCRIC 	,NIL})
	AAdd(aCab,{"N1_QUANTD" 	, 1					,NIL})
	AAdd(aCab,{"N1_PATRIM" 	, "V"	    		,NIL})
	AAdd(aCab,{"N1_GRUPO" 	, cGrpBens		 	,NIL})
	AAdd(aCab,{"N1_STATUS" 	, "1"				,NIL})
	AAdd(aCab,{"N1_PROJETO"	, SN1->N1_PROJETO	,NIL})
	AAdd(aCab,{'N1_PROJREV'	, SN1->N1_PROJREV	,NIL})
	AAdd(aCab,{'N1_PROJETP'	, SN1->N1_PROJETP	,NIL})
	AAdd(aCab,{'N1_PROJITE'	, SN1->N1_PROJITE	,NIL})
	AAdd(aCab,{'N1_LOCAL'	, SN1->N1_LOCAL		,NIL})
	AAdd(aCab,{'N1_INDAVP'	, SN1->N1_INDAVP	,NIL})
	AAdd(aCab,{'N1_INIAVP'	, dDataBase      	,NIL})
	AAdd(aCab,{'N1_DTAVP'	, SN1->N1_DTAVP		,NIL})
	AAdd(aCab,{'N1_TPAVP'	, "1"				,NIL})
	AAdd(aCab,{'N1_ORIGEM'	, "ATFA460"			,NIL})
	AAdd(aCab,{"N1_BASESUP"	, cCBaseSup			,NIL})
	AAdd(aCab,{"N1_ITEMSUP"	, cItemSup			,NIL})

Endif

aItensAux := {}

AAdd(aItensAux,{"N3_CBASE"	    , cCBaseSup		 	,NIL})
AAdd(aItensAux,{"N3_ITEM"       , cItem				,NIL})
AAdd(aItensAux,{"N3_TIPO"  		, SN3->N3_TIPO  	,NIL})
AAdd(aItensAux,{"N3_TPSALDO"    , SN3->N3_TPSALDO	,NIL})
AAdd(aItensAux,{"N3_TPDEPR"  	, '1'				,NIL})
AAdd(aItensAux,{"N3_BAIXA" 		, "0"           	,NIL})
AAdd(aItensAux,{"N3_HISTOR" 	, SN3->N3_HISTOR	,NIL})
AAdd(aItensAux,{"N3_DINDEPR" 	, dInDepr+1		    ,NIL})

aValorAVP := A460AVPMAN(aAVPMan,SN3->N3_TIPO,SN3->N3_TPSALDO)
If !Empty(aValorAVP)
	If aValorAVP[1] > 0
		AAdd(aItensAux,{"N3AVPPLAN" , aValorAVP[1] ,NIL})
	EndIf
	If aValorAVP[2] > 0
		AAdd(aItensAux,{"N3AVPREAL" , aValorAVP[2] ,NIL})
	EndIf
EndIf

//Valores
For nY := 1 to __nQuantas
	cMoeda := AllTrim(Str(nY))
	AAdd(aItensAux,	{"N3_VORIG"+cMoeda,SN4->&("N4_VLROC"+cMoeda) ,NIL})
	AAdd(aItensAux,{IIF(cMoeda <= '9',"N3_TXDEPR","N3_TXDEP") + cMoeda , 0 ,NIL})
Next nY

AADD(aCampoExc,"NG_FILIAL")
AADD(aCampoExc,"NG_TPSALDO")
AADD(aCampoExc,"NG_TPDEPR")
AADD(aCampoExc,"NG_VMXDEPR")
AADD(aCampoExc,"NG_CRIDEPR")
AADD(aCampoExc,"NG_CALDEPR")
AADD(aCampoExc,"N3_FILIAL")
AADD(aCampoExc,"N3_TPSALDO")
AADD(aCampoExc,"N3_TPDEPR")
AADD(aCampoExc,"N3_VMXDEPR")
AADD(aCampoExc,"N3_CRIDEPR")
AADD(aCampoExc,"N3_CALDEPR")
If Empty(cGrpBens)
	aGrupo := SNG->(dbStruct())
	For nX := 1 to Len(aGrupo)
		cCampoN3 := Alltrim("N3_" + Subs(aGrupo[nX,1], 4))
		If SN3->(FieldPos(cCampoN3)) > 0 .And. !("TXDEP" $  Alltrim(aGrupo[nX,1])) .And. aScan( aCampoExc , { |x| Alltrim(aGrupo[nX,1]) == x } ) <= 0
			AAdd(aItensAux,{cCampoN3, SN3->(&cCampoN3) ,NIL})
		EndIf
	Next nX
Else
	SNG->(MsSeek(xFilial("SNG")+cGrpBens))
	aGrupo := SN3->(dbStruct()) // utiliza a Estrutura do N3
	For nX := 1 to Len(aGrupo)
		cCampoNG := Alltrim("NG_" + Subs(aGrupo[nX,1], 4))  // Cria o Nome do campo no NG
		cCampoN3 := Alltrim("N3_" + Subs(aGrupo[nX,1], 4))  // Cria o Nome do campo no N3
		//Verifica se o Campo do N3 existe no NG
		//Se no NG não tiver conteudo pega ele do N3
		If SNG->(FieldPos(cCampoNG)) > 0 .And. Empty(SNG->(&cCampoNG)) .And. !("TXDEP" $  Alltrim(aGrupo[nX,1])) .And. aScan( aCampoExc , { |x| Alltrim(aGrupo[nX,1]) == x } ) <= 0
			AAdd(aItensAux,{cCampoN3, SN3->(&cCampoN3) ,NIL})
		Endif
	Next nX
Endif

aAdd(aItens,aItensAux)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF430GerATºAutor  ³Alvaro Camillo Neto º Data ³  25/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que realiza a gravação das fichas do ativo do        º±±
±±º          ³processo                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460GerAT(aCab,aItens,aDetalhe,cCBaseSup,cItemSup)

Local lRet		:= .T.
Local aParam	:= {}
Local cMoedaATF	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local aArea		:= GetArea()
Local cItem 	:= ""
Local aLog		:= {}
Local nY		:= 0
Local cIdCV8	:= ""
Local lFirst	:= .T.
Local cDetalhe  := ""

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.

aAdd( aParam, {"MV_PAR01", 2} )
aAdd( aParam, {"MV_PAR02", 1} )
aAdd( aParam, {"MV_PAR03", 2} )


MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)},aCab,aItens,3,aParam)

If lMsErroAuto
	aLog := GETAUTOGRLOG()
	lMsErroAuto := .F.
	DisarmTransaction()
	lRet := .F.

	cDetalhe := ""
	For nY := 1 to Len(aLog)
		cDetalhe += aLog[nY]
	Next nY

	aadd(aDetalhe,STR0015 + cCBaseSup + STR0016 + cItemSup )	//"Falha ao processar Imobilizado Código Base: "###" Item: "
	aadd(aDetalhe, cDetalhe )

EndIf

RestArea(aArea)

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF460Can	³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03.11.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de cancelamento de processo de apropriacao do AVP de³±±
±±³Descri‡„o ³  bens imobilizados			 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA460													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF460Can(cAlias, nReg, nOpc)

Local aArea 	:= GetArea()
Local lRet 		:= .T.
Local nOpcA		:= 0
Local cProcesso := FNN->FNN_IDPROC
Local aCores    := Af460Leg(.T.,.T.)
Local cPerg		:= "AFA460"
Local nPosRec	:= 0
Local	nQtdReg	:= 0
Local oFnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aHeadAvp  		:= {}
Local aColsAvp			:= {}
Local nOpcX				:= 0							 							// Opção da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  									// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"										// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  			// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              									// Campos estaticos na GetDados.
Local nMax         	:= 999              									// Numero maximo de linhas permitidas.
Local aAlter    		:= {}                                      	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"						  				// Funcao executada na validacao do campo
Local cSuperDel     	:= "AllwaysTrue"          			  			   // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        	:= "AllwaysTrue"    					 				// Funcao executada para validar a exclusao de uma linha do aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para a MsAdvSize e MsObjSize³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lEnchBar   		:= .F. // Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao    		:= .F. // Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY	    		:= 400 // Altura mínima da janela
Local aSize	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 			:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  		:= {}
Local aPosObj	   	:= {}
Local oDlg				:= Nil
Local oPanelMed		:= Nil
Local oGetMov			:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição das posições dos objetos na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg(cPerg,.T.)})

Pergunte(cPerg,.F.)

//Verifico se eh possivel cancelar o processo
If AF460EstOK()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o a Header e o acols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeadAvp := AF460Head()
	aColsAvp := AF460aCol(aHeadAvp,cProcesso)
	nQtdReg	:= Len(aColsAvp)
	nPosRec	:= Len(aHeadAvp)+1

	If nPosRec <= 0
		Help(" ",1,"ATF460NOT1",,STR0017,1,0) //"Não foram encontrados registros para este processo. Por favor, verifique o status do processo"
		lRet := .F.
	Else

		DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD

		// Definicao dos Objetos
		oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)

		oPanel1 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,025,025,.T.,.T. )
		oPanel1:Align 	:= CONTROL_ALIGN_TOP

		oPanel2 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,500,500,.T.,.T. )
		oPanel2:Align 	:= CONTROL_ALIGN_ALLCLIENT

		//
		// Painel 1 - Informacao do processo
		//
		@ 003 , 005 SAY STR0018 FONT oDlg:oFont PIXEL Of oPanel1 //"Processo: "
		@ 003 , 060 Say cProcesso			Picture "@!";
													FONT oFnt COLOR CLR_HBLUE;
													PIXEL Of oPanel1

		@ 012 , 005 Say STR0019 PIXEL Of oPanel1			//"Data do Processo: "
		@ 012 , 060 Say DTOC(FNN->FNN_DTPROC) SIZE 50,8  PIXEL Of oPanel1
		@ 012 , 150 Say STR0020 PIXEL Of oPanel1		//"Qtd. Registros: "
		@ 012 , 200 Say nQtdReg Picture "@E 9999999" SIZE 50,8  PIXEL Of oPanel1


		//
		// Painel 2 - Dados dos movimentos do processo
		//
		oGetAvp	:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,Len(aColsAVP),cFieldOk,cSuperDel,cDelOk,oPanel2,aHeadAvp,aColsAvp)
		oGetAvp:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

		oDlg:bInit 		:= EnchoiceBar(oDlg,{|| nOpcA:=1,oDlg:End() },{|| nOpcA:=0,oDlg:End()})
		oDlg:lCentered	:= .T.
		oDlg:Activate()

	Endif

EndIf

If nOpcA == 1
	MsgRun( STR0021 ,, {|| AF460EstPrV(aColsAvp,nPosRec) } ) 	//"Estornando o processo de constituição de AVP em parcelas selecionado..."
EndIf

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF460EstOKºAutor  ³Microsiga           º Data ³  07/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida possibilidade do processo AVP ser estornado         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                              	        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF460EstOK()

Local cAliasQry := ""
Local lRet := .T.
Local cQuery := ""

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := AFAvpAtf2(.T.)
Endif

//Data da ultima depreciacao
IF Empty(dUltDepr)
	dUltDepr := GetNewPar("MV_ULTDEPR", STOD("19800101"))
Endif

//Verifica parametros contabilizacao
lRet := CTBINTRAN(1,.F.)

If lRet
	//AVP e AVP Parcela implantados
	If !lAvpAtf2
		lRet := .F.
	//Tentativa de cancelar processo ja cancelado
	ElseIf FNN->FNN_STATUS != "1"
		Help(" ",1,"AF460CAN01",,STR0022,1,0)	//"Este processo já se encontra cancelado."
	lRet := .F.
	//Tentativa de cancelar processo gerado em data posterior a database
	ElseIf FNN->FNN_DTPROC > dDataBase
		Help(" ",1,"AF460CAN02",,STR0023,1,0)	//"Este processo foi efetuado em data posterior a database do sistema."
	lRet := .F.
	//Tentativa de cancelar processo gerado em data posterior a data da ultima depreciacao
	ElseIf FNN->FNN_DTPROC > dUltDepr
		Help(" ",1,"AF460CAN02",,STR0024 +CRLF+ STR0008 + Dtoc(dUltDepr),1,0) 	//"Esta rotina somente deverá ser executada na mesma database do último cálculo mensal. "###"Ultimo calculo em :"
	lRet := .F.
EndIf
Endif

If lRet
	//Verifica se eh o ultimo processo efetuado e ativo
  	cAliasQry := GetNextAlias()
	cQuery := " SELECT "
	cQuery += " 	MAX(FNN_IDPROC) FNNMAXPROC  "
	cQuery += " FROM "  + RetSQLTab("FNN")
	cQuery += " WHERE FNN_STATUS = '1' AND "
	cQuery += RetSqlCond("FNN")

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )

   If FNN->FNN_IDPROC < (cAliasQry)->FNNMAXPROC
		Help(" ",1,"AF460NOLAST",,STR0025,1,0)		//"Existem processos posteriorea ao processo que está se tentando cancelar. Por segurança, os processos devem ser cancelados do mais atual para o mais antigo."
		lRet := .F.
	Endif

	dbSelectArea(cAliasQry)
	dbCloseArea()

	dbSelectArea("FNN")

Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF460EstPrv ºAutor ³Mauricio Pequim Jr. º Data ³  18/11/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o cancelamento de um determinado processo de        º±±
±±º          ³apuracao de AVP Parcela                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA460                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460EstPrv(aRecFNO,nPosRec,lAutoApr)

Local aArea		:= GetArea()
Local aDetalhe	:= {}
Local nX	  		:= 0
Local cCBase	:= ""
Local cItem		:= ""
Local cIdCV8	:= ""
Local cProc		:= __cProcPrinc + "DEL"
Local cMensIni	:= STR0026	//"Estorno Constituição de AVP por parcela de depreciação"
Local lRet		:= .T.

DEFAULT aRecFNO := {}
DEFAULT nPosRec := 0
DEFAULT lAutoApr := .F.

DbSelectArea("FNO")

If !lAutoApr
	ProcLogIni( {},cProc,,@cIdCV8 )
	ProcLogAtu( "INICIO" , cMensIni,,,.T. )
Endif

BEGIN TRANSACTION

	For nX := 1 to Len(aRecFNO)

		FNO->(dbGoto(aRecFNO[nX][nPosRec]))

		//Obtenho os dados do imobilizado a ser cancelado
		cCbase := FNO->FNO_CBASE
		cItem  := FNO->FNO_ITEM

		//Efetue a exclusão do imobilizado e registros associados
		//Posiciono na Ficha do ativo
		SN1->(dbSetOrder(1))
		SN1->(MsSeek(xFilial("SN1")+cCBase+cItem))

		SN3->(dbSetOrder(11))
		SN3->(MsSeek(xFilial("SN3")+cCBase+cItem))

		If !F460DelPrv(cCBase,cItem,aDetalhe,lAutoApr)
			lRet := .F.
		Else
			//Atualizo o flag do processo (Detalhes)
			RecLock("FNO",.F.,.T.)
			If !lAutoApr  //Caso nao seja rotina automatizada (acesso externo)
				FNO->FNO_STATUS := '2'
			Else
				FNO->(dbDelete())
				Endif
				MsUnlock()

		Endif
   Next

	If lRet .and. !lAutoApr
		//Atualizo o registro da tabela de processos (FNN)
		RecLock("FNN")
		FNN->FNN_STATUS := "2"
		FNN->(MsUnlock())

		If !lAutoApr
			ProcLogAtu( "MENSAGEM",  STR0014 ,,,.T. )	//"Processo concluido sem ocorrências"
		Endif
	Else
		If !lAutoApr
			ProcLogAtu( IIF(Empty(aDetalhe[2]),"MENSAGEM","ERRO"), aDetalhe[1] ,aDetalhe[2],,.F. )
	Endif
	EndIf

END TRANSACTION

If !lAutoApr
	ProcLogAtu( "FIM" ,,,,.T.)
	ProcLogView(cFilAnt,cProc,,cIdCV8)
Endif

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF460Head ºAutor  ³Mauricio Pequim Jr  º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aHeader da getdados dos movimentos de apropriacao  º±±
±±º          ³ do processo a ser cancelado                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA460                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF460Head()

Local aHeadAVP	:= {}
Local aCpos	  	:= {}
Local nX		  	:= 0
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local nTamCpo	:= SX3->(Len(X3_CAMPO))

aAdd(aCpos,'FNO_FILIAL')
aAdd(aCpos,'FNO_CBASE')
aAdd(aCpos,'FNO_ITEM')
aAdd(aCpos,'FNO_BASESP')
aAdd(aCpos,'FNO_ITEMSP')


SX3->(dbSetOrder(2)) //X3_CAMPO
For nX := 1 to Len(aCpos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If SX3->(MsSeek( Padr(aCpos[nX],nTamCpo )))
		IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL

			cUsado := SX3->X3_USADO
			//Transformo em string o conteudo de SX3->X3_CBOX
			//Este tratamento eh feito pois a MsNewGetDados nao trata como combo
			// se SX3->X3_CBOX for igual a #Function()
			cCombo := SX3->X3_CBOX
			If Substr(cCombo,1,1) == "#"
				cCombo := &(Alltrim(Substr(cCombo,2)))
			Endif

			aAdd( aHeadAvp ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
   	   		           ,SX3->X3_PICTURE ,SX3->X3_TAMANHO ;
      	      		     ,SX3->X3_DECIMAL ,SX3->X3_VALID ;
		   	              ,SX3->X3_USADO ,SX3->X3_TIPO ;
      			           ,SX3->X3_F3 ,SX3->X3_CONTEXT ;
            			     ,cCombo ,SX3->X3_RELACAO})
		EndIf
	EndIf
Next

RestArea( aAreaSX3 )
RestArea( aArea )

Return aHeadAVP


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF460aCol ºAutor  ³Mauricio Pequim Jr. º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aCols com os movimentos de apropriacoes do processoº±±
±±º          ³ a ser cancelado                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA460                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF460aCol(aHeader,cProcesso)

Local nX					:= 0
Local nCols		      := 0
Local aArea		  		:= GetArea()
Local aCols				:= {}

DEFAULT aHeader 	:= {}
DEFAULT cProcesso := ""


FNO->(dbSetOrder(1)) //FNO_FILIAL+FNO_IDPROC
If FNO->(MsSeek(xFilial("FNO") + cProcesso ))
	While FNO->(!Eof()) .And. FNO->(FNO_FILIAL+FNO_IDPROC) == xFilial("FNO") + cProcesso
		aAdd(aCols,Array(Len(aHeader)+2))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := FNO->(FieldGet(FieldPos(aHeader[nX][2])))
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+2] := .F.
		aCols[nCols][Len(aHeader)+1] := FNO->(RECNO())

		FNO->(dbSkip())
	Enddo
EndIf
RestArea(aArea)

Return aCols


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³24/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados            ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Private aRotina := {{ STR0027 ,"AxPesqui"  , 0, 1 , ,.F.},;		//"Pesquisar"
                    { STR0028 ,"AxVisual"  , 0, 2		},;		//"Visualizar"
					{ STR0029 ,"AF460Inc"  , 3, 3		},;		//"Apuração"
					{ STR0030 ,"AF460Can"  , 5, 5		},;		//"Cancelar"
					{ STR0031 ,"AF460Leg"  , 4, 2		} }		//"Legenda"


Return(aRotina)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF460Leg  ³Autor  ³ Mauricio Pequim Jr.   ³ Data ³03.05.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF460Leg(lRetCor)
Local aRet		:= {}
Local aCores 	:= {	{"BR_VERDE"		,"FNN_STATUS == '1'", STR0032 },;		//"Apuração Realizada"
						{"BR_VERMELHO"	,"FNN_STATUS == '2'", STR0033 }}		//"Apuração Cancelada"


DEFAULT lRetCor := .F.
If ValType(lRetCor) <> 'L'
	lRetCor := .F.
EndIf

If lRetCor
	aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } )
Else
	aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } )
	BrwLegenda(cCadastro,STR0031,aRet)			//"Legenda"
	aRet := Nil
EndIf

Return(aRet)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F460DelPrv³Autor  ³ Mauricio Pequim Jr.   ³ Data ³03.05.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function F460DelPrv(cCBase,cItem,aDetalhe,lAutoApr)

Local aArea := GetArea()
Local aCab := {}
Local aItens := {}
Local aParam := {}
Local nY := 0
Local lRet := .T.
Local aLog		:= {}

DEFAULT lAutoApr := .F.

//Controle de rotina automatica
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := If(lAutoApr,.F.,.T.)

aAdd( aParam, {"MV_PAR01", 2} )
aAdd( aParam, {"MV_PAR02", 1} )
aAdd( aParam, {"MV_PAR03", 2} )

AAdd(aCab,{"N1_CBASE"  	, cCBase			,NIL})
AAdd(aCab,{"N1_ITEM"   	, cItem				,NIL})

MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)},aCab,aItens,5,aParam)

If lMsErroAuto
	If lAutoApr
		lMsErroAuto := .F.
		DisarmTransaction()
		lRet := .F.

		cFileLog := NomeAutoLog()
		cPath := ""
		If !Empty(cFileLog) .And. !lRet
			MostraErro(cPath,cFileLog)
		Endif
	Else
		aLog := GETAUTOGRLOG()
		lMsErroAuto := .F.
		DisarmTransaction()
		lRet := .F.

		cDetalhe := ""
		For nY := 1 to Len(aLog)
			cDetalhe += aLog[nY]
		Next nY

		aadd(aDetalhe,STR0015 +cCBase+ STR0016 + cItem )		//"Falha ao processar Imobilizado Código Base: "###" Item: "
		aadd(aDetalhe, cDetalhe )
	Endif
EndIf

RestArea(aArea)

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460AVPMAN³Autor  ³ Alvaro Camillo Neto   ³ Data ³22.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Retorna o AVP Manual incluido pela rotina automatica
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A460AVPMAN(aAVPMan,cTipo,cTipoSLD)
Local aRet       := {0,0}
Local nPosAVP    := 0
Local nPosTipo   := 0
Local nPosTipSld := 0
Local nX         := 0
Local aAux       := {}

Default cTipoSLD := ""
Default cTipo    := ""
Default aAVPMan  := {}

For nX := 1 to Len(aAVPMan)
	aAux       := aAVPMan[nX]
	nPosTipo   := ascan(aAux,{|x| Alltrim(x[1]) == 'N3_TIPO'})
	nPosTipSld := ascan(aAux,{|x| Alltrim(x[1]) == 'N3_TPSALDO'})
	nPosAVP    := ascan(aAux,{|x| Alltrim(x[1]) == 'N3AVPPLAN'})
	nPosAVPRZ  := ascan(aAux,{|x| Alltrim(x[1]) == 'N3AVPREAL'})
	If nPosTipo > 0 .And. nPosTipSld > 0
		If Alltrim(aAux[nPosTipo][2]) == Alltrim(cTipo) .And. Alltrim(aAux[nPosTipSld][2]) == Alltrim(cTipoSLD)
			If nPosAVP > 0
				aRet[1] := aAux[nPosAVP][2]
			EndIf
			If nPosAVPRZ > 0
				aRet[2] := aAux[nPosAVPRZ][2]
			EndIf
		EndIf
	EndIf

Next nX


Return aRet
