#INCLUDE "CTBR500P.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr500	³ Autor ³ Wagner Mobile Costa	³ Data ³ 08.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demostrativo de balancos patrimoniais - MCASP 		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR500P()                   
Local aSetOfBook	:= {}	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.
Local nHandle       := 0

Private aSelFil	 	:= {}
PRIVATE CPERG	   	:= "CTR500P" 
Private nomeprog	:= "CTBR500P"       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
If ! CtrVld500P(cPerg)
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

If lRet .And. (mv_par06==1)
	If Empty(mv_par07)
		MsgAlert(STR0038) //"O Arquivo de termo .TRM não informado. Verifique!"
		lRet := .F.
	Else
		If (nHandle := FOpen(mv_par07, 3)) < 0
			MsgAlert(STR0037) //"O Arquivo de termo (.TRM) nao pode estar como somente leitura."
			lRet := .F.
		Else
			FClose(nHandle)
		EndIf
	EndIf
EndIf

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

//Limpa os arquivos temporários 
CTBGerClean()

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

Local oReport, oSection1, oSecFil, oQuadro1, oNotExplic
Local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR500P"
Local cTITULO		:= Capital(STR0001)		// BALANCOS PATRIMONIAIS
Local cDESC			:= STR0016 + STR0017
Local cCodVisao     := aSetOfBook[5]
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 20
Local dFinal 		:= CTOD(SPACE(8))

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
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dFinal,cCodVisao), .T., oReport:CancelPrint())}, CDESC)
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
TRCell():New( oSection1, "ANOTAEXP"  , ,STR0020                 /*Titulo*/,/*Picture*/,TamSx3("QLQ_CODIGO")[1]+1/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.) //"NE"
TRCell():New( oSection1, "ASEMESTRE" , ,STR(nAno)+CRLF+STR0008  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "AEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "AEXERANT"  , ,STR(nAno-1)+CRLF+STR0010/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
// Colunas referentes ao Passivo
TRCell():New( oSection1, "PASSIVO"   , ,StrTran(STR0009, "+ ", "+"+CRLF)+cDescMoeda+")"  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,5,.T.)
TRCell():New( oSection1, "PNOTAEXP"  , ,STR0020                 /*Titulo*/,/*Picture*/,TamSx3("QLQ_CODIGO")[1]+1/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.) //"NE"
TRCell():New( oSection1, "PSEMESTRE" , ,STR(nAno)+CRLF+STR0008  /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "PEXERCICIO", ,cTitCol                 /*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "PEXERANT"  , ,STR(nAno-1)+CRLF+STR0010/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)

oSection1:SetTotalInLine(.F.)

//oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDatabase,cTitulo,,,,,oReport) } )

/*
GESTAO - inicio */
/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL",,STR0021,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/) //"Código"
TRCell():New(oSecFil,"EMPRESA",,STR0022,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0023,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Unidade de negócio"
TRCell():New(oSecFil,"NOMEFIL",,STR0024,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Filial"

//Criacao da Secao Quadro I - TITULO DO RELATORIO
oQuadro1 := TRSection():New(oReport, "QUADRO1", {},,,,, .F./*<lTotalInLine>*/ ,,,,,, .T./*<lLineStyle>*/,,,, 0/*<nLinesBefore>*/, 1/*<nCols>*/)
TRCell():New(oQuadro1, "TITREL1",, "",, 140, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)  
TRCell():New(oQuadro1, "TITREL2",, "",, 140, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.) 

//Criacao da Secao Nota Explicativa
oNotExplic := TRSection():New(oReport, "NEXP", {},,,,, .F./*<lTotalInLine>*/,,,,,, .T./*<lLineStyle>*/,,,, 0/*<nLinesBefore>*/, 1/*<nCols>*/)
TRCell():New(oNotExplic, "CODNOT",, STR0025,,  10, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)               //"Código NE"
TRCell():New(oNotExplic, "DATNOT",, STR0026,,  10, /*lPixel*/, /*CodeBlock*/,,,,,,,,,)                   //"Data NE"
TRCell():New(oNotExplic, "OBSNOT",, STR0027,, 140, /*lPixel*/, /*CodeBlock*/,"LEFT",.T.,"CENTER",,,,,,)  //"Observ.NE"

If mv_par04==1
	oReport:DisableOrientation() 
EndIf

/* GESTAO - fim
*/   

RestArea(aArea)

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
Static Function ReportPrint( oReport,Titulo, dFinal, cCodVisao )  
Local oSection1 	:= oReport:Section(1)  

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cArqTmp

Local cPicture
Local aColunas		:= { {}, {} }
Local aResumo		:= { {}, {} }
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
Local nI			:= 0
Local nDifRes       := 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local cResumo       := ""
Local oSecFil		:= oReport:Section("SECFIL") 
Local oQuadro1      := oReport:Section("QUADRO1")
Local oNotExplic    := oReport:Section("NEXP")
Local aSM0			:= {}  
Local aNotaExpl     := {}
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
	oReport:SetTitle(cTitulo + " (" + STR0028 + ")") //"Filiais selecionadas para o relatorio"
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
//³ Monta Arquivo Temporario para Impressao							  ³
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

//Resumo a ser apresentado no final do relatorio
cResumo := STR0031 + "|" + STR0032 + "|" + STR0033 + "|" + STR0034 + "|" + STR0035 //"ATIVO FINANCEIRO" #"ATIVO PERMANENTE" ##"PASSIVO FINANCEIRO ###"PASSIVO PERMANENTE ####"SALDO PATRIMONIAL"

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
	ElseIf AllTrim(SUPERIOR)=='3.1' .Or. AllTrim(SUPERIOR)=='3.2'
		Aadd(aResumo[nColuna], { 	CONTA, Space(NIVEL)+DESCCTA, NORMAL, NIVEL, IDENTIFI,;
									If(lSemestre, SALDOSEM, 0), SALDOATU, SALDOANT })
	ElseIf Left(CONTA,1) <> '3'
		Aadd(aColunas[nColuna], { 	CONTA, Space(NIVEL)+DESCCTA, NORMAL, NIVEL, IDENTIFI,;
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

	If (nCol1Pos > Len(aColunas[1]) .or. nCol1Pos > nMaxCol) .and. (nCol2Pos > Len(aColunas[2]) .or. nCol2Pos > nMaxCol)
		oSection1:Cell("ANOTAEXP"):SetBlock( { || " " } )
		oSection1:Cell("PNOTAEXP"):SetBlock( { || " " } )
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

						oSection1:Cell("ANOTAEXP"):SetBlock( { || CodeNota(aColunas[1][nCol1Pos][C_CONTA], cCodVisao, dFinalA+1, dFinal, aNotaExpl) } )
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

						oSection1:Cell("ANOTAEXP"):SetBlock( { || " " } )
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

						oSection1:Cell("PNOTAEXP"):SetBlock( { || CodeNota(aColunas[2][nCol2Pos][C_CONTA], cCodVisao, dFinalA+1, dFinal, aNotaExpl) } )
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
						
						oSection1:Cell("PNOTAEXP"):SetBlock( { || " " } )
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

			oSection1:Cell("ANOTAEXP"):SetBlock( { || " " } )
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

			oSection1:Cell("PNOTAEXP"):SetBlock( { || " " } )
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

	oSection1:Cell("PNOTAEXP"):SetBlock( { || "" } )
ElseIf Len( aPosCol[2] ) > Len( aPosCol[1] )
	oSection1:Cell("ATIVO"     ):SetBlock( {|| ""} )
	oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )
	If lSemestre
		oSection1:Cell("ASEMESTRE" ):SetBlock( {|| ""} )
	EndIf
	If lPeriodoAnt
		oSection1:Cell("AEXERANT"  ):SetBlock( {|| ""} )
	EndIf

	oSection1:Cell("ANOTAEXP"):SetBlock( { || "" } )
EndIf


oSection1:PrintLine()

oReport:ThinLine()

//Imprime Resumos
If Len(aResumo[1]) > 0 .Or. Len(aResumo[2]) > 0 
	oReport:SkipLine()
	oReport:ThinLine()
	
	//Ajusta tamanho do Resumo
	If Len(aResumo[1]) > Len(aResumo[2]) //Completa resumo da coluna 2
		nDifRes := Len(aResumo[1]) - Len(aResumo[2])

		For nI := 1 To nDifRes
			Aadd(aResumo[2], { "", "", "", 0, 0, 0.00, 0.00, 0 })
		Next nI
	ElseIf Len(aResumo[2]) > Len(aResumo[1]) //Completa resumo da coluna 1
		nDifRes := Len(aResumo[2]) - Len(aResumo[1])

		For nI := 1 To nDifRes
			Aadd(aResumo[1], { "", "", "", 0, 0, 0.00, 0.00, 0 })
		Next nI
	EndIf

	//Totalizadores do Resumo
	Aadd(aResumo[1], { STR0036, STR0036, "", 0, 0, 0.00, 0.00, 0 }) //"TOTAL"
	Aadd(aResumo[2], { STR0036, STR0036, "", 0, 0, 0.00, 0.00, 0 }) //"TOTAL"

	For nI := 1 To Len(aResumo[1])
		// 1 Coluna
		oSection1:Cell("ATIVO"):SetBlock( { || aResumo[1][nI][C_DESC] } )
		
		If lSemestre
			oSection1:Cell("ASEMESTRE"):SetBlock( { || ValorCTB( aResumo[1][nI][C_SALDOSEM],,,aTamVal[1],nDecimais,.T.,cPicture,;
																aResumo[1][nI][C_SITNORMAL],aResumo[1][nI][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf
		
		oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aResumo[1][nI][C_SALDOATU],,,aTamVal[1],nDecimais,.T.,cPicture,;
																aResumo[1][nI][C_SITNORMAL],aResumo[1][nI][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		If lPeriodoAnt
			oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aResumo[1][nI][C_SALDOANT],,,aTamVal[1],nDecimais,.T.,cPicture,;
																aResumo[1][nI][C_SITNORMAL],aResumo[1][nI][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf

		//Exibicao de colunas
		If !Empty(aResumo[1][nI][C_CONTA])
			oSection1:Cell("ASEMESTRE"):Show()
			oSection1:Cell("AEXERCICIO"):Show()
			oSection1:Cell("AEXERANT"):Show()
		Else
			oSection1:Cell("ASEMESTRE"):Hide()
			oSection1:Cell("AEXERCICIO"):Hide()
			oSection1:Cell("AEXERANT"):Hide()
		EndIf

		// 2 Coluna
		oSection1:Cell("PASSIVO"):SetBlock( { || aResumo[2][nI][C_DESC] } )
		
		If lSemestre
			oSection1:Cell("PSEMESTRE"):SetBlock( { || ValorCTB( aResumo[2][nI][C_SALDOSEM],,,aTamVal[1],nDecimais,.T.,cPicture,;
								aResumo[2][nI][C_SITNORMAL],aResumo[2][nI][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf

		oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aResumo[2][nI][C_SALDOATU],,,aTamVal[1],nDecimais,.T.,cPicture,;
								aResumo[2][nI][C_SITNORMAL],aResumo[2][nI][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		
		If lPeriodoAnt
			oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aResumo[2][nI][C_SALDOANT],,,aTamVal[1],nDecimais,.T.,cPicture,;
								aResumo[2][nI][C_SITNORMAL],aResumo[2][nI][C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
		EndIf

		//Exibicao de colunas
		If !Empty(aResumo[2][nI][C_CONTA])
			oSection1:Cell("PSEMESTRE"):Show()
			oSection1:Cell("PEXERCICIO"):Show()
			oSection1:Cell("PEXERANT"):Show()
		Else
			oSection1:Cell("PSEMESTRE"):Hide()
			oSection1:Cell("PEXERCICIO"):Hide()
			oSection1:Cell("PEXERANT"):Hide()
		EndIf

		oSection1:PrintLine()
		
		//Alimenta Totalizadores do Resumo
		If nI < Len(aResumo[1])  
			aResumo[1][Len(aResumo[1])][C_SALDOSEM] += aResumo[1][nI][C_SALDOSEM]
			aResumo[1][Len(aResumo[1])][C_SALDOATU] += aResumo[1][nI][C_SALDOATU]
			aResumo[1][Len(aResumo[1])][C_SALDOANT] += aResumo[1][nI][C_SALDOANT]
			aResumo[2][Len(aResumo[1])][C_SALDOSEM] += aResumo[2][nI][C_SALDOSEM]
			aResumo[2][Len(aResumo[1])][C_SALDOATU] += aResumo[2][nI][C_SALDOATU]
			aResumo[2][Len(aResumo[1])][C_SALDOANT] += aResumo[2][nI][C_SALDOANT]
		EndIf                           
	Next nI

	oReport:ThinLine()
EndIf

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

//Impressao de Notas Explicativas
If Len(aNotaExpl) > 0
    oReport:EndPage() //Finaliza Folha de Impressao
    
    oQuadro1:Init()
    oQuadro1:Cell("TITREL1"):SetBlock({|| STR0001}) //Demostrativo de balancos patrimoniais - MCASP
    oQuadro1:Cell("TITREL2"):SetBlock({|| STR0029 + DToC(dFinal)}) //"Em: "
    oQuadro1:PrintLine()
	oQuadro1:Finish()
	
    oReport:ThinLine()
	oReport:PrintText(STR0030) //"** NOTAS EXPLICATIVAS **"
	oReport:ThinLine()

    oNotExplic:Init()

	For nI := 1 To Len(aNotaExpl)
		QLQ->(dbGoto(aNotaExpl[nI]))

        oNotExplic:Cell("CODNOT"):SetBlock({|| QLQ->QLQ_CODIGO})
        oNotExplic:Cell("DATNOT"):SetBlock({|| DToC(QLQ->QLQ_DATA)})
        oNotExplic:Cell("OBSNOT"):SetBlock({|| QLQ->QLQ_DESCNE})
		oNotExplic:PrintLine()
	Next nI

	oNotExplic:Finish()
EndIf

oReport:EndPage()

Return .T.



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtrVld500P    ³ Autor ³ Wagner Mobile Costa	³ Data ³ 25/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas dos relatorios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CtrVld500P(cPerg)

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

/*{Protheus.doc} Code_NE()
Retorna o codigo da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CodeNota(cCodConta, cCodVisao, dRefIni, dRefFim, aNotaExp)

Local cContaGer := ""
Local cCodeNota := ""
Local nRegQLQ := 0

//tem que estar posicionado na tabela de saida da visao gerencial
cContaGer := Padr(cCodConta, TamSx3("QLQ_CONTAG")[1])

//busca pela codigo da conta gerencial por query
//indice 1 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CODIGO+QLQ_CONTAG
//indice 2 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG+DTOS(QLQ_DATA)
QLQ->( dbSetOrder(2) )

//primeiro busca na data
If QLQ->( dbSeek( xFilial("QLQ")+cCodVisao+cContaGer+DtoS(dRefFim) ) )
	cCodeNota := QLQ->QLQ_CODIGO
	nRegQLQ   := QLQ->( Recno() )
	
	If !Empty(cCodeNota) .And. aScan(aNotaExp, {|x| x == nRegQLQ}) == 0
		aAdd( aNotaExp, nRegQLQ )
	EndIf

ElseIf QLQ->( dbSeek( xFilial("QLQ")+cCodVisao+cContaGer) )
	
	//laco para percorrer todas as notas explicativas para visao / conta gerencial
	While QLQ->( ! Eof() .And. QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG == xFilial("QLQ")+cCodVisao+cContaGer )

		If QLQ->QLQ_DATA >= dRefIni .And. QLQ->QLQ_DATA <= dRefFim
			cCodeNota := QLQ->QLQ_CODIGO
			nRegQLQ   := QLQ->( Recno() )
		EndIf

		QLQ->( dbSkip() )

	EndDo

	If !Empty(cCodeNota) .And. aScan(aNotaExp, {|x| x == nRegQLQ}) == 0
		aAdd( aNotaExp, nRegQLQ )
	EndIf

EndIf

Return( cCodeNota )
