#INCLUDE "CTBR500.CH"
#INCLUDE "PROTHEUS.CH"
 
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
Function CtbR500()
Private aSelFil	 	:= {}
If TRepInUse() 
	CTBR500R4()
Else
	Return CTBR500R3()
EndIf

//Limpa os arquivos temporários 
CTBGerClean()

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
Function CTBR500R4()                           
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.

PRIVATE CPERG	   	:= "CTR500" 
Private nomeprog	:= "CTBR500"       
Private aSelFil		:={} 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
If ! CtrVld500(cPerg)
	Return
Endif
// Faz a validacao das filiais
If lRet .And. mv_par14 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// faz a validação do livro
if ! Empty( mv_par02 ) 
	if ! VdSetOfBook( mv_par02 , .F. )
		lRet := .F.
	endif
Endif

IF lRet
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
local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR500"
Local cTITULO		:= Capital(STR0001)		// BALANCOS PATRIMONIAIS
Local cDESC			:= STR0016 + STR0017
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 20
Local dFinal 		:= CTOD(SPACE(8))

// seta o livro / aCtbMoeda / Descr Moeda
Default aSetOfBook := CTBSetOf(mv_par02)
Default aCtbMoeda  := CtbMoeda(mv_par03, aSetOfBook[9])
Default cDescMoeda := AllTrim(aCtbMoeda[3])

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

nAno := year(dFinal)

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
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

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
TRCell():New( oSection1, "ATIVO"     , ,STR0007+cDescMoeda+")"  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.)
TRCell():New( oSection1, "ASEMESTRE" , ,STR(nAno)+CRLF+STR0008  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "AEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "AEXERANT"  , ,STR(nAno-1)+CRLF+STR0010/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
// Colunas referentes ao Passivo
TRCell():New( oSection1, "PASSIVO"   , ,StrTran(STR0009, "+ ", "+"+CRLF)+cDescMoeda+")"  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,5,.T.)
TRCell():New( oSection1, "PSEMESTRE" , ,STR(nAno)+CRLF+STR0008  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "PEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "PEXERANT"  , ,STR(nAno-1)+CRLF+STR0010/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)

oSection1:SetTotalInLine(.F.)

//oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDatabase,cTitulo,,,,,oReport) } )

/*
GESTAO - inicio */
/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL",,"Código",/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"EMPRESA",,"Empresa",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"UNIDNEG",,"Unidade de negócio",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"NOMEFIL",,"Filial",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)

If mv_par04==1
	oReport:DisableOrientation() 
EndIf

/* GESTAO - fim
*/             
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
±±³Parametros³ ExpO1 = Obj. do relatorio	                                ³±±
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
Local lin 			:= 2301
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

Local aDemJson := {}
Local lRelatorio := .T.
Local lArqJson   := .F.

Local cStr_Json := ""
Local cId := ""
Local cNivel := "" 
Local cDescricao := ""
Local cContaPai := ""
Local nValor1 := 0
Local nValor2 := 0
Local nTotVal1 := 0
Local nTotVal2 := 0
Local lIndividual := .T.
Local lImpVal12
Local cNmDemonst:= ""
Local nDivide	:= 1
Local lMVPAR17 	:= .F.
Local cFindSX1 	:= Padr("CTR500", Len(SX1->X1_GRUPO), " ")
Local cDt1	 	:= ""
Local cDt2	 	:= ""
Local nBloco  	:= 0

If cPaisLoc <> "PER"	
	SX1->(dbSetOrder(1))
	lMVPAR17 := SX1->(dbSeek(cFindSX1+"17"))

	//As perguntas 15 e 16 são exclusivas do PERU
	//em outros ambientes o mv_par17 ocupa o lugar do mv_par15
	If lMVPAR17 .And. ValType(mv_par15) == "N"
		nDivide := mv_par15
	Endif
EndIf

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
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_GRPEMP] = cEmpant .And. sm0[SM0_CODFIL] == aSelFil[nX]})
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
/* GESTAO - fim
*/  

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


//para verificar por quanto sera dividido e adicionar ao o titulo da moeda.
If nDivide == 2			// Divide por cem
	nDivide := 100
ElseIf nDivide == 3		// Divide por mil
	nDivide := 1000
ElseIf nDivide == 4		// Divide por milhao
	nDivide := 1000000
EndIf

aSetOfBook[9] := nDivide
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]
                                            
lComNivel	:= .T.

aDemJson := CTBDEMJSON()
lRelatorio := Empty(aDemJson) .OR. aDemJson[1] == 1 .OR. aDemJson[1] == 3
lArqJson   := !Empty(aDemJson) .And. ( aDemJson[1] == 2 .OR. aDemJson[1] == 3)

m_pag := mv_par05
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		   				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		   				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
		   				MV_PAR12,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		   				,,,,,,,nDivide,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)},;
			STR0006, Titulo) //"Criando Arquivo Temporario..."

If lRelatorio
	dbSelectArea("cArqTmp")
	dbGoTop()
	lColuna	:= FieldPos("COLUNA") > 0

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
			If COLUNA < 2
				nColuna := 1
			Else
				nColuna := 2
			Endif
		Else
			nColuna := 1
		Endif
		If IDENTIFI = "4"
			aMaxCol[nColuna][C_CONTA] 		:= CONTA
			aMaxCol[nColuna][C_DESC] 		:= DESCCTA
			aMaxCol[nColuna][C_SITNORMAL]	:= NORMAL
			aMaxCol[nColuna][C_NIVEL]		:= NIVEL
			aMaxCol[nColuna][C_IDENTIFI]	:= "4"
			aMaxCol[nColuna][C_SALDOANT] 	+= SALDOANT
			aMaxCol[nColuna][C_SALDOATU] 	+= SALDOATU
			If lSemestre
				aMaxCol[nColuna][C_SALDOSEM] += SALDOSEM
			Endif
		Else
			Aadd(aColunas[nColuna], { 	CONTA, DESCCTA, NORMAL, NIVEL, IDENTIFI,;
										If(lSemestre, SALDOSEM, 0), SALDOATU, SALDOANT })
			aMaxCol[nColuna][C_TOTAL] ++
		Endif
		DbSkip()
	EndDo

	If aMaxCol[1][C_TOTAL] > aMaxCol[2][C_TOTAL]
		nMaxCol := aMaxCol[1][C_TOTAL]
	Else
		nMaxCol := aMaxCol[2][C_TOTAL]
	Endif

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
		Endif

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
						Endif
					Endif
					nCol2Pos++
				EndDo
			Endif


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
						Endif
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
						Endif
					Next									
				Endif
			Endif


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
						Endif

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
						Endif
					Next
				Endif
			Endif

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

		Endif
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
		Endif                              
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
		Endif                              
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
		If IsBlind() .OR. ( lImpTrmAux .And. MsgYesNo(STR0019) )  //"Imprime Termo na Proxima Pagina ?"
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
			Endif

			If cArqTRM#NIL
				ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
			Endif	 
		Endif
	EndIf
	oReport:EndPage()
EndIf

If lArqJson
	dbSelectArea("cArqTmp")
	dbGoTop()
	
	If DateDiffMonth(dFinalA,dFinal) == 6 		
		cDt1 := "S"+Month2Str(dFinal)+Year2Str(dFinal)
		cDt2 := "S"+Month2Str(dFinalA)+Year2Str(dFinalA)
	Else
		cDt1 := "A"+Month2Str(dFinal)+Year2Str(dFinal)
		cDt2 := "A"+Month2Str(dFinalA)+Year2Str(dFinalA)
	EndIf

	lIndividual := ( aDemJson[5] == 1 )

	nBloco  := aDemJson[6]

	cNmDemonst := CTNmDemon(nBloco,aDemJson[5])

	If Empty(cNmDemonst)
		//atencao - nao colocar em STR000X pois se trata de legislacao e tem que ser exatamente como esta escrito
		cNmDemonst := "BalancoPatrimonial"
		nBloco := 0
	
		If !lIndividual
			//atencao - nao colocar em STR000X pois se trata de legislacao e tem que ser exatamente como esta escrito	
			cNmDemonst += "Consolidada"
		EndIf
	EndIf

	Pergunte( "CTR500", .F.)   //Garantir carga do pergunte antes de chamar funcao CtLstPerg()
	//geração de arquivo json no diretorio informado
	dbSelectArea("cArqTmp")
	oReport:SetMeter(RecCount())
	dbGoTop()
	//atencao - nao colocar em STR000X pois se trata de legislacao e tem que ser exatamente como esta escrito
	cStr_Json := ""
	cStr_Json += " {"+CRLF
	//----------------------------
	cStr_Json += '  "PergunteRel":{ "CTBR500": ['+CtLstPerg( "CTR500" )+'] }, '+CRLF
  	cStr_Json += '  "ParametrosJson": { '+CRLF
    cStr_Json += '  "PergunteJson": ['+CtLstPerg("CTBJSON", aDemJson )+'], '+CRLF
    cStr_Json += '  "DatasJson": [{"CTBR50'+cValToChar(nBloco)+'DT1":"'+cDt1+'"'
	
	If lPeriodoAnt
		cStr_Json += ' ,"CTBR50'+cValToChar(nBloco)+'DT2":"'+cDt2+'"}]'+CRLF
	Else
		cStr_Json += '}]'+CRLF
	EndIf

  	cStr_Json += '  }, '+CRLF
	//----------------------------
 	cStr_Json += ' "'+cNmDemonst+'": { '+CRLF
	If !Eof()
		cStr_Json += '"contas":[ '+CRLF
	EndIf
	
	While !Eof()

		cId := Alltrim( CONTA )
		cNivel := Alltrim( NIVJSON )
		cDescricao := Alltrim( DESCCTA )
		cContaPai := Alltrim( SUPERIOR )
		nValor1 := SALDOATU
		nValor2 := SALDOANT

		nTotVal1 += nValor1
		nTotVal2 += nValor2

		lImpVal12 := .F.

		If nValor1 <> 0 .OR. nValor2 <> 0 			
			lImpVal12 := .T.
			cStr_Json += '{ "@id":"'+cId+'", '+CRLF
			cStr_Json += '  "@nivel":"'+cNivel+'", '+CRLF
			cStr_Json += '  "@descricao":"'+cDescricao+'", '+CRLF
			cStr_Json += '  "@contaPai":"'+cContaPai+'", '+CRLF
			//atencao - nao colocar em STR000X pois se trata de legislacao e tem que ser exatamente como esta escrito
			If lIndividual
				cStr_Json += '"valoresIndividualizados":['+CRLF
			Else
				cStr_Json += '"valoresConsolidados":['+CRLF
			EndIf

			If nValor1 <> 0
				cStr_Json += '{ "@dtBase":"CTBR50'+cValToChar(nBloco)+'DT1", '
				cStr_Json += '  "@valor":'+Alltrim(Str(nValor1,16,2))+'} '
			EndIf

			If lPeriodoAnt .And. nValor2 <> 0

				If nValor1 <> 0
					cStr_Json += ', '+CRLF
				EndIf

				cStr_Json += '{ "@dtBase":"CTBR50'+cValToChar(nBloco)+'DT2", '
				cStr_Json += '  "@valor":'+Alltrim(Str(nValor2,16,2))+'} '
			EndIf

			cStr_Json += ' ]} '+CRLF

		EndIf

		oReport:IncMeter()

		dbSkip()

		If Eof()
			If Subs(cStr_Json, Len(cStr_Json), 1) == ","
				cStr_Json := Subs(cStr_Json, 1, Len(cStr_Json)-1 )
			EndIf
			cStr_Json += " ] "
		Else
			cStr_Json += If(lImpVal12, ',', '')
		EndIf

	EndDo
	
	cStr_Json += " } "

	cStr_Json += " } "+CRLF

	MemoWrite( aDemJson[4], cStr_Json)

EndIf

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

Return .T.

/*
-------------------------------------------------------- RELEASE 3 -------------------------------------------------------------
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr500R3³ Autor ³ Wagner Mobile Costa	³ Data ³ 08.10.01 ³±±
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
Function CtbR500R3()

Local titulo 		:= ""
Local lPeriodoAnt 	
Local aSetOfBook	

PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "CTR500"
PRIVATE nomeProg 	:= "CTBR500"
PRIVATE dFinal

If ! CtrVld500(cPerg)
	Return
Endif      
lPeriodoAnt 	:= (mv_par10 == 1) 
//Filtra Filiais
If mv_par14 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

aSetOfBook	:= CTBSetOf(mv_par02)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Exercicio contabil             		³
//³ mv_par02				// Configuracao de livros				³
//³ mv_par03				// Moeda?          			     	    ³
//³ mv_par04				// Demonstra semestre ?		    	    ³
//³ mv_par05				// Folha Inicial      ?		    	    ³
//³ mv_par06				// Imprime Arq. Termo Auxiliar?			³
//³ mv_par07				// Arq.Termo Auxiliar ?					³ 
//³ mv_par08				// Imprime Valor Zerado ?	    	    ³
//³ mv_par09				// Data Referencia    ?		    	    ³  
//³ mv_par10				// Dem. Periodo Anterior? Sim / Nao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(MV_PAR09)
	CTG->(dbSetOrder(1))
	If CTG->(dbSeek(xFilial("CTG")+mv_par01))
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		Help(" ",1,"NOEXISCALE")
		Return
	EndIf		
Else
	dFinal:= MV_PAR09
EndIf     

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

mv_par01    := dFinal
wnrel 		:= "CTBR500"            //Nome Default do relatorio em Disco
titulo 		:= STR0001 //"BALANCOS PATRIMONIAIS"
lComNivel	:= .T.

//aSetOfBook := CTBSetOf(mv_par02)

Titulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], Titulo )		// Titulo definido SetOfBook  
If (mv_par13 == 1)
	Titulo := CTBNomeVis( aSetOfBook[5] )
EndIf

MsgRun(	STR0002,"",; //"Gerando relatorio, aguarde..."
		{|| CursorWait(), Ctr500Cfg(@titulo, "Ctr500Det", STR0001) ,CursorArrow()}) //"Balancos Patrimoniais"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctr500Det ³ Autor ³ Simone Mie Sato       ³ Data ³ 28.06.01 ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhe do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr500Det(ExpO1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ParC1 = Titulo do relatorio                                ³±±
±±³          ³ ParC2 = Titulo da caixa do processo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctr500Det(oPrint,i,titulo, cProcesso)

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local lin 			:= 2301
Local cArqTmp

Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local aColunas		:= { {}, {} }
Local aMaxCol		:= { 	{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 },;
							{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 } }
Local nMaxCol 		:= 0
Local lSemestre		:= mv_par04 == 1 .And. Month(dFinal) > 6
Local lPeriodoAnt   := (mv_par10 == 1)

Local aPosCol		:= {}  //array com 2 elementos com coordenadas para ativo e passivo
Local nPosCol

Local lColuna		:= .F.
Local nColuna		:= 0
Local cTpValor		:= AllTrim( GetMV("MV_TPVALOR") )
Local lImpTrmAux	:= Iif(mv_par06 == 1,.T.,.F.)
Local cArqTrm		:= ""                                       
Local cMoedaDesc	:= mv_par11 

Local nDifCol
Local nTamPict		:= 0
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nLenVlrInt

Local lVerTamanho	:= .F.
Local nMaximo

Local oFont07		:= TFont():New("Courier New",,07,,.F.,,,,.T.,.F.)
Local oCouNew07N	:= TFont():New("Courier New",,07,,.T.,,,,.T.,.F.)		// Negrito
Local oCouNew07S	:= TFont():New("Courier New",,07,,.T.,,,,.T.,.T.)		// SubLinhado

Local oFontOld08	:= TFont():New("Courier New",,08,,.F.,,,,.T.,.F.)
Local oCouOld08N	:= TFont():New("Courier New",,08,,.T.,,,,.T.,.F.)		// Negrito
Local oCouOld08S	:= TFont():New("Courier New",,08,,.T.,,,,.T.,.T.)		// SubLinhado

Local oArial08		:= TFont():New("Arial",,08,,.F.,,,,.T.,.F.)
Local oArial08N		:= TFont():New("Arial",,08,,.T.,,,,.T.,.F.)		// Negrito
Local oArial08S		:= TFont():New("Arial",,08,,.T.,,,,.T.,.T.)		// SubLinhado


Local aDifCol		:= Array(3,2)
Local aLenVlrInt	:= Array(3)
Local aMaximo		:= Array(3)

If lSemestre
	If lPeriodoAnt
		aAdd(aPosCol, {  025,  640,  960, 1280, 1590 } )
		aAdd(aPosCol, { 1590, 2220, 2540, 2860, 3180 } )
	Else
		aAdd(aPosCol, {  025,  800, 1200,   NIL, 1590 } )
		aAdd(aPosCol, { 1590, 2385, 2785,   NIL, 3180 } )
	EndIf
Else
	If lPeriodoAnt
		aAdd(aPosCol, {  025,  NIL,  890, 1240, 1590 } )
		aAdd(aPosCol, { 1590,  NIL, 2480, 2830, 3180 } )
	Else
		aAdd(aPosCol, {  025,  NIL, 1190,  NIL, 1590 } )
		aAdd(aPosCol, { 1590,  NIL, 2780,  NIL, 3180 } )
	EndIf
EndIf

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda 	:= AllTrim(aCtbMoeda[3])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture := aSetOfBook[4]
nTamPict := Len(Trans(0,cPicture))
If ! Empty(cPicture) .And. nTamPict > 17		// Bops 59240
	cPicture := ""
	nDecimais := Nil
Endif
              
m_pag := mv_par05
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
						"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
						"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
						MV_PAR12,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
						,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)},;
			STR0006, cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")
dbGoTop()
lColuna	:= FieldPos("COLUNA") > 0

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


aLenVlrInt[1]	:= aTamVal[1]	//	Coluna Semestre
aLenVlrInt[2]	:= aTamVal[1]	//	Coluna Exercicio
aLenVlrInt[3]	:= aTamVal[1] 	//	Coluna Anterior

aMaximo[1]		:= If( cTpValor == "D", 12, 14 )	//	Coluna Semestre
aMaximo[2]		:= If( cTpValor == "D", 12, 14 )	//	Coluna Exercicio
aMaximo[3]		:= If( cTpValor == "D", 12, 14 )	//	Coluna Anterior


// Quanto maiores os valores de aDifCol, mais à esquerda sera impresso o valor na coluna
// Fonte com tamanho 8

aDifCol[1,1]	:= If( cTpValor == "D", 10, 0 )	//	Coluna Semestre
aDifCol[2,1]	:= If( cTpValor == "D", 10, 0 )	//	Coluna Exercicio
aDifCol[3,1]	:= If( cTpValor == "D", 10, 0 )  	//	Coluna Anterior

// Fonte com tamanho 6
aDifCol[1,2]	:= If( cTpValor == "D", 10, 0 )	//	Coluna Semestre
aDifCol[2,2]	:= If( cTpValor == "D", 10, 0 )	//	Coluna Exercicio
aDifCol[3,2]	:= If( cTpValor == "D", 10, 0 )	//	Coluna Exercicio

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
		If COLUNA < 2
			nColuna := 1
		Else
			nColuna := 2
		Endif
	Else
		nColuna := 1
	Endif
	If IDENTIFI = "4"
		aMaxCol[nColuna][C_CONTA] 		:= CONTA
		aMaxCol[nColuna][C_DESC] 		:= Subs(DESCCTA,1,40)
		aMaxCol[nColuna][C_SITNORMAL]	:= NORMAL
		aMaxCol[nColuna][C_NIVEL]		:= NIVEL
		aMaxCol[nColuna][C_IDENTIFI]	:= "4"
		aMaxCol[nColuna][C_SALDOANT] 	+= SALDOANT
		aMaxCol[nColuna][C_SALDOATU] 	+= SALDOATU
		If lSemestre
			aMaxCol[nColuna][C_SALDOSEM] += SALDOSEM
		Endif
	Else
		Aadd(aColunas[nColuna], { 	CONTA, DESCCTA, NORMAL, NIVEL, IDENTIFI,;
									If(lSemestre, SALDOSEM, 0), SALDOATU, SALDOANT })
		aMaxCol[nColuna][C_TOTAL] ++
	Endif                                                  
	If ! lVerTamanho
		lVerTamanho := (Len( Alltrim( Str( SALDOANT ) ) ) >= aMaximo[3]) .Or.;
		               (Len( Alltrim( Str( SALDOATU ) ) ) >= aMaximo[2]) .Or.;
	    	           (lSemestre .And. Len( Alltrim( Str( SALDOSEM ) ) ) >= aMaximo[1])
	EndIf
	DbSkip()
EndDo

If aMaxCol[1][C_TOTAL] > aMaxCol[2][C_TOTAL]
	nMaxCol := aMaxCol[1][C_TOTAL]
Else
	nMaxCol := aMaxCol[2][C_TOTAL]
Endif

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2")


nCol1Pos	:= 0
nCol2Pos	:= 0
For nColuna := 1 To nMaxCol
	nCol1Pos++
	nCol2Pos++                   
	
	If nCol1Pos > Len(aColunas[1]) .and. nCol2Pos > Len(aColunas[2])
		Exit
	Endif

	If lin > 2300
		If !lFirstPage
			oPrint:Line( ntraco,015,ntraco,3180 )   	// horizontal                          			
		EndIf	
		i++                                                
		oPrint:EndPage() 	 											// Finaliza a pagina
		CtbCbcDem( oPrint, titulo, .T./*lLandScape*/, 3180, 015)		// Funcao que monta o cabecalho padrao 
		Lin := Ctr500Esp(oPrint, cDescMoeda, mv_par04 = 1, aPosCol)	// Cabecalho especifico do CTBR500
		lFirstPage := .F.		
	End                                                                 

	If 	(nColuna <= Len(aColunas[1]) .And. aColunas[1][nColuna][C_DESC] = "-") .Or.;
		(nColuna <= Len(aColunas[2]) .And. aColunas[2][nColuna][C_DESC] = "-")
		oPrint:Line(lin,015,lin,3180)   	// horizontal
	Else
		oPrint:Line( lin,015,lin+50,015 )   // vertical
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
					If aColunas[2][nCol2Pos][C_SALDOS + 2] <> 0  .OR. aColunas[2][nCol2Pos][C_NIVEL]==1				/// SE O SALDO ATUAL NAO ESTIVER ZERADO OU FOR SINTETICA
						Exit
					Endif
				Endif
				nCol2Pos++
			EndDo
		Endif

// 1. Coluna
		If nCol1Pos <= Len(aColunas[1])
			nPosCol := aPosCol[1][1] + (aColunas[1][nCol1Pos][C_NIVEL]) * 15
			oPrint:Say(lin+15,nPosCol,aColunas[1][nCol1Pos][C_DESC],;
					    If(aColunas[1][nCol1Pos][C_IDENTIFI] $ "346",;
					        If(lSemestre .And. lPeriodoAnt, oCouNew07N,oArial08N),;
					        If(lSemestre .And. lPeriodoAnt, oFont07,oArial08)))
    	 	
			If aColunas[1][nCol1Pos][C_IDENTIFI] < "5"
				For nPosCol := 2 To Len(aPosCol[1]) - 1
					If aPosCol[1][nPosCol] # Nil
						nDifCol	   := aDifCol   [ nPosCol - 1 , 1 ] 
						nLenVlrInt := aLenVlrInt[ nPosCol - 1  ] 

						If lVerTamanho   //muda fonte mas tem que preservar variavel oFont08 etc
										//por conta da funcao ValorCTB()
							oFont08		:= oFont07
							oCouNew08N	:= oCouNew07N		// Negrito
							oCouNew08S	:= oCouNew07S		// SubLinhado
						EndIf

						ValorCTB(aColunas[1][nCol1Pos][C_SALDOS + nPosCol - 1],lin+15,;
								 aPosCol[1][nPosCol]+nDifCol,nLenVlrInt,nDecimais,.T.,cPicture,;
								 aColunas[1][nCol1Pos][C_SITNORMAL],;
							  	 aColunas[1][nCol1Pos][C_CONTA],.T.,oPrint,cTpValor,;
							     Iif(aColunas[1][nCol1Pos][C_IDENTIFI]$"4","1",aColunas[1][nCol1Pos][C_IDENTIFI]))							     

					Endif
				Next                                 
			Endif
		Endif

		For nPosCol := 2 To Len(aPosCol[1])
			If aPosCol[1][nPosCol] # Nil
				oPrint:Line(lin,aPosCol[1][nPosCol],lin+50,aPosCol[1][nPosCol])	// Separador vertical 
			Endif
		Next

// 2. Coluna
		If nCol2Pos <= Len(aColunas[2])
			nPosCol := aPosCol[2][1] + (aColunas[2][nCol2Pos][C_NIVEL]) * 15
			oPrint:Say(lin+15,nPosCol,aColunas[2][nCol2Pos][C_DESC],;
							  	    If(aColunas[2][nCol2Pos][C_IDENTIFI] $ "346",; 
								    	If(lSemestre .And. lPeriodoAnt, oCouNew07N,oArial08N),;
					    			 	If(lSemestre .And. lPeriodoAnt, oFont07,oArial08)))

			If aColunas[2][nCol2Pos][C_IDENTIFI] < "5"
				For nPosCol := 2 To Len(aPosCol[2]) - 1
					If aPosCol[2][nPosCol] # Nil
						nDifCol	   := aDifCol   [ nPosCol - 1 , 1 ]
						nLenVlrInt := aLenVlrInt[ nPosCol - 1 ]

						If lVerTamanho   //muda fonte mas tem que preservar variavel oFont08 etc
										//por conta da funcao ValorCTB()
							oFont08		:= oFont07
							oCouNew08N	:= oCouNew07N		// Negrito
							oCouNew08S	:= oCouNew07S		// SubLinhado
						EndIf

						ValorCTB(aColunas[2][nCol2Pos][C_SALDOS + nPosCol - 1],lin+15,;
								 aPosCol[2][nPosCol]+nDifCol,nLenVlrInt,nDecimais,.T.,cPicture,;
								 aColunas[2][nCol2Pos][C_SITNORMAL],;
							  	 aColunas[2][nCol2Pos][C_CONTA],.T.,oPrint,cTpValor,;
							     Iif(aColunas[2][nCol2Pos][C_IDENTIFI]$"4","1",aColunas[2][nCol2Pos][C_IDENTIFI]))							     							  	 

					Endif
				Next
			Endif
		Endif
	
		For nPosCol := 2 To Len(aPosCol[2])
			If aPosCol[2][nPosCol] # Nil
				oPrint:Line(lin,aPosCol[2][nPosCol],lin+50,aPosCol[2][nPosCol])	// Separador vertical 
			Endif
		Next
	
		lin +=47
	Endif

	nTraco := lin + 1
Next
oPrint:Line(lin,015,lin,3180)   	// horizontal

oPrint:Line( lin,015,lin+47, 015 )   	// vertical

// 1 Coluna

nPosCol := aPosCol[1][1] + 15 + (aMaxCol[1][C_NIVEL]) * 15
oPrint:Say(lin+15,nPosCol,aMaxCol[1][C_DESC],oArial08N)
For nPosCol := 2 To Len(aPosCol[1])
	If aPosCol[1][nPosCol] # Nil .And. (C_SALDOS + nPosCol - 1) < Len(aMaxCol[1])
		nDifCol	   := aDifCol   [ nPosCol - 1, 1 ] 
		nLenVlrInt := aLenVlrInt[ nPosCol - 1 ] 

		If lVerTamanho   //muda fonte mas tem que preservar variavel oFont08 etc
						//por conta da funcao ValorCTB()
				oFont08		:= oFont07
				oCouNew08N	:= oCouNew07N		// Negrito
				oCouNew08S	:= oCouNew07S		// SubLinhado
		EndIf
		ValorCTB(aMaxCol[1][C_SALDOS + nPosCol - 1],lin+15,;
			     aPosCol[1][nPosCol]+nDifCol,nLenVlrInt,nDecimais,.T.,cPicture,;
				 aMaxCol[1][C_SITNORMAL],;
			  	 aMaxCol[1][C_CONTA],.T.,oPrint,cTpValor, "1")//Esta sendo enviado "1" para que respeite  
																//o sinal na impressao do valor.							  	 
	Endif                              
	If aPosCol[1][nPosCol] <> Nil
		oPrint:Line(lin,aPosCol[1][nPosCol],lin+47,aPosCol[1][nPosCol])	// Separador vertical 
	EndIf
Next

// 2 Coluna

nPosCol := aPosCol[2][1] + 15 + (aMaxCol[2][C_NIVEL]) * 15
oPrint:Say(lin+15,nPosCol,aMaxCol[2][C_DESC],oArial08N)
For nPosCol := 2 To Len(aPosCol[2])
	If aPosCol[2][nPosCol] # Nil .And. (C_SALDOS + nPosCol - 1) < Len(aMaxCol[2])
		nDifCol	   := aDifCol   [ nPosCol - 1, 1 ] 
		nLenVlrInt := aLenVlrInt[ nPosCol - 1 ] 
		If lVerTamanho   //muda fonte mas tem que preservar variavel oFont08 etc
						//por conta da funcao ValorCTB()
			oFont08		:= oFont07
			oCouNew08N	:= oCouNew07N		// Negrito
			oCouNew08S	:= oCouNew07S		// SubLinhado
		EndIf
		ValorCTB(aMaxCol[2][C_SALDOS + nPosCol - 1],lin+15,;
			     aPosCol[2][nPosCol]+nDifCol,nLenVlrInt,nDecimais,.T.,cPicture,;
				 aMaxCol[2][C_SITNORMAL],;
			  	 aMaxCol[2][C_CONTA],.T.,oPrint,cTpValor, "1")	//Esta sendo enviado "1" para que respeite  

	Endif                              
	If aPosCol[2][nPosCol] <> Nil
		oPrint:Line(lin,aPosCol[2][nPosCol],lin+47,aPosCol[2][nPosCol])	// Separador vertical 
	EndIf
Next

lin +=47
oPrint:Line(lin,015,lin,3180)   	// horizontal

lin += 10


If lImpTrmAux
	If lin > 2300
		i++                                                
		oPrint:EndPage() 	 											// Finaliza a pagina
		CtbCbcDem( oPrint, titulo, .T./*lLandScape*/, 3180, 015)			 							// Funcao que monta o cabecalho padrao 
		Lin := 304							/// Tamanha da linha retornado pela CTr500Esp
		If lSemestre
			Lin+=40
		Endif
		lFirstPage := .F.		
	Endif
	cArqTRM 	:= mv_par07
	aVariaveis	:= {}

    // Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek( padr( "CTR500" , Len( SX1->X1_GRUPO ) , ' ' ) + "01" ) )
	Do While SX1->X1_GRUPO == padr( "CTR500" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	EndDo
	
	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0013) // "Responsáveis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm(cArqTRM,aVariaveis,"",.T.,{oPrint,oFont08,Lin})
	Endif	 
Endif

Return lin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctr500Cfg ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria os objetos para relat. grafico.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctr500Cfg(titulo,cFuncao,cProcesso,lLandScape,	uParam1,uParam2,uParam3,;
														uParam4, uParam5)
		
Local oPrint
Local i 		:= 1
Local lPreview

DEFAULT lLandScape := .T.

If Upper(cFuncao) <> "CTBENVPRINT" .And. Empty(CTBSetOf(mv_par02)[5])
	ApMsgAlert(	STR0012) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

If Upper(Alltrim(FunName())) == "CTBR510"
	oFont08		:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oCouNew08N	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)		// Negrito
	oCouNew08S	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.T.)		// SubLinhado
Else
	oFont08		:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oCouNew08N	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)		// Negrito
	oCouNew08S	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.T.)		// SubLinhado
EndIf
oCouNew10	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oCouNew14	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
oCouNew16	:= TFont():New("Courier New",16,16,,.T.,,,,.T.,.F.)

oArial08N	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)

oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)

oPrint:= TMSPrinter():New( titulo )
If lLandScape
	oPrint:SetLandscape()
Else                                             
	oPrint:SetPortrait()
Endif

//oPrint:Setup()

lPreview := (&cFuncao.(oPrint, i, Titulo, cProcesso, lLandScape, 	uParam1, uParam2, uParam3,;
														uParam4, uParam5))

If ValType(lPreview) <> "L" .Or. lPreview
	oPrint:Preview()  // Visualiza antes de imprimir
EndIf	


Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTR500Esp ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho Especifico do relatorio CTBR500.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR500Esp(ParO1,ParC1)			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpC1 = Descricao da moeda sendo impressa                  ³±±
±±³          ³ ExpL1 = Indica se apresenta coluna de semestre             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR500Esp(oPrint, cDescMoeda, lSemestre, aPosCol)

Local nPosCol, aCabec := { { 	STR0007 + cDescMoeda + ")",; //"Ativo (Em "
		  						If(lSemestre, STR0008,),; //"  Semestre  "
		  						Dtoc(dFinal, "ddmmyyyy"),;
		  						Dtoc(dFinalA, "ddmmyyyy") },;
							{ 	STR0009  + cDescMoeda + " )",; //"Passivo (Em "
		  						IF(lSemestre, STR0008,),; //"  Semestre  "
		  						Dtoc(dFinal, "ddmmyyyy"),;
		  						Dtoc(dFinalA, "ddmmyyyy") } }, nCabec
Local nLin			:= 260
Local oArial10NS	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.T.)
Local nPosMais 		:= 0
                                   
If lSemestre                       
	oPrint:Say(nLin,aPosCol[1][3],Space(10) + Str(Year(dFinal) , 4) + Space(10),oArial10NS)
	If aPosCol[1][4] # Nil	//	Se estiver <> Nil, demonstra periodo anterior (mv_par10 == 1)
		oPrint:Say(nLin,aPosCol[1][4],Space(10) + Str(Year(dFinalA), 4) + Space(10),oArial10NS)
	EndIf
	aCabec[1][3] := STR0010 //"   Exercicio   "
	aCabec[1][4] := STR0010 //"   Exercicio   "
	
	oPrint:Say(nLin,aPosCol[2][3],Space(10) + Str(Year(dFinal) , 4) + Space(10),oArial10NS)
	If aPosCol[1][4] # Nil	//	Se estiver <> Nil, demonstra periodo anterior (mv_par10 == 1)
		oPrint:Say(nLin,aPosCol[2][4],Space(10) + Str(Year(dFinalA), 4) + Space(10),oArial10NS)
	EndIf
	aCabec[2][3] := STR0010 //"   Exercicio   "
	aCabec[2][4] := STR0010 //"   Exercicio   "
	nLin += 40
Else
	nLin += 40
Endif

For nCabec := 1 To Len(aCabec)
	For nPosCol := 1 To Len(aCabec[nCabec])
		If aPosCol[nCabec][nPosCol] # Nil
			If nCabec == 2 .And. nPosCol == 1
				nPosMais := AT("+", aCabec[nCabec][nPosCol])
				oPrint:Say(nLin-40,aPosCol[nCabec][nPosCol] + 30,Subs(aCabec[nCabec][nPosCol],1,nPosMais),oArial10)
				oPrint:Say(nLin   ,aPosCol[nCabec][nPosCol] + 30,Alltrim(Subs(aCabec[nCabec][nPosCol],nPosMais+1)),oArial10)
			Else
				If nPosCol >= 2  //data das colunas de valores desloca 80 para direita para centralizar mais ou menos
					oPrint:Say(nLin,aPosCol[nCabec][nPosCol] + 80,aCabec[nCabec][nPosCol],oArial10)
				Else
					oPrint:Say(nLin,aPosCol[nCabec][nPosCol] + 30,aCabec[nCabec][nPosCol],oArial10)
				EndIf
			EndIf	
		Endif
	Next
Next

oPrint:Line(250,015,nLin + 40,015)   			// vertical
oPrint:Line(250,3180,nLin + 40,3180)   			// vertical

oPrint:Line(nLin + 40,015,nLin + 40,3180) 	// horizontal

Return nLin + 44

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtrVld500    ³ Autor ³ Wagner Mobile Costa	³ Data ³ 25/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas dos relatorios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtrVld500(cPerg)


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return .F.
EndIf

If ! Pergunte(cPerg,.T.) 
	Return .F.
Endif                    

If Empty(mv_par01)	
	Help(" ",1,"NOEXCONTAB")	
	Return .F.		
Else
	CTG->(dbSetOrder(1))
	If CTG->(! DbSeek(xFilial() + mv_par01))
		Help(" ",1,"NOEXISCALE")
		Return .F.
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTR500VLD    ³Autor ³ Paulo Augusto        ³Data³ 08/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida pergunta da data de referencia                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTR500VLD()
Local dDatIni
Local dDatFin
Local lRet:= .T.
If !Empty(MV_PAR09)
	CTG->(DbSeek(xFilial() + mv_par01))
	dDatIni:=CTG->CTG_DTINI
	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dDatFin	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo
	If  MV_PAR09 < dDatIni  .or.  MV_PAR09 > dDatFin
		lRet:= .F.
		MsgAlert(STR0014,STR0015)// # "Data Informada nao pertence ao calendario selecionado" ### "Data Invalida"
	EndIf	
EndIf

Return(lRet)
