#INCLUDE "CTBR500.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE C_CONTA			1
#DEFINE C_DESC			2
#DEFINE C_SITNORMAL		3
#DEFINE C_NIVEL    		4
#DEFINE C_IDENTIFI		5

#DEFINE C_SALDOS  		5
#DEFINE C_SALDOSEM		6
#DEFINE C_SALDOATU		7
#DEFINE C_SALDOANT		8

#DEFINE C_TOTAL   		9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr500	³ Autor ³ Wagner Mobile Costa	³ Data ³ 08.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demostrativo de balancos patrimoniais  		 		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR500A()
Private aSelFil	 	:= {}

If TRepInUse()
	CTBR500AR4()
	//Limpa os arquivos temporários
	CTBGerClean()
Else
	MsgAlert(STR0020,"")	// "Funcion disponible solo para TReport, verificar parametro MV_TREPORT."
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR500R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 14/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demostrativo de balancos patrimoniais - R4		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR115R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTBR500AR4()
Local aSetOfBook
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.

Private CPERG	   	:= "CTR500"
Private nomeprog	:= "CTBR500A"
Private aSelFil		:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! CtrVld500(cPerg)
	Return
EndIf

// Faz a validacao das filiais
If lRet .And. mv_par14 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// faz a validação do livro
If ! Empty( mv_par02 )
	If ! VdSetOfBook( mv_par02 , .F. )
		lRet := .F.
	EndIf
EndIf

If lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par02)
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03, aSetOfBook[9])
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf

	cDescMoeda 	:= AllTrim(aCtbMoeda[3])
	oReport := ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)
	oReport :PrintDialog()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 15/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)
Local cREPORT		:= "CTBR500A"
Local cTITULO		:= Capital(STR0001)		// BALANCOS PATRIMONIAIS
Local cDESC			:= STR0016 + STR0017
Local aTamDesc		:= TAMSX3("CTS_DESCCG")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 10
Local dFinal 		:= CtoD(Space(8))

cTitulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo )		// Titulo definido SetOfBook
If Valtype(mv_par13)=="N" .And. (mv_par13 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

//Filtra Filiais
If mv_par14 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf

If Empty(MV_PAR09)
	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dFinal	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo
Else
	dFinal:= MV_PAR09
EndIf

nAno := Year(dFinal)

If mv_par04 = 1
	cTitCol := STR0010
Else
	cTitCol	:= Dtoc(dFinal)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dFinal), .T., oReport:CancelPrint())}, CDESC)
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )
oReport:SetLandScape(.T.)
oReport:ParamReadOnly()

If GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
EndIf

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1  := TRSection():New( oReport, STR0018, {"cArqTmp"},, .F., .F. )      // "Detalhe"

// Colunas referentes ao Ativo
TRCell():New( oSection1, "ATIVO"     , ,STR0007+cDescMoeda+")"  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "ASEMESTRE" , ,STR(nAno)+CRLF+STR0008  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")
TRCell():New( oSection1, "AEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")
TRCell():New( oSection1, "AEXERANT"  , ,STR(nAno-1)+CRLF+STR0010/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")
// Colunas referentes ao Passivo
TRCell():New( oSection1, "PASSIVO"   , ,StrTran(STR0009, "+ ", "+"+CRLF)+cDescMoeda+")"  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,,,5)
TRCell():New( oSection1, "PSEMESTRE" , ,STR(nAno)+CRLF+STR0008  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")
TRCell():New( oSection1, "PEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")
TRCell():New( oSection1, "PEXERANT"  , ,STR(nAno-1)+CRLF+STR0010/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")

oSection1:SetTotalInLine(.F.)
//oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDatabase,cTitulo,,,,,oReport) } )

/* GESTAO - inicio */
/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL",,"Código",/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"EMPRESA",,"Empresa",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"UNIDNEG",,"Unidade de negócio",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"NOMEFIL",,"Filial",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
/* GESTAO - fim */
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius    ³ Data ³ 15/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(ExpO1,ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Obj. do relatorio	                              ³±±
±±³          ³ ExpC1 = Titulo do relatorio (sera' atualizado conf. param.)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatorio                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport,Titulo, dFinal )
Local oSection1 	:= oReport:Section(1)
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aColunas		:= { {}, {} }
Local aMaxCol		:= {	{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 },;
							{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 } }
Local nMaxCol 		:= 0
Local nPosCol		:= 0
Local nColuna		:= 0
Local nCelula		:= 0
Local lSemestre
Local lPeriodoAnt 	:= (mv_par10 == 1)
Local aPosCol
Local lColuna		:= .F.
Local cTpValor		:= GetMV("MV_TPVALOR")
Local lImpTrmAux	:= (mv_par06 == 1)
Local cArqTrm		:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= mv_par11 // RFC - 22/01/07 - BOPS 103653
Local nTamEmp		:= 0
Local nTamUnNeg		:= 0
Local nTamTit		:= 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local oSecFil		:= oReport:Section("SECFIL")
Local aSM0			:= {}
Local nX
Local lCharSinal	:= .F.
Local lAutomato   := FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR500"

oReport:SetPageNumber( MV_PAR05 )

If  Empty(CTBSetOf(mv_par02)[5])
	ApMsgAlert(	STR0012) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

/* imprime a lista de filiais selecionadas para o relatorio */
If Len(aSelFil) > 1
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + "Filiais selecionadas para o relatorio" + ")")
	nTamTit := Len(oReport:Title())
	oSecFil:Init()
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

	For nX := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nX]})
		If nLinha > 0
			cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
			oSecFil:PrintLine()
		Endif
	Next
	oReport:SetTitle(cTitulo)
	oSecFil:Finish()
	oReport:EndPage()
Endif
/* GESTAO - fim */

If mv_par04 = 1 .And. Month(dFinal) > 6
	dSemestre := Ctod("30/06/" + Str(Year(dFinal), 4))
Endif

If !lPeriodoAnt
	dFinalA := dFinal-1
ElseIf  Substr(dtoc(dFinal),1,5) == "29/02" // Validacao para anos bissextos
	dFinalA := Ctod("28/02/" + Str(Year(dFinal) - 1, 4))
Else
	dFinalA := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
Endif

lSemestre	:= mv_par04 = 1 .And. Month(dFinal) > 6
aPosCol		:= {	{  175, If(lSemestre, 740 ,), 1050, If(lPeriodoAnt,1370,), 1630 },;
					{ 1695, If(lSemestre, 2220,), 2540, If(lPeriodoAnt,2860,), 3120 }	}
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]
lComNivel	:= .T.
m_pag := mv_par05

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		   				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		   				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
		   				MV_PAR12,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		   				,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)},;
			STR0006, Titulo) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")
dbGoTop()
lColuna	:= FieldPos("COLUNA") > 0

While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³indica se a entidade gerencial sera impressa/visualizada em ³
	//³um relatorio ou consulta apos o processamento da visao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf

	If lColuna
		If cArqTmp->COLUNA < 2
			nColuna := 1
		Else
			nColuna := 2
		EndIf
	Else
		nColuna := 1
	EndIf

	If cArqTmp->IDENTIFI = "4"
		aMaxCol[nColuna][C_CONTA] 		:= cArqTmp->CONTA
		aMaxCol[nColuna][C_DESC] 		:= cArqTmp->DESCCTA
		aMaxCol[nColuna][C_SITNORMAL]	:= cArqTmp->NORMAL
		aMaxCol[nColuna][C_NIVEL]		:= cArqTmp->NIVEL
		aMaxCol[nColuna][C_IDENTIFI]	:= "4"
		aMaxCol[nColuna][C_SALDOANT] 	+= cArqTmp->SALDOANT
		aMaxCol[nColuna][C_SALDOATU] 	+= cArqTmp->SALDOATU
		If lSemestre
			aMaxCol[nColuna][C_SALDOSEM] += cArqTmp->SALDOSEM
		EndIf
	Else
		Aadd(aColunas[nColuna], { 	cArqTmp->CONTA, cArqTmp->DESCCTA, cArqTmp->NORMAL, cArqTmp->NIVEL, cArqTmp->IDENTIFI,;
									If(lSemestre, cArqTmp->SALDOSEM, 0), cArqTmp->SALDOATU, cArqTmp->SALDOANT })
		aMaxCol[nColuna][C_TOTAL] ++
	EndIf

	DbSkip()
EndDo

If aMaxCol[1][C_TOTAL] > aMaxCol[2][C_TOTAL]
	nMaxCol := aMaxCol[1][C_TOTAL]
Else
	nMaxCol := aMaxCol[2][C_TOTAL]
EndIf

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()

If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf

dbselectArea("CT2")
nCol1Pos	:= 0
nCol2Pos	:= 0

If  ! lSemestre
	oSection1:Cell("ASEMESTRE"):Disable()
	oSection1:Cell("PSEMESTRE"):Disable()
EndIf

If  ! lPeriodoAnt
	oSection1:Cell("AEXERANT"):Disable()
	oSection1:Cell("PEXERANT"):Disable()
Else
	If  ! lSemestre
		oSection1:Cell("AEXERANT"):SetTitle(DTOC(dFinalA))
		oSection1:Cell("PEXERANT"):SetTitle(DTOC(dFinalA))
	EndIf
EndIf

If  ! lSemestre
	oSection1:Cell("AEXERCICIO"):SetTitle(DTOC(dFinal))
	oSection1:Cell("PEXERCICIO"):SetTitle(DTOC(dFinal))
EndIf

oSection1:Init()
aTamVal[1] += 8

For nColuna := 1 To nMaxCol
	nCol1Pos++
	nCol2Pos++

	If nCol1Pos > Len(aColunas[1]) .and. nCol2Pos > Len(aColunas[2])
		Exit
	EndIf

	If 	(nColuna <= Len(aColunas[1]) .And. aColunas[1][nColuna][C_DESC] = "-") .Or.;
		(nColuna <= Len(aColunas[2]) .And. aColunas[2][nColuna][C_DESC] = "-")
		oReport:ThinLine()

	Else
		If mv_par08 <> 1				/// Se Imprime Valor Zerado = Não
			/// LOCALIZA A PROXIMA LINHA COM VALOR NA COLUNA 1
		 	While nCol1Pos <= Len(aColunas[1]) .and. (aColunas[1][nCol1Pos][C_SALDOS + 2] == 0 .And. aColunas[1][nCol1Pos][C_SALDOS + 3] == 0)
				If aColunas[1][nCol1Pos][C_IDENTIFI] < "5"
					If aColunas[1][nCol1Pos][C_SALDOS + 2] <> 0 .OR. aColunas[1][nCol1Pos][C_NIVEL]==1				/// SE O SALDO ATUAL NAO ESTIVER ZERADO OU FOR SINTETICA
						Exit
					EndIf
				EndIf
				nCol1Pos++
			EndDo

			/// LOCALIZA A PROXIMA LINHA COM VALOR NA COLUNA 2
			While nCol2Pos <= Len(aColunas[2]) .and. (aColunas[2][nCol2Pos][C_SALDOS + 2] == 0 .And. aColunas[2][nCol2Pos][C_SALDOS + 3] == 0)
				If aColunas[2][nCol2Pos][C_IDENTIFI] < "5"
					If aColunas[2][nCol2Pos][C_SALDOS + 2] <> 0  .OR. aColunas[2][nCol2Pos][C_NIVEL]==1 				/// SE O SALDO ATUAL NAO ESTIVER ZERADO
						Exit
					EndIf
				EndIf
			  	nCol2Pos++
			EndDo
		EndIf

// 1. Coluna
		If nCol1Pos <= Len(aColunas[1])
			oSection1:Cell("ATIVO"):SetBlock( { || aColunas[1][nCol1Pos][C_DESC] } )

			If aColunas[1][nCol1Pos][C_IDENTIFI] < "5"

				For nPosCol := 2 To Len(aPosCol[1]) - 1
					If aPosCol[1][nPosCol] # Nil
						nCelula := ( C_SALDOS + nPosCol - 1 )

						If nCelula == 6 .And. lSemestre
							oSection1:Cell("ASEMESTRE")		:SetBlock( { || ValorCTB( aColunas[1][nCol1Pos][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
       												                        aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
						ElseIf nCelula == 7
							oSection1:Cell("AEXERCICIO")	:SetBlock( { || ValorCTB( aColunas[1][nCol1Pos][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
       																		aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
						ElseIf nCelula == 8 .And. lPeriodoAnt
							oSection1:Cell("AEXERANT")		:SetBlock( { || ValorCTB( aColunas[1][nCol1Pos][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
       												                        aColunas[1][nCol1Pos][C_SITNORMAL],aColunas[1][nCol1Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
						EndIf
					EndIf
				Next
			//Somente para Linha Sem Valor
			ElseIf aColunas[1][nCol1Pos][C_IDENTIFI] == "5"
				For nPosCol := 2 To Len(aPosCol[1]) - 1
					If aPosCol[1][nPosCol] # Nil
						nCelula := ( C_SALDOS + nPosCol - 1 )

						If nCelula == 6 .And. lSemestre
							oSection1:Cell("ASEMESTRE") :SetBlock( { || " " } )
						ElseIf nCelula == 7
							oSection1:Cell("AEXERCICIO"):SetBlock( { || " " } )
						ElseIf nCelula == 8 .And. lPeriodoAnt
							oSection1:Cell("AEXERANT")  :SetBlock( { || " " } )
						EndIf
					EndIf
				Next

			EndIf
		EndIf

// 2. Coluna
		If nCol2Pos <= Len(aColunas[2])
			oSection1:Cell("PASSIVO"):SetBlock( { || aColunas[2][nCol2Pos][C_DESC] } )

			If aColunas[2][nCol2Pos][C_IDENTIFI] < "5"

				For nPosCol := 2 To Len(aPosCol[1]) - 1

					If aPosCol[2][nPosCol] # Nil
						nCelula := ( C_SALDOS + nPosCol - 1 )

						If nCelula == 6 .And. lSemestre
							oSection1:Cell("PSEMESTRE"):SetBlock( { || ValorCTB( aColunas[2][nCol2Pos][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
						                          aColunas[2][nCol2Pos][C_SITNORMAL],aColunas[2][nCol2Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )

						ElseIf nCelula == 7
							oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aColunas[2][nCol2Pos][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
						                          aColunas[2][nCol2Pos][C_SITNORMAL],aColunas[2][nCol2Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )

						ElseIf nCelula == 8 .And. lPeriodoAnt
							oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aColunas[2][nCol2Pos][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
						                          aColunas[2][nCol2Pos][C_SITNORMAL],aColunas[2][nCol2Pos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
						EndIf
					EndIf

				Next

			ElseIf aColunas[2][nCol2Pos][C_IDENTIFI] == "5"

				For nPosCol := 2 To Len(aPosCol[1]) - 1

					If aPosCol[2][nPosCol] # Nil
						nCelula := ( C_SALDOS + nPosCol - 1 )

						If nCelula == 6 .And. lSemestre
							oSection1:Cell("PSEMESTRE") :SetBlock( { || " " } )
						ElseIf nCelula == 7
							oSection1:Cell("PEXERCICIO"):SetBlock( { || " " } )
						ElseIf nCelula == 8 .And. lPeriodoAnt
							oSection1:Cell("PEXERANT")  :SetBlock( { || " " } )
						EndIf
					EndIf
				Next
			EndIf
		EndIf

		If nCol1Pos > Len( aColunas[1] )
			oSection1:Cell("ATIVO"     ):SetBlock( {|| ""} )
			oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )
            If lSemestre
				oSection1:Cell("ASEMESTRE" ):SetBlock( {|| ""} )
			EndIf
	        If lPeriodoAnt
				oSection1:Cell("AEXERANT"  ):SetBlock( {|| ""} )
			EndIf
		EndIf

		If nCol2Pos > Len( aColunas[2] )
			oSection1:Cell("PASSIVO"   ):SetBlock( {|| ""} )
			oSection1:Cell("PEXERCICIO"):SetBlock( {|| ""} )
            If lSemestre
				oSection1:Cell("PSEMESTRE" ):SetBlock( {|| ""} )
			EndIf
	        If lPeriodoAnt
				oSection1:Cell("PEXERANT"  ):SetBlock( {|| ""} )
			EndIf
		EndIf

		oSection1:PrintLine()

	EndIf
Next

oReport:ThinLine()

// 1 Coluna
oSection1:Cell("ATIVO"):SetBlock( { || aMaxCol[1][C_DESC] } )
nColuna2 := 2

For nPosCol := 2 To Len(aPosCol[1])
	nCelula := (C_SALDOS + nPosCol - 1)

	If ( aPosCol[1][nPosCol] <> Nil ) .And. ( nCelula < Len(aMaxCol[1]) )
		If nCelula == 6 .And. lSemestre
			oSection1:Cell("ASEMESTRE"):SetBlock( { || ValorCTB( aMaxCol[1][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
                                		                         aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		ElseIf nCelula == 7
			oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aMaxCol[1][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
                                		                         aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		ElseIf nCelula == 8 .And. lPeriodoAnt
			oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aMaxCol[1][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
                                		                         aMaxCol[1][C_SITNORMAL],aMaxCol[1][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf
	EndIf
Next

// 2 Coluna
oSection1:Cell("PASSIVO"):SetBlock( { || aMaxCol[2][C_DESC] } )

For nPosCol := 2 To Len(aPosCol[2])
	nCelula := (C_SALDOS + nPosCol - 1)

	If ( aPosCol[2][nPosCol] <> Nil ) .And. ( nCelula < Len(aMaxCol[2]) )
		If nCelula == 6 .And. lSemestre
			oSection1:Cell("PSEMESTRE"):SetBlock( { || ValorCTB( aMaxCol[2][6],,,aTamVal[1],nDecimais,.T.,cPicture,;
		                          aMaxCol[2][C_SITNORMAL],aMaxCol[2][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		ElseIf nCelula == 7
			oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aMaxCol[2][7],,,aTamVal[1],nDecimais,.T.,cPicture,;
		                          aMaxCol[2][C_SITNORMAL],aMaxCol[2][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		ElseIf nCelula == 8 .And. lPeriodoAnt
			oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aMaxCol[2][8],,,aTamVal[1],nDecimais,.T.,cPicture,;
		                          aMaxCol[2][C_SITNORMAL],aMaxCol[2][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf
	EndIf
Next

If Len( aPosCol[1] ) > Len( aPosCol[2] )
	oSection1:Cell("PASSIVO"   ):SetBlock( {|| ""} )
	oSection1:Cell("PEXERCICIO"):SetBlock( {|| ""} )
	If lSemestre
		oSection1:Cell("PSEMESTRE" ):SetBlock( {|| ""} )
	EndIf
	If lPeriodoAnt
		oSection1:Cell("PEXERANT"  ):SetBlock( {|| ""} )
	EndIf

ElseIf Len( aPosCol[2] ) > Len( aPosCol[1] )
	oSection1:Cell("ATIVO"     ):SetBlock( {|| ""} )
	oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )
	If lSemestre
		oSection1:Cell("ASEMESTRE" ):SetBlock( {|| ""} )
	EndIf
	If lPeriodoAnt
		oSection1:Cell("AEXERANT"  ):SetBlock( {|| ""} )
	EndIf

EndIf

oSection1:PrintLine()
oReport:ThinLine()
oSection1:Finish()

If !lAutomato
	If IsBlind() .OR. ( lImpTrmAux .And. MsgYesNo(STR0019, Capital(STR0001)) )  //"Imprime Termo na Proxima Pagina ?"
		oReport:EndPage()
	EndIf

	If lImpTrmAux
		cArqTRM 	:= mv_par07
		aVariaveis	:= {}

		// Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
    	SX1->( dbSeek( padr( "CTR500" , Len( X1_GRUPO ) , ' ' ) + "01" ) )

		Do While SX1->X1_GRUPO == padr( "CTR500" , Len( SX1->X1_GRUPO ) , ' ' )
			AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
			SX1->( dbSkip() )
		Enddo

		If !File(cArqTRM)
			aSavSet:=__SetSets()
			cArqTRM := CFGX024(cArqTRM,STR0013) // "Responsáveis..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		EndIf

		If cArqTRM # NIL
			ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
		EndIf
	EndIf
EndIf

If MV_PAR15 == 1
	Processa({|| GerArq(AllTrim(MV_PAR16),dFinal,aColunas,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)},,STR0023)
EndIf

oReport:EndPage()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³ A Rodriguez         ³ Data ³ 20.02.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 3.1 LIBRO DE INVENTARIOS Y BALANCES                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru                  - Arquivo Magnetico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir, dFinal, aColunas, aTamVal, nDecimais, cPicture, cTpValor, lCharSinal)

Local nHdl		:= 0
Local cLin		:= ""
Local cSep		:= "|"
Local cArq		:= ""
Local nColuna	:= 0
Local nColPos	:= 0
Local cValor	:= ""

If !(Right(cDir,1) == "\")
	cDir += "\"
EndIf

cArq += "LE"					// Fixo  'LE'
cArq +=  AllTrim(SM0->M0_CGC)	// Ruc
cArq +=  DtoS(dFinal)			// Fecha AAAAMMDD
cArq +=  "030100"				// Id Libro

If Month(dFinal) == 12		// Oportunidad de presentación
	cArq += "01"
ElseIf Month(dFinal) == 1
	cArq += "02"
ElseIf Month(dFinal) == 6
	cArq += "04"
Else
	cArq += "07"
EndIf

cArq += "1"						// I. Operaciones
cArq += "1"						// I. de contenido del libro/registro
cArq += "1"						// Moneda (soles)
cArq += "1"						// Generado por PLE
cArq += ".TXT"					// Extensao

nHdl := fCreate(cDir+cArq)

If nHdl <= 0
	ApMsgStop(STR0021)
	Return Nil
EndIf

For nColuna := 1 to 2

	For nColPos := 1 To Len(aColunas[nColuna])

		If Alltrim(aColunas[nColuna][nColPos][C_DESC]) == "-"
			Loop
		EndIf

		If mv_par08 <> 1				// Se Imprime Valor Zerado = Não
			If ! (aColunas[nColuna][nColPos][C_IDENTIFI] < "5" .And. (aColunas[nColuna][nColPos][C_SALDOS + 2] <> 0 .Or. aColunas[nColuna][nCol1Pos][C_NIVEL]==1))
				Loop
			EndIf
			// SE O SALDO ATUAL NAO ESTIVER ZERADO OU FOR SINTETICA
		EndIf

		If aColunas[nColuna][nColPos][C_IDENTIFI] == "5"
			Loop
		EndIf

		cLin := ""

		//01 - Periodo
		cLin += DtoS(dFinal)
		cLin += cSep

		//02 - Código de catálogo
		cLin += "09"
		cLin += cSep

		//03 - Código del rubro del estado financiero
		cLin += Trim(aColunas[nColuna][nColPos][C_CONTA])
		cLin += cSep

		//04 - Saldo
		cValor := ValorCTB( aColunas[nColuna][nColPos][7],,,15,2,.T.,"@E 999999999999.99",aColunas[nColuna][nColPos][C_SITNORMAL],aColunas[nColuna][nColPos][C_CONTA],,,cTpValor,,,.F.,,lCharSinal)
		cLin += lTrim(cValor) + cSep

		//05 - Estado operación
		cLin += "1"
		cLin += cSep

		cLin += CRLF
		fWrite(nHdl,cLin)

	Next nColPos

Next nColuna

fClose(nHdl)
MsgAlert(STR0022,"")

Return Nil
